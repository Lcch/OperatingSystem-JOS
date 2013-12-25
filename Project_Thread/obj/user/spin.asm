
obj/user/spin.debug:     file format elf32-i386


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
  80002c:	e8 87 00 00 00       	call   8000b8 <libmain>
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
  800038:	83 ec 10             	sub    $0x10,%esp
	envid_t env;

	cprintf("I am the parent.  Forking the child...\n");
  80003b:	68 e0 21 80 00       	push   $0x8021e0
  800040:	e8 6b 01 00 00       	call   8001b0 <cprintf>
	if ((env = fork()) == 0) {
  800045:	e8 1c 0e 00 00       	call   800e66 <fork>
  80004a:	89 c3                	mov    %eax,%ebx
  80004c:	83 c4 10             	add    $0x10,%esp
  80004f:	85 c0                	test   %eax,%eax
  800051:	75 12                	jne    800065 <umain+0x31>
		cprintf("I am the child.  Spinning...\n");
  800053:	83 ec 0c             	sub    $0xc,%esp
  800056:	68 58 22 80 00       	push   $0x802258
  80005b:	e8 50 01 00 00       	call   8001b0 <cprintf>
  800060:	83 c4 10             	add    $0x10,%esp
  800063:	eb fe                	jmp    800063 <umain+0x2f>
		while (1)
			/* do nothing */;
	}

	cprintf("I am the parent.  Running the child...\n");
  800065:	83 ec 0c             	sub    $0xc,%esp
  800068:	68 08 22 80 00       	push   $0x802208
  80006d:	e8 3e 01 00 00       	call   8001b0 <cprintf>
	sys_yield();
  800072:	e8 4a 0b 00 00       	call   800bc1 <sys_yield>
	sys_yield();
  800077:	e8 45 0b 00 00       	call   800bc1 <sys_yield>
	sys_yield();
  80007c:	e8 40 0b 00 00       	call   800bc1 <sys_yield>
	sys_yield();
  800081:	e8 3b 0b 00 00       	call   800bc1 <sys_yield>
	sys_yield();
  800086:	e8 36 0b 00 00       	call   800bc1 <sys_yield>
	sys_yield();
  80008b:	e8 31 0b 00 00       	call   800bc1 <sys_yield>
	sys_yield();
  800090:	e8 2c 0b 00 00       	call   800bc1 <sys_yield>
	sys_yield();
  800095:	e8 27 0b 00 00       	call   800bc1 <sys_yield>

	cprintf("I am the parent.  Killing the child...\n");
  80009a:	c7 04 24 30 22 80 00 	movl   $0x802230,(%esp)
  8000a1:	e8 0a 01 00 00       	call   8001b0 <cprintf>
	sys_env_destroy(env);
  8000a6:	89 1c 24             	mov    %ebx,(%esp)
  8000a9:	e8 cd 0a 00 00       	call   800b7b <sys_env_destroy>
  8000ae:	83 c4 10             	add    $0x10,%esp
}
  8000b1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000b4:	c9                   	leave  
  8000b5:	c3                   	ret    
	...

008000b8 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000b8:	55                   	push   %ebp
  8000b9:	89 e5                	mov    %esp,%ebp
  8000bb:	56                   	push   %esi
  8000bc:	53                   	push   %ebx
  8000bd:	8b 75 08             	mov    0x8(%ebp),%esi
  8000c0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs + ENVX(sys_getenvid());
  8000c3:	e8 d5 0a 00 00       	call   800b9d <sys_getenvid>
  8000c8:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000cd:	89 c2                	mov    %eax,%edx
  8000cf:	c1 e2 07             	shl    $0x7,%edx
  8000d2:	8d 84 82 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,4),%eax
  8000d9:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000de:	85 f6                	test   %esi,%esi
  8000e0:	7e 07                	jle    8000e9 <libmain+0x31>
		binaryname = argv[0];
  8000e2:	8b 03                	mov    (%ebx),%eax
  8000e4:	a3 00 30 80 00       	mov    %eax,0x803000
	// call user main routine
	umain(argc, argv);
  8000e9:	83 ec 08             	sub    $0x8,%esp
  8000ec:	53                   	push   %ebx
  8000ed:	56                   	push   %esi
  8000ee:	e8 41 ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  8000f3:	e8 0c 00 00 00       	call   800104 <exit>
  8000f8:	83 c4 10             	add    $0x10,%esp
}
  8000fb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000fe:	5b                   	pop    %ebx
  8000ff:	5e                   	pop    %esi
  800100:	c9                   	leave  
  800101:	c3                   	ret    
	...

00800104 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800104:	55                   	push   %ebp
  800105:	89 e5                	mov    %esp,%ebp
  800107:	83 ec 08             	sub    $0x8,%esp
	close_all();
  80010a:	e8 a7 11 00 00       	call   8012b6 <close_all>
	sys_env_destroy(0);
  80010f:	83 ec 0c             	sub    $0xc,%esp
  800112:	6a 00                	push   $0x0
  800114:	e8 62 0a 00 00       	call   800b7b <sys_env_destroy>
  800119:	83 c4 10             	add    $0x10,%esp
}
  80011c:	c9                   	leave  
  80011d:	c3                   	ret    
	...

00800120 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800120:	55                   	push   %ebp
  800121:	89 e5                	mov    %esp,%ebp
  800123:	53                   	push   %ebx
  800124:	83 ec 04             	sub    $0x4,%esp
  800127:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80012a:	8b 03                	mov    (%ebx),%eax
  80012c:	8b 55 08             	mov    0x8(%ebp),%edx
  80012f:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  800133:	40                   	inc    %eax
  800134:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  800136:	3d ff 00 00 00       	cmp    $0xff,%eax
  80013b:	75 1a                	jne    800157 <putch+0x37>
		sys_cputs(b->buf, b->idx);
  80013d:	83 ec 08             	sub    $0x8,%esp
  800140:	68 ff 00 00 00       	push   $0xff
  800145:	8d 43 08             	lea    0x8(%ebx),%eax
  800148:	50                   	push   %eax
  800149:	e8 e3 09 00 00       	call   800b31 <sys_cputs>
		b->idx = 0;
  80014e:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800154:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800157:	ff 43 04             	incl   0x4(%ebx)
}
  80015a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80015d:	c9                   	leave  
  80015e:	c3                   	ret    

0080015f <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80015f:	55                   	push   %ebp
  800160:	89 e5                	mov    %esp,%ebp
  800162:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800168:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80016f:	00 00 00 
	b.cnt = 0;
  800172:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800179:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80017c:	ff 75 0c             	pushl  0xc(%ebp)
  80017f:	ff 75 08             	pushl  0x8(%ebp)
  800182:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800188:	50                   	push   %eax
  800189:	68 20 01 80 00       	push   $0x800120
  80018e:	e8 82 01 00 00       	call   800315 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800193:	83 c4 08             	add    $0x8,%esp
  800196:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80019c:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001a2:	50                   	push   %eax
  8001a3:	e8 89 09 00 00       	call   800b31 <sys_cputs>

	return b.cnt;
}
  8001a8:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001ae:	c9                   	leave  
  8001af:	c3                   	ret    

008001b0 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001b0:	55                   	push   %ebp
  8001b1:	89 e5                	mov    %esp,%ebp
  8001b3:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001b6:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001b9:	50                   	push   %eax
  8001ba:	ff 75 08             	pushl  0x8(%ebp)
  8001bd:	e8 9d ff ff ff       	call   80015f <vcprintf>
	va_end(ap);

	return cnt;
}
  8001c2:	c9                   	leave  
  8001c3:	c3                   	ret    

008001c4 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001c4:	55                   	push   %ebp
  8001c5:	89 e5                	mov    %esp,%ebp
  8001c7:	57                   	push   %edi
  8001c8:	56                   	push   %esi
  8001c9:	53                   	push   %ebx
  8001ca:	83 ec 2c             	sub    $0x2c,%esp
  8001cd:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8001d0:	89 d6                	mov    %edx,%esi
  8001d2:	8b 45 08             	mov    0x8(%ebp),%eax
  8001d5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001d8:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001db:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8001de:	8b 45 10             	mov    0x10(%ebp),%eax
  8001e1:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8001e4:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001e7:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8001ea:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  8001f1:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
  8001f4:	72 0c                	jb     800202 <printnum+0x3e>
  8001f6:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  8001f9:	76 07                	jbe    800202 <printnum+0x3e>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8001fb:	4b                   	dec    %ebx
  8001fc:	85 db                	test   %ebx,%ebx
  8001fe:	7f 31                	jg     800231 <printnum+0x6d>
  800200:	eb 3f                	jmp    800241 <printnum+0x7d>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800202:	83 ec 0c             	sub    $0xc,%esp
  800205:	57                   	push   %edi
  800206:	4b                   	dec    %ebx
  800207:	53                   	push   %ebx
  800208:	50                   	push   %eax
  800209:	83 ec 08             	sub    $0x8,%esp
  80020c:	ff 75 d4             	pushl  -0x2c(%ebp)
  80020f:	ff 75 d0             	pushl  -0x30(%ebp)
  800212:	ff 75 dc             	pushl  -0x24(%ebp)
  800215:	ff 75 d8             	pushl  -0x28(%ebp)
  800218:	e8 7b 1d 00 00       	call   801f98 <__udivdi3>
  80021d:	83 c4 18             	add    $0x18,%esp
  800220:	52                   	push   %edx
  800221:	50                   	push   %eax
  800222:	89 f2                	mov    %esi,%edx
  800224:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800227:	e8 98 ff ff ff       	call   8001c4 <printnum>
  80022c:	83 c4 20             	add    $0x20,%esp
  80022f:	eb 10                	jmp    800241 <printnum+0x7d>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800231:	83 ec 08             	sub    $0x8,%esp
  800234:	56                   	push   %esi
  800235:	57                   	push   %edi
  800236:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800239:	4b                   	dec    %ebx
  80023a:	83 c4 10             	add    $0x10,%esp
  80023d:	85 db                	test   %ebx,%ebx
  80023f:	7f f0                	jg     800231 <printnum+0x6d>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800241:	83 ec 08             	sub    $0x8,%esp
  800244:	56                   	push   %esi
  800245:	83 ec 04             	sub    $0x4,%esp
  800248:	ff 75 d4             	pushl  -0x2c(%ebp)
  80024b:	ff 75 d0             	pushl  -0x30(%ebp)
  80024e:	ff 75 dc             	pushl  -0x24(%ebp)
  800251:	ff 75 d8             	pushl  -0x28(%ebp)
  800254:	e8 5b 1e 00 00       	call   8020b4 <__umoddi3>
  800259:	83 c4 14             	add    $0x14,%esp
  80025c:	0f be 80 80 22 80 00 	movsbl 0x802280(%eax),%eax
  800263:	50                   	push   %eax
  800264:	ff 55 e4             	call   *-0x1c(%ebp)
  800267:	83 c4 10             	add    $0x10,%esp
}
  80026a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80026d:	5b                   	pop    %ebx
  80026e:	5e                   	pop    %esi
  80026f:	5f                   	pop    %edi
  800270:	c9                   	leave  
  800271:	c3                   	ret    

00800272 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800272:	55                   	push   %ebp
  800273:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800275:	83 fa 01             	cmp    $0x1,%edx
  800278:	7e 0e                	jle    800288 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80027a:	8b 10                	mov    (%eax),%edx
  80027c:	8d 4a 08             	lea    0x8(%edx),%ecx
  80027f:	89 08                	mov    %ecx,(%eax)
  800281:	8b 02                	mov    (%edx),%eax
  800283:	8b 52 04             	mov    0x4(%edx),%edx
  800286:	eb 22                	jmp    8002aa <getuint+0x38>
	else if (lflag)
  800288:	85 d2                	test   %edx,%edx
  80028a:	74 10                	je     80029c <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80028c:	8b 10                	mov    (%eax),%edx
  80028e:	8d 4a 04             	lea    0x4(%edx),%ecx
  800291:	89 08                	mov    %ecx,(%eax)
  800293:	8b 02                	mov    (%edx),%eax
  800295:	ba 00 00 00 00       	mov    $0x0,%edx
  80029a:	eb 0e                	jmp    8002aa <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80029c:	8b 10                	mov    (%eax),%edx
  80029e:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002a1:	89 08                	mov    %ecx,(%eax)
  8002a3:	8b 02                	mov    (%edx),%eax
  8002a5:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002aa:	c9                   	leave  
  8002ab:	c3                   	ret    

008002ac <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  8002ac:	55                   	push   %ebp
  8002ad:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002af:	83 fa 01             	cmp    $0x1,%edx
  8002b2:	7e 0e                	jle    8002c2 <getint+0x16>
		return va_arg(*ap, long long);
  8002b4:	8b 10                	mov    (%eax),%edx
  8002b6:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002b9:	89 08                	mov    %ecx,(%eax)
  8002bb:	8b 02                	mov    (%edx),%eax
  8002bd:	8b 52 04             	mov    0x4(%edx),%edx
  8002c0:	eb 1a                	jmp    8002dc <getint+0x30>
	else if (lflag)
  8002c2:	85 d2                	test   %edx,%edx
  8002c4:	74 0c                	je     8002d2 <getint+0x26>
		return va_arg(*ap, long);
  8002c6:	8b 10                	mov    (%eax),%edx
  8002c8:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002cb:	89 08                	mov    %ecx,(%eax)
  8002cd:	8b 02                	mov    (%edx),%eax
  8002cf:	99                   	cltd   
  8002d0:	eb 0a                	jmp    8002dc <getint+0x30>
	else
		return va_arg(*ap, int);
  8002d2:	8b 10                	mov    (%eax),%edx
  8002d4:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002d7:	89 08                	mov    %ecx,(%eax)
  8002d9:	8b 02                	mov    (%edx),%eax
  8002db:	99                   	cltd   
}
  8002dc:	c9                   	leave  
  8002dd:	c3                   	ret    

008002de <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002de:	55                   	push   %ebp
  8002df:	89 e5                	mov    %esp,%ebp
  8002e1:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002e4:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  8002e7:	8b 10                	mov    (%eax),%edx
  8002e9:	3b 50 04             	cmp    0x4(%eax),%edx
  8002ec:	73 08                	jae    8002f6 <sprintputch+0x18>
		*b->buf++ = ch;
  8002ee:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8002f1:	88 0a                	mov    %cl,(%edx)
  8002f3:	42                   	inc    %edx
  8002f4:	89 10                	mov    %edx,(%eax)
}
  8002f6:	c9                   	leave  
  8002f7:	c3                   	ret    

008002f8 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8002f8:	55                   	push   %ebp
  8002f9:	89 e5                	mov    %esp,%ebp
  8002fb:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8002fe:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800301:	50                   	push   %eax
  800302:	ff 75 10             	pushl  0x10(%ebp)
  800305:	ff 75 0c             	pushl  0xc(%ebp)
  800308:	ff 75 08             	pushl  0x8(%ebp)
  80030b:	e8 05 00 00 00       	call   800315 <vprintfmt>
	va_end(ap);
  800310:	83 c4 10             	add    $0x10,%esp
}
  800313:	c9                   	leave  
  800314:	c3                   	ret    

