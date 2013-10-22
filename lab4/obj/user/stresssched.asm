
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
  80002c:	e8 eb 00 00 00       	call   80011c <libmain>
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
  800039:	e8 07 0c 00 00       	call   800c45 <sys_getenvid>
  80003e:	89 c6                	mov    %eax,%esi

	// Fork several environments
	for (i = 0; i < 20; i++)
  800040:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (fork() == 0)
  800045:	e8 14 0e 00 00       	call   800e5e <fork>
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
  800054:	eb 2c                	jmp    800082 <umain+0x4e>
		if (fork() == 0)
			break;
	if (i == 20) {
  800056:	83 fb 14             	cmp    $0x14,%ebx
  800059:	74 27                	je     800082 <umain+0x4e>
		sys_yield();
		return;
	}

	// Wait for the parent to finish forking
	while (envs[ENVX(parent)].env_status != ENV_FREE)
  80005b:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
  800061:	8d 14 b5 00 00 00 00 	lea    0x0(,%esi,4),%edx
  800068:	89 f0                	mov    %esi,%eax
  80006a:	c1 e0 07             	shl    $0x7,%eax
  80006d:	29 d0                	sub    %edx,%eax
  80006f:	05 04 00 c0 ee       	add    $0xeec00004,%eax
  800074:	8b 40 50             	mov    0x50(%eax),%eax
  800077:	85 c0                	test   %eax,%eax
  800079:	75 11                	jne    80008c <umain+0x58>
  80007b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800080:	eb 2c                	jmp    8000ae <umain+0x7a>
	// Fork several environments
	for (i = 0; i < 20; i++)
		if (fork() == 0)
			break;
	if (i == 20) {
		sys_yield();
  800082:	e8 e2 0b 00 00       	call   800c69 <sys_yield>
		return;
  800087:	e9 87 00 00 00       	jmp    800113 <umain+0xdf>
	}

	// Wait for the parent to finish forking
	while (envs[ENVX(parent)].env_status != ENV_FREE)
  80008c:	8d 04 b5 00 00 00 00 	lea    0x0(,%esi,4),%eax
  800093:	89 f2                	mov    %esi,%edx
  800095:	c1 e2 07             	shl    $0x7,%edx
  800098:	29 c2                	sub    %eax,%edx
  80009a:	81 c2 04 00 c0 ee    	add    $0xeec00004,%edx
		asm volatile("pause");
  8000a0:	f3 90                	pause  
		sys_yield();
		return;
	}

	// Wait for the parent to finish forking
	while (envs[ENVX(parent)].env_status != ENV_FREE)
  8000a2:	8b 42 50             	mov    0x50(%edx),%eax
  8000a5:	85 c0                	test   %eax,%eax
  8000a7:	75 f7                	jne    8000a0 <umain+0x6c>
  8000a9:	bb 00 00 00 00       	mov    $0x0,%ebx
		asm volatile("pause");

	// Check that one environment doesn't run on two CPUs at once
	for (i = 0; i < 10; i++) {
		sys_yield();
  8000ae:	e8 b6 0b 00 00       	call   800c69 <sys_yield>
		for (j = 0; j < 10000; j++)
  8000b3:	b8 00 00 00 00       	mov    $0x0,%eax
			counter++;
  8000b8:	8b 15 04 20 80 00    	mov    0x802004,%edx
  8000be:	42                   	inc    %edx
  8000bf:	89 15 04 20 80 00    	mov    %edx,0x802004
		asm volatile("pause");

	// Check that one environment doesn't run on two CPUs at once
	for (i = 0; i < 10; i++) {
		sys_yield();
		for (j = 0; j < 10000; j++)
  8000c5:	40                   	inc    %eax
  8000c6:	3d 10 27 00 00       	cmp    $0x2710,%eax
  8000cb:	75 eb                	jne    8000b8 <umain+0x84>
	// Wait for the parent to finish forking
	while (envs[ENVX(parent)].env_status != ENV_FREE)
		asm volatile("pause");

	// Check that one environment doesn't run on two CPUs at once
	for (i = 0; i < 10; i++) {
  8000cd:	43                   	inc    %ebx
  8000ce:	83 fb 0a             	cmp    $0xa,%ebx
  8000d1:	75 db                	jne    8000ae <umain+0x7a>
		sys_yield();
		for (j = 0; j < 10000; j++)
			counter++;
	}

	if (counter != 10*10000)
  8000d3:	a1 04 20 80 00       	mov    0x802004,%eax
  8000d8:	3d a0 86 01 00       	cmp    $0x186a0,%eax
  8000dd:	74 17                	je     8000f6 <umain+0xc2>
		panic("ran on two CPUs at once (counter is %d)", counter);
  8000df:	a1 04 20 80 00       	mov    0x802004,%eax
  8000e4:	50                   	push   %eax
  8000e5:	68 40 13 80 00       	push   $0x801340
  8000ea:	6a 21                	push   $0x21
  8000ec:	68 68 13 80 00       	push   $0x801368
  8000f1:	e8 8a 00 00 00       	call   800180 <_panic>

	// Check that we see environments running on different CPUs
	cprintf("[%08x] stresssched on CPU %d\n", thisenv->env_id, thisenv->env_cpunum);
  8000f6:	a1 08 20 80 00       	mov    0x802008,%eax
  8000fb:	8b 50 5c             	mov    0x5c(%eax),%edx
  8000fe:	8b 40 48             	mov    0x48(%eax),%eax
  800101:	83 ec 04             	sub    $0x4,%esp
  800104:	52                   	push   %edx
  800105:	50                   	push   %eax
  800106:	68 7b 13 80 00       	push   $0x80137b
  80010b:	e8 48 01 00 00       	call   800258 <cprintf>
  800110:	83 c4 10             	add    $0x10,%esp

}
  800113:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800116:	5b                   	pop    %ebx
  800117:	5e                   	pop    %esi
  800118:	c9                   	leave  
  800119:	c3                   	ret    
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
  800127:	e8 19 0b 00 00       	call   800c45 <sys_getenvid>
  80012c:	25 ff 03 00 00       	and    $0x3ff,%eax
  800131:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800138:	c1 e0 07             	shl    $0x7,%eax
  80013b:	29 d0                	sub    %edx,%eax
  80013d:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800142:	a3 08 20 80 00       	mov    %eax,0x802008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800147:	85 f6                	test   %esi,%esi
  800149:	7e 07                	jle    800152 <libmain+0x36>
		binaryname = argv[0];
  80014b:	8b 03                	mov    (%ebx),%eax
  80014d:	a3 00 20 80 00       	mov    %eax,0x802000
	// call user main routine
	umain(argc, argv);
  800152:	83 ec 08             	sub    $0x8,%esp
  800155:	53                   	push   %ebx
  800156:	56                   	push   %esi
  800157:	e8 d8 fe ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  80015c:	e8 0b 00 00 00       	call   80016c <exit>
  800161:	83 c4 10             	add    $0x10,%esp
}
  800164:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800167:	5b                   	pop    %ebx
  800168:	5e                   	pop    %esi
  800169:	c9                   	leave  
  80016a:	c3                   	ret    
	...

0080016c <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80016c:	55                   	push   %ebp
  80016d:	89 e5                	mov    %esp,%ebp
  80016f:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  800172:	6a 00                	push   $0x0
  800174:	e8 aa 0a 00 00       	call   800c23 <sys_env_destroy>
  800179:	83 c4 10             	add    $0x10,%esp
}
  80017c:	c9                   	leave  
  80017d:	c3                   	ret    
	...

00800180 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800180:	55                   	push   %ebp
  800181:	89 e5                	mov    %esp,%ebp
  800183:	56                   	push   %esi
  800184:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800185:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800188:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  80018e:	e8 b2 0a 00 00       	call   800c45 <sys_getenvid>
  800193:	83 ec 0c             	sub    $0xc,%esp
  800196:	ff 75 0c             	pushl  0xc(%ebp)
  800199:	ff 75 08             	pushl  0x8(%ebp)
  80019c:	53                   	push   %ebx
  80019d:	50                   	push   %eax
  80019e:	68 a4 13 80 00       	push   $0x8013a4
  8001a3:	e8 b0 00 00 00       	call   800258 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8001a8:	83 c4 18             	add    $0x18,%esp
  8001ab:	56                   	push   %esi
  8001ac:	ff 75 10             	pushl  0x10(%ebp)
  8001af:	e8 53 00 00 00       	call   800207 <vcprintf>
	cprintf("\n");
  8001b4:	c7 04 24 97 13 80 00 	movl   $0x801397,(%esp)
  8001bb:	e8 98 00 00 00       	call   800258 <cprintf>
  8001c0:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8001c3:	cc                   	int3   
  8001c4:	eb fd                	jmp    8001c3 <_panic+0x43>
	...

008001c8 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001c8:	55                   	push   %ebp
  8001c9:	89 e5                	mov    %esp,%ebp
  8001cb:	53                   	push   %ebx
  8001cc:	83 ec 04             	sub    $0x4,%esp
  8001cf:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001d2:	8b 03                	mov    (%ebx),%eax
  8001d4:	8b 55 08             	mov    0x8(%ebp),%edx
  8001d7:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8001db:	40                   	inc    %eax
  8001dc:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8001de:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001e3:	75 1a                	jne    8001ff <putch+0x37>
		sys_cputs(b->buf, b->idx);
  8001e5:	83 ec 08             	sub    $0x8,%esp
  8001e8:	68 ff 00 00 00       	push   $0xff
  8001ed:	8d 43 08             	lea    0x8(%ebx),%eax
  8001f0:	50                   	push   %eax
  8001f1:	e8 e3 09 00 00       	call   800bd9 <sys_cputs>
		b->idx = 0;
  8001f6:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001fc:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8001ff:	ff 43 04             	incl   0x4(%ebx)
}
  800202:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800205:	c9                   	leave  
  800206:	c3                   	ret    

00800207 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800207:	55                   	push   %ebp
  800208:	89 e5                	mov    %esp,%ebp
  80020a:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800210:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800217:	00 00 00 
	b.cnt = 0;
  80021a:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800221:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800224:	ff 75 0c             	pushl  0xc(%ebp)
  800227:	ff 75 08             	pushl  0x8(%ebp)
  80022a:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800230:	50                   	push   %eax
  800231:	68 c8 01 80 00       	push   $0x8001c8
  800236:	e8 82 01 00 00       	call   8003bd <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80023b:	83 c4 08             	add    $0x8,%esp
  80023e:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800244:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80024a:	50                   	push   %eax
  80024b:	e8 89 09 00 00       	call   800bd9 <sys_cputs>

	return b.cnt;
}
  800250:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800256:	c9                   	leave  
  800257:	c3                   	ret    

00800258 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800258:	55                   	push   %ebp
  800259:	89 e5                	mov    %esp,%ebp
  80025b:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80025e:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800261:	50                   	push   %eax
  800262:	ff 75 08             	pushl  0x8(%ebp)
  800265:	e8 9d ff ff ff       	call   800207 <vcprintf>
	va_end(ap);

	return cnt;
}
  80026a:	c9                   	leave  
  80026b:	c3                   	ret    

