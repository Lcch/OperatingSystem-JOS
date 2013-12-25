
obj/user/thread_t2.debug:     file format elf32-i386


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
  80002c:	e8 bf 00 00 00       	call   8000f0 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <mythread>:

pthread_mutex_t Lock;
int sum;
int k;

void mythread(void * arg) {
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	53                   	push   %ebx
  800038:	83 ec 04             	sub    $0x4,%esp
  80003b:	bb 10 27 00 00       	mov    $0x2710,%ebx
	int i, t, g;
	for (i = 0; i != 10000; i++) {
		cprintf("%d\n", sum);
  800040:	83 ec 08             	sub    $0x8,%esp
  800043:	ff 35 04 40 80 00    	pushl  0x804004
  800049:	68 46 20 80 00       	push   $0x802046
  80004e:	e8 95 01 00 00       	call   8001e8 <cprintf>
		t = sum;
  800053:	8b 15 04 40 80 00    	mov    0x804004,%edx
  800059:	8b 0d 08 40 80 00    	mov    0x804008,%ecx
  80005f:	83 c4 10             	add    $0x10,%esp
  800062:	b8 0a 00 00 00       	mov    $0xa,%eax
		for (g = 0; g != 10; g++) k++;
  800067:	48                   	dec    %eax
  800068:	75 fd                	jne    800067 <mythread+0x33>
  80006a:	83 c1 0a             	add    $0xa,%ecx
		++t;
  80006d:	42                   	inc    %edx
		for (g = 0; g != 10; g++) k++;
  80006e:	b8 00 00 00 00       	mov    $0x0,%eax
  800073:	40                   	inc    %eax
  800074:	83 f8 0a             	cmp    $0xa,%eax
  800077:	75 fa                	jne    800073 <mythread+0x3f>
  800079:	8d 41 0a             	lea    0xa(%ecx),%eax
  80007c:	a3 08 40 80 00       	mov    %eax,0x804008
		sum = t;
  800081:	89 15 04 40 80 00    	mov    %edx,0x804004
int sum;
int k;

void mythread(void * arg) {
	int i, t, g;
	for (i = 0; i != 10000; i++) {
  800087:	4b                   	dec    %ebx
  800088:	75 b6                	jne    800040 <mythread+0xc>
		for (g = 0; g != 10; g++) k++;
		++t;
		for (g = 0; g != 10; g++) k++;
		sum = t;
	}
}
  80008a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80008d:	c9                   	leave  
  80008e:	c3                   	ret    

0080008f <umain>:

void
umain(int argc, char **argv)
{
  80008f:	55                   	push   %ebp
  800090:	89 e5                	mov    %esp,%ebp
  800092:	83 ec 1c             	sub    $0x1c,%esp
	uint32_t id[2];
	sum = 0;
  800095:	c7 05 04 40 80 00 00 	movl   $0x0,0x804004
  80009c:	00 00 00 
	pthread_create(&id[0], mythread, NULL);
  80009f:	6a 00                	push   $0x0
  8000a1:	68 34 00 80 00       	push   $0x800034
  8000a6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8000a9:	50                   	push   %eax
  8000aa:	e8 41 18 00 00       	call   8018f0 <pthread_create>
	pthread_create(&id[1], mythread, NULL);
  8000af:	83 c4 0c             	add    $0xc,%esp
  8000b2:	6a 00                	push   $0x0
  8000b4:	68 34 00 80 00       	push   $0x800034
  8000b9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8000bc:	50                   	push   %eax
  8000bd:	e8 2e 18 00 00       	call   8018f0 <pthread_create>
	pthread_join(id[0]);
  8000c2:	83 c4 04             	add    $0x4,%esp
  8000c5:	ff 75 f0             	pushl  -0x10(%ebp)
  8000c8:	e8 11 19 00 00       	call   8019de <pthread_join>
	pthread_join(id[1]);
  8000cd:	83 c4 04             	add    $0x4,%esp
  8000d0:	ff 75 f4             	pushl  -0xc(%ebp)
  8000d3:	e8 06 19 00 00       	call   8019de <pthread_join>
	cprintf("HAHA: %d\n", sum);
  8000d8:	83 c4 08             	add    $0x8,%esp
  8000db:	ff 35 04 40 80 00    	pushl  0x804004
  8000e1:	68 40 20 80 00       	push   $0x802040
  8000e6:	e8 fd 00 00 00       	call   8001e8 <cprintf>
  8000eb:	83 c4 10             	add    $0x10,%esp
}
  8000ee:	c9                   	leave  
  8000ef:	c3                   	ret    

008000f0 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000f0:	55                   	push   %ebp
  8000f1:	89 e5                	mov    %esp,%ebp
  8000f3:	56                   	push   %esi
  8000f4:	53                   	push   %ebx
  8000f5:	8b 75 08             	mov    0x8(%ebp),%esi
  8000f8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs + ENVX(sys_getenvid());
  8000fb:	e8 d5 0a 00 00       	call   800bd5 <sys_getenvid>
  800100:	25 ff 03 00 00       	and    $0x3ff,%eax
  800105:	89 c2                	mov    %eax,%edx
  800107:	c1 e2 07             	shl    $0x7,%edx
  80010a:	8d 84 82 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,4),%eax
  800111:	a3 10 40 80 00       	mov    %eax,0x804010

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800116:	85 f6                	test   %esi,%esi
  800118:	7e 07                	jle    800121 <libmain+0x31>
		binaryname = argv[0];
  80011a:	8b 03                	mov    (%ebx),%eax
  80011c:	a3 00 30 80 00       	mov    %eax,0x803000
	// call user main routine
	umain(argc, argv);
  800121:	83 ec 08             	sub    $0x8,%esp
  800124:	53                   	push   %ebx
  800125:	56                   	push   %esi
  800126:	e8 64 ff ff ff       	call   80008f <umain>

	// exit gracefully
	exit();
  80012b:	e8 0c 00 00 00       	call   80013c <exit>
  800130:	83 c4 10             	add    $0x10,%esp
}
  800133:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800136:	5b                   	pop    %ebx
  800137:	5e                   	pop    %esi
  800138:	c9                   	leave  
  800139:	c3                   	ret    
	...

0080013c <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80013c:	55                   	push   %ebp
  80013d:	89 e5                	mov    %esp,%ebp
  80013f:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800142:	e8 8f 0e 00 00       	call   800fd6 <close_all>
	sys_env_destroy(0);
  800147:	83 ec 0c             	sub    $0xc,%esp
  80014a:	6a 00                	push   $0x0
  80014c:	e8 62 0a 00 00       	call   800bb3 <sys_env_destroy>
  800151:	83 c4 10             	add    $0x10,%esp
}
  800154:	c9                   	leave  
  800155:	c3                   	ret    
	...

00800158 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800158:	55                   	push   %ebp
  800159:	89 e5                	mov    %esp,%ebp
  80015b:	53                   	push   %ebx
  80015c:	83 ec 04             	sub    $0x4,%esp
  80015f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800162:	8b 03                	mov    (%ebx),%eax
  800164:	8b 55 08             	mov    0x8(%ebp),%edx
  800167:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  80016b:	40                   	inc    %eax
  80016c:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  80016e:	3d ff 00 00 00       	cmp    $0xff,%eax
  800173:	75 1a                	jne    80018f <putch+0x37>
		sys_cputs(b->buf, b->idx);
  800175:	83 ec 08             	sub    $0x8,%esp
  800178:	68 ff 00 00 00       	push   $0xff
  80017d:	8d 43 08             	lea    0x8(%ebx),%eax
  800180:	50                   	push   %eax
  800181:	e8 e3 09 00 00       	call   800b69 <sys_cputs>
		b->idx = 0;
  800186:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80018c:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80018f:	ff 43 04             	incl   0x4(%ebx)
}
  800192:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800195:	c9                   	leave  
  800196:	c3                   	ret    

00800197 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800197:	55                   	push   %ebp
  800198:	89 e5                	mov    %esp,%ebp
  80019a:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001a0:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001a7:	00 00 00 
	b.cnt = 0;
  8001aa:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001b1:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001b4:	ff 75 0c             	pushl  0xc(%ebp)
  8001b7:	ff 75 08             	pushl  0x8(%ebp)
  8001ba:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001c0:	50                   	push   %eax
  8001c1:	68 58 01 80 00       	push   $0x800158
  8001c6:	e8 82 01 00 00       	call   80034d <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001cb:	83 c4 08             	add    $0x8,%esp
  8001ce:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8001d4:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001da:	50                   	push   %eax
  8001db:	e8 89 09 00 00       	call   800b69 <sys_cputs>

	return b.cnt;
}
  8001e0:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001e6:	c9                   	leave  
  8001e7:	c3                   	ret    

008001e8 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001e8:	55                   	push   %ebp
  8001e9:	89 e5                	mov    %esp,%ebp
  8001eb:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001ee:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001f1:	50                   	push   %eax
  8001f2:	ff 75 08             	pushl  0x8(%ebp)
  8001f5:	e8 9d ff ff ff       	call   800197 <vcprintf>
	va_end(ap);

	return cnt;
}
  8001fa:	c9                   	leave  
  8001fb:	c3                   	ret    

008001fc <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001fc:	55                   	push   %ebp
  8001fd:	89 e5                	mov    %esp,%ebp
  8001ff:	57                   	push   %edi
  800200:	56                   	push   %esi
  800201:	53                   	push   %ebx
  800202:	83 ec 2c             	sub    $0x2c,%esp
  800205:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800208:	89 d6                	mov    %edx,%esi
  80020a:	8b 45 08             	mov    0x8(%ebp),%eax
  80020d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800210:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800213:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800216:	8b 45 10             	mov    0x10(%ebp),%eax
  800219:	8b 5d 14             	mov    0x14(%ebp),%ebx
  80021c:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80021f:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800222:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  800229:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
  80022c:	72 0c                	jb     80023a <printnum+0x3e>
  80022e:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  800231:	76 07                	jbe    80023a <printnum+0x3e>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800233:	4b                   	dec    %ebx
  800234:	85 db                	test   %ebx,%ebx
  800236:	7f 31                	jg     800269 <printnum+0x6d>
  800238:	eb 3f                	jmp    800279 <printnum+0x7d>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80023a:	83 ec 0c             	sub    $0xc,%esp
  80023d:	57                   	push   %edi
  80023e:	4b                   	dec    %ebx
  80023f:	53                   	push   %ebx
  800240:	50                   	push   %eax
  800241:	83 ec 08             	sub    $0x8,%esp
  800244:	ff 75 d4             	pushl  -0x2c(%ebp)
  800247:	ff 75 d0             	pushl  -0x30(%ebp)
  80024a:	ff 75 dc             	pushl  -0x24(%ebp)
  80024d:	ff 75 d8             	pushl  -0x28(%ebp)
  800250:	e8 9b 1b 00 00       	call   801df0 <__udivdi3>
  800255:	83 c4 18             	add    $0x18,%esp
  800258:	52                   	push   %edx
  800259:	50                   	push   %eax
  80025a:	89 f2                	mov    %esi,%edx
  80025c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80025f:	e8 98 ff ff ff       	call   8001fc <printnum>
  800264:	83 c4 20             	add    $0x20,%esp
  800267:	eb 10                	jmp    800279 <printnum+0x7d>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800269:	83 ec 08             	sub    $0x8,%esp
  80026c:	56                   	push   %esi
  80026d:	57                   	push   %edi
  80026e:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800271:	4b                   	dec    %ebx
  800272:	83 c4 10             	add    $0x10,%esp
  800275:	85 db                	test   %ebx,%ebx
  800277:	7f f0                	jg     800269 <printnum+0x6d>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800279:	83 ec 08             	sub    $0x8,%esp
  80027c:	56                   	push   %esi
  80027d:	83 ec 04             	sub    $0x4,%esp
  800280:	ff 75 d4             	pushl  -0x2c(%ebp)
  800283:	ff 75 d0             	pushl  -0x30(%ebp)
  800286:	ff 75 dc             	pushl  -0x24(%ebp)
  800289:	ff 75 d8             	pushl  -0x28(%ebp)
  80028c:	e8 7b 1c 00 00       	call   801f0c <__umoddi3>
  800291:	83 c4 14             	add    $0x14,%esp
  800294:	0f be 80 54 20 80 00 	movsbl 0x802054(%eax),%eax
  80029b:	50                   	push   %eax
  80029c:	ff 55 e4             	call   *-0x1c(%ebp)
  80029f:	83 c4 10             	add    $0x10,%esp
}
  8002a2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002a5:	5b                   	pop    %ebx
  8002a6:	5e                   	pop    %esi
  8002a7:	5f                   	pop    %edi
  8002a8:	c9                   	leave  
  8002a9:	c3                   	ret    

008002aa <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002aa:	55                   	push   %ebp
  8002ab:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002ad:	83 fa 01             	cmp    $0x1,%edx
  8002b0:	7e 0e                	jle    8002c0 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8002b2:	8b 10                	mov    (%eax),%edx
  8002b4:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002b7:	89 08                	mov    %ecx,(%eax)
  8002b9:	8b 02                	mov    (%edx),%eax
  8002bb:	8b 52 04             	mov    0x4(%edx),%edx
  8002be:	eb 22                	jmp    8002e2 <getuint+0x38>
	else if (lflag)
  8002c0:	85 d2                	test   %edx,%edx
  8002c2:	74 10                	je     8002d4 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8002c4:	8b 10                	mov    (%eax),%edx
  8002c6:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002c9:	89 08                	mov    %ecx,(%eax)
  8002cb:	8b 02                	mov    (%edx),%eax
  8002cd:	ba 00 00 00 00       	mov    $0x0,%edx
  8002d2:	eb 0e                	jmp    8002e2 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8002d4:	8b 10                	mov    (%eax),%edx
  8002d6:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002d9:	89 08                	mov    %ecx,(%eax)
  8002db:	8b 02                	mov    (%edx),%eax
  8002dd:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002e2:	c9                   	leave  
  8002e3:	c3                   	ret    

008002e4 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  8002e4:	55                   	push   %ebp
  8002e5:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002e7:	83 fa 01             	cmp    $0x1,%edx
  8002ea:	7e 0e                	jle    8002fa <getint+0x16>
		return va_arg(*ap, long long);
  8002ec:	8b 10                	mov    (%eax),%edx
  8002ee:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002f1:	89 08                	mov    %ecx,(%eax)
  8002f3:	8b 02                	mov    (%edx),%eax
  8002f5:	8b 52 04             	mov    0x4(%edx),%edx
  8002f8:	eb 1a                	jmp    800314 <getint+0x30>
	else if (lflag)
  8002fa:	85 d2                	test   %edx,%edx
  8002fc:	74 0c                	je     80030a <getint+0x26>
		return va_arg(*ap, long);
  8002fe:	8b 10                	mov    (%eax),%edx
  800300:	8d 4a 04             	lea    0x4(%edx),%ecx
  800303:	89 08                	mov    %ecx,(%eax)
  800305:	8b 02                	mov    (%edx),%eax
  800307:	99                   	cltd   
  800308:	eb 0a                	jmp    800314 <getint+0x30>
	else
		return va_arg(*ap, int);
  80030a:	8b 10                	mov    (%eax),%edx
  80030c:	8d 4a 04             	lea    0x4(%edx),%ecx
  80030f:	89 08                	mov    %ecx,(%eax)
  800311:	8b 02                	mov    (%edx),%eax
  800313:	99                   	cltd   
}
  800314:	c9                   	leave  
  800315:	c3                   	ret    

00800316 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800316:	55                   	push   %ebp
  800317:	89 e5                	mov    %esp,%ebp
  800319:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80031c:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  80031f:	8b 10                	mov    (%eax),%edx
  800321:	3b 50 04             	cmp    0x4(%eax),%edx
  800324:	73 08                	jae    80032e <sprintputch+0x18>
		*b->buf++ = ch;
  800326:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800329:	88 0a                	mov    %cl,(%edx)
  80032b:	42                   	inc    %edx
  80032c:	89 10                	mov    %edx,(%eax)
}
  80032e:	c9                   	leave  
  80032f:	c3                   	ret    

00800330 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800330:	55                   	push   %ebp
  800331:	89 e5                	mov    %esp,%ebp
  800333:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800336:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800339:	50                   	push   %eax
  80033a:	ff 75 10             	pushl  0x10(%ebp)
  80033d:	ff 75 0c             	pushl  0xc(%ebp)
  800340:	ff 75 08             	pushl  0x8(%ebp)
  800343:	e8 05 00 00 00       	call   80034d <vprintfmt>
	va_end(ap);
  800348:	83 c4 10             	add    $0x10,%esp
}
  80034b:	c9                   	leave  
  80034c:	c3                   	ret    

