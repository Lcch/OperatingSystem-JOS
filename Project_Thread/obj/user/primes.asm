
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
  800048:	e8 e7 10 00 00       	call   801134 <ipc_recv>
  80004d:	89 c3                	mov    %eax,%ebx
	cprintf("CPU %d: %d ", thisenv->env_cpunum, p);
  80004f:	a1 04 40 80 00       	mov    0x804004,%eax
  800054:	8b 40 5c             	mov    0x5c(%eax),%eax
  800057:	83 c4 0c             	add    $0xc,%esp
  80005a:	53                   	push   %ebx
  80005b:	50                   	push   %eax
  80005c:	68 20 22 80 00       	push   $0x802220
  800061:	e8 d2 01 00 00       	call   800238 <cprintf>

	// fork a right neighbor to continue the chain
	if ((id = fork()) < 0)
  800066:	e8 83 0e 00 00       	call   800eee <fork>
  80006b:	89 c7                	mov    %eax,%edi
  80006d:	83 c4 10             	add    $0x10,%esp
  800070:	85 c0                	test   %eax,%eax
  800072:	79 12                	jns    800086 <primeproc+0x52>
		panic("fork: %e", id);
  800074:	50                   	push   %eax
  800075:	68 2c 22 80 00       	push   $0x80222c
  80007a:	6a 1a                	push   $0x1a
  80007c:	68 35 22 80 00       	push   $0x802235
  800081:	e8 da 00 00 00       	call   800160 <_panic>
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
  800095:	e8 9a 10 00 00       	call   801134 <ipc_recv>
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
  8000ac:	e8 f8 10 00 00       	call   8011a9 <ipc_send>
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
  8000bb:	e8 2e 0e 00 00       	call   800eee <fork>
  8000c0:	89 c3                	mov    %eax,%ebx
  8000c2:	85 c0                	test   %eax,%eax
  8000c4:	79 12                	jns    8000d8 <umain+0x22>
		panic("fork: %e", id);
  8000c6:	50                   	push   %eax
  8000c7:	68 2c 22 80 00       	push   $0x80222c
  8000cc:	6a 2d                	push   $0x2d
  8000ce:	68 35 22 80 00       	push   $0x802235
  8000d3:	e8 88 00 00 00       	call   800160 <_panic>
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
  8000ec:	e8 b8 10 00 00       	call   8011a9 <ipc_send>
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
  800103:	e8 1d 0b 00 00       	call   800c25 <sys_getenvid>
  800108:	25 ff 03 00 00       	and    $0x3ff,%eax
  80010d:	89 c2                	mov    %eax,%edx
  80010f:	c1 e2 07             	shl    $0x7,%edx
  800112:	8d 84 82 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,4),%eax
  800119:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80011e:	85 f6                	test   %esi,%esi
  800120:	7e 07                	jle    800129 <libmain+0x31>
		binaryname = argv[0];
  800122:	8b 03                	mov    (%ebx),%eax
  800124:	a3 00 30 80 00       	mov    %eax,0x803000
	// call user main routine
	umain(argc, argv);
  800129:	83 ec 08             	sub    $0x8,%esp
  80012c:	53                   	push   %ebx
  80012d:	56                   	push   %esi
  80012e:	e8 83 ff ff ff       	call   8000b6 <umain>

	// exit gracefully
	exit();
  800133:	e8 0c 00 00 00       	call   800144 <exit>
  800138:	83 c4 10             	add    $0x10,%esp
}
  80013b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80013e:	5b                   	pop    %ebx
  80013f:	5e                   	pop    %esi
  800140:	c9                   	leave  
  800141:	c3                   	ret    
	...

00800144 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800144:	55                   	push   %ebp
  800145:	89 e5                	mov    %esp,%ebp
  800147:	83 ec 08             	sub    $0x8,%esp
	close_all();
  80014a:	e8 07 13 00 00       	call   801456 <close_all>
	sys_env_destroy(0);
  80014f:	83 ec 0c             	sub    $0xc,%esp
  800152:	6a 00                	push   $0x0
  800154:	e8 aa 0a 00 00       	call   800c03 <sys_env_destroy>
  800159:	83 c4 10             	add    $0x10,%esp
}
  80015c:	c9                   	leave  
  80015d:	c3                   	ret    
	...

00800160 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800160:	55                   	push   %ebp
  800161:	89 e5                	mov    %esp,%ebp
  800163:	56                   	push   %esi
  800164:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800165:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800168:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  80016e:	e8 b2 0a 00 00       	call   800c25 <sys_getenvid>
  800173:	83 ec 0c             	sub    $0xc,%esp
  800176:	ff 75 0c             	pushl  0xc(%ebp)
  800179:	ff 75 08             	pushl  0x8(%ebp)
  80017c:	53                   	push   %ebx
  80017d:	50                   	push   %eax
  80017e:	68 50 22 80 00       	push   $0x802250
  800183:	e8 b0 00 00 00       	call   800238 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800188:	83 c4 18             	add    $0x18,%esp
  80018b:	56                   	push   %esi
  80018c:	ff 75 10             	pushl  0x10(%ebp)
  80018f:	e8 53 00 00 00       	call   8001e7 <vcprintf>
	cprintf("\n");
  800194:	c7 04 24 23 28 80 00 	movl   $0x802823,(%esp)
  80019b:	e8 98 00 00 00       	call   800238 <cprintf>
  8001a0:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8001a3:	cc                   	int3   
  8001a4:	eb fd                	jmp    8001a3 <_panic+0x43>
	...

008001a8 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001a8:	55                   	push   %ebp
  8001a9:	89 e5                	mov    %esp,%ebp
  8001ab:	53                   	push   %ebx
  8001ac:	83 ec 04             	sub    $0x4,%esp
  8001af:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001b2:	8b 03                	mov    (%ebx),%eax
  8001b4:	8b 55 08             	mov    0x8(%ebp),%edx
  8001b7:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8001bb:	40                   	inc    %eax
  8001bc:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8001be:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001c3:	75 1a                	jne    8001df <putch+0x37>
		sys_cputs(b->buf, b->idx);
  8001c5:	83 ec 08             	sub    $0x8,%esp
  8001c8:	68 ff 00 00 00       	push   $0xff
  8001cd:	8d 43 08             	lea    0x8(%ebx),%eax
  8001d0:	50                   	push   %eax
  8001d1:	e8 e3 09 00 00       	call   800bb9 <sys_cputs>
		b->idx = 0;
  8001d6:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001dc:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8001df:	ff 43 04             	incl   0x4(%ebx)
}
  8001e2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001e5:	c9                   	leave  
  8001e6:	c3                   	ret    

008001e7 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001e7:	55                   	push   %ebp
  8001e8:	89 e5                	mov    %esp,%ebp
  8001ea:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001f0:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001f7:	00 00 00 
	b.cnt = 0;
  8001fa:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800201:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800204:	ff 75 0c             	pushl  0xc(%ebp)
  800207:	ff 75 08             	pushl  0x8(%ebp)
  80020a:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800210:	50                   	push   %eax
  800211:	68 a8 01 80 00       	push   $0x8001a8
  800216:	e8 82 01 00 00       	call   80039d <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80021b:	83 c4 08             	add    $0x8,%esp
  80021e:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800224:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80022a:	50                   	push   %eax
  80022b:	e8 89 09 00 00       	call   800bb9 <sys_cputs>

	return b.cnt;
}
  800230:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800236:	c9                   	leave  
  800237:	c3                   	ret    

00800238 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800238:	55                   	push   %ebp
  800239:	89 e5                	mov    %esp,%ebp
  80023b:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80023e:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800241:	50                   	push   %eax
  800242:	ff 75 08             	pushl  0x8(%ebp)
  800245:	e8 9d ff ff ff       	call   8001e7 <vcprintf>
	va_end(ap);

	return cnt;
}
  80024a:	c9                   	leave  
  80024b:	c3                   	ret    

0080024c <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80024c:	55                   	push   %ebp
  80024d:	89 e5                	mov    %esp,%ebp
  80024f:	57                   	push   %edi
  800250:	56                   	push   %esi
  800251:	53                   	push   %ebx
  800252:	83 ec 2c             	sub    $0x2c,%esp
  800255:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800258:	89 d6                	mov    %edx,%esi
  80025a:	8b 45 08             	mov    0x8(%ebp),%eax
  80025d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800260:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800263:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800266:	8b 45 10             	mov    0x10(%ebp),%eax
  800269:	8b 5d 14             	mov    0x14(%ebp),%ebx
  80026c:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80026f:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800272:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  800279:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
  80027c:	72 0c                	jb     80028a <printnum+0x3e>
  80027e:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  800281:	76 07                	jbe    80028a <printnum+0x3e>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800283:	4b                   	dec    %ebx
  800284:	85 db                	test   %ebx,%ebx
  800286:	7f 31                	jg     8002b9 <printnum+0x6d>
  800288:	eb 3f                	jmp    8002c9 <printnum+0x7d>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80028a:	83 ec 0c             	sub    $0xc,%esp
  80028d:	57                   	push   %edi
  80028e:	4b                   	dec    %ebx
  80028f:	53                   	push   %ebx
  800290:	50                   	push   %eax
  800291:	83 ec 08             	sub    $0x8,%esp
  800294:	ff 75 d4             	pushl  -0x2c(%ebp)
  800297:	ff 75 d0             	pushl  -0x30(%ebp)
  80029a:	ff 75 dc             	pushl  -0x24(%ebp)
  80029d:	ff 75 d8             	pushl  -0x28(%ebp)
  8002a0:	e8 33 1d 00 00       	call   801fd8 <__udivdi3>
  8002a5:	83 c4 18             	add    $0x18,%esp
  8002a8:	52                   	push   %edx
  8002a9:	50                   	push   %eax
  8002aa:	89 f2                	mov    %esi,%edx
  8002ac:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8002af:	e8 98 ff ff ff       	call   80024c <printnum>
  8002b4:	83 c4 20             	add    $0x20,%esp
  8002b7:	eb 10                	jmp    8002c9 <printnum+0x7d>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002b9:	83 ec 08             	sub    $0x8,%esp
  8002bc:	56                   	push   %esi
  8002bd:	57                   	push   %edi
  8002be:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002c1:	4b                   	dec    %ebx
  8002c2:	83 c4 10             	add    $0x10,%esp
  8002c5:	85 db                	test   %ebx,%ebx
  8002c7:	7f f0                	jg     8002b9 <printnum+0x6d>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002c9:	83 ec 08             	sub    $0x8,%esp
  8002cc:	56                   	push   %esi
  8002cd:	83 ec 04             	sub    $0x4,%esp
  8002d0:	ff 75 d4             	pushl  -0x2c(%ebp)
  8002d3:	ff 75 d0             	pushl  -0x30(%ebp)
  8002d6:	ff 75 dc             	pushl  -0x24(%ebp)
  8002d9:	ff 75 d8             	pushl  -0x28(%ebp)
  8002dc:	e8 13 1e 00 00       	call   8020f4 <__umoddi3>
  8002e1:	83 c4 14             	add    $0x14,%esp
  8002e4:	0f be 80 73 22 80 00 	movsbl 0x802273(%eax),%eax
  8002eb:	50                   	push   %eax
  8002ec:	ff 55 e4             	call   *-0x1c(%ebp)
  8002ef:	83 c4 10             	add    $0x10,%esp
}
  8002f2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002f5:	5b                   	pop    %ebx
  8002f6:	5e                   	pop    %esi
  8002f7:	5f                   	pop    %edi
  8002f8:	c9                   	leave  
  8002f9:	c3                   	ret    

008002fa <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002fa:	55                   	push   %ebp
  8002fb:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002fd:	83 fa 01             	cmp    $0x1,%edx
  800300:	7e 0e                	jle    800310 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800302:	8b 10                	mov    (%eax),%edx
  800304:	8d 4a 08             	lea    0x8(%edx),%ecx
  800307:	89 08                	mov    %ecx,(%eax)
  800309:	8b 02                	mov    (%edx),%eax
  80030b:	8b 52 04             	mov    0x4(%edx),%edx
  80030e:	eb 22                	jmp    800332 <getuint+0x38>
	else if (lflag)
  800310:	85 d2                	test   %edx,%edx
  800312:	74 10                	je     800324 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800314:	8b 10                	mov    (%eax),%edx
  800316:	8d 4a 04             	lea    0x4(%edx),%ecx
  800319:	89 08                	mov    %ecx,(%eax)
  80031b:	8b 02                	mov    (%edx),%eax
  80031d:	ba 00 00 00 00       	mov    $0x0,%edx
  800322:	eb 0e                	jmp    800332 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800324:	8b 10                	mov    (%eax),%edx
  800326:	8d 4a 04             	lea    0x4(%edx),%ecx
  800329:	89 08                	mov    %ecx,(%eax)
  80032b:	8b 02                	mov    (%edx),%eax
  80032d:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800332:	c9                   	leave  
  800333:	c3                   	ret    

00800334 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  800334:	55                   	push   %ebp
  800335:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800337:	83 fa 01             	cmp    $0x1,%edx
  80033a:	7e 0e                	jle    80034a <getint+0x16>
		return va_arg(*ap, long long);
  80033c:	8b 10                	mov    (%eax),%edx
  80033e:	8d 4a 08             	lea    0x8(%edx),%ecx
  800341:	89 08                	mov    %ecx,(%eax)
  800343:	8b 02                	mov    (%edx),%eax
  800345:	8b 52 04             	mov    0x4(%edx),%edx
  800348:	eb 1a                	jmp    800364 <getint+0x30>
	else if (lflag)
  80034a:	85 d2                	test   %edx,%edx
  80034c:	74 0c                	je     80035a <getint+0x26>
		return va_arg(*ap, long);
  80034e:	8b 10                	mov    (%eax),%edx
  800350:	8d 4a 04             	lea    0x4(%edx),%ecx
  800353:	89 08                	mov    %ecx,(%eax)
  800355:	8b 02                	mov    (%edx),%eax
  800357:	99                   	cltd   
  800358:	eb 0a                	jmp    800364 <getint+0x30>
	else
		return va_arg(*ap, int);
  80035a:	8b 10                	mov    (%eax),%edx
  80035c:	8d 4a 04             	lea    0x4(%edx),%ecx
  80035f:	89 08                	mov    %ecx,(%eax)
  800361:	8b 02                	mov    (%edx),%eax
  800363:	99                   	cltd   
}
  800364:	c9                   	leave  
  800365:	c3                   	ret    

00800366 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800366:	55                   	push   %ebp
  800367:	89 e5                	mov    %esp,%ebp
  800369:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80036c:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  80036f:	8b 10                	mov    (%eax),%edx
  800371:	3b 50 04             	cmp    0x4(%eax),%edx
  800374:	73 08                	jae    80037e <sprintputch+0x18>
		*b->buf++ = ch;
  800376:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800379:	88 0a                	mov    %cl,(%edx)
  80037b:	42                   	inc    %edx
  80037c:	89 10                	mov    %edx,(%eax)
}
  80037e:	c9                   	leave  
  80037f:	c3                   	ret    

00800380 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800380:	55                   	push   %ebp
  800381:	89 e5                	mov    %esp,%ebp
  800383:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800386:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800389:	50                   	push   %eax
  80038a:	ff 75 10             	pushl  0x10(%ebp)
  80038d:	ff 75 0c             	pushl  0xc(%ebp)
  800390:	ff 75 08             	pushl  0x8(%ebp)
  800393:	e8 05 00 00 00       	call   80039d <vprintfmt>
	va_end(ap);
  800398:	83 c4 10             	add    $0x10,%esp
}
  80039b:	c9                   	leave  
  80039c:	c3                   	ret    