0080026c <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80026c:	55                   	push   %ebp
  80026d:	89 e5                	mov    %esp,%ebp
  80026f:	57                   	push   %edi
  800270:	56                   	push   %esi
  800271:	53                   	push   %ebx
  800272:	83 ec 2c             	sub    $0x2c,%esp
  800275:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800278:	89 d6                	mov    %edx,%esi
  80027a:	8b 45 08             	mov    0x8(%ebp),%eax
  80027d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800280:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800283:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800286:	8b 45 10             	mov    0x10(%ebp),%eax
  800289:	8b 5d 14             	mov    0x14(%ebp),%ebx
  80028c:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80028f:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800292:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  800299:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
  80029c:	72 0c                	jb     8002aa <printnum+0x3e>
  80029e:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  8002a1:	76 07                	jbe    8002aa <printnum+0x3e>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002a3:	4b                   	dec    %ebx
  8002a4:	85 db                	test   %ebx,%ebx
  8002a6:	7f 31                	jg     8002d9 <printnum+0x6d>
  8002a8:	eb 3f                	jmp    8002e9 <printnum+0x7d>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002aa:	83 ec 0c             	sub    $0xc,%esp
  8002ad:	57                   	push   %edi
  8002ae:	4b                   	dec    %ebx
  8002af:	53                   	push   %ebx
  8002b0:	50                   	push   %eax
  8002b1:	83 ec 08             	sub    $0x8,%esp
  8002b4:	ff 75 d4             	pushl  -0x2c(%ebp)
  8002b7:	ff 75 d0             	pushl  -0x30(%ebp)
  8002ba:	ff 75 dc             	pushl  -0x24(%ebp)
  8002bd:	ff 75 d8             	pushl  -0x28(%ebp)
  8002c0:	e8 33 0e 00 00       	call   8010f8 <__udivdi3>
  8002c5:	83 c4 18             	add    $0x18,%esp
  8002c8:	52                   	push   %edx
  8002c9:	50                   	push   %eax
  8002ca:	89 f2                	mov    %esi,%edx
  8002cc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8002cf:	e8 98 ff ff ff       	call   80026c <printnum>
  8002d4:	83 c4 20             	add    $0x20,%esp
  8002d7:	eb 10                	jmp    8002e9 <printnum+0x7d>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002d9:	83 ec 08             	sub    $0x8,%esp
  8002dc:	56                   	push   %esi
  8002dd:	57                   	push   %edi
  8002de:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002e1:	4b                   	dec    %ebx
  8002e2:	83 c4 10             	add    $0x10,%esp
  8002e5:	85 db                	test   %ebx,%ebx
  8002e7:	7f f0                	jg     8002d9 <printnum+0x6d>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002e9:	83 ec 08             	sub    $0x8,%esp
  8002ec:	56                   	push   %esi
  8002ed:	83 ec 04             	sub    $0x4,%esp
  8002f0:	ff 75 d4             	pushl  -0x2c(%ebp)
  8002f3:	ff 75 d0             	pushl  -0x30(%ebp)
  8002f6:	ff 75 dc             	pushl  -0x24(%ebp)
  8002f9:	ff 75 d8             	pushl  -0x28(%ebp)
  8002fc:	e8 13 0f 00 00       	call   801214 <__umoddi3>
  800301:	83 c4 14             	add    $0x14,%esp
  800304:	0f be 80 c7 13 80 00 	movsbl 0x8013c7(%eax),%eax
  80030b:	50                   	push   %eax
  80030c:	ff 55 e4             	call   *-0x1c(%ebp)
  80030f:	83 c4 10             	add    $0x10,%esp
}
  800312:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800315:	5b                   	pop    %ebx
  800316:	5e                   	pop    %esi
  800317:	5f                   	pop    %edi
  800318:	c9                   	leave  
  800319:	c3                   	ret    

0080031a <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80031a:	55                   	push   %ebp
  80031b:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80031d:	83 fa 01             	cmp    $0x1,%edx
  800320:	7e 0e                	jle    800330 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800322:	8b 10                	mov    (%eax),%edx
  800324:	8d 4a 08             	lea    0x8(%edx),%ecx
  800327:	89 08                	mov    %ecx,(%eax)
  800329:	8b 02                	mov    (%edx),%eax
  80032b:	8b 52 04             	mov    0x4(%edx),%edx
  80032e:	eb 22                	jmp    800352 <getuint+0x38>
	else if (lflag)
  800330:	85 d2                	test   %edx,%edx
  800332:	74 10                	je     800344 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800334:	8b 10                	mov    (%eax),%edx
  800336:	8d 4a 04             	lea    0x4(%edx),%ecx
  800339:	89 08                	mov    %ecx,(%eax)
  80033b:	8b 02                	mov    (%edx),%eax
  80033d:	ba 00 00 00 00       	mov    $0x0,%edx
  800342:	eb 0e                	jmp    800352 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800344:	8b 10                	mov    (%eax),%edx
  800346:	8d 4a 04             	lea    0x4(%edx),%ecx
  800349:	89 08                	mov    %ecx,(%eax)
  80034b:	8b 02                	mov    (%edx),%eax
  80034d:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800352:	c9                   	leave  
  800353:	c3                   	ret    

00800354 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  800354:	55                   	push   %ebp
  800355:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800357:	83 fa 01             	cmp    $0x1,%edx
  80035a:	7e 0e                	jle    80036a <getint+0x16>
		return va_arg(*ap, long long);
  80035c:	8b 10                	mov    (%eax),%edx
  80035e:	8d 4a 08             	lea    0x8(%edx),%ecx
  800361:	89 08                	mov    %ecx,(%eax)
  800363:	8b 02                	mov    (%edx),%eax
  800365:	8b 52 04             	mov    0x4(%edx),%edx
  800368:	eb 1a                	jmp    800384 <getint+0x30>
	else if (lflag)
  80036a:	85 d2                	test   %edx,%edx
  80036c:	74 0c                	je     80037a <getint+0x26>
		return va_arg(*ap, long);
  80036e:	8b 10                	mov    (%eax),%edx
  800370:	8d 4a 04             	lea    0x4(%edx),%ecx
  800373:	89 08                	mov    %ecx,(%eax)
  800375:	8b 02                	mov    (%edx),%eax
  800377:	99                   	cltd   
  800378:	eb 0a                	jmp    800384 <getint+0x30>
	else
		return va_arg(*ap, int);
  80037a:	8b 10                	mov    (%eax),%edx
  80037c:	8d 4a 04             	lea    0x4(%edx),%ecx
  80037f:	89 08                	mov    %ecx,(%eax)
  800381:	8b 02                	mov    (%edx),%eax
  800383:	99                   	cltd   
}
  800384:	c9                   	leave  
  800385:	c3                   	ret    

00800386 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800386:	55                   	push   %ebp
  800387:	89 e5                	mov    %esp,%ebp
  800389:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80038c:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  80038f:	8b 10                	mov    (%eax),%edx
  800391:	3b 50 04             	cmp    0x4(%eax),%edx
  800394:	73 08                	jae    80039e <sprintputch+0x18>
		*b->buf++ = ch;
  800396:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800399:	88 0a                	mov    %cl,(%edx)
  80039b:	42                   	inc    %edx
  80039c:	89 10                	mov    %edx,(%eax)
}
  80039e:	c9                   	leave  
  80039f:	c3                   	ret    

008003a0 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8003a0:	55                   	push   %ebp
  8003a1:	89 e5                	mov    %esp,%ebp
  8003a3:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8003a6:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8003a9:	50                   	push   %eax
  8003aa:	ff 75 10             	pushl  0x10(%ebp)
  8003ad:	ff 75 0c             	pushl  0xc(%ebp)
  8003b0:	ff 75 08             	pushl  0x8(%ebp)
  8003b3:	e8 05 00 00 00       	call   8003bd <vprintfmt>
	va_end(ap);
  8003b8:	83 c4 10             	add    $0x10,%esp
}
  8003bb:	c9                   	leave  
  8003bc:	c3                   	ret    

