
obj/user/divzero.debug:     file format elf32-i386


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
  80003a:	c7 05 04 40 80 00 00 	movl   $0x0,0x804004
  800041:	00 00 00 
	cprintf("1/0 is %08x!\n", 1/zero);
  800044:	b8 01 00 00 00       	mov    $0x1,%eax
  800049:	b9 00 00 00 00       	mov    $0x0,%ecx
  80004e:	99                   	cltd   
  80004f:	f7 f9                	idiv   %ecx
  800051:	50                   	push   %eax
  800052:	68 c0 1d 80 00       	push   $0x801dc0
  800057:	e8 04 01 00 00       	call   800160 <cprintf>
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
  80006f:	e8 d9 0a 00 00       	call   800b4d <sys_getenvid>
  800074:	25 ff 03 00 00       	and    $0x3ff,%eax
  800079:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800080:	c1 e0 07             	shl    $0x7,%eax
  800083:	29 d0                	sub    %edx,%eax
  800085:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80008a:	a3 08 40 80 00       	mov    %eax,0x804008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80008f:	85 f6                	test   %esi,%esi
  800091:	7e 07                	jle    80009a <libmain+0x36>
		binaryname = argv[0];
  800093:	8b 03                	mov    (%ebx),%eax
  800095:	a3 00 30 80 00       	mov    %eax,0x803000
	// call user main routine
	umain(argc, argv);
  80009a:	83 ec 08             	sub    $0x8,%esp
  80009d:	53                   	push   %ebx
  80009e:	56                   	push   %esi
  80009f:	e8 90 ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  8000a4:	e8 0b 00 00 00       	call   8000b4 <exit>
  8000a9:	83 c4 10             	add    $0x10,%esp
}
  8000ac:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000af:	5b                   	pop    %ebx
  8000b0:	5e                   	pop    %esi
  8000b1:	c9                   	leave  
  8000b2:	c3                   	ret    
	...

008000b4 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000b4:	55                   	push   %ebp
  8000b5:	89 e5                	mov    %esp,%ebp
  8000b7:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8000ba:	e8 4b 0e 00 00       	call   800f0a <close_all>
	sys_env_destroy(0);
  8000bf:	83 ec 0c             	sub    $0xc,%esp
  8000c2:	6a 00                	push   $0x0
  8000c4:	e8 62 0a 00 00       	call   800b2b <sys_env_destroy>
  8000c9:	83 c4 10             	add    $0x10,%esp
}
  8000cc:	c9                   	leave  
  8000cd:	c3                   	ret    
	...

008000d0 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000d0:	55                   	push   %ebp
  8000d1:	89 e5                	mov    %esp,%ebp
  8000d3:	53                   	push   %ebx
  8000d4:	83 ec 04             	sub    $0x4,%esp
  8000d7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000da:	8b 03                	mov    (%ebx),%eax
  8000dc:	8b 55 08             	mov    0x8(%ebp),%edx
  8000df:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8000e3:	40                   	inc    %eax
  8000e4:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8000e6:	3d ff 00 00 00       	cmp    $0xff,%eax
  8000eb:	75 1a                	jne    800107 <putch+0x37>
		sys_cputs(b->buf, b->idx);
  8000ed:	83 ec 08             	sub    $0x8,%esp
  8000f0:	68 ff 00 00 00       	push   $0xff
  8000f5:	8d 43 08             	lea    0x8(%ebx),%eax
  8000f8:	50                   	push   %eax
  8000f9:	e8 e3 09 00 00       	call   800ae1 <sys_cputs>
		b->idx = 0;
  8000fe:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800104:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800107:	ff 43 04             	incl   0x4(%ebx)
}
  80010a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80010d:	c9                   	leave  
  80010e:	c3                   	ret    

0080010f <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80010f:	55                   	push   %ebp
  800110:	89 e5                	mov    %esp,%ebp
  800112:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800118:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80011f:	00 00 00 
	b.cnt = 0;
  800122:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800129:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80012c:	ff 75 0c             	pushl  0xc(%ebp)
  80012f:	ff 75 08             	pushl  0x8(%ebp)
  800132:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800138:	50                   	push   %eax
  800139:	68 d0 00 80 00       	push   $0x8000d0
  80013e:	e8 82 01 00 00       	call   8002c5 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800143:	83 c4 08             	add    $0x8,%esp
  800146:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80014c:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800152:	50                   	push   %eax
  800153:	e8 89 09 00 00       	call   800ae1 <sys_cputs>

	return b.cnt;
}
  800158:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80015e:	c9                   	leave  
  80015f:	c3                   	ret    

00800160 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800160:	55                   	push   %ebp
  800161:	89 e5                	mov    %esp,%ebp
  800163:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800166:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800169:	50                   	push   %eax
  80016a:	ff 75 08             	pushl  0x8(%ebp)
  80016d:	e8 9d ff ff ff       	call   80010f <vcprintf>
	va_end(ap);

	return cnt;
}
  800172:	c9                   	leave  
  800173:	c3                   	ret    

00800174 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800174:	55                   	push   %ebp
  800175:	89 e5                	mov    %esp,%ebp
  800177:	57                   	push   %edi
  800178:	56                   	push   %esi
  800179:	53                   	push   %ebx
  80017a:	83 ec 2c             	sub    $0x2c,%esp
  80017d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800180:	89 d6                	mov    %edx,%esi
  800182:	8b 45 08             	mov    0x8(%ebp),%eax
  800185:	8b 55 0c             	mov    0xc(%ebp),%edx
  800188:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80018b:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80018e:	8b 45 10             	mov    0x10(%ebp),%eax
  800191:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800194:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800197:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80019a:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  8001a1:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
  8001a4:	72 0c                	jb     8001b2 <printnum+0x3e>
  8001a6:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  8001a9:	76 07                	jbe    8001b2 <printnum+0x3e>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8001ab:	4b                   	dec    %ebx
  8001ac:	85 db                	test   %ebx,%ebx
  8001ae:	7f 31                	jg     8001e1 <printnum+0x6d>
  8001b0:	eb 3f                	jmp    8001f1 <printnum+0x7d>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001b2:	83 ec 0c             	sub    $0xc,%esp
  8001b5:	57                   	push   %edi
  8001b6:	4b                   	dec    %ebx
  8001b7:	53                   	push   %ebx
  8001b8:	50                   	push   %eax
  8001b9:	83 ec 08             	sub    $0x8,%esp
  8001bc:	ff 75 d4             	pushl  -0x2c(%ebp)
  8001bf:	ff 75 d0             	pushl  -0x30(%ebp)
  8001c2:	ff 75 dc             	pushl  -0x24(%ebp)
  8001c5:	ff 75 d8             	pushl  -0x28(%ebp)
  8001c8:	e8 9b 19 00 00       	call   801b68 <__udivdi3>
  8001cd:	83 c4 18             	add    $0x18,%esp
  8001d0:	52                   	push   %edx
  8001d1:	50                   	push   %eax
  8001d2:	89 f2                	mov    %esi,%edx
  8001d4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8001d7:	e8 98 ff ff ff       	call   800174 <printnum>
  8001dc:	83 c4 20             	add    $0x20,%esp
  8001df:	eb 10                	jmp    8001f1 <printnum+0x7d>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8001e1:	83 ec 08             	sub    $0x8,%esp
  8001e4:	56                   	push   %esi
  8001e5:	57                   	push   %edi
  8001e6:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8001e9:	4b                   	dec    %ebx
  8001ea:	83 c4 10             	add    $0x10,%esp
  8001ed:	85 db                	test   %ebx,%ebx
  8001ef:	7f f0                	jg     8001e1 <printnum+0x6d>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8001f1:	83 ec 08             	sub    $0x8,%esp
  8001f4:	56                   	push   %esi
  8001f5:	83 ec 04             	sub    $0x4,%esp
  8001f8:	ff 75 d4             	pushl  -0x2c(%ebp)
  8001fb:	ff 75 d0             	pushl  -0x30(%ebp)
  8001fe:	ff 75 dc             	pushl  -0x24(%ebp)
  800201:	ff 75 d8             	pushl  -0x28(%ebp)
  800204:	e8 7b 1a 00 00       	call   801c84 <__umoddi3>
  800209:	83 c4 14             	add    $0x14,%esp
  80020c:	0f be 80 d8 1d 80 00 	movsbl 0x801dd8(%eax),%eax
  800213:	50                   	push   %eax
  800214:	ff 55 e4             	call   *-0x1c(%ebp)
  800217:	83 c4 10             	add    $0x10,%esp
}
  80021a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80021d:	5b                   	pop    %ebx
  80021e:	5e                   	pop    %esi
  80021f:	5f                   	pop    %edi
  800220:	c9                   	leave  
  800221:	c3                   	ret    

00800222 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800222:	55                   	push   %ebp
  800223:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800225:	83 fa 01             	cmp    $0x1,%edx
  800228:	7e 0e                	jle    800238 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80022a:	8b 10                	mov    (%eax),%edx
  80022c:	8d 4a 08             	lea    0x8(%edx),%ecx
  80022f:	89 08                	mov    %ecx,(%eax)
  800231:	8b 02                	mov    (%edx),%eax
  800233:	8b 52 04             	mov    0x4(%edx),%edx
  800236:	eb 22                	jmp    80025a <getuint+0x38>
	else if (lflag)
  800238:	85 d2                	test   %edx,%edx
  80023a:	74 10                	je     80024c <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80023c:	8b 10                	mov    (%eax),%edx
  80023e:	8d 4a 04             	lea    0x4(%edx),%ecx
  800241:	89 08                	mov    %ecx,(%eax)
  800243:	8b 02                	mov    (%edx),%eax
  800245:	ba 00 00 00 00       	mov    $0x0,%edx
  80024a:	eb 0e                	jmp    80025a <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80024c:	8b 10                	mov    (%eax),%edx
  80024e:	8d 4a 04             	lea    0x4(%edx),%ecx
  800251:	89 08                	mov    %ecx,(%eax)
  800253:	8b 02                	mov    (%edx),%eax
  800255:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80025a:	c9                   	leave  
  80025b:	c3                   	ret    

0080025c <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  80025c:	55                   	push   %ebp
  80025d:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80025f:	83 fa 01             	cmp    $0x1,%edx
  800262:	7e 0e                	jle    800272 <getint+0x16>
		return va_arg(*ap, long long);
  800264:	8b 10                	mov    (%eax),%edx
  800266:	8d 4a 08             	lea    0x8(%edx),%ecx
  800269:	89 08                	mov    %ecx,(%eax)
  80026b:	8b 02                	mov    (%edx),%eax
  80026d:	8b 52 04             	mov    0x4(%edx),%edx
  800270:	eb 1a                	jmp    80028c <getint+0x30>
	else if (lflag)
  800272:	85 d2                	test   %edx,%edx
  800274:	74 0c                	je     800282 <getint+0x26>
		return va_arg(*ap, long);
  800276:	8b 10                	mov    (%eax),%edx
  800278:	8d 4a 04             	lea    0x4(%edx),%ecx
  80027b:	89 08                	mov    %ecx,(%eax)
  80027d:	8b 02                	mov    (%edx),%eax
  80027f:	99                   	cltd   
  800280:	eb 0a                	jmp    80028c <getint+0x30>
	else
		return va_arg(*ap, int);
  800282:	8b 10                	mov    (%eax),%edx
  800284:	8d 4a 04             	lea    0x4(%edx),%ecx
  800287:	89 08                	mov    %ecx,(%eax)
  800289:	8b 02                	mov    (%edx),%eax
  80028b:	99                   	cltd   
}
  80028c:	c9                   	leave  
  80028d:	c3                   	ret    

0080028e <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80028e:	55                   	push   %ebp
  80028f:	89 e5                	mov    %esp,%ebp
  800291:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800294:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  800297:	8b 10                	mov    (%eax),%edx
  800299:	3b 50 04             	cmp    0x4(%eax),%edx
  80029c:	73 08                	jae    8002a6 <sprintputch+0x18>
		*b->buf++ = ch;
  80029e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8002a1:	88 0a                	mov    %cl,(%edx)
  8002a3:	42                   	inc    %edx
  8002a4:	89 10                	mov    %edx,(%eax)
}
  8002a6:	c9                   	leave  
  8002a7:	c3                   	ret    

008002a8 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8002a8:	55                   	push   %ebp
  8002a9:	89 e5                	mov    %esp,%ebp
  8002ab:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8002ae:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002b1:	50                   	push   %eax
  8002b2:	ff 75 10             	pushl  0x10(%ebp)
  8002b5:	ff 75 0c             	pushl  0xc(%ebp)
  8002b8:	ff 75 08             	pushl  0x8(%ebp)
  8002bb:	e8 05 00 00 00       	call   8002c5 <vprintfmt>
	va_end(ap);
  8002c0:	83 c4 10             	add    $0x10,%esp
}
  8002c3:	c9                   	leave  
  8002c4:	c3                   	ret    

