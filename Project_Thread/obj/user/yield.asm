
obj/user/yield.debug:     file format elf32-i386


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
  80002c:	e8 6b 00 00 00       	call   80009c <libmain>
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
  800037:	53                   	push   %ebx
  800038:	83 ec 0c             	sub    $0xc,%esp
	int i;

	cprintf("Hello, I am environment %08x.\n", thisenv->env_id);
  80003b:	a1 04 40 80 00       	mov    0x804004,%eax
  800040:	8b 40 48             	mov    0x48(%eax),%eax
  800043:	50                   	push   %eax
  800044:	68 20 1e 80 00       	push   $0x801e20
  800049:	e8 46 01 00 00       	call   800194 <cprintf>
  80004e:	83 c4 10             	add    $0x10,%esp
	for (i = 0; i < 5; i++) {
  800051:	bb 00 00 00 00       	mov    $0x0,%ebx
		sys_yield();
  800056:	e8 4a 0b 00 00       	call   800ba5 <sys_yield>
		cprintf("Back in environment %08x, iteration %d.\n",
			thisenv->env_id, i);
  80005b:	a1 04 40 80 00       	mov    0x804004,%eax
	int i;

	cprintf("Hello, I am environment %08x.\n", thisenv->env_id);
	for (i = 0; i < 5; i++) {
		sys_yield();
		cprintf("Back in environment %08x, iteration %d.\n",
  800060:	8b 40 48             	mov    0x48(%eax),%eax
  800063:	83 ec 04             	sub    $0x4,%esp
  800066:	53                   	push   %ebx
  800067:	50                   	push   %eax
  800068:	68 40 1e 80 00       	push   $0x801e40
  80006d:	e8 22 01 00 00       	call   800194 <cprintf>
umain(int argc, char **argv)
{
	int i;

	cprintf("Hello, I am environment %08x.\n", thisenv->env_id);
	for (i = 0; i < 5; i++) {
  800072:	43                   	inc    %ebx
  800073:	83 c4 10             	add    $0x10,%esp
  800076:	83 fb 05             	cmp    $0x5,%ebx
  800079:	75 db                	jne    800056 <umain+0x22>
		sys_yield();
		cprintf("Back in environment %08x, iteration %d.\n",
			thisenv->env_id, i);
	}
	cprintf("All done in environment %08x.\n", thisenv->env_id);
  80007b:	a1 04 40 80 00       	mov    0x804004,%eax
  800080:	8b 40 48             	mov    0x48(%eax),%eax
  800083:	83 ec 08             	sub    $0x8,%esp
  800086:	50                   	push   %eax
  800087:	68 6c 1e 80 00       	push   $0x801e6c
  80008c:	e8 03 01 00 00       	call   800194 <cprintf>
  800091:	83 c4 10             	add    $0x10,%esp
}
  800094:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800097:	c9                   	leave  
  800098:	c3                   	ret    
  800099:	00 00                	add    %al,(%eax)
	...

0080009c <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80009c:	55                   	push   %ebp
  80009d:	89 e5                	mov    %esp,%ebp
  80009f:	56                   	push   %esi
  8000a0:	53                   	push   %ebx
  8000a1:	8b 75 08             	mov    0x8(%ebp),%esi
  8000a4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs + ENVX(sys_getenvid());
  8000a7:	e8 d5 0a 00 00       	call   800b81 <sys_getenvid>
  8000ac:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000b1:	89 c2                	mov    %eax,%edx
  8000b3:	c1 e2 07             	shl    $0x7,%edx
  8000b6:	8d 84 82 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,4),%eax
  8000bd:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000c2:	85 f6                	test   %esi,%esi
  8000c4:	7e 07                	jle    8000cd <libmain+0x31>
		binaryname = argv[0];
  8000c6:	8b 03                	mov    (%ebx),%eax
  8000c8:	a3 00 30 80 00       	mov    %eax,0x803000
	// call user main routine
	umain(argc, argv);
  8000cd:	83 ec 08             	sub    $0x8,%esp
  8000d0:	53                   	push   %ebx
  8000d1:	56                   	push   %esi
  8000d2:	e8 5d ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  8000d7:	e8 0c 00 00 00       	call   8000e8 <exit>
  8000dc:	83 c4 10             	add    $0x10,%esp
}
  8000df:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000e2:	5b                   	pop    %ebx
  8000e3:	5e                   	pop    %esi
  8000e4:	c9                   	leave  
  8000e5:	c3                   	ret    
	...

008000e8 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000e8:	55                   	push   %ebp
  8000e9:	89 e5                	mov    %esp,%ebp
  8000eb:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8000ee:	e8 8f 0e 00 00       	call   800f82 <close_all>
	sys_env_destroy(0);
  8000f3:	83 ec 0c             	sub    $0xc,%esp
  8000f6:	6a 00                	push   $0x0
  8000f8:	e8 62 0a 00 00       	call   800b5f <sys_env_destroy>
  8000fd:	83 c4 10             	add    $0x10,%esp
}
  800100:	c9                   	leave  
  800101:	c3                   	ret    
	...

00800104 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800104:	55                   	push   %ebp
  800105:	89 e5                	mov    %esp,%ebp
  800107:	53                   	push   %ebx
  800108:	83 ec 04             	sub    $0x4,%esp
  80010b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80010e:	8b 03                	mov    (%ebx),%eax
  800110:	8b 55 08             	mov    0x8(%ebp),%edx
  800113:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  800117:	40                   	inc    %eax
  800118:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  80011a:	3d ff 00 00 00       	cmp    $0xff,%eax
  80011f:	75 1a                	jne    80013b <putch+0x37>
		sys_cputs(b->buf, b->idx);
  800121:	83 ec 08             	sub    $0x8,%esp
  800124:	68 ff 00 00 00       	push   $0xff
  800129:	8d 43 08             	lea    0x8(%ebx),%eax
  80012c:	50                   	push   %eax
  80012d:	e8 e3 09 00 00       	call   800b15 <sys_cputs>
		b->idx = 0;
  800132:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800138:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80013b:	ff 43 04             	incl   0x4(%ebx)
}
  80013e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800141:	c9                   	leave  
  800142:	c3                   	ret    

00800143 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800143:	55                   	push   %ebp
  800144:	89 e5                	mov    %esp,%ebp
  800146:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80014c:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800153:	00 00 00 
	b.cnt = 0;
  800156:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80015d:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800160:	ff 75 0c             	pushl  0xc(%ebp)
  800163:	ff 75 08             	pushl  0x8(%ebp)
  800166:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80016c:	50                   	push   %eax
  80016d:	68 04 01 80 00       	push   $0x800104
  800172:	e8 82 01 00 00       	call   8002f9 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800177:	83 c4 08             	add    $0x8,%esp
  80017a:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800180:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800186:	50                   	push   %eax
  800187:	e8 89 09 00 00       	call   800b15 <sys_cputs>

	return b.cnt;
}
  80018c:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800192:	c9                   	leave  
  800193:	c3                   	ret    

00800194 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800194:	55                   	push   %ebp
  800195:	89 e5                	mov    %esp,%ebp
  800197:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80019a:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80019d:	50                   	push   %eax
  80019e:	ff 75 08             	pushl  0x8(%ebp)
  8001a1:	e8 9d ff ff ff       	call   800143 <vcprintf>
	va_end(ap);

	return cnt;
}
  8001a6:	c9                   	leave  
  8001a7:	c3                   	ret    

008001a8 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001a8:	55                   	push   %ebp
  8001a9:	89 e5                	mov    %esp,%ebp
  8001ab:	57                   	push   %edi
  8001ac:	56                   	push   %esi
  8001ad:	53                   	push   %ebx
  8001ae:	83 ec 2c             	sub    $0x2c,%esp
  8001b1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8001b4:	89 d6                	mov    %edx,%esi
  8001b6:	8b 45 08             	mov    0x8(%ebp),%eax
  8001b9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001bc:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001bf:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8001c2:	8b 45 10             	mov    0x10(%ebp),%eax
  8001c5:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8001c8:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001cb:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8001ce:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  8001d5:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
  8001d8:	72 0c                	jb     8001e6 <printnum+0x3e>
  8001da:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  8001dd:	76 07                	jbe    8001e6 <printnum+0x3e>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8001df:	4b                   	dec    %ebx
  8001e0:	85 db                	test   %ebx,%ebx
  8001e2:	7f 31                	jg     800215 <printnum+0x6d>
  8001e4:	eb 3f                	jmp    800225 <printnum+0x7d>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001e6:	83 ec 0c             	sub    $0xc,%esp
  8001e9:	57                   	push   %edi
  8001ea:	4b                   	dec    %ebx
  8001eb:	53                   	push   %ebx
  8001ec:	50                   	push   %eax
  8001ed:	83 ec 08             	sub    $0x8,%esp
  8001f0:	ff 75 d4             	pushl  -0x2c(%ebp)
  8001f3:	ff 75 d0             	pushl  -0x30(%ebp)
  8001f6:	ff 75 dc             	pushl  -0x24(%ebp)
  8001f9:	ff 75 d8             	pushl  -0x28(%ebp)
  8001fc:	e8 cf 19 00 00       	call   801bd0 <__udivdi3>
  800201:	83 c4 18             	add    $0x18,%esp
  800204:	52                   	push   %edx
  800205:	50                   	push   %eax
  800206:	89 f2                	mov    %esi,%edx
  800208:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80020b:	e8 98 ff ff ff       	call   8001a8 <printnum>
  800210:	83 c4 20             	add    $0x20,%esp
  800213:	eb 10                	jmp    800225 <printnum+0x7d>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800215:	83 ec 08             	sub    $0x8,%esp
  800218:	56                   	push   %esi
  800219:	57                   	push   %edi
  80021a:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80021d:	4b                   	dec    %ebx
  80021e:	83 c4 10             	add    $0x10,%esp
  800221:	85 db                	test   %ebx,%ebx
  800223:	7f f0                	jg     800215 <printnum+0x6d>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800225:	83 ec 08             	sub    $0x8,%esp
  800228:	56                   	push   %esi
  800229:	83 ec 04             	sub    $0x4,%esp
  80022c:	ff 75 d4             	pushl  -0x2c(%ebp)
  80022f:	ff 75 d0             	pushl  -0x30(%ebp)
  800232:	ff 75 dc             	pushl  -0x24(%ebp)
  800235:	ff 75 d8             	pushl  -0x28(%ebp)
  800238:	e8 af 1a 00 00       	call   801cec <__umoddi3>
  80023d:	83 c4 14             	add    $0x14,%esp
  800240:	0f be 80 95 1e 80 00 	movsbl 0x801e95(%eax),%eax
  800247:	50                   	push   %eax
  800248:	ff 55 e4             	call   *-0x1c(%ebp)
  80024b:	83 c4 10             	add    $0x10,%esp
}
  80024e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800251:	5b                   	pop    %ebx
  800252:	5e                   	pop    %esi
  800253:	5f                   	pop    %edi
  800254:	c9                   	leave  
  800255:	c3                   	ret    

00800256 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800256:	55                   	push   %ebp
  800257:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800259:	83 fa 01             	cmp    $0x1,%edx
  80025c:	7e 0e                	jle    80026c <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80025e:	8b 10                	mov    (%eax),%edx
  800260:	8d 4a 08             	lea    0x8(%edx),%ecx
  800263:	89 08                	mov    %ecx,(%eax)
  800265:	8b 02                	mov    (%edx),%eax
  800267:	8b 52 04             	mov    0x4(%edx),%edx
  80026a:	eb 22                	jmp    80028e <getuint+0x38>
	else if (lflag)
  80026c:	85 d2                	test   %edx,%edx
  80026e:	74 10                	je     800280 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800270:	8b 10                	mov    (%eax),%edx
  800272:	8d 4a 04             	lea    0x4(%edx),%ecx
  800275:	89 08                	mov    %ecx,(%eax)
  800277:	8b 02                	mov    (%edx),%eax
  800279:	ba 00 00 00 00       	mov    $0x0,%edx
  80027e:	eb 0e                	jmp    80028e <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800280:	8b 10                	mov    (%eax),%edx
  800282:	8d 4a 04             	lea    0x4(%edx),%ecx
  800285:	89 08                	mov    %ecx,(%eax)
  800287:	8b 02                	mov    (%edx),%eax
  800289:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80028e:	c9                   	leave  
  80028f:	c3                   	ret    

00800290 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  800290:	55                   	push   %ebp
  800291:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800293:	83 fa 01             	cmp    $0x1,%edx
  800296:	7e 0e                	jle    8002a6 <getint+0x16>
		return va_arg(*ap, long long);
  800298:	8b 10                	mov    (%eax),%edx
  80029a:	8d 4a 08             	lea    0x8(%edx),%ecx
  80029d:	89 08                	mov    %ecx,(%eax)
  80029f:	8b 02                	mov    (%edx),%eax
  8002a1:	8b 52 04             	mov    0x4(%edx),%edx
  8002a4:	eb 1a                	jmp    8002c0 <getint+0x30>
	else if (lflag)
  8002a6:	85 d2                	test   %edx,%edx
  8002a8:	74 0c                	je     8002b6 <getint+0x26>
		return va_arg(*ap, long);
  8002aa:	8b 10                	mov    (%eax),%edx
  8002ac:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002af:	89 08                	mov    %ecx,(%eax)
  8002b1:	8b 02                	mov    (%edx),%eax
  8002b3:	99                   	cltd   
  8002b4:	eb 0a                	jmp    8002c0 <getint+0x30>
	else
		return va_arg(*ap, int);
  8002b6:	8b 10                	mov    (%eax),%edx
  8002b8:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002bb:	89 08                	mov    %ecx,(%eax)
  8002bd:	8b 02                	mov    (%edx),%eax
  8002bf:	99                   	cltd   
}
  8002c0:	c9                   	leave  
  8002c1:	c3                   	ret    

008002c2 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002c2:	55                   	push   %ebp
  8002c3:	89 e5                	mov    %esp,%ebp
  8002c5:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002c8:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  8002cb:	8b 10                	mov    (%eax),%edx
  8002cd:	3b 50 04             	cmp    0x4(%eax),%edx
  8002d0:	73 08                	jae    8002da <sprintputch+0x18>
		*b->buf++ = ch;
  8002d2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8002d5:	88 0a                	mov    %cl,(%edx)
  8002d7:	42                   	inc    %edx
  8002d8:	89 10                	mov    %edx,(%eax)
}
  8002da:	c9                   	leave  
  8002db:	c3                   	ret    

008002dc <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8002dc:	55                   	push   %ebp
  8002dd:	89 e5                	mov    %esp,%ebp
  8002df:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8002e2:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002e5:	50                   	push   %eax
  8002e6:	ff 75 10             	pushl  0x10(%ebp)
  8002e9:	ff 75 0c             	pushl  0xc(%ebp)
  8002ec:	ff 75 08             	pushl  0x8(%ebp)
  8002ef:	e8 05 00 00 00       	call   8002f9 <vprintfmt>
	va_end(ap);
  8002f4:	83 c4 10             	add    $0x10,%esp
}
  8002f7:	c9                   	leave  
  8002f8:	c3                   	ret    

