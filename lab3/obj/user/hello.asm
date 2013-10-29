
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
  80002c:	e8 47 00 00 00       	call   800078 <libmain>
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
	cprintf("hello, world!\n");
  80003a:	68 0c 0e 80 00       	push   $0x800e0c
  80003f:	e8 24 01 00 00       	call   800168 <cprintf>
	cprintf("i am environment %08x\n", thisenv->env_id);
  800044:	a1 04 20 80 00       	mov    0x802004,%eax
  800049:	8b 40 48             	mov    0x48(%eax),%eax
  80004c:	83 c4 08             	add    $0x8,%esp
  80004f:	50                   	push   %eax
  800050:	68 1b 0e 80 00       	push   $0x800e1b
  800055:	e8 0e 01 00 00       	call   800168 <cprintf>
    cprintf("%08x\n", thisenv->env_tf.tf_regs.reg_eax);
  80005a:	a1 04 20 80 00       	mov    0x802004,%eax
  80005f:	8b 40 1c             	mov    0x1c(%eax),%eax
  800062:	83 c4 08             	add    $0x8,%esp
  800065:	50                   	push   %eax
  800066:	68 2c 0e 80 00       	push   $0x800e2c
  80006b:	e8 f8 00 00 00       	call   800168 <cprintf>
  800070:	83 c4 10             	add    $0x10,%esp
}
  800073:	c9                   	leave  
  800074:	c3                   	ret    
  800075:	00 00                	add    %al,(%eax)
	...

00800078 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800078:	55                   	push   %ebp
  800079:	89 e5                	mov    %esp,%ebp
  80007b:	56                   	push   %esi
  80007c:	53                   	push   %ebx
  80007d:	8b 75 08             	mov    0x8(%ebp),%esi
  800080:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs + ENVX(sys_getenvid());
  800083:	e8 cd 0a 00 00       	call   800b55 <sys_getenvid>
  800088:	25 ff 03 00 00       	and    $0x3ff,%eax
  80008d:	8d 04 40             	lea    (%eax,%eax,2),%eax
  800090:	c1 e0 05             	shl    $0x5,%eax
  800093:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800098:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80009d:	85 f6                	test   %esi,%esi
  80009f:	7e 07                	jle    8000a8 <libmain+0x30>
		binaryname = argv[0];
  8000a1:	8b 03                	mov    (%ebx),%eax
  8000a3:	a3 00 20 80 00       	mov    %eax,0x802000
	// call user main routine
	umain(argc, argv);
  8000a8:	83 ec 08             	sub    $0x8,%esp
  8000ab:	53                   	push   %ebx
  8000ac:	56                   	push   %esi
  8000ad:	e8 82 ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  8000b2:	e8 0d 00 00 00       	call   8000c4 <exit>
  8000b7:	83 c4 10             	add    $0x10,%esp
}
  8000ba:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000bd:	5b                   	pop    %ebx
  8000be:	5e                   	pop    %esi
  8000bf:	c9                   	leave  
  8000c0:	c3                   	ret    
  8000c1:	00 00                	add    %al,(%eax)
	...

008000c4 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000c4:	55                   	push   %ebp
  8000c5:	89 e5                	mov    %esp,%ebp
  8000c7:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  8000ca:	6a 00                	push   $0x0
  8000cc:	e8 62 0a 00 00       	call   800b33 <sys_env_destroy>
  8000d1:	83 c4 10             	add    $0x10,%esp
}
  8000d4:	c9                   	leave  
  8000d5:	c3                   	ret    
	...

008000d8 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000d8:	55                   	push   %ebp
  8000d9:	89 e5                	mov    %esp,%ebp
  8000db:	53                   	push   %ebx
  8000dc:	83 ec 04             	sub    $0x4,%esp
  8000df:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000e2:	8b 03                	mov    (%ebx),%eax
  8000e4:	8b 55 08             	mov    0x8(%ebp),%edx
  8000e7:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8000eb:	40                   	inc    %eax
  8000ec:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8000ee:	3d ff 00 00 00       	cmp    $0xff,%eax
  8000f3:	75 1a                	jne    80010f <putch+0x37>
		sys_cputs(b->buf, b->idx);
  8000f5:	83 ec 08             	sub    $0x8,%esp
  8000f8:	68 ff 00 00 00       	push   $0xff
  8000fd:	8d 43 08             	lea    0x8(%ebx),%eax
  800100:	50                   	push   %eax
  800101:	e8 e3 09 00 00       	call   800ae9 <sys_cputs>
		b->idx = 0;
  800106:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80010c:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80010f:	ff 43 04             	incl   0x4(%ebx)
}
  800112:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800115:	c9                   	leave  
  800116:	c3                   	ret    

00800117 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800117:	55                   	push   %ebp
  800118:	89 e5                	mov    %esp,%ebp
  80011a:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800120:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800127:	00 00 00 
	b.cnt = 0;
  80012a:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800131:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800134:	ff 75 0c             	pushl  0xc(%ebp)
  800137:	ff 75 08             	pushl  0x8(%ebp)
  80013a:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800140:	50                   	push   %eax
  800141:	68 d8 00 80 00       	push   $0x8000d8
  800146:	e8 82 01 00 00       	call   8002cd <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80014b:	83 c4 08             	add    $0x8,%esp
  80014e:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800154:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80015a:	50                   	push   %eax
  80015b:	e8 89 09 00 00       	call   800ae9 <sys_cputs>

	return b.cnt;
}
  800160:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800166:	c9                   	leave  
  800167:	c3                   	ret    

00800168 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800168:	55                   	push   %ebp
  800169:	89 e5                	mov    %esp,%ebp
  80016b:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80016e:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800171:	50                   	push   %eax
  800172:	ff 75 08             	pushl  0x8(%ebp)
  800175:	e8 9d ff ff ff       	call   800117 <vcprintf>
	va_end(ap);

	return cnt;
}
  80017a:	c9                   	leave  
  80017b:	c3                   	ret    

0080017c <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80017c:	55                   	push   %ebp
  80017d:	89 e5                	mov    %esp,%ebp
  80017f:	57                   	push   %edi
  800180:	56                   	push   %esi
  800181:	53                   	push   %ebx
  800182:	83 ec 2c             	sub    $0x2c,%esp
  800185:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800188:	89 d6                	mov    %edx,%esi
  80018a:	8b 45 08             	mov    0x8(%ebp),%eax
  80018d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800190:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800193:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800196:	8b 45 10             	mov    0x10(%ebp),%eax
  800199:	8b 5d 14             	mov    0x14(%ebp),%ebx
  80019c:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80019f:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8001a2:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  8001a9:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
  8001ac:	72 0c                	jb     8001ba <printnum+0x3e>
  8001ae:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  8001b1:	76 07                	jbe    8001ba <printnum+0x3e>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8001b3:	4b                   	dec    %ebx
  8001b4:	85 db                	test   %ebx,%ebx
  8001b6:	7f 31                	jg     8001e9 <printnum+0x6d>
  8001b8:	eb 3f                	jmp    8001f9 <printnum+0x7d>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001ba:	83 ec 0c             	sub    $0xc,%esp
  8001bd:	57                   	push   %edi
  8001be:	4b                   	dec    %ebx
  8001bf:	53                   	push   %ebx
  8001c0:	50                   	push   %eax
  8001c1:	83 ec 08             	sub    $0x8,%esp
  8001c4:	ff 75 d4             	pushl  -0x2c(%ebp)
  8001c7:	ff 75 d0             	pushl  -0x30(%ebp)
  8001ca:	ff 75 dc             	pushl  -0x24(%ebp)
  8001cd:	ff 75 d8             	pushl  -0x28(%ebp)
  8001d0:	e8 ef 09 00 00       	call   800bc4 <__udivdi3>
  8001d5:	83 c4 18             	add    $0x18,%esp
  8001d8:	52                   	push   %edx
  8001d9:	50                   	push   %eax
  8001da:	89 f2                	mov    %esi,%edx
  8001dc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8001df:	e8 98 ff ff ff       	call   80017c <printnum>
  8001e4:	83 c4 20             	add    $0x20,%esp
  8001e7:	eb 10                	jmp    8001f9 <printnum+0x7d>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8001e9:	83 ec 08             	sub    $0x8,%esp
  8001ec:	56                   	push   %esi
  8001ed:	57                   	push   %edi
  8001ee:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8001f1:	4b                   	dec    %ebx
  8001f2:	83 c4 10             	add    $0x10,%esp
  8001f5:	85 db                	test   %ebx,%ebx
  8001f7:	7f f0                	jg     8001e9 <printnum+0x6d>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8001f9:	83 ec 08             	sub    $0x8,%esp
  8001fc:	56                   	push   %esi
  8001fd:	83 ec 04             	sub    $0x4,%esp
  800200:	ff 75 d4             	pushl  -0x2c(%ebp)
  800203:	ff 75 d0             	pushl  -0x30(%ebp)
  800206:	ff 75 dc             	pushl  -0x24(%ebp)
  800209:	ff 75 d8             	pushl  -0x28(%ebp)
  80020c:	e8 cf 0a 00 00       	call   800ce0 <__umoddi3>
  800211:	83 c4 14             	add    $0x14,%esp
  800214:	0f be 80 3c 0e 80 00 	movsbl 0x800e3c(%eax),%eax
  80021b:	50                   	push   %eax
  80021c:	ff 55 e4             	call   *-0x1c(%ebp)
  80021f:	83 c4 10             	add    $0x10,%esp
}
  800222:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800225:	5b                   	pop    %ebx
  800226:	5e                   	pop    %esi
  800227:	5f                   	pop    %edi
  800228:	c9                   	leave  
  800229:	c3                   	ret    

