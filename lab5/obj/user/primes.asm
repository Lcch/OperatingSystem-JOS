
obj/user/primes.debug:     file format elf32-i386


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
  80002c:	e8 c7 00 00 00       	call   8000f8 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <primeproc>:

#include <inc/lib.h>

unsigned
primeproc(void)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	57                   	push   %edi
  800038:	56                   	push   %esi
  800039:	53                   	push   %ebx
  80003a:	83 ec 1c             	sub    $0x1c,%esp
	int i, id, p;
	envid_t envid;

	// fetch a prime from our left neighbor
top:
	p = ipc_recv(&envid, 0, 0);
  80003d:	8d 75 e4             	lea    -0x1c(%ebp),%esi
  800040:	83 ec 04             	sub    $0x4,%esp
  800043:	6a 00                	push   $0x0
  800045:	6a 00                	push   $0x0
  800047:	56                   	push   %esi
  800048:	e8 ab 10 00 00       	call   8010f8 <ipc_recv>
  80004d:	89 c3                	mov    %eax,%ebx
	cprintf("CPU %d: %d ", thisenv->env_cpunum, p);
  80004f:	a1 04 40 80 00       	mov    0x804004,%eax
  800054:	8b 40 5c             	mov    0x5c(%eax),%eax
  800057:	83 c4 0c             	add    $0xc,%esp
  80005a:	53                   	push   %ebx
  80005b:	50                   	push   %eax
  80005c:	68 00 22 80 00       	push   $0x802200
  800061:	e8 d6 01 00 00       	call   80023c <cprintf>

	// fork a right neighbor to continue the chain
	if ((id = fork()) < 0)
  800066:	e8 43 0e 00 00       	call   800eae <fork>
  80006b:	89 c7                	mov    %eax,%edi
  80006d:	83 c4 10             	add    $0x10,%esp
  800070:	85 c0                	test   %eax,%eax
  800072:	79 12                	jns    800086 <primeproc+0x52>
		panic("fork: %e", id);
  800074:	50                   	push   %eax
  800075:	68 0c 22 80 00       	push   $0x80220c
  80007a:	6a 1a                	push   $0x1a
  80007c:	68 15 22 80 00       	push   $0x802215
  800081:	e8 de 00 00 00       	call   800164 <_panic>
	if (id == 0)
  800086:	85 c0                	test   %eax,%eax
  800088:	74 b6                	je     800040 <primeproc+0xc>
		goto top;

	// filter out multiples of our prime
	while (1) {
		i = ipc_recv(&envid, 0, 0);
  80008a:	8d 75 e4             	lea    -0x1c(%ebp),%esi
  80008d:	83 ec 04             	sub    $0x4,%esp
  800090:	6a 00                	push   $0x0
  800092:	6a 00                	push   $0x0
  800094:	56                   	push   %esi
  800095:	e8 5e 10 00 00       	call   8010f8 <ipc_recv>
  80009a:	89 c1                	mov    %eax,%ecx
		if (i % p)
  80009c:	99                   	cltd   
  80009d:	f7 fb                	idiv   %ebx
  80009f:	83 c4 10             	add    $0x10,%esp
  8000a2:	85 d2                	test   %edx,%edx
  8000a4:	74 e7                	je     80008d <primeproc+0x59>
			ipc_send(id, i, 0, 0);
  8000a6:	6a 00                	push   $0x0
  8000a8:	6a 00                	push   $0x0
  8000aa:	51                   	push   %ecx
  8000ab:	57                   	push   %edi
  8000ac:	e8 bc 10 00 00       	call   80116d <ipc_send>
  8000b1:	83 c4 10             	add    $0x10,%esp
  8000b4:	eb d7                	jmp    80008d <primeproc+0x59>

008000b6 <umain>:
	}
}

void
umain(int argc, char **argv)
{
  8000b6:	55                   	push   %ebp
  8000b7:	89 e5                	mov    %esp,%ebp
  8000b9:	56                   	push   %esi
  8000ba:	53                   	push   %ebx
	int i, id;

	// fork the first prime process in the chain
	if ((id = fork()) < 0)
  8000bb:	e8 ee 0d 00 00       	call   800eae <fork>
  8000c0:	89 c3                	mov    %eax,%ebx
  8000c2:	85 c0                	test   %eax,%eax
  8000c4:	79 12                	jns    8000d8 <umain+0x22>
		panic("fork: %e", id);
  8000c6:	50                   	push   %eax
  8000c7:	68 0c 22 80 00       	push   $0x80220c
  8000cc:	6a 2d                	push   $0x2d
  8000ce:	68 15 22 80 00       	push   $0x802215
  8000d3:	e8 8c 00 00 00       	call   800164 <_panic>
	if (id == 0)
  8000d8:	85 c0                	test   %eax,%eax
  8000da:	75 05                	jne    8000e1 <umain+0x2b>
		primeproc();
  8000dc:	e8 53 ff ff ff       	call   800034 <primeproc>
	}
}

void
umain(int argc, char **argv)
{
  8000e1:	be 02 00 00 00       	mov    $0x2,%esi
	if (id == 0)
		primeproc();

	// feed all the integers through
	for (i = 2; ; i++)
		ipc_send(id, i, 0, 0);
  8000e6:	6a 00                	push   $0x0
  8000e8:	6a 00                	push   $0x0
  8000ea:	56                   	push   %esi
  8000eb:	53                   	push   %ebx
  8000ec:	e8 7c 10 00 00       	call   80116d <ipc_send>
		panic("fork: %e", id);
	if (id == 0)
		primeproc();

	// feed all the integers through
	for (i = 2; ; i++)
  8000f1:	46                   	inc    %esi
  8000f2:	83 c4 10             	add    $0x10,%esp
  8000f5:	eb ef                	jmp    8000e6 <umain+0x30>
	...

008000f8 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000f8:	55                   	push   %ebp
  8000f9:	89 e5                	mov    %esp,%ebp
  8000fb:	56                   	push   %esi
  8000fc:	53                   	push   %ebx
  8000fd:	8b 75 08             	mov    0x8(%ebp),%esi
  800100:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs + ENVX(sys_getenvid());
  800103:	e8 21 0b 00 00       	call   800c29 <sys_getenvid>
  800108:	25 ff 03 00 00       	and    $0x3ff,%eax
  80010d:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800114:	c1 e0 07             	shl    $0x7,%eax
  800117:	29 d0                	sub    %edx,%eax
  800119:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80011e:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800123:	85 f6                	test   %esi,%esi
  800125:	7e 07                	jle    80012e <libmain+0x36>
		binaryname = argv[0];
  800127:	8b 03                	mov    (%ebx),%eax
  800129:	a3 00 30 80 00       	mov    %eax,0x803000
	// call user main routine
	umain(argc, argv);
  80012e:	83 ec 08             	sub    $0x8,%esp
  800131:	53                   	push   %ebx
  800132:	56                   	push   %esi
  800133:	e8 7e ff ff ff       	call   8000b6 <umain>

	// exit gracefully
	exit();
  800138:	e8 0b 00 00 00       	call   800148 <exit>
  80013d:	83 c4 10             	add    $0x10,%esp
}
  800140:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800143:	5b                   	pop    %ebx
  800144:	5e                   	pop    %esi
  800145:	c9                   	leave  
  800146:	c3                   	ret    
	...

00800148 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800148:	55                   	push   %ebp
  800149:	89 e5                	mov    %esp,%ebp
  80014b:	83 ec 08             	sub    $0x8,%esp
	close_all();
  80014e:	e8 d7 12 00 00       	call   80142a <close_all>
	sys_env_destroy(0);
  800153:	83 ec 0c             	sub    $0xc,%esp
  800156:	6a 00                	push   $0x0
  800158:	e8 aa 0a 00 00       	call   800c07 <sys_env_destroy>
  80015d:	83 c4 10             	add    $0x10,%esp
}
  800160:	c9                   	leave  
  800161:	c3                   	ret    
	...

00800164 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800164:	55                   	push   %ebp
  800165:	89 e5                	mov    %esp,%ebp
  800167:	56                   	push   %esi
  800168:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800169:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80016c:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  800172:	e8 b2 0a 00 00       	call   800c29 <sys_getenvid>
  800177:	83 ec 0c             	sub    $0xc,%esp
  80017a:	ff 75 0c             	pushl  0xc(%ebp)
  80017d:	ff 75 08             	pushl  0x8(%ebp)
  800180:	53                   	push   %ebx
  800181:	50                   	push   %eax
  800182:	68 30 22 80 00       	push   $0x802230
  800187:	e8 b0 00 00 00       	call   80023c <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80018c:	83 c4 18             	add    $0x18,%esp
  80018f:	56                   	push   %esi
  800190:	ff 75 10             	pushl  0x10(%ebp)
  800193:	e8 53 00 00 00       	call   8001eb <vcprintf>
	cprintf("\n");
  800198:	c7 04 24 03 28 80 00 	movl   $0x802803,(%esp)
  80019f:	e8 98 00 00 00       	call   80023c <cprintf>
  8001a4:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8001a7:	cc                   	int3   
  8001a8:	eb fd                	jmp    8001a7 <_panic+0x43>
	...

008001ac <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001ac:	55                   	push   %ebp
  8001ad:	89 e5                	mov    %esp,%ebp
  8001af:	53                   	push   %ebx
  8001b0:	83 ec 04             	sub    $0x4,%esp
  8001b3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001b6:	8b 03                	mov    (%ebx),%eax
  8001b8:	8b 55 08             	mov    0x8(%ebp),%edx
  8001bb:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8001bf:	40                   	inc    %eax
  8001c0:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8001c2:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001c7:	75 1a                	jne    8001e3 <putch+0x37>
		sys_cputs(b->buf, b->idx);
  8001c9:	83 ec 08             	sub    $0x8,%esp
  8001cc:	68 ff 00 00 00       	push   $0xff
  8001d1:	8d 43 08             	lea    0x8(%ebx),%eax
  8001d4:	50                   	push   %eax
  8001d5:	e8 e3 09 00 00       	call   800bbd <sys_cputs>
		b->idx = 0;
  8001da:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001e0:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8001e3:	ff 43 04             	incl   0x4(%ebx)
}
  8001e6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001e9:	c9                   	leave  
  8001ea:	c3                   	ret    

008001eb <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001eb:	55                   	push   %ebp
  8001ec:	89 e5                	mov    %esp,%ebp
  8001ee:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001f4:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001fb:	00 00 00 
	b.cnt = 0;
  8001fe:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800205:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800208:	ff 75 0c             	pushl  0xc(%ebp)
  80020b:	ff 75 08             	pushl  0x8(%ebp)
  80020e:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800214:	50                   	push   %eax
  800215:	68 ac 01 80 00       	push   $0x8001ac
  80021a:	e8 82 01 00 00       	call   8003a1 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80021f:	83 c4 08             	add    $0x8,%esp
  800222:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800228:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80022e:	50                   	push   %eax
  80022f:	e8 89 09 00 00       	call   800bbd <sys_cputs>

	return b.cnt;
}
  800234:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80023a:	c9                   	leave  
  80023b:	c3                   	ret    

0080023c <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80023c:	55                   	push   %ebp
  80023d:	89 e5                	mov    %esp,%ebp
  80023f:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800242:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800245:	50                   	push   %eax
  800246:	ff 75 08             	pushl  0x8(%ebp)
  800249:	e8 9d ff ff ff       	call   8001eb <vcprintf>
	va_end(ap);

	return cnt;
}
  80024e:	c9                   	leave  
  80024f:	c3                   	ret    

00800250 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800250:	55                   	push   %ebp
  800251:	89 e5                	mov    %esp,%ebp
  800253:	57                   	push   %edi
  800254:	56                   	push   %esi
  800255:	53                   	push   %ebx
  800256:	83 ec 2c             	sub    $0x2c,%esp
  800259:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80025c:	89 d6                	mov    %edx,%esi
  80025e:	8b 45 08             	mov    0x8(%ebp),%eax
  800261:	8b 55 0c             	mov    0xc(%ebp),%edx
  800264:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800267:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80026a:	8b 45 10             	mov    0x10(%ebp),%eax
  80026d:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800270:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800273:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800276:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  80027d:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
  800280:	72 0c                	jb     80028e <printnum+0x3e>
  800282:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  800285:	76 07                	jbe    80028e <printnum+0x3e>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800287:	4b                   	dec    %ebx
  800288:	85 db                	test   %ebx,%ebx
  80028a:	7f 31                	jg     8002bd <printnum+0x6d>
  80028c:	eb 3f                	jmp    8002cd <printnum+0x7d>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80028e:	83 ec 0c             	sub    $0xc,%esp
  800291:	57                   	push   %edi
  800292:	4b                   	dec    %ebx
  800293:	53                   	push   %ebx
  800294:	50                   	push   %eax
  800295:	83 ec 08             	sub    $0x8,%esp
  800298:	ff 75 d4             	pushl  -0x2c(%ebp)
  80029b:	ff 75 d0             	pushl  -0x30(%ebp)
  80029e:	ff 75 dc             	pushl  -0x24(%ebp)
  8002a1:	ff 75 d8             	pushl  -0x28(%ebp)
  8002a4:	e8 03 1d 00 00       	call   801fac <__udivdi3>
  8002a9:	83 c4 18             	add    $0x18,%esp
  8002ac:	52                   	push   %edx
  8002ad:	50                   	push   %eax
  8002ae:	89 f2                	mov    %esi,%edx
  8002b0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8002b3:	e8 98 ff ff ff       	call   800250 <printnum>
  8002b8:	83 c4 20             	add    $0x20,%esp
  8002bb:	eb 10                	jmp    8002cd <printnum+0x7d>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002bd:	83 ec 08             	sub    $0x8,%esp
  8002c0:	56                   	push   %esi
  8002c1:	57                   	push   %edi
  8002c2:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002c5:	4b                   	dec    %ebx
  8002c6:	83 c4 10             	add    $0x10,%esp
  8002c9:	85 db                	test   %ebx,%ebx
  8002cb:	7f f0                	jg     8002bd <printnum+0x6d>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002cd:	83 ec 08             	sub    $0x8,%esp
  8002d0:	56                   	push   %esi
  8002d1:	83 ec 04             	sub    $0x4,%esp
  8002d4:	ff 75 d4             	pushl  -0x2c(%ebp)
  8002d7:	ff 75 d0             	pushl  -0x30(%ebp)
  8002da:	ff 75 dc             	pushl  -0x24(%ebp)
  8002dd:	ff 75 d8             	pushl  -0x28(%ebp)
  8002e0:	e8 e3 1d 00 00       	call   8020c8 <__umoddi3>
  8002e5:	83 c4 14             	add    $0x14,%esp
  8002e8:	0f be 80 53 22 80 00 	movsbl 0x802253(%eax),%eax
  8002ef:	50                   	push   %eax
  8002f0:	ff 55 e4             	call   *-0x1c(%ebp)
  8002f3:	83 c4 10             	add    $0x10,%esp
}
  8002f6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002f9:	5b                   	pop    %ebx
  8002fa:	5e                   	pop    %esi
  8002fb:	5f                   	pop    %edi
  8002fc:	c9                   	leave  
  8002fd:	c3                   	ret    

008002fe <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002fe:	55                   	push   %ebp
  8002ff:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800301:	83 fa 01             	cmp    $0x1,%edx
  800304:	7e 0e                	jle    800314 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800306:	8b 10                	mov    (%eax),%edx
  800308:	8d 4a 08             	lea    0x8(%edx),%ecx
  80030b:	89 08                	mov    %ecx,(%eax)
  80030d:	8b 02                	mov    (%edx),%eax
  80030f:	8b 52 04             	mov    0x4(%edx),%edx
  800312:	eb 22                	jmp    800336 <getuint+0x38>
	else if (lflag)
  800314:	85 d2                	test   %edx,%edx
  800316:	74 10                	je     800328 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800318:	8b 10                	mov    (%eax),%edx
  80031a:	8d 4a 04             	lea    0x4(%edx),%ecx
  80031d:	89 08                	mov    %ecx,(%eax)
  80031f:	8b 02                	mov    (%edx),%eax
  800321:	ba 00 00 00 00       	mov    $0x0,%edx
  800326:	eb 0e                	jmp    800336 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800328:	8b 10                	mov    (%eax),%edx
  80032a:	8d 4a 04             	lea    0x4(%edx),%ecx
  80032d:	89 08                	mov    %ecx,(%eax)
  80032f:	8b 02                	mov    (%edx),%eax
  800331:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800336:	c9                   	leave  
  800337:	c3                   	ret    

00800338 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  800338:	55                   	push   %ebp
  800339:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80033b:	83 fa 01             	cmp    $0x1,%edx
  80033e:	7e 0e                	jle    80034e <getint+0x16>
		return va_arg(*ap, long long);
  800340:	8b 10                	mov    (%eax),%edx
  800342:	8d 4a 08             	lea    0x8(%edx),%ecx
  800345:	89 08                	mov    %ecx,(%eax)
  800347:	8b 02                	mov    (%edx),%eax
  800349:	8b 52 04             	mov    0x4(%edx),%edx
  80034c:	eb 1a                	jmp    800368 <getint+0x30>
	else if (lflag)
  80034e:	85 d2                	test   %edx,%edx
  800350:	74 0c                	je     80035e <getint+0x26>
		return va_arg(*ap, long);
  800352:	8b 10                	mov    (%eax),%edx
  800354:	8d 4a 04             	lea    0x4(%edx),%ecx
  800357:	89 08                	mov    %ecx,(%eax)
  800359:	8b 02                	mov    (%edx),%eax
  80035b:	99                   	cltd   
  80035c:	eb 0a                	jmp    800368 <getint+0x30>
	else
		return va_arg(*ap, int);
  80035e:	8b 10                	mov    (%eax),%edx
  800360:	8d 4a 04             	lea    0x4(%edx),%ecx
  800363:	89 08                	mov    %ecx,(%eax)
  800365:	8b 02                	mov    (%edx),%eax
  800367:	99                   	cltd   
}
  800368:	c9                   	leave  
  800369:	c3                   	ret    

0080036a <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80036a:	55                   	push   %ebp
  80036b:	89 e5                	mov    %esp,%ebp
  80036d:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800370:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  800373:	8b 10                	mov    (%eax),%edx
  800375:	3b 50 04             	cmp    0x4(%eax),%edx
  800378:	73 08                	jae    800382 <sprintputch+0x18>
		*b->buf++ = ch;
  80037a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80037d:	88 0a                	mov    %cl,(%edx)
  80037f:	42                   	inc    %edx
  800380:	89 10                	mov    %edx,(%eax)
}
  800382:	c9                   	leave  
  800383:	c3                   	ret    

00800384 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800384:	55                   	push   %ebp
  800385:	89 e5                	mov    %esp,%ebp
  800387:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80038a:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80038d:	50                   	push   %eax
  80038e:	ff 75 10             	pushl  0x10(%ebp)
  800391:	ff 75 0c             	pushl  0xc(%ebp)
  800394:	ff 75 08             	pushl  0x8(%ebp)
  800397:	e8 05 00 00 00       	call   8003a1 <vprintfmt>
	va_end(ap);
  80039c:	83 c4 10             	add    $0x10,%esp
}
  80039f:	c9                   	leave  
  8003a0:	c3                   	ret    