008002f9 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8002f9:	55                   	push   %ebp
  8002fa:	89 e5                	mov    %esp,%ebp
  8002fc:	57                   	push   %edi
  8002fd:	56                   	push   %esi
  8002fe:	53                   	push   %ebx
  8002ff:	83 ec 2c             	sub    $0x2c,%esp
  800302:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800305:	8b 75 10             	mov    0x10(%ebp),%esi
  800308:	eb 13                	jmp    80031d <vprintfmt+0x24>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80030a:	85 c0                	test   %eax,%eax
  80030c:	0f 84 6d 03 00 00    	je     80067f <vprintfmt+0x386>
				return;
			putch(ch, putdat);
  800312:	83 ec 08             	sub    $0x8,%esp
  800315:	57                   	push   %edi
  800316:	50                   	push   %eax
  800317:	ff 55 08             	call   *0x8(%ebp)
  80031a:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80031d:	0f b6 06             	movzbl (%esi),%eax
  800320:	46                   	inc    %esi
  800321:	83 f8 25             	cmp    $0x25,%eax
  800324:	75 e4                	jne    80030a <vprintfmt+0x11>
  800326:	c6 45 dc 20          	movb   $0x20,-0x24(%ebp)
  80032a:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  800331:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  800338:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  80033f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800344:	eb 28                	jmp    80036e <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800346:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800348:	c6 45 dc 2d          	movb   $0x2d,-0x24(%ebp)
  80034c:	eb 20                	jmp    80036e <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80034e:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800350:	c6 45 dc 30          	movb   $0x30,-0x24(%ebp)
  800354:	eb 18                	jmp    80036e <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800356:	89 de                	mov    %ebx,%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800358:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  80035f:	eb 0d                	jmp    80036e <vprintfmt+0x75>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800361:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800364:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800367:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80036e:	8a 06                	mov    (%esi),%al
  800370:	0f b6 d0             	movzbl %al,%edx
  800373:	8d 5e 01             	lea    0x1(%esi),%ebx
  800376:	83 e8 23             	sub    $0x23,%eax
  800379:	3c 55                	cmp    $0x55,%al
  80037b:	0f 87 e0 02 00 00    	ja     800661 <vprintfmt+0x368>
  800381:	0f b6 c0             	movzbl %al,%eax
  800384:	ff 24 85 e0 1f 80 00 	jmp    *0x801fe0(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80038b:	83 ea 30             	sub    $0x30,%edx
  80038e:	89 55 d4             	mov    %edx,-0x2c(%ebp)
				ch = *fmt;
  800391:	0f be 03             	movsbl (%ebx),%eax
				if (ch < '0' || ch > '9')
  800394:	8d 50 d0             	lea    -0x30(%eax),%edx
  800397:	83 fa 09             	cmp    $0x9,%edx
  80039a:	77 44                	ja     8003e0 <vprintfmt+0xe7>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80039c:	89 de                	mov    %ebx,%esi
  80039e:	8b 55 d4             	mov    -0x2c(%ebp),%edx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003a1:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
  8003a2:	8d 14 92             	lea    (%edx,%edx,4),%edx
  8003a5:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
  8003a9:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8003ac:	8d 58 d0             	lea    -0x30(%eax),%ebx
  8003af:	83 fb 09             	cmp    $0x9,%ebx
  8003b2:	76 ed                	jbe    8003a1 <vprintfmt+0xa8>
  8003b4:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  8003b7:	eb 29                	jmp    8003e2 <vprintfmt+0xe9>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003b9:	8b 45 14             	mov    0x14(%ebp),%eax
  8003bc:	8d 50 04             	lea    0x4(%eax),%edx
  8003bf:	89 55 14             	mov    %edx,0x14(%ebp)
  8003c2:	8b 00                	mov    (%eax),%eax
  8003c4:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003c7:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8003c9:	eb 17                	jmp    8003e2 <vprintfmt+0xe9>

		case '.':
			if (width < 0)
  8003cb:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8003cf:	78 85                	js     800356 <vprintfmt+0x5d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003d1:	89 de                	mov    %ebx,%esi
  8003d3:	eb 99                	jmp    80036e <vprintfmt+0x75>
  8003d5:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8003d7:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  8003de:	eb 8e                	jmp    80036e <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003e0:	89 de                	mov    %ebx,%esi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  8003e2:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8003e6:	79 86                	jns    80036e <vprintfmt+0x75>
  8003e8:	e9 74 ff ff ff       	jmp    800361 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8003ed:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ee:	89 de                	mov    %ebx,%esi
  8003f0:	e9 79 ff ff ff       	jmp    80036e <vprintfmt+0x75>
  8003f5:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8003f8:	8b 45 14             	mov    0x14(%ebp),%eax
  8003fb:	8d 50 04             	lea    0x4(%eax),%edx
  8003fe:	89 55 14             	mov    %edx,0x14(%ebp)
  800401:	83 ec 08             	sub    $0x8,%esp
  800404:	57                   	push   %edi
  800405:	ff 30                	pushl  (%eax)
  800407:	ff 55 08             	call   *0x8(%ebp)
			break;
  80040a:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80040d:	8b 75 d8             	mov    -0x28(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800410:	e9 08 ff ff ff       	jmp    80031d <vprintfmt+0x24>
  800415:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  800418:	8b 45 14             	mov    0x14(%ebp),%eax
  80041b:	8d 50 04             	lea    0x4(%eax),%edx
  80041e:	89 55 14             	mov    %edx,0x14(%ebp)
  800421:	8b 00                	mov    (%eax),%eax
  800423:	85 c0                	test   %eax,%eax
  800425:	79 02                	jns    800429 <vprintfmt+0x130>
  800427:	f7 d8                	neg    %eax
  800429:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80042b:	83 f8 0f             	cmp    $0xf,%eax
  80042e:	7f 0b                	jg     80043b <vprintfmt+0x142>
  800430:	8b 04 85 40 21 80 00 	mov    0x802140(,%eax,4),%eax
  800437:	85 c0                	test   %eax,%eax
  800439:	75 1a                	jne    800455 <vprintfmt+0x15c>
				printfmt(putch, putdat, "error %d", err);
  80043b:	52                   	push   %edx
  80043c:	68 ad 1e 80 00       	push   $0x801ead
  800441:	57                   	push   %edi
  800442:	ff 75 08             	pushl  0x8(%ebp)
  800445:	e8 92 fe ff ff       	call   8002dc <printfmt>
  80044a:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80044d:	8b 75 d8             	mov    -0x28(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800450:	e9 c8 fe ff ff       	jmp    80031d <vprintfmt+0x24>
			else
				printfmt(putch, putdat, "%s", p);
  800455:	50                   	push   %eax
  800456:	68 71 22 80 00       	push   $0x802271
  80045b:	57                   	push   %edi
  80045c:	ff 75 08             	pushl  0x8(%ebp)
  80045f:	e8 78 fe ff ff       	call   8002dc <printfmt>
  800464:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800467:	8b 75 d8             	mov    -0x28(%ebp),%esi
  80046a:	e9 ae fe ff ff       	jmp    80031d <vprintfmt+0x24>
  80046f:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  800472:	89 de                	mov    %ebx,%esi
  800474:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  800477:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80047a:	8b 45 14             	mov    0x14(%ebp),%eax
  80047d:	8d 50 04             	lea    0x4(%eax),%edx
  800480:	89 55 14             	mov    %edx,0x14(%ebp)
  800483:	8b 00                	mov    (%eax),%eax
  800485:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800488:	85 c0                	test   %eax,%eax
  80048a:	75 07                	jne    800493 <vprintfmt+0x19a>
				p = "(null)";
  80048c:	c7 45 d0 a6 1e 80 00 	movl   $0x801ea6,-0x30(%ebp)
			if (width > 0 && padc != '-')
  800493:	85 db                	test   %ebx,%ebx
  800495:	7e 42                	jle    8004d9 <vprintfmt+0x1e0>
  800497:	80 7d dc 2d          	cmpb   $0x2d,-0x24(%ebp)
  80049b:	74 3c                	je     8004d9 <vprintfmt+0x1e0>
				for (width -= strnlen(p, precision); width > 0; width--)
  80049d:	83 ec 08             	sub    $0x8,%esp
  8004a0:	51                   	push   %ecx
  8004a1:	ff 75 d0             	pushl  -0x30(%ebp)
  8004a4:	e8 6f 02 00 00       	call   800718 <strnlen>
  8004a9:	29 c3                	sub    %eax,%ebx
  8004ab:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8004ae:	83 c4 10             	add    $0x10,%esp
  8004b1:	85 db                	test   %ebx,%ebx
  8004b3:	7e 24                	jle    8004d9 <vprintfmt+0x1e0>
					putch(padc, putdat);
  8004b5:	0f be 5d dc          	movsbl -0x24(%ebp),%ebx
  8004b9:	89 75 dc             	mov    %esi,-0x24(%ebp)
  8004bc:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  8004bf:	83 ec 08             	sub    $0x8,%esp
  8004c2:	57                   	push   %edi
  8004c3:	53                   	push   %ebx
  8004c4:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004c7:	4e                   	dec    %esi
  8004c8:	83 c4 10             	add    $0x10,%esp
  8004cb:	85 f6                	test   %esi,%esi
  8004cd:	7f f0                	jg     8004bf <vprintfmt+0x1c6>
  8004cf:	8b 75 dc             	mov    -0x24(%ebp),%esi
  8004d2:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004d9:	8b 55 d0             	mov    -0x30(%ebp),%edx
  8004dc:	0f be 02             	movsbl (%edx),%eax
  8004df:	85 c0                	test   %eax,%eax
  8004e1:	75 47                	jne    80052a <vprintfmt+0x231>
  8004e3:	eb 37                	jmp    80051c <vprintfmt+0x223>
				if (altflag && (ch < ' ' || ch > '~'))
  8004e5:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004e9:	74 16                	je     800501 <vprintfmt+0x208>
  8004eb:	8d 50 e0             	lea    -0x20(%eax),%edx
  8004ee:	83 fa 5e             	cmp    $0x5e,%edx
  8004f1:	76 0e                	jbe    800501 <vprintfmt+0x208>
					putch('?', putdat);
  8004f3:	83 ec 08             	sub    $0x8,%esp
  8004f6:	57                   	push   %edi
  8004f7:	6a 3f                	push   $0x3f
  8004f9:	ff 55 08             	call   *0x8(%ebp)
  8004fc:	83 c4 10             	add    $0x10,%esp
  8004ff:	eb 0b                	jmp    80050c <vprintfmt+0x213>
				else
					putch(ch, putdat);
  800501:	83 ec 08             	sub    $0x8,%esp
  800504:	57                   	push   %edi
  800505:	50                   	push   %eax
  800506:	ff 55 08             	call   *0x8(%ebp)
  800509:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80050c:	ff 4d e4             	decl   -0x1c(%ebp)
  80050f:	0f be 03             	movsbl (%ebx),%eax
  800512:	85 c0                	test   %eax,%eax
  800514:	74 03                	je     800519 <vprintfmt+0x220>
  800516:	43                   	inc    %ebx
  800517:	eb 1b                	jmp    800534 <vprintfmt+0x23b>
  800519:	8b 75 dc             	mov    -0x24(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80051c:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800520:	7f 1e                	jg     800540 <vprintfmt+0x247>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800522:	8b 75 d8             	mov    -0x28(%ebp),%esi
  800525:	e9 f3 fd ff ff       	jmp    80031d <vprintfmt+0x24>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80052a:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  80052d:	43                   	inc    %ebx
  80052e:	89 75 dc             	mov    %esi,-0x24(%ebp)
  800531:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  800534:	85 f6                	test   %esi,%esi
  800536:	78 ad                	js     8004e5 <vprintfmt+0x1ec>
  800538:	4e                   	dec    %esi
  800539:	79 aa                	jns    8004e5 <vprintfmt+0x1ec>
  80053b:	8b 75 dc             	mov    -0x24(%ebp),%esi
  80053e:	eb dc                	jmp    80051c <vprintfmt+0x223>
  800540:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800543:	83 ec 08             	sub    $0x8,%esp
  800546:	57                   	push   %edi
  800547:	6a 20                	push   $0x20
  800549:	ff 55 08             	call   *0x8(%ebp)
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80054c:	4b                   	dec    %ebx
  80054d:	83 c4 10             	add    $0x10,%esp
  800550:	85 db                	test   %ebx,%ebx
  800552:	7f ef                	jg     800543 <vprintfmt+0x24a>
  800554:	e9 c4 fd ff ff       	jmp    80031d <vprintfmt+0x24>
  800559:	89 5d d8             	mov    %ebx,-0x28(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80055c:	89 ca                	mov    %ecx,%edx
  80055e:	8d 45 14             	lea    0x14(%ebp),%eax
  800561:	e8 2a fd ff ff       	call   800290 <getint>
  800566:	89 c3                	mov    %eax,%ebx
  800568:	89 d6                	mov    %edx,%esi
			if ((long long) num < 0) {
  80056a:	85 d2                	test   %edx,%edx
  80056c:	78 0a                	js     800578 <vprintfmt+0x27f>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80056e:	b8 0a 00 00 00       	mov    $0xa,%eax
  800573:	e9 b0 00 00 00       	jmp    800628 <vprintfmt+0x32f>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  800578:	83 ec 08             	sub    $0x8,%esp
  80057b:	57                   	push   %edi
  80057c:	6a 2d                	push   $0x2d
  80057e:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800581:	f7 db                	neg    %ebx
  800583:	83 d6 00             	adc    $0x0,%esi
  800586:	f7 de                	neg    %esi
  800588:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  80058b:	b8 0a 00 00 00       	mov    $0xa,%eax
  800590:	e9 93 00 00 00       	jmp    800628 <vprintfmt+0x32f>
  800595:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800598:	89 ca                	mov    %ecx,%edx
  80059a:	8d 45 14             	lea    0x14(%ebp),%eax
  80059d:	e8 b4 fc ff ff       	call   800256 <getuint>
  8005a2:	89 c3                	mov    %eax,%ebx
  8005a4:	89 d6                	mov    %edx,%esi
			base = 10;
  8005a6:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  8005ab:	eb 7b                	jmp    800628 <vprintfmt+0x32f>
  8005ad:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
  8005b0:	89 ca                	mov    %ecx,%edx
  8005b2:	8d 45 14             	lea    0x14(%ebp),%eax
  8005b5:	e8 d6 fc ff ff       	call   800290 <getint>
  8005ba:	89 c3                	mov    %eax,%ebx
  8005bc:	89 d6                	mov    %edx,%esi
            if ((long long) num < 0) {
  8005be:	85 d2                	test   %edx,%edx
  8005c0:	78 07                	js     8005c9 <vprintfmt+0x2d0>
                putch('-', putdat);
                num = -(long long) num;
            }
            base = 8;
  8005c2:	b8 08 00 00 00       	mov    $0x8,%eax
  8005c7:	eb 5f                	jmp    800628 <vprintfmt+0x32f>
		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
            if ((long long) num < 0) {
                putch('-', putdat);
  8005c9:	83 ec 08             	sub    $0x8,%esp
  8005cc:	57                   	push   %edi
  8005cd:	6a 2d                	push   $0x2d
  8005cf:	ff 55 08             	call   *0x8(%ebp)
                num = -(long long) num;
  8005d2:	f7 db                	neg    %ebx
  8005d4:	83 d6 00             	adc    $0x0,%esi
  8005d7:	f7 de                	neg    %esi
  8005d9:	83 c4 10             	add    $0x10,%esp
            }
            base = 8;
  8005dc:	b8 08 00 00 00       	mov    $0x8,%eax
  8005e1:	eb 45                	jmp    800628 <vprintfmt+0x32f>
  8005e3:	89 5d d8             	mov    %ebx,-0x28(%ebp)
            goto number;

        // pointer
		case 'p':
			putch('0', putdat);
  8005e6:	83 ec 08             	sub    $0x8,%esp
  8005e9:	57                   	push   %edi
  8005ea:	6a 30                	push   $0x30
  8005ec:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8005ef:	83 c4 08             	add    $0x8,%esp
  8005f2:	57                   	push   %edi
  8005f3:	6a 78                	push   $0x78
  8005f5:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8005f8:	8b 45 14             	mov    0x14(%ebp),%eax
  8005fb:	8d 50 04             	lea    0x4(%eax),%edx
  8005fe:	89 55 14             	mov    %edx,0x14(%ebp)

        // pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800601:	8b 18                	mov    (%eax),%ebx
  800603:	be 00 00 00 00       	mov    $0x0,%esi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800608:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80060b:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800610:	eb 16                	jmp    800628 <vprintfmt+0x32f>
  800612:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800615:	89 ca                	mov    %ecx,%edx
  800617:	8d 45 14             	lea    0x14(%ebp),%eax
  80061a:	e8 37 fc ff ff       	call   800256 <getuint>
  80061f:	89 c3                	mov    %eax,%ebx
  800621:	89 d6                	mov    %edx,%esi
			base = 16;
  800623:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800628:	83 ec 0c             	sub    $0xc,%esp
  80062b:	0f be 55 dc          	movsbl -0x24(%ebp),%edx
  80062f:	52                   	push   %edx
  800630:	ff 75 e4             	pushl  -0x1c(%ebp)
  800633:	50                   	push   %eax
  800634:	56                   	push   %esi
  800635:	53                   	push   %ebx
  800636:	89 fa                	mov    %edi,%edx
  800638:	8b 45 08             	mov    0x8(%ebp),%eax
  80063b:	e8 68 fb ff ff       	call   8001a8 <printnum>
			break;
  800640:	83 c4 20             	add    $0x20,%esp
  800643:	8b 75 d8             	mov    -0x28(%ebp),%esi
  800646:	e9 d2 fc ff ff       	jmp    80031d <vprintfmt+0x24>
  80064b:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80064e:	83 ec 08             	sub    $0x8,%esp
  800651:	57                   	push   %edi
  800652:	52                   	push   %edx
  800653:	ff 55 08             	call   *0x8(%ebp)
			break;
  800656:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800659:	8b 75 d8             	mov    -0x28(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80065c:	e9 bc fc ff ff       	jmp    80031d <vprintfmt+0x24>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800661:	83 ec 08             	sub    $0x8,%esp
  800664:	57                   	push   %edi
  800665:	6a 25                	push   $0x25
  800667:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  80066a:	83 c4 10             	add    $0x10,%esp
  80066d:	eb 02                	jmp    800671 <vprintfmt+0x378>
  80066f:	89 c6                	mov    %eax,%esi
  800671:	8d 46 ff             	lea    -0x1(%esi),%eax
  800674:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800678:	75 f5                	jne    80066f <vprintfmt+0x376>
  80067a:	e9 9e fc ff ff       	jmp    80031d <vprintfmt+0x24>
				/* do nothing */;
			break;
		}
	}
}
  80067f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800682:	5b                   	pop    %ebx
  800683:	5e                   	pop    %esi
  800684:	5f                   	pop    %edi
  800685:	c9                   	leave  
  800686:	c3                   	ret    

00800687 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800687:	55                   	push   %ebp
  800688:	89 e5                	mov    %esp,%ebp
  80068a:	83 ec 18             	sub    $0x18,%esp
  80068d:	8b 45 08             	mov    0x8(%ebp),%eax
  800690:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800693:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800696:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80069a:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80069d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8006a4:	85 c0                	test   %eax,%eax
  8006a6:	74 26                	je     8006ce <vsnprintf+0x47>
  8006a8:	85 d2                	test   %edx,%edx
  8006aa:	7e 29                	jle    8006d5 <vsnprintf+0x4e>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8006ac:	ff 75 14             	pushl  0x14(%ebp)
  8006af:	ff 75 10             	pushl  0x10(%ebp)
  8006b2:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8006b5:	50                   	push   %eax
  8006b6:	68 c2 02 80 00       	push   $0x8002c2
  8006bb:	e8 39 fc ff ff       	call   8002f9 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8006c0:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8006c3:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8006c6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006c9:	83 c4 10             	add    $0x10,%esp
  8006cc:	eb 0c                	jmp    8006da <vsnprintf+0x53>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8006ce:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8006d3:	eb 05                	jmp    8006da <vsnprintf+0x53>
  8006d5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8006da:	c9                   	leave  
  8006db:	c3                   	ret    

008006dc <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8006dc:	55                   	push   %ebp
  8006dd:	89 e5                	mov    %esp,%ebp
  8006df:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8006e2:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8006e5:	50                   	push   %eax
  8006e6:	ff 75 10             	pushl  0x10(%ebp)
  8006e9:	ff 75 0c             	pushl  0xc(%ebp)
  8006ec:	ff 75 08             	pushl  0x8(%ebp)
  8006ef:	e8 93 ff ff ff       	call   800687 <vsnprintf>
	va_end(ap);

	return rc;
}
  8006f4:	c9                   	leave  
  8006f5:	c3                   	ret    
	...

008006f8 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8006f8:	55                   	push   %ebp
  8006f9:	89 e5                	mov    %esp,%ebp
  8006fb:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8006fe:	80 3a 00             	cmpb   $0x0,(%edx)
  800701:	74 0e                	je     800711 <strlen+0x19>
  800703:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800708:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800709:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80070d:	75 f9                	jne    800708 <strlen+0x10>
  80070f:	eb 05                	jmp    800716 <strlen+0x1e>
  800711:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800716:	c9                   	leave  
  800717:	c3                   	ret    

00800718 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800718:	55                   	push   %ebp
  800719:	89 e5                	mov    %esp,%ebp
  80071b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80071e:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800721:	85 d2                	test   %edx,%edx
  800723:	74 17                	je     80073c <strnlen+0x24>
  800725:	80 39 00             	cmpb   $0x0,(%ecx)
  800728:	74 19                	je     800743 <strnlen+0x2b>
  80072a:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  80072f:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800730:	39 d0                	cmp    %edx,%eax
  800732:	74 14                	je     800748 <strnlen+0x30>
  800734:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800738:	75 f5                	jne    80072f <strnlen+0x17>
  80073a:	eb 0c                	jmp    800748 <strnlen+0x30>
  80073c:	b8 00 00 00 00       	mov    $0x0,%eax
  800741:	eb 05                	jmp    800748 <strnlen+0x30>
  800743:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800748:	c9                   	leave  
  800749:	c3                   	ret    

0080074a <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80074a:	55                   	push   %ebp
  80074b:	89 e5                	mov    %esp,%ebp
  80074d:	53                   	push   %ebx
  80074e:	8b 45 08             	mov    0x8(%ebp),%eax
  800751:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800754:	ba 00 00 00 00       	mov    $0x0,%edx
  800759:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  80075c:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  80075f:	42                   	inc    %edx
  800760:	84 c9                	test   %cl,%cl
  800762:	75 f5                	jne    800759 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800764:	5b                   	pop    %ebx
  800765:	c9                   	leave  
  800766:	c3                   	ret    

00800767 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800767:	55                   	push   %ebp
  800768:	89 e5                	mov    %esp,%ebp
  80076a:	53                   	push   %ebx
  80076b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80076e:	53                   	push   %ebx
  80076f:	e8 84 ff ff ff       	call   8006f8 <strlen>
  800774:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800777:	ff 75 0c             	pushl  0xc(%ebp)
  80077a:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  80077d:	50                   	push   %eax
  80077e:	e8 c7 ff ff ff       	call   80074a <strcpy>
	return dst;
}
  800783:	89 d8                	mov    %ebx,%eax
  800785:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800788:	c9                   	leave  
  800789:	c3                   	ret    

0080078a <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80078a:	55                   	push   %ebp
  80078b:	89 e5                	mov    %esp,%ebp
  80078d:	56                   	push   %esi
  80078e:	53                   	push   %ebx
  80078f:	8b 45 08             	mov    0x8(%ebp),%eax
  800792:	8b 55 0c             	mov    0xc(%ebp),%edx
  800795:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800798:	85 f6                	test   %esi,%esi
  80079a:	74 15                	je     8007b1 <strncpy+0x27>
  80079c:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  8007a1:	8a 1a                	mov    (%edx),%bl
  8007a3:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007a6:	80 3a 01             	cmpb   $0x1,(%edx)
  8007a9:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007ac:	41                   	inc    %ecx
  8007ad:	39 ce                	cmp    %ecx,%esi
  8007af:	77 f0                	ja     8007a1 <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8007b1:	5b                   	pop    %ebx
  8007b2:	5e                   	pop    %esi
  8007b3:	c9                   	leave  
  8007b4:	c3                   	ret    

008007b5 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8007b5:	55                   	push   %ebp
  8007b6:	89 e5                	mov    %esp,%ebp
  8007b8:	57                   	push   %edi
  8007b9:	56                   	push   %esi
  8007ba:	53                   	push   %ebx
  8007bb:	8b 7d 08             	mov    0x8(%ebp),%edi
  8007be:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8007c1:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007c4:	85 f6                	test   %esi,%esi
  8007c6:	74 32                	je     8007fa <strlcpy+0x45>
		while (--size > 0 && *src != '\0')
  8007c8:	83 fe 01             	cmp    $0x1,%esi
  8007cb:	74 22                	je     8007ef <strlcpy+0x3a>
  8007cd:	8a 0b                	mov    (%ebx),%cl
  8007cf:	84 c9                	test   %cl,%cl
  8007d1:	74 20                	je     8007f3 <strlcpy+0x3e>
  8007d3:	89 f8                	mov    %edi,%eax
  8007d5:	ba 00 00 00 00       	mov    $0x0,%edx
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
  8007da:	83 ee 02             	sub    $0x2,%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8007dd:	88 08                	mov    %cl,(%eax)
  8007df:	40                   	inc    %eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8007e0:	39 f2                	cmp    %esi,%edx
  8007e2:	74 11                	je     8007f5 <strlcpy+0x40>
  8007e4:	8a 4c 13 01          	mov    0x1(%ebx,%edx,1),%cl
  8007e8:	42                   	inc    %edx
  8007e9:	84 c9                	test   %cl,%cl
  8007eb:	75 f0                	jne    8007dd <strlcpy+0x28>
  8007ed:	eb 06                	jmp    8007f5 <strlcpy+0x40>
  8007ef:	89 f8                	mov    %edi,%eax
  8007f1:	eb 02                	jmp    8007f5 <strlcpy+0x40>
  8007f3:	89 f8                	mov    %edi,%eax
			*dst++ = *src++;
		*dst = '\0';
  8007f5:	c6 00 00             	movb   $0x0,(%eax)
  8007f8:	eb 02                	jmp    8007fc <strlcpy+0x47>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007fa:	89 f8                	mov    %edi,%eax
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
		*dst = '\0';
	}
	return dst - dst_in;
  8007fc:	29 f8                	sub    %edi,%eax
}
  8007fe:	5b                   	pop    %ebx
  8007ff:	5e                   	pop    %esi
  800800:	5f                   	pop    %edi
  800801:	c9                   	leave  
  800802:	c3                   	ret    

