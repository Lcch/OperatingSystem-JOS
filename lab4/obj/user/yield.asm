
obj/user/yield:     file format elf32-i386


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
  80003b:	a1 04 20 80 00       	mov    0x802004,%eax
  800040:	8b 40 48             	mov    0x48(%eax),%eax
  800043:	50                   	push   %eax
  800044:	68 80 0f 80 00       	push   $0x800f80
  800049:	e8 3a 01 00 00       	call   800188 <cprintf>
  80004e:	83 c4 10             	add    $0x10,%esp
	for (i = 0; i < 5; i++) {
  800051:	bb 00 00 00 00       	mov    $0x0,%ebx
		sys_yield();
  800056:	e8 3e 0b 00 00       	call   800b99 <sys_yield>
		cprintf("Back in environment %08x, iteration %d.\n",
			thisenv->env_id, i);
  80005b:	a1 04 20 80 00       	mov    0x802004,%eax
	int i;

	cprintf("Hello, I am environment %08x.\n", thisenv->env_id);
	for (i = 0; i < 5; i++) {
		sys_yield();
		cprintf("Back in environment %08x, iteration %d.\n",
  800060:	8b 40 48             	mov    0x48(%eax),%eax
  800063:	83 ec 04             	sub    $0x4,%esp
  800066:	53                   	push   %ebx
  800067:	50                   	push   %eax
  800068:	68 a0 0f 80 00       	push   $0x800fa0
  80006d:	e8 16 01 00 00       	call   800188 <cprintf>
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
  80007b:	a1 04 20 80 00       	mov    0x802004,%eax
  800080:	8b 40 48             	mov    0x48(%eax),%eax
  800083:	83 ec 08             	sub    $0x8,%esp
  800086:	50                   	push   %eax
  800087:	68 cc 0f 80 00       	push   $0x800fcc
  80008c:	e8 f7 00 00 00       	call   800188 <cprintf>
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
  8000a7:	e8 c9 0a 00 00       	call   800b75 <sys_getenvid>
  8000ac:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000b1:	c1 e0 07             	shl    $0x7,%eax
  8000b4:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000b9:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000be:	85 f6                	test   %esi,%esi
  8000c0:	7e 07                	jle    8000c9 <libmain+0x2d>
		binaryname = argv[0];
  8000c2:	8b 03                	mov    (%ebx),%eax
  8000c4:	a3 00 20 80 00       	mov    %eax,0x802000
	// call user main routine
	umain(argc, argv);
  8000c9:	83 ec 08             	sub    $0x8,%esp
  8000cc:	53                   	push   %ebx
  8000cd:	56                   	push   %esi
  8000ce:	e8 61 ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  8000d3:	e8 0c 00 00 00       	call   8000e4 <exit>
  8000d8:	83 c4 10             	add    $0x10,%esp
}
  8000db:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000de:	5b                   	pop    %ebx
  8000df:	5e                   	pop    %esi
  8000e0:	c9                   	leave  
  8000e1:	c3                   	ret    
	...

008000e4 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000e4:	55                   	push   %ebp
  8000e5:	89 e5                	mov    %esp,%ebp
  8000e7:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  8000ea:	6a 00                	push   $0x0
  8000ec:	e8 62 0a 00 00       	call   800b53 <sys_env_destroy>
  8000f1:	83 c4 10             	add    $0x10,%esp
}
  8000f4:	c9                   	leave  
  8000f5:	c3                   	ret    
	...

008000f8 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000f8:	55                   	push   %ebp
  8000f9:	89 e5                	mov    %esp,%ebp
  8000fb:	53                   	push   %ebx
  8000fc:	83 ec 04             	sub    $0x4,%esp
  8000ff:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800102:	8b 03                	mov    (%ebx),%eax
  800104:	8b 55 08             	mov    0x8(%ebp),%edx
  800107:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  80010b:	40                   	inc    %eax
  80010c:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  80010e:	3d ff 00 00 00       	cmp    $0xff,%eax
  800113:	75 1a                	jne    80012f <putch+0x37>
		sys_cputs(b->buf, b->idx);
  800115:	83 ec 08             	sub    $0x8,%esp
  800118:	68 ff 00 00 00       	push   $0xff
  80011d:	8d 43 08             	lea    0x8(%ebx),%eax
  800120:	50                   	push   %eax
  800121:	e8 e3 09 00 00       	call   800b09 <sys_cputs>
		b->idx = 0;
  800126:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80012c:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80012f:	ff 43 04             	incl   0x4(%ebx)
}
  800132:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800135:	c9                   	leave  
  800136:	c3                   	ret    

00800137 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800137:	55                   	push   %ebp
  800138:	89 e5                	mov    %esp,%ebp
  80013a:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800140:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800147:	00 00 00 
	b.cnt = 0;
  80014a:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800151:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800154:	ff 75 0c             	pushl  0xc(%ebp)
  800157:	ff 75 08             	pushl  0x8(%ebp)
  80015a:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800160:	50                   	push   %eax
  800161:	68 f8 00 80 00       	push   $0x8000f8
  800166:	e8 82 01 00 00       	call   8002ed <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80016b:	83 c4 08             	add    $0x8,%esp
  80016e:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800174:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80017a:	50                   	push   %eax
  80017b:	e8 89 09 00 00       	call   800b09 <sys_cputs>

	return b.cnt;
}
  800180:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800186:	c9                   	leave  
  800187:	c3                   	ret    

00800188 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800188:	55                   	push   %ebp
  800189:	89 e5                	mov    %esp,%ebp
  80018b:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80018e:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800191:	50                   	push   %eax
  800192:	ff 75 08             	pushl  0x8(%ebp)
  800195:	e8 9d ff ff ff       	call   800137 <vcprintf>
	va_end(ap);

	return cnt;
}
  80019a:	c9                   	leave  
  80019b:	c3                   	ret    

0080019c <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80019c:	55                   	push   %ebp
  80019d:	89 e5                	mov    %esp,%ebp
  80019f:	57                   	push   %edi
  8001a0:	56                   	push   %esi
  8001a1:	53                   	push   %ebx
  8001a2:	83 ec 2c             	sub    $0x2c,%esp
  8001a5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8001a8:	89 d6                	mov    %edx,%esi
  8001aa:	8b 45 08             	mov    0x8(%ebp),%eax
  8001ad:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001b0:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001b3:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8001b6:	8b 45 10             	mov    0x10(%ebp),%eax
  8001b9:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8001bc:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001bf:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8001c2:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  8001c9:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
  8001cc:	72 0c                	jb     8001da <printnum+0x3e>
  8001ce:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  8001d1:	76 07                	jbe    8001da <printnum+0x3e>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8001d3:	4b                   	dec    %ebx
  8001d4:	85 db                	test   %ebx,%ebx
  8001d6:	7f 31                	jg     800209 <printnum+0x6d>
  8001d8:	eb 3f                	jmp    800219 <printnum+0x7d>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001da:	83 ec 0c             	sub    $0xc,%esp
  8001dd:	57                   	push   %edi
  8001de:	4b                   	dec    %ebx
  8001df:	53                   	push   %ebx
  8001e0:	50                   	push   %eax
  8001e1:	83 ec 08             	sub    $0x8,%esp
  8001e4:	ff 75 d4             	pushl  -0x2c(%ebp)
  8001e7:	ff 75 d0             	pushl  -0x30(%ebp)
  8001ea:	ff 75 dc             	pushl  -0x24(%ebp)
  8001ed:	ff 75 d8             	pushl  -0x28(%ebp)
  8001f0:	e8 33 0b 00 00       	call   800d28 <__udivdi3>
  8001f5:	83 c4 18             	add    $0x18,%esp
  8001f8:	52                   	push   %edx
  8001f9:	50                   	push   %eax
  8001fa:	89 f2                	mov    %esi,%edx
  8001fc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8001ff:	e8 98 ff ff ff       	call   80019c <printnum>
  800204:	83 c4 20             	add    $0x20,%esp
  800207:	eb 10                	jmp    800219 <printnum+0x7d>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800209:	83 ec 08             	sub    $0x8,%esp
  80020c:	56                   	push   %esi
  80020d:	57                   	push   %edi
  80020e:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800211:	4b                   	dec    %ebx
  800212:	83 c4 10             	add    $0x10,%esp
  800215:	85 db                	test   %ebx,%ebx
  800217:	7f f0                	jg     800209 <printnum+0x6d>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800219:	83 ec 08             	sub    $0x8,%esp
  80021c:	56                   	push   %esi
  80021d:	83 ec 04             	sub    $0x4,%esp
  800220:	ff 75 d4             	pushl  -0x2c(%ebp)
  800223:	ff 75 d0             	pushl  -0x30(%ebp)
  800226:	ff 75 dc             	pushl  -0x24(%ebp)
  800229:	ff 75 d8             	pushl  -0x28(%ebp)
  80022c:	e8 13 0c 00 00       	call   800e44 <__umoddi3>
  800231:	83 c4 14             	add    $0x14,%esp
  800234:	0f be 80 f5 0f 80 00 	movsbl 0x800ff5(%eax),%eax
  80023b:	50                   	push   %eax
  80023c:	ff 55 e4             	call   *-0x1c(%ebp)
  80023f:	83 c4 10             	add    $0x10,%esp
}
  800242:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800245:	5b                   	pop    %ebx
  800246:	5e                   	pop    %esi
  800247:	5f                   	pop    %edi
  800248:	c9                   	leave  
  800249:	c3                   	ret    

0080024a <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80024a:	55                   	push   %ebp
  80024b:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80024d:	83 fa 01             	cmp    $0x1,%edx
  800250:	7e 0e                	jle    800260 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800252:	8b 10                	mov    (%eax),%edx
  800254:	8d 4a 08             	lea    0x8(%edx),%ecx
  800257:	89 08                	mov    %ecx,(%eax)
  800259:	8b 02                	mov    (%edx),%eax
  80025b:	8b 52 04             	mov    0x4(%edx),%edx
  80025e:	eb 22                	jmp    800282 <getuint+0x38>
	else if (lflag)
  800260:	85 d2                	test   %edx,%edx
  800262:	74 10                	je     800274 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800264:	8b 10                	mov    (%eax),%edx
  800266:	8d 4a 04             	lea    0x4(%edx),%ecx
  800269:	89 08                	mov    %ecx,(%eax)
  80026b:	8b 02                	mov    (%edx),%eax
  80026d:	ba 00 00 00 00       	mov    $0x0,%edx
  800272:	eb 0e                	jmp    800282 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800274:	8b 10                	mov    (%eax),%edx
  800276:	8d 4a 04             	lea    0x4(%edx),%ecx
  800279:	89 08                	mov    %ecx,(%eax)
  80027b:	8b 02                	mov    (%edx),%eax
  80027d:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800282:	c9                   	leave  
  800283:	c3                   	ret    

