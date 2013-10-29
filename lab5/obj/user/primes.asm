
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
  800048:	e8 3f 10 00 00       	call   80108c <ipc_recv>
  80004d:	89 c3                	mov    %eax,%ebx
	cprintf("CPU %d: %d ", thisenv->env_cpunum, p);
  80004f:	a1 04 40 80 00       	mov    0x804004,%eax
  800054:	8b 40 5c             	mov    0x5c(%eax),%eax
  800057:	83 c4 0c             	add    $0xc,%esp
  80005a:	53                   	push   %ebx
  80005b:	50                   	push   %eax
  80005c:	68 e0 21 80 00       	push   $0x8021e0
  800061:	e8 d6 01 00 00       	call   80023c <cprintf>

	// fork a right neighbor to continue the chain
	if ((id = fork()) < 0)
  800066:	e8 1b 0e 00 00       	call   800e86 <fork>
  80006b:	89 c7                	mov    %eax,%edi
  80006d:	83 c4 10             	add    $0x10,%esp
  800070:	85 c0                	test   %eax,%eax
  800072:	79 12                	jns    800086 <primeproc+0x52>
		panic("fork: %e", id);
  800074:	50                   	push   %eax
  800075:	68 ec 21 80 00       	push   $0x8021ec
  80007a:	6a 1a                	push   $0x1a
  80007c:	68 f5 21 80 00       	push   $0x8021f5
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
  800095:	e8 f2 0f 00 00       	call   80108c <ipc_recv>
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
  8000ac:	e8 83 10 00 00       	call   801134 <ipc_send>
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
  8000bb:	e8 c6 0d 00 00       	call   800e86 <fork>
  8000c0:	89 c3                	mov    %eax,%ebx
  8000c2:	85 c0                	test   %eax,%eax
  8000c4:	79 12                	jns    8000d8 <umain+0x22>
		panic("fork: %e", id);
  8000c6:	50                   	push   %eax
  8000c7:	68 ec 21 80 00       	push   $0x8021ec
  8000cc:	6a 2d                	push   $0x2d
  8000ce:	68 f5 21 80 00       	push   $0x8021f5
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
  8000ec:	e8 43 10 00 00       	call   801134 <ipc_send>
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
  80014e:	e8 9b 12 00 00       	call   8013ee <close_all>
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
  800182:	68 10 22 80 00       	push   $0x802210
  800187:	e8 b0 00 00 00       	call   80023c <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80018c:	83 c4 18             	add    $0x18,%esp
  80018f:	56                   	push   %esi
  800190:	ff 75 10             	pushl  0x10(%ebp)
  800193:	e8 53 00 00 00       	call   8001eb <vcprintf>
	cprintf("\n");
  800198:	c7 04 24 eb 27 80 00 	movl   $0x8027eb,(%esp)
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
  8002a4:	e8 e7 1c 00 00       	call   801f90 <__udivdi3>
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
  8002e0:	e8 c7 1d 00 00       	call   8020ac <__umoddi3>
  8002e5:	83 c4 14             	add    $0x14,%esp
  8002e8:	0f be 80 33 22 80 00 	movsbl 0x802233(%eax),%eax
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
  80042c:	ff 24 85 80 23 80 00 	jmp    *0x802380(,%eax,4)
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
  8004d8:	8b 04 85 e0 24 80 00 	mov    0x8024e0(,%eax,4),%eax
  8004df:	85 c0                	test   %eax,%eax
  8004e1:	75 1a                	jne    8004fd <vprintfmt+0x15c>
				printfmt(putch, putdat, "error %d", err);
  8004e3:	52                   	push   %edx
  8004e4:	68 4b 22 80 00       	push   $0x80224b
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
  8004fe:	68 cd 27 80 00       	push   $0x8027cd
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
  800534:	c7 45 d0 44 22 80 00 	movl   $0x802244,-0x30(%ebp)
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
  800ba2:	68 3f 25 80 00       	push   $0x80253f
  800ba7:	6a 42                	push   $0x42
  800ba9:	68 5c 25 80 00       	push   $0x80255c
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

00800db4 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800db4:	55                   	push   %ebp
  800db5:	89 e5                	mov    %esp,%ebp
  800db7:	53                   	push   %ebx
  800db8:	83 ec 04             	sub    $0x4,%esp
  800dbb:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800dbe:	8b 18                	mov    (%eax),%ebx

	// LAB 4: Your code here.
	
	// cprintf("PAGE FAULT HANDLER, 0x%08x %d\n", (uint32_t)addr, err & FEC_WR);
	
	if ((err & FEC_WR) == 0)
  800dc0:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800dc4:	75 14                	jne    800dda <pgfault+0x26>
		panic("pgfault, the fault is not a write\n");
  800dc6:	83 ec 04             	sub    $0x4,%esp
  800dc9:	68 6c 25 80 00       	push   $0x80256c
  800dce:	6a 20                	push   $0x20
  800dd0:	68 b0 26 80 00       	push   $0x8026b0
  800dd5:	e8 8a f3 ff ff       	call   800164 <_panic>

	uint32_t uaddr = (uint32_t) addr;
	if ((uvpd[PDX(addr)] & PTE_P) == 0 || (uvpt[uaddr / PGSIZE] & PTE_COW) == 0) {
  800dda:	89 d8                	mov    %ebx,%eax
  800ddc:	c1 e8 16             	shr    $0x16,%eax
  800ddf:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800de6:	a8 01                	test   $0x1,%al
  800de8:	74 11                	je     800dfb <pgfault+0x47>
  800dea:	89 d8                	mov    %ebx,%eax
  800dec:	c1 e8 0c             	shr    $0xc,%eax
  800def:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800df6:	f6 c4 08             	test   $0x8,%ah
  800df9:	75 14                	jne    800e0f <pgfault+0x5b>
		panic("pgfault, not a copy-on-write page\n");
  800dfb:	83 ec 04             	sub    $0x4,%esp
  800dfe:	68 90 25 80 00       	push   $0x802590
  800e03:	6a 24                	push   $0x24
  800e05:	68 b0 26 80 00       	push   $0x8026b0
  800e0a:	e8 55 f3 ff ff       	call   800164 <_panic>
	//   No need to explicitly delete the old page's mapping.

	// LAB 4: Your code here.

	// static int sys_page_alloc(envid_t envid, void *va, int perm)
	r = sys_page_alloc(0, (void *)PFTEMP, PTE_W | PTE_U | PTE_P);
  800e0f:	83 ec 04             	sub    $0x4,%esp
  800e12:	6a 07                	push   $0x7
  800e14:	68 00 f0 7f 00       	push   $0x7ff000
  800e19:	6a 00                	push   $0x0
  800e1b:	e8 54 fe ff ff       	call   800c74 <sys_page_alloc>
	if (r < 0) panic("pgfault, sys_page_alloc error : %e\n", r);
  800e20:	83 c4 10             	add    $0x10,%esp
  800e23:	85 c0                	test   %eax,%eax
  800e25:	79 12                	jns    800e39 <pgfault+0x85>
  800e27:	50                   	push   %eax
  800e28:	68 b4 25 80 00       	push   $0x8025b4
  800e2d:	6a 32                	push   $0x32
  800e2f:	68 b0 26 80 00       	push   $0x8026b0
  800e34:	e8 2b f3 ff ff       	call   800164 <_panic>

	// Oh my god, I forget this at the first, it waste me a lot of time to debug!!!
	addr = ROUNDDOWN(addr, PGSIZE);
  800e39:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	
	memcpy(PFTEMP, addr, PGSIZE);
  800e3f:	83 ec 04             	sub    $0x4,%esp
  800e42:	68 00 10 00 00       	push   $0x1000
  800e47:	53                   	push   %ebx
  800e48:	68 00 f0 7f 00       	push   $0x7ff000
  800e4d:	e8 cb fb ff ff       	call   800a1d <memcpy>
	
	r = sys_page_map(0, PFTEMP, 0, addr, PTE_W | PTE_U | PTE_P);
  800e52:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800e59:	53                   	push   %ebx
  800e5a:	6a 00                	push   $0x0
  800e5c:	68 00 f0 7f 00       	push   $0x7ff000
  800e61:	6a 00                	push   $0x0
  800e63:	e8 30 fe ff ff       	call   800c98 <sys_page_map>
	if (r < 0) panic("pgfault, sys_page_map error : %e\n", r);
  800e68:	83 c4 20             	add    $0x20,%esp
  800e6b:	85 c0                	test   %eax,%eax
  800e6d:	79 12                	jns    800e81 <pgfault+0xcd>
  800e6f:	50                   	push   %eax
  800e70:	68 d8 25 80 00       	push   $0x8025d8
  800e75:	6a 3a                	push   $0x3a
  800e77:	68 b0 26 80 00       	push   $0x8026b0
  800e7c:	e8 e3 f2 ff ff       	call   800164 <_panic>

	return;
}
  800e81:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e84:	c9                   	leave  
  800e85:	c3                   	ret    

