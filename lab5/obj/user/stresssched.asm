
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
  800039:	e8 0f 0c 00 00       	call   800c4d <sys_getenvid>
  80003e:	89 c6                	mov    %eax,%esi

	// Fork several environments
	for (i = 0; i < 20; i++)
  800040:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (fork() == 0)
  800045:	e8 88 0e 00 00       	call   800ed2 <fork>
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
  800082:	e8 ea 0b 00 00       	call   800c71 <sys_yield>
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
  8000ae:	e8 be 0b 00 00       	call   800c71 <sys_yield>
		for (j = 0; j < 10000; j++)
  8000b3:	b8 00 00 00 00       	mov    $0x0,%eax
			counter++;
  8000b8:	8b 15 04 40 80 00    	mov    0x804004,%edx
  8000be:	42                   	inc    %edx
  8000bf:	89 15 04 40 80 00    	mov    %edx,0x804004
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
  8000d3:	a1 04 40 80 00       	mov    0x804004,%eax
  8000d8:	3d a0 86 01 00       	cmp    $0x186a0,%eax
  8000dd:	74 17                	je     8000f6 <umain+0xc2>
		panic("ran on two CPUs at once (counter is %d)", counter);
  8000df:	a1 04 40 80 00       	mov    0x804004,%eax
  8000e4:	50                   	push   %eax
  8000e5:	68 20 22 80 00       	push   $0x802220
  8000ea:	6a 21                	push   $0x21
  8000ec:	68 48 22 80 00       	push   $0x802248
  8000f1:	e8 92 00 00 00       	call   800188 <_panic>

	// Check that we see environments running on different CPUs
	cprintf("[%08x] stresssched on CPU %d\n", thisenv->env_id, thisenv->env_cpunum);
  8000f6:	a1 08 40 80 00       	mov    0x804008,%eax
  8000fb:	8b 50 5c             	mov    0x5c(%eax),%edx
  8000fe:	8b 40 48             	mov    0x48(%eax),%eax
  800101:	83 ec 04             	sub    $0x4,%esp
  800104:	52                   	push   %edx
  800105:	50                   	push   %eax
  800106:	68 5b 22 80 00       	push   $0x80225b
  80010b:	e8 50 01 00 00       	call   800260 <cprintf>
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
  800127:	e8 21 0b 00 00       	call   800c4d <sys_getenvid>
  80012c:	25 ff 03 00 00       	and    $0x3ff,%eax
  800131:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800138:	c1 e0 07             	shl    $0x7,%eax
  80013b:	29 d0                	sub    %edx,%eax
  80013d:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800142:	a3 08 40 80 00       	mov    %eax,0x804008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800147:	85 f6                	test   %esi,%esi
  800149:	7e 07                	jle    800152 <libmain+0x36>
		binaryname = argv[0];
  80014b:	8b 03                	mov    (%ebx),%eax
  80014d:	a3 00 30 80 00       	mov    %eax,0x803000
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
  80016f:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800172:	e8 af 11 00 00       	call   801326 <close_all>
	sys_env_destroy(0);
  800177:	83 ec 0c             	sub    $0xc,%esp
  80017a:	6a 00                	push   $0x0
  80017c:	e8 aa 0a 00 00       	call   800c2b <sys_env_destroy>
  800181:	83 c4 10             	add    $0x10,%esp
}
  800184:	c9                   	leave  
  800185:	c3                   	ret    
	...

00800188 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800188:	55                   	push   %ebp
  800189:	89 e5                	mov    %esp,%ebp
  80018b:	56                   	push   %esi
  80018c:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80018d:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800190:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  800196:	e8 b2 0a 00 00       	call   800c4d <sys_getenvid>
  80019b:	83 ec 0c             	sub    $0xc,%esp
  80019e:	ff 75 0c             	pushl  0xc(%ebp)
  8001a1:	ff 75 08             	pushl  0x8(%ebp)
  8001a4:	53                   	push   %ebx
  8001a5:	50                   	push   %eax
  8001a6:	68 84 22 80 00       	push   $0x802284
  8001ab:	e8 b0 00 00 00       	call   800260 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8001b0:	83 c4 18             	add    $0x18,%esp
  8001b3:	56                   	push   %esi
  8001b4:	ff 75 10             	pushl  0x10(%ebp)
  8001b7:	e8 53 00 00 00       	call   80020f <vcprintf>
	cprintf("\n");
  8001bc:	c7 04 24 77 22 80 00 	movl   $0x802277,(%esp)
  8001c3:	e8 98 00 00 00       	call   800260 <cprintf>
  8001c8:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8001cb:	cc                   	int3   
  8001cc:	eb fd                	jmp    8001cb <_panic+0x43>
	...

008001d0 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001d0:	55                   	push   %ebp
  8001d1:	89 e5                	mov    %esp,%ebp
  8001d3:	53                   	push   %ebx
  8001d4:	83 ec 04             	sub    $0x4,%esp
  8001d7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001da:	8b 03                	mov    (%ebx),%eax
  8001dc:	8b 55 08             	mov    0x8(%ebp),%edx
  8001df:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8001e3:	40                   	inc    %eax
  8001e4:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8001e6:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001eb:	75 1a                	jne    800207 <putch+0x37>
		sys_cputs(b->buf, b->idx);
  8001ed:	83 ec 08             	sub    $0x8,%esp
  8001f0:	68 ff 00 00 00       	push   $0xff
  8001f5:	8d 43 08             	lea    0x8(%ebx),%eax
  8001f8:	50                   	push   %eax
  8001f9:	e8 e3 09 00 00       	call   800be1 <sys_cputs>
		b->idx = 0;
  8001fe:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800204:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800207:	ff 43 04             	incl   0x4(%ebx)
}
  80020a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80020d:	c9                   	leave  
  80020e:	c3                   	ret    

0080020f <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80020f:	55                   	push   %ebp
  800210:	89 e5                	mov    %esp,%ebp
  800212:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800218:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80021f:	00 00 00 
	b.cnt = 0;
  800222:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800229:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80022c:	ff 75 0c             	pushl  0xc(%ebp)
  80022f:	ff 75 08             	pushl  0x8(%ebp)
  800232:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800238:	50                   	push   %eax
  800239:	68 d0 01 80 00       	push   $0x8001d0
  80023e:	e8 82 01 00 00       	call   8003c5 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800243:	83 c4 08             	add    $0x8,%esp
  800246:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80024c:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800252:	50                   	push   %eax
  800253:	e8 89 09 00 00       	call   800be1 <sys_cputs>

	return b.cnt;
}
  800258:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80025e:	c9                   	leave  
  80025f:	c3                   	ret    

00800260 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800260:	55                   	push   %ebp
  800261:	89 e5                	mov    %esp,%ebp
  800263:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800266:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800269:	50                   	push   %eax
  80026a:	ff 75 08             	pushl  0x8(%ebp)
  80026d:	e8 9d ff ff ff       	call   80020f <vcprintf>
	va_end(ap);

	return cnt;
}
  800272:	c9                   	leave  
  800273:	c3                   	ret    

00800274 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800274:	55                   	push   %ebp
  800275:	89 e5                	mov    %esp,%ebp
  800277:	57                   	push   %edi
  800278:	56                   	push   %esi
  800279:	53                   	push   %ebx
  80027a:	83 ec 2c             	sub    $0x2c,%esp
  80027d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800280:	89 d6                	mov    %edx,%esi
  800282:	8b 45 08             	mov    0x8(%ebp),%eax
  800285:	8b 55 0c             	mov    0xc(%ebp),%edx
  800288:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80028b:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80028e:	8b 45 10             	mov    0x10(%ebp),%eax
  800291:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800294:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800297:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80029a:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  8002a1:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
  8002a4:	72 0c                	jb     8002b2 <printnum+0x3e>
  8002a6:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  8002a9:	76 07                	jbe    8002b2 <printnum+0x3e>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002ab:	4b                   	dec    %ebx
  8002ac:	85 db                	test   %ebx,%ebx
  8002ae:	7f 31                	jg     8002e1 <printnum+0x6d>
  8002b0:	eb 3f                	jmp    8002f1 <printnum+0x7d>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002b2:	83 ec 0c             	sub    $0xc,%esp
  8002b5:	57                   	push   %edi
  8002b6:	4b                   	dec    %ebx
  8002b7:	53                   	push   %ebx
  8002b8:	50                   	push   %eax
  8002b9:	83 ec 08             	sub    $0x8,%esp
  8002bc:	ff 75 d4             	pushl  -0x2c(%ebp)
  8002bf:	ff 75 d0             	pushl  -0x30(%ebp)
  8002c2:	ff 75 dc             	pushl  -0x24(%ebp)
  8002c5:	ff 75 d8             	pushl  -0x28(%ebp)
  8002c8:	e8 03 1d 00 00       	call   801fd0 <__udivdi3>
  8002cd:	83 c4 18             	add    $0x18,%esp
  8002d0:	52                   	push   %edx
  8002d1:	50                   	push   %eax
  8002d2:	89 f2                	mov    %esi,%edx
  8002d4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8002d7:	e8 98 ff ff ff       	call   800274 <printnum>
  8002dc:	83 c4 20             	add    $0x20,%esp
  8002df:	eb 10                	jmp    8002f1 <printnum+0x7d>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002e1:	83 ec 08             	sub    $0x8,%esp
  8002e4:	56                   	push   %esi
  8002e5:	57                   	push   %edi
  8002e6:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002e9:	4b                   	dec    %ebx
  8002ea:	83 c4 10             	add    $0x10,%esp
  8002ed:	85 db                	test   %ebx,%ebx
  8002ef:	7f f0                	jg     8002e1 <printnum+0x6d>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002f1:	83 ec 08             	sub    $0x8,%esp
  8002f4:	56                   	push   %esi
  8002f5:	83 ec 04             	sub    $0x4,%esp
  8002f8:	ff 75 d4             	pushl  -0x2c(%ebp)
  8002fb:	ff 75 d0             	pushl  -0x30(%ebp)
  8002fe:	ff 75 dc             	pushl  -0x24(%ebp)
  800301:	ff 75 d8             	pushl  -0x28(%ebp)
  800304:	e8 e3 1d 00 00       	call   8020ec <__umoddi3>
  800309:	83 c4 14             	add    $0x14,%esp
  80030c:	0f be 80 a7 22 80 00 	movsbl 0x8022a7(%eax),%eax
  800313:	50                   	push   %eax
  800314:	ff 55 e4             	call   *-0x1c(%ebp)
  800317:	83 c4 10             	add    $0x10,%esp
}
  80031a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80031d:	5b                   	pop    %ebx
  80031e:	5e                   	pop    %esi
  80031f:	5f                   	pop    %edi
  800320:	c9                   	leave  
  800321:	c3                   	ret    

00800322 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800322:	55                   	push   %ebp
  800323:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800325:	83 fa 01             	cmp    $0x1,%edx
  800328:	7e 0e                	jle    800338 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80032a:	8b 10                	mov    (%eax),%edx
  80032c:	8d 4a 08             	lea    0x8(%edx),%ecx
  80032f:	89 08                	mov    %ecx,(%eax)
  800331:	8b 02                	mov    (%edx),%eax
  800333:	8b 52 04             	mov    0x4(%edx),%edx
  800336:	eb 22                	jmp    80035a <getuint+0x38>
	else if (lflag)
  800338:	85 d2                	test   %edx,%edx
  80033a:	74 10                	je     80034c <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80033c:	8b 10                	mov    (%eax),%edx
  80033e:	8d 4a 04             	lea    0x4(%edx),%ecx
  800341:	89 08                	mov    %ecx,(%eax)
  800343:	8b 02                	mov    (%edx),%eax
  800345:	ba 00 00 00 00       	mov    $0x0,%edx
  80034a:	eb 0e                	jmp    80035a <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80034c:	8b 10                	mov    (%eax),%edx
  80034e:	8d 4a 04             	lea    0x4(%edx),%ecx
  800351:	89 08                	mov    %ecx,(%eax)
  800353:	8b 02                	mov    (%edx),%eax
  800355:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80035a:	c9                   	leave  
  80035b:	c3                   	ret    

0080035c <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  80035c:	55                   	push   %ebp
  80035d:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80035f:	83 fa 01             	cmp    $0x1,%edx
  800362:	7e 0e                	jle    800372 <getint+0x16>
		return va_arg(*ap, long long);
  800364:	8b 10                	mov    (%eax),%edx
  800366:	8d 4a 08             	lea    0x8(%edx),%ecx
  800369:	89 08                	mov    %ecx,(%eax)
  80036b:	8b 02                	mov    (%edx),%eax
  80036d:	8b 52 04             	mov    0x4(%edx),%edx
  800370:	eb 1a                	jmp    80038c <getint+0x30>
	else if (lflag)
  800372:	85 d2                	test   %edx,%edx
  800374:	74 0c                	je     800382 <getint+0x26>
		return va_arg(*ap, long);
  800376:	8b 10                	mov    (%eax),%edx
  800378:	8d 4a 04             	lea    0x4(%edx),%ecx
  80037b:	89 08                	mov    %ecx,(%eax)
  80037d:	8b 02                	mov    (%edx),%eax
  80037f:	99                   	cltd   
  800380:	eb 0a                	jmp    80038c <getint+0x30>
	else
		return va_arg(*ap, int);
  800382:	8b 10                	mov    (%eax),%edx
  800384:	8d 4a 04             	lea    0x4(%edx),%ecx
  800387:	89 08                	mov    %ecx,(%eax)
  800389:	8b 02                	mov    (%edx),%eax
  80038b:	99                   	cltd   
}
  80038c:	c9                   	leave  
  80038d:	c3                   	ret    

0080038e <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80038e:	55                   	push   %ebp
  80038f:	89 e5                	mov    %esp,%ebp
  800391:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800394:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  800397:	8b 10                	mov    (%eax),%edx
  800399:	3b 50 04             	cmp    0x4(%eax),%edx
  80039c:	73 08                	jae    8003a6 <sprintputch+0x18>
		*b->buf++ = ch;
  80039e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8003a1:	88 0a                	mov    %cl,(%edx)
  8003a3:	42                   	inc    %edx
  8003a4:	89 10                	mov    %edx,(%eax)
}
  8003a6:	c9                   	leave  
  8003a7:	c3                   	ret    

008003a8 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8003a8:	55                   	push   %ebp
  8003a9:	89 e5                	mov    %esp,%ebp
  8003ab:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8003ae:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8003b1:	50                   	push   %eax
  8003b2:	ff 75 10             	pushl  0x10(%ebp)
  8003b5:	ff 75 0c             	pushl  0xc(%ebp)
  8003b8:	ff 75 08             	pushl  0x8(%ebp)
  8003bb:	e8 05 00 00 00       	call   8003c5 <vprintfmt>
	va_end(ap);
  8003c0:	83 c4 10             	add    $0x10,%esp
}
  8003c3:	c9                   	leave  
  8003c4:	c3                   	ret    