008003a1 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8003a1:	55                   	push   %ebp
  8003a2:	89 e5                	mov    %esp,%ebp
  8003a4:	57                   	push   %edi
  8003a5:	56                   	push   %esi
  8003a6:	53                   	push   %ebx
  8003a7:	83 ec 2c             	sub    $0x2c,%esp
  8003aa:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8003ad:	8b 75 10             	mov    0x10(%ebp),%esi
  8003b0:	eb 13                	jmp    8003c5 <vprintfmt+0x24>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8003b2:	85 c0                	test   %eax,%eax
  8003b4:	0f 84 6d 03 00 00    	je     800727 <vprintfmt+0x386>
				return;
			putch(ch, putdat);
  8003ba:	83 ec 08             	sub    $0x8,%esp
  8003bd:	57                   	push   %edi
  8003be:	50                   	push   %eax
  8003bf:	ff 55 08             	call   *0x8(%ebp)
  8003c2:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8003c5:	0f b6 06             	movzbl (%esi),%eax
  8003c8:	46                   	inc    %esi
  8003c9:	83 f8 25             	cmp    $0x25,%eax
  8003cc:	75 e4                	jne    8003b2 <vprintfmt+0x11>
  8003ce:	c6 45 dc 20          	movb   $0x20,-0x24(%ebp)
  8003d2:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  8003d9:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  8003e0:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  8003e7:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003ec:	eb 28                	jmp    800416 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ee:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  8003f0:	c6 45 dc 2d          	movb   $0x2d,-0x24(%ebp)
  8003f4:	eb 20                	jmp    800416 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003f6:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8003f8:	c6 45 dc 30          	movb   $0x30,-0x24(%ebp)
  8003fc:	eb 18                	jmp    800416 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003fe:	89 de                	mov    %ebx,%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800400:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800407:	eb 0d                	jmp    800416 <vprintfmt+0x75>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800409:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80040c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80040f:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800416:	8a 06                	mov    (%esi),%al
  800418:	0f b6 d0             	movzbl %al,%edx
  80041b:	8d 5e 01             	lea    0x1(%esi),%ebx
  80041e:	83 e8 23             	sub    $0x23,%eax
  800421:	3c 55                	cmp    $0x55,%al
  800423:	0f 87 e0 02 00 00    	ja     800709 <vprintfmt+0x368>
  800429:	0f b6 c0             	movzbl %al,%eax
  80042c:	ff 24 85 a0 23 80 00 	jmp    *0x8023a0(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800433:	83 ea 30             	sub    $0x30,%edx
  800436:	89 55 d4             	mov    %edx,-0x2c(%ebp)
				ch = *fmt;
  800439:	0f be 03             	movsbl (%ebx),%eax
				if (ch < '0' || ch > '9')
  80043c:	8d 50 d0             	lea    -0x30(%eax),%edx
  80043f:	83 fa 09             	cmp    $0x9,%edx
  800442:	77 44                	ja     800488 <vprintfmt+0xe7>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800444:	89 de                	mov    %ebx,%esi
  800446:	8b 55 d4             	mov    -0x2c(%ebp),%edx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800449:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
  80044a:	8d 14 92             	lea    (%edx,%edx,4),%edx
  80044d:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
  800451:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800454:	8d 58 d0             	lea    -0x30(%eax),%ebx
  800457:	83 fb 09             	cmp    $0x9,%ebx
  80045a:	76 ed                	jbe    800449 <vprintfmt+0xa8>
  80045c:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  80045f:	eb 29                	jmp    80048a <vprintfmt+0xe9>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800461:	8b 45 14             	mov    0x14(%ebp),%eax
  800464:	8d 50 04             	lea    0x4(%eax),%edx
  800467:	89 55 14             	mov    %edx,0x14(%ebp)
  80046a:	8b 00                	mov    (%eax),%eax
  80046c:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80046f:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800471:	eb 17                	jmp    80048a <vprintfmt+0xe9>

		case '.':
			if (width < 0)
  800473:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800477:	78 85                	js     8003fe <vprintfmt+0x5d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800479:	89 de                	mov    %ebx,%esi
  80047b:	eb 99                	jmp    800416 <vprintfmt+0x75>
  80047d:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80047f:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  800486:	eb 8e                	jmp    800416 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800488:	89 de                	mov    %ebx,%esi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  80048a:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80048e:	79 86                	jns    800416 <vprintfmt+0x75>
  800490:	e9 74 ff ff ff       	jmp    800409 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800495:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800496:	89 de                	mov    %ebx,%esi
  800498:	e9 79 ff ff ff       	jmp    800416 <vprintfmt+0x75>
  80049d:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8004a0:	8b 45 14             	mov    0x14(%ebp),%eax
  8004a3:	8d 50 04             	lea    0x4(%eax),%edx
  8004a6:	89 55 14             	mov    %edx,0x14(%ebp)
  8004a9:	83 ec 08             	sub    $0x8,%esp
  8004ac:	57                   	push   %edi
  8004ad:	ff 30                	pushl  (%eax)
  8004af:	ff 55 08             	call   *0x8(%ebp)
			break;
  8004b2:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004b5:	8b 75 d8             	mov    -0x28(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8004b8:	e9 08 ff ff ff       	jmp    8003c5 <vprintfmt+0x24>
  8004bd:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  8004c0:	8b 45 14             	mov    0x14(%ebp),%eax
  8004c3:	8d 50 04             	lea    0x4(%eax),%edx
  8004c6:	89 55 14             	mov    %edx,0x14(%ebp)
  8004c9:	8b 00                	mov    (%eax),%eax
  8004cb:	85 c0                	test   %eax,%eax
  8004cd:	79 02                	jns    8004d1 <vprintfmt+0x130>
  8004cf:	f7 d8                	neg    %eax
  8004d1:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004d3:	83 f8 0f             	cmp    $0xf,%eax
  8004d6:	7f 0b                	jg     8004e3 <vprintfmt+0x142>
  8004d8:	8b 04 85 00 25 80 00 	mov    0x802500(,%eax,4),%eax
  8004df:	85 c0                	test   %eax,%eax
  8004e1:	75 1a                	jne    8004fd <vprintfmt+0x15c>
				printfmt(putch, putdat, "error %d", err);
  8004e3:	52                   	push   %edx
  8004e4:	68 6b 22 80 00       	push   $0x80226b
  8004e9:	57                   	push   %edi
  8004ea:	ff 75 08             	pushl  0x8(%ebp)
  8004ed:	e8 92 fe ff ff       	call   800384 <printfmt>
  8004f2:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004f5:	8b 75 d8             	mov    -0x28(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8004f8:	e9 c8 fe ff ff       	jmp    8003c5 <vprintfmt+0x24>
			else
				printfmt(putch, putdat, "%s", p);
  8004fd:	50                   	push   %eax
  8004fe:	68 d1 27 80 00       	push   $0x8027d1
  800503:	57                   	push   %edi
  800504:	ff 75 08             	pushl  0x8(%ebp)
  800507:	e8 78 fe ff ff       	call   800384 <printfmt>
  80050c:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80050f:	8b 75 d8             	mov    -0x28(%ebp),%esi
  800512:	e9 ae fe ff ff       	jmp    8003c5 <vprintfmt+0x24>
  800517:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  80051a:	89 de                	mov    %ebx,%esi
  80051c:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  80051f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800522:	8b 45 14             	mov    0x14(%ebp),%eax
  800525:	8d 50 04             	lea    0x4(%eax),%edx
  800528:	89 55 14             	mov    %edx,0x14(%ebp)
  80052b:	8b 00                	mov    (%eax),%eax
  80052d:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800530:	85 c0                	test   %eax,%eax
  800532:	75 07                	jne    80053b <vprintfmt+0x19a>
				p = "(null)";
  800534:	c7 45 d0 64 22 80 00 	movl   $0x802264,-0x30(%ebp)
			if (width > 0 && padc != '-')
  80053b:	85 db                	test   %ebx,%ebx
  80053d:	7e 42                	jle    800581 <vprintfmt+0x1e0>
  80053f:	80 7d dc 2d          	cmpb   $0x2d,-0x24(%ebp)
  800543:	74 3c                	je     800581 <vprintfmt+0x1e0>
				for (width -= strnlen(p, precision); width > 0; width--)
  800545:	83 ec 08             	sub    $0x8,%esp
  800548:	51                   	push   %ecx
  800549:	ff 75 d0             	pushl  -0x30(%ebp)
  80054c:	e8 6f 02 00 00       	call   8007c0 <strnlen>
  800551:	29 c3                	sub    %eax,%ebx
  800553:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800556:	83 c4 10             	add    $0x10,%esp
  800559:	85 db                	test   %ebx,%ebx
  80055b:	7e 24                	jle    800581 <vprintfmt+0x1e0>
					putch(padc, putdat);
  80055d:	0f be 5d dc          	movsbl -0x24(%ebp),%ebx
  800561:	89 75 dc             	mov    %esi,-0x24(%ebp)
  800564:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  800567:	83 ec 08             	sub    $0x8,%esp
  80056a:	57                   	push   %edi
  80056b:	53                   	push   %ebx
  80056c:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80056f:	4e                   	dec    %esi
  800570:	83 c4 10             	add    $0x10,%esp
  800573:	85 f6                	test   %esi,%esi
  800575:	7f f0                	jg     800567 <vprintfmt+0x1c6>
  800577:	8b 75 dc             	mov    -0x24(%ebp),%esi
  80057a:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800581:	8b 55 d0             	mov    -0x30(%ebp),%edx
  800584:	0f be 02             	movsbl (%edx),%eax
  800587:	85 c0                	test   %eax,%eax
  800589:	75 47                	jne    8005d2 <vprintfmt+0x231>
  80058b:	eb 37                	jmp    8005c4 <vprintfmt+0x223>
				if (altflag && (ch < ' ' || ch > '~'))
  80058d:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800591:	74 16                	je     8005a9 <vprintfmt+0x208>
  800593:	8d 50 e0             	lea    -0x20(%eax),%edx
  800596:	83 fa 5e             	cmp    $0x5e,%edx
  800599:	76 0e                	jbe    8005a9 <vprintfmt+0x208>
					putch('?', putdat);
  80059b:	83 ec 08             	sub    $0x8,%esp
  80059e:	57                   	push   %edi
  80059f:	6a 3f                	push   $0x3f
  8005a1:	ff 55 08             	call   *0x8(%ebp)
  8005a4:	83 c4 10             	add    $0x10,%esp
  8005a7:	eb 0b                	jmp    8005b4 <vprintfmt+0x213>
				else
					putch(ch, putdat);
  8005a9:	83 ec 08             	sub    $0x8,%esp
  8005ac:	57                   	push   %edi
  8005ad:	50                   	push   %eax
  8005ae:	ff 55 08             	call   *0x8(%ebp)
  8005b1:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005b4:	ff 4d e4             	decl   -0x1c(%ebp)
  8005b7:	0f be 03             	movsbl (%ebx),%eax
  8005ba:	85 c0                	test   %eax,%eax
  8005bc:	74 03                	je     8005c1 <vprintfmt+0x220>
  8005be:	43                   	inc    %ebx
  8005bf:	eb 1b                	jmp    8005dc <vprintfmt+0x23b>
  8005c1:	8b 75 dc             	mov    -0x24(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005c4:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8005c8:	7f 1e                	jg     8005e8 <vprintfmt+0x247>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005ca:	8b 75 d8             	mov    -0x28(%ebp),%esi
  8005cd:	e9 f3 fd ff ff       	jmp    8003c5 <vprintfmt+0x24>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005d2:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  8005d5:	43                   	inc    %ebx
  8005d6:	89 75 dc             	mov    %esi,-0x24(%ebp)
  8005d9:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  8005dc:	85 f6                	test   %esi,%esi
  8005de:	78 ad                	js     80058d <vprintfmt+0x1ec>
  8005e0:	4e                   	dec    %esi
  8005e1:	79 aa                	jns    80058d <vprintfmt+0x1ec>
  8005e3:	8b 75 dc             	mov    -0x24(%ebp),%esi
  8005e6:	eb dc                	jmp    8005c4 <vprintfmt+0x223>
  8005e8:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8005eb:	83 ec 08             	sub    $0x8,%esp
  8005ee:	57                   	push   %edi
  8005ef:	6a 20                	push   $0x20
  8005f1:	ff 55 08             	call   *0x8(%ebp)
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005f4:	4b                   	dec    %ebx
  8005f5:	83 c4 10             	add    $0x10,%esp
  8005f8:	85 db                	test   %ebx,%ebx
  8005fa:	7f ef                	jg     8005eb <vprintfmt+0x24a>
  8005fc:	e9 c4 fd ff ff       	jmp    8003c5 <vprintfmt+0x24>
  800601:	89 5d d8             	mov    %ebx,-0x28(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800604:	89 ca                	mov    %ecx,%edx
  800606:	8d 45 14             	lea    0x14(%ebp),%eax
  800609:	e8 2a fd ff ff       	call   800338 <getint>
  80060e:	89 c3                	mov    %eax,%ebx
  800610:	89 d6                	mov    %edx,%esi
			if ((long long) num < 0) {
  800612:	85 d2                	test   %edx,%edx
  800614:	78 0a                	js     800620 <vprintfmt+0x27f>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800616:	b8 0a 00 00 00       	mov    $0xa,%eax
  80061b:	e9 b0 00 00 00       	jmp    8006d0 <vprintfmt+0x32f>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  800620:	83 ec 08             	sub    $0x8,%esp
  800623:	57                   	push   %edi
  800624:	6a 2d                	push   $0x2d
  800626:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800629:	f7 db                	neg    %ebx
  80062b:	83 d6 00             	adc    $0x0,%esi
  80062e:	f7 de                	neg    %esi
  800630:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800633:	b8 0a 00 00 00       	mov    $0xa,%eax
  800638:	e9 93 00 00 00       	jmp    8006d0 <vprintfmt+0x32f>
  80063d:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800640:	89 ca                	mov    %ecx,%edx
  800642:	8d 45 14             	lea    0x14(%ebp),%eax
  800645:	e8 b4 fc ff ff       	call   8002fe <getuint>
  80064a:	89 c3                	mov    %eax,%ebx
  80064c:	89 d6                	mov    %edx,%esi
			base = 10;
  80064e:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  800653:	eb 7b                	jmp    8006d0 <vprintfmt+0x32f>
  800655:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
  800658:	89 ca                	mov    %ecx,%edx
  80065a:	8d 45 14             	lea    0x14(%ebp),%eax
  80065d:	e8 d6 fc ff ff       	call   800338 <getint>
  800662:	89 c3                	mov    %eax,%ebx
  800664:	89 d6                	mov    %edx,%esi
            if ((long long) num < 0) {
  800666:	85 d2                	test   %edx,%edx
  800668:	78 07                	js     800671 <vprintfmt+0x2d0>
                putch('-', putdat);
                num = -(long long) num;
            }
            base = 8;
  80066a:	b8 08 00 00 00       	mov    $0x8,%eax
  80066f:	eb 5f                	jmp    8006d0 <vprintfmt+0x32f>
		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
            if ((long long) num < 0) {
                putch('-', putdat);
  800671:	83 ec 08             	sub    $0x8,%esp
  800674:	57                   	push   %edi
  800675:	6a 2d                	push   $0x2d
  800677:	ff 55 08             	call   *0x8(%ebp)
                num = -(long long) num;
  80067a:	f7 db                	neg    %ebx
  80067c:	83 d6 00             	adc    $0x0,%esi
  80067f:	f7 de                	neg    %esi
  800681:	83 c4 10             	add    $0x10,%esp
            }
            base = 8;
  800684:	b8 08 00 00 00       	mov    $0x8,%eax
  800689:	eb 45                	jmp    8006d0 <vprintfmt+0x32f>
  80068b:	89 5d d8             	mov    %ebx,-0x28(%ebp)
            goto number;

        // pointer
		case 'p':
			putch('0', putdat);
  80068e:	83 ec 08             	sub    $0x8,%esp
  800691:	57                   	push   %edi
  800692:	6a 30                	push   $0x30
  800694:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800697:	83 c4 08             	add    $0x8,%esp
  80069a:	57                   	push   %edi
  80069b:	6a 78                	push   $0x78
  80069d:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8006a0:	8b 45 14             	mov    0x14(%ebp),%eax
  8006a3:	8d 50 04             	lea    0x4(%eax),%edx
  8006a6:	89 55 14             	mov    %edx,0x14(%ebp)

        // pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8006a9:	8b 18                	mov    (%eax),%ebx
  8006ab:	be 00 00 00 00       	mov    $0x0,%esi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8006b0:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8006b3:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8006b8:	eb 16                	jmp    8006d0 <vprintfmt+0x32f>
  8006ba:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8006bd:	89 ca                	mov    %ecx,%edx
  8006bf:	8d 45 14             	lea    0x14(%ebp),%eax
  8006c2:	e8 37 fc ff ff       	call   8002fe <getuint>
  8006c7:	89 c3                	mov    %eax,%ebx
  8006c9:	89 d6                	mov    %edx,%esi
			base = 16;
  8006cb:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006d0:	83 ec 0c             	sub    $0xc,%esp
  8006d3:	0f be 55 dc          	movsbl -0x24(%ebp),%edx
  8006d7:	52                   	push   %edx
  8006d8:	ff 75 e4             	pushl  -0x1c(%ebp)
  8006db:	50                   	push   %eax
  8006dc:	56                   	push   %esi
  8006dd:	53                   	push   %ebx
  8006de:	89 fa                	mov    %edi,%edx
  8006e0:	8b 45 08             	mov    0x8(%ebp),%eax
  8006e3:	e8 68 fb ff ff       	call   800250 <printnum>
			break;
  8006e8:	83 c4 20             	add    $0x20,%esp
  8006eb:	8b 75 d8             	mov    -0x28(%ebp),%esi
  8006ee:	e9 d2 fc ff ff       	jmp    8003c5 <vprintfmt+0x24>
  8006f3:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006f6:	83 ec 08             	sub    $0x8,%esp
  8006f9:	57                   	push   %edi
  8006fa:	52                   	push   %edx
  8006fb:	ff 55 08             	call   *0x8(%ebp)
			break;
  8006fe:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800701:	8b 75 d8             	mov    -0x28(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800704:	e9 bc fc ff ff       	jmp    8003c5 <vprintfmt+0x24>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800709:	83 ec 08             	sub    $0x8,%esp
  80070c:	57                   	push   %edi
  80070d:	6a 25                	push   $0x25
  80070f:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800712:	83 c4 10             	add    $0x10,%esp
  800715:	eb 02                	jmp    800719 <vprintfmt+0x378>
  800717:	89 c6                	mov    %eax,%esi
  800719:	8d 46 ff             	lea    -0x1(%esi),%eax
  80071c:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800720:	75 f5                	jne    800717 <vprintfmt+0x376>
  800722:	e9 9e fc ff ff       	jmp    8003c5 <vprintfmt+0x24>
				/* do nothing */;
			break;
		}
	}
}
  800727:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80072a:	5b                   	pop    %ebx
  80072b:	5e                   	pop    %esi
  80072c:	5f                   	pop    %edi
  80072d:	c9                   	leave  
  80072e:	c3                   	ret    

0080072f <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80072f:	55                   	push   %ebp
  800730:	89 e5                	mov    %esp,%ebp
  800732:	83 ec 18             	sub    $0x18,%esp
  800735:	8b 45 08             	mov    0x8(%ebp),%eax
  800738:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80073b:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80073e:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800742:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800745:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80074c:	85 c0                	test   %eax,%eax
  80074e:	74 26                	je     800776 <vsnprintf+0x47>
  800750:	85 d2                	test   %edx,%edx
  800752:	7e 29                	jle    80077d <vsnprintf+0x4e>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800754:	ff 75 14             	pushl  0x14(%ebp)
  800757:	ff 75 10             	pushl  0x10(%ebp)
  80075a:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80075d:	50                   	push   %eax
  80075e:	68 6a 03 80 00       	push   $0x80036a
  800763:	e8 39 fc ff ff       	call   8003a1 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800768:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80076b:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80076e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800771:	83 c4 10             	add    $0x10,%esp
  800774:	eb 0c                	jmp    800782 <vsnprintf+0x53>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800776:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80077b:	eb 05                	jmp    800782 <vsnprintf+0x53>
  80077d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800782:	c9                   	leave  
  800783:	c3                   	ret    

00800784 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800784:	55                   	push   %ebp
  800785:	89 e5                	mov    %esp,%ebp
  800787:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80078a:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80078d:	50                   	push   %eax
  80078e:	ff 75 10             	pushl  0x10(%ebp)
  800791:	ff 75 0c             	pushl  0xc(%ebp)
  800794:	ff 75 08             	pushl  0x8(%ebp)
  800797:	e8 93 ff ff ff       	call   80072f <vsnprintf>
	va_end(ap);

	return rc;
}
  80079c:	c9                   	leave  
  80079d:	c3                   	ret    
	...

008007a0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007a0:	55                   	push   %ebp
  8007a1:	89 e5                	mov    %esp,%ebp
  8007a3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007a6:	80 3a 00             	cmpb   $0x0,(%edx)
  8007a9:	74 0e                	je     8007b9 <strlen+0x19>
  8007ab:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  8007b0:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8007b1:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007b5:	75 f9                	jne    8007b0 <strlen+0x10>
  8007b7:	eb 05                	jmp    8007be <strlen+0x1e>
  8007b9:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  8007be:	c9                   	leave  
  8007bf:	c3                   	ret    

008007c0 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007c0:	55                   	push   %ebp
  8007c1:	89 e5                	mov    %esp,%ebp
  8007c3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007c6:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007c9:	85 d2                	test   %edx,%edx
  8007cb:	74 17                	je     8007e4 <strnlen+0x24>
  8007cd:	80 39 00             	cmpb   $0x0,(%ecx)
  8007d0:	74 19                	je     8007eb <strnlen+0x2b>
  8007d2:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  8007d7:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007d8:	39 d0                	cmp    %edx,%eax
  8007da:	74 14                	je     8007f0 <strnlen+0x30>
  8007dc:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8007e0:	75 f5                	jne    8007d7 <strnlen+0x17>
  8007e2:	eb 0c                	jmp    8007f0 <strnlen+0x30>
  8007e4:	b8 00 00 00 00       	mov    $0x0,%eax
  8007e9:	eb 05                	jmp    8007f0 <strnlen+0x30>
  8007eb:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  8007f0:	c9                   	leave  
  8007f1:	c3                   	ret    

008007f2 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007f2:	55                   	push   %ebp
  8007f3:	89 e5                	mov    %esp,%ebp
  8007f5:	53                   	push   %ebx
  8007f6:	8b 45 08             	mov    0x8(%ebp),%eax
  8007f9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007fc:	ba 00 00 00 00       	mov    $0x0,%edx
  800801:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  800804:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800807:	42                   	inc    %edx
  800808:	84 c9                	test   %cl,%cl
  80080a:	75 f5                	jne    800801 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  80080c:	5b                   	pop    %ebx
  80080d:	c9                   	leave  
  80080e:	c3                   	ret    

0080080f <strcat>:

char *
strcat(char *dst, const char *src)
{
  80080f:	55                   	push   %ebp
  800810:	89 e5                	mov    %esp,%ebp
  800812:	53                   	push   %ebx
  800813:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800816:	53                   	push   %ebx
  800817:	e8 84 ff ff ff       	call   8007a0 <strlen>
  80081c:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  80081f:	ff 75 0c             	pushl  0xc(%ebp)
  800822:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  800825:	50                   	push   %eax
  800826:	e8 c7 ff ff ff       	call   8007f2 <strcpy>
	return dst;
}
  80082b:	89 d8                	mov    %ebx,%eax
  80082d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800830:	c9                   	leave  
  800831:	c3                   	ret    

00800832 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800832:	55                   	push   %ebp
  800833:	89 e5                	mov    %esp,%ebp
  800835:	56                   	push   %esi
  800836:	53                   	push   %ebx
  800837:	8b 45 08             	mov    0x8(%ebp),%eax
  80083a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80083d:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800840:	85 f6                	test   %esi,%esi
  800842:	74 15                	je     800859 <strncpy+0x27>
  800844:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  800849:	8a 1a                	mov    (%edx),%bl
  80084b:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80084e:	80 3a 01             	cmpb   $0x1,(%edx)
  800851:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800854:	41                   	inc    %ecx
  800855:	39 ce                	cmp    %ecx,%esi
  800857:	77 f0                	ja     800849 <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800859:	5b                   	pop    %ebx
  80085a:	5e                   	pop    %esi
  80085b:	c9                   	leave  
  80085c:	c3                   	ret    

0080085d <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80085d:	55                   	push   %ebp
  80085e:	89 e5                	mov    %esp,%ebp
  800860:	57                   	push   %edi
  800861:	56                   	push   %esi
  800862:	53                   	push   %ebx
  800863:	8b 7d 08             	mov    0x8(%ebp),%edi
  800866:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800869:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80086c:	85 f6                	test   %esi,%esi
  80086e:	74 32                	je     8008a2 <strlcpy+0x45>
		while (--size > 0 && *src != '\0')
  800870:	83 fe 01             	cmp    $0x1,%esi
  800873:	74 22                	je     800897 <strlcpy+0x3a>
  800875:	8a 0b                	mov    (%ebx),%cl
  800877:	84 c9                	test   %cl,%cl
  800879:	74 20                	je     80089b <strlcpy+0x3e>
  80087b:	89 f8                	mov    %edi,%eax
  80087d:	ba 00 00 00 00       	mov    $0x0,%edx
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
  800882:	83 ee 02             	sub    $0x2,%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800885:	88 08                	mov    %cl,(%eax)
  800887:	40                   	inc    %eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800888:	39 f2                	cmp    %esi,%edx
  80088a:	74 11                	je     80089d <strlcpy+0x40>
  80088c:	8a 4c 13 01          	mov    0x1(%ebx,%edx,1),%cl
  800890:	42                   	inc    %edx
  800891:	84 c9                	test   %cl,%cl
  800893:	75 f0                	jne    800885 <strlcpy+0x28>
  800895:	eb 06                	jmp    80089d <strlcpy+0x40>
  800897:	89 f8                	mov    %edi,%eax
  800899:	eb 02                	jmp    80089d <strlcpy+0x40>
  80089b:	89 f8                	mov    %edi,%eax
			*dst++ = *src++;
		*dst = '\0';
  80089d:	c6 00 00             	movb   $0x0,(%eax)
  8008a0:	eb 02                	jmp    8008a4 <strlcpy+0x47>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8008a2:	89 f8                	mov    %edi,%eax
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
		*dst = '\0';
	}
	return dst - dst_in;
  8008a4:	29 f8                	sub    %edi,%eax
}
  8008a6:	5b                   	pop    %ebx
  8008a7:	5e                   	pop    %esi
  8008a8:	5f                   	pop    %edi
  8008a9:	c9                   	leave  
  8008aa:	c3                   	ret    

008008ab <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8008ab:	55                   	push   %ebp
  8008ac:	89 e5                	mov    %esp,%ebp
  8008ae:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008b1:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008b4:	8a 01                	mov    (%ecx),%al
  8008b6:	84 c0                	test   %al,%al
  8008b8:	74 10                	je     8008ca <strcmp+0x1f>
  8008ba:	3a 02                	cmp    (%edx),%al
  8008bc:	75 0c                	jne    8008ca <strcmp+0x1f>
		p++, q++;
  8008be:	41                   	inc    %ecx
  8008bf:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8008c0:	8a 01                	mov    (%ecx),%al
  8008c2:	84 c0                	test   %al,%al
  8008c4:	74 04                	je     8008ca <strcmp+0x1f>
  8008c6:	3a 02                	cmp    (%edx),%al
  8008c8:	74 f4                	je     8008be <strcmp+0x13>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008ca:	0f b6 c0             	movzbl %al,%eax
  8008cd:	0f b6 12             	movzbl (%edx),%edx
  8008d0:	29 d0                	sub    %edx,%eax
}
  8008d2:	c9                   	leave  
  8008d3:	c3                   	ret    

