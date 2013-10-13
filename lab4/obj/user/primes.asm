
obj/user/primes:     file format elf32-i386


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
  800048:	e8 4b 0d 00 00       	call   800d98 <ipc_recv>
  80004d:	89 c3                	mov    %eax,%ebx
	cprintf("CPU %d: %d ", thisenv->env_cpunum, p);
  80004f:	a1 04 20 80 00       	mov    0x802004,%eax
  800054:	8b 40 5c             	mov    0x5c(%eax),%eax
  800057:	83 c4 0c             	add    $0xc,%esp
  80005a:	53                   	push   %ebx
  80005b:	50                   	push   %eax
  80005c:	68 80 10 80 00       	push   $0x801080
  800061:	e8 ce 01 00 00       	call   800234 <cprintf>

	// fork a right neighbor to continue the chain
	if ((id = fork()) < 0)
  800066:	e8 fd 0c 00 00       	call   800d68 <fork>
  80006b:	89 c7                	mov    %eax,%edi
  80006d:	83 c4 10             	add    $0x10,%esp
  800070:	85 c0                	test   %eax,%eax
  800072:	79 12                	jns    800086 <primeproc+0x52>
		panic("fork: %e", id);
  800074:	50                   	push   %eax
  800075:	68 8c 10 80 00       	push   $0x80108c
  80007a:	6a 1a                	push   $0x1a
  80007c:	68 95 10 80 00       	push   $0x801095
  800081:	e8 d6 00 00 00       	call   80015c <_panic>
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
  800095:	e8 fe 0c 00 00       	call   800d98 <ipc_recv>
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
  8000ac:	e8 fe 0c 00 00       	call   800daf <ipc_send>
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
  8000bb:	e8 a8 0c 00 00       	call   800d68 <fork>
  8000c0:	89 c3                	mov    %eax,%ebx
  8000c2:	85 c0                	test   %eax,%eax
  8000c4:	79 12                	jns    8000d8 <umain+0x22>
		panic("fork: %e", id);
  8000c6:	50                   	push   %eax
  8000c7:	68 8c 10 80 00       	push   $0x80108c
  8000cc:	6a 2d                	push   $0x2d
  8000ce:	68 95 10 80 00       	push   $0x801095
  8000d3:	e8 84 00 00 00       	call   80015c <_panic>
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
  8000ec:	e8 be 0c 00 00       	call   800daf <ipc_send>
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
  800103:	e8 19 0b 00 00       	call   800c21 <sys_getenvid>
  800108:	25 ff 03 00 00       	and    $0x3ff,%eax
  80010d:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800114:	c1 e0 07             	shl    $0x7,%eax
  800117:	29 d0                	sub    %edx,%eax
  800119:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80011e:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800123:	85 f6                	test   %esi,%esi
  800125:	7e 07                	jle    80012e <libmain+0x36>
		binaryname = argv[0];
  800127:	8b 03                	mov    (%ebx),%eax
  800129:	a3 00 20 80 00       	mov    %eax,0x802000
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
  80014b:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  80014e:	6a 00                	push   $0x0
  800150:	e8 aa 0a 00 00       	call   800bff <sys_env_destroy>
  800155:	83 c4 10             	add    $0x10,%esp
}
  800158:	c9                   	leave  
  800159:	c3                   	ret    
	...

0080015c <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80015c:	55                   	push   %ebp
  80015d:	89 e5                	mov    %esp,%ebp
  80015f:	56                   	push   %esi
  800160:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800161:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800164:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  80016a:	e8 b2 0a 00 00       	call   800c21 <sys_getenvid>
  80016f:	83 ec 0c             	sub    $0xc,%esp
  800172:	ff 75 0c             	pushl  0xc(%ebp)
  800175:	ff 75 08             	pushl  0x8(%ebp)
  800178:	53                   	push   %ebx
  800179:	50                   	push   %eax
  80017a:	68 b0 10 80 00       	push   $0x8010b0
  80017f:	e8 b0 00 00 00       	call   800234 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800184:	83 c4 18             	add    $0x18,%esp
  800187:	56                   	push   %esi
  800188:	ff 75 10             	pushl  0x10(%ebp)
  80018b:	e8 53 00 00 00       	call   8001e3 <vcprintf>
	cprintf("\n");
  800190:	c7 04 24 d4 10 80 00 	movl   $0x8010d4,(%esp)
  800197:	e8 98 00 00 00       	call   800234 <cprintf>
  80019c:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80019f:	cc                   	int3   
  8001a0:	eb fd                	jmp    80019f <_panic+0x43>
	...

008001a4 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001a4:	55                   	push   %ebp
  8001a5:	89 e5                	mov    %esp,%ebp
  8001a7:	53                   	push   %ebx
  8001a8:	83 ec 04             	sub    $0x4,%esp
  8001ab:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001ae:	8b 03                	mov    (%ebx),%eax
  8001b0:	8b 55 08             	mov    0x8(%ebp),%edx
  8001b3:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8001b7:	40                   	inc    %eax
  8001b8:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8001ba:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001bf:	75 1a                	jne    8001db <putch+0x37>
		sys_cputs(b->buf, b->idx);
  8001c1:	83 ec 08             	sub    $0x8,%esp
  8001c4:	68 ff 00 00 00       	push   $0xff
  8001c9:	8d 43 08             	lea    0x8(%ebx),%eax
  8001cc:	50                   	push   %eax
  8001cd:	e8 e3 09 00 00       	call   800bb5 <sys_cputs>
		b->idx = 0;
  8001d2:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001d8:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8001db:	ff 43 04             	incl   0x4(%ebx)
}
  8001de:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001e1:	c9                   	leave  
  8001e2:	c3                   	ret    

008001e3 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001e3:	55                   	push   %ebp
  8001e4:	89 e5                	mov    %esp,%ebp
  8001e6:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001ec:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001f3:	00 00 00 
	b.cnt = 0;
  8001f6:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001fd:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800200:	ff 75 0c             	pushl  0xc(%ebp)
  800203:	ff 75 08             	pushl  0x8(%ebp)
  800206:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80020c:	50                   	push   %eax
  80020d:	68 a4 01 80 00       	push   $0x8001a4
  800212:	e8 82 01 00 00       	call   800399 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800217:	83 c4 08             	add    $0x8,%esp
  80021a:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800220:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800226:	50                   	push   %eax
  800227:	e8 89 09 00 00       	call   800bb5 <sys_cputs>

	return b.cnt;
}
  80022c:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800232:	c9                   	leave  
  800233:	c3                   	ret    

00800234 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800234:	55                   	push   %ebp
  800235:	89 e5                	mov    %esp,%ebp
  800237:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80023a:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80023d:	50                   	push   %eax
  80023e:	ff 75 08             	pushl  0x8(%ebp)
  800241:	e8 9d ff ff ff       	call   8001e3 <vcprintf>
	va_end(ap);

	return cnt;
}
  800246:	c9                   	leave  
  800247:	c3                   	ret    

00800248 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800248:	55                   	push   %ebp
  800249:	89 e5                	mov    %esp,%ebp
  80024b:	57                   	push   %edi
  80024c:	56                   	push   %esi
  80024d:	53                   	push   %ebx
  80024e:	83 ec 2c             	sub    $0x2c,%esp
  800251:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800254:	89 d6                	mov    %edx,%esi
  800256:	8b 45 08             	mov    0x8(%ebp),%eax
  800259:	8b 55 0c             	mov    0xc(%ebp),%edx
  80025c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80025f:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800262:	8b 45 10             	mov    0x10(%ebp),%eax
  800265:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800268:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80026b:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80026e:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  800275:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
  800278:	72 0c                	jb     800286 <printnum+0x3e>
  80027a:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  80027d:	76 07                	jbe    800286 <printnum+0x3e>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80027f:	4b                   	dec    %ebx
  800280:	85 db                	test   %ebx,%ebx
  800282:	7f 31                	jg     8002b5 <printnum+0x6d>
  800284:	eb 3f                	jmp    8002c5 <printnum+0x7d>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800286:	83 ec 0c             	sub    $0xc,%esp
  800289:	57                   	push   %edi
  80028a:	4b                   	dec    %ebx
  80028b:	53                   	push   %ebx
  80028c:	50                   	push   %eax
  80028d:	83 ec 08             	sub    $0x8,%esp
  800290:	ff 75 d4             	pushl  -0x2c(%ebp)
  800293:	ff 75 d0             	pushl  -0x30(%ebp)
  800296:	ff 75 dc             	pushl  -0x24(%ebp)
  800299:	ff 75 d8             	pushl  -0x28(%ebp)
  80029c:	e8 83 0b 00 00       	call   800e24 <__udivdi3>
  8002a1:	83 c4 18             	add    $0x18,%esp
  8002a4:	52                   	push   %edx
  8002a5:	50                   	push   %eax
  8002a6:	89 f2                	mov    %esi,%edx
  8002a8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8002ab:	e8 98 ff ff ff       	call   800248 <printnum>
  8002b0:	83 c4 20             	add    $0x20,%esp
  8002b3:	eb 10                	jmp    8002c5 <printnum+0x7d>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002b5:	83 ec 08             	sub    $0x8,%esp
  8002b8:	56                   	push   %esi
  8002b9:	57                   	push   %edi
  8002ba:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002bd:	4b                   	dec    %ebx
  8002be:	83 c4 10             	add    $0x10,%esp
  8002c1:	85 db                	test   %ebx,%ebx
  8002c3:	7f f0                	jg     8002b5 <printnum+0x6d>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002c5:	83 ec 08             	sub    $0x8,%esp
  8002c8:	56                   	push   %esi
  8002c9:	83 ec 04             	sub    $0x4,%esp
  8002cc:	ff 75 d4             	pushl  -0x2c(%ebp)
  8002cf:	ff 75 d0             	pushl  -0x30(%ebp)
  8002d2:	ff 75 dc             	pushl  -0x24(%ebp)
  8002d5:	ff 75 d8             	pushl  -0x28(%ebp)
  8002d8:	e8 63 0c 00 00       	call   800f40 <__umoddi3>
  8002dd:	83 c4 14             	add    $0x14,%esp
  8002e0:	0f be 80 d6 10 80 00 	movsbl 0x8010d6(%eax),%eax
  8002e7:	50                   	push   %eax
  8002e8:	ff 55 e4             	call   *-0x1c(%ebp)
  8002eb:	83 c4 10             	add    $0x10,%esp
}
  8002ee:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002f1:	5b                   	pop    %ebx
  8002f2:	5e                   	pop    %esi
  8002f3:	5f                   	pop    %edi
  8002f4:	c9                   	leave  
  8002f5:	c3                   	ret    

