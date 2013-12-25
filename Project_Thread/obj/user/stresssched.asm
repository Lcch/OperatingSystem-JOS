
obj/user/stresssched.debug:     file format elf32-i386


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
  80002c:	e8 d7 00 00 00       	call   800108 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <umain>:

volatile int counter;

void
umain(int argc, char **argv)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
	int i, j;
	int seen;
	envid_t parent = sys_getenvid();
  800039:	e8 f7 0b 00 00       	call   800c35 <sys_getenvid>
  80003e:	89 c6                	mov    %eax,%esi

	// Fork several environments
	for (i = 0; i < 20; i++)
  800040:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (fork() == 0)
  800045:	e8 b4 0e 00 00       	call   800efe <fork>
  80004a:	85 c0                	test   %eax,%eax
  80004c:	74 08                	je     800056 <umain+0x22>
	int i, j;
	int seen;
	envid_t parent = sys_getenvid();

	// Fork several environments
	for (i = 0; i < 20; i++)
  80004e:	43                   	inc    %ebx
  80004f:	83 fb 14             	cmp    $0x14,%ebx
  800052:	75 f1                	jne    800045 <umain+0x11>
  800054:	eb 25                	jmp    80007b <umain+0x47>
		if (fork() == 0)
			break;
	if (i == 20) {
  800056:	83 fb 14             	cmp    $0x14,%ebx
  800059:	74 20                	je     80007b <umain+0x47>
		sys_yield();
		return;
	}

	// Wait for the parent to finish forking
	while (envs[ENVX(parent)].env_status != ENV_FREE)
  80005b:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
  800061:	89 f0                	mov    %esi,%eax
  800063:	c1 e0 07             	shl    $0x7,%eax
  800066:	8d 84 b0 04 00 c0 ee 	lea    -0x113ffffc(%eax,%esi,4),%eax
  80006d:	8b 40 50             	mov    0x50(%eax),%eax
  800070:	85 c0                	test   %eax,%eax
  800072:	75 0e                	jne    800082 <umain+0x4e>
  800074:	bb 00 00 00 00       	mov    $0x0,%ebx
  800079:	eb 21                	jmp    80009c <umain+0x68>
	// Fork several environments
	for (i = 0; i < 20; i++)
		if (fork() == 0)
			break;
	if (i == 20) {
		sys_yield();
  80007b:	e8 d9 0b 00 00       	call   800c59 <sys_yield>
		return;
  800080:	eb 7f                	jmp    800101 <umain+0xcd>
	}

	// Wait for the parent to finish forking
	while (envs[ENVX(parent)].env_status != ENV_FREE)
  800082:	89 f0                	mov    %esi,%eax
  800084:	c1 e0 07             	shl    $0x7,%eax
  800087:	8d 94 b0 04 00 c0 ee 	lea    -0x113ffffc(%eax,%esi,4),%edx
		asm volatile("pause");
  80008e:	f3 90                	pause  
		sys_yield();
		return;
	}

	// Wait for the parent to finish forking
	while (envs[ENVX(parent)].env_status != ENV_FREE)
  800090:	8b 42 50             	mov    0x50(%edx),%eax
  800093:	85 c0                	test   %eax,%eax
  800095:	75 f7                	jne    80008e <umain+0x5a>
  800097:	bb 00 00 00 00       	mov    $0x0,%ebx
		asm volatile("pause");

	// Check that one environment doesn't run on two CPUs at once
	for (i = 0; i < 10; i++) {
		sys_yield();
  80009c:	e8 b8 0b 00 00       	call   800c59 <sys_yield>
		for (j = 0; j < 10000; j++)
  8000a1:	b8 00 00 00 00       	mov    $0x0,%eax
			counter++;
  8000a6:	8b 15 04 40 80 00    	mov    0x804004,%edx
  8000ac:	42                   	inc    %edx
  8000ad:	89 15 04 40 80 00    	mov    %edx,0x804004
		asm volatile("pause");

	// Check that one environment doesn't run on two CPUs at once
	for (i = 0; i < 10; i++) {
		sys_yield();
		for (j = 0; j < 10000; j++)
  8000b3:	40                   	inc    %eax
  8000b4:	3d 10 27 00 00       	cmp    $0x2710,%eax
  8000b9:	75 eb                	jne    8000a6 <umain+0x72>
	// Wait for the parent to finish forking
	while (envs[ENVX(parent)].env_status != ENV_FREE)
		asm volatile("pause");

	// Check that one environment doesn't run on two CPUs at once
	for (i = 0; i < 10; i++) {
  8000bb:	43                   	inc    %ebx
  8000bc:	83 fb 0a             	cmp    $0xa,%ebx
  8000bf:	75 db                	jne    80009c <umain+0x68>
		sys_yield();
		for (j = 0; j < 10000; j++)
			counter++;
	}

	if (counter != 10*10000)
  8000c1:	a1 04 40 80 00       	mov    0x804004,%eax
  8000c6:	3d a0 86 01 00       	cmp    $0x186a0,%eax
  8000cb:	74 17                	je     8000e4 <umain+0xb0>
		panic("ran on two CPUs at once (counter is %d)", counter);
  8000cd:	a1 04 40 80 00       	mov    0x804004,%eax
  8000d2:	50                   	push   %eax
  8000d3:	68 40 22 80 00       	push   $0x802240
  8000d8:	6a 21                	push   $0x21
  8000da:	68 68 22 80 00       	push   $0x802268
  8000df:	e8 8c 00 00 00       	call   800170 <_panic>

	// Check that we see environments running on different CPUs
	cprintf("[%08x] stresssched on CPU %d\n", thisenv->env_id, thisenv->env_cpunum);
  8000e4:	a1 08 40 80 00       	mov    0x804008,%eax
  8000e9:	8b 50 5c             	mov    0x5c(%eax),%edx
  8000ec:	8b 40 48             	mov    0x48(%eax),%eax
  8000ef:	83 ec 04             	sub    $0x4,%esp
  8000f2:	52                   	push   %edx
  8000f3:	50                   	push   %eax
  8000f4:	68 7b 22 80 00       	push   $0x80227b
  8000f9:	e8 4a 01 00 00       	call   800248 <cprintf>
  8000fe:	83 c4 10             	add    $0x10,%esp

}
  800101:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800104:	5b                   	pop    %ebx
  800105:	5e                   	pop    %esi
  800106:	c9                   	leave  
  800107:	c3                   	ret    

00800108 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800108:	55                   	push   %ebp
  800109:	89 e5                	mov    %esp,%ebp
  80010b:	56                   	push   %esi
  80010c:	53                   	push   %ebx
  80010d:	8b 75 08             	mov    0x8(%ebp),%esi
  800110:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs + ENVX(sys_getenvid());
  800113:	e8 1d 0b 00 00       	call   800c35 <sys_getenvid>
  800118:	25 ff 03 00 00       	and    $0x3ff,%eax
  80011d:	89 c2                	mov    %eax,%edx
  80011f:	c1 e2 07             	shl    $0x7,%edx
  800122:	8d 84 82 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,4),%eax
  800129:	a3 08 40 80 00       	mov    %eax,0x804008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80012e:	85 f6                	test   %esi,%esi
  800130:	7e 07                	jle    800139 <libmain+0x31>
		binaryname = argv[0];
  800132:	8b 03                	mov    (%ebx),%eax
  800134:	a3 00 30 80 00       	mov    %eax,0x803000
	// call user main routine
	umain(argc, argv);
  800139:	83 ec 08             	sub    $0x8,%esp
  80013c:	53                   	push   %ebx
  80013d:	56                   	push   %esi
  80013e:	e8 f1 fe ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  800143:	e8 0c 00 00 00       	call   800154 <exit>
  800148:	83 c4 10             	add    $0x10,%esp
}
  80014b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80014e:	5b                   	pop    %ebx
  80014f:	5e                   	pop    %esi
  800150:	c9                   	leave  
  800151:	c3                   	ret    
	...

00800154 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800154:	55                   	push   %ebp
  800155:	89 e5                	mov    %esp,%ebp
  800157:	83 ec 08             	sub    $0x8,%esp
	close_all();
  80015a:	e8 ef 11 00 00       	call   80134e <close_all>
	sys_env_destroy(0);
  80015f:	83 ec 0c             	sub    $0xc,%esp
  800162:	6a 00                	push   $0x0
  800164:	e8 aa 0a 00 00       	call   800c13 <sys_env_destroy>
  800169:	83 c4 10             	add    $0x10,%esp
}
  80016c:	c9                   	leave  
  80016d:	c3                   	ret    
	...

00800170 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800170:	55                   	push   %ebp
  800171:	89 e5                	mov    %esp,%ebp
  800173:	56                   	push   %esi
  800174:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800175:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800178:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  80017e:	e8 b2 0a 00 00       	call   800c35 <sys_getenvid>
  800183:	83 ec 0c             	sub    $0xc,%esp
  800186:	ff 75 0c             	pushl  0xc(%ebp)
  800189:	ff 75 08             	pushl  0x8(%ebp)
  80018c:	53                   	push   %ebx
  80018d:	50                   	push   %eax
  80018e:	68 a4 22 80 00       	push   $0x8022a4
  800193:	e8 b0 00 00 00       	call   800248 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800198:	83 c4 18             	add    $0x18,%esp
  80019b:	56                   	push   %esi
  80019c:	ff 75 10             	pushl  0x10(%ebp)
  80019f:	e8 53 00 00 00       	call   8001f7 <vcprintf>
	cprintf("\n");
  8001a4:	c7 04 24 97 22 80 00 	movl   $0x802297,(%esp)
  8001ab:	e8 98 00 00 00       	call   800248 <cprintf>
  8001b0:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8001b3:	cc                   	int3   
  8001b4:	eb fd                	jmp    8001b3 <_panic+0x43>
	...

008001b8 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001b8:	55                   	push   %ebp
  8001b9:	89 e5                	mov    %esp,%ebp
  8001bb:	53                   	push   %ebx
  8001bc:	83 ec 04             	sub    $0x4,%esp
  8001bf:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001c2:	8b 03                	mov    (%ebx),%eax
  8001c4:	8b 55 08             	mov    0x8(%ebp),%edx
  8001c7:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8001cb:	40                   	inc    %eax
  8001cc:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8001ce:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001d3:	75 1a                	jne    8001ef <putch+0x37>
		sys_cputs(b->buf, b->idx);
  8001d5:	83 ec 08             	sub    $0x8,%esp
  8001d8:	68 ff 00 00 00       	push   $0xff
  8001dd:	8d 43 08             	lea    0x8(%ebx),%eax
  8001e0:	50                   	push   %eax
  8001e1:	e8 e3 09 00 00       	call   800bc9 <sys_cputs>
		b->idx = 0;
  8001e6:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001ec:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8001ef:	ff 43 04             	incl   0x4(%ebx)
}
  8001f2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001f5:	c9                   	leave  
  8001f6:	c3                   	ret    

008001f7 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001f7:	55                   	push   %ebp
  8001f8:	89 e5                	mov    %esp,%ebp
  8001fa:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800200:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800207:	00 00 00 
	b.cnt = 0;
  80020a:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800211:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800214:	ff 75 0c             	pushl  0xc(%ebp)
  800217:	ff 75 08             	pushl  0x8(%ebp)
  80021a:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800220:	50                   	push   %eax
  800221:	68 b8 01 80 00       	push   $0x8001b8
  800226:	e8 82 01 00 00       	call   8003ad <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80022b:	83 c4 08             	add    $0x8,%esp
  80022e:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800234:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80023a:	50                   	push   %eax
  80023b:	e8 89 09 00 00       	call   800bc9 <sys_cputs>

	return b.cnt;
}
  800240:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800246:	c9                   	leave  
  800247:	c3                   	ret    

00800248 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800248:	55                   	push   %ebp
  800249:	89 e5                	mov    %esp,%ebp
  80024b:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80024e:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800251:	50                   	push   %eax
  800252:	ff 75 08             	pushl  0x8(%ebp)
  800255:	e8 9d ff ff ff       	call   8001f7 <vcprintf>
	va_end(ap);

	return cnt;
}
  80025a:	c9                   	leave  
  80025b:	c3                   	ret    

0080025c <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80025c:	55                   	push   %ebp
  80025d:	89 e5                	mov    %esp,%ebp
  80025f:	57                   	push   %edi
  800260:	56                   	push   %esi
  800261:	53                   	push   %ebx
  800262:	83 ec 2c             	sub    $0x2c,%esp
  800265:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800268:	89 d6                	mov    %edx,%esi
  80026a:	8b 45 08             	mov    0x8(%ebp),%eax
  80026d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800270:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800273:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800276:	8b 45 10             	mov    0x10(%ebp),%eax
  800279:	8b 5d 14             	mov    0x14(%ebp),%ebx
  80027c:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80027f:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800282:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  800289:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
  80028c:	72 0c                	jb     80029a <printnum+0x3e>
  80028e:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  800291:	76 07                	jbe    80029a <printnum+0x3e>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800293:	4b                   	dec    %ebx
  800294:	85 db                	test   %ebx,%ebx
  800296:	7f 31                	jg     8002c9 <printnum+0x6d>
  800298:	eb 3f                	jmp    8002d9 <printnum+0x7d>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80029a:	83 ec 0c             	sub    $0xc,%esp
  80029d:	57                   	push   %edi
  80029e:	4b                   	dec    %ebx
  80029f:	53                   	push   %ebx
  8002a0:	50                   	push   %eax
  8002a1:	83 ec 08             	sub    $0x8,%esp
  8002a4:	ff 75 d4             	pushl  -0x2c(%ebp)
  8002a7:	ff 75 d0             	pushl  -0x30(%ebp)
  8002aa:	ff 75 dc             	pushl  -0x24(%ebp)
  8002ad:	ff 75 d8             	pushl  -0x28(%ebp)
  8002b0:	e8 33 1d 00 00       	call   801fe8 <__udivdi3>
  8002b5:	83 c4 18             	add    $0x18,%esp
  8002b8:	52                   	push   %edx
  8002b9:	50                   	push   %eax
  8002ba:	89 f2                	mov    %esi,%edx
  8002bc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8002bf:	e8 98 ff ff ff       	call   80025c <printnum>
  8002c4:	83 c4 20             	add    $0x20,%esp
  8002c7:	eb 10                	jmp    8002d9 <printnum+0x7d>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002c9:	83 ec 08             	sub    $0x8,%esp
  8002cc:	56                   	push   %esi
  8002cd:	57                   	push   %edi
  8002ce:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002d1:	4b                   	dec    %ebx
  8002d2:	83 c4 10             	add    $0x10,%esp
  8002d5:	85 db                	test   %ebx,%ebx
  8002d7:	7f f0                	jg     8002c9 <printnum+0x6d>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002d9:	83 ec 08             	sub    $0x8,%esp
  8002dc:	56                   	push   %esi
  8002dd:	83 ec 04             	sub    $0x4,%esp
  8002e0:	ff 75 d4             	pushl  -0x2c(%ebp)
  8002e3:	ff 75 d0             	pushl  -0x30(%ebp)
  8002e6:	ff 75 dc             	pushl  -0x24(%ebp)
  8002e9:	ff 75 d8             	pushl  -0x28(%ebp)
  8002ec:	e8 13 1e 00 00       	call   802104 <__umoddi3>
  8002f1:	83 c4 14             	add    $0x14,%esp
  8002f4:	0f be 80 c7 22 80 00 	movsbl 0x8022c7(%eax),%eax
  8002fb:	50                   	push   %eax
  8002fc:	ff 55 e4             	call   *-0x1c(%ebp)
  8002ff:	83 c4 10             	add    $0x10,%esp
}
  800302:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800305:	5b                   	pop    %ebx
  800306:	5e                   	pop    %esi
  800307:	5f                   	pop    %edi
  800308:	c9                   	leave  
  800309:	c3                   	ret    

0080030a <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80030a:	55                   	push   %ebp
  80030b:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80030d:	83 fa 01             	cmp    $0x1,%edx
  800310:	7e 0e                	jle    800320 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800312:	8b 10                	mov    (%eax),%edx
  800314:	8d 4a 08             	lea    0x8(%edx),%ecx
  800317:	89 08                	mov    %ecx,(%eax)
  800319:	8b 02                	mov    (%edx),%eax
  80031b:	8b 52 04             	mov    0x4(%edx),%edx
  80031e:	eb 22                	jmp    800342 <getuint+0x38>
	else if (lflag)
  800320:	85 d2                	test   %edx,%edx
  800322:	74 10                	je     800334 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800324:	8b 10                	mov    (%eax),%edx
  800326:	8d 4a 04             	lea    0x4(%edx),%ecx
  800329:	89 08                	mov    %ecx,(%eax)
  80032b:	8b 02                	mov    (%edx),%eax
  80032d:	ba 00 00 00 00       	mov    $0x0,%edx
  800332:	eb 0e                	jmp    800342 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800334:	8b 10                	mov    (%eax),%edx
  800336:	8d 4a 04             	lea    0x4(%edx),%ecx
  800339:	89 08                	mov    %ecx,(%eax)
  80033b:	8b 02                	mov    (%edx),%eax
  80033d:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800342:	c9                   	leave  
  800343:	c3                   	ret    

00800344 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  800344:	55                   	push   %ebp
  800345:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800347:	83 fa 01             	cmp    $0x1,%edx
  80034a:	7e 0e                	jle    80035a <getint+0x16>
		return va_arg(*ap, long long);
  80034c:	8b 10                	mov    (%eax),%edx
  80034e:	8d 4a 08             	lea    0x8(%edx),%ecx
  800351:	89 08                	mov    %ecx,(%eax)
  800353:	8b 02                	mov    (%edx),%eax
  800355:	8b 52 04             	mov    0x4(%edx),%edx
  800358:	eb 1a                	jmp    800374 <getint+0x30>
	else if (lflag)
  80035a:	85 d2                	test   %edx,%edx
  80035c:	74 0c                	je     80036a <getint+0x26>
		return va_arg(*ap, long);
  80035e:	8b 10                	mov    (%eax),%edx
  800360:	8d 4a 04             	lea    0x4(%edx),%ecx
  800363:	89 08                	mov    %ecx,(%eax)
  800365:	8b 02                	mov    (%edx),%eax
  800367:	99                   	cltd   
  800368:	eb 0a                	jmp    800374 <getint+0x30>
	else
		return va_arg(*ap, int);
  80036a:	8b 10                	mov    (%eax),%edx
  80036c:	8d 4a 04             	lea    0x4(%edx),%ecx
  80036f:	89 08                	mov    %ecx,(%eax)
  800371:	8b 02                	mov    (%edx),%eax
  800373:	99                   	cltd   
}
  800374:	c9                   	leave  
  800375:	c3                   	ret    

00800376 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800376:	55                   	push   %ebp
  800377:	89 e5                	mov    %esp,%ebp
  800379:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80037c:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  80037f:	8b 10                	mov    (%eax),%edx
  800381:	3b 50 04             	cmp    0x4(%eax),%edx
  800384:	73 08                	jae    80038e <sprintputch+0x18>
		*b->buf++ = ch;
  800386:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800389:	88 0a                	mov    %cl,(%edx)
  80038b:	42                   	inc    %edx
  80038c:	89 10                	mov    %edx,(%eax)
}
  80038e:	c9                   	leave  
  80038f:	c3                   	ret    

00800390 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800390:	55                   	push   %ebp
  800391:	89 e5                	mov    %esp,%ebp
  800393:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800396:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800399:	50                   	push   %eax
  80039a:	ff 75 10             	pushl  0x10(%ebp)
  80039d:	ff 75 0c             	pushl  0xc(%ebp)
  8003a0:	ff 75 08             	pushl  0x8(%ebp)
  8003a3:	e8 05 00 00 00       	call   8003ad <vprintfmt>
	va_end(ap);
  8003a8:	83 c4 10             	add    $0x10,%esp
}
  8003ab:	c9                   	leave  
  8003ac:	c3                   	ret    