008008d4 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008d4:	55                   	push   %ebp
  8008d5:	89 e5                	mov    %esp,%ebp
  8008d7:	53                   	push   %ebx
  8008d8:	8b 55 08             	mov    0x8(%ebp),%edx
  8008db:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008de:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  8008e1:	85 c0                	test   %eax,%eax
  8008e3:	74 1b                	je     800900 <strncmp+0x2c>
  8008e5:	8a 1a                	mov    (%edx),%bl
  8008e7:	84 db                	test   %bl,%bl
  8008e9:	74 24                	je     80090f <strncmp+0x3b>
  8008eb:	3a 19                	cmp    (%ecx),%bl
  8008ed:	75 20                	jne    80090f <strncmp+0x3b>
  8008ef:	48                   	dec    %eax
  8008f0:	74 15                	je     800907 <strncmp+0x33>
		n--, p++, q++;
  8008f2:	42                   	inc    %edx
  8008f3:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8008f4:	8a 1a                	mov    (%edx),%bl
  8008f6:	84 db                	test   %bl,%bl
  8008f8:	74 15                	je     80090f <strncmp+0x3b>
  8008fa:	3a 19                	cmp    (%ecx),%bl
  8008fc:	74 f1                	je     8008ef <strncmp+0x1b>
  8008fe:	eb 0f                	jmp    80090f <strncmp+0x3b>
		n--, p++, q++;
	if (n == 0)
		return 0;
  800900:	b8 00 00 00 00       	mov    $0x0,%eax
  800905:	eb 05                	jmp    80090c <strncmp+0x38>
  800907:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80090c:	5b                   	pop    %ebx
  80090d:	c9                   	leave  
  80090e:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80090f:	0f b6 02             	movzbl (%edx),%eax
  800912:	0f b6 11             	movzbl (%ecx),%edx
  800915:	29 d0                	sub    %edx,%eax
  800917:	eb f3                	jmp    80090c <strncmp+0x38>

00800919 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800919:	55                   	push   %ebp
  80091a:	89 e5                	mov    %esp,%ebp
  80091c:	8b 45 08             	mov    0x8(%ebp),%eax
  80091f:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800922:	8a 10                	mov    (%eax),%dl
  800924:	84 d2                	test   %dl,%dl
  800926:	74 18                	je     800940 <strchr+0x27>
		if (*s == c)
  800928:	38 ca                	cmp    %cl,%dl
  80092a:	75 06                	jne    800932 <strchr+0x19>
  80092c:	eb 17                	jmp    800945 <strchr+0x2c>
  80092e:	38 ca                	cmp    %cl,%dl
  800930:	74 13                	je     800945 <strchr+0x2c>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800932:	40                   	inc    %eax
  800933:	8a 10                	mov    (%eax),%dl
  800935:	84 d2                	test   %dl,%dl
  800937:	75 f5                	jne    80092e <strchr+0x15>
		if (*s == c)
			return (char *) s;
	return 0;
  800939:	b8 00 00 00 00       	mov    $0x0,%eax
  80093e:	eb 05                	jmp    800945 <strchr+0x2c>
  800940:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800945:	c9                   	leave  
  800946:	c3                   	ret    

00800947 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800947:	55                   	push   %ebp
  800948:	89 e5                	mov    %esp,%ebp
  80094a:	8b 45 08             	mov    0x8(%ebp),%eax
  80094d:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800950:	8a 10                	mov    (%eax),%dl
  800952:	84 d2                	test   %dl,%dl
  800954:	74 11                	je     800967 <strfind+0x20>
		if (*s == c)
  800956:	38 ca                	cmp    %cl,%dl
  800958:	75 06                	jne    800960 <strfind+0x19>
  80095a:	eb 0b                	jmp    800967 <strfind+0x20>
  80095c:	38 ca                	cmp    %cl,%dl
  80095e:	74 07                	je     800967 <strfind+0x20>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800960:	40                   	inc    %eax
  800961:	8a 10                	mov    (%eax),%dl
  800963:	84 d2                	test   %dl,%dl
  800965:	75 f5                	jne    80095c <strfind+0x15>
		if (*s == c)
			break;
	return (char *) s;
}
  800967:	c9                   	leave  
  800968:	c3                   	ret    

00800969 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800969:	55                   	push   %ebp
  80096a:	89 e5                	mov    %esp,%ebp
  80096c:	57                   	push   %edi
  80096d:	56                   	push   %esi
  80096e:	53                   	push   %ebx
  80096f:	8b 7d 08             	mov    0x8(%ebp),%edi
  800972:	8b 45 0c             	mov    0xc(%ebp),%eax
  800975:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800978:	85 c9                	test   %ecx,%ecx
  80097a:	74 30                	je     8009ac <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80097c:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800982:	75 25                	jne    8009a9 <memset+0x40>
  800984:	f6 c1 03             	test   $0x3,%cl
  800987:	75 20                	jne    8009a9 <memset+0x40>
		c &= 0xFF;
  800989:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80098c:	89 d3                	mov    %edx,%ebx
  80098e:	c1 e3 08             	shl    $0x8,%ebx
  800991:	89 d6                	mov    %edx,%esi
  800993:	c1 e6 18             	shl    $0x18,%esi
  800996:	89 d0                	mov    %edx,%eax
  800998:	c1 e0 10             	shl    $0x10,%eax
  80099b:	09 f0                	or     %esi,%eax
  80099d:	09 d0                	or     %edx,%eax
  80099f:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  8009a1:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  8009a4:	fc                   	cld    
  8009a5:	f3 ab                	rep stos %eax,%es:(%edi)
  8009a7:	eb 03                	jmp    8009ac <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8009a9:	fc                   	cld    
  8009aa:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8009ac:	89 f8                	mov    %edi,%eax
  8009ae:	5b                   	pop    %ebx
  8009af:	5e                   	pop    %esi
  8009b0:	5f                   	pop    %edi
  8009b1:	c9                   	leave  
  8009b2:	c3                   	ret    

008009b3 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8009b3:	55                   	push   %ebp
  8009b4:	89 e5                	mov    %esp,%ebp
  8009b6:	57                   	push   %edi
  8009b7:	56                   	push   %esi
  8009b8:	8b 45 08             	mov    0x8(%ebp),%eax
  8009bb:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009be:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8009c1:	39 c6                	cmp    %eax,%esi
  8009c3:	73 34                	jae    8009f9 <memmove+0x46>
  8009c5:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8009c8:	39 d0                	cmp    %edx,%eax
  8009ca:	73 2d                	jae    8009f9 <memmove+0x46>
		s += n;
		d += n;
  8009cc:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009cf:	f6 c2 03             	test   $0x3,%dl
  8009d2:	75 1b                	jne    8009ef <memmove+0x3c>
  8009d4:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8009da:	75 13                	jne    8009ef <memmove+0x3c>
  8009dc:	f6 c1 03             	test   $0x3,%cl
  8009df:	75 0e                	jne    8009ef <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8009e1:	83 ef 04             	sub    $0x4,%edi
  8009e4:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009e7:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  8009ea:	fd                   	std    
  8009eb:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009ed:	eb 07                	jmp    8009f6 <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8009ef:	4f                   	dec    %edi
  8009f0:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8009f3:	fd                   	std    
  8009f4:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009f6:	fc                   	cld    
  8009f7:	eb 20                	jmp    800a19 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009f9:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009ff:	75 13                	jne    800a14 <memmove+0x61>
  800a01:	a8 03                	test   $0x3,%al
  800a03:	75 0f                	jne    800a14 <memmove+0x61>
  800a05:	f6 c1 03             	test   $0x3,%cl
  800a08:	75 0a                	jne    800a14 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800a0a:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800a0d:	89 c7                	mov    %eax,%edi
  800a0f:	fc                   	cld    
  800a10:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a12:	eb 05                	jmp    800a19 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a14:	89 c7                	mov    %eax,%edi
  800a16:	fc                   	cld    
  800a17:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a19:	5e                   	pop    %esi
  800a1a:	5f                   	pop    %edi
  800a1b:	c9                   	leave  
  800a1c:	c3                   	ret    

00800a1d <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a1d:	55                   	push   %ebp
  800a1e:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800a20:	ff 75 10             	pushl  0x10(%ebp)
  800a23:	ff 75 0c             	pushl  0xc(%ebp)
  800a26:	ff 75 08             	pushl  0x8(%ebp)
  800a29:	e8 85 ff ff ff       	call   8009b3 <memmove>
}
  800a2e:	c9                   	leave  
  800a2f:	c3                   	ret    

00800a30 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a30:	55                   	push   %ebp
  800a31:	89 e5                	mov    %esp,%ebp
  800a33:	57                   	push   %edi
  800a34:	56                   	push   %esi
  800a35:	53                   	push   %ebx
  800a36:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800a39:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a3c:	8b 7d 10             	mov    0x10(%ebp),%edi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a3f:	85 ff                	test   %edi,%edi
  800a41:	74 32                	je     800a75 <memcmp+0x45>
		if (*s1 != *s2)
  800a43:	8a 03                	mov    (%ebx),%al
  800a45:	8a 0e                	mov    (%esi),%cl
  800a47:	38 c8                	cmp    %cl,%al
  800a49:	74 19                	je     800a64 <memcmp+0x34>
  800a4b:	eb 0d                	jmp    800a5a <memcmp+0x2a>
  800a4d:	8a 44 13 01          	mov    0x1(%ebx,%edx,1),%al
  800a51:	8a 4c 16 01          	mov    0x1(%esi,%edx,1),%cl
  800a55:	42                   	inc    %edx
  800a56:	38 c8                	cmp    %cl,%al
  800a58:	74 10                	je     800a6a <memcmp+0x3a>
			return (int) *s1 - (int) *s2;
  800a5a:	0f b6 c0             	movzbl %al,%eax
  800a5d:	0f b6 c9             	movzbl %cl,%ecx
  800a60:	29 c8                	sub    %ecx,%eax
  800a62:	eb 16                	jmp    800a7a <memcmp+0x4a>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a64:	4f                   	dec    %edi
  800a65:	ba 00 00 00 00       	mov    $0x0,%edx
  800a6a:	39 fa                	cmp    %edi,%edx
  800a6c:	75 df                	jne    800a4d <memcmp+0x1d>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a6e:	b8 00 00 00 00       	mov    $0x0,%eax
  800a73:	eb 05                	jmp    800a7a <memcmp+0x4a>
  800a75:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a7a:	5b                   	pop    %ebx
  800a7b:	5e                   	pop    %esi
  800a7c:	5f                   	pop    %edi
  800a7d:	c9                   	leave  
  800a7e:	c3                   	ret    

00800a7f <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a7f:	55                   	push   %ebp
  800a80:	89 e5                	mov    %esp,%ebp
  800a82:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800a85:	89 c2                	mov    %eax,%edx
  800a87:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a8a:	39 d0                	cmp    %edx,%eax
  800a8c:	73 12                	jae    800aa0 <memfind+0x21>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a8e:	8a 4d 0c             	mov    0xc(%ebp),%cl
  800a91:	38 08                	cmp    %cl,(%eax)
  800a93:	75 06                	jne    800a9b <memfind+0x1c>
  800a95:	eb 09                	jmp    800aa0 <memfind+0x21>
  800a97:	38 08                	cmp    %cl,(%eax)
  800a99:	74 05                	je     800aa0 <memfind+0x21>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a9b:	40                   	inc    %eax
  800a9c:	39 c2                	cmp    %eax,%edx
  800a9e:	77 f7                	ja     800a97 <memfind+0x18>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800aa0:	c9                   	leave  
  800aa1:	c3                   	ret    

00800aa2 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800aa2:	55                   	push   %ebp
  800aa3:	89 e5                	mov    %esp,%ebp
  800aa5:	57                   	push   %edi
  800aa6:	56                   	push   %esi
  800aa7:	53                   	push   %ebx
  800aa8:	8b 55 08             	mov    0x8(%ebp),%edx
  800aab:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800aae:	eb 01                	jmp    800ab1 <strtol+0xf>
		s++;
  800ab0:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ab1:	8a 02                	mov    (%edx),%al
  800ab3:	3c 20                	cmp    $0x20,%al
  800ab5:	74 f9                	je     800ab0 <strtol+0xe>
  800ab7:	3c 09                	cmp    $0x9,%al
  800ab9:	74 f5                	je     800ab0 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800abb:	3c 2b                	cmp    $0x2b,%al
  800abd:	75 08                	jne    800ac7 <strtol+0x25>
		s++;
  800abf:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800ac0:	bf 00 00 00 00       	mov    $0x0,%edi
  800ac5:	eb 13                	jmp    800ada <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800ac7:	3c 2d                	cmp    $0x2d,%al
  800ac9:	75 0a                	jne    800ad5 <strtol+0x33>
		s++, neg = 1;
  800acb:	8d 52 01             	lea    0x1(%edx),%edx
  800ace:	bf 01 00 00 00       	mov    $0x1,%edi
  800ad3:	eb 05                	jmp    800ada <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800ad5:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800ada:	85 db                	test   %ebx,%ebx
  800adc:	74 05                	je     800ae3 <strtol+0x41>
  800ade:	83 fb 10             	cmp    $0x10,%ebx
  800ae1:	75 28                	jne    800b0b <strtol+0x69>
  800ae3:	8a 02                	mov    (%edx),%al
  800ae5:	3c 30                	cmp    $0x30,%al
  800ae7:	75 10                	jne    800af9 <strtol+0x57>
  800ae9:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800aed:	75 0a                	jne    800af9 <strtol+0x57>
		s += 2, base = 16;
  800aef:	83 c2 02             	add    $0x2,%edx
  800af2:	bb 10 00 00 00       	mov    $0x10,%ebx
  800af7:	eb 12                	jmp    800b0b <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800af9:	85 db                	test   %ebx,%ebx
  800afb:	75 0e                	jne    800b0b <strtol+0x69>
  800afd:	3c 30                	cmp    $0x30,%al
  800aff:	75 05                	jne    800b06 <strtol+0x64>
		s++, base = 8;
  800b01:	42                   	inc    %edx
  800b02:	b3 08                	mov    $0x8,%bl
  800b04:	eb 05                	jmp    800b0b <strtol+0x69>
	else if (base == 0)
		base = 10;
  800b06:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800b0b:	b8 00 00 00 00       	mov    $0x0,%eax
  800b10:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800b12:	8a 0a                	mov    (%edx),%cl
  800b14:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800b17:	80 fb 09             	cmp    $0x9,%bl
  800b1a:	77 08                	ja     800b24 <strtol+0x82>
			dig = *s - '0';
  800b1c:	0f be c9             	movsbl %cl,%ecx
  800b1f:	83 e9 30             	sub    $0x30,%ecx
  800b22:	eb 1e                	jmp    800b42 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800b24:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800b27:	80 fb 19             	cmp    $0x19,%bl
  800b2a:	77 08                	ja     800b34 <strtol+0x92>
			dig = *s - 'a' + 10;
  800b2c:	0f be c9             	movsbl %cl,%ecx
  800b2f:	83 e9 57             	sub    $0x57,%ecx
  800b32:	eb 0e                	jmp    800b42 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800b34:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800b37:	80 fb 19             	cmp    $0x19,%bl
  800b3a:	77 13                	ja     800b4f <strtol+0xad>
			dig = *s - 'A' + 10;
  800b3c:	0f be c9             	movsbl %cl,%ecx
  800b3f:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800b42:	39 f1                	cmp    %esi,%ecx
  800b44:	7d 0d                	jge    800b53 <strtol+0xb1>
			break;
		s++, val = (val * base) + dig;
  800b46:	42                   	inc    %edx
  800b47:	0f af c6             	imul   %esi,%eax
  800b4a:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  800b4d:	eb c3                	jmp    800b12 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800b4f:	89 c1                	mov    %eax,%ecx
  800b51:	eb 02                	jmp    800b55 <strtol+0xb3>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800b53:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800b55:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b59:	74 05                	je     800b60 <strtol+0xbe>
		*endptr = (char *) s;
  800b5b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800b5e:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800b60:	85 ff                	test   %edi,%edi
  800b62:	74 04                	je     800b68 <strtol+0xc6>
  800b64:	89 c8                	mov    %ecx,%eax
  800b66:	f7 d8                	neg    %eax
}
  800b68:	5b                   	pop    %ebx
  800b69:	5e                   	pop    %esi
  800b6a:	5f                   	pop    %edi
  800b6b:	c9                   	leave  
  800b6c:	c3                   	ret    
  800b6d:	00 00                	add    %al,(%eax)
	...

00800b70 <syscall>:
	return ret;
}

static int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800b70:	55                   	push   %ebp
  800b71:	89 e5                	mov    %esp,%ebp
  800b73:	57                   	push   %edi
  800b74:	56                   	push   %esi
  800b75:	53                   	push   %ebx
  800b76:	83 ec 1c             	sub    $0x1c,%esp
  800b79:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800b7c:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800b7f:	89 ca                	mov    %ecx,%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b81:	8b 75 14             	mov    0x14(%ebp),%esi
  800b84:	8b 7d 10             	mov    0x10(%ebp),%edi
  800b87:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800b8a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b8d:	cd 30                	int    $0x30
  800b8f:	89 c2                	mov    %eax,%edx
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b91:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800b95:	74 1c                	je     800bb3 <syscall+0x43>
  800b97:	85 c0                	test   %eax,%eax
  800b99:	7e 18                	jle    800bb3 <syscall+0x43>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b9b:	83 ec 0c             	sub    $0xc,%esp
  800b9e:	50                   	push   %eax
  800b9f:	ff 75 e4             	pushl  -0x1c(%ebp)
  800ba2:	68 5f 25 80 00       	push   $0x80255f
  800ba7:	6a 42                	push   $0x42
  800ba9:	68 7c 25 80 00       	push   $0x80257c
  800bae:	e8 b1 f5 ff ff       	call   800164 <_panic>

	return ret;
}
  800bb3:	89 d0                	mov    %edx,%eax
  800bb5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bb8:	5b                   	pop    %ebx
  800bb9:	5e                   	pop    %esi
  800bba:	5f                   	pop    %edi
  800bbb:	c9                   	leave  
  800bbc:	c3                   	ret    

00800bbd <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{	
  800bbd:	55                   	push   %ebp
  800bbe:	89 e5                	mov    %esp,%ebp
  800bc0:	83 ec 08             	sub    $0x8,%esp
	// my_sysenter(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
	// return;
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  800bc3:	6a 00                	push   $0x0
  800bc5:	6a 00                	push   $0x0
  800bc7:	6a 00                	push   $0x0
  800bc9:	ff 75 0c             	pushl  0xc(%ebp)
  800bcc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800bcf:	ba 00 00 00 00       	mov    $0x0,%edx
  800bd4:	b8 00 00 00 00       	mov    $0x0,%eax
  800bd9:	e8 92 ff ff ff       	call   800b70 <syscall>
  800bde:	83 c4 10             	add    $0x10,%esp
	return;
}
  800be1:	c9                   	leave  
  800be2:	c3                   	ret    

00800be3 <sys_cgetc>:

int
sys_cgetc(void)
{
  800be3:	55                   	push   %ebp
  800be4:	89 e5                	mov    %esp,%ebp
  800be6:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_cgetc, 0, 0, 0, 0, 0, 0);
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  800be9:	6a 00                	push   $0x0
  800beb:	6a 00                	push   $0x0
  800bed:	6a 00                	push   $0x0
  800bef:	6a 00                	push   $0x0
  800bf1:	b9 00 00 00 00       	mov    $0x0,%ecx
  800bf6:	ba 00 00 00 00       	mov    $0x0,%edx
  800bfb:	b8 01 00 00 00       	mov    $0x1,%eax
  800c00:	e8 6b ff ff ff       	call   800b70 <syscall>
}
  800c05:	c9                   	leave  
  800c06:	c3                   	ret    

00800c07 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800c07:	55                   	push   %ebp
  800c08:	89 e5                	mov    %esp,%ebp
  800c0a:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  800c0d:	6a 00                	push   $0x0
  800c0f:	6a 00                	push   $0x0
  800c11:	6a 00                	push   $0x0
  800c13:	6a 00                	push   $0x0
  800c15:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c18:	ba 01 00 00 00       	mov    $0x1,%edx
  800c1d:	b8 03 00 00 00       	mov    $0x3,%eax
  800c22:	e8 49 ff ff ff       	call   800b70 <syscall>
}
  800c27:	c9                   	leave  
  800c28:	c3                   	ret    

00800c29 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c29:	55                   	push   %ebp
  800c2a:	89 e5                	mov    %esp,%ebp
  800c2c:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_getenvid, 0, 0, 0, 0, 0, 0);
	return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  800c2f:	6a 00                	push   $0x0
  800c31:	6a 00                	push   $0x0
  800c33:	6a 00                	push   $0x0
  800c35:	6a 00                	push   $0x0
  800c37:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c3c:	ba 00 00 00 00       	mov    $0x0,%edx
  800c41:	b8 02 00 00 00       	mov    $0x2,%eax
  800c46:	e8 25 ff ff ff       	call   800b70 <syscall>
}
  800c4b:	c9                   	leave  
  800c4c:	c3                   	ret    

00800c4d <sys_yield>:

void
sys_yield(void)
{
  800c4d:	55                   	push   %ebp
  800c4e:	89 e5                	mov    %esp,%ebp
  800c50:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  800c53:	6a 00                	push   $0x0
  800c55:	6a 00                	push   $0x0
  800c57:	6a 00                	push   $0x0
  800c59:	6a 00                	push   $0x0
  800c5b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c60:	ba 00 00 00 00       	mov    $0x0,%edx
  800c65:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c6a:	e8 01 ff ff ff       	call   800b70 <syscall>
  800c6f:	83 c4 10             	add    $0x10,%esp
}
  800c72:	c9                   	leave  
  800c73:	c3                   	ret    

00800c74 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c74:	55                   	push   %ebp
  800c75:	89 e5                	mov    %esp,%ebp
  800c77:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  800c7a:	6a 00                	push   $0x0
  800c7c:	6a 00                	push   $0x0
  800c7e:	ff 75 10             	pushl  0x10(%ebp)
  800c81:	ff 75 0c             	pushl  0xc(%ebp)
  800c84:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c87:	ba 01 00 00 00       	mov    $0x1,%edx
  800c8c:	b8 04 00 00 00       	mov    $0x4,%eax
  800c91:	e8 da fe ff ff       	call   800b70 <syscall>
}
  800c96:	c9                   	leave  
  800c97:	c3                   	ret    

00800c98 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c98:	55                   	push   %ebp
  800c99:	89 e5                	mov    %esp,%ebp
  800c9b:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
  800c9e:	ff 75 18             	pushl  0x18(%ebp)
  800ca1:	ff 75 14             	pushl  0x14(%ebp)
  800ca4:	ff 75 10             	pushl  0x10(%ebp)
  800ca7:	ff 75 0c             	pushl  0xc(%ebp)
  800caa:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800cad:	ba 01 00 00 00       	mov    $0x1,%edx
  800cb2:	b8 05 00 00 00       	mov    $0x5,%eax
  800cb7:	e8 b4 fe ff ff       	call   800b70 <syscall>
}
  800cbc:	c9                   	leave  
  800cbd:	c3                   	ret    

00800cbe <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800cbe:	55                   	push   %ebp
  800cbf:	89 e5                	mov    %esp,%ebp
  800cc1:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  800cc4:	6a 00                	push   $0x0
  800cc6:	6a 00                	push   $0x0
  800cc8:	6a 00                	push   $0x0
  800cca:	ff 75 0c             	pushl  0xc(%ebp)
  800ccd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800cd0:	ba 01 00 00 00       	mov    $0x1,%edx
  800cd5:	b8 06 00 00 00       	mov    $0x6,%eax
  800cda:	e8 91 fe ff ff       	call   800b70 <syscall>
}
  800cdf:	c9                   	leave  
  800ce0:	c3                   	ret    

00800ce1 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800ce1:	55                   	push   %ebp
  800ce2:	89 e5                	mov    %esp,%ebp
  800ce4:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  800ce7:	6a 00                	push   $0x0
  800ce9:	6a 00                	push   $0x0
  800ceb:	6a 00                	push   $0x0
  800ced:	ff 75 0c             	pushl  0xc(%ebp)
  800cf0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800cf3:	ba 01 00 00 00       	mov    $0x1,%edx
  800cf8:	b8 08 00 00 00       	mov    $0x8,%eax
  800cfd:	e8 6e fe ff ff       	call   800b70 <syscall>
}
  800d02:	c9                   	leave  
  800d03:	c3                   	ret    

00800d04 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800d04:	55                   	push   %ebp
  800d05:	89 e5                	mov    %esp,%ebp
  800d07:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
  800d0a:	6a 00                	push   $0x0
  800d0c:	6a 00                	push   $0x0
  800d0e:	6a 00                	push   $0x0
  800d10:	ff 75 0c             	pushl  0xc(%ebp)
  800d13:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d16:	ba 01 00 00 00       	mov    $0x1,%edx
  800d1b:	b8 09 00 00 00       	mov    $0x9,%eax
  800d20:	e8 4b fe ff ff       	call   800b70 <syscall>
}
  800d25:	c9                   	leave  
  800d26:	c3                   	ret    

00800d27 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d27:	55                   	push   %ebp
  800d28:	89 e5                	mov    %esp,%ebp
  800d2a:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  800d2d:	6a 00                	push   $0x0
  800d2f:	6a 00                	push   $0x0
  800d31:	6a 00                	push   $0x0
  800d33:	ff 75 0c             	pushl  0xc(%ebp)
  800d36:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d39:	ba 01 00 00 00       	mov    $0x1,%edx
  800d3e:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d43:	e8 28 fe ff ff       	call   800b70 <syscall>
}
  800d48:	c9                   	leave  
  800d49:	c3                   	ret    

00800d4a <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d4a:	55                   	push   %ebp
  800d4b:	89 e5                	mov    %esp,%ebp
  800d4d:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  800d50:	6a 00                	push   $0x0
  800d52:	ff 75 14             	pushl  0x14(%ebp)
  800d55:	ff 75 10             	pushl  0x10(%ebp)
  800d58:	ff 75 0c             	pushl  0xc(%ebp)
  800d5b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d5e:	ba 00 00 00 00       	mov    $0x0,%edx
  800d63:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d68:	e8 03 fe ff ff       	call   800b70 <syscall>
}
  800d6d:	c9                   	leave  
  800d6e:	c3                   	ret    

00800d6f <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d6f:	55                   	push   %ebp
  800d70:	89 e5                	mov    %esp,%ebp
  800d72:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  800d75:	6a 00                	push   $0x0
  800d77:	6a 00                	push   $0x0
  800d79:	6a 00                	push   $0x0
  800d7b:	6a 00                	push   $0x0
  800d7d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d80:	ba 01 00 00 00       	mov    $0x1,%edx
  800d85:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d8a:	e8 e1 fd ff ff       	call   800b70 <syscall>
}
  800d8f:	c9                   	leave  
  800d90:	c3                   	ret    

00800d91 <sys_set_priority>:

int
sys_set_priority(envid_t envid, uint32_t new_priority)
{
  800d91:	55                   	push   %ebp
  800d92:	89 e5                	mov    %esp,%ebp
  800d94:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_set_priority, 0, envid, new_priority, 0, 0, 0);
  800d97:	6a 00                	push   $0x0
  800d99:	6a 00                	push   $0x0
  800d9b:	6a 00                	push   $0x0
  800d9d:	ff 75 0c             	pushl  0xc(%ebp)
  800da0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800da3:	ba 00 00 00 00       	mov    $0x0,%edx
  800da8:	b8 0e 00 00 00       	mov    $0xe,%eax
  800dad:	e8 be fd ff ff       	call   800b70 <syscall>
}
  800db2:	c9                   	leave  
  800db3:	c3                   	ret    

00800db4 <sys_exec>:

int
sys_exec(uint32_t eip, uint32_t esp, void * ph, uint32_t elf_phnum)
{
  800db4:	55                   	push   %ebp
  800db5:	89 e5                	mov    %esp,%ebp
  800db7:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_exec, 0, eip, esp, (uint32_t)ph, elf_phnum, 0);
  800dba:	6a 00                	push   $0x0
  800dbc:	ff 75 14             	pushl  0x14(%ebp)
  800dbf:	ff 75 10             	pushl  0x10(%ebp)
  800dc2:	ff 75 0c             	pushl  0xc(%ebp)
  800dc5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800dc8:	ba 00 00 00 00       	mov    $0x0,%edx
  800dcd:	b8 0f 00 00 00       	mov    $0xf,%eax
  800dd2:	e8 99 fd ff ff       	call   800b70 <syscall>
  800dd7:	c9                   	leave  
  800dd8:	c3                   	ret    
  800dd9:	00 00                	add    %al,(%eax)
	...

00800ddc <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800ddc:	55                   	push   %ebp
  800ddd:	89 e5                	mov    %esp,%ebp
  800ddf:	53                   	push   %ebx
  800de0:	83 ec 04             	sub    $0x4,%esp
  800de3:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800de6:	8b 18                	mov    (%eax),%ebx

	// LAB 4: Your code here.
	
	// cprintf("PAGE FAULT HANDLER, 0x%08x %d\n", (uint32_t)addr, err & FEC_WR);
	
	if ((err & FEC_WR) == 0)
  800de8:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800dec:	75 14                	jne    800e02 <pgfault+0x26>
		panic("pgfault, the fault is not a write\n");
  800dee:	83 ec 04             	sub    $0x4,%esp
  800df1:	68 8c 25 80 00       	push   $0x80258c
  800df6:	6a 20                	push   $0x20
  800df8:	68 d0 26 80 00       	push   $0x8026d0
  800dfd:	e8 62 f3 ff ff       	call   800164 <_panic>

	uint32_t uaddr = (uint32_t) addr;
	if ((uvpd[PDX(addr)] & PTE_P) == 0 || (uvpt[uaddr / PGSIZE] & PTE_COW) == 0) {
  800e02:	89 d8                	mov    %ebx,%eax
  800e04:	c1 e8 16             	shr    $0x16,%eax
  800e07:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800e0e:	a8 01                	test   $0x1,%al
  800e10:	74 11                	je     800e23 <pgfault+0x47>
  800e12:	89 d8                	mov    %ebx,%eax
  800e14:	c1 e8 0c             	shr    $0xc,%eax
  800e17:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800e1e:	f6 c4 08             	test   $0x8,%ah
  800e21:	75 14                	jne    800e37 <pgfault+0x5b>
		panic("pgfault, not a copy-on-write page\n");
  800e23:	83 ec 04             	sub    $0x4,%esp
  800e26:	68 b0 25 80 00       	push   $0x8025b0
  800e2b:	6a 24                	push   $0x24
  800e2d:	68 d0 26 80 00       	push   $0x8026d0
  800e32:	e8 2d f3 ff ff       	call   800164 <_panic>
	//   No need to explicitly delete the old page's mapping.

	// LAB 4: Your code here.

	// static int sys_page_alloc(envid_t envid, void *va, int perm)
	r = sys_page_alloc(0, (void *)PFTEMP, PTE_W | PTE_U | PTE_P);
  800e37:	83 ec 04             	sub    $0x4,%esp
  800e3a:	6a 07                	push   $0x7
  800e3c:	68 00 f0 7f 00       	push   $0x7ff000
  800e41:	6a 00                	push   $0x0
  800e43:	e8 2c fe ff ff       	call   800c74 <sys_page_alloc>
	if (r < 0) panic("pgfault, sys_page_alloc error : %e\n", r);
  800e48:	83 c4 10             	add    $0x10,%esp
  800e4b:	85 c0                	test   %eax,%eax
  800e4d:	79 12                	jns    800e61 <pgfault+0x85>
  800e4f:	50                   	push   %eax
  800e50:	68 d4 25 80 00       	push   $0x8025d4
  800e55:	6a 32                	push   $0x32
  800e57:	68 d0 26 80 00       	push   $0x8026d0
  800e5c:	e8 03 f3 ff ff       	call   800164 <_panic>

	// Oh my god, I forget this at the first, it waste me a lot of time to debug!!!
	addr = ROUNDDOWN(addr, PGSIZE);
  800e61:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	
	memcpy(PFTEMP, addr, PGSIZE);
  800e67:	83 ec 04             	sub    $0x4,%esp
  800e6a:	68 00 10 00 00       	push   $0x1000
  800e6f:	53                   	push   %ebx
  800e70:	68 00 f0 7f 00       	push   $0x7ff000
  800e75:	e8 a3 fb ff ff       	call   800a1d <memcpy>
	
	r = sys_page_map(0, PFTEMP, 0, addr, PTE_W | PTE_U | PTE_P);
  800e7a:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800e81:	53                   	push   %ebx
  800e82:	6a 00                	push   $0x0
  800e84:	68 00 f0 7f 00       	push   $0x7ff000
  800e89:	6a 00                	push   $0x0
  800e8b:	e8 08 fe ff ff       	call   800c98 <sys_page_map>
	if (r < 0) panic("pgfault, sys_page_map error : %e\n", r);
  800e90:	83 c4 20             	add    $0x20,%esp
  800e93:	85 c0                	test   %eax,%eax
  800e95:	79 12                	jns    800ea9 <pgfault+0xcd>
  800e97:	50                   	push   %eax
  800e98:	68 f8 25 80 00       	push   $0x8025f8
  800e9d:	6a 3a                	push   $0x3a
  800e9f:	68 d0 26 80 00       	push   $0x8026d0
  800ea4:	e8 bb f2 ff ff       	call   800164 <_panic>

	return;
}
  800ea9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800eac:	c9                   	leave  
  800ead:	c3                   	ret    

00800eae <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800eae:	55                   	push   %ebp
  800eaf:	89 e5                	mov    %esp,%ebp
  800eb1:	57                   	push   %edi
  800eb2:	56                   	push   %esi
  800eb3:	53                   	push   %ebx
  800eb4:	83 ec 28             	sub    $0x28,%esp
	// static int num = 0x100;

	// LAB 4: Your code here.
	set_pgfault_handler(pgfault);
  800eb7:	68 dc 0d 80 00       	push   $0x800ddc
  800ebc:	e8 13 10 00 00       	call   801ed4 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  800ec1:	ba 07 00 00 00       	mov    $0x7,%edx
  800ec6:	89 d0                	mov    %edx,%eax
  800ec8:	cd 30                	int    $0x30
  800eca:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800ecd:	89 c7                	mov    %eax,%edi
	int childpid = sys_exofork();
	if (childpid < 0) {
  800ecf:	83 c4 10             	add    $0x10,%esp
  800ed2:	85 c0                	test   %eax,%eax
  800ed4:	79 12                	jns    800ee8 <fork+0x3a>
		panic("fork sys_exofork error : %e\n", childpid);
  800ed6:	50                   	push   %eax
  800ed7:	68 db 26 80 00       	push   $0x8026db
  800edc:	6a 7f                	push   $0x7f
  800ede:	68 d0 26 80 00       	push   $0x8026d0
  800ee3:	e8 7c f2 ff ff       	call   800164 <_panic>
	}
	int r;

	if (childpid == 0) {
  800ee8:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800eec:	75 25                	jne    800f13 <fork+0x65>
		// child process
		// Remember to fix "thisenv" in the child process. ??? 
		thisenv = &envs[ENVX(sys_getenvid())];
  800eee:	e8 36 fd ff ff       	call   800c29 <sys_getenvid>
  800ef3:	25 ff 03 00 00       	and    $0x3ff,%eax
  800ef8:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800eff:	c1 e0 07             	shl    $0x7,%eax
  800f02:	29 d0                	sub    %edx,%eax
  800f04:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800f09:	a3 04 40 80 00       	mov    %eax,0x804004
		// cprintf("fork child ok\n");
		return 0;
  800f0e:	e9 be 01 00 00       	jmp    8010d1 <fork+0x223>
	if (childpid < 0) {
		panic("fork sys_exofork error : %e\n", childpid);
	}
	int r;

	if (childpid == 0) {
  800f13:	bb 00 00 00 00       	mov    $0x0,%ebx
	} else {
		// map page to new environment
		// kernel page is already in new environment
		uint32_t i;
		for (i = 0; i != UTOP; i += PGSIZE) 
		if ((uvpd[PDX(i)] & PTE_P) && (uvpt[i / PGSIZE] & PTE_P) && (uvpt[i / PGSIZE] & PTE_U)) {
  800f18:	89 d8                	mov    %ebx,%eax
  800f1a:	c1 e8 16             	shr    $0x16,%eax
  800f1d:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800f24:	a8 01                	test   $0x1,%al
  800f26:	0f 84 10 01 00 00    	je     80103c <fork+0x18e>
  800f2c:	89 d8                	mov    %ebx,%eax
  800f2e:	c1 e8 0c             	shr    $0xc,%eax
  800f31:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800f38:	f6 c2 01             	test   $0x1,%dl
  800f3b:	0f 84 fb 00 00 00    	je     80103c <fork+0x18e>
  800f41:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800f48:	f6 c2 04             	test   $0x4,%dl
  800f4b:	0f 84 eb 00 00 00    	je     80103c <fork+0x18e>
//
static int
duppage(envid_t envid, unsigned pn)
{
	// do not dup exception stack
	if (pn * PGSIZE == UXSTACKTOP - PGSIZE) return 0;
  800f51:	89 c6                	mov    %eax,%esi
  800f53:	c1 e6 0c             	shl    $0xc,%esi
  800f56:	81 fe 00 f0 bf ee    	cmp    $0xeebff000,%esi
  800f5c:	0f 84 da 00 00 00    	je     80103c <fork+0x18e>

	int r;
	void * addr = (void *)(pn * PGSIZE);
    if (uvpt[pn] & PTE_SHARE) {
  800f62:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800f69:	f6 c6 04             	test   $0x4,%dh
  800f6c:	74 37                	je     800fa5 <fork+0xf7>
        r = sys_page_map(0, addr, envid, addr, uvpt[pn] & PTE_SYSCALL);
  800f6e:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f75:	83 ec 0c             	sub    $0xc,%esp
  800f78:	25 07 0e 00 00       	and    $0xe07,%eax
  800f7d:	50                   	push   %eax
  800f7e:	56                   	push   %esi
  800f7f:	57                   	push   %edi
  800f80:	56                   	push   %esi
  800f81:	6a 00                	push   $0x0
  800f83:	e8 10 fd ff ff       	call   800c98 <sys_page_map>
        if (r < 0) panic("duppage sys_page_map error : %e\n", r);
  800f88:	83 c4 20             	add    $0x20,%esp
  800f8b:	85 c0                	test   %eax,%eax
  800f8d:	0f 89 a9 00 00 00    	jns    80103c <fork+0x18e>
  800f93:	50                   	push   %eax
  800f94:	68 1c 26 80 00       	push   $0x80261c
  800f99:	6a 54                	push   $0x54
  800f9b:	68 d0 26 80 00       	push   $0x8026d0
  800fa0:	e8 bf f1 ff ff       	call   800164 <_panic>
    } else
	if ((uvpt[pn] & PTE_W) || (uvpt[pn] & PTE_COW)) {
  800fa5:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800fac:	f6 c2 02             	test   $0x2,%dl
  800faf:	75 0c                	jne    800fbd <fork+0x10f>
  800fb1:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800fb8:	f6 c4 08             	test   $0x8,%ah
  800fbb:	74 57                	je     801014 <fork+0x166>
		// cow
		r = sys_page_map(0, addr, envid, addr, PTE_COW | PTE_P | PTE_U);
  800fbd:	83 ec 0c             	sub    $0xc,%esp
  800fc0:	68 05 08 00 00       	push   $0x805
  800fc5:	56                   	push   %esi
  800fc6:	57                   	push   %edi
  800fc7:	56                   	push   %esi
  800fc8:	6a 00                	push   $0x0
  800fca:	e8 c9 fc ff ff       	call   800c98 <sys_page_map>
		if (r < 0) panic("duppage sys_page_map error : %e\n", r);
  800fcf:	83 c4 20             	add    $0x20,%esp
  800fd2:	85 c0                	test   %eax,%eax
  800fd4:	79 12                	jns    800fe8 <fork+0x13a>
  800fd6:	50                   	push   %eax
  800fd7:	68 1c 26 80 00       	push   $0x80261c
  800fdc:	6a 59                	push   $0x59
  800fde:	68 d0 26 80 00       	push   $0x8026d0
  800fe3:	e8 7c f1 ff ff       	call   800164 <_panic>
		
		r = sys_page_map(0, addr, 0, addr, PTE_COW | PTE_P | PTE_U);
  800fe8:	83 ec 0c             	sub    $0xc,%esp
  800feb:	68 05 08 00 00       	push   $0x805
  800ff0:	56                   	push   %esi
  800ff1:	6a 00                	push   $0x0
  800ff3:	56                   	push   %esi
  800ff4:	6a 00                	push   $0x0
  800ff6:	e8 9d fc ff ff       	call   800c98 <sys_page_map>
		if (r < 0) panic("duppage sys_page_map error : %e\n", r);
  800ffb:	83 c4 20             	add    $0x20,%esp
  800ffe:	85 c0                	test   %eax,%eax
  801000:	79 3a                	jns    80103c <fork+0x18e>
  801002:	50                   	push   %eax
  801003:	68 1c 26 80 00       	push   $0x80261c
  801008:	6a 5c                	push   $0x5c
  80100a:	68 d0 26 80 00       	push   $0x8026d0
  80100f:	e8 50 f1 ff ff       	call   800164 <_panic>
	} else {
		// read only
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U);
  801014:	83 ec 0c             	sub    $0xc,%esp
  801017:	6a 05                	push   $0x5
  801019:	56                   	push   %esi
  80101a:	57                   	push   %edi
  80101b:	56                   	push   %esi
  80101c:	6a 00                	push   $0x0
  80101e:	e8 75 fc ff ff       	call   800c98 <sys_page_map>
		if (r < 0) panic("duppage sys_page_map error : %e\n", r);
  801023:	83 c4 20             	add    $0x20,%esp
  801026:	85 c0                	test   %eax,%eax
  801028:	79 12                	jns    80103c <fork+0x18e>
  80102a:	50                   	push   %eax
  80102b:	68 1c 26 80 00       	push   $0x80261c
  801030:	6a 60                	push   $0x60
  801032:	68 d0 26 80 00       	push   $0x8026d0
  801037:	e8 28 f1 ff ff       	call   800164 <_panic>
		return 0;
	} else {
		// map page to new environment
		// kernel page is already in new environment
		uint32_t i;
		for (i = 0; i != UTOP; i += PGSIZE) 
  80103c:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801042:	81 fb 00 00 c0 ee    	cmp    $0xeec00000,%ebx
  801048:	0f 85 ca fe ff ff    	jne    800f18 <fork+0x6a>
		if ((uvpd[PDX(i)] & PTE_P) && (uvpt[i / PGSIZE] & PTE_P) && (uvpt[i / PGSIZE] & PTE_U)) {
			duppage(childpid, i / PGSIZE);
		}

		// allocate exception stack
		r = sys_page_alloc(childpid, (void *)(UXSTACKTOP - PGSIZE), PTE_U | PTE_W | PTE_P);
  80104e:	83 ec 04             	sub    $0x4,%esp
  801051:	6a 07                	push   $0x7
  801053:	68 00 f0 bf ee       	push   $0xeebff000
  801058:	ff 75 e4             	pushl  -0x1c(%ebp)
  80105b:	e8 14 fc ff ff       	call   800c74 <sys_page_alloc>
		if (r < 0) panic("fork, sys_page_alloc user exception stack error : %e\n", r);
  801060:	83 c4 10             	add    $0x10,%esp
  801063:	85 c0                	test   %eax,%eax
  801065:	79 15                	jns    80107c <fork+0x1ce>
  801067:	50                   	push   %eax
  801068:	68 40 26 80 00       	push   $0x802640
  80106d:	68 94 00 00 00       	push   $0x94
  801072:	68 d0 26 80 00       	push   $0x8026d0
  801077:	e8 e8 f0 ff ff       	call   800164 <_panic>

		// set user environment user page fault handler 
		extern void _pgfault_upcall(void);
		r = sys_env_set_pgfault_upcall(childpid, _pgfault_upcall);
  80107c:	83 ec 08             	sub    $0x8,%esp
  80107f:	68 40 1f 80 00       	push   $0x801f40
  801084:	ff 75 e4             	pushl  -0x1c(%ebp)
  801087:	e8 9b fc ff ff       	call   800d27 <sys_env_set_pgfault_upcall>
		if (r < 0) panic("fork, set pgfault upcall fail : %e\n", r);
  80108c:	83 c4 10             	add    $0x10,%esp
  80108f:	85 c0                	test   %eax,%eax
  801091:	79 15                	jns    8010a8 <fork+0x1fa>
  801093:	50                   	push   %eax
  801094:	68 78 26 80 00       	push   $0x802678
  801099:	68 99 00 00 00       	push   $0x99
  80109e:	68 d0 26 80 00       	push   $0x8026d0
  8010a3:	e8 bc f0 ff ff       	call   800164 <_panic>
		r = sys_set_priority(childpid, num);
		if (r < 0) panic("fork, set priority error\n");
		*/

		// mark the child as runnable and return
		r = sys_env_set_status(childpid, ENV_RUNNABLE);
  8010a8:	83 ec 08             	sub    $0x8,%esp
  8010ab:	6a 02                	push   $0x2
  8010ad:	ff 75 e4             	pushl  -0x1c(%ebp)
  8010b0:	e8 2c fc ff ff       	call   800ce1 <sys_env_set_status>
		if (r < 0) panic("fork, set child process to ENV_RUNNABLE error : %e\n", r);
  8010b5:	83 c4 10             	add    $0x10,%esp
  8010b8:	85 c0                	test   %eax,%eax
  8010ba:	79 15                	jns    8010d1 <fork+0x223>
  8010bc:	50                   	push   %eax
  8010bd:	68 9c 26 80 00       	push   $0x80269c
  8010c2:	68 a4 00 00 00       	push   $0xa4
  8010c7:	68 d0 26 80 00       	push   $0x8026d0
  8010cc:	e8 93 f0 ff ff       	call   800164 <_panic>
		// cprintf("fork father ok!")
		return childpid;
	}

	panic("fork not implemented");
}
  8010d1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8010d4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010d7:	5b                   	pop    %ebx
  8010d8:	5e                   	pop    %esi
  8010d9:	5f                   	pop    %edi
  8010da:	c9                   	leave  
  8010db:	c3                   	ret    

008010dc <sfork>:

// Challenge!
int
sfork(void)
{
  8010dc:	55                   	push   %ebp
  8010dd:	89 e5                	mov    %esp,%ebp
  8010df:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  8010e2:	68 f8 26 80 00       	push   $0x8026f8
  8010e7:	68 b1 00 00 00       	push   $0xb1
  8010ec:	68 d0 26 80 00       	push   $0x8026d0
  8010f1:	e8 6e f0 ff ff       	call   800164 <_panic>
	...

008010f8 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8010f8:	55                   	push   %ebp
  8010f9:	89 e5                	mov    %esp,%ebp
  8010fb:	56                   	push   %esi
  8010fc:	53                   	push   %ebx
  8010fd:	8b 75 08             	mov    0x8(%ebp),%esi
  801100:	8b 45 0c             	mov    0xc(%ebp),%eax
  801103:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// cprintf("0x%x 0x%x 0x%x\n", (uint32_t)from_env_store, (uint32_t)pg, (uint32_t)perm_store);
	int r;
	if (pg != NULL) {
  801106:	85 c0                	test   %eax,%eax
  801108:	74 0e                	je     801118 <ipc_recv+0x20>
		r = sys_ipc_recv(pg);
  80110a:	83 ec 0c             	sub    $0xc,%esp
  80110d:	50                   	push   %eax
  80110e:	e8 5c fc ff ff       	call   800d6f <sys_ipc_recv>
  801113:	83 c4 10             	add    $0x10,%esp
  801116:	eb 10                	jmp    801128 <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv((void *)UTOP);
  801118:	83 ec 0c             	sub    $0xc,%esp
  80111b:	68 00 00 c0 ee       	push   $0xeec00000
  801120:	e8 4a fc ff ff       	call   800d6f <sys_ipc_recv>
  801125:	83 c4 10             	add    $0x10,%esp
	}

	if (r == 0) {
  801128:	85 c0                	test   %eax,%eax
  80112a:	75 26                	jne    801152 <ipc_recv+0x5a>
		if (from_env_store != NULL) *from_env_store = thisenv->env_ipc_from;
  80112c:	85 f6                	test   %esi,%esi
  80112e:	74 0a                	je     80113a <ipc_recv+0x42>
  801130:	a1 04 40 80 00       	mov    0x804004,%eax
  801135:	8b 40 74             	mov    0x74(%eax),%eax
  801138:	89 06                	mov    %eax,(%esi)
		if (perm_store != NULL) *perm_store = thisenv->env_ipc_perm;
  80113a:	85 db                	test   %ebx,%ebx
  80113c:	74 0a                	je     801148 <ipc_recv+0x50>
  80113e:	a1 04 40 80 00       	mov    0x804004,%eax
  801143:	8b 40 78             	mov    0x78(%eax),%eax
  801146:	89 03                	mov    %eax,(%ebx)
		return thisenv->env_ipc_value;
  801148:	a1 04 40 80 00       	mov    0x804004,%eax
  80114d:	8b 40 70             	mov    0x70(%eax),%eax
  801150:	eb 14                	jmp    801166 <ipc_recv+0x6e>
	} else {
		// fails;
		if (from_env_store != NULL) *from_env_store = 0;
  801152:	85 f6                	test   %esi,%esi
  801154:	74 06                	je     80115c <ipc_recv+0x64>
  801156:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if (perm_store != NULL) *perm_store = 0;
  80115c:	85 db                	test   %ebx,%ebx
  80115e:	74 06                	je     801166 <ipc_recv+0x6e>
  801160:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		return r;
	}
}
  801166:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801169:	5b                   	pop    %ebx
  80116a:	5e                   	pop    %esi
  80116b:	c9                   	leave  
  80116c:	c3                   	ret    

0080116d <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80116d:	55                   	push   %ebp
  80116e:	89 e5                	mov    %esp,%ebp
  801170:	57                   	push   %edi
  801171:	56                   	push   %esi
  801172:	53                   	push   %ebx
  801173:	83 ec 0c             	sub    $0xc,%esp
  801176:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801179:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80117c:	8b 75 14             	mov    0x14(%ebp),%esi
	// LAB 4: Your code here.
	// int sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
	int r;
	if (pg == NULL) pg = (void *)UTOP;
  80117f:	85 db                	test   %ebx,%ebx
  801181:	75 25                	jne    8011a8 <ipc_send+0x3b>
  801183:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
  801188:	eb 1e                	jmp    8011a8 <ipc_send+0x3b>
	
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) != 0) {
		if (r == -E_IPC_NOT_RECV) {
  80118a:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80118d:	75 07                	jne    801196 <ipc_send+0x29>
			// cprintf("Try Again and Again....\n");
			sys_yield();
  80118f:	e8 b9 fa ff ff       	call   800c4d <sys_yield>
  801194:	eb 12                	jmp    8011a8 <ipc_send+0x3b>
		} else {
			panic("ipc_send error %e\n", r);
  801196:	50                   	push   %eax
  801197:	68 0e 27 80 00       	push   $0x80270e
  80119c:	6a 43                	push   $0x43
  80119e:	68 21 27 80 00       	push   $0x802721
  8011a3:	e8 bc ef ff ff       	call   800164 <_panic>
	// LAB 4: Your code here.
	// int sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
	int r;
	if (pg == NULL) pg = (void *)UTOP;
	
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) != 0) {
  8011a8:	56                   	push   %esi
  8011a9:	53                   	push   %ebx
  8011aa:	57                   	push   %edi
  8011ab:	ff 75 08             	pushl  0x8(%ebp)
  8011ae:	e8 97 fb ff ff       	call   800d4a <sys_ipc_try_send>
  8011b3:	83 c4 10             	add    $0x10,%esp
  8011b6:	85 c0                	test   %eax,%eax
  8011b8:	75 d0                	jne    80118a <ipc_send+0x1d>
		} else {
			panic("ipc_send error %e\n", r);
		}
	}
	return;
}
  8011ba:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011bd:	5b                   	pop    %ebx
  8011be:	5e                   	pop    %esi
  8011bf:	5f                   	pop    %edi
  8011c0:	c9                   	leave  
  8011c1:	c3                   	ret    