008002f6 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002f6:	55                   	push   %ebp
  8002f7:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002f9:	83 fa 01             	cmp    $0x1,%edx
  8002fc:	7e 0e                	jle    80030c <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8002fe:	8b 10                	mov    (%eax),%edx
  800300:	8d 4a 08             	lea    0x8(%edx),%ecx
  800303:	89 08                	mov    %ecx,(%eax)
  800305:	8b 02                	mov    (%edx),%eax
  800307:	8b 52 04             	mov    0x4(%edx),%edx
  80030a:	eb 22                	jmp    80032e <getuint+0x38>
	else if (lflag)
  80030c:	85 d2                	test   %edx,%edx
  80030e:	74 10                	je     800320 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800310:	8b 10                	mov    (%eax),%edx
  800312:	8d 4a 04             	lea    0x4(%edx),%ecx
  800315:	89 08                	mov    %ecx,(%eax)
  800317:	8b 02                	mov    (%edx),%eax
  800319:	ba 00 00 00 00       	mov    $0x0,%edx
  80031e:	eb 0e                	jmp    80032e <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800320:	8b 10                	mov    (%eax),%edx
  800322:	8d 4a 04             	lea    0x4(%edx),%ecx
  800325:	89 08                	mov    %ecx,(%eax)
  800327:	8b 02                	mov    (%edx),%eax
  800329:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80032e:	c9                   	leave  
  80032f:	c3                   	ret    

00800330 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  800330:	55                   	push   %ebp
  800331:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800333:	83 fa 01             	cmp    $0x1,%edx
  800336:	7e 0e                	jle    800346 <getint+0x16>
		return va_arg(*ap, long long);
  800338:	8b 10                	mov    (%eax),%edx
  80033a:	8d 4a 08             	lea    0x8(%edx),%ecx
  80033d:	89 08                	mov    %ecx,(%eax)
  80033f:	8b 02                	mov    (%edx),%eax
  800341:	8b 52 04             	mov    0x4(%edx),%edx
  800344:	eb 1a                	jmp    800360 <getint+0x30>
	else if (lflag)
  800346:	85 d2                	test   %edx,%edx
  800348:	74 0c                	je     800356 <getint+0x26>
		return va_arg(*ap, long);
  80034a:	8b 10                	mov    (%eax),%edx
  80034c:	8d 4a 04             	lea    0x4(%edx),%ecx
  80034f:	89 08                	mov    %ecx,(%eax)
  800351:	8b 02                	mov    (%edx),%eax
  800353:	99                   	cltd   
  800354:	eb 0a                	jmp    800360 <getint+0x30>
	else
		return va_arg(*ap, int);
  800356:	8b 10                	mov    (%eax),%edx
  800358:	8d 4a 04             	lea    0x4(%edx),%ecx
  80035b:	89 08                	mov    %ecx,(%eax)
  80035d:	8b 02                	mov    (%edx),%eax
  80035f:	99                   	cltd   
}
  800360:	c9                   	leave  
  800361:	c3                   	ret    

00800362 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800362:	55                   	push   %ebp
  800363:	89 e5                	mov    %esp,%ebp
  800365:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800368:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  80036b:	8b 10                	mov    (%eax),%edx
  80036d:	3b 50 04             	cmp    0x4(%eax),%edx
  800370:	73 08                	jae    80037a <sprintputch+0x18>
		*b->buf++ = ch;
  800372:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800375:	88 0a                	mov    %cl,(%edx)
  800377:	42                   	inc    %edx
  800378:	89 10                	mov    %edx,(%eax)
}
  80037a:	c9                   	leave  
  80037b:	c3                   	ret    

0080037c <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80037c:	55                   	push   %ebp
  80037d:	89 e5                	mov    %esp,%ebp
  80037f:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800382:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800385:	50                   	push   %eax
  800386:	ff 75 10             	pushl  0x10(%ebp)
  800389:	ff 75 0c             	pushl  0xc(%ebp)
  80038c:	ff 75 08             	pushl  0x8(%ebp)
  80038f:	e8 05 00 00 00       	call   800399 <vprintfmt>
	va_end(ap);
  800394:	83 c4 10             	add    $0x10,%esp
}
  800397:	c9                   	leave  
  800398:	c3                   	ret    

