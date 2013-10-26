
obj/user/spin:     file format elf32-i386


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
  80003b:	68 00 13 80 00       	push   $0x801300
  800040:	e8 5f 01 00 00       	call   8001a4 <cprintf>
	if ((env = fork()) == 0) {
  800045:	e8 84 0d 00 00       	call   800dce <fork>
  80004a:	89 c3                	mov    %eax,%ebx
  80004c:	83 c4 10             	add    $0x10,%esp
  80004f:	85 c0                	test   %eax,%eax
  800051:	75 12                	jne    800065 <umain+0x31>
		cprintf("I am the child.  Spinning...\n");
  800053:	83 ec 0c             	sub    $0xc,%esp
  800056:	68 78 13 80 00       	push   $0x801378
  80005b:	e8 44 01 00 00       	call   8001a4 <cprintf>
  800060:	83 c4 10             	add    $0x10,%esp
  800063:	eb fe                	jmp    800063 <umain+0x2f>
		while (1)
			/* do nothing */;
	}

	cprintf("I am the parent.  Running the child...\n");
  800065:	83 ec 0c             	sub    $0xc,%esp
  800068:	68 28 13 80 00       	push   $0x801328
  80006d:	e8 32 01 00 00       	call   8001a4 <cprintf>
	sys_yield();
  800072:	e8 3e 0b 00 00       	call   800bb5 <sys_yield>
	sys_yield();
  800077:	e8 39 0b 00 00       	call   800bb5 <sys_yield>
	sys_yield();
  80007c:	e8 34 0b 00 00       	call   800bb5 <sys_yield>
	sys_yield();
  800081:	e8 2f 0b 00 00       	call   800bb5 <sys_yield>
	sys_yield();
  800086:	e8 2a 0b 00 00       	call   800bb5 <sys_yield>
	sys_yield();
  80008b:	e8 25 0b 00 00       	call   800bb5 <sys_yield>
	sys_yield();
  800090:	e8 20 0b 00 00       	call   800bb5 <sys_yield>
	sys_yield();
  800095:	e8 1b 0b 00 00       	call   800bb5 <sys_yield>

	cprintf("I am the parent.  Killing the child...\n");
  80009a:	c7 04 24 50 13 80 00 	movl   $0x801350,(%esp)
  8000a1:	e8 fe 00 00 00       	call   8001a4 <cprintf>
	sys_env_destroy(env);
  8000a6:	89 1c 24             	mov    %ebx,(%esp)
  8000a9:	e8 c1 0a 00 00       	call   800b6f <sys_env_destroy>
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
  8000c3:	e8 c9 0a 00 00       	call   800b91 <sys_getenvid>
  8000c8:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000cd:	c1 e0 07             	shl    $0x7,%eax
  8000d0:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000d5:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000da:	85 f6                	test   %esi,%esi
  8000dc:	7e 07                	jle    8000e5 <libmain+0x2d>
		binaryname = argv[0];
  8000de:	8b 03                	mov    (%ebx),%eax
  8000e0:	a3 00 20 80 00       	mov    %eax,0x802000
	// call user main routine
	umain(argc, argv);
  8000e5:	83 ec 08             	sub    $0x8,%esp
  8000e8:	53                   	push   %ebx
  8000e9:	56                   	push   %esi
  8000ea:	e8 45 ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  8000ef:	e8 0c 00 00 00       	call   800100 <exit>
  8000f4:	83 c4 10             	add    $0x10,%esp
}
  8000f7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000fa:	5b                   	pop    %ebx
  8000fb:	5e                   	pop    %esi
  8000fc:	c9                   	leave  
  8000fd:	c3                   	ret    
	...

00800100 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800100:	55                   	push   %ebp
  800101:	89 e5                	mov    %esp,%ebp
  800103:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  800106:	6a 00                	push   $0x0
  800108:	e8 62 0a 00 00       	call   800b6f <sys_env_destroy>
  80010d:	83 c4 10             	add    $0x10,%esp
}
  800110:	c9                   	leave  
  800111:	c3                   	ret    
	...

00800114 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800114:	55                   	push   %ebp
  800115:	89 e5                	mov    %esp,%ebp
  800117:	53                   	push   %ebx
  800118:	83 ec 04             	sub    $0x4,%esp
  80011b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80011e:	8b 03                	mov    (%ebx),%eax
  800120:	8b 55 08             	mov    0x8(%ebp),%edx
  800123:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  800127:	40                   	inc    %eax
  800128:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  80012a:	3d ff 00 00 00       	cmp    $0xff,%eax
  80012f:	75 1a                	jne    80014b <putch+0x37>
		sys_cputs(b->buf, b->idx);
  800131:	83 ec 08             	sub    $0x8,%esp
  800134:	68 ff 00 00 00       	push   $0xff
  800139:	8d 43 08             	lea    0x8(%ebx),%eax
  80013c:	50                   	push   %eax
  80013d:	e8 e3 09 00 00       	call   800b25 <sys_cputs>
		b->idx = 0;
  800142:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800148:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80014b:	ff 43 04             	incl   0x4(%ebx)
}
  80014e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800151:	c9                   	leave  
  800152:	c3                   	ret    

00800153 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800153:	55                   	push   %ebp
  800154:	89 e5                	mov    %esp,%ebp
  800156:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80015c:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800163:	00 00 00 
	b.cnt = 0;
  800166:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80016d:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800170:	ff 75 0c             	pushl  0xc(%ebp)
  800173:	ff 75 08             	pushl  0x8(%ebp)
  800176:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80017c:	50                   	push   %eax
  80017d:	68 14 01 80 00       	push   $0x800114
  800182:	e8 82 01 00 00       	call   800309 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800187:	83 c4 08             	add    $0x8,%esp
  80018a:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800190:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800196:	50                   	push   %eax
  800197:	e8 89 09 00 00       	call   800b25 <sys_cputs>

	return b.cnt;
}
  80019c:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001a2:	c9                   	leave  
  8001a3:	c3                   	ret    

008001a4 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001a4:	55                   	push   %ebp
  8001a5:	89 e5                	mov    %esp,%ebp
  8001a7:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001aa:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001ad:	50                   	push   %eax
  8001ae:	ff 75 08             	pushl  0x8(%ebp)
  8001b1:	e8 9d ff ff ff       	call   800153 <vcprintf>
	va_end(ap);

	return cnt;
}
  8001b6:	c9                   	leave  
  8001b7:	c3                   	ret    

008001b8 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001b8:	55                   	push   %ebp
  8001b9:	89 e5                	mov    %esp,%ebp
  8001bb:	57                   	push   %edi
  8001bc:	56                   	push   %esi
  8001bd:	53                   	push   %ebx
  8001be:	83 ec 2c             	sub    $0x2c,%esp
  8001c1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8001c4:	89 d6                	mov    %edx,%esi
  8001c6:	8b 45 08             	mov    0x8(%ebp),%eax
  8001c9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001cc:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001cf:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8001d2:	8b 45 10             	mov    0x10(%ebp),%eax
  8001d5:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8001d8:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001db:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8001de:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  8001e5:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
  8001e8:	72 0c                	jb     8001f6 <printnum+0x3e>
  8001ea:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  8001ed:	76 07                	jbe    8001f6 <printnum+0x3e>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8001ef:	4b                   	dec    %ebx
  8001f0:	85 db                	test   %ebx,%ebx
  8001f2:	7f 31                	jg     800225 <printnum+0x6d>
  8001f4:	eb 3f                	jmp    800235 <printnum+0x7d>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001f6:	83 ec 0c             	sub    $0xc,%esp
  8001f9:	57                   	push   %edi
  8001fa:	4b                   	dec    %ebx
  8001fb:	53                   	push   %ebx
  8001fc:	50                   	push   %eax
  8001fd:	83 ec 08             	sub    $0x8,%esp
  800200:	ff 75 d4             	pushl  -0x2c(%ebp)
  800203:	ff 75 d0             	pushl  -0x30(%ebp)
  800206:	ff 75 dc             	pushl  -0x24(%ebp)
  800209:	ff 75 d8             	pushl  -0x28(%ebp)
  80020c:	e8 97 0e 00 00       	call   8010a8 <__udivdi3>
  800211:	83 c4 18             	add    $0x18,%esp
  800214:	52                   	push   %edx
  800215:	50                   	push   %eax
  800216:	89 f2                	mov    %esi,%edx
  800218:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80021b:	e8 98 ff ff ff       	call   8001b8 <printnum>
  800220:	83 c4 20             	add    $0x20,%esp
  800223:	eb 10                	jmp    800235 <printnum+0x7d>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800225:	83 ec 08             	sub    $0x8,%esp
  800228:	56                   	push   %esi
  800229:	57                   	push   %edi
  80022a:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80022d:	4b                   	dec    %ebx
  80022e:	83 c4 10             	add    $0x10,%esp
  800231:	85 db                	test   %ebx,%ebx
  800233:	7f f0                	jg     800225 <printnum+0x6d>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800235:	83 ec 08             	sub    $0x8,%esp
  800238:	56                   	push   %esi
  800239:	83 ec 04             	sub    $0x4,%esp
  80023c:	ff 75 d4             	pushl  -0x2c(%ebp)
  80023f:	ff 75 d0             	pushl  -0x30(%ebp)
  800242:	ff 75 dc             	pushl  -0x24(%ebp)
  800245:	ff 75 d8             	pushl  -0x28(%ebp)
  800248:	e8 77 0f 00 00       	call   8011c4 <__umoddi3>
  80024d:	83 c4 14             	add    $0x14,%esp
  800250:	0f be 80 a0 13 80 00 	movsbl 0x8013a0(%eax),%eax
  800257:	50                   	push   %eax
  800258:	ff 55 e4             	call   *-0x1c(%ebp)
  80025b:	83 c4 10             	add    $0x10,%esp
}
  80025e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800261:	5b                   	pop    %ebx
  800262:	5e                   	pop    %esi
  800263:	5f                   	pop    %edi
  800264:	c9                   	leave  
  800265:	c3                   	ret    

00800266 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800266:	55                   	push   %ebp
  800267:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800269:	83 fa 01             	cmp    $0x1,%edx
  80026c:	7e 0e                	jle    80027c <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80026e:	8b 10                	mov    (%eax),%edx
  800270:	8d 4a 08             	lea    0x8(%edx),%ecx
  800273:	89 08                	mov    %ecx,(%eax)
  800275:	8b 02                	mov    (%edx),%eax
  800277:	8b 52 04             	mov    0x4(%edx),%edx
  80027a:	eb 22                	jmp    80029e <getuint+0x38>
	else if (lflag)
  80027c:	85 d2                	test   %edx,%edx
  80027e:	74 10                	je     800290 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800280:	8b 10                	mov    (%eax),%edx
  800282:	8d 4a 04             	lea    0x4(%edx),%ecx
  800285:	89 08                	mov    %ecx,(%eax)
  800287:	8b 02                	mov    (%edx),%eax
  800289:	ba 00 00 00 00       	mov    $0x0,%edx
  80028e:	eb 0e                	jmp    80029e <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800290:	8b 10                	mov    (%eax),%edx
  800292:	8d 4a 04             	lea    0x4(%edx),%ecx
  800295:	89 08                	mov    %ecx,(%eax)
  800297:	8b 02                	mov    (%edx),%eax
  800299:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80029e:	c9                   	leave  
  80029f:	c3                   	ret    

008002a0 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  8002a0:	55                   	push   %ebp
  8002a1:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002a3:	83 fa 01             	cmp    $0x1,%edx
  8002a6:	7e 0e                	jle    8002b6 <getint+0x16>
		return va_arg(*ap, long long);
  8002a8:	8b 10                	mov    (%eax),%edx
  8002aa:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002ad:	89 08                	mov    %ecx,(%eax)
  8002af:	8b 02                	mov    (%edx),%eax
  8002b1:	8b 52 04             	mov    0x4(%edx),%edx
  8002b4:	eb 1a                	jmp    8002d0 <getint+0x30>
	else if (lflag)
  8002b6:	85 d2                	test   %edx,%edx
  8002b8:	74 0c                	je     8002c6 <getint+0x26>
		return va_arg(*ap, long);
  8002ba:	8b 10                	mov    (%eax),%edx
  8002bc:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002bf:	89 08                	mov    %ecx,(%eax)
  8002c1:	8b 02                	mov    (%edx),%eax
  8002c3:	99                   	cltd   
  8002c4:	eb 0a                	jmp    8002d0 <getint+0x30>
	else
		return va_arg(*ap, int);
  8002c6:	8b 10                	mov    (%eax),%edx
  8002c8:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002cb:	89 08                	mov    %ecx,(%eax)
  8002cd:	8b 02                	mov    (%edx),%eax
  8002cf:	99                   	cltd   
}
  8002d0:	c9                   	leave  
  8002d1:	c3                   	ret    

008002d2 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002d2:	55                   	push   %ebp
  8002d3:	89 e5                	mov    %esp,%ebp
  8002d5:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002d8:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  8002db:	8b 10                	mov    (%eax),%edx
  8002dd:	3b 50 04             	cmp    0x4(%eax),%edx
  8002e0:	73 08                	jae    8002ea <sprintputch+0x18>
		*b->buf++ = ch;
  8002e2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8002e5:	88 0a                	mov    %cl,(%edx)
  8002e7:	42                   	inc    %edx
  8002e8:	89 10                	mov    %edx,(%eax)
}
  8002ea:	c9                   	leave  
  8002eb:	c3                   	ret    

