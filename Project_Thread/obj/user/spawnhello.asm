
obj/user/spawnhello.debug:     file format elf32-i386


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
  80002c:	e8 5b 00 00 00       	call   80008c <libmain>
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
  800037:	83 ec 10             	sub    $0x10,%esp
	int r;
	cprintf("i am parent environment %08x\n", thisenv->env_id);
  80003a:	a1 04 40 80 00       	mov    0x804004,%eax
  80003f:	8b 40 48             	mov    0x48(%eax),%eax
  800042:	50                   	push   %eax
  800043:	68 80 26 80 00       	push   $0x802680
  800048:	e8 7f 01 00 00       	call   8001cc <cprintf>
	if ((r = spawnl("hello", "hello", 0)) < 0)
  80004d:	83 c4 0c             	add    $0xc,%esp
  800050:	6a 00                	push   $0x0
  800052:	68 9e 26 80 00       	push   $0x80269e
  800057:	68 9e 26 80 00       	push   $0x80269e
  80005c:	e8 d5 1c 00 00       	call   801d36 <spawnl>
  800061:	83 c4 10             	add    $0x10,%esp
  800064:	85 c0                	test   %eax,%eax
  800066:	79 12                	jns    80007a <umain+0x46>
		panic("spawn(hello) failed: %e", r);
  800068:	50                   	push   %eax
  800069:	68 a4 26 80 00       	push   $0x8026a4
  80006e:	6a 09                	push   $0x9
  800070:	68 bc 26 80 00       	push   $0x8026bc
  800075:	e8 7a 00 00 00       	call   8000f4 <_panic>
	//if ((r = execl("hello", "hello", 0)) < 0)
	//	panic("spawn(hello) exec: %e", r);
	cprintf("I come back!\n");
  80007a:	83 ec 0c             	sub    $0xc,%esp
  80007d:	68 ce 26 80 00       	push   $0x8026ce
  800082:	e8 45 01 00 00       	call   8001cc <cprintf>
  800087:	83 c4 10             	add    $0x10,%esp
	
}
  80008a:	c9                   	leave  
  80008b:	c3                   	ret    

0080008c <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80008c:	55                   	push   %ebp
  80008d:	89 e5                	mov    %esp,%ebp
  80008f:	56                   	push   %esi
  800090:	53                   	push   %ebx
  800091:	8b 75 08             	mov    0x8(%ebp),%esi
  800094:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs + ENVX(sys_getenvid());
  800097:	e8 1d 0b 00 00       	call   800bb9 <sys_getenvid>
  80009c:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000a1:	89 c2                	mov    %eax,%edx
  8000a3:	c1 e2 07             	shl    $0x7,%edx
  8000a6:	8d 84 82 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,4),%eax
  8000ad:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000b2:	85 f6                	test   %esi,%esi
  8000b4:	7e 07                	jle    8000bd <libmain+0x31>
		binaryname = argv[0];
  8000b6:	8b 03                	mov    (%ebx),%eax
  8000b8:	a3 00 30 80 00       	mov    %eax,0x803000
	// call user main routine
	umain(argc, argv);
  8000bd:	83 ec 08             	sub    $0x8,%esp
  8000c0:	53                   	push   %ebx
  8000c1:	56                   	push   %esi
  8000c2:	e8 6d ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  8000c7:	e8 0c 00 00 00       	call   8000d8 <exit>
  8000cc:	83 c4 10             	add    $0x10,%esp
}
  8000cf:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000d2:	5b                   	pop    %ebx
  8000d3:	5e                   	pop    %esi
  8000d4:	c9                   	leave  
  8000d5:	c3                   	ret    
	...

008000d8 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000d8:	55                   	push   %ebp
  8000d9:	89 e5                	mov    %esp,%ebp
  8000db:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8000de:	e8 d7 0e 00 00       	call   800fba <close_all>
	sys_env_destroy(0);
  8000e3:	83 ec 0c             	sub    $0xc,%esp
  8000e6:	6a 00                	push   $0x0
  8000e8:	e8 aa 0a 00 00       	call   800b97 <sys_env_destroy>
  8000ed:	83 c4 10             	add    $0x10,%esp
}
  8000f0:	c9                   	leave  
  8000f1:	c3                   	ret    
	...

008000f4 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8000f4:	55                   	push   %ebp
  8000f5:	89 e5                	mov    %esp,%ebp
  8000f7:	56                   	push   %esi
  8000f8:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8000f9:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8000fc:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  800102:	e8 b2 0a 00 00       	call   800bb9 <sys_getenvid>
  800107:	83 ec 0c             	sub    $0xc,%esp
  80010a:	ff 75 0c             	pushl  0xc(%ebp)
  80010d:	ff 75 08             	pushl  0x8(%ebp)
  800110:	53                   	push   %ebx
  800111:	50                   	push   %eax
  800112:	68 e8 26 80 00       	push   $0x8026e8
  800117:	e8 b0 00 00 00       	call   8001cc <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80011c:	83 c4 18             	add    $0x18,%esp
  80011f:	56                   	push   %esi
  800120:	ff 75 10             	pushl  0x10(%ebp)
  800123:	e8 53 00 00 00       	call   80017b <vcprintf>
	cprintf("\n");
  800128:	c7 04 24 da 26 80 00 	movl   $0x8026da,(%esp)
  80012f:	e8 98 00 00 00       	call   8001cc <cprintf>
  800134:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800137:	cc                   	int3   
  800138:	eb fd                	jmp    800137 <_panic+0x43>
	...

0080013c <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80013c:	55                   	push   %ebp
  80013d:	89 e5                	mov    %esp,%ebp
  80013f:	53                   	push   %ebx
  800140:	83 ec 04             	sub    $0x4,%esp
  800143:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800146:	8b 03                	mov    (%ebx),%eax
  800148:	8b 55 08             	mov    0x8(%ebp),%edx
  80014b:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  80014f:	40                   	inc    %eax
  800150:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  800152:	3d ff 00 00 00       	cmp    $0xff,%eax
  800157:	75 1a                	jne    800173 <putch+0x37>
		sys_cputs(b->buf, b->idx);
  800159:	83 ec 08             	sub    $0x8,%esp
  80015c:	68 ff 00 00 00       	push   $0xff
  800161:	8d 43 08             	lea    0x8(%ebx),%eax
  800164:	50                   	push   %eax
  800165:	e8 e3 09 00 00       	call   800b4d <sys_cputs>
		b->idx = 0;
  80016a:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800170:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800173:	ff 43 04             	incl   0x4(%ebx)
}
  800176:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800179:	c9                   	leave  
  80017a:	c3                   	ret    

0080017b <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80017b:	55                   	push   %ebp
  80017c:	89 e5                	mov    %esp,%ebp
  80017e:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800184:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80018b:	00 00 00 
	b.cnt = 0;
  80018e:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800195:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800198:	ff 75 0c             	pushl  0xc(%ebp)
  80019b:	ff 75 08             	pushl  0x8(%ebp)
  80019e:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001a4:	50                   	push   %eax
  8001a5:	68 3c 01 80 00       	push   $0x80013c
  8001aa:	e8 82 01 00 00       	call   800331 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001af:	83 c4 08             	add    $0x8,%esp
  8001b2:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8001b8:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001be:	50                   	push   %eax
  8001bf:	e8 89 09 00 00       	call   800b4d <sys_cputs>

	return b.cnt;
}
  8001c4:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001ca:	c9                   	leave  
  8001cb:	c3                   	ret    

008001cc <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001cc:	55                   	push   %ebp
  8001cd:	89 e5                	mov    %esp,%ebp
  8001cf:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001d2:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001d5:	50                   	push   %eax
  8001d6:	ff 75 08             	pushl  0x8(%ebp)
  8001d9:	e8 9d ff ff ff       	call   80017b <vcprintf>
	va_end(ap);

	return cnt;
}
  8001de:	c9                   	leave  
  8001df:	c3                   	ret    

008001e0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001e0:	55                   	push   %ebp
  8001e1:	89 e5                	mov    %esp,%ebp
  8001e3:	57                   	push   %edi
  8001e4:	56                   	push   %esi
  8001e5:	53                   	push   %ebx
  8001e6:	83 ec 2c             	sub    $0x2c,%esp
  8001e9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8001ec:	89 d6                	mov    %edx,%esi
  8001ee:	8b 45 08             	mov    0x8(%ebp),%eax
  8001f1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001f4:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001f7:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8001fa:	8b 45 10             	mov    0x10(%ebp),%eax
  8001fd:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800200:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800203:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800206:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  80020d:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
  800210:	72 0c                	jb     80021e <printnum+0x3e>
  800212:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  800215:	76 07                	jbe    80021e <printnum+0x3e>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800217:	4b                   	dec    %ebx
  800218:	85 db                	test   %ebx,%ebx
  80021a:	7f 31                	jg     80024d <printnum+0x6d>
  80021c:	eb 3f                	jmp    80025d <printnum+0x7d>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80021e:	83 ec 0c             	sub    $0xc,%esp
  800221:	57                   	push   %edi
  800222:	4b                   	dec    %ebx
  800223:	53                   	push   %ebx
  800224:	50                   	push   %eax
  800225:	83 ec 08             	sub    $0x8,%esp
  800228:	ff 75 d4             	pushl  -0x2c(%ebp)
  80022b:	ff 75 d0             	pushl  -0x30(%ebp)
  80022e:	ff 75 dc             	pushl  -0x24(%ebp)
  800231:	ff 75 d8             	pushl  -0x28(%ebp)
  800234:	e8 e7 21 00 00       	call   802420 <__udivdi3>
  800239:	83 c4 18             	add    $0x18,%esp
  80023c:	52                   	push   %edx
  80023d:	50                   	push   %eax
  80023e:	89 f2                	mov    %esi,%edx
  800240:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800243:	e8 98 ff ff ff       	call   8001e0 <printnum>
  800248:	83 c4 20             	add    $0x20,%esp
  80024b:	eb 10                	jmp    80025d <printnum+0x7d>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80024d:	83 ec 08             	sub    $0x8,%esp
  800250:	56                   	push   %esi
  800251:	57                   	push   %edi
  800252:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800255:	4b                   	dec    %ebx
  800256:	83 c4 10             	add    $0x10,%esp
  800259:	85 db                	test   %ebx,%ebx
  80025b:	7f f0                	jg     80024d <printnum+0x6d>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80025d:	83 ec 08             	sub    $0x8,%esp
  800260:	56                   	push   %esi
  800261:	83 ec 04             	sub    $0x4,%esp
  800264:	ff 75 d4             	pushl  -0x2c(%ebp)
  800267:	ff 75 d0             	pushl  -0x30(%ebp)
  80026a:	ff 75 dc             	pushl  -0x24(%ebp)
  80026d:	ff 75 d8             	pushl  -0x28(%ebp)
  800270:	e8 c7 22 00 00       	call   80253c <__umoddi3>
  800275:	83 c4 14             	add    $0x14,%esp
  800278:	0f be 80 0b 27 80 00 	movsbl 0x80270b(%eax),%eax
  80027f:	50                   	push   %eax
  800280:	ff 55 e4             	call   *-0x1c(%ebp)
  800283:	83 c4 10             	add    $0x10,%esp
}
  800286:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800289:	5b                   	pop    %ebx
  80028a:	5e                   	pop    %esi
  80028b:	5f                   	pop    %edi
  80028c:	c9                   	leave  
  80028d:	c3                   	ret    

0080028e <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80028e:	55                   	push   %ebp
  80028f:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800291:	83 fa 01             	cmp    $0x1,%edx
  800294:	7e 0e                	jle    8002a4 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800296:	8b 10                	mov    (%eax),%edx
  800298:	8d 4a 08             	lea    0x8(%edx),%ecx
  80029b:	89 08                	mov    %ecx,(%eax)
  80029d:	8b 02                	mov    (%edx),%eax
  80029f:	8b 52 04             	mov    0x4(%edx),%edx
  8002a2:	eb 22                	jmp    8002c6 <getuint+0x38>
	else if (lflag)
  8002a4:	85 d2                	test   %edx,%edx
  8002a6:	74 10                	je     8002b8 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8002a8:	8b 10                	mov    (%eax),%edx
  8002aa:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002ad:	89 08                	mov    %ecx,(%eax)
  8002af:	8b 02                	mov    (%edx),%eax
  8002b1:	ba 00 00 00 00       	mov    $0x0,%edx
  8002b6:	eb 0e                	jmp    8002c6 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8002b8:	8b 10                	mov    (%eax),%edx
  8002ba:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002bd:	89 08                	mov    %ecx,(%eax)
  8002bf:	8b 02                	mov    (%edx),%eax
  8002c1:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002c6:	c9                   	leave  
  8002c7:	c3                   	ret    

008002c8 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  8002c8:	55                   	push   %ebp
  8002c9:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002cb:	83 fa 01             	cmp    $0x1,%edx
  8002ce:	7e 0e                	jle    8002de <getint+0x16>
		return va_arg(*ap, long long);
  8002d0:	8b 10                	mov    (%eax),%edx
  8002d2:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002d5:	89 08                	mov    %ecx,(%eax)
  8002d7:	8b 02                	mov    (%edx),%eax
  8002d9:	8b 52 04             	mov    0x4(%edx),%edx
  8002dc:	eb 1a                	jmp    8002f8 <getint+0x30>
	else if (lflag)
  8002de:	85 d2                	test   %edx,%edx
  8002e0:	74 0c                	je     8002ee <getint+0x26>
		return va_arg(*ap, long);
  8002e2:	8b 10                	mov    (%eax),%edx
  8002e4:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002e7:	89 08                	mov    %ecx,(%eax)
  8002e9:	8b 02                	mov    (%edx),%eax
  8002eb:	99                   	cltd   
  8002ec:	eb 0a                	jmp    8002f8 <getint+0x30>
	else
		return va_arg(*ap, int);
  8002ee:	8b 10                	mov    (%eax),%edx
  8002f0:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002f3:	89 08                	mov    %ecx,(%eax)
  8002f5:	8b 02                	mov    (%edx),%eax
  8002f7:	99                   	cltd   
}
  8002f8:	c9                   	leave  
  8002f9:	c3                   	ret    

008002fa <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002fa:	55                   	push   %ebp
  8002fb:	89 e5                	mov    %esp,%ebp
  8002fd:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800300:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  800303:	8b 10                	mov    (%eax),%edx
  800305:	3b 50 04             	cmp    0x4(%eax),%edx
  800308:	73 08                	jae    800312 <sprintputch+0x18>
		*b->buf++ = ch;
  80030a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80030d:	88 0a                	mov    %cl,(%edx)
  80030f:	42                   	inc    %edx
  800310:	89 10                	mov    %edx,(%eax)
}
  800312:	c9                   	leave  
  800313:	c3                   	ret    

00800314 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800314:	55                   	push   %ebp
  800315:	89 e5                	mov    %esp,%ebp
  800317:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80031a:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80031d:	50                   	push   %eax
  80031e:	ff 75 10             	pushl  0x10(%ebp)
  800321:	ff 75 0c             	pushl  0xc(%ebp)
  800324:	ff 75 08             	pushl  0x8(%ebp)
  800327:	e8 05 00 00 00       	call   800331 <vprintfmt>
	va_end(ap);
  80032c:	83 c4 10             	add    $0x10,%esp
}
  80032f:	c9                   	leave  
  800330:	c3                   	ret    