008002c5 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8002c5:	55                   	push   %ebp
  8002c6:	89 e5                	mov    %esp,%ebp
  8002c8:	57                   	push   %edi
  8002c9:	56                   	push   %esi
  8002ca:	53                   	push   %ebx
  8002cb:	83 ec 2c             	sub    $0x2c,%esp
  8002ce:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8002d1:	8b 75 10             	mov    0x10(%ebp),%esi
  8002d4:	eb 13                	jmp    8002e9 <vprintfmt+0x24>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8002d6:	85 c0                	test   %eax,%eax
  8002d8:	0f 84 6d 03 00 00    	je     80064b <vprintfmt+0x386>
				return;
			putch(ch, putdat);
  8002de:	83 ec 08             	sub    $0x8,%esp
  8002e1:	57                   	push   %edi
  8002e2:	50                   	push   %eax
  8002e3:	ff 55 08             	call   *0x8(%ebp)
  8002e6:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8002e9:	0f b6 06             	movzbl (%esi),%eax
  8002ec:	46                   	inc    %esi
  8002ed:	83 f8 25             	cmp    $0x25,%eax
  8002f0:	75 e4                	jne    8002d6 <vprintfmt+0x11>
  8002f2:	c6 45 dc 20          	movb   $0x20,-0x24(%ebp)
  8002f6:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  8002fd:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  800304:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  80030b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800310:	eb 28                	jmp    80033a <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800312:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800314:	c6 45 dc 2d          	movb   $0x2d,-0x24(%ebp)
  800318:	eb 20                	jmp    80033a <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80031a:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80031c:	c6 45 dc 30          	movb   $0x30,-0x24(%ebp)
  800320:	eb 18                	jmp    80033a <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800322:	89 de                	mov    %ebx,%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800324:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  80032b:	eb 0d                	jmp    80033a <vprintfmt+0x75>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  80032d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800330:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800333:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80033a:	8a 06                	mov    (%esi),%al
  80033c:	0f b6 d0             	movzbl %al,%edx
  80033f:	8d 5e 01             	lea    0x1(%esi),%ebx
  800342:	83 e8 23             	sub    $0x23,%eax
  800345:	3c 55                	cmp    $0x55,%al
  800347:	0f 87 e0 02 00 00    	ja     80062d <vprintfmt+0x368>
  80034d:	0f b6 c0             	movzbl %al,%eax
  800350:	ff 24 85 20 1f 80 00 	jmp    *0x801f20(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800357:	83 ea 30             	sub    $0x30,%edx
  80035a:	89 55 d4             	mov    %edx,-0x2c(%ebp)
				ch = *fmt;
  80035d:	0f be 03             	movsbl (%ebx),%eax
				if (ch < '0' || ch > '9')
  800360:	8d 50 d0             	lea    -0x30(%eax),%edx
  800363:	83 fa 09             	cmp    $0x9,%edx
  800366:	77 44                	ja     8003ac <vprintfmt+0xe7>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800368:	89 de                	mov    %ebx,%esi
  80036a:	8b 55 d4             	mov    -0x2c(%ebp),%edx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80036d:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
  80036e:	8d 14 92             	lea    (%edx,%edx,4),%edx
  800371:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
  800375:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800378:	8d 58 d0             	lea    -0x30(%eax),%ebx
  80037b:	83 fb 09             	cmp    $0x9,%ebx
  80037e:	76 ed                	jbe    80036d <vprintfmt+0xa8>
  800380:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  800383:	eb 29                	jmp    8003ae <vprintfmt+0xe9>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800385:	8b 45 14             	mov    0x14(%ebp),%eax
  800388:	8d 50 04             	lea    0x4(%eax),%edx
  80038b:	89 55 14             	mov    %edx,0x14(%ebp)
  80038e:	8b 00                	mov    (%eax),%eax
  800390:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800393:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800395:	eb 17                	jmp    8003ae <vprintfmt+0xe9>

		case '.':
			if (width < 0)
  800397:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80039b:	78 85                	js     800322 <vprintfmt+0x5d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80039d:	89 de                	mov    %ebx,%esi
  80039f:	eb 99                	jmp    80033a <vprintfmt+0x75>
  8003a1:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8003a3:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  8003aa:	eb 8e                	jmp    80033a <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ac:	89 de                	mov    %ebx,%esi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  8003ae:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8003b2:	79 86                	jns    80033a <vprintfmt+0x75>
  8003b4:	e9 74 ff ff ff       	jmp    80032d <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8003b9:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ba:	89 de                	mov    %ebx,%esi
  8003bc:	e9 79 ff ff ff       	jmp    80033a <vprintfmt+0x75>
  8003c1:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8003c4:	8b 45 14             	mov    0x14(%ebp),%eax
  8003c7:	8d 50 04             	lea    0x4(%eax),%edx
  8003ca:	89 55 14             	mov    %edx,0x14(%ebp)
  8003cd:	83 ec 08             	sub    $0x8,%esp
  8003d0:	57                   	push   %edi
  8003d1:	ff 30                	pushl  (%eax)
  8003d3:	ff 55 08             	call   *0x8(%ebp)
			break;
  8003d6:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003d9:	8b 75 d8             	mov    -0x28(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8003dc:	e9 08 ff ff ff       	jmp    8002e9 <vprintfmt+0x24>
  8003e1:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  8003e4:	8b 45 14             	mov    0x14(%ebp),%eax
  8003e7:	8d 50 04             	lea    0x4(%eax),%edx
  8003ea:	89 55 14             	mov    %edx,0x14(%ebp)
  8003ed:	8b 00                	mov    (%eax),%eax
  8003ef:	85 c0                	test   %eax,%eax
  8003f1:	79 02                	jns    8003f5 <vprintfmt+0x130>
  8003f3:	f7 d8                	neg    %eax
  8003f5:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003f7:	83 f8 0f             	cmp    $0xf,%eax
  8003fa:	7f 0b                	jg     800407 <vprintfmt+0x142>
  8003fc:	8b 04 85 80 20 80 00 	mov    0x802080(,%eax,4),%eax
  800403:	85 c0                	test   %eax,%eax
  800405:	75 1a                	jne    800421 <vprintfmt+0x15c>
				printfmt(putch, putdat, "error %d", err);
  800407:	52                   	push   %edx
  800408:	68 f0 1d 80 00       	push   $0x801df0
  80040d:	57                   	push   %edi
  80040e:	ff 75 08             	pushl  0x8(%ebp)
  800411:	e8 92 fe ff ff       	call   8002a8 <printfmt>
  800416:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800419:	8b 75 d8             	mov    -0x28(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80041c:	e9 c8 fe ff ff       	jmp    8002e9 <vprintfmt+0x24>
			else
				printfmt(putch, putdat, "%s", p);
  800421:	50                   	push   %eax
  800422:	68 b1 21 80 00       	push   $0x8021b1
  800427:	57                   	push   %edi
  800428:	ff 75 08             	pushl  0x8(%ebp)
  80042b:	e8 78 fe ff ff       	call   8002a8 <printfmt>
  800430:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800433:	8b 75 d8             	mov    -0x28(%ebp),%esi
  800436:	e9 ae fe ff ff       	jmp    8002e9 <vprintfmt+0x24>
  80043b:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  80043e:	89 de                	mov    %ebx,%esi
  800440:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  800443:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800446:	8b 45 14             	mov    0x14(%ebp),%eax
  800449:	8d 50 04             	lea    0x4(%eax),%edx
  80044c:	89 55 14             	mov    %edx,0x14(%ebp)
  80044f:	8b 00                	mov    (%eax),%eax
  800451:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800454:	85 c0                	test   %eax,%eax
  800456:	75 07                	jne    80045f <vprintfmt+0x19a>
				p = "(null)";
  800458:	c7 45 d0 e9 1d 80 00 	movl   $0x801de9,-0x30(%ebp)
			if (width > 0 && padc != '-')
  80045f:	85 db                	test   %ebx,%ebx
  800461:	7e 42                	jle    8004a5 <vprintfmt+0x1e0>
  800463:	80 7d dc 2d          	cmpb   $0x2d,-0x24(%ebp)
  800467:	74 3c                	je     8004a5 <vprintfmt+0x1e0>
				for (width -= strnlen(p, precision); width > 0; width--)
  800469:	83 ec 08             	sub    $0x8,%esp
  80046c:	51                   	push   %ecx
  80046d:	ff 75 d0             	pushl  -0x30(%ebp)
  800470:	e8 6f 02 00 00       	call   8006e4 <strnlen>
  800475:	29 c3                	sub    %eax,%ebx
  800477:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80047a:	83 c4 10             	add    $0x10,%esp
  80047d:	85 db                	test   %ebx,%ebx
  80047f:	7e 24                	jle    8004a5 <vprintfmt+0x1e0>
					putch(padc, putdat);
  800481:	0f be 5d dc          	movsbl -0x24(%ebp),%ebx
  800485:	89 75 dc             	mov    %esi,-0x24(%ebp)
  800488:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  80048b:	83 ec 08             	sub    $0x8,%esp
  80048e:	57                   	push   %edi
  80048f:	53                   	push   %ebx
  800490:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800493:	4e                   	dec    %esi
  800494:	83 c4 10             	add    $0x10,%esp
  800497:	85 f6                	test   %esi,%esi
  800499:	7f f0                	jg     80048b <vprintfmt+0x1c6>
  80049b:	8b 75 dc             	mov    -0x24(%ebp),%esi
  80049e:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004a5:	8b 55 d0             	mov    -0x30(%ebp),%edx
  8004a8:	0f be 02             	movsbl (%edx),%eax
  8004ab:	85 c0                	test   %eax,%eax
  8004ad:	75 47                	jne    8004f6 <vprintfmt+0x231>
  8004af:	eb 37                	jmp    8004e8 <vprintfmt+0x223>
				if (altflag && (ch < ' ' || ch > '~'))
  8004b1:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004b5:	74 16                	je     8004cd <vprintfmt+0x208>
  8004b7:	8d 50 e0             	lea    -0x20(%eax),%edx
  8004ba:	83 fa 5e             	cmp    $0x5e,%edx
  8004bd:	76 0e                	jbe    8004cd <vprintfmt+0x208>
					putch('?', putdat);
  8004bf:	83 ec 08             	sub    $0x8,%esp
  8004c2:	57                   	push   %edi
  8004c3:	6a 3f                	push   $0x3f
  8004c5:	ff 55 08             	call   *0x8(%ebp)
  8004c8:	83 c4 10             	add    $0x10,%esp
  8004cb:	eb 0b                	jmp    8004d8 <vprintfmt+0x213>
				else
					putch(ch, putdat);
  8004cd:	83 ec 08             	sub    $0x8,%esp
  8004d0:	57                   	push   %edi
  8004d1:	50                   	push   %eax
  8004d2:	ff 55 08             	call   *0x8(%ebp)
  8004d5:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004d8:	ff 4d e4             	decl   -0x1c(%ebp)
  8004db:	0f be 03             	movsbl (%ebx),%eax
  8004de:	85 c0                	test   %eax,%eax
  8004e0:	74 03                	je     8004e5 <vprintfmt+0x220>
  8004e2:	43                   	inc    %ebx
  8004e3:	eb 1b                	jmp    800500 <vprintfmt+0x23b>
  8004e5:	8b 75 dc             	mov    -0x24(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8004e8:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8004ec:	7f 1e                	jg     80050c <vprintfmt+0x247>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004ee:	8b 75 d8             	mov    -0x28(%ebp),%esi
  8004f1:	e9 f3 fd ff ff       	jmp    8002e9 <vprintfmt+0x24>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004f6:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  8004f9:	43                   	inc    %ebx
  8004fa:	89 75 dc             	mov    %esi,-0x24(%ebp)
  8004fd:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  800500:	85 f6                	test   %esi,%esi
  800502:	78 ad                	js     8004b1 <vprintfmt+0x1ec>
  800504:	4e                   	dec    %esi
  800505:	79 aa                	jns    8004b1 <vprintfmt+0x1ec>
  800507:	8b 75 dc             	mov    -0x24(%ebp),%esi
  80050a:	eb dc                	jmp    8004e8 <vprintfmt+0x223>
  80050c:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80050f:	83 ec 08             	sub    $0x8,%esp
  800512:	57                   	push   %edi
  800513:	6a 20                	push   $0x20
  800515:	ff 55 08             	call   *0x8(%ebp)
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800518:	4b                   	dec    %ebx
  800519:	83 c4 10             	add    $0x10,%esp
  80051c:	85 db                	test   %ebx,%ebx
  80051e:	7f ef                	jg     80050f <vprintfmt+0x24a>
  800520:	e9 c4 fd ff ff       	jmp    8002e9 <vprintfmt+0x24>
  800525:	89 5d d8             	mov    %ebx,-0x28(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800528:	89 ca                	mov    %ecx,%edx
  80052a:	8d 45 14             	lea    0x14(%ebp),%eax
  80052d:	e8 2a fd ff ff       	call   80025c <getint>
  800532:	89 c3                	mov    %eax,%ebx
  800534:	89 d6                	mov    %edx,%esi
			if ((long long) num < 0) {
  800536:	85 d2                	test   %edx,%edx
  800538:	78 0a                	js     800544 <vprintfmt+0x27f>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80053a:	b8 0a 00 00 00       	mov    $0xa,%eax
  80053f:	e9 b0 00 00 00       	jmp    8005f4 <vprintfmt+0x32f>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  800544:	83 ec 08             	sub    $0x8,%esp
  800547:	57                   	push   %edi
  800548:	6a 2d                	push   $0x2d
  80054a:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  80054d:	f7 db                	neg    %ebx
  80054f:	83 d6 00             	adc    $0x0,%esi
  800552:	f7 de                	neg    %esi
  800554:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800557:	b8 0a 00 00 00       	mov    $0xa,%eax
  80055c:	e9 93 00 00 00       	jmp    8005f4 <vprintfmt+0x32f>
  800561:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800564:	89 ca                	mov    %ecx,%edx
  800566:	8d 45 14             	lea    0x14(%ebp),%eax
  800569:	e8 b4 fc ff ff       	call   800222 <getuint>
  80056e:	89 c3                	mov    %eax,%ebx
  800570:	89 d6                	mov    %edx,%esi
			base = 10;
  800572:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  800577:	eb 7b                	jmp    8005f4 <vprintfmt+0x32f>
  800579:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
  80057c:	89 ca                	mov    %ecx,%edx
  80057e:	8d 45 14             	lea    0x14(%ebp),%eax
  800581:	e8 d6 fc ff ff       	call   80025c <getint>
  800586:	89 c3                	mov    %eax,%ebx
  800588:	89 d6                	mov    %edx,%esi
            if ((long long) num < 0) {
  80058a:	85 d2                	test   %edx,%edx
  80058c:	78 07                	js     800595 <vprintfmt+0x2d0>
                putch('-', putdat);
                num = -(long long) num;
            }
            base = 8;
  80058e:	b8 08 00 00 00       	mov    $0x8,%eax
  800593:	eb 5f                	jmp    8005f4 <vprintfmt+0x32f>
		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
            if ((long long) num < 0) {
                putch('-', putdat);
  800595:	83 ec 08             	sub    $0x8,%esp
  800598:	57                   	push   %edi
  800599:	6a 2d                	push   $0x2d
  80059b:	ff 55 08             	call   *0x8(%ebp)
                num = -(long long) num;
  80059e:	f7 db                	neg    %ebx
  8005a0:	83 d6 00             	adc    $0x0,%esi
  8005a3:	f7 de                	neg    %esi
  8005a5:	83 c4 10             	add    $0x10,%esp
            }
            base = 8;
  8005a8:	b8 08 00 00 00       	mov    $0x8,%eax
  8005ad:	eb 45                	jmp    8005f4 <vprintfmt+0x32f>
  8005af:	89 5d d8             	mov    %ebx,-0x28(%ebp)
            goto number;

        // pointer
		case 'p':
			putch('0', putdat);
  8005b2:	83 ec 08             	sub    $0x8,%esp
  8005b5:	57                   	push   %edi
  8005b6:	6a 30                	push   $0x30
  8005b8:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8005bb:	83 c4 08             	add    $0x8,%esp
  8005be:	57                   	push   %edi
  8005bf:	6a 78                	push   $0x78
  8005c1:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8005c4:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c7:	8d 50 04             	lea    0x4(%eax),%edx
  8005ca:	89 55 14             	mov    %edx,0x14(%ebp)

        // pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8005cd:	8b 18                	mov    (%eax),%ebx
  8005cf:	be 00 00 00 00       	mov    $0x0,%esi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8005d4:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8005d7:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8005dc:	eb 16                	jmp    8005f4 <vprintfmt+0x32f>
  8005de:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8005e1:	89 ca                	mov    %ecx,%edx
  8005e3:	8d 45 14             	lea    0x14(%ebp),%eax
  8005e6:	e8 37 fc ff ff       	call   800222 <getuint>
  8005eb:	89 c3                	mov    %eax,%ebx
  8005ed:	89 d6                	mov    %edx,%esi
			base = 16;
  8005ef:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  8005f4:	83 ec 0c             	sub    $0xc,%esp
  8005f7:	0f be 55 dc          	movsbl -0x24(%ebp),%edx
  8005fb:	52                   	push   %edx
  8005fc:	ff 75 e4             	pushl  -0x1c(%ebp)
  8005ff:	50                   	push   %eax
  800600:	56                   	push   %esi
  800601:	53                   	push   %ebx
  800602:	89 fa                	mov    %edi,%edx
  800604:	8b 45 08             	mov    0x8(%ebp),%eax
  800607:	e8 68 fb ff ff       	call   800174 <printnum>
			break;
  80060c:	83 c4 20             	add    $0x20,%esp
  80060f:	8b 75 d8             	mov    -0x28(%ebp),%esi
  800612:	e9 d2 fc ff ff       	jmp    8002e9 <vprintfmt+0x24>
  800617:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80061a:	83 ec 08             	sub    $0x8,%esp
  80061d:	57                   	push   %edi
  80061e:	52                   	push   %edx
  80061f:	ff 55 08             	call   *0x8(%ebp)
			break;
  800622:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800625:	8b 75 d8             	mov    -0x28(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800628:	e9 bc fc ff ff       	jmp    8002e9 <vprintfmt+0x24>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80062d:	83 ec 08             	sub    $0x8,%esp
  800630:	57                   	push   %edi
  800631:	6a 25                	push   $0x25
  800633:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800636:	83 c4 10             	add    $0x10,%esp
  800639:	eb 02                	jmp    80063d <vprintfmt+0x378>
  80063b:	89 c6                	mov    %eax,%esi
  80063d:	8d 46 ff             	lea    -0x1(%esi),%eax
  800640:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800644:	75 f5                	jne    80063b <vprintfmt+0x376>
  800646:	e9 9e fc ff ff       	jmp    8002e9 <vprintfmt+0x24>
				/* do nothing */;
			break;
		}
	}
}
  80064b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80064e:	5b                   	pop    %ebx
  80064f:	5e                   	pop    %esi
  800650:	5f                   	pop    %edi
  800651:	c9                   	leave  
  800652:	c3                   	ret    

00800653 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800653:	55                   	push   %ebp
  800654:	89 e5                	mov    %esp,%ebp
  800656:	83 ec 18             	sub    $0x18,%esp
  800659:	8b 45 08             	mov    0x8(%ebp),%eax
  80065c:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80065f:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800662:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800666:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800669:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800670:	85 c0                	test   %eax,%eax
  800672:	74 26                	je     80069a <vsnprintf+0x47>
  800674:	85 d2                	test   %edx,%edx
  800676:	7e 29                	jle    8006a1 <vsnprintf+0x4e>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800678:	ff 75 14             	pushl  0x14(%ebp)
  80067b:	ff 75 10             	pushl  0x10(%ebp)
  80067e:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800681:	50                   	push   %eax
  800682:	68 8e 02 80 00       	push   $0x80028e
  800687:	e8 39 fc ff ff       	call   8002c5 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80068c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80068f:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800692:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800695:	83 c4 10             	add    $0x10,%esp
  800698:	eb 0c                	jmp    8006a6 <vsnprintf+0x53>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80069a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80069f:	eb 05                	jmp    8006a6 <vsnprintf+0x53>
  8006a1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8006a6:	c9                   	leave  
  8006a7:	c3                   	ret    

008006a8 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8006a8:	55                   	push   %ebp
  8006a9:	89 e5                	mov    %esp,%ebp
  8006ab:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8006ae:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8006b1:	50                   	push   %eax
  8006b2:	ff 75 10             	pushl  0x10(%ebp)
  8006b5:	ff 75 0c             	pushl  0xc(%ebp)
  8006b8:	ff 75 08             	pushl  0x8(%ebp)
  8006bb:	e8 93 ff ff ff       	call   800653 <vsnprintf>
	va_end(ap);

	return rc;
}
  8006c0:	c9                   	leave  
  8006c1:	c3                   	ret    
	...

008006c4 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8006c4:	55                   	push   %ebp
  8006c5:	89 e5                	mov    %esp,%ebp
  8006c7:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8006ca:	80 3a 00             	cmpb   $0x0,(%edx)
  8006cd:	74 0e                	je     8006dd <strlen+0x19>
  8006cf:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  8006d4:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8006d5:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8006d9:	75 f9                	jne    8006d4 <strlen+0x10>
  8006db:	eb 05                	jmp    8006e2 <strlen+0x1e>
  8006dd:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  8006e2:	c9                   	leave  
  8006e3:	c3                   	ret    

008006e4 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8006e4:	55                   	push   %ebp
  8006e5:	89 e5                	mov    %esp,%ebp
  8006e7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8006ea:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8006ed:	85 d2                	test   %edx,%edx
  8006ef:	74 17                	je     800708 <strnlen+0x24>
  8006f1:	80 39 00             	cmpb   $0x0,(%ecx)
  8006f4:	74 19                	je     80070f <strnlen+0x2b>
  8006f6:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  8006fb:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8006fc:	39 d0                	cmp    %edx,%eax
  8006fe:	74 14                	je     800714 <strnlen+0x30>
  800700:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800704:	75 f5                	jne    8006fb <strnlen+0x17>
  800706:	eb 0c                	jmp    800714 <strnlen+0x30>
  800708:	b8 00 00 00 00       	mov    $0x0,%eax
  80070d:	eb 05                	jmp    800714 <strnlen+0x30>
  80070f:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800714:	c9                   	leave  
  800715:	c3                   	ret    

00800716 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800716:	55                   	push   %ebp
  800717:	89 e5                	mov    %esp,%ebp
  800719:	53                   	push   %ebx
  80071a:	8b 45 08             	mov    0x8(%ebp),%eax
  80071d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800720:	ba 00 00 00 00       	mov    $0x0,%edx
  800725:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  800728:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  80072b:	42                   	inc    %edx
  80072c:	84 c9                	test   %cl,%cl
  80072e:	75 f5                	jne    800725 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800730:	5b                   	pop    %ebx
  800731:	c9                   	leave  
  800732:	c3                   	ret    

00800733 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800733:	55                   	push   %ebp
  800734:	89 e5                	mov    %esp,%ebp
  800736:	53                   	push   %ebx
  800737:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80073a:	53                   	push   %ebx
  80073b:	e8 84 ff ff ff       	call   8006c4 <strlen>
  800740:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800743:	ff 75 0c             	pushl  0xc(%ebp)
  800746:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  800749:	50                   	push   %eax
  80074a:	e8 c7 ff ff ff       	call   800716 <strcpy>
	return dst;
}
  80074f:	89 d8                	mov    %ebx,%eax
  800751:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800754:	c9                   	leave  
  800755:	c3                   	ret    

00800756 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800756:	55                   	push   %ebp
  800757:	89 e5                	mov    %esp,%ebp
  800759:	56                   	push   %esi
  80075a:	53                   	push   %ebx
  80075b:	8b 45 08             	mov    0x8(%ebp),%eax
  80075e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800761:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800764:	85 f6                	test   %esi,%esi
  800766:	74 15                	je     80077d <strncpy+0x27>
  800768:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  80076d:	8a 1a                	mov    (%edx),%bl
  80076f:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800772:	80 3a 01             	cmpb   $0x1,(%edx)
  800775:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800778:	41                   	inc    %ecx
  800779:	39 ce                	cmp    %ecx,%esi
  80077b:	77 f0                	ja     80076d <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80077d:	5b                   	pop    %ebx
  80077e:	5e                   	pop    %esi
  80077f:	c9                   	leave  
  800780:	c3                   	ret    

00800781 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800781:	55                   	push   %ebp
  800782:	89 e5                	mov    %esp,%ebp
  800784:	57                   	push   %edi
  800785:	56                   	push   %esi
  800786:	53                   	push   %ebx
  800787:	8b 7d 08             	mov    0x8(%ebp),%edi
  80078a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80078d:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800790:	85 f6                	test   %esi,%esi
  800792:	74 32                	je     8007c6 <strlcpy+0x45>
		while (--size > 0 && *src != '\0')
  800794:	83 fe 01             	cmp    $0x1,%esi
  800797:	74 22                	je     8007bb <strlcpy+0x3a>
  800799:	8a 0b                	mov    (%ebx),%cl
  80079b:	84 c9                	test   %cl,%cl
  80079d:	74 20                	je     8007bf <strlcpy+0x3e>
  80079f:	89 f8                	mov    %edi,%eax
  8007a1:	ba 00 00 00 00       	mov    $0x0,%edx
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
  8007a6:	83 ee 02             	sub    $0x2,%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8007a9:	88 08                	mov    %cl,(%eax)
  8007ab:	40                   	inc    %eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8007ac:	39 f2                	cmp    %esi,%edx
  8007ae:	74 11                	je     8007c1 <strlcpy+0x40>
  8007b0:	8a 4c 13 01          	mov    0x1(%ebx,%edx,1),%cl
  8007b4:	42                   	inc    %edx
  8007b5:	84 c9                	test   %cl,%cl
  8007b7:	75 f0                	jne    8007a9 <strlcpy+0x28>
  8007b9:	eb 06                	jmp    8007c1 <strlcpy+0x40>
  8007bb:	89 f8                	mov    %edi,%eax
  8007bd:	eb 02                	jmp    8007c1 <strlcpy+0x40>
  8007bf:	89 f8                	mov    %edi,%eax
			*dst++ = *src++;
		*dst = '\0';
  8007c1:	c6 00 00             	movb   $0x0,(%eax)
  8007c4:	eb 02                	jmp    8007c8 <strlcpy+0x47>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007c6:	89 f8                	mov    %edi,%eax
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
		*dst = '\0';
	}
	return dst - dst_in;
  8007c8:	29 f8                	sub    %edi,%eax
}
  8007ca:	5b                   	pop    %ebx
  8007cb:	5e                   	pop    %esi
  8007cc:	5f                   	pop    %edi
  8007cd:	c9                   	leave  
  8007ce:	c3                   	ret    