00800e86 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800e86:	55                   	push   %ebp
  800e87:	89 e5                	mov    %esp,%ebp
  800e89:	57                   	push   %edi
  800e8a:	56                   	push   %esi
  800e8b:	53                   	push   %ebx
  800e8c:	83 ec 28             	sub    $0x28,%esp
	// static int num = 0x100;

	// LAB 4: Your code here.
	set_pgfault_handler(pgfault);
  800e8f:	68 b4 0d 80 00       	push   $0x800db4
  800e94:	e8 1f 10 00 00       	call   801eb8 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  800e99:	ba 07 00 00 00       	mov    $0x7,%edx
  800e9e:	89 d0                	mov    %edx,%eax
  800ea0:	cd 30                	int    $0x30
  800ea2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800ea5:	89 c7                	mov    %eax,%edi
	int childpid = sys_exofork();
	if (childpid < 0) {
  800ea7:	83 c4 10             	add    $0x10,%esp
  800eaa:	85 c0                	test   %eax,%eax
  800eac:	79 12                	jns    800ec0 <fork+0x3a>
		panic("fork sys_exofork error : %e\n", childpid);
  800eae:	50                   	push   %eax
  800eaf:	68 bb 26 80 00       	push   $0x8026bb
  800eb4:	6a 7b                	push   $0x7b
  800eb6:	68 b0 26 80 00       	push   $0x8026b0
  800ebb:	e8 a4 f2 ff ff       	call   800164 <_panic>
	}
	int r;

	if (childpid == 0) {
  800ec0:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800ec4:	75 25                	jne    800eeb <fork+0x65>
		// child process
		// Remember to fix "thisenv" in the child process. ??? 
		thisenv = &envs[ENVX(sys_getenvid())];
  800ec6:	e8 5e fd ff ff       	call   800c29 <sys_getenvid>
  800ecb:	25 ff 03 00 00       	and    $0x3ff,%eax
  800ed0:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800ed7:	c1 e0 07             	shl    $0x7,%eax
  800eda:	29 d0                	sub    %edx,%eax
  800edc:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800ee1:	a3 04 40 80 00       	mov    %eax,0x804004
		// cprintf("fork child ok\n");
		return 0;
  800ee6:	e9 7b 01 00 00       	jmp    801066 <fork+0x1e0>
	if (childpid < 0) {
		panic("fork sys_exofork error : %e\n", childpid);
	}
	int r;

	if (childpid == 0) {
  800eeb:	bb 00 00 00 00       	mov    $0x0,%ebx
	} else {
		// map page to new environment
		// kernel page is already in new environment
		uint32_t i;
		for (i = 0; i != UTOP; i += PGSIZE) 
		if ((uvpd[PDX(i)] & PTE_P) && (uvpt[i / PGSIZE] & PTE_P) && (uvpt[i / PGSIZE] & PTE_U)) {
  800ef0:	89 d8                	mov    %ebx,%eax
  800ef2:	c1 e8 16             	shr    $0x16,%eax
  800ef5:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800efc:	a8 01                	test   $0x1,%al
  800efe:	0f 84 cd 00 00 00    	je     800fd1 <fork+0x14b>
  800f04:	89 d8                	mov    %ebx,%eax
  800f06:	c1 e8 0c             	shr    $0xc,%eax
  800f09:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800f10:	f6 c2 01             	test   $0x1,%dl
  800f13:	0f 84 b8 00 00 00    	je     800fd1 <fork+0x14b>
  800f19:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800f20:	f6 c2 04             	test   $0x4,%dl
  800f23:	0f 84 a8 00 00 00    	je     800fd1 <fork+0x14b>
//
static int
duppage(envid_t envid, unsigned pn)
{
	// do not dup exception stack
	if (pn * PGSIZE == UXSTACKTOP - PGSIZE) return 0;
  800f29:	89 c6                	mov    %eax,%esi
  800f2b:	c1 e6 0c             	shl    $0xc,%esi
  800f2e:	81 fe 00 f0 bf ee    	cmp    $0xeebff000,%esi
  800f34:	0f 84 97 00 00 00    	je     800fd1 <fork+0x14b>

	int r;
	void * addr = (void *)(pn * PGSIZE);
	if ((uvpt[pn] & PTE_W) || (uvpt[pn] & PTE_COW)) {
  800f3a:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800f41:	f6 c2 02             	test   $0x2,%dl
  800f44:	75 0c                	jne    800f52 <fork+0xcc>
  800f46:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f4d:	f6 c4 08             	test   $0x8,%ah
  800f50:	74 57                	je     800fa9 <fork+0x123>
		// cow
		r = sys_page_map(0, addr, envid, addr, PTE_COW | PTE_P | PTE_U);
  800f52:	83 ec 0c             	sub    $0xc,%esp
  800f55:	68 05 08 00 00       	push   $0x805
  800f5a:	56                   	push   %esi
  800f5b:	57                   	push   %edi
  800f5c:	56                   	push   %esi
  800f5d:	6a 00                	push   $0x0
  800f5f:	e8 34 fd ff ff       	call   800c98 <sys_page_map>
		if (r < 0) panic("duppage sys_page_map error : %e\n", r);
  800f64:	83 c4 20             	add    $0x20,%esp
  800f67:	85 c0                	test   %eax,%eax
  800f69:	79 12                	jns    800f7d <fork+0xf7>
  800f6b:	50                   	push   %eax
  800f6c:	68 fc 25 80 00       	push   $0x8025fc
  800f71:	6a 55                	push   $0x55
  800f73:	68 b0 26 80 00       	push   $0x8026b0
  800f78:	e8 e7 f1 ff ff       	call   800164 <_panic>
		
		r = sys_page_map(0, addr, 0, addr, PTE_COW | PTE_P | PTE_U);
  800f7d:	83 ec 0c             	sub    $0xc,%esp
  800f80:	68 05 08 00 00       	push   $0x805
  800f85:	56                   	push   %esi
  800f86:	6a 00                	push   $0x0
  800f88:	56                   	push   %esi
  800f89:	6a 00                	push   $0x0
  800f8b:	e8 08 fd ff ff       	call   800c98 <sys_page_map>
		if (r < 0) panic("duppage sys_page_map error : %e\n", r);
  800f90:	83 c4 20             	add    $0x20,%esp
  800f93:	85 c0                	test   %eax,%eax
  800f95:	79 3a                	jns    800fd1 <fork+0x14b>
  800f97:	50                   	push   %eax
  800f98:	68 fc 25 80 00       	push   $0x8025fc
  800f9d:	6a 58                	push   $0x58
  800f9f:	68 b0 26 80 00       	push   $0x8026b0
  800fa4:	e8 bb f1 ff ff       	call   800164 <_panic>
	} else {
		// read only
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U);
  800fa9:	83 ec 0c             	sub    $0xc,%esp
  800fac:	6a 05                	push   $0x5
  800fae:	56                   	push   %esi
  800faf:	57                   	push   %edi
  800fb0:	56                   	push   %esi
  800fb1:	6a 00                	push   $0x0
  800fb3:	e8 e0 fc ff ff       	call   800c98 <sys_page_map>
		if (r < 0) panic("duppage sys_page_map error : %e\n", r);
  800fb8:	83 c4 20             	add    $0x20,%esp
  800fbb:	85 c0                	test   %eax,%eax
  800fbd:	79 12                	jns    800fd1 <fork+0x14b>
  800fbf:	50                   	push   %eax
  800fc0:	68 fc 25 80 00       	push   $0x8025fc
  800fc5:	6a 5c                	push   $0x5c
  800fc7:	68 b0 26 80 00       	push   $0x8026b0
  800fcc:	e8 93 f1 ff ff       	call   800164 <_panic>
		return 0;
	} else {
		// map page to new environment
		// kernel page is already in new environment
		uint32_t i;
		for (i = 0; i != UTOP; i += PGSIZE) 
  800fd1:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  800fd7:	81 fb 00 00 c0 ee    	cmp    $0xeec00000,%ebx
  800fdd:	0f 85 0d ff ff ff    	jne    800ef0 <fork+0x6a>
		if ((uvpd[PDX(i)] & PTE_P) && (uvpt[i / PGSIZE] & PTE_P) && (uvpt[i / PGSIZE] & PTE_U)) {
			duppage(childpid, i / PGSIZE);
		}

		// allocate exception stack
		r = sys_page_alloc(childpid, (void *)(UXSTACKTOP - PGSIZE), PTE_U | PTE_W | PTE_P);
  800fe3:	83 ec 04             	sub    $0x4,%esp
  800fe6:	6a 07                	push   $0x7
  800fe8:	68 00 f0 bf ee       	push   $0xeebff000
  800fed:	ff 75 e4             	pushl  -0x1c(%ebp)
  800ff0:	e8 7f fc ff ff       	call   800c74 <sys_page_alloc>
		if (r < 0) panic("fork, sys_page_alloc user exception stack error : %e\n", r);
  800ff5:	83 c4 10             	add    $0x10,%esp
  800ff8:	85 c0                	test   %eax,%eax
  800ffa:	79 15                	jns    801011 <fork+0x18b>
  800ffc:	50                   	push   %eax
  800ffd:	68 20 26 80 00       	push   $0x802620
  801002:	68 90 00 00 00       	push   $0x90
  801007:	68 b0 26 80 00       	push   $0x8026b0
  80100c:	e8 53 f1 ff ff       	call   800164 <_panic>

		// set user environment user page fault handler 
		extern void _pgfault_upcall(void);
		r = sys_env_set_pgfault_upcall(childpid, _pgfault_upcall);
  801011:	83 ec 08             	sub    $0x8,%esp
  801014:	68 24 1f 80 00       	push   $0x801f24
  801019:	ff 75 e4             	pushl  -0x1c(%ebp)
  80101c:	e8 06 fd ff ff       	call   800d27 <sys_env_set_pgfault_upcall>
		if (r < 0) panic("fork, set pgfault upcall fail : %e\n", r);
  801021:	83 c4 10             	add    $0x10,%esp
  801024:	85 c0                	test   %eax,%eax
  801026:	79 15                	jns    80103d <fork+0x1b7>
  801028:	50                   	push   %eax
  801029:	68 58 26 80 00       	push   $0x802658
  80102e:	68 95 00 00 00       	push   $0x95
  801033:	68 b0 26 80 00       	push   $0x8026b0
  801038:	e8 27 f1 ff ff       	call   800164 <_panic>
		r = sys_set_priority(childpid, num);
		if (r < 0) panic("fork, set priority error\n");
		*/

		// mark the child as runnable and return
		r = sys_env_set_status(childpid, ENV_RUNNABLE);
  80103d:	83 ec 08             	sub    $0x8,%esp
  801040:	6a 02                	push   $0x2
  801042:	ff 75 e4             	pushl  -0x1c(%ebp)
  801045:	e8 97 fc ff ff       	call   800ce1 <sys_env_set_status>
		if (r < 0) panic("fork, set child process to ENV_RUNNABLE error : %e\n", r);
  80104a:	83 c4 10             	add    $0x10,%esp
  80104d:	85 c0                	test   %eax,%eax
  80104f:	79 15                	jns    801066 <fork+0x1e0>
  801051:	50                   	push   %eax
  801052:	68 7c 26 80 00       	push   $0x80267c
  801057:	68 a0 00 00 00       	push   $0xa0
  80105c:	68 b0 26 80 00       	push   $0x8026b0
  801061:	e8 fe f0 ff ff       	call   800164 <_panic>
		// cprintf("fork father ok!")
		return childpid;
	}

	panic("fork not implemented");
}
  801066:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801069:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80106c:	5b                   	pop    %ebx
  80106d:	5e                   	pop    %esi
  80106e:	5f                   	pop    %edi
  80106f:	c9                   	leave  
  801070:	c3                   	ret    

00801071 <sfork>:

// Challenge!
int
sfork(void)
{
  801071:	55                   	push   %ebp
  801072:	89 e5                	mov    %esp,%ebp
  801074:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  801077:	68 d8 26 80 00       	push   $0x8026d8
  80107c:	68 ad 00 00 00       	push   $0xad
  801081:	68 b0 26 80 00       	push   $0x8026b0
  801086:	e8 d9 f0 ff ff       	call   800164 <_panic>
	...

0080108c <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  80108c:	55                   	push   %ebp
  80108d:	89 e5                	mov    %esp,%ebp
  80108f:	57                   	push   %edi
  801090:	56                   	push   %esi
  801091:	53                   	push   %ebx
  801092:	83 ec 0c             	sub    $0xc,%esp
  801095:	8b 7d 08             	mov    0x8(%ebp),%edi
  801098:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80109b:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	cprintf("0x%x 0x%x 0x%x\n", (uint32_t)from_env_store, (uint32_t)pg, (uint32_t)perm_store);
  80109e:	56                   	push   %esi
  80109f:	53                   	push   %ebx
  8010a0:	57                   	push   %edi
  8010a1:	68 ee 26 80 00       	push   $0x8026ee
  8010a6:	e8 91 f1 ff ff       	call   80023c <cprintf>
	int r;
	if (pg != NULL) {
  8010ab:	83 c4 10             	add    $0x10,%esp
  8010ae:	85 db                	test   %ebx,%ebx
  8010b0:	74 28                	je     8010da <ipc_recv+0x4e>
		cprintf("BEGIN\n");
  8010b2:	83 ec 0c             	sub    $0xc,%esp
  8010b5:	68 fe 26 80 00       	push   $0x8026fe
  8010ba:	e8 7d f1 ff ff       	call   80023c <cprintf>
		r = sys_ipc_recv(pg);
  8010bf:	89 1c 24             	mov    %ebx,(%esp)
  8010c2:	e8 a8 fc ff ff       	call   800d6f <sys_ipc_recv>
  8010c7:	89 c3                	mov    %eax,%ebx
		cprintf("OVER\n");
  8010c9:	c7 04 24 05 27 80 00 	movl   $0x802705,(%esp)
  8010d0:	e8 67 f1 ff ff       	call   80023c <cprintf>
  8010d5:	83 c4 10             	add    $0x10,%esp
  8010d8:	eb 12                	jmp    8010ec <ipc_recv+0x60>
	} else {
		r = sys_ipc_recv((void *)UTOP);
  8010da:	83 ec 0c             	sub    $0xc,%esp
  8010dd:	68 00 00 c0 ee       	push   $0xeec00000
  8010e2:	e8 88 fc ff ff       	call   800d6f <sys_ipc_recv>
  8010e7:	89 c3                	mov    %eax,%ebx
  8010e9:	83 c4 10             	add    $0x10,%esp
	}

	if (r == 0) {
  8010ec:	85 db                	test   %ebx,%ebx
  8010ee:	75 26                	jne    801116 <ipc_recv+0x8a>
		if (from_env_store != NULL) *from_env_store = thisenv->env_ipc_from;
  8010f0:	85 ff                	test   %edi,%edi
  8010f2:	74 0a                	je     8010fe <ipc_recv+0x72>
  8010f4:	a1 04 40 80 00       	mov    0x804004,%eax
  8010f9:	8b 40 74             	mov    0x74(%eax),%eax
  8010fc:	89 07                	mov    %eax,(%edi)
		if (perm_store != NULL) *perm_store = thisenv->env_ipc_perm;
  8010fe:	85 f6                	test   %esi,%esi
  801100:	74 0a                	je     80110c <ipc_recv+0x80>
  801102:	a1 04 40 80 00       	mov    0x804004,%eax
  801107:	8b 40 78             	mov    0x78(%eax),%eax
  80110a:	89 06                	mov    %eax,(%esi)
		return thisenv->env_ipc_value;
  80110c:	a1 04 40 80 00       	mov    0x804004,%eax
  801111:	8b 58 70             	mov    0x70(%eax),%ebx
  801114:	eb 14                	jmp    80112a <ipc_recv+0x9e>
	} else {
		// fails;
		if (from_env_store != NULL) *from_env_store = 0;
  801116:	85 ff                	test   %edi,%edi
  801118:	74 06                	je     801120 <ipc_recv+0x94>
  80111a:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
		if (perm_store != NULL) *perm_store = 0;
  801120:	85 f6                	test   %esi,%esi
  801122:	74 06                	je     80112a <ipc_recv+0x9e>
  801124:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		return r;
	}
}
  80112a:	89 d8                	mov    %ebx,%eax
  80112c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80112f:	5b                   	pop    %ebx
  801130:	5e                   	pop    %esi
  801131:	5f                   	pop    %edi
  801132:	c9                   	leave  
  801133:	c3                   	ret    

00801134 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801134:	55                   	push   %ebp
  801135:	89 e5                	mov    %esp,%ebp
  801137:	57                   	push   %edi
  801138:	56                   	push   %esi
  801139:	53                   	push   %ebx
  80113a:	83 ec 0c             	sub    $0xc,%esp
  80113d:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801140:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801143:	8b 75 14             	mov    0x14(%ebp),%esi
	// LAB 4: Your code here.
	// int sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
	int r;
	if (pg == NULL) pg = (void *)UTOP;
  801146:	85 db                	test   %ebx,%ebx
  801148:	75 25                	jne    80116f <ipc_send+0x3b>
  80114a:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
  80114f:	eb 1e                	jmp    80116f <ipc_send+0x3b>
	
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) != 0) {
		if (r == -E_IPC_NOT_RECV) {
  801151:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801154:	75 07                	jne    80115d <ipc_send+0x29>
			// cprintf("Try Again and Again....\n");
			sys_yield();
  801156:	e8 f2 fa ff ff       	call   800c4d <sys_yield>
  80115b:	eb 12                	jmp    80116f <ipc_send+0x3b>
		} else {
			panic("ipc_send error %e\n", r);
  80115d:	50                   	push   %eax
  80115e:	68 0b 27 80 00       	push   $0x80270b
  801163:	6a 45                	push   $0x45
  801165:	68 1e 27 80 00       	push   $0x80271e
  80116a:	e8 f5 ef ff ff       	call   800164 <_panic>
	// LAB 4: Your code here.
	// int sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
	int r;
	if (pg == NULL) pg = (void *)UTOP;
	
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) != 0) {
  80116f:	56                   	push   %esi
  801170:	53                   	push   %ebx
  801171:	57                   	push   %edi
  801172:	ff 75 08             	pushl  0x8(%ebp)
  801175:	e8 d0 fb ff ff       	call   800d4a <sys_ipc_try_send>
  80117a:	83 c4 10             	add    $0x10,%esp
  80117d:	85 c0                	test   %eax,%eax
  80117f:	75 d0                	jne    801151 <ipc_send+0x1d>
		} else {
			panic("ipc_send error %e\n", r);
		}
	}
	return;
}
  801181:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801184:	5b                   	pop    %ebx
  801185:	5e                   	pop    %esi
  801186:	5f                   	pop    %edi
  801187:	c9                   	leave  
  801188:	c3                   	ret    

