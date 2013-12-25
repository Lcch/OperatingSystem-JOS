
obj/user/hello.debug:     file format elf32-i386


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
  80002c:	e8 eb 00 00 00       	call   80011c <libmain>
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
  800049:	68 86 20 80 00       	push   $0x802086
  80004e:	e8 c1 01 00 00       	call   800214 <cprintf>
		pthread_mutex_lock(&Lock);
  800053:	c7 04 24 0c 40 80 00 	movl   $0x80400c,(%esp)
  80005a:	e8 e4 19 00 00       	call   801a43 <pthread_mutex_lock>
		t = sum;
  80005f:	8b 15 04 40 80 00    	mov    0x804004,%edx
  800065:	8b 0d 08 40 80 00    	mov    0x804008,%ecx
  80006b:	83 c4 10             	add    $0x10,%esp
  80006e:	b8 0a 00 00 00       	mov    $0xa,%eax
		for (g = 0; g != 10; g++) k++;
  800073:	48                   	dec    %eax
  800074:	75 fd                	jne    800073 <mythread+0x3f>
  800076:	83 c1 0a             	add    $0xa,%ecx
		++t;
  800079:	42                   	inc    %edx
		for (g = 0; g != 10; g++) k++;
  80007a:	b8 00 00 00 00       	mov    $0x0,%eax
  80007f:	40                   	inc    %eax
  800080:	83 f8 0a             	cmp    $0xa,%eax
  800083:	75 fa                	jne    80007f <mythread+0x4b>
  800085:	8d 41 0a             	lea    0xa(%ecx),%eax
  800088:	a3 08 40 80 00       	mov    %eax,0x804008
		sum = t;
  80008d:	89 15 04 40 80 00    	mov    %edx,0x804004
		pthread_mutex_unlock(&Lock);
  800093:	83 ec 0c             	sub    $0xc,%esp
  800096:	68 0c 40 80 00       	push   $0x80400c
  80009b:	e8 bf 19 00 00       	call   801a5f <pthread_mutex_unlock>
int sum;
int k;

void mythread(void * arg) {
	int i, t, g;
	for (i = 0; i != 10000; i++) {
  8000a0:	83 c4 10             	add    $0x10,%esp
  8000a3:	4b                   	dec    %ebx
  8000a4:	75 9a                	jne    800040 <mythread+0xc>
		++t;
		for (g = 0; g != 10; g++) k++;
		sum = t;
		pthread_mutex_unlock(&Lock);
	}
}
  8000a6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000a9:	c9                   	leave  
  8000aa:	c3                   	ret    

008000ab <umain>:

void
umain(int argc, char **argv)
{
  8000ab:	55                   	push   %ebp
  8000ac:	89 e5                	mov    %esp,%ebp
  8000ae:	83 ec 24             	sub    $0x24,%esp
	pthread_mutex_init(&Lock);
  8000b1:	68 0c 40 80 00       	push   $0x80400c
  8000b6:	e8 75 19 00 00       	call   801a30 <pthread_mutex_init>
	uint32_t id[2];
	sum = 0;
  8000bb:	c7 05 04 40 80 00 00 	movl   $0x0,0x804004
  8000c2:	00 00 00 
	pthread_create(&id[0], mythread, NULL);
  8000c5:	83 c4 0c             	add    $0xc,%esp
  8000c8:	6a 00                	push   $0x0
  8000ca:	68 34 00 80 00       	push   $0x800034
  8000cf:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8000d2:	50                   	push   %eax
  8000d3:	e8 44 18 00 00       	call   80191c <pthread_create>
	pthread_create(&id[1], mythread, NULL);
  8000d8:	83 c4 0c             	add    $0xc,%esp
  8000db:	6a 00                	push   $0x0
  8000dd:	68 34 00 80 00       	push   $0x800034
  8000e2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8000e5:	50                   	push   %eax
  8000e6:	e8 31 18 00 00       	call   80191c <pthread_create>
	pthread_join(id[0]);
  8000eb:	83 c4 04             	add    $0x4,%esp
  8000ee:	ff 75 f0             	pushl  -0x10(%ebp)
  8000f1:	e8 14 19 00 00       	call   801a0a <pthread_join>
	pthread_join(id[1]);
  8000f6:	83 c4 04             	add    $0x4,%esp
  8000f9:	ff 75 f4             	pushl  -0xc(%ebp)
  8000fc:	e8 09 19 00 00       	call   801a0a <pthread_join>
	cprintf("HAHA: %d\n", sum);
  800101:	83 c4 08             	add    $0x8,%esp
  800104:	ff 35 04 40 80 00    	pushl  0x804004
  80010a:	68 80 20 80 00       	push   $0x802080
  80010f:	e8 00 01 00 00       	call   800214 <cprintf>
  800114:	83 c4 10             	add    $0x10,%esp
}
  800117:	c9                   	leave  
  800118:	c3                   	ret    
  800119:	00 00                	add    %al,(%eax)
	...

0080011c <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80011c:	55                   	push   %ebp
  80011d:	89 e5                	mov    %esp,%ebp
  80011f:	56                   	push   %esi
  800120:	53                   	push   %ebx
  800121:	8b 75 08             	mov    0x8(%ebp),%esi
  800124:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs + ENVX(sys_getenvid());
  800127:	e8 d5 0a 00 00       	call   800c01 <sys_getenvid>
  80012c:	25 ff 03 00 00       	and    $0x3ff,%eax
  800131:	89 c2                	mov    %eax,%edx
  800133:	c1 e2 07             	shl    $0x7,%edx
  800136:	8d 84 82 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,4),%eax
  80013d:	a3 10 40 80 00       	mov    %eax,0x804010

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800142:	85 f6                	test   %esi,%esi
  800144:	7e 07                	jle    80014d <libmain+0x31>
		binaryname = argv[0];
  800146:	8b 03                	mov    (%ebx),%eax
  800148:	a3 00 30 80 00       	mov    %eax,0x803000
	// call user main routine
	umain(argc, argv);
  80014d:	83 ec 08             	sub    $0x8,%esp
  800150:	53                   	push   %ebx
  800151:	56                   	push   %esi
  800152:	e8 54 ff ff ff       	call   8000ab <umain>

	// exit gracefully
	exit();
  800157:	e8 0c 00 00 00       	call   800168 <exit>
  80015c:	83 c4 10             	add    $0x10,%esp
}
  80015f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800162:	5b                   	pop    %ebx
  800163:	5e                   	pop    %esi
  800164:	c9                   	leave  
  800165:	c3                   	ret    
	...

00800168 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800168:	55                   	push   %ebp
  800169:	89 e5                	mov    %esp,%ebp
  80016b:	83 ec 08             	sub    $0x8,%esp
	close_all();
  80016e:	e8 8f 0e 00 00       	call   801002 <close_all>
	sys_env_destroy(0);
  800173:	83 ec 0c             	sub    $0xc,%esp
  800176:	6a 00                	push   $0x0
  800178:	e8 62 0a 00 00       	call   800bdf <sys_env_destroy>
  80017d:	83 c4 10             	add    $0x10,%esp
}
  800180:	c9                   	leave  
  800181:	c3                   	ret    
	...

00800184 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800184:	55                   	push   %ebp
  800185:	89 e5                	mov    %esp,%ebp
  800187:	53                   	push   %ebx
  800188:	83 ec 04             	sub    $0x4,%esp
  80018b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80018e:	8b 03                	mov    (%ebx),%eax
  800190:	8b 55 08             	mov    0x8(%ebp),%edx
  800193:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  800197:	40                   	inc    %eax
  800198:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  80019a:	3d ff 00 00 00       	cmp    $0xff,%eax
  80019f:	75 1a                	jne    8001bb <putch+0x37>
		sys_cputs(b->buf, b->idx);
  8001a1:	83 ec 08             	sub    $0x8,%esp
  8001a4:	68 ff 00 00 00       	push   $0xff
  8001a9:	8d 43 08             	lea    0x8(%ebx),%eax
  8001ac:	50                   	push   %eax
  8001ad:	e8 e3 09 00 00       	call   800b95 <sys_cputs>
		b->idx = 0;
  8001b2:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001b8:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8001bb:	ff 43 04             	incl   0x4(%ebx)
}
  8001be:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001c1:	c9                   	leave  
  8001c2:	c3                   	ret    

008001c3 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001c3:	55                   	push   %ebp
  8001c4:	89 e5                	mov    %esp,%ebp
  8001c6:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001cc:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001d3:	00 00 00 
	b.cnt = 0;
  8001d6:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001dd:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001e0:	ff 75 0c             	pushl  0xc(%ebp)
  8001e3:	ff 75 08             	pushl  0x8(%ebp)
  8001e6:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001ec:	50                   	push   %eax
  8001ed:	68 84 01 80 00       	push   $0x800184
  8001f2:	e8 82 01 00 00       	call   800379 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001f7:	83 c4 08             	add    $0x8,%esp
  8001fa:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800200:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800206:	50                   	push   %eax
  800207:	e8 89 09 00 00       	call   800b95 <sys_cputs>

	return b.cnt;
}
  80020c:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800212:	c9                   	leave  
  800213:	c3                   	ret    

00800214 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800214:	55                   	push   %ebp
  800215:	89 e5                	mov    %esp,%ebp
  800217:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80021a:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80021d:	50                   	push   %eax
  80021e:	ff 75 08             	pushl  0x8(%ebp)
  800221:	e8 9d ff ff ff       	call   8001c3 <vcprintf>
	va_end(ap);

	return cnt;
}
  800226:	c9                   	leave  
  800227:	c3                   	ret    

00800228 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800228:	55                   	push   %ebp
  800229:	89 e5                	mov    %esp,%ebp
  80022b:	57                   	push   %edi
  80022c:	56                   	push   %esi
  80022d:	53                   	push   %ebx
  80022e:	83 ec 2c             	sub    $0x2c,%esp
  800231:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800234:	89 d6                	mov    %edx,%esi
  800236:	8b 45 08             	mov    0x8(%ebp),%eax
  800239:	8b 55 0c             	mov    0xc(%ebp),%edx
  80023c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80023f:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800242:	8b 45 10             	mov    0x10(%ebp),%eax
  800245:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800248:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80024b:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80024e:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  800255:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
  800258:	72 0c                	jb     800266 <printnum+0x3e>
  80025a:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  80025d:	76 07                	jbe    800266 <printnum+0x3e>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80025f:	4b                   	dec    %ebx
  800260:	85 db                	test   %ebx,%ebx
  800262:	7f 31                	jg     800295 <printnum+0x6d>
  800264:	eb 3f                	jmp    8002a5 <printnum+0x7d>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800266:	83 ec 0c             	sub    $0xc,%esp
  800269:	57                   	push   %edi
  80026a:	4b                   	dec    %ebx
  80026b:	53                   	push   %ebx
  80026c:	50                   	push   %eax
  80026d:	83 ec 08             	sub    $0x8,%esp
  800270:	ff 75 d4             	pushl  -0x2c(%ebp)
  800273:	ff 75 d0             	pushl  -0x30(%ebp)
  800276:	ff 75 dc             	pushl  -0x24(%ebp)
  800279:	ff 75 d8             	pushl  -0x28(%ebp)
  80027c:	e8 9b 1b 00 00       	call   801e1c <__udivdi3>
  800281:	83 c4 18             	add    $0x18,%esp
  800284:	52                   	push   %edx
  800285:	50                   	push   %eax
  800286:	89 f2                	mov    %esi,%edx
  800288:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80028b:	e8 98 ff ff ff       	call   800228 <printnum>
  800290:	83 c4 20             	add    $0x20,%esp
  800293:	eb 10                	jmp    8002a5 <printnum+0x7d>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800295:	83 ec 08             	sub    $0x8,%esp
  800298:	56                   	push   %esi
  800299:	57                   	push   %edi
  80029a:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80029d:	4b                   	dec    %ebx
  80029e:	83 c4 10             	add    $0x10,%esp
  8002a1:	85 db                	test   %ebx,%ebx
  8002a3:	7f f0                	jg     800295 <printnum+0x6d>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002a5:	83 ec 08             	sub    $0x8,%esp
  8002a8:	56                   	push   %esi
  8002a9:	83 ec 04             	sub    $0x4,%esp
  8002ac:	ff 75 d4             	pushl  -0x2c(%ebp)
  8002af:	ff 75 d0             	pushl  -0x30(%ebp)
  8002b2:	ff 75 dc             	pushl  -0x24(%ebp)
  8002b5:	ff 75 d8             	pushl  -0x28(%ebp)
  8002b8:	e8 7b 1c 00 00       	call   801f38 <__umoddi3>
  8002bd:	83 c4 14             	add    $0x14,%esp
  8002c0:	0f be 80 94 20 80 00 	movsbl 0x802094(%eax),%eax
  8002c7:	50                   	push   %eax
  8002c8:	ff 55 e4             	call   *-0x1c(%ebp)
  8002cb:	83 c4 10             	add    $0x10,%esp
}
  8002ce:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002d1:	5b                   	pop    %ebx
  8002d2:	5e                   	pop    %esi
  8002d3:	5f                   	pop    %edi
  8002d4:	c9                   	leave  
  8002d5:	c3                   	ret    

008002d6 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002d6:	55                   	push   %ebp
  8002d7:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002d9:	83 fa 01             	cmp    $0x1,%edx
  8002dc:	7e 0e                	jle    8002ec <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8002de:	8b 10                	mov    (%eax),%edx
  8002e0:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002e3:	89 08                	mov    %ecx,(%eax)
  8002e5:	8b 02                	mov    (%edx),%eax
  8002e7:	8b 52 04             	mov    0x4(%edx),%edx
  8002ea:	eb 22                	jmp    80030e <getuint+0x38>
	else if (lflag)
  8002ec:	85 d2                	test   %edx,%edx
  8002ee:	74 10                	je     800300 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8002f0:	8b 10                	mov    (%eax),%edx
  8002f2:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002f5:	89 08                	mov    %ecx,(%eax)
  8002f7:	8b 02                	mov    (%edx),%eax
  8002f9:	ba 00 00 00 00       	mov    $0x0,%edx
  8002fe:	eb 0e                	jmp    80030e <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800300:	8b 10                	mov    (%eax),%edx
  800302:	8d 4a 04             	lea    0x4(%edx),%ecx
  800305:	89 08                	mov    %ecx,(%eax)
  800307:	8b 02                	mov    (%edx),%eax
  800309:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80030e:	c9                   	leave  
  80030f:	c3                   	ret    

00800310 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  800310:	55                   	push   %ebp
  800311:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800313:	83 fa 01             	cmp    $0x1,%edx
  800316:	7e 0e                	jle    800326 <getint+0x16>
		return va_arg(*ap, long long);
  800318:	8b 10                	mov    (%eax),%edx
  80031a:	8d 4a 08             	lea    0x8(%edx),%ecx
  80031d:	89 08                	mov    %ecx,(%eax)
  80031f:	8b 02                	mov    (%edx),%eax
  800321:	8b 52 04             	mov    0x4(%edx),%edx
  800324:	eb 1a                	jmp    800340 <getint+0x30>
	else if (lflag)
  800326:	85 d2                	test   %edx,%edx
  800328:	74 0c                	je     800336 <getint+0x26>
		return va_arg(*ap, long);
  80032a:	8b 10                	mov    (%eax),%edx
  80032c:	8d 4a 04             	lea    0x4(%edx),%ecx
  80032f:	89 08                	mov    %ecx,(%eax)
  800331:	8b 02                	mov    (%edx),%eax
  800333:	99                   	cltd   
  800334:	eb 0a                	jmp    800340 <getint+0x30>
	else
		return va_arg(*ap, int);
  800336:	8b 10                	mov    (%eax),%edx
  800338:	8d 4a 04             	lea    0x4(%edx),%ecx
  80033b:	89 08                	mov    %ecx,(%eax)
  80033d:	8b 02                	mov    (%edx),%eax
  80033f:	99                   	cltd   
}
  800340:	c9                   	leave  
  800341:	c3                   	ret    

00800342 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800342:	55                   	push   %ebp
  800343:	89 e5                	mov    %esp,%ebp
  800345:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800348:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  80034b:	8b 10                	mov    (%eax),%edx
  80034d:	3b 50 04             	cmp    0x4(%eax),%edx
  800350:	73 08                	jae    80035a <sprintputch+0x18>
		*b->buf++ = ch;
  800352:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800355:	88 0a                	mov    %cl,(%edx)
  800357:	42                   	inc    %edx
  800358:	89 10                	mov    %edx,(%eax)
}
  80035a:	c9                   	leave  
  80035b:	c3                   	ret    

0080035c <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80035c:	55                   	push   %ebp
  80035d:	89 e5                	mov    %esp,%ebp
  80035f:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800362:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800365:	50                   	push   %eax
  800366:	ff 75 10             	pushl  0x10(%ebp)
  800369:	ff 75 0c             	pushl  0xc(%ebp)
  80036c:	ff 75 08             	pushl  0x8(%ebp)
  80036f:	e8 05 00 00 00       	call   800379 <vprintfmt>
	va_end(ap);
  800374:	83 c4 10             	add    $0x10,%esp
}
  800377:	c9                   	leave  
  800378:	c3                   	ret    