0080039d <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80039d:	55                   	push   %ebp
  80039e:	89 e5                	mov    %esp,%ebp
  8003a0:	57                   	push   %edi
  8003a1:	56                   	push   %esi
  8003a2:	53                   	push   %ebx
  8003a3:	83 ec 2c             	sub    $0x2c,%esp
  8003a6:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8003a9:	8b 75 10             	mov    0x10(%ebp),%esi
  8003ac:	eb 13                	jmp    8003c1 <vprintfmt+0x24>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8003ae:	85 c0                	test   %eax,%eax
  8003b0:	0f 84 6d 03 00 00    	je     800723 <vprintfmt+0x386>
				return;
			putch(ch, putdat);
  8003b6:	83 ec 08             	sub    $0x8,%esp
  8003b9:	57                   	push   %edi
  8003ba:	50                   	push   %eax
  8003bb:	ff 55 08             	call   *0x8(%ebp)
  8003be:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8003c1:	0f b6 06             	movzbl (%esi),%eax
  8003c4:	46                   	inc    %esi
  8003c5:	83 f8 25             	cmp    $0x25,%eax
  8003c8:	75 e4                	jne    8003ae <vprintfmt+0x11>
  8003ca:	c6 45 dc 20          	movb   $0x20,-0x24(%ebp)
  8003ce:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  8003d5:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  8003dc:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  8003e3:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003e8:	eb 28                	jmp    800412 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ea:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  8003ec:	c6 45 dc 2d          	movb   $0x2d,-0x24(%ebp)
  8003f0:	eb 20                	jmp    800412 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003f2:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8003f4:	c6 45 dc 30          	movb   $0x30,-0x24(%ebp)
  8003f8:	eb 18                	jmp    800412 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003fa:	89 de                	mov    %ebx,%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  8003fc:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800403:	eb 0d                	jmp    800412 <vprintfmt+0x75>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800405:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800408:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80040b:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800412:	8a 06                	mov    (%esi),%al
  800414:	0f b6 d0             	movzbl %al,%edx
  800417:	8d 5e 01             	lea    0x1(%esi),%ebx
  80041a:	83 e8 23             	sub    $0x23,%eax
  80041d:	3c 55                	cmp    $0x55,%al
  80041f:	0f 87 e0 02 00 00    	ja     800705 <vprintfmt+0x368>
  800425:	0f b6 c0             	movzbl %al,%eax
  800428:	ff 24 85 c0 23 80 00 	jmp    *0x8023c0(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80042f:	83 ea 30             	sub    $0x30,%edx
  800432:	89 55 d4             	mov    %edx,-0x2c(%ebp)
				ch = *fmt;
  800435:	0f be 03             	movsbl (%ebx),%eax
				if (ch < '0' || ch > '9')
  800438:	8d 50 d0             	lea    -0x30(%eax),%edx
  80043b:	83 fa 09             	cmp    $0x9,%edx
  80043e:	77 44                	ja     800484 <vprintfmt+0xe7>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800440:	89 de                	mov    %ebx,%esi
  800442:	8b 55 d4             	mov    -0x2c(%ebp),%edx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800445:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
  800446:	8d 14 92             	lea    (%edx,%edx,4),%edx
  800449:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
  80044d:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800450:	8d 58 d0             	lea    -0x30(%eax),%ebx
  800453:	83 fb 09             	cmp    $0x9,%ebx
  800456:	76 ed                	jbe    800445 <vprintfmt+0xa8>
  800458:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  80045b:	eb 29                	jmp    800486 <vprintfmt+0xe9>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80045d:	8b 45 14             	mov    0x14(%ebp),%eax
  800460:	8d 50 04             	lea    0x4(%eax),%edx
  800463:	89 55 14             	mov    %edx,0x14(%ebp)
  800466:	8b 00                	mov    (%eax),%eax
  800468:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80046b:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80046d:	eb 17                	jmp    800486 <vprintfmt+0xe9>

		case '.':
			if (width < 0)
  80046f:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800473:	78 85                	js     8003fa <vprintfmt+0x5d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800475:	89 de                	mov    %ebx,%esi
  800477:	eb 99                	jmp    800412 <vprintfmt+0x75>
  800479:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80047b:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  800482:	eb 8e                	jmp    800412 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800484:	89 de                	mov    %ebx,%esi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  800486:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80048a:	79 86                	jns    800412 <vprintfmt+0x75>
  80048c:	e9 74 ff ff ff       	jmp    800405 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800491:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800492:	89 de                	mov    %ebx,%esi
  800494:	e9 79 ff ff ff       	jmp    800412 <vprintfmt+0x75>
  800499:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80049c:	8b 45 14             	mov    0x14(%ebp),%eax
  80049f:	8d 50 04             	lea    0x4(%eax),%edx
  8004a2:	89 55 14             	mov    %edx,0x14(%ebp)
  8004a5:	83 ec 08             	sub    $0x8,%esp
  8004a8:	57                   	push   %edi
  8004a9:	ff 30                	pushl  (%eax)
  8004ab:	ff 55 08             	call   *0x8(%ebp)
			break;
  8004ae:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004b1:	8b 75 d8             	mov    -0x28(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8004b4:	e9 08 ff ff ff       	jmp    8003c1 <vprintfmt+0x24>
  8004b9:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  8004bc:	8b 45 14             	mov    0x14(%ebp),%eax
  8004bf:	8d 50 04             	lea    0x4(%eax),%edx
  8004c2:	89 55 14             	mov    %edx,0x14(%ebp)
  8004c5:	8b 00                	mov    (%eax),%eax
  8004c7:	85 c0                	test   %eax,%eax
  8004c9:	79 02                	jns    8004cd <vprintfmt+0x130>
  8004cb:	f7 d8                	neg    %eax
  8004cd:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004cf:	83 f8 0f             	cmp    $0xf,%eax
  8004d2:	7f 0b                	jg     8004df <vprintfmt+0x142>
  8004d4:	8b 04 85 20 25 80 00 	mov    0x802520(,%eax,4),%eax
  8004db:	85 c0                	test   %eax,%eax
  8004dd:	75 1a                	jne    8004f9 <vprintfmt+0x15c>
				printfmt(putch, putdat, "error %d", err);
  8004df:	52                   	push   %edx
  8004e0:	68 8b 22 80 00       	push   $0x80228b
  8004e5:	57                   	push   %edi
  8004e6:	ff 75 08             	pushl  0x8(%ebp)
  8004e9:	e8 92 fe ff ff       	call   800380 <printfmt>
  8004ee:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004f1:	8b 75 d8             	mov    -0x28(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8004f4:	e9 c8 fe ff ff       	jmp    8003c1 <vprintfmt+0x24>
			else
				printfmt(putch, putdat, "%s", p);
  8004f9:	50                   	push   %eax
  8004fa:	68 f1 27 80 00       	push   $0x8027f1
  8004ff:	57                   	push   %edi
  800500:	ff 75 08             	pushl  0x8(%ebp)
  800503:	e8 78 fe ff ff       	call   800380 <printfmt>
  800508:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80050b:	8b 75 d8             	mov    -0x28(%ebp),%esi
  80050e:	e9 ae fe ff ff       	jmp    8003c1 <vprintfmt+0x24>
  800513:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  800516:	89 de                	mov    %ebx,%esi
  800518:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  80051b:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80051e:	8b 45 14             	mov    0x14(%ebp),%eax
  800521:	8d 50 04             	lea    0x4(%eax),%edx
  800524:	89 55 14             	mov    %edx,0x14(%ebp)
  800527:	8b 00                	mov    (%eax),%eax
  800529:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80052c:	85 c0                	test   %eax,%eax
  80052e:	75 07                	jne    800537 <vprintfmt+0x19a>
				p = "(null)";
  800530:	c7 45 d0 84 22 80 00 	movl   $0x802284,-0x30(%ebp)
			if (width > 0 && padc != '-')
  800537:	85 db                	test   %ebx,%ebx
  800539:	7e 42                	jle    80057d <vprintfmt+0x1e0>
  80053b:	80 7d dc 2d          	cmpb   $0x2d,-0x24(%ebp)
  80053f:	74 3c                	je     80057d <vprintfmt+0x1e0>
				for (width -= strnlen(p, precision); width > 0; width--)
  800541:	83 ec 08             	sub    $0x8,%esp
  800544:	51                   	push   %ecx
  800545:	ff 75 d0             	pushl  -0x30(%ebp)
  800548:	e8 6f 02 00 00       	call   8007bc <strnlen>
  80054d:	29 c3                	sub    %eax,%ebx
  80054f:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800552:	83 c4 10             	add    $0x10,%esp
  800555:	85 db                	test   %ebx,%ebx
  800557:	7e 24                	jle    80057d <vprintfmt+0x1e0>
					putch(padc, putdat);
  800559:	0f be 5d dc          	movsbl -0x24(%ebp),%ebx
  80055d:	89 75 dc             	mov    %esi,-0x24(%ebp)
  800560:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  800563:	83 ec 08             	sub    $0x8,%esp
  800566:	57                   	push   %edi
  800567:	53                   	push   %ebx
  800568:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80056b:	4e                   	dec    %esi
  80056c:	83 c4 10             	add    $0x10,%esp
  80056f:	85 f6                	test   %esi,%esi
  800571:	7f f0                	jg     800563 <vprintfmt+0x1c6>
  800573:	8b 75 dc             	mov    -0x24(%ebp),%esi
  800576:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80057d:	8b 55 d0             	mov    -0x30(%ebp),%edx
  800580:	0f be 02             	movsbl (%edx),%eax
  800583:	85 c0                	test   %eax,%eax
  800585:	75 47                	jne    8005ce <vprintfmt+0x231>
  800587:	eb 37                	jmp    8005c0 <vprintfmt+0x223>
				if (altflag && (ch < ' ' || ch > '~'))
  800589:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80058d:	74 16                	je     8005a5 <vprintfmt+0x208>
  80058f:	8d 50 e0             	lea    -0x20(%eax),%edx
  800592:	83 fa 5e             	cmp    $0x5e,%edx
  800595:	76 0e                	jbe    8005a5 <vprintfmt+0x208>
					putch('?', putdat);
  800597:	83 ec 08             	sub    $0x8,%esp
  80059a:	57                   	push   %edi
  80059b:	6a 3f                	push   $0x3f
  80059d:	ff 55 08             	call   *0x8(%ebp)
  8005a0:	83 c4 10             	add    $0x10,%esp
  8005a3:	eb 0b                	jmp    8005b0 <vprintfmt+0x213>
				else
					putch(ch, putdat);
  8005a5:	83 ec 08             	sub    $0x8,%esp
  8005a8:	57                   	push   %edi
  8005a9:	50                   	push   %eax
  8005aa:	ff 55 08             	call   *0x8(%ebp)
  8005ad:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005b0:	ff 4d e4             	decl   -0x1c(%ebp)
  8005b3:	0f be 03             	movsbl (%ebx),%eax
  8005b6:	85 c0                	test   %eax,%eax
  8005b8:	74 03                	je     8005bd <vprintfmt+0x220>
  8005ba:	43                   	inc    %ebx
  8005bb:	eb 1b                	jmp    8005d8 <vprintfmt+0x23b>
  8005bd:	8b 75 dc             	mov    -0x24(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005c0:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8005c4:	7f 1e                	jg     8005e4 <vprintfmt+0x247>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005c6:	8b 75 d8             	mov    -0x28(%ebp),%esi
  8005c9:	e9 f3 fd ff ff       	jmp    8003c1 <vprintfmt+0x24>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005ce:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  8005d1:	43                   	inc    %ebx
  8005d2:	89 75 dc             	mov    %esi,-0x24(%ebp)
  8005d5:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  8005d8:	85 f6                	test   %esi,%esi
  8005da:	78 ad                	js     800589 <vprintfmt+0x1ec>
  8005dc:	4e                   	dec    %esi
  8005dd:	79 aa                	jns    800589 <vprintfmt+0x1ec>
  8005df:	8b 75 dc             	mov    -0x24(%ebp),%esi
  8005e2:	eb dc                	jmp    8005c0 <vprintfmt+0x223>
  8005e4:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8005e7:	83 ec 08             	sub    $0x8,%esp
  8005ea:	57                   	push   %edi
  8005eb:	6a 20                	push   $0x20
  8005ed:	ff 55 08             	call   *0x8(%ebp)
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005f0:	4b                   	dec    %ebx
  8005f1:	83 c4 10             	add    $0x10,%esp
  8005f4:	85 db                	test   %ebx,%ebx
  8005f6:	7f ef                	jg     8005e7 <vprintfmt+0x24a>
  8005f8:	e9 c4 fd ff ff       	jmp    8003c1 <vprintfmt+0x24>
  8005fd:	89 5d d8             	mov    %ebx,-0x28(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800600:	89 ca                	mov    %ecx,%edx
  800602:	8d 45 14             	lea    0x14(%ebp),%eax
  800605:	e8 2a fd ff ff       	call   800334 <getint>
  80060a:	89 c3                	mov    %eax,%ebx
  80060c:	89 d6                	mov    %edx,%esi
			if ((long long) num < 0) {
  80060e:	85 d2                	test   %edx,%edx
  800610:	78 0a                	js     80061c <vprintfmt+0x27f>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800612:	b8 0a 00 00 00       	mov    $0xa,%eax
  800617:	e9 b0 00 00 00       	jmp    8006cc <vprintfmt+0x32f>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  80061c:	83 ec 08             	sub    $0x8,%esp
  80061f:	57                   	push   %edi
  800620:	6a 2d                	push   $0x2d
  800622:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800625:	f7 db                	neg    %ebx
  800627:	83 d6 00             	adc    $0x0,%esi
  80062a:	f7 de                	neg    %esi
  80062c:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  80062f:	b8 0a 00 00 00       	mov    $0xa,%eax
  800634:	e9 93 00 00 00       	jmp    8006cc <vprintfmt+0x32f>
  800639:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80063c:	89 ca                	mov    %ecx,%edx
  80063e:	8d 45 14             	lea    0x14(%ebp),%eax
  800641:	e8 b4 fc ff ff       	call   8002fa <getuint>
  800646:	89 c3                	mov    %eax,%ebx
  800648:	89 d6                	mov    %edx,%esi
			base = 10;
  80064a:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  80064f:	eb 7b                	jmp    8006cc <vprintfmt+0x32f>
  800651:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
  800654:	89 ca                	mov    %ecx,%edx
  800656:	8d 45 14             	lea    0x14(%ebp),%eax
  800659:	e8 d6 fc ff ff       	call   800334 <getint>
  80065e:	89 c3                	mov    %eax,%ebx
  800660:	89 d6                	mov    %edx,%esi
            if ((long long) num < 0) {
  800662:	85 d2                	test   %edx,%edx
  800664:	78 07                	js     80066d <vprintfmt+0x2d0>
                putch('-', putdat);
                num = -(long long) num;
            }
            base = 8;
  800666:	b8 08 00 00 00       	mov    $0x8,%eax
  80066b:	eb 5f                	jmp    8006cc <vprintfmt+0x32f>
		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
            if ((long long) num < 0) {
                putch('-', putdat);
  80066d:	83 ec 08             	sub    $0x8,%esp
  800670:	57                   	push   %edi
  800671:	6a 2d                	push   $0x2d
  800673:	ff 55 08             	call   *0x8(%ebp)
                num = -(long long) num;
  800676:	f7 db                	neg    %ebx
  800678:	83 d6 00             	adc    $0x0,%esi
  80067b:	f7 de                	neg    %esi
  80067d:	83 c4 10             	add    $0x10,%esp
            }
            base = 8;
  800680:	b8 08 00 00 00       	mov    $0x8,%eax
  800685:	eb 45                	jmp    8006cc <vprintfmt+0x32f>
  800687:	89 5d d8             	mov    %ebx,-0x28(%ebp)
            goto number;

        // pointer
		case 'p':
			putch('0', putdat);
  80068a:	83 ec 08             	sub    $0x8,%esp
  80068d:	57                   	push   %edi
  80068e:	6a 30                	push   $0x30
  800690:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800693:	83 c4 08             	add    $0x8,%esp
  800696:	57                   	push   %edi
  800697:	6a 78                	push   $0x78
  800699:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80069c:	8b 45 14             	mov    0x14(%ebp),%eax
  80069f:	8d 50 04             	lea    0x4(%eax),%edx
  8006a2:	89 55 14             	mov    %edx,0x14(%ebp)

        // pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8006a5:	8b 18                	mov    (%eax),%ebx
  8006a7:	be 00 00 00 00       	mov    $0x0,%esi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8006ac:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8006af:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8006b4:	eb 16                	jmp    8006cc <vprintfmt+0x32f>
  8006b6:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8006b9:	89 ca                	mov    %ecx,%edx
  8006bb:	8d 45 14             	lea    0x14(%ebp),%eax
  8006be:	e8 37 fc ff ff       	call   8002fa <getuint>
  8006c3:	89 c3                	mov    %eax,%ebx
  8006c5:	89 d6                	mov    %edx,%esi
			base = 16;
  8006c7:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006cc:	83 ec 0c             	sub    $0xc,%esp
  8006cf:	0f be 55 dc          	movsbl -0x24(%ebp),%edx
  8006d3:	52                   	push   %edx
  8006d4:	ff 75 e4             	pushl  -0x1c(%ebp)
  8006d7:	50                   	push   %eax
  8006d8:	56                   	push   %esi
  8006d9:	53                   	push   %ebx
  8006da:	89 fa                	mov    %edi,%edx
  8006dc:	8b 45 08             	mov    0x8(%ebp),%eax
  8006df:	e8 68 fb ff ff       	call   80024c <printnum>
			break;
  8006e4:	83 c4 20             	add    $0x20,%esp
  8006e7:	8b 75 d8             	mov    -0x28(%ebp),%esi
  8006ea:	e9 d2 fc ff ff       	jmp    8003c1 <vprintfmt+0x24>
  8006ef:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006f2:	83 ec 08             	sub    $0x8,%esp
  8006f5:	57                   	push   %edi
  8006f6:	52                   	push   %edx
  8006f7:	ff 55 08             	call   *0x8(%ebp)
			break;
  8006fa:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006fd:	8b 75 d8             	mov    -0x28(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800700:	e9 bc fc ff ff       	jmp    8003c1 <vprintfmt+0x24>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800705:	83 ec 08             	sub    $0x8,%esp
  800708:	57                   	push   %edi
  800709:	6a 25                	push   $0x25
  80070b:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  80070e:	83 c4 10             	add    $0x10,%esp
  800711:	eb 02                	jmp    800715 <vprintfmt+0x378>
  800713:	89 c6                	mov    %eax,%esi
  800715:	8d 46 ff             	lea    -0x1(%esi),%eax
  800718:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  80071c:	75 f5                	jne    800713 <vprintfmt+0x376>
  80071e:	e9 9e fc ff ff       	jmp    8003c1 <vprintfmt+0x24>
				/* do nothing */;
			break;
		}
	}
}
  800723:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800726:	5b                   	pop    %ebx
  800727:	5e                   	pop    %esi
  800728:	5f                   	pop    %edi
  800729:	c9                   	leave  
  80072a:	c3                   	ret    

0080072b <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80072b:	55                   	push   %ebp
  80072c:	89 e5                	mov    %esp,%ebp
  80072e:	83 ec 18             	sub    $0x18,%esp
  800731:	8b 45 08             	mov    0x8(%ebp),%eax
  800734:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800737:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80073a:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80073e:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800741:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800748:	85 c0                	test   %eax,%eax
  80074a:	74 26                	je     800772 <vsnprintf+0x47>
  80074c:	85 d2                	test   %edx,%edx
  80074e:	7e 29                	jle    800779 <vsnprintf+0x4e>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800750:	ff 75 14             	pushl  0x14(%ebp)
  800753:	ff 75 10             	pushl  0x10(%ebp)
  800756:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800759:	50                   	push   %eax
  80075a:	68 66 03 80 00       	push   $0x800366
  80075f:	e8 39 fc ff ff       	call   80039d <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800764:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800767:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80076a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80076d:	83 c4 10             	add    $0x10,%esp
  800770:	eb 0c                	jmp    80077e <vsnprintf+0x53>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800772:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800777:	eb 05                	jmp    80077e <vsnprintf+0x53>
  800779:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80077e:	c9                   	leave  
  80077f:	c3                   	ret    

00800780 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800780:	55                   	push   %ebp
  800781:	89 e5                	mov    %esp,%ebp
  800783:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800786:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800789:	50                   	push   %eax
  80078a:	ff 75 10             	pushl  0x10(%ebp)
  80078d:	ff 75 0c             	pushl  0xc(%ebp)
  800790:	ff 75 08             	pushl  0x8(%ebp)
  800793:	e8 93 ff ff ff       	call   80072b <vsnprintf>
	va_end(ap);

	return rc;
}
  800798:	c9                   	leave  
  800799:	c3                   	ret    
	...

0080079c <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80079c:	55                   	push   %ebp
  80079d:	89 e5                	mov    %esp,%ebp
  80079f:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007a2:	80 3a 00             	cmpb   $0x0,(%edx)
  8007a5:	74 0e                	je     8007b5 <strlen+0x19>
  8007a7:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  8007ac:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8007ad:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007b1:	75 f9                	jne    8007ac <strlen+0x10>
  8007b3:	eb 05                	jmp    8007ba <strlen+0x1e>
  8007b5:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  8007ba:	c9                   	leave  
  8007bb:	c3                   	ret    

008007bc <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007bc:	55                   	push   %ebp
  8007bd:	89 e5                	mov    %esp,%ebp
  8007bf:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007c2:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007c5:	85 d2                	test   %edx,%edx
  8007c7:	74 17                	je     8007e0 <strnlen+0x24>
  8007c9:	80 39 00             	cmpb   $0x0,(%ecx)
  8007cc:	74 19                	je     8007e7 <strnlen+0x2b>
  8007ce:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  8007d3:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007d4:	39 d0                	cmp    %edx,%eax
  8007d6:	74 14                	je     8007ec <strnlen+0x30>
  8007d8:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8007dc:	75 f5                	jne    8007d3 <strnlen+0x17>
  8007de:	eb 0c                	jmp    8007ec <strnlen+0x30>
  8007e0:	b8 00 00 00 00       	mov    $0x0,%eax
  8007e5:	eb 05                	jmp    8007ec <strnlen+0x30>
  8007e7:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  8007ec:	c9                   	leave  
  8007ed:	c3                   	ret    

008007ee <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007ee:	55                   	push   %ebp
  8007ef:	89 e5                	mov    %esp,%ebp
  8007f1:	53                   	push   %ebx
  8007f2:	8b 45 08             	mov    0x8(%ebp),%eax
  8007f5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007f8:	ba 00 00 00 00       	mov    $0x0,%edx
  8007fd:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  800800:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800803:	42                   	inc    %edx
  800804:	84 c9                	test   %cl,%cl
  800806:	75 f5                	jne    8007fd <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800808:	5b                   	pop    %ebx
  800809:	c9                   	leave  
  80080a:	c3                   	ret    

0080080b <strcat>:

char *
strcat(char *dst, const char *src)
{
  80080b:	55                   	push   %ebp
  80080c:	89 e5                	mov    %esp,%ebp
  80080e:	53                   	push   %ebx
  80080f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800812:	53                   	push   %ebx
  800813:	e8 84 ff ff ff       	call   80079c <strlen>
  800818:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  80081b:	ff 75 0c             	pushl  0xc(%ebp)
  80081e:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  800821:	50                   	push   %eax
  800822:	e8 c7 ff ff ff       	call   8007ee <strcpy>
	return dst;
}
  800827:	89 d8                	mov    %ebx,%eax
  800829:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80082c:	c9                   	leave  
  80082d:	c3                   	ret    

0080082e <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80082e:	55                   	push   %ebp
  80082f:	89 e5                	mov    %esp,%ebp
  800831:	56                   	push   %esi
  800832:	53                   	push   %ebx
  800833:	8b 45 08             	mov    0x8(%ebp),%eax
  800836:	8b 55 0c             	mov    0xc(%ebp),%edx
  800839:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80083c:	85 f6                	test   %esi,%esi
  80083e:	74 15                	je     800855 <strncpy+0x27>
  800840:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  800845:	8a 1a                	mov    (%edx),%bl
  800847:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80084a:	80 3a 01             	cmpb   $0x1,(%edx)
  80084d:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800850:	41                   	inc    %ecx
  800851:	39 ce                	cmp    %ecx,%esi
  800853:	77 f0                	ja     800845 <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800855:	5b                   	pop    %ebx
  800856:	5e                   	pop    %esi
  800857:	c9                   	leave  
  800858:	c3                   	ret    

00800859 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800859:	55                   	push   %ebp
  80085a:	89 e5                	mov    %esp,%ebp
  80085c:	57                   	push   %edi
  80085d:	56                   	push   %esi
  80085e:	53                   	push   %ebx
  80085f:	8b 7d 08             	mov    0x8(%ebp),%edi
  800862:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800865:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800868:	85 f6                	test   %esi,%esi
  80086a:	74 32                	je     80089e <strlcpy+0x45>
		while (--size > 0 && *src != '\0')
  80086c:	83 fe 01             	cmp    $0x1,%esi
  80086f:	74 22                	je     800893 <strlcpy+0x3a>
  800871:	8a 0b                	mov    (%ebx),%cl
  800873:	84 c9                	test   %cl,%cl
  800875:	74 20                	je     800897 <strlcpy+0x3e>
  800877:	89 f8                	mov    %edi,%eax
  800879:	ba 00 00 00 00       	mov    $0x0,%edx
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
  80087e:	83 ee 02             	sub    $0x2,%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800881:	88 08                	mov    %cl,(%eax)
  800883:	40                   	inc    %eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800884:	39 f2                	cmp    %esi,%edx
  800886:	74 11                	je     800899 <strlcpy+0x40>
  800888:	8a 4c 13 01          	mov    0x1(%ebx,%edx,1),%cl
  80088c:	42                   	inc    %edx
  80088d:	84 c9                	test   %cl,%cl
  80088f:	75 f0                	jne    800881 <strlcpy+0x28>
  800891:	eb 06                	jmp    800899 <strlcpy+0x40>
  800893:	89 f8                	mov    %edi,%eax
  800895:	eb 02                	jmp    800899 <strlcpy+0x40>
  800897:	89 f8                	mov    %edi,%eax
			*dst++ = *src++;
		*dst = '\0';
  800899:	c6 00 00             	movb   $0x0,(%eax)
  80089c:	eb 02                	jmp    8008a0 <strlcpy+0x47>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80089e:	89 f8                	mov    %edi,%eax
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
		*dst = '\0';
	}
	return dst - dst_in;
  8008a0:	29 f8                	sub    %edi,%eax
}
  8008a2:	5b                   	pop    %ebx
  8008a3:	5e                   	pop    %esi
  8008a4:	5f                   	pop    %edi
  8008a5:	c9                   	leave  
  8008a6:	c3                   	ret    

008008a7 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8008a7:	55                   	push   %ebp
  8008a8:	89 e5                	mov    %esp,%ebp
  8008aa:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008ad:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008b0:	8a 01                	mov    (%ecx),%al
  8008b2:	84 c0                	test   %al,%al
  8008b4:	74 10                	je     8008c6 <strcmp+0x1f>
  8008b6:	3a 02                	cmp    (%edx),%al
  8008b8:	75 0c                	jne    8008c6 <strcmp+0x1f>
		p++, q++;
  8008ba:	41                   	inc    %ecx
  8008bb:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8008bc:	8a 01                	mov    (%ecx),%al
  8008be:	84 c0                	test   %al,%al
  8008c0:	74 04                	je     8008c6 <strcmp+0x1f>
  8008c2:	3a 02                	cmp    (%edx),%al
  8008c4:	74 f4                	je     8008ba <strcmp+0x13>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008c6:	0f b6 c0             	movzbl %al,%eax
  8008c9:	0f b6 12             	movzbl (%edx),%edx
  8008cc:	29 d0                	sub    %edx,%eax
}
  8008ce:	c9                   	leave  
  8008cf:	c3                   	ret    

008008d0 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008d0:	55                   	push   %ebp
  8008d1:	89 e5                	mov    %esp,%ebp
  8008d3:	53                   	push   %ebx
  8008d4:	8b 55 08             	mov    0x8(%ebp),%edx
  8008d7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008da:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  8008dd:	85 c0                	test   %eax,%eax
  8008df:	74 1b                	je     8008fc <strncmp+0x2c>
  8008e1:	8a 1a                	mov    (%edx),%bl
  8008e3:	84 db                	test   %bl,%bl
  8008e5:	74 24                	je     80090b <strncmp+0x3b>
  8008e7:	3a 19                	cmp    (%ecx),%bl
  8008e9:	75 20                	jne    80090b <strncmp+0x3b>
  8008eb:	48                   	dec    %eax
  8008ec:	74 15                	je     800903 <strncmp+0x33>
		n--, p++, q++;
  8008ee:	42                   	inc    %edx
  8008ef:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8008f0:	8a 1a                	mov    (%edx),%bl
  8008f2:	84 db                	test   %bl,%bl
  8008f4:	74 15                	je     80090b <strncmp+0x3b>
  8008f6:	3a 19                	cmp    (%ecx),%bl
  8008f8:	74 f1                	je     8008eb <strncmp+0x1b>
  8008fa:	eb 0f                	jmp    80090b <strncmp+0x3b>
		n--, p++, q++;
	if (n == 0)
		return 0;
  8008fc:	b8 00 00 00 00       	mov    $0x0,%eax
  800901:	eb 05                	jmp    800908 <strncmp+0x38>
  800903:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800908:	5b                   	pop    %ebx
  800909:	c9                   	leave  
  80090a:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80090b:	0f b6 02             	movzbl (%edx),%eax
  80090e:	0f b6 11             	movzbl (%ecx),%edx
  800911:	29 d0                	sub    %edx,%eax
  800913:	eb f3                	jmp    800908 <strncmp+0x38>