0080022a <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80022a:	55                   	push   %ebp
  80022b:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80022d:	83 fa 01             	cmp    $0x1,%edx
  800230:	7e 0e                	jle    800240 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800232:	8b 10                	mov    (%eax),%edx
  800234:	8d 4a 08             	lea    0x8(%edx),%ecx
  800237:	89 08                	mov    %ecx,(%eax)
  800239:	8b 02                	mov    (%edx),%eax
  80023b:	8b 52 04             	mov    0x4(%edx),%edx
  80023e:	eb 22                	jmp    800262 <getuint+0x38>
	else if (lflag)
  800240:	85 d2                	test   %edx,%edx
  800242:	74 10                	je     800254 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800244:	8b 10                	mov    (%eax),%edx
  800246:	8d 4a 04             	lea    0x4(%edx),%ecx
  800249:	89 08                	mov    %ecx,(%eax)
  80024b:	8b 02                	mov    (%edx),%eax
  80024d:	ba 00 00 00 00       	mov    $0x0,%edx
  800252:	eb 0e                	jmp    800262 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800254:	8b 10                	mov    (%eax),%edx
  800256:	8d 4a 04             	lea    0x4(%edx),%ecx
  800259:	89 08                	mov    %ecx,(%eax)
  80025b:	8b 02                	mov    (%edx),%eax
  80025d:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800262:	c9                   	leave  
  800263:	c3                   	ret    

00800264 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  800264:	55                   	push   %ebp
  800265:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800267:	83 fa 01             	cmp    $0x1,%edx
  80026a:	7e 0e                	jle    80027a <getint+0x16>
		return va_arg(*ap, long long);
  80026c:	8b 10                	mov    (%eax),%edx
  80026e:	8d 4a 08             	lea    0x8(%edx),%ecx
  800271:	89 08                	mov    %ecx,(%eax)
  800273:	8b 02                	mov    (%edx),%eax
  800275:	8b 52 04             	mov    0x4(%edx),%edx
  800278:	eb 1a                	jmp    800294 <getint+0x30>
	else if (lflag)
  80027a:	85 d2                	test   %edx,%edx
  80027c:	74 0c                	je     80028a <getint+0x26>
		return va_arg(*ap, long);
  80027e:	8b 10                	mov    (%eax),%edx
  800280:	8d 4a 04             	lea    0x4(%edx),%ecx
  800283:	89 08                	mov    %ecx,(%eax)
  800285:	8b 02                	mov    (%edx),%eax
  800287:	99                   	cltd   
  800288:	eb 0a                	jmp    800294 <getint+0x30>
	else
		return va_arg(*ap, int);
  80028a:	8b 10                	mov    (%eax),%edx
  80028c:	8d 4a 04             	lea    0x4(%edx),%ecx
  80028f:	89 08                	mov    %ecx,(%eax)
  800291:	8b 02                	mov    (%edx),%eax
  800293:	99                   	cltd   
}
  800294:	c9                   	leave  
  800295:	c3                   	ret    

00800296 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800296:	55                   	push   %ebp
  800297:	89 e5                	mov    %esp,%ebp
  800299:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80029c:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  80029f:	8b 10                	mov    (%eax),%edx
  8002a1:	3b 50 04             	cmp    0x4(%eax),%edx
  8002a4:	73 08                	jae    8002ae <sprintputch+0x18>
		*b->buf++ = ch;
  8002a6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8002a9:	88 0a                	mov    %cl,(%edx)
  8002ab:	42                   	inc    %edx
  8002ac:	89 10                	mov    %edx,(%eax)
}
  8002ae:	c9                   	leave  
  8002af:	c3                   	ret    

008002b0 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8002b0:	55                   	push   %ebp
  8002b1:	89 e5                	mov    %esp,%ebp
  8002b3:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8002b6:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002b9:	50                   	push   %eax
  8002ba:	ff 75 10             	pushl  0x10(%ebp)
  8002bd:	ff 75 0c             	pushl  0xc(%ebp)
  8002c0:	ff 75 08             	pushl  0x8(%ebp)
  8002c3:	e8 05 00 00 00       	call   8002cd <vprintfmt>
	va_end(ap);
  8002c8:	83 c4 10             	add    $0x10,%esp
}
  8002cb:	c9                   	leave  
  8002cc:	c3                   	ret    