00800315 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800315:	55                   	push   %ebp
  800316:	89 e5                	mov    %esp,%ebp
  800318:	57                   	push   %edi
  800319:	56                   	push   %esi
  80031a:	53                   	push   %ebx
  80031b:	83 ec 2c             	sub    $0x2c,%esp
  80031e:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800321:	8b 75 10             	mov    0x10(%ebp),%esi
  800324:	eb 13                	jmp    800339 <vprintfmt+0x24>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800326:	85 c0                	test   %eax,%eax
  800328:	0f 84 6d 03 00 00    	je     80069b <vprintfmt+0x386>
				return;
			putch(ch, putdat);
  80032e:	83 ec 08             	sub    $0x8,%esp
  800331:	57                   	push   %edi
  800332:	50                   	push   %eax
  800333:	ff 55 08             	call   *0x8(%ebp)
  800336:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800339:	0f b6 06             	movzbl (%esi),%eax
  80033c:	46                   	inc    %esi
  80033d:	83 f8 25             	cmp    $0x25,%eax
  800340:	75 e4                	jne    800326 <vprintfmt+0x11>
  800342:	c6 45 dc 20          	movb   $0x20,-0x24(%ebp)
  800346:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  80034d:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  800354:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  80035b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800360:	eb 28                	jmp    80038a <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800362:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800364:	c6 45 dc 2d          	movb   $0x2d,-0x24(%ebp)
  800368:	eb 20                	jmp    80038a <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80036a:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80036c:	c6 45 dc 30          	movb   $0x30,-0x24(%ebp)
  800370:	eb 18                	jmp    80038a <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800372:	89 de                	mov    %ebx,%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800374:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  80037b:	eb 0d                	jmp    80038a <vprintfmt+0x75>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  80037d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800380:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800383:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80038a:	8a 06                	mov    (%esi),%al
  80038c:	0f b6 d0             	movzbl %al,%edx
  80038f:	8d 5e 01             	lea    0x1(%esi),%ebx
  800392:	83 e8 23             	sub    $0x23,%eax
  800395:	3c 55                	cmp    $0x55,%al
  800397:	0f 87 e0 02 00 00    	ja     80067d <vprintfmt+0x368>
  80039d:	0f b6 c0             	movzbl %al,%eax
  8003a0:	ff 24 85 c0 23 80 00 	jmp    *0x8023c0(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003a7:	83 ea 30             	sub    $0x30,%edx
  8003aa:	89 55 d4             	mov    %edx,-0x2c(%ebp)
				ch = *fmt;
  8003ad:	0f be 03             	movsbl (%ebx),%eax
				if (ch < '0' || ch > '9')
  8003b0:	8d 50 d0             	lea    -0x30(%eax),%edx
  8003b3:	83 fa 09             	cmp    $0x9,%edx
  8003b6:	77 44                	ja     8003fc <vprintfmt+0xe7>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003b8:	89 de                	mov    %ebx,%esi
  8003ba:	8b 55 d4             	mov    -0x2c(%ebp),%edx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003bd:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
  8003be:	8d 14 92             	lea    (%edx,%edx,4),%edx
  8003c1:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
  8003c5:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8003c8:	8d 58 d0             	lea    -0x30(%eax),%ebx
  8003cb:	83 fb 09             	cmp    $0x9,%ebx
  8003ce:	76 ed                	jbe    8003bd <vprintfmt+0xa8>
  8003d0:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  8003d3:	eb 29                	jmp    8003fe <vprintfmt+0xe9>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003d5:	8b 45 14             	mov    0x14(%ebp),%eax
  8003d8:	8d 50 04             	lea    0x4(%eax),%edx
  8003db:	89 55 14             	mov    %edx,0x14(%ebp)
  8003de:	8b 00                	mov    (%eax),%eax
  8003e0:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003e3:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8003e5:	eb 17                	jmp    8003fe <vprintfmt+0xe9>

		case '.':
			if (width < 0)
  8003e7:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8003eb:	78 85                	js     800372 <vprintfmt+0x5d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ed:	89 de                	mov    %ebx,%esi
  8003ef:	eb 99                	jmp    80038a <vprintfmt+0x75>
  8003f1:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8003f3:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  8003fa:	eb 8e                	jmp    80038a <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003fc:	89 de                	mov    %ebx,%esi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  8003fe:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800402:	79 86                	jns    80038a <vprintfmt+0x75>
  800404:	e9 74 ff ff ff       	jmp    80037d <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800409:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80040a:	89 de                	mov    %ebx,%esi
  80040c:	e9 79 ff ff ff       	jmp    80038a <vprintfmt+0x75>
  800411:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800414:	8b 45 14             	mov    0x14(%ebp),%eax
  800417:	8d 50 04             	lea    0x4(%eax),%edx
  80041a:	89 55 14             	mov    %edx,0x14(%ebp)
  80041d:	83 ec 08             	sub    $0x8,%esp
  800420:	57                   	push   %edi
  800421:	ff 30                	pushl  (%eax)
  800423:	ff 55 08             	call   *0x8(%ebp)
			break;
  800426:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800429:	8b 75 d8             	mov    -0x28(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80042c:	e9 08 ff ff ff       	jmp    800339 <vprintfmt+0x24>
  800431:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  800434:	8b 45 14             	mov    0x14(%ebp),%eax
  800437:	8d 50 04             	lea    0x4(%eax),%edx
  80043a:	89 55 14             	mov    %edx,0x14(%ebp)
  80043d:	8b 00                	mov    (%eax),%eax
  80043f:	85 c0                	test   %eax,%eax
  800441:	79 02                	jns    800445 <vprintfmt+0x130>
  800443:	f7 d8                	neg    %eax
  800445:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800447:	83 f8 0f             	cmp    $0xf,%eax
  80044a:	7f 0b                	jg     800457 <vprintfmt+0x142>
  80044c:	8b 04 85 20 25 80 00 	mov    0x802520(,%eax,4),%eax
  800453:	85 c0                	test   %eax,%eax
  800455:	75 1a                	jne    800471 <vprintfmt+0x15c>
				printfmt(putch, putdat, "error %d", err);
  800457:	52                   	push   %edx
  800458:	68 98 22 80 00       	push   $0x802298
  80045d:	57                   	push   %edi
  80045e:	ff 75 08             	pushl  0x8(%ebp)
  800461:	e8 92 fe ff ff       	call   8002f8 <printfmt>
  800466:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800469:	8b 75 d8             	mov    -0x28(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80046c:	e9 c8 fe ff ff       	jmp    800339 <vprintfmt+0x24>
			else
				printfmt(putch, putdat, "%s", p);
  800471:	50                   	push   %eax
  800472:	68 d5 27 80 00       	push   $0x8027d5
  800477:	57                   	push   %edi
  800478:	ff 75 08             	pushl  0x8(%ebp)
  80047b:	e8 78 fe ff ff       	call   8002f8 <printfmt>
  800480:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800483:	8b 75 d8             	mov    -0x28(%ebp),%esi
  800486:	e9 ae fe ff ff       	jmp    800339 <vprintfmt+0x24>
  80048b:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  80048e:	89 de                	mov    %ebx,%esi
  800490:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  800493:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800496:	8b 45 14             	mov    0x14(%ebp),%eax
  800499:	8d 50 04             	lea    0x4(%eax),%edx
  80049c:	89 55 14             	mov    %edx,0x14(%ebp)
  80049f:	8b 00                	mov    (%eax),%eax
  8004a1:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8004a4:	85 c0                	test   %eax,%eax
  8004a6:	75 07                	jne    8004af <vprintfmt+0x19a>
				p = "(null)";
  8004a8:	c7 45 d0 91 22 80 00 	movl   $0x802291,-0x30(%ebp)
			if (width > 0 && padc != '-')
  8004af:	85 db                	test   %ebx,%ebx
  8004b1:	7e 42                	jle    8004f5 <vprintfmt+0x1e0>
  8004b3:	80 7d dc 2d          	cmpb   $0x2d,-0x24(%ebp)
  8004b7:	74 3c                	je     8004f5 <vprintfmt+0x1e0>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004b9:	83 ec 08             	sub    $0x8,%esp
  8004bc:	51                   	push   %ecx
  8004bd:	ff 75 d0             	pushl  -0x30(%ebp)
  8004c0:	e8 6f 02 00 00       	call   800734 <strnlen>
  8004c5:	29 c3                	sub    %eax,%ebx
  8004c7:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8004ca:	83 c4 10             	add    $0x10,%esp
  8004cd:	85 db                	test   %ebx,%ebx
  8004cf:	7e 24                	jle    8004f5 <vprintfmt+0x1e0>
					putch(padc, putdat);
  8004d1:	0f be 5d dc          	movsbl -0x24(%ebp),%ebx
  8004d5:	89 75 dc             	mov    %esi,-0x24(%ebp)
  8004d8:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  8004db:	83 ec 08             	sub    $0x8,%esp
  8004de:	57                   	push   %edi
  8004df:	53                   	push   %ebx
  8004e0:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004e3:	4e                   	dec    %esi
  8004e4:	83 c4 10             	add    $0x10,%esp
  8004e7:	85 f6                	test   %esi,%esi
  8004e9:	7f f0                	jg     8004db <vprintfmt+0x1c6>
  8004eb:	8b 75 dc             	mov    -0x24(%ebp),%esi
  8004ee:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004f5:	8b 55 d0             	mov    -0x30(%ebp),%edx
  8004f8:	0f be 02             	movsbl (%edx),%eax
  8004fb:	85 c0                	test   %eax,%eax
  8004fd:	75 47                	jne    800546 <vprintfmt+0x231>
  8004ff:	eb 37                	jmp    800538 <vprintfmt+0x223>
				if (altflag && (ch < ' ' || ch > '~'))
  800501:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800505:	74 16                	je     80051d <vprintfmt+0x208>
  800507:	8d 50 e0             	lea    -0x20(%eax),%edx
  80050a:	83 fa 5e             	cmp    $0x5e,%edx
  80050d:	76 0e                	jbe    80051d <vprintfmt+0x208>
					putch('?', putdat);
  80050f:	83 ec 08             	sub    $0x8,%esp
  800512:	57                   	push   %edi
  800513:	6a 3f                	push   $0x3f
  800515:	ff 55 08             	call   *0x8(%ebp)
  800518:	83 c4 10             	add    $0x10,%esp
  80051b:	eb 0b                	jmp    800528 <vprintfmt+0x213>
				else
					putch(ch, putdat);
  80051d:	83 ec 08             	sub    $0x8,%esp
  800520:	57                   	push   %edi
  800521:	50                   	push   %eax
  800522:	ff 55 08             	call   *0x8(%ebp)
  800525:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800528:	ff 4d e4             	decl   -0x1c(%ebp)
  80052b:	0f be 03             	movsbl (%ebx),%eax
  80052e:	85 c0                	test   %eax,%eax
  800530:	74 03                	je     800535 <vprintfmt+0x220>
  800532:	43                   	inc    %ebx
  800533:	eb 1b                	jmp    800550 <vprintfmt+0x23b>
  800535:	8b 75 dc             	mov    -0x24(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800538:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80053c:	7f 1e                	jg     80055c <vprintfmt+0x247>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80053e:	8b 75 d8             	mov    -0x28(%ebp),%esi
  800541:	e9 f3 fd ff ff       	jmp    800339 <vprintfmt+0x24>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800546:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800549:	43                   	inc    %ebx
  80054a:	89 75 dc             	mov    %esi,-0x24(%ebp)
  80054d:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  800550:	85 f6                	test   %esi,%esi
  800552:	78 ad                	js     800501 <vprintfmt+0x1ec>
  800554:	4e                   	dec    %esi
  800555:	79 aa                	jns    800501 <vprintfmt+0x1ec>
  800557:	8b 75 dc             	mov    -0x24(%ebp),%esi
  80055a:	eb dc                	jmp    800538 <vprintfmt+0x223>
  80055c:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80055f:	83 ec 08             	sub    $0x8,%esp
  800562:	57                   	push   %edi
  800563:	6a 20                	push   $0x20
  800565:	ff 55 08             	call   *0x8(%ebp)
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800568:	4b                   	dec    %ebx
  800569:	83 c4 10             	add    $0x10,%esp
  80056c:	85 db                	test   %ebx,%ebx
  80056e:	7f ef                	jg     80055f <vprintfmt+0x24a>
  800570:	e9 c4 fd ff ff       	jmp    800339 <vprintfmt+0x24>
  800575:	89 5d d8             	mov    %ebx,-0x28(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800578:	89 ca                	mov    %ecx,%edx
  80057a:	8d 45 14             	lea    0x14(%ebp),%eax
  80057d:	e8 2a fd ff ff       	call   8002ac <getint>
  800582:	89 c3                	mov    %eax,%ebx
  800584:	89 d6                	mov    %edx,%esi
			if ((long long) num < 0) {
  800586:	85 d2                	test   %edx,%edx
  800588:	78 0a                	js     800594 <vprintfmt+0x27f>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80058a:	b8 0a 00 00 00       	mov    $0xa,%eax
  80058f:	e9 b0 00 00 00       	jmp    800644 <vprintfmt+0x32f>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  800594:	83 ec 08             	sub    $0x8,%esp
  800597:	57                   	push   %edi
  800598:	6a 2d                	push   $0x2d
  80059a:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  80059d:	f7 db                	neg    %ebx
  80059f:	83 d6 00             	adc    $0x0,%esi
  8005a2:	f7 de                	neg    %esi
  8005a4:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8005a7:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005ac:	e9 93 00 00 00       	jmp    800644 <vprintfmt+0x32f>
  8005b1:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8005b4:	89 ca                	mov    %ecx,%edx
  8005b6:	8d 45 14             	lea    0x14(%ebp),%eax
  8005b9:	e8 b4 fc ff ff       	call   800272 <getuint>
  8005be:	89 c3                	mov    %eax,%ebx
  8005c0:	89 d6                	mov    %edx,%esi
			base = 10;
  8005c2:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  8005c7:	eb 7b                	jmp    800644 <vprintfmt+0x32f>
  8005c9:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
  8005cc:	89 ca                	mov    %ecx,%edx
  8005ce:	8d 45 14             	lea    0x14(%ebp),%eax
  8005d1:	e8 d6 fc ff ff       	call   8002ac <getint>
  8005d6:	89 c3                	mov    %eax,%ebx
  8005d8:	89 d6                	mov    %edx,%esi
            if ((long long) num < 0) {
  8005da:	85 d2                	test   %edx,%edx
  8005dc:	78 07                	js     8005e5 <vprintfmt+0x2d0>
                putch('-', putdat);
                num = -(long long) num;
            }
            base = 8;
  8005de:	b8 08 00 00 00       	mov    $0x8,%eax
  8005e3:	eb 5f                	jmp    800644 <vprintfmt+0x32f>
		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
            if ((long long) num < 0) {
                putch('-', putdat);
  8005e5:	83 ec 08             	sub    $0x8,%esp
  8005e8:	57                   	push   %edi
  8005e9:	6a 2d                	push   $0x2d
  8005eb:	ff 55 08             	call   *0x8(%ebp)
                num = -(long long) num;
  8005ee:	f7 db                	neg    %ebx
  8005f0:	83 d6 00             	adc    $0x0,%esi
  8005f3:	f7 de                	neg    %esi
  8005f5:	83 c4 10             	add    $0x10,%esp
            }
            base = 8;
  8005f8:	b8 08 00 00 00       	mov    $0x8,%eax
  8005fd:	eb 45                	jmp    800644 <vprintfmt+0x32f>
  8005ff:	89 5d d8             	mov    %ebx,-0x28(%ebp)
            goto number;

        // pointer
		case 'p':
			putch('0', putdat);
  800602:	83 ec 08             	sub    $0x8,%esp
  800605:	57                   	push   %edi
  800606:	6a 30                	push   $0x30
  800608:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  80060b:	83 c4 08             	add    $0x8,%esp
  80060e:	57                   	push   %edi
  80060f:	6a 78                	push   $0x78
  800611:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800614:	8b 45 14             	mov    0x14(%ebp),%eax
  800617:	8d 50 04             	lea    0x4(%eax),%edx
  80061a:	89 55 14             	mov    %edx,0x14(%ebp)

        // pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80061d:	8b 18                	mov    (%eax),%ebx
  80061f:	be 00 00 00 00       	mov    $0x0,%esi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800624:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800627:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  80062c:	eb 16                	jmp    800644 <vprintfmt+0x32f>
  80062e:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800631:	89 ca                	mov    %ecx,%edx
  800633:	8d 45 14             	lea    0x14(%ebp),%eax
  800636:	e8 37 fc ff ff       	call   800272 <getuint>
  80063b:	89 c3                	mov    %eax,%ebx
  80063d:	89 d6                	mov    %edx,%esi
			base = 16;
  80063f:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800644:	83 ec 0c             	sub    $0xc,%esp
  800647:	0f be 55 dc          	movsbl -0x24(%ebp),%edx
  80064b:	52                   	push   %edx
  80064c:	ff 75 e4             	pushl  -0x1c(%ebp)
  80064f:	50                   	push   %eax
  800650:	56                   	push   %esi
  800651:	53                   	push   %ebx
  800652:	89 fa                	mov    %edi,%edx
  800654:	8b 45 08             	mov    0x8(%ebp),%eax
  800657:	e8 68 fb ff ff       	call   8001c4 <printnum>
			break;
  80065c:	83 c4 20             	add    $0x20,%esp
  80065f:	8b 75 d8             	mov    -0x28(%ebp),%esi
  800662:	e9 d2 fc ff ff       	jmp    800339 <vprintfmt+0x24>
  800667:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80066a:	83 ec 08             	sub    $0x8,%esp
  80066d:	57                   	push   %edi
  80066e:	52                   	push   %edx
  80066f:	ff 55 08             	call   *0x8(%ebp)
			break;
  800672:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800675:	8b 75 d8             	mov    -0x28(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800678:	e9 bc fc ff ff       	jmp    800339 <vprintfmt+0x24>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80067d:	83 ec 08             	sub    $0x8,%esp
  800680:	57                   	push   %edi
  800681:	6a 25                	push   $0x25
  800683:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800686:	83 c4 10             	add    $0x10,%esp
  800689:	eb 02                	jmp    80068d <vprintfmt+0x378>
  80068b:	89 c6                	mov    %eax,%esi
  80068d:	8d 46 ff             	lea    -0x1(%esi),%eax
  800690:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800694:	75 f5                	jne    80068b <vprintfmt+0x376>
  800696:	e9 9e fc ff ff       	jmp    800339 <vprintfmt+0x24>
				/* do nothing */;
			break;
		}
	}
}
  80069b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80069e:	5b                   	pop    %ebx
  80069f:	5e                   	pop    %esi
  8006a0:	5f                   	pop    %edi
  8006a1:	c9                   	leave  
  8006a2:	c3                   	ret    

008006a3 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006a3:	55                   	push   %ebp
  8006a4:	89 e5                	mov    %esp,%ebp
  8006a6:	83 ec 18             	sub    $0x18,%esp
  8006a9:	8b 45 08             	mov    0x8(%ebp),%eax
  8006ac:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006af:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006b2:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8006b6:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8006b9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8006c0:	85 c0                	test   %eax,%eax
  8006c2:	74 26                	je     8006ea <vsnprintf+0x47>
  8006c4:	85 d2                	test   %edx,%edx
  8006c6:	7e 29                	jle    8006f1 <vsnprintf+0x4e>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8006c8:	ff 75 14             	pushl  0x14(%ebp)
  8006cb:	ff 75 10             	pushl  0x10(%ebp)
  8006ce:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8006d1:	50                   	push   %eax
  8006d2:	68 de 02 80 00       	push   $0x8002de
  8006d7:	e8 39 fc ff ff       	call   800315 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8006dc:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8006df:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8006e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006e5:	83 c4 10             	add    $0x10,%esp
  8006e8:	eb 0c                	jmp    8006f6 <vsnprintf+0x53>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8006ea:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8006ef:	eb 05                	jmp    8006f6 <vsnprintf+0x53>
  8006f1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8006f6:	c9                   	leave  
  8006f7:	c3                   	ret    

008006f8 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8006f8:	55                   	push   %ebp
  8006f9:	89 e5                	mov    %esp,%ebp
  8006fb:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8006fe:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800701:	50                   	push   %eax
  800702:	ff 75 10             	pushl  0x10(%ebp)
  800705:	ff 75 0c             	pushl  0xc(%ebp)
  800708:	ff 75 08             	pushl  0x8(%ebp)
  80070b:	e8 93 ff ff ff       	call   8006a3 <vsnprintf>
	va_end(ap);

	return rc;
}
  800710:	c9                   	leave  
  800711:	c3                   	ret    
	...

00800714 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800714:	55                   	push   %ebp
  800715:	89 e5                	mov    %esp,%ebp
  800717:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80071a:	80 3a 00             	cmpb   $0x0,(%edx)
  80071d:	74 0e                	je     80072d <strlen+0x19>
  80071f:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800724:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800725:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800729:	75 f9                	jne    800724 <strlen+0x10>
  80072b:	eb 05                	jmp    800732 <strlen+0x1e>
  80072d:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800732:	c9                   	leave  
  800733:	c3                   	ret    

00800734 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800734:	55                   	push   %ebp
  800735:	89 e5                	mov    %esp,%ebp
  800737:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80073a:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80073d:	85 d2                	test   %edx,%edx
  80073f:	74 17                	je     800758 <strnlen+0x24>
  800741:	80 39 00             	cmpb   $0x0,(%ecx)
  800744:	74 19                	je     80075f <strnlen+0x2b>
  800746:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  80074b:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80074c:	39 d0                	cmp    %edx,%eax
  80074e:	74 14                	je     800764 <strnlen+0x30>
  800750:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800754:	75 f5                	jne    80074b <strnlen+0x17>
  800756:	eb 0c                	jmp    800764 <strnlen+0x30>
  800758:	b8 00 00 00 00       	mov    $0x0,%eax
  80075d:	eb 05                	jmp    800764 <strnlen+0x30>
  80075f:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800764:	c9                   	leave  
  800765:	c3                   	ret    

00800766 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800766:	55                   	push   %ebp
  800767:	89 e5                	mov    %esp,%ebp
  800769:	53                   	push   %ebx
  80076a:	8b 45 08             	mov    0x8(%ebp),%eax
  80076d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800770:	ba 00 00 00 00       	mov    $0x0,%edx
  800775:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  800778:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  80077b:	42                   	inc    %edx
  80077c:	84 c9                	test   %cl,%cl
  80077e:	75 f5                	jne    800775 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800780:	5b                   	pop    %ebx
  800781:	c9                   	leave  
  800782:	c3                   	ret    

00800783 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800783:	55                   	push   %ebp
  800784:	89 e5                	mov    %esp,%ebp
  800786:	53                   	push   %ebx
  800787:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80078a:	53                   	push   %ebx
  80078b:	e8 84 ff ff ff       	call   800714 <strlen>
  800790:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800793:	ff 75 0c             	pushl  0xc(%ebp)
  800796:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  800799:	50                   	push   %eax
  80079a:	e8 c7 ff ff ff       	call   800766 <strcpy>
	return dst;
}
  80079f:	89 d8                	mov    %ebx,%eax
  8007a1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007a4:	c9                   	leave  
  8007a5:	c3                   	ret    

008007a6 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007a6:	55                   	push   %ebp
  8007a7:	89 e5                	mov    %esp,%ebp
  8007a9:	56                   	push   %esi
  8007aa:	53                   	push   %ebx
  8007ab:	8b 45 08             	mov    0x8(%ebp),%eax
  8007ae:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007b1:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007b4:	85 f6                	test   %esi,%esi
  8007b6:	74 15                	je     8007cd <strncpy+0x27>
  8007b8:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  8007bd:	8a 1a                	mov    (%edx),%bl
  8007bf:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007c2:	80 3a 01             	cmpb   $0x1,(%edx)
  8007c5:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007c8:	41                   	inc    %ecx
  8007c9:	39 ce                	cmp    %ecx,%esi
  8007cb:	77 f0                	ja     8007bd <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8007cd:	5b                   	pop    %ebx
  8007ce:	5e                   	pop    %esi
  8007cf:	c9                   	leave  
  8007d0:	c3                   	ret    

008007d1 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8007d1:	55                   	push   %ebp
  8007d2:	89 e5                	mov    %esp,%ebp
  8007d4:	57                   	push   %edi
  8007d5:	56                   	push   %esi
  8007d6:	53                   	push   %ebx
  8007d7:	8b 7d 08             	mov    0x8(%ebp),%edi
  8007da:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8007dd:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007e0:	85 f6                	test   %esi,%esi
  8007e2:	74 32                	je     800816 <strlcpy+0x45>
		while (--size > 0 && *src != '\0')
  8007e4:	83 fe 01             	cmp    $0x1,%esi
  8007e7:	74 22                	je     80080b <strlcpy+0x3a>
  8007e9:	8a 0b                	mov    (%ebx),%cl
  8007eb:	84 c9                	test   %cl,%cl
  8007ed:	74 20                	je     80080f <strlcpy+0x3e>
  8007ef:	89 f8                	mov    %edi,%eax
  8007f1:	ba 00 00 00 00       	mov    $0x0,%edx
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
  8007f6:	83 ee 02             	sub    $0x2,%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8007f9:	88 08                	mov    %cl,(%eax)
  8007fb:	40                   	inc    %eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8007fc:	39 f2                	cmp    %esi,%edx
  8007fe:	74 11                	je     800811 <strlcpy+0x40>
  800800:	8a 4c 13 01          	mov    0x1(%ebx,%edx,1),%cl
  800804:	42                   	inc    %edx
  800805:	84 c9                	test   %cl,%cl
  800807:	75 f0                	jne    8007f9 <strlcpy+0x28>
  800809:	eb 06                	jmp    800811 <strlcpy+0x40>
  80080b:	89 f8                	mov    %edi,%eax
  80080d:	eb 02                	jmp    800811 <strlcpy+0x40>
  80080f:	89 f8                	mov    %edi,%eax
			*dst++ = *src++;
		*dst = '\0';
  800811:	c6 00 00             	movb   $0x0,(%eax)
  800814:	eb 02                	jmp    800818 <strlcpy+0x47>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800816:	89 f8                	mov    %edi,%eax
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
		*dst = '\0';
	}
	return dst - dst_in;
  800818:	29 f8                	sub    %edi,%eax
}
  80081a:	5b                   	pop    %ebx
  80081b:	5e                   	pop    %esi
  80081c:	5f                   	pop    %edi
  80081d:	c9                   	leave  
  80081e:	c3                   	ret    

0080081f <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80081f:	55                   	push   %ebp
  800820:	89 e5                	mov    %esp,%ebp
  800822:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800825:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800828:	8a 01                	mov    (%ecx),%al
  80082a:	84 c0                	test   %al,%al
  80082c:	74 10                	je     80083e <strcmp+0x1f>
  80082e:	3a 02                	cmp    (%edx),%al
  800830:	75 0c                	jne    80083e <strcmp+0x1f>
		p++, q++;
  800832:	41                   	inc    %ecx
  800833:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800834:	8a 01                	mov    (%ecx),%al
  800836:	84 c0                	test   %al,%al
  800838:	74 04                	je     80083e <strcmp+0x1f>
  80083a:	3a 02                	cmp    (%edx),%al
  80083c:	74 f4                	je     800832 <strcmp+0x13>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80083e:	0f b6 c0             	movzbl %al,%eax
  800841:	0f b6 12             	movzbl (%edx),%edx
  800844:	29 d0                	sub    %edx,%eax
}
  800846:	c9                   	leave  
  800847:	c3                   	ret    

00800848 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800848:	55                   	push   %ebp
  800849:	89 e5                	mov    %esp,%ebp
  80084b:	53                   	push   %ebx
  80084c:	8b 55 08             	mov    0x8(%ebp),%edx
  80084f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800852:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  800855:	85 c0                	test   %eax,%eax
  800857:	74 1b                	je     800874 <strncmp+0x2c>
  800859:	8a 1a                	mov    (%edx),%bl
  80085b:	84 db                	test   %bl,%bl
  80085d:	74 24                	je     800883 <strncmp+0x3b>
  80085f:	3a 19                	cmp    (%ecx),%bl
  800861:	75 20                	jne    800883 <strncmp+0x3b>
  800863:	48                   	dec    %eax
  800864:	74 15                	je     80087b <strncmp+0x33>
		n--, p++, q++;
  800866:	42                   	inc    %edx
  800867:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800868:	8a 1a                	mov    (%edx),%bl
  80086a:	84 db                	test   %bl,%bl
  80086c:	74 15                	je     800883 <strncmp+0x3b>
  80086e:	3a 19                	cmp    (%ecx),%bl
  800870:	74 f1                	je     800863 <strncmp+0x1b>
  800872:	eb 0f                	jmp    800883 <strncmp+0x3b>
		n--, p++, q++;
	if (n == 0)
		return 0;
  800874:	b8 00 00 00 00       	mov    $0x0,%eax
  800879:	eb 05                	jmp    800880 <strncmp+0x38>
  80087b:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800880:	5b                   	pop    %ebx
  800881:	c9                   	leave  
  800882:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800883:	0f b6 02             	movzbl (%edx),%eax
  800886:	0f b6 11             	movzbl (%ecx),%edx
  800889:	29 d0                	sub    %edx,%eax
  80088b:	eb f3                	jmp    800880 <strncmp+0x38>

0080088d <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80088d:	55                   	push   %ebp
  80088e:	89 e5                	mov    %esp,%ebp
  800890:	8b 45 08             	mov    0x8(%ebp),%eax
  800893:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800896:	8a 10                	mov    (%eax),%dl
  800898:	84 d2                	test   %dl,%dl
  80089a:	74 18                	je     8008b4 <strchr+0x27>
		if (*s == c)
  80089c:	38 ca                	cmp    %cl,%dl
  80089e:	75 06                	jne    8008a6 <strchr+0x19>
  8008a0:	eb 17                	jmp    8008b9 <strchr+0x2c>
  8008a2:	38 ca                	cmp    %cl,%dl
  8008a4:	74 13                	je     8008b9 <strchr+0x2c>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8008a6:	40                   	inc    %eax
  8008a7:	8a 10                	mov    (%eax),%dl
  8008a9:	84 d2                	test   %dl,%dl
  8008ab:	75 f5                	jne    8008a2 <strchr+0x15>
		if (*s == c)
			return (char *) s;
	return 0;
  8008ad:	b8 00 00 00 00       	mov    $0x0,%eax
  8008b2:	eb 05                	jmp    8008b9 <strchr+0x2c>
  8008b4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008b9:	c9                   	leave  
  8008ba:	c3                   	ret    