00800915 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800915:	55                   	push   %ebp
  800916:	89 e5                	mov    %esp,%ebp
  800918:	8b 45 08             	mov    0x8(%ebp),%eax
  80091b:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  80091e:	8a 10                	mov    (%eax),%dl
  800920:	84 d2                	test   %dl,%dl
  800922:	74 18                	je     80093c <strchr+0x27>
		if (*s == c)
  800924:	38 ca                	cmp    %cl,%dl
  800926:	75 06                	jne    80092e <strchr+0x19>
  800928:	eb 17                	jmp    800941 <strchr+0x2c>
  80092a:	38 ca                	cmp    %cl,%dl
  80092c:	74 13                	je     800941 <strchr+0x2c>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80092e:	40                   	inc    %eax
  80092f:	8a 10                	mov    (%eax),%dl
  800931:	84 d2                	test   %dl,%dl
  800933:	75 f5                	jne    80092a <strchr+0x15>
		if (*s == c)
			return (char *) s;
	return 0;
  800935:	b8 00 00 00 00       	mov    $0x0,%eax
  80093a:	eb 05                	jmp    800941 <strchr+0x2c>
  80093c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800941:	c9                   	leave  
  800942:	c3                   	ret    

00800943 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800943:	55                   	push   %ebp
  800944:	89 e5                	mov    %esp,%ebp
  800946:	8b 45 08             	mov    0x8(%ebp),%eax
  800949:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  80094c:	8a 10                	mov    (%eax),%dl
  80094e:	84 d2                	test   %dl,%dl
  800950:	74 11                	je     800963 <strfind+0x20>
		if (*s == c)
  800952:	38 ca                	cmp    %cl,%dl
  800954:	75 06                	jne    80095c <strfind+0x19>
  800956:	eb 0b                	jmp    800963 <strfind+0x20>
  800958:	38 ca                	cmp    %cl,%dl
  80095a:	74 07                	je     800963 <strfind+0x20>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  80095c:	40                   	inc    %eax
  80095d:	8a 10                	mov    (%eax),%dl
  80095f:	84 d2                	test   %dl,%dl
  800961:	75 f5                	jne    800958 <strfind+0x15>
		if (*s == c)
			break;
	return (char *) s;
}
  800963:	c9                   	leave  
  800964:	c3                   	ret    

00800965 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800965:	55                   	push   %ebp
  800966:	89 e5                	mov    %esp,%ebp
  800968:	57                   	push   %edi
  800969:	56                   	push   %esi
  80096a:	53                   	push   %ebx
  80096b:	8b 7d 08             	mov    0x8(%ebp),%edi
  80096e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800971:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800974:	85 c9                	test   %ecx,%ecx
  800976:	74 30                	je     8009a8 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800978:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80097e:	75 25                	jne    8009a5 <memset+0x40>
  800980:	f6 c1 03             	test   $0x3,%cl
  800983:	75 20                	jne    8009a5 <memset+0x40>
		c &= 0xFF;
  800985:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800988:	89 d3                	mov    %edx,%ebx
  80098a:	c1 e3 08             	shl    $0x8,%ebx
  80098d:	89 d6                	mov    %edx,%esi
  80098f:	c1 e6 18             	shl    $0x18,%esi
  800992:	89 d0                	mov    %edx,%eax
  800994:	c1 e0 10             	shl    $0x10,%eax
  800997:	09 f0                	or     %esi,%eax
  800999:	09 d0                	or     %edx,%eax
  80099b:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  80099d:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  8009a0:	fc                   	cld    
  8009a1:	f3 ab                	rep stos %eax,%es:(%edi)
  8009a3:	eb 03                	jmp    8009a8 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8009a5:	fc                   	cld    
  8009a6:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8009a8:	89 f8                	mov    %edi,%eax
  8009aa:	5b                   	pop    %ebx
  8009ab:	5e                   	pop    %esi
  8009ac:	5f                   	pop    %edi
  8009ad:	c9                   	leave  
  8009ae:	c3                   	ret    

008009af <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8009af:	55                   	push   %ebp
  8009b0:	89 e5                	mov    %esp,%ebp
  8009b2:	57                   	push   %edi
  8009b3:	56                   	push   %esi
  8009b4:	8b 45 08             	mov    0x8(%ebp),%eax
  8009b7:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009ba:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8009bd:	39 c6                	cmp    %eax,%esi
  8009bf:	73 34                	jae    8009f5 <memmove+0x46>
  8009c1:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8009c4:	39 d0                	cmp    %edx,%eax
  8009c6:	73 2d                	jae    8009f5 <memmove+0x46>
		s += n;
		d += n;
  8009c8:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009cb:	f6 c2 03             	test   $0x3,%dl
  8009ce:	75 1b                	jne    8009eb <memmove+0x3c>
  8009d0:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8009d6:	75 13                	jne    8009eb <memmove+0x3c>
  8009d8:	f6 c1 03             	test   $0x3,%cl
  8009db:	75 0e                	jne    8009eb <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8009dd:	83 ef 04             	sub    $0x4,%edi
  8009e0:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009e3:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  8009e6:	fd                   	std    
  8009e7:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009e9:	eb 07                	jmp    8009f2 <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8009eb:	4f                   	dec    %edi
  8009ec:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8009ef:	fd                   	std    
  8009f0:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009f2:	fc                   	cld    
  8009f3:	eb 20                	jmp    800a15 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009f5:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009fb:	75 13                	jne    800a10 <memmove+0x61>
  8009fd:	a8 03                	test   $0x3,%al
  8009ff:	75 0f                	jne    800a10 <memmove+0x61>
  800a01:	f6 c1 03             	test   $0x3,%cl
  800a04:	75 0a                	jne    800a10 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800a06:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800a09:	89 c7                	mov    %eax,%edi
  800a0b:	fc                   	cld    
  800a0c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a0e:	eb 05                	jmp    800a15 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a10:	89 c7                	mov    %eax,%edi
  800a12:	fc                   	cld    
  800a13:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a15:	5e                   	pop    %esi
  800a16:	5f                   	pop    %edi
  800a17:	c9                   	leave  
  800a18:	c3                   	ret    

00800a19 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a19:	55                   	push   %ebp
  800a1a:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800a1c:	ff 75 10             	pushl  0x10(%ebp)
  800a1f:	ff 75 0c             	pushl  0xc(%ebp)
  800a22:	ff 75 08             	pushl  0x8(%ebp)
  800a25:	e8 85 ff ff ff       	call   8009af <memmove>
}
  800a2a:	c9                   	leave  
  800a2b:	c3                   	ret    

00800a2c <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a2c:	55                   	push   %ebp
  800a2d:	89 e5                	mov    %esp,%ebp
  800a2f:	57                   	push   %edi
  800a30:	56                   	push   %esi
  800a31:	53                   	push   %ebx
  800a32:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800a35:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a38:	8b 7d 10             	mov    0x10(%ebp),%edi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a3b:	85 ff                	test   %edi,%edi
  800a3d:	74 32                	je     800a71 <memcmp+0x45>
		if (*s1 != *s2)
  800a3f:	8a 03                	mov    (%ebx),%al
  800a41:	8a 0e                	mov    (%esi),%cl
  800a43:	38 c8                	cmp    %cl,%al
  800a45:	74 19                	je     800a60 <memcmp+0x34>
  800a47:	eb 0d                	jmp    800a56 <memcmp+0x2a>
  800a49:	8a 44 13 01          	mov    0x1(%ebx,%edx,1),%al
  800a4d:	8a 4c 16 01          	mov    0x1(%esi,%edx,1),%cl
  800a51:	42                   	inc    %edx
  800a52:	38 c8                	cmp    %cl,%al
  800a54:	74 10                	je     800a66 <memcmp+0x3a>
			return (int) *s1 - (int) *s2;
  800a56:	0f b6 c0             	movzbl %al,%eax
  800a59:	0f b6 c9             	movzbl %cl,%ecx
  800a5c:	29 c8                	sub    %ecx,%eax
  800a5e:	eb 16                	jmp    800a76 <memcmp+0x4a>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a60:	4f                   	dec    %edi
  800a61:	ba 00 00 00 00       	mov    $0x0,%edx
  800a66:	39 fa                	cmp    %edi,%edx
  800a68:	75 df                	jne    800a49 <memcmp+0x1d>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a6a:	b8 00 00 00 00       	mov    $0x0,%eax
  800a6f:	eb 05                	jmp    800a76 <memcmp+0x4a>
  800a71:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a76:	5b                   	pop    %ebx
  800a77:	5e                   	pop    %esi
  800a78:	5f                   	pop    %edi
  800a79:	c9                   	leave  
  800a7a:	c3                   	ret    

00800a7b <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a7b:	55                   	push   %ebp
  800a7c:	89 e5                	mov    %esp,%ebp
  800a7e:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800a81:	89 c2                	mov    %eax,%edx
  800a83:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a86:	39 d0                	cmp    %edx,%eax
  800a88:	73 12                	jae    800a9c <memfind+0x21>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a8a:	8a 4d 0c             	mov    0xc(%ebp),%cl
  800a8d:	38 08                	cmp    %cl,(%eax)
  800a8f:	75 06                	jne    800a97 <memfind+0x1c>
  800a91:	eb 09                	jmp    800a9c <memfind+0x21>
  800a93:	38 08                	cmp    %cl,(%eax)
  800a95:	74 05                	je     800a9c <memfind+0x21>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a97:	40                   	inc    %eax
  800a98:	39 c2                	cmp    %eax,%edx
  800a9a:	77 f7                	ja     800a93 <memfind+0x18>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a9c:	c9                   	leave  
  800a9d:	c3                   	ret    

00800a9e <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a9e:	55                   	push   %ebp
  800a9f:	89 e5                	mov    %esp,%ebp
  800aa1:	57                   	push   %edi
  800aa2:	56                   	push   %esi
  800aa3:	53                   	push   %ebx
  800aa4:	8b 55 08             	mov    0x8(%ebp),%edx
  800aa7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800aaa:	eb 01                	jmp    800aad <strtol+0xf>
		s++;
  800aac:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800aad:	8a 02                	mov    (%edx),%al
  800aaf:	3c 20                	cmp    $0x20,%al
  800ab1:	74 f9                	je     800aac <strtol+0xe>
  800ab3:	3c 09                	cmp    $0x9,%al
  800ab5:	74 f5                	je     800aac <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800ab7:	3c 2b                	cmp    $0x2b,%al
  800ab9:	75 08                	jne    800ac3 <strtol+0x25>
		s++;
  800abb:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800abc:	bf 00 00 00 00       	mov    $0x0,%edi
  800ac1:	eb 13                	jmp    800ad6 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800ac3:	3c 2d                	cmp    $0x2d,%al
  800ac5:	75 0a                	jne    800ad1 <strtol+0x33>
		s++, neg = 1;
  800ac7:	8d 52 01             	lea    0x1(%edx),%edx
  800aca:	bf 01 00 00 00       	mov    $0x1,%edi
  800acf:	eb 05                	jmp    800ad6 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800ad1:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800ad6:	85 db                	test   %ebx,%ebx
  800ad8:	74 05                	je     800adf <strtol+0x41>
  800ada:	83 fb 10             	cmp    $0x10,%ebx
  800add:	75 28                	jne    800b07 <strtol+0x69>
  800adf:	8a 02                	mov    (%edx),%al
  800ae1:	3c 30                	cmp    $0x30,%al
  800ae3:	75 10                	jne    800af5 <strtol+0x57>
  800ae5:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800ae9:	75 0a                	jne    800af5 <strtol+0x57>
		s += 2, base = 16;
  800aeb:	83 c2 02             	add    $0x2,%edx
  800aee:	bb 10 00 00 00       	mov    $0x10,%ebx
  800af3:	eb 12                	jmp    800b07 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800af5:	85 db                	test   %ebx,%ebx
  800af7:	75 0e                	jne    800b07 <strtol+0x69>
  800af9:	3c 30                	cmp    $0x30,%al
  800afb:	75 05                	jne    800b02 <strtol+0x64>
		s++, base = 8;
  800afd:	42                   	inc    %edx
  800afe:	b3 08                	mov    $0x8,%bl
  800b00:	eb 05                	jmp    800b07 <strtol+0x69>
	else if (base == 0)
		base = 10;
  800b02:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800b07:	b8 00 00 00 00       	mov    $0x0,%eax
  800b0c:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800b0e:	8a 0a                	mov    (%edx),%cl
  800b10:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800b13:	80 fb 09             	cmp    $0x9,%bl
  800b16:	77 08                	ja     800b20 <strtol+0x82>
			dig = *s - '0';
  800b18:	0f be c9             	movsbl %cl,%ecx
  800b1b:	83 e9 30             	sub    $0x30,%ecx
  800b1e:	eb 1e                	jmp    800b3e <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800b20:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800b23:	80 fb 19             	cmp    $0x19,%bl
  800b26:	77 08                	ja     800b30 <strtol+0x92>
			dig = *s - 'a' + 10;
  800b28:	0f be c9             	movsbl %cl,%ecx
  800b2b:	83 e9 57             	sub    $0x57,%ecx
  800b2e:	eb 0e                	jmp    800b3e <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800b30:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800b33:	80 fb 19             	cmp    $0x19,%bl
  800b36:	77 13                	ja     800b4b <strtol+0xad>
			dig = *s - 'A' + 10;
  800b38:	0f be c9             	movsbl %cl,%ecx
  800b3b:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800b3e:	39 f1                	cmp    %esi,%ecx
  800b40:	7d 0d                	jge    800b4f <strtol+0xb1>
			break;
		s++, val = (val * base) + dig;
  800b42:	42                   	inc    %edx
  800b43:	0f af c6             	imul   %esi,%eax
  800b46:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  800b49:	eb c3                	jmp    800b0e <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800b4b:	89 c1                	mov    %eax,%ecx
  800b4d:	eb 02                	jmp    800b51 <strtol+0xb3>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800b4f:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800b51:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b55:	74 05                	je     800b5c <strtol+0xbe>
		*endptr = (char *) s;
  800b57:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800b5a:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800b5c:	85 ff                	test   %edi,%edi
  800b5e:	74 04                	je     800b64 <strtol+0xc6>
  800b60:	89 c8                	mov    %ecx,%eax
  800b62:	f7 d8                	neg    %eax
}
  800b64:	5b                   	pop    %ebx
  800b65:	5e                   	pop    %esi
  800b66:	5f                   	pop    %edi
  800b67:	c9                   	leave  
  800b68:	c3                   	ret    
  800b69:	00 00                	add    %al,(%eax)
	...

00800b6c <syscall>:
	return ret;
}

static int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800b6c:	55                   	push   %ebp
  800b6d:	89 e5                	mov    %esp,%ebp
  800b6f:	57                   	push   %edi
  800b70:	56                   	push   %esi
  800b71:	53                   	push   %ebx
  800b72:	83 ec 1c             	sub    $0x1c,%esp
  800b75:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800b78:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800b7b:	89 ca                	mov    %ecx,%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b7d:	8b 75 14             	mov    0x14(%ebp),%esi
  800b80:	8b 7d 10             	mov    0x10(%ebp),%edi
  800b83:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800b86:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b89:	cd 30                	int    $0x30
  800b8b:	89 c2                	mov    %eax,%edx
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b8d:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800b91:	74 1c                	je     800baf <syscall+0x43>
  800b93:	85 c0                	test   %eax,%eax
  800b95:	7e 18                	jle    800baf <syscall+0x43>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b97:	83 ec 0c             	sub    $0xc,%esp
  800b9a:	50                   	push   %eax
  800b9b:	ff 75 e4             	pushl  -0x1c(%ebp)
  800b9e:	68 7f 25 80 00       	push   $0x80257f
  800ba3:	6a 42                	push   $0x42
  800ba5:	68 9c 25 80 00       	push   $0x80259c
  800baa:	e8 b1 f5 ff ff       	call   800160 <_panic>

	return ret;
}
  800baf:	89 d0                	mov    %edx,%eax
  800bb1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bb4:	5b                   	pop    %ebx
  800bb5:	5e                   	pop    %esi
  800bb6:	5f                   	pop    %edi
  800bb7:	c9                   	leave  
  800bb8:	c3                   	ret    

00800bb9 <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{	
  800bb9:	55                   	push   %ebp
  800bba:	89 e5                	mov    %esp,%ebp
  800bbc:	83 ec 08             	sub    $0x8,%esp
	// my_sysenter(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
	// return;
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  800bbf:	6a 00                	push   $0x0
  800bc1:	6a 00                	push   $0x0
  800bc3:	6a 00                	push   $0x0
  800bc5:	ff 75 0c             	pushl  0xc(%ebp)
  800bc8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800bcb:	ba 00 00 00 00       	mov    $0x0,%edx
  800bd0:	b8 00 00 00 00       	mov    $0x0,%eax
  800bd5:	e8 92 ff ff ff       	call   800b6c <syscall>
  800bda:	83 c4 10             	add    $0x10,%esp
	return;
}
  800bdd:	c9                   	leave  
  800bde:	c3                   	ret    

00800bdf <sys_cgetc>:

int
sys_cgetc(void)
{
  800bdf:	55                   	push   %ebp
  800be0:	89 e5                	mov    %esp,%ebp
  800be2:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_cgetc, 0, 0, 0, 0, 0, 0);
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  800be5:	6a 00                	push   $0x0
  800be7:	6a 00                	push   $0x0
  800be9:	6a 00                	push   $0x0
  800beb:	6a 00                	push   $0x0
  800bed:	b9 00 00 00 00       	mov    $0x0,%ecx
  800bf2:	ba 00 00 00 00       	mov    $0x0,%edx
  800bf7:	b8 01 00 00 00       	mov    $0x1,%eax
  800bfc:	e8 6b ff ff ff       	call   800b6c <syscall>
}
  800c01:	c9                   	leave  
  800c02:	c3                   	ret    

00800c03 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800c03:	55                   	push   %ebp
  800c04:	89 e5                	mov    %esp,%ebp
  800c06:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  800c09:	6a 00                	push   $0x0
  800c0b:	6a 00                	push   $0x0
  800c0d:	6a 00                	push   $0x0
  800c0f:	6a 00                	push   $0x0
  800c11:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c14:	ba 01 00 00 00       	mov    $0x1,%edx
  800c19:	b8 03 00 00 00       	mov    $0x3,%eax
  800c1e:	e8 49 ff ff ff       	call   800b6c <syscall>
}
  800c23:	c9                   	leave  
  800c24:	c3                   	ret    

00800c25 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c25:	55                   	push   %ebp
  800c26:	89 e5                	mov    %esp,%ebp
  800c28:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_getenvid, 0, 0, 0, 0, 0, 0);
	return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  800c2b:	6a 00                	push   $0x0
  800c2d:	6a 00                	push   $0x0
  800c2f:	6a 00                	push   $0x0
  800c31:	6a 00                	push   $0x0
  800c33:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c38:	ba 00 00 00 00       	mov    $0x0,%edx
  800c3d:	b8 02 00 00 00       	mov    $0x2,%eax
  800c42:	e8 25 ff ff ff       	call   800b6c <syscall>
}
  800c47:	c9                   	leave  
  800c48:	c3                   	ret    

00800c49 <sys_yield>:

void
sys_yield(void)
{
  800c49:	55                   	push   %ebp
  800c4a:	89 e5                	mov    %esp,%ebp
  800c4c:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  800c4f:	6a 00                	push   $0x0
  800c51:	6a 00                	push   $0x0
  800c53:	6a 00                	push   $0x0
  800c55:	6a 00                	push   $0x0
  800c57:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c5c:	ba 00 00 00 00       	mov    $0x0,%edx
  800c61:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c66:	e8 01 ff ff ff       	call   800b6c <syscall>
  800c6b:	83 c4 10             	add    $0x10,%esp
}
  800c6e:	c9                   	leave  
  800c6f:	c3                   	ret    

00800c70 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c70:	55                   	push   %ebp
  800c71:	89 e5                	mov    %esp,%ebp
  800c73:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  800c76:	6a 00                	push   $0x0
  800c78:	6a 00                	push   $0x0
  800c7a:	ff 75 10             	pushl  0x10(%ebp)
  800c7d:	ff 75 0c             	pushl  0xc(%ebp)
  800c80:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c83:	ba 01 00 00 00       	mov    $0x1,%edx
  800c88:	b8 04 00 00 00       	mov    $0x4,%eax
  800c8d:	e8 da fe ff ff       	call   800b6c <syscall>
}
  800c92:	c9                   	leave  
  800c93:	c3                   	ret    

00800c94 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c94:	55                   	push   %ebp
  800c95:	89 e5                	mov    %esp,%ebp
  800c97:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
  800c9a:	ff 75 18             	pushl  0x18(%ebp)
  800c9d:	ff 75 14             	pushl  0x14(%ebp)
  800ca0:	ff 75 10             	pushl  0x10(%ebp)
  800ca3:	ff 75 0c             	pushl  0xc(%ebp)
  800ca6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ca9:	ba 01 00 00 00       	mov    $0x1,%edx
  800cae:	b8 05 00 00 00       	mov    $0x5,%eax
  800cb3:	e8 b4 fe ff ff       	call   800b6c <syscall>
}
  800cb8:	c9                   	leave  
  800cb9:	c3                   	ret    

00800cba <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800cba:	55                   	push   %ebp
  800cbb:	89 e5                	mov    %esp,%ebp
  800cbd:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  800cc0:	6a 00                	push   $0x0
  800cc2:	6a 00                	push   $0x0
  800cc4:	6a 00                	push   $0x0
  800cc6:	ff 75 0c             	pushl  0xc(%ebp)
  800cc9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ccc:	ba 01 00 00 00       	mov    $0x1,%edx
  800cd1:	b8 06 00 00 00       	mov    $0x6,%eax
  800cd6:	e8 91 fe ff ff       	call   800b6c <syscall>
}
  800cdb:	c9                   	leave  
  800cdc:	c3                   	ret    