008011c2 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8011c2:	55                   	push   %ebp
  8011c3:	89 e5                	mov    %esp,%ebp
  8011c5:	53                   	push   %ebx
  8011c6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  8011c9:	39 1d 50 00 c0 ee    	cmp    %ebx,0xeec00050
  8011cf:	74 22                	je     8011f3 <ipc_find_env+0x31>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8011d1:	b8 01 00 00 00       	mov    $0x1,%eax
		if (envs[i].env_type == type)
  8011d6:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  8011dd:	89 c2                	mov    %eax,%edx
  8011df:	c1 e2 07             	shl    $0x7,%edx
  8011e2:	29 ca                	sub    %ecx,%edx
  8011e4:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8011ea:	8b 52 50             	mov    0x50(%edx),%edx
  8011ed:	39 da                	cmp    %ebx,%edx
  8011ef:	75 1d                	jne    80120e <ipc_find_env+0x4c>
  8011f1:	eb 05                	jmp    8011f8 <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8011f3:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
			return envs[i].env_id;
  8011f8:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  8011ff:	c1 e0 07             	shl    $0x7,%eax
  801202:	29 d0                	sub    %edx,%eax
  801204:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  801209:	8b 40 40             	mov    0x40(%eax),%eax
  80120c:	eb 0c                	jmp    80121a <ipc_find_env+0x58>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80120e:	40                   	inc    %eax
  80120f:	3d 00 04 00 00       	cmp    $0x400,%eax
  801214:	75 c0                	jne    8011d6 <ipc_find_env+0x14>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801216:	66 b8 00 00          	mov    $0x0,%ax
}
  80121a:	5b                   	pop    %ebx
  80121b:	c9                   	leave  
  80121c:	c3                   	ret    
  80121d:	00 00                	add    %al,(%eax)
	...

00801220 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801220:	55                   	push   %ebp
  801221:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801223:	8b 45 08             	mov    0x8(%ebp),%eax
  801226:	05 00 00 00 30       	add    $0x30000000,%eax
  80122b:	c1 e8 0c             	shr    $0xc,%eax
}
  80122e:	c9                   	leave  
  80122f:	c3                   	ret    

00801230 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801230:	55                   	push   %ebp
  801231:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  801233:	ff 75 08             	pushl  0x8(%ebp)
  801236:	e8 e5 ff ff ff       	call   801220 <fd2num>
  80123b:	83 c4 04             	add    $0x4,%esp
  80123e:	05 20 00 0d 00       	add    $0xd0020,%eax
  801243:	c1 e0 0c             	shl    $0xc,%eax
}
  801246:	c9                   	leave  
  801247:	c3                   	ret    

00801248 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801248:	55                   	push   %ebp
  801249:	89 e5                	mov    %esp,%ebp
  80124b:	53                   	push   %ebx
  80124c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80124f:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  801254:	a8 01                	test   $0x1,%al
  801256:	74 34                	je     80128c <fd_alloc+0x44>
  801258:	a1 00 00 74 ef       	mov    0xef740000,%eax
  80125d:	a8 01                	test   $0x1,%al
  80125f:	74 32                	je     801293 <fd_alloc+0x4b>
  801261:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
  801266:	89 c1                	mov    %eax,%ecx
  801268:	89 c2                	mov    %eax,%edx
  80126a:	c1 ea 16             	shr    $0x16,%edx
  80126d:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801274:	f6 c2 01             	test   $0x1,%dl
  801277:	74 1f                	je     801298 <fd_alloc+0x50>
  801279:	89 c2                	mov    %eax,%edx
  80127b:	c1 ea 0c             	shr    $0xc,%edx
  80127e:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801285:	f6 c2 01             	test   $0x1,%dl
  801288:	75 17                	jne    8012a1 <fd_alloc+0x59>
  80128a:	eb 0c                	jmp    801298 <fd_alloc+0x50>
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  80128c:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
  801291:	eb 05                	jmp    801298 <fd_alloc+0x50>
  801293:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
  801298:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  80129a:	b8 00 00 00 00       	mov    $0x0,%eax
  80129f:	eb 17                	jmp    8012b8 <fd_alloc+0x70>
  8012a1:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8012a6:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8012ab:	75 b9                	jne    801266 <fd_alloc+0x1e>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8012ad:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  8012b3:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8012b8:	5b                   	pop    %ebx
  8012b9:	c9                   	leave  
  8012ba:	c3                   	ret    

008012bb <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8012bb:	55                   	push   %ebp
  8012bc:	89 e5                	mov    %esp,%ebp
  8012be:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8012c1:	83 f8 1f             	cmp    $0x1f,%eax
  8012c4:	77 36                	ja     8012fc <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8012c6:	05 00 00 0d 00       	add    $0xd0000,%eax
  8012cb:	c1 e0 0c             	shl    $0xc,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8012ce:	89 c2                	mov    %eax,%edx
  8012d0:	c1 ea 16             	shr    $0x16,%edx
  8012d3:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8012da:	f6 c2 01             	test   $0x1,%dl
  8012dd:	74 24                	je     801303 <fd_lookup+0x48>
  8012df:	89 c2                	mov    %eax,%edx
  8012e1:	c1 ea 0c             	shr    $0xc,%edx
  8012e4:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8012eb:	f6 c2 01             	test   $0x1,%dl
  8012ee:	74 1a                	je     80130a <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8012f0:	8b 55 0c             	mov    0xc(%ebp),%edx
  8012f3:	89 02                	mov    %eax,(%edx)
	return 0;
  8012f5:	b8 00 00 00 00       	mov    $0x0,%eax
  8012fa:	eb 13                	jmp    80130f <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8012fc:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801301:	eb 0c                	jmp    80130f <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801303:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801308:	eb 05                	jmp    80130f <fd_lookup+0x54>
  80130a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  80130f:	c9                   	leave  
  801310:	c3                   	ret    

00801311 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801311:	55                   	push   %ebp
  801312:	89 e5                	mov    %esp,%ebp
  801314:	53                   	push   %ebx
  801315:	83 ec 04             	sub    $0x4,%esp
  801318:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80131b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  80131e:	39 0d 04 30 80 00    	cmp    %ecx,0x803004
  801324:	74 0d                	je     801333 <dev_lookup+0x22>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801326:	b8 00 00 00 00       	mov    $0x0,%eax
  80132b:	eb 14                	jmp    801341 <dev_lookup+0x30>
		if (devtab[i]->dev_id == dev_id) {
  80132d:	39 0a                	cmp    %ecx,(%edx)
  80132f:	75 10                	jne    801341 <dev_lookup+0x30>
  801331:	eb 05                	jmp    801338 <dev_lookup+0x27>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801333:	ba 04 30 80 00       	mov    $0x803004,%edx
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
  801338:	89 13                	mov    %edx,(%ebx)
			return 0;
  80133a:	b8 00 00 00 00       	mov    $0x0,%eax
  80133f:	eb 31                	jmp    801372 <dev_lookup+0x61>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801341:	40                   	inc    %eax
  801342:	8b 14 85 a8 27 80 00 	mov    0x8027a8(,%eax,4),%edx
  801349:	85 d2                	test   %edx,%edx
  80134b:	75 e0                	jne    80132d <dev_lookup+0x1c>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80134d:	a1 04 40 80 00       	mov    0x804004,%eax
  801352:	8b 40 48             	mov    0x48(%eax),%eax
  801355:	83 ec 04             	sub    $0x4,%esp
  801358:	51                   	push   %ecx
  801359:	50                   	push   %eax
  80135a:	68 2c 27 80 00       	push   $0x80272c
  80135f:	e8 d8 ee ff ff       	call   80023c <cprintf>
	*dev = 0;
  801364:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  80136a:	83 c4 10             	add    $0x10,%esp
  80136d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801372:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801375:	c9                   	leave  
  801376:	c3                   	ret    

00801377 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801377:	55                   	push   %ebp
  801378:	89 e5                	mov    %esp,%ebp
  80137a:	56                   	push   %esi
  80137b:	53                   	push   %ebx
  80137c:	83 ec 20             	sub    $0x20,%esp
  80137f:	8b 75 08             	mov    0x8(%ebp),%esi
  801382:	8a 45 0c             	mov    0xc(%ebp),%al
  801385:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801388:	56                   	push   %esi
  801389:	e8 92 fe ff ff       	call   801220 <fd2num>
  80138e:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801391:	89 14 24             	mov    %edx,(%esp)
  801394:	50                   	push   %eax
  801395:	e8 21 ff ff ff       	call   8012bb <fd_lookup>
  80139a:	89 c3                	mov    %eax,%ebx
  80139c:	83 c4 08             	add    $0x8,%esp
  80139f:	85 c0                	test   %eax,%eax
  8013a1:	78 05                	js     8013a8 <fd_close+0x31>
	    || fd != fd2)
  8013a3:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8013a6:	74 0d                	je     8013b5 <fd_close+0x3e>
		return (must_exist ? r : 0);
  8013a8:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  8013ac:	75 48                	jne    8013f6 <fd_close+0x7f>
  8013ae:	bb 00 00 00 00       	mov    $0x0,%ebx
  8013b3:	eb 41                	jmp    8013f6 <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8013b5:	83 ec 08             	sub    $0x8,%esp
  8013b8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8013bb:	50                   	push   %eax
  8013bc:	ff 36                	pushl  (%esi)
  8013be:	e8 4e ff ff ff       	call   801311 <dev_lookup>
  8013c3:	89 c3                	mov    %eax,%ebx
  8013c5:	83 c4 10             	add    $0x10,%esp
  8013c8:	85 c0                	test   %eax,%eax
  8013ca:	78 1c                	js     8013e8 <fd_close+0x71>
		if (dev->dev_close)
  8013cc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013cf:	8b 40 10             	mov    0x10(%eax),%eax
  8013d2:	85 c0                	test   %eax,%eax
  8013d4:	74 0d                	je     8013e3 <fd_close+0x6c>
			r = (*dev->dev_close)(fd);
  8013d6:	83 ec 0c             	sub    $0xc,%esp
  8013d9:	56                   	push   %esi
  8013da:	ff d0                	call   *%eax
  8013dc:	89 c3                	mov    %eax,%ebx
  8013de:	83 c4 10             	add    $0x10,%esp
  8013e1:	eb 05                	jmp    8013e8 <fd_close+0x71>
		else
			r = 0;
  8013e3:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8013e8:	83 ec 08             	sub    $0x8,%esp
  8013eb:	56                   	push   %esi
  8013ec:	6a 00                	push   $0x0
  8013ee:	e8 cb f8 ff ff       	call   800cbe <sys_page_unmap>
	return r;
  8013f3:	83 c4 10             	add    $0x10,%esp
}
  8013f6:	89 d8                	mov    %ebx,%eax
  8013f8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8013fb:	5b                   	pop    %ebx
  8013fc:	5e                   	pop    %esi
  8013fd:	c9                   	leave  
  8013fe:	c3                   	ret    

008013ff <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8013ff:	55                   	push   %ebp
  801400:	89 e5                	mov    %esp,%ebp
  801402:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801405:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801408:	50                   	push   %eax
  801409:	ff 75 08             	pushl  0x8(%ebp)
  80140c:	e8 aa fe ff ff       	call   8012bb <fd_lookup>
  801411:	83 c4 08             	add    $0x8,%esp
  801414:	85 c0                	test   %eax,%eax
  801416:	78 10                	js     801428 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801418:	83 ec 08             	sub    $0x8,%esp
  80141b:	6a 01                	push   $0x1
  80141d:	ff 75 f4             	pushl  -0xc(%ebp)
  801420:	e8 52 ff ff ff       	call   801377 <fd_close>
  801425:	83 c4 10             	add    $0x10,%esp
}
  801428:	c9                   	leave  
  801429:	c3                   	ret    

0080142a <close_all>:

void
close_all(void)
{
  80142a:	55                   	push   %ebp
  80142b:	89 e5                	mov    %esp,%ebp
  80142d:	53                   	push   %ebx
  80142e:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801431:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801436:	83 ec 0c             	sub    $0xc,%esp
  801439:	53                   	push   %ebx
  80143a:	e8 c0 ff ff ff       	call   8013ff <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80143f:	43                   	inc    %ebx
  801440:	83 c4 10             	add    $0x10,%esp
  801443:	83 fb 20             	cmp    $0x20,%ebx
  801446:	75 ee                	jne    801436 <close_all+0xc>
		close(i);
}
  801448:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80144b:	c9                   	leave  
  80144c:	c3                   	ret    