008008bb <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008bb:	55                   	push   %ebp
  8008bc:	89 e5                	mov    %esp,%ebp
  8008be:	8b 45 08             	mov    0x8(%ebp),%eax
  8008c1:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8008c4:	8a 10                	mov    (%eax),%dl
  8008c6:	84 d2                	test   %dl,%dl
  8008c8:	74 11                	je     8008db <strfind+0x20>
		if (*s == c)
  8008ca:	38 ca                	cmp    %cl,%dl
  8008cc:	75 06                	jne    8008d4 <strfind+0x19>
  8008ce:	eb 0b                	jmp    8008db <strfind+0x20>
  8008d0:	38 ca                	cmp    %cl,%dl
  8008d2:	74 07                	je     8008db <strfind+0x20>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  8008d4:	40                   	inc    %eax
  8008d5:	8a 10                	mov    (%eax),%dl
  8008d7:	84 d2                	test   %dl,%dl
  8008d9:	75 f5                	jne    8008d0 <strfind+0x15>
		if (*s == c)
			break;
	return (char *) s;
}
  8008db:	c9                   	leave  
  8008dc:	c3                   	ret    

008008dd <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008dd:	55                   	push   %ebp
  8008de:	89 e5                	mov    %esp,%ebp
  8008e0:	57                   	push   %edi
  8008e1:	56                   	push   %esi
  8008e2:	53                   	push   %ebx
  8008e3:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008e6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008e9:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8008ec:	85 c9                	test   %ecx,%ecx
  8008ee:	74 30                	je     800920 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008f0:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008f6:	75 25                	jne    80091d <memset+0x40>
  8008f8:	f6 c1 03             	test   $0x3,%cl
  8008fb:	75 20                	jne    80091d <memset+0x40>
		c &= 0xFF;
  8008fd:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800900:	89 d3                	mov    %edx,%ebx
  800902:	c1 e3 08             	shl    $0x8,%ebx
  800905:	89 d6                	mov    %edx,%esi
  800907:	c1 e6 18             	shl    $0x18,%esi
  80090a:	89 d0                	mov    %edx,%eax
  80090c:	c1 e0 10             	shl    $0x10,%eax
  80090f:	09 f0                	or     %esi,%eax
  800911:	09 d0                	or     %edx,%eax
  800913:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800915:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800918:	fc                   	cld    
  800919:	f3 ab                	rep stos %eax,%es:(%edi)
  80091b:	eb 03                	jmp    800920 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80091d:	fc                   	cld    
  80091e:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800920:	89 f8                	mov    %edi,%eax
  800922:	5b                   	pop    %ebx
  800923:	5e                   	pop    %esi
  800924:	5f                   	pop    %edi
  800925:	c9                   	leave  
  800926:	c3                   	ret    

00800927 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800927:	55                   	push   %ebp
  800928:	89 e5                	mov    %esp,%ebp
  80092a:	57                   	push   %edi
  80092b:	56                   	push   %esi
  80092c:	8b 45 08             	mov    0x8(%ebp),%eax
  80092f:	8b 75 0c             	mov    0xc(%ebp),%esi
  800932:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800935:	39 c6                	cmp    %eax,%esi
  800937:	73 34                	jae    80096d <memmove+0x46>
  800939:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80093c:	39 d0                	cmp    %edx,%eax
  80093e:	73 2d                	jae    80096d <memmove+0x46>
		s += n;
		d += n;
  800940:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800943:	f6 c2 03             	test   $0x3,%dl
  800946:	75 1b                	jne    800963 <memmove+0x3c>
  800948:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80094e:	75 13                	jne    800963 <memmove+0x3c>
  800950:	f6 c1 03             	test   $0x3,%cl
  800953:	75 0e                	jne    800963 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800955:	83 ef 04             	sub    $0x4,%edi
  800958:	8d 72 fc             	lea    -0x4(%edx),%esi
  80095b:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  80095e:	fd                   	std    
  80095f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800961:	eb 07                	jmp    80096a <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800963:	4f                   	dec    %edi
  800964:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800967:	fd                   	std    
  800968:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80096a:	fc                   	cld    
  80096b:	eb 20                	jmp    80098d <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80096d:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800973:	75 13                	jne    800988 <memmove+0x61>
  800975:	a8 03                	test   $0x3,%al
  800977:	75 0f                	jne    800988 <memmove+0x61>
  800979:	f6 c1 03             	test   $0x3,%cl
  80097c:	75 0a                	jne    800988 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  80097e:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800981:	89 c7                	mov    %eax,%edi
  800983:	fc                   	cld    
  800984:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800986:	eb 05                	jmp    80098d <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800988:	89 c7                	mov    %eax,%edi
  80098a:	fc                   	cld    
  80098b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  80098d:	5e                   	pop    %esi
  80098e:	5f                   	pop    %edi
  80098f:	c9                   	leave  
  800990:	c3                   	ret    

00800991 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800991:	55                   	push   %ebp
  800992:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800994:	ff 75 10             	pushl  0x10(%ebp)
  800997:	ff 75 0c             	pushl  0xc(%ebp)
  80099a:	ff 75 08             	pushl  0x8(%ebp)
  80099d:	e8 85 ff ff ff       	call   800927 <memmove>
}
  8009a2:	c9                   	leave  
  8009a3:	c3                   	ret    

008009a4 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009a4:	55                   	push   %ebp
  8009a5:	89 e5                	mov    %esp,%ebp
  8009a7:	57                   	push   %edi
  8009a8:	56                   	push   %esi
  8009a9:	53                   	push   %ebx
  8009aa:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8009ad:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009b0:	8b 7d 10             	mov    0x10(%ebp),%edi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009b3:	85 ff                	test   %edi,%edi
  8009b5:	74 32                	je     8009e9 <memcmp+0x45>
		if (*s1 != *s2)
  8009b7:	8a 03                	mov    (%ebx),%al
  8009b9:	8a 0e                	mov    (%esi),%cl
  8009bb:	38 c8                	cmp    %cl,%al
  8009bd:	74 19                	je     8009d8 <memcmp+0x34>
  8009bf:	eb 0d                	jmp    8009ce <memcmp+0x2a>
  8009c1:	8a 44 13 01          	mov    0x1(%ebx,%edx,1),%al
  8009c5:	8a 4c 16 01          	mov    0x1(%esi,%edx,1),%cl
  8009c9:	42                   	inc    %edx
  8009ca:	38 c8                	cmp    %cl,%al
  8009cc:	74 10                	je     8009de <memcmp+0x3a>
			return (int) *s1 - (int) *s2;
  8009ce:	0f b6 c0             	movzbl %al,%eax
  8009d1:	0f b6 c9             	movzbl %cl,%ecx
  8009d4:	29 c8                	sub    %ecx,%eax
  8009d6:	eb 16                	jmp    8009ee <memcmp+0x4a>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009d8:	4f                   	dec    %edi
  8009d9:	ba 00 00 00 00       	mov    $0x0,%edx
  8009de:	39 fa                	cmp    %edi,%edx
  8009e0:	75 df                	jne    8009c1 <memcmp+0x1d>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8009e2:	b8 00 00 00 00       	mov    $0x0,%eax
  8009e7:	eb 05                	jmp    8009ee <memcmp+0x4a>
  8009e9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009ee:	5b                   	pop    %ebx
  8009ef:	5e                   	pop    %esi
  8009f0:	5f                   	pop    %edi
  8009f1:	c9                   	leave  
  8009f2:	c3                   	ret    

008009f3 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009f3:	55                   	push   %ebp
  8009f4:	89 e5                	mov    %esp,%ebp
  8009f6:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  8009f9:	89 c2                	mov    %eax,%edx
  8009fb:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  8009fe:	39 d0                	cmp    %edx,%eax
  800a00:	73 12                	jae    800a14 <memfind+0x21>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a02:	8a 4d 0c             	mov    0xc(%ebp),%cl
  800a05:	38 08                	cmp    %cl,(%eax)
  800a07:	75 06                	jne    800a0f <memfind+0x1c>
  800a09:	eb 09                	jmp    800a14 <memfind+0x21>
  800a0b:	38 08                	cmp    %cl,(%eax)
  800a0d:	74 05                	je     800a14 <memfind+0x21>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a0f:	40                   	inc    %eax
  800a10:	39 c2                	cmp    %eax,%edx
  800a12:	77 f7                	ja     800a0b <memfind+0x18>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a14:	c9                   	leave  
  800a15:	c3                   	ret    

00800a16 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a16:	55                   	push   %ebp
  800a17:	89 e5                	mov    %esp,%ebp
  800a19:	57                   	push   %edi
  800a1a:	56                   	push   %esi
  800a1b:	53                   	push   %ebx
  800a1c:	8b 55 08             	mov    0x8(%ebp),%edx
  800a1f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a22:	eb 01                	jmp    800a25 <strtol+0xf>
		s++;
  800a24:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a25:	8a 02                	mov    (%edx),%al
  800a27:	3c 20                	cmp    $0x20,%al
  800a29:	74 f9                	je     800a24 <strtol+0xe>
  800a2b:	3c 09                	cmp    $0x9,%al
  800a2d:	74 f5                	je     800a24 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a2f:	3c 2b                	cmp    $0x2b,%al
  800a31:	75 08                	jne    800a3b <strtol+0x25>
		s++;
  800a33:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a34:	bf 00 00 00 00       	mov    $0x0,%edi
  800a39:	eb 13                	jmp    800a4e <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a3b:	3c 2d                	cmp    $0x2d,%al
  800a3d:	75 0a                	jne    800a49 <strtol+0x33>
		s++, neg = 1;
  800a3f:	8d 52 01             	lea    0x1(%edx),%edx
  800a42:	bf 01 00 00 00       	mov    $0x1,%edi
  800a47:	eb 05                	jmp    800a4e <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a49:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a4e:	85 db                	test   %ebx,%ebx
  800a50:	74 05                	je     800a57 <strtol+0x41>
  800a52:	83 fb 10             	cmp    $0x10,%ebx
  800a55:	75 28                	jne    800a7f <strtol+0x69>
  800a57:	8a 02                	mov    (%edx),%al
  800a59:	3c 30                	cmp    $0x30,%al
  800a5b:	75 10                	jne    800a6d <strtol+0x57>
  800a5d:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800a61:	75 0a                	jne    800a6d <strtol+0x57>
		s += 2, base = 16;
  800a63:	83 c2 02             	add    $0x2,%edx
  800a66:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a6b:	eb 12                	jmp    800a7f <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800a6d:	85 db                	test   %ebx,%ebx
  800a6f:	75 0e                	jne    800a7f <strtol+0x69>
  800a71:	3c 30                	cmp    $0x30,%al
  800a73:	75 05                	jne    800a7a <strtol+0x64>
		s++, base = 8;
  800a75:	42                   	inc    %edx
  800a76:	b3 08                	mov    $0x8,%bl
  800a78:	eb 05                	jmp    800a7f <strtol+0x69>
	else if (base == 0)
		base = 10;
  800a7a:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800a7f:	b8 00 00 00 00       	mov    $0x0,%eax
  800a84:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a86:	8a 0a                	mov    (%edx),%cl
  800a88:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800a8b:	80 fb 09             	cmp    $0x9,%bl
  800a8e:	77 08                	ja     800a98 <strtol+0x82>
			dig = *s - '0';
  800a90:	0f be c9             	movsbl %cl,%ecx
  800a93:	83 e9 30             	sub    $0x30,%ecx
  800a96:	eb 1e                	jmp    800ab6 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800a98:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800a9b:	80 fb 19             	cmp    $0x19,%bl
  800a9e:	77 08                	ja     800aa8 <strtol+0x92>
			dig = *s - 'a' + 10;
  800aa0:	0f be c9             	movsbl %cl,%ecx
  800aa3:	83 e9 57             	sub    $0x57,%ecx
  800aa6:	eb 0e                	jmp    800ab6 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800aa8:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800aab:	80 fb 19             	cmp    $0x19,%bl
  800aae:	77 13                	ja     800ac3 <strtol+0xad>
			dig = *s - 'A' + 10;
  800ab0:	0f be c9             	movsbl %cl,%ecx
  800ab3:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800ab6:	39 f1                	cmp    %esi,%ecx
  800ab8:	7d 0d                	jge    800ac7 <strtol+0xb1>
			break;
		s++, val = (val * base) + dig;
  800aba:	42                   	inc    %edx
  800abb:	0f af c6             	imul   %esi,%eax
  800abe:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  800ac1:	eb c3                	jmp    800a86 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800ac3:	89 c1                	mov    %eax,%ecx
  800ac5:	eb 02                	jmp    800ac9 <strtol+0xb3>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800ac7:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800ac9:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800acd:	74 05                	je     800ad4 <strtol+0xbe>
		*endptr = (char *) s;
  800acf:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800ad2:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800ad4:	85 ff                	test   %edi,%edi
  800ad6:	74 04                	je     800adc <strtol+0xc6>
  800ad8:	89 c8                	mov    %ecx,%eax
  800ada:	f7 d8                	neg    %eax
}
  800adc:	5b                   	pop    %ebx
  800add:	5e                   	pop    %esi
  800ade:	5f                   	pop    %edi
  800adf:	c9                   	leave  
  800ae0:	c3                   	ret    
  800ae1:	00 00                	add    %al,(%eax)
	...

00800ae4 <syscall>:
	return ret;
}

static int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800ae4:	55                   	push   %ebp
  800ae5:	89 e5                	mov    %esp,%ebp
  800ae7:	57                   	push   %edi
  800ae8:	56                   	push   %esi
  800ae9:	53                   	push   %ebx
  800aea:	83 ec 1c             	sub    $0x1c,%esp
  800aed:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800af0:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800af3:	89 ca                	mov    %ecx,%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800af5:	8b 75 14             	mov    0x14(%ebp),%esi
  800af8:	8b 7d 10             	mov    0x10(%ebp),%edi
  800afb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800afe:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b01:	cd 30                	int    $0x30
  800b03:	89 c2                	mov    %eax,%edx
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b05:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800b09:	74 1c                	je     800b27 <syscall+0x43>
  800b0b:	85 c0                	test   %eax,%eax
  800b0d:	7e 18                	jle    800b27 <syscall+0x43>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b0f:	83 ec 0c             	sub    $0xc,%esp
  800b12:	50                   	push   %eax
  800b13:	ff 75 e4             	pushl  -0x1c(%ebp)
  800b16:	68 7f 25 80 00       	push   $0x80257f
  800b1b:	6a 42                	push   $0x42
  800b1d:	68 9c 25 80 00       	push   $0x80259c
  800b22:	e8 39 12 00 00       	call   801d60 <_panic>

	return ret;
}
  800b27:	89 d0                	mov    %edx,%eax
  800b29:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b2c:	5b                   	pop    %ebx
  800b2d:	5e                   	pop    %esi
  800b2e:	5f                   	pop    %edi
  800b2f:	c9                   	leave  
  800b30:	c3                   	ret    

00800b31 <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{	
  800b31:	55                   	push   %ebp
  800b32:	89 e5                	mov    %esp,%ebp
  800b34:	83 ec 08             	sub    $0x8,%esp
	// my_sysenter(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
	// return;
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  800b37:	6a 00                	push   $0x0
  800b39:	6a 00                	push   $0x0
  800b3b:	6a 00                	push   $0x0
  800b3d:	ff 75 0c             	pushl  0xc(%ebp)
  800b40:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b43:	ba 00 00 00 00       	mov    $0x0,%edx
  800b48:	b8 00 00 00 00       	mov    $0x0,%eax
  800b4d:	e8 92 ff ff ff       	call   800ae4 <syscall>
  800b52:	83 c4 10             	add    $0x10,%esp
	return;
}
  800b55:	c9                   	leave  
  800b56:	c3                   	ret    

00800b57 <sys_cgetc>:

int
sys_cgetc(void)
{
  800b57:	55                   	push   %ebp
  800b58:	89 e5                	mov    %esp,%ebp
  800b5a:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_cgetc, 0, 0, 0, 0, 0, 0);
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  800b5d:	6a 00                	push   $0x0
  800b5f:	6a 00                	push   $0x0
  800b61:	6a 00                	push   $0x0
  800b63:	6a 00                	push   $0x0
  800b65:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b6a:	ba 00 00 00 00       	mov    $0x0,%edx
  800b6f:	b8 01 00 00 00       	mov    $0x1,%eax
  800b74:	e8 6b ff ff ff       	call   800ae4 <syscall>
}
  800b79:	c9                   	leave  
  800b7a:	c3                   	ret    

00800b7b <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b7b:	55                   	push   %ebp
  800b7c:	89 e5                	mov    %esp,%ebp
  800b7e:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  800b81:	6a 00                	push   $0x0
  800b83:	6a 00                	push   $0x0
  800b85:	6a 00                	push   $0x0
  800b87:	6a 00                	push   $0x0
  800b89:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b8c:	ba 01 00 00 00       	mov    $0x1,%edx
  800b91:	b8 03 00 00 00       	mov    $0x3,%eax
  800b96:	e8 49 ff ff ff       	call   800ae4 <syscall>
}
  800b9b:	c9                   	leave  
  800b9c:	c3                   	ret    

00800b9d <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b9d:	55                   	push   %ebp
  800b9e:	89 e5                	mov    %esp,%ebp
  800ba0:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_getenvid, 0, 0, 0, 0, 0, 0);
	return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  800ba3:	6a 00                	push   $0x0
  800ba5:	6a 00                	push   $0x0
  800ba7:	6a 00                	push   $0x0
  800ba9:	6a 00                	push   $0x0
  800bab:	b9 00 00 00 00       	mov    $0x0,%ecx
  800bb0:	ba 00 00 00 00       	mov    $0x0,%edx
  800bb5:	b8 02 00 00 00       	mov    $0x2,%eax
  800bba:	e8 25 ff ff ff       	call   800ae4 <syscall>
}
  800bbf:	c9                   	leave  
  800bc0:	c3                   	ret    

00800bc1 <sys_yield>:

void
sys_yield(void)
{
  800bc1:	55                   	push   %ebp
  800bc2:	89 e5                	mov    %esp,%ebp
  800bc4:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  800bc7:	6a 00                	push   $0x0
  800bc9:	6a 00                	push   $0x0
  800bcb:	6a 00                	push   $0x0
  800bcd:	6a 00                	push   $0x0
  800bcf:	b9 00 00 00 00       	mov    $0x0,%ecx
  800bd4:	ba 00 00 00 00       	mov    $0x0,%edx
  800bd9:	b8 0b 00 00 00       	mov    $0xb,%eax
  800bde:	e8 01 ff ff ff       	call   800ae4 <syscall>
  800be3:	83 c4 10             	add    $0x10,%esp
}
  800be6:	c9                   	leave  
  800be7:	c3                   	ret    

00800be8 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800be8:	55                   	push   %ebp
  800be9:	89 e5                	mov    %esp,%ebp
  800beb:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  800bee:	6a 00                	push   $0x0
  800bf0:	6a 00                	push   $0x0
  800bf2:	ff 75 10             	pushl  0x10(%ebp)
  800bf5:	ff 75 0c             	pushl  0xc(%ebp)
  800bf8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800bfb:	ba 01 00 00 00       	mov    $0x1,%edx
  800c00:	b8 04 00 00 00       	mov    $0x4,%eax
  800c05:	e8 da fe ff ff       	call   800ae4 <syscall>
}
  800c0a:	c9                   	leave  
  800c0b:	c3                   	ret    

00800c0c <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c0c:	55                   	push   %ebp
  800c0d:	89 e5                	mov    %esp,%ebp
  800c0f:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
  800c12:	ff 75 18             	pushl  0x18(%ebp)
  800c15:	ff 75 14             	pushl  0x14(%ebp)
  800c18:	ff 75 10             	pushl  0x10(%ebp)
  800c1b:	ff 75 0c             	pushl  0xc(%ebp)
  800c1e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c21:	ba 01 00 00 00       	mov    $0x1,%edx
  800c26:	b8 05 00 00 00       	mov    $0x5,%eax
  800c2b:	e8 b4 fe ff ff       	call   800ae4 <syscall>
}
  800c30:	c9                   	leave  
  800c31:	c3                   	ret    

00800c32 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c32:	55                   	push   %ebp
  800c33:	89 e5                	mov    %esp,%ebp
  800c35:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  800c38:	6a 00                	push   $0x0
  800c3a:	6a 00                	push   $0x0
  800c3c:	6a 00                	push   $0x0
  800c3e:	ff 75 0c             	pushl  0xc(%ebp)
  800c41:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c44:	ba 01 00 00 00       	mov    $0x1,%edx
  800c49:	b8 06 00 00 00       	mov    $0x6,%eax
  800c4e:	e8 91 fe ff ff       	call   800ae4 <syscall>
}
  800c53:	c9                   	leave  
  800c54:	c3                   	ret    

00800c55 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c55:	55                   	push   %ebp
  800c56:	89 e5                	mov    %esp,%ebp
  800c58:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  800c5b:	6a 00                	push   $0x0
  800c5d:	6a 00                	push   $0x0
  800c5f:	6a 00                	push   $0x0
  800c61:	ff 75 0c             	pushl  0xc(%ebp)
  800c64:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c67:	ba 01 00 00 00       	mov    $0x1,%edx
  800c6c:	b8 08 00 00 00       	mov    $0x8,%eax
  800c71:	e8 6e fe ff ff       	call   800ae4 <syscall>
}
  800c76:	c9                   	leave  
  800c77:	c3                   	ret    

00800c78 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800c78:	55                   	push   %ebp
  800c79:	89 e5                	mov    %esp,%ebp
  800c7b:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
  800c7e:	6a 00                	push   $0x0
  800c80:	6a 00                	push   $0x0
  800c82:	6a 00                	push   $0x0
  800c84:	ff 75 0c             	pushl  0xc(%ebp)
  800c87:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c8a:	ba 01 00 00 00       	mov    $0x1,%edx
  800c8f:	b8 09 00 00 00       	mov    $0x9,%eax
  800c94:	e8 4b fe ff ff       	call   800ae4 <syscall>
}
  800c99:	c9                   	leave  
  800c9a:	c3                   	ret    