008002ec <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8002ec:	55                   	push   %ebp
  8002ed:	89 e5                	mov    %esp,%ebp
  8002ef:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8002f2:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002f5:	50                   	push   %eax
  8002f6:	ff 75 10             	pushl  0x10(%ebp)
  8002f9:	ff 75 0c             	pushl  0xc(%ebp)
  8002fc:	ff 75 08             	pushl  0x8(%ebp)
  8002ff:	e8 05 00 00 00       	call   800309 <vprintfmt>
	va_end(ap);
  800304:	83 c4 10             	add    $0x10,%esp
}
  800307:	c9                   	leave  
  800308:	c3                   	ret    

00800309 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800309:	55                   	push   %ebp
  80030a:	89 e5                	mov    %esp,%ebp
  80030c:	57                   	push   %edi
  80030d:	56                   	push   %esi
  80030e:	53                   	push   %ebx
  80030f:	83 ec 2c             	sub    $0x2c,%esp
  800312:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800315:	8b 75 10             	mov    0x10(%ebp),%esi
  800318:	eb 13                	jmp    80032d <vprintfmt+0x24>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80031a:	85 c0                	test   %eax,%eax
  80031c:	0f 84 6d 03 00 00    	je     80068f <vprintfmt+0x386>
				return;
			putch(ch, putdat);
  800322:	83 ec 08             	sub    $0x8,%esp
  800325:	57                   	push   %edi
  800326:	50                   	push   %eax
  800327:	ff 55 08             	call   *0x8(%ebp)
  80032a:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80032d:	0f b6 06             	movzbl (%esi),%eax
  800330:	46                   	inc    %esi
  800331:	83 f8 25             	cmp    $0x25,%eax
  800334:	75 e4                	jne    80031a <vprintfmt+0x11>
  800336:	c6 45 dc 20          	movb   $0x20,-0x24(%ebp)
  80033a:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  800341:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  800348:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  80034f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800354:	eb 28                	jmp    80037e <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800356:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800358:	c6 45 dc 2d          	movb   $0x2d,-0x24(%ebp)
  80035c:	eb 20                	jmp    80037e <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80035e:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800360:	c6 45 dc 30          	movb   $0x30,-0x24(%ebp)
  800364:	eb 18                	jmp    80037e <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800366:	89 de                	mov    %ebx,%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800368:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  80036f:	eb 0d                	jmp    80037e <vprintfmt+0x75>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800371:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800374:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800377:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80037e:	8a 06                	mov    (%esi),%al
  800380:	0f b6 d0             	movzbl %al,%edx
  800383:	8d 5e 01             	lea    0x1(%esi),%ebx
  800386:	83 e8 23             	sub    $0x23,%eax
  800389:	3c 55                	cmp    $0x55,%al
  80038b:	0f 87 e0 02 00 00    	ja     800671 <vprintfmt+0x368>
  800391:	0f b6 c0             	movzbl %al,%eax
  800394:	ff 24 85 60 14 80 00 	jmp    *0x801460(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80039b:	83 ea 30             	sub    $0x30,%edx
  80039e:	89 55 d4             	mov    %edx,-0x2c(%ebp)
				ch = *fmt;
  8003a1:	0f be 03             	movsbl (%ebx),%eax
				if (ch < '0' || ch > '9')
  8003a4:	8d 50 d0             	lea    -0x30(%eax),%edx
  8003a7:	83 fa 09             	cmp    $0x9,%edx
  8003aa:	77 44                	ja     8003f0 <vprintfmt+0xe7>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ac:	89 de                	mov    %ebx,%esi
  8003ae:	8b 55 d4             	mov    -0x2c(%ebp),%edx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003b1:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
  8003b2:	8d 14 92             	lea    (%edx,%edx,4),%edx
  8003b5:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
  8003b9:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8003bc:	8d 58 d0             	lea    -0x30(%eax),%ebx
  8003bf:	83 fb 09             	cmp    $0x9,%ebx
  8003c2:	76 ed                	jbe    8003b1 <vprintfmt+0xa8>
  8003c4:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  8003c7:	eb 29                	jmp    8003f2 <vprintfmt+0xe9>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003c9:	8b 45 14             	mov    0x14(%ebp),%eax
  8003cc:	8d 50 04             	lea    0x4(%eax),%edx
  8003cf:	89 55 14             	mov    %edx,0x14(%ebp)
  8003d2:	8b 00                	mov    (%eax),%eax
  8003d4:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003d7:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8003d9:	eb 17                	jmp    8003f2 <vprintfmt+0xe9>

		case '.':
			if (width < 0)
  8003db:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8003df:	78 85                	js     800366 <vprintfmt+0x5d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003e1:	89 de                	mov    %ebx,%esi
  8003e3:	eb 99                	jmp    80037e <vprintfmt+0x75>
  8003e5:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8003e7:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  8003ee:	eb 8e                	jmp    80037e <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003f0:	89 de                	mov    %ebx,%esi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  8003f2:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8003f6:	79 86                	jns    80037e <vprintfmt+0x75>
  8003f8:	e9 74 ff ff ff       	jmp    800371 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8003fd:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003fe:	89 de                	mov    %ebx,%esi
  800400:	e9 79 ff ff ff       	jmp    80037e <vprintfmt+0x75>
  800405:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800408:	8b 45 14             	mov    0x14(%ebp),%eax
  80040b:	8d 50 04             	lea    0x4(%eax),%edx
  80040e:	89 55 14             	mov    %edx,0x14(%ebp)
  800411:	83 ec 08             	sub    $0x8,%esp
  800414:	57                   	push   %edi
  800415:	ff 30                	pushl  (%eax)
  800417:	ff 55 08             	call   *0x8(%ebp)
			break;
  80041a:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80041d:	8b 75 d8             	mov    -0x28(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800420:	e9 08 ff ff ff       	jmp    80032d <vprintfmt+0x24>
  800425:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  800428:	8b 45 14             	mov    0x14(%ebp),%eax
  80042b:	8d 50 04             	lea    0x4(%eax),%edx
  80042e:	89 55 14             	mov    %edx,0x14(%ebp)
  800431:	8b 00                	mov    (%eax),%eax
  800433:	85 c0                	test   %eax,%eax
  800435:	79 02                	jns    800439 <vprintfmt+0x130>
  800437:	f7 d8                	neg    %eax
  800439:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80043b:	83 f8 08             	cmp    $0x8,%eax
  80043e:	7f 0b                	jg     80044b <vprintfmt+0x142>
  800440:	8b 04 85 c0 15 80 00 	mov    0x8015c0(,%eax,4),%eax
  800447:	85 c0                	test   %eax,%eax
  800449:	75 1a                	jne    800465 <vprintfmt+0x15c>
				printfmt(putch, putdat, "error %d", err);
  80044b:	52                   	push   %edx
  80044c:	68 b8 13 80 00       	push   $0x8013b8
  800451:	57                   	push   %edi
  800452:	ff 75 08             	pushl  0x8(%ebp)
  800455:	e8 92 fe ff ff       	call   8002ec <printfmt>
  80045a:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80045d:	8b 75 d8             	mov    -0x28(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800460:	e9 c8 fe ff ff       	jmp    80032d <vprintfmt+0x24>
			else
				printfmt(putch, putdat, "%s", p);
  800465:	50                   	push   %eax
  800466:	68 c1 13 80 00       	push   $0x8013c1
  80046b:	57                   	push   %edi
  80046c:	ff 75 08             	pushl  0x8(%ebp)
  80046f:	e8 78 fe ff ff       	call   8002ec <printfmt>
  800474:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800477:	8b 75 d8             	mov    -0x28(%ebp),%esi
  80047a:	e9 ae fe ff ff       	jmp    80032d <vprintfmt+0x24>
  80047f:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  800482:	89 de                	mov    %ebx,%esi
  800484:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  800487:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80048a:	8b 45 14             	mov    0x14(%ebp),%eax
  80048d:	8d 50 04             	lea    0x4(%eax),%edx
  800490:	89 55 14             	mov    %edx,0x14(%ebp)
  800493:	8b 00                	mov    (%eax),%eax
  800495:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800498:	85 c0                	test   %eax,%eax
  80049a:	75 07                	jne    8004a3 <vprintfmt+0x19a>
				p = "(null)";
  80049c:	c7 45 d0 b1 13 80 00 	movl   $0x8013b1,-0x30(%ebp)
			if (width > 0 && padc != '-')
  8004a3:	85 db                	test   %ebx,%ebx
  8004a5:	7e 42                	jle    8004e9 <vprintfmt+0x1e0>
  8004a7:	80 7d dc 2d          	cmpb   $0x2d,-0x24(%ebp)
  8004ab:	74 3c                	je     8004e9 <vprintfmt+0x1e0>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004ad:	83 ec 08             	sub    $0x8,%esp
  8004b0:	51                   	push   %ecx
  8004b1:	ff 75 d0             	pushl  -0x30(%ebp)
  8004b4:	e8 6f 02 00 00       	call   800728 <strnlen>
  8004b9:	29 c3                	sub    %eax,%ebx
  8004bb:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8004be:	83 c4 10             	add    $0x10,%esp
  8004c1:	85 db                	test   %ebx,%ebx
  8004c3:	7e 24                	jle    8004e9 <vprintfmt+0x1e0>
					putch(padc, putdat);
  8004c5:	0f be 5d dc          	movsbl -0x24(%ebp),%ebx
  8004c9:	89 75 dc             	mov    %esi,-0x24(%ebp)
  8004cc:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  8004cf:	83 ec 08             	sub    $0x8,%esp
  8004d2:	57                   	push   %edi
  8004d3:	53                   	push   %ebx
  8004d4:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004d7:	4e                   	dec    %esi
  8004d8:	83 c4 10             	add    $0x10,%esp
  8004db:	85 f6                	test   %esi,%esi
  8004dd:	7f f0                	jg     8004cf <vprintfmt+0x1c6>
  8004df:	8b 75 dc             	mov    -0x24(%ebp),%esi
  8004e2:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004e9:	8b 55 d0             	mov    -0x30(%ebp),%edx
  8004ec:	0f be 02             	movsbl (%edx),%eax
  8004ef:	85 c0                	test   %eax,%eax
  8004f1:	75 47                	jne    80053a <vprintfmt+0x231>
  8004f3:	eb 37                	jmp    80052c <vprintfmt+0x223>
				if (altflag && (ch < ' ' || ch > '~'))
  8004f5:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004f9:	74 16                	je     800511 <vprintfmt+0x208>
  8004fb:	8d 50 e0             	lea    -0x20(%eax),%edx
  8004fe:	83 fa 5e             	cmp    $0x5e,%edx
  800501:	76 0e                	jbe    800511 <vprintfmt+0x208>
					putch('?', putdat);
  800503:	83 ec 08             	sub    $0x8,%esp
  800506:	57                   	push   %edi
  800507:	6a 3f                	push   $0x3f
  800509:	ff 55 08             	call   *0x8(%ebp)
  80050c:	83 c4 10             	add    $0x10,%esp
  80050f:	eb 0b                	jmp    80051c <vprintfmt+0x213>
				else
					putch(ch, putdat);
  800511:	83 ec 08             	sub    $0x8,%esp
  800514:	57                   	push   %edi
  800515:	50                   	push   %eax
  800516:	ff 55 08             	call   *0x8(%ebp)
  800519:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80051c:	ff 4d e4             	decl   -0x1c(%ebp)
  80051f:	0f be 03             	movsbl (%ebx),%eax
  800522:	85 c0                	test   %eax,%eax
  800524:	74 03                	je     800529 <vprintfmt+0x220>
  800526:	43                   	inc    %ebx
  800527:	eb 1b                	jmp    800544 <vprintfmt+0x23b>
  800529:	8b 75 dc             	mov    -0x24(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80052c:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800530:	7f 1e                	jg     800550 <vprintfmt+0x247>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800532:	8b 75 d8             	mov    -0x28(%ebp),%esi
  800535:	e9 f3 fd ff ff       	jmp    80032d <vprintfmt+0x24>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80053a:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  80053d:	43                   	inc    %ebx
  80053e:	89 75 dc             	mov    %esi,-0x24(%ebp)
  800541:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  800544:	85 f6                	test   %esi,%esi
  800546:	78 ad                	js     8004f5 <vprintfmt+0x1ec>
  800548:	4e                   	dec    %esi
  800549:	79 aa                	jns    8004f5 <vprintfmt+0x1ec>
  80054b:	8b 75 dc             	mov    -0x24(%ebp),%esi
  80054e:	eb dc                	jmp    80052c <vprintfmt+0x223>
  800550:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800553:	83 ec 08             	sub    $0x8,%esp
  800556:	57                   	push   %edi
  800557:	6a 20                	push   $0x20
  800559:	ff 55 08             	call   *0x8(%ebp)
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80055c:	4b                   	dec    %ebx
  80055d:	83 c4 10             	add    $0x10,%esp
  800560:	85 db                	test   %ebx,%ebx
  800562:	7f ef                	jg     800553 <vprintfmt+0x24a>
  800564:	e9 c4 fd ff ff       	jmp    80032d <vprintfmt+0x24>
  800569:	89 5d d8             	mov    %ebx,-0x28(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80056c:	89 ca                	mov    %ecx,%edx
  80056e:	8d 45 14             	lea    0x14(%ebp),%eax
  800571:	e8 2a fd ff ff       	call   8002a0 <getint>
  800576:	89 c3                	mov    %eax,%ebx
  800578:	89 d6                	mov    %edx,%esi
			if ((long long) num < 0) {
  80057a:	85 d2                	test   %edx,%edx
  80057c:	78 0a                	js     800588 <vprintfmt+0x27f>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80057e:	b8 0a 00 00 00       	mov    $0xa,%eax
  800583:	e9 b0 00 00 00       	jmp    800638 <vprintfmt+0x32f>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  800588:	83 ec 08             	sub    $0x8,%esp
  80058b:	57                   	push   %edi
  80058c:	6a 2d                	push   $0x2d
  80058e:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800591:	f7 db                	neg    %ebx
  800593:	83 d6 00             	adc    $0x0,%esi
  800596:	f7 de                	neg    %esi
  800598:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  80059b:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005a0:	e9 93 00 00 00       	jmp    800638 <vprintfmt+0x32f>
  8005a5:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8005a8:	89 ca                	mov    %ecx,%edx
  8005aa:	8d 45 14             	lea    0x14(%ebp),%eax
  8005ad:	e8 b4 fc ff ff       	call   800266 <getuint>
  8005b2:	89 c3                	mov    %eax,%ebx
  8005b4:	89 d6                	mov    %edx,%esi
			base = 10;
  8005b6:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  8005bb:	eb 7b                	jmp    800638 <vprintfmt+0x32f>
  8005bd:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
  8005c0:	89 ca                	mov    %ecx,%edx
  8005c2:	8d 45 14             	lea    0x14(%ebp),%eax
  8005c5:	e8 d6 fc ff ff       	call   8002a0 <getint>
  8005ca:	89 c3                	mov    %eax,%ebx
  8005cc:	89 d6                	mov    %edx,%esi
            if ((long long) num < 0) {
  8005ce:	85 d2                	test   %edx,%edx
  8005d0:	78 07                	js     8005d9 <vprintfmt+0x2d0>
                putch('-', putdat);
                num = -(long long) num;
            }
            base = 8;
  8005d2:	b8 08 00 00 00       	mov    $0x8,%eax
  8005d7:	eb 5f                	jmp    800638 <vprintfmt+0x32f>
		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
            if ((long long) num < 0) {
                putch('-', putdat);
  8005d9:	83 ec 08             	sub    $0x8,%esp
  8005dc:	57                   	push   %edi
  8005dd:	6a 2d                	push   $0x2d
  8005df:	ff 55 08             	call   *0x8(%ebp)
                num = -(long long) num;
  8005e2:	f7 db                	neg    %ebx
  8005e4:	83 d6 00             	adc    $0x0,%esi
  8005e7:	f7 de                	neg    %esi
  8005e9:	83 c4 10             	add    $0x10,%esp
            }
            base = 8;
  8005ec:	b8 08 00 00 00       	mov    $0x8,%eax
  8005f1:	eb 45                	jmp    800638 <vprintfmt+0x32f>
  8005f3:	89 5d d8             	mov    %ebx,-0x28(%ebp)
            goto number;

        // pointer
		case 'p':
			putch('0', putdat);
  8005f6:	83 ec 08             	sub    $0x8,%esp
  8005f9:	57                   	push   %edi
  8005fa:	6a 30                	push   $0x30
  8005fc:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8005ff:	83 c4 08             	add    $0x8,%esp
  800602:	57                   	push   %edi
  800603:	6a 78                	push   $0x78
  800605:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800608:	8b 45 14             	mov    0x14(%ebp),%eax
  80060b:	8d 50 04             	lea    0x4(%eax),%edx
  80060e:	89 55 14             	mov    %edx,0x14(%ebp)

        // pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800611:	8b 18                	mov    (%eax),%ebx
  800613:	be 00 00 00 00       	mov    $0x0,%esi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800618:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80061b:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800620:	eb 16                	jmp    800638 <vprintfmt+0x32f>
  800622:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800625:	89 ca                	mov    %ecx,%edx
  800627:	8d 45 14             	lea    0x14(%ebp),%eax
  80062a:	e8 37 fc ff ff       	call   800266 <getuint>
  80062f:	89 c3                	mov    %eax,%ebx
  800631:	89 d6                	mov    %edx,%esi
			base = 16;
  800633:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800638:	83 ec 0c             	sub    $0xc,%esp
  80063b:	0f be 55 dc          	movsbl -0x24(%ebp),%edx
  80063f:	52                   	push   %edx
  800640:	ff 75 e4             	pushl  -0x1c(%ebp)
  800643:	50                   	push   %eax
  800644:	56                   	push   %esi
  800645:	53                   	push   %ebx
  800646:	89 fa                	mov    %edi,%edx
  800648:	8b 45 08             	mov    0x8(%ebp),%eax
  80064b:	e8 68 fb ff ff       	call   8001b8 <printnum>
			break;
  800650:	83 c4 20             	add    $0x20,%esp
  800653:	8b 75 d8             	mov    -0x28(%ebp),%esi
  800656:	e9 d2 fc ff ff       	jmp    80032d <vprintfmt+0x24>
  80065b:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80065e:	83 ec 08             	sub    $0x8,%esp
  800661:	57                   	push   %edi
  800662:	52                   	push   %edx
  800663:	ff 55 08             	call   *0x8(%ebp)
			break;
  800666:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800669:	8b 75 d8             	mov    -0x28(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80066c:	e9 bc fc ff ff       	jmp    80032d <vprintfmt+0x24>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800671:	83 ec 08             	sub    $0x8,%esp
  800674:	57                   	push   %edi
  800675:	6a 25                	push   $0x25
  800677:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  80067a:	83 c4 10             	add    $0x10,%esp
  80067d:	eb 02                	jmp    800681 <vprintfmt+0x378>
  80067f:	89 c6                	mov    %eax,%esi
  800681:	8d 46 ff             	lea    -0x1(%esi),%eax
  800684:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800688:	75 f5                	jne    80067f <vprintfmt+0x376>
  80068a:	e9 9e fc ff ff       	jmp    80032d <vprintfmt+0x24>
				/* do nothing */;
			break;
		}
	}
}
  80068f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800692:	5b                   	pop    %ebx
  800693:	5e                   	pop    %esi
  800694:	5f                   	pop    %edi
  800695:	c9                   	leave  
  800696:	c3                   	ret    

00800697 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800697:	55                   	push   %ebp
  800698:	89 e5                	mov    %esp,%ebp
  80069a:	83 ec 18             	sub    $0x18,%esp
  80069d:	8b 45 08             	mov    0x8(%ebp),%eax
  8006a0:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006a3:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006a6:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8006aa:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8006ad:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8006b4:	85 c0                	test   %eax,%eax
  8006b6:	74 26                	je     8006de <vsnprintf+0x47>
  8006b8:	85 d2                	test   %edx,%edx
  8006ba:	7e 29                	jle    8006e5 <vsnprintf+0x4e>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8006bc:	ff 75 14             	pushl  0x14(%ebp)
  8006bf:	ff 75 10             	pushl  0x10(%ebp)
  8006c2:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8006c5:	50                   	push   %eax
  8006c6:	68 d2 02 80 00       	push   $0x8002d2
  8006cb:	e8 39 fc ff ff       	call   800309 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8006d0:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8006d3:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8006d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006d9:	83 c4 10             	add    $0x10,%esp
  8006dc:	eb 0c                	jmp    8006ea <vsnprintf+0x53>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8006de:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8006e3:	eb 05                	jmp    8006ea <vsnprintf+0x53>
  8006e5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8006ea:	c9                   	leave  
  8006eb:	c3                   	ret    

008006ec <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8006ec:	55                   	push   %ebp
  8006ed:	89 e5                	mov    %esp,%ebp
  8006ef:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8006f2:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8006f5:	50                   	push   %eax
  8006f6:	ff 75 10             	pushl  0x10(%ebp)
  8006f9:	ff 75 0c             	pushl  0xc(%ebp)
  8006fc:	ff 75 08             	pushl  0x8(%ebp)
  8006ff:	e8 93 ff ff ff       	call   800697 <vsnprintf>
	va_end(ap);

	return rc;
}
  800704:	c9                   	leave  
  800705:	c3                   	ret    
	...

00800708 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800708:	55                   	push   %ebp
  800709:	89 e5                	mov    %esp,%ebp
  80070b:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80070e:	80 3a 00             	cmpb   $0x0,(%edx)
  800711:	74 0e                	je     800721 <strlen+0x19>
  800713:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800718:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800719:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80071d:	75 f9                	jne    800718 <strlen+0x10>
  80071f:	eb 05                	jmp    800726 <strlen+0x1e>
  800721:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800726:	c9                   	leave  
  800727:	c3                   	ret    

00800728 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800728:	55                   	push   %ebp
  800729:	89 e5                	mov    %esp,%ebp
  80072b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80072e:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800731:	85 d2                	test   %edx,%edx
  800733:	74 17                	je     80074c <strnlen+0x24>
  800735:	80 39 00             	cmpb   $0x0,(%ecx)
  800738:	74 19                	je     800753 <strnlen+0x2b>
  80073a:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  80073f:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800740:	39 d0                	cmp    %edx,%eax
  800742:	74 14                	je     800758 <strnlen+0x30>
  800744:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800748:	75 f5                	jne    80073f <strnlen+0x17>
  80074a:	eb 0c                	jmp    800758 <strnlen+0x30>
  80074c:	b8 00 00 00 00       	mov    $0x0,%eax
  800751:	eb 05                	jmp    800758 <strnlen+0x30>
  800753:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800758:	c9                   	leave  
  800759:	c3                   	ret    

0080075a <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80075a:	55                   	push   %ebp
  80075b:	89 e5                	mov    %esp,%ebp
  80075d:	53                   	push   %ebx
  80075e:	8b 45 08             	mov    0x8(%ebp),%eax
  800761:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800764:	ba 00 00 00 00       	mov    $0x0,%edx
  800769:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  80076c:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  80076f:	42                   	inc    %edx
  800770:	84 c9                	test   %cl,%cl
  800772:	75 f5                	jne    800769 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800774:	5b                   	pop    %ebx
  800775:	c9                   	leave  
  800776:	c3                   	ret    

00800777 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800777:	55                   	push   %ebp
  800778:	89 e5                	mov    %esp,%ebp
  80077a:	53                   	push   %ebx
  80077b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80077e:	53                   	push   %ebx
  80077f:	e8 84 ff ff ff       	call   800708 <strlen>
  800784:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800787:	ff 75 0c             	pushl  0xc(%ebp)
  80078a:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  80078d:	50                   	push   %eax
  80078e:	e8 c7 ff ff ff       	call   80075a <strcpy>
	return dst;
}
  800793:	89 d8                	mov    %ebx,%eax
  800795:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800798:	c9                   	leave  
  800799:	c3                   	ret    

0080079a <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80079a:	55                   	push   %ebp
  80079b:	89 e5                	mov    %esp,%ebp
  80079d:	56                   	push   %esi
  80079e:	53                   	push   %ebx
  80079f:	8b 45 08             	mov    0x8(%ebp),%eax
  8007a2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007a5:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007a8:	85 f6                	test   %esi,%esi
  8007aa:	74 15                	je     8007c1 <strncpy+0x27>
  8007ac:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  8007b1:	8a 1a                	mov    (%edx),%bl
  8007b3:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007b6:	80 3a 01             	cmpb   $0x1,(%edx)
  8007b9:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007bc:	41                   	inc    %ecx
  8007bd:	39 ce                	cmp    %ecx,%esi
  8007bf:	77 f0                	ja     8007b1 <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8007c1:	5b                   	pop    %ebx
  8007c2:	5e                   	pop    %esi
  8007c3:	c9                   	leave  
  8007c4:	c3                   	ret    

008007c5 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8007c5:	55                   	push   %ebp
  8007c6:	89 e5                	mov    %esp,%ebp
  8007c8:	57                   	push   %edi
  8007c9:	56                   	push   %esi
  8007ca:	53                   	push   %ebx
  8007cb:	8b 7d 08             	mov    0x8(%ebp),%edi
  8007ce:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8007d1:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007d4:	85 f6                	test   %esi,%esi
  8007d6:	74 32                	je     80080a <strlcpy+0x45>
		while (--size > 0 && *src != '\0')
  8007d8:	83 fe 01             	cmp    $0x1,%esi
  8007db:	74 22                	je     8007ff <strlcpy+0x3a>
  8007dd:	8a 0b                	mov    (%ebx),%cl
  8007df:	84 c9                	test   %cl,%cl
  8007e1:	74 20                	je     800803 <strlcpy+0x3e>
  8007e3:	89 f8                	mov    %edi,%eax
  8007e5:	ba 00 00 00 00       	mov    $0x0,%edx
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
  8007ea:	83 ee 02             	sub    $0x2,%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8007ed:	88 08                	mov    %cl,(%eax)
  8007ef:	40                   	inc    %eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8007f0:	39 f2                	cmp    %esi,%edx
  8007f2:	74 11                	je     800805 <strlcpy+0x40>
  8007f4:	8a 4c 13 01          	mov    0x1(%ebx,%edx,1),%cl
  8007f8:	42                   	inc    %edx
  8007f9:	84 c9                	test   %cl,%cl
  8007fb:	75 f0                	jne    8007ed <strlcpy+0x28>
  8007fd:	eb 06                	jmp    800805 <strlcpy+0x40>
  8007ff:	89 f8                	mov    %edi,%eax
  800801:	eb 02                	jmp    800805 <strlcpy+0x40>
  800803:	89 f8                	mov    %edi,%eax
			*dst++ = *src++;
		*dst = '\0';
  800805:	c6 00 00             	movb   $0x0,(%eax)
  800808:	eb 02                	jmp    80080c <strlcpy+0x47>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80080a:	89 f8                	mov    %edi,%eax
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
		*dst = '\0';
	}
	return dst - dst_in;
  80080c:	29 f8                	sub    %edi,%eax
}
  80080e:	5b                   	pop    %ebx
  80080f:	5e                   	pop    %esi
  800810:	5f                   	pop    %edi
  800811:	c9                   	leave  
  800812:	c3                   	ret    