008007cf <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8007cf:	55                   	push   %ebp
  8007d0:	89 e5                	mov    %esp,%ebp
  8007d2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007d5:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8007d8:	8a 01                	mov    (%ecx),%al
  8007da:	84 c0                	test   %al,%al
  8007dc:	74 10                	je     8007ee <strcmp+0x1f>
  8007de:	3a 02                	cmp    (%edx),%al
  8007e0:	75 0c                	jne    8007ee <strcmp+0x1f>
		p++, q++;
  8007e2:	41                   	inc    %ecx
  8007e3:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8007e4:	8a 01                	mov    (%ecx),%al
  8007e6:	84 c0                	test   %al,%al
  8007e8:	74 04                	je     8007ee <strcmp+0x1f>
  8007ea:	3a 02                	cmp    (%edx),%al
  8007ec:	74 f4                	je     8007e2 <strcmp+0x13>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8007ee:	0f b6 c0             	movzbl %al,%eax
  8007f1:	0f b6 12             	movzbl (%edx),%edx
  8007f4:	29 d0                	sub    %edx,%eax
}
  8007f6:	c9                   	leave  
  8007f7:	c3                   	ret    

008007f8 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8007f8:	55                   	push   %ebp
  8007f9:	89 e5                	mov    %esp,%ebp
  8007fb:	53                   	push   %ebx
  8007fc:	8b 55 08             	mov    0x8(%ebp),%edx
  8007ff:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800802:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  800805:	85 c0                	test   %eax,%eax
  800807:	74 1b                	je     800824 <strncmp+0x2c>
  800809:	8a 1a                	mov    (%edx),%bl
  80080b:	84 db                	test   %bl,%bl
  80080d:	74 24                	je     800833 <strncmp+0x3b>
  80080f:	3a 19                	cmp    (%ecx),%bl
  800811:	75 20                	jne    800833 <strncmp+0x3b>
  800813:	48                   	dec    %eax
  800814:	74 15                	je     80082b <strncmp+0x33>
		n--, p++, q++;
  800816:	42                   	inc    %edx
  800817:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800818:	8a 1a                	mov    (%edx),%bl
  80081a:	84 db                	test   %bl,%bl
  80081c:	74 15                	je     800833 <strncmp+0x3b>
  80081e:	3a 19                	cmp    (%ecx),%bl
  800820:	74 f1                	je     800813 <strncmp+0x1b>
  800822:	eb 0f                	jmp    800833 <strncmp+0x3b>
		n--, p++, q++;
	if (n == 0)
		return 0;
  800824:	b8 00 00 00 00       	mov    $0x0,%eax
  800829:	eb 05                	jmp    800830 <strncmp+0x38>
  80082b:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800830:	5b                   	pop    %ebx
  800831:	c9                   	leave  
  800832:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800833:	0f b6 02             	movzbl (%edx),%eax
  800836:	0f b6 11             	movzbl (%ecx),%edx
  800839:	29 d0                	sub    %edx,%eax
  80083b:	eb f3                	jmp    800830 <strncmp+0x38>

0080083d <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80083d:	55                   	push   %ebp
  80083e:	89 e5                	mov    %esp,%ebp
  800840:	8b 45 08             	mov    0x8(%ebp),%eax
  800843:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800846:	8a 10                	mov    (%eax),%dl
  800848:	84 d2                	test   %dl,%dl
  80084a:	74 18                	je     800864 <strchr+0x27>
		if (*s == c)
  80084c:	38 ca                	cmp    %cl,%dl
  80084e:	75 06                	jne    800856 <strchr+0x19>
  800850:	eb 17                	jmp    800869 <strchr+0x2c>
  800852:	38 ca                	cmp    %cl,%dl
  800854:	74 13                	je     800869 <strchr+0x2c>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800856:	40                   	inc    %eax
  800857:	8a 10                	mov    (%eax),%dl
  800859:	84 d2                	test   %dl,%dl
  80085b:	75 f5                	jne    800852 <strchr+0x15>
		if (*s == c)
			return (char *) s;
	return 0;
  80085d:	b8 00 00 00 00       	mov    $0x0,%eax
  800862:	eb 05                	jmp    800869 <strchr+0x2c>
  800864:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800869:	c9                   	leave  
  80086a:	c3                   	ret    

0080086b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80086b:	55                   	push   %ebp
  80086c:	89 e5                	mov    %esp,%ebp
  80086e:	8b 45 08             	mov    0x8(%ebp),%eax
  800871:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800874:	8a 10                	mov    (%eax),%dl
  800876:	84 d2                	test   %dl,%dl
  800878:	74 11                	je     80088b <strfind+0x20>
		if (*s == c)
  80087a:	38 ca                	cmp    %cl,%dl
  80087c:	75 06                	jne    800884 <strfind+0x19>
  80087e:	eb 0b                	jmp    80088b <strfind+0x20>
  800880:	38 ca                	cmp    %cl,%dl
  800882:	74 07                	je     80088b <strfind+0x20>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800884:	40                   	inc    %eax
  800885:	8a 10                	mov    (%eax),%dl
  800887:	84 d2                	test   %dl,%dl
  800889:	75 f5                	jne    800880 <strfind+0x15>
		if (*s == c)
			break;
	return (char *) s;
}
  80088b:	c9                   	leave  
  80088c:	c3                   	ret    

0080088d <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80088d:	55                   	push   %ebp
  80088e:	89 e5                	mov    %esp,%ebp
  800890:	57                   	push   %edi
  800891:	56                   	push   %esi
  800892:	53                   	push   %ebx
  800893:	8b 7d 08             	mov    0x8(%ebp),%edi
  800896:	8b 45 0c             	mov    0xc(%ebp),%eax
  800899:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80089c:	85 c9                	test   %ecx,%ecx
  80089e:	74 30                	je     8008d0 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008a0:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008a6:	75 25                	jne    8008cd <memset+0x40>
  8008a8:	f6 c1 03             	test   $0x3,%cl
  8008ab:	75 20                	jne    8008cd <memset+0x40>
		c &= 0xFF;
  8008ad:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8008b0:	89 d3                	mov    %edx,%ebx
  8008b2:	c1 e3 08             	shl    $0x8,%ebx
  8008b5:	89 d6                	mov    %edx,%esi
  8008b7:	c1 e6 18             	shl    $0x18,%esi
  8008ba:	89 d0                	mov    %edx,%eax
  8008bc:	c1 e0 10             	shl    $0x10,%eax
  8008bf:	09 f0                	or     %esi,%eax
  8008c1:	09 d0                	or     %edx,%eax
  8008c3:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  8008c5:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  8008c8:	fc                   	cld    
  8008c9:	f3 ab                	rep stos %eax,%es:(%edi)
  8008cb:	eb 03                	jmp    8008d0 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8008cd:	fc                   	cld    
  8008ce:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8008d0:	89 f8                	mov    %edi,%eax
  8008d2:	5b                   	pop    %ebx
  8008d3:	5e                   	pop    %esi
  8008d4:	5f                   	pop    %edi
  8008d5:	c9                   	leave  
  8008d6:	c3                   	ret    

008008d7 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8008d7:	55                   	push   %ebp
  8008d8:	89 e5                	mov    %esp,%ebp
  8008da:	57                   	push   %edi
  8008db:	56                   	push   %esi
  8008dc:	8b 45 08             	mov    0x8(%ebp),%eax
  8008df:	8b 75 0c             	mov    0xc(%ebp),%esi
  8008e2:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8008e5:	39 c6                	cmp    %eax,%esi
  8008e7:	73 34                	jae    80091d <memmove+0x46>
  8008e9:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8008ec:	39 d0                	cmp    %edx,%eax
  8008ee:	73 2d                	jae    80091d <memmove+0x46>
		s += n;
		d += n;
  8008f0:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008f3:	f6 c2 03             	test   $0x3,%dl
  8008f6:	75 1b                	jne    800913 <memmove+0x3c>
  8008f8:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008fe:	75 13                	jne    800913 <memmove+0x3c>
  800900:	f6 c1 03             	test   $0x3,%cl
  800903:	75 0e                	jne    800913 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800905:	83 ef 04             	sub    $0x4,%edi
  800908:	8d 72 fc             	lea    -0x4(%edx),%esi
  80090b:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  80090e:	fd                   	std    
  80090f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800911:	eb 07                	jmp    80091a <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800913:	4f                   	dec    %edi
  800914:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800917:	fd                   	std    
  800918:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80091a:	fc                   	cld    
  80091b:	eb 20                	jmp    80093d <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80091d:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800923:	75 13                	jne    800938 <memmove+0x61>
  800925:	a8 03                	test   $0x3,%al
  800927:	75 0f                	jne    800938 <memmove+0x61>
  800929:	f6 c1 03             	test   $0x3,%cl
  80092c:	75 0a                	jne    800938 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  80092e:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800931:	89 c7                	mov    %eax,%edi
  800933:	fc                   	cld    
  800934:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800936:	eb 05                	jmp    80093d <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800938:	89 c7                	mov    %eax,%edi
  80093a:	fc                   	cld    
  80093b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  80093d:	5e                   	pop    %esi
  80093e:	5f                   	pop    %edi
  80093f:	c9                   	leave  
  800940:	c3                   	ret    

00800941 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800941:	55                   	push   %ebp
  800942:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800944:	ff 75 10             	pushl  0x10(%ebp)
  800947:	ff 75 0c             	pushl  0xc(%ebp)
  80094a:	ff 75 08             	pushl  0x8(%ebp)
  80094d:	e8 85 ff ff ff       	call   8008d7 <memmove>
}
  800952:	c9                   	leave  
  800953:	c3                   	ret    

00800954 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800954:	55                   	push   %ebp
  800955:	89 e5                	mov    %esp,%ebp
  800957:	57                   	push   %edi
  800958:	56                   	push   %esi
  800959:	53                   	push   %ebx
  80095a:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80095d:	8b 75 0c             	mov    0xc(%ebp),%esi
  800960:	8b 7d 10             	mov    0x10(%ebp),%edi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800963:	85 ff                	test   %edi,%edi
  800965:	74 32                	je     800999 <memcmp+0x45>
		if (*s1 != *s2)
  800967:	8a 03                	mov    (%ebx),%al
  800969:	8a 0e                	mov    (%esi),%cl
  80096b:	38 c8                	cmp    %cl,%al
  80096d:	74 19                	je     800988 <memcmp+0x34>
  80096f:	eb 0d                	jmp    80097e <memcmp+0x2a>
  800971:	8a 44 13 01          	mov    0x1(%ebx,%edx,1),%al
  800975:	8a 4c 16 01          	mov    0x1(%esi,%edx,1),%cl
  800979:	42                   	inc    %edx
  80097a:	38 c8                	cmp    %cl,%al
  80097c:	74 10                	je     80098e <memcmp+0x3a>
			return (int) *s1 - (int) *s2;
  80097e:	0f b6 c0             	movzbl %al,%eax
  800981:	0f b6 c9             	movzbl %cl,%ecx
  800984:	29 c8                	sub    %ecx,%eax
  800986:	eb 16                	jmp    80099e <memcmp+0x4a>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800988:	4f                   	dec    %edi
  800989:	ba 00 00 00 00       	mov    $0x0,%edx
  80098e:	39 fa                	cmp    %edi,%edx
  800990:	75 df                	jne    800971 <memcmp+0x1d>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800992:	b8 00 00 00 00       	mov    $0x0,%eax
  800997:	eb 05                	jmp    80099e <memcmp+0x4a>
  800999:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80099e:	5b                   	pop    %ebx
  80099f:	5e                   	pop    %esi
  8009a0:	5f                   	pop    %edi
  8009a1:	c9                   	leave  
  8009a2:	c3                   	ret    

008009a3 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009a3:	55                   	push   %ebp
  8009a4:	89 e5                	mov    %esp,%ebp
  8009a6:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  8009a9:	89 c2                	mov    %eax,%edx
  8009ab:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  8009ae:	39 d0                	cmp    %edx,%eax
  8009b0:	73 12                	jae    8009c4 <memfind+0x21>
		if (*(const unsigned char *) s == (unsigned char) c)
  8009b2:	8a 4d 0c             	mov    0xc(%ebp),%cl
  8009b5:	38 08                	cmp    %cl,(%eax)
  8009b7:	75 06                	jne    8009bf <memfind+0x1c>
  8009b9:	eb 09                	jmp    8009c4 <memfind+0x21>
  8009bb:	38 08                	cmp    %cl,(%eax)
  8009bd:	74 05                	je     8009c4 <memfind+0x21>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009bf:	40                   	inc    %eax
  8009c0:	39 c2                	cmp    %eax,%edx
  8009c2:	77 f7                	ja     8009bb <memfind+0x18>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8009c4:	c9                   	leave  
  8009c5:	c3                   	ret    

008009c6 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8009c6:	55                   	push   %ebp
  8009c7:	89 e5                	mov    %esp,%ebp
  8009c9:	57                   	push   %edi
  8009ca:	56                   	push   %esi
  8009cb:	53                   	push   %ebx
  8009cc:	8b 55 08             	mov    0x8(%ebp),%edx
  8009cf:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009d2:	eb 01                	jmp    8009d5 <strtol+0xf>
		s++;
  8009d4:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009d5:	8a 02                	mov    (%edx),%al
  8009d7:	3c 20                	cmp    $0x20,%al
  8009d9:	74 f9                	je     8009d4 <strtol+0xe>
  8009db:	3c 09                	cmp    $0x9,%al
  8009dd:	74 f5                	je     8009d4 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  8009df:	3c 2b                	cmp    $0x2b,%al
  8009e1:	75 08                	jne    8009eb <strtol+0x25>
		s++;
  8009e3:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8009e4:	bf 00 00 00 00       	mov    $0x0,%edi
  8009e9:	eb 13                	jmp    8009fe <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  8009eb:	3c 2d                	cmp    $0x2d,%al
  8009ed:	75 0a                	jne    8009f9 <strtol+0x33>
		s++, neg = 1;
  8009ef:	8d 52 01             	lea    0x1(%edx),%edx
  8009f2:	bf 01 00 00 00       	mov    $0x1,%edi
  8009f7:	eb 05                	jmp    8009fe <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8009f9:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8009fe:	85 db                	test   %ebx,%ebx
  800a00:	74 05                	je     800a07 <strtol+0x41>
  800a02:	83 fb 10             	cmp    $0x10,%ebx
  800a05:	75 28                	jne    800a2f <strtol+0x69>
  800a07:	8a 02                	mov    (%edx),%al
  800a09:	3c 30                	cmp    $0x30,%al
  800a0b:	75 10                	jne    800a1d <strtol+0x57>
  800a0d:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800a11:	75 0a                	jne    800a1d <strtol+0x57>
		s += 2, base = 16;
  800a13:	83 c2 02             	add    $0x2,%edx
  800a16:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a1b:	eb 12                	jmp    800a2f <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800a1d:	85 db                	test   %ebx,%ebx
  800a1f:	75 0e                	jne    800a2f <strtol+0x69>
  800a21:	3c 30                	cmp    $0x30,%al
  800a23:	75 05                	jne    800a2a <strtol+0x64>
		s++, base = 8;
  800a25:	42                   	inc    %edx
  800a26:	b3 08                	mov    $0x8,%bl
  800a28:	eb 05                	jmp    800a2f <strtol+0x69>
	else if (base == 0)
		base = 10;
  800a2a:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800a2f:	b8 00 00 00 00       	mov    $0x0,%eax
  800a34:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a36:	8a 0a                	mov    (%edx),%cl
  800a38:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800a3b:	80 fb 09             	cmp    $0x9,%bl
  800a3e:	77 08                	ja     800a48 <strtol+0x82>
			dig = *s - '0';
  800a40:	0f be c9             	movsbl %cl,%ecx
  800a43:	83 e9 30             	sub    $0x30,%ecx
  800a46:	eb 1e                	jmp    800a66 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800a48:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800a4b:	80 fb 19             	cmp    $0x19,%bl
  800a4e:	77 08                	ja     800a58 <strtol+0x92>
			dig = *s - 'a' + 10;
  800a50:	0f be c9             	movsbl %cl,%ecx
  800a53:	83 e9 57             	sub    $0x57,%ecx
  800a56:	eb 0e                	jmp    800a66 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800a58:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800a5b:	80 fb 19             	cmp    $0x19,%bl
  800a5e:	77 13                	ja     800a73 <strtol+0xad>
			dig = *s - 'A' + 10;
  800a60:	0f be c9             	movsbl %cl,%ecx
  800a63:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800a66:	39 f1                	cmp    %esi,%ecx
  800a68:	7d 0d                	jge    800a77 <strtol+0xb1>
			break;
		s++, val = (val * base) + dig;
  800a6a:	42                   	inc    %edx
  800a6b:	0f af c6             	imul   %esi,%eax
  800a6e:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  800a71:	eb c3                	jmp    800a36 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800a73:	89 c1                	mov    %eax,%ecx
  800a75:	eb 02                	jmp    800a79 <strtol+0xb3>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800a77:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800a79:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a7d:	74 05                	je     800a84 <strtol+0xbe>
		*endptr = (char *) s;
  800a7f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800a82:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800a84:	85 ff                	test   %edi,%edi
  800a86:	74 04                	je     800a8c <strtol+0xc6>
  800a88:	89 c8                	mov    %ecx,%eax
  800a8a:	f7 d8                	neg    %eax
}
  800a8c:	5b                   	pop    %ebx
  800a8d:	5e                   	pop    %esi
  800a8e:	5f                   	pop    %edi
  800a8f:	c9                   	leave  
  800a90:	c3                   	ret    
  800a91:	00 00                	add    %al,(%eax)
	...

00800a94 <syscall>:
	return ret;
}

static int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800a94:	55                   	push   %ebp
  800a95:	89 e5                	mov    %esp,%ebp
  800a97:	57                   	push   %edi
  800a98:	56                   	push   %esi
  800a99:	53                   	push   %ebx
  800a9a:	83 ec 1c             	sub    $0x1c,%esp
  800a9d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800aa0:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800aa3:	89 ca                	mov    %ecx,%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800aa5:	8b 75 14             	mov    0x14(%ebp),%esi
  800aa8:	8b 7d 10             	mov    0x10(%ebp),%edi
  800aab:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800aae:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ab1:	cd 30                	int    $0x30
  800ab3:	89 c2                	mov    %eax,%edx
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ab5:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800ab9:	74 1c                	je     800ad7 <syscall+0x43>
  800abb:	85 c0                	test   %eax,%eax
  800abd:	7e 18                	jle    800ad7 <syscall+0x43>
		panic("syscall %d returned %d (> 0)", num, ret);
  800abf:	83 ec 0c             	sub    $0xc,%esp
  800ac2:	50                   	push   %eax
  800ac3:	ff 75 e4             	pushl  -0x1c(%ebp)
  800ac6:	68 df 20 80 00       	push   $0x8020df
  800acb:	6a 42                	push   $0x42
  800acd:	68 fc 20 80 00       	push   $0x8020fc
  800ad2:	e8 dd 0e 00 00       	call   8019b4 <_panic>

	return ret;
}
  800ad7:	89 d0                	mov    %edx,%eax
  800ad9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800adc:	5b                   	pop    %ebx
  800add:	5e                   	pop    %esi
  800ade:	5f                   	pop    %edi
  800adf:	c9                   	leave  
  800ae0:	c3                   	ret    