00800331 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800331:	55                   	push   %ebp
  800332:	89 e5                	mov    %esp,%ebp
  800334:	57                   	push   %edi
  800335:	56                   	push   %esi
  800336:	53                   	push   %ebx
  800337:	83 ec 2c             	sub    $0x2c,%esp
  80033a:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80033d:	8b 75 10             	mov    0x10(%ebp),%esi
  800340:	eb 13                	jmp    800355 <vprintfmt+0x24>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800342:	85 c0                	test   %eax,%eax
  800344:	0f 84 6d 03 00 00    	je     8006b7 <vprintfmt+0x386>
				return;
			putch(ch, putdat);
  80034a:	83 ec 08             	sub    $0x8,%esp
  80034d:	57                   	push   %edi
  80034e:	50                   	push   %eax
  80034f:	ff 55 08             	call   *0x8(%ebp)
  800352:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800355:	0f b6 06             	movzbl (%esi),%eax
  800358:	46                   	inc    %esi
  800359:	83 f8 25             	cmp    $0x25,%eax
  80035c:	75 e4                	jne    800342 <vprintfmt+0x11>
  80035e:	c6 45 dc 20          	movb   $0x20,-0x24(%ebp)
  800362:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  800369:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  800370:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800377:	b9 00 00 00 00       	mov    $0x0,%ecx
  80037c:	eb 28                	jmp    8003a6 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80037e:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800380:	c6 45 dc 2d          	movb   $0x2d,-0x24(%ebp)
  800384:	eb 20                	jmp    8003a6 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800386:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800388:	c6 45 dc 30          	movb   $0x30,-0x24(%ebp)
  80038c:	eb 18                	jmp    8003a6 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80038e:	89 de                	mov    %ebx,%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800390:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800397:	eb 0d                	jmp    8003a6 <vprintfmt+0x75>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800399:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80039c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80039f:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003a6:	8a 06                	mov    (%esi),%al
  8003a8:	0f b6 d0             	movzbl %al,%edx
  8003ab:	8d 5e 01             	lea    0x1(%esi),%ebx
  8003ae:	83 e8 23             	sub    $0x23,%eax
  8003b1:	3c 55                	cmp    $0x55,%al
  8003b3:	0f 87 e0 02 00 00    	ja     800699 <vprintfmt+0x368>
  8003b9:	0f b6 c0             	movzbl %al,%eax
  8003bc:	ff 24 85 40 28 80 00 	jmp    *0x802840(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003c3:	83 ea 30             	sub    $0x30,%edx
  8003c6:	89 55 d4             	mov    %edx,-0x2c(%ebp)
				ch = *fmt;
  8003c9:	0f be 03             	movsbl (%ebx),%eax
				if (ch < '0' || ch > '9')
  8003cc:	8d 50 d0             	lea    -0x30(%eax),%edx
  8003cf:	83 fa 09             	cmp    $0x9,%edx
  8003d2:	77 44                	ja     800418 <vprintfmt+0xe7>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003d4:	89 de                	mov    %ebx,%esi
  8003d6:	8b 55 d4             	mov    -0x2c(%ebp),%edx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003d9:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
  8003da:	8d 14 92             	lea    (%edx,%edx,4),%edx
  8003dd:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
  8003e1:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8003e4:	8d 58 d0             	lea    -0x30(%eax),%ebx
  8003e7:	83 fb 09             	cmp    $0x9,%ebx
  8003ea:	76 ed                	jbe    8003d9 <vprintfmt+0xa8>
  8003ec:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  8003ef:	eb 29                	jmp    80041a <vprintfmt+0xe9>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003f1:	8b 45 14             	mov    0x14(%ebp),%eax
  8003f4:	8d 50 04             	lea    0x4(%eax),%edx
  8003f7:	89 55 14             	mov    %edx,0x14(%ebp)
  8003fa:	8b 00                	mov    (%eax),%eax
  8003fc:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ff:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800401:	eb 17                	jmp    80041a <vprintfmt+0xe9>

		case '.':
			if (width < 0)
  800403:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800407:	78 85                	js     80038e <vprintfmt+0x5d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800409:	89 de                	mov    %ebx,%esi
  80040b:	eb 99                	jmp    8003a6 <vprintfmt+0x75>
  80040d:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80040f:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  800416:	eb 8e                	jmp    8003a6 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800418:	89 de                	mov    %ebx,%esi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  80041a:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80041e:	79 86                	jns    8003a6 <vprintfmt+0x75>
  800420:	e9 74 ff ff ff       	jmp    800399 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800425:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800426:	89 de                	mov    %ebx,%esi
  800428:	e9 79 ff ff ff       	jmp    8003a6 <vprintfmt+0x75>
  80042d:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800430:	8b 45 14             	mov    0x14(%ebp),%eax
  800433:	8d 50 04             	lea    0x4(%eax),%edx
  800436:	89 55 14             	mov    %edx,0x14(%ebp)
  800439:	83 ec 08             	sub    $0x8,%esp
  80043c:	57                   	push   %edi
  80043d:	ff 30                	pushl  (%eax)
  80043f:	ff 55 08             	call   *0x8(%ebp)
			break;
  800442:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800445:	8b 75 d8             	mov    -0x28(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800448:	e9 08 ff ff ff       	jmp    800355 <vprintfmt+0x24>
  80044d:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  800450:	8b 45 14             	mov    0x14(%ebp),%eax
  800453:	8d 50 04             	lea    0x4(%eax),%edx
  800456:	89 55 14             	mov    %edx,0x14(%ebp)
  800459:	8b 00                	mov    (%eax),%eax
  80045b:	85 c0                	test   %eax,%eax
  80045d:	79 02                	jns    800461 <vprintfmt+0x130>
  80045f:	f7 d8                	neg    %eax
  800461:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800463:	83 f8 0f             	cmp    $0xf,%eax
  800466:	7f 0b                	jg     800473 <vprintfmt+0x142>
  800468:	8b 04 85 a0 29 80 00 	mov    0x8029a0(,%eax,4),%eax
  80046f:	85 c0                	test   %eax,%eax
  800471:	75 1a                	jne    80048d <vprintfmt+0x15c>
				printfmt(putch, putdat, "error %d", err);
  800473:	52                   	push   %edx
  800474:	68 23 27 80 00       	push   $0x802723
  800479:	57                   	push   %edi
  80047a:	ff 75 08             	pushl  0x8(%ebp)
  80047d:	e8 92 fe ff ff       	call   800314 <printfmt>
  800482:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800485:	8b 75 d8             	mov    -0x28(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800488:	e9 c8 fe ff ff       	jmp    800355 <vprintfmt+0x24>
			else
				printfmt(putch, putdat, "%s", p);
  80048d:	50                   	push   %eax
  80048e:	68 d1 2a 80 00       	push   $0x802ad1
  800493:	57                   	push   %edi
  800494:	ff 75 08             	pushl  0x8(%ebp)
  800497:	e8 78 fe ff ff       	call   800314 <printfmt>
  80049c:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80049f:	8b 75 d8             	mov    -0x28(%ebp),%esi
  8004a2:	e9 ae fe ff ff       	jmp    800355 <vprintfmt+0x24>
  8004a7:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  8004aa:	89 de                	mov    %ebx,%esi
  8004ac:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  8004af:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004b2:	8b 45 14             	mov    0x14(%ebp),%eax
  8004b5:	8d 50 04             	lea    0x4(%eax),%edx
  8004b8:	89 55 14             	mov    %edx,0x14(%ebp)
  8004bb:	8b 00                	mov    (%eax),%eax
  8004bd:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8004c0:	85 c0                	test   %eax,%eax
  8004c2:	75 07                	jne    8004cb <vprintfmt+0x19a>
				p = "(null)";
  8004c4:	c7 45 d0 1c 27 80 00 	movl   $0x80271c,-0x30(%ebp)
			if (width > 0 && padc != '-')
  8004cb:	85 db                	test   %ebx,%ebx
  8004cd:	7e 42                	jle    800511 <vprintfmt+0x1e0>
  8004cf:	80 7d dc 2d          	cmpb   $0x2d,-0x24(%ebp)
  8004d3:	74 3c                	je     800511 <vprintfmt+0x1e0>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004d5:	83 ec 08             	sub    $0x8,%esp
  8004d8:	51                   	push   %ecx
  8004d9:	ff 75 d0             	pushl  -0x30(%ebp)
  8004dc:	e8 6f 02 00 00       	call   800750 <strnlen>
  8004e1:	29 c3                	sub    %eax,%ebx
  8004e3:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8004e6:	83 c4 10             	add    $0x10,%esp
  8004e9:	85 db                	test   %ebx,%ebx
  8004eb:	7e 24                	jle    800511 <vprintfmt+0x1e0>
					putch(padc, putdat);
  8004ed:	0f be 5d dc          	movsbl -0x24(%ebp),%ebx
  8004f1:	89 75 dc             	mov    %esi,-0x24(%ebp)
  8004f4:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  8004f7:	83 ec 08             	sub    $0x8,%esp
  8004fa:	57                   	push   %edi
  8004fb:	53                   	push   %ebx
  8004fc:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004ff:	4e                   	dec    %esi
  800500:	83 c4 10             	add    $0x10,%esp
  800503:	85 f6                	test   %esi,%esi
  800505:	7f f0                	jg     8004f7 <vprintfmt+0x1c6>
  800507:	8b 75 dc             	mov    -0x24(%ebp),%esi
  80050a:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800511:	8b 55 d0             	mov    -0x30(%ebp),%edx
  800514:	0f be 02             	movsbl (%edx),%eax
  800517:	85 c0                	test   %eax,%eax
  800519:	75 47                	jne    800562 <vprintfmt+0x231>
  80051b:	eb 37                	jmp    800554 <vprintfmt+0x223>
				if (altflag && (ch < ' ' || ch > '~'))
  80051d:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800521:	74 16                	je     800539 <vprintfmt+0x208>
  800523:	8d 50 e0             	lea    -0x20(%eax),%edx
  800526:	83 fa 5e             	cmp    $0x5e,%edx
  800529:	76 0e                	jbe    800539 <vprintfmt+0x208>
					putch('?', putdat);
  80052b:	83 ec 08             	sub    $0x8,%esp
  80052e:	57                   	push   %edi
  80052f:	6a 3f                	push   $0x3f
  800531:	ff 55 08             	call   *0x8(%ebp)
  800534:	83 c4 10             	add    $0x10,%esp
  800537:	eb 0b                	jmp    800544 <vprintfmt+0x213>
				else
					putch(ch, putdat);
  800539:	83 ec 08             	sub    $0x8,%esp
  80053c:	57                   	push   %edi
  80053d:	50                   	push   %eax
  80053e:	ff 55 08             	call   *0x8(%ebp)
  800541:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800544:	ff 4d e4             	decl   -0x1c(%ebp)
  800547:	0f be 03             	movsbl (%ebx),%eax
  80054a:	85 c0                	test   %eax,%eax
  80054c:	74 03                	je     800551 <vprintfmt+0x220>
  80054e:	43                   	inc    %ebx
  80054f:	eb 1b                	jmp    80056c <vprintfmt+0x23b>
  800551:	8b 75 dc             	mov    -0x24(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800554:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800558:	7f 1e                	jg     800578 <vprintfmt+0x247>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80055a:	8b 75 d8             	mov    -0x28(%ebp),%esi
  80055d:	e9 f3 fd ff ff       	jmp    800355 <vprintfmt+0x24>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800562:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800565:	43                   	inc    %ebx
  800566:	89 75 dc             	mov    %esi,-0x24(%ebp)
  800569:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  80056c:	85 f6                	test   %esi,%esi
  80056e:	78 ad                	js     80051d <vprintfmt+0x1ec>
  800570:	4e                   	dec    %esi
  800571:	79 aa                	jns    80051d <vprintfmt+0x1ec>
  800573:	8b 75 dc             	mov    -0x24(%ebp),%esi
  800576:	eb dc                	jmp    800554 <vprintfmt+0x223>
  800578:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80057b:	83 ec 08             	sub    $0x8,%esp
  80057e:	57                   	push   %edi
  80057f:	6a 20                	push   $0x20
  800581:	ff 55 08             	call   *0x8(%ebp)
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800584:	4b                   	dec    %ebx
  800585:	83 c4 10             	add    $0x10,%esp
  800588:	85 db                	test   %ebx,%ebx
  80058a:	7f ef                	jg     80057b <vprintfmt+0x24a>
  80058c:	e9 c4 fd ff ff       	jmp    800355 <vprintfmt+0x24>
  800591:	89 5d d8             	mov    %ebx,-0x28(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800594:	89 ca                	mov    %ecx,%edx
  800596:	8d 45 14             	lea    0x14(%ebp),%eax
  800599:	e8 2a fd ff ff       	call   8002c8 <getint>
  80059e:	89 c3                	mov    %eax,%ebx
  8005a0:	89 d6                	mov    %edx,%esi
			if ((long long) num < 0) {
  8005a2:	85 d2                	test   %edx,%edx
  8005a4:	78 0a                	js     8005b0 <vprintfmt+0x27f>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8005a6:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005ab:	e9 b0 00 00 00       	jmp    800660 <vprintfmt+0x32f>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  8005b0:	83 ec 08             	sub    $0x8,%esp
  8005b3:	57                   	push   %edi
  8005b4:	6a 2d                	push   $0x2d
  8005b6:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8005b9:	f7 db                	neg    %ebx
  8005bb:	83 d6 00             	adc    $0x0,%esi
  8005be:	f7 de                	neg    %esi
  8005c0:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8005c3:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005c8:	e9 93 00 00 00       	jmp    800660 <vprintfmt+0x32f>
  8005cd:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8005d0:	89 ca                	mov    %ecx,%edx
  8005d2:	8d 45 14             	lea    0x14(%ebp),%eax
  8005d5:	e8 b4 fc ff ff       	call   80028e <getuint>
  8005da:	89 c3                	mov    %eax,%ebx
  8005dc:	89 d6                	mov    %edx,%esi
			base = 10;
  8005de:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  8005e3:	eb 7b                	jmp    800660 <vprintfmt+0x32f>
  8005e5:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
  8005e8:	89 ca                	mov    %ecx,%edx
  8005ea:	8d 45 14             	lea    0x14(%ebp),%eax
  8005ed:	e8 d6 fc ff ff       	call   8002c8 <getint>
  8005f2:	89 c3                	mov    %eax,%ebx
  8005f4:	89 d6                	mov    %edx,%esi
            if ((long long) num < 0) {
  8005f6:	85 d2                	test   %edx,%edx
  8005f8:	78 07                	js     800601 <vprintfmt+0x2d0>
                putch('-', putdat);
                num = -(long long) num;
            }
            base = 8;
  8005fa:	b8 08 00 00 00       	mov    $0x8,%eax
  8005ff:	eb 5f                	jmp    800660 <vprintfmt+0x32f>
		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
            if ((long long) num < 0) {
                putch('-', putdat);
  800601:	83 ec 08             	sub    $0x8,%esp
  800604:	57                   	push   %edi
  800605:	6a 2d                	push   $0x2d
  800607:	ff 55 08             	call   *0x8(%ebp)
                num = -(long long) num;
  80060a:	f7 db                	neg    %ebx
  80060c:	83 d6 00             	adc    $0x0,%esi
  80060f:	f7 de                	neg    %esi
  800611:	83 c4 10             	add    $0x10,%esp
            }
            base = 8;
  800614:	b8 08 00 00 00       	mov    $0x8,%eax
  800619:	eb 45                	jmp    800660 <vprintfmt+0x32f>
  80061b:	89 5d d8             	mov    %ebx,-0x28(%ebp)
            goto number;

        // pointer
		case 'p':
			putch('0', putdat);
  80061e:	83 ec 08             	sub    $0x8,%esp
  800621:	57                   	push   %edi
  800622:	6a 30                	push   $0x30
  800624:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800627:	83 c4 08             	add    $0x8,%esp
  80062a:	57                   	push   %edi
  80062b:	6a 78                	push   $0x78
  80062d:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800630:	8b 45 14             	mov    0x14(%ebp),%eax
  800633:	8d 50 04             	lea    0x4(%eax),%edx
  800636:	89 55 14             	mov    %edx,0x14(%ebp)

        // pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800639:	8b 18                	mov    (%eax),%ebx
  80063b:	be 00 00 00 00       	mov    $0x0,%esi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800640:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800643:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800648:	eb 16                	jmp    800660 <vprintfmt+0x32f>
  80064a:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80064d:	89 ca                	mov    %ecx,%edx
  80064f:	8d 45 14             	lea    0x14(%ebp),%eax
  800652:	e8 37 fc ff ff       	call   80028e <getuint>
  800657:	89 c3                	mov    %eax,%ebx
  800659:	89 d6                	mov    %edx,%esi
			base = 16;
  80065b:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800660:	83 ec 0c             	sub    $0xc,%esp
  800663:	0f be 55 dc          	movsbl -0x24(%ebp),%edx
  800667:	52                   	push   %edx
  800668:	ff 75 e4             	pushl  -0x1c(%ebp)
  80066b:	50                   	push   %eax
  80066c:	56                   	push   %esi
  80066d:	53                   	push   %ebx
  80066e:	89 fa                	mov    %edi,%edx
  800670:	8b 45 08             	mov    0x8(%ebp),%eax
  800673:	e8 68 fb ff ff       	call   8001e0 <printnum>
			break;
  800678:	83 c4 20             	add    $0x20,%esp
  80067b:	8b 75 d8             	mov    -0x28(%ebp),%esi
  80067e:	e9 d2 fc ff ff       	jmp    800355 <vprintfmt+0x24>
  800683:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800686:	83 ec 08             	sub    $0x8,%esp
  800689:	57                   	push   %edi
  80068a:	52                   	push   %edx
  80068b:	ff 55 08             	call   *0x8(%ebp)
			break;
  80068e:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800691:	8b 75 d8             	mov    -0x28(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800694:	e9 bc fc ff ff       	jmp    800355 <vprintfmt+0x24>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800699:	83 ec 08             	sub    $0x8,%esp
  80069c:	57                   	push   %edi
  80069d:	6a 25                	push   $0x25
  80069f:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006a2:	83 c4 10             	add    $0x10,%esp
  8006a5:	eb 02                	jmp    8006a9 <vprintfmt+0x378>
  8006a7:	89 c6                	mov    %eax,%esi
  8006a9:	8d 46 ff             	lea    -0x1(%esi),%eax
  8006ac:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  8006b0:	75 f5                	jne    8006a7 <vprintfmt+0x376>
  8006b2:	e9 9e fc ff ff       	jmp    800355 <vprintfmt+0x24>
				/* do nothing */;
			break;
		}
	}
}
  8006b7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006ba:	5b                   	pop    %ebx
  8006bb:	5e                   	pop    %esi
  8006bc:	5f                   	pop    %edi
  8006bd:	c9                   	leave  
  8006be:	c3                   	ret    

008006bf <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006bf:	55                   	push   %ebp
  8006c0:	89 e5                	mov    %esp,%ebp
  8006c2:	83 ec 18             	sub    $0x18,%esp
  8006c5:	8b 45 08             	mov    0x8(%ebp),%eax
  8006c8:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006cb:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006ce:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8006d2:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8006d5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8006dc:	85 c0                	test   %eax,%eax
  8006de:	74 26                	je     800706 <vsnprintf+0x47>
  8006e0:	85 d2                	test   %edx,%edx
  8006e2:	7e 29                	jle    80070d <vsnprintf+0x4e>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8006e4:	ff 75 14             	pushl  0x14(%ebp)
  8006e7:	ff 75 10             	pushl  0x10(%ebp)
  8006ea:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8006ed:	50                   	push   %eax
  8006ee:	68 fa 02 80 00       	push   $0x8002fa
  8006f3:	e8 39 fc ff ff       	call   800331 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8006f8:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8006fb:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8006fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800701:	83 c4 10             	add    $0x10,%esp
  800704:	eb 0c                	jmp    800712 <vsnprintf+0x53>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800706:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80070b:	eb 05                	jmp    800712 <vsnprintf+0x53>
  80070d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800712:	c9                   	leave  
  800713:	c3                   	ret    

00800714 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800714:	55                   	push   %ebp
  800715:	89 e5                	mov    %esp,%ebp
  800717:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80071a:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80071d:	50                   	push   %eax
  80071e:	ff 75 10             	pushl  0x10(%ebp)
  800721:	ff 75 0c             	pushl  0xc(%ebp)
  800724:	ff 75 08             	pushl  0x8(%ebp)
  800727:	e8 93 ff ff ff       	call   8006bf <vsnprintf>
	va_end(ap);

	return rc;
}
  80072c:	c9                   	leave  
  80072d:	c3                   	ret    
	...

00800730 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800730:	55                   	push   %ebp
  800731:	89 e5                	mov    %esp,%ebp
  800733:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800736:	80 3a 00             	cmpb   $0x0,(%edx)
  800739:	74 0e                	je     800749 <strlen+0x19>
  80073b:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800740:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800741:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800745:	75 f9                	jne    800740 <strlen+0x10>
  800747:	eb 05                	jmp    80074e <strlen+0x1e>
  800749:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  80074e:	c9                   	leave  
  80074f:	c3                   	ret    

00800750 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800750:	55                   	push   %ebp
  800751:	89 e5                	mov    %esp,%ebp
  800753:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800756:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800759:	85 d2                	test   %edx,%edx
  80075b:	74 17                	je     800774 <strnlen+0x24>
  80075d:	80 39 00             	cmpb   $0x0,(%ecx)
  800760:	74 19                	je     80077b <strnlen+0x2b>
  800762:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800767:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800768:	39 d0                	cmp    %edx,%eax
  80076a:	74 14                	je     800780 <strnlen+0x30>
  80076c:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800770:	75 f5                	jne    800767 <strnlen+0x17>
  800772:	eb 0c                	jmp    800780 <strnlen+0x30>
  800774:	b8 00 00 00 00       	mov    $0x0,%eax
  800779:	eb 05                	jmp    800780 <strnlen+0x30>
  80077b:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800780:	c9                   	leave  
  800781:	c3                   	ret    

00800782 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800782:	55                   	push   %ebp
  800783:	89 e5                	mov    %esp,%ebp
  800785:	53                   	push   %ebx
  800786:	8b 45 08             	mov    0x8(%ebp),%eax
  800789:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80078c:	ba 00 00 00 00       	mov    $0x0,%edx
  800791:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  800794:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800797:	42                   	inc    %edx
  800798:	84 c9                	test   %cl,%cl
  80079a:	75 f5                	jne    800791 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  80079c:	5b                   	pop    %ebx
  80079d:	c9                   	leave  
  80079e:	c3                   	ret    

0080079f <strcat>:

char *
strcat(char *dst, const char *src)
{
  80079f:	55                   	push   %ebp
  8007a0:	89 e5                	mov    %esp,%ebp
  8007a2:	53                   	push   %ebx
  8007a3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007a6:	53                   	push   %ebx
  8007a7:	e8 84 ff ff ff       	call   800730 <strlen>
  8007ac:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8007af:	ff 75 0c             	pushl  0xc(%ebp)
  8007b2:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  8007b5:	50                   	push   %eax
  8007b6:	e8 c7 ff ff ff       	call   800782 <strcpy>
	return dst;
}
  8007bb:	89 d8                	mov    %ebx,%eax
  8007bd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007c0:	c9                   	leave  
  8007c1:	c3                   	ret    

008007c2 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007c2:	55                   	push   %ebp
  8007c3:	89 e5                	mov    %esp,%ebp
  8007c5:	56                   	push   %esi
  8007c6:	53                   	push   %ebx
  8007c7:	8b 45 08             	mov    0x8(%ebp),%eax
  8007ca:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007cd:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007d0:	85 f6                	test   %esi,%esi
  8007d2:	74 15                	je     8007e9 <strncpy+0x27>
  8007d4:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  8007d9:	8a 1a                	mov    (%edx),%bl
  8007db:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007de:	80 3a 01             	cmpb   $0x1,(%edx)
  8007e1:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007e4:	41                   	inc    %ecx
  8007e5:	39 ce                	cmp    %ecx,%esi
  8007e7:	77 f0                	ja     8007d9 <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8007e9:	5b                   	pop    %ebx
  8007ea:	5e                   	pop    %esi
  8007eb:	c9                   	leave  
  8007ec:	c3                   	ret    

008007ed <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8007ed:	55                   	push   %ebp
  8007ee:	89 e5                	mov    %esp,%ebp
  8007f0:	57                   	push   %edi
  8007f1:	56                   	push   %esi
  8007f2:	53                   	push   %ebx
  8007f3:	8b 7d 08             	mov    0x8(%ebp),%edi
  8007f6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8007f9:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007fc:	85 f6                	test   %esi,%esi
  8007fe:	74 32                	je     800832 <strlcpy+0x45>
		while (--size > 0 && *src != '\0')
  800800:	83 fe 01             	cmp    $0x1,%esi
  800803:	74 22                	je     800827 <strlcpy+0x3a>
  800805:	8a 0b                	mov    (%ebx),%cl
  800807:	84 c9                	test   %cl,%cl
  800809:	74 20                	je     80082b <strlcpy+0x3e>
  80080b:	89 f8                	mov    %edi,%eax
  80080d:	ba 00 00 00 00       	mov    $0x0,%edx
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
  800812:	83 ee 02             	sub    $0x2,%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800815:	88 08                	mov    %cl,(%eax)
  800817:	40                   	inc    %eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800818:	39 f2                	cmp    %esi,%edx
  80081a:	74 11                	je     80082d <strlcpy+0x40>
  80081c:	8a 4c 13 01          	mov    0x1(%ebx,%edx,1),%cl
  800820:	42                   	inc    %edx
  800821:	84 c9                	test   %cl,%cl
  800823:	75 f0                	jne    800815 <strlcpy+0x28>
  800825:	eb 06                	jmp    80082d <strlcpy+0x40>
  800827:	89 f8                	mov    %edi,%eax
  800829:	eb 02                	jmp    80082d <strlcpy+0x40>
  80082b:	89 f8                	mov    %edi,%eax
			*dst++ = *src++;
		*dst = '\0';
  80082d:	c6 00 00             	movb   $0x0,(%eax)
  800830:	eb 02                	jmp    800834 <strlcpy+0x47>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800832:	89 f8                	mov    %edi,%eax
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
		*dst = '\0';
	}
	return dst - dst_in;
  800834:	29 f8                	sub    %edi,%eax
}
  800836:	5b                   	pop    %ebx
  800837:	5e                   	pop    %esi
  800838:	5f                   	pop    %edi
  800839:	c9                   	leave  
  80083a:	c3                   	ret    

0080083b <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80083b:	55                   	push   %ebp
  80083c:	89 e5                	mov    %esp,%ebp
  80083e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800841:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800844:	8a 01                	mov    (%ecx),%al
  800846:	84 c0                	test   %al,%al
  800848:	74 10                	je     80085a <strcmp+0x1f>
  80084a:	3a 02                	cmp    (%edx),%al
  80084c:	75 0c                	jne    80085a <strcmp+0x1f>
		p++, q++;
  80084e:	41                   	inc    %ecx
  80084f:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800850:	8a 01                	mov    (%ecx),%al
  800852:	84 c0                	test   %al,%al
  800854:	74 04                	je     80085a <strcmp+0x1f>
  800856:	3a 02                	cmp    (%edx),%al
  800858:	74 f4                	je     80084e <strcmp+0x13>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80085a:	0f b6 c0             	movzbl %al,%eax
  80085d:	0f b6 12             	movzbl (%edx),%edx
  800860:	29 d0                	sub    %edx,%eax
}
  800862:	c9                   	leave  
  800863:	c3                   	ret    

00800864 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800864:	55                   	push   %ebp
  800865:	89 e5                	mov    %esp,%ebp
  800867:	53                   	push   %ebx
  800868:	8b 55 08             	mov    0x8(%ebp),%edx
  80086b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80086e:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  800871:	85 c0                	test   %eax,%eax
  800873:	74 1b                	je     800890 <strncmp+0x2c>
  800875:	8a 1a                	mov    (%edx),%bl
  800877:	84 db                	test   %bl,%bl
  800879:	74 24                	je     80089f <strncmp+0x3b>
  80087b:	3a 19                	cmp    (%ecx),%bl
  80087d:	75 20                	jne    80089f <strncmp+0x3b>
  80087f:	48                   	dec    %eax
  800880:	74 15                	je     800897 <strncmp+0x33>
		n--, p++, q++;
  800882:	42                   	inc    %edx
  800883:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800884:	8a 1a                	mov    (%edx),%bl
  800886:	84 db                	test   %bl,%bl
  800888:	74 15                	je     80089f <strncmp+0x3b>
  80088a:	3a 19                	cmp    (%ecx),%bl
  80088c:	74 f1                	je     80087f <strncmp+0x1b>
  80088e:	eb 0f                	jmp    80089f <strncmp+0x3b>
		n--, p++, q++;
	if (n == 0)
		return 0;
  800890:	b8 00 00 00 00       	mov    $0x0,%eax
  800895:	eb 05                	jmp    80089c <strncmp+0x38>
  800897:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80089c:	5b                   	pop    %ebx
  80089d:	c9                   	leave  
  80089e:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80089f:	0f b6 02             	movzbl (%edx),%eax
  8008a2:	0f b6 11             	movzbl (%ecx),%edx
  8008a5:	29 d0                	sub    %edx,%eax
  8008a7:	eb f3                	jmp    80089c <strncmp+0x38>

008008a9 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008a9:	55                   	push   %ebp
  8008aa:	89 e5                	mov    %esp,%ebp
  8008ac:	8b 45 08             	mov    0x8(%ebp),%eax
  8008af:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8008b2:	8a 10                	mov    (%eax),%dl
  8008b4:	84 d2                	test   %dl,%dl
  8008b6:	74 18                	je     8008d0 <strchr+0x27>
		if (*s == c)
  8008b8:	38 ca                	cmp    %cl,%dl
  8008ba:	75 06                	jne    8008c2 <strchr+0x19>
  8008bc:	eb 17                	jmp    8008d5 <strchr+0x2c>
  8008be:	38 ca                	cmp    %cl,%dl
  8008c0:	74 13                	je     8008d5 <strchr+0x2c>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8008c2:	40                   	inc    %eax
  8008c3:	8a 10                	mov    (%eax),%dl
  8008c5:	84 d2                	test   %dl,%dl
  8008c7:	75 f5                	jne    8008be <strchr+0x15>
		if (*s == c)
			return (char *) s;
	return 0;
  8008c9:	b8 00 00 00 00       	mov    $0x0,%eax
  8008ce:	eb 05                	jmp    8008d5 <strchr+0x2c>
  8008d0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008d5:	c9                   	leave  
  8008d6:	c3                   	ret    

008008d7 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008d7:	55                   	push   %ebp
  8008d8:	89 e5                	mov    %esp,%ebp
  8008da:	8b 45 08             	mov    0x8(%ebp),%eax
  8008dd:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8008e0:	8a 10                	mov    (%eax),%dl
  8008e2:	84 d2                	test   %dl,%dl
  8008e4:	74 11                	je     8008f7 <strfind+0x20>
		if (*s == c)
  8008e6:	38 ca                	cmp    %cl,%dl
  8008e8:	75 06                	jne    8008f0 <strfind+0x19>
  8008ea:	eb 0b                	jmp    8008f7 <strfind+0x20>
  8008ec:	38 ca                	cmp    %cl,%dl
  8008ee:	74 07                	je     8008f7 <strfind+0x20>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  8008f0:	40                   	inc    %eax
  8008f1:	8a 10                	mov    (%eax),%dl
  8008f3:	84 d2                	test   %dl,%dl
  8008f5:	75 f5                	jne    8008ec <strfind+0x15>
		if (*s == c)
			break;
	return (char *) s;
}
  8008f7:	c9                   	leave  
  8008f8:	c3                   	ret    

008008f9 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008f9:	55                   	push   %ebp
  8008fa:	89 e5                	mov    %esp,%ebp
  8008fc:	57                   	push   %edi
  8008fd:	56                   	push   %esi
  8008fe:	53                   	push   %ebx
  8008ff:	8b 7d 08             	mov    0x8(%ebp),%edi
  800902:	8b 45 0c             	mov    0xc(%ebp),%eax
  800905:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800908:	85 c9                	test   %ecx,%ecx
  80090a:	74 30                	je     80093c <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80090c:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800912:	75 25                	jne    800939 <memset+0x40>
  800914:	f6 c1 03             	test   $0x3,%cl
  800917:	75 20                	jne    800939 <memset+0x40>
		c &= 0xFF;
  800919:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80091c:	89 d3                	mov    %edx,%ebx
  80091e:	c1 e3 08             	shl    $0x8,%ebx
  800921:	89 d6                	mov    %edx,%esi
  800923:	c1 e6 18             	shl    $0x18,%esi
  800926:	89 d0                	mov    %edx,%eax
  800928:	c1 e0 10             	shl    $0x10,%eax
  80092b:	09 f0                	or     %esi,%eax
  80092d:	09 d0                	or     %edx,%eax
  80092f:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800931:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800934:	fc                   	cld    
  800935:	f3 ab                	rep stos %eax,%es:(%edi)
  800937:	eb 03                	jmp    80093c <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800939:	fc                   	cld    
  80093a:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80093c:	89 f8                	mov    %edi,%eax
  80093e:	5b                   	pop    %ebx
  80093f:	5e                   	pop    %esi
  800940:	5f                   	pop    %edi
  800941:	c9                   	leave  
  800942:	c3                   	ret    

00800943 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800943:	55                   	push   %ebp
  800944:	89 e5                	mov    %esp,%ebp
  800946:	57                   	push   %edi
  800947:	56                   	push   %esi
  800948:	8b 45 08             	mov    0x8(%ebp),%eax
  80094b:	8b 75 0c             	mov    0xc(%ebp),%esi
  80094e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800951:	39 c6                	cmp    %eax,%esi
  800953:	73 34                	jae    800989 <memmove+0x46>
  800955:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800958:	39 d0                	cmp    %edx,%eax
  80095a:	73 2d                	jae    800989 <memmove+0x46>
		s += n;
		d += n;
  80095c:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80095f:	f6 c2 03             	test   $0x3,%dl
  800962:	75 1b                	jne    80097f <memmove+0x3c>
  800964:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80096a:	75 13                	jne    80097f <memmove+0x3c>
  80096c:	f6 c1 03             	test   $0x3,%cl
  80096f:	75 0e                	jne    80097f <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800971:	83 ef 04             	sub    $0x4,%edi
  800974:	8d 72 fc             	lea    -0x4(%edx),%esi
  800977:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  80097a:	fd                   	std    
  80097b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80097d:	eb 07                	jmp    800986 <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  80097f:	4f                   	dec    %edi
  800980:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800983:	fd                   	std    
  800984:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800986:	fc                   	cld    
  800987:	eb 20                	jmp    8009a9 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800989:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80098f:	75 13                	jne    8009a4 <memmove+0x61>
  800991:	a8 03                	test   $0x3,%al
  800993:	75 0f                	jne    8009a4 <memmove+0x61>
  800995:	f6 c1 03             	test   $0x3,%cl
  800998:	75 0a                	jne    8009a4 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  80099a:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  80099d:	89 c7                	mov    %eax,%edi
  80099f:	fc                   	cld    
  8009a0:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009a2:	eb 05                	jmp    8009a9 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8009a4:	89 c7                	mov    %eax,%edi
  8009a6:	fc                   	cld    
  8009a7:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009a9:	5e                   	pop    %esi
  8009aa:	5f                   	pop    %edi
  8009ab:	c9                   	leave  
  8009ac:	c3                   	ret    

008009ad <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009ad:	55                   	push   %ebp
  8009ae:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8009b0:	ff 75 10             	pushl  0x10(%ebp)
  8009b3:	ff 75 0c             	pushl  0xc(%ebp)
  8009b6:	ff 75 08             	pushl  0x8(%ebp)
  8009b9:	e8 85 ff ff ff       	call   800943 <memmove>
}
  8009be:	c9                   	leave  
  8009bf:	c3                   	ret    

008009c0 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009c0:	55                   	push   %ebp
  8009c1:	89 e5                	mov    %esp,%ebp
  8009c3:	57                   	push   %edi
  8009c4:	56                   	push   %esi
  8009c5:	53                   	push   %ebx
  8009c6:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8009c9:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009cc:	8b 7d 10             	mov    0x10(%ebp),%edi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009cf:	85 ff                	test   %edi,%edi
  8009d1:	74 32                	je     800a05 <memcmp+0x45>
		if (*s1 != *s2)
  8009d3:	8a 03                	mov    (%ebx),%al
  8009d5:	8a 0e                	mov    (%esi),%cl
  8009d7:	38 c8                	cmp    %cl,%al
  8009d9:	74 19                	je     8009f4 <memcmp+0x34>
  8009db:	eb 0d                	jmp    8009ea <memcmp+0x2a>
  8009dd:	8a 44 13 01          	mov    0x1(%ebx,%edx,1),%al
  8009e1:	8a 4c 16 01          	mov    0x1(%esi,%edx,1),%cl
  8009e5:	42                   	inc    %edx
  8009e6:	38 c8                	cmp    %cl,%al
  8009e8:	74 10                	je     8009fa <memcmp+0x3a>
			return (int) *s1 - (int) *s2;
  8009ea:	0f b6 c0             	movzbl %al,%eax
  8009ed:	0f b6 c9             	movzbl %cl,%ecx
  8009f0:	29 c8                	sub    %ecx,%eax
  8009f2:	eb 16                	jmp    800a0a <memcmp+0x4a>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009f4:	4f                   	dec    %edi
  8009f5:	ba 00 00 00 00       	mov    $0x0,%edx
  8009fa:	39 fa                	cmp    %edi,%edx
  8009fc:	75 df                	jne    8009dd <memcmp+0x1d>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8009fe:	b8 00 00 00 00       	mov    $0x0,%eax
  800a03:	eb 05                	jmp    800a0a <memcmp+0x4a>
  800a05:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a0a:	5b                   	pop    %ebx
  800a0b:	5e                   	pop    %esi
  800a0c:	5f                   	pop    %edi
  800a0d:	c9                   	leave  
  800a0e:	c3                   	ret    