008003ad <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8003ad:	55                   	push   %ebp
  8003ae:	89 e5                	mov    %esp,%ebp
  8003b0:	57                   	push   %edi
  8003b1:	56                   	push   %esi
  8003b2:	53                   	push   %ebx
  8003b3:	83 ec 2c             	sub    $0x2c,%esp
  8003b6:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8003b9:	8b 75 10             	mov    0x10(%ebp),%esi
  8003bc:	eb 13                	jmp    8003d1 <vprintfmt+0x24>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8003be:	85 c0                	test   %eax,%eax
  8003c0:	0f 84 6d 03 00 00    	je     800733 <vprintfmt+0x386>
				return;
			putch(ch, putdat);
  8003c6:	83 ec 08             	sub    $0x8,%esp
  8003c9:	57                   	push   %edi
  8003ca:	50                   	push   %eax
  8003cb:	ff 55 08             	call   *0x8(%ebp)
  8003ce:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8003d1:	0f b6 06             	movzbl (%esi),%eax
  8003d4:	46                   	inc    %esi
  8003d5:	83 f8 25             	cmp    $0x25,%eax
  8003d8:	75 e4                	jne    8003be <vprintfmt+0x11>
  8003da:	c6 45 dc 20          	movb   $0x20,-0x24(%ebp)
  8003de:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  8003e5:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  8003ec:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  8003f3:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003f8:	eb 28                	jmp    800422 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003fa:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  8003fc:	c6 45 dc 2d          	movb   $0x2d,-0x24(%ebp)
  800400:	eb 20                	jmp    800422 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800402:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800404:	c6 45 dc 30          	movb   $0x30,-0x24(%ebp)
  800408:	eb 18                	jmp    800422 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80040a:	89 de                	mov    %ebx,%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  80040c:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800413:	eb 0d                	jmp    800422 <vprintfmt+0x75>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800415:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800418:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80041b:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800422:	8a 06                	mov    (%esi),%al
  800424:	0f b6 d0             	movzbl %al,%edx
  800427:	8d 5e 01             	lea    0x1(%esi),%ebx
  80042a:	83 e8 23             	sub    $0x23,%eax
  80042d:	3c 55                	cmp    $0x55,%al
  80042f:	0f 87 e0 02 00 00    	ja     800715 <vprintfmt+0x368>
  800435:	0f b6 c0             	movzbl %al,%eax
  800438:	ff 24 85 00 24 80 00 	jmp    *0x802400(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80043f:	83 ea 30             	sub    $0x30,%edx
  800442:	89 55 d4             	mov    %edx,-0x2c(%ebp)
				ch = *fmt;
  800445:	0f be 03             	movsbl (%ebx),%eax
				if (ch < '0' || ch > '9')
  800448:	8d 50 d0             	lea    -0x30(%eax),%edx
  80044b:	83 fa 09             	cmp    $0x9,%edx
  80044e:	77 44                	ja     800494 <vprintfmt+0xe7>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800450:	89 de                	mov    %ebx,%esi
  800452:	8b 55 d4             	mov    -0x2c(%ebp),%edx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800455:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
  800456:	8d 14 92             	lea    (%edx,%edx,4),%edx
  800459:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
  80045d:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800460:	8d 58 d0             	lea    -0x30(%eax),%ebx
  800463:	83 fb 09             	cmp    $0x9,%ebx
  800466:	76 ed                	jbe    800455 <vprintfmt+0xa8>
  800468:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  80046b:	eb 29                	jmp    800496 <vprintfmt+0xe9>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80046d:	8b 45 14             	mov    0x14(%ebp),%eax
  800470:	8d 50 04             	lea    0x4(%eax),%edx
  800473:	89 55 14             	mov    %edx,0x14(%ebp)
  800476:	8b 00                	mov    (%eax),%eax
  800478:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80047b:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80047d:	eb 17                	jmp    800496 <vprintfmt+0xe9>

		case '.':
			if (width < 0)
  80047f:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800483:	78 85                	js     80040a <vprintfmt+0x5d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800485:	89 de                	mov    %ebx,%esi
  800487:	eb 99                	jmp    800422 <vprintfmt+0x75>
  800489:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80048b:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  800492:	eb 8e                	jmp    800422 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800494:	89 de                	mov    %ebx,%esi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  800496:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80049a:	79 86                	jns    800422 <vprintfmt+0x75>
  80049c:	e9 74 ff ff ff       	jmp    800415 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8004a1:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004a2:	89 de                	mov    %ebx,%esi
  8004a4:	e9 79 ff ff ff       	jmp    800422 <vprintfmt+0x75>
  8004a9:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8004ac:	8b 45 14             	mov    0x14(%ebp),%eax
  8004af:	8d 50 04             	lea    0x4(%eax),%edx
  8004b2:	89 55 14             	mov    %edx,0x14(%ebp)
  8004b5:	83 ec 08             	sub    $0x8,%esp
  8004b8:	57                   	push   %edi
  8004b9:	ff 30                	pushl  (%eax)
  8004bb:	ff 55 08             	call   *0x8(%ebp)
			break;
  8004be:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004c1:	8b 75 d8             	mov    -0x28(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8004c4:	e9 08 ff ff ff       	jmp    8003d1 <vprintfmt+0x24>
  8004c9:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  8004cc:	8b 45 14             	mov    0x14(%ebp),%eax
  8004cf:	8d 50 04             	lea    0x4(%eax),%edx
  8004d2:	89 55 14             	mov    %edx,0x14(%ebp)
  8004d5:	8b 00                	mov    (%eax),%eax
  8004d7:	85 c0                	test   %eax,%eax
  8004d9:	79 02                	jns    8004dd <vprintfmt+0x130>
  8004db:	f7 d8                	neg    %eax
  8004dd:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004df:	83 f8 0f             	cmp    $0xf,%eax
  8004e2:	7f 0b                	jg     8004ef <vprintfmt+0x142>
  8004e4:	8b 04 85 60 25 80 00 	mov    0x802560(,%eax,4),%eax
  8004eb:	85 c0                	test   %eax,%eax
  8004ed:	75 1a                	jne    800509 <vprintfmt+0x15c>
				printfmt(putch, putdat, "error %d", err);
  8004ef:	52                   	push   %edx
  8004f0:	68 df 22 80 00       	push   $0x8022df
  8004f5:	57                   	push   %edi
  8004f6:	ff 75 08             	pushl  0x8(%ebp)
  8004f9:	e8 92 fe ff ff       	call   800390 <printfmt>
  8004fe:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800501:	8b 75 d8             	mov    -0x28(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800504:	e9 c8 fe ff ff       	jmp    8003d1 <vprintfmt+0x24>
			else
				printfmt(putch, putdat, "%s", p);
  800509:	50                   	push   %eax
  80050a:	68 15 28 80 00       	push   $0x802815
  80050f:	57                   	push   %edi
  800510:	ff 75 08             	pushl  0x8(%ebp)
  800513:	e8 78 fe ff ff       	call   800390 <printfmt>
  800518:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80051b:	8b 75 d8             	mov    -0x28(%ebp),%esi
  80051e:	e9 ae fe ff ff       	jmp    8003d1 <vprintfmt+0x24>
  800523:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  800526:	89 de                	mov    %ebx,%esi
  800528:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  80052b:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80052e:	8b 45 14             	mov    0x14(%ebp),%eax
  800531:	8d 50 04             	lea    0x4(%eax),%edx
  800534:	89 55 14             	mov    %edx,0x14(%ebp)
  800537:	8b 00                	mov    (%eax),%eax
  800539:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80053c:	85 c0                	test   %eax,%eax
  80053e:	75 07                	jne    800547 <vprintfmt+0x19a>
				p = "(null)";
  800540:	c7 45 d0 d8 22 80 00 	movl   $0x8022d8,-0x30(%ebp)
			if (width > 0 && padc != '-')
  800547:	85 db                	test   %ebx,%ebx
  800549:	7e 42                	jle    80058d <vprintfmt+0x1e0>
  80054b:	80 7d dc 2d          	cmpb   $0x2d,-0x24(%ebp)
  80054f:	74 3c                	je     80058d <vprintfmt+0x1e0>
				for (width -= strnlen(p, precision); width > 0; width--)
  800551:	83 ec 08             	sub    $0x8,%esp
  800554:	51                   	push   %ecx
  800555:	ff 75 d0             	pushl  -0x30(%ebp)
  800558:	e8 6f 02 00 00       	call   8007cc <strnlen>
  80055d:	29 c3                	sub    %eax,%ebx
  80055f:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800562:	83 c4 10             	add    $0x10,%esp
  800565:	85 db                	test   %ebx,%ebx
  800567:	7e 24                	jle    80058d <vprintfmt+0x1e0>
					putch(padc, putdat);
  800569:	0f be 5d dc          	movsbl -0x24(%ebp),%ebx
  80056d:	89 75 dc             	mov    %esi,-0x24(%ebp)
  800570:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  800573:	83 ec 08             	sub    $0x8,%esp
  800576:	57                   	push   %edi
  800577:	53                   	push   %ebx
  800578:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80057b:	4e                   	dec    %esi
  80057c:	83 c4 10             	add    $0x10,%esp
  80057f:	85 f6                	test   %esi,%esi
  800581:	7f f0                	jg     800573 <vprintfmt+0x1c6>
  800583:	8b 75 dc             	mov    -0x24(%ebp),%esi
  800586:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80058d:	8b 55 d0             	mov    -0x30(%ebp),%edx
  800590:	0f be 02             	movsbl (%edx),%eax
  800593:	85 c0                	test   %eax,%eax
  800595:	75 47                	jne    8005de <vprintfmt+0x231>
  800597:	eb 37                	jmp    8005d0 <vprintfmt+0x223>
				if (altflag && (ch < ' ' || ch > '~'))
  800599:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80059d:	74 16                	je     8005b5 <vprintfmt+0x208>
  80059f:	8d 50 e0             	lea    -0x20(%eax),%edx
  8005a2:	83 fa 5e             	cmp    $0x5e,%edx
  8005a5:	76 0e                	jbe    8005b5 <vprintfmt+0x208>
					putch('?', putdat);
  8005a7:	83 ec 08             	sub    $0x8,%esp
  8005aa:	57                   	push   %edi
  8005ab:	6a 3f                	push   $0x3f
  8005ad:	ff 55 08             	call   *0x8(%ebp)
  8005b0:	83 c4 10             	add    $0x10,%esp
  8005b3:	eb 0b                	jmp    8005c0 <vprintfmt+0x213>
				else
					putch(ch, putdat);
  8005b5:	83 ec 08             	sub    $0x8,%esp
  8005b8:	57                   	push   %edi
  8005b9:	50                   	push   %eax
  8005ba:	ff 55 08             	call   *0x8(%ebp)
  8005bd:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005c0:	ff 4d e4             	decl   -0x1c(%ebp)
  8005c3:	0f be 03             	movsbl (%ebx),%eax
  8005c6:	85 c0                	test   %eax,%eax
  8005c8:	74 03                	je     8005cd <vprintfmt+0x220>
  8005ca:	43                   	inc    %ebx
  8005cb:	eb 1b                	jmp    8005e8 <vprintfmt+0x23b>
  8005cd:	8b 75 dc             	mov    -0x24(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005d0:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8005d4:	7f 1e                	jg     8005f4 <vprintfmt+0x247>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005d6:	8b 75 d8             	mov    -0x28(%ebp),%esi
  8005d9:	e9 f3 fd ff ff       	jmp    8003d1 <vprintfmt+0x24>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005de:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  8005e1:	43                   	inc    %ebx
  8005e2:	89 75 dc             	mov    %esi,-0x24(%ebp)
  8005e5:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  8005e8:	85 f6                	test   %esi,%esi
  8005ea:	78 ad                	js     800599 <vprintfmt+0x1ec>
  8005ec:	4e                   	dec    %esi
  8005ed:	79 aa                	jns    800599 <vprintfmt+0x1ec>
  8005ef:	8b 75 dc             	mov    -0x24(%ebp),%esi
  8005f2:	eb dc                	jmp    8005d0 <vprintfmt+0x223>
  8005f4:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8005f7:	83 ec 08             	sub    $0x8,%esp
  8005fa:	57                   	push   %edi
  8005fb:	6a 20                	push   $0x20
  8005fd:	ff 55 08             	call   *0x8(%ebp)
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800600:	4b                   	dec    %ebx
  800601:	83 c4 10             	add    $0x10,%esp
  800604:	85 db                	test   %ebx,%ebx
  800606:	7f ef                	jg     8005f7 <vprintfmt+0x24a>
  800608:	e9 c4 fd ff ff       	jmp    8003d1 <vprintfmt+0x24>
  80060d:	89 5d d8             	mov    %ebx,-0x28(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800610:	89 ca                	mov    %ecx,%edx
  800612:	8d 45 14             	lea    0x14(%ebp),%eax
  800615:	e8 2a fd ff ff       	call   800344 <getint>
  80061a:	89 c3                	mov    %eax,%ebx
  80061c:	89 d6                	mov    %edx,%esi
			if ((long long) num < 0) {
  80061e:	85 d2                	test   %edx,%edx
  800620:	78 0a                	js     80062c <vprintfmt+0x27f>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800622:	b8 0a 00 00 00       	mov    $0xa,%eax
  800627:	e9 b0 00 00 00       	jmp    8006dc <vprintfmt+0x32f>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  80062c:	83 ec 08             	sub    $0x8,%esp
  80062f:	57                   	push   %edi
  800630:	6a 2d                	push   $0x2d
  800632:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800635:	f7 db                	neg    %ebx
  800637:	83 d6 00             	adc    $0x0,%esi
  80063a:	f7 de                	neg    %esi
  80063c:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  80063f:	b8 0a 00 00 00       	mov    $0xa,%eax
  800644:	e9 93 00 00 00       	jmp    8006dc <vprintfmt+0x32f>
  800649:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80064c:	89 ca                	mov    %ecx,%edx
  80064e:	8d 45 14             	lea    0x14(%ebp),%eax
  800651:	e8 b4 fc ff ff       	call   80030a <getuint>
  800656:	89 c3                	mov    %eax,%ebx
  800658:	89 d6                	mov    %edx,%esi
			base = 10;
  80065a:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  80065f:	eb 7b                	jmp    8006dc <vprintfmt+0x32f>
  800661:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
  800664:	89 ca                	mov    %ecx,%edx
  800666:	8d 45 14             	lea    0x14(%ebp),%eax
  800669:	e8 d6 fc ff ff       	call   800344 <getint>
  80066e:	89 c3                	mov    %eax,%ebx
  800670:	89 d6                	mov    %edx,%esi
            if ((long long) num < 0) {
  800672:	85 d2                	test   %edx,%edx
  800674:	78 07                	js     80067d <vprintfmt+0x2d0>
                putch('-', putdat);
                num = -(long long) num;
            }
            base = 8;
  800676:	b8 08 00 00 00       	mov    $0x8,%eax
  80067b:	eb 5f                	jmp    8006dc <vprintfmt+0x32f>
		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
            if ((long long) num < 0) {
                putch('-', putdat);
  80067d:	83 ec 08             	sub    $0x8,%esp
  800680:	57                   	push   %edi
  800681:	6a 2d                	push   $0x2d
  800683:	ff 55 08             	call   *0x8(%ebp)
                num = -(long long) num;
  800686:	f7 db                	neg    %ebx
  800688:	83 d6 00             	adc    $0x0,%esi
  80068b:	f7 de                	neg    %esi
  80068d:	83 c4 10             	add    $0x10,%esp
            }
            base = 8;
  800690:	b8 08 00 00 00       	mov    $0x8,%eax
  800695:	eb 45                	jmp    8006dc <vprintfmt+0x32f>
  800697:	89 5d d8             	mov    %ebx,-0x28(%ebp)
            goto number;

        // pointer
		case 'p':
			putch('0', putdat);
  80069a:	83 ec 08             	sub    $0x8,%esp
  80069d:	57                   	push   %edi
  80069e:	6a 30                	push   $0x30
  8006a0:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8006a3:	83 c4 08             	add    $0x8,%esp
  8006a6:	57                   	push   %edi
  8006a7:	6a 78                	push   $0x78
  8006a9:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8006ac:	8b 45 14             	mov    0x14(%ebp),%eax
  8006af:	8d 50 04             	lea    0x4(%eax),%edx
  8006b2:	89 55 14             	mov    %edx,0x14(%ebp)

        // pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8006b5:	8b 18                	mov    (%eax),%ebx
  8006b7:	be 00 00 00 00       	mov    $0x0,%esi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8006bc:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8006bf:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8006c4:	eb 16                	jmp    8006dc <vprintfmt+0x32f>
  8006c6:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8006c9:	89 ca                	mov    %ecx,%edx
  8006cb:	8d 45 14             	lea    0x14(%ebp),%eax
  8006ce:	e8 37 fc ff ff       	call   80030a <getuint>
  8006d3:	89 c3                	mov    %eax,%ebx
  8006d5:	89 d6                	mov    %edx,%esi
			base = 16;
  8006d7:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006dc:	83 ec 0c             	sub    $0xc,%esp
  8006df:	0f be 55 dc          	movsbl -0x24(%ebp),%edx
  8006e3:	52                   	push   %edx
  8006e4:	ff 75 e4             	pushl  -0x1c(%ebp)
  8006e7:	50                   	push   %eax
  8006e8:	56                   	push   %esi
  8006e9:	53                   	push   %ebx
  8006ea:	89 fa                	mov    %edi,%edx
  8006ec:	8b 45 08             	mov    0x8(%ebp),%eax
  8006ef:	e8 68 fb ff ff       	call   80025c <printnum>
			break;
  8006f4:	83 c4 20             	add    $0x20,%esp
  8006f7:	8b 75 d8             	mov    -0x28(%ebp),%esi
  8006fa:	e9 d2 fc ff ff       	jmp    8003d1 <vprintfmt+0x24>
  8006ff:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800702:	83 ec 08             	sub    $0x8,%esp
  800705:	57                   	push   %edi
  800706:	52                   	push   %edx
  800707:	ff 55 08             	call   *0x8(%ebp)
			break;
  80070a:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80070d:	8b 75 d8             	mov    -0x28(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800710:	e9 bc fc ff ff       	jmp    8003d1 <vprintfmt+0x24>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800715:	83 ec 08             	sub    $0x8,%esp
  800718:	57                   	push   %edi
  800719:	6a 25                	push   $0x25
  80071b:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  80071e:	83 c4 10             	add    $0x10,%esp
  800721:	eb 02                	jmp    800725 <vprintfmt+0x378>
  800723:	89 c6                	mov    %eax,%esi
  800725:	8d 46 ff             	lea    -0x1(%esi),%eax
  800728:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  80072c:	75 f5                	jne    800723 <vprintfmt+0x376>
  80072e:	e9 9e fc ff ff       	jmp    8003d1 <vprintfmt+0x24>
				/* do nothing */;
			break;
		}
	}
}
  800733:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800736:	5b                   	pop    %ebx
  800737:	5e                   	pop    %esi
  800738:	5f                   	pop    %edi
  800739:	c9                   	leave  
  80073a:	c3                   	ret    

0080073b <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80073b:	55                   	push   %ebp
  80073c:	89 e5                	mov    %esp,%ebp
  80073e:	83 ec 18             	sub    $0x18,%esp
  800741:	8b 45 08             	mov    0x8(%ebp),%eax
  800744:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800747:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80074a:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80074e:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800751:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800758:	85 c0                	test   %eax,%eax
  80075a:	74 26                	je     800782 <vsnprintf+0x47>
  80075c:	85 d2                	test   %edx,%edx
  80075e:	7e 29                	jle    800789 <vsnprintf+0x4e>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800760:	ff 75 14             	pushl  0x14(%ebp)
  800763:	ff 75 10             	pushl  0x10(%ebp)
  800766:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800769:	50                   	push   %eax
  80076a:	68 76 03 80 00       	push   $0x800376
  80076f:	e8 39 fc ff ff       	call   8003ad <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800774:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800777:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80077a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80077d:	83 c4 10             	add    $0x10,%esp
  800780:	eb 0c                	jmp    80078e <vsnprintf+0x53>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800782:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800787:	eb 05                	jmp    80078e <vsnprintf+0x53>
  800789:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80078e:	c9                   	leave  
  80078f:	c3                   	ret    

00800790 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800790:	55                   	push   %ebp
  800791:	89 e5                	mov    %esp,%ebp
  800793:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800796:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800799:	50                   	push   %eax
  80079a:	ff 75 10             	pushl  0x10(%ebp)
  80079d:	ff 75 0c             	pushl  0xc(%ebp)
  8007a0:	ff 75 08             	pushl  0x8(%ebp)
  8007a3:	e8 93 ff ff ff       	call   80073b <vsnprintf>
	va_end(ap);

	return rc;
}
  8007a8:	c9                   	leave  
  8007a9:	c3                   	ret    
	...

008007ac <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007ac:	55                   	push   %ebp
  8007ad:	89 e5                	mov    %esp,%ebp
  8007af:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007b2:	80 3a 00             	cmpb   $0x0,(%edx)
  8007b5:	74 0e                	je     8007c5 <strlen+0x19>
  8007b7:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  8007bc:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8007bd:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007c1:	75 f9                	jne    8007bc <strlen+0x10>
  8007c3:	eb 05                	jmp    8007ca <strlen+0x1e>
  8007c5:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  8007ca:	c9                   	leave  
  8007cb:	c3                   	ret    

008007cc <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007cc:	55                   	push   %ebp
  8007cd:	89 e5                	mov    %esp,%ebp
  8007cf:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007d2:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007d5:	85 d2                	test   %edx,%edx
  8007d7:	74 17                	je     8007f0 <strnlen+0x24>
  8007d9:	80 39 00             	cmpb   $0x0,(%ecx)
  8007dc:	74 19                	je     8007f7 <strnlen+0x2b>
  8007de:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  8007e3:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007e4:	39 d0                	cmp    %edx,%eax
  8007e6:	74 14                	je     8007fc <strnlen+0x30>
  8007e8:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8007ec:	75 f5                	jne    8007e3 <strnlen+0x17>
  8007ee:	eb 0c                	jmp    8007fc <strnlen+0x30>
  8007f0:	b8 00 00 00 00       	mov    $0x0,%eax
  8007f5:	eb 05                	jmp    8007fc <strnlen+0x30>
  8007f7:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  8007fc:	c9                   	leave  
  8007fd:	c3                   	ret    

008007fe <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007fe:	55                   	push   %ebp
  8007ff:	89 e5                	mov    %esp,%ebp
  800801:	53                   	push   %ebx
  800802:	8b 45 08             	mov    0x8(%ebp),%eax
  800805:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800808:	ba 00 00 00 00       	mov    $0x0,%edx
  80080d:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  800810:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800813:	42                   	inc    %edx
  800814:	84 c9                	test   %cl,%cl
  800816:	75 f5                	jne    80080d <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800818:	5b                   	pop    %ebx
  800819:	c9                   	leave  
  80081a:	c3                   	ret    

0080081b <strcat>:

char *
strcat(char *dst, const char *src)
{
  80081b:	55                   	push   %ebp
  80081c:	89 e5                	mov    %esp,%ebp
  80081e:	53                   	push   %ebx
  80081f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800822:	53                   	push   %ebx
  800823:	e8 84 ff ff ff       	call   8007ac <strlen>
  800828:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  80082b:	ff 75 0c             	pushl  0xc(%ebp)
  80082e:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  800831:	50                   	push   %eax
  800832:	e8 c7 ff ff ff       	call   8007fe <strcpy>
	return dst;
}
  800837:	89 d8                	mov    %ebx,%eax
  800839:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80083c:	c9                   	leave  
  80083d:	c3                   	ret    

0080083e <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80083e:	55                   	push   %ebp
  80083f:	89 e5                	mov    %esp,%ebp
  800841:	56                   	push   %esi
  800842:	53                   	push   %ebx
  800843:	8b 45 08             	mov    0x8(%ebp),%eax
  800846:	8b 55 0c             	mov    0xc(%ebp),%edx
  800849:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80084c:	85 f6                	test   %esi,%esi
  80084e:	74 15                	je     800865 <strncpy+0x27>
  800850:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  800855:	8a 1a                	mov    (%edx),%bl
  800857:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80085a:	80 3a 01             	cmpb   $0x1,(%edx)
  80085d:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800860:	41                   	inc    %ecx
  800861:	39 ce                	cmp    %ecx,%esi
  800863:	77 f0                	ja     800855 <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800865:	5b                   	pop    %ebx
  800866:	5e                   	pop    %esi
  800867:	c9                   	leave  
  800868:	c3                   	ret    

00800869 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800869:	55                   	push   %ebp
  80086a:	89 e5                	mov    %esp,%ebp
  80086c:	57                   	push   %edi
  80086d:	56                   	push   %esi
  80086e:	53                   	push   %ebx
  80086f:	8b 7d 08             	mov    0x8(%ebp),%edi
  800872:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800875:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800878:	85 f6                	test   %esi,%esi
  80087a:	74 32                	je     8008ae <strlcpy+0x45>
		while (--size > 0 && *src != '\0')
  80087c:	83 fe 01             	cmp    $0x1,%esi
  80087f:	74 22                	je     8008a3 <strlcpy+0x3a>
  800881:	8a 0b                	mov    (%ebx),%cl
  800883:	84 c9                	test   %cl,%cl
  800885:	74 20                	je     8008a7 <strlcpy+0x3e>
  800887:	89 f8                	mov    %edi,%eax
  800889:	ba 00 00 00 00       	mov    $0x0,%edx
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
  80088e:	83 ee 02             	sub    $0x2,%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800891:	88 08                	mov    %cl,(%eax)
  800893:	40                   	inc    %eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800894:	39 f2                	cmp    %esi,%edx
  800896:	74 11                	je     8008a9 <strlcpy+0x40>
  800898:	8a 4c 13 01          	mov    0x1(%ebx,%edx,1),%cl
  80089c:	42                   	inc    %edx
  80089d:	84 c9                	test   %cl,%cl
  80089f:	75 f0                	jne    800891 <strlcpy+0x28>
  8008a1:	eb 06                	jmp    8008a9 <strlcpy+0x40>
  8008a3:	89 f8                	mov    %edi,%eax
  8008a5:	eb 02                	jmp    8008a9 <strlcpy+0x40>
  8008a7:	89 f8                	mov    %edi,%eax
			*dst++ = *src++;
		*dst = '\0';
  8008a9:	c6 00 00             	movb   $0x0,(%eax)
  8008ac:	eb 02                	jmp    8008b0 <strlcpy+0x47>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8008ae:	89 f8                	mov    %edi,%eax
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
		*dst = '\0';
	}
	return dst - dst_in;
  8008b0:	29 f8                	sub    %edi,%eax
}
  8008b2:	5b                   	pop    %ebx
  8008b3:	5e                   	pop    %esi
  8008b4:	5f                   	pop    %edi
  8008b5:	c9                   	leave  
  8008b6:	c3                   	ret    

008008b7 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8008b7:	55                   	push   %ebp
  8008b8:	89 e5                	mov    %esp,%ebp
  8008ba:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008bd:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008c0:	8a 01                	mov    (%ecx),%al
  8008c2:	84 c0                	test   %al,%al
  8008c4:	74 10                	je     8008d6 <strcmp+0x1f>
  8008c6:	3a 02                	cmp    (%edx),%al
  8008c8:	75 0c                	jne    8008d6 <strcmp+0x1f>
		p++, q++;
  8008ca:	41                   	inc    %ecx
  8008cb:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8008cc:	8a 01                	mov    (%ecx),%al
  8008ce:	84 c0                	test   %al,%al
  8008d0:	74 04                	je     8008d6 <strcmp+0x1f>
  8008d2:	3a 02                	cmp    (%edx),%al
  8008d4:	74 f4                	je     8008ca <strcmp+0x13>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008d6:	0f b6 c0             	movzbl %al,%eax
  8008d9:	0f b6 12             	movzbl (%edx),%edx
  8008dc:	29 d0                	sub    %edx,%eax
}
  8008de:	c9                   	leave  
  8008df:	c3                   	ret    