008003c5 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8003c5:	55                   	push   %ebp
  8003c6:	89 e5                	mov    %esp,%ebp
  8003c8:	57                   	push   %edi
  8003c9:	56                   	push   %esi
  8003ca:	53                   	push   %ebx
  8003cb:	83 ec 2c             	sub    $0x2c,%esp
  8003ce:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8003d1:	8b 75 10             	mov    0x10(%ebp),%esi
  8003d4:	eb 13                	jmp    8003e9 <vprintfmt+0x24>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8003d6:	85 c0                	test   %eax,%eax
  8003d8:	0f 84 6d 03 00 00    	je     80074b <vprintfmt+0x386>
				return;
			putch(ch, putdat);
  8003de:	83 ec 08             	sub    $0x8,%esp
  8003e1:	57                   	push   %edi
  8003e2:	50                   	push   %eax
  8003e3:	ff 55 08             	call   *0x8(%ebp)
  8003e6:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8003e9:	0f b6 06             	movzbl (%esi),%eax
  8003ec:	46                   	inc    %esi
  8003ed:	83 f8 25             	cmp    $0x25,%eax
  8003f0:	75 e4                	jne    8003d6 <vprintfmt+0x11>
  8003f2:	c6 45 dc 20          	movb   $0x20,-0x24(%ebp)
  8003f6:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  8003fd:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  800404:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  80040b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800410:	eb 28                	jmp    80043a <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800412:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800414:	c6 45 dc 2d          	movb   $0x2d,-0x24(%ebp)
  800418:	eb 20                	jmp    80043a <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80041a:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80041c:	c6 45 dc 30          	movb   $0x30,-0x24(%ebp)
  800420:	eb 18                	jmp    80043a <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800422:	89 de                	mov    %ebx,%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800424:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  80042b:	eb 0d                	jmp    80043a <vprintfmt+0x75>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  80042d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800430:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800433:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80043a:	8a 06                	mov    (%esi),%al
  80043c:	0f b6 d0             	movzbl %al,%edx
  80043f:	8d 5e 01             	lea    0x1(%esi),%ebx
  800442:	83 e8 23             	sub    $0x23,%eax
  800445:	3c 55                	cmp    $0x55,%al
  800447:	0f 87 e0 02 00 00    	ja     80072d <vprintfmt+0x368>
  80044d:	0f b6 c0             	movzbl %al,%eax
  800450:	ff 24 85 e0 23 80 00 	jmp    *0x8023e0(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800457:	83 ea 30             	sub    $0x30,%edx
  80045a:	89 55 d4             	mov    %edx,-0x2c(%ebp)
				ch = *fmt;
  80045d:	0f be 03             	movsbl (%ebx),%eax
				if (ch < '0' || ch > '9')
  800460:	8d 50 d0             	lea    -0x30(%eax),%edx
  800463:	83 fa 09             	cmp    $0x9,%edx
  800466:	77 44                	ja     8004ac <vprintfmt+0xe7>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800468:	89 de                	mov    %ebx,%esi
  80046a:	8b 55 d4             	mov    -0x2c(%ebp),%edx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80046d:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
  80046e:	8d 14 92             	lea    (%edx,%edx,4),%edx
  800471:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
  800475:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800478:	8d 58 d0             	lea    -0x30(%eax),%ebx
  80047b:	83 fb 09             	cmp    $0x9,%ebx
  80047e:	76 ed                	jbe    80046d <vprintfmt+0xa8>
  800480:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  800483:	eb 29                	jmp    8004ae <vprintfmt+0xe9>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800485:	8b 45 14             	mov    0x14(%ebp),%eax
  800488:	8d 50 04             	lea    0x4(%eax),%edx
  80048b:	89 55 14             	mov    %edx,0x14(%ebp)
  80048e:	8b 00                	mov    (%eax),%eax
  800490:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800493:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800495:	eb 17                	jmp    8004ae <vprintfmt+0xe9>

		case '.':
			if (width < 0)
  800497:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80049b:	78 85                	js     800422 <vprintfmt+0x5d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80049d:	89 de                	mov    %ebx,%esi
  80049f:	eb 99                	jmp    80043a <vprintfmt+0x75>
  8004a1:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8004a3:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  8004aa:	eb 8e                	jmp    80043a <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004ac:	89 de                	mov    %ebx,%esi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  8004ae:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8004b2:	79 86                	jns    80043a <vprintfmt+0x75>
  8004b4:	e9 74 ff ff ff       	jmp    80042d <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8004b9:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004ba:	89 de                	mov    %ebx,%esi
  8004bc:	e9 79 ff ff ff       	jmp    80043a <vprintfmt+0x75>
  8004c1:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8004c4:	8b 45 14             	mov    0x14(%ebp),%eax
  8004c7:	8d 50 04             	lea    0x4(%eax),%edx
  8004ca:	89 55 14             	mov    %edx,0x14(%ebp)
  8004cd:	83 ec 08             	sub    $0x8,%esp
  8004d0:	57                   	push   %edi
  8004d1:	ff 30                	pushl  (%eax)
  8004d3:	ff 55 08             	call   *0x8(%ebp)
			break;
  8004d6:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004d9:	8b 75 d8             	mov    -0x28(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8004dc:	e9 08 ff ff ff       	jmp    8003e9 <vprintfmt+0x24>
  8004e1:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  8004e4:	8b 45 14             	mov    0x14(%ebp),%eax
  8004e7:	8d 50 04             	lea    0x4(%eax),%edx
  8004ea:	89 55 14             	mov    %edx,0x14(%ebp)
  8004ed:	8b 00                	mov    (%eax),%eax
  8004ef:	85 c0                	test   %eax,%eax
  8004f1:	79 02                	jns    8004f5 <vprintfmt+0x130>
  8004f3:	f7 d8                	neg    %eax
  8004f5:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004f7:	83 f8 0f             	cmp    $0xf,%eax
  8004fa:	7f 0b                	jg     800507 <vprintfmt+0x142>
  8004fc:	8b 04 85 40 25 80 00 	mov    0x802540(,%eax,4),%eax
  800503:	85 c0                	test   %eax,%eax
  800505:	75 1a                	jne    800521 <vprintfmt+0x15c>
				printfmt(putch, putdat, "error %d", err);
  800507:	52                   	push   %edx
  800508:	68 bf 22 80 00       	push   $0x8022bf
  80050d:	57                   	push   %edi
  80050e:	ff 75 08             	pushl  0x8(%ebp)
  800511:	e8 92 fe ff ff       	call   8003a8 <printfmt>
  800516:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800519:	8b 75 d8             	mov    -0x28(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80051c:	e9 c8 fe ff ff       	jmp    8003e9 <vprintfmt+0x24>
			else
				printfmt(putch, putdat, "%s", p);
  800521:	50                   	push   %eax
  800522:	68 f5 27 80 00       	push   $0x8027f5
  800527:	57                   	push   %edi
  800528:	ff 75 08             	pushl  0x8(%ebp)
  80052b:	e8 78 fe ff ff       	call   8003a8 <printfmt>
  800530:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800533:	8b 75 d8             	mov    -0x28(%ebp),%esi
  800536:	e9 ae fe ff ff       	jmp    8003e9 <vprintfmt+0x24>
  80053b:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  80053e:	89 de                	mov    %ebx,%esi
  800540:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  800543:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800546:	8b 45 14             	mov    0x14(%ebp),%eax
  800549:	8d 50 04             	lea    0x4(%eax),%edx
  80054c:	89 55 14             	mov    %edx,0x14(%ebp)
  80054f:	8b 00                	mov    (%eax),%eax
  800551:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800554:	85 c0                	test   %eax,%eax
  800556:	75 07                	jne    80055f <vprintfmt+0x19a>
				p = "(null)";
  800558:	c7 45 d0 b8 22 80 00 	movl   $0x8022b8,-0x30(%ebp)
			if (width > 0 && padc != '-')
  80055f:	85 db                	test   %ebx,%ebx
  800561:	7e 42                	jle    8005a5 <vprintfmt+0x1e0>
  800563:	80 7d dc 2d          	cmpb   $0x2d,-0x24(%ebp)
  800567:	74 3c                	je     8005a5 <vprintfmt+0x1e0>
				for (width -= strnlen(p, precision); width > 0; width--)
  800569:	83 ec 08             	sub    $0x8,%esp
  80056c:	51                   	push   %ecx
  80056d:	ff 75 d0             	pushl  -0x30(%ebp)
  800570:	e8 6f 02 00 00       	call   8007e4 <strnlen>
  800575:	29 c3                	sub    %eax,%ebx
  800577:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80057a:	83 c4 10             	add    $0x10,%esp
  80057d:	85 db                	test   %ebx,%ebx
  80057f:	7e 24                	jle    8005a5 <vprintfmt+0x1e0>
					putch(padc, putdat);
  800581:	0f be 5d dc          	movsbl -0x24(%ebp),%ebx
  800585:	89 75 dc             	mov    %esi,-0x24(%ebp)
  800588:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  80058b:	83 ec 08             	sub    $0x8,%esp
  80058e:	57                   	push   %edi
  80058f:	53                   	push   %ebx
  800590:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800593:	4e                   	dec    %esi
  800594:	83 c4 10             	add    $0x10,%esp
  800597:	85 f6                	test   %esi,%esi
  800599:	7f f0                	jg     80058b <vprintfmt+0x1c6>
  80059b:	8b 75 dc             	mov    -0x24(%ebp),%esi
  80059e:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005a5:	8b 55 d0             	mov    -0x30(%ebp),%edx
  8005a8:	0f be 02             	movsbl (%edx),%eax
  8005ab:	85 c0                	test   %eax,%eax
  8005ad:	75 47                	jne    8005f6 <vprintfmt+0x231>
  8005af:	eb 37                	jmp    8005e8 <vprintfmt+0x223>
				if (altflag && (ch < ' ' || ch > '~'))
  8005b1:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8005b5:	74 16                	je     8005cd <vprintfmt+0x208>
  8005b7:	8d 50 e0             	lea    -0x20(%eax),%edx
  8005ba:	83 fa 5e             	cmp    $0x5e,%edx
  8005bd:	76 0e                	jbe    8005cd <vprintfmt+0x208>
					putch('?', putdat);
  8005bf:	83 ec 08             	sub    $0x8,%esp
  8005c2:	57                   	push   %edi
  8005c3:	6a 3f                	push   $0x3f
  8005c5:	ff 55 08             	call   *0x8(%ebp)
  8005c8:	83 c4 10             	add    $0x10,%esp
  8005cb:	eb 0b                	jmp    8005d8 <vprintfmt+0x213>
				else
					putch(ch, putdat);
  8005cd:	83 ec 08             	sub    $0x8,%esp
  8005d0:	57                   	push   %edi
  8005d1:	50                   	push   %eax
  8005d2:	ff 55 08             	call   *0x8(%ebp)
  8005d5:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005d8:	ff 4d e4             	decl   -0x1c(%ebp)
  8005db:	0f be 03             	movsbl (%ebx),%eax
  8005de:	85 c0                	test   %eax,%eax
  8005e0:	74 03                	je     8005e5 <vprintfmt+0x220>
  8005e2:	43                   	inc    %ebx
  8005e3:	eb 1b                	jmp    800600 <vprintfmt+0x23b>
  8005e5:	8b 75 dc             	mov    -0x24(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005e8:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8005ec:	7f 1e                	jg     80060c <vprintfmt+0x247>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005ee:	8b 75 d8             	mov    -0x28(%ebp),%esi
  8005f1:	e9 f3 fd ff ff       	jmp    8003e9 <vprintfmt+0x24>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005f6:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  8005f9:	43                   	inc    %ebx
  8005fa:	89 75 dc             	mov    %esi,-0x24(%ebp)
  8005fd:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  800600:	85 f6                	test   %esi,%esi
  800602:	78 ad                	js     8005b1 <vprintfmt+0x1ec>
  800604:	4e                   	dec    %esi
  800605:	79 aa                	jns    8005b1 <vprintfmt+0x1ec>
  800607:	8b 75 dc             	mov    -0x24(%ebp),%esi
  80060a:	eb dc                	jmp    8005e8 <vprintfmt+0x223>
  80060c:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80060f:	83 ec 08             	sub    $0x8,%esp
  800612:	57                   	push   %edi
  800613:	6a 20                	push   $0x20
  800615:	ff 55 08             	call   *0x8(%ebp)
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800618:	4b                   	dec    %ebx
  800619:	83 c4 10             	add    $0x10,%esp
  80061c:	85 db                	test   %ebx,%ebx
  80061e:	7f ef                	jg     80060f <vprintfmt+0x24a>
  800620:	e9 c4 fd ff ff       	jmp    8003e9 <vprintfmt+0x24>
  800625:	89 5d d8             	mov    %ebx,-0x28(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800628:	89 ca                	mov    %ecx,%edx
  80062a:	8d 45 14             	lea    0x14(%ebp),%eax
  80062d:	e8 2a fd ff ff       	call   80035c <getint>
  800632:	89 c3                	mov    %eax,%ebx
  800634:	89 d6                	mov    %edx,%esi
			if ((long long) num < 0) {
  800636:	85 d2                	test   %edx,%edx
  800638:	78 0a                	js     800644 <vprintfmt+0x27f>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80063a:	b8 0a 00 00 00       	mov    $0xa,%eax
  80063f:	e9 b0 00 00 00       	jmp    8006f4 <vprintfmt+0x32f>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  800644:	83 ec 08             	sub    $0x8,%esp
  800647:	57                   	push   %edi
  800648:	6a 2d                	push   $0x2d
  80064a:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  80064d:	f7 db                	neg    %ebx
  80064f:	83 d6 00             	adc    $0x0,%esi
  800652:	f7 de                	neg    %esi
  800654:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800657:	b8 0a 00 00 00       	mov    $0xa,%eax
  80065c:	e9 93 00 00 00       	jmp    8006f4 <vprintfmt+0x32f>
  800661:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800664:	89 ca                	mov    %ecx,%edx
  800666:	8d 45 14             	lea    0x14(%ebp),%eax
  800669:	e8 b4 fc ff ff       	call   800322 <getuint>
  80066e:	89 c3                	mov    %eax,%ebx
  800670:	89 d6                	mov    %edx,%esi
			base = 10;
  800672:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  800677:	eb 7b                	jmp    8006f4 <vprintfmt+0x32f>
  800679:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
  80067c:	89 ca                	mov    %ecx,%edx
  80067e:	8d 45 14             	lea    0x14(%ebp),%eax
  800681:	e8 d6 fc ff ff       	call   80035c <getint>
  800686:	89 c3                	mov    %eax,%ebx
  800688:	89 d6                	mov    %edx,%esi
            if ((long long) num < 0) {
  80068a:	85 d2                	test   %edx,%edx
  80068c:	78 07                	js     800695 <vprintfmt+0x2d0>
                putch('-', putdat);
                num = -(long long) num;
            }
            base = 8;
  80068e:	b8 08 00 00 00       	mov    $0x8,%eax
  800693:	eb 5f                	jmp    8006f4 <vprintfmt+0x32f>
		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
            if ((long long) num < 0) {
                putch('-', putdat);
  800695:	83 ec 08             	sub    $0x8,%esp
  800698:	57                   	push   %edi
  800699:	6a 2d                	push   $0x2d
  80069b:	ff 55 08             	call   *0x8(%ebp)
                num = -(long long) num;
  80069e:	f7 db                	neg    %ebx
  8006a0:	83 d6 00             	adc    $0x0,%esi
  8006a3:	f7 de                	neg    %esi
  8006a5:	83 c4 10             	add    $0x10,%esp
            }
            base = 8;
  8006a8:	b8 08 00 00 00       	mov    $0x8,%eax
  8006ad:	eb 45                	jmp    8006f4 <vprintfmt+0x32f>
  8006af:	89 5d d8             	mov    %ebx,-0x28(%ebp)
            goto number;

        // pointer
		case 'p':
			putch('0', putdat);
  8006b2:	83 ec 08             	sub    $0x8,%esp
  8006b5:	57                   	push   %edi
  8006b6:	6a 30                	push   $0x30
  8006b8:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8006bb:	83 c4 08             	add    $0x8,%esp
  8006be:	57                   	push   %edi
  8006bf:	6a 78                	push   $0x78
  8006c1:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8006c4:	8b 45 14             	mov    0x14(%ebp),%eax
  8006c7:	8d 50 04             	lea    0x4(%eax),%edx
  8006ca:	89 55 14             	mov    %edx,0x14(%ebp)

        // pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8006cd:	8b 18                	mov    (%eax),%ebx
  8006cf:	be 00 00 00 00       	mov    $0x0,%esi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8006d4:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8006d7:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8006dc:	eb 16                	jmp    8006f4 <vprintfmt+0x32f>
  8006de:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8006e1:	89 ca                	mov    %ecx,%edx
  8006e3:	8d 45 14             	lea    0x14(%ebp),%eax
  8006e6:	e8 37 fc ff ff       	call   800322 <getuint>
  8006eb:	89 c3                	mov    %eax,%ebx
  8006ed:	89 d6                	mov    %edx,%esi
			base = 16;
  8006ef:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006f4:	83 ec 0c             	sub    $0xc,%esp
  8006f7:	0f be 55 dc          	movsbl -0x24(%ebp),%edx
  8006fb:	52                   	push   %edx
  8006fc:	ff 75 e4             	pushl  -0x1c(%ebp)
  8006ff:	50                   	push   %eax
  800700:	56                   	push   %esi
  800701:	53                   	push   %ebx
  800702:	89 fa                	mov    %edi,%edx
  800704:	8b 45 08             	mov    0x8(%ebp),%eax
  800707:	e8 68 fb ff ff       	call   800274 <printnum>
			break;
  80070c:	83 c4 20             	add    $0x20,%esp
  80070f:	8b 75 d8             	mov    -0x28(%ebp),%esi
  800712:	e9 d2 fc ff ff       	jmp    8003e9 <vprintfmt+0x24>
  800717:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80071a:	83 ec 08             	sub    $0x8,%esp
  80071d:	57                   	push   %edi
  80071e:	52                   	push   %edx
  80071f:	ff 55 08             	call   *0x8(%ebp)
			break;
  800722:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800725:	8b 75 d8             	mov    -0x28(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800728:	e9 bc fc ff ff       	jmp    8003e9 <vprintfmt+0x24>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80072d:	83 ec 08             	sub    $0x8,%esp
  800730:	57                   	push   %edi
  800731:	6a 25                	push   $0x25
  800733:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800736:	83 c4 10             	add    $0x10,%esp
  800739:	eb 02                	jmp    80073d <vprintfmt+0x378>
  80073b:	89 c6                	mov    %eax,%esi
  80073d:	8d 46 ff             	lea    -0x1(%esi),%eax
  800740:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800744:	75 f5                	jne    80073b <vprintfmt+0x376>
  800746:	e9 9e fc ff ff       	jmp    8003e9 <vprintfmt+0x24>
				/* do nothing */;
			break;
		}
	}
}
  80074b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80074e:	5b                   	pop    %ebx
  80074f:	5e                   	pop    %esi
  800750:	5f                   	pop    %edi
  800751:	c9                   	leave  
  800752:	c3                   	ret    

00800753 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800753:	55                   	push   %ebp
  800754:	89 e5                	mov    %esp,%ebp
  800756:	83 ec 18             	sub    $0x18,%esp
  800759:	8b 45 08             	mov    0x8(%ebp),%eax
  80075c:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80075f:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800762:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800766:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800769:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800770:	85 c0                	test   %eax,%eax
  800772:	74 26                	je     80079a <vsnprintf+0x47>
  800774:	85 d2                	test   %edx,%edx
  800776:	7e 29                	jle    8007a1 <vsnprintf+0x4e>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800778:	ff 75 14             	pushl  0x14(%ebp)
  80077b:	ff 75 10             	pushl  0x10(%ebp)
  80077e:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800781:	50                   	push   %eax
  800782:	68 8e 03 80 00       	push   $0x80038e
  800787:	e8 39 fc ff ff       	call   8003c5 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80078c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80078f:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800792:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800795:	83 c4 10             	add    $0x10,%esp
  800798:	eb 0c                	jmp    8007a6 <vsnprintf+0x53>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80079a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80079f:	eb 05                	jmp    8007a6 <vsnprintf+0x53>
  8007a1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8007a6:	c9                   	leave  
  8007a7:	c3                   	ret    

008007a8 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007a8:	55                   	push   %ebp
  8007a9:	89 e5                	mov    %esp,%ebp
  8007ab:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007ae:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8007b1:	50                   	push   %eax
  8007b2:	ff 75 10             	pushl  0x10(%ebp)
  8007b5:	ff 75 0c             	pushl  0xc(%ebp)
  8007b8:	ff 75 08             	pushl  0x8(%ebp)
  8007bb:	e8 93 ff ff ff       	call   800753 <vsnprintf>
	va_end(ap);

	return rc;
}
  8007c0:	c9                   	leave  
  8007c1:	c3                   	ret    
	...

008007c4 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007c4:	55                   	push   %ebp
  8007c5:	89 e5                	mov    %esp,%ebp
  8007c7:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007ca:	80 3a 00             	cmpb   $0x0,(%edx)
  8007cd:	74 0e                	je     8007dd <strlen+0x19>
  8007cf:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  8007d4:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8007d5:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007d9:	75 f9                	jne    8007d4 <strlen+0x10>
  8007db:	eb 05                	jmp    8007e2 <strlen+0x1e>
  8007dd:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  8007e2:	c9                   	leave  
  8007e3:	c3                   	ret    

008007e4 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007e4:	55                   	push   %ebp
  8007e5:	89 e5                	mov    %esp,%ebp
  8007e7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007ea:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007ed:	85 d2                	test   %edx,%edx
  8007ef:	74 17                	je     800808 <strnlen+0x24>
  8007f1:	80 39 00             	cmpb   $0x0,(%ecx)
  8007f4:	74 19                	je     80080f <strnlen+0x2b>
  8007f6:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  8007fb:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007fc:	39 d0                	cmp    %edx,%eax
  8007fe:	74 14                	je     800814 <strnlen+0x30>
  800800:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800804:	75 f5                	jne    8007fb <strnlen+0x17>
  800806:	eb 0c                	jmp    800814 <strnlen+0x30>
  800808:	b8 00 00 00 00       	mov    $0x0,%eax
  80080d:	eb 05                	jmp    800814 <strnlen+0x30>
  80080f:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800814:	c9                   	leave  
  800815:	c3                   	ret    

00800816 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800816:	55                   	push   %ebp
  800817:	89 e5                	mov    %esp,%ebp
  800819:	53                   	push   %ebx
  80081a:	8b 45 08             	mov    0x8(%ebp),%eax
  80081d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800820:	ba 00 00 00 00       	mov    $0x0,%edx
  800825:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  800828:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  80082b:	42                   	inc    %edx
  80082c:	84 c9                	test   %cl,%cl
  80082e:	75 f5                	jne    800825 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800830:	5b                   	pop    %ebx
  800831:	c9                   	leave  
  800832:	c3                   	ret    

00800833 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800833:	55                   	push   %ebp
  800834:	89 e5                	mov    %esp,%ebp
  800836:	53                   	push   %ebx
  800837:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80083a:	53                   	push   %ebx
  80083b:	e8 84 ff ff ff       	call   8007c4 <strlen>
  800840:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800843:	ff 75 0c             	pushl  0xc(%ebp)
  800846:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  800849:	50                   	push   %eax
  80084a:	e8 c7 ff ff ff       	call   800816 <strcpy>
	return dst;
}
  80084f:	89 d8                	mov    %ebx,%eax
  800851:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800854:	c9                   	leave  
  800855:	c3                   	ret    

00800856 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800856:	55                   	push   %ebp
  800857:	89 e5                	mov    %esp,%ebp
  800859:	56                   	push   %esi
  80085a:	53                   	push   %ebx
  80085b:	8b 45 08             	mov    0x8(%ebp),%eax
  80085e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800861:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800864:	85 f6                	test   %esi,%esi
  800866:	74 15                	je     80087d <strncpy+0x27>
  800868:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  80086d:	8a 1a                	mov    (%edx),%bl
  80086f:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800872:	80 3a 01             	cmpb   $0x1,(%edx)
  800875:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800878:	41                   	inc    %ecx
  800879:	39 ce                	cmp    %ecx,%esi
  80087b:	77 f0                	ja     80086d <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80087d:	5b                   	pop    %ebx
  80087e:	5e                   	pop    %esi
  80087f:	c9                   	leave  
  800880:	c3                   	ret    

00800881 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800881:	55                   	push   %ebp
  800882:	89 e5                	mov    %esp,%ebp
  800884:	57                   	push   %edi
  800885:	56                   	push   %esi
  800886:	53                   	push   %ebx
  800887:	8b 7d 08             	mov    0x8(%ebp),%edi
  80088a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80088d:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800890:	85 f6                	test   %esi,%esi
  800892:	74 32                	je     8008c6 <strlcpy+0x45>
		while (--size > 0 && *src != '\0')
  800894:	83 fe 01             	cmp    $0x1,%esi
  800897:	74 22                	je     8008bb <strlcpy+0x3a>
  800899:	8a 0b                	mov    (%ebx),%cl
  80089b:	84 c9                	test   %cl,%cl
  80089d:	74 20                	je     8008bf <strlcpy+0x3e>
  80089f:	89 f8                	mov    %edi,%eax
  8008a1:	ba 00 00 00 00       	mov    $0x0,%edx
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
  8008a6:	83 ee 02             	sub    $0x2,%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8008a9:	88 08                	mov    %cl,(%eax)
  8008ab:	40                   	inc    %eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8008ac:	39 f2                	cmp    %esi,%edx
  8008ae:	74 11                	je     8008c1 <strlcpy+0x40>
  8008b0:	8a 4c 13 01          	mov    0x1(%ebx,%edx,1),%cl
  8008b4:	42                   	inc    %edx
  8008b5:	84 c9                	test   %cl,%cl
  8008b7:	75 f0                	jne    8008a9 <strlcpy+0x28>
  8008b9:	eb 06                	jmp    8008c1 <strlcpy+0x40>
  8008bb:	89 f8                	mov    %edi,%eax
  8008bd:	eb 02                	jmp    8008c1 <strlcpy+0x40>
  8008bf:	89 f8                	mov    %edi,%eax
			*dst++ = *src++;
		*dst = '\0';
  8008c1:	c6 00 00             	movb   $0x0,(%eax)
  8008c4:	eb 02                	jmp    8008c8 <strlcpy+0x47>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8008c6:	89 f8                	mov    %edi,%eax
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
		*dst = '\0';
	}
	return dst - dst_in;
  8008c8:	29 f8                	sub    %edi,%eax
}
  8008ca:	5b                   	pop    %ebx
  8008cb:	5e                   	pop    %esi
  8008cc:	5f                   	pop    %edi
  8008cd:	c9                   	leave  
  8008ce:	c3                   	ret    

008008cf <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8008cf:	55                   	push   %ebp
  8008d0:	89 e5                	mov    %esp,%ebp
  8008d2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008d5:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008d8:	8a 01                	mov    (%ecx),%al
  8008da:	84 c0                	test   %al,%al
  8008dc:	74 10                	je     8008ee <strcmp+0x1f>
  8008de:	3a 02                	cmp    (%edx),%al
  8008e0:	75 0c                	jne    8008ee <strcmp+0x1f>
		p++, q++;
  8008e2:	41                   	inc    %ecx
  8008e3:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8008e4:	8a 01                	mov    (%ecx),%al
  8008e6:	84 c0                	test   %al,%al
  8008e8:	74 04                	je     8008ee <strcmp+0x1f>
  8008ea:	3a 02                	cmp    (%edx),%al
  8008ec:	74 f4                	je     8008e2 <strcmp+0x13>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008ee:	0f b6 c0             	movzbl %al,%eax
  8008f1:	0f b6 12             	movzbl (%edx),%edx
  8008f4:	29 d0                	sub    %edx,%eax
}
  8008f6:	c9                   	leave  
  8008f7:	c3                   	ret    

008008f8 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008f8:	55                   	push   %ebp
  8008f9:	89 e5                	mov    %esp,%ebp
  8008fb:	53                   	push   %ebx
  8008fc:	8b 55 08             	mov    0x8(%ebp),%edx
  8008ff:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800902:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  800905:	85 c0                	test   %eax,%eax
  800907:	74 1b                	je     800924 <strncmp+0x2c>
  800909:	8a 1a                	mov    (%edx),%bl
  80090b:	84 db                	test   %bl,%bl
  80090d:	74 24                	je     800933 <strncmp+0x3b>
  80090f:	3a 19                	cmp    (%ecx),%bl
  800911:	75 20                	jne    800933 <strncmp+0x3b>
  800913:	48                   	dec    %eax
  800914:	74 15                	je     80092b <strncmp+0x33>
		n--, p++, q++;
  800916:	42                   	inc    %edx
  800917:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800918:	8a 1a                	mov    (%edx),%bl
  80091a:	84 db                	test   %bl,%bl
  80091c:	74 15                	je     800933 <strncmp+0x3b>
  80091e:	3a 19                	cmp    (%ecx),%bl
  800920:	74 f1                	je     800913 <strncmp+0x1b>
  800922:	eb 0f                	jmp    800933 <strncmp+0x3b>
		n--, p++, q++;
	if (n == 0)
		return 0;
  800924:	b8 00 00 00 00       	mov    $0x0,%eax
  800929:	eb 05                	jmp    800930 <strncmp+0x38>
  80092b:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800930:	5b                   	pop    %ebx
  800931:	c9                   	leave  
  800932:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800933:	0f b6 02             	movzbl (%edx),%eax
  800936:	0f b6 11             	movzbl (%ecx),%edx
  800939:	29 d0                	sub    %edx,%eax
  80093b:	eb f3                	jmp    800930 <strncmp+0x38>