00800a0f <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a0f:	55                   	push   %ebp
  800a10:	89 e5                	mov    %esp,%ebp
  800a12:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800a15:	89 c2                	mov    %eax,%edx
  800a17:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a1a:	39 d0                	cmp    %edx,%eax
  800a1c:	73 12                	jae    800a30 <memfind+0x21>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a1e:	8a 4d 0c             	mov    0xc(%ebp),%cl
  800a21:	38 08                	cmp    %cl,(%eax)
  800a23:	75 06                	jne    800a2b <memfind+0x1c>
  800a25:	eb 09                	jmp    800a30 <memfind+0x21>
  800a27:	38 08                	cmp    %cl,(%eax)
  800a29:	74 05                	je     800a30 <memfind+0x21>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a2b:	40                   	inc    %eax
  800a2c:	39 c2                	cmp    %eax,%edx
  800a2e:	77 f7                	ja     800a27 <memfind+0x18>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a30:	c9                   	leave  
  800a31:	c3                   	ret    

00800a32 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a32:	55                   	push   %ebp
  800a33:	89 e5                	mov    %esp,%ebp
  800a35:	57                   	push   %edi
  800a36:	56                   	push   %esi
  800a37:	53                   	push   %ebx
  800a38:	8b 55 08             	mov    0x8(%ebp),%edx
  800a3b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a3e:	eb 01                	jmp    800a41 <strtol+0xf>
		s++;
  800a40:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a41:	8a 02                	mov    (%edx),%al
  800a43:	3c 20                	cmp    $0x20,%al
  800a45:	74 f9                	je     800a40 <strtol+0xe>
  800a47:	3c 09                	cmp    $0x9,%al
  800a49:	74 f5                	je     800a40 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a4b:	3c 2b                	cmp    $0x2b,%al
  800a4d:	75 08                	jne    800a57 <strtol+0x25>
		s++;
  800a4f:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a50:	bf 00 00 00 00       	mov    $0x0,%edi
  800a55:	eb 13                	jmp    800a6a <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a57:	3c 2d                	cmp    $0x2d,%al
  800a59:	75 0a                	jne    800a65 <strtol+0x33>
		s++, neg = 1;
  800a5b:	8d 52 01             	lea    0x1(%edx),%edx
  800a5e:	bf 01 00 00 00       	mov    $0x1,%edi
  800a63:	eb 05                	jmp    800a6a <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a65:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a6a:	85 db                	test   %ebx,%ebx
  800a6c:	74 05                	je     800a73 <strtol+0x41>
  800a6e:	83 fb 10             	cmp    $0x10,%ebx
  800a71:	75 28                	jne    800a9b <strtol+0x69>
  800a73:	8a 02                	mov    (%edx),%al
  800a75:	3c 30                	cmp    $0x30,%al
  800a77:	75 10                	jne    800a89 <strtol+0x57>
  800a79:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800a7d:	75 0a                	jne    800a89 <strtol+0x57>
		s += 2, base = 16;
  800a7f:	83 c2 02             	add    $0x2,%edx
  800a82:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a87:	eb 12                	jmp    800a9b <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800a89:	85 db                	test   %ebx,%ebx
  800a8b:	75 0e                	jne    800a9b <strtol+0x69>
  800a8d:	3c 30                	cmp    $0x30,%al
  800a8f:	75 05                	jne    800a96 <strtol+0x64>
		s++, base = 8;
  800a91:	42                   	inc    %edx
  800a92:	b3 08                	mov    $0x8,%bl
  800a94:	eb 05                	jmp    800a9b <strtol+0x69>
	else if (base == 0)
		base = 10;
  800a96:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800a9b:	b8 00 00 00 00       	mov    $0x0,%eax
  800aa0:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800aa2:	8a 0a                	mov    (%edx),%cl
  800aa4:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800aa7:	80 fb 09             	cmp    $0x9,%bl
  800aaa:	77 08                	ja     800ab4 <strtol+0x82>
			dig = *s - '0';
  800aac:	0f be c9             	movsbl %cl,%ecx
  800aaf:	83 e9 30             	sub    $0x30,%ecx
  800ab2:	eb 1e                	jmp    800ad2 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800ab4:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800ab7:	80 fb 19             	cmp    $0x19,%bl
  800aba:	77 08                	ja     800ac4 <strtol+0x92>
			dig = *s - 'a' + 10;
  800abc:	0f be c9             	movsbl %cl,%ecx
  800abf:	83 e9 57             	sub    $0x57,%ecx
  800ac2:	eb 0e                	jmp    800ad2 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800ac4:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800ac7:	80 fb 19             	cmp    $0x19,%bl
  800aca:	77 13                	ja     800adf <strtol+0xad>
			dig = *s - 'A' + 10;
  800acc:	0f be c9             	movsbl %cl,%ecx
  800acf:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800ad2:	39 f1                	cmp    %esi,%ecx
  800ad4:	7d 0d                	jge    800ae3 <strtol+0xb1>
			break;
		s++, val = (val * base) + dig;
  800ad6:	42                   	inc    %edx
  800ad7:	0f af c6             	imul   %esi,%eax
  800ada:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  800add:	eb c3                	jmp    800aa2 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800adf:	89 c1                	mov    %eax,%ecx
  800ae1:	eb 02                	jmp    800ae5 <strtol+0xb3>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800ae3:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800ae5:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ae9:	74 05                	je     800af0 <strtol+0xbe>
		*endptr = (char *) s;
  800aeb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800aee:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800af0:	85 ff                	test   %edi,%edi
  800af2:	74 04                	je     800af8 <strtol+0xc6>
  800af4:	89 c8                	mov    %ecx,%eax
  800af6:	f7 d8                	neg    %eax
}
  800af8:	5b                   	pop    %ebx
  800af9:	5e                   	pop    %esi
  800afa:	5f                   	pop    %edi
  800afb:	c9                   	leave  
  800afc:	c3                   	ret    
  800afd:	00 00                	add    %al,(%eax)
	...

00800b00 <syscall>:
	return ret;
}

static int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800b00:	55                   	push   %ebp
  800b01:	89 e5                	mov    %esp,%ebp
  800b03:	57                   	push   %edi
  800b04:	56                   	push   %esi
  800b05:	53                   	push   %ebx
  800b06:	83 ec 1c             	sub    $0x1c,%esp
  800b09:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800b0c:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800b0f:	89 ca                	mov    %ecx,%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b11:	8b 75 14             	mov    0x14(%ebp),%esi
  800b14:	8b 7d 10             	mov    0x10(%ebp),%edi
  800b17:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800b1a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b1d:	cd 30                	int    $0x30
  800b1f:	89 c2                	mov    %eax,%edx
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b21:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800b25:	74 1c                	je     800b43 <syscall+0x43>
  800b27:	85 c0                	test   %eax,%eax
  800b29:	7e 18                	jle    800b43 <syscall+0x43>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b2b:	83 ec 0c             	sub    $0xc,%esp
  800b2e:	50                   	push   %eax
  800b2f:	ff 75 e4             	pushl  -0x1c(%ebp)
  800b32:	68 ff 29 80 00       	push   $0x8029ff
  800b37:	6a 42                	push   $0x42
  800b39:	68 1c 2a 80 00       	push   $0x802a1c
  800b3e:	e8 b1 f5 ff ff       	call   8000f4 <_panic>

	return ret;
}
  800b43:	89 d0                	mov    %edx,%eax
  800b45:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b48:	5b                   	pop    %ebx
  800b49:	5e                   	pop    %esi
  800b4a:	5f                   	pop    %edi
  800b4b:	c9                   	leave  
  800b4c:	c3                   	ret    

00800b4d <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{	
  800b4d:	55                   	push   %ebp
  800b4e:	89 e5                	mov    %esp,%ebp
  800b50:	83 ec 08             	sub    $0x8,%esp
	// my_sysenter(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
	// return;
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  800b53:	6a 00                	push   $0x0
  800b55:	6a 00                	push   $0x0
  800b57:	6a 00                	push   $0x0
  800b59:	ff 75 0c             	pushl  0xc(%ebp)
  800b5c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b5f:	ba 00 00 00 00       	mov    $0x0,%edx
  800b64:	b8 00 00 00 00       	mov    $0x0,%eax
  800b69:	e8 92 ff ff ff       	call   800b00 <syscall>
  800b6e:	83 c4 10             	add    $0x10,%esp
	return;
}
  800b71:	c9                   	leave  
  800b72:	c3                   	ret    

00800b73 <sys_cgetc>:

int
sys_cgetc(void)
{
  800b73:	55                   	push   %ebp
  800b74:	89 e5                	mov    %esp,%ebp
  800b76:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_cgetc, 0, 0, 0, 0, 0, 0);
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  800b79:	6a 00                	push   $0x0
  800b7b:	6a 00                	push   $0x0
  800b7d:	6a 00                	push   $0x0
  800b7f:	6a 00                	push   $0x0
  800b81:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b86:	ba 00 00 00 00       	mov    $0x0,%edx
  800b8b:	b8 01 00 00 00       	mov    $0x1,%eax
  800b90:	e8 6b ff ff ff       	call   800b00 <syscall>
}
  800b95:	c9                   	leave  
  800b96:	c3                   	ret    

00800b97 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b97:	55                   	push   %ebp
  800b98:	89 e5                	mov    %esp,%ebp
  800b9a:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  800b9d:	6a 00                	push   $0x0
  800b9f:	6a 00                	push   $0x0
  800ba1:	6a 00                	push   $0x0
  800ba3:	6a 00                	push   $0x0
  800ba5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ba8:	ba 01 00 00 00       	mov    $0x1,%edx
  800bad:	b8 03 00 00 00       	mov    $0x3,%eax
  800bb2:	e8 49 ff ff ff       	call   800b00 <syscall>
}
  800bb7:	c9                   	leave  
  800bb8:	c3                   	ret    

00800bb9 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800bb9:	55                   	push   %ebp
  800bba:	89 e5                	mov    %esp,%ebp
  800bbc:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_getenvid, 0, 0, 0, 0, 0, 0);
	return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  800bbf:	6a 00                	push   $0x0
  800bc1:	6a 00                	push   $0x0
  800bc3:	6a 00                	push   $0x0
  800bc5:	6a 00                	push   $0x0
  800bc7:	b9 00 00 00 00       	mov    $0x0,%ecx
  800bcc:	ba 00 00 00 00       	mov    $0x0,%edx
  800bd1:	b8 02 00 00 00       	mov    $0x2,%eax
  800bd6:	e8 25 ff ff ff       	call   800b00 <syscall>
}
  800bdb:	c9                   	leave  
  800bdc:	c3                   	ret    

00800bdd <sys_yield>:

void
sys_yield(void)
{
  800bdd:	55                   	push   %ebp
  800bde:	89 e5                	mov    %esp,%ebp
  800be0:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  800be3:	6a 00                	push   $0x0
  800be5:	6a 00                	push   $0x0
  800be7:	6a 00                	push   $0x0
  800be9:	6a 00                	push   $0x0
  800beb:	b9 00 00 00 00       	mov    $0x0,%ecx
  800bf0:	ba 00 00 00 00       	mov    $0x0,%edx
  800bf5:	b8 0b 00 00 00       	mov    $0xb,%eax
  800bfa:	e8 01 ff ff ff       	call   800b00 <syscall>
  800bff:	83 c4 10             	add    $0x10,%esp
}
  800c02:	c9                   	leave  
  800c03:	c3                   	ret    

00800c04 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c04:	55                   	push   %ebp
  800c05:	89 e5                	mov    %esp,%ebp
  800c07:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  800c0a:	6a 00                	push   $0x0
  800c0c:	6a 00                	push   $0x0
  800c0e:	ff 75 10             	pushl  0x10(%ebp)
  800c11:	ff 75 0c             	pushl  0xc(%ebp)
  800c14:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c17:	ba 01 00 00 00       	mov    $0x1,%edx
  800c1c:	b8 04 00 00 00       	mov    $0x4,%eax
  800c21:	e8 da fe ff ff       	call   800b00 <syscall>
}
  800c26:	c9                   	leave  
  800c27:	c3                   	ret    

00800c28 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c28:	55                   	push   %ebp
  800c29:	89 e5                	mov    %esp,%ebp
  800c2b:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
  800c2e:	ff 75 18             	pushl  0x18(%ebp)
  800c31:	ff 75 14             	pushl  0x14(%ebp)
  800c34:	ff 75 10             	pushl  0x10(%ebp)
  800c37:	ff 75 0c             	pushl  0xc(%ebp)
  800c3a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c3d:	ba 01 00 00 00       	mov    $0x1,%edx
  800c42:	b8 05 00 00 00       	mov    $0x5,%eax
  800c47:	e8 b4 fe ff ff       	call   800b00 <syscall>
}
  800c4c:	c9                   	leave  
  800c4d:	c3                   	ret    

00800c4e <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c4e:	55                   	push   %ebp
  800c4f:	89 e5                	mov    %esp,%ebp
  800c51:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  800c54:	6a 00                	push   $0x0
  800c56:	6a 00                	push   $0x0
  800c58:	6a 00                	push   $0x0
  800c5a:	ff 75 0c             	pushl  0xc(%ebp)
  800c5d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c60:	ba 01 00 00 00       	mov    $0x1,%edx
  800c65:	b8 06 00 00 00       	mov    $0x6,%eax
  800c6a:	e8 91 fe ff ff       	call   800b00 <syscall>
}
  800c6f:	c9                   	leave  
  800c70:	c3                   	ret    

00800c71 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c71:	55                   	push   %ebp
  800c72:	89 e5                	mov    %esp,%ebp
  800c74:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  800c77:	6a 00                	push   $0x0
  800c79:	6a 00                	push   $0x0
  800c7b:	6a 00                	push   $0x0
  800c7d:	ff 75 0c             	pushl  0xc(%ebp)
  800c80:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c83:	ba 01 00 00 00       	mov    $0x1,%edx
  800c88:	b8 08 00 00 00       	mov    $0x8,%eax
  800c8d:	e8 6e fe ff ff       	call   800b00 <syscall>
}
  800c92:	c9                   	leave  
  800c93:	c3                   	ret    

00800c94 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800c94:	55                   	push   %ebp
  800c95:	89 e5                	mov    %esp,%ebp
  800c97:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
  800c9a:	6a 00                	push   $0x0
  800c9c:	6a 00                	push   $0x0
  800c9e:	6a 00                	push   $0x0
  800ca0:	ff 75 0c             	pushl  0xc(%ebp)
  800ca3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ca6:	ba 01 00 00 00       	mov    $0x1,%edx
  800cab:	b8 09 00 00 00       	mov    $0x9,%eax
  800cb0:	e8 4b fe ff ff       	call   800b00 <syscall>
}
  800cb5:	c9                   	leave  
  800cb6:	c3                   	ret    

00800cb7 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800cb7:	55                   	push   %ebp
  800cb8:	89 e5                	mov    %esp,%ebp
  800cba:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  800cbd:	6a 00                	push   $0x0
  800cbf:	6a 00                	push   $0x0
  800cc1:	6a 00                	push   $0x0
  800cc3:	ff 75 0c             	pushl  0xc(%ebp)
  800cc6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800cc9:	ba 01 00 00 00       	mov    $0x1,%edx
  800cce:	b8 0a 00 00 00       	mov    $0xa,%eax
  800cd3:	e8 28 fe ff ff       	call   800b00 <syscall>
}
  800cd8:	c9                   	leave  
  800cd9:	c3                   	ret    

00800cda <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800cda:	55                   	push   %ebp
  800cdb:	89 e5                	mov    %esp,%ebp
  800cdd:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  800ce0:	6a 00                	push   $0x0
  800ce2:	ff 75 14             	pushl  0x14(%ebp)
  800ce5:	ff 75 10             	pushl  0x10(%ebp)
  800ce8:	ff 75 0c             	pushl  0xc(%ebp)
  800ceb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800cee:	ba 00 00 00 00       	mov    $0x0,%edx
  800cf3:	b8 0c 00 00 00       	mov    $0xc,%eax
  800cf8:	e8 03 fe ff ff       	call   800b00 <syscall>
}
  800cfd:	c9                   	leave  
  800cfe:	c3                   	ret    

00800cff <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800cff:	55                   	push   %ebp
  800d00:	89 e5                	mov    %esp,%ebp
  800d02:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  800d05:	6a 00                	push   $0x0
  800d07:	6a 00                	push   $0x0
  800d09:	6a 00                	push   $0x0
  800d0b:	6a 00                	push   $0x0
  800d0d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d10:	ba 01 00 00 00       	mov    $0x1,%edx
  800d15:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d1a:	e8 e1 fd ff ff       	call   800b00 <syscall>
}
  800d1f:	c9                   	leave  
  800d20:	c3                   	ret    

00800d21 <sys_set_priority>:

int
sys_set_priority(envid_t envid, uint32_t new_priority)
{
  800d21:	55                   	push   %ebp
  800d22:	89 e5                	mov    %esp,%ebp
  800d24:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_set_priority, 0, envid, new_priority, 0, 0, 0);
  800d27:	6a 00                	push   $0x0
  800d29:	6a 00                	push   $0x0
  800d2b:	6a 00                	push   $0x0
  800d2d:	ff 75 0c             	pushl  0xc(%ebp)
  800d30:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d33:	ba 00 00 00 00       	mov    $0x0,%edx
  800d38:	b8 0e 00 00 00       	mov    $0xe,%eax
  800d3d:	e8 be fd ff ff       	call   800b00 <syscall>
}
  800d42:	c9                   	leave  
  800d43:	c3                   	ret    

00800d44 <sys_exec>:

int
sys_exec(uint32_t eip, uint32_t esp, void * ph, uint32_t elf_phnum)
{
  800d44:	55                   	push   %ebp
  800d45:	89 e5                	mov    %esp,%ebp
  800d47:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_exec, 0, eip, esp, (uint32_t)ph, elf_phnum, 0);
  800d4a:	6a 00                	push   $0x0
  800d4c:	ff 75 14             	pushl  0x14(%ebp)
  800d4f:	ff 75 10             	pushl  0x10(%ebp)
  800d52:	ff 75 0c             	pushl  0xc(%ebp)
  800d55:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d58:	ba 00 00 00 00       	mov    $0x0,%edx
  800d5d:	b8 0f 00 00 00       	mov    $0xf,%eax
  800d62:	e8 99 fd ff ff       	call   800b00 <syscall>
} 
  800d67:	c9                   	leave  
  800d68:	c3                   	ret    

00800d69 <sys_join>:

// thread:
int
sys_join(envid_t envid)
{
  800d69:	55                   	push   %ebp
  800d6a:	89 e5                	mov    %esp,%ebp
  800d6c:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_join, 0, envid, 0, 0, 0, 0);
  800d6f:	6a 00                	push   $0x0
  800d71:	6a 00                	push   $0x0
  800d73:	6a 00                	push   $0x0
  800d75:	6a 00                	push   $0x0
  800d77:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d7a:	ba 00 00 00 00       	mov    $0x0,%edx
  800d7f:	b8 11 00 00 00       	mov    $0x11,%eax
  800d84:	e8 77 fd ff ff       	call   800b00 <syscall>
}
  800d89:	c9                   	leave  
  800d8a:	c3                   	ret    

00800d8b <sys_getpid>:

envid_t
sys_getpid(void)
{
  800d8b:	55                   	push   %ebp
  800d8c:	89 e5                	mov    %esp,%ebp
  800d8e:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_getpid, 0, 0, 0, 0, 0, 0);
  800d91:	6a 00                	push   $0x0
  800d93:	6a 00                	push   $0x0
  800d95:	6a 00                	push   $0x0
  800d97:	6a 00                	push   $0x0
  800d99:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d9e:	ba 00 00 00 00       	mov    $0x0,%edx
  800da3:	b8 10 00 00 00       	mov    $0x10,%eax
  800da8:	e8 53 fd ff ff       	call   800b00 <syscall>
  800dad:	c9                   	leave  
  800dae:	c3                   	ret    
	...

00800db0 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800db0:	55                   	push   %ebp
  800db1:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800db3:	8b 45 08             	mov    0x8(%ebp),%eax
  800db6:	05 00 00 00 30       	add    $0x30000000,%eax
  800dbb:	c1 e8 0c             	shr    $0xc,%eax
}
  800dbe:	c9                   	leave  
  800dbf:	c3                   	ret    

00800dc0 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800dc0:	55                   	push   %ebp
  800dc1:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800dc3:	ff 75 08             	pushl  0x8(%ebp)
  800dc6:	e8 e5 ff ff ff       	call   800db0 <fd2num>
  800dcb:	83 c4 04             	add    $0x4,%esp
  800dce:	05 20 00 0d 00       	add    $0xd0020,%eax
  800dd3:	c1 e0 0c             	shl    $0xc,%eax
}
  800dd6:	c9                   	leave  
  800dd7:	c3                   	ret    

00800dd8 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800dd8:	55                   	push   %ebp
  800dd9:	89 e5                	mov    %esp,%ebp
  800ddb:	53                   	push   %ebx
  800ddc:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800ddf:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  800de4:	a8 01                	test   $0x1,%al
  800de6:	74 34                	je     800e1c <fd_alloc+0x44>
  800de8:	a1 00 00 74 ef       	mov    0xef740000,%eax
  800ded:	a8 01                	test   $0x1,%al
  800def:	74 32                	je     800e23 <fd_alloc+0x4b>
  800df1:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
  800df6:	89 c1                	mov    %eax,%ecx
  800df8:	89 c2                	mov    %eax,%edx
  800dfa:	c1 ea 16             	shr    $0x16,%edx
  800dfd:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800e04:	f6 c2 01             	test   $0x1,%dl
  800e07:	74 1f                	je     800e28 <fd_alloc+0x50>
  800e09:	89 c2                	mov    %eax,%edx
  800e0b:	c1 ea 0c             	shr    $0xc,%edx
  800e0e:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e15:	f6 c2 01             	test   $0x1,%dl
  800e18:	75 17                	jne    800e31 <fd_alloc+0x59>
  800e1a:	eb 0c                	jmp    800e28 <fd_alloc+0x50>
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  800e1c:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
  800e21:	eb 05                	jmp    800e28 <fd_alloc+0x50>
  800e23:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
  800e28:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  800e2a:	b8 00 00 00 00       	mov    $0x0,%eax
  800e2f:	eb 17                	jmp    800e48 <fd_alloc+0x70>
  800e31:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800e36:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800e3b:	75 b9                	jne    800df6 <fd_alloc+0x1e>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800e3d:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  800e43:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800e48:	5b                   	pop    %ebx
  800e49:	c9                   	leave  
  800e4a:	c3                   	ret    

00800e4b <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800e4b:	55                   	push   %ebp
  800e4c:	89 e5                	mov    %esp,%ebp
  800e4e:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800e51:	83 f8 1f             	cmp    $0x1f,%eax
  800e54:	77 36                	ja     800e8c <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800e56:	05 00 00 0d 00       	add    $0xd0000,%eax
  800e5b:	c1 e0 0c             	shl    $0xc,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800e5e:	89 c2                	mov    %eax,%edx
  800e60:	c1 ea 16             	shr    $0x16,%edx
  800e63:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800e6a:	f6 c2 01             	test   $0x1,%dl
  800e6d:	74 24                	je     800e93 <fd_lookup+0x48>
  800e6f:	89 c2                	mov    %eax,%edx
  800e71:	c1 ea 0c             	shr    $0xc,%edx
  800e74:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e7b:	f6 c2 01             	test   $0x1,%dl
  800e7e:	74 1a                	je     800e9a <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800e80:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e83:	89 02                	mov    %eax,(%edx)
	return 0;
  800e85:	b8 00 00 00 00       	mov    $0x0,%eax
  800e8a:	eb 13                	jmp    800e9f <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800e8c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800e91:	eb 0c                	jmp    800e9f <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800e93:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800e98:	eb 05                	jmp    800e9f <fd_lookup+0x54>
  800e9a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800e9f:	c9                   	leave  
  800ea0:	c3                   	ret    