00800284 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  800284:	55                   	push   %ebp
  800285:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800287:	83 fa 01             	cmp    $0x1,%edx
  80028a:	7e 0e                	jle    80029a <getint+0x16>
		return va_arg(*ap, long long);
  80028c:	8b 10                	mov    (%eax),%edx
  80028e:	8d 4a 08             	lea    0x8(%edx),%ecx
  800291:	89 08                	mov    %ecx,(%eax)
  800293:	8b 02                	mov    (%edx),%eax
  800295:	8b 52 04             	mov    0x4(%edx),%edx
  800298:	eb 1a                	jmp    8002b4 <getint+0x30>
	else if (lflag)
  80029a:	85 d2                	test   %edx,%edx
  80029c:	74 0c                	je     8002aa <getint+0x26>
		return va_arg(*ap, long);
  80029e:	8b 10                	mov    (%eax),%edx
  8002a0:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002a3:	89 08                	mov    %ecx,(%eax)
  8002a5:	8b 02                	mov    (%edx),%eax
  8002a7:	99                   	cltd   
  8002a8:	eb 0a                	jmp    8002b4 <getint+0x30>
	else
		return va_arg(*ap, int);
  8002aa:	8b 10                	mov    (%eax),%edx
  8002ac:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002af:	89 08                	mov    %ecx,(%eax)
  8002b1:	8b 02                	mov    (%edx),%eax
  8002b3:	99                   	cltd   
}
  8002b4:	c9                   	leave  
  8002b5:	c3                   	ret    

008002b6 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002b6:	55                   	push   %ebp
  8002b7:	89 e5                	mov    %esp,%ebp
  8002b9:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002bc:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  8002bf:	8b 10                	mov    (%eax),%edx
  8002c1:	3b 50 04             	cmp    0x4(%eax),%edx
  8002c4:	73 08                	jae    8002ce <sprintputch+0x18>
		*b->buf++ = ch;
  8002c6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8002c9:	88 0a                	mov    %cl,(%edx)
  8002cb:	42                   	inc    %edx
  8002cc:	89 10                	mov    %edx,(%eax)
}
  8002ce:	c9                   	leave  
  8002cf:	c3                   	ret    

008002d0 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8002d0:	55                   	push   %ebp
  8002d1:	89 e5                	mov    %esp,%ebp
  8002d3:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8002d6:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002d9:	50                   	push   %eax
  8002da:	ff 75 10             	pushl  0x10(%ebp)
  8002dd:	ff 75 0c             	pushl  0xc(%ebp)
  8002e0:	ff 75 08             	pushl  0x8(%ebp)
  8002e3:	e8 05 00 00 00       	call   8002ed <vprintfmt>
	va_end(ap);
  8002e8:	83 c4 10             	add    $0x10,%esp
}
  8002eb:	c9                   	leave  
  8002ec:	c3                   	ret    