008003bd <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8003bd:	55                   	push   %ebp
  8003be:	89 e5                	mov    %esp,%ebp
  8003c0:	57                   	push   %edi
  8003c1:	56                   	push   %esi
  8003c2:	53                   	push   %ebx
  8003c3:	83 ec 2c             	sub    $0x2c,%esp
  8003c6:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8003c9:	8b 75 10             	mov    0x10(%ebp),%esi
  8003cc:	eb 13                	jmp    8003e1 <vprintfmt+0x24>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8003ce:	85 c0                	test   %eax,%eax
  8003d0:	0f 84 6d 03 00 00    	je     800743 <vprintfmt+0x386>
				return;
			putch(ch, putdat);
  8003d6:	83 ec 08             	sub    $0x8,%esp
  8003d9:	57                   	push   %edi
  8003da:	50                   	push   %eax
  8003db:	ff 55 08             	call   *0x8(%ebp)
  8003de:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8003e1:	0f b6 06             	movzbl (%esi),%eax
  8003e4:	46                   	inc    %esi
  8003e5:	83 f8 25             	cmp    $0x25,%eax
  8003e8:	75 e4                	jne    8003ce <vprintfmt+0x11>
  8003ea:	c6 45 dc 20          	movb   $0x20,-0x24(%ebp)
  8003ee:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  8003f5:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  8003fc:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800403:	b9 00 00 00 00       	mov    $0x0,%ecx
  800408:	eb 28                	jmp    800432 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80040a:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  80040c:	c6 45 dc 2d          	movb   $0x2d,-0x24(%ebp)
  800410:	eb 20                	jmp    800432 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800412:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800414:	c6 45 dc 30          	movb   $0x30,-0x24(%ebp)
  800418:	eb 18                	jmp    800432 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80041a:	89 de                	mov    %ebx,%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  80041c:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800423:	eb 0d                	jmp    800432 <vprintfmt+0x75>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800425:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800428:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80042b:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800432:	8a 06                	mov    (%esi),%al
  800434:	0f b6 d0             	movzbl %al,%edx
  800437:	8d 5e 01             	lea    0x1(%esi),%ebx
  80043a:	83 e8 23             	sub    $0x23,%eax
  80043d:	3c 55                	cmp    $0x55,%al
  80043f:	0f 87 e0 02 00 00    	ja     800725 <vprintfmt+0x368>
  800445:	0f b6 c0             	movzbl %al,%eax
  800448:	ff 24 85 80 14 80 00 	jmp    *0x801480(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80044f:	83 ea 30             	sub    $0x30,%edx
  800452:	89 55 d4             	mov    %edx,-0x2c(%ebp)
				ch = *fmt;
  800455:	0f be 03             	movsbl (%ebx),%eax
				if (ch < '0' || ch > '9')
  800458:	8d 50 d0             	lea    -0x30(%eax),%edx
  80045b:	83 fa 09             	cmp    $0x9,%edx
  80045e:	77 44                	ja     8004a4 <vprintfmt+0xe7>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800460:	89 de                	mov    %ebx,%esi
  800462:	8b 55 d4             	mov    -0x2c(%ebp),%edx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800465:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
  800466:	8d 14 92             	lea    (%edx,%edx,4),%edx
  800469:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
  80046d:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800470:	8d 58 d0             	lea    -0x30(%eax),%ebx
  800473:	83 fb 09             	cmp    $0x9,%ebx
  800476:	76 ed                	jbe    800465 <vprintfmt+0xa8>
  800478:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  80047b:	eb 29                	jmp    8004a6 <vprintfmt+0xe9>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80047d:	8b 45 14             	mov    0x14(%ebp),%eax
  800480:	8d 50 04             	lea    0x4(%eax),%edx
  800483:	89 55 14             	mov    %edx,0x14(%ebp)
  800486:	8b 00                	mov    (%eax),%eax
  800488:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80048b:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80048d:	eb 17                	jmp    8004a6 <vprintfmt+0xe9>

		case '.':
			if (width < 0)
  80048f:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800493:	78 85                	js     80041a <vprintfmt+0x5d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800495:	89 de                	mov    %ebx,%esi
  800497:	eb 99                	jmp    800432 <vprintfmt+0x75>
  800499:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80049b:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  8004a2:	eb 8e                	jmp    800432 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004a4:	89 de                	mov    %ebx,%esi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  8004a6:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8004aa:	79 86                	jns    800432 <vprintfmt+0x75>
  8004ac:	e9 74 ff ff ff       	jmp    800425 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8004b1:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004b2:	89 de                	mov    %ebx,%esi
  8004b4:	e9 79 ff ff ff       	jmp    800432 <vprintfmt+0x75>
  8004b9:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8004bc:	8b 45 14             	mov    0x14(%ebp),%eax
  8004bf:	8d 50 04             	lea    0x4(%eax),%edx
  8004c2:	89 55 14             	mov    %edx,0x14(%ebp)
  8004c5:	83 ec 08             	sub    $0x8,%esp
  8004c8:	57                   	push   %edi
  8004c9:	ff 30                	pushl  (%eax)
  8004cb:	ff 55 08             	call   *0x8(%ebp)
			break;
  8004ce:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004d1:	8b 75 d8             	mov    -0x28(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8004d4:	e9 08 ff ff ff       	jmp    8003e1 <vprintfmt+0x24>
  8004d9:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  8004dc:	8b 45 14             	mov    0x14(%ebp),%eax
  8004df:	8d 50 04             	lea    0x4(%eax),%edx
  8004e2:	89 55 14             	mov    %edx,0x14(%ebp)
  8004e5:	8b 00                	mov    (%eax),%eax
  8004e7:	85 c0                	test   %eax,%eax
  8004e9:	79 02                	jns    8004ed <vprintfmt+0x130>
  8004eb:	f7 d8                	neg    %eax
  8004ed:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004ef:	83 f8 08             	cmp    $0x8,%eax
  8004f2:	7f 0b                	jg     8004ff <vprintfmt+0x142>
  8004f4:	8b 04 85 e0 15 80 00 	mov    0x8015e0(,%eax,4),%eax
  8004fb:	85 c0                	test   %eax,%eax
  8004fd:	75 1a                	jne    800519 <vprintfmt+0x15c>
				printfmt(putch, putdat, "error %d", err);
  8004ff:	52                   	push   %edx
  800500:	68 df 13 80 00       	push   $0x8013df
  800505:	57                   	push   %edi
  800506:	ff 75 08             	pushl  0x8(%ebp)
  800509:	e8 92 fe ff ff       	call   8003a0 <printfmt>
  80050e:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800511:	8b 75 d8             	mov    -0x28(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800514:	e9 c8 fe ff ff       	jmp    8003e1 <vprintfmt+0x24>
			else
				printfmt(putch, putdat, "%s", p);
  800519:	50                   	push   %eax
  80051a:	68 e8 13 80 00       	push   $0x8013e8
  80051f:	57                   	push   %edi
  800520:	ff 75 08             	pushl  0x8(%ebp)
  800523:	e8 78 fe ff ff       	call   8003a0 <printfmt>
  800528:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80052b:	8b 75 d8             	mov    -0x28(%ebp),%esi
  80052e:	e9 ae fe ff ff       	jmp    8003e1 <vprintfmt+0x24>
  800533:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  800536:	89 de                	mov    %ebx,%esi
  800538:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  80053b:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80053e:	8b 45 14             	mov    0x14(%ebp),%eax
  800541:	8d 50 04             	lea    0x4(%eax),%edx
  800544:	89 55 14             	mov    %edx,0x14(%ebp)
  800547:	8b 00                	mov    (%eax),%eax
  800549:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80054c:	85 c0                	test   %eax,%eax
  80054e:	75 07                	jne    800557 <vprintfmt+0x19a>
				p = "(null)";
  800550:	c7 45 d0 d8 13 80 00 	movl   $0x8013d8,-0x30(%ebp)
			if (width > 0 && padc != '-')
  800557:	85 db                	test   %ebx,%ebx
  800559:	7e 42                	jle    80059d <vprintfmt+0x1e0>
  80055b:	80 7d dc 2d          	cmpb   $0x2d,-0x24(%ebp)
  80055f:	74 3c                	je     80059d <vprintfmt+0x1e0>
				for (width -= strnlen(p, precision); width > 0; width--)
  800561:	83 ec 08             	sub    $0x8,%esp
  800564:	51                   	push   %ecx
  800565:	ff 75 d0             	pushl  -0x30(%ebp)
  800568:	e8 6f 02 00 00       	call   8007dc <strnlen>
  80056d:	29 c3                	sub    %eax,%ebx
  80056f:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800572:	83 c4 10             	add    $0x10,%esp
  800575:	85 db                	test   %ebx,%ebx
  800577:	7e 24                	jle    80059d <vprintfmt+0x1e0>
					putch(padc, putdat);
  800579:	0f be 5d dc          	movsbl -0x24(%ebp),%ebx
  80057d:	89 75 dc             	mov    %esi,-0x24(%ebp)
  800580:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  800583:	83 ec 08             	sub    $0x8,%esp
  800586:	57                   	push   %edi
  800587:	53                   	push   %ebx
  800588:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80058b:	4e                   	dec    %esi
  80058c:	83 c4 10             	add    $0x10,%esp
  80058f:	85 f6                	test   %esi,%esi
  800591:	7f f0                	jg     800583 <vprintfmt+0x1c6>
  800593:	8b 75 dc             	mov    -0x24(%ebp),%esi
  800596:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80059d:	8b 55 d0             	mov    -0x30(%ebp),%edx
  8005a0:	0f be 02             	movsbl (%edx),%eax
  8005a3:	85 c0                	test   %eax,%eax
  8005a5:	75 47                	jne    8005ee <vprintfmt+0x231>
  8005a7:	eb 37                	jmp    8005e0 <vprintfmt+0x223>
				if (altflag && (ch < ' ' || ch > '~'))
  8005a9:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8005ad:	74 16                	je     8005c5 <vprintfmt+0x208>
  8005af:	8d 50 e0             	lea    -0x20(%eax),%edx
  8005b2:	83 fa 5e             	cmp    $0x5e,%edx
  8005b5:	76 0e                	jbe    8005c5 <vprintfmt+0x208>
					putch('?', putdat);
  8005b7:	83 ec 08             	sub    $0x8,%esp
  8005ba:	57                   	push   %edi
  8005bb:	6a 3f                	push   $0x3f
  8005bd:	ff 55 08             	call   *0x8(%ebp)
  8005c0:	83 c4 10             	add    $0x10,%esp
  8005c3:	eb 0b                	jmp    8005d0 <vprintfmt+0x213>
				else
					putch(ch, putdat);
  8005c5:	83 ec 08             	sub    $0x8,%esp
  8005c8:	57                   	push   %edi
  8005c9:	50                   	push   %eax
  8005ca:	ff 55 08             	call   *0x8(%ebp)
  8005cd:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005d0:	ff 4d e4             	decl   -0x1c(%ebp)
  8005d3:	0f be 03             	movsbl (%ebx),%eax
  8005d6:	85 c0                	test   %eax,%eax
  8005d8:	74 03                	je     8005dd <vprintfmt+0x220>
  8005da:	43                   	inc    %ebx
  8005db:	eb 1b                	jmp    8005f8 <vprintfmt+0x23b>
  8005dd:	8b 75 dc             	mov    -0x24(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005e0:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8005e4:	7f 1e                	jg     800604 <vprintfmt+0x247>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005e6:	8b 75 d8             	mov    -0x28(%ebp),%esi
  8005e9:	e9 f3 fd ff ff       	jmp    8003e1 <vprintfmt+0x24>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005ee:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  8005f1:	43                   	inc    %ebx
  8005f2:	89 75 dc             	mov    %esi,-0x24(%ebp)
  8005f5:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  8005f8:	85 f6                	test   %esi,%esi
  8005fa:	78 ad                	js     8005a9 <vprintfmt+0x1ec>
  8005fc:	4e                   	dec    %esi
  8005fd:	79 aa                	jns    8005a9 <vprintfmt+0x1ec>
  8005ff:	8b 75 dc             	mov    -0x24(%ebp),%esi
  800602:	eb dc                	jmp    8005e0 <vprintfmt+0x223>
  800604:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800607:	83 ec 08             	sub    $0x8,%esp
  80060a:	57                   	push   %edi
  80060b:	6a 20                	push   $0x20
  80060d:	ff 55 08             	call   *0x8(%ebp)
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800610:	4b                   	dec    %ebx
  800611:	83 c4 10             	add    $0x10,%esp
  800614:	85 db                	test   %ebx,%ebx
  800616:	7f ef                	jg     800607 <vprintfmt+0x24a>
  800618:	e9 c4 fd ff ff       	jmp    8003e1 <vprintfmt+0x24>
  80061d:	89 5d d8             	mov    %ebx,-0x28(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800620:	89 ca                	mov    %ecx,%edx
  800622:	8d 45 14             	lea    0x14(%ebp),%eax
  800625:	e8 2a fd ff ff       	call   800354 <getint>
  80062a:	89 c3                	mov    %eax,%ebx
  80062c:	89 d6                	mov    %edx,%esi
			if ((long long) num < 0) {
  80062e:	85 d2                	test   %edx,%edx
  800630:	78 0a                	js     80063c <vprintfmt+0x27f>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800632:	b8 0a 00 00 00       	mov    $0xa,%eax
  800637:	e9 b0 00 00 00       	jmp    8006ec <vprintfmt+0x32f>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  80063c:	83 ec 08             	sub    $0x8,%esp
  80063f:	57                   	push   %edi
  800640:	6a 2d                	push   $0x2d
  800642:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800645:	f7 db                	neg    %ebx
  800647:	83 d6 00             	adc    $0x0,%esi
  80064a:	f7 de                	neg    %esi
  80064c:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  80064f:	b8 0a 00 00 00       	mov    $0xa,%eax
  800654:	e9 93 00 00 00       	jmp    8006ec <vprintfmt+0x32f>
  800659:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80065c:	89 ca                	mov    %ecx,%edx
  80065e:	8d 45 14             	lea    0x14(%ebp),%eax
  800661:	e8 b4 fc ff ff       	call   80031a <getuint>
  800666:	89 c3                	mov    %eax,%ebx
  800668:	89 d6                	mov    %edx,%esi
			base = 10;
  80066a:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  80066f:	eb 7b                	jmp    8006ec <vprintfmt+0x32f>
  800671:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
  800674:	89 ca                	mov    %ecx,%edx
  800676:	8d 45 14             	lea    0x14(%ebp),%eax
  800679:	e8 d6 fc ff ff       	call   800354 <getint>
  80067e:	89 c3                	mov    %eax,%ebx
  800680:	89 d6                	mov    %edx,%esi
            if ((long long) num < 0) {
  800682:	85 d2                	test   %edx,%edx
  800684:	78 07                	js     80068d <vprintfmt+0x2d0>
                putch('-', putdat);
                num = -(long long) num;
            }
            base = 8;
  800686:	b8 08 00 00 00       	mov    $0x8,%eax
  80068b:	eb 5f                	jmp    8006ec <vprintfmt+0x32f>
		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
            if ((long long) num < 0) {
                putch('-', putdat);
  80068d:	83 ec 08             	sub    $0x8,%esp
  800690:	57                   	push   %edi
  800691:	6a 2d                	push   $0x2d
  800693:	ff 55 08             	call   *0x8(%ebp)
                num = -(long long) num;
  800696:	f7 db                	neg    %ebx
  800698:	83 d6 00             	adc    $0x0,%esi
  80069b:	f7 de                	neg    %esi
  80069d:	83 c4 10             	add    $0x10,%esp
            }
            base = 8;
  8006a0:	b8 08 00 00 00       	mov    $0x8,%eax
  8006a5:	eb 45                	jmp    8006ec <vprintfmt+0x32f>
  8006a7:	89 5d d8             	mov    %ebx,-0x28(%ebp)
            goto number;

        // pointer
		case 'p':
			putch('0', putdat);
  8006aa:	83 ec 08             	sub    $0x8,%esp
  8006ad:	57                   	push   %edi
  8006ae:	6a 30                	push   $0x30
  8006b0:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8006b3:	83 c4 08             	add    $0x8,%esp
  8006b6:	57                   	push   %edi
  8006b7:	6a 78                	push   $0x78
  8006b9:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8006bc:	8b 45 14             	mov    0x14(%ebp),%eax
  8006bf:	8d 50 04             	lea    0x4(%eax),%edx
  8006c2:	89 55 14             	mov    %edx,0x14(%ebp)

        // pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8006c5:	8b 18                	mov    (%eax),%ebx
  8006c7:	be 00 00 00 00       	mov    $0x0,%esi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8006cc:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8006cf:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8006d4:	eb 16                	jmp    8006ec <vprintfmt+0x32f>
  8006d6:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8006d9:	89 ca                	mov    %ecx,%edx
  8006db:	8d 45 14             	lea    0x14(%ebp),%eax
  8006de:	e8 37 fc ff ff       	call   80031a <getuint>
  8006e3:	89 c3                	mov    %eax,%ebx
  8006e5:	89 d6                	mov    %edx,%esi
			base = 16;
  8006e7:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006ec:	83 ec 0c             	sub    $0xc,%esp
  8006ef:	0f be 55 dc          	movsbl -0x24(%ebp),%edx
  8006f3:	52                   	push   %edx
  8006f4:	ff 75 e4             	pushl  -0x1c(%ebp)
  8006f7:	50                   	push   %eax
  8006f8:	56                   	push   %esi
  8006f9:	53                   	push   %ebx
  8006fa:	89 fa                	mov    %edi,%edx
  8006fc:	8b 45 08             	mov    0x8(%ebp),%eax
  8006ff:	e8 68 fb ff ff       	call   80026c <printnum>
			break;
  800704:	83 c4 20             	add    $0x20,%esp
  800707:	8b 75 d8             	mov    -0x28(%ebp),%esi
  80070a:	e9 d2 fc ff ff       	jmp    8003e1 <vprintfmt+0x24>
  80070f:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800712:	83 ec 08             	sub    $0x8,%esp
  800715:	57                   	push   %edi
  800716:	52                   	push   %edx
  800717:	ff 55 08             	call   *0x8(%ebp)
			break;
  80071a:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80071d:	8b 75 d8             	mov    -0x28(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800720:	e9 bc fc ff ff       	jmp    8003e1 <vprintfmt+0x24>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800725:	83 ec 08             	sub    $0x8,%esp
  800728:	57                   	push   %edi
  800729:	6a 25                	push   $0x25
  80072b:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  80072e:	83 c4 10             	add    $0x10,%esp
  800731:	eb 02                	jmp    800735 <vprintfmt+0x378>
  800733:	89 c6                	mov    %eax,%esi
  800735:	8d 46 ff             	lea    -0x1(%esi),%eax
  800738:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  80073c:	75 f5                	jne    800733 <vprintfmt+0x376>
  80073e:	e9 9e fc ff ff       	jmp    8003e1 <vprintfmt+0x24>
				/* do nothing */;
			break;
		}
	}
}
  800743:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800746:	5b                   	pop    %ebx
  800747:	5e                   	pop    %esi
  800748:	5f                   	pop    %edi
  800749:	c9                   	leave  
  80074a:	c3                   	ret    

0080074b <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80074b:	55                   	push   %ebp
  80074c:	89 e5                	mov    %esp,%ebp
  80074e:	83 ec 18             	sub    $0x18,%esp
  800751:	8b 45 08             	mov    0x8(%ebp),%eax
  800754:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800757:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80075a:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80075e:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800761:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800768:	85 c0                	test   %eax,%eax
  80076a:	74 26                	je     800792 <vsnprintf+0x47>
  80076c:	85 d2                	test   %edx,%edx
  80076e:	7e 29                	jle    800799 <vsnprintf+0x4e>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800770:	ff 75 14             	pushl  0x14(%ebp)
  800773:	ff 75 10             	pushl  0x10(%ebp)
  800776:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800779:	50                   	push   %eax
  80077a:	68 86 03 80 00       	push   $0x800386
  80077f:	e8 39 fc ff ff       	call   8003bd <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800784:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800787:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80078a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80078d:	83 c4 10             	add    $0x10,%esp
  800790:	eb 0c                	jmp    80079e <vsnprintf+0x53>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800792:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800797:	eb 05                	jmp    80079e <vsnprintf+0x53>
  800799:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80079e:	c9                   	leave  
  80079f:	c3                   	ret    

008007a0 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007a0:	55                   	push   %ebp
  8007a1:	89 e5                	mov    %esp,%ebp
  8007a3:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007a6:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8007a9:	50                   	push   %eax
  8007aa:	ff 75 10             	pushl  0x10(%ebp)
  8007ad:	ff 75 0c             	pushl  0xc(%ebp)
  8007b0:	ff 75 08             	pushl  0x8(%ebp)
  8007b3:	e8 93 ff ff ff       	call   80074b <vsnprintf>
	va_end(ap);

	return rc;
}
  8007b8:	c9                   	leave  
  8007b9:	c3                   	ret    
	...

008007bc <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007bc:	55                   	push   %ebp
  8007bd:	89 e5                	mov    %esp,%ebp
  8007bf:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007c2:	80 3a 00             	cmpb   $0x0,(%edx)
  8007c5:	74 0e                	je     8007d5 <strlen+0x19>
  8007c7:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  8007cc:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8007cd:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007d1:	75 f9                	jne    8007cc <strlen+0x10>
  8007d3:	eb 05                	jmp    8007da <strlen+0x1e>
  8007d5:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  8007da:	c9                   	leave  
  8007db:	c3                   	ret    

008007dc <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007dc:	55                   	push   %ebp
  8007dd:	89 e5                	mov    %esp,%ebp
  8007df:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007e2:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007e5:	85 d2                	test   %edx,%edx
  8007e7:	74 17                	je     800800 <strnlen+0x24>
  8007e9:	80 39 00             	cmpb   $0x0,(%ecx)
  8007ec:	74 19                	je     800807 <strnlen+0x2b>
  8007ee:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  8007f3:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007f4:	39 d0                	cmp    %edx,%eax
  8007f6:	74 14                	je     80080c <strnlen+0x30>
  8007f8:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8007fc:	75 f5                	jne    8007f3 <strnlen+0x17>
  8007fe:	eb 0c                	jmp    80080c <strnlen+0x30>
  800800:	b8 00 00 00 00       	mov    $0x0,%eax
  800805:	eb 05                	jmp    80080c <strnlen+0x30>
  800807:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  80080c:	c9                   	leave  
  80080d:	c3                   	ret    

0080080e <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80080e:	55                   	push   %ebp
  80080f:	89 e5                	mov    %esp,%ebp
  800811:	53                   	push   %ebx
  800812:	8b 45 08             	mov    0x8(%ebp),%eax
  800815:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800818:	ba 00 00 00 00       	mov    $0x0,%edx
  80081d:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  800820:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800823:	42                   	inc    %edx
  800824:	84 c9                	test   %cl,%cl
  800826:	75 f5                	jne    80081d <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800828:	5b                   	pop    %ebx
  800829:	c9                   	leave  
  80082a:	c3                   	ret    

0080082b <strcat>:

char *
strcat(char *dst, const char *src)
{
  80082b:	55                   	push   %ebp
  80082c:	89 e5                	mov    %esp,%ebp
  80082e:	53                   	push   %ebx
  80082f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800832:	53                   	push   %ebx
  800833:	e8 84 ff ff ff       	call   8007bc <strlen>
  800838:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  80083b:	ff 75 0c             	pushl  0xc(%ebp)
  80083e:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  800841:	50                   	push   %eax
  800842:	e8 c7 ff ff ff       	call   80080e <strcpy>
	return dst;
}
  800847:	89 d8                	mov    %ebx,%eax
  800849:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80084c:	c9                   	leave  
  80084d:	c3                   	ret    

0080084e <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80084e:	55                   	push   %ebp
  80084f:	89 e5                	mov    %esp,%ebp
  800851:	56                   	push   %esi
  800852:	53                   	push   %ebx
  800853:	8b 45 08             	mov    0x8(%ebp),%eax
  800856:	8b 55 0c             	mov    0xc(%ebp),%edx
  800859:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80085c:	85 f6                	test   %esi,%esi
  80085e:	74 15                	je     800875 <strncpy+0x27>
  800860:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  800865:	8a 1a                	mov    (%edx),%bl
  800867:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80086a:	80 3a 01             	cmpb   $0x1,(%edx)
  80086d:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800870:	41                   	inc    %ecx
  800871:	39 ce                	cmp    %ecx,%esi
  800873:	77 f0                	ja     800865 <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800875:	5b                   	pop    %ebx
  800876:	5e                   	pop    %esi
  800877:	c9                   	leave  
  800878:	c3                   	ret    

00800879 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800879:	55                   	push   %ebp
  80087a:	89 e5                	mov    %esp,%ebp
  80087c:	57                   	push   %edi
  80087d:	56                   	push   %esi
  80087e:	53                   	push   %ebx
  80087f:	8b 7d 08             	mov    0x8(%ebp),%edi
  800882:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800885:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800888:	85 f6                	test   %esi,%esi
  80088a:	74 32                	je     8008be <strlcpy+0x45>
		while (--size > 0 && *src != '\0')
  80088c:	83 fe 01             	cmp    $0x1,%esi
  80088f:	74 22                	je     8008b3 <strlcpy+0x3a>
  800891:	8a 0b                	mov    (%ebx),%cl
  800893:	84 c9                	test   %cl,%cl
  800895:	74 20                	je     8008b7 <strlcpy+0x3e>
  800897:	89 f8                	mov    %edi,%eax
  800899:	ba 00 00 00 00       	mov    $0x0,%edx
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
  80089e:	83 ee 02             	sub    $0x2,%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8008a1:	88 08                	mov    %cl,(%eax)
  8008a3:	40                   	inc    %eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8008a4:	39 f2                	cmp    %esi,%edx
  8008a6:	74 11                	je     8008b9 <strlcpy+0x40>
  8008a8:	8a 4c 13 01          	mov    0x1(%ebx,%edx,1),%cl
  8008ac:	42                   	inc    %edx
  8008ad:	84 c9                	test   %cl,%cl
  8008af:	75 f0                	jne    8008a1 <strlcpy+0x28>
  8008b1:	eb 06                	jmp    8008b9 <strlcpy+0x40>
  8008b3:	89 f8                	mov    %edi,%eax
  8008b5:	eb 02                	jmp    8008b9 <strlcpy+0x40>
  8008b7:	89 f8                	mov    %edi,%eax
			*dst++ = *src++;
		*dst = '\0';
  8008b9:	c6 00 00             	movb   $0x0,(%eax)
  8008bc:	eb 02                	jmp    8008c0 <strlcpy+0x47>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8008be:	89 f8                	mov    %edi,%eax
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
		*dst = '\0';
	}
	return dst - dst_in;
  8008c0:	29 f8                	sub    %edi,%eax
}
  8008c2:	5b                   	pop    %ebx
  8008c3:	5e                   	pop    %esi
  8008c4:	5f                   	pop    %edi
  8008c5:	c9                   	leave  
  8008c6:	c3                   	ret    

008008c7 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8008c7:	55                   	push   %ebp
  8008c8:	89 e5                	mov    %esp,%ebp
  8008ca:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008cd:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008d0:	8a 01                	mov    (%ecx),%al
  8008d2:	84 c0                	test   %al,%al
  8008d4:	74 10                	je     8008e6 <strcmp+0x1f>
  8008d6:	3a 02                	cmp    (%edx),%al
  8008d8:	75 0c                	jne    8008e6 <strcmp+0x1f>
		p++, q++;
  8008da:	41                   	inc    %ecx
  8008db:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8008dc:	8a 01                	mov    (%ecx),%al
  8008de:	84 c0                	test   %al,%al
  8008e0:	74 04                	je     8008e6 <strcmp+0x1f>
  8008e2:	3a 02                	cmp    (%edx),%al
  8008e4:	74 f4                	je     8008da <strcmp+0x13>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008e6:	0f b6 c0             	movzbl %al,%eax
  8008e9:	0f b6 12             	movzbl (%edx),%edx
  8008ec:	29 d0                	sub    %edx,%eax
}
  8008ee:	c9                   	leave  
  8008ef:	c3                   	ret    