00800ea1 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800ea1:	55                   	push   %ebp
  800ea2:	89 e5                	mov    %esp,%ebp
  800ea4:	53                   	push   %ebx
  800ea5:	83 ec 04             	sub    $0x4,%esp
  800ea8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800eab:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  800eae:	39 0d 04 30 80 00    	cmp    %ecx,0x803004
  800eb4:	74 0d                	je     800ec3 <dev_lookup+0x22>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800eb6:	b8 00 00 00 00       	mov    $0x0,%eax
  800ebb:	eb 14                	jmp    800ed1 <dev_lookup+0x30>
		if (devtab[i]->dev_id == dev_id) {
  800ebd:	39 0a                	cmp    %ecx,(%edx)
  800ebf:	75 10                	jne    800ed1 <dev_lookup+0x30>
  800ec1:	eb 05                	jmp    800ec8 <dev_lookup+0x27>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800ec3:	ba 04 30 80 00       	mov    $0x803004,%edx
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
  800ec8:	89 13                	mov    %edx,(%ebx)
			return 0;
  800eca:	b8 00 00 00 00       	mov    $0x0,%eax
  800ecf:	eb 31                	jmp    800f02 <dev_lookup+0x61>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800ed1:	40                   	inc    %eax
  800ed2:	8b 14 85 a8 2a 80 00 	mov    0x802aa8(,%eax,4),%edx
  800ed9:	85 d2                	test   %edx,%edx
  800edb:	75 e0                	jne    800ebd <dev_lookup+0x1c>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800edd:	a1 04 40 80 00       	mov    0x804004,%eax
  800ee2:	8b 40 48             	mov    0x48(%eax),%eax
  800ee5:	83 ec 04             	sub    $0x4,%esp
  800ee8:	51                   	push   %ecx
  800ee9:	50                   	push   %eax
  800eea:	68 2c 2a 80 00       	push   $0x802a2c
  800eef:	e8 d8 f2 ff ff       	call   8001cc <cprintf>
	*dev = 0;
  800ef4:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  800efa:	83 c4 10             	add    $0x10,%esp
  800efd:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800f02:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f05:	c9                   	leave  
  800f06:	c3                   	ret    

00800f07 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800f07:	55                   	push   %ebp
  800f08:	89 e5                	mov    %esp,%ebp
  800f0a:	56                   	push   %esi
  800f0b:	53                   	push   %ebx
  800f0c:	83 ec 20             	sub    $0x20,%esp
  800f0f:	8b 75 08             	mov    0x8(%ebp),%esi
  800f12:	8a 45 0c             	mov    0xc(%ebp),%al
  800f15:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800f18:	56                   	push   %esi
  800f19:	e8 92 fe ff ff       	call   800db0 <fd2num>
  800f1e:	8d 55 f4             	lea    -0xc(%ebp),%edx
  800f21:	89 14 24             	mov    %edx,(%esp)
  800f24:	50                   	push   %eax
  800f25:	e8 21 ff ff ff       	call   800e4b <fd_lookup>
  800f2a:	89 c3                	mov    %eax,%ebx
  800f2c:	83 c4 08             	add    $0x8,%esp
  800f2f:	85 c0                	test   %eax,%eax
  800f31:	78 05                	js     800f38 <fd_close+0x31>
	    || fd != fd2)
  800f33:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800f36:	74 0d                	je     800f45 <fd_close+0x3e>
		return (must_exist ? r : 0);
  800f38:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  800f3c:	75 48                	jne    800f86 <fd_close+0x7f>
  800f3e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f43:	eb 41                	jmp    800f86 <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800f45:	83 ec 08             	sub    $0x8,%esp
  800f48:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800f4b:	50                   	push   %eax
  800f4c:	ff 36                	pushl  (%esi)
  800f4e:	e8 4e ff ff ff       	call   800ea1 <dev_lookup>
  800f53:	89 c3                	mov    %eax,%ebx
  800f55:	83 c4 10             	add    $0x10,%esp
  800f58:	85 c0                	test   %eax,%eax
  800f5a:	78 1c                	js     800f78 <fd_close+0x71>
		if (dev->dev_close)
  800f5c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800f5f:	8b 40 10             	mov    0x10(%eax),%eax
  800f62:	85 c0                	test   %eax,%eax
  800f64:	74 0d                	je     800f73 <fd_close+0x6c>
			r = (*dev->dev_close)(fd);
  800f66:	83 ec 0c             	sub    $0xc,%esp
  800f69:	56                   	push   %esi
  800f6a:	ff d0                	call   *%eax
  800f6c:	89 c3                	mov    %eax,%ebx
  800f6e:	83 c4 10             	add    $0x10,%esp
  800f71:	eb 05                	jmp    800f78 <fd_close+0x71>
		else
			r = 0;
  800f73:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800f78:	83 ec 08             	sub    $0x8,%esp
  800f7b:	56                   	push   %esi
  800f7c:	6a 00                	push   $0x0
  800f7e:	e8 cb fc ff ff       	call   800c4e <sys_page_unmap>
	return r;
  800f83:	83 c4 10             	add    $0x10,%esp
}
  800f86:	89 d8                	mov    %ebx,%eax
  800f88:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800f8b:	5b                   	pop    %ebx
  800f8c:	5e                   	pop    %esi
  800f8d:	c9                   	leave  
  800f8e:	c3                   	ret    

00800f8f <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800f8f:	55                   	push   %ebp
  800f90:	89 e5                	mov    %esp,%ebp
  800f92:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800f95:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f98:	50                   	push   %eax
  800f99:	ff 75 08             	pushl  0x8(%ebp)
  800f9c:	e8 aa fe ff ff       	call   800e4b <fd_lookup>
  800fa1:	83 c4 08             	add    $0x8,%esp
  800fa4:	85 c0                	test   %eax,%eax
  800fa6:	78 10                	js     800fb8 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800fa8:	83 ec 08             	sub    $0x8,%esp
  800fab:	6a 01                	push   $0x1
  800fad:	ff 75 f4             	pushl  -0xc(%ebp)
  800fb0:	e8 52 ff ff ff       	call   800f07 <fd_close>
  800fb5:	83 c4 10             	add    $0x10,%esp
}
  800fb8:	c9                   	leave  
  800fb9:	c3                   	ret    

00800fba <close_all>:

void
close_all(void)
{
  800fba:	55                   	push   %ebp
  800fbb:	89 e5                	mov    %esp,%ebp
  800fbd:	53                   	push   %ebx
  800fbe:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800fc1:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800fc6:	83 ec 0c             	sub    $0xc,%esp
  800fc9:	53                   	push   %ebx
  800fca:	e8 c0 ff ff ff       	call   800f8f <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800fcf:	43                   	inc    %ebx
  800fd0:	83 c4 10             	add    $0x10,%esp
  800fd3:	83 fb 20             	cmp    $0x20,%ebx
  800fd6:	75 ee                	jne    800fc6 <close_all+0xc>
		close(i);
}
  800fd8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800fdb:	c9                   	leave  
  800fdc:	c3                   	ret    

00800fdd <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800fdd:	55                   	push   %ebp
  800fde:	89 e5                	mov    %esp,%ebp
  800fe0:	57                   	push   %edi
  800fe1:	56                   	push   %esi
  800fe2:	53                   	push   %ebx
  800fe3:	83 ec 2c             	sub    $0x2c,%esp
  800fe6:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800fe9:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800fec:	50                   	push   %eax
  800fed:	ff 75 08             	pushl  0x8(%ebp)
  800ff0:	e8 56 fe ff ff       	call   800e4b <fd_lookup>
  800ff5:	89 c3                	mov    %eax,%ebx
  800ff7:	83 c4 08             	add    $0x8,%esp
  800ffa:	85 c0                	test   %eax,%eax
  800ffc:	0f 88 c0 00 00 00    	js     8010c2 <dup+0xe5>
		return r;
	close(newfdnum);
  801002:	83 ec 0c             	sub    $0xc,%esp
  801005:	57                   	push   %edi
  801006:	e8 84 ff ff ff       	call   800f8f <close>

	newfd = INDEX2FD(newfdnum);
  80100b:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  801011:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  801014:	83 c4 04             	add    $0x4,%esp
  801017:	ff 75 e4             	pushl  -0x1c(%ebp)
  80101a:	e8 a1 fd ff ff       	call   800dc0 <fd2data>
  80101f:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801021:	89 34 24             	mov    %esi,(%esp)
  801024:	e8 97 fd ff ff       	call   800dc0 <fd2data>
  801029:	83 c4 10             	add    $0x10,%esp
  80102c:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80102f:	89 d8                	mov    %ebx,%eax
  801031:	c1 e8 16             	shr    $0x16,%eax
  801034:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80103b:	a8 01                	test   $0x1,%al
  80103d:	74 37                	je     801076 <dup+0x99>
  80103f:	89 d8                	mov    %ebx,%eax
  801041:	c1 e8 0c             	shr    $0xc,%eax
  801044:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80104b:	f6 c2 01             	test   $0x1,%dl
  80104e:	74 26                	je     801076 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801050:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801057:	83 ec 0c             	sub    $0xc,%esp
  80105a:	25 07 0e 00 00       	and    $0xe07,%eax
  80105f:	50                   	push   %eax
  801060:	ff 75 d4             	pushl  -0x2c(%ebp)
  801063:	6a 00                	push   $0x0
  801065:	53                   	push   %ebx
  801066:	6a 00                	push   $0x0
  801068:	e8 bb fb ff ff       	call   800c28 <sys_page_map>
  80106d:	89 c3                	mov    %eax,%ebx
  80106f:	83 c4 20             	add    $0x20,%esp
  801072:	85 c0                	test   %eax,%eax
  801074:	78 2d                	js     8010a3 <dup+0xc6>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801076:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801079:	89 c2                	mov    %eax,%edx
  80107b:	c1 ea 0c             	shr    $0xc,%edx
  80107e:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801085:	83 ec 0c             	sub    $0xc,%esp
  801088:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  80108e:	52                   	push   %edx
  80108f:	56                   	push   %esi
  801090:	6a 00                	push   $0x0
  801092:	50                   	push   %eax
  801093:	6a 00                	push   $0x0
  801095:	e8 8e fb ff ff       	call   800c28 <sys_page_map>
  80109a:	89 c3                	mov    %eax,%ebx
  80109c:	83 c4 20             	add    $0x20,%esp
  80109f:	85 c0                	test   %eax,%eax
  8010a1:	79 1d                	jns    8010c0 <dup+0xe3>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8010a3:	83 ec 08             	sub    $0x8,%esp
  8010a6:	56                   	push   %esi
  8010a7:	6a 00                	push   $0x0
  8010a9:	e8 a0 fb ff ff       	call   800c4e <sys_page_unmap>
	sys_page_unmap(0, nva);
  8010ae:	83 c4 08             	add    $0x8,%esp
  8010b1:	ff 75 d4             	pushl  -0x2c(%ebp)
  8010b4:	6a 00                	push   $0x0
  8010b6:	e8 93 fb ff ff       	call   800c4e <sys_page_unmap>
	return r;
  8010bb:	83 c4 10             	add    $0x10,%esp
  8010be:	eb 02                	jmp    8010c2 <dup+0xe5>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  8010c0:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  8010c2:	89 d8                	mov    %ebx,%eax
  8010c4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010c7:	5b                   	pop    %ebx
  8010c8:	5e                   	pop    %esi
  8010c9:	5f                   	pop    %edi
  8010ca:	c9                   	leave  
  8010cb:	c3                   	ret    

008010cc <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8010cc:	55                   	push   %ebp
  8010cd:	89 e5                	mov    %esp,%ebp
  8010cf:	53                   	push   %ebx
  8010d0:	83 ec 14             	sub    $0x14,%esp
  8010d3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8010d6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8010d9:	50                   	push   %eax
  8010da:	53                   	push   %ebx
  8010db:	e8 6b fd ff ff       	call   800e4b <fd_lookup>
  8010e0:	83 c4 08             	add    $0x8,%esp
  8010e3:	85 c0                	test   %eax,%eax
  8010e5:	78 67                	js     80114e <read+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8010e7:	83 ec 08             	sub    $0x8,%esp
  8010ea:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8010ed:	50                   	push   %eax
  8010ee:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8010f1:	ff 30                	pushl  (%eax)
  8010f3:	e8 a9 fd ff ff       	call   800ea1 <dev_lookup>
  8010f8:	83 c4 10             	add    $0x10,%esp
  8010fb:	85 c0                	test   %eax,%eax
  8010fd:	78 4f                	js     80114e <read+0x82>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8010ff:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801102:	8b 50 08             	mov    0x8(%eax),%edx
  801105:	83 e2 03             	and    $0x3,%edx
  801108:	83 fa 01             	cmp    $0x1,%edx
  80110b:	75 21                	jne    80112e <read+0x62>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80110d:	a1 04 40 80 00       	mov    0x804004,%eax
  801112:	8b 40 48             	mov    0x48(%eax),%eax
  801115:	83 ec 04             	sub    $0x4,%esp
  801118:	53                   	push   %ebx
  801119:	50                   	push   %eax
  80111a:	68 6d 2a 80 00       	push   $0x802a6d
  80111f:	e8 a8 f0 ff ff       	call   8001cc <cprintf>
		return -E_INVAL;
  801124:	83 c4 10             	add    $0x10,%esp
  801127:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80112c:	eb 20                	jmp    80114e <read+0x82>
	}
	if (!dev->dev_read)
  80112e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801131:	8b 52 08             	mov    0x8(%edx),%edx
  801134:	85 d2                	test   %edx,%edx
  801136:	74 11                	je     801149 <read+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801138:	83 ec 04             	sub    $0x4,%esp
  80113b:	ff 75 10             	pushl  0x10(%ebp)
  80113e:	ff 75 0c             	pushl  0xc(%ebp)
  801141:	50                   	push   %eax
  801142:	ff d2                	call   *%edx
  801144:	83 c4 10             	add    $0x10,%esp
  801147:	eb 05                	jmp    80114e <read+0x82>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801149:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  80114e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801151:	c9                   	leave  
  801152:	c3                   	ret    

00801153 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801153:	55                   	push   %ebp
  801154:	89 e5                	mov    %esp,%ebp
  801156:	57                   	push   %edi
  801157:	56                   	push   %esi
  801158:	53                   	push   %ebx
  801159:	83 ec 0c             	sub    $0xc,%esp
  80115c:	8b 7d 08             	mov    0x8(%ebp),%edi
  80115f:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801162:	85 f6                	test   %esi,%esi
  801164:	74 31                	je     801197 <readn+0x44>
  801166:	b8 00 00 00 00       	mov    $0x0,%eax
  80116b:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = read(fdnum, (char*)buf + tot, n - tot);
  801170:	83 ec 04             	sub    $0x4,%esp
  801173:	89 f2                	mov    %esi,%edx
  801175:	29 c2                	sub    %eax,%edx
  801177:	52                   	push   %edx
  801178:	03 45 0c             	add    0xc(%ebp),%eax
  80117b:	50                   	push   %eax
  80117c:	57                   	push   %edi
  80117d:	e8 4a ff ff ff       	call   8010cc <read>
		if (m < 0)
  801182:	83 c4 10             	add    $0x10,%esp
  801185:	85 c0                	test   %eax,%eax
  801187:	78 17                	js     8011a0 <readn+0x4d>
			return m;
		if (m == 0)
  801189:	85 c0                	test   %eax,%eax
  80118b:	74 11                	je     80119e <readn+0x4b>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80118d:	01 c3                	add    %eax,%ebx
  80118f:	89 d8                	mov    %ebx,%eax
  801191:	39 f3                	cmp    %esi,%ebx
  801193:	72 db                	jb     801170 <readn+0x1d>
  801195:	eb 09                	jmp    8011a0 <readn+0x4d>
  801197:	b8 00 00 00 00       	mov    $0x0,%eax
  80119c:	eb 02                	jmp    8011a0 <readn+0x4d>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  80119e:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  8011a0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011a3:	5b                   	pop    %ebx
  8011a4:	5e                   	pop    %esi
  8011a5:	5f                   	pop    %edi
  8011a6:	c9                   	leave  
  8011a7:	c3                   	ret    

008011a8 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8011a8:	55                   	push   %ebp
  8011a9:	89 e5                	mov    %esp,%ebp
  8011ab:	53                   	push   %ebx
  8011ac:	83 ec 14             	sub    $0x14,%esp
  8011af:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8011b2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011b5:	50                   	push   %eax
  8011b6:	53                   	push   %ebx
  8011b7:	e8 8f fc ff ff       	call   800e4b <fd_lookup>
  8011bc:	83 c4 08             	add    $0x8,%esp
  8011bf:	85 c0                	test   %eax,%eax
  8011c1:	78 62                	js     801225 <write+0x7d>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011c3:	83 ec 08             	sub    $0x8,%esp
  8011c6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011c9:	50                   	push   %eax
  8011ca:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011cd:	ff 30                	pushl  (%eax)
  8011cf:	e8 cd fc ff ff       	call   800ea1 <dev_lookup>
  8011d4:	83 c4 10             	add    $0x10,%esp
  8011d7:	85 c0                	test   %eax,%eax
  8011d9:	78 4a                	js     801225 <write+0x7d>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8011db:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011de:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8011e2:	75 21                	jne    801205 <write+0x5d>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8011e4:	a1 04 40 80 00       	mov    0x804004,%eax
  8011e9:	8b 40 48             	mov    0x48(%eax),%eax
  8011ec:	83 ec 04             	sub    $0x4,%esp
  8011ef:	53                   	push   %ebx
  8011f0:	50                   	push   %eax
  8011f1:	68 89 2a 80 00       	push   $0x802a89
  8011f6:	e8 d1 ef ff ff       	call   8001cc <cprintf>
		return -E_INVAL;
  8011fb:	83 c4 10             	add    $0x10,%esp
  8011fe:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801203:	eb 20                	jmp    801225 <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801205:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801208:	8b 52 0c             	mov    0xc(%edx),%edx
  80120b:	85 d2                	test   %edx,%edx
  80120d:	74 11                	je     801220 <write+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80120f:	83 ec 04             	sub    $0x4,%esp
  801212:	ff 75 10             	pushl  0x10(%ebp)
  801215:	ff 75 0c             	pushl  0xc(%ebp)
  801218:	50                   	push   %eax
  801219:	ff d2                	call   *%edx
  80121b:	83 c4 10             	add    $0x10,%esp
  80121e:	eb 05                	jmp    801225 <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801220:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  801225:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801228:	c9                   	leave  
  801229:	c3                   	ret    

0080122a <seek>:

int
seek(int fdnum, off_t offset)
{
  80122a:	55                   	push   %ebp
  80122b:	89 e5                	mov    %esp,%ebp
  80122d:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801230:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801233:	50                   	push   %eax
  801234:	ff 75 08             	pushl  0x8(%ebp)
  801237:	e8 0f fc ff ff       	call   800e4b <fd_lookup>
  80123c:	83 c4 08             	add    $0x8,%esp
  80123f:	85 c0                	test   %eax,%eax
  801241:	78 0e                	js     801251 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801243:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801246:	8b 55 0c             	mov    0xc(%ebp),%edx
  801249:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80124c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801251:	c9                   	leave  
  801252:	c3                   	ret    

00801253 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801253:	55                   	push   %ebp
  801254:	89 e5                	mov    %esp,%ebp
  801256:	53                   	push   %ebx
  801257:	83 ec 14             	sub    $0x14,%esp
  80125a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80125d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801260:	50                   	push   %eax
  801261:	53                   	push   %ebx
  801262:	e8 e4 fb ff ff       	call   800e4b <fd_lookup>
  801267:	83 c4 08             	add    $0x8,%esp
  80126a:	85 c0                	test   %eax,%eax
  80126c:	78 5f                	js     8012cd <ftruncate+0x7a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80126e:	83 ec 08             	sub    $0x8,%esp
  801271:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801274:	50                   	push   %eax
  801275:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801278:	ff 30                	pushl  (%eax)
  80127a:	e8 22 fc ff ff       	call   800ea1 <dev_lookup>
  80127f:	83 c4 10             	add    $0x10,%esp
  801282:	85 c0                	test   %eax,%eax
  801284:	78 47                	js     8012cd <ftruncate+0x7a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801286:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801289:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80128d:	75 21                	jne    8012b0 <ftruncate+0x5d>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80128f:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801294:	8b 40 48             	mov    0x48(%eax),%eax
  801297:	83 ec 04             	sub    $0x4,%esp
  80129a:	53                   	push   %ebx
  80129b:	50                   	push   %eax
  80129c:	68 4c 2a 80 00       	push   $0x802a4c
  8012a1:	e8 26 ef ff ff       	call   8001cc <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8012a6:	83 c4 10             	add    $0x10,%esp
  8012a9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012ae:	eb 1d                	jmp    8012cd <ftruncate+0x7a>
	}
	if (!dev->dev_trunc)
  8012b0:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8012b3:	8b 52 18             	mov    0x18(%edx),%edx
  8012b6:	85 d2                	test   %edx,%edx
  8012b8:	74 0e                	je     8012c8 <ftruncate+0x75>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8012ba:	83 ec 08             	sub    $0x8,%esp
  8012bd:	ff 75 0c             	pushl  0xc(%ebp)
  8012c0:	50                   	push   %eax
  8012c1:	ff d2                	call   *%edx
  8012c3:	83 c4 10             	add    $0x10,%esp
  8012c6:	eb 05                	jmp    8012cd <ftruncate+0x7a>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8012c8:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  8012cd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012d0:	c9                   	leave  
  8012d1:	c3                   	ret    

008012d2 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8012d2:	55                   	push   %ebp
  8012d3:	89 e5                	mov    %esp,%ebp
  8012d5:	53                   	push   %ebx
  8012d6:	83 ec 14             	sub    $0x14,%esp
  8012d9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8012dc:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012df:	50                   	push   %eax
  8012e0:	ff 75 08             	pushl  0x8(%ebp)
  8012e3:	e8 63 fb ff ff       	call   800e4b <fd_lookup>
  8012e8:	83 c4 08             	add    $0x8,%esp
  8012eb:	85 c0                	test   %eax,%eax
  8012ed:	78 52                	js     801341 <fstat+0x6f>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012ef:	83 ec 08             	sub    $0x8,%esp
  8012f2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012f5:	50                   	push   %eax
  8012f6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012f9:	ff 30                	pushl  (%eax)
  8012fb:	e8 a1 fb ff ff       	call   800ea1 <dev_lookup>
  801300:	83 c4 10             	add    $0x10,%esp
  801303:	85 c0                	test   %eax,%eax
  801305:	78 3a                	js     801341 <fstat+0x6f>
		return r;
	if (!dev->dev_stat)
  801307:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80130a:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80130e:	74 2c                	je     80133c <fstat+0x6a>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801310:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801313:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80131a:	00 00 00 
	stat->st_isdir = 0;
  80131d:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801324:	00 00 00 
	stat->st_dev = dev;
  801327:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80132d:	83 ec 08             	sub    $0x8,%esp
  801330:	53                   	push   %ebx
  801331:	ff 75 f0             	pushl  -0x10(%ebp)
  801334:	ff 50 14             	call   *0x14(%eax)
  801337:	83 c4 10             	add    $0x10,%esp
  80133a:	eb 05                	jmp    801341 <fstat+0x6f>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  80133c:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801341:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801344:	c9                   	leave  
  801345:	c3                   	ret    

00801346 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801346:	55                   	push   %ebp
  801347:	89 e5                	mov    %esp,%ebp
  801349:	56                   	push   %esi
  80134a:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80134b:	83 ec 08             	sub    $0x8,%esp
  80134e:	6a 00                	push   $0x0
  801350:	ff 75 08             	pushl  0x8(%ebp)
  801353:	e8 78 01 00 00       	call   8014d0 <open>
  801358:	89 c3                	mov    %eax,%ebx
  80135a:	83 c4 10             	add    $0x10,%esp
  80135d:	85 c0                	test   %eax,%eax
  80135f:	78 1b                	js     80137c <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801361:	83 ec 08             	sub    $0x8,%esp
  801364:	ff 75 0c             	pushl  0xc(%ebp)
  801367:	50                   	push   %eax
  801368:	e8 65 ff ff ff       	call   8012d2 <fstat>
  80136d:	89 c6                	mov    %eax,%esi
	close(fd);
  80136f:	89 1c 24             	mov    %ebx,(%esp)
  801372:	e8 18 fc ff ff       	call   800f8f <close>
	return r;
  801377:	83 c4 10             	add    $0x10,%esp
  80137a:	89 f3                	mov    %esi,%ebx
}
  80137c:	89 d8                	mov    %ebx,%eax
  80137e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801381:	5b                   	pop    %ebx
  801382:	5e                   	pop    %esi
  801383:	c9                   	leave  
  801384:	c3                   	ret    
  801385:	00 00                	add    %al,(%eax)
	...

00801388 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801388:	55                   	push   %ebp
  801389:	89 e5                	mov    %esp,%ebp
  80138b:	56                   	push   %esi
  80138c:	53                   	push   %ebx
  80138d:	89 c3                	mov    %eax,%ebx
  80138f:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  801391:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801398:	75 12                	jne    8013ac <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80139a:	83 ec 0c             	sub    $0xc,%esp
  80139d:	6a 01                	push   $0x1
  80139f:	e8 ea 0f 00 00       	call   80238e <ipc_find_env>
  8013a4:	a3 00 40 80 00       	mov    %eax,0x804000
  8013a9:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8013ac:	6a 07                	push   $0x7
  8013ae:	68 00 50 80 00       	push   $0x805000
  8013b3:	53                   	push   %ebx
  8013b4:	ff 35 00 40 80 00    	pushl  0x804000
  8013ba:	e8 7a 0f 00 00       	call   802339 <ipc_send>
	
	return ipc_recv(NULL, dstva, NULL);
  8013bf:	83 c4 0c             	add    $0xc,%esp
  8013c2:	6a 00                	push   $0x0
  8013c4:	56                   	push   %esi
  8013c5:	6a 00                	push   $0x0
  8013c7:	e8 f8 0e 00 00       	call   8022c4 <ipc_recv>
}
  8013cc:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8013cf:	5b                   	pop    %ebx
  8013d0:	5e                   	pop    %esi
  8013d1:	c9                   	leave  
  8013d2:	c3                   	ret    

008013d3 <devfile_stat>:
}


static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8013d3:	55                   	push   %ebp
  8013d4:	89 e5                	mov    %esp,%ebp
  8013d6:	53                   	push   %ebx
  8013d7:	83 ec 04             	sub    $0x4,%esp
  8013da:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8013dd:	8b 45 08             	mov    0x8(%ebp),%eax
  8013e0:	8b 40 0c             	mov    0xc(%eax),%eax
  8013e3:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0) {
  8013e8:	ba 00 00 00 00       	mov    $0x0,%edx
  8013ed:	b8 05 00 00 00       	mov    $0x5,%eax
  8013f2:	e8 91 ff ff ff       	call   801388 <fsipc>
  8013f7:	85 c0                	test   %eax,%eax
  8013f9:	78 2c                	js     801427 <devfile_stat+0x54>
		return r;
	}
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8013fb:	83 ec 08             	sub    $0x8,%esp
  8013fe:	68 00 50 80 00       	push   $0x805000
  801403:	53                   	push   %ebx
  801404:	e8 79 f3 ff ff       	call   800782 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801409:	a1 80 50 80 00       	mov    0x805080,%eax
  80140e:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801414:	a1 84 50 80 00       	mov    0x805084,%eax
  801419:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80141f:	83 c4 10             	add    $0x10,%esp
  801422:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801427:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80142a:	c9                   	leave  
  80142b:	c3                   	ret    