00800c9b <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800c9b:	55                   	push   %ebp
  800c9c:	89 e5                	mov    %esp,%ebp
  800c9e:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  800ca1:	6a 00                	push   $0x0
  800ca3:	6a 00                	push   $0x0
  800ca5:	6a 00                	push   $0x0
  800ca7:	ff 75 0c             	pushl  0xc(%ebp)
  800caa:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800cad:	ba 01 00 00 00       	mov    $0x1,%edx
  800cb2:	b8 0a 00 00 00       	mov    $0xa,%eax
  800cb7:	e8 28 fe ff ff       	call   800ae4 <syscall>
}
  800cbc:	c9                   	leave  
  800cbd:	c3                   	ret    

00800cbe <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800cbe:	55                   	push   %ebp
  800cbf:	89 e5                	mov    %esp,%ebp
  800cc1:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  800cc4:	6a 00                	push   $0x0
  800cc6:	ff 75 14             	pushl  0x14(%ebp)
  800cc9:	ff 75 10             	pushl  0x10(%ebp)
  800ccc:	ff 75 0c             	pushl  0xc(%ebp)
  800ccf:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800cd2:	ba 00 00 00 00       	mov    $0x0,%edx
  800cd7:	b8 0c 00 00 00       	mov    $0xc,%eax
  800cdc:	e8 03 fe ff ff       	call   800ae4 <syscall>
}
  800ce1:	c9                   	leave  
  800ce2:	c3                   	ret    

00800ce3 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800ce3:	55                   	push   %ebp
  800ce4:	89 e5                	mov    %esp,%ebp
  800ce6:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  800ce9:	6a 00                	push   $0x0
  800ceb:	6a 00                	push   $0x0
  800ced:	6a 00                	push   $0x0
  800cef:	6a 00                	push   $0x0
  800cf1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800cf4:	ba 01 00 00 00       	mov    $0x1,%edx
  800cf9:	b8 0d 00 00 00       	mov    $0xd,%eax
  800cfe:	e8 e1 fd ff ff       	call   800ae4 <syscall>
}
  800d03:	c9                   	leave  
  800d04:	c3                   	ret    

00800d05 <sys_set_priority>:

int
sys_set_priority(envid_t envid, uint32_t new_priority)
{
  800d05:	55                   	push   %ebp
  800d06:	89 e5                	mov    %esp,%ebp
  800d08:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_set_priority, 0, envid, new_priority, 0, 0, 0);
  800d0b:	6a 00                	push   $0x0
  800d0d:	6a 00                	push   $0x0
  800d0f:	6a 00                	push   $0x0
  800d11:	ff 75 0c             	pushl  0xc(%ebp)
  800d14:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d17:	ba 00 00 00 00       	mov    $0x0,%edx
  800d1c:	b8 0e 00 00 00       	mov    $0xe,%eax
  800d21:	e8 be fd ff ff       	call   800ae4 <syscall>
}
  800d26:	c9                   	leave  
  800d27:	c3                   	ret    

00800d28 <sys_exec>:

int
sys_exec(uint32_t eip, uint32_t esp, void * ph, uint32_t elf_phnum)
{
  800d28:	55                   	push   %ebp
  800d29:	89 e5                	mov    %esp,%ebp
  800d2b:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_exec, 0, eip, esp, (uint32_t)ph, elf_phnum, 0);
  800d2e:	6a 00                	push   $0x0
  800d30:	ff 75 14             	pushl  0x14(%ebp)
  800d33:	ff 75 10             	pushl  0x10(%ebp)
  800d36:	ff 75 0c             	pushl  0xc(%ebp)
  800d39:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d3c:	ba 00 00 00 00       	mov    $0x0,%edx
  800d41:	b8 0f 00 00 00       	mov    $0xf,%eax
  800d46:	e8 99 fd ff ff       	call   800ae4 <syscall>
} 
  800d4b:	c9                   	leave  
  800d4c:	c3                   	ret    

00800d4d <sys_join>:

// thread:
int
sys_join(envid_t envid)
{
  800d4d:	55                   	push   %ebp
  800d4e:	89 e5                	mov    %esp,%ebp
  800d50:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_join, 0, envid, 0, 0, 0, 0);
  800d53:	6a 00                	push   $0x0
  800d55:	6a 00                	push   $0x0
  800d57:	6a 00                	push   $0x0
  800d59:	6a 00                	push   $0x0
  800d5b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d5e:	ba 00 00 00 00       	mov    $0x0,%edx
  800d63:	b8 11 00 00 00       	mov    $0x11,%eax
  800d68:	e8 77 fd ff ff       	call   800ae4 <syscall>
}
  800d6d:	c9                   	leave  
  800d6e:	c3                   	ret    

00800d6f <sys_getpid>:

envid_t
sys_getpid(void)
{
  800d6f:	55                   	push   %ebp
  800d70:	89 e5                	mov    %esp,%ebp
  800d72:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_getpid, 0, 0, 0, 0, 0, 0);
  800d75:	6a 00                	push   $0x0
  800d77:	6a 00                	push   $0x0
  800d79:	6a 00                	push   $0x0
  800d7b:	6a 00                	push   $0x0
  800d7d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d82:	ba 00 00 00 00       	mov    $0x0,%edx
  800d87:	b8 10 00 00 00       	mov    $0x10,%eax
  800d8c:	e8 53 fd ff ff       	call   800ae4 <syscall>
  800d91:	c9                   	leave  
  800d92:	c3                   	ret    
	...

00800d94 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800d94:	55                   	push   %ebp
  800d95:	89 e5                	mov    %esp,%ebp
  800d97:	53                   	push   %ebx
  800d98:	83 ec 04             	sub    $0x4,%esp
  800d9b:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800d9e:	8b 18                	mov    (%eax),%ebx

	// LAB 4: Your code here.
	
	// cprintf("PAGE FAULT HANDLER, 0x%08x %d\n", (uint32_t)addr, err & FEC_WR);
	
	if ((err & FEC_WR) == 0)
  800da0:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800da4:	75 14                	jne    800dba <pgfault+0x26>
		panic("pgfault, the fault is not a write\n");
  800da6:	83 ec 04             	sub    $0x4,%esp
  800da9:	68 ac 25 80 00       	push   $0x8025ac
  800dae:	6a 20                	push   $0x20
  800db0:	68 f0 26 80 00       	push   $0x8026f0
  800db5:	e8 a6 0f 00 00       	call   801d60 <_panic>

	uint32_t uaddr = (uint32_t) addr;
	if ((uvpd[PDX(addr)] & PTE_P) == 0 || (uvpt[uaddr / PGSIZE] & PTE_COW) == 0) {
  800dba:	89 d8                	mov    %ebx,%eax
  800dbc:	c1 e8 16             	shr    $0x16,%eax
  800dbf:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800dc6:	a8 01                	test   $0x1,%al
  800dc8:	74 11                	je     800ddb <pgfault+0x47>
  800dca:	89 d8                	mov    %ebx,%eax
  800dcc:	c1 e8 0c             	shr    $0xc,%eax
  800dcf:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800dd6:	f6 c4 08             	test   $0x8,%ah
  800dd9:	75 14                	jne    800def <pgfault+0x5b>
		panic("pgfault, not a copy-on-write page\n");
  800ddb:	83 ec 04             	sub    $0x4,%esp
  800dde:	68 d0 25 80 00       	push   $0x8025d0
  800de3:	6a 24                	push   $0x24
  800de5:	68 f0 26 80 00       	push   $0x8026f0
  800dea:	e8 71 0f 00 00       	call   801d60 <_panic>
	//   No need to explicitly delete the old page's mapping.

	// LAB 4: Your code here.

	// static int sys_page_alloc(envid_t envid, void *va, int perm)
	r = sys_page_alloc(0, (void *)PFTEMP, PTE_W | PTE_U | PTE_P);
  800def:	83 ec 04             	sub    $0x4,%esp
  800df2:	6a 07                	push   $0x7
  800df4:	68 00 f0 7f 00       	push   $0x7ff000
  800df9:	6a 00                	push   $0x0
  800dfb:	e8 e8 fd ff ff       	call   800be8 <sys_page_alloc>
	if (r < 0) panic("pgfault, sys_page_alloc error : %e\n", r);
  800e00:	83 c4 10             	add    $0x10,%esp
  800e03:	85 c0                	test   %eax,%eax
  800e05:	79 12                	jns    800e19 <pgfault+0x85>
  800e07:	50                   	push   %eax
  800e08:	68 f4 25 80 00       	push   $0x8025f4
  800e0d:	6a 32                	push   $0x32
  800e0f:	68 f0 26 80 00       	push   $0x8026f0
  800e14:	e8 47 0f 00 00       	call   801d60 <_panic>

	// Oh my god, I forget this at the first, it waste me a lot of time to debug!!!
	addr = ROUNDDOWN(addr, PGSIZE);
  800e19:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	
	memcpy(PFTEMP, addr, PGSIZE);
  800e1f:	83 ec 04             	sub    $0x4,%esp
  800e22:	68 00 10 00 00       	push   $0x1000
  800e27:	53                   	push   %ebx
  800e28:	68 00 f0 7f 00       	push   $0x7ff000
  800e2d:	e8 5f fb ff ff       	call   800991 <memcpy>
	
	r = sys_page_map(0, PFTEMP, 0, addr, PTE_W | PTE_U | PTE_P);
  800e32:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800e39:	53                   	push   %ebx
  800e3a:	6a 00                	push   $0x0
  800e3c:	68 00 f0 7f 00       	push   $0x7ff000
  800e41:	6a 00                	push   $0x0
  800e43:	e8 c4 fd ff ff       	call   800c0c <sys_page_map>
	if (r < 0) panic("pgfault, sys_page_map error : %e\n", r);
  800e48:	83 c4 20             	add    $0x20,%esp
  800e4b:	85 c0                	test   %eax,%eax
  800e4d:	79 12                	jns    800e61 <pgfault+0xcd>
  800e4f:	50                   	push   %eax
  800e50:	68 18 26 80 00       	push   $0x802618
  800e55:	6a 3a                	push   $0x3a
  800e57:	68 f0 26 80 00       	push   $0x8026f0
  800e5c:	e8 ff 0e 00 00       	call   801d60 <_panic>

	return;
}
  800e61:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e64:	c9                   	leave  
  800e65:	c3                   	ret    

00800e66 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800e66:	55                   	push   %ebp
  800e67:	89 e5                	mov    %esp,%ebp
  800e69:	57                   	push   %edi
  800e6a:	56                   	push   %esi
  800e6b:	53                   	push   %ebx
  800e6c:	83 ec 28             	sub    $0x28,%esp
	// static int num = 0x100;

	// LAB 4: Your code here.
	set_pgfault_handler(pgfault);
  800e6f:	68 94 0d 80 00       	push   $0x800d94
  800e74:	e8 2f 0f 00 00       	call   801da8 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  800e79:	ba 07 00 00 00       	mov    $0x7,%edx
  800e7e:	89 d0                	mov    %edx,%eax
  800e80:	cd 30                	int    $0x30
  800e82:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800e85:	89 c7                	mov    %eax,%edi
	int childpid = sys_exofork();
	if (childpid < 0) {
  800e87:	83 c4 10             	add    $0x10,%esp
  800e8a:	85 c0                	test   %eax,%eax
  800e8c:	79 12                	jns    800ea0 <fork+0x3a>
		panic("fork sys_exofork error : %e\n", childpid);
  800e8e:	50                   	push   %eax
  800e8f:	68 fb 26 80 00       	push   $0x8026fb
  800e94:	6a 7f                	push   $0x7f
  800e96:	68 f0 26 80 00       	push   $0x8026f0
  800e9b:	e8 c0 0e 00 00       	call   801d60 <_panic>
	}
	int r;

	if (childpid == 0) {
  800ea0:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800ea4:	75 20                	jne    800ec6 <fork+0x60>
		// child process
		// Remember to fix "thisenv" in the child process. ??? 
		thisenv = &envs[ENVX(sys_getenvid())];
  800ea6:	e8 f2 fc ff ff       	call   800b9d <sys_getenvid>
  800eab:	25 ff 03 00 00       	and    $0x3ff,%eax
  800eb0:	89 c2                	mov    %eax,%edx
  800eb2:	c1 e2 07             	shl    $0x7,%edx
  800eb5:	8d 84 82 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,4),%eax
  800ebc:	a3 04 40 80 00       	mov    %eax,0x804004
		// cprintf("fork child ok\n");
		return 0;
  800ec1:	e9 be 01 00 00       	jmp    801084 <fork+0x21e>
	if (childpid < 0) {
		panic("fork sys_exofork error : %e\n", childpid);
	}
	int r;

	if (childpid == 0) {
  800ec6:	bb 00 00 00 00       	mov    $0x0,%ebx
	} else {
		// map page to new environment
		// kernel page is already in new environment
		uint32_t i;
		for (i = 0; i != UTOP; i += PGSIZE) 
		if ((uvpd[PDX(i)] & PTE_P) && (uvpt[i / PGSIZE] & PTE_P) && (uvpt[i / PGSIZE] & PTE_U)) {
  800ecb:	89 d8                	mov    %ebx,%eax
  800ecd:	c1 e8 16             	shr    $0x16,%eax
  800ed0:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800ed7:	a8 01                	test   $0x1,%al
  800ed9:	0f 84 10 01 00 00    	je     800fef <fork+0x189>
  800edf:	89 d8                	mov    %ebx,%eax
  800ee1:	c1 e8 0c             	shr    $0xc,%eax
  800ee4:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800eeb:	f6 c2 01             	test   $0x1,%dl
  800eee:	0f 84 fb 00 00 00    	je     800fef <fork+0x189>
  800ef4:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800efb:	f6 c2 04             	test   $0x4,%dl
  800efe:	0f 84 eb 00 00 00    	je     800fef <fork+0x189>
//
static int
duppage(envid_t envid, unsigned pn)
{
	// do not dup exception stack
	if (pn * PGSIZE == UXSTACKTOP - PGSIZE) return 0;
  800f04:	89 c6                	mov    %eax,%esi
  800f06:	c1 e6 0c             	shl    $0xc,%esi
  800f09:	81 fe 00 f0 bf ee    	cmp    $0xeebff000,%esi
  800f0f:	0f 84 da 00 00 00    	je     800fef <fork+0x189>

	int r;
	void * addr = (void *)(pn * PGSIZE);
    if (uvpt[pn] & PTE_SHARE) {
  800f15:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800f1c:	f6 c6 04             	test   $0x4,%dh
  800f1f:	74 37                	je     800f58 <fork+0xf2>
        r = sys_page_map(0, addr, envid, addr, uvpt[pn] & PTE_SYSCALL);
  800f21:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f28:	83 ec 0c             	sub    $0xc,%esp
  800f2b:	25 07 0e 00 00       	and    $0xe07,%eax
  800f30:	50                   	push   %eax
  800f31:	56                   	push   %esi
  800f32:	57                   	push   %edi
  800f33:	56                   	push   %esi
  800f34:	6a 00                	push   $0x0
  800f36:	e8 d1 fc ff ff       	call   800c0c <sys_page_map>
        if (r < 0) panic("duppage sys_page_map error : %e\n", r);
  800f3b:	83 c4 20             	add    $0x20,%esp
  800f3e:	85 c0                	test   %eax,%eax
  800f40:	0f 89 a9 00 00 00    	jns    800fef <fork+0x189>
  800f46:	50                   	push   %eax
  800f47:	68 3c 26 80 00       	push   $0x80263c
  800f4c:	6a 54                	push   $0x54
  800f4e:	68 f0 26 80 00       	push   $0x8026f0
  800f53:	e8 08 0e 00 00       	call   801d60 <_panic>
    } else
	if ((uvpt[pn] & PTE_W) || (uvpt[pn] & PTE_COW)) {
  800f58:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800f5f:	f6 c2 02             	test   $0x2,%dl
  800f62:	75 0c                	jne    800f70 <fork+0x10a>
  800f64:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f6b:	f6 c4 08             	test   $0x8,%ah
  800f6e:	74 57                	je     800fc7 <fork+0x161>
		// cow
		r = sys_page_map(0, addr, envid, addr, PTE_COW | PTE_P | PTE_U);
  800f70:	83 ec 0c             	sub    $0xc,%esp
  800f73:	68 05 08 00 00       	push   $0x805
  800f78:	56                   	push   %esi
  800f79:	57                   	push   %edi
  800f7a:	56                   	push   %esi
  800f7b:	6a 00                	push   $0x0
  800f7d:	e8 8a fc ff ff       	call   800c0c <sys_page_map>
		if (r < 0) panic("duppage sys_page_map error : %e\n", r);
  800f82:	83 c4 20             	add    $0x20,%esp
  800f85:	85 c0                	test   %eax,%eax
  800f87:	79 12                	jns    800f9b <fork+0x135>
  800f89:	50                   	push   %eax
  800f8a:	68 3c 26 80 00       	push   $0x80263c
  800f8f:	6a 59                	push   $0x59
  800f91:	68 f0 26 80 00       	push   $0x8026f0
  800f96:	e8 c5 0d 00 00       	call   801d60 <_panic>
		
		r = sys_page_map(0, addr, 0, addr, PTE_COW | PTE_P | PTE_U);
  800f9b:	83 ec 0c             	sub    $0xc,%esp
  800f9e:	68 05 08 00 00       	push   $0x805
  800fa3:	56                   	push   %esi
  800fa4:	6a 00                	push   $0x0
  800fa6:	56                   	push   %esi
  800fa7:	6a 00                	push   $0x0
  800fa9:	e8 5e fc ff ff       	call   800c0c <sys_page_map>
		if (r < 0) panic("duppage sys_page_map error : %e\n", r);
  800fae:	83 c4 20             	add    $0x20,%esp
  800fb1:	85 c0                	test   %eax,%eax
  800fb3:	79 3a                	jns    800fef <fork+0x189>
  800fb5:	50                   	push   %eax
  800fb6:	68 3c 26 80 00       	push   $0x80263c
  800fbb:	6a 5c                	push   $0x5c
  800fbd:	68 f0 26 80 00       	push   $0x8026f0
  800fc2:	e8 99 0d 00 00       	call   801d60 <_panic>
	} else {
		// read only
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U);
  800fc7:	83 ec 0c             	sub    $0xc,%esp
  800fca:	6a 05                	push   $0x5
  800fcc:	56                   	push   %esi
  800fcd:	57                   	push   %edi
  800fce:	56                   	push   %esi
  800fcf:	6a 00                	push   $0x0
  800fd1:	e8 36 fc ff ff       	call   800c0c <sys_page_map>
		if (r < 0) panic("duppage sys_page_map error : %e\n", r);
  800fd6:	83 c4 20             	add    $0x20,%esp
  800fd9:	85 c0                	test   %eax,%eax
  800fdb:	79 12                	jns    800fef <fork+0x189>
  800fdd:	50                   	push   %eax
  800fde:	68 3c 26 80 00       	push   $0x80263c
  800fe3:	6a 60                	push   $0x60
  800fe5:	68 f0 26 80 00       	push   $0x8026f0
  800fea:	e8 71 0d 00 00       	call   801d60 <_panic>
		return 0;
	} else {
		// map page to new environment
		// kernel page is already in new environment
		uint32_t i;
		for (i = 0; i != UTOP; i += PGSIZE) 
  800fef:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  800ff5:	81 fb 00 00 c0 ee    	cmp    $0xeec00000,%ebx
  800ffb:	0f 85 ca fe ff ff    	jne    800ecb <fork+0x65>
		if ((uvpd[PDX(i)] & PTE_P) && (uvpt[i / PGSIZE] & PTE_P) && (uvpt[i / PGSIZE] & PTE_U)) {
			duppage(childpid, i / PGSIZE);
		}

		// allocate exception stack
		r = sys_page_alloc(childpid, (void *)(UXSTACKTOP - PGSIZE), PTE_U | PTE_W | PTE_P);
  801001:	83 ec 04             	sub    $0x4,%esp
  801004:	6a 07                	push   $0x7
  801006:	68 00 f0 bf ee       	push   $0xeebff000
  80100b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80100e:	e8 d5 fb ff ff       	call   800be8 <sys_page_alloc>
		if (r < 0) panic("fork, sys_page_alloc user exception stack error : %e\n", r);
  801013:	83 c4 10             	add    $0x10,%esp
  801016:	85 c0                	test   %eax,%eax
  801018:	79 15                	jns    80102f <fork+0x1c9>
  80101a:	50                   	push   %eax
  80101b:	68 60 26 80 00       	push   $0x802660
  801020:	68 94 00 00 00       	push   $0x94
  801025:	68 f0 26 80 00       	push   $0x8026f0
  80102a:	e8 31 0d 00 00       	call   801d60 <_panic>

		// set user environment user page fault handler 
		extern void _pgfault_upcall(void);
		r = sys_env_set_pgfault_upcall(childpid, _pgfault_upcall);
  80102f:	83 ec 08             	sub    $0x8,%esp
  801032:	68 14 1e 80 00       	push   $0x801e14
  801037:	ff 75 e4             	pushl  -0x1c(%ebp)
  80103a:	e8 5c fc ff ff       	call   800c9b <sys_env_set_pgfault_upcall>
		if (r < 0) panic("fork, set pgfault upcall fail : %e\n", r);
  80103f:	83 c4 10             	add    $0x10,%esp
  801042:	85 c0                	test   %eax,%eax
  801044:	79 15                	jns    80105b <fork+0x1f5>
  801046:	50                   	push   %eax
  801047:	68 98 26 80 00       	push   $0x802698
  80104c:	68 99 00 00 00       	push   $0x99
  801051:	68 f0 26 80 00       	push   $0x8026f0
  801056:	e8 05 0d 00 00       	call   801d60 <_panic>
		r = sys_set_priority(childpid, num);
		if (r < 0) panic("fork, set priority error\n");
		*/

		// mark the child as runnable and return
		r = sys_env_set_status(childpid, ENV_RUNNABLE);
  80105b:	83 ec 08             	sub    $0x8,%esp
  80105e:	6a 02                	push   $0x2
  801060:	ff 75 e4             	pushl  -0x1c(%ebp)
  801063:	e8 ed fb ff ff       	call   800c55 <sys_env_set_status>
		if (r < 0) panic("fork, set child process to ENV_RUNNABLE error : %e\n", r);
  801068:	83 c4 10             	add    $0x10,%esp
  80106b:	85 c0                	test   %eax,%eax
  80106d:	79 15                	jns    801084 <fork+0x21e>
  80106f:	50                   	push   %eax
  801070:	68 bc 26 80 00       	push   $0x8026bc
  801075:	68 a4 00 00 00       	push   $0xa4
  80107a:	68 f0 26 80 00       	push   $0x8026f0
  80107f:	e8 dc 0c 00 00       	call   801d60 <_panic>
		// cprintf("fork father ok!")
		return childpid;
	}

	panic("fork not implemented");
}
  801084:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801087:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80108a:	5b                   	pop    %ebx
  80108b:	5e                   	pop    %esi
  80108c:	5f                   	pop    %edi
  80108d:	c9                   	leave  
  80108e:	c3                   	ret    

0080108f <sfork>:

// Challenge!
int
sfork(void)
{
  80108f:	55                   	push   %ebp
  801090:	89 e5                	mov    %esp,%ebp
  801092:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  801095:	68 18 27 80 00       	push   $0x802718
  80109a:	68 b1 00 00 00       	push   $0xb1
  80109f:	68 f0 26 80 00       	push   $0x8026f0
  8010a4:	e8 b7 0c 00 00       	call   801d60 <_panic>
  8010a9:	00 00                	add    %al,(%eax)
	...

008010ac <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8010ac:	55                   	push   %ebp
  8010ad:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8010af:	8b 45 08             	mov    0x8(%ebp),%eax
  8010b2:	05 00 00 00 30       	add    $0x30000000,%eax
  8010b7:	c1 e8 0c             	shr    $0xc,%eax
}
  8010ba:	c9                   	leave  
  8010bb:	c3                   	ret    

008010bc <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8010bc:	55                   	push   %ebp
  8010bd:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  8010bf:	ff 75 08             	pushl  0x8(%ebp)
  8010c2:	e8 e5 ff ff ff       	call   8010ac <fd2num>
  8010c7:	83 c4 04             	add    $0x4,%esp
  8010ca:	05 20 00 0d 00       	add    $0xd0020,%eax
  8010cf:	c1 e0 0c             	shl    $0xc,%eax
}
  8010d2:	c9                   	leave  
  8010d3:	c3                   	ret    