00800813 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800813:	55                   	push   %ebp
  800814:	89 e5                	mov    %esp,%ebp
  800816:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800819:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80081c:	8a 01                	mov    (%ecx),%al
  80081e:	84 c0                	test   %al,%al
  800820:	74 10                	je     800832 <strcmp+0x1f>
  800822:	3a 02                	cmp    (%edx),%al
  800824:	75 0c                	jne    800832 <strcmp+0x1f>
		p++, q++;
  800826:	41                   	inc    %ecx
  800827:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800828:	8a 01                	mov    (%ecx),%al
  80082a:	84 c0                	test   %al,%al
  80082c:	74 04                	je     800832 <strcmp+0x1f>
  80082e:	3a 02                	cmp    (%edx),%al
  800830:	74 f4                	je     800826 <strcmp+0x13>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800832:	0f b6 c0             	movzbl %al,%eax
  800835:	0f b6 12             	movzbl (%edx),%edx
  800838:	29 d0                	sub    %edx,%eax
}
  80083a:	c9                   	leave  
  80083b:	c3                   	ret    

0080083c <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80083c:	55                   	push   %ebp
  80083d:	89 e5                	mov    %esp,%ebp
  80083f:	53                   	push   %ebx
  800840:	8b 55 08             	mov    0x8(%ebp),%edx
  800843:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800846:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  800849:	85 c0                	test   %eax,%eax
  80084b:	74 1b                	je     800868 <strncmp+0x2c>
  80084d:	8a 1a                	mov    (%edx),%bl
  80084f:	84 db                	test   %bl,%bl
  800851:	74 24                	je     800877 <strncmp+0x3b>
  800853:	3a 19                	cmp    (%ecx),%bl
  800855:	75 20                	jne    800877 <strncmp+0x3b>
  800857:	48                   	dec    %eax
  800858:	74 15                	je     80086f <strncmp+0x33>
		n--, p++, q++;
  80085a:	42                   	inc    %edx
  80085b:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80085c:	8a 1a                	mov    (%edx),%bl
  80085e:	84 db                	test   %bl,%bl
  800860:	74 15                	je     800877 <strncmp+0x3b>
  800862:	3a 19                	cmp    (%ecx),%bl
  800864:	74 f1                	je     800857 <strncmp+0x1b>
  800866:	eb 0f                	jmp    800877 <strncmp+0x3b>
		n--, p++, q++;
	if (n == 0)
		return 0;
  800868:	b8 00 00 00 00       	mov    $0x0,%eax
  80086d:	eb 05                	jmp    800874 <strncmp+0x38>
  80086f:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800874:	5b                   	pop    %ebx
  800875:	c9                   	leave  
  800876:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800877:	0f b6 02             	movzbl (%edx),%eax
  80087a:	0f b6 11             	movzbl (%ecx),%edx
  80087d:	29 d0                	sub    %edx,%eax
  80087f:	eb f3                	jmp    800874 <strncmp+0x38>