008002cd <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8002cd:	55                   	push   %ebp
  8002ce:	89 e5                	mov    %esp,%ebp
  8002d0:	57                   	push   %edi
  8002d1:	56                   	push   %esi
  8002d2:	53                   	push   %ebx
  8002d3:	83 ec 2c             	sub    $0x2c,%esp
  8002d6:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8002d9:	8b 75 10             	mov    0x10(%ebp),%esi
  8002dc:	eb 13                	jmp    8002f1 <vprintfmt+0x24>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8002de:	85 c0                	test   %eax,%eax
  8002e0:	0f 84 6d 03 00 00    	je     800653 <vprintfmt+0x386>
				return;
			putch(ch, putdat);
  8002e6:	83 ec 08             	sub    $0x8,%esp
  8002e9:	57                   	push   %edi
  8002ea:	50                   	push   %eax
  8002eb:	ff 55 08             	call   *0x8(%ebp)
  8002ee:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8002f1:	0f b6 06             	movzbl (%esi),%eax
  8002f4:	46                   	inc    %esi
  8002f5:	83 f8 25             	cmp    $0x25,%eax
  8002f8:	75 e4                	jne    8002de <vprintfmt+0x11>
  8002fa:	c6 45 dc 20          	movb   $0x20,-0x24(%ebp)
  8002fe:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  800305:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  80030c:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800313:	b9 00 00 00 00       	mov    $0x0,%ecx
  800318:	eb 28                	jmp    800342 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80031a:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  80031c:	c6 45 dc 2d          	movb   $0x2d,-0x24(%ebp)
  800320:	eb 20                	jmp    800342 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800322:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800324:	c6 45 dc 30          	movb   $0x30,-0x24(%ebp)
  800328:	eb 18                	jmp    800342 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80032a:	89 de                	mov    %ebx,%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  80032c:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800333:	eb 0d                	jmp    800342 <vprintfmt+0x75>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800335:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800338:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80033b:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800342:	8a 06                	mov    (%esi),%al
  800344:	0f b6 d0             	movzbl %al,%edx
  800347:	8d 5e 01             	lea    0x1(%esi),%ebx
  80034a:	83 e8 23             	sub    $0x23,%eax
  80034d:	3c 55                	cmp    $0x55,%al
  80034f:	0f 87 e0 02 00 00    	ja     800635 <vprintfmt+0x368>
  800355:	0f b6 c0             	movzbl %al,%eax
  800358:	ff 24 85 cc 0e 80 00 	jmp    *0x800ecc(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80035f:	83 ea 30             	sub    $0x30,%edx
  800362:	89 55 d4             	mov    %edx,-0x2c(%ebp)
				ch = *fmt;
  800365:	0f be 03             	movsbl (%ebx),%eax
				if (ch < '0' || ch > '9')
  800368:	8d 50 d0             	lea    -0x30(%eax),%edx
  80036b:	83 fa 09             	cmp    $0x9,%edx
  80036e:	77 44                	ja     8003b4 <vprintfmt+0xe7>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800370:	89 de                	mov    %ebx,%esi
  800372:	8b 55 d4             	mov    -0x2c(%ebp),%edx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800375:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
  800376:	8d 14 92             	lea    (%edx,%edx,4),%edx
  800379:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
  80037d:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800380:	8d 58 d0             	lea    -0x30(%eax),%ebx
  800383:	83 fb 09             	cmp    $0x9,%ebx
  800386:	76 ed                	jbe    800375 <vprintfmt+0xa8>
  800388:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  80038b:	eb 29                	jmp    8003b6 <vprintfmt+0xe9>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80038d:	8b 45 14             	mov    0x14(%ebp),%eax
  800390:	8d 50 04             	lea    0x4(%eax),%edx
  800393:	89 55 14             	mov    %edx,0x14(%ebp)
  800396:	8b 00                	mov    (%eax),%eax
  800398:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80039b:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80039d:	eb 17                	jmp    8003b6 <vprintfmt+0xe9>

		case '.':
			if (width < 0)
  80039f:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8003a3:	78 85                	js     80032a <vprintfmt+0x5d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003a5:	89 de                	mov    %ebx,%esi
  8003a7:	eb 99                	jmp    800342 <vprintfmt+0x75>
  8003a9:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8003ab:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  8003b2:	eb 8e                	jmp    800342 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003b4:	89 de                	mov    %ebx,%esi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  8003b6:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8003ba:	79 86                	jns    800342 <vprintfmt+0x75>
  8003bc:	e9 74 ff ff ff       	jmp    800335 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8003c1:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003c2:	89 de                	mov    %ebx,%esi
  8003c4:	e9 79 ff ff ff       	jmp    800342 <vprintfmt+0x75>
  8003c9:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8003cc:	8b 45 14             	mov    0x14(%ebp),%eax
  8003cf:	8d 50 04             	lea    0x4(%eax),%edx
  8003d2:	89 55 14             	mov    %edx,0x14(%ebp)
  8003d5:	83 ec 08             	sub    $0x8,%esp
  8003d8:	57                   	push   %edi
  8003d9:	ff 30                	pushl  (%eax)
  8003db:	ff 55 08             	call   *0x8(%ebp)
			break;
  8003de:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003e1:	8b 75 d8             	mov    -0x28(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8003e4:	e9 08 ff ff ff       	jmp    8002f1 <vprintfmt+0x24>
  8003e9:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  8003ec:	8b 45 14             	mov    0x14(%ebp),%eax
  8003ef:	8d 50 04             	lea    0x4(%eax),%edx
  8003f2:	89 55 14             	mov    %edx,0x14(%ebp)
  8003f5:	8b 00                	mov    (%eax),%eax
  8003f7:	85 c0                	test   %eax,%eax
  8003f9:	79 02                	jns    8003fd <vprintfmt+0x130>
  8003fb:	f7 d8                	neg    %eax
  8003fd:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003ff:	83 f8 06             	cmp    $0x6,%eax
  800402:	7f 0b                	jg     80040f <vprintfmt+0x142>
  800404:	8b 04 85 24 10 80 00 	mov    0x801024(,%eax,4),%eax
  80040b:	85 c0                	test   %eax,%eax
  80040d:	75 1a                	jne    800429 <vprintfmt+0x15c>
				printfmt(putch, putdat, "error %d", err);
  80040f:	52                   	push   %edx
  800410:	68 54 0e 80 00       	push   $0x800e54
  800415:	57                   	push   %edi
  800416:	ff 75 08             	pushl  0x8(%ebp)
  800419:	e8 92 fe ff ff       	call   8002b0 <printfmt>
  80041e:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800421:	8b 75 d8             	mov    -0x28(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800424:	e9 c8 fe ff ff       	jmp    8002f1 <vprintfmt+0x24>
			else
				printfmt(putch, putdat, "%s", p);
  800429:	50                   	push   %eax
  80042a:	68 5d 0e 80 00       	push   $0x800e5d
  80042f:	57                   	push   %edi
  800430:	ff 75 08             	pushl  0x8(%ebp)
  800433:	e8 78 fe ff ff       	call   8002b0 <printfmt>
  800438:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80043b:	8b 75 d8             	mov    -0x28(%ebp),%esi
  80043e:	e9 ae fe ff ff       	jmp    8002f1 <vprintfmt+0x24>
  800443:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  800446:	89 de                	mov    %ebx,%esi
  800448:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  80044b:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80044e:	8b 45 14             	mov    0x14(%ebp),%eax
  800451:	8d 50 04             	lea    0x4(%eax),%edx
  800454:	89 55 14             	mov    %edx,0x14(%ebp)
  800457:	8b 00                	mov    (%eax),%eax
  800459:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80045c:	85 c0                	test   %eax,%eax
  80045e:	75 07                	jne    800467 <vprintfmt+0x19a>
				p = "(null)";
  800460:	c7 45 d0 4d 0e 80 00 	movl   $0x800e4d,-0x30(%ebp)
			if (width > 0 && padc != '-')
  800467:	85 db                	test   %ebx,%ebx
  800469:	7e 42                	jle    8004ad <vprintfmt+0x1e0>
  80046b:	80 7d dc 2d          	cmpb   $0x2d,-0x24(%ebp)
  80046f:	74 3c                	je     8004ad <vprintfmt+0x1e0>
				for (width -= strnlen(p, precision); width > 0; width--)
  800471:	83 ec 08             	sub    $0x8,%esp
  800474:	51                   	push   %ecx
  800475:	ff 75 d0             	pushl  -0x30(%ebp)
  800478:	e8 6f 02 00 00       	call   8006ec <strnlen>
  80047d:	29 c3                	sub    %eax,%ebx
  80047f:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800482:	83 c4 10             	add    $0x10,%esp
  800485:	85 db                	test   %ebx,%ebx
  800487:	7e 24                	jle    8004ad <vprintfmt+0x1e0>
					putch(padc, putdat);
  800489:	0f be 5d dc          	movsbl -0x24(%ebp),%ebx
  80048d:	89 75 dc             	mov    %esi,-0x24(%ebp)
  800490:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  800493:	83 ec 08             	sub    $0x8,%esp
  800496:	57                   	push   %edi
  800497:	53                   	push   %ebx
  800498:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80049b:	4e                   	dec    %esi
  80049c:	83 c4 10             	add    $0x10,%esp
  80049f:	85 f6                	test   %esi,%esi
  8004a1:	7f f0                	jg     800493 <vprintfmt+0x1c6>
  8004a3:	8b 75 dc             	mov    -0x24(%ebp),%esi
  8004a6:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004ad:	8b 55 d0             	mov    -0x30(%ebp),%edx
  8004b0:	0f be 02             	movsbl (%edx),%eax
  8004b3:	85 c0                	test   %eax,%eax
  8004b5:	75 47                	jne    8004fe <vprintfmt+0x231>
  8004b7:	eb 37                	jmp    8004f0 <vprintfmt+0x223>
				if (altflag && (ch < ' ' || ch > '~'))
  8004b9:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004bd:	74 16                	je     8004d5 <vprintfmt+0x208>
  8004bf:	8d 50 e0             	lea    -0x20(%eax),%edx
  8004c2:	83 fa 5e             	cmp    $0x5e,%edx
  8004c5:	76 0e                	jbe    8004d5 <vprintfmt+0x208>
					putch('?', putdat);
  8004c7:	83 ec 08             	sub    $0x8,%esp
  8004ca:	57                   	push   %edi
  8004cb:	6a 3f                	push   $0x3f
  8004cd:	ff 55 08             	call   *0x8(%ebp)
  8004d0:	83 c4 10             	add    $0x10,%esp
  8004d3:	eb 0b                	jmp    8004e0 <vprintfmt+0x213>
				else
					putch(ch, putdat);
  8004d5:	83 ec 08             	sub    $0x8,%esp
  8004d8:	57                   	push   %edi
  8004d9:	50                   	push   %eax
  8004da:	ff 55 08             	call   *0x8(%ebp)
  8004dd:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004e0:	ff 4d e4             	decl   -0x1c(%ebp)
  8004e3:	0f be 03             	movsbl (%ebx),%eax
  8004e6:	85 c0                	test   %eax,%eax
  8004e8:	74 03                	je     8004ed <vprintfmt+0x220>
  8004ea:	43                   	inc    %ebx
  8004eb:	eb 1b                	jmp    800508 <vprintfmt+0x23b>
  8004ed:	8b 75 dc             	mov    -0x24(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8004f0:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8004f4:	7f 1e                	jg     800514 <vprintfmt+0x247>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004f6:	8b 75 d8             	mov    -0x28(%ebp),%esi
  8004f9:	e9 f3 fd ff ff       	jmp    8002f1 <vprintfmt+0x24>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004fe:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800501:	43                   	inc    %ebx
  800502:	89 75 dc             	mov    %esi,-0x24(%ebp)
  800505:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  800508:	85 f6                	test   %esi,%esi
  80050a:	78 ad                	js     8004b9 <vprintfmt+0x1ec>
  80050c:	4e                   	dec    %esi
  80050d:	79 aa                	jns    8004b9 <vprintfmt+0x1ec>
  80050f:	8b 75 dc             	mov    -0x24(%ebp),%esi
  800512:	eb dc                	jmp    8004f0 <vprintfmt+0x223>
  800514:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800517:	83 ec 08             	sub    $0x8,%esp
  80051a:	57                   	push   %edi
  80051b:	6a 20                	push   $0x20
  80051d:	ff 55 08             	call   *0x8(%ebp)
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800520:	4b                   	dec    %ebx
  800521:	83 c4 10             	add    $0x10,%esp
  800524:	85 db                	test   %ebx,%ebx
  800526:	7f ef                	jg     800517 <vprintfmt+0x24a>
  800528:	e9 c4 fd ff ff       	jmp    8002f1 <vprintfmt+0x24>
  80052d:	89 5d d8             	mov    %ebx,-0x28(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800530:	89 ca                	mov    %ecx,%edx
  800532:	8d 45 14             	lea    0x14(%ebp),%eax
  800535:	e8 2a fd ff ff       	call   800264 <getint>
  80053a:	89 c3                	mov    %eax,%ebx
  80053c:	89 d6                	mov    %edx,%esi
			if ((long long) num < 0) {
  80053e:	85 d2                	test   %edx,%edx
  800540:	78 0a                	js     80054c <vprintfmt+0x27f>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800542:	b8 0a 00 00 00       	mov    $0xa,%eax
  800547:	e9 b0 00 00 00       	jmp    8005fc <vprintfmt+0x32f>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  80054c:	83 ec 08             	sub    $0x8,%esp
  80054f:	57                   	push   %edi
  800550:	6a 2d                	push   $0x2d
  800552:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800555:	f7 db                	neg    %ebx
  800557:	83 d6 00             	adc    $0x0,%esi
  80055a:	f7 de                	neg    %esi
  80055c:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  80055f:	b8 0a 00 00 00       	mov    $0xa,%eax
  800564:	e9 93 00 00 00       	jmp    8005fc <vprintfmt+0x32f>
  800569:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80056c:	89 ca                	mov    %ecx,%edx
  80056e:	8d 45 14             	lea    0x14(%ebp),%eax
  800571:	e8 b4 fc ff ff       	call   80022a <getuint>
  800576:	89 c3                	mov    %eax,%ebx
  800578:	89 d6                	mov    %edx,%esi
			base = 10;
  80057a:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  80057f:	eb 7b                	jmp    8005fc <vprintfmt+0x32f>
  800581:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
  800584:	89 ca                	mov    %ecx,%edx
  800586:	8d 45 14             	lea    0x14(%ebp),%eax
  800589:	e8 d6 fc ff ff       	call   800264 <getint>
  80058e:	89 c3                	mov    %eax,%ebx
  800590:	89 d6                	mov    %edx,%esi
            if ((long long) num < 0) {
  800592:	85 d2                	test   %edx,%edx
  800594:	78 07                	js     80059d <vprintfmt+0x2d0>
                putch('-', putdat);
                num = -(long long) num;
            }
            base = 8;
  800596:	b8 08 00 00 00       	mov    $0x8,%eax
  80059b:	eb 5f                	jmp    8005fc <vprintfmt+0x32f>
		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
            if ((long long) num < 0) {
                putch('-', putdat);
  80059d:	83 ec 08             	sub    $0x8,%esp
  8005a0:	57                   	push   %edi
  8005a1:	6a 2d                	push   $0x2d
  8005a3:	ff 55 08             	call   *0x8(%ebp)
                num = -(long long) num;
  8005a6:	f7 db                	neg    %ebx
  8005a8:	83 d6 00             	adc    $0x0,%esi
  8005ab:	f7 de                	neg    %esi
  8005ad:	83 c4 10             	add    $0x10,%esp
            }
            base = 8;
  8005b0:	b8 08 00 00 00       	mov    $0x8,%eax
  8005b5:	eb 45                	jmp    8005fc <vprintfmt+0x32f>
  8005b7:	89 5d d8             	mov    %ebx,-0x28(%ebp)
            goto number;

        // pointer
		case 'p':
			putch('0', putdat);
  8005ba:	83 ec 08             	sub    $0x8,%esp
  8005bd:	57                   	push   %edi
  8005be:	6a 30                	push   $0x30
  8005c0:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8005c3:	83 c4 08             	add    $0x8,%esp
  8005c6:	57                   	push   %edi
  8005c7:	6a 78                	push   $0x78
  8005c9:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8005cc:	8b 45 14             	mov    0x14(%ebp),%eax
  8005cf:	8d 50 04             	lea    0x4(%eax),%edx
  8005d2:	89 55 14             	mov    %edx,0x14(%ebp)

        // pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8005d5:	8b 18                	mov    (%eax),%ebx
  8005d7:	be 00 00 00 00       	mov    $0x0,%esi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8005dc:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8005df:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8005e4:	eb 16                	jmp    8005fc <vprintfmt+0x32f>
  8005e6:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8005e9:	89 ca                	mov    %ecx,%edx
  8005eb:	8d 45 14             	lea    0x14(%ebp),%eax
  8005ee:	e8 37 fc ff ff       	call   80022a <getuint>
  8005f3:	89 c3                	mov    %eax,%ebx
  8005f5:	89 d6                	mov    %edx,%esi
			base = 16;
  8005f7:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  8005fc:	83 ec 0c             	sub    $0xc,%esp
  8005ff:	0f be 55 dc          	movsbl -0x24(%ebp),%edx
  800603:	52                   	push   %edx
  800604:	ff 75 e4             	pushl  -0x1c(%ebp)
  800607:	50                   	push   %eax
  800608:	56                   	push   %esi
  800609:	53                   	push   %ebx
  80060a:	89 fa                	mov    %edi,%edx
  80060c:	8b 45 08             	mov    0x8(%ebp),%eax
  80060f:	e8 68 fb ff ff       	call   80017c <printnum>
			break;
  800614:	83 c4 20             	add    $0x20,%esp
  800617:	8b 75 d8             	mov    -0x28(%ebp),%esi
  80061a:	e9 d2 fc ff ff       	jmp    8002f1 <vprintfmt+0x24>
  80061f:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800622:	83 ec 08             	sub    $0x8,%esp
  800625:	57                   	push   %edi
  800626:	52                   	push   %edx
  800627:	ff 55 08             	call   *0x8(%ebp)
			break;
  80062a:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80062d:	8b 75 d8             	mov    -0x28(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800630:	e9 bc fc ff ff       	jmp    8002f1 <vprintfmt+0x24>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800635:	83 ec 08             	sub    $0x8,%esp
  800638:	57                   	push   %edi
  800639:	6a 25                	push   $0x25
  80063b:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  80063e:	83 c4 10             	add    $0x10,%esp
  800641:	eb 02                	jmp    800645 <vprintfmt+0x378>
  800643:	89 c6                	mov    %eax,%esi
  800645:	8d 46 ff             	lea    -0x1(%esi),%eax
  800648:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  80064c:	75 f5                	jne    800643 <vprintfmt+0x376>
  80064e:	e9 9e fc ff ff       	jmp    8002f1 <vprintfmt+0x24>
				/* do nothing */;
			break;
		}
	}
}
  800653:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800656:	5b                   	pop    %ebx
  800657:	5e                   	pop    %esi
  800658:	5f                   	pop    %edi
  800659:	c9                   	leave  
  80065a:	c3                   	ret    

0080065b <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80065b:	55                   	push   %ebp
  80065c:	89 e5                	mov    %esp,%ebp
  80065e:	83 ec 18             	sub    $0x18,%esp
  800661:	8b 45 08             	mov    0x8(%ebp),%eax
  800664:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800667:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80066a:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80066e:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800671:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800678:	85 c0                	test   %eax,%eax
  80067a:	74 26                	je     8006a2 <vsnprintf+0x47>
  80067c:	85 d2                	test   %edx,%edx
  80067e:	7e 29                	jle    8006a9 <vsnprintf+0x4e>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800680:	ff 75 14             	pushl  0x14(%ebp)
  800683:	ff 75 10             	pushl  0x10(%ebp)
  800686:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800689:	50                   	push   %eax
  80068a:	68 96 02 80 00       	push   $0x800296
  80068f:	e8 39 fc ff ff       	call   8002cd <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800694:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800697:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80069a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80069d:	83 c4 10             	add    $0x10,%esp
  8006a0:	eb 0c                	jmp    8006ae <vsnprintf+0x53>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8006a2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8006a7:	eb 05                	jmp    8006ae <vsnprintf+0x53>
  8006a9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8006ae:	c9                   	leave  
  8006af:	c3                   	ret    

008006b0 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8006b0:	55                   	push   %ebp
  8006b1:	89 e5                	mov    %esp,%ebp
  8006b3:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8006b6:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8006b9:	50                   	push   %eax
  8006ba:	ff 75 10             	pushl  0x10(%ebp)
  8006bd:	ff 75 0c             	pushl  0xc(%ebp)
  8006c0:	ff 75 08             	pushl  0x8(%ebp)
  8006c3:	e8 93 ff ff ff       	call   80065b <vsnprintf>
	va_end(ap);

	return rc;
}
  8006c8:	c9                   	leave  
  8006c9:	c3                   	ret    
	...

008006cc <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8006cc:	55                   	push   %ebp
  8006cd:	89 e5                	mov    %esp,%ebp
  8006cf:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8006d2:	80 3a 00             	cmpb   $0x0,(%edx)
  8006d5:	74 0e                	je     8006e5 <strlen+0x19>
  8006d7:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  8006dc:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8006dd:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8006e1:	75 f9                	jne    8006dc <strlen+0x10>
  8006e3:	eb 05                	jmp    8006ea <strlen+0x1e>
  8006e5:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  8006ea:	c9                   	leave  
  8006eb:	c3                   	ret    

008006ec <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8006ec:	55                   	push   %ebp
  8006ed:	89 e5                	mov    %esp,%ebp
  8006ef:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8006f2:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8006f5:	85 d2                	test   %edx,%edx
  8006f7:	74 17                	je     800710 <strnlen+0x24>
  8006f9:	80 39 00             	cmpb   $0x0,(%ecx)
  8006fc:	74 19                	je     800717 <strnlen+0x2b>
  8006fe:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800703:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800704:	39 d0                	cmp    %edx,%eax
  800706:	74 14                	je     80071c <strnlen+0x30>
  800708:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  80070c:	75 f5                	jne    800703 <strnlen+0x17>
  80070e:	eb 0c                	jmp    80071c <strnlen+0x30>
  800710:	b8 00 00 00 00       	mov    $0x0,%eax
  800715:	eb 05                	jmp    80071c <strnlen+0x30>
  800717:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  80071c:	c9                   	leave  
  80071d:	c3                   	ret    

0080071e <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80071e:	55                   	push   %ebp
  80071f:	89 e5                	mov    %esp,%ebp
  800721:	53                   	push   %ebx
  800722:	8b 45 08             	mov    0x8(%ebp),%eax
  800725:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800728:	ba 00 00 00 00       	mov    $0x0,%edx
  80072d:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  800730:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800733:	42                   	inc    %edx
  800734:	84 c9                	test   %cl,%cl
  800736:	75 f5                	jne    80072d <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800738:	5b                   	pop    %ebx
  800739:	c9                   	leave  
  80073a:	c3                   	ret    

0080073b <strcat>:

char *
strcat(char *dst, const char *src)
{
  80073b:	55                   	push   %ebp
  80073c:	89 e5                	mov    %esp,%ebp
  80073e:	53                   	push   %ebx
  80073f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800742:	53                   	push   %ebx
  800743:	e8 84 ff ff ff       	call   8006cc <strlen>
  800748:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  80074b:	ff 75 0c             	pushl  0xc(%ebp)
  80074e:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  800751:	50                   	push   %eax
  800752:	e8 c7 ff ff ff       	call   80071e <strcpy>
	return dst;
}
  800757:	89 d8                	mov    %ebx,%eax
  800759:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80075c:	c9                   	leave  
  80075d:	c3                   	ret    

0080075e <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80075e:	55                   	push   %ebp
  80075f:	89 e5                	mov    %esp,%ebp
  800761:	56                   	push   %esi
  800762:	53                   	push   %ebx
  800763:	8b 45 08             	mov    0x8(%ebp),%eax
  800766:	8b 55 0c             	mov    0xc(%ebp),%edx
  800769:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80076c:	85 f6                	test   %esi,%esi
  80076e:	74 15                	je     800785 <strncpy+0x27>
  800770:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  800775:	8a 1a                	mov    (%edx),%bl
  800777:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80077a:	80 3a 01             	cmpb   $0x1,(%edx)
  80077d:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800780:	41                   	inc    %ecx
  800781:	39 ce                	cmp    %ecx,%esi
  800783:	77 f0                	ja     800775 <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800785:	5b                   	pop    %ebx
  800786:	5e                   	pop    %esi
  800787:	c9                   	leave  
  800788:	c3                   	ret    

00800789 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800789:	55                   	push   %ebp
  80078a:	89 e5                	mov    %esp,%ebp
  80078c:	57                   	push   %edi
  80078d:	56                   	push   %esi
  80078e:	53                   	push   %ebx
  80078f:	8b 7d 08             	mov    0x8(%ebp),%edi
  800792:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800795:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800798:	85 f6                	test   %esi,%esi
  80079a:	74 32                	je     8007ce <strlcpy+0x45>
		while (--size > 0 && *src != '\0')
  80079c:	83 fe 01             	cmp    $0x1,%esi
  80079f:	74 22                	je     8007c3 <strlcpy+0x3a>
  8007a1:	8a 0b                	mov    (%ebx),%cl
  8007a3:	84 c9                	test   %cl,%cl
  8007a5:	74 20                	je     8007c7 <strlcpy+0x3e>
  8007a7:	89 f8                	mov    %edi,%eax
  8007a9:	ba 00 00 00 00       	mov    $0x0,%edx
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
  8007ae:	83 ee 02             	sub    $0x2,%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8007b1:	88 08                	mov    %cl,(%eax)
  8007b3:	40                   	inc    %eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8007b4:	39 f2                	cmp    %esi,%edx
  8007b6:	74 11                	je     8007c9 <strlcpy+0x40>
  8007b8:	8a 4c 13 01          	mov    0x1(%ebx,%edx,1),%cl
  8007bc:	42                   	inc    %edx
  8007bd:	84 c9                	test   %cl,%cl
  8007bf:	75 f0                	jne    8007b1 <strlcpy+0x28>
  8007c1:	eb 06                	jmp    8007c9 <strlcpy+0x40>
  8007c3:	89 f8                	mov    %edi,%eax
  8007c5:	eb 02                	jmp    8007c9 <strlcpy+0x40>
  8007c7:	89 f8                	mov    %edi,%eax
			*dst++ = *src++;
		*dst = '\0';
  8007c9:	c6 00 00             	movb   $0x0,(%eax)
  8007cc:	eb 02                	jmp    8007d0 <strlcpy+0x47>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007ce:	89 f8                	mov    %edi,%eax
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
		*dst = '\0';
	}
	return dst - dst_in;
  8007d0:	29 f8                	sub    %edi,%eax
}
  8007d2:	5b                   	pop    %ebx
  8007d3:	5e                   	pop    %esi
  8007d4:	5f                   	pop    %edi
  8007d5:	c9                   	leave  
  8007d6:	c3                   	ret    

008007d7 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8007d7:	55                   	push   %ebp
  8007d8:	89 e5                	mov    %esp,%ebp
  8007da:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007dd:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8007e0:	8a 01                	mov    (%ecx),%al
  8007e2:	84 c0                	test   %al,%al
  8007e4:	74 10                	je     8007f6 <strcmp+0x1f>
  8007e6:	3a 02                	cmp    (%edx),%al
  8007e8:	75 0c                	jne    8007f6 <strcmp+0x1f>
		p++, q++;
  8007ea:	41                   	inc    %ecx
  8007eb:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8007ec:	8a 01                	mov    (%ecx),%al
  8007ee:	84 c0                	test   %al,%al
  8007f0:	74 04                	je     8007f6 <strcmp+0x1f>
  8007f2:	3a 02                	cmp    (%edx),%al
  8007f4:	74 f4                	je     8007ea <strcmp+0x13>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8007f6:	0f b6 c0             	movzbl %al,%eax
  8007f9:	0f b6 12             	movzbl (%edx),%edx
  8007fc:	29 d0                	sub    %edx,%eax
}
  8007fe:	c9                   	leave  
  8007ff:	c3                   	ret    