0080093d <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80093d:	55                   	push   %ebp
  80093e:	89 e5                	mov    %esp,%ebp
  800940:	8b 45 08             	mov    0x8(%ebp),%eax
  800943:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800946:	8a 10                	mov    (%eax),%dl
  800948:	84 d2                	test   %dl,%dl
  80094a:	74 18                	je     800964 <strchr+0x27>
		if (*s == c)
  80094c:	38 ca                	cmp    %cl,%dl
  80094e:	75 06                	jne    800956 <strchr+0x19>
  800950:	eb 17                	jmp    800969 <strchr+0x2c>
  800952:	38 ca                	cmp    %cl,%dl
  800954:	74 13                	je     800969 <strchr+0x2c>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800956:	40                   	inc    %eax
  800957:	8a 10                	mov    (%eax),%dl
  800959:	84 d2                	test   %dl,%dl
  80095b:	75 f5                	jne    800952 <strchr+0x15>
		if (*s == c)
			return (char *) s;
	return 0;
  80095d:	b8 00 00 00 00       	mov    $0x0,%eax
  800962:	eb 05                	jmp    800969 <strchr+0x2c>
  800964:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800969:	c9                   	leave  
  80096a:	c3                   	ret    

0080096b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80096b:	55                   	push   %ebp
  80096c:	89 e5                	mov    %esp,%ebp
  80096e:	8b 45 08             	mov    0x8(%ebp),%eax
  800971:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800974:	8a 10                	mov    (%eax),%dl
  800976:	84 d2                	test   %dl,%dl
  800978:	74 11                	je     80098b <strfind+0x20>
		if (*s == c)
  80097a:	38 ca                	cmp    %cl,%dl
  80097c:	75 06                	jne    800984 <strfind+0x19>
  80097e:	eb 0b                	jmp    80098b <strfind+0x20>
  800980:	38 ca                	cmp    %cl,%dl
  800982:	74 07                	je     80098b <strfind+0x20>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800984:	40                   	inc    %eax
  800985:	8a 10                	mov    (%eax),%dl
  800987:	84 d2                	test   %dl,%dl
  800989:	75 f5                	jne    800980 <strfind+0x15>
		if (*s == c)
			break;
	return (char *) s;
}
  80098b:	c9                   	leave  
  80098c:	c3                   	ret    

0080098d <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80098d:	55                   	push   %ebp
  80098e:	89 e5                	mov    %esp,%ebp
  800990:	57                   	push   %edi
  800991:	56                   	push   %esi
  800992:	53                   	push   %ebx
  800993:	8b 7d 08             	mov    0x8(%ebp),%edi
  800996:	8b 45 0c             	mov    0xc(%ebp),%eax
  800999:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80099c:	85 c9                	test   %ecx,%ecx
  80099e:	74 30                	je     8009d0 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8009a0:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8009a6:	75 25                	jne    8009cd <memset+0x40>
  8009a8:	f6 c1 03             	test   $0x3,%cl
  8009ab:	75 20                	jne    8009cd <memset+0x40>
		c &= 0xFF;
  8009ad:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8009b0:	89 d3                	mov    %edx,%ebx
  8009b2:	c1 e3 08             	shl    $0x8,%ebx
  8009b5:	89 d6                	mov    %edx,%esi
  8009b7:	c1 e6 18             	shl    $0x18,%esi
  8009ba:	89 d0                	mov    %edx,%eax
  8009bc:	c1 e0 10             	shl    $0x10,%eax
  8009bf:	09 f0                	or     %esi,%eax
  8009c1:	09 d0                	or     %edx,%eax
  8009c3:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  8009c5:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  8009c8:	fc                   	cld    
  8009c9:	f3 ab                	rep stos %eax,%es:(%edi)
  8009cb:	eb 03                	jmp    8009d0 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8009cd:	fc                   	cld    
  8009ce:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8009d0:	89 f8                	mov    %edi,%eax
  8009d2:	5b                   	pop    %ebx
  8009d3:	5e                   	pop    %esi
  8009d4:	5f                   	pop    %edi
  8009d5:	c9                   	leave  
  8009d6:	c3                   	ret    

008009d7 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8009d7:	55                   	push   %ebp
  8009d8:	89 e5                	mov    %esp,%ebp
  8009da:	57                   	push   %edi
  8009db:	56                   	push   %esi
  8009dc:	8b 45 08             	mov    0x8(%ebp),%eax
  8009df:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009e2:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8009e5:	39 c6                	cmp    %eax,%esi
  8009e7:	73 34                	jae    800a1d <memmove+0x46>
  8009e9:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8009ec:	39 d0                	cmp    %edx,%eax
  8009ee:	73 2d                	jae    800a1d <memmove+0x46>
		s += n;
		d += n;
  8009f0:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009f3:	f6 c2 03             	test   $0x3,%dl
  8009f6:	75 1b                	jne    800a13 <memmove+0x3c>
  8009f8:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8009fe:	75 13                	jne    800a13 <memmove+0x3c>
  800a00:	f6 c1 03             	test   $0x3,%cl
  800a03:	75 0e                	jne    800a13 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800a05:	83 ef 04             	sub    $0x4,%edi
  800a08:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a0b:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800a0e:	fd                   	std    
  800a0f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a11:	eb 07                	jmp    800a1a <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800a13:	4f                   	dec    %edi
  800a14:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800a17:	fd                   	std    
  800a18:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a1a:	fc                   	cld    
  800a1b:	eb 20                	jmp    800a3d <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a1d:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a23:	75 13                	jne    800a38 <memmove+0x61>
  800a25:	a8 03                	test   $0x3,%al
  800a27:	75 0f                	jne    800a38 <memmove+0x61>
  800a29:	f6 c1 03             	test   $0x3,%cl
  800a2c:	75 0a                	jne    800a38 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800a2e:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800a31:	89 c7                	mov    %eax,%edi
  800a33:	fc                   	cld    
  800a34:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a36:	eb 05                	jmp    800a3d <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a38:	89 c7                	mov    %eax,%edi
  800a3a:	fc                   	cld    
  800a3b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a3d:	5e                   	pop    %esi
  800a3e:	5f                   	pop    %edi
  800a3f:	c9                   	leave  
  800a40:	c3                   	ret    

00800a41 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a41:	55                   	push   %ebp
  800a42:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800a44:	ff 75 10             	pushl  0x10(%ebp)
  800a47:	ff 75 0c             	pushl  0xc(%ebp)
  800a4a:	ff 75 08             	pushl  0x8(%ebp)
  800a4d:	e8 85 ff ff ff       	call   8009d7 <memmove>
}
  800a52:	c9                   	leave  
  800a53:	c3                   	ret    

00800a54 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a54:	55                   	push   %ebp
  800a55:	89 e5                	mov    %esp,%ebp
  800a57:	57                   	push   %edi
  800a58:	56                   	push   %esi
  800a59:	53                   	push   %ebx
  800a5a:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800a5d:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a60:	8b 7d 10             	mov    0x10(%ebp),%edi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a63:	85 ff                	test   %edi,%edi
  800a65:	74 32                	je     800a99 <memcmp+0x45>
		if (*s1 != *s2)
  800a67:	8a 03                	mov    (%ebx),%al
  800a69:	8a 0e                	mov    (%esi),%cl
  800a6b:	38 c8                	cmp    %cl,%al
  800a6d:	74 19                	je     800a88 <memcmp+0x34>
  800a6f:	eb 0d                	jmp    800a7e <memcmp+0x2a>
  800a71:	8a 44 13 01          	mov    0x1(%ebx,%edx,1),%al
  800a75:	8a 4c 16 01          	mov    0x1(%esi,%edx,1),%cl
  800a79:	42                   	inc    %edx
  800a7a:	38 c8                	cmp    %cl,%al
  800a7c:	74 10                	je     800a8e <memcmp+0x3a>
			return (int) *s1 - (int) *s2;
  800a7e:	0f b6 c0             	movzbl %al,%eax
  800a81:	0f b6 c9             	movzbl %cl,%ecx
  800a84:	29 c8                	sub    %ecx,%eax
  800a86:	eb 16                	jmp    800a9e <memcmp+0x4a>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a88:	4f                   	dec    %edi
  800a89:	ba 00 00 00 00       	mov    $0x0,%edx
  800a8e:	39 fa                	cmp    %edi,%edx
  800a90:	75 df                	jne    800a71 <memcmp+0x1d>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a92:	b8 00 00 00 00       	mov    $0x0,%eax
  800a97:	eb 05                	jmp    800a9e <memcmp+0x4a>
  800a99:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a9e:	5b                   	pop    %ebx
  800a9f:	5e                   	pop    %esi
  800aa0:	5f                   	pop    %edi
  800aa1:	c9                   	leave  
  800aa2:	c3                   	ret    

00800aa3 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800aa3:	55                   	push   %ebp
  800aa4:	89 e5                	mov    %esp,%ebp
  800aa6:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800aa9:	89 c2                	mov    %eax,%edx
  800aab:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800aae:	39 d0                	cmp    %edx,%eax
  800ab0:	73 12                	jae    800ac4 <memfind+0x21>
		if (*(const unsigned char *) s == (unsigned char) c)
  800ab2:	8a 4d 0c             	mov    0xc(%ebp),%cl
  800ab5:	38 08                	cmp    %cl,(%eax)
  800ab7:	75 06                	jne    800abf <memfind+0x1c>
  800ab9:	eb 09                	jmp    800ac4 <memfind+0x21>
  800abb:	38 08                	cmp    %cl,(%eax)
  800abd:	74 05                	je     800ac4 <memfind+0x21>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800abf:	40                   	inc    %eax
  800ac0:	39 c2                	cmp    %eax,%edx
  800ac2:	77 f7                	ja     800abb <memfind+0x18>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800ac4:	c9                   	leave  
  800ac5:	c3                   	ret    

00800ac6 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800ac6:	55                   	push   %ebp
  800ac7:	89 e5                	mov    %esp,%ebp
  800ac9:	57                   	push   %edi
  800aca:	56                   	push   %esi
  800acb:	53                   	push   %ebx
  800acc:	8b 55 08             	mov    0x8(%ebp),%edx
  800acf:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ad2:	eb 01                	jmp    800ad5 <strtol+0xf>
		s++;
  800ad4:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ad5:	8a 02                	mov    (%edx),%al
  800ad7:	3c 20                	cmp    $0x20,%al
  800ad9:	74 f9                	je     800ad4 <strtol+0xe>
  800adb:	3c 09                	cmp    $0x9,%al
  800add:	74 f5                	je     800ad4 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800adf:	3c 2b                	cmp    $0x2b,%al
  800ae1:	75 08                	jne    800aeb <strtol+0x25>
		s++;
  800ae3:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800ae4:	bf 00 00 00 00       	mov    $0x0,%edi
  800ae9:	eb 13                	jmp    800afe <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800aeb:	3c 2d                	cmp    $0x2d,%al
  800aed:	75 0a                	jne    800af9 <strtol+0x33>
		s++, neg = 1;
  800aef:	8d 52 01             	lea    0x1(%edx),%edx
  800af2:	bf 01 00 00 00       	mov    $0x1,%edi
  800af7:	eb 05                	jmp    800afe <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800af9:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800afe:	85 db                	test   %ebx,%ebx
  800b00:	74 05                	je     800b07 <strtol+0x41>
  800b02:	83 fb 10             	cmp    $0x10,%ebx
  800b05:	75 28                	jne    800b2f <strtol+0x69>
  800b07:	8a 02                	mov    (%edx),%al
  800b09:	3c 30                	cmp    $0x30,%al
  800b0b:	75 10                	jne    800b1d <strtol+0x57>
  800b0d:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800b11:	75 0a                	jne    800b1d <strtol+0x57>
		s += 2, base = 16;
  800b13:	83 c2 02             	add    $0x2,%edx
  800b16:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b1b:	eb 12                	jmp    800b2f <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800b1d:	85 db                	test   %ebx,%ebx
  800b1f:	75 0e                	jne    800b2f <strtol+0x69>
  800b21:	3c 30                	cmp    $0x30,%al
  800b23:	75 05                	jne    800b2a <strtol+0x64>
		s++, base = 8;
  800b25:	42                   	inc    %edx
  800b26:	b3 08                	mov    $0x8,%bl
  800b28:	eb 05                	jmp    800b2f <strtol+0x69>
	else if (base == 0)
		base = 10;
  800b2a:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800b2f:	b8 00 00 00 00       	mov    $0x0,%eax
  800b34:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800b36:	8a 0a                	mov    (%edx),%cl
  800b38:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800b3b:	80 fb 09             	cmp    $0x9,%bl
  800b3e:	77 08                	ja     800b48 <strtol+0x82>
			dig = *s - '0';
  800b40:	0f be c9             	movsbl %cl,%ecx
  800b43:	83 e9 30             	sub    $0x30,%ecx
  800b46:	eb 1e                	jmp    800b66 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800b48:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800b4b:	80 fb 19             	cmp    $0x19,%bl
  800b4e:	77 08                	ja     800b58 <strtol+0x92>
			dig = *s - 'a' + 10;
  800b50:	0f be c9             	movsbl %cl,%ecx
  800b53:	83 e9 57             	sub    $0x57,%ecx
  800b56:	eb 0e                	jmp    800b66 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800b58:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800b5b:	80 fb 19             	cmp    $0x19,%bl
  800b5e:	77 13                	ja     800b73 <strtol+0xad>
			dig = *s - 'A' + 10;
  800b60:	0f be c9             	movsbl %cl,%ecx
  800b63:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800b66:	39 f1                	cmp    %esi,%ecx
  800b68:	7d 0d                	jge    800b77 <strtol+0xb1>
			break;
		s++, val = (val * base) + dig;
  800b6a:	42                   	inc    %edx
  800b6b:	0f af c6             	imul   %esi,%eax
  800b6e:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  800b71:	eb c3                	jmp    800b36 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800b73:	89 c1                	mov    %eax,%ecx
  800b75:	eb 02                	jmp    800b79 <strtol+0xb3>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800b77:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800b79:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b7d:	74 05                	je     800b84 <strtol+0xbe>
		*endptr = (char *) s;
  800b7f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800b82:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800b84:	85 ff                	test   %edi,%edi
  800b86:	74 04                	je     800b8c <strtol+0xc6>
  800b88:	89 c8                	mov    %ecx,%eax
  800b8a:	f7 d8                	neg    %eax
}
  800b8c:	5b                   	pop    %ebx
  800b8d:	5e                   	pop    %esi
  800b8e:	5f                   	pop    %edi
  800b8f:	c9                   	leave  
  800b90:	c3                   	ret    
  800b91:	00 00                	add    %al,(%eax)
	...

00800b94 <syscall>:
	return ret;
}

static int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800b94:	55                   	push   %ebp
  800b95:	89 e5                	mov    %esp,%ebp
  800b97:	57                   	push   %edi
  800b98:	56                   	push   %esi
  800b99:	53                   	push   %ebx
  800b9a:	83 ec 1c             	sub    $0x1c,%esp
  800b9d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800ba0:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800ba3:	89 ca                	mov    %ecx,%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ba5:	8b 75 14             	mov    0x14(%ebp),%esi
  800ba8:	8b 7d 10             	mov    0x10(%ebp),%edi
  800bab:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800bae:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800bb1:	cd 30                	int    $0x30
  800bb3:	89 c2                	mov    %eax,%edx
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800bb5:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800bb9:	74 1c                	je     800bd7 <syscall+0x43>
  800bbb:	85 c0                	test   %eax,%eax
  800bbd:	7e 18                	jle    800bd7 <syscall+0x43>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bbf:	83 ec 0c             	sub    $0xc,%esp
  800bc2:	50                   	push   %eax
  800bc3:	ff 75 e4             	pushl  -0x1c(%ebp)
  800bc6:	68 9f 25 80 00       	push   $0x80259f
  800bcb:	6a 42                	push   $0x42
  800bcd:	68 bc 25 80 00       	push   $0x8025bc
  800bd2:	e8 b1 f5 ff ff       	call   800188 <_panic>

	return ret;
}
  800bd7:	89 d0                	mov    %edx,%eax
  800bd9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bdc:	5b                   	pop    %ebx
  800bdd:	5e                   	pop    %esi
  800bde:	5f                   	pop    %edi
  800bdf:	c9                   	leave  
  800be0:	c3                   	ret    

00800be1 <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{	
  800be1:	55                   	push   %ebp
  800be2:	89 e5                	mov    %esp,%ebp
  800be4:	83 ec 08             	sub    $0x8,%esp
	// my_sysenter(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
	// return;
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  800be7:	6a 00                	push   $0x0
  800be9:	6a 00                	push   $0x0
  800beb:	6a 00                	push   $0x0
  800bed:	ff 75 0c             	pushl  0xc(%ebp)
  800bf0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800bf3:	ba 00 00 00 00       	mov    $0x0,%edx
  800bf8:	b8 00 00 00 00       	mov    $0x0,%eax
  800bfd:	e8 92 ff ff ff       	call   800b94 <syscall>
  800c02:	83 c4 10             	add    $0x10,%esp
	return;
}
  800c05:	c9                   	leave  
  800c06:	c3                   	ret    

00800c07 <sys_cgetc>:

int
sys_cgetc(void)
{
  800c07:	55                   	push   %ebp
  800c08:	89 e5                	mov    %esp,%ebp
  800c0a:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_cgetc, 0, 0, 0, 0, 0, 0);
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  800c0d:	6a 00                	push   $0x0
  800c0f:	6a 00                	push   $0x0
  800c11:	6a 00                	push   $0x0
  800c13:	6a 00                	push   $0x0
  800c15:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c1a:	ba 00 00 00 00       	mov    $0x0,%edx
  800c1f:	b8 01 00 00 00       	mov    $0x1,%eax
  800c24:	e8 6b ff ff ff       	call   800b94 <syscall>
}
  800c29:	c9                   	leave  
  800c2a:	c3                   	ret    

00800c2b <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800c2b:	55                   	push   %ebp
  800c2c:	89 e5                	mov    %esp,%ebp
  800c2e:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  800c31:	6a 00                	push   $0x0
  800c33:	6a 00                	push   $0x0
  800c35:	6a 00                	push   $0x0
  800c37:	6a 00                	push   $0x0
  800c39:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c3c:	ba 01 00 00 00       	mov    $0x1,%edx
  800c41:	b8 03 00 00 00       	mov    $0x3,%eax
  800c46:	e8 49 ff ff ff       	call   800b94 <syscall>
}
  800c4b:	c9                   	leave  
  800c4c:	c3                   	ret    

00800c4d <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c4d:	55                   	push   %ebp
  800c4e:	89 e5                	mov    %esp,%ebp
  800c50:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_getenvid, 0, 0, 0, 0, 0, 0);
	return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  800c53:	6a 00                	push   $0x0
  800c55:	6a 00                	push   $0x0
  800c57:	6a 00                	push   $0x0
  800c59:	6a 00                	push   $0x0
  800c5b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c60:	ba 00 00 00 00       	mov    $0x0,%edx
  800c65:	b8 02 00 00 00       	mov    $0x2,%eax
  800c6a:	e8 25 ff ff ff       	call   800b94 <syscall>
}
  800c6f:	c9                   	leave  
  800c70:	c3                   	ret    

00800c71 <sys_yield>:

void
sys_yield(void)
{
  800c71:	55                   	push   %ebp
  800c72:	89 e5                	mov    %esp,%ebp
  800c74:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  800c77:	6a 00                	push   $0x0
  800c79:	6a 00                	push   $0x0
  800c7b:	6a 00                	push   $0x0
  800c7d:	6a 00                	push   $0x0
  800c7f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c84:	ba 00 00 00 00       	mov    $0x0,%edx
  800c89:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c8e:	e8 01 ff ff ff       	call   800b94 <syscall>
  800c93:	83 c4 10             	add    $0x10,%esp
}
  800c96:	c9                   	leave  
  800c97:	c3                   	ret    

00800c98 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c98:	55                   	push   %ebp
  800c99:	89 e5                	mov    %esp,%ebp
  800c9b:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  800c9e:	6a 00                	push   $0x0
  800ca0:	6a 00                	push   $0x0
  800ca2:	ff 75 10             	pushl  0x10(%ebp)
  800ca5:	ff 75 0c             	pushl  0xc(%ebp)
  800ca8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800cab:	ba 01 00 00 00       	mov    $0x1,%edx
  800cb0:	b8 04 00 00 00       	mov    $0x4,%eax
  800cb5:	e8 da fe ff ff       	call   800b94 <syscall>
}
  800cba:	c9                   	leave  
  800cbb:	c3                   	ret    

00800cbc <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800cbc:	55                   	push   %ebp
  800cbd:	89 e5                	mov    %esp,%ebp
  800cbf:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
  800cc2:	ff 75 18             	pushl  0x18(%ebp)
  800cc5:	ff 75 14             	pushl  0x14(%ebp)
  800cc8:	ff 75 10             	pushl  0x10(%ebp)
  800ccb:	ff 75 0c             	pushl  0xc(%ebp)
  800cce:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800cd1:	ba 01 00 00 00       	mov    $0x1,%edx
  800cd6:	b8 05 00 00 00       	mov    $0x5,%eax
  800cdb:	e8 b4 fe ff ff       	call   800b94 <syscall>
}
  800ce0:	c9                   	leave  
  800ce1:	c3                   	ret    

00800ce2 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800ce2:	55                   	push   %ebp
  800ce3:	89 e5                	mov    %esp,%ebp
  800ce5:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  800ce8:	6a 00                	push   $0x0
  800cea:	6a 00                	push   $0x0
  800cec:	6a 00                	push   $0x0
  800cee:	ff 75 0c             	pushl  0xc(%ebp)
  800cf1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800cf4:	ba 01 00 00 00       	mov    $0x1,%edx
  800cf9:	b8 06 00 00 00       	mov    $0x6,%eax
  800cfe:	e8 91 fe ff ff       	call   800b94 <syscall>
}
  800d03:	c9                   	leave  
  800d04:	c3                   	ret    