008008f0 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008f0:	55                   	push   %ebp
  8008f1:	89 e5                	mov    %esp,%ebp
  8008f3:	53                   	push   %ebx
  8008f4:	8b 55 08             	mov    0x8(%ebp),%edx
  8008f7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008fa:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  8008fd:	85 c0                	test   %eax,%eax
  8008ff:	74 1b                	je     80091c <strncmp+0x2c>
  800901:	8a 1a                	mov    (%edx),%bl
  800903:	84 db                	test   %bl,%bl
  800905:	74 24                	je     80092b <strncmp+0x3b>
  800907:	3a 19                	cmp    (%ecx),%bl
  800909:	75 20                	jne    80092b <strncmp+0x3b>
  80090b:	48                   	dec    %eax
  80090c:	74 15                	je     800923 <strncmp+0x33>
		n--, p++, q++;
  80090e:	42                   	inc    %edx
  80090f:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800910:	8a 1a                	mov    (%edx),%bl
  800912:	84 db                	test   %bl,%bl
  800914:	74 15                	je     80092b <strncmp+0x3b>
  800916:	3a 19                	cmp    (%ecx),%bl
  800918:	74 f1                	je     80090b <strncmp+0x1b>
  80091a:	eb 0f                	jmp    80092b <strncmp+0x3b>
		n--, p++, q++;
	if (n == 0)
		return 0;
  80091c:	b8 00 00 00 00       	mov    $0x0,%eax
  800921:	eb 05                	jmp    800928 <strncmp+0x38>
  800923:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800928:	5b                   	pop    %ebx
  800929:	c9                   	leave  
  80092a:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80092b:	0f b6 02             	movzbl (%edx),%eax
  80092e:	0f b6 11             	movzbl (%ecx),%edx
  800931:	29 d0                	sub    %edx,%eax
  800933:	eb f3                	jmp    800928 <strncmp+0x38>