00801189 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801189:	55                   	push   %ebp
  80118a:	89 e5                	mov    %esp,%ebp
  80118c:	53                   	push   %ebx
  80118d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  801190:	39 1d 50 00 c0 ee    	cmp    %ebx,0xeec00050
  801196:	74 22                	je     8011ba <ipc_find_env+0x31>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801198:	b8 01 00 00 00       	mov    $0x1,%eax
		if (envs[i].env_type == type)
  80119d:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  8011a4:	89 c2                	mov    %eax,%edx
  8011a6:	c1 e2 07             	shl    $0x7,%edx
  8011a9:	29 ca                	sub    %ecx,%edx
  8011ab:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8011b1:	8b 52 50             	mov    0x50(%edx),%edx
  8011b4:	39 da                	cmp    %ebx,%edx
  8011b6:	75 1d                	jne    8011d5 <ipc_find_env+0x4c>
  8011b8:	eb 05                	jmp    8011bf <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8011ba:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
			return envs[i].env_id;
  8011bf:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  8011c6:	c1 e0 07             	shl    $0x7,%eax
  8011c9:	29 d0                	sub    %edx,%eax
  8011cb:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  8011d0:	8b 40 40             	mov    0x40(%eax),%eax
  8011d3:	eb 0c                	jmp    8011e1 <ipc_find_env+0x58>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8011d5:	40                   	inc    %eax
  8011d6:	3d 00 04 00 00       	cmp    $0x400,%eax
  8011db:	75 c0                	jne    80119d <ipc_find_env+0x14>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8011dd:	66 b8 00 00          	mov    $0x0,%ax
}
  8011e1:	5b                   	pop    %ebx
  8011e2:	c9                   	leave  
  8011e3:	c3                   	ret    

008011e4 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8011e4:	55                   	push   %ebp
  8011e5:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8011e7:	8b 45 08             	mov    0x8(%ebp),%eax
  8011ea:	05 00 00 00 30       	add    $0x30000000,%eax
  8011ef:	c1 e8 0c             	shr    $0xc,%eax
}
  8011f2:	c9                   	leave  
  8011f3:	c3                   	ret    

008011f4 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8011f4:	55                   	push   %ebp
  8011f5:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  8011f7:	ff 75 08             	pushl  0x8(%ebp)
  8011fa:	e8 e5 ff ff ff       	call   8011e4 <fd2num>
  8011ff:	83 c4 04             	add    $0x4,%esp
  801202:	05 20 00 0d 00       	add    $0xd0020,%eax
  801207:	c1 e0 0c             	shl    $0xc,%eax
}
  80120a:	c9                   	leave  
  80120b:	c3                   	ret    

0080120c <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80120c:	55                   	push   %ebp
  80120d:	89 e5                	mov    %esp,%ebp
  80120f:	53                   	push   %ebx
  801210:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801213:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  801218:	a8 01                	test   $0x1,%al
  80121a:	74 34                	je     801250 <fd_alloc+0x44>
  80121c:	a1 00 00 74 ef       	mov    0xef740000,%eax
  801221:	a8 01                	test   $0x1,%al
  801223:	74 32                	je     801257 <fd_alloc+0x4b>
  801225:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
  80122a:	89 c1                	mov    %eax,%ecx
  80122c:	89 c2                	mov    %eax,%edx
  80122e:	c1 ea 16             	shr    $0x16,%edx
  801231:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801238:	f6 c2 01             	test   $0x1,%dl
  80123b:	74 1f                	je     80125c <fd_alloc+0x50>
  80123d:	89 c2                	mov    %eax,%edx
  80123f:	c1 ea 0c             	shr    $0xc,%edx
  801242:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801249:	f6 c2 01             	test   $0x1,%dl
  80124c:	75 17                	jne    801265 <fd_alloc+0x59>
  80124e:	eb 0c                	jmp    80125c <fd_alloc+0x50>
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  801250:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
  801255:	eb 05                	jmp    80125c <fd_alloc+0x50>
  801257:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
  80125c:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  80125e:	b8 00 00 00 00       	mov    $0x0,%eax
  801263:	eb 17                	jmp    80127c <fd_alloc+0x70>
  801265:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  80126a:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80126f:	75 b9                	jne    80122a <fd_alloc+0x1e>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801271:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  801277:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  80127c:	5b                   	pop    %ebx
  80127d:	c9                   	leave  
  80127e:	c3                   	ret    

0080127f <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80127f:	55                   	push   %ebp
  801280:	89 e5                	mov    %esp,%ebp
  801282:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801285:	83 f8 1f             	cmp    $0x1f,%eax
  801288:	77 36                	ja     8012c0 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80128a:	05 00 00 0d 00       	add    $0xd0000,%eax
  80128f:	c1 e0 0c             	shl    $0xc,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801292:	89 c2                	mov    %eax,%edx
  801294:	c1 ea 16             	shr    $0x16,%edx
  801297:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80129e:	f6 c2 01             	test   $0x1,%dl
  8012a1:	74 24                	je     8012c7 <fd_lookup+0x48>
  8012a3:	89 c2                	mov    %eax,%edx
  8012a5:	c1 ea 0c             	shr    $0xc,%edx
  8012a8:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8012af:	f6 c2 01             	test   $0x1,%dl
  8012b2:	74 1a                	je     8012ce <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8012b4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8012b7:	89 02                	mov    %eax,(%edx)
	return 0;
  8012b9:	b8 00 00 00 00       	mov    $0x0,%eax
  8012be:	eb 13                	jmp    8012d3 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8012c0:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012c5:	eb 0c                	jmp    8012d3 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8012c7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012cc:	eb 05                	jmp    8012d3 <fd_lookup+0x54>
  8012ce:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8012d3:	c9                   	leave  
  8012d4:	c3                   	ret    

008012d5 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8012d5:	55                   	push   %ebp
  8012d6:	89 e5                	mov    %esp,%ebp
  8012d8:	53                   	push   %ebx
  8012d9:	83 ec 04             	sub    $0x4,%esp
  8012dc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8012df:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  8012e2:	39 0d 04 30 80 00    	cmp    %ecx,0x803004
  8012e8:	74 0d                	je     8012f7 <dev_lookup+0x22>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8012ea:	b8 00 00 00 00       	mov    $0x0,%eax
  8012ef:	eb 14                	jmp    801305 <dev_lookup+0x30>
		if (devtab[i]->dev_id == dev_id) {
  8012f1:	39 0a                	cmp    %ecx,(%edx)
  8012f3:	75 10                	jne    801305 <dev_lookup+0x30>
  8012f5:	eb 05                	jmp    8012fc <dev_lookup+0x27>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8012f7:	ba 04 30 80 00       	mov    $0x803004,%edx
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
  8012fc:	89 13                	mov    %edx,(%ebx)
			return 0;
  8012fe:	b8 00 00 00 00       	mov    $0x0,%eax
  801303:	eb 31                	jmp    801336 <dev_lookup+0x61>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801305:	40                   	inc    %eax
  801306:	8b 14 85 a4 27 80 00 	mov    0x8027a4(,%eax,4),%edx
  80130d:	85 d2                	test   %edx,%edx
  80130f:	75 e0                	jne    8012f1 <dev_lookup+0x1c>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801311:	a1 04 40 80 00       	mov    0x804004,%eax
  801316:	8b 40 48             	mov    0x48(%eax),%eax
  801319:	83 ec 04             	sub    $0x4,%esp
  80131c:	51                   	push   %ecx
  80131d:	50                   	push   %eax
  80131e:	68 28 27 80 00       	push   $0x802728
  801323:	e8 14 ef ff ff       	call   80023c <cprintf>
	*dev = 0;
  801328:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  80132e:	83 c4 10             	add    $0x10,%esp
  801331:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801336:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801339:	c9                   	leave  
  80133a:	c3                   	ret    

0080133b <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80133b:	55                   	push   %ebp
  80133c:	89 e5                	mov    %esp,%ebp
  80133e:	56                   	push   %esi
  80133f:	53                   	push   %ebx
  801340:	83 ec 20             	sub    $0x20,%esp
  801343:	8b 75 08             	mov    0x8(%ebp),%esi
  801346:	8a 45 0c             	mov    0xc(%ebp),%al
  801349:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80134c:	56                   	push   %esi
  80134d:	e8 92 fe ff ff       	call   8011e4 <fd2num>
  801352:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801355:	89 14 24             	mov    %edx,(%esp)
  801358:	50                   	push   %eax
  801359:	e8 21 ff ff ff       	call   80127f <fd_lookup>
  80135e:	89 c3                	mov    %eax,%ebx
  801360:	83 c4 08             	add    $0x8,%esp
  801363:	85 c0                	test   %eax,%eax
  801365:	78 05                	js     80136c <fd_close+0x31>
	    || fd != fd2)
  801367:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80136a:	74 0d                	je     801379 <fd_close+0x3e>
		return (must_exist ? r : 0);
  80136c:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  801370:	75 48                	jne    8013ba <fd_close+0x7f>
  801372:	bb 00 00 00 00       	mov    $0x0,%ebx
  801377:	eb 41                	jmp    8013ba <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801379:	83 ec 08             	sub    $0x8,%esp
  80137c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80137f:	50                   	push   %eax
  801380:	ff 36                	pushl  (%esi)
  801382:	e8 4e ff ff ff       	call   8012d5 <dev_lookup>
  801387:	89 c3                	mov    %eax,%ebx
  801389:	83 c4 10             	add    $0x10,%esp
  80138c:	85 c0                	test   %eax,%eax
  80138e:	78 1c                	js     8013ac <fd_close+0x71>
		if (dev->dev_close)
  801390:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801393:	8b 40 10             	mov    0x10(%eax),%eax
  801396:	85 c0                	test   %eax,%eax
  801398:	74 0d                	je     8013a7 <fd_close+0x6c>
			r = (*dev->dev_close)(fd);
  80139a:	83 ec 0c             	sub    $0xc,%esp
  80139d:	56                   	push   %esi
  80139e:	ff d0                	call   *%eax
  8013a0:	89 c3                	mov    %eax,%ebx
  8013a2:	83 c4 10             	add    $0x10,%esp
  8013a5:	eb 05                	jmp    8013ac <fd_close+0x71>
		else
			r = 0;
  8013a7:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8013ac:	83 ec 08             	sub    $0x8,%esp
  8013af:	56                   	push   %esi
  8013b0:	6a 00                	push   $0x0
  8013b2:	e8 07 f9 ff ff       	call   800cbe <sys_page_unmap>
	return r;
  8013b7:	83 c4 10             	add    $0x10,%esp
}
  8013ba:	89 d8                	mov    %ebx,%eax
  8013bc:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8013bf:	5b                   	pop    %ebx
  8013c0:	5e                   	pop    %esi
  8013c1:	c9                   	leave  
  8013c2:	c3                   	ret    

008013c3 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8013c3:	55                   	push   %ebp
  8013c4:	89 e5                	mov    %esp,%ebp
  8013c6:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8013c9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013cc:	50                   	push   %eax
  8013cd:	ff 75 08             	pushl  0x8(%ebp)
  8013d0:	e8 aa fe ff ff       	call   80127f <fd_lookup>
  8013d5:	83 c4 08             	add    $0x8,%esp
  8013d8:	85 c0                	test   %eax,%eax
  8013da:	78 10                	js     8013ec <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  8013dc:	83 ec 08             	sub    $0x8,%esp
  8013df:	6a 01                	push   $0x1
  8013e1:	ff 75 f4             	pushl  -0xc(%ebp)
  8013e4:	e8 52 ff ff ff       	call   80133b <fd_close>
  8013e9:	83 c4 10             	add    $0x10,%esp
}
  8013ec:	c9                   	leave  
  8013ed:	c3                   	ret    

008013ee <close_all>:

void
close_all(void)
{
  8013ee:	55                   	push   %ebp
  8013ef:	89 e5                	mov    %esp,%ebp
  8013f1:	53                   	push   %ebx
  8013f2:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8013f5:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8013fa:	83 ec 0c             	sub    $0xc,%esp
  8013fd:	53                   	push   %ebx
  8013fe:	e8 c0 ff ff ff       	call   8013c3 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801403:	43                   	inc    %ebx
  801404:	83 c4 10             	add    $0x10,%esp
  801407:	83 fb 20             	cmp    $0x20,%ebx
  80140a:	75 ee                	jne    8013fa <close_all+0xc>
		close(i);
}
  80140c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80140f:	c9                   	leave  
  801410:	c3                   	ret    