0080142c <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80142c:	55                   	push   %ebp
  80142d:	89 e5                	mov    %esp,%ebp
  80142f:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801432:	8b 45 08             	mov    0x8(%ebp),%eax
  801435:	8b 40 0c             	mov    0xc(%eax),%eax
  801438:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80143d:	ba 00 00 00 00       	mov    $0x0,%edx
  801442:	b8 06 00 00 00       	mov    $0x6,%eax
  801447:	e8 3c ff ff ff       	call   801388 <fsipc>
}
  80144c:	c9                   	leave  
  80144d:	c3                   	ret    

0080144e <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  80144e:	55                   	push   %ebp
  80144f:	89 e5                	mov    %esp,%ebp
  801451:	56                   	push   %esi
  801452:	53                   	push   %ebx
  801453:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801456:	8b 45 08             	mov    0x8(%ebp),%eax
  801459:	8b 40 0c             	mov    0xc(%eax),%eax
  80145c:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801461:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801467:	ba 00 00 00 00       	mov    $0x0,%edx
  80146c:	b8 03 00 00 00       	mov    $0x3,%eax
  801471:	e8 12 ff ff ff       	call   801388 <fsipc>
  801476:	89 c3                	mov    %eax,%ebx
  801478:	85 c0                	test   %eax,%eax
  80147a:	78 4b                	js     8014c7 <devfile_read+0x79>
		return r;
	assert(r <= n);
  80147c:	39 c6                	cmp    %eax,%esi
  80147e:	73 16                	jae    801496 <devfile_read+0x48>
  801480:	68 b8 2a 80 00       	push   $0x802ab8
  801485:	68 bf 2a 80 00       	push   $0x802abf
  80148a:	6a 7d                	push   $0x7d
  80148c:	68 d4 2a 80 00       	push   $0x802ad4
  801491:	e8 5e ec ff ff       	call   8000f4 <_panic>
	assert(r <= PGSIZE);
  801496:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80149b:	7e 16                	jle    8014b3 <devfile_read+0x65>
  80149d:	68 df 2a 80 00       	push   $0x802adf
  8014a2:	68 bf 2a 80 00       	push   $0x802abf
  8014a7:	6a 7e                	push   $0x7e
  8014a9:	68 d4 2a 80 00       	push   $0x802ad4
  8014ae:	e8 41 ec ff ff       	call   8000f4 <_panic>
	memmove(buf, &fsipcbuf, r);
  8014b3:	83 ec 04             	sub    $0x4,%esp
  8014b6:	50                   	push   %eax
  8014b7:	68 00 50 80 00       	push   $0x805000
  8014bc:	ff 75 0c             	pushl  0xc(%ebp)
  8014bf:	e8 7f f4 ff ff       	call   800943 <memmove>
	return r;
  8014c4:	83 c4 10             	add    $0x10,%esp
}
  8014c7:	89 d8                	mov    %ebx,%eax
  8014c9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8014cc:	5b                   	pop    %ebx
  8014cd:	5e                   	pop    %esi
  8014ce:	c9                   	leave  
  8014cf:	c3                   	ret    

008014d0 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8014d0:	55                   	push   %ebp
  8014d1:	89 e5                	mov    %esp,%ebp
  8014d3:	56                   	push   %esi
  8014d4:	53                   	push   %ebx
  8014d5:	83 ec 1c             	sub    $0x1c,%esp
  8014d8:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8014db:	56                   	push   %esi
  8014dc:	e8 4f f2 ff ff       	call   800730 <strlen>
  8014e1:	83 c4 10             	add    $0x10,%esp
  8014e4:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8014e9:	7f 65                	jg     801550 <open+0x80>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8014eb:	83 ec 0c             	sub    $0xc,%esp
  8014ee:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014f1:	50                   	push   %eax
  8014f2:	e8 e1 f8 ff ff       	call   800dd8 <fd_alloc>
  8014f7:	89 c3                	mov    %eax,%ebx
  8014f9:	83 c4 10             	add    $0x10,%esp
  8014fc:	85 c0                	test   %eax,%eax
  8014fe:	78 55                	js     801555 <open+0x85>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801500:	83 ec 08             	sub    $0x8,%esp
  801503:	56                   	push   %esi
  801504:	68 00 50 80 00       	push   $0x805000
  801509:	e8 74 f2 ff ff       	call   800782 <strcpy>
	fsipcbuf.open.req_omode = mode;
  80150e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801511:	a3 00 54 80 00       	mov    %eax,0x805400



	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801516:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801519:	b8 01 00 00 00       	mov    $0x1,%eax
  80151e:	e8 65 fe ff ff       	call   801388 <fsipc>
  801523:	89 c3                	mov    %eax,%ebx
  801525:	83 c4 10             	add    $0x10,%esp
  801528:	85 c0                	test   %eax,%eax
  80152a:	79 12                	jns    80153e <open+0x6e>
		fd_close(fd, 0);
  80152c:	83 ec 08             	sub    $0x8,%esp
  80152f:	6a 00                	push   $0x0
  801531:	ff 75 f4             	pushl  -0xc(%ebp)
  801534:	e8 ce f9 ff ff       	call   800f07 <fd_close>
		return r;
  801539:	83 c4 10             	add    $0x10,%esp
  80153c:	eb 17                	jmp    801555 <open+0x85>
	}

	return fd2num(fd);
  80153e:	83 ec 0c             	sub    $0xc,%esp
  801541:	ff 75 f4             	pushl  -0xc(%ebp)
  801544:	e8 67 f8 ff ff       	call   800db0 <fd2num>
  801549:	89 c3                	mov    %eax,%ebx
  80154b:	83 c4 10             	add    $0x10,%esp
  80154e:	eb 05                	jmp    801555 <open+0x85>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801550:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801555:	89 d8                	mov    %ebx,%eax
  801557:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80155a:	5b                   	pop    %ebx
  80155b:	5e                   	pop    %esi
  80155c:	c9                   	leave  
  80155d:	c3                   	ret    
	...

00801560 <map_segment>:
}

static int
map_segment(envid_t child, uintptr_t va, size_t memsz,
	int fd, size_t filesz, off_t fileoffset, int perm)
{
  801560:	55                   	push   %ebp
  801561:	89 e5                	mov    %esp,%ebp
  801563:	57                   	push   %edi
  801564:	56                   	push   %esi
  801565:	53                   	push   %ebx
  801566:	83 ec 1c             	sub    $0x1c,%esp
  801569:	89 c7                	mov    %eax,%edi
  80156b:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  80156e:	89 4d e0             	mov    %ecx,-0x20(%ebp)
	int i, r;
	void *blk;

	//cprintf("map_segment %x+%x\n", va, memsz);

	if ((i = PGOFF(va))) {
  801571:	89 d0                	mov    %edx,%eax
  801573:	25 ff 0f 00 00       	and    $0xfff,%eax
  801578:	74 0c                	je     801586 <map_segment+0x26>
		va -= i;
  80157a:	29 45 e4             	sub    %eax,-0x1c(%ebp)
		memsz += i;
  80157d:	01 45 e0             	add    %eax,-0x20(%ebp)
		filesz += i;
  801580:	01 45 0c             	add    %eax,0xc(%ebp)
		fileoffset -= i;
  801583:	29 45 10             	sub    %eax,0x10(%ebp)
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  801586:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80158a:	0f 84 ee 00 00 00    	je     80167e <map_segment+0x11e>
  801590:	be 00 00 00 00       	mov    $0x0,%esi
  801595:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (i >= filesz) {
  80159a:	39 75 0c             	cmp    %esi,0xc(%ebp)
  80159d:	77 20                	ja     8015bf <map_segment+0x5f>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
  80159f:	83 ec 04             	sub    $0x4,%esp
  8015a2:	ff 75 14             	pushl  0x14(%ebp)
  8015a5:	03 75 e4             	add    -0x1c(%ebp),%esi
  8015a8:	56                   	push   %esi
  8015a9:	57                   	push   %edi
  8015aa:	e8 55 f6 ff ff       	call   800c04 <sys_page_alloc>
  8015af:	83 c4 10             	add    $0x10,%esp
  8015b2:	85 c0                	test   %eax,%eax
  8015b4:	0f 89 ac 00 00 00    	jns    801666 <map_segment+0x106>
  8015ba:	e9 c4 00 00 00       	jmp    801683 <map_segment+0x123>
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  8015bf:	83 ec 04             	sub    $0x4,%esp
  8015c2:	6a 07                	push   $0x7
  8015c4:	68 00 00 40 00       	push   $0x400000
  8015c9:	6a 00                	push   $0x0
  8015cb:	e8 34 f6 ff ff       	call   800c04 <sys_page_alloc>
  8015d0:	83 c4 10             	add    $0x10,%esp
  8015d3:	85 c0                	test   %eax,%eax
  8015d5:	0f 88 a8 00 00 00    	js     801683 <map_segment+0x123>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  8015db:	83 ec 08             	sub    $0x8,%esp
	sys_page_unmap(0, UTEMP);
	return r;
}

static int
map_segment(envid_t child, uintptr_t va, size_t memsz,
  8015de:	8b 45 10             	mov    0x10(%ebp),%eax
  8015e1:	8d 04 03             	lea    (%ebx,%eax,1),%eax
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  8015e4:	50                   	push   %eax
  8015e5:	ff 75 08             	pushl  0x8(%ebp)
  8015e8:	e8 3d fc ff ff       	call   80122a <seek>
  8015ed:	83 c4 10             	add    $0x10,%esp
  8015f0:	85 c0                	test   %eax,%eax
  8015f2:	0f 88 8b 00 00 00    	js     801683 <map_segment+0x123>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  8015f8:	83 ec 04             	sub    $0x4,%esp
  8015fb:	8b 45 0c             	mov    0xc(%ebp),%eax
  8015fe:	29 f0                	sub    %esi,%eax
  801600:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801605:	76 05                	jbe    80160c <map_segment+0xac>
  801607:	b8 00 10 00 00       	mov    $0x1000,%eax
  80160c:	50                   	push   %eax
  80160d:	68 00 00 40 00       	push   $0x400000
  801612:	ff 75 08             	pushl  0x8(%ebp)
  801615:	e8 39 fb ff ff       	call   801153 <readn>
  80161a:	83 c4 10             	add    $0x10,%esp
  80161d:	85 c0                	test   %eax,%eax
  80161f:	78 62                	js     801683 <map_segment+0x123>
				return r;
			if ((r = sys_page_map(0, UTEMP, child, (void*) (va + i), perm)) < 0)
  801621:	83 ec 0c             	sub    $0xc,%esp
  801624:	ff 75 14             	pushl  0x14(%ebp)
  801627:	03 75 e4             	add    -0x1c(%ebp),%esi
  80162a:	56                   	push   %esi
  80162b:	57                   	push   %edi
  80162c:	68 00 00 40 00       	push   $0x400000
  801631:	6a 00                	push   $0x0
  801633:	e8 f0 f5 ff ff       	call   800c28 <sys_page_map>
  801638:	83 c4 20             	add    $0x20,%esp
  80163b:	85 c0                	test   %eax,%eax
  80163d:	79 15                	jns    801654 <map_segment+0xf4>
				panic("spawn: sys_page_map data: %e", r);
  80163f:	50                   	push   %eax
  801640:	68 eb 2a 80 00       	push   $0x802aeb
  801645:	68 84 01 00 00       	push   $0x184
  80164a:	68 08 2b 80 00       	push   $0x802b08
  80164f:	e8 a0 ea ff ff       	call   8000f4 <_panic>
			sys_page_unmap(0, UTEMP);
  801654:	83 ec 08             	sub    $0x8,%esp
  801657:	68 00 00 40 00       	push   $0x400000
  80165c:	6a 00                	push   $0x0
  80165e:	e8 eb f5 ff ff       	call   800c4e <sys_page_unmap>
  801663:	83 c4 10             	add    $0x10,%esp
		memsz += i;
		filesz += i;
		fileoffset -= i;
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  801666:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  80166c:	89 de                	mov    %ebx,%esi
  80166e:	39 5d e0             	cmp    %ebx,-0x20(%ebp)
  801671:	0f 87 23 ff ff ff    	ja     80159a <map_segment+0x3a>
			if ((r = sys_page_map(0, UTEMP, child, (void*) (va + i), perm)) < 0)
				panic("spawn: sys_page_map data: %e", r);
			sys_page_unmap(0, UTEMP);
		}
	}
	return 0;
  801677:	b8 00 00 00 00       	mov    $0x0,%eax
  80167c:	eb 05                	jmp    801683 <map_segment+0x123>
  80167e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801683:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801686:	5b                   	pop    %ebx
  801687:	5e                   	pop    %esi
  801688:	5f                   	pop    %edi
  801689:	c9                   	leave  
  80168a:	c3                   	ret    

0080168b <init_stack>:
// On success, returns 0 and sets *init_esp
// to the initial stack pointer with which the child should start.
// Returns < 0 on failure.
static int
init_stack(envid_t child, const char **argv, uintptr_t *init_esp, uint32_t stack_addr)
{
  80168b:	55                   	push   %ebp
  80168c:	89 e5                	mov    %esp,%ebp
  80168e:	57                   	push   %edi
  80168f:	56                   	push   %esi
  801690:	53                   	push   %ebx
  801691:	83 ec 2c             	sub    $0x2c,%esp
  801694:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801697:	89 d7                	mov    %edx,%edi
  801699:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  80169c:	8b 02                	mov    (%edx),%eax
  80169e:	85 c0                	test   %eax,%eax
  8016a0:	74 31                	je     8016d3 <init_stack+0x48>
  8016a2:	bb 00 00 00 00       	mov    $0x0,%ebx
	char *string_store;
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
  8016a7:	be 00 00 00 00       	mov    $0x0,%esi
	for (argc = 0; argv[argc] != 0; argc++)
		string_size += strlen(argv[argc]) + 1;
  8016ac:	83 ec 0c             	sub    $0xc,%esp
  8016af:	50                   	push   %eax
  8016b0:	e8 7b f0 ff ff       	call   800730 <strlen>
  8016b5:	8d 74 30 01          	lea    0x1(%eax,%esi,1),%esi
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  8016b9:	43                   	inc    %ebx
  8016ba:	8d 0c 9d 00 00 00 00 	lea    0x0(,%ebx,4),%ecx
  8016c1:	8b 04 9f             	mov    (%edi,%ebx,4),%eax
  8016c4:	83 c4 10             	add    $0x10,%esp
  8016c7:	85 c0                	test   %eax,%eax
  8016c9:	75 e1                	jne    8016ac <init_stack+0x21>
  8016cb:	89 5d d0             	mov    %ebx,-0x30(%ebp)
  8016ce:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8016d1:	eb 18                	jmp    8016eb <init_stack+0x60>
  8016d3:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
  8016da:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
  8016e1:	bb 00 00 00 00       	mov    $0x0,%ebx
	char *string_store;
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
  8016e6:	be 00 00 00 00       	mov    $0x0,%esi
	// Determine where to place the strings and the argv array.
	// Set up pointers into the temporary page 'UTEMP'; we'll map a page
	// there later, then remap that page into the child environment
	// at (USTACKTOP - PGSIZE).
	// strings is the topmost thing on the stack.
	string_store = (char*) UTEMP + PGSIZE - string_size;
  8016eb:	f7 de                	neg    %esi
  8016ed:	81 c6 00 10 40 00    	add    $0x401000,%esi
  8016f3:	89 75 dc             	mov    %esi,-0x24(%ebp)
	// argv is below that.  There's one argument pointer per argument, plus
	// a null pointer.
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));
  8016f6:	89 f2                	mov    %esi,%edx
  8016f8:	83 e2 fc             	and    $0xfffffffc,%edx
  8016fb:	89 d8                	mov    %ebx,%eax
  8016fd:	f7 d0                	not    %eax
  8016ff:	8d 04 82             	lea    (%edx,%eax,4),%eax
  801702:	89 45 e4             	mov    %eax,-0x1c(%ebp)

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
  801705:	83 e8 08             	sub    $0x8,%eax
  801708:	3d ff ff 3f 00       	cmp    $0x3fffff,%eax
  80170d:	0f 86 fb 00 00 00    	jbe    80180e <init_stack+0x183>
		return -E_NO_MEM;

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801713:	83 ec 04             	sub    $0x4,%esp
  801716:	6a 07                	push   $0x7
  801718:	68 00 00 40 00       	push   $0x400000
  80171d:	6a 00                	push   $0x0
  80171f:	e8 e0 f4 ff ff       	call   800c04 <sys_page_alloc>
  801724:	89 c6                	mov    %eax,%esi
  801726:	83 c4 10             	add    $0x10,%esp
  801729:	85 c0                	test   %eax,%eax
  80172b:	0f 88 e9 00 00 00    	js     80181a <init_stack+0x18f>
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  801731:	85 db                	test   %ebx,%ebx
  801733:	7e 3e                	jle    801773 <init_stack+0xe8>
  801735:	be 00 00 00 00       	mov    $0x0,%esi
  80173a:	89 5d e0             	mov    %ebx,-0x20(%ebp)
  80173d:	8b 5d dc             	mov    -0x24(%ebp),%ebx
		argv_store[i] = UTEMP2USTACK(string_store);
  801740:	8d 83 00 d0 7f ee    	lea    -0x11803000(%ebx),%eax
  801746:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801749:	89 04 b2             	mov    %eax,(%edx,%esi,4)
		strcpy(string_store, argv[i]);
  80174c:	83 ec 08             	sub    $0x8,%esp
  80174f:	ff 34 b7             	pushl  (%edi,%esi,4)
  801752:	53                   	push   %ebx
  801753:	e8 2a f0 ff ff       	call   800782 <strcpy>
		string_store += strlen(argv[i]) + 1;
  801758:	83 c4 04             	add    $0x4,%esp
  80175b:	ff 34 b7             	pushl  (%edi,%esi,4)
  80175e:	e8 cd ef ff ff       	call   800730 <strlen>
  801763:	8d 5c 03 01          	lea    0x1(%ebx,%eax,1),%ebx
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  801767:	46                   	inc    %esi
  801768:	83 c4 10             	add    $0x10,%esp
  80176b:	3b 75 e0             	cmp    -0x20(%ebp),%esi
  80176e:	7c d0                	jl     801740 <init_stack+0xb5>
  801770:	89 5d dc             	mov    %ebx,-0x24(%ebp)
		argv_store[i] = UTEMP2USTACK(string_store);
		strcpy(string_store, argv[i]);
		string_store += strlen(argv[i]) + 1;
	}
	argv_store[argc] = 0;
  801773:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801776:	8b 45 cc             	mov    -0x34(%ebp),%eax
  801779:	c7 04 02 00 00 00 00 	movl   $0x0,(%edx,%eax,1)
	assert(string_store == (char*)UTEMP + PGSIZE);
  801780:	81 7d dc 00 10 40 00 	cmpl   $0x401000,-0x24(%ebp)
  801787:	74 19                	je     8017a2 <init_stack+0x117>
  801789:	68 78 2b 80 00       	push   $0x802b78
  80178e:	68 bf 2a 80 00       	push   $0x802abf
  801793:	68 51 01 00 00       	push   $0x151
  801798:	68 08 2b 80 00       	push   $0x802b08
  80179d:	e8 52 e9 ff ff       	call   8000f4 <_panic>

	argv_store[-1] = UTEMP2USTACK(argv_store);
  8017a2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8017a5:	2d 00 30 80 11       	sub    $0x11803000,%eax
  8017aa:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8017ad:	89 42 fc             	mov    %eax,-0x4(%edx)
	argv_store[-2] = argc;
  8017b0:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8017b3:	89 42 f8             	mov    %eax,-0x8(%edx)

	*init_esp = UTEMP2USTACK(&argv_store[-2]);
  8017b6:	89 d0                	mov    %edx,%eax
  8017b8:	2d 08 30 80 11       	sub    $0x11803008,%eax
  8017bd:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8017c0:	89 02                	mov    %eax,(%edx)

	// After completing the stack, map it into the child's address space
	// and unmap it from ours!
	
	if ((r = sys_page_map(0, UTEMP, child, (void*) stack_addr, PTE_P | PTE_U | PTE_W)) < 0)
  8017c2:	83 ec 0c             	sub    $0xc,%esp
  8017c5:	6a 07                	push   $0x7
  8017c7:	ff 75 08             	pushl  0x8(%ebp)
  8017ca:	ff 75 d8             	pushl  -0x28(%ebp)
  8017cd:	68 00 00 40 00       	push   $0x400000
  8017d2:	6a 00                	push   $0x0
  8017d4:	e8 4f f4 ff ff       	call   800c28 <sys_page_map>
  8017d9:	89 c6                	mov    %eax,%esi
  8017db:	83 c4 20             	add    $0x20,%esp
  8017de:	85 c0                	test   %eax,%eax
  8017e0:	78 18                	js     8017fa <init_stack+0x16f>
		goto error;
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  8017e2:	83 ec 08             	sub    $0x8,%esp
  8017e5:	68 00 00 40 00       	push   $0x400000
  8017ea:	6a 00                	push   $0x0
  8017ec:	e8 5d f4 ff ff       	call   800c4e <sys_page_unmap>
  8017f1:	89 c6                	mov    %eax,%esi
  8017f3:	83 c4 10             	add    $0x10,%esp
  8017f6:	85 c0                	test   %eax,%eax
  8017f8:	79 1b                	jns    801815 <init_stack+0x18a>
		goto error;
	return 0;

error:
	sys_page_unmap(0, UTEMP);
  8017fa:	83 ec 08             	sub    $0x8,%esp
  8017fd:	68 00 00 40 00       	push   $0x400000
  801802:	6a 00                	push   $0x0
  801804:	e8 45 f4 ff ff       	call   800c4e <sys_page_unmap>
	return r;
  801809:	83 c4 10             	add    $0x10,%esp
  80180c:	eb 0c                	jmp    80181a <init_stack+0x18f>
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
		return -E_NO_MEM;
  80180e:	be fc ff ff ff       	mov    $0xfffffffc,%esi
  801813:	eb 05                	jmp    80181a <init_stack+0x18f>
	
	if ((r = sys_page_map(0, UTEMP, child, (void*) stack_addr, PTE_P | PTE_U | PTE_W)) < 0)
		goto error;
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
		goto error;
	return 0;
  801815:	be 00 00 00 00       	mov    $0x0,%esi

error:
	sys_page_unmap(0, UTEMP);
	return r;
}
  80181a:	89 f0                	mov    %esi,%eax
  80181c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80181f:	5b                   	pop    %ebx
  801820:	5e                   	pop    %esi
  801821:	5f                   	pop    %edi
  801822:	c9                   	leave  
  801823:	c3                   	ret    