00800399 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800399:	55                   	push   %ebp
  80039a:	89 e5                	mov    %esp,%ebp
  80039c:	57                   	push   %edi
  80039d:	56                   	push   %esi
  80039e:	53                   	push   %ebx
  80039f:	83 ec 2c             	sub    $0x2c,%esp
  8003a2:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8003a5:	8b 75 10             	mov    0x10(%ebp),%esi
  8003a8:	eb 13                	jmp    8003bd <vprintfmt+0x24>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8003aa:	85 c0                	test   %eax,%eax
  8003ac:	0f 84 6d 03 00 00    	je     80071f <vprintfmt+0x386>
				return;
			putch(ch, putdat);
  8003b2:	83 ec 08             	sub    $0x8,%esp
  8003b5:	57                   	push   %edi
  8003b6:	50                   	push   %eax
  8003b7:	ff 55 08             	call   *0x8(%ebp)
  8003ba:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8003bd:	0f b6 06             	movzbl (%esi),%eax
  8003c0:	46                   	inc    %esi
  8003c1:	83 f8 25             	cmp    $0x25,%eax
  8003c4:	75 e4                	jne    8003aa <vprintfmt+0x11>
  8003c6:	c6 45 dc 20          	movb   $0x20,-0x24(%ebp)
  8003ca:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  8003d1:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  8003d8:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  8003df:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003e4:	eb 28                	jmp    80040e <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003e6:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  8003e8:	c6 45 dc 2d          	movb   $0x2d,-0x24(%ebp)
  8003ec:	eb 20                	jmp    80040e <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ee:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8003f0:	c6 45 dc 30          	movb   $0x30,-0x24(%ebp)
  8003f4:	eb 18                	jmp    80040e <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003f6:	89 de                	mov    %ebx,%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  8003f8:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8003ff:	eb 0d                	jmp    80040e <vprintfmt+0x75>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800401:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800404:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800407:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80040e:	8a 06                	mov    (%esi),%al
  800410:	0f b6 d0             	movzbl %al,%edx
  800413:	8d 5e 01             	lea    0x1(%esi),%ebx
  800416:	83 e8 23             	sub    $0x23,%eax
  800419:	3c 55                	cmp    $0x55,%al
  80041b:	0f 87 e0 02 00 00    	ja     800701 <vprintfmt+0x368>
  800421:	0f b6 c0             	movzbl %al,%eax
  800424:	ff 24 85 a0 11 80 00 	jmp    *0x8011a0(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80042b:	83 ea 30             	sub    $0x30,%edx
  80042e:	89 55 d4             	mov    %edx,-0x2c(%ebp)
				ch = *fmt;
  800431:	0f be 03             	movsbl (%ebx),%eax
				if (ch < '0' || ch > '9')
  800434:	8d 50 d0             	lea    -0x30(%eax),%edx
  800437:	83 fa 09             	cmp    $0x9,%edx
  80043a:	77 44                	ja     800480 <vprintfmt+0xe7>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80043c:	89 de                	mov    %ebx,%esi
  80043e:	8b 55 d4             	mov    -0x2c(%ebp),%edx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800441:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
  800442:	8d 14 92             	lea    (%edx,%edx,4),%edx
  800445:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
  800449:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  80044c:	8d 58 d0             	lea    -0x30(%eax),%ebx
  80044f:	83 fb 09             	cmp    $0x9,%ebx
  800452:	76 ed                	jbe    800441 <vprintfmt+0xa8>
  800454:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  800457:	eb 29                	jmp    800482 <vprintfmt+0xe9>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800459:	8b 45 14             	mov    0x14(%ebp),%eax
  80045c:	8d 50 04             	lea    0x4(%eax),%edx
  80045f:	89 55 14             	mov    %edx,0x14(%ebp)
  800462:	8b 00                	mov    (%eax),%eax
  800464:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800467:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800469:	eb 17                	jmp    800482 <vprintfmt+0xe9>

		case '.':
			if (width < 0)
  80046b:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80046f:	78 85                	js     8003f6 <vprintfmt+0x5d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800471:	89 de                	mov    %ebx,%esi
  800473:	eb 99                	jmp    80040e <vprintfmt+0x75>
  800475:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800477:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  80047e:	eb 8e                	jmp    80040e <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800480:	89 de                	mov    %ebx,%esi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  800482:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800486:	79 86                	jns    80040e <vprintfmt+0x75>
  800488:	e9 74 ff ff ff       	jmp    800401 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80048d:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80048e:	89 de                	mov    %ebx,%esi
  800490:	e9 79 ff ff ff       	jmp    80040e <vprintfmt+0x75>
  800495:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800498:	8b 45 14             	mov    0x14(%ebp),%eax
  80049b:	8d 50 04             	lea    0x4(%eax),%edx
  80049e:	89 55 14             	mov    %edx,0x14(%ebp)
  8004a1:	83 ec 08             	sub    $0x8,%esp
  8004a4:	57                   	push   %edi
  8004a5:	ff 30                	pushl  (%eax)
  8004a7:	ff 55 08             	call   *0x8(%ebp)
			break;
  8004aa:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004ad:	8b 75 d8             	mov    -0x28(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8004b0:	e9 08 ff ff ff       	jmp    8003bd <vprintfmt+0x24>
  8004b5:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  8004b8:	8b 45 14             	mov    0x14(%ebp),%eax
  8004bb:	8d 50 04             	lea    0x4(%eax),%edx
  8004be:	89 55 14             	mov    %edx,0x14(%ebp)
  8004c1:	8b 00                	mov    (%eax),%eax
  8004c3:	85 c0                	test   %eax,%eax
  8004c5:	79 02                	jns    8004c9 <vprintfmt+0x130>
  8004c7:	f7 d8                	neg    %eax
  8004c9:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004cb:	83 f8 08             	cmp    $0x8,%eax
  8004ce:	7f 0b                	jg     8004db <vprintfmt+0x142>
  8004d0:	8b 04 85 00 13 80 00 	mov    0x801300(,%eax,4),%eax
  8004d7:	85 c0                	test   %eax,%eax
  8004d9:	75 1a                	jne    8004f5 <vprintfmt+0x15c>
				printfmt(putch, putdat, "error %d", err);
  8004db:	52                   	push   %edx
  8004dc:	68 ee 10 80 00       	push   $0x8010ee
  8004e1:	57                   	push   %edi
  8004e2:	ff 75 08             	pushl  0x8(%ebp)
  8004e5:	e8 92 fe ff ff       	call   80037c <printfmt>
  8004ea:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004ed:	8b 75 d8             	mov    -0x28(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8004f0:	e9 c8 fe ff ff       	jmp    8003bd <vprintfmt+0x24>
			else
				printfmt(putch, putdat, "%s", p);
  8004f5:	50                   	push   %eax
  8004f6:	68 f7 10 80 00       	push   $0x8010f7
  8004fb:	57                   	push   %edi
  8004fc:	ff 75 08             	pushl  0x8(%ebp)
  8004ff:	e8 78 fe ff ff       	call   80037c <printfmt>
  800504:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800507:	8b 75 d8             	mov    -0x28(%ebp),%esi
  80050a:	e9 ae fe ff ff       	jmp    8003bd <vprintfmt+0x24>
  80050f:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  800512:	89 de                	mov    %ebx,%esi
  800514:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  800517:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80051a:	8b 45 14             	mov    0x14(%ebp),%eax
  80051d:	8d 50 04             	lea    0x4(%eax),%edx
  800520:	89 55 14             	mov    %edx,0x14(%ebp)
  800523:	8b 00                	mov    (%eax),%eax
  800525:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800528:	85 c0                	test   %eax,%eax
  80052a:	75 07                	jne    800533 <vprintfmt+0x19a>
				p = "(null)";
  80052c:	c7 45 d0 e7 10 80 00 	movl   $0x8010e7,-0x30(%ebp)
			if (width > 0 && padc != '-')
  800533:	85 db                	test   %ebx,%ebx
  800535:	7e 42                	jle    800579 <vprintfmt+0x1e0>
  800537:	80 7d dc 2d          	cmpb   $0x2d,-0x24(%ebp)
  80053b:	74 3c                	je     800579 <vprintfmt+0x1e0>
				for (width -= strnlen(p, precision); width > 0; width--)
  80053d:	83 ec 08             	sub    $0x8,%esp
  800540:	51                   	push   %ecx
  800541:	ff 75 d0             	pushl  -0x30(%ebp)
  800544:	e8 6f 02 00 00       	call   8007b8 <strnlen>
  800549:	29 c3                	sub    %eax,%ebx
  80054b:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80054e:	83 c4 10             	add    $0x10,%esp
  800551:	85 db                	test   %ebx,%ebx
  800553:	7e 24                	jle    800579 <vprintfmt+0x1e0>
					putch(padc, putdat);
  800555:	0f be 5d dc          	movsbl -0x24(%ebp),%ebx
  800559:	89 75 dc             	mov    %esi,-0x24(%ebp)
  80055c:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  80055f:	83 ec 08             	sub    $0x8,%esp
  800562:	57                   	push   %edi
  800563:	53                   	push   %ebx
  800564:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800567:	4e                   	dec    %esi
  800568:	83 c4 10             	add    $0x10,%esp
  80056b:	85 f6                	test   %esi,%esi
  80056d:	7f f0                	jg     80055f <vprintfmt+0x1c6>
  80056f:	8b 75 dc             	mov    -0x24(%ebp),%esi
  800572:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800579:	8b 55 d0             	mov    -0x30(%ebp),%edx
  80057c:	0f be 02             	movsbl (%edx),%eax
  80057f:	85 c0                	test   %eax,%eax
  800581:	75 47                	jne    8005ca <vprintfmt+0x231>
  800583:	eb 37                	jmp    8005bc <vprintfmt+0x223>
				if (altflag && (ch < ' ' || ch > '~'))
  800585:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800589:	74 16                	je     8005a1 <vprintfmt+0x208>
  80058b:	8d 50 e0             	lea    -0x20(%eax),%edx
  80058e:	83 fa 5e             	cmp    $0x5e,%edx
  800591:	76 0e                	jbe    8005a1 <vprintfmt+0x208>
					putch('?', putdat);
  800593:	83 ec 08             	sub    $0x8,%esp
  800596:	57                   	push   %edi
  800597:	6a 3f                	push   $0x3f
  800599:	ff 55 08             	call   *0x8(%ebp)
  80059c:	83 c4 10             	add    $0x10,%esp
  80059f:	eb 0b                	jmp    8005ac <vprintfmt+0x213>
				else
					putch(ch, putdat);
  8005a1:	83 ec 08             	sub    $0x8,%esp
  8005a4:	57                   	push   %edi
  8005a5:	50                   	push   %eax
  8005a6:	ff 55 08             	call   *0x8(%ebp)
  8005a9:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005ac:	ff 4d e4             	decl   -0x1c(%ebp)
  8005af:	0f be 03             	movsbl (%ebx),%eax
  8005b2:	85 c0                	test   %eax,%eax
  8005b4:	74 03                	je     8005b9 <vprintfmt+0x220>
  8005b6:	43                   	inc    %ebx
  8005b7:	eb 1b                	jmp    8005d4 <vprintfmt+0x23b>
  8005b9:	8b 75 dc             	mov    -0x24(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005bc:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8005c0:	7f 1e                	jg     8005e0 <vprintfmt+0x247>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005c2:	8b 75 d8             	mov    -0x28(%ebp),%esi
  8005c5:	e9 f3 fd ff ff       	jmp    8003bd <vprintfmt+0x24>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005ca:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  8005cd:	43                   	inc    %ebx
  8005ce:	89 75 dc             	mov    %esi,-0x24(%ebp)
  8005d1:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  8005d4:	85 f6                	test   %esi,%esi
  8005d6:	78 ad                	js     800585 <vprintfmt+0x1ec>
  8005d8:	4e                   	dec    %esi
  8005d9:	79 aa                	jns    800585 <vprintfmt+0x1ec>
  8005db:	8b 75 dc             	mov    -0x24(%ebp),%esi
  8005de:	eb dc                	jmp    8005bc <vprintfmt+0x223>
  8005e0:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8005e3:	83 ec 08             	sub    $0x8,%esp
  8005e6:	57                   	push   %edi
  8005e7:	6a 20                	push   $0x20
  8005e9:	ff 55 08             	call   *0x8(%ebp)
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005ec:	4b                   	dec    %ebx
  8005ed:	83 c4 10             	add    $0x10,%esp
  8005f0:	85 db                	test   %ebx,%ebx
  8005f2:	7f ef                	jg     8005e3 <vprintfmt+0x24a>
  8005f4:	e9 c4 fd ff ff       	jmp    8003bd <vprintfmt+0x24>
  8005f9:	89 5d d8             	mov    %ebx,-0x28(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8005fc:	89 ca                	mov    %ecx,%edx
  8005fe:	8d 45 14             	lea    0x14(%ebp),%eax
  800601:	e8 2a fd ff ff       	call   800330 <getint>
  800606:	89 c3                	mov    %eax,%ebx
  800608:	89 d6                	mov    %edx,%esi
			if ((long long) num < 0) {
  80060a:	85 d2                	test   %edx,%edx
  80060c:	78 0a                	js     800618 <vprintfmt+0x27f>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80060e:	b8 0a 00 00 00       	mov    $0xa,%eax
  800613:	e9 b0 00 00 00       	jmp    8006c8 <vprintfmt+0x32f>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  800618:	83 ec 08             	sub    $0x8,%esp
  80061b:	57                   	push   %edi
  80061c:	6a 2d                	push   $0x2d
  80061e:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800621:	f7 db                	neg    %ebx
  800623:	83 d6 00             	adc    $0x0,%esi
  800626:	f7 de                	neg    %esi
  800628:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  80062b:	b8 0a 00 00 00       	mov    $0xa,%eax
  800630:	e9 93 00 00 00       	jmp    8006c8 <vprintfmt+0x32f>
  800635:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800638:	89 ca                	mov    %ecx,%edx
  80063a:	8d 45 14             	lea    0x14(%ebp),%eax
  80063d:	e8 b4 fc ff ff       	call   8002f6 <getuint>
  800642:	89 c3                	mov    %eax,%ebx
  800644:	89 d6                	mov    %edx,%esi
			base = 10;
  800646:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  80064b:	eb 7b                	jmp    8006c8 <vprintfmt+0x32f>
  80064d:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
  800650:	89 ca                	mov    %ecx,%edx
  800652:	8d 45 14             	lea    0x14(%ebp),%eax
  800655:	e8 d6 fc ff ff       	call   800330 <getint>
  80065a:	89 c3                	mov    %eax,%ebx
  80065c:	89 d6                	mov    %edx,%esi
            if ((long long) num < 0) {
  80065e:	85 d2                	test   %edx,%edx
  800660:	78 07                	js     800669 <vprintfmt+0x2d0>
                putch('-', putdat);
                num = -(long long) num;
            }
            base = 8;
  800662:	b8 08 00 00 00       	mov    $0x8,%eax
  800667:	eb 5f                	jmp    8006c8 <vprintfmt+0x32f>
		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
            if ((long long) num < 0) {
                putch('-', putdat);
  800669:	83 ec 08             	sub    $0x8,%esp
  80066c:	57                   	push   %edi
  80066d:	6a 2d                	push   $0x2d
  80066f:	ff 55 08             	call   *0x8(%ebp)
                num = -(long long) num;
  800672:	f7 db                	neg    %ebx
  800674:	83 d6 00             	adc    $0x0,%esi
  800677:	f7 de                	neg    %esi
  800679:	83 c4 10             	add    $0x10,%esp
            }
            base = 8;
  80067c:	b8 08 00 00 00       	mov    $0x8,%eax
  800681:	eb 45                	jmp    8006c8 <vprintfmt+0x32f>
  800683:	89 5d d8             	mov    %ebx,-0x28(%ebp)
            goto number;

        // pointer
		case 'p':
			putch('0', putdat);
  800686:	83 ec 08             	sub    $0x8,%esp
  800689:	57                   	push   %edi
  80068a:	6a 30                	push   $0x30
  80068c:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  80068f:	83 c4 08             	add    $0x8,%esp
  800692:	57                   	push   %edi
  800693:	6a 78                	push   $0x78
  800695:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800698:	8b 45 14             	mov    0x14(%ebp),%eax
  80069b:	8d 50 04             	lea    0x4(%eax),%edx
  80069e:	89 55 14             	mov    %edx,0x14(%ebp)

        // pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8006a1:	8b 18                	mov    (%eax),%ebx
  8006a3:	be 00 00 00 00       	mov    $0x0,%esi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8006a8:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8006ab:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8006b0:	eb 16                	jmp    8006c8 <vprintfmt+0x32f>
  8006b2:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8006b5:	89 ca                	mov    %ecx,%edx
  8006b7:	8d 45 14             	lea    0x14(%ebp),%eax
  8006ba:	e8 37 fc ff ff       	call   8002f6 <getuint>
  8006bf:	89 c3                	mov    %eax,%ebx
  8006c1:	89 d6                	mov    %edx,%esi
			base = 16;
  8006c3:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006c8:	83 ec 0c             	sub    $0xc,%esp
  8006cb:	0f be 55 dc          	movsbl -0x24(%ebp),%edx
  8006cf:	52                   	push   %edx
  8006d0:	ff 75 e4             	pushl  -0x1c(%ebp)
  8006d3:	50                   	push   %eax
  8006d4:	56                   	push   %esi
  8006d5:	53                   	push   %ebx
  8006d6:	89 fa                	mov    %edi,%edx
  8006d8:	8b 45 08             	mov    0x8(%ebp),%eax
  8006db:	e8 68 fb ff ff       	call   800248 <printnum>
			break;
  8006e0:	83 c4 20             	add    $0x20,%esp
  8006e3:	8b 75 d8             	mov    -0x28(%ebp),%esi
  8006e6:	e9 d2 fc ff ff       	jmp    8003bd <vprintfmt+0x24>
  8006eb:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006ee:	83 ec 08             	sub    $0x8,%esp
  8006f1:	57                   	push   %edi
  8006f2:	52                   	push   %edx
  8006f3:	ff 55 08             	call   *0x8(%ebp)
			break;
  8006f6:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006f9:	8b 75 d8             	mov    -0x28(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8006fc:	e9 bc fc ff ff       	jmp    8003bd <vprintfmt+0x24>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800701:	83 ec 08             	sub    $0x8,%esp
  800704:	57                   	push   %edi
  800705:	6a 25                	push   $0x25
  800707:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  80070a:	83 c4 10             	add    $0x10,%esp
  80070d:	eb 02                	jmp    800711 <vprintfmt+0x378>
  80070f:	89 c6                	mov    %eax,%esi
  800711:	8d 46 ff             	lea    -0x1(%esi),%eax
  800714:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800718:	75 f5                	jne    80070f <vprintfmt+0x376>
  80071a:	e9 9e fc ff ff       	jmp    8003bd <vprintfmt+0x24>
				/* do nothing */;
			break;
		}
	}
}
  80071f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800722:	5b                   	pop    %ebx
  800723:	5e                   	pop    %esi
  800724:	5f                   	pop    %edi
  800725:	c9                   	leave  
  800726:	c3                   	ret    

00800727 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800727:	55                   	push   %ebp
  800728:	89 e5                	mov    %esp,%ebp
  80072a:	83 ec 18             	sub    $0x18,%esp
  80072d:	8b 45 08             	mov    0x8(%ebp),%eax
  800730:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800733:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800736:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80073a:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80073d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800744:	85 c0                	test   %eax,%eax
  800746:	74 26                	je     80076e <vsnprintf+0x47>
  800748:	85 d2                	test   %edx,%edx
  80074a:	7e 29                	jle    800775 <vsnprintf+0x4e>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80074c:	ff 75 14             	pushl  0x14(%ebp)
  80074f:	ff 75 10             	pushl  0x10(%ebp)
  800752:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800755:	50                   	push   %eax
  800756:	68 62 03 80 00       	push   $0x800362
  80075b:	e8 39 fc ff ff       	call   800399 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800760:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800763:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800766:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800769:	83 c4 10             	add    $0x10,%esp
  80076c:	eb 0c                	jmp    80077a <vsnprintf+0x53>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80076e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800773:	eb 05                	jmp    80077a <vsnprintf+0x53>
  800775:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80077a:	c9                   	leave  
  80077b:	c3                   	ret    

0080077c <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80077c:	55                   	push   %ebp
  80077d:	89 e5                	mov    %esp,%ebp
  80077f:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800782:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800785:	50                   	push   %eax
  800786:	ff 75 10             	pushl  0x10(%ebp)
  800789:	ff 75 0c             	pushl  0xc(%ebp)
  80078c:	ff 75 08             	pushl  0x8(%ebp)
  80078f:	e8 93 ff ff ff       	call   800727 <vsnprintf>
	va_end(ap);

	return rc;
}
  800794:	c9                   	leave  
  800795:	c3                   	ret    
	...

00800798 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800798:	55                   	push   %ebp
  800799:	89 e5                	mov    %esp,%ebp
  80079b:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80079e:	80 3a 00             	cmpb   $0x0,(%edx)
  8007a1:	74 0e                	je     8007b1 <strlen+0x19>
  8007a3:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  8007a8:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8007a9:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007ad:	75 f9                	jne    8007a8 <strlen+0x10>
  8007af:	eb 05                	jmp    8007b6 <strlen+0x1e>
  8007b1:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  8007b6:	c9                   	leave  
  8007b7:	c3                   	ret    

008007b8 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007b8:	55                   	push   %ebp
  8007b9:	89 e5                	mov    %esp,%ebp
  8007bb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007be:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007c1:	85 d2                	test   %edx,%edx
  8007c3:	74 17                	je     8007dc <strnlen+0x24>
  8007c5:	80 39 00             	cmpb   $0x0,(%ecx)
  8007c8:	74 19                	je     8007e3 <strnlen+0x2b>
  8007ca:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  8007cf:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007d0:	39 d0                	cmp    %edx,%eax
  8007d2:	74 14                	je     8007e8 <strnlen+0x30>
  8007d4:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8007d8:	75 f5                	jne    8007cf <strnlen+0x17>
  8007da:	eb 0c                	jmp    8007e8 <strnlen+0x30>
  8007dc:	b8 00 00 00 00       	mov    $0x0,%eax
  8007e1:	eb 05                	jmp    8007e8 <strnlen+0x30>
  8007e3:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  8007e8:	c9                   	leave  
  8007e9:	c3                   	ret    

008007ea <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007ea:	55                   	push   %ebp
  8007eb:	89 e5                	mov    %esp,%ebp
  8007ed:	53                   	push   %ebx
  8007ee:	8b 45 08             	mov    0x8(%ebp),%eax
  8007f1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007f4:	ba 00 00 00 00       	mov    $0x0,%edx
  8007f9:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  8007fc:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  8007ff:	42                   	inc    %edx
  800800:	84 c9                	test   %cl,%cl
  800802:	75 f5                	jne    8007f9 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800804:	5b                   	pop    %ebx
  800805:	c9                   	leave  
  800806:	c3                   	ret    

00800807 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800807:	55                   	push   %ebp
  800808:	89 e5                	mov    %esp,%ebp
  80080a:	53                   	push   %ebx
  80080b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80080e:	53                   	push   %ebx
  80080f:	e8 84 ff ff ff       	call   800798 <strlen>
  800814:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800817:	ff 75 0c             	pushl  0xc(%ebp)
  80081a:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  80081d:	50                   	push   %eax
  80081e:	e8 c7 ff ff ff       	call   8007ea <strcpy>
	return dst;
}
  800823:	89 d8                	mov    %ebx,%eax
  800825:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800828:	c9                   	leave  
  800829:	c3                   	ret    

0080082a <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80082a:	55                   	push   %ebp
  80082b:	89 e5                	mov    %esp,%ebp
  80082d:	56                   	push   %esi
  80082e:	53                   	push   %ebx
  80082f:	8b 45 08             	mov    0x8(%ebp),%eax
  800832:	8b 55 0c             	mov    0xc(%ebp),%edx
  800835:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800838:	85 f6                	test   %esi,%esi
  80083a:	74 15                	je     800851 <strncpy+0x27>
  80083c:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  800841:	8a 1a                	mov    (%edx),%bl
  800843:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800846:	80 3a 01             	cmpb   $0x1,(%edx)
  800849:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80084c:	41                   	inc    %ecx
  80084d:	39 ce                	cmp    %ecx,%esi
  80084f:	77 f0                	ja     800841 <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800851:	5b                   	pop    %ebx
  800852:	5e                   	pop    %esi
  800853:	c9                   	leave  
  800854:	c3                   	ret    

00800855 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800855:	55                   	push   %ebp
  800856:	89 e5                	mov    %esp,%ebp
  800858:	57                   	push   %edi
  800859:	56                   	push   %esi
  80085a:	53                   	push   %ebx
  80085b:	8b 7d 08             	mov    0x8(%ebp),%edi
  80085e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800861:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800864:	85 f6                	test   %esi,%esi
  800866:	74 32                	je     80089a <strlcpy+0x45>
		while (--size > 0 && *src != '\0')
  800868:	83 fe 01             	cmp    $0x1,%esi
  80086b:	74 22                	je     80088f <strlcpy+0x3a>
  80086d:	8a 0b                	mov    (%ebx),%cl
  80086f:	84 c9                	test   %cl,%cl
  800871:	74 20                	je     800893 <strlcpy+0x3e>
  800873:	89 f8                	mov    %edi,%eax
  800875:	ba 00 00 00 00       	mov    $0x0,%edx
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
  80087a:	83 ee 02             	sub    $0x2,%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80087d:	88 08                	mov    %cl,(%eax)
  80087f:	40                   	inc    %eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800880:	39 f2                	cmp    %esi,%edx
  800882:	74 11                	je     800895 <strlcpy+0x40>
  800884:	8a 4c 13 01          	mov    0x1(%ebx,%edx,1),%cl
  800888:	42                   	inc    %edx
  800889:	84 c9                	test   %cl,%cl
  80088b:	75 f0                	jne    80087d <strlcpy+0x28>
  80088d:	eb 06                	jmp    800895 <strlcpy+0x40>
  80088f:	89 f8                	mov    %edi,%eax
  800891:	eb 02                	jmp    800895 <strlcpy+0x40>
  800893:	89 f8                	mov    %edi,%eax
			*dst++ = *src++;
		*dst = '\0';
  800895:	c6 00 00             	movb   $0x0,(%eax)
  800898:	eb 02                	jmp    80089c <strlcpy+0x47>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80089a:	89 f8                	mov    %edi,%eax
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
		*dst = '\0';
	}
	return dst - dst_in;
  80089c:	29 f8                	sub    %edi,%eax
}
  80089e:	5b                   	pop    %ebx
  80089f:	5e                   	pop    %esi
  8008a0:	5f                   	pop    %edi
  8008a1:	c9                   	leave  
  8008a2:	c3                   	ret    