008002ed <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8002ed:	55                   	push   %ebp
  8002ee:	89 e5                	mov    %esp,%ebp
  8002f0:	57                   	push   %edi
  8002f1:	56                   	push   %esi
  8002f2:	53                   	push   %ebx
  8002f3:	83 ec 2c             	sub    $0x2c,%esp
  8002f6:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8002f9:	8b 75 10             	mov    0x10(%ebp),%esi
  8002fc:	eb 13                	jmp    800311 <vprintfmt+0x24>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8002fe:	85 c0                	test   %eax,%eax
  800300:	0f 84 6d 03 00 00    	je     800673 <vprintfmt+0x386>
				return;
			putch(ch, putdat);
  800306:	83 ec 08             	sub    $0x8,%esp
  800309:	57                   	push   %edi
  80030a:	50                   	push   %eax
  80030b:	ff 55 08             	call   *0x8(%ebp)
  80030e:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800311:	0f b6 06             	movzbl (%esi),%eax
  800314:	46                   	inc    %esi
  800315:	83 f8 25             	cmp    $0x25,%eax
  800318:	75 e4                	jne    8002fe <vprintfmt+0x11>
  80031a:	c6 45 dc 20          	movb   $0x20,-0x24(%ebp)
  80031e:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  800325:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  80032c:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800333:	b9 00 00 00 00       	mov    $0x0,%ecx
  800338:	eb 28                	jmp    800362 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80033a:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  80033c:	c6 45 dc 2d          	movb   $0x2d,-0x24(%ebp)
  800340:	eb 20                	jmp    800362 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800342:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800344:	c6 45 dc 30          	movb   $0x30,-0x24(%ebp)
  800348:	eb 18                	jmp    800362 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80034a:	89 de                	mov    %ebx,%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  80034c:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800353:	eb 0d                	jmp    800362 <vprintfmt+0x75>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800355:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800358:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80035b:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800362:	8a 06                	mov    (%esi),%al
  800364:	0f b6 d0             	movzbl %al,%edx
  800367:	8d 5e 01             	lea    0x1(%esi),%ebx
  80036a:	83 e8 23             	sub    $0x23,%eax
  80036d:	3c 55                	cmp    $0x55,%al
  80036f:	0f 87 e0 02 00 00    	ja     800655 <vprintfmt+0x368>
  800375:	0f b6 c0             	movzbl %al,%eax
  800378:	ff 24 85 c0 10 80 00 	jmp    *0x8010c0(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80037f:	83 ea 30             	sub    $0x30,%edx
  800382:	89 55 d4             	mov    %edx,-0x2c(%ebp)
				ch = *fmt;
  800385:	0f be 03             	movsbl (%ebx),%eax
				if (ch < '0' || ch > '9')
  800388:	8d 50 d0             	lea    -0x30(%eax),%edx
  80038b:	83 fa 09             	cmp    $0x9,%edx
  80038e:	77 44                	ja     8003d4 <vprintfmt+0xe7>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800390:	89 de                	mov    %ebx,%esi
  800392:	8b 55 d4             	mov    -0x2c(%ebp),%edx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800395:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
  800396:	8d 14 92             	lea    (%edx,%edx,4),%edx
  800399:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
  80039d:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8003a0:	8d 58 d0             	lea    -0x30(%eax),%ebx
  8003a3:	83 fb 09             	cmp    $0x9,%ebx
  8003a6:	76 ed                	jbe    800395 <vprintfmt+0xa8>
  8003a8:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  8003ab:	eb 29                	jmp    8003d6 <vprintfmt+0xe9>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003ad:	8b 45 14             	mov    0x14(%ebp),%eax
  8003b0:	8d 50 04             	lea    0x4(%eax),%edx
  8003b3:	89 55 14             	mov    %edx,0x14(%ebp)
  8003b6:	8b 00                	mov    (%eax),%eax
  8003b8:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003bb:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8003bd:	eb 17                	jmp    8003d6 <vprintfmt+0xe9>

		case '.':
			if (width < 0)
  8003bf:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8003c3:	78 85                	js     80034a <vprintfmt+0x5d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003c5:	89 de                	mov    %ebx,%esi
  8003c7:	eb 99                	jmp    800362 <vprintfmt+0x75>
  8003c9:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8003cb:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  8003d2:	eb 8e                	jmp    800362 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003d4:	89 de                	mov    %ebx,%esi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  8003d6:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8003da:	79 86                	jns    800362 <vprintfmt+0x75>
  8003dc:	e9 74 ff ff ff       	jmp    800355 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8003e1:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003e2:	89 de                	mov    %ebx,%esi
  8003e4:	e9 79 ff ff ff       	jmp    800362 <vprintfmt+0x75>
  8003e9:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8003ec:	8b 45 14             	mov    0x14(%ebp),%eax
  8003ef:	8d 50 04             	lea    0x4(%eax),%edx
  8003f2:	89 55 14             	mov    %edx,0x14(%ebp)
  8003f5:	83 ec 08             	sub    $0x8,%esp
  8003f8:	57                   	push   %edi
  8003f9:	ff 30                	pushl  (%eax)
  8003fb:	ff 55 08             	call   *0x8(%ebp)
			break;
  8003fe:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800401:	8b 75 d8             	mov    -0x28(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800404:	e9 08 ff ff ff       	jmp    800311 <vprintfmt+0x24>
  800409:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  80040c:	8b 45 14             	mov    0x14(%ebp),%eax
  80040f:	8d 50 04             	lea    0x4(%eax),%edx
  800412:	89 55 14             	mov    %edx,0x14(%ebp)
  800415:	8b 00                	mov    (%eax),%eax
  800417:	85 c0                	test   %eax,%eax
  800419:	79 02                	jns    80041d <vprintfmt+0x130>
  80041b:	f7 d8                	neg    %eax
  80041d:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80041f:	83 f8 08             	cmp    $0x8,%eax
  800422:	7f 0b                	jg     80042f <vprintfmt+0x142>
  800424:	8b 04 85 20 12 80 00 	mov    0x801220(,%eax,4),%eax
  80042b:	85 c0                	test   %eax,%eax
  80042d:	75 1a                	jne    800449 <vprintfmt+0x15c>
				printfmt(putch, putdat, "error %d", err);
  80042f:	52                   	push   %edx
  800430:	68 0d 10 80 00       	push   $0x80100d
  800435:	57                   	push   %edi
  800436:	ff 75 08             	pushl  0x8(%ebp)
  800439:	e8 92 fe ff ff       	call   8002d0 <printfmt>
  80043e:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800441:	8b 75 d8             	mov    -0x28(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800444:	e9 c8 fe ff ff       	jmp    800311 <vprintfmt+0x24>
			else
				printfmt(putch, putdat, "%s", p);
  800449:	50                   	push   %eax
  80044a:	68 16 10 80 00       	push   $0x801016
  80044f:	57                   	push   %edi
  800450:	ff 75 08             	pushl  0x8(%ebp)
  800453:	e8 78 fe ff ff       	call   8002d0 <printfmt>
  800458:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80045b:	8b 75 d8             	mov    -0x28(%ebp),%esi
  80045e:	e9 ae fe ff ff       	jmp    800311 <vprintfmt+0x24>
  800463:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  800466:	89 de                	mov    %ebx,%esi
  800468:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  80046b:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80046e:	8b 45 14             	mov    0x14(%ebp),%eax
  800471:	8d 50 04             	lea    0x4(%eax),%edx
  800474:	89 55 14             	mov    %edx,0x14(%ebp)
  800477:	8b 00                	mov    (%eax),%eax
  800479:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80047c:	85 c0                	test   %eax,%eax
  80047e:	75 07                	jne    800487 <vprintfmt+0x19a>
				p = "(null)";
  800480:	c7 45 d0 06 10 80 00 	movl   $0x801006,-0x30(%ebp)
			if (width > 0 && padc != '-')
  800487:	85 db                	test   %ebx,%ebx
  800489:	7e 42                	jle    8004cd <vprintfmt+0x1e0>
  80048b:	80 7d dc 2d          	cmpb   $0x2d,-0x24(%ebp)
  80048f:	74 3c                	je     8004cd <vprintfmt+0x1e0>
				for (width -= strnlen(p, precision); width > 0; width--)
  800491:	83 ec 08             	sub    $0x8,%esp
  800494:	51                   	push   %ecx
  800495:	ff 75 d0             	pushl  -0x30(%ebp)
  800498:	e8 6f 02 00 00       	call   80070c <strnlen>
  80049d:	29 c3                	sub    %eax,%ebx
  80049f:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8004a2:	83 c4 10             	add    $0x10,%esp
  8004a5:	85 db                	test   %ebx,%ebx
  8004a7:	7e 24                	jle    8004cd <vprintfmt+0x1e0>
					putch(padc, putdat);
  8004a9:	0f be 5d dc          	movsbl -0x24(%ebp),%ebx
  8004ad:	89 75 dc             	mov    %esi,-0x24(%ebp)
  8004b0:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  8004b3:	83 ec 08             	sub    $0x8,%esp
  8004b6:	57                   	push   %edi
  8004b7:	53                   	push   %ebx
  8004b8:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004bb:	4e                   	dec    %esi
  8004bc:	83 c4 10             	add    $0x10,%esp
  8004bf:	85 f6                	test   %esi,%esi
  8004c1:	7f f0                	jg     8004b3 <vprintfmt+0x1c6>
  8004c3:	8b 75 dc             	mov    -0x24(%ebp),%esi
  8004c6:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004cd:	8b 55 d0             	mov    -0x30(%ebp),%edx
  8004d0:	0f be 02             	movsbl (%edx),%eax
  8004d3:	85 c0                	test   %eax,%eax
  8004d5:	75 47                	jne    80051e <vprintfmt+0x231>
  8004d7:	eb 37                	jmp    800510 <vprintfmt+0x223>
				if (altflag && (ch < ' ' || ch > '~'))
  8004d9:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004dd:	74 16                	je     8004f5 <vprintfmt+0x208>
  8004df:	8d 50 e0             	lea    -0x20(%eax),%edx
  8004e2:	83 fa 5e             	cmp    $0x5e,%edx
  8004e5:	76 0e                	jbe    8004f5 <vprintfmt+0x208>
					putch('?', putdat);
  8004e7:	83 ec 08             	sub    $0x8,%esp
  8004ea:	57                   	push   %edi
  8004eb:	6a 3f                	push   $0x3f
  8004ed:	ff 55 08             	call   *0x8(%ebp)
  8004f0:	83 c4 10             	add    $0x10,%esp
  8004f3:	eb 0b                	jmp    800500 <vprintfmt+0x213>
				else
					putch(ch, putdat);
  8004f5:	83 ec 08             	sub    $0x8,%esp
  8004f8:	57                   	push   %edi
  8004f9:	50                   	push   %eax
  8004fa:	ff 55 08             	call   *0x8(%ebp)
  8004fd:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800500:	ff 4d e4             	decl   -0x1c(%ebp)
  800503:	0f be 03             	movsbl (%ebx),%eax
  800506:	85 c0                	test   %eax,%eax
  800508:	74 03                	je     80050d <vprintfmt+0x220>
  80050a:	43                   	inc    %ebx
  80050b:	eb 1b                	jmp    800528 <vprintfmt+0x23b>
  80050d:	8b 75 dc             	mov    -0x24(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800510:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800514:	7f 1e                	jg     800534 <vprintfmt+0x247>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800516:	8b 75 d8             	mov    -0x28(%ebp),%esi
  800519:	e9 f3 fd ff ff       	jmp    800311 <vprintfmt+0x24>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80051e:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800521:	43                   	inc    %ebx
  800522:	89 75 dc             	mov    %esi,-0x24(%ebp)
  800525:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  800528:	85 f6                	test   %esi,%esi
  80052a:	78 ad                	js     8004d9 <vprintfmt+0x1ec>
  80052c:	4e                   	dec    %esi
  80052d:	79 aa                	jns    8004d9 <vprintfmt+0x1ec>
  80052f:	8b 75 dc             	mov    -0x24(%ebp),%esi
  800532:	eb dc                	jmp    800510 <vprintfmt+0x223>
  800534:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800537:	83 ec 08             	sub    $0x8,%esp
  80053a:	57                   	push   %edi
  80053b:	6a 20                	push   $0x20
  80053d:	ff 55 08             	call   *0x8(%ebp)
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800540:	4b                   	dec    %ebx
  800541:	83 c4 10             	add    $0x10,%esp
  800544:	85 db                	test   %ebx,%ebx
  800546:	7f ef                	jg     800537 <vprintfmt+0x24a>
  800548:	e9 c4 fd ff ff       	jmp    800311 <vprintfmt+0x24>
  80054d:	89 5d d8             	mov    %ebx,-0x28(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800550:	89 ca                	mov    %ecx,%edx
  800552:	8d 45 14             	lea    0x14(%ebp),%eax
  800555:	e8 2a fd ff ff       	call   800284 <getint>
  80055a:	89 c3                	mov    %eax,%ebx
  80055c:	89 d6                	mov    %edx,%esi
			if ((long long) num < 0) {
  80055e:	85 d2                	test   %edx,%edx
  800560:	78 0a                	js     80056c <vprintfmt+0x27f>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800562:	b8 0a 00 00 00       	mov    $0xa,%eax
  800567:	e9 b0 00 00 00       	jmp    80061c <vprintfmt+0x32f>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  80056c:	83 ec 08             	sub    $0x8,%esp
  80056f:	57                   	push   %edi
  800570:	6a 2d                	push   $0x2d
  800572:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800575:	f7 db                	neg    %ebx
  800577:	83 d6 00             	adc    $0x0,%esi
  80057a:	f7 de                	neg    %esi
  80057c:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  80057f:	b8 0a 00 00 00       	mov    $0xa,%eax
  800584:	e9 93 00 00 00       	jmp    80061c <vprintfmt+0x32f>
  800589:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80058c:	89 ca                	mov    %ecx,%edx
  80058e:	8d 45 14             	lea    0x14(%ebp),%eax
  800591:	e8 b4 fc ff ff       	call   80024a <getuint>
  800596:	89 c3                	mov    %eax,%ebx
  800598:	89 d6                	mov    %edx,%esi
			base = 10;
  80059a:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  80059f:	eb 7b                	jmp    80061c <vprintfmt+0x32f>
  8005a1:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
  8005a4:	89 ca                	mov    %ecx,%edx
  8005a6:	8d 45 14             	lea    0x14(%ebp),%eax
  8005a9:	e8 d6 fc ff ff       	call   800284 <getint>
  8005ae:	89 c3                	mov    %eax,%ebx
  8005b0:	89 d6                	mov    %edx,%esi
            if ((long long) num < 0) {
  8005b2:	85 d2                	test   %edx,%edx
  8005b4:	78 07                	js     8005bd <vprintfmt+0x2d0>
                putch('-', putdat);
                num = -(long long) num;
            }
            base = 8;
  8005b6:	b8 08 00 00 00       	mov    $0x8,%eax
  8005bb:	eb 5f                	jmp    80061c <vprintfmt+0x32f>
		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
            if ((long long) num < 0) {
                putch('-', putdat);
  8005bd:	83 ec 08             	sub    $0x8,%esp
  8005c0:	57                   	push   %edi
  8005c1:	6a 2d                	push   $0x2d
  8005c3:	ff 55 08             	call   *0x8(%ebp)
                num = -(long long) num;
  8005c6:	f7 db                	neg    %ebx
  8005c8:	83 d6 00             	adc    $0x0,%esi
  8005cb:	f7 de                	neg    %esi
  8005cd:	83 c4 10             	add    $0x10,%esp
            }
            base = 8;
  8005d0:	b8 08 00 00 00       	mov    $0x8,%eax
  8005d5:	eb 45                	jmp    80061c <vprintfmt+0x32f>
  8005d7:	89 5d d8             	mov    %ebx,-0x28(%ebp)
            goto number;

        // pointer
		case 'p':
			putch('0', putdat);
  8005da:	83 ec 08             	sub    $0x8,%esp
  8005dd:	57                   	push   %edi
  8005de:	6a 30                	push   $0x30
  8005e0:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8005e3:	83 c4 08             	add    $0x8,%esp
  8005e6:	57                   	push   %edi
  8005e7:	6a 78                	push   $0x78
  8005e9:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8005ec:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ef:	8d 50 04             	lea    0x4(%eax),%edx
  8005f2:	89 55 14             	mov    %edx,0x14(%ebp)

        // pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8005f5:	8b 18                	mov    (%eax),%ebx
  8005f7:	be 00 00 00 00       	mov    $0x0,%esi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8005fc:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8005ff:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800604:	eb 16                	jmp    80061c <vprintfmt+0x32f>
  800606:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800609:	89 ca                	mov    %ecx,%edx
  80060b:	8d 45 14             	lea    0x14(%ebp),%eax
  80060e:	e8 37 fc ff ff       	call   80024a <getuint>
  800613:	89 c3                	mov    %eax,%ebx
  800615:	89 d6                	mov    %edx,%esi
			base = 16;
  800617:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  80061c:	83 ec 0c             	sub    $0xc,%esp
  80061f:	0f be 55 dc          	movsbl -0x24(%ebp),%edx
  800623:	52                   	push   %edx
  800624:	ff 75 e4             	pushl  -0x1c(%ebp)
  800627:	50                   	push   %eax
  800628:	56                   	push   %esi
  800629:	53                   	push   %ebx
  80062a:	89 fa                	mov    %edi,%edx
  80062c:	8b 45 08             	mov    0x8(%ebp),%eax
  80062f:	e8 68 fb ff ff       	call   80019c <printnum>
			break;
  800634:	83 c4 20             	add    $0x20,%esp
  800637:	8b 75 d8             	mov    -0x28(%ebp),%esi
  80063a:	e9 d2 fc ff ff       	jmp    800311 <vprintfmt+0x24>
  80063f:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800642:	83 ec 08             	sub    $0x8,%esp
  800645:	57                   	push   %edi
  800646:	52                   	push   %edx
  800647:	ff 55 08             	call   *0x8(%ebp)
			break;
  80064a:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80064d:	8b 75 d8             	mov    -0x28(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800650:	e9 bc fc ff ff       	jmp    800311 <vprintfmt+0x24>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800655:	83 ec 08             	sub    $0x8,%esp
  800658:	57                   	push   %edi
  800659:	6a 25                	push   $0x25
  80065b:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  80065e:	83 c4 10             	add    $0x10,%esp
  800661:	eb 02                	jmp    800665 <vprintfmt+0x378>
  800663:	89 c6                	mov    %eax,%esi
  800665:	8d 46 ff             	lea    -0x1(%esi),%eax
  800668:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  80066c:	75 f5                	jne    800663 <vprintfmt+0x376>
  80066e:	e9 9e fc ff ff       	jmp    800311 <vprintfmt+0x24>
				/* do nothing */;
			break;
		}
	}
}
  800673:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800676:	5b                   	pop    %ebx
  800677:	5e                   	pop    %esi
  800678:	5f                   	pop    %edi
  800679:	c9                   	leave  
  80067a:	c3                   	ret    

0080067b <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80067b:	55                   	push   %ebp
  80067c:	89 e5                	mov    %esp,%ebp
  80067e:	83 ec 18             	sub    $0x18,%esp
  800681:	8b 45 08             	mov    0x8(%ebp),%eax
  800684:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800687:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80068a:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80068e:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800691:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800698:	85 c0                	test   %eax,%eax
  80069a:	74 26                	je     8006c2 <vsnprintf+0x47>
  80069c:	85 d2                	test   %edx,%edx
  80069e:	7e 29                	jle    8006c9 <vsnprintf+0x4e>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8006a0:	ff 75 14             	pushl  0x14(%ebp)
  8006a3:	ff 75 10             	pushl  0x10(%ebp)
  8006a6:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8006a9:	50                   	push   %eax
  8006aa:	68 b6 02 80 00       	push   $0x8002b6
  8006af:	e8 39 fc ff ff       	call   8002ed <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8006b4:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8006b7:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8006ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006bd:	83 c4 10             	add    $0x10,%esp
  8006c0:	eb 0c                	jmp    8006ce <vsnprintf+0x53>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8006c2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8006c7:	eb 05                	jmp    8006ce <vsnprintf+0x53>
  8006c9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8006ce:	c9                   	leave  
  8006cf:	c3                   	ret    

008006d0 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8006d0:	55                   	push   %ebp
  8006d1:	89 e5                	mov    %esp,%ebp
  8006d3:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8006d6:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8006d9:	50                   	push   %eax
  8006da:	ff 75 10             	pushl  0x10(%ebp)
  8006dd:	ff 75 0c             	pushl  0xc(%ebp)
  8006e0:	ff 75 08             	pushl  0x8(%ebp)
  8006e3:	e8 93 ff ff ff       	call   80067b <vsnprintf>
	va_end(ap);

	return rc;
}
  8006e8:	c9                   	leave  
  8006e9:	c3                   	ret    
	...

008006ec <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8006ec:	55                   	push   %ebp
  8006ed:	89 e5                	mov    %esp,%ebp
  8006ef:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8006f2:	80 3a 00             	cmpb   $0x0,(%edx)
  8006f5:	74 0e                	je     800705 <strlen+0x19>
  8006f7:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  8006fc:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8006fd:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800701:	75 f9                	jne    8006fc <strlen+0x10>
  800703:	eb 05                	jmp    80070a <strlen+0x1e>
  800705:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  80070a:	c9                   	leave  
  80070b:	c3                   	ret    

0080070c <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80070c:	55                   	push   %ebp
  80070d:	89 e5                	mov    %esp,%ebp
  80070f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800712:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800715:	85 d2                	test   %edx,%edx
  800717:	74 17                	je     800730 <strnlen+0x24>
  800719:	80 39 00             	cmpb   $0x0,(%ecx)
  80071c:	74 19                	je     800737 <strnlen+0x2b>
  80071e:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800723:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800724:	39 d0                	cmp    %edx,%eax
  800726:	74 14                	je     80073c <strnlen+0x30>
  800728:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  80072c:	75 f5                	jne    800723 <strnlen+0x17>
  80072e:	eb 0c                	jmp    80073c <strnlen+0x30>
  800730:	b8 00 00 00 00       	mov    $0x0,%eax
  800735:	eb 05                	jmp    80073c <strnlen+0x30>
  800737:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  80073c:	c9                   	leave  
  80073d:	c3                   	ret    

0080073e <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80073e:	55                   	push   %ebp
  80073f:	89 e5                	mov    %esp,%ebp
  800741:	53                   	push   %ebx
  800742:	8b 45 08             	mov    0x8(%ebp),%eax
  800745:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800748:	ba 00 00 00 00       	mov    $0x0,%edx
  80074d:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  800750:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800753:	42                   	inc    %edx
  800754:	84 c9                	test   %cl,%cl
  800756:	75 f5                	jne    80074d <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800758:	5b                   	pop    %ebx
  800759:	c9                   	leave  
  80075a:	c3                   	ret    

0080075b <strcat>:

char *
strcat(char *dst, const char *src)
{
  80075b:	55                   	push   %ebp
  80075c:	89 e5                	mov    %esp,%ebp
  80075e:	53                   	push   %ebx
  80075f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800762:	53                   	push   %ebx
  800763:	e8 84 ff ff ff       	call   8006ec <strlen>
  800768:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  80076b:	ff 75 0c             	pushl  0xc(%ebp)
  80076e:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  800771:	50                   	push   %eax
  800772:	e8 c7 ff ff ff       	call   80073e <strcpy>
	return dst;
}
  800777:	89 d8                	mov    %ebx,%eax
  800779:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80077c:	c9                   	leave  
  80077d:	c3                   	ret    

0080077e <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80077e:	55                   	push   %ebp
  80077f:	89 e5                	mov    %esp,%ebp
  800781:	56                   	push   %esi
  800782:	53                   	push   %ebx
  800783:	8b 45 08             	mov    0x8(%ebp),%eax
  800786:	8b 55 0c             	mov    0xc(%ebp),%edx
  800789:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80078c:	85 f6                	test   %esi,%esi
  80078e:	74 15                	je     8007a5 <strncpy+0x27>
  800790:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  800795:	8a 1a                	mov    (%edx),%bl
  800797:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80079a:	80 3a 01             	cmpb   $0x1,(%edx)
  80079d:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007a0:	41                   	inc    %ecx
  8007a1:	39 ce                	cmp    %ecx,%esi
  8007a3:	77 f0                	ja     800795 <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8007a5:	5b                   	pop    %ebx
  8007a6:	5e                   	pop    %esi
  8007a7:	c9                   	leave  
  8007a8:	c3                   	ret    

008007a9 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8007a9:	55                   	push   %ebp
  8007aa:	89 e5                	mov    %esp,%ebp
  8007ac:	57                   	push   %edi
  8007ad:	56                   	push   %esi
  8007ae:	53                   	push   %ebx
  8007af:	8b 7d 08             	mov    0x8(%ebp),%edi
  8007b2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8007b5:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007b8:	85 f6                	test   %esi,%esi
  8007ba:	74 32                	je     8007ee <strlcpy+0x45>
		while (--size > 0 && *src != '\0')
  8007bc:	83 fe 01             	cmp    $0x1,%esi
  8007bf:	74 22                	je     8007e3 <strlcpy+0x3a>
  8007c1:	8a 0b                	mov    (%ebx),%cl
  8007c3:	84 c9                	test   %cl,%cl
  8007c5:	74 20                	je     8007e7 <strlcpy+0x3e>
  8007c7:	89 f8                	mov    %edi,%eax
  8007c9:	ba 00 00 00 00       	mov    $0x0,%edx
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
  8007ce:	83 ee 02             	sub    $0x2,%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8007d1:	88 08                	mov    %cl,(%eax)
  8007d3:	40                   	inc    %eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8007d4:	39 f2                	cmp    %esi,%edx
  8007d6:	74 11                	je     8007e9 <strlcpy+0x40>
  8007d8:	8a 4c 13 01          	mov    0x1(%ebx,%edx,1),%cl
  8007dc:	42                   	inc    %edx
  8007dd:	84 c9                	test   %cl,%cl
  8007df:	75 f0                	jne    8007d1 <strlcpy+0x28>
  8007e1:	eb 06                	jmp    8007e9 <strlcpy+0x40>
  8007e3:	89 f8                	mov    %edi,%eax
  8007e5:	eb 02                	jmp    8007e9 <strlcpy+0x40>
  8007e7:	89 f8                	mov    %edi,%eax
			*dst++ = *src++;
		*dst = '\0';
  8007e9:	c6 00 00             	movb   $0x0,(%eax)
  8007ec:	eb 02                	jmp    8007f0 <strlcpy+0x47>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007ee:	89 f8                	mov    %edi,%eax
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
		*dst = '\0';
	}
	return dst - dst_in;
  8007f0:	29 f8                	sub    %edi,%eax
}
  8007f2:	5b                   	pop    %ebx
  8007f3:	5e                   	pop    %esi
  8007f4:	5f                   	pop    %edi
  8007f5:	c9                   	leave  
  8007f6:	c3                   	ret    

008007f7 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8007f7:	55                   	push   %ebp
  8007f8:	89 e5                	mov    %esp,%ebp
  8007fa:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007fd:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800800:	8a 01                	mov    (%ecx),%al
  800802:	84 c0                	test   %al,%al
  800804:	74 10                	je     800816 <strcmp+0x1f>
  800806:	3a 02                	cmp    (%edx),%al
  800808:	75 0c                	jne    800816 <strcmp+0x1f>
		p++, q++;
  80080a:	41                   	inc    %ecx
  80080b:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80080c:	8a 01                	mov    (%ecx),%al
  80080e:	84 c0                	test   %al,%al
  800810:	74 04                	je     800816 <strcmp+0x1f>
  800812:	3a 02                	cmp    (%edx),%al
  800814:	74 f4                	je     80080a <strcmp+0x13>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800816:	0f b6 c0             	movzbl %al,%eax
  800819:	0f b6 12             	movzbl (%edx),%edx
  80081c:	29 d0                	sub    %edx,%eax
}
  80081e:	c9                   	leave  
  80081f:	c3                   	ret    