0080034d <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80034d:	55                   	push   %ebp
  80034e:	89 e5                	mov    %esp,%ebp
  800350:	57                   	push   %edi
  800351:	56                   	push   %esi
  800352:	53                   	push   %ebx
  800353:	83 ec 2c             	sub    $0x2c,%esp
  800356:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800359:	8b 75 10             	mov    0x10(%ebp),%esi
  80035c:	eb 13                	jmp    800371 <vprintfmt+0x24>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80035e:	85 c0                	test   %eax,%eax
  800360:	0f 84 6d 03 00 00    	je     8006d3 <vprintfmt+0x386>
				return;
			putch(ch, putdat);
  800366:	83 ec 08             	sub    $0x8,%esp
  800369:	57                   	push   %edi
  80036a:	50                   	push   %eax
  80036b:	ff 55 08             	call   *0x8(%ebp)
  80036e:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800371:	0f b6 06             	movzbl (%esi),%eax
  800374:	46                   	inc    %esi
  800375:	83 f8 25             	cmp    $0x25,%eax
  800378:	75 e4                	jne    80035e <vprintfmt+0x11>
  80037a:	c6 45 dc 20          	movb   $0x20,-0x24(%ebp)
  80037e:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  800385:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  80038c:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800393:	b9 00 00 00 00       	mov    $0x0,%ecx
  800398:	eb 28                	jmp    8003c2 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80039a:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  80039c:	c6 45 dc 2d          	movb   $0x2d,-0x24(%ebp)
  8003a0:	eb 20                	jmp    8003c2 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003a2:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8003a4:	c6 45 dc 30          	movb   $0x30,-0x24(%ebp)
  8003a8:	eb 18                	jmp    8003c2 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003aa:	89 de                	mov    %ebx,%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  8003ac:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8003b3:	eb 0d                	jmp    8003c2 <vprintfmt+0x75>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  8003b5:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8003b8:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003bb:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003c2:	8a 06                	mov    (%esi),%al
  8003c4:	0f b6 d0             	movzbl %al,%edx
  8003c7:	8d 5e 01             	lea    0x1(%esi),%ebx
  8003ca:	83 e8 23             	sub    $0x23,%eax
  8003cd:	3c 55                	cmp    $0x55,%al
  8003cf:	0f 87 e0 02 00 00    	ja     8006b5 <vprintfmt+0x368>
  8003d5:	0f b6 c0             	movzbl %al,%eax
  8003d8:	ff 24 85 a0 21 80 00 	jmp    *0x8021a0(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003df:	83 ea 30             	sub    $0x30,%edx
  8003e2:	89 55 d4             	mov    %edx,-0x2c(%ebp)
				ch = *fmt;
  8003e5:	0f be 03             	movsbl (%ebx),%eax
				if (ch < '0' || ch > '9')
  8003e8:	8d 50 d0             	lea    -0x30(%eax),%edx
  8003eb:	83 fa 09             	cmp    $0x9,%edx
  8003ee:	77 44                	ja     800434 <vprintfmt+0xe7>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003f0:	89 de                	mov    %ebx,%esi
  8003f2:	8b 55 d4             	mov    -0x2c(%ebp),%edx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003f5:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
  8003f6:	8d 14 92             	lea    (%edx,%edx,4),%edx
  8003f9:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
  8003fd:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800400:	8d 58 d0             	lea    -0x30(%eax),%ebx
  800403:	83 fb 09             	cmp    $0x9,%ebx
  800406:	76 ed                	jbe    8003f5 <vprintfmt+0xa8>
  800408:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  80040b:	eb 29                	jmp    800436 <vprintfmt+0xe9>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80040d:	8b 45 14             	mov    0x14(%ebp),%eax
  800410:	8d 50 04             	lea    0x4(%eax),%edx
  800413:	89 55 14             	mov    %edx,0x14(%ebp)
  800416:	8b 00                	mov    (%eax),%eax
  800418:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80041b:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80041d:	eb 17                	jmp    800436 <vprintfmt+0xe9>

		case '.':
			if (width < 0)
  80041f:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800423:	78 85                	js     8003aa <vprintfmt+0x5d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800425:	89 de                	mov    %ebx,%esi
  800427:	eb 99                	jmp    8003c2 <vprintfmt+0x75>
  800429:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80042b:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  800432:	eb 8e                	jmp    8003c2 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800434:	89 de                	mov    %ebx,%esi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  800436:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80043a:	79 86                	jns    8003c2 <vprintfmt+0x75>
  80043c:	e9 74 ff ff ff       	jmp    8003b5 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800441:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800442:	89 de                	mov    %ebx,%esi
  800444:	e9 79 ff ff ff       	jmp    8003c2 <vprintfmt+0x75>
  800449:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80044c:	8b 45 14             	mov    0x14(%ebp),%eax
  80044f:	8d 50 04             	lea    0x4(%eax),%edx
  800452:	89 55 14             	mov    %edx,0x14(%ebp)
  800455:	83 ec 08             	sub    $0x8,%esp
  800458:	57                   	push   %edi
  800459:	ff 30                	pushl  (%eax)
  80045b:	ff 55 08             	call   *0x8(%ebp)
			break;
  80045e:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800461:	8b 75 d8             	mov    -0x28(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800464:	e9 08 ff ff ff       	jmp    800371 <vprintfmt+0x24>
  800469:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  80046c:	8b 45 14             	mov    0x14(%ebp),%eax
  80046f:	8d 50 04             	lea    0x4(%eax),%edx
  800472:	89 55 14             	mov    %edx,0x14(%ebp)
  800475:	8b 00                	mov    (%eax),%eax
  800477:	85 c0                	test   %eax,%eax
  800479:	79 02                	jns    80047d <vprintfmt+0x130>
  80047b:	f7 d8                	neg    %eax
  80047d:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80047f:	83 f8 0f             	cmp    $0xf,%eax
  800482:	7f 0b                	jg     80048f <vprintfmt+0x142>
  800484:	8b 04 85 00 23 80 00 	mov    0x802300(,%eax,4),%eax
  80048b:	85 c0                	test   %eax,%eax
  80048d:	75 1a                	jne    8004a9 <vprintfmt+0x15c>
				printfmt(putch, putdat, "error %d", err);
  80048f:	52                   	push   %edx
  800490:	68 6c 20 80 00       	push   $0x80206c
  800495:	57                   	push   %edi
  800496:	ff 75 08             	pushl  0x8(%ebp)
  800499:	e8 92 fe ff ff       	call   800330 <printfmt>
  80049e:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004a1:	8b 75 d8             	mov    -0x28(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8004a4:	e9 c8 fe ff ff       	jmp    800371 <vprintfmt+0x24>
			else
				printfmt(putch, putdat, "%s", p);
  8004a9:	50                   	push   %eax
  8004aa:	68 31 24 80 00       	push   $0x802431
  8004af:	57                   	push   %edi
  8004b0:	ff 75 08             	pushl  0x8(%ebp)
  8004b3:	e8 78 fe ff ff       	call   800330 <printfmt>
  8004b8:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004bb:	8b 75 d8             	mov    -0x28(%ebp),%esi
  8004be:	e9 ae fe ff ff       	jmp    800371 <vprintfmt+0x24>
  8004c3:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  8004c6:	89 de                	mov    %ebx,%esi
  8004c8:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  8004cb:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004ce:	8b 45 14             	mov    0x14(%ebp),%eax
  8004d1:	8d 50 04             	lea    0x4(%eax),%edx
  8004d4:	89 55 14             	mov    %edx,0x14(%ebp)
  8004d7:	8b 00                	mov    (%eax),%eax
  8004d9:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8004dc:	85 c0                	test   %eax,%eax
  8004de:	75 07                	jne    8004e7 <vprintfmt+0x19a>
				p = "(null)";
  8004e0:	c7 45 d0 65 20 80 00 	movl   $0x802065,-0x30(%ebp)
			if (width > 0 && padc != '-')
  8004e7:	85 db                	test   %ebx,%ebx
  8004e9:	7e 42                	jle    80052d <vprintfmt+0x1e0>
  8004eb:	80 7d dc 2d          	cmpb   $0x2d,-0x24(%ebp)
  8004ef:	74 3c                	je     80052d <vprintfmt+0x1e0>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004f1:	83 ec 08             	sub    $0x8,%esp
  8004f4:	51                   	push   %ecx
  8004f5:	ff 75 d0             	pushl  -0x30(%ebp)
  8004f8:	e8 6f 02 00 00       	call   80076c <strnlen>
  8004fd:	29 c3                	sub    %eax,%ebx
  8004ff:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800502:	83 c4 10             	add    $0x10,%esp
  800505:	85 db                	test   %ebx,%ebx
  800507:	7e 24                	jle    80052d <vprintfmt+0x1e0>
					putch(padc, putdat);
  800509:	0f be 5d dc          	movsbl -0x24(%ebp),%ebx
  80050d:	89 75 dc             	mov    %esi,-0x24(%ebp)
  800510:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  800513:	83 ec 08             	sub    $0x8,%esp
  800516:	57                   	push   %edi
  800517:	53                   	push   %ebx
  800518:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80051b:	4e                   	dec    %esi
  80051c:	83 c4 10             	add    $0x10,%esp
  80051f:	85 f6                	test   %esi,%esi
  800521:	7f f0                	jg     800513 <vprintfmt+0x1c6>
  800523:	8b 75 dc             	mov    -0x24(%ebp),%esi
  800526:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80052d:	8b 55 d0             	mov    -0x30(%ebp),%edx
  800530:	0f be 02             	movsbl (%edx),%eax
  800533:	85 c0                	test   %eax,%eax
  800535:	75 47                	jne    80057e <vprintfmt+0x231>
  800537:	eb 37                	jmp    800570 <vprintfmt+0x223>
				if (altflag && (ch < ' ' || ch > '~'))
  800539:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80053d:	74 16                	je     800555 <vprintfmt+0x208>
  80053f:	8d 50 e0             	lea    -0x20(%eax),%edx
  800542:	83 fa 5e             	cmp    $0x5e,%edx
  800545:	76 0e                	jbe    800555 <vprintfmt+0x208>
					putch('?', putdat);
  800547:	83 ec 08             	sub    $0x8,%esp
  80054a:	57                   	push   %edi
  80054b:	6a 3f                	push   $0x3f
  80054d:	ff 55 08             	call   *0x8(%ebp)
  800550:	83 c4 10             	add    $0x10,%esp
  800553:	eb 0b                	jmp    800560 <vprintfmt+0x213>
				else
					putch(ch, putdat);
  800555:	83 ec 08             	sub    $0x8,%esp
  800558:	57                   	push   %edi
  800559:	50                   	push   %eax
  80055a:	ff 55 08             	call   *0x8(%ebp)
  80055d:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800560:	ff 4d e4             	decl   -0x1c(%ebp)
  800563:	0f be 03             	movsbl (%ebx),%eax
  800566:	85 c0                	test   %eax,%eax
  800568:	74 03                	je     80056d <vprintfmt+0x220>
  80056a:	43                   	inc    %ebx
  80056b:	eb 1b                	jmp    800588 <vprintfmt+0x23b>
  80056d:	8b 75 dc             	mov    -0x24(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800570:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800574:	7f 1e                	jg     800594 <vprintfmt+0x247>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800576:	8b 75 d8             	mov    -0x28(%ebp),%esi
  800579:	e9 f3 fd ff ff       	jmp    800371 <vprintfmt+0x24>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80057e:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800581:	43                   	inc    %ebx
  800582:	89 75 dc             	mov    %esi,-0x24(%ebp)
  800585:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  800588:	85 f6                	test   %esi,%esi
  80058a:	78 ad                	js     800539 <vprintfmt+0x1ec>
  80058c:	4e                   	dec    %esi
  80058d:	79 aa                	jns    800539 <vprintfmt+0x1ec>
  80058f:	8b 75 dc             	mov    -0x24(%ebp),%esi
  800592:	eb dc                	jmp    800570 <vprintfmt+0x223>
  800594:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800597:	83 ec 08             	sub    $0x8,%esp
  80059a:	57                   	push   %edi
  80059b:	6a 20                	push   $0x20
  80059d:	ff 55 08             	call   *0x8(%ebp)
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005a0:	4b                   	dec    %ebx
  8005a1:	83 c4 10             	add    $0x10,%esp
  8005a4:	85 db                	test   %ebx,%ebx
  8005a6:	7f ef                	jg     800597 <vprintfmt+0x24a>
  8005a8:	e9 c4 fd ff ff       	jmp    800371 <vprintfmt+0x24>
  8005ad:	89 5d d8             	mov    %ebx,-0x28(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8005b0:	89 ca                	mov    %ecx,%edx
  8005b2:	8d 45 14             	lea    0x14(%ebp),%eax
  8005b5:	e8 2a fd ff ff       	call   8002e4 <getint>
  8005ba:	89 c3                	mov    %eax,%ebx
  8005bc:	89 d6                	mov    %edx,%esi
			if ((long long) num < 0) {
  8005be:	85 d2                	test   %edx,%edx
  8005c0:	78 0a                	js     8005cc <vprintfmt+0x27f>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8005c2:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005c7:	e9 b0 00 00 00       	jmp    80067c <vprintfmt+0x32f>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  8005cc:	83 ec 08             	sub    $0x8,%esp
  8005cf:	57                   	push   %edi
  8005d0:	6a 2d                	push   $0x2d
  8005d2:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8005d5:	f7 db                	neg    %ebx
  8005d7:	83 d6 00             	adc    $0x0,%esi
  8005da:	f7 de                	neg    %esi
  8005dc:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8005df:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005e4:	e9 93 00 00 00       	jmp    80067c <vprintfmt+0x32f>
  8005e9:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8005ec:	89 ca                	mov    %ecx,%edx
  8005ee:	8d 45 14             	lea    0x14(%ebp),%eax
  8005f1:	e8 b4 fc ff ff       	call   8002aa <getuint>
  8005f6:	89 c3                	mov    %eax,%ebx
  8005f8:	89 d6                	mov    %edx,%esi
			base = 10;
  8005fa:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  8005ff:	eb 7b                	jmp    80067c <vprintfmt+0x32f>
  800601:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
  800604:	89 ca                	mov    %ecx,%edx
  800606:	8d 45 14             	lea    0x14(%ebp),%eax
  800609:	e8 d6 fc ff ff       	call   8002e4 <getint>
  80060e:	89 c3                	mov    %eax,%ebx
  800610:	89 d6                	mov    %edx,%esi
            if ((long long) num < 0) {
  800612:	85 d2                	test   %edx,%edx
  800614:	78 07                	js     80061d <vprintfmt+0x2d0>
                putch('-', putdat);
                num = -(long long) num;
            }
            base = 8;
  800616:	b8 08 00 00 00       	mov    $0x8,%eax
  80061b:	eb 5f                	jmp    80067c <vprintfmt+0x32f>
		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
            if ((long long) num < 0) {
                putch('-', putdat);
  80061d:	83 ec 08             	sub    $0x8,%esp
  800620:	57                   	push   %edi
  800621:	6a 2d                	push   $0x2d
  800623:	ff 55 08             	call   *0x8(%ebp)
                num = -(long long) num;
  800626:	f7 db                	neg    %ebx
  800628:	83 d6 00             	adc    $0x0,%esi
  80062b:	f7 de                	neg    %esi
  80062d:	83 c4 10             	add    $0x10,%esp
            }
            base = 8;
  800630:	b8 08 00 00 00       	mov    $0x8,%eax
  800635:	eb 45                	jmp    80067c <vprintfmt+0x32f>
  800637:	89 5d d8             	mov    %ebx,-0x28(%ebp)
            goto number;

        // pointer
		case 'p':
			putch('0', putdat);
  80063a:	83 ec 08             	sub    $0x8,%esp
  80063d:	57                   	push   %edi
  80063e:	6a 30                	push   $0x30
  800640:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800643:	83 c4 08             	add    $0x8,%esp
  800646:	57                   	push   %edi
  800647:	6a 78                	push   $0x78
  800649:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80064c:	8b 45 14             	mov    0x14(%ebp),%eax
  80064f:	8d 50 04             	lea    0x4(%eax),%edx
  800652:	89 55 14             	mov    %edx,0x14(%ebp)

        // pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800655:	8b 18                	mov    (%eax),%ebx
  800657:	be 00 00 00 00       	mov    $0x0,%esi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80065c:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80065f:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800664:	eb 16                	jmp    80067c <vprintfmt+0x32f>
  800666:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800669:	89 ca                	mov    %ecx,%edx
  80066b:	8d 45 14             	lea    0x14(%ebp),%eax
  80066e:	e8 37 fc ff ff       	call   8002aa <getuint>
  800673:	89 c3                	mov    %eax,%ebx
  800675:	89 d6                	mov    %edx,%esi
			base = 16;
  800677:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  80067c:	83 ec 0c             	sub    $0xc,%esp
  80067f:	0f be 55 dc          	movsbl -0x24(%ebp),%edx
  800683:	52                   	push   %edx
  800684:	ff 75 e4             	pushl  -0x1c(%ebp)
  800687:	50                   	push   %eax
  800688:	56                   	push   %esi
  800689:	53                   	push   %ebx
  80068a:	89 fa                	mov    %edi,%edx
  80068c:	8b 45 08             	mov    0x8(%ebp),%eax
  80068f:	e8 68 fb ff ff       	call   8001fc <printnum>
			break;
  800694:	83 c4 20             	add    $0x20,%esp
  800697:	8b 75 d8             	mov    -0x28(%ebp),%esi
  80069a:	e9 d2 fc ff ff       	jmp    800371 <vprintfmt+0x24>
  80069f:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006a2:	83 ec 08             	sub    $0x8,%esp
  8006a5:	57                   	push   %edi
  8006a6:	52                   	push   %edx
  8006a7:	ff 55 08             	call   *0x8(%ebp)
			break;
  8006aa:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006ad:	8b 75 d8             	mov    -0x28(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8006b0:	e9 bc fc ff ff       	jmp    800371 <vprintfmt+0x24>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8006b5:	83 ec 08             	sub    $0x8,%esp
  8006b8:	57                   	push   %edi
  8006b9:	6a 25                	push   $0x25
  8006bb:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006be:	83 c4 10             	add    $0x10,%esp
  8006c1:	eb 02                	jmp    8006c5 <vprintfmt+0x378>
  8006c3:	89 c6                	mov    %eax,%esi
  8006c5:	8d 46 ff             	lea    -0x1(%esi),%eax
  8006c8:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  8006cc:	75 f5                	jne    8006c3 <vprintfmt+0x376>
  8006ce:	e9 9e fc ff ff       	jmp    800371 <vprintfmt+0x24>
				/* do nothing */;
			break;
		}
	}
}
  8006d3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006d6:	5b                   	pop    %ebx
  8006d7:	5e                   	pop    %esi
  8006d8:	5f                   	pop    %edi
  8006d9:	c9                   	leave  
  8006da:	c3                   	ret    

008006db <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006db:	55                   	push   %ebp
  8006dc:	89 e5                	mov    %esp,%ebp
  8006de:	83 ec 18             	sub    $0x18,%esp
  8006e1:	8b 45 08             	mov    0x8(%ebp),%eax
  8006e4:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006e7:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006ea:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8006ee:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8006f1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8006f8:	85 c0                	test   %eax,%eax
  8006fa:	74 26                	je     800722 <vsnprintf+0x47>
  8006fc:	85 d2                	test   %edx,%edx
  8006fe:	7e 29                	jle    800729 <vsnprintf+0x4e>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800700:	ff 75 14             	pushl  0x14(%ebp)
  800703:	ff 75 10             	pushl  0x10(%ebp)
  800706:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800709:	50                   	push   %eax
  80070a:	68 16 03 80 00       	push   $0x800316
  80070f:	e8 39 fc ff ff       	call   80034d <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800714:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800717:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80071a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80071d:	83 c4 10             	add    $0x10,%esp
  800720:	eb 0c                	jmp    80072e <vsnprintf+0x53>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800722:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800727:	eb 05                	jmp    80072e <vsnprintf+0x53>
  800729:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80072e:	c9                   	leave  
  80072f:	c3                   	ret    

00800730 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800730:	55                   	push   %ebp
  800731:	89 e5                	mov    %esp,%ebp
  800733:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800736:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800739:	50                   	push   %eax
  80073a:	ff 75 10             	pushl  0x10(%ebp)
  80073d:	ff 75 0c             	pushl  0xc(%ebp)
  800740:	ff 75 08             	pushl  0x8(%ebp)
  800743:	e8 93 ff ff ff       	call   8006db <vsnprintf>
	va_end(ap);

	return rc;
}
  800748:	c9                   	leave  
  800749:	c3                   	ret    
	...

0080074c <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80074c:	55                   	push   %ebp
  80074d:	89 e5                	mov    %esp,%ebp
  80074f:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800752:	80 3a 00             	cmpb   $0x0,(%edx)
  800755:	74 0e                	je     800765 <strlen+0x19>
  800757:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  80075c:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80075d:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800761:	75 f9                	jne    80075c <strlen+0x10>
  800763:	eb 05                	jmp    80076a <strlen+0x1e>
  800765:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  80076a:	c9                   	leave  
  80076b:	c3                   	ret    

0080076c <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80076c:	55                   	push   %ebp
  80076d:	89 e5                	mov    %esp,%ebp
  80076f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800772:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800775:	85 d2                	test   %edx,%edx
  800777:	74 17                	je     800790 <strnlen+0x24>
  800779:	80 39 00             	cmpb   $0x0,(%ecx)
  80077c:	74 19                	je     800797 <strnlen+0x2b>
  80077e:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800783:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800784:	39 d0                	cmp    %edx,%eax
  800786:	74 14                	je     80079c <strnlen+0x30>
  800788:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  80078c:	75 f5                	jne    800783 <strnlen+0x17>
  80078e:	eb 0c                	jmp    80079c <strnlen+0x30>
  800790:	b8 00 00 00 00       	mov    $0x0,%eax
  800795:	eb 05                	jmp    80079c <strnlen+0x30>
  800797:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  80079c:	c9                   	leave  
  80079d:	c3                   	ret    

0080079e <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80079e:	55                   	push   %ebp
  80079f:	89 e5                	mov    %esp,%ebp
  8007a1:	53                   	push   %ebx
  8007a2:	8b 45 08             	mov    0x8(%ebp),%eax
  8007a5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007a8:	ba 00 00 00 00       	mov    $0x0,%edx
  8007ad:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  8007b0:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  8007b3:	42                   	inc    %edx
  8007b4:	84 c9                	test   %cl,%cl
  8007b6:	75 f5                	jne    8007ad <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8007b8:	5b                   	pop    %ebx
  8007b9:	c9                   	leave  
  8007ba:	c3                   	ret    

008007bb <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007bb:	55                   	push   %ebp
  8007bc:	89 e5                	mov    %esp,%ebp
  8007be:	53                   	push   %ebx
  8007bf:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007c2:	53                   	push   %ebx
  8007c3:	e8 84 ff ff ff       	call   80074c <strlen>
  8007c8:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8007cb:	ff 75 0c             	pushl  0xc(%ebp)
  8007ce:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  8007d1:	50                   	push   %eax
  8007d2:	e8 c7 ff ff ff       	call   80079e <strcpy>
	return dst;
}
  8007d7:	89 d8                	mov    %ebx,%eax
  8007d9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007dc:	c9                   	leave  
  8007dd:	c3                   	ret    

008007de <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007de:	55                   	push   %ebp
  8007df:	89 e5                	mov    %esp,%ebp
  8007e1:	56                   	push   %esi
  8007e2:	53                   	push   %ebx
  8007e3:	8b 45 08             	mov    0x8(%ebp),%eax
  8007e6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007e9:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007ec:	85 f6                	test   %esi,%esi
  8007ee:	74 15                	je     800805 <strncpy+0x27>
  8007f0:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  8007f5:	8a 1a                	mov    (%edx),%bl
  8007f7:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007fa:	80 3a 01             	cmpb   $0x1,(%edx)
  8007fd:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800800:	41                   	inc    %ecx
  800801:	39 ce                	cmp    %ecx,%esi
  800803:	77 f0                	ja     8007f5 <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800805:	5b                   	pop    %ebx
  800806:	5e                   	pop    %esi
  800807:	c9                   	leave  
  800808:	c3                   	ret    

00800809 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800809:	55                   	push   %ebp
  80080a:	89 e5                	mov    %esp,%ebp
  80080c:	57                   	push   %edi
  80080d:	56                   	push   %esi
  80080e:	53                   	push   %ebx
  80080f:	8b 7d 08             	mov    0x8(%ebp),%edi
  800812:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800815:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800818:	85 f6                	test   %esi,%esi
  80081a:	74 32                	je     80084e <strlcpy+0x45>
		while (--size > 0 && *src != '\0')
  80081c:	83 fe 01             	cmp    $0x1,%esi
  80081f:	74 22                	je     800843 <strlcpy+0x3a>
  800821:	8a 0b                	mov    (%ebx),%cl
  800823:	84 c9                	test   %cl,%cl
  800825:	74 20                	je     800847 <strlcpy+0x3e>
  800827:	89 f8                	mov    %edi,%eax
  800829:	ba 00 00 00 00       	mov    $0x0,%edx
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
  80082e:	83 ee 02             	sub    $0x2,%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800831:	88 08                	mov    %cl,(%eax)
  800833:	40                   	inc    %eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800834:	39 f2                	cmp    %esi,%edx
  800836:	74 11                	je     800849 <strlcpy+0x40>
  800838:	8a 4c 13 01          	mov    0x1(%ebx,%edx,1),%cl
  80083c:	42                   	inc    %edx
  80083d:	84 c9                	test   %cl,%cl
  80083f:	75 f0                	jne    800831 <strlcpy+0x28>
  800841:	eb 06                	jmp    800849 <strlcpy+0x40>
  800843:	89 f8                	mov    %edi,%eax
  800845:	eb 02                	jmp    800849 <strlcpy+0x40>
  800847:	89 f8                	mov    %edi,%eax
			*dst++ = *src++;
		*dst = '\0';
  800849:	c6 00 00             	movb   $0x0,(%eax)
  80084c:	eb 02                	jmp    800850 <strlcpy+0x47>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80084e:	89 f8                	mov    %edi,%eax
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
		*dst = '\0';
	}
	return dst - dst_in;
  800850:	29 f8                	sub    %edi,%eax
}
  800852:	5b                   	pop    %ebx
  800853:	5e                   	pop    %esi
  800854:	5f                   	pop    %edi
  800855:	c9                   	leave  
  800856:	c3                   	ret    