008008a3 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8008a3:	55                   	push   %ebp
  8008a4:	89 e5                	mov    %esp,%ebp
  8008a6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008a9:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008ac:	8a 01                	mov    (%ecx),%al
  8008ae:	84 c0                	test   %al,%al
  8008b0:	74 10                	je     8008c2 <strcmp+0x1f>
  8008b2:	3a 02                	cmp    (%edx),%al
  8008b4:	75 0c                	jne    8008c2 <strcmp+0x1f>
		p++, q++;
  8008b6:	41                   	inc    %ecx
  8008b7:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8008b8:	8a 01                	mov    (%ecx),%al
  8008ba:	84 c0                	test   %al,%al
  8008bc:	74 04                	je     8008c2 <strcmp+0x1f>
  8008be:	3a 02                	cmp    (%edx),%al
  8008c0:	74 f4                	je     8008b6 <strcmp+0x13>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008c2:	0f b6 c0             	movzbl %al,%eax
  8008c5:	0f b6 12             	movzbl (%edx),%edx
  8008c8:	29 d0                	sub    %edx,%eax
}
  8008ca:	c9                   	leave  
  8008cb:	c3                   	ret    

008008cc <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008cc:	55                   	push   %ebp
  8008cd:	89 e5                	mov    %esp,%ebp
  8008cf:	53                   	push   %ebx
  8008d0:	8b 55 08             	mov    0x8(%ebp),%edx
  8008d3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008d6:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  8008d9:	85 c0                	test   %eax,%eax
  8008db:	74 1b                	je     8008f8 <strncmp+0x2c>
  8008dd:	8a 1a                	mov    (%edx),%bl
  8008df:	84 db                	test   %bl,%bl
  8008e1:	74 24                	je     800907 <strncmp+0x3b>
  8008e3:	3a 19                	cmp    (%ecx),%bl
  8008e5:	75 20                	jne    800907 <strncmp+0x3b>
  8008e7:	48                   	dec    %eax
  8008e8:	74 15                	je     8008ff <strncmp+0x33>
		n--, p++, q++;
  8008ea:	42                   	inc    %edx
  8008eb:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8008ec:	8a 1a                	mov    (%edx),%bl
  8008ee:	84 db                	test   %bl,%bl
  8008f0:	74 15                	je     800907 <strncmp+0x3b>
  8008f2:	3a 19                	cmp    (%ecx),%bl
  8008f4:	74 f1                	je     8008e7 <strncmp+0x1b>
  8008f6:	eb 0f                	jmp    800907 <strncmp+0x3b>
		n--, p++, q++;
	if (n == 0)
		return 0;
  8008f8:	b8 00 00 00 00       	mov    $0x0,%eax
  8008fd:	eb 05                	jmp    800904 <strncmp+0x38>
  8008ff:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800904:	5b                   	pop    %ebx
  800905:	c9                   	leave  
  800906:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800907:	0f b6 02             	movzbl (%edx),%eax
  80090a:	0f b6 11             	movzbl (%ecx),%edx
  80090d:	29 d0                	sub    %edx,%eax
  80090f:	eb f3                	jmp    800904 <strncmp+0x38>