0080144d <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80144d:	55                   	push   %ebp
  80144e:	89 e5                	mov    %esp,%ebp
  801450:	57                   	push   %edi
  801451:	56                   	push   %esi
  801452:	53                   	push   %ebx
  801453:	83 ec 2c             	sub    $0x2c,%esp
  801456:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801459:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80145c:	50                   	push   %eax
  80145d:	ff 75 08             	pushl  0x8(%ebp)
  801460:	e8 56 fe ff ff       	call   8012bb <fd_lookup>
  801465:	89 c3                	mov    %eax,%ebx
  801467:	83 c4 08             	add    $0x8,%esp
  80146a:	85 c0                	test   %eax,%eax
  80146c:	0f 88 c0 00 00 00    	js     801532 <dup+0xe5>
		return r;
	close(newfdnum);
  801472:	83 ec 0c             	sub    $0xc,%esp
  801475:	57                   	push   %edi
  801476:	e8 84 ff ff ff       	call   8013ff <close>

	newfd = INDEX2FD(newfdnum);
  80147b:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  801481:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  801484:	83 c4 04             	add    $0x4,%esp
  801487:	ff 75 e4             	pushl  -0x1c(%ebp)
  80148a:	e8 a1 fd ff ff       	call   801230 <fd2data>
  80148f:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801491:	89 34 24             	mov    %esi,(%esp)
  801494:	e8 97 fd ff ff       	call   801230 <fd2data>
  801499:	83 c4 10             	add    $0x10,%esp
  80149c:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80149f:	89 d8                	mov    %ebx,%eax
  8014a1:	c1 e8 16             	shr    $0x16,%eax
  8014a4:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8014ab:	a8 01                	test   $0x1,%al
  8014ad:	74 37                	je     8014e6 <dup+0x99>
  8014af:	89 d8                	mov    %ebx,%eax
  8014b1:	c1 e8 0c             	shr    $0xc,%eax
  8014b4:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8014bb:	f6 c2 01             	test   $0x1,%dl
  8014be:	74 26                	je     8014e6 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8014c0:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8014c7:	83 ec 0c             	sub    $0xc,%esp
  8014ca:	25 07 0e 00 00       	and    $0xe07,%eax
  8014cf:	50                   	push   %eax
  8014d0:	ff 75 d4             	pushl  -0x2c(%ebp)
  8014d3:	6a 00                	push   $0x0
  8014d5:	53                   	push   %ebx
  8014d6:	6a 00                	push   $0x0
  8014d8:	e8 bb f7 ff ff       	call   800c98 <sys_page_map>
  8014dd:	89 c3                	mov    %eax,%ebx
  8014df:	83 c4 20             	add    $0x20,%esp
  8014e2:	85 c0                	test   %eax,%eax
  8014e4:	78 2d                	js     801513 <dup+0xc6>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8014e6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8014e9:	89 c2                	mov    %eax,%edx
  8014eb:	c1 ea 0c             	shr    $0xc,%edx
  8014ee:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8014f5:	83 ec 0c             	sub    $0xc,%esp
  8014f8:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  8014fe:	52                   	push   %edx
  8014ff:	56                   	push   %esi
  801500:	6a 00                	push   $0x0
  801502:	50                   	push   %eax
  801503:	6a 00                	push   $0x0
  801505:	e8 8e f7 ff ff       	call   800c98 <sys_page_map>
  80150a:	89 c3                	mov    %eax,%ebx
  80150c:	83 c4 20             	add    $0x20,%esp
  80150f:	85 c0                	test   %eax,%eax
  801511:	79 1d                	jns    801530 <dup+0xe3>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801513:	83 ec 08             	sub    $0x8,%esp
  801516:	56                   	push   %esi
  801517:	6a 00                	push   $0x0
  801519:	e8 a0 f7 ff ff       	call   800cbe <sys_page_unmap>
	sys_page_unmap(0, nva);
  80151e:	83 c4 08             	add    $0x8,%esp
  801521:	ff 75 d4             	pushl  -0x2c(%ebp)
  801524:	6a 00                	push   $0x0
  801526:	e8 93 f7 ff ff       	call   800cbe <sys_page_unmap>
	return r;
  80152b:	83 c4 10             	add    $0x10,%esp
  80152e:	eb 02                	jmp    801532 <dup+0xe5>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  801530:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  801532:	89 d8                	mov    %ebx,%eax
  801534:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801537:	5b                   	pop    %ebx
  801538:	5e                   	pop    %esi
  801539:	5f                   	pop    %edi
  80153a:	c9                   	leave  
  80153b:	c3                   	ret    

0080153c <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80153c:	55                   	push   %ebp
  80153d:	89 e5                	mov    %esp,%ebp
  80153f:	53                   	push   %ebx
  801540:	83 ec 14             	sub    $0x14,%esp
  801543:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801546:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801549:	50                   	push   %eax
  80154a:	53                   	push   %ebx
  80154b:	e8 6b fd ff ff       	call   8012bb <fd_lookup>
  801550:	83 c4 08             	add    $0x8,%esp
  801553:	85 c0                	test   %eax,%eax
  801555:	78 67                	js     8015be <read+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801557:	83 ec 08             	sub    $0x8,%esp
  80155a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80155d:	50                   	push   %eax
  80155e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801561:	ff 30                	pushl  (%eax)
  801563:	e8 a9 fd ff ff       	call   801311 <dev_lookup>
  801568:	83 c4 10             	add    $0x10,%esp
  80156b:	85 c0                	test   %eax,%eax
  80156d:	78 4f                	js     8015be <read+0x82>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80156f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801572:	8b 50 08             	mov    0x8(%eax),%edx
  801575:	83 e2 03             	and    $0x3,%edx
  801578:	83 fa 01             	cmp    $0x1,%edx
  80157b:	75 21                	jne    80159e <read+0x62>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80157d:	a1 04 40 80 00       	mov    0x804004,%eax
  801582:	8b 40 48             	mov    0x48(%eax),%eax
  801585:	83 ec 04             	sub    $0x4,%esp
  801588:	53                   	push   %ebx
  801589:	50                   	push   %eax
  80158a:	68 6d 27 80 00       	push   $0x80276d
  80158f:	e8 a8 ec ff ff       	call   80023c <cprintf>
		return -E_INVAL;
  801594:	83 c4 10             	add    $0x10,%esp
  801597:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80159c:	eb 20                	jmp    8015be <read+0x82>
	}
	if (!dev->dev_read)
  80159e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8015a1:	8b 52 08             	mov    0x8(%edx),%edx
  8015a4:	85 d2                	test   %edx,%edx
  8015a6:	74 11                	je     8015b9 <read+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8015a8:	83 ec 04             	sub    $0x4,%esp
  8015ab:	ff 75 10             	pushl  0x10(%ebp)
  8015ae:	ff 75 0c             	pushl  0xc(%ebp)
  8015b1:	50                   	push   %eax
  8015b2:	ff d2                	call   *%edx
  8015b4:	83 c4 10             	add    $0x10,%esp
  8015b7:	eb 05                	jmp    8015be <read+0x82>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8015b9:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  8015be:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015c1:	c9                   	leave  
  8015c2:	c3                   	ret    

008015c3 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8015c3:	55                   	push   %ebp
  8015c4:	89 e5                	mov    %esp,%ebp
  8015c6:	57                   	push   %edi
  8015c7:	56                   	push   %esi
  8015c8:	53                   	push   %ebx
  8015c9:	83 ec 0c             	sub    $0xc,%esp
  8015cc:	8b 7d 08             	mov    0x8(%ebp),%edi
  8015cf:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8015d2:	85 f6                	test   %esi,%esi
  8015d4:	74 31                	je     801607 <readn+0x44>
  8015d6:	b8 00 00 00 00       	mov    $0x0,%eax
  8015db:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = read(fdnum, (char*)buf + tot, n - tot);
  8015e0:	83 ec 04             	sub    $0x4,%esp
  8015e3:	89 f2                	mov    %esi,%edx
  8015e5:	29 c2                	sub    %eax,%edx
  8015e7:	52                   	push   %edx
  8015e8:	03 45 0c             	add    0xc(%ebp),%eax
  8015eb:	50                   	push   %eax
  8015ec:	57                   	push   %edi
  8015ed:	e8 4a ff ff ff       	call   80153c <read>
		if (m < 0)
  8015f2:	83 c4 10             	add    $0x10,%esp
  8015f5:	85 c0                	test   %eax,%eax
  8015f7:	78 17                	js     801610 <readn+0x4d>
			return m;
		if (m == 0)
  8015f9:	85 c0                	test   %eax,%eax
  8015fb:	74 11                	je     80160e <readn+0x4b>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8015fd:	01 c3                	add    %eax,%ebx
  8015ff:	89 d8                	mov    %ebx,%eax
  801601:	39 f3                	cmp    %esi,%ebx
  801603:	72 db                	jb     8015e0 <readn+0x1d>
  801605:	eb 09                	jmp    801610 <readn+0x4d>
  801607:	b8 00 00 00 00       	mov    $0x0,%eax
  80160c:	eb 02                	jmp    801610 <readn+0x4d>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  80160e:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  801610:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801613:	5b                   	pop    %ebx
  801614:	5e                   	pop    %esi
  801615:	5f                   	pop    %edi
  801616:	c9                   	leave  
  801617:	c3                   	ret    

00801618 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801618:	55                   	push   %ebp
  801619:	89 e5                	mov    %esp,%ebp
  80161b:	53                   	push   %ebx
  80161c:	83 ec 14             	sub    $0x14,%esp
  80161f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801622:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801625:	50                   	push   %eax
  801626:	53                   	push   %ebx
  801627:	e8 8f fc ff ff       	call   8012bb <fd_lookup>
  80162c:	83 c4 08             	add    $0x8,%esp
  80162f:	85 c0                	test   %eax,%eax
  801631:	78 62                	js     801695 <write+0x7d>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801633:	83 ec 08             	sub    $0x8,%esp
  801636:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801639:	50                   	push   %eax
  80163a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80163d:	ff 30                	pushl  (%eax)
  80163f:	e8 cd fc ff ff       	call   801311 <dev_lookup>
  801644:	83 c4 10             	add    $0x10,%esp
  801647:	85 c0                	test   %eax,%eax
  801649:	78 4a                	js     801695 <write+0x7d>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80164b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80164e:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801652:	75 21                	jne    801675 <write+0x5d>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801654:	a1 04 40 80 00       	mov    0x804004,%eax
  801659:	8b 40 48             	mov    0x48(%eax),%eax
  80165c:	83 ec 04             	sub    $0x4,%esp
  80165f:	53                   	push   %ebx
  801660:	50                   	push   %eax
  801661:	68 89 27 80 00       	push   $0x802789
  801666:	e8 d1 eb ff ff       	call   80023c <cprintf>
		return -E_INVAL;
  80166b:	83 c4 10             	add    $0x10,%esp
  80166e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801673:	eb 20                	jmp    801695 <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801675:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801678:	8b 52 0c             	mov    0xc(%edx),%edx
  80167b:	85 d2                	test   %edx,%edx
  80167d:	74 11                	je     801690 <write+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80167f:	83 ec 04             	sub    $0x4,%esp
  801682:	ff 75 10             	pushl  0x10(%ebp)
  801685:	ff 75 0c             	pushl  0xc(%ebp)
  801688:	50                   	push   %eax
  801689:	ff d2                	call   *%edx
  80168b:	83 c4 10             	add    $0x10,%esp
  80168e:	eb 05                	jmp    801695 <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801690:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  801695:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801698:	c9                   	leave  
  801699:	c3                   	ret    

0080169a <seek>:

int
seek(int fdnum, off_t offset)
{
  80169a:	55                   	push   %ebp
  80169b:	89 e5                	mov    %esp,%ebp
  80169d:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8016a0:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8016a3:	50                   	push   %eax
  8016a4:	ff 75 08             	pushl  0x8(%ebp)
  8016a7:	e8 0f fc ff ff       	call   8012bb <fd_lookup>
  8016ac:	83 c4 08             	add    $0x8,%esp
  8016af:	85 c0                	test   %eax,%eax
  8016b1:	78 0e                	js     8016c1 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8016b3:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8016b6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8016b9:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8016bc:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8016c1:	c9                   	leave  
  8016c2:	c3                   	ret    

008016c3 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8016c3:	55                   	push   %ebp
  8016c4:	89 e5                	mov    %esp,%ebp
  8016c6:	53                   	push   %ebx
  8016c7:	83 ec 14             	sub    $0x14,%esp
  8016ca:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016cd:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016d0:	50                   	push   %eax
  8016d1:	53                   	push   %ebx
  8016d2:	e8 e4 fb ff ff       	call   8012bb <fd_lookup>
  8016d7:	83 c4 08             	add    $0x8,%esp
  8016da:	85 c0                	test   %eax,%eax
  8016dc:	78 5f                	js     80173d <ftruncate+0x7a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016de:	83 ec 08             	sub    $0x8,%esp
  8016e1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016e4:	50                   	push   %eax
  8016e5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016e8:	ff 30                	pushl  (%eax)
  8016ea:	e8 22 fc ff ff       	call   801311 <dev_lookup>
  8016ef:	83 c4 10             	add    $0x10,%esp
  8016f2:	85 c0                	test   %eax,%eax
  8016f4:	78 47                	js     80173d <ftruncate+0x7a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8016f6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016f9:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8016fd:	75 21                	jne    801720 <ftruncate+0x5d>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8016ff:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801704:	8b 40 48             	mov    0x48(%eax),%eax
  801707:	83 ec 04             	sub    $0x4,%esp
  80170a:	53                   	push   %ebx
  80170b:	50                   	push   %eax
  80170c:	68 4c 27 80 00       	push   $0x80274c
  801711:	e8 26 eb ff ff       	call   80023c <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801716:	83 c4 10             	add    $0x10,%esp
  801719:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80171e:	eb 1d                	jmp    80173d <ftruncate+0x7a>
	}
	if (!dev->dev_trunc)
  801720:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801723:	8b 52 18             	mov    0x18(%edx),%edx
  801726:	85 d2                	test   %edx,%edx
  801728:	74 0e                	je     801738 <ftruncate+0x75>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80172a:	83 ec 08             	sub    $0x8,%esp
  80172d:	ff 75 0c             	pushl  0xc(%ebp)
  801730:	50                   	push   %eax
  801731:	ff d2                	call   *%edx
  801733:	83 c4 10             	add    $0x10,%esp
  801736:	eb 05                	jmp    80173d <ftruncate+0x7a>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801738:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  80173d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801740:	c9                   	leave  
  801741:	c3                   	ret    

00801742 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801742:	55                   	push   %ebp
  801743:	89 e5                	mov    %esp,%ebp
  801745:	53                   	push   %ebx
  801746:	83 ec 14             	sub    $0x14,%esp
  801749:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80174c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80174f:	50                   	push   %eax
  801750:	ff 75 08             	pushl  0x8(%ebp)
  801753:	e8 63 fb ff ff       	call   8012bb <fd_lookup>
  801758:	83 c4 08             	add    $0x8,%esp
  80175b:	85 c0                	test   %eax,%eax
  80175d:	78 52                	js     8017b1 <fstat+0x6f>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80175f:	83 ec 08             	sub    $0x8,%esp
  801762:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801765:	50                   	push   %eax
  801766:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801769:	ff 30                	pushl  (%eax)
  80176b:	e8 a1 fb ff ff       	call   801311 <dev_lookup>
  801770:	83 c4 10             	add    $0x10,%esp
  801773:	85 c0                	test   %eax,%eax
  801775:	78 3a                	js     8017b1 <fstat+0x6f>
		return r;
	if (!dev->dev_stat)
  801777:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80177a:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80177e:	74 2c                	je     8017ac <fstat+0x6a>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801780:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801783:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80178a:	00 00 00 
	stat->st_isdir = 0;
  80178d:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801794:	00 00 00 
	stat->st_dev = dev;
  801797:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80179d:	83 ec 08             	sub    $0x8,%esp
  8017a0:	53                   	push   %ebx
  8017a1:	ff 75 f0             	pushl  -0x10(%ebp)
  8017a4:	ff 50 14             	call   *0x14(%eax)
  8017a7:	83 c4 10             	add    $0x10,%esp
  8017aa:	eb 05                	jmp    8017b1 <fstat+0x6f>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8017ac:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8017b1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017b4:	c9                   	leave  
  8017b5:	c3                   	ret    

008017b6 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8017b6:	55                   	push   %ebp
  8017b7:	89 e5                	mov    %esp,%ebp
  8017b9:	56                   	push   %esi
  8017ba:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8017bb:	83 ec 08             	sub    $0x8,%esp
  8017be:	6a 00                	push   $0x0
  8017c0:	ff 75 08             	pushl  0x8(%ebp)
  8017c3:	e8 78 01 00 00       	call   801940 <open>
  8017c8:	89 c3                	mov    %eax,%ebx
  8017ca:	83 c4 10             	add    $0x10,%esp
  8017cd:	85 c0                	test   %eax,%eax
  8017cf:	78 1b                	js     8017ec <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8017d1:	83 ec 08             	sub    $0x8,%esp
  8017d4:	ff 75 0c             	pushl  0xc(%ebp)
  8017d7:	50                   	push   %eax
  8017d8:	e8 65 ff ff ff       	call   801742 <fstat>
  8017dd:	89 c6                	mov    %eax,%esi
	close(fd);
  8017df:	89 1c 24             	mov    %ebx,(%esp)
  8017e2:	e8 18 fc ff ff       	call   8013ff <close>
	return r;
  8017e7:	83 c4 10             	add    $0x10,%esp
  8017ea:	89 f3                	mov    %esi,%ebx
}
  8017ec:	89 d8                	mov    %ebx,%eax
  8017ee:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017f1:	5b                   	pop    %ebx
  8017f2:	5e                   	pop    %esi
  8017f3:	c9                   	leave  
  8017f4:	c3                   	ret    
  8017f5:	00 00                	add    %al,(%eax)
	...

008017f8 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8017f8:	55                   	push   %ebp
  8017f9:	89 e5                	mov    %esp,%ebp
  8017fb:	56                   	push   %esi
  8017fc:	53                   	push   %ebx
  8017fd:	89 c3                	mov    %eax,%ebx
  8017ff:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  801801:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801808:	75 12                	jne    80181c <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80180a:	83 ec 0c             	sub    $0xc,%esp
  80180d:	6a 01                	push   $0x1
  80180f:	e8 ae f9 ff ff       	call   8011c2 <ipc_find_env>
  801814:	a3 00 40 80 00       	mov    %eax,0x804000
  801819:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80181c:	6a 07                	push   $0x7
  80181e:	68 00 50 80 00       	push   $0x805000
  801823:	53                   	push   %ebx
  801824:	ff 35 00 40 80 00    	pushl  0x804000
  80182a:	e8 3e f9 ff ff       	call   80116d <ipc_send>
	
	return ipc_recv(NULL, dstva, NULL);
  80182f:	83 c4 0c             	add    $0xc,%esp
  801832:	6a 00                	push   $0x0
  801834:	56                   	push   %esi
  801835:	6a 00                	push   $0x0
  801837:	e8 bc f8 ff ff       	call   8010f8 <ipc_recv>
}
  80183c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80183f:	5b                   	pop    %ebx
  801840:	5e                   	pop    %esi
  801841:	c9                   	leave  
  801842:	c3                   	ret    

00801843 <devfile_stat>:
}


static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801843:	55                   	push   %ebp
  801844:	89 e5                	mov    %esp,%ebp
  801846:	53                   	push   %ebx
  801847:	83 ec 04             	sub    $0x4,%esp
  80184a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80184d:	8b 45 08             	mov    0x8(%ebp),%eax
  801850:	8b 40 0c             	mov    0xc(%eax),%eax
  801853:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0) {
  801858:	ba 00 00 00 00       	mov    $0x0,%edx
  80185d:	b8 05 00 00 00       	mov    $0x5,%eax
  801862:	e8 91 ff ff ff       	call   8017f8 <fsipc>
  801867:	85 c0                	test   %eax,%eax
  801869:	78 2c                	js     801897 <devfile_stat+0x54>
		return r;
	}
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80186b:	83 ec 08             	sub    $0x8,%esp
  80186e:	68 00 50 80 00       	push   $0x805000
  801873:	53                   	push   %ebx
  801874:	e8 79 ef ff ff       	call   8007f2 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801879:	a1 80 50 80 00       	mov    0x805080,%eax
  80187e:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801884:	a1 84 50 80 00       	mov    0x805084,%eax
  801889:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80188f:	83 c4 10             	add    $0x10,%esp
  801892:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801897:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80189a:	c9                   	leave  
  80189b:	c3                   	ret    

0080189c <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80189c:	55                   	push   %ebp
  80189d:	89 e5                	mov    %esp,%ebp
  80189f:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8018a2:	8b 45 08             	mov    0x8(%ebp),%eax
  8018a5:	8b 40 0c             	mov    0xc(%eax),%eax
  8018a8:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8018ad:	ba 00 00 00 00       	mov    $0x0,%edx
  8018b2:	b8 06 00 00 00       	mov    $0x6,%eax
  8018b7:	e8 3c ff ff ff       	call   8017f8 <fsipc>
}
  8018bc:	c9                   	leave  
  8018bd:	c3                   	ret    

008018be <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8018be:	55                   	push   %ebp
  8018bf:	89 e5                	mov    %esp,%ebp
  8018c1:	56                   	push   %esi
  8018c2:	53                   	push   %ebx
  8018c3:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8018c6:	8b 45 08             	mov    0x8(%ebp),%eax
  8018c9:	8b 40 0c             	mov    0xc(%eax),%eax
  8018cc:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8018d1:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8018d7:	ba 00 00 00 00       	mov    $0x0,%edx
  8018dc:	b8 03 00 00 00       	mov    $0x3,%eax
  8018e1:	e8 12 ff ff ff       	call   8017f8 <fsipc>
  8018e6:	89 c3                	mov    %eax,%ebx
  8018e8:	85 c0                	test   %eax,%eax
  8018ea:	78 4b                	js     801937 <devfile_read+0x79>
		return r;
	assert(r <= n);
  8018ec:	39 c6                	cmp    %eax,%esi
  8018ee:	73 16                	jae    801906 <devfile_read+0x48>
  8018f0:	68 b8 27 80 00       	push   $0x8027b8
  8018f5:	68 bf 27 80 00       	push   $0x8027bf
  8018fa:	6a 7d                	push   $0x7d
  8018fc:	68 d4 27 80 00       	push   $0x8027d4
  801901:	e8 5e e8 ff ff       	call   800164 <_panic>
	assert(r <= PGSIZE);
  801906:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80190b:	7e 16                	jle    801923 <devfile_read+0x65>
  80190d:	68 df 27 80 00       	push   $0x8027df
  801912:	68 bf 27 80 00       	push   $0x8027bf
  801917:	6a 7e                	push   $0x7e
  801919:	68 d4 27 80 00       	push   $0x8027d4
  80191e:	e8 41 e8 ff ff       	call   800164 <_panic>
	memmove(buf, &fsipcbuf, r);
  801923:	83 ec 04             	sub    $0x4,%esp
  801926:	50                   	push   %eax
  801927:	68 00 50 80 00       	push   $0x805000
  80192c:	ff 75 0c             	pushl  0xc(%ebp)
  80192f:	e8 7f f0 ff ff       	call   8009b3 <memmove>
	return r;
  801934:	83 c4 10             	add    $0x10,%esp
}
  801937:	89 d8                	mov    %ebx,%eax
  801939:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80193c:	5b                   	pop    %ebx
  80193d:	5e                   	pop    %esi
  80193e:	c9                   	leave  
  80193f:	c3                   	ret    