00800ae1 <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{	
  800ae1:	55                   	push   %ebp
  800ae2:	89 e5                	mov    %esp,%ebp
  800ae4:	83 ec 08             	sub    $0x8,%esp
	// my_sysenter(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
	// return;
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  800ae7:	6a 00                	push   $0x0
  800ae9:	6a 00                	push   $0x0
  800aeb:	6a 00                	push   $0x0
  800aed:	ff 75 0c             	pushl  0xc(%ebp)
  800af0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800af3:	ba 00 00 00 00       	mov    $0x0,%edx
  800af8:	b8 00 00 00 00       	mov    $0x0,%eax
  800afd:	e8 92 ff ff ff       	call   800a94 <syscall>
  800b02:	83 c4 10             	add    $0x10,%esp
	return;
}
  800b05:	c9                   	leave  
  800b06:	c3                   	ret    

00800b07 <sys_cgetc>:

int
sys_cgetc(void)
{
  800b07:	55                   	push   %ebp
  800b08:	89 e5                	mov    %esp,%ebp
  800b0a:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_cgetc, 0, 0, 0, 0, 0, 0);
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  800b0d:	6a 00                	push   $0x0
  800b0f:	6a 00                	push   $0x0
  800b11:	6a 00                	push   $0x0
  800b13:	6a 00                	push   $0x0
  800b15:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b1a:	ba 00 00 00 00       	mov    $0x0,%edx
  800b1f:	b8 01 00 00 00       	mov    $0x1,%eax
  800b24:	e8 6b ff ff ff       	call   800a94 <syscall>
}
  800b29:	c9                   	leave  
  800b2a:	c3                   	ret    

00800b2b <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b2b:	55                   	push   %ebp
  800b2c:	89 e5                	mov    %esp,%ebp
  800b2e:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  800b31:	6a 00                	push   $0x0
  800b33:	6a 00                	push   $0x0
  800b35:	6a 00                	push   $0x0
  800b37:	6a 00                	push   $0x0
  800b39:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b3c:	ba 01 00 00 00       	mov    $0x1,%edx
  800b41:	b8 03 00 00 00       	mov    $0x3,%eax
  800b46:	e8 49 ff ff ff       	call   800a94 <syscall>
}
  800b4b:	c9                   	leave  
  800b4c:	c3                   	ret    

00800b4d <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b4d:	55                   	push   %ebp
  800b4e:	89 e5                	mov    %esp,%ebp
  800b50:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_getenvid, 0, 0, 0, 0, 0, 0);
	return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  800b53:	6a 00                	push   $0x0
  800b55:	6a 00                	push   $0x0
  800b57:	6a 00                	push   $0x0
  800b59:	6a 00                	push   $0x0
  800b5b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b60:	ba 00 00 00 00       	mov    $0x0,%edx
  800b65:	b8 02 00 00 00       	mov    $0x2,%eax
  800b6a:	e8 25 ff ff ff       	call   800a94 <syscall>
}
  800b6f:	c9                   	leave  
  800b70:	c3                   	ret    

00800b71 <sys_yield>:

void
sys_yield(void)
{
  800b71:	55                   	push   %ebp
  800b72:	89 e5                	mov    %esp,%ebp
  800b74:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  800b77:	6a 00                	push   $0x0
  800b79:	6a 00                	push   $0x0
  800b7b:	6a 00                	push   $0x0
  800b7d:	6a 00                	push   $0x0
  800b7f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b84:	ba 00 00 00 00       	mov    $0x0,%edx
  800b89:	b8 0b 00 00 00       	mov    $0xb,%eax
  800b8e:	e8 01 ff ff ff       	call   800a94 <syscall>
  800b93:	83 c4 10             	add    $0x10,%esp
}
  800b96:	c9                   	leave  
  800b97:	c3                   	ret    

00800b98 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b98:	55                   	push   %ebp
  800b99:	89 e5                	mov    %esp,%ebp
  800b9b:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  800b9e:	6a 00                	push   $0x0
  800ba0:	6a 00                	push   $0x0
  800ba2:	ff 75 10             	pushl  0x10(%ebp)
  800ba5:	ff 75 0c             	pushl  0xc(%ebp)
  800ba8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800bab:	ba 01 00 00 00       	mov    $0x1,%edx
  800bb0:	b8 04 00 00 00       	mov    $0x4,%eax
  800bb5:	e8 da fe ff ff       	call   800a94 <syscall>
}
  800bba:	c9                   	leave  
  800bbb:	c3                   	ret    

00800bbc <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800bbc:	55                   	push   %ebp
  800bbd:	89 e5                	mov    %esp,%ebp
  800bbf:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
  800bc2:	ff 75 18             	pushl  0x18(%ebp)
  800bc5:	ff 75 14             	pushl  0x14(%ebp)
  800bc8:	ff 75 10             	pushl  0x10(%ebp)
  800bcb:	ff 75 0c             	pushl  0xc(%ebp)
  800bce:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800bd1:	ba 01 00 00 00       	mov    $0x1,%edx
  800bd6:	b8 05 00 00 00       	mov    $0x5,%eax
  800bdb:	e8 b4 fe ff ff       	call   800a94 <syscall>
}
  800be0:	c9                   	leave  
  800be1:	c3                   	ret    

00800be2 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800be2:	55                   	push   %ebp
  800be3:	89 e5                	mov    %esp,%ebp
  800be5:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  800be8:	6a 00                	push   $0x0
  800bea:	6a 00                	push   $0x0
  800bec:	6a 00                	push   $0x0
  800bee:	ff 75 0c             	pushl  0xc(%ebp)
  800bf1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800bf4:	ba 01 00 00 00       	mov    $0x1,%edx
  800bf9:	b8 06 00 00 00       	mov    $0x6,%eax
  800bfe:	e8 91 fe ff ff       	call   800a94 <syscall>
}
  800c03:	c9                   	leave  
  800c04:	c3                   	ret    

00800c05 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c05:	55                   	push   %ebp
  800c06:	89 e5                	mov    %esp,%ebp
  800c08:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  800c0b:	6a 00                	push   $0x0
  800c0d:	6a 00                	push   $0x0
  800c0f:	6a 00                	push   $0x0
  800c11:	ff 75 0c             	pushl  0xc(%ebp)
  800c14:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c17:	ba 01 00 00 00       	mov    $0x1,%edx
  800c1c:	b8 08 00 00 00       	mov    $0x8,%eax
  800c21:	e8 6e fe ff ff       	call   800a94 <syscall>
}
  800c26:	c9                   	leave  
  800c27:	c3                   	ret    

00800c28 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800c28:	55                   	push   %ebp
  800c29:	89 e5                	mov    %esp,%ebp
  800c2b:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
  800c2e:	6a 00                	push   $0x0
  800c30:	6a 00                	push   $0x0
  800c32:	6a 00                	push   $0x0
  800c34:	ff 75 0c             	pushl  0xc(%ebp)
  800c37:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c3a:	ba 01 00 00 00       	mov    $0x1,%edx
  800c3f:	b8 09 00 00 00       	mov    $0x9,%eax
  800c44:	e8 4b fe ff ff       	call   800a94 <syscall>
}
  800c49:	c9                   	leave  
  800c4a:	c3                   	ret    

00800c4b <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800c4b:	55                   	push   %ebp
  800c4c:	89 e5                	mov    %esp,%ebp
  800c4e:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  800c51:	6a 00                	push   $0x0
  800c53:	6a 00                	push   $0x0
  800c55:	6a 00                	push   $0x0
  800c57:	ff 75 0c             	pushl  0xc(%ebp)
  800c5a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c5d:	ba 01 00 00 00       	mov    $0x1,%edx
  800c62:	b8 0a 00 00 00       	mov    $0xa,%eax
  800c67:	e8 28 fe ff ff       	call   800a94 <syscall>
}
  800c6c:	c9                   	leave  
  800c6d:	c3                   	ret    

00800c6e <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800c6e:	55                   	push   %ebp
  800c6f:	89 e5                	mov    %esp,%ebp
  800c71:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  800c74:	6a 00                	push   $0x0
  800c76:	ff 75 14             	pushl  0x14(%ebp)
  800c79:	ff 75 10             	pushl  0x10(%ebp)
  800c7c:	ff 75 0c             	pushl  0xc(%ebp)
  800c7f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c82:	ba 00 00 00 00       	mov    $0x0,%edx
  800c87:	b8 0c 00 00 00       	mov    $0xc,%eax
  800c8c:	e8 03 fe ff ff       	call   800a94 <syscall>
}
  800c91:	c9                   	leave  
  800c92:	c3                   	ret    

00800c93 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800c93:	55                   	push   %ebp
  800c94:	89 e5                	mov    %esp,%ebp
  800c96:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  800c99:	6a 00                	push   $0x0
  800c9b:	6a 00                	push   $0x0
  800c9d:	6a 00                	push   $0x0
  800c9f:	6a 00                	push   $0x0
  800ca1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ca4:	ba 01 00 00 00       	mov    $0x1,%edx
  800ca9:	b8 0d 00 00 00       	mov    $0xd,%eax
  800cae:	e8 e1 fd ff ff       	call   800a94 <syscall>
}
  800cb3:	c9                   	leave  
  800cb4:	c3                   	ret    

00800cb5 <sys_set_priority>:

int
sys_set_priority(envid_t envid, uint32_t new_priority)
{
  800cb5:	55                   	push   %ebp
  800cb6:	89 e5                	mov    %esp,%ebp
  800cb8:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_set_priority, 0, envid, new_priority, 0, 0, 0);
  800cbb:	6a 00                	push   $0x0
  800cbd:	6a 00                	push   $0x0
  800cbf:	6a 00                	push   $0x0
  800cc1:	ff 75 0c             	pushl  0xc(%ebp)
  800cc4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800cc7:	ba 00 00 00 00       	mov    $0x0,%edx
  800ccc:	b8 0e 00 00 00       	mov    $0xe,%eax
  800cd1:	e8 be fd ff ff       	call   800a94 <syscall>
}
  800cd6:	c9                   	leave  
  800cd7:	c3                   	ret    

00800cd8 <sys_exec>:

int
sys_exec(uint32_t eip, uint32_t esp, void * ph, uint32_t elf_phnum)
{
  800cd8:	55                   	push   %ebp
  800cd9:	89 e5                	mov    %esp,%ebp
  800cdb:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_exec, 0, eip, esp, (uint32_t)ph, elf_phnum, 0);
  800cde:	6a 00                	push   $0x0
  800ce0:	ff 75 14             	pushl  0x14(%ebp)
  800ce3:	ff 75 10             	pushl  0x10(%ebp)
  800ce6:	ff 75 0c             	pushl  0xc(%ebp)
  800ce9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800cec:	ba 00 00 00 00       	mov    $0x0,%edx
  800cf1:	b8 0f 00 00 00       	mov    $0xf,%eax
  800cf6:	e8 99 fd ff ff       	call   800a94 <syscall>
  800cfb:	c9                   	leave  
  800cfc:	c3                   	ret    
  800cfd:	00 00                	add    %al,(%eax)
	...

00800d00 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800d00:	55                   	push   %ebp
  800d01:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800d03:	8b 45 08             	mov    0x8(%ebp),%eax
  800d06:	05 00 00 00 30       	add    $0x30000000,%eax
  800d0b:	c1 e8 0c             	shr    $0xc,%eax
}
  800d0e:	c9                   	leave  
  800d0f:	c3                   	ret    

00800d10 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800d10:	55                   	push   %ebp
  800d11:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800d13:	ff 75 08             	pushl  0x8(%ebp)
  800d16:	e8 e5 ff ff ff       	call   800d00 <fd2num>
  800d1b:	83 c4 04             	add    $0x4,%esp
  800d1e:	05 20 00 0d 00       	add    $0xd0020,%eax
  800d23:	c1 e0 0c             	shl    $0xc,%eax
}
  800d26:	c9                   	leave  
  800d27:	c3                   	ret    

00800d28 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800d28:	55                   	push   %ebp
  800d29:	89 e5                	mov    %esp,%ebp
  800d2b:	53                   	push   %ebx
  800d2c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800d2f:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  800d34:	a8 01                	test   $0x1,%al
  800d36:	74 34                	je     800d6c <fd_alloc+0x44>
  800d38:	a1 00 00 74 ef       	mov    0xef740000,%eax
  800d3d:	a8 01                	test   $0x1,%al
  800d3f:	74 32                	je     800d73 <fd_alloc+0x4b>
  800d41:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
  800d46:	89 c1                	mov    %eax,%ecx
  800d48:	89 c2                	mov    %eax,%edx
  800d4a:	c1 ea 16             	shr    $0x16,%edx
  800d4d:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800d54:	f6 c2 01             	test   $0x1,%dl
  800d57:	74 1f                	je     800d78 <fd_alloc+0x50>
  800d59:	89 c2                	mov    %eax,%edx
  800d5b:	c1 ea 0c             	shr    $0xc,%edx
  800d5e:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800d65:	f6 c2 01             	test   $0x1,%dl
  800d68:	75 17                	jne    800d81 <fd_alloc+0x59>
  800d6a:	eb 0c                	jmp    800d78 <fd_alloc+0x50>
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  800d6c:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
  800d71:	eb 05                	jmp    800d78 <fd_alloc+0x50>
  800d73:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
  800d78:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  800d7a:	b8 00 00 00 00       	mov    $0x0,%eax
  800d7f:	eb 17                	jmp    800d98 <fd_alloc+0x70>
  800d81:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800d86:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800d8b:	75 b9                	jne    800d46 <fd_alloc+0x1e>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800d8d:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  800d93:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800d98:	5b                   	pop    %ebx
  800d99:	c9                   	leave  
  800d9a:	c3                   	ret    

00800d9b <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800d9b:	55                   	push   %ebp
  800d9c:	89 e5                	mov    %esp,%ebp
  800d9e:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800da1:	83 f8 1f             	cmp    $0x1f,%eax
  800da4:	77 36                	ja     800ddc <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800da6:	05 00 00 0d 00       	add    $0xd0000,%eax
  800dab:	c1 e0 0c             	shl    $0xc,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800dae:	89 c2                	mov    %eax,%edx
  800db0:	c1 ea 16             	shr    $0x16,%edx
  800db3:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800dba:	f6 c2 01             	test   $0x1,%dl
  800dbd:	74 24                	je     800de3 <fd_lookup+0x48>
  800dbf:	89 c2                	mov    %eax,%edx
  800dc1:	c1 ea 0c             	shr    $0xc,%edx
  800dc4:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800dcb:	f6 c2 01             	test   $0x1,%dl
  800dce:	74 1a                	je     800dea <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800dd0:	8b 55 0c             	mov    0xc(%ebp),%edx
  800dd3:	89 02                	mov    %eax,(%edx)
	return 0;
  800dd5:	b8 00 00 00 00       	mov    $0x0,%eax
  800dda:	eb 13                	jmp    800def <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800ddc:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800de1:	eb 0c                	jmp    800def <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800de3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800de8:	eb 05                	jmp    800def <fd_lookup+0x54>
  800dea:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800def:	c9                   	leave  
  800df0:	c3                   	ret    

00800df1 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800df1:	55                   	push   %ebp
  800df2:	89 e5                	mov    %esp,%ebp
  800df4:	53                   	push   %ebx
  800df5:	83 ec 04             	sub    $0x4,%esp
  800df8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800dfb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  800dfe:	39 0d 04 30 80 00    	cmp    %ecx,0x803004
  800e04:	74 0d                	je     800e13 <dev_lookup+0x22>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800e06:	b8 00 00 00 00       	mov    $0x0,%eax
  800e0b:	eb 14                	jmp    800e21 <dev_lookup+0x30>
		if (devtab[i]->dev_id == dev_id) {
  800e0d:	39 0a                	cmp    %ecx,(%edx)
  800e0f:	75 10                	jne    800e21 <dev_lookup+0x30>
  800e11:	eb 05                	jmp    800e18 <dev_lookup+0x27>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800e13:	ba 04 30 80 00       	mov    $0x803004,%edx
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
  800e18:	89 13                	mov    %edx,(%ebx)
			return 0;
  800e1a:	b8 00 00 00 00       	mov    $0x0,%eax
  800e1f:	eb 31                	jmp    800e52 <dev_lookup+0x61>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800e21:	40                   	inc    %eax
  800e22:	8b 14 85 88 21 80 00 	mov    0x802188(,%eax,4),%edx
  800e29:	85 d2                	test   %edx,%edx
  800e2b:	75 e0                	jne    800e0d <dev_lookup+0x1c>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800e2d:	a1 08 40 80 00       	mov    0x804008,%eax
  800e32:	8b 40 48             	mov    0x48(%eax),%eax
  800e35:	83 ec 04             	sub    $0x4,%esp
  800e38:	51                   	push   %ecx
  800e39:	50                   	push   %eax
  800e3a:	68 0c 21 80 00       	push   $0x80210c
  800e3f:	e8 1c f3 ff ff       	call   800160 <cprintf>
	*dev = 0;
  800e44:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  800e4a:	83 c4 10             	add    $0x10,%esp
  800e4d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800e52:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e55:	c9                   	leave  
  800e56:	c3                   	ret    

00800e57 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800e57:	55                   	push   %ebp
  800e58:	89 e5                	mov    %esp,%ebp
  800e5a:	56                   	push   %esi
  800e5b:	53                   	push   %ebx
  800e5c:	83 ec 20             	sub    $0x20,%esp
  800e5f:	8b 75 08             	mov    0x8(%ebp),%esi
  800e62:	8a 45 0c             	mov    0xc(%ebp),%al
  800e65:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800e68:	56                   	push   %esi
  800e69:	e8 92 fe ff ff       	call   800d00 <fd2num>
  800e6e:	8d 55 f4             	lea    -0xc(%ebp),%edx
  800e71:	89 14 24             	mov    %edx,(%esp)
  800e74:	50                   	push   %eax
  800e75:	e8 21 ff ff ff       	call   800d9b <fd_lookup>
  800e7a:	89 c3                	mov    %eax,%ebx
  800e7c:	83 c4 08             	add    $0x8,%esp
  800e7f:	85 c0                	test   %eax,%eax
  800e81:	78 05                	js     800e88 <fd_close+0x31>
	    || fd != fd2)
  800e83:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800e86:	74 0d                	je     800e95 <fd_close+0x3e>
		return (must_exist ? r : 0);
  800e88:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  800e8c:	75 48                	jne    800ed6 <fd_close+0x7f>
  800e8e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e93:	eb 41                	jmp    800ed6 <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800e95:	83 ec 08             	sub    $0x8,%esp
  800e98:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800e9b:	50                   	push   %eax
  800e9c:	ff 36                	pushl  (%esi)
  800e9e:	e8 4e ff ff ff       	call   800df1 <dev_lookup>
  800ea3:	89 c3                	mov    %eax,%ebx
  800ea5:	83 c4 10             	add    $0x10,%esp
  800ea8:	85 c0                	test   %eax,%eax
  800eaa:	78 1c                	js     800ec8 <fd_close+0x71>
		if (dev->dev_close)
  800eac:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800eaf:	8b 40 10             	mov    0x10(%eax),%eax
  800eb2:	85 c0                	test   %eax,%eax
  800eb4:	74 0d                	je     800ec3 <fd_close+0x6c>
			r = (*dev->dev_close)(fd);
  800eb6:	83 ec 0c             	sub    $0xc,%esp
  800eb9:	56                   	push   %esi
  800eba:	ff d0                	call   *%eax
  800ebc:	89 c3                	mov    %eax,%ebx
  800ebe:	83 c4 10             	add    $0x10,%esp
  800ec1:	eb 05                	jmp    800ec8 <fd_close+0x71>
		else
			r = 0;
  800ec3:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800ec8:	83 ec 08             	sub    $0x8,%esp
  800ecb:	56                   	push   %esi
  800ecc:	6a 00                	push   $0x0
  800ece:	e8 0f fd ff ff       	call   800be2 <sys_page_unmap>
	return r;
  800ed3:	83 c4 10             	add    $0x10,%esp
}
  800ed6:	89 d8                	mov    %ebx,%eax
  800ed8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800edb:	5b                   	pop    %ebx
  800edc:	5e                   	pop    %esi
  800edd:	c9                   	leave  
  800ede:	c3                   	ret    