00800911 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800911:	55                   	push   %ebp
  800912:	89 e5                	mov    %esp,%ebp
  800914:	8b 45 08             	mov    0x8(%ebp),%eax
  800917:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  80091a:	8a 10                	mov    (%eax),%dl
  80091c:	84 d2                	test   %dl,%dl
  80091e:	74 18                	je     800938 <strchr+0x27>
		if (*s == c)
  800920:	38 ca                	cmp    %cl,%dl
  800922:	75 06                	jne    80092a <strchr+0x19>
  800924:	eb 17                	jmp    80093d <strchr+0x2c>
  800926:	38 ca                	cmp    %cl,%dl
  800928:	74 13                	je     80093d <strchr+0x2c>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80092a:	40                   	inc    %eax
  80092b:	8a 10                	mov    (%eax),%dl
  80092d:	84 d2                	test   %dl,%dl
  80092f:	75 f5                	jne    800926 <strchr+0x15>
		if (*s == c)
			return (char *) s;
	return 0;
  800931:	b8 00 00 00 00       	mov    $0x0,%eax
  800936:	eb 05                	jmp    80093d <strchr+0x2c>
  800938:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80093d:	c9                   	leave  
  80093e:	c3                   	ret    

0080093f <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80093f:	55                   	push   %ebp
  800940:	89 e5                	mov    %esp,%ebp
  800942:	8b 45 08             	mov    0x8(%ebp),%eax
  800945:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800948:	8a 10                	mov    (%eax),%dl
  80094a:	84 d2                	test   %dl,%dl
  80094c:	74 11                	je     80095f <strfind+0x20>
		if (*s == c)
  80094e:	38 ca                	cmp    %cl,%dl
  800950:	75 06                	jne    800958 <strfind+0x19>
  800952:	eb 0b                	jmp    80095f <strfind+0x20>
  800954:	38 ca                	cmp    %cl,%dl
  800956:	74 07                	je     80095f <strfind+0x20>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800958:	40                   	inc    %eax
  800959:	8a 10                	mov    (%eax),%dl
  80095b:	84 d2                	test   %dl,%dl
  80095d:	75 f5                	jne    800954 <strfind+0x15>
		if (*s == c)
			break;
	return (char *) s;
}
  80095f:	c9                   	leave  
  800960:	c3                   	ret    

00800961 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800961:	55                   	push   %ebp
  800962:	89 e5                	mov    %esp,%ebp
  800964:	57                   	push   %edi
  800965:	56                   	push   %esi
  800966:	53                   	push   %ebx
  800967:	8b 7d 08             	mov    0x8(%ebp),%edi
  80096a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80096d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800970:	85 c9                	test   %ecx,%ecx
  800972:	74 30                	je     8009a4 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800974:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80097a:	75 25                	jne    8009a1 <memset+0x40>
  80097c:	f6 c1 03             	test   $0x3,%cl
  80097f:	75 20                	jne    8009a1 <memset+0x40>
		c &= 0xFF;
  800981:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800984:	89 d3                	mov    %edx,%ebx
  800986:	c1 e3 08             	shl    $0x8,%ebx
  800989:	89 d6                	mov    %edx,%esi
  80098b:	c1 e6 18             	shl    $0x18,%esi
  80098e:	89 d0                	mov    %edx,%eax
  800990:	c1 e0 10             	shl    $0x10,%eax
  800993:	09 f0                	or     %esi,%eax
  800995:	09 d0                	or     %edx,%eax
  800997:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800999:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  80099c:	fc                   	cld    
  80099d:	f3 ab                	rep stos %eax,%es:(%edi)
  80099f:	eb 03                	jmp    8009a4 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8009a1:	fc                   	cld    
  8009a2:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8009a4:	89 f8                	mov    %edi,%eax
  8009a6:	5b                   	pop    %ebx
  8009a7:	5e                   	pop    %esi
  8009a8:	5f                   	pop    %edi
  8009a9:	c9                   	leave  
  8009aa:	c3                   	ret    

008009ab <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8009ab:	55                   	push   %ebp
  8009ac:	89 e5                	mov    %esp,%ebp
  8009ae:	57                   	push   %edi
  8009af:	56                   	push   %esi
  8009b0:	8b 45 08             	mov    0x8(%ebp),%eax
  8009b3:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009b6:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8009b9:	39 c6                	cmp    %eax,%esi
  8009bb:	73 34                	jae    8009f1 <memmove+0x46>
  8009bd:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8009c0:	39 d0                	cmp    %edx,%eax
  8009c2:	73 2d                	jae    8009f1 <memmove+0x46>
		s += n;
		d += n;
  8009c4:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009c7:	f6 c2 03             	test   $0x3,%dl
  8009ca:	75 1b                	jne    8009e7 <memmove+0x3c>
  8009cc:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8009d2:	75 13                	jne    8009e7 <memmove+0x3c>
  8009d4:	f6 c1 03             	test   $0x3,%cl
  8009d7:	75 0e                	jne    8009e7 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8009d9:	83 ef 04             	sub    $0x4,%edi
  8009dc:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009df:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  8009e2:	fd                   	std    
  8009e3:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009e5:	eb 07                	jmp    8009ee <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8009e7:	4f                   	dec    %edi
  8009e8:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8009eb:	fd                   	std    
  8009ec:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009ee:	fc                   	cld    
  8009ef:	eb 20                	jmp    800a11 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009f1:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009f7:	75 13                	jne    800a0c <memmove+0x61>
  8009f9:	a8 03                	test   $0x3,%al
  8009fb:	75 0f                	jne    800a0c <memmove+0x61>
  8009fd:	f6 c1 03             	test   $0x3,%cl
  800a00:	75 0a                	jne    800a0c <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800a02:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800a05:	89 c7                	mov    %eax,%edi
  800a07:	fc                   	cld    
  800a08:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a0a:	eb 05                	jmp    800a11 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a0c:	89 c7                	mov    %eax,%edi
  800a0e:	fc                   	cld    
  800a0f:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a11:	5e                   	pop    %esi
  800a12:	5f                   	pop    %edi
  800a13:	c9                   	leave  
  800a14:	c3                   	ret    

00800a15 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a15:	55                   	push   %ebp
  800a16:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800a18:	ff 75 10             	pushl  0x10(%ebp)
  800a1b:	ff 75 0c             	pushl  0xc(%ebp)
  800a1e:	ff 75 08             	pushl  0x8(%ebp)
  800a21:	e8 85 ff ff ff       	call   8009ab <memmove>
}
  800a26:	c9                   	leave  
  800a27:	c3                   	ret    

00800a28 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a28:	55                   	push   %ebp
  800a29:	89 e5                	mov    %esp,%ebp
  800a2b:	57                   	push   %edi
  800a2c:	56                   	push   %esi
  800a2d:	53                   	push   %ebx
  800a2e:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800a31:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a34:	8b 7d 10             	mov    0x10(%ebp),%edi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a37:	85 ff                	test   %edi,%edi
  800a39:	74 32                	je     800a6d <memcmp+0x45>
		if (*s1 != *s2)
  800a3b:	8a 03                	mov    (%ebx),%al
  800a3d:	8a 0e                	mov    (%esi),%cl
  800a3f:	38 c8                	cmp    %cl,%al
  800a41:	74 19                	je     800a5c <memcmp+0x34>
  800a43:	eb 0d                	jmp    800a52 <memcmp+0x2a>
  800a45:	8a 44 13 01          	mov    0x1(%ebx,%edx,1),%al
  800a49:	8a 4c 16 01          	mov    0x1(%esi,%edx,1),%cl
  800a4d:	42                   	inc    %edx
  800a4e:	38 c8                	cmp    %cl,%al
  800a50:	74 10                	je     800a62 <memcmp+0x3a>
			return (int) *s1 - (int) *s2;
  800a52:	0f b6 c0             	movzbl %al,%eax
  800a55:	0f b6 c9             	movzbl %cl,%ecx
  800a58:	29 c8                	sub    %ecx,%eax
  800a5a:	eb 16                	jmp    800a72 <memcmp+0x4a>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a5c:	4f                   	dec    %edi
  800a5d:	ba 00 00 00 00       	mov    $0x0,%edx
  800a62:	39 fa                	cmp    %edi,%edx
  800a64:	75 df                	jne    800a45 <memcmp+0x1d>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a66:	b8 00 00 00 00       	mov    $0x0,%eax
  800a6b:	eb 05                	jmp    800a72 <memcmp+0x4a>
  800a6d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a72:	5b                   	pop    %ebx
  800a73:	5e                   	pop    %esi
  800a74:	5f                   	pop    %edi
  800a75:	c9                   	leave  
  800a76:	c3                   	ret    

00800a77 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a77:	55                   	push   %ebp
  800a78:	89 e5                	mov    %esp,%ebp
  800a7a:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800a7d:	89 c2                	mov    %eax,%edx
  800a7f:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a82:	39 d0                	cmp    %edx,%eax
  800a84:	73 12                	jae    800a98 <memfind+0x21>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a86:	8a 4d 0c             	mov    0xc(%ebp),%cl
  800a89:	38 08                	cmp    %cl,(%eax)
  800a8b:	75 06                	jne    800a93 <memfind+0x1c>
  800a8d:	eb 09                	jmp    800a98 <memfind+0x21>
  800a8f:	38 08                	cmp    %cl,(%eax)
  800a91:	74 05                	je     800a98 <memfind+0x21>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a93:	40                   	inc    %eax
  800a94:	39 c2                	cmp    %eax,%edx
  800a96:	77 f7                	ja     800a8f <memfind+0x18>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a98:	c9                   	leave  
  800a99:	c3                   	ret    