008008e0 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008e0:	55                   	push   %ebp
  8008e1:	89 e5                	mov    %esp,%ebp
  8008e3:	53                   	push   %ebx
  8008e4:	8b 55 08             	mov    0x8(%ebp),%edx
  8008e7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008ea:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  8008ed:	85 c0                	test   %eax,%eax
  8008ef:	74 1b                	je     80090c <strncmp+0x2c>
  8008f1:	8a 1a                	mov    (%edx),%bl
  8008f3:	84 db                	test   %bl,%bl
  8008f5:	74 24                	je     80091b <strncmp+0x3b>
  8008f7:	3a 19                	cmp    (%ecx),%bl
  8008f9:	75 20                	jne    80091b <strncmp+0x3b>
  8008fb:	48                   	dec    %eax
  8008fc:	74 15                	je     800913 <strncmp+0x33>
		n--, p++, q++;
  8008fe:	42                   	inc    %edx
  8008ff:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800900:	8a 1a                	mov    (%edx),%bl
  800902:	84 db                	test   %bl,%bl
  800904:	74 15                	je     80091b <strncmp+0x3b>
  800906:	3a 19                	cmp    (%ecx),%bl
  800908:	74 f1                	je     8008fb <strncmp+0x1b>
  80090a:	eb 0f                	jmp    80091b <strncmp+0x3b>
		n--, p++, q++;
	if (n == 0)
		return 0;
  80090c:	b8 00 00 00 00       	mov    $0x0,%eax
  800911:	eb 05                	jmp    800918 <strncmp+0x38>
  800913:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800918:	5b                   	pop    %ebx
  800919:	c9                   	leave  
  80091a:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80091b:	0f b6 02             	movzbl (%edx),%eax
  80091e:	0f b6 11             	movzbl (%ecx),%edx
  800921:	29 d0                	sub    %edx,%eax
  800923:	eb f3                	jmp    800918 <strncmp+0x38>

00800925 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800925:	55                   	push   %ebp
  800926:	89 e5                	mov    %esp,%ebp
  800928:	8b 45 08             	mov    0x8(%ebp),%eax
  80092b:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  80092e:	8a 10                	mov    (%eax),%dl
  800930:	84 d2                	test   %dl,%dl
  800932:	74 18                	je     80094c <strchr+0x27>
		if (*s == c)
  800934:	38 ca                	cmp    %cl,%dl
  800936:	75 06                	jne    80093e <strchr+0x19>
  800938:	eb 17                	jmp    800951 <strchr+0x2c>
  80093a:	38 ca                	cmp    %cl,%dl
  80093c:	74 13                	je     800951 <strchr+0x2c>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80093e:	40                   	inc    %eax
  80093f:	8a 10                	mov    (%eax),%dl
  800941:	84 d2                	test   %dl,%dl
  800943:	75 f5                	jne    80093a <strchr+0x15>
		if (*s == c)
			return (char *) s;
	return 0;
  800945:	b8 00 00 00 00       	mov    $0x0,%eax
  80094a:	eb 05                	jmp    800951 <strchr+0x2c>
  80094c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800951:	c9                   	leave  
  800952:	c3                   	ret    

00800953 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800953:	55                   	push   %ebp
  800954:	89 e5                	mov    %esp,%ebp
  800956:	8b 45 08             	mov    0x8(%ebp),%eax
  800959:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  80095c:	8a 10                	mov    (%eax),%dl
  80095e:	84 d2                	test   %dl,%dl
  800960:	74 11                	je     800973 <strfind+0x20>
		if (*s == c)
  800962:	38 ca                	cmp    %cl,%dl
  800964:	75 06                	jne    80096c <strfind+0x19>
  800966:	eb 0b                	jmp    800973 <strfind+0x20>
  800968:	38 ca                	cmp    %cl,%dl
  80096a:	74 07                	je     800973 <strfind+0x20>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  80096c:	40                   	inc    %eax
  80096d:	8a 10                	mov    (%eax),%dl
  80096f:	84 d2                	test   %dl,%dl
  800971:	75 f5                	jne    800968 <strfind+0x15>
		if (*s == c)
			break;
	return (char *) s;
}
  800973:	c9                   	leave  
  800974:	c3                   	ret    

00800975 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800975:	55                   	push   %ebp
  800976:	89 e5                	mov    %esp,%ebp
  800978:	57                   	push   %edi
  800979:	56                   	push   %esi
  80097a:	53                   	push   %ebx
  80097b:	8b 7d 08             	mov    0x8(%ebp),%edi
  80097e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800981:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800984:	85 c9                	test   %ecx,%ecx
  800986:	74 30                	je     8009b8 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800988:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80098e:	75 25                	jne    8009b5 <memset+0x40>
  800990:	f6 c1 03             	test   $0x3,%cl
  800993:	75 20                	jne    8009b5 <memset+0x40>
		c &= 0xFF;
  800995:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800998:	89 d3                	mov    %edx,%ebx
  80099a:	c1 e3 08             	shl    $0x8,%ebx
  80099d:	89 d6                	mov    %edx,%esi
  80099f:	c1 e6 18             	shl    $0x18,%esi
  8009a2:	89 d0                	mov    %edx,%eax
  8009a4:	c1 e0 10             	shl    $0x10,%eax
  8009a7:	09 f0                	or     %esi,%eax
  8009a9:	09 d0                	or     %edx,%eax
  8009ab:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  8009ad:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  8009b0:	fc                   	cld    
  8009b1:	f3 ab                	rep stos %eax,%es:(%edi)
  8009b3:	eb 03                	jmp    8009b8 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8009b5:	fc                   	cld    
  8009b6:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8009b8:	89 f8                	mov    %edi,%eax
  8009ba:	5b                   	pop    %ebx
  8009bb:	5e                   	pop    %esi
  8009bc:	5f                   	pop    %edi
  8009bd:	c9                   	leave  
  8009be:	c3                   	ret    

008009bf <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8009bf:	55                   	push   %ebp
  8009c0:	89 e5                	mov    %esp,%ebp
  8009c2:	57                   	push   %edi
  8009c3:	56                   	push   %esi
  8009c4:	8b 45 08             	mov    0x8(%ebp),%eax
  8009c7:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009ca:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8009cd:	39 c6                	cmp    %eax,%esi
  8009cf:	73 34                	jae    800a05 <memmove+0x46>
  8009d1:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8009d4:	39 d0                	cmp    %edx,%eax
  8009d6:	73 2d                	jae    800a05 <memmove+0x46>
		s += n;
		d += n;
  8009d8:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009db:	f6 c2 03             	test   $0x3,%dl
  8009de:	75 1b                	jne    8009fb <memmove+0x3c>
  8009e0:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8009e6:	75 13                	jne    8009fb <memmove+0x3c>
  8009e8:	f6 c1 03             	test   $0x3,%cl
  8009eb:	75 0e                	jne    8009fb <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8009ed:	83 ef 04             	sub    $0x4,%edi
  8009f0:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009f3:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  8009f6:	fd                   	std    
  8009f7:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009f9:	eb 07                	jmp    800a02 <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8009fb:	4f                   	dec    %edi
  8009fc:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8009ff:	fd                   	std    
  800a00:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a02:	fc                   	cld    
  800a03:	eb 20                	jmp    800a25 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a05:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a0b:	75 13                	jne    800a20 <memmove+0x61>
  800a0d:	a8 03                	test   $0x3,%al
  800a0f:	75 0f                	jne    800a20 <memmove+0x61>
  800a11:	f6 c1 03             	test   $0x3,%cl
  800a14:	75 0a                	jne    800a20 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800a16:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800a19:	89 c7                	mov    %eax,%edi
  800a1b:	fc                   	cld    
  800a1c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a1e:	eb 05                	jmp    800a25 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a20:	89 c7                	mov    %eax,%edi
  800a22:	fc                   	cld    
  800a23:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a25:	5e                   	pop    %esi
  800a26:	5f                   	pop    %edi
  800a27:	c9                   	leave  
  800a28:	c3                   	ret    

00800a29 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a29:	55                   	push   %ebp
  800a2a:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800a2c:	ff 75 10             	pushl  0x10(%ebp)
  800a2f:	ff 75 0c             	pushl  0xc(%ebp)
  800a32:	ff 75 08             	pushl  0x8(%ebp)
  800a35:	e8 85 ff ff ff       	call   8009bf <memmove>
}
  800a3a:	c9                   	leave  
  800a3b:	c3                   	ret    

00800a3c <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a3c:	55                   	push   %ebp
  800a3d:	89 e5                	mov    %esp,%ebp
  800a3f:	57                   	push   %edi
  800a40:	56                   	push   %esi
  800a41:	53                   	push   %ebx
  800a42:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800a45:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a48:	8b 7d 10             	mov    0x10(%ebp),%edi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a4b:	85 ff                	test   %edi,%edi
  800a4d:	74 32                	je     800a81 <memcmp+0x45>
		if (*s1 != *s2)
  800a4f:	8a 03                	mov    (%ebx),%al
  800a51:	8a 0e                	mov    (%esi),%cl
  800a53:	38 c8                	cmp    %cl,%al
  800a55:	74 19                	je     800a70 <memcmp+0x34>
  800a57:	eb 0d                	jmp    800a66 <memcmp+0x2a>
  800a59:	8a 44 13 01          	mov    0x1(%ebx,%edx,1),%al
  800a5d:	8a 4c 16 01          	mov    0x1(%esi,%edx,1),%cl
  800a61:	42                   	inc    %edx
  800a62:	38 c8                	cmp    %cl,%al
  800a64:	74 10                	je     800a76 <memcmp+0x3a>
			return (int) *s1 - (int) *s2;
  800a66:	0f b6 c0             	movzbl %al,%eax
  800a69:	0f b6 c9             	movzbl %cl,%ecx
  800a6c:	29 c8                	sub    %ecx,%eax
  800a6e:	eb 16                	jmp    800a86 <memcmp+0x4a>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a70:	4f                   	dec    %edi
  800a71:	ba 00 00 00 00       	mov    $0x0,%edx
  800a76:	39 fa                	cmp    %edi,%edx
  800a78:	75 df                	jne    800a59 <memcmp+0x1d>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a7a:	b8 00 00 00 00       	mov    $0x0,%eax
  800a7f:	eb 05                	jmp    800a86 <memcmp+0x4a>
  800a81:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a86:	5b                   	pop    %ebx
  800a87:	5e                   	pop    %esi
  800a88:	5f                   	pop    %edi
  800a89:	c9                   	leave  
  800a8a:	c3                   	ret    

00800a8b <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a8b:	55                   	push   %ebp
  800a8c:	89 e5                	mov    %esp,%ebp
  800a8e:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800a91:	89 c2                	mov    %eax,%edx
  800a93:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a96:	39 d0                	cmp    %edx,%eax
  800a98:	73 12                	jae    800aac <memfind+0x21>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a9a:	8a 4d 0c             	mov    0xc(%ebp),%cl
  800a9d:	38 08                	cmp    %cl,(%eax)
  800a9f:	75 06                	jne    800aa7 <memfind+0x1c>
  800aa1:	eb 09                	jmp    800aac <memfind+0x21>
  800aa3:	38 08                	cmp    %cl,(%eax)
  800aa5:	74 05                	je     800aac <memfind+0x21>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800aa7:	40                   	inc    %eax
  800aa8:	39 c2                	cmp    %eax,%edx
  800aaa:	77 f7                	ja     800aa3 <memfind+0x18>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800aac:	c9                   	leave  
  800aad:	c3                   	ret    

00800aae <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800aae:	55                   	push   %ebp
  800aaf:	89 e5                	mov    %esp,%ebp
  800ab1:	57                   	push   %edi
  800ab2:	56                   	push   %esi
  800ab3:	53                   	push   %ebx
  800ab4:	8b 55 08             	mov    0x8(%ebp),%edx
  800ab7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800aba:	eb 01                	jmp    800abd <strtol+0xf>
		s++;
  800abc:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800abd:	8a 02                	mov    (%edx),%al
  800abf:	3c 20                	cmp    $0x20,%al
  800ac1:	74 f9                	je     800abc <strtol+0xe>
  800ac3:	3c 09                	cmp    $0x9,%al
  800ac5:	74 f5                	je     800abc <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800ac7:	3c 2b                	cmp    $0x2b,%al
  800ac9:	75 08                	jne    800ad3 <strtol+0x25>
		s++;
  800acb:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800acc:	bf 00 00 00 00       	mov    $0x0,%edi
  800ad1:	eb 13                	jmp    800ae6 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800ad3:	3c 2d                	cmp    $0x2d,%al
  800ad5:	75 0a                	jne    800ae1 <strtol+0x33>
		s++, neg = 1;
  800ad7:	8d 52 01             	lea    0x1(%edx),%edx
  800ada:	bf 01 00 00 00       	mov    $0x1,%edi
  800adf:	eb 05                	jmp    800ae6 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800ae1:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800ae6:	85 db                	test   %ebx,%ebx
  800ae8:	74 05                	je     800aef <strtol+0x41>
  800aea:	83 fb 10             	cmp    $0x10,%ebx
  800aed:	75 28                	jne    800b17 <strtol+0x69>
  800aef:	8a 02                	mov    (%edx),%al
  800af1:	3c 30                	cmp    $0x30,%al
  800af3:	75 10                	jne    800b05 <strtol+0x57>
  800af5:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800af9:	75 0a                	jne    800b05 <strtol+0x57>
		s += 2, base = 16;
  800afb:	83 c2 02             	add    $0x2,%edx
  800afe:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b03:	eb 12                	jmp    800b17 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800b05:	85 db                	test   %ebx,%ebx
  800b07:	75 0e                	jne    800b17 <strtol+0x69>
  800b09:	3c 30                	cmp    $0x30,%al
  800b0b:	75 05                	jne    800b12 <strtol+0x64>
		s++, base = 8;
  800b0d:	42                   	inc    %edx
  800b0e:	b3 08                	mov    $0x8,%bl
  800b10:	eb 05                	jmp    800b17 <strtol+0x69>
	else if (base == 0)
		base = 10;
  800b12:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800b17:	b8 00 00 00 00       	mov    $0x0,%eax
  800b1c:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800b1e:	8a 0a                	mov    (%edx),%cl
  800b20:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800b23:	80 fb 09             	cmp    $0x9,%bl
  800b26:	77 08                	ja     800b30 <strtol+0x82>
			dig = *s - '0';
  800b28:	0f be c9             	movsbl %cl,%ecx
  800b2b:	83 e9 30             	sub    $0x30,%ecx
  800b2e:	eb 1e                	jmp    800b4e <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800b30:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800b33:	80 fb 19             	cmp    $0x19,%bl
  800b36:	77 08                	ja     800b40 <strtol+0x92>
			dig = *s - 'a' + 10;
  800b38:	0f be c9             	movsbl %cl,%ecx
  800b3b:	83 e9 57             	sub    $0x57,%ecx
  800b3e:	eb 0e                	jmp    800b4e <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800b40:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800b43:	80 fb 19             	cmp    $0x19,%bl
  800b46:	77 13                	ja     800b5b <strtol+0xad>
			dig = *s - 'A' + 10;
  800b48:	0f be c9             	movsbl %cl,%ecx
  800b4b:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800b4e:	39 f1                	cmp    %esi,%ecx
  800b50:	7d 0d                	jge    800b5f <strtol+0xb1>
			break;
		s++, val = (val * base) + dig;
  800b52:	42                   	inc    %edx
  800b53:	0f af c6             	imul   %esi,%eax
  800b56:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  800b59:	eb c3                	jmp    800b1e <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800b5b:	89 c1                	mov    %eax,%ecx
  800b5d:	eb 02                	jmp    800b61 <strtol+0xb3>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800b5f:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800b61:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b65:	74 05                	je     800b6c <strtol+0xbe>
		*endptr = (char *) s;
  800b67:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800b6a:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800b6c:	85 ff                	test   %edi,%edi
  800b6e:	74 04                	je     800b74 <strtol+0xc6>
  800b70:	89 c8                	mov    %ecx,%eax
  800b72:	f7 d8                	neg    %eax
}
  800b74:	5b                   	pop    %ebx
  800b75:	5e                   	pop    %esi
  800b76:	5f                   	pop    %edi
  800b77:	c9                   	leave  
  800b78:	c3                   	ret    
  800b79:	00 00                	add    %al,(%eax)
	...

00800b7c <syscall>:
	return ret;
}

static int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800b7c:	55                   	push   %ebp
  800b7d:	89 e5                	mov    %esp,%ebp
  800b7f:	57                   	push   %edi
  800b80:	56                   	push   %esi
  800b81:	53                   	push   %ebx
  800b82:	83 ec 1c             	sub    $0x1c,%esp
  800b85:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800b88:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800b8b:	89 ca                	mov    %ecx,%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b8d:	8b 75 14             	mov    0x14(%ebp),%esi
  800b90:	8b 7d 10             	mov    0x10(%ebp),%edi
  800b93:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800b96:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b99:	cd 30                	int    $0x30
  800b9b:	89 c2                	mov    %eax,%edx
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b9d:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800ba1:	74 1c                	je     800bbf <syscall+0x43>
  800ba3:	85 c0                	test   %eax,%eax
  800ba5:	7e 18                	jle    800bbf <syscall+0x43>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ba7:	83 ec 0c             	sub    $0xc,%esp
  800baa:	50                   	push   %eax
  800bab:	ff 75 e4             	pushl  -0x1c(%ebp)
  800bae:	68 bf 25 80 00       	push   $0x8025bf
  800bb3:	6a 42                	push   $0x42
  800bb5:	68 dc 25 80 00       	push   $0x8025dc
  800bba:	e8 b1 f5 ff ff       	call   800170 <_panic>

	return ret;
}
  800bbf:	89 d0                	mov    %edx,%eax
  800bc1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bc4:	5b                   	pop    %ebx
  800bc5:	5e                   	pop    %esi
  800bc6:	5f                   	pop    %edi
  800bc7:	c9                   	leave  
  800bc8:	c3                   	ret    

00800bc9 <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{	
  800bc9:	55                   	push   %ebp
  800bca:	89 e5                	mov    %esp,%ebp
  800bcc:	83 ec 08             	sub    $0x8,%esp
	// my_sysenter(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
	// return;
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  800bcf:	6a 00                	push   $0x0
  800bd1:	6a 00                	push   $0x0
  800bd3:	6a 00                	push   $0x0
  800bd5:	ff 75 0c             	pushl  0xc(%ebp)
  800bd8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800bdb:	ba 00 00 00 00       	mov    $0x0,%edx
  800be0:	b8 00 00 00 00       	mov    $0x0,%eax
  800be5:	e8 92 ff ff ff       	call   800b7c <syscall>
  800bea:	83 c4 10             	add    $0x10,%esp
	return;
}
  800bed:	c9                   	leave  
  800bee:	c3                   	ret    

00800bef <sys_cgetc>:

int
sys_cgetc(void)
{
  800bef:	55                   	push   %ebp
  800bf0:	89 e5                	mov    %esp,%ebp
  800bf2:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_cgetc, 0, 0, 0, 0, 0, 0);
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  800bf5:	6a 00                	push   $0x0
  800bf7:	6a 00                	push   $0x0
  800bf9:	6a 00                	push   $0x0
  800bfb:	6a 00                	push   $0x0
  800bfd:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c02:	ba 00 00 00 00       	mov    $0x0,%edx
  800c07:	b8 01 00 00 00       	mov    $0x1,%eax
  800c0c:	e8 6b ff ff ff       	call   800b7c <syscall>
}
  800c11:	c9                   	leave  
  800c12:	c3                   	ret    

00800c13 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800c13:	55                   	push   %ebp
  800c14:	89 e5                	mov    %esp,%ebp
  800c16:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  800c19:	6a 00                	push   $0x0
  800c1b:	6a 00                	push   $0x0
  800c1d:	6a 00                	push   $0x0
  800c1f:	6a 00                	push   $0x0
  800c21:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c24:	ba 01 00 00 00       	mov    $0x1,%edx
  800c29:	b8 03 00 00 00       	mov    $0x3,%eax
  800c2e:	e8 49 ff ff ff       	call   800b7c <syscall>
}
  800c33:	c9                   	leave  
  800c34:	c3                   	ret    

00800c35 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c35:	55                   	push   %ebp
  800c36:	89 e5                	mov    %esp,%ebp
  800c38:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_getenvid, 0, 0, 0, 0, 0, 0);
	return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  800c3b:	6a 00                	push   $0x0
  800c3d:	6a 00                	push   $0x0
  800c3f:	6a 00                	push   $0x0
  800c41:	6a 00                	push   $0x0
  800c43:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c48:	ba 00 00 00 00       	mov    $0x0,%edx
  800c4d:	b8 02 00 00 00       	mov    $0x2,%eax
  800c52:	e8 25 ff ff ff       	call   800b7c <syscall>
}
  800c57:	c9                   	leave  
  800c58:	c3                   	ret    

00800c59 <sys_yield>:

void
sys_yield(void)
{
  800c59:	55                   	push   %ebp
  800c5a:	89 e5                	mov    %esp,%ebp
  800c5c:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  800c5f:	6a 00                	push   $0x0
  800c61:	6a 00                	push   $0x0
  800c63:	6a 00                	push   $0x0
  800c65:	6a 00                	push   $0x0
  800c67:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c6c:	ba 00 00 00 00       	mov    $0x0,%edx
  800c71:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c76:	e8 01 ff ff ff       	call   800b7c <syscall>
  800c7b:	83 c4 10             	add    $0x10,%esp
}
  800c7e:	c9                   	leave  
  800c7f:	c3                   	ret    

00800c80 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c80:	55                   	push   %ebp
  800c81:	89 e5                	mov    %esp,%ebp
  800c83:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  800c86:	6a 00                	push   $0x0
  800c88:	6a 00                	push   $0x0
  800c8a:	ff 75 10             	pushl  0x10(%ebp)
  800c8d:	ff 75 0c             	pushl  0xc(%ebp)
  800c90:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c93:	ba 01 00 00 00       	mov    $0x1,%edx
  800c98:	b8 04 00 00 00       	mov    $0x4,%eax
  800c9d:	e8 da fe ff ff       	call   800b7c <syscall>
}
  800ca2:	c9                   	leave  
  800ca3:	c3                   	ret    

00800ca4 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800ca4:	55                   	push   %ebp
  800ca5:	89 e5                	mov    %esp,%ebp
  800ca7:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
  800caa:	ff 75 18             	pushl  0x18(%ebp)
  800cad:	ff 75 14             	pushl  0x14(%ebp)
  800cb0:	ff 75 10             	pushl  0x10(%ebp)
  800cb3:	ff 75 0c             	pushl  0xc(%ebp)
  800cb6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800cb9:	ba 01 00 00 00       	mov    $0x1,%edx
  800cbe:	b8 05 00 00 00       	mov    $0x5,%eax
  800cc3:	e8 b4 fe ff ff       	call   800b7c <syscall>
}
  800cc8:	c9                   	leave  
  800cc9:	c3                   	ret    

00800cca <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800cca:	55                   	push   %ebp
  800ccb:	89 e5                	mov    %esp,%ebp
  800ccd:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  800cd0:	6a 00                	push   $0x0
  800cd2:	6a 00                	push   $0x0
  800cd4:	6a 00                	push   $0x0
  800cd6:	ff 75 0c             	pushl  0xc(%ebp)
  800cd9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800cdc:	ba 01 00 00 00       	mov    $0x1,%edx
  800ce1:	b8 06 00 00 00       	mov    $0x6,%eax
  800ce6:	e8 91 fe ff ff       	call   800b7c <syscall>
}
  800ceb:	c9                   	leave  
  800cec:	c3                   	ret    

00800ced <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800ced:	55                   	push   %ebp
  800cee:	89 e5                	mov    %esp,%ebp
  800cf0:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  800cf3:	6a 00                	push   $0x0
  800cf5:	6a 00                	push   $0x0
  800cf7:	6a 00                	push   $0x0
  800cf9:	ff 75 0c             	pushl  0xc(%ebp)
  800cfc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800cff:	ba 01 00 00 00       	mov    $0x1,%edx
  800d04:	b8 08 00 00 00       	mov    $0x8,%eax
  800d09:	e8 6e fe ff ff       	call   800b7c <syscall>
}
  800d0e:	c9                   	leave  
  800d0f:	c3                   	ret    

00800d10 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800d10:	55                   	push   %ebp
  800d11:	89 e5                	mov    %esp,%ebp
  800d13:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
  800d16:	6a 00                	push   $0x0
  800d18:	6a 00                	push   $0x0
  800d1a:	6a 00                	push   $0x0
  800d1c:	ff 75 0c             	pushl  0xc(%ebp)
  800d1f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d22:	ba 01 00 00 00       	mov    $0x1,%edx
  800d27:	b8 09 00 00 00       	mov    $0x9,%eax
  800d2c:	e8 4b fe ff ff       	call   800b7c <syscall>
}
  800d31:	c9                   	leave  
  800d32:	c3                   	ret    

00800d33 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d33:	55                   	push   %ebp
  800d34:	89 e5                	mov    %esp,%ebp
  800d36:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  800d39:	6a 00                	push   $0x0
  800d3b:	6a 00                	push   $0x0
  800d3d:	6a 00                	push   $0x0
  800d3f:	ff 75 0c             	pushl  0xc(%ebp)
  800d42:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d45:	ba 01 00 00 00       	mov    $0x1,%edx
  800d4a:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d4f:	e8 28 fe ff ff       	call   800b7c <syscall>
}
  800d54:	c9                   	leave  
  800d55:	c3                   	ret    

00800d56 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d56:	55                   	push   %ebp
  800d57:	89 e5                	mov    %esp,%ebp
  800d59:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  800d5c:	6a 00                	push   $0x0
  800d5e:	ff 75 14             	pushl  0x14(%ebp)
  800d61:	ff 75 10             	pushl  0x10(%ebp)
  800d64:	ff 75 0c             	pushl  0xc(%ebp)
  800d67:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d6a:	ba 00 00 00 00       	mov    $0x0,%edx
  800d6f:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d74:	e8 03 fe ff ff       	call   800b7c <syscall>
}
  800d79:	c9                   	leave  
  800d7a:	c3                   	ret    

00800d7b <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d7b:	55                   	push   %ebp
  800d7c:	89 e5                	mov    %esp,%ebp
  800d7e:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  800d81:	6a 00                	push   $0x0
  800d83:	6a 00                	push   $0x0
  800d85:	6a 00                	push   $0x0
  800d87:	6a 00                	push   $0x0
  800d89:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d8c:	ba 01 00 00 00       	mov    $0x1,%edx
  800d91:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d96:	e8 e1 fd ff ff       	call   800b7c <syscall>
}
  800d9b:	c9                   	leave  
  800d9c:	c3                   	ret    

00800d9d <sys_set_priority>:

int
sys_set_priority(envid_t envid, uint32_t new_priority)
{
  800d9d:	55                   	push   %ebp
  800d9e:	89 e5                	mov    %esp,%ebp
  800da0:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_set_priority, 0, envid, new_priority, 0, 0, 0);
  800da3:	6a 00                	push   $0x0
  800da5:	6a 00                	push   $0x0
  800da7:	6a 00                	push   $0x0
  800da9:	ff 75 0c             	pushl  0xc(%ebp)
  800dac:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800daf:	ba 00 00 00 00       	mov    $0x0,%edx
  800db4:	b8 0e 00 00 00       	mov    $0xe,%eax
  800db9:	e8 be fd ff ff       	call   800b7c <syscall>
}
  800dbe:	c9                   	leave  
  800dbf:	c3                   	ret    

00800dc0 <sys_exec>:

int
sys_exec(uint32_t eip, uint32_t esp, void * ph, uint32_t elf_phnum)
{
  800dc0:	55                   	push   %ebp
  800dc1:	89 e5                	mov    %esp,%ebp
  800dc3:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_exec, 0, eip, esp, (uint32_t)ph, elf_phnum, 0);
  800dc6:	6a 00                	push   $0x0
  800dc8:	ff 75 14             	pushl  0x14(%ebp)
  800dcb:	ff 75 10             	pushl  0x10(%ebp)
  800dce:	ff 75 0c             	pushl  0xc(%ebp)
  800dd1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800dd4:	ba 00 00 00 00       	mov    $0x0,%edx
  800dd9:	b8 0f 00 00 00       	mov    $0xf,%eax
  800dde:	e8 99 fd ff ff       	call   800b7c <syscall>
} 
  800de3:	c9                   	leave  
  800de4:	c3                   	ret    

00800de5 <sys_join>:

// thread:
int
sys_join(envid_t envid)
{
  800de5:	55                   	push   %ebp
  800de6:	89 e5                	mov    %esp,%ebp
  800de8:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_join, 0, envid, 0, 0, 0, 0);
  800deb:	6a 00                	push   $0x0
  800ded:	6a 00                	push   $0x0
  800def:	6a 00                	push   $0x0
  800df1:	6a 00                	push   $0x0
  800df3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800df6:	ba 00 00 00 00       	mov    $0x0,%edx
  800dfb:	b8 11 00 00 00       	mov    $0x11,%eax
  800e00:	e8 77 fd ff ff       	call   800b7c <syscall>
}
  800e05:	c9                   	leave  
  800e06:	c3                   	ret    

00800e07 <sys_getpid>:

envid_t
sys_getpid(void)
{
  800e07:	55                   	push   %ebp
  800e08:	89 e5                	mov    %esp,%ebp
  800e0a:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_getpid, 0, 0, 0, 0, 0, 0);
  800e0d:	6a 00                	push   $0x0
  800e0f:	6a 00                	push   $0x0
  800e11:	6a 00                	push   $0x0
  800e13:	6a 00                	push   $0x0
  800e15:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e1a:	ba 00 00 00 00       	mov    $0x0,%edx
  800e1f:	b8 10 00 00 00       	mov    $0x10,%eax
  800e24:	e8 53 fd ff ff       	call   800b7c <syscall>
  800e29:	c9                   	leave  
  800e2a:	c3                   	ret    
	...

00800e2c <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800e2c:	55                   	push   %ebp
  800e2d:	89 e5                	mov    %esp,%ebp
  800e2f:	53                   	push   %ebx
  800e30:	83 ec 04             	sub    $0x4,%esp
  800e33:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800e36:	8b 18                	mov    (%eax),%ebx

	// LAB 4: Your code here.
	
	// cprintf("PAGE FAULT HANDLER, 0x%08x %d\n", (uint32_t)addr, err & FEC_WR);
	
	if ((err & FEC_WR) == 0)
  800e38:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800e3c:	75 14                	jne    800e52 <pgfault+0x26>
		panic("pgfault, the fault is not a write\n");
  800e3e:	83 ec 04             	sub    $0x4,%esp
  800e41:	68 ec 25 80 00       	push   $0x8025ec
  800e46:	6a 20                	push   $0x20
  800e48:	68 30 27 80 00       	push   $0x802730
  800e4d:	e8 1e f3 ff ff       	call   800170 <_panic>

	uint32_t uaddr = (uint32_t) addr;
	if ((uvpd[PDX(addr)] & PTE_P) == 0 || (uvpt[uaddr / PGSIZE] & PTE_COW) == 0) {
  800e52:	89 d8                	mov    %ebx,%eax
  800e54:	c1 e8 16             	shr    $0x16,%eax
  800e57:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800e5e:	a8 01                	test   $0x1,%al
  800e60:	74 11                	je     800e73 <pgfault+0x47>
  800e62:	89 d8                	mov    %ebx,%eax
  800e64:	c1 e8 0c             	shr    $0xc,%eax
  800e67:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800e6e:	f6 c4 08             	test   $0x8,%ah
  800e71:	75 14                	jne    800e87 <pgfault+0x5b>
		panic("pgfault, not a copy-on-write page\n");
  800e73:	83 ec 04             	sub    $0x4,%esp
  800e76:	68 10 26 80 00       	push   $0x802610
  800e7b:	6a 24                	push   $0x24
  800e7d:	68 30 27 80 00       	push   $0x802730
  800e82:	e8 e9 f2 ff ff       	call   800170 <_panic>
	//   No need to explicitly delete the old page's mapping.

	// LAB 4: Your code here.

	// static int sys_page_alloc(envid_t envid, void *va, int perm)
	r = sys_page_alloc(0, (void *)PFTEMP, PTE_W | PTE_U | PTE_P);
  800e87:	83 ec 04             	sub    $0x4,%esp
  800e8a:	6a 07                	push   $0x7
  800e8c:	68 00 f0 7f 00       	push   $0x7ff000
  800e91:	6a 00                	push   $0x0
  800e93:	e8 e8 fd ff ff       	call   800c80 <sys_page_alloc>
	if (r < 0) panic("pgfault, sys_page_alloc error : %e\n", r);
  800e98:	83 c4 10             	add    $0x10,%esp
  800e9b:	85 c0                	test   %eax,%eax
  800e9d:	79 12                	jns    800eb1 <pgfault+0x85>
  800e9f:	50                   	push   %eax
  800ea0:	68 34 26 80 00       	push   $0x802634
  800ea5:	6a 32                	push   $0x32
  800ea7:	68 30 27 80 00       	push   $0x802730
  800eac:	e8 bf f2 ff ff       	call   800170 <_panic>

	// Oh my god, I forget this at the first, it waste me a lot of time to debug!!!
	addr = ROUNDDOWN(addr, PGSIZE);
  800eb1:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	
	memcpy(PFTEMP, addr, PGSIZE);
  800eb7:	83 ec 04             	sub    $0x4,%esp
  800eba:	68 00 10 00 00       	push   $0x1000
  800ebf:	53                   	push   %ebx
  800ec0:	68 00 f0 7f 00       	push   $0x7ff000
  800ec5:	e8 5f fb ff ff       	call   800a29 <memcpy>
	
	r = sys_page_map(0, PFTEMP, 0, addr, PTE_W | PTE_U | PTE_P);
  800eca:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800ed1:	53                   	push   %ebx
  800ed2:	6a 00                	push   $0x0
  800ed4:	68 00 f0 7f 00       	push   $0x7ff000
  800ed9:	6a 00                	push   $0x0
  800edb:	e8 c4 fd ff ff       	call   800ca4 <sys_page_map>
	if (r < 0) panic("pgfault, sys_page_map error : %e\n", r);
  800ee0:	83 c4 20             	add    $0x20,%esp
  800ee3:	85 c0                	test   %eax,%eax
  800ee5:	79 12                	jns    800ef9 <pgfault+0xcd>
  800ee7:	50                   	push   %eax
  800ee8:	68 58 26 80 00       	push   $0x802658
  800eed:	6a 3a                	push   $0x3a
  800eef:	68 30 27 80 00       	push   $0x802730
  800ef4:	e8 77 f2 ff ff       	call   800170 <_panic>

	return;
}
  800ef9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800efc:	c9                   	leave  
  800efd:	c3                   	ret    

00800efe <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800efe:	55                   	push   %ebp
  800eff:	89 e5                	mov    %esp,%ebp
  800f01:	57                   	push   %edi
  800f02:	56                   	push   %esi
  800f03:	53                   	push   %ebx
  800f04:	83 ec 28             	sub    $0x28,%esp
	// static int num = 0x100;

	// LAB 4: Your code here.
	set_pgfault_handler(pgfault);
  800f07:	68 2c 0e 80 00       	push   $0x800e2c
  800f0c:	e8 e7 0e 00 00       	call   801df8 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  800f11:	ba 07 00 00 00       	mov    $0x7,%edx
  800f16:	89 d0                	mov    %edx,%eax
  800f18:	cd 30                	int    $0x30
  800f1a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800f1d:	89 c7                	mov    %eax,%edi
	int childpid = sys_exofork();
	if (childpid < 0) {
  800f1f:	83 c4 10             	add    $0x10,%esp
  800f22:	85 c0                	test   %eax,%eax
  800f24:	79 12                	jns    800f38 <fork+0x3a>
		panic("fork sys_exofork error : %e\n", childpid);
  800f26:	50                   	push   %eax
  800f27:	68 3b 27 80 00       	push   $0x80273b
  800f2c:	6a 7f                	push   $0x7f
  800f2e:	68 30 27 80 00       	push   $0x802730
  800f33:	e8 38 f2 ff ff       	call   800170 <_panic>
	}
	int r;

	if (childpid == 0) {
  800f38:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800f3c:	75 20                	jne    800f5e <fork+0x60>
		// child process
		// Remember to fix "thisenv" in the child process. ??? 
		thisenv = &envs[ENVX(sys_getenvid())];
  800f3e:	e8 f2 fc ff ff       	call   800c35 <sys_getenvid>
  800f43:	25 ff 03 00 00       	and    $0x3ff,%eax
  800f48:	89 c2                	mov    %eax,%edx
  800f4a:	c1 e2 07             	shl    $0x7,%edx
  800f4d:	8d 84 82 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,4),%eax
  800f54:	a3 08 40 80 00       	mov    %eax,0x804008
		// cprintf("fork child ok\n");
		return 0;
  800f59:	e9 be 01 00 00       	jmp    80111c <fork+0x21e>
	if (childpid < 0) {
		panic("fork sys_exofork error : %e\n", childpid);
	}
	int r;

	if (childpid == 0) {
  800f5e:	bb 00 00 00 00       	mov    $0x0,%ebx
	} else {
		// map page to new environment
		// kernel page is already in new environment
		uint32_t i;
		for (i = 0; i != UTOP; i += PGSIZE) 
		if ((uvpd[PDX(i)] & PTE_P) && (uvpt[i / PGSIZE] & PTE_P) && (uvpt[i / PGSIZE] & PTE_U)) {
  800f63:	89 d8                	mov    %ebx,%eax
  800f65:	c1 e8 16             	shr    $0x16,%eax
  800f68:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800f6f:	a8 01                	test   $0x1,%al
  800f71:	0f 84 10 01 00 00    	je     801087 <fork+0x189>
  800f77:	89 d8                	mov    %ebx,%eax
  800f79:	c1 e8 0c             	shr    $0xc,%eax
  800f7c:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800f83:	f6 c2 01             	test   $0x1,%dl
  800f86:	0f 84 fb 00 00 00    	je     801087 <fork+0x189>
  800f8c:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800f93:	f6 c2 04             	test   $0x4,%dl
  800f96:	0f 84 eb 00 00 00    	je     801087 <fork+0x189>
//
static int
duppage(envid_t envid, unsigned pn)
{
	// do not dup exception stack
	if (pn * PGSIZE == UXSTACKTOP - PGSIZE) return 0;
  800f9c:	89 c6                	mov    %eax,%esi
  800f9e:	c1 e6 0c             	shl    $0xc,%esi
  800fa1:	81 fe 00 f0 bf ee    	cmp    $0xeebff000,%esi
  800fa7:	0f 84 da 00 00 00    	je     801087 <fork+0x189>

	int r;
	void * addr = (void *)(pn * PGSIZE);
    if (uvpt[pn] & PTE_SHARE) {
  800fad:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800fb4:	f6 c6 04             	test   $0x4,%dh
  800fb7:	74 37                	je     800ff0 <fork+0xf2>
        r = sys_page_map(0, addr, envid, addr, uvpt[pn] & PTE_SYSCALL);
  800fb9:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800fc0:	83 ec 0c             	sub    $0xc,%esp
  800fc3:	25 07 0e 00 00       	and    $0xe07,%eax
  800fc8:	50                   	push   %eax
  800fc9:	56                   	push   %esi
  800fca:	57                   	push   %edi
  800fcb:	56                   	push   %esi
  800fcc:	6a 00                	push   $0x0
  800fce:	e8 d1 fc ff ff       	call   800ca4 <sys_page_map>
        if (r < 0) panic("duppage sys_page_map error : %e\n", r);
  800fd3:	83 c4 20             	add    $0x20,%esp
  800fd6:	85 c0                	test   %eax,%eax
  800fd8:	0f 89 a9 00 00 00    	jns    801087 <fork+0x189>
  800fde:	50                   	push   %eax
  800fdf:	68 7c 26 80 00       	push   $0x80267c
  800fe4:	6a 54                	push   $0x54
  800fe6:	68 30 27 80 00       	push   $0x802730
  800feb:	e8 80 f1 ff ff       	call   800170 <_panic>
    } else
	if ((uvpt[pn] & PTE_W) || (uvpt[pn] & PTE_COW)) {
  800ff0:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800ff7:	f6 c2 02             	test   $0x2,%dl
  800ffa:	75 0c                	jne    801008 <fork+0x10a>
  800ffc:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801003:	f6 c4 08             	test   $0x8,%ah
  801006:	74 57                	je     80105f <fork+0x161>
		// cow
		r = sys_page_map(0, addr, envid, addr, PTE_COW | PTE_P | PTE_U);
  801008:	83 ec 0c             	sub    $0xc,%esp
  80100b:	68 05 08 00 00       	push   $0x805
  801010:	56                   	push   %esi
  801011:	57                   	push   %edi
  801012:	56                   	push   %esi
  801013:	6a 00                	push   $0x0
  801015:	e8 8a fc ff ff       	call   800ca4 <sys_page_map>
		if (r < 0) panic("duppage sys_page_map error : %e\n", r);
  80101a:	83 c4 20             	add    $0x20,%esp
  80101d:	85 c0                	test   %eax,%eax
  80101f:	79 12                	jns    801033 <fork+0x135>
  801021:	50                   	push   %eax
  801022:	68 7c 26 80 00       	push   $0x80267c
  801027:	6a 59                	push   $0x59
  801029:	68 30 27 80 00       	push   $0x802730
  80102e:	e8 3d f1 ff ff       	call   800170 <_panic>
		
		r = sys_page_map(0, addr, 0, addr, PTE_COW | PTE_P | PTE_U);
  801033:	83 ec 0c             	sub    $0xc,%esp
  801036:	68 05 08 00 00       	push   $0x805
  80103b:	56                   	push   %esi
  80103c:	6a 00                	push   $0x0
  80103e:	56                   	push   %esi
  80103f:	6a 00                	push   $0x0
  801041:	e8 5e fc ff ff       	call   800ca4 <sys_page_map>
		if (r < 0) panic("duppage sys_page_map error : %e\n", r);
  801046:	83 c4 20             	add    $0x20,%esp
  801049:	85 c0                	test   %eax,%eax
  80104b:	79 3a                	jns    801087 <fork+0x189>
  80104d:	50                   	push   %eax
  80104e:	68 7c 26 80 00       	push   $0x80267c
  801053:	6a 5c                	push   $0x5c
  801055:	68 30 27 80 00       	push   $0x802730
  80105a:	e8 11 f1 ff ff       	call   800170 <_panic>
	} else {
		// read only
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U);
  80105f:	83 ec 0c             	sub    $0xc,%esp
  801062:	6a 05                	push   $0x5
  801064:	56                   	push   %esi
  801065:	57                   	push   %edi
  801066:	56                   	push   %esi
  801067:	6a 00                	push   $0x0
  801069:	e8 36 fc ff ff       	call   800ca4 <sys_page_map>
		if (r < 0) panic("duppage sys_page_map error : %e\n", r);
  80106e:	83 c4 20             	add    $0x20,%esp
  801071:	85 c0                	test   %eax,%eax
  801073:	79 12                	jns    801087 <fork+0x189>
  801075:	50                   	push   %eax
  801076:	68 7c 26 80 00       	push   $0x80267c
  80107b:	6a 60                	push   $0x60
  80107d:	68 30 27 80 00       	push   $0x802730
  801082:	e8 e9 f0 ff ff       	call   800170 <_panic>
		return 0;
	} else {
		// map page to new environment
		// kernel page is already in new environment
		uint32_t i;
		for (i = 0; i != UTOP; i += PGSIZE) 
  801087:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  80108d:	81 fb 00 00 c0 ee    	cmp    $0xeec00000,%ebx
  801093:	0f 85 ca fe ff ff    	jne    800f63 <fork+0x65>
		if ((uvpd[PDX(i)] & PTE_P) && (uvpt[i / PGSIZE] & PTE_P) && (uvpt[i / PGSIZE] & PTE_U)) {
			duppage(childpid, i / PGSIZE);
		}

		// allocate exception stack
		r = sys_page_alloc(childpid, (void *)(UXSTACKTOP - PGSIZE), PTE_U | PTE_W | PTE_P);
  801099:	83 ec 04             	sub    $0x4,%esp
  80109c:	6a 07                	push   $0x7
  80109e:	68 00 f0 bf ee       	push   $0xeebff000
  8010a3:	ff 75 e4             	pushl  -0x1c(%ebp)
  8010a6:	e8 d5 fb ff ff       	call   800c80 <sys_page_alloc>
		if (r < 0) panic("fork, sys_page_alloc user exception stack error : %e\n", r);
  8010ab:	83 c4 10             	add    $0x10,%esp
  8010ae:	85 c0                	test   %eax,%eax
  8010b0:	79 15                	jns    8010c7 <fork+0x1c9>
  8010b2:	50                   	push   %eax
  8010b3:	68 a0 26 80 00       	push   $0x8026a0
  8010b8:	68 94 00 00 00       	push   $0x94
  8010bd:	68 30 27 80 00       	push   $0x802730
  8010c2:	e8 a9 f0 ff ff       	call   800170 <_panic>

		// set user environment user page fault handler 
		extern void _pgfault_upcall(void);
		r = sys_env_set_pgfault_upcall(childpid, _pgfault_upcall);
  8010c7:	83 ec 08             	sub    $0x8,%esp
  8010ca:	68 64 1e 80 00       	push   $0x801e64
  8010cf:	ff 75 e4             	pushl  -0x1c(%ebp)
  8010d2:	e8 5c fc ff ff       	call   800d33 <sys_env_set_pgfault_upcall>
		if (r < 0) panic("fork, set pgfault upcall fail : %e\n", r);
  8010d7:	83 c4 10             	add    $0x10,%esp
  8010da:	85 c0                	test   %eax,%eax
  8010dc:	79 15                	jns    8010f3 <fork+0x1f5>
  8010de:	50                   	push   %eax
  8010df:	68 d8 26 80 00       	push   $0x8026d8
  8010e4:	68 99 00 00 00       	push   $0x99
  8010e9:	68 30 27 80 00       	push   $0x802730
  8010ee:	e8 7d f0 ff ff       	call   800170 <_panic>
		r = sys_set_priority(childpid, num);
		if (r < 0) panic("fork, set priority error\n");
		*/

		// mark the child as runnable and return
		r = sys_env_set_status(childpid, ENV_RUNNABLE);
  8010f3:	83 ec 08             	sub    $0x8,%esp
  8010f6:	6a 02                	push   $0x2
  8010f8:	ff 75 e4             	pushl  -0x1c(%ebp)
  8010fb:	e8 ed fb ff ff       	call   800ced <sys_env_set_status>
		if (r < 0) panic("fork, set child process to ENV_RUNNABLE error : %e\n", r);
  801100:	83 c4 10             	add    $0x10,%esp
  801103:	85 c0                	test   %eax,%eax
  801105:	79 15                	jns    80111c <fork+0x21e>
  801107:	50                   	push   %eax
  801108:	68 fc 26 80 00       	push   $0x8026fc
  80110d:	68 a4 00 00 00       	push   $0xa4
  801112:	68 30 27 80 00       	push   $0x802730
  801117:	e8 54 f0 ff ff       	call   800170 <_panic>
		// cprintf("fork father ok!")
		return childpid;
	}

	panic("fork not implemented");
}
  80111c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80111f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801122:	5b                   	pop    %ebx
  801123:	5e                   	pop    %esi
  801124:	5f                   	pop    %edi
  801125:	c9                   	leave  
  801126:	c3                   	ret    

00801127 <sfork>:

// Challenge!
int
sfork(void)
{
  801127:	55                   	push   %ebp
  801128:	89 e5                	mov    %esp,%ebp
  80112a:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  80112d:	68 58 27 80 00       	push   $0x802758
  801132:	68 b1 00 00 00       	push   $0xb1
  801137:	68 30 27 80 00       	push   $0x802730
  80113c:	e8 2f f0 ff ff       	call   800170 <_panic>
  801141:	00 00                	add    %al,(%eax)
	...

00801144 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801144:	55                   	push   %ebp
  801145:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801147:	8b 45 08             	mov    0x8(%ebp),%eax
  80114a:	05 00 00 00 30       	add    $0x30000000,%eax
  80114f:	c1 e8 0c             	shr    $0xc,%eax
}
  801152:	c9                   	leave  
  801153:	c3                   	ret    

00801154 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801154:	55                   	push   %ebp
  801155:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  801157:	ff 75 08             	pushl  0x8(%ebp)
  80115a:	e8 e5 ff ff ff       	call   801144 <fd2num>
  80115f:	83 c4 04             	add    $0x4,%esp
  801162:	05 20 00 0d 00       	add    $0xd0020,%eax
  801167:	c1 e0 0c             	shl    $0xc,%eax
}
  80116a:	c9                   	leave  
  80116b:	c3                   	ret    