00800935 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800935:	55                   	push   %ebp
  800936:	89 e5                	mov    %esp,%ebp
  800938:	8b 45 08             	mov    0x8(%ebp),%eax
  80093b:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  80093e:	8a 10                	mov    (%eax),%dl
  800940:	84 d2                	test   %dl,%dl
  800942:	74 18                	je     80095c <strchr+0x27>
		if (*s == c)
  800944:	38 ca                	cmp    %cl,%dl
  800946:	75 06                	jne    80094e <strchr+0x19>
  800948:	eb 17                	jmp    800961 <strchr+0x2c>
  80094a:	38 ca                	cmp    %cl,%dl
  80094c:	74 13                	je     800961 <strchr+0x2c>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80094e:	40                   	inc    %eax
  80094f:	8a 10                	mov    (%eax),%dl
  800951:	84 d2                	test   %dl,%dl
  800953:	75 f5                	jne    80094a <strchr+0x15>
		if (*s == c)
			return (char *) s;
	return 0;
  800955:	b8 00 00 00 00       	mov    $0x0,%eax
  80095a:	eb 05                	jmp    800961 <strchr+0x2c>
  80095c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800961:	c9                   	leave  
  800962:	c3                   	ret    

00800963 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800963:	55                   	push   %ebp
  800964:	89 e5                	mov    %esp,%ebp
  800966:	8b 45 08             	mov    0x8(%ebp),%eax
  800969:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  80096c:	8a 10                	mov    (%eax),%dl
  80096e:	84 d2                	test   %dl,%dl
  800970:	74 11                	je     800983 <strfind+0x20>
		if (*s == c)
  800972:	38 ca                	cmp    %cl,%dl
  800974:	75 06                	jne    80097c <strfind+0x19>
  800976:	eb 0b                	jmp    800983 <strfind+0x20>
  800978:	38 ca                	cmp    %cl,%dl
  80097a:	74 07                	je     800983 <strfind+0x20>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  80097c:	40                   	inc    %eax
  80097d:	8a 10                	mov    (%eax),%dl
  80097f:	84 d2                	test   %dl,%dl
  800981:	75 f5                	jne    800978 <strfind+0x15>
		if (*s == c)
			break;
	return (char *) s;
}
  800983:	c9                   	leave  
  800984:	c3                   	ret    

00800985 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800985:	55                   	push   %ebp
  800986:	89 e5                	mov    %esp,%ebp
  800988:	57                   	push   %edi
  800989:	56                   	push   %esi
  80098a:	53                   	push   %ebx
  80098b:	8b 7d 08             	mov    0x8(%ebp),%edi
  80098e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800991:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800994:	85 c9                	test   %ecx,%ecx
  800996:	74 30                	je     8009c8 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800998:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80099e:	75 25                	jne    8009c5 <memset+0x40>
  8009a0:	f6 c1 03             	test   $0x3,%cl
  8009a3:	75 20                	jne    8009c5 <memset+0x40>
		c &= 0xFF;
  8009a5:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8009a8:	89 d3                	mov    %edx,%ebx
  8009aa:	c1 e3 08             	shl    $0x8,%ebx
  8009ad:	89 d6                	mov    %edx,%esi
  8009af:	c1 e6 18             	shl    $0x18,%esi
  8009b2:	89 d0                	mov    %edx,%eax
  8009b4:	c1 e0 10             	shl    $0x10,%eax
  8009b7:	09 f0                	or     %esi,%eax
  8009b9:	09 d0                	or     %edx,%eax
  8009bb:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  8009bd:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  8009c0:	fc                   	cld    
  8009c1:	f3 ab                	rep stos %eax,%es:(%edi)
  8009c3:	eb 03                	jmp    8009c8 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8009c5:	fc                   	cld    
  8009c6:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8009c8:	89 f8                	mov    %edi,%eax
  8009ca:	5b                   	pop    %ebx
  8009cb:	5e                   	pop    %esi
  8009cc:	5f                   	pop    %edi
  8009cd:	c9                   	leave  
  8009ce:	c3                   	ret    

008009cf <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8009cf:	55                   	push   %ebp
  8009d0:	89 e5                	mov    %esp,%ebp
  8009d2:	57                   	push   %edi
  8009d3:	56                   	push   %esi
  8009d4:	8b 45 08             	mov    0x8(%ebp),%eax
  8009d7:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009da:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8009dd:	39 c6                	cmp    %eax,%esi
  8009df:	73 34                	jae    800a15 <memmove+0x46>
  8009e1:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8009e4:	39 d0                	cmp    %edx,%eax
  8009e6:	73 2d                	jae    800a15 <memmove+0x46>
		s += n;
		d += n;
  8009e8:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009eb:	f6 c2 03             	test   $0x3,%dl
  8009ee:	75 1b                	jne    800a0b <memmove+0x3c>
  8009f0:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8009f6:	75 13                	jne    800a0b <memmove+0x3c>
  8009f8:	f6 c1 03             	test   $0x3,%cl
  8009fb:	75 0e                	jne    800a0b <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8009fd:	83 ef 04             	sub    $0x4,%edi
  800a00:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a03:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800a06:	fd                   	std    
  800a07:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a09:	eb 07                	jmp    800a12 <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800a0b:	4f                   	dec    %edi
  800a0c:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800a0f:	fd                   	std    
  800a10:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a12:	fc                   	cld    
  800a13:	eb 20                	jmp    800a35 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a15:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a1b:	75 13                	jne    800a30 <memmove+0x61>
  800a1d:	a8 03                	test   $0x3,%al
  800a1f:	75 0f                	jne    800a30 <memmove+0x61>
  800a21:	f6 c1 03             	test   $0x3,%cl
  800a24:	75 0a                	jne    800a30 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800a26:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800a29:	89 c7                	mov    %eax,%edi
  800a2b:	fc                   	cld    
  800a2c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a2e:	eb 05                	jmp    800a35 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a30:	89 c7                	mov    %eax,%edi
  800a32:	fc                   	cld    
  800a33:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a35:	5e                   	pop    %esi
  800a36:	5f                   	pop    %edi
  800a37:	c9                   	leave  
  800a38:	c3                   	ret    

00800a39 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a39:	55                   	push   %ebp
  800a3a:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800a3c:	ff 75 10             	pushl  0x10(%ebp)
  800a3f:	ff 75 0c             	pushl  0xc(%ebp)
  800a42:	ff 75 08             	pushl  0x8(%ebp)
  800a45:	e8 85 ff ff ff       	call   8009cf <memmove>
}
  800a4a:	c9                   	leave  
  800a4b:	c3                   	ret    

00800a4c <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a4c:	55                   	push   %ebp
  800a4d:	89 e5                	mov    %esp,%ebp
  800a4f:	57                   	push   %edi
  800a50:	56                   	push   %esi
  800a51:	53                   	push   %ebx
  800a52:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800a55:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a58:	8b 7d 10             	mov    0x10(%ebp),%edi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a5b:	85 ff                	test   %edi,%edi
  800a5d:	74 32                	je     800a91 <memcmp+0x45>
		if (*s1 != *s2)
  800a5f:	8a 03                	mov    (%ebx),%al
  800a61:	8a 0e                	mov    (%esi),%cl
  800a63:	38 c8                	cmp    %cl,%al
  800a65:	74 19                	je     800a80 <memcmp+0x34>
  800a67:	eb 0d                	jmp    800a76 <memcmp+0x2a>
  800a69:	8a 44 13 01          	mov    0x1(%ebx,%edx,1),%al
  800a6d:	8a 4c 16 01          	mov    0x1(%esi,%edx,1),%cl
  800a71:	42                   	inc    %edx
  800a72:	38 c8                	cmp    %cl,%al
  800a74:	74 10                	je     800a86 <memcmp+0x3a>
			return (int) *s1 - (int) *s2;
  800a76:	0f b6 c0             	movzbl %al,%eax
  800a79:	0f b6 c9             	movzbl %cl,%ecx
  800a7c:	29 c8                	sub    %ecx,%eax
  800a7e:	eb 16                	jmp    800a96 <memcmp+0x4a>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a80:	4f                   	dec    %edi
  800a81:	ba 00 00 00 00       	mov    $0x0,%edx
  800a86:	39 fa                	cmp    %edi,%edx
  800a88:	75 df                	jne    800a69 <memcmp+0x1d>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a8a:	b8 00 00 00 00       	mov    $0x0,%eax
  800a8f:	eb 05                	jmp    800a96 <memcmp+0x4a>
  800a91:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a96:	5b                   	pop    %ebx
  800a97:	5e                   	pop    %esi
  800a98:	5f                   	pop    %edi
  800a99:	c9                   	leave  
  800a9a:	c3                   	ret    