00800820 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800820:	55                   	push   %ebp
  800821:	89 e5                	mov    %esp,%ebp
  800823:	53                   	push   %ebx
  800824:	8b 55 08             	mov    0x8(%ebp),%edx
  800827:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80082a:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  80082d:	85 c0                	test   %eax,%eax
  80082f:	74 1b                	je     80084c <strncmp+0x2c>
  800831:	8a 1a                	mov    (%edx),%bl
  800833:	84 db                	test   %bl,%bl
  800835:	74 24                	je     80085b <strncmp+0x3b>
  800837:	3a 19                	cmp    (%ecx),%bl
  800839:	75 20                	jne    80085b <strncmp+0x3b>
  80083b:	48                   	dec    %eax
  80083c:	74 15                	je     800853 <strncmp+0x33>
		n--, p++, q++;
  80083e:	42                   	inc    %edx
  80083f:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800840:	8a 1a                	mov    (%edx),%bl
  800842:	84 db                	test   %bl,%bl
  800844:	74 15                	je     80085b <strncmp+0x3b>
  800846:	3a 19                	cmp    (%ecx),%bl
  800848:	74 f1                	je     80083b <strncmp+0x1b>
  80084a:	eb 0f                	jmp    80085b <strncmp+0x3b>
		n--, p++, q++;
	if (n == 0)
		return 0;
  80084c:	b8 00 00 00 00       	mov    $0x0,%eax
  800851:	eb 05                	jmp    800858 <strncmp+0x38>
  800853:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800858:	5b                   	pop    %ebx
  800859:	c9                   	leave  
  80085a:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80085b:	0f b6 02             	movzbl (%edx),%eax
  80085e:	0f b6 11             	movzbl (%ecx),%edx
  800861:	29 d0                	sub    %edx,%eax
  800863:	eb f3                	jmp    800858 <strncmp+0x38>