00800857 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800857:	55                   	push   %ebp
  800858:	89 e5                	mov    %esp,%ebp
  80085a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80085d:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800860:	8a 01                	mov    (%ecx),%al
  800862:	84 c0                	test   %al,%al
  800864:	74 10                	je     800876 <strcmp+0x1f>
  800866:	3a 02                	cmp    (%edx),%al
  800868:	75 0c                	jne    800876 <strcmp+0x1f>
		p++, q++;
  80086a:	41                   	inc    %ecx
  80086b:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80086c:	8a 01                	mov    (%ecx),%al
  80086e:	84 c0                	test   %al,%al
  800870:	74 04                	je     800876 <strcmp+0x1f>
  800872:	3a 02                	cmp    (%edx),%al
  800874:	74 f4                	je     80086a <strcmp+0x13>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800876:	0f b6 c0             	movzbl %al,%eax
  800879:	0f b6 12             	movzbl (%edx),%edx
  80087c:	29 d0                	sub    %edx,%eax
}
  80087e:	c9                   	leave  
  80087f:	c3                   	ret    

00800880 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800880:	55                   	push   %ebp
  800881:	89 e5                	mov    %esp,%ebp
  800883:	53                   	push   %ebx
  800884:	8b 55 08             	mov    0x8(%ebp),%edx
  800887:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80088a:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  80088d:	85 c0                	test   %eax,%eax
  80088f:	74 1b                	je     8008ac <strncmp+0x2c>
  800891:	8a 1a                	mov    (%edx),%bl
  800893:	84 db                	test   %bl,%bl
  800895:	74 24                	je     8008bb <strncmp+0x3b>
  800897:	3a 19                	cmp    (%ecx),%bl
  800899:	75 20                	jne    8008bb <strncmp+0x3b>
  80089b:	48                   	dec    %eax
  80089c:	74 15                	je     8008b3 <strncmp+0x33>
		n--, p++, q++;
  80089e:	42                   	inc    %edx
  80089f:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8008a0:	8a 1a                	mov    (%edx),%bl
  8008a2:	84 db                	test   %bl,%bl
  8008a4:	74 15                	je     8008bb <strncmp+0x3b>
  8008a6:	3a 19                	cmp    (%ecx),%bl
  8008a8:	74 f1                	je     80089b <strncmp+0x1b>
  8008aa:	eb 0f                	jmp    8008bb <strncmp+0x3b>
		n--, p++, q++;
	if (n == 0)
		return 0;
  8008ac:	b8 00 00 00 00       	mov    $0x0,%eax
  8008b1:	eb 05                	jmp    8008b8 <strncmp+0x38>
  8008b3:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8008b8:	5b                   	pop    %ebx
  8008b9:	c9                   	leave  
  8008ba:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008bb:	0f b6 02             	movzbl (%edx),%eax
  8008be:	0f b6 11             	movzbl (%ecx),%edx
  8008c1:	29 d0                	sub    %edx,%eax
  8008c3:	eb f3                	jmp    8008b8 <strncmp+0x38>

008008c5 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008c5:	55                   	push   %ebp
  8008c6:	89 e5                	mov    %esp,%ebp
  8008c8:	8b 45 08             	mov    0x8(%ebp),%eax
  8008cb:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8008ce:	8a 10                	mov    (%eax),%dl
  8008d0:	84 d2                	test   %dl,%dl
  8008d2:	74 18                	je     8008ec <strchr+0x27>
		if (*s == c)
  8008d4:	38 ca                	cmp    %cl,%dl
  8008d6:	75 06                	jne    8008de <strchr+0x19>
  8008d8:	eb 17                	jmp    8008f1 <strchr+0x2c>
  8008da:	38 ca                	cmp    %cl,%dl
  8008dc:	74 13                	je     8008f1 <strchr+0x2c>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8008de:	40                   	inc    %eax
  8008df:	8a 10                	mov    (%eax),%dl
  8008e1:	84 d2                	test   %dl,%dl
  8008e3:	75 f5                	jne    8008da <strchr+0x15>
		if (*s == c)
			return (char *) s;
	return 0;
  8008e5:	b8 00 00 00 00       	mov    $0x0,%eax
  8008ea:	eb 05                	jmp    8008f1 <strchr+0x2c>
  8008ec:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008f1:	c9                   	leave  
  8008f2:	c3                   	ret    

008008f3 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008f3:	55                   	push   %ebp
  8008f4:	89 e5                	mov    %esp,%ebp
  8008f6:	8b 45 08             	mov    0x8(%ebp),%eax
  8008f9:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8008fc:	8a 10                	mov    (%eax),%dl
  8008fe:	84 d2                	test   %dl,%dl
  800900:	74 11                	je     800913 <strfind+0x20>
		if (*s == c)
  800902:	38 ca                	cmp    %cl,%dl
  800904:	75 06                	jne    80090c <strfind+0x19>
  800906:	eb 0b                	jmp    800913 <strfind+0x20>
  800908:	38 ca                	cmp    %cl,%dl
  80090a:	74 07                	je     800913 <strfind+0x20>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  80090c:	40                   	inc    %eax
  80090d:	8a 10                	mov    (%eax),%dl
  80090f:	84 d2                	test   %dl,%dl
  800911:	75 f5                	jne    800908 <strfind+0x15>
		if (*s == c)
			break;
	return (char *) s;
}
  800913:	c9                   	leave  
  800914:	c3                   	ret    

00800915 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800915:	55                   	push   %ebp
  800916:	89 e5                	mov    %esp,%ebp
  800918:	57                   	push   %edi
  800919:	56                   	push   %esi
  80091a:	53                   	push   %ebx
  80091b:	8b 7d 08             	mov    0x8(%ebp),%edi
  80091e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800921:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800924:	85 c9                	test   %ecx,%ecx
  800926:	74 30                	je     800958 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800928:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80092e:	75 25                	jne    800955 <memset+0x40>
  800930:	f6 c1 03             	test   $0x3,%cl
  800933:	75 20                	jne    800955 <memset+0x40>
		c &= 0xFF;
  800935:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800938:	89 d3                	mov    %edx,%ebx
  80093a:	c1 e3 08             	shl    $0x8,%ebx
  80093d:	89 d6                	mov    %edx,%esi
  80093f:	c1 e6 18             	shl    $0x18,%esi
  800942:	89 d0                	mov    %edx,%eax
  800944:	c1 e0 10             	shl    $0x10,%eax
  800947:	09 f0                	or     %esi,%eax
  800949:	09 d0                	or     %edx,%eax
  80094b:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  80094d:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800950:	fc                   	cld    
  800951:	f3 ab                	rep stos %eax,%es:(%edi)
  800953:	eb 03                	jmp    800958 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800955:	fc                   	cld    
  800956:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800958:	89 f8                	mov    %edi,%eax
  80095a:	5b                   	pop    %ebx
  80095b:	5e                   	pop    %esi
  80095c:	5f                   	pop    %edi
  80095d:	c9                   	leave  
  80095e:	c3                   	ret    

0080095f <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80095f:	55                   	push   %ebp
  800960:	89 e5                	mov    %esp,%ebp
  800962:	57                   	push   %edi
  800963:	56                   	push   %esi
  800964:	8b 45 08             	mov    0x8(%ebp),%eax
  800967:	8b 75 0c             	mov    0xc(%ebp),%esi
  80096a:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80096d:	39 c6                	cmp    %eax,%esi
  80096f:	73 34                	jae    8009a5 <memmove+0x46>
  800971:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800974:	39 d0                	cmp    %edx,%eax
  800976:	73 2d                	jae    8009a5 <memmove+0x46>
		s += n;
		d += n;
  800978:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80097b:	f6 c2 03             	test   $0x3,%dl
  80097e:	75 1b                	jne    80099b <memmove+0x3c>
  800980:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800986:	75 13                	jne    80099b <memmove+0x3c>
  800988:	f6 c1 03             	test   $0x3,%cl
  80098b:	75 0e                	jne    80099b <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  80098d:	83 ef 04             	sub    $0x4,%edi
  800990:	8d 72 fc             	lea    -0x4(%edx),%esi
  800993:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800996:	fd                   	std    
  800997:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800999:	eb 07                	jmp    8009a2 <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  80099b:	4f                   	dec    %edi
  80099c:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  80099f:	fd                   	std    
  8009a0:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009a2:	fc                   	cld    
  8009a3:	eb 20                	jmp    8009c5 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009a5:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009ab:	75 13                	jne    8009c0 <memmove+0x61>
  8009ad:	a8 03                	test   $0x3,%al
  8009af:	75 0f                	jne    8009c0 <memmove+0x61>
  8009b1:	f6 c1 03             	test   $0x3,%cl
  8009b4:	75 0a                	jne    8009c0 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8009b6:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  8009b9:	89 c7                	mov    %eax,%edi
  8009bb:	fc                   	cld    
  8009bc:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009be:	eb 05                	jmp    8009c5 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8009c0:	89 c7                	mov    %eax,%edi
  8009c2:	fc                   	cld    
  8009c3:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009c5:	5e                   	pop    %esi
  8009c6:	5f                   	pop    %edi
  8009c7:	c9                   	leave  
  8009c8:	c3                   	ret    

008009c9 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009c9:	55                   	push   %ebp
  8009ca:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8009cc:	ff 75 10             	pushl  0x10(%ebp)
  8009cf:	ff 75 0c             	pushl  0xc(%ebp)
  8009d2:	ff 75 08             	pushl  0x8(%ebp)
  8009d5:	e8 85 ff ff ff       	call   80095f <memmove>
}
  8009da:	c9                   	leave  
  8009db:	c3                   	ret    

008009dc <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009dc:	55                   	push   %ebp
  8009dd:	89 e5                	mov    %esp,%ebp
  8009df:	57                   	push   %edi
  8009e0:	56                   	push   %esi
  8009e1:	53                   	push   %ebx
  8009e2:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8009e5:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009e8:	8b 7d 10             	mov    0x10(%ebp),%edi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009eb:	85 ff                	test   %edi,%edi
  8009ed:	74 32                	je     800a21 <memcmp+0x45>
		if (*s1 != *s2)
  8009ef:	8a 03                	mov    (%ebx),%al
  8009f1:	8a 0e                	mov    (%esi),%cl
  8009f3:	38 c8                	cmp    %cl,%al
  8009f5:	74 19                	je     800a10 <memcmp+0x34>
  8009f7:	eb 0d                	jmp    800a06 <memcmp+0x2a>
  8009f9:	8a 44 13 01          	mov    0x1(%ebx,%edx,1),%al
  8009fd:	8a 4c 16 01          	mov    0x1(%esi,%edx,1),%cl
  800a01:	42                   	inc    %edx
  800a02:	38 c8                	cmp    %cl,%al
  800a04:	74 10                	je     800a16 <memcmp+0x3a>
			return (int) *s1 - (int) *s2;
  800a06:	0f b6 c0             	movzbl %al,%eax
  800a09:	0f b6 c9             	movzbl %cl,%ecx
  800a0c:	29 c8                	sub    %ecx,%eax
  800a0e:	eb 16                	jmp    800a26 <memcmp+0x4a>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a10:	4f                   	dec    %edi
  800a11:	ba 00 00 00 00       	mov    $0x0,%edx
  800a16:	39 fa                	cmp    %edi,%edx
  800a18:	75 df                	jne    8009f9 <memcmp+0x1d>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a1a:	b8 00 00 00 00       	mov    $0x0,%eax
  800a1f:	eb 05                	jmp    800a26 <memcmp+0x4a>
  800a21:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a26:	5b                   	pop    %ebx
  800a27:	5e                   	pop    %esi
  800a28:	5f                   	pop    %edi
  800a29:	c9                   	leave  
  800a2a:	c3                   	ret    

00800a2b <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a2b:	55                   	push   %ebp
  800a2c:	89 e5                	mov    %esp,%ebp
  800a2e:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800a31:	89 c2                	mov    %eax,%edx
  800a33:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a36:	39 d0                	cmp    %edx,%eax
  800a38:	73 12                	jae    800a4c <memfind+0x21>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a3a:	8a 4d 0c             	mov    0xc(%ebp),%cl
  800a3d:	38 08                	cmp    %cl,(%eax)
  800a3f:	75 06                	jne    800a47 <memfind+0x1c>
  800a41:	eb 09                	jmp    800a4c <memfind+0x21>
  800a43:	38 08                	cmp    %cl,(%eax)
  800a45:	74 05                	je     800a4c <memfind+0x21>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a47:	40                   	inc    %eax
  800a48:	39 c2                	cmp    %eax,%edx
  800a4a:	77 f7                	ja     800a43 <memfind+0x18>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a4c:	c9                   	leave  
  800a4d:	c3                   	ret    

00800a4e <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a4e:	55                   	push   %ebp
  800a4f:	89 e5                	mov    %esp,%ebp
  800a51:	57                   	push   %edi
  800a52:	56                   	push   %esi
  800a53:	53                   	push   %ebx
  800a54:	8b 55 08             	mov    0x8(%ebp),%edx
  800a57:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a5a:	eb 01                	jmp    800a5d <strtol+0xf>
		s++;
  800a5c:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a5d:	8a 02                	mov    (%edx),%al
  800a5f:	3c 20                	cmp    $0x20,%al
  800a61:	74 f9                	je     800a5c <strtol+0xe>
  800a63:	3c 09                	cmp    $0x9,%al
  800a65:	74 f5                	je     800a5c <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a67:	3c 2b                	cmp    $0x2b,%al
  800a69:	75 08                	jne    800a73 <strtol+0x25>
		s++;
  800a6b:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a6c:	bf 00 00 00 00       	mov    $0x0,%edi
  800a71:	eb 13                	jmp    800a86 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a73:	3c 2d                	cmp    $0x2d,%al
  800a75:	75 0a                	jne    800a81 <strtol+0x33>
		s++, neg = 1;
  800a77:	8d 52 01             	lea    0x1(%edx),%edx
  800a7a:	bf 01 00 00 00       	mov    $0x1,%edi
  800a7f:	eb 05                	jmp    800a86 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a81:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a86:	85 db                	test   %ebx,%ebx
  800a88:	74 05                	je     800a8f <strtol+0x41>
  800a8a:	83 fb 10             	cmp    $0x10,%ebx
  800a8d:	75 28                	jne    800ab7 <strtol+0x69>
  800a8f:	8a 02                	mov    (%edx),%al
  800a91:	3c 30                	cmp    $0x30,%al
  800a93:	75 10                	jne    800aa5 <strtol+0x57>
  800a95:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800a99:	75 0a                	jne    800aa5 <strtol+0x57>
		s += 2, base = 16;
  800a9b:	83 c2 02             	add    $0x2,%edx
  800a9e:	bb 10 00 00 00       	mov    $0x10,%ebx
  800aa3:	eb 12                	jmp    800ab7 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800aa5:	85 db                	test   %ebx,%ebx
  800aa7:	75 0e                	jne    800ab7 <strtol+0x69>
  800aa9:	3c 30                	cmp    $0x30,%al
  800aab:	75 05                	jne    800ab2 <strtol+0x64>
		s++, base = 8;
  800aad:	42                   	inc    %edx
  800aae:	b3 08                	mov    $0x8,%bl
  800ab0:	eb 05                	jmp    800ab7 <strtol+0x69>
	else if (base == 0)
		base = 10;
  800ab2:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800ab7:	b8 00 00 00 00       	mov    $0x0,%eax
  800abc:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800abe:	8a 0a                	mov    (%edx),%cl
  800ac0:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800ac3:	80 fb 09             	cmp    $0x9,%bl
  800ac6:	77 08                	ja     800ad0 <strtol+0x82>
			dig = *s - '0';
  800ac8:	0f be c9             	movsbl %cl,%ecx
  800acb:	83 e9 30             	sub    $0x30,%ecx
  800ace:	eb 1e                	jmp    800aee <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800ad0:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800ad3:	80 fb 19             	cmp    $0x19,%bl
  800ad6:	77 08                	ja     800ae0 <strtol+0x92>
			dig = *s - 'a' + 10;
  800ad8:	0f be c9             	movsbl %cl,%ecx
  800adb:	83 e9 57             	sub    $0x57,%ecx
  800ade:	eb 0e                	jmp    800aee <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800ae0:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800ae3:	80 fb 19             	cmp    $0x19,%bl
  800ae6:	77 13                	ja     800afb <strtol+0xad>
			dig = *s - 'A' + 10;
  800ae8:	0f be c9             	movsbl %cl,%ecx
  800aeb:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800aee:	39 f1                	cmp    %esi,%ecx
  800af0:	7d 0d                	jge    800aff <strtol+0xb1>
			break;
		s++, val = (val * base) + dig;
  800af2:	42                   	inc    %edx
  800af3:	0f af c6             	imul   %esi,%eax
  800af6:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  800af9:	eb c3                	jmp    800abe <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800afb:	89 c1                	mov    %eax,%ecx
  800afd:	eb 02                	jmp    800b01 <strtol+0xb3>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800aff:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800b01:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b05:	74 05                	je     800b0c <strtol+0xbe>
		*endptr = (char *) s;
  800b07:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800b0a:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800b0c:	85 ff                	test   %edi,%edi
  800b0e:	74 04                	je     800b14 <strtol+0xc6>
  800b10:	89 c8                	mov    %ecx,%eax
  800b12:	f7 d8                	neg    %eax
}
  800b14:	5b                   	pop    %ebx
  800b15:	5e                   	pop    %esi
  800b16:	5f                   	pop    %edi
  800b17:	c9                   	leave  
  800b18:	c3                   	ret    
  800b19:	00 00                	add    %al,(%eax)
	...

00800b1c <syscall>:
	return ret;
}

static int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800b1c:	55                   	push   %ebp
  800b1d:	89 e5                	mov    %esp,%ebp
  800b1f:	57                   	push   %edi
  800b20:	56                   	push   %esi
  800b21:	53                   	push   %ebx
  800b22:	83 ec 1c             	sub    $0x1c,%esp
  800b25:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800b28:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800b2b:	89 ca                	mov    %ecx,%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b2d:	8b 75 14             	mov    0x14(%ebp),%esi
  800b30:	8b 7d 10             	mov    0x10(%ebp),%edi
  800b33:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800b36:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b39:	cd 30                	int    $0x30
  800b3b:	89 c2                	mov    %eax,%edx
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b3d:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800b41:	74 1c                	je     800b5f <syscall+0x43>
  800b43:	85 c0                	test   %eax,%eax
  800b45:	7e 18                	jle    800b5f <syscall+0x43>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b47:	83 ec 0c             	sub    $0xc,%esp
  800b4a:	50                   	push   %eax
  800b4b:	ff 75 e4             	pushl  -0x1c(%ebp)
  800b4e:	68 5f 23 80 00       	push   $0x80235f
  800b53:	6a 42                	push   $0x42
  800b55:	68 7c 23 80 00       	push   $0x80237c
  800b5a:	e8 79 10 00 00       	call   801bd8 <_panic>

	return ret;
}
  800b5f:	89 d0                	mov    %edx,%eax
  800b61:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b64:	5b                   	pop    %ebx
  800b65:	5e                   	pop    %esi
  800b66:	5f                   	pop    %edi
  800b67:	c9                   	leave  
  800b68:	c3                   	ret    

00800b69 <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{	
  800b69:	55                   	push   %ebp
  800b6a:	89 e5                	mov    %esp,%ebp
  800b6c:	83 ec 08             	sub    $0x8,%esp
	// my_sysenter(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
	// return;
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  800b6f:	6a 00                	push   $0x0
  800b71:	6a 00                	push   $0x0
  800b73:	6a 00                	push   $0x0
  800b75:	ff 75 0c             	pushl  0xc(%ebp)
  800b78:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b7b:	ba 00 00 00 00       	mov    $0x0,%edx
  800b80:	b8 00 00 00 00       	mov    $0x0,%eax
  800b85:	e8 92 ff ff ff       	call   800b1c <syscall>
  800b8a:	83 c4 10             	add    $0x10,%esp
	return;
}
  800b8d:	c9                   	leave  
  800b8e:	c3                   	ret    

00800b8f <sys_cgetc>:

int
sys_cgetc(void)
{
  800b8f:	55                   	push   %ebp
  800b90:	89 e5                	mov    %esp,%ebp
  800b92:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_cgetc, 0, 0, 0, 0, 0, 0);
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  800b95:	6a 00                	push   $0x0
  800b97:	6a 00                	push   $0x0
  800b99:	6a 00                	push   $0x0
  800b9b:	6a 00                	push   $0x0
  800b9d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ba2:	ba 00 00 00 00       	mov    $0x0,%edx
  800ba7:	b8 01 00 00 00       	mov    $0x1,%eax
  800bac:	e8 6b ff ff ff       	call   800b1c <syscall>
}
  800bb1:	c9                   	leave  
  800bb2:	c3                   	ret    

00800bb3 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800bb3:	55                   	push   %ebp
  800bb4:	89 e5                	mov    %esp,%ebp
  800bb6:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  800bb9:	6a 00                	push   $0x0
  800bbb:	6a 00                	push   $0x0
  800bbd:	6a 00                	push   $0x0
  800bbf:	6a 00                	push   $0x0
  800bc1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800bc4:	ba 01 00 00 00       	mov    $0x1,%edx
  800bc9:	b8 03 00 00 00       	mov    $0x3,%eax
  800bce:	e8 49 ff ff ff       	call   800b1c <syscall>
}
  800bd3:	c9                   	leave  
  800bd4:	c3                   	ret    

00800bd5 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800bd5:	55                   	push   %ebp
  800bd6:	89 e5                	mov    %esp,%ebp
  800bd8:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_getenvid, 0, 0, 0, 0, 0, 0);
	return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  800bdb:	6a 00                	push   $0x0
  800bdd:	6a 00                	push   $0x0
  800bdf:	6a 00                	push   $0x0
  800be1:	6a 00                	push   $0x0
  800be3:	b9 00 00 00 00       	mov    $0x0,%ecx
  800be8:	ba 00 00 00 00       	mov    $0x0,%edx
  800bed:	b8 02 00 00 00       	mov    $0x2,%eax
  800bf2:	e8 25 ff ff ff       	call   800b1c <syscall>
}
  800bf7:	c9                   	leave  
  800bf8:	c3                   	ret    