00800803 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800803:	55                   	push   %ebp
  800804:	89 e5                	mov    %esp,%ebp
  800806:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800809:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80080c:	8a 01                	mov    (%ecx),%al
  80080e:	84 c0                	test   %al,%al
  800810:	74 10                	je     800822 <strcmp+0x1f>
  800812:	3a 02                	cmp    (%edx),%al
  800814:	75 0c                	jne    800822 <strcmp+0x1f>
		p++, q++;
  800816:	41                   	inc    %ecx
  800817:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800818:	8a 01                	mov    (%ecx),%al
  80081a:	84 c0                	test   %al,%al
  80081c:	74 04                	je     800822 <strcmp+0x1f>
  80081e:	3a 02                	cmp    (%edx),%al
  800820:	74 f4                	je     800816 <strcmp+0x13>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800822:	0f b6 c0             	movzbl %al,%eax
  800825:	0f b6 12             	movzbl (%edx),%edx
  800828:	29 d0                	sub    %edx,%eax
}
  80082a:	c9                   	leave  
  80082b:	c3                   	ret    

0080082c <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80082c:	55                   	push   %ebp
  80082d:	89 e5                	mov    %esp,%ebp
  80082f:	53                   	push   %ebx
  800830:	8b 55 08             	mov    0x8(%ebp),%edx
  800833:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800836:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  800839:	85 c0                	test   %eax,%eax
  80083b:	74 1b                	je     800858 <strncmp+0x2c>
  80083d:	8a 1a                	mov    (%edx),%bl
  80083f:	84 db                	test   %bl,%bl
  800841:	74 24                	je     800867 <strncmp+0x3b>
  800843:	3a 19                	cmp    (%ecx),%bl
  800845:	75 20                	jne    800867 <strncmp+0x3b>
  800847:	48                   	dec    %eax
  800848:	74 15                	je     80085f <strncmp+0x33>
		n--, p++, q++;
  80084a:	42                   	inc    %edx
  80084b:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80084c:	8a 1a                	mov    (%edx),%bl
  80084e:	84 db                	test   %bl,%bl
  800850:	74 15                	je     800867 <strncmp+0x3b>
  800852:	3a 19                	cmp    (%ecx),%bl
  800854:	74 f1                	je     800847 <strncmp+0x1b>
  800856:	eb 0f                	jmp    800867 <strncmp+0x3b>
		n--, p++, q++;
	if (n == 0)
		return 0;
  800858:	b8 00 00 00 00       	mov    $0x0,%eax
  80085d:	eb 05                	jmp    800864 <strncmp+0x38>
  80085f:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800864:	5b                   	pop    %ebx
  800865:	c9                   	leave  
  800866:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800867:	0f b6 02             	movzbl (%edx),%eax
  80086a:	0f b6 11             	movzbl (%ecx),%edx
  80086d:	29 d0                	sub    %edx,%eax
  80086f:	eb f3                	jmp    800864 <strncmp+0x38>

00800871 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800871:	55                   	push   %ebp
  800872:	89 e5                	mov    %esp,%ebp
  800874:	8b 45 08             	mov    0x8(%ebp),%eax
  800877:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  80087a:	8a 10                	mov    (%eax),%dl
  80087c:	84 d2                	test   %dl,%dl
  80087e:	74 18                	je     800898 <strchr+0x27>
		if (*s == c)
  800880:	38 ca                	cmp    %cl,%dl
  800882:	75 06                	jne    80088a <strchr+0x19>
  800884:	eb 17                	jmp    80089d <strchr+0x2c>
  800886:	38 ca                	cmp    %cl,%dl
  800888:	74 13                	je     80089d <strchr+0x2c>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80088a:	40                   	inc    %eax
  80088b:	8a 10                	mov    (%eax),%dl
  80088d:	84 d2                	test   %dl,%dl
  80088f:	75 f5                	jne    800886 <strchr+0x15>
		if (*s == c)
			return (char *) s;
	return 0;
  800891:	b8 00 00 00 00       	mov    $0x0,%eax
  800896:	eb 05                	jmp    80089d <strchr+0x2c>
  800898:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80089d:	c9                   	leave  
  80089e:	c3                   	ret    

0080089f <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80089f:	55                   	push   %ebp
  8008a0:	89 e5                	mov    %esp,%ebp
  8008a2:	8b 45 08             	mov    0x8(%ebp),%eax
  8008a5:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8008a8:	8a 10                	mov    (%eax),%dl
  8008aa:	84 d2                	test   %dl,%dl
  8008ac:	74 11                	je     8008bf <strfind+0x20>
		if (*s == c)
  8008ae:	38 ca                	cmp    %cl,%dl
  8008b0:	75 06                	jne    8008b8 <strfind+0x19>
  8008b2:	eb 0b                	jmp    8008bf <strfind+0x20>
  8008b4:	38 ca                	cmp    %cl,%dl
  8008b6:	74 07                	je     8008bf <strfind+0x20>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  8008b8:	40                   	inc    %eax
  8008b9:	8a 10                	mov    (%eax),%dl
  8008bb:	84 d2                	test   %dl,%dl
  8008bd:	75 f5                	jne    8008b4 <strfind+0x15>
		if (*s == c)
			break;
	return (char *) s;
}
  8008bf:	c9                   	leave  
  8008c0:	c3                   	ret    

008008c1 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008c1:	55                   	push   %ebp
  8008c2:	89 e5                	mov    %esp,%ebp
  8008c4:	57                   	push   %edi
  8008c5:	56                   	push   %esi
  8008c6:	53                   	push   %ebx
  8008c7:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008ca:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008cd:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8008d0:	85 c9                	test   %ecx,%ecx
  8008d2:	74 30                	je     800904 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008d4:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008da:	75 25                	jne    800901 <memset+0x40>
  8008dc:	f6 c1 03             	test   $0x3,%cl
  8008df:	75 20                	jne    800901 <memset+0x40>
		c &= 0xFF;
  8008e1:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8008e4:	89 d3                	mov    %edx,%ebx
  8008e6:	c1 e3 08             	shl    $0x8,%ebx
  8008e9:	89 d6                	mov    %edx,%esi
  8008eb:	c1 e6 18             	shl    $0x18,%esi
  8008ee:	89 d0                	mov    %edx,%eax
  8008f0:	c1 e0 10             	shl    $0x10,%eax
  8008f3:	09 f0                	or     %esi,%eax
  8008f5:	09 d0                	or     %edx,%eax
  8008f7:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  8008f9:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  8008fc:	fc                   	cld    
  8008fd:	f3 ab                	rep stos %eax,%es:(%edi)
  8008ff:	eb 03                	jmp    800904 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800901:	fc                   	cld    
  800902:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800904:	89 f8                	mov    %edi,%eax
  800906:	5b                   	pop    %ebx
  800907:	5e                   	pop    %esi
  800908:	5f                   	pop    %edi
  800909:	c9                   	leave  
  80090a:	c3                   	ret    

0080090b <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80090b:	55                   	push   %ebp
  80090c:	89 e5                	mov    %esp,%ebp
  80090e:	57                   	push   %edi
  80090f:	56                   	push   %esi
  800910:	8b 45 08             	mov    0x8(%ebp),%eax
  800913:	8b 75 0c             	mov    0xc(%ebp),%esi
  800916:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800919:	39 c6                	cmp    %eax,%esi
  80091b:	73 34                	jae    800951 <memmove+0x46>
  80091d:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800920:	39 d0                	cmp    %edx,%eax
  800922:	73 2d                	jae    800951 <memmove+0x46>
		s += n;
		d += n;
  800924:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800927:	f6 c2 03             	test   $0x3,%dl
  80092a:	75 1b                	jne    800947 <memmove+0x3c>
  80092c:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800932:	75 13                	jne    800947 <memmove+0x3c>
  800934:	f6 c1 03             	test   $0x3,%cl
  800937:	75 0e                	jne    800947 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800939:	83 ef 04             	sub    $0x4,%edi
  80093c:	8d 72 fc             	lea    -0x4(%edx),%esi
  80093f:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800942:	fd                   	std    
  800943:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800945:	eb 07                	jmp    80094e <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800947:	4f                   	dec    %edi
  800948:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  80094b:	fd                   	std    
  80094c:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80094e:	fc                   	cld    
  80094f:	eb 20                	jmp    800971 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800951:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800957:	75 13                	jne    80096c <memmove+0x61>
  800959:	a8 03                	test   $0x3,%al
  80095b:	75 0f                	jne    80096c <memmove+0x61>
  80095d:	f6 c1 03             	test   $0x3,%cl
  800960:	75 0a                	jne    80096c <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800962:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800965:	89 c7                	mov    %eax,%edi
  800967:	fc                   	cld    
  800968:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80096a:	eb 05                	jmp    800971 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  80096c:	89 c7                	mov    %eax,%edi
  80096e:	fc                   	cld    
  80096f:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800971:	5e                   	pop    %esi
  800972:	5f                   	pop    %edi
  800973:	c9                   	leave  
  800974:	c3                   	ret    

00800975 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800975:	55                   	push   %ebp
  800976:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800978:	ff 75 10             	pushl  0x10(%ebp)
  80097b:	ff 75 0c             	pushl  0xc(%ebp)
  80097e:	ff 75 08             	pushl  0x8(%ebp)
  800981:	e8 85 ff ff ff       	call   80090b <memmove>
}
  800986:	c9                   	leave  
  800987:	c3                   	ret    

00800988 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800988:	55                   	push   %ebp
  800989:	89 e5                	mov    %esp,%ebp
  80098b:	57                   	push   %edi
  80098c:	56                   	push   %esi
  80098d:	53                   	push   %ebx
  80098e:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800991:	8b 75 0c             	mov    0xc(%ebp),%esi
  800994:	8b 7d 10             	mov    0x10(%ebp),%edi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800997:	85 ff                	test   %edi,%edi
  800999:	74 32                	je     8009cd <memcmp+0x45>
		if (*s1 != *s2)
  80099b:	8a 03                	mov    (%ebx),%al
  80099d:	8a 0e                	mov    (%esi),%cl
  80099f:	38 c8                	cmp    %cl,%al
  8009a1:	74 19                	je     8009bc <memcmp+0x34>
  8009a3:	eb 0d                	jmp    8009b2 <memcmp+0x2a>
  8009a5:	8a 44 13 01          	mov    0x1(%ebx,%edx,1),%al
  8009a9:	8a 4c 16 01          	mov    0x1(%esi,%edx,1),%cl
  8009ad:	42                   	inc    %edx
  8009ae:	38 c8                	cmp    %cl,%al
  8009b0:	74 10                	je     8009c2 <memcmp+0x3a>
			return (int) *s1 - (int) *s2;
  8009b2:	0f b6 c0             	movzbl %al,%eax
  8009b5:	0f b6 c9             	movzbl %cl,%ecx
  8009b8:	29 c8                	sub    %ecx,%eax
  8009ba:	eb 16                	jmp    8009d2 <memcmp+0x4a>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009bc:	4f                   	dec    %edi
  8009bd:	ba 00 00 00 00       	mov    $0x0,%edx
  8009c2:	39 fa                	cmp    %edi,%edx
  8009c4:	75 df                	jne    8009a5 <memcmp+0x1d>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8009c6:	b8 00 00 00 00       	mov    $0x0,%eax
  8009cb:	eb 05                	jmp    8009d2 <memcmp+0x4a>
  8009cd:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009d2:	5b                   	pop    %ebx
  8009d3:	5e                   	pop    %esi
  8009d4:	5f                   	pop    %edi
  8009d5:	c9                   	leave  
  8009d6:	c3                   	ret    

008009d7 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009d7:	55                   	push   %ebp
  8009d8:	89 e5                	mov    %esp,%ebp
  8009da:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  8009dd:	89 c2                	mov    %eax,%edx
  8009df:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  8009e2:	39 d0                	cmp    %edx,%eax
  8009e4:	73 12                	jae    8009f8 <memfind+0x21>
		if (*(const unsigned char *) s == (unsigned char) c)
  8009e6:	8a 4d 0c             	mov    0xc(%ebp),%cl
  8009e9:	38 08                	cmp    %cl,(%eax)
  8009eb:	75 06                	jne    8009f3 <memfind+0x1c>
  8009ed:	eb 09                	jmp    8009f8 <memfind+0x21>
  8009ef:	38 08                	cmp    %cl,(%eax)
  8009f1:	74 05                	je     8009f8 <memfind+0x21>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009f3:	40                   	inc    %eax
  8009f4:	39 c2                	cmp    %eax,%edx
  8009f6:	77 f7                	ja     8009ef <memfind+0x18>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8009f8:	c9                   	leave  
  8009f9:	c3                   	ret    

008009fa <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8009fa:	55                   	push   %ebp
  8009fb:	89 e5                	mov    %esp,%ebp
  8009fd:	57                   	push   %edi
  8009fe:	56                   	push   %esi
  8009ff:	53                   	push   %ebx
  800a00:	8b 55 08             	mov    0x8(%ebp),%edx
  800a03:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a06:	eb 01                	jmp    800a09 <strtol+0xf>
		s++;
  800a08:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a09:	8a 02                	mov    (%edx),%al
  800a0b:	3c 20                	cmp    $0x20,%al
  800a0d:	74 f9                	je     800a08 <strtol+0xe>
  800a0f:	3c 09                	cmp    $0x9,%al
  800a11:	74 f5                	je     800a08 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a13:	3c 2b                	cmp    $0x2b,%al
  800a15:	75 08                	jne    800a1f <strtol+0x25>
		s++;
  800a17:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a18:	bf 00 00 00 00       	mov    $0x0,%edi
  800a1d:	eb 13                	jmp    800a32 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a1f:	3c 2d                	cmp    $0x2d,%al
  800a21:	75 0a                	jne    800a2d <strtol+0x33>
		s++, neg = 1;
  800a23:	8d 52 01             	lea    0x1(%edx),%edx
  800a26:	bf 01 00 00 00       	mov    $0x1,%edi
  800a2b:	eb 05                	jmp    800a32 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a2d:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a32:	85 db                	test   %ebx,%ebx
  800a34:	74 05                	je     800a3b <strtol+0x41>
  800a36:	83 fb 10             	cmp    $0x10,%ebx
  800a39:	75 28                	jne    800a63 <strtol+0x69>
  800a3b:	8a 02                	mov    (%edx),%al
  800a3d:	3c 30                	cmp    $0x30,%al
  800a3f:	75 10                	jne    800a51 <strtol+0x57>
  800a41:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800a45:	75 0a                	jne    800a51 <strtol+0x57>
		s += 2, base = 16;
  800a47:	83 c2 02             	add    $0x2,%edx
  800a4a:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a4f:	eb 12                	jmp    800a63 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800a51:	85 db                	test   %ebx,%ebx
  800a53:	75 0e                	jne    800a63 <strtol+0x69>
  800a55:	3c 30                	cmp    $0x30,%al
  800a57:	75 05                	jne    800a5e <strtol+0x64>
		s++, base = 8;
  800a59:	42                   	inc    %edx
  800a5a:	b3 08                	mov    $0x8,%bl
  800a5c:	eb 05                	jmp    800a63 <strtol+0x69>
	else if (base == 0)
		base = 10;
  800a5e:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800a63:	b8 00 00 00 00       	mov    $0x0,%eax
  800a68:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a6a:	8a 0a                	mov    (%edx),%cl
  800a6c:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800a6f:	80 fb 09             	cmp    $0x9,%bl
  800a72:	77 08                	ja     800a7c <strtol+0x82>
			dig = *s - '0';
  800a74:	0f be c9             	movsbl %cl,%ecx
  800a77:	83 e9 30             	sub    $0x30,%ecx
  800a7a:	eb 1e                	jmp    800a9a <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800a7c:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800a7f:	80 fb 19             	cmp    $0x19,%bl
  800a82:	77 08                	ja     800a8c <strtol+0x92>
			dig = *s - 'a' + 10;
  800a84:	0f be c9             	movsbl %cl,%ecx
  800a87:	83 e9 57             	sub    $0x57,%ecx
  800a8a:	eb 0e                	jmp    800a9a <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800a8c:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800a8f:	80 fb 19             	cmp    $0x19,%bl
  800a92:	77 13                	ja     800aa7 <strtol+0xad>
			dig = *s - 'A' + 10;
  800a94:	0f be c9             	movsbl %cl,%ecx
  800a97:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800a9a:	39 f1                	cmp    %esi,%ecx
  800a9c:	7d 0d                	jge    800aab <strtol+0xb1>
			break;
		s++, val = (val * base) + dig;
  800a9e:	42                   	inc    %edx
  800a9f:	0f af c6             	imul   %esi,%eax
  800aa2:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  800aa5:	eb c3                	jmp    800a6a <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800aa7:	89 c1                	mov    %eax,%ecx
  800aa9:	eb 02                	jmp    800aad <strtol+0xb3>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800aab:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800aad:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ab1:	74 05                	je     800ab8 <strtol+0xbe>
		*endptr = (char *) s;
  800ab3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800ab6:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800ab8:	85 ff                	test   %edi,%edi
  800aba:	74 04                	je     800ac0 <strtol+0xc6>
  800abc:	89 c8                	mov    %ecx,%eax
  800abe:	f7 d8                	neg    %eax
}
  800ac0:	5b                   	pop    %ebx
  800ac1:	5e                   	pop    %esi
  800ac2:	5f                   	pop    %edi
  800ac3:	c9                   	leave  
  800ac4:	c3                   	ret    
  800ac5:	00 00                	add    %al,(%eax)
	...

00800ac8 <syscall>:
	return ret;
}