00800edf <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800edf:	55                   	push   %ebp
  800ee0:	89 e5                	mov    %esp,%ebp
  800ee2:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800ee5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ee8:	50                   	push   %eax
  800ee9:	ff 75 08             	pushl  0x8(%ebp)
  800eec:	e8 aa fe ff ff       	call   800d9b <fd_lookup>
  800ef1:	83 c4 08             	add    $0x8,%esp
  800ef4:	85 c0                	test   %eax,%eax
  800ef6:	78 10                	js     800f08 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800ef8:	83 ec 08             	sub    $0x8,%esp
  800efb:	6a 01                	push   $0x1
  800efd:	ff 75 f4             	pushl  -0xc(%ebp)
  800f00:	e8 52 ff ff ff       	call   800e57 <fd_close>
  800f05:	83 c4 10             	add    $0x10,%esp
}
  800f08:	c9                   	leave  
  800f09:	c3                   	ret    

00800f0a <close_all>:

void
close_all(void)
{
  800f0a:	55                   	push   %ebp
  800f0b:	89 e5                	mov    %esp,%ebp
  800f0d:	53                   	push   %ebx
  800f0e:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800f11:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800f16:	83 ec 0c             	sub    $0xc,%esp
  800f19:	53                   	push   %ebx
  800f1a:	e8 c0 ff ff ff       	call   800edf <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800f1f:	43                   	inc    %ebx
  800f20:	83 c4 10             	add    $0x10,%esp
  800f23:	83 fb 20             	cmp    $0x20,%ebx
  800f26:	75 ee                	jne    800f16 <close_all+0xc>
		close(i);
}
  800f28:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f2b:	c9                   	leave  
  800f2c:	c3                   	ret    

00800f2d <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800f2d:	55                   	push   %ebp
  800f2e:	89 e5                	mov    %esp,%ebp
  800f30:	57                   	push   %edi
  800f31:	56                   	push   %esi
  800f32:	53                   	push   %ebx
  800f33:	83 ec 2c             	sub    $0x2c,%esp
  800f36:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800f39:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800f3c:	50                   	push   %eax
  800f3d:	ff 75 08             	pushl  0x8(%ebp)
  800f40:	e8 56 fe ff ff       	call   800d9b <fd_lookup>
  800f45:	89 c3                	mov    %eax,%ebx
  800f47:	83 c4 08             	add    $0x8,%esp
  800f4a:	85 c0                	test   %eax,%eax
  800f4c:	0f 88 c0 00 00 00    	js     801012 <dup+0xe5>
		return r;
	close(newfdnum);
  800f52:	83 ec 0c             	sub    $0xc,%esp
  800f55:	57                   	push   %edi
  800f56:	e8 84 ff ff ff       	call   800edf <close>

	newfd = INDEX2FD(newfdnum);
  800f5b:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  800f61:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  800f64:	83 c4 04             	add    $0x4,%esp
  800f67:	ff 75 e4             	pushl  -0x1c(%ebp)
  800f6a:	e8 a1 fd ff ff       	call   800d10 <fd2data>
  800f6f:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  800f71:	89 34 24             	mov    %esi,(%esp)
  800f74:	e8 97 fd ff ff       	call   800d10 <fd2data>
  800f79:	83 c4 10             	add    $0x10,%esp
  800f7c:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800f7f:	89 d8                	mov    %ebx,%eax
  800f81:	c1 e8 16             	shr    $0x16,%eax
  800f84:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800f8b:	a8 01                	test   $0x1,%al
  800f8d:	74 37                	je     800fc6 <dup+0x99>
  800f8f:	89 d8                	mov    %ebx,%eax
  800f91:	c1 e8 0c             	shr    $0xc,%eax
  800f94:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800f9b:	f6 c2 01             	test   $0x1,%dl
  800f9e:	74 26                	je     800fc6 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  800fa0:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800fa7:	83 ec 0c             	sub    $0xc,%esp
  800faa:	25 07 0e 00 00       	and    $0xe07,%eax
  800faf:	50                   	push   %eax
  800fb0:	ff 75 d4             	pushl  -0x2c(%ebp)
  800fb3:	6a 00                	push   $0x0
  800fb5:	53                   	push   %ebx
  800fb6:	6a 00                	push   $0x0
  800fb8:	e8 ff fb ff ff       	call   800bbc <sys_page_map>
  800fbd:	89 c3                	mov    %eax,%ebx
  800fbf:	83 c4 20             	add    $0x20,%esp
  800fc2:	85 c0                	test   %eax,%eax
  800fc4:	78 2d                	js     800ff3 <dup+0xc6>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800fc6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800fc9:	89 c2                	mov    %eax,%edx
  800fcb:	c1 ea 0c             	shr    $0xc,%edx
  800fce:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800fd5:	83 ec 0c             	sub    $0xc,%esp
  800fd8:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  800fde:	52                   	push   %edx
  800fdf:	56                   	push   %esi
  800fe0:	6a 00                	push   $0x0
  800fe2:	50                   	push   %eax
  800fe3:	6a 00                	push   $0x0
  800fe5:	e8 d2 fb ff ff       	call   800bbc <sys_page_map>
  800fea:	89 c3                	mov    %eax,%ebx
  800fec:	83 c4 20             	add    $0x20,%esp
  800fef:	85 c0                	test   %eax,%eax
  800ff1:	79 1d                	jns    801010 <dup+0xe3>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  800ff3:	83 ec 08             	sub    $0x8,%esp
  800ff6:	56                   	push   %esi
  800ff7:	6a 00                	push   $0x0
  800ff9:	e8 e4 fb ff ff       	call   800be2 <sys_page_unmap>
	sys_page_unmap(0, nva);
  800ffe:	83 c4 08             	add    $0x8,%esp
  801001:	ff 75 d4             	pushl  -0x2c(%ebp)
  801004:	6a 00                	push   $0x0
  801006:	e8 d7 fb ff ff       	call   800be2 <sys_page_unmap>
	return r;
  80100b:	83 c4 10             	add    $0x10,%esp
  80100e:	eb 02                	jmp    801012 <dup+0xe5>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  801010:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  801012:	89 d8                	mov    %ebx,%eax
  801014:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801017:	5b                   	pop    %ebx
  801018:	5e                   	pop    %esi
  801019:	5f                   	pop    %edi
  80101a:	c9                   	leave  
  80101b:	c3                   	ret    

0080101c <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80101c:	55                   	push   %ebp
  80101d:	89 e5                	mov    %esp,%ebp
  80101f:	53                   	push   %ebx
  801020:	83 ec 14             	sub    $0x14,%esp
  801023:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801026:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801029:	50                   	push   %eax
  80102a:	53                   	push   %ebx
  80102b:	e8 6b fd ff ff       	call   800d9b <fd_lookup>
  801030:	83 c4 08             	add    $0x8,%esp
  801033:	85 c0                	test   %eax,%eax
  801035:	78 67                	js     80109e <read+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801037:	83 ec 08             	sub    $0x8,%esp
  80103a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80103d:	50                   	push   %eax
  80103e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801041:	ff 30                	pushl  (%eax)
  801043:	e8 a9 fd ff ff       	call   800df1 <dev_lookup>
  801048:	83 c4 10             	add    $0x10,%esp
  80104b:	85 c0                	test   %eax,%eax
  80104d:	78 4f                	js     80109e <read+0x82>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80104f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801052:	8b 50 08             	mov    0x8(%eax),%edx
  801055:	83 e2 03             	and    $0x3,%edx
  801058:	83 fa 01             	cmp    $0x1,%edx
  80105b:	75 21                	jne    80107e <read+0x62>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80105d:	a1 08 40 80 00       	mov    0x804008,%eax
  801062:	8b 40 48             	mov    0x48(%eax),%eax
  801065:	83 ec 04             	sub    $0x4,%esp
  801068:	53                   	push   %ebx
  801069:	50                   	push   %eax
  80106a:	68 4d 21 80 00       	push   $0x80214d
  80106f:	e8 ec f0 ff ff       	call   800160 <cprintf>
		return -E_INVAL;
  801074:	83 c4 10             	add    $0x10,%esp
  801077:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80107c:	eb 20                	jmp    80109e <read+0x82>
	}
	if (!dev->dev_read)
  80107e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801081:	8b 52 08             	mov    0x8(%edx),%edx
  801084:	85 d2                	test   %edx,%edx
  801086:	74 11                	je     801099 <read+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801088:	83 ec 04             	sub    $0x4,%esp
  80108b:	ff 75 10             	pushl  0x10(%ebp)
  80108e:	ff 75 0c             	pushl  0xc(%ebp)
  801091:	50                   	push   %eax
  801092:	ff d2                	call   *%edx
  801094:	83 c4 10             	add    $0x10,%esp
  801097:	eb 05                	jmp    80109e <read+0x82>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801099:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  80109e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8010a1:	c9                   	leave  
  8010a2:	c3                   	ret    

008010a3 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8010a3:	55                   	push   %ebp
  8010a4:	89 e5                	mov    %esp,%ebp
  8010a6:	57                   	push   %edi
  8010a7:	56                   	push   %esi
  8010a8:	53                   	push   %ebx
  8010a9:	83 ec 0c             	sub    $0xc,%esp
  8010ac:	8b 7d 08             	mov    0x8(%ebp),%edi
  8010af:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8010b2:	85 f6                	test   %esi,%esi
  8010b4:	74 31                	je     8010e7 <readn+0x44>
  8010b6:	b8 00 00 00 00       	mov    $0x0,%eax
  8010bb:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = read(fdnum, (char*)buf + tot, n - tot);
  8010c0:	83 ec 04             	sub    $0x4,%esp
  8010c3:	89 f2                	mov    %esi,%edx
  8010c5:	29 c2                	sub    %eax,%edx
  8010c7:	52                   	push   %edx
  8010c8:	03 45 0c             	add    0xc(%ebp),%eax
  8010cb:	50                   	push   %eax
  8010cc:	57                   	push   %edi
  8010cd:	e8 4a ff ff ff       	call   80101c <read>
		if (m < 0)
  8010d2:	83 c4 10             	add    $0x10,%esp
  8010d5:	85 c0                	test   %eax,%eax
  8010d7:	78 17                	js     8010f0 <readn+0x4d>
			return m;
		if (m == 0)
  8010d9:	85 c0                	test   %eax,%eax
  8010db:	74 11                	je     8010ee <readn+0x4b>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8010dd:	01 c3                	add    %eax,%ebx
  8010df:	89 d8                	mov    %ebx,%eax
  8010e1:	39 f3                	cmp    %esi,%ebx
  8010e3:	72 db                	jb     8010c0 <readn+0x1d>
  8010e5:	eb 09                	jmp    8010f0 <readn+0x4d>
  8010e7:	b8 00 00 00 00       	mov    $0x0,%eax
  8010ec:	eb 02                	jmp    8010f0 <readn+0x4d>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  8010ee:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  8010f0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010f3:	5b                   	pop    %ebx
  8010f4:	5e                   	pop    %esi
  8010f5:	5f                   	pop    %edi
  8010f6:	c9                   	leave  
  8010f7:	c3                   	ret    

008010f8 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8010f8:	55                   	push   %ebp
  8010f9:	89 e5                	mov    %esp,%ebp
  8010fb:	53                   	push   %ebx
  8010fc:	83 ec 14             	sub    $0x14,%esp
  8010ff:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801102:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801105:	50                   	push   %eax
  801106:	53                   	push   %ebx
  801107:	e8 8f fc ff ff       	call   800d9b <fd_lookup>
  80110c:	83 c4 08             	add    $0x8,%esp
  80110f:	85 c0                	test   %eax,%eax
  801111:	78 62                	js     801175 <write+0x7d>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801113:	83 ec 08             	sub    $0x8,%esp
  801116:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801119:	50                   	push   %eax
  80111a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80111d:	ff 30                	pushl  (%eax)
  80111f:	e8 cd fc ff ff       	call   800df1 <dev_lookup>
  801124:	83 c4 10             	add    $0x10,%esp
  801127:	85 c0                	test   %eax,%eax
  801129:	78 4a                	js     801175 <write+0x7d>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80112b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80112e:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801132:	75 21                	jne    801155 <write+0x5d>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801134:	a1 08 40 80 00       	mov    0x804008,%eax
  801139:	8b 40 48             	mov    0x48(%eax),%eax
  80113c:	83 ec 04             	sub    $0x4,%esp
  80113f:	53                   	push   %ebx
  801140:	50                   	push   %eax
  801141:	68 69 21 80 00       	push   $0x802169
  801146:	e8 15 f0 ff ff       	call   800160 <cprintf>
		return -E_INVAL;
  80114b:	83 c4 10             	add    $0x10,%esp
  80114e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801153:	eb 20                	jmp    801175 <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801155:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801158:	8b 52 0c             	mov    0xc(%edx),%edx
  80115b:	85 d2                	test   %edx,%edx
  80115d:	74 11                	je     801170 <write+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80115f:	83 ec 04             	sub    $0x4,%esp
  801162:	ff 75 10             	pushl  0x10(%ebp)
  801165:	ff 75 0c             	pushl  0xc(%ebp)
  801168:	50                   	push   %eax
  801169:	ff d2                	call   *%edx
  80116b:	83 c4 10             	add    $0x10,%esp
  80116e:	eb 05                	jmp    801175 <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801170:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  801175:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801178:	c9                   	leave  
  801179:	c3                   	ret    

0080117a <seek>:

int
seek(int fdnum, off_t offset)
{
  80117a:	55                   	push   %ebp
  80117b:	89 e5                	mov    %esp,%ebp
  80117d:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801180:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801183:	50                   	push   %eax
  801184:	ff 75 08             	pushl  0x8(%ebp)
  801187:	e8 0f fc ff ff       	call   800d9b <fd_lookup>
  80118c:	83 c4 08             	add    $0x8,%esp
  80118f:	85 c0                	test   %eax,%eax
  801191:	78 0e                	js     8011a1 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801193:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801196:	8b 55 0c             	mov    0xc(%ebp),%edx
  801199:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80119c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8011a1:	c9                   	leave  
  8011a2:	c3                   	ret    

008011a3 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8011a3:	55                   	push   %ebp
  8011a4:	89 e5                	mov    %esp,%ebp
  8011a6:	53                   	push   %ebx
  8011a7:	83 ec 14             	sub    $0x14,%esp
  8011aa:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8011ad:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011b0:	50                   	push   %eax
  8011b1:	53                   	push   %ebx
  8011b2:	e8 e4 fb ff ff       	call   800d9b <fd_lookup>
  8011b7:	83 c4 08             	add    $0x8,%esp
  8011ba:	85 c0                	test   %eax,%eax
  8011bc:	78 5f                	js     80121d <ftruncate+0x7a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011be:	83 ec 08             	sub    $0x8,%esp
  8011c1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011c4:	50                   	push   %eax
  8011c5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011c8:	ff 30                	pushl  (%eax)
  8011ca:	e8 22 fc ff ff       	call   800df1 <dev_lookup>
  8011cf:	83 c4 10             	add    $0x10,%esp
  8011d2:	85 c0                	test   %eax,%eax
  8011d4:	78 47                	js     80121d <ftruncate+0x7a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8011d6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011d9:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8011dd:	75 21                	jne    801200 <ftruncate+0x5d>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8011df:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8011e4:	8b 40 48             	mov    0x48(%eax),%eax
  8011e7:	83 ec 04             	sub    $0x4,%esp
  8011ea:	53                   	push   %ebx
  8011eb:	50                   	push   %eax
  8011ec:	68 2c 21 80 00       	push   $0x80212c
  8011f1:	e8 6a ef ff ff       	call   800160 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8011f6:	83 c4 10             	add    $0x10,%esp
  8011f9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8011fe:	eb 1d                	jmp    80121d <ftruncate+0x7a>
	}
	if (!dev->dev_trunc)
  801200:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801203:	8b 52 18             	mov    0x18(%edx),%edx
  801206:	85 d2                	test   %edx,%edx
  801208:	74 0e                	je     801218 <ftruncate+0x75>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80120a:	83 ec 08             	sub    $0x8,%esp
  80120d:	ff 75 0c             	pushl  0xc(%ebp)
  801210:	50                   	push   %eax
  801211:	ff d2                	call   *%edx
  801213:	83 c4 10             	add    $0x10,%esp
  801216:	eb 05                	jmp    80121d <ftruncate+0x7a>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801218:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  80121d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801220:	c9                   	leave  
  801221:	c3                   	ret    

00801222 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801222:	55                   	push   %ebp
  801223:	89 e5                	mov    %esp,%ebp
  801225:	53                   	push   %ebx
  801226:	83 ec 14             	sub    $0x14,%esp
  801229:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80122c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80122f:	50                   	push   %eax
  801230:	ff 75 08             	pushl  0x8(%ebp)
  801233:	e8 63 fb ff ff       	call   800d9b <fd_lookup>
  801238:	83 c4 08             	add    $0x8,%esp
  80123b:	85 c0                	test   %eax,%eax
  80123d:	78 52                	js     801291 <fstat+0x6f>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80123f:	83 ec 08             	sub    $0x8,%esp
  801242:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801245:	50                   	push   %eax
  801246:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801249:	ff 30                	pushl  (%eax)
  80124b:	e8 a1 fb ff ff       	call   800df1 <dev_lookup>
  801250:	83 c4 10             	add    $0x10,%esp
  801253:	85 c0                	test   %eax,%eax
  801255:	78 3a                	js     801291 <fstat+0x6f>
		return r;
	if (!dev->dev_stat)
  801257:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80125a:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80125e:	74 2c                	je     80128c <fstat+0x6a>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801260:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801263:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80126a:	00 00 00 
	stat->st_isdir = 0;
  80126d:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801274:	00 00 00 
	stat->st_dev = dev;
  801277:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80127d:	83 ec 08             	sub    $0x8,%esp
  801280:	53                   	push   %ebx
  801281:	ff 75 f0             	pushl  -0x10(%ebp)
  801284:	ff 50 14             	call   *0x14(%eax)
  801287:	83 c4 10             	add    $0x10,%esp
  80128a:	eb 05                	jmp    801291 <fstat+0x6f>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  80128c:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801291:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801294:	c9                   	leave  
  801295:	c3                   	ret    