00800bf9 <sys_yield>:

void
sys_yield(void)
{
  800bf9:	55                   	push   %ebp
  800bfa:	89 e5                	mov    %esp,%ebp
  800bfc:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  800bff:	6a 00                	push   $0x0
  800c01:	6a 00                	push   $0x0
  800c03:	6a 00                	push   $0x0
  800c05:	6a 00                	push   $0x0
  800c07:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c0c:	ba 00 00 00 00       	mov    $0x0,%edx
  800c11:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c16:	e8 01 ff ff ff       	call   800b1c <syscall>
  800c1b:	83 c4 10             	add    $0x10,%esp
}
  800c1e:	c9                   	leave  
  800c1f:	c3                   	ret    

00800c20 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c20:	55                   	push   %ebp
  800c21:	89 e5                	mov    %esp,%ebp
  800c23:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  800c26:	6a 00                	push   $0x0
  800c28:	6a 00                	push   $0x0
  800c2a:	ff 75 10             	pushl  0x10(%ebp)
  800c2d:	ff 75 0c             	pushl  0xc(%ebp)
  800c30:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c33:	ba 01 00 00 00       	mov    $0x1,%edx
  800c38:	b8 04 00 00 00       	mov    $0x4,%eax
  800c3d:	e8 da fe ff ff       	call   800b1c <syscall>
}
  800c42:	c9                   	leave  
  800c43:	c3                   	ret    

00800c44 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c44:	55                   	push   %ebp
  800c45:	89 e5                	mov    %esp,%ebp
  800c47:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
  800c4a:	ff 75 18             	pushl  0x18(%ebp)
  800c4d:	ff 75 14             	pushl  0x14(%ebp)
  800c50:	ff 75 10             	pushl  0x10(%ebp)
  800c53:	ff 75 0c             	pushl  0xc(%ebp)
  800c56:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c59:	ba 01 00 00 00       	mov    $0x1,%edx
  800c5e:	b8 05 00 00 00       	mov    $0x5,%eax
  800c63:	e8 b4 fe ff ff       	call   800b1c <syscall>
}
  800c68:	c9                   	leave  
  800c69:	c3                   	ret    

00800c6a <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c6a:	55                   	push   %ebp
  800c6b:	89 e5                	mov    %esp,%ebp
  800c6d:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  800c70:	6a 00                	push   $0x0
  800c72:	6a 00                	push   $0x0
  800c74:	6a 00                	push   $0x0
  800c76:	ff 75 0c             	pushl  0xc(%ebp)
  800c79:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c7c:	ba 01 00 00 00       	mov    $0x1,%edx
  800c81:	b8 06 00 00 00       	mov    $0x6,%eax
  800c86:	e8 91 fe ff ff       	call   800b1c <syscall>
}
  800c8b:	c9                   	leave  
  800c8c:	c3                   	ret    

00800c8d <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c8d:	55                   	push   %ebp
  800c8e:	89 e5                	mov    %esp,%ebp
  800c90:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  800c93:	6a 00                	push   $0x0
  800c95:	6a 00                	push   $0x0
  800c97:	6a 00                	push   $0x0
  800c99:	ff 75 0c             	pushl  0xc(%ebp)
  800c9c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c9f:	ba 01 00 00 00       	mov    $0x1,%edx
  800ca4:	b8 08 00 00 00       	mov    $0x8,%eax
  800ca9:	e8 6e fe ff ff       	call   800b1c <syscall>
}
  800cae:	c9                   	leave  
  800caf:	c3                   	ret    

00800cb0 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800cb0:	55                   	push   %ebp
  800cb1:	89 e5                	mov    %esp,%ebp
  800cb3:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
  800cb6:	6a 00                	push   $0x0
  800cb8:	6a 00                	push   $0x0
  800cba:	6a 00                	push   $0x0
  800cbc:	ff 75 0c             	pushl  0xc(%ebp)
  800cbf:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800cc2:	ba 01 00 00 00       	mov    $0x1,%edx
  800cc7:	b8 09 00 00 00       	mov    $0x9,%eax
  800ccc:	e8 4b fe ff ff       	call   800b1c <syscall>
}
  800cd1:	c9                   	leave  
  800cd2:	c3                   	ret    

00800cd3 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800cd3:	55                   	push   %ebp
  800cd4:	89 e5                	mov    %esp,%ebp
  800cd6:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  800cd9:	6a 00                	push   $0x0
  800cdb:	6a 00                	push   $0x0
  800cdd:	6a 00                	push   $0x0
  800cdf:	ff 75 0c             	pushl  0xc(%ebp)
  800ce2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ce5:	ba 01 00 00 00       	mov    $0x1,%edx
  800cea:	b8 0a 00 00 00       	mov    $0xa,%eax
  800cef:	e8 28 fe ff ff       	call   800b1c <syscall>
}
  800cf4:	c9                   	leave  
  800cf5:	c3                   	ret    

00800cf6 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800cf6:	55                   	push   %ebp
  800cf7:	89 e5                	mov    %esp,%ebp
  800cf9:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  800cfc:	6a 00                	push   $0x0
  800cfe:	ff 75 14             	pushl  0x14(%ebp)
  800d01:	ff 75 10             	pushl  0x10(%ebp)
  800d04:	ff 75 0c             	pushl  0xc(%ebp)
  800d07:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d0a:	ba 00 00 00 00       	mov    $0x0,%edx
  800d0f:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d14:	e8 03 fe ff ff       	call   800b1c <syscall>
}
  800d19:	c9                   	leave  
  800d1a:	c3                   	ret    

00800d1b <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d1b:	55                   	push   %ebp
  800d1c:	89 e5                	mov    %esp,%ebp
  800d1e:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  800d21:	6a 00                	push   $0x0
  800d23:	6a 00                	push   $0x0
  800d25:	6a 00                	push   $0x0
  800d27:	6a 00                	push   $0x0
  800d29:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d2c:	ba 01 00 00 00       	mov    $0x1,%edx
  800d31:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d36:	e8 e1 fd ff ff       	call   800b1c <syscall>
}
  800d3b:	c9                   	leave  
  800d3c:	c3                   	ret    

00800d3d <sys_set_priority>:

int
sys_set_priority(envid_t envid, uint32_t new_priority)
{
  800d3d:	55                   	push   %ebp
  800d3e:	89 e5                	mov    %esp,%ebp
  800d40:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_set_priority, 0, envid, new_priority, 0, 0, 0);
  800d43:	6a 00                	push   $0x0
  800d45:	6a 00                	push   $0x0
  800d47:	6a 00                	push   $0x0
  800d49:	ff 75 0c             	pushl  0xc(%ebp)
  800d4c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d4f:	ba 00 00 00 00       	mov    $0x0,%edx
  800d54:	b8 0e 00 00 00       	mov    $0xe,%eax
  800d59:	e8 be fd ff ff       	call   800b1c <syscall>
}
  800d5e:	c9                   	leave  
  800d5f:	c3                   	ret    

00800d60 <sys_exec>:

int
sys_exec(uint32_t eip, uint32_t esp, void * ph, uint32_t elf_phnum)
{
  800d60:	55                   	push   %ebp
  800d61:	89 e5                	mov    %esp,%ebp
  800d63:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_exec, 0, eip, esp, (uint32_t)ph, elf_phnum, 0);
  800d66:	6a 00                	push   $0x0
  800d68:	ff 75 14             	pushl  0x14(%ebp)
  800d6b:	ff 75 10             	pushl  0x10(%ebp)
  800d6e:	ff 75 0c             	pushl  0xc(%ebp)
  800d71:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d74:	ba 00 00 00 00       	mov    $0x0,%edx
  800d79:	b8 0f 00 00 00       	mov    $0xf,%eax
  800d7e:	e8 99 fd ff ff       	call   800b1c <syscall>
} 
  800d83:	c9                   	leave  
  800d84:	c3                   	ret    

00800d85 <sys_join>:

// thread:
int
sys_join(envid_t envid)
{
  800d85:	55                   	push   %ebp
  800d86:	89 e5                	mov    %esp,%ebp
  800d88:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_join, 0, envid, 0, 0, 0, 0);
  800d8b:	6a 00                	push   $0x0
  800d8d:	6a 00                	push   $0x0
  800d8f:	6a 00                	push   $0x0
  800d91:	6a 00                	push   $0x0
  800d93:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d96:	ba 00 00 00 00       	mov    $0x0,%edx
  800d9b:	b8 11 00 00 00       	mov    $0x11,%eax
  800da0:	e8 77 fd ff ff       	call   800b1c <syscall>
}
  800da5:	c9                   	leave  
  800da6:	c3                   	ret    

00800da7 <sys_getpid>:

envid_t
sys_getpid(void)
{
  800da7:	55                   	push   %ebp
  800da8:	89 e5                	mov    %esp,%ebp
  800daa:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_getpid, 0, 0, 0, 0, 0, 0);
  800dad:	6a 00                	push   $0x0
  800daf:	6a 00                	push   $0x0
  800db1:	6a 00                	push   $0x0
  800db3:	6a 00                	push   $0x0
  800db5:	b9 00 00 00 00       	mov    $0x0,%ecx
  800dba:	ba 00 00 00 00       	mov    $0x0,%edx
  800dbf:	b8 10 00 00 00       	mov    $0x10,%eax
  800dc4:	e8 53 fd ff ff       	call   800b1c <syscall>
  800dc9:	c9                   	leave  
  800dca:	c3                   	ret    
	...

00800dcc <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800dcc:	55                   	push   %ebp
  800dcd:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800dcf:	8b 45 08             	mov    0x8(%ebp),%eax
  800dd2:	05 00 00 00 30       	add    $0x30000000,%eax
  800dd7:	c1 e8 0c             	shr    $0xc,%eax
}
  800dda:	c9                   	leave  
  800ddb:	c3                   	ret    

00800ddc <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800ddc:	55                   	push   %ebp
  800ddd:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800ddf:	ff 75 08             	pushl  0x8(%ebp)
  800de2:	e8 e5 ff ff ff       	call   800dcc <fd2num>
  800de7:	83 c4 04             	add    $0x4,%esp
  800dea:	05 20 00 0d 00       	add    $0xd0020,%eax
  800def:	c1 e0 0c             	shl    $0xc,%eax
}
  800df2:	c9                   	leave  
  800df3:	c3                   	ret    

00800df4 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800df4:	55                   	push   %ebp
  800df5:	89 e5                	mov    %esp,%ebp
  800df7:	53                   	push   %ebx
  800df8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800dfb:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  800e00:	a8 01                	test   $0x1,%al
  800e02:	74 34                	je     800e38 <fd_alloc+0x44>
  800e04:	a1 00 00 74 ef       	mov    0xef740000,%eax
  800e09:	a8 01                	test   $0x1,%al
  800e0b:	74 32                	je     800e3f <fd_alloc+0x4b>
  800e0d:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
  800e12:	89 c1                	mov    %eax,%ecx
  800e14:	89 c2                	mov    %eax,%edx
  800e16:	c1 ea 16             	shr    $0x16,%edx
  800e19:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800e20:	f6 c2 01             	test   $0x1,%dl
  800e23:	74 1f                	je     800e44 <fd_alloc+0x50>
  800e25:	89 c2                	mov    %eax,%edx
  800e27:	c1 ea 0c             	shr    $0xc,%edx
  800e2a:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e31:	f6 c2 01             	test   $0x1,%dl
  800e34:	75 17                	jne    800e4d <fd_alloc+0x59>
  800e36:	eb 0c                	jmp    800e44 <fd_alloc+0x50>
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  800e38:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
  800e3d:	eb 05                	jmp    800e44 <fd_alloc+0x50>
  800e3f:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
  800e44:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  800e46:	b8 00 00 00 00       	mov    $0x0,%eax
  800e4b:	eb 17                	jmp    800e64 <fd_alloc+0x70>
  800e4d:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800e52:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800e57:	75 b9                	jne    800e12 <fd_alloc+0x1e>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800e59:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  800e5f:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800e64:	5b                   	pop    %ebx
  800e65:	c9                   	leave  
  800e66:	c3                   	ret    

00800e67 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800e67:	55                   	push   %ebp
  800e68:	89 e5                	mov    %esp,%ebp
  800e6a:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800e6d:	83 f8 1f             	cmp    $0x1f,%eax
  800e70:	77 36                	ja     800ea8 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800e72:	05 00 00 0d 00       	add    $0xd0000,%eax
  800e77:	c1 e0 0c             	shl    $0xc,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800e7a:	89 c2                	mov    %eax,%edx
  800e7c:	c1 ea 16             	shr    $0x16,%edx
  800e7f:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800e86:	f6 c2 01             	test   $0x1,%dl
  800e89:	74 24                	je     800eaf <fd_lookup+0x48>
  800e8b:	89 c2                	mov    %eax,%edx
  800e8d:	c1 ea 0c             	shr    $0xc,%edx
  800e90:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e97:	f6 c2 01             	test   $0x1,%dl
  800e9a:	74 1a                	je     800eb6 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800e9c:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e9f:	89 02                	mov    %eax,(%edx)
	return 0;
  800ea1:	b8 00 00 00 00       	mov    $0x0,%eax
  800ea6:	eb 13                	jmp    800ebb <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800ea8:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800ead:	eb 0c                	jmp    800ebb <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800eaf:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800eb4:	eb 05                	jmp    800ebb <fd_lookup+0x54>
  800eb6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800ebb:	c9                   	leave  
  800ebc:	c3                   	ret    

00800ebd <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800ebd:	55                   	push   %ebp
  800ebe:	89 e5                	mov    %esp,%ebp
  800ec0:	53                   	push   %ebx
  800ec1:	83 ec 04             	sub    $0x4,%esp
  800ec4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ec7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  800eca:	39 0d 04 30 80 00    	cmp    %ecx,0x803004
  800ed0:	74 0d                	je     800edf <dev_lookup+0x22>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800ed2:	b8 00 00 00 00       	mov    $0x0,%eax
  800ed7:	eb 14                	jmp    800eed <dev_lookup+0x30>
		if (devtab[i]->dev_id == dev_id) {
  800ed9:	39 0a                	cmp    %ecx,(%edx)
  800edb:	75 10                	jne    800eed <dev_lookup+0x30>
  800edd:	eb 05                	jmp    800ee4 <dev_lookup+0x27>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800edf:	ba 04 30 80 00       	mov    $0x803004,%edx
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
  800ee4:	89 13                	mov    %edx,(%ebx)
			return 0;
  800ee6:	b8 00 00 00 00       	mov    $0x0,%eax
  800eeb:	eb 31                	jmp    800f1e <dev_lookup+0x61>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800eed:	40                   	inc    %eax
  800eee:	8b 14 85 08 24 80 00 	mov    0x802408(,%eax,4),%edx
  800ef5:	85 d2                	test   %edx,%edx
  800ef7:	75 e0                	jne    800ed9 <dev_lookup+0x1c>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800ef9:	a1 10 40 80 00       	mov    0x804010,%eax
  800efe:	8b 40 48             	mov    0x48(%eax),%eax
  800f01:	83 ec 04             	sub    $0x4,%esp
  800f04:	51                   	push   %ecx
  800f05:	50                   	push   %eax
  800f06:	68 8c 23 80 00       	push   $0x80238c
  800f0b:	e8 d8 f2 ff ff       	call   8001e8 <cprintf>
	*dev = 0;
  800f10:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  800f16:	83 c4 10             	add    $0x10,%esp
  800f19:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800f1e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f21:	c9                   	leave  
  800f22:	c3                   	ret    

00800f23 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800f23:	55                   	push   %ebp
  800f24:	89 e5                	mov    %esp,%ebp
  800f26:	56                   	push   %esi
  800f27:	53                   	push   %ebx
  800f28:	83 ec 20             	sub    $0x20,%esp
  800f2b:	8b 75 08             	mov    0x8(%ebp),%esi
  800f2e:	8a 45 0c             	mov    0xc(%ebp),%al
  800f31:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800f34:	56                   	push   %esi
  800f35:	e8 92 fe ff ff       	call   800dcc <fd2num>
  800f3a:	8d 55 f4             	lea    -0xc(%ebp),%edx
  800f3d:	89 14 24             	mov    %edx,(%esp)
  800f40:	50                   	push   %eax
  800f41:	e8 21 ff ff ff       	call   800e67 <fd_lookup>
  800f46:	89 c3                	mov    %eax,%ebx
  800f48:	83 c4 08             	add    $0x8,%esp
  800f4b:	85 c0                	test   %eax,%eax
  800f4d:	78 05                	js     800f54 <fd_close+0x31>
	    || fd != fd2)
  800f4f:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800f52:	74 0d                	je     800f61 <fd_close+0x3e>
		return (must_exist ? r : 0);
  800f54:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  800f58:	75 48                	jne    800fa2 <fd_close+0x7f>
  800f5a:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f5f:	eb 41                	jmp    800fa2 <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800f61:	83 ec 08             	sub    $0x8,%esp
  800f64:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800f67:	50                   	push   %eax
  800f68:	ff 36                	pushl  (%esi)
  800f6a:	e8 4e ff ff ff       	call   800ebd <dev_lookup>
  800f6f:	89 c3                	mov    %eax,%ebx
  800f71:	83 c4 10             	add    $0x10,%esp
  800f74:	85 c0                	test   %eax,%eax
  800f76:	78 1c                	js     800f94 <fd_close+0x71>
		if (dev->dev_close)
  800f78:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800f7b:	8b 40 10             	mov    0x10(%eax),%eax
  800f7e:	85 c0                	test   %eax,%eax
  800f80:	74 0d                	je     800f8f <fd_close+0x6c>
			r = (*dev->dev_close)(fd);
  800f82:	83 ec 0c             	sub    $0xc,%esp
  800f85:	56                   	push   %esi
  800f86:	ff d0                	call   *%eax
  800f88:	89 c3                	mov    %eax,%ebx
  800f8a:	83 c4 10             	add    $0x10,%esp
  800f8d:	eb 05                	jmp    800f94 <fd_close+0x71>
		else
			r = 0;
  800f8f:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800f94:	83 ec 08             	sub    $0x8,%esp
  800f97:	56                   	push   %esi
  800f98:	6a 00                	push   $0x0
  800f9a:	e8 cb fc ff ff       	call   800c6a <sys_page_unmap>
	return r;
  800f9f:	83 c4 10             	add    $0x10,%esp
}
  800fa2:	89 d8                	mov    %ebx,%eax
  800fa4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800fa7:	5b                   	pop    %ebx
  800fa8:	5e                   	pop    %esi
  800fa9:	c9                   	leave  
  800faa:	c3                   	ret    

00800fab <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800fab:	55                   	push   %ebp
  800fac:	89 e5                	mov    %esp,%ebp
  800fae:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800fb1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fb4:	50                   	push   %eax
  800fb5:	ff 75 08             	pushl  0x8(%ebp)
  800fb8:	e8 aa fe ff ff       	call   800e67 <fd_lookup>
  800fbd:	83 c4 08             	add    $0x8,%esp
  800fc0:	85 c0                	test   %eax,%eax
  800fc2:	78 10                	js     800fd4 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800fc4:	83 ec 08             	sub    $0x8,%esp
  800fc7:	6a 01                	push   $0x1
  800fc9:	ff 75 f4             	pushl  -0xc(%ebp)
  800fcc:	e8 52 ff ff ff       	call   800f23 <fd_close>
  800fd1:	83 c4 10             	add    $0x10,%esp
}
  800fd4:	c9                   	leave  
  800fd5:	c3                   	ret    

00800fd6 <close_all>:

void
close_all(void)
{
  800fd6:	55                   	push   %ebp
  800fd7:	89 e5                	mov    %esp,%ebp
  800fd9:	53                   	push   %ebx
  800fda:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800fdd:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800fe2:	83 ec 0c             	sub    $0xc,%esp
  800fe5:	53                   	push   %ebx
  800fe6:	e8 c0 ff ff ff       	call   800fab <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800feb:	43                   	inc    %ebx
  800fec:	83 c4 10             	add    $0x10,%esp
  800fef:	83 fb 20             	cmp    $0x20,%ebx
  800ff2:	75 ee                	jne    800fe2 <close_all+0xc>
		close(i);
}
  800ff4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ff7:	c9                   	leave  
  800ff8:	c3                   	ret    