00800800 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800800:	55                   	push   %ebp
  800801:	89 e5                	mov    %esp,%ebp
  800803:	53                   	push   %ebx
  800804:	8b 55 08             	mov    0x8(%ebp),%edx
  800807:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80080a:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  80080d:	85 c0                	test   %eax,%eax
  80080f:	74 1b                	je     80082c <strncmp+0x2c>
  800811:	8a 1a                	mov    (%edx),%bl
  800813:	84 db                	test   %bl,%bl
  800815:	74 24                	je     80083b <strncmp+0x3b>
  800817:	3a 19                	cmp    (%ecx),%bl
  800819:	75 20                	jne    80083b <strncmp+0x3b>
  80081b:	48                   	dec    %eax
  80081c:	74 15                	je     800833 <strncmp+0x33>
		n--, p++, q++;
  80081e:	42                   	inc    %edx
  80081f:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800820:	8a 1a                	mov    (%edx),%bl
  800822:	84 db                	test   %bl,%bl
  800824:	74 15                	je     80083b <strncmp+0x3b>
  800826:	3a 19                	cmp    (%ecx),%bl
  800828:	74 f1                	je     80081b <strncmp+0x1b>
  80082a:	eb 0f                	jmp    80083b <strncmp+0x3b>
		n--, p++, q++;
	if (n == 0)
		return 0;
  80082c:	b8 00 00 00 00       	mov    $0x0,%eax
  800831:	eb 05                	jmp    800838 <strncmp+0x38>
  800833:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800838:	5b                   	pop    %ebx
  800839:	c9                   	leave  
  80083a:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80083b:	0f b6 02             	movzbl (%edx),%eax
  80083e:	0f b6 11             	movzbl (%ecx),%edx
  800841:	29 d0                	sub    %edx,%eax
  800843:	eb f3                	jmp    800838 <strncmp+0x38>