008010d4 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8010d4:	55                   	push   %ebp
  8010d5:	89 e5                	mov    %esp,%ebp
  8010d7:	53                   	push   %ebx
  8010d8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8010db:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  8010e0:	a8 01                	test   $0x1,%al
  8010e2:	74 34                	je     801118 <fd_alloc+0x44>
  8010e4:	a1 00 00 74 ef       	mov    0xef740000,%eax
  8010e9:	a8 01                	test   $0x1,%al
  8010eb:	74 32                	je     80111f <fd_alloc+0x4b>
  8010ed:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
  8010f2:	89 c1                	mov    %eax,%ecx
  8010f4:	89 c2                	mov    %eax,%edx
  8010f6:	c1 ea 16             	shr    $0x16,%edx
  8010f9:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801100:	f6 c2 01             	test   $0x1,%dl
  801103:	74 1f                	je     801124 <fd_alloc+0x50>
  801105:	89 c2                	mov    %eax,%edx
  801107:	c1 ea 0c             	shr    $0xc,%edx
  80110a:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801111:	f6 c2 01             	test   $0x1,%dl
  801114:	75 17                	jne    80112d <fd_alloc+0x59>
  801116:	eb 0c                	jmp    801124 <fd_alloc+0x50>
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  801118:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
  80111d:	eb 05                	jmp    801124 <fd_alloc+0x50>
  80111f:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
  801124:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  801126:	b8 00 00 00 00       	mov    $0x0,%eax
  80112b:	eb 17                	jmp    801144 <fd_alloc+0x70>
  80112d:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801132:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801137:	75 b9                	jne    8010f2 <fd_alloc+0x1e>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801139:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  80113f:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801144:	5b                   	pop    %ebx
  801145:	c9                   	leave  
  801146:	c3                   	ret    

00801147 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801147:	55                   	push   %ebp
  801148:	89 e5                	mov    %esp,%ebp
  80114a:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80114d:	83 f8 1f             	cmp    $0x1f,%eax
  801150:	77 36                	ja     801188 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801152:	05 00 00 0d 00       	add    $0xd0000,%eax
  801157:	c1 e0 0c             	shl    $0xc,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80115a:	89 c2                	mov    %eax,%edx
  80115c:	c1 ea 16             	shr    $0x16,%edx
  80115f:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801166:	f6 c2 01             	test   $0x1,%dl
  801169:	74 24                	je     80118f <fd_lookup+0x48>
  80116b:	89 c2                	mov    %eax,%edx
  80116d:	c1 ea 0c             	shr    $0xc,%edx
  801170:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801177:	f6 c2 01             	test   $0x1,%dl
  80117a:	74 1a                	je     801196 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80117c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80117f:	89 02                	mov    %eax,(%edx)
	return 0;
  801181:	b8 00 00 00 00       	mov    $0x0,%eax
  801186:	eb 13                	jmp    80119b <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801188:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80118d:	eb 0c                	jmp    80119b <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80118f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801194:	eb 05                	jmp    80119b <fd_lookup+0x54>
  801196:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  80119b:	c9                   	leave  
  80119c:	c3                   	ret    

0080119d <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80119d:	55                   	push   %ebp
  80119e:	89 e5                	mov    %esp,%ebp
  8011a0:	53                   	push   %ebx
  8011a1:	83 ec 04             	sub    $0x4,%esp
  8011a4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8011a7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  8011aa:	39 0d 04 30 80 00    	cmp    %ecx,0x803004
  8011b0:	74 0d                	je     8011bf <dev_lookup+0x22>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8011b2:	b8 00 00 00 00       	mov    $0x0,%eax
  8011b7:	eb 14                	jmp    8011cd <dev_lookup+0x30>
		if (devtab[i]->dev_id == dev_id) {
  8011b9:	39 0a                	cmp    %ecx,(%edx)
  8011bb:	75 10                	jne    8011cd <dev_lookup+0x30>
  8011bd:	eb 05                	jmp    8011c4 <dev_lookup+0x27>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8011bf:	ba 04 30 80 00       	mov    $0x803004,%edx
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
  8011c4:	89 13                	mov    %edx,(%ebx)
			return 0;
  8011c6:	b8 00 00 00 00       	mov    $0x0,%eax
  8011cb:	eb 31                	jmp    8011fe <dev_lookup+0x61>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8011cd:	40                   	inc    %eax
  8011ce:	8b 14 85 ac 27 80 00 	mov    0x8027ac(,%eax,4),%edx
  8011d5:	85 d2                	test   %edx,%edx
  8011d7:	75 e0                	jne    8011b9 <dev_lookup+0x1c>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8011d9:	a1 04 40 80 00       	mov    0x804004,%eax
  8011de:	8b 40 48             	mov    0x48(%eax),%eax
  8011e1:	83 ec 04             	sub    $0x4,%esp
  8011e4:	51                   	push   %ecx
  8011e5:	50                   	push   %eax
  8011e6:	68 30 27 80 00       	push   $0x802730
  8011eb:	e8 c0 ef ff ff       	call   8001b0 <cprintf>
	*dev = 0;
  8011f0:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  8011f6:	83 c4 10             	add    $0x10,%esp
  8011f9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8011fe:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801201:	c9                   	leave  
  801202:	c3                   	ret    

00801203 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801203:	55                   	push   %ebp
  801204:	89 e5                	mov    %esp,%ebp
  801206:	56                   	push   %esi
  801207:	53                   	push   %ebx
  801208:	83 ec 20             	sub    $0x20,%esp
  80120b:	8b 75 08             	mov    0x8(%ebp),%esi
  80120e:	8a 45 0c             	mov    0xc(%ebp),%al
  801211:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801214:	56                   	push   %esi
  801215:	e8 92 fe ff ff       	call   8010ac <fd2num>
  80121a:	8d 55 f4             	lea    -0xc(%ebp),%edx
  80121d:	89 14 24             	mov    %edx,(%esp)
  801220:	50                   	push   %eax
  801221:	e8 21 ff ff ff       	call   801147 <fd_lookup>
  801226:	89 c3                	mov    %eax,%ebx
  801228:	83 c4 08             	add    $0x8,%esp
  80122b:	85 c0                	test   %eax,%eax
  80122d:	78 05                	js     801234 <fd_close+0x31>
	    || fd != fd2)
  80122f:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801232:	74 0d                	je     801241 <fd_close+0x3e>
		return (must_exist ? r : 0);
  801234:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  801238:	75 48                	jne    801282 <fd_close+0x7f>
  80123a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80123f:	eb 41                	jmp    801282 <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801241:	83 ec 08             	sub    $0x8,%esp
  801244:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801247:	50                   	push   %eax
  801248:	ff 36                	pushl  (%esi)
  80124a:	e8 4e ff ff ff       	call   80119d <dev_lookup>
  80124f:	89 c3                	mov    %eax,%ebx
  801251:	83 c4 10             	add    $0x10,%esp
  801254:	85 c0                	test   %eax,%eax
  801256:	78 1c                	js     801274 <fd_close+0x71>
		if (dev->dev_close)
  801258:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80125b:	8b 40 10             	mov    0x10(%eax),%eax
  80125e:	85 c0                	test   %eax,%eax
  801260:	74 0d                	je     80126f <fd_close+0x6c>
			r = (*dev->dev_close)(fd);
  801262:	83 ec 0c             	sub    $0xc,%esp
  801265:	56                   	push   %esi
  801266:	ff d0                	call   *%eax
  801268:	89 c3                	mov    %eax,%ebx
  80126a:	83 c4 10             	add    $0x10,%esp
  80126d:	eb 05                	jmp    801274 <fd_close+0x71>
		else
			r = 0;
  80126f:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801274:	83 ec 08             	sub    $0x8,%esp
  801277:	56                   	push   %esi
  801278:	6a 00                	push   $0x0
  80127a:	e8 b3 f9 ff ff       	call   800c32 <sys_page_unmap>
	return r;
  80127f:	83 c4 10             	add    $0x10,%esp
}
  801282:	89 d8                	mov    %ebx,%eax
  801284:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801287:	5b                   	pop    %ebx
  801288:	5e                   	pop    %esi
  801289:	c9                   	leave  
  80128a:	c3                   	ret    

0080128b <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80128b:	55                   	push   %ebp
  80128c:	89 e5                	mov    %esp,%ebp
  80128e:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801291:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801294:	50                   	push   %eax
  801295:	ff 75 08             	pushl  0x8(%ebp)
  801298:	e8 aa fe ff ff       	call   801147 <fd_lookup>
  80129d:	83 c4 08             	add    $0x8,%esp
  8012a0:	85 c0                	test   %eax,%eax
  8012a2:	78 10                	js     8012b4 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  8012a4:	83 ec 08             	sub    $0x8,%esp
  8012a7:	6a 01                	push   $0x1
  8012a9:	ff 75 f4             	pushl  -0xc(%ebp)
  8012ac:	e8 52 ff ff ff       	call   801203 <fd_close>
  8012b1:	83 c4 10             	add    $0x10,%esp
}
  8012b4:	c9                   	leave  
  8012b5:	c3                   	ret    

008012b6 <close_all>:

void
close_all(void)
{
  8012b6:	55                   	push   %ebp
  8012b7:	89 e5                	mov    %esp,%ebp
  8012b9:	53                   	push   %ebx
  8012ba:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8012bd:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8012c2:	83 ec 0c             	sub    $0xc,%esp
  8012c5:	53                   	push   %ebx
  8012c6:	e8 c0 ff ff ff       	call   80128b <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8012cb:	43                   	inc    %ebx
  8012cc:	83 c4 10             	add    $0x10,%esp
  8012cf:	83 fb 20             	cmp    $0x20,%ebx
  8012d2:	75 ee                	jne    8012c2 <close_all+0xc>
		close(i);
}
  8012d4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012d7:	c9                   	leave  
  8012d8:	c3                   	ret    

008012d9 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8012d9:	55                   	push   %ebp
  8012da:	89 e5                	mov    %esp,%ebp
  8012dc:	57                   	push   %edi
  8012dd:	56                   	push   %esi
  8012de:	53                   	push   %ebx
  8012df:	83 ec 2c             	sub    $0x2c,%esp
  8012e2:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8012e5:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8012e8:	50                   	push   %eax
  8012e9:	ff 75 08             	pushl  0x8(%ebp)
  8012ec:	e8 56 fe ff ff       	call   801147 <fd_lookup>
  8012f1:	89 c3                	mov    %eax,%ebx
  8012f3:	83 c4 08             	add    $0x8,%esp
  8012f6:	85 c0                	test   %eax,%eax
  8012f8:	0f 88 c0 00 00 00    	js     8013be <dup+0xe5>
		return r;
	close(newfdnum);
  8012fe:	83 ec 0c             	sub    $0xc,%esp
  801301:	57                   	push   %edi
  801302:	e8 84 ff ff ff       	call   80128b <close>

	newfd = INDEX2FD(newfdnum);
  801307:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  80130d:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  801310:	83 c4 04             	add    $0x4,%esp
  801313:	ff 75 e4             	pushl  -0x1c(%ebp)
  801316:	e8 a1 fd ff ff       	call   8010bc <fd2data>
  80131b:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  80131d:	89 34 24             	mov    %esi,(%esp)
  801320:	e8 97 fd ff ff       	call   8010bc <fd2data>
  801325:	83 c4 10             	add    $0x10,%esp
  801328:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80132b:	89 d8                	mov    %ebx,%eax
  80132d:	c1 e8 16             	shr    $0x16,%eax
  801330:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801337:	a8 01                	test   $0x1,%al
  801339:	74 37                	je     801372 <dup+0x99>
  80133b:	89 d8                	mov    %ebx,%eax
  80133d:	c1 e8 0c             	shr    $0xc,%eax
  801340:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801347:	f6 c2 01             	test   $0x1,%dl
  80134a:	74 26                	je     801372 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80134c:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801353:	83 ec 0c             	sub    $0xc,%esp
  801356:	25 07 0e 00 00       	and    $0xe07,%eax
  80135b:	50                   	push   %eax
  80135c:	ff 75 d4             	pushl  -0x2c(%ebp)
  80135f:	6a 00                	push   $0x0
  801361:	53                   	push   %ebx
  801362:	6a 00                	push   $0x0
  801364:	e8 a3 f8 ff ff       	call   800c0c <sys_page_map>
  801369:	89 c3                	mov    %eax,%ebx
  80136b:	83 c4 20             	add    $0x20,%esp
  80136e:	85 c0                	test   %eax,%eax
  801370:	78 2d                	js     80139f <dup+0xc6>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801372:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801375:	89 c2                	mov    %eax,%edx
  801377:	c1 ea 0c             	shr    $0xc,%edx
  80137a:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801381:	83 ec 0c             	sub    $0xc,%esp
  801384:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  80138a:	52                   	push   %edx
  80138b:	56                   	push   %esi
  80138c:	6a 00                	push   $0x0
  80138e:	50                   	push   %eax
  80138f:	6a 00                	push   $0x0
  801391:	e8 76 f8 ff ff       	call   800c0c <sys_page_map>
  801396:	89 c3                	mov    %eax,%ebx
  801398:	83 c4 20             	add    $0x20,%esp
  80139b:	85 c0                	test   %eax,%eax
  80139d:	79 1d                	jns    8013bc <dup+0xe3>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80139f:	83 ec 08             	sub    $0x8,%esp
  8013a2:	56                   	push   %esi
  8013a3:	6a 00                	push   $0x0
  8013a5:	e8 88 f8 ff ff       	call   800c32 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8013aa:	83 c4 08             	add    $0x8,%esp
  8013ad:	ff 75 d4             	pushl  -0x2c(%ebp)
  8013b0:	6a 00                	push   $0x0
  8013b2:	e8 7b f8 ff ff       	call   800c32 <sys_page_unmap>
	return r;
  8013b7:	83 c4 10             	add    $0x10,%esp
  8013ba:	eb 02                	jmp    8013be <dup+0xe5>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  8013bc:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  8013be:	89 d8                	mov    %ebx,%eax
  8013c0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8013c3:	5b                   	pop    %ebx
  8013c4:	5e                   	pop    %esi
  8013c5:	5f                   	pop    %edi
  8013c6:	c9                   	leave  
  8013c7:	c3                   	ret    

008013c8 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8013c8:	55                   	push   %ebp
  8013c9:	89 e5                	mov    %esp,%ebp
  8013cb:	53                   	push   %ebx
  8013cc:	83 ec 14             	sub    $0x14,%esp
  8013cf:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8013d2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8013d5:	50                   	push   %eax
  8013d6:	53                   	push   %ebx
  8013d7:	e8 6b fd ff ff       	call   801147 <fd_lookup>
  8013dc:	83 c4 08             	add    $0x8,%esp
  8013df:	85 c0                	test   %eax,%eax
  8013e1:	78 67                	js     80144a <read+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013e3:	83 ec 08             	sub    $0x8,%esp
  8013e6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013e9:	50                   	push   %eax
  8013ea:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013ed:	ff 30                	pushl  (%eax)
  8013ef:	e8 a9 fd ff ff       	call   80119d <dev_lookup>
  8013f4:	83 c4 10             	add    $0x10,%esp
  8013f7:	85 c0                	test   %eax,%eax
  8013f9:	78 4f                	js     80144a <read+0x82>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8013fb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013fe:	8b 50 08             	mov    0x8(%eax),%edx
  801401:	83 e2 03             	and    $0x3,%edx
  801404:	83 fa 01             	cmp    $0x1,%edx
  801407:	75 21                	jne    80142a <read+0x62>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801409:	a1 04 40 80 00       	mov    0x804004,%eax
  80140e:	8b 40 48             	mov    0x48(%eax),%eax
  801411:	83 ec 04             	sub    $0x4,%esp
  801414:	53                   	push   %ebx
  801415:	50                   	push   %eax
  801416:	68 71 27 80 00       	push   $0x802771
  80141b:	e8 90 ed ff ff       	call   8001b0 <cprintf>
		return -E_INVAL;
  801420:	83 c4 10             	add    $0x10,%esp
  801423:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801428:	eb 20                	jmp    80144a <read+0x82>
	}
	if (!dev->dev_read)
  80142a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80142d:	8b 52 08             	mov    0x8(%edx),%edx
  801430:	85 d2                	test   %edx,%edx
  801432:	74 11                	je     801445 <read+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801434:	83 ec 04             	sub    $0x4,%esp
  801437:	ff 75 10             	pushl  0x10(%ebp)
  80143a:	ff 75 0c             	pushl  0xc(%ebp)
  80143d:	50                   	push   %eax
  80143e:	ff d2                	call   *%edx
  801440:	83 c4 10             	add    $0x10,%esp
  801443:	eb 05                	jmp    80144a <read+0x82>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801445:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  80144a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80144d:	c9                   	leave  
  80144e:	c3                   	ret    

0080144f <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80144f:	55                   	push   %ebp
  801450:	89 e5                	mov    %esp,%ebp
  801452:	57                   	push   %edi
  801453:	56                   	push   %esi
  801454:	53                   	push   %ebx
  801455:	83 ec 0c             	sub    $0xc,%esp
  801458:	8b 7d 08             	mov    0x8(%ebp),%edi
  80145b:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80145e:	85 f6                	test   %esi,%esi
  801460:	74 31                	je     801493 <readn+0x44>
  801462:	b8 00 00 00 00       	mov    $0x0,%eax
  801467:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = read(fdnum, (char*)buf + tot, n - tot);
  80146c:	83 ec 04             	sub    $0x4,%esp
  80146f:	89 f2                	mov    %esi,%edx
  801471:	29 c2                	sub    %eax,%edx
  801473:	52                   	push   %edx
  801474:	03 45 0c             	add    0xc(%ebp),%eax
  801477:	50                   	push   %eax
  801478:	57                   	push   %edi
  801479:	e8 4a ff ff ff       	call   8013c8 <read>
		if (m < 0)
  80147e:	83 c4 10             	add    $0x10,%esp
  801481:	85 c0                	test   %eax,%eax
  801483:	78 17                	js     80149c <readn+0x4d>
			return m;
		if (m == 0)
  801485:	85 c0                	test   %eax,%eax
  801487:	74 11                	je     80149a <readn+0x4b>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801489:	01 c3                	add    %eax,%ebx
  80148b:	89 d8                	mov    %ebx,%eax
  80148d:	39 f3                	cmp    %esi,%ebx
  80148f:	72 db                	jb     80146c <readn+0x1d>
  801491:	eb 09                	jmp    80149c <readn+0x4d>
  801493:	b8 00 00 00 00       	mov    $0x0,%eax
  801498:	eb 02                	jmp    80149c <readn+0x4d>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  80149a:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  80149c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80149f:	5b                   	pop    %ebx
  8014a0:	5e                   	pop    %esi
  8014a1:	5f                   	pop    %edi
  8014a2:	c9                   	leave  
  8014a3:	c3                   	ret    

008014a4 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8014a4:	55                   	push   %ebp
  8014a5:	89 e5                	mov    %esp,%ebp
  8014a7:	53                   	push   %ebx
  8014a8:	83 ec 14             	sub    $0x14,%esp
  8014ab:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8014ae:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014b1:	50                   	push   %eax
  8014b2:	53                   	push   %ebx
  8014b3:	e8 8f fc ff ff       	call   801147 <fd_lookup>
  8014b8:	83 c4 08             	add    $0x8,%esp
  8014bb:	85 c0                	test   %eax,%eax
  8014bd:	78 62                	js     801521 <write+0x7d>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014bf:	83 ec 08             	sub    $0x8,%esp
  8014c2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014c5:	50                   	push   %eax
  8014c6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014c9:	ff 30                	pushl  (%eax)
  8014cb:	e8 cd fc ff ff       	call   80119d <dev_lookup>
  8014d0:	83 c4 10             	add    $0x10,%esp
  8014d3:	85 c0                	test   %eax,%eax
  8014d5:	78 4a                	js     801521 <write+0x7d>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8014d7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014da:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8014de:	75 21                	jne    801501 <write+0x5d>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8014e0:	a1 04 40 80 00       	mov    0x804004,%eax
  8014e5:	8b 40 48             	mov    0x48(%eax),%eax
  8014e8:	83 ec 04             	sub    $0x4,%esp
  8014eb:	53                   	push   %ebx
  8014ec:	50                   	push   %eax
  8014ed:	68 8d 27 80 00       	push   $0x80278d
  8014f2:	e8 b9 ec ff ff       	call   8001b0 <cprintf>
		return -E_INVAL;
  8014f7:	83 c4 10             	add    $0x10,%esp
  8014fa:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8014ff:	eb 20                	jmp    801521 <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801501:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801504:	8b 52 0c             	mov    0xc(%edx),%edx
  801507:	85 d2                	test   %edx,%edx
  801509:	74 11                	je     80151c <write+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80150b:	83 ec 04             	sub    $0x4,%esp
  80150e:	ff 75 10             	pushl  0x10(%ebp)
  801511:	ff 75 0c             	pushl  0xc(%ebp)
  801514:	50                   	push   %eax
  801515:	ff d2                	call   *%edx
  801517:	83 c4 10             	add    $0x10,%esp
  80151a:	eb 05                	jmp    801521 <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80151c:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  801521:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801524:	c9                   	leave  
  801525:	c3                   	ret    