00800ff9 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800ff9:	55                   	push   %ebp
  800ffa:	89 e5                	mov    %esp,%ebp
  800ffc:	57                   	push   %edi
  800ffd:	56                   	push   %esi
  800ffe:	53                   	push   %ebx
  800fff:	83 ec 2c             	sub    $0x2c,%esp
  801002:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801005:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801008:	50                   	push   %eax
  801009:	ff 75 08             	pushl  0x8(%ebp)
  80100c:	e8 56 fe ff ff       	call   800e67 <fd_lookup>
  801011:	89 c3                	mov    %eax,%ebx
  801013:	83 c4 08             	add    $0x8,%esp
  801016:	85 c0                	test   %eax,%eax
  801018:	0f 88 c0 00 00 00    	js     8010de <dup+0xe5>
		return r;
	close(newfdnum);
  80101e:	83 ec 0c             	sub    $0xc,%esp
  801021:	57                   	push   %edi
  801022:	e8 84 ff ff ff       	call   800fab <close>

	newfd = INDEX2FD(newfdnum);
  801027:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  80102d:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  801030:	83 c4 04             	add    $0x4,%esp
  801033:	ff 75 e4             	pushl  -0x1c(%ebp)
  801036:	e8 a1 fd ff ff       	call   800ddc <fd2data>
  80103b:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  80103d:	89 34 24             	mov    %esi,(%esp)
  801040:	e8 97 fd ff ff       	call   800ddc <fd2data>
  801045:	83 c4 10             	add    $0x10,%esp
  801048:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80104b:	89 d8                	mov    %ebx,%eax
  80104d:	c1 e8 16             	shr    $0x16,%eax
  801050:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801057:	a8 01                	test   $0x1,%al
  801059:	74 37                	je     801092 <dup+0x99>
  80105b:	89 d8                	mov    %ebx,%eax
  80105d:	c1 e8 0c             	shr    $0xc,%eax
  801060:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801067:	f6 c2 01             	test   $0x1,%dl
  80106a:	74 26                	je     801092 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80106c:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801073:	83 ec 0c             	sub    $0xc,%esp
  801076:	25 07 0e 00 00       	and    $0xe07,%eax
  80107b:	50                   	push   %eax
  80107c:	ff 75 d4             	pushl  -0x2c(%ebp)
  80107f:	6a 00                	push   $0x0
  801081:	53                   	push   %ebx
  801082:	6a 00                	push   $0x0
  801084:	e8 bb fb ff ff       	call   800c44 <sys_page_map>
  801089:	89 c3                	mov    %eax,%ebx
  80108b:	83 c4 20             	add    $0x20,%esp
  80108e:	85 c0                	test   %eax,%eax
  801090:	78 2d                	js     8010bf <dup+0xc6>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801092:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801095:	89 c2                	mov    %eax,%edx
  801097:	c1 ea 0c             	shr    $0xc,%edx
  80109a:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8010a1:	83 ec 0c             	sub    $0xc,%esp
  8010a4:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  8010aa:	52                   	push   %edx
  8010ab:	56                   	push   %esi
  8010ac:	6a 00                	push   $0x0
  8010ae:	50                   	push   %eax
  8010af:	6a 00                	push   $0x0
  8010b1:	e8 8e fb ff ff       	call   800c44 <sys_page_map>
  8010b6:	89 c3                	mov    %eax,%ebx
  8010b8:	83 c4 20             	add    $0x20,%esp
  8010bb:	85 c0                	test   %eax,%eax
  8010bd:	79 1d                	jns    8010dc <dup+0xe3>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8010bf:	83 ec 08             	sub    $0x8,%esp
  8010c2:	56                   	push   %esi
  8010c3:	6a 00                	push   $0x0
  8010c5:	e8 a0 fb ff ff       	call   800c6a <sys_page_unmap>
	sys_page_unmap(0, nva);
  8010ca:	83 c4 08             	add    $0x8,%esp
  8010cd:	ff 75 d4             	pushl  -0x2c(%ebp)
  8010d0:	6a 00                	push   $0x0
  8010d2:	e8 93 fb ff ff       	call   800c6a <sys_page_unmap>
	return r;
  8010d7:	83 c4 10             	add    $0x10,%esp
  8010da:	eb 02                	jmp    8010de <dup+0xe5>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  8010dc:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  8010de:	89 d8                	mov    %ebx,%eax
  8010e0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010e3:	5b                   	pop    %ebx
  8010e4:	5e                   	pop    %esi
  8010e5:	5f                   	pop    %edi
  8010e6:	c9                   	leave  
  8010e7:	c3                   	ret    

008010e8 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8010e8:	55                   	push   %ebp
  8010e9:	89 e5                	mov    %esp,%ebp
  8010eb:	53                   	push   %ebx
  8010ec:	83 ec 14             	sub    $0x14,%esp
  8010ef:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8010f2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8010f5:	50                   	push   %eax
  8010f6:	53                   	push   %ebx
  8010f7:	e8 6b fd ff ff       	call   800e67 <fd_lookup>
  8010fc:	83 c4 08             	add    $0x8,%esp
  8010ff:	85 c0                	test   %eax,%eax
  801101:	78 67                	js     80116a <read+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801103:	83 ec 08             	sub    $0x8,%esp
  801106:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801109:	50                   	push   %eax
  80110a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80110d:	ff 30                	pushl  (%eax)
  80110f:	e8 a9 fd ff ff       	call   800ebd <dev_lookup>
  801114:	83 c4 10             	add    $0x10,%esp
  801117:	85 c0                	test   %eax,%eax
  801119:	78 4f                	js     80116a <read+0x82>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80111b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80111e:	8b 50 08             	mov    0x8(%eax),%edx
  801121:	83 e2 03             	and    $0x3,%edx
  801124:	83 fa 01             	cmp    $0x1,%edx
  801127:	75 21                	jne    80114a <read+0x62>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801129:	a1 10 40 80 00       	mov    0x804010,%eax
  80112e:	8b 40 48             	mov    0x48(%eax),%eax
  801131:	83 ec 04             	sub    $0x4,%esp
  801134:	53                   	push   %ebx
  801135:	50                   	push   %eax
  801136:	68 cd 23 80 00       	push   $0x8023cd
  80113b:	e8 a8 f0 ff ff       	call   8001e8 <cprintf>
		return -E_INVAL;
  801140:	83 c4 10             	add    $0x10,%esp
  801143:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801148:	eb 20                	jmp    80116a <read+0x82>
	}
	if (!dev->dev_read)
  80114a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80114d:	8b 52 08             	mov    0x8(%edx),%edx
  801150:	85 d2                	test   %edx,%edx
  801152:	74 11                	je     801165 <read+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801154:	83 ec 04             	sub    $0x4,%esp
  801157:	ff 75 10             	pushl  0x10(%ebp)
  80115a:	ff 75 0c             	pushl  0xc(%ebp)
  80115d:	50                   	push   %eax
  80115e:	ff d2                	call   *%edx
  801160:	83 c4 10             	add    $0x10,%esp
  801163:	eb 05                	jmp    80116a <read+0x82>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801165:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  80116a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80116d:	c9                   	leave  
  80116e:	c3                   	ret    

0080116f <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80116f:	55                   	push   %ebp
  801170:	89 e5                	mov    %esp,%ebp
  801172:	57                   	push   %edi
  801173:	56                   	push   %esi
  801174:	53                   	push   %ebx
  801175:	83 ec 0c             	sub    $0xc,%esp
  801178:	8b 7d 08             	mov    0x8(%ebp),%edi
  80117b:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80117e:	85 f6                	test   %esi,%esi
  801180:	74 31                	je     8011b3 <readn+0x44>
  801182:	b8 00 00 00 00       	mov    $0x0,%eax
  801187:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = read(fdnum, (char*)buf + tot, n - tot);
  80118c:	83 ec 04             	sub    $0x4,%esp
  80118f:	89 f2                	mov    %esi,%edx
  801191:	29 c2                	sub    %eax,%edx
  801193:	52                   	push   %edx
  801194:	03 45 0c             	add    0xc(%ebp),%eax
  801197:	50                   	push   %eax
  801198:	57                   	push   %edi
  801199:	e8 4a ff ff ff       	call   8010e8 <read>
		if (m < 0)
  80119e:	83 c4 10             	add    $0x10,%esp
  8011a1:	85 c0                	test   %eax,%eax
  8011a3:	78 17                	js     8011bc <readn+0x4d>
			return m;
		if (m == 0)
  8011a5:	85 c0                	test   %eax,%eax
  8011a7:	74 11                	je     8011ba <readn+0x4b>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8011a9:	01 c3                	add    %eax,%ebx
  8011ab:	89 d8                	mov    %ebx,%eax
  8011ad:	39 f3                	cmp    %esi,%ebx
  8011af:	72 db                	jb     80118c <readn+0x1d>
  8011b1:	eb 09                	jmp    8011bc <readn+0x4d>
  8011b3:	b8 00 00 00 00       	mov    $0x0,%eax
  8011b8:	eb 02                	jmp    8011bc <readn+0x4d>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  8011ba:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  8011bc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011bf:	5b                   	pop    %ebx
  8011c0:	5e                   	pop    %esi
  8011c1:	5f                   	pop    %edi
  8011c2:	c9                   	leave  
  8011c3:	c3                   	ret    

008011c4 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8011c4:	55                   	push   %ebp
  8011c5:	89 e5                	mov    %esp,%ebp
  8011c7:	53                   	push   %ebx
  8011c8:	83 ec 14             	sub    $0x14,%esp
  8011cb:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8011ce:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011d1:	50                   	push   %eax
  8011d2:	53                   	push   %ebx
  8011d3:	e8 8f fc ff ff       	call   800e67 <fd_lookup>
  8011d8:	83 c4 08             	add    $0x8,%esp
  8011db:	85 c0                	test   %eax,%eax
  8011dd:	78 62                	js     801241 <write+0x7d>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011df:	83 ec 08             	sub    $0x8,%esp
  8011e2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011e5:	50                   	push   %eax
  8011e6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011e9:	ff 30                	pushl  (%eax)
  8011eb:	e8 cd fc ff ff       	call   800ebd <dev_lookup>
  8011f0:	83 c4 10             	add    $0x10,%esp
  8011f3:	85 c0                	test   %eax,%eax
  8011f5:	78 4a                	js     801241 <write+0x7d>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8011f7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011fa:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8011fe:	75 21                	jne    801221 <write+0x5d>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801200:	a1 10 40 80 00       	mov    0x804010,%eax
  801205:	8b 40 48             	mov    0x48(%eax),%eax
  801208:	83 ec 04             	sub    $0x4,%esp
  80120b:	53                   	push   %ebx
  80120c:	50                   	push   %eax
  80120d:	68 e9 23 80 00       	push   $0x8023e9
  801212:	e8 d1 ef ff ff       	call   8001e8 <cprintf>
		return -E_INVAL;
  801217:	83 c4 10             	add    $0x10,%esp
  80121a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80121f:	eb 20                	jmp    801241 <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801221:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801224:	8b 52 0c             	mov    0xc(%edx),%edx
  801227:	85 d2                	test   %edx,%edx
  801229:	74 11                	je     80123c <write+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80122b:	83 ec 04             	sub    $0x4,%esp
  80122e:	ff 75 10             	pushl  0x10(%ebp)
  801231:	ff 75 0c             	pushl  0xc(%ebp)
  801234:	50                   	push   %eax
  801235:	ff d2                	call   *%edx
  801237:	83 c4 10             	add    $0x10,%esp
  80123a:	eb 05                	jmp    801241 <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80123c:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  801241:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801244:	c9                   	leave  
  801245:	c3                   	ret    

00801246 <seek>:

int
seek(int fdnum, off_t offset)
{
  801246:	55                   	push   %ebp
  801247:	89 e5                	mov    %esp,%ebp
  801249:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80124c:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80124f:	50                   	push   %eax
  801250:	ff 75 08             	pushl  0x8(%ebp)
  801253:	e8 0f fc ff ff       	call   800e67 <fd_lookup>
  801258:	83 c4 08             	add    $0x8,%esp
  80125b:	85 c0                	test   %eax,%eax
  80125d:	78 0e                	js     80126d <seek+0x27>
		return r;
	fd->fd_offset = offset;
  80125f:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801262:	8b 55 0c             	mov    0xc(%ebp),%edx
  801265:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801268:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80126d:	c9                   	leave  
  80126e:	c3                   	ret    

0080126f <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80126f:	55                   	push   %ebp
  801270:	89 e5                	mov    %esp,%ebp
  801272:	53                   	push   %ebx
  801273:	83 ec 14             	sub    $0x14,%esp
  801276:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801279:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80127c:	50                   	push   %eax
  80127d:	53                   	push   %ebx
  80127e:	e8 e4 fb ff ff       	call   800e67 <fd_lookup>
  801283:	83 c4 08             	add    $0x8,%esp
  801286:	85 c0                	test   %eax,%eax
  801288:	78 5f                	js     8012e9 <ftruncate+0x7a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80128a:	83 ec 08             	sub    $0x8,%esp
  80128d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801290:	50                   	push   %eax
  801291:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801294:	ff 30                	pushl  (%eax)
  801296:	e8 22 fc ff ff       	call   800ebd <dev_lookup>
  80129b:	83 c4 10             	add    $0x10,%esp
  80129e:	85 c0                	test   %eax,%eax
  8012a0:	78 47                	js     8012e9 <ftruncate+0x7a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8012a2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012a5:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8012a9:	75 21                	jne    8012cc <ftruncate+0x5d>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8012ab:	a1 10 40 80 00       	mov    0x804010,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8012b0:	8b 40 48             	mov    0x48(%eax),%eax
  8012b3:	83 ec 04             	sub    $0x4,%esp
  8012b6:	53                   	push   %ebx
  8012b7:	50                   	push   %eax
  8012b8:	68 ac 23 80 00       	push   $0x8023ac
  8012bd:	e8 26 ef ff ff       	call   8001e8 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8012c2:	83 c4 10             	add    $0x10,%esp
  8012c5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012ca:	eb 1d                	jmp    8012e9 <ftruncate+0x7a>
	}
	if (!dev->dev_trunc)
  8012cc:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8012cf:	8b 52 18             	mov    0x18(%edx),%edx
  8012d2:	85 d2                	test   %edx,%edx
  8012d4:	74 0e                	je     8012e4 <ftruncate+0x75>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8012d6:	83 ec 08             	sub    $0x8,%esp
  8012d9:	ff 75 0c             	pushl  0xc(%ebp)
  8012dc:	50                   	push   %eax
  8012dd:	ff d2                	call   *%edx
  8012df:	83 c4 10             	add    $0x10,%esp
  8012e2:	eb 05                	jmp    8012e9 <ftruncate+0x7a>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8012e4:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  8012e9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012ec:	c9                   	leave  
  8012ed:	c3                   	ret    

008012ee <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8012ee:	55                   	push   %ebp
  8012ef:	89 e5                	mov    %esp,%ebp
  8012f1:	53                   	push   %ebx
  8012f2:	83 ec 14             	sub    $0x14,%esp
  8012f5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8012f8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012fb:	50                   	push   %eax
  8012fc:	ff 75 08             	pushl  0x8(%ebp)
  8012ff:	e8 63 fb ff ff       	call   800e67 <fd_lookup>
  801304:	83 c4 08             	add    $0x8,%esp
  801307:	85 c0                	test   %eax,%eax
  801309:	78 52                	js     80135d <fstat+0x6f>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80130b:	83 ec 08             	sub    $0x8,%esp
  80130e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801311:	50                   	push   %eax
  801312:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801315:	ff 30                	pushl  (%eax)
  801317:	e8 a1 fb ff ff       	call   800ebd <dev_lookup>
  80131c:	83 c4 10             	add    $0x10,%esp
  80131f:	85 c0                	test   %eax,%eax
  801321:	78 3a                	js     80135d <fstat+0x6f>
		return r;
	if (!dev->dev_stat)
  801323:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801326:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80132a:	74 2c                	je     801358 <fstat+0x6a>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80132c:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80132f:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801336:	00 00 00 
	stat->st_isdir = 0;
  801339:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801340:	00 00 00 
	stat->st_dev = dev;
  801343:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801349:	83 ec 08             	sub    $0x8,%esp
  80134c:	53                   	push   %ebx
  80134d:	ff 75 f0             	pushl  -0x10(%ebp)
  801350:	ff 50 14             	call   *0x14(%eax)
  801353:	83 c4 10             	add    $0x10,%esp
  801356:	eb 05                	jmp    80135d <fstat+0x6f>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801358:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  80135d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801360:	c9                   	leave  
  801361:	c3                   	ret    

00801362 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801362:	55                   	push   %ebp
  801363:	89 e5                	mov    %esp,%ebp
  801365:	56                   	push   %esi
  801366:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801367:	83 ec 08             	sub    $0x8,%esp
  80136a:	6a 00                	push   $0x0
  80136c:	ff 75 08             	pushl  0x8(%ebp)
  80136f:	e8 78 01 00 00       	call   8014ec <open>
  801374:	89 c3                	mov    %eax,%ebx
  801376:	83 c4 10             	add    $0x10,%esp
  801379:	85 c0                	test   %eax,%eax
  80137b:	78 1b                	js     801398 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  80137d:	83 ec 08             	sub    $0x8,%esp
  801380:	ff 75 0c             	pushl  0xc(%ebp)
  801383:	50                   	push   %eax
  801384:	e8 65 ff ff ff       	call   8012ee <fstat>
  801389:	89 c6                	mov    %eax,%esi
	close(fd);
  80138b:	89 1c 24             	mov    %ebx,(%esp)
  80138e:	e8 18 fc ff ff       	call   800fab <close>
	return r;
  801393:	83 c4 10             	add    $0x10,%esp
  801396:	89 f3                	mov    %esi,%ebx
}
  801398:	89 d8                	mov    %ebx,%eax
  80139a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80139d:	5b                   	pop    %ebx
  80139e:	5e                   	pop    %esi
  80139f:	c9                   	leave  
  8013a0:	c3                   	ret    
  8013a1:	00 00                	add    %al,(%eax)
	...

008013a4 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8013a4:	55                   	push   %ebp
  8013a5:	89 e5                	mov    %esp,%ebp
  8013a7:	56                   	push   %esi
  8013a8:	53                   	push   %ebx
  8013a9:	89 c3                	mov    %eax,%ebx
  8013ab:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  8013ad:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8013b4:	75 12                	jne    8013c8 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8013b6:	83 ec 0c             	sub    $0xc,%esp
  8013b9:	6a 01                	push   $0x1
  8013bb:	e8 2a 09 00 00       	call   801cea <ipc_find_env>
  8013c0:	a3 00 40 80 00       	mov    %eax,0x804000
  8013c5:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8013c8:	6a 07                	push   $0x7
  8013ca:	68 00 50 80 00       	push   $0x805000
  8013cf:	53                   	push   %ebx
  8013d0:	ff 35 00 40 80 00    	pushl  0x804000
  8013d6:	e8 ba 08 00 00       	call   801c95 <ipc_send>
	
	return ipc_recv(NULL, dstva, NULL);
  8013db:	83 c4 0c             	add    $0xc,%esp
  8013de:	6a 00                	push   $0x0
  8013e0:	56                   	push   %esi
  8013e1:	6a 00                	push   $0x0
  8013e3:	e8 38 08 00 00       	call   801c20 <ipc_recv>
}
  8013e8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8013eb:	5b                   	pop    %ebx
  8013ec:	5e                   	pop    %esi
  8013ed:	c9                   	leave  
  8013ee:	c3                   	ret    

008013ef <devfile_stat>:
}


static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8013ef:	55                   	push   %ebp
  8013f0:	89 e5                	mov    %esp,%ebp
  8013f2:	53                   	push   %ebx
  8013f3:	83 ec 04             	sub    $0x4,%esp
  8013f6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8013f9:	8b 45 08             	mov    0x8(%ebp),%eax
  8013fc:	8b 40 0c             	mov    0xc(%eax),%eax
  8013ff:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0) {
  801404:	ba 00 00 00 00       	mov    $0x0,%edx
  801409:	b8 05 00 00 00       	mov    $0x5,%eax
  80140e:	e8 91 ff ff ff       	call   8013a4 <fsipc>
  801413:	85 c0                	test   %eax,%eax
  801415:	78 2c                	js     801443 <devfile_stat+0x54>
		return r;
	}
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801417:	83 ec 08             	sub    $0x8,%esp
  80141a:	68 00 50 80 00       	push   $0x805000
  80141f:	53                   	push   %ebx
  801420:	e8 79 f3 ff ff       	call   80079e <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801425:	a1 80 50 80 00       	mov    0x805080,%eax
  80142a:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801430:	a1 84 50 80 00       	mov    0x805084,%eax
  801435:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80143b:	83 c4 10             	add    $0x10,%esp
  80143e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801443:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801446:	c9                   	leave  
  801447:	c3                   	ret    

00801448 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801448:	55                   	push   %ebp
  801449:	89 e5                	mov    %esp,%ebp
  80144b:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80144e:	8b 45 08             	mov    0x8(%ebp),%eax
  801451:	8b 40 0c             	mov    0xc(%eax),%eax
  801454:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801459:	ba 00 00 00 00       	mov    $0x0,%edx
  80145e:	b8 06 00 00 00       	mov    $0x6,%eax
  801463:	e8 3c ff ff ff       	call   8013a4 <fsipc>
}
  801468:	c9                   	leave  
  801469:	c3                   	ret    

0080146a <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  80146a:	55                   	push   %ebp
  80146b:	89 e5                	mov    %esp,%ebp
  80146d:	56                   	push   %esi
  80146e:	53                   	push   %ebx
  80146f:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801472:	8b 45 08             	mov    0x8(%ebp),%eax
  801475:	8b 40 0c             	mov    0xc(%eax),%eax
  801478:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  80147d:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801483:	ba 00 00 00 00       	mov    $0x0,%edx
  801488:	b8 03 00 00 00       	mov    $0x3,%eax
  80148d:	e8 12 ff ff ff       	call   8013a4 <fsipc>
  801492:	89 c3                	mov    %eax,%ebx
  801494:	85 c0                	test   %eax,%eax
  801496:	78 4b                	js     8014e3 <devfile_read+0x79>
		return r;
	assert(r <= n);
  801498:	39 c6                	cmp    %eax,%esi
  80149a:	73 16                	jae    8014b2 <devfile_read+0x48>
  80149c:	68 18 24 80 00       	push   $0x802418
  8014a1:	68 1f 24 80 00       	push   $0x80241f
  8014a6:	6a 7d                	push   $0x7d
  8014a8:	68 34 24 80 00       	push   $0x802434
  8014ad:	e8 26 07 00 00       	call   801bd8 <_panic>
	assert(r <= PGSIZE);
  8014b2:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8014b7:	7e 16                	jle    8014cf <devfile_read+0x65>
  8014b9:	68 3f 24 80 00       	push   $0x80243f
  8014be:	68 1f 24 80 00       	push   $0x80241f
  8014c3:	6a 7e                	push   $0x7e
  8014c5:	68 34 24 80 00       	push   $0x802434
  8014ca:	e8 09 07 00 00       	call   801bd8 <_panic>
	memmove(buf, &fsipcbuf, r);
  8014cf:	83 ec 04             	sub    $0x4,%esp
  8014d2:	50                   	push   %eax
  8014d3:	68 00 50 80 00       	push   $0x805000
  8014d8:	ff 75 0c             	pushl  0xc(%ebp)
  8014db:	e8 7f f4 ff ff       	call   80095f <memmove>
	return r;
  8014e0:	83 c4 10             	add    $0x10,%esp
}
  8014e3:	89 d8                	mov    %ebx,%eax
  8014e5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8014e8:	5b                   	pop    %ebx
  8014e9:	5e                   	pop    %esi
  8014ea:	c9                   	leave  
  8014eb:	c3                   	ret    

