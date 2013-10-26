
obj/user/stresssched:     file format elf32-i386


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
  800039:	e8 eb 0b 00 00       	call   800c29 <sys_getenvid>
  80003e:	89 c6                	mov    %eax,%esi

	// Fork several environments
	for (i = 0; i < 20; i++)
  800040:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (fork() == 0)
  800045:	e8 1c 0e 00 00       	call   800e66 <fork>
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
  800054:	eb 23                	jmp    800079 <umain+0x45>
		if (fork() == 0)
			break;
	if (i == 20) {
  800056:	83 fb 14             	cmp    $0x14,%ebx
  800059:	74 1e                	je     800079 <umain+0x45>
		sys_yield();
		return;
	}

	// Wait for the parent to finish forking
	while (envs[ENVX(parent)].env_status != ENV_FREE)
  80005b:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
  800061:	89 f0                	mov    %esi,%eax
  800063:	c1 e0 07             	shl    $0x7,%eax
  800066:	05 04 00 c0 ee       	add    $0xeec00004,%eax
  80006b:	8b 40 50             	mov    0x50(%eax),%eax
  80006e:	85 c0                	test   %eax,%eax
  800070:	75 0e                	jne    800080 <umain+0x4c>
  800072:	bb 00 00 00 00       	mov    $0x0,%ebx
  800077:	eb 20                	jmp    800099 <umain+0x65>
	// Fork several environments
	for (i = 0; i < 20; i++)
		if (fork() == 0)
			break;
	if (i == 20) {
		sys_yield();
  800079:	e8 cf 0b 00 00       	call   800c4d <sys_yield>
		return;
  80007e:	eb 7e                	jmp    8000fe <umain+0xca>
	}

	// Wait for the parent to finish forking
	while (envs[ENVX(parent)].env_status != ENV_FREE)
  800080:	89 f2                	mov    %esi,%edx
  800082:	c1 e2 07             	shl    $0x7,%edx
  800085:	81 c2 04 00 c0 ee    	add    $0xeec00004,%edx
		asm volatile("pause");
  80008b:	f3 90                	pause  
		sys_yield();
		return;
	}

	// Wait for the parent to finish forking
	while (envs[ENVX(parent)].env_status != ENV_FREE)
  80008d:	8b 42 50             	mov    0x50(%edx),%eax
  800090:	85 c0                	test   %eax,%eax
  800092:	75 f7                	jne    80008b <umain+0x57>
  800094:	bb 00 00 00 00       	mov    $0x0,%ebx
		asm volatile("pause");

	// Check that one environment doesn't run on two CPUs at once
	for (i = 0; i < 10; i++) {
		sys_yield();
  800099:	e8 af 0b 00 00       	call   800c4d <sys_yield>
		for (j = 0; j < 10000; j++)
  80009e:	b8 00 00 00 00       	mov    $0x0,%eax
			counter++;
  8000a3:	8b 15 04 20 80 00    	mov    0x802004,%edx
  8000a9:	42                   	inc    %edx
  8000aa:	89 15 04 20 80 00    	mov    %edx,0x802004
		asm volatile("pause");

	// Check that one environment doesn't run on two CPUs at once
	for (i = 0; i < 10; i++) {
		sys_yield();
		for (j = 0; j < 10000; j++)
  8000b0:	40                   	inc    %eax
  8000b1:	3d 10 27 00 00       	cmp    $0x2710,%eax
  8000b6:	75 eb                	jne    8000a3 <umain+0x6f>
	// Wait for the parent to finish forking
	while (envs[ENVX(parent)].env_status != ENV_FREE)
		asm volatile("pause");

	// Check that one environment doesn't run on two CPUs at once
	for (i = 0; i < 10; i++) {
  8000b8:	43                   	inc    %ebx
  8000b9:	83 fb 0a             	cmp    $0xa,%ebx
  8000bc:	75 db                	jne    800099 <umain+0x65>
		sys_yield();
		for (j = 0; j < 10000; j++)
			counter++;
	}

	if (counter != 10*10000)
  8000be:	a1 04 20 80 00       	mov    0x802004,%eax
  8000c3:	3d a0 86 01 00       	cmp    $0x186a0,%eax
  8000c8:	74 17                	je     8000e1 <umain+0xad>
		panic("ran on two CPUs at once (counter is %d)", counter);
  8000ca:	a1 04 20 80 00       	mov    0x802004,%eax
  8000cf:	50                   	push   %eax
  8000d0:	68 40 13 80 00       	push   $0x801340
  8000d5:	6a 21                	push   $0x21
  8000d7:	68 68 13 80 00       	push   $0x801368
  8000dc:	e8 83 00 00 00       	call   800164 <_panic>

	// Check that we see environments running on different CPUs
	cprintf("[%08x] stresssched on CPU %d\n", thisenv->env_id, thisenv->env_cpunum);
  8000e1:	a1 08 20 80 00       	mov    0x802008,%eax
  8000e6:	8b 50 5c             	mov    0x5c(%eax),%edx
  8000e9:	8b 40 48             	mov    0x48(%eax),%eax
  8000ec:	83 ec 04             	sub    $0x4,%esp
  8000ef:	52                   	push   %edx
  8000f0:	50                   	push   %eax
  8000f1:	68 7b 13 80 00       	push   $0x80137b
  8000f6:	e8 41 01 00 00       	call   80023c <cprintf>
  8000fb:	83 c4 10             	add    $0x10,%esp

}
  8000fe:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800101:	5b                   	pop    %ebx
  800102:	5e                   	pop    %esi
  800103:	c9                   	leave  
  800104:	c3                   	ret    
  800105:	00 00                	add    %al,(%eax)
	...

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
  800113:	e8 11 0b 00 00       	call   800c29 <sys_getenvid>
  800118:	25 ff 03 00 00       	and    $0x3ff,%eax
  80011d:	c1 e0 07             	shl    $0x7,%eax
  800120:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800125:	a3 08 20 80 00       	mov    %eax,0x802008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80012a:	85 f6                	test   %esi,%esi
  80012c:	7e 07                	jle    800135 <libmain+0x2d>
		binaryname = argv[0];
  80012e:	8b 03                	mov    (%ebx),%eax
  800130:	a3 00 20 80 00       	mov    %eax,0x802000
	// call user main routine
	umain(argc, argv);
  800135:	83 ec 08             	sub    $0x8,%esp
  800138:	53                   	push   %ebx
  800139:	56                   	push   %esi
  80013a:	e8 f5 fe ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  80013f:	e8 0c 00 00 00       	call   800150 <exit>
  800144:	83 c4 10             	add    $0x10,%esp
}
  800147:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80014a:	5b                   	pop    %ebx
  80014b:	5e                   	pop    %esi
  80014c:	c9                   	leave  
  80014d:	c3                   	ret    
	...