00801296 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801296:	55                   	push   %ebp
  801297:	89 e5                	mov    %esp,%ebp
  801299:	56                   	push   %esi
  80129a:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80129b:	83 ec 08             	sub    $0x8,%esp
  80129e:	6a 00                	push   $0x0
  8012a0:	ff 75 08             	pushl  0x8(%ebp)
  8012a3:	e8 78 01 00 00       	call   801420 <open>
  8012a8:	89 c3                	mov    %eax,%ebx
  8012aa:	83 c4 10             	add    $0x10,%esp
  8012ad:	85 c0                	test   %eax,%eax
  8012af:	78 1b                	js     8012cc <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8012b1:	83 ec 08             	sub    $0x8,%esp
  8012b4:	ff 75 0c             	pushl  0xc(%ebp)
  8012b7:	50                   	push   %eax
  8012b8:	e8 65 ff ff ff       	call   801222 <fstat>
  8012bd:	89 c6                	mov    %eax,%esi
	close(fd);
  8012bf:	89 1c 24             	mov    %ebx,(%esp)
  8012c2:	e8 18 fc ff ff       	call   800edf <close>
	return r;
  8012c7:	83 c4 10             	add    $0x10,%esp
  8012ca:	89 f3                	mov    %esi,%ebx
}
  8012cc:	89 d8                	mov    %ebx,%eax
  8012ce:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8012d1:	5b                   	pop    %ebx
  8012d2:	5e                   	pop    %esi
  8012d3:	c9                   	leave  
  8012d4:	c3                   	ret    
  8012d5:	00 00                	add    %al,(%eax)
	...

008012d8 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8012d8:	55                   	push   %ebp
  8012d9:	89 e5                	mov    %esp,%ebp
  8012db:	56                   	push   %esi
  8012dc:	53                   	push   %ebx
  8012dd:	89 c3                	mov    %eax,%ebx
  8012df:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  8012e1:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8012e8:	75 12                	jne    8012fc <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8012ea:	83 ec 0c             	sub    $0xc,%esp
  8012ed:	6a 01                	push   $0x1
  8012ef:	e8 d2 07 00 00       	call   801ac6 <ipc_find_env>
  8012f4:	a3 00 40 80 00       	mov    %eax,0x804000
  8012f9:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8012fc:	6a 07                	push   $0x7
  8012fe:	68 00 50 80 00       	push   $0x805000
  801303:	53                   	push   %ebx
  801304:	ff 35 00 40 80 00    	pushl  0x804000
  80130a:	e8 62 07 00 00       	call   801a71 <ipc_send>
	
	return ipc_recv(NULL, dstva, NULL);
  80130f:	83 c4 0c             	add    $0xc,%esp
  801312:	6a 00                	push   $0x0
  801314:	56                   	push   %esi
  801315:	6a 00                	push   $0x0
  801317:	e8 e0 06 00 00       	call   8019fc <ipc_recv>
}
  80131c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80131f:	5b                   	pop    %ebx
  801320:	5e                   	pop    %esi
  801321:	c9                   	leave  
  801322:	c3                   	ret    

00801323 <devfile_stat>:
}


static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801323:	55                   	push   %ebp
  801324:	89 e5                	mov    %esp,%ebp
  801326:	53                   	push   %ebx
  801327:	83 ec 04             	sub    $0x4,%esp
  80132a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80132d:	8b 45 08             	mov    0x8(%ebp),%eax
  801330:	8b 40 0c             	mov    0xc(%eax),%eax
  801333:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0) {
  801338:	ba 00 00 00 00       	mov    $0x0,%edx
  80133d:	b8 05 00 00 00       	mov    $0x5,%eax
  801342:	e8 91 ff ff ff       	call   8012d8 <fsipc>
  801347:	85 c0                	test   %eax,%eax
  801349:	78 2c                	js     801377 <devfile_stat+0x54>
		return r;
	}
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80134b:	83 ec 08             	sub    $0x8,%esp
  80134e:	68 00 50 80 00       	push   $0x805000
  801353:	53                   	push   %ebx
  801354:	e8 bd f3 ff ff       	call   800716 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801359:	a1 80 50 80 00       	mov    0x805080,%eax
  80135e:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801364:	a1 84 50 80 00       	mov    0x805084,%eax
  801369:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80136f:	83 c4 10             	add    $0x10,%esp
  801372:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801377:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80137a:	c9                   	leave  
  80137b:	c3                   	ret    

0080137c <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80137c:	55                   	push   %ebp
  80137d:	89 e5                	mov    %esp,%ebp
  80137f:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801382:	8b 45 08             	mov    0x8(%ebp),%eax
  801385:	8b 40 0c             	mov    0xc(%eax),%eax
  801388:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80138d:	ba 00 00 00 00       	mov    $0x0,%edx
  801392:	b8 06 00 00 00       	mov    $0x6,%eax
  801397:	e8 3c ff ff ff       	call   8012d8 <fsipc>
}
  80139c:	c9                   	leave  
  80139d:	c3                   	ret    

0080139e <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  80139e:	55                   	push   %ebp
  80139f:	89 e5                	mov    %esp,%ebp
  8013a1:	56                   	push   %esi
  8013a2:	53                   	push   %ebx
  8013a3:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8013a6:	8b 45 08             	mov    0x8(%ebp),%eax
  8013a9:	8b 40 0c             	mov    0xc(%eax),%eax
  8013ac:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8013b1:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8013b7:	ba 00 00 00 00       	mov    $0x0,%edx
  8013bc:	b8 03 00 00 00       	mov    $0x3,%eax
  8013c1:	e8 12 ff ff ff       	call   8012d8 <fsipc>
  8013c6:	89 c3                	mov    %eax,%ebx
  8013c8:	85 c0                	test   %eax,%eax
  8013ca:	78 4b                	js     801417 <devfile_read+0x79>
		return r;
	assert(r <= n);
  8013cc:	39 c6                	cmp    %eax,%esi
  8013ce:	73 16                	jae    8013e6 <devfile_read+0x48>
  8013d0:	68 98 21 80 00       	push   $0x802198
  8013d5:	68 9f 21 80 00       	push   $0x80219f
  8013da:	6a 7d                	push   $0x7d
  8013dc:	68 b4 21 80 00       	push   $0x8021b4
  8013e1:	e8 ce 05 00 00       	call   8019b4 <_panic>
	assert(r <= PGSIZE);
  8013e6:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8013eb:	7e 16                	jle    801403 <devfile_read+0x65>
  8013ed:	68 bf 21 80 00       	push   $0x8021bf
  8013f2:	68 9f 21 80 00       	push   $0x80219f
  8013f7:	6a 7e                	push   $0x7e
  8013f9:	68 b4 21 80 00       	push   $0x8021b4
  8013fe:	e8 b1 05 00 00       	call   8019b4 <_panic>
	memmove(buf, &fsipcbuf, r);
  801403:	83 ec 04             	sub    $0x4,%esp
  801406:	50                   	push   %eax
  801407:	68 00 50 80 00       	push   $0x805000
  80140c:	ff 75 0c             	pushl  0xc(%ebp)
  80140f:	e8 c3 f4 ff ff       	call   8008d7 <memmove>
	return r;
  801414:	83 c4 10             	add    $0x10,%esp
}
  801417:	89 d8                	mov    %ebx,%eax
  801419:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80141c:	5b                   	pop    %ebx
  80141d:	5e                   	pop    %esi
  80141e:	c9                   	leave  
  80141f:	c3                   	ret    

00801420 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801420:	55                   	push   %ebp
  801421:	89 e5                	mov    %esp,%ebp
  801423:	56                   	push   %esi
  801424:	53                   	push   %ebx
  801425:	83 ec 1c             	sub    $0x1c,%esp
  801428:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  80142b:	56                   	push   %esi
  80142c:	e8 93 f2 ff ff       	call   8006c4 <strlen>
  801431:	83 c4 10             	add    $0x10,%esp
  801434:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801439:	7f 65                	jg     8014a0 <open+0x80>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80143b:	83 ec 0c             	sub    $0xc,%esp
  80143e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801441:	50                   	push   %eax
  801442:	e8 e1 f8 ff ff       	call   800d28 <fd_alloc>
  801447:	89 c3                	mov    %eax,%ebx
  801449:	83 c4 10             	add    $0x10,%esp
  80144c:	85 c0                	test   %eax,%eax
  80144e:	78 55                	js     8014a5 <open+0x85>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801450:	83 ec 08             	sub    $0x8,%esp
  801453:	56                   	push   %esi
  801454:	68 00 50 80 00       	push   $0x805000
  801459:	e8 b8 f2 ff ff       	call   800716 <strcpy>
	fsipcbuf.open.req_omode = mode;
  80145e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801461:	a3 00 54 80 00       	mov    %eax,0x805400



	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801466:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801469:	b8 01 00 00 00       	mov    $0x1,%eax
  80146e:	e8 65 fe ff ff       	call   8012d8 <fsipc>
  801473:	89 c3                	mov    %eax,%ebx
  801475:	83 c4 10             	add    $0x10,%esp
  801478:	85 c0                	test   %eax,%eax
  80147a:	79 12                	jns    80148e <open+0x6e>
		fd_close(fd, 0);
  80147c:	83 ec 08             	sub    $0x8,%esp
  80147f:	6a 00                	push   $0x0
  801481:	ff 75 f4             	pushl  -0xc(%ebp)
  801484:	e8 ce f9 ff ff       	call   800e57 <fd_close>
		return r;
  801489:	83 c4 10             	add    $0x10,%esp
  80148c:	eb 17                	jmp    8014a5 <open+0x85>
	}

	return fd2num(fd);
  80148e:	83 ec 0c             	sub    $0xc,%esp
  801491:	ff 75 f4             	pushl  -0xc(%ebp)
  801494:	e8 67 f8 ff ff       	call   800d00 <fd2num>
  801499:	89 c3                	mov    %eax,%ebx
  80149b:	83 c4 10             	add    $0x10,%esp
  80149e:	eb 05                	jmp    8014a5 <open+0x85>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8014a0:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8014a5:	89 d8                	mov    %ebx,%eax
  8014a7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8014aa:	5b                   	pop    %ebx
  8014ab:	5e                   	pop    %esi
  8014ac:	c9                   	leave  
  8014ad:	c3                   	ret    
	...

008014b0 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8014b0:	55                   	push   %ebp
  8014b1:	89 e5                	mov    %esp,%ebp
  8014b3:	56                   	push   %esi
  8014b4:	53                   	push   %ebx
  8014b5:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8014b8:	83 ec 0c             	sub    $0xc,%esp
  8014bb:	ff 75 08             	pushl  0x8(%ebp)
  8014be:	e8 4d f8 ff ff       	call   800d10 <fd2data>
  8014c3:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  8014c5:	83 c4 08             	add    $0x8,%esp
  8014c8:	68 cb 21 80 00       	push   $0x8021cb
  8014cd:	56                   	push   %esi
  8014ce:	e8 43 f2 ff ff       	call   800716 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8014d3:	8b 43 04             	mov    0x4(%ebx),%eax
  8014d6:	2b 03                	sub    (%ebx),%eax
  8014d8:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  8014de:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  8014e5:	00 00 00 
	stat->st_dev = &devpipe;
  8014e8:	c7 86 88 00 00 00 20 	movl   $0x803020,0x88(%esi)
  8014ef:	30 80 00 
	return 0;
}
  8014f2:	b8 00 00 00 00       	mov    $0x0,%eax
  8014f7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8014fa:	5b                   	pop    %ebx
  8014fb:	5e                   	pop    %esi
  8014fc:	c9                   	leave  
  8014fd:	c3                   	ret    

008014fe <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8014fe:	55                   	push   %ebp
  8014ff:	89 e5                	mov    %esp,%ebp
  801501:	53                   	push   %ebx
  801502:	83 ec 0c             	sub    $0xc,%esp
  801505:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801508:	53                   	push   %ebx
  801509:	6a 00                	push   $0x0
  80150b:	e8 d2 f6 ff ff       	call   800be2 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801510:	89 1c 24             	mov    %ebx,(%esp)
  801513:	e8 f8 f7 ff ff       	call   800d10 <fd2data>
  801518:	83 c4 08             	add    $0x8,%esp
  80151b:	50                   	push   %eax
  80151c:	6a 00                	push   $0x0
  80151e:	e8 bf f6 ff ff       	call   800be2 <sys_page_unmap>
}
  801523:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801526:	c9                   	leave  
  801527:	c3                   	ret    

00801528 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801528:	55                   	push   %ebp
  801529:	89 e5                	mov    %esp,%ebp
  80152b:	57                   	push   %edi
  80152c:	56                   	push   %esi
  80152d:	53                   	push   %ebx
  80152e:	83 ec 1c             	sub    $0x1c,%esp
  801531:	89 c7                	mov    %eax,%edi
  801533:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801536:	a1 08 40 80 00       	mov    0x804008,%eax
  80153b:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  80153e:	83 ec 0c             	sub    $0xc,%esp
  801541:	57                   	push   %edi
  801542:	e8 dd 05 00 00       	call   801b24 <pageref>
  801547:	89 c6                	mov    %eax,%esi
  801549:	83 c4 04             	add    $0x4,%esp
  80154c:	ff 75 e4             	pushl  -0x1c(%ebp)
  80154f:	e8 d0 05 00 00       	call   801b24 <pageref>
  801554:	83 c4 10             	add    $0x10,%esp
  801557:	39 c6                	cmp    %eax,%esi
  801559:	0f 94 c0             	sete   %al
  80155c:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  80155f:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801565:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801568:	39 cb                	cmp    %ecx,%ebx
  80156a:	75 08                	jne    801574 <_pipeisclosed+0x4c>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  80156c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80156f:	5b                   	pop    %ebx
  801570:	5e                   	pop    %esi
  801571:	5f                   	pop    %edi
  801572:	c9                   	leave  
  801573:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  801574:	83 f8 01             	cmp    $0x1,%eax
  801577:	75 bd                	jne    801536 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801579:	8b 42 58             	mov    0x58(%edx),%eax
  80157c:	6a 01                	push   $0x1
  80157e:	50                   	push   %eax
  80157f:	53                   	push   %ebx
  801580:	68 d2 21 80 00       	push   $0x8021d2
  801585:	e8 d6 eb ff ff       	call   800160 <cprintf>
  80158a:	83 c4 10             	add    $0x10,%esp
  80158d:	eb a7                	jmp    801536 <_pipeisclosed+0xe>

0080158f <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80158f:	55                   	push   %ebp
  801590:	89 e5                	mov    %esp,%ebp
  801592:	57                   	push   %edi
  801593:	56                   	push   %esi
  801594:	53                   	push   %ebx
  801595:	83 ec 28             	sub    $0x28,%esp
  801598:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  80159b:	56                   	push   %esi
  80159c:	e8 6f f7 ff ff       	call   800d10 <fd2data>
  8015a1:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8015a3:	83 c4 10             	add    $0x10,%esp
  8015a6:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8015aa:	75 4a                	jne    8015f6 <devpipe_write+0x67>
  8015ac:	bf 00 00 00 00       	mov    $0x0,%edi
  8015b1:	eb 56                	jmp    801609 <devpipe_write+0x7a>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  8015b3:	89 da                	mov    %ebx,%edx
  8015b5:	89 f0                	mov    %esi,%eax
  8015b7:	e8 6c ff ff ff       	call   801528 <_pipeisclosed>
  8015bc:	85 c0                	test   %eax,%eax
  8015be:	75 4d                	jne    80160d <devpipe_write+0x7e>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  8015c0:	e8 ac f5 ff ff       	call   800b71 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8015c5:	8b 43 04             	mov    0x4(%ebx),%eax
  8015c8:	8b 13                	mov    (%ebx),%edx
  8015ca:	83 c2 20             	add    $0x20,%edx
  8015cd:	39 d0                	cmp    %edx,%eax
  8015cf:	73 e2                	jae    8015b3 <devpipe_write+0x24>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  8015d1:	89 c2                	mov    %eax,%edx
  8015d3:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  8015d9:	79 05                	jns    8015e0 <devpipe_write+0x51>
  8015db:	4a                   	dec    %edx
  8015dc:	83 ca e0             	or     $0xffffffe0,%edx
  8015df:	42                   	inc    %edx
  8015e0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8015e3:	8a 0c 39             	mov    (%ecx,%edi,1),%cl
  8015e6:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  8015ea:	40                   	inc    %eax
  8015eb:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8015ee:	47                   	inc    %edi
  8015ef:	39 7d 10             	cmp    %edi,0x10(%ebp)
  8015f2:	77 07                	ja     8015fb <devpipe_write+0x6c>
  8015f4:	eb 13                	jmp    801609 <devpipe_write+0x7a>
  8015f6:	bf 00 00 00 00       	mov    $0x0,%edi
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8015fb:	8b 43 04             	mov    0x4(%ebx),%eax
  8015fe:	8b 13                	mov    (%ebx),%edx
  801600:	83 c2 20             	add    $0x20,%edx
  801603:	39 d0                	cmp    %edx,%eax
  801605:	73 ac                	jae    8015b3 <devpipe_write+0x24>
  801607:	eb c8                	jmp    8015d1 <devpipe_write+0x42>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801609:	89 f8                	mov    %edi,%eax
  80160b:	eb 05                	jmp    801612 <devpipe_write+0x83>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80160d:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801612:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801615:	5b                   	pop    %ebx
  801616:	5e                   	pop    %esi
  801617:	5f                   	pop    %edi
  801618:	c9                   	leave  
  801619:	c3                   	ret    