00800881 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800881:	55                   	push   %ebp
  800882:	89 e5                	mov    %esp,%ebp
  800884:	8b 45 08             	mov    0x8(%ebp),%eax
  800887:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  80088a:	8a 10                	mov    (%eax),%dl
  80088c:	84 d2                	test   %dl,%dl
  80088e:	74 18                	je     8008a8 <strchr+0x27>
		if (*s == c)
  800890:	38 ca                	cmp    %cl,%dl
  800892:	75 06                	jne    80089a <strchr+0x19>
  800894:	eb 17                	jmp    8008ad <strchr+0x2c>
  800896:	38 ca                	cmp    %cl,%dl
  800898:	74 13                	je     8008ad <strchr+0x2c>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80089a:	40                   	inc    %eax
  80089b:	8a 10                	mov    (%eax),%dl
  80089d:	84 d2                	test   %dl,%dl
  80089f:	75 f5                	jne    800896 <strchr+0x15>
		if (*s == c)
			return (char *) s;
	return 0;
  8008a1:	b8 00 00 00 00       	mov    $0x0,%eax
  8008a6:	eb 05                	jmp    8008ad <strchr+0x2c>
  8008a8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008ad:	c9                   	leave  
  8008ae:	c3                   	ret    

008008af <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008af:	55                   	push   %ebp
  8008b0:	89 e5                	mov    %esp,%ebp
  8008b2:	8b 45 08             	mov    0x8(%ebp),%eax
  8008b5:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8008b8:	8a 10                	mov    (%eax),%dl
  8008ba:	84 d2                	test   %dl,%dl
  8008bc:	74 11                	je     8008cf <strfind+0x20>
		if (*s == c)
  8008be:	38 ca                	cmp    %cl,%dl
  8008c0:	75 06                	jne    8008c8 <strfind+0x19>
  8008c2:	eb 0b                	jmp    8008cf <strfind+0x20>
  8008c4:	38 ca                	cmp    %cl,%dl
  8008c6:	74 07                	je     8008cf <strfind+0x20>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  8008c8:	40                   	inc    %eax
  8008c9:	8a 10                	mov    (%eax),%dl
  8008cb:	84 d2                	test   %dl,%dl
  8008cd:	75 f5                	jne    8008c4 <strfind+0x15>
		if (*s == c)
			break;
	return (char *) s;
}
  8008cf:	c9                   	leave  
  8008d0:	c3                   	ret    

008008d1 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008d1:	55                   	push   %ebp
  8008d2:	89 e5                	mov    %esp,%ebp
  8008d4:	57                   	push   %edi
  8008d5:	56                   	push   %esi
  8008d6:	53                   	push   %ebx
  8008d7:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008da:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008dd:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8008e0:	85 c9                	test   %ecx,%ecx
  8008e2:	74 30                	je     800914 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008e4:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008ea:	75 25                	jne    800911 <memset+0x40>
  8008ec:	f6 c1 03             	test   $0x3,%cl
  8008ef:	75 20                	jne    800911 <memset+0x40>
		c &= 0xFF;
  8008f1:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8008f4:	89 d3                	mov    %edx,%ebx
  8008f6:	c1 e3 08             	shl    $0x8,%ebx
  8008f9:	89 d6                	mov    %edx,%esi
  8008fb:	c1 e6 18             	shl    $0x18,%esi
  8008fe:	89 d0                	mov    %edx,%eax
  800900:	c1 e0 10             	shl    $0x10,%eax
  800903:	09 f0                	or     %esi,%eax
  800905:	09 d0                	or     %edx,%eax
  800907:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800909:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  80090c:	fc                   	cld    
  80090d:	f3 ab                	rep stos %eax,%es:(%edi)
  80090f:	eb 03                	jmp    800914 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800911:	fc                   	cld    
  800912:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800914:	89 f8                	mov    %edi,%eax
  800916:	5b                   	pop    %ebx
  800917:	5e                   	pop    %esi
  800918:	5f                   	pop    %edi
  800919:	c9                   	leave  
  80091a:	c3                   	ret    

0080091b <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80091b:	55                   	push   %ebp
  80091c:	89 e5                	mov    %esp,%ebp
  80091e:	57                   	push   %edi
  80091f:	56                   	push   %esi
  800920:	8b 45 08             	mov    0x8(%ebp),%eax
  800923:	8b 75 0c             	mov    0xc(%ebp),%esi
  800926:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800929:	39 c6                	cmp    %eax,%esi
  80092b:	73 34                	jae    800961 <memmove+0x46>
  80092d:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800930:	39 d0                	cmp    %edx,%eax
  800932:	73 2d                	jae    800961 <memmove+0x46>
		s += n;
		d += n;
  800934:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800937:	f6 c2 03             	test   $0x3,%dl
  80093a:	75 1b                	jne    800957 <memmove+0x3c>
  80093c:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800942:	75 13                	jne    800957 <memmove+0x3c>
  800944:	f6 c1 03             	test   $0x3,%cl
  800947:	75 0e                	jne    800957 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800949:	83 ef 04             	sub    $0x4,%edi
  80094c:	8d 72 fc             	lea    -0x4(%edx),%esi
  80094f:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800952:	fd                   	std    
  800953:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800955:	eb 07                	jmp    80095e <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800957:	4f                   	dec    %edi
  800958:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  80095b:	fd                   	std    
  80095c:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80095e:	fc                   	cld    
  80095f:	eb 20                	jmp    800981 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800961:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800967:	75 13                	jne    80097c <memmove+0x61>
  800969:	a8 03                	test   $0x3,%al
  80096b:	75 0f                	jne    80097c <memmove+0x61>
  80096d:	f6 c1 03             	test   $0x3,%cl
  800970:	75 0a                	jne    80097c <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800972:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800975:	89 c7                	mov    %eax,%edi
  800977:	fc                   	cld    
  800978:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80097a:	eb 05                	jmp    800981 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  80097c:	89 c7                	mov    %eax,%edi
  80097e:	fc                   	cld    
  80097f:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800981:	5e                   	pop    %esi
  800982:	5f                   	pop    %edi
  800983:	c9                   	leave  
  800984:	c3                   	ret    

00800985 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800985:	55                   	push   %ebp
  800986:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800988:	ff 75 10             	pushl  0x10(%ebp)
  80098b:	ff 75 0c             	pushl  0xc(%ebp)
  80098e:	ff 75 08             	pushl  0x8(%ebp)
  800991:	e8 85 ff ff ff       	call   80091b <memmove>
}
  800996:	c9                   	leave  
  800997:	c3                   	ret    

00800998 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800998:	55                   	push   %ebp
  800999:	89 e5                	mov    %esp,%ebp
  80099b:	57                   	push   %edi
  80099c:	56                   	push   %esi
  80099d:	53                   	push   %ebx
  80099e:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8009a1:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009a4:	8b 7d 10             	mov    0x10(%ebp),%edi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009a7:	85 ff                	test   %edi,%edi
  8009a9:	74 32                	je     8009dd <memcmp+0x45>
		if (*s1 != *s2)
  8009ab:	8a 03                	mov    (%ebx),%al
  8009ad:	8a 0e                	mov    (%esi),%cl
  8009af:	38 c8                	cmp    %cl,%al
  8009b1:	74 19                	je     8009cc <memcmp+0x34>
  8009b3:	eb 0d                	jmp    8009c2 <memcmp+0x2a>
  8009b5:	8a 44 13 01          	mov    0x1(%ebx,%edx,1),%al
  8009b9:	8a 4c 16 01          	mov    0x1(%esi,%edx,1),%cl
  8009bd:	42                   	inc    %edx
  8009be:	38 c8                	cmp    %cl,%al
  8009c0:	74 10                	je     8009d2 <memcmp+0x3a>
			return (int) *s1 - (int) *s2;
  8009c2:	0f b6 c0             	movzbl %al,%eax
  8009c5:	0f b6 c9             	movzbl %cl,%ecx
  8009c8:	29 c8                	sub    %ecx,%eax
  8009ca:	eb 16                	jmp    8009e2 <memcmp+0x4a>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009cc:	4f                   	dec    %edi
  8009cd:	ba 00 00 00 00       	mov    $0x0,%edx
  8009d2:	39 fa                	cmp    %edi,%edx
  8009d4:	75 df                	jne    8009b5 <memcmp+0x1d>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8009d6:	b8 00 00 00 00       	mov    $0x0,%eax
  8009db:	eb 05                	jmp    8009e2 <memcmp+0x4a>
  8009dd:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009e2:	5b                   	pop    %ebx
  8009e3:	5e                   	pop    %esi
  8009e4:	5f                   	pop    %edi
  8009e5:	c9                   	leave  
  8009e6:	c3                   	ret    