static int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800ac8:	55                   	push   %ebp
  800ac9:	89 e5                	mov    %esp,%ebp
  800acb:	57                   	push   %edi
  800acc:	56                   	push   %esi
  800acd:	53                   	push   %ebx
  800ace:	83 ec 1c             	sub    $0x1c,%esp
  800ad1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800ad4:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800ad7:	89 ca                	mov    %ecx,%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ad9:	8b 75 14             	mov    0x14(%ebp),%esi
  800adc:	8b 7d 10             	mov    0x10(%ebp),%edi
  800adf:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800ae2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ae5:	cd 30                	int    $0x30
  800ae7:	89 c2                	mov    %eax,%edx
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ae9:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800aed:	74 1c                	je     800b0b <syscall+0x43>
  800aef:	85 c0                	test   %eax,%eax
  800af1:	7e 18                	jle    800b0b <syscall+0x43>
		panic("syscall %d returned %d (> 0)", num, ret);
  800af3:	83 ec 0c             	sub    $0xc,%esp
  800af6:	50                   	push   %eax
  800af7:	ff 75 e4             	pushl  -0x1c(%ebp)
  800afa:	68 9f 21 80 00       	push   $0x80219f
  800aff:	6a 42                	push   $0x42
  800b01:	68 bc 21 80 00       	push   $0x8021bc
  800b06:	e8 21 0f 00 00       	call   801a2c <_panic>

	return ret;
}
  800b0b:	89 d0                	mov    %edx,%eax
  800b0d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b10:	5b                   	pop    %ebx
  800b11:	5e                   	pop    %esi
  800b12:	5f                   	pop    %edi
  800b13:	c9                   	leave  
  800b14:	c3                   	ret    

00800b15 <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{	
  800b15:	55                   	push   %ebp
  800b16:	89 e5                	mov    %esp,%ebp
  800b18:	83 ec 08             	sub    $0x8,%esp
	// my_sysenter(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
	// return;
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  800b1b:	6a 00                	push   $0x0
  800b1d:	6a 00                	push   $0x0
  800b1f:	6a 00                	push   $0x0
  800b21:	ff 75 0c             	pushl  0xc(%ebp)
  800b24:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b27:	ba 00 00 00 00       	mov    $0x0,%edx
  800b2c:	b8 00 00 00 00       	mov    $0x0,%eax
  800b31:	e8 92 ff ff ff       	call   800ac8 <syscall>
  800b36:	83 c4 10             	add    $0x10,%esp
	return;
}
  800b39:	c9                   	leave  
  800b3a:	c3                   	ret    

00800b3b <sys_cgetc>:

int
sys_cgetc(void)
{
  800b3b:	55                   	push   %ebp
  800b3c:	89 e5                	mov    %esp,%ebp
  800b3e:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_cgetc, 0, 0, 0, 0, 0, 0);
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  800b41:	6a 00                	push   $0x0
  800b43:	6a 00                	push   $0x0
  800b45:	6a 00                	push   $0x0
  800b47:	6a 00                	push   $0x0
  800b49:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b4e:	ba 00 00 00 00       	mov    $0x0,%edx
  800b53:	b8 01 00 00 00       	mov    $0x1,%eax
  800b58:	e8 6b ff ff ff       	call   800ac8 <syscall>
}
  800b5d:	c9                   	leave  
  800b5e:	c3                   	ret    

00800b5f <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b5f:	55                   	push   %ebp
  800b60:	89 e5                	mov    %esp,%ebp
  800b62:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  800b65:	6a 00                	push   $0x0
  800b67:	6a 00                	push   $0x0
  800b69:	6a 00                	push   $0x0
  800b6b:	6a 00                	push   $0x0
  800b6d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b70:	ba 01 00 00 00       	mov    $0x1,%edx
  800b75:	b8 03 00 00 00       	mov    $0x3,%eax
  800b7a:	e8 49 ff ff ff       	call   800ac8 <syscall>
}
  800b7f:	c9                   	leave  
  800b80:	c3                   	ret    

00800b81 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b81:	55                   	push   %ebp
  800b82:	89 e5                	mov    %esp,%ebp
  800b84:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_getenvid, 0, 0, 0, 0, 0, 0);
	return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  800b87:	6a 00                	push   $0x0
  800b89:	6a 00                	push   $0x0
  800b8b:	6a 00                	push   $0x0
  800b8d:	6a 00                	push   $0x0
  800b8f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b94:	ba 00 00 00 00       	mov    $0x0,%edx
  800b99:	b8 02 00 00 00       	mov    $0x2,%eax
  800b9e:	e8 25 ff ff ff       	call   800ac8 <syscall>
}
  800ba3:	c9                   	leave  
  800ba4:	c3                   	ret    

00800ba5 <sys_yield>:

void
sys_yield(void)
{
  800ba5:	55                   	push   %ebp
  800ba6:	89 e5                	mov    %esp,%ebp
  800ba8:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  800bab:	6a 00                	push   $0x0
  800bad:	6a 00                	push   $0x0
  800baf:	6a 00                	push   $0x0
  800bb1:	6a 00                	push   $0x0
  800bb3:	b9 00 00 00 00       	mov    $0x0,%ecx
  800bb8:	ba 00 00 00 00       	mov    $0x0,%edx
  800bbd:	b8 0b 00 00 00       	mov    $0xb,%eax
  800bc2:	e8 01 ff ff ff       	call   800ac8 <syscall>
  800bc7:	83 c4 10             	add    $0x10,%esp
}
  800bca:	c9                   	leave  
  800bcb:	c3                   	ret    

00800bcc <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800bcc:	55                   	push   %ebp
  800bcd:	89 e5                	mov    %esp,%ebp
  800bcf:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  800bd2:	6a 00                	push   $0x0
  800bd4:	6a 00                	push   $0x0
  800bd6:	ff 75 10             	pushl  0x10(%ebp)
  800bd9:	ff 75 0c             	pushl  0xc(%ebp)
  800bdc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800bdf:	ba 01 00 00 00       	mov    $0x1,%edx
  800be4:	b8 04 00 00 00       	mov    $0x4,%eax
  800be9:	e8 da fe ff ff       	call   800ac8 <syscall>
}
  800bee:	c9                   	leave  
  800bef:	c3                   	ret    

00800bf0 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800bf0:	55                   	push   %ebp
  800bf1:	89 e5                	mov    %esp,%ebp
  800bf3:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
  800bf6:	ff 75 18             	pushl  0x18(%ebp)
  800bf9:	ff 75 14             	pushl  0x14(%ebp)
  800bfc:	ff 75 10             	pushl  0x10(%ebp)
  800bff:	ff 75 0c             	pushl  0xc(%ebp)
  800c02:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c05:	ba 01 00 00 00       	mov    $0x1,%edx
  800c0a:	b8 05 00 00 00       	mov    $0x5,%eax
  800c0f:	e8 b4 fe ff ff       	call   800ac8 <syscall>
}
  800c14:	c9                   	leave  
  800c15:	c3                   	ret    

00800c16 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c16:	55                   	push   %ebp
  800c17:	89 e5                	mov    %esp,%ebp
  800c19:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  800c1c:	6a 00                	push   $0x0
  800c1e:	6a 00                	push   $0x0
  800c20:	6a 00                	push   $0x0
  800c22:	ff 75 0c             	pushl  0xc(%ebp)
  800c25:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c28:	ba 01 00 00 00       	mov    $0x1,%edx
  800c2d:	b8 06 00 00 00       	mov    $0x6,%eax
  800c32:	e8 91 fe ff ff       	call   800ac8 <syscall>
}
  800c37:	c9                   	leave  
  800c38:	c3                   	ret    

00800c39 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c39:	55                   	push   %ebp
  800c3a:	89 e5                	mov    %esp,%ebp
  800c3c:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  800c3f:	6a 00                	push   $0x0
  800c41:	6a 00                	push   $0x0
  800c43:	6a 00                	push   $0x0
  800c45:	ff 75 0c             	pushl  0xc(%ebp)
  800c48:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c4b:	ba 01 00 00 00       	mov    $0x1,%edx
  800c50:	b8 08 00 00 00       	mov    $0x8,%eax
  800c55:	e8 6e fe ff ff       	call   800ac8 <syscall>
}
  800c5a:	c9                   	leave  
  800c5b:	c3                   	ret    

00800c5c <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800c5c:	55                   	push   %ebp
  800c5d:	89 e5                	mov    %esp,%ebp
  800c5f:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
  800c62:	6a 00                	push   $0x0
  800c64:	6a 00                	push   $0x0
  800c66:	6a 00                	push   $0x0
  800c68:	ff 75 0c             	pushl  0xc(%ebp)
  800c6b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c6e:	ba 01 00 00 00       	mov    $0x1,%edx
  800c73:	b8 09 00 00 00       	mov    $0x9,%eax
  800c78:	e8 4b fe ff ff       	call   800ac8 <syscall>
}
  800c7d:	c9                   	leave  
  800c7e:	c3                   	ret    

00800c7f <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800c7f:	55                   	push   %ebp
  800c80:	89 e5                	mov    %esp,%ebp
  800c82:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  800c85:	6a 00                	push   $0x0
  800c87:	6a 00                	push   $0x0
  800c89:	6a 00                	push   $0x0
  800c8b:	ff 75 0c             	pushl  0xc(%ebp)
  800c8e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c91:	ba 01 00 00 00       	mov    $0x1,%edx
  800c96:	b8 0a 00 00 00       	mov    $0xa,%eax
  800c9b:	e8 28 fe ff ff       	call   800ac8 <syscall>
}
  800ca0:	c9                   	leave  
  800ca1:	c3                   	ret    

00800ca2 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800ca2:	55                   	push   %ebp
  800ca3:	89 e5                	mov    %esp,%ebp
  800ca5:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  800ca8:	6a 00                	push   $0x0
  800caa:	ff 75 14             	pushl  0x14(%ebp)
  800cad:	ff 75 10             	pushl  0x10(%ebp)
  800cb0:	ff 75 0c             	pushl  0xc(%ebp)
  800cb3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800cb6:	ba 00 00 00 00       	mov    $0x0,%edx
  800cbb:	b8 0c 00 00 00       	mov    $0xc,%eax
  800cc0:	e8 03 fe ff ff       	call   800ac8 <syscall>
}
  800cc5:	c9                   	leave  
  800cc6:	c3                   	ret    

00800cc7 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800cc7:	55                   	push   %ebp
  800cc8:	89 e5                	mov    %esp,%ebp
  800cca:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  800ccd:	6a 00                	push   $0x0
  800ccf:	6a 00                	push   $0x0
  800cd1:	6a 00                	push   $0x0
  800cd3:	6a 00                	push   $0x0
  800cd5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800cd8:	ba 01 00 00 00       	mov    $0x1,%edx
  800cdd:	b8 0d 00 00 00       	mov    $0xd,%eax
  800ce2:	e8 e1 fd ff ff       	call   800ac8 <syscall>
}
  800ce7:	c9                   	leave  
  800ce8:	c3                   	ret    

00800ce9 <sys_set_priority>:

int
sys_set_priority(envid_t envid, uint32_t new_priority)
{
  800ce9:	55                   	push   %ebp
  800cea:	89 e5                	mov    %esp,%ebp
  800cec:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_set_priority, 0, envid, new_priority, 0, 0, 0);
  800cef:	6a 00                	push   $0x0
  800cf1:	6a 00                	push   $0x0
  800cf3:	6a 00                	push   $0x0
  800cf5:	ff 75 0c             	pushl  0xc(%ebp)
  800cf8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800cfb:	ba 00 00 00 00       	mov    $0x0,%edx
  800d00:	b8 0e 00 00 00       	mov    $0xe,%eax
  800d05:	e8 be fd ff ff       	call   800ac8 <syscall>
}
  800d0a:	c9                   	leave  
  800d0b:	c3                   	ret    

00800d0c <sys_exec>:

int
sys_exec(uint32_t eip, uint32_t esp, void * ph, uint32_t elf_phnum)
{
  800d0c:	55                   	push   %ebp
  800d0d:	89 e5                	mov    %esp,%ebp
  800d0f:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_exec, 0, eip, esp, (uint32_t)ph, elf_phnum, 0);
  800d12:	6a 00                	push   $0x0
  800d14:	ff 75 14             	pushl  0x14(%ebp)
  800d17:	ff 75 10             	pushl  0x10(%ebp)
  800d1a:	ff 75 0c             	pushl  0xc(%ebp)
  800d1d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d20:	ba 00 00 00 00       	mov    $0x0,%edx
  800d25:	b8 0f 00 00 00       	mov    $0xf,%eax
  800d2a:	e8 99 fd ff ff       	call   800ac8 <syscall>
} 
  800d2f:	c9                   	leave  
  800d30:	c3                   	ret    

00800d31 <sys_join>:

// thread:
int
sys_join(envid_t envid)
{
  800d31:	55                   	push   %ebp
  800d32:	89 e5                	mov    %esp,%ebp
  800d34:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_join, 0, envid, 0, 0, 0, 0);
  800d37:	6a 00                	push   $0x0
  800d39:	6a 00                	push   $0x0
  800d3b:	6a 00                	push   $0x0
  800d3d:	6a 00                	push   $0x0
  800d3f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d42:	ba 00 00 00 00       	mov    $0x0,%edx
  800d47:	b8 11 00 00 00       	mov    $0x11,%eax
  800d4c:	e8 77 fd ff ff       	call   800ac8 <syscall>
}
  800d51:	c9                   	leave  
  800d52:	c3                   	ret    

00800d53 <sys_getpid>:

envid_t
sys_getpid(void)
{
  800d53:	55                   	push   %ebp
  800d54:	89 e5                	mov    %esp,%ebp
  800d56:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_getpid, 0, 0, 0, 0, 0, 0);
  800d59:	6a 00                	push   $0x0
  800d5b:	6a 00                	push   $0x0
  800d5d:	6a 00                	push   $0x0
  800d5f:	6a 00                	push   $0x0
  800d61:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d66:	ba 00 00 00 00       	mov    $0x0,%edx
  800d6b:	b8 10 00 00 00       	mov    $0x10,%eax
  800d70:	e8 53 fd ff ff       	call   800ac8 <syscall>
  800d75:	c9                   	leave  
  800d76:	c3                   	ret    
	...

00800d78 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800d78:	55                   	push   %ebp
  800d79:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800d7b:	8b 45 08             	mov    0x8(%ebp),%eax
  800d7e:	05 00 00 00 30       	add    $0x30000000,%eax
  800d83:	c1 e8 0c             	shr    $0xc,%eax
}
  800d86:	c9                   	leave  
  800d87:	c3                   	ret    

00800d88 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800d88:	55                   	push   %ebp
  800d89:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800d8b:	ff 75 08             	pushl  0x8(%ebp)
  800d8e:	e8 e5 ff ff ff       	call   800d78 <fd2num>
  800d93:	83 c4 04             	add    $0x4,%esp
  800d96:	05 20 00 0d 00       	add    $0xd0020,%eax
  800d9b:	c1 e0 0c             	shl    $0xc,%eax
}
  800d9e:	c9                   	leave  
  800d9f:	c3                   	ret    

00800da0 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800da0:	55                   	push   %ebp
  800da1:	89 e5                	mov    %esp,%ebp
  800da3:	53                   	push   %ebx
  800da4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800da7:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  800dac:	a8 01                	test   $0x1,%al
  800dae:	74 34                	je     800de4 <fd_alloc+0x44>
  800db0:	a1 00 00 74 ef       	mov    0xef740000,%eax
  800db5:	a8 01                	test   $0x1,%al
  800db7:	74 32                	je     800deb <fd_alloc+0x4b>
  800db9:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
  800dbe:	89 c1                	mov    %eax,%ecx
  800dc0:	89 c2                	mov    %eax,%edx
  800dc2:	c1 ea 16             	shr    $0x16,%edx
  800dc5:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800dcc:	f6 c2 01             	test   $0x1,%dl
  800dcf:	74 1f                	je     800df0 <fd_alloc+0x50>
  800dd1:	89 c2                	mov    %eax,%edx
  800dd3:	c1 ea 0c             	shr    $0xc,%edx
  800dd6:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800ddd:	f6 c2 01             	test   $0x1,%dl
  800de0:	75 17                	jne    800df9 <fd_alloc+0x59>
  800de2:	eb 0c                	jmp    800df0 <fd_alloc+0x50>
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  800de4:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
  800de9:	eb 05                	jmp    800df0 <fd_alloc+0x50>
  800deb:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
  800df0:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  800df2:	b8 00 00 00 00       	mov    $0x0,%eax
  800df7:	eb 17                	jmp    800e10 <fd_alloc+0x70>
  800df9:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800dfe:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800e03:	75 b9                	jne    800dbe <fd_alloc+0x1e>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800e05:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  800e0b:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800e10:	5b                   	pop    %ebx
  800e11:	c9                   	leave  
  800e12:	c3                   	ret    

00800e13 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800e13:	55                   	push   %ebp
  800e14:	89 e5                	mov    %esp,%ebp
  800e16:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800e19:	83 f8 1f             	cmp    $0x1f,%eax
  800e1c:	77 36                	ja     800e54 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800e1e:	05 00 00 0d 00       	add    $0xd0000,%eax
  800e23:	c1 e0 0c             	shl    $0xc,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800e26:	89 c2                	mov    %eax,%edx
  800e28:	c1 ea 16             	shr    $0x16,%edx
  800e2b:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800e32:	f6 c2 01             	test   $0x1,%dl
  800e35:	74 24                	je     800e5b <fd_lookup+0x48>
  800e37:	89 c2                	mov    %eax,%edx
  800e39:	c1 ea 0c             	shr    $0xc,%edx
  800e3c:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e43:	f6 c2 01             	test   $0x1,%dl
  800e46:	74 1a                	je     800e62 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800e48:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e4b:	89 02                	mov    %eax,(%edx)
	return 0;
  800e4d:	b8 00 00 00 00       	mov    $0x0,%eax
  800e52:	eb 13                	jmp    800e67 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800e54:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800e59:	eb 0c                	jmp    800e67 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800e5b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800e60:	eb 05                	jmp    800e67 <fd_lookup+0x54>
  800e62:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800e67:	c9                   	leave  
  800e68:	c3                   	ret    