00801411 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801411:	55                   	push   %ebp
  801412:	89 e5                	mov    %esp,%ebp
  801414:	57                   	push   %edi
  801415:	56                   	push   %esi
  801416:	53                   	push   %ebx
  801417:	83 ec 2c             	sub    $0x2c,%esp
  80141a:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80141d:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801420:	50                   	push   %eax
  801421:	ff 75 08             	pushl  0x8(%ebp)
  801424:	e8 56 fe ff ff       	call   80127f <fd_lookup>
  801429:	89 c3                	mov    %eax,%ebx
  80142b:	83 c4 08             	add    $0x8,%esp
  80142e:	85 c0                	test   %eax,%eax
  801430:	0f 88 c0 00 00 00    	js     8014f6 <dup+0xe5>
		return r;
	close(newfdnum);
  801436:	83 ec 0c             	sub    $0xc,%esp
  801439:	57                   	push   %edi
  80143a:	e8 84 ff ff ff       	call   8013c3 <close>

	newfd = INDEX2FD(newfdnum);
  80143f:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  801445:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  801448:	83 c4 04             	add    $0x4,%esp
  80144b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80144e:	e8 a1 fd ff ff       	call   8011f4 <fd2data>
  801453:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801455:	89 34 24             	mov    %esi,(%esp)
  801458:	e8 97 fd ff ff       	call   8011f4 <fd2data>
  80145d:	83 c4 10             	add    $0x10,%esp
  801460:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801463:	89 d8                	mov    %ebx,%eax
  801465:	c1 e8 16             	shr    $0x16,%eax
  801468:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80146f:	a8 01                	test   $0x1,%al
  801471:	74 37                	je     8014aa <dup+0x99>
  801473:	89 d8                	mov    %ebx,%eax
  801475:	c1 e8 0c             	shr    $0xc,%eax
  801478:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80147f:	f6 c2 01             	test   $0x1,%dl
  801482:	74 26                	je     8014aa <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801484:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80148b:	83 ec 0c             	sub    $0xc,%esp
  80148e:	25 07 0e 00 00       	and    $0xe07,%eax
  801493:	50                   	push   %eax
  801494:	ff 75 d4             	pushl  -0x2c(%ebp)
  801497:	6a 00                	push   $0x0
  801499:	53                   	push   %ebx
  80149a:	6a 00                	push   $0x0
  80149c:	e8 f7 f7 ff ff       	call   800c98 <sys_page_map>
  8014a1:	89 c3                	mov    %eax,%ebx
  8014a3:	83 c4 20             	add    $0x20,%esp
  8014a6:	85 c0                	test   %eax,%eax
  8014a8:	78 2d                	js     8014d7 <dup+0xc6>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8014aa:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8014ad:	89 c2                	mov    %eax,%edx
  8014af:	c1 ea 0c             	shr    $0xc,%edx
  8014b2:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8014b9:	83 ec 0c             	sub    $0xc,%esp
  8014bc:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  8014c2:	52                   	push   %edx
  8014c3:	56                   	push   %esi
  8014c4:	6a 00                	push   $0x0
  8014c6:	50                   	push   %eax
  8014c7:	6a 00                	push   $0x0
  8014c9:	e8 ca f7 ff ff       	call   800c98 <sys_page_map>
  8014ce:	89 c3                	mov    %eax,%ebx
  8014d0:	83 c4 20             	add    $0x20,%esp
  8014d3:	85 c0                	test   %eax,%eax
  8014d5:	79 1d                	jns    8014f4 <dup+0xe3>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8014d7:	83 ec 08             	sub    $0x8,%esp
  8014da:	56                   	push   %esi
  8014db:	6a 00                	push   $0x0
  8014dd:	e8 dc f7 ff ff       	call   800cbe <sys_page_unmap>
	sys_page_unmap(0, nva);
  8014e2:	83 c4 08             	add    $0x8,%esp
  8014e5:	ff 75 d4             	pushl  -0x2c(%ebp)
  8014e8:	6a 00                	push   $0x0
  8014ea:	e8 cf f7 ff ff       	call   800cbe <sys_page_unmap>
	return r;
  8014ef:	83 c4 10             	add    $0x10,%esp
  8014f2:	eb 02                	jmp    8014f6 <dup+0xe5>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  8014f4:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  8014f6:	89 d8                	mov    %ebx,%eax
  8014f8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8014fb:	5b                   	pop    %ebx
  8014fc:	5e                   	pop    %esi
  8014fd:	5f                   	pop    %edi
  8014fe:	c9                   	leave  
  8014ff:	c3                   	ret    

00801500 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801500:	55                   	push   %ebp
  801501:	89 e5                	mov    %esp,%ebp
  801503:	53                   	push   %ebx
  801504:	83 ec 14             	sub    $0x14,%esp
  801507:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80150a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80150d:	50                   	push   %eax
  80150e:	53                   	push   %ebx
  80150f:	e8 6b fd ff ff       	call   80127f <fd_lookup>
  801514:	83 c4 08             	add    $0x8,%esp
  801517:	85 c0                	test   %eax,%eax
  801519:	78 67                	js     801582 <read+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80151b:	83 ec 08             	sub    $0x8,%esp
  80151e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801521:	50                   	push   %eax
  801522:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801525:	ff 30                	pushl  (%eax)
  801527:	e8 a9 fd ff ff       	call   8012d5 <dev_lookup>
  80152c:	83 c4 10             	add    $0x10,%esp
  80152f:	85 c0                	test   %eax,%eax
  801531:	78 4f                	js     801582 <read+0x82>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801533:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801536:	8b 50 08             	mov    0x8(%eax),%edx
  801539:	83 e2 03             	and    $0x3,%edx
  80153c:	83 fa 01             	cmp    $0x1,%edx
  80153f:	75 21                	jne    801562 <read+0x62>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801541:	a1 04 40 80 00       	mov    0x804004,%eax
  801546:	8b 40 48             	mov    0x48(%eax),%eax
  801549:	83 ec 04             	sub    $0x4,%esp
  80154c:	53                   	push   %ebx
  80154d:	50                   	push   %eax
  80154e:	68 69 27 80 00       	push   $0x802769
  801553:	e8 e4 ec ff ff       	call   80023c <cprintf>
		return -E_INVAL;
  801558:	83 c4 10             	add    $0x10,%esp
  80155b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801560:	eb 20                	jmp    801582 <read+0x82>
	}
	if (!dev->dev_read)
  801562:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801565:	8b 52 08             	mov    0x8(%edx),%edx
  801568:	85 d2                	test   %edx,%edx
  80156a:	74 11                	je     80157d <read+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80156c:	83 ec 04             	sub    $0x4,%esp
  80156f:	ff 75 10             	pushl  0x10(%ebp)
  801572:	ff 75 0c             	pushl  0xc(%ebp)
  801575:	50                   	push   %eax
  801576:	ff d2                	call   *%edx
  801578:	83 c4 10             	add    $0x10,%esp
  80157b:	eb 05                	jmp    801582 <read+0x82>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80157d:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  801582:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801585:	c9                   	leave  
  801586:	c3                   	ret    

00801587 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801587:	55                   	push   %ebp
  801588:	89 e5                	mov    %esp,%ebp
  80158a:	57                   	push   %edi
  80158b:	56                   	push   %esi
  80158c:	53                   	push   %ebx
  80158d:	83 ec 0c             	sub    $0xc,%esp
  801590:	8b 7d 08             	mov    0x8(%ebp),%edi
  801593:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801596:	85 f6                	test   %esi,%esi
  801598:	74 31                	je     8015cb <readn+0x44>
  80159a:	b8 00 00 00 00       	mov    $0x0,%eax
  80159f:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = read(fdnum, (char*)buf + tot, n - tot);
  8015a4:	83 ec 04             	sub    $0x4,%esp
  8015a7:	89 f2                	mov    %esi,%edx
  8015a9:	29 c2                	sub    %eax,%edx
  8015ab:	52                   	push   %edx
  8015ac:	03 45 0c             	add    0xc(%ebp),%eax
  8015af:	50                   	push   %eax
  8015b0:	57                   	push   %edi
  8015b1:	e8 4a ff ff ff       	call   801500 <read>
		if (m < 0)
  8015b6:	83 c4 10             	add    $0x10,%esp
  8015b9:	85 c0                	test   %eax,%eax
  8015bb:	78 17                	js     8015d4 <readn+0x4d>
			return m;
		if (m == 0)
  8015bd:	85 c0                	test   %eax,%eax
  8015bf:	74 11                	je     8015d2 <readn+0x4b>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8015c1:	01 c3                	add    %eax,%ebx
  8015c3:	89 d8                	mov    %ebx,%eax
  8015c5:	39 f3                	cmp    %esi,%ebx
  8015c7:	72 db                	jb     8015a4 <readn+0x1d>
  8015c9:	eb 09                	jmp    8015d4 <readn+0x4d>
  8015cb:	b8 00 00 00 00       	mov    $0x0,%eax
  8015d0:	eb 02                	jmp    8015d4 <readn+0x4d>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  8015d2:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  8015d4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8015d7:	5b                   	pop    %ebx
  8015d8:	5e                   	pop    %esi
  8015d9:	5f                   	pop    %edi
  8015da:	c9                   	leave  
  8015db:	c3                   	ret    

008015dc <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8015dc:	55                   	push   %ebp
  8015dd:	89 e5                	mov    %esp,%ebp
  8015df:	53                   	push   %ebx
  8015e0:	83 ec 14             	sub    $0x14,%esp
  8015e3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015e6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015e9:	50                   	push   %eax
  8015ea:	53                   	push   %ebx
  8015eb:	e8 8f fc ff ff       	call   80127f <fd_lookup>
  8015f0:	83 c4 08             	add    $0x8,%esp
  8015f3:	85 c0                	test   %eax,%eax
  8015f5:	78 62                	js     801659 <write+0x7d>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015f7:	83 ec 08             	sub    $0x8,%esp
  8015fa:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015fd:	50                   	push   %eax
  8015fe:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801601:	ff 30                	pushl  (%eax)
  801603:	e8 cd fc ff ff       	call   8012d5 <dev_lookup>
  801608:	83 c4 10             	add    $0x10,%esp
  80160b:	85 c0                	test   %eax,%eax
  80160d:	78 4a                	js     801659 <write+0x7d>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80160f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801612:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801616:	75 21                	jne    801639 <write+0x5d>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801618:	a1 04 40 80 00       	mov    0x804004,%eax
  80161d:	8b 40 48             	mov    0x48(%eax),%eax
  801620:	83 ec 04             	sub    $0x4,%esp
  801623:	53                   	push   %ebx
  801624:	50                   	push   %eax
  801625:	68 85 27 80 00       	push   $0x802785
  80162a:	e8 0d ec ff ff       	call   80023c <cprintf>
		return -E_INVAL;
  80162f:	83 c4 10             	add    $0x10,%esp
  801632:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801637:	eb 20                	jmp    801659 <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801639:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80163c:	8b 52 0c             	mov    0xc(%edx),%edx
  80163f:	85 d2                	test   %edx,%edx
  801641:	74 11                	je     801654 <write+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801643:	83 ec 04             	sub    $0x4,%esp
  801646:	ff 75 10             	pushl  0x10(%ebp)
  801649:	ff 75 0c             	pushl  0xc(%ebp)
  80164c:	50                   	push   %eax
  80164d:	ff d2                	call   *%edx
  80164f:	83 c4 10             	add    $0x10,%esp
  801652:	eb 05                	jmp    801659 <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801654:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  801659:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80165c:	c9                   	leave  
  80165d:	c3                   	ret    

0080165e <seek>:

int
seek(int fdnum, off_t offset)
{
  80165e:	55                   	push   %ebp
  80165f:	89 e5                	mov    %esp,%ebp
  801661:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801664:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801667:	50                   	push   %eax
  801668:	ff 75 08             	pushl  0x8(%ebp)
  80166b:	e8 0f fc ff ff       	call   80127f <fd_lookup>
  801670:	83 c4 08             	add    $0x8,%esp
  801673:	85 c0                	test   %eax,%eax
  801675:	78 0e                	js     801685 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801677:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80167a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80167d:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801680:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801685:	c9                   	leave  
  801686:	c3                   	ret    

00801687 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801687:	55                   	push   %ebp
  801688:	89 e5                	mov    %esp,%ebp
  80168a:	53                   	push   %ebx
  80168b:	83 ec 14             	sub    $0x14,%esp
  80168e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801691:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801694:	50                   	push   %eax
  801695:	53                   	push   %ebx
  801696:	e8 e4 fb ff ff       	call   80127f <fd_lookup>
  80169b:	83 c4 08             	add    $0x8,%esp
  80169e:	85 c0                	test   %eax,%eax
  8016a0:	78 5f                	js     801701 <ftruncate+0x7a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016a2:	83 ec 08             	sub    $0x8,%esp
  8016a5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016a8:	50                   	push   %eax
  8016a9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016ac:	ff 30                	pushl  (%eax)
  8016ae:	e8 22 fc ff ff       	call   8012d5 <dev_lookup>
  8016b3:	83 c4 10             	add    $0x10,%esp
  8016b6:	85 c0                	test   %eax,%eax
  8016b8:	78 47                	js     801701 <ftruncate+0x7a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8016ba:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016bd:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8016c1:	75 21                	jne    8016e4 <ftruncate+0x5d>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8016c3:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8016c8:	8b 40 48             	mov    0x48(%eax),%eax
  8016cb:	83 ec 04             	sub    $0x4,%esp
  8016ce:	53                   	push   %ebx
  8016cf:	50                   	push   %eax
  8016d0:	68 48 27 80 00       	push   $0x802748
  8016d5:	e8 62 eb ff ff       	call   80023c <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8016da:	83 c4 10             	add    $0x10,%esp
  8016dd:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8016e2:	eb 1d                	jmp    801701 <ftruncate+0x7a>
	}
	if (!dev->dev_trunc)
  8016e4:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8016e7:	8b 52 18             	mov    0x18(%edx),%edx
  8016ea:	85 d2                	test   %edx,%edx
  8016ec:	74 0e                	je     8016fc <ftruncate+0x75>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8016ee:	83 ec 08             	sub    $0x8,%esp
  8016f1:	ff 75 0c             	pushl  0xc(%ebp)
  8016f4:	50                   	push   %eax
  8016f5:	ff d2                	call   *%edx
  8016f7:	83 c4 10             	add    $0x10,%esp
  8016fa:	eb 05                	jmp    801701 <ftruncate+0x7a>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8016fc:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  801701:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801704:	c9                   	leave  
  801705:	c3                   	ret    

00801706 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801706:	55                   	push   %ebp
  801707:	89 e5                	mov    %esp,%ebp
  801709:	53                   	push   %ebx
  80170a:	83 ec 14             	sub    $0x14,%esp
  80170d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801710:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801713:	50                   	push   %eax
  801714:	ff 75 08             	pushl  0x8(%ebp)
  801717:	e8 63 fb ff ff       	call   80127f <fd_lookup>
  80171c:	83 c4 08             	add    $0x8,%esp
  80171f:	85 c0                	test   %eax,%eax
  801721:	78 52                	js     801775 <fstat+0x6f>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801723:	83 ec 08             	sub    $0x8,%esp
  801726:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801729:	50                   	push   %eax
  80172a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80172d:	ff 30                	pushl  (%eax)
  80172f:	e8 a1 fb ff ff       	call   8012d5 <dev_lookup>
  801734:	83 c4 10             	add    $0x10,%esp
  801737:	85 c0                	test   %eax,%eax
  801739:	78 3a                	js     801775 <fstat+0x6f>
		return r;
	if (!dev->dev_stat)
  80173b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80173e:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801742:	74 2c                	je     801770 <fstat+0x6a>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801744:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801747:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80174e:	00 00 00 
	stat->st_isdir = 0;
  801751:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801758:	00 00 00 
	stat->st_dev = dev;
  80175b:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801761:	83 ec 08             	sub    $0x8,%esp
  801764:	53                   	push   %ebx
  801765:	ff 75 f0             	pushl  -0x10(%ebp)
  801768:	ff 50 14             	call   *0x14(%eax)
  80176b:	83 c4 10             	add    $0x10,%esp
  80176e:	eb 05                	jmp    801775 <fstat+0x6f>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801770:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801775:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801778:	c9                   	leave  
  801779:	c3                   	ret    