00800d05 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800d05:	55                   	push   %ebp
  800d06:	89 e5                	mov    %esp,%ebp
  800d08:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  800d0b:	6a 00                	push   $0x0
  800d0d:	6a 00                	push   $0x0
  800d0f:	6a 00                	push   $0x0
  800d11:	ff 75 0c             	pushl  0xc(%ebp)
  800d14:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d17:	ba 01 00 00 00       	mov    $0x1,%edx
  800d1c:	b8 08 00 00 00       	mov    $0x8,%eax
  800d21:	e8 6e fe ff ff       	call   800b94 <syscall>
}
  800d26:	c9                   	leave  
  800d27:	c3                   	ret    

00800d28 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800d28:	55                   	push   %ebp
  800d29:	89 e5                	mov    %esp,%ebp
  800d2b:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
  800d2e:	6a 00                	push   $0x0
  800d30:	6a 00                	push   $0x0
  800d32:	6a 00                	push   $0x0
  800d34:	ff 75 0c             	pushl  0xc(%ebp)
  800d37:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d3a:	ba 01 00 00 00       	mov    $0x1,%edx
  800d3f:	b8 09 00 00 00       	mov    $0x9,%eax
  800d44:	e8 4b fe ff ff       	call   800b94 <syscall>
}
  800d49:	c9                   	leave  
  800d4a:	c3                   	ret    

00800d4b <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d4b:	55                   	push   %ebp
  800d4c:	89 e5                	mov    %esp,%ebp
  800d4e:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  800d51:	6a 00                	push   $0x0
  800d53:	6a 00                	push   $0x0
  800d55:	6a 00                	push   $0x0
  800d57:	ff 75 0c             	pushl  0xc(%ebp)
  800d5a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d5d:	ba 01 00 00 00       	mov    $0x1,%edx
  800d62:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d67:	e8 28 fe ff ff       	call   800b94 <syscall>
}
  800d6c:	c9                   	leave  
  800d6d:	c3                   	ret    

00800d6e <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d6e:	55                   	push   %ebp
  800d6f:	89 e5                	mov    %esp,%ebp
  800d71:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  800d74:	6a 00                	push   $0x0
  800d76:	ff 75 14             	pushl  0x14(%ebp)
  800d79:	ff 75 10             	pushl  0x10(%ebp)
  800d7c:	ff 75 0c             	pushl  0xc(%ebp)
  800d7f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d82:	ba 00 00 00 00       	mov    $0x0,%edx
  800d87:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d8c:	e8 03 fe ff ff       	call   800b94 <syscall>
}
  800d91:	c9                   	leave  
  800d92:	c3                   	ret    

00800d93 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d93:	55                   	push   %ebp
  800d94:	89 e5                	mov    %esp,%ebp
  800d96:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  800d99:	6a 00                	push   $0x0
  800d9b:	6a 00                	push   $0x0
  800d9d:	6a 00                	push   $0x0
  800d9f:	6a 00                	push   $0x0
  800da1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800da4:	ba 01 00 00 00       	mov    $0x1,%edx
  800da9:	b8 0d 00 00 00       	mov    $0xd,%eax
  800dae:	e8 e1 fd ff ff       	call   800b94 <syscall>
}
  800db3:	c9                   	leave  
  800db4:	c3                   	ret    

00800db5 <sys_set_priority>:

int
sys_set_priority(envid_t envid, uint32_t new_priority)
{
  800db5:	55                   	push   %ebp
  800db6:	89 e5                	mov    %esp,%ebp
  800db8:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_set_priority, 0, envid, new_priority, 0, 0, 0);
  800dbb:	6a 00                	push   $0x0
  800dbd:	6a 00                	push   $0x0
  800dbf:	6a 00                	push   $0x0
  800dc1:	ff 75 0c             	pushl  0xc(%ebp)
  800dc4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800dc7:	ba 00 00 00 00       	mov    $0x0,%edx
  800dcc:	b8 0e 00 00 00       	mov    $0xe,%eax
  800dd1:	e8 be fd ff ff       	call   800b94 <syscall>
}
  800dd6:	c9                   	leave  
  800dd7:	c3                   	ret    

00800dd8 <sys_exec>:

int
sys_exec(uint32_t eip, uint32_t esp, void * ph, uint32_t elf_phnum)
{
  800dd8:	55                   	push   %ebp
  800dd9:	89 e5                	mov    %esp,%ebp
  800ddb:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_exec, 0, eip, esp, (uint32_t)ph, elf_phnum, 0);
  800dde:	6a 00                	push   $0x0
  800de0:	ff 75 14             	pushl  0x14(%ebp)
  800de3:	ff 75 10             	pushl  0x10(%ebp)
  800de6:	ff 75 0c             	pushl  0xc(%ebp)
  800de9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800dec:	ba 00 00 00 00       	mov    $0x0,%edx
  800df1:	b8 0f 00 00 00       	mov    $0xf,%eax
  800df6:	e8 99 fd ff ff       	call   800b94 <syscall>
  800dfb:	c9                   	leave  
  800dfc:	c3                   	ret    
  800dfd:	00 00                	add    %al,(%eax)
	...

00800e00 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800e00:	55                   	push   %ebp
  800e01:	89 e5                	mov    %esp,%ebp
  800e03:	53                   	push   %ebx
  800e04:	83 ec 04             	sub    $0x4,%esp
  800e07:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800e0a:	8b 18                	mov    (%eax),%ebx

	// LAB 4: Your code here.
	
	// cprintf("PAGE FAULT HANDLER, 0x%08x %d\n", (uint32_t)addr, err & FEC_WR);
	
	if ((err & FEC_WR) == 0)
  800e0c:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800e10:	75 14                	jne    800e26 <pgfault+0x26>
		panic("pgfault, the fault is not a write\n");
  800e12:	83 ec 04             	sub    $0x4,%esp
  800e15:	68 cc 25 80 00       	push   $0x8025cc
  800e1a:	6a 20                	push   $0x20
  800e1c:	68 10 27 80 00       	push   $0x802710
  800e21:	e8 62 f3 ff ff       	call   800188 <_panic>

	uint32_t uaddr = (uint32_t) addr;
	if ((uvpd[PDX(addr)] & PTE_P) == 0 || (uvpt[uaddr / PGSIZE] & PTE_COW) == 0) {
  800e26:	89 d8                	mov    %ebx,%eax
  800e28:	c1 e8 16             	shr    $0x16,%eax
  800e2b:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800e32:	a8 01                	test   $0x1,%al
  800e34:	74 11                	je     800e47 <pgfault+0x47>
  800e36:	89 d8                	mov    %ebx,%eax
  800e38:	c1 e8 0c             	shr    $0xc,%eax
  800e3b:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800e42:	f6 c4 08             	test   $0x8,%ah
  800e45:	75 14                	jne    800e5b <pgfault+0x5b>
		panic("pgfault, not a copy-on-write page\n");
  800e47:	83 ec 04             	sub    $0x4,%esp
  800e4a:	68 f0 25 80 00       	push   $0x8025f0
  800e4f:	6a 24                	push   $0x24
  800e51:	68 10 27 80 00       	push   $0x802710
  800e56:	e8 2d f3 ff ff       	call   800188 <_panic>
	//   No need to explicitly delete the old page's mapping.

	// LAB 4: Your code here.

	// static int sys_page_alloc(envid_t envid, void *va, int perm)
	r = sys_page_alloc(0, (void *)PFTEMP, PTE_W | PTE_U | PTE_P);
  800e5b:	83 ec 04             	sub    $0x4,%esp
  800e5e:	6a 07                	push   $0x7
  800e60:	68 00 f0 7f 00       	push   $0x7ff000
  800e65:	6a 00                	push   $0x0
  800e67:	e8 2c fe ff ff       	call   800c98 <sys_page_alloc>
	if (r < 0) panic("pgfault, sys_page_alloc error : %e\n", r);
  800e6c:	83 c4 10             	add    $0x10,%esp
  800e6f:	85 c0                	test   %eax,%eax
  800e71:	79 12                	jns    800e85 <pgfault+0x85>
  800e73:	50                   	push   %eax
  800e74:	68 14 26 80 00       	push   $0x802614
  800e79:	6a 32                	push   $0x32
  800e7b:	68 10 27 80 00       	push   $0x802710
  800e80:	e8 03 f3 ff ff       	call   800188 <_panic>

	// Oh my god, I forget this at the first, it waste me a lot of time to debug!!!
	addr = ROUNDDOWN(addr, PGSIZE);
  800e85:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	
	memcpy(PFTEMP, addr, PGSIZE);
  800e8b:	83 ec 04             	sub    $0x4,%esp
  800e8e:	68 00 10 00 00       	push   $0x1000
  800e93:	53                   	push   %ebx
  800e94:	68 00 f0 7f 00       	push   $0x7ff000
  800e99:	e8 a3 fb ff ff       	call   800a41 <memcpy>
	
	r = sys_page_map(0, PFTEMP, 0, addr, PTE_W | PTE_U | PTE_P);
  800e9e:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800ea5:	53                   	push   %ebx
  800ea6:	6a 00                	push   $0x0
  800ea8:	68 00 f0 7f 00       	push   $0x7ff000
  800ead:	6a 00                	push   $0x0
  800eaf:	e8 08 fe ff ff       	call   800cbc <sys_page_map>
	if (r < 0) panic("pgfault, sys_page_map error : %e\n", r);
  800eb4:	83 c4 20             	add    $0x20,%esp
  800eb7:	85 c0                	test   %eax,%eax
  800eb9:	79 12                	jns    800ecd <pgfault+0xcd>
  800ebb:	50                   	push   %eax
  800ebc:	68 38 26 80 00       	push   $0x802638
  800ec1:	6a 3a                	push   $0x3a
  800ec3:	68 10 27 80 00       	push   $0x802710
  800ec8:	e8 bb f2 ff ff       	call   800188 <_panic>

	return;
}
  800ecd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ed0:	c9                   	leave  
  800ed1:	c3                   	ret    

00800ed2 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800ed2:	55                   	push   %ebp
  800ed3:	89 e5                	mov    %esp,%ebp
  800ed5:	57                   	push   %edi
  800ed6:	56                   	push   %esi
  800ed7:	53                   	push   %ebx
  800ed8:	83 ec 28             	sub    $0x28,%esp
	// static int num = 0x100;

	// LAB 4: Your code here.
	set_pgfault_handler(pgfault);
  800edb:	68 00 0e 80 00       	push   $0x800e00
  800ee0:	e8 eb 0e 00 00       	call   801dd0 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  800ee5:	ba 07 00 00 00       	mov    $0x7,%edx
  800eea:	89 d0                	mov    %edx,%eax
  800eec:	cd 30                	int    $0x30
  800eee:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800ef1:	89 c7                	mov    %eax,%edi
	int childpid = sys_exofork();
	if (childpid < 0) {
  800ef3:	83 c4 10             	add    $0x10,%esp
  800ef6:	85 c0                	test   %eax,%eax
  800ef8:	79 12                	jns    800f0c <fork+0x3a>
		panic("fork sys_exofork error : %e\n", childpid);
  800efa:	50                   	push   %eax
  800efb:	68 1b 27 80 00       	push   $0x80271b
  800f00:	6a 7f                	push   $0x7f
  800f02:	68 10 27 80 00       	push   $0x802710
  800f07:	e8 7c f2 ff ff       	call   800188 <_panic>
	}
	int r;

	if (childpid == 0) {
  800f0c:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800f10:	75 25                	jne    800f37 <fork+0x65>
		// child process
		// Remember to fix "thisenv" in the child process. ??? 
		thisenv = &envs[ENVX(sys_getenvid())];
  800f12:	e8 36 fd ff ff       	call   800c4d <sys_getenvid>
  800f17:	25 ff 03 00 00       	and    $0x3ff,%eax
  800f1c:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800f23:	c1 e0 07             	shl    $0x7,%eax
  800f26:	29 d0                	sub    %edx,%eax
  800f28:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800f2d:	a3 08 40 80 00       	mov    %eax,0x804008
		// cprintf("fork child ok\n");
		return 0;
  800f32:	e9 be 01 00 00       	jmp    8010f5 <fork+0x223>
	if (childpid < 0) {
		panic("fork sys_exofork error : %e\n", childpid);
	}
	int r;

	if (childpid == 0) {
  800f37:	bb 00 00 00 00       	mov    $0x0,%ebx
	} else {
		// map page to new environment
		// kernel page is already in new environment
		uint32_t i;
		for (i = 0; i != UTOP; i += PGSIZE) 
		if ((uvpd[PDX(i)] & PTE_P) && (uvpt[i / PGSIZE] & PTE_P) && (uvpt[i / PGSIZE] & PTE_U)) {
  800f3c:	89 d8                	mov    %ebx,%eax
  800f3e:	c1 e8 16             	shr    $0x16,%eax
  800f41:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800f48:	a8 01                	test   $0x1,%al
  800f4a:	0f 84 10 01 00 00    	je     801060 <fork+0x18e>
  800f50:	89 d8                	mov    %ebx,%eax
  800f52:	c1 e8 0c             	shr    $0xc,%eax
  800f55:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800f5c:	f6 c2 01             	test   $0x1,%dl
  800f5f:	0f 84 fb 00 00 00    	je     801060 <fork+0x18e>
  800f65:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800f6c:	f6 c2 04             	test   $0x4,%dl
  800f6f:	0f 84 eb 00 00 00    	je     801060 <fork+0x18e>
//
static int
duppage(envid_t envid, unsigned pn)
{
	// do not dup exception stack
	if (pn * PGSIZE == UXSTACKTOP - PGSIZE) return 0;
  800f75:	89 c6                	mov    %eax,%esi
  800f77:	c1 e6 0c             	shl    $0xc,%esi
  800f7a:	81 fe 00 f0 bf ee    	cmp    $0xeebff000,%esi
  800f80:	0f 84 da 00 00 00    	je     801060 <fork+0x18e>

	int r;
	void * addr = (void *)(pn * PGSIZE);
    if (uvpt[pn] & PTE_SHARE) {
  800f86:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800f8d:	f6 c6 04             	test   $0x4,%dh
  800f90:	74 37                	je     800fc9 <fork+0xf7>
        r = sys_page_map(0, addr, envid, addr, uvpt[pn] & PTE_SYSCALL);
  800f92:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f99:	83 ec 0c             	sub    $0xc,%esp
  800f9c:	25 07 0e 00 00       	and    $0xe07,%eax
  800fa1:	50                   	push   %eax
  800fa2:	56                   	push   %esi
  800fa3:	57                   	push   %edi
  800fa4:	56                   	push   %esi
  800fa5:	6a 00                	push   $0x0
  800fa7:	e8 10 fd ff ff       	call   800cbc <sys_page_map>
        if (r < 0) panic("duppage sys_page_map error : %e\n", r);
  800fac:	83 c4 20             	add    $0x20,%esp
  800faf:	85 c0                	test   %eax,%eax
  800fb1:	0f 89 a9 00 00 00    	jns    801060 <fork+0x18e>
  800fb7:	50                   	push   %eax
  800fb8:	68 5c 26 80 00       	push   $0x80265c
  800fbd:	6a 54                	push   $0x54
  800fbf:	68 10 27 80 00       	push   $0x802710
  800fc4:	e8 bf f1 ff ff       	call   800188 <_panic>
    } else
	if ((uvpt[pn] & PTE_W) || (uvpt[pn] & PTE_COW)) {
  800fc9:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800fd0:	f6 c2 02             	test   $0x2,%dl
  800fd3:	75 0c                	jne    800fe1 <fork+0x10f>
  800fd5:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800fdc:	f6 c4 08             	test   $0x8,%ah
  800fdf:	74 57                	je     801038 <fork+0x166>
		// cow
		r = sys_page_map(0, addr, envid, addr, PTE_COW | PTE_P | PTE_U);
  800fe1:	83 ec 0c             	sub    $0xc,%esp
  800fe4:	68 05 08 00 00       	push   $0x805
  800fe9:	56                   	push   %esi
  800fea:	57                   	push   %edi
  800feb:	56                   	push   %esi
  800fec:	6a 00                	push   $0x0
  800fee:	e8 c9 fc ff ff       	call   800cbc <sys_page_map>
		if (r < 0) panic("duppage sys_page_map error : %e\n", r);
  800ff3:	83 c4 20             	add    $0x20,%esp
  800ff6:	85 c0                	test   %eax,%eax
  800ff8:	79 12                	jns    80100c <fork+0x13a>
  800ffa:	50                   	push   %eax
  800ffb:	68 5c 26 80 00       	push   $0x80265c
  801000:	6a 59                	push   $0x59
  801002:	68 10 27 80 00       	push   $0x802710
  801007:	e8 7c f1 ff ff       	call   800188 <_panic>
		
		r = sys_page_map(0, addr, 0, addr, PTE_COW | PTE_P | PTE_U);
  80100c:	83 ec 0c             	sub    $0xc,%esp
  80100f:	68 05 08 00 00       	push   $0x805
  801014:	56                   	push   %esi
  801015:	6a 00                	push   $0x0
  801017:	56                   	push   %esi
  801018:	6a 00                	push   $0x0
  80101a:	e8 9d fc ff ff       	call   800cbc <sys_page_map>
		if (r < 0) panic("duppage sys_page_map error : %e\n", r);
  80101f:	83 c4 20             	add    $0x20,%esp
  801022:	85 c0                	test   %eax,%eax
  801024:	79 3a                	jns    801060 <fork+0x18e>
  801026:	50                   	push   %eax
  801027:	68 5c 26 80 00       	push   $0x80265c
  80102c:	6a 5c                	push   $0x5c
  80102e:	68 10 27 80 00       	push   $0x802710
  801033:	e8 50 f1 ff ff       	call   800188 <_panic>
	} else {
		// read only
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U);
  801038:	83 ec 0c             	sub    $0xc,%esp
  80103b:	6a 05                	push   $0x5
  80103d:	56                   	push   %esi
  80103e:	57                   	push   %edi
  80103f:	56                   	push   %esi
  801040:	6a 00                	push   $0x0
  801042:	e8 75 fc ff ff       	call   800cbc <sys_page_map>
		if (r < 0) panic("duppage sys_page_map error : %e\n", r);
  801047:	83 c4 20             	add    $0x20,%esp
  80104a:	85 c0                	test   %eax,%eax
  80104c:	79 12                	jns    801060 <fork+0x18e>
  80104e:	50                   	push   %eax
  80104f:	68 5c 26 80 00       	push   $0x80265c
  801054:	6a 60                	push   $0x60
  801056:	68 10 27 80 00       	push   $0x802710
  80105b:	e8 28 f1 ff ff       	call   800188 <_panic>
		return 0;
	} else {
		// map page to new environment
		// kernel page is already in new environment
		uint32_t i;
		for (i = 0; i != UTOP; i += PGSIZE) 
  801060:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801066:	81 fb 00 00 c0 ee    	cmp    $0xeec00000,%ebx
  80106c:	0f 85 ca fe ff ff    	jne    800f3c <fork+0x6a>
		if ((uvpd[PDX(i)] & PTE_P) && (uvpt[i / PGSIZE] & PTE_P) && (uvpt[i / PGSIZE] & PTE_U)) {
			duppage(childpid, i / PGSIZE);
		}

		// allocate exception stack
		r = sys_page_alloc(childpid, (void *)(UXSTACKTOP - PGSIZE), PTE_U | PTE_W | PTE_P);
  801072:	83 ec 04             	sub    $0x4,%esp
  801075:	6a 07                	push   $0x7
  801077:	68 00 f0 bf ee       	push   $0xeebff000
  80107c:	ff 75 e4             	pushl  -0x1c(%ebp)
  80107f:	e8 14 fc ff ff       	call   800c98 <sys_page_alloc>
		if (r < 0) panic("fork, sys_page_alloc user exception stack error : %e\n", r);
  801084:	83 c4 10             	add    $0x10,%esp
  801087:	85 c0                	test   %eax,%eax
  801089:	79 15                	jns    8010a0 <fork+0x1ce>
  80108b:	50                   	push   %eax
  80108c:	68 80 26 80 00       	push   $0x802680
  801091:	68 94 00 00 00       	push   $0x94
  801096:	68 10 27 80 00       	push   $0x802710
  80109b:	e8 e8 f0 ff ff       	call   800188 <_panic>

		// set user environment user page fault handler 
		extern void _pgfault_upcall(void);
		r = sys_env_set_pgfault_upcall(childpid, _pgfault_upcall);
  8010a0:	83 ec 08             	sub    $0x8,%esp
  8010a3:	68 3c 1e 80 00       	push   $0x801e3c
  8010a8:	ff 75 e4             	pushl  -0x1c(%ebp)
  8010ab:	e8 9b fc ff ff       	call   800d4b <sys_env_set_pgfault_upcall>
		if (r < 0) panic("fork, set pgfault upcall fail : %e\n", r);
  8010b0:	83 c4 10             	add    $0x10,%esp
  8010b3:	85 c0                	test   %eax,%eax
  8010b5:	79 15                	jns    8010cc <fork+0x1fa>
  8010b7:	50                   	push   %eax
  8010b8:	68 b8 26 80 00       	push   $0x8026b8
  8010bd:	68 99 00 00 00       	push   $0x99
  8010c2:	68 10 27 80 00       	push   $0x802710
  8010c7:	e8 bc f0 ff ff       	call   800188 <_panic>
		r = sys_set_priority(childpid, num);
		if (r < 0) panic("fork, set priority error\n");
		*/

		// mark the child as runnable and return
		r = sys_env_set_status(childpid, ENV_RUNNABLE);
  8010cc:	83 ec 08             	sub    $0x8,%esp
  8010cf:	6a 02                	push   $0x2
  8010d1:	ff 75 e4             	pushl  -0x1c(%ebp)
  8010d4:	e8 2c fc ff ff       	call   800d05 <sys_env_set_status>
		if (r < 0) panic("fork, set child process to ENV_RUNNABLE error : %e\n", r);
  8010d9:	83 c4 10             	add    $0x10,%esp
  8010dc:	85 c0                	test   %eax,%eax
  8010de:	79 15                	jns    8010f5 <fork+0x223>
  8010e0:	50                   	push   %eax
  8010e1:	68 dc 26 80 00       	push   $0x8026dc
  8010e6:	68 a4 00 00 00       	push   $0xa4
  8010eb:	68 10 27 80 00       	push   $0x802710
  8010f0:	e8 93 f0 ff ff       	call   800188 <_panic>
		// cprintf("fork father ok!")
		return childpid;
	}

	panic("fork not implemented");
}
  8010f5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8010f8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010fb:	5b                   	pop    %ebx
  8010fc:	5e                   	pop    %esi
  8010fd:	5f                   	pop    %edi
  8010fe:	c9                   	leave  
  8010ff:	c3                   	ret    

00801100 <sfork>:

// Challenge!
int
sfork(void)
{
  801100:	55                   	push   %ebp
  801101:	89 e5                	mov    %esp,%ebp
  801103:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  801106:	68 38 27 80 00       	push   $0x802738
  80110b:	68 b1 00 00 00       	push   $0xb1
  801110:	68 10 27 80 00       	push   $0x802710
  801115:	e8 6e f0 ff ff       	call   800188 <_panic>
	...

0080111c <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  80111c:	55                   	push   %ebp
  80111d:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80111f:	8b 45 08             	mov    0x8(%ebp),%eax
  801122:	05 00 00 00 30       	add    $0x30000000,%eax
  801127:	c1 e8 0c             	shr    $0xc,%eax
}
  80112a:	c9                   	leave  
  80112b:	c3                   	ret    

0080112c <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80112c:	55                   	push   %ebp
  80112d:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  80112f:	ff 75 08             	pushl  0x8(%ebp)
  801132:	e8 e5 ff ff ff       	call   80111c <fd2num>
  801137:	83 c4 04             	add    $0x4,%esp
  80113a:	05 20 00 0d 00       	add    $0xd0020,%eax
  80113f:	c1 e0 0c             	shl    $0xc,%eax
}
  801142:	c9                   	leave  
  801143:	c3                   	ret    

00801144 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801144:	55                   	push   %ebp
  801145:	89 e5                	mov    %esp,%ebp
  801147:	53                   	push   %ebx
  801148:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80114b:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  801150:	a8 01                	test   $0x1,%al
  801152:	74 34                	je     801188 <fd_alloc+0x44>
  801154:	a1 00 00 74 ef       	mov    0xef740000,%eax
  801159:	a8 01                	test   $0x1,%al
  80115b:	74 32                	je     80118f <fd_alloc+0x4b>
  80115d:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
  801162:	89 c1                	mov    %eax,%ecx
  801164:	89 c2                	mov    %eax,%edx
  801166:	c1 ea 16             	shr    $0x16,%edx
  801169:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801170:	f6 c2 01             	test   $0x1,%dl
  801173:	74 1f                	je     801194 <fd_alloc+0x50>
  801175:	89 c2                	mov    %eax,%edx
  801177:	c1 ea 0c             	shr    $0xc,%edx
  80117a:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801181:	f6 c2 01             	test   $0x1,%dl
  801184:	75 17                	jne    80119d <fd_alloc+0x59>
  801186:	eb 0c                	jmp    801194 <fd_alloc+0x50>
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  801188:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
  80118d:	eb 05                	jmp    801194 <fd_alloc+0x50>
  80118f:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
  801194:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  801196:	b8 00 00 00 00       	mov    $0x0,%eax
  80119b:	eb 17                	jmp    8011b4 <fd_alloc+0x70>
  80119d:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8011a2:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8011a7:	75 b9                	jne    801162 <fd_alloc+0x1e>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8011a9:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  8011af:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8011b4:	5b                   	pop    %ebx
  8011b5:	c9                   	leave  
  8011b6:	c3                   	ret    

008011b7 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8011b7:	55                   	push   %ebp
  8011b8:	89 e5                	mov    %esp,%ebp
  8011ba:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8011bd:	83 f8 1f             	cmp    $0x1f,%eax
  8011c0:	77 36                	ja     8011f8 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8011c2:	05 00 00 0d 00       	add    $0xd0000,%eax
  8011c7:	c1 e0 0c             	shl    $0xc,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8011ca:	89 c2                	mov    %eax,%edx
  8011cc:	c1 ea 16             	shr    $0x16,%edx
  8011cf:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8011d6:	f6 c2 01             	test   $0x1,%dl
  8011d9:	74 24                	je     8011ff <fd_lookup+0x48>
  8011db:	89 c2                	mov    %eax,%edx
  8011dd:	c1 ea 0c             	shr    $0xc,%edx
  8011e0:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8011e7:	f6 c2 01             	test   $0x1,%dl
  8011ea:	74 1a                	je     801206 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8011ec:	8b 55 0c             	mov    0xc(%ebp),%edx
  8011ef:	89 02                	mov    %eax,(%edx)
	return 0;
  8011f1:	b8 00 00 00 00       	mov    $0x0,%eax
  8011f6:	eb 13                	jmp    80120b <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8011f8:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8011fd:	eb 0c                	jmp    80120b <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8011ff:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801204:	eb 05                	jmp    80120b <fd_lookup+0x54>
  801206:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  80120b:	c9                   	leave  
  80120c:	c3                   	ret    

0080120d <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80120d:	55                   	push   %ebp
  80120e:	89 e5                	mov    %esp,%ebp
  801210:	53                   	push   %ebx
  801211:	83 ec 04             	sub    $0x4,%esp
  801214:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801217:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  80121a:	39 0d 04 30 80 00    	cmp    %ecx,0x803004
  801220:	74 0d                	je     80122f <dev_lookup+0x22>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801222:	b8 00 00 00 00       	mov    $0x0,%eax
  801227:	eb 14                	jmp    80123d <dev_lookup+0x30>
		if (devtab[i]->dev_id == dev_id) {
  801229:	39 0a                	cmp    %ecx,(%edx)
  80122b:	75 10                	jne    80123d <dev_lookup+0x30>
  80122d:	eb 05                	jmp    801234 <dev_lookup+0x27>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80122f:	ba 04 30 80 00       	mov    $0x803004,%edx
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
  801234:	89 13                	mov    %edx,(%ebx)
			return 0;
  801236:	b8 00 00 00 00       	mov    $0x0,%eax
  80123b:	eb 31                	jmp    80126e <dev_lookup+0x61>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80123d:	40                   	inc    %eax
  80123e:	8b 14 85 cc 27 80 00 	mov    0x8027cc(,%eax,4),%edx
  801245:	85 d2                	test   %edx,%edx
  801247:	75 e0                	jne    801229 <dev_lookup+0x1c>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801249:	a1 08 40 80 00       	mov    0x804008,%eax
  80124e:	8b 40 48             	mov    0x48(%eax),%eax
  801251:	83 ec 04             	sub    $0x4,%esp
  801254:	51                   	push   %ecx
  801255:	50                   	push   %eax
  801256:	68 50 27 80 00       	push   $0x802750
  80125b:	e8 00 f0 ff ff       	call   800260 <cprintf>
	*dev = 0;
  801260:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  801266:	83 c4 10             	add    $0x10,%esp
  801269:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80126e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801271:	c9                   	leave  
  801272:	c3                   	ret    

00801273 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801273:	55                   	push   %ebp
  801274:	89 e5                	mov    %esp,%ebp
  801276:	56                   	push   %esi
  801277:	53                   	push   %ebx
  801278:	83 ec 20             	sub    $0x20,%esp
  80127b:	8b 75 08             	mov    0x8(%ebp),%esi
  80127e:	8a 45 0c             	mov    0xc(%ebp),%al
  801281:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801284:	56                   	push   %esi
  801285:	e8 92 fe ff ff       	call   80111c <fd2num>
  80128a:	8d 55 f4             	lea    -0xc(%ebp),%edx
  80128d:	89 14 24             	mov    %edx,(%esp)
  801290:	50                   	push   %eax
  801291:	e8 21 ff ff ff       	call   8011b7 <fd_lookup>
  801296:	89 c3                	mov    %eax,%ebx
  801298:	83 c4 08             	add    $0x8,%esp
  80129b:	85 c0                	test   %eax,%eax
  80129d:	78 05                	js     8012a4 <fd_close+0x31>
	    || fd != fd2)
  80129f:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8012a2:	74 0d                	je     8012b1 <fd_close+0x3e>
		return (must_exist ? r : 0);
  8012a4:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  8012a8:	75 48                	jne    8012f2 <fd_close+0x7f>
  8012aa:	bb 00 00 00 00       	mov    $0x0,%ebx
  8012af:	eb 41                	jmp    8012f2 <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8012b1:	83 ec 08             	sub    $0x8,%esp
  8012b4:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012b7:	50                   	push   %eax
  8012b8:	ff 36                	pushl  (%esi)
  8012ba:	e8 4e ff ff ff       	call   80120d <dev_lookup>
  8012bf:	89 c3                	mov    %eax,%ebx
  8012c1:	83 c4 10             	add    $0x10,%esp
  8012c4:	85 c0                	test   %eax,%eax
  8012c6:	78 1c                	js     8012e4 <fd_close+0x71>
		if (dev->dev_close)
  8012c8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012cb:	8b 40 10             	mov    0x10(%eax),%eax
  8012ce:	85 c0                	test   %eax,%eax
  8012d0:	74 0d                	je     8012df <fd_close+0x6c>
			r = (*dev->dev_close)(fd);
  8012d2:	83 ec 0c             	sub    $0xc,%esp
  8012d5:	56                   	push   %esi
  8012d6:	ff d0                	call   *%eax
  8012d8:	89 c3                	mov    %eax,%ebx
  8012da:	83 c4 10             	add    $0x10,%esp
  8012dd:	eb 05                	jmp    8012e4 <fd_close+0x71>
		else
			r = 0;
  8012df:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8012e4:	83 ec 08             	sub    $0x8,%esp
  8012e7:	56                   	push   %esi
  8012e8:	6a 00                	push   $0x0
  8012ea:	e8 f3 f9 ff ff       	call   800ce2 <sys_page_unmap>
	return r;
  8012ef:	83 c4 10             	add    $0x10,%esp
}
  8012f2:	89 d8                	mov    %ebx,%eax
  8012f4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8012f7:	5b                   	pop    %ebx
  8012f8:	5e                   	pop    %esi
  8012f9:	c9                   	leave  
  8012fa:	c3                   	ret    