00800379 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800379:	55                   	push   %ebp
  80037a:	89 e5                	mov    %esp,%ebp
  80037c:	57                   	push   %edi
  80037d:	56                   	push   %esi
  80037e:	53                   	push   %ebx
  80037f:	83 ec 2c             	sub    $0x2c,%esp
  800382:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800385:	8b 75 10             	mov    0x10(%ebp),%esi
  800388:	eb 13                	jmp    80039d <vprintfmt+0x24>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80038a:	85 c0                	test   %eax,%eax
  80038c:	0f 84 6d 03 00 00    	je     8006ff <vprintfmt+0x386>
				return;
			putch(ch, putdat);
  800392:	83 ec 08             	sub    $0x8,%esp
  800395:	57                   	push   %edi
  800396:	50                   	push   %eax
  800397:	ff 55 08             	call   *0x8(%ebp)
  80039a:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80039d:	0f b6 06             	movzbl (%esi),%eax
  8003a0:	46                   	inc    %esi
  8003a1:	83 f8 25             	cmp    $0x25,%eax
  8003a4:	75 e4                	jne    80038a <vprintfmt+0x11>
  8003a6:	c6 45 dc 20          	movb   $0x20,-0x24(%ebp)
  8003aa:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  8003b1:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  8003b8:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  8003bf:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003c4:	eb 28                	jmp    8003ee <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003c6:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  8003c8:	c6 45 dc 2d          	movb   $0x2d,-0x24(%ebp)
  8003cc:	eb 20                	jmp    8003ee <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ce:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8003d0:	c6 45 dc 30          	movb   $0x30,-0x24(%ebp)
  8003d4:	eb 18                	jmp    8003ee <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003d6:	89 de                	mov    %ebx,%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  8003d8:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8003df:	eb 0d                	jmp    8003ee <vprintfmt+0x75>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  8003e1:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8003e4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003e7:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ee:	8a 06                	mov    (%esi),%al
  8003f0:	0f b6 d0             	movzbl %al,%edx
  8003f3:	8d 5e 01             	lea    0x1(%esi),%ebx
  8003f6:	83 e8 23             	sub    $0x23,%eax
  8003f9:	3c 55                	cmp    $0x55,%al
  8003fb:	0f 87 e0 02 00 00    	ja     8006e1 <vprintfmt+0x368>
  800401:	0f b6 c0             	movzbl %al,%eax
  800404:	ff 24 85 e0 21 80 00 	jmp    *0x8021e0(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80040b:	83 ea 30             	sub    $0x30,%edx
  80040e:	89 55 d4             	mov    %edx,-0x2c(%ebp)
				ch = *fmt;
  800411:	0f be 03             	movsbl (%ebx),%eax
				if (ch < '0' || ch > '9')
  800414:	8d 50 d0             	lea    -0x30(%eax),%edx
  800417:	83 fa 09             	cmp    $0x9,%edx
  80041a:	77 44                	ja     800460 <vprintfmt+0xe7>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80041c:	89 de                	mov    %ebx,%esi
  80041e:	8b 55 d4             	mov    -0x2c(%ebp),%edx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800421:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
  800422:	8d 14 92             	lea    (%edx,%edx,4),%edx
  800425:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
  800429:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  80042c:	8d 58 d0             	lea    -0x30(%eax),%ebx
  80042f:	83 fb 09             	cmp    $0x9,%ebx
  800432:	76 ed                	jbe    800421 <vprintfmt+0xa8>
  800434:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  800437:	eb 29                	jmp    800462 <vprintfmt+0xe9>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800439:	8b 45 14             	mov    0x14(%ebp),%eax
  80043c:	8d 50 04             	lea    0x4(%eax),%edx
  80043f:	89 55 14             	mov    %edx,0x14(%ebp)
  800442:	8b 00                	mov    (%eax),%eax
  800444:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800447:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800449:	eb 17                	jmp    800462 <vprintfmt+0xe9>

		case '.':
			if (width < 0)
  80044b:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80044f:	78 85                	js     8003d6 <vprintfmt+0x5d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800451:	89 de                	mov    %ebx,%esi
  800453:	eb 99                	jmp    8003ee <vprintfmt+0x75>
  800455:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800457:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  80045e:	eb 8e                	jmp    8003ee <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800460:	89 de                	mov    %ebx,%esi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  800462:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800466:	79 86                	jns    8003ee <vprintfmt+0x75>
  800468:	e9 74 ff ff ff       	jmp    8003e1 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80046d:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80046e:	89 de                	mov    %ebx,%esi
  800470:	e9 79 ff ff ff       	jmp    8003ee <vprintfmt+0x75>
  800475:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800478:	8b 45 14             	mov    0x14(%ebp),%eax
  80047b:	8d 50 04             	lea    0x4(%eax),%edx
  80047e:	89 55 14             	mov    %edx,0x14(%ebp)
  800481:	83 ec 08             	sub    $0x8,%esp
  800484:	57                   	push   %edi
  800485:	ff 30                	pushl  (%eax)
  800487:	ff 55 08             	call   *0x8(%ebp)
			break;
  80048a:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80048d:	8b 75 d8             	mov    -0x28(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800490:	e9 08 ff ff ff       	jmp    80039d <vprintfmt+0x24>
  800495:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  800498:	8b 45 14             	mov    0x14(%ebp),%eax
  80049b:	8d 50 04             	lea    0x4(%eax),%edx
  80049e:	89 55 14             	mov    %edx,0x14(%ebp)
  8004a1:	8b 00                	mov    (%eax),%eax
  8004a3:	85 c0                	test   %eax,%eax
  8004a5:	79 02                	jns    8004a9 <vprintfmt+0x130>
  8004a7:	f7 d8                	neg    %eax
  8004a9:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004ab:	83 f8 0f             	cmp    $0xf,%eax
  8004ae:	7f 0b                	jg     8004bb <vprintfmt+0x142>
  8004b0:	8b 04 85 40 23 80 00 	mov    0x802340(,%eax,4),%eax
  8004b7:	85 c0                	test   %eax,%eax
  8004b9:	75 1a                	jne    8004d5 <vprintfmt+0x15c>
				printfmt(putch, putdat, "error %d", err);
  8004bb:	52                   	push   %edx
  8004bc:	68 ac 20 80 00       	push   $0x8020ac
  8004c1:	57                   	push   %edi
  8004c2:	ff 75 08             	pushl  0x8(%ebp)
  8004c5:	e8 92 fe ff ff       	call   80035c <printfmt>
  8004ca:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004cd:	8b 75 d8             	mov    -0x28(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8004d0:	e9 c8 fe ff ff       	jmp    80039d <vprintfmt+0x24>
			else
				printfmt(putch, putdat, "%s", p);
  8004d5:	50                   	push   %eax
  8004d6:	68 71 24 80 00       	push   $0x802471
  8004db:	57                   	push   %edi
  8004dc:	ff 75 08             	pushl  0x8(%ebp)
  8004df:	e8 78 fe ff ff       	call   80035c <printfmt>
  8004e4:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004e7:	8b 75 d8             	mov    -0x28(%ebp),%esi
  8004ea:	e9 ae fe ff ff       	jmp    80039d <vprintfmt+0x24>
  8004ef:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  8004f2:	89 de                	mov    %ebx,%esi
  8004f4:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  8004f7:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004fa:	8b 45 14             	mov    0x14(%ebp),%eax
  8004fd:	8d 50 04             	lea    0x4(%eax),%edx
  800500:	89 55 14             	mov    %edx,0x14(%ebp)
  800503:	8b 00                	mov    (%eax),%eax
  800505:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800508:	85 c0                	test   %eax,%eax
  80050a:	75 07                	jne    800513 <vprintfmt+0x19a>
				p = "(null)";
  80050c:	c7 45 d0 a5 20 80 00 	movl   $0x8020a5,-0x30(%ebp)
			if (width > 0 && padc != '-')
  800513:	85 db                	test   %ebx,%ebx
  800515:	7e 42                	jle    800559 <vprintfmt+0x1e0>
  800517:	80 7d dc 2d          	cmpb   $0x2d,-0x24(%ebp)
  80051b:	74 3c                	je     800559 <vprintfmt+0x1e0>
				for (width -= strnlen(p, precision); width > 0; width--)
  80051d:	83 ec 08             	sub    $0x8,%esp
  800520:	51                   	push   %ecx
  800521:	ff 75 d0             	pushl  -0x30(%ebp)
  800524:	e8 6f 02 00 00       	call   800798 <strnlen>
  800529:	29 c3                	sub    %eax,%ebx
  80052b:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80052e:	83 c4 10             	add    $0x10,%esp
  800531:	85 db                	test   %ebx,%ebx
  800533:	7e 24                	jle    800559 <vprintfmt+0x1e0>
					putch(padc, putdat);
  800535:	0f be 5d dc          	movsbl -0x24(%ebp),%ebx
  800539:	89 75 dc             	mov    %esi,-0x24(%ebp)
  80053c:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  80053f:	83 ec 08             	sub    $0x8,%esp
  800542:	57                   	push   %edi
  800543:	53                   	push   %ebx
  800544:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800547:	4e                   	dec    %esi
  800548:	83 c4 10             	add    $0x10,%esp
  80054b:	85 f6                	test   %esi,%esi
  80054d:	7f f0                	jg     80053f <vprintfmt+0x1c6>
  80054f:	8b 75 dc             	mov    -0x24(%ebp),%esi
  800552:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800559:	8b 55 d0             	mov    -0x30(%ebp),%edx
  80055c:	0f be 02             	movsbl (%edx),%eax
  80055f:	85 c0                	test   %eax,%eax
  800561:	75 47                	jne    8005aa <vprintfmt+0x231>
  800563:	eb 37                	jmp    80059c <vprintfmt+0x223>
				if (altflag && (ch < ' ' || ch > '~'))
  800565:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800569:	74 16                	je     800581 <vprintfmt+0x208>
  80056b:	8d 50 e0             	lea    -0x20(%eax),%edx
  80056e:	83 fa 5e             	cmp    $0x5e,%edx
  800571:	76 0e                	jbe    800581 <vprintfmt+0x208>
					putch('?', putdat);
  800573:	83 ec 08             	sub    $0x8,%esp
  800576:	57                   	push   %edi
  800577:	6a 3f                	push   $0x3f
  800579:	ff 55 08             	call   *0x8(%ebp)
  80057c:	83 c4 10             	add    $0x10,%esp
  80057f:	eb 0b                	jmp    80058c <vprintfmt+0x213>
				else
					putch(ch, putdat);
  800581:	83 ec 08             	sub    $0x8,%esp
  800584:	57                   	push   %edi
  800585:	50                   	push   %eax
  800586:	ff 55 08             	call   *0x8(%ebp)
  800589:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80058c:	ff 4d e4             	decl   -0x1c(%ebp)
  80058f:	0f be 03             	movsbl (%ebx),%eax
  800592:	85 c0                	test   %eax,%eax
  800594:	74 03                	je     800599 <vprintfmt+0x220>
  800596:	43                   	inc    %ebx
  800597:	eb 1b                	jmp    8005b4 <vprintfmt+0x23b>
  800599:	8b 75 dc             	mov    -0x24(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80059c:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8005a0:	7f 1e                	jg     8005c0 <vprintfmt+0x247>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005a2:	8b 75 d8             	mov    -0x28(%ebp),%esi
  8005a5:	e9 f3 fd ff ff       	jmp    80039d <vprintfmt+0x24>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005aa:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  8005ad:	43                   	inc    %ebx
  8005ae:	89 75 dc             	mov    %esi,-0x24(%ebp)
  8005b1:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  8005b4:	85 f6                	test   %esi,%esi
  8005b6:	78 ad                	js     800565 <vprintfmt+0x1ec>
  8005b8:	4e                   	dec    %esi
  8005b9:	79 aa                	jns    800565 <vprintfmt+0x1ec>
  8005bb:	8b 75 dc             	mov    -0x24(%ebp),%esi
  8005be:	eb dc                	jmp    80059c <vprintfmt+0x223>
  8005c0:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8005c3:	83 ec 08             	sub    $0x8,%esp
  8005c6:	57                   	push   %edi
  8005c7:	6a 20                	push   $0x20
  8005c9:	ff 55 08             	call   *0x8(%ebp)
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005cc:	4b                   	dec    %ebx
  8005cd:	83 c4 10             	add    $0x10,%esp
  8005d0:	85 db                	test   %ebx,%ebx
  8005d2:	7f ef                	jg     8005c3 <vprintfmt+0x24a>
  8005d4:	e9 c4 fd ff ff       	jmp    80039d <vprintfmt+0x24>
  8005d9:	89 5d d8             	mov    %ebx,-0x28(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8005dc:	89 ca                	mov    %ecx,%edx
  8005de:	8d 45 14             	lea    0x14(%ebp),%eax
  8005e1:	e8 2a fd ff ff       	call   800310 <getint>
  8005e6:	89 c3                	mov    %eax,%ebx
  8005e8:	89 d6                	mov    %edx,%esi
			if ((long long) num < 0) {
  8005ea:	85 d2                	test   %edx,%edx
  8005ec:	78 0a                	js     8005f8 <vprintfmt+0x27f>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8005ee:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005f3:	e9 b0 00 00 00       	jmp    8006a8 <vprintfmt+0x32f>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  8005f8:	83 ec 08             	sub    $0x8,%esp
  8005fb:	57                   	push   %edi
  8005fc:	6a 2d                	push   $0x2d
  8005fe:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800601:	f7 db                	neg    %ebx
  800603:	83 d6 00             	adc    $0x0,%esi
  800606:	f7 de                	neg    %esi
  800608:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  80060b:	b8 0a 00 00 00       	mov    $0xa,%eax
  800610:	e9 93 00 00 00       	jmp    8006a8 <vprintfmt+0x32f>
  800615:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800618:	89 ca                	mov    %ecx,%edx
  80061a:	8d 45 14             	lea    0x14(%ebp),%eax
  80061d:	e8 b4 fc ff ff       	call   8002d6 <getuint>
  800622:	89 c3                	mov    %eax,%ebx
  800624:	89 d6                	mov    %edx,%esi
			base = 10;
  800626:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  80062b:	eb 7b                	jmp    8006a8 <vprintfmt+0x32f>
  80062d:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
  800630:	89 ca                	mov    %ecx,%edx
  800632:	8d 45 14             	lea    0x14(%ebp),%eax
  800635:	e8 d6 fc ff ff       	call   800310 <getint>
  80063a:	89 c3                	mov    %eax,%ebx
  80063c:	89 d6                	mov    %edx,%esi
            if ((long long) num < 0) {
  80063e:	85 d2                	test   %edx,%edx
  800640:	78 07                	js     800649 <vprintfmt+0x2d0>
                putch('-', putdat);
                num = -(long long) num;
            }
            base = 8;
  800642:	b8 08 00 00 00       	mov    $0x8,%eax
  800647:	eb 5f                	jmp    8006a8 <vprintfmt+0x32f>
		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
            if ((long long) num < 0) {
                putch('-', putdat);
  800649:	83 ec 08             	sub    $0x8,%esp
  80064c:	57                   	push   %edi
  80064d:	6a 2d                	push   $0x2d
  80064f:	ff 55 08             	call   *0x8(%ebp)
                num = -(long long) num;
  800652:	f7 db                	neg    %ebx
  800654:	83 d6 00             	adc    $0x0,%esi
  800657:	f7 de                	neg    %esi
  800659:	83 c4 10             	add    $0x10,%esp
            }
            base = 8;
  80065c:	b8 08 00 00 00       	mov    $0x8,%eax
  800661:	eb 45                	jmp    8006a8 <vprintfmt+0x32f>
  800663:	89 5d d8             	mov    %ebx,-0x28(%ebp)
            goto number;

        // pointer
		case 'p':
			putch('0', putdat);
  800666:	83 ec 08             	sub    $0x8,%esp
  800669:	57                   	push   %edi
  80066a:	6a 30                	push   $0x30
  80066c:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  80066f:	83 c4 08             	add    $0x8,%esp
  800672:	57                   	push   %edi
  800673:	6a 78                	push   $0x78
  800675:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800678:	8b 45 14             	mov    0x14(%ebp),%eax
  80067b:	8d 50 04             	lea    0x4(%eax),%edx
  80067e:	89 55 14             	mov    %edx,0x14(%ebp)

        // pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800681:	8b 18                	mov    (%eax),%ebx
  800683:	be 00 00 00 00       	mov    $0x0,%esi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800688:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80068b:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800690:	eb 16                	jmp    8006a8 <vprintfmt+0x32f>
  800692:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800695:	89 ca                	mov    %ecx,%edx
  800697:	8d 45 14             	lea    0x14(%ebp),%eax
  80069a:	e8 37 fc ff ff       	call   8002d6 <getuint>
  80069f:	89 c3                	mov    %eax,%ebx
  8006a1:	89 d6                	mov    %edx,%esi
			base = 16;
  8006a3:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006a8:	83 ec 0c             	sub    $0xc,%esp
  8006ab:	0f be 55 dc          	movsbl -0x24(%ebp),%edx
  8006af:	52                   	push   %edx
  8006b0:	ff 75 e4             	pushl  -0x1c(%ebp)
  8006b3:	50                   	push   %eax
  8006b4:	56                   	push   %esi
  8006b5:	53                   	push   %ebx
  8006b6:	89 fa                	mov    %edi,%edx
  8006b8:	8b 45 08             	mov    0x8(%ebp),%eax
  8006bb:	e8 68 fb ff ff       	call   800228 <printnum>
			break;
  8006c0:	83 c4 20             	add    $0x20,%esp
  8006c3:	8b 75 d8             	mov    -0x28(%ebp),%esi
  8006c6:	e9 d2 fc ff ff       	jmp    80039d <vprintfmt+0x24>
  8006cb:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006ce:	83 ec 08             	sub    $0x8,%esp
  8006d1:	57                   	push   %edi
  8006d2:	52                   	push   %edx
  8006d3:	ff 55 08             	call   *0x8(%ebp)
			break;
  8006d6:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006d9:	8b 75 d8             	mov    -0x28(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8006dc:	e9 bc fc ff ff       	jmp    80039d <vprintfmt+0x24>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8006e1:	83 ec 08             	sub    $0x8,%esp
  8006e4:	57                   	push   %edi
  8006e5:	6a 25                	push   $0x25
  8006e7:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006ea:	83 c4 10             	add    $0x10,%esp
  8006ed:	eb 02                	jmp    8006f1 <vprintfmt+0x378>
  8006ef:	89 c6                	mov    %eax,%esi
  8006f1:	8d 46 ff             	lea    -0x1(%esi),%eax
  8006f4:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  8006f8:	75 f5                	jne    8006ef <vprintfmt+0x376>
  8006fa:	e9 9e fc ff ff       	jmp    80039d <vprintfmt+0x24>
				/* do nothing */;
			break;
		}
	}
}
  8006ff:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800702:	5b                   	pop    %ebx
  800703:	5e                   	pop    %esi
  800704:	5f                   	pop    %edi
  800705:	c9                   	leave  
  800706:	c3                   	ret    

00800707 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800707:	55                   	push   %ebp
  800708:	89 e5                	mov    %esp,%ebp
  80070a:	83 ec 18             	sub    $0x18,%esp
  80070d:	8b 45 08             	mov    0x8(%ebp),%eax
  800710:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800713:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800716:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80071a:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80071d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800724:	85 c0                	test   %eax,%eax
  800726:	74 26                	je     80074e <vsnprintf+0x47>
  800728:	85 d2                	test   %edx,%edx
  80072a:	7e 29                	jle    800755 <vsnprintf+0x4e>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80072c:	ff 75 14             	pushl  0x14(%ebp)
  80072f:	ff 75 10             	pushl  0x10(%ebp)
  800732:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800735:	50                   	push   %eax
  800736:	68 42 03 80 00       	push   $0x800342
  80073b:	e8 39 fc ff ff       	call   800379 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800740:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800743:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800746:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800749:	83 c4 10             	add    $0x10,%esp
  80074c:	eb 0c                	jmp    80075a <vsnprintf+0x53>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80074e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800753:	eb 05                	jmp    80075a <vsnprintf+0x53>
  800755:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80075a:	c9                   	leave  
  80075b:	c3                   	ret    

0080075c <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80075c:	55                   	push   %ebp
  80075d:	89 e5                	mov    %esp,%ebp
  80075f:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800762:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800765:	50                   	push   %eax
  800766:	ff 75 10             	pushl  0x10(%ebp)
  800769:	ff 75 0c             	pushl  0xc(%ebp)
  80076c:	ff 75 08             	pushl  0x8(%ebp)
  80076f:	e8 93 ff ff ff       	call   800707 <vsnprintf>
	va_end(ap);

	return rc;
}
  800774:	c9                   	leave  
  800775:	c3                   	ret    
	...

00800778 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800778:	55                   	push   %ebp
  800779:	89 e5                	mov    %esp,%ebp
  80077b:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80077e:	80 3a 00             	cmpb   $0x0,(%edx)
  800781:	74 0e                	je     800791 <strlen+0x19>
  800783:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800788:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800789:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80078d:	75 f9                	jne    800788 <strlen+0x10>
  80078f:	eb 05                	jmp    800796 <strlen+0x1e>
  800791:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800796:	c9                   	leave  
  800797:	c3                   	ret    

00800798 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800798:	55                   	push   %ebp
  800799:	89 e5                	mov    %esp,%ebp
  80079b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80079e:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007a1:	85 d2                	test   %edx,%edx
  8007a3:	74 17                	je     8007bc <strnlen+0x24>
  8007a5:	80 39 00             	cmpb   $0x0,(%ecx)
  8007a8:	74 19                	je     8007c3 <strnlen+0x2b>
  8007aa:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  8007af:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007b0:	39 d0                	cmp    %edx,%eax
  8007b2:	74 14                	je     8007c8 <strnlen+0x30>
  8007b4:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8007b8:	75 f5                	jne    8007af <strnlen+0x17>
  8007ba:	eb 0c                	jmp    8007c8 <strnlen+0x30>
  8007bc:	b8 00 00 00 00       	mov    $0x0,%eax
  8007c1:	eb 05                	jmp    8007c8 <strnlen+0x30>
  8007c3:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  8007c8:	c9                   	leave  
  8007c9:	c3                   	ret    

008007ca <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007ca:	55                   	push   %ebp
  8007cb:	89 e5                	mov    %esp,%ebp
  8007cd:	53                   	push   %ebx
  8007ce:	8b 45 08             	mov    0x8(%ebp),%eax
  8007d1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007d4:	ba 00 00 00 00       	mov    $0x0,%edx
  8007d9:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  8007dc:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  8007df:	42                   	inc    %edx
  8007e0:	84 c9                	test   %cl,%cl
  8007e2:	75 f5                	jne    8007d9 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8007e4:	5b                   	pop    %ebx
  8007e5:	c9                   	leave  
  8007e6:	c3                   	ret    

008007e7 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007e7:	55                   	push   %ebp
  8007e8:	89 e5                	mov    %esp,%ebp
  8007ea:	53                   	push   %ebx
  8007eb:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007ee:	53                   	push   %ebx
  8007ef:	e8 84 ff ff ff       	call   800778 <strlen>
  8007f4:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8007f7:	ff 75 0c             	pushl  0xc(%ebp)
  8007fa:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  8007fd:	50                   	push   %eax
  8007fe:	e8 c7 ff ff ff       	call   8007ca <strcpy>
	return dst;
}
  800803:	89 d8                	mov    %ebx,%eax
  800805:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800808:	c9                   	leave  
  800809:	c3                   	ret    

0080080a <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80080a:	55                   	push   %ebp
  80080b:	89 e5                	mov    %esp,%ebp
  80080d:	56                   	push   %esi
  80080e:	53                   	push   %ebx
  80080f:	8b 45 08             	mov    0x8(%ebp),%eax
  800812:	8b 55 0c             	mov    0xc(%ebp),%edx
  800815:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800818:	85 f6                	test   %esi,%esi
  80081a:	74 15                	je     800831 <strncpy+0x27>
  80081c:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  800821:	8a 1a                	mov    (%edx),%bl
  800823:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800826:	80 3a 01             	cmpb   $0x1,(%edx)
  800829:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80082c:	41                   	inc    %ecx
  80082d:	39 ce                	cmp    %ecx,%esi
  80082f:	77 f0                	ja     800821 <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800831:	5b                   	pop    %ebx
  800832:	5e                   	pop    %esi
  800833:	c9                   	leave  
  800834:	c3                   	ret    

00800835 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800835:	55                   	push   %ebp
  800836:	89 e5                	mov    %esp,%ebp
  800838:	57                   	push   %edi
  800839:	56                   	push   %esi
  80083a:	53                   	push   %ebx
  80083b:	8b 7d 08             	mov    0x8(%ebp),%edi
  80083e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800841:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800844:	85 f6                	test   %esi,%esi
  800846:	74 32                	je     80087a <strlcpy+0x45>
		while (--size > 0 && *src != '\0')
  800848:	83 fe 01             	cmp    $0x1,%esi
  80084b:	74 22                	je     80086f <strlcpy+0x3a>
  80084d:	8a 0b                	mov    (%ebx),%cl
  80084f:	84 c9                	test   %cl,%cl
  800851:	74 20                	je     800873 <strlcpy+0x3e>
  800853:	89 f8                	mov    %edi,%eax
  800855:	ba 00 00 00 00       	mov    $0x0,%edx
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
  80085a:	83 ee 02             	sub    $0x2,%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80085d:	88 08                	mov    %cl,(%eax)
  80085f:	40                   	inc    %eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800860:	39 f2                	cmp    %esi,%edx
  800862:	74 11                	je     800875 <strlcpy+0x40>
  800864:	8a 4c 13 01          	mov    0x1(%ebx,%edx,1),%cl
  800868:	42                   	inc    %edx
  800869:	84 c9                	test   %cl,%cl
  80086b:	75 f0                	jne    80085d <strlcpy+0x28>
  80086d:	eb 06                	jmp    800875 <strlcpy+0x40>
  80086f:	89 f8                	mov    %edi,%eax
  800871:	eb 02                	jmp    800875 <strlcpy+0x40>
  800873:	89 f8                	mov    %edi,%eax
			*dst++ = *src++;
		*dst = '\0';
  800875:	c6 00 00             	movb   $0x0,(%eax)
  800878:	eb 02                	jmp    80087c <strlcpy+0x47>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80087a:	89 f8                	mov    %edi,%eax
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
		*dst = '\0';
	}
	return dst - dst_in;
  80087c:	29 f8                	sub    %edi,%eax
}
  80087e:	5b                   	pop    %ebx
  80087f:	5e                   	pop    %esi
  800880:	5f                   	pop    %edi
  800881:	c9                   	leave  
  800882:	c3                   	ret    