00800cdd <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800cdd:	55                   	push   %ebp
  800cde:	89 e5                	mov    %esp,%ebp
  800ce0:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  800ce3:	6a 00                	push   $0x0
  800ce5:	6a 00                	push   $0x0
  800ce7:	6a 00                	push   $0x0
  800ce9:	ff 75 0c             	pushl  0xc(%ebp)
  800cec:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800cef:	ba 01 00 00 00       	mov    $0x1,%edx
  800cf4:	b8 08 00 00 00       	mov    $0x8,%eax
  800cf9:	e8 6e fe ff ff       	call   800b6c <syscall>
}
  800cfe:	c9                   	leave  
  800cff:	c3                   	ret    

00800d00 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800d00:	55                   	push   %ebp
  800d01:	89 e5                	mov    %esp,%ebp
  800d03:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
  800d06:	6a 00                	push   $0x0
  800d08:	6a 00                	push   $0x0
  800d0a:	6a 00                	push   $0x0
  800d0c:	ff 75 0c             	pushl  0xc(%ebp)
  800d0f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d12:	ba 01 00 00 00       	mov    $0x1,%edx
  800d17:	b8 09 00 00 00       	mov    $0x9,%eax
  800d1c:	e8 4b fe ff ff       	call   800b6c <syscall>
}
  800d21:	c9                   	leave  
  800d22:	c3                   	ret    

00800d23 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d23:	55                   	push   %ebp
  800d24:	89 e5                	mov    %esp,%ebp
  800d26:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  800d29:	6a 00                	push   $0x0
  800d2b:	6a 00                	push   $0x0
  800d2d:	6a 00                	push   $0x0
  800d2f:	ff 75 0c             	pushl  0xc(%ebp)
  800d32:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d35:	ba 01 00 00 00       	mov    $0x1,%edx
  800d3a:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d3f:	e8 28 fe ff ff       	call   800b6c <syscall>
}
  800d44:	c9                   	leave  
  800d45:	c3                   	ret    

00800d46 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d46:	55                   	push   %ebp
  800d47:	89 e5                	mov    %esp,%ebp
  800d49:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  800d4c:	6a 00                	push   $0x0
  800d4e:	ff 75 14             	pushl  0x14(%ebp)
  800d51:	ff 75 10             	pushl  0x10(%ebp)
  800d54:	ff 75 0c             	pushl  0xc(%ebp)
  800d57:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d5a:	ba 00 00 00 00       	mov    $0x0,%edx
  800d5f:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d64:	e8 03 fe ff ff       	call   800b6c <syscall>
}
  800d69:	c9                   	leave  
  800d6a:	c3                   	ret    

00800d6b <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d6b:	55                   	push   %ebp
  800d6c:	89 e5                	mov    %esp,%ebp
  800d6e:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  800d71:	6a 00                	push   $0x0
  800d73:	6a 00                	push   $0x0
  800d75:	6a 00                	push   $0x0
  800d77:	6a 00                	push   $0x0
  800d79:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d7c:	ba 01 00 00 00       	mov    $0x1,%edx
  800d81:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d86:	e8 e1 fd ff ff       	call   800b6c <syscall>
}
  800d8b:	c9                   	leave  
  800d8c:	c3                   	ret    

00800d8d <sys_set_priority>:

int
sys_set_priority(envid_t envid, uint32_t new_priority)
{
  800d8d:	55                   	push   %ebp
  800d8e:	89 e5                	mov    %esp,%ebp
  800d90:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_set_priority, 0, envid, new_priority, 0, 0, 0);
  800d93:	6a 00                	push   $0x0
  800d95:	6a 00                	push   $0x0
  800d97:	6a 00                	push   $0x0
  800d99:	ff 75 0c             	pushl  0xc(%ebp)
  800d9c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d9f:	ba 00 00 00 00       	mov    $0x0,%edx
  800da4:	b8 0e 00 00 00       	mov    $0xe,%eax
  800da9:	e8 be fd ff ff       	call   800b6c <syscall>
}
  800dae:	c9                   	leave  
  800daf:	c3                   	ret    

00800db0 <sys_exec>:

int
sys_exec(uint32_t eip, uint32_t esp, void * ph, uint32_t elf_phnum)
{
  800db0:	55                   	push   %ebp
  800db1:	89 e5                	mov    %esp,%ebp
  800db3:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_exec, 0, eip, esp, (uint32_t)ph, elf_phnum, 0);
  800db6:	6a 00                	push   $0x0
  800db8:	ff 75 14             	pushl  0x14(%ebp)
  800dbb:	ff 75 10             	pushl  0x10(%ebp)
  800dbe:	ff 75 0c             	pushl  0xc(%ebp)
  800dc1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800dc4:	ba 00 00 00 00       	mov    $0x0,%edx
  800dc9:	b8 0f 00 00 00       	mov    $0xf,%eax
  800dce:	e8 99 fd ff ff       	call   800b6c <syscall>
} 
  800dd3:	c9                   	leave  
  800dd4:	c3                   	ret    

00800dd5 <sys_join>:

// thread:
int
sys_join(envid_t envid)
{
  800dd5:	55                   	push   %ebp
  800dd6:	89 e5                	mov    %esp,%ebp
  800dd8:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_join, 0, envid, 0, 0, 0, 0);
  800ddb:	6a 00                	push   $0x0
  800ddd:	6a 00                	push   $0x0
  800ddf:	6a 00                	push   $0x0
  800de1:	6a 00                	push   $0x0
  800de3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800de6:	ba 00 00 00 00       	mov    $0x0,%edx
  800deb:	b8 11 00 00 00       	mov    $0x11,%eax
  800df0:	e8 77 fd ff ff       	call   800b6c <syscall>
}
  800df5:	c9                   	leave  
  800df6:	c3                   	ret    

00800df7 <sys_getpid>:

envid_t
sys_getpid(void)
{
  800df7:	55                   	push   %ebp
  800df8:	89 e5                	mov    %esp,%ebp
  800dfa:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_getpid, 0, 0, 0, 0, 0, 0);
  800dfd:	6a 00                	push   $0x0
  800dff:	6a 00                	push   $0x0
  800e01:	6a 00                	push   $0x0
  800e03:	6a 00                	push   $0x0
  800e05:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e0a:	ba 00 00 00 00       	mov    $0x0,%edx
  800e0f:	b8 10 00 00 00       	mov    $0x10,%eax
  800e14:	e8 53 fd ff ff       	call   800b6c <syscall>
  800e19:	c9                   	leave  
  800e1a:	c3                   	ret    
	...

00800e1c <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800e1c:	55                   	push   %ebp
  800e1d:	89 e5                	mov    %esp,%ebp
  800e1f:	53                   	push   %ebx
  800e20:	83 ec 04             	sub    $0x4,%esp
  800e23:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800e26:	8b 18                	mov    (%eax),%ebx

	// LAB 4: Your code here.
	
	// cprintf("PAGE FAULT HANDLER, 0x%08x %d\n", (uint32_t)addr, err & FEC_WR);
	
	if ((err & FEC_WR) == 0)
  800e28:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800e2c:	75 14                	jne    800e42 <pgfault+0x26>
		panic("pgfault, the fault is not a write\n");
  800e2e:	83 ec 04             	sub    $0x4,%esp
  800e31:	68 ac 25 80 00       	push   $0x8025ac
  800e36:	6a 20                	push   $0x20
  800e38:	68 f0 26 80 00       	push   $0x8026f0
  800e3d:	e8 1e f3 ff ff       	call   800160 <_panic>

	uint32_t uaddr = (uint32_t) addr;
	if ((uvpd[PDX(addr)] & PTE_P) == 0 || (uvpt[uaddr / PGSIZE] & PTE_COW) == 0) {
  800e42:	89 d8                	mov    %ebx,%eax
  800e44:	c1 e8 16             	shr    $0x16,%eax
  800e47:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800e4e:	a8 01                	test   $0x1,%al
  800e50:	74 11                	je     800e63 <pgfault+0x47>
  800e52:	89 d8                	mov    %ebx,%eax
  800e54:	c1 e8 0c             	shr    $0xc,%eax
  800e57:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800e5e:	f6 c4 08             	test   $0x8,%ah
  800e61:	75 14                	jne    800e77 <pgfault+0x5b>
		panic("pgfault, not a copy-on-write page\n");
  800e63:	83 ec 04             	sub    $0x4,%esp
  800e66:	68 d0 25 80 00       	push   $0x8025d0
  800e6b:	6a 24                	push   $0x24
  800e6d:	68 f0 26 80 00       	push   $0x8026f0
  800e72:	e8 e9 f2 ff ff       	call   800160 <_panic>
	//   No need to explicitly delete the old page's mapping.

	// LAB 4: Your code here.

	// static int sys_page_alloc(envid_t envid, void *va, int perm)
	r = sys_page_alloc(0, (void *)PFTEMP, PTE_W | PTE_U | PTE_P);
  800e77:	83 ec 04             	sub    $0x4,%esp
  800e7a:	6a 07                	push   $0x7
  800e7c:	68 00 f0 7f 00       	push   $0x7ff000
  800e81:	6a 00                	push   $0x0
  800e83:	e8 e8 fd ff ff       	call   800c70 <sys_page_alloc>
	if (r < 0) panic("pgfault, sys_page_alloc error : %e\n", r);
  800e88:	83 c4 10             	add    $0x10,%esp
  800e8b:	85 c0                	test   %eax,%eax
  800e8d:	79 12                	jns    800ea1 <pgfault+0x85>
  800e8f:	50                   	push   %eax
  800e90:	68 f4 25 80 00       	push   $0x8025f4
  800e95:	6a 32                	push   $0x32
  800e97:	68 f0 26 80 00       	push   $0x8026f0
  800e9c:	e8 bf f2 ff ff       	call   800160 <_panic>

	// Oh my god, I forget this at the first, it waste me a lot of time to debug!!!
	addr = ROUNDDOWN(addr, PGSIZE);
  800ea1:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	
	memcpy(PFTEMP, addr, PGSIZE);
  800ea7:	83 ec 04             	sub    $0x4,%esp
  800eaa:	68 00 10 00 00       	push   $0x1000
  800eaf:	53                   	push   %ebx
  800eb0:	68 00 f0 7f 00       	push   $0x7ff000
  800eb5:	e8 5f fb ff ff       	call   800a19 <memcpy>
	
	r = sys_page_map(0, PFTEMP, 0, addr, PTE_W | PTE_U | PTE_P);
  800eba:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800ec1:	53                   	push   %ebx
  800ec2:	6a 00                	push   $0x0
  800ec4:	68 00 f0 7f 00       	push   $0x7ff000
  800ec9:	6a 00                	push   $0x0
  800ecb:	e8 c4 fd ff ff       	call   800c94 <sys_page_map>
	if (r < 0) panic("pgfault, sys_page_map error : %e\n", r);
  800ed0:	83 c4 20             	add    $0x20,%esp
  800ed3:	85 c0                	test   %eax,%eax
  800ed5:	79 12                	jns    800ee9 <pgfault+0xcd>
  800ed7:	50                   	push   %eax
  800ed8:	68 18 26 80 00       	push   $0x802618
  800edd:	6a 3a                	push   $0x3a
  800edf:	68 f0 26 80 00       	push   $0x8026f0
  800ee4:	e8 77 f2 ff ff       	call   800160 <_panic>

	return;
}
  800ee9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800eec:	c9                   	leave  
  800eed:	c3                   	ret    

00800eee <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800eee:	55                   	push   %ebp
  800eef:	89 e5                	mov    %esp,%ebp
  800ef1:	57                   	push   %edi
  800ef2:	56                   	push   %esi
  800ef3:	53                   	push   %ebx
  800ef4:	83 ec 28             	sub    $0x28,%esp
	// static int num = 0x100;

	// LAB 4: Your code here.
	set_pgfault_handler(pgfault);
  800ef7:	68 1c 0e 80 00       	push   $0x800e1c
  800efc:	e8 ff 0f 00 00       	call   801f00 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  800f01:	ba 07 00 00 00       	mov    $0x7,%edx
  800f06:	89 d0                	mov    %edx,%eax
  800f08:	cd 30                	int    $0x30
  800f0a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800f0d:	89 c7                	mov    %eax,%edi
	int childpid = sys_exofork();
	if (childpid < 0) {
  800f0f:	83 c4 10             	add    $0x10,%esp
  800f12:	85 c0                	test   %eax,%eax
  800f14:	79 12                	jns    800f28 <fork+0x3a>
		panic("fork sys_exofork error : %e\n", childpid);
  800f16:	50                   	push   %eax
  800f17:	68 fb 26 80 00       	push   $0x8026fb
  800f1c:	6a 7f                	push   $0x7f
  800f1e:	68 f0 26 80 00       	push   $0x8026f0
  800f23:	e8 38 f2 ff ff       	call   800160 <_panic>
	}
	int r;

	if (childpid == 0) {
  800f28:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800f2c:	75 20                	jne    800f4e <fork+0x60>
		// child process
		// Remember to fix "thisenv" in the child process. ??? 
		thisenv = &envs[ENVX(sys_getenvid())];
  800f2e:	e8 f2 fc ff ff       	call   800c25 <sys_getenvid>
  800f33:	25 ff 03 00 00       	and    $0x3ff,%eax
  800f38:	89 c2                	mov    %eax,%edx
  800f3a:	c1 e2 07             	shl    $0x7,%edx
  800f3d:	8d 84 82 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,4),%eax
  800f44:	a3 04 40 80 00       	mov    %eax,0x804004
		// cprintf("fork child ok\n");
		return 0;
  800f49:	e9 be 01 00 00       	jmp    80110c <fork+0x21e>
	if (childpid < 0) {
		panic("fork sys_exofork error : %e\n", childpid);
	}
	int r;

	if (childpid == 0) {
  800f4e:	bb 00 00 00 00       	mov    $0x0,%ebx
	} else {
		// map page to new environment
		// kernel page is already in new environment
		uint32_t i;
		for (i = 0; i != UTOP; i += PGSIZE) 
		if ((uvpd[PDX(i)] & PTE_P) && (uvpt[i / PGSIZE] & PTE_P) && (uvpt[i / PGSIZE] & PTE_U)) {
  800f53:	89 d8                	mov    %ebx,%eax
  800f55:	c1 e8 16             	shr    $0x16,%eax
  800f58:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800f5f:	a8 01                	test   $0x1,%al
  800f61:	0f 84 10 01 00 00    	je     801077 <fork+0x189>
  800f67:	89 d8                	mov    %ebx,%eax
  800f69:	c1 e8 0c             	shr    $0xc,%eax
  800f6c:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800f73:	f6 c2 01             	test   $0x1,%dl
  800f76:	0f 84 fb 00 00 00    	je     801077 <fork+0x189>
  800f7c:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800f83:	f6 c2 04             	test   $0x4,%dl
  800f86:	0f 84 eb 00 00 00    	je     801077 <fork+0x189>
//
static int
duppage(envid_t envid, unsigned pn)
{
	// do not dup exception stack
	if (pn * PGSIZE == UXSTACKTOP - PGSIZE) return 0;
  800f8c:	89 c6                	mov    %eax,%esi
  800f8e:	c1 e6 0c             	shl    $0xc,%esi
  800f91:	81 fe 00 f0 bf ee    	cmp    $0xeebff000,%esi
  800f97:	0f 84 da 00 00 00    	je     801077 <fork+0x189>

	int r;
	void * addr = (void *)(pn * PGSIZE);
    if (uvpt[pn] & PTE_SHARE) {
  800f9d:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800fa4:	f6 c6 04             	test   $0x4,%dh
  800fa7:	74 37                	je     800fe0 <fork+0xf2>
        r = sys_page_map(0, addr, envid, addr, uvpt[pn] & PTE_SYSCALL);
  800fa9:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800fb0:	83 ec 0c             	sub    $0xc,%esp
  800fb3:	25 07 0e 00 00       	and    $0xe07,%eax
  800fb8:	50                   	push   %eax
  800fb9:	56                   	push   %esi
  800fba:	57                   	push   %edi
  800fbb:	56                   	push   %esi
  800fbc:	6a 00                	push   $0x0
  800fbe:	e8 d1 fc ff ff       	call   800c94 <sys_page_map>
        if (r < 0) panic("duppage sys_page_map error : %e\n", r);
  800fc3:	83 c4 20             	add    $0x20,%esp
  800fc6:	85 c0                	test   %eax,%eax
  800fc8:	0f 89 a9 00 00 00    	jns    801077 <fork+0x189>
  800fce:	50                   	push   %eax
  800fcf:	68 3c 26 80 00       	push   $0x80263c
  800fd4:	6a 54                	push   $0x54
  800fd6:	68 f0 26 80 00       	push   $0x8026f0
  800fdb:	e8 80 f1 ff ff       	call   800160 <_panic>
    } else
	if ((uvpt[pn] & PTE_W) || (uvpt[pn] & PTE_COW)) {
  800fe0:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800fe7:	f6 c2 02             	test   $0x2,%dl
  800fea:	75 0c                	jne    800ff8 <fork+0x10a>
  800fec:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800ff3:	f6 c4 08             	test   $0x8,%ah
  800ff6:	74 57                	je     80104f <fork+0x161>
		// cow
		r = sys_page_map(0, addr, envid, addr, PTE_COW | PTE_P | PTE_U);
  800ff8:	83 ec 0c             	sub    $0xc,%esp
  800ffb:	68 05 08 00 00       	push   $0x805
  801000:	56                   	push   %esi
  801001:	57                   	push   %edi
  801002:	56                   	push   %esi
  801003:	6a 00                	push   $0x0
  801005:	e8 8a fc ff ff       	call   800c94 <sys_page_map>
		if (r < 0) panic("duppage sys_page_map error : %e\n", r);
  80100a:	83 c4 20             	add    $0x20,%esp
  80100d:	85 c0                	test   %eax,%eax
  80100f:	79 12                	jns    801023 <fork+0x135>
  801011:	50                   	push   %eax
  801012:	68 3c 26 80 00       	push   $0x80263c
  801017:	6a 59                	push   $0x59
  801019:	68 f0 26 80 00       	push   $0x8026f0
  80101e:	e8 3d f1 ff ff       	call   800160 <_panic>
		
		r = sys_page_map(0, addr, 0, addr, PTE_COW | PTE_P | PTE_U);
  801023:	83 ec 0c             	sub    $0xc,%esp
  801026:	68 05 08 00 00       	push   $0x805
  80102b:	56                   	push   %esi
  80102c:	6a 00                	push   $0x0
  80102e:	56                   	push   %esi
  80102f:	6a 00                	push   $0x0
  801031:	e8 5e fc ff ff       	call   800c94 <sys_page_map>
		if (r < 0) panic("duppage sys_page_map error : %e\n", r);
  801036:	83 c4 20             	add    $0x20,%esp
  801039:	85 c0                	test   %eax,%eax
  80103b:	79 3a                	jns    801077 <fork+0x189>
  80103d:	50                   	push   %eax
  80103e:	68 3c 26 80 00       	push   $0x80263c
  801043:	6a 5c                	push   $0x5c
  801045:	68 f0 26 80 00       	push   $0x8026f0
  80104a:	e8 11 f1 ff ff       	call   800160 <_panic>
	} else {
		// read only
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U);
  80104f:	83 ec 0c             	sub    $0xc,%esp
  801052:	6a 05                	push   $0x5
  801054:	56                   	push   %esi
  801055:	57                   	push   %edi
  801056:	56                   	push   %esi
  801057:	6a 00                	push   $0x0
  801059:	e8 36 fc ff ff       	call   800c94 <sys_page_map>
		if (r < 0) panic("duppage sys_page_map error : %e\n", r);
  80105e:	83 c4 20             	add    $0x20,%esp
  801061:	85 c0                	test   %eax,%eax
  801063:	79 12                	jns    801077 <fork+0x189>
  801065:	50                   	push   %eax
  801066:	68 3c 26 80 00       	push   $0x80263c
  80106b:	6a 60                	push   $0x60
  80106d:	68 f0 26 80 00       	push   $0x8026f0
  801072:	e8 e9 f0 ff ff       	call   800160 <_panic>
		return 0;
	} else {
		// map page to new environment
		// kernel page is already in new environment
		uint32_t i;
		for (i = 0; i != UTOP; i += PGSIZE) 
  801077:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  80107d:	81 fb 00 00 c0 ee    	cmp    $0xeec00000,%ebx
  801083:	0f 85 ca fe ff ff    	jne    800f53 <fork+0x65>
		if ((uvpd[PDX(i)] & PTE_P) && (uvpt[i / PGSIZE] & PTE_P) && (uvpt[i / PGSIZE] & PTE_U)) {
			duppage(childpid, i / PGSIZE);
		}

		// allocate exception stack
		r = sys_page_alloc(childpid, (void *)(UXSTACKTOP - PGSIZE), PTE_U | PTE_W | PTE_P);
  801089:	83 ec 04             	sub    $0x4,%esp
  80108c:	6a 07                	push   $0x7
  80108e:	68 00 f0 bf ee       	push   $0xeebff000
  801093:	ff 75 e4             	pushl  -0x1c(%ebp)
  801096:	e8 d5 fb ff ff       	call   800c70 <sys_page_alloc>
		if (r < 0) panic("fork, sys_page_alloc user exception stack error : %e\n", r);
  80109b:	83 c4 10             	add    $0x10,%esp
  80109e:	85 c0                	test   %eax,%eax
  8010a0:	79 15                	jns    8010b7 <fork+0x1c9>
  8010a2:	50                   	push   %eax
  8010a3:	68 60 26 80 00       	push   $0x802660
  8010a8:	68 94 00 00 00       	push   $0x94
  8010ad:	68 f0 26 80 00       	push   $0x8026f0
  8010b2:	e8 a9 f0 ff ff       	call   800160 <_panic>

		// set user environment user page fault handler 
		extern void _pgfault_upcall(void);
		r = sys_env_set_pgfault_upcall(childpid, _pgfault_upcall);
  8010b7:	83 ec 08             	sub    $0x8,%esp
  8010ba:	68 6c 1f 80 00       	push   $0x801f6c
  8010bf:	ff 75 e4             	pushl  -0x1c(%ebp)
  8010c2:	e8 5c fc ff ff       	call   800d23 <sys_env_set_pgfault_upcall>
		if (r < 0) panic("fork, set pgfault upcall fail : %e\n", r);
  8010c7:	83 c4 10             	add    $0x10,%esp
  8010ca:	85 c0                	test   %eax,%eax
  8010cc:	79 15                	jns    8010e3 <fork+0x1f5>
  8010ce:	50                   	push   %eax
  8010cf:	68 98 26 80 00       	push   $0x802698
  8010d4:	68 99 00 00 00       	push   $0x99
  8010d9:	68 f0 26 80 00       	push   $0x8026f0
  8010de:	e8 7d f0 ff ff       	call   800160 <_panic>
		r = sys_set_priority(childpid, num);
		if (r < 0) panic("fork, set priority error\n");
		*/

		// mark the child as runnable and return
		r = sys_env_set_status(childpid, ENV_RUNNABLE);
  8010e3:	83 ec 08             	sub    $0x8,%esp
  8010e6:	6a 02                	push   $0x2
  8010e8:	ff 75 e4             	pushl  -0x1c(%ebp)
  8010eb:	e8 ed fb ff ff       	call   800cdd <sys_env_set_status>
		if (r < 0) panic("fork, set child process to ENV_RUNNABLE error : %e\n", r);
  8010f0:	83 c4 10             	add    $0x10,%esp
  8010f3:	85 c0                	test   %eax,%eax
  8010f5:	79 15                	jns    80110c <fork+0x21e>
  8010f7:	50                   	push   %eax
  8010f8:	68 bc 26 80 00       	push   $0x8026bc
  8010fd:	68 a4 00 00 00       	push   $0xa4
  801102:	68 f0 26 80 00       	push   $0x8026f0
  801107:	e8 54 f0 ff ff       	call   800160 <_panic>
		// cprintf("fork father ok!")
		return childpid;
	}

	panic("fork not implemented");
}
  80110c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80110f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801112:	5b                   	pop    %ebx
  801113:	5e                   	pop    %esi
  801114:	5f                   	pop    %edi
  801115:	c9                   	leave  
  801116:	c3                   	ret    

00801117 <sfork>:

// Challenge!
int
sfork(void)
{
  801117:	55                   	push   %ebp
  801118:	89 e5                	mov    %esp,%ebp
  80111a:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  80111d:	68 18 27 80 00       	push   $0x802718
  801122:	68 b1 00 00 00       	push   $0xb1
  801127:	68 f0 26 80 00       	push   $0x8026f0
  80112c:	e8 2f f0 ff ff       	call   800160 <_panic>
  801131:	00 00                	add    %al,(%eax)
	...

00801134 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801134:	55                   	push   %ebp
  801135:	89 e5                	mov    %esp,%ebp
  801137:	56                   	push   %esi
  801138:	53                   	push   %ebx
  801139:	8b 75 08             	mov    0x8(%ebp),%esi
  80113c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80113f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// cprintf("0x%x 0x%x 0x%x\n", (uint32_t)from_env_store, (uint32_t)pg, (uint32_t)perm_store);
	int r;
	if (pg != NULL) {
  801142:	85 c0                	test   %eax,%eax
  801144:	74 0e                	je     801154 <ipc_recv+0x20>
		r = sys_ipc_recv(pg);
  801146:	83 ec 0c             	sub    $0xc,%esp
  801149:	50                   	push   %eax
  80114a:	e8 1c fc ff ff       	call   800d6b <sys_ipc_recv>
  80114f:	83 c4 10             	add    $0x10,%esp
  801152:	eb 10                	jmp    801164 <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv((void *)UTOP);
  801154:	83 ec 0c             	sub    $0xc,%esp
  801157:	68 00 00 c0 ee       	push   $0xeec00000
  80115c:	e8 0a fc ff ff       	call   800d6b <sys_ipc_recv>
  801161:	83 c4 10             	add    $0x10,%esp
	}

	if (r == 0) {
  801164:	85 c0                	test   %eax,%eax
  801166:	75 26                	jne    80118e <ipc_recv+0x5a>
		if (from_env_store != NULL) *from_env_store = thisenv->env_ipc_from;
  801168:	85 f6                	test   %esi,%esi
  80116a:	74 0a                	je     801176 <ipc_recv+0x42>
  80116c:	a1 04 40 80 00       	mov    0x804004,%eax
  801171:	8b 40 74             	mov    0x74(%eax),%eax
  801174:	89 06                	mov    %eax,(%esi)
		if (perm_store != NULL) *perm_store = thisenv->env_ipc_perm;
  801176:	85 db                	test   %ebx,%ebx
  801178:	74 0a                	je     801184 <ipc_recv+0x50>
  80117a:	a1 04 40 80 00       	mov    0x804004,%eax
  80117f:	8b 40 78             	mov    0x78(%eax),%eax
  801182:	89 03                	mov    %eax,(%ebx)
		return thisenv->env_ipc_value;
  801184:	a1 04 40 80 00       	mov    0x804004,%eax
  801189:	8b 40 70             	mov    0x70(%eax),%eax
  80118c:	eb 14                	jmp    8011a2 <ipc_recv+0x6e>
	} else {
		// fails;
		if (from_env_store != NULL) *from_env_store = 0;
  80118e:	85 f6                	test   %esi,%esi
  801190:	74 06                	je     801198 <ipc_recv+0x64>
  801192:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if (perm_store != NULL) *perm_store = 0;
  801198:	85 db                	test   %ebx,%ebx
  80119a:	74 06                	je     8011a2 <ipc_recv+0x6e>
  80119c:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		return r;
	}
}
  8011a2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8011a5:	5b                   	pop    %ebx
  8011a6:	5e                   	pop    %esi
  8011a7:	c9                   	leave  
  8011a8:	c3                   	ret    

008011a9 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8011a9:	55                   	push   %ebp
  8011aa:	89 e5                	mov    %esp,%ebp
  8011ac:	57                   	push   %edi
  8011ad:	56                   	push   %esi
  8011ae:	53                   	push   %ebx
  8011af:	83 ec 0c             	sub    $0xc,%esp
  8011b2:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8011b5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8011b8:	8b 75 14             	mov    0x14(%ebp),%esi
	// LAB 4: Your code here.
	// int sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
	int r;
	if (pg == NULL) pg = (void *)UTOP;
  8011bb:	85 db                	test   %ebx,%ebx
  8011bd:	75 25                	jne    8011e4 <ipc_send+0x3b>
  8011bf:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
  8011c4:	eb 1e                	jmp    8011e4 <ipc_send+0x3b>
	
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) != 0) {
		if (r == -E_IPC_NOT_RECV) {
  8011c6:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8011c9:	75 07                	jne    8011d2 <ipc_send+0x29>
			// cprintf("Try Again and Again....\n");
			sys_yield();
  8011cb:	e8 79 fa ff ff       	call   800c49 <sys_yield>
  8011d0:	eb 12                	jmp    8011e4 <ipc_send+0x3b>
		} else {
			panic("ipc_send error %e\n", r);
  8011d2:	50                   	push   %eax
  8011d3:	68 2e 27 80 00       	push   $0x80272e
  8011d8:	6a 43                	push   $0x43
  8011da:	68 41 27 80 00       	push   $0x802741
  8011df:	e8 7c ef ff ff       	call   800160 <_panic>
	// LAB 4: Your code here.
	// int sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
	int r;
	if (pg == NULL) pg = (void *)UTOP;
	
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) != 0) {
  8011e4:	56                   	push   %esi
  8011e5:	53                   	push   %ebx
  8011e6:	57                   	push   %edi
  8011e7:	ff 75 08             	pushl  0x8(%ebp)
  8011ea:	e8 57 fb ff ff       	call   800d46 <sys_ipc_try_send>
  8011ef:	83 c4 10             	add    $0x10,%esp
  8011f2:	85 c0                	test   %eax,%eax
  8011f4:	75 d0                	jne    8011c6 <ipc_send+0x1d>
		} else {
			panic("ipc_send error %e\n", r);
		}
	}
	return;
}
  8011f6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011f9:	5b                   	pop    %ebx
  8011fa:	5e                   	pop    %esi
  8011fb:	5f                   	pop    %edi
  8011fc:	c9                   	leave  
  8011fd:	c3                   	ret    