00800a9b <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a9b:	55                   	push   %ebp
  800a9c:	89 e5                	mov    %esp,%ebp
  800a9e:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800aa1:	89 c2                	mov    %eax,%edx
  800aa3:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800aa6:	39 d0                	cmp    %edx,%eax
  800aa8:	73 12                	jae    800abc <memfind+0x21>
		if (*(const unsigned char *) s == (unsigned char) c)
  800aaa:	8a 4d 0c             	mov    0xc(%ebp),%cl
  800aad:	38 08                	cmp    %cl,(%eax)
  800aaf:	75 06                	jne    800ab7 <memfind+0x1c>
  800ab1:	eb 09                	jmp    800abc <memfind+0x21>
  800ab3:	38 08                	cmp    %cl,(%eax)
  800ab5:	74 05                	je     800abc <memfind+0x21>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800ab7:	40                   	inc    %eax
  800ab8:	39 c2                	cmp    %eax,%edx
  800aba:	77 f7                	ja     800ab3 <memfind+0x18>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800abc:	c9                   	leave  
  800abd:	c3                   	ret    

00800abe <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800abe:	55                   	push   %ebp
  800abf:	89 e5                	mov    %esp,%ebp
  800ac1:	57                   	push   %edi
  800ac2:	56                   	push   %esi
  800ac3:	53                   	push   %ebx
  800ac4:	8b 55 08             	mov    0x8(%ebp),%edx
  800ac7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800aca:	eb 01                	jmp    800acd <strtol+0xf>
		s++;
  800acc:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800acd:	8a 02                	mov    (%edx),%al
  800acf:	3c 20                	cmp    $0x20,%al
  800ad1:	74 f9                	je     800acc <strtol+0xe>
  800ad3:	3c 09                	cmp    $0x9,%al
  800ad5:	74 f5                	je     800acc <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800ad7:	3c 2b                	cmp    $0x2b,%al
  800ad9:	75 08                	jne    800ae3 <strtol+0x25>
		s++;
  800adb:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800adc:	bf 00 00 00 00       	mov    $0x0,%edi
  800ae1:	eb 13                	jmp    800af6 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800ae3:	3c 2d                	cmp    $0x2d,%al
  800ae5:	75 0a                	jne    800af1 <strtol+0x33>
		s++, neg = 1;
  800ae7:	8d 52 01             	lea    0x1(%edx),%edx
  800aea:	bf 01 00 00 00       	mov    $0x1,%edi
  800aef:	eb 05                	jmp    800af6 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800af1:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800af6:	85 db                	test   %ebx,%ebx
  800af8:	74 05                	je     800aff <strtol+0x41>
  800afa:	83 fb 10             	cmp    $0x10,%ebx
  800afd:	75 28                	jne    800b27 <strtol+0x69>
  800aff:	8a 02                	mov    (%edx),%al
  800b01:	3c 30                	cmp    $0x30,%al
  800b03:	75 10                	jne    800b15 <strtol+0x57>
  800b05:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800b09:	75 0a                	jne    800b15 <strtol+0x57>
		s += 2, base = 16;
  800b0b:	83 c2 02             	add    $0x2,%edx
  800b0e:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b13:	eb 12                	jmp    800b27 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800b15:	85 db                	test   %ebx,%ebx
  800b17:	75 0e                	jne    800b27 <strtol+0x69>
  800b19:	3c 30                	cmp    $0x30,%al
  800b1b:	75 05                	jne    800b22 <strtol+0x64>
		s++, base = 8;
  800b1d:	42                   	inc    %edx
  800b1e:	b3 08                	mov    $0x8,%bl
  800b20:	eb 05                	jmp    800b27 <strtol+0x69>
	else if (base == 0)
		base = 10;
  800b22:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800b27:	b8 00 00 00 00       	mov    $0x0,%eax
  800b2c:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800b2e:	8a 0a                	mov    (%edx),%cl
  800b30:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800b33:	80 fb 09             	cmp    $0x9,%bl
  800b36:	77 08                	ja     800b40 <strtol+0x82>
			dig = *s - '0';
  800b38:	0f be c9             	movsbl %cl,%ecx
  800b3b:	83 e9 30             	sub    $0x30,%ecx
  800b3e:	eb 1e                	jmp    800b5e <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800b40:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800b43:	80 fb 19             	cmp    $0x19,%bl
  800b46:	77 08                	ja     800b50 <strtol+0x92>
			dig = *s - 'a' + 10;
  800b48:	0f be c9             	movsbl %cl,%ecx
  800b4b:	83 e9 57             	sub    $0x57,%ecx
  800b4e:	eb 0e                	jmp    800b5e <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800b50:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800b53:	80 fb 19             	cmp    $0x19,%bl
  800b56:	77 13                	ja     800b6b <strtol+0xad>
			dig = *s - 'A' + 10;
  800b58:	0f be c9             	movsbl %cl,%ecx
  800b5b:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800b5e:	39 f1                	cmp    %esi,%ecx
  800b60:	7d 0d                	jge    800b6f <strtol+0xb1>
			break;
		s++, val = (val * base) + dig;
  800b62:	42                   	inc    %edx
  800b63:	0f af c6             	imul   %esi,%eax
  800b66:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  800b69:	eb c3                	jmp    800b2e <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800b6b:	89 c1                	mov    %eax,%ecx
  800b6d:	eb 02                	jmp    800b71 <strtol+0xb3>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800b6f:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800b71:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b75:	74 05                	je     800b7c <strtol+0xbe>
		*endptr = (char *) s;
  800b77:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800b7a:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800b7c:	85 ff                	test   %edi,%edi
  800b7e:	74 04                	je     800b84 <strtol+0xc6>
  800b80:	89 c8                	mov    %ecx,%eax
  800b82:	f7 d8                	neg    %eax
}
  800b84:	5b                   	pop    %ebx
  800b85:	5e                   	pop    %esi
  800b86:	5f                   	pop    %edi
  800b87:	c9                   	leave  
  800b88:	c3                   	ret    
  800b89:	00 00                	add    %al,(%eax)
	...

00800b8c <syscall>:
	return ret;
}

static int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800b8c:	55                   	push   %ebp
  800b8d:	89 e5                	mov    %esp,%ebp
  800b8f:	57                   	push   %edi
  800b90:	56                   	push   %esi
  800b91:	53                   	push   %ebx
  800b92:	83 ec 1c             	sub    $0x1c,%esp
  800b95:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800b98:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800b9b:	89 ca                	mov    %ecx,%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b9d:	8b 75 14             	mov    0x14(%ebp),%esi
  800ba0:	8b 7d 10             	mov    0x10(%ebp),%edi
  800ba3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800ba6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ba9:	cd 30                	int    $0x30
  800bab:	89 c2                	mov    %eax,%edx
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800bad:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800bb1:	74 1c                	je     800bcf <syscall+0x43>
  800bb3:	85 c0                	test   %eax,%eax
  800bb5:	7e 18                	jle    800bcf <syscall+0x43>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bb7:	83 ec 0c             	sub    $0xc,%esp
  800bba:	50                   	push   %eax
  800bbb:	ff 75 e4             	pushl  -0x1c(%ebp)
  800bbe:	68 04 16 80 00       	push   $0x801604
  800bc3:	6a 42                	push   $0x42
  800bc5:	68 21 16 80 00       	push   $0x801621
  800bca:	e8 b1 f5 ff ff       	call   800180 <_panic>

	return ret;
}
  800bcf:	89 d0                	mov    %edx,%eax
  800bd1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bd4:	5b                   	pop    %ebx
  800bd5:	5e                   	pop    %esi
  800bd6:	5f                   	pop    %edi
  800bd7:	c9                   	leave  
  800bd8:	c3                   	ret    

00800bd9 <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{	
  800bd9:	55                   	push   %ebp
  800bda:	89 e5                	mov    %esp,%ebp
  800bdc:	83 ec 08             	sub    $0x8,%esp
	// my_sysenter(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
	// return;
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  800bdf:	6a 00                	push   $0x0
  800be1:	6a 00                	push   $0x0
  800be3:	6a 00                	push   $0x0
  800be5:	ff 75 0c             	pushl  0xc(%ebp)
  800be8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800beb:	ba 00 00 00 00       	mov    $0x0,%edx
  800bf0:	b8 00 00 00 00       	mov    $0x0,%eax
  800bf5:	e8 92 ff ff ff       	call   800b8c <syscall>
  800bfa:	83 c4 10             	add    $0x10,%esp
	return;
}
  800bfd:	c9                   	leave  
  800bfe:	c3                   	ret    

00800bff <sys_cgetc>:

int
sys_cgetc(void)
{
  800bff:	55                   	push   %ebp
  800c00:	89 e5                	mov    %esp,%ebp
  800c02:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_cgetc, 0, 0, 0, 0, 0, 0);
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  800c05:	6a 00                	push   $0x0
  800c07:	6a 00                	push   $0x0
  800c09:	6a 00                	push   $0x0
  800c0b:	6a 00                	push   $0x0
  800c0d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c12:	ba 00 00 00 00       	mov    $0x0,%edx
  800c17:	b8 01 00 00 00       	mov    $0x1,%eax
  800c1c:	e8 6b ff ff ff       	call   800b8c <syscall>
}
  800c21:	c9                   	leave  
  800c22:	c3                   	ret    

00800c23 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800c23:	55                   	push   %ebp
  800c24:	89 e5                	mov    %esp,%ebp
  800c26:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  800c29:	6a 00                	push   $0x0
  800c2b:	6a 00                	push   $0x0
  800c2d:	6a 00                	push   $0x0
  800c2f:	6a 00                	push   $0x0
  800c31:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c34:	ba 01 00 00 00       	mov    $0x1,%edx
  800c39:	b8 03 00 00 00       	mov    $0x3,%eax
  800c3e:	e8 49 ff ff ff       	call   800b8c <syscall>
}
  800c43:	c9                   	leave  
  800c44:	c3                   	ret    

00800c45 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c45:	55                   	push   %ebp
  800c46:	89 e5                	mov    %esp,%ebp
  800c48:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_getenvid, 0, 0, 0, 0, 0, 0);
	return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  800c4b:	6a 00                	push   $0x0
  800c4d:	6a 00                	push   $0x0
  800c4f:	6a 00                	push   $0x0
  800c51:	6a 00                	push   $0x0
  800c53:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c58:	ba 00 00 00 00       	mov    $0x0,%edx
  800c5d:	b8 02 00 00 00       	mov    $0x2,%eax
  800c62:	e8 25 ff ff ff       	call   800b8c <syscall>
}
  800c67:	c9                   	leave  
  800c68:	c3                   	ret    

00800c69 <sys_yield>:

void
sys_yield(void)
{
  800c69:	55                   	push   %ebp
  800c6a:	89 e5                	mov    %esp,%ebp
  800c6c:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  800c6f:	6a 00                	push   $0x0
  800c71:	6a 00                	push   $0x0
  800c73:	6a 00                	push   $0x0
  800c75:	6a 00                	push   $0x0
  800c77:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c7c:	ba 00 00 00 00       	mov    $0x0,%edx
  800c81:	b8 0a 00 00 00       	mov    $0xa,%eax
  800c86:	e8 01 ff ff ff       	call   800b8c <syscall>
  800c8b:	83 c4 10             	add    $0x10,%esp
}
  800c8e:	c9                   	leave  
  800c8f:	c3                   	ret    