008009e7 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009e7:	55                   	push   %ebp
  8009e8:	89 e5                	mov    %esp,%ebp
  8009ea:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  8009ed:	89 c2                	mov    %eax,%edx
  8009ef:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  8009f2:	39 d0                	cmp    %edx,%eax
  8009f4:	73 12                	jae    800a08 <memfind+0x21>
		if (*(const unsigned char *) s == (unsigned char) c)
  8009f6:	8a 4d 0c             	mov    0xc(%ebp),%cl
  8009f9:	38 08                	cmp    %cl,(%eax)
  8009fb:	75 06                	jne    800a03 <memfind+0x1c>
  8009fd:	eb 09                	jmp    800a08 <memfind+0x21>
  8009ff:	38 08                	cmp    %cl,(%eax)
  800a01:	74 05                	je     800a08 <memfind+0x21>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a03:	40                   	inc    %eax
  800a04:	39 c2                	cmp    %eax,%edx
  800a06:	77 f7                	ja     8009ff <memfind+0x18>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a08:	c9                   	leave  
  800a09:	c3                   	ret    

00800a0a <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a0a:	55                   	push   %ebp
  800a0b:	89 e5                	mov    %esp,%ebp
  800a0d:	57                   	push   %edi
  800a0e:	56                   	push   %esi
  800a0f:	53                   	push   %ebx
  800a10:	8b 55 08             	mov    0x8(%ebp),%edx
  800a13:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a16:	eb 01                	jmp    800a19 <strtol+0xf>
		s++;
  800a18:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a19:	8a 02                	mov    (%edx),%al
  800a1b:	3c 20                	cmp    $0x20,%al
  800a1d:	74 f9                	je     800a18 <strtol+0xe>
  800a1f:	3c 09                	cmp    $0x9,%al
  800a21:	74 f5                	je     800a18 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a23:	3c 2b                	cmp    $0x2b,%al
  800a25:	75 08                	jne    800a2f <strtol+0x25>
		s++;
  800a27:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a28:	bf 00 00 00 00       	mov    $0x0,%edi
  800a2d:	eb 13                	jmp    800a42 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a2f:	3c 2d                	cmp    $0x2d,%al
  800a31:	75 0a                	jne    800a3d <strtol+0x33>
		s++, neg = 1;
  800a33:	8d 52 01             	lea    0x1(%edx),%edx
  800a36:	bf 01 00 00 00       	mov    $0x1,%edi
  800a3b:	eb 05                	jmp    800a42 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a3d:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a42:	85 db                	test   %ebx,%ebx
  800a44:	74 05                	je     800a4b <strtol+0x41>
  800a46:	83 fb 10             	cmp    $0x10,%ebx
  800a49:	75 28                	jne    800a73 <strtol+0x69>
  800a4b:	8a 02                	mov    (%edx),%al
  800a4d:	3c 30                	cmp    $0x30,%al
  800a4f:	75 10                	jne    800a61 <strtol+0x57>
  800a51:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800a55:	75 0a                	jne    800a61 <strtol+0x57>
		s += 2, base = 16;
  800a57:	83 c2 02             	add    $0x2,%edx
  800a5a:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a5f:	eb 12                	jmp    800a73 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800a61:	85 db                	test   %ebx,%ebx
  800a63:	75 0e                	jne    800a73 <strtol+0x69>
  800a65:	3c 30                	cmp    $0x30,%al
  800a67:	75 05                	jne    800a6e <strtol+0x64>
		s++, base = 8;
  800a69:	42                   	inc    %edx
  800a6a:	b3 08                	mov    $0x8,%bl
  800a6c:	eb 05                	jmp    800a73 <strtol+0x69>
	else if (base == 0)
		base = 10;
  800a6e:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800a73:	b8 00 00 00 00       	mov    $0x0,%eax
  800a78:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a7a:	8a 0a                	mov    (%edx),%cl
  800a7c:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800a7f:	80 fb 09             	cmp    $0x9,%bl
  800a82:	77 08                	ja     800a8c <strtol+0x82>
			dig = *s - '0';
  800a84:	0f be c9             	movsbl %cl,%ecx
  800a87:	83 e9 30             	sub    $0x30,%ecx
  800a8a:	eb 1e                	jmp    800aaa <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800a8c:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800a8f:	80 fb 19             	cmp    $0x19,%bl
  800a92:	77 08                	ja     800a9c <strtol+0x92>
			dig = *s - 'a' + 10;
  800a94:	0f be c9             	movsbl %cl,%ecx
  800a97:	83 e9 57             	sub    $0x57,%ecx
  800a9a:	eb 0e                	jmp    800aaa <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800a9c:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800a9f:	80 fb 19             	cmp    $0x19,%bl
  800aa2:	77 13                	ja     800ab7 <strtol+0xad>
			dig = *s - 'A' + 10;
  800aa4:	0f be c9             	movsbl %cl,%ecx
  800aa7:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800aaa:	39 f1                	cmp    %esi,%ecx
  800aac:	7d 0d                	jge    800abb <strtol+0xb1>
			break;
		s++, val = (val * base) + dig;
  800aae:	42                   	inc    %edx
  800aaf:	0f af c6             	imul   %esi,%eax
  800ab2:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  800ab5:	eb c3                	jmp    800a7a <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800ab7:	89 c1                	mov    %eax,%ecx
  800ab9:	eb 02                	jmp    800abd <strtol+0xb3>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800abb:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800abd:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ac1:	74 05                	je     800ac8 <strtol+0xbe>
		*endptr = (char *) s;
  800ac3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800ac6:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800ac8:	85 ff                	test   %edi,%edi
  800aca:	74 04                	je     800ad0 <strtol+0xc6>
  800acc:	89 c8                	mov    %ecx,%eax
  800ace:	f7 d8                	neg    %eax
}
  800ad0:	5b                   	pop    %ebx
  800ad1:	5e                   	pop    %esi
  800ad2:	5f                   	pop    %edi
  800ad3:	c9                   	leave  
  800ad4:	c3                   	ret    
  800ad5:	00 00                	add    %al,(%eax)
	...

00800ad8 <syscall>:
	return ret;
}

static int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800ad8:	55                   	push   %ebp
  800ad9:	89 e5                	mov    %esp,%ebp
  800adb:	57                   	push   %edi
  800adc:	56                   	push   %esi
  800add:	53                   	push   %ebx
  800ade:	83 ec 1c             	sub    $0x1c,%esp
  800ae1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800ae4:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800ae7:	89 ca                	mov    %ecx,%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ae9:	8b 75 14             	mov    0x14(%ebp),%esi
  800aec:	8b 7d 10             	mov    0x10(%ebp),%edi
  800aef:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800af2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800af5:	cd 30                	int    $0x30
  800af7:	89 c2                	mov    %eax,%edx
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800af9:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800afd:	74 1c                	je     800b1b <syscall+0x43>
  800aff:	85 c0                	test   %eax,%eax
  800b01:	7e 18                	jle    800b1b <syscall+0x43>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b03:	83 ec 0c             	sub    $0xc,%esp
  800b06:	50                   	push   %eax
  800b07:	ff 75 e4             	pushl  -0x1c(%ebp)
  800b0a:	68 e4 15 80 00       	push   $0x8015e4
  800b0f:	6a 42                	push   $0x42
  800b11:	68 01 16 80 00       	push   $0x801601
  800b16:	e8 b1 04 00 00       	call   800fcc <_panic>

	return ret;
}
  800b1b:	89 d0                	mov    %edx,%eax
  800b1d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b20:	5b                   	pop    %ebx
  800b21:	5e                   	pop    %esi
  800b22:	5f                   	pop    %edi
  800b23:	c9                   	leave  
  800b24:	c3                   	ret    

00800b25 <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{	
  800b25:	55                   	push   %ebp
  800b26:	89 e5                	mov    %esp,%ebp
  800b28:	83 ec 08             	sub    $0x8,%esp
	// my_sysenter(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
	// return;
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  800b2b:	6a 00                	push   $0x0
  800b2d:	6a 00                	push   $0x0
  800b2f:	6a 00                	push   $0x0
  800b31:	ff 75 0c             	pushl  0xc(%ebp)
  800b34:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b37:	ba 00 00 00 00       	mov    $0x0,%edx
  800b3c:	b8 00 00 00 00       	mov    $0x0,%eax
  800b41:	e8 92 ff ff ff       	call   800ad8 <syscall>
  800b46:	83 c4 10             	add    $0x10,%esp
	return;
}
  800b49:	c9                   	leave  
  800b4a:	c3                   	ret    

00800b4b <sys_cgetc>:

int
sys_cgetc(void)
{
  800b4b:	55                   	push   %ebp
  800b4c:	89 e5                	mov    %esp,%ebp
  800b4e:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_cgetc, 0, 0, 0, 0, 0, 0);
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  800b51:	6a 00                	push   $0x0
  800b53:	6a 00                	push   $0x0
  800b55:	6a 00                	push   $0x0
  800b57:	6a 00                	push   $0x0
  800b59:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b5e:	ba 00 00 00 00       	mov    $0x0,%edx
  800b63:	b8 01 00 00 00       	mov    $0x1,%eax
  800b68:	e8 6b ff ff ff       	call   800ad8 <syscall>
}
  800b6d:	c9                   	leave  
  800b6e:	c3                   	ret    

00800b6f <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b6f:	55                   	push   %ebp
  800b70:	89 e5                	mov    %esp,%ebp
  800b72:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  800b75:	6a 00                	push   $0x0
  800b77:	6a 00                	push   $0x0
  800b79:	6a 00                	push   $0x0
  800b7b:	6a 00                	push   $0x0
  800b7d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b80:	ba 01 00 00 00       	mov    $0x1,%edx
  800b85:	b8 03 00 00 00       	mov    $0x3,%eax
  800b8a:	e8 49 ff ff ff       	call   800ad8 <syscall>
}
  800b8f:	c9                   	leave  
  800b90:	c3                   	ret    

00800b91 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b91:	55                   	push   %ebp
  800b92:	89 e5                	mov    %esp,%ebp
  800b94:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_getenvid, 0, 0, 0, 0, 0, 0);
	return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  800b97:	6a 00                	push   $0x0
  800b99:	6a 00                	push   $0x0
  800b9b:	6a 00                	push   $0x0
  800b9d:	6a 00                	push   $0x0
  800b9f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ba4:	ba 00 00 00 00       	mov    $0x0,%edx
  800ba9:	b8 02 00 00 00       	mov    $0x2,%eax
  800bae:	e8 25 ff ff ff       	call   800ad8 <syscall>
}
  800bb3:	c9                   	leave  
  800bb4:	c3                   	ret    

00800bb5 <sys_yield>:

void
sys_yield(void)
{
  800bb5:	55                   	push   %ebp
  800bb6:	89 e5                	mov    %esp,%ebp
  800bb8:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  800bbb:	6a 00                	push   $0x0
  800bbd:	6a 00                	push   $0x0
  800bbf:	6a 00                	push   $0x0
  800bc1:	6a 00                	push   $0x0
  800bc3:	b9 00 00 00 00       	mov    $0x0,%ecx
  800bc8:	ba 00 00 00 00       	mov    $0x0,%edx
  800bcd:	b8 0a 00 00 00       	mov    $0xa,%eax
  800bd2:	e8 01 ff ff ff       	call   800ad8 <syscall>
  800bd7:	83 c4 10             	add    $0x10,%esp
}
  800bda:	c9                   	leave  
  800bdb:	c3                   	ret    

00800bdc <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800bdc:	55                   	push   %ebp
  800bdd:	89 e5                	mov    %esp,%ebp
  800bdf:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  800be2:	6a 00                	push   $0x0
  800be4:	6a 00                	push   $0x0
  800be6:	ff 75 10             	pushl  0x10(%ebp)
  800be9:	ff 75 0c             	pushl  0xc(%ebp)
  800bec:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800bef:	ba 01 00 00 00       	mov    $0x1,%edx
  800bf4:	b8 04 00 00 00       	mov    $0x4,%eax
  800bf9:	e8 da fe ff ff       	call   800ad8 <syscall>
}
  800bfe:	c9                   	leave  
  800bff:	c3                   	ret    

00800c00 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c00:	55                   	push   %ebp
  800c01:	89 e5                	mov    %esp,%ebp
  800c03:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
  800c06:	ff 75 18             	pushl  0x18(%ebp)
  800c09:	ff 75 14             	pushl  0x14(%ebp)
  800c0c:	ff 75 10             	pushl  0x10(%ebp)
  800c0f:	ff 75 0c             	pushl  0xc(%ebp)
  800c12:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c15:	ba 01 00 00 00       	mov    $0x1,%edx
  800c1a:	b8 05 00 00 00       	mov    $0x5,%eax
  800c1f:	e8 b4 fe ff ff       	call   800ad8 <syscall>
}
  800c24:	c9                   	leave  
  800c25:	c3                   	ret    

00800c26 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c26:	55                   	push   %ebp
  800c27:	89 e5                	mov    %esp,%ebp
  800c29:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  800c2c:	6a 00                	push   $0x0
  800c2e:	6a 00                	push   $0x0
  800c30:	6a 00                	push   $0x0
  800c32:	ff 75 0c             	pushl  0xc(%ebp)
  800c35:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c38:	ba 01 00 00 00       	mov    $0x1,%edx
  800c3d:	b8 06 00 00 00       	mov    $0x6,%eax
  800c42:	e8 91 fe ff ff       	call   800ad8 <syscall>
}
  800c47:	c9                   	leave  
  800c48:	c3                   	ret    