00801940 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801940:	55                   	push   %ebp
  801941:	89 e5                	mov    %esp,%ebp
  801943:	56                   	push   %esi
  801944:	53                   	push   %ebx
  801945:	83 ec 1c             	sub    $0x1c,%esp
  801948:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  80194b:	56                   	push   %esi
  80194c:	e8 4f ee ff ff       	call   8007a0 <strlen>
  801951:	83 c4 10             	add    $0x10,%esp
  801954:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801959:	7f 65                	jg     8019c0 <open+0x80>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80195b:	83 ec 0c             	sub    $0xc,%esp
  80195e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801961:	50                   	push   %eax
  801962:	e8 e1 f8 ff ff       	call   801248 <fd_alloc>
  801967:	89 c3                	mov    %eax,%ebx
  801969:	83 c4 10             	add    $0x10,%esp
  80196c:	85 c0                	test   %eax,%eax
  80196e:	78 55                	js     8019c5 <open+0x85>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801970:	83 ec 08             	sub    $0x8,%esp
  801973:	56                   	push   %esi
  801974:	68 00 50 80 00       	push   $0x805000
  801979:	e8 74 ee ff ff       	call   8007f2 <strcpy>
	fsipcbuf.open.req_omode = mode;
  80197e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801981:	a3 00 54 80 00       	mov    %eax,0x805400



	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801986:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801989:	b8 01 00 00 00       	mov    $0x1,%eax
  80198e:	e8 65 fe ff ff       	call   8017f8 <fsipc>
  801993:	89 c3                	mov    %eax,%ebx
  801995:	83 c4 10             	add    $0x10,%esp
  801998:	85 c0                	test   %eax,%eax
  80199a:	79 12                	jns    8019ae <open+0x6e>
		fd_close(fd, 0);
  80199c:	83 ec 08             	sub    $0x8,%esp
  80199f:	6a 00                	push   $0x0
  8019a1:	ff 75 f4             	pushl  -0xc(%ebp)
  8019a4:	e8 ce f9 ff ff       	call   801377 <fd_close>
		return r;
  8019a9:	83 c4 10             	add    $0x10,%esp
  8019ac:	eb 17                	jmp    8019c5 <open+0x85>
	}

	return fd2num(fd);
  8019ae:	83 ec 0c             	sub    $0xc,%esp
  8019b1:	ff 75 f4             	pushl  -0xc(%ebp)
  8019b4:	e8 67 f8 ff ff       	call   801220 <fd2num>
  8019b9:	89 c3                	mov    %eax,%ebx
  8019bb:	83 c4 10             	add    $0x10,%esp
  8019be:	eb 05                	jmp    8019c5 <open+0x85>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8019c0:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8019c5:	89 d8                	mov    %ebx,%eax
  8019c7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8019ca:	5b                   	pop    %ebx
  8019cb:	5e                   	pop    %esi
  8019cc:	c9                   	leave  
  8019cd:	c3                   	ret    
	...

008019d0 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8019d0:	55                   	push   %ebp
  8019d1:	89 e5                	mov    %esp,%ebp
  8019d3:	56                   	push   %esi
  8019d4:	53                   	push   %ebx
  8019d5:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8019d8:	83 ec 0c             	sub    $0xc,%esp
  8019db:	ff 75 08             	pushl  0x8(%ebp)
  8019de:	e8 4d f8 ff ff       	call   801230 <fd2data>
  8019e3:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  8019e5:	83 c4 08             	add    $0x8,%esp
  8019e8:	68 eb 27 80 00       	push   $0x8027eb
  8019ed:	56                   	push   %esi
  8019ee:	e8 ff ed ff ff       	call   8007f2 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8019f3:	8b 43 04             	mov    0x4(%ebx),%eax
  8019f6:	2b 03                	sub    (%ebx),%eax
  8019f8:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  8019fe:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  801a05:	00 00 00 
	stat->st_dev = &devpipe;
  801a08:	c7 86 88 00 00 00 20 	movl   $0x803020,0x88(%esi)
  801a0f:	30 80 00 
	return 0;
}
  801a12:	b8 00 00 00 00       	mov    $0x0,%eax
  801a17:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a1a:	5b                   	pop    %ebx
  801a1b:	5e                   	pop    %esi
  801a1c:	c9                   	leave  
  801a1d:	c3                   	ret    

00801a1e <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801a1e:	55                   	push   %ebp
  801a1f:	89 e5                	mov    %esp,%ebp
  801a21:	53                   	push   %ebx
  801a22:	83 ec 0c             	sub    $0xc,%esp
  801a25:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801a28:	53                   	push   %ebx
  801a29:	6a 00                	push   $0x0
  801a2b:	e8 8e f2 ff ff       	call   800cbe <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801a30:	89 1c 24             	mov    %ebx,(%esp)
  801a33:	e8 f8 f7 ff ff       	call   801230 <fd2data>
  801a38:	83 c4 08             	add    $0x8,%esp
  801a3b:	50                   	push   %eax
  801a3c:	6a 00                	push   $0x0
  801a3e:	e8 7b f2 ff ff       	call   800cbe <sys_page_unmap>
}
  801a43:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a46:	c9                   	leave  
  801a47:	c3                   	ret    

00801a48 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801a48:	55                   	push   %ebp
  801a49:	89 e5                	mov    %esp,%ebp
  801a4b:	57                   	push   %edi
  801a4c:	56                   	push   %esi
  801a4d:	53                   	push   %ebx
  801a4e:	83 ec 1c             	sub    $0x1c,%esp
  801a51:	89 c7                	mov    %eax,%edi
  801a53:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801a56:	a1 04 40 80 00       	mov    0x804004,%eax
  801a5b:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801a5e:	83 ec 0c             	sub    $0xc,%esp
  801a61:	57                   	push   %edi
  801a62:	e8 01 05 00 00       	call   801f68 <pageref>
  801a67:	89 c6                	mov    %eax,%esi
  801a69:	83 c4 04             	add    $0x4,%esp
  801a6c:	ff 75 e4             	pushl  -0x1c(%ebp)
  801a6f:	e8 f4 04 00 00       	call   801f68 <pageref>
  801a74:	83 c4 10             	add    $0x10,%esp
  801a77:	39 c6                	cmp    %eax,%esi
  801a79:	0f 94 c0             	sete   %al
  801a7c:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  801a7f:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801a85:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801a88:	39 cb                	cmp    %ecx,%ebx
  801a8a:	75 08                	jne    801a94 <_pipeisclosed+0x4c>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  801a8c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a8f:	5b                   	pop    %ebx
  801a90:	5e                   	pop    %esi
  801a91:	5f                   	pop    %edi
  801a92:	c9                   	leave  
  801a93:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  801a94:	83 f8 01             	cmp    $0x1,%eax
  801a97:	75 bd                	jne    801a56 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801a99:	8b 42 58             	mov    0x58(%edx),%eax
  801a9c:	6a 01                	push   $0x1
  801a9e:	50                   	push   %eax
  801a9f:	53                   	push   %ebx
  801aa0:	68 f2 27 80 00       	push   $0x8027f2
  801aa5:	e8 92 e7 ff ff       	call   80023c <cprintf>
  801aaa:	83 c4 10             	add    $0x10,%esp
  801aad:	eb a7                	jmp    801a56 <_pipeisclosed+0xe>

00801aaf <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801aaf:	55                   	push   %ebp
  801ab0:	89 e5                	mov    %esp,%ebp
  801ab2:	57                   	push   %edi
  801ab3:	56                   	push   %esi
  801ab4:	53                   	push   %ebx
  801ab5:	83 ec 28             	sub    $0x28,%esp
  801ab8:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801abb:	56                   	push   %esi
  801abc:	e8 6f f7 ff ff       	call   801230 <fd2data>
  801ac1:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801ac3:	83 c4 10             	add    $0x10,%esp
  801ac6:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801aca:	75 4a                	jne    801b16 <devpipe_write+0x67>
  801acc:	bf 00 00 00 00       	mov    $0x0,%edi
  801ad1:	eb 56                	jmp    801b29 <devpipe_write+0x7a>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801ad3:	89 da                	mov    %ebx,%edx
  801ad5:	89 f0                	mov    %esi,%eax
  801ad7:	e8 6c ff ff ff       	call   801a48 <_pipeisclosed>
  801adc:	85 c0                	test   %eax,%eax
  801ade:	75 4d                	jne    801b2d <devpipe_write+0x7e>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801ae0:	e8 68 f1 ff ff       	call   800c4d <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801ae5:	8b 43 04             	mov    0x4(%ebx),%eax
  801ae8:	8b 13                	mov    (%ebx),%edx
  801aea:	83 c2 20             	add    $0x20,%edx
  801aed:	39 d0                	cmp    %edx,%eax
  801aef:	73 e2                	jae    801ad3 <devpipe_write+0x24>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801af1:	89 c2                	mov    %eax,%edx
  801af3:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  801af9:	79 05                	jns    801b00 <devpipe_write+0x51>
  801afb:	4a                   	dec    %edx
  801afc:	83 ca e0             	or     $0xffffffe0,%edx
  801aff:	42                   	inc    %edx
  801b00:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b03:	8a 0c 39             	mov    (%ecx,%edi,1),%cl
  801b06:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801b0a:	40                   	inc    %eax
  801b0b:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b0e:	47                   	inc    %edi
  801b0f:	39 7d 10             	cmp    %edi,0x10(%ebp)
  801b12:	77 07                	ja     801b1b <devpipe_write+0x6c>
  801b14:	eb 13                	jmp    801b29 <devpipe_write+0x7a>
  801b16:	bf 00 00 00 00       	mov    $0x0,%edi
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801b1b:	8b 43 04             	mov    0x4(%ebx),%eax
  801b1e:	8b 13                	mov    (%ebx),%edx
  801b20:	83 c2 20             	add    $0x20,%edx
  801b23:	39 d0                	cmp    %edx,%eax
  801b25:	73 ac                	jae    801ad3 <devpipe_write+0x24>
  801b27:	eb c8                	jmp    801af1 <devpipe_write+0x42>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801b29:	89 f8                	mov    %edi,%eax
  801b2b:	eb 05                	jmp    801b32 <devpipe_write+0x83>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801b2d:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801b32:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b35:	5b                   	pop    %ebx
  801b36:	5e                   	pop    %esi
  801b37:	5f                   	pop    %edi
  801b38:	c9                   	leave  
  801b39:	c3                   	ret    

00801b3a <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801b3a:	55                   	push   %ebp
  801b3b:	89 e5                	mov    %esp,%ebp
  801b3d:	57                   	push   %edi
  801b3e:	56                   	push   %esi
  801b3f:	53                   	push   %ebx
  801b40:	83 ec 18             	sub    $0x18,%esp
  801b43:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801b46:	57                   	push   %edi
  801b47:	e8 e4 f6 ff ff       	call   801230 <fd2data>
  801b4c:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b4e:	83 c4 10             	add    $0x10,%esp
  801b51:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801b55:	75 44                	jne    801b9b <devpipe_read+0x61>
  801b57:	be 00 00 00 00       	mov    $0x0,%esi
  801b5c:	eb 4f                	jmp    801bad <devpipe_read+0x73>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
				return i;
  801b5e:	89 f0                	mov    %esi,%eax
  801b60:	eb 54                	jmp    801bb6 <devpipe_read+0x7c>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801b62:	89 da                	mov    %ebx,%edx
  801b64:	89 f8                	mov    %edi,%eax
  801b66:	e8 dd fe ff ff       	call   801a48 <_pipeisclosed>
  801b6b:	85 c0                	test   %eax,%eax
  801b6d:	75 42                	jne    801bb1 <devpipe_read+0x77>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801b6f:	e8 d9 f0 ff ff       	call   800c4d <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801b74:	8b 03                	mov    (%ebx),%eax
  801b76:	3b 43 04             	cmp    0x4(%ebx),%eax
  801b79:	74 e7                	je     801b62 <devpipe_read+0x28>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801b7b:	25 1f 00 00 80       	and    $0x8000001f,%eax
  801b80:	79 05                	jns    801b87 <devpipe_read+0x4d>
  801b82:	48                   	dec    %eax
  801b83:	83 c8 e0             	or     $0xffffffe0,%eax
  801b86:	40                   	inc    %eax
  801b87:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  801b8b:	8b 55 0c             	mov    0xc(%ebp),%edx
  801b8e:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  801b91:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b93:	46                   	inc    %esi
  801b94:	39 75 10             	cmp    %esi,0x10(%ebp)
  801b97:	77 07                	ja     801ba0 <devpipe_read+0x66>
  801b99:	eb 12                	jmp    801bad <devpipe_read+0x73>
  801b9b:	be 00 00 00 00       	mov    $0x0,%esi
		while (p->p_rpos == p->p_wpos) {
  801ba0:	8b 03                	mov    (%ebx),%eax
  801ba2:	3b 43 04             	cmp    0x4(%ebx),%eax
  801ba5:	75 d4                	jne    801b7b <devpipe_read+0x41>
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801ba7:	85 f6                	test   %esi,%esi
  801ba9:	75 b3                	jne    801b5e <devpipe_read+0x24>
  801bab:	eb b5                	jmp    801b62 <devpipe_read+0x28>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801bad:	89 f0                	mov    %esi,%eax
  801baf:	eb 05                	jmp    801bb6 <devpipe_read+0x7c>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801bb1:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801bb6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801bb9:	5b                   	pop    %ebx
  801bba:	5e                   	pop    %esi
  801bbb:	5f                   	pop    %edi
  801bbc:	c9                   	leave  
  801bbd:	c3                   	ret    

00801bbe <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801bbe:	55                   	push   %ebp
  801bbf:	89 e5                	mov    %esp,%ebp
  801bc1:	57                   	push   %edi
  801bc2:	56                   	push   %esi
  801bc3:	53                   	push   %ebx
  801bc4:	83 ec 28             	sub    $0x28,%esp
  801bc7:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801bca:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801bcd:	50                   	push   %eax
  801bce:	e8 75 f6 ff ff       	call   801248 <fd_alloc>
  801bd3:	89 c3                	mov    %eax,%ebx
  801bd5:	83 c4 10             	add    $0x10,%esp
  801bd8:	85 c0                	test   %eax,%eax
  801bda:	0f 88 24 01 00 00    	js     801d04 <pipe+0x146>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801be0:	83 ec 04             	sub    $0x4,%esp
  801be3:	68 07 04 00 00       	push   $0x407
  801be8:	ff 75 e4             	pushl  -0x1c(%ebp)
  801beb:	6a 00                	push   $0x0
  801bed:	e8 82 f0 ff ff       	call   800c74 <sys_page_alloc>
  801bf2:	89 c3                	mov    %eax,%ebx
  801bf4:	83 c4 10             	add    $0x10,%esp
  801bf7:	85 c0                	test   %eax,%eax
  801bf9:	0f 88 05 01 00 00    	js     801d04 <pipe+0x146>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801bff:	83 ec 0c             	sub    $0xc,%esp
  801c02:	8d 45 e0             	lea    -0x20(%ebp),%eax
  801c05:	50                   	push   %eax
  801c06:	e8 3d f6 ff ff       	call   801248 <fd_alloc>
  801c0b:	89 c3                	mov    %eax,%ebx
  801c0d:	83 c4 10             	add    $0x10,%esp
  801c10:	85 c0                	test   %eax,%eax
  801c12:	0f 88 dc 00 00 00    	js     801cf4 <pipe+0x136>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c18:	83 ec 04             	sub    $0x4,%esp
  801c1b:	68 07 04 00 00       	push   $0x407
  801c20:	ff 75 e0             	pushl  -0x20(%ebp)
  801c23:	6a 00                	push   $0x0
  801c25:	e8 4a f0 ff ff       	call   800c74 <sys_page_alloc>
  801c2a:	89 c3                	mov    %eax,%ebx
  801c2c:	83 c4 10             	add    $0x10,%esp
  801c2f:	85 c0                	test   %eax,%eax
  801c31:	0f 88 bd 00 00 00    	js     801cf4 <pipe+0x136>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801c37:	83 ec 0c             	sub    $0xc,%esp
  801c3a:	ff 75 e4             	pushl  -0x1c(%ebp)
  801c3d:	e8 ee f5 ff ff       	call   801230 <fd2data>
  801c42:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c44:	83 c4 0c             	add    $0xc,%esp
  801c47:	68 07 04 00 00       	push   $0x407
  801c4c:	50                   	push   %eax
  801c4d:	6a 00                	push   $0x0
  801c4f:	e8 20 f0 ff ff       	call   800c74 <sys_page_alloc>
  801c54:	89 c3                	mov    %eax,%ebx
  801c56:	83 c4 10             	add    $0x10,%esp
  801c59:	85 c0                	test   %eax,%eax
  801c5b:	0f 88 83 00 00 00    	js     801ce4 <pipe+0x126>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c61:	83 ec 0c             	sub    $0xc,%esp
  801c64:	ff 75 e0             	pushl  -0x20(%ebp)
  801c67:	e8 c4 f5 ff ff       	call   801230 <fd2data>
  801c6c:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801c73:	50                   	push   %eax
  801c74:	6a 00                	push   $0x0
  801c76:	56                   	push   %esi
  801c77:	6a 00                	push   $0x0
  801c79:	e8 1a f0 ff ff       	call   800c98 <sys_page_map>
  801c7e:	89 c3                	mov    %eax,%ebx
  801c80:	83 c4 20             	add    $0x20,%esp
  801c83:	85 c0                	test   %eax,%eax
  801c85:	78 4f                	js     801cd6 <pipe+0x118>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801c87:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801c8d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801c90:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801c92:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801c95:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801c9c:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801ca2:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801ca5:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801ca7:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801caa:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801cb1:	83 ec 0c             	sub    $0xc,%esp
  801cb4:	ff 75 e4             	pushl  -0x1c(%ebp)
  801cb7:	e8 64 f5 ff ff       	call   801220 <fd2num>
  801cbc:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  801cbe:	83 c4 04             	add    $0x4,%esp
  801cc1:	ff 75 e0             	pushl  -0x20(%ebp)
  801cc4:	e8 57 f5 ff ff       	call   801220 <fd2num>
  801cc9:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  801ccc:	83 c4 10             	add    $0x10,%esp
  801ccf:	bb 00 00 00 00       	mov    $0x0,%ebx
  801cd4:	eb 2e                	jmp    801d04 <pipe+0x146>

    err3:
	sys_page_unmap(0, va);
  801cd6:	83 ec 08             	sub    $0x8,%esp
  801cd9:	56                   	push   %esi
  801cda:	6a 00                	push   $0x0
  801cdc:	e8 dd ef ff ff       	call   800cbe <sys_page_unmap>
  801ce1:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801ce4:	83 ec 08             	sub    $0x8,%esp
  801ce7:	ff 75 e0             	pushl  -0x20(%ebp)
  801cea:	6a 00                	push   $0x0
  801cec:	e8 cd ef ff ff       	call   800cbe <sys_page_unmap>
  801cf1:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801cf4:	83 ec 08             	sub    $0x8,%esp
  801cf7:	ff 75 e4             	pushl  -0x1c(%ebp)
  801cfa:	6a 00                	push   $0x0
  801cfc:	e8 bd ef ff ff       	call   800cbe <sys_page_unmap>
  801d01:	83 c4 10             	add    $0x10,%esp
    err:
	return r;
}
  801d04:	89 d8                	mov    %ebx,%eax
  801d06:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d09:	5b                   	pop    %ebx
  801d0a:	5e                   	pop    %esi
  801d0b:	5f                   	pop    %edi
  801d0c:	c9                   	leave  
  801d0d:	c3                   	ret    

00801d0e <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801d0e:	55                   	push   %ebp
  801d0f:	89 e5                	mov    %esp,%ebp
  801d11:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801d14:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d17:	50                   	push   %eax
  801d18:	ff 75 08             	pushl  0x8(%ebp)
  801d1b:	e8 9b f5 ff ff       	call   8012bb <fd_lookup>
  801d20:	83 c4 10             	add    $0x10,%esp
  801d23:	85 c0                	test   %eax,%eax
  801d25:	78 18                	js     801d3f <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801d27:	83 ec 0c             	sub    $0xc,%esp
  801d2a:	ff 75 f4             	pushl  -0xc(%ebp)
  801d2d:	e8 fe f4 ff ff       	call   801230 <fd2data>
	return _pipeisclosed(fd, p);
  801d32:	89 c2                	mov    %eax,%edx
  801d34:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d37:	e8 0c fd ff ff       	call   801a48 <_pipeisclosed>
  801d3c:	83 c4 10             	add    $0x10,%esp
}
  801d3f:	c9                   	leave  
  801d40:	c3                   	ret    
  801d41:	00 00                	add    %al,(%eax)
	...

00801d44 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801d44:	55                   	push   %ebp
  801d45:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801d47:	b8 00 00 00 00       	mov    $0x0,%eax
  801d4c:	c9                   	leave  
  801d4d:	c3                   	ret    

00801d4e <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801d4e:	55                   	push   %ebp
  801d4f:	89 e5                	mov    %esp,%ebp
  801d51:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801d54:	68 0a 28 80 00       	push   $0x80280a
  801d59:	ff 75 0c             	pushl  0xc(%ebp)
  801d5c:	e8 91 ea ff ff       	call   8007f2 <strcpy>
	return 0;
}
  801d61:	b8 00 00 00 00       	mov    $0x0,%eax
  801d66:	c9                   	leave  
  801d67:	c3                   	ret    

00801d68 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801d68:	55                   	push   %ebp
  801d69:	89 e5                	mov    %esp,%ebp
  801d6b:	57                   	push   %edi
  801d6c:	56                   	push   %esi
  801d6d:	53                   	push   %ebx
  801d6e:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801d74:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801d78:	74 45                	je     801dbf <devcons_write+0x57>
  801d7a:	b8 00 00 00 00       	mov    $0x0,%eax
  801d7f:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801d84:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801d8a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801d8d:	29 c3                	sub    %eax,%ebx
		if (m > sizeof(buf) - 1)
  801d8f:	83 fb 7f             	cmp    $0x7f,%ebx
  801d92:	76 05                	jbe    801d99 <devcons_write+0x31>
			m = sizeof(buf) - 1;
  801d94:	bb 7f 00 00 00       	mov    $0x7f,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  801d99:	83 ec 04             	sub    $0x4,%esp
  801d9c:	53                   	push   %ebx
  801d9d:	03 45 0c             	add    0xc(%ebp),%eax
  801da0:	50                   	push   %eax
  801da1:	57                   	push   %edi
  801da2:	e8 0c ec ff ff       	call   8009b3 <memmove>
		sys_cputs(buf, m);
  801da7:	83 c4 08             	add    $0x8,%esp
  801daa:	53                   	push   %ebx
  801dab:	57                   	push   %edi
  801dac:	e8 0c ee ff ff       	call   800bbd <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801db1:	01 de                	add    %ebx,%esi
  801db3:	89 f0                	mov    %esi,%eax
  801db5:	83 c4 10             	add    $0x10,%esp
  801db8:	3b 75 10             	cmp    0x10(%ebp),%esi
  801dbb:	72 cd                	jb     801d8a <devcons_write+0x22>
  801dbd:	eb 05                	jmp    801dc4 <devcons_write+0x5c>
  801dbf:	be 00 00 00 00       	mov    $0x0,%esi
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801dc4:	89 f0                	mov    %esi,%eax
  801dc6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801dc9:	5b                   	pop    %ebx
  801dca:	5e                   	pop    %esi
  801dcb:	5f                   	pop    %edi
  801dcc:	c9                   	leave  
  801dcd:	c3                   	ret    