00801526 <seek>:

int
seek(int fdnum, off_t offset)
{
  801526:	55                   	push   %ebp
  801527:	89 e5                	mov    %esp,%ebp
  801529:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80152c:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80152f:	50                   	push   %eax
  801530:	ff 75 08             	pushl  0x8(%ebp)
  801533:	e8 0f fc ff ff       	call   801147 <fd_lookup>
  801538:	83 c4 08             	add    $0x8,%esp
  80153b:	85 c0                	test   %eax,%eax
  80153d:	78 0e                	js     80154d <seek+0x27>
		return r;
	fd->fd_offset = offset;
  80153f:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801542:	8b 55 0c             	mov    0xc(%ebp),%edx
  801545:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801548:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80154d:	c9                   	leave  
  80154e:	c3                   	ret    

0080154f <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80154f:	55                   	push   %ebp
  801550:	89 e5                	mov    %esp,%ebp
  801552:	53                   	push   %ebx
  801553:	83 ec 14             	sub    $0x14,%esp
  801556:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801559:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80155c:	50                   	push   %eax
  80155d:	53                   	push   %ebx
  80155e:	e8 e4 fb ff ff       	call   801147 <fd_lookup>
  801563:	83 c4 08             	add    $0x8,%esp
  801566:	85 c0                	test   %eax,%eax
  801568:	78 5f                	js     8015c9 <ftruncate+0x7a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80156a:	83 ec 08             	sub    $0x8,%esp
  80156d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801570:	50                   	push   %eax
  801571:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801574:	ff 30                	pushl  (%eax)
  801576:	e8 22 fc ff ff       	call   80119d <dev_lookup>
  80157b:	83 c4 10             	add    $0x10,%esp
  80157e:	85 c0                	test   %eax,%eax
  801580:	78 47                	js     8015c9 <ftruncate+0x7a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801582:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801585:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801589:	75 21                	jne    8015ac <ftruncate+0x5d>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80158b:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801590:	8b 40 48             	mov    0x48(%eax),%eax
  801593:	83 ec 04             	sub    $0x4,%esp
  801596:	53                   	push   %ebx
  801597:	50                   	push   %eax
  801598:	68 50 27 80 00       	push   $0x802750
  80159d:	e8 0e ec ff ff       	call   8001b0 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8015a2:	83 c4 10             	add    $0x10,%esp
  8015a5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8015aa:	eb 1d                	jmp    8015c9 <ftruncate+0x7a>
	}
	if (!dev->dev_trunc)
  8015ac:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8015af:	8b 52 18             	mov    0x18(%edx),%edx
  8015b2:	85 d2                	test   %edx,%edx
  8015b4:	74 0e                	je     8015c4 <ftruncate+0x75>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8015b6:	83 ec 08             	sub    $0x8,%esp
  8015b9:	ff 75 0c             	pushl  0xc(%ebp)
  8015bc:	50                   	push   %eax
  8015bd:	ff d2                	call   *%edx
  8015bf:	83 c4 10             	add    $0x10,%esp
  8015c2:	eb 05                	jmp    8015c9 <ftruncate+0x7a>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8015c4:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  8015c9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015cc:	c9                   	leave  
  8015cd:	c3                   	ret    

008015ce <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8015ce:	55                   	push   %ebp
  8015cf:	89 e5                	mov    %esp,%ebp
  8015d1:	53                   	push   %ebx
  8015d2:	83 ec 14             	sub    $0x14,%esp
  8015d5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015d8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015db:	50                   	push   %eax
  8015dc:	ff 75 08             	pushl  0x8(%ebp)
  8015df:	e8 63 fb ff ff       	call   801147 <fd_lookup>
  8015e4:	83 c4 08             	add    $0x8,%esp
  8015e7:	85 c0                	test   %eax,%eax
  8015e9:	78 52                	js     80163d <fstat+0x6f>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015eb:	83 ec 08             	sub    $0x8,%esp
  8015ee:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015f1:	50                   	push   %eax
  8015f2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015f5:	ff 30                	pushl  (%eax)
  8015f7:	e8 a1 fb ff ff       	call   80119d <dev_lookup>
  8015fc:	83 c4 10             	add    $0x10,%esp
  8015ff:	85 c0                	test   %eax,%eax
  801601:	78 3a                	js     80163d <fstat+0x6f>
		return r;
	if (!dev->dev_stat)
  801603:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801606:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80160a:	74 2c                	je     801638 <fstat+0x6a>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80160c:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80160f:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801616:	00 00 00 
	stat->st_isdir = 0;
  801619:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801620:	00 00 00 
	stat->st_dev = dev;
  801623:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801629:	83 ec 08             	sub    $0x8,%esp
  80162c:	53                   	push   %ebx
  80162d:	ff 75 f0             	pushl  -0x10(%ebp)
  801630:	ff 50 14             	call   *0x14(%eax)
  801633:	83 c4 10             	add    $0x10,%esp
  801636:	eb 05                	jmp    80163d <fstat+0x6f>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801638:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  80163d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801640:	c9                   	leave  
  801641:	c3                   	ret    

00801642 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801642:	55                   	push   %ebp
  801643:	89 e5                	mov    %esp,%ebp
  801645:	56                   	push   %esi
  801646:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801647:	83 ec 08             	sub    $0x8,%esp
  80164a:	6a 00                	push   $0x0
  80164c:	ff 75 08             	pushl  0x8(%ebp)
  80164f:	e8 78 01 00 00       	call   8017cc <open>
  801654:	89 c3                	mov    %eax,%ebx
  801656:	83 c4 10             	add    $0x10,%esp
  801659:	85 c0                	test   %eax,%eax
  80165b:	78 1b                	js     801678 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  80165d:	83 ec 08             	sub    $0x8,%esp
  801660:	ff 75 0c             	pushl  0xc(%ebp)
  801663:	50                   	push   %eax
  801664:	e8 65 ff ff ff       	call   8015ce <fstat>
  801669:	89 c6                	mov    %eax,%esi
	close(fd);
  80166b:	89 1c 24             	mov    %ebx,(%esp)
  80166e:	e8 18 fc ff ff       	call   80128b <close>
	return r;
  801673:	83 c4 10             	add    $0x10,%esp
  801676:	89 f3                	mov    %esi,%ebx
}
  801678:	89 d8                	mov    %ebx,%eax
  80167a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80167d:	5b                   	pop    %ebx
  80167e:	5e                   	pop    %esi
  80167f:	c9                   	leave  
  801680:	c3                   	ret    
  801681:	00 00                	add    %al,(%eax)
	...

00801684 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801684:	55                   	push   %ebp
  801685:	89 e5                	mov    %esp,%ebp
  801687:	56                   	push   %esi
  801688:	53                   	push   %ebx
  801689:	89 c3                	mov    %eax,%ebx
  80168b:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  80168d:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801694:	75 12                	jne    8016a8 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801696:	83 ec 0c             	sub    $0xc,%esp
  801699:	6a 01                	push   $0x1
  80169b:	e8 66 08 00 00       	call   801f06 <ipc_find_env>
  8016a0:	a3 00 40 80 00       	mov    %eax,0x804000
  8016a5:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8016a8:	6a 07                	push   $0x7
  8016aa:	68 00 50 80 00       	push   $0x805000
  8016af:	53                   	push   %ebx
  8016b0:	ff 35 00 40 80 00    	pushl  0x804000
  8016b6:	e8 f6 07 00 00       	call   801eb1 <ipc_send>
	
	return ipc_recv(NULL, dstva, NULL);
  8016bb:	83 c4 0c             	add    $0xc,%esp
  8016be:	6a 00                	push   $0x0
  8016c0:	56                   	push   %esi
  8016c1:	6a 00                	push   $0x0
  8016c3:	e8 74 07 00 00       	call   801e3c <ipc_recv>
}
  8016c8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8016cb:	5b                   	pop    %ebx
  8016cc:	5e                   	pop    %esi
  8016cd:	c9                   	leave  
  8016ce:	c3                   	ret    

008016cf <devfile_stat>:
}


static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8016cf:	55                   	push   %ebp
  8016d0:	89 e5                	mov    %esp,%ebp
  8016d2:	53                   	push   %ebx
  8016d3:	83 ec 04             	sub    $0x4,%esp
  8016d6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8016d9:	8b 45 08             	mov    0x8(%ebp),%eax
  8016dc:	8b 40 0c             	mov    0xc(%eax),%eax
  8016df:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0) {
  8016e4:	ba 00 00 00 00       	mov    $0x0,%edx
  8016e9:	b8 05 00 00 00       	mov    $0x5,%eax
  8016ee:	e8 91 ff ff ff       	call   801684 <fsipc>
  8016f3:	85 c0                	test   %eax,%eax
  8016f5:	78 2c                	js     801723 <devfile_stat+0x54>
		return r;
	}
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8016f7:	83 ec 08             	sub    $0x8,%esp
  8016fa:	68 00 50 80 00       	push   $0x805000
  8016ff:	53                   	push   %ebx
  801700:	e8 61 f0 ff ff       	call   800766 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801705:	a1 80 50 80 00       	mov    0x805080,%eax
  80170a:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801710:	a1 84 50 80 00       	mov    0x805084,%eax
  801715:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80171b:	83 c4 10             	add    $0x10,%esp
  80171e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801723:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801726:	c9                   	leave  
  801727:	c3                   	ret    

00801728 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801728:	55                   	push   %ebp
  801729:	89 e5                	mov    %esp,%ebp
  80172b:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80172e:	8b 45 08             	mov    0x8(%ebp),%eax
  801731:	8b 40 0c             	mov    0xc(%eax),%eax
  801734:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801739:	ba 00 00 00 00       	mov    $0x0,%edx
  80173e:	b8 06 00 00 00       	mov    $0x6,%eax
  801743:	e8 3c ff ff ff       	call   801684 <fsipc>
}
  801748:	c9                   	leave  
  801749:	c3                   	ret    

0080174a <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  80174a:	55                   	push   %ebp
  80174b:	89 e5                	mov    %esp,%ebp
  80174d:	56                   	push   %esi
  80174e:	53                   	push   %ebx
  80174f:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801752:	8b 45 08             	mov    0x8(%ebp),%eax
  801755:	8b 40 0c             	mov    0xc(%eax),%eax
  801758:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  80175d:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801763:	ba 00 00 00 00       	mov    $0x0,%edx
  801768:	b8 03 00 00 00       	mov    $0x3,%eax
  80176d:	e8 12 ff ff ff       	call   801684 <fsipc>
  801772:	89 c3                	mov    %eax,%ebx
  801774:	85 c0                	test   %eax,%eax
  801776:	78 4b                	js     8017c3 <devfile_read+0x79>
		return r;
	assert(r <= n);
  801778:	39 c6                	cmp    %eax,%esi
  80177a:	73 16                	jae    801792 <devfile_read+0x48>
  80177c:	68 bc 27 80 00       	push   $0x8027bc
  801781:	68 c3 27 80 00       	push   $0x8027c3
  801786:	6a 7d                	push   $0x7d
  801788:	68 d8 27 80 00       	push   $0x8027d8
  80178d:	e8 ce 05 00 00       	call   801d60 <_panic>
	assert(r <= PGSIZE);
  801792:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801797:	7e 16                	jle    8017af <devfile_read+0x65>
  801799:	68 e3 27 80 00       	push   $0x8027e3
  80179e:	68 c3 27 80 00       	push   $0x8027c3
  8017a3:	6a 7e                	push   $0x7e
  8017a5:	68 d8 27 80 00       	push   $0x8027d8
  8017aa:	e8 b1 05 00 00       	call   801d60 <_panic>
	memmove(buf, &fsipcbuf, r);
  8017af:	83 ec 04             	sub    $0x4,%esp
  8017b2:	50                   	push   %eax
  8017b3:	68 00 50 80 00       	push   $0x805000
  8017b8:	ff 75 0c             	pushl  0xc(%ebp)
  8017bb:	e8 67 f1 ff ff       	call   800927 <memmove>
	return r;
  8017c0:	83 c4 10             	add    $0x10,%esp
}
  8017c3:	89 d8                	mov    %ebx,%eax
  8017c5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017c8:	5b                   	pop    %ebx
  8017c9:	5e                   	pop    %esi
  8017ca:	c9                   	leave  
  8017cb:	c3                   	ret    

008017cc <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8017cc:	55                   	push   %ebp
  8017cd:	89 e5                	mov    %esp,%ebp
  8017cf:	56                   	push   %esi
  8017d0:	53                   	push   %ebx
  8017d1:	83 ec 1c             	sub    $0x1c,%esp
  8017d4:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8017d7:	56                   	push   %esi
  8017d8:	e8 37 ef ff ff       	call   800714 <strlen>
  8017dd:	83 c4 10             	add    $0x10,%esp
  8017e0:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8017e5:	7f 65                	jg     80184c <open+0x80>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8017e7:	83 ec 0c             	sub    $0xc,%esp
  8017ea:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017ed:	50                   	push   %eax
  8017ee:	e8 e1 f8 ff ff       	call   8010d4 <fd_alloc>
  8017f3:	89 c3                	mov    %eax,%ebx
  8017f5:	83 c4 10             	add    $0x10,%esp
  8017f8:	85 c0                	test   %eax,%eax
  8017fa:	78 55                	js     801851 <open+0x85>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8017fc:	83 ec 08             	sub    $0x8,%esp
  8017ff:	56                   	push   %esi
  801800:	68 00 50 80 00       	push   $0x805000
  801805:	e8 5c ef ff ff       	call   800766 <strcpy>
	fsipcbuf.open.req_omode = mode;
  80180a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80180d:	a3 00 54 80 00       	mov    %eax,0x805400



	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801812:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801815:	b8 01 00 00 00       	mov    $0x1,%eax
  80181a:	e8 65 fe ff ff       	call   801684 <fsipc>
  80181f:	89 c3                	mov    %eax,%ebx
  801821:	83 c4 10             	add    $0x10,%esp
  801824:	85 c0                	test   %eax,%eax
  801826:	79 12                	jns    80183a <open+0x6e>
		fd_close(fd, 0);
  801828:	83 ec 08             	sub    $0x8,%esp
  80182b:	6a 00                	push   $0x0
  80182d:	ff 75 f4             	pushl  -0xc(%ebp)
  801830:	e8 ce f9 ff ff       	call   801203 <fd_close>
		return r;
  801835:	83 c4 10             	add    $0x10,%esp
  801838:	eb 17                	jmp    801851 <open+0x85>
	}

	return fd2num(fd);
  80183a:	83 ec 0c             	sub    $0xc,%esp
  80183d:	ff 75 f4             	pushl  -0xc(%ebp)
  801840:	e8 67 f8 ff ff       	call   8010ac <fd2num>
  801845:	89 c3                	mov    %eax,%ebx
  801847:	83 c4 10             	add    $0x10,%esp
  80184a:	eb 05                	jmp    801851 <open+0x85>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  80184c:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801851:	89 d8                	mov    %ebx,%eax
  801853:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801856:	5b                   	pop    %ebx
  801857:	5e                   	pop    %esi
  801858:	c9                   	leave  
  801859:	c3                   	ret    
	...

0080185c <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  80185c:	55                   	push   %ebp
  80185d:	89 e5                	mov    %esp,%ebp
  80185f:	56                   	push   %esi
  801860:	53                   	push   %ebx
  801861:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801864:	83 ec 0c             	sub    $0xc,%esp
  801867:	ff 75 08             	pushl  0x8(%ebp)
  80186a:	e8 4d f8 ff ff       	call   8010bc <fd2data>
  80186f:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  801871:	83 c4 08             	add    $0x8,%esp
  801874:	68 ef 27 80 00       	push   $0x8027ef
  801879:	56                   	push   %esi
  80187a:	e8 e7 ee ff ff       	call   800766 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  80187f:	8b 43 04             	mov    0x4(%ebx),%eax
  801882:	2b 03                	sub    (%ebx),%eax
  801884:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  80188a:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  801891:	00 00 00 
	stat->st_dev = &devpipe;
  801894:	c7 86 88 00 00 00 20 	movl   $0x803020,0x88(%esi)
  80189b:	30 80 00 
	return 0;
}
  80189e:	b8 00 00 00 00       	mov    $0x0,%eax
  8018a3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018a6:	5b                   	pop    %ebx
  8018a7:	5e                   	pop    %esi
  8018a8:	c9                   	leave  
  8018a9:	c3                   	ret    

008018aa <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8018aa:	55                   	push   %ebp
  8018ab:	89 e5                	mov    %esp,%ebp
  8018ad:	53                   	push   %ebx
  8018ae:	83 ec 0c             	sub    $0xc,%esp
  8018b1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8018b4:	53                   	push   %ebx
  8018b5:	6a 00                	push   $0x0
  8018b7:	e8 76 f3 ff ff       	call   800c32 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8018bc:	89 1c 24             	mov    %ebx,(%esp)
  8018bf:	e8 f8 f7 ff ff       	call   8010bc <fd2data>
  8018c4:	83 c4 08             	add    $0x8,%esp
  8018c7:	50                   	push   %eax
  8018c8:	6a 00                	push   $0x0
  8018ca:	e8 63 f3 ff ff       	call   800c32 <sys_page_unmap>
}
  8018cf:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018d2:	c9                   	leave  
  8018d3:	c3                   	ret    

008018d4 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8018d4:	55                   	push   %ebp
  8018d5:	89 e5                	mov    %esp,%ebp
  8018d7:	57                   	push   %edi
  8018d8:	56                   	push   %esi
  8018d9:	53                   	push   %ebx
  8018da:	83 ec 1c             	sub    $0x1c,%esp
  8018dd:	89 c7                	mov    %eax,%edi
  8018df:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8018e2:	a1 04 40 80 00       	mov    0x804004,%eax
  8018e7:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  8018ea:	83 ec 0c             	sub    $0xc,%esp
  8018ed:	57                   	push   %edi
  8018ee:	e8 61 06 00 00       	call   801f54 <pageref>
  8018f3:	89 c6                	mov    %eax,%esi
  8018f5:	83 c4 04             	add    $0x4,%esp
  8018f8:	ff 75 e4             	pushl  -0x1c(%ebp)
  8018fb:	e8 54 06 00 00       	call   801f54 <pageref>
  801900:	83 c4 10             	add    $0x10,%esp
  801903:	39 c6                	cmp    %eax,%esi
  801905:	0f 94 c0             	sete   %al
  801908:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  80190b:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801911:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801914:	39 cb                	cmp    %ecx,%ebx
  801916:	75 08                	jne    801920 <_pipeisclosed+0x4c>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  801918:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80191b:	5b                   	pop    %ebx
  80191c:	5e                   	pop    %esi
  80191d:	5f                   	pop    %edi
  80191e:	c9                   	leave  
  80191f:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  801920:	83 f8 01             	cmp    $0x1,%eax
  801923:	75 bd                	jne    8018e2 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801925:	8b 42 58             	mov    0x58(%edx),%eax
  801928:	6a 01                	push   $0x1
  80192a:	50                   	push   %eax
  80192b:	53                   	push   %ebx
  80192c:	68 f6 27 80 00       	push   $0x8027f6
  801931:	e8 7a e8 ff ff       	call   8001b0 <cprintf>
  801936:	83 c4 10             	add    $0x10,%esp
  801939:	eb a7                	jmp    8018e2 <_pipeisclosed+0xe>

0080193b <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80193b:	55                   	push   %ebp
  80193c:	89 e5                	mov    %esp,%ebp
  80193e:	57                   	push   %edi
  80193f:	56                   	push   %esi
  801940:	53                   	push   %ebx
  801941:	83 ec 28             	sub    $0x28,%esp
  801944:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801947:	56                   	push   %esi
  801948:	e8 6f f7 ff ff       	call   8010bc <fd2data>
  80194d:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80194f:	83 c4 10             	add    $0x10,%esp
  801952:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801956:	75 4a                	jne    8019a2 <devpipe_write+0x67>
  801958:	bf 00 00 00 00       	mov    $0x0,%edi
  80195d:	eb 56                	jmp    8019b5 <devpipe_write+0x7a>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  80195f:	89 da                	mov    %ebx,%edx
  801961:	89 f0                	mov    %esi,%eax
  801963:	e8 6c ff ff ff       	call   8018d4 <_pipeisclosed>
  801968:	85 c0                	test   %eax,%eax
  80196a:	75 4d                	jne    8019b9 <devpipe_write+0x7e>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  80196c:	e8 50 f2 ff ff       	call   800bc1 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801971:	8b 43 04             	mov    0x4(%ebx),%eax
  801974:	8b 13                	mov    (%ebx),%edx
  801976:	83 c2 20             	add    $0x20,%edx
  801979:	39 d0                	cmp    %edx,%eax
  80197b:	73 e2                	jae    80195f <devpipe_write+0x24>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  80197d:	89 c2                	mov    %eax,%edx
  80197f:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  801985:	79 05                	jns    80198c <devpipe_write+0x51>
  801987:	4a                   	dec    %edx
  801988:	83 ca e0             	or     $0xffffffe0,%edx
  80198b:	42                   	inc    %edx
  80198c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80198f:	8a 0c 39             	mov    (%ecx,%edi,1),%cl
  801992:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801996:	40                   	inc    %eax
  801997:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80199a:	47                   	inc    %edi
  80199b:	39 7d 10             	cmp    %edi,0x10(%ebp)
  80199e:	77 07                	ja     8019a7 <devpipe_write+0x6c>
  8019a0:	eb 13                	jmp    8019b5 <devpipe_write+0x7a>
  8019a2:	bf 00 00 00 00       	mov    $0x0,%edi
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8019a7:	8b 43 04             	mov    0x4(%ebx),%eax
  8019aa:	8b 13                	mov    (%ebx),%edx
  8019ac:	83 c2 20             	add    $0x20,%edx
  8019af:	39 d0                	cmp    %edx,%eax
  8019b1:	73 ac                	jae    80195f <devpipe_write+0x24>
  8019b3:	eb c8                	jmp    80197d <devpipe_write+0x42>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  8019b5:	89 f8                	mov    %edi,%eax
  8019b7:	eb 05                	jmp    8019be <devpipe_write+0x83>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8019b9:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  8019be:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8019c1:	5b                   	pop    %ebx
  8019c2:	5e                   	pop    %esi
  8019c3:	5f                   	pop    %edi
  8019c4:	c9                   	leave  
  8019c5:	c3                   	ret    