008012fb <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8012fb:	55                   	push   %ebp
  8012fc:	89 e5                	mov    %esp,%ebp
  8012fe:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801301:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801304:	50                   	push   %eax
  801305:	ff 75 08             	pushl  0x8(%ebp)
  801308:	e8 aa fe ff ff       	call   8011b7 <fd_lookup>
  80130d:	83 c4 08             	add    $0x8,%esp
  801310:	85 c0                	test   %eax,%eax
  801312:	78 10                	js     801324 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801314:	83 ec 08             	sub    $0x8,%esp
  801317:	6a 01                	push   $0x1
  801319:	ff 75 f4             	pushl  -0xc(%ebp)
  80131c:	e8 52 ff ff ff       	call   801273 <fd_close>
  801321:	83 c4 10             	add    $0x10,%esp
}
  801324:	c9                   	leave  
  801325:	c3                   	ret    

00801326 <close_all>:

void
close_all(void)
{
  801326:	55                   	push   %ebp
  801327:	89 e5                	mov    %esp,%ebp
  801329:	53                   	push   %ebx
  80132a:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80132d:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801332:	83 ec 0c             	sub    $0xc,%esp
  801335:	53                   	push   %ebx
  801336:	e8 c0 ff ff ff       	call   8012fb <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80133b:	43                   	inc    %ebx
  80133c:	83 c4 10             	add    $0x10,%esp
  80133f:	83 fb 20             	cmp    $0x20,%ebx
  801342:	75 ee                	jne    801332 <close_all+0xc>
		close(i);
}
  801344:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801347:	c9                   	leave  
  801348:	c3                   	ret    

00801349 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801349:	55                   	push   %ebp
  80134a:	89 e5                	mov    %esp,%ebp
  80134c:	57                   	push   %edi
  80134d:	56                   	push   %esi
  80134e:	53                   	push   %ebx
  80134f:	83 ec 2c             	sub    $0x2c,%esp
  801352:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801355:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801358:	50                   	push   %eax
  801359:	ff 75 08             	pushl  0x8(%ebp)
  80135c:	e8 56 fe ff ff       	call   8011b7 <fd_lookup>
  801361:	89 c3                	mov    %eax,%ebx
  801363:	83 c4 08             	add    $0x8,%esp
  801366:	85 c0                	test   %eax,%eax
  801368:	0f 88 c0 00 00 00    	js     80142e <dup+0xe5>
		return r;
	close(newfdnum);
  80136e:	83 ec 0c             	sub    $0xc,%esp
  801371:	57                   	push   %edi
  801372:	e8 84 ff ff ff       	call   8012fb <close>

	newfd = INDEX2FD(newfdnum);
  801377:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  80137d:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  801380:	83 c4 04             	add    $0x4,%esp
  801383:	ff 75 e4             	pushl  -0x1c(%ebp)
  801386:	e8 a1 fd ff ff       	call   80112c <fd2data>
  80138b:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  80138d:	89 34 24             	mov    %esi,(%esp)
  801390:	e8 97 fd ff ff       	call   80112c <fd2data>
  801395:	83 c4 10             	add    $0x10,%esp
  801398:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80139b:	89 d8                	mov    %ebx,%eax
  80139d:	c1 e8 16             	shr    $0x16,%eax
  8013a0:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8013a7:	a8 01                	test   $0x1,%al
  8013a9:	74 37                	je     8013e2 <dup+0x99>
  8013ab:	89 d8                	mov    %ebx,%eax
  8013ad:	c1 e8 0c             	shr    $0xc,%eax
  8013b0:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8013b7:	f6 c2 01             	test   $0x1,%dl
  8013ba:	74 26                	je     8013e2 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8013bc:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8013c3:	83 ec 0c             	sub    $0xc,%esp
  8013c6:	25 07 0e 00 00       	and    $0xe07,%eax
  8013cb:	50                   	push   %eax
  8013cc:	ff 75 d4             	pushl  -0x2c(%ebp)
  8013cf:	6a 00                	push   $0x0
  8013d1:	53                   	push   %ebx
  8013d2:	6a 00                	push   $0x0
  8013d4:	e8 e3 f8 ff ff       	call   800cbc <sys_page_map>
  8013d9:	89 c3                	mov    %eax,%ebx
  8013db:	83 c4 20             	add    $0x20,%esp
  8013de:	85 c0                	test   %eax,%eax
  8013e0:	78 2d                	js     80140f <dup+0xc6>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8013e2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8013e5:	89 c2                	mov    %eax,%edx
  8013e7:	c1 ea 0c             	shr    $0xc,%edx
  8013ea:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8013f1:	83 ec 0c             	sub    $0xc,%esp
  8013f4:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  8013fa:	52                   	push   %edx
  8013fb:	56                   	push   %esi
  8013fc:	6a 00                	push   $0x0
  8013fe:	50                   	push   %eax
  8013ff:	6a 00                	push   $0x0
  801401:	e8 b6 f8 ff ff       	call   800cbc <sys_page_map>
  801406:	89 c3                	mov    %eax,%ebx
  801408:	83 c4 20             	add    $0x20,%esp
  80140b:	85 c0                	test   %eax,%eax
  80140d:	79 1d                	jns    80142c <dup+0xe3>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80140f:	83 ec 08             	sub    $0x8,%esp
  801412:	56                   	push   %esi
  801413:	6a 00                	push   $0x0
  801415:	e8 c8 f8 ff ff       	call   800ce2 <sys_page_unmap>
	sys_page_unmap(0, nva);
  80141a:	83 c4 08             	add    $0x8,%esp
  80141d:	ff 75 d4             	pushl  -0x2c(%ebp)
  801420:	6a 00                	push   $0x0
  801422:	e8 bb f8 ff ff       	call   800ce2 <sys_page_unmap>
	return r;
  801427:	83 c4 10             	add    $0x10,%esp
  80142a:	eb 02                	jmp    80142e <dup+0xe5>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  80142c:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  80142e:	89 d8                	mov    %ebx,%eax
  801430:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801433:	5b                   	pop    %ebx
  801434:	5e                   	pop    %esi
  801435:	5f                   	pop    %edi
  801436:	c9                   	leave  
  801437:	c3                   	ret    

00801438 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801438:	55                   	push   %ebp
  801439:	89 e5                	mov    %esp,%ebp
  80143b:	53                   	push   %ebx
  80143c:	83 ec 14             	sub    $0x14,%esp
  80143f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801442:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801445:	50                   	push   %eax
  801446:	53                   	push   %ebx
  801447:	e8 6b fd ff ff       	call   8011b7 <fd_lookup>
  80144c:	83 c4 08             	add    $0x8,%esp
  80144f:	85 c0                	test   %eax,%eax
  801451:	78 67                	js     8014ba <read+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801453:	83 ec 08             	sub    $0x8,%esp
  801456:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801459:	50                   	push   %eax
  80145a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80145d:	ff 30                	pushl  (%eax)
  80145f:	e8 a9 fd ff ff       	call   80120d <dev_lookup>
  801464:	83 c4 10             	add    $0x10,%esp
  801467:	85 c0                	test   %eax,%eax
  801469:	78 4f                	js     8014ba <read+0x82>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80146b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80146e:	8b 50 08             	mov    0x8(%eax),%edx
  801471:	83 e2 03             	and    $0x3,%edx
  801474:	83 fa 01             	cmp    $0x1,%edx
  801477:	75 21                	jne    80149a <read+0x62>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801479:	a1 08 40 80 00       	mov    0x804008,%eax
  80147e:	8b 40 48             	mov    0x48(%eax),%eax
  801481:	83 ec 04             	sub    $0x4,%esp
  801484:	53                   	push   %ebx
  801485:	50                   	push   %eax
  801486:	68 91 27 80 00       	push   $0x802791
  80148b:	e8 d0 ed ff ff       	call   800260 <cprintf>
		return -E_INVAL;
  801490:	83 c4 10             	add    $0x10,%esp
  801493:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801498:	eb 20                	jmp    8014ba <read+0x82>
	}
	if (!dev->dev_read)
  80149a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80149d:	8b 52 08             	mov    0x8(%edx),%edx
  8014a0:	85 d2                	test   %edx,%edx
  8014a2:	74 11                	je     8014b5 <read+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8014a4:	83 ec 04             	sub    $0x4,%esp
  8014a7:	ff 75 10             	pushl  0x10(%ebp)
  8014aa:	ff 75 0c             	pushl  0xc(%ebp)
  8014ad:	50                   	push   %eax
  8014ae:	ff d2                	call   *%edx
  8014b0:	83 c4 10             	add    $0x10,%esp
  8014b3:	eb 05                	jmp    8014ba <read+0x82>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8014b5:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  8014ba:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014bd:	c9                   	leave  
  8014be:	c3                   	ret    

008014bf <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8014bf:	55                   	push   %ebp
  8014c0:	89 e5                	mov    %esp,%ebp
  8014c2:	57                   	push   %edi
  8014c3:	56                   	push   %esi
  8014c4:	53                   	push   %ebx
  8014c5:	83 ec 0c             	sub    $0xc,%esp
  8014c8:	8b 7d 08             	mov    0x8(%ebp),%edi
  8014cb:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8014ce:	85 f6                	test   %esi,%esi
  8014d0:	74 31                	je     801503 <readn+0x44>
  8014d2:	b8 00 00 00 00       	mov    $0x0,%eax
  8014d7:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = read(fdnum, (char*)buf + tot, n - tot);
  8014dc:	83 ec 04             	sub    $0x4,%esp
  8014df:	89 f2                	mov    %esi,%edx
  8014e1:	29 c2                	sub    %eax,%edx
  8014e3:	52                   	push   %edx
  8014e4:	03 45 0c             	add    0xc(%ebp),%eax
  8014e7:	50                   	push   %eax
  8014e8:	57                   	push   %edi
  8014e9:	e8 4a ff ff ff       	call   801438 <read>
		if (m < 0)
  8014ee:	83 c4 10             	add    $0x10,%esp
  8014f1:	85 c0                	test   %eax,%eax
  8014f3:	78 17                	js     80150c <readn+0x4d>
			return m;
		if (m == 0)
  8014f5:	85 c0                	test   %eax,%eax
  8014f7:	74 11                	je     80150a <readn+0x4b>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8014f9:	01 c3                	add    %eax,%ebx
  8014fb:	89 d8                	mov    %ebx,%eax
  8014fd:	39 f3                	cmp    %esi,%ebx
  8014ff:	72 db                	jb     8014dc <readn+0x1d>
  801501:	eb 09                	jmp    80150c <readn+0x4d>
  801503:	b8 00 00 00 00       	mov    $0x0,%eax
  801508:	eb 02                	jmp    80150c <readn+0x4d>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  80150a:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  80150c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80150f:	5b                   	pop    %ebx
  801510:	5e                   	pop    %esi
  801511:	5f                   	pop    %edi
  801512:	c9                   	leave  
  801513:	c3                   	ret    

00801514 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801514:	55                   	push   %ebp
  801515:	89 e5                	mov    %esp,%ebp
  801517:	53                   	push   %ebx
  801518:	83 ec 14             	sub    $0x14,%esp
  80151b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80151e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801521:	50                   	push   %eax
  801522:	53                   	push   %ebx
  801523:	e8 8f fc ff ff       	call   8011b7 <fd_lookup>
  801528:	83 c4 08             	add    $0x8,%esp
  80152b:	85 c0                	test   %eax,%eax
  80152d:	78 62                	js     801591 <write+0x7d>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80152f:	83 ec 08             	sub    $0x8,%esp
  801532:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801535:	50                   	push   %eax
  801536:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801539:	ff 30                	pushl  (%eax)
  80153b:	e8 cd fc ff ff       	call   80120d <dev_lookup>
  801540:	83 c4 10             	add    $0x10,%esp
  801543:	85 c0                	test   %eax,%eax
  801545:	78 4a                	js     801591 <write+0x7d>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801547:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80154a:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80154e:	75 21                	jne    801571 <write+0x5d>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801550:	a1 08 40 80 00       	mov    0x804008,%eax
  801555:	8b 40 48             	mov    0x48(%eax),%eax
  801558:	83 ec 04             	sub    $0x4,%esp
  80155b:	53                   	push   %ebx
  80155c:	50                   	push   %eax
  80155d:	68 ad 27 80 00       	push   $0x8027ad
  801562:	e8 f9 ec ff ff       	call   800260 <cprintf>
		return -E_INVAL;
  801567:	83 c4 10             	add    $0x10,%esp
  80156a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80156f:	eb 20                	jmp    801591 <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801571:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801574:	8b 52 0c             	mov    0xc(%edx),%edx
  801577:	85 d2                	test   %edx,%edx
  801579:	74 11                	je     80158c <write+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80157b:	83 ec 04             	sub    $0x4,%esp
  80157e:	ff 75 10             	pushl  0x10(%ebp)
  801581:	ff 75 0c             	pushl  0xc(%ebp)
  801584:	50                   	push   %eax
  801585:	ff d2                	call   *%edx
  801587:	83 c4 10             	add    $0x10,%esp
  80158a:	eb 05                	jmp    801591 <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80158c:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  801591:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801594:	c9                   	leave  
  801595:	c3                   	ret    