00800a9a <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a9a:	55                   	push   %ebp
  800a9b:	89 e5                	mov    %esp,%ebp
  800a9d:	57                   	push   %edi
  800a9e:	56                   	push   %esi
  800a9f:	53                   	push   %ebx
  800aa0:	8b 55 08             	mov    0x8(%ebp),%edx
  800aa3:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800aa6:	eb 01                	jmp    800aa9 <strtol+0xf>
		s++;
  800aa8:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800aa9:	8a 02                	mov    (%edx),%al
  800aab:	3c 20                	cmp    $0x20,%al
  800aad:	74 f9                	je     800aa8 <strtol+0xe>
  800aaf:	3c 09                	cmp    $0x9,%al
  800ab1:	74 f5                	je     800aa8 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800ab3:	3c 2b                	cmp    $0x2b,%al
  800ab5:	75 08                	jne    800abf <strtol+0x25>
		s++;
  800ab7:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800ab8:	bf 00 00 00 00       	mov    $0x0,%edi
  800abd:	eb 13                	jmp    800ad2 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800abf:	3c 2d                	cmp    $0x2d,%al
  800ac1:	75 0a                	jne    800acd <strtol+0x33>
		s++, neg = 1;
  800ac3:	8d 52 01             	lea    0x1(%edx),%edx
  800ac6:	bf 01 00 00 00       	mov    $0x1,%edi
  800acb:	eb 05                	jmp    800ad2 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800acd:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800ad2:	85 db                	test   %ebx,%ebx
  800ad4:	74 05                	je     800adb <strtol+0x41>
  800ad6:	83 fb 10             	cmp    $0x10,%ebx
  800ad9:	75 28                	jne    800b03 <strtol+0x69>
  800adb:	8a 02                	mov    (%edx),%al
  800add:	3c 30                	cmp    $0x30,%al
  800adf:	75 10                	jne    800af1 <strtol+0x57>
  800ae1:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800ae5:	75 0a                	jne    800af1 <strtol+0x57>
		s += 2, base = 16;
  800ae7:	83 c2 02             	add    $0x2,%edx
  800aea:	bb 10 00 00 00       	mov    $0x10,%ebx
  800aef:	eb 12                	jmp    800b03 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800af1:	85 db                	test   %ebx,%ebx
  800af3:	75 0e                	jne    800b03 <strtol+0x69>
  800af5:	3c 30                	cmp    $0x30,%al
  800af7:	75 05                	jne    800afe <strtol+0x64>
		s++, base = 8;
  800af9:	42                   	inc    %edx
  800afa:	b3 08                	mov    $0x8,%bl
  800afc:	eb 05                	jmp    800b03 <strtol+0x69>
	else if (base == 0)
		base = 10;
  800afe:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800b03:	b8 00 00 00 00       	mov    $0x0,%eax
  800b08:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800b0a:	8a 0a                	mov    (%edx),%cl
  800b0c:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800b0f:	80 fb 09             	cmp    $0x9,%bl
  800b12:	77 08                	ja     800b1c <strtol+0x82>
			dig = *s - '0';
  800b14:	0f be c9             	movsbl %cl,%ecx
  800b17:	83 e9 30             	sub    $0x30,%ecx
  800b1a:	eb 1e                	jmp    800b3a <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800b1c:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800b1f:	80 fb 19             	cmp    $0x19,%bl
  800b22:	77 08                	ja     800b2c <strtol+0x92>
			dig = *s - 'a' + 10;
  800b24:	0f be c9             	movsbl %cl,%ecx
  800b27:	83 e9 57             	sub    $0x57,%ecx
  800b2a:	eb 0e                	jmp    800b3a <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800b2c:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800b2f:	80 fb 19             	cmp    $0x19,%bl
  800b32:	77 13                	ja     800b47 <strtol+0xad>
			dig = *s - 'A' + 10;
  800b34:	0f be c9             	movsbl %cl,%ecx
  800b37:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800b3a:	39 f1                	cmp    %esi,%ecx
  800b3c:	7d 0d                	jge    800b4b <strtol+0xb1>
			break;
		s++, val = (val * base) + dig;
  800b3e:	42                   	inc    %edx
  800b3f:	0f af c6             	imul   %esi,%eax
  800b42:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  800b45:	eb c3                	jmp    800b0a <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800b47:	89 c1                	mov    %eax,%ecx
  800b49:	eb 02                	jmp    800b4d <strtol+0xb3>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800b4b:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800b4d:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b51:	74 05                	je     800b58 <strtol+0xbe>
		*endptr = (char *) s;
  800b53:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800b56:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800b58:	85 ff                	test   %edi,%edi
  800b5a:	74 04                	je     800b60 <strtol+0xc6>
  800b5c:	89 c8                	mov    %ecx,%eax
  800b5e:	f7 d8                	neg    %eax
}
  800b60:	5b                   	pop    %ebx
  800b61:	5e                   	pop    %esi
  800b62:	5f                   	pop    %edi
  800b63:	c9                   	leave  
  800b64:	c3                   	ret    
  800b65:	00 00                	add    %al,(%eax)
	...

00800b68 <syscall>:
	return ret;
}

static int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800b68:	55                   	push   %ebp
  800b69:	89 e5                	mov    %esp,%ebp
  800b6b:	57                   	push   %edi
  800b6c:	56                   	push   %esi
  800b6d:	53                   	push   %ebx
  800b6e:	83 ec 1c             	sub    $0x1c,%esp
  800b71:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800b74:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800b77:	89 ca                	mov    %ecx,%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b79:	8b 75 14             	mov    0x14(%ebp),%esi
  800b7c:	8b 7d 10             	mov    0x10(%ebp),%edi
  800b7f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800b82:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b85:	cd 30                	int    $0x30
  800b87:	89 c2                	mov    %eax,%edx
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b89:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800b8d:	74 1c                	je     800bab <syscall+0x43>
  800b8f:	85 c0                	test   %eax,%eax
  800b91:	7e 18                	jle    800bab <syscall+0x43>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b93:	83 ec 0c             	sub    $0xc,%esp
  800b96:	50                   	push   %eax
  800b97:	ff 75 e4             	pushl  -0x1c(%ebp)
  800b9a:	68 24 13 80 00       	push   $0x801324
  800b9f:	6a 42                	push   $0x42
  800ba1:	68 41 13 80 00       	push   $0x801341
  800ba6:	e8 b1 f5 ff ff       	call   80015c <_panic>

	return ret;
}
  800bab:	89 d0                	mov    %edx,%eax
  800bad:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bb0:	5b                   	pop    %ebx
  800bb1:	5e                   	pop    %esi
  800bb2:	5f                   	pop    %edi
  800bb3:	c9                   	leave  
  800bb4:	c3                   	ret    

00800bb5 <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{	
  800bb5:	55                   	push   %ebp
  800bb6:	89 e5                	mov    %esp,%ebp
  800bb8:	83 ec 08             	sub    $0x8,%esp
	// my_sysenter(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
	// return;
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  800bbb:	6a 00                	push   $0x0
  800bbd:	6a 00                	push   $0x0
  800bbf:	6a 00                	push   $0x0
  800bc1:	ff 75 0c             	pushl  0xc(%ebp)
  800bc4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800bc7:	ba 00 00 00 00       	mov    $0x0,%edx
  800bcc:	b8 00 00 00 00       	mov    $0x0,%eax
  800bd1:	e8 92 ff ff ff       	call   800b68 <syscall>
  800bd6:	83 c4 10             	add    $0x10,%esp
	return;
}
  800bd9:	c9                   	leave  
  800bda:	c3                   	ret    

00800bdb <sys_cgetc>:

int
sys_cgetc(void)
{
  800bdb:	55                   	push   %ebp
  800bdc:	89 e5                	mov    %esp,%ebp
  800bde:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_cgetc, 0, 0, 0, 0, 0, 0);
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  800be1:	6a 00                	push   $0x0
  800be3:	6a 00                	push   $0x0
  800be5:	6a 00                	push   $0x0
  800be7:	6a 00                	push   $0x0
  800be9:	b9 00 00 00 00       	mov    $0x0,%ecx
  800bee:	ba 00 00 00 00       	mov    $0x0,%edx
  800bf3:	b8 01 00 00 00       	mov    $0x1,%eax
  800bf8:	e8 6b ff ff ff       	call   800b68 <syscall>
}
  800bfd:	c9                   	leave  
  800bfe:	c3                   	ret    

00800bff <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800bff:	55                   	push   %ebp
  800c00:	89 e5                	mov    %esp,%ebp
  800c02:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  800c05:	6a 00                	push   $0x0
  800c07:	6a 00                	push   $0x0
  800c09:	6a 00                	push   $0x0
  800c0b:	6a 00                	push   $0x0
  800c0d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c10:	ba 01 00 00 00       	mov    $0x1,%edx
  800c15:	b8 03 00 00 00       	mov    $0x3,%eax
  800c1a:	e8 49 ff ff ff       	call   800b68 <syscall>
}
  800c1f:	c9                   	leave  
  800c20:	c3                   	ret    

00800c21 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c21:	55                   	push   %ebp
  800c22:	89 e5                	mov    %esp,%ebp
  800c24:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_getenvid, 0, 0, 0, 0, 0, 0);
	return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  800c27:	6a 00                	push   $0x0
  800c29:	6a 00                	push   $0x0
  800c2b:	6a 00                	push   $0x0
  800c2d:	6a 00                	push   $0x0
  800c2f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c34:	ba 00 00 00 00       	mov    $0x0,%edx
  800c39:	b8 02 00 00 00       	mov    $0x2,%eax
  800c3e:	e8 25 ff ff ff       	call   800b68 <syscall>
}
  800c43:	c9                   	leave  
  800c44:	c3                   	ret    

00800c45 <sys_yield>:

void
sys_yield(void)
{
  800c45:	55                   	push   %ebp
  800c46:	89 e5                	mov    %esp,%ebp
  800c48:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  800c4b:	6a 00                	push   $0x0
  800c4d:	6a 00                	push   $0x0
  800c4f:	6a 00                	push   $0x0
  800c51:	6a 00                	push   $0x0
  800c53:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c58:	ba 00 00 00 00       	mov    $0x0,%edx
  800c5d:	b8 0a 00 00 00       	mov    $0xa,%eax
  800c62:	e8 01 ff ff ff       	call   800b68 <syscall>
  800c67:	83 c4 10             	add    $0x10,%esp
}
  800c6a:	c9                   	leave  
  800c6b:	c3                   	ret    

00800c6c <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c6c:	55                   	push   %ebp
  800c6d:	89 e5                	mov    %esp,%ebp
  800c6f:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  800c72:	6a 00                	push   $0x0
  800c74:	6a 00                	push   $0x0
  800c76:	ff 75 10             	pushl  0x10(%ebp)
  800c79:	ff 75 0c             	pushl  0xc(%ebp)
  800c7c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c7f:	ba 01 00 00 00       	mov    $0x1,%edx
  800c84:	b8 04 00 00 00       	mov    $0x4,%eax
  800c89:	e8 da fe ff ff       	call   800b68 <syscall>
}
  800c8e:	c9                   	leave  
  800c8f:	c3                   	ret    