00800883 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800883:	55                   	push   %ebp
  800884:	89 e5                	mov    %esp,%ebp
  800886:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800889:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80088c:	8a 01                	mov    (%ecx),%al
  80088e:	84 c0                	test   %al,%al
  800890:	74 10                	je     8008a2 <strcmp+0x1f>
  800892:	3a 02                	cmp    (%edx),%al
  800894:	75 0c                	jne    8008a2 <strcmp+0x1f>
		p++, q++;
  800896:	41                   	inc    %ecx
  800897:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800898:	8a 01                	mov    (%ecx),%al
  80089a:	84 c0                	test   %al,%al
  80089c:	74 04                	je     8008a2 <strcmp+0x1f>
  80089e:	3a 02                	cmp    (%edx),%al
  8008a0:	74 f4                	je     800896 <strcmp+0x13>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008a2:	0f b6 c0             	movzbl %al,%eax
  8008a5:	0f b6 12             	movzbl (%edx),%edx
  8008a8:	29 d0                	sub    %edx,%eax
}
  8008aa:	c9                   	leave  
  8008ab:	c3                   	ret    

008008ac <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008ac:	55                   	push   %ebp
  8008ad:	89 e5                	mov    %esp,%ebp
  8008af:	53                   	push   %ebx
  8008b0:	8b 55 08             	mov    0x8(%ebp),%edx
  8008b3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008b6:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  8008b9:	85 c0                	test   %eax,%eax
  8008bb:	74 1b                	je     8008d8 <strncmp+0x2c>
  8008bd:	8a 1a                	mov    (%edx),%bl
  8008bf:	84 db                	test   %bl,%bl
  8008c1:	74 24                	je     8008e7 <strncmp+0x3b>
  8008c3:	3a 19                	cmp    (%ecx),%bl
  8008c5:	75 20                	jne    8008e7 <strncmp+0x3b>
  8008c7:	48                   	dec    %eax
  8008c8:	74 15                	je     8008df <strncmp+0x33>
		n--, p++, q++;
  8008ca:	42                   	inc    %edx
  8008cb:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8008cc:	8a 1a                	mov    (%edx),%bl
  8008ce:	84 db                	test   %bl,%bl
  8008d0:	74 15                	je     8008e7 <strncmp+0x3b>
  8008d2:	3a 19                	cmp    (%ecx),%bl
  8008d4:	74 f1                	je     8008c7 <strncmp+0x1b>
  8008d6:	eb 0f                	jmp    8008e7 <strncmp+0x3b>
		n--, p++, q++;
	if (n == 0)
		return 0;
  8008d8:	b8 00 00 00 00       	mov    $0x0,%eax
  8008dd:	eb 05                	jmp    8008e4 <strncmp+0x38>
  8008df:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8008e4:	5b                   	pop    %ebx
  8008e5:	c9                   	leave  
  8008e6:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008e7:	0f b6 02             	movzbl (%edx),%eax
  8008ea:	0f b6 11             	movzbl (%ecx),%edx
  8008ed:	29 d0                	sub    %edx,%eax
  8008ef:	eb f3                	jmp    8008e4 <strncmp+0x38>

008008f1 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008f1:	55                   	push   %ebp
  8008f2:	89 e5                	mov    %esp,%ebp
  8008f4:	8b 45 08             	mov    0x8(%ebp),%eax
  8008f7:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8008fa:	8a 10                	mov    (%eax),%dl
  8008fc:	84 d2                	test   %dl,%dl
  8008fe:	74 18                	je     800918 <strchr+0x27>
		if (*s == c)
  800900:	38 ca                	cmp    %cl,%dl
  800902:	75 06                	jne    80090a <strchr+0x19>
  800904:	eb 17                	jmp    80091d <strchr+0x2c>
  800906:	38 ca                	cmp    %cl,%dl
  800908:	74 13                	je     80091d <strchr+0x2c>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80090a:	40                   	inc    %eax
  80090b:	8a 10                	mov    (%eax),%dl
  80090d:	84 d2                	test   %dl,%dl
  80090f:	75 f5                	jne    800906 <strchr+0x15>
		if (*s == c)
			return (char *) s;
	return 0;
  800911:	b8 00 00 00 00       	mov    $0x0,%eax
  800916:	eb 05                	jmp    80091d <strchr+0x2c>
  800918:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80091d:	c9                   	leave  
  80091e:	c3                   	ret    

0080091f <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80091f:	55                   	push   %ebp
  800920:	89 e5                	mov    %esp,%ebp
  800922:	8b 45 08             	mov    0x8(%ebp),%eax
  800925:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800928:	8a 10                	mov    (%eax),%dl
  80092a:	84 d2                	test   %dl,%dl
  80092c:	74 11                	je     80093f <strfind+0x20>
		if (*s == c)
  80092e:	38 ca                	cmp    %cl,%dl
  800930:	75 06                	jne    800938 <strfind+0x19>
  800932:	eb 0b                	jmp    80093f <strfind+0x20>
  800934:	38 ca                	cmp    %cl,%dl
  800936:	74 07                	je     80093f <strfind+0x20>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800938:	40                   	inc    %eax
  800939:	8a 10                	mov    (%eax),%dl
  80093b:	84 d2                	test   %dl,%dl
  80093d:	75 f5                	jne    800934 <strfind+0x15>
		if (*s == c)
			break;
	return (char *) s;
}
  80093f:	c9                   	leave  
  800940:	c3                   	ret    

00800941 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800941:	55                   	push   %ebp
  800942:	89 e5                	mov    %esp,%ebp
  800944:	57                   	push   %edi
  800945:	56                   	push   %esi
  800946:	53                   	push   %ebx
  800947:	8b 7d 08             	mov    0x8(%ebp),%edi
  80094a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80094d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800950:	85 c9                	test   %ecx,%ecx
  800952:	74 30                	je     800984 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800954:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80095a:	75 25                	jne    800981 <memset+0x40>
  80095c:	f6 c1 03             	test   $0x3,%cl
  80095f:	75 20                	jne    800981 <memset+0x40>
		c &= 0xFF;
  800961:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800964:	89 d3                	mov    %edx,%ebx
  800966:	c1 e3 08             	shl    $0x8,%ebx
  800969:	89 d6                	mov    %edx,%esi
  80096b:	c1 e6 18             	shl    $0x18,%esi
  80096e:	89 d0                	mov    %edx,%eax
  800970:	c1 e0 10             	shl    $0x10,%eax
  800973:	09 f0                	or     %esi,%eax
  800975:	09 d0                	or     %edx,%eax
  800977:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800979:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  80097c:	fc                   	cld    
  80097d:	f3 ab                	rep stos %eax,%es:(%edi)
  80097f:	eb 03                	jmp    800984 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800981:	fc                   	cld    
  800982:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800984:	89 f8                	mov    %edi,%eax
  800986:	5b                   	pop    %ebx
  800987:	5e                   	pop    %esi
  800988:	5f                   	pop    %edi
  800989:	c9                   	leave  
  80098a:	c3                   	ret    

0080098b <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80098b:	55                   	push   %ebp
  80098c:	89 e5                	mov    %esp,%ebp
  80098e:	57                   	push   %edi
  80098f:	56                   	push   %esi
  800990:	8b 45 08             	mov    0x8(%ebp),%eax
  800993:	8b 75 0c             	mov    0xc(%ebp),%esi
  800996:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800999:	39 c6                	cmp    %eax,%esi
  80099b:	73 34                	jae    8009d1 <memmove+0x46>
  80099d:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8009a0:	39 d0                	cmp    %edx,%eax
  8009a2:	73 2d                	jae    8009d1 <memmove+0x46>
		s += n;
		d += n;
  8009a4:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009a7:	f6 c2 03             	test   $0x3,%dl
  8009aa:	75 1b                	jne    8009c7 <memmove+0x3c>
  8009ac:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8009b2:	75 13                	jne    8009c7 <memmove+0x3c>
  8009b4:	f6 c1 03             	test   $0x3,%cl
  8009b7:	75 0e                	jne    8009c7 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8009b9:	83 ef 04             	sub    $0x4,%edi
  8009bc:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009bf:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  8009c2:	fd                   	std    
  8009c3:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009c5:	eb 07                	jmp    8009ce <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8009c7:	4f                   	dec    %edi
  8009c8:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8009cb:	fd                   	std    
  8009cc:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009ce:	fc                   	cld    
  8009cf:	eb 20                	jmp    8009f1 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009d1:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009d7:	75 13                	jne    8009ec <memmove+0x61>
  8009d9:	a8 03                	test   $0x3,%al
  8009db:	75 0f                	jne    8009ec <memmove+0x61>
  8009dd:	f6 c1 03             	test   $0x3,%cl
  8009e0:	75 0a                	jne    8009ec <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8009e2:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  8009e5:	89 c7                	mov    %eax,%edi
  8009e7:	fc                   	cld    
  8009e8:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009ea:	eb 05                	jmp    8009f1 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8009ec:	89 c7                	mov    %eax,%edi
  8009ee:	fc                   	cld    
  8009ef:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009f1:	5e                   	pop    %esi
  8009f2:	5f                   	pop    %edi
  8009f3:	c9                   	leave  
  8009f4:	c3                   	ret    

008009f5 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009f5:	55                   	push   %ebp
  8009f6:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8009f8:	ff 75 10             	pushl  0x10(%ebp)
  8009fb:	ff 75 0c             	pushl  0xc(%ebp)
  8009fe:	ff 75 08             	pushl  0x8(%ebp)
  800a01:	e8 85 ff ff ff       	call   80098b <memmove>
}
  800a06:	c9                   	leave  
  800a07:	c3                   	ret    

00800a08 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a08:	55                   	push   %ebp
  800a09:	89 e5                	mov    %esp,%ebp
  800a0b:	57                   	push   %edi
  800a0c:	56                   	push   %esi
  800a0d:	53                   	push   %ebx
  800a0e:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800a11:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a14:	8b 7d 10             	mov    0x10(%ebp),%edi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a17:	85 ff                	test   %edi,%edi
  800a19:	74 32                	je     800a4d <memcmp+0x45>
		if (*s1 != *s2)
  800a1b:	8a 03                	mov    (%ebx),%al
  800a1d:	8a 0e                	mov    (%esi),%cl
  800a1f:	38 c8                	cmp    %cl,%al
  800a21:	74 19                	je     800a3c <memcmp+0x34>
  800a23:	eb 0d                	jmp    800a32 <memcmp+0x2a>
  800a25:	8a 44 13 01          	mov    0x1(%ebx,%edx,1),%al
  800a29:	8a 4c 16 01          	mov    0x1(%esi,%edx,1),%cl
  800a2d:	42                   	inc    %edx
  800a2e:	38 c8                	cmp    %cl,%al
  800a30:	74 10                	je     800a42 <memcmp+0x3a>
			return (int) *s1 - (int) *s2;
  800a32:	0f b6 c0             	movzbl %al,%eax
  800a35:	0f b6 c9             	movzbl %cl,%ecx
  800a38:	29 c8                	sub    %ecx,%eax
  800a3a:	eb 16                	jmp    800a52 <memcmp+0x4a>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a3c:	4f                   	dec    %edi
  800a3d:	ba 00 00 00 00       	mov    $0x0,%edx
  800a42:	39 fa                	cmp    %edi,%edx
  800a44:	75 df                	jne    800a25 <memcmp+0x1d>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a46:	b8 00 00 00 00       	mov    $0x0,%eax
  800a4b:	eb 05                	jmp    800a52 <memcmp+0x4a>
  800a4d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a52:	5b                   	pop    %ebx
  800a53:	5e                   	pop    %esi
  800a54:	5f                   	pop    %edi
  800a55:	c9                   	leave  
  800a56:	c3                   	ret    

00800a57 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a57:	55                   	push   %ebp
  800a58:	89 e5                	mov    %esp,%ebp
  800a5a:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800a5d:	89 c2                	mov    %eax,%edx
  800a5f:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a62:	39 d0                	cmp    %edx,%eax
  800a64:	73 12                	jae    800a78 <memfind+0x21>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a66:	8a 4d 0c             	mov    0xc(%ebp),%cl
  800a69:	38 08                	cmp    %cl,(%eax)
  800a6b:	75 06                	jne    800a73 <memfind+0x1c>
  800a6d:	eb 09                	jmp    800a78 <memfind+0x21>
  800a6f:	38 08                	cmp    %cl,(%eax)
  800a71:	74 05                	je     800a78 <memfind+0x21>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a73:	40                   	inc    %eax
  800a74:	39 c2                	cmp    %eax,%edx
  800a76:	77 f7                	ja     800a6f <memfind+0x18>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a78:	c9                   	leave  
  800a79:	c3                   	ret    

00800a7a <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a7a:	55                   	push   %ebp
  800a7b:	89 e5                	mov    %esp,%ebp
  800a7d:	57                   	push   %edi
  800a7e:	56                   	push   %esi
  800a7f:	53                   	push   %ebx
  800a80:	8b 55 08             	mov    0x8(%ebp),%edx
  800a83:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a86:	eb 01                	jmp    800a89 <strtol+0xf>
		s++;
  800a88:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a89:	8a 02                	mov    (%edx),%al
  800a8b:	3c 20                	cmp    $0x20,%al
  800a8d:	74 f9                	je     800a88 <strtol+0xe>
  800a8f:	3c 09                	cmp    $0x9,%al
  800a91:	74 f5                	je     800a88 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a93:	3c 2b                	cmp    $0x2b,%al
  800a95:	75 08                	jne    800a9f <strtol+0x25>
		s++;
  800a97:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a98:	bf 00 00 00 00       	mov    $0x0,%edi
  800a9d:	eb 13                	jmp    800ab2 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a9f:	3c 2d                	cmp    $0x2d,%al
  800aa1:	75 0a                	jne    800aad <strtol+0x33>
		s++, neg = 1;
  800aa3:	8d 52 01             	lea    0x1(%edx),%edx
  800aa6:	bf 01 00 00 00       	mov    $0x1,%edi
  800aab:	eb 05                	jmp    800ab2 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800aad:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800ab2:	85 db                	test   %ebx,%ebx
  800ab4:	74 05                	je     800abb <strtol+0x41>
  800ab6:	83 fb 10             	cmp    $0x10,%ebx
  800ab9:	75 28                	jne    800ae3 <strtol+0x69>
  800abb:	8a 02                	mov    (%edx),%al
  800abd:	3c 30                	cmp    $0x30,%al
  800abf:	75 10                	jne    800ad1 <strtol+0x57>
  800ac1:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800ac5:	75 0a                	jne    800ad1 <strtol+0x57>
		s += 2, base = 16;
  800ac7:	83 c2 02             	add    $0x2,%edx
  800aca:	bb 10 00 00 00       	mov    $0x10,%ebx
  800acf:	eb 12                	jmp    800ae3 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800ad1:	85 db                	test   %ebx,%ebx
  800ad3:	75 0e                	jne    800ae3 <strtol+0x69>
  800ad5:	3c 30                	cmp    $0x30,%al
  800ad7:	75 05                	jne    800ade <strtol+0x64>
		s++, base = 8;
  800ad9:	42                   	inc    %edx
  800ada:	b3 08                	mov    $0x8,%bl
  800adc:	eb 05                	jmp    800ae3 <strtol+0x69>
	else if (base == 0)
		base = 10;
  800ade:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800ae3:	b8 00 00 00 00       	mov    $0x0,%eax
  800ae8:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800aea:	8a 0a                	mov    (%edx),%cl
  800aec:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800aef:	80 fb 09             	cmp    $0x9,%bl
  800af2:	77 08                	ja     800afc <strtol+0x82>
			dig = *s - '0';
  800af4:	0f be c9             	movsbl %cl,%ecx
  800af7:	83 e9 30             	sub    $0x30,%ecx
  800afa:	eb 1e                	jmp    800b1a <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800afc:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800aff:	80 fb 19             	cmp    $0x19,%bl
  800b02:	77 08                	ja     800b0c <strtol+0x92>
			dig = *s - 'a' + 10;
  800b04:	0f be c9             	movsbl %cl,%ecx
  800b07:	83 e9 57             	sub    $0x57,%ecx
  800b0a:	eb 0e                	jmp    800b1a <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800b0c:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800b0f:	80 fb 19             	cmp    $0x19,%bl
  800b12:	77 13                	ja     800b27 <strtol+0xad>
			dig = *s - 'A' + 10;
  800b14:	0f be c9             	movsbl %cl,%ecx
  800b17:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800b1a:	39 f1                	cmp    %esi,%ecx
  800b1c:	7d 0d                	jge    800b2b <strtol+0xb1>
			break;
		s++, val = (val * base) + dig;
  800b1e:	42                   	inc    %edx
  800b1f:	0f af c6             	imul   %esi,%eax
  800b22:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  800b25:	eb c3                	jmp    800aea <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800b27:	89 c1                	mov    %eax,%ecx
  800b29:	eb 02                	jmp    800b2d <strtol+0xb3>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800b2b:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800b2d:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b31:	74 05                	je     800b38 <strtol+0xbe>
		*endptr = (char *) s;
  800b33:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800b36:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800b38:	85 ff                	test   %edi,%edi
  800b3a:	74 04                	je     800b40 <strtol+0xc6>
  800b3c:	89 c8                	mov    %ecx,%eax
  800b3e:	f7 d8                	neg    %eax
}
  800b40:	5b                   	pop    %ebx
  800b41:	5e                   	pop    %esi
  800b42:	5f                   	pop    %edi
  800b43:	c9                   	leave  
  800b44:	c3                   	ret    
  800b45:	00 00                	add    %al,(%eax)
	...

00800b48 <syscall>:
	return ret;
}

static int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800b48:	55                   	push   %ebp
  800b49:	89 e5                	mov    %esp,%ebp
  800b4b:	57                   	push   %edi
  800b4c:	56                   	push   %esi
  800b4d:	53                   	push   %ebx
  800b4e:	83 ec 1c             	sub    $0x1c,%esp
  800b51:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800b54:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800b57:	89 ca                	mov    %ecx,%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b59:	8b 75 14             	mov    0x14(%ebp),%esi
  800b5c:	8b 7d 10             	mov    0x10(%ebp),%edi
  800b5f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800b62:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b65:	cd 30                	int    $0x30
  800b67:	89 c2                	mov    %eax,%edx
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b69:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800b6d:	74 1c                	je     800b8b <syscall+0x43>
  800b6f:	85 c0                	test   %eax,%eax
  800b71:	7e 18                	jle    800b8b <syscall+0x43>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b73:	83 ec 0c             	sub    $0xc,%esp
  800b76:	50                   	push   %eax
  800b77:	ff 75 e4             	pushl  -0x1c(%ebp)
  800b7a:	68 9f 23 80 00       	push   $0x80239f
  800b7f:	6a 42                	push   $0x42
  800b81:	68 bc 23 80 00       	push   $0x8023bc
  800b86:	e8 79 10 00 00       	call   801c04 <_panic>

	return ret;
}
  800b8b:	89 d0                	mov    %edx,%eax
  800b8d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b90:	5b                   	pop    %ebx
  800b91:	5e                   	pop    %esi
  800b92:	5f                   	pop    %edi
  800b93:	c9                   	leave  
  800b94:	c3                   	ret    

00800b95 <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{	
  800b95:	55                   	push   %ebp
  800b96:	89 e5                	mov    %esp,%ebp
  800b98:	83 ec 08             	sub    $0x8,%esp
	// my_sysenter(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
	// return;
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  800b9b:	6a 00                	push   $0x0
  800b9d:	6a 00                	push   $0x0
  800b9f:	6a 00                	push   $0x0
  800ba1:	ff 75 0c             	pushl  0xc(%ebp)
  800ba4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ba7:	ba 00 00 00 00       	mov    $0x0,%edx
  800bac:	b8 00 00 00 00       	mov    $0x0,%eax
  800bb1:	e8 92 ff ff ff       	call   800b48 <syscall>
  800bb6:	83 c4 10             	add    $0x10,%esp
	return;
}
  800bb9:	c9                   	leave  
  800bba:	c3                   	ret    

00800bbb <sys_cgetc>:

int
sys_cgetc(void)
{
  800bbb:	55                   	push   %ebp
  800bbc:	89 e5                	mov    %esp,%ebp
  800bbe:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_cgetc, 0, 0, 0, 0, 0, 0);
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  800bc1:	6a 00                	push   $0x0
  800bc3:	6a 00                	push   $0x0
  800bc5:	6a 00                	push   $0x0
  800bc7:	6a 00                	push   $0x0
  800bc9:	b9 00 00 00 00       	mov    $0x0,%ecx
  800bce:	ba 00 00 00 00       	mov    $0x0,%edx
  800bd3:	b8 01 00 00 00       	mov    $0x1,%eax
  800bd8:	e8 6b ff ff ff       	call   800b48 <syscall>
}
  800bdd:	c9                   	leave  
  800bde:	c3                   	ret    

00800bdf <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800bdf:	55                   	push   %ebp
  800be0:	89 e5                	mov    %esp,%ebp
  800be2:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  800be5:	6a 00                	push   $0x0
  800be7:	6a 00                	push   $0x0
  800be9:	6a 00                	push   $0x0
  800beb:	6a 00                	push   $0x0
  800bed:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800bf0:	ba 01 00 00 00       	mov    $0x1,%edx
  800bf5:	b8 03 00 00 00       	mov    $0x3,%eax
  800bfa:	e8 49 ff ff ff       	call   800b48 <syscall>
}
  800bff:	c9                   	leave  
  800c00:	c3                   	ret    