00800e69 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800e69:	55                   	push   %ebp
  800e6a:	89 e5                	mov    %esp,%ebp
  800e6c:	53                   	push   %ebx
  800e6d:	83 ec 04             	sub    $0x4,%esp
  800e70:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e73:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  800e76:	39 0d 04 30 80 00    	cmp    %ecx,0x803004
  800e7c:	74 0d                	je     800e8b <dev_lookup+0x22>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800e7e:	b8 00 00 00 00       	mov    $0x0,%eax
  800e83:	eb 14                	jmp    800e99 <dev_lookup+0x30>
		if (devtab[i]->dev_id == dev_id) {
  800e85:	39 0a                	cmp    %ecx,(%edx)
  800e87:	75 10                	jne    800e99 <dev_lookup+0x30>
  800e89:	eb 05                	jmp    800e90 <dev_lookup+0x27>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800e8b:	ba 04 30 80 00       	mov    $0x803004,%edx
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
  800e90:	89 13                	mov    %edx,(%ebx)
			return 0;
  800e92:	b8 00 00 00 00       	mov    $0x0,%eax
  800e97:	eb 31                	jmp    800eca <dev_lookup+0x61>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800e99:	40                   	inc    %eax
  800e9a:	8b 14 85 48 22 80 00 	mov    0x802248(,%eax,4),%edx
  800ea1:	85 d2                	test   %edx,%edx
  800ea3:	75 e0                	jne    800e85 <dev_lookup+0x1c>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800ea5:	a1 04 40 80 00       	mov    0x804004,%eax
  800eaa:	8b 40 48             	mov    0x48(%eax),%eax
  800ead:	83 ec 04             	sub    $0x4,%esp
  800eb0:	51                   	push   %ecx
  800eb1:	50                   	push   %eax
  800eb2:	68 cc 21 80 00       	push   $0x8021cc
  800eb7:	e8 d8 f2 ff ff       	call   800194 <cprintf>
	*dev = 0;
  800ebc:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  800ec2:	83 c4 10             	add    $0x10,%esp
  800ec5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800eca:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ecd:	c9                   	leave  
  800ece:	c3                   	ret    

00800ecf <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800ecf:	55                   	push   %ebp
  800ed0:	89 e5                	mov    %esp,%ebp
  800ed2:	56                   	push   %esi
  800ed3:	53                   	push   %ebx
  800ed4:	83 ec 20             	sub    $0x20,%esp
  800ed7:	8b 75 08             	mov    0x8(%ebp),%esi
  800eda:	8a 45 0c             	mov    0xc(%ebp),%al
  800edd:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800ee0:	56                   	push   %esi
  800ee1:	e8 92 fe ff ff       	call   800d78 <fd2num>
  800ee6:	8d 55 f4             	lea    -0xc(%ebp),%edx
  800ee9:	89 14 24             	mov    %edx,(%esp)
  800eec:	50                   	push   %eax
  800eed:	e8 21 ff ff ff       	call   800e13 <fd_lookup>
  800ef2:	89 c3                	mov    %eax,%ebx
  800ef4:	83 c4 08             	add    $0x8,%esp
  800ef7:	85 c0                	test   %eax,%eax
  800ef9:	78 05                	js     800f00 <fd_close+0x31>
	    || fd != fd2)
  800efb:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800efe:	74 0d                	je     800f0d <fd_close+0x3e>
		return (must_exist ? r : 0);
  800f00:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  800f04:	75 48                	jne    800f4e <fd_close+0x7f>
  800f06:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f0b:	eb 41                	jmp    800f4e <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800f0d:	83 ec 08             	sub    $0x8,%esp
  800f10:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800f13:	50                   	push   %eax
  800f14:	ff 36                	pushl  (%esi)
  800f16:	e8 4e ff ff ff       	call   800e69 <dev_lookup>
  800f1b:	89 c3                	mov    %eax,%ebx
  800f1d:	83 c4 10             	add    $0x10,%esp
  800f20:	85 c0                	test   %eax,%eax
  800f22:	78 1c                	js     800f40 <fd_close+0x71>
		if (dev->dev_close)
  800f24:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800f27:	8b 40 10             	mov    0x10(%eax),%eax
  800f2a:	85 c0                	test   %eax,%eax
  800f2c:	74 0d                	je     800f3b <fd_close+0x6c>
			r = (*dev->dev_close)(fd);
  800f2e:	83 ec 0c             	sub    $0xc,%esp
  800f31:	56                   	push   %esi
  800f32:	ff d0                	call   *%eax
  800f34:	89 c3                	mov    %eax,%ebx
  800f36:	83 c4 10             	add    $0x10,%esp
  800f39:	eb 05                	jmp    800f40 <fd_close+0x71>
		else
			r = 0;
  800f3b:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800f40:	83 ec 08             	sub    $0x8,%esp
  800f43:	56                   	push   %esi
  800f44:	6a 00                	push   $0x0
  800f46:	e8 cb fc ff ff       	call   800c16 <sys_page_unmap>
	return r;
  800f4b:	83 c4 10             	add    $0x10,%esp
}
  800f4e:	89 d8                	mov    %ebx,%eax
  800f50:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800f53:	5b                   	pop    %ebx
  800f54:	5e                   	pop    %esi
  800f55:	c9                   	leave  
  800f56:	c3                   	ret    

00800f57 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800f57:	55                   	push   %ebp
  800f58:	89 e5                	mov    %esp,%ebp
  800f5a:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800f5d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f60:	50                   	push   %eax
  800f61:	ff 75 08             	pushl  0x8(%ebp)
  800f64:	e8 aa fe ff ff       	call   800e13 <fd_lookup>
  800f69:	83 c4 08             	add    $0x8,%esp
  800f6c:	85 c0                	test   %eax,%eax
  800f6e:	78 10                	js     800f80 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800f70:	83 ec 08             	sub    $0x8,%esp
  800f73:	6a 01                	push   $0x1
  800f75:	ff 75 f4             	pushl  -0xc(%ebp)
  800f78:	e8 52 ff ff ff       	call   800ecf <fd_close>
  800f7d:	83 c4 10             	add    $0x10,%esp
}
  800f80:	c9                   	leave  
  800f81:	c3                   	ret    

00800f82 <close_all>:

void
close_all(void)
{
  800f82:	55                   	push   %ebp
  800f83:	89 e5                	mov    %esp,%ebp
  800f85:	53                   	push   %ebx
  800f86:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800f89:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800f8e:	83 ec 0c             	sub    $0xc,%esp
  800f91:	53                   	push   %ebx
  800f92:	e8 c0 ff ff ff       	call   800f57 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800f97:	43                   	inc    %ebx
  800f98:	83 c4 10             	add    $0x10,%esp
  800f9b:	83 fb 20             	cmp    $0x20,%ebx
  800f9e:	75 ee                	jne    800f8e <close_all+0xc>
		close(i);
}
  800fa0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800fa3:	c9                   	leave  
  800fa4:	c3                   	ret    

00800fa5 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800fa5:	55                   	push   %ebp
  800fa6:	89 e5                	mov    %esp,%ebp
  800fa8:	57                   	push   %edi
  800fa9:	56                   	push   %esi
  800faa:	53                   	push   %ebx
  800fab:	83 ec 2c             	sub    $0x2c,%esp
  800fae:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800fb1:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800fb4:	50                   	push   %eax
  800fb5:	ff 75 08             	pushl  0x8(%ebp)
  800fb8:	e8 56 fe ff ff       	call   800e13 <fd_lookup>
  800fbd:	89 c3                	mov    %eax,%ebx
  800fbf:	83 c4 08             	add    $0x8,%esp
  800fc2:	85 c0                	test   %eax,%eax
  800fc4:	0f 88 c0 00 00 00    	js     80108a <dup+0xe5>
		return r;
	close(newfdnum);
  800fca:	83 ec 0c             	sub    $0xc,%esp
  800fcd:	57                   	push   %edi
  800fce:	e8 84 ff ff ff       	call   800f57 <close>

	newfd = INDEX2FD(newfdnum);
  800fd3:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  800fd9:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  800fdc:	83 c4 04             	add    $0x4,%esp
  800fdf:	ff 75 e4             	pushl  -0x1c(%ebp)
  800fe2:	e8 a1 fd ff ff       	call   800d88 <fd2data>
  800fe7:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  800fe9:	89 34 24             	mov    %esi,(%esp)
  800fec:	e8 97 fd ff ff       	call   800d88 <fd2data>
  800ff1:	83 c4 10             	add    $0x10,%esp
  800ff4:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800ff7:	89 d8                	mov    %ebx,%eax
  800ff9:	c1 e8 16             	shr    $0x16,%eax
  800ffc:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801003:	a8 01                	test   $0x1,%al
  801005:	74 37                	je     80103e <dup+0x99>
  801007:	89 d8                	mov    %ebx,%eax
  801009:	c1 e8 0c             	shr    $0xc,%eax
  80100c:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801013:	f6 c2 01             	test   $0x1,%dl
  801016:	74 26                	je     80103e <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801018:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80101f:	83 ec 0c             	sub    $0xc,%esp
  801022:	25 07 0e 00 00       	and    $0xe07,%eax
  801027:	50                   	push   %eax
  801028:	ff 75 d4             	pushl  -0x2c(%ebp)
  80102b:	6a 00                	push   $0x0
  80102d:	53                   	push   %ebx
  80102e:	6a 00                	push   $0x0
  801030:	e8 bb fb ff ff       	call   800bf0 <sys_page_map>
  801035:	89 c3                	mov    %eax,%ebx
  801037:	83 c4 20             	add    $0x20,%esp
  80103a:	85 c0                	test   %eax,%eax
  80103c:	78 2d                	js     80106b <dup+0xc6>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80103e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801041:	89 c2                	mov    %eax,%edx
  801043:	c1 ea 0c             	shr    $0xc,%edx
  801046:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80104d:	83 ec 0c             	sub    $0xc,%esp
  801050:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  801056:	52                   	push   %edx
  801057:	56                   	push   %esi
  801058:	6a 00                	push   $0x0
  80105a:	50                   	push   %eax
  80105b:	6a 00                	push   $0x0
  80105d:	e8 8e fb ff ff       	call   800bf0 <sys_page_map>
  801062:	89 c3                	mov    %eax,%ebx
  801064:	83 c4 20             	add    $0x20,%esp
  801067:	85 c0                	test   %eax,%eax
  801069:	79 1d                	jns    801088 <dup+0xe3>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80106b:	83 ec 08             	sub    $0x8,%esp
  80106e:	56                   	push   %esi
  80106f:	6a 00                	push   $0x0
  801071:	e8 a0 fb ff ff       	call   800c16 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801076:	83 c4 08             	add    $0x8,%esp
  801079:	ff 75 d4             	pushl  -0x2c(%ebp)
  80107c:	6a 00                	push   $0x0
  80107e:	e8 93 fb ff ff       	call   800c16 <sys_page_unmap>
	return r;
  801083:	83 c4 10             	add    $0x10,%esp
  801086:	eb 02                	jmp    80108a <dup+0xe5>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  801088:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  80108a:	89 d8                	mov    %ebx,%eax
  80108c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80108f:	5b                   	pop    %ebx
  801090:	5e                   	pop    %esi
  801091:	5f                   	pop    %edi
  801092:	c9                   	leave  
  801093:	c3                   	ret    

00801094 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801094:	55                   	push   %ebp
  801095:	89 e5                	mov    %esp,%ebp
  801097:	53                   	push   %ebx
  801098:	83 ec 14             	sub    $0x14,%esp
  80109b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80109e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8010a1:	50                   	push   %eax
  8010a2:	53                   	push   %ebx
  8010a3:	e8 6b fd ff ff       	call   800e13 <fd_lookup>
  8010a8:	83 c4 08             	add    $0x8,%esp
  8010ab:	85 c0                	test   %eax,%eax
  8010ad:	78 67                	js     801116 <read+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8010af:	83 ec 08             	sub    $0x8,%esp
  8010b2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8010b5:	50                   	push   %eax
  8010b6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8010b9:	ff 30                	pushl  (%eax)
  8010bb:	e8 a9 fd ff ff       	call   800e69 <dev_lookup>
  8010c0:	83 c4 10             	add    $0x10,%esp
  8010c3:	85 c0                	test   %eax,%eax
  8010c5:	78 4f                	js     801116 <read+0x82>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8010c7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8010ca:	8b 50 08             	mov    0x8(%eax),%edx
  8010cd:	83 e2 03             	and    $0x3,%edx
  8010d0:	83 fa 01             	cmp    $0x1,%edx
  8010d3:	75 21                	jne    8010f6 <read+0x62>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8010d5:	a1 04 40 80 00       	mov    0x804004,%eax
  8010da:	8b 40 48             	mov    0x48(%eax),%eax
  8010dd:	83 ec 04             	sub    $0x4,%esp
  8010e0:	53                   	push   %ebx
  8010e1:	50                   	push   %eax
  8010e2:	68 0d 22 80 00       	push   $0x80220d
  8010e7:	e8 a8 f0 ff ff       	call   800194 <cprintf>
		return -E_INVAL;
  8010ec:	83 c4 10             	add    $0x10,%esp
  8010ef:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8010f4:	eb 20                	jmp    801116 <read+0x82>
	}
	if (!dev->dev_read)
  8010f6:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8010f9:	8b 52 08             	mov    0x8(%edx),%edx
  8010fc:	85 d2                	test   %edx,%edx
  8010fe:	74 11                	je     801111 <read+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801100:	83 ec 04             	sub    $0x4,%esp
  801103:	ff 75 10             	pushl  0x10(%ebp)
  801106:	ff 75 0c             	pushl  0xc(%ebp)
  801109:	50                   	push   %eax
  80110a:	ff d2                	call   *%edx
  80110c:	83 c4 10             	add    $0x10,%esp
  80110f:	eb 05                	jmp    801116 <read+0x82>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801111:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  801116:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801119:	c9                   	leave  
  80111a:	c3                   	ret    

0080111b <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80111b:	55                   	push   %ebp
  80111c:	89 e5                	mov    %esp,%ebp
  80111e:	57                   	push   %edi
  80111f:	56                   	push   %esi
  801120:	53                   	push   %ebx
  801121:	83 ec 0c             	sub    $0xc,%esp
  801124:	8b 7d 08             	mov    0x8(%ebp),%edi
  801127:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80112a:	85 f6                	test   %esi,%esi
  80112c:	74 31                	je     80115f <readn+0x44>
  80112e:	b8 00 00 00 00       	mov    $0x0,%eax
  801133:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = read(fdnum, (char*)buf + tot, n - tot);
  801138:	83 ec 04             	sub    $0x4,%esp
  80113b:	89 f2                	mov    %esi,%edx
  80113d:	29 c2                	sub    %eax,%edx
  80113f:	52                   	push   %edx
  801140:	03 45 0c             	add    0xc(%ebp),%eax
  801143:	50                   	push   %eax
  801144:	57                   	push   %edi
  801145:	e8 4a ff ff ff       	call   801094 <read>
		if (m < 0)
  80114a:	83 c4 10             	add    $0x10,%esp
  80114d:	85 c0                	test   %eax,%eax
  80114f:	78 17                	js     801168 <readn+0x4d>
			return m;
		if (m == 0)
  801151:	85 c0                	test   %eax,%eax
  801153:	74 11                	je     801166 <readn+0x4b>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801155:	01 c3                	add    %eax,%ebx
  801157:	89 d8                	mov    %ebx,%eax
  801159:	39 f3                	cmp    %esi,%ebx
  80115b:	72 db                	jb     801138 <readn+0x1d>
  80115d:	eb 09                	jmp    801168 <readn+0x4d>
  80115f:	b8 00 00 00 00       	mov    $0x0,%eax
  801164:	eb 02                	jmp    801168 <readn+0x4d>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  801166:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  801168:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80116b:	5b                   	pop    %ebx
  80116c:	5e                   	pop    %esi
  80116d:	5f                   	pop    %edi
  80116e:	c9                   	leave  
  80116f:	c3                   	ret    

00801170 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801170:	55                   	push   %ebp
  801171:	89 e5                	mov    %esp,%ebp
  801173:	53                   	push   %ebx
  801174:	83 ec 14             	sub    $0x14,%esp
  801177:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80117a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80117d:	50                   	push   %eax
  80117e:	53                   	push   %ebx
  80117f:	e8 8f fc ff ff       	call   800e13 <fd_lookup>
  801184:	83 c4 08             	add    $0x8,%esp
  801187:	85 c0                	test   %eax,%eax
  801189:	78 62                	js     8011ed <write+0x7d>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80118b:	83 ec 08             	sub    $0x8,%esp
  80118e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801191:	50                   	push   %eax
  801192:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801195:	ff 30                	pushl  (%eax)
  801197:	e8 cd fc ff ff       	call   800e69 <dev_lookup>
  80119c:	83 c4 10             	add    $0x10,%esp
  80119f:	85 c0                	test   %eax,%eax
  8011a1:	78 4a                	js     8011ed <write+0x7d>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8011a3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011a6:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8011aa:	75 21                	jne    8011cd <write+0x5d>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8011ac:	a1 04 40 80 00       	mov    0x804004,%eax
  8011b1:	8b 40 48             	mov    0x48(%eax),%eax
  8011b4:	83 ec 04             	sub    $0x4,%esp
  8011b7:	53                   	push   %ebx
  8011b8:	50                   	push   %eax
  8011b9:	68 29 22 80 00       	push   $0x802229
  8011be:	e8 d1 ef ff ff       	call   800194 <cprintf>
		return -E_INVAL;
  8011c3:	83 c4 10             	add    $0x10,%esp
  8011c6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8011cb:	eb 20                	jmp    8011ed <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8011cd:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8011d0:	8b 52 0c             	mov    0xc(%edx),%edx
  8011d3:	85 d2                	test   %edx,%edx
  8011d5:	74 11                	je     8011e8 <write+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8011d7:	83 ec 04             	sub    $0x4,%esp
  8011da:	ff 75 10             	pushl  0x10(%ebp)
  8011dd:	ff 75 0c             	pushl  0xc(%ebp)
  8011e0:	50                   	push   %eax
  8011e1:	ff d2                	call   *%edx
  8011e3:	83 c4 10             	add    $0x10,%esp
  8011e6:	eb 05                	jmp    8011ed <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8011e8:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  8011ed:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8011f0:	c9                   	leave  
  8011f1:	c3                   	ret    

008011f2 <seek>:

int
seek(int fdnum, off_t offset)
{
  8011f2:	55                   	push   %ebp
  8011f3:	89 e5                	mov    %esp,%ebp
  8011f5:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8011f8:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8011fb:	50                   	push   %eax
  8011fc:	ff 75 08             	pushl  0x8(%ebp)
  8011ff:	e8 0f fc ff ff       	call   800e13 <fd_lookup>
  801204:	83 c4 08             	add    $0x8,%esp
  801207:	85 c0                	test   %eax,%eax
  801209:	78 0e                	js     801219 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  80120b:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80120e:	8b 55 0c             	mov    0xc(%ebp),%edx
  801211:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801214:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801219:	c9                   	leave  
  80121a:	c3                   	ret    

0080121b <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80121b:	55                   	push   %ebp
  80121c:	89 e5                	mov    %esp,%ebp
  80121e:	53                   	push   %ebx
  80121f:	83 ec 14             	sub    $0x14,%esp
  801222:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801225:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801228:	50                   	push   %eax
  801229:	53                   	push   %ebx
  80122a:	e8 e4 fb ff ff       	call   800e13 <fd_lookup>
  80122f:	83 c4 08             	add    $0x8,%esp
  801232:	85 c0                	test   %eax,%eax
  801234:	78 5f                	js     801295 <ftruncate+0x7a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801236:	83 ec 08             	sub    $0x8,%esp
  801239:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80123c:	50                   	push   %eax
  80123d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801240:	ff 30                	pushl  (%eax)
  801242:	e8 22 fc ff ff       	call   800e69 <dev_lookup>
  801247:	83 c4 10             	add    $0x10,%esp
  80124a:	85 c0                	test   %eax,%eax
  80124c:	78 47                	js     801295 <ftruncate+0x7a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80124e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801251:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801255:	75 21                	jne    801278 <ftruncate+0x5d>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801257:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80125c:	8b 40 48             	mov    0x48(%eax),%eax
  80125f:	83 ec 04             	sub    $0x4,%esp
  801262:	53                   	push   %ebx
  801263:	50                   	push   %eax
  801264:	68 ec 21 80 00       	push   $0x8021ec
  801269:	e8 26 ef ff ff       	call   800194 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80126e:	83 c4 10             	add    $0x10,%esp
  801271:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801276:	eb 1d                	jmp    801295 <ftruncate+0x7a>
	}
	if (!dev->dev_trunc)
  801278:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80127b:	8b 52 18             	mov    0x18(%edx),%edx
  80127e:	85 d2                	test   %edx,%edx
  801280:	74 0e                	je     801290 <ftruncate+0x75>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801282:	83 ec 08             	sub    $0x8,%esp
  801285:	ff 75 0c             	pushl  0xc(%ebp)
  801288:	50                   	push   %eax
  801289:	ff d2                	call   *%edx
  80128b:	83 c4 10             	add    $0x10,%esp
  80128e:	eb 05                	jmp    801295 <ftruncate+0x7a>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801290:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  801295:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801298:	c9                   	leave  
  801299:	c3                   	ret    