00801dce <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801dce:	55                   	push   %ebp
  801dcf:	89 e5                	mov    %esp,%ebp
  801dd1:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  801dd4:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801dd8:	75 07                	jne    801de1 <devcons_read+0x13>
  801dda:	eb 25                	jmp    801e01 <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801ddc:	e8 6c ee ff ff       	call   800c4d <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801de1:	e8 fd ed ff ff       	call   800be3 <sys_cgetc>
  801de6:	85 c0                	test   %eax,%eax
  801de8:	74 f2                	je     801ddc <devcons_read+0xe>
  801dea:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  801dec:	85 c0                	test   %eax,%eax
  801dee:	78 1d                	js     801e0d <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801df0:	83 f8 04             	cmp    $0x4,%eax
  801df3:	74 13                	je     801e08 <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  801df5:	8b 45 0c             	mov    0xc(%ebp),%eax
  801df8:	88 10                	mov    %dl,(%eax)
	return 1;
  801dfa:	b8 01 00 00 00       	mov    $0x1,%eax
  801dff:	eb 0c                	jmp    801e0d <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  801e01:	b8 00 00 00 00       	mov    $0x0,%eax
  801e06:	eb 05                	jmp    801e0d <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801e08:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801e0d:	c9                   	leave  
  801e0e:	c3                   	ret    

00801e0f <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801e0f:	55                   	push   %ebp
  801e10:	89 e5                	mov    %esp,%ebp
  801e12:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801e15:	8b 45 08             	mov    0x8(%ebp),%eax
  801e18:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801e1b:	6a 01                	push   $0x1
  801e1d:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801e20:	50                   	push   %eax
  801e21:	e8 97 ed ff ff       	call   800bbd <sys_cputs>
  801e26:	83 c4 10             	add    $0x10,%esp
}
  801e29:	c9                   	leave  
  801e2a:	c3                   	ret    

00801e2b <getchar>:

int
getchar(void)
{
  801e2b:	55                   	push   %ebp
  801e2c:	89 e5                	mov    %esp,%ebp
  801e2e:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801e31:	6a 01                	push   $0x1
  801e33:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801e36:	50                   	push   %eax
  801e37:	6a 00                	push   $0x0
  801e39:	e8 fe f6 ff ff       	call   80153c <read>
	if (r < 0)
  801e3e:	83 c4 10             	add    $0x10,%esp
  801e41:	85 c0                	test   %eax,%eax
  801e43:	78 0f                	js     801e54 <getchar+0x29>
		return r;
	if (r < 1)
  801e45:	85 c0                	test   %eax,%eax
  801e47:	7e 06                	jle    801e4f <getchar+0x24>
		return -E_EOF;
	return c;
  801e49:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801e4d:	eb 05                	jmp    801e54 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801e4f:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801e54:	c9                   	leave  
  801e55:	c3                   	ret    

00801e56 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801e56:	55                   	push   %ebp
  801e57:	89 e5                	mov    %esp,%ebp
  801e59:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801e5c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e5f:	50                   	push   %eax
  801e60:	ff 75 08             	pushl  0x8(%ebp)
  801e63:	e8 53 f4 ff ff       	call   8012bb <fd_lookup>
  801e68:	83 c4 10             	add    $0x10,%esp
  801e6b:	85 c0                	test   %eax,%eax
  801e6d:	78 11                	js     801e80 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801e6f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e72:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801e78:	39 10                	cmp    %edx,(%eax)
  801e7a:	0f 94 c0             	sete   %al
  801e7d:	0f b6 c0             	movzbl %al,%eax
}
  801e80:	c9                   	leave  
  801e81:	c3                   	ret    

00801e82 <opencons>:

int
opencons(void)
{
  801e82:	55                   	push   %ebp
  801e83:	89 e5                	mov    %esp,%ebp
  801e85:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801e88:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e8b:	50                   	push   %eax
  801e8c:	e8 b7 f3 ff ff       	call   801248 <fd_alloc>
  801e91:	83 c4 10             	add    $0x10,%esp
  801e94:	85 c0                	test   %eax,%eax
  801e96:	78 3a                	js     801ed2 <opencons+0x50>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801e98:	83 ec 04             	sub    $0x4,%esp
  801e9b:	68 07 04 00 00       	push   $0x407
  801ea0:	ff 75 f4             	pushl  -0xc(%ebp)
  801ea3:	6a 00                	push   $0x0
  801ea5:	e8 ca ed ff ff       	call   800c74 <sys_page_alloc>
  801eaa:	83 c4 10             	add    $0x10,%esp
  801ead:	85 c0                	test   %eax,%eax
  801eaf:	78 21                	js     801ed2 <opencons+0x50>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801eb1:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801eb7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801eba:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801ebc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ebf:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801ec6:	83 ec 0c             	sub    $0xc,%esp
  801ec9:	50                   	push   %eax
  801eca:	e8 51 f3 ff ff       	call   801220 <fd2num>
  801ecf:	83 c4 10             	add    $0x10,%esp
}
  801ed2:	c9                   	leave  
  801ed3:	c3                   	ret    

00801ed4 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801ed4:	55                   	push   %ebp
  801ed5:	89 e5                	mov    %esp,%ebp
  801ed7:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  801eda:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801ee1:	75 52                	jne    801f35 <set_pgfault_handler+0x61>
		// First time through!	
		// LAB 4: Your code here.

		//int sys_page_alloc(envid_t envid, void *va, int perm)
		r = sys_page_alloc(0, (void*)(UXSTACKTOP - PGSIZE), PTE_U | PTE_W | PTE_P);
  801ee3:	83 ec 04             	sub    $0x4,%esp
  801ee6:	6a 07                	push   $0x7
  801ee8:	68 00 f0 bf ee       	push   $0xeebff000
  801eed:	6a 00                	push   $0x0
  801eef:	e8 80 ed ff ff       	call   800c74 <sys_page_alloc>
		if (r < 0) {
  801ef4:	83 c4 10             	add    $0x10,%esp
  801ef7:	85 c0                	test   %eax,%eax
  801ef9:	79 12                	jns    801f0d <set_pgfault_handler+0x39>
			panic("sys_page_alloc error : %e\n", r);
  801efb:	50                   	push   %eax
  801efc:	68 16 28 80 00       	push   $0x802816
  801f01:	6a 24                	push   $0x24
  801f03:	68 31 28 80 00       	push   $0x802831
  801f08:	e8 57 e2 ff ff       	call   800164 <_panic>
		}

		// how to know envid, put 0, envid2env will help us to get curenv in syscall
		r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);		
  801f0d:	83 ec 08             	sub    $0x8,%esp
  801f10:	68 40 1f 80 00       	push   $0x801f40
  801f15:	6a 00                	push   $0x0
  801f17:	e8 0b ee ff ff       	call   800d27 <sys_env_set_pgfault_upcall>
		if (r < 0) {
  801f1c:	83 c4 10             	add    $0x10,%esp
  801f1f:	85 c0                	test   %eax,%eax
  801f21:	79 12                	jns    801f35 <set_pgfault_handler+0x61>
			panic("sys_env_set_pgfault_upcall error : %e\n", r);
  801f23:	50                   	push   %eax
  801f24:	68 40 28 80 00       	push   $0x802840
  801f29:	6a 2a                	push   $0x2a
  801f2b:	68 31 28 80 00       	push   $0x802831
  801f30:	e8 2f e2 ff ff       	call   800164 <_panic>
		}
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801f35:	8b 45 08             	mov    0x8(%ebp),%eax
  801f38:	a3 00 60 80 00       	mov    %eax,0x806000
}
  801f3d:	c9                   	leave  
  801f3e:	c3                   	ret    
	...

00801f40 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801f40:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801f41:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  801f46:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801f48:	83 c4 04             	add    $0x4,%esp
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	
	// fix old esp
	movl 0x30(%esp), %eax
  801f4b:	8b 44 24 30          	mov    0x30(%esp),%eax
	subl $0x4, %eax
  801f4f:	83 e8 04             	sub    $0x4,%eax
	movl %eax, 0x30(%esp)
  801f52:	89 44 24 30          	mov    %eax,0x30(%esp)

	// set trap-time %eip
	movl 0x28(%esp), %ebx
  801f56:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	movl %ebx, (%eax)
  801f5a:	89 18                	mov    %ebx,(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $0x08, %esp 	// ignore err_code and fault_va
  801f5c:	83 c4 08             	add    $0x8,%esp
	popal 				// restore registers
  801f5f:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x04, %esp 	// ignore eip 
  801f60:	83 c4 04             	add    $0x4,%esp
	popfl				// modify eflags
  801f63:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  801f64:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  801f65:	c3                   	ret    
	...

00801f68 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801f68:	55                   	push   %ebp
  801f69:	89 e5                	mov    %esp,%ebp
  801f6b:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801f6e:	89 c2                	mov    %eax,%edx
  801f70:	c1 ea 16             	shr    $0x16,%edx
  801f73:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801f7a:	f6 c2 01             	test   $0x1,%dl
  801f7d:	74 1e                	je     801f9d <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  801f7f:	c1 e8 0c             	shr    $0xc,%eax
  801f82:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801f89:	a8 01                	test   $0x1,%al
  801f8b:	74 17                	je     801fa4 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801f8d:	c1 e8 0c             	shr    $0xc,%eax
  801f90:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  801f97:	ef 
  801f98:	0f b7 c0             	movzwl %ax,%eax
  801f9b:	eb 0c                	jmp    801fa9 <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  801f9d:	b8 00 00 00 00       	mov    $0x0,%eax
  801fa2:	eb 05                	jmp    801fa9 <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  801fa4:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  801fa9:	c9                   	leave  
  801faa:	c3                   	ret    
	...

00801fac <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  801fac:	55                   	push   %ebp
  801fad:	89 e5                	mov    %esp,%ebp
  801faf:	57                   	push   %edi
  801fb0:	56                   	push   %esi
  801fb1:	83 ec 10             	sub    $0x10,%esp
  801fb4:	8b 7d 08             	mov    0x8(%ebp),%edi
  801fb7:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  801fba:	89 7d f0             	mov    %edi,-0x10(%ebp)
  801fbd:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  801fc0:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  801fc3:	8b 45 14             	mov    0x14(%ebp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  801fc6:	85 c0                	test   %eax,%eax
  801fc8:	75 2e                	jne    801ff8 <__udivdi3+0x4c>
    {
      if (d0 > n1)
  801fca:	39 f1                	cmp    %esi,%ecx
  801fcc:	77 5a                	ja     802028 <__udivdi3+0x7c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  801fce:	85 c9                	test   %ecx,%ecx
  801fd0:	75 0b                	jne    801fdd <__udivdi3+0x31>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  801fd2:	b8 01 00 00 00       	mov    $0x1,%eax
  801fd7:	31 d2                	xor    %edx,%edx
  801fd9:	f7 f1                	div    %ecx
  801fdb:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  801fdd:	31 d2                	xor    %edx,%edx
  801fdf:	89 f0                	mov    %esi,%eax
  801fe1:	f7 f1                	div    %ecx
  801fe3:	89 c6                	mov    %eax,%esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801fe5:	89 f8                	mov    %edi,%eax
  801fe7:	f7 f1                	div    %ecx
  801fe9:	89 c7                	mov    %eax,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801feb:	89 f8                	mov    %edi,%eax
  801fed:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801fef:	83 c4 10             	add    $0x10,%esp
  801ff2:	5e                   	pop    %esi
  801ff3:	5f                   	pop    %edi
  801ff4:	c9                   	leave  
  801ff5:	c3                   	ret    
  801ff6:	66 90                	xchg   %ax,%ax
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801ff8:	39 f0                	cmp    %esi,%eax
  801ffa:	77 1c                	ja     802018 <__udivdi3+0x6c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  801ffc:	0f bd f8             	bsr    %eax,%edi
	  if (bm == 0)
  801fff:	83 f7 1f             	xor    $0x1f,%edi
  802002:	75 3c                	jne    802040 <__udivdi3+0x94>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802004:	39 f0                	cmp    %esi,%eax
  802006:	0f 82 90 00 00 00    	jb     80209c <__udivdi3+0xf0>
  80200c:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80200f:	39 55 f4             	cmp    %edx,-0xc(%ebp)
  802012:	0f 86 84 00 00 00    	jbe    80209c <__udivdi3+0xf0>
  802018:	31 f6                	xor    %esi,%esi
  80201a:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  80201c:	89 f8                	mov    %edi,%eax
  80201e:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802020:	83 c4 10             	add    $0x10,%esp
  802023:	5e                   	pop    %esi
  802024:	5f                   	pop    %edi
  802025:	c9                   	leave  
  802026:	c3                   	ret    
  802027:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802028:	89 f2                	mov    %esi,%edx
  80202a:	89 f8                	mov    %edi,%eax
  80202c:	f7 f1                	div    %ecx
  80202e:	89 c7                	mov    %eax,%edi
  802030:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  802032:	89 f8                	mov    %edi,%eax
  802034:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802036:	83 c4 10             	add    $0x10,%esp
  802039:	5e                   	pop    %esi
  80203a:	5f                   	pop    %edi
  80203b:	c9                   	leave  
  80203c:	c3                   	ret    
  80203d:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  802040:	89 f9                	mov    %edi,%ecx
  802042:	d3 e0                	shl    %cl,%eax
  802044:	89 45 e8             	mov    %eax,-0x18(%ebp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  802047:	b8 20 00 00 00       	mov    $0x20,%eax
  80204c:	29 f8                	sub    %edi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  80204e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802051:	88 c1                	mov    %al,%cl
  802053:	d3 ea                	shr    %cl,%edx
  802055:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  802058:	09 ca                	or     %ecx,%edx
  80205a:	89 55 ec             	mov    %edx,-0x14(%ebp)
	      d0 = d0 << bm;
  80205d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802060:	89 f9                	mov    %edi,%ecx
  802062:	d3 e2                	shl    %cl,%edx
  802064:	89 55 f4             	mov    %edx,-0xc(%ebp)
	      n2 = n1 >> b;
  802067:	89 f2                	mov    %esi,%edx
  802069:	88 c1                	mov    %al,%cl
  80206b:	d3 ea                	shr    %cl,%edx
  80206d:	89 55 e8             	mov    %edx,-0x18(%ebp)
	      n1 = (n1 << bm) | (n0 >> b);
  802070:	89 f2                	mov    %esi,%edx
  802072:	89 f9                	mov    %edi,%ecx
  802074:	d3 e2                	shl    %cl,%edx
  802076:	8b 75 f0             	mov    -0x10(%ebp),%esi
  802079:	88 c1                	mov    %al,%cl
  80207b:	d3 ee                	shr    %cl,%esi
  80207d:	09 d6                	or     %edx,%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  80207f:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  802082:	89 f0                	mov    %esi,%eax
  802084:	89 ca                	mov    %ecx,%edx
  802086:	f7 75 ec             	divl   -0x14(%ebp)
  802089:	89 d1                	mov    %edx,%ecx
  80208b:	89 c6                	mov    %eax,%esi
	      umul_ppmm (m1, m0, q0, d0);
  80208d:	f7 65 f4             	mull   -0xc(%ebp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802090:	39 d1                	cmp    %edx,%ecx
  802092:	72 28                	jb     8020bc <__udivdi3+0x110>
  802094:	74 1a                	je     8020b0 <__udivdi3+0x104>
  802096:	89 f7                	mov    %esi,%edi
  802098:	31 f6                	xor    %esi,%esi
  80209a:	eb 80                	jmp    80201c <__udivdi3+0x70>
	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  80209c:	31 f6                	xor    %esi,%esi
  80209e:	bf 01 00 00 00       	mov    $0x1,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  8020a3:	89 f8                	mov    %edi,%eax
  8020a5:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  8020a7:	83 c4 10             	add    $0x10,%esp
  8020aa:	5e                   	pop    %esi
  8020ab:	5f                   	pop    %edi
  8020ac:	c9                   	leave  
  8020ad:	c3                   	ret    
  8020ae:	66 90                	xchg   %ax,%ax

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  8020b0:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8020b3:	89 f9                	mov    %edi,%ecx
  8020b5:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8020b7:	39 c2                	cmp    %eax,%edx
  8020b9:	73 db                	jae    802096 <__udivdi3+0xea>
  8020bb:	90                   	nop
		{
		  q0--;
  8020bc:	8d 7e ff             	lea    -0x1(%esi),%edi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  8020bf:	31 f6                	xor    %esi,%esi
  8020c1:	e9 56 ff ff ff       	jmp    80201c <__udivdi3+0x70>
	...

008020c8 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  8020c8:	55                   	push   %ebp
  8020c9:	89 e5                	mov    %esp,%ebp
  8020cb:	57                   	push   %edi
  8020cc:	56                   	push   %esi
  8020cd:	83 ec 20             	sub    $0x20,%esp
  8020d0:	8b 45 08             	mov    0x8(%ebp),%eax
  8020d3:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  8020d6:	89 45 e8             	mov    %eax,-0x18(%ebp)
  8020d9:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  8020dc:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  8020df:	8b 7d 14             	mov    0x14(%ebp),%edi
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  8020e2:	89 45 f0             	mov    %eax,-0x10(%ebp)
  n1 = nn.s.high;
  8020e5:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  8020e7:	85 ff                	test   %edi,%edi
  8020e9:	75 15                	jne    802100 <__umoddi3+0x38>
    {
      if (d0 > n1)
  8020eb:	39 f1                	cmp    %esi,%ecx
  8020ed:	0f 86 99 00 00 00    	jbe    80218c <__umoddi3+0xc4>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8020f3:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  8020f5:	89 d0                	mov    %edx,%eax
  8020f7:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8020f9:	83 c4 20             	add    $0x20,%esp
  8020fc:	5e                   	pop    %esi
  8020fd:	5f                   	pop    %edi
  8020fe:	c9                   	leave  
  8020ff:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  802100:	39 f7                	cmp    %esi,%edi
  802102:	0f 87 a4 00 00 00    	ja     8021ac <__umoddi3+0xe4>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  802108:	0f bd c7             	bsr    %edi,%eax
	  if (bm == 0)
  80210b:	83 f0 1f             	xor    $0x1f,%eax
  80210e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  802111:	0f 84 a1 00 00 00    	je     8021b8 <__umoddi3+0xf0>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  802117:	89 f8                	mov    %edi,%eax
  802119:	8a 4d ec             	mov    -0x14(%ebp),%cl
  80211c:	d3 e0                	shl    %cl,%eax
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  80211e:	bf 20 00 00 00       	mov    $0x20,%edi
  802123:	2b 7d ec             	sub    -0x14(%ebp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  802126:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802129:	89 f9                	mov    %edi,%ecx
  80212b:	d3 ea                	shr    %cl,%edx
  80212d:	09 c2                	or     %eax,%edx
  80212f:	89 55 f0             	mov    %edx,-0x10(%ebp)
	      d0 = d0 << bm;
  802132:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802135:	8a 4d ec             	mov    -0x14(%ebp),%cl
  802138:	d3 e0                	shl    %cl,%eax
  80213a:	89 45 f4             	mov    %eax,-0xc(%ebp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  80213d:	89 f2                	mov    %esi,%edx
  80213f:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  802141:	8b 45 e8             	mov    -0x18(%ebp),%eax
  802144:	d3 e0                	shl    %cl,%eax
  802146:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  802149:	8b 45 e8             	mov    -0x18(%ebp),%eax
  80214c:	89 f9                	mov    %edi,%ecx
  80214e:	d3 e8                	shr    %cl,%eax
  802150:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  802152:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  802154:	89 f2                	mov    %esi,%edx
  802156:	f7 75 f0             	divl   -0x10(%ebp)
  802159:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  80215b:	f7 65 f4             	mull   -0xc(%ebp)
  80215e:	89 55 e8             	mov    %edx,-0x18(%ebp)
  802161:	89 c1                	mov    %eax,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802163:	39 d6                	cmp    %edx,%esi
  802165:	72 71                	jb     8021d8 <__umoddi3+0x110>
  802167:	74 7f                	je     8021e8 <__umoddi3+0x120>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  802169:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80216c:	29 c8                	sub    %ecx,%eax
  80216e:	19 d6                	sbb    %edx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  802170:	8a 4d ec             	mov    -0x14(%ebp),%cl
  802173:	d3 e8                	shr    %cl,%eax
  802175:	89 f2                	mov    %esi,%edx
  802177:	89 f9                	mov    %edi,%ecx
  802179:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  80217b:	09 d0                	or     %edx,%eax
  80217d:	89 f2                	mov    %esi,%edx
  80217f:	8a 4d ec             	mov    -0x14(%ebp),%cl
  802182:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802184:	83 c4 20             	add    $0x20,%esp
  802187:	5e                   	pop    %esi
  802188:	5f                   	pop    %edi
  802189:	c9                   	leave  
  80218a:	c3                   	ret    
  80218b:	90                   	nop
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  80218c:	85 c9                	test   %ecx,%ecx
  80218e:	75 0b                	jne    80219b <__umoddi3+0xd3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  802190:	b8 01 00 00 00       	mov    $0x1,%eax
  802195:	31 d2                	xor    %edx,%edx
  802197:	f7 f1                	div    %ecx
  802199:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  80219b:	89 f0                	mov    %esi,%eax
  80219d:	31 d2                	xor    %edx,%edx
  80219f:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8021a1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8021a4:	f7 f1                	div    %ecx
  8021a6:	e9 4a ff ff ff       	jmp    8020f5 <__umoddi3+0x2d>
  8021ab:	90                   	nop
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  8021ac:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8021ae:	83 c4 20             	add    $0x20,%esp
  8021b1:	5e                   	pop    %esi
  8021b2:	5f                   	pop    %edi
  8021b3:	c9                   	leave  
  8021b4:	c3                   	ret    
  8021b5:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  8021b8:	39 f7                	cmp    %esi,%edi
  8021ba:	72 05                	jb     8021c1 <__umoddi3+0xf9>
  8021bc:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
  8021bf:	77 0c                	ja     8021cd <__umoddi3+0x105>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  8021c1:	89 f2                	mov    %esi,%edx
  8021c3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8021c6:	29 c8                	sub    %ecx,%eax
  8021c8:	19 fa                	sbb    %edi,%edx
  8021ca:	89 45 f0             	mov    %eax,-0x10(%ebp)

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  8021cd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8021d0:	83 c4 20             	add    $0x20,%esp
  8021d3:	5e                   	pop    %esi
  8021d4:	5f                   	pop    %edi
  8021d5:	c9                   	leave  
  8021d6:	c3                   	ret    
  8021d7:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  8021d8:	8b 55 e8             	mov    -0x18(%ebp),%edx
  8021db:	89 c1                	mov    %eax,%ecx
  8021dd:	2b 4d f4             	sub    -0xc(%ebp),%ecx
  8021e0:	1b 55 f0             	sbb    -0x10(%ebp),%edx
  8021e3:	eb 84                	jmp    802169 <__umoddi3+0xa1>
  8021e5:	8d 76 00             	lea    0x0(%esi),%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8021e8:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  8021eb:	72 eb                	jb     8021d8 <__umoddi3+0x110>
  8021ed:	89 f2                	mov    %esi,%edx
  8021ef:	e9 75 ff ff ff       	jmp    802169 <__umoddi3+0xa1>