00800c90 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c90:	55                   	push   %ebp
  800c91:	89 e5                	mov    %esp,%ebp
  800c93:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  800c96:	6a 00                	push   $0x0
  800c98:	6a 00                	push   $0x0
  800c9a:	ff 75 10             	pushl  0x10(%ebp)
  800c9d:	ff 75 0c             	pushl  0xc(%ebp)
  800ca0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ca3:	ba 01 00 00 00       	mov    $0x1,%edx
  800ca8:	b8 04 00 00 00       	mov    $0x4,%eax
  800cad:	e8 da fe ff ff       	call   800b8c <syscall>
}
  800cb2:	c9                   	leave  
  800cb3:	c3                   	ret    

00800cb4 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800cb4:	55                   	push   %ebp
  800cb5:	89 e5                	mov    %esp,%ebp
  800cb7:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
  800cba:	ff 75 18             	pushl  0x18(%ebp)
  800cbd:	ff 75 14             	pushl  0x14(%ebp)
  800cc0:	ff 75 10             	pushl  0x10(%ebp)
  800cc3:	ff 75 0c             	pushl  0xc(%ebp)
  800cc6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800cc9:	ba 01 00 00 00       	mov    $0x1,%edx
  800cce:	b8 05 00 00 00       	mov    $0x5,%eax
  800cd3:	e8 b4 fe ff ff       	call   800b8c <syscall>
}
  800cd8:	c9                   	leave  
  800cd9:	c3                   	ret    

00800cda <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800cda:	55                   	push   %ebp
  800cdb:	89 e5                	mov    %esp,%ebp
  800cdd:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  800ce0:	6a 00                	push   $0x0
  800ce2:	6a 00                	push   $0x0
  800ce4:	6a 00                	push   $0x0
  800ce6:	ff 75 0c             	pushl  0xc(%ebp)
  800ce9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800cec:	ba 01 00 00 00       	mov    $0x1,%edx
  800cf1:	b8 06 00 00 00       	mov    $0x6,%eax
  800cf6:	e8 91 fe ff ff       	call   800b8c <syscall>
}
  800cfb:	c9                   	leave  
  800cfc:	c3                   	ret    

00800cfd <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800cfd:	55                   	push   %ebp
  800cfe:	89 e5                	mov    %esp,%ebp
  800d00:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  800d03:	6a 00                	push   $0x0
  800d05:	6a 00                	push   $0x0
  800d07:	6a 00                	push   $0x0
  800d09:	ff 75 0c             	pushl  0xc(%ebp)
  800d0c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d0f:	ba 01 00 00 00       	mov    $0x1,%edx
  800d14:	b8 08 00 00 00       	mov    $0x8,%eax
  800d19:	e8 6e fe ff ff       	call   800b8c <syscall>
}
  800d1e:	c9                   	leave  
  800d1f:	c3                   	ret    

00800d20 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d20:	55                   	push   %ebp
  800d21:	89 e5                	mov    %esp,%ebp
  800d23:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  800d26:	6a 00                	push   $0x0
  800d28:	6a 00                	push   $0x0
  800d2a:	6a 00                	push   $0x0
  800d2c:	ff 75 0c             	pushl  0xc(%ebp)
  800d2f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d32:	ba 01 00 00 00       	mov    $0x1,%edx
  800d37:	b8 09 00 00 00       	mov    $0x9,%eax
  800d3c:	e8 4b fe ff ff       	call   800b8c <syscall>
}
  800d41:	c9                   	leave  
  800d42:	c3                   	ret    

00800d43 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d43:	55                   	push   %ebp
  800d44:	89 e5                	mov    %esp,%ebp
  800d46:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  800d49:	6a 00                	push   $0x0
  800d4b:	ff 75 14             	pushl  0x14(%ebp)
  800d4e:	ff 75 10             	pushl  0x10(%ebp)
  800d51:	ff 75 0c             	pushl  0xc(%ebp)
  800d54:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d57:	ba 00 00 00 00       	mov    $0x0,%edx
  800d5c:	b8 0b 00 00 00       	mov    $0xb,%eax
  800d61:	e8 26 fe ff ff       	call   800b8c <syscall>
}
  800d66:	c9                   	leave  
  800d67:	c3                   	ret    

00800d68 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d68:	55                   	push   %ebp
  800d69:	89 e5                	mov    %esp,%ebp
  800d6b:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  800d6e:	6a 00                	push   $0x0
  800d70:	6a 00                	push   $0x0
  800d72:	6a 00                	push   $0x0
  800d74:	6a 00                	push   $0x0
  800d76:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d79:	ba 01 00 00 00       	mov    $0x1,%edx
  800d7e:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d83:	e8 04 fe ff ff       	call   800b8c <syscall>
}
  800d88:	c9                   	leave  
  800d89:	c3                   	ret    
	...

00800d8c <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800d8c:	55                   	push   %ebp
  800d8d:	89 e5                	mov    %esp,%ebp
  800d8f:	53                   	push   %ebx
  800d90:	83 ec 04             	sub    $0x4,%esp
  800d93:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800d96:	8b 18                	mov    (%eax),%ebx

	// LAB 4: Your code here.
	
	// cprintf("PAGE FAULT HANDLER, 0x%08x %d\n", (uint32_t)addr, err & FEC_WR);
	
	if ((err & FEC_WR) == 0)
  800d98:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800d9c:	75 14                	jne    800db2 <pgfault+0x26>
		panic("pgfault, the fault is not a write\n");
  800d9e:	83 ec 04             	sub    $0x4,%esp
  800da1:	68 30 16 80 00       	push   $0x801630
  800da6:	6a 20                	push   $0x20
  800da8:	68 74 17 80 00       	push   $0x801774
  800dad:	e8 ce f3 ff ff       	call   800180 <_panic>

	uint32_t uaddr = (uint32_t) addr;
	if ((uvpd[PDX(addr)] & PTE_P) == 0 || (uvpt[uaddr / PGSIZE] & PTE_COW) == 0) {
  800db2:	89 d8                	mov    %ebx,%eax
  800db4:	c1 e8 16             	shr    $0x16,%eax
  800db7:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800dbe:	a8 01                	test   $0x1,%al
  800dc0:	74 11                	je     800dd3 <pgfault+0x47>
  800dc2:	89 d8                	mov    %ebx,%eax
  800dc4:	c1 e8 0c             	shr    $0xc,%eax
  800dc7:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800dce:	f6 c4 08             	test   $0x8,%ah
  800dd1:	75 14                	jne    800de7 <pgfault+0x5b>
		panic("pgfault, not a copy-on-write page\n");
  800dd3:	83 ec 04             	sub    $0x4,%esp
  800dd6:	68 54 16 80 00       	push   $0x801654
  800ddb:	6a 24                	push   $0x24
  800ddd:	68 74 17 80 00       	push   $0x801774
  800de2:	e8 99 f3 ff ff       	call   800180 <_panic>
	//   No need to explicitly delete the old page's mapping.

	// LAB 4: Your code here.

	// static int sys_page_alloc(envid_t envid, void *va, int perm)
	r = sys_page_alloc(0, (void *)PFTEMP, PTE_W | PTE_U | PTE_P);
  800de7:	83 ec 04             	sub    $0x4,%esp
  800dea:	6a 07                	push   $0x7
  800dec:	68 00 f0 7f 00       	push   $0x7ff000
  800df1:	6a 00                	push   $0x0
  800df3:	e8 98 fe ff ff       	call   800c90 <sys_page_alloc>
	if (r < 0) panic("pgfault, sys_page_alloc error : %e\n", r);
  800df8:	83 c4 10             	add    $0x10,%esp
  800dfb:	85 c0                	test   %eax,%eax
  800dfd:	79 12                	jns    800e11 <pgfault+0x85>
  800dff:	50                   	push   %eax
  800e00:	68 78 16 80 00       	push   $0x801678
  800e05:	6a 32                	push   $0x32
  800e07:	68 74 17 80 00       	push   $0x801774
  800e0c:	e8 6f f3 ff ff       	call   800180 <_panic>

	// Oh my god, I forget this at the first, it waste me a lot of time to debug!!!
	addr = ROUNDDOWN(addr, PGSIZE);
  800e11:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	
	memcpy(PFTEMP, addr, PGSIZE);
  800e17:	83 ec 04             	sub    $0x4,%esp
  800e1a:	68 00 10 00 00       	push   $0x1000
  800e1f:	53                   	push   %ebx
  800e20:	68 00 f0 7f 00       	push   $0x7ff000
  800e25:	e8 0f fc ff ff       	call   800a39 <memcpy>
	
	r = sys_page_map(0, PFTEMP, 0, addr, PTE_W | PTE_U | PTE_P);
  800e2a:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800e31:	53                   	push   %ebx
  800e32:	6a 00                	push   $0x0
  800e34:	68 00 f0 7f 00       	push   $0x7ff000
  800e39:	6a 00                	push   $0x0
  800e3b:	e8 74 fe ff ff       	call   800cb4 <sys_page_map>
	if (r < 0) panic("pgfault, sys_page_map error : %e\n", r);
  800e40:	83 c4 20             	add    $0x20,%esp
  800e43:	85 c0                	test   %eax,%eax
  800e45:	79 12                	jns    800e59 <pgfault+0xcd>
  800e47:	50                   	push   %eax
  800e48:	68 9c 16 80 00       	push   $0x80169c
  800e4d:	6a 3a                	push   $0x3a
  800e4f:	68 74 17 80 00       	push   $0x801774
  800e54:	e8 27 f3 ff ff       	call   800180 <_panic>

	return;
}
  800e59:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e5c:	c9                   	leave  
  800e5d:	c3                   	ret    