00800c01 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c01:	55                   	push   %ebp
  800c02:	89 e5                	mov    %esp,%ebp
  800c04:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_getenvid, 0, 0, 0, 0, 0, 0);
	return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  800c07:	6a 00                	push   $0x0
  800c09:	6a 00                	push   $0x0
  800c0b:	6a 00                	push   $0x0
  800c0d:	6a 00                	push   $0x0
  800c0f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c14:	ba 00 00 00 00       	mov    $0x0,%edx
  800c19:	b8 02 00 00 00       	mov    $0x2,%eax
  800c1e:	e8 25 ff ff ff       	call   800b48 <syscall>
}
  800c23:	c9                   	leave  
  800c24:	c3                   	ret    

00800c25 <sys_yield>:

void
sys_yield(void)
{
  800c25:	55                   	push   %ebp
  800c26:	89 e5                	mov    %esp,%ebp
  800c28:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  800c2b:	6a 00                	push   $0x0
  800c2d:	6a 00                	push   $0x0
  800c2f:	6a 00                	push   $0x0
  800c31:	6a 00                	push   $0x0
  800c33:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c38:	ba 00 00 00 00       	mov    $0x0,%edx
  800c3d:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c42:	e8 01 ff ff ff       	call   800b48 <syscall>
  800c47:	83 c4 10             	add    $0x10,%esp
}
  800c4a:	c9                   	leave  
  800c4b:	c3                   	ret    

00800c4c <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c4c:	55                   	push   %ebp
  800c4d:	89 e5                	mov    %esp,%ebp
  800c4f:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  800c52:	6a 00                	push   $0x0
  800c54:	6a 00                	push   $0x0
  800c56:	ff 75 10             	pushl  0x10(%ebp)
  800c59:	ff 75 0c             	pushl  0xc(%ebp)
  800c5c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c5f:	ba 01 00 00 00       	mov    $0x1,%edx
  800c64:	b8 04 00 00 00       	mov    $0x4,%eax
  800c69:	e8 da fe ff ff       	call   800b48 <syscall>
}
  800c6e:	c9                   	leave  
  800c6f:	c3                   	ret    

00800c70 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c70:	55                   	push   %ebp
  800c71:	89 e5                	mov    %esp,%ebp
  800c73:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
  800c76:	ff 75 18             	pushl  0x18(%ebp)
  800c79:	ff 75 14             	pushl  0x14(%ebp)
  800c7c:	ff 75 10             	pushl  0x10(%ebp)
  800c7f:	ff 75 0c             	pushl  0xc(%ebp)
  800c82:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c85:	ba 01 00 00 00       	mov    $0x1,%edx
  800c8a:	b8 05 00 00 00       	mov    $0x5,%eax
  800c8f:	e8 b4 fe ff ff       	call   800b48 <syscall>
}
  800c94:	c9                   	leave  
  800c95:	c3                   	ret    

00800c96 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c96:	55                   	push   %ebp
  800c97:	89 e5                	mov    %esp,%ebp
  800c99:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  800c9c:	6a 00                	push   $0x0
  800c9e:	6a 00                	push   $0x0
  800ca0:	6a 00                	push   $0x0
  800ca2:	ff 75 0c             	pushl  0xc(%ebp)
  800ca5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ca8:	ba 01 00 00 00       	mov    $0x1,%edx
  800cad:	b8 06 00 00 00       	mov    $0x6,%eax
  800cb2:	e8 91 fe ff ff       	call   800b48 <syscall>
}
  800cb7:	c9                   	leave  
  800cb8:	c3                   	ret    

00800cb9 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800cb9:	55                   	push   %ebp
  800cba:	89 e5                	mov    %esp,%ebp
  800cbc:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  800cbf:	6a 00                	push   $0x0
  800cc1:	6a 00                	push   $0x0
  800cc3:	6a 00                	push   $0x0
  800cc5:	ff 75 0c             	pushl  0xc(%ebp)
  800cc8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ccb:	ba 01 00 00 00       	mov    $0x1,%edx
  800cd0:	b8 08 00 00 00       	mov    $0x8,%eax
  800cd5:	e8 6e fe ff ff       	call   800b48 <syscall>
}
  800cda:	c9                   	leave  
  800cdb:	c3                   	ret    

00800cdc <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800cdc:	55                   	push   %ebp
  800cdd:	89 e5                	mov    %esp,%ebp
  800cdf:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
  800ce2:	6a 00                	push   $0x0
  800ce4:	6a 00                	push   $0x0
  800ce6:	6a 00                	push   $0x0
  800ce8:	ff 75 0c             	pushl  0xc(%ebp)
  800ceb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800cee:	ba 01 00 00 00       	mov    $0x1,%edx
  800cf3:	b8 09 00 00 00       	mov    $0x9,%eax
  800cf8:	e8 4b fe ff ff       	call   800b48 <syscall>
}
  800cfd:	c9                   	leave  
  800cfe:	c3                   	ret    

00800cff <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800cff:	55                   	push   %ebp
  800d00:	89 e5                	mov    %esp,%ebp
  800d02:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  800d05:	6a 00                	push   $0x0
  800d07:	6a 00                	push   $0x0
  800d09:	6a 00                	push   $0x0
  800d0b:	ff 75 0c             	pushl  0xc(%ebp)
  800d0e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d11:	ba 01 00 00 00       	mov    $0x1,%edx
  800d16:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d1b:	e8 28 fe ff ff       	call   800b48 <syscall>
}
  800d20:	c9                   	leave  
  800d21:	c3                   	ret    

00800d22 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d22:	55                   	push   %ebp
  800d23:	89 e5                	mov    %esp,%ebp
  800d25:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  800d28:	6a 00                	push   $0x0
  800d2a:	ff 75 14             	pushl  0x14(%ebp)
  800d2d:	ff 75 10             	pushl  0x10(%ebp)
  800d30:	ff 75 0c             	pushl  0xc(%ebp)
  800d33:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d36:	ba 00 00 00 00       	mov    $0x0,%edx
  800d3b:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d40:	e8 03 fe ff ff       	call   800b48 <syscall>
}
  800d45:	c9                   	leave  
  800d46:	c3                   	ret    

00800d47 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d47:	55                   	push   %ebp
  800d48:	89 e5                	mov    %esp,%ebp
  800d4a:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  800d4d:	6a 00                	push   $0x0
  800d4f:	6a 00                	push   $0x0
  800d51:	6a 00                	push   $0x0
  800d53:	6a 00                	push   $0x0
  800d55:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d58:	ba 01 00 00 00       	mov    $0x1,%edx
  800d5d:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d62:	e8 e1 fd ff ff       	call   800b48 <syscall>
}
  800d67:	c9                   	leave  
  800d68:	c3                   	ret    

00800d69 <sys_set_priority>:

int
sys_set_priority(envid_t envid, uint32_t new_priority)
{
  800d69:	55                   	push   %ebp
  800d6a:	89 e5                	mov    %esp,%ebp
  800d6c:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_set_priority, 0, envid, new_priority, 0, 0, 0);
  800d6f:	6a 00                	push   $0x0
  800d71:	6a 00                	push   $0x0
  800d73:	6a 00                	push   $0x0
  800d75:	ff 75 0c             	pushl  0xc(%ebp)
  800d78:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d7b:	ba 00 00 00 00       	mov    $0x0,%edx
  800d80:	b8 0e 00 00 00       	mov    $0xe,%eax
  800d85:	e8 be fd ff ff       	call   800b48 <syscall>
}
  800d8a:	c9                   	leave  
  800d8b:	c3                   	ret    

00800d8c <sys_exec>:

int
sys_exec(uint32_t eip, uint32_t esp, void * ph, uint32_t elf_phnum)
{
  800d8c:	55                   	push   %ebp
  800d8d:	89 e5                	mov    %esp,%ebp
  800d8f:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_exec, 0, eip, esp, (uint32_t)ph, elf_phnum, 0);
  800d92:	6a 00                	push   $0x0
  800d94:	ff 75 14             	pushl  0x14(%ebp)
  800d97:	ff 75 10             	pushl  0x10(%ebp)
  800d9a:	ff 75 0c             	pushl  0xc(%ebp)
  800d9d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800da0:	ba 00 00 00 00       	mov    $0x0,%edx
  800da5:	b8 0f 00 00 00       	mov    $0xf,%eax
  800daa:	e8 99 fd ff ff       	call   800b48 <syscall>
} 
  800daf:	c9                   	leave  
  800db0:	c3                   	ret    

00800db1 <sys_join>:

// thread:
int
sys_join(envid_t envid)
{
  800db1:	55                   	push   %ebp
  800db2:	89 e5                	mov    %esp,%ebp
  800db4:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_join, 0, envid, 0, 0, 0, 0);
  800db7:	6a 00                	push   $0x0
  800db9:	6a 00                	push   $0x0
  800dbb:	6a 00                	push   $0x0
  800dbd:	6a 00                	push   $0x0
  800dbf:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800dc2:	ba 00 00 00 00       	mov    $0x0,%edx
  800dc7:	b8 11 00 00 00       	mov    $0x11,%eax
  800dcc:	e8 77 fd ff ff       	call   800b48 <syscall>
}
  800dd1:	c9                   	leave  
  800dd2:	c3                   	ret    

00800dd3 <sys_getpid>:

envid_t
sys_getpid(void)
{
  800dd3:	55                   	push   %ebp
  800dd4:	89 e5                	mov    %esp,%ebp
  800dd6:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_getpid, 0, 0, 0, 0, 0, 0);
  800dd9:	6a 00                	push   $0x0
  800ddb:	6a 00                	push   $0x0
  800ddd:	6a 00                	push   $0x0
  800ddf:	6a 00                	push   $0x0
  800de1:	b9 00 00 00 00       	mov    $0x0,%ecx
  800de6:	ba 00 00 00 00       	mov    $0x0,%edx
  800deb:	b8 10 00 00 00       	mov    $0x10,%eax
  800df0:	e8 53 fd ff ff       	call   800b48 <syscall>
  800df5:	c9                   	leave  
  800df6:	c3                   	ret    
	...

00800df8 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800df8:	55                   	push   %ebp
  800df9:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800dfb:	8b 45 08             	mov    0x8(%ebp),%eax
  800dfe:	05 00 00 00 30       	add    $0x30000000,%eax
  800e03:	c1 e8 0c             	shr    $0xc,%eax
}
  800e06:	c9                   	leave  
  800e07:	c3                   	ret    

00800e08 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800e08:	55                   	push   %ebp
  800e09:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800e0b:	ff 75 08             	pushl  0x8(%ebp)
  800e0e:	e8 e5 ff ff ff       	call   800df8 <fd2num>
  800e13:	83 c4 04             	add    $0x4,%esp
  800e16:	05 20 00 0d 00       	add    $0xd0020,%eax
  800e1b:	c1 e0 0c             	shl    $0xc,%eax
}
  800e1e:	c9                   	leave  
  800e1f:	c3                   	ret    

00800e20 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800e20:	55                   	push   %ebp
  800e21:	89 e5                	mov    %esp,%ebp
  800e23:	53                   	push   %ebx
  800e24:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800e27:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  800e2c:	a8 01                	test   $0x1,%al
  800e2e:	74 34                	je     800e64 <fd_alloc+0x44>
  800e30:	a1 00 00 74 ef       	mov    0xef740000,%eax
  800e35:	a8 01                	test   $0x1,%al
  800e37:	74 32                	je     800e6b <fd_alloc+0x4b>
  800e39:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
  800e3e:	89 c1                	mov    %eax,%ecx
  800e40:	89 c2                	mov    %eax,%edx
  800e42:	c1 ea 16             	shr    $0x16,%edx
  800e45:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800e4c:	f6 c2 01             	test   $0x1,%dl
  800e4f:	74 1f                	je     800e70 <fd_alloc+0x50>
  800e51:	89 c2                	mov    %eax,%edx
  800e53:	c1 ea 0c             	shr    $0xc,%edx
  800e56:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e5d:	f6 c2 01             	test   $0x1,%dl
  800e60:	75 17                	jne    800e79 <fd_alloc+0x59>
  800e62:	eb 0c                	jmp    800e70 <fd_alloc+0x50>
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  800e64:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
  800e69:	eb 05                	jmp    800e70 <fd_alloc+0x50>
  800e6b:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
  800e70:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  800e72:	b8 00 00 00 00       	mov    $0x0,%eax
  800e77:	eb 17                	jmp    800e90 <fd_alloc+0x70>
  800e79:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800e7e:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800e83:	75 b9                	jne    800e3e <fd_alloc+0x1e>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800e85:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  800e8b:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800e90:	5b                   	pop    %ebx
  800e91:	c9                   	leave  
  800e92:	c3                   	ret    

00800e93 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800e93:	55                   	push   %ebp
  800e94:	89 e5                	mov    %esp,%ebp
  800e96:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800e99:	83 f8 1f             	cmp    $0x1f,%eax
  800e9c:	77 36                	ja     800ed4 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800e9e:	05 00 00 0d 00       	add    $0xd0000,%eax
  800ea3:	c1 e0 0c             	shl    $0xc,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800ea6:	89 c2                	mov    %eax,%edx
  800ea8:	c1 ea 16             	shr    $0x16,%edx
  800eab:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800eb2:	f6 c2 01             	test   $0x1,%dl
  800eb5:	74 24                	je     800edb <fd_lookup+0x48>
  800eb7:	89 c2                	mov    %eax,%edx
  800eb9:	c1 ea 0c             	shr    $0xc,%edx
  800ebc:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800ec3:	f6 c2 01             	test   $0x1,%dl
  800ec6:	74 1a                	je     800ee2 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800ec8:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ecb:	89 02                	mov    %eax,(%edx)
	return 0;
  800ecd:	b8 00 00 00 00       	mov    $0x0,%eax
  800ed2:	eb 13                	jmp    800ee7 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800ed4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800ed9:	eb 0c                	jmp    800ee7 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800edb:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800ee0:	eb 05                	jmp    800ee7 <fd_lookup+0x54>
  800ee2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800ee7:	c9                   	leave  
  800ee8:	c3                   	ret    

00800ee9 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800ee9:	55                   	push   %ebp
  800eea:	89 e5                	mov    %esp,%ebp
  800eec:	53                   	push   %ebx
  800eed:	83 ec 04             	sub    $0x4,%esp
  800ef0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ef3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  800ef6:	39 0d 04 30 80 00    	cmp    %ecx,0x803004
  800efc:	74 0d                	je     800f0b <dev_lookup+0x22>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800efe:	b8 00 00 00 00       	mov    $0x0,%eax
  800f03:	eb 14                	jmp    800f19 <dev_lookup+0x30>
		if (devtab[i]->dev_id == dev_id) {
  800f05:	39 0a                	cmp    %ecx,(%edx)
  800f07:	75 10                	jne    800f19 <dev_lookup+0x30>
  800f09:	eb 05                	jmp    800f10 <dev_lookup+0x27>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800f0b:	ba 04 30 80 00       	mov    $0x803004,%edx
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
  800f10:	89 13                	mov    %edx,(%ebx)
			return 0;
  800f12:	b8 00 00 00 00       	mov    $0x0,%eax
  800f17:	eb 31                	jmp    800f4a <dev_lookup+0x61>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800f19:	40                   	inc    %eax
  800f1a:	8b 14 85 48 24 80 00 	mov    0x802448(,%eax,4),%edx
  800f21:	85 d2                	test   %edx,%edx
  800f23:	75 e0                	jne    800f05 <dev_lookup+0x1c>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800f25:	a1 10 40 80 00       	mov    0x804010,%eax
  800f2a:	8b 40 48             	mov    0x48(%eax),%eax
  800f2d:	83 ec 04             	sub    $0x4,%esp
  800f30:	51                   	push   %ecx
  800f31:	50                   	push   %eax
  800f32:	68 cc 23 80 00       	push   $0x8023cc
  800f37:	e8 d8 f2 ff ff       	call   800214 <cprintf>
	*dev = 0;
  800f3c:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  800f42:	83 c4 10             	add    $0x10,%esp
  800f45:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800f4a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f4d:	c9                   	leave  
  800f4e:	c3                   	ret    

00800f4f <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800f4f:	55                   	push   %ebp
  800f50:	89 e5                	mov    %esp,%ebp
  800f52:	56                   	push   %esi
  800f53:	53                   	push   %ebx
  800f54:	83 ec 20             	sub    $0x20,%esp
  800f57:	8b 75 08             	mov    0x8(%ebp),%esi
  800f5a:	8a 45 0c             	mov    0xc(%ebp),%al
  800f5d:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800f60:	56                   	push   %esi
  800f61:	e8 92 fe ff ff       	call   800df8 <fd2num>
  800f66:	8d 55 f4             	lea    -0xc(%ebp),%edx
  800f69:	89 14 24             	mov    %edx,(%esp)
  800f6c:	50                   	push   %eax
  800f6d:	e8 21 ff ff ff       	call   800e93 <fd_lookup>
  800f72:	89 c3                	mov    %eax,%ebx
  800f74:	83 c4 08             	add    $0x8,%esp
  800f77:	85 c0                	test   %eax,%eax
  800f79:	78 05                	js     800f80 <fd_close+0x31>
	    || fd != fd2)
  800f7b:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800f7e:	74 0d                	je     800f8d <fd_close+0x3e>
		return (must_exist ? r : 0);
  800f80:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  800f84:	75 48                	jne    800fce <fd_close+0x7f>
  800f86:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f8b:	eb 41                	jmp    800fce <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800f8d:	83 ec 08             	sub    $0x8,%esp
  800f90:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800f93:	50                   	push   %eax
  800f94:	ff 36                	pushl  (%esi)
  800f96:	e8 4e ff ff ff       	call   800ee9 <dev_lookup>
  800f9b:	89 c3                	mov    %eax,%ebx
  800f9d:	83 c4 10             	add    $0x10,%esp
  800fa0:	85 c0                	test   %eax,%eax
  800fa2:	78 1c                	js     800fc0 <fd_close+0x71>
		if (dev->dev_close)
  800fa4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800fa7:	8b 40 10             	mov    0x10(%eax),%eax
  800faa:	85 c0                	test   %eax,%eax
  800fac:	74 0d                	je     800fbb <fd_close+0x6c>
			r = (*dev->dev_close)(fd);
  800fae:	83 ec 0c             	sub    $0xc,%esp
  800fb1:	56                   	push   %esi
  800fb2:	ff d0                	call   *%eax
  800fb4:	89 c3                	mov    %eax,%ebx
  800fb6:	83 c4 10             	add    $0x10,%esp
  800fb9:	eb 05                	jmp    800fc0 <fd_close+0x71>
		else
			r = 0;
  800fbb:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800fc0:	83 ec 08             	sub    $0x8,%esp
  800fc3:	56                   	push   %esi
  800fc4:	6a 00                	push   $0x0
  800fc6:	e8 cb fc ff ff       	call   800c96 <sys_page_unmap>
	return r;
  800fcb:	83 c4 10             	add    $0x10,%esp
}
  800fce:	89 d8                	mov    %ebx,%eax
  800fd0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800fd3:	5b                   	pop    %ebx
  800fd4:	5e                   	pop    %esi
  800fd5:	c9                   	leave  
  800fd6:	c3                   	ret    

00800fd7 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800fd7:	55                   	push   %ebp
  800fd8:	89 e5                	mov    %esp,%ebp
  800fda:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800fdd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fe0:	50                   	push   %eax
  800fe1:	ff 75 08             	pushl  0x8(%ebp)
  800fe4:	e8 aa fe ff ff       	call   800e93 <fd_lookup>
  800fe9:	83 c4 08             	add    $0x8,%esp
  800fec:	85 c0                	test   %eax,%eax
  800fee:	78 10                	js     801000 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800ff0:	83 ec 08             	sub    $0x8,%esp
  800ff3:	6a 01                	push   $0x1
  800ff5:	ff 75 f4             	pushl  -0xc(%ebp)
  800ff8:	e8 52 ff ff ff       	call   800f4f <fd_close>
  800ffd:	83 c4 10             	add    $0x10,%esp
}
  801000:	c9                   	leave  
  801001:	c3                   	ret    

00801002 <close_all>:

void
close_all(void)
{
  801002:	55                   	push   %ebp
  801003:	89 e5                	mov    %esp,%ebp
  801005:	53                   	push   %ebx
  801006:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801009:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80100e:	83 ec 0c             	sub    $0xc,%esp
  801011:	53                   	push   %ebx
  801012:	e8 c0 ff ff ff       	call   800fd7 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801017:	43                   	inc    %ebx
  801018:	83 c4 10             	add    $0x10,%esp
  80101b:	83 fb 20             	cmp    $0x20,%ebx
  80101e:	75 ee                	jne    80100e <close_all+0xc>
		close(i);
}
  801020:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801023:	c9                   	leave  
  801024:	c3                   	ret    