00800c90 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c90:	55                   	push   %ebp
  800c91:	89 e5                	mov    %esp,%ebp
  800c93:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
  800c96:	ff 75 18             	pushl  0x18(%ebp)
  800c99:	ff 75 14             	pushl  0x14(%ebp)
  800c9c:	ff 75 10             	pushl  0x10(%ebp)
  800c9f:	ff 75 0c             	pushl  0xc(%ebp)
  800ca2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ca5:	ba 01 00 00 00       	mov    $0x1,%edx
  800caa:	b8 05 00 00 00       	mov    $0x5,%eax
  800caf:	e8 b4 fe ff ff       	call   800b68 <syscall>
}
  800cb4:	c9                   	leave  
  800cb5:	c3                   	ret    

00800cb6 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800cb6:	55                   	push   %ebp
  800cb7:	89 e5                	mov    %esp,%ebp
  800cb9:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  800cbc:	6a 00                	push   $0x0
  800cbe:	6a 00                	push   $0x0
  800cc0:	6a 00                	push   $0x0
  800cc2:	ff 75 0c             	pushl  0xc(%ebp)
  800cc5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800cc8:	ba 01 00 00 00       	mov    $0x1,%edx
  800ccd:	b8 06 00 00 00       	mov    $0x6,%eax
  800cd2:	e8 91 fe ff ff       	call   800b68 <syscall>
}
  800cd7:	c9                   	leave  
  800cd8:	c3                   	ret    

00800cd9 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800cd9:	55                   	push   %ebp
  800cda:	89 e5                	mov    %esp,%ebp
  800cdc:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  800cdf:	6a 00                	push   $0x0
  800ce1:	6a 00                	push   $0x0
  800ce3:	6a 00                	push   $0x0
  800ce5:	ff 75 0c             	pushl  0xc(%ebp)
  800ce8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ceb:	ba 01 00 00 00       	mov    $0x1,%edx
  800cf0:	b8 08 00 00 00       	mov    $0x8,%eax
  800cf5:	e8 6e fe ff ff       	call   800b68 <syscall>
}
  800cfa:	c9                   	leave  
  800cfb:	c3                   	ret    

00800cfc <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800cfc:	55                   	push   %ebp
  800cfd:	89 e5                	mov    %esp,%ebp
  800cff:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  800d02:	6a 00                	push   $0x0
  800d04:	6a 00                	push   $0x0
  800d06:	6a 00                	push   $0x0
  800d08:	ff 75 0c             	pushl  0xc(%ebp)
  800d0b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d0e:	ba 01 00 00 00       	mov    $0x1,%edx
  800d13:	b8 09 00 00 00       	mov    $0x9,%eax
  800d18:	e8 4b fe ff ff       	call   800b68 <syscall>
}
  800d1d:	c9                   	leave  
  800d1e:	c3                   	ret    

00800d1f <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d1f:	55                   	push   %ebp
  800d20:	89 e5                	mov    %esp,%ebp
  800d22:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  800d25:	6a 00                	push   $0x0
  800d27:	ff 75 14             	pushl  0x14(%ebp)
  800d2a:	ff 75 10             	pushl  0x10(%ebp)
  800d2d:	ff 75 0c             	pushl  0xc(%ebp)
  800d30:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d33:	ba 00 00 00 00       	mov    $0x0,%edx
  800d38:	b8 0b 00 00 00       	mov    $0xb,%eax
  800d3d:	e8 26 fe ff ff       	call   800b68 <syscall>
}
  800d42:	c9                   	leave  
  800d43:	c3                   	ret    

00800d44 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d44:	55                   	push   %ebp
  800d45:	89 e5                	mov    %esp,%ebp
  800d47:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  800d4a:	6a 00                	push   $0x0
  800d4c:	6a 00                	push   $0x0
  800d4e:	6a 00                	push   $0x0
  800d50:	6a 00                	push   $0x0
  800d52:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d55:	ba 01 00 00 00       	mov    $0x1,%edx
  800d5a:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d5f:	e8 04 fe ff ff       	call   800b68 <syscall>
}
  800d64:	c9                   	leave  
  800d65:	c3                   	ret    
	...

00800d68 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800d68:	55                   	push   %ebp
  800d69:	89 e5                	mov    %esp,%ebp
  800d6b:	83 ec 0c             	sub    $0xc,%esp
	// LAB 4: Your code here.
	panic("fork not implemented");
  800d6e:	68 5b 13 80 00       	push   $0x80135b
  800d73:	6a 52                	push   $0x52
  800d75:	68 4f 13 80 00       	push   $0x80134f
  800d7a:	e8 dd f3 ff ff       	call   80015c <_panic>

00800d7f <sfork>:
}

// Challenge!
int
sfork(void)
{
  800d7f:	55                   	push   %ebp
  800d80:	89 e5                	mov    %esp,%ebp
  800d82:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  800d85:	68 5a 13 80 00       	push   $0x80135a
  800d8a:	6a 59                	push   $0x59
  800d8c:	68 4f 13 80 00       	push   $0x80134f
  800d91:	e8 c6 f3 ff ff       	call   80015c <_panic>
	...

00800d98 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  800d98:	55                   	push   %ebp
  800d99:	89 e5                	mov    %esp,%ebp
  800d9b:	83 ec 0c             	sub    $0xc,%esp
	// LAB 4: Your code here.
	panic("ipc_recv not implemented");
  800d9e:	68 70 13 80 00       	push   $0x801370
  800da3:	6a 1a                	push   $0x1a
  800da5:	68 89 13 80 00       	push   $0x801389
  800daa:	e8 ad f3 ff ff       	call   80015c <_panic>

00800daf <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  800daf:	55                   	push   %ebp
  800db0:	89 e5                	mov    %esp,%ebp
  800db2:	83 ec 0c             	sub    $0xc,%esp
	// LAB 4: Your code here.
	panic("ipc_send not implemented");
  800db5:	68 93 13 80 00       	push   $0x801393
  800dba:	6a 2a                	push   $0x2a
  800dbc:	68 89 13 80 00       	push   $0x801389
  800dc1:	e8 96 f3 ff ff       	call   80015c <_panic>

00800dc6 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  800dc6:	55                   	push   %ebp
  800dc7:	89 e5                	mov    %esp,%ebp
  800dc9:	53                   	push   %ebx
  800dca:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  800dcd:	39 1d 50 00 c0 ee    	cmp    %ebx,0xeec00050
  800dd3:	74 22                	je     800df7 <ipc_find_env+0x31>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  800dd5:	b8 01 00 00 00       	mov    $0x1,%eax
		if (envs[i].env_type == type)
  800dda:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  800de1:	89 c2                	mov    %eax,%edx
  800de3:	c1 e2 07             	shl    $0x7,%edx
  800de6:	29 ca                	sub    %ecx,%edx
  800de8:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  800dee:	8b 52 50             	mov    0x50(%edx),%edx
  800df1:	39 da                	cmp    %ebx,%edx
  800df3:	75 1d                	jne    800e12 <ipc_find_env+0x4c>
  800df5:	eb 05                	jmp    800dfc <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  800df7:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
			return envs[i].env_id;
  800dfc:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800e03:	c1 e0 07             	shl    $0x7,%eax
  800e06:	29 d0                	sub    %edx,%eax
  800e08:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  800e0d:	8b 40 40             	mov    0x40(%eax),%eax
  800e10:	eb 0c                	jmp    800e1e <ipc_find_env+0x58>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  800e12:	40                   	inc    %eax
  800e13:	3d 00 04 00 00       	cmp    $0x400,%eax
  800e18:	75 c0                	jne    800dda <ipc_find_env+0x14>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  800e1a:	66 b8 00 00          	mov    $0x0,%ax
}
  800e1e:	5b                   	pop    %ebx
  800e1f:	c9                   	leave  
  800e20:	c3                   	ret    
  800e21:	00 00                	add    %al,(%eax)
	...