008019c6 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  8019c6:	55                   	push   %ebp
  8019c7:	89 e5                	mov    %esp,%ebp
  8019c9:	57                   	push   %edi
  8019ca:	56                   	push   %esi
  8019cb:	53                   	push   %ebx
  8019cc:	83 ec 18             	sub    $0x18,%esp
  8019cf:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  8019d2:	57                   	push   %edi
  8019d3:	e8 e4 f6 ff ff       	call   8010bc <fd2data>
  8019d8:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8019da:	83 c4 10             	add    $0x10,%esp
  8019dd:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8019e1:	75 44                	jne    801a27 <devpipe_read+0x61>
  8019e3:	be 00 00 00 00       	mov    $0x0,%esi
  8019e8:	eb 4f                	jmp    801a39 <devpipe_read+0x73>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
				return i;
  8019ea:	89 f0                	mov    %esi,%eax
  8019ec:	eb 54                	jmp    801a42 <devpipe_read+0x7c>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  8019ee:	89 da                	mov    %ebx,%edx
  8019f0:	89 f8                	mov    %edi,%eax
  8019f2:	e8 dd fe ff ff       	call   8018d4 <_pipeisclosed>
  8019f7:	85 c0                	test   %eax,%eax
  8019f9:	75 42                	jne    801a3d <devpipe_read+0x77>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  8019fb:	e8 c1 f1 ff ff       	call   800bc1 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801a00:	8b 03                	mov    (%ebx),%eax
  801a02:	3b 43 04             	cmp    0x4(%ebx),%eax
  801a05:	74 e7                	je     8019ee <devpipe_read+0x28>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801a07:	25 1f 00 00 80       	and    $0x8000001f,%eax
  801a0c:	79 05                	jns    801a13 <devpipe_read+0x4d>
  801a0e:	48                   	dec    %eax
  801a0f:	83 c8 e0             	or     $0xffffffe0,%eax
  801a12:	40                   	inc    %eax
  801a13:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  801a17:	8b 55 0c             	mov    0xc(%ebp),%edx
  801a1a:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  801a1d:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801a1f:	46                   	inc    %esi
  801a20:	39 75 10             	cmp    %esi,0x10(%ebp)
  801a23:	77 07                	ja     801a2c <devpipe_read+0x66>
  801a25:	eb 12                	jmp    801a39 <devpipe_read+0x73>
  801a27:	be 00 00 00 00       	mov    $0x0,%esi
		while (p->p_rpos == p->p_wpos) {
  801a2c:	8b 03                	mov    (%ebx),%eax
  801a2e:	3b 43 04             	cmp    0x4(%ebx),%eax
  801a31:	75 d4                	jne    801a07 <devpipe_read+0x41>
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801a33:	85 f6                	test   %esi,%esi
  801a35:	75 b3                	jne    8019ea <devpipe_read+0x24>
  801a37:	eb b5                	jmp    8019ee <devpipe_read+0x28>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801a39:	89 f0                	mov    %esi,%eax
  801a3b:	eb 05                	jmp    801a42 <devpipe_read+0x7c>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801a3d:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801a42:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a45:	5b                   	pop    %ebx
  801a46:	5e                   	pop    %esi
  801a47:	5f                   	pop    %edi
  801a48:	c9                   	leave  
  801a49:	c3                   	ret    

00801a4a <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801a4a:	55                   	push   %ebp
  801a4b:	89 e5                	mov    %esp,%ebp
  801a4d:	57                   	push   %edi
  801a4e:	56                   	push   %esi
  801a4f:	53                   	push   %ebx
  801a50:	83 ec 28             	sub    $0x28,%esp
  801a53:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801a56:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801a59:	50                   	push   %eax
  801a5a:	e8 75 f6 ff ff       	call   8010d4 <fd_alloc>
  801a5f:	89 c3                	mov    %eax,%ebx
  801a61:	83 c4 10             	add    $0x10,%esp
  801a64:	85 c0                	test   %eax,%eax
  801a66:	0f 88 24 01 00 00    	js     801b90 <pipe+0x146>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801a6c:	83 ec 04             	sub    $0x4,%esp
  801a6f:	68 07 04 00 00       	push   $0x407
  801a74:	ff 75 e4             	pushl  -0x1c(%ebp)
  801a77:	6a 00                	push   $0x0
  801a79:	e8 6a f1 ff ff       	call   800be8 <sys_page_alloc>
  801a7e:	89 c3                	mov    %eax,%ebx
  801a80:	83 c4 10             	add    $0x10,%esp
  801a83:	85 c0                	test   %eax,%eax
  801a85:	0f 88 05 01 00 00    	js     801b90 <pipe+0x146>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801a8b:	83 ec 0c             	sub    $0xc,%esp
  801a8e:	8d 45 e0             	lea    -0x20(%ebp),%eax
  801a91:	50                   	push   %eax
  801a92:	e8 3d f6 ff ff       	call   8010d4 <fd_alloc>
  801a97:	89 c3                	mov    %eax,%ebx
  801a99:	83 c4 10             	add    $0x10,%esp
  801a9c:	85 c0                	test   %eax,%eax
  801a9e:	0f 88 dc 00 00 00    	js     801b80 <pipe+0x136>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801aa4:	83 ec 04             	sub    $0x4,%esp
  801aa7:	68 07 04 00 00       	push   $0x407
  801aac:	ff 75 e0             	pushl  -0x20(%ebp)
  801aaf:	6a 00                	push   $0x0
  801ab1:	e8 32 f1 ff ff       	call   800be8 <sys_page_alloc>
  801ab6:	89 c3                	mov    %eax,%ebx
  801ab8:	83 c4 10             	add    $0x10,%esp
  801abb:	85 c0                	test   %eax,%eax
  801abd:	0f 88 bd 00 00 00    	js     801b80 <pipe+0x136>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801ac3:	83 ec 0c             	sub    $0xc,%esp
  801ac6:	ff 75 e4             	pushl  -0x1c(%ebp)
  801ac9:	e8 ee f5 ff ff       	call   8010bc <fd2data>
  801ace:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ad0:	83 c4 0c             	add    $0xc,%esp
  801ad3:	68 07 04 00 00       	push   $0x407
  801ad8:	50                   	push   %eax
  801ad9:	6a 00                	push   $0x0
  801adb:	e8 08 f1 ff ff       	call   800be8 <sys_page_alloc>
  801ae0:	89 c3                	mov    %eax,%ebx
  801ae2:	83 c4 10             	add    $0x10,%esp
  801ae5:	85 c0                	test   %eax,%eax
  801ae7:	0f 88 83 00 00 00    	js     801b70 <pipe+0x126>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801aed:	83 ec 0c             	sub    $0xc,%esp
  801af0:	ff 75 e0             	pushl  -0x20(%ebp)
  801af3:	e8 c4 f5 ff ff       	call   8010bc <fd2data>
  801af8:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801aff:	50                   	push   %eax
  801b00:	6a 00                	push   $0x0
  801b02:	56                   	push   %esi
  801b03:	6a 00                	push   $0x0
  801b05:	e8 02 f1 ff ff       	call   800c0c <sys_page_map>
  801b0a:	89 c3                	mov    %eax,%ebx
  801b0c:	83 c4 20             	add    $0x20,%esp
  801b0f:	85 c0                	test   %eax,%eax
  801b11:	78 4f                	js     801b62 <pipe+0x118>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801b13:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801b19:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801b1c:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801b1e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801b21:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801b28:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801b2e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801b31:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801b33:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801b36:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801b3d:	83 ec 0c             	sub    $0xc,%esp
  801b40:	ff 75 e4             	pushl  -0x1c(%ebp)
  801b43:	e8 64 f5 ff ff       	call   8010ac <fd2num>
  801b48:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  801b4a:	83 c4 04             	add    $0x4,%esp
  801b4d:	ff 75 e0             	pushl  -0x20(%ebp)
  801b50:	e8 57 f5 ff ff       	call   8010ac <fd2num>
  801b55:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  801b58:	83 c4 10             	add    $0x10,%esp
  801b5b:	bb 00 00 00 00       	mov    $0x0,%ebx
  801b60:	eb 2e                	jmp    801b90 <pipe+0x146>

    err3:
	sys_page_unmap(0, va);
  801b62:	83 ec 08             	sub    $0x8,%esp
  801b65:	56                   	push   %esi
  801b66:	6a 00                	push   $0x0
  801b68:	e8 c5 f0 ff ff       	call   800c32 <sys_page_unmap>
  801b6d:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801b70:	83 ec 08             	sub    $0x8,%esp
  801b73:	ff 75 e0             	pushl  -0x20(%ebp)
  801b76:	6a 00                	push   $0x0
  801b78:	e8 b5 f0 ff ff       	call   800c32 <sys_page_unmap>
  801b7d:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801b80:	83 ec 08             	sub    $0x8,%esp
  801b83:	ff 75 e4             	pushl  -0x1c(%ebp)
  801b86:	6a 00                	push   $0x0
  801b88:	e8 a5 f0 ff ff       	call   800c32 <sys_page_unmap>
  801b8d:	83 c4 10             	add    $0x10,%esp
    err:
	return r;
}
  801b90:	89 d8                	mov    %ebx,%eax
  801b92:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b95:	5b                   	pop    %ebx
  801b96:	5e                   	pop    %esi
  801b97:	5f                   	pop    %edi
  801b98:	c9                   	leave  
  801b99:	c3                   	ret    

00801b9a <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801b9a:	55                   	push   %ebp
  801b9b:	89 e5                	mov    %esp,%ebp
  801b9d:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801ba0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ba3:	50                   	push   %eax
  801ba4:	ff 75 08             	pushl  0x8(%ebp)
  801ba7:	e8 9b f5 ff ff       	call   801147 <fd_lookup>
  801bac:	83 c4 10             	add    $0x10,%esp
  801baf:	85 c0                	test   %eax,%eax
  801bb1:	78 18                	js     801bcb <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801bb3:	83 ec 0c             	sub    $0xc,%esp
  801bb6:	ff 75 f4             	pushl  -0xc(%ebp)
  801bb9:	e8 fe f4 ff ff       	call   8010bc <fd2data>
	return _pipeisclosed(fd, p);
  801bbe:	89 c2                	mov    %eax,%edx
  801bc0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801bc3:	e8 0c fd ff ff       	call   8018d4 <_pipeisclosed>
  801bc8:	83 c4 10             	add    $0x10,%esp
}
  801bcb:	c9                   	leave  
  801bcc:	c3                   	ret    
  801bcd:	00 00                	add    %al,(%eax)
	...

00801bd0 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801bd0:	55                   	push   %ebp
  801bd1:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801bd3:	b8 00 00 00 00       	mov    $0x0,%eax
  801bd8:	c9                   	leave  
  801bd9:	c3                   	ret    

00801bda <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801bda:	55                   	push   %ebp
  801bdb:	89 e5                	mov    %esp,%ebp
  801bdd:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801be0:	68 0e 28 80 00       	push   $0x80280e
  801be5:	ff 75 0c             	pushl  0xc(%ebp)
  801be8:	e8 79 eb ff ff       	call   800766 <strcpy>
	return 0;
}
  801bed:	b8 00 00 00 00       	mov    $0x0,%eax
  801bf2:	c9                   	leave  
  801bf3:	c3                   	ret    

00801bf4 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801bf4:	55                   	push   %ebp
  801bf5:	89 e5                	mov    %esp,%ebp
  801bf7:	57                   	push   %edi
  801bf8:	56                   	push   %esi
  801bf9:	53                   	push   %ebx
  801bfa:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801c00:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801c04:	74 45                	je     801c4b <devcons_write+0x57>
  801c06:	b8 00 00 00 00       	mov    $0x0,%eax
  801c0b:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801c10:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801c16:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801c19:	29 c3                	sub    %eax,%ebx
		if (m > sizeof(buf) - 1)
  801c1b:	83 fb 7f             	cmp    $0x7f,%ebx
  801c1e:	76 05                	jbe    801c25 <devcons_write+0x31>
			m = sizeof(buf) - 1;
  801c20:	bb 7f 00 00 00       	mov    $0x7f,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  801c25:	83 ec 04             	sub    $0x4,%esp
  801c28:	53                   	push   %ebx
  801c29:	03 45 0c             	add    0xc(%ebp),%eax
  801c2c:	50                   	push   %eax
  801c2d:	57                   	push   %edi
  801c2e:	e8 f4 ec ff ff       	call   800927 <memmove>
		sys_cputs(buf, m);
  801c33:	83 c4 08             	add    $0x8,%esp
  801c36:	53                   	push   %ebx
  801c37:	57                   	push   %edi
  801c38:	e8 f4 ee ff ff       	call   800b31 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801c3d:	01 de                	add    %ebx,%esi
  801c3f:	89 f0                	mov    %esi,%eax
  801c41:	83 c4 10             	add    $0x10,%esp
  801c44:	3b 75 10             	cmp    0x10(%ebp),%esi
  801c47:	72 cd                	jb     801c16 <devcons_write+0x22>
  801c49:	eb 05                	jmp    801c50 <devcons_write+0x5c>
  801c4b:	be 00 00 00 00       	mov    $0x0,%esi
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801c50:	89 f0                	mov    %esi,%eax
  801c52:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c55:	5b                   	pop    %ebx
  801c56:	5e                   	pop    %esi
  801c57:	5f                   	pop    %edi
  801c58:	c9                   	leave  
  801c59:	c3                   	ret    

00801c5a <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801c5a:	55                   	push   %ebp
  801c5b:	89 e5                	mov    %esp,%ebp
  801c5d:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  801c60:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801c64:	75 07                	jne    801c6d <devcons_read+0x13>
  801c66:	eb 25                	jmp    801c8d <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801c68:	e8 54 ef ff ff       	call   800bc1 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801c6d:	e8 e5 ee ff ff       	call   800b57 <sys_cgetc>
  801c72:	85 c0                	test   %eax,%eax
  801c74:	74 f2                	je     801c68 <devcons_read+0xe>
  801c76:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  801c78:	85 c0                	test   %eax,%eax
  801c7a:	78 1d                	js     801c99 <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801c7c:	83 f8 04             	cmp    $0x4,%eax
  801c7f:	74 13                	je     801c94 <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  801c81:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c84:	88 10                	mov    %dl,(%eax)
	return 1;
  801c86:	b8 01 00 00 00       	mov    $0x1,%eax
  801c8b:	eb 0c                	jmp    801c99 <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  801c8d:	b8 00 00 00 00       	mov    $0x0,%eax
  801c92:	eb 05                	jmp    801c99 <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801c94:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801c99:	c9                   	leave  
  801c9a:	c3                   	ret    

00801c9b <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801c9b:	55                   	push   %ebp
  801c9c:	89 e5                	mov    %esp,%ebp
  801c9e:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801ca1:	8b 45 08             	mov    0x8(%ebp),%eax
  801ca4:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801ca7:	6a 01                	push   $0x1
  801ca9:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801cac:	50                   	push   %eax
  801cad:	e8 7f ee ff ff       	call   800b31 <sys_cputs>
  801cb2:	83 c4 10             	add    $0x10,%esp
}
  801cb5:	c9                   	leave  
  801cb6:	c3                   	ret    

00801cb7 <getchar>:

int
getchar(void)
{
  801cb7:	55                   	push   %ebp
  801cb8:	89 e5                	mov    %esp,%ebp
  801cba:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801cbd:	6a 01                	push   $0x1
  801cbf:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801cc2:	50                   	push   %eax
  801cc3:	6a 00                	push   $0x0
  801cc5:	e8 fe f6 ff ff       	call   8013c8 <read>
	if (r < 0)
  801cca:	83 c4 10             	add    $0x10,%esp
  801ccd:	85 c0                	test   %eax,%eax
  801ccf:	78 0f                	js     801ce0 <getchar+0x29>
		return r;
	if (r < 1)
  801cd1:	85 c0                	test   %eax,%eax
  801cd3:	7e 06                	jle    801cdb <getchar+0x24>
		return -E_EOF;
	return c;
  801cd5:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801cd9:	eb 05                	jmp    801ce0 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801cdb:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801ce0:	c9                   	leave  
  801ce1:	c3                   	ret    

00801ce2 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801ce2:	55                   	push   %ebp
  801ce3:	89 e5                	mov    %esp,%ebp
  801ce5:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801ce8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ceb:	50                   	push   %eax
  801cec:	ff 75 08             	pushl  0x8(%ebp)
  801cef:	e8 53 f4 ff ff       	call   801147 <fd_lookup>
  801cf4:	83 c4 10             	add    $0x10,%esp
  801cf7:	85 c0                	test   %eax,%eax
  801cf9:	78 11                	js     801d0c <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801cfb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cfe:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801d04:	39 10                	cmp    %edx,(%eax)
  801d06:	0f 94 c0             	sete   %al
  801d09:	0f b6 c0             	movzbl %al,%eax
}
  801d0c:	c9                   	leave  
  801d0d:	c3                   	ret    

00801d0e <opencons>:

int
opencons(void)
{
  801d0e:	55                   	push   %ebp
  801d0f:	89 e5                	mov    %esp,%ebp
  801d11:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801d14:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d17:	50                   	push   %eax
  801d18:	e8 b7 f3 ff ff       	call   8010d4 <fd_alloc>
  801d1d:	83 c4 10             	add    $0x10,%esp
  801d20:	85 c0                	test   %eax,%eax
  801d22:	78 3a                	js     801d5e <opencons+0x50>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801d24:	83 ec 04             	sub    $0x4,%esp
  801d27:	68 07 04 00 00       	push   $0x407
  801d2c:	ff 75 f4             	pushl  -0xc(%ebp)
  801d2f:	6a 00                	push   $0x0
  801d31:	e8 b2 ee ff ff       	call   800be8 <sys_page_alloc>
  801d36:	83 c4 10             	add    $0x10,%esp
  801d39:	85 c0                	test   %eax,%eax
  801d3b:	78 21                	js     801d5e <opencons+0x50>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801d3d:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801d43:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d46:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801d48:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d4b:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801d52:	83 ec 0c             	sub    $0xc,%esp
  801d55:	50                   	push   %eax
  801d56:	e8 51 f3 ff ff       	call   8010ac <fd2num>
  801d5b:	83 c4 10             	add    $0x10,%esp
}
  801d5e:	c9                   	leave  
  801d5f:	c3                   	ret    

00801d60 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801d60:	55                   	push   %ebp
  801d61:	89 e5                	mov    %esp,%ebp
  801d63:	56                   	push   %esi
  801d64:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801d65:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801d68:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  801d6e:	e8 2a ee ff ff       	call   800b9d <sys_getenvid>
  801d73:	83 ec 0c             	sub    $0xc,%esp
  801d76:	ff 75 0c             	pushl  0xc(%ebp)
  801d79:	ff 75 08             	pushl  0x8(%ebp)
  801d7c:	53                   	push   %ebx
  801d7d:	50                   	push   %eax
  801d7e:	68 1c 28 80 00       	push   $0x80281c
  801d83:	e8 28 e4 ff ff       	call   8001b0 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801d88:	83 c4 18             	add    $0x18,%esp
  801d8b:	56                   	push   %esi
  801d8c:	ff 75 10             	pushl  0x10(%ebp)
  801d8f:	e8 cb e3 ff ff       	call   80015f <vcprintf>
	cprintf("\n");
  801d94:	c7 04 24 74 22 80 00 	movl   $0x802274,(%esp)
  801d9b:	e8 10 e4 ff ff       	call   8001b0 <cprintf>
  801da0:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801da3:	cc                   	int3   
  801da4:	eb fd                	jmp    801da3 <_panic+0x43>
	...

00801da8 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801da8:	55                   	push   %ebp
  801da9:	89 e5                	mov    %esp,%ebp
  801dab:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  801dae:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801db5:	75 52                	jne    801e09 <set_pgfault_handler+0x61>
		// First time through!	
		// LAB 4: Your code here.

		//int sys_page_alloc(envid_t envid, void *va, int perm)
		r = sys_page_alloc(0, (void*)(UXSTACKTOP - PGSIZE), PTE_U | PTE_W | PTE_P);
  801db7:	83 ec 04             	sub    $0x4,%esp
  801dba:	6a 07                	push   $0x7
  801dbc:	68 00 f0 bf ee       	push   $0xeebff000
  801dc1:	6a 00                	push   $0x0
  801dc3:	e8 20 ee ff ff       	call   800be8 <sys_page_alloc>
		if (r < 0) {
  801dc8:	83 c4 10             	add    $0x10,%esp
  801dcb:	85 c0                	test   %eax,%eax
  801dcd:	79 12                	jns    801de1 <set_pgfault_handler+0x39>
			panic("sys_page_alloc error : %e\n", r);
  801dcf:	50                   	push   %eax
  801dd0:	68 3f 28 80 00       	push   $0x80283f
  801dd5:	6a 24                	push   $0x24
  801dd7:	68 5a 28 80 00       	push   $0x80285a
  801ddc:	e8 7f ff ff ff       	call   801d60 <_panic>
		}

		// how to know envid, put 0, envid2env will help us to get curenv in syscall
		r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);		
  801de1:	83 ec 08             	sub    $0x8,%esp
  801de4:	68 14 1e 80 00       	push   $0x801e14
  801de9:	6a 00                	push   $0x0
  801deb:	e8 ab ee ff ff       	call   800c9b <sys_env_set_pgfault_upcall>
		if (r < 0) {
  801df0:	83 c4 10             	add    $0x10,%esp
  801df3:	85 c0                	test   %eax,%eax
  801df5:	79 12                	jns    801e09 <set_pgfault_handler+0x61>
			panic("sys_env_set_pgfault_upcall error : %e\n", r);
  801df7:	50                   	push   %eax
  801df8:	68 68 28 80 00       	push   $0x802868
  801dfd:	6a 2a                	push   $0x2a
  801dff:	68 5a 28 80 00       	push   $0x80285a
  801e04:	e8 57 ff ff ff       	call   801d60 <_panic>
		}
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801e09:	8b 45 08             	mov    0x8(%ebp),%eax
  801e0c:	a3 00 60 80 00       	mov    %eax,0x806000
}
  801e11:	c9                   	leave  
  801e12:	c3                   	ret    
	...