00801025 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801025:	55                   	push   %ebp
  801026:	89 e5                	mov    %esp,%ebp
  801028:	57                   	push   %edi
  801029:	56                   	push   %esi
  80102a:	53                   	push   %ebx
  80102b:	83 ec 2c             	sub    $0x2c,%esp
  80102e:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801031:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801034:	50                   	push   %eax
  801035:	ff 75 08             	pushl  0x8(%ebp)
  801038:	e8 56 fe ff ff       	call   800e93 <fd_lookup>
  80103d:	89 c3                	mov    %eax,%ebx
  80103f:	83 c4 08             	add    $0x8,%esp
  801042:	85 c0                	test   %eax,%eax
  801044:	0f 88 c0 00 00 00    	js     80110a <dup+0xe5>
		return r;
	close(newfdnum);
  80104a:	83 ec 0c             	sub    $0xc,%esp
  80104d:	57                   	push   %edi
  80104e:	e8 84 ff ff ff       	call   800fd7 <close>

	newfd = INDEX2FD(newfdnum);
  801053:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  801059:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  80105c:	83 c4 04             	add    $0x4,%esp
  80105f:	ff 75 e4             	pushl  -0x1c(%ebp)
  801062:	e8 a1 fd ff ff       	call   800e08 <fd2data>
  801067:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801069:	89 34 24             	mov    %esi,(%esp)
  80106c:	e8 97 fd ff ff       	call   800e08 <fd2data>
  801071:	83 c4 10             	add    $0x10,%esp
  801074:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801077:	89 d8                	mov    %ebx,%eax
  801079:	c1 e8 16             	shr    $0x16,%eax
  80107c:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801083:	a8 01                	test   $0x1,%al
  801085:	74 37                	je     8010be <dup+0x99>
  801087:	89 d8                	mov    %ebx,%eax
  801089:	c1 e8 0c             	shr    $0xc,%eax
  80108c:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801093:	f6 c2 01             	test   $0x1,%dl
  801096:	74 26                	je     8010be <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801098:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80109f:	83 ec 0c             	sub    $0xc,%esp
  8010a2:	25 07 0e 00 00       	and    $0xe07,%eax
  8010a7:	50                   	push   %eax
  8010a8:	ff 75 d4             	pushl  -0x2c(%ebp)
  8010ab:	6a 00                	push   $0x0
  8010ad:	53                   	push   %ebx
  8010ae:	6a 00                	push   $0x0
  8010b0:	e8 bb fb ff ff       	call   800c70 <sys_page_map>
  8010b5:	89 c3                	mov    %eax,%ebx
  8010b7:	83 c4 20             	add    $0x20,%esp
  8010ba:	85 c0                	test   %eax,%eax
  8010bc:	78 2d                	js     8010eb <dup+0xc6>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8010be:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8010c1:	89 c2                	mov    %eax,%edx
  8010c3:	c1 ea 0c             	shr    $0xc,%edx
  8010c6:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8010cd:	83 ec 0c             	sub    $0xc,%esp
  8010d0:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  8010d6:	52                   	push   %edx
  8010d7:	56                   	push   %esi
  8010d8:	6a 00                	push   $0x0
  8010da:	50                   	push   %eax
  8010db:	6a 00                	push   $0x0
  8010dd:	e8 8e fb ff ff       	call   800c70 <sys_page_map>
  8010e2:	89 c3                	mov    %eax,%ebx
  8010e4:	83 c4 20             	add    $0x20,%esp
  8010e7:	85 c0                	test   %eax,%eax
  8010e9:	79 1d                	jns    801108 <dup+0xe3>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8010eb:	83 ec 08             	sub    $0x8,%esp
  8010ee:	56                   	push   %esi
  8010ef:	6a 00                	push   $0x0
  8010f1:	e8 a0 fb ff ff       	call   800c96 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8010f6:	83 c4 08             	add    $0x8,%esp
  8010f9:	ff 75 d4             	pushl  -0x2c(%ebp)
  8010fc:	6a 00                	push   $0x0
  8010fe:	e8 93 fb ff ff       	call   800c96 <sys_page_unmap>
	return r;
  801103:	83 c4 10             	add    $0x10,%esp
  801106:	eb 02                	jmp    80110a <dup+0xe5>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  801108:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  80110a:	89 d8                	mov    %ebx,%eax
  80110c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80110f:	5b                   	pop    %ebx
  801110:	5e                   	pop    %esi
  801111:	5f                   	pop    %edi
  801112:	c9                   	leave  
  801113:	c3                   	ret    

00801114 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801114:	55                   	push   %ebp
  801115:	89 e5                	mov    %esp,%ebp
  801117:	53                   	push   %ebx
  801118:	83 ec 14             	sub    $0x14,%esp
  80111b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80111e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801121:	50                   	push   %eax
  801122:	53                   	push   %ebx
  801123:	e8 6b fd ff ff       	call   800e93 <fd_lookup>
  801128:	83 c4 08             	add    $0x8,%esp
  80112b:	85 c0                	test   %eax,%eax
  80112d:	78 67                	js     801196 <read+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80112f:	83 ec 08             	sub    $0x8,%esp
  801132:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801135:	50                   	push   %eax
  801136:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801139:	ff 30                	pushl  (%eax)
  80113b:	e8 a9 fd ff ff       	call   800ee9 <dev_lookup>
  801140:	83 c4 10             	add    $0x10,%esp
  801143:	85 c0                	test   %eax,%eax
  801145:	78 4f                	js     801196 <read+0x82>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801147:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80114a:	8b 50 08             	mov    0x8(%eax),%edx
  80114d:	83 e2 03             	and    $0x3,%edx
  801150:	83 fa 01             	cmp    $0x1,%edx
  801153:	75 21                	jne    801176 <read+0x62>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801155:	a1 10 40 80 00       	mov    0x804010,%eax
  80115a:	8b 40 48             	mov    0x48(%eax),%eax
  80115d:	83 ec 04             	sub    $0x4,%esp
  801160:	53                   	push   %ebx
  801161:	50                   	push   %eax
  801162:	68 0d 24 80 00       	push   $0x80240d
  801167:	e8 a8 f0 ff ff       	call   800214 <cprintf>
		return -E_INVAL;
  80116c:	83 c4 10             	add    $0x10,%esp
  80116f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801174:	eb 20                	jmp    801196 <read+0x82>
	}
	if (!dev->dev_read)
  801176:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801179:	8b 52 08             	mov    0x8(%edx),%edx
  80117c:	85 d2                	test   %edx,%edx
  80117e:	74 11                	je     801191 <read+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801180:	83 ec 04             	sub    $0x4,%esp
  801183:	ff 75 10             	pushl  0x10(%ebp)
  801186:	ff 75 0c             	pushl  0xc(%ebp)
  801189:	50                   	push   %eax
  80118a:	ff d2                	call   *%edx
  80118c:	83 c4 10             	add    $0x10,%esp
  80118f:	eb 05                	jmp    801196 <read+0x82>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801191:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  801196:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801199:	c9                   	leave  
  80119a:	c3                   	ret    

0080119b <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80119b:	55                   	push   %ebp
  80119c:	89 e5                	mov    %esp,%ebp
  80119e:	57                   	push   %edi
  80119f:	56                   	push   %esi
  8011a0:	53                   	push   %ebx
  8011a1:	83 ec 0c             	sub    $0xc,%esp
  8011a4:	8b 7d 08             	mov    0x8(%ebp),%edi
  8011a7:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8011aa:	85 f6                	test   %esi,%esi
  8011ac:	74 31                	je     8011df <readn+0x44>
  8011ae:	b8 00 00 00 00       	mov    $0x0,%eax
  8011b3:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = read(fdnum, (char*)buf + tot, n - tot);
  8011b8:	83 ec 04             	sub    $0x4,%esp
  8011bb:	89 f2                	mov    %esi,%edx
  8011bd:	29 c2                	sub    %eax,%edx
  8011bf:	52                   	push   %edx
  8011c0:	03 45 0c             	add    0xc(%ebp),%eax
  8011c3:	50                   	push   %eax
  8011c4:	57                   	push   %edi
  8011c5:	e8 4a ff ff ff       	call   801114 <read>
		if (m < 0)
  8011ca:	83 c4 10             	add    $0x10,%esp
  8011cd:	85 c0                	test   %eax,%eax
  8011cf:	78 17                	js     8011e8 <readn+0x4d>
			return m;
		if (m == 0)
  8011d1:	85 c0                	test   %eax,%eax
  8011d3:	74 11                	je     8011e6 <readn+0x4b>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8011d5:	01 c3                	add    %eax,%ebx
  8011d7:	89 d8                	mov    %ebx,%eax
  8011d9:	39 f3                	cmp    %esi,%ebx
  8011db:	72 db                	jb     8011b8 <readn+0x1d>
  8011dd:	eb 09                	jmp    8011e8 <readn+0x4d>
  8011df:	b8 00 00 00 00       	mov    $0x0,%eax
  8011e4:	eb 02                	jmp    8011e8 <readn+0x4d>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  8011e6:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  8011e8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011eb:	5b                   	pop    %ebx
  8011ec:	5e                   	pop    %esi
  8011ed:	5f                   	pop    %edi
  8011ee:	c9                   	leave  
  8011ef:	c3                   	ret    

008011f0 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8011f0:	55                   	push   %ebp
  8011f1:	89 e5                	mov    %esp,%ebp
  8011f3:	53                   	push   %ebx
  8011f4:	83 ec 14             	sub    $0x14,%esp
  8011f7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8011fa:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011fd:	50                   	push   %eax
  8011fe:	53                   	push   %ebx
  8011ff:	e8 8f fc ff ff       	call   800e93 <fd_lookup>
  801204:	83 c4 08             	add    $0x8,%esp
  801207:	85 c0                	test   %eax,%eax
  801209:	78 62                	js     80126d <write+0x7d>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80120b:	83 ec 08             	sub    $0x8,%esp
  80120e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801211:	50                   	push   %eax
  801212:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801215:	ff 30                	pushl  (%eax)
  801217:	e8 cd fc ff ff       	call   800ee9 <dev_lookup>
  80121c:	83 c4 10             	add    $0x10,%esp
  80121f:	85 c0                	test   %eax,%eax
  801221:	78 4a                	js     80126d <write+0x7d>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801223:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801226:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80122a:	75 21                	jne    80124d <write+0x5d>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80122c:	a1 10 40 80 00       	mov    0x804010,%eax
  801231:	8b 40 48             	mov    0x48(%eax),%eax
  801234:	83 ec 04             	sub    $0x4,%esp
  801237:	53                   	push   %ebx
  801238:	50                   	push   %eax
  801239:	68 29 24 80 00       	push   $0x802429
  80123e:	e8 d1 ef ff ff       	call   800214 <cprintf>
		return -E_INVAL;
  801243:	83 c4 10             	add    $0x10,%esp
  801246:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80124b:	eb 20                	jmp    80126d <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80124d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801250:	8b 52 0c             	mov    0xc(%edx),%edx
  801253:	85 d2                	test   %edx,%edx
  801255:	74 11                	je     801268 <write+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801257:	83 ec 04             	sub    $0x4,%esp
  80125a:	ff 75 10             	pushl  0x10(%ebp)
  80125d:	ff 75 0c             	pushl  0xc(%ebp)
  801260:	50                   	push   %eax
  801261:	ff d2                	call   *%edx
  801263:	83 c4 10             	add    $0x10,%esp
  801266:	eb 05                	jmp    80126d <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801268:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  80126d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801270:	c9                   	leave  
  801271:	c3                   	ret    

00801272 <seek>:

int
seek(int fdnum, off_t offset)
{
  801272:	55                   	push   %ebp
  801273:	89 e5                	mov    %esp,%ebp
  801275:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801278:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80127b:	50                   	push   %eax
  80127c:	ff 75 08             	pushl  0x8(%ebp)
  80127f:	e8 0f fc ff ff       	call   800e93 <fd_lookup>
  801284:	83 c4 08             	add    $0x8,%esp
  801287:	85 c0                	test   %eax,%eax
  801289:	78 0e                	js     801299 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  80128b:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80128e:	8b 55 0c             	mov    0xc(%ebp),%edx
  801291:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801294:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801299:	c9                   	leave  
  80129a:	c3                   	ret    

0080129b <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80129b:	55                   	push   %ebp
  80129c:	89 e5                	mov    %esp,%ebp
  80129e:	53                   	push   %ebx
  80129f:	83 ec 14             	sub    $0x14,%esp
  8012a2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8012a5:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012a8:	50                   	push   %eax
  8012a9:	53                   	push   %ebx
  8012aa:	e8 e4 fb ff ff       	call   800e93 <fd_lookup>
  8012af:	83 c4 08             	add    $0x8,%esp
  8012b2:	85 c0                	test   %eax,%eax
  8012b4:	78 5f                	js     801315 <ftruncate+0x7a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012b6:	83 ec 08             	sub    $0x8,%esp
  8012b9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012bc:	50                   	push   %eax
  8012bd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012c0:	ff 30                	pushl  (%eax)
  8012c2:	e8 22 fc ff ff       	call   800ee9 <dev_lookup>
  8012c7:	83 c4 10             	add    $0x10,%esp
  8012ca:	85 c0                	test   %eax,%eax
  8012cc:	78 47                	js     801315 <ftruncate+0x7a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8012ce:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012d1:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8012d5:	75 21                	jne    8012f8 <ftruncate+0x5d>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8012d7:	a1 10 40 80 00       	mov    0x804010,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8012dc:	8b 40 48             	mov    0x48(%eax),%eax
  8012df:	83 ec 04             	sub    $0x4,%esp
  8012e2:	53                   	push   %ebx
  8012e3:	50                   	push   %eax
  8012e4:	68 ec 23 80 00       	push   $0x8023ec
  8012e9:	e8 26 ef ff ff       	call   800214 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8012ee:	83 c4 10             	add    $0x10,%esp
  8012f1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012f6:	eb 1d                	jmp    801315 <ftruncate+0x7a>
	}
	if (!dev->dev_trunc)
  8012f8:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8012fb:	8b 52 18             	mov    0x18(%edx),%edx
  8012fe:	85 d2                	test   %edx,%edx
  801300:	74 0e                	je     801310 <ftruncate+0x75>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801302:	83 ec 08             	sub    $0x8,%esp
  801305:	ff 75 0c             	pushl  0xc(%ebp)
  801308:	50                   	push   %eax
  801309:	ff d2                	call   *%edx
  80130b:	83 c4 10             	add    $0x10,%esp
  80130e:	eb 05                	jmp    801315 <ftruncate+0x7a>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801310:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  801315:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801318:	c9                   	leave  
  801319:	c3                   	ret    

0080131a <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80131a:	55                   	push   %ebp
  80131b:	89 e5                	mov    %esp,%ebp
  80131d:	53                   	push   %ebx
  80131e:	83 ec 14             	sub    $0x14,%esp
  801321:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801324:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801327:	50                   	push   %eax
  801328:	ff 75 08             	pushl  0x8(%ebp)
  80132b:	e8 63 fb ff ff       	call   800e93 <fd_lookup>
  801330:	83 c4 08             	add    $0x8,%esp
  801333:	85 c0                	test   %eax,%eax
  801335:	78 52                	js     801389 <fstat+0x6f>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801337:	83 ec 08             	sub    $0x8,%esp
  80133a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80133d:	50                   	push   %eax
  80133e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801341:	ff 30                	pushl  (%eax)
  801343:	e8 a1 fb ff ff       	call   800ee9 <dev_lookup>
  801348:	83 c4 10             	add    $0x10,%esp
  80134b:	85 c0                	test   %eax,%eax
  80134d:	78 3a                	js     801389 <fstat+0x6f>
		return r;
	if (!dev->dev_stat)
  80134f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801352:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801356:	74 2c                	je     801384 <fstat+0x6a>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801358:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80135b:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801362:	00 00 00 
	stat->st_isdir = 0;
  801365:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80136c:	00 00 00 
	stat->st_dev = dev;
  80136f:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801375:	83 ec 08             	sub    $0x8,%esp
  801378:	53                   	push   %ebx
  801379:	ff 75 f0             	pushl  -0x10(%ebp)
  80137c:	ff 50 14             	call   *0x14(%eax)
  80137f:	83 c4 10             	add    $0x10,%esp
  801382:	eb 05                	jmp    801389 <fstat+0x6f>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801384:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801389:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80138c:	c9                   	leave  
  80138d:	c3                   	ret    

0080138e <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80138e:	55                   	push   %ebp
  80138f:	89 e5                	mov    %esp,%ebp
  801391:	56                   	push   %esi
  801392:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801393:	83 ec 08             	sub    $0x8,%esp
  801396:	6a 00                	push   $0x0
  801398:	ff 75 08             	pushl  0x8(%ebp)
  80139b:	e8 78 01 00 00       	call   801518 <open>
  8013a0:	89 c3                	mov    %eax,%ebx
  8013a2:	83 c4 10             	add    $0x10,%esp
  8013a5:	85 c0                	test   %eax,%eax
  8013a7:	78 1b                	js     8013c4 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8013a9:	83 ec 08             	sub    $0x8,%esp
  8013ac:	ff 75 0c             	pushl  0xc(%ebp)
  8013af:	50                   	push   %eax
  8013b0:	e8 65 ff ff ff       	call   80131a <fstat>
  8013b5:	89 c6                	mov    %eax,%esi
	close(fd);
  8013b7:	89 1c 24             	mov    %ebx,(%esp)
  8013ba:	e8 18 fc ff ff       	call   800fd7 <close>
	return r;
  8013bf:	83 c4 10             	add    $0x10,%esp
  8013c2:	89 f3                	mov    %esi,%ebx
}
  8013c4:	89 d8                	mov    %ebx,%eax
  8013c6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8013c9:	5b                   	pop    %ebx
  8013ca:	5e                   	pop    %esi
  8013cb:	c9                   	leave  
  8013cc:	c3                   	ret    
  8013cd:	00 00                	add    %al,(%eax)
	...

008013d0 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8013d0:	55                   	push   %ebp
  8013d1:	89 e5                	mov    %esp,%ebp
  8013d3:	56                   	push   %esi
  8013d4:	53                   	push   %ebx
  8013d5:	89 c3                	mov    %eax,%ebx
  8013d7:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  8013d9:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8013e0:	75 12                	jne    8013f4 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8013e2:	83 ec 0c             	sub    $0xc,%esp
  8013e5:	6a 01                	push   $0x1
  8013e7:	e8 2a 09 00 00       	call   801d16 <ipc_find_env>
  8013ec:	a3 00 40 80 00       	mov    %eax,0x804000
  8013f1:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8013f4:	6a 07                	push   $0x7
  8013f6:	68 00 50 80 00       	push   $0x805000
  8013fb:	53                   	push   %ebx
  8013fc:	ff 35 00 40 80 00    	pushl  0x804000
  801402:	e8 ba 08 00 00       	call   801cc1 <ipc_send>
	
	return ipc_recv(NULL, dstva, NULL);
  801407:	83 c4 0c             	add    $0xc,%esp
  80140a:	6a 00                	push   $0x0
  80140c:	56                   	push   %esi
  80140d:	6a 00                	push   $0x0
  80140f:	e8 38 08 00 00       	call   801c4c <ipc_recv>
}
  801414:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801417:	5b                   	pop    %ebx
  801418:	5e                   	pop    %esi
  801419:	c9                   	leave  
  80141a:	c3                   	ret    

0080141b <devfile_stat>:
}


static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80141b:	55                   	push   %ebp
  80141c:	89 e5                	mov    %esp,%ebp
  80141e:	53                   	push   %ebx
  80141f:	83 ec 04             	sub    $0x4,%esp
  801422:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801425:	8b 45 08             	mov    0x8(%ebp),%eax
  801428:	8b 40 0c             	mov    0xc(%eax),%eax
  80142b:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0) {
  801430:	ba 00 00 00 00       	mov    $0x0,%edx
  801435:	b8 05 00 00 00       	mov    $0x5,%eax
  80143a:	e8 91 ff ff ff       	call   8013d0 <fsipc>
  80143f:	85 c0                	test   %eax,%eax
  801441:	78 2c                	js     80146f <devfile_stat+0x54>
		return r;
	}
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801443:	83 ec 08             	sub    $0x8,%esp
  801446:	68 00 50 80 00       	push   $0x805000
  80144b:	53                   	push   %ebx
  80144c:	e8 79 f3 ff ff       	call   8007ca <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801451:	a1 80 50 80 00       	mov    0x805080,%eax
  801456:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80145c:	a1 84 50 80 00       	mov    0x805084,%eax
  801461:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801467:	83 c4 10             	add    $0x10,%esp
  80146a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80146f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801472:	c9                   	leave  
  801473:	c3                   	ret    

00801474 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801474:	55                   	push   %ebp
  801475:	89 e5                	mov    %esp,%ebp
  801477:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80147a:	8b 45 08             	mov    0x8(%ebp),%eax
  80147d:	8b 40 0c             	mov    0xc(%eax),%eax
  801480:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801485:	ba 00 00 00 00       	mov    $0x0,%edx
  80148a:	b8 06 00 00 00       	mov    $0x6,%eax
  80148f:	e8 3c ff ff ff       	call   8013d0 <fsipc>
}
  801494:	c9                   	leave  
  801495:	c3                   	ret    

00801496 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801496:	55                   	push   %ebp
  801497:	89 e5                	mov    %esp,%ebp
  801499:	56                   	push   %esi
  80149a:	53                   	push   %ebx
  80149b:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80149e:	8b 45 08             	mov    0x8(%ebp),%eax
  8014a1:	8b 40 0c             	mov    0xc(%eax),%eax
  8014a4:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8014a9:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8014af:	ba 00 00 00 00       	mov    $0x0,%edx
  8014b4:	b8 03 00 00 00       	mov    $0x3,%eax
  8014b9:	e8 12 ff ff ff       	call   8013d0 <fsipc>
  8014be:	89 c3                	mov    %eax,%ebx
  8014c0:	85 c0                	test   %eax,%eax
  8014c2:	78 4b                	js     80150f <devfile_read+0x79>
		return r;
	assert(r <= n);
  8014c4:	39 c6                	cmp    %eax,%esi
  8014c6:	73 16                	jae    8014de <devfile_read+0x48>
  8014c8:	68 58 24 80 00       	push   $0x802458
  8014cd:	68 5f 24 80 00       	push   $0x80245f
  8014d2:	6a 7d                	push   $0x7d
  8014d4:	68 74 24 80 00       	push   $0x802474
  8014d9:	e8 26 07 00 00       	call   801c04 <_panic>
	assert(r <= PGSIZE);
  8014de:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8014e3:	7e 16                	jle    8014fb <devfile_read+0x65>
  8014e5:	68 7f 24 80 00       	push   $0x80247f
  8014ea:	68 5f 24 80 00       	push   $0x80245f
  8014ef:	6a 7e                	push   $0x7e
  8014f1:	68 74 24 80 00       	push   $0x802474
  8014f6:	e8 09 07 00 00       	call   801c04 <_panic>
	memmove(buf, &fsipcbuf, r);
  8014fb:	83 ec 04             	sub    $0x4,%esp
  8014fe:	50                   	push   %eax
  8014ff:	68 00 50 80 00       	push   $0x805000
  801504:	ff 75 0c             	pushl  0xc(%ebp)
  801507:	e8 7f f4 ff ff       	call   80098b <memmove>
	return r;
  80150c:	83 c4 10             	add    $0x10,%esp
}
  80150f:	89 d8                	mov    %ebx,%eax
  801511:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801514:	5b                   	pop    %ebx
  801515:	5e                   	pop    %esi
  801516:	c9                   	leave  
  801517:	c3                   	ret    