00801824 <spawn>:
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
{
  801824:	55                   	push   %ebp
  801825:	89 e5                	mov    %esp,%ebp
  801827:	57                   	push   %edi
  801828:	56                   	push   %esi
  801829:	53                   	push   %ebx
  80182a:	81 ec 74 02 00 00    	sub    $0x274,%esp
	//   - Call sys_env_set_trapframe(child, &child_tf) to set up the
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
  801830:	6a 00                	push   $0x0
  801832:	ff 75 08             	pushl  0x8(%ebp)
  801835:	e8 96 fc ff ff       	call   8014d0 <open>
  80183a:	89 85 90 fd ff ff    	mov    %eax,-0x270(%ebp)
  801840:	83 c4 10             	add    $0x10,%esp
  801843:	85 c0                	test   %eax,%eax
  801845:	0f 88 3f 02 00 00    	js     801a8a <spawn+0x266>
		return r;
	fd = r;

	// Read elf header
	elf = (struct Elf*) elf_buf;
	if (readn(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf)
  80184b:	83 ec 04             	sub    $0x4,%esp
  80184e:	68 00 02 00 00       	push   $0x200
  801853:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  801859:	50                   	push   %eax
  80185a:	ff b5 90 fd ff ff    	pushl  -0x270(%ebp)
  801860:	e8 ee f8 ff ff       	call   801153 <readn>
  801865:	83 c4 10             	add    $0x10,%esp
  801868:	3d 00 02 00 00       	cmp    $0x200,%eax
  80186d:	75 0c                	jne    80187b <spawn+0x57>
	    || elf->e_magic != ELF_MAGIC) {
  80186f:	81 bd e8 fd ff ff 7f 	cmpl   $0x464c457f,-0x218(%ebp)
  801876:	45 4c 46 
  801879:	74 38                	je     8018b3 <spawn+0x8f>
		close(fd);
  80187b:	83 ec 0c             	sub    $0xc,%esp
  80187e:	ff b5 90 fd ff ff    	pushl  -0x270(%ebp)
  801884:	e8 06 f7 ff ff       	call   800f8f <close>
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
  801889:	83 c4 0c             	add    $0xc,%esp
  80188c:	68 7f 45 4c 46       	push   $0x464c457f
  801891:	ff b5 e8 fd ff ff    	pushl  -0x218(%ebp)
  801897:	68 14 2b 80 00       	push   $0x802b14
  80189c:	e8 2b e9 ff ff       	call   8001cc <cprintf>
		return -E_NOT_EXEC;
  8018a1:	83 c4 10             	add    $0x10,%esp
  8018a4:	c7 85 94 fd ff ff f2 	movl   $0xfffffff2,-0x26c(%ebp)
  8018ab:	ff ff ff 
  8018ae:	e9 eb 01 00 00       	jmp    801a9e <spawn+0x27a>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  8018b3:	ba 07 00 00 00       	mov    $0x7,%edx
  8018b8:	89 d0                	mov    %edx,%eax
  8018ba:	cd 30                	int    $0x30
  8018bc:	89 85 8c fd ff ff    	mov    %eax,-0x274(%ebp)
  8018c2:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)
	}


	// Create new child environment
	if ((r = sys_exofork()) < 0)
  8018c8:	85 c0                	test   %eax,%eax
  8018ca:	0f 88 ce 01 00 00    	js     801a9e <spawn+0x27a>
		return r;
	child = r;

	// Set up trap frame, including initial stack.
	child_tf = envs[ENVX(child)].env_tf;
  8018d0:	25 ff 03 00 00       	and    $0x3ff,%eax
  8018d5:	89 c2                	mov    %eax,%edx
  8018d7:	c1 e2 07             	shl    $0x7,%edx
  8018da:	8d b4 82 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,4),%esi
  8018e1:	8d bd a4 fd ff ff    	lea    -0x25c(%ebp),%edi
  8018e7:	b9 11 00 00 00       	mov    $0x11,%ecx
  8018ec:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	child_tf.tf_eip = elf->e_entry;
  8018ee:	8b 85 00 fe ff ff    	mov    -0x200(%ebp),%eax
  8018f4:	89 85 d4 fd ff ff    	mov    %eax,-0x22c(%ebp)

	if ((r = init_stack(child, argv, &child_tf.tf_esp, (USTACKTOP - PGSIZE))) < 0)
  8018fa:	83 ec 0c             	sub    $0xc,%esp
  8018fd:	8d 8d e0 fd ff ff    	lea    -0x220(%ebp),%ecx
  801903:	68 00 d0 bf ee       	push   $0xeebfd000
  801908:	8b 55 0c             	mov    0xc(%ebp),%edx
  80190b:	8b 85 8c fd ff ff    	mov    -0x274(%ebp),%eax
  801911:	e8 75 fd ff ff       	call   80168b <init_stack>
  801916:	83 c4 10             	add    $0x10,%esp
  801919:	85 c0                	test   %eax,%eax
  80191b:	0f 88 77 01 00 00    	js     801a98 <spawn+0x274>
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  801921:	8b 85 04 fe ff ff    	mov    -0x1fc(%ebp),%eax
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801927:	66 83 bd 14 fe ff ff 	cmpw   $0x0,-0x1ec(%ebp)
  80192e:	00 
  80192f:	74 5d                	je     80198e <spawn+0x16a>

	if ((r = init_stack(child, argv, &child_tf.tf_esp, (USTACKTOP - PGSIZE))) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  801931:	8d 9c 05 e8 fd ff ff 	lea    -0x218(%ebp,%eax,1),%ebx
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801938:	be 00 00 00 00       	mov    $0x0,%esi
  80193d:	8b bd 90 fd ff ff    	mov    -0x270(%ebp),%edi
		if (ph->p_type != ELF_PROG_LOAD)
  801943:	83 3b 01             	cmpl   $0x1,(%ebx)
  801946:	75 35                	jne    80197d <spawn+0x159>
			continue;
		perm = PTE_P | PTE_U;
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
  801948:	8b 43 18             	mov    0x18(%ebx),%eax
  80194b:	83 e0 02             	and    $0x2,%eax
	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
		if (ph->p_type != ELF_PROG_LOAD)
			continue;
		perm = PTE_P | PTE_U;
  80194e:	83 f8 01             	cmp    $0x1,%eax
  801951:	19 c0                	sbb    %eax,%eax
  801953:	83 e0 fe             	and    $0xfffffffe,%eax
  801956:	83 c0 07             	add    $0x7,%eax
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
  801959:	8b 4b 14             	mov    0x14(%ebx),%ecx
  80195c:	8b 53 08             	mov    0x8(%ebx),%edx
  80195f:	50                   	push   %eax
  801960:	ff 73 04             	pushl  0x4(%ebx)
  801963:	ff 73 10             	pushl  0x10(%ebx)
  801966:	57                   	push   %edi
  801967:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  80196d:	e8 ee fb ff ff       	call   801560 <map_segment>
  801972:	83 c4 10             	add    $0x10,%esp
  801975:	85 c0                	test   %eax,%eax
  801977:	0f 88 e4 00 00 00    	js     801a61 <spawn+0x23d>
	if ((r = init_stack(child, argv, &child_tf.tf_esp, (USTACKTOP - PGSIZE))) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  80197d:	46                   	inc    %esi
  80197e:	0f b7 85 14 fe ff ff 	movzwl -0x1ec(%ebp),%eax
  801985:	39 f0                	cmp    %esi,%eax
  801987:	7e 05                	jle    80198e <spawn+0x16a>
  801989:	83 c3 20             	add    $0x20,%ebx
  80198c:	eb b5                	jmp    801943 <spawn+0x11f>
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
				     fd, ph->p_filesz, ph->p_offset, perm)) < 0)
			goto error;
	}
	close(fd);
  80198e:	83 ec 0c             	sub    $0xc,%esp
  801991:	ff b5 90 fd ff ff    	pushl  -0x270(%ebp)
  801997:	e8 f3 f5 ff ff       	call   800f8f <close>
  80199c:	83 c4 10             	add    $0x10,%esp
copy_shared_pages(envid_t child)
{
	// LAB 5: Your code here.
    uint32_t i;
    int r;
    for (i = 0; i != UTOP; i += PGSIZE) 
  80199f:	bb 00 00 00 00       	mov    $0x0,%ebx
  8019a4:	8b b5 94 fd ff ff    	mov    -0x26c(%ebp),%esi
    if ((uvpd[PDX(i)] & PTE_P) && (uvpt[i / PGSIZE] & PTE_P) && (uvpt[i / PGSIZE] & PTE_SHARE)) {
  8019aa:	89 d8                	mov    %ebx,%eax
  8019ac:	c1 e8 16             	shr    $0x16,%eax
  8019af:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8019b6:	a8 01                	test   $0x1,%al
  8019b8:	74 3e                	je     8019f8 <spawn+0x1d4>
  8019ba:	89 d8                	mov    %ebx,%eax
  8019bc:	c1 e8 0c             	shr    $0xc,%eax
  8019bf:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8019c6:	f6 c2 01             	test   $0x1,%dl
  8019c9:	74 2d                	je     8019f8 <spawn+0x1d4>
  8019cb:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8019d2:	f6 c6 04             	test   $0x4,%dh
  8019d5:	74 21                	je     8019f8 <spawn+0x1d4>
        r = sys_page_map(0, (void *)i, child, (void *)i, uvpt[i / PGSIZE] & PTE_SYSCALL);
  8019d7:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8019de:	83 ec 0c             	sub    $0xc,%esp
  8019e1:	25 07 0e 00 00       	and    $0xe07,%eax
  8019e6:	50                   	push   %eax
  8019e7:	53                   	push   %ebx
  8019e8:	56                   	push   %esi
  8019e9:	53                   	push   %ebx
  8019ea:	6a 00                	push   $0x0
  8019ec:	e8 37 f2 ff ff       	call   800c28 <sys_page_map>
        if (r < 0) return r;
  8019f1:	83 c4 20             	add    $0x20,%esp
  8019f4:	85 c0                	test   %eax,%eax
  8019f6:	78 13                	js     801a0b <spawn+0x1e7>
copy_shared_pages(envid_t child)
{
	// LAB 5: Your code here.
    uint32_t i;
    int r;
    for (i = 0; i != UTOP; i += PGSIZE) 
  8019f8:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  8019fe:	81 fb 00 00 c0 ee    	cmp    $0xeec00000,%ebx
  801a04:	75 a4                	jne    8019aa <spawn+0x186>
  801a06:	e9 a1 00 00 00       	jmp    801aac <spawn+0x288>
	close(fd);
	fd = -1;

	// Copy shared library state.
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);
  801a0b:	50                   	push   %eax
  801a0c:	68 2e 2b 80 00       	push   $0x802b2e
  801a11:	68 85 00 00 00       	push   $0x85
  801a16:	68 08 2b 80 00       	push   $0x802b08
  801a1b:	e8 d4 e6 ff ff       	call   8000f4 <_panic>

	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
		panic("sys_env_set_trapframe: %e", r);
  801a20:	50                   	push   %eax
  801a21:	68 44 2b 80 00       	push   $0x802b44
  801a26:	68 88 00 00 00       	push   $0x88
  801a2b:	68 08 2b 80 00       	push   $0x802b08
  801a30:	e8 bf e6 ff ff       	call   8000f4 <_panic>

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
  801a35:	83 ec 08             	sub    $0x8,%esp
  801a38:	6a 02                	push   $0x2
  801a3a:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801a40:	e8 2c f2 ff ff       	call   800c71 <sys_env_set_status>
  801a45:	83 c4 10             	add    $0x10,%esp
  801a48:	85 c0                	test   %eax,%eax
  801a4a:	79 52                	jns    801a9e <spawn+0x27a>
		panic("sys_env_set_status: %e", r);
  801a4c:	50                   	push   %eax
  801a4d:	68 5e 2b 80 00       	push   $0x802b5e
  801a52:	68 8b 00 00 00       	push   $0x8b
  801a57:	68 08 2b 80 00       	push   $0x802b08
  801a5c:	e8 93 e6 ff ff       	call   8000f4 <_panic>
  801a61:	89 c7                	mov    %eax,%edi

	return child;

error:
	sys_env_destroy(child);
  801a63:	83 ec 0c             	sub    $0xc,%esp
  801a66:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801a6c:	e8 26 f1 ff ff       	call   800b97 <sys_env_destroy>
	close(fd);
  801a71:	83 c4 04             	add    $0x4,%esp
  801a74:	ff b5 90 fd ff ff    	pushl  -0x270(%ebp)
  801a7a:	e8 10 f5 ff ff       	call   800f8f <close>
	return r;
  801a7f:	83 c4 10             	add    $0x10,%esp
		if (ph->p_type != ELF_PROG_LOAD)
			continue;
		perm = PTE_P | PTE_U;
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
  801a82:	89 bd 94 fd ff ff    	mov    %edi,-0x26c(%ebp)
	return child;

error:
	sys_env_destroy(child);
	close(fd);
	return r;
  801a88:	eb 14                	jmp    801a9e <spawn+0x27a>
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
		return r;
  801a8a:	8b 85 90 fd ff ff    	mov    -0x270(%ebp),%eax
  801a90:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)
  801a96:	eb 06                	jmp    801a9e <spawn+0x27a>
	// Set up trap frame, including initial stack.
	child_tf = envs[ENVX(child)].env_tf;
	child_tf.tf_eip = elf->e_entry;

	if ((r = init_stack(child, argv, &child_tf.tf_esp, (USTACKTOP - PGSIZE))) < 0)
		return r;
  801a98:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)

error:
	sys_env_destroy(child);
	close(fd);
	return r;
}
  801a9e:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  801aa4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801aa7:	5b                   	pop    %ebx
  801aa8:	5e                   	pop    %esi
  801aa9:	5f                   	pop    %edi
  801aaa:	c9                   	leave  
  801aab:	c3                   	ret    

	// Copy shared library state.
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);

	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
  801aac:	83 ec 08             	sub    $0x8,%esp
  801aaf:	8d 85 a4 fd ff ff    	lea    -0x25c(%ebp),%eax
  801ab5:	50                   	push   %eax
  801ab6:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801abc:	e8 d3 f1 ff ff       	call   800c94 <sys_env_set_trapframe>
  801ac1:	83 c4 10             	add    $0x10,%esp
  801ac4:	85 c0                	test   %eax,%eax
  801ac6:	0f 89 69 ff ff ff    	jns    801a35 <spawn+0x211>
  801acc:	e9 4f ff ff ff       	jmp    801a20 <spawn+0x1fc>

00801ad1 <exec>:
// 		 0x80000000(MYTEMPLATE) to be template block cache. Then sys_exec is a system call to complete 
// 		 memory setting.
// Remember: When there is virtual memory in ELF linking address overlaped with MYTEMPLATE, exec will fail.
int
exec(const char *prog, const char **argv)
{
  801ad1:	55                   	push   %ebp
  801ad2:	89 e5                	mov    %esp,%ebp
  801ad4:	57                   	push   %edi
  801ad5:	56                   	push   %esi
  801ad6:	53                   	push   %ebx
  801ad7:	81 ec 34 02 00 00    	sub    $0x234,%esp
	struct Elf *elf;
	struct Proghdr *ph;
	int perm;	


	if ((r = open(prog, O_RDONLY)) < 0)
  801add:	6a 00                	push   $0x0
  801adf:	ff 75 08             	pushl  0x8(%ebp)
  801ae2:	e8 e9 f9 ff ff       	call   8014d0 <open>
  801ae7:	89 85 d0 fd ff ff    	mov    %eax,-0x230(%ebp)
  801aed:	83 c4 10             	add    $0x10,%esp
  801af0:	85 c0                	test   %eax,%eax
  801af2:	0f 88 a9 01 00 00    	js     801ca1 <exec+0x1d0>
		return r;
	fd = r;

	// Read elf header
	elf = (struct Elf*) elf_buf;
  801af8:	8d bd e8 fd ff ff    	lea    -0x218(%ebp),%edi
	if (readn(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf)
  801afe:	83 ec 04             	sub    $0x4,%esp
  801b01:	68 00 02 00 00       	push   $0x200
  801b06:	57                   	push   %edi
  801b07:	50                   	push   %eax
  801b08:	e8 46 f6 ff ff       	call   801153 <readn>
  801b0d:	83 c4 10             	add    $0x10,%esp
  801b10:	3d 00 02 00 00       	cmp    $0x200,%eax
  801b15:	75 0c                	jne    801b23 <exec+0x52>
	    || elf->e_magic != ELF_MAGIC) {
  801b17:	81 bd e8 fd ff ff 7f 	cmpl   $0x464c457f,-0x218(%ebp)
  801b1e:	45 4c 46 
  801b21:	74 34                	je     801b57 <exec+0x86>
		close(fd);
  801b23:	83 ec 0c             	sub    $0xc,%esp
  801b26:	ff b5 d0 fd ff ff    	pushl  -0x230(%ebp)
  801b2c:	e8 5e f4 ff ff       	call   800f8f <close>
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
  801b31:	83 c4 0c             	add    $0xc,%esp
  801b34:	68 7f 45 4c 46       	push   $0x464c457f
  801b39:	ff 37                	pushl  (%edi)
  801b3b:	68 14 2b 80 00       	push   $0x802b14
  801b40:	e8 87 e6 ff ff       	call   8001cc <cprintf>
		return -E_NOT_EXEC;
  801b45:	83 c4 10             	add    $0x10,%esp
  801b48:	c7 85 d0 fd ff ff f2 	movl   $0xfffffff2,-0x230(%ebp)
  801b4f:	ff ff ff 
  801b52:	e9 4a 01 00 00       	jmp    801ca1 <exec+0x1d0>
	}


	// Set up program segments as defined in ELF header.
	uint32_t now_addr = MYTEMPLATE;
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  801b57:	8b 47 1c             	mov    0x1c(%edi),%eax
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801b5a:	66 83 7f 2c 00       	cmpw   $0x0,0x2c(%edi)
  801b5f:	0f 84 8b 00 00 00    	je     801bf0 <exec+0x11f>
	}


	// Set up program segments as defined in ELF header.
	uint32_t now_addr = MYTEMPLATE;
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  801b65:	8d 9c 05 e8 fd ff ff 	lea    -0x218(%ebp,%eax,1),%ebx
		return -E_NOT_EXEC;
	}


	// Set up program segments as defined in ELF header.
	uint32_t now_addr = MYTEMPLATE;
  801b6c:	c7 85 d4 fd ff ff 00 	movl   $0x80000000,-0x22c(%ebp)
  801b73:	00 00 80 
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801b76:	be 00 00 00 00       	mov    $0x0,%esi
		if (ph->p_type != ELF_PROG_LOAD)
  801b7b:	83 3b 01             	cmpl   $0x1,(%ebx)
  801b7e:	75 62                	jne    801be2 <exec+0x111>
			continue;
		perm = PTE_P | PTE_U;
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
  801b80:	8b 43 18             	mov    0x18(%ebx),%eax
  801b83:	83 e0 02             	and    $0x2,%eax
	uint32_t now_addr = MYTEMPLATE;
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
		if (ph->p_type != ELF_PROG_LOAD)
			continue;
		perm = PTE_P | PTE_U;
  801b86:	83 f8 01             	cmp    $0x1,%eax
  801b89:	19 c0                	sbb    %eax,%eax
  801b8b:	83 e0 fe             	and    $0xfffffffe,%eax
  801b8e:	83 c0 07             	add    $0x7,%eax
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
			perm |= PTE_W;
		if ((r = map_segment(0, PGOFF(ph->p_va) + now_addr, ph->p_memsz,
  801b91:	8b 4b 14             	mov    0x14(%ebx),%ecx
  801b94:	8b 53 08             	mov    0x8(%ebx),%edx
  801b97:	81 e2 ff 0f 00 00    	and    $0xfff,%edx
  801b9d:	03 95 d4 fd ff ff    	add    -0x22c(%ebp),%edx
  801ba3:	50                   	push   %eax
  801ba4:	ff 73 04             	pushl  0x4(%ebx)
  801ba7:	ff 73 10             	pushl  0x10(%ebx)
  801baa:	ff b5 d0 fd ff ff    	pushl  -0x230(%ebp)
  801bb0:	b8 00 00 00 00       	mov    $0x0,%eax
  801bb5:	e8 a6 f9 ff ff       	call   801560 <map_segment>
  801bba:	83 c4 10             	add    $0x10,%esp
  801bbd:	85 c0                	test   %eax,%eax
  801bbf:	0f 88 a3 00 00 00    	js     801c68 <exec+0x197>
				     fd, ph->p_filesz, ph->p_offset, perm)) < 0)
			goto error;
		now_addr += ROUNDUP(ph->p_memsz + PGOFF(ph->p_va), PGSIZE);
  801bc5:	8b 53 14             	mov    0x14(%ebx),%edx
  801bc8:	8b 43 08             	mov    0x8(%ebx),%eax
  801bcb:	25 ff 0f 00 00       	and    $0xfff,%eax
  801bd0:	8d 84 02 ff 0f 00 00 	lea    0xfff(%edx,%eax,1),%eax
  801bd7:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801bdc:	01 85 d4 fd ff ff    	add    %eax,-0x22c(%ebp)


	// Set up program segments as defined in ELF header.
	uint32_t now_addr = MYTEMPLATE;
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801be2:	46                   	inc    %esi
  801be3:	0f b7 47 2c          	movzwl 0x2c(%edi),%eax
  801be7:	39 f0                	cmp    %esi,%eax
  801be9:	7e 0f                	jle    801bfa <exec+0x129>
  801beb:	83 c3 20             	add    $0x20,%ebx
  801bee:	eb 8b                	jmp    801b7b <exec+0xaa>
		return -E_NOT_EXEC;
	}


	// Set up program segments as defined in ELF header.
	uint32_t now_addr = MYTEMPLATE;
  801bf0:	c7 85 d4 fd ff ff 00 	movl   $0x80000000,-0x22c(%ebp)
  801bf7:	00 00 80 
		if ((r = map_segment(0, PGOFF(ph->p_va) + now_addr, ph->p_memsz,
				     fd, ph->p_filesz, ph->p_offset, perm)) < 0)
			goto error;
		now_addr += ROUNDUP(ph->p_memsz + PGOFF(ph->p_va), PGSIZE);
	}
	close(fd);
  801bfa:	83 ec 0c             	sub    $0xc,%esp
  801bfd:	ff b5 d0 fd ff ff    	pushl  -0x230(%ebp)
  801c03:	e8 87 f3 ff ff       	call   800f8f <close>
	fd = -1;

	// Set up Stack 
	if ((r = init_stack(0, argv, &tf_esp, now_addr)) < 0)
  801c08:	83 c4 04             	add    $0x4,%esp
  801c0b:	8d 8d e4 fd ff ff    	lea    -0x21c(%ebp),%ecx
  801c11:	ff b5 d4 fd ff ff    	pushl  -0x22c(%ebp)
  801c17:	8b 55 0c             	mov    0xc(%ebp),%edx
  801c1a:	b8 00 00 00 00       	mov    $0x0,%eax
  801c1f:	e8 67 fa ff ff       	call   80168b <init_stack>
  801c24:	89 85 d0 fd ff ff    	mov    %eax,-0x230(%ebp)
  801c2a:	83 c4 10             	add    $0x10,%esp
  801c2d:	85 c0                	test   %eax,%eax
  801c2f:	78 70                	js     801ca1 <exec+0x1d0>
		return r;

	// Syscall to exec
	if (sys_exec(elf->e_entry, tf_esp, (void *)(elf_buf + elf->e_phoff), elf->e_phnum) < 0)
  801c31:	0f b7 47 2c          	movzwl 0x2c(%edi),%eax
  801c35:	50                   	push   %eax
  801c36:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  801c3c:	03 47 1c             	add    0x1c(%edi),%eax
  801c3f:	50                   	push   %eax
  801c40:	ff b5 e4 fd ff ff    	pushl  -0x21c(%ebp)
  801c46:	ff 77 18             	pushl  0x18(%edi)
  801c49:	e8 f6 f0 ff ff       	call   800d44 <sys_exec>
  801c4e:	83 c4 10             	add    $0x10,%esp
  801c51:	85 c0                	test   %eax,%eax
  801c53:	79 42                	jns    801c97 <exec+0x1c6>
	}
	close(fd);
	fd = -1;

	// Set up Stack 
	if ((r = init_stack(0, argv, &tf_esp, now_addr)) < 0)
  801c55:	8b 85 d0 fd ff ff    	mov    -0x230(%ebp),%eax
  801c5b:	89 85 d4 fd ff ff    	mov    %eax,-0x22c(%ebp)
				     fd, ph->p_filesz, ph->p_offset, perm)) < 0)
			goto error;
		now_addr += ROUNDUP(ph->p_memsz + PGOFF(ph->p_va), PGSIZE);
	}
	close(fd);
	fd = -1;
  801c61:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
  801c66:	eb 0c                	jmp    801c74 <exec+0x1a3>
  801c68:	89 85 d4 fd ff ff    	mov    %eax,-0x22c(%ebp)
	int perm;	


	if ((r = open(prog, O_RDONLY)) < 0)
		return r;
	fd = r;
  801c6e:	8b 9d d0 fd ff ff    	mov    -0x230(%ebp),%ebx
	if (sys_exec(elf->e_entry, tf_esp, (void *)(elf_buf + elf->e_phoff), elf->e_phnum) < 0)
		goto error;
	return 0;

error:
	sys_env_destroy(0);
  801c74:	83 ec 0c             	sub    $0xc,%esp
  801c77:	6a 00                	push   $0x0
  801c79:	e8 19 ef ff ff       	call   800b97 <sys_env_destroy>
	close(fd);
  801c7e:	89 1c 24             	mov    %ebx,(%esp)
  801c81:	e8 09 f3 ff ff       	call   800f8f <close>
	return r;
  801c86:	83 c4 10             	add    $0x10,%esp
  801c89:	8b 85 d4 fd ff ff    	mov    -0x22c(%ebp),%eax
  801c8f:	89 85 d0 fd ff ff    	mov    %eax,-0x230(%ebp)
  801c95:	eb 0a                	jmp    801ca1 <exec+0x1d0>
		return r;

	// Syscall to exec
	if (sys_exec(elf->e_entry, tf_esp, (void *)(elf_buf + elf->e_phoff), elf->e_phnum) < 0)
		goto error;
	return 0;
  801c97:	c7 85 d0 fd ff ff 00 	movl   $0x0,-0x230(%ebp)
  801c9e:	00 00 00 

error:
	sys_env_destroy(0);
	close(fd);
	return r;
}
  801ca1:	8b 85 d0 fd ff ff    	mov    -0x230(%ebp),%eax
  801ca7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801caa:	5b                   	pop    %ebx
  801cab:	5e                   	pop    %esi
  801cac:	5f                   	pop    %edi
  801cad:	c9                   	leave  
  801cae:	c3                   	ret    