00801e14 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801e14:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801e15:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  801e1a:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801e1c:	83 c4 04             	add    $0x4,%esp
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	
	// fix old esp
	movl 0x30(%esp), %eax
  801e1f:	8b 44 24 30          	mov    0x30(%esp),%eax
	subl $0x4, %eax
  801e23:	83 e8 04             	sub    $0x4,%eax
	movl %eax, 0x30(%esp)
  801e26:	89 44 24 30          	mov    %eax,0x30(%esp)

	// set trap-time %eip
	movl 0x28(%esp), %ebx
  801e2a:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	movl %ebx, (%eax)
  801e2e:	89 18                	mov    %ebx,(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $0x08, %esp 	// ignore err_code and fault_va
  801e30:	83 c4 08             	add    $0x8,%esp
	popal 				// restore registers
  801e33:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x04, %esp 	// ignore eip 
  801e34:	83 c4 04             	add    $0x4,%esp
	popfl				// modify eflags
  801e37:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  801e38:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  801e39:	c3                   	ret    
	...

00801e3c <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801e3c:	55                   	push   %ebp
  801e3d:	89 e5                	mov    %esp,%ebp
  801e3f:	56                   	push   %esi
  801e40:	53                   	push   %ebx
  801e41:	8b 75 08             	mov    0x8(%ebp),%esi
  801e44:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e47:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// cprintf("0x%x 0x%x 0x%x\n", (uint32_t)from_env_store, (uint32_t)pg, (uint32_t)perm_store);
	int r;
	if (pg != NULL) {
  801e4a:	85 c0                	test   %eax,%eax
  801e4c:	74 0e                	je     801e5c <ipc_recv+0x20>
		r = sys_ipc_recv(pg);
  801e4e:	83 ec 0c             	sub    $0xc,%esp
  801e51:	50                   	push   %eax
  801e52:	e8 8c ee ff ff       	call   800ce3 <sys_ipc_recv>
  801e57:	83 c4 10             	add    $0x10,%esp
  801e5a:	eb 10                	jmp    801e6c <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv((void *)UTOP);
  801e5c:	83 ec 0c             	sub    $0xc,%esp
  801e5f:	68 00 00 c0 ee       	push   $0xeec00000
  801e64:	e8 7a ee ff ff       	call   800ce3 <sys_ipc_recv>
  801e69:	83 c4 10             	add    $0x10,%esp
	}

	if (r == 0) {
  801e6c:	85 c0                	test   %eax,%eax
  801e6e:	75 26                	jne    801e96 <ipc_recv+0x5a>
		if (from_env_store != NULL) *from_env_store = thisenv->env_ipc_from;
  801e70:	85 f6                	test   %esi,%esi
  801e72:	74 0a                	je     801e7e <ipc_recv+0x42>
  801e74:	a1 04 40 80 00       	mov    0x804004,%eax
  801e79:	8b 40 74             	mov    0x74(%eax),%eax
  801e7c:	89 06                	mov    %eax,(%esi)
		if (perm_store != NULL) *perm_store = thisenv->env_ipc_perm;
  801e7e:	85 db                	test   %ebx,%ebx
  801e80:	74 0a                	je     801e8c <ipc_recv+0x50>
  801e82:	a1 04 40 80 00       	mov    0x804004,%eax
  801e87:	8b 40 78             	mov    0x78(%eax),%eax
  801e8a:	89 03                	mov    %eax,(%ebx)
		return thisenv->env_ipc_value;
  801e8c:	a1 04 40 80 00       	mov    0x804004,%eax
  801e91:	8b 40 70             	mov    0x70(%eax),%eax
  801e94:	eb 14                	jmp    801eaa <ipc_recv+0x6e>
	} else {
		// fails;
		if (from_env_store != NULL) *from_env_store = 0;
  801e96:	85 f6                	test   %esi,%esi
  801e98:	74 06                	je     801ea0 <ipc_recv+0x64>
  801e9a:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if (perm_store != NULL) *perm_store = 0;
  801ea0:	85 db                	test   %ebx,%ebx
  801ea2:	74 06                	je     801eaa <ipc_recv+0x6e>
  801ea4:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		return r;
	}
}
  801eaa:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ead:	5b                   	pop    %ebx
  801eae:	5e                   	pop    %esi
  801eaf:	c9                   	leave  
  801eb0:	c3                   	ret    

00801eb1 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801eb1:	55                   	push   %ebp
  801eb2:	89 e5                	mov    %esp,%ebp
  801eb4:	57                   	push   %edi
  801eb5:	56                   	push   %esi
  801eb6:	53                   	push   %ebx
  801eb7:	83 ec 0c             	sub    $0xc,%esp
  801eba:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801ebd:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801ec0:	8b 75 14             	mov    0x14(%ebp),%esi
	// LAB 4: Your code here.
	// int sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
	int r;
	if (pg == NULL) pg = (void *)UTOP;
  801ec3:	85 db                	test   %ebx,%ebx
  801ec5:	75 25                	jne    801eec <ipc_send+0x3b>
  801ec7:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
  801ecc:	eb 1e                	jmp    801eec <ipc_send+0x3b>
	
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) != 0) {
		if (r == -E_IPC_NOT_RECV) {
  801ece:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801ed1:	75 07                	jne    801eda <ipc_send+0x29>
			// cprintf("Try Again and Again....\n");
			sys_yield();
  801ed3:	e8 e9 ec ff ff       	call   800bc1 <sys_yield>
  801ed8:	eb 12                	jmp    801eec <ipc_send+0x3b>
		} else {
			panic("ipc_send error %e\n", r);
  801eda:	50                   	push   %eax
  801edb:	68 90 28 80 00       	push   $0x802890
  801ee0:	6a 43                	push   $0x43
  801ee2:	68 a3 28 80 00       	push   $0x8028a3
  801ee7:	e8 74 fe ff ff       	call   801d60 <_panic>
	// LAB 4: Your code here.
	// int sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
	int r;
	if (pg == NULL) pg = (void *)UTOP;
	
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) != 0) {
  801eec:	56                   	push   %esi
  801eed:	53                   	push   %ebx
  801eee:	57                   	push   %edi
  801eef:	ff 75 08             	pushl  0x8(%ebp)
  801ef2:	e8 c7 ed ff ff       	call   800cbe <sys_ipc_try_send>
  801ef7:	83 c4 10             	add    $0x10,%esp
  801efa:	85 c0                	test   %eax,%eax
  801efc:	75 d0                	jne    801ece <ipc_send+0x1d>
		} else {
			panic("ipc_send error %e\n", r);
		}
	}
	return;
}
  801efe:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f01:	5b                   	pop    %ebx
  801f02:	5e                   	pop    %esi
  801f03:	5f                   	pop    %edi
  801f04:	c9                   	leave  
  801f05:	c3                   	ret    

00801f06 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801f06:	55                   	push   %ebp
  801f07:	89 e5                	mov    %esp,%ebp
  801f09:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  801f0c:	39 0d 50 00 c0 ee    	cmp    %ecx,0xeec00050
  801f12:	74 1a                	je     801f2e <ipc_find_env+0x28>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801f14:	b8 01 00 00 00       	mov    $0x1,%eax
		if (envs[i].env_type == type)
  801f19:	89 c2                	mov    %eax,%edx
  801f1b:	c1 e2 07             	shl    $0x7,%edx
  801f1e:	8d 94 82 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,4),%edx
  801f25:	8b 52 50             	mov    0x50(%edx),%edx
  801f28:	39 ca                	cmp    %ecx,%edx
  801f2a:	75 18                	jne    801f44 <ipc_find_env+0x3e>
  801f2c:	eb 05                	jmp    801f33 <ipc_find_env+0x2d>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801f2e:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
			return envs[i].env_id;
  801f33:	89 c2                	mov    %eax,%edx
  801f35:	c1 e2 07             	shl    $0x7,%edx
  801f38:	8d 84 82 08 00 c0 ee 	lea    -0x113ffff8(%edx,%eax,4),%eax
  801f3f:	8b 40 40             	mov    0x40(%eax),%eax
  801f42:	eb 0c                	jmp    801f50 <ipc_find_env+0x4a>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801f44:	40                   	inc    %eax
  801f45:	3d 00 04 00 00       	cmp    $0x400,%eax
  801f4a:	75 cd                	jne    801f19 <ipc_find_env+0x13>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801f4c:	66 b8 00 00          	mov    $0x0,%ax
}
  801f50:	c9                   	leave  
  801f51:	c3                   	ret    
	...

00801f54 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801f54:	55                   	push   %ebp
  801f55:	89 e5                	mov    %esp,%ebp
  801f57:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801f5a:	89 c2                	mov    %eax,%edx
  801f5c:	c1 ea 16             	shr    $0x16,%edx
  801f5f:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801f66:	f6 c2 01             	test   $0x1,%dl
  801f69:	74 1e                	je     801f89 <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  801f6b:	c1 e8 0c             	shr    $0xc,%eax
  801f6e:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801f75:	a8 01                	test   $0x1,%al
  801f77:	74 17                	je     801f90 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801f79:	c1 e8 0c             	shr    $0xc,%eax
  801f7c:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  801f83:	ef 
  801f84:	0f b7 c0             	movzwl %ax,%eax
  801f87:	eb 0c                	jmp    801f95 <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  801f89:	b8 00 00 00 00       	mov    $0x0,%eax
  801f8e:	eb 05                	jmp    801f95 <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  801f90:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  801f95:	c9                   	leave  
  801f96:	c3                   	ret    
	...

00801f98 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  801f98:	55                   	push   %ebp
  801f99:	89 e5                	mov    %esp,%ebp
  801f9b:	57                   	push   %edi
  801f9c:	56                   	push   %esi
  801f9d:	83 ec 10             	sub    $0x10,%esp
  801fa0:	8b 7d 08             	mov    0x8(%ebp),%edi
  801fa3:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  801fa6:	89 7d f0             	mov    %edi,-0x10(%ebp)
  801fa9:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  801fac:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  801faf:	8b 45 14             	mov    0x14(%ebp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  801fb2:	85 c0                	test   %eax,%eax
  801fb4:	75 2e                	jne    801fe4 <__udivdi3+0x4c>
    {
      if (d0 > n1)
  801fb6:	39 f1                	cmp    %esi,%ecx
  801fb8:	77 5a                	ja     802014 <__udivdi3+0x7c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  801fba:	85 c9                	test   %ecx,%ecx
  801fbc:	75 0b                	jne    801fc9 <__udivdi3+0x31>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  801fbe:	b8 01 00 00 00       	mov    $0x1,%eax
  801fc3:	31 d2                	xor    %edx,%edx
  801fc5:	f7 f1                	div    %ecx
  801fc7:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  801fc9:	31 d2                	xor    %edx,%edx
  801fcb:	89 f0                	mov    %esi,%eax
  801fcd:	f7 f1                	div    %ecx
  801fcf:	89 c6                	mov    %eax,%esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801fd1:	89 f8                	mov    %edi,%eax
  801fd3:	f7 f1                	div    %ecx
  801fd5:	89 c7                	mov    %eax,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801fd7:	89 f8                	mov    %edi,%eax
  801fd9:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801fdb:	83 c4 10             	add    $0x10,%esp
  801fde:	5e                   	pop    %esi
  801fdf:	5f                   	pop    %edi
  801fe0:	c9                   	leave  
  801fe1:	c3                   	ret    
  801fe2:	66 90                	xchg   %ax,%ax
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801fe4:	39 f0                	cmp    %esi,%eax
  801fe6:	77 1c                	ja     802004 <__udivdi3+0x6c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  801fe8:	0f bd f8             	bsr    %eax,%edi
	  if (bm == 0)
  801feb:	83 f7 1f             	xor    $0x1f,%edi
  801fee:	75 3c                	jne    80202c <__udivdi3+0x94>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801ff0:	39 f0                	cmp    %esi,%eax
  801ff2:	0f 82 90 00 00 00    	jb     802088 <__udivdi3+0xf0>
  801ff8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801ffb:	39 55 f4             	cmp    %edx,-0xc(%ebp)
  801ffe:	0f 86 84 00 00 00    	jbe    802088 <__udivdi3+0xf0>
  802004:	31 f6                	xor    %esi,%esi
  802006:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  802008:	89 f8                	mov    %edi,%eax
  80200a:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  80200c:	83 c4 10             	add    $0x10,%esp
  80200f:	5e                   	pop    %esi
  802010:	5f                   	pop    %edi
  802011:	c9                   	leave  
  802012:	c3                   	ret    
  802013:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802014:	89 f2                	mov    %esi,%edx
  802016:	89 f8                	mov    %edi,%eax
  802018:	f7 f1                	div    %ecx
  80201a:	89 c7                	mov    %eax,%edi
  80201c:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  80201e:	89 f8                	mov    %edi,%eax
  802020:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802022:	83 c4 10             	add    $0x10,%esp
  802025:	5e                   	pop    %esi
  802026:	5f                   	pop    %edi
  802027:	c9                   	leave  
  802028:	c3                   	ret    
  802029:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  80202c:	89 f9                	mov    %edi,%ecx
  80202e:	d3 e0                	shl    %cl,%eax
  802030:	89 45 e8             	mov    %eax,-0x18(%ebp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  802033:	b8 20 00 00 00       	mov    $0x20,%eax
  802038:	29 f8                	sub    %edi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  80203a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80203d:	88 c1                	mov    %al,%cl
  80203f:	d3 ea                	shr    %cl,%edx
  802041:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  802044:	09 ca                	or     %ecx,%edx
  802046:	89 55 ec             	mov    %edx,-0x14(%ebp)
	      d0 = d0 << bm;
  802049:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80204c:	89 f9                	mov    %edi,%ecx
  80204e:	d3 e2                	shl    %cl,%edx
  802050:	89 55 f4             	mov    %edx,-0xc(%ebp)
	      n2 = n1 >> b;
  802053:	89 f2                	mov    %esi,%edx
  802055:	88 c1                	mov    %al,%cl
  802057:	d3 ea                	shr    %cl,%edx
  802059:	89 55 e8             	mov    %edx,-0x18(%ebp)
	      n1 = (n1 << bm) | (n0 >> b);
  80205c:	89 f2                	mov    %esi,%edx
  80205e:	89 f9                	mov    %edi,%ecx
  802060:	d3 e2                	shl    %cl,%edx
  802062:	8b 75 f0             	mov    -0x10(%ebp),%esi
  802065:	88 c1                	mov    %al,%cl
  802067:	d3 ee                	shr    %cl,%esi
  802069:	09 d6                	or     %edx,%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  80206b:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  80206e:	89 f0                	mov    %esi,%eax
  802070:	89 ca                	mov    %ecx,%edx
  802072:	f7 75 ec             	divl   -0x14(%ebp)
  802075:	89 d1                	mov    %edx,%ecx
  802077:	89 c6                	mov    %eax,%esi
	      umul_ppmm (m1, m0, q0, d0);
  802079:	f7 65 f4             	mull   -0xc(%ebp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  80207c:	39 d1                	cmp    %edx,%ecx
  80207e:	72 28                	jb     8020a8 <__udivdi3+0x110>
  802080:	74 1a                	je     80209c <__udivdi3+0x104>
  802082:	89 f7                	mov    %esi,%edi
  802084:	31 f6                	xor    %esi,%esi
  802086:	eb 80                	jmp    802008 <__udivdi3+0x70>
	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  802088:	31 f6                	xor    %esi,%esi
  80208a:	bf 01 00 00 00       	mov    $0x1,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  80208f:	89 f8                	mov    %edi,%eax
  802091:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802093:	83 c4 10             	add    $0x10,%esp
  802096:	5e                   	pop    %esi
  802097:	5f                   	pop    %edi
  802098:	c9                   	leave  
  802099:	c3                   	ret    
  80209a:	66 90                	xchg   %ax,%ax

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  80209c:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80209f:	89 f9                	mov    %edi,%ecx
  8020a1:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8020a3:	39 c2                	cmp    %eax,%edx
  8020a5:	73 db                	jae    802082 <__udivdi3+0xea>
  8020a7:	90                   	nop
		{
		  q0--;
  8020a8:	8d 7e ff             	lea    -0x1(%esi),%edi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  8020ab:	31 f6                	xor    %esi,%esi
  8020ad:	e9 56 ff ff ff       	jmp    802008 <__udivdi3+0x70>
	...

008020b4 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  8020b4:	55                   	push   %ebp
  8020b5:	89 e5                	mov    %esp,%ebp
  8020b7:	57                   	push   %edi
  8020b8:	56                   	push   %esi
  8020b9:	83 ec 20             	sub    $0x20,%esp
  8020bc:	8b 45 08             	mov    0x8(%ebp),%eax
  8020bf:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  8020c2:	89 45 e8             	mov    %eax,-0x18(%ebp)
  8020c5:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  8020c8:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  8020cb:	8b 7d 14             	mov    0x14(%ebp),%edi
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  8020ce:	89 45 f0             	mov    %eax,-0x10(%ebp)
  n1 = nn.s.high;
  8020d1:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  8020d3:	85 ff                	test   %edi,%edi
  8020d5:	75 15                	jne    8020ec <__umoddi3+0x38>
    {
      if (d0 > n1)
  8020d7:	39 f1                	cmp    %esi,%ecx
  8020d9:	0f 86 99 00 00 00    	jbe    802178 <__umoddi3+0xc4>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8020df:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  8020e1:	89 d0                	mov    %edx,%eax
  8020e3:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8020e5:	83 c4 20             	add    $0x20,%esp
  8020e8:	5e                   	pop    %esi
  8020e9:	5f                   	pop    %edi
  8020ea:	c9                   	leave  
  8020eb:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  8020ec:	39 f7                	cmp    %esi,%edi
  8020ee:	0f 87 a4 00 00 00    	ja     802198 <__umoddi3+0xe4>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  8020f4:	0f bd c7             	bsr    %edi,%eax
	  if (bm == 0)
  8020f7:	83 f0 1f             	xor    $0x1f,%eax
  8020fa:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8020fd:	0f 84 a1 00 00 00    	je     8021a4 <__umoddi3+0xf0>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  802103:	89 f8                	mov    %edi,%eax
  802105:	8a 4d ec             	mov    -0x14(%ebp),%cl
  802108:	d3 e0                	shl    %cl,%eax
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  80210a:	bf 20 00 00 00       	mov    $0x20,%edi
  80210f:	2b 7d ec             	sub    -0x14(%ebp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  802112:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802115:	89 f9                	mov    %edi,%ecx
  802117:	d3 ea                	shr    %cl,%edx
  802119:	09 c2                	or     %eax,%edx
  80211b:	89 55 f0             	mov    %edx,-0x10(%ebp)
	      d0 = d0 << bm;
  80211e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802121:	8a 4d ec             	mov    -0x14(%ebp),%cl
  802124:	d3 e0                	shl    %cl,%eax
  802126:	89 45 f4             	mov    %eax,-0xc(%ebp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  802129:	89 f2                	mov    %esi,%edx
  80212b:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  80212d:	8b 45 e8             	mov    -0x18(%ebp),%eax
  802130:	d3 e0                	shl    %cl,%eax
  802132:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  802135:	8b 45 e8             	mov    -0x18(%ebp),%eax
  802138:	89 f9                	mov    %edi,%ecx
  80213a:	d3 e8                	shr    %cl,%eax
  80213c:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  80213e:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  802140:	89 f2                	mov    %esi,%edx
  802142:	f7 75 f0             	divl   -0x10(%ebp)
  802145:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  802147:	f7 65 f4             	mull   -0xc(%ebp)
  80214a:	89 55 e8             	mov    %edx,-0x18(%ebp)
  80214d:	89 c1                	mov    %eax,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  80214f:	39 d6                	cmp    %edx,%esi
  802151:	72 71                	jb     8021c4 <__umoddi3+0x110>
  802153:	74 7f                	je     8021d4 <__umoddi3+0x120>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  802155:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802158:	29 c8                	sub    %ecx,%eax
  80215a:	19 d6                	sbb    %edx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  80215c:	8a 4d ec             	mov    -0x14(%ebp),%cl
  80215f:	d3 e8                	shr    %cl,%eax
  802161:	89 f2                	mov    %esi,%edx
  802163:	89 f9                	mov    %edi,%ecx
  802165:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  802167:	09 d0                	or     %edx,%eax
  802169:	89 f2                	mov    %esi,%edx
  80216b:	8a 4d ec             	mov    -0x14(%ebp),%cl
  80216e:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802170:	83 c4 20             	add    $0x20,%esp
  802173:	5e                   	pop    %esi
  802174:	5f                   	pop    %edi
  802175:	c9                   	leave  
  802176:	c3                   	ret    
  802177:	90                   	nop
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  802178:	85 c9                	test   %ecx,%ecx
  80217a:	75 0b                	jne    802187 <__umoddi3+0xd3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  80217c:	b8 01 00 00 00       	mov    $0x1,%eax
  802181:	31 d2                	xor    %edx,%edx
  802183:	f7 f1                	div    %ecx
  802185:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  802187:	89 f0                	mov    %esi,%eax
  802189:	31 d2                	xor    %edx,%edx
  80218b:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  80218d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802190:	f7 f1                	div    %ecx
  802192:	e9 4a ff ff ff       	jmp    8020e1 <__umoddi3+0x2d>
  802197:	90                   	nop
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  802198:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  80219a:	83 c4 20             	add    $0x20,%esp
  80219d:	5e                   	pop    %esi
  80219e:	5f                   	pop    %edi
  80219f:	c9                   	leave  
  8021a0:	c3                   	ret    
  8021a1:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  8021a4:	39 f7                	cmp    %esi,%edi
  8021a6:	72 05                	jb     8021ad <__umoddi3+0xf9>
  8021a8:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
  8021ab:	77 0c                	ja     8021b9 <__umoddi3+0x105>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  8021ad:	89 f2                	mov    %esi,%edx
  8021af:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8021b2:	29 c8                	sub    %ecx,%eax
  8021b4:	19 fa                	sbb    %edi,%edx
  8021b6:	89 45 f0             	mov    %eax,-0x10(%ebp)

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  8021b9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8021bc:	83 c4 20             	add    $0x20,%esp
  8021bf:	5e                   	pop    %esi
  8021c0:	5f                   	pop    %edi
  8021c1:	c9                   	leave  
  8021c2:	c3                   	ret    
  8021c3:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  8021c4:	8b 55 e8             	mov    -0x18(%ebp),%edx
  8021c7:	89 c1                	mov    %eax,%ecx
  8021c9:	2b 4d f4             	sub    -0xc(%ebp),%ecx
  8021cc:	1b 55 f0             	sbb    -0x10(%ebp),%edx
  8021cf:	eb 84                	jmp    802155 <__umoddi3+0xa1>
  8021d1:	8d 76 00             	lea    0x0(%esi),%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8021d4:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  8021d7:	72 eb                	jb     8021c4 <__umoddi3+0x110>
  8021d9:	89 f2                	mov    %esi,%edx
  8021db:	e9 75 ff ff ff       	jmp    802155 <__umoddi3+0xa1>