008011fe <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8011fe:	55                   	push   %ebp
  8011ff:	89 e5                	mov    %esp,%ebp
  801201:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  801204:	39 0d 50 00 c0 ee    	cmp    %ecx,0xeec00050
  80120a:	74 1a                	je     801226 <ipc_find_env+0x28>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80120c:	b8 01 00 00 00       	mov    $0x1,%eax
		if (envs[i].env_type == type)
  801211:	89 c2                	mov    %eax,%edx
  801213:	c1 e2 07             	shl    $0x7,%edx
  801216:	8d 94 82 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,4),%edx
  80121d:	8b 52 50             	mov    0x50(%edx),%edx
  801220:	39 ca                	cmp    %ecx,%edx
  801222:	75 18                	jne    80123c <ipc_find_env+0x3e>
  801224:	eb 05                	jmp    80122b <ipc_find_env+0x2d>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801226:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
			return envs[i].env_id;
  80122b:	89 c2                	mov    %eax,%edx
  80122d:	c1 e2 07             	shl    $0x7,%edx
  801230:	8d 84 82 08 00 c0 ee 	lea    -0x113ffff8(%edx,%eax,4),%eax
  801237:	8b 40 40             	mov    0x40(%eax),%eax
  80123a:	eb 0c                	jmp    801248 <ipc_find_env+0x4a>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80123c:	40                   	inc    %eax
  80123d:	3d 00 04 00 00       	cmp    $0x400,%eax
  801242:	75 cd                	jne    801211 <ipc_find_env+0x13>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801244:	66 b8 00 00          	mov    $0x0,%ax
}
  801248:	c9                   	leave  
  801249:	c3                   	ret    
	...

0080124c <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  80124c:	55                   	push   %ebp
  80124d:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80124f:	8b 45 08             	mov    0x8(%ebp),%eax
  801252:	05 00 00 00 30       	add    $0x30000000,%eax
  801257:	c1 e8 0c             	shr    $0xc,%eax
}
  80125a:	c9                   	leave  
  80125b:	c3                   	ret    

0080125c <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80125c:	55                   	push   %ebp
  80125d:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  80125f:	ff 75 08             	pushl  0x8(%ebp)
  801262:	e8 e5 ff ff ff       	call   80124c <fd2num>
  801267:	83 c4 04             	add    $0x4,%esp
  80126a:	05 20 00 0d 00       	add    $0xd0020,%eax
  80126f:	c1 e0 0c             	shl    $0xc,%eax
}
  801272:	c9                   	leave  
  801273:	c3                   	ret    

00801274 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801274:	55                   	push   %ebp
  801275:	89 e5                	mov    %esp,%ebp
  801277:	53                   	push   %ebx
  801278:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80127b:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  801280:	a8 01                	test   $0x1,%al
  801282:	74 34                	je     8012b8 <fd_alloc+0x44>
  801284:	a1 00 00 74 ef       	mov    0xef740000,%eax
  801289:	a8 01                	test   $0x1,%al
  80128b:	74 32                	je     8012bf <fd_alloc+0x4b>
  80128d:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
  801292:	89 c1                	mov    %eax,%ecx
  801294:	89 c2                	mov    %eax,%edx
  801296:	c1 ea 16             	shr    $0x16,%edx
  801299:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8012a0:	f6 c2 01             	test   $0x1,%dl
  8012a3:	74 1f                	je     8012c4 <fd_alloc+0x50>
  8012a5:	89 c2                	mov    %eax,%edx
  8012a7:	c1 ea 0c             	shr    $0xc,%edx
  8012aa:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8012b1:	f6 c2 01             	test   $0x1,%dl
  8012b4:	75 17                	jne    8012cd <fd_alloc+0x59>
  8012b6:	eb 0c                	jmp    8012c4 <fd_alloc+0x50>
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  8012b8:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
  8012bd:	eb 05                	jmp    8012c4 <fd_alloc+0x50>
  8012bf:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
  8012c4:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  8012c6:	b8 00 00 00 00       	mov    $0x0,%eax
  8012cb:	eb 17                	jmp    8012e4 <fd_alloc+0x70>
  8012cd:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8012d2:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8012d7:	75 b9                	jne    801292 <fd_alloc+0x1e>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8012d9:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  8012df:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8012e4:	5b                   	pop    %ebx
  8012e5:	c9                   	leave  
  8012e6:	c3                   	ret    

008012e7 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8012e7:	55                   	push   %ebp
  8012e8:	89 e5                	mov    %esp,%ebp
  8012ea:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8012ed:	83 f8 1f             	cmp    $0x1f,%eax
  8012f0:	77 36                	ja     801328 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8012f2:	05 00 00 0d 00       	add    $0xd0000,%eax
  8012f7:	c1 e0 0c             	shl    $0xc,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8012fa:	89 c2                	mov    %eax,%edx
  8012fc:	c1 ea 16             	shr    $0x16,%edx
  8012ff:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801306:	f6 c2 01             	test   $0x1,%dl
  801309:	74 24                	je     80132f <fd_lookup+0x48>
  80130b:	89 c2                	mov    %eax,%edx
  80130d:	c1 ea 0c             	shr    $0xc,%edx
  801310:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801317:	f6 c2 01             	test   $0x1,%dl
  80131a:	74 1a                	je     801336 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80131c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80131f:	89 02                	mov    %eax,(%edx)
	return 0;
  801321:	b8 00 00 00 00       	mov    $0x0,%eax
  801326:	eb 13                	jmp    80133b <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801328:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80132d:	eb 0c                	jmp    80133b <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80132f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801334:	eb 05                	jmp    80133b <fd_lookup+0x54>
  801336:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  80133b:	c9                   	leave  
  80133c:	c3                   	ret    

0080133d <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80133d:	55                   	push   %ebp
  80133e:	89 e5                	mov    %esp,%ebp
  801340:	53                   	push   %ebx
  801341:	83 ec 04             	sub    $0x4,%esp
  801344:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801347:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  80134a:	39 0d 04 30 80 00    	cmp    %ecx,0x803004
  801350:	74 0d                	je     80135f <dev_lookup+0x22>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801352:	b8 00 00 00 00       	mov    $0x0,%eax
  801357:	eb 14                	jmp    80136d <dev_lookup+0x30>
		if (devtab[i]->dev_id == dev_id) {
  801359:	39 0a                	cmp    %ecx,(%edx)
  80135b:	75 10                	jne    80136d <dev_lookup+0x30>
  80135d:	eb 05                	jmp    801364 <dev_lookup+0x27>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80135f:	ba 04 30 80 00       	mov    $0x803004,%edx
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
  801364:	89 13                	mov    %edx,(%ebx)
			return 0;
  801366:	b8 00 00 00 00       	mov    $0x0,%eax
  80136b:	eb 31                	jmp    80139e <dev_lookup+0x61>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80136d:	40                   	inc    %eax
  80136e:	8b 14 85 c8 27 80 00 	mov    0x8027c8(,%eax,4),%edx
  801375:	85 d2                	test   %edx,%edx
  801377:	75 e0                	jne    801359 <dev_lookup+0x1c>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801379:	a1 04 40 80 00       	mov    0x804004,%eax
  80137e:	8b 40 48             	mov    0x48(%eax),%eax
  801381:	83 ec 04             	sub    $0x4,%esp
  801384:	51                   	push   %ecx
  801385:	50                   	push   %eax
  801386:	68 4c 27 80 00       	push   $0x80274c
  80138b:	e8 a8 ee ff ff       	call   800238 <cprintf>
	*dev = 0;
  801390:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  801396:	83 c4 10             	add    $0x10,%esp
  801399:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80139e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013a1:	c9                   	leave  
  8013a2:	c3                   	ret    

008013a3 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8013a3:	55                   	push   %ebp
  8013a4:	89 e5                	mov    %esp,%ebp
  8013a6:	56                   	push   %esi
  8013a7:	53                   	push   %ebx
  8013a8:	83 ec 20             	sub    $0x20,%esp
  8013ab:	8b 75 08             	mov    0x8(%ebp),%esi
  8013ae:	8a 45 0c             	mov    0xc(%ebp),%al
  8013b1:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8013b4:	56                   	push   %esi
  8013b5:	e8 92 fe ff ff       	call   80124c <fd2num>
  8013ba:	8d 55 f4             	lea    -0xc(%ebp),%edx
  8013bd:	89 14 24             	mov    %edx,(%esp)
  8013c0:	50                   	push   %eax
  8013c1:	e8 21 ff ff ff       	call   8012e7 <fd_lookup>
  8013c6:	89 c3                	mov    %eax,%ebx
  8013c8:	83 c4 08             	add    $0x8,%esp
  8013cb:	85 c0                	test   %eax,%eax
  8013cd:	78 05                	js     8013d4 <fd_close+0x31>
	    || fd != fd2)
  8013cf:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8013d2:	74 0d                	je     8013e1 <fd_close+0x3e>
		return (must_exist ? r : 0);
  8013d4:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  8013d8:	75 48                	jne    801422 <fd_close+0x7f>
  8013da:	bb 00 00 00 00       	mov    $0x0,%ebx
  8013df:	eb 41                	jmp    801422 <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8013e1:	83 ec 08             	sub    $0x8,%esp
  8013e4:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8013e7:	50                   	push   %eax
  8013e8:	ff 36                	pushl  (%esi)
  8013ea:	e8 4e ff ff ff       	call   80133d <dev_lookup>
  8013ef:	89 c3                	mov    %eax,%ebx
  8013f1:	83 c4 10             	add    $0x10,%esp
  8013f4:	85 c0                	test   %eax,%eax
  8013f6:	78 1c                	js     801414 <fd_close+0x71>
		if (dev->dev_close)
  8013f8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013fb:	8b 40 10             	mov    0x10(%eax),%eax
  8013fe:	85 c0                	test   %eax,%eax
  801400:	74 0d                	je     80140f <fd_close+0x6c>
			r = (*dev->dev_close)(fd);
  801402:	83 ec 0c             	sub    $0xc,%esp
  801405:	56                   	push   %esi
  801406:	ff d0                	call   *%eax
  801408:	89 c3                	mov    %eax,%ebx
  80140a:	83 c4 10             	add    $0x10,%esp
  80140d:	eb 05                	jmp    801414 <fd_close+0x71>
		else
			r = 0;
  80140f:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801414:	83 ec 08             	sub    $0x8,%esp
  801417:	56                   	push   %esi
  801418:	6a 00                	push   $0x0
  80141a:	e8 9b f8 ff ff       	call   800cba <sys_page_unmap>
	return r;
  80141f:	83 c4 10             	add    $0x10,%esp
}
  801422:	89 d8                	mov    %ebx,%eax
  801424:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801427:	5b                   	pop    %ebx
  801428:	5e                   	pop    %esi
  801429:	c9                   	leave  
  80142a:	c3                   	ret    

0080142b <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80142b:	55                   	push   %ebp
  80142c:	89 e5                	mov    %esp,%ebp
  80142e:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801431:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801434:	50                   	push   %eax
  801435:	ff 75 08             	pushl  0x8(%ebp)
  801438:	e8 aa fe ff ff       	call   8012e7 <fd_lookup>
  80143d:	83 c4 08             	add    $0x8,%esp
  801440:	85 c0                	test   %eax,%eax
  801442:	78 10                	js     801454 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801444:	83 ec 08             	sub    $0x8,%esp
  801447:	6a 01                	push   $0x1
  801449:	ff 75 f4             	pushl  -0xc(%ebp)
  80144c:	e8 52 ff ff ff       	call   8013a3 <fd_close>
  801451:	83 c4 10             	add    $0x10,%esp
}
  801454:	c9                   	leave  
  801455:	c3                   	ret    

00801456 <close_all>:

void
close_all(void)
{
  801456:	55                   	push   %ebp
  801457:	89 e5                	mov    %esp,%ebp
  801459:	53                   	push   %ebx
  80145a:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80145d:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801462:	83 ec 0c             	sub    $0xc,%esp
  801465:	53                   	push   %ebx
  801466:	e8 c0 ff ff ff       	call   80142b <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80146b:	43                   	inc    %ebx
  80146c:	83 c4 10             	add    $0x10,%esp
  80146f:	83 fb 20             	cmp    $0x20,%ebx
  801472:	75 ee                	jne    801462 <close_all+0xc>
		close(i);
}
  801474:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801477:	c9                   	leave  
  801478:	c3                   	ret    

00801479 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801479:	55                   	push   %ebp
  80147a:	89 e5                	mov    %esp,%ebp
  80147c:	57                   	push   %edi
  80147d:	56                   	push   %esi
  80147e:	53                   	push   %ebx
  80147f:	83 ec 2c             	sub    $0x2c,%esp
  801482:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801485:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801488:	50                   	push   %eax
  801489:	ff 75 08             	pushl  0x8(%ebp)
  80148c:	e8 56 fe ff ff       	call   8012e7 <fd_lookup>
  801491:	89 c3                	mov    %eax,%ebx
  801493:	83 c4 08             	add    $0x8,%esp
  801496:	85 c0                	test   %eax,%eax
  801498:	0f 88 c0 00 00 00    	js     80155e <dup+0xe5>
		return r;
	close(newfdnum);
  80149e:	83 ec 0c             	sub    $0xc,%esp
  8014a1:	57                   	push   %edi
  8014a2:	e8 84 ff ff ff       	call   80142b <close>

	newfd = INDEX2FD(newfdnum);
  8014a7:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  8014ad:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  8014b0:	83 c4 04             	add    $0x4,%esp
  8014b3:	ff 75 e4             	pushl  -0x1c(%ebp)
  8014b6:	e8 a1 fd ff ff       	call   80125c <fd2data>
  8014bb:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  8014bd:	89 34 24             	mov    %esi,(%esp)
  8014c0:	e8 97 fd ff ff       	call   80125c <fd2data>
  8014c5:	83 c4 10             	add    $0x10,%esp
  8014c8:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8014cb:	89 d8                	mov    %ebx,%eax
  8014cd:	c1 e8 16             	shr    $0x16,%eax
  8014d0:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8014d7:	a8 01                	test   $0x1,%al
  8014d9:	74 37                	je     801512 <dup+0x99>
  8014db:	89 d8                	mov    %ebx,%eax
  8014dd:	c1 e8 0c             	shr    $0xc,%eax
  8014e0:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8014e7:	f6 c2 01             	test   $0x1,%dl
  8014ea:	74 26                	je     801512 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8014ec:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8014f3:	83 ec 0c             	sub    $0xc,%esp
  8014f6:	25 07 0e 00 00       	and    $0xe07,%eax
  8014fb:	50                   	push   %eax
  8014fc:	ff 75 d4             	pushl  -0x2c(%ebp)
  8014ff:	6a 00                	push   $0x0
  801501:	53                   	push   %ebx
  801502:	6a 00                	push   $0x0
  801504:	e8 8b f7 ff ff       	call   800c94 <sys_page_map>
  801509:	89 c3                	mov    %eax,%ebx
  80150b:	83 c4 20             	add    $0x20,%esp
  80150e:	85 c0                	test   %eax,%eax
  801510:	78 2d                	js     80153f <dup+0xc6>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801512:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801515:	89 c2                	mov    %eax,%edx
  801517:	c1 ea 0c             	shr    $0xc,%edx
  80151a:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801521:	83 ec 0c             	sub    $0xc,%esp
  801524:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  80152a:	52                   	push   %edx
  80152b:	56                   	push   %esi
  80152c:	6a 00                	push   $0x0
  80152e:	50                   	push   %eax
  80152f:	6a 00                	push   $0x0
  801531:	e8 5e f7 ff ff       	call   800c94 <sys_page_map>
  801536:	89 c3                	mov    %eax,%ebx
  801538:	83 c4 20             	add    $0x20,%esp
  80153b:	85 c0                	test   %eax,%eax
  80153d:	79 1d                	jns    80155c <dup+0xe3>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80153f:	83 ec 08             	sub    $0x8,%esp
  801542:	56                   	push   %esi
  801543:	6a 00                	push   $0x0
  801545:	e8 70 f7 ff ff       	call   800cba <sys_page_unmap>
	sys_page_unmap(0, nva);
  80154a:	83 c4 08             	add    $0x8,%esp
  80154d:	ff 75 d4             	pushl  -0x2c(%ebp)
  801550:	6a 00                	push   $0x0
  801552:	e8 63 f7 ff ff       	call   800cba <sys_page_unmap>
	return r;
  801557:	83 c4 10             	add    $0x10,%esp
  80155a:	eb 02                	jmp    80155e <dup+0xe5>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  80155c:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  80155e:	89 d8                	mov    %ebx,%eax
  801560:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801563:	5b                   	pop    %ebx
  801564:	5e                   	pop    %esi
  801565:	5f                   	pop    %edi
  801566:	c9                   	leave  
  801567:	c3                   	ret    