0080116c <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80116c:	55                   	push   %ebp
  80116d:	89 e5                	mov    %esp,%ebp
  80116f:	53                   	push   %ebx
  801170:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801173:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  801178:	a8 01                	test   $0x1,%al
  80117a:	74 34                	je     8011b0 <fd_alloc+0x44>
  80117c:	a1 00 00 74 ef       	mov    0xef740000,%eax
  801181:	a8 01                	test   $0x1,%al
  801183:	74 32                	je     8011b7 <fd_alloc+0x4b>
  801185:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
  80118a:	89 c1                	mov    %eax,%ecx
  80118c:	89 c2                	mov    %eax,%edx
  80118e:	c1 ea 16             	shr    $0x16,%edx
  801191:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801198:	f6 c2 01             	test   $0x1,%dl
  80119b:	74 1f                	je     8011bc <fd_alloc+0x50>
  80119d:	89 c2                	mov    %eax,%edx
  80119f:	c1 ea 0c             	shr    $0xc,%edx
  8011a2:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8011a9:	f6 c2 01             	test   $0x1,%dl
  8011ac:	75 17                	jne    8011c5 <fd_alloc+0x59>
  8011ae:	eb 0c                	jmp    8011bc <fd_alloc+0x50>
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  8011b0:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
  8011b5:	eb 05                	jmp    8011bc <fd_alloc+0x50>
  8011b7:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
  8011bc:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  8011be:	b8 00 00 00 00       	mov    $0x0,%eax
  8011c3:	eb 17                	jmp    8011dc <fd_alloc+0x70>
  8011c5:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8011ca:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8011cf:	75 b9                	jne    80118a <fd_alloc+0x1e>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8011d1:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  8011d7:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8011dc:	5b                   	pop    %ebx
  8011dd:	c9                   	leave  
  8011de:	c3                   	ret    

008011df <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8011df:	55                   	push   %ebp
  8011e0:	89 e5                	mov    %esp,%ebp
  8011e2:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8011e5:	83 f8 1f             	cmp    $0x1f,%eax
  8011e8:	77 36                	ja     801220 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8011ea:	05 00 00 0d 00       	add    $0xd0000,%eax
  8011ef:	c1 e0 0c             	shl    $0xc,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8011f2:	89 c2                	mov    %eax,%edx
  8011f4:	c1 ea 16             	shr    $0x16,%edx
  8011f7:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8011fe:	f6 c2 01             	test   $0x1,%dl
  801201:	74 24                	je     801227 <fd_lookup+0x48>
  801203:	89 c2                	mov    %eax,%edx
  801205:	c1 ea 0c             	shr    $0xc,%edx
  801208:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80120f:	f6 c2 01             	test   $0x1,%dl
  801212:	74 1a                	je     80122e <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801214:	8b 55 0c             	mov    0xc(%ebp),%edx
  801217:	89 02                	mov    %eax,(%edx)
	return 0;
  801219:	b8 00 00 00 00       	mov    $0x0,%eax
  80121e:	eb 13                	jmp    801233 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801220:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801225:	eb 0c                	jmp    801233 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801227:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80122c:	eb 05                	jmp    801233 <fd_lookup+0x54>
  80122e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801233:	c9                   	leave  
  801234:	c3                   	ret    

00801235 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801235:	55                   	push   %ebp
  801236:	89 e5                	mov    %esp,%ebp
  801238:	53                   	push   %ebx
  801239:	83 ec 04             	sub    $0x4,%esp
  80123c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80123f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  801242:	39 0d 04 30 80 00    	cmp    %ecx,0x803004
  801248:	74 0d                	je     801257 <dev_lookup+0x22>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80124a:	b8 00 00 00 00       	mov    $0x0,%eax
  80124f:	eb 14                	jmp    801265 <dev_lookup+0x30>
		if (devtab[i]->dev_id == dev_id) {
  801251:	39 0a                	cmp    %ecx,(%edx)
  801253:	75 10                	jne    801265 <dev_lookup+0x30>
  801255:	eb 05                	jmp    80125c <dev_lookup+0x27>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801257:	ba 04 30 80 00       	mov    $0x803004,%edx
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
  80125c:	89 13                	mov    %edx,(%ebx)
			return 0;
  80125e:	b8 00 00 00 00       	mov    $0x0,%eax
  801263:	eb 31                	jmp    801296 <dev_lookup+0x61>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801265:	40                   	inc    %eax
  801266:	8b 14 85 ec 27 80 00 	mov    0x8027ec(,%eax,4),%edx
  80126d:	85 d2                	test   %edx,%edx
  80126f:	75 e0                	jne    801251 <dev_lookup+0x1c>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801271:	a1 08 40 80 00       	mov    0x804008,%eax
  801276:	8b 40 48             	mov    0x48(%eax),%eax
  801279:	83 ec 04             	sub    $0x4,%esp
  80127c:	51                   	push   %ecx
  80127d:	50                   	push   %eax
  80127e:	68 70 27 80 00       	push   $0x802770
  801283:	e8 c0 ef ff ff       	call   800248 <cprintf>
	*dev = 0;
  801288:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  80128e:	83 c4 10             	add    $0x10,%esp
  801291:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801296:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801299:	c9                   	leave  
  80129a:	c3                   	ret    

0080129b <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80129b:	55                   	push   %ebp
  80129c:	89 e5                	mov    %esp,%ebp
  80129e:	56                   	push   %esi
  80129f:	53                   	push   %ebx
  8012a0:	83 ec 20             	sub    $0x20,%esp
  8012a3:	8b 75 08             	mov    0x8(%ebp),%esi
  8012a6:	8a 45 0c             	mov    0xc(%ebp),%al
  8012a9:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8012ac:	56                   	push   %esi
  8012ad:	e8 92 fe ff ff       	call   801144 <fd2num>
  8012b2:	8d 55 f4             	lea    -0xc(%ebp),%edx
  8012b5:	89 14 24             	mov    %edx,(%esp)
  8012b8:	50                   	push   %eax
  8012b9:	e8 21 ff ff ff       	call   8011df <fd_lookup>
  8012be:	89 c3                	mov    %eax,%ebx
  8012c0:	83 c4 08             	add    $0x8,%esp
  8012c3:	85 c0                	test   %eax,%eax
  8012c5:	78 05                	js     8012cc <fd_close+0x31>
	    || fd != fd2)
  8012c7:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8012ca:	74 0d                	je     8012d9 <fd_close+0x3e>
		return (must_exist ? r : 0);
  8012cc:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  8012d0:	75 48                	jne    80131a <fd_close+0x7f>
  8012d2:	bb 00 00 00 00       	mov    $0x0,%ebx
  8012d7:	eb 41                	jmp    80131a <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8012d9:	83 ec 08             	sub    $0x8,%esp
  8012dc:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012df:	50                   	push   %eax
  8012e0:	ff 36                	pushl  (%esi)
  8012e2:	e8 4e ff ff ff       	call   801235 <dev_lookup>
  8012e7:	89 c3                	mov    %eax,%ebx
  8012e9:	83 c4 10             	add    $0x10,%esp
  8012ec:	85 c0                	test   %eax,%eax
  8012ee:	78 1c                	js     80130c <fd_close+0x71>
		if (dev->dev_close)
  8012f0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012f3:	8b 40 10             	mov    0x10(%eax),%eax
  8012f6:	85 c0                	test   %eax,%eax
  8012f8:	74 0d                	je     801307 <fd_close+0x6c>
			r = (*dev->dev_close)(fd);
  8012fa:	83 ec 0c             	sub    $0xc,%esp
  8012fd:	56                   	push   %esi
  8012fe:	ff d0                	call   *%eax
  801300:	89 c3                	mov    %eax,%ebx
  801302:	83 c4 10             	add    $0x10,%esp
  801305:	eb 05                	jmp    80130c <fd_close+0x71>
		else
			r = 0;
  801307:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  80130c:	83 ec 08             	sub    $0x8,%esp
  80130f:	56                   	push   %esi
  801310:	6a 00                	push   $0x0
  801312:	e8 b3 f9 ff ff       	call   800cca <sys_page_unmap>
	return r;
  801317:	83 c4 10             	add    $0x10,%esp
}
  80131a:	89 d8                	mov    %ebx,%eax
  80131c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80131f:	5b                   	pop    %ebx
  801320:	5e                   	pop    %esi
  801321:	c9                   	leave  
  801322:	c3                   	ret    

00801323 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801323:	55                   	push   %ebp
  801324:	89 e5                	mov    %esp,%ebp
  801326:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801329:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80132c:	50                   	push   %eax
  80132d:	ff 75 08             	pushl  0x8(%ebp)
  801330:	e8 aa fe ff ff       	call   8011df <fd_lookup>
  801335:	83 c4 08             	add    $0x8,%esp
  801338:	85 c0                	test   %eax,%eax
  80133a:	78 10                	js     80134c <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  80133c:	83 ec 08             	sub    $0x8,%esp
  80133f:	6a 01                	push   $0x1
  801341:	ff 75 f4             	pushl  -0xc(%ebp)
  801344:	e8 52 ff ff ff       	call   80129b <fd_close>
  801349:	83 c4 10             	add    $0x10,%esp
}
  80134c:	c9                   	leave  
  80134d:	c3                   	ret    

0080134e <close_all>:

void
close_all(void)
{
  80134e:	55                   	push   %ebp
  80134f:	89 e5                	mov    %esp,%ebp
  801351:	53                   	push   %ebx
  801352:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801355:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80135a:	83 ec 0c             	sub    $0xc,%esp
  80135d:	53                   	push   %ebx
  80135e:	e8 c0 ff ff ff       	call   801323 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801363:	43                   	inc    %ebx
  801364:	83 c4 10             	add    $0x10,%esp
  801367:	83 fb 20             	cmp    $0x20,%ebx
  80136a:	75 ee                	jne    80135a <close_all+0xc>
		close(i);
}
  80136c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80136f:	c9                   	leave  
  801370:	c3                   	ret    

00801371 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801371:	55                   	push   %ebp
  801372:	89 e5                	mov    %esp,%ebp
  801374:	57                   	push   %edi
  801375:	56                   	push   %esi
  801376:	53                   	push   %ebx
  801377:	83 ec 2c             	sub    $0x2c,%esp
  80137a:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80137d:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801380:	50                   	push   %eax
  801381:	ff 75 08             	pushl  0x8(%ebp)
  801384:	e8 56 fe ff ff       	call   8011df <fd_lookup>
  801389:	89 c3                	mov    %eax,%ebx
  80138b:	83 c4 08             	add    $0x8,%esp
  80138e:	85 c0                	test   %eax,%eax
  801390:	0f 88 c0 00 00 00    	js     801456 <dup+0xe5>
		return r;
	close(newfdnum);
  801396:	83 ec 0c             	sub    $0xc,%esp
  801399:	57                   	push   %edi
  80139a:	e8 84 ff ff ff       	call   801323 <close>

	newfd = INDEX2FD(newfdnum);
  80139f:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  8013a5:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  8013a8:	83 c4 04             	add    $0x4,%esp
  8013ab:	ff 75 e4             	pushl  -0x1c(%ebp)
  8013ae:	e8 a1 fd ff ff       	call   801154 <fd2data>
  8013b3:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  8013b5:	89 34 24             	mov    %esi,(%esp)
  8013b8:	e8 97 fd ff ff       	call   801154 <fd2data>
  8013bd:	83 c4 10             	add    $0x10,%esp
  8013c0:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8013c3:	89 d8                	mov    %ebx,%eax
  8013c5:	c1 e8 16             	shr    $0x16,%eax
  8013c8:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8013cf:	a8 01                	test   $0x1,%al
  8013d1:	74 37                	je     80140a <dup+0x99>
  8013d3:	89 d8                	mov    %ebx,%eax
  8013d5:	c1 e8 0c             	shr    $0xc,%eax
  8013d8:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8013df:	f6 c2 01             	test   $0x1,%dl
  8013e2:	74 26                	je     80140a <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8013e4:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8013eb:	83 ec 0c             	sub    $0xc,%esp
  8013ee:	25 07 0e 00 00       	and    $0xe07,%eax
  8013f3:	50                   	push   %eax
  8013f4:	ff 75 d4             	pushl  -0x2c(%ebp)
  8013f7:	6a 00                	push   $0x0
  8013f9:	53                   	push   %ebx
  8013fa:	6a 00                	push   $0x0
  8013fc:	e8 a3 f8 ff ff       	call   800ca4 <sys_page_map>
  801401:	89 c3                	mov    %eax,%ebx
  801403:	83 c4 20             	add    $0x20,%esp
  801406:	85 c0                	test   %eax,%eax
  801408:	78 2d                	js     801437 <dup+0xc6>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80140a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80140d:	89 c2                	mov    %eax,%edx
  80140f:	c1 ea 0c             	shr    $0xc,%edx
  801412:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801419:	83 ec 0c             	sub    $0xc,%esp
  80141c:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  801422:	52                   	push   %edx
  801423:	56                   	push   %esi
  801424:	6a 00                	push   $0x0
  801426:	50                   	push   %eax
  801427:	6a 00                	push   $0x0
  801429:	e8 76 f8 ff ff       	call   800ca4 <sys_page_map>
  80142e:	89 c3                	mov    %eax,%ebx
  801430:	83 c4 20             	add    $0x20,%esp
  801433:	85 c0                	test   %eax,%eax
  801435:	79 1d                	jns    801454 <dup+0xe3>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801437:	83 ec 08             	sub    $0x8,%esp
  80143a:	56                   	push   %esi
  80143b:	6a 00                	push   $0x0
  80143d:	e8 88 f8 ff ff       	call   800cca <sys_page_unmap>
	sys_page_unmap(0, nva);
  801442:	83 c4 08             	add    $0x8,%esp
  801445:	ff 75 d4             	pushl  -0x2c(%ebp)
  801448:	6a 00                	push   $0x0
  80144a:	e8 7b f8 ff ff       	call   800cca <sys_page_unmap>
	return r;
  80144f:	83 c4 10             	add    $0x10,%esp
  801452:	eb 02                	jmp    801456 <dup+0xe5>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  801454:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  801456:	89 d8                	mov    %ebx,%eax
  801458:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80145b:	5b                   	pop    %ebx
  80145c:	5e                   	pop    %esi
  80145d:	5f                   	pop    %edi
  80145e:	c9                   	leave  
  80145f:	c3                   	ret    

00801460 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801460:	55                   	push   %ebp
  801461:	89 e5                	mov    %esp,%ebp
  801463:	53                   	push   %ebx
  801464:	83 ec 14             	sub    $0x14,%esp
  801467:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80146a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80146d:	50                   	push   %eax
  80146e:	53                   	push   %ebx
  80146f:	e8 6b fd ff ff       	call   8011df <fd_lookup>
  801474:	83 c4 08             	add    $0x8,%esp
  801477:	85 c0                	test   %eax,%eax
  801479:	78 67                	js     8014e2 <read+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80147b:	83 ec 08             	sub    $0x8,%esp
  80147e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801481:	50                   	push   %eax
  801482:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801485:	ff 30                	pushl  (%eax)
  801487:	e8 a9 fd ff ff       	call   801235 <dev_lookup>
  80148c:	83 c4 10             	add    $0x10,%esp
  80148f:	85 c0                	test   %eax,%eax
  801491:	78 4f                	js     8014e2 <read+0x82>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801493:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801496:	8b 50 08             	mov    0x8(%eax),%edx
  801499:	83 e2 03             	and    $0x3,%edx
  80149c:	83 fa 01             	cmp    $0x1,%edx
  80149f:	75 21                	jne    8014c2 <read+0x62>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8014a1:	a1 08 40 80 00       	mov    0x804008,%eax
  8014a6:	8b 40 48             	mov    0x48(%eax),%eax
  8014a9:	83 ec 04             	sub    $0x4,%esp
  8014ac:	53                   	push   %ebx
  8014ad:	50                   	push   %eax
  8014ae:	68 b1 27 80 00       	push   $0x8027b1
  8014b3:	e8 90 ed ff ff       	call   800248 <cprintf>
		return -E_INVAL;
  8014b8:	83 c4 10             	add    $0x10,%esp
  8014bb:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8014c0:	eb 20                	jmp    8014e2 <read+0x82>
	}
	if (!dev->dev_read)
  8014c2:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8014c5:	8b 52 08             	mov    0x8(%edx),%edx
  8014c8:	85 d2                	test   %edx,%edx
  8014ca:	74 11                	je     8014dd <read+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8014cc:	83 ec 04             	sub    $0x4,%esp
  8014cf:	ff 75 10             	pushl  0x10(%ebp)
  8014d2:	ff 75 0c             	pushl  0xc(%ebp)
  8014d5:	50                   	push   %eax
  8014d6:	ff d2                	call   *%edx
  8014d8:	83 c4 10             	add    $0x10,%esp
  8014db:	eb 05                	jmp    8014e2 <read+0x82>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8014dd:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  8014e2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014e5:	c9                   	leave  
  8014e6:	c3                   	ret    

008014e7 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8014e7:	55                   	push   %ebp
  8014e8:	89 e5                	mov    %esp,%ebp
  8014ea:	57                   	push   %edi
  8014eb:	56                   	push   %esi
  8014ec:	53                   	push   %ebx
  8014ed:	83 ec 0c             	sub    $0xc,%esp
  8014f0:	8b 7d 08             	mov    0x8(%ebp),%edi
  8014f3:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8014f6:	85 f6                	test   %esi,%esi
  8014f8:	74 31                	je     80152b <readn+0x44>
  8014fa:	b8 00 00 00 00       	mov    $0x0,%eax
  8014ff:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = read(fdnum, (char*)buf + tot, n - tot);
  801504:	83 ec 04             	sub    $0x4,%esp
  801507:	89 f2                	mov    %esi,%edx
  801509:	29 c2                	sub    %eax,%edx
  80150b:	52                   	push   %edx
  80150c:	03 45 0c             	add    0xc(%ebp),%eax
  80150f:	50                   	push   %eax
  801510:	57                   	push   %edi
  801511:	e8 4a ff ff ff       	call   801460 <read>
		if (m < 0)
  801516:	83 c4 10             	add    $0x10,%esp
  801519:	85 c0                	test   %eax,%eax
  80151b:	78 17                	js     801534 <readn+0x4d>
			return m;
		if (m == 0)
  80151d:	85 c0                	test   %eax,%eax
  80151f:	74 11                	je     801532 <readn+0x4b>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801521:	01 c3                	add    %eax,%ebx
  801523:	89 d8                	mov    %ebx,%eax
  801525:	39 f3                	cmp    %esi,%ebx
  801527:	72 db                	jb     801504 <readn+0x1d>
  801529:	eb 09                	jmp    801534 <readn+0x4d>
  80152b:	b8 00 00 00 00       	mov    $0x0,%eax
  801530:	eb 02                	jmp    801534 <readn+0x4d>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  801532:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  801534:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801537:	5b                   	pop    %ebx
  801538:	5e                   	pop    %esi
  801539:	5f                   	pop    %edi
  80153a:	c9                   	leave  
  80153b:	c3                   	ret    