0080177a <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80177a:	55                   	push   %ebp
  80177b:	89 e5                	mov    %esp,%ebp
  80177d:	56                   	push   %esi
  80177e:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80177f:	83 ec 08             	sub    $0x8,%esp
  801782:	6a 00                	push   $0x0
  801784:	ff 75 08             	pushl  0x8(%ebp)
  801787:	e8 8b 01 00 00       	call   801917 <open>
  80178c:	89 c3                	mov    %eax,%ebx
  80178e:	83 c4 10             	add    $0x10,%esp
  801791:	85 c0                	test   %eax,%eax
  801793:	78 1b                	js     8017b0 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801795:	83 ec 08             	sub    $0x8,%esp
  801798:	ff 75 0c             	pushl  0xc(%ebp)
  80179b:	50                   	push   %eax
  80179c:	e8 65 ff ff ff       	call   801706 <fstat>
  8017a1:	89 c6                	mov    %eax,%esi
	close(fd);
  8017a3:	89 1c 24             	mov    %ebx,(%esp)
  8017a6:	e8 18 fc ff ff       	call   8013c3 <close>
	return r;
  8017ab:	83 c4 10             	add    $0x10,%esp
  8017ae:	89 f3                	mov    %esi,%ebx
}
  8017b0:	89 d8                	mov    %ebx,%eax
  8017b2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017b5:	5b                   	pop    %ebx
  8017b6:	5e                   	pop    %esi
  8017b7:	c9                   	leave  
  8017b8:	c3                   	ret    
  8017b9:	00 00                	add    %al,(%eax)
	...

008017bc <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8017bc:	55                   	push   %ebp
  8017bd:	89 e5                	mov    %esp,%ebp
  8017bf:	56                   	push   %esi
  8017c0:	53                   	push   %ebx
  8017c1:	89 c3                	mov    %eax,%ebx
  8017c3:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  8017c5:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8017cc:	75 12                	jne    8017e0 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8017ce:	83 ec 0c             	sub    $0xc,%esp
  8017d1:	6a 01                	push   $0x1
  8017d3:	e8 b1 f9 ff ff       	call   801189 <ipc_find_env>
  8017d8:	a3 00 40 80 00       	mov    %eax,0x804000
  8017dd:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8017e0:	6a 07                	push   $0x7
  8017e2:	68 00 50 80 00       	push   $0x805000
  8017e7:	53                   	push   %ebx
  8017e8:	ff 35 00 40 80 00    	pushl  0x804000
  8017ee:	e8 41 f9 ff ff       	call   801134 <ipc_send>
	
	return ipc_recv(NULL, dstva, NULL);
  8017f3:	83 c4 0c             	add    $0xc,%esp
  8017f6:	6a 00                	push   $0x0
  8017f8:	56                   	push   %esi
  8017f9:	6a 00                	push   $0x0
  8017fb:	e8 8c f8 ff ff       	call   80108c <ipc_recv>
}
  801800:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801803:	5b                   	pop    %ebx
  801804:	5e                   	pop    %esi
  801805:	c9                   	leave  
  801806:	c3                   	ret    

00801807 <devfile_stat>:
}


static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801807:	55                   	push   %ebp
  801808:	89 e5                	mov    %esp,%ebp
  80180a:	53                   	push   %ebx
  80180b:	83 ec 04             	sub    $0x4,%esp
  80180e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801811:	8b 45 08             	mov    0x8(%ebp),%eax
  801814:	8b 40 0c             	mov    0xc(%eax),%eax
  801817:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0) {
  80181c:	ba 00 00 00 00       	mov    $0x0,%edx
  801821:	b8 05 00 00 00       	mov    $0x5,%eax
  801826:	e8 91 ff ff ff       	call   8017bc <fsipc>
  80182b:	85 c0                	test   %eax,%eax
  80182d:	78 39                	js     801868 <devfile_stat+0x61>
		return r;
	}
	cprintf("OVER\n");
  80182f:	83 ec 0c             	sub    $0xc,%esp
  801832:	68 05 27 80 00       	push   $0x802705
  801837:	e8 00 ea ff ff       	call   80023c <cprintf>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80183c:	83 c4 08             	add    $0x8,%esp
  80183f:	68 00 50 80 00       	push   $0x805000
  801844:	53                   	push   %ebx
  801845:	e8 a8 ef ff ff       	call   8007f2 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  80184a:	a1 80 50 80 00       	mov    0x805080,%eax
  80184f:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801855:	a1 84 50 80 00       	mov    0x805084,%eax
  80185a:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801860:	83 c4 10             	add    $0x10,%esp
  801863:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801868:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80186b:	c9                   	leave  
  80186c:	c3                   	ret    

0080186d <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80186d:	55                   	push   %ebp
  80186e:	89 e5                	mov    %esp,%ebp
  801870:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801873:	8b 45 08             	mov    0x8(%ebp),%eax
  801876:	8b 40 0c             	mov    0xc(%eax),%eax
  801879:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80187e:	ba 00 00 00 00       	mov    $0x0,%edx
  801883:	b8 06 00 00 00       	mov    $0x6,%eax
  801888:	e8 2f ff ff ff       	call   8017bc <fsipc>
}
  80188d:	c9                   	leave  
  80188e:	c3                   	ret    

0080188f <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  80188f:	55                   	push   %ebp
  801890:	89 e5                	mov    %esp,%ebp
  801892:	56                   	push   %esi
  801893:	53                   	push   %ebx
  801894:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801897:	8b 45 08             	mov    0x8(%ebp),%eax
  80189a:	8b 40 0c             	mov    0xc(%eax),%eax
  80189d:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8018a2:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8018a8:	ba 00 00 00 00       	mov    $0x0,%edx
  8018ad:	b8 03 00 00 00       	mov    $0x3,%eax
  8018b2:	e8 05 ff ff ff       	call   8017bc <fsipc>
  8018b7:	89 c3                	mov    %eax,%ebx
  8018b9:	85 c0                	test   %eax,%eax
  8018bb:	78 51                	js     80190e <devfile_read+0x7f>
		return r;
	assert(r <= n);
  8018bd:	39 c6                	cmp    %eax,%esi
  8018bf:	73 19                	jae    8018da <devfile_read+0x4b>
  8018c1:	68 b4 27 80 00       	push   $0x8027b4
  8018c6:	68 bb 27 80 00       	push   $0x8027bb
  8018cb:	68 80 00 00 00       	push   $0x80
  8018d0:	68 d0 27 80 00       	push   $0x8027d0
  8018d5:	e8 8a e8 ff ff       	call   800164 <_panic>
	assert(r <= PGSIZE);
  8018da:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8018df:	7e 19                	jle    8018fa <devfile_read+0x6b>
  8018e1:	68 db 27 80 00       	push   $0x8027db
  8018e6:	68 bb 27 80 00       	push   $0x8027bb
  8018eb:	68 81 00 00 00       	push   $0x81
  8018f0:	68 d0 27 80 00       	push   $0x8027d0
  8018f5:	e8 6a e8 ff ff       	call   800164 <_panic>
	memmove(buf, &fsipcbuf, r);
  8018fa:	83 ec 04             	sub    $0x4,%esp
  8018fd:	50                   	push   %eax
  8018fe:	68 00 50 80 00       	push   $0x805000
  801903:	ff 75 0c             	pushl  0xc(%ebp)
  801906:	e8 a8 f0 ff ff       	call   8009b3 <memmove>
	return r;
  80190b:	83 c4 10             	add    $0x10,%esp
}
  80190e:	89 d8                	mov    %ebx,%eax
  801910:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801913:	5b                   	pop    %ebx
  801914:	5e                   	pop    %esi
  801915:	c9                   	leave  
  801916:	c3                   	ret    

00801917 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801917:	55                   	push   %ebp
  801918:	89 e5                	mov    %esp,%ebp
  80191a:	56                   	push   %esi
  80191b:	53                   	push   %ebx
  80191c:	83 ec 1c             	sub    $0x1c,%esp
  80191f:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801922:	56                   	push   %esi
  801923:	e8 78 ee ff ff       	call   8007a0 <strlen>
  801928:	83 c4 10             	add    $0x10,%esp
  80192b:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801930:	7f 72                	jg     8019a4 <open+0x8d>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801932:	83 ec 0c             	sub    $0xc,%esp
  801935:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801938:	50                   	push   %eax
  801939:	e8 ce f8 ff ff       	call   80120c <fd_alloc>
  80193e:	89 c3                	mov    %eax,%ebx
  801940:	83 c4 10             	add    $0x10,%esp
  801943:	85 c0                	test   %eax,%eax
  801945:	78 62                	js     8019a9 <open+0x92>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801947:	83 ec 08             	sub    $0x8,%esp
  80194a:	56                   	push   %esi
  80194b:	68 00 50 80 00       	push   $0x805000
  801950:	e8 9d ee ff ff       	call   8007f2 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801955:	8b 45 0c             	mov    0xc(%ebp),%eax
  801958:	a3 00 54 80 00       	mov    %eax,0x805400



	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  80195d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801960:	b8 01 00 00 00       	mov    $0x1,%eax
  801965:	e8 52 fe ff ff       	call   8017bc <fsipc>
  80196a:	89 c3                	mov    %eax,%ebx
  80196c:	83 c4 10             	add    $0x10,%esp
  80196f:	85 c0                	test   %eax,%eax
  801971:	79 12                	jns    801985 <open+0x6e>
		fd_close(fd, 0);
  801973:	83 ec 08             	sub    $0x8,%esp
  801976:	6a 00                	push   $0x0
  801978:	ff 75 f4             	pushl  -0xc(%ebp)
  80197b:	e8 bb f9 ff ff       	call   80133b <fd_close>
		return r;
  801980:	83 c4 10             	add    $0x10,%esp
  801983:	eb 24                	jmp    8019a9 <open+0x92>
	}


	cprintf("OPEN\n");
  801985:	83 ec 0c             	sub    $0xc,%esp
  801988:	68 e7 27 80 00       	push   $0x8027e7
  80198d:	e8 aa e8 ff ff       	call   80023c <cprintf>

	return fd2num(fd);
  801992:	83 c4 04             	add    $0x4,%esp
  801995:	ff 75 f4             	pushl  -0xc(%ebp)
  801998:	e8 47 f8 ff ff       	call   8011e4 <fd2num>
  80199d:	89 c3                	mov    %eax,%ebx
  80199f:	83 c4 10             	add    $0x10,%esp
  8019a2:	eb 05                	jmp    8019a9 <open+0x92>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8019a4:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx


	cprintf("OPEN\n");

	return fd2num(fd);
}
  8019a9:	89 d8                	mov    %ebx,%eax
  8019ab:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8019ae:	5b                   	pop    %ebx
  8019af:	5e                   	pop    %esi
  8019b0:	c9                   	leave  
  8019b1:	c3                   	ret    
	...

008019b4 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8019b4:	55                   	push   %ebp
  8019b5:	89 e5                	mov    %esp,%ebp
  8019b7:	56                   	push   %esi
  8019b8:	53                   	push   %ebx
  8019b9:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8019bc:	83 ec 0c             	sub    $0xc,%esp
  8019bf:	ff 75 08             	pushl  0x8(%ebp)
  8019c2:	e8 2d f8 ff ff       	call   8011f4 <fd2data>
  8019c7:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  8019c9:	83 c4 08             	add    $0x8,%esp
  8019cc:	68 ed 27 80 00       	push   $0x8027ed
  8019d1:	56                   	push   %esi
  8019d2:	e8 1b ee ff ff       	call   8007f2 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8019d7:	8b 43 04             	mov    0x4(%ebx),%eax
  8019da:	2b 03                	sub    (%ebx),%eax
  8019dc:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  8019e2:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  8019e9:	00 00 00 
	stat->st_dev = &devpipe;
  8019ec:	c7 86 88 00 00 00 20 	movl   $0x803020,0x88(%esi)
  8019f3:	30 80 00 
	return 0;
}
  8019f6:	b8 00 00 00 00       	mov    $0x0,%eax
  8019fb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8019fe:	5b                   	pop    %ebx
  8019ff:	5e                   	pop    %esi
  801a00:	c9                   	leave  
  801a01:	c3                   	ret    

00801a02 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801a02:	55                   	push   %ebp
  801a03:	89 e5                	mov    %esp,%ebp
  801a05:	53                   	push   %ebx
  801a06:	83 ec 0c             	sub    $0xc,%esp
  801a09:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801a0c:	53                   	push   %ebx
  801a0d:	6a 00                	push   $0x0
  801a0f:	e8 aa f2 ff ff       	call   800cbe <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801a14:	89 1c 24             	mov    %ebx,(%esp)
  801a17:	e8 d8 f7 ff ff       	call   8011f4 <fd2data>
  801a1c:	83 c4 08             	add    $0x8,%esp
  801a1f:	50                   	push   %eax
  801a20:	6a 00                	push   $0x0
  801a22:	e8 97 f2 ff ff       	call   800cbe <sys_page_unmap>
}
  801a27:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a2a:	c9                   	leave  
  801a2b:	c3                   	ret    