00800865 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800865:	55                   	push   %ebp
  800866:	89 e5                	mov    %esp,%ebp
  800868:	8b 45 08             	mov    0x8(%ebp),%eax
  80086b:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  80086e:	8a 10                	mov    (%eax),%dl
  800870:	84 d2                	test   %dl,%dl
  800872:	74 18                	je     80088c <strchr+0x27>
		if (*s == c)
  800874:	38 ca                	cmp    %cl,%dl
  800876:	75 06                	jne    80087e <strchr+0x19>
  800878:	eb 17                	jmp    800891 <strchr+0x2c>
  80087a:	38 ca                	cmp    %cl,%dl
  80087c:	74 13                	je     800891 <strchr+0x2c>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80087e:	40                   	inc    %eax
  80087f:	8a 10                	mov    (%eax),%dl
  800881:	84 d2                	test   %dl,%dl
  800883:	75 f5                	jne    80087a <strchr+0x15>
		if (*s == c)
			return (char *) s;
	return 0;
  800885:	b8 00 00 00 00       	mov    $0x0,%eax
  80088a:	eb 05                	jmp    800891 <strchr+0x2c>
  80088c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800891:	c9                   	leave  
  800892:	c3                   	ret    

00800893 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800893:	55                   	push   %ebp
  800894:	89 e5                	mov    %esp,%ebp
  800896:	8b 45 08             	mov    0x8(%ebp),%eax
  800899:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  80089c:	8a 10                	mov    (%eax),%dl
  80089e:	84 d2                	test   %dl,%dl
  8008a0:	74 11                	je     8008b3 <strfind+0x20>
		if (*s == c)
  8008a2:	38 ca                	cmp    %cl,%dl
  8008a4:	75 06                	jne    8008ac <strfind+0x19>
  8008a6:	eb 0b                	jmp    8008b3 <strfind+0x20>
  8008a8:	38 ca                	cmp    %cl,%dl
  8008aa:	74 07                	je     8008b3 <strfind+0x20>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  8008ac:	40                   	inc    %eax
  8008ad:	8a 10                	mov    (%eax),%dl
  8008af:	84 d2                	test   %dl,%dl
  8008b1:	75 f5                	jne    8008a8 <strfind+0x15>
		if (*s == c)
			break;
	return (char *) s;
}
  8008b3:	c9                   	leave  
  8008b4:	c3                   	ret    

008008b5 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008b5:	55                   	push   %ebp
  8008b6:	89 e5                	mov    %esp,%ebp
  8008b8:	57                   	push   %edi
  8008b9:	56                   	push   %esi
  8008ba:	53                   	push   %ebx
  8008bb:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008be:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008c1:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8008c4:	85 c9                	test   %ecx,%ecx
  8008c6:	74 30                	je     8008f8 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008c8:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008ce:	75 25                	jne    8008f5 <memset+0x40>
  8008d0:	f6 c1 03             	test   $0x3,%cl
  8008d3:	75 20                	jne    8008f5 <memset+0x40>
		c &= 0xFF;
  8008d5:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8008d8:	89 d3                	mov    %edx,%ebx
  8008da:	c1 e3 08             	shl    $0x8,%ebx
  8008dd:	89 d6                	mov    %edx,%esi
  8008df:	c1 e6 18             	shl    $0x18,%esi
  8008e2:	89 d0                	mov    %edx,%eax
  8008e4:	c1 e0 10             	shl    $0x10,%eax
  8008e7:	09 f0                	or     %esi,%eax
  8008e9:	09 d0                	or     %edx,%eax
  8008eb:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  8008ed:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  8008f0:	fc                   	cld    
  8008f1:	f3 ab                	rep stos %eax,%es:(%edi)
  8008f3:	eb 03                	jmp    8008f8 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8008f5:	fc                   	cld    
  8008f6:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8008f8:	89 f8                	mov    %edi,%eax
  8008fa:	5b                   	pop    %ebx
  8008fb:	5e                   	pop    %esi
  8008fc:	5f                   	pop    %edi
  8008fd:	c9                   	leave  
  8008fe:	c3                   	ret    

008008ff <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8008ff:	55                   	push   %ebp
  800900:	89 e5                	mov    %esp,%ebp
  800902:	57                   	push   %edi
  800903:	56                   	push   %esi
  800904:	8b 45 08             	mov    0x8(%ebp),%eax
  800907:	8b 75 0c             	mov    0xc(%ebp),%esi
  80090a:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80090d:	39 c6                	cmp    %eax,%esi
  80090f:	73 34                	jae    800945 <memmove+0x46>
  800911:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800914:	39 d0                	cmp    %edx,%eax
  800916:	73 2d                	jae    800945 <memmove+0x46>
		s += n;
		d += n;
  800918:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80091b:	f6 c2 03             	test   $0x3,%dl
  80091e:	75 1b                	jne    80093b <memmove+0x3c>
  800920:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800926:	75 13                	jne    80093b <memmove+0x3c>
  800928:	f6 c1 03             	test   $0x3,%cl
  80092b:	75 0e                	jne    80093b <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  80092d:	83 ef 04             	sub    $0x4,%edi
  800930:	8d 72 fc             	lea    -0x4(%edx),%esi
  800933:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800936:	fd                   	std    
  800937:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800939:	eb 07                	jmp    800942 <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  80093b:	4f                   	dec    %edi
  80093c:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  80093f:	fd                   	std    
  800940:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800942:	fc                   	cld    
  800943:	eb 20                	jmp    800965 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800945:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80094b:	75 13                	jne    800960 <memmove+0x61>
  80094d:	a8 03                	test   $0x3,%al
  80094f:	75 0f                	jne    800960 <memmove+0x61>
  800951:	f6 c1 03             	test   $0x3,%cl
  800954:	75 0a                	jne    800960 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800956:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800959:	89 c7                	mov    %eax,%edi
  80095b:	fc                   	cld    
  80095c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80095e:	eb 05                	jmp    800965 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800960:	89 c7                	mov    %eax,%edi
  800962:	fc                   	cld    
  800963:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800965:	5e                   	pop    %esi
  800966:	5f                   	pop    %edi
  800967:	c9                   	leave  
  800968:	c3                   	ret    

00800969 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800969:	55                   	push   %ebp
  80096a:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  80096c:	ff 75 10             	pushl  0x10(%ebp)
  80096f:	ff 75 0c             	pushl  0xc(%ebp)
  800972:	ff 75 08             	pushl  0x8(%ebp)
  800975:	e8 85 ff ff ff       	call   8008ff <memmove>
}
  80097a:	c9                   	leave  
  80097b:	c3                   	ret    

0080097c <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  80097c:	55                   	push   %ebp
  80097d:	89 e5                	mov    %esp,%ebp
  80097f:	57                   	push   %edi
  800980:	56                   	push   %esi
  800981:	53                   	push   %ebx
  800982:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800985:	8b 75 0c             	mov    0xc(%ebp),%esi
  800988:	8b 7d 10             	mov    0x10(%ebp),%edi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80098b:	85 ff                	test   %edi,%edi
  80098d:	74 32                	je     8009c1 <memcmp+0x45>
		if (*s1 != *s2)
  80098f:	8a 03                	mov    (%ebx),%al
  800991:	8a 0e                	mov    (%esi),%cl
  800993:	38 c8                	cmp    %cl,%al
  800995:	74 19                	je     8009b0 <memcmp+0x34>
  800997:	eb 0d                	jmp    8009a6 <memcmp+0x2a>
  800999:	8a 44 13 01          	mov    0x1(%ebx,%edx,1),%al
  80099d:	8a 4c 16 01          	mov    0x1(%esi,%edx,1),%cl
  8009a1:	42                   	inc    %edx
  8009a2:	38 c8                	cmp    %cl,%al
  8009a4:	74 10                	je     8009b6 <memcmp+0x3a>
			return (int) *s1 - (int) *s2;
  8009a6:	0f b6 c0             	movzbl %al,%eax
  8009a9:	0f b6 c9             	movzbl %cl,%ecx
  8009ac:	29 c8                	sub    %ecx,%eax
  8009ae:	eb 16                	jmp    8009c6 <memcmp+0x4a>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009b0:	4f                   	dec    %edi
  8009b1:	ba 00 00 00 00       	mov    $0x0,%edx
  8009b6:	39 fa                	cmp    %edi,%edx
  8009b8:	75 df                	jne    800999 <memcmp+0x1d>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8009ba:	b8 00 00 00 00       	mov    $0x0,%eax
  8009bf:	eb 05                	jmp    8009c6 <memcmp+0x4a>
  8009c1:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009c6:	5b                   	pop    %ebx
  8009c7:	5e                   	pop    %esi
  8009c8:	5f                   	pop    %edi
  8009c9:	c9                   	leave  
  8009ca:	c3                   	ret    