0080153c <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
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
  80154b:	e8 8f fc ff ff       	call   8011df <fd_lookup>
  801550:	83 c4 08             	add    $0x8,%esp
  801553:	85 c0                	test   %eax,%eax
  801555:	78 62                	js     8015b9 <write+0x7d>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801557:	83 ec 08             	sub    $0x8,%esp
  80155a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80155d:	50                   	push   %eax
  80155e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801561:	ff 30                	pushl  (%eax)
  801563:	e8 cd fc ff ff       	call   801235 <dev_lookup>
  801568:	83 c4 10             	add    $0x10,%esp
  80156b:	85 c0                	test   %eax,%eax
  80156d:	78 4a                	js     8015b9 <write+0x7d>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80156f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801572:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801576:	75 21                	jne    801599 <write+0x5d>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801578:	a1 08 40 80 00       	mov    0x804008,%eax
  80157d:	8b 40 48             	mov    0x48(%eax),%eax
  801580:	83 ec 04             	sub    $0x4,%esp
  801583:	53                   	push   %ebx
  801584:	50                   	push   %eax
  801585:	68 cd 27 80 00       	push   $0x8027cd
  80158a:	e8 b9 ec ff ff       	call   800248 <cprintf>
		return -E_INVAL;
  80158f:	83 c4 10             	add    $0x10,%esp
  801592:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801597:	eb 20                	jmp    8015b9 <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801599:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80159c:	8b 52 0c             	mov    0xc(%edx),%edx
  80159f:	85 d2                	test   %edx,%edx
  8015a1:	74 11                	je     8015b4 <write+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8015a3:	83 ec 04             	sub    $0x4,%esp
  8015a6:	ff 75 10             	pushl  0x10(%ebp)
  8015a9:	ff 75 0c             	pushl  0xc(%ebp)
  8015ac:	50                   	push   %eax
  8015ad:	ff d2                	call   *%edx
  8015af:	83 c4 10             	add    $0x10,%esp
  8015b2:	eb 05                	jmp    8015b9 <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8015b4:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  8015b9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015bc:	c9                   	leave  
  8015bd:	c3                   	ret    

008015be <seek>:

int
seek(int fdnum, off_t offset)
{
  8015be:	55                   	push   %ebp
  8015bf:	89 e5                	mov    %esp,%ebp
  8015c1:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8015c4:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8015c7:	50                   	push   %eax
  8015c8:	ff 75 08             	pushl  0x8(%ebp)
  8015cb:	e8 0f fc ff ff       	call   8011df <fd_lookup>
  8015d0:	83 c4 08             	add    $0x8,%esp
  8015d3:	85 c0                	test   %eax,%eax
  8015d5:	78 0e                	js     8015e5 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8015d7:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8015da:	8b 55 0c             	mov    0xc(%ebp),%edx
  8015dd:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8015e0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8015e5:	c9                   	leave  
  8015e6:	c3                   	ret    

008015e7 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8015e7:	55                   	push   %ebp
  8015e8:	89 e5                	mov    %esp,%ebp
  8015ea:	53                   	push   %ebx
  8015eb:	83 ec 14             	sub    $0x14,%esp
  8015ee:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015f1:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015f4:	50                   	push   %eax
  8015f5:	53                   	push   %ebx
  8015f6:	e8 e4 fb ff ff       	call   8011df <fd_lookup>
  8015fb:	83 c4 08             	add    $0x8,%esp
  8015fe:	85 c0                	test   %eax,%eax
  801600:	78 5f                	js     801661 <ftruncate+0x7a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801602:	83 ec 08             	sub    $0x8,%esp
  801605:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801608:	50                   	push   %eax
  801609:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80160c:	ff 30                	pushl  (%eax)
  80160e:	e8 22 fc ff ff       	call   801235 <dev_lookup>
  801613:	83 c4 10             	add    $0x10,%esp
  801616:	85 c0                	test   %eax,%eax
  801618:	78 47                	js     801661 <ftruncate+0x7a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80161a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80161d:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801621:	75 21                	jne    801644 <ftruncate+0x5d>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801623:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801628:	8b 40 48             	mov    0x48(%eax),%eax
  80162b:	83 ec 04             	sub    $0x4,%esp
  80162e:	53                   	push   %ebx
  80162f:	50                   	push   %eax
  801630:	68 90 27 80 00       	push   $0x802790
  801635:	e8 0e ec ff ff       	call   800248 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80163a:	83 c4 10             	add    $0x10,%esp
  80163d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801642:	eb 1d                	jmp    801661 <ftruncate+0x7a>
	}
	if (!dev->dev_trunc)
  801644:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801647:	8b 52 18             	mov    0x18(%edx),%edx
  80164a:	85 d2                	test   %edx,%edx
  80164c:	74 0e                	je     80165c <ftruncate+0x75>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80164e:	83 ec 08             	sub    $0x8,%esp
  801651:	ff 75 0c             	pushl  0xc(%ebp)
  801654:	50                   	push   %eax
  801655:	ff d2                	call   *%edx
  801657:	83 c4 10             	add    $0x10,%esp
  80165a:	eb 05                	jmp    801661 <ftruncate+0x7a>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80165c:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  801661:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801664:	c9                   	leave  
  801665:	c3                   	ret    

00801666 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801666:	55                   	push   %ebp
  801667:	89 e5                	mov    %esp,%ebp
  801669:	53                   	push   %ebx
  80166a:	83 ec 14             	sub    $0x14,%esp
  80166d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801670:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801673:	50                   	push   %eax
  801674:	ff 75 08             	pushl  0x8(%ebp)
  801677:	e8 63 fb ff ff       	call   8011df <fd_lookup>
  80167c:	83 c4 08             	add    $0x8,%esp
  80167f:	85 c0                	test   %eax,%eax
  801681:	78 52                	js     8016d5 <fstat+0x6f>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801683:	83 ec 08             	sub    $0x8,%esp
  801686:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801689:	50                   	push   %eax
  80168a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80168d:	ff 30                	pushl  (%eax)
  80168f:	e8 a1 fb ff ff       	call   801235 <dev_lookup>
  801694:	83 c4 10             	add    $0x10,%esp
  801697:	85 c0                	test   %eax,%eax
  801699:	78 3a                	js     8016d5 <fstat+0x6f>
		return r;
	if (!dev->dev_stat)
  80169b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80169e:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8016a2:	74 2c                	je     8016d0 <fstat+0x6a>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8016a4:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8016a7:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8016ae:	00 00 00 
	stat->st_isdir = 0;
  8016b1:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8016b8:	00 00 00 
	stat->st_dev = dev;
  8016bb:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8016c1:	83 ec 08             	sub    $0x8,%esp
  8016c4:	53                   	push   %ebx
  8016c5:	ff 75 f0             	pushl  -0x10(%ebp)
  8016c8:	ff 50 14             	call   *0x14(%eax)
  8016cb:	83 c4 10             	add    $0x10,%esp
  8016ce:	eb 05                	jmp    8016d5 <fstat+0x6f>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8016d0:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8016d5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016d8:	c9                   	leave  
  8016d9:	c3                   	ret    

008016da <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8016da:	55                   	push   %ebp
  8016db:	89 e5                	mov    %esp,%ebp
  8016dd:	56                   	push   %esi
  8016de:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8016df:	83 ec 08             	sub    $0x8,%esp
  8016e2:	6a 00                	push   $0x0
  8016e4:	ff 75 08             	pushl  0x8(%ebp)
  8016e7:	e8 78 01 00 00       	call   801864 <open>
  8016ec:	89 c3                	mov    %eax,%ebx
  8016ee:	83 c4 10             	add    $0x10,%esp
  8016f1:	85 c0                	test   %eax,%eax
  8016f3:	78 1b                	js     801710 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8016f5:	83 ec 08             	sub    $0x8,%esp
  8016f8:	ff 75 0c             	pushl  0xc(%ebp)
  8016fb:	50                   	push   %eax
  8016fc:	e8 65 ff ff ff       	call   801666 <fstat>
  801701:	89 c6                	mov    %eax,%esi
	close(fd);
  801703:	89 1c 24             	mov    %ebx,(%esp)
  801706:	e8 18 fc ff ff       	call   801323 <close>
	return r;
  80170b:	83 c4 10             	add    $0x10,%esp
  80170e:	89 f3                	mov    %esi,%ebx
}
  801710:	89 d8                	mov    %ebx,%eax
  801712:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801715:	5b                   	pop    %ebx
  801716:	5e                   	pop    %esi
  801717:	c9                   	leave  
  801718:	c3                   	ret    
  801719:	00 00                	add    %al,(%eax)
	...

0080171c <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80171c:	55                   	push   %ebp
  80171d:	89 e5                	mov    %esp,%ebp
  80171f:	56                   	push   %esi
  801720:	53                   	push   %ebx
  801721:	89 c3                	mov    %eax,%ebx
  801723:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  801725:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  80172c:	75 12                	jne    801740 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80172e:	83 ec 0c             	sub    $0xc,%esp
  801731:	6a 01                	push   $0x1
  801733:	e8 1e 08 00 00       	call   801f56 <ipc_find_env>
  801738:	a3 00 40 80 00       	mov    %eax,0x804000
  80173d:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801740:	6a 07                	push   $0x7
  801742:	68 00 50 80 00       	push   $0x805000
  801747:	53                   	push   %ebx
  801748:	ff 35 00 40 80 00    	pushl  0x804000
  80174e:	e8 ae 07 00 00       	call   801f01 <ipc_send>
	
	return ipc_recv(NULL, dstva, NULL);
  801753:	83 c4 0c             	add    $0xc,%esp
  801756:	6a 00                	push   $0x0
  801758:	56                   	push   %esi
  801759:	6a 00                	push   $0x0
  80175b:	e8 2c 07 00 00       	call   801e8c <ipc_recv>
}
  801760:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801763:	5b                   	pop    %ebx
  801764:	5e                   	pop    %esi
  801765:	c9                   	leave  
  801766:	c3                   	ret    

00801767 <devfile_stat>:
}


static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801767:	55                   	push   %ebp
  801768:	89 e5                	mov    %esp,%ebp
  80176a:	53                   	push   %ebx
  80176b:	83 ec 04             	sub    $0x4,%esp
  80176e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801771:	8b 45 08             	mov    0x8(%ebp),%eax
  801774:	8b 40 0c             	mov    0xc(%eax),%eax
  801777:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0) {
  80177c:	ba 00 00 00 00       	mov    $0x0,%edx
  801781:	b8 05 00 00 00       	mov    $0x5,%eax
  801786:	e8 91 ff ff ff       	call   80171c <fsipc>
  80178b:	85 c0                	test   %eax,%eax
  80178d:	78 2c                	js     8017bb <devfile_stat+0x54>
		return r;
	}
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80178f:	83 ec 08             	sub    $0x8,%esp
  801792:	68 00 50 80 00       	push   $0x805000
  801797:	53                   	push   %ebx
  801798:	e8 61 f0 ff ff       	call   8007fe <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  80179d:	a1 80 50 80 00       	mov    0x805080,%eax
  8017a2:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8017a8:	a1 84 50 80 00       	mov    0x805084,%eax
  8017ad:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8017b3:	83 c4 10             	add    $0x10,%esp
  8017b6:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8017bb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017be:	c9                   	leave  
  8017bf:	c3                   	ret    

008017c0 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8017c0:	55                   	push   %ebp
  8017c1:	89 e5                	mov    %esp,%ebp
  8017c3:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8017c6:	8b 45 08             	mov    0x8(%ebp),%eax
  8017c9:	8b 40 0c             	mov    0xc(%eax),%eax
  8017cc:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8017d1:	ba 00 00 00 00       	mov    $0x0,%edx
  8017d6:	b8 06 00 00 00       	mov    $0x6,%eax
  8017db:	e8 3c ff ff ff       	call   80171c <fsipc>
}
  8017e0:	c9                   	leave  
  8017e1:	c3                   	ret    

008017e2 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8017e2:	55                   	push   %ebp
  8017e3:	89 e5                	mov    %esp,%ebp
  8017e5:	56                   	push   %esi
  8017e6:	53                   	push   %ebx
  8017e7:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8017ea:	8b 45 08             	mov    0x8(%ebp),%eax
  8017ed:	8b 40 0c             	mov    0xc(%eax),%eax
  8017f0:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8017f5:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8017fb:	ba 00 00 00 00       	mov    $0x0,%edx
  801800:	b8 03 00 00 00       	mov    $0x3,%eax
  801805:	e8 12 ff ff ff       	call   80171c <fsipc>
  80180a:	89 c3                	mov    %eax,%ebx
  80180c:	85 c0                	test   %eax,%eax
  80180e:	78 4b                	js     80185b <devfile_read+0x79>
		return r;
	assert(r <= n);
  801810:	39 c6                	cmp    %eax,%esi
  801812:	73 16                	jae    80182a <devfile_read+0x48>
  801814:	68 fc 27 80 00       	push   $0x8027fc
  801819:	68 03 28 80 00       	push   $0x802803
  80181e:	6a 7d                	push   $0x7d
  801820:	68 18 28 80 00       	push   $0x802818
  801825:	e8 46 e9 ff ff       	call   800170 <_panic>
	assert(r <= PGSIZE);
  80182a:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80182f:	7e 16                	jle    801847 <devfile_read+0x65>
  801831:	68 23 28 80 00       	push   $0x802823
  801836:	68 03 28 80 00       	push   $0x802803
  80183b:	6a 7e                	push   $0x7e
  80183d:	68 18 28 80 00       	push   $0x802818
  801842:	e8 29 e9 ff ff       	call   800170 <_panic>
	memmove(buf, &fsipcbuf, r);
  801847:	83 ec 04             	sub    $0x4,%esp
  80184a:	50                   	push   %eax
  80184b:	68 00 50 80 00       	push   $0x805000
  801850:	ff 75 0c             	pushl  0xc(%ebp)
  801853:	e8 67 f1 ff ff       	call   8009bf <memmove>
	return r;
  801858:	83 c4 10             	add    $0x10,%esp
}
  80185b:	89 d8                	mov    %ebx,%eax
  80185d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801860:	5b                   	pop    %ebx
  801861:	5e                   	pop    %esi
  801862:	c9                   	leave  
  801863:	c3                   	ret    

00801864 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801864:	55                   	push   %ebp
  801865:	89 e5                	mov    %esp,%ebp
  801867:	56                   	push   %esi
  801868:	53                   	push   %ebx
  801869:	83 ec 1c             	sub    $0x1c,%esp
  80186c:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  80186f:	56                   	push   %esi
  801870:	e8 37 ef ff ff       	call   8007ac <strlen>
  801875:	83 c4 10             	add    $0x10,%esp
  801878:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  80187d:	7f 65                	jg     8018e4 <open+0x80>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80187f:	83 ec 0c             	sub    $0xc,%esp
  801882:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801885:	50                   	push   %eax
  801886:	e8 e1 f8 ff ff       	call   80116c <fd_alloc>
  80188b:	89 c3                	mov    %eax,%ebx
  80188d:	83 c4 10             	add    $0x10,%esp
  801890:	85 c0                	test   %eax,%eax
  801892:	78 55                	js     8018e9 <open+0x85>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801894:	83 ec 08             	sub    $0x8,%esp
  801897:	56                   	push   %esi
  801898:	68 00 50 80 00       	push   $0x805000
  80189d:	e8 5c ef ff ff       	call   8007fe <strcpy>
	fsipcbuf.open.req_omode = mode;
  8018a2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018a5:	a3 00 54 80 00       	mov    %eax,0x805400



	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8018aa:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8018ad:	b8 01 00 00 00       	mov    $0x1,%eax
  8018b2:	e8 65 fe ff ff       	call   80171c <fsipc>
  8018b7:	89 c3                	mov    %eax,%ebx
  8018b9:	83 c4 10             	add    $0x10,%esp
  8018bc:	85 c0                	test   %eax,%eax
  8018be:	79 12                	jns    8018d2 <open+0x6e>
		fd_close(fd, 0);
  8018c0:	83 ec 08             	sub    $0x8,%esp
  8018c3:	6a 00                	push   $0x0
  8018c5:	ff 75 f4             	pushl  -0xc(%ebp)
  8018c8:	e8 ce f9 ff ff       	call   80129b <fd_close>
		return r;
  8018cd:	83 c4 10             	add    $0x10,%esp
  8018d0:	eb 17                	jmp    8018e9 <open+0x85>
	}

	return fd2num(fd);
  8018d2:	83 ec 0c             	sub    $0xc,%esp
  8018d5:	ff 75 f4             	pushl  -0xc(%ebp)
  8018d8:	e8 67 f8 ff ff       	call   801144 <fd2num>
  8018dd:	89 c3                	mov    %eax,%ebx
  8018df:	83 c4 10             	add    $0x10,%esp
  8018e2:	eb 05                	jmp    8018e9 <open+0x85>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8018e4:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8018e9:	89 d8                	mov    %ebx,%eax
  8018eb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018ee:	5b                   	pop    %ebx
  8018ef:	5e                   	pop    %esi
  8018f0:	c9                   	leave  
  8018f1:	c3                   	ret    
	...

008018f4 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8018f4:	55                   	push   %ebp
  8018f5:	89 e5                	mov    %esp,%ebp
  8018f7:	56                   	push   %esi
  8018f8:	53                   	push   %ebx
  8018f9:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8018fc:	83 ec 0c             	sub    $0xc,%esp
  8018ff:	ff 75 08             	pushl  0x8(%ebp)
  801902:	e8 4d f8 ff ff       	call   801154 <fd2data>
  801907:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  801909:	83 c4 08             	add    $0x8,%esp
  80190c:	68 2f 28 80 00       	push   $0x80282f
  801911:	56                   	push   %esi
  801912:	e8 e7 ee ff ff       	call   8007fe <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801917:	8b 43 04             	mov    0x4(%ebx),%eax
  80191a:	2b 03                	sub    (%ebx),%eax
  80191c:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  801922:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  801929:	00 00 00 
	stat->st_dev = &devpipe;
  80192c:	c7 86 88 00 00 00 20 	movl   $0x803020,0x88(%esi)
  801933:	30 80 00 
	return 0;
}
  801936:	b8 00 00 00 00       	mov    $0x0,%eax
  80193b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80193e:	5b                   	pop    %ebx
  80193f:	5e                   	pop    %esi
  801940:	c9                   	leave  
  801941:	c3                   	ret    

00801942 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801942:	55                   	push   %ebp
  801943:	89 e5                	mov    %esp,%ebp
  801945:	53                   	push   %ebx
  801946:	83 ec 0c             	sub    $0xc,%esp
  801949:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  80194c:	53                   	push   %ebx
  80194d:	6a 00                	push   $0x0
  80194f:	e8 76 f3 ff ff       	call   800cca <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801954:	89 1c 24             	mov    %ebx,(%esp)
  801957:	e8 f8 f7 ff ff       	call   801154 <fd2data>
  80195c:	83 c4 08             	add    $0x8,%esp
  80195f:	50                   	push   %eax
  801960:	6a 00                	push   $0x0
  801962:	e8 63 f3 ff ff       	call   800cca <sys_page_unmap>
}
  801967:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80196a:	c9                   	leave  
  80196b:	c3                   	ret    

0080196c <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  80196c:	55                   	push   %ebp
  80196d:	89 e5                	mov    %esp,%ebp
  80196f:	57                   	push   %edi
  801970:	56                   	push   %esi
  801971:	53                   	push   %ebx
  801972:	83 ec 1c             	sub    $0x1c,%esp
  801975:	89 c7                	mov    %eax,%edi
  801977:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  80197a:	a1 08 40 80 00       	mov    0x804008,%eax
  80197f:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801982:	83 ec 0c             	sub    $0xc,%esp
  801985:	57                   	push   %edi
  801986:	e8 19 06 00 00       	call   801fa4 <pageref>
  80198b:	89 c6                	mov    %eax,%esi
  80198d:	83 c4 04             	add    $0x4,%esp
  801990:	ff 75 e4             	pushl  -0x1c(%ebp)
  801993:	e8 0c 06 00 00       	call   801fa4 <pageref>
  801998:	83 c4 10             	add    $0x10,%esp
  80199b:	39 c6                	cmp    %eax,%esi
  80199d:	0f 94 c0             	sete   %al
  8019a0:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  8019a3:	8b 15 08 40 80 00    	mov    0x804008,%edx
  8019a9:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  8019ac:	39 cb                	cmp    %ecx,%ebx
  8019ae:	75 08                	jne    8019b8 <_pipeisclosed+0x4c>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  8019b0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8019b3:	5b                   	pop    %ebx
  8019b4:	5e                   	pop    %esi
  8019b5:	5f                   	pop    %edi
  8019b6:	c9                   	leave  
  8019b7:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  8019b8:	83 f8 01             	cmp    $0x1,%eax
  8019bb:	75 bd                	jne    80197a <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8019bd:	8b 42 58             	mov    0x58(%edx),%eax
  8019c0:	6a 01                	push   $0x1
  8019c2:	50                   	push   %eax
  8019c3:	53                   	push   %ebx
  8019c4:	68 36 28 80 00       	push   $0x802836
  8019c9:	e8 7a e8 ff ff       	call   800248 <cprintf>
  8019ce:	83 c4 10             	add    $0x10,%esp
  8019d1:	eb a7                	jmp    80197a <_pipeisclosed+0xe>