00801a2c <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801a2c:	55                   	push   %ebp
  801a2d:	89 e5                	mov    %esp,%ebp
  801a2f:	57                   	push   %edi
  801a30:	56                   	push   %esi
  801a31:	53                   	push   %ebx
  801a32:	83 ec 1c             	sub    $0x1c,%esp
  801a35:	89 c7                	mov    %eax,%edi
  801a37:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801a3a:	a1 04 40 80 00       	mov    0x804004,%eax
  801a3f:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801a42:	83 ec 0c             	sub    $0xc,%esp
  801a45:	57                   	push   %edi
  801a46:	e8 01 05 00 00       	call   801f4c <pageref>
  801a4b:	89 c6                	mov    %eax,%esi
  801a4d:	83 c4 04             	add    $0x4,%esp
  801a50:	ff 75 e4             	pushl  -0x1c(%ebp)
  801a53:	e8 f4 04 00 00       	call   801f4c <pageref>
  801a58:	83 c4 10             	add    $0x10,%esp
  801a5b:	39 c6                	cmp    %eax,%esi
  801a5d:	0f 94 c0             	sete   %al
  801a60:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  801a63:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801a69:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801a6c:	39 cb                	cmp    %ecx,%ebx
  801a6e:	75 08                	jne    801a78 <_pipeisclosed+0x4c>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  801a70:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a73:	5b                   	pop    %ebx
  801a74:	5e                   	pop    %esi
  801a75:	5f                   	pop    %edi
  801a76:	c9                   	leave  
  801a77:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  801a78:	83 f8 01             	cmp    $0x1,%eax
  801a7b:	75 bd                	jne    801a3a <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801a7d:	8b 42 58             	mov    0x58(%edx),%eax
  801a80:	6a 01                	push   $0x1
  801a82:	50                   	push   %eax
  801a83:	53                   	push   %ebx
  801a84:	68 f4 27 80 00       	push   $0x8027f4
  801a89:	e8 ae e7 ff ff       	call   80023c <cprintf>
  801a8e:	83 c4 10             	add    $0x10,%esp
  801a91:	eb a7                	jmp    801a3a <_pipeisclosed+0xe>

00801a93 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801a93:	55                   	push   %ebp
  801a94:	89 e5                	mov    %esp,%ebp
  801a96:	57                   	push   %edi
  801a97:	56                   	push   %esi
  801a98:	53                   	push   %ebx
  801a99:	83 ec 28             	sub    $0x28,%esp
  801a9c:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801a9f:	56                   	push   %esi
  801aa0:	e8 4f f7 ff ff       	call   8011f4 <fd2data>
  801aa5:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801aa7:	83 c4 10             	add    $0x10,%esp
  801aaa:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801aae:	75 4a                	jne    801afa <devpipe_write+0x67>
  801ab0:	bf 00 00 00 00       	mov    $0x0,%edi
  801ab5:	eb 56                	jmp    801b0d <devpipe_write+0x7a>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801ab7:	89 da                	mov    %ebx,%edx
  801ab9:	89 f0                	mov    %esi,%eax
  801abb:	e8 6c ff ff ff       	call   801a2c <_pipeisclosed>
  801ac0:	85 c0                	test   %eax,%eax
  801ac2:	75 4d                	jne    801b11 <devpipe_write+0x7e>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801ac4:	e8 84 f1 ff ff       	call   800c4d <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801ac9:	8b 43 04             	mov    0x4(%ebx),%eax
  801acc:	8b 13                	mov    (%ebx),%edx
  801ace:	83 c2 20             	add    $0x20,%edx
  801ad1:	39 d0                	cmp    %edx,%eax
  801ad3:	73 e2                	jae    801ab7 <devpipe_write+0x24>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801ad5:	89 c2                	mov    %eax,%edx
  801ad7:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  801add:	79 05                	jns    801ae4 <devpipe_write+0x51>
  801adf:	4a                   	dec    %edx
  801ae0:	83 ca e0             	or     $0xffffffe0,%edx
  801ae3:	42                   	inc    %edx
  801ae4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801ae7:	8a 0c 39             	mov    (%ecx,%edi,1),%cl
  801aea:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801aee:	40                   	inc    %eax
  801aef:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801af2:	47                   	inc    %edi
  801af3:	39 7d 10             	cmp    %edi,0x10(%ebp)
  801af6:	77 07                	ja     801aff <devpipe_write+0x6c>
  801af8:	eb 13                	jmp    801b0d <devpipe_write+0x7a>
  801afa:	bf 00 00 00 00       	mov    $0x0,%edi
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801aff:	8b 43 04             	mov    0x4(%ebx),%eax
  801b02:	8b 13                	mov    (%ebx),%edx
  801b04:	83 c2 20             	add    $0x20,%edx
  801b07:	39 d0                	cmp    %edx,%eax
  801b09:	73 ac                	jae    801ab7 <devpipe_write+0x24>
  801b0b:	eb c8                	jmp    801ad5 <devpipe_write+0x42>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801b0d:	89 f8                	mov    %edi,%eax
  801b0f:	eb 05                	jmp    801b16 <devpipe_write+0x83>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801b11:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801b16:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b19:	5b                   	pop    %ebx
  801b1a:	5e                   	pop    %esi
  801b1b:	5f                   	pop    %edi
  801b1c:	c9                   	leave  
  801b1d:	c3                   	ret    

00801b1e <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801b1e:	55                   	push   %ebp
  801b1f:	89 e5                	mov    %esp,%ebp
  801b21:	57                   	push   %edi
  801b22:	56                   	push   %esi
  801b23:	53                   	push   %ebx
  801b24:	83 ec 18             	sub    $0x18,%esp
  801b27:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801b2a:	57                   	push   %edi
  801b2b:	e8 c4 f6 ff ff       	call   8011f4 <fd2data>
  801b30:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b32:	83 c4 10             	add    $0x10,%esp
  801b35:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801b39:	75 44                	jne    801b7f <devpipe_read+0x61>
  801b3b:	be 00 00 00 00       	mov    $0x0,%esi
  801b40:	eb 4f                	jmp    801b91 <devpipe_read+0x73>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
				return i;
  801b42:	89 f0                	mov    %esi,%eax
  801b44:	eb 54                	jmp    801b9a <devpipe_read+0x7c>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801b46:	89 da                	mov    %ebx,%edx
  801b48:	89 f8                	mov    %edi,%eax
  801b4a:	e8 dd fe ff ff       	call   801a2c <_pipeisclosed>
  801b4f:	85 c0                	test   %eax,%eax
  801b51:	75 42                	jne    801b95 <devpipe_read+0x77>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801b53:	e8 f5 f0 ff ff       	call   800c4d <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801b58:	8b 03                	mov    (%ebx),%eax
  801b5a:	3b 43 04             	cmp    0x4(%ebx),%eax
  801b5d:	74 e7                	je     801b46 <devpipe_read+0x28>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801b5f:	25 1f 00 00 80       	and    $0x8000001f,%eax
  801b64:	79 05                	jns    801b6b <devpipe_read+0x4d>
  801b66:	48                   	dec    %eax
  801b67:	83 c8 e0             	or     $0xffffffe0,%eax
  801b6a:	40                   	inc    %eax
  801b6b:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  801b6f:	8b 55 0c             	mov    0xc(%ebp),%edx
  801b72:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  801b75:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b77:	46                   	inc    %esi
  801b78:	39 75 10             	cmp    %esi,0x10(%ebp)
  801b7b:	77 07                	ja     801b84 <devpipe_read+0x66>
  801b7d:	eb 12                	jmp    801b91 <devpipe_read+0x73>
  801b7f:	be 00 00 00 00       	mov    $0x0,%esi
		while (p->p_rpos == p->p_wpos) {
  801b84:	8b 03                	mov    (%ebx),%eax
  801b86:	3b 43 04             	cmp    0x4(%ebx),%eax
  801b89:	75 d4                	jne    801b5f <devpipe_read+0x41>
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801b8b:	85 f6                	test   %esi,%esi
  801b8d:	75 b3                	jne    801b42 <devpipe_read+0x24>
  801b8f:	eb b5                	jmp    801b46 <devpipe_read+0x28>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801b91:	89 f0                	mov    %esi,%eax
  801b93:	eb 05                	jmp    801b9a <devpipe_read+0x7c>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801b95:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801b9a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b9d:	5b                   	pop    %ebx
  801b9e:	5e                   	pop    %esi
  801b9f:	5f                   	pop    %edi
  801ba0:	c9                   	leave  
  801ba1:	c3                   	ret    

00801ba2 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801ba2:	55                   	push   %ebp
  801ba3:	89 e5                	mov    %esp,%ebp
  801ba5:	57                   	push   %edi
  801ba6:	56                   	push   %esi
  801ba7:	53                   	push   %ebx
  801ba8:	83 ec 28             	sub    $0x28,%esp
  801bab:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801bae:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801bb1:	50                   	push   %eax
  801bb2:	e8 55 f6 ff ff       	call   80120c <fd_alloc>
  801bb7:	89 c3                	mov    %eax,%ebx
  801bb9:	83 c4 10             	add    $0x10,%esp
  801bbc:	85 c0                	test   %eax,%eax
  801bbe:	0f 88 24 01 00 00    	js     801ce8 <pipe+0x146>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801bc4:	83 ec 04             	sub    $0x4,%esp
  801bc7:	68 07 04 00 00       	push   $0x407
  801bcc:	ff 75 e4             	pushl  -0x1c(%ebp)
  801bcf:	6a 00                	push   $0x0
  801bd1:	e8 9e f0 ff ff       	call   800c74 <sys_page_alloc>
  801bd6:	89 c3                	mov    %eax,%ebx
  801bd8:	83 c4 10             	add    $0x10,%esp
  801bdb:	85 c0                	test   %eax,%eax
  801bdd:	0f 88 05 01 00 00    	js     801ce8 <pipe+0x146>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801be3:	83 ec 0c             	sub    $0xc,%esp
  801be6:	8d 45 e0             	lea    -0x20(%ebp),%eax
  801be9:	50                   	push   %eax
  801bea:	e8 1d f6 ff ff       	call   80120c <fd_alloc>
  801bef:	89 c3                	mov    %eax,%ebx
  801bf1:	83 c4 10             	add    $0x10,%esp
  801bf4:	85 c0                	test   %eax,%eax
  801bf6:	0f 88 dc 00 00 00    	js     801cd8 <pipe+0x136>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801bfc:	83 ec 04             	sub    $0x4,%esp
  801bff:	68 07 04 00 00       	push   $0x407
  801c04:	ff 75 e0             	pushl  -0x20(%ebp)
  801c07:	6a 00                	push   $0x0
  801c09:	e8 66 f0 ff ff       	call   800c74 <sys_page_alloc>
  801c0e:	89 c3                	mov    %eax,%ebx
  801c10:	83 c4 10             	add    $0x10,%esp
  801c13:	85 c0                	test   %eax,%eax
  801c15:	0f 88 bd 00 00 00    	js     801cd8 <pipe+0x136>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801c1b:	83 ec 0c             	sub    $0xc,%esp
  801c1e:	ff 75 e4             	pushl  -0x1c(%ebp)
  801c21:	e8 ce f5 ff ff       	call   8011f4 <fd2data>
  801c26:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c28:	83 c4 0c             	add    $0xc,%esp
  801c2b:	68 07 04 00 00       	push   $0x407
  801c30:	50                   	push   %eax
  801c31:	6a 00                	push   $0x0
  801c33:	e8 3c f0 ff ff       	call   800c74 <sys_page_alloc>
  801c38:	89 c3                	mov    %eax,%ebx
  801c3a:	83 c4 10             	add    $0x10,%esp
  801c3d:	85 c0                	test   %eax,%eax
  801c3f:	0f 88 83 00 00 00    	js     801cc8 <pipe+0x126>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c45:	83 ec 0c             	sub    $0xc,%esp
  801c48:	ff 75 e0             	pushl  -0x20(%ebp)
  801c4b:	e8 a4 f5 ff ff       	call   8011f4 <fd2data>
  801c50:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801c57:	50                   	push   %eax
  801c58:	6a 00                	push   $0x0
  801c5a:	56                   	push   %esi
  801c5b:	6a 00                	push   $0x0
  801c5d:	e8 36 f0 ff ff       	call   800c98 <sys_page_map>
  801c62:	89 c3                	mov    %eax,%ebx
  801c64:	83 c4 20             	add    $0x20,%esp
  801c67:	85 c0                	test   %eax,%eax
  801c69:	78 4f                	js     801cba <pipe+0x118>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801c6b:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801c71:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801c74:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801c76:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801c79:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801c80:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801c86:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801c89:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801c8b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801c8e:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801c95:	83 ec 0c             	sub    $0xc,%esp
  801c98:	ff 75 e4             	pushl  -0x1c(%ebp)
  801c9b:	e8 44 f5 ff ff       	call   8011e4 <fd2num>
  801ca0:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  801ca2:	83 c4 04             	add    $0x4,%esp
  801ca5:	ff 75 e0             	pushl  -0x20(%ebp)
  801ca8:	e8 37 f5 ff ff       	call   8011e4 <fd2num>
  801cad:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  801cb0:	83 c4 10             	add    $0x10,%esp
  801cb3:	bb 00 00 00 00       	mov    $0x0,%ebx
  801cb8:	eb 2e                	jmp    801ce8 <pipe+0x146>

    err3:
	sys_page_unmap(0, va);
  801cba:	83 ec 08             	sub    $0x8,%esp
  801cbd:	56                   	push   %esi
  801cbe:	6a 00                	push   $0x0
  801cc0:	e8 f9 ef ff ff       	call   800cbe <sys_page_unmap>
  801cc5:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801cc8:	83 ec 08             	sub    $0x8,%esp
  801ccb:	ff 75 e0             	pushl  -0x20(%ebp)
  801cce:	6a 00                	push   $0x0
  801cd0:	e8 e9 ef ff ff       	call   800cbe <sys_page_unmap>
  801cd5:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801cd8:	83 ec 08             	sub    $0x8,%esp
  801cdb:	ff 75 e4             	pushl  -0x1c(%ebp)
  801cde:	6a 00                	push   $0x0
  801ce0:	e8 d9 ef ff ff       	call   800cbe <sys_page_unmap>
  801ce5:	83 c4 10             	add    $0x10,%esp
    err:
	return r;
}
  801ce8:	89 d8                	mov    %ebx,%eax
  801cea:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ced:	5b                   	pop    %ebx
  801cee:	5e                   	pop    %esi
  801cef:	5f                   	pop    %edi
  801cf0:	c9                   	leave  
  801cf1:	c3                   	ret    