008009cb <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009cb:	55                   	push   %ebp
  8009cc:	89 e5                	mov    %esp,%ebp
  8009ce:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  8009d1:	89 c2                	mov    %eax,%edx
  8009d3:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  8009d6:	39 d0                	cmp    %edx,%eax
  8009d8:	73 12                	jae    8009ec <memfind+0x21>
		if (*(const unsigned char *) s == (unsigned char) c)
  8009da:	8a 4d 0c             	mov    0xc(%ebp),%cl
  8009dd:	38 08                	cmp    %cl,(%eax)
  8009df:	75 06                	jne    8009e7 <memfind+0x1c>
  8009e1:	eb 09                	jmp    8009ec <memfind+0x21>
  8009e3:	38 08                	cmp    %cl,(%eax)
  8009e5:	74 05                	je     8009ec <memfind+0x21>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009e7:	40                   	inc    %eax
  8009e8:	39 c2                	cmp    %eax,%edx
  8009ea:	77 f7                	ja     8009e3 <memfind+0x18>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8009ec:	c9                   	leave  
  8009ed:	c3                   	ret    

008009ee <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8009ee:	55                   	push   %ebp
  8009ef:	89 e5                	mov    %esp,%ebp
  8009f1:	57                   	push   %edi
  8009f2:	56                   	push   %esi
  8009f3:	53                   	push   %ebx
  8009f4:	8b 55 08             	mov    0x8(%ebp),%edx
  8009f7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009fa:	eb 01                	jmp    8009fd <strtol+0xf>
		s++;
  8009fc:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009fd:	8a 02                	mov    (%edx),%al
  8009ff:	3c 20                	cmp    $0x20,%al
  800a01:	74 f9                	je     8009fc <strtol+0xe>
  800a03:	3c 09                	cmp    $0x9,%al
  800a05:	74 f5                	je     8009fc <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a07:	3c 2b                	cmp    $0x2b,%al
  800a09:	75 08                	jne    800a13 <strtol+0x25>
		s++;
  800a0b:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a0c:	bf 00 00 00 00       	mov    $0x0,%edi
  800a11:	eb 13                	jmp    800a26 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a13:	3c 2d                	cmp    $0x2d,%al
  800a15:	75 0a                	jne    800a21 <strtol+0x33>
		s++, neg = 1;
  800a17:	8d 52 01             	lea    0x1(%edx),%edx
  800a1a:	bf 01 00 00 00       	mov    $0x1,%edi
  800a1f:	eb 05                	jmp    800a26 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a21:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a26:	85 db                	test   %ebx,%ebx
  800a28:	74 05                	je     800a2f <strtol+0x41>
  800a2a:	83 fb 10             	cmp    $0x10,%ebx
  800a2d:	75 28                	jne    800a57 <strtol+0x69>
  800a2f:	8a 02                	mov    (%edx),%al
  800a31:	3c 30                	cmp    $0x30,%al
  800a33:	75 10                	jne    800a45 <strtol+0x57>
  800a35:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800a39:	75 0a                	jne    800a45 <strtol+0x57>
		s += 2, base = 16;
  800a3b:	83 c2 02             	add    $0x2,%edx
  800a3e:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a43:	eb 12                	jmp    800a57 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800a45:	85 db                	test   %ebx,%ebx
  800a47:	75 0e                	jne    800a57 <strtol+0x69>
  800a49:	3c 30                	cmp    $0x30,%al
  800a4b:	75 05                	jne    800a52 <strtol+0x64>
		s++, base = 8;
  800a4d:	42                   	inc    %edx
  800a4e:	b3 08                	mov    $0x8,%bl
  800a50:	eb 05                	jmp    800a57 <strtol+0x69>
	else if (base == 0)
		base = 10;
  800a52:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800a57:	b8 00 00 00 00       	mov    $0x0,%eax
  800a5c:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a5e:	8a 0a                	mov    (%edx),%cl
  800a60:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800a63:	80 fb 09             	cmp    $0x9,%bl
  800a66:	77 08                	ja     800a70 <strtol+0x82>
			dig = *s - '0';
  800a68:	0f be c9             	movsbl %cl,%ecx
  800a6b:	83 e9 30             	sub    $0x30,%ecx
  800a6e:	eb 1e                	jmp    800a8e <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800a70:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800a73:	80 fb 19             	cmp    $0x19,%bl
  800a76:	77 08                	ja     800a80 <strtol+0x92>
			dig = *s - 'a' + 10;
  800a78:	0f be c9             	movsbl %cl,%ecx
  800a7b:	83 e9 57             	sub    $0x57,%ecx
  800a7e:	eb 0e                	jmp    800a8e <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800a80:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800a83:	80 fb 19             	cmp    $0x19,%bl
  800a86:	77 13                	ja     800a9b <strtol+0xad>
			dig = *s - 'A' + 10;
  800a88:	0f be c9             	movsbl %cl,%ecx
  800a8b:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800a8e:	39 f1                	cmp    %esi,%ecx
  800a90:	7d 0d                	jge    800a9f <strtol+0xb1>
			break;
		s++, val = (val * base) + dig;
  800a92:	42                   	inc    %edx
  800a93:	0f af c6             	imul   %esi,%eax
  800a96:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  800a99:	eb c3                	jmp    800a5e <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800a9b:	89 c1                	mov    %eax,%ecx
  800a9d:	eb 02                	jmp    800aa1 <strtol+0xb3>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800a9f:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800aa1:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800aa5:	74 05                	je     800aac <strtol+0xbe>
		*endptr = (char *) s;
  800aa7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800aaa:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800aac:	85 ff                	test   %edi,%edi
  800aae:	74 04                	je     800ab4 <strtol+0xc6>
  800ab0:	89 c8                	mov    %ecx,%eax
  800ab2:	f7 d8                	neg    %eax
}
  800ab4:	5b                   	pop    %ebx
  800ab5:	5e                   	pop    %esi
  800ab6:	5f                   	pop    %edi
  800ab7:	c9                   	leave  
  800ab8:	c3                   	ret    
  800ab9:	00 00                	add    %al,(%eax)
	...

00800abc <syscall>:
	return ret;
}

static int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800abc:	55                   	push   %ebp
  800abd:	89 e5                	mov    %esp,%ebp
  800abf:	57                   	push   %edi
  800ac0:	56                   	push   %esi
  800ac1:	53                   	push   %ebx
  800ac2:	83 ec 1c             	sub    $0x1c,%esp
  800ac5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800ac8:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800acb:	89 ca                	mov    %ecx,%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800acd:	8b 75 14             	mov    0x14(%ebp),%esi
  800ad0:	8b 7d 10             	mov    0x10(%ebp),%edi
  800ad3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800ad6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ad9:	cd 30                	int    $0x30
  800adb:	89 c2                	mov    %eax,%edx
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800add:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800ae1:	74 1c                	je     800aff <syscall+0x43>
  800ae3:	85 c0                	test   %eax,%eax
  800ae5:	7e 18                	jle    800aff <syscall+0x43>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ae7:	83 ec 0c             	sub    $0xc,%esp
  800aea:	50                   	push   %eax
  800aeb:	ff 75 e4             	pushl  -0x1c(%ebp)
  800aee:	68 44 12 80 00       	push   $0x801244
  800af3:	6a 42                	push   $0x42
  800af5:	68 61 12 80 00       	push   $0x801261
  800afa:	e8 e1 01 00 00       	call   800ce0 <_panic>

	return ret;
}
  800aff:	89 d0                	mov    %edx,%eax
  800b01:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b04:	5b                   	pop    %ebx
  800b05:	5e                   	pop    %esi
  800b06:	5f                   	pop    %edi
  800b07:	c9                   	leave  
  800b08:	c3                   	ret    

00800b09 <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{	
  800b09:	55                   	push   %ebp
  800b0a:	89 e5                	mov    %esp,%ebp
  800b0c:	83 ec 08             	sub    $0x8,%esp
	// my_sysenter(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
	// return;
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  800b0f:	6a 00                	push   $0x0
  800b11:	6a 00                	push   $0x0
  800b13:	6a 00                	push   $0x0
  800b15:	ff 75 0c             	pushl  0xc(%ebp)
  800b18:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b1b:	ba 00 00 00 00       	mov    $0x0,%edx
  800b20:	b8 00 00 00 00       	mov    $0x0,%eax
  800b25:	e8 92 ff ff ff       	call   800abc <syscall>
  800b2a:	83 c4 10             	add    $0x10,%esp
	return;
}
  800b2d:	c9                   	leave  
  800b2e:	c3                   	ret    

00800b2f <sys_cgetc>:

int
sys_cgetc(void)
{
  800b2f:	55                   	push   %ebp
  800b30:	89 e5                	mov    %esp,%ebp
  800b32:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_cgetc, 0, 0, 0, 0, 0, 0);
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  800b35:	6a 00                	push   $0x0
  800b37:	6a 00                	push   $0x0
  800b39:	6a 00                	push   $0x0
  800b3b:	6a 00                	push   $0x0
  800b3d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b42:	ba 00 00 00 00       	mov    $0x0,%edx
  800b47:	b8 01 00 00 00       	mov    $0x1,%eax
  800b4c:	e8 6b ff ff ff       	call   800abc <syscall>
}
  800b51:	c9                   	leave  
  800b52:	c3                   	ret    

00800b53 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b53:	55                   	push   %ebp
  800b54:	89 e5                	mov    %esp,%ebp
  800b56:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  800b59:	6a 00                	push   $0x0
  800b5b:	6a 00                	push   $0x0
  800b5d:	6a 00                	push   $0x0
  800b5f:	6a 00                	push   $0x0
  800b61:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b64:	ba 01 00 00 00       	mov    $0x1,%edx
  800b69:	b8 03 00 00 00       	mov    $0x3,%eax
  800b6e:	e8 49 ff ff ff       	call   800abc <syscall>
}
  800b73:	c9                   	leave  
  800b74:	c3                   	ret    

00800b75 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b75:	55                   	push   %ebp
  800b76:	89 e5                	mov    %esp,%ebp
  800b78:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_getenvid, 0, 0, 0, 0, 0, 0);
	return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  800b7b:	6a 00                	push   $0x0
  800b7d:	6a 00                	push   $0x0
  800b7f:	6a 00                	push   $0x0
  800b81:	6a 00                	push   $0x0
  800b83:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b88:	ba 00 00 00 00       	mov    $0x0,%edx
  800b8d:	b8 02 00 00 00       	mov    $0x2,%eax
  800b92:	e8 25 ff ff ff       	call   800abc <syscall>
}
  800b97:	c9                   	leave  
  800b98:	c3                   	ret    

00800b99 <sys_yield>:

void
sys_yield(void)
{
  800b99:	55                   	push   %ebp
  800b9a:	89 e5                	mov    %esp,%ebp
  800b9c:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  800b9f:	6a 00                	push   $0x0
  800ba1:	6a 00                	push   $0x0
  800ba3:	6a 00                	push   $0x0
  800ba5:	6a 00                	push   $0x0
  800ba7:	b9 00 00 00 00       	mov    $0x0,%ecx
  800bac:	ba 00 00 00 00       	mov    $0x0,%edx
  800bb1:	b8 0a 00 00 00       	mov    $0xa,%eax
  800bb6:	e8 01 ff ff ff       	call   800abc <syscall>
  800bbb:	83 c4 10             	add    $0x10,%esp
}
  800bbe:	c9                   	leave  
  800bbf:	c3                   	ret    

00800bc0 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800bc0:	55                   	push   %ebp
  800bc1:	89 e5                	mov    %esp,%ebp
  800bc3:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  800bc6:	6a 00                	push   $0x0
  800bc8:	6a 00                	push   $0x0
  800bca:	ff 75 10             	pushl  0x10(%ebp)
  800bcd:	ff 75 0c             	pushl  0xc(%ebp)
  800bd0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800bd3:	ba 01 00 00 00       	mov    $0x1,%edx
  800bd8:	b8 04 00 00 00       	mov    $0x4,%eax
  800bdd:	e8 da fe ff ff       	call   800abc <syscall>
}
  800be2:	c9                   	leave  
  800be3:	c3                   	ret    

00800be4 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800be4:	55                   	push   %ebp
  800be5:	89 e5                	mov    %esp,%ebp
  800be7:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
  800bea:	ff 75 18             	pushl  0x18(%ebp)
  800bed:	ff 75 14             	pushl  0x14(%ebp)
  800bf0:	ff 75 10             	pushl  0x10(%ebp)
  800bf3:	ff 75 0c             	pushl  0xc(%ebp)
  800bf6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800bf9:	ba 01 00 00 00       	mov    $0x1,%edx
  800bfe:	b8 05 00 00 00       	mov    $0x5,%eax
  800c03:	e8 b4 fe ff ff       	call   800abc <syscall>
}
  800c08:	c9                   	leave  
  800c09:	c3                   	ret    

00800c0a <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c0a:	55                   	push   %ebp
  800c0b:	89 e5                	mov    %esp,%ebp
  800c0d:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  800c10:	6a 00                	push   $0x0
  800c12:	6a 00                	push   $0x0
  800c14:	6a 00                	push   $0x0
  800c16:	ff 75 0c             	pushl  0xc(%ebp)
  800c19:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c1c:	ba 01 00 00 00       	mov    $0x1,%edx
  800c21:	b8 06 00 00 00       	mov    $0x6,%eax
  800c26:	e8 91 fe ff ff       	call   800abc <syscall>
}
  800c2b:	c9                   	leave  
  800c2c:	c3                   	ret    

00800c2d <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c2d:	55                   	push   %ebp
  800c2e:	89 e5                	mov    %esp,%ebp
  800c30:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  800c33:	6a 00                	push   $0x0
  800c35:	6a 00                	push   $0x0
  800c37:	6a 00                	push   $0x0
  800c39:	ff 75 0c             	pushl  0xc(%ebp)
  800c3c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c3f:	ba 01 00 00 00       	mov    $0x1,%edx
  800c44:	b8 08 00 00 00       	mov    $0x8,%eax
  800c49:	e8 6e fe ff ff       	call   800abc <syscall>
}
  800c4e:	c9                   	leave  
  800c4f:	c3                   	ret    

00800c50 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800c50:	55                   	push   %ebp
  800c51:	89 e5                	mov    %esp,%ebp
  800c53:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  800c56:	6a 00                	push   $0x0
  800c58:	6a 00                	push   $0x0
  800c5a:	6a 00                	push   $0x0
  800c5c:	ff 75 0c             	pushl  0xc(%ebp)
  800c5f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c62:	ba 01 00 00 00       	mov    $0x1,%edx
  800c67:	b8 09 00 00 00       	mov    $0x9,%eax
  800c6c:	e8 4b fe ff ff       	call   800abc <syscall>
}
  800c71:	c9                   	leave  
  800c72:	c3                   	ret    

00800c73 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800c73:	55                   	push   %ebp
  800c74:	89 e5                	mov    %esp,%ebp
  800c76:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  800c79:	6a 00                	push   $0x0
  800c7b:	ff 75 14             	pushl  0x14(%ebp)
  800c7e:	ff 75 10             	pushl  0x10(%ebp)
  800c81:	ff 75 0c             	pushl  0xc(%ebp)
  800c84:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c87:	ba 00 00 00 00       	mov    $0x0,%edx
  800c8c:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c91:	e8 26 fe ff ff       	call   800abc <syscall>
}
  800c96:	c9                   	leave  
  800c97:	c3                   	ret    

00800c98 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800c98:	55                   	push   %ebp
  800c99:	89 e5                	mov    %esp,%ebp
  800c9b:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  800c9e:	6a 00                	push   $0x0
  800ca0:	6a 00                	push   $0x0
  800ca2:	6a 00                	push   $0x0
  800ca4:	6a 00                	push   $0x0
  800ca6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ca9:	ba 01 00 00 00       	mov    $0x1,%edx
  800cae:	b8 0c 00 00 00       	mov    $0xc,%eax
  800cb3:	e8 04 fe ff ff       	call   800abc <syscall>
}
  800cb8:	c9                   	leave  
  800cb9:	c3                   	ret    

00800cba <sys_set_priority>:

int
sys_set_priority(envid_t envid, uint32_t new_priority)
{
  800cba:	55                   	push   %ebp
  800cbb:	89 e5                	mov    %esp,%ebp
  800cbd:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_set_priority, 0, envid, new_priority, 0, 0, 0);
  800cc0:	6a 00                	push   $0x0
  800cc2:	6a 00                	push   $0x0
  800cc4:	6a 00                	push   $0x0
  800cc6:	ff 75 0c             	pushl  0xc(%ebp)
  800cc9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ccc:	ba 00 00 00 00       	mov    $0x0,%edx
  800cd1:	b8 0d 00 00 00       	mov    $0xd,%eax
  800cd6:	e8 e1 fd ff ff       	call   800abc <syscall>
}
  800cdb:	c9                   	leave  
  800cdc:	c3                   	ret    
  800cdd:	00 00                	add    %al,(%eax)
	...

00800ce0 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800ce0:	55                   	push   %ebp
  800ce1:	89 e5                	mov    %esp,%ebp
  800ce3:	56                   	push   %esi
  800ce4:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800ce5:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800ce8:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  800cee:	e8 82 fe ff ff       	call   800b75 <sys_getenvid>
  800cf3:	83 ec 0c             	sub    $0xc,%esp
  800cf6:	ff 75 0c             	pushl  0xc(%ebp)
  800cf9:	ff 75 08             	pushl  0x8(%ebp)
  800cfc:	53                   	push   %ebx
  800cfd:	50                   	push   %eax
  800cfe:	68 70 12 80 00       	push   $0x801270
  800d03:	e8 80 f4 ff ff       	call   800188 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800d08:	83 c4 18             	add    $0x18,%esp
  800d0b:	56                   	push   %esi
  800d0c:	ff 75 10             	pushl  0x10(%ebp)
  800d0f:	e8 23 f4 ff ff       	call   800137 <vcprintf>
	cprintf("\n");
  800d14:	c7 04 24 94 12 80 00 	movl   $0x801294,(%esp)
  800d1b:	e8 68 f4 ff ff       	call   800188 <cprintf>
  800d20:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800d23:	cc                   	int3   
  800d24:	eb fd                	jmp    800d23 <_panic+0x43>
	...