00800150 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800150:	55                   	push   %ebp
  800151:	89 e5                	mov    %esp,%ebp
  800153:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
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
  80016c:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  800172:	e8 b2 0a 00 00       	call   800c29 <sys_getenvid>
  800177:	83 ec 0c             	sub    $0xc,%esp
  80017a:	ff 75 0c             	pushl  0xc(%ebp)
  80017d:	ff 75 08             	pushl  0x8(%ebp)
  800180:	53                   	push   %ebx
  800181:	50                   	push   %eax
  800182:	68 a4 13 80 00       	push   $0x8013a4
  800187:	e8 b0 00 00 00       	call   80023c <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80018c:	83 c4 18             	add    $0x18,%esp
  80018f:	56                   	push   %esi
  800190:	ff 75 10             	pushl  0x10(%ebp)
  800193:	e8 53 00 00 00       	call   8001eb <vcprintf>
	cprintf("\n");
  800198:	c7 04 24 97 13 80 00 	movl   $0x801397,(%esp)
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
  8002a4:	e8 4f 0e 00 00       	call   8010f8 <__udivdi3>
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
  8002e0:	e8 2f 0f 00 00       	call   801214 <__umoddi3>
  8002e5:	83 c4 14             	add    $0x14,%esp
  8002e8:	0f be 80 c7 13 80 00 	movsbl 0x8013c7(%eax),%eax
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
  80042c:	ff 24 85 80 14 80 00 	jmp    *0x801480(,%eax,4)
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
  8004d3:	83 f8 08             	cmp    $0x8,%eax
  8004d6:	7f 0b                	jg     8004e3 <vprintfmt+0x142>
  8004d8:	8b 04 85 e0 15 80 00 	mov    0x8015e0(,%eax,4),%eax
  8004df:	85 c0                	test   %eax,%eax
  8004e1:	75 1a                	jne    8004fd <vprintfmt+0x15c>
				printfmt(putch, putdat, "error %d", err);
  8004e3:	52                   	push   %edx
  8004e4:	68 df 13 80 00       	push   $0x8013df
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
  8004fe:	68 e8 13 80 00       	push   $0x8013e8
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
  800534:	c7 45 d0 d8 13 80 00 	movl   $0x8013d8,-0x30(%ebp)
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
  800ba2:	68 04 16 80 00       	push   $0x801604
  800ba7:	6a 42                	push   $0x42
  800ba9:	68 21 16 80 00       	push   $0x801621
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
  800c65:	b8 0a 00 00 00       	mov    $0xa,%eax
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

00800d04 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d04:	55                   	push   %ebp
  800d05:	89 e5                	mov    %esp,%ebp
  800d07:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
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

00800d27 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d27:	55                   	push   %ebp
  800d28:	89 e5                	mov    %esp,%ebp
  800d2a:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  800d2d:	6a 00                	push   $0x0
  800d2f:	ff 75 14             	pushl  0x14(%ebp)
  800d32:	ff 75 10             	pushl  0x10(%ebp)
  800d35:	ff 75 0c             	pushl  0xc(%ebp)
  800d38:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d3b:	ba 00 00 00 00       	mov    $0x0,%edx
  800d40:	b8 0b 00 00 00       	mov    $0xb,%eax
  800d45:	e8 26 fe ff ff       	call   800b70 <syscall>
}
  800d4a:	c9                   	leave  
  800d4b:	c3                   	ret    

00800d4c <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d4c:	55                   	push   %ebp
  800d4d:	89 e5                	mov    %esp,%ebp
  800d4f:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  800d52:	6a 00                	push   $0x0
  800d54:	6a 00                	push   $0x0
  800d56:	6a 00                	push   $0x0
  800d58:	6a 00                	push   $0x0
  800d5a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d5d:	ba 01 00 00 00       	mov    $0x1,%edx
  800d62:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d67:	e8 04 fe ff ff       	call   800b70 <syscall>
}
  800d6c:	c9                   	leave  
  800d6d:	c3                   	ret    

00800d6e <sys_set_priority>:

int
sys_set_priority(envid_t envid, uint32_t new_priority)
{
  800d6e:	55                   	push   %ebp
  800d6f:	89 e5                	mov    %esp,%ebp
  800d71:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_set_priority, 0, envid, new_priority, 0, 0, 0);
  800d74:	6a 00                	push   $0x0
  800d76:	6a 00                	push   $0x0
  800d78:	6a 00                	push   $0x0
  800d7a:	ff 75 0c             	pushl  0xc(%ebp)
  800d7d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d80:	ba 00 00 00 00       	mov    $0x0,%edx
  800d85:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d8a:	e8 e1 fd ff ff       	call   800b70 <syscall>
}
  800d8f:	c9                   	leave  
  800d90:	c3                   	ret    
  800d91:	00 00                	add    %al,(%eax)
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
  800da9:	68 30 16 80 00       	push   $0x801630
  800dae:	6a 20                	push   $0x20
  800db0:	68 74 17 80 00       	push   $0x801774
  800db5:	e8 aa f3 ff ff       	call   800164 <_panic>

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
  800dde:	68 54 16 80 00       	push   $0x801654
  800de3:	6a 24                	push   $0x24
  800de5:	68 74 17 80 00       	push   $0x801774
  800dea:	e8 75 f3 ff ff       	call   800164 <_panic>
	//   No need to explicitly delete the old page's mapping.

	// LAB 4: Your code here.

	// static int sys_page_alloc(envid_t envid, void *va, int perm)
	r = sys_page_alloc(0, (void *)PFTEMP, PTE_W | PTE_U | PTE_P);
  800def:	83 ec 04             	sub    $0x4,%esp
  800df2:	6a 07                	push   $0x7
  800df4:	68 00 f0 7f 00       	push   $0x7ff000
  800df9:	6a 00                	push   $0x0
  800dfb:	e8 74 fe ff ff       	call   800c74 <sys_page_alloc>
	if (r < 0) panic("pgfault, sys_page_alloc error : %e\n", r);
  800e00:	83 c4 10             	add    $0x10,%esp
  800e03:	85 c0                	test   %eax,%eax
  800e05:	79 12                	jns    800e19 <pgfault+0x85>
  800e07:	50                   	push   %eax
  800e08:	68 78 16 80 00       	push   $0x801678
  800e0d:	6a 32                	push   $0x32
  800e0f:	68 74 17 80 00       	push   $0x801774
  800e14:	e8 4b f3 ff ff       	call   800164 <_panic>

	// Oh my god, I forget this at the first, it waste me a lot of time to debug!!!
	addr = ROUNDDOWN(addr, PGSIZE);
  800e19:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	
	memcpy(PFTEMP, addr, PGSIZE);
  800e1f:	83 ec 04             	sub    $0x4,%esp
  800e22:	68 00 10 00 00       	push   $0x1000
  800e27:	53                   	push   %ebx
  800e28:	68 00 f0 7f 00       	push   $0x7ff000
  800e2d:	e8 eb fb ff ff       	call   800a1d <memcpy>
	
	r = sys_page_map(0, PFTEMP, 0, addr, PTE_W | PTE_U | PTE_P);
  800e32:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800e39:	53                   	push   %ebx
  800e3a:	6a 00                	push   $0x0
  800e3c:	68 00 f0 7f 00       	push   $0x7ff000
  800e41:	6a 00                	push   $0x0
  800e43:	e8 50 fe ff ff       	call   800c98 <sys_page_map>
	if (r < 0) panic("pgfault, sys_page_map error : %e\n", r);
  800e48:	83 c4 20             	add    $0x20,%esp
  800e4b:	85 c0                	test   %eax,%eax
  800e4d:	79 12                	jns    800e61 <pgfault+0xcd>
  800e4f:	50                   	push   %eax
  800e50:	68 9c 16 80 00       	push   $0x80169c
  800e55:	6a 3a                	push   $0x3a
  800e57:	68 74 17 80 00       	push   $0x801774
  800e5c:	e8 03 f3 ff ff       	call   800164 <_panic>

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
  800e74:	e8 eb 01 00 00       	call   801064 <set_pgfault_handler>
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
  800e8f:	68 7f 17 80 00       	push   $0x80177f
  800e94:	6a 7b                	push   $0x7b
  800e96:	68 74 17 80 00       	push   $0x801774
  800e9b:	e8 c4 f2 ff ff       	call   800164 <_panic>
	}
	int r;

	if (childpid == 0) {
  800ea0:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800ea4:	75 1c                	jne    800ec2 <fork+0x5c>
		// child process
		// Remember to fix "thisenv" in the child process. ??? 
		thisenv = &envs[ENVX(sys_getenvid())];
  800ea6:	e8 7e fd ff ff       	call   800c29 <sys_getenvid>
  800eab:	25 ff 03 00 00       	and    $0x3ff,%eax
  800eb0:	c1 e0 07             	shl    $0x7,%eax
  800eb3:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800eb8:	a3 08 20 80 00       	mov    %eax,0x802008
		// cprintf("fork child ok\n");
		return 0;
  800ebd:	e9 7b 01 00 00       	jmp    80103d <fork+0x1d7>
	if (childpid < 0) {
		panic("fork sys_exofork error : %e\n", childpid);
	}
	int r;

	if (childpid == 0) {
  800ec2:	bb 00 00 00 00       	mov    $0x0,%ebx
	} else {
		// map page to new environment
		// kernel page is already in new environment
		uint32_t i;
		for (i = 0; i != UTOP; i += PGSIZE) 
		if ((uvpd[PDX(i)] & PTE_P) && (uvpt[i / PGSIZE] & PTE_P) && (uvpt[i / PGSIZE] & PTE_U)) {
  800ec7:	89 d8                	mov    %ebx,%eax
  800ec9:	c1 e8 16             	shr    $0x16,%eax
  800ecc:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800ed3:	a8 01                	test   $0x1,%al
  800ed5:	0f 84 cd 00 00 00    	je     800fa8 <fork+0x142>
  800edb:	89 d8                	mov    %ebx,%eax
  800edd:	c1 e8 0c             	shr    $0xc,%eax
  800ee0:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800ee7:	f6 c2 01             	test   $0x1,%dl
  800eea:	0f 84 b8 00 00 00    	je     800fa8 <fork+0x142>
  800ef0:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800ef7:	f6 c2 04             	test   $0x4,%dl
  800efa:	0f 84 a8 00 00 00    	je     800fa8 <fork+0x142>
//
static int
duppage(envid_t envid, unsigned pn)
{
	// do not dup exception stack
	if (pn * PGSIZE == UXSTACKTOP - PGSIZE) return 0;
  800f00:	89 c6                	mov    %eax,%esi
  800f02:	c1 e6 0c             	shl    $0xc,%esi
  800f05:	81 fe 00 f0 bf ee    	cmp    $0xeebff000,%esi
  800f0b:	0f 84 97 00 00 00    	je     800fa8 <fork+0x142>

	int r;
	void * addr = (void *)(pn * PGSIZE);
	if ((uvpt[pn] & PTE_W) || (uvpt[pn] & PTE_COW)) {
  800f11:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800f18:	f6 c2 02             	test   $0x2,%dl
  800f1b:	75 0c                	jne    800f29 <fork+0xc3>
  800f1d:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f24:	f6 c4 08             	test   $0x8,%ah
  800f27:	74 57                	je     800f80 <fork+0x11a>
		// cow
		r = sys_page_map(0, addr, envid, addr, PTE_COW | PTE_P | PTE_U);
  800f29:	83 ec 0c             	sub    $0xc,%esp
  800f2c:	68 05 08 00 00       	push   $0x805
  800f31:	56                   	push   %esi
  800f32:	57                   	push   %edi
  800f33:	56                   	push   %esi
  800f34:	6a 00                	push   $0x0
  800f36:	e8 5d fd ff ff       	call   800c98 <sys_page_map>
		if (r < 0) panic("duppage sys_page_map error : %e\n", r);
  800f3b:	83 c4 20             	add    $0x20,%esp
  800f3e:	85 c0                	test   %eax,%eax
  800f40:	79 12                	jns    800f54 <fork+0xee>
  800f42:	50                   	push   %eax
  800f43:	68 c0 16 80 00       	push   $0x8016c0
  800f48:	6a 55                	push   $0x55
  800f4a:	68 74 17 80 00       	push   $0x801774
  800f4f:	e8 10 f2 ff ff       	call   800164 <_panic>
		
		r = sys_page_map(0, addr, 0, addr, PTE_COW | PTE_P | PTE_U);
  800f54:	83 ec 0c             	sub    $0xc,%esp
  800f57:	68 05 08 00 00       	push   $0x805
  800f5c:	56                   	push   %esi
  800f5d:	6a 00                	push   $0x0
  800f5f:	56                   	push   %esi
  800f60:	6a 00                	push   $0x0
  800f62:	e8 31 fd ff ff       	call   800c98 <sys_page_map>
		if (r < 0) panic("duppage sys_page_map error : %e\n", r);
  800f67:	83 c4 20             	add    $0x20,%esp
  800f6a:	85 c0                	test   %eax,%eax
  800f6c:	79 3a                	jns    800fa8 <fork+0x142>
  800f6e:	50                   	push   %eax
  800f6f:	68 c0 16 80 00       	push   $0x8016c0
  800f74:	6a 58                	push   $0x58
  800f76:	68 74 17 80 00       	push   $0x801774
  800f7b:	e8 e4 f1 ff ff       	call   800164 <_panic>
	} else {
		// read only
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U);
  800f80:	83 ec 0c             	sub    $0xc,%esp
  800f83:	6a 05                	push   $0x5
  800f85:	56                   	push   %esi
  800f86:	57                   	push   %edi
  800f87:	56                   	push   %esi
  800f88:	6a 00                	push   $0x0
  800f8a:	e8 09 fd ff ff       	call   800c98 <sys_page_map>
		if (r < 0) panic("duppage sys_page_map error : %e\n", r);
  800f8f:	83 c4 20             	add    $0x20,%esp
  800f92:	85 c0                	test   %eax,%eax
  800f94:	79 12                	jns    800fa8 <fork+0x142>
  800f96:	50                   	push   %eax
  800f97:	68 c0 16 80 00       	push   $0x8016c0
  800f9c:	6a 5c                	push   $0x5c
  800f9e:	68 74 17 80 00       	push   $0x801774
  800fa3:	e8 bc f1 ff ff       	call   800164 <_panic>
		return 0;
	} else {
		// map page to new environment
		// kernel page is already in new environment
		uint32_t i;
		for (i = 0; i != UTOP; i += PGSIZE) 
  800fa8:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  800fae:	81 fb 00 00 c0 ee    	cmp    $0xeec00000,%ebx
  800fb4:	0f 85 0d ff ff ff    	jne    800ec7 <fork+0x61>
		if ((uvpd[PDX(i)] & PTE_P) && (uvpt[i / PGSIZE] & PTE_P) && (uvpt[i / PGSIZE] & PTE_U)) {
			duppage(childpid, i / PGSIZE);
		}

		// allocate exception stack
		r = sys_page_alloc(childpid, (void *)(UXSTACKTOP - PGSIZE), PTE_U | PTE_W | PTE_P);
  800fba:	83 ec 04             	sub    $0x4,%esp
  800fbd:	6a 07                	push   $0x7
  800fbf:	68 00 f0 bf ee       	push   $0xeebff000
  800fc4:	ff 75 e4             	pushl  -0x1c(%ebp)
  800fc7:	e8 a8 fc ff ff       	call   800c74 <sys_page_alloc>
		if (r < 0) panic("fork, sys_page_alloc user exception stack error : %e\n", r);
  800fcc:	83 c4 10             	add    $0x10,%esp
  800fcf:	85 c0                	test   %eax,%eax
  800fd1:	79 15                	jns    800fe8 <fork+0x182>
  800fd3:	50                   	push   %eax
  800fd4:	68 e4 16 80 00       	push   $0x8016e4
  800fd9:	68 90 00 00 00       	push   $0x90
  800fde:	68 74 17 80 00       	push   $0x801774
  800fe3:	e8 7c f1 ff ff       	call   800164 <_panic>

		// set user environment user page fault handler 
		extern void _pgfault_upcall(void);
		r = sys_env_set_pgfault_upcall(childpid, _pgfault_upcall);
  800fe8:	83 ec 08             	sub    $0x8,%esp
  800feb:	68 d0 10 80 00       	push   $0x8010d0
  800ff0:	ff 75 e4             	pushl  -0x1c(%ebp)
  800ff3:	e8 0c fd ff ff       	call   800d04 <sys_env_set_pgfault_upcall>
		if (r < 0) panic("fork, set pgfault upcall fail : %e\n", r);
  800ff8:	83 c4 10             	add    $0x10,%esp
  800ffb:	85 c0                	test   %eax,%eax
  800ffd:	79 15                	jns    801014 <fork+0x1ae>
  800fff:	50                   	push   %eax
  801000:	68 1c 17 80 00       	push   $0x80171c
  801005:	68 95 00 00 00       	push   $0x95
  80100a:	68 74 17 80 00       	push   $0x801774
  80100f:	e8 50 f1 ff ff       	call   800164 <_panic>
		r = sys_set_priority(childpid, num);
		if (r < 0) panic("fork, set priority error\n");
		*/

		// mark the child as runnable and return
		r = sys_env_set_status(childpid, ENV_RUNNABLE);
  801014:	83 ec 08             	sub    $0x8,%esp
  801017:	6a 02                	push   $0x2
  801019:	ff 75 e4             	pushl  -0x1c(%ebp)
  80101c:	e8 c0 fc ff ff       	call   800ce1 <sys_env_set_status>
		if (r < 0) panic("fork, set child process to ENV_RUNNABLE error : %e\n", r);
  801021:	83 c4 10             	add    $0x10,%esp
  801024:	85 c0                	test   %eax,%eax
  801026:	79 15                	jns    80103d <fork+0x1d7>
  801028:	50                   	push   %eax
  801029:	68 40 17 80 00       	push   $0x801740
  80102e:	68 a0 00 00 00       	push   $0xa0
  801033:	68 74 17 80 00       	push   $0x801774
  801038:	e8 27 f1 ff ff       	call   800164 <_panic>
		// cprintf("fork father ok!")
		return childpid;
	}

	panic("fork not implemented");
}
  80103d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801040:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801043:	5b                   	pop    %ebx
  801044:	5e                   	pop    %esi
  801045:	5f                   	pop    %edi
  801046:	c9                   	leave  
  801047:	c3                   	ret    

00801048 <sfork>:

// Challenge!
int
sfork(void)
{
  801048:	55                   	push   %ebp
  801049:	89 e5                	mov    %esp,%ebp
  80104b:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  80104e:	68 9c 17 80 00       	push   $0x80179c
  801053:	68 ad 00 00 00       	push   $0xad
  801058:	68 74 17 80 00       	push   $0x801774
  80105d:	e8 02 f1 ff ff       	call   800164 <_panic>
	...

00801064 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801064:	55                   	push   %ebp
  801065:	89 e5                	mov    %esp,%ebp
  801067:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  80106a:	83 3d 0c 20 80 00 00 	cmpl   $0x0,0x80200c
  801071:	75 52                	jne    8010c5 <set_pgfault_handler+0x61>
		// First time through!	
		// LAB 4: Your code here.

		//int sys_page_alloc(envid_t envid, void *va, int perm)
		r = sys_page_alloc(0, (void*)(UXSTACKTOP - PGSIZE), PTE_U | PTE_W | PTE_P);
  801073:	83 ec 04             	sub    $0x4,%esp
  801076:	6a 07                	push   $0x7
  801078:	68 00 f0 bf ee       	push   $0xeebff000
  80107d:	6a 00                	push   $0x0
  80107f:	e8 f0 fb ff ff       	call   800c74 <sys_page_alloc>
		if (r < 0) {
  801084:	83 c4 10             	add    $0x10,%esp
  801087:	85 c0                	test   %eax,%eax
  801089:	79 12                	jns    80109d <set_pgfault_handler+0x39>
			panic("sys_page_alloc error : %e\n", r);
  80108b:	50                   	push   %eax
  80108c:	68 b2 17 80 00       	push   $0x8017b2
  801091:	6a 24                	push   $0x24
  801093:	68 cd 17 80 00       	push   $0x8017cd
  801098:	e8 c7 f0 ff ff       	call   800164 <_panic>
		}

		// how to know envid, put 0, envid2env will help us to get curenv in syscall
		r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);		
  80109d:	83 ec 08             	sub    $0x8,%esp
  8010a0:	68 d0 10 80 00       	push   $0x8010d0
  8010a5:	6a 00                	push   $0x0
  8010a7:	e8 58 fc ff ff       	call   800d04 <sys_env_set_pgfault_upcall>
		if (r < 0) {
  8010ac:	83 c4 10             	add    $0x10,%esp
  8010af:	85 c0                	test   %eax,%eax
  8010b1:	79 12                	jns    8010c5 <set_pgfault_handler+0x61>
			panic("sys_env_set_pgfault_upcall error : %e\n", r);
  8010b3:	50                   	push   %eax
  8010b4:	68 dc 17 80 00       	push   $0x8017dc
  8010b9:	6a 2a                	push   $0x2a
  8010bb:	68 cd 17 80 00       	push   $0x8017cd
  8010c0:	e8 9f f0 ff ff       	call   800164 <_panic>
		}
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8010c5:	8b 45 08             	mov    0x8(%ebp),%eax
  8010c8:	a3 0c 20 80 00       	mov    %eax,0x80200c
}
  8010cd:	c9                   	leave  
  8010ce:	c3                   	ret    
	...

008010d0 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8010d0:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8010d1:	a1 0c 20 80 00       	mov    0x80200c,%eax
	call *%eax
  8010d6:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8010d8:	83 c4 04             	add    $0x4,%esp
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	
	// fix old esp
	movl 0x30(%esp), %eax
  8010db:	8b 44 24 30          	mov    0x30(%esp),%eax
	subl $0x4, %eax
  8010df:	83 e8 04             	sub    $0x4,%eax
	movl %eax, 0x30(%esp)
  8010e2:	89 44 24 30          	mov    %eax,0x30(%esp)

	// set trap-time %eip
	movl 0x28(%esp), %ebx
  8010e6:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	movl %ebx, (%eax)
  8010ea:	89 18                	mov    %ebx,(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $0x08, %esp 	// ignore err_code and fault_va
  8010ec:	83 c4 08             	add    $0x8,%esp
	popal 				// restore registers
  8010ef:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x04, %esp 	// ignore eip 
  8010f0:	83 c4 04             	add    $0x4,%esp
	popfl				// modify eflags
  8010f3:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  8010f4:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  8010f5:	c3                   	ret    
	...

008010f8 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  8010f8:	55                   	push   %ebp
  8010f9:	89 e5                	mov    %esp,%ebp
  8010fb:	57                   	push   %edi
  8010fc:	56                   	push   %esi
  8010fd:	83 ec 10             	sub    $0x10,%esp
  801100:	8b 7d 08             	mov    0x8(%ebp),%edi
  801103:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  801106:	89 7d f0             	mov    %edi,-0x10(%ebp)
  801109:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  80110c:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  80110f:	8b 45 14             	mov    0x14(%ebp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  801112:	85 c0                	test   %eax,%eax
  801114:	75 2e                	jne    801144 <__udivdi3+0x4c>
    {
      if (d0 > n1)
  801116:	39 f1                	cmp    %esi,%ecx
  801118:	77 5a                	ja     801174 <__udivdi3+0x7c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  80111a:	85 c9                	test   %ecx,%ecx
  80111c:	75 0b                	jne    801129 <__udivdi3+0x31>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  80111e:	b8 01 00 00 00       	mov    $0x1,%eax
  801123:	31 d2                	xor    %edx,%edx
  801125:	f7 f1                	div    %ecx
  801127:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  801129:	31 d2                	xor    %edx,%edx
  80112b:	89 f0                	mov    %esi,%eax
  80112d:	f7 f1                	div    %ecx
  80112f:	89 c6                	mov    %eax,%esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801131:	89 f8                	mov    %edi,%eax
  801133:	f7 f1                	div    %ecx
  801135:	89 c7                	mov    %eax,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801137:	89 f8                	mov    %edi,%eax
  801139:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  80113b:	83 c4 10             	add    $0x10,%esp
  80113e:	5e                   	pop    %esi
  80113f:	5f                   	pop    %edi
  801140:	c9                   	leave  
  801141:	c3                   	ret    
  801142:	66 90                	xchg   %ax,%ax
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801144:	39 f0                	cmp    %esi,%eax
  801146:	77 1c                	ja     801164 <__udivdi3+0x6c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  801148:	0f bd f8             	bsr    %eax,%edi
	  if (bm == 0)
  80114b:	83 f7 1f             	xor    $0x1f,%edi
  80114e:	75 3c                	jne    80118c <__udivdi3+0x94>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801150:	39 f0                	cmp    %esi,%eax
  801152:	0f 82 90 00 00 00    	jb     8011e8 <__udivdi3+0xf0>
  801158:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80115b:	39 55 f4             	cmp    %edx,-0xc(%ebp)
  80115e:	0f 86 84 00 00 00    	jbe    8011e8 <__udivdi3+0xf0>
  801164:	31 f6                	xor    %esi,%esi
  801166:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801168:	89 f8                	mov    %edi,%eax
  80116a:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  80116c:	83 c4 10             	add    $0x10,%esp
  80116f:	5e                   	pop    %esi
  801170:	5f                   	pop    %edi
  801171:	c9                   	leave  
  801172:	c3                   	ret    
  801173:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801174:	89 f2                	mov    %esi,%edx
  801176:	89 f8                	mov    %edi,%eax
  801178:	f7 f1                	div    %ecx
  80117a:	89 c7                	mov    %eax,%edi
  80117c:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  80117e:	89 f8                	mov    %edi,%eax
  801180:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801182:	83 c4 10             	add    $0x10,%esp
  801185:	5e                   	pop    %esi
  801186:	5f                   	pop    %edi
  801187:	c9                   	leave  
  801188:	c3                   	ret    
  801189:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  80118c:	89 f9                	mov    %edi,%ecx
  80118e:	d3 e0                	shl    %cl,%eax
  801190:	89 45 e8             	mov    %eax,-0x18(%ebp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  801193:	b8 20 00 00 00       	mov    $0x20,%eax
  801198:	29 f8                	sub    %edi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  80119a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80119d:	88 c1                	mov    %al,%cl
  80119f:	d3 ea                	shr    %cl,%edx
  8011a1:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  8011a4:	09 ca                	or     %ecx,%edx
  8011a6:	89 55 ec             	mov    %edx,-0x14(%ebp)
	      d0 = d0 << bm;
  8011a9:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8011ac:	89 f9                	mov    %edi,%ecx
  8011ae:	d3 e2                	shl    %cl,%edx
  8011b0:	89 55 f4             	mov    %edx,-0xc(%ebp)
	      n2 = n1 >> b;
  8011b3:	89 f2                	mov    %esi,%edx
  8011b5:	88 c1                	mov    %al,%cl
  8011b7:	d3 ea                	shr    %cl,%edx
  8011b9:	89 55 e8             	mov    %edx,-0x18(%ebp)
	      n1 = (n1 << bm) | (n0 >> b);
  8011bc:	89 f2                	mov    %esi,%edx
  8011be:	89 f9                	mov    %edi,%ecx
  8011c0:	d3 e2                	shl    %cl,%edx
  8011c2:	8b 75 f0             	mov    -0x10(%ebp),%esi
  8011c5:	88 c1                	mov    %al,%cl
  8011c7:	d3 ee                	shr    %cl,%esi
  8011c9:	09 d6                	or     %edx,%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  8011cb:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  8011ce:	89 f0                	mov    %esi,%eax
  8011d0:	89 ca                	mov    %ecx,%edx
  8011d2:	f7 75 ec             	divl   -0x14(%ebp)
  8011d5:	89 d1                	mov    %edx,%ecx
  8011d7:	89 c6                	mov    %eax,%esi
	      umul_ppmm (m1, m0, q0, d0);
  8011d9:	f7 65 f4             	mull   -0xc(%ebp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8011dc:	39 d1                	cmp    %edx,%ecx
  8011de:	72 28                	jb     801208 <__udivdi3+0x110>
  8011e0:	74 1a                	je     8011fc <__udivdi3+0x104>
  8011e2:	89 f7                	mov    %esi,%edi
  8011e4:	31 f6                	xor    %esi,%esi
  8011e6:	eb 80                	jmp    801168 <__udivdi3+0x70>
	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  8011e8:	31 f6                	xor    %esi,%esi
  8011ea:	bf 01 00 00 00       	mov    $0x1,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  8011ef:	89 f8                	mov    %edi,%eax
  8011f1:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  8011f3:	83 c4 10             	add    $0x10,%esp
  8011f6:	5e                   	pop    %esi
  8011f7:	5f                   	pop    %edi
  8011f8:	c9                   	leave  
  8011f9:	c3                   	ret    
  8011fa:	66 90                	xchg   %ax,%ax

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  8011fc:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8011ff:	89 f9                	mov    %edi,%ecx
  801201:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801203:	39 c2                	cmp    %eax,%edx
  801205:	73 db                	jae    8011e2 <__udivdi3+0xea>
  801207:	90                   	nop
		{
		  q0--;
  801208:	8d 7e ff             	lea    -0x1(%esi),%edi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  80120b:	31 f6                	xor    %esi,%esi
  80120d:	e9 56 ff ff ff       	jmp    801168 <__udivdi3+0x70>
	...

00801214 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  801214:	55                   	push   %ebp
  801215:	89 e5                	mov    %esp,%ebp
  801217:	57                   	push   %edi
  801218:	56                   	push   %esi
  801219:	83 ec 20             	sub    $0x20,%esp
  80121c:	8b 45 08             	mov    0x8(%ebp),%eax
  80121f:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  801222:	89 45 e8             	mov    %eax,-0x18(%ebp)
  801225:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  801228:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  80122b:	8b 7d 14             	mov    0x14(%ebp),%edi
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  80122e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  n1 = nn.s.high;
  801231:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  801233:	85 ff                	test   %edi,%edi
  801235:	75 15                	jne    80124c <__umoddi3+0x38>
    {
      if (d0 > n1)
  801237:	39 f1                	cmp    %esi,%ecx
  801239:	0f 86 99 00 00 00    	jbe    8012d8 <__umoddi3+0xc4>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  80123f:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  801241:	89 d0                	mov    %edx,%eax
  801243:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801245:	83 c4 20             	add    $0x20,%esp
  801248:	5e                   	pop    %esi
  801249:	5f                   	pop    %edi
  80124a:	c9                   	leave  
  80124b:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  80124c:	39 f7                	cmp    %esi,%edi
  80124e:	0f 87 a4 00 00 00    	ja     8012f8 <__umoddi3+0xe4>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  801254:	0f bd c7             	bsr    %edi,%eax
	  if (bm == 0)
  801257:	83 f0 1f             	xor    $0x1f,%eax
  80125a:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80125d:	0f 84 a1 00 00 00    	je     801304 <__umoddi3+0xf0>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  801263:	89 f8                	mov    %edi,%eax
  801265:	8a 4d ec             	mov    -0x14(%ebp),%cl
  801268:	d3 e0                	shl    %cl,%eax
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  80126a:	bf 20 00 00 00       	mov    $0x20,%edi
  80126f:	2b 7d ec             	sub    -0x14(%ebp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  801272:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801275:	89 f9                	mov    %edi,%ecx
  801277:	d3 ea                	shr    %cl,%edx
  801279:	09 c2                	or     %eax,%edx
  80127b:	89 55 f0             	mov    %edx,-0x10(%ebp)
	      d0 = d0 << bm;
  80127e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801281:	8a 4d ec             	mov    -0x14(%ebp),%cl
  801284:	d3 e0                	shl    %cl,%eax
  801286:	89 45 f4             	mov    %eax,-0xc(%ebp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  801289:	89 f2                	mov    %esi,%edx
  80128b:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  80128d:	8b 45 e8             	mov    -0x18(%ebp),%eax
  801290:	d3 e0                	shl    %cl,%eax
  801292:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  801295:	8b 45 e8             	mov    -0x18(%ebp),%eax
  801298:	89 f9                	mov    %edi,%ecx
  80129a:	d3 e8                	shr    %cl,%eax
  80129c:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  80129e:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  8012a0:	89 f2                	mov    %esi,%edx
  8012a2:	f7 75 f0             	divl   -0x10(%ebp)
  8012a5:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  8012a7:	f7 65 f4             	mull   -0xc(%ebp)
  8012aa:	89 55 e8             	mov    %edx,-0x18(%ebp)
  8012ad:	89 c1                	mov    %eax,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8012af:	39 d6                	cmp    %edx,%esi
  8012b1:	72 71                	jb     801324 <__umoddi3+0x110>
  8012b3:	74 7f                	je     801334 <__umoddi3+0x120>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  8012b5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8012b8:	29 c8                	sub    %ecx,%eax
  8012ba:	19 d6                	sbb    %edx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  8012bc:	8a 4d ec             	mov    -0x14(%ebp),%cl
  8012bf:	d3 e8                	shr    %cl,%eax
  8012c1:	89 f2                	mov    %esi,%edx
  8012c3:	89 f9                	mov    %edi,%ecx
  8012c5:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  8012c7:	09 d0                	or     %edx,%eax
  8012c9:	89 f2                	mov    %esi,%edx
  8012cb:	8a 4d ec             	mov    -0x14(%ebp),%cl
  8012ce:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8012d0:	83 c4 20             	add    $0x20,%esp
  8012d3:	5e                   	pop    %esi
  8012d4:	5f                   	pop    %edi
  8012d5:	c9                   	leave  
  8012d6:	c3                   	ret    
  8012d7:	90                   	nop
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  8012d8:	85 c9                	test   %ecx,%ecx
  8012da:	75 0b                	jne    8012e7 <__umoddi3+0xd3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  8012dc:	b8 01 00 00 00       	mov    $0x1,%eax
  8012e1:	31 d2                	xor    %edx,%edx
  8012e3:	f7 f1                	div    %ecx
  8012e5:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  8012e7:	89 f0                	mov    %esi,%eax
  8012e9:	31 d2                	xor    %edx,%edx
  8012eb:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8012ed:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012f0:	f7 f1                	div    %ecx
  8012f2:	e9 4a ff ff ff       	jmp    801241 <__umoddi3+0x2d>
  8012f7:	90                   	nop
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  8012f8:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8012fa:	83 c4 20             	add    $0x20,%esp
  8012fd:	5e                   	pop    %esi
  8012fe:	5f                   	pop    %edi
  8012ff:	c9                   	leave  
  801300:	c3                   	ret    
  801301:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801304:	39 f7                	cmp    %esi,%edi
  801306:	72 05                	jb     80130d <__umoddi3+0xf9>
  801308:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
  80130b:	77 0c                	ja     801319 <__umoddi3+0x105>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  80130d:	89 f2                	mov    %esi,%edx
  80130f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801312:	29 c8                	sub    %ecx,%eax
  801314:	19 fa                	sbb    %edi,%edx
  801316:	89 45 f0             	mov    %eax,-0x10(%ebp)

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  801319:	8b 45 f0             	mov    -0x10(%ebp),%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  80131c:	83 c4 20             	add    $0x20,%esp
  80131f:	5e                   	pop    %esi
  801320:	5f                   	pop    %edi
  801321:	c9                   	leave  
  801322:	c3                   	ret    
  801323:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  801324:	8b 55 e8             	mov    -0x18(%ebp),%edx
  801327:	89 c1                	mov    %eax,%ecx
  801329:	2b 4d f4             	sub    -0xc(%ebp),%ecx
  80132c:	1b 55 f0             	sbb    -0x10(%ebp),%edx
  80132f:	eb 84                	jmp    8012b5 <__umoddi3+0xa1>
  801331:	8d 76 00             	lea    0x0(%esi),%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801334:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801337:	72 eb                	jb     801324 <__umoddi3+0x110>
  801339:	89 f2                	mov    %esi,%edx
  80133b:	e9 75 ff ff ff       	jmp    8012b5 <__umoddi3+0xa1>