00801cf2 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801cf2:	55                   	push   %ebp
  801cf3:	89 e5                	mov    %esp,%ebp
  801cf5:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801cf8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801cfb:	50                   	push   %eax
  801cfc:	ff 75 08             	pushl  0x8(%ebp)
  801cff:	e8 7b f5 ff ff       	call   80127f <fd_lookup>
  801d04:	83 c4 10             	add    $0x10,%esp
  801d07:	85 c0                	test   %eax,%eax
  801d09:	78 18                	js     801d23 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801d0b:	83 ec 0c             	sub    $0xc,%esp
  801d0e:	ff 75 f4             	pushl  -0xc(%ebp)
  801d11:	e8 de f4 ff ff       	call   8011f4 <fd2data>
	return _pipeisclosed(fd, p);
  801d16:	89 c2                	mov    %eax,%edx
  801d18:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d1b:	e8 0c fd ff ff       	call   801a2c <_pipeisclosed>
  801d20:	83 c4 10             	add    $0x10,%esp
}
  801d23:	c9                   	leave  
  801d24:	c3                   	ret    
  801d25:	00 00                	add    %al,(%eax)
	...

00801d28 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801d28:	55                   	push   %ebp
  801d29:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801d2b:	b8 00 00 00 00       	mov    $0x0,%eax
  801d30:	c9                   	leave  
  801d31:	c3                   	ret    

00801d32 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801d32:	55                   	push   %ebp
  801d33:	89 e5                	mov    %esp,%ebp
  801d35:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801d38:	68 0c 28 80 00       	push   $0x80280c
  801d3d:	ff 75 0c             	pushl  0xc(%ebp)
  801d40:	e8 ad ea ff ff       	call   8007f2 <strcpy>
	return 0;
}
  801d45:	b8 00 00 00 00       	mov    $0x0,%eax
  801d4a:	c9                   	leave  
  801d4b:	c3                   	ret    

00801d4c <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801d4c:	55                   	push   %ebp
  801d4d:	89 e5                	mov    %esp,%ebp
  801d4f:	57                   	push   %edi
  801d50:	56                   	push   %esi
  801d51:	53                   	push   %ebx
  801d52:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801d58:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801d5c:	74 45                	je     801da3 <devcons_write+0x57>
  801d5e:	b8 00 00 00 00       	mov    $0x0,%eax
  801d63:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801d68:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801d6e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801d71:	29 c3                	sub    %eax,%ebx
		if (m > sizeof(buf) - 1)
  801d73:	83 fb 7f             	cmp    $0x7f,%ebx
  801d76:	76 05                	jbe    801d7d <devcons_write+0x31>
			m = sizeof(buf) - 1;
  801d78:	bb 7f 00 00 00       	mov    $0x7f,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  801d7d:	83 ec 04             	sub    $0x4,%esp
  801d80:	53                   	push   %ebx
  801d81:	03 45 0c             	add    0xc(%ebp),%eax
  801d84:	50                   	push   %eax
  801d85:	57                   	push   %edi
  801d86:	e8 28 ec ff ff       	call   8009b3 <memmove>
		sys_cputs(buf, m);
  801d8b:	83 c4 08             	add    $0x8,%esp
  801d8e:	53                   	push   %ebx
  801d8f:	57                   	push   %edi
  801d90:	e8 28 ee ff ff       	call   800bbd <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801d95:	01 de                	add    %ebx,%esi
  801d97:	89 f0                	mov    %esi,%eax
  801d99:	83 c4 10             	add    $0x10,%esp
  801d9c:	3b 75 10             	cmp    0x10(%ebp),%esi
  801d9f:	72 cd                	jb     801d6e <devcons_write+0x22>
  801da1:	eb 05                	jmp    801da8 <devcons_write+0x5c>
  801da3:	be 00 00 00 00       	mov    $0x0,%esi
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801da8:	89 f0                	mov    %esi,%eax
  801daa:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801dad:	5b                   	pop    %ebx
  801dae:	5e                   	pop    %esi
  801daf:	5f                   	pop    %edi
  801db0:	c9                   	leave  
  801db1:	c3                   	ret    

00801db2 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801db2:	55                   	push   %ebp
  801db3:	89 e5                	mov    %esp,%ebp
  801db5:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  801db8:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801dbc:	75 07                	jne    801dc5 <devcons_read+0x13>
  801dbe:	eb 25                	jmp    801de5 <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801dc0:	e8 88 ee ff ff       	call   800c4d <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801dc5:	e8 19 ee ff ff       	call   800be3 <sys_cgetc>
  801dca:	85 c0                	test   %eax,%eax
  801dcc:	74 f2                	je     801dc0 <devcons_read+0xe>
  801dce:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  801dd0:	85 c0                	test   %eax,%eax
  801dd2:	78 1d                	js     801df1 <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801dd4:	83 f8 04             	cmp    $0x4,%eax
  801dd7:	74 13                	je     801dec <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  801dd9:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ddc:	88 10                	mov    %dl,(%eax)
	return 1;
  801dde:	b8 01 00 00 00       	mov    $0x1,%eax
  801de3:	eb 0c                	jmp    801df1 <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  801de5:	b8 00 00 00 00       	mov    $0x0,%eax
  801dea:	eb 05                	jmp    801df1 <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801dec:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801df1:	c9                   	leave  
  801df2:	c3                   	ret    

00801df3 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801df3:	55                   	push   %ebp
  801df4:	89 e5                	mov    %esp,%ebp
  801df6:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801df9:	8b 45 08             	mov    0x8(%ebp),%eax
  801dfc:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801dff:	6a 01                	push   $0x1
  801e01:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801e04:	50                   	push   %eax
  801e05:	e8 b3 ed ff ff       	call   800bbd <sys_cputs>
  801e0a:	83 c4 10             	add    $0x10,%esp
}
  801e0d:	c9                   	leave  
  801e0e:	c3                   	ret    

00801e0f <getchar>:

int
getchar(void)
{
  801e0f:	55                   	push   %ebp
  801e10:	89 e5                	mov    %esp,%ebp
  801e12:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801e15:	6a 01                	push   $0x1
  801e17:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801e1a:	50                   	push   %eax
  801e1b:	6a 00                	push   $0x0
  801e1d:	e8 de f6 ff ff       	call   801500 <read>
	if (r < 0)
  801e22:	83 c4 10             	add    $0x10,%esp
  801e25:	85 c0                	test   %eax,%eax
  801e27:	78 0f                	js     801e38 <getchar+0x29>
		return r;
	if (r < 1)
  801e29:	85 c0                	test   %eax,%eax
  801e2b:	7e 06                	jle    801e33 <getchar+0x24>
		return -E_EOF;
	return c;
  801e2d:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801e31:	eb 05                	jmp    801e38 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801e33:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801e38:	c9                   	leave  
  801e39:	c3                   	ret    

00801e3a <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801e3a:	55                   	push   %ebp
  801e3b:	89 e5                	mov    %esp,%ebp
  801e3d:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801e40:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e43:	50                   	push   %eax
  801e44:	ff 75 08             	pushl  0x8(%ebp)
  801e47:	e8 33 f4 ff ff       	call   80127f <fd_lookup>
  801e4c:	83 c4 10             	add    $0x10,%esp
  801e4f:	85 c0                	test   %eax,%eax
  801e51:	78 11                	js     801e64 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801e53:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e56:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801e5c:	39 10                	cmp    %edx,(%eax)
  801e5e:	0f 94 c0             	sete   %al
  801e61:	0f b6 c0             	movzbl %al,%eax
}
  801e64:	c9                   	leave  
  801e65:	c3                   	ret    

00801e66 <opencons>:

int
opencons(void)
{
  801e66:	55                   	push   %ebp
  801e67:	89 e5                	mov    %esp,%ebp
  801e69:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801e6c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e6f:	50                   	push   %eax
  801e70:	e8 97 f3 ff ff       	call   80120c <fd_alloc>
  801e75:	83 c4 10             	add    $0x10,%esp
  801e78:	85 c0                	test   %eax,%eax
  801e7a:	78 3a                	js     801eb6 <opencons+0x50>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801e7c:	83 ec 04             	sub    $0x4,%esp
  801e7f:	68 07 04 00 00       	push   $0x407
  801e84:	ff 75 f4             	pushl  -0xc(%ebp)
  801e87:	6a 00                	push   $0x0
  801e89:	e8 e6 ed ff ff       	call   800c74 <sys_page_alloc>
  801e8e:	83 c4 10             	add    $0x10,%esp
  801e91:	85 c0                	test   %eax,%eax
  801e93:	78 21                	js     801eb6 <opencons+0x50>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801e95:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801e9b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e9e:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801ea0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ea3:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801eaa:	83 ec 0c             	sub    $0xc,%esp
  801ead:	50                   	push   %eax
  801eae:	e8 31 f3 ff ff       	call   8011e4 <fd2num>
  801eb3:	83 c4 10             	add    $0x10,%esp
}
  801eb6:	c9                   	leave  
  801eb7:	c3                   	ret    

00801eb8 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801eb8:	55                   	push   %ebp
  801eb9:	89 e5                	mov    %esp,%ebp
  801ebb:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  801ebe:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801ec5:	75 52                	jne    801f19 <set_pgfault_handler+0x61>
		// First time through!	
		// LAB 4: Your code here.

		//int sys_page_alloc(envid_t envid, void *va, int perm)
		r = sys_page_alloc(0, (void*)(UXSTACKTOP - PGSIZE), PTE_U | PTE_W | PTE_P);
  801ec7:	83 ec 04             	sub    $0x4,%esp
  801eca:	6a 07                	push   $0x7
  801ecc:	68 00 f0 bf ee       	push   $0xeebff000
  801ed1:	6a 00                	push   $0x0
  801ed3:	e8 9c ed ff ff       	call   800c74 <sys_page_alloc>
		if (r < 0) {
  801ed8:	83 c4 10             	add    $0x10,%esp
  801edb:	85 c0                	test   %eax,%eax
  801edd:	79 12                	jns    801ef1 <set_pgfault_handler+0x39>
			panic("sys_page_alloc error : %e\n", r);
  801edf:	50                   	push   %eax
  801ee0:	68 18 28 80 00       	push   $0x802818
  801ee5:	6a 24                	push   $0x24
  801ee7:	68 33 28 80 00       	push   $0x802833
  801eec:	e8 73 e2 ff ff       	call   800164 <_panic>
		}

		// how to know envid, put 0, envid2env will help us to get curenv in syscall
		r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);		
  801ef1:	83 ec 08             	sub    $0x8,%esp
  801ef4:	68 24 1f 80 00       	push   $0x801f24
  801ef9:	6a 00                	push   $0x0
  801efb:	e8 27 ee ff ff       	call   800d27 <sys_env_set_pgfault_upcall>
		if (r < 0) {
  801f00:	83 c4 10             	add    $0x10,%esp
  801f03:	85 c0                	test   %eax,%eax
  801f05:	79 12                	jns    801f19 <set_pgfault_handler+0x61>
			panic("sys_env_set_pgfault_upcall error : %e\n", r);
  801f07:	50                   	push   %eax
  801f08:	68 44 28 80 00       	push   $0x802844
  801f0d:	6a 2a                	push   $0x2a
  801f0f:	68 33 28 80 00       	push   $0x802833
  801f14:	e8 4b e2 ff ff       	call   800164 <_panic>
		}
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801f19:	8b 45 08             	mov    0x8(%ebp),%eax
  801f1c:	a3 00 60 80 00       	mov    %eax,0x806000
}
  801f21:	c9                   	leave  
  801f22:	c3                   	ret    
	...