0080161a <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  80161a:	55                   	push   %ebp
  80161b:	89 e5                	mov    %esp,%ebp
  80161d:	57                   	push   %edi
  80161e:	56                   	push   %esi
  80161f:	53                   	push   %ebx
  801620:	83 ec 18             	sub    $0x18,%esp
  801623:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801626:	57                   	push   %edi
  801627:	e8 e4 f6 ff ff       	call   800d10 <fd2data>
  80162c:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80162e:	83 c4 10             	add    $0x10,%esp
  801631:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801635:	75 44                	jne    80167b <devpipe_read+0x61>
  801637:	be 00 00 00 00       	mov    $0x0,%esi
  80163c:	eb 4f                	jmp    80168d <devpipe_read+0x73>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
				return i;
  80163e:	89 f0                	mov    %esi,%eax
  801640:	eb 54                	jmp    801696 <devpipe_read+0x7c>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801642:	89 da                	mov    %ebx,%edx
  801644:	89 f8                	mov    %edi,%eax
  801646:	e8 dd fe ff ff       	call   801528 <_pipeisclosed>
  80164b:	85 c0                	test   %eax,%eax
  80164d:	75 42                	jne    801691 <devpipe_read+0x77>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  80164f:	e8 1d f5 ff ff       	call   800b71 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801654:	8b 03                	mov    (%ebx),%eax
  801656:	3b 43 04             	cmp    0x4(%ebx),%eax
  801659:	74 e7                	je     801642 <devpipe_read+0x28>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  80165b:	25 1f 00 00 80       	and    $0x8000001f,%eax
  801660:	79 05                	jns    801667 <devpipe_read+0x4d>
  801662:	48                   	dec    %eax
  801663:	83 c8 e0             	or     $0xffffffe0,%eax
  801666:	40                   	inc    %eax
  801667:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  80166b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80166e:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  801671:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801673:	46                   	inc    %esi
  801674:	39 75 10             	cmp    %esi,0x10(%ebp)
  801677:	77 07                	ja     801680 <devpipe_read+0x66>
  801679:	eb 12                	jmp    80168d <devpipe_read+0x73>
  80167b:	be 00 00 00 00       	mov    $0x0,%esi
		while (p->p_rpos == p->p_wpos) {
  801680:	8b 03                	mov    (%ebx),%eax
  801682:	3b 43 04             	cmp    0x4(%ebx),%eax
  801685:	75 d4                	jne    80165b <devpipe_read+0x41>
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801687:	85 f6                	test   %esi,%esi
  801689:	75 b3                	jne    80163e <devpipe_read+0x24>
  80168b:	eb b5                	jmp    801642 <devpipe_read+0x28>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  80168d:	89 f0                	mov    %esi,%eax
  80168f:	eb 05                	jmp    801696 <devpipe_read+0x7c>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801691:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801696:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801699:	5b                   	pop    %ebx
  80169a:	5e                   	pop    %esi
  80169b:	5f                   	pop    %edi
  80169c:	c9                   	leave  
  80169d:	c3                   	ret    

0080169e <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  80169e:	55                   	push   %ebp
  80169f:	89 e5                	mov    %esp,%ebp
  8016a1:	57                   	push   %edi
  8016a2:	56                   	push   %esi
  8016a3:	53                   	push   %ebx
  8016a4:	83 ec 28             	sub    $0x28,%esp
  8016a7:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  8016aa:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8016ad:	50                   	push   %eax
  8016ae:	e8 75 f6 ff ff       	call   800d28 <fd_alloc>
  8016b3:	89 c3                	mov    %eax,%ebx
  8016b5:	83 c4 10             	add    $0x10,%esp
  8016b8:	85 c0                	test   %eax,%eax
  8016ba:	0f 88 24 01 00 00    	js     8017e4 <pipe+0x146>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8016c0:	83 ec 04             	sub    $0x4,%esp
  8016c3:	68 07 04 00 00       	push   $0x407
  8016c8:	ff 75 e4             	pushl  -0x1c(%ebp)
  8016cb:	6a 00                	push   $0x0
  8016cd:	e8 c6 f4 ff ff       	call   800b98 <sys_page_alloc>
  8016d2:	89 c3                	mov    %eax,%ebx
  8016d4:	83 c4 10             	add    $0x10,%esp
  8016d7:	85 c0                	test   %eax,%eax
  8016d9:	0f 88 05 01 00 00    	js     8017e4 <pipe+0x146>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  8016df:	83 ec 0c             	sub    $0xc,%esp
  8016e2:	8d 45 e0             	lea    -0x20(%ebp),%eax
  8016e5:	50                   	push   %eax
  8016e6:	e8 3d f6 ff ff       	call   800d28 <fd_alloc>
  8016eb:	89 c3                	mov    %eax,%ebx
  8016ed:	83 c4 10             	add    $0x10,%esp
  8016f0:	85 c0                	test   %eax,%eax
  8016f2:	0f 88 dc 00 00 00    	js     8017d4 <pipe+0x136>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8016f8:	83 ec 04             	sub    $0x4,%esp
  8016fb:	68 07 04 00 00       	push   $0x407
  801700:	ff 75 e0             	pushl  -0x20(%ebp)
  801703:	6a 00                	push   $0x0
  801705:	e8 8e f4 ff ff       	call   800b98 <sys_page_alloc>
  80170a:	89 c3                	mov    %eax,%ebx
  80170c:	83 c4 10             	add    $0x10,%esp
  80170f:	85 c0                	test   %eax,%eax
  801711:	0f 88 bd 00 00 00    	js     8017d4 <pipe+0x136>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801717:	83 ec 0c             	sub    $0xc,%esp
  80171a:	ff 75 e4             	pushl  -0x1c(%ebp)
  80171d:	e8 ee f5 ff ff       	call   800d10 <fd2data>
  801722:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801724:	83 c4 0c             	add    $0xc,%esp
  801727:	68 07 04 00 00       	push   $0x407
  80172c:	50                   	push   %eax
  80172d:	6a 00                	push   $0x0
  80172f:	e8 64 f4 ff ff       	call   800b98 <sys_page_alloc>
  801734:	89 c3                	mov    %eax,%ebx
  801736:	83 c4 10             	add    $0x10,%esp
  801739:	85 c0                	test   %eax,%eax
  80173b:	0f 88 83 00 00 00    	js     8017c4 <pipe+0x126>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801741:	83 ec 0c             	sub    $0xc,%esp
  801744:	ff 75 e0             	pushl  -0x20(%ebp)
  801747:	e8 c4 f5 ff ff       	call   800d10 <fd2data>
  80174c:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801753:	50                   	push   %eax
  801754:	6a 00                	push   $0x0
  801756:	56                   	push   %esi
  801757:	6a 00                	push   $0x0
  801759:	e8 5e f4 ff ff       	call   800bbc <sys_page_map>
  80175e:	89 c3                	mov    %eax,%ebx
  801760:	83 c4 20             	add    $0x20,%esp
  801763:	85 c0                	test   %eax,%eax
  801765:	78 4f                	js     8017b6 <pipe+0x118>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801767:	8b 15 20 30 80 00    	mov    0x803020,%edx
  80176d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801770:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801772:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801775:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  80177c:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801782:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801785:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801787:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80178a:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801791:	83 ec 0c             	sub    $0xc,%esp
  801794:	ff 75 e4             	pushl  -0x1c(%ebp)
  801797:	e8 64 f5 ff ff       	call   800d00 <fd2num>
  80179c:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  80179e:	83 c4 04             	add    $0x4,%esp
  8017a1:	ff 75 e0             	pushl  -0x20(%ebp)
  8017a4:	e8 57 f5 ff ff       	call   800d00 <fd2num>
  8017a9:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  8017ac:	83 c4 10             	add    $0x10,%esp
  8017af:	bb 00 00 00 00       	mov    $0x0,%ebx
  8017b4:	eb 2e                	jmp    8017e4 <pipe+0x146>

    err3:
	sys_page_unmap(0, va);
  8017b6:	83 ec 08             	sub    $0x8,%esp
  8017b9:	56                   	push   %esi
  8017ba:	6a 00                	push   $0x0
  8017bc:	e8 21 f4 ff ff       	call   800be2 <sys_page_unmap>
  8017c1:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  8017c4:	83 ec 08             	sub    $0x8,%esp
  8017c7:	ff 75 e0             	pushl  -0x20(%ebp)
  8017ca:	6a 00                	push   $0x0
  8017cc:	e8 11 f4 ff ff       	call   800be2 <sys_page_unmap>
  8017d1:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  8017d4:	83 ec 08             	sub    $0x8,%esp
  8017d7:	ff 75 e4             	pushl  -0x1c(%ebp)
  8017da:	6a 00                	push   $0x0
  8017dc:	e8 01 f4 ff ff       	call   800be2 <sys_page_unmap>
  8017e1:	83 c4 10             	add    $0x10,%esp
    err:
	return r;
}
  8017e4:	89 d8                	mov    %ebx,%eax
  8017e6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8017e9:	5b                   	pop    %ebx
  8017ea:	5e                   	pop    %esi
  8017eb:	5f                   	pop    %edi
  8017ec:	c9                   	leave  
  8017ed:	c3                   	ret    

008017ee <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  8017ee:	55                   	push   %ebp
  8017ef:	89 e5                	mov    %esp,%ebp
  8017f1:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8017f4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017f7:	50                   	push   %eax
  8017f8:	ff 75 08             	pushl  0x8(%ebp)
  8017fb:	e8 9b f5 ff ff       	call   800d9b <fd_lookup>
  801800:	83 c4 10             	add    $0x10,%esp
  801803:	85 c0                	test   %eax,%eax
  801805:	78 18                	js     80181f <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801807:	83 ec 0c             	sub    $0xc,%esp
  80180a:	ff 75 f4             	pushl  -0xc(%ebp)
  80180d:	e8 fe f4 ff ff       	call   800d10 <fd2data>
	return _pipeisclosed(fd, p);
  801812:	89 c2                	mov    %eax,%edx
  801814:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801817:	e8 0c fd ff ff       	call   801528 <_pipeisclosed>
  80181c:	83 c4 10             	add    $0x10,%esp
}
  80181f:	c9                   	leave  
  801820:	c3                   	ret    
  801821:	00 00                	add    %al,(%eax)
	...

00801824 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801824:	55                   	push   %ebp
  801825:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801827:	b8 00 00 00 00       	mov    $0x0,%eax
  80182c:	c9                   	leave  
  80182d:	c3                   	ret    

0080182e <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80182e:	55                   	push   %ebp
  80182f:	89 e5                	mov    %esp,%ebp
  801831:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801834:	68 ea 21 80 00       	push   $0x8021ea
  801839:	ff 75 0c             	pushl  0xc(%ebp)
  80183c:	e8 d5 ee ff ff       	call   800716 <strcpy>
	return 0;
}
  801841:	b8 00 00 00 00       	mov    $0x0,%eax
  801846:	c9                   	leave  
  801847:	c3                   	ret    

00801848 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801848:	55                   	push   %ebp
  801849:	89 e5                	mov    %esp,%ebp
  80184b:	57                   	push   %edi
  80184c:	56                   	push   %esi
  80184d:	53                   	push   %ebx
  80184e:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801854:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801858:	74 45                	je     80189f <devcons_write+0x57>
  80185a:	b8 00 00 00 00       	mov    $0x0,%eax
  80185f:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801864:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  80186a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80186d:	29 c3                	sub    %eax,%ebx
		if (m > sizeof(buf) - 1)
  80186f:	83 fb 7f             	cmp    $0x7f,%ebx
  801872:	76 05                	jbe    801879 <devcons_write+0x31>
			m = sizeof(buf) - 1;
  801874:	bb 7f 00 00 00       	mov    $0x7f,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  801879:	83 ec 04             	sub    $0x4,%esp
  80187c:	53                   	push   %ebx
  80187d:	03 45 0c             	add    0xc(%ebp),%eax
  801880:	50                   	push   %eax
  801881:	57                   	push   %edi
  801882:	e8 50 f0 ff ff       	call   8008d7 <memmove>
		sys_cputs(buf, m);
  801887:	83 c4 08             	add    $0x8,%esp
  80188a:	53                   	push   %ebx
  80188b:	57                   	push   %edi
  80188c:	e8 50 f2 ff ff       	call   800ae1 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801891:	01 de                	add    %ebx,%esi
  801893:	89 f0                	mov    %esi,%eax
  801895:	83 c4 10             	add    $0x10,%esp
  801898:	3b 75 10             	cmp    0x10(%ebp),%esi
  80189b:	72 cd                	jb     80186a <devcons_write+0x22>
  80189d:	eb 05                	jmp    8018a4 <devcons_write+0x5c>
  80189f:	be 00 00 00 00       	mov    $0x0,%esi
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8018a4:	89 f0                	mov    %esi,%eax
  8018a6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8018a9:	5b                   	pop    %ebx
  8018aa:	5e                   	pop    %esi
  8018ab:	5f                   	pop    %edi
  8018ac:	c9                   	leave  
  8018ad:	c3                   	ret    

008018ae <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8018ae:	55                   	push   %ebp
  8018af:	89 e5                	mov    %esp,%ebp
  8018b1:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  8018b4:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8018b8:	75 07                	jne    8018c1 <devcons_read+0x13>
  8018ba:	eb 25                	jmp    8018e1 <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8018bc:	e8 b0 f2 ff ff       	call   800b71 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8018c1:	e8 41 f2 ff ff       	call   800b07 <sys_cgetc>
  8018c6:	85 c0                	test   %eax,%eax
  8018c8:	74 f2                	je     8018bc <devcons_read+0xe>
  8018ca:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  8018cc:	85 c0                	test   %eax,%eax
  8018ce:	78 1d                	js     8018ed <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8018d0:	83 f8 04             	cmp    $0x4,%eax
  8018d3:	74 13                	je     8018e8 <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  8018d5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018d8:	88 10                	mov    %dl,(%eax)
	return 1;
  8018da:	b8 01 00 00 00       	mov    $0x1,%eax
  8018df:	eb 0c                	jmp    8018ed <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  8018e1:	b8 00 00 00 00       	mov    $0x0,%eax
  8018e6:	eb 05                	jmp    8018ed <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8018e8:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8018ed:	c9                   	leave  
  8018ee:	c3                   	ret    

008018ef <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  8018ef:	55                   	push   %ebp
  8018f0:	89 e5                	mov    %esp,%ebp
  8018f2:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8018f5:	8b 45 08             	mov    0x8(%ebp),%eax
  8018f8:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8018fb:	6a 01                	push   $0x1
  8018fd:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801900:	50                   	push   %eax
  801901:	e8 db f1 ff ff       	call   800ae1 <sys_cputs>
  801906:	83 c4 10             	add    $0x10,%esp
}
  801909:	c9                   	leave  
  80190a:	c3                   	ret    

0080190b <getchar>:

int
getchar(void)
{
  80190b:	55                   	push   %ebp
  80190c:	89 e5                	mov    %esp,%ebp
  80190e:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801911:	6a 01                	push   $0x1
  801913:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801916:	50                   	push   %eax
  801917:	6a 00                	push   $0x0
  801919:	e8 fe f6 ff ff       	call   80101c <read>
	if (r < 0)
  80191e:	83 c4 10             	add    $0x10,%esp
  801921:	85 c0                	test   %eax,%eax
  801923:	78 0f                	js     801934 <getchar+0x29>
		return r;
	if (r < 1)
  801925:	85 c0                	test   %eax,%eax
  801927:	7e 06                	jle    80192f <getchar+0x24>
		return -E_EOF;
	return c;
  801929:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  80192d:	eb 05                	jmp    801934 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  80192f:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801934:	c9                   	leave  
  801935:	c3                   	ret    

00801936 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801936:	55                   	push   %ebp
  801937:	89 e5                	mov    %esp,%ebp
  801939:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80193c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80193f:	50                   	push   %eax
  801940:	ff 75 08             	pushl  0x8(%ebp)
  801943:	e8 53 f4 ff ff       	call   800d9b <fd_lookup>
  801948:	83 c4 10             	add    $0x10,%esp
  80194b:	85 c0                	test   %eax,%eax
  80194d:	78 11                	js     801960 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  80194f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801952:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801958:	39 10                	cmp    %edx,(%eax)
  80195a:	0f 94 c0             	sete   %al
  80195d:	0f b6 c0             	movzbl %al,%eax
}
  801960:	c9                   	leave  
  801961:	c3                   	ret    

00801962 <opencons>:

int
opencons(void)
{
  801962:	55                   	push   %ebp
  801963:	89 e5                	mov    %esp,%ebp
  801965:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801968:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80196b:	50                   	push   %eax
  80196c:	e8 b7 f3 ff ff       	call   800d28 <fd_alloc>
  801971:	83 c4 10             	add    $0x10,%esp
  801974:	85 c0                	test   %eax,%eax
  801976:	78 3a                	js     8019b2 <opencons+0x50>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801978:	83 ec 04             	sub    $0x4,%esp
  80197b:	68 07 04 00 00       	push   $0x407
  801980:	ff 75 f4             	pushl  -0xc(%ebp)
  801983:	6a 00                	push   $0x0
  801985:	e8 0e f2 ff ff       	call   800b98 <sys_page_alloc>
  80198a:	83 c4 10             	add    $0x10,%esp
  80198d:	85 c0                	test   %eax,%eax
  80198f:	78 21                	js     8019b2 <opencons+0x50>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801991:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801997:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80199a:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80199c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80199f:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8019a6:	83 ec 0c             	sub    $0xc,%esp
  8019a9:	50                   	push   %eax
  8019aa:	e8 51 f3 ff ff       	call   800d00 <fd2num>
  8019af:	83 c4 10             	add    $0x10,%esp
}
  8019b2:	c9                   	leave  
  8019b3:	c3                   	ret    

008019b4 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8019b4:	55                   	push   %ebp
  8019b5:	89 e5                	mov    %esp,%ebp
  8019b7:	56                   	push   %esi
  8019b8:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8019b9:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8019bc:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  8019c2:	e8 86 f1 ff ff       	call   800b4d <sys_getenvid>
  8019c7:	83 ec 0c             	sub    $0xc,%esp
  8019ca:	ff 75 0c             	pushl  0xc(%ebp)
  8019cd:	ff 75 08             	pushl  0x8(%ebp)
  8019d0:	53                   	push   %ebx
  8019d1:	50                   	push   %eax
  8019d2:	68 f8 21 80 00       	push   $0x8021f8
  8019d7:	e8 84 e7 ff ff       	call   800160 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8019dc:	83 c4 18             	add    $0x18,%esp
  8019df:	56                   	push   %esi
  8019e0:	ff 75 10             	pushl  0x10(%ebp)
  8019e3:	e8 27 e7 ff ff       	call   80010f <vcprintf>
	cprintf("\n");
  8019e8:	c7 04 24 cc 1d 80 00 	movl   $0x801dcc,(%esp)
  8019ef:	e8 6c e7 ff ff       	call   800160 <cprintf>
  8019f4:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8019f7:	cc                   	int3   
  8019f8:	eb fd                	jmp    8019f7 <_panic+0x43>
	...

008019fc <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8019fc:	55                   	push   %ebp
  8019fd:	89 e5                	mov    %esp,%ebp
  8019ff:	56                   	push   %esi
  801a00:	53                   	push   %ebx
  801a01:	8b 75 08             	mov    0x8(%ebp),%esi
  801a04:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a07:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// cprintf("0x%x 0x%x 0x%x\n", (uint32_t)from_env_store, (uint32_t)pg, (uint32_t)perm_store);
	int r;
	if (pg != NULL) {
  801a0a:	85 c0                	test   %eax,%eax
  801a0c:	74 0e                	je     801a1c <ipc_recv+0x20>
		r = sys_ipc_recv(pg);
  801a0e:	83 ec 0c             	sub    $0xc,%esp
  801a11:	50                   	push   %eax
  801a12:	e8 7c f2 ff ff       	call   800c93 <sys_ipc_recv>
  801a17:	83 c4 10             	add    $0x10,%esp
  801a1a:	eb 10                	jmp    801a2c <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv((void *)UTOP);
  801a1c:	83 ec 0c             	sub    $0xc,%esp
  801a1f:	68 00 00 c0 ee       	push   $0xeec00000
  801a24:	e8 6a f2 ff ff       	call   800c93 <sys_ipc_recv>
  801a29:	83 c4 10             	add    $0x10,%esp
	}

	if (r == 0) {
  801a2c:	85 c0                	test   %eax,%eax
  801a2e:	75 26                	jne    801a56 <ipc_recv+0x5a>
		if (from_env_store != NULL) *from_env_store = thisenv->env_ipc_from;
  801a30:	85 f6                	test   %esi,%esi
  801a32:	74 0a                	je     801a3e <ipc_recv+0x42>
  801a34:	a1 08 40 80 00       	mov    0x804008,%eax
  801a39:	8b 40 74             	mov    0x74(%eax),%eax
  801a3c:	89 06                	mov    %eax,(%esi)
		if (perm_store != NULL) *perm_store = thisenv->env_ipc_perm;
  801a3e:	85 db                	test   %ebx,%ebx
  801a40:	74 0a                	je     801a4c <ipc_recv+0x50>
  801a42:	a1 08 40 80 00       	mov    0x804008,%eax
  801a47:	8b 40 78             	mov    0x78(%eax),%eax
  801a4a:	89 03                	mov    %eax,(%ebx)
		return thisenv->env_ipc_value;
  801a4c:	a1 08 40 80 00       	mov    0x804008,%eax
  801a51:	8b 40 70             	mov    0x70(%eax),%eax
  801a54:	eb 14                	jmp    801a6a <ipc_recv+0x6e>
	} else {
		// fails;
		if (from_env_store != NULL) *from_env_store = 0;
  801a56:	85 f6                	test   %esi,%esi
  801a58:	74 06                	je     801a60 <ipc_recv+0x64>
  801a5a:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if (perm_store != NULL) *perm_store = 0;
  801a60:	85 db                	test   %ebx,%ebx
  801a62:	74 06                	je     801a6a <ipc_recv+0x6e>
  801a64:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		return r;
	}
}
  801a6a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a6d:	5b                   	pop    %ebx
  801a6e:	5e                   	pop    %esi
  801a6f:	c9                   	leave  
  801a70:	c3                   	ret    