0080129a <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80129a:	55                   	push   %ebp
  80129b:	89 e5                	mov    %esp,%ebp
  80129d:	53                   	push   %ebx
  80129e:	83 ec 14             	sub    $0x14,%esp
  8012a1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8012a4:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012a7:	50                   	push   %eax
  8012a8:	ff 75 08             	pushl  0x8(%ebp)
  8012ab:	e8 63 fb ff ff       	call   800e13 <fd_lookup>
  8012b0:	83 c4 08             	add    $0x8,%esp
  8012b3:	85 c0                	test   %eax,%eax
  8012b5:	78 52                	js     801309 <fstat+0x6f>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012b7:	83 ec 08             	sub    $0x8,%esp
  8012ba:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012bd:	50                   	push   %eax
  8012be:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012c1:	ff 30                	pushl  (%eax)
  8012c3:	e8 a1 fb ff ff       	call   800e69 <dev_lookup>
  8012c8:	83 c4 10             	add    $0x10,%esp
  8012cb:	85 c0                	test   %eax,%eax
  8012cd:	78 3a                	js     801309 <fstat+0x6f>
		return r;
	if (!dev->dev_stat)
  8012cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8012d2:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8012d6:	74 2c                	je     801304 <fstat+0x6a>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8012d8:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8012db:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8012e2:	00 00 00 
	stat->st_isdir = 0;
  8012e5:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8012ec:	00 00 00 
	stat->st_dev = dev;
  8012ef:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8012f5:	83 ec 08             	sub    $0x8,%esp
  8012f8:	53                   	push   %ebx
  8012f9:	ff 75 f0             	pushl  -0x10(%ebp)
  8012fc:	ff 50 14             	call   *0x14(%eax)
  8012ff:	83 c4 10             	add    $0x10,%esp
  801302:	eb 05                	jmp    801309 <fstat+0x6f>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801304:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801309:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80130c:	c9                   	leave  
  80130d:	c3                   	ret    

0080130e <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80130e:	55                   	push   %ebp
  80130f:	89 e5                	mov    %esp,%ebp
  801311:	56                   	push   %esi
  801312:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801313:	83 ec 08             	sub    $0x8,%esp
  801316:	6a 00                	push   $0x0
  801318:	ff 75 08             	pushl  0x8(%ebp)
  80131b:	e8 78 01 00 00       	call   801498 <open>
  801320:	89 c3                	mov    %eax,%ebx
  801322:	83 c4 10             	add    $0x10,%esp
  801325:	85 c0                	test   %eax,%eax
  801327:	78 1b                	js     801344 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801329:	83 ec 08             	sub    $0x8,%esp
  80132c:	ff 75 0c             	pushl  0xc(%ebp)
  80132f:	50                   	push   %eax
  801330:	e8 65 ff ff ff       	call   80129a <fstat>
  801335:	89 c6                	mov    %eax,%esi
	close(fd);
  801337:	89 1c 24             	mov    %ebx,(%esp)
  80133a:	e8 18 fc ff ff       	call   800f57 <close>
	return r;
  80133f:	83 c4 10             	add    $0x10,%esp
  801342:	89 f3                	mov    %esi,%ebx
}
  801344:	89 d8                	mov    %ebx,%eax
  801346:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801349:	5b                   	pop    %ebx
  80134a:	5e                   	pop    %esi
  80134b:	c9                   	leave  
  80134c:	c3                   	ret    
  80134d:	00 00                	add    %al,(%eax)
	...

00801350 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801350:	55                   	push   %ebp
  801351:	89 e5                	mov    %esp,%ebp
  801353:	56                   	push   %esi
  801354:	53                   	push   %ebx
  801355:	89 c3                	mov    %eax,%ebx
  801357:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  801359:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801360:	75 12                	jne    801374 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801362:	83 ec 0c             	sub    $0xc,%esp
  801365:	6a 01                	push   $0x1
  801367:	e8 d2 07 00 00       	call   801b3e <ipc_find_env>
  80136c:	a3 00 40 80 00       	mov    %eax,0x804000
  801371:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801374:	6a 07                	push   $0x7
  801376:	68 00 50 80 00       	push   $0x805000
  80137b:	53                   	push   %ebx
  80137c:	ff 35 00 40 80 00    	pushl  0x804000
  801382:	e8 62 07 00 00       	call   801ae9 <ipc_send>
	
	return ipc_recv(NULL, dstva, NULL);
  801387:	83 c4 0c             	add    $0xc,%esp
  80138a:	6a 00                	push   $0x0
  80138c:	56                   	push   %esi
  80138d:	6a 00                	push   $0x0
  80138f:	e8 e0 06 00 00       	call   801a74 <ipc_recv>
}
  801394:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801397:	5b                   	pop    %ebx
  801398:	5e                   	pop    %esi
  801399:	c9                   	leave  
  80139a:	c3                   	ret    

0080139b <devfile_stat>:
}


static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80139b:	55                   	push   %ebp
  80139c:	89 e5                	mov    %esp,%ebp
  80139e:	53                   	push   %ebx
  80139f:	83 ec 04             	sub    $0x4,%esp
  8013a2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8013a5:	8b 45 08             	mov    0x8(%ebp),%eax
  8013a8:	8b 40 0c             	mov    0xc(%eax),%eax
  8013ab:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0) {
  8013b0:	ba 00 00 00 00       	mov    $0x0,%edx
  8013b5:	b8 05 00 00 00       	mov    $0x5,%eax
  8013ba:	e8 91 ff ff ff       	call   801350 <fsipc>
  8013bf:	85 c0                	test   %eax,%eax
  8013c1:	78 2c                	js     8013ef <devfile_stat+0x54>
		return r;
	}
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8013c3:	83 ec 08             	sub    $0x8,%esp
  8013c6:	68 00 50 80 00       	push   $0x805000
  8013cb:	53                   	push   %ebx
  8013cc:	e8 79 f3 ff ff       	call   80074a <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8013d1:	a1 80 50 80 00       	mov    0x805080,%eax
  8013d6:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8013dc:	a1 84 50 80 00       	mov    0x805084,%eax
  8013e1:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8013e7:	83 c4 10             	add    $0x10,%esp
  8013ea:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8013ef:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013f2:	c9                   	leave  
  8013f3:	c3                   	ret    

008013f4 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8013f4:	55                   	push   %ebp
  8013f5:	89 e5                	mov    %esp,%ebp
  8013f7:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8013fa:	8b 45 08             	mov    0x8(%ebp),%eax
  8013fd:	8b 40 0c             	mov    0xc(%eax),%eax
  801400:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801405:	ba 00 00 00 00       	mov    $0x0,%edx
  80140a:	b8 06 00 00 00       	mov    $0x6,%eax
  80140f:	e8 3c ff ff ff       	call   801350 <fsipc>
}
  801414:	c9                   	leave  
  801415:	c3                   	ret    

00801416 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801416:	55                   	push   %ebp
  801417:	89 e5                	mov    %esp,%ebp
  801419:	56                   	push   %esi
  80141a:	53                   	push   %ebx
  80141b:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80141e:	8b 45 08             	mov    0x8(%ebp),%eax
  801421:	8b 40 0c             	mov    0xc(%eax),%eax
  801424:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801429:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80142f:	ba 00 00 00 00       	mov    $0x0,%edx
  801434:	b8 03 00 00 00       	mov    $0x3,%eax
  801439:	e8 12 ff ff ff       	call   801350 <fsipc>
  80143e:	89 c3                	mov    %eax,%ebx
  801440:	85 c0                	test   %eax,%eax
  801442:	78 4b                	js     80148f <devfile_read+0x79>
		return r;
	assert(r <= n);
  801444:	39 c6                	cmp    %eax,%esi
  801446:	73 16                	jae    80145e <devfile_read+0x48>
  801448:	68 58 22 80 00       	push   $0x802258
  80144d:	68 5f 22 80 00       	push   $0x80225f
  801452:	6a 7d                	push   $0x7d
  801454:	68 74 22 80 00       	push   $0x802274
  801459:	e8 ce 05 00 00       	call   801a2c <_panic>
	assert(r <= PGSIZE);
  80145e:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801463:	7e 16                	jle    80147b <devfile_read+0x65>
  801465:	68 7f 22 80 00       	push   $0x80227f
  80146a:	68 5f 22 80 00       	push   $0x80225f
  80146f:	6a 7e                	push   $0x7e
  801471:	68 74 22 80 00       	push   $0x802274
  801476:	e8 b1 05 00 00       	call   801a2c <_panic>
	memmove(buf, &fsipcbuf, r);
  80147b:	83 ec 04             	sub    $0x4,%esp
  80147e:	50                   	push   %eax
  80147f:	68 00 50 80 00       	push   $0x805000
  801484:	ff 75 0c             	pushl  0xc(%ebp)
  801487:	e8 7f f4 ff ff       	call   80090b <memmove>
	return r;
  80148c:	83 c4 10             	add    $0x10,%esp
}
  80148f:	89 d8                	mov    %ebx,%eax
  801491:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801494:	5b                   	pop    %ebx
  801495:	5e                   	pop    %esi
  801496:	c9                   	leave  
  801497:	c3                   	ret    

00801498 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801498:	55                   	push   %ebp
  801499:	89 e5                	mov    %esp,%ebp
  80149b:	56                   	push   %esi
  80149c:	53                   	push   %ebx
  80149d:	83 ec 1c             	sub    $0x1c,%esp
  8014a0:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8014a3:	56                   	push   %esi
  8014a4:	e8 4f f2 ff ff       	call   8006f8 <strlen>
  8014a9:	83 c4 10             	add    $0x10,%esp
  8014ac:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8014b1:	7f 65                	jg     801518 <open+0x80>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8014b3:	83 ec 0c             	sub    $0xc,%esp
  8014b6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014b9:	50                   	push   %eax
  8014ba:	e8 e1 f8 ff ff       	call   800da0 <fd_alloc>
  8014bf:	89 c3                	mov    %eax,%ebx
  8014c1:	83 c4 10             	add    $0x10,%esp
  8014c4:	85 c0                	test   %eax,%eax
  8014c6:	78 55                	js     80151d <open+0x85>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8014c8:	83 ec 08             	sub    $0x8,%esp
  8014cb:	56                   	push   %esi
  8014cc:	68 00 50 80 00       	push   $0x805000
  8014d1:	e8 74 f2 ff ff       	call   80074a <strcpy>
	fsipcbuf.open.req_omode = mode;
  8014d6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8014d9:	a3 00 54 80 00       	mov    %eax,0x805400



	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8014de:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8014e1:	b8 01 00 00 00       	mov    $0x1,%eax
  8014e6:	e8 65 fe ff ff       	call   801350 <fsipc>
  8014eb:	89 c3                	mov    %eax,%ebx
  8014ed:	83 c4 10             	add    $0x10,%esp
  8014f0:	85 c0                	test   %eax,%eax
  8014f2:	79 12                	jns    801506 <open+0x6e>
		fd_close(fd, 0);
  8014f4:	83 ec 08             	sub    $0x8,%esp
  8014f7:	6a 00                	push   $0x0
  8014f9:	ff 75 f4             	pushl  -0xc(%ebp)
  8014fc:	e8 ce f9 ff ff       	call   800ecf <fd_close>
		return r;
  801501:	83 c4 10             	add    $0x10,%esp
  801504:	eb 17                	jmp    80151d <open+0x85>
	}

	return fd2num(fd);
  801506:	83 ec 0c             	sub    $0xc,%esp
  801509:	ff 75 f4             	pushl  -0xc(%ebp)
  80150c:	e8 67 f8 ff ff       	call   800d78 <fd2num>
  801511:	89 c3                	mov    %eax,%ebx
  801513:	83 c4 10             	add    $0x10,%esp
  801516:	eb 05                	jmp    80151d <open+0x85>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801518:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  80151d:	89 d8                	mov    %ebx,%eax
  80151f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801522:	5b                   	pop    %ebx
  801523:	5e                   	pop    %esi
  801524:	c9                   	leave  
  801525:	c3                   	ret    
	...

00801528 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801528:	55                   	push   %ebp
  801529:	89 e5                	mov    %esp,%ebp
  80152b:	56                   	push   %esi
  80152c:	53                   	push   %ebx
  80152d:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801530:	83 ec 0c             	sub    $0xc,%esp
  801533:	ff 75 08             	pushl  0x8(%ebp)
  801536:	e8 4d f8 ff ff       	call   800d88 <fd2data>
  80153b:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  80153d:	83 c4 08             	add    $0x8,%esp
  801540:	68 8b 22 80 00       	push   $0x80228b
  801545:	56                   	push   %esi
  801546:	e8 ff f1 ff ff       	call   80074a <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  80154b:	8b 43 04             	mov    0x4(%ebx),%eax
  80154e:	2b 03                	sub    (%ebx),%eax
  801550:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  801556:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  80155d:	00 00 00 
	stat->st_dev = &devpipe;
  801560:	c7 86 88 00 00 00 20 	movl   $0x803020,0x88(%esi)
  801567:	30 80 00 
	return 0;
}
  80156a:	b8 00 00 00 00       	mov    $0x0,%eax
  80156f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801572:	5b                   	pop    %ebx
  801573:	5e                   	pop    %esi
  801574:	c9                   	leave  
  801575:	c3                   	ret    

00801576 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801576:	55                   	push   %ebp
  801577:	89 e5                	mov    %esp,%ebp
  801579:	53                   	push   %ebx
  80157a:	83 ec 0c             	sub    $0xc,%esp
  80157d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801580:	53                   	push   %ebx
  801581:	6a 00                	push   $0x0
  801583:	e8 8e f6 ff ff       	call   800c16 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801588:	89 1c 24             	mov    %ebx,(%esp)
  80158b:	e8 f8 f7 ff ff       	call   800d88 <fd2data>
  801590:	83 c4 08             	add    $0x8,%esp
  801593:	50                   	push   %eax
  801594:	6a 00                	push   $0x0
  801596:	e8 7b f6 ff ff       	call   800c16 <sys_page_unmap>
}
  80159b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80159e:	c9                   	leave  
  80159f:	c3                   	ret    

008015a0 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8015a0:	55                   	push   %ebp
  8015a1:	89 e5                	mov    %esp,%ebp
  8015a3:	57                   	push   %edi
  8015a4:	56                   	push   %esi
  8015a5:	53                   	push   %ebx
  8015a6:	83 ec 1c             	sub    $0x1c,%esp
  8015a9:	89 c7                	mov    %eax,%edi
  8015ab:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8015ae:	a1 04 40 80 00       	mov    0x804004,%eax
  8015b3:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  8015b6:	83 ec 0c             	sub    $0xc,%esp
  8015b9:	57                   	push   %edi
  8015ba:	e8 cd 05 00 00       	call   801b8c <pageref>
  8015bf:	89 c6                	mov    %eax,%esi
  8015c1:	83 c4 04             	add    $0x4,%esp
  8015c4:	ff 75 e4             	pushl  -0x1c(%ebp)
  8015c7:	e8 c0 05 00 00       	call   801b8c <pageref>
  8015cc:	83 c4 10             	add    $0x10,%esp
  8015cf:	39 c6                	cmp    %eax,%esi
  8015d1:	0f 94 c0             	sete   %al
  8015d4:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  8015d7:	8b 15 04 40 80 00    	mov    0x804004,%edx
  8015dd:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  8015e0:	39 cb                	cmp    %ecx,%ebx
  8015e2:	75 08                	jne    8015ec <_pipeisclosed+0x4c>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  8015e4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8015e7:	5b                   	pop    %ebx
  8015e8:	5e                   	pop    %esi
  8015e9:	5f                   	pop    %edi
  8015ea:	c9                   	leave  
  8015eb:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  8015ec:	83 f8 01             	cmp    $0x1,%eax
  8015ef:	75 bd                	jne    8015ae <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8015f1:	8b 42 58             	mov    0x58(%edx),%eax
  8015f4:	6a 01                	push   $0x1
  8015f6:	50                   	push   %eax
  8015f7:	53                   	push   %ebx
  8015f8:	68 92 22 80 00       	push   $0x802292
  8015fd:	e8 92 eb ff ff       	call   800194 <cprintf>
  801602:	83 c4 10             	add    $0x10,%esp
  801605:	eb a7                	jmp    8015ae <_pipeisclosed+0xe>

00801607 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801607:	55                   	push   %ebp
  801608:	89 e5                	mov    %esp,%ebp
  80160a:	57                   	push   %edi
  80160b:	56                   	push   %esi
  80160c:	53                   	push   %ebx
  80160d:	83 ec 28             	sub    $0x28,%esp
  801610:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801613:	56                   	push   %esi
  801614:	e8 6f f7 ff ff       	call   800d88 <fd2data>
  801619:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80161b:	83 c4 10             	add    $0x10,%esp
  80161e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801622:	75 4a                	jne    80166e <devpipe_write+0x67>
  801624:	bf 00 00 00 00       	mov    $0x0,%edi
  801629:	eb 56                	jmp    801681 <devpipe_write+0x7a>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  80162b:	89 da                	mov    %ebx,%edx
  80162d:	89 f0                	mov    %esi,%eax
  80162f:	e8 6c ff ff ff       	call   8015a0 <_pipeisclosed>
  801634:	85 c0                	test   %eax,%eax
  801636:	75 4d                	jne    801685 <devpipe_write+0x7e>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801638:	e8 68 f5 ff ff       	call   800ba5 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  80163d:	8b 43 04             	mov    0x4(%ebx),%eax
  801640:	8b 13                	mov    (%ebx),%edx
  801642:	83 c2 20             	add    $0x20,%edx
  801645:	39 d0                	cmp    %edx,%eax
  801647:	73 e2                	jae    80162b <devpipe_write+0x24>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801649:	89 c2                	mov    %eax,%edx
  80164b:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  801651:	79 05                	jns    801658 <devpipe_write+0x51>
  801653:	4a                   	dec    %edx
  801654:	83 ca e0             	or     $0xffffffe0,%edx
  801657:	42                   	inc    %edx
  801658:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80165b:	8a 0c 39             	mov    (%ecx,%edi,1),%cl
  80165e:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801662:	40                   	inc    %eax
  801663:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801666:	47                   	inc    %edi
  801667:	39 7d 10             	cmp    %edi,0x10(%ebp)
  80166a:	77 07                	ja     801673 <devpipe_write+0x6c>
  80166c:	eb 13                	jmp    801681 <devpipe_write+0x7a>
  80166e:	bf 00 00 00 00       	mov    $0x0,%edi
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801673:	8b 43 04             	mov    0x4(%ebx),%eax
  801676:	8b 13                	mov    (%ebx),%edx
  801678:	83 c2 20             	add    $0x20,%edx
  80167b:	39 d0                	cmp    %edx,%eax
  80167d:	73 ac                	jae    80162b <devpipe_write+0x24>
  80167f:	eb c8                	jmp    801649 <devpipe_write+0x42>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801681:	89 f8                	mov    %edi,%eax
  801683:	eb 05                	jmp    80168a <devpipe_write+0x83>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801685:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  80168a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80168d:	5b                   	pop    %ebx
  80168e:	5e                   	pop    %esi
  80168f:	5f                   	pop    %edi
  801690:	c9                   	leave  
  801691:	c3                   	ret    