00801f24 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801f24:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801f25:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  801f2a:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801f2c:	83 c4 04             	add    $0x4,%esp
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	
	// fix old esp
	movl 0x30(%esp), %eax
  801f2f:	8b 44 24 30          	mov    0x30(%esp),%eax
	subl $0x4, %eax
  801f33:	83 e8 04             	sub    $0x4,%eax
	movl %eax, 0x30(%esp)
  801f36:	89 44 24 30          	mov    %eax,0x30(%esp)

	// set trap-time %eip
	movl 0x28(%esp), %ebx
  801f3a:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	movl %ebx, (%eax)
  801f3e:	89 18                	mov    %ebx,(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $0x08, %esp 	// ignore err_code and fault_va
  801f40:	83 c4 08             	add    $0x8,%esp
	popal 				// restore registers
  801f43:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x04, %esp 	// ignore eip 
  801f44:	83 c4 04             	add    $0x4,%esp
	popfl				// modify eflags
  801f47:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  801f48:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  801f49:	c3                   	ret    
	...

00801f4c <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801f4c:	55                   	push   %ebp
  801f4d:	89 e5                	mov    %esp,%ebp
  801f4f:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801f52:	89 c2                	mov    %eax,%edx
  801f54:	c1 ea 16             	shr    $0x16,%edx
  801f57:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801f5e:	f6 c2 01             	test   $0x1,%dl
  801f61:	74 1e                	je     801f81 <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  801f63:	c1 e8 0c             	shr    $0xc,%eax
  801f66:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801f6d:	a8 01                	test   $0x1,%al
  801f6f:	74 17                	je     801f88 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801f71:	c1 e8 0c             	shr    $0xc,%eax
  801f74:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  801f7b:	ef 
  801f7c:	0f b7 c0             	movzwl %ax,%eax
  801f7f:	eb 0c                	jmp    801f8d <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  801f81:	b8 00 00 00 00       	mov    $0x0,%eax
  801f86:	eb 05                	jmp    801f8d <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  801f88:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  801f8d:	c9                   	leave  
  801f8e:	c3                   	ret    
	...

00801f90 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  801f90:	55                   	push   %ebp
  801f91:	89 e5                	mov    %esp,%ebp
  801f93:	57                   	push   %edi
  801f94:	56                   	push   %esi
  801f95:	83 ec 10             	sub    $0x10,%esp
  801f98:	8b 7d 08             	mov    0x8(%ebp),%edi
  801f9b:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  801f9e:	89 7d f0             	mov    %edi,-0x10(%ebp)
  801fa1:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  801fa4:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  801fa7:	8b 45 14             	mov    0x14(%ebp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  801faa:	85 c0                	test   %eax,%eax
  801fac:	75 2e                	jne    801fdc <__udivdi3+0x4c>
    {
      if (d0 > n1)
  801fae:	39 f1                	cmp    %esi,%ecx
  801fb0:	77 5a                	ja     80200c <__udivdi3+0x7c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  801fb2:	85 c9                	test   %ecx,%ecx
  801fb4:	75 0b                	jne    801fc1 <__udivdi3+0x31>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  801fb6:	b8 01 00 00 00       	mov    $0x1,%eax
  801fbb:	31 d2                	xor    %edx,%edx
  801fbd:	f7 f1                	div    %ecx
  801fbf:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  801fc1:	31 d2                	xor    %edx,%edx
  801fc3:	89 f0                	mov    %esi,%eax
  801fc5:	f7 f1                	div    %ecx
  801fc7:	89 c6                	mov    %eax,%esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801fc9:	89 f8                	mov    %edi,%eax
  801fcb:	f7 f1                	div    %ecx
  801fcd:	89 c7                	mov    %eax,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801fcf:	89 f8                	mov    %edi,%eax
  801fd1:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801fd3:	83 c4 10             	add    $0x10,%esp
  801fd6:	5e                   	pop    %esi
  801fd7:	5f                   	pop    %edi
  801fd8:	c9                   	leave  
  801fd9:	c3                   	ret    
  801fda:	66 90                	xchg   %ax,%ax
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801fdc:	39 f0                	cmp    %esi,%eax
  801fde:	77 1c                	ja     801ffc <__udivdi3+0x6c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  801fe0:	0f bd f8             	bsr    %eax,%edi
	  if (bm == 0)
  801fe3:	83 f7 1f             	xor    $0x1f,%edi
  801fe6:	75 3c                	jne    802024 <__udivdi3+0x94>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801fe8:	39 f0                	cmp    %esi,%eax
  801fea:	0f 82 90 00 00 00    	jb     802080 <__udivdi3+0xf0>
  801ff0:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801ff3:	39 55 f4             	cmp    %edx,-0xc(%ebp)
  801ff6:	0f 86 84 00 00 00    	jbe    802080 <__udivdi3+0xf0>
  801ffc:	31 f6                	xor    %esi,%esi
  801ffe:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  802000:	89 f8                	mov    %edi,%eax
  802002:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802004:	83 c4 10             	add    $0x10,%esp
  802007:	5e                   	pop    %esi
  802008:	5f                   	pop    %edi
  802009:	c9                   	leave  
  80200a:	c3                   	ret    
  80200b:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  80200c:	89 f2                	mov    %esi,%edx
  80200e:	89 f8                	mov    %edi,%eax
  802010:	f7 f1                	div    %ecx
  802012:	89 c7                	mov    %eax,%edi
  802014:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  802016:	89 f8                	mov    %edi,%eax
  802018:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  80201a:	83 c4 10             	add    $0x10,%esp
  80201d:	5e                   	pop    %esi
  80201e:	5f                   	pop    %edi
  80201f:	c9                   	leave  
  802020:	c3                   	ret    
  802021:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  802024:	89 f9                	mov    %edi,%ecx
  802026:	d3 e0                	shl    %cl,%eax
  802028:	89 45 e8             	mov    %eax,-0x18(%ebp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  80202b:	b8 20 00 00 00       	mov    $0x20,%eax
  802030:	29 f8                	sub    %edi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  802032:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802035:	88 c1                	mov    %al,%cl
  802037:	d3 ea                	shr    %cl,%edx
  802039:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  80203c:	09 ca                	or     %ecx,%edx
  80203e:	89 55 ec             	mov    %edx,-0x14(%ebp)
	      d0 = d0 << bm;
  802041:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802044:	89 f9                	mov    %edi,%ecx
  802046:	d3 e2                	shl    %cl,%edx
  802048:	89 55 f4             	mov    %edx,-0xc(%ebp)
	      n2 = n1 >> b;
  80204b:	89 f2                	mov    %esi,%edx
  80204d:	88 c1                	mov    %al,%cl
  80204f:	d3 ea                	shr    %cl,%edx
  802051:	89 55 e8             	mov    %edx,-0x18(%ebp)
	      n1 = (n1 << bm) | (n0 >> b);
  802054:	89 f2                	mov    %esi,%edx
  802056:	89 f9                	mov    %edi,%ecx
  802058:	d3 e2                	shl    %cl,%edx
  80205a:	8b 75 f0             	mov    -0x10(%ebp),%esi
  80205d:	88 c1                	mov    %al,%cl
  80205f:	d3 ee                	shr    %cl,%esi
  802061:	09 d6                	or     %edx,%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  802063:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  802066:	89 f0                	mov    %esi,%eax
  802068:	89 ca                	mov    %ecx,%edx
  80206a:	f7 75 ec             	divl   -0x14(%ebp)
  80206d:	89 d1                	mov    %edx,%ecx
  80206f:	89 c6                	mov    %eax,%esi
	      umul_ppmm (m1, m0, q0, d0);
  802071:	f7 65 f4             	mull   -0xc(%ebp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802074:	39 d1                	cmp    %edx,%ecx
  802076:	72 28                	jb     8020a0 <__udivdi3+0x110>
  802078:	74 1a                	je     802094 <__udivdi3+0x104>
  80207a:	89 f7                	mov    %esi,%edi
  80207c:	31 f6                	xor    %esi,%esi
  80207e:	eb 80                	jmp    802000 <__udivdi3+0x70>
	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  802080:	31 f6                	xor    %esi,%esi
  802082:	bf 01 00 00 00       	mov    $0x1,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  802087:	89 f8                	mov    %edi,%eax
  802089:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  80208b:	83 c4 10             	add    $0x10,%esp
  80208e:	5e                   	pop    %esi
  80208f:	5f                   	pop    %edi
  802090:	c9                   	leave  
  802091:	c3                   	ret    
  802092:	66 90                	xchg   %ax,%ax

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  802094:	8b 55 f0             	mov    -0x10(%ebp),%edx
  802097:	89 f9                	mov    %edi,%ecx
  802099:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  80209b:	39 c2                	cmp    %eax,%edx
  80209d:	73 db                	jae    80207a <__udivdi3+0xea>
  80209f:	90                   	nop
		{
		  q0--;
  8020a0:	8d 7e ff             	lea    -0x1(%esi),%edi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  8020a3:	31 f6                	xor    %esi,%esi
  8020a5:	e9 56 ff ff ff       	jmp    802000 <__udivdi3+0x70>
	...

008020ac <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  8020ac:	55                   	push   %ebp
  8020ad:	89 e5                	mov    %esp,%ebp
  8020af:	57                   	push   %edi
  8020b0:	56                   	push   %esi
  8020b1:	83 ec 20             	sub    $0x20,%esp
  8020b4:	8b 45 08             	mov    0x8(%ebp),%eax
  8020b7:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  8020ba:	89 45 e8             	mov    %eax,-0x18(%ebp)
  8020bd:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  8020c0:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  8020c3:	8b 7d 14             	mov    0x14(%ebp),%edi
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  8020c6:	89 45 f0             	mov    %eax,-0x10(%ebp)
  n1 = nn.s.high;
  8020c9:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  8020cb:	85 ff                	test   %edi,%edi
  8020cd:	75 15                	jne    8020e4 <__umoddi3+0x38>
    {
      if (d0 > n1)
  8020cf:	39 f1                	cmp    %esi,%ecx
  8020d1:	0f 86 99 00 00 00    	jbe    802170 <__umoddi3+0xc4>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8020d7:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  8020d9:	89 d0                	mov    %edx,%eax
  8020db:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8020dd:	83 c4 20             	add    $0x20,%esp
  8020e0:	5e                   	pop    %esi
  8020e1:	5f                   	pop    %edi
  8020e2:	c9                   	leave  
  8020e3:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  8020e4:	39 f7                	cmp    %esi,%edi
  8020e6:	0f 87 a4 00 00 00    	ja     802190 <__umoddi3+0xe4>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  8020ec:	0f bd c7             	bsr    %edi,%eax
	  if (bm == 0)
  8020ef:	83 f0 1f             	xor    $0x1f,%eax
  8020f2:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8020f5:	0f 84 a1 00 00 00    	je     80219c <__umoddi3+0xf0>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  8020fb:	89 f8                	mov    %edi,%eax
  8020fd:	8a 4d ec             	mov    -0x14(%ebp),%cl
  802100:	d3 e0                	shl    %cl,%eax
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  802102:	bf 20 00 00 00       	mov    $0x20,%edi
  802107:	2b 7d ec             	sub    -0x14(%ebp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  80210a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80210d:	89 f9                	mov    %edi,%ecx
  80210f:	d3 ea                	shr    %cl,%edx
  802111:	09 c2                	or     %eax,%edx
  802113:	89 55 f0             	mov    %edx,-0x10(%ebp)
	      d0 = d0 << bm;
  802116:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802119:	8a 4d ec             	mov    -0x14(%ebp),%cl
  80211c:	d3 e0                	shl    %cl,%eax
  80211e:	89 45 f4             	mov    %eax,-0xc(%ebp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  802121:	89 f2                	mov    %esi,%edx
  802123:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  802125:	8b 45 e8             	mov    -0x18(%ebp),%eax
  802128:	d3 e0                	shl    %cl,%eax
  80212a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  80212d:	8b 45 e8             	mov    -0x18(%ebp),%eax
  802130:	89 f9                	mov    %edi,%ecx
  802132:	d3 e8                	shr    %cl,%eax
  802134:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  802136:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  802138:	89 f2                	mov    %esi,%edx
  80213a:	f7 75 f0             	divl   -0x10(%ebp)
  80213d:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  80213f:	f7 65 f4             	mull   -0xc(%ebp)
  802142:	89 55 e8             	mov    %edx,-0x18(%ebp)
  802145:	89 c1                	mov    %eax,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802147:	39 d6                	cmp    %edx,%esi
  802149:	72 71                	jb     8021bc <__umoddi3+0x110>
  80214b:	74 7f                	je     8021cc <__umoddi3+0x120>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  80214d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802150:	29 c8                	sub    %ecx,%eax
  802152:	19 d6                	sbb    %edx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  802154:	8a 4d ec             	mov    -0x14(%ebp),%cl
  802157:	d3 e8                	shr    %cl,%eax
  802159:	89 f2                	mov    %esi,%edx
  80215b:	89 f9                	mov    %edi,%ecx
  80215d:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  80215f:	09 d0                	or     %edx,%eax
  802161:	89 f2                	mov    %esi,%edx
  802163:	8a 4d ec             	mov    -0x14(%ebp),%cl
  802166:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802168:	83 c4 20             	add    $0x20,%esp
  80216b:	5e                   	pop    %esi
  80216c:	5f                   	pop    %edi
  80216d:	c9                   	leave  
  80216e:	c3                   	ret    
  80216f:	90                   	nop
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  802170:	85 c9                	test   %ecx,%ecx
  802172:	75 0b                	jne    80217f <__umoddi3+0xd3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  802174:	b8 01 00 00 00       	mov    $0x1,%eax
  802179:	31 d2                	xor    %edx,%edx
  80217b:	f7 f1                	div    %ecx
  80217d:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  80217f:	89 f0                	mov    %esi,%eax
  802181:	31 d2                	xor    %edx,%edx
  802183:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802185:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802188:	f7 f1                	div    %ecx
  80218a:	e9 4a ff ff ff       	jmp    8020d9 <__umoddi3+0x2d>
  80218f:	90                   	nop
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  802190:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802192:	83 c4 20             	add    $0x20,%esp
  802195:	5e                   	pop    %esi
  802196:	5f                   	pop    %edi
  802197:	c9                   	leave  
  802198:	c3                   	ret    
  802199:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  80219c:	39 f7                	cmp    %esi,%edi
  80219e:	72 05                	jb     8021a5 <__umoddi3+0xf9>
  8021a0:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
  8021a3:	77 0c                	ja     8021b1 <__umoddi3+0x105>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  8021a5:	89 f2                	mov    %esi,%edx
  8021a7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8021aa:	29 c8                	sub    %ecx,%eax
  8021ac:	19 fa                	sbb    %edi,%edx
  8021ae:	89 45 f0             	mov    %eax,-0x10(%ebp)

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  8021b1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8021b4:	83 c4 20             	add    $0x20,%esp
  8021b7:	5e                   	pop    %esi
  8021b8:	5f                   	pop    %edi
  8021b9:	c9                   	leave  
  8021ba:	c3                   	ret    
  8021bb:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  8021bc:	8b 55 e8             	mov    -0x18(%ebp),%edx
  8021bf:	89 c1                	mov    %eax,%ecx
  8021c1:	2b 4d f4             	sub    -0xc(%ebp),%ecx
  8021c4:	1b 55 f0             	sbb    -0x10(%ebp),%edx
  8021c7:	eb 84                	jmp    80214d <__umoddi3+0xa1>
  8021c9:	8d 76 00             	lea    0x0(%esi),%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8021cc:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  8021cf:	72 eb                	jb     8021bc <__umoddi3+0x110>
  8021d1:	89 f2                	mov    %esi,%edx
  8021d3:	e9 75 ff ff ff       	jmp    80214d <__umoddi3+0xa1>