00800e24 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  800e24:	55                   	push   %ebp
  800e25:	89 e5                	mov    %esp,%ebp
  800e27:	57                   	push   %edi
  800e28:	56                   	push   %esi
  800e29:	83 ec 10             	sub    $0x10,%esp
  800e2c:	8b 7d 08             	mov    0x8(%ebp),%edi
  800e2f:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  800e32:	89 7d f0             	mov    %edi,-0x10(%ebp)
  800e35:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  800e38:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  800e3b:	8b 45 14             	mov    0x14(%ebp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800e3e:	85 c0                	test   %eax,%eax
  800e40:	75 2e                	jne    800e70 <__udivdi3+0x4c>
    {
      if (d0 > n1)
  800e42:	39 f1                	cmp    %esi,%ecx
  800e44:	77 5a                	ja     800ea0 <__udivdi3+0x7c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  800e46:	85 c9                	test   %ecx,%ecx
  800e48:	75 0b                	jne    800e55 <__udivdi3+0x31>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  800e4a:	b8 01 00 00 00       	mov    $0x1,%eax
  800e4f:	31 d2                	xor    %edx,%edx
  800e51:	f7 f1                	div    %ecx
  800e53:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  800e55:	31 d2                	xor    %edx,%edx
  800e57:	89 f0                	mov    %esi,%eax
  800e59:	f7 f1                	div    %ecx
  800e5b:	89 c6                	mov    %eax,%esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800e5d:	89 f8                	mov    %edi,%eax
  800e5f:	f7 f1                	div    %ecx
  800e61:	89 c7                	mov    %eax,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800e63:	89 f8                	mov    %edi,%eax
  800e65:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800e67:	83 c4 10             	add    $0x10,%esp
  800e6a:	5e                   	pop    %esi
  800e6b:	5f                   	pop    %edi
  800e6c:	c9                   	leave  
  800e6d:	c3                   	ret    
  800e6e:	66 90                	xchg   %ax,%ax
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800e70:	39 f0                	cmp    %esi,%eax
  800e72:	77 1c                	ja     800e90 <__udivdi3+0x6c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  800e74:	0f bd f8             	bsr    %eax,%edi
	  if (bm == 0)
  800e77:	83 f7 1f             	xor    $0x1f,%edi
  800e7a:	75 3c                	jne    800eb8 <__udivdi3+0x94>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800e7c:	39 f0                	cmp    %esi,%eax
  800e7e:	0f 82 90 00 00 00    	jb     800f14 <__udivdi3+0xf0>
  800e84:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800e87:	39 55 f4             	cmp    %edx,-0xc(%ebp)
  800e8a:	0f 86 84 00 00 00    	jbe    800f14 <__udivdi3+0xf0>
  800e90:	31 f6                	xor    %esi,%esi
  800e92:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800e94:	89 f8                	mov    %edi,%eax
  800e96:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800e98:	83 c4 10             	add    $0x10,%esp
  800e9b:	5e                   	pop    %esi
  800e9c:	5f                   	pop    %edi
  800e9d:	c9                   	leave  
  800e9e:	c3                   	ret    
  800e9f:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800ea0:	89 f2                	mov    %esi,%edx
  800ea2:	89 f8                	mov    %edi,%eax
  800ea4:	f7 f1                	div    %ecx
  800ea6:	89 c7                	mov    %eax,%edi
  800ea8:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800eaa:	89 f8                	mov    %edi,%eax
  800eac:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800eae:	83 c4 10             	add    $0x10,%esp
  800eb1:	5e                   	pop    %esi
  800eb2:	5f                   	pop    %edi
  800eb3:	c9                   	leave  
  800eb4:	c3                   	ret    
  800eb5:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  800eb8:	89 f9                	mov    %edi,%ecx
  800eba:	d3 e0                	shl    %cl,%eax
  800ebc:	89 45 e8             	mov    %eax,-0x18(%ebp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  800ebf:	b8 20 00 00 00       	mov    $0x20,%eax
  800ec4:	29 f8                	sub    %edi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  800ec6:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800ec9:	88 c1                	mov    %al,%cl
  800ecb:	d3 ea                	shr    %cl,%edx
  800ecd:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  800ed0:	09 ca                	or     %ecx,%edx
  800ed2:	89 55 ec             	mov    %edx,-0x14(%ebp)
	      d0 = d0 << bm;
  800ed5:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800ed8:	89 f9                	mov    %edi,%ecx
  800eda:	d3 e2                	shl    %cl,%edx
  800edc:	89 55 f4             	mov    %edx,-0xc(%ebp)
	      n2 = n1 >> b;
  800edf:	89 f2                	mov    %esi,%edx
  800ee1:	88 c1                	mov    %al,%cl
  800ee3:	d3 ea                	shr    %cl,%edx
  800ee5:	89 55 e8             	mov    %edx,-0x18(%ebp)
	      n1 = (n1 << bm) | (n0 >> b);
  800ee8:	89 f2                	mov    %esi,%edx
  800eea:	89 f9                	mov    %edi,%ecx
  800eec:	d3 e2                	shl    %cl,%edx
  800eee:	8b 75 f0             	mov    -0x10(%ebp),%esi
  800ef1:	88 c1                	mov    %al,%cl
  800ef3:	d3 ee                	shr    %cl,%esi
  800ef5:	09 d6                	or     %edx,%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  800ef7:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  800efa:	89 f0                	mov    %esi,%eax
  800efc:	89 ca                	mov    %ecx,%edx
  800efe:	f7 75 ec             	divl   -0x14(%ebp)
  800f01:	89 d1                	mov    %edx,%ecx
  800f03:	89 c6                	mov    %eax,%esi
	      umul_ppmm (m1, m0, q0, d0);
  800f05:	f7 65 f4             	mull   -0xc(%ebp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800f08:	39 d1                	cmp    %edx,%ecx
  800f0a:	72 28                	jb     800f34 <__udivdi3+0x110>
  800f0c:	74 1a                	je     800f28 <__udivdi3+0x104>
  800f0e:	89 f7                	mov    %esi,%edi
  800f10:	31 f6                	xor    %esi,%esi
  800f12:	eb 80                	jmp    800e94 <__udivdi3+0x70>
	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  800f14:	31 f6                	xor    %esi,%esi
  800f16:	bf 01 00 00 00       	mov    $0x1,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800f1b:	89 f8                	mov    %edi,%eax
  800f1d:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800f1f:	83 c4 10             	add    $0x10,%esp
  800f22:	5e                   	pop    %esi
  800f23:	5f                   	pop    %edi
  800f24:	c9                   	leave  
  800f25:	c3                   	ret    
  800f26:	66 90                	xchg   %ax,%ax

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  800f28:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800f2b:	89 f9                	mov    %edi,%ecx
  800f2d:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800f2f:	39 c2                	cmp    %eax,%edx
  800f31:	73 db                	jae    800f0e <__udivdi3+0xea>
  800f33:	90                   	nop
		{
		  q0--;
  800f34:	8d 7e ff             	lea    -0x1(%esi),%edi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  800f37:	31 f6                	xor    %esi,%esi
  800f39:	e9 56 ff ff ff       	jmp    800e94 <__udivdi3+0x70>
	...

00800f40 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  800f40:	55                   	push   %ebp
  800f41:	89 e5                	mov    %esp,%ebp
  800f43:	57                   	push   %edi
  800f44:	56                   	push   %esi
  800f45:	83 ec 20             	sub    $0x20,%esp
  800f48:	8b 45 08             	mov    0x8(%ebp),%eax
  800f4b:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  800f4e:	89 45 e8             	mov    %eax,-0x18(%ebp)
  800f51:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  800f54:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  800f57:	8b 7d 14             	mov    0x14(%ebp),%edi
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  800f5a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  n1 = nn.s.high;
  800f5d:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800f5f:	85 ff                	test   %edi,%edi
  800f61:	75 15                	jne    800f78 <__umoddi3+0x38>
    {
      if (d0 > n1)
  800f63:	39 f1                	cmp    %esi,%ecx
  800f65:	0f 86 99 00 00 00    	jbe    801004 <__umoddi3+0xc4>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800f6b:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  800f6d:	89 d0                	mov    %edx,%eax
  800f6f:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800f71:	83 c4 20             	add    $0x20,%esp
  800f74:	5e                   	pop    %esi
  800f75:	5f                   	pop    %edi
  800f76:	c9                   	leave  
  800f77:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800f78:	39 f7                	cmp    %esi,%edi
  800f7a:	0f 87 a4 00 00 00    	ja     801024 <__umoddi3+0xe4>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  800f80:	0f bd c7             	bsr    %edi,%eax
	  if (bm == 0)
  800f83:	83 f0 1f             	xor    $0x1f,%eax
  800f86:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800f89:	0f 84 a1 00 00 00    	je     801030 <__umoddi3+0xf0>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  800f8f:	89 f8                	mov    %edi,%eax
  800f91:	8a 4d ec             	mov    -0x14(%ebp),%cl
  800f94:	d3 e0                	shl    %cl,%eax
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  800f96:	bf 20 00 00 00       	mov    $0x20,%edi
  800f9b:	2b 7d ec             	sub    -0x14(%ebp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  800f9e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800fa1:	89 f9                	mov    %edi,%ecx
  800fa3:	d3 ea                	shr    %cl,%edx
  800fa5:	09 c2                	or     %eax,%edx
  800fa7:	89 55 f0             	mov    %edx,-0x10(%ebp)
	      d0 = d0 << bm;
  800faa:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800fad:	8a 4d ec             	mov    -0x14(%ebp),%cl
  800fb0:	d3 e0                	shl    %cl,%eax
  800fb2:	89 45 f4             	mov    %eax,-0xc(%ebp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  800fb5:	89 f2                	mov    %esi,%edx
  800fb7:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  800fb9:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800fbc:	d3 e0                	shl    %cl,%eax
  800fbe:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  800fc1:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800fc4:	89 f9                	mov    %edi,%ecx
  800fc6:	d3 e8                	shr    %cl,%eax
  800fc8:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  800fca:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  800fcc:	89 f2                	mov    %esi,%edx
  800fce:	f7 75 f0             	divl   -0x10(%ebp)
  800fd1:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  800fd3:	f7 65 f4             	mull   -0xc(%ebp)
  800fd6:	89 55 e8             	mov    %edx,-0x18(%ebp)
  800fd9:	89 c1                	mov    %eax,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800fdb:	39 d6                	cmp    %edx,%esi
  800fdd:	72 71                	jb     801050 <__umoddi3+0x110>
  800fdf:	74 7f                	je     801060 <__umoddi3+0x120>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  800fe1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800fe4:	29 c8                	sub    %ecx,%eax
  800fe6:	19 d6                	sbb    %edx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  800fe8:	8a 4d ec             	mov    -0x14(%ebp),%cl
  800feb:	d3 e8                	shr    %cl,%eax
  800fed:	89 f2                	mov    %esi,%edx
  800fef:	89 f9                	mov    %edi,%ecx
  800ff1:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  800ff3:	09 d0                	or     %edx,%eax
  800ff5:	89 f2                	mov    %esi,%edx
  800ff7:	8a 4d ec             	mov    -0x14(%ebp),%cl
  800ffa:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800ffc:	83 c4 20             	add    $0x20,%esp
  800fff:	5e                   	pop    %esi
  801000:	5f                   	pop    %edi
  801001:	c9                   	leave  
  801002:	c3                   	ret    
  801003:	90                   	nop
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  801004:	85 c9                	test   %ecx,%ecx
  801006:	75 0b                	jne    801013 <__umoddi3+0xd3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  801008:	b8 01 00 00 00       	mov    $0x1,%eax
  80100d:	31 d2                	xor    %edx,%edx
  80100f:	f7 f1                	div    %ecx
  801011:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  801013:	89 f0                	mov    %esi,%eax
  801015:	31 d2                	xor    %edx,%edx
  801017:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801019:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80101c:	f7 f1                	div    %ecx
  80101e:	e9 4a ff ff ff       	jmp    800f6d <__umoddi3+0x2d>
  801023:	90                   	nop
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  801024:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801026:	83 c4 20             	add    $0x20,%esp
  801029:	5e                   	pop    %esi
  80102a:	5f                   	pop    %edi
  80102b:	c9                   	leave  
  80102c:	c3                   	ret    
  80102d:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801030:	39 f7                	cmp    %esi,%edi
  801032:	72 05                	jb     801039 <__umoddi3+0xf9>
  801034:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
  801037:	77 0c                	ja     801045 <__umoddi3+0x105>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  801039:	89 f2                	mov    %esi,%edx
  80103b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80103e:	29 c8                	sub    %ecx,%eax
  801040:	19 fa                	sbb    %edi,%edx
  801042:	89 45 f0             	mov    %eax,-0x10(%ebp)

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  801045:	8b 45 f0             	mov    -0x10(%ebp),%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801048:	83 c4 20             	add    $0x20,%esp
  80104b:	5e                   	pop    %esi
  80104c:	5f                   	pop    %edi
  80104d:	c9                   	leave  
  80104e:	c3                   	ret    
  80104f:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  801050:	8b 55 e8             	mov    -0x18(%ebp),%edx
  801053:	89 c1                	mov    %eax,%ecx
  801055:	2b 4d f4             	sub    -0xc(%ebp),%ecx
  801058:	1b 55 f0             	sbb    -0x10(%ebp),%edx
  80105b:	eb 84                	jmp    800fe1 <__umoddi3+0xa1>
  80105d:	8d 76 00             	lea    0x0(%esi),%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801060:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801063:	72 eb                	jb     801050 <__umoddi3+0x110>
  801065:	89 f2                	mov    %esi,%edx
  801067:	e9 75 ff ff ff       	jmp    800fe1 <__umoddi3+0xa1>