00801568 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801568:	55                   	push   %ebp
  801569:	89 e5                	mov    %esp,%ebp
  80156b:	53                   	push   %ebx
  80156c:	83 ec 14             	sub    $0x14,%esp
  80156f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801572:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801575:	50                   	push   %eax
  801576:	53                   	push   %ebx
  801577:	e8 6b fd ff ff       	call   8012e7 <fd_lookup>
  80157c:	83 c4 08             	add    $0x8,%esp
  80157f:	85 c0                	test   %eax,%eax
  801581:	78 67                	js     8015ea <read+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801583:	83 ec 08             	sub    $0x8,%esp
  801586:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801589:	50                   	push   %eax
  80158a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80158d:	ff 30                	pushl  (%eax)
  80158f:	e8 a9 fd ff ff       	call   80133d <dev_lookup>
  801594:	83 c4 10             	add    $0x10,%esp
  801597:	85 c0                	test   %eax,%eax
  801599:	78 4f                	js     8015ea <read+0x82>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80159b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80159e:	8b 50 08             	mov    0x8(%eax),%edx
  8015a1:	83 e2 03             	and    $0x3,%edx
  8015a4:	83 fa 01             	cmp    $0x1,%edx
  8015a7:	75 21                	jne    8015ca <read+0x62>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8015a9:	a1 04 40 80 00       	mov    0x804004,%eax
  8015ae:	8b 40 48             	mov    0x48(%eax),%eax
  8015b1:	83 ec 04             	sub    $0x4,%esp
  8015b4:	53                   	push   %ebx
  8015b5:	50                   	push   %eax
  8015b6:	68 8d 27 80 00       	push   $0x80278d
  8015bb:	e8 78 ec ff ff       	call   800238 <cprintf>
		return -E_INVAL;
  8015c0:	83 c4 10             	add    $0x10,%esp
  8015c3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8015c8:	eb 20                	jmp    8015ea <read+0x82>
	}
	if (!dev->dev_read)
  8015ca:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8015cd:	8b 52 08             	mov    0x8(%edx),%edx
  8015d0:	85 d2                	test   %edx,%edx
  8015d2:	74 11                	je     8015e5 <read+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8015d4:	83 ec 04             	sub    $0x4,%esp
  8015d7:	ff 75 10             	pushl  0x10(%ebp)
  8015da:	ff 75 0c             	pushl  0xc(%ebp)
  8015dd:	50                   	push   %eax
  8015de:	ff d2                	call   *%edx
  8015e0:	83 c4 10             	add    $0x10,%esp
  8015e3:	eb 05                	jmp    8015ea <read+0x82>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8015e5:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  8015ea:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015ed:	c9                   	leave  
  8015ee:	c3                   	ret    

008015ef <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8015ef:	55                   	push   %ebp
  8015f0:	89 e5                	mov    %esp,%ebp
  8015f2:	57                   	push   %edi
  8015f3:	56                   	push   %esi
  8015f4:	53                   	push   %ebx
  8015f5:	83 ec 0c             	sub    $0xc,%esp
  8015f8:	8b 7d 08             	mov    0x8(%ebp),%edi
  8015fb:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8015fe:	85 f6                	test   %esi,%esi
  801600:	74 31                	je     801633 <readn+0x44>
  801602:	b8 00 00 00 00       	mov    $0x0,%eax
  801607:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = read(fdnum, (char*)buf + tot, n - tot);
  80160c:	83 ec 04             	sub    $0x4,%esp
  80160f:	89 f2                	mov    %esi,%edx
  801611:	29 c2                	sub    %eax,%edx
  801613:	52                   	push   %edx
  801614:	03 45 0c             	add    0xc(%ebp),%eax
  801617:	50                   	push   %eax
  801618:	57                   	push   %edi
  801619:	e8 4a ff ff ff       	call   801568 <read>
		if (m < 0)
  80161e:	83 c4 10             	add    $0x10,%esp
  801621:	85 c0                	test   %eax,%eax
  801623:	78 17                	js     80163c <readn+0x4d>
			return m;
		if (m == 0)
  801625:	85 c0                	test   %eax,%eax
  801627:	74 11                	je     80163a <readn+0x4b>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801629:	01 c3                	add    %eax,%ebx
  80162b:	89 d8                	mov    %ebx,%eax
  80162d:	39 f3                	cmp    %esi,%ebx
  80162f:	72 db                	jb     80160c <readn+0x1d>
  801631:	eb 09                	jmp    80163c <readn+0x4d>
  801633:	b8 00 00 00 00       	mov    $0x0,%eax
  801638:	eb 02                	jmp    80163c <readn+0x4d>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  80163a:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  80163c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80163f:	5b                   	pop    %ebx
  801640:	5e                   	pop    %esi
  801641:	5f                   	pop    %edi
  801642:	c9                   	leave  
  801643:	c3                   	ret    

00801644 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801644:	55                   	push   %ebp
  801645:	89 e5                	mov    %esp,%ebp
  801647:	53                   	push   %ebx
  801648:	83 ec 14             	sub    $0x14,%esp
  80164b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80164e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801651:	50                   	push   %eax
  801652:	53                   	push   %ebx
  801653:	e8 8f fc ff ff       	call   8012e7 <fd_lookup>
  801658:	83 c4 08             	add    $0x8,%esp
  80165b:	85 c0                	test   %eax,%eax
  80165d:	78 62                	js     8016c1 <write+0x7d>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80165f:	83 ec 08             	sub    $0x8,%esp
  801662:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801665:	50                   	push   %eax
  801666:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801669:	ff 30                	pushl  (%eax)
  80166b:	e8 cd fc ff ff       	call   80133d <dev_lookup>
  801670:	83 c4 10             	add    $0x10,%esp
  801673:	85 c0                	test   %eax,%eax
  801675:	78 4a                	js     8016c1 <write+0x7d>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801677:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80167a:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80167e:	75 21                	jne    8016a1 <write+0x5d>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801680:	a1 04 40 80 00       	mov    0x804004,%eax
  801685:	8b 40 48             	mov    0x48(%eax),%eax
  801688:	83 ec 04             	sub    $0x4,%esp
  80168b:	53                   	push   %ebx
  80168c:	50                   	push   %eax
  80168d:	68 a9 27 80 00       	push   $0x8027a9
  801692:	e8 a1 eb ff ff       	call   800238 <cprintf>
		return -E_INVAL;
  801697:	83 c4 10             	add    $0x10,%esp
  80169a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80169f:	eb 20                	jmp    8016c1 <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8016a1:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8016a4:	8b 52 0c             	mov    0xc(%edx),%edx
  8016a7:	85 d2                	test   %edx,%edx
  8016a9:	74 11                	je     8016bc <write+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8016ab:	83 ec 04             	sub    $0x4,%esp
  8016ae:	ff 75 10             	pushl  0x10(%ebp)
  8016b1:	ff 75 0c             	pushl  0xc(%ebp)
  8016b4:	50                   	push   %eax
  8016b5:	ff d2                	call   *%edx
  8016b7:	83 c4 10             	add    $0x10,%esp
  8016ba:	eb 05                	jmp    8016c1 <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8016bc:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  8016c1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016c4:	c9                   	leave  
  8016c5:	c3                   	ret    

008016c6 <seek>:

int
seek(int fdnum, off_t offset)
{
  8016c6:	55                   	push   %ebp
  8016c7:	89 e5                	mov    %esp,%ebp
  8016c9:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8016cc:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8016cf:	50                   	push   %eax
  8016d0:	ff 75 08             	pushl  0x8(%ebp)
  8016d3:	e8 0f fc ff ff       	call   8012e7 <fd_lookup>
  8016d8:	83 c4 08             	add    $0x8,%esp
  8016db:	85 c0                	test   %eax,%eax
  8016dd:	78 0e                	js     8016ed <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8016df:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8016e2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8016e5:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8016e8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8016ed:	c9                   	leave  
  8016ee:	c3                   	ret    

008016ef <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8016ef:	55                   	push   %ebp
  8016f0:	89 e5                	mov    %esp,%ebp
  8016f2:	53                   	push   %ebx
  8016f3:	83 ec 14             	sub    $0x14,%esp
  8016f6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016f9:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016fc:	50                   	push   %eax
  8016fd:	53                   	push   %ebx
  8016fe:	e8 e4 fb ff ff       	call   8012e7 <fd_lookup>
  801703:	83 c4 08             	add    $0x8,%esp
  801706:	85 c0                	test   %eax,%eax
  801708:	78 5f                	js     801769 <ftruncate+0x7a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80170a:	83 ec 08             	sub    $0x8,%esp
  80170d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801710:	50                   	push   %eax
  801711:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801714:	ff 30                	pushl  (%eax)
  801716:	e8 22 fc ff ff       	call   80133d <dev_lookup>
  80171b:	83 c4 10             	add    $0x10,%esp
  80171e:	85 c0                	test   %eax,%eax
  801720:	78 47                	js     801769 <ftruncate+0x7a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801722:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801725:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801729:	75 21                	jne    80174c <ftruncate+0x5d>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80172b:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801730:	8b 40 48             	mov    0x48(%eax),%eax
  801733:	83 ec 04             	sub    $0x4,%esp
  801736:	53                   	push   %ebx
  801737:	50                   	push   %eax
  801738:	68 6c 27 80 00       	push   $0x80276c
  80173d:	e8 f6 ea ff ff       	call   800238 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801742:	83 c4 10             	add    $0x10,%esp
  801745:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80174a:	eb 1d                	jmp    801769 <ftruncate+0x7a>
	}
	if (!dev->dev_trunc)
  80174c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80174f:	8b 52 18             	mov    0x18(%edx),%edx
  801752:	85 d2                	test   %edx,%edx
  801754:	74 0e                	je     801764 <ftruncate+0x75>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801756:	83 ec 08             	sub    $0x8,%esp
  801759:	ff 75 0c             	pushl  0xc(%ebp)
  80175c:	50                   	push   %eax
  80175d:	ff d2                	call   *%edx
  80175f:	83 c4 10             	add    $0x10,%esp
  801762:	eb 05                	jmp    801769 <ftruncate+0x7a>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801764:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  801769:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80176c:	c9                   	leave  
  80176d:	c3                   	ret    

0080176e <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80176e:	55                   	push   %ebp
  80176f:	89 e5                	mov    %esp,%ebp
  801771:	53                   	push   %ebx
  801772:	83 ec 14             	sub    $0x14,%esp
  801775:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801778:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80177b:	50                   	push   %eax
  80177c:	ff 75 08             	pushl  0x8(%ebp)
  80177f:	e8 63 fb ff ff       	call   8012e7 <fd_lookup>
  801784:	83 c4 08             	add    $0x8,%esp
  801787:	85 c0                	test   %eax,%eax
  801789:	78 52                	js     8017dd <fstat+0x6f>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80178b:	83 ec 08             	sub    $0x8,%esp
  80178e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801791:	50                   	push   %eax
  801792:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801795:	ff 30                	pushl  (%eax)
  801797:	e8 a1 fb ff ff       	call   80133d <dev_lookup>
  80179c:	83 c4 10             	add    $0x10,%esp
  80179f:	85 c0                	test   %eax,%eax
  8017a1:	78 3a                	js     8017dd <fstat+0x6f>
		return r;
	if (!dev->dev_stat)
  8017a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017a6:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8017aa:	74 2c                	je     8017d8 <fstat+0x6a>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8017ac:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8017af:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8017b6:	00 00 00 
	stat->st_isdir = 0;
  8017b9:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8017c0:	00 00 00 
	stat->st_dev = dev;
  8017c3:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8017c9:	83 ec 08             	sub    $0x8,%esp
  8017cc:	53                   	push   %ebx
  8017cd:	ff 75 f0             	pushl  -0x10(%ebp)
  8017d0:	ff 50 14             	call   *0x14(%eax)
  8017d3:	83 c4 10             	add    $0x10,%esp
  8017d6:	eb 05                	jmp    8017dd <fstat+0x6f>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8017d8:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8017dd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017e0:	c9                   	leave  
  8017e1:	c3                   	ret    

008017e2 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8017e2:	55                   	push   %ebp
  8017e3:	89 e5                	mov    %esp,%ebp
  8017e5:	56                   	push   %esi
  8017e6:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8017e7:	83 ec 08             	sub    $0x8,%esp
  8017ea:	6a 00                	push   $0x0
  8017ec:	ff 75 08             	pushl  0x8(%ebp)
  8017ef:	e8 78 01 00 00       	call   80196c <open>
  8017f4:	89 c3                	mov    %eax,%ebx
  8017f6:	83 c4 10             	add    $0x10,%esp
  8017f9:	85 c0                	test   %eax,%eax
  8017fb:	78 1b                	js     801818 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8017fd:	83 ec 08             	sub    $0x8,%esp
  801800:	ff 75 0c             	pushl  0xc(%ebp)
  801803:	50                   	push   %eax
  801804:	e8 65 ff ff ff       	call   80176e <fstat>
  801809:	89 c6                	mov    %eax,%esi
	close(fd);
  80180b:	89 1c 24             	mov    %ebx,(%esp)
  80180e:	e8 18 fc ff ff       	call   80142b <close>
	return r;
  801813:	83 c4 10             	add    $0x10,%esp
  801816:	89 f3                	mov    %esi,%ebx
}
  801818:	89 d8                	mov    %ebx,%eax
  80181a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80181d:	5b                   	pop    %ebx
  80181e:	5e                   	pop    %esi
  80181f:	c9                   	leave  
  801820:	c3                   	ret    
  801821:	00 00                	add    %al,(%eax)
	...

00801824 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801824:	55                   	push   %ebp
  801825:	89 e5                	mov    %esp,%ebp
  801827:	56                   	push   %esi
  801828:	53                   	push   %ebx
  801829:	89 c3                	mov    %eax,%ebx
  80182b:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  80182d:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801834:	75 12                	jne    801848 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801836:	83 ec 0c             	sub    $0xc,%esp
  801839:	6a 01                	push   $0x1
  80183b:	e8 be f9 ff ff       	call   8011fe <ipc_find_env>
  801840:	a3 00 40 80 00       	mov    %eax,0x804000
  801845:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801848:	6a 07                	push   $0x7
  80184a:	68 00 50 80 00       	push   $0x805000
  80184f:	53                   	push   %ebx
  801850:	ff 35 00 40 80 00    	pushl  0x804000
  801856:	e8 4e f9 ff ff       	call   8011a9 <ipc_send>
	
	return ipc_recv(NULL, dstva, NULL);
  80185b:	83 c4 0c             	add    $0xc,%esp
  80185e:	6a 00                	push   $0x0
  801860:	56                   	push   %esi
  801861:	6a 00                	push   $0x0
  801863:	e8 cc f8 ff ff       	call   801134 <ipc_recv>
}
  801868:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80186b:	5b                   	pop    %ebx
  80186c:	5e                   	pop    %esi
  80186d:	c9                   	leave  
  80186e:	c3                   	ret    

0080186f <devfile_stat>:
}


static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80186f:	55                   	push   %ebp
  801870:	89 e5                	mov    %esp,%ebp
  801872:	53                   	push   %ebx
  801873:	83 ec 04             	sub    $0x4,%esp
  801876:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801879:	8b 45 08             	mov    0x8(%ebp),%eax
  80187c:	8b 40 0c             	mov    0xc(%eax),%eax
  80187f:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0) {
  801884:	ba 00 00 00 00       	mov    $0x0,%edx
  801889:	b8 05 00 00 00       	mov    $0x5,%eax
  80188e:	e8 91 ff ff ff       	call   801824 <fsipc>
  801893:	85 c0                	test   %eax,%eax
  801895:	78 2c                	js     8018c3 <devfile_stat+0x54>
		return r;
	}
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801897:	83 ec 08             	sub    $0x8,%esp
  80189a:	68 00 50 80 00       	push   $0x805000
  80189f:	53                   	push   %ebx
  8018a0:	e8 49 ef ff ff       	call   8007ee <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8018a5:	a1 80 50 80 00       	mov    0x805080,%eax
  8018aa:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8018b0:	a1 84 50 80 00       	mov    0x805084,%eax
  8018b5:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8018bb:	83 c4 10             	add    $0x10,%esp
  8018be:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8018c3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018c6:	c9                   	leave  
  8018c7:	c3                   	ret    

008018c8 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8018c8:	55                   	push   %ebp
  8018c9:	89 e5                	mov    %esp,%ebp
  8018cb:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8018ce:	8b 45 08             	mov    0x8(%ebp),%eax
  8018d1:	8b 40 0c             	mov    0xc(%eax),%eax
  8018d4:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8018d9:	ba 00 00 00 00       	mov    $0x0,%edx
  8018de:	b8 06 00 00 00       	mov    $0x6,%eax
  8018e3:	e8 3c ff ff ff       	call   801824 <fsipc>
}
  8018e8:	c9                   	leave  
  8018e9:	c3                   	ret    

008018ea <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8018ea:	55                   	push   %ebp
  8018eb:	89 e5                	mov    %esp,%ebp
  8018ed:	56                   	push   %esi
  8018ee:	53                   	push   %ebx
  8018ef:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8018f2:	8b 45 08             	mov    0x8(%ebp),%eax
  8018f5:	8b 40 0c             	mov    0xc(%eax),%eax
  8018f8:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8018fd:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801903:	ba 00 00 00 00       	mov    $0x0,%edx
  801908:	b8 03 00 00 00       	mov    $0x3,%eax
  80190d:	e8 12 ff ff ff       	call   801824 <fsipc>
  801912:	89 c3                	mov    %eax,%ebx
  801914:	85 c0                	test   %eax,%eax
  801916:	78 4b                	js     801963 <devfile_read+0x79>
		return r;
	assert(r <= n);
  801918:	39 c6                	cmp    %eax,%esi
  80191a:	73 16                	jae    801932 <devfile_read+0x48>
  80191c:	68 d8 27 80 00       	push   $0x8027d8
  801921:	68 df 27 80 00       	push   $0x8027df
  801926:	6a 7d                	push   $0x7d
  801928:	68 f4 27 80 00       	push   $0x8027f4
  80192d:	e8 2e e8 ff ff       	call   800160 <_panic>
	assert(r <= PGSIZE);
  801932:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801937:	7e 16                	jle    80194f <devfile_read+0x65>
  801939:	68 ff 27 80 00       	push   $0x8027ff
  80193e:	68 df 27 80 00       	push   $0x8027df
  801943:	6a 7e                	push   $0x7e
  801945:	68 f4 27 80 00       	push   $0x8027f4
  80194a:	e8 11 e8 ff ff       	call   800160 <_panic>
	memmove(buf, &fsipcbuf, r);
  80194f:	83 ec 04             	sub    $0x4,%esp
  801952:	50                   	push   %eax
  801953:	68 00 50 80 00       	push   $0x805000
  801958:	ff 75 0c             	pushl  0xc(%ebp)
  80195b:	e8 4f f0 ff ff       	call   8009af <memmove>
	return r;
  801960:	83 c4 10             	add    $0x10,%esp
}
  801963:	89 d8                	mov    %ebx,%eax
  801965:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801968:	5b                   	pop    %ebx
  801969:	5e                   	pop    %esi
  80196a:	c9                   	leave  
  80196b:	c3                   	ret    

0080196c <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  80196c:	55                   	push   %ebp
  80196d:	89 e5                	mov    %esp,%ebp
  80196f:	56                   	push   %esi
  801970:	53                   	push   %ebx
  801971:	83 ec 1c             	sub    $0x1c,%esp
  801974:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801977:	56                   	push   %esi
  801978:	e8 1f ee ff ff       	call   80079c <strlen>
  80197d:	83 c4 10             	add    $0x10,%esp
  801980:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801985:	7f 65                	jg     8019ec <open+0x80>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801987:	83 ec 0c             	sub    $0xc,%esp
  80198a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80198d:	50                   	push   %eax
  80198e:	e8 e1 f8 ff ff       	call   801274 <fd_alloc>
  801993:	89 c3                	mov    %eax,%ebx
  801995:	83 c4 10             	add    $0x10,%esp
  801998:	85 c0                	test   %eax,%eax
  80199a:	78 55                	js     8019f1 <open+0x85>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  80199c:	83 ec 08             	sub    $0x8,%esp
  80199f:	56                   	push   %esi
  8019a0:	68 00 50 80 00       	push   $0x805000
  8019a5:	e8 44 ee ff ff       	call   8007ee <strcpy>
	fsipcbuf.open.req_omode = mode;
  8019aa:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019ad:	a3 00 54 80 00       	mov    %eax,0x805400



	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8019b2:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8019b5:	b8 01 00 00 00       	mov    $0x1,%eax
  8019ba:	e8 65 fe ff ff       	call   801824 <fsipc>
  8019bf:	89 c3                	mov    %eax,%ebx
  8019c1:	83 c4 10             	add    $0x10,%esp
  8019c4:	85 c0                	test   %eax,%eax
  8019c6:	79 12                	jns    8019da <open+0x6e>
		fd_close(fd, 0);
  8019c8:	83 ec 08             	sub    $0x8,%esp
  8019cb:	6a 00                	push   $0x0
  8019cd:	ff 75 f4             	pushl  -0xc(%ebp)
  8019d0:	e8 ce f9 ff ff       	call   8013a3 <fd_close>
		return r;
  8019d5:	83 c4 10             	add    $0x10,%esp
  8019d8:	eb 17                	jmp    8019f1 <open+0x85>
	}

	return fd2num(fd);
  8019da:	83 ec 0c             	sub    $0xc,%esp
  8019dd:	ff 75 f4             	pushl  -0xc(%ebp)
  8019e0:	e8 67 f8 ff ff       	call   80124c <fd2num>
  8019e5:	89 c3                	mov    %eax,%ebx
  8019e7:	83 c4 10             	add    $0x10,%esp
  8019ea:	eb 05                	jmp    8019f1 <open+0x85>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8019ec:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8019f1:	89 d8                	mov    %ebx,%eax
  8019f3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8019f6:	5b                   	pop    %ebx
  8019f7:	5e                   	pop    %esi
  8019f8:	c9                   	leave  
  8019f9:	c3                   	ret    
	...