00801518 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801518:	55                   	push   %ebp
  801519:	89 e5                	mov    %esp,%ebp
  80151b:	56                   	push   %esi
  80151c:	53                   	push   %ebx
  80151d:	83 ec 1c             	sub    $0x1c,%esp
  801520:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801523:	56                   	push   %esi
  801524:	e8 4f f2 ff ff       	call   800778 <strlen>
  801529:	83 c4 10             	add    $0x10,%esp
  80152c:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801531:	7f 65                	jg     801598 <open+0x80>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801533:	83 ec 0c             	sub    $0xc,%esp
  801536:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801539:	50                   	push   %eax
  80153a:	e8 e1 f8 ff ff       	call   800e20 <fd_alloc>
  80153f:	89 c3                	mov    %eax,%ebx
  801541:	83 c4 10             	add    $0x10,%esp
  801544:	85 c0                	test   %eax,%eax
  801546:	78 55                	js     80159d <open+0x85>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801548:	83 ec 08             	sub    $0x8,%esp
  80154b:	56                   	push   %esi
  80154c:	68 00 50 80 00       	push   $0x805000
  801551:	e8 74 f2 ff ff       	call   8007ca <strcpy>
	fsipcbuf.open.req_omode = mode;
  801556:	8b 45 0c             	mov    0xc(%ebp),%eax
  801559:	a3 00 54 80 00       	mov    %eax,0x805400



	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  80155e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801561:	b8 01 00 00 00       	mov    $0x1,%eax
  801566:	e8 65 fe ff ff       	call   8013d0 <fsipc>
  80156b:	89 c3                	mov    %eax,%ebx
  80156d:	83 c4 10             	add    $0x10,%esp
  801570:	85 c0                	test   %eax,%eax
  801572:	79 12                	jns    801586 <open+0x6e>
		fd_close(fd, 0);
  801574:	83 ec 08             	sub    $0x8,%esp
  801577:	6a 00                	push   $0x0
  801579:	ff 75 f4             	pushl  -0xc(%ebp)
  80157c:	e8 ce f9 ff ff       	call   800f4f <fd_close>
		return r;
  801581:	83 c4 10             	add    $0x10,%esp
  801584:	eb 17                	jmp    80159d <open+0x85>
	}

	return fd2num(fd);
  801586:	83 ec 0c             	sub    $0xc,%esp
  801589:	ff 75 f4             	pushl  -0xc(%ebp)
  80158c:	e8 67 f8 ff ff       	call   800df8 <fd2num>
  801591:	89 c3                	mov    %eax,%ebx
  801593:	83 c4 10             	add    $0x10,%esp
  801596:	eb 05                	jmp    80159d <open+0x85>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801598:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  80159d:	89 d8                	mov    %ebx,%eax
  80159f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8015a2:	5b                   	pop    %ebx
  8015a3:	5e                   	pop    %esi
  8015a4:	c9                   	leave  
  8015a5:	c3                   	ret    
	...

008015a8 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8015a8:	55                   	push   %ebp
  8015a9:	89 e5                	mov    %esp,%ebp
  8015ab:	56                   	push   %esi
  8015ac:	53                   	push   %ebx
  8015ad:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8015b0:	83 ec 0c             	sub    $0xc,%esp
  8015b3:	ff 75 08             	pushl  0x8(%ebp)
  8015b6:	e8 4d f8 ff ff       	call   800e08 <fd2data>
  8015bb:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  8015bd:	83 c4 08             	add    $0x8,%esp
  8015c0:	68 8b 24 80 00       	push   $0x80248b
  8015c5:	56                   	push   %esi
  8015c6:	e8 ff f1 ff ff       	call   8007ca <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8015cb:	8b 43 04             	mov    0x4(%ebx),%eax
  8015ce:	2b 03                	sub    (%ebx),%eax
  8015d0:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  8015d6:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  8015dd:	00 00 00 
	stat->st_dev = &devpipe;
  8015e0:	c7 86 88 00 00 00 20 	movl   $0x803020,0x88(%esi)
  8015e7:	30 80 00 
	return 0;
}
  8015ea:	b8 00 00 00 00       	mov    $0x0,%eax
  8015ef:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8015f2:	5b                   	pop    %ebx
  8015f3:	5e                   	pop    %esi
  8015f4:	c9                   	leave  
  8015f5:	c3                   	ret    

008015f6 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8015f6:	55                   	push   %ebp
  8015f7:	89 e5                	mov    %esp,%ebp
  8015f9:	53                   	push   %ebx
  8015fa:	83 ec 0c             	sub    $0xc,%esp
  8015fd:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801600:	53                   	push   %ebx
  801601:	6a 00                	push   $0x0
  801603:	e8 8e f6 ff ff       	call   800c96 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801608:	89 1c 24             	mov    %ebx,(%esp)
  80160b:	e8 f8 f7 ff ff       	call   800e08 <fd2data>
  801610:	83 c4 08             	add    $0x8,%esp
  801613:	50                   	push   %eax
  801614:	6a 00                	push   $0x0
  801616:	e8 7b f6 ff ff       	call   800c96 <sys_page_unmap>
}
  80161b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80161e:	c9                   	leave  
  80161f:	c3                   	ret    

00801620 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801620:	55                   	push   %ebp
  801621:	89 e5                	mov    %esp,%ebp
  801623:	57                   	push   %edi
  801624:	56                   	push   %esi
  801625:	53                   	push   %ebx
  801626:	83 ec 1c             	sub    $0x1c,%esp
  801629:	89 c7                	mov    %eax,%edi
  80162b:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  80162e:	a1 10 40 80 00       	mov    0x804010,%eax
  801633:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801636:	83 ec 0c             	sub    $0xc,%esp
  801639:	57                   	push   %edi
  80163a:	e8 25 07 00 00       	call   801d64 <pageref>
  80163f:	89 c6                	mov    %eax,%esi
  801641:	83 c4 04             	add    $0x4,%esp
  801644:	ff 75 e4             	pushl  -0x1c(%ebp)
  801647:	e8 18 07 00 00       	call   801d64 <pageref>
  80164c:	83 c4 10             	add    $0x10,%esp
  80164f:	39 c6                	cmp    %eax,%esi
  801651:	0f 94 c0             	sete   %al
  801654:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  801657:	8b 15 10 40 80 00    	mov    0x804010,%edx
  80165d:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801660:	39 cb                	cmp    %ecx,%ebx
  801662:	75 08                	jne    80166c <_pipeisclosed+0x4c>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  801664:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801667:	5b                   	pop    %ebx
  801668:	5e                   	pop    %esi
  801669:	5f                   	pop    %edi
  80166a:	c9                   	leave  
  80166b:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  80166c:	83 f8 01             	cmp    $0x1,%eax
  80166f:	75 bd                	jne    80162e <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801671:	8b 42 58             	mov    0x58(%edx),%eax
  801674:	6a 01                	push   $0x1
  801676:	50                   	push   %eax
  801677:	53                   	push   %ebx
  801678:	68 92 24 80 00       	push   $0x802492
  80167d:	e8 92 eb ff ff       	call   800214 <cprintf>
  801682:	83 c4 10             	add    $0x10,%esp
  801685:	eb a7                	jmp    80162e <_pipeisclosed+0xe>

00801687 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801687:	55                   	push   %ebp
  801688:	89 e5                	mov    %esp,%ebp
  80168a:	57                   	push   %edi
  80168b:	56                   	push   %esi
  80168c:	53                   	push   %ebx
  80168d:	83 ec 28             	sub    $0x28,%esp
  801690:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801693:	56                   	push   %esi
  801694:	e8 6f f7 ff ff       	call   800e08 <fd2data>
  801699:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80169b:	83 c4 10             	add    $0x10,%esp
  80169e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8016a2:	75 4a                	jne    8016ee <devpipe_write+0x67>
  8016a4:	bf 00 00 00 00       	mov    $0x0,%edi
  8016a9:	eb 56                	jmp    801701 <devpipe_write+0x7a>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  8016ab:	89 da                	mov    %ebx,%edx
  8016ad:	89 f0                	mov    %esi,%eax
  8016af:	e8 6c ff ff ff       	call   801620 <_pipeisclosed>
  8016b4:	85 c0                	test   %eax,%eax
  8016b6:	75 4d                	jne    801705 <devpipe_write+0x7e>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  8016b8:	e8 68 f5 ff ff       	call   800c25 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8016bd:	8b 43 04             	mov    0x4(%ebx),%eax
  8016c0:	8b 13                	mov    (%ebx),%edx
  8016c2:	83 c2 20             	add    $0x20,%edx
  8016c5:	39 d0                	cmp    %edx,%eax
  8016c7:	73 e2                	jae    8016ab <devpipe_write+0x24>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  8016c9:	89 c2                	mov    %eax,%edx
  8016cb:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  8016d1:	79 05                	jns    8016d8 <devpipe_write+0x51>
  8016d3:	4a                   	dec    %edx
  8016d4:	83 ca e0             	or     $0xffffffe0,%edx
  8016d7:	42                   	inc    %edx
  8016d8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8016db:	8a 0c 39             	mov    (%ecx,%edi,1),%cl
  8016de:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  8016e2:	40                   	inc    %eax
  8016e3:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8016e6:	47                   	inc    %edi
  8016e7:	39 7d 10             	cmp    %edi,0x10(%ebp)
  8016ea:	77 07                	ja     8016f3 <devpipe_write+0x6c>
  8016ec:	eb 13                	jmp    801701 <devpipe_write+0x7a>
  8016ee:	bf 00 00 00 00       	mov    $0x0,%edi
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8016f3:	8b 43 04             	mov    0x4(%ebx),%eax
  8016f6:	8b 13                	mov    (%ebx),%edx
  8016f8:	83 c2 20             	add    $0x20,%edx
  8016fb:	39 d0                	cmp    %edx,%eax
  8016fd:	73 ac                	jae    8016ab <devpipe_write+0x24>
  8016ff:	eb c8                	jmp    8016c9 <devpipe_write+0x42>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801701:	89 f8                	mov    %edi,%eax
  801703:	eb 05                	jmp    80170a <devpipe_write+0x83>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801705:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  80170a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80170d:	5b                   	pop    %ebx
  80170e:	5e                   	pop    %esi
  80170f:	5f                   	pop    %edi
  801710:	c9                   	leave  
  801711:	c3                   	ret    

00801712 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801712:	55                   	push   %ebp
  801713:	89 e5                	mov    %esp,%ebp
  801715:	57                   	push   %edi
  801716:	56                   	push   %esi
  801717:	53                   	push   %ebx
  801718:	83 ec 18             	sub    $0x18,%esp
  80171b:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  80171e:	57                   	push   %edi
  80171f:	e8 e4 f6 ff ff       	call   800e08 <fd2data>
  801724:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801726:	83 c4 10             	add    $0x10,%esp
  801729:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80172d:	75 44                	jne    801773 <devpipe_read+0x61>
  80172f:	be 00 00 00 00       	mov    $0x0,%esi
  801734:	eb 4f                	jmp    801785 <devpipe_read+0x73>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
				return i;
  801736:	89 f0                	mov    %esi,%eax
  801738:	eb 54                	jmp    80178e <devpipe_read+0x7c>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  80173a:	89 da                	mov    %ebx,%edx
  80173c:	89 f8                	mov    %edi,%eax
  80173e:	e8 dd fe ff ff       	call   801620 <_pipeisclosed>
  801743:	85 c0                	test   %eax,%eax
  801745:	75 42                	jne    801789 <devpipe_read+0x77>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801747:	e8 d9 f4 ff ff       	call   800c25 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  80174c:	8b 03                	mov    (%ebx),%eax
  80174e:	3b 43 04             	cmp    0x4(%ebx),%eax
  801751:	74 e7                	je     80173a <devpipe_read+0x28>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801753:	25 1f 00 00 80       	and    $0x8000001f,%eax
  801758:	79 05                	jns    80175f <devpipe_read+0x4d>
  80175a:	48                   	dec    %eax
  80175b:	83 c8 e0             	or     $0xffffffe0,%eax
  80175e:	40                   	inc    %eax
  80175f:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  801763:	8b 55 0c             	mov    0xc(%ebp),%edx
  801766:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  801769:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80176b:	46                   	inc    %esi
  80176c:	39 75 10             	cmp    %esi,0x10(%ebp)
  80176f:	77 07                	ja     801778 <devpipe_read+0x66>
  801771:	eb 12                	jmp    801785 <devpipe_read+0x73>
  801773:	be 00 00 00 00       	mov    $0x0,%esi
		while (p->p_rpos == p->p_wpos) {
  801778:	8b 03                	mov    (%ebx),%eax
  80177a:	3b 43 04             	cmp    0x4(%ebx),%eax
  80177d:	75 d4                	jne    801753 <devpipe_read+0x41>
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  80177f:	85 f6                	test   %esi,%esi
  801781:	75 b3                	jne    801736 <devpipe_read+0x24>
  801783:	eb b5                	jmp    80173a <devpipe_read+0x28>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801785:	89 f0                	mov    %esi,%eax
  801787:	eb 05                	jmp    80178e <devpipe_read+0x7c>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801789:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  80178e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801791:	5b                   	pop    %ebx
  801792:	5e                   	pop    %esi
  801793:	5f                   	pop    %edi
  801794:	c9                   	leave  
  801795:	c3                   	ret    

00801796 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801796:	55                   	push   %ebp
  801797:	89 e5                	mov    %esp,%ebp
  801799:	57                   	push   %edi
  80179a:	56                   	push   %esi
  80179b:	53                   	push   %ebx
  80179c:	83 ec 28             	sub    $0x28,%esp
  80179f:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  8017a2:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8017a5:	50                   	push   %eax
  8017a6:	e8 75 f6 ff ff       	call   800e20 <fd_alloc>
  8017ab:	89 c3                	mov    %eax,%ebx
  8017ad:	83 c4 10             	add    $0x10,%esp
  8017b0:	85 c0                	test   %eax,%eax
  8017b2:	0f 88 24 01 00 00    	js     8018dc <pipe+0x146>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8017b8:	83 ec 04             	sub    $0x4,%esp
  8017bb:	68 07 04 00 00       	push   $0x407
  8017c0:	ff 75 e4             	pushl  -0x1c(%ebp)
  8017c3:	6a 00                	push   $0x0
  8017c5:	e8 82 f4 ff ff       	call   800c4c <sys_page_alloc>
  8017ca:	89 c3                	mov    %eax,%ebx
  8017cc:	83 c4 10             	add    $0x10,%esp
  8017cf:	85 c0                	test   %eax,%eax
  8017d1:	0f 88 05 01 00 00    	js     8018dc <pipe+0x146>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  8017d7:	83 ec 0c             	sub    $0xc,%esp
  8017da:	8d 45 e0             	lea    -0x20(%ebp),%eax
  8017dd:	50                   	push   %eax
  8017de:	e8 3d f6 ff ff       	call   800e20 <fd_alloc>
  8017e3:	89 c3                	mov    %eax,%ebx
  8017e5:	83 c4 10             	add    $0x10,%esp
  8017e8:	85 c0                	test   %eax,%eax
  8017ea:	0f 88 dc 00 00 00    	js     8018cc <pipe+0x136>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8017f0:	83 ec 04             	sub    $0x4,%esp
  8017f3:	68 07 04 00 00       	push   $0x407
  8017f8:	ff 75 e0             	pushl  -0x20(%ebp)
  8017fb:	6a 00                	push   $0x0
  8017fd:	e8 4a f4 ff ff       	call   800c4c <sys_page_alloc>
  801802:	89 c3                	mov    %eax,%ebx
  801804:	83 c4 10             	add    $0x10,%esp
  801807:	85 c0                	test   %eax,%eax
  801809:	0f 88 bd 00 00 00    	js     8018cc <pipe+0x136>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  80180f:	83 ec 0c             	sub    $0xc,%esp
  801812:	ff 75 e4             	pushl  -0x1c(%ebp)
  801815:	e8 ee f5 ff ff       	call   800e08 <fd2data>
  80181a:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80181c:	83 c4 0c             	add    $0xc,%esp
  80181f:	68 07 04 00 00       	push   $0x407
  801824:	50                   	push   %eax
  801825:	6a 00                	push   $0x0
  801827:	e8 20 f4 ff ff       	call   800c4c <sys_page_alloc>
  80182c:	89 c3                	mov    %eax,%ebx
  80182e:	83 c4 10             	add    $0x10,%esp
  801831:	85 c0                	test   %eax,%eax
  801833:	0f 88 83 00 00 00    	js     8018bc <pipe+0x126>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801839:	83 ec 0c             	sub    $0xc,%esp
  80183c:	ff 75 e0             	pushl  -0x20(%ebp)
  80183f:	e8 c4 f5 ff ff       	call   800e08 <fd2data>
  801844:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  80184b:	50                   	push   %eax
  80184c:	6a 00                	push   $0x0
  80184e:	56                   	push   %esi
  80184f:	6a 00                	push   $0x0
  801851:	e8 1a f4 ff ff       	call   800c70 <sys_page_map>
  801856:	89 c3                	mov    %eax,%ebx
  801858:	83 c4 20             	add    $0x20,%esp
  80185b:	85 c0                	test   %eax,%eax
  80185d:	78 4f                	js     8018ae <pipe+0x118>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  80185f:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801865:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801868:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  80186a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80186d:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801874:	8b 15 20 30 80 00    	mov    0x803020,%edx
  80187a:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80187d:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  80187f:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801882:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801889:	83 ec 0c             	sub    $0xc,%esp
  80188c:	ff 75 e4             	pushl  -0x1c(%ebp)
  80188f:	e8 64 f5 ff ff       	call   800df8 <fd2num>
  801894:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  801896:	83 c4 04             	add    $0x4,%esp
  801899:	ff 75 e0             	pushl  -0x20(%ebp)
  80189c:	e8 57 f5 ff ff       	call   800df8 <fd2num>
  8018a1:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  8018a4:	83 c4 10             	add    $0x10,%esp
  8018a7:	bb 00 00 00 00       	mov    $0x0,%ebx
  8018ac:	eb 2e                	jmp    8018dc <pipe+0x146>

    err3:
	sys_page_unmap(0, va);
  8018ae:	83 ec 08             	sub    $0x8,%esp
  8018b1:	56                   	push   %esi
  8018b2:	6a 00                	push   $0x0
  8018b4:	e8 dd f3 ff ff       	call   800c96 <sys_page_unmap>
  8018b9:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  8018bc:	83 ec 08             	sub    $0x8,%esp
  8018bf:	ff 75 e0             	pushl  -0x20(%ebp)
  8018c2:	6a 00                	push   $0x0
  8018c4:	e8 cd f3 ff ff       	call   800c96 <sys_page_unmap>
  8018c9:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  8018cc:	83 ec 08             	sub    $0x8,%esp
  8018cf:	ff 75 e4             	pushl  -0x1c(%ebp)
  8018d2:	6a 00                	push   $0x0
  8018d4:	e8 bd f3 ff ff       	call   800c96 <sys_page_unmap>
  8018d9:	83 c4 10             	add    $0x10,%esp
    err:
	return r;
}
  8018dc:	89 d8                	mov    %ebx,%eax
  8018de:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8018e1:	5b                   	pop    %ebx
  8018e2:	5e                   	pop    %esi
  8018e3:	5f                   	pop    %edi
  8018e4:	c9                   	leave  
  8018e5:	c3                   	ret    

008018e6 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  8018e6:	55                   	push   %ebp
  8018e7:	89 e5                	mov    %esp,%ebp
  8018e9:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8018ec:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018ef:	50                   	push   %eax
  8018f0:	ff 75 08             	pushl  0x8(%ebp)
  8018f3:	e8 9b f5 ff ff       	call   800e93 <fd_lookup>
  8018f8:	83 c4 10             	add    $0x10,%esp
  8018fb:	85 c0                	test   %eax,%eax
  8018fd:	78 18                	js     801917 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  8018ff:	83 ec 0c             	sub    $0xc,%esp
  801902:	ff 75 f4             	pushl  -0xc(%ebp)
  801905:	e8 fe f4 ff ff       	call   800e08 <fd2data>
	return _pipeisclosed(fd, p);
  80190a:	89 c2                	mov    %eax,%edx
  80190c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80190f:	e8 0c fd ff ff       	call   801620 <_pipeisclosed>
  801914:	83 c4 10             	add    $0x10,%esp
}
  801917:	c9                   	leave  
  801918:	c3                   	ret    
  801919:	00 00                	add    %al,(%eax)
	...

0080191c <pthread_create>:
#include <inc/lib.h>
#include <inc/x86.h>