008014ec <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8014ec:	55                   	push   %ebp
  8014ed:	89 e5                	mov    %esp,%ebp
  8014ef:	56                   	push   %esi
  8014f0:	53                   	push   %ebx
  8014f1:	83 ec 1c             	sub    $0x1c,%esp
  8014f4:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8014f7:	56                   	push   %esi
  8014f8:	e8 4f f2 ff ff       	call   80074c <strlen>
  8014fd:	83 c4 10             	add    $0x10,%esp
  801500:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801505:	7f 65                	jg     80156c <open+0x80>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801507:	83 ec 0c             	sub    $0xc,%esp
  80150a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80150d:	50                   	push   %eax
  80150e:	e8 e1 f8 ff ff       	call   800df4 <fd_alloc>
  801513:	89 c3                	mov    %eax,%ebx
  801515:	83 c4 10             	add    $0x10,%esp
  801518:	85 c0                	test   %eax,%eax
  80151a:	78 55                	js     801571 <open+0x85>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  80151c:	83 ec 08             	sub    $0x8,%esp
  80151f:	56                   	push   %esi
  801520:	68 00 50 80 00       	push   $0x805000
  801525:	e8 74 f2 ff ff       	call   80079e <strcpy>
	fsipcbuf.open.req_omode = mode;
  80152a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80152d:	a3 00 54 80 00       	mov    %eax,0x805400



	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801532:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801535:	b8 01 00 00 00       	mov    $0x1,%eax
  80153a:	e8 65 fe ff ff       	call   8013a4 <fsipc>
  80153f:	89 c3                	mov    %eax,%ebx
  801541:	83 c4 10             	add    $0x10,%esp
  801544:	85 c0                	test   %eax,%eax
  801546:	79 12                	jns    80155a <open+0x6e>
		fd_close(fd, 0);
  801548:	83 ec 08             	sub    $0x8,%esp
  80154b:	6a 00                	push   $0x0
  80154d:	ff 75 f4             	pushl  -0xc(%ebp)
  801550:	e8 ce f9 ff ff       	call   800f23 <fd_close>
		return r;
  801555:	83 c4 10             	add    $0x10,%esp
  801558:	eb 17                	jmp    801571 <open+0x85>
	}

	return fd2num(fd);
  80155a:	83 ec 0c             	sub    $0xc,%esp
  80155d:	ff 75 f4             	pushl  -0xc(%ebp)
  801560:	e8 67 f8 ff ff       	call   800dcc <fd2num>
  801565:	89 c3                	mov    %eax,%ebx
  801567:	83 c4 10             	add    $0x10,%esp
  80156a:	eb 05                	jmp    801571 <open+0x85>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  80156c:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801571:	89 d8                	mov    %ebx,%eax
  801573:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801576:	5b                   	pop    %ebx
  801577:	5e                   	pop    %esi
  801578:	c9                   	leave  
  801579:	c3                   	ret    
	...

0080157c <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  80157c:	55                   	push   %ebp
  80157d:	89 e5                	mov    %esp,%ebp
  80157f:	56                   	push   %esi
  801580:	53                   	push   %ebx
  801581:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801584:	83 ec 0c             	sub    $0xc,%esp
  801587:	ff 75 08             	pushl  0x8(%ebp)
  80158a:	e8 4d f8 ff ff       	call   800ddc <fd2data>
  80158f:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  801591:	83 c4 08             	add    $0x8,%esp
  801594:	68 4b 24 80 00       	push   $0x80244b
  801599:	56                   	push   %esi
  80159a:	e8 ff f1 ff ff       	call   80079e <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  80159f:	8b 43 04             	mov    0x4(%ebx),%eax
  8015a2:	2b 03                	sub    (%ebx),%eax
  8015a4:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  8015aa:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  8015b1:	00 00 00 
	stat->st_dev = &devpipe;
  8015b4:	c7 86 88 00 00 00 20 	movl   $0x803020,0x88(%esi)
  8015bb:	30 80 00 
	return 0;
}
  8015be:	b8 00 00 00 00       	mov    $0x0,%eax
  8015c3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8015c6:	5b                   	pop    %ebx
  8015c7:	5e                   	pop    %esi
  8015c8:	c9                   	leave  
  8015c9:	c3                   	ret    

008015ca <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8015ca:	55                   	push   %ebp
  8015cb:	89 e5                	mov    %esp,%ebp
  8015cd:	53                   	push   %ebx
  8015ce:	83 ec 0c             	sub    $0xc,%esp
  8015d1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8015d4:	53                   	push   %ebx
  8015d5:	6a 00                	push   $0x0
  8015d7:	e8 8e f6 ff ff       	call   800c6a <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8015dc:	89 1c 24             	mov    %ebx,(%esp)
  8015df:	e8 f8 f7 ff ff       	call   800ddc <fd2data>
  8015e4:	83 c4 08             	add    $0x8,%esp
  8015e7:	50                   	push   %eax
  8015e8:	6a 00                	push   $0x0
  8015ea:	e8 7b f6 ff ff       	call   800c6a <sys_page_unmap>
}
  8015ef:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015f2:	c9                   	leave  
  8015f3:	c3                   	ret    

008015f4 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8015f4:	55                   	push   %ebp
  8015f5:	89 e5                	mov    %esp,%ebp
  8015f7:	57                   	push   %edi
  8015f8:	56                   	push   %esi
  8015f9:	53                   	push   %ebx
  8015fa:	83 ec 1c             	sub    $0x1c,%esp
  8015fd:	89 c7                	mov    %eax,%edi
  8015ff:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801602:	a1 10 40 80 00       	mov    0x804010,%eax
  801607:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  80160a:	83 ec 0c             	sub    $0xc,%esp
  80160d:	57                   	push   %edi
  80160e:	e8 25 07 00 00       	call   801d38 <pageref>
  801613:	89 c6                	mov    %eax,%esi
  801615:	83 c4 04             	add    $0x4,%esp
  801618:	ff 75 e4             	pushl  -0x1c(%ebp)
  80161b:	e8 18 07 00 00       	call   801d38 <pageref>
  801620:	83 c4 10             	add    $0x10,%esp
  801623:	39 c6                	cmp    %eax,%esi
  801625:	0f 94 c0             	sete   %al
  801628:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  80162b:	8b 15 10 40 80 00    	mov    0x804010,%edx
  801631:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801634:	39 cb                	cmp    %ecx,%ebx
  801636:	75 08                	jne    801640 <_pipeisclosed+0x4c>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  801638:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80163b:	5b                   	pop    %ebx
  80163c:	5e                   	pop    %esi
  80163d:	5f                   	pop    %edi
  80163e:	c9                   	leave  
  80163f:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  801640:	83 f8 01             	cmp    $0x1,%eax
  801643:	75 bd                	jne    801602 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801645:	8b 42 58             	mov    0x58(%edx),%eax
  801648:	6a 01                	push   $0x1
  80164a:	50                   	push   %eax
  80164b:	53                   	push   %ebx
  80164c:	68 52 24 80 00       	push   $0x802452
  801651:	e8 92 eb ff ff       	call   8001e8 <cprintf>
  801656:	83 c4 10             	add    $0x10,%esp
  801659:	eb a7                	jmp    801602 <_pipeisclosed+0xe>

0080165b <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80165b:	55                   	push   %ebp
  80165c:	89 e5                	mov    %esp,%ebp
  80165e:	57                   	push   %edi
  80165f:	56                   	push   %esi
  801660:	53                   	push   %ebx
  801661:	83 ec 28             	sub    $0x28,%esp
  801664:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801667:	56                   	push   %esi
  801668:	e8 6f f7 ff ff       	call   800ddc <fd2data>
  80166d:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80166f:	83 c4 10             	add    $0x10,%esp
  801672:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801676:	75 4a                	jne    8016c2 <devpipe_write+0x67>
  801678:	bf 00 00 00 00       	mov    $0x0,%edi
  80167d:	eb 56                	jmp    8016d5 <devpipe_write+0x7a>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  80167f:	89 da                	mov    %ebx,%edx
  801681:	89 f0                	mov    %esi,%eax
  801683:	e8 6c ff ff ff       	call   8015f4 <_pipeisclosed>
  801688:	85 c0                	test   %eax,%eax
  80168a:	75 4d                	jne    8016d9 <devpipe_write+0x7e>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  80168c:	e8 68 f5 ff ff       	call   800bf9 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801691:	8b 43 04             	mov    0x4(%ebx),%eax
  801694:	8b 13                	mov    (%ebx),%edx
  801696:	83 c2 20             	add    $0x20,%edx
  801699:	39 d0                	cmp    %edx,%eax
  80169b:	73 e2                	jae    80167f <devpipe_write+0x24>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  80169d:	89 c2                	mov    %eax,%edx
  80169f:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  8016a5:	79 05                	jns    8016ac <devpipe_write+0x51>
  8016a7:	4a                   	dec    %edx
  8016a8:	83 ca e0             	or     $0xffffffe0,%edx
  8016ab:	42                   	inc    %edx
  8016ac:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8016af:	8a 0c 39             	mov    (%ecx,%edi,1),%cl
  8016b2:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  8016b6:	40                   	inc    %eax
  8016b7:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8016ba:	47                   	inc    %edi
  8016bb:	39 7d 10             	cmp    %edi,0x10(%ebp)
  8016be:	77 07                	ja     8016c7 <devpipe_write+0x6c>
  8016c0:	eb 13                	jmp    8016d5 <devpipe_write+0x7a>
  8016c2:	bf 00 00 00 00       	mov    $0x0,%edi
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8016c7:	8b 43 04             	mov    0x4(%ebx),%eax
  8016ca:	8b 13                	mov    (%ebx),%edx
  8016cc:	83 c2 20             	add    $0x20,%edx
  8016cf:	39 d0                	cmp    %edx,%eax
  8016d1:	73 ac                	jae    80167f <devpipe_write+0x24>
  8016d3:	eb c8                	jmp    80169d <devpipe_write+0x42>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  8016d5:	89 f8                	mov    %edi,%eax
  8016d7:	eb 05                	jmp    8016de <devpipe_write+0x83>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8016d9:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  8016de:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8016e1:	5b                   	pop    %ebx
  8016e2:	5e                   	pop    %esi
  8016e3:	5f                   	pop    %edi
  8016e4:	c9                   	leave  
  8016e5:	c3                   	ret    

008016e6 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  8016e6:	55                   	push   %ebp
  8016e7:	89 e5                	mov    %esp,%ebp
  8016e9:	57                   	push   %edi
  8016ea:	56                   	push   %esi
  8016eb:	53                   	push   %ebx
  8016ec:	83 ec 18             	sub    $0x18,%esp
  8016ef:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  8016f2:	57                   	push   %edi
  8016f3:	e8 e4 f6 ff ff       	call   800ddc <fd2data>
  8016f8:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8016fa:	83 c4 10             	add    $0x10,%esp
  8016fd:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801701:	75 44                	jne    801747 <devpipe_read+0x61>
  801703:	be 00 00 00 00       	mov    $0x0,%esi
  801708:	eb 4f                	jmp    801759 <devpipe_read+0x73>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
				return i;
  80170a:	89 f0                	mov    %esi,%eax
  80170c:	eb 54                	jmp    801762 <devpipe_read+0x7c>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  80170e:	89 da                	mov    %ebx,%edx
  801710:	89 f8                	mov    %edi,%eax
  801712:	e8 dd fe ff ff       	call   8015f4 <_pipeisclosed>
  801717:	85 c0                	test   %eax,%eax
  801719:	75 42                	jne    80175d <devpipe_read+0x77>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  80171b:	e8 d9 f4 ff ff       	call   800bf9 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801720:	8b 03                	mov    (%ebx),%eax
  801722:	3b 43 04             	cmp    0x4(%ebx),%eax
  801725:	74 e7                	je     80170e <devpipe_read+0x28>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801727:	25 1f 00 00 80       	and    $0x8000001f,%eax
  80172c:	79 05                	jns    801733 <devpipe_read+0x4d>
  80172e:	48                   	dec    %eax
  80172f:	83 c8 e0             	or     $0xffffffe0,%eax
  801732:	40                   	inc    %eax
  801733:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  801737:	8b 55 0c             	mov    0xc(%ebp),%edx
  80173a:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  80173d:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80173f:	46                   	inc    %esi
  801740:	39 75 10             	cmp    %esi,0x10(%ebp)
  801743:	77 07                	ja     80174c <devpipe_read+0x66>
  801745:	eb 12                	jmp    801759 <devpipe_read+0x73>
  801747:	be 00 00 00 00       	mov    $0x0,%esi
		while (p->p_rpos == p->p_wpos) {
  80174c:	8b 03                	mov    (%ebx),%eax
  80174e:	3b 43 04             	cmp    0x4(%ebx),%eax
  801751:	75 d4                	jne    801727 <devpipe_read+0x41>
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801753:	85 f6                	test   %esi,%esi
  801755:	75 b3                	jne    80170a <devpipe_read+0x24>
  801757:	eb b5                	jmp    80170e <devpipe_read+0x28>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801759:	89 f0                	mov    %esi,%eax
  80175b:	eb 05                	jmp    801762 <devpipe_read+0x7c>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80175d:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801762:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801765:	5b                   	pop    %ebx
  801766:	5e                   	pop    %esi
  801767:	5f                   	pop    %edi
  801768:	c9                   	leave  
  801769:	c3                   	ret    

0080176a <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  80176a:	55                   	push   %ebp
  80176b:	89 e5                	mov    %esp,%ebp
  80176d:	57                   	push   %edi
  80176e:	56                   	push   %esi
  80176f:	53                   	push   %ebx
  801770:	83 ec 28             	sub    $0x28,%esp
  801773:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801776:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801779:	50                   	push   %eax
  80177a:	e8 75 f6 ff ff       	call   800df4 <fd_alloc>
  80177f:	89 c3                	mov    %eax,%ebx
  801781:	83 c4 10             	add    $0x10,%esp
  801784:	85 c0                	test   %eax,%eax
  801786:	0f 88 24 01 00 00    	js     8018b0 <pipe+0x146>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80178c:	83 ec 04             	sub    $0x4,%esp
  80178f:	68 07 04 00 00       	push   $0x407
  801794:	ff 75 e4             	pushl  -0x1c(%ebp)
  801797:	6a 00                	push   $0x0
  801799:	e8 82 f4 ff ff       	call   800c20 <sys_page_alloc>
  80179e:	89 c3                	mov    %eax,%ebx
  8017a0:	83 c4 10             	add    $0x10,%esp
  8017a3:	85 c0                	test   %eax,%eax
  8017a5:	0f 88 05 01 00 00    	js     8018b0 <pipe+0x146>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  8017ab:	83 ec 0c             	sub    $0xc,%esp
  8017ae:	8d 45 e0             	lea    -0x20(%ebp),%eax
  8017b1:	50                   	push   %eax
  8017b2:	e8 3d f6 ff ff       	call   800df4 <fd_alloc>
  8017b7:	89 c3                	mov    %eax,%ebx
  8017b9:	83 c4 10             	add    $0x10,%esp
  8017bc:	85 c0                	test   %eax,%eax
  8017be:	0f 88 dc 00 00 00    	js     8018a0 <pipe+0x136>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8017c4:	83 ec 04             	sub    $0x4,%esp
  8017c7:	68 07 04 00 00       	push   $0x407
  8017cc:	ff 75 e0             	pushl  -0x20(%ebp)
  8017cf:	6a 00                	push   $0x0
  8017d1:	e8 4a f4 ff ff       	call   800c20 <sys_page_alloc>
  8017d6:	89 c3                	mov    %eax,%ebx
  8017d8:	83 c4 10             	add    $0x10,%esp
  8017db:	85 c0                	test   %eax,%eax
  8017dd:	0f 88 bd 00 00 00    	js     8018a0 <pipe+0x136>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  8017e3:	83 ec 0c             	sub    $0xc,%esp
  8017e6:	ff 75 e4             	pushl  -0x1c(%ebp)
  8017e9:	e8 ee f5 ff ff       	call   800ddc <fd2data>
  8017ee:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8017f0:	83 c4 0c             	add    $0xc,%esp
  8017f3:	68 07 04 00 00       	push   $0x407
  8017f8:	50                   	push   %eax
  8017f9:	6a 00                	push   $0x0
  8017fb:	e8 20 f4 ff ff       	call   800c20 <sys_page_alloc>
  801800:	89 c3                	mov    %eax,%ebx
  801802:	83 c4 10             	add    $0x10,%esp
  801805:	85 c0                	test   %eax,%eax
  801807:	0f 88 83 00 00 00    	js     801890 <pipe+0x126>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80180d:	83 ec 0c             	sub    $0xc,%esp
  801810:	ff 75 e0             	pushl  -0x20(%ebp)
  801813:	e8 c4 f5 ff ff       	call   800ddc <fd2data>
  801818:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  80181f:	50                   	push   %eax
  801820:	6a 00                	push   $0x0
  801822:	56                   	push   %esi
  801823:	6a 00                	push   $0x0
  801825:	e8 1a f4 ff ff       	call   800c44 <sys_page_map>
  80182a:	89 c3                	mov    %eax,%ebx
  80182c:	83 c4 20             	add    $0x20,%esp
  80182f:	85 c0                	test   %eax,%eax
  801831:	78 4f                	js     801882 <pipe+0x118>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801833:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801839:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80183c:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  80183e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801841:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801848:	8b 15 20 30 80 00    	mov    0x803020,%edx
  80184e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801851:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801853:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801856:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  80185d:	83 ec 0c             	sub    $0xc,%esp
  801860:	ff 75 e4             	pushl  -0x1c(%ebp)
  801863:	e8 64 f5 ff ff       	call   800dcc <fd2num>
  801868:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  80186a:	83 c4 04             	add    $0x4,%esp
  80186d:	ff 75 e0             	pushl  -0x20(%ebp)
  801870:	e8 57 f5 ff ff       	call   800dcc <fd2num>
  801875:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  801878:	83 c4 10             	add    $0x10,%esp
  80187b:	bb 00 00 00 00       	mov    $0x0,%ebx
  801880:	eb 2e                	jmp    8018b0 <pipe+0x146>

    err3:
	sys_page_unmap(0, va);
  801882:	83 ec 08             	sub    $0x8,%esp
  801885:	56                   	push   %esi
  801886:	6a 00                	push   $0x0
  801888:	e8 dd f3 ff ff       	call   800c6a <sys_page_unmap>
  80188d:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801890:	83 ec 08             	sub    $0x8,%esp
  801893:	ff 75 e0             	pushl  -0x20(%ebp)
  801896:	6a 00                	push   $0x0
  801898:	e8 cd f3 ff ff       	call   800c6a <sys_page_unmap>
  80189d:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  8018a0:	83 ec 08             	sub    $0x8,%esp
  8018a3:	ff 75 e4             	pushl  -0x1c(%ebp)
  8018a6:	6a 00                	push   $0x0
  8018a8:	e8 bd f3 ff ff       	call   800c6a <sys_page_unmap>
  8018ad:	83 c4 10             	add    $0x10,%esp
    err:
	return r;
}
  8018b0:	89 d8                	mov    %ebx,%eax
  8018b2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8018b5:	5b                   	pop    %ebx
  8018b6:	5e                   	pop    %esi
  8018b7:	5f                   	pop    %edi
  8018b8:	c9                   	leave  
  8018b9:	c3                   	ret    

008018ba <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  8018ba:	55                   	push   %ebp
  8018bb:	89 e5                	mov    %esp,%ebp
  8018bd:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8018c0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018c3:	50                   	push   %eax
  8018c4:	ff 75 08             	pushl  0x8(%ebp)
  8018c7:	e8 9b f5 ff ff       	call   800e67 <fd_lookup>
  8018cc:	83 c4 10             	add    $0x10,%esp
  8018cf:	85 c0                	test   %eax,%eax
  8018d1:	78 18                	js     8018eb <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  8018d3:	83 ec 0c             	sub    $0xc,%esp
  8018d6:	ff 75 f4             	pushl  -0xc(%ebp)
  8018d9:	e8 fe f4 ff ff       	call   800ddc <fd2data>
	return _pipeisclosed(fd, p);
  8018de:	89 c2                	mov    %eax,%edx
  8018e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018e3:	e8 0c fd ff ff       	call   8015f4 <_pipeisclosed>
  8018e8:	83 c4 10             	add    $0x10,%esp
}
  8018eb:	c9                   	leave  
  8018ec:	c3                   	ret    
  8018ed:	00 00                	add    %al,(%eax)
	...

008018f0 <pthread_create>:
#include <inc/lib.h>
#include <inc/x86.h>