008019d3 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8019d3:	55                   	push   %ebp
  8019d4:	89 e5                	mov    %esp,%ebp
  8019d6:	57                   	push   %edi
  8019d7:	56                   	push   %esi
  8019d8:	53                   	push   %ebx
  8019d9:	83 ec 28             	sub    $0x28,%esp
  8019dc:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  8019df:	56                   	push   %esi
  8019e0:	e8 6f f7 ff ff       	call   801154 <fd2data>
  8019e5:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8019e7:	83 c4 10             	add    $0x10,%esp
  8019ea:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8019ee:	75 4a                	jne    801a3a <devpipe_write+0x67>
  8019f0:	bf 00 00 00 00       	mov    $0x0,%edi
  8019f5:	eb 56                	jmp    801a4d <devpipe_write+0x7a>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  8019f7:	89 da                	mov    %ebx,%edx
  8019f9:	89 f0                	mov    %esi,%eax
  8019fb:	e8 6c ff ff ff       	call   80196c <_pipeisclosed>
  801a00:	85 c0                	test   %eax,%eax
  801a02:	75 4d                	jne    801a51 <devpipe_write+0x7e>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801a04:	e8 50 f2 ff ff       	call   800c59 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801a09:	8b 43 04             	mov    0x4(%ebx),%eax
  801a0c:	8b 13                	mov    (%ebx),%edx
  801a0e:	83 c2 20             	add    $0x20,%edx
  801a11:	39 d0                	cmp    %edx,%eax
  801a13:	73 e2                	jae    8019f7 <devpipe_write+0x24>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801a15:	89 c2                	mov    %eax,%edx
  801a17:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  801a1d:	79 05                	jns    801a24 <devpipe_write+0x51>
  801a1f:	4a                   	dec    %edx
  801a20:	83 ca e0             	or     $0xffffffe0,%edx
  801a23:	42                   	inc    %edx
  801a24:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801a27:	8a 0c 39             	mov    (%ecx,%edi,1),%cl
  801a2a:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801a2e:	40                   	inc    %eax
  801a2f:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801a32:	47                   	inc    %edi
  801a33:	39 7d 10             	cmp    %edi,0x10(%ebp)
  801a36:	77 07                	ja     801a3f <devpipe_write+0x6c>
  801a38:	eb 13                	jmp    801a4d <devpipe_write+0x7a>
  801a3a:	bf 00 00 00 00       	mov    $0x0,%edi
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801a3f:	8b 43 04             	mov    0x4(%ebx),%eax
  801a42:	8b 13                	mov    (%ebx),%edx
  801a44:	83 c2 20             	add    $0x20,%edx
  801a47:	39 d0                	cmp    %edx,%eax
  801a49:	73 ac                	jae    8019f7 <devpipe_write+0x24>
  801a4b:	eb c8                	jmp    801a15 <devpipe_write+0x42>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801a4d:	89 f8                	mov    %edi,%eax
  801a4f:	eb 05                	jmp    801a56 <devpipe_write+0x83>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801a51:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801a56:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a59:	5b                   	pop    %ebx
  801a5a:	5e                   	pop    %esi
  801a5b:	5f                   	pop    %edi
  801a5c:	c9                   	leave  
  801a5d:	c3                   	ret    

00801a5e <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801a5e:	55                   	push   %ebp
  801a5f:	89 e5                	mov    %esp,%ebp
  801a61:	57                   	push   %edi
  801a62:	56                   	push   %esi
  801a63:	53                   	push   %ebx
  801a64:	83 ec 18             	sub    $0x18,%esp
  801a67:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801a6a:	57                   	push   %edi
  801a6b:	e8 e4 f6 ff ff       	call   801154 <fd2data>
  801a70:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801a72:	83 c4 10             	add    $0x10,%esp
  801a75:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801a79:	75 44                	jne    801abf <devpipe_read+0x61>
  801a7b:	be 00 00 00 00       	mov    $0x0,%esi
  801a80:	eb 4f                	jmp    801ad1 <devpipe_read+0x73>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
				return i;
  801a82:	89 f0                	mov    %esi,%eax
  801a84:	eb 54                	jmp    801ada <devpipe_read+0x7c>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801a86:	89 da                	mov    %ebx,%edx
  801a88:	89 f8                	mov    %edi,%eax
  801a8a:	e8 dd fe ff ff       	call   80196c <_pipeisclosed>
  801a8f:	85 c0                	test   %eax,%eax
  801a91:	75 42                	jne    801ad5 <devpipe_read+0x77>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801a93:	e8 c1 f1 ff ff       	call   800c59 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801a98:	8b 03                	mov    (%ebx),%eax
  801a9a:	3b 43 04             	cmp    0x4(%ebx),%eax
  801a9d:	74 e7                	je     801a86 <devpipe_read+0x28>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801a9f:	25 1f 00 00 80       	and    $0x8000001f,%eax
  801aa4:	79 05                	jns    801aab <devpipe_read+0x4d>
  801aa6:	48                   	dec    %eax
  801aa7:	83 c8 e0             	or     $0xffffffe0,%eax
  801aaa:	40                   	inc    %eax
  801aab:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  801aaf:	8b 55 0c             	mov    0xc(%ebp),%edx
  801ab2:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  801ab5:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801ab7:	46                   	inc    %esi
  801ab8:	39 75 10             	cmp    %esi,0x10(%ebp)
  801abb:	77 07                	ja     801ac4 <devpipe_read+0x66>
  801abd:	eb 12                	jmp    801ad1 <devpipe_read+0x73>
  801abf:	be 00 00 00 00       	mov    $0x0,%esi
		while (p->p_rpos == p->p_wpos) {
  801ac4:	8b 03                	mov    (%ebx),%eax
  801ac6:	3b 43 04             	cmp    0x4(%ebx),%eax
  801ac9:	75 d4                	jne    801a9f <devpipe_read+0x41>
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801acb:	85 f6                	test   %esi,%esi
  801acd:	75 b3                	jne    801a82 <devpipe_read+0x24>
  801acf:	eb b5                	jmp    801a86 <devpipe_read+0x28>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801ad1:	89 f0                	mov    %esi,%eax
  801ad3:	eb 05                	jmp    801ada <devpipe_read+0x7c>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801ad5:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801ada:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801add:	5b                   	pop    %ebx
  801ade:	5e                   	pop    %esi
  801adf:	5f                   	pop    %edi
  801ae0:	c9                   	leave  
  801ae1:	c3                   	ret    

00801ae2 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801ae2:	55                   	push   %ebp
  801ae3:	89 e5                	mov    %esp,%ebp
  801ae5:	57                   	push   %edi
  801ae6:	56                   	push   %esi
  801ae7:	53                   	push   %ebx
  801ae8:	83 ec 28             	sub    $0x28,%esp
  801aeb:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801aee:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801af1:	50                   	push   %eax
  801af2:	e8 75 f6 ff ff       	call   80116c <fd_alloc>
  801af7:	89 c3                	mov    %eax,%ebx
  801af9:	83 c4 10             	add    $0x10,%esp
  801afc:	85 c0                	test   %eax,%eax
  801afe:	0f 88 24 01 00 00    	js     801c28 <pipe+0x146>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b04:	83 ec 04             	sub    $0x4,%esp
  801b07:	68 07 04 00 00       	push   $0x407
  801b0c:	ff 75 e4             	pushl  -0x1c(%ebp)
  801b0f:	6a 00                	push   $0x0
  801b11:	e8 6a f1 ff ff       	call   800c80 <sys_page_alloc>
  801b16:	89 c3                	mov    %eax,%ebx
  801b18:	83 c4 10             	add    $0x10,%esp
  801b1b:	85 c0                	test   %eax,%eax
  801b1d:	0f 88 05 01 00 00    	js     801c28 <pipe+0x146>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801b23:	83 ec 0c             	sub    $0xc,%esp
  801b26:	8d 45 e0             	lea    -0x20(%ebp),%eax
  801b29:	50                   	push   %eax
  801b2a:	e8 3d f6 ff ff       	call   80116c <fd_alloc>
  801b2f:	89 c3                	mov    %eax,%ebx
  801b31:	83 c4 10             	add    $0x10,%esp
  801b34:	85 c0                	test   %eax,%eax
  801b36:	0f 88 dc 00 00 00    	js     801c18 <pipe+0x136>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b3c:	83 ec 04             	sub    $0x4,%esp
  801b3f:	68 07 04 00 00       	push   $0x407
  801b44:	ff 75 e0             	pushl  -0x20(%ebp)
  801b47:	6a 00                	push   $0x0
  801b49:	e8 32 f1 ff ff       	call   800c80 <sys_page_alloc>
  801b4e:	89 c3                	mov    %eax,%ebx
  801b50:	83 c4 10             	add    $0x10,%esp
  801b53:	85 c0                	test   %eax,%eax
  801b55:	0f 88 bd 00 00 00    	js     801c18 <pipe+0x136>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801b5b:	83 ec 0c             	sub    $0xc,%esp
  801b5e:	ff 75 e4             	pushl  -0x1c(%ebp)
  801b61:	e8 ee f5 ff ff       	call   801154 <fd2data>
  801b66:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b68:	83 c4 0c             	add    $0xc,%esp
  801b6b:	68 07 04 00 00       	push   $0x407
  801b70:	50                   	push   %eax
  801b71:	6a 00                	push   $0x0
  801b73:	e8 08 f1 ff ff       	call   800c80 <sys_page_alloc>
  801b78:	89 c3                	mov    %eax,%ebx
  801b7a:	83 c4 10             	add    $0x10,%esp
  801b7d:	85 c0                	test   %eax,%eax
  801b7f:	0f 88 83 00 00 00    	js     801c08 <pipe+0x126>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b85:	83 ec 0c             	sub    $0xc,%esp
  801b88:	ff 75 e0             	pushl  -0x20(%ebp)
  801b8b:	e8 c4 f5 ff ff       	call   801154 <fd2data>
  801b90:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801b97:	50                   	push   %eax
  801b98:	6a 00                	push   $0x0
  801b9a:	56                   	push   %esi
  801b9b:	6a 00                	push   $0x0
  801b9d:	e8 02 f1 ff ff       	call   800ca4 <sys_page_map>
  801ba2:	89 c3                	mov    %eax,%ebx
  801ba4:	83 c4 20             	add    $0x20,%esp
  801ba7:	85 c0                	test   %eax,%eax
  801ba9:	78 4f                	js     801bfa <pipe+0x118>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801bab:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801bb1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801bb4:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801bb6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801bb9:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801bc0:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801bc6:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801bc9:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801bcb:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801bce:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801bd5:	83 ec 0c             	sub    $0xc,%esp
  801bd8:	ff 75 e4             	pushl  -0x1c(%ebp)
  801bdb:	e8 64 f5 ff ff       	call   801144 <fd2num>
  801be0:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  801be2:	83 c4 04             	add    $0x4,%esp
  801be5:	ff 75 e0             	pushl  -0x20(%ebp)
  801be8:	e8 57 f5 ff ff       	call   801144 <fd2num>
  801bed:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  801bf0:	83 c4 10             	add    $0x10,%esp
  801bf3:	bb 00 00 00 00       	mov    $0x0,%ebx
  801bf8:	eb 2e                	jmp    801c28 <pipe+0x146>

    err3:
	sys_page_unmap(0, va);
  801bfa:	83 ec 08             	sub    $0x8,%esp
  801bfd:	56                   	push   %esi
  801bfe:	6a 00                	push   $0x0
  801c00:	e8 c5 f0 ff ff       	call   800cca <sys_page_unmap>
  801c05:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801c08:	83 ec 08             	sub    $0x8,%esp
  801c0b:	ff 75 e0             	pushl  -0x20(%ebp)
  801c0e:	6a 00                	push   $0x0
  801c10:	e8 b5 f0 ff ff       	call   800cca <sys_page_unmap>
  801c15:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801c18:	83 ec 08             	sub    $0x8,%esp
  801c1b:	ff 75 e4             	pushl  -0x1c(%ebp)
  801c1e:	6a 00                	push   $0x0
  801c20:	e8 a5 f0 ff ff       	call   800cca <sys_page_unmap>
  801c25:	83 c4 10             	add    $0x10,%esp
    err:
	return r;
}
  801c28:	89 d8                	mov    %ebx,%eax
  801c2a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c2d:	5b                   	pop    %ebx
  801c2e:	5e                   	pop    %esi
  801c2f:	5f                   	pop    %edi
  801c30:	c9                   	leave  
  801c31:	c3                   	ret    

00801c32 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801c32:	55                   	push   %ebp
  801c33:	89 e5                	mov    %esp,%ebp
  801c35:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801c38:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c3b:	50                   	push   %eax
  801c3c:	ff 75 08             	pushl  0x8(%ebp)
  801c3f:	e8 9b f5 ff ff       	call   8011df <fd_lookup>
  801c44:	83 c4 10             	add    $0x10,%esp
  801c47:	85 c0                	test   %eax,%eax
  801c49:	78 18                	js     801c63 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801c4b:	83 ec 0c             	sub    $0xc,%esp
  801c4e:	ff 75 f4             	pushl  -0xc(%ebp)
  801c51:	e8 fe f4 ff ff       	call   801154 <fd2data>
	return _pipeisclosed(fd, p);
  801c56:	89 c2                	mov    %eax,%edx
  801c58:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c5b:	e8 0c fd ff ff       	call   80196c <_pipeisclosed>
  801c60:	83 c4 10             	add    $0x10,%esp
}
  801c63:	c9                   	leave  
  801c64:	c3                   	ret    
  801c65:	00 00                	add    %al,(%eax)
	...

00801c68 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801c68:	55                   	push   %ebp
  801c69:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801c6b:	b8 00 00 00 00       	mov    $0x0,%eax
  801c70:	c9                   	leave  
  801c71:	c3                   	ret    

00801c72 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801c72:	55                   	push   %ebp
  801c73:	89 e5                	mov    %esp,%ebp
  801c75:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801c78:	68 4e 28 80 00       	push   $0x80284e
  801c7d:	ff 75 0c             	pushl  0xc(%ebp)
  801c80:	e8 79 eb ff ff       	call   8007fe <strcpy>
	return 0;
}
  801c85:	b8 00 00 00 00       	mov    $0x0,%eax
  801c8a:	c9                   	leave  
  801c8b:	c3                   	ret    

00801c8c <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801c8c:	55                   	push   %ebp
  801c8d:	89 e5                	mov    %esp,%ebp
  801c8f:	57                   	push   %edi
  801c90:	56                   	push   %esi
  801c91:	53                   	push   %ebx
  801c92:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801c98:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801c9c:	74 45                	je     801ce3 <devcons_write+0x57>
  801c9e:	b8 00 00 00 00       	mov    $0x0,%eax
  801ca3:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801ca8:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801cae:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801cb1:	29 c3                	sub    %eax,%ebx
		if (m > sizeof(buf) - 1)
  801cb3:	83 fb 7f             	cmp    $0x7f,%ebx
  801cb6:	76 05                	jbe    801cbd <devcons_write+0x31>
			m = sizeof(buf) - 1;
  801cb8:	bb 7f 00 00 00       	mov    $0x7f,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  801cbd:	83 ec 04             	sub    $0x4,%esp
  801cc0:	53                   	push   %ebx
  801cc1:	03 45 0c             	add    0xc(%ebp),%eax
  801cc4:	50                   	push   %eax
  801cc5:	57                   	push   %edi
  801cc6:	e8 f4 ec ff ff       	call   8009bf <memmove>
		sys_cputs(buf, m);
  801ccb:	83 c4 08             	add    $0x8,%esp
  801cce:	53                   	push   %ebx
  801ccf:	57                   	push   %edi
  801cd0:	e8 f4 ee ff ff       	call   800bc9 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801cd5:	01 de                	add    %ebx,%esi
  801cd7:	89 f0                	mov    %esi,%eax
  801cd9:	83 c4 10             	add    $0x10,%esp
  801cdc:	3b 75 10             	cmp    0x10(%ebp),%esi
  801cdf:	72 cd                	jb     801cae <devcons_write+0x22>
  801ce1:	eb 05                	jmp    801ce8 <devcons_write+0x5c>
  801ce3:	be 00 00 00 00       	mov    $0x0,%esi
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801ce8:	89 f0                	mov    %esi,%eax
  801cea:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ced:	5b                   	pop    %ebx
  801cee:	5e                   	pop    %esi
  801cef:	5f                   	pop    %edi
  801cf0:	c9                   	leave  
  801cf1:	c3                   	ret    

00801cf2 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801cf2:	55                   	push   %ebp
  801cf3:	89 e5                	mov    %esp,%ebp
  801cf5:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  801cf8:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801cfc:	75 07                	jne    801d05 <devcons_read+0x13>
  801cfe:	eb 25                	jmp    801d25 <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801d00:	e8 54 ef ff ff       	call   800c59 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801d05:	e8 e5 ee ff ff       	call   800bef <sys_cgetc>
  801d0a:	85 c0                	test   %eax,%eax
  801d0c:	74 f2                	je     801d00 <devcons_read+0xe>
  801d0e:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  801d10:	85 c0                	test   %eax,%eax
  801d12:	78 1d                	js     801d31 <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801d14:	83 f8 04             	cmp    $0x4,%eax
  801d17:	74 13                	je     801d2c <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  801d19:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d1c:	88 10                	mov    %dl,(%eax)
	return 1;
  801d1e:	b8 01 00 00 00       	mov    $0x1,%eax
  801d23:	eb 0c                	jmp    801d31 <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  801d25:	b8 00 00 00 00       	mov    $0x0,%eax
  801d2a:	eb 05                	jmp    801d31 <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801d2c:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801d31:	c9                   	leave  
  801d32:	c3                   	ret    

00801d33 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801d33:	55                   	push   %ebp
  801d34:	89 e5                	mov    %esp,%ebp
  801d36:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801d39:	8b 45 08             	mov    0x8(%ebp),%eax
  801d3c:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801d3f:	6a 01                	push   $0x1
  801d41:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801d44:	50                   	push   %eax
  801d45:	e8 7f ee ff ff       	call   800bc9 <sys_cputs>
  801d4a:	83 c4 10             	add    $0x10,%esp
}
  801d4d:	c9                   	leave  
  801d4e:	c3                   	ret    

00801d4f <getchar>:

int
getchar(void)
{
  801d4f:	55                   	push   %ebp
  801d50:	89 e5                	mov    %esp,%ebp
  801d52:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801d55:	6a 01                	push   $0x1
  801d57:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801d5a:	50                   	push   %eax
  801d5b:	6a 00                	push   $0x0
  801d5d:	e8 fe f6 ff ff       	call   801460 <read>
	if (r < 0)
  801d62:	83 c4 10             	add    $0x10,%esp
  801d65:	85 c0                	test   %eax,%eax
  801d67:	78 0f                	js     801d78 <getchar+0x29>
		return r;
	if (r < 1)
  801d69:	85 c0                	test   %eax,%eax
  801d6b:	7e 06                	jle    801d73 <getchar+0x24>
		return -E_EOF;
	return c;
  801d6d:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801d71:	eb 05                	jmp    801d78 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801d73:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801d78:	c9                   	leave  
  801d79:	c3                   	ret    

00801d7a <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801d7a:	55                   	push   %ebp
  801d7b:	89 e5                	mov    %esp,%ebp
  801d7d:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801d80:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d83:	50                   	push   %eax
  801d84:	ff 75 08             	pushl  0x8(%ebp)
  801d87:	e8 53 f4 ff ff       	call   8011df <fd_lookup>
  801d8c:	83 c4 10             	add    $0x10,%esp
  801d8f:	85 c0                	test   %eax,%eax
  801d91:	78 11                	js     801da4 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801d93:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d96:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801d9c:	39 10                	cmp    %edx,(%eax)
  801d9e:	0f 94 c0             	sete   %al
  801da1:	0f b6 c0             	movzbl %al,%eax
}
  801da4:	c9                   	leave  
  801da5:	c3                   	ret    

00801da6 <opencons>:

int
opencons(void)
{
  801da6:	55                   	push   %ebp
  801da7:	89 e5                	mov    %esp,%ebp
  801da9:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801dac:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801daf:	50                   	push   %eax
  801db0:	e8 b7 f3 ff ff       	call   80116c <fd_alloc>
  801db5:	83 c4 10             	add    $0x10,%esp
  801db8:	85 c0                	test   %eax,%eax
  801dba:	78 3a                	js     801df6 <opencons+0x50>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801dbc:	83 ec 04             	sub    $0x4,%esp
  801dbf:	68 07 04 00 00       	push   $0x407
  801dc4:	ff 75 f4             	pushl  -0xc(%ebp)
  801dc7:	6a 00                	push   $0x0
  801dc9:	e8 b2 ee ff ff       	call   800c80 <sys_page_alloc>
  801dce:	83 c4 10             	add    $0x10,%esp
  801dd1:	85 c0                	test   %eax,%eax
  801dd3:	78 21                	js     801df6 <opencons+0x50>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801dd5:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801ddb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801dde:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801de0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801de3:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801dea:	83 ec 0c             	sub    $0xc,%esp
  801ded:	50                   	push   %eax
  801dee:	e8 51 f3 ff ff       	call   801144 <fd2num>
  801df3:	83 c4 10             	add    $0x10,%esp
}
  801df6:	c9                   	leave  
  801df7:	c3                   	ret    

00801df8 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801df8:	55                   	push   %ebp
  801df9:	89 e5                	mov    %esp,%ebp
  801dfb:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  801dfe:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801e05:	75 52                	jne    801e59 <set_pgfault_handler+0x61>
		// First time through!	
		// LAB 4: Your code here.

		//int sys_page_alloc(envid_t envid, void *va, int perm)
		r = sys_page_alloc(0, (void*)(UXSTACKTOP - PGSIZE), PTE_U | PTE_W | PTE_P);
  801e07:	83 ec 04             	sub    $0x4,%esp
  801e0a:	6a 07                	push   $0x7
  801e0c:	68 00 f0 bf ee       	push   $0xeebff000
  801e11:	6a 00                	push   $0x0
  801e13:	e8 68 ee ff ff       	call   800c80 <sys_page_alloc>
		if (r < 0) {
  801e18:	83 c4 10             	add    $0x10,%esp
  801e1b:	85 c0                	test   %eax,%eax
  801e1d:	79 12                	jns    801e31 <set_pgfault_handler+0x39>
			panic("sys_page_alloc error : %e\n", r);
  801e1f:	50                   	push   %eax
  801e20:	68 5a 28 80 00       	push   $0x80285a
  801e25:	6a 24                	push   $0x24
  801e27:	68 75 28 80 00       	push   $0x802875
  801e2c:	e8 3f e3 ff ff       	call   800170 <_panic>
		}

		// how to know envid, put 0, envid2env will help us to get curenv in syscall
		r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);		
  801e31:	83 ec 08             	sub    $0x8,%esp
  801e34:	68 64 1e 80 00       	push   $0x801e64
  801e39:	6a 00                	push   $0x0
  801e3b:	e8 f3 ee ff ff       	call   800d33 <sys_env_set_pgfault_upcall>
		if (r < 0) {
  801e40:	83 c4 10             	add    $0x10,%esp
  801e43:	85 c0                	test   %eax,%eax
  801e45:	79 12                	jns    801e59 <set_pgfault_handler+0x61>
			panic("sys_env_set_pgfault_upcall error : %e\n", r);
  801e47:	50                   	push   %eax
  801e48:	68 84 28 80 00       	push   $0x802884
  801e4d:	6a 2a                	push   $0x2a
  801e4f:	68 75 28 80 00       	push   $0x802875
  801e54:	e8 17 e3 ff ff       	call   800170 <_panic>
		}
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801e59:	8b 45 08             	mov    0x8(%ebp),%eax
  801e5c:	a3 00 60 80 00       	mov    %eax,0x806000
}
  801e61:	c9                   	leave  
  801e62:	c3                   	ret    
	...