00800845 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800845:	55                   	push   %ebp
  800846:	89 e5                	mov    %esp,%ebp
  800848:	8b 45 08             	mov    0x8(%ebp),%eax
  80084b:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  80084e:	8a 10                	mov    (%eax),%dl
  800850:	84 d2                	test   %dl,%dl
  800852:	74 18                	je     80086c <strchr+0x27>
		if (*s == c)
  800854:	38 ca                	cmp    %cl,%dl
  800856:	75 06                	jne    80085e <strchr+0x19>
  800858:	eb 17                	jmp    800871 <strchr+0x2c>
  80085a:	38 ca                	cmp    %cl,%dl
  80085c:	74 13                	je     800871 <strchr+0x2c>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80085e:	40                   	inc    %eax
  80085f:	8a 10                	mov    (%eax),%dl
  800861:	84 d2                	test   %dl,%dl
  800863:	75 f5                	jne    80085a <strchr+0x15>
		if (*s == c)
			return (char *) s;
	return 0;
  800865:	b8 00 00 00 00       	mov    $0x0,%eax
  80086a:	eb 05                	jmp    800871 <strchr+0x2c>
  80086c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800871:	c9                   	leave  
  800872:	c3                   	ret    

00800873 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800873:	55                   	push   %ebp
  800874:	89 e5                	mov    %esp,%ebp
  800876:	8b 45 08             	mov    0x8(%ebp),%eax
  800879:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  80087c:	8a 10                	mov    (%eax),%dl
  80087e:	84 d2                	test   %dl,%dl
  800880:	74 11                	je     800893 <strfind+0x20>
		if (*s == c)
  800882:	38 ca                	cmp    %cl,%dl
  800884:	75 06                	jne    80088c <strfind+0x19>
  800886:	eb 0b                	jmp    800893 <strfind+0x20>
  800888:	38 ca                	cmp    %cl,%dl
  80088a:	74 07                	je     800893 <strfind+0x20>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  80088c:	40                   	inc    %eax
  80088d:	8a 10                	mov    (%eax),%dl
  80088f:	84 d2                	test   %dl,%dl
  800891:	75 f5                	jne    800888 <strfind+0x15>
		if (*s == c)
			break;
	return (char *) s;
}
  800893:	c9                   	leave  
  800894:	c3                   	ret    

00800895 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800895:	55                   	push   %ebp
  800896:	89 e5                	mov    %esp,%ebp
  800898:	57                   	push   %edi
  800899:	56                   	push   %esi
  80089a:	53                   	push   %ebx
  80089b:	8b 7d 08             	mov    0x8(%ebp),%edi
  80089e:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008a1:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8008a4:	85 c9                	test   %ecx,%ecx
  8008a6:	74 30                	je     8008d8 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008a8:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008ae:	75 25                	jne    8008d5 <memset+0x40>
  8008b0:	f6 c1 03             	test   $0x3,%cl
  8008b3:	75 20                	jne    8008d5 <memset+0x40>
		c &= 0xFF;
  8008b5:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8008b8:	89 d3                	mov    %edx,%ebx
  8008ba:	c1 e3 08             	shl    $0x8,%ebx
  8008bd:	89 d6                	mov    %edx,%esi
  8008bf:	c1 e6 18             	shl    $0x18,%esi
  8008c2:	89 d0                	mov    %edx,%eax
  8008c4:	c1 e0 10             	shl    $0x10,%eax
  8008c7:	09 f0                	or     %esi,%eax
  8008c9:	09 d0                	or     %edx,%eax
  8008cb:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  8008cd:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  8008d0:	fc                   	cld    
  8008d1:	f3 ab                	rep stos %eax,%es:(%edi)
  8008d3:	eb 03                	jmp    8008d8 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8008d5:	fc                   	cld    
  8008d6:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8008d8:	89 f8                	mov    %edi,%eax
  8008da:	5b                   	pop    %ebx
  8008db:	5e                   	pop    %esi
  8008dc:	5f                   	pop    %edi
  8008dd:	c9                   	leave  
  8008de:	c3                   	ret    