00801caf <execl>:
// Exec, taking command-line arguments array directly on the stack.
// NOTE: Must have a sentinal of NULL at the end of the args
// (none of the args may be NULL).
int
execl(const char *prog, const char *arg0, ...)
{
  801caf:	55                   	push   %ebp
  801cb0:	89 e5                	mov    %esp,%ebp
  801cb2:	56                   	push   %esi
  801cb3:	53                   	push   %ebx
  801cb4:	8b 75 0c             	mov    0xc(%ebp),%esi
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801cb7:	8d 45 14             	lea    0x14(%ebp),%eax
  801cba:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801cbe:	74 5f                	je     801d1f <execl+0x70>
{
	// We calculate argc by advancing the args until we hit NULL.
	// The contract of the function guarantees that the last
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
  801cc0:	b9 00 00 00 00       	mov    $0x0,%ecx
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
		argc++;
  801cc5:	41                   	inc    %ecx
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801cc6:	89 c2                	mov    %eax,%edx
  801cc8:	83 c0 04             	add    $0x4,%eax
  801ccb:	83 3a 00             	cmpl   $0x0,(%edx)
  801cce:	75 f5                	jne    801cc5 <execl+0x16>
		argc++;
	va_end(vl);

	// Now that we have the size of the args, do a second pass
	// and store the values in a VLA, which has the format of argv
	const char *argv[argc+2];
  801cd0:	8d 04 8d 26 00 00 00 	lea    0x26(,%ecx,4),%eax
  801cd7:	83 e0 f0             	and    $0xfffffff0,%eax
  801cda:	29 c4                	sub    %eax,%esp
  801cdc:	8d 44 24 0f          	lea    0xf(%esp),%eax
  801ce0:	83 e0 f0             	and    $0xfffffff0,%eax
  801ce3:	89 c3                	mov    %eax,%ebx
	argv[0] = arg0;
  801ce5:	89 30                	mov    %esi,(%eax)
	argv[argc+1] = NULL;
  801ce7:	c7 44 88 04 00 00 00 	movl   $0x0,0x4(%eax,%ecx,4)
  801cee:	00 

	va_start(vl, arg0);
  801cef:	8d 55 10             	lea    0x10(%ebp),%edx
	unsigned i;
	for(i=0;i<argc;i++)
  801cf2:	89 ce                	mov    %ecx,%esi
  801cf4:	85 c9                	test   %ecx,%ecx
  801cf6:	74 14                	je     801d0c <execl+0x5d>
  801cf8:	b8 00 00 00 00       	mov    $0x0,%eax
		argv[i+1] = va_arg(vl, const char *);
  801cfd:	40                   	inc    %eax
  801cfe:	89 d1                	mov    %edx,%ecx
  801d00:	83 c2 04             	add    $0x4,%edx
  801d03:	8b 09                	mov    (%ecx),%ecx
  801d05:	89 0c 83             	mov    %ecx,(%ebx,%eax,4)
	argv[0] = arg0;
	argv[argc+1] = NULL;

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  801d08:	39 f0                	cmp    %esi,%eax
  801d0a:	72 f1                	jb     801cfd <execl+0x4e>
		argv[i+1] = va_arg(vl, const char *);
	va_end(vl);
	return exec(prog, argv);
  801d0c:	83 ec 08             	sub    $0x8,%esp
  801d0f:	53                   	push   %ebx
  801d10:	ff 75 08             	pushl  0x8(%ebp)
  801d13:	e8 b9 fd ff ff       	call   801ad1 <exec>
}
  801d18:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d1b:	5b                   	pop    %ebx
  801d1c:	5e                   	pop    %esi
  801d1d:	c9                   	leave  
  801d1e:	c3                   	ret    
		argc++;
	va_end(vl);

	// Now that we have the size of the args, do a second pass
	// and store the values in a VLA, which has the format of argv
	const char *argv[argc+2];
  801d1f:	83 ec 20             	sub    $0x20,%esp
  801d22:	8d 44 24 0f          	lea    0xf(%esp),%eax
  801d26:	83 e0 f0             	and    $0xfffffff0,%eax
  801d29:	89 c3                	mov    %eax,%ebx
	argv[0] = arg0;
  801d2b:	89 30                	mov    %esi,(%eax)
	argv[argc+1] = NULL;
  801d2d:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
  801d34:	eb d6                	jmp    801d0c <execl+0x5d>

00801d36 <spawnl>:
// Spawn, taking command-line arguments array directly on the stack.
// NOTE: Must have a sentinal of NULL at the end of the args
// (none of the args may be NULL).
int
spawnl(const char *prog, const char *arg0, ...)
{
  801d36:	55                   	push   %ebp
  801d37:	89 e5                	mov    %esp,%ebp
  801d39:	56                   	push   %esi
  801d3a:	53                   	push   %ebx
  801d3b:	8b 75 0c             	mov    0xc(%ebp),%esi
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801d3e:	8d 45 14             	lea    0x14(%ebp),%eax
  801d41:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801d45:	74 5f                	je     801da6 <spawnl+0x70>
{
	// We calculate argc by advancing the args until we hit NULL.
	// The contract of the function guarantees that the last
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
  801d47:	b9 00 00 00 00       	mov    $0x0,%ecx
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
		argc++;
  801d4c:	41                   	inc    %ecx
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801d4d:	89 c2                	mov    %eax,%edx
  801d4f:	83 c0 04             	add    $0x4,%eax
  801d52:	83 3a 00             	cmpl   $0x0,(%edx)
  801d55:	75 f5                	jne    801d4c <spawnl+0x16>
		argc++;
	va_end(vl);

	// Now that we have the size of the args, do a second pass
	// and store the values in a VLA, which has the format of argv
	const char *argv[argc+2];
  801d57:	8d 04 8d 26 00 00 00 	lea    0x26(,%ecx,4),%eax
  801d5e:	83 e0 f0             	and    $0xfffffff0,%eax
  801d61:	29 c4                	sub    %eax,%esp
  801d63:	8d 44 24 0f          	lea    0xf(%esp),%eax
  801d67:	83 e0 f0             	and    $0xfffffff0,%eax
  801d6a:	89 c3                	mov    %eax,%ebx
	argv[0] = arg0;
  801d6c:	89 30                	mov    %esi,(%eax)
	argv[argc+1] = NULL;
  801d6e:	c7 44 88 04 00 00 00 	movl   $0x0,0x4(%eax,%ecx,4)
  801d75:	00 

	va_start(vl, arg0);
  801d76:	8d 55 10             	lea    0x10(%ebp),%edx
	unsigned i;
	for(i=0;i<argc;i++)
  801d79:	89 ce                	mov    %ecx,%esi
  801d7b:	85 c9                	test   %ecx,%ecx
  801d7d:	74 14                	je     801d93 <spawnl+0x5d>
  801d7f:	b8 00 00 00 00       	mov    $0x0,%eax
		argv[i+1] = va_arg(vl, const char *);
  801d84:	40                   	inc    %eax
  801d85:	89 d1                	mov    %edx,%ecx
  801d87:	83 c2 04             	add    $0x4,%edx
  801d8a:	8b 09                	mov    (%ecx),%ecx
  801d8c:	89 0c 83             	mov    %ecx,(%ebx,%eax,4)
	argv[0] = arg0;
	argv[argc+1] = NULL;

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  801d8f:	39 f0                	cmp    %esi,%eax
  801d91:	72 f1                	jb     801d84 <spawnl+0x4e>
		argv[i+1] = va_arg(vl, const char *);
	va_end(vl);
	return spawn(prog, argv);
  801d93:	83 ec 08             	sub    $0x8,%esp
  801d96:	53                   	push   %ebx
  801d97:	ff 75 08             	pushl  0x8(%ebp)
  801d9a:	e8 85 fa ff ff       	call   801824 <spawn>
}
  801d9f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801da2:	5b                   	pop    %ebx
  801da3:	5e                   	pop    %esi
  801da4:	c9                   	leave  
  801da5:	c3                   	ret    
		argc++;
	va_end(vl);

	// Now that we have the size of the args, do a second pass
	// and store the values in a VLA, which has the format of argv
	const char *argv[argc+2];
  801da6:	83 ec 20             	sub    $0x20,%esp
  801da9:	8d 44 24 0f          	lea    0xf(%esp),%eax
  801dad:	83 e0 f0             	and    $0xfffffff0,%eax
  801db0:	89 c3                	mov    %eax,%ebx
	argv[0] = arg0;
  801db2:	89 30                	mov    %esi,(%eax)
	argv[argc+1] = NULL;
  801db4:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
  801dbb:	eb d6                	jmp    801d93 <spawnl+0x5d>
  801dbd:	00 00                	add    %al,(%eax)
	...

00801dc0 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801dc0:	55                   	push   %ebp
  801dc1:	89 e5                	mov    %esp,%ebp
  801dc3:	56                   	push   %esi
  801dc4:	53                   	push   %ebx
  801dc5:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801dc8:	83 ec 0c             	sub    $0xc,%esp
  801dcb:	ff 75 08             	pushl  0x8(%ebp)
  801dce:	e8 ed ef ff ff       	call   800dc0 <fd2data>
  801dd3:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  801dd5:	83 c4 08             	add    $0x8,%esp
  801dd8:	68 a0 2b 80 00       	push   $0x802ba0
  801ddd:	56                   	push   %esi
  801dde:	e8 9f e9 ff ff       	call   800782 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801de3:	8b 43 04             	mov    0x4(%ebx),%eax
  801de6:	2b 03                	sub    (%ebx),%eax
  801de8:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  801dee:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  801df5:	00 00 00 
	stat->st_dev = &devpipe;
  801df8:	c7 86 88 00 00 00 20 	movl   $0x803020,0x88(%esi)
  801dff:	30 80 00 
	return 0;
}
  801e02:	b8 00 00 00 00       	mov    $0x0,%eax
  801e07:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e0a:	5b                   	pop    %ebx
  801e0b:	5e                   	pop    %esi
  801e0c:	c9                   	leave  
  801e0d:	c3                   	ret    

00801e0e <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801e0e:	55                   	push   %ebp
  801e0f:	89 e5                	mov    %esp,%ebp
  801e11:	53                   	push   %ebx
  801e12:	83 ec 0c             	sub    $0xc,%esp
  801e15:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801e18:	53                   	push   %ebx
  801e19:	6a 00                	push   $0x0
  801e1b:	e8 2e ee ff ff       	call   800c4e <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801e20:	89 1c 24             	mov    %ebx,(%esp)
  801e23:	e8 98 ef ff ff       	call   800dc0 <fd2data>
  801e28:	83 c4 08             	add    $0x8,%esp
  801e2b:	50                   	push   %eax
  801e2c:	6a 00                	push   $0x0
  801e2e:	e8 1b ee ff ff       	call   800c4e <sys_page_unmap>
}
  801e33:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801e36:	c9                   	leave  
  801e37:	c3                   	ret    

00801e38 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801e38:	55                   	push   %ebp
  801e39:	89 e5                	mov    %esp,%ebp
  801e3b:	57                   	push   %edi
  801e3c:	56                   	push   %esi
  801e3d:	53                   	push   %ebx
  801e3e:	83 ec 1c             	sub    $0x1c,%esp
  801e41:	89 c7                	mov    %eax,%edi
  801e43:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801e46:	a1 04 40 80 00       	mov    0x804004,%eax
  801e4b:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801e4e:	83 ec 0c             	sub    $0xc,%esp
  801e51:	57                   	push   %edi
  801e52:	e8 85 05 00 00       	call   8023dc <pageref>
  801e57:	89 c6                	mov    %eax,%esi
  801e59:	83 c4 04             	add    $0x4,%esp
  801e5c:	ff 75 e4             	pushl  -0x1c(%ebp)
  801e5f:	e8 78 05 00 00       	call   8023dc <pageref>
  801e64:	83 c4 10             	add    $0x10,%esp
  801e67:	39 c6                	cmp    %eax,%esi
  801e69:	0f 94 c0             	sete   %al
  801e6c:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  801e6f:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801e75:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801e78:	39 cb                	cmp    %ecx,%ebx
  801e7a:	75 08                	jne    801e84 <_pipeisclosed+0x4c>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  801e7c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e7f:	5b                   	pop    %ebx
  801e80:	5e                   	pop    %esi
  801e81:	5f                   	pop    %edi
  801e82:	c9                   	leave  
  801e83:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  801e84:	83 f8 01             	cmp    $0x1,%eax
  801e87:	75 bd                	jne    801e46 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801e89:	8b 42 58             	mov    0x58(%edx),%eax
  801e8c:	6a 01                	push   $0x1
  801e8e:	50                   	push   %eax
  801e8f:	53                   	push   %ebx
  801e90:	68 a7 2b 80 00       	push   $0x802ba7
  801e95:	e8 32 e3 ff ff       	call   8001cc <cprintf>
  801e9a:	83 c4 10             	add    $0x10,%esp
  801e9d:	eb a7                	jmp    801e46 <_pipeisclosed+0xe>

00801e9f <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801e9f:	55                   	push   %ebp
  801ea0:	89 e5                	mov    %esp,%ebp
  801ea2:	57                   	push   %edi
  801ea3:	56                   	push   %esi
  801ea4:	53                   	push   %ebx
  801ea5:	83 ec 28             	sub    $0x28,%esp
  801ea8:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801eab:	56                   	push   %esi
  801eac:	e8 0f ef ff ff       	call   800dc0 <fd2data>
  801eb1:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801eb3:	83 c4 10             	add    $0x10,%esp
  801eb6:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801eba:	75 4a                	jne    801f06 <devpipe_write+0x67>
  801ebc:	bf 00 00 00 00       	mov    $0x0,%edi
  801ec1:	eb 56                	jmp    801f19 <devpipe_write+0x7a>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801ec3:	89 da                	mov    %ebx,%edx
  801ec5:	89 f0                	mov    %esi,%eax
  801ec7:	e8 6c ff ff ff       	call   801e38 <_pipeisclosed>
  801ecc:	85 c0                	test   %eax,%eax
  801ece:	75 4d                	jne    801f1d <devpipe_write+0x7e>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801ed0:	e8 08 ed ff ff       	call   800bdd <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801ed5:	8b 43 04             	mov    0x4(%ebx),%eax
  801ed8:	8b 13                	mov    (%ebx),%edx
  801eda:	83 c2 20             	add    $0x20,%edx
  801edd:	39 d0                	cmp    %edx,%eax
  801edf:	73 e2                	jae    801ec3 <devpipe_write+0x24>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801ee1:	89 c2                	mov    %eax,%edx
  801ee3:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  801ee9:	79 05                	jns    801ef0 <devpipe_write+0x51>
  801eeb:	4a                   	dec    %edx
  801eec:	83 ca e0             	or     $0xffffffe0,%edx
  801eef:	42                   	inc    %edx
  801ef0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801ef3:	8a 0c 39             	mov    (%ecx,%edi,1),%cl
  801ef6:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801efa:	40                   	inc    %eax
  801efb:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801efe:	47                   	inc    %edi
  801eff:	39 7d 10             	cmp    %edi,0x10(%ebp)
  801f02:	77 07                	ja     801f0b <devpipe_write+0x6c>
  801f04:	eb 13                	jmp    801f19 <devpipe_write+0x7a>
  801f06:	bf 00 00 00 00       	mov    $0x0,%edi
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801f0b:	8b 43 04             	mov    0x4(%ebx),%eax
  801f0e:	8b 13                	mov    (%ebx),%edx
  801f10:	83 c2 20             	add    $0x20,%edx
  801f13:	39 d0                	cmp    %edx,%eax
  801f15:	73 ac                	jae    801ec3 <devpipe_write+0x24>
  801f17:	eb c8                	jmp    801ee1 <devpipe_write+0x42>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801f19:	89 f8                	mov    %edi,%eax
  801f1b:	eb 05                	jmp    801f22 <devpipe_write+0x83>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801f1d:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801f22:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f25:	5b                   	pop    %ebx
  801f26:	5e                   	pop    %esi
  801f27:	5f                   	pop    %edi
  801f28:	c9                   	leave  
  801f29:	c3                   	ret    

00801f2a <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801f2a:	55                   	push   %ebp
  801f2b:	89 e5                	mov    %esp,%ebp
  801f2d:	57                   	push   %edi
  801f2e:	56                   	push   %esi
  801f2f:	53                   	push   %ebx
  801f30:	83 ec 18             	sub    $0x18,%esp
  801f33:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801f36:	57                   	push   %edi
  801f37:	e8 84 ee ff ff       	call   800dc0 <fd2data>
  801f3c:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801f3e:	83 c4 10             	add    $0x10,%esp
  801f41:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801f45:	75 44                	jne    801f8b <devpipe_read+0x61>
  801f47:	be 00 00 00 00       	mov    $0x0,%esi
  801f4c:	eb 4f                	jmp    801f9d <devpipe_read+0x73>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
				return i;
  801f4e:	89 f0                	mov    %esi,%eax
  801f50:	eb 54                	jmp    801fa6 <devpipe_read+0x7c>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801f52:	89 da                	mov    %ebx,%edx
  801f54:	89 f8                	mov    %edi,%eax
  801f56:	e8 dd fe ff ff       	call   801e38 <_pipeisclosed>
  801f5b:	85 c0                	test   %eax,%eax
  801f5d:	75 42                	jne    801fa1 <devpipe_read+0x77>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801f5f:	e8 79 ec ff ff       	call   800bdd <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801f64:	8b 03                	mov    (%ebx),%eax
  801f66:	3b 43 04             	cmp    0x4(%ebx),%eax
  801f69:	74 e7                	je     801f52 <devpipe_read+0x28>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801f6b:	25 1f 00 00 80       	and    $0x8000001f,%eax
  801f70:	79 05                	jns    801f77 <devpipe_read+0x4d>
  801f72:	48                   	dec    %eax
  801f73:	83 c8 e0             	or     $0xffffffe0,%eax
  801f76:	40                   	inc    %eax
  801f77:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  801f7b:	8b 55 0c             	mov    0xc(%ebp),%edx
  801f7e:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  801f81:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801f83:	46                   	inc    %esi
  801f84:	39 75 10             	cmp    %esi,0x10(%ebp)
  801f87:	77 07                	ja     801f90 <devpipe_read+0x66>
  801f89:	eb 12                	jmp    801f9d <devpipe_read+0x73>
  801f8b:	be 00 00 00 00       	mov    $0x0,%esi
		while (p->p_rpos == p->p_wpos) {
  801f90:	8b 03                	mov    (%ebx),%eax
  801f92:	3b 43 04             	cmp    0x4(%ebx),%eax
  801f95:	75 d4                	jne    801f6b <devpipe_read+0x41>
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801f97:	85 f6                	test   %esi,%esi
  801f99:	75 b3                	jne    801f4e <devpipe_read+0x24>
  801f9b:	eb b5                	jmp    801f52 <devpipe_read+0x28>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801f9d:	89 f0                	mov    %esi,%eax
  801f9f:	eb 05                	jmp    801fa6 <devpipe_read+0x7c>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801fa1:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801fa6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801fa9:	5b                   	pop    %ebx
  801faa:	5e                   	pop    %esi
  801fab:	5f                   	pop    %edi
  801fac:	c9                   	leave  
  801fad:	c3                   	ret    

00801fae <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801fae:	55                   	push   %ebp
  801faf:	89 e5                	mov    %esp,%ebp
  801fb1:	57                   	push   %edi
  801fb2:	56                   	push   %esi
  801fb3:	53                   	push   %ebx
  801fb4:	83 ec 28             	sub    $0x28,%esp
  801fb7:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801fba:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801fbd:	50                   	push   %eax
  801fbe:	e8 15 ee ff ff       	call   800dd8 <fd_alloc>
  801fc3:	89 c3                	mov    %eax,%ebx
  801fc5:	83 c4 10             	add    $0x10,%esp
  801fc8:	85 c0                	test   %eax,%eax
  801fca:	0f 88 24 01 00 00    	js     8020f4 <pipe+0x146>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801fd0:	83 ec 04             	sub    $0x4,%esp
  801fd3:	68 07 04 00 00       	push   $0x407
  801fd8:	ff 75 e4             	pushl  -0x1c(%ebp)
  801fdb:	6a 00                	push   $0x0
  801fdd:	e8 22 ec ff ff       	call   800c04 <sys_page_alloc>
  801fe2:	89 c3                	mov    %eax,%ebx
  801fe4:	83 c4 10             	add    $0x10,%esp
  801fe7:	85 c0                	test   %eax,%eax
  801fe9:	0f 88 05 01 00 00    	js     8020f4 <pipe+0x146>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801fef:	83 ec 0c             	sub    $0xc,%esp
  801ff2:	8d 45 e0             	lea    -0x20(%ebp),%eax
  801ff5:	50                   	push   %eax
  801ff6:	e8 dd ed ff ff       	call   800dd8 <fd_alloc>
  801ffb:	89 c3                	mov    %eax,%ebx
  801ffd:	83 c4 10             	add    $0x10,%esp
  802000:	85 c0                	test   %eax,%eax
  802002:	0f 88 dc 00 00 00    	js     8020e4 <pipe+0x136>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802008:	83 ec 04             	sub    $0x4,%esp
  80200b:	68 07 04 00 00       	push   $0x407
  802010:	ff 75 e0             	pushl  -0x20(%ebp)
  802013:	6a 00                	push   $0x0
  802015:	e8 ea eb ff ff       	call   800c04 <sys_page_alloc>
  80201a:	89 c3                	mov    %eax,%ebx
  80201c:	83 c4 10             	add    $0x10,%esp
  80201f:	85 c0                	test   %eax,%eax
  802021:	0f 88 bd 00 00 00    	js     8020e4 <pipe+0x136>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  802027:	83 ec 0c             	sub    $0xc,%esp
  80202a:	ff 75 e4             	pushl  -0x1c(%ebp)
  80202d:	e8 8e ed ff ff       	call   800dc0 <fd2data>
  802032:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802034:	83 c4 0c             	add    $0xc,%esp
  802037:	68 07 04 00 00       	push   $0x407
  80203c:	50                   	push   %eax
  80203d:	6a 00                	push   $0x0
  80203f:	e8 c0 eb ff ff       	call   800c04 <sys_page_alloc>
  802044:	89 c3                	mov    %eax,%ebx
  802046:	83 c4 10             	add    $0x10,%esp
  802049:	85 c0                	test   %eax,%eax
  80204b:	0f 88 83 00 00 00    	js     8020d4 <pipe+0x126>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802051:	83 ec 0c             	sub    $0xc,%esp
  802054:	ff 75 e0             	pushl  -0x20(%ebp)
  802057:	e8 64 ed ff ff       	call   800dc0 <fd2data>
  80205c:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  802063:	50                   	push   %eax
  802064:	6a 00                	push   $0x0
  802066:	56                   	push   %esi
  802067:	6a 00                	push   $0x0
  802069:	e8 ba eb ff ff       	call   800c28 <sys_page_map>
  80206e:	89 c3                	mov    %eax,%ebx
  802070:	83 c4 20             	add    $0x20,%esp
  802073:	85 c0                	test   %eax,%eax
  802075:	78 4f                	js     8020c6 <pipe+0x118>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  802077:	8b 15 20 30 80 00    	mov    0x803020,%edx
  80207d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802080:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  802082:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802085:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  80208c:	8b 15 20 30 80 00    	mov    0x803020,%edx
  802092:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802095:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  802097:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80209a:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  8020a1:	83 ec 0c             	sub    $0xc,%esp
  8020a4:	ff 75 e4             	pushl  -0x1c(%ebp)
  8020a7:	e8 04 ed ff ff       	call   800db0 <fd2num>
  8020ac:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  8020ae:	83 c4 04             	add    $0x4,%esp
  8020b1:	ff 75 e0             	pushl  -0x20(%ebp)
  8020b4:	e8 f7 ec ff ff       	call   800db0 <fd2num>
  8020b9:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  8020bc:	83 c4 10             	add    $0x10,%esp
  8020bf:	bb 00 00 00 00       	mov    $0x0,%ebx
  8020c4:	eb 2e                	jmp    8020f4 <pipe+0x146>

    err3:
	sys_page_unmap(0, va);
  8020c6:	83 ec 08             	sub    $0x8,%esp
  8020c9:	56                   	push   %esi
  8020ca:	6a 00                	push   $0x0
  8020cc:	e8 7d eb ff ff       	call   800c4e <sys_page_unmap>
  8020d1:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  8020d4:	83 ec 08             	sub    $0x8,%esp
  8020d7:	ff 75 e0             	pushl  -0x20(%ebp)
  8020da:	6a 00                	push   $0x0
  8020dc:	e8 6d eb ff ff       	call   800c4e <sys_page_unmap>
  8020e1:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  8020e4:	83 ec 08             	sub    $0x8,%esp
  8020e7:	ff 75 e4             	pushl  -0x1c(%ebp)
  8020ea:	6a 00                	push   $0x0
  8020ec:	e8 5d eb ff ff       	call   800c4e <sys_page_unmap>
  8020f1:	83 c4 10             	add    $0x10,%esp
    err:
	return r;
}
  8020f4:	89 d8                	mov    %ebx,%eax
  8020f6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8020f9:	5b                   	pop    %ebx
  8020fa:	5e                   	pop    %esi
  8020fb:	5f                   	pop    %edi
  8020fc:	c9                   	leave  
  8020fd:	c3                   	ret    

008020fe <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  8020fe:	55                   	push   %ebp
  8020ff:	89 e5                	mov    %esp,%ebp
  802101:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802104:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802107:	50                   	push   %eax
  802108:	ff 75 08             	pushl  0x8(%ebp)
  80210b:	e8 3b ed ff ff       	call   800e4b <fd_lookup>
  802110:	83 c4 10             	add    $0x10,%esp
  802113:	85 c0                	test   %eax,%eax
  802115:	78 18                	js     80212f <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  802117:	83 ec 0c             	sub    $0xc,%esp
  80211a:	ff 75 f4             	pushl  -0xc(%ebp)
  80211d:	e8 9e ec ff ff       	call   800dc0 <fd2data>
	return _pipeisclosed(fd, p);
  802122:	89 c2                	mov    %eax,%edx
  802124:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802127:	e8 0c fd ff ff       	call   801e38 <_pipeisclosed>
  80212c:	83 c4 10             	add    $0x10,%esp
}
  80212f:	c9                   	leave  
  802130:	c3                   	ret    
  802131:	00 00                	add    %al,(%eax)
	...

00802134 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  802134:	55                   	push   %ebp
  802135:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  802137:	b8 00 00 00 00       	mov    $0x0,%eax
  80213c:	c9                   	leave  
  80213d:	c3                   	ret    

0080213e <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80213e:	55                   	push   %ebp
  80213f:	89 e5                	mov    %esp,%ebp
  802141:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  802144:	68 bf 2b 80 00       	push   $0x802bbf
  802149:	ff 75 0c             	pushl  0xc(%ebp)
  80214c:	e8 31 e6 ff ff       	call   800782 <strcpy>
	return 0;
}
  802151:	b8 00 00 00 00       	mov    $0x0,%eax
  802156:	c9                   	leave  
  802157:	c3                   	ret    

00802158 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  802158:	55                   	push   %ebp
  802159:	89 e5                	mov    %esp,%ebp
  80215b:	57                   	push   %edi
  80215c:	56                   	push   %esi
  80215d:	53                   	push   %ebx
  80215e:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802164:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  802168:	74 45                	je     8021af <devcons_write+0x57>
  80216a:	b8 00 00 00 00       	mov    $0x0,%eax
  80216f:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  802174:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  80217a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80217d:	29 c3                	sub    %eax,%ebx
		if (m > sizeof(buf) - 1)
  80217f:	83 fb 7f             	cmp    $0x7f,%ebx
  802182:	76 05                	jbe    802189 <devcons_write+0x31>
			m = sizeof(buf) - 1;
  802184:	bb 7f 00 00 00       	mov    $0x7f,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  802189:	83 ec 04             	sub    $0x4,%esp
  80218c:	53                   	push   %ebx
  80218d:	03 45 0c             	add    0xc(%ebp),%eax
  802190:	50                   	push   %eax
  802191:	57                   	push   %edi
  802192:	e8 ac e7 ff ff       	call   800943 <memmove>
		sys_cputs(buf, m);
  802197:	83 c4 08             	add    $0x8,%esp
  80219a:	53                   	push   %ebx
  80219b:	57                   	push   %edi
  80219c:	e8 ac e9 ff ff       	call   800b4d <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8021a1:	01 de                	add    %ebx,%esi
  8021a3:	89 f0                	mov    %esi,%eax
  8021a5:	83 c4 10             	add    $0x10,%esp
  8021a8:	3b 75 10             	cmp    0x10(%ebp),%esi
  8021ab:	72 cd                	jb     80217a <devcons_write+0x22>
  8021ad:	eb 05                	jmp    8021b4 <devcons_write+0x5c>
  8021af:	be 00 00 00 00       	mov    $0x0,%esi
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8021b4:	89 f0                	mov    %esi,%eax
  8021b6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8021b9:	5b                   	pop    %ebx
  8021ba:	5e                   	pop    %esi
  8021bb:	5f                   	pop    %edi
  8021bc:	c9                   	leave  
  8021bd:	c3                   	ret    