int
pthread_create(uint32_t * t_id, void (*f)(void *), void *arg) 
{
  8018f0:	55                   	push   %ebp
  8018f1:	89 e5                	mov    %esp,%ebp
  8018f3:	57                   	push   %edi
  8018f4:	56                   	push   %esi
  8018f5:	53                   	push   %ebx
  8018f6:	83 ec 78             	sub    $0x78,%esp
	char * t_stack = malloc(PGSIZE);
  8018f9:	68 00 10 00 00       	push   $0x1000
  8018fe:	e8 79 04 00 00       	call   801d7c <malloc>
  801903:	89 c3                	mov    %eax,%ebx
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exothread(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  801905:	ba 12 00 00 00       	mov    $0x12,%edx
  80190a:	89 d0                	mov    %edx,%eax
  80190c:	cd 30                	int    $0x30
  80190e:	89 45 94             	mov    %eax,-0x6c(%ebp)
	struct Trapframe child_tf;

	int childpid = sys_exothread();
	if (childpid < 0) {
  801911:	83 c4 10             	add    $0x10,%esp
  801914:	85 c0                	test   %eax,%eax
  801916:	79 12                	jns    80192a <pthread_create+0x3a>
		panic("fork sys_exofork error : %e\n", childpid);
  801918:	50                   	push   %eax
  801919:	68 6a 24 80 00       	push   $0x80246a
  80191e:	6a 0d                	push   $0xd
  801920:	68 87 24 80 00       	push   $0x802487
  801925:	e8 ae 02 00 00       	call   801bd8 <_panic>
	}

	int r;
	uint32_t sta_top, sta[2];
	sta_top = (uint32_t)t_stack + PGSIZE;
	sta[0] = (uint32_t)exit;					// return address
  80192a:	c7 45 9c 3c 01 80 00 	movl   $0x80013c,-0x64(%ebp)
	sta[1] = (uint32_t)arg;					// thread arg
  801931:	8b 45 10             	mov    0x10(%ebp),%eax
  801934:	89 45 a0             	mov    %eax,-0x60(%ebp)
	sta_top -= 2 * sizeof(uint32_t);		
  801937:	81 c3 f8 0f 00 00    	add    $0xff8,%ebx
	memcpy((void *)sta_top, (void *)sta, 2 * sizeof(uint32_t));
  80193d:	83 ec 04             	sub    $0x4,%esp
  801940:	6a 08                	push   $0x8
  801942:	8d 45 9c             	lea    -0x64(%ebp),%eax
  801945:	50                   	push   %eax
  801946:	53                   	push   %ebx
  801947:	e8 7d f0 ff ff       	call   8009c9 <memcpy>

	child_tf = envs[ENVX(childpid)].env_tf;
  80194c:	8b 45 94             	mov    -0x6c(%ebp),%eax
  80194f:	25 ff 03 00 00       	and    $0x3ff,%eax
  801954:	89 c2                	mov    %eax,%edx
  801956:	c1 e2 07             	shl    $0x7,%edx
  801959:	8d b4 82 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,4),%esi
  801960:	8d 7d a4             	lea    -0x5c(%ebp),%edi
  801963:	b9 11 00 00 00       	mov    $0x11,%ecx
  801968:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  	child_tf.tf_eip = (uint32_t)f;				// set eip
  80196a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80196d:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	child_tf.tf_esp = sta_top;						// set esp
  801970:	89 5d e0             	mov    %ebx,-0x20(%ebp)

	if ((r = sys_env_set_trapframe(childpid, &child_tf)) < 0) {
  801973:	83 c4 08             	add    $0x8,%esp
  801976:	8d 45 a4             	lea    -0x5c(%ebp),%eax
  801979:	50                   	push   %eax
  80197a:	ff 75 94             	pushl  -0x6c(%ebp)
  80197d:	e8 2e f3 ff ff       	call   800cb0 <sys_env_set_trapframe>
  801982:	89 c3                	mov    %eax,%ebx
  801984:	83 c4 10             	add    $0x10,%esp
  801987:	85 c0                	test   %eax,%eax
  801989:	79 13                	jns    80199e <pthread_create+0xae>
		cprintf("pthread create: sys_env_set_trapframe: %e\n", r);
  80198b:	83 ec 08             	sub    $0x8,%esp
  80198e:	50                   	push   %eax
  80198f:	68 94 24 80 00       	push   $0x802494
  801994:	e8 4f e8 ff ff       	call   8001e8 <cprintf>
		return r;
  801999:	83 c4 10             	add    $0x10,%esp
  80199c:	eb 36                	jmp    8019d4 <pthread_create+0xe4>
	}
	if ((r = sys_env_set_status(childpid, ENV_RUNNABLE)) < 0) {
  80199e:	83 ec 08             	sub    $0x8,%esp
  8019a1:	6a 02                	push   $0x2
  8019a3:	ff 75 94             	pushl  -0x6c(%ebp)
  8019a6:	e8 e2 f2 ff ff       	call   800c8d <sys_env_set_status>
  8019ab:	89 c3                	mov    %eax,%ebx
  8019ad:	83 c4 10             	add    $0x10,%esp
  8019b0:	85 c0                	test   %eax,%eax
  8019b2:	79 13                	jns    8019c7 <pthread_create+0xd7>
		cprintf("pthread create: set thread status error : %e\n", r);
  8019b4:	83 ec 08             	sub    $0x8,%esp
  8019b7:	50                   	push   %eax
  8019b8:	68 c0 24 80 00       	push   $0x8024c0
  8019bd:	e8 26 e8 ff ff       	call   8001e8 <cprintf>
		return r;
  8019c2:	83 c4 10             	add    $0x10,%esp
  8019c5:	eb 0d                	jmp    8019d4 <pthread_create+0xe4>
	}

	*t_id = childpid;
  8019c7:	8b 45 08             	mov    0x8(%ebp),%eax
  8019ca:	8b 55 94             	mov    -0x6c(%ebp),%edx
  8019cd:	89 10                	mov    %edx,(%eax)
	return 0;
  8019cf:	bb 00 00 00 00       	mov    $0x0,%ebx
}
  8019d4:	89 d8                	mov    %ebx,%eax
  8019d6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8019d9:	5b                   	pop    %ebx
  8019da:	5e                   	pop    %esi
  8019db:	5f                   	pop    %edi
  8019dc:	c9                   	leave  
  8019dd:	c3                   	ret    

008019de <pthread_join>:

int 
pthread_join(envid_t id) 
{
  8019de:	55                   	push   %ebp
  8019df:	89 e5                	mov    %esp,%ebp
  8019e1:	53                   	push   %ebx
  8019e2:	83 ec 04             	sub    $0x4,%esp
  8019e5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	while (1) {
		r = sys_join(id);
  8019e8:	83 ec 0c             	sub    $0xc,%esp
  8019eb:	53                   	push   %ebx
  8019ec:	e8 94 f3 ff ff       	call   800d85 <sys_join>
		if (r != 0) break;
  8019f1:	83 c4 10             	add    $0x10,%esp
  8019f4:	85 c0                	test   %eax,%eax
  8019f6:	75 07                	jne    8019ff <pthread_join+0x21>
		sys_yield();
  8019f8:	e8 fc f1 ff ff       	call   800bf9 <sys_yield>
	}
  8019fd:	eb e9                	jmp    8019e8 <pthread_join+0xa>
	return r;
}
  8019ff:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a02:	c9                   	leave  
  801a03:	c3                   	ret    

00801a04 <pthread_mutex_init>:

int
pthread_mutex_init(pthread_mutex_t * mutex)
{
  801a04:	55                   	push   %ebp
  801a05:	89 e5                	mov    %esp,%ebp
	mutex->lock = 0;
  801a07:	8b 45 08             	mov    0x8(%ebp),%eax
  801a0a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return 0;
}
  801a10:	b8 00 00 00 00       	mov    $0x0,%eax
  801a15:	c9                   	leave  
  801a16:	c3                   	ret    

00801a17 <pthread_mutex_lock>:

int
pthread_mutex_lock(pthread_mutex_t * mutex)
{
  801a17:	55                   	push   %ebp
  801a18:	89 e5                	mov    %esp,%ebp
  801a1a:	8b 55 08             	mov    0x8(%ebp),%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1" :
  801a1d:	b9 01 00 00 00       	mov    $0x1,%ecx
  801a22:	89 c8                	mov    %ecx,%eax
  801a24:	f0 87 02             	lock xchg %eax,(%edx)
	while (xchg(&mutex->lock, 1) == 1)
  801a27:	83 f8 01             	cmp    $0x1,%eax
  801a2a:	74 f6                	je     801a22 <pthread_mutex_lock+0xb>
		;
	return 0;
}
  801a2c:	b8 00 00 00 00       	mov    $0x0,%eax
  801a31:	c9                   	leave  
  801a32:	c3                   	ret    

00801a33 <pthread_mutex_unlock>:

int
pthread_mutex_unlock(pthread_mutex_t * mutex)
{
  801a33:	55                   	push   %ebp
  801a34:	89 e5                	mov    %esp,%ebp
  801a36:	8b 55 08             	mov    0x8(%ebp),%edx
  801a39:	b8 00 00 00 00       	mov    $0x0,%eax
  801a3e:	f0 87 02             	lock xchg %eax,(%edx)
	xchg(&mutex->lock, 0);
	return 0;
  801a41:	b8 00 00 00 00       	mov    $0x0,%eax
  801a46:	c9                   	leave  
  801a47:	c3                   	ret    

00801a48 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801a48:	55                   	push   %ebp
  801a49:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801a4b:	b8 00 00 00 00       	mov    $0x0,%eax
  801a50:	c9                   	leave  
  801a51:	c3                   	ret    

00801a52 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801a52:	55                   	push   %ebp
  801a53:	89 e5                	mov    %esp,%ebp
  801a55:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801a58:	68 ee 24 80 00       	push   $0x8024ee
  801a5d:	ff 75 0c             	pushl  0xc(%ebp)
  801a60:	e8 39 ed ff ff       	call   80079e <strcpy>
	return 0;
}
  801a65:	b8 00 00 00 00       	mov    $0x0,%eax
  801a6a:	c9                   	leave  
  801a6b:	c3                   	ret    

00801a6c <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801a6c:	55                   	push   %ebp
  801a6d:	89 e5                	mov    %esp,%ebp
  801a6f:	57                   	push   %edi
  801a70:	56                   	push   %esi
  801a71:	53                   	push   %ebx
  801a72:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801a78:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801a7c:	74 45                	je     801ac3 <devcons_write+0x57>
  801a7e:	b8 00 00 00 00       	mov    $0x0,%eax
  801a83:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801a88:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801a8e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801a91:	29 c3                	sub    %eax,%ebx
		if (m > sizeof(buf) - 1)
  801a93:	83 fb 7f             	cmp    $0x7f,%ebx
  801a96:	76 05                	jbe    801a9d <devcons_write+0x31>
			m = sizeof(buf) - 1;
  801a98:	bb 7f 00 00 00       	mov    $0x7f,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  801a9d:	83 ec 04             	sub    $0x4,%esp
  801aa0:	53                   	push   %ebx
  801aa1:	03 45 0c             	add    0xc(%ebp),%eax
  801aa4:	50                   	push   %eax
  801aa5:	57                   	push   %edi
  801aa6:	e8 b4 ee ff ff       	call   80095f <memmove>
		sys_cputs(buf, m);
  801aab:	83 c4 08             	add    $0x8,%esp
  801aae:	53                   	push   %ebx
  801aaf:	57                   	push   %edi
  801ab0:	e8 b4 f0 ff ff       	call   800b69 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801ab5:	01 de                	add    %ebx,%esi
  801ab7:	89 f0                	mov    %esi,%eax
  801ab9:	83 c4 10             	add    $0x10,%esp
  801abc:	3b 75 10             	cmp    0x10(%ebp),%esi
  801abf:	72 cd                	jb     801a8e <devcons_write+0x22>
  801ac1:	eb 05                	jmp    801ac8 <devcons_write+0x5c>
  801ac3:	be 00 00 00 00       	mov    $0x0,%esi
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801ac8:	89 f0                	mov    %esi,%eax
  801aca:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801acd:	5b                   	pop    %ebx
  801ace:	5e                   	pop    %esi
  801acf:	5f                   	pop    %edi
  801ad0:	c9                   	leave  
  801ad1:	c3                   	ret    

00801ad2 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801ad2:	55                   	push   %ebp
  801ad3:	89 e5                	mov    %esp,%ebp
  801ad5:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  801ad8:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801adc:	75 07                	jne    801ae5 <devcons_read+0x13>
  801ade:	eb 25                	jmp    801b05 <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801ae0:	e8 14 f1 ff ff       	call   800bf9 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801ae5:	e8 a5 f0 ff ff       	call   800b8f <sys_cgetc>
  801aea:	85 c0                	test   %eax,%eax
  801aec:	74 f2                	je     801ae0 <devcons_read+0xe>
  801aee:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  801af0:	85 c0                	test   %eax,%eax
  801af2:	78 1d                	js     801b11 <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801af4:	83 f8 04             	cmp    $0x4,%eax
  801af7:	74 13                	je     801b0c <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  801af9:	8b 45 0c             	mov    0xc(%ebp),%eax
  801afc:	88 10                	mov    %dl,(%eax)
	return 1;
  801afe:	b8 01 00 00 00       	mov    $0x1,%eax
  801b03:	eb 0c                	jmp    801b11 <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  801b05:	b8 00 00 00 00       	mov    $0x0,%eax
  801b0a:	eb 05                	jmp    801b11 <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801b0c:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801b11:	c9                   	leave  
  801b12:	c3                   	ret    

00801b13 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801b13:	55                   	push   %ebp
  801b14:	89 e5                	mov    %esp,%ebp
  801b16:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801b19:	8b 45 08             	mov    0x8(%ebp),%eax
  801b1c:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801b1f:	6a 01                	push   $0x1
  801b21:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801b24:	50                   	push   %eax
  801b25:	e8 3f f0 ff ff       	call   800b69 <sys_cputs>
  801b2a:	83 c4 10             	add    $0x10,%esp
}
  801b2d:	c9                   	leave  
  801b2e:	c3                   	ret    

00801b2f <getchar>:

int
getchar(void)
{
  801b2f:	55                   	push   %ebp
  801b30:	89 e5                	mov    %esp,%ebp
  801b32:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801b35:	6a 01                	push   $0x1
  801b37:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801b3a:	50                   	push   %eax
  801b3b:	6a 00                	push   $0x0
  801b3d:	e8 a6 f5 ff ff       	call   8010e8 <read>
	if (r < 0)
  801b42:	83 c4 10             	add    $0x10,%esp
  801b45:	85 c0                	test   %eax,%eax
  801b47:	78 0f                	js     801b58 <getchar+0x29>
		return r;
	if (r < 1)
  801b49:	85 c0                	test   %eax,%eax
  801b4b:	7e 06                	jle    801b53 <getchar+0x24>
		return -E_EOF;
	return c;
  801b4d:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801b51:	eb 05                	jmp    801b58 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801b53:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801b58:	c9                   	leave  
  801b59:	c3                   	ret    

00801b5a <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801b5a:	55                   	push   %ebp
  801b5b:	89 e5                	mov    %esp,%ebp
  801b5d:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801b60:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b63:	50                   	push   %eax
  801b64:	ff 75 08             	pushl  0x8(%ebp)
  801b67:	e8 fb f2 ff ff       	call   800e67 <fd_lookup>
  801b6c:	83 c4 10             	add    $0x10,%esp
  801b6f:	85 c0                	test   %eax,%eax
  801b71:	78 11                	js     801b84 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801b73:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b76:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801b7c:	39 10                	cmp    %edx,(%eax)
  801b7e:	0f 94 c0             	sete   %al
  801b81:	0f b6 c0             	movzbl %al,%eax
}
  801b84:	c9                   	leave  
  801b85:	c3                   	ret    

00801b86 <opencons>:

int
opencons(void)
{
  801b86:	55                   	push   %ebp
  801b87:	89 e5                	mov    %esp,%ebp
  801b89:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801b8c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b8f:	50                   	push   %eax
  801b90:	e8 5f f2 ff ff       	call   800df4 <fd_alloc>
  801b95:	83 c4 10             	add    $0x10,%esp
  801b98:	85 c0                	test   %eax,%eax
  801b9a:	78 3a                	js     801bd6 <opencons+0x50>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801b9c:	83 ec 04             	sub    $0x4,%esp
  801b9f:	68 07 04 00 00       	push   $0x407
  801ba4:	ff 75 f4             	pushl  -0xc(%ebp)
  801ba7:	6a 00                	push   $0x0
  801ba9:	e8 72 f0 ff ff       	call   800c20 <sys_page_alloc>
  801bae:	83 c4 10             	add    $0x10,%esp
  801bb1:	85 c0                	test   %eax,%eax
  801bb3:	78 21                	js     801bd6 <opencons+0x50>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801bb5:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801bbb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801bbe:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801bc0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801bc3:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801bca:	83 ec 0c             	sub    $0xc,%esp
  801bcd:	50                   	push   %eax
  801bce:	e8 f9 f1 ff ff       	call   800dcc <fd2num>
  801bd3:	83 c4 10             	add    $0x10,%esp
}
  801bd6:	c9                   	leave  
  801bd7:	c3                   	ret    

00801bd8 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801bd8:	55                   	push   %ebp
  801bd9:	89 e5                	mov    %esp,%ebp
  801bdb:	56                   	push   %esi
  801bdc:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801bdd:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801be0:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  801be6:	e8 ea ef ff ff       	call   800bd5 <sys_getenvid>
  801beb:	83 ec 0c             	sub    $0xc,%esp
  801bee:	ff 75 0c             	pushl  0xc(%ebp)
  801bf1:	ff 75 08             	pushl  0x8(%ebp)
  801bf4:	53                   	push   %ebx
  801bf5:	50                   	push   %eax
  801bf6:	68 fc 24 80 00       	push   $0x8024fc
  801bfb:	e8 e8 e5 ff ff       	call   8001e8 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801c00:	83 c4 18             	add    $0x18,%esp
  801c03:	56                   	push   %esi
  801c04:	ff 75 10             	pushl  0x10(%ebp)
  801c07:	e8 8b e5 ff ff       	call   800197 <vcprintf>
	cprintf("\n");
  801c0c:	c7 04 24 48 20 80 00 	movl   $0x802048,(%esp)
  801c13:	e8 d0 e5 ff ff       	call   8001e8 <cprintf>
  801c18:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801c1b:	cc                   	int3   
  801c1c:	eb fd                	jmp    801c1b <_panic+0x43>
	...

00801c20 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801c20:	55                   	push   %ebp
  801c21:	89 e5                	mov    %esp,%ebp
  801c23:	56                   	push   %esi
  801c24:	53                   	push   %ebx
  801c25:	8b 75 08             	mov    0x8(%ebp),%esi
  801c28:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c2b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// cprintf("0x%x 0x%x 0x%x\n", (uint32_t)from_env_store, (uint32_t)pg, (uint32_t)perm_store);
	int r;
	if (pg != NULL) {
  801c2e:	85 c0                	test   %eax,%eax
  801c30:	74 0e                	je     801c40 <ipc_recv+0x20>
		r = sys_ipc_recv(pg);
  801c32:	83 ec 0c             	sub    $0xc,%esp
  801c35:	50                   	push   %eax
  801c36:	e8 e0 f0 ff ff       	call   800d1b <sys_ipc_recv>
  801c3b:	83 c4 10             	add    $0x10,%esp
  801c3e:	eb 10                	jmp    801c50 <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv((void *)UTOP);
  801c40:	83 ec 0c             	sub    $0xc,%esp
  801c43:	68 00 00 c0 ee       	push   $0xeec00000
  801c48:	e8 ce f0 ff ff       	call   800d1b <sys_ipc_recv>
  801c4d:	83 c4 10             	add    $0x10,%esp
	}

	if (r == 0) {
  801c50:	85 c0                	test   %eax,%eax
  801c52:	75 26                	jne    801c7a <ipc_recv+0x5a>
		if (from_env_store != NULL) *from_env_store = thisenv->env_ipc_from;
  801c54:	85 f6                	test   %esi,%esi
  801c56:	74 0a                	je     801c62 <ipc_recv+0x42>
  801c58:	a1 10 40 80 00       	mov    0x804010,%eax
  801c5d:	8b 40 74             	mov    0x74(%eax),%eax
  801c60:	89 06                	mov    %eax,(%esi)
		if (perm_store != NULL) *perm_store = thisenv->env_ipc_perm;
  801c62:	85 db                	test   %ebx,%ebx
  801c64:	74 0a                	je     801c70 <ipc_recv+0x50>
  801c66:	a1 10 40 80 00       	mov    0x804010,%eax
  801c6b:	8b 40 78             	mov    0x78(%eax),%eax
  801c6e:	89 03                	mov    %eax,(%ebx)
		return thisenv->env_ipc_value;
  801c70:	a1 10 40 80 00       	mov    0x804010,%eax
  801c75:	8b 40 70             	mov    0x70(%eax),%eax
  801c78:	eb 14                	jmp    801c8e <ipc_recv+0x6e>
	} else {
		// fails;
		if (from_env_store != NULL) *from_env_store = 0;
  801c7a:	85 f6                	test   %esi,%esi
  801c7c:	74 06                	je     801c84 <ipc_recv+0x64>
  801c7e:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if (perm_store != NULL) *perm_store = 0;
  801c84:	85 db                	test   %ebx,%ebx
  801c86:	74 06                	je     801c8e <ipc_recv+0x6e>
  801c88:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		return r;
	}
}
  801c8e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c91:	5b                   	pop    %ebx
  801c92:	5e                   	pop    %esi
  801c93:	c9                   	leave  
  801c94:	c3                   	ret    