00800d28 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  800d28:	55                   	push   %ebp
  800d29:	89 e5                	mov    %esp,%ebp
  800d2b:	57                   	push   %edi
  800d2c:	56                   	push   %esi
  800d2d:	83 ec 10             	sub    $0x10,%esp
  800d30:	8b 7d 08             	mov    0x8(%ebp),%edi
  800d33:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  800d36:	89 7d f0             	mov    %edi,-0x10(%ebp)
  800d39:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  800d3c:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  800d3f:	8b 45 14             	mov    0x14(%ebp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800d42:	85 c0                	test   %eax,%eax
  800d44:	75 2e                	jne    800d74 <__udivdi3+0x4c>
    {
      if (d0 > n1)
  800d46:	39 f1                	cmp    %esi,%ecx
  800d48:	77 5a                	ja     800da4 <__udivdi3+0x7c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  800d4a:	85 c9                	test   %ecx,%ecx
  800d4c:	75 0b                	jne    800d59 <__udivdi3+0x31>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  800d4e:	b8 01 00 00 00       	mov    $0x1,%eax
  800d53:	31 d2                	xor    %edx,%edx
  800d55:	f7 f1                	div    %ecx
  800d57:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  800d59:	31 d2                	xor    %edx,%edx
  800d5b:	89 f0                	mov    %esi,%eax
  800d5d:	f7 f1                	div    %ecx
  800d5f:	89 c6                	mov    %eax,%esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800d61:	89 f8                	mov    %edi,%eax
  800d63:	f7 f1                	div    %ecx
  800d65:	89 c7                	mov    %eax,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800d67:	89 f8                	mov    %edi,%eax
  800d69:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800d6b:	83 c4 10             	add    $0x10,%esp
  800d6e:	5e                   	pop    %esi
  800d6f:	5f                   	pop    %edi
  800d70:	c9                   	leave  
  800d71:	c3                   	ret    
  800d72:	66 90                	xchg   %ax,%ax
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800d74:	39 f0                	cmp    %esi,%eax
  800d76:	77 1c                	ja     800d94 <__udivdi3+0x6c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  800d78:	0f bd f8             	bsr    %eax,%edi
	  if (bm == 0)
  800d7b:	83 f7 1f             	xor    $0x1f,%edi
  800d7e:	75 3c                	jne    800dbc <__udivdi3+0x94>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800d80:	39 f0                	cmp    %esi,%eax
  800d82:	0f 82 90 00 00 00    	jb     800e18 <__udivdi3+0xf0>
  800d88:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800d8b:	39 55 f4             	cmp    %edx,-0xc(%ebp)
  800d8e:	0f 86 84 00 00 00    	jbe    800e18 <__udivdi3+0xf0>
  800d94:	31 f6                	xor    %esi,%esi
  800d96:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800d98:	89 f8                	mov    %edi,%eax
  800d9a:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800d9c:	83 c4 10             	add    $0x10,%esp
  800d9f:	5e                   	pop    %esi
  800da0:	5f                   	pop    %edi
  800da1:	c9                   	leave  
  800da2:	c3                   	ret    
  800da3:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800da4:	89 f2                	mov    %esi,%edx
  800da6:	89 f8                	mov    %edi,%eax
  800da8:	f7 f1                	div    %ecx
  800daa:	89 c7                	mov    %eax,%edi
  800dac:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800dae:	89 f8                	mov    %edi,%eax
  800db0:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800db2:	83 c4 10             	add    $0x10,%esp
  800db5:	5e                   	pop    %esi
  800db6:	5f                   	pop    %edi
  800db7:	c9                   	leave  
  800db8:	c3                   	ret    
  800db9:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  800dbc:	89 f9                	mov    %edi,%ecx
  800dbe:	d3 e0                	shl    %cl,%eax
  800dc0:	89 45 e8             	mov    %eax,-0x18(%ebp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  800dc3:	b8 20 00 00 00       	mov    $0x20,%eax
  800dc8:	29 f8                	sub    %edi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  800dca:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800dcd:	88 c1                	mov    %al,%cl
  800dcf:	d3 ea                	shr    %cl,%edx
  800dd1:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  800dd4:	09 ca                	or     %ecx,%edx
  800dd6:	89 55 ec             	mov    %edx,-0x14(%ebp)
	      d0 = d0 << bm;
  800dd9:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800ddc:	89 f9                	mov    %edi,%ecx
  800dde:	d3 e2                	shl    %cl,%edx
  800de0:	89 55 f4             	mov    %edx,-0xc(%ebp)
	      n2 = n1 >> b;
  800de3:	89 f2                	mov    %esi,%edx
  800de5:	88 c1                	mov    %al,%cl
  800de7:	d3 ea                	shr    %cl,%edx
  800de9:	89 55 e8             	mov    %edx,-0x18(%ebp)
	      n1 = (n1 << bm) | (n0 >> b);
  800dec:	89 f2                	mov    %esi,%edx
  800dee:	89 f9                	mov    %edi,%ecx
  800df0:	d3 e2                	shl    %cl,%edx
  800df2:	8b 75 f0             	mov    -0x10(%ebp),%esi
  800df5:	88 c1                	mov    %al,%cl
  800df7:	d3 ee                	shr    %cl,%esi
  800df9:	09 d6                	or     %edx,%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  800dfb:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  800dfe:	89 f0                	mov    %esi,%eax
  800e00:	89 ca                	mov    %ecx,%edx
  800e02:	f7 75 ec             	divl   -0x14(%ebp)
  800e05:	89 d1                	mov    %edx,%ecx
  800e07:	89 c6                	mov    %eax,%esi
	      umul_ppmm (m1, m0, q0, d0);
  800e09:	f7 65 f4             	mull   -0xc(%ebp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800e0c:	39 d1                	cmp    %edx,%ecx
  800e0e:	72 28                	jb     800e38 <__udivdi3+0x110>
  800e10:	74 1a                	je     800e2c <__udivdi3+0x104>
  800e12:	89 f7                	mov    %esi,%edi
  800e14:	31 f6                	xor    %esi,%esi
  800e16:	eb 80                	jmp    800d98 <__udivdi3+0x70>
	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  800e18:	31 f6                	xor    %esi,%esi
  800e1a:	bf 01 00 00 00       	mov    $0x1,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800e1f:	89 f8                	mov    %edi,%eax
  800e21:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800e23:	83 c4 10             	add    $0x10,%esp
  800e26:	5e                   	pop    %esi
  800e27:	5f                   	pop    %edi
  800e28:	c9                   	leave  
  800e29:	c3                   	ret    
  800e2a:	66 90                	xchg   %ax,%ax

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  800e2c:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800e2f:	89 f9                	mov    %edi,%ecx
  800e31:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800e33:	39 c2                	cmp    %eax,%edx
  800e35:	73 db                	jae    800e12 <__udivdi3+0xea>
  800e37:	90                   	nop
		{
		  q0--;
  800e38:	8d 7e ff             	lea    -0x1(%esi),%edi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  800e3b:	31 f6                	xor    %esi,%esi
  800e3d:	e9 56 ff ff ff       	jmp    800d98 <__udivdi3+0x70>
	...

00800e44 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  800e44:	55                   	push   %ebp
  800e45:	89 e5                	mov    %esp,%ebp
  800e47:	57                   	push   %edi
  800e48:	56                   	push   %esi
  800e49:	83 ec 20             	sub    $0x20,%esp
  800e4c:	8b 45 08             	mov    0x8(%ebp),%eax
  800e4f:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  800e52:	89 45 e8             	mov    %eax,-0x18(%ebp)
  800e55:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  800e58:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  800e5b:	8b 7d 14             	mov    0x14(%ebp),%edi
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  800e5e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  n1 = nn.s.high;
  800e61:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800e63:	85 ff                	test   %edi,%edi
  800e65:	75 15                	jne    800e7c <__umoddi3+0x38>
    {
      if (d0 > n1)
  800e67:	39 f1                	cmp    %esi,%ecx
  800e69:	0f 86 99 00 00 00    	jbe    800f08 <__umoddi3+0xc4>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800e6f:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  800e71:	89 d0                	mov    %edx,%eax
  800e73:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800e75:	83 c4 20             	add    $0x20,%esp
  800e78:	5e                   	pop    %esi
  800e79:	5f                   	pop    %edi
  800e7a:	c9                   	leave  
  800e7b:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800e7c:	39 f7                	cmp    %esi,%edi
  800e7e:	0f 87 a4 00 00 00    	ja     800f28 <__umoddi3+0xe4>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  800e84:	0f bd c7             	bsr    %edi,%eax
	  if (bm == 0)
  800e87:	83 f0 1f             	xor    $0x1f,%eax
  800e8a:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800e8d:	0f 84 a1 00 00 00    	je     800f34 <__umoddi3+0xf0>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  800e93:	89 f8                	mov    %edi,%eax
  800e95:	8a 4d ec             	mov    -0x14(%ebp),%cl
  800e98:	d3 e0                	shl    %cl,%eax
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  800e9a:	bf 20 00 00 00       	mov    $0x20,%edi
  800e9f:	2b 7d ec             	sub    -0x14(%ebp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  800ea2:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800ea5:	89 f9                	mov    %edi,%ecx
  800ea7:	d3 ea                	shr    %cl,%edx
  800ea9:	09 c2                	or     %eax,%edx
  800eab:	89 55 f0             	mov    %edx,-0x10(%ebp)
	      d0 = d0 << bm;
  800eae:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800eb1:	8a 4d ec             	mov    -0x14(%ebp),%cl
  800eb4:	d3 e0                	shl    %cl,%eax
  800eb6:	89 45 f4             	mov    %eax,-0xc(%ebp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  800eb9:	89 f2                	mov    %esi,%edx
  800ebb:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  800ebd:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800ec0:	d3 e0                	shl    %cl,%eax
  800ec2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  800ec5:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800ec8:	89 f9                	mov    %edi,%ecx
  800eca:	d3 e8                	shr    %cl,%eax
  800ecc:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  800ece:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  800ed0:	89 f2                	mov    %esi,%edx
  800ed2:	f7 75 f0             	divl   -0x10(%ebp)
  800ed5:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  800ed7:	f7 65 f4             	mull   -0xc(%ebp)
  800eda:	89 55 e8             	mov    %edx,-0x18(%ebp)
  800edd:	89 c1                	mov    %eax,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800edf:	39 d6                	cmp    %edx,%esi
  800ee1:	72 71                	jb     800f54 <__umoddi3+0x110>
  800ee3:	74 7f                	je     800f64 <__umoddi3+0x120>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  800ee5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800ee8:	29 c8                	sub    %ecx,%eax
  800eea:	19 d6                	sbb    %edx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  800eec:	8a 4d ec             	mov    -0x14(%ebp),%cl
  800eef:	d3 e8                	shr    %cl,%eax
  800ef1:	89 f2                	mov    %esi,%edx
  800ef3:	89 f9                	mov    %edi,%ecx
  800ef5:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  800ef7:	09 d0                	or     %edx,%eax
  800ef9:	89 f2                	mov    %esi,%edx
  800efb:	8a 4d ec             	mov    -0x14(%ebp),%cl
  800efe:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800f00:	83 c4 20             	add    $0x20,%esp
  800f03:	5e                   	pop    %esi
  800f04:	5f                   	pop    %edi
  800f05:	c9                   	leave  
  800f06:	c3                   	ret    
  800f07:	90                   	nop
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  800f08:	85 c9                	test   %ecx,%ecx
  800f0a:	75 0b                	jne    800f17 <__umoddi3+0xd3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  800f0c:	b8 01 00 00 00       	mov    $0x1,%eax
  800f11:	31 d2                	xor    %edx,%edx
  800f13:	f7 f1                	div    %ecx
  800f15:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  800f17:	89 f0                	mov    %esi,%eax
  800f19:	31 d2                	xor    %edx,%edx
  800f1b:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800f1d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800f20:	f7 f1                	div    %ecx
  800f22:	e9 4a ff ff ff       	jmp    800e71 <__umoddi3+0x2d>
  800f27:	90                   	nop
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  800f28:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800f2a:	83 c4 20             	add    $0x20,%esp
  800f2d:	5e                   	pop    %esi
  800f2e:	5f                   	pop    %edi
  800f2f:	c9                   	leave  
  800f30:	c3                   	ret    
  800f31:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800f34:	39 f7                	cmp    %esi,%edi
  800f36:	72 05                	jb     800f3d <__umoddi3+0xf9>
  800f38:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
  800f3b:	77 0c                	ja     800f49 <__umoddi3+0x105>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  800f3d:	89 f2                	mov    %esi,%edx
  800f3f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800f42:	29 c8                	sub    %ecx,%eax
  800f44:	19 fa                	sbb    %edi,%edx
  800f46:	89 45 f0             	mov    %eax,-0x10(%ebp)

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  800f49:	8b 45 f0             	mov    -0x10(%ebp),%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800f4c:	83 c4 20             	add    $0x20,%esp
  800f4f:	5e                   	pop    %esi
  800f50:	5f                   	pop    %edi
  800f51:	c9                   	leave  
  800f52:	c3                   	ret    
  800f53:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  800f54:	8b 55 e8             	mov    -0x18(%ebp),%edx
  800f57:	89 c1                	mov    %eax,%ecx
  800f59:	2b 4d f4             	sub    -0xc(%ebp),%ecx
  800f5c:	1b 55 f0             	sbb    -0x10(%ebp),%edx
  800f5f:	eb 84                	jmp    800ee5 <__umoddi3+0xa1>
  800f61:	8d 76 00             	lea    0x0(%esi),%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800f64:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  800f67:	72 eb                	jb     800f54 <__umoddi3+0x110>
  800f69:	89 f2                	mov    %esi,%edx
  800f6b:	e9 75 ff ff ff       	jmp    800ee5 <__umoddi3+0xa1>