008008df <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8008df:	55                   	push   %ebp
  8008e0:	89 e5                	mov    %esp,%ebp
  8008e2:	57                   	push   %edi
  8008e3:	56                   	push   %esi
  8008e4:	8b 45 08             	mov    0x8(%ebp),%eax
  8008e7:	8b 75 0c             	mov    0xc(%ebp),%esi
  8008ea:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8008ed:	39 c6                	cmp    %eax,%esi
  8008ef:	73 34                	jae    800925 <memmove+0x46>
  8008f1:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8008f4:	39 d0                	cmp    %edx,%eax
  8008f6:	73 2d                	jae    800925 <memmove+0x46>
		s += n;
		d += n;
  8008f8:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008fb:	f6 c2 03             	test   $0x3,%dl
  8008fe:	75 1b                	jne    80091b <memmove+0x3c>
  800900:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800906:	75 13                	jne    80091b <memmove+0x3c>
  800908:	f6 c1 03             	test   $0x3,%cl
  80090b:	75 0e                	jne    80091b <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  80090d:	83 ef 04             	sub    $0x4,%edi
  800910:	8d 72 fc             	lea    -0x4(%edx),%esi
  800913:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800916:	fd                   	std    
  800917:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800919:	eb 07                	jmp    800922 <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  80091b:	4f                   	dec    %edi
  80091c:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  80091f:	fd                   	std    
  800920:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800922:	fc                   	cld    
  800923:	eb 20                	jmp    800945 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800925:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80092b:	75 13                	jne    800940 <memmove+0x61>
  80092d:	a8 03                	test   $0x3,%al
  80092f:	75 0f                	jne    800940 <memmove+0x61>
  800931:	f6 c1 03             	test   $0x3,%cl
  800934:	75 0a                	jne    800940 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800936:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800939:	89 c7                	mov    %eax,%edi
  80093b:	fc                   	cld    
  80093c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80093e:	eb 05                	jmp    800945 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800940:	89 c7                	mov    %eax,%edi
  800942:	fc                   	cld    
  800943:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800945:	5e                   	pop    %esi
  800946:	5f                   	pop    %edi
  800947:	c9                   	leave  
  800948:	c3                   	ret    

00800949 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800949:	55                   	push   %ebp
  80094a:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  80094c:	ff 75 10             	pushl  0x10(%ebp)
  80094f:	ff 75 0c             	pushl  0xc(%ebp)
  800952:	ff 75 08             	pushl  0x8(%ebp)
  800955:	e8 85 ff ff ff       	call   8008df <memmove>
}
  80095a:	c9                   	leave  
  80095b:	c3                   	ret    

0080095c <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  80095c:	55                   	push   %ebp
  80095d:	89 e5                	mov    %esp,%ebp
  80095f:	57                   	push   %edi
  800960:	56                   	push   %esi
  800961:	53                   	push   %ebx
  800962:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800965:	8b 75 0c             	mov    0xc(%ebp),%esi
  800968:	8b 7d 10             	mov    0x10(%ebp),%edi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80096b:	85 ff                	test   %edi,%edi
  80096d:	74 32                	je     8009a1 <memcmp+0x45>
		if (*s1 != *s2)
  80096f:	8a 03                	mov    (%ebx),%al
  800971:	8a 0e                	mov    (%esi),%cl
  800973:	38 c8                	cmp    %cl,%al
  800975:	74 19                	je     800990 <memcmp+0x34>
  800977:	eb 0d                	jmp    800986 <memcmp+0x2a>
  800979:	8a 44 13 01          	mov    0x1(%ebx,%edx,1),%al
  80097d:	8a 4c 16 01          	mov    0x1(%esi,%edx,1),%cl
  800981:	42                   	inc    %edx
  800982:	38 c8                	cmp    %cl,%al
  800984:	74 10                	je     800996 <memcmp+0x3a>
			return (int) *s1 - (int) *s2;
  800986:	0f b6 c0             	movzbl %al,%eax
  800989:	0f b6 c9             	movzbl %cl,%ecx
  80098c:	29 c8                	sub    %ecx,%eax
  80098e:	eb 16                	jmp    8009a6 <memcmp+0x4a>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800990:	4f                   	dec    %edi
  800991:	ba 00 00 00 00       	mov    $0x0,%edx
  800996:	39 fa                	cmp    %edi,%edx
  800998:	75 df                	jne    800979 <memcmp+0x1d>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  80099a:	b8 00 00 00 00       	mov    $0x0,%eax
  80099f:	eb 05                	jmp    8009a6 <memcmp+0x4a>
  8009a1:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009a6:	5b                   	pop    %ebx
  8009a7:	5e                   	pop    %esi
  8009a8:	5f                   	pop    %edi
  8009a9:	c9                   	leave  
  8009aa:	c3                   	ret    

008009ab <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009ab:	55                   	push   %ebp
  8009ac:	89 e5                	mov    %esp,%ebp
  8009ae:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  8009b1:	89 c2                	mov    %eax,%edx
  8009b3:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  8009b6:	39 d0                	cmp    %edx,%eax
  8009b8:	73 12                	jae    8009cc <memfind+0x21>
		if (*(const unsigned char *) s == (unsigned char) c)
  8009ba:	8a 4d 0c             	mov    0xc(%ebp),%cl
  8009bd:	38 08                	cmp    %cl,(%eax)
  8009bf:	75 06                	jne    8009c7 <memfind+0x1c>
  8009c1:	eb 09                	jmp    8009cc <memfind+0x21>
  8009c3:	38 08                	cmp    %cl,(%eax)
  8009c5:	74 05                	je     8009cc <memfind+0x21>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009c7:	40                   	inc    %eax
  8009c8:	39 c2                	cmp    %eax,%edx
  8009ca:	77 f7                	ja     8009c3 <memfind+0x18>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8009cc:	c9                   	leave  
  8009cd:	c3                   	ret    

008009ce <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8009ce:	55                   	push   %ebp
  8009cf:	89 e5                	mov    %esp,%ebp
  8009d1:	57                   	push   %edi
  8009d2:	56                   	push   %esi
  8009d3:	53                   	push   %ebx
  8009d4:	8b 55 08             	mov    0x8(%ebp),%edx
  8009d7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009da:	eb 01                	jmp    8009dd <strtol+0xf>
		s++;
  8009dc:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009dd:	8a 02                	mov    (%edx),%al
  8009df:	3c 20                	cmp    $0x20,%al
  8009e1:	74 f9                	je     8009dc <strtol+0xe>
  8009e3:	3c 09                	cmp    $0x9,%al
  8009e5:	74 f5                	je     8009dc <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  8009e7:	3c 2b                	cmp    $0x2b,%al
  8009e9:	75 08                	jne    8009f3 <strtol+0x25>
		s++;
  8009eb:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8009ec:	bf 00 00 00 00       	mov    $0x0,%edi
  8009f1:	eb 13                	jmp    800a06 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  8009f3:	3c 2d                	cmp    $0x2d,%al
  8009f5:	75 0a                	jne    800a01 <strtol+0x33>
		s++, neg = 1;
  8009f7:	8d 52 01             	lea    0x1(%edx),%edx
  8009fa:	bf 01 00 00 00       	mov    $0x1,%edi
  8009ff:	eb 05                	jmp    800a06 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a01:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a06:	85 db                	test   %ebx,%ebx
  800a08:	74 05                	je     800a0f <strtol+0x41>
  800a0a:	83 fb 10             	cmp    $0x10,%ebx
  800a0d:	75 28                	jne    800a37 <strtol+0x69>
  800a0f:	8a 02                	mov    (%edx),%al
  800a11:	3c 30                	cmp    $0x30,%al
  800a13:	75 10                	jne    800a25 <strtol+0x57>
  800a15:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800a19:	75 0a                	jne    800a25 <strtol+0x57>
		s += 2, base = 16;
  800a1b:	83 c2 02             	add    $0x2,%edx
  800a1e:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a23:	eb 12                	jmp    800a37 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800a25:	85 db                	test   %ebx,%ebx
  800a27:	75 0e                	jne    800a37 <strtol+0x69>
  800a29:	3c 30                	cmp    $0x30,%al
  800a2b:	75 05                	jne    800a32 <strtol+0x64>
		s++, base = 8;
  800a2d:	42                   	inc    %edx
  800a2e:	b3 08                	mov    $0x8,%bl
  800a30:	eb 05                	jmp    800a37 <strtol+0x69>
	else if (base == 0)
		base = 10;
  800a32:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800a37:	b8 00 00 00 00       	mov    $0x0,%eax
  800a3c:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a3e:	8a 0a                	mov    (%edx),%cl
  800a40:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800a43:	80 fb 09             	cmp    $0x9,%bl
  800a46:	77 08                	ja     800a50 <strtol+0x82>
			dig = *s - '0';
  800a48:	0f be c9             	movsbl %cl,%ecx
  800a4b:	83 e9 30             	sub    $0x30,%ecx
  800a4e:	eb 1e                	jmp    800a6e <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800a50:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800a53:	80 fb 19             	cmp    $0x19,%bl
  800a56:	77 08                	ja     800a60 <strtol+0x92>
			dig = *s - 'a' + 10;
  800a58:	0f be c9             	movsbl %cl,%ecx
  800a5b:	83 e9 57             	sub    $0x57,%ecx
  800a5e:	eb 0e                	jmp    800a6e <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800a60:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800a63:	80 fb 19             	cmp    $0x19,%bl
  800a66:	77 13                	ja     800a7b <strtol+0xad>
			dig = *s - 'A' + 10;
  800a68:	0f be c9             	movsbl %cl,%ecx
  800a6b:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800a6e:	39 f1                	cmp    %esi,%ecx
  800a70:	7d 0d                	jge    800a7f <strtol+0xb1>
			break;
		s++, val = (val * base) + dig;
  800a72:	42                   	inc    %edx
  800a73:	0f af c6             	imul   %esi,%eax
  800a76:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  800a79:	eb c3                	jmp    800a3e <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800a7b:	89 c1                	mov    %eax,%ecx
  800a7d:	eb 02                	jmp    800a81 <strtol+0xb3>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800a7f:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800a81:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a85:	74 05                	je     800a8c <strtol+0xbe>
		*endptr = (char *) s;
  800a87:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800a8a:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800a8c:	85 ff                	test   %edi,%edi
  800a8e:	74 04                	je     800a94 <strtol+0xc6>
  800a90:	89 c8                	mov    %ecx,%eax
  800a92:	f7 d8                	neg    %eax
}
  800a94:	5b                   	pop    %ebx
  800a95:	5e                   	pop    %esi
  800a96:	5f                   	pop    %edi
  800a97:	c9                   	leave  
  800a98:	c3                   	ret    
  800a99:	00 00                	add    %al,(%eax)
	...

00800a9c <syscall>:
	return ret;
}