00801596 <seek>:

int
seek(int fdnum, off_t offset)
{
  801596:	55                   	push   %ebp
  801597:	89 e5                	mov    %esp,%ebp
  801599:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80159c:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80159f:	50                   	push   %eax
  8015a0:	ff 75 08             	pushl  0x8(%ebp)
  8015a3:	e8 0f fc ff ff       	call   8011b7 <fd_lookup>
  8015a8:	83 c4 08             	add    $0x8,%esp
  8015ab:	85 c0                	test   %eax,%eax
  8015ad:	78 0e                	js     8015bd <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8015af:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8015b2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8015b5:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8015b8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8015bd:	c9                   	leave  
  8015be:	c3                   	ret    

008015bf <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8015bf:	55                   	push   %ebp
  8015c0:	89 e5                	mov    %esp,%ebp
  8015c2:	53                   	push   %ebx
  8015c3:	83 ec 14             	sub    $0x14,%esp
  8015c6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015c9:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015cc:	50                   	push   %eax
  8015cd:	53                   	push   %ebx
  8015ce:	e8 e4 fb ff ff       	call   8011b7 <fd_lookup>
  8015d3:	83 c4 08             	add    $0x8,%esp
  8015d6:	85 c0                	test   %eax,%eax
  8015d8:	78 5f                	js     801639 <ftruncate+0x7a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015da:	83 ec 08             	sub    $0x8,%esp
  8015dd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015e0:	50                   	push   %eax
  8015e1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015e4:	ff 30                	pushl  (%eax)
  8015e6:	e8 22 fc ff ff       	call   80120d <dev_lookup>
  8015eb:	83 c4 10             	add    $0x10,%esp
  8015ee:	85 c0                	test   %eax,%eax
  8015f0:	78 47                	js     801639 <ftruncate+0x7a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8015f2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015f5:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8015f9:	75 21                	jne    80161c <ftruncate+0x5d>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8015fb:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801600:	8b 40 48             	mov    0x48(%eax),%eax
  801603:	83 ec 04             	sub    $0x4,%esp
  801606:	53                   	push   %ebx
  801607:	50                   	push   %eax
  801608:	68 70 27 80 00       	push   $0x802770
  80160d:	e8 4e ec ff ff       	call   800260 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801612:	83 c4 10             	add    $0x10,%esp
  801615:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80161a:	eb 1d                	jmp    801639 <ftruncate+0x7a>
	}
	if (!dev->dev_trunc)
  80161c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80161f:	8b 52 18             	mov    0x18(%edx),%edx
  801622:	85 d2                	test   %edx,%edx
  801624:	74 0e                	je     801634 <ftruncate+0x75>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801626:	83 ec 08             	sub    $0x8,%esp
  801629:	ff 75 0c             	pushl  0xc(%ebp)
  80162c:	50                   	push   %eax
  80162d:	ff d2                	call   *%edx
  80162f:	83 c4 10             	add    $0x10,%esp
  801632:	eb 05                	jmp    801639 <ftruncate+0x7a>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801634:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  801639:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80163c:	c9                   	leave  
  80163d:	c3                   	ret    

0080163e <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80163e:	55                   	push   %ebp
  80163f:	89 e5                	mov    %esp,%ebp
  801641:	53                   	push   %ebx
  801642:	83 ec 14             	sub    $0x14,%esp
  801645:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801648:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80164b:	50                   	push   %eax
  80164c:	ff 75 08             	pushl  0x8(%ebp)
  80164f:	e8 63 fb ff ff       	call   8011b7 <fd_lookup>
  801654:	83 c4 08             	add    $0x8,%esp
  801657:	85 c0                	test   %eax,%eax
  801659:	78 52                	js     8016ad <fstat+0x6f>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80165b:	83 ec 08             	sub    $0x8,%esp
  80165e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801661:	50                   	push   %eax
  801662:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801665:	ff 30                	pushl  (%eax)
  801667:	e8 a1 fb ff ff       	call   80120d <dev_lookup>
  80166c:	83 c4 10             	add    $0x10,%esp
  80166f:	85 c0                	test   %eax,%eax
  801671:	78 3a                	js     8016ad <fstat+0x6f>
		return r;
	if (!dev->dev_stat)
  801673:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801676:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80167a:	74 2c                	je     8016a8 <fstat+0x6a>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80167c:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80167f:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801686:	00 00 00 
	stat->st_isdir = 0;
  801689:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801690:	00 00 00 
	stat->st_dev = dev;
  801693:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801699:	83 ec 08             	sub    $0x8,%esp
  80169c:	53                   	push   %ebx
  80169d:	ff 75 f0             	pushl  -0x10(%ebp)
  8016a0:	ff 50 14             	call   *0x14(%eax)
  8016a3:	83 c4 10             	add    $0x10,%esp
  8016a6:	eb 05                	jmp    8016ad <fstat+0x6f>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8016a8:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8016ad:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016b0:	c9                   	leave  
  8016b1:	c3                   	ret    

008016b2 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8016b2:	55                   	push   %ebp
  8016b3:	89 e5                	mov    %esp,%ebp
  8016b5:	56                   	push   %esi
  8016b6:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8016b7:	83 ec 08             	sub    $0x8,%esp
  8016ba:	6a 00                	push   $0x0
  8016bc:	ff 75 08             	pushl  0x8(%ebp)
  8016bf:	e8 78 01 00 00       	call   80183c <open>
  8016c4:	89 c3                	mov    %eax,%ebx
  8016c6:	83 c4 10             	add    $0x10,%esp
  8016c9:	85 c0                	test   %eax,%eax
  8016cb:	78 1b                	js     8016e8 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8016cd:	83 ec 08             	sub    $0x8,%esp
  8016d0:	ff 75 0c             	pushl  0xc(%ebp)
  8016d3:	50                   	push   %eax
  8016d4:	e8 65 ff ff ff       	call   80163e <fstat>
  8016d9:	89 c6                	mov    %eax,%esi
	close(fd);
  8016db:	89 1c 24             	mov    %ebx,(%esp)
  8016de:	e8 18 fc ff ff       	call   8012fb <close>
	return r;
  8016e3:	83 c4 10             	add    $0x10,%esp
  8016e6:	89 f3                	mov    %esi,%ebx
}
  8016e8:	89 d8                	mov    %ebx,%eax
  8016ea:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8016ed:	5b                   	pop    %ebx
  8016ee:	5e                   	pop    %esi
  8016ef:	c9                   	leave  
  8016f0:	c3                   	ret    
  8016f1:	00 00                	add    %al,(%eax)
	...

008016f4 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8016f4:	55                   	push   %ebp
  8016f5:	89 e5                	mov    %esp,%ebp
  8016f7:	56                   	push   %esi
  8016f8:	53                   	push   %ebx
  8016f9:	89 c3                	mov    %eax,%ebx
  8016fb:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  8016fd:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801704:	75 12                	jne    801718 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801706:	83 ec 0c             	sub    $0xc,%esp
  801709:	6a 01                	push   $0x1
  80170b:	e8 1e 08 00 00       	call   801f2e <ipc_find_env>
  801710:	a3 00 40 80 00       	mov    %eax,0x804000
  801715:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801718:	6a 07                	push   $0x7
  80171a:	68 00 50 80 00       	push   $0x805000
  80171f:	53                   	push   %ebx
  801720:	ff 35 00 40 80 00    	pushl  0x804000
  801726:	e8 ae 07 00 00       	call   801ed9 <ipc_send>
	
	return ipc_recv(NULL, dstva, NULL);
  80172b:	83 c4 0c             	add    $0xc,%esp
  80172e:	6a 00                	push   $0x0
  801730:	56                   	push   %esi
  801731:	6a 00                	push   $0x0
  801733:	e8 2c 07 00 00       	call   801e64 <ipc_recv>
}
  801738:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80173b:	5b                   	pop    %ebx
  80173c:	5e                   	pop    %esi
  80173d:	c9                   	leave  
  80173e:	c3                   	ret    

0080173f <devfile_stat>:
}


static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80173f:	55                   	push   %ebp
  801740:	89 e5                	mov    %esp,%ebp
  801742:	53                   	push   %ebx
  801743:	83 ec 04             	sub    $0x4,%esp
  801746:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801749:	8b 45 08             	mov    0x8(%ebp),%eax
  80174c:	8b 40 0c             	mov    0xc(%eax),%eax
  80174f:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0) {
  801754:	ba 00 00 00 00       	mov    $0x0,%edx
  801759:	b8 05 00 00 00       	mov    $0x5,%eax
  80175e:	e8 91 ff ff ff       	call   8016f4 <fsipc>
  801763:	85 c0                	test   %eax,%eax
  801765:	78 2c                	js     801793 <devfile_stat+0x54>
		return r;
	}
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801767:	83 ec 08             	sub    $0x8,%esp
  80176a:	68 00 50 80 00       	push   $0x805000
  80176f:	53                   	push   %ebx
  801770:	e8 a1 f0 ff ff       	call   800816 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801775:	a1 80 50 80 00       	mov    0x805080,%eax
  80177a:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801780:	a1 84 50 80 00       	mov    0x805084,%eax
  801785:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80178b:	83 c4 10             	add    $0x10,%esp
  80178e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801793:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801796:	c9                   	leave  
  801797:	c3                   	ret    

00801798 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801798:	55                   	push   %ebp
  801799:	89 e5                	mov    %esp,%ebp
  80179b:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80179e:	8b 45 08             	mov    0x8(%ebp),%eax
  8017a1:	8b 40 0c             	mov    0xc(%eax),%eax
  8017a4:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8017a9:	ba 00 00 00 00       	mov    $0x0,%edx
  8017ae:	b8 06 00 00 00       	mov    $0x6,%eax
  8017b3:	e8 3c ff ff ff       	call   8016f4 <fsipc>
}
  8017b8:	c9                   	leave  
  8017b9:	c3                   	ret    

008017ba <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8017ba:	55                   	push   %ebp
  8017bb:	89 e5                	mov    %esp,%ebp
  8017bd:	56                   	push   %esi
  8017be:	53                   	push   %ebx
  8017bf:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8017c2:	8b 45 08             	mov    0x8(%ebp),%eax
  8017c5:	8b 40 0c             	mov    0xc(%eax),%eax
  8017c8:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8017cd:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8017d3:	ba 00 00 00 00       	mov    $0x0,%edx
  8017d8:	b8 03 00 00 00       	mov    $0x3,%eax
  8017dd:	e8 12 ff ff ff       	call   8016f4 <fsipc>
  8017e2:	89 c3                	mov    %eax,%ebx
  8017e4:	85 c0                	test   %eax,%eax
  8017e6:	78 4b                	js     801833 <devfile_read+0x79>
		return r;
	assert(r <= n);
  8017e8:	39 c6                	cmp    %eax,%esi
  8017ea:	73 16                	jae    801802 <devfile_read+0x48>
  8017ec:	68 dc 27 80 00       	push   $0x8027dc
  8017f1:	68 e3 27 80 00       	push   $0x8027e3
  8017f6:	6a 7d                	push   $0x7d
  8017f8:	68 f8 27 80 00       	push   $0x8027f8
  8017fd:	e8 86 e9 ff ff       	call   800188 <_panic>
	assert(r <= PGSIZE);
  801802:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801807:	7e 16                	jle    80181f <devfile_read+0x65>
  801809:	68 03 28 80 00       	push   $0x802803
  80180e:	68 e3 27 80 00       	push   $0x8027e3
  801813:	6a 7e                	push   $0x7e
  801815:	68 f8 27 80 00       	push   $0x8027f8
  80181a:	e8 69 e9 ff ff       	call   800188 <_panic>
	memmove(buf, &fsipcbuf, r);
  80181f:	83 ec 04             	sub    $0x4,%esp
  801822:	50                   	push   %eax
  801823:	68 00 50 80 00       	push   $0x805000
  801828:	ff 75 0c             	pushl  0xc(%ebp)
  80182b:	e8 a7 f1 ff ff       	call   8009d7 <memmove>
	return r;
  801830:	83 c4 10             	add    $0x10,%esp
}
  801833:	89 d8                	mov    %ebx,%eax
  801835:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801838:	5b                   	pop    %ebx
  801839:	5e                   	pop    %esi
  80183a:	c9                   	leave  
  80183b:	c3                   	ret    

0080183c <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  80183c:	55                   	push   %ebp
  80183d:	89 e5                	mov    %esp,%ebp
  80183f:	56                   	push   %esi
  801840:	53                   	push   %ebx
  801841:	83 ec 1c             	sub    $0x1c,%esp
  801844:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801847:	56                   	push   %esi
  801848:	e8 77 ef ff ff       	call   8007c4 <strlen>
  80184d:	83 c4 10             	add    $0x10,%esp
  801850:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801855:	7f 65                	jg     8018bc <open+0x80>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801857:	83 ec 0c             	sub    $0xc,%esp
  80185a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80185d:	50                   	push   %eax
  80185e:	e8 e1 f8 ff ff       	call   801144 <fd_alloc>
  801863:	89 c3                	mov    %eax,%ebx
  801865:	83 c4 10             	add    $0x10,%esp
  801868:	85 c0                	test   %eax,%eax
  80186a:	78 55                	js     8018c1 <open+0x85>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  80186c:	83 ec 08             	sub    $0x8,%esp
  80186f:	56                   	push   %esi
  801870:	68 00 50 80 00       	push   $0x805000
  801875:	e8 9c ef ff ff       	call   800816 <strcpy>
	fsipcbuf.open.req_omode = mode;
  80187a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80187d:	a3 00 54 80 00       	mov    %eax,0x805400



	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801882:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801885:	b8 01 00 00 00       	mov    $0x1,%eax
  80188a:	e8 65 fe ff ff       	call   8016f4 <fsipc>
  80188f:	89 c3                	mov    %eax,%ebx
  801891:	83 c4 10             	add    $0x10,%esp
  801894:	85 c0                	test   %eax,%eax
  801896:	79 12                	jns    8018aa <open+0x6e>
		fd_close(fd, 0);
  801898:	83 ec 08             	sub    $0x8,%esp
  80189b:	6a 00                	push   $0x0
  80189d:	ff 75 f4             	pushl  -0xc(%ebp)
  8018a0:	e8 ce f9 ff ff       	call   801273 <fd_close>
		return r;
  8018a5:	83 c4 10             	add    $0x10,%esp
  8018a8:	eb 17                	jmp    8018c1 <open+0x85>
	}

	return fd2num(fd);
  8018aa:	83 ec 0c             	sub    $0xc,%esp
  8018ad:	ff 75 f4             	pushl  -0xc(%ebp)
  8018b0:	e8 67 f8 ff ff       	call   80111c <fd2num>
  8018b5:	89 c3                	mov    %eax,%ebx
  8018b7:	83 c4 10             	add    $0x10,%esp
  8018ba:	eb 05                	jmp    8018c1 <open+0x85>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8018bc:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8018c1:	89 d8                	mov    %ebx,%eax
  8018c3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018c6:	5b                   	pop    %ebx
  8018c7:	5e                   	pop    %esi
  8018c8:	c9                   	leave  
  8018c9:	c3                   	ret    
	...

008018cc <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8018cc:	55                   	push   %ebp
  8018cd:	89 e5                	mov    %esp,%ebp
  8018cf:	56                   	push   %esi
  8018d0:	53                   	push   %ebx
  8018d1:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8018d4:	83 ec 0c             	sub    $0xc,%esp
  8018d7:	ff 75 08             	pushl  0x8(%ebp)
  8018da:	e8 4d f8 ff ff       	call   80112c <fd2data>
  8018df:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  8018e1:	83 c4 08             	add    $0x8,%esp
  8018e4:	68 0f 28 80 00       	push   $0x80280f
  8018e9:	56                   	push   %esi
  8018ea:	e8 27 ef ff ff       	call   800816 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8018ef:	8b 43 04             	mov    0x4(%ebx),%eax
  8018f2:	2b 03                	sub    (%ebx),%eax
  8018f4:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  8018fa:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  801901:	00 00 00 
	stat->st_dev = &devpipe;
  801904:	c7 86 88 00 00 00 20 	movl   $0x803020,0x88(%esi)
  80190b:	30 80 00 
	return 0;
}
  80190e:	b8 00 00 00 00       	mov    $0x0,%eax
  801913:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801916:	5b                   	pop    %ebx
  801917:	5e                   	pop    %esi
  801918:	c9                   	leave  
  801919:	c3                   	ret    

0080191a <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  80191a:	55                   	push   %ebp
  80191b:	89 e5                	mov    %esp,%ebp
  80191d:	53                   	push   %ebx
  80191e:	83 ec 0c             	sub    $0xc,%esp
  801921:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801924:	53                   	push   %ebx
  801925:	6a 00                	push   $0x0
  801927:	e8 b6 f3 ff ff       	call   800ce2 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  80192c:	89 1c 24             	mov    %ebx,(%esp)
  80192f:	e8 f8 f7 ff ff       	call   80112c <fd2data>
  801934:	83 c4 08             	add    $0x8,%esp
  801937:	50                   	push   %eax
  801938:	6a 00                	push   $0x0
  80193a:	e8 a3 f3 ff ff       	call   800ce2 <sys_page_unmap>
}
  80193f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801942:	c9                   	leave  
  801943:	c3                   	ret    

00801944 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801944:	55                   	push   %ebp
  801945:	89 e5                	mov    %esp,%ebp
  801947:	57                   	push   %edi
  801948:	56                   	push   %esi
  801949:	53                   	push   %ebx
  80194a:	83 ec 1c             	sub    $0x1c,%esp
  80194d:	89 c7                	mov    %eax,%edi
  80194f:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801952:	a1 08 40 80 00       	mov    0x804008,%eax
  801957:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  80195a:	83 ec 0c             	sub    $0xc,%esp
  80195d:	57                   	push   %edi
  80195e:	e8 29 06 00 00       	call   801f8c <pageref>
  801963:	89 c6                	mov    %eax,%esi
  801965:	83 c4 04             	add    $0x4,%esp
  801968:	ff 75 e4             	pushl  -0x1c(%ebp)
  80196b:	e8 1c 06 00 00       	call   801f8c <pageref>
  801970:	83 c4 10             	add    $0x10,%esp
  801973:	39 c6                	cmp    %eax,%esi
  801975:	0f 94 c0             	sete   %al
  801978:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  80197b:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801981:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801984:	39 cb                	cmp    %ecx,%ebx
  801986:	75 08                	jne    801990 <_pipeisclosed+0x4c>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  801988:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80198b:	5b                   	pop    %ebx
  80198c:	5e                   	pop    %esi
  80198d:	5f                   	pop    %edi
  80198e:	c9                   	leave  
  80198f:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  801990:	83 f8 01             	cmp    $0x1,%eax
  801993:	75 bd                	jne    801952 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801995:	8b 42 58             	mov    0x58(%edx),%eax
  801998:	6a 01                	push   $0x1
  80199a:	50                   	push   %eax
  80199b:	53                   	push   %ebx
  80199c:	68 16 28 80 00       	push   $0x802816
  8019a1:	e8 ba e8 ff ff       	call   800260 <cprintf>
  8019a6:	83 c4 10             	add    $0x10,%esp
  8019a9:	eb a7                	jmp    801952 <_pipeisclosed+0xe>

008019ab <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8019ab:	55                   	push   %ebp
  8019ac:	89 e5                	mov    %esp,%ebp
  8019ae:	57                   	push   %edi
  8019af:	56                   	push   %esi
  8019b0:	53                   	push   %ebx
  8019b1:	83 ec 28             	sub    $0x28,%esp
  8019b4:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  8019b7:	56                   	push   %esi
  8019b8:	e8 6f f7 ff ff       	call   80112c <fd2data>
  8019bd:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8019bf:	83 c4 10             	add    $0x10,%esp
  8019c2:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8019c6:	75 4a                	jne    801a12 <devpipe_write+0x67>
  8019c8:	bf 00 00 00 00       	mov    $0x0,%edi
  8019cd:	eb 56                	jmp    801a25 <devpipe_write+0x7a>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  8019cf:	89 da                	mov    %ebx,%edx
  8019d1:	89 f0                	mov    %esi,%eax
  8019d3:	e8 6c ff ff ff       	call   801944 <_pipeisclosed>
  8019d8:	85 c0                	test   %eax,%eax
  8019da:	75 4d                	jne    801a29 <devpipe_write+0x7e>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  8019dc:	e8 90 f2 ff ff       	call   800c71 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8019e1:	8b 43 04             	mov    0x4(%ebx),%eax
  8019e4:	8b 13                	mov    (%ebx),%edx
  8019e6:	83 c2 20             	add    $0x20,%edx
  8019e9:	39 d0                	cmp    %edx,%eax
  8019eb:	73 e2                	jae    8019cf <devpipe_write+0x24>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  8019ed:	89 c2                	mov    %eax,%edx
  8019ef:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  8019f5:	79 05                	jns    8019fc <devpipe_write+0x51>
  8019f7:	4a                   	dec    %edx
  8019f8:	83 ca e0             	or     $0xffffffe0,%edx
  8019fb:	42                   	inc    %edx
  8019fc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8019ff:	8a 0c 39             	mov    (%ecx,%edi,1),%cl
  801a02:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801a06:	40                   	inc    %eax
  801a07:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801a0a:	47                   	inc    %edi
  801a0b:	39 7d 10             	cmp    %edi,0x10(%ebp)
  801a0e:	77 07                	ja     801a17 <devpipe_write+0x6c>
  801a10:	eb 13                	jmp    801a25 <devpipe_write+0x7a>
  801a12:	bf 00 00 00 00       	mov    $0x0,%edi
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801a17:	8b 43 04             	mov    0x4(%ebx),%eax
  801a1a:	8b 13                	mov    (%ebx),%edx
  801a1c:	83 c2 20             	add    $0x20,%edx
  801a1f:	39 d0                	cmp    %edx,%eax
  801a21:	73 ac                	jae    8019cf <devpipe_write+0x24>
  801a23:	eb c8                	jmp    8019ed <devpipe_write+0x42>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801a25:	89 f8                	mov    %edi,%eax
  801a27:	eb 05                	jmp    801a2e <devpipe_write+0x83>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801a29:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801a2e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a31:	5b                   	pop    %ebx
  801a32:	5e                   	pop    %esi
  801a33:	5f                   	pop    %edi
  801a34:	c9                   	leave  
  801a35:	c3                   	ret    