int
pthread_create(uint32_t * t_id, void (*f)(void *), void *arg) 
{
  80191c:	55                   	push   %ebp
  80191d:	89 e5                	mov    %esp,%ebp
  80191f:	57                   	push   %edi
  801920:	56                   	push   %esi
  801921:	53                   	push   %ebx
  801922:	83 ec 78             	sub    $0x78,%esp
	char * t_stack = malloc(PGSIZE);
  801925:	68 00 10 00 00       	push   $0x1000
  80192a:	e8 79 04 00 00       	call   801da8 <malloc>
  80192f:	89 c3                	mov    %eax,%ebx
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exothread(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  801931:	ba 12 00 00 00       	mov    $0x12,%edx
  801936:	89 d0                	mov    %edx,%eax
  801938:	cd 30                	int    $0x30
  80193a:	89 45 94             	mov    %eax,-0x6c(%ebp)
	struct Trapframe child_tf;

	int childpid = sys_exothread();
	if (childpid < 0) {
  80193d:	83 c4 10             	add    $0x10,%esp
  801940:	85 c0                	test   %eax,%eax
  801942:	79 12                	jns    801956 <pthread_create+0x3a>
		panic("fork sys_exofork error : %e\n", childpid);
  801944:	50                   	push   %eax
  801945:	68 aa 24 80 00       	push   $0x8024aa
  80194a:	6a 0d                	push   $0xd
  80194c:	68 c7 24 80 00       	push   $0x8024c7
  801951:	e8 ae 02 00 00       	call   801c04 <_panic>
	}

	int r;
	uint32_t sta_top, sta[2];
	sta_top = (uint32_t)t_stack + PGSIZE;
	sta[0] = (uint32_t)exit;					// return address
  801956:	c7 45 9c 68 01 80 00 	movl   $0x800168,-0x64(%ebp)
	sta[1] = (uint32_t)arg;					// thread arg
  80195d:	8b 45 10             	mov    0x10(%ebp),%eax
  801960:	89 45 a0             	mov    %eax,-0x60(%ebp)
	sta_top -= 2 * sizeof(uint32_t);		
  801963:	81 c3 f8 0f 00 00    	add    $0xff8,%ebx
	memcpy((void *)sta_top, (void *)sta, 2 * sizeof(uint32_t));
  801969:	83 ec 04             	sub    $0x4,%esp
  80196c:	6a 08                	push   $0x8
  80196e:	8d 45 9c             	lea    -0x64(%ebp),%eax
  801971:	50                   	push   %eax
  801972:	53                   	push   %ebx
  801973:	e8 7d f0 ff ff       	call   8009f5 <memcpy>

	child_tf = envs[ENVX(childpid)].env_tf;
  801978:	8b 45 94             	mov    -0x6c(%ebp),%eax
  80197b:	25 ff 03 00 00       	and    $0x3ff,%eax
  801980:	89 c2                	mov    %eax,%edx
  801982:	c1 e2 07             	shl    $0x7,%edx
  801985:	8d b4 82 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,4),%esi
  80198c:	8d 7d a4             	lea    -0x5c(%ebp),%edi
  80198f:	b9 11 00 00 00       	mov    $0x11,%ecx
  801994:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  	child_tf.tf_eip = (uint32_t)f;				// set eip
  801996:	8b 45 0c             	mov    0xc(%ebp),%eax
  801999:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	child_tf.tf_esp = sta_top;						// set esp
  80199c:	89 5d e0             	mov    %ebx,-0x20(%ebp)

	if ((r = sys_env_set_trapframe(childpid, &child_tf)) < 0) {
  80199f:	83 c4 08             	add    $0x8,%esp
  8019a2:	8d 45 a4             	lea    -0x5c(%ebp),%eax
  8019a5:	50                   	push   %eax
  8019a6:	ff 75 94             	pushl  -0x6c(%ebp)
  8019a9:	e8 2e f3 ff ff       	call   800cdc <sys_env_set_trapframe>
  8019ae:	89 c3                	mov    %eax,%ebx
  8019b0:	83 c4 10             	add    $0x10,%esp
  8019b3:	85 c0                	test   %eax,%eax
  8019b5:	79 13                	jns    8019ca <pthread_create+0xae>
		cprintf("pthread create: sys_env_set_trapframe: %e\n", r);
  8019b7:	83 ec 08             	sub    $0x8,%esp
  8019ba:	50                   	push   %eax
  8019bb:	68 d4 24 80 00       	push   $0x8024d4
  8019c0:	e8 4f e8 ff ff       	call   800214 <cprintf>
		return r;
  8019c5:	83 c4 10             	add    $0x10,%esp
  8019c8:	eb 36                	jmp    801a00 <pthread_create+0xe4>
	}
	if ((r = sys_env_set_status(childpid, ENV_RUNNABLE)) < 0) {
  8019ca:	83 ec 08             	sub    $0x8,%esp
  8019cd:	6a 02                	push   $0x2
  8019cf:	ff 75 94             	pushl  -0x6c(%ebp)
  8019d2:	e8 e2 f2 ff ff       	call   800cb9 <sys_env_set_status>
  8019d7:	89 c3                	mov    %eax,%ebx
  8019d9:	83 c4 10             	add    $0x10,%esp
  8019dc:	85 c0                	test   %eax,%eax
  8019de:	79 13                	jns    8019f3 <pthread_create+0xd7>
		cprintf("pthread create: set thread status error : %e\n", r);
  8019e0:	83 ec 08             	sub    $0x8,%esp
  8019e3:	50                   	push   %eax
  8019e4:	68 00 25 80 00       	push   $0x802500
  8019e9:	e8 26 e8 ff ff       	call   800214 <cprintf>
		return r;
  8019ee:	83 c4 10             	add    $0x10,%esp
  8019f1:	eb 0d                	jmp    801a00 <pthread_create+0xe4>
	}

	*t_id = childpid;
  8019f3:	8b 45 08             	mov    0x8(%ebp),%eax
  8019f6:	8b 55 94             	mov    -0x6c(%ebp),%edx
  8019f9:	89 10                	mov    %edx,(%eax)
	return 0;
  8019fb:	bb 00 00 00 00       	mov    $0x0,%ebx
}
  801a00:	89 d8                	mov    %ebx,%eax
  801a02:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a05:	5b                   	pop    %ebx
  801a06:	5e                   	pop    %esi
  801a07:	5f                   	pop    %edi
  801a08:	c9                   	leave  
  801a09:	c3                   	ret    

00801a0a <pthread_join>:

int 
pthread_join(envid_t id) 
{
  801a0a:	55                   	push   %ebp
  801a0b:	89 e5                	mov    %esp,%ebp
  801a0d:	53                   	push   %ebx
  801a0e:	83 ec 04             	sub    $0x4,%esp
  801a11:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	while (1) {
		r = sys_join(id);
  801a14:	83 ec 0c             	sub    $0xc,%esp
  801a17:	53                   	push   %ebx
  801a18:	e8 94 f3 ff ff       	call   800db1 <sys_join>
		if (r != 0) break;
  801a1d:	83 c4 10             	add    $0x10,%esp
  801a20:	85 c0                	test   %eax,%eax
  801a22:	75 07                	jne    801a2b <pthread_join+0x21>
		sys_yield();
  801a24:	e8 fc f1 ff ff       	call   800c25 <sys_yield>
	}
  801a29:	eb e9                	jmp    801a14 <pthread_join+0xa>
	return r;
}
  801a2b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a2e:	c9                   	leave  
  801a2f:	c3                   	ret    

00801a30 <pthread_mutex_init>:

int
pthread_mutex_init(pthread_mutex_t * mutex)
{
  801a30:	55                   	push   %ebp
  801a31:	89 e5                	mov    %esp,%ebp
	mutex->lock = 0;
  801a33:	8b 45 08             	mov    0x8(%ebp),%eax
  801a36:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return 0;
}
  801a3c:	b8 00 00 00 00       	mov    $0x0,%eax
  801a41:	c9                   	leave  
  801a42:	c3                   	ret    

00801a43 <pthread_mutex_lock>:

int
pthread_mutex_lock(pthread_mutex_t * mutex)
{
  801a43:	55                   	push   %ebp
  801a44:	89 e5                	mov    %esp,%ebp
  801a46:	8b 55 08             	mov    0x8(%ebp),%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1" :
  801a49:	b9 01 00 00 00       	mov    $0x1,%ecx
  801a4e:	89 c8                	mov    %ecx,%eax
  801a50:	f0 87 02             	lock xchg %eax,(%edx)
	while (xchg(&mutex->lock, 1) == 1)
  801a53:	83 f8 01             	cmp    $0x1,%eax
  801a56:	74 f6                	je     801a4e <pthread_mutex_lock+0xb>
		;
	return 0;
}
  801a58:	b8 00 00 00 00       	mov    $0x0,%eax
  801a5d:	c9                   	leave  
  801a5e:	c3                   	ret    

00801a5f <pthread_mutex_unlock>:

int
pthread_mutex_unlock(pthread_mutex_t * mutex)
{
  801a5f:	55                   	push   %ebp
  801a60:	89 e5                	mov    %esp,%ebp
  801a62:	8b 55 08             	mov    0x8(%ebp),%edx
  801a65:	b8 00 00 00 00       	mov    $0x0,%eax
  801a6a:	f0 87 02             	lock xchg %eax,(%edx)
	xchg(&mutex->lock, 0);
	return 0;
  801a6d:	b8 00 00 00 00       	mov    $0x0,%eax
  801a72:	c9                   	leave  
  801a73:	c3                   	ret    

00801a74 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801a74:	55                   	push   %ebp
  801a75:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801a77:	b8 00 00 00 00       	mov    $0x0,%eax
  801a7c:	c9                   	leave  
  801a7d:	c3                   	ret    

00801a7e <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801a7e:	55                   	push   %ebp
  801a7f:	89 e5                	mov    %esp,%ebp
  801a81:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801a84:	68 2e 25 80 00       	push   $0x80252e
  801a89:	ff 75 0c             	pushl  0xc(%ebp)
  801a8c:	e8 39 ed ff ff       	call   8007ca <strcpy>
	return 0;
}
  801a91:	b8 00 00 00 00       	mov    $0x0,%eax
  801a96:	c9                   	leave  
  801a97:	c3                   	ret    

00801a98 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801a98:	55                   	push   %ebp
  801a99:	89 e5                	mov    %esp,%ebp
  801a9b:	57                   	push   %edi
  801a9c:	56                   	push   %esi
  801a9d:	53                   	push   %ebx
  801a9e:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801aa4:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801aa8:	74 45                	je     801aef <devcons_write+0x57>
  801aaa:	b8 00 00 00 00       	mov    $0x0,%eax
  801aaf:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801ab4:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801aba:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801abd:	29 c3                	sub    %eax,%ebx
		if (m > sizeof(buf) - 1)
  801abf:	83 fb 7f             	cmp    $0x7f,%ebx
  801ac2:	76 05                	jbe    801ac9 <devcons_write+0x31>
			m = sizeof(buf) - 1;
  801ac4:	bb 7f 00 00 00       	mov    $0x7f,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  801ac9:	83 ec 04             	sub    $0x4,%esp
  801acc:	53                   	push   %ebx
  801acd:	03 45 0c             	add    0xc(%ebp),%eax
  801ad0:	50                   	push   %eax
  801ad1:	57                   	push   %edi
  801ad2:	e8 b4 ee ff ff       	call   80098b <memmove>
		sys_cputs(buf, m);
  801ad7:	83 c4 08             	add    $0x8,%esp
  801ada:	53                   	push   %ebx
  801adb:	57                   	push   %edi
  801adc:	e8 b4 f0 ff ff       	call   800b95 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801ae1:	01 de                	add    %ebx,%esi
  801ae3:	89 f0                	mov    %esi,%eax
  801ae5:	83 c4 10             	add    $0x10,%esp
  801ae8:	3b 75 10             	cmp    0x10(%ebp),%esi
  801aeb:	72 cd                	jb     801aba <devcons_write+0x22>
  801aed:	eb 05                	jmp    801af4 <devcons_write+0x5c>
  801aef:	be 00 00 00 00       	mov    $0x0,%esi
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801af4:	89 f0                	mov    %esi,%eax
  801af6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801af9:	5b                   	pop    %ebx
  801afa:	5e                   	pop    %esi
  801afb:	5f                   	pop    %edi
  801afc:	c9                   	leave  
  801afd:	c3                   	ret    

00801afe <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801afe:	55                   	push   %ebp
  801aff:	89 e5                	mov    %esp,%ebp
  801b01:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  801b04:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801b08:	75 07                	jne    801b11 <devcons_read+0x13>
  801b0a:	eb 25                	jmp    801b31 <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801b0c:	e8 14 f1 ff ff       	call   800c25 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801b11:	e8 a5 f0 ff ff       	call   800bbb <sys_cgetc>
  801b16:	85 c0                	test   %eax,%eax
  801b18:	74 f2                	je     801b0c <devcons_read+0xe>
  801b1a:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  801b1c:	85 c0                	test   %eax,%eax
  801b1e:	78 1d                	js     801b3d <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801b20:	83 f8 04             	cmp    $0x4,%eax
  801b23:	74 13                	je     801b38 <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  801b25:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b28:	88 10                	mov    %dl,(%eax)
	return 1;
  801b2a:	b8 01 00 00 00       	mov    $0x1,%eax
  801b2f:	eb 0c                	jmp    801b3d <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  801b31:	b8 00 00 00 00       	mov    $0x0,%eax
  801b36:	eb 05                	jmp    801b3d <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801b38:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801b3d:	c9                   	leave  
  801b3e:	c3                   	ret    

00801b3f <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801b3f:	55                   	push   %ebp
  801b40:	89 e5                	mov    %esp,%ebp
  801b42:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801b45:	8b 45 08             	mov    0x8(%ebp),%eax
  801b48:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801b4b:	6a 01                	push   $0x1
  801b4d:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801b50:	50                   	push   %eax
  801b51:	e8 3f f0 ff ff       	call   800b95 <sys_cputs>
  801b56:	83 c4 10             	add    $0x10,%esp
}
  801b59:	c9                   	leave  
  801b5a:	c3                   	ret    

00801b5b <getchar>:

int
getchar(void)
{
  801b5b:	55                   	push   %ebp
  801b5c:	89 e5                	mov    %esp,%ebp
  801b5e:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801b61:	6a 01                	push   $0x1
  801b63:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801b66:	50                   	push   %eax
  801b67:	6a 00                	push   $0x0
  801b69:	e8 a6 f5 ff ff       	call   801114 <read>
	if (r < 0)
  801b6e:	83 c4 10             	add    $0x10,%esp
  801b71:	85 c0                	test   %eax,%eax
  801b73:	78 0f                	js     801b84 <getchar+0x29>
		return r;
	if (r < 1)
  801b75:	85 c0                	test   %eax,%eax
  801b77:	7e 06                	jle    801b7f <getchar+0x24>
		return -E_EOF;
	return c;
  801b79:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801b7d:	eb 05                	jmp    801b84 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801b7f:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801b84:	c9                   	leave  
  801b85:	c3                   	ret    

00801b86 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801b86:	55                   	push   %ebp
  801b87:	89 e5                	mov    %esp,%ebp
  801b89:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801b8c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b8f:	50                   	push   %eax
  801b90:	ff 75 08             	pushl  0x8(%ebp)
  801b93:	e8 fb f2 ff ff       	call   800e93 <fd_lookup>
  801b98:	83 c4 10             	add    $0x10,%esp
  801b9b:	85 c0                	test   %eax,%eax
  801b9d:	78 11                	js     801bb0 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801b9f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ba2:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801ba8:	39 10                	cmp    %edx,(%eax)
  801baa:	0f 94 c0             	sete   %al
  801bad:	0f b6 c0             	movzbl %al,%eax
}
  801bb0:	c9                   	leave  
  801bb1:	c3                   	ret    

00801bb2 <opencons>:

int
opencons(void)
{
  801bb2:	55                   	push   %ebp
  801bb3:	89 e5                	mov    %esp,%ebp
  801bb5:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801bb8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801bbb:	50                   	push   %eax
  801bbc:	e8 5f f2 ff ff       	call   800e20 <fd_alloc>
  801bc1:	83 c4 10             	add    $0x10,%esp
  801bc4:	85 c0                	test   %eax,%eax
  801bc6:	78 3a                	js     801c02 <opencons+0x50>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801bc8:	83 ec 04             	sub    $0x4,%esp
  801bcb:	68 07 04 00 00       	push   $0x407
  801bd0:	ff 75 f4             	pushl  -0xc(%ebp)
  801bd3:	6a 00                	push   $0x0
  801bd5:	e8 72 f0 ff ff       	call   800c4c <sys_page_alloc>
  801bda:	83 c4 10             	add    $0x10,%esp
  801bdd:	85 c0                	test   %eax,%eax
  801bdf:	78 21                	js     801c02 <opencons+0x50>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801be1:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801be7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801bea:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801bec:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801bef:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801bf6:	83 ec 0c             	sub    $0xc,%esp
  801bf9:	50                   	push   %eax
  801bfa:	e8 f9 f1 ff ff       	call   800df8 <fd2num>
  801bff:	83 c4 10             	add    $0x10,%esp
}
  801c02:	c9                   	leave  
  801c03:	c3                   	ret    

00801c04 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801c04:	55                   	push   %ebp
  801c05:	89 e5                	mov    %esp,%ebp
  801c07:	56                   	push   %esi
  801c08:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801c09:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801c0c:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  801c12:	e8 ea ef ff ff       	call   800c01 <sys_getenvid>
  801c17:	83 ec 0c             	sub    $0xc,%esp
  801c1a:	ff 75 0c             	pushl  0xc(%ebp)
  801c1d:	ff 75 08             	pushl  0x8(%ebp)
  801c20:	53                   	push   %ebx
  801c21:	50                   	push   %eax
  801c22:	68 3c 25 80 00       	push   $0x80253c
  801c27:	e8 e8 e5 ff ff       	call   800214 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801c2c:	83 c4 18             	add    $0x18,%esp
  801c2f:	56                   	push   %esi
  801c30:	ff 75 10             	pushl  0x10(%ebp)
  801c33:	e8 8b e5 ff ff       	call   8001c3 <vcprintf>
	cprintf("\n");
  801c38:	c7 04 24 88 20 80 00 	movl   $0x802088,(%esp)
  801c3f:	e8 d0 e5 ff ff       	call   800214 <cprintf>
  801c44:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801c47:	cc                   	int3   
  801c48:	eb fd                	jmp    801c47 <_panic+0x43>
	...

00801c4c <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801c4c:	55                   	push   %ebp
  801c4d:	89 e5                	mov    %esp,%ebp
  801c4f:	56                   	push   %esi
  801c50:	53                   	push   %ebx
  801c51:	8b 75 08             	mov    0x8(%ebp),%esi
  801c54:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c57:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// cprintf("0x%x 0x%x 0x%x\n", (uint32_t)from_env_store, (uint32_t)pg, (uint32_t)perm_store);
	int r;
	if (pg != NULL) {
  801c5a:	85 c0                	test   %eax,%eax
  801c5c:	74 0e                	je     801c6c <ipc_recv+0x20>
		r = sys_ipc_recv(pg);
  801c5e:	83 ec 0c             	sub    $0xc,%esp
  801c61:	50                   	push   %eax
  801c62:	e8 e0 f0 ff ff       	call   800d47 <sys_ipc_recv>
  801c67:	83 c4 10             	add    $0x10,%esp
  801c6a:	eb 10                	jmp    801c7c <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv((void *)UTOP);
  801c6c:	83 ec 0c             	sub    $0xc,%esp
  801c6f:	68 00 00 c0 ee       	push   $0xeec00000
  801c74:	e8 ce f0 ff ff       	call   800d47 <sys_ipc_recv>
  801c79:	83 c4 10             	add    $0x10,%esp
	}

	if (r == 0) {
  801c7c:	85 c0                	test   %eax,%eax
  801c7e:	75 26                	jne    801ca6 <ipc_recv+0x5a>
		if (from_env_store != NULL) *from_env_store = thisenv->env_ipc_from;
  801c80:	85 f6                	test   %esi,%esi
  801c82:	74 0a                	je     801c8e <ipc_recv+0x42>
  801c84:	a1 10 40 80 00       	mov    0x804010,%eax
  801c89:	8b 40 74             	mov    0x74(%eax),%eax
  801c8c:	89 06                	mov    %eax,(%esi)
		if (perm_store != NULL) *perm_store = thisenv->env_ipc_perm;
  801c8e:	85 db                	test   %ebx,%ebx
  801c90:	74 0a                	je     801c9c <ipc_recv+0x50>
  801c92:	a1 10 40 80 00       	mov    0x804010,%eax
  801c97:	8b 40 78             	mov    0x78(%eax),%eax
  801c9a:	89 03                	mov    %eax,(%ebx)
		return thisenv->env_ipc_value;
  801c9c:	a1 10 40 80 00       	mov    0x804010,%eax
  801ca1:	8b 40 70             	mov    0x70(%eax),%eax
  801ca4:	eb 14                	jmp    801cba <ipc_recv+0x6e>
	} else {
		// fails;
		if (from_env_store != NULL) *from_env_store = 0;
  801ca6:	85 f6                	test   %esi,%esi
  801ca8:	74 06                	je     801cb0 <ipc_recv+0x64>
  801caa:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if (perm_store != NULL) *perm_store = 0;
  801cb0:	85 db                	test   %ebx,%ebx
  801cb2:	74 06                	je     801cba <ipc_recv+0x6e>
  801cb4:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		return r;
	}
}
  801cba:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801cbd:	5b                   	pop    %ebx
  801cbe:	5e                   	pop    %esi
  801cbf:	c9                   	leave  
  801cc0:	c3                   	ret    