static int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800a9c:	55                   	push   %ebp
  800a9d:	89 e5                	mov    %esp,%ebp
  800a9f:	57                   	push   %edi
  800aa0:	56                   	push   %esi
  800aa1:	53                   	push   %ebx
  800aa2:	83 ec 1c             	sub    $0x1c,%esp
  800aa5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800aa8:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800aab:	89 ca                	mov    %ecx,%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800aad:	8b 75 14             	mov    0x14(%ebp),%esi
  800ab0:	8b 7d 10             	mov    0x10(%ebp),%edi
  800ab3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800ab6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ab9:	cd 30                	int    $0x30
  800abb:	89 c2                	mov    %eax,%edx
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800abd:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800ac1:	74 1c                	je     800adf <syscall+0x43>
  800ac3:	85 c0                	test   %eax,%eax
  800ac5:	7e 18                	jle    800adf <syscall+0x43>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ac7:	83 ec 0c             	sub    $0xc,%esp
  800aca:	50                   	push   %eax
  800acb:	ff 75 e4             	pushl  -0x1c(%ebp)
  800ace:	68 40 10 80 00       	push   $0x801040
  800ad3:	6a 42                	push   $0x42
  800ad5:	68 5d 10 80 00       	push   $0x80105d
  800ada:	e8 9d 00 00 00       	call   800b7c <_panic>

	return ret;
}
  800adf:	89 d0                	mov    %edx,%eax
  800ae1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ae4:	5b                   	pop    %ebx
  800ae5:	5e                   	pop    %esi
  800ae6:	5f                   	pop    %edi
  800ae7:	c9                   	leave  
  800ae8:	c3                   	ret    

00800ae9 <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{	
  800ae9:	55                   	push   %ebp
  800aea:	89 e5                	mov    %esp,%ebp
  800aec:	83 ec 08             	sub    $0x8,%esp
	// my_sysenter(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
	// return;
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  800aef:	6a 00                	push   $0x0
  800af1:	6a 00                	push   $0x0
  800af3:	6a 00                	push   $0x0
  800af5:	ff 75 0c             	pushl  0xc(%ebp)
  800af8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800afb:	ba 00 00 00 00       	mov    $0x0,%edx
  800b00:	b8 00 00 00 00       	mov    $0x0,%eax
  800b05:	e8 92 ff ff ff       	call   800a9c <syscall>
  800b0a:	83 c4 10             	add    $0x10,%esp
	return;
}
  800b0d:	c9                   	leave  
  800b0e:	c3                   	ret    

00800b0f <sys_cgetc>:

int
sys_cgetc(void)
{
  800b0f:	55                   	push   %ebp
  800b10:	89 e5                	mov    %esp,%ebp
  800b12:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_cgetc, 0, 0, 0, 0, 0, 0);
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  800b15:	6a 00                	push   $0x0
  800b17:	6a 00                	push   $0x0
  800b19:	6a 00                	push   $0x0
  800b1b:	6a 00                	push   $0x0
  800b1d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b22:	ba 00 00 00 00       	mov    $0x0,%edx
  800b27:	b8 01 00 00 00       	mov    $0x1,%eax
  800b2c:	e8 6b ff ff ff       	call   800a9c <syscall>
}
  800b31:	c9                   	leave  
  800b32:	c3                   	ret    

00800b33 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b33:	55                   	push   %ebp
  800b34:	89 e5                	mov    %esp,%ebp
  800b36:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  800b39:	6a 00                	push   $0x0
  800b3b:	6a 00                	push   $0x0
  800b3d:	6a 00                	push   $0x0
  800b3f:	6a 00                	push   $0x0
  800b41:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b44:	ba 01 00 00 00       	mov    $0x1,%edx
  800b49:	b8 03 00 00 00       	mov    $0x3,%eax
  800b4e:	e8 49 ff ff ff       	call   800a9c <syscall>
}
  800b53:	c9                   	leave  
  800b54:	c3                   	ret    

00800b55 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b55:	55                   	push   %ebp
  800b56:	89 e5                	mov    %esp,%ebp
  800b58:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_getenvid, 0, 0, 0, 0, 0, 0);
	return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  800b5b:	6a 00                	push   $0x0
  800b5d:	6a 00                	push   $0x0
  800b5f:	6a 00                	push   $0x0
  800b61:	6a 00                	push   $0x0
  800b63:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b68:	ba 00 00 00 00       	mov    $0x0,%edx
  800b6d:	b8 02 00 00 00       	mov    $0x2,%eax
  800b72:	e8 25 ff ff ff       	call   800a9c <syscall>
}
  800b77:	c9                   	leave  
  800b78:	c3                   	ret    
  800b79:	00 00                	add    %al,(%eax)
	...

00800b7c <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800b7c:	55                   	push   %ebp
  800b7d:	89 e5                	mov    %esp,%ebp
  800b7f:	56                   	push   %esi
  800b80:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800b81:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800b84:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  800b8a:	e8 c6 ff ff ff       	call   800b55 <sys_getenvid>
  800b8f:	83 ec 0c             	sub    $0xc,%esp
  800b92:	ff 75 0c             	pushl  0xc(%ebp)
  800b95:	ff 75 08             	pushl  0x8(%ebp)
  800b98:	53                   	push   %ebx
  800b99:	50                   	push   %eax
  800b9a:	68 6c 10 80 00       	push   $0x80106c
  800b9f:	e8 c4 f5 ff ff       	call   800168 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800ba4:	83 c4 18             	add    $0x18,%esp
  800ba7:	56                   	push   %esi
  800ba8:	ff 75 10             	pushl  0x10(%ebp)
  800bab:	e8 67 f5 ff ff       	call   800117 <vcprintf>
	cprintf("\n");
  800bb0:	c7 04 24 19 0e 80 00 	movl   $0x800e19,(%esp)
  800bb7:	e8 ac f5 ff ff       	call   800168 <cprintf>
  800bbc:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800bbf:	cc                   	int3   
  800bc0:	eb fd                	jmp    800bbf <_panic+0x43>
	...