008019fc <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8019fc:	55                   	push   %ebp
  8019fd:	89 e5                	mov    %esp,%ebp
  8019ff:	56                   	push   %esi
  801a00:	53                   	push   %ebx
  801a01:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801a04:	83 ec 0c             	sub    $0xc,%esp
  801a07:	ff 75 08             	pushl  0x8(%ebp)
  801a0a:	e8 4d f8 ff ff       	call   80125c <fd2data>
  801a0f:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  801a11:	83 c4 08             	add    $0x8,%esp
  801a14:	68 0b 28 80 00       	push   $0x80280b
  801a19:	56                   	push   %esi
  801a1a:	e8 cf ed ff ff       	call   8007ee <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801a1f:	8b 43 04             	mov    0x4(%ebx),%eax
  801a22:	2b 03                	sub    (%ebx),%eax
  801a24:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  801a2a:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  801a31:	00 00 00 
	stat->st_dev = &devpipe;
  801a34:	c7 86 88 00 00 00 20 	movl   $0x803020,0x88(%esi)
  801a3b:	30 80 00 
	return 0;
}
  801a3e:	b8 00 00 00 00       	mov    $0x0,%eax
  801a43:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a46:	5b                   	pop    %ebx
  801a47:	5e                   	pop    %esi
  801a48:	c9                   	leave  
  801a49:	c3                   	ret    

00801a4a <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801a4a:	55                   	push   %ebp
  801a4b:	89 e5                	mov    %esp,%ebp
  801a4d:	53                   	push   %ebx
  801a4e:	83 ec 0c             	sub    $0xc,%esp
  801a51:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801a54:	53                   	push   %ebx
  801a55:	6a 00                	push   $0x0
  801a57:	e8 5e f2 ff ff       	call   800cba <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801a5c:	89 1c 24             	mov    %ebx,(%esp)
  801a5f:	e8 f8 f7 ff ff       	call   80125c <fd2data>
  801a64:	83 c4 08             	add    $0x8,%esp
  801a67:	50                   	push   %eax
  801a68:	6a 00                	push   $0x0
  801a6a:	e8 4b f2 ff ff       	call   800cba <sys_page_unmap>
}
  801a6f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a72:	c9                   	leave  
  801a73:	c3                   	ret    

00801a74 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801a74:	55                   	push   %ebp
  801a75:	89 e5                	mov    %esp,%ebp
  801a77:	57                   	push   %edi
  801a78:	56                   	push   %esi
  801a79:	53                   	push   %ebx
  801a7a:	83 ec 1c             	sub    $0x1c,%esp
  801a7d:	89 c7                	mov    %eax,%edi
  801a7f:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801a82:	a1 04 40 80 00       	mov    0x804004,%eax
  801a87:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801a8a:	83 ec 0c             	sub    $0xc,%esp
  801a8d:	57                   	push   %edi
  801a8e:	e8 01 05 00 00       	call   801f94 <pageref>
  801a93:	89 c6                	mov    %eax,%esi
  801a95:	83 c4 04             	add    $0x4,%esp
  801a98:	ff 75 e4             	pushl  -0x1c(%ebp)
  801a9b:	e8 f4 04 00 00       	call   801f94 <pageref>
  801aa0:	83 c4 10             	add    $0x10,%esp
  801aa3:	39 c6                	cmp    %eax,%esi
  801aa5:	0f 94 c0             	sete   %al
  801aa8:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  801aab:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801ab1:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801ab4:	39 cb                	cmp    %ecx,%ebx
  801ab6:	75 08                	jne    801ac0 <_pipeisclosed+0x4c>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  801ab8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801abb:	5b                   	pop    %ebx
  801abc:	5e                   	pop    %esi
  801abd:	5f                   	pop    %edi
  801abe:	c9                   	leave  
  801abf:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  801ac0:	83 f8 01             	cmp    $0x1,%eax
  801ac3:	75 bd                	jne    801a82 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801ac5:	8b 42 58             	mov    0x58(%edx),%eax
  801ac8:	6a 01                	push   $0x1
  801aca:	50                   	push   %eax
  801acb:	53                   	push   %ebx
  801acc:	68 12 28 80 00       	push   $0x802812
  801ad1:	e8 62 e7 ff ff       	call   800238 <cprintf>
  801ad6:	83 c4 10             	add    $0x10,%esp
  801ad9:	eb a7                	jmp    801a82 <_pipeisclosed+0xe>

00801adb <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801adb:	55                   	push   %ebp
  801adc:	89 e5                	mov    %esp,%ebp
  801ade:	57                   	push   %edi
  801adf:	56                   	push   %esi
  801ae0:	53                   	push   %ebx
  801ae1:	83 ec 28             	sub    $0x28,%esp
  801ae4:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801ae7:	56                   	push   %esi
  801ae8:	e8 6f f7 ff ff       	call   80125c <fd2data>
  801aed:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801aef:	83 c4 10             	add    $0x10,%esp
  801af2:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801af6:	75 4a                	jne    801b42 <devpipe_write+0x67>
  801af8:	bf 00 00 00 00       	mov    $0x0,%edi
  801afd:	eb 56                	jmp    801b55 <devpipe_write+0x7a>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801aff:	89 da                	mov    %ebx,%edx
  801b01:	89 f0                	mov    %esi,%eax
  801b03:	e8 6c ff ff ff       	call   801a74 <_pipeisclosed>
  801b08:	85 c0                	test   %eax,%eax
  801b0a:	75 4d                	jne    801b59 <devpipe_write+0x7e>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801b0c:	e8 38 f1 ff ff       	call   800c49 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801b11:	8b 43 04             	mov    0x4(%ebx),%eax
  801b14:	8b 13                	mov    (%ebx),%edx
  801b16:	83 c2 20             	add    $0x20,%edx
  801b19:	39 d0                	cmp    %edx,%eax
  801b1b:	73 e2                	jae    801aff <devpipe_write+0x24>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801b1d:	89 c2                	mov    %eax,%edx
  801b1f:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  801b25:	79 05                	jns    801b2c <devpipe_write+0x51>
  801b27:	4a                   	dec    %edx
  801b28:	83 ca e0             	or     $0xffffffe0,%edx
  801b2b:	42                   	inc    %edx
  801b2c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b2f:	8a 0c 39             	mov    (%ecx,%edi,1),%cl
  801b32:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801b36:	40                   	inc    %eax
  801b37:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b3a:	47                   	inc    %edi
  801b3b:	39 7d 10             	cmp    %edi,0x10(%ebp)
  801b3e:	77 07                	ja     801b47 <devpipe_write+0x6c>
  801b40:	eb 13                	jmp    801b55 <devpipe_write+0x7a>
  801b42:	bf 00 00 00 00       	mov    $0x0,%edi
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801b47:	8b 43 04             	mov    0x4(%ebx),%eax
  801b4a:	8b 13                	mov    (%ebx),%edx
  801b4c:	83 c2 20             	add    $0x20,%edx
  801b4f:	39 d0                	cmp    %edx,%eax
  801b51:	73 ac                	jae    801aff <devpipe_write+0x24>
  801b53:	eb c8                	jmp    801b1d <devpipe_write+0x42>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801b55:	89 f8                	mov    %edi,%eax
  801b57:	eb 05                	jmp    801b5e <devpipe_write+0x83>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801b59:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801b5e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b61:	5b                   	pop    %ebx
  801b62:	5e                   	pop    %esi
  801b63:	5f                   	pop    %edi
  801b64:	c9                   	leave  
  801b65:	c3                   	ret    

00801b66 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801b66:	55                   	push   %ebp
  801b67:	89 e5                	mov    %esp,%ebp
  801b69:	57                   	push   %edi
  801b6a:	56                   	push   %esi
  801b6b:	53                   	push   %ebx
  801b6c:	83 ec 18             	sub    $0x18,%esp
  801b6f:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801b72:	57                   	push   %edi
  801b73:	e8 e4 f6 ff ff       	call   80125c <fd2data>
  801b78:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b7a:	83 c4 10             	add    $0x10,%esp
  801b7d:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801b81:	75 44                	jne    801bc7 <devpipe_read+0x61>
  801b83:	be 00 00 00 00       	mov    $0x0,%esi
  801b88:	eb 4f                	jmp    801bd9 <devpipe_read+0x73>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
				return i;
  801b8a:	89 f0                	mov    %esi,%eax
  801b8c:	eb 54                	jmp    801be2 <devpipe_read+0x7c>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801b8e:	89 da                	mov    %ebx,%edx
  801b90:	89 f8                	mov    %edi,%eax
  801b92:	e8 dd fe ff ff       	call   801a74 <_pipeisclosed>
  801b97:	85 c0                	test   %eax,%eax
  801b99:	75 42                	jne    801bdd <devpipe_read+0x77>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801b9b:	e8 a9 f0 ff ff       	call   800c49 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801ba0:	8b 03                	mov    (%ebx),%eax
  801ba2:	3b 43 04             	cmp    0x4(%ebx),%eax
  801ba5:	74 e7                	je     801b8e <devpipe_read+0x28>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801ba7:	25 1f 00 00 80       	and    $0x8000001f,%eax
  801bac:	79 05                	jns    801bb3 <devpipe_read+0x4d>
  801bae:	48                   	dec    %eax
  801baf:	83 c8 e0             	or     $0xffffffe0,%eax
  801bb2:	40                   	inc    %eax
  801bb3:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  801bb7:	8b 55 0c             	mov    0xc(%ebp),%edx
  801bba:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  801bbd:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801bbf:	46                   	inc    %esi
  801bc0:	39 75 10             	cmp    %esi,0x10(%ebp)
  801bc3:	77 07                	ja     801bcc <devpipe_read+0x66>
  801bc5:	eb 12                	jmp    801bd9 <devpipe_read+0x73>
  801bc7:	be 00 00 00 00       	mov    $0x0,%esi
		while (p->p_rpos == p->p_wpos) {
  801bcc:	8b 03                	mov    (%ebx),%eax
  801bce:	3b 43 04             	cmp    0x4(%ebx),%eax
  801bd1:	75 d4                	jne    801ba7 <devpipe_read+0x41>
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801bd3:	85 f6                	test   %esi,%esi
  801bd5:	75 b3                	jne    801b8a <devpipe_read+0x24>
  801bd7:	eb b5                	jmp    801b8e <devpipe_read+0x28>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801bd9:	89 f0                	mov    %esi,%eax
  801bdb:	eb 05                	jmp    801be2 <devpipe_read+0x7c>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801bdd:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801be2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801be5:	5b                   	pop    %ebx
  801be6:	5e                   	pop    %esi
  801be7:	5f                   	pop    %edi
  801be8:	c9                   	leave  
  801be9:	c3                   	ret    

00801bea <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801bea:	55                   	push   %ebp
  801beb:	89 e5                	mov    %esp,%ebp
  801bed:	57                   	push   %edi
  801bee:	56                   	push   %esi
  801bef:	53                   	push   %ebx
  801bf0:	83 ec 28             	sub    $0x28,%esp
  801bf3:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801bf6:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801bf9:	50                   	push   %eax
  801bfa:	e8 75 f6 ff ff       	call   801274 <fd_alloc>
  801bff:	89 c3                	mov    %eax,%ebx
  801c01:	83 c4 10             	add    $0x10,%esp
  801c04:	85 c0                	test   %eax,%eax
  801c06:	0f 88 24 01 00 00    	js     801d30 <pipe+0x146>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c0c:	83 ec 04             	sub    $0x4,%esp
  801c0f:	68 07 04 00 00       	push   $0x407
  801c14:	ff 75 e4             	pushl  -0x1c(%ebp)
  801c17:	6a 00                	push   $0x0
  801c19:	e8 52 f0 ff ff       	call   800c70 <sys_page_alloc>
  801c1e:	89 c3                	mov    %eax,%ebx
  801c20:	83 c4 10             	add    $0x10,%esp
  801c23:	85 c0                	test   %eax,%eax
  801c25:	0f 88 05 01 00 00    	js     801d30 <pipe+0x146>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801c2b:	83 ec 0c             	sub    $0xc,%esp
  801c2e:	8d 45 e0             	lea    -0x20(%ebp),%eax
  801c31:	50                   	push   %eax
  801c32:	e8 3d f6 ff ff       	call   801274 <fd_alloc>
  801c37:	89 c3                	mov    %eax,%ebx
  801c39:	83 c4 10             	add    $0x10,%esp
  801c3c:	85 c0                	test   %eax,%eax
  801c3e:	0f 88 dc 00 00 00    	js     801d20 <pipe+0x136>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c44:	83 ec 04             	sub    $0x4,%esp
  801c47:	68 07 04 00 00       	push   $0x407
  801c4c:	ff 75 e0             	pushl  -0x20(%ebp)
  801c4f:	6a 00                	push   $0x0
  801c51:	e8 1a f0 ff ff       	call   800c70 <sys_page_alloc>
  801c56:	89 c3                	mov    %eax,%ebx
  801c58:	83 c4 10             	add    $0x10,%esp
  801c5b:	85 c0                	test   %eax,%eax
  801c5d:	0f 88 bd 00 00 00    	js     801d20 <pipe+0x136>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801c63:	83 ec 0c             	sub    $0xc,%esp
  801c66:	ff 75 e4             	pushl  -0x1c(%ebp)
  801c69:	e8 ee f5 ff ff       	call   80125c <fd2data>
  801c6e:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c70:	83 c4 0c             	add    $0xc,%esp
  801c73:	68 07 04 00 00       	push   $0x407
  801c78:	50                   	push   %eax
  801c79:	6a 00                	push   $0x0
  801c7b:	e8 f0 ef ff ff       	call   800c70 <sys_page_alloc>
  801c80:	89 c3                	mov    %eax,%ebx
  801c82:	83 c4 10             	add    $0x10,%esp
  801c85:	85 c0                	test   %eax,%eax
  801c87:	0f 88 83 00 00 00    	js     801d10 <pipe+0x126>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c8d:	83 ec 0c             	sub    $0xc,%esp
  801c90:	ff 75 e0             	pushl  -0x20(%ebp)
  801c93:	e8 c4 f5 ff ff       	call   80125c <fd2data>
  801c98:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801c9f:	50                   	push   %eax
  801ca0:	6a 00                	push   $0x0
  801ca2:	56                   	push   %esi
  801ca3:	6a 00                	push   $0x0
  801ca5:	e8 ea ef ff ff       	call   800c94 <sys_page_map>
  801caa:	89 c3                	mov    %eax,%ebx
  801cac:	83 c4 20             	add    $0x20,%esp
  801caf:	85 c0                	test   %eax,%eax
  801cb1:	78 4f                	js     801d02 <pipe+0x118>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801cb3:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801cb9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801cbc:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801cbe:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801cc1:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801cc8:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801cce:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801cd1:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801cd3:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801cd6:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801cdd:	83 ec 0c             	sub    $0xc,%esp
  801ce0:	ff 75 e4             	pushl  -0x1c(%ebp)
  801ce3:	e8 64 f5 ff ff       	call   80124c <fd2num>
  801ce8:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  801cea:	83 c4 04             	add    $0x4,%esp
  801ced:	ff 75 e0             	pushl  -0x20(%ebp)
  801cf0:	e8 57 f5 ff ff       	call   80124c <fd2num>
  801cf5:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  801cf8:	83 c4 10             	add    $0x10,%esp
  801cfb:	bb 00 00 00 00       	mov    $0x0,%ebx
  801d00:	eb 2e                	jmp    801d30 <pipe+0x146>

    err3:
	sys_page_unmap(0, va);
  801d02:	83 ec 08             	sub    $0x8,%esp
  801d05:	56                   	push   %esi
  801d06:	6a 00                	push   $0x0
  801d08:	e8 ad ef ff ff       	call   800cba <sys_page_unmap>
  801d0d:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801d10:	83 ec 08             	sub    $0x8,%esp
  801d13:	ff 75 e0             	pushl  -0x20(%ebp)
  801d16:	6a 00                	push   $0x0
  801d18:	e8 9d ef ff ff       	call   800cba <sys_page_unmap>
  801d1d:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801d20:	83 ec 08             	sub    $0x8,%esp
  801d23:	ff 75 e4             	pushl  -0x1c(%ebp)
  801d26:	6a 00                	push   $0x0
  801d28:	e8 8d ef ff ff       	call   800cba <sys_page_unmap>
  801d2d:	83 c4 10             	add    $0x10,%esp
    err:
	return r;
}
  801d30:	89 d8                	mov    %ebx,%eax
  801d32:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d35:	5b                   	pop    %ebx
  801d36:	5e                   	pop    %esi
  801d37:	5f                   	pop    %edi
  801d38:	c9                   	leave  
  801d39:	c3                   	ret    

00801d3a <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801d3a:	55                   	push   %ebp
  801d3b:	89 e5                	mov    %esp,%ebp
  801d3d:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801d40:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d43:	50                   	push   %eax
  801d44:	ff 75 08             	pushl  0x8(%ebp)
  801d47:	e8 9b f5 ff ff       	call   8012e7 <fd_lookup>
  801d4c:	83 c4 10             	add    $0x10,%esp
  801d4f:	85 c0                	test   %eax,%eax
  801d51:	78 18                	js     801d6b <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801d53:	83 ec 0c             	sub    $0xc,%esp
  801d56:	ff 75 f4             	pushl  -0xc(%ebp)
  801d59:	e8 fe f4 ff ff       	call   80125c <fd2data>
	return _pipeisclosed(fd, p);
  801d5e:	89 c2                	mov    %eax,%edx
  801d60:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d63:	e8 0c fd ff ff       	call   801a74 <_pipeisclosed>
  801d68:	83 c4 10             	add    $0x10,%esp
}
  801d6b:	c9                   	leave  
  801d6c:	c3                   	ret    
  801d6d:	00 00                	add    %al,(%eax)
	...

00801d70 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801d70:	55                   	push   %ebp
  801d71:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801d73:	b8 00 00 00 00       	mov    $0x0,%eax
  801d78:	c9                   	leave  
  801d79:	c3                   	ret    

00801d7a <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801d7a:	55                   	push   %ebp
  801d7b:	89 e5                	mov    %esp,%ebp
  801d7d:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801d80:	68 2a 28 80 00       	push   $0x80282a
  801d85:	ff 75 0c             	pushl  0xc(%ebp)
  801d88:	e8 61 ea ff ff       	call   8007ee <strcpy>
	return 0;
}
  801d8d:	b8 00 00 00 00       	mov    $0x0,%eax
  801d92:	c9                   	leave  
  801d93:	c3                   	ret    

00801d94 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801d94:	55                   	push   %ebp
  801d95:	89 e5                	mov    %esp,%ebp
  801d97:	57                   	push   %edi
  801d98:	56                   	push   %esi
  801d99:	53                   	push   %ebx
  801d9a:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801da0:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801da4:	74 45                	je     801deb <devcons_write+0x57>
  801da6:	b8 00 00 00 00       	mov    $0x0,%eax
  801dab:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801db0:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801db6:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801db9:	29 c3                	sub    %eax,%ebx
		if (m > sizeof(buf) - 1)
  801dbb:	83 fb 7f             	cmp    $0x7f,%ebx
  801dbe:	76 05                	jbe    801dc5 <devcons_write+0x31>
			m = sizeof(buf) - 1;
  801dc0:	bb 7f 00 00 00       	mov    $0x7f,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  801dc5:	83 ec 04             	sub    $0x4,%esp
  801dc8:	53                   	push   %ebx
  801dc9:	03 45 0c             	add    0xc(%ebp),%eax
  801dcc:	50                   	push   %eax
  801dcd:	57                   	push   %edi
  801dce:	e8 dc eb ff ff       	call   8009af <memmove>
		sys_cputs(buf, m);
  801dd3:	83 c4 08             	add    $0x8,%esp
  801dd6:	53                   	push   %ebx
  801dd7:	57                   	push   %edi
  801dd8:	e8 dc ed ff ff       	call   800bb9 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801ddd:	01 de                	add    %ebx,%esi
  801ddf:	89 f0                	mov    %esi,%eax
  801de1:	83 c4 10             	add    $0x10,%esp
  801de4:	3b 75 10             	cmp    0x10(%ebp),%esi
  801de7:	72 cd                	jb     801db6 <devcons_write+0x22>
  801de9:	eb 05                	jmp    801df0 <devcons_write+0x5c>
  801deb:	be 00 00 00 00       	mov    $0x0,%esi
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801df0:	89 f0                	mov    %esi,%eax
  801df2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801df5:	5b                   	pop    %ebx
  801df6:	5e                   	pop    %esi
  801df7:	5f                   	pop    %edi
  801df8:	c9                   	leave  
  801df9:	c3                   	ret    