00801a71 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801a71:	55                   	push   %ebp
  801a72:	89 e5                	mov    %esp,%ebp
  801a74:	57                   	push   %edi
  801a75:	56                   	push   %esi
  801a76:	53                   	push   %ebx
  801a77:	83 ec 0c             	sub    $0xc,%esp
  801a7a:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801a7d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801a80:	8b 75 14             	mov    0x14(%ebp),%esi
	// LAB 4: Your code here.
	// int sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
	int r;
	if (pg == NULL) pg = (void *)UTOP;
  801a83:	85 db                	test   %ebx,%ebx
  801a85:	75 25                	jne    801aac <ipc_send+0x3b>
  801a87:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
  801a8c:	eb 1e                	jmp    801aac <ipc_send+0x3b>
	
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) != 0) {
		if (r == -E_IPC_NOT_RECV) {
  801a8e:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801a91:	75 07                	jne    801a9a <ipc_send+0x29>
			// cprintf("Try Again and Again....\n");
			sys_yield();
  801a93:	e8 d9 f0 ff ff       	call   800b71 <sys_yield>
  801a98:	eb 12                	jmp    801aac <ipc_send+0x3b>
		} else {
			panic("ipc_send error %e\n", r);
  801a9a:	50                   	push   %eax
  801a9b:	68 1c 22 80 00       	push   $0x80221c
  801aa0:	6a 43                	push   $0x43
  801aa2:	68 2f 22 80 00       	push   $0x80222f
  801aa7:	e8 08 ff ff ff       	call   8019b4 <_panic>
	// LAB 4: Your code here.
	// int sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
	int r;
	if (pg == NULL) pg = (void *)UTOP;
	
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) != 0) {
  801aac:	56                   	push   %esi
  801aad:	53                   	push   %ebx
  801aae:	57                   	push   %edi
  801aaf:	ff 75 08             	pushl  0x8(%ebp)
  801ab2:	e8 b7 f1 ff ff       	call   800c6e <sys_ipc_try_send>
  801ab7:	83 c4 10             	add    $0x10,%esp
  801aba:	85 c0                	test   %eax,%eax
  801abc:	75 d0                	jne    801a8e <ipc_send+0x1d>
		} else {
			panic("ipc_send error %e\n", r);
		}
	}
	return;
}
  801abe:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ac1:	5b                   	pop    %ebx
  801ac2:	5e                   	pop    %esi
  801ac3:	5f                   	pop    %edi
  801ac4:	c9                   	leave  
  801ac5:	c3                   	ret    

00801ac6 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801ac6:	55                   	push   %ebp
  801ac7:	89 e5                	mov    %esp,%ebp
  801ac9:	53                   	push   %ebx
  801aca:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  801acd:	39 1d 50 00 c0 ee    	cmp    %ebx,0xeec00050
  801ad3:	74 22                	je     801af7 <ipc_find_env+0x31>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801ad5:	b8 01 00 00 00       	mov    $0x1,%eax
		if (envs[i].env_type == type)
  801ada:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  801ae1:	89 c2                	mov    %eax,%edx
  801ae3:	c1 e2 07             	shl    $0x7,%edx
  801ae6:	29 ca                	sub    %ecx,%edx
  801ae8:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801aee:	8b 52 50             	mov    0x50(%edx),%edx
  801af1:	39 da                	cmp    %ebx,%edx
  801af3:	75 1d                	jne    801b12 <ipc_find_env+0x4c>
  801af5:	eb 05                	jmp    801afc <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801af7:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
			return envs[i].env_id;
  801afc:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  801b03:	c1 e0 07             	shl    $0x7,%eax
  801b06:	29 d0                	sub    %edx,%eax
  801b08:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  801b0d:	8b 40 40             	mov    0x40(%eax),%eax
  801b10:	eb 0c                	jmp    801b1e <ipc_find_env+0x58>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801b12:	40                   	inc    %eax
  801b13:	3d 00 04 00 00       	cmp    $0x400,%eax
  801b18:	75 c0                	jne    801ada <ipc_find_env+0x14>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801b1a:	66 b8 00 00          	mov    $0x0,%ax
}
  801b1e:	5b                   	pop    %ebx
  801b1f:	c9                   	leave  
  801b20:	c3                   	ret    
  801b21:	00 00                	add    %al,(%eax)
	...

00801b24 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801b24:	55                   	push   %ebp
  801b25:	89 e5                	mov    %esp,%ebp
  801b27:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b2a:	89 c2                	mov    %eax,%edx
  801b2c:	c1 ea 16             	shr    $0x16,%edx
  801b2f:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801b36:	f6 c2 01             	test   $0x1,%dl
  801b39:	74 1e                	je     801b59 <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  801b3b:	c1 e8 0c             	shr    $0xc,%eax
  801b3e:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801b45:	a8 01                	test   $0x1,%al
  801b47:	74 17                	je     801b60 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801b49:	c1 e8 0c             	shr    $0xc,%eax
  801b4c:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  801b53:	ef 
  801b54:	0f b7 c0             	movzwl %ax,%eax
  801b57:	eb 0c                	jmp    801b65 <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  801b59:	b8 00 00 00 00       	mov    $0x0,%eax
  801b5e:	eb 05                	jmp    801b65 <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  801b60:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  801b65:	c9                   	leave  
  801b66:	c3                   	ret    
	...

00801b68 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  801b68:	55                   	push   %ebp
  801b69:	89 e5                	mov    %esp,%ebp
  801b6b:	57                   	push   %edi
  801b6c:	56                   	push   %esi
  801b6d:	83 ec 10             	sub    $0x10,%esp
  801b70:	8b 7d 08             	mov    0x8(%ebp),%edi
  801b73:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  801b76:	89 7d f0             	mov    %edi,-0x10(%ebp)
  801b79:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  801b7c:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  801b7f:	8b 45 14             	mov    0x14(%ebp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  801b82:	85 c0                	test   %eax,%eax
  801b84:	75 2e                	jne    801bb4 <__udivdi3+0x4c>
    {
      if (d0 > n1)
  801b86:	39 f1                	cmp    %esi,%ecx
  801b88:	77 5a                	ja     801be4 <__udivdi3+0x7c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  801b8a:	85 c9                	test   %ecx,%ecx
  801b8c:	75 0b                	jne    801b99 <__udivdi3+0x31>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  801b8e:	b8 01 00 00 00       	mov    $0x1,%eax
  801b93:	31 d2                	xor    %edx,%edx
  801b95:	f7 f1                	div    %ecx
  801b97:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  801b99:	31 d2                	xor    %edx,%edx
  801b9b:	89 f0                	mov    %esi,%eax
  801b9d:	f7 f1                	div    %ecx
  801b9f:	89 c6                	mov    %eax,%esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801ba1:	89 f8                	mov    %edi,%eax
  801ba3:	f7 f1                	div    %ecx
  801ba5:	89 c7                	mov    %eax,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801ba7:	89 f8                	mov    %edi,%eax
  801ba9:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801bab:	83 c4 10             	add    $0x10,%esp
  801bae:	5e                   	pop    %esi
  801baf:	5f                   	pop    %edi
  801bb0:	c9                   	leave  
  801bb1:	c3                   	ret    
  801bb2:	66 90                	xchg   %ax,%ax
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801bb4:	39 f0                	cmp    %esi,%eax
  801bb6:	77 1c                	ja     801bd4 <__udivdi3+0x6c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  801bb8:	0f bd f8             	bsr    %eax,%edi
	  if (bm == 0)
  801bbb:	83 f7 1f             	xor    $0x1f,%edi
  801bbe:	75 3c                	jne    801bfc <__udivdi3+0x94>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801bc0:	39 f0                	cmp    %esi,%eax
  801bc2:	0f 82 90 00 00 00    	jb     801c58 <__udivdi3+0xf0>
  801bc8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801bcb:	39 55 f4             	cmp    %edx,-0xc(%ebp)
  801bce:	0f 86 84 00 00 00    	jbe    801c58 <__udivdi3+0xf0>
  801bd4:	31 f6                	xor    %esi,%esi
  801bd6:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801bd8:	89 f8                	mov    %edi,%eax
  801bda:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801bdc:	83 c4 10             	add    $0x10,%esp
  801bdf:	5e                   	pop    %esi
  801be0:	5f                   	pop    %edi
  801be1:	c9                   	leave  
  801be2:	c3                   	ret    
  801be3:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801be4:	89 f2                	mov    %esi,%edx
  801be6:	89 f8                	mov    %edi,%eax
  801be8:	f7 f1                	div    %ecx
  801bea:	89 c7                	mov    %eax,%edi
  801bec:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801bee:	89 f8                	mov    %edi,%eax
  801bf0:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801bf2:	83 c4 10             	add    $0x10,%esp
  801bf5:	5e                   	pop    %esi
  801bf6:	5f                   	pop    %edi
  801bf7:	c9                   	leave  
  801bf8:	c3                   	ret    
  801bf9:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  801bfc:	89 f9                	mov    %edi,%ecx
  801bfe:	d3 e0                	shl    %cl,%eax
  801c00:	89 45 e8             	mov    %eax,-0x18(%ebp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  801c03:	b8 20 00 00 00       	mov    $0x20,%eax
  801c08:	29 f8                	sub    %edi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  801c0a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801c0d:	88 c1                	mov    %al,%cl
  801c0f:	d3 ea                	shr    %cl,%edx
  801c11:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  801c14:	09 ca                	or     %ecx,%edx
  801c16:	89 55 ec             	mov    %edx,-0x14(%ebp)
	      d0 = d0 << bm;
  801c19:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801c1c:	89 f9                	mov    %edi,%ecx
  801c1e:	d3 e2                	shl    %cl,%edx
  801c20:	89 55 f4             	mov    %edx,-0xc(%ebp)
	      n2 = n1 >> b;
  801c23:	89 f2                	mov    %esi,%edx
  801c25:	88 c1                	mov    %al,%cl
  801c27:	d3 ea                	shr    %cl,%edx
  801c29:	89 55 e8             	mov    %edx,-0x18(%ebp)
	      n1 = (n1 << bm) | (n0 >> b);
  801c2c:	89 f2                	mov    %esi,%edx
  801c2e:	89 f9                	mov    %edi,%ecx
  801c30:	d3 e2                	shl    %cl,%edx
  801c32:	8b 75 f0             	mov    -0x10(%ebp),%esi
  801c35:	88 c1                	mov    %al,%cl
  801c37:	d3 ee                	shr    %cl,%esi
  801c39:	09 d6                	or     %edx,%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  801c3b:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  801c3e:	89 f0                	mov    %esi,%eax
  801c40:	89 ca                	mov    %ecx,%edx
  801c42:	f7 75 ec             	divl   -0x14(%ebp)
  801c45:	89 d1                	mov    %edx,%ecx
  801c47:	89 c6                	mov    %eax,%esi
	      umul_ppmm (m1, m0, q0, d0);
  801c49:	f7 65 f4             	mull   -0xc(%ebp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801c4c:	39 d1                	cmp    %edx,%ecx
  801c4e:	72 28                	jb     801c78 <__udivdi3+0x110>
  801c50:	74 1a                	je     801c6c <__udivdi3+0x104>
  801c52:	89 f7                	mov    %esi,%edi
  801c54:	31 f6                	xor    %esi,%esi
  801c56:	eb 80                	jmp    801bd8 <__udivdi3+0x70>
	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  801c58:	31 f6                	xor    %esi,%esi
  801c5a:	bf 01 00 00 00       	mov    $0x1,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801c5f:	89 f8                	mov    %edi,%eax
  801c61:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801c63:	83 c4 10             	add    $0x10,%esp
  801c66:	5e                   	pop    %esi
  801c67:	5f                   	pop    %edi
  801c68:	c9                   	leave  
  801c69:	c3                   	ret    
  801c6a:	66 90                	xchg   %ax,%ax

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  801c6c:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801c6f:	89 f9                	mov    %edi,%ecx
  801c71:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801c73:	39 c2                	cmp    %eax,%edx
  801c75:	73 db                	jae    801c52 <__udivdi3+0xea>
  801c77:	90                   	nop
		{
		  q0--;
  801c78:	8d 7e ff             	lea    -0x1(%esi),%edi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  801c7b:	31 f6                	xor    %esi,%esi
  801c7d:	e9 56 ff ff ff       	jmp    801bd8 <__udivdi3+0x70>
	...

00801c84 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  801c84:	55                   	push   %ebp
  801c85:	89 e5                	mov    %esp,%ebp
  801c87:	57                   	push   %edi
  801c88:	56                   	push   %esi
  801c89:	83 ec 20             	sub    $0x20,%esp
  801c8c:	8b 45 08             	mov    0x8(%ebp),%eax
  801c8f:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  801c92:	89 45 e8             	mov    %eax,-0x18(%ebp)
  801c95:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  801c98:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  801c9b:	8b 7d 14             	mov    0x14(%ebp),%edi
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  801c9e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  n1 = nn.s.high;
  801ca1:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  801ca3:	85 ff                	test   %edi,%edi
  801ca5:	75 15                	jne    801cbc <__umoddi3+0x38>
    {
      if (d0 > n1)
  801ca7:	39 f1                	cmp    %esi,%ecx
  801ca9:	0f 86 99 00 00 00    	jbe    801d48 <__umoddi3+0xc4>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801caf:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  801cb1:	89 d0                	mov    %edx,%eax
  801cb3:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801cb5:	83 c4 20             	add    $0x20,%esp
  801cb8:	5e                   	pop    %esi
  801cb9:	5f                   	pop    %edi
  801cba:	c9                   	leave  
  801cbb:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801cbc:	39 f7                	cmp    %esi,%edi
  801cbe:	0f 87 a4 00 00 00    	ja     801d68 <__umoddi3+0xe4>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  801cc4:	0f bd c7             	bsr    %edi,%eax
	  if (bm == 0)
  801cc7:	83 f0 1f             	xor    $0x1f,%eax
  801cca:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801ccd:	0f 84 a1 00 00 00    	je     801d74 <__umoddi3+0xf0>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  801cd3:	89 f8                	mov    %edi,%eax
  801cd5:	8a 4d ec             	mov    -0x14(%ebp),%cl
  801cd8:	d3 e0                	shl    %cl,%eax
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  801cda:	bf 20 00 00 00       	mov    $0x20,%edi
  801cdf:	2b 7d ec             	sub    -0x14(%ebp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  801ce2:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801ce5:	89 f9                	mov    %edi,%ecx
  801ce7:	d3 ea                	shr    %cl,%edx
  801ce9:	09 c2                	or     %eax,%edx
  801ceb:	89 55 f0             	mov    %edx,-0x10(%ebp)
	      d0 = d0 << bm;
  801cee:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cf1:	8a 4d ec             	mov    -0x14(%ebp),%cl
  801cf4:	d3 e0                	shl    %cl,%eax
  801cf6:	89 45 f4             	mov    %eax,-0xc(%ebp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  801cf9:	89 f2                	mov    %esi,%edx
  801cfb:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  801cfd:	8b 45 e8             	mov    -0x18(%ebp),%eax
  801d00:	d3 e0                	shl    %cl,%eax
  801d02:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  801d05:	8b 45 e8             	mov    -0x18(%ebp),%eax
  801d08:	89 f9                	mov    %edi,%ecx
  801d0a:	d3 e8                	shr    %cl,%eax
  801d0c:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  801d0e:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  801d10:	89 f2                	mov    %esi,%edx
  801d12:	f7 75 f0             	divl   -0x10(%ebp)
  801d15:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  801d17:	f7 65 f4             	mull   -0xc(%ebp)
  801d1a:	89 55 e8             	mov    %edx,-0x18(%ebp)
  801d1d:	89 c1                	mov    %eax,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801d1f:	39 d6                	cmp    %edx,%esi
  801d21:	72 71                	jb     801d94 <__umoddi3+0x110>
  801d23:	74 7f                	je     801da4 <__umoddi3+0x120>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  801d25:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801d28:	29 c8                	sub    %ecx,%eax
  801d2a:	19 d6                	sbb    %edx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  801d2c:	8a 4d ec             	mov    -0x14(%ebp),%cl
  801d2f:	d3 e8                	shr    %cl,%eax
  801d31:	89 f2                	mov    %esi,%edx
  801d33:	89 f9                	mov    %edi,%ecx
  801d35:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  801d37:	09 d0                	or     %edx,%eax
  801d39:	89 f2                	mov    %esi,%edx
  801d3b:	8a 4d ec             	mov    -0x14(%ebp),%cl
  801d3e:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801d40:	83 c4 20             	add    $0x20,%esp
  801d43:	5e                   	pop    %esi
  801d44:	5f                   	pop    %edi
  801d45:	c9                   	leave  
  801d46:	c3                   	ret    
  801d47:	90                   	nop
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  801d48:	85 c9                	test   %ecx,%ecx
  801d4a:	75 0b                	jne    801d57 <__umoddi3+0xd3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  801d4c:	b8 01 00 00 00       	mov    $0x1,%eax
  801d51:	31 d2                	xor    %edx,%edx
  801d53:	f7 f1                	div    %ecx
  801d55:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  801d57:	89 f0                	mov    %esi,%eax
  801d59:	31 d2                	xor    %edx,%edx
  801d5b:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801d5d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801d60:	f7 f1                	div    %ecx
  801d62:	e9 4a ff ff ff       	jmp    801cb1 <__umoddi3+0x2d>
  801d67:	90                   	nop
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  801d68:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801d6a:	83 c4 20             	add    $0x20,%esp
  801d6d:	5e                   	pop    %esi
  801d6e:	5f                   	pop    %edi
  801d6f:	c9                   	leave  
  801d70:	c3                   	ret    
  801d71:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801d74:	39 f7                	cmp    %esi,%edi
  801d76:	72 05                	jb     801d7d <__umoddi3+0xf9>
  801d78:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
  801d7b:	77 0c                	ja     801d89 <__umoddi3+0x105>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  801d7d:	89 f2                	mov    %esi,%edx
  801d7f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801d82:	29 c8                	sub    %ecx,%eax
  801d84:	19 fa                	sbb    %edi,%edx
  801d86:	89 45 f0             	mov    %eax,-0x10(%ebp)

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  801d89:	8b 45 f0             	mov    -0x10(%ebp),%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801d8c:	83 c4 20             	add    $0x20,%esp
  801d8f:	5e                   	pop    %esi
  801d90:	5f                   	pop    %edi
  801d91:	c9                   	leave  
  801d92:	c3                   	ret    
  801d93:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  801d94:	8b 55 e8             	mov    -0x18(%ebp),%edx
  801d97:	89 c1                	mov    %eax,%ecx
  801d99:	2b 4d f4             	sub    -0xc(%ebp),%ecx
  801d9c:	1b 55 f0             	sbb    -0x10(%ebp),%edx
  801d9f:	eb 84                	jmp    801d25 <__umoddi3+0xa1>
  801da1:	8d 76 00             	lea    0x0(%esi),%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801da4:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801da7:	72 eb                	jb     801d94 <__umoddi3+0x110>
  801da9:	89 f2                	mov    %esi,%edx
  801dab:	e9 75 ff ff ff       	jmp    801d25 <__umoddi3+0xa1>