00801692 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801692:	55                   	push   %ebp
  801693:	89 e5                	mov    %esp,%ebp
  801695:	57                   	push   %edi
  801696:	56                   	push   %esi
  801697:	53                   	push   %ebx
  801698:	83 ec 18             	sub    $0x18,%esp
  80169b:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  80169e:	57                   	push   %edi
  80169f:	e8 e4 f6 ff ff       	call   800d88 <fd2data>
  8016a4:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8016a6:	83 c4 10             	add    $0x10,%esp
  8016a9:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8016ad:	75 44                	jne    8016f3 <devpipe_read+0x61>
  8016af:	be 00 00 00 00       	mov    $0x0,%esi
  8016b4:	eb 4f                	jmp    801705 <devpipe_read+0x73>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
				return i;
  8016b6:	89 f0                	mov    %esi,%eax
  8016b8:	eb 54                	jmp    80170e <devpipe_read+0x7c>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  8016ba:	89 da                	mov    %ebx,%edx
  8016bc:	89 f8                	mov    %edi,%eax
  8016be:	e8 dd fe ff ff       	call   8015a0 <_pipeisclosed>
  8016c3:	85 c0                	test   %eax,%eax
  8016c5:	75 42                	jne    801709 <devpipe_read+0x77>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  8016c7:	e8 d9 f4 ff ff       	call   800ba5 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8016cc:	8b 03                	mov    (%ebx),%eax
  8016ce:	3b 43 04             	cmp    0x4(%ebx),%eax
  8016d1:	74 e7                	je     8016ba <devpipe_read+0x28>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8016d3:	25 1f 00 00 80       	and    $0x8000001f,%eax
  8016d8:	79 05                	jns    8016df <devpipe_read+0x4d>
  8016da:	48                   	dec    %eax
  8016db:	83 c8 e0             	or     $0xffffffe0,%eax
  8016de:	40                   	inc    %eax
  8016df:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  8016e3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8016e6:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  8016e9:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8016eb:	46                   	inc    %esi
  8016ec:	39 75 10             	cmp    %esi,0x10(%ebp)
  8016ef:	77 07                	ja     8016f8 <devpipe_read+0x66>
  8016f1:	eb 12                	jmp    801705 <devpipe_read+0x73>
  8016f3:	be 00 00 00 00       	mov    $0x0,%esi
		while (p->p_rpos == p->p_wpos) {
  8016f8:	8b 03                	mov    (%ebx),%eax
  8016fa:	3b 43 04             	cmp    0x4(%ebx),%eax
  8016fd:	75 d4                	jne    8016d3 <devpipe_read+0x41>
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  8016ff:	85 f6                	test   %esi,%esi
  801701:	75 b3                	jne    8016b6 <devpipe_read+0x24>
  801703:	eb b5                	jmp    8016ba <devpipe_read+0x28>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801705:	89 f0                	mov    %esi,%eax
  801707:	eb 05                	jmp    80170e <devpipe_read+0x7c>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801709:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  80170e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801711:	5b                   	pop    %ebx
  801712:	5e                   	pop    %esi
  801713:	5f                   	pop    %edi
  801714:	c9                   	leave  
  801715:	c3                   	ret    

00801716 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801716:	55                   	push   %ebp
  801717:	89 e5                	mov    %esp,%ebp
  801719:	57                   	push   %edi
  80171a:	56                   	push   %esi
  80171b:	53                   	push   %ebx
  80171c:	83 ec 28             	sub    $0x28,%esp
  80171f:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801722:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801725:	50                   	push   %eax
  801726:	e8 75 f6 ff ff       	call   800da0 <fd_alloc>
  80172b:	89 c3                	mov    %eax,%ebx
  80172d:	83 c4 10             	add    $0x10,%esp
  801730:	85 c0                	test   %eax,%eax
  801732:	0f 88 24 01 00 00    	js     80185c <pipe+0x146>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801738:	83 ec 04             	sub    $0x4,%esp
  80173b:	68 07 04 00 00       	push   $0x407
  801740:	ff 75 e4             	pushl  -0x1c(%ebp)
  801743:	6a 00                	push   $0x0
  801745:	e8 82 f4 ff ff       	call   800bcc <sys_page_alloc>
  80174a:	89 c3                	mov    %eax,%ebx
  80174c:	83 c4 10             	add    $0x10,%esp
  80174f:	85 c0                	test   %eax,%eax
  801751:	0f 88 05 01 00 00    	js     80185c <pipe+0x146>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801757:	83 ec 0c             	sub    $0xc,%esp
  80175a:	8d 45 e0             	lea    -0x20(%ebp),%eax
  80175d:	50                   	push   %eax
  80175e:	e8 3d f6 ff ff       	call   800da0 <fd_alloc>
  801763:	89 c3                	mov    %eax,%ebx
  801765:	83 c4 10             	add    $0x10,%esp
  801768:	85 c0                	test   %eax,%eax
  80176a:	0f 88 dc 00 00 00    	js     80184c <pipe+0x136>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801770:	83 ec 04             	sub    $0x4,%esp
  801773:	68 07 04 00 00       	push   $0x407
  801778:	ff 75 e0             	pushl  -0x20(%ebp)
  80177b:	6a 00                	push   $0x0
  80177d:	e8 4a f4 ff ff       	call   800bcc <sys_page_alloc>
  801782:	89 c3                	mov    %eax,%ebx
  801784:	83 c4 10             	add    $0x10,%esp
  801787:	85 c0                	test   %eax,%eax
  801789:	0f 88 bd 00 00 00    	js     80184c <pipe+0x136>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  80178f:	83 ec 0c             	sub    $0xc,%esp
  801792:	ff 75 e4             	pushl  -0x1c(%ebp)
  801795:	e8 ee f5 ff ff       	call   800d88 <fd2data>
  80179a:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80179c:	83 c4 0c             	add    $0xc,%esp
  80179f:	68 07 04 00 00       	push   $0x407
  8017a4:	50                   	push   %eax
  8017a5:	6a 00                	push   $0x0
  8017a7:	e8 20 f4 ff ff       	call   800bcc <sys_page_alloc>
  8017ac:	89 c3                	mov    %eax,%ebx
  8017ae:	83 c4 10             	add    $0x10,%esp
  8017b1:	85 c0                	test   %eax,%eax
  8017b3:	0f 88 83 00 00 00    	js     80183c <pipe+0x126>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8017b9:	83 ec 0c             	sub    $0xc,%esp
  8017bc:	ff 75 e0             	pushl  -0x20(%ebp)
  8017bf:	e8 c4 f5 ff ff       	call   800d88 <fd2data>
  8017c4:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  8017cb:	50                   	push   %eax
  8017cc:	6a 00                	push   $0x0
  8017ce:	56                   	push   %esi
  8017cf:	6a 00                	push   $0x0
  8017d1:	e8 1a f4 ff ff       	call   800bf0 <sys_page_map>
  8017d6:	89 c3                	mov    %eax,%ebx
  8017d8:	83 c4 20             	add    $0x20,%esp
  8017db:	85 c0                	test   %eax,%eax
  8017dd:	78 4f                	js     80182e <pipe+0x118>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  8017df:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8017e5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8017e8:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8017ea:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8017ed:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8017f4:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8017fa:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8017fd:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8017ff:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801802:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801809:	83 ec 0c             	sub    $0xc,%esp
  80180c:	ff 75 e4             	pushl  -0x1c(%ebp)
  80180f:	e8 64 f5 ff ff       	call   800d78 <fd2num>
  801814:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  801816:	83 c4 04             	add    $0x4,%esp
  801819:	ff 75 e0             	pushl  -0x20(%ebp)
  80181c:	e8 57 f5 ff ff       	call   800d78 <fd2num>
  801821:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  801824:	83 c4 10             	add    $0x10,%esp
  801827:	bb 00 00 00 00       	mov    $0x0,%ebx
  80182c:	eb 2e                	jmp    80185c <pipe+0x146>

    err3:
	sys_page_unmap(0, va);
  80182e:	83 ec 08             	sub    $0x8,%esp
  801831:	56                   	push   %esi
  801832:	6a 00                	push   $0x0
  801834:	e8 dd f3 ff ff       	call   800c16 <sys_page_unmap>
  801839:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  80183c:	83 ec 08             	sub    $0x8,%esp
  80183f:	ff 75 e0             	pushl  -0x20(%ebp)
  801842:	6a 00                	push   $0x0
  801844:	e8 cd f3 ff ff       	call   800c16 <sys_page_unmap>
  801849:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  80184c:	83 ec 08             	sub    $0x8,%esp
  80184f:	ff 75 e4             	pushl  -0x1c(%ebp)
  801852:	6a 00                	push   $0x0
  801854:	e8 bd f3 ff ff       	call   800c16 <sys_page_unmap>
  801859:	83 c4 10             	add    $0x10,%esp
    err:
	return r;
}
  80185c:	89 d8                	mov    %ebx,%eax
  80185e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801861:	5b                   	pop    %ebx
  801862:	5e                   	pop    %esi
  801863:	5f                   	pop    %edi
  801864:	c9                   	leave  
  801865:	c3                   	ret    

00801866 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801866:	55                   	push   %ebp
  801867:	89 e5                	mov    %esp,%ebp
  801869:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80186c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80186f:	50                   	push   %eax
  801870:	ff 75 08             	pushl  0x8(%ebp)
  801873:	e8 9b f5 ff ff       	call   800e13 <fd_lookup>
  801878:	83 c4 10             	add    $0x10,%esp
  80187b:	85 c0                	test   %eax,%eax
  80187d:	78 18                	js     801897 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  80187f:	83 ec 0c             	sub    $0xc,%esp
  801882:	ff 75 f4             	pushl  -0xc(%ebp)
  801885:	e8 fe f4 ff ff       	call   800d88 <fd2data>
	return _pipeisclosed(fd, p);
  80188a:	89 c2                	mov    %eax,%edx
  80188c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80188f:	e8 0c fd ff ff       	call   8015a0 <_pipeisclosed>
  801894:	83 c4 10             	add    $0x10,%esp
}
  801897:	c9                   	leave  
  801898:	c3                   	ret    
  801899:	00 00                	add    %al,(%eax)
	...

0080189c <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  80189c:	55                   	push   %ebp
  80189d:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  80189f:	b8 00 00 00 00       	mov    $0x0,%eax
  8018a4:	c9                   	leave  
  8018a5:	c3                   	ret    

008018a6 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8018a6:	55                   	push   %ebp
  8018a7:	89 e5                	mov    %esp,%ebp
  8018a9:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  8018ac:	68 aa 22 80 00       	push   $0x8022aa
  8018b1:	ff 75 0c             	pushl  0xc(%ebp)
  8018b4:	e8 91 ee ff ff       	call   80074a <strcpy>
	return 0;
}
  8018b9:	b8 00 00 00 00       	mov    $0x0,%eax
  8018be:	c9                   	leave  
  8018bf:	c3                   	ret    

008018c0 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8018c0:	55                   	push   %ebp
  8018c1:	89 e5                	mov    %esp,%ebp
  8018c3:	57                   	push   %edi
  8018c4:	56                   	push   %esi
  8018c5:	53                   	push   %ebx
  8018c6:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8018cc:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8018d0:	74 45                	je     801917 <devcons_write+0x57>
  8018d2:	b8 00 00 00 00       	mov    $0x0,%eax
  8018d7:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8018dc:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  8018e2:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8018e5:	29 c3                	sub    %eax,%ebx
		if (m > sizeof(buf) - 1)
  8018e7:	83 fb 7f             	cmp    $0x7f,%ebx
  8018ea:	76 05                	jbe    8018f1 <devcons_write+0x31>
			m = sizeof(buf) - 1;
  8018ec:	bb 7f 00 00 00       	mov    $0x7f,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  8018f1:	83 ec 04             	sub    $0x4,%esp
  8018f4:	53                   	push   %ebx
  8018f5:	03 45 0c             	add    0xc(%ebp),%eax
  8018f8:	50                   	push   %eax
  8018f9:	57                   	push   %edi
  8018fa:	e8 0c f0 ff ff       	call   80090b <memmove>
		sys_cputs(buf, m);
  8018ff:	83 c4 08             	add    $0x8,%esp
  801902:	53                   	push   %ebx
  801903:	57                   	push   %edi
  801904:	e8 0c f2 ff ff       	call   800b15 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801909:	01 de                	add    %ebx,%esi
  80190b:	89 f0                	mov    %esi,%eax
  80190d:	83 c4 10             	add    $0x10,%esp
  801910:	3b 75 10             	cmp    0x10(%ebp),%esi
  801913:	72 cd                	jb     8018e2 <devcons_write+0x22>
  801915:	eb 05                	jmp    80191c <devcons_write+0x5c>
  801917:	be 00 00 00 00       	mov    $0x0,%esi
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  80191c:	89 f0                	mov    %esi,%eax
  80191e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801921:	5b                   	pop    %ebx
  801922:	5e                   	pop    %esi
  801923:	5f                   	pop    %edi
  801924:	c9                   	leave  
  801925:	c3                   	ret    

00801926 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801926:	55                   	push   %ebp
  801927:	89 e5                	mov    %esp,%ebp
  801929:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  80192c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801930:	75 07                	jne    801939 <devcons_read+0x13>
  801932:	eb 25                	jmp    801959 <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801934:	e8 6c f2 ff ff       	call   800ba5 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801939:	e8 fd f1 ff ff       	call   800b3b <sys_cgetc>
  80193e:	85 c0                	test   %eax,%eax
  801940:	74 f2                	je     801934 <devcons_read+0xe>
  801942:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  801944:	85 c0                	test   %eax,%eax
  801946:	78 1d                	js     801965 <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801948:	83 f8 04             	cmp    $0x4,%eax
  80194b:	74 13                	je     801960 <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  80194d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801950:	88 10                	mov    %dl,(%eax)
	return 1;
  801952:	b8 01 00 00 00       	mov    $0x1,%eax
  801957:	eb 0c                	jmp    801965 <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  801959:	b8 00 00 00 00       	mov    $0x0,%eax
  80195e:	eb 05                	jmp    801965 <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801960:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801965:	c9                   	leave  
  801966:	c3                   	ret    

00801967 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801967:	55                   	push   %ebp
  801968:	89 e5                	mov    %esp,%ebp
  80196a:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  80196d:	8b 45 08             	mov    0x8(%ebp),%eax
  801970:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801973:	6a 01                	push   $0x1
  801975:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801978:	50                   	push   %eax
  801979:	e8 97 f1 ff ff       	call   800b15 <sys_cputs>
  80197e:	83 c4 10             	add    $0x10,%esp
}
  801981:	c9                   	leave  
  801982:	c3                   	ret    

00801983 <getchar>:

int
getchar(void)
{
  801983:	55                   	push   %ebp
  801984:	89 e5                	mov    %esp,%ebp
  801986:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801989:	6a 01                	push   $0x1
  80198b:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80198e:	50                   	push   %eax
  80198f:	6a 00                	push   $0x0
  801991:	e8 fe f6 ff ff       	call   801094 <read>
	if (r < 0)
  801996:	83 c4 10             	add    $0x10,%esp
  801999:	85 c0                	test   %eax,%eax
  80199b:	78 0f                	js     8019ac <getchar+0x29>
		return r;
	if (r < 1)
  80199d:	85 c0                	test   %eax,%eax
  80199f:	7e 06                	jle    8019a7 <getchar+0x24>
		return -E_EOF;
	return c;
  8019a1:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8019a5:	eb 05                	jmp    8019ac <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  8019a7:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  8019ac:	c9                   	leave  
  8019ad:	c3                   	ret    

008019ae <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  8019ae:	55                   	push   %ebp
  8019af:	89 e5                	mov    %esp,%ebp
  8019b1:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8019b4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019b7:	50                   	push   %eax
  8019b8:	ff 75 08             	pushl  0x8(%ebp)
  8019bb:	e8 53 f4 ff ff       	call   800e13 <fd_lookup>
  8019c0:	83 c4 10             	add    $0x10,%esp
  8019c3:	85 c0                	test   %eax,%eax
  8019c5:	78 11                	js     8019d8 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  8019c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019ca:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8019d0:	39 10                	cmp    %edx,(%eax)
  8019d2:	0f 94 c0             	sete   %al
  8019d5:	0f b6 c0             	movzbl %al,%eax
}
  8019d8:	c9                   	leave  
  8019d9:	c3                   	ret    

008019da <opencons>:

int
opencons(void)
{
  8019da:	55                   	push   %ebp
  8019db:	89 e5                	mov    %esp,%ebp
  8019dd:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8019e0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019e3:	50                   	push   %eax
  8019e4:	e8 b7 f3 ff ff       	call   800da0 <fd_alloc>
  8019e9:	83 c4 10             	add    $0x10,%esp
  8019ec:	85 c0                	test   %eax,%eax
  8019ee:	78 3a                	js     801a2a <opencons+0x50>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8019f0:	83 ec 04             	sub    $0x4,%esp
  8019f3:	68 07 04 00 00       	push   $0x407
  8019f8:	ff 75 f4             	pushl  -0xc(%ebp)
  8019fb:	6a 00                	push   $0x0
  8019fd:	e8 ca f1 ff ff       	call   800bcc <sys_page_alloc>
  801a02:	83 c4 10             	add    $0x10,%esp
  801a05:	85 c0                	test   %eax,%eax
  801a07:	78 21                	js     801a2a <opencons+0x50>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801a09:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801a0f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a12:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801a14:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a17:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801a1e:	83 ec 0c             	sub    $0xc,%esp
  801a21:	50                   	push   %eax
  801a22:	e8 51 f3 ff ff       	call   800d78 <fd2num>
  801a27:	83 c4 10             	add    $0x10,%esp
}
  801a2a:	c9                   	leave  
  801a2b:	c3                   	ret    

00801a2c <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801a2c:	55                   	push   %ebp
  801a2d:	89 e5                	mov    %esp,%ebp
  801a2f:	56                   	push   %esi
  801a30:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801a31:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801a34:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  801a3a:	e8 42 f1 ff ff       	call   800b81 <sys_getenvid>
  801a3f:	83 ec 0c             	sub    $0xc,%esp
  801a42:	ff 75 0c             	pushl  0xc(%ebp)
  801a45:	ff 75 08             	pushl  0x8(%ebp)
  801a48:	53                   	push   %ebx
  801a49:	50                   	push   %eax
  801a4a:	68 b8 22 80 00       	push   $0x8022b8
  801a4f:	e8 40 e7 ff ff       	call   800194 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801a54:	83 c4 18             	add    $0x18,%esp
  801a57:	56                   	push   %esi
  801a58:	ff 75 10             	pushl  0x10(%ebp)
  801a5b:	e8 e3 e6 ff ff       	call   800143 <vcprintf>
	cprintf("\n");
  801a60:	c7 04 24 a3 22 80 00 	movl   $0x8022a3,(%esp)
  801a67:	e8 28 e7 ff ff       	call   800194 <cprintf>
  801a6c:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801a6f:	cc                   	int3   
  801a70:	eb fd                	jmp    801a6f <_panic+0x43>
	...

00801a74 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801a74:	55                   	push   %ebp
  801a75:	89 e5                	mov    %esp,%ebp
  801a77:	56                   	push   %esi
  801a78:	53                   	push   %ebx
  801a79:	8b 75 08             	mov    0x8(%ebp),%esi
  801a7c:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a7f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// cprintf("0x%x 0x%x 0x%x\n", (uint32_t)from_env_store, (uint32_t)pg, (uint32_t)perm_store);
	int r;
	if (pg != NULL) {
  801a82:	85 c0                	test   %eax,%eax
  801a84:	74 0e                	je     801a94 <ipc_recv+0x20>
		r = sys_ipc_recv(pg);
  801a86:	83 ec 0c             	sub    $0xc,%esp
  801a89:	50                   	push   %eax
  801a8a:	e8 38 f2 ff ff       	call   800cc7 <sys_ipc_recv>
  801a8f:	83 c4 10             	add    $0x10,%esp
  801a92:	eb 10                	jmp    801aa4 <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv((void *)UTOP);
  801a94:	83 ec 0c             	sub    $0xc,%esp
  801a97:	68 00 00 c0 ee       	push   $0xeec00000
  801a9c:	e8 26 f2 ff ff       	call   800cc7 <sys_ipc_recv>
  801aa1:	83 c4 10             	add    $0x10,%esp
	}

	if (r == 0) {
  801aa4:	85 c0                	test   %eax,%eax
  801aa6:	75 26                	jne    801ace <ipc_recv+0x5a>
		if (from_env_store != NULL) *from_env_store = thisenv->env_ipc_from;
  801aa8:	85 f6                	test   %esi,%esi
  801aaa:	74 0a                	je     801ab6 <ipc_recv+0x42>
  801aac:	a1 04 40 80 00       	mov    0x804004,%eax
  801ab1:	8b 40 74             	mov    0x74(%eax),%eax
  801ab4:	89 06                	mov    %eax,(%esi)
		if (perm_store != NULL) *perm_store = thisenv->env_ipc_perm;
  801ab6:	85 db                	test   %ebx,%ebx
  801ab8:	74 0a                	je     801ac4 <ipc_recv+0x50>
  801aba:	a1 04 40 80 00       	mov    0x804004,%eax
  801abf:	8b 40 78             	mov    0x78(%eax),%eax
  801ac2:	89 03                	mov    %eax,(%ebx)
		return thisenv->env_ipc_value;
  801ac4:	a1 04 40 80 00       	mov    0x804004,%eax
  801ac9:	8b 40 70             	mov    0x70(%eax),%eax
  801acc:	eb 14                	jmp    801ae2 <ipc_recv+0x6e>
	} else {
		// fails;
		if (from_env_store != NULL) *from_env_store = 0;
  801ace:	85 f6                	test   %esi,%esi
  801ad0:	74 06                	je     801ad8 <ipc_recv+0x64>
  801ad2:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if (perm_store != NULL) *perm_store = 0;
  801ad8:	85 db                	test   %ebx,%ebx
  801ada:	74 06                	je     801ae2 <ipc_recv+0x6e>
  801adc:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		return r;
	}
}
  801ae2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ae5:	5b                   	pop    %ebx
  801ae6:	5e                   	pop    %esi
  801ae7:	c9                   	leave  
  801ae8:	c3                   	ret    