00800c49 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c49:	55                   	push   %ebp
  800c4a:	89 e5                	mov    %esp,%ebp
  800c4c:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  800c4f:	6a 00                	push   $0x0
  800c51:	6a 00                	push   $0x0
  800c53:	6a 00                	push   $0x0
  800c55:	ff 75 0c             	pushl  0xc(%ebp)
  800c58:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c5b:	ba 01 00 00 00       	mov    $0x1,%edx
  800c60:	b8 08 00 00 00       	mov    $0x8,%eax
  800c65:	e8 6e fe ff ff       	call   800ad8 <syscall>
}
  800c6a:	c9                   	leave  
  800c6b:	c3                   	ret    

00800c6c <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800c6c:	55                   	push   %ebp
  800c6d:	89 e5                	mov    %esp,%ebp
  800c6f:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  800c72:	6a 00                	push   $0x0
  800c74:	6a 00                	push   $0x0
  800c76:	6a 00                	push   $0x0
  800c78:	ff 75 0c             	pushl  0xc(%ebp)
  800c7b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c7e:	ba 01 00 00 00       	mov    $0x1,%edx
  800c83:	b8 09 00 00 00       	mov    $0x9,%eax
  800c88:	e8 4b fe ff ff       	call   800ad8 <syscall>
}
  800c8d:	c9                   	leave  
  800c8e:	c3                   	ret    

00800c8f <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800c8f:	55                   	push   %ebp
  800c90:	89 e5                	mov    %esp,%ebp
  800c92:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  800c95:	6a 00                	push   $0x0
  800c97:	ff 75 14             	pushl  0x14(%ebp)
  800c9a:	ff 75 10             	pushl  0x10(%ebp)
  800c9d:	ff 75 0c             	pushl  0xc(%ebp)
  800ca0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ca3:	ba 00 00 00 00       	mov    $0x0,%edx
  800ca8:	b8 0b 00 00 00       	mov    $0xb,%eax
  800cad:	e8 26 fe ff ff       	call   800ad8 <syscall>
}
  800cb2:	c9                   	leave  
  800cb3:	c3                   	ret    

00800cb4 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800cb4:	55                   	push   %ebp
  800cb5:	89 e5                	mov    %esp,%ebp
  800cb7:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  800cba:	6a 00                	push   $0x0
  800cbc:	6a 00                	push   $0x0
  800cbe:	6a 00                	push   $0x0
  800cc0:	6a 00                	push   $0x0
  800cc2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800cc5:	ba 01 00 00 00       	mov    $0x1,%edx
  800cca:	b8 0c 00 00 00       	mov    $0xc,%eax
  800ccf:	e8 04 fe ff ff       	call   800ad8 <syscall>
}
  800cd4:	c9                   	leave  
  800cd5:	c3                   	ret    

00800cd6 <sys_set_priority>:

int
sys_set_priority(envid_t envid, uint32_t new_priority)
{
  800cd6:	55                   	push   %ebp
  800cd7:	89 e5                	mov    %esp,%ebp
  800cd9:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_set_priority, 0, envid, new_priority, 0, 0, 0);
  800cdc:	6a 00                	push   $0x0
  800cde:	6a 00                	push   $0x0
  800ce0:	6a 00                	push   $0x0
  800ce2:	ff 75 0c             	pushl  0xc(%ebp)
  800ce5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ce8:	ba 00 00 00 00       	mov    $0x0,%edx
  800ced:	b8 0d 00 00 00       	mov    $0xd,%eax
  800cf2:	e8 e1 fd ff ff       	call   800ad8 <syscall>
}
  800cf7:	c9                   	leave  
  800cf8:	c3                   	ret    
  800cf9:	00 00                	add    %al,(%eax)
	...

00800cfc <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800cfc:	55                   	push   %ebp
  800cfd:	89 e5                	mov    %esp,%ebp
  800cff:	53                   	push   %ebx
  800d00:	83 ec 04             	sub    $0x4,%esp
  800d03:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800d06:	8b 18                	mov    (%eax),%ebx

	// LAB 4: Your code here.
	
	// cprintf("PAGE FAULT HANDLER, 0x%08x %d\n", (uint32_t)addr, err & FEC_WR);
	
	if ((err & FEC_WR) == 0)
  800d08:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800d0c:	75 14                	jne    800d22 <pgfault+0x26>
		panic("pgfault, the fault is not a write\n");
  800d0e:	83 ec 04             	sub    $0x4,%esp
  800d11:	68 10 16 80 00       	push   $0x801610
  800d16:	6a 20                	push   $0x20
  800d18:	68 54 17 80 00       	push   $0x801754
  800d1d:	e8 aa 02 00 00       	call   800fcc <_panic>

	uint32_t uaddr = (uint32_t) addr;
	if ((uvpd[PDX(addr)] & PTE_P) == 0 || (uvpt[uaddr / PGSIZE] & PTE_COW) == 0) {
  800d22:	89 d8                	mov    %ebx,%eax
  800d24:	c1 e8 16             	shr    $0x16,%eax
  800d27:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800d2e:	a8 01                	test   $0x1,%al
  800d30:	74 11                	je     800d43 <pgfault+0x47>
  800d32:	89 d8                	mov    %ebx,%eax
  800d34:	c1 e8 0c             	shr    $0xc,%eax
  800d37:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800d3e:	f6 c4 08             	test   $0x8,%ah
  800d41:	75 14                	jne    800d57 <pgfault+0x5b>
		panic("pgfault, not a copy-on-write page\n");
  800d43:	83 ec 04             	sub    $0x4,%esp
  800d46:	68 34 16 80 00       	push   $0x801634
  800d4b:	6a 24                	push   $0x24
  800d4d:	68 54 17 80 00       	push   $0x801754
  800d52:	e8 75 02 00 00       	call   800fcc <_panic>
	//   No need to explicitly delete the old page's mapping.

	// LAB 4: Your code here.

	// static int sys_page_alloc(envid_t envid, void *va, int perm)
	r = sys_page_alloc(0, (void *)PFTEMP, PTE_W | PTE_U | PTE_P);
  800d57:	83 ec 04             	sub    $0x4,%esp
  800d5a:	6a 07                	push   $0x7
  800d5c:	68 00 f0 7f 00       	push   $0x7ff000
  800d61:	6a 00                	push   $0x0
  800d63:	e8 74 fe ff ff       	call   800bdc <sys_page_alloc>
	if (r < 0) panic("pgfault, sys_page_alloc error : %e\n", r);
  800d68:	83 c4 10             	add    $0x10,%esp
  800d6b:	85 c0                	test   %eax,%eax
  800d6d:	79 12                	jns    800d81 <pgfault+0x85>
  800d6f:	50                   	push   %eax
  800d70:	68 58 16 80 00       	push   $0x801658
  800d75:	6a 32                	push   $0x32
  800d77:	68 54 17 80 00       	push   $0x801754
  800d7c:	e8 4b 02 00 00       	call   800fcc <_panic>

	// Oh my god, I forget this at the first, it waste me a lot of time to debug!!!
	addr = ROUNDDOWN(addr, PGSIZE);
  800d81:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	
	memcpy(PFTEMP, addr, PGSIZE);
  800d87:	83 ec 04             	sub    $0x4,%esp
  800d8a:	68 00 10 00 00       	push   $0x1000
  800d8f:	53                   	push   %ebx
  800d90:	68 00 f0 7f 00       	push   $0x7ff000
  800d95:	e8 eb fb ff ff       	call   800985 <memcpy>
	
	r = sys_page_map(0, PFTEMP, 0, addr, PTE_W | PTE_U | PTE_P);
  800d9a:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800da1:	53                   	push   %ebx
  800da2:	6a 00                	push   $0x0
  800da4:	68 00 f0 7f 00       	push   $0x7ff000
  800da9:	6a 00                	push   $0x0
  800dab:	e8 50 fe ff ff       	call   800c00 <sys_page_map>
	if (r < 0) panic("pgfault, sys_page_map error : %e\n", r);
  800db0:	83 c4 20             	add    $0x20,%esp
  800db3:	85 c0                	test   %eax,%eax
  800db5:	79 12                	jns    800dc9 <pgfault+0xcd>
  800db7:	50                   	push   %eax
  800db8:	68 7c 16 80 00       	push   $0x80167c
  800dbd:	6a 3a                	push   $0x3a
  800dbf:	68 54 17 80 00       	push   $0x801754
  800dc4:	e8 03 02 00 00       	call   800fcc <_panic>

	return;
}
  800dc9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800dcc:	c9                   	leave  
  800dcd:	c3                   	ret    