00801cc1 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801cc1:	55                   	push   %ebp
  801cc2:	89 e5                	mov    %esp,%ebp
  801cc4:	57                   	push   %edi
  801cc5:	56                   	push   %esi
  801cc6:	53                   	push   %ebx
  801cc7:	83 ec 0c             	sub    $0xc,%esp
  801cca:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801ccd:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801cd0:	8b 75 14             	mov    0x14(%ebp),%esi
	// LAB 4: Your code here.
	// int sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
	int r;
	if (pg == NULL) pg = (void *)UTOP;
  801cd3:	85 db                	test   %ebx,%ebx
  801cd5:	75 25                	jne    801cfc <ipc_send+0x3b>
  801cd7:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
  801cdc:	eb 1e                	jmp    801cfc <ipc_send+0x3b>
	
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) != 0) {
		if (r == -E_IPC_NOT_RECV) {
  801cde:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801ce1:	75 07                	jne    801cea <ipc_send+0x29>
			// cprintf("Try Again and Again....\n");
			sys_yield();
  801ce3:	e8 3d ef ff ff       	call   800c25 <sys_yield>
  801ce8:	eb 12                	jmp    801cfc <ipc_send+0x3b>
		} else {
			panic("ipc_send error %e\n", r);
  801cea:	50                   	push   %eax
  801ceb:	68 60 25 80 00       	push   $0x802560
  801cf0:	6a 43                	push   $0x43
  801cf2:	68 73 25 80 00       	push   $0x802573
  801cf7:	e8 08 ff ff ff       	call   801c04 <_panic>
	// LAB 4: Your code here.
	// int sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
	int r;
	if (pg == NULL) pg = (void *)UTOP;
	
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) != 0) {
  801cfc:	56                   	push   %esi
  801cfd:	53                   	push   %ebx
  801cfe:	57                   	push   %edi
  801cff:	ff 75 08             	pushl  0x8(%ebp)
  801d02:	e8 1b f0 ff ff       	call   800d22 <sys_ipc_try_send>
  801d07:	83 c4 10             	add    $0x10,%esp
  801d0a:	85 c0                	test   %eax,%eax
  801d0c:	75 d0                	jne    801cde <ipc_send+0x1d>
		} else {
			panic("ipc_send error %e\n", r);
		}
	}
	return;
}
  801d0e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d11:	5b                   	pop    %ebx
  801d12:	5e                   	pop    %esi
  801d13:	5f                   	pop    %edi
  801d14:	c9                   	leave  
  801d15:	c3                   	ret    

00801d16 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801d16:	55                   	push   %ebp
  801d17:	89 e5                	mov    %esp,%ebp
  801d19:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  801d1c:	39 0d 50 00 c0 ee    	cmp    %ecx,0xeec00050
  801d22:	74 1a                	je     801d3e <ipc_find_env+0x28>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801d24:	b8 01 00 00 00       	mov    $0x1,%eax
		if (envs[i].env_type == type)
  801d29:	89 c2                	mov    %eax,%edx
  801d2b:	c1 e2 07             	shl    $0x7,%edx
  801d2e:	8d 94 82 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,4),%edx
  801d35:	8b 52 50             	mov    0x50(%edx),%edx
  801d38:	39 ca                	cmp    %ecx,%edx
  801d3a:	75 18                	jne    801d54 <ipc_find_env+0x3e>
  801d3c:	eb 05                	jmp    801d43 <ipc_find_env+0x2d>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801d3e:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
			return envs[i].env_id;
  801d43:	89 c2                	mov    %eax,%edx
  801d45:	c1 e2 07             	shl    $0x7,%edx
  801d48:	8d 84 82 08 00 c0 ee 	lea    -0x113ffff8(%edx,%eax,4),%eax
  801d4f:	8b 40 40             	mov    0x40(%eax),%eax
  801d52:	eb 0c                	jmp    801d60 <ipc_find_env+0x4a>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801d54:	40                   	inc    %eax
  801d55:	3d 00 04 00 00       	cmp    $0x400,%eax
  801d5a:	75 cd                	jne    801d29 <ipc_find_env+0x13>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801d5c:	66 b8 00 00          	mov    $0x0,%ax
}
  801d60:	c9                   	leave  
  801d61:	c3                   	ret    
	...

00801d64 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801d64:	55                   	push   %ebp
  801d65:	89 e5                	mov    %esp,%ebp
  801d67:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801d6a:	89 c2                	mov    %eax,%edx
  801d6c:	c1 ea 16             	shr    $0x16,%edx
  801d6f:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801d76:	f6 c2 01             	test   $0x1,%dl
  801d79:	74 1e                	je     801d99 <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  801d7b:	c1 e8 0c             	shr    $0xc,%eax
  801d7e:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801d85:	a8 01                	test   $0x1,%al
  801d87:	74 17                	je     801da0 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801d89:	c1 e8 0c             	shr    $0xc,%eax
  801d8c:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  801d93:	ef 
  801d94:	0f b7 c0             	movzwl %ax,%eax
  801d97:	eb 0c                	jmp    801da5 <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  801d99:	b8 00 00 00 00       	mov    $0x0,%eax
  801d9e:	eb 05                	jmp    801da5 <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  801da0:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  801da5:	c9                   	leave  
  801da6:	c3                   	ret    
	...

00801da8 <malloc>:

#define null ((char *)(0))

char *
malloc(uint32_t size)
{
  801da8:	55                   	push   %ebp
  801da9:	89 e5                	mov    %esp,%ebp
  801dab:	57                   	push   %edi
  801dac:	56                   	push   %esi
  801dad:	53                   	push   %ebx
  801dae:	83 ec 0c             	sub    $0xc,%esp
  801db1:	8b 75 08             	mov    0x8(%ebp),%esi
	cur = ROUNDUP(cur, PGSIZE);
  801db4:	8b 3d 58 30 80 00    	mov    0x803058,%edi
  801dba:	81 c7 ff 0f 00 00    	add    $0xfff,%edi
  801dc0:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
  801dc6:	89 3d 58 30 80 00    	mov    %edi,0x803058

	char * ret = cur;
	int r;
	uint32_t t;
	for (t = 0; t < size; t += PGSIZE) {
  801dcc:	85 f6                	test   %esi,%esi
  801dce:	74 3f                	je     801e0f <malloc+0x67>
  801dd0:	bb 00 00 00 00       	mov    $0x0,%ebx
		r = sys_page_alloc(0, cur, PTE_W | PTE_U | PTE_P);
  801dd5:	83 ec 04             	sub    $0x4,%esp
  801dd8:	6a 07                	push   $0x7
  801dda:	ff 35 58 30 80 00    	pushl  0x803058
  801de0:	6a 00                	push   $0x0
  801de2:	e8 65 ee ff ff       	call   800c4c <sys_page_alloc>
		if (r < 0) {
  801de7:	83 c4 10             	add    $0x10,%esp
  801dea:	85 c0                	test   %eax,%eax
  801dec:	79 0d                	jns    801dfb <malloc+0x53>
			cur -= t;
  801dee:	29 1d 58 30 80 00    	sub    %ebx,0x803058
			return null;
  801df4:	bf 00 00 00 00       	mov    $0x0,%edi
  801df9:	eb 14                	jmp    801e0f <malloc+0x67>
		}
		cur += PGSIZE;
  801dfb:	81 05 58 30 80 00 00 	addl   $0x1000,0x803058
  801e02:	10 00 00 
	cur = ROUNDUP(cur, PGSIZE);

	char * ret = cur;
	int r;
	uint32_t t;
	for (t = 0; t < size; t += PGSIZE) {
  801e05:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801e0b:	39 de                	cmp    %ebx,%esi
  801e0d:	77 c6                	ja     801dd5 <malloc+0x2d>
			return null;
		}
		cur += PGSIZE;
	}
	return ret;
  801e0f:	89 f8                	mov    %edi,%eax
  801e11:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e14:	5b                   	pop    %ebx
  801e15:	5e                   	pop    %esi
  801e16:	5f                   	pop    %edi
  801e17:	c9                   	leave  
  801e18:	c3                   	ret    
  801e19:	00 00                	add    %al,(%eax)
	...

00801e1c <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  801e1c:	55                   	push   %ebp
  801e1d:	89 e5                	mov    %esp,%ebp
  801e1f:	57                   	push   %edi
  801e20:	56                   	push   %esi
  801e21:	83 ec 10             	sub    $0x10,%esp
  801e24:	8b 7d 08             	mov    0x8(%ebp),%edi
  801e27:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  801e2a:	89 7d f0             	mov    %edi,-0x10(%ebp)
  801e2d:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  801e30:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  801e33:	8b 45 14             	mov    0x14(%ebp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  801e36:	85 c0                	test   %eax,%eax
  801e38:	75 2e                	jne    801e68 <__udivdi3+0x4c>
    {
      if (d0 > n1)
  801e3a:	39 f1                	cmp    %esi,%ecx
  801e3c:	77 5a                	ja     801e98 <__udivdi3+0x7c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  801e3e:	85 c9                	test   %ecx,%ecx
  801e40:	75 0b                	jne    801e4d <__udivdi3+0x31>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  801e42:	b8 01 00 00 00       	mov    $0x1,%eax
  801e47:	31 d2                	xor    %edx,%edx
  801e49:	f7 f1                	div    %ecx
  801e4b:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  801e4d:	31 d2                	xor    %edx,%edx
  801e4f:	89 f0                	mov    %esi,%eax
  801e51:	f7 f1                	div    %ecx
  801e53:	89 c6                	mov    %eax,%esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801e55:	89 f8                	mov    %edi,%eax
  801e57:	f7 f1                	div    %ecx
  801e59:	89 c7                	mov    %eax,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801e5b:	89 f8                	mov    %edi,%eax
  801e5d:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801e5f:	83 c4 10             	add    $0x10,%esp
  801e62:	5e                   	pop    %esi
  801e63:	5f                   	pop    %edi
  801e64:	c9                   	leave  
  801e65:	c3                   	ret    
  801e66:	66 90                	xchg   %ax,%ax
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801e68:	39 f0                	cmp    %esi,%eax
  801e6a:	77 1c                	ja     801e88 <__udivdi3+0x6c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  801e6c:	0f bd f8             	bsr    %eax,%edi
	  if (bm == 0)
  801e6f:	83 f7 1f             	xor    $0x1f,%edi
  801e72:	75 3c                	jne    801eb0 <__udivdi3+0x94>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801e74:	39 f0                	cmp    %esi,%eax
  801e76:	0f 82 90 00 00 00    	jb     801f0c <__udivdi3+0xf0>
  801e7c:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801e7f:	39 55 f4             	cmp    %edx,-0xc(%ebp)
  801e82:	0f 86 84 00 00 00    	jbe    801f0c <__udivdi3+0xf0>
  801e88:	31 f6                	xor    %esi,%esi
  801e8a:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801e8c:	89 f8                	mov    %edi,%eax
  801e8e:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801e90:	83 c4 10             	add    $0x10,%esp
  801e93:	5e                   	pop    %esi
  801e94:	5f                   	pop    %edi
  801e95:	c9                   	leave  
  801e96:	c3                   	ret    
  801e97:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801e98:	89 f2                	mov    %esi,%edx
  801e9a:	89 f8                	mov    %edi,%eax
  801e9c:	f7 f1                	div    %ecx
  801e9e:	89 c7                	mov    %eax,%edi
  801ea0:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801ea2:	89 f8                	mov    %edi,%eax
  801ea4:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801ea6:	83 c4 10             	add    $0x10,%esp
  801ea9:	5e                   	pop    %esi
  801eaa:	5f                   	pop    %edi
  801eab:	c9                   	leave  
  801eac:	c3                   	ret    
  801ead:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  801eb0:	89 f9                	mov    %edi,%ecx
  801eb2:	d3 e0                	shl    %cl,%eax
  801eb4:	89 45 e8             	mov    %eax,-0x18(%ebp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  801eb7:	b8 20 00 00 00       	mov    $0x20,%eax
  801ebc:	29 f8                	sub    %edi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  801ebe:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801ec1:	88 c1                	mov    %al,%cl
  801ec3:	d3 ea                	shr    %cl,%edx
  801ec5:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  801ec8:	09 ca                	or     %ecx,%edx
  801eca:	89 55 ec             	mov    %edx,-0x14(%ebp)
	      d0 = d0 << bm;
  801ecd:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801ed0:	89 f9                	mov    %edi,%ecx
  801ed2:	d3 e2                	shl    %cl,%edx
  801ed4:	89 55 f4             	mov    %edx,-0xc(%ebp)
	      n2 = n1 >> b;
  801ed7:	89 f2                	mov    %esi,%edx
  801ed9:	88 c1                	mov    %al,%cl
  801edb:	d3 ea                	shr    %cl,%edx
  801edd:	89 55 e8             	mov    %edx,-0x18(%ebp)
	      n1 = (n1 << bm) | (n0 >> b);
  801ee0:	89 f2                	mov    %esi,%edx
  801ee2:	89 f9                	mov    %edi,%ecx
  801ee4:	d3 e2                	shl    %cl,%edx
  801ee6:	8b 75 f0             	mov    -0x10(%ebp),%esi
  801ee9:	88 c1                	mov    %al,%cl
  801eeb:	d3 ee                	shr    %cl,%esi
  801eed:	09 d6                	or     %edx,%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  801eef:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  801ef2:	89 f0                	mov    %esi,%eax
  801ef4:	89 ca                	mov    %ecx,%edx
  801ef6:	f7 75 ec             	divl   -0x14(%ebp)
  801ef9:	89 d1                	mov    %edx,%ecx
  801efb:	89 c6                	mov    %eax,%esi
	      umul_ppmm (m1, m0, q0, d0);
  801efd:	f7 65 f4             	mull   -0xc(%ebp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801f00:	39 d1                	cmp    %edx,%ecx
  801f02:	72 28                	jb     801f2c <__udivdi3+0x110>
  801f04:	74 1a                	je     801f20 <__udivdi3+0x104>
  801f06:	89 f7                	mov    %esi,%edi
  801f08:	31 f6                	xor    %esi,%esi
  801f0a:	eb 80                	jmp    801e8c <__udivdi3+0x70>
	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  801f0c:	31 f6                	xor    %esi,%esi
  801f0e:	bf 01 00 00 00       	mov    $0x1,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801f13:	89 f8                	mov    %edi,%eax
  801f15:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801f17:	83 c4 10             	add    $0x10,%esp
  801f1a:	5e                   	pop    %esi
  801f1b:	5f                   	pop    %edi
  801f1c:	c9                   	leave  
  801f1d:	c3                   	ret    
  801f1e:	66 90                	xchg   %ax,%ax

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  801f20:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801f23:	89 f9                	mov    %edi,%ecx
  801f25:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801f27:	39 c2                	cmp    %eax,%edx
  801f29:	73 db                	jae    801f06 <__udivdi3+0xea>
  801f2b:	90                   	nop
		{
		  q0--;
  801f2c:	8d 7e ff             	lea    -0x1(%esi),%edi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  801f2f:	31 f6                	xor    %esi,%esi
  801f31:	e9 56 ff ff ff       	jmp    801e8c <__udivdi3+0x70>
	...

00801f38 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  801f38:	55                   	push   %ebp
  801f39:	89 e5                	mov    %esp,%ebp
  801f3b:	57                   	push   %edi
  801f3c:	56                   	push   %esi
  801f3d:	83 ec 20             	sub    $0x20,%esp
  801f40:	8b 45 08             	mov    0x8(%ebp),%eax
  801f43:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  801f46:	89 45 e8             	mov    %eax,-0x18(%ebp)
  801f49:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  801f4c:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  801f4f:	8b 7d 14             	mov    0x14(%ebp),%edi
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  801f52:	89 45 f0             	mov    %eax,-0x10(%ebp)
  n1 = nn.s.high;
  801f55:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  801f57:	85 ff                	test   %edi,%edi
  801f59:	75 15                	jne    801f70 <__umoddi3+0x38>
    {
      if (d0 > n1)
  801f5b:	39 f1                	cmp    %esi,%ecx
  801f5d:	0f 86 99 00 00 00    	jbe    801ffc <__umoddi3+0xc4>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801f63:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  801f65:	89 d0                	mov    %edx,%eax
  801f67:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801f69:	83 c4 20             	add    $0x20,%esp
  801f6c:	5e                   	pop    %esi
  801f6d:	5f                   	pop    %edi
  801f6e:	c9                   	leave  
  801f6f:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801f70:	39 f7                	cmp    %esi,%edi
  801f72:	0f 87 a4 00 00 00    	ja     80201c <__umoddi3+0xe4>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  801f78:	0f bd c7             	bsr    %edi,%eax
	  if (bm == 0)
  801f7b:	83 f0 1f             	xor    $0x1f,%eax
  801f7e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801f81:	0f 84 a1 00 00 00    	je     802028 <__umoddi3+0xf0>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  801f87:	89 f8                	mov    %edi,%eax
  801f89:	8a 4d ec             	mov    -0x14(%ebp),%cl
  801f8c:	d3 e0                	shl    %cl,%eax
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  801f8e:	bf 20 00 00 00       	mov    $0x20,%edi
  801f93:	2b 7d ec             	sub    -0x14(%ebp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  801f96:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801f99:	89 f9                	mov    %edi,%ecx
  801f9b:	d3 ea                	shr    %cl,%edx
  801f9d:	09 c2                	or     %eax,%edx
  801f9f:	89 55 f0             	mov    %edx,-0x10(%ebp)
	      d0 = d0 << bm;
  801fa2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fa5:	8a 4d ec             	mov    -0x14(%ebp),%cl
  801fa8:	d3 e0                	shl    %cl,%eax
  801faa:	89 45 f4             	mov    %eax,-0xc(%ebp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  801fad:	89 f2                	mov    %esi,%edx
  801faf:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  801fb1:	8b 45 e8             	mov    -0x18(%ebp),%eax
  801fb4:	d3 e0                	shl    %cl,%eax
  801fb6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  801fb9:	8b 45 e8             	mov    -0x18(%ebp),%eax
  801fbc:	89 f9                	mov    %edi,%ecx
  801fbe:	d3 e8                	shr    %cl,%eax
  801fc0:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  801fc2:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  801fc4:	89 f2                	mov    %esi,%edx
  801fc6:	f7 75 f0             	divl   -0x10(%ebp)
  801fc9:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  801fcb:	f7 65 f4             	mull   -0xc(%ebp)
  801fce:	89 55 e8             	mov    %edx,-0x18(%ebp)
  801fd1:	89 c1                	mov    %eax,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801fd3:	39 d6                	cmp    %edx,%esi
  801fd5:	72 71                	jb     802048 <__umoddi3+0x110>
  801fd7:	74 7f                	je     802058 <__umoddi3+0x120>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  801fd9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801fdc:	29 c8                	sub    %ecx,%eax
  801fde:	19 d6                	sbb    %edx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  801fe0:	8a 4d ec             	mov    -0x14(%ebp),%cl
  801fe3:	d3 e8                	shr    %cl,%eax
  801fe5:	89 f2                	mov    %esi,%edx
  801fe7:	89 f9                	mov    %edi,%ecx
  801fe9:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  801feb:	09 d0                	or     %edx,%eax
  801fed:	89 f2                	mov    %esi,%edx
  801fef:	8a 4d ec             	mov    -0x14(%ebp),%cl
  801ff2:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801ff4:	83 c4 20             	add    $0x20,%esp
  801ff7:	5e                   	pop    %esi
  801ff8:	5f                   	pop    %edi
  801ff9:	c9                   	leave  
  801ffa:	c3                   	ret    
  801ffb:	90                   	nop
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  801ffc:	85 c9                	test   %ecx,%ecx
  801ffe:	75 0b                	jne    80200b <__umoddi3+0xd3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  802000:	b8 01 00 00 00       	mov    $0x1,%eax
  802005:	31 d2                	xor    %edx,%edx
  802007:	f7 f1                	div    %ecx
  802009:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  80200b:	89 f0                	mov    %esi,%eax
  80200d:	31 d2                	xor    %edx,%edx
  80200f:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802011:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802014:	f7 f1                	div    %ecx
  802016:	e9 4a ff ff ff       	jmp    801f65 <__umoddi3+0x2d>
  80201b:	90                   	nop
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  80201c:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  80201e:	83 c4 20             	add    $0x20,%esp
  802021:	5e                   	pop    %esi
  802022:	5f                   	pop    %edi
  802023:	c9                   	leave  
  802024:	c3                   	ret    
  802025:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802028:	39 f7                	cmp    %esi,%edi
  80202a:	72 05                	jb     802031 <__umoddi3+0xf9>
  80202c:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
  80202f:	77 0c                	ja     80203d <__umoddi3+0x105>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  802031:	89 f2                	mov    %esi,%edx
  802033:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802036:	29 c8                	sub    %ecx,%eax
  802038:	19 fa                	sbb    %edi,%edx
  80203a:	89 45 f0             	mov    %eax,-0x10(%ebp)

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  80203d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802040:	83 c4 20             	add    $0x20,%esp
  802043:	5e                   	pop    %esi
  802044:	5f                   	pop    %edi
  802045:	c9                   	leave  
  802046:	c3                   	ret    
  802047:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  802048:	8b 55 e8             	mov    -0x18(%ebp),%edx
  80204b:	89 c1                	mov    %eax,%ecx
  80204d:	2b 4d f4             	sub    -0xc(%ebp),%ecx
  802050:	1b 55 f0             	sbb    -0x10(%ebp),%edx
  802053:	eb 84                	jmp    801fd9 <__umoddi3+0xa1>
  802055:	8d 76 00             	lea    0x0(%esi),%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802058:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  80205b:	72 eb                	jb     802048 <__umoddi3+0x110>
  80205d:	89 f2                	mov    %esi,%edx
  80205f:	e9 75 ff ff ff       	jmp    801fd9 <__umoddi3+0xa1>