00801a36 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801a36:	55                   	push   %ebp
  801a37:	89 e5                	mov    %esp,%ebp
  801a39:	57                   	push   %edi
  801a3a:	56                   	push   %esi
  801a3b:	53                   	push   %ebx
  801a3c:	83 ec 18             	sub    $0x18,%esp
  801a3f:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801a42:	57                   	push   %edi
  801a43:	e8 e4 f6 ff ff       	call   80112c <fd2data>
  801a48:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801a4a:	83 c4 10             	add    $0x10,%esp
  801a4d:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801a51:	75 44                	jne    801a97 <devpipe_read+0x61>
  801a53:	be 00 00 00 00       	mov    $0x0,%esi
  801a58:	eb 4f                	jmp    801aa9 <devpipe_read+0x73>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
				return i;
  801a5a:	89 f0                	mov    %esi,%eax
  801a5c:	eb 54                	jmp    801ab2 <devpipe_read+0x7c>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801a5e:	89 da                	mov    %ebx,%edx
  801a60:	89 f8                	mov    %edi,%eax
  801a62:	e8 dd fe ff ff       	call   801944 <_pipeisclosed>
  801a67:	85 c0                	test   %eax,%eax
  801a69:	75 42                	jne    801aad <devpipe_read+0x77>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801a6b:	e8 01 f2 ff ff       	call   800c71 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801a70:	8b 03                	mov    (%ebx),%eax
  801a72:	3b 43 04             	cmp    0x4(%ebx),%eax
  801a75:	74 e7                	je     801a5e <devpipe_read+0x28>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801a77:	25 1f 00 00 80       	and    $0x8000001f,%eax
  801a7c:	79 05                	jns    801a83 <devpipe_read+0x4d>
  801a7e:	48                   	dec    %eax
  801a7f:	83 c8 e0             	or     $0xffffffe0,%eax
  801a82:	40                   	inc    %eax
  801a83:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  801a87:	8b 55 0c             	mov    0xc(%ebp),%edx
  801a8a:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  801a8d:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801a8f:	46                   	inc    %esi
  801a90:	39 75 10             	cmp    %esi,0x10(%ebp)
  801a93:	77 07                	ja     801a9c <devpipe_read+0x66>
  801a95:	eb 12                	jmp    801aa9 <devpipe_read+0x73>
  801a97:	be 00 00 00 00       	mov    $0x0,%esi
		while (p->p_rpos == p->p_wpos) {
  801a9c:	8b 03                	mov    (%ebx),%eax
  801a9e:	3b 43 04             	cmp    0x4(%ebx),%eax
  801aa1:	75 d4                	jne    801a77 <devpipe_read+0x41>
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801aa3:	85 f6                	test   %esi,%esi
  801aa5:	75 b3                	jne    801a5a <devpipe_read+0x24>
  801aa7:	eb b5                	jmp    801a5e <devpipe_read+0x28>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801aa9:	89 f0                	mov    %esi,%eax
  801aab:	eb 05                	jmp    801ab2 <devpipe_read+0x7c>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801aad:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801ab2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ab5:	5b                   	pop    %ebx
  801ab6:	5e                   	pop    %esi
  801ab7:	5f                   	pop    %edi
  801ab8:	c9                   	leave  
  801ab9:	c3                   	ret    

00801aba <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801aba:	55                   	push   %ebp
  801abb:	89 e5                	mov    %esp,%ebp
  801abd:	57                   	push   %edi
  801abe:	56                   	push   %esi
  801abf:	53                   	push   %ebx
  801ac0:	83 ec 28             	sub    $0x28,%esp
  801ac3:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801ac6:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801ac9:	50                   	push   %eax
  801aca:	e8 75 f6 ff ff       	call   801144 <fd_alloc>
  801acf:	89 c3                	mov    %eax,%ebx
  801ad1:	83 c4 10             	add    $0x10,%esp
  801ad4:	85 c0                	test   %eax,%eax
  801ad6:	0f 88 24 01 00 00    	js     801c00 <pipe+0x146>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801adc:	83 ec 04             	sub    $0x4,%esp
  801adf:	68 07 04 00 00       	push   $0x407
  801ae4:	ff 75 e4             	pushl  -0x1c(%ebp)
  801ae7:	6a 00                	push   $0x0
  801ae9:	e8 aa f1 ff ff       	call   800c98 <sys_page_alloc>
  801aee:	89 c3                	mov    %eax,%ebx
  801af0:	83 c4 10             	add    $0x10,%esp
  801af3:	85 c0                	test   %eax,%eax
  801af5:	0f 88 05 01 00 00    	js     801c00 <pipe+0x146>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801afb:	83 ec 0c             	sub    $0xc,%esp
  801afe:	8d 45 e0             	lea    -0x20(%ebp),%eax
  801b01:	50                   	push   %eax
  801b02:	e8 3d f6 ff ff       	call   801144 <fd_alloc>
  801b07:	89 c3                	mov    %eax,%ebx
  801b09:	83 c4 10             	add    $0x10,%esp
  801b0c:	85 c0                	test   %eax,%eax
  801b0e:	0f 88 dc 00 00 00    	js     801bf0 <pipe+0x136>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b14:	83 ec 04             	sub    $0x4,%esp
  801b17:	68 07 04 00 00       	push   $0x407
  801b1c:	ff 75 e0             	pushl  -0x20(%ebp)
  801b1f:	6a 00                	push   $0x0
  801b21:	e8 72 f1 ff ff       	call   800c98 <sys_page_alloc>
  801b26:	89 c3                	mov    %eax,%ebx
  801b28:	83 c4 10             	add    $0x10,%esp
  801b2b:	85 c0                	test   %eax,%eax
  801b2d:	0f 88 bd 00 00 00    	js     801bf0 <pipe+0x136>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801b33:	83 ec 0c             	sub    $0xc,%esp
  801b36:	ff 75 e4             	pushl  -0x1c(%ebp)
  801b39:	e8 ee f5 ff ff       	call   80112c <fd2data>
  801b3e:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b40:	83 c4 0c             	add    $0xc,%esp
  801b43:	68 07 04 00 00       	push   $0x407
  801b48:	50                   	push   %eax
  801b49:	6a 00                	push   $0x0
  801b4b:	e8 48 f1 ff ff       	call   800c98 <sys_page_alloc>
  801b50:	89 c3                	mov    %eax,%ebx
  801b52:	83 c4 10             	add    $0x10,%esp
  801b55:	85 c0                	test   %eax,%eax
  801b57:	0f 88 83 00 00 00    	js     801be0 <pipe+0x126>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b5d:	83 ec 0c             	sub    $0xc,%esp
  801b60:	ff 75 e0             	pushl  -0x20(%ebp)
  801b63:	e8 c4 f5 ff ff       	call   80112c <fd2data>
  801b68:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801b6f:	50                   	push   %eax
  801b70:	6a 00                	push   $0x0
  801b72:	56                   	push   %esi
  801b73:	6a 00                	push   $0x0
  801b75:	e8 42 f1 ff ff       	call   800cbc <sys_page_map>
  801b7a:	89 c3                	mov    %eax,%ebx
  801b7c:	83 c4 20             	add    $0x20,%esp
  801b7f:	85 c0                	test   %eax,%eax
  801b81:	78 4f                	js     801bd2 <pipe+0x118>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801b83:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801b89:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801b8c:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801b8e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801b91:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801b98:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801b9e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801ba1:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801ba3:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801ba6:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801bad:	83 ec 0c             	sub    $0xc,%esp
  801bb0:	ff 75 e4             	pushl  -0x1c(%ebp)
  801bb3:	e8 64 f5 ff ff       	call   80111c <fd2num>
  801bb8:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  801bba:	83 c4 04             	add    $0x4,%esp
  801bbd:	ff 75 e0             	pushl  -0x20(%ebp)
  801bc0:	e8 57 f5 ff ff       	call   80111c <fd2num>
  801bc5:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  801bc8:	83 c4 10             	add    $0x10,%esp
  801bcb:	bb 00 00 00 00       	mov    $0x0,%ebx
  801bd0:	eb 2e                	jmp    801c00 <pipe+0x146>

    err3:
	sys_page_unmap(0, va);
  801bd2:	83 ec 08             	sub    $0x8,%esp
  801bd5:	56                   	push   %esi
  801bd6:	6a 00                	push   $0x0
  801bd8:	e8 05 f1 ff ff       	call   800ce2 <sys_page_unmap>
  801bdd:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801be0:	83 ec 08             	sub    $0x8,%esp
  801be3:	ff 75 e0             	pushl  -0x20(%ebp)
  801be6:	6a 00                	push   $0x0
  801be8:	e8 f5 f0 ff ff       	call   800ce2 <sys_page_unmap>
  801bed:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801bf0:	83 ec 08             	sub    $0x8,%esp
  801bf3:	ff 75 e4             	pushl  -0x1c(%ebp)
  801bf6:	6a 00                	push   $0x0
  801bf8:	e8 e5 f0 ff ff       	call   800ce2 <sys_page_unmap>
  801bfd:	83 c4 10             	add    $0x10,%esp
    err:
	return r;
}
  801c00:	89 d8                	mov    %ebx,%eax
  801c02:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c05:	5b                   	pop    %ebx
  801c06:	5e                   	pop    %esi
  801c07:	5f                   	pop    %edi
  801c08:	c9                   	leave  
  801c09:	c3                   	ret    

00801c0a <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801c0a:	55                   	push   %ebp
  801c0b:	89 e5                	mov    %esp,%ebp
  801c0d:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801c10:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c13:	50                   	push   %eax
  801c14:	ff 75 08             	pushl  0x8(%ebp)
  801c17:	e8 9b f5 ff ff       	call   8011b7 <fd_lookup>
  801c1c:	83 c4 10             	add    $0x10,%esp
  801c1f:	85 c0                	test   %eax,%eax
  801c21:	78 18                	js     801c3b <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801c23:	83 ec 0c             	sub    $0xc,%esp
  801c26:	ff 75 f4             	pushl  -0xc(%ebp)
  801c29:	e8 fe f4 ff ff       	call   80112c <fd2data>
	return _pipeisclosed(fd, p);
  801c2e:	89 c2                	mov    %eax,%edx
  801c30:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c33:	e8 0c fd ff ff       	call   801944 <_pipeisclosed>
  801c38:	83 c4 10             	add    $0x10,%esp
}
  801c3b:	c9                   	leave  
  801c3c:	c3                   	ret    
  801c3d:	00 00                	add    %al,(%eax)
	...

00801c40 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801c40:	55                   	push   %ebp
  801c41:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801c43:	b8 00 00 00 00       	mov    $0x0,%eax
  801c48:	c9                   	leave  
  801c49:	c3                   	ret    

00801c4a <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801c4a:	55                   	push   %ebp
  801c4b:	89 e5                	mov    %esp,%ebp
  801c4d:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801c50:	68 2e 28 80 00       	push   $0x80282e
  801c55:	ff 75 0c             	pushl  0xc(%ebp)
  801c58:	e8 b9 eb ff ff       	call   800816 <strcpy>
	return 0;
}
  801c5d:	b8 00 00 00 00       	mov    $0x0,%eax
  801c62:	c9                   	leave  
  801c63:	c3                   	ret    

00801c64 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801c64:	55                   	push   %ebp
  801c65:	89 e5                	mov    %esp,%ebp
  801c67:	57                   	push   %edi
  801c68:	56                   	push   %esi
  801c69:	53                   	push   %ebx
  801c6a:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801c70:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801c74:	74 45                	je     801cbb <devcons_write+0x57>
  801c76:	b8 00 00 00 00       	mov    $0x0,%eax
  801c7b:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801c80:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801c86:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801c89:	29 c3                	sub    %eax,%ebx
		if (m > sizeof(buf) - 1)
  801c8b:	83 fb 7f             	cmp    $0x7f,%ebx
  801c8e:	76 05                	jbe    801c95 <devcons_write+0x31>
			m = sizeof(buf) - 1;
  801c90:	bb 7f 00 00 00       	mov    $0x7f,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  801c95:	83 ec 04             	sub    $0x4,%esp
  801c98:	53                   	push   %ebx
  801c99:	03 45 0c             	add    0xc(%ebp),%eax
  801c9c:	50                   	push   %eax
  801c9d:	57                   	push   %edi
  801c9e:	e8 34 ed ff ff       	call   8009d7 <memmove>
		sys_cputs(buf, m);
  801ca3:	83 c4 08             	add    $0x8,%esp
  801ca6:	53                   	push   %ebx
  801ca7:	57                   	push   %edi
  801ca8:	e8 34 ef ff ff       	call   800be1 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801cad:	01 de                	add    %ebx,%esi
  801caf:	89 f0                	mov    %esi,%eax
  801cb1:	83 c4 10             	add    $0x10,%esp
  801cb4:	3b 75 10             	cmp    0x10(%ebp),%esi
  801cb7:	72 cd                	jb     801c86 <devcons_write+0x22>
  801cb9:	eb 05                	jmp    801cc0 <devcons_write+0x5c>
  801cbb:	be 00 00 00 00       	mov    $0x0,%esi
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801cc0:	89 f0                	mov    %esi,%eax
  801cc2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801cc5:	5b                   	pop    %ebx
  801cc6:	5e                   	pop    %esi
  801cc7:	5f                   	pop    %edi
  801cc8:	c9                   	leave  
  801cc9:	c3                   	ret    

00801cca <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801cca:	55                   	push   %ebp
  801ccb:	89 e5                	mov    %esp,%ebp
  801ccd:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  801cd0:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801cd4:	75 07                	jne    801cdd <devcons_read+0x13>
  801cd6:	eb 25                	jmp    801cfd <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801cd8:	e8 94 ef ff ff       	call   800c71 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801cdd:	e8 25 ef ff ff       	call   800c07 <sys_cgetc>
  801ce2:	85 c0                	test   %eax,%eax
  801ce4:	74 f2                	je     801cd8 <devcons_read+0xe>
  801ce6:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  801ce8:	85 c0                	test   %eax,%eax
  801cea:	78 1d                	js     801d09 <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801cec:	83 f8 04             	cmp    $0x4,%eax
  801cef:	74 13                	je     801d04 <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  801cf1:	8b 45 0c             	mov    0xc(%ebp),%eax
  801cf4:	88 10                	mov    %dl,(%eax)
	return 1;
  801cf6:	b8 01 00 00 00       	mov    $0x1,%eax
  801cfb:	eb 0c                	jmp    801d09 <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  801cfd:	b8 00 00 00 00       	mov    $0x0,%eax
  801d02:	eb 05                	jmp    801d09 <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801d04:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801d09:	c9                   	leave  
  801d0a:	c3                   	ret    

00801d0b <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801d0b:	55                   	push   %ebp
  801d0c:	89 e5                	mov    %esp,%ebp
  801d0e:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801d11:	8b 45 08             	mov    0x8(%ebp),%eax
  801d14:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801d17:	6a 01                	push   $0x1
  801d19:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801d1c:	50                   	push   %eax
  801d1d:	e8 bf ee ff ff       	call   800be1 <sys_cputs>
  801d22:	83 c4 10             	add    $0x10,%esp
}
  801d25:	c9                   	leave  
  801d26:	c3                   	ret    

00801d27 <getchar>:

int
getchar(void)
{
  801d27:	55                   	push   %ebp
  801d28:	89 e5                	mov    %esp,%ebp
  801d2a:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801d2d:	6a 01                	push   $0x1
  801d2f:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801d32:	50                   	push   %eax
  801d33:	6a 00                	push   $0x0
  801d35:	e8 fe f6 ff ff       	call   801438 <read>
	if (r < 0)
  801d3a:	83 c4 10             	add    $0x10,%esp
  801d3d:	85 c0                	test   %eax,%eax
  801d3f:	78 0f                	js     801d50 <getchar+0x29>
		return r;
	if (r < 1)
  801d41:	85 c0                	test   %eax,%eax
  801d43:	7e 06                	jle    801d4b <getchar+0x24>
		return -E_EOF;
	return c;
  801d45:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801d49:	eb 05                	jmp    801d50 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801d4b:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801d50:	c9                   	leave  
  801d51:	c3                   	ret    

00801d52 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801d52:	55                   	push   %ebp
  801d53:	89 e5                	mov    %esp,%ebp
  801d55:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801d58:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d5b:	50                   	push   %eax
  801d5c:	ff 75 08             	pushl  0x8(%ebp)
  801d5f:	e8 53 f4 ff ff       	call   8011b7 <fd_lookup>
  801d64:	83 c4 10             	add    $0x10,%esp
  801d67:	85 c0                	test   %eax,%eax
  801d69:	78 11                	js     801d7c <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801d6b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d6e:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801d74:	39 10                	cmp    %edx,(%eax)
  801d76:	0f 94 c0             	sete   %al
  801d79:	0f b6 c0             	movzbl %al,%eax
}
  801d7c:	c9                   	leave  
  801d7d:	c3                   	ret    

00801d7e <opencons>:

int
opencons(void)
{
  801d7e:	55                   	push   %ebp
  801d7f:	89 e5                	mov    %esp,%ebp
  801d81:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801d84:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d87:	50                   	push   %eax
  801d88:	e8 b7 f3 ff ff       	call   801144 <fd_alloc>
  801d8d:	83 c4 10             	add    $0x10,%esp
  801d90:	85 c0                	test   %eax,%eax
  801d92:	78 3a                	js     801dce <opencons+0x50>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801d94:	83 ec 04             	sub    $0x4,%esp
  801d97:	68 07 04 00 00       	push   $0x407
  801d9c:	ff 75 f4             	pushl  -0xc(%ebp)
  801d9f:	6a 00                	push   $0x0
  801da1:	e8 f2 ee ff ff       	call   800c98 <sys_page_alloc>
  801da6:	83 c4 10             	add    $0x10,%esp
  801da9:	85 c0                	test   %eax,%eax
  801dab:	78 21                	js     801dce <opencons+0x50>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801dad:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801db3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801db6:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801db8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801dbb:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801dc2:	83 ec 0c             	sub    $0xc,%esp
  801dc5:	50                   	push   %eax
  801dc6:	e8 51 f3 ff ff       	call   80111c <fd2num>
  801dcb:	83 c4 10             	add    $0x10,%esp
}
  801dce:	c9                   	leave  
  801dcf:	c3                   	ret    

00801dd0 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801dd0:	55                   	push   %ebp
  801dd1:	89 e5                	mov    %esp,%ebp
  801dd3:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  801dd6:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801ddd:	75 52                	jne    801e31 <set_pgfault_handler+0x61>
		// First time through!	
		// LAB 4: Your code here.

		//int sys_page_alloc(envid_t envid, void *va, int perm)
		r = sys_page_alloc(0, (void*)(UXSTACKTOP - PGSIZE), PTE_U | PTE_W | PTE_P);
  801ddf:	83 ec 04             	sub    $0x4,%esp
  801de2:	6a 07                	push   $0x7
  801de4:	68 00 f0 bf ee       	push   $0xeebff000
  801de9:	6a 00                	push   $0x0
  801deb:	e8 a8 ee ff ff       	call   800c98 <sys_page_alloc>
		if (r < 0) {
  801df0:	83 c4 10             	add    $0x10,%esp
  801df3:	85 c0                	test   %eax,%eax
  801df5:	79 12                	jns    801e09 <set_pgfault_handler+0x39>
			panic("sys_page_alloc error : %e\n", r);
  801df7:	50                   	push   %eax
  801df8:	68 3a 28 80 00       	push   $0x80283a
  801dfd:	6a 24                	push   $0x24
  801dff:	68 55 28 80 00       	push   $0x802855
  801e04:	e8 7f e3 ff ff       	call   800188 <_panic>
		}

		// how to know envid, put 0, envid2env will help us to get curenv in syscall
		r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);		
  801e09:	83 ec 08             	sub    $0x8,%esp
  801e0c:	68 3c 1e 80 00       	push   $0x801e3c
  801e11:	6a 00                	push   $0x0
  801e13:	e8 33 ef ff ff       	call   800d4b <sys_env_set_pgfault_upcall>
		if (r < 0) {
  801e18:	83 c4 10             	add    $0x10,%esp
  801e1b:	85 c0                	test   %eax,%eax
  801e1d:	79 12                	jns    801e31 <set_pgfault_handler+0x61>
			panic("sys_env_set_pgfault_upcall error : %e\n", r);
  801e1f:	50                   	push   %eax
  801e20:	68 64 28 80 00       	push   $0x802864
  801e25:	6a 2a                	push   $0x2a
  801e27:	68 55 28 80 00       	push   $0x802855
  801e2c:	e8 57 e3 ff ff       	call   800188 <_panic>
		}
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801e31:	8b 45 08             	mov    0x8(%ebp),%eax
  801e34:	a3 00 60 80 00       	mov    %eax,0x806000
}
  801e39:	c9                   	leave  
  801e3a:	c3                   	ret    
	...