00801c95 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801c95:	55                   	push   %ebp
  801c96:	89 e5                	mov    %esp,%ebp
  801c98:	57                   	push   %edi
  801c99:	56                   	push   %esi
  801c9a:	53                   	push   %ebx
  801c9b:	83 ec 0c             	sub    $0xc,%esp
  801c9e:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801ca1:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801ca4:	8b 75 14             	mov    0x14(%ebp),%esi
	// LAB 4: Your code here.
	// int sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
	int r;
	if (pg == NULL) pg = (void *)UTOP;
  801ca7:	85 db                	test   %ebx,%ebx
  801ca9:	75 25                	jne    801cd0 <ipc_send+0x3b>
  801cab:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
  801cb0:	eb 1e                	jmp    801cd0 <ipc_send+0x3b>
	
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) != 0) {
		if (r == -E_IPC_NOT_RECV) {
  801cb2:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801cb5:	75 07                	jne    801cbe <ipc_send+0x29>
			// cprintf("Try Again and Again....\n");
			sys_yield();
  801cb7:	e8 3d ef ff ff       	call   800bf9 <sys_yield>
  801cbc:	eb 12                	jmp    801cd0 <ipc_send+0x3b>
		} else {
			panic("ipc_send error %e\n", r);
  801cbe:	50                   	push   %eax
  801cbf:	68 20 25 80 00       	push   $0x802520
  801cc4:	6a 43                	push   $0x43
  801cc6:	68 33 25 80 00       	push   $0x802533
  801ccb:	e8 08 ff ff ff       	call   801bd8 <_panic>
	// LAB 4: Your code here.
	// int sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
	int r;
	if (pg == NULL) pg = (void *)UTOP;
	
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) != 0) {
  801cd0:	56                   	push   %esi
  801cd1:	53                   	push   %ebx
  801cd2:	57                   	push   %edi
  801cd3:	ff 75 08             	pushl  0x8(%ebp)
  801cd6:	e8 1b f0 ff ff       	call   800cf6 <sys_ipc_try_send>
  801cdb:	83 c4 10             	add    $0x10,%esp
  801cde:	85 c0                	test   %eax,%eax
  801ce0:	75 d0                	jne    801cb2 <ipc_send+0x1d>
		} else {
			panic("ipc_send error %e\n", r);
		}
	}
	return;
}
  801ce2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ce5:	5b                   	pop    %ebx
  801ce6:	5e                   	pop    %esi
  801ce7:	5f                   	pop    %edi
  801ce8:	c9                   	leave  
  801ce9:	c3                   	ret    

00801cea <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801cea:	55                   	push   %ebp
  801ceb:	89 e5                	mov    %esp,%ebp
  801ced:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  801cf0:	39 0d 50 00 c0 ee    	cmp    %ecx,0xeec00050
  801cf6:	74 1a                	je     801d12 <ipc_find_env+0x28>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801cf8:	b8 01 00 00 00       	mov    $0x1,%eax
		if (envs[i].env_type == type)
  801cfd:	89 c2                	mov    %eax,%edx
  801cff:	c1 e2 07             	shl    $0x7,%edx
  801d02:	8d 94 82 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,4),%edx
  801d09:	8b 52 50             	mov    0x50(%edx),%edx
  801d0c:	39 ca                	cmp    %ecx,%edx
  801d0e:	75 18                	jne    801d28 <ipc_find_env+0x3e>
  801d10:	eb 05                	jmp    801d17 <ipc_find_env+0x2d>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801d12:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
			return envs[i].env_id;
  801d17:	89 c2                	mov    %eax,%edx
  801d19:	c1 e2 07             	shl    $0x7,%edx
  801d1c:	8d 84 82 08 00 c0 ee 	lea    -0x113ffff8(%edx,%eax,4),%eax
  801d23:	8b 40 40             	mov    0x40(%eax),%eax
  801d26:	eb 0c                	jmp    801d34 <ipc_find_env+0x4a>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801d28:	40                   	inc    %eax
  801d29:	3d 00 04 00 00       	cmp    $0x400,%eax
  801d2e:	75 cd                	jne    801cfd <ipc_find_env+0x13>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801d30:	66 b8 00 00          	mov    $0x0,%ax
}
  801d34:	c9                   	leave  
  801d35:	c3                   	ret    
	...

00801d38 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801d38:	55                   	push   %ebp
  801d39:	89 e5                	mov    %esp,%ebp
  801d3b:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801d3e:	89 c2                	mov    %eax,%edx
  801d40:	c1 ea 16             	shr    $0x16,%edx
  801d43:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801d4a:	f6 c2 01             	test   $0x1,%dl
  801d4d:	74 1e                	je     801d6d <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  801d4f:	c1 e8 0c             	shr    $0xc,%eax
  801d52:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801d59:	a8 01                	test   $0x1,%al
  801d5b:	74 17                	je     801d74 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801d5d:	c1 e8 0c             	shr    $0xc,%eax
  801d60:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  801d67:	ef 
  801d68:	0f b7 c0             	movzwl %ax,%eax
  801d6b:	eb 0c                	jmp    801d79 <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  801d6d:	b8 00 00 00 00       	mov    $0x0,%eax
  801d72:	eb 05                	jmp    801d79 <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  801d74:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  801d79:	c9                   	leave  
  801d7a:	c3                   	ret    
	...

00801d7c <malloc>:

#define null ((char *)(0))

char *
malloc(uint32_t size)
{
  801d7c:	55                   	push   %ebp
  801d7d:	89 e5                	mov    %esp,%ebp
  801d7f:	57                   	push   %edi
  801d80:	56                   	push   %esi
  801d81:	53                   	push   %ebx
  801d82:	83 ec 0c             	sub    $0xc,%esp
  801d85:	8b 75 08             	mov    0x8(%ebp),%esi
	cur = ROUNDUP(cur, PGSIZE);
  801d88:	8b 3d 58 30 80 00    	mov    0x803058,%edi
  801d8e:	81 c7 ff 0f 00 00    	add    $0xfff,%edi
  801d94:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
  801d9a:	89 3d 58 30 80 00    	mov    %edi,0x803058

	char * ret = cur;
	int r;
	uint32_t t;
	for (t = 0; t < size; t += PGSIZE) {
  801da0:	85 f6                	test   %esi,%esi
  801da2:	74 3f                	je     801de3 <malloc+0x67>
  801da4:	bb 00 00 00 00       	mov    $0x0,%ebx
		r = sys_page_alloc(0, cur, PTE_W | PTE_U | PTE_P);
  801da9:	83 ec 04             	sub    $0x4,%esp
  801dac:	6a 07                	push   $0x7
  801dae:	ff 35 58 30 80 00    	pushl  0x803058
  801db4:	6a 00                	push   $0x0
  801db6:	e8 65 ee ff ff       	call   800c20 <sys_page_alloc>
		if (r < 0) {
  801dbb:	83 c4 10             	add    $0x10,%esp
  801dbe:	85 c0                	test   %eax,%eax
  801dc0:	79 0d                	jns    801dcf <malloc+0x53>
			cur -= t;
  801dc2:	29 1d 58 30 80 00    	sub    %ebx,0x803058
			return null;
  801dc8:	bf 00 00 00 00       	mov    $0x0,%edi
  801dcd:	eb 14                	jmp    801de3 <malloc+0x67>
		}
		cur += PGSIZE;
  801dcf:	81 05 58 30 80 00 00 	addl   $0x1000,0x803058
  801dd6:	10 00 00 
	cur = ROUNDUP(cur, PGSIZE);

	char * ret = cur;
	int r;
	uint32_t t;
	for (t = 0; t < size; t += PGSIZE) {
  801dd9:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801ddf:	39 de                	cmp    %ebx,%esi
  801de1:	77 c6                	ja     801da9 <malloc+0x2d>
			return null;
		}
		cur += PGSIZE;
	}
	return ret;
  801de3:	89 f8                	mov    %edi,%eax
  801de5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801de8:	5b                   	pop    %ebx
  801de9:	5e                   	pop    %esi
  801dea:	5f                   	pop    %edi
  801deb:	c9                   	leave  
  801dec:	c3                   	ret    
  801ded:	00 00                	add    %al,(%eax)
	...

00801df0 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  801df0:	55                   	push   %ebp
  801df1:	89 e5                	mov    %esp,%ebp
  801df3:	57                   	push   %edi
  801df4:	56                   	push   %esi
  801df5:	83 ec 10             	sub    $0x10,%esp
  801df8:	8b 7d 08             	mov    0x8(%ebp),%edi
  801dfb:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  801dfe:	89 7d f0             	mov    %edi,-0x10(%ebp)
  801e01:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  801e04:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  801e07:	8b 45 14             	mov    0x14(%ebp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  801e0a:	85 c0                	test   %eax,%eax
  801e0c:	75 2e                	jne    801e3c <__udivdi3+0x4c>
    {
      if (d0 > n1)
  801e0e:	39 f1                	cmp    %esi,%ecx
  801e10:	77 5a                	ja     801e6c <__udivdi3+0x7c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  801e12:	85 c9                	test   %ecx,%ecx
  801e14:	75 0b                	jne    801e21 <__udivdi3+0x31>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  801e16:	b8 01 00 00 00       	mov    $0x1,%eax
  801e1b:	31 d2                	xor    %edx,%edx
  801e1d:	f7 f1                	div    %ecx
  801e1f:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  801e21:	31 d2                	xor    %edx,%edx
  801e23:	89 f0                	mov    %esi,%eax
  801e25:	f7 f1                	div    %ecx
  801e27:	89 c6                	mov    %eax,%esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801e29:	89 f8                	mov    %edi,%eax
  801e2b:	f7 f1                	div    %ecx
  801e2d:	89 c7                	mov    %eax,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801e2f:	89 f8                	mov    %edi,%eax
  801e31:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801e33:	83 c4 10             	add    $0x10,%esp
  801e36:	5e                   	pop    %esi
  801e37:	5f                   	pop    %edi
  801e38:	c9                   	leave  
  801e39:	c3                   	ret    
  801e3a:	66 90                	xchg   %ax,%ax
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801e3c:	39 f0                	cmp    %esi,%eax
  801e3e:	77 1c                	ja     801e5c <__udivdi3+0x6c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  801e40:	0f bd f8             	bsr    %eax,%edi
	  if (bm == 0)
  801e43:	83 f7 1f             	xor    $0x1f,%edi
  801e46:	75 3c                	jne    801e84 <__udivdi3+0x94>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801e48:	39 f0                	cmp    %esi,%eax
  801e4a:	0f 82 90 00 00 00    	jb     801ee0 <__udivdi3+0xf0>
  801e50:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801e53:	39 55 f4             	cmp    %edx,-0xc(%ebp)
  801e56:	0f 86 84 00 00 00    	jbe    801ee0 <__udivdi3+0xf0>
  801e5c:	31 f6                	xor    %esi,%esi
  801e5e:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801e60:	89 f8                	mov    %edi,%eax
  801e62:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801e64:	83 c4 10             	add    $0x10,%esp
  801e67:	5e                   	pop    %esi
  801e68:	5f                   	pop    %edi
  801e69:	c9                   	leave  
  801e6a:	c3                   	ret    
  801e6b:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801e6c:	89 f2                	mov    %esi,%edx
  801e6e:	89 f8                	mov    %edi,%eax
  801e70:	f7 f1                	div    %ecx
  801e72:	89 c7                	mov    %eax,%edi
  801e74:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801e76:	89 f8                	mov    %edi,%eax
  801e78:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801e7a:	83 c4 10             	add    $0x10,%esp
  801e7d:	5e                   	pop    %esi
  801e7e:	5f                   	pop    %edi
  801e7f:	c9                   	leave  
  801e80:	c3                   	ret    
  801e81:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  801e84:	89 f9                	mov    %edi,%ecx
  801e86:	d3 e0                	shl    %cl,%eax
  801e88:	89 45 e8             	mov    %eax,-0x18(%ebp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  801e8b:	b8 20 00 00 00       	mov    $0x20,%eax
  801e90:	29 f8                	sub    %edi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  801e92:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801e95:	88 c1                	mov    %al,%cl
  801e97:	d3 ea                	shr    %cl,%edx
  801e99:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  801e9c:	09 ca                	or     %ecx,%edx
  801e9e:	89 55 ec             	mov    %edx,-0x14(%ebp)
	      d0 = d0 << bm;
  801ea1:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801ea4:	89 f9                	mov    %edi,%ecx
  801ea6:	d3 e2                	shl    %cl,%edx
  801ea8:	89 55 f4             	mov    %edx,-0xc(%ebp)
	      n2 = n1 >> b;
  801eab:	89 f2                	mov    %esi,%edx
  801ead:	88 c1                	mov    %al,%cl
  801eaf:	d3 ea                	shr    %cl,%edx
  801eb1:	89 55 e8             	mov    %edx,-0x18(%ebp)
	      n1 = (n1 << bm) | (n0 >> b);
  801eb4:	89 f2                	mov    %esi,%edx
  801eb6:	89 f9                	mov    %edi,%ecx
  801eb8:	d3 e2                	shl    %cl,%edx
  801eba:	8b 75 f0             	mov    -0x10(%ebp),%esi
  801ebd:	88 c1                	mov    %al,%cl
  801ebf:	d3 ee                	shr    %cl,%esi
  801ec1:	09 d6                	or     %edx,%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  801ec3:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  801ec6:	89 f0                	mov    %esi,%eax
  801ec8:	89 ca                	mov    %ecx,%edx
  801eca:	f7 75 ec             	divl   -0x14(%ebp)
  801ecd:	89 d1                	mov    %edx,%ecx
  801ecf:	89 c6                	mov    %eax,%esi
	      umul_ppmm (m1, m0, q0, d0);
  801ed1:	f7 65 f4             	mull   -0xc(%ebp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801ed4:	39 d1                	cmp    %edx,%ecx
  801ed6:	72 28                	jb     801f00 <__udivdi3+0x110>
  801ed8:	74 1a                	je     801ef4 <__udivdi3+0x104>
  801eda:	89 f7                	mov    %esi,%edi
  801edc:	31 f6                	xor    %esi,%esi
  801ede:	eb 80                	jmp    801e60 <__udivdi3+0x70>
	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  801ee0:	31 f6                	xor    %esi,%esi
  801ee2:	bf 01 00 00 00       	mov    $0x1,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801ee7:	89 f8                	mov    %edi,%eax
  801ee9:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801eeb:	83 c4 10             	add    $0x10,%esp
  801eee:	5e                   	pop    %esi
  801eef:	5f                   	pop    %edi
  801ef0:	c9                   	leave  
  801ef1:	c3                   	ret    
  801ef2:	66 90                	xchg   %ax,%ax

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  801ef4:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801ef7:	89 f9                	mov    %edi,%ecx
  801ef9:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801efb:	39 c2                	cmp    %eax,%edx
  801efd:	73 db                	jae    801eda <__udivdi3+0xea>
  801eff:	90                   	nop
		{
		  q0--;
  801f00:	8d 7e ff             	lea    -0x1(%esi),%edi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  801f03:	31 f6                	xor    %esi,%esi
  801f05:	e9 56 ff ff ff       	jmp    801e60 <__udivdi3+0x70>
	...

00801f0c <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  801f0c:	55                   	push   %ebp
  801f0d:	89 e5                	mov    %esp,%ebp
  801f0f:	57                   	push   %edi
  801f10:	56                   	push   %esi
  801f11:	83 ec 20             	sub    $0x20,%esp
  801f14:	8b 45 08             	mov    0x8(%ebp),%eax
  801f17:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  801f1a:	89 45 e8             	mov    %eax,-0x18(%ebp)
  801f1d:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  801f20:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  801f23:	8b 7d 14             	mov    0x14(%ebp),%edi
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  801f26:	89 45 f0             	mov    %eax,-0x10(%ebp)
  n1 = nn.s.high;
  801f29:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  801f2b:	85 ff                	test   %edi,%edi
  801f2d:	75 15                	jne    801f44 <__umoddi3+0x38>
    {
      if (d0 > n1)
  801f2f:	39 f1                	cmp    %esi,%ecx
  801f31:	0f 86 99 00 00 00    	jbe    801fd0 <__umoddi3+0xc4>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801f37:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  801f39:	89 d0                	mov    %edx,%eax
  801f3b:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801f3d:	83 c4 20             	add    $0x20,%esp
  801f40:	5e                   	pop    %esi
  801f41:	5f                   	pop    %edi
  801f42:	c9                   	leave  
  801f43:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801f44:	39 f7                	cmp    %esi,%edi
  801f46:	0f 87 a4 00 00 00    	ja     801ff0 <__umoddi3+0xe4>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  801f4c:	0f bd c7             	bsr    %edi,%eax
	  if (bm == 0)
  801f4f:	83 f0 1f             	xor    $0x1f,%eax
  801f52:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801f55:	0f 84 a1 00 00 00    	je     801ffc <__umoddi3+0xf0>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  801f5b:	89 f8                	mov    %edi,%eax
  801f5d:	8a 4d ec             	mov    -0x14(%ebp),%cl
  801f60:	d3 e0                	shl    %cl,%eax
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  801f62:	bf 20 00 00 00       	mov    $0x20,%edi
  801f67:	2b 7d ec             	sub    -0x14(%ebp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  801f6a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801f6d:	89 f9                	mov    %edi,%ecx
  801f6f:	d3 ea                	shr    %cl,%edx
  801f71:	09 c2                	or     %eax,%edx
  801f73:	89 55 f0             	mov    %edx,-0x10(%ebp)
	      d0 = d0 << bm;
  801f76:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f79:	8a 4d ec             	mov    -0x14(%ebp),%cl
  801f7c:	d3 e0                	shl    %cl,%eax
  801f7e:	89 45 f4             	mov    %eax,-0xc(%ebp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  801f81:	89 f2                	mov    %esi,%edx
  801f83:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  801f85:	8b 45 e8             	mov    -0x18(%ebp),%eax
  801f88:	d3 e0                	shl    %cl,%eax
  801f8a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  801f8d:	8b 45 e8             	mov    -0x18(%ebp),%eax
  801f90:	89 f9                	mov    %edi,%ecx
  801f92:	d3 e8                	shr    %cl,%eax
  801f94:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  801f96:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  801f98:	89 f2                	mov    %esi,%edx
  801f9a:	f7 75 f0             	divl   -0x10(%ebp)
  801f9d:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  801f9f:	f7 65 f4             	mull   -0xc(%ebp)
  801fa2:	89 55 e8             	mov    %edx,-0x18(%ebp)
  801fa5:	89 c1                	mov    %eax,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801fa7:	39 d6                	cmp    %edx,%esi
  801fa9:	72 71                	jb     80201c <__umoddi3+0x110>
  801fab:	74 7f                	je     80202c <__umoddi3+0x120>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  801fad:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801fb0:	29 c8                	sub    %ecx,%eax
  801fb2:	19 d6                	sbb    %edx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  801fb4:	8a 4d ec             	mov    -0x14(%ebp),%cl
  801fb7:	d3 e8                	shr    %cl,%eax
  801fb9:	89 f2                	mov    %esi,%edx
  801fbb:	89 f9                	mov    %edi,%ecx
  801fbd:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  801fbf:	09 d0                	or     %edx,%eax
  801fc1:	89 f2                	mov    %esi,%edx
  801fc3:	8a 4d ec             	mov    -0x14(%ebp),%cl
  801fc6:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801fc8:	83 c4 20             	add    $0x20,%esp
  801fcb:	5e                   	pop    %esi
  801fcc:	5f                   	pop    %edi
  801fcd:	c9                   	leave  
  801fce:	c3                   	ret    
  801fcf:	90                   	nop
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  801fd0:	85 c9                	test   %ecx,%ecx
  801fd2:	75 0b                	jne    801fdf <__umoddi3+0xd3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  801fd4:	b8 01 00 00 00       	mov    $0x1,%eax
  801fd9:	31 d2                	xor    %edx,%edx
  801fdb:	f7 f1                	div    %ecx
  801fdd:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  801fdf:	89 f0                	mov    %esi,%eax
  801fe1:	31 d2                	xor    %edx,%edx
  801fe3:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801fe5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801fe8:	f7 f1                	div    %ecx
  801fea:	e9 4a ff ff ff       	jmp    801f39 <__umoddi3+0x2d>
  801fef:	90                   	nop
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  801ff0:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801ff2:	83 c4 20             	add    $0x20,%esp
  801ff5:	5e                   	pop    %esi
  801ff6:	5f                   	pop    %edi
  801ff7:	c9                   	leave  
  801ff8:	c3                   	ret    
  801ff9:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801ffc:	39 f7                	cmp    %esi,%edi
  801ffe:	72 05                	jb     802005 <__umoddi3+0xf9>
  802000:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
  802003:	77 0c                	ja     802011 <__umoddi3+0x105>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  802005:	89 f2                	mov    %esi,%edx
  802007:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80200a:	29 c8                	sub    %ecx,%eax
  80200c:	19 fa                	sbb    %edi,%edx
  80200e:	89 45 f0             	mov    %eax,-0x10(%ebp)

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  802011:	8b 45 f0             	mov    -0x10(%ebp),%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802014:	83 c4 20             	add    $0x20,%esp
  802017:	5e                   	pop    %esi
  802018:	5f                   	pop    %edi
  802019:	c9                   	leave  
  80201a:	c3                   	ret    
  80201b:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  80201c:	8b 55 e8             	mov    -0x18(%ebp),%edx
  80201f:	89 c1                	mov    %eax,%ecx
  802021:	2b 4d f4             	sub    -0xc(%ebp),%ecx
  802024:	1b 55 f0             	sbb    -0x10(%ebp),%edx
  802027:	eb 84                	jmp    801fad <__umoddi3+0xa1>
  802029:	8d 76 00             	lea    0x0(%esi),%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  80202c:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  80202f:	72 eb                	jb     80201c <__umoddi3+0x110>
  802031:	89 f2                	mov    %esi,%edx
  802033:	e9 75 ff ff ff       	jmp    801fad <__umoddi3+0xa1>