00801e64 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801e64:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801e65:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  801e6a:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801e6c:	83 c4 04             	add    $0x4,%esp
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	
	// fix old esp
	movl 0x30(%esp), %eax
  801e6f:	8b 44 24 30          	mov    0x30(%esp),%eax
	subl $0x4, %eax
  801e73:	83 e8 04             	sub    $0x4,%eax
	movl %eax, 0x30(%esp)
  801e76:	89 44 24 30          	mov    %eax,0x30(%esp)

	// set trap-time %eip
	movl 0x28(%esp), %ebx
  801e7a:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	movl %ebx, (%eax)
  801e7e:	89 18                	mov    %ebx,(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $0x08, %esp 	// ignore err_code and fault_va
  801e80:	83 c4 08             	add    $0x8,%esp
	popal 				// restore registers
  801e83:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x04, %esp 	// ignore eip 
  801e84:	83 c4 04             	add    $0x4,%esp
	popfl				// modify eflags
  801e87:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  801e88:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  801e89:	c3                   	ret    
	...

00801e8c <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801e8c:	55                   	push   %ebp
  801e8d:	89 e5                	mov    %esp,%ebp
  801e8f:	56                   	push   %esi
  801e90:	53                   	push   %ebx
  801e91:	8b 75 08             	mov    0x8(%ebp),%esi
  801e94:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e97:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// cprintf("0x%x 0x%x 0x%x\n", (uint32_t)from_env_store, (uint32_t)pg, (uint32_t)perm_store);
	int r;
	if (pg != NULL) {
  801e9a:	85 c0                	test   %eax,%eax
  801e9c:	74 0e                	je     801eac <ipc_recv+0x20>
		r = sys_ipc_recv(pg);
  801e9e:	83 ec 0c             	sub    $0xc,%esp
  801ea1:	50                   	push   %eax
  801ea2:	e8 d4 ee ff ff       	call   800d7b <sys_ipc_recv>
  801ea7:	83 c4 10             	add    $0x10,%esp
  801eaa:	eb 10                	jmp    801ebc <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv((void *)UTOP);
  801eac:	83 ec 0c             	sub    $0xc,%esp
  801eaf:	68 00 00 c0 ee       	push   $0xeec00000
  801eb4:	e8 c2 ee ff ff       	call   800d7b <sys_ipc_recv>
  801eb9:	83 c4 10             	add    $0x10,%esp
	}

	if (r == 0) {
  801ebc:	85 c0                	test   %eax,%eax
  801ebe:	75 26                	jne    801ee6 <ipc_recv+0x5a>
		if (from_env_store != NULL) *from_env_store = thisenv->env_ipc_from;
  801ec0:	85 f6                	test   %esi,%esi
  801ec2:	74 0a                	je     801ece <ipc_recv+0x42>
  801ec4:	a1 08 40 80 00       	mov    0x804008,%eax
  801ec9:	8b 40 74             	mov    0x74(%eax),%eax
  801ecc:	89 06                	mov    %eax,(%esi)
		if (perm_store != NULL) *perm_store = thisenv->env_ipc_perm;
  801ece:	85 db                	test   %ebx,%ebx
  801ed0:	74 0a                	je     801edc <ipc_recv+0x50>
  801ed2:	a1 08 40 80 00       	mov    0x804008,%eax
  801ed7:	8b 40 78             	mov    0x78(%eax),%eax
  801eda:	89 03                	mov    %eax,(%ebx)
		return thisenv->env_ipc_value;
  801edc:	a1 08 40 80 00       	mov    0x804008,%eax
  801ee1:	8b 40 70             	mov    0x70(%eax),%eax
  801ee4:	eb 14                	jmp    801efa <ipc_recv+0x6e>
	} else {
		// fails;
		if (from_env_store != NULL) *from_env_store = 0;
  801ee6:	85 f6                	test   %esi,%esi
  801ee8:	74 06                	je     801ef0 <ipc_recv+0x64>
  801eea:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if (perm_store != NULL) *perm_store = 0;
  801ef0:	85 db                	test   %ebx,%ebx
  801ef2:	74 06                	je     801efa <ipc_recv+0x6e>
  801ef4:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		return r;
	}
}
  801efa:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801efd:	5b                   	pop    %ebx
  801efe:	5e                   	pop    %esi
  801eff:	c9                   	leave  
  801f00:	c3                   	ret    

00801f01 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801f01:	55                   	push   %ebp
  801f02:	89 e5                	mov    %esp,%ebp
  801f04:	57                   	push   %edi
  801f05:	56                   	push   %esi
  801f06:	53                   	push   %ebx
  801f07:	83 ec 0c             	sub    $0xc,%esp
  801f0a:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801f0d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801f10:	8b 75 14             	mov    0x14(%ebp),%esi
	// LAB 4: Your code here.
	// int sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
	int r;
	if (pg == NULL) pg = (void *)UTOP;
  801f13:	85 db                	test   %ebx,%ebx
  801f15:	75 25                	jne    801f3c <ipc_send+0x3b>
  801f17:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
  801f1c:	eb 1e                	jmp    801f3c <ipc_send+0x3b>
	
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) != 0) {
		if (r == -E_IPC_NOT_RECV) {
  801f1e:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801f21:	75 07                	jne    801f2a <ipc_send+0x29>
			// cprintf("Try Again and Again....\n");
			sys_yield();
  801f23:	e8 31 ed ff ff       	call   800c59 <sys_yield>
  801f28:	eb 12                	jmp    801f3c <ipc_send+0x3b>
		} else {
			panic("ipc_send error %e\n", r);
  801f2a:	50                   	push   %eax
  801f2b:	68 ac 28 80 00       	push   $0x8028ac
  801f30:	6a 43                	push   $0x43
  801f32:	68 bf 28 80 00       	push   $0x8028bf
  801f37:	e8 34 e2 ff ff       	call   800170 <_panic>
	// LAB 4: Your code here.
	// int sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
	int r;
	if (pg == NULL) pg = (void *)UTOP;
	
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) != 0) {
  801f3c:	56                   	push   %esi
  801f3d:	53                   	push   %ebx
  801f3e:	57                   	push   %edi
  801f3f:	ff 75 08             	pushl  0x8(%ebp)
  801f42:	e8 0f ee ff ff       	call   800d56 <sys_ipc_try_send>
  801f47:	83 c4 10             	add    $0x10,%esp
  801f4a:	85 c0                	test   %eax,%eax
  801f4c:	75 d0                	jne    801f1e <ipc_send+0x1d>
		} else {
			panic("ipc_send error %e\n", r);
		}
	}
	return;
}
  801f4e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f51:	5b                   	pop    %ebx
  801f52:	5e                   	pop    %esi
  801f53:	5f                   	pop    %edi
  801f54:	c9                   	leave  
  801f55:	c3                   	ret    

00801f56 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801f56:	55                   	push   %ebp
  801f57:	89 e5                	mov    %esp,%ebp
  801f59:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  801f5c:	39 0d 50 00 c0 ee    	cmp    %ecx,0xeec00050
  801f62:	74 1a                	je     801f7e <ipc_find_env+0x28>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801f64:	b8 01 00 00 00       	mov    $0x1,%eax
		if (envs[i].env_type == type)
  801f69:	89 c2                	mov    %eax,%edx
  801f6b:	c1 e2 07             	shl    $0x7,%edx
  801f6e:	8d 94 82 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,4),%edx
  801f75:	8b 52 50             	mov    0x50(%edx),%edx
  801f78:	39 ca                	cmp    %ecx,%edx
  801f7a:	75 18                	jne    801f94 <ipc_find_env+0x3e>
  801f7c:	eb 05                	jmp    801f83 <ipc_find_env+0x2d>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801f7e:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
			return envs[i].env_id;
  801f83:	89 c2                	mov    %eax,%edx
  801f85:	c1 e2 07             	shl    $0x7,%edx
  801f88:	8d 84 82 08 00 c0 ee 	lea    -0x113ffff8(%edx,%eax,4),%eax
  801f8f:	8b 40 40             	mov    0x40(%eax),%eax
  801f92:	eb 0c                	jmp    801fa0 <ipc_find_env+0x4a>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801f94:	40                   	inc    %eax
  801f95:	3d 00 04 00 00       	cmp    $0x400,%eax
  801f9a:	75 cd                	jne    801f69 <ipc_find_env+0x13>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801f9c:	66 b8 00 00          	mov    $0x0,%ax
}
  801fa0:	c9                   	leave  
  801fa1:	c3                   	ret    
	...

00801fa4 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801fa4:	55                   	push   %ebp
  801fa5:	89 e5                	mov    %esp,%ebp
  801fa7:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801faa:	89 c2                	mov    %eax,%edx
  801fac:	c1 ea 16             	shr    $0x16,%edx
  801faf:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801fb6:	f6 c2 01             	test   $0x1,%dl
  801fb9:	74 1e                	je     801fd9 <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  801fbb:	c1 e8 0c             	shr    $0xc,%eax
  801fbe:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801fc5:	a8 01                	test   $0x1,%al
  801fc7:	74 17                	je     801fe0 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801fc9:	c1 e8 0c             	shr    $0xc,%eax
  801fcc:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  801fd3:	ef 
  801fd4:	0f b7 c0             	movzwl %ax,%eax
  801fd7:	eb 0c                	jmp    801fe5 <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  801fd9:	b8 00 00 00 00       	mov    $0x0,%eax
  801fde:	eb 05                	jmp    801fe5 <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  801fe0:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  801fe5:	c9                   	leave  
  801fe6:	c3                   	ret    
	...

00801fe8 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  801fe8:	55                   	push   %ebp
  801fe9:	89 e5                	mov    %esp,%ebp
  801feb:	57                   	push   %edi
  801fec:	56                   	push   %esi
  801fed:	83 ec 10             	sub    $0x10,%esp
  801ff0:	8b 7d 08             	mov    0x8(%ebp),%edi
  801ff3:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  801ff6:	89 7d f0             	mov    %edi,-0x10(%ebp)
  801ff9:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  801ffc:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  801fff:	8b 45 14             	mov    0x14(%ebp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  802002:	85 c0                	test   %eax,%eax
  802004:	75 2e                	jne    802034 <__udivdi3+0x4c>
    {
      if (d0 > n1)
  802006:	39 f1                	cmp    %esi,%ecx
  802008:	77 5a                	ja     802064 <__udivdi3+0x7c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  80200a:	85 c9                	test   %ecx,%ecx
  80200c:	75 0b                	jne    802019 <__udivdi3+0x31>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  80200e:	b8 01 00 00 00       	mov    $0x1,%eax
  802013:	31 d2                	xor    %edx,%edx
  802015:	f7 f1                	div    %ecx
  802017:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  802019:	31 d2                	xor    %edx,%edx
  80201b:	89 f0                	mov    %esi,%eax
  80201d:	f7 f1                	div    %ecx
  80201f:	89 c6                	mov    %eax,%esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802021:	89 f8                	mov    %edi,%eax
  802023:	f7 f1                	div    %ecx
  802025:	89 c7                	mov    %eax,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  802027:	89 f8                	mov    %edi,%eax
  802029:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  80202b:	83 c4 10             	add    $0x10,%esp
  80202e:	5e                   	pop    %esi
  80202f:	5f                   	pop    %edi
  802030:	c9                   	leave  
  802031:	c3                   	ret    
  802032:	66 90                	xchg   %ax,%ax
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  802034:	39 f0                	cmp    %esi,%eax
  802036:	77 1c                	ja     802054 <__udivdi3+0x6c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  802038:	0f bd f8             	bsr    %eax,%edi
	  if (bm == 0)
  80203b:	83 f7 1f             	xor    $0x1f,%edi
  80203e:	75 3c                	jne    80207c <__udivdi3+0x94>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802040:	39 f0                	cmp    %esi,%eax
  802042:	0f 82 90 00 00 00    	jb     8020d8 <__udivdi3+0xf0>
  802048:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80204b:	39 55 f4             	cmp    %edx,-0xc(%ebp)
  80204e:	0f 86 84 00 00 00    	jbe    8020d8 <__udivdi3+0xf0>
  802054:	31 f6                	xor    %esi,%esi
  802056:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  802058:	89 f8                	mov    %edi,%eax
  80205a:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  80205c:	83 c4 10             	add    $0x10,%esp
  80205f:	5e                   	pop    %esi
  802060:	5f                   	pop    %edi
  802061:	c9                   	leave  
  802062:	c3                   	ret    
  802063:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802064:	89 f2                	mov    %esi,%edx
  802066:	89 f8                	mov    %edi,%eax
  802068:	f7 f1                	div    %ecx
  80206a:	89 c7                	mov    %eax,%edi
  80206c:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  80206e:	89 f8                	mov    %edi,%eax
  802070:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802072:	83 c4 10             	add    $0x10,%esp
  802075:	5e                   	pop    %esi
  802076:	5f                   	pop    %edi
  802077:	c9                   	leave  
  802078:	c3                   	ret    
  802079:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  80207c:	89 f9                	mov    %edi,%ecx
  80207e:	d3 e0                	shl    %cl,%eax
  802080:	89 45 e8             	mov    %eax,-0x18(%ebp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  802083:	b8 20 00 00 00       	mov    $0x20,%eax
  802088:	29 f8                	sub    %edi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  80208a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80208d:	88 c1                	mov    %al,%cl
  80208f:	d3 ea                	shr    %cl,%edx
  802091:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  802094:	09 ca                	or     %ecx,%edx
  802096:	89 55 ec             	mov    %edx,-0x14(%ebp)
	      d0 = d0 << bm;
  802099:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80209c:	89 f9                	mov    %edi,%ecx
  80209e:	d3 e2                	shl    %cl,%edx
  8020a0:	89 55 f4             	mov    %edx,-0xc(%ebp)
	      n2 = n1 >> b;
  8020a3:	89 f2                	mov    %esi,%edx
  8020a5:	88 c1                	mov    %al,%cl
  8020a7:	d3 ea                	shr    %cl,%edx
  8020a9:	89 55 e8             	mov    %edx,-0x18(%ebp)
	      n1 = (n1 << bm) | (n0 >> b);
  8020ac:	89 f2                	mov    %esi,%edx
  8020ae:	89 f9                	mov    %edi,%ecx
  8020b0:	d3 e2                	shl    %cl,%edx
  8020b2:	8b 75 f0             	mov    -0x10(%ebp),%esi
  8020b5:	88 c1                	mov    %al,%cl
  8020b7:	d3 ee                	shr    %cl,%esi
  8020b9:	09 d6                	or     %edx,%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  8020bb:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  8020be:	89 f0                	mov    %esi,%eax
  8020c0:	89 ca                	mov    %ecx,%edx
  8020c2:	f7 75 ec             	divl   -0x14(%ebp)
  8020c5:	89 d1                	mov    %edx,%ecx
  8020c7:	89 c6                	mov    %eax,%esi
	      umul_ppmm (m1, m0, q0, d0);
  8020c9:	f7 65 f4             	mull   -0xc(%ebp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8020cc:	39 d1                	cmp    %edx,%ecx
  8020ce:	72 28                	jb     8020f8 <__udivdi3+0x110>
  8020d0:	74 1a                	je     8020ec <__udivdi3+0x104>
  8020d2:	89 f7                	mov    %esi,%edi
  8020d4:	31 f6                	xor    %esi,%esi
  8020d6:	eb 80                	jmp    802058 <__udivdi3+0x70>
	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  8020d8:	31 f6                	xor    %esi,%esi
  8020da:	bf 01 00 00 00       	mov    $0x1,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  8020df:	89 f8                	mov    %edi,%eax
  8020e1:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  8020e3:	83 c4 10             	add    $0x10,%esp
  8020e6:	5e                   	pop    %esi
  8020e7:	5f                   	pop    %edi
  8020e8:	c9                   	leave  
  8020e9:	c3                   	ret    
  8020ea:	66 90                	xchg   %ax,%ax

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  8020ec:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8020ef:	89 f9                	mov    %edi,%ecx
  8020f1:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8020f3:	39 c2                	cmp    %eax,%edx
  8020f5:	73 db                	jae    8020d2 <__udivdi3+0xea>
  8020f7:	90                   	nop
		{
		  q0--;
  8020f8:	8d 7e ff             	lea    -0x1(%esi),%edi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  8020fb:	31 f6                	xor    %esi,%esi
  8020fd:	e9 56 ff ff ff       	jmp    802058 <__udivdi3+0x70>
	...

00802104 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  802104:	55                   	push   %ebp
  802105:	89 e5                	mov    %esp,%ebp
  802107:	57                   	push   %edi
  802108:	56                   	push   %esi
  802109:	83 ec 20             	sub    $0x20,%esp
  80210c:	8b 45 08             	mov    0x8(%ebp),%eax
  80210f:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  802112:	89 45 e8             	mov    %eax,-0x18(%ebp)
  802115:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  802118:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  80211b:	8b 7d 14             	mov    0x14(%ebp),%edi
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  80211e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  n1 = nn.s.high;
  802121:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  802123:	85 ff                	test   %edi,%edi
  802125:	75 15                	jne    80213c <__umoddi3+0x38>
    {
      if (d0 > n1)
  802127:	39 f1                	cmp    %esi,%ecx
  802129:	0f 86 99 00 00 00    	jbe    8021c8 <__umoddi3+0xc4>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  80212f:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  802131:	89 d0                	mov    %edx,%eax
  802133:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802135:	83 c4 20             	add    $0x20,%esp
  802138:	5e                   	pop    %esi
  802139:	5f                   	pop    %edi
  80213a:	c9                   	leave  
  80213b:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  80213c:	39 f7                	cmp    %esi,%edi
  80213e:	0f 87 a4 00 00 00    	ja     8021e8 <__umoddi3+0xe4>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  802144:	0f bd c7             	bsr    %edi,%eax
	  if (bm == 0)
  802147:	83 f0 1f             	xor    $0x1f,%eax
  80214a:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80214d:	0f 84 a1 00 00 00    	je     8021f4 <__umoddi3+0xf0>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  802153:	89 f8                	mov    %edi,%eax
  802155:	8a 4d ec             	mov    -0x14(%ebp),%cl
  802158:	d3 e0                	shl    %cl,%eax
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  80215a:	bf 20 00 00 00       	mov    $0x20,%edi
  80215f:	2b 7d ec             	sub    -0x14(%ebp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  802162:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802165:	89 f9                	mov    %edi,%ecx
  802167:	d3 ea                	shr    %cl,%edx
  802169:	09 c2                	or     %eax,%edx
  80216b:	89 55 f0             	mov    %edx,-0x10(%ebp)
	      d0 = d0 << bm;
  80216e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802171:	8a 4d ec             	mov    -0x14(%ebp),%cl
  802174:	d3 e0                	shl    %cl,%eax
  802176:	89 45 f4             	mov    %eax,-0xc(%ebp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  802179:	89 f2                	mov    %esi,%edx
  80217b:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  80217d:	8b 45 e8             	mov    -0x18(%ebp),%eax
  802180:	d3 e0                	shl    %cl,%eax
  802182:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  802185:	8b 45 e8             	mov    -0x18(%ebp),%eax
  802188:	89 f9                	mov    %edi,%ecx
  80218a:	d3 e8                	shr    %cl,%eax
  80218c:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  80218e:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  802190:	89 f2                	mov    %esi,%edx
  802192:	f7 75 f0             	divl   -0x10(%ebp)
  802195:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  802197:	f7 65 f4             	mull   -0xc(%ebp)
  80219a:	89 55 e8             	mov    %edx,-0x18(%ebp)
  80219d:	89 c1                	mov    %eax,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  80219f:	39 d6                	cmp    %edx,%esi
  8021a1:	72 71                	jb     802214 <__umoddi3+0x110>
  8021a3:	74 7f                	je     802224 <__umoddi3+0x120>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  8021a5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8021a8:	29 c8                	sub    %ecx,%eax
  8021aa:	19 d6                	sbb    %edx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  8021ac:	8a 4d ec             	mov    -0x14(%ebp),%cl
  8021af:	d3 e8                	shr    %cl,%eax
  8021b1:	89 f2                	mov    %esi,%edx
  8021b3:	89 f9                	mov    %edi,%ecx
  8021b5:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  8021b7:	09 d0                	or     %edx,%eax
  8021b9:	89 f2                	mov    %esi,%edx
  8021bb:	8a 4d ec             	mov    -0x14(%ebp),%cl
  8021be:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8021c0:	83 c4 20             	add    $0x20,%esp
  8021c3:	5e                   	pop    %esi
  8021c4:	5f                   	pop    %edi
  8021c5:	c9                   	leave  
  8021c6:	c3                   	ret    
  8021c7:	90                   	nop
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  8021c8:	85 c9                	test   %ecx,%ecx
  8021ca:	75 0b                	jne    8021d7 <__umoddi3+0xd3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  8021cc:	b8 01 00 00 00       	mov    $0x1,%eax
  8021d1:	31 d2                	xor    %edx,%edx
  8021d3:	f7 f1                	div    %ecx
  8021d5:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  8021d7:	89 f0                	mov    %esi,%eax
  8021d9:	31 d2                	xor    %edx,%edx
  8021db:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8021dd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8021e0:	f7 f1                	div    %ecx
  8021e2:	e9 4a ff ff ff       	jmp    802131 <__umoddi3+0x2d>
  8021e7:	90                   	nop
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  8021e8:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8021ea:	83 c4 20             	add    $0x20,%esp
  8021ed:	5e                   	pop    %esi
  8021ee:	5f                   	pop    %edi
  8021ef:	c9                   	leave  
  8021f0:	c3                   	ret    
  8021f1:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  8021f4:	39 f7                	cmp    %esi,%edi
  8021f6:	72 05                	jb     8021fd <__umoddi3+0xf9>
  8021f8:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
  8021fb:	77 0c                	ja     802209 <__umoddi3+0x105>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  8021fd:	89 f2                	mov    %esi,%edx
  8021ff:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802202:	29 c8                	sub    %ecx,%eax
  802204:	19 fa                	sbb    %edi,%edx
  802206:	89 45 f0             	mov    %eax,-0x10(%ebp)

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  802209:	8b 45 f0             	mov    -0x10(%ebp),%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  80220c:	83 c4 20             	add    $0x20,%esp
  80220f:	5e                   	pop    %esi
  802210:	5f                   	pop    %edi
  802211:	c9                   	leave  
  802212:	c3                   	ret    
  802213:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  802214:	8b 55 e8             	mov    -0x18(%ebp),%edx
  802217:	89 c1                	mov    %eax,%ecx
  802219:	2b 4d f4             	sub    -0xc(%ebp),%ecx
  80221c:	1b 55 f0             	sbb    -0x10(%ebp),%edx
  80221f:	eb 84                	jmp    8021a5 <__umoddi3+0xa1>
  802221:	8d 76 00             	lea    0x0(%esi),%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802224:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  802227:	72 eb                	jb     802214 <__umoddi3+0x110>
  802229:	89 f2                	mov    %esi,%edx
  80222b:	e9 75 ff ff ff       	jmp    8021a5 <__umoddi3+0xa1>