00800e5e <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800e5e:	55                   	push   %ebp
  800e5f:	89 e5                	mov    %esp,%ebp
  800e61:	57                   	push   %edi
  800e62:	56                   	push   %esi
  800e63:	53                   	push   %ebx
  800e64:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	set_pgfault_handler(pgfault);
  800e67:	68 8c 0d 80 00       	push   $0x800d8c
  800e6c:	e8 f3 01 00 00       	call   801064 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  800e71:	ba 07 00 00 00       	mov    $0x7,%edx
  800e76:	89 d0                	mov    %edx,%eax
  800e78:	cd 30                	int    $0x30
  800e7a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800e7d:	89 c7                	mov    %eax,%edi
	int childpid = sys_exofork();
	if (childpid < 0) {
  800e7f:	83 c4 10             	add    $0x10,%esp
  800e82:	85 c0                	test   %eax,%eax
  800e84:	79 12                	jns    800e98 <fork+0x3a>
		panic("fork sys_exofork error : %e\n", childpid);
  800e86:	50                   	push   %eax
  800e87:	68 7f 17 80 00       	push   $0x80177f
  800e8c:	6a 79                	push   $0x79
  800e8e:	68 74 17 80 00       	push   $0x801774
  800e93:	e8 e8 f2 ff ff       	call   800180 <_panic>
	}
	int r;

	if (childpid == 0) {
  800e98:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800e9c:	75 25                	jne    800ec3 <fork+0x65>
		// child process
		// Remember to fix "thisenv" in the child process. ??? 
		thisenv = &envs[ENVX(sys_getenvid())];
  800e9e:	e8 a2 fd ff ff       	call   800c45 <sys_getenvid>
  800ea3:	25 ff 03 00 00       	and    $0x3ff,%eax
  800ea8:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800eaf:	c1 e0 07             	shl    $0x7,%eax
  800eb2:	29 d0                	sub    %edx,%eax
  800eb4:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800eb9:	a3 08 20 80 00       	mov    %eax,0x802008
		// cprintf("fork child ok\n");
		return 0;
  800ebe:	e9 7b 01 00 00       	jmp    80103e <fork+0x1e0>
	if (childpid < 0) {
		panic("fork sys_exofork error : %e\n", childpid);
	}
	int r;

	if (childpid == 0) {
  800ec3:	bb 00 00 00 00       	mov    $0x0,%ebx
	} else {
		// map page to new environment
		// kernel page is already in new environment
		uint32_t i;
		for (i = 0; i != UTOP; i += PGSIZE) 
		if ((uvpd[PDX(i)] & PTE_P) && (uvpt[i / PGSIZE] & PTE_P) && (uvpt[i / PGSIZE] & PTE_U)) {
  800ec8:	89 d8                	mov    %ebx,%eax
  800eca:	c1 e8 16             	shr    $0x16,%eax
  800ecd:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800ed4:	a8 01                	test   $0x1,%al
  800ed6:	0f 84 cd 00 00 00    	je     800fa9 <fork+0x14b>
  800edc:	89 d8                	mov    %ebx,%eax
  800ede:	c1 e8 0c             	shr    $0xc,%eax
  800ee1:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800ee8:	f6 c2 01             	test   $0x1,%dl
  800eeb:	0f 84 b8 00 00 00    	je     800fa9 <fork+0x14b>
  800ef1:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800ef8:	f6 c2 04             	test   $0x4,%dl
  800efb:	0f 84 a8 00 00 00    	je     800fa9 <fork+0x14b>
//
static int
duppage(envid_t envid, unsigned pn)
{
	// do not dup exception stack
	if (pn * PGSIZE == UXSTACKTOP - PGSIZE) return 0;
  800f01:	89 c6                	mov    %eax,%esi
  800f03:	c1 e6 0c             	shl    $0xc,%esi
  800f06:	81 fe 00 f0 bf ee    	cmp    $0xeebff000,%esi
  800f0c:	0f 84 97 00 00 00    	je     800fa9 <fork+0x14b>

	int r;
	void * addr = (void *)(pn * PGSIZE);
	if ((uvpt[pn] & PTE_W) || (uvpt[pn] & PTE_COW)) {
  800f12:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800f19:	f6 c2 02             	test   $0x2,%dl
  800f1c:	75 0c                	jne    800f2a <fork+0xcc>
  800f1e:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f25:	f6 c4 08             	test   $0x8,%ah
  800f28:	74 57                	je     800f81 <fork+0x123>
		// cow
		r = sys_page_map(0, addr, envid, addr, PTE_COW | PTE_P | PTE_U);
  800f2a:	83 ec 0c             	sub    $0xc,%esp
  800f2d:	68 05 08 00 00       	push   $0x805
  800f32:	56                   	push   %esi
  800f33:	57                   	push   %edi
  800f34:	56                   	push   %esi
  800f35:	6a 00                	push   $0x0
  800f37:	e8 78 fd ff ff       	call   800cb4 <sys_page_map>
		if (r < 0) panic("duppage sys_page_map error : %e\n", r);
  800f3c:	83 c4 20             	add    $0x20,%esp
  800f3f:	85 c0                	test   %eax,%eax
  800f41:	79 12                	jns    800f55 <fork+0xf7>
  800f43:	50                   	push   %eax
  800f44:	68 c0 16 80 00       	push   $0x8016c0
  800f49:	6a 55                	push   $0x55
  800f4b:	68 74 17 80 00       	push   $0x801774
  800f50:	e8 2b f2 ff ff       	call   800180 <_panic>
		
		r = sys_page_map(0, addr, 0, addr, PTE_COW | PTE_P | PTE_U);
  800f55:	83 ec 0c             	sub    $0xc,%esp
  800f58:	68 05 08 00 00       	push   $0x805
  800f5d:	56                   	push   %esi
  800f5e:	6a 00                	push   $0x0
  800f60:	56                   	push   %esi
  800f61:	6a 00                	push   $0x0
  800f63:	e8 4c fd ff ff       	call   800cb4 <sys_page_map>
		if (r < 0) panic("duppage sys_page_map error : %e\n", r);
  800f68:	83 c4 20             	add    $0x20,%esp
  800f6b:	85 c0                	test   %eax,%eax
  800f6d:	79 3a                	jns    800fa9 <fork+0x14b>
  800f6f:	50                   	push   %eax
  800f70:	68 c0 16 80 00       	push   $0x8016c0
  800f75:	6a 58                	push   $0x58
  800f77:	68 74 17 80 00       	push   $0x801774
  800f7c:	e8 ff f1 ff ff       	call   800180 <_panic>
	} else {
		// read only
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U);
  800f81:	83 ec 0c             	sub    $0xc,%esp
  800f84:	6a 05                	push   $0x5
  800f86:	56                   	push   %esi
  800f87:	57                   	push   %edi
  800f88:	56                   	push   %esi
  800f89:	6a 00                	push   $0x0
  800f8b:	e8 24 fd ff ff       	call   800cb4 <sys_page_map>
		if (r < 0) panic("duppage sys_page_map error : %e\n", r);
  800f90:	83 c4 20             	add    $0x20,%esp
  800f93:	85 c0                	test   %eax,%eax
  800f95:	79 12                	jns    800fa9 <fork+0x14b>
  800f97:	50                   	push   %eax
  800f98:	68 c0 16 80 00       	push   $0x8016c0
  800f9d:	6a 5c                	push   $0x5c
  800f9f:	68 74 17 80 00       	push   $0x801774
  800fa4:	e8 d7 f1 ff ff       	call   800180 <_panic>
		return 0;
	} else {
		// map page to new environment
		// kernel page is already in new environment
		uint32_t i;
		for (i = 0; i != UTOP; i += PGSIZE) 
  800fa9:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  800faf:	81 fb 00 00 c0 ee    	cmp    $0xeec00000,%ebx
  800fb5:	0f 85 0d ff ff ff    	jne    800ec8 <fork+0x6a>
		if ((uvpd[PDX(i)] & PTE_P) && (uvpt[i / PGSIZE] & PTE_P) && (uvpt[i / PGSIZE] & PTE_U)) {
			duppage(childpid, i / PGSIZE);
		}

		// allocate exception stack
		r = sys_page_alloc(childpid, (void *)(UXSTACKTOP - PGSIZE), PTE_U | PTE_W | PTE_P);
  800fbb:	83 ec 04             	sub    $0x4,%esp
  800fbe:	6a 07                	push   $0x7
  800fc0:	68 00 f0 bf ee       	push   $0xeebff000
  800fc5:	ff 75 e4             	pushl  -0x1c(%ebp)
  800fc8:	e8 c3 fc ff ff       	call   800c90 <sys_page_alloc>
		if (r < 0) panic("fork, sys_page_alloc user exception stack error : %e\n", r);
  800fcd:	83 c4 10             	add    $0x10,%esp
  800fd0:	85 c0                	test   %eax,%eax
  800fd2:	79 15                	jns    800fe9 <fork+0x18b>
  800fd4:	50                   	push   %eax
  800fd5:	68 e4 16 80 00       	push   $0x8016e4
  800fda:	68 8e 00 00 00       	push   $0x8e
  800fdf:	68 74 17 80 00       	push   $0x801774
  800fe4:	e8 97 f1 ff ff       	call   800180 <_panic>

		// set user environment user page fault handler 
		extern void _pgfault_upcall(void);
		r = sys_env_set_pgfault_upcall(childpid, _pgfault_upcall);
  800fe9:	83 ec 08             	sub    $0x8,%esp
  800fec:	68 d0 10 80 00       	push   $0x8010d0
  800ff1:	ff 75 e4             	pushl  -0x1c(%ebp)
  800ff4:	e8 27 fd ff ff       	call   800d20 <sys_env_set_pgfault_upcall>
		if (r < 0) panic("fork, set pgfault upcall fail : %e\n", r);
  800ff9:	83 c4 10             	add    $0x10,%esp
  800ffc:	85 c0                	test   %eax,%eax
  800ffe:	79 15                	jns    801015 <fork+0x1b7>
  801000:	50                   	push   %eax
  801001:	68 1c 17 80 00       	push   $0x80171c
  801006:	68 93 00 00 00       	push   $0x93
  80100b:	68 74 17 80 00       	push   $0x801774
  801010:	e8 6b f1 ff ff       	call   800180 <_panic>

		// mark the child as runnable and return
		r = sys_env_set_status(childpid, ENV_RUNNABLE);
  801015:	83 ec 08             	sub    $0x8,%esp
  801018:	6a 02                	push   $0x2
  80101a:	ff 75 e4             	pushl  -0x1c(%ebp)
  80101d:	e8 db fc ff ff       	call   800cfd <sys_env_set_status>
		if (r < 0) panic("fork, set child process to ENV_RUNNABLE error : %e\n", r);
  801022:	83 c4 10             	add    $0x10,%esp
  801025:	85 c0                	test   %eax,%eax
  801027:	79 15                	jns    80103e <fork+0x1e0>
  801029:	50                   	push   %eax
  80102a:	68 40 17 80 00       	push   $0x801740
  80102f:	68 97 00 00 00       	push   $0x97
  801034:	68 74 17 80 00       	push   $0x801774
  801039:	e8 42 f1 ff ff       	call   800180 <_panic>
		// cprintf("fork father ok!");
		return childpid;
	}

	panic("fork not implemented");
}
  80103e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801041:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801044:	5b                   	pop    %ebx
  801045:	5e                   	pop    %esi
  801046:	5f                   	pop    %edi
  801047:	c9                   	leave  
  801048:	c3                   	ret    

00801049 <sfork>:

// Challenge!
int
sfork(void)
{
  801049:	55                   	push   %ebp
  80104a:	89 e5                	mov    %esp,%ebp
  80104c:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  80104f:	68 9c 17 80 00       	push   $0x80179c
  801054:	68 a4 00 00 00       	push   $0xa4
  801059:	68 74 17 80 00       	push   $0x801774
  80105e:	e8 1d f1 ff ff       	call   800180 <_panic>
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
  80107f:	e8 0c fc ff ff       	call   800c90 <sys_page_alloc>
		if (r < 0) {
  801084:	83 c4 10             	add    $0x10,%esp
  801087:	85 c0                	test   %eax,%eax
  801089:	79 12                	jns    80109d <set_pgfault_handler+0x39>
			panic("sys_page_alloc error : %e\n", r);
  80108b:	50                   	push   %eax
  80108c:	68 b2 17 80 00       	push   $0x8017b2
  801091:	6a 24                	push   $0x24
  801093:	68 cd 17 80 00       	push   $0x8017cd
  801098:	e8 e3 f0 ff ff       	call   800180 <_panic>
		}

		// how to know envid, put 0, envid2env will help us to get curenv in syscall
		r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);		
  80109d:	83 ec 08             	sub    $0x8,%esp
  8010a0:	68 d0 10 80 00       	push   $0x8010d0
  8010a5:	6a 00                	push   $0x0
  8010a7:	e8 74 fc ff ff       	call   800d20 <sys_env_set_pgfault_upcall>
		if (r < 0) {
  8010ac:	83 c4 10             	add    $0x10,%esp
  8010af:	85 c0                	test   %eax,%eax
  8010b1:	79 12                	jns    8010c5 <set_pgfault_handler+0x61>
			panic("sys_env_set_pgfault_upcall error : %e\n", r);
  8010b3:	50                   	push   %eax
  8010b4:	68 dc 17 80 00       	push   $0x8017dc
  8010b9:	6a 2a                	push   $0x2a
  8010bb:	68 cd 17 80 00       	push   $0x8017cd
  8010c0:	e8 bb f0 ff ff       	call   800180 <_panic>
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