00800dce <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800dce:	55                   	push   %ebp
  800dcf:	89 e5                	mov    %esp,%ebp
  800dd1:	57                   	push   %edi
  800dd2:	56                   	push   %esi
  800dd3:	53                   	push   %ebx
  800dd4:	83 ec 28             	sub    $0x28,%esp
	// static int num = 0x100;

	// LAB 4: Your code here.
	set_pgfault_handler(pgfault);
  800dd7:	68 fc 0c 80 00       	push   $0x800cfc
  800ddc:	e8 33 02 00 00       	call   801014 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  800de1:	ba 07 00 00 00       	mov    $0x7,%edx
  800de6:	89 d0                	mov    %edx,%eax
  800de8:	cd 30                	int    $0x30
  800dea:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800ded:	89 c7                	mov    %eax,%edi
	int childpid = sys_exofork();
	if (childpid < 0) {
  800def:	83 c4 10             	add    $0x10,%esp
  800df2:	85 c0                	test   %eax,%eax
  800df4:	79 12                	jns    800e08 <fork+0x3a>
		panic("fork sys_exofork error : %e\n", childpid);
  800df6:	50                   	push   %eax
  800df7:	68 5f 17 80 00       	push   $0x80175f
  800dfc:	6a 7b                	push   $0x7b
  800dfe:	68 54 17 80 00       	push   $0x801754
  800e03:	e8 c4 01 00 00       	call   800fcc <_panic>
	}
	int r;

	if (childpid == 0) {
  800e08:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800e0c:	75 1c                	jne    800e2a <fork+0x5c>
		// child process
		// Remember to fix "thisenv" in the child process. ??? 
		thisenv = &envs[ENVX(sys_getenvid())];
  800e0e:	e8 7e fd ff ff       	call   800b91 <sys_getenvid>
  800e13:	25 ff 03 00 00       	and    $0x3ff,%eax
  800e18:	c1 e0 07             	shl    $0x7,%eax
  800e1b:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800e20:	a3 04 20 80 00       	mov    %eax,0x802004
		// cprintf("fork child ok\n");
		return 0;
  800e25:	e9 7b 01 00 00       	jmp    800fa5 <fork+0x1d7>
	if (childpid < 0) {
		panic("fork sys_exofork error : %e\n", childpid);
	}
	int r;

	if (childpid == 0) {
  800e2a:	bb 00 00 00 00       	mov    $0x0,%ebx
	} else {
		// map page to new environment
		// kernel page is already in new environment
		uint32_t i;
		for (i = 0; i != UTOP; i += PGSIZE) 
		if ((uvpd[PDX(i)] & PTE_P) && (uvpt[i / PGSIZE] & PTE_P) && (uvpt[i / PGSIZE] & PTE_U)) {
  800e2f:	89 d8                	mov    %ebx,%eax
  800e31:	c1 e8 16             	shr    $0x16,%eax
  800e34:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800e3b:	a8 01                	test   $0x1,%al
  800e3d:	0f 84 cd 00 00 00    	je     800f10 <fork+0x142>
  800e43:	89 d8                	mov    %ebx,%eax
  800e45:	c1 e8 0c             	shr    $0xc,%eax
  800e48:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800e4f:	f6 c2 01             	test   $0x1,%dl
  800e52:	0f 84 b8 00 00 00    	je     800f10 <fork+0x142>
  800e58:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800e5f:	f6 c2 04             	test   $0x4,%dl
  800e62:	0f 84 a8 00 00 00    	je     800f10 <fork+0x142>
//
static int
duppage(envid_t envid, unsigned pn)
{
	// do not dup exception stack
	if (pn * PGSIZE == UXSTACKTOP - PGSIZE) return 0;
  800e68:	89 c6                	mov    %eax,%esi
  800e6a:	c1 e6 0c             	shl    $0xc,%esi
  800e6d:	81 fe 00 f0 bf ee    	cmp    $0xeebff000,%esi
  800e73:	0f 84 97 00 00 00    	je     800f10 <fork+0x142>

	int r;
	void * addr = (void *)(pn * PGSIZE);
	if ((uvpt[pn] & PTE_W) || (uvpt[pn] & PTE_COW)) {
  800e79:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800e80:	f6 c2 02             	test   $0x2,%dl
  800e83:	75 0c                	jne    800e91 <fork+0xc3>
  800e85:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800e8c:	f6 c4 08             	test   $0x8,%ah
  800e8f:	74 57                	je     800ee8 <fork+0x11a>
		// cow
		r = sys_page_map(0, addr, envid, addr, PTE_COW | PTE_P | PTE_U);
  800e91:	83 ec 0c             	sub    $0xc,%esp
  800e94:	68 05 08 00 00       	push   $0x805
  800e99:	56                   	push   %esi
  800e9a:	57                   	push   %edi
  800e9b:	56                   	push   %esi
  800e9c:	6a 00                	push   $0x0
  800e9e:	e8 5d fd ff ff       	call   800c00 <sys_page_map>
		if (r < 0) panic("duppage sys_page_map error : %e\n", r);
  800ea3:	83 c4 20             	add    $0x20,%esp
  800ea6:	85 c0                	test   %eax,%eax
  800ea8:	79 12                	jns    800ebc <fork+0xee>
  800eaa:	50                   	push   %eax
  800eab:	68 a0 16 80 00       	push   $0x8016a0
  800eb0:	6a 55                	push   $0x55
  800eb2:	68 54 17 80 00       	push   $0x801754
  800eb7:	e8 10 01 00 00       	call   800fcc <_panic>
		
		r = sys_page_map(0, addr, 0, addr, PTE_COW | PTE_P | PTE_U);
  800ebc:	83 ec 0c             	sub    $0xc,%esp
  800ebf:	68 05 08 00 00       	push   $0x805
  800ec4:	56                   	push   %esi
  800ec5:	6a 00                	push   $0x0
  800ec7:	56                   	push   %esi
  800ec8:	6a 00                	push   $0x0
  800eca:	e8 31 fd ff ff       	call   800c00 <sys_page_map>
		if (r < 0) panic("duppage sys_page_map error : %e\n", r);
  800ecf:	83 c4 20             	add    $0x20,%esp
  800ed2:	85 c0                	test   %eax,%eax
  800ed4:	79 3a                	jns    800f10 <fork+0x142>
  800ed6:	50                   	push   %eax
  800ed7:	68 a0 16 80 00       	push   $0x8016a0
  800edc:	6a 58                	push   $0x58
  800ede:	68 54 17 80 00       	push   $0x801754
  800ee3:	e8 e4 00 00 00       	call   800fcc <_panic>
	} else {
		// read only
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U);
  800ee8:	83 ec 0c             	sub    $0xc,%esp
  800eeb:	6a 05                	push   $0x5
  800eed:	56                   	push   %esi
  800eee:	57                   	push   %edi
  800eef:	56                   	push   %esi
  800ef0:	6a 00                	push   $0x0
  800ef2:	e8 09 fd ff ff       	call   800c00 <sys_page_map>
		if (r < 0) panic("duppage sys_page_map error : %e\n", r);
  800ef7:	83 c4 20             	add    $0x20,%esp
  800efa:	85 c0                	test   %eax,%eax
  800efc:	79 12                	jns    800f10 <fork+0x142>
  800efe:	50                   	push   %eax
  800eff:	68 a0 16 80 00       	push   $0x8016a0
  800f04:	6a 5c                	push   $0x5c
  800f06:	68 54 17 80 00       	push   $0x801754
  800f0b:	e8 bc 00 00 00       	call   800fcc <_panic>
		return 0;
	} else {
		// map page to new environment
		// kernel page is already in new environment
		uint32_t i;
		for (i = 0; i != UTOP; i += PGSIZE) 
  800f10:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  800f16:	81 fb 00 00 c0 ee    	cmp    $0xeec00000,%ebx
  800f1c:	0f 85 0d ff ff ff    	jne    800e2f <fork+0x61>
		if ((uvpd[PDX(i)] & PTE_P) && (uvpt[i / PGSIZE] & PTE_P) && (uvpt[i / PGSIZE] & PTE_U)) {
			duppage(childpid, i / PGSIZE);
		}

		// allocate exception stack
		r = sys_page_alloc(childpid, (void *)(UXSTACKTOP - PGSIZE), PTE_U | PTE_W | PTE_P);
  800f22:	83 ec 04             	sub    $0x4,%esp
  800f25:	6a 07                	push   $0x7
  800f27:	68 00 f0 bf ee       	push   $0xeebff000
  800f2c:	ff 75 e4             	pushl  -0x1c(%ebp)
  800f2f:	e8 a8 fc ff ff       	call   800bdc <sys_page_alloc>
		if (r < 0) panic("fork, sys_page_alloc user exception stack error : %e\n", r);
  800f34:	83 c4 10             	add    $0x10,%esp
  800f37:	85 c0                	test   %eax,%eax
  800f39:	79 15                	jns    800f50 <fork+0x182>
  800f3b:	50                   	push   %eax
  800f3c:	68 c4 16 80 00       	push   $0x8016c4
  800f41:	68 90 00 00 00       	push   $0x90
  800f46:	68 54 17 80 00       	push   $0x801754
  800f4b:	e8 7c 00 00 00       	call   800fcc <_panic>

		// set user environment user page fault handler 
		extern void _pgfault_upcall(void);
		r = sys_env_set_pgfault_upcall(childpid, _pgfault_upcall);
  800f50:	83 ec 08             	sub    $0x8,%esp
  800f53:	68 80 10 80 00       	push   $0x801080
  800f58:	ff 75 e4             	pushl  -0x1c(%ebp)
  800f5b:	e8 0c fd ff ff       	call   800c6c <sys_env_set_pgfault_upcall>
		if (r < 0) panic("fork, set pgfault upcall fail : %e\n", r);
  800f60:	83 c4 10             	add    $0x10,%esp
  800f63:	85 c0                	test   %eax,%eax
  800f65:	79 15                	jns    800f7c <fork+0x1ae>
  800f67:	50                   	push   %eax
  800f68:	68 fc 16 80 00       	push   $0x8016fc
  800f6d:	68 95 00 00 00       	push   $0x95
  800f72:	68 54 17 80 00       	push   $0x801754
  800f77:	e8 50 00 00 00       	call   800fcc <_panic>
		r = sys_set_priority(childpid, num);
		if (r < 0) panic("fork, set priority error\n");
		*/

		// mark the child as runnable and return
		r = sys_env_set_status(childpid, ENV_RUNNABLE);
  800f7c:	83 ec 08             	sub    $0x8,%esp
  800f7f:	6a 02                	push   $0x2
  800f81:	ff 75 e4             	pushl  -0x1c(%ebp)
  800f84:	e8 c0 fc ff ff       	call   800c49 <sys_env_set_status>
		if (r < 0) panic("fork, set child process to ENV_RUNNABLE error : %e\n", r);
  800f89:	83 c4 10             	add    $0x10,%esp
  800f8c:	85 c0                	test   %eax,%eax
  800f8e:	79 15                	jns    800fa5 <fork+0x1d7>
  800f90:	50                   	push   %eax
  800f91:	68 20 17 80 00       	push   $0x801720
  800f96:	68 a0 00 00 00       	push   $0xa0
  800f9b:	68 54 17 80 00       	push   $0x801754
  800fa0:	e8 27 00 00 00       	call   800fcc <_panic>
		// cprintf("fork father ok!")
		return childpid;
	}

	panic("fork not implemented");
}
  800fa5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800fa8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800fab:	5b                   	pop    %ebx
  800fac:	5e                   	pop    %esi
  800fad:	5f                   	pop    %edi
  800fae:	c9                   	leave  
  800faf:	c3                   	ret    

00800fb0 <sfork>:

// Challenge!
int
sfork(void)
{
  800fb0:	55                   	push   %ebp
  800fb1:	89 e5                	mov    %esp,%ebp
  800fb3:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  800fb6:	68 7c 17 80 00       	push   $0x80177c
  800fbb:	68 ad 00 00 00       	push   $0xad
  800fc0:	68 54 17 80 00       	push   $0x801754
  800fc5:	e8 02 00 00 00       	call   800fcc <_panic>
	...

00800fcc <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800fcc:	55                   	push   %ebp
  800fcd:	89 e5                	mov    %esp,%ebp
  800fcf:	56                   	push   %esi
  800fd0:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800fd1:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800fd4:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  800fda:	e8 b2 fb ff ff       	call   800b91 <sys_getenvid>
  800fdf:	83 ec 0c             	sub    $0xc,%esp
  800fe2:	ff 75 0c             	pushl  0xc(%ebp)
  800fe5:	ff 75 08             	pushl  0x8(%ebp)
  800fe8:	53                   	push   %ebx
  800fe9:	50                   	push   %eax
  800fea:	68 94 17 80 00       	push   $0x801794
  800fef:	e8 b0 f1 ff ff       	call   8001a4 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800ff4:	83 c4 18             	add    $0x18,%esp
  800ff7:	56                   	push   %esi
  800ff8:	ff 75 10             	pushl  0x10(%ebp)
  800ffb:	e8 53 f1 ff ff       	call   800153 <vcprintf>
	cprintf("\n");
  801000:	c7 04 24 94 13 80 00 	movl   $0x801394,(%esp)
  801007:	e8 98 f1 ff ff       	call   8001a4 <cprintf>
  80100c:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80100f:	cc                   	int3   
  801010:	eb fd                	jmp    80100f <_panic+0x43>
	...

00801014 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801014:	55                   	push   %ebp
  801015:	89 e5                	mov    %esp,%ebp
  801017:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  80101a:	83 3d 08 20 80 00 00 	cmpl   $0x0,0x802008
  801021:	75 52                	jne    801075 <set_pgfault_handler+0x61>
		// First time through!	
		// LAB 4: Your code here.

		//int sys_page_alloc(envid_t envid, void *va, int perm)
		r = sys_page_alloc(0, (void*)(UXSTACKTOP - PGSIZE), PTE_U | PTE_W | PTE_P);
  801023:	83 ec 04             	sub    $0x4,%esp
  801026:	6a 07                	push   $0x7
  801028:	68 00 f0 bf ee       	push   $0xeebff000
  80102d:	6a 00                	push   $0x0
  80102f:	e8 a8 fb ff ff       	call   800bdc <sys_page_alloc>
		if (r < 0) {
  801034:	83 c4 10             	add    $0x10,%esp
  801037:	85 c0                	test   %eax,%eax
  801039:	79 12                	jns    80104d <set_pgfault_handler+0x39>
			panic("sys_page_alloc error : %e\n", r);
  80103b:	50                   	push   %eax
  80103c:	68 b7 17 80 00       	push   $0x8017b7
  801041:	6a 24                	push   $0x24
  801043:	68 d2 17 80 00       	push   $0x8017d2
  801048:	e8 7f ff ff ff       	call   800fcc <_panic>
		}

		// how to know envid, put 0, envid2env will help us to get curenv in syscall
		r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);		
  80104d:	83 ec 08             	sub    $0x8,%esp
  801050:	68 80 10 80 00       	push   $0x801080
  801055:	6a 00                	push   $0x0
  801057:	e8 10 fc ff ff       	call   800c6c <sys_env_set_pgfault_upcall>
		if (r < 0) {
  80105c:	83 c4 10             	add    $0x10,%esp
  80105f:	85 c0                	test   %eax,%eax
  801061:	79 12                	jns    801075 <set_pgfault_handler+0x61>
			panic("sys_env_set_pgfault_upcall error : %e\n", r);
  801063:	50                   	push   %eax
  801064:	68 e0 17 80 00       	push   $0x8017e0
  801069:	6a 2a                	push   $0x2a
  80106b:	68 d2 17 80 00       	push   $0x8017d2
  801070:	e8 57 ff ff ff       	call   800fcc <_panic>
		}
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801075:	8b 45 08             	mov    0x8(%ebp),%eax
  801078:	a3 08 20 80 00       	mov    %eax,0x802008
}
  80107d:	c9                   	leave  
  80107e:	c3                   	ret    
	...

00801080 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801080:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801081:	a1 08 20 80 00       	mov    0x802008,%eax
	call *%eax
  801086:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801088:	83 c4 04             	add    $0x4,%esp
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	
	// fix old esp
	movl 0x30(%esp), %eax
  80108b:	8b 44 24 30          	mov    0x30(%esp),%eax
	subl $0x4, %eax
  80108f:	83 e8 04             	sub    $0x4,%eax
	movl %eax, 0x30(%esp)
  801092:	89 44 24 30          	mov    %eax,0x30(%esp)

	// set trap-time %eip
	movl 0x28(%esp), %ebx
  801096:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	movl %ebx, (%eax)
  80109a:	89 18                	mov    %ebx,(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $0x08, %esp 	// ignore err_code and fault_va
  80109c:	83 c4 08             	add    $0x8,%esp
	popal 				// restore registers
  80109f:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x04, %esp 	// ignore eip 
  8010a0:	83 c4 04             	add    $0x4,%esp
	popfl				// modify eflags
  8010a3:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  8010a4:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  8010a5:	c3                   	ret    
	...

008010a8 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  8010a8:	55                   	push   %ebp
  8010a9:	89 e5                	mov    %esp,%ebp
  8010ab:	57                   	push   %edi
  8010ac:	56                   	push   %esi
  8010ad:	83 ec 10             	sub    $0x10,%esp
  8010b0:	8b 7d 08             	mov    0x8(%ebp),%edi
  8010b3:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  8010b6:	89 7d f0             	mov    %edi,-0x10(%ebp)
  8010b9:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  8010bc:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  8010bf:	8b 45 14             	mov    0x14(%ebp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  8010c2:	85 c0                	test   %eax,%eax
  8010c4:	75 2e                	jne    8010f4 <__udivdi3+0x4c>
    {
      if (d0 > n1)
  8010c6:	39 f1                	cmp    %esi,%ecx
  8010c8:	77 5a                	ja     801124 <__udivdi3+0x7c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  8010ca:	85 c9                	test   %ecx,%ecx
  8010cc:	75 0b                	jne    8010d9 <__udivdi3+0x31>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  8010ce:	b8 01 00 00 00       	mov    $0x1,%eax
  8010d3:	31 d2                	xor    %edx,%edx
  8010d5:	f7 f1                	div    %ecx
  8010d7:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  8010d9:	31 d2                	xor    %edx,%edx
  8010db:	89 f0                	mov    %esi,%eax
  8010dd:	f7 f1                	div    %ecx
  8010df:	89 c6                	mov    %eax,%esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8010e1:	89 f8                	mov    %edi,%eax
  8010e3:	f7 f1                	div    %ecx
  8010e5:	89 c7                	mov    %eax,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  8010e7:	89 f8                	mov    %edi,%eax
  8010e9:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  8010eb:	83 c4 10             	add    $0x10,%esp
  8010ee:	5e                   	pop    %esi
  8010ef:	5f                   	pop    %edi
  8010f0:	c9                   	leave  
  8010f1:	c3                   	ret    
  8010f2:	66 90                	xchg   %ax,%ax
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  8010f4:	39 f0                	cmp    %esi,%eax
  8010f6:	77 1c                	ja     801114 <__udivdi3+0x6c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  8010f8:	0f bd f8             	bsr    %eax,%edi
	  if (bm == 0)
  8010fb:	83 f7 1f             	xor    $0x1f,%edi
  8010fe:	75 3c                	jne    80113c <__udivdi3+0x94>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801100:	39 f0                	cmp    %esi,%eax
  801102:	0f 82 90 00 00 00    	jb     801198 <__udivdi3+0xf0>
  801108:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80110b:	39 55 f4             	cmp    %edx,-0xc(%ebp)
  80110e:	0f 86 84 00 00 00    	jbe    801198 <__udivdi3+0xf0>
  801114:	31 f6                	xor    %esi,%esi
  801116:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801118:	89 f8                	mov    %edi,%eax
  80111a:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  80111c:	83 c4 10             	add    $0x10,%esp
  80111f:	5e                   	pop    %esi
  801120:	5f                   	pop    %edi
  801121:	c9                   	leave  
  801122:	c3                   	ret    
  801123:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801124:	89 f2                	mov    %esi,%edx
  801126:	89 f8                	mov    %edi,%eax
  801128:	f7 f1                	div    %ecx
  80112a:	89 c7                	mov    %eax,%edi
  80112c:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  80112e:	89 f8                	mov    %edi,%eax
  801130:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801132:	83 c4 10             	add    $0x10,%esp
  801135:	5e                   	pop    %esi
  801136:	5f                   	pop    %edi
  801137:	c9                   	leave  
  801138:	c3                   	ret    
  801139:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  80113c:	89 f9                	mov    %edi,%ecx
  80113e:	d3 e0                	shl    %cl,%eax
  801140:	89 45 e8             	mov    %eax,-0x18(%ebp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  801143:	b8 20 00 00 00       	mov    $0x20,%eax
  801148:	29 f8                	sub    %edi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  80114a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80114d:	88 c1                	mov    %al,%cl
  80114f:	d3 ea                	shr    %cl,%edx
  801151:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  801154:	09 ca                	or     %ecx,%edx
  801156:	89 55 ec             	mov    %edx,-0x14(%ebp)
	      d0 = d0 << bm;
  801159:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80115c:	89 f9                	mov    %edi,%ecx
  80115e:	d3 e2                	shl    %cl,%edx
  801160:	89 55 f4             	mov    %edx,-0xc(%ebp)
	      n2 = n1 >> b;
  801163:	89 f2                	mov    %esi,%edx
  801165:	88 c1                	mov    %al,%cl
  801167:	d3 ea                	shr    %cl,%edx
  801169:	89 55 e8             	mov    %edx,-0x18(%ebp)
	      n1 = (n1 << bm) | (n0 >> b);
  80116c:	89 f2                	mov    %esi,%edx
  80116e:	89 f9                	mov    %edi,%ecx
  801170:	d3 e2                	shl    %cl,%edx
  801172:	8b 75 f0             	mov    -0x10(%ebp),%esi
  801175:	88 c1                	mov    %al,%cl
  801177:	d3 ee                	shr    %cl,%esi
  801179:	09 d6                	or     %edx,%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  80117b:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  80117e:	89 f0                	mov    %esi,%eax
  801180:	89 ca                	mov    %ecx,%edx
  801182:	f7 75 ec             	divl   -0x14(%ebp)
  801185:	89 d1                	mov    %edx,%ecx
  801187:	89 c6                	mov    %eax,%esi
	      umul_ppmm (m1, m0, q0, d0);
  801189:	f7 65 f4             	mull   -0xc(%ebp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  80118c:	39 d1                	cmp    %edx,%ecx
  80118e:	72 28                	jb     8011b8 <__udivdi3+0x110>
  801190:	74 1a                	je     8011ac <__udivdi3+0x104>
  801192:	89 f7                	mov    %esi,%edi
  801194:	31 f6                	xor    %esi,%esi
  801196:	eb 80                	jmp    801118 <__udivdi3+0x70>
	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  801198:	31 f6                	xor    %esi,%esi
  80119a:	bf 01 00 00 00       	mov    $0x1,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  80119f:	89 f8                	mov    %edi,%eax
  8011a1:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  8011a3:	83 c4 10             	add    $0x10,%esp
  8011a6:	5e                   	pop    %esi
  8011a7:	5f                   	pop    %edi
  8011a8:	c9                   	leave  
  8011a9:	c3                   	ret    
  8011aa:	66 90                	xchg   %ax,%ax

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  8011ac:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8011af:	89 f9                	mov    %edi,%ecx
  8011b1:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8011b3:	39 c2                	cmp    %eax,%edx
  8011b5:	73 db                	jae    801192 <__udivdi3+0xea>
  8011b7:	90                   	nop
		{
		  q0--;
  8011b8:	8d 7e ff             	lea    -0x1(%esi),%edi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  8011bb:	31 f6                	xor    %esi,%esi
  8011bd:	e9 56 ff ff ff       	jmp    801118 <__udivdi3+0x70>
	...

008011c4 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  8011c4:	55                   	push   %ebp
  8011c5:	89 e5                	mov    %esp,%ebp
  8011c7:	57                   	push   %edi
  8011c8:	56                   	push   %esi
  8011c9:	83 ec 20             	sub    $0x20,%esp
  8011cc:	8b 45 08             	mov    0x8(%ebp),%eax
  8011cf:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  8011d2:	89 45 e8             	mov    %eax,-0x18(%ebp)
  8011d5:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  8011d8:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  8011db:	8b 7d 14             	mov    0x14(%ebp),%edi
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  8011de:	89 45 f0             	mov    %eax,-0x10(%ebp)
  n1 = nn.s.high;
  8011e1:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  8011e3:	85 ff                	test   %edi,%edi
  8011e5:	75 15                	jne    8011fc <__umoddi3+0x38>
    {
      if (d0 > n1)
  8011e7:	39 f1                	cmp    %esi,%ecx
  8011e9:	0f 86 99 00 00 00    	jbe    801288 <__umoddi3+0xc4>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8011ef:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  8011f1:	89 d0                	mov    %edx,%eax
  8011f3:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8011f5:	83 c4 20             	add    $0x20,%esp
  8011f8:	5e                   	pop    %esi
  8011f9:	5f                   	pop    %edi
  8011fa:	c9                   	leave  
  8011fb:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  8011fc:	39 f7                	cmp    %esi,%edi
  8011fe:	0f 87 a4 00 00 00    	ja     8012a8 <__umoddi3+0xe4>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  801204:	0f bd c7             	bsr    %edi,%eax
	  if (bm == 0)
  801207:	83 f0 1f             	xor    $0x1f,%eax
  80120a:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80120d:	0f 84 a1 00 00 00    	je     8012b4 <__umoddi3+0xf0>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  801213:	89 f8                	mov    %edi,%eax
  801215:	8a 4d ec             	mov    -0x14(%ebp),%cl
  801218:	d3 e0                	shl    %cl,%eax
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  80121a:	bf 20 00 00 00       	mov    $0x20,%edi
  80121f:	2b 7d ec             	sub    -0x14(%ebp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  801222:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801225:	89 f9                	mov    %edi,%ecx
  801227:	d3 ea                	shr    %cl,%edx
  801229:	09 c2                	or     %eax,%edx
  80122b:	89 55 f0             	mov    %edx,-0x10(%ebp)
	      d0 = d0 << bm;
  80122e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801231:	8a 4d ec             	mov    -0x14(%ebp),%cl
  801234:	d3 e0                	shl    %cl,%eax
  801236:	89 45 f4             	mov    %eax,-0xc(%ebp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  801239:	89 f2                	mov    %esi,%edx
  80123b:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  80123d:	8b 45 e8             	mov    -0x18(%ebp),%eax
  801240:	d3 e0                	shl    %cl,%eax
  801242:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  801245:	8b 45 e8             	mov    -0x18(%ebp),%eax
  801248:	89 f9                	mov    %edi,%ecx
  80124a:	d3 e8                	shr    %cl,%eax
  80124c:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  80124e:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  801250:	89 f2                	mov    %esi,%edx
  801252:	f7 75 f0             	divl   -0x10(%ebp)
  801255:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  801257:	f7 65 f4             	mull   -0xc(%ebp)
  80125a:	89 55 e8             	mov    %edx,-0x18(%ebp)
  80125d:	89 c1                	mov    %eax,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  80125f:	39 d6                	cmp    %edx,%esi
  801261:	72 71                	jb     8012d4 <__umoddi3+0x110>
  801263:	74 7f                	je     8012e4 <__umoddi3+0x120>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  801265:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801268:	29 c8                	sub    %ecx,%eax
  80126a:	19 d6                	sbb    %edx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  80126c:	8a 4d ec             	mov    -0x14(%ebp),%cl
  80126f:	d3 e8                	shr    %cl,%eax
  801271:	89 f2                	mov    %esi,%edx
  801273:	89 f9                	mov    %edi,%ecx
  801275:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  801277:	09 d0                	or     %edx,%eax
  801279:	89 f2                	mov    %esi,%edx
  80127b:	8a 4d ec             	mov    -0x14(%ebp),%cl
  80127e:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801280:	83 c4 20             	add    $0x20,%esp
  801283:	5e                   	pop    %esi
  801284:	5f                   	pop    %edi
  801285:	c9                   	leave  
  801286:	c3                   	ret    
  801287:	90                   	nop
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  801288:	85 c9                	test   %ecx,%ecx
  80128a:	75 0b                	jne    801297 <__umoddi3+0xd3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  80128c:	b8 01 00 00 00       	mov    $0x1,%eax
  801291:	31 d2                	xor    %edx,%edx
  801293:	f7 f1                	div    %ecx
  801295:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  801297:	89 f0                	mov    %esi,%eax
  801299:	31 d2                	xor    %edx,%edx
  80129b:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  80129d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012a0:	f7 f1                	div    %ecx
  8012a2:	e9 4a ff ff ff       	jmp    8011f1 <__umoddi3+0x2d>
  8012a7:	90                   	nop
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  8012a8:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8012aa:	83 c4 20             	add    $0x20,%esp
  8012ad:	5e                   	pop    %esi
  8012ae:	5f                   	pop    %edi
  8012af:	c9                   	leave  
  8012b0:	c3                   	ret    
  8012b1:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  8012b4:	39 f7                	cmp    %esi,%edi
  8012b6:	72 05                	jb     8012bd <__umoddi3+0xf9>
  8012b8:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
  8012bb:	77 0c                	ja     8012c9 <__umoddi3+0x105>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  8012bd:	89 f2                	mov    %esi,%edx
  8012bf:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012c2:	29 c8                	sub    %ecx,%eax
  8012c4:	19 fa                	sbb    %edi,%edx
  8012c6:	89 45 f0             	mov    %eax,-0x10(%ebp)

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  8012c9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8012cc:	83 c4 20             	add    $0x20,%esp
  8012cf:	5e                   	pop    %esi
  8012d0:	5f                   	pop    %edi
  8012d1:	c9                   	leave  
  8012d2:	c3                   	ret    
  8012d3:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  8012d4:	8b 55 e8             	mov    -0x18(%ebp),%edx
  8012d7:	89 c1                	mov    %eax,%ecx
  8012d9:	2b 4d f4             	sub    -0xc(%ebp),%ecx
  8012dc:	1b 55 f0             	sbb    -0x10(%ebp),%edx
  8012df:	eb 84                	jmp    801265 <__umoddi3+0xa1>
  8012e1:	8d 76 00             	lea    0x0(%esi),%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8012e4:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  8012e7:	72 eb                	jb     8012d4 <__umoddi3+0x110>
  8012e9:	89 f2                	mov    %esi,%edx
  8012eb:	e9 75 ff ff ff       	jmp    801265 <__umoddi3+0xa1>