00801dfa <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801dfa:	55                   	push   %ebp
  801dfb:	89 e5                	mov    %esp,%ebp
  801dfd:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  801e00:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801e04:	75 07                	jne    801e0d <devcons_read+0x13>
  801e06:	eb 25                	jmp    801e2d <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801e08:	e8 3c ee ff ff       	call   800c49 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801e0d:	e8 cd ed ff ff       	call   800bdf <sys_cgetc>
  801e12:	85 c0                	test   %eax,%eax
  801e14:	74 f2                	je     801e08 <devcons_read+0xe>
  801e16:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  801e18:	85 c0                	test   %eax,%eax
  801e1a:	78 1d                	js     801e39 <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801e1c:	83 f8 04             	cmp    $0x4,%eax
  801e1f:	74 13                	je     801e34 <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  801e21:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e24:	88 10                	mov    %dl,(%eax)
	return 1;
  801e26:	b8 01 00 00 00       	mov    $0x1,%eax
  801e2b:	eb 0c                	jmp    801e39 <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  801e2d:	b8 00 00 00 00       	mov    $0x0,%eax
  801e32:	eb 05                	jmp    801e39 <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801e34:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801e39:	c9                   	leave  
  801e3a:	c3                   	ret    

00801e3b <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801e3b:	55                   	push   %ebp
  801e3c:	89 e5                	mov    %esp,%ebp
  801e3e:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801e41:	8b 45 08             	mov    0x8(%ebp),%eax
  801e44:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801e47:	6a 01                	push   $0x1
  801e49:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801e4c:	50                   	push   %eax
  801e4d:	e8 67 ed ff ff       	call   800bb9 <sys_cputs>
  801e52:	83 c4 10             	add    $0x10,%esp
}
  801e55:	c9                   	leave  
  801e56:	c3                   	ret    

00801e57 <getchar>:

int
getchar(void)
{
  801e57:	55                   	push   %ebp
  801e58:	89 e5                	mov    %esp,%ebp
  801e5a:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801e5d:	6a 01                	push   $0x1
  801e5f:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801e62:	50                   	push   %eax
  801e63:	6a 00                	push   $0x0
  801e65:	e8 fe f6 ff ff       	call   801568 <read>
	if (r < 0)
  801e6a:	83 c4 10             	add    $0x10,%esp
  801e6d:	85 c0                	test   %eax,%eax
  801e6f:	78 0f                	js     801e80 <getchar+0x29>
		return r;
	if (r < 1)
  801e71:	85 c0                	test   %eax,%eax
  801e73:	7e 06                	jle    801e7b <getchar+0x24>
		return -E_EOF;
	return c;
  801e75:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801e79:	eb 05                	jmp    801e80 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801e7b:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801e80:	c9                   	leave  
  801e81:	c3                   	ret    

00801e82 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801e82:	55                   	push   %ebp
  801e83:	89 e5                	mov    %esp,%ebp
  801e85:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801e88:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e8b:	50                   	push   %eax
  801e8c:	ff 75 08             	pushl  0x8(%ebp)
  801e8f:	e8 53 f4 ff ff       	call   8012e7 <fd_lookup>
  801e94:	83 c4 10             	add    $0x10,%esp
  801e97:	85 c0                	test   %eax,%eax
  801e99:	78 11                	js     801eac <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801e9b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e9e:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801ea4:	39 10                	cmp    %edx,(%eax)
  801ea6:	0f 94 c0             	sete   %al
  801ea9:	0f b6 c0             	movzbl %al,%eax
}
  801eac:	c9                   	leave  
  801ead:	c3                   	ret    

00801eae <opencons>:

int
opencons(void)
{
  801eae:	55                   	push   %ebp
  801eaf:	89 e5                	mov    %esp,%ebp
  801eb1:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801eb4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801eb7:	50                   	push   %eax
  801eb8:	e8 b7 f3 ff ff       	call   801274 <fd_alloc>
  801ebd:	83 c4 10             	add    $0x10,%esp
  801ec0:	85 c0                	test   %eax,%eax
  801ec2:	78 3a                	js     801efe <opencons+0x50>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801ec4:	83 ec 04             	sub    $0x4,%esp
  801ec7:	68 07 04 00 00       	push   $0x407
  801ecc:	ff 75 f4             	pushl  -0xc(%ebp)
  801ecf:	6a 00                	push   $0x0
  801ed1:	e8 9a ed ff ff       	call   800c70 <sys_page_alloc>
  801ed6:	83 c4 10             	add    $0x10,%esp
  801ed9:	85 c0                	test   %eax,%eax
  801edb:	78 21                	js     801efe <opencons+0x50>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801edd:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801ee3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ee6:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801ee8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801eeb:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801ef2:	83 ec 0c             	sub    $0xc,%esp
  801ef5:	50                   	push   %eax
  801ef6:	e8 51 f3 ff ff       	call   80124c <fd2num>
  801efb:	83 c4 10             	add    $0x10,%esp
}
  801efe:	c9                   	leave  
  801eff:	c3                   	ret    

00801f00 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801f00:	55                   	push   %ebp
  801f01:	89 e5                	mov    %esp,%ebp
  801f03:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  801f06:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801f0d:	75 52                	jne    801f61 <set_pgfault_handler+0x61>
		// First time through!	
		// LAB 4: Your code here.

		//int sys_page_alloc(envid_t envid, void *va, int perm)
		r = sys_page_alloc(0, (void*)(UXSTACKTOP - PGSIZE), PTE_U | PTE_W | PTE_P);
  801f0f:	83 ec 04             	sub    $0x4,%esp
  801f12:	6a 07                	push   $0x7
  801f14:	68 00 f0 bf ee       	push   $0xeebff000
  801f19:	6a 00                	push   $0x0
  801f1b:	e8 50 ed ff ff       	call   800c70 <sys_page_alloc>
		if (r < 0) {
  801f20:	83 c4 10             	add    $0x10,%esp
  801f23:	85 c0                	test   %eax,%eax
  801f25:	79 12                	jns    801f39 <set_pgfault_handler+0x39>
			panic("sys_page_alloc error : %e\n", r);
  801f27:	50                   	push   %eax
  801f28:	68 36 28 80 00       	push   $0x802836
  801f2d:	6a 24                	push   $0x24
  801f2f:	68 51 28 80 00       	push   $0x802851
  801f34:	e8 27 e2 ff ff       	call   800160 <_panic>
		}

		// how to know envid, put 0, envid2env will help us to get curenv in syscall
		r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);		
  801f39:	83 ec 08             	sub    $0x8,%esp
  801f3c:	68 6c 1f 80 00       	push   $0x801f6c
  801f41:	6a 00                	push   $0x0
  801f43:	e8 db ed ff ff       	call   800d23 <sys_env_set_pgfault_upcall>
		if (r < 0) {
  801f48:	83 c4 10             	add    $0x10,%esp
  801f4b:	85 c0                	test   %eax,%eax
  801f4d:	79 12                	jns    801f61 <set_pgfault_handler+0x61>
			panic("sys_env_set_pgfault_upcall error : %e\n", r);
  801f4f:	50                   	push   %eax
  801f50:	68 60 28 80 00       	push   $0x802860
  801f55:	6a 2a                	push   $0x2a
  801f57:	68 51 28 80 00       	push   $0x802851
  801f5c:	e8 ff e1 ff ff       	call   800160 <_panic>
		}
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801f61:	8b 45 08             	mov    0x8(%ebp),%eax
  801f64:	a3 00 60 80 00       	mov    %eax,0x806000
}
  801f69:	c9                   	leave  
  801f6a:	c3                   	ret    
	...

00801f6c <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801f6c:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801f6d:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  801f72:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801f74:	83 c4 04             	add    $0x4,%esp
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	
	// fix old esp
	movl 0x30(%esp), %eax
  801f77:	8b 44 24 30          	mov    0x30(%esp),%eax
	subl $0x4, %eax
  801f7b:	83 e8 04             	sub    $0x4,%eax
	movl %eax, 0x30(%esp)
  801f7e:	89 44 24 30          	mov    %eax,0x30(%esp)

	// set trap-time %eip
	movl 0x28(%esp), %ebx
  801f82:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	movl %ebx, (%eax)
  801f86:	89 18                	mov    %ebx,(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $0x08, %esp 	// ignore err_code and fault_va
  801f88:	83 c4 08             	add    $0x8,%esp
	popal 				// restore registers
  801f8b:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x04, %esp 	// ignore eip 
  801f8c:	83 c4 04             	add    $0x4,%esp
	popfl				// modify eflags
  801f8f:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  801f90:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  801f91:	c3                   	ret    
	...

00801f94 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801f94:	55                   	push   %ebp
  801f95:	89 e5                	mov    %esp,%ebp
  801f97:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801f9a:	89 c2                	mov    %eax,%edx
  801f9c:	c1 ea 16             	shr    $0x16,%edx
  801f9f:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801fa6:	f6 c2 01             	test   $0x1,%dl
  801fa9:	74 1e                	je     801fc9 <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  801fab:	c1 e8 0c             	shr    $0xc,%eax
  801fae:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801fb5:	a8 01                	test   $0x1,%al
  801fb7:	74 17                	je     801fd0 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801fb9:	c1 e8 0c             	shr    $0xc,%eax
  801fbc:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  801fc3:	ef 
  801fc4:	0f b7 c0             	movzwl %ax,%eax
  801fc7:	eb 0c                	jmp    801fd5 <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  801fc9:	b8 00 00 00 00       	mov    $0x0,%eax
  801fce:	eb 05                	jmp    801fd5 <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  801fd0:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  801fd5:	c9                   	leave  
  801fd6:	c3                   	ret    
	...

00801fd8 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  801fd8:	55                   	push   %ebp
  801fd9:	89 e5                	mov    %esp,%ebp
  801fdb:	57                   	push   %edi
  801fdc:	56                   	push   %esi
  801fdd:	83 ec 10             	sub    $0x10,%esp
  801fe0:	8b 7d 08             	mov    0x8(%ebp),%edi
  801fe3:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  801fe6:	89 7d f0             	mov    %edi,-0x10(%ebp)
  801fe9:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  801fec:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  801fef:	8b 45 14             	mov    0x14(%ebp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  801ff2:	85 c0                	test   %eax,%eax
  801ff4:	75 2e                	jne    802024 <__udivdi3+0x4c>
    {
      if (d0 > n1)
  801ff6:	39 f1                	cmp    %esi,%ecx
  801ff8:	77 5a                	ja     802054 <__udivdi3+0x7c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  801ffa:	85 c9                	test   %ecx,%ecx
  801ffc:	75 0b                	jne    802009 <__udivdi3+0x31>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  801ffe:	b8 01 00 00 00       	mov    $0x1,%eax
  802003:	31 d2                	xor    %edx,%edx
  802005:	f7 f1                	div    %ecx
  802007:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  802009:	31 d2                	xor    %edx,%edx
  80200b:	89 f0                	mov    %esi,%eax
  80200d:	f7 f1                	div    %ecx
  80200f:	89 c6                	mov    %eax,%esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802011:	89 f8                	mov    %edi,%eax
  802013:	f7 f1                	div    %ecx
  802015:	89 c7                	mov    %eax,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  802017:	89 f8                	mov    %edi,%eax
  802019:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  80201b:	83 c4 10             	add    $0x10,%esp
  80201e:	5e                   	pop    %esi
  80201f:	5f                   	pop    %edi
  802020:	c9                   	leave  
  802021:	c3                   	ret    
  802022:	66 90                	xchg   %ax,%ax
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  802024:	39 f0                	cmp    %esi,%eax
  802026:	77 1c                	ja     802044 <__udivdi3+0x6c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  802028:	0f bd f8             	bsr    %eax,%edi
	  if (bm == 0)
  80202b:	83 f7 1f             	xor    $0x1f,%edi
  80202e:	75 3c                	jne    80206c <__udivdi3+0x94>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802030:	39 f0                	cmp    %esi,%eax
  802032:	0f 82 90 00 00 00    	jb     8020c8 <__udivdi3+0xf0>
  802038:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80203b:	39 55 f4             	cmp    %edx,-0xc(%ebp)
  80203e:	0f 86 84 00 00 00    	jbe    8020c8 <__udivdi3+0xf0>
  802044:	31 f6                	xor    %esi,%esi
  802046:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  802048:	89 f8                	mov    %edi,%eax
  80204a:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  80204c:	83 c4 10             	add    $0x10,%esp
  80204f:	5e                   	pop    %esi
  802050:	5f                   	pop    %edi
  802051:	c9                   	leave  
  802052:	c3                   	ret    
  802053:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802054:	89 f2                	mov    %esi,%edx
  802056:	89 f8                	mov    %edi,%eax
  802058:	f7 f1                	div    %ecx
  80205a:	89 c7                	mov    %eax,%edi
  80205c:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  80205e:	89 f8                	mov    %edi,%eax
  802060:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802062:	83 c4 10             	add    $0x10,%esp
  802065:	5e                   	pop    %esi
  802066:	5f                   	pop    %edi
  802067:	c9                   	leave  
  802068:	c3                   	ret    
  802069:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  80206c:	89 f9                	mov    %edi,%ecx
  80206e:	d3 e0                	shl    %cl,%eax
  802070:	89 45 e8             	mov    %eax,-0x18(%ebp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  802073:	b8 20 00 00 00       	mov    $0x20,%eax
  802078:	29 f8                	sub    %edi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  80207a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80207d:	88 c1                	mov    %al,%cl
  80207f:	d3 ea                	shr    %cl,%edx
  802081:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  802084:	09 ca                	or     %ecx,%edx
  802086:	89 55 ec             	mov    %edx,-0x14(%ebp)
	      d0 = d0 << bm;
  802089:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80208c:	89 f9                	mov    %edi,%ecx
  80208e:	d3 e2                	shl    %cl,%edx
  802090:	89 55 f4             	mov    %edx,-0xc(%ebp)
	      n2 = n1 >> b;
  802093:	89 f2                	mov    %esi,%edx
  802095:	88 c1                	mov    %al,%cl
  802097:	d3 ea                	shr    %cl,%edx
  802099:	89 55 e8             	mov    %edx,-0x18(%ebp)
	      n1 = (n1 << bm) | (n0 >> b);
  80209c:	89 f2                	mov    %esi,%edx
  80209e:	89 f9                	mov    %edi,%ecx
  8020a0:	d3 e2                	shl    %cl,%edx
  8020a2:	8b 75 f0             	mov    -0x10(%ebp),%esi
  8020a5:	88 c1                	mov    %al,%cl
  8020a7:	d3 ee                	shr    %cl,%esi
  8020a9:	09 d6                	or     %edx,%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  8020ab:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  8020ae:	89 f0                	mov    %esi,%eax
  8020b0:	89 ca                	mov    %ecx,%edx
  8020b2:	f7 75 ec             	divl   -0x14(%ebp)
  8020b5:	89 d1                	mov    %edx,%ecx
  8020b7:	89 c6                	mov    %eax,%esi
	      umul_ppmm (m1, m0, q0, d0);
  8020b9:	f7 65 f4             	mull   -0xc(%ebp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8020bc:	39 d1                	cmp    %edx,%ecx
  8020be:	72 28                	jb     8020e8 <__udivdi3+0x110>
  8020c0:	74 1a                	je     8020dc <__udivdi3+0x104>
  8020c2:	89 f7                	mov    %esi,%edi
  8020c4:	31 f6                	xor    %esi,%esi
  8020c6:	eb 80                	jmp    802048 <__udivdi3+0x70>
	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  8020c8:	31 f6                	xor    %esi,%esi
  8020ca:	bf 01 00 00 00       	mov    $0x1,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  8020cf:	89 f8                	mov    %edi,%eax
  8020d1:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  8020d3:	83 c4 10             	add    $0x10,%esp
  8020d6:	5e                   	pop    %esi
  8020d7:	5f                   	pop    %edi
  8020d8:	c9                   	leave  
  8020d9:	c3                   	ret    
  8020da:	66 90                	xchg   %ax,%ax

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  8020dc:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8020df:	89 f9                	mov    %edi,%ecx
  8020e1:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8020e3:	39 c2                	cmp    %eax,%edx
  8020e5:	73 db                	jae    8020c2 <__udivdi3+0xea>
  8020e7:	90                   	nop
		{
		  q0--;
  8020e8:	8d 7e ff             	lea    -0x1(%esi),%edi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  8020eb:	31 f6                	xor    %esi,%esi
  8020ed:	e9 56 ff ff ff       	jmp    802048 <__udivdi3+0x70>
	...

008020f4 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  8020f4:	55                   	push   %ebp
  8020f5:	89 e5                	mov    %esp,%ebp
  8020f7:	57                   	push   %edi
  8020f8:	56                   	push   %esi
  8020f9:	83 ec 20             	sub    $0x20,%esp
  8020fc:	8b 45 08             	mov    0x8(%ebp),%eax
  8020ff:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  802102:	89 45 e8             	mov    %eax,-0x18(%ebp)
  802105:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  802108:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  80210b:	8b 7d 14             	mov    0x14(%ebp),%edi
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  80210e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  n1 = nn.s.high;
  802111:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  802113:	85 ff                	test   %edi,%edi
  802115:	75 15                	jne    80212c <__umoddi3+0x38>
    {
      if (d0 > n1)
  802117:	39 f1                	cmp    %esi,%ecx
  802119:	0f 86 99 00 00 00    	jbe    8021b8 <__umoddi3+0xc4>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  80211f:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  802121:	89 d0                	mov    %edx,%eax
  802123:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802125:	83 c4 20             	add    $0x20,%esp
  802128:	5e                   	pop    %esi
  802129:	5f                   	pop    %edi
  80212a:	c9                   	leave  
  80212b:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  80212c:	39 f7                	cmp    %esi,%edi
  80212e:	0f 87 a4 00 00 00    	ja     8021d8 <__umoddi3+0xe4>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  802134:	0f bd c7             	bsr    %edi,%eax
	  if (bm == 0)
  802137:	83 f0 1f             	xor    $0x1f,%eax
  80213a:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80213d:	0f 84 a1 00 00 00    	je     8021e4 <__umoddi3+0xf0>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  802143:	89 f8                	mov    %edi,%eax
  802145:	8a 4d ec             	mov    -0x14(%ebp),%cl
  802148:	d3 e0                	shl    %cl,%eax
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  80214a:	bf 20 00 00 00       	mov    $0x20,%edi
  80214f:	2b 7d ec             	sub    -0x14(%ebp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  802152:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802155:	89 f9                	mov    %edi,%ecx
  802157:	d3 ea                	shr    %cl,%edx
  802159:	09 c2                	or     %eax,%edx
  80215b:	89 55 f0             	mov    %edx,-0x10(%ebp)
	      d0 = d0 << bm;
  80215e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802161:	8a 4d ec             	mov    -0x14(%ebp),%cl
  802164:	d3 e0                	shl    %cl,%eax
  802166:	89 45 f4             	mov    %eax,-0xc(%ebp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  802169:	89 f2                	mov    %esi,%edx
  80216b:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  80216d:	8b 45 e8             	mov    -0x18(%ebp),%eax
  802170:	d3 e0                	shl    %cl,%eax
  802172:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  802175:	8b 45 e8             	mov    -0x18(%ebp),%eax
  802178:	89 f9                	mov    %edi,%ecx
  80217a:	d3 e8                	shr    %cl,%eax
  80217c:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  80217e:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  802180:	89 f2                	mov    %esi,%edx
  802182:	f7 75 f0             	divl   -0x10(%ebp)
  802185:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  802187:	f7 65 f4             	mull   -0xc(%ebp)
  80218a:	89 55 e8             	mov    %edx,-0x18(%ebp)
  80218d:	89 c1                	mov    %eax,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  80218f:	39 d6                	cmp    %edx,%esi
  802191:	72 71                	jb     802204 <__umoddi3+0x110>
  802193:	74 7f                	je     802214 <__umoddi3+0x120>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  802195:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802198:	29 c8                	sub    %ecx,%eax
  80219a:	19 d6                	sbb    %edx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  80219c:	8a 4d ec             	mov    -0x14(%ebp),%cl
  80219f:	d3 e8                	shr    %cl,%eax
  8021a1:	89 f2                	mov    %esi,%edx
  8021a3:	89 f9                	mov    %edi,%ecx
  8021a5:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  8021a7:	09 d0                	or     %edx,%eax
  8021a9:	89 f2                	mov    %esi,%edx
  8021ab:	8a 4d ec             	mov    -0x14(%ebp),%cl
  8021ae:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8021b0:	83 c4 20             	add    $0x20,%esp
  8021b3:	5e                   	pop    %esi
  8021b4:	5f                   	pop    %edi
  8021b5:	c9                   	leave  
  8021b6:	c3                   	ret    
  8021b7:	90                   	nop
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  8021b8:	85 c9                	test   %ecx,%ecx
  8021ba:	75 0b                	jne    8021c7 <__umoddi3+0xd3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  8021bc:	b8 01 00 00 00       	mov    $0x1,%eax
  8021c1:	31 d2                	xor    %edx,%edx
  8021c3:	f7 f1                	div    %ecx
  8021c5:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  8021c7:	89 f0                	mov    %esi,%eax
  8021c9:	31 d2                	xor    %edx,%edx
  8021cb:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8021cd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8021d0:	f7 f1                	div    %ecx
  8021d2:	e9 4a ff ff ff       	jmp    802121 <__umoddi3+0x2d>
  8021d7:	90                   	nop
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  8021d8:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8021da:	83 c4 20             	add    $0x20,%esp
  8021dd:	5e                   	pop    %esi
  8021de:	5f                   	pop    %edi
  8021df:	c9                   	leave  
  8021e0:	c3                   	ret    
  8021e1:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  8021e4:	39 f7                	cmp    %esi,%edi
  8021e6:	72 05                	jb     8021ed <__umoddi3+0xf9>
  8021e8:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
  8021eb:	77 0c                	ja     8021f9 <__umoddi3+0x105>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  8021ed:	89 f2                	mov    %esi,%edx
  8021ef:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8021f2:	29 c8                	sub    %ecx,%eax
  8021f4:	19 fa                	sbb    %edi,%edx
  8021f6:	89 45 f0             	mov    %eax,-0x10(%ebp)

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  8021f9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8021fc:	83 c4 20             	add    $0x20,%esp
  8021ff:	5e                   	pop    %esi
  802200:	5f                   	pop    %edi
  802201:	c9                   	leave  
  802202:	c3                   	ret    
  802203:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  802204:	8b 55 e8             	mov    -0x18(%ebp),%edx
  802207:	89 c1                	mov    %eax,%ecx
  802209:	2b 4d f4             	sub    -0xc(%ebp),%ecx
  80220c:	1b 55 f0             	sbb    -0x10(%ebp),%edx
  80220f:	eb 84                	jmp    802195 <__umoddi3+0xa1>
  802211:	8d 76 00             	lea    0x0(%esi),%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802214:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  802217:	72 eb                	jb     802204 <__umoddi3+0x110>
  802219:	89 f2                	mov    %esi,%edx
  80221b:	e9 75 ff ff ff       	jmp    802195 <__umoddi3+0xa1>