008021be <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8021be:	55                   	push   %ebp
  8021bf:	89 e5                	mov    %esp,%ebp
  8021c1:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  8021c4:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8021c8:	75 07                	jne    8021d1 <devcons_read+0x13>
  8021ca:	eb 25                	jmp    8021f1 <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8021cc:	e8 0c ea ff ff       	call   800bdd <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8021d1:	e8 9d e9 ff ff       	call   800b73 <sys_cgetc>
  8021d6:	85 c0                	test   %eax,%eax
  8021d8:	74 f2                	je     8021cc <devcons_read+0xe>
  8021da:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  8021dc:	85 c0                	test   %eax,%eax
  8021de:	78 1d                	js     8021fd <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8021e0:	83 f8 04             	cmp    $0x4,%eax
  8021e3:	74 13                	je     8021f8 <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  8021e5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8021e8:	88 10                	mov    %dl,(%eax)
	return 1;
  8021ea:	b8 01 00 00 00       	mov    $0x1,%eax
  8021ef:	eb 0c                	jmp    8021fd <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  8021f1:	b8 00 00 00 00       	mov    $0x0,%eax
  8021f6:	eb 05                	jmp    8021fd <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8021f8:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8021fd:	c9                   	leave  
  8021fe:	c3                   	ret    

008021ff <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  8021ff:	55                   	push   %ebp
  802200:	89 e5                	mov    %esp,%ebp
  802202:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  802205:	8b 45 08             	mov    0x8(%ebp),%eax
  802208:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  80220b:	6a 01                	push   $0x1
  80220d:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802210:	50                   	push   %eax
  802211:	e8 37 e9 ff ff       	call   800b4d <sys_cputs>
  802216:	83 c4 10             	add    $0x10,%esp
}
  802219:	c9                   	leave  
  80221a:	c3                   	ret    

0080221b <getchar>:

int
getchar(void)
{
  80221b:	55                   	push   %ebp
  80221c:	89 e5                	mov    %esp,%ebp
  80221e:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  802221:	6a 01                	push   $0x1
  802223:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802226:	50                   	push   %eax
  802227:	6a 00                	push   $0x0
  802229:	e8 9e ee ff ff       	call   8010cc <read>
	if (r < 0)
  80222e:	83 c4 10             	add    $0x10,%esp
  802231:	85 c0                	test   %eax,%eax
  802233:	78 0f                	js     802244 <getchar+0x29>
		return r;
	if (r < 1)
  802235:	85 c0                	test   %eax,%eax
  802237:	7e 06                	jle    80223f <getchar+0x24>
		return -E_EOF;
	return c;
  802239:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  80223d:	eb 05                	jmp    802244 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  80223f:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  802244:	c9                   	leave  
  802245:	c3                   	ret    

00802246 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  802246:	55                   	push   %ebp
  802247:	89 e5                	mov    %esp,%ebp
  802249:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80224c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80224f:	50                   	push   %eax
  802250:	ff 75 08             	pushl  0x8(%ebp)
  802253:	e8 f3 eb ff ff       	call   800e4b <fd_lookup>
  802258:	83 c4 10             	add    $0x10,%esp
  80225b:	85 c0                	test   %eax,%eax
  80225d:	78 11                	js     802270 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  80225f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802262:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  802268:	39 10                	cmp    %edx,(%eax)
  80226a:	0f 94 c0             	sete   %al
  80226d:	0f b6 c0             	movzbl %al,%eax
}
  802270:	c9                   	leave  
  802271:	c3                   	ret    

00802272 <opencons>:

int
opencons(void)
{
  802272:	55                   	push   %ebp
  802273:	89 e5                	mov    %esp,%ebp
  802275:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802278:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80227b:	50                   	push   %eax
  80227c:	e8 57 eb ff ff       	call   800dd8 <fd_alloc>
  802281:	83 c4 10             	add    $0x10,%esp
  802284:	85 c0                	test   %eax,%eax
  802286:	78 3a                	js     8022c2 <opencons+0x50>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802288:	83 ec 04             	sub    $0x4,%esp
  80228b:	68 07 04 00 00       	push   $0x407
  802290:	ff 75 f4             	pushl  -0xc(%ebp)
  802293:	6a 00                	push   $0x0
  802295:	e8 6a e9 ff ff       	call   800c04 <sys_page_alloc>
  80229a:	83 c4 10             	add    $0x10,%esp
  80229d:	85 c0                	test   %eax,%eax
  80229f:	78 21                	js     8022c2 <opencons+0x50>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8022a1:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8022a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8022aa:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8022ac:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8022af:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8022b6:	83 ec 0c             	sub    $0xc,%esp
  8022b9:	50                   	push   %eax
  8022ba:	e8 f1 ea ff ff       	call   800db0 <fd2num>
  8022bf:	83 c4 10             	add    $0x10,%esp
}
  8022c2:	c9                   	leave  
  8022c3:	c3                   	ret    

008022c4 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8022c4:	55                   	push   %ebp
  8022c5:	89 e5                	mov    %esp,%ebp
  8022c7:	56                   	push   %esi
  8022c8:	53                   	push   %ebx
  8022c9:	8b 75 08             	mov    0x8(%ebp),%esi
  8022cc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8022cf:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// cprintf("0x%x 0x%x 0x%x\n", (uint32_t)from_env_store, (uint32_t)pg, (uint32_t)perm_store);
	int r;
	if (pg != NULL) {
  8022d2:	85 c0                	test   %eax,%eax
  8022d4:	74 0e                	je     8022e4 <ipc_recv+0x20>
		r = sys_ipc_recv(pg);
  8022d6:	83 ec 0c             	sub    $0xc,%esp
  8022d9:	50                   	push   %eax
  8022da:	e8 20 ea ff ff       	call   800cff <sys_ipc_recv>
  8022df:	83 c4 10             	add    $0x10,%esp
  8022e2:	eb 10                	jmp    8022f4 <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv((void *)UTOP);
  8022e4:	83 ec 0c             	sub    $0xc,%esp
  8022e7:	68 00 00 c0 ee       	push   $0xeec00000
  8022ec:	e8 0e ea ff ff       	call   800cff <sys_ipc_recv>
  8022f1:	83 c4 10             	add    $0x10,%esp
	}

	if (r == 0) {
  8022f4:	85 c0                	test   %eax,%eax
  8022f6:	75 26                	jne    80231e <ipc_recv+0x5a>
		if (from_env_store != NULL) *from_env_store = thisenv->env_ipc_from;
  8022f8:	85 f6                	test   %esi,%esi
  8022fa:	74 0a                	je     802306 <ipc_recv+0x42>
  8022fc:	a1 04 40 80 00       	mov    0x804004,%eax
  802301:	8b 40 74             	mov    0x74(%eax),%eax
  802304:	89 06                	mov    %eax,(%esi)
		if (perm_store != NULL) *perm_store = thisenv->env_ipc_perm;
  802306:	85 db                	test   %ebx,%ebx
  802308:	74 0a                	je     802314 <ipc_recv+0x50>
  80230a:	a1 04 40 80 00       	mov    0x804004,%eax
  80230f:	8b 40 78             	mov    0x78(%eax),%eax
  802312:	89 03                	mov    %eax,(%ebx)
		return thisenv->env_ipc_value;
  802314:	a1 04 40 80 00       	mov    0x804004,%eax
  802319:	8b 40 70             	mov    0x70(%eax),%eax
  80231c:	eb 14                	jmp    802332 <ipc_recv+0x6e>
	} else {
		// fails;
		if (from_env_store != NULL) *from_env_store = 0;
  80231e:	85 f6                	test   %esi,%esi
  802320:	74 06                	je     802328 <ipc_recv+0x64>
  802322:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if (perm_store != NULL) *perm_store = 0;
  802328:	85 db                	test   %ebx,%ebx
  80232a:	74 06                	je     802332 <ipc_recv+0x6e>
  80232c:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		return r;
	}
}
  802332:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802335:	5b                   	pop    %ebx
  802336:	5e                   	pop    %esi
  802337:	c9                   	leave  
  802338:	c3                   	ret    

00802339 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802339:	55                   	push   %ebp
  80233a:	89 e5                	mov    %esp,%ebp
  80233c:	57                   	push   %edi
  80233d:	56                   	push   %esi
  80233e:	53                   	push   %ebx
  80233f:	83 ec 0c             	sub    $0xc,%esp
  802342:	8b 7d 0c             	mov    0xc(%ebp),%edi
  802345:	8b 5d 10             	mov    0x10(%ebp),%ebx
  802348:	8b 75 14             	mov    0x14(%ebp),%esi
	// LAB 4: Your code here.
	// int sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
	int r;
	if (pg == NULL) pg = (void *)UTOP;
  80234b:	85 db                	test   %ebx,%ebx
  80234d:	75 25                	jne    802374 <ipc_send+0x3b>
  80234f:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
  802354:	eb 1e                	jmp    802374 <ipc_send+0x3b>
	
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) != 0) {
		if (r == -E_IPC_NOT_RECV) {
  802356:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802359:	75 07                	jne    802362 <ipc_send+0x29>
			// cprintf("Try Again and Again....\n");
			sys_yield();
  80235b:	e8 7d e8 ff ff       	call   800bdd <sys_yield>
  802360:	eb 12                	jmp    802374 <ipc_send+0x3b>
		} else {
			panic("ipc_send error %e\n", r);
  802362:	50                   	push   %eax
  802363:	68 cb 2b 80 00       	push   $0x802bcb
  802368:	6a 43                	push   $0x43
  80236a:	68 de 2b 80 00       	push   $0x802bde
  80236f:	e8 80 dd ff ff       	call   8000f4 <_panic>
	// LAB 4: Your code here.
	// int sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
	int r;
	if (pg == NULL) pg = (void *)UTOP;
	
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) != 0) {
  802374:	56                   	push   %esi
  802375:	53                   	push   %ebx
  802376:	57                   	push   %edi
  802377:	ff 75 08             	pushl  0x8(%ebp)
  80237a:	e8 5b e9 ff ff       	call   800cda <sys_ipc_try_send>
  80237f:	83 c4 10             	add    $0x10,%esp
  802382:	85 c0                	test   %eax,%eax
  802384:	75 d0                	jne    802356 <ipc_send+0x1d>
		} else {
			panic("ipc_send error %e\n", r);
		}
	}
	return;
}
  802386:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802389:	5b                   	pop    %ebx
  80238a:	5e                   	pop    %esi
  80238b:	5f                   	pop    %edi
  80238c:	c9                   	leave  
  80238d:	c3                   	ret    

0080238e <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80238e:	55                   	push   %ebp
  80238f:	89 e5                	mov    %esp,%ebp
  802391:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  802394:	39 0d 50 00 c0 ee    	cmp    %ecx,0xeec00050
  80239a:	74 1a                	je     8023b6 <ipc_find_env+0x28>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80239c:	b8 01 00 00 00       	mov    $0x1,%eax
		if (envs[i].env_type == type)
  8023a1:	89 c2                	mov    %eax,%edx
  8023a3:	c1 e2 07             	shl    $0x7,%edx
  8023a6:	8d 94 82 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,4),%edx
  8023ad:	8b 52 50             	mov    0x50(%edx),%edx
  8023b0:	39 ca                	cmp    %ecx,%edx
  8023b2:	75 18                	jne    8023cc <ipc_find_env+0x3e>
  8023b4:	eb 05                	jmp    8023bb <ipc_find_env+0x2d>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8023b6:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
			return envs[i].env_id;
  8023bb:	89 c2                	mov    %eax,%edx
  8023bd:	c1 e2 07             	shl    $0x7,%edx
  8023c0:	8d 84 82 08 00 c0 ee 	lea    -0x113ffff8(%edx,%eax,4),%eax
  8023c7:	8b 40 40             	mov    0x40(%eax),%eax
  8023ca:	eb 0c                	jmp    8023d8 <ipc_find_env+0x4a>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8023cc:	40                   	inc    %eax
  8023cd:	3d 00 04 00 00       	cmp    $0x400,%eax
  8023d2:	75 cd                	jne    8023a1 <ipc_find_env+0x13>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8023d4:	66 b8 00 00          	mov    $0x0,%ax
}
  8023d8:	c9                   	leave  
  8023d9:	c3                   	ret    
	...

008023dc <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8023dc:	55                   	push   %ebp
  8023dd:	89 e5                	mov    %esp,%ebp
  8023df:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8023e2:	89 c2                	mov    %eax,%edx
  8023e4:	c1 ea 16             	shr    $0x16,%edx
  8023e7:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8023ee:	f6 c2 01             	test   $0x1,%dl
  8023f1:	74 1e                	je     802411 <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  8023f3:	c1 e8 0c             	shr    $0xc,%eax
  8023f6:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  8023fd:	a8 01                	test   $0x1,%al
  8023ff:	74 17                	je     802418 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802401:	c1 e8 0c             	shr    $0xc,%eax
  802404:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  80240b:	ef 
  80240c:	0f b7 c0             	movzwl %ax,%eax
  80240f:	eb 0c                	jmp    80241d <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  802411:	b8 00 00 00 00       	mov    $0x0,%eax
  802416:	eb 05                	jmp    80241d <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  802418:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  80241d:	c9                   	leave  
  80241e:	c3                   	ret    
	...

00802420 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  802420:	55                   	push   %ebp
  802421:	89 e5                	mov    %esp,%ebp
  802423:	57                   	push   %edi
  802424:	56                   	push   %esi
  802425:	83 ec 10             	sub    $0x10,%esp
  802428:	8b 7d 08             	mov    0x8(%ebp),%edi
  80242b:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  80242e:	89 7d f0             	mov    %edi,-0x10(%ebp)
  802431:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  802434:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  802437:	8b 45 14             	mov    0x14(%ebp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  80243a:	85 c0                	test   %eax,%eax
  80243c:	75 2e                	jne    80246c <__udivdi3+0x4c>
    {
      if (d0 > n1)
  80243e:	39 f1                	cmp    %esi,%ecx
  802440:	77 5a                	ja     80249c <__udivdi3+0x7c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  802442:	85 c9                	test   %ecx,%ecx
  802444:	75 0b                	jne    802451 <__udivdi3+0x31>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  802446:	b8 01 00 00 00       	mov    $0x1,%eax
  80244b:	31 d2                	xor    %edx,%edx
  80244d:	f7 f1                	div    %ecx
  80244f:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  802451:	31 d2                	xor    %edx,%edx
  802453:	89 f0                	mov    %esi,%eax
  802455:	f7 f1                	div    %ecx
  802457:	89 c6                	mov    %eax,%esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802459:	89 f8                	mov    %edi,%eax
  80245b:	f7 f1                	div    %ecx
  80245d:	89 c7                	mov    %eax,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  80245f:	89 f8                	mov    %edi,%eax
  802461:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802463:	83 c4 10             	add    $0x10,%esp
  802466:	5e                   	pop    %esi
  802467:	5f                   	pop    %edi
  802468:	c9                   	leave  
  802469:	c3                   	ret    
  80246a:	66 90                	xchg   %ax,%ax
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  80246c:	39 f0                	cmp    %esi,%eax
  80246e:	77 1c                	ja     80248c <__udivdi3+0x6c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  802470:	0f bd f8             	bsr    %eax,%edi
	  if (bm == 0)
  802473:	83 f7 1f             	xor    $0x1f,%edi
  802476:	75 3c                	jne    8024b4 <__udivdi3+0x94>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802478:	39 f0                	cmp    %esi,%eax
  80247a:	0f 82 90 00 00 00    	jb     802510 <__udivdi3+0xf0>
  802480:	8b 55 f0             	mov    -0x10(%ebp),%edx
  802483:	39 55 f4             	cmp    %edx,-0xc(%ebp)
  802486:	0f 86 84 00 00 00    	jbe    802510 <__udivdi3+0xf0>
  80248c:	31 f6                	xor    %esi,%esi
  80248e:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  802490:	89 f8                	mov    %edi,%eax
  802492:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802494:	83 c4 10             	add    $0x10,%esp
  802497:	5e                   	pop    %esi
  802498:	5f                   	pop    %edi
  802499:	c9                   	leave  
  80249a:	c3                   	ret    
  80249b:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  80249c:	89 f2                	mov    %esi,%edx
  80249e:	89 f8                	mov    %edi,%eax
  8024a0:	f7 f1                	div    %ecx
  8024a2:	89 c7                	mov    %eax,%edi
  8024a4:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  8024a6:	89 f8                	mov    %edi,%eax
  8024a8:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  8024aa:	83 c4 10             	add    $0x10,%esp
  8024ad:	5e                   	pop    %esi
  8024ae:	5f                   	pop    %edi
  8024af:	c9                   	leave  
  8024b0:	c3                   	ret    
  8024b1:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  8024b4:	89 f9                	mov    %edi,%ecx
  8024b6:	d3 e0                	shl    %cl,%eax
  8024b8:	89 45 e8             	mov    %eax,-0x18(%ebp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  8024bb:	b8 20 00 00 00       	mov    $0x20,%eax
  8024c0:	29 f8                	sub    %edi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  8024c2:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8024c5:	88 c1                	mov    %al,%cl
  8024c7:	d3 ea                	shr    %cl,%edx
  8024c9:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  8024cc:	09 ca                	or     %ecx,%edx
  8024ce:	89 55 ec             	mov    %edx,-0x14(%ebp)
	      d0 = d0 << bm;
  8024d1:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8024d4:	89 f9                	mov    %edi,%ecx
  8024d6:	d3 e2                	shl    %cl,%edx
  8024d8:	89 55 f4             	mov    %edx,-0xc(%ebp)
	      n2 = n1 >> b;
  8024db:	89 f2                	mov    %esi,%edx
  8024dd:	88 c1                	mov    %al,%cl
  8024df:	d3 ea                	shr    %cl,%edx
  8024e1:	89 55 e8             	mov    %edx,-0x18(%ebp)
	      n1 = (n1 << bm) | (n0 >> b);
  8024e4:	89 f2                	mov    %esi,%edx
  8024e6:	89 f9                	mov    %edi,%ecx
  8024e8:	d3 e2                	shl    %cl,%edx
  8024ea:	8b 75 f0             	mov    -0x10(%ebp),%esi
  8024ed:	88 c1                	mov    %al,%cl
  8024ef:	d3 ee                	shr    %cl,%esi
  8024f1:	09 d6                	or     %edx,%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  8024f3:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  8024f6:	89 f0                	mov    %esi,%eax
  8024f8:	89 ca                	mov    %ecx,%edx
  8024fa:	f7 75 ec             	divl   -0x14(%ebp)
  8024fd:	89 d1                	mov    %edx,%ecx
  8024ff:	89 c6                	mov    %eax,%esi
	      umul_ppmm (m1, m0, q0, d0);
  802501:	f7 65 f4             	mull   -0xc(%ebp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802504:	39 d1                	cmp    %edx,%ecx
  802506:	72 28                	jb     802530 <__udivdi3+0x110>
  802508:	74 1a                	je     802524 <__udivdi3+0x104>
  80250a:	89 f7                	mov    %esi,%edi
  80250c:	31 f6                	xor    %esi,%esi
  80250e:	eb 80                	jmp    802490 <__udivdi3+0x70>
	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  802510:	31 f6                	xor    %esi,%esi
  802512:	bf 01 00 00 00       	mov    $0x1,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  802517:	89 f8                	mov    %edi,%eax
  802519:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  80251b:	83 c4 10             	add    $0x10,%esp
  80251e:	5e                   	pop    %esi
  80251f:	5f                   	pop    %edi
  802520:	c9                   	leave  
  802521:	c3                   	ret    
  802522:	66 90                	xchg   %ax,%ax

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  802524:	8b 55 f0             	mov    -0x10(%ebp),%edx
  802527:	89 f9                	mov    %edi,%ecx
  802529:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  80252b:	39 c2                	cmp    %eax,%edx
  80252d:	73 db                	jae    80250a <__udivdi3+0xea>
  80252f:	90                   	nop
		{
		  q0--;
  802530:	8d 7e ff             	lea    -0x1(%esi),%edi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  802533:	31 f6                	xor    %esi,%esi
  802535:	e9 56 ff ff ff       	jmp    802490 <__udivdi3+0x70>
	...

0080253c <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  80253c:	55                   	push   %ebp
  80253d:	89 e5                	mov    %esp,%ebp
  80253f:	57                   	push   %edi
  802540:	56                   	push   %esi
  802541:	83 ec 20             	sub    $0x20,%esp
  802544:	8b 45 08             	mov    0x8(%ebp),%eax
  802547:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  80254a:	89 45 e8             	mov    %eax,-0x18(%ebp)
  80254d:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  802550:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  802553:	8b 7d 14             	mov    0x14(%ebp),%edi
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  802556:	89 45 f0             	mov    %eax,-0x10(%ebp)
  n1 = nn.s.high;
  802559:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  80255b:	85 ff                	test   %edi,%edi
  80255d:	75 15                	jne    802574 <__umoddi3+0x38>
    {
      if (d0 > n1)
  80255f:	39 f1                	cmp    %esi,%ecx
  802561:	0f 86 99 00 00 00    	jbe    802600 <__umoddi3+0xc4>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802567:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  802569:	89 d0                	mov    %edx,%eax
  80256b:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  80256d:	83 c4 20             	add    $0x20,%esp
  802570:	5e                   	pop    %esi
  802571:	5f                   	pop    %edi
  802572:	c9                   	leave  
  802573:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  802574:	39 f7                	cmp    %esi,%edi
  802576:	0f 87 a4 00 00 00    	ja     802620 <__umoddi3+0xe4>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  80257c:	0f bd c7             	bsr    %edi,%eax
	  if (bm == 0)
  80257f:	83 f0 1f             	xor    $0x1f,%eax
  802582:	89 45 ec             	mov    %eax,-0x14(%ebp)
  802585:	0f 84 a1 00 00 00    	je     80262c <__umoddi3+0xf0>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  80258b:	89 f8                	mov    %edi,%eax
  80258d:	8a 4d ec             	mov    -0x14(%ebp),%cl
  802590:	d3 e0                	shl    %cl,%eax
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  802592:	bf 20 00 00 00       	mov    $0x20,%edi
  802597:	2b 7d ec             	sub    -0x14(%ebp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  80259a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80259d:	89 f9                	mov    %edi,%ecx
  80259f:	d3 ea                	shr    %cl,%edx
  8025a1:	09 c2                	or     %eax,%edx
  8025a3:	89 55 f0             	mov    %edx,-0x10(%ebp)
	      d0 = d0 << bm;
  8025a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8025a9:	8a 4d ec             	mov    -0x14(%ebp),%cl
  8025ac:	d3 e0                	shl    %cl,%eax
  8025ae:	89 45 f4             	mov    %eax,-0xc(%ebp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  8025b1:	89 f2                	mov    %esi,%edx
  8025b3:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  8025b5:	8b 45 e8             	mov    -0x18(%ebp),%eax
  8025b8:	d3 e0                	shl    %cl,%eax
  8025ba:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  8025bd:	8b 45 e8             	mov    -0x18(%ebp),%eax
  8025c0:	89 f9                	mov    %edi,%ecx
  8025c2:	d3 e8                	shr    %cl,%eax
  8025c4:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  8025c6:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  8025c8:	89 f2                	mov    %esi,%edx
  8025ca:	f7 75 f0             	divl   -0x10(%ebp)
  8025cd:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  8025cf:	f7 65 f4             	mull   -0xc(%ebp)
  8025d2:	89 55 e8             	mov    %edx,-0x18(%ebp)
  8025d5:	89 c1                	mov    %eax,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8025d7:	39 d6                	cmp    %edx,%esi
  8025d9:	72 71                	jb     80264c <__umoddi3+0x110>
  8025db:	74 7f                	je     80265c <__umoddi3+0x120>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  8025dd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8025e0:	29 c8                	sub    %ecx,%eax
  8025e2:	19 d6                	sbb    %edx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  8025e4:	8a 4d ec             	mov    -0x14(%ebp),%cl
  8025e7:	d3 e8                	shr    %cl,%eax
  8025e9:	89 f2                	mov    %esi,%edx
  8025eb:	89 f9                	mov    %edi,%ecx
  8025ed:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  8025ef:	09 d0                	or     %edx,%eax
  8025f1:	89 f2                	mov    %esi,%edx
  8025f3:	8a 4d ec             	mov    -0x14(%ebp),%cl
  8025f6:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8025f8:	83 c4 20             	add    $0x20,%esp
  8025fb:	5e                   	pop    %esi
  8025fc:	5f                   	pop    %edi
  8025fd:	c9                   	leave  
  8025fe:	c3                   	ret    
  8025ff:	90                   	nop
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  802600:	85 c9                	test   %ecx,%ecx
  802602:	75 0b                	jne    80260f <__umoddi3+0xd3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  802604:	b8 01 00 00 00       	mov    $0x1,%eax
  802609:	31 d2                	xor    %edx,%edx
  80260b:	f7 f1                	div    %ecx
  80260d:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  80260f:	89 f0                	mov    %esi,%eax
  802611:	31 d2                	xor    %edx,%edx
  802613:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802615:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802618:	f7 f1                	div    %ecx
  80261a:	e9 4a ff ff ff       	jmp    802569 <__umoddi3+0x2d>
  80261f:	90                   	nop
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  802620:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802622:	83 c4 20             	add    $0x20,%esp
  802625:	5e                   	pop    %esi
  802626:	5f                   	pop    %edi
  802627:	c9                   	leave  
  802628:	c3                   	ret    
  802629:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  80262c:	39 f7                	cmp    %esi,%edi
  80262e:	72 05                	jb     802635 <__umoddi3+0xf9>
  802630:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
  802633:	77 0c                	ja     802641 <__umoddi3+0x105>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  802635:	89 f2                	mov    %esi,%edx
  802637:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80263a:	29 c8                	sub    %ecx,%eax
  80263c:	19 fa                	sbb    %edi,%edx
  80263e:	89 45 f0             	mov    %eax,-0x10(%ebp)

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  802641:	8b 45 f0             	mov    -0x10(%ebp),%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802644:	83 c4 20             	add    $0x20,%esp
  802647:	5e                   	pop    %esi
  802648:	5f                   	pop    %edi
  802649:	c9                   	leave  
  80264a:	c3                   	ret    
  80264b:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  80264c:	8b 55 e8             	mov    -0x18(%ebp),%edx
  80264f:	89 c1                	mov    %eax,%ecx
  802651:	2b 4d f4             	sub    -0xc(%ebp),%ecx
  802654:	1b 55 f0             	sbb    -0x10(%ebp),%edx
  802657:	eb 84                	jmp    8025dd <__umoddi3+0xa1>
  802659:	8d 76 00             	lea    0x0(%esi),%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  80265c:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  80265f:	72 eb                	jb     80264c <__umoddi3+0x110>
  802661:	89 f2                	mov    %esi,%edx
  802663:	e9 75 ff ff ff       	jmp    8025dd <__umoddi3+0xa1>