00801e3c <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801e3c:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801e3d:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  801e42:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801e44:	83 c4 04             	add    $0x4,%esp
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	
	// fix old esp
	movl 0x30(%esp), %eax
  801e47:	8b 44 24 30          	mov    0x30(%esp),%eax
	subl $0x4, %eax
  801e4b:	83 e8 04             	sub    $0x4,%eax
	movl %eax, 0x30(%esp)
  801e4e:	89 44 24 30          	mov    %eax,0x30(%esp)

	// set trap-time %eip
	movl 0x28(%esp), %ebx
  801e52:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	movl %ebx, (%eax)
  801e56:	89 18                	mov    %ebx,(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $0x08, %esp 	// ignore err_code and fault_va
  801e58:	83 c4 08             	add    $0x8,%esp
	popal 				// restore registers
  801e5b:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x04, %esp 	// ignore eip 
  801e5c:	83 c4 04             	add    $0x4,%esp
	popfl				// modify eflags
  801e5f:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  801e60:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  801e61:	c3                   	ret    
	...

00801e64 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801e64:	55                   	push   %ebp
  801e65:	89 e5                	mov    %esp,%ebp
  801e67:	56                   	push   %esi
  801e68:	53                   	push   %ebx
  801e69:	8b 75 08             	mov    0x8(%ebp),%esi
  801e6c:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e6f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// cprintf("0x%x 0x%x 0x%x\n", (uint32_t)from_env_store, (uint32_t)pg, (uint32_t)perm_store);
	int r;
	if (pg != NULL) {
  801e72:	85 c0                	test   %eax,%eax
  801e74:	74 0e                	je     801e84 <ipc_recv+0x20>
		r = sys_ipc_recv(pg);
  801e76:	83 ec 0c             	sub    $0xc,%esp
  801e79:	50                   	push   %eax
  801e7a:	e8 14 ef ff ff       	call   800d93 <sys_ipc_recv>
  801e7f:	83 c4 10             	add    $0x10,%esp
  801e82:	eb 10                	jmp    801e94 <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv((void *)UTOP);
  801e84:	83 ec 0c             	sub    $0xc,%esp
  801e87:	68 00 00 c0 ee       	push   $0xeec00000
  801e8c:	e8 02 ef ff ff       	call   800d93 <sys_ipc_recv>
  801e91:	83 c4 10             	add    $0x10,%esp
	}

	if (r == 0) {
  801e94:	85 c0                	test   %eax,%eax
  801e96:	75 26                	jne    801ebe <ipc_recv+0x5a>
		if (from_env_store != NULL) *from_env_store = thisenv->env_ipc_from;
  801e98:	85 f6                	test   %esi,%esi
  801e9a:	74 0a                	je     801ea6 <ipc_recv+0x42>
  801e9c:	a1 08 40 80 00       	mov    0x804008,%eax
  801ea1:	8b 40 74             	mov    0x74(%eax),%eax
  801ea4:	89 06                	mov    %eax,(%esi)
		if (perm_store != NULL) *perm_store = thisenv->env_ipc_perm;
  801ea6:	85 db                	test   %ebx,%ebx
  801ea8:	74 0a                	je     801eb4 <ipc_recv+0x50>
  801eaa:	a1 08 40 80 00       	mov    0x804008,%eax
  801eaf:	8b 40 78             	mov    0x78(%eax),%eax
  801eb2:	89 03                	mov    %eax,(%ebx)
		return thisenv->env_ipc_value;
  801eb4:	a1 08 40 80 00       	mov    0x804008,%eax
  801eb9:	8b 40 70             	mov    0x70(%eax),%eax
  801ebc:	eb 14                	jmp    801ed2 <ipc_recv+0x6e>
	} else {
		// fails;
		if (from_env_store != NULL) *from_env_store = 0;
  801ebe:	85 f6                	test   %esi,%esi
  801ec0:	74 06                	je     801ec8 <ipc_recv+0x64>
  801ec2:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if (perm_store != NULL) *perm_store = 0;
  801ec8:	85 db                	test   %ebx,%ebx
  801eca:	74 06                	je     801ed2 <ipc_recv+0x6e>
  801ecc:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		return r;
	}
}
  801ed2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ed5:	5b                   	pop    %ebx
  801ed6:	5e                   	pop    %esi
  801ed7:	c9                   	leave  
  801ed8:	c3                   	ret    

00801ed9 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801ed9:	55                   	push   %ebp
  801eda:	89 e5                	mov    %esp,%ebp
  801edc:	57                   	push   %edi
  801edd:	56                   	push   %esi
  801ede:	53                   	push   %ebx
  801edf:	83 ec 0c             	sub    $0xc,%esp
  801ee2:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801ee5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801ee8:	8b 75 14             	mov    0x14(%ebp),%esi
	// LAB 4: Your code here.
	// int sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
	int r;
	if (pg == NULL) pg = (void *)UTOP;
  801eeb:	85 db                	test   %ebx,%ebx
  801eed:	75 25                	jne    801f14 <ipc_send+0x3b>
  801eef:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
  801ef4:	eb 1e                	jmp    801f14 <ipc_send+0x3b>
	
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) != 0) {
		if (r == -E_IPC_NOT_RECV) {
  801ef6:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801ef9:	75 07                	jne    801f02 <ipc_send+0x29>
			// cprintf("Try Again and Again....\n");
			sys_yield();
  801efb:	e8 71 ed ff ff       	call   800c71 <sys_yield>
  801f00:	eb 12                	jmp    801f14 <ipc_send+0x3b>
		} else {
			panic("ipc_send error %e\n", r);
  801f02:	50                   	push   %eax
  801f03:	68 8c 28 80 00       	push   $0x80288c
  801f08:	6a 43                	push   $0x43
  801f0a:	68 9f 28 80 00       	push   $0x80289f
  801f0f:	e8 74 e2 ff ff       	call   800188 <_panic>
	// LAB 4: Your code here.
	// int sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
	int r;
	if (pg == NULL) pg = (void *)UTOP;
	
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) != 0) {
  801f14:	56                   	push   %esi
  801f15:	53                   	push   %ebx
  801f16:	57                   	push   %edi
  801f17:	ff 75 08             	pushl  0x8(%ebp)
  801f1a:	e8 4f ee ff ff       	call   800d6e <sys_ipc_try_send>
  801f1f:	83 c4 10             	add    $0x10,%esp
  801f22:	85 c0                	test   %eax,%eax
  801f24:	75 d0                	jne    801ef6 <ipc_send+0x1d>
		} else {
			panic("ipc_send error %e\n", r);
		}
	}
	return;
}
  801f26:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f29:	5b                   	pop    %ebx
  801f2a:	5e                   	pop    %esi
  801f2b:	5f                   	pop    %edi
  801f2c:	c9                   	leave  
  801f2d:	c3                   	ret    

00801f2e <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801f2e:	55                   	push   %ebp
  801f2f:	89 e5                	mov    %esp,%ebp
  801f31:	53                   	push   %ebx
  801f32:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  801f35:	39 1d 50 00 c0 ee    	cmp    %ebx,0xeec00050
  801f3b:	74 22                	je     801f5f <ipc_find_env+0x31>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801f3d:	b8 01 00 00 00       	mov    $0x1,%eax
		if (envs[i].env_type == type)
  801f42:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  801f49:	89 c2                	mov    %eax,%edx
  801f4b:	c1 e2 07             	shl    $0x7,%edx
  801f4e:	29 ca                	sub    %ecx,%edx
  801f50:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801f56:	8b 52 50             	mov    0x50(%edx),%edx
  801f59:	39 da                	cmp    %ebx,%edx
  801f5b:	75 1d                	jne    801f7a <ipc_find_env+0x4c>
  801f5d:	eb 05                	jmp    801f64 <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801f5f:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
			return envs[i].env_id;
  801f64:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  801f6b:	c1 e0 07             	shl    $0x7,%eax
  801f6e:	29 d0                	sub    %edx,%eax
  801f70:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  801f75:	8b 40 40             	mov    0x40(%eax),%eax
  801f78:	eb 0c                	jmp    801f86 <ipc_find_env+0x58>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801f7a:	40                   	inc    %eax
  801f7b:	3d 00 04 00 00       	cmp    $0x400,%eax
  801f80:	75 c0                	jne    801f42 <ipc_find_env+0x14>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801f82:	66 b8 00 00          	mov    $0x0,%ax
}
  801f86:	5b                   	pop    %ebx
  801f87:	c9                   	leave  
  801f88:	c3                   	ret    
  801f89:	00 00                	add    %al,(%eax)
	...

00801f8c <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801f8c:	55                   	push   %ebp
  801f8d:	89 e5                	mov    %esp,%ebp
  801f8f:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801f92:	89 c2                	mov    %eax,%edx
  801f94:	c1 ea 16             	shr    $0x16,%edx
  801f97:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801f9e:	f6 c2 01             	test   $0x1,%dl
  801fa1:	74 1e                	je     801fc1 <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  801fa3:	c1 e8 0c             	shr    $0xc,%eax
  801fa6:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801fad:	a8 01                	test   $0x1,%al
  801faf:	74 17                	je     801fc8 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801fb1:	c1 e8 0c             	shr    $0xc,%eax
  801fb4:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  801fbb:	ef 
  801fbc:	0f b7 c0             	movzwl %ax,%eax
  801fbf:	eb 0c                	jmp    801fcd <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  801fc1:	b8 00 00 00 00       	mov    $0x0,%eax
  801fc6:	eb 05                	jmp    801fcd <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  801fc8:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  801fcd:	c9                   	leave  
  801fce:	c3                   	ret    
	...

00801fd0 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  801fd0:	55                   	push   %ebp
  801fd1:	89 e5                	mov    %esp,%ebp
  801fd3:	57                   	push   %edi
  801fd4:	56                   	push   %esi
  801fd5:	83 ec 10             	sub    $0x10,%esp
  801fd8:	8b 7d 08             	mov    0x8(%ebp),%edi
  801fdb:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  801fde:	89 7d f0             	mov    %edi,-0x10(%ebp)
  801fe1:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  801fe4:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  801fe7:	8b 45 14             	mov    0x14(%ebp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  801fea:	85 c0                	test   %eax,%eax
  801fec:	75 2e                	jne    80201c <__udivdi3+0x4c>
    {
      if (d0 > n1)
  801fee:	39 f1                	cmp    %esi,%ecx
  801ff0:	77 5a                	ja     80204c <__udivdi3+0x7c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  801ff2:	85 c9                	test   %ecx,%ecx
  801ff4:	75 0b                	jne    802001 <__udivdi3+0x31>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  801ff6:	b8 01 00 00 00       	mov    $0x1,%eax
  801ffb:	31 d2                	xor    %edx,%edx
  801ffd:	f7 f1                	div    %ecx
  801fff:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  802001:	31 d2                	xor    %edx,%edx
  802003:	89 f0                	mov    %esi,%eax
  802005:	f7 f1                	div    %ecx
  802007:	89 c6                	mov    %eax,%esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802009:	89 f8                	mov    %edi,%eax
  80200b:	f7 f1                	div    %ecx
  80200d:	89 c7                	mov    %eax,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  80200f:	89 f8                	mov    %edi,%eax
  802011:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802013:	83 c4 10             	add    $0x10,%esp
  802016:	5e                   	pop    %esi
  802017:	5f                   	pop    %edi
  802018:	c9                   	leave  
  802019:	c3                   	ret    
  80201a:	66 90                	xchg   %ax,%ax
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  80201c:	39 f0                	cmp    %esi,%eax
  80201e:	77 1c                	ja     80203c <__udivdi3+0x6c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  802020:	0f bd f8             	bsr    %eax,%edi
	  if (bm == 0)
  802023:	83 f7 1f             	xor    $0x1f,%edi
  802026:	75 3c                	jne    802064 <__udivdi3+0x94>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802028:	39 f0                	cmp    %esi,%eax
  80202a:	0f 82 90 00 00 00    	jb     8020c0 <__udivdi3+0xf0>
  802030:	8b 55 f0             	mov    -0x10(%ebp),%edx
  802033:	39 55 f4             	cmp    %edx,-0xc(%ebp)
  802036:	0f 86 84 00 00 00    	jbe    8020c0 <__udivdi3+0xf0>
  80203c:	31 f6                	xor    %esi,%esi
  80203e:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  802040:	89 f8                	mov    %edi,%eax
  802042:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802044:	83 c4 10             	add    $0x10,%esp
  802047:	5e                   	pop    %esi
  802048:	5f                   	pop    %edi
  802049:	c9                   	leave  
  80204a:	c3                   	ret    
  80204b:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  80204c:	89 f2                	mov    %esi,%edx
  80204e:	89 f8                	mov    %edi,%eax
  802050:	f7 f1                	div    %ecx
  802052:	89 c7                	mov    %eax,%edi
  802054:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  802056:	89 f8                	mov    %edi,%eax
  802058:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  80205a:	83 c4 10             	add    $0x10,%esp
  80205d:	5e                   	pop    %esi
  80205e:	5f                   	pop    %edi
  80205f:	c9                   	leave  
  802060:	c3                   	ret    
  802061:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  802064:	89 f9                	mov    %edi,%ecx
  802066:	d3 e0                	shl    %cl,%eax
  802068:	89 45 e8             	mov    %eax,-0x18(%ebp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  80206b:	b8 20 00 00 00       	mov    $0x20,%eax
  802070:	29 f8                	sub    %edi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  802072:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802075:	88 c1                	mov    %al,%cl
  802077:	d3 ea                	shr    %cl,%edx
  802079:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  80207c:	09 ca                	or     %ecx,%edx
  80207e:	89 55 ec             	mov    %edx,-0x14(%ebp)
	      d0 = d0 << bm;
  802081:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802084:	89 f9                	mov    %edi,%ecx
  802086:	d3 e2                	shl    %cl,%edx
  802088:	89 55 f4             	mov    %edx,-0xc(%ebp)
	      n2 = n1 >> b;
  80208b:	89 f2                	mov    %esi,%edx
  80208d:	88 c1                	mov    %al,%cl
  80208f:	d3 ea                	shr    %cl,%edx
  802091:	89 55 e8             	mov    %edx,-0x18(%ebp)
	      n1 = (n1 << bm) | (n0 >> b);
  802094:	89 f2                	mov    %esi,%edx
  802096:	89 f9                	mov    %edi,%ecx
  802098:	d3 e2                	shl    %cl,%edx
  80209a:	8b 75 f0             	mov    -0x10(%ebp),%esi
  80209d:	88 c1                	mov    %al,%cl
  80209f:	d3 ee                	shr    %cl,%esi
  8020a1:	09 d6                	or     %edx,%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  8020a3:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  8020a6:	89 f0                	mov    %esi,%eax
  8020a8:	89 ca                	mov    %ecx,%edx
  8020aa:	f7 75 ec             	divl   -0x14(%ebp)
  8020ad:	89 d1                	mov    %edx,%ecx
  8020af:	89 c6                	mov    %eax,%esi
	      umul_ppmm (m1, m0, q0, d0);
  8020b1:	f7 65 f4             	mull   -0xc(%ebp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8020b4:	39 d1                	cmp    %edx,%ecx
  8020b6:	72 28                	jb     8020e0 <__udivdi3+0x110>
  8020b8:	74 1a                	je     8020d4 <__udivdi3+0x104>
  8020ba:	89 f7                	mov    %esi,%edi
  8020bc:	31 f6                	xor    %esi,%esi
  8020be:	eb 80                	jmp    802040 <__udivdi3+0x70>
	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  8020c0:	31 f6                	xor    %esi,%esi
  8020c2:	bf 01 00 00 00       	mov    $0x1,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  8020c7:	89 f8                	mov    %edi,%eax
  8020c9:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  8020cb:	83 c4 10             	add    $0x10,%esp
  8020ce:	5e                   	pop    %esi
  8020cf:	5f                   	pop    %edi
  8020d0:	c9                   	leave  
  8020d1:	c3                   	ret    
  8020d2:	66 90                	xchg   %ax,%ax

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  8020d4:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8020d7:	89 f9                	mov    %edi,%ecx
  8020d9:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8020db:	39 c2                	cmp    %eax,%edx
  8020dd:	73 db                	jae    8020ba <__udivdi3+0xea>
  8020df:	90                   	nop
		{
		  q0--;
  8020e0:	8d 7e ff             	lea    -0x1(%esi),%edi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  8020e3:	31 f6                	xor    %esi,%esi
  8020e5:	e9 56 ff ff ff       	jmp    802040 <__udivdi3+0x70>
	...

008020ec <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  8020ec:	55                   	push   %ebp
  8020ed:	89 e5                	mov    %esp,%ebp
  8020ef:	57                   	push   %edi
  8020f0:	56                   	push   %esi
  8020f1:	83 ec 20             	sub    $0x20,%esp
  8020f4:	8b 45 08             	mov    0x8(%ebp),%eax
  8020f7:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  8020fa:	89 45 e8             	mov    %eax,-0x18(%ebp)
  8020fd:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  802100:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  802103:	8b 7d 14             	mov    0x14(%ebp),%edi
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  802106:	89 45 f0             	mov    %eax,-0x10(%ebp)
  n1 = nn.s.high;
  802109:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  80210b:	85 ff                	test   %edi,%edi
  80210d:	75 15                	jne    802124 <__umoddi3+0x38>
    {
      if (d0 > n1)
  80210f:	39 f1                	cmp    %esi,%ecx
  802111:	0f 86 99 00 00 00    	jbe    8021b0 <__umoddi3+0xc4>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802117:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  802119:	89 d0                	mov    %edx,%eax
  80211b:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  80211d:	83 c4 20             	add    $0x20,%esp
  802120:	5e                   	pop    %esi
  802121:	5f                   	pop    %edi
  802122:	c9                   	leave  
  802123:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  802124:	39 f7                	cmp    %esi,%edi
  802126:	0f 87 a4 00 00 00    	ja     8021d0 <__umoddi3+0xe4>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  80212c:	0f bd c7             	bsr    %edi,%eax
	  if (bm == 0)
  80212f:	83 f0 1f             	xor    $0x1f,%eax
  802132:	89 45 ec             	mov    %eax,-0x14(%ebp)
  802135:	0f 84 a1 00 00 00    	je     8021dc <__umoddi3+0xf0>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  80213b:	89 f8                	mov    %edi,%eax
  80213d:	8a 4d ec             	mov    -0x14(%ebp),%cl
  802140:	d3 e0                	shl    %cl,%eax
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  802142:	bf 20 00 00 00       	mov    $0x20,%edi
  802147:	2b 7d ec             	sub    -0x14(%ebp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  80214a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80214d:	89 f9                	mov    %edi,%ecx
  80214f:	d3 ea                	shr    %cl,%edx
  802151:	09 c2                	or     %eax,%edx
  802153:	89 55 f0             	mov    %edx,-0x10(%ebp)
	      d0 = d0 << bm;
  802156:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802159:	8a 4d ec             	mov    -0x14(%ebp),%cl
  80215c:	d3 e0                	shl    %cl,%eax
  80215e:	89 45 f4             	mov    %eax,-0xc(%ebp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  802161:	89 f2                	mov    %esi,%edx
  802163:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  802165:	8b 45 e8             	mov    -0x18(%ebp),%eax
  802168:	d3 e0                	shl    %cl,%eax
  80216a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  80216d:	8b 45 e8             	mov    -0x18(%ebp),%eax
  802170:	89 f9                	mov    %edi,%ecx
  802172:	d3 e8                	shr    %cl,%eax
  802174:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  802176:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  802178:	89 f2                	mov    %esi,%edx
  80217a:	f7 75 f0             	divl   -0x10(%ebp)
  80217d:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  80217f:	f7 65 f4             	mull   -0xc(%ebp)
  802182:	89 55 e8             	mov    %edx,-0x18(%ebp)
  802185:	89 c1                	mov    %eax,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802187:	39 d6                	cmp    %edx,%esi
  802189:	72 71                	jb     8021fc <__umoddi3+0x110>
  80218b:	74 7f                	je     80220c <__umoddi3+0x120>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  80218d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802190:	29 c8                	sub    %ecx,%eax
  802192:	19 d6                	sbb    %edx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  802194:	8a 4d ec             	mov    -0x14(%ebp),%cl
  802197:	d3 e8                	shr    %cl,%eax
  802199:	89 f2                	mov    %esi,%edx
  80219b:	89 f9                	mov    %edi,%ecx
  80219d:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  80219f:	09 d0                	or     %edx,%eax
  8021a1:	89 f2                	mov    %esi,%edx
  8021a3:	8a 4d ec             	mov    -0x14(%ebp),%cl
  8021a6:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8021a8:	83 c4 20             	add    $0x20,%esp
  8021ab:	5e                   	pop    %esi
  8021ac:	5f                   	pop    %edi
  8021ad:	c9                   	leave  
  8021ae:	c3                   	ret    
  8021af:	90                   	nop
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  8021b0:	85 c9                	test   %ecx,%ecx
  8021b2:	75 0b                	jne    8021bf <__umoddi3+0xd3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  8021b4:	b8 01 00 00 00       	mov    $0x1,%eax
  8021b9:	31 d2                	xor    %edx,%edx
  8021bb:	f7 f1                	div    %ecx
  8021bd:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  8021bf:	89 f0                	mov    %esi,%eax
  8021c1:	31 d2                	xor    %edx,%edx
  8021c3:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8021c5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8021c8:	f7 f1                	div    %ecx
  8021ca:	e9 4a ff ff ff       	jmp    802119 <__umoddi3+0x2d>
  8021cf:	90                   	nop
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  8021d0:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8021d2:	83 c4 20             	add    $0x20,%esp
  8021d5:	5e                   	pop    %esi
  8021d6:	5f                   	pop    %edi
  8021d7:	c9                   	leave  
  8021d8:	c3                   	ret    
  8021d9:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  8021dc:	39 f7                	cmp    %esi,%edi
  8021de:	72 05                	jb     8021e5 <__umoddi3+0xf9>
  8021e0:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
  8021e3:	77 0c                	ja     8021f1 <__umoddi3+0x105>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  8021e5:	89 f2                	mov    %esi,%edx
  8021e7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8021ea:	29 c8                	sub    %ecx,%eax
  8021ec:	19 fa                	sbb    %edi,%edx
  8021ee:	89 45 f0             	mov    %eax,-0x10(%ebp)

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  8021f1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8021f4:	83 c4 20             	add    $0x20,%esp
  8021f7:	5e                   	pop    %esi
  8021f8:	5f                   	pop    %edi
  8021f9:	c9                   	leave  
  8021fa:	c3                   	ret    
  8021fb:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  8021fc:	8b 55 e8             	mov    -0x18(%ebp),%edx
  8021ff:	89 c1                	mov    %eax,%ecx
  802201:	2b 4d f4             	sub    -0xc(%ebp),%ecx
  802204:	1b 55 f0             	sbb    -0x10(%ebp),%edx
  802207:	eb 84                	jmp    80218d <__umoddi3+0xa1>
  802209:	8d 76 00             	lea    0x0(%esi),%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  80220c:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  80220f:	72 eb                	jb     8021fc <__umoddi3+0x110>
  802211:	89 f2                	mov    %esi,%edx
  802213:	e9 75 ff ff ff       	jmp    80218d <__umoddi3+0xa1>