00800bc4 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  800bc4:	55                   	push   %ebp
  800bc5:	89 e5                	mov    %esp,%ebp
  800bc7:	57                   	push   %edi
  800bc8:	56                   	push   %esi
  800bc9:	83 ec 10             	sub    $0x10,%esp
  800bcc:	8b 7d 08             	mov    0x8(%ebp),%edi
  800bcf:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  800bd2:	89 7d f0             	mov    %edi,-0x10(%ebp)
  800bd5:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  800bd8:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  800bdb:	8b 45 14             	mov    0x14(%ebp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800bde:	85 c0                	test   %eax,%eax
  800be0:	75 2e                	jne    800c10 <__udivdi3+0x4c>
    {
      if (d0 > n1)
  800be2:	39 f1                	cmp    %esi,%ecx
  800be4:	77 5a                	ja     800c40 <__udivdi3+0x7c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  800be6:	85 c9                	test   %ecx,%ecx
  800be8:	75 0b                	jne    800bf5 <__udivdi3+0x31>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  800bea:	b8 01 00 00 00       	mov    $0x1,%eax
  800bef:	31 d2                	xor    %edx,%edx
  800bf1:	f7 f1                	div    %ecx
  800bf3:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  800bf5:	31 d2                	xor    %edx,%edx
  800bf7:	89 f0                	mov    %esi,%eax
  800bf9:	f7 f1                	div    %ecx
  800bfb:	89 c6                	mov    %eax,%esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800bfd:	89 f8                	mov    %edi,%eax
  800bff:	f7 f1                	div    %ecx
  800c01:	89 c7                	mov    %eax,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800c03:	89 f8                	mov    %edi,%eax
  800c05:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800c07:	83 c4 10             	add    $0x10,%esp
  800c0a:	5e                   	pop    %esi
  800c0b:	5f                   	pop    %edi
  800c0c:	c9                   	leave  
  800c0d:	c3                   	ret    
  800c0e:	66 90                	xchg   %ax,%ax
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800c10:	39 f0                	cmp    %esi,%eax
  800c12:	77 1c                	ja     800c30 <__udivdi3+0x6c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  800c14:	0f bd f8             	bsr    %eax,%edi
	  if (bm == 0)
  800c17:	83 f7 1f             	xor    $0x1f,%edi
  800c1a:	75 3c                	jne    800c58 <__udivdi3+0x94>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800c1c:	39 f0                	cmp    %esi,%eax
  800c1e:	0f 82 90 00 00 00    	jb     800cb4 <__udivdi3+0xf0>
  800c24:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800c27:	39 55 f4             	cmp    %edx,-0xc(%ebp)
  800c2a:	0f 86 84 00 00 00    	jbe    800cb4 <__udivdi3+0xf0>
  800c30:	31 f6                	xor    %esi,%esi
  800c32:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800c34:	89 f8                	mov    %edi,%eax
  800c36:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800c38:	83 c4 10             	add    $0x10,%esp
  800c3b:	5e                   	pop    %esi
  800c3c:	5f                   	pop    %edi
  800c3d:	c9                   	leave  
  800c3e:	c3                   	ret    
  800c3f:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800c40:	89 f2                	mov    %esi,%edx
  800c42:	89 f8                	mov    %edi,%eax
  800c44:	f7 f1                	div    %ecx
  800c46:	89 c7                	mov    %eax,%edi
  800c48:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800c4a:	89 f8                	mov    %edi,%eax
  800c4c:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800c4e:	83 c4 10             	add    $0x10,%esp
  800c51:	5e                   	pop    %esi
  800c52:	5f                   	pop    %edi
  800c53:	c9                   	leave  
  800c54:	c3                   	ret    
  800c55:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  800c58:	89 f9                	mov    %edi,%ecx
  800c5a:	d3 e0                	shl    %cl,%eax
  800c5c:	89 45 e8             	mov    %eax,-0x18(%ebp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  800c5f:	b8 20 00 00 00       	mov    $0x20,%eax
  800c64:	29 f8                	sub    %edi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  800c66:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800c69:	88 c1                	mov    %al,%cl
  800c6b:	d3 ea                	shr    %cl,%edx
  800c6d:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  800c70:	09 ca                	or     %ecx,%edx
  800c72:	89 55 ec             	mov    %edx,-0x14(%ebp)
	      d0 = d0 << bm;
  800c75:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800c78:	89 f9                	mov    %edi,%ecx
  800c7a:	d3 e2                	shl    %cl,%edx
  800c7c:	89 55 f4             	mov    %edx,-0xc(%ebp)
	      n2 = n1 >> b;
  800c7f:	89 f2                	mov    %esi,%edx
  800c81:	88 c1                	mov    %al,%cl
  800c83:	d3 ea                	shr    %cl,%edx
  800c85:	89 55 e8             	mov    %edx,-0x18(%ebp)
	      n1 = (n1 << bm) | (n0 >> b);
  800c88:	89 f2                	mov    %esi,%edx
  800c8a:	89 f9                	mov    %edi,%ecx
  800c8c:	d3 e2                	shl    %cl,%edx
  800c8e:	8b 75 f0             	mov    -0x10(%ebp),%esi
  800c91:	88 c1                	mov    %al,%cl
  800c93:	d3 ee                	shr    %cl,%esi
  800c95:	09 d6                	or     %edx,%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  800c97:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  800c9a:	89 f0                	mov    %esi,%eax
  800c9c:	89 ca                	mov    %ecx,%edx
  800c9e:	f7 75 ec             	divl   -0x14(%ebp)
  800ca1:	89 d1                	mov    %edx,%ecx
  800ca3:	89 c6                	mov    %eax,%esi
	      umul_ppmm (m1, m0, q0, d0);
  800ca5:	f7 65 f4             	mull   -0xc(%ebp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800ca8:	39 d1                	cmp    %edx,%ecx
  800caa:	72 28                	jb     800cd4 <__udivdi3+0x110>
  800cac:	74 1a                	je     800cc8 <__udivdi3+0x104>
  800cae:	89 f7                	mov    %esi,%edi
  800cb0:	31 f6                	xor    %esi,%esi
  800cb2:	eb 80                	jmp    800c34 <__udivdi3+0x70>
	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  800cb4:	31 f6                	xor    %esi,%esi
  800cb6:	bf 01 00 00 00       	mov    $0x1,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800cbb:	89 f8                	mov    %edi,%eax
  800cbd:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800cbf:	83 c4 10             	add    $0x10,%esp
  800cc2:	5e                   	pop    %esi
  800cc3:	5f                   	pop    %edi
  800cc4:	c9                   	leave  
  800cc5:	c3                   	ret    
  800cc6:	66 90                	xchg   %ax,%ax

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  800cc8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800ccb:	89 f9                	mov    %edi,%ecx
  800ccd:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800ccf:	39 c2                	cmp    %eax,%edx
  800cd1:	73 db                	jae    800cae <__udivdi3+0xea>
  800cd3:	90                   	nop
		{
		  q0--;
  800cd4:	8d 7e ff             	lea    -0x1(%esi),%edi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  800cd7:	31 f6                	xor    %esi,%esi
  800cd9:	e9 56 ff ff ff       	jmp    800c34 <__udivdi3+0x70>
	...

00800ce0 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  800ce0:	55                   	push   %ebp
  800ce1:	89 e5                	mov    %esp,%ebp
  800ce3:	57                   	push   %edi
  800ce4:	56                   	push   %esi
  800ce5:	83 ec 20             	sub    $0x20,%esp
  800ce8:	8b 45 08             	mov    0x8(%ebp),%eax
  800ceb:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  800cee:	89 45 e8             	mov    %eax,-0x18(%ebp)
  800cf1:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  800cf4:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  800cf7:	8b 7d 14             	mov    0x14(%ebp),%edi
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  800cfa:	89 45 f0             	mov    %eax,-0x10(%ebp)
  n1 = nn.s.high;
  800cfd:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800cff:	85 ff                	test   %edi,%edi
  800d01:	75 15                	jne    800d18 <__umoddi3+0x38>
    {
      if (d0 > n1)
  800d03:	39 f1                	cmp    %esi,%ecx
  800d05:	0f 86 99 00 00 00    	jbe    800da4 <__umoddi3+0xc4>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800d0b:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  800d0d:	89 d0                	mov    %edx,%eax
  800d0f:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800d11:	83 c4 20             	add    $0x20,%esp
  800d14:	5e                   	pop    %esi
  800d15:	5f                   	pop    %edi
  800d16:	c9                   	leave  
  800d17:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800d18:	39 f7                	cmp    %esi,%edi
  800d1a:	0f 87 a4 00 00 00    	ja     800dc4 <__umoddi3+0xe4>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  800d20:	0f bd c7             	bsr    %edi,%eax
	  if (bm == 0)
  800d23:	83 f0 1f             	xor    $0x1f,%eax
  800d26:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800d29:	0f 84 a1 00 00 00    	je     800dd0 <__umoddi3+0xf0>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  800d2f:	89 f8                	mov    %edi,%eax
  800d31:	8a 4d ec             	mov    -0x14(%ebp),%cl
  800d34:	d3 e0                	shl    %cl,%eax
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  800d36:	bf 20 00 00 00       	mov    $0x20,%edi
  800d3b:	2b 7d ec             	sub    -0x14(%ebp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  800d3e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800d41:	89 f9                	mov    %edi,%ecx
  800d43:	d3 ea                	shr    %cl,%edx
  800d45:	09 c2                	or     %eax,%edx
  800d47:	89 55 f0             	mov    %edx,-0x10(%ebp)
	      d0 = d0 << bm;
  800d4a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800d4d:	8a 4d ec             	mov    -0x14(%ebp),%cl
  800d50:	d3 e0                	shl    %cl,%eax
  800d52:	89 45 f4             	mov    %eax,-0xc(%ebp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  800d55:	89 f2                	mov    %esi,%edx
  800d57:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  800d59:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800d5c:	d3 e0                	shl    %cl,%eax
  800d5e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  800d61:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800d64:	89 f9                	mov    %edi,%ecx
  800d66:	d3 e8                	shr    %cl,%eax
  800d68:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  800d6a:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  800d6c:	89 f2                	mov    %esi,%edx
  800d6e:	f7 75 f0             	divl   -0x10(%ebp)
  800d71:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  800d73:	f7 65 f4             	mull   -0xc(%ebp)
  800d76:	89 55 e8             	mov    %edx,-0x18(%ebp)
  800d79:	89 c1                	mov    %eax,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800d7b:	39 d6                	cmp    %edx,%esi
  800d7d:	72 71                	jb     800df0 <__umoddi3+0x110>
  800d7f:	74 7f                	je     800e00 <__umoddi3+0x120>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  800d81:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800d84:	29 c8                	sub    %ecx,%eax
  800d86:	19 d6                	sbb    %edx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  800d88:	8a 4d ec             	mov    -0x14(%ebp),%cl
  800d8b:	d3 e8                	shr    %cl,%eax
  800d8d:	89 f2                	mov    %esi,%edx
  800d8f:	89 f9                	mov    %edi,%ecx
  800d91:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  800d93:	09 d0                	or     %edx,%eax
  800d95:	89 f2                	mov    %esi,%edx
  800d97:	8a 4d ec             	mov    -0x14(%ebp),%cl
  800d9a:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800d9c:	83 c4 20             	add    $0x20,%esp
  800d9f:	5e                   	pop    %esi
  800da0:	5f                   	pop    %edi
  800da1:	c9                   	leave  
  800da2:	c3                   	ret    
  800da3:	90                   	nop
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  800da4:	85 c9                	test   %ecx,%ecx
  800da6:	75 0b                	jne    800db3 <__umoddi3+0xd3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  800da8:	b8 01 00 00 00       	mov    $0x1,%eax
  800dad:	31 d2                	xor    %edx,%edx
  800daf:	f7 f1                	div    %ecx
  800db1:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  800db3:	89 f0                	mov    %esi,%eax
  800db5:	31 d2                	xor    %edx,%edx
  800db7:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800db9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800dbc:	f7 f1                	div    %ecx
  800dbe:	e9 4a ff ff ff       	jmp    800d0d <__umoddi3+0x2d>
  800dc3:	90                   	nop
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  800dc4:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800dc6:	83 c4 20             	add    $0x20,%esp
  800dc9:	5e                   	pop    %esi
  800dca:	5f                   	pop    %edi
  800dcb:	c9                   	leave  
  800dcc:	c3                   	ret    
  800dcd:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800dd0:	39 f7                	cmp    %esi,%edi
  800dd2:	72 05                	jb     800dd9 <__umoddi3+0xf9>
  800dd4:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
  800dd7:	77 0c                	ja     800de5 <__umoddi3+0x105>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  800dd9:	89 f2                	mov    %esi,%edx
  800ddb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800dde:	29 c8                	sub    %ecx,%eax
  800de0:	19 fa                	sbb    %edi,%edx
  800de2:	89 45 f0             	mov    %eax,-0x10(%ebp)

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  800de5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800de8:	83 c4 20             	add    $0x20,%esp
  800deb:	5e                   	pop    %esi
  800dec:	5f                   	pop    %edi
  800ded:	c9                   	leave  
  800dee:	c3                   	ret    
  800def:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  800df0:	8b 55 e8             	mov    -0x18(%ebp),%edx
  800df3:	89 c1                	mov    %eax,%ecx
  800df5:	2b 4d f4             	sub    -0xc(%ebp),%ecx
  800df8:	1b 55 f0             	sbb    -0x10(%ebp),%edx
  800dfb:	eb 84                	jmp    800d81 <__umoddi3+0xa1>
  800dfd:	8d 76 00             	lea    0x0(%esi),%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800e00:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  800e03:	72 eb                	jb     800df0 <__umoddi3+0x110>
  800e05:	89 f2                	mov    %esi,%edx
  800e07:	e9 75 ff ff ff       	jmp    800d81 <__umoddi3+0xa1>