00801ae9 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801ae9:	55                   	push   %ebp
  801aea:	89 e5                	mov    %esp,%ebp
  801aec:	57                   	push   %edi
  801aed:	56                   	push   %esi
  801aee:	53                   	push   %ebx
  801aef:	83 ec 0c             	sub    $0xc,%esp
  801af2:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801af5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801af8:	8b 75 14             	mov    0x14(%ebp),%esi
	// LAB 4: Your code here.
	// int sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
	int r;
	if (pg == NULL) pg = (void *)UTOP;
  801afb:	85 db                	test   %ebx,%ebx
  801afd:	75 25                	jne    801b24 <ipc_send+0x3b>
  801aff:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
  801b04:	eb 1e                	jmp    801b24 <ipc_send+0x3b>
	
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) != 0) {
		if (r == -E_IPC_NOT_RECV) {
  801b06:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801b09:	75 07                	jne    801b12 <ipc_send+0x29>
			// cprintf("Try Again and Again....\n");
			sys_yield();
  801b0b:	e8 95 f0 ff ff       	call   800ba5 <sys_yield>
  801b10:	eb 12                	jmp    801b24 <ipc_send+0x3b>
		} else {
			panic("ipc_send error %e\n", r);
  801b12:	50                   	push   %eax
  801b13:	68 dc 22 80 00       	push   $0x8022dc
  801b18:	6a 43                	push   $0x43
  801b1a:	68 ef 22 80 00       	push   $0x8022ef
  801b1f:	e8 08 ff ff ff       	call   801a2c <_panic>
	// LAB 4: Your code here.
	// int sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
	int r;
	if (pg == NULL) pg = (void *)UTOP;
	
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) != 0) {
  801b24:	56                   	push   %esi
  801b25:	53                   	push   %ebx
  801b26:	57                   	push   %edi
  801b27:	ff 75 08             	pushl  0x8(%ebp)
  801b2a:	e8 73 f1 ff ff       	call   800ca2 <sys_ipc_try_send>
  801b2f:	83 c4 10             	add    $0x10,%esp
  801b32:	85 c0                	test   %eax,%eax
  801b34:	75 d0                	jne    801b06 <ipc_send+0x1d>
		} else {
			panic("ipc_send error %e\n", r);
		}
	}
	return;
}
  801b36:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b39:	5b                   	pop    %ebx
  801b3a:	5e                   	pop    %esi
  801b3b:	5f                   	pop    %edi
  801b3c:	c9                   	leave  
  801b3d:	c3                   	ret    

00801b3e <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801b3e:	55                   	push   %ebp
  801b3f:	89 e5                	mov    %esp,%ebp
  801b41:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  801b44:	39 0d 50 00 c0 ee    	cmp    %ecx,0xeec00050
  801b4a:	74 1a                	je     801b66 <ipc_find_env+0x28>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801b4c:	b8 01 00 00 00       	mov    $0x1,%eax
		if (envs[i].env_type == type)
  801b51:	89 c2                	mov    %eax,%edx
  801b53:	c1 e2 07             	shl    $0x7,%edx
  801b56:	8d 94 82 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,4),%edx
  801b5d:	8b 52 50             	mov    0x50(%edx),%edx
  801b60:	39 ca                	cmp    %ecx,%edx
  801b62:	75 18                	jne    801b7c <ipc_find_env+0x3e>
  801b64:	eb 05                	jmp    801b6b <ipc_find_env+0x2d>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801b66:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
			return envs[i].env_id;
  801b6b:	89 c2                	mov    %eax,%edx
  801b6d:	c1 e2 07             	shl    $0x7,%edx
  801b70:	8d 84 82 08 00 c0 ee 	lea    -0x113ffff8(%edx,%eax,4),%eax
  801b77:	8b 40 40             	mov    0x40(%eax),%eax
  801b7a:	eb 0c                	jmp    801b88 <ipc_find_env+0x4a>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801b7c:	40                   	inc    %eax
  801b7d:	3d 00 04 00 00       	cmp    $0x400,%eax
  801b82:	75 cd                	jne    801b51 <ipc_find_env+0x13>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801b84:	66 b8 00 00          	mov    $0x0,%ax
}
  801b88:	c9                   	leave  
  801b89:	c3                   	ret    
	...

00801b8c <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801b8c:	55                   	push   %ebp
  801b8d:	89 e5                	mov    %esp,%ebp
  801b8f:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b92:	89 c2                	mov    %eax,%edx
  801b94:	c1 ea 16             	shr    $0x16,%edx
  801b97:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801b9e:	f6 c2 01             	test   $0x1,%dl
  801ba1:	74 1e                	je     801bc1 <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  801ba3:	c1 e8 0c             	shr    $0xc,%eax
  801ba6:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801bad:	a8 01                	test   $0x1,%al
  801baf:	74 17                	je     801bc8 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801bb1:	c1 e8 0c             	shr    $0xc,%eax
  801bb4:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  801bbb:	ef 
  801bbc:	0f b7 c0             	movzwl %ax,%eax
  801bbf:	eb 0c                	jmp    801bcd <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  801bc1:	b8 00 00 00 00       	mov    $0x0,%eax
  801bc6:	eb 05                	jmp    801bcd <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  801bc8:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  801bcd:	c9                   	leave  
  801bce:	c3                   	ret    
	...

00801bd0 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  801bd0:	55                   	push   %ebp
  801bd1:	89 e5                	mov    %esp,%ebp
  801bd3:	57                   	push   %edi
  801bd4:	56                   	push   %esi
  801bd5:	83 ec 10             	sub    $0x10,%esp
  801bd8:	8b 7d 08             	mov    0x8(%ebp),%edi
  801bdb:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  801bde:	89 7d f0             	mov    %edi,-0x10(%ebp)
  801be1:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  801be4:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  801be7:	8b 45 14             	mov    0x14(%ebp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  801bea:	85 c0                	test   %eax,%eax
  801bec:	75 2e                	jne    801c1c <__udivdi3+0x4c>
    {
      if (d0 > n1)
  801bee:	39 f1                	cmp    %esi,%ecx
  801bf0:	77 5a                	ja     801c4c <__udivdi3+0x7c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  801bf2:	85 c9                	test   %ecx,%ecx
  801bf4:	75 0b                	jne    801c01 <__udivdi3+0x31>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  801bf6:	b8 01 00 00 00       	mov    $0x1,%eax
  801bfb:	31 d2                	xor    %edx,%edx
  801bfd:	f7 f1                	div    %ecx
  801bff:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  801c01:	31 d2                	xor    %edx,%edx
  801c03:	89 f0                	mov    %esi,%eax
  801c05:	f7 f1                	div    %ecx
  801c07:	89 c6                	mov    %eax,%esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801c09:	89 f8                	mov    %edi,%eax
  801c0b:	f7 f1                	div    %ecx
  801c0d:	89 c7                	mov    %eax,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801c0f:	89 f8                	mov    %edi,%eax
  801c11:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801c13:	83 c4 10             	add    $0x10,%esp
  801c16:	5e                   	pop    %esi
  801c17:	5f                   	pop    %edi
  801c18:	c9                   	leave  
  801c19:	c3                   	ret    
  801c1a:	66 90                	xchg   %ax,%ax
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801c1c:	39 f0                	cmp    %esi,%eax
  801c1e:	77 1c                	ja     801c3c <__udivdi3+0x6c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  801c20:	0f bd f8             	bsr    %eax,%edi
	  if (bm == 0)
  801c23:	83 f7 1f             	xor    $0x1f,%edi
  801c26:	75 3c                	jne    801c64 <__udivdi3+0x94>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801c28:	39 f0                	cmp    %esi,%eax
  801c2a:	0f 82 90 00 00 00    	jb     801cc0 <__udivdi3+0xf0>
  801c30:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801c33:	39 55 f4             	cmp    %edx,-0xc(%ebp)
  801c36:	0f 86 84 00 00 00    	jbe    801cc0 <__udivdi3+0xf0>
  801c3c:	31 f6                	xor    %esi,%esi
  801c3e:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801c40:	89 f8                	mov    %edi,%eax
  801c42:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801c44:	83 c4 10             	add    $0x10,%esp
  801c47:	5e                   	pop    %esi
  801c48:	5f                   	pop    %edi
  801c49:	c9                   	leave  
  801c4a:	c3                   	ret    
  801c4b:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801c4c:	89 f2                	mov    %esi,%edx
  801c4e:	89 f8                	mov    %edi,%eax
  801c50:	f7 f1                	div    %ecx
  801c52:	89 c7                	mov    %eax,%edi
  801c54:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801c56:	89 f8                	mov    %edi,%eax
  801c58:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801c5a:	83 c4 10             	add    $0x10,%esp
  801c5d:	5e                   	pop    %esi
  801c5e:	5f                   	pop    %edi
  801c5f:	c9                   	leave  
  801c60:	c3                   	ret    
  801c61:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  801c64:	89 f9                	mov    %edi,%ecx
  801c66:	d3 e0                	shl    %cl,%eax
  801c68:	89 45 e8             	mov    %eax,-0x18(%ebp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  801c6b:	b8 20 00 00 00       	mov    $0x20,%eax
  801c70:	29 f8                	sub    %edi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  801c72:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801c75:	88 c1                	mov    %al,%cl
  801c77:	d3 ea                	shr    %cl,%edx
  801c79:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  801c7c:	09 ca                	or     %ecx,%edx
  801c7e:	89 55 ec             	mov    %edx,-0x14(%ebp)
	      d0 = d0 << bm;
  801c81:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801c84:	89 f9                	mov    %edi,%ecx
  801c86:	d3 e2                	shl    %cl,%edx
  801c88:	89 55 f4             	mov    %edx,-0xc(%ebp)
	      n2 = n1 >> b;
  801c8b:	89 f2                	mov    %esi,%edx
  801c8d:	88 c1                	mov    %al,%cl
  801c8f:	d3 ea                	shr    %cl,%edx
  801c91:	89 55 e8             	mov    %edx,-0x18(%ebp)
	      n1 = (n1 << bm) | (n0 >> b);
  801c94:	89 f2                	mov    %esi,%edx
  801c96:	89 f9                	mov    %edi,%ecx
  801c98:	d3 e2                	shl    %cl,%edx
  801c9a:	8b 75 f0             	mov    -0x10(%ebp),%esi
  801c9d:	88 c1                	mov    %al,%cl
  801c9f:	d3 ee                	shr    %cl,%esi
  801ca1:	09 d6                	or     %edx,%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  801ca3:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  801ca6:	89 f0                	mov    %esi,%eax
  801ca8:	89 ca                	mov    %ecx,%edx
  801caa:	f7 75 ec             	divl   -0x14(%ebp)
  801cad:	89 d1                	mov    %edx,%ecx
  801caf:	89 c6                	mov    %eax,%esi
	      umul_ppmm (m1, m0, q0, d0);
  801cb1:	f7 65 f4             	mull   -0xc(%ebp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801cb4:	39 d1                	cmp    %edx,%ecx
  801cb6:	72 28                	jb     801ce0 <__udivdi3+0x110>
  801cb8:	74 1a                	je     801cd4 <__udivdi3+0x104>
  801cba:	89 f7                	mov    %esi,%edi
  801cbc:	31 f6                	xor    %esi,%esi
  801cbe:	eb 80                	jmp    801c40 <__udivdi3+0x70>
	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  801cc0:	31 f6                	xor    %esi,%esi
  801cc2:	bf 01 00 00 00       	mov    $0x1,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801cc7:	89 f8                	mov    %edi,%eax
  801cc9:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801ccb:	83 c4 10             	add    $0x10,%esp
  801cce:	5e                   	pop    %esi
  801ccf:	5f                   	pop    %edi
  801cd0:	c9                   	leave  
  801cd1:	c3                   	ret    
  801cd2:	66 90                	xchg   %ax,%ax

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  801cd4:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801cd7:	89 f9                	mov    %edi,%ecx
  801cd9:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801cdb:	39 c2                	cmp    %eax,%edx
  801cdd:	73 db                	jae    801cba <__udivdi3+0xea>
  801cdf:	90                   	nop
		{
		  q0--;
  801ce0:	8d 7e ff             	lea    -0x1(%esi),%edi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  801ce3:	31 f6                	xor    %esi,%esi
  801ce5:	e9 56 ff ff ff       	jmp    801c40 <__udivdi3+0x70>
	...

00801cec <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  801cec:	55                   	push   %ebp
  801ced:	89 e5                	mov    %esp,%ebp
  801cef:	57                   	push   %edi
  801cf0:	56                   	push   %esi
  801cf1:	83 ec 20             	sub    $0x20,%esp
  801cf4:	8b 45 08             	mov    0x8(%ebp),%eax
  801cf7:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  801cfa:	89 45 e8             	mov    %eax,-0x18(%ebp)
  801cfd:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  801d00:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  801d03:	8b 7d 14             	mov    0x14(%ebp),%edi
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  801d06:	89 45 f0             	mov    %eax,-0x10(%ebp)
  n1 = nn.s.high;
  801d09:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  801d0b:	85 ff                	test   %edi,%edi
  801d0d:	75 15                	jne    801d24 <__umoddi3+0x38>
    {
      if (d0 > n1)
  801d0f:	39 f1                	cmp    %esi,%ecx
  801d11:	0f 86 99 00 00 00    	jbe    801db0 <__umoddi3+0xc4>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801d17:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  801d19:	89 d0                	mov    %edx,%eax
  801d1b:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801d1d:	83 c4 20             	add    $0x20,%esp
  801d20:	5e                   	pop    %esi
  801d21:	5f                   	pop    %edi
  801d22:	c9                   	leave  
  801d23:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801d24:	39 f7                	cmp    %esi,%edi
  801d26:	0f 87 a4 00 00 00    	ja     801dd0 <__umoddi3+0xe4>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  801d2c:	0f bd c7             	bsr    %edi,%eax
	  if (bm == 0)
  801d2f:	83 f0 1f             	xor    $0x1f,%eax
  801d32:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801d35:	0f 84 a1 00 00 00    	je     801ddc <__umoddi3+0xf0>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  801d3b:	89 f8                	mov    %edi,%eax
  801d3d:	8a 4d ec             	mov    -0x14(%ebp),%cl
  801d40:	d3 e0                	shl    %cl,%eax
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  801d42:	bf 20 00 00 00       	mov    $0x20,%edi
  801d47:	2b 7d ec             	sub    -0x14(%ebp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  801d4a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801d4d:	89 f9                	mov    %edi,%ecx
  801d4f:	d3 ea                	shr    %cl,%edx
  801d51:	09 c2                	or     %eax,%edx
  801d53:	89 55 f0             	mov    %edx,-0x10(%ebp)
	      d0 = d0 << bm;
  801d56:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d59:	8a 4d ec             	mov    -0x14(%ebp),%cl
  801d5c:	d3 e0                	shl    %cl,%eax
  801d5e:	89 45 f4             	mov    %eax,-0xc(%ebp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  801d61:	89 f2                	mov    %esi,%edx
  801d63:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  801d65:	8b 45 e8             	mov    -0x18(%ebp),%eax
  801d68:	d3 e0                	shl    %cl,%eax
  801d6a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  801d6d:	8b 45 e8             	mov    -0x18(%ebp),%eax
  801d70:	89 f9                	mov    %edi,%ecx
  801d72:	d3 e8                	shr    %cl,%eax
  801d74:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  801d76:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  801d78:	89 f2                	mov    %esi,%edx
  801d7a:	f7 75 f0             	divl   -0x10(%ebp)
  801d7d:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  801d7f:	f7 65 f4             	mull   -0xc(%ebp)
  801d82:	89 55 e8             	mov    %edx,-0x18(%ebp)
  801d85:	89 c1                	mov    %eax,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801d87:	39 d6                	cmp    %edx,%esi
  801d89:	72 71                	jb     801dfc <__umoddi3+0x110>
  801d8b:	74 7f                	je     801e0c <__umoddi3+0x120>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  801d8d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801d90:	29 c8                	sub    %ecx,%eax
  801d92:	19 d6                	sbb    %edx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  801d94:	8a 4d ec             	mov    -0x14(%ebp),%cl
  801d97:	d3 e8                	shr    %cl,%eax
  801d99:	89 f2                	mov    %esi,%edx
  801d9b:	89 f9                	mov    %edi,%ecx
  801d9d:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  801d9f:	09 d0                	or     %edx,%eax
  801da1:	89 f2                	mov    %esi,%edx
  801da3:	8a 4d ec             	mov    -0x14(%ebp),%cl
  801da6:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801da8:	83 c4 20             	add    $0x20,%esp
  801dab:	5e                   	pop    %esi
  801dac:	5f                   	pop    %edi
  801dad:	c9                   	leave  
  801dae:	c3                   	ret    
  801daf:	90                   	nop
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  801db0:	85 c9                	test   %ecx,%ecx
  801db2:	75 0b                	jne    801dbf <__umoddi3+0xd3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  801db4:	b8 01 00 00 00       	mov    $0x1,%eax
  801db9:	31 d2                	xor    %edx,%edx
  801dbb:	f7 f1                	div    %ecx
  801dbd:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  801dbf:	89 f0                	mov    %esi,%eax
  801dc1:	31 d2                	xor    %edx,%edx
  801dc3:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801dc5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801dc8:	f7 f1                	div    %ecx
  801dca:	e9 4a ff ff ff       	jmp    801d19 <__umoddi3+0x2d>
  801dcf:	90                   	nop
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  801dd0:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801dd2:	83 c4 20             	add    $0x20,%esp
  801dd5:	5e                   	pop    %esi
  801dd6:	5f                   	pop    %edi
  801dd7:	c9                   	leave  
  801dd8:	c3                   	ret    
  801dd9:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801ddc:	39 f7                	cmp    %esi,%edi
  801dde:	72 05                	jb     801de5 <__umoddi3+0xf9>
  801de0:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
  801de3:	77 0c                	ja     801df1 <__umoddi3+0x105>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  801de5:	89 f2                	mov    %esi,%edx
  801de7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801dea:	29 c8                	sub    %ecx,%eax
  801dec:	19 fa                	sbb    %edi,%edx
  801dee:	89 45 f0             	mov    %eax,-0x10(%ebp)

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  801df1:	8b 45 f0             	mov    -0x10(%ebp),%eax
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
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  801dfc:	8b 55 e8             	mov    -0x18(%ebp),%edx
  801dff:	89 c1                	mov    %eax,%ecx
  801e01:	2b 4d f4             	sub    -0xc(%ebp),%ecx
  801e04:	1b 55 f0             	sbb    -0x10(%ebp),%edx
  801e07:	eb 84                	jmp    801d8d <__umoddi3+0xa1>
  801e09:	8d 76 00             	lea    0x0(%esi),%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801e0c:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801e0f:	72 eb                	jb     801dfc <__umoddi3+0x110>
  801e11:	89 f2                	mov    %esi,%edx
  801e13:	e9 75 ff ff ff       	jmp    801d8d <__umoddi3+0xa1>
