
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
  800045:	e8 60 0e 00 00       	call   800eaa <fork>
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
  8000e5:	68 00 22 80 00       	push   $0x802200
  8000ea:	6a 21                	push   $0x21
  8000ec:	68 28 22 80 00       	push   $0x802228
  8000f1:	e8 92 00 00 00       	call   800188 <_panic>

	// Check that we see environments running on different CPUs
	cprintf("[%08x] stresssched on CPU %d\n", thisenv->env_id, thisenv->env_cpunum);
  8000f6:	a1 08 40 80 00       	mov    0x804008,%eax
  8000fb:	8b 50 5c             	mov    0x5c(%eax),%edx
  8000fe:	8b 40 48             	mov    0x48(%eax),%eax
  800101:	83 ec 04             	sub    $0x4,%esp
  800104:	52                   	push   %edx
  800105:	50                   	push   %eax
  800106:	68 3b 22 80 00       	push   $0x80223b
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
  800172:	e8 87 11 00 00       	call   8012fe <close_all>
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
  8001a6:	68 64 22 80 00       	push   $0x802264
  8001ab:	e8 b0 00 00 00       	call   800260 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8001b0:	83 c4 18             	add    $0x18,%esp
  8001b3:	56                   	push   %esi
  8001b4:	ff 75 10             	pushl  0x10(%ebp)
  8001b7:	e8 53 00 00 00       	call   80020f <vcprintf>
	cprintf("\n");
  8001bc:	c7 04 24 57 22 80 00 	movl   $0x802257,(%esp)
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
  8002c8:	e8 db 1c 00 00       	call   801fa8 <__udivdi3>
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
  800304:	e8 bb 1d 00 00       	call   8020c4 <__umoddi3>
  800309:	83 c4 14             	add    $0x14,%esp
  80030c:	0f be 80 87 22 80 00 	movsbl 0x802287(%eax),%eax
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
  800450:	ff 24 85 c0 23 80 00 	jmp    *0x8023c0(,%eax,4)
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
  8004fc:	8b 04 85 20 25 80 00 	mov    0x802520(,%eax,4),%eax
  800503:	85 c0                	test   %eax,%eax
  800505:	75 1a                	jne    800521 <vprintfmt+0x15c>
				printfmt(putch, putdat, "error %d", err);
  800507:	52                   	push   %edx
  800508:	68 9f 22 80 00       	push   $0x80229f
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
  800522:	68 d5 27 80 00       	push   $0x8027d5
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
  800558:	c7 45 d0 98 22 80 00 	movl   $0x802298,-0x30(%ebp)
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
  800bc6:	68 7f 25 80 00       	push   $0x80257f
  800bcb:	6a 42                	push   $0x42
  800bcd:	68 9c 25 80 00       	push   $0x80259c
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

00800dd8 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800dd8:	55                   	push   %ebp
  800dd9:	89 e5                	mov    %esp,%ebp
  800ddb:	53                   	push   %ebx
  800ddc:	83 ec 04             	sub    $0x4,%esp
  800ddf:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800de2:	8b 18                	mov    (%eax),%ebx

	// LAB 4: Your code here.
	
	// cprintf("PAGE FAULT HANDLER, 0x%08x %d\n", (uint32_t)addr, err & FEC_WR);
	
	if ((err & FEC_WR) == 0)
  800de4:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800de8:	75 14                	jne    800dfe <pgfault+0x26>
		panic("pgfault, the fault is not a write\n");
  800dea:	83 ec 04             	sub    $0x4,%esp
  800ded:	68 ac 25 80 00       	push   $0x8025ac
  800df2:	6a 20                	push   $0x20
  800df4:	68 f0 26 80 00       	push   $0x8026f0
  800df9:	e8 8a f3 ff ff       	call   800188 <_panic>

	uint32_t uaddr = (uint32_t) addr;
	if ((uvpd[PDX(addr)] & PTE_P) == 0 || (uvpt[uaddr / PGSIZE] & PTE_COW) == 0) {
  800dfe:	89 d8                	mov    %ebx,%eax
  800e00:	c1 e8 16             	shr    $0x16,%eax
  800e03:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800e0a:	a8 01                	test   $0x1,%al
  800e0c:	74 11                	je     800e1f <pgfault+0x47>
  800e0e:	89 d8                	mov    %ebx,%eax
  800e10:	c1 e8 0c             	shr    $0xc,%eax
  800e13:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800e1a:	f6 c4 08             	test   $0x8,%ah
  800e1d:	75 14                	jne    800e33 <pgfault+0x5b>
		panic("pgfault, not a copy-on-write page\n");
  800e1f:	83 ec 04             	sub    $0x4,%esp
  800e22:	68 d0 25 80 00       	push   $0x8025d0
  800e27:	6a 24                	push   $0x24
  800e29:	68 f0 26 80 00       	push   $0x8026f0
  800e2e:	e8 55 f3 ff ff       	call   800188 <_panic>
	//   No need to explicitly delete the old page's mapping.

	// LAB 4: Your code here.

	// static int sys_page_alloc(envid_t envid, void *va, int perm)
	r = sys_page_alloc(0, (void *)PFTEMP, PTE_W | PTE_U | PTE_P);
  800e33:	83 ec 04             	sub    $0x4,%esp
  800e36:	6a 07                	push   $0x7
  800e38:	68 00 f0 7f 00       	push   $0x7ff000
  800e3d:	6a 00                	push   $0x0
  800e3f:	e8 54 fe ff ff       	call   800c98 <sys_page_alloc>
	if (r < 0) panic("pgfault, sys_page_alloc error : %e\n", r);
  800e44:	83 c4 10             	add    $0x10,%esp
  800e47:	85 c0                	test   %eax,%eax
  800e49:	79 12                	jns    800e5d <pgfault+0x85>
  800e4b:	50                   	push   %eax
  800e4c:	68 f4 25 80 00       	push   $0x8025f4
  800e51:	6a 32                	push   $0x32
  800e53:	68 f0 26 80 00       	push   $0x8026f0
  800e58:	e8 2b f3 ff ff       	call   800188 <_panic>

	// Oh my god, I forget this at the first, it waste me a lot of time to debug!!!
	addr = ROUNDDOWN(addr, PGSIZE);
  800e5d:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	
	memcpy(PFTEMP, addr, PGSIZE);
  800e63:	83 ec 04             	sub    $0x4,%esp
  800e66:	68 00 10 00 00       	push   $0x1000
  800e6b:	53                   	push   %ebx
  800e6c:	68 00 f0 7f 00       	push   $0x7ff000
  800e71:	e8 cb fb ff ff       	call   800a41 <memcpy>
	
	r = sys_page_map(0, PFTEMP, 0, addr, PTE_W | PTE_U | PTE_P);
  800e76:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800e7d:	53                   	push   %ebx
  800e7e:	6a 00                	push   $0x0
  800e80:	68 00 f0 7f 00       	push   $0x7ff000
  800e85:	6a 00                	push   $0x0
  800e87:	e8 30 fe ff ff       	call   800cbc <sys_page_map>
	if (r < 0) panic("pgfault, sys_page_map error : %e\n", r);
  800e8c:	83 c4 20             	add    $0x20,%esp
  800e8f:	85 c0                	test   %eax,%eax
  800e91:	79 12                	jns    800ea5 <pgfault+0xcd>
  800e93:	50                   	push   %eax
  800e94:	68 18 26 80 00       	push   $0x802618
  800e99:	6a 3a                	push   $0x3a
  800e9b:	68 f0 26 80 00       	push   $0x8026f0
  800ea0:	e8 e3 f2 ff ff       	call   800188 <_panic>

	return;
}
  800ea5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ea8:	c9                   	leave  
  800ea9:	c3                   	ret    

00800eaa <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800eaa:	55                   	push   %ebp
  800eab:	89 e5                	mov    %esp,%ebp
  800ead:	57                   	push   %edi
  800eae:	56                   	push   %esi
  800eaf:	53                   	push   %ebx
  800eb0:	83 ec 28             	sub    $0x28,%esp
	// static int num = 0x100;

	// LAB 4: Your code here.
	set_pgfault_handler(pgfault);
  800eb3:	68 d8 0d 80 00       	push   $0x800dd8
  800eb8:	e8 eb 0e 00 00       	call   801da8 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  800ebd:	ba 07 00 00 00       	mov    $0x7,%edx
  800ec2:	89 d0                	mov    %edx,%eax
  800ec4:	cd 30                	int    $0x30
  800ec6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800ec9:	89 c7                	mov    %eax,%edi
	int childpid = sys_exofork();
	if (childpid < 0) {
  800ecb:	83 c4 10             	add    $0x10,%esp
  800ece:	85 c0                	test   %eax,%eax
  800ed0:	79 12                	jns    800ee4 <fork+0x3a>
		panic("fork sys_exofork error : %e\n", childpid);
  800ed2:	50                   	push   %eax
  800ed3:	68 fb 26 80 00       	push   $0x8026fb
  800ed8:	6a 7f                	push   $0x7f
  800eda:	68 f0 26 80 00       	push   $0x8026f0
  800edf:	e8 a4 f2 ff ff       	call   800188 <_panic>
	}
	int r;

	if (childpid == 0) {
  800ee4:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800ee8:	75 25                	jne    800f0f <fork+0x65>
		// child process
		// Remember to fix "thisenv" in the child process. ??? 
		thisenv = &envs[ENVX(sys_getenvid())];
  800eea:	e8 5e fd ff ff       	call   800c4d <sys_getenvid>
  800eef:	25 ff 03 00 00       	and    $0x3ff,%eax
  800ef4:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800efb:	c1 e0 07             	shl    $0x7,%eax
  800efe:	29 d0                	sub    %edx,%eax
  800f00:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800f05:	a3 08 40 80 00       	mov    %eax,0x804008
		// cprintf("fork child ok\n");
		return 0;
  800f0a:	e9 be 01 00 00       	jmp    8010cd <fork+0x223>
	if (childpid < 0) {
		panic("fork sys_exofork error : %e\n", childpid);
	}
	int r;

	if (childpid == 0) {
  800f0f:	bb 00 00 00 00       	mov    $0x0,%ebx
	} else {
		// map page to new environment
		// kernel page is already in new environment
		uint32_t i;
		for (i = 0; i != UTOP; i += PGSIZE) 
		if ((uvpd[PDX(i)] & PTE_P) && (uvpt[i / PGSIZE] & PTE_P) && (uvpt[i / PGSIZE] & PTE_U)) {
  800f14:	89 d8                	mov    %ebx,%eax
  800f16:	c1 e8 16             	shr    $0x16,%eax
  800f19:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800f20:	a8 01                	test   $0x1,%al
  800f22:	0f 84 10 01 00 00    	je     801038 <fork+0x18e>
  800f28:	89 d8                	mov    %ebx,%eax
  800f2a:	c1 e8 0c             	shr    $0xc,%eax
  800f2d:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800f34:	f6 c2 01             	test   $0x1,%dl
  800f37:	0f 84 fb 00 00 00    	je     801038 <fork+0x18e>
  800f3d:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800f44:	f6 c2 04             	test   $0x4,%dl
  800f47:	0f 84 eb 00 00 00    	je     801038 <fork+0x18e>
//
static int
duppage(envid_t envid, unsigned pn)
{
	// do not dup exception stack
	if (pn * PGSIZE == UXSTACKTOP - PGSIZE) return 0;
  800f4d:	89 c6                	mov    %eax,%esi
  800f4f:	c1 e6 0c             	shl    $0xc,%esi
  800f52:	81 fe 00 f0 bf ee    	cmp    $0xeebff000,%esi
  800f58:	0f 84 da 00 00 00    	je     801038 <fork+0x18e>

	int r;
	void * addr = (void *)(pn * PGSIZE);
    if (uvpt[pn] & PTE_SHARE) {
  800f5e:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800f65:	f6 c6 04             	test   $0x4,%dh
  800f68:	74 37                	je     800fa1 <fork+0xf7>
        r = sys_page_map(0, addr, envid, addr, uvpt[pn] & PTE_SYSCALL);
  800f6a:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f71:	83 ec 0c             	sub    $0xc,%esp
  800f74:	25 07 0e 00 00       	and    $0xe07,%eax
  800f79:	50                   	push   %eax
  800f7a:	56                   	push   %esi
  800f7b:	57                   	push   %edi
  800f7c:	56                   	push   %esi
  800f7d:	6a 00                	push   $0x0
  800f7f:	e8 38 fd ff ff       	call   800cbc <sys_page_map>
        if (r < 0) panic("duppage sys_page_map error : %e\n", r);
  800f84:	83 c4 20             	add    $0x20,%esp
  800f87:	85 c0                	test   %eax,%eax
  800f89:	0f 89 a9 00 00 00    	jns    801038 <fork+0x18e>
  800f8f:	50                   	push   %eax
  800f90:	68 3c 26 80 00       	push   $0x80263c
  800f95:	6a 54                	push   $0x54
  800f97:	68 f0 26 80 00       	push   $0x8026f0
  800f9c:	e8 e7 f1 ff ff       	call   800188 <_panic>
    } else
	if ((uvpt[pn] & PTE_W) || (uvpt[pn] & PTE_COW)) {
  800fa1:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800fa8:	f6 c2 02             	test   $0x2,%dl
  800fab:	75 0c                	jne    800fb9 <fork+0x10f>
  800fad:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800fb4:	f6 c4 08             	test   $0x8,%ah
  800fb7:	74 57                	je     801010 <fork+0x166>
		// cow
		r = sys_page_map(0, addr, envid, addr, PTE_COW | PTE_P | PTE_U);
  800fb9:	83 ec 0c             	sub    $0xc,%esp
  800fbc:	68 05 08 00 00       	push   $0x805
  800fc1:	56                   	push   %esi
  800fc2:	57                   	push   %edi
  800fc3:	56                   	push   %esi
  800fc4:	6a 00                	push   $0x0
  800fc6:	e8 f1 fc ff ff       	call   800cbc <sys_page_map>
		if (r < 0) panic("duppage sys_page_map error : %e\n", r);
  800fcb:	83 c4 20             	add    $0x20,%esp
  800fce:	85 c0                	test   %eax,%eax
  800fd0:	79 12                	jns    800fe4 <fork+0x13a>
  800fd2:	50                   	push   %eax
  800fd3:	68 3c 26 80 00       	push   $0x80263c
  800fd8:	6a 59                	push   $0x59
  800fda:	68 f0 26 80 00       	push   $0x8026f0
  800fdf:	e8 a4 f1 ff ff       	call   800188 <_panic>
		
		r = sys_page_map(0, addr, 0, addr, PTE_COW | PTE_P | PTE_U);
  800fe4:	83 ec 0c             	sub    $0xc,%esp
  800fe7:	68 05 08 00 00       	push   $0x805
  800fec:	56                   	push   %esi
  800fed:	6a 00                	push   $0x0
  800fef:	56                   	push   %esi
  800ff0:	6a 00                	push   $0x0
  800ff2:	e8 c5 fc ff ff       	call   800cbc <sys_page_map>
		if (r < 0) panic("duppage sys_page_map error : %e\n", r);
  800ff7:	83 c4 20             	add    $0x20,%esp
  800ffa:	85 c0                	test   %eax,%eax
  800ffc:	79 3a                	jns    801038 <fork+0x18e>
  800ffe:	50                   	push   %eax
  800fff:	68 3c 26 80 00       	push   $0x80263c
  801004:	6a 5c                	push   $0x5c
  801006:	68 f0 26 80 00       	push   $0x8026f0
  80100b:	e8 78 f1 ff ff       	call   800188 <_panic>
	} else {
		// read only
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U);
  801010:	83 ec 0c             	sub    $0xc,%esp
  801013:	6a 05                	push   $0x5
  801015:	56                   	push   %esi
  801016:	57                   	push   %edi
  801017:	56                   	push   %esi
  801018:	6a 00                	push   $0x0
  80101a:	e8 9d fc ff ff       	call   800cbc <sys_page_map>
		if (r < 0) panic("duppage sys_page_map error : %e\n", r);
  80101f:	83 c4 20             	add    $0x20,%esp
  801022:	85 c0                	test   %eax,%eax
  801024:	79 12                	jns    801038 <fork+0x18e>
  801026:	50                   	push   %eax
  801027:	68 3c 26 80 00       	push   $0x80263c
  80102c:	6a 60                	push   $0x60
  80102e:	68 f0 26 80 00       	push   $0x8026f0
  801033:	e8 50 f1 ff ff       	call   800188 <_panic>
		return 0;
	} else {
		// map page to new environment
		// kernel page is already in new environment
		uint32_t i;
		for (i = 0; i != UTOP; i += PGSIZE) 
  801038:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  80103e:	81 fb 00 00 c0 ee    	cmp    $0xeec00000,%ebx
  801044:	0f 85 ca fe ff ff    	jne    800f14 <fork+0x6a>
		if ((uvpd[PDX(i)] & PTE_P) && (uvpt[i / PGSIZE] & PTE_P) && (uvpt[i / PGSIZE] & PTE_U)) {
			duppage(childpid, i / PGSIZE);
		}

		// allocate exception stack
		r = sys_page_alloc(childpid, (void *)(UXSTACKTOP - PGSIZE), PTE_U | PTE_W | PTE_P);
  80104a:	83 ec 04             	sub    $0x4,%esp
  80104d:	6a 07                	push   $0x7
  80104f:	68 00 f0 bf ee       	push   $0xeebff000
  801054:	ff 75 e4             	pushl  -0x1c(%ebp)
  801057:	e8 3c fc ff ff       	call   800c98 <sys_page_alloc>
		if (r < 0) panic("fork, sys_page_alloc user exception stack error : %e\n", r);
  80105c:	83 c4 10             	add    $0x10,%esp
  80105f:	85 c0                	test   %eax,%eax
  801061:	79 15                	jns    801078 <fork+0x1ce>
  801063:	50                   	push   %eax
  801064:	68 60 26 80 00       	push   $0x802660
  801069:	68 94 00 00 00       	push   $0x94
  80106e:	68 f0 26 80 00       	push   $0x8026f0
  801073:	e8 10 f1 ff ff       	call   800188 <_panic>

		// set user environment user page fault handler 
		extern void _pgfault_upcall(void);
		r = sys_env_set_pgfault_upcall(childpid, _pgfault_upcall);
  801078:	83 ec 08             	sub    $0x8,%esp
  80107b:	68 14 1e 80 00       	push   $0x801e14
  801080:	ff 75 e4             	pushl  -0x1c(%ebp)
  801083:	e8 c3 fc ff ff       	call   800d4b <sys_env_set_pgfault_upcall>
		if (r < 0) panic("fork, set pgfault upcall fail : %e\n", r);
  801088:	83 c4 10             	add    $0x10,%esp
  80108b:	85 c0                	test   %eax,%eax
  80108d:	79 15                	jns    8010a4 <fork+0x1fa>
  80108f:	50                   	push   %eax
  801090:	68 98 26 80 00       	push   $0x802698
  801095:	68 99 00 00 00       	push   $0x99
  80109a:	68 f0 26 80 00       	push   $0x8026f0
  80109f:	e8 e4 f0 ff ff       	call   800188 <_panic>
		r = sys_set_priority(childpid, num);
		if (r < 0) panic("fork, set priority error\n");
		*/

		// mark the child as runnable and return
		r = sys_env_set_status(childpid, ENV_RUNNABLE);
  8010a4:	83 ec 08             	sub    $0x8,%esp
  8010a7:	6a 02                	push   $0x2
  8010a9:	ff 75 e4             	pushl  -0x1c(%ebp)
  8010ac:	e8 54 fc ff ff       	call   800d05 <sys_env_set_status>
		if (r < 0) panic("fork, set child process to ENV_RUNNABLE error : %e\n", r);
  8010b1:	83 c4 10             	add    $0x10,%esp
  8010b4:	85 c0                	test   %eax,%eax
  8010b6:	79 15                	jns    8010cd <fork+0x223>
  8010b8:	50                   	push   %eax
  8010b9:	68 bc 26 80 00       	push   $0x8026bc
  8010be:	68 a4 00 00 00       	push   $0xa4
  8010c3:	68 f0 26 80 00       	push   $0x8026f0
  8010c8:	e8 bb f0 ff ff       	call   800188 <_panic>
		// cprintf("fork father ok!")
		return childpid;
	}

	panic("fork not implemented");
}
  8010cd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8010d0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010d3:	5b                   	pop    %ebx
  8010d4:	5e                   	pop    %esi
  8010d5:	5f                   	pop    %edi
  8010d6:	c9                   	leave  
  8010d7:	c3                   	ret    

008010d8 <sfork>:

// Challenge!
int
sfork(void)
{
  8010d8:	55                   	push   %ebp
  8010d9:	89 e5                	mov    %esp,%ebp
  8010db:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  8010de:	68 18 27 80 00       	push   $0x802718
  8010e3:	68 b1 00 00 00       	push   $0xb1
  8010e8:	68 f0 26 80 00       	push   $0x8026f0
  8010ed:	e8 96 f0 ff ff       	call   800188 <_panic>
	...

008010f4 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8010f4:	55                   	push   %ebp
  8010f5:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8010f7:	8b 45 08             	mov    0x8(%ebp),%eax
  8010fa:	05 00 00 00 30       	add    $0x30000000,%eax
  8010ff:	c1 e8 0c             	shr    $0xc,%eax
}
  801102:	c9                   	leave  
  801103:	c3                   	ret    

00801104 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801104:	55                   	push   %ebp
  801105:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  801107:	ff 75 08             	pushl  0x8(%ebp)
  80110a:	e8 e5 ff ff ff       	call   8010f4 <fd2num>
  80110f:	83 c4 04             	add    $0x4,%esp
  801112:	05 20 00 0d 00       	add    $0xd0020,%eax
  801117:	c1 e0 0c             	shl    $0xc,%eax
}
  80111a:	c9                   	leave  
  80111b:	c3                   	ret    

0080111c <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80111c:	55                   	push   %ebp
  80111d:	89 e5                	mov    %esp,%ebp
  80111f:	53                   	push   %ebx
  801120:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801123:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  801128:	a8 01                	test   $0x1,%al
  80112a:	74 34                	je     801160 <fd_alloc+0x44>
  80112c:	a1 00 00 74 ef       	mov    0xef740000,%eax
  801131:	a8 01                	test   $0x1,%al
  801133:	74 32                	je     801167 <fd_alloc+0x4b>
  801135:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
  80113a:	89 c1                	mov    %eax,%ecx
  80113c:	89 c2                	mov    %eax,%edx
  80113e:	c1 ea 16             	shr    $0x16,%edx
  801141:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801148:	f6 c2 01             	test   $0x1,%dl
  80114b:	74 1f                	je     80116c <fd_alloc+0x50>
  80114d:	89 c2                	mov    %eax,%edx
  80114f:	c1 ea 0c             	shr    $0xc,%edx
  801152:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801159:	f6 c2 01             	test   $0x1,%dl
  80115c:	75 17                	jne    801175 <fd_alloc+0x59>
  80115e:	eb 0c                	jmp    80116c <fd_alloc+0x50>
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  801160:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
  801165:	eb 05                	jmp    80116c <fd_alloc+0x50>
  801167:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
  80116c:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  80116e:	b8 00 00 00 00       	mov    $0x0,%eax
  801173:	eb 17                	jmp    80118c <fd_alloc+0x70>
  801175:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  80117a:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80117f:	75 b9                	jne    80113a <fd_alloc+0x1e>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801181:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  801187:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  80118c:	5b                   	pop    %ebx
  80118d:	c9                   	leave  
  80118e:	c3                   	ret    

0080118f <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80118f:	55                   	push   %ebp
  801190:	89 e5                	mov    %esp,%ebp
  801192:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801195:	83 f8 1f             	cmp    $0x1f,%eax
  801198:	77 36                	ja     8011d0 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80119a:	05 00 00 0d 00       	add    $0xd0000,%eax
  80119f:	c1 e0 0c             	shl    $0xc,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8011a2:	89 c2                	mov    %eax,%edx
  8011a4:	c1 ea 16             	shr    $0x16,%edx
  8011a7:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8011ae:	f6 c2 01             	test   $0x1,%dl
  8011b1:	74 24                	je     8011d7 <fd_lookup+0x48>
  8011b3:	89 c2                	mov    %eax,%edx
  8011b5:	c1 ea 0c             	shr    $0xc,%edx
  8011b8:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8011bf:	f6 c2 01             	test   $0x1,%dl
  8011c2:	74 1a                	je     8011de <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8011c4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8011c7:	89 02                	mov    %eax,(%edx)
	return 0;
  8011c9:	b8 00 00 00 00       	mov    $0x0,%eax
  8011ce:	eb 13                	jmp    8011e3 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8011d0:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8011d5:	eb 0c                	jmp    8011e3 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8011d7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8011dc:	eb 05                	jmp    8011e3 <fd_lookup+0x54>
  8011de:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8011e3:	c9                   	leave  
  8011e4:	c3                   	ret    

008011e5 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8011e5:	55                   	push   %ebp
  8011e6:	89 e5                	mov    %esp,%ebp
  8011e8:	53                   	push   %ebx
  8011e9:	83 ec 04             	sub    $0x4,%esp
  8011ec:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8011ef:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  8011f2:	39 0d 04 30 80 00    	cmp    %ecx,0x803004
  8011f8:	74 0d                	je     801207 <dev_lookup+0x22>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8011fa:	b8 00 00 00 00       	mov    $0x0,%eax
  8011ff:	eb 14                	jmp    801215 <dev_lookup+0x30>
		if (devtab[i]->dev_id == dev_id) {
  801201:	39 0a                	cmp    %ecx,(%edx)
  801203:	75 10                	jne    801215 <dev_lookup+0x30>
  801205:	eb 05                	jmp    80120c <dev_lookup+0x27>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801207:	ba 04 30 80 00       	mov    $0x803004,%edx
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
  80120c:	89 13                	mov    %edx,(%ebx)
			return 0;
  80120e:	b8 00 00 00 00       	mov    $0x0,%eax
  801213:	eb 31                	jmp    801246 <dev_lookup+0x61>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801215:	40                   	inc    %eax
  801216:	8b 14 85 ac 27 80 00 	mov    0x8027ac(,%eax,4),%edx
  80121d:	85 d2                	test   %edx,%edx
  80121f:	75 e0                	jne    801201 <dev_lookup+0x1c>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801221:	a1 08 40 80 00       	mov    0x804008,%eax
  801226:	8b 40 48             	mov    0x48(%eax),%eax
  801229:	83 ec 04             	sub    $0x4,%esp
  80122c:	51                   	push   %ecx
  80122d:	50                   	push   %eax
  80122e:	68 30 27 80 00       	push   $0x802730
  801233:	e8 28 f0 ff ff       	call   800260 <cprintf>
	*dev = 0;
  801238:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  80123e:	83 c4 10             	add    $0x10,%esp
  801241:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801246:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801249:	c9                   	leave  
  80124a:	c3                   	ret    

0080124b <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80124b:	55                   	push   %ebp
  80124c:	89 e5                	mov    %esp,%ebp
  80124e:	56                   	push   %esi
  80124f:	53                   	push   %ebx
  801250:	83 ec 20             	sub    $0x20,%esp
  801253:	8b 75 08             	mov    0x8(%ebp),%esi
  801256:	8a 45 0c             	mov    0xc(%ebp),%al
  801259:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80125c:	56                   	push   %esi
  80125d:	e8 92 fe ff ff       	call   8010f4 <fd2num>
  801262:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801265:	89 14 24             	mov    %edx,(%esp)
  801268:	50                   	push   %eax
  801269:	e8 21 ff ff ff       	call   80118f <fd_lookup>
  80126e:	89 c3                	mov    %eax,%ebx
  801270:	83 c4 08             	add    $0x8,%esp
  801273:	85 c0                	test   %eax,%eax
  801275:	78 05                	js     80127c <fd_close+0x31>
	    || fd != fd2)
  801277:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80127a:	74 0d                	je     801289 <fd_close+0x3e>
		return (must_exist ? r : 0);
  80127c:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  801280:	75 48                	jne    8012ca <fd_close+0x7f>
  801282:	bb 00 00 00 00       	mov    $0x0,%ebx
  801287:	eb 41                	jmp    8012ca <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801289:	83 ec 08             	sub    $0x8,%esp
  80128c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80128f:	50                   	push   %eax
  801290:	ff 36                	pushl  (%esi)
  801292:	e8 4e ff ff ff       	call   8011e5 <dev_lookup>
  801297:	89 c3                	mov    %eax,%ebx
  801299:	83 c4 10             	add    $0x10,%esp
  80129c:	85 c0                	test   %eax,%eax
  80129e:	78 1c                	js     8012bc <fd_close+0x71>
		if (dev->dev_close)
  8012a0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012a3:	8b 40 10             	mov    0x10(%eax),%eax
  8012a6:	85 c0                	test   %eax,%eax
  8012a8:	74 0d                	je     8012b7 <fd_close+0x6c>
			r = (*dev->dev_close)(fd);
  8012aa:	83 ec 0c             	sub    $0xc,%esp
  8012ad:	56                   	push   %esi
  8012ae:	ff d0                	call   *%eax
  8012b0:	89 c3                	mov    %eax,%ebx
  8012b2:	83 c4 10             	add    $0x10,%esp
  8012b5:	eb 05                	jmp    8012bc <fd_close+0x71>
		else
			r = 0;
  8012b7:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8012bc:	83 ec 08             	sub    $0x8,%esp
  8012bf:	56                   	push   %esi
  8012c0:	6a 00                	push   $0x0
  8012c2:	e8 1b fa ff ff       	call   800ce2 <sys_page_unmap>
	return r;
  8012c7:	83 c4 10             	add    $0x10,%esp
}
  8012ca:	89 d8                	mov    %ebx,%eax
  8012cc:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8012cf:	5b                   	pop    %ebx
  8012d0:	5e                   	pop    %esi
  8012d1:	c9                   	leave  
  8012d2:	c3                   	ret    

008012d3 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8012d3:	55                   	push   %ebp
  8012d4:	89 e5                	mov    %esp,%ebp
  8012d6:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8012d9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012dc:	50                   	push   %eax
  8012dd:	ff 75 08             	pushl  0x8(%ebp)
  8012e0:	e8 aa fe ff ff       	call   80118f <fd_lookup>
  8012e5:	83 c4 08             	add    $0x8,%esp
  8012e8:	85 c0                	test   %eax,%eax
  8012ea:	78 10                	js     8012fc <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  8012ec:	83 ec 08             	sub    $0x8,%esp
  8012ef:	6a 01                	push   $0x1
  8012f1:	ff 75 f4             	pushl  -0xc(%ebp)
  8012f4:	e8 52 ff ff ff       	call   80124b <fd_close>
  8012f9:	83 c4 10             	add    $0x10,%esp
}
  8012fc:	c9                   	leave  
  8012fd:	c3                   	ret    

008012fe <close_all>:

void
close_all(void)
{
  8012fe:	55                   	push   %ebp
  8012ff:	89 e5                	mov    %esp,%ebp
  801301:	53                   	push   %ebx
  801302:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801305:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80130a:	83 ec 0c             	sub    $0xc,%esp
  80130d:	53                   	push   %ebx
  80130e:	e8 c0 ff ff ff       	call   8012d3 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801313:	43                   	inc    %ebx
  801314:	83 c4 10             	add    $0x10,%esp
  801317:	83 fb 20             	cmp    $0x20,%ebx
  80131a:	75 ee                	jne    80130a <close_all+0xc>
		close(i);
}
  80131c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80131f:	c9                   	leave  
  801320:	c3                   	ret    

00801321 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801321:	55                   	push   %ebp
  801322:	89 e5                	mov    %esp,%ebp
  801324:	57                   	push   %edi
  801325:	56                   	push   %esi
  801326:	53                   	push   %ebx
  801327:	83 ec 2c             	sub    $0x2c,%esp
  80132a:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80132d:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801330:	50                   	push   %eax
  801331:	ff 75 08             	pushl  0x8(%ebp)
  801334:	e8 56 fe ff ff       	call   80118f <fd_lookup>
  801339:	89 c3                	mov    %eax,%ebx
  80133b:	83 c4 08             	add    $0x8,%esp
  80133e:	85 c0                	test   %eax,%eax
  801340:	0f 88 c0 00 00 00    	js     801406 <dup+0xe5>
		return r;
	close(newfdnum);
  801346:	83 ec 0c             	sub    $0xc,%esp
  801349:	57                   	push   %edi
  80134a:	e8 84 ff ff ff       	call   8012d3 <close>

	newfd = INDEX2FD(newfdnum);
  80134f:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  801355:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  801358:	83 c4 04             	add    $0x4,%esp
  80135b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80135e:	e8 a1 fd ff ff       	call   801104 <fd2data>
  801363:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801365:	89 34 24             	mov    %esi,(%esp)
  801368:	e8 97 fd ff ff       	call   801104 <fd2data>
  80136d:	83 c4 10             	add    $0x10,%esp
  801370:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801373:	89 d8                	mov    %ebx,%eax
  801375:	c1 e8 16             	shr    $0x16,%eax
  801378:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80137f:	a8 01                	test   $0x1,%al
  801381:	74 37                	je     8013ba <dup+0x99>
  801383:	89 d8                	mov    %ebx,%eax
  801385:	c1 e8 0c             	shr    $0xc,%eax
  801388:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80138f:	f6 c2 01             	test   $0x1,%dl
  801392:	74 26                	je     8013ba <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801394:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80139b:	83 ec 0c             	sub    $0xc,%esp
  80139e:	25 07 0e 00 00       	and    $0xe07,%eax
  8013a3:	50                   	push   %eax
  8013a4:	ff 75 d4             	pushl  -0x2c(%ebp)
  8013a7:	6a 00                	push   $0x0
  8013a9:	53                   	push   %ebx
  8013aa:	6a 00                	push   $0x0
  8013ac:	e8 0b f9 ff ff       	call   800cbc <sys_page_map>
  8013b1:	89 c3                	mov    %eax,%ebx
  8013b3:	83 c4 20             	add    $0x20,%esp
  8013b6:	85 c0                	test   %eax,%eax
  8013b8:	78 2d                	js     8013e7 <dup+0xc6>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8013ba:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8013bd:	89 c2                	mov    %eax,%edx
  8013bf:	c1 ea 0c             	shr    $0xc,%edx
  8013c2:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8013c9:	83 ec 0c             	sub    $0xc,%esp
  8013cc:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  8013d2:	52                   	push   %edx
  8013d3:	56                   	push   %esi
  8013d4:	6a 00                	push   $0x0
  8013d6:	50                   	push   %eax
  8013d7:	6a 00                	push   $0x0
  8013d9:	e8 de f8 ff ff       	call   800cbc <sys_page_map>
  8013de:	89 c3                	mov    %eax,%ebx
  8013e0:	83 c4 20             	add    $0x20,%esp
  8013e3:	85 c0                	test   %eax,%eax
  8013e5:	79 1d                	jns    801404 <dup+0xe3>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8013e7:	83 ec 08             	sub    $0x8,%esp
  8013ea:	56                   	push   %esi
  8013eb:	6a 00                	push   $0x0
  8013ed:	e8 f0 f8 ff ff       	call   800ce2 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8013f2:	83 c4 08             	add    $0x8,%esp
  8013f5:	ff 75 d4             	pushl  -0x2c(%ebp)
  8013f8:	6a 00                	push   $0x0
  8013fa:	e8 e3 f8 ff ff       	call   800ce2 <sys_page_unmap>
	return r;
  8013ff:	83 c4 10             	add    $0x10,%esp
  801402:	eb 02                	jmp    801406 <dup+0xe5>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  801404:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  801406:	89 d8                	mov    %ebx,%eax
  801408:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80140b:	5b                   	pop    %ebx
  80140c:	5e                   	pop    %esi
  80140d:	5f                   	pop    %edi
  80140e:	c9                   	leave  
  80140f:	c3                   	ret    

00801410 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801410:	55                   	push   %ebp
  801411:	89 e5                	mov    %esp,%ebp
  801413:	53                   	push   %ebx
  801414:	83 ec 14             	sub    $0x14,%esp
  801417:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80141a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80141d:	50                   	push   %eax
  80141e:	53                   	push   %ebx
  80141f:	e8 6b fd ff ff       	call   80118f <fd_lookup>
  801424:	83 c4 08             	add    $0x8,%esp
  801427:	85 c0                	test   %eax,%eax
  801429:	78 67                	js     801492 <read+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80142b:	83 ec 08             	sub    $0x8,%esp
  80142e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801431:	50                   	push   %eax
  801432:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801435:	ff 30                	pushl  (%eax)
  801437:	e8 a9 fd ff ff       	call   8011e5 <dev_lookup>
  80143c:	83 c4 10             	add    $0x10,%esp
  80143f:	85 c0                	test   %eax,%eax
  801441:	78 4f                	js     801492 <read+0x82>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801443:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801446:	8b 50 08             	mov    0x8(%eax),%edx
  801449:	83 e2 03             	and    $0x3,%edx
  80144c:	83 fa 01             	cmp    $0x1,%edx
  80144f:	75 21                	jne    801472 <read+0x62>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801451:	a1 08 40 80 00       	mov    0x804008,%eax
  801456:	8b 40 48             	mov    0x48(%eax),%eax
  801459:	83 ec 04             	sub    $0x4,%esp
  80145c:	53                   	push   %ebx
  80145d:	50                   	push   %eax
  80145e:	68 71 27 80 00       	push   $0x802771
  801463:	e8 f8 ed ff ff       	call   800260 <cprintf>
		return -E_INVAL;
  801468:	83 c4 10             	add    $0x10,%esp
  80146b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801470:	eb 20                	jmp    801492 <read+0x82>
	}
	if (!dev->dev_read)
  801472:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801475:	8b 52 08             	mov    0x8(%edx),%edx
  801478:	85 d2                	test   %edx,%edx
  80147a:	74 11                	je     80148d <read+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80147c:	83 ec 04             	sub    $0x4,%esp
  80147f:	ff 75 10             	pushl  0x10(%ebp)
  801482:	ff 75 0c             	pushl  0xc(%ebp)
  801485:	50                   	push   %eax
  801486:	ff d2                	call   *%edx
  801488:	83 c4 10             	add    $0x10,%esp
  80148b:	eb 05                	jmp    801492 <read+0x82>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80148d:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  801492:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801495:	c9                   	leave  
  801496:	c3                   	ret    

00801497 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801497:	55                   	push   %ebp
  801498:	89 e5                	mov    %esp,%ebp
  80149a:	57                   	push   %edi
  80149b:	56                   	push   %esi
  80149c:	53                   	push   %ebx
  80149d:	83 ec 0c             	sub    $0xc,%esp
  8014a0:	8b 7d 08             	mov    0x8(%ebp),%edi
  8014a3:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8014a6:	85 f6                	test   %esi,%esi
  8014a8:	74 31                	je     8014db <readn+0x44>
  8014aa:	b8 00 00 00 00       	mov    $0x0,%eax
  8014af:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = read(fdnum, (char*)buf + tot, n - tot);
  8014b4:	83 ec 04             	sub    $0x4,%esp
  8014b7:	89 f2                	mov    %esi,%edx
  8014b9:	29 c2                	sub    %eax,%edx
  8014bb:	52                   	push   %edx
  8014bc:	03 45 0c             	add    0xc(%ebp),%eax
  8014bf:	50                   	push   %eax
  8014c0:	57                   	push   %edi
  8014c1:	e8 4a ff ff ff       	call   801410 <read>
		if (m < 0)
  8014c6:	83 c4 10             	add    $0x10,%esp
  8014c9:	85 c0                	test   %eax,%eax
  8014cb:	78 17                	js     8014e4 <readn+0x4d>
			return m;
		if (m == 0)
  8014cd:	85 c0                	test   %eax,%eax
  8014cf:	74 11                	je     8014e2 <readn+0x4b>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8014d1:	01 c3                	add    %eax,%ebx
  8014d3:	89 d8                	mov    %ebx,%eax
  8014d5:	39 f3                	cmp    %esi,%ebx
  8014d7:	72 db                	jb     8014b4 <readn+0x1d>
  8014d9:	eb 09                	jmp    8014e4 <readn+0x4d>
  8014db:	b8 00 00 00 00       	mov    $0x0,%eax
  8014e0:	eb 02                	jmp    8014e4 <readn+0x4d>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  8014e2:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  8014e4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8014e7:	5b                   	pop    %ebx
  8014e8:	5e                   	pop    %esi
  8014e9:	5f                   	pop    %edi
  8014ea:	c9                   	leave  
  8014eb:	c3                   	ret    

008014ec <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8014ec:	55                   	push   %ebp
  8014ed:	89 e5                	mov    %esp,%ebp
  8014ef:	53                   	push   %ebx
  8014f0:	83 ec 14             	sub    $0x14,%esp
  8014f3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8014f6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014f9:	50                   	push   %eax
  8014fa:	53                   	push   %ebx
  8014fb:	e8 8f fc ff ff       	call   80118f <fd_lookup>
  801500:	83 c4 08             	add    $0x8,%esp
  801503:	85 c0                	test   %eax,%eax
  801505:	78 62                	js     801569 <write+0x7d>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801507:	83 ec 08             	sub    $0x8,%esp
  80150a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80150d:	50                   	push   %eax
  80150e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801511:	ff 30                	pushl  (%eax)
  801513:	e8 cd fc ff ff       	call   8011e5 <dev_lookup>
  801518:	83 c4 10             	add    $0x10,%esp
  80151b:	85 c0                	test   %eax,%eax
  80151d:	78 4a                	js     801569 <write+0x7d>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80151f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801522:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801526:	75 21                	jne    801549 <write+0x5d>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801528:	a1 08 40 80 00       	mov    0x804008,%eax
  80152d:	8b 40 48             	mov    0x48(%eax),%eax
  801530:	83 ec 04             	sub    $0x4,%esp
  801533:	53                   	push   %ebx
  801534:	50                   	push   %eax
  801535:	68 8d 27 80 00       	push   $0x80278d
  80153a:	e8 21 ed ff ff       	call   800260 <cprintf>
		return -E_INVAL;
  80153f:	83 c4 10             	add    $0x10,%esp
  801542:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801547:	eb 20                	jmp    801569 <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801549:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80154c:	8b 52 0c             	mov    0xc(%edx),%edx
  80154f:	85 d2                	test   %edx,%edx
  801551:	74 11                	je     801564 <write+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801553:	83 ec 04             	sub    $0x4,%esp
  801556:	ff 75 10             	pushl  0x10(%ebp)
  801559:	ff 75 0c             	pushl  0xc(%ebp)
  80155c:	50                   	push   %eax
  80155d:	ff d2                	call   *%edx
  80155f:	83 c4 10             	add    $0x10,%esp
  801562:	eb 05                	jmp    801569 <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801564:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  801569:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80156c:	c9                   	leave  
  80156d:	c3                   	ret    

0080156e <seek>:

int
seek(int fdnum, off_t offset)
{
  80156e:	55                   	push   %ebp
  80156f:	89 e5                	mov    %esp,%ebp
  801571:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801574:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801577:	50                   	push   %eax
  801578:	ff 75 08             	pushl  0x8(%ebp)
  80157b:	e8 0f fc ff ff       	call   80118f <fd_lookup>
  801580:	83 c4 08             	add    $0x8,%esp
  801583:	85 c0                	test   %eax,%eax
  801585:	78 0e                	js     801595 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801587:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80158a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80158d:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801590:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801595:	c9                   	leave  
  801596:	c3                   	ret    

00801597 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801597:	55                   	push   %ebp
  801598:	89 e5                	mov    %esp,%ebp
  80159a:	53                   	push   %ebx
  80159b:	83 ec 14             	sub    $0x14,%esp
  80159e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015a1:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015a4:	50                   	push   %eax
  8015a5:	53                   	push   %ebx
  8015a6:	e8 e4 fb ff ff       	call   80118f <fd_lookup>
  8015ab:	83 c4 08             	add    $0x8,%esp
  8015ae:	85 c0                	test   %eax,%eax
  8015b0:	78 5f                	js     801611 <ftruncate+0x7a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015b2:	83 ec 08             	sub    $0x8,%esp
  8015b5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015b8:	50                   	push   %eax
  8015b9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015bc:	ff 30                	pushl  (%eax)
  8015be:	e8 22 fc ff ff       	call   8011e5 <dev_lookup>
  8015c3:	83 c4 10             	add    $0x10,%esp
  8015c6:	85 c0                	test   %eax,%eax
  8015c8:	78 47                	js     801611 <ftruncate+0x7a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8015ca:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015cd:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8015d1:	75 21                	jne    8015f4 <ftruncate+0x5d>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8015d3:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8015d8:	8b 40 48             	mov    0x48(%eax),%eax
  8015db:	83 ec 04             	sub    $0x4,%esp
  8015de:	53                   	push   %ebx
  8015df:	50                   	push   %eax
  8015e0:	68 50 27 80 00       	push   $0x802750
  8015e5:	e8 76 ec ff ff       	call   800260 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8015ea:	83 c4 10             	add    $0x10,%esp
  8015ed:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8015f2:	eb 1d                	jmp    801611 <ftruncate+0x7a>
	}
	if (!dev->dev_trunc)
  8015f4:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8015f7:	8b 52 18             	mov    0x18(%edx),%edx
  8015fa:	85 d2                	test   %edx,%edx
  8015fc:	74 0e                	je     80160c <ftruncate+0x75>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8015fe:	83 ec 08             	sub    $0x8,%esp
  801601:	ff 75 0c             	pushl  0xc(%ebp)
  801604:	50                   	push   %eax
  801605:	ff d2                	call   *%edx
  801607:	83 c4 10             	add    $0x10,%esp
  80160a:	eb 05                	jmp    801611 <ftruncate+0x7a>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80160c:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  801611:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801614:	c9                   	leave  
  801615:	c3                   	ret    

00801616 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801616:	55                   	push   %ebp
  801617:	89 e5                	mov    %esp,%ebp
  801619:	53                   	push   %ebx
  80161a:	83 ec 14             	sub    $0x14,%esp
  80161d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801620:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801623:	50                   	push   %eax
  801624:	ff 75 08             	pushl  0x8(%ebp)
  801627:	e8 63 fb ff ff       	call   80118f <fd_lookup>
  80162c:	83 c4 08             	add    $0x8,%esp
  80162f:	85 c0                	test   %eax,%eax
  801631:	78 52                	js     801685 <fstat+0x6f>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801633:	83 ec 08             	sub    $0x8,%esp
  801636:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801639:	50                   	push   %eax
  80163a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80163d:	ff 30                	pushl  (%eax)
  80163f:	e8 a1 fb ff ff       	call   8011e5 <dev_lookup>
  801644:	83 c4 10             	add    $0x10,%esp
  801647:	85 c0                	test   %eax,%eax
  801649:	78 3a                	js     801685 <fstat+0x6f>
		return r;
	if (!dev->dev_stat)
  80164b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80164e:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801652:	74 2c                	je     801680 <fstat+0x6a>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801654:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801657:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80165e:	00 00 00 
	stat->st_isdir = 0;
  801661:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801668:	00 00 00 
	stat->st_dev = dev;
  80166b:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801671:	83 ec 08             	sub    $0x8,%esp
  801674:	53                   	push   %ebx
  801675:	ff 75 f0             	pushl  -0x10(%ebp)
  801678:	ff 50 14             	call   *0x14(%eax)
  80167b:	83 c4 10             	add    $0x10,%esp
  80167e:	eb 05                	jmp    801685 <fstat+0x6f>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801680:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801685:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801688:	c9                   	leave  
  801689:	c3                   	ret    

0080168a <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80168a:	55                   	push   %ebp
  80168b:	89 e5                	mov    %esp,%ebp
  80168d:	56                   	push   %esi
  80168e:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80168f:	83 ec 08             	sub    $0x8,%esp
  801692:	6a 00                	push   $0x0
  801694:	ff 75 08             	pushl  0x8(%ebp)
  801697:	e8 78 01 00 00       	call   801814 <open>
  80169c:	89 c3                	mov    %eax,%ebx
  80169e:	83 c4 10             	add    $0x10,%esp
  8016a1:	85 c0                	test   %eax,%eax
  8016a3:	78 1b                	js     8016c0 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8016a5:	83 ec 08             	sub    $0x8,%esp
  8016a8:	ff 75 0c             	pushl  0xc(%ebp)
  8016ab:	50                   	push   %eax
  8016ac:	e8 65 ff ff ff       	call   801616 <fstat>
  8016b1:	89 c6                	mov    %eax,%esi
	close(fd);
  8016b3:	89 1c 24             	mov    %ebx,(%esp)
  8016b6:	e8 18 fc ff ff       	call   8012d3 <close>
	return r;
  8016bb:	83 c4 10             	add    $0x10,%esp
  8016be:	89 f3                	mov    %esi,%ebx
}
  8016c0:	89 d8                	mov    %ebx,%eax
  8016c2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8016c5:	5b                   	pop    %ebx
  8016c6:	5e                   	pop    %esi
  8016c7:	c9                   	leave  
  8016c8:	c3                   	ret    
  8016c9:	00 00                	add    %al,(%eax)
	...

008016cc <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8016cc:	55                   	push   %ebp
  8016cd:	89 e5                	mov    %esp,%ebp
  8016cf:	56                   	push   %esi
  8016d0:	53                   	push   %ebx
  8016d1:	89 c3                	mov    %eax,%ebx
  8016d3:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  8016d5:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8016dc:	75 12                	jne    8016f0 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8016de:	83 ec 0c             	sub    $0xc,%esp
  8016e1:	6a 01                	push   $0x1
  8016e3:	e8 1e 08 00 00       	call   801f06 <ipc_find_env>
  8016e8:	a3 00 40 80 00       	mov    %eax,0x804000
  8016ed:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8016f0:	6a 07                	push   $0x7
  8016f2:	68 00 50 80 00       	push   $0x805000
  8016f7:	53                   	push   %ebx
  8016f8:	ff 35 00 40 80 00    	pushl  0x804000
  8016fe:	e8 ae 07 00 00       	call   801eb1 <ipc_send>
	
	return ipc_recv(NULL, dstva, NULL);
  801703:	83 c4 0c             	add    $0xc,%esp
  801706:	6a 00                	push   $0x0
  801708:	56                   	push   %esi
  801709:	6a 00                	push   $0x0
  80170b:	e8 2c 07 00 00       	call   801e3c <ipc_recv>
}
  801710:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801713:	5b                   	pop    %ebx
  801714:	5e                   	pop    %esi
  801715:	c9                   	leave  
  801716:	c3                   	ret    

00801717 <devfile_stat>:
}


static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801717:	55                   	push   %ebp
  801718:	89 e5                	mov    %esp,%ebp
  80171a:	53                   	push   %ebx
  80171b:	83 ec 04             	sub    $0x4,%esp
  80171e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801721:	8b 45 08             	mov    0x8(%ebp),%eax
  801724:	8b 40 0c             	mov    0xc(%eax),%eax
  801727:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0) {
  80172c:	ba 00 00 00 00       	mov    $0x0,%edx
  801731:	b8 05 00 00 00       	mov    $0x5,%eax
  801736:	e8 91 ff ff ff       	call   8016cc <fsipc>
  80173b:	85 c0                	test   %eax,%eax
  80173d:	78 2c                	js     80176b <devfile_stat+0x54>
		return r;
	}
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80173f:	83 ec 08             	sub    $0x8,%esp
  801742:	68 00 50 80 00       	push   $0x805000
  801747:	53                   	push   %ebx
  801748:	e8 c9 f0 ff ff       	call   800816 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  80174d:	a1 80 50 80 00       	mov    0x805080,%eax
  801752:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801758:	a1 84 50 80 00       	mov    0x805084,%eax
  80175d:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801763:	83 c4 10             	add    $0x10,%esp
  801766:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80176b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80176e:	c9                   	leave  
  80176f:	c3                   	ret    

00801770 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801770:	55                   	push   %ebp
  801771:	89 e5                	mov    %esp,%ebp
  801773:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801776:	8b 45 08             	mov    0x8(%ebp),%eax
  801779:	8b 40 0c             	mov    0xc(%eax),%eax
  80177c:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801781:	ba 00 00 00 00       	mov    $0x0,%edx
  801786:	b8 06 00 00 00       	mov    $0x6,%eax
  80178b:	e8 3c ff ff ff       	call   8016cc <fsipc>
}
  801790:	c9                   	leave  
  801791:	c3                   	ret    

00801792 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801792:	55                   	push   %ebp
  801793:	89 e5                	mov    %esp,%ebp
  801795:	56                   	push   %esi
  801796:	53                   	push   %ebx
  801797:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80179a:	8b 45 08             	mov    0x8(%ebp),%eax
  80179d:	8b 40 0c             	mov    0xc(%eax),%eax
  8017a0:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8017a5:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8017ab:	ba 00 00 00 00       	mov    $0x0,%edx
  8017b0:	b8 03 00 00 00       	mov    $0x3,%eax
  8017b5:	e8 12 ff ff ff       	call   8016cc <fsipc>
  8017ba:	89 c3                	mov    %eax,%ebx
  8017bc:	85 c0                	test   %eax,%eax
  8017be:	78 4b                	js     80180b <devfile_read+0x79>
		return r;
	assert(r <= n);
  8017c0:	39 c6                	cmp    %eax,%esi
  8017c2:	73 16                	jae    8017da <devfile_read+0x48>
  8017c4:	68 bc 27 80 00       	push   $0x8027bc
  8017c9:	68 c3 27 80 00       	push   $0x8027c3
  8017ce:	6a 7d                	push   $0x7d
  8017d0:	68 d8 27 80 00       	push   $0x8027d8
  8017d5:	e8 ae e9 ff ff       	call   800188 <_panic>
	assert(r <= PGSIZE);
  8017da:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8017df:	7e 16                	jle    8017f7 <devfile_read+0x65>
  8017e1:	68 e3 27 80 00       	push   $0x8027e3
  8017e6:	68 c3 27 80 00       	push   $0x8027c3
  8017eb:	6a 7e                	push   $0x7e
  8017ed:	68 d8 27 80 00       	push   $0x8027d8
  8017f2:	e8 91 e9 ff ff       	call   800188 <_panic>
	memmove(buf, &fsipcbuf, r);
  8017f7:	83 ec 04             	sub    $0x4,%esp
  8017fa:	50                   	push   %eax
  8017fb:	68 00 50 80 00       	push   $0x805000
  801800:	ff 75 0c             	pushl  0xc(%ebp)
  801803:	e8 cf f1 ff ff       	call   8009d7 <memmove>
	return r;
  801808:	83 c4 10             	add    $0x10,%esp
}
  80180b:	89 d8                	mov    %ebx,%eax
  80180d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801810:	5b                   	pop    %ebx
  801811:	5e                   	pop    %esi
  801812:	c9                   	leave  
  801813:	c3                   	ret    

00801814 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801814:	55                   	push   %ebp
  801815:	89 e5                	mov    %esp,%ebp
  801817:	56                   	push   %esi
  801818:	53                   	push   %ebx
  801819:	83 ec 1c             	sub    $0x1c,%esp
  80181c:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  80181f:	56                   	push   %esi
  801820:	e8 9f ef ff ff       	call   8007c4 <strlen>
  801825:	83 c4 10             	add    $0x10,%esp
  801828:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  80182d:	7f 65                	jg     801894 <open+0x80>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80182f:	83 ec 0c             	sub    $0xc,%esp
  801832:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801835:	50                   	push   %eax
  801836:	e8 e1 f8 ff ff       	call   80111c <fd_alloc>
  80183b:	89 c3                	mov    %eax,%ebx
  80183d:	83 c4 10             	add    $0x10,%esp
  801840:	85 c0                	test   %eax,%eax
  801842:	78 55                	js     801899 <open+0x85>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801844:	83 ec 08             	sub    $0x8,%esp
  801847:	56                   	push   %esi
  801848:	68 00 50 80 00       	push   $0x805000
  80184d:	e8 c4 ef ff ff       	call   800816 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801852:	8b 45 0c             	mov    0xc(%ebp),%eax
  801855:	a3 00 54 80 00       	mov    %eax,0x805400



	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  80185a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80185d:	b8 01 00 00 00       	mov    $0x1,%eax
  801862:	e8 65 fe ff ff       	call   8016cc <fsipc>
  801867:	89 c3                	mov    %eax,%ebx
  801869:	83 c4 10             	add    $0x10,%esp
  80186c:	85 c0                	test   %eax,%eax
  80186e:	79 12                	jns    801882 <open+0x6e>
		fd_close(fd, 0);
  801870:	83 ec 08             	sub    $0x8,%esp
  801873:	6a 00                	push   $0x0
  801875:	ff 75 f4             	pushl  -0xc(%ebp)
  801878:	e8 ce f9 ff ff       	call   80124b <fd_close>
		return r;
  80187d:	83 c4 10             	add    $0x10,%esp
  801880:	eb 17                	jmp    801899 <open+0x85>
	}

	return fd2num(fd);
  801882:	83 ec 0c             	sub    $0xc,%esp
  801885:	ff 75 f4             	pushl  -0xc(%ebp)
  801888:	e8 67 f8 ff ff       	call   8010f4 <fd2num>
  80188d:	89 c3                	mov    %eax,%ebx
  80188f:	83 c4 10             	add    $0x10,%esp
  801892:	eb 05                	jmp    801899 <open+0x85>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801894:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801899:	89 d8                	mov    %ebx,%eax
  80189b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80189e:	5b                   	pop    %ebx
  80189f:	5e                   	pop    %esi
  8018a0:	c9                   	leave  
  8018a1:	c3                   	ret    
	...

008018a4 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8018a4:	55                   	push   %ebp
  8018a5:	89 e5                	mov    %esp,%ebp
  8018a7:	56                   	push   %esi
  8018a8:	53                   	push   %ebx
  8018a9:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8018ac:	83 ec 0c             	sub    $0xc,%esp
  8018af:	ff 75 08             	pushl  0x8(%ebp)
  8018b2:	e8 4d f8 ff ff       	call   801104 <fd2data>
  8018b7:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  8018b9:	83 c4 08             	add    $0x8,%esp
  8018bc:	68 ef 27 80 00       	push   $0x8027ef
  8018c1:	56                   	push   %esi
  8018c2:	e8 4f ef ff ff       	call   800816 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8018c7:	8b 43 04             	mov    0x4(%ebx),%eax
  8018ca:	2b 03                	sub    (%ebx),%eax
  8018cc:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  8018d2:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  8018d9:	00 00 00 
	stat->st_dev = &devpipe;
  8018dc:	c7 86 88 00 00 00 20 	movl   $0x803020,0x88(%esi)
  8018e3:	30 80 00 
	return 0;
}
  8018e6:	b8 00 00 00 00       	mov    $0x0,%eax
  8018eb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018ee:	5b                   	pop    %ebx
  8018ef:	5e                   	pop    %esi
  8018f0:	c9                   	leave  
  8018f1:	c3                   	ret    

008018f2 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8018f2:	55                   	push   %ebp
  8018f3:	89 e5                	mov    %esp,%ebp
  8018f5:	53                   	push   %ebx
  8018f6:	83 ec 0c             	sub    $0xc,%esp
  8018f9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8018fc:	53                   	push   %ebx
  8018fd:	6a 00                	push   $0x0
  8018ff:	e8 de f3 ff ff       	call   800ce2 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801904:	89 1c 24             	mov    %ebx,(%esp)
  801907:	e8 f8 f7 ff ff       	call   801104 <fd2data>
  80190c:	83 c4 08             	add    $0x8,%esp
  80190f:	50                   	push   %eax
  801910:	6a 00                	push   $0x0
  801912:	e8 cb f3 ff ff       	call   800ce2 <sys_page_unmap>
}
  801917:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80191a:	c9                   	leave  
  80191b:	c3                   	ret    

0080191c <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  80191c:	55                   	push   %ebp
  80191d:	89 e5                	mov    %esp,%ebp
  80191f:	57                   	push   %edi
  801920:	56                   	push   %esi
  801921:	53                   	push   %ebx
  801922:	83 ec 1c             	sub    $0x1c,%esp
  801925:	89 c7                	mov    %eax,%edi
  801927:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  80192a:	a1 08 40 80 00       	mov    0x804008,%eax
  80192f:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801932:	83 ec 0c             	sub    $0xc,%esp
  801935:	57                   	push   %edi
  801936:	e8 29 06 00 00       	call   801f64 <pageref>
  80193b:	89 c6                	mov    %eax,%esi
  80193d:	83 c4 04             	add    $0x4,%esp
  801940:	ff 75 e4             	pushl  -0x1c(%ebp)
  801943:	e8 1c 06 00 00       	call   801f64 <pageref>
  801948:	83 c4 10             	add    $0x10,%esp
  80194b:	39 c6                	cmp    %eax,%esi
  80194d:	0f 94 c0             	sete   %al
  801950:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  801953:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801959:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  80195c:	39 cb                	cmp    %ecx,%ebx
  80195e:	75 08                	jne    801968 <_pipeisclosed+0x4c>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  801960:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801963:	5b                   	pop    %ebx
  801964:	5e                   	pop    %esi
  801965:	5f                   	pop    %edi
  801966:	c9                   	leave  
  801967:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  801968:	83 f8 01             	cmp    $0x1,%eax
  80196b:	75 bd                	jne    80192a <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  80196d:	8b 42 58             	mov    0x58(%edx),%eax
  801970:	6a 01                	push   $0x1
  801972:	50                   	push   %eax
  801973:	53                   	push   %ebx
  801974:	68 f6 27 80 00       	push   $0x8027f6
  801979:	e8 e2 e8 ff ff       	call   800260 <cprintf>
  80197e:	83 c4 10             	add    $0x10,%esp
  801981:	eb a7                	jmp    80192a <_pipeisclosed+0xe>

00801983 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801983:	55                   	push   %ebp
  801984:	89 e5                	mov    %esp,%ebp
  801986:	57                   	push   %edi
  801987:	56                   	push   %esi
  801988:	53                   	push   %ebx
  801989:	83 ec 28             	sub    $0x28,%esp
  80198c:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  80198f:	56                   	push   %esi
  801990:	e8 6f f7 ff ff       	call   801104 <fd2data>
  801995:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801997:	83 c4 10             	add    $0x10,%esp
  80199a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80199e:	75 4a                	jne    8019ea <devpipe_write+0x67>
  8019a0:	bf 00 00 00 00       	mov    $0x0,%edi
  8019a5:	eb 56                	jmp    8019fd <devpipe_write+0x7a>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  8019a7:	89 da                	mov    %ebx,%edx
  8019a9:	89 f0                	mov    %esi,%eax
  8019ab:	e8 6c ff ff ff       	call   80191c <_pipeisclosed>
  8019b0:	85 c0                	test   %eax,%eax
  8019b2:	75 4d                	jne    801a01 <devpipe_write+0x7e>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  8019b4:	e8 b8 f2 ff ff       	call   800c71 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8019b9:	8b 43 04             	mov    0x4(%ebx),%eax
  8019bc:	8b 13                	mov    (%ebx),%edx
  8019be:	83 c2 20             	add    $0x20,%edx
  8019c1:	39 d0                	cmp    %edx,%eax
  8019c3:	73 e2                	jae    8019a7 <devpipe_write+0x24>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  8019c5:	89 c2                	mov    %eax,%edx
  8019c7:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  8019cd:	79 05                	jns    8019d4 <devpipe_write+0x51>
  8019cf:	4a                   	dec    %edx
  8019d0:	83 ca e0             	or     $0xffffffe0,%edx
  8019d3:	42                   	inc    %edx
  8019d4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8019d7:	8a 0c 39             	mov    (%ecx,%edi,1),%cl
  8019da:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  8019de:	40                   	inc    %eax
  8019df:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8019e2:	47                   	inc    %edi
  8019e3:	39 7d 10             	cmp    %edi,0x10(%ebp)
  8019e6:	77 07                	ja     8019ef <devpipe_write+0x6c>
  8019e8:	eb 13                	jmp    8019fd <devpipe_write+0x7a>
  8019ea:	bf 00 00 00 00       	mov    $0x0,%edi
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8019ef:	8b 43 04             	mov    0x4(%ebx),%eax
  8019f2:	8b 13                	mov    (%ebx),%edx
  8019f4:	83 c2 20             	add    $0x20,%edx
  8019f7:	39 d0                	cmp    %edx,%eax
  8019f9:	73 ac                	jae    8019a7 <devpipe_write+0x24>
  8019fb:	eb c8                	jmp    8019c5 <devpipe_write+0x42>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  8019fd:	89 f8                	mov    %edi,%eax
  8019ff:	eb 05                	jmp    801a06 <devpipe_write+0x83>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801a01:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801a06:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a09:	5b                   	pop    %ebx
  801a0a:	5e                   	pop    %esi
  801a0b:	5f                   	pop    %edi
  801a0c:	c9                   	leave  
  801a0d:	c3                   	ret    

00801a0e <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801a0e:	55                   	push   %ebp
  801a0f:	89 e5                	mov    %esp,%ebp
  801a11:	57                   	push   %edi
  801a12:	56                   	push   %esi
  801a13:	53                   	push   %ebx
  801a14:	83 ec 18             	sub    $0x18,%esp
  801a17:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801a1a:	57                   	push   %edi
  801a1b:	e8 e4 f6 ff ff       	call   801104 <fd2data>
  801a20:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801a22:	83 c4 10             	add    $0x10,%esp
  801a25:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801a29:	75 44                	jne    801a6f <devpipe_read+0x61>
  801a2b:	be 00 00 00 00       	mov    $0x0,%esi
  801a30:	eb 4f                	jmp    801a81 <devpipe_read+0x73>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
				return i;
  801a32:	89 f0                	mov    %esi,%eax
  801a34:	eb 54                	jmp    801a8a <devpipe_read+0x7c>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801a36:	89 da                	mov    %ebx,%edx
  801a38:	89 f8                	mov    %edi,%eax
  801a3a:	e8 dd fe ff ff       	call   80191c <_pipeisclosed>
  801a3f:	85 c0                	test   %eax,%eax
  801a41:	75 42                	jne    801a85 <devpipe_read+0x77>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801a43:	e8 29 f2 ff ff       	call   800c71 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801a48:	8b 03                	mov    (%ebx),%eax
  801a4a:	3b 43 04             	cmp    0x4(%ebx),%eax
  801a4d:	74 e7                	je     801a36 <devpipe_read+0x28>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801a4f:	25 1f 00 00 80       	and    $0x8000001f,%eax
  801a54:	79 05                	jns    801a5b <devpipe_read+0x4d>
  801a56:	48                   	dec    %eax
  801a57:	83 c8 e0             	or     $0xffffffe0,%eax
  801a5a:	40                   	inc    %eax
  801a5b:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  801a5f:	8b 55 0c             	mov    0xc(%ebp),%edx
  801a62:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  801a65:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801a67:	46                   	inc    %esi
  801a68:	39 75 10             	cmp    %esi,0x10(%ebp)
  801a6b:	77 07                	ja     801a74 <devpipe_read+0x66>
  801a6d:	eb 12                	jmp    801a81 <devpipe_read+0x73>
  801a6f:	be 00 00 00 00       	mov    $0x0,%esi
		while (p->p_rpos == p->p_wpos) {
  801a74:	8b 03                	mov    (%ebx),%eax
  801a76:	3b 43 04             	cmp    0x4(%ebx),%eax
  801a79:	75 d4                	jne    801a4f <devpipe_read+0x41>
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801a7b:	85 f6                	test   %esi,%esi
  801a7d:	75 b3                	jne    801a32 <devpipe_read+0x24>
  801a7f:	eb b5                	jmp    801a36 <devpipe_read+0x28>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801a81:	89 f0                	mov    %esi,%eax
  801a83:	eb 05                	jmp    801a8a <devpipe_read+0x7c>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801a85:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801a8a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a8d:	5b                   	pop    %ebx
  801a8e:	5e                   	pop    %esi
  801a8f:	5f                   	pop    %edi
  801a90:	c9                   	leave  
  801a91:	c3                   	ret    

00801a92 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801a92:	55                   	push   %ebp
  801a93:	89 e5                	mov    %esp,%ebp
  801a95:	57                   	push   %edi
  801a96:	56                   	push   %esi
  801a97:	53                   	push   %ebx
  801a98:	83 ec 28             	sub    $0x28,%esp
  801a9b:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801a9e:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801aa1:	50                   	push   %eax
  801aa2:	e8 75 f6 ff ff       	call   80111c <fd_alloc>
  801aa7:	89 c3                	mov    %eax,%ebx
  801aa9:	83 c4 10             	add    $0x10,%esp
  801aac:	85 c0                	test   %eax,%eax
  801aae:	0f 88 24 01 00 00    	js     801bd8 <pipe+0x146>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ab4:	83 ec 04             	sub    $0x4,%esp
  801ab7:	68 07 04 00 00       	push   $0x407
  801abc:	ff 75 e4             	pushl  -0x1c(%ebp)
  801abf:	6a 00                	push   $0x0
  801ac1:	e8 d2 f1 ff ff       	call   800c98 <sys_page_alloc>
  801ac6:	89 c3                	mov    %eax,%ebx
  801ac8:	83 c4 10             	add    $0x10,%esp
  801acb:	85 c0                	test   %eax,%eax
  801acd:	0f 88 05 01 00 00    	js     801bd8 <pipe+0x146>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801ad3:	83 ec 0c             	sub    $0xc,%esp
  801ad6:	8d 45 e0             	lea    -0x20(%ebp),%eax
  801ad9:	50                   	push   %eax
  801ada:	e8 3d f6 ff ff       	call   80111c <fd_alloc>
  801adf:	89 c3                	mov    %eax,%ebx
  801ae1:	83 c4 10             	add    $0x10,%esp
  801ae4:	85 c0                	test   %eax,%eax
  801ae6:	0f 88 dc 00 00 00    	js     801bc8 <pipe+0x136>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801aec:	83 ec 04             	sub    $0x4,%esp
  801aef:	68 07 04 00 00       	push   $0x407
  801af4:	ff 75 e0             	pushl  -0x20(%ebp)
  801af7:	6a 00                	push   $0x0
  801af9:	e8 9a f1 ff ff       	call   800c98 <sys_page_alloc>
  801afe:	89 c3                	mov    %eax,%ebx
  801b00:	83 c4 10             	add    $0x10,%esp
  801b03:	85 c0                	test   %eax,%eax
  801b05:	0f 88 bd 00 00 00    	js     801bc8 <pipe+0x136>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801b0b:	83 ec 0c             	sub    $0xc,%esp
  801b0e:	ff 75 e4             	pushl  -0x1c(%ebp)
  801b11:	e8 ee f5 ff ff       	call   801104 <fd2data>
  801b16:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b18:	83 c4 0c             	add    $0xc,%esp
  801b1b:	68 07 04 00 00       	push   $0x407
  801b20:	50                   	push   %eax
  801b21:	6a 00                	push   $0x0
  801b23:	e8 70 f1 ff ff       	call   800c98 <sys_page_alloc>
  801b28:	89 c3                	mov    %eax,%ebx
  801b2a:	83 c4 10             	add    $0x10,%esp
  801b2d:	85 c0                	test   %eax,%eax
  801b2f:	0f 88 83 00 00 00    	js     801bb8 <pipe+0x126>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b35:	83 ec 0c             	sub    $0xc,%esp
  801b38:	ff 75 e0             	pushl  -0x20(%ebp)
  801b3b:	e8 c4 f5 ff ff       	call   801104 <fd2data>
  801b40:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801b47:	50                   	push   %eax
  801b48:	6a 00                	push   $0x0
  801b4a:	56                   	push   %esi
  801b4b:	6a 00                	push   $0x0
  801b4d:	e8 6a f1 ff ff       	call   800cbc <sys_page_map>
  801b52:	89 c3                	mov    %eax,%ebx
  801b54:	83 c4 20             	add    $0x20,%esp
  801b57:	85 c0                	test   %eax,%eax
  801b59:	78 4f                	js     801baa <pipe+0x118>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801b5b:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801b61:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801b64:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801b66:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801b69:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801b70:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801b76:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801b79:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801b7b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801b7e:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801b85:	83 ec 0c             	sub    $0xc,%esp
  801b88:	ff 75 e4             	pushl  -0x1c(%ebp)
  801b8b:	e8 64 f5 ff ff       	call   8010f4 <fd2num>
  801b90:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  801b92:	83 c4 04             	add    $0x4,%esp
  801b95:	ff 75 e0             	pushl  -0x20(%ebp)
  801b98:	e8 57 f5 ff ff       	call   8010f4 <fd2num>
  801b9d:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  801ba0:	83 c4 10             	add    $0x10,%esp
  801ba3:	bb 00 00 00 00       	mov    $0x0,%ebx
  801ba8:	eb 2e                	jmp    801bd8 <pipe+0x146>

    err3:
	sys_page_unmap(0, va);
  801baa:	83 ec 08             	sub    $0x8,%esp
  801bad:	56                   	push   %esi
  801bae:	6a 00                	push   $0x0
  801bb0:	e8 2d f1 ff ff       	call   800ce2 <sys_page_unmap>
  801bb5:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801bb8:	83 ec 08             	sub    $0x8,%esp
  801bbb:	ff 75 e0             	pushl  -0x20(%ebp)
  801bbe:	6a 00                	push   $0x0
  801bc0:	e8 1d f1 ff ff       	call   800ce2 <sys_page_unmap>
  801bc5:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801bc8:	83 ec 08             	sub    $0x8,%esp
  801bcb:	ff 75 e4             	pushl  -0x1c(%ebp)
  801bce:	6a 00                	push   $0x0
  801bd0:	e8 0d f1 ff ff       	call   800ce2 <sys_page_unmap>
  801bd5:	83 c4 10             	add    $0x10,%esp
    err:
	return r;
}
  801bd8:	89 d8                	mov    %ebx,%eax
  801bda:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801bdd:	5b                   	pop    %ebx
  801bde:	5e                   	pop    %esi
  801bdf:	5f                   	pop    %edi
  801be0:	c9                   	leave  
  801be1:	c3                   	ret    

00801be2 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801be2:	55                   	push   %ebp
  801be3:	89 e5                	mov    %esp,%ebp
  801be5:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801be8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801beb:	50                   	push   %eax
  801bec:	ff 75 08             	pushl  0x8(%ebp)
  801bef:	e8 9b f5 ff ff       	call   80118f <fd_lookup>
  801bf4:	83 c4 10             	add    $0x10,%esp
  801bf7:	85 c0                	test   %eax,%eax
  801bf9:	78 18                	js     801c13 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801bfb:	83 ec 0c             	sub    $0xc,%esp
  801bfe:	ff 75 f4             	pushl  -0xc(%ebp)
  801c01:	e8 fe f4 ff ff       	call   801104 <fd2data>
	return _pipeisclosed(fd, p);
  801c06:	89 c2                	mov    %eax,%edx
  801c08:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c0b:	e8 0c fd ff ff       	call   80191c <_pipeisclosed>
  801c10:	83 c4 10             	add    $0x10,%esp
}
  801c13:	c9                   	leave  
  801c14:	c3                   	ret    
  801c15:	00 00                	add    %al,(%eax)
	...

00801c18 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801c18:	55                   	push   %ebp
  801c19:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801c1b:	b8 00 00 00 00       	mov    $0x0,%eax
  801c20:	c9                   	leave  
  801c21:	c3                   	ret    

00801c22 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801c22:	55                   	push   %ebp
  801c23:	89 e5                	mov    %esp,%ebp
  801c25:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801c28:	68 0e 28 80 00       	push   $0x80280e
  801c2d:	ff 75 0c             	pushl  0xc(%ebp)
  801c30:	e8 e1 eb ff ff       	call   800816 <strcpy>
	return 0;
}
  801c35:	b8 00 00 00 00       	mov    $0x0,%eax
  801c3a:	c9                   	leave  
  801c3b:	c3                   	ret    

00801c3c <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801c3c:	55                   	push   %ebp
  801c3d:	89 e5                	mov    %esp,%ebp
  801c3f:	57                   	push   %edi
  801c40:	56                   	push   %esi
  801c41:	53                   	push   %ebx
  801c42:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801c48:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801c4c:	74 45                	je     801c93 <devcons_write+0x57>
  801c4e:	b8 00 00 00 00       	mov    $0x0,%eax
  801c53:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801c58:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801c5e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801c61:	29 c3                	sub    %eax,%ebx
		if (m > sizeof(buf) - 1)
  801c63:	83 fb 7f             	cmp    $0x7f,%ebx
  801c66:	76 05                	jbe    801c6d <devcons_write+0x31>
			m = sizeof(buf) - 1;
  801c68:	bb 7f 00 00 00       	mov    $0x7f,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  801c6d:	83 ec 04             	sub    $0x4,%esp
  801c70:	53                   	push   %ebx
  801c71:	03 45 0c             	add    0xc(%ebp),%eax
  801c74:	50                   	push   %eax
  801c75:	57                   	push   %edi
  801c76:	e8 5c ed ff ff       	call   8009d7 <memmove>
		sys_cputs(buf, m);
  801c7b:	83 c4 08             	add    $0x8,%esp
  801c7e:	53                   	push   %ebx
  801c7f:	57                   	push   %edi
  801c80:	e8 5c ef ff ff       	call   800be1 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801c85:	01 de                	add    %ebx,%esi
  801c87:	89 f0                	mov    %esi,%eax
  801c89:	83 c4 10             	add    $0x10,%esp
  801c8c:	3b 75 10             	cmp    0x10(%ebp),%esi
  801c8f:	72 cd                	jb     801c5e <devcons_write+0x22>
  801c91:	eb 05                	jmp    801c98 <devcons_write+0x5c>
  801c93:	be 00 00 00 00       	mov    $0x0,%esi
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801c98:	89 f0                	mov    %esi,%eax
  801c9a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c9d:	5b                   	pop    %ebx
  801c9e:	5e                   	pop    %esi
  801c9f:	5f                   	pop    %edi
  801ca0:	c9                   	leave  
  801ca1:	c3                   	ret    

00801ca2 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801ca2:	55                   	push   %ebp
  801ca3:	89 e5                	mov    %esp,%ebp
  801ca5:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  801ca8:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801cac:	75 07                	jne    801cb5 <devcons_read+0x13>
  801cae:	eb 25                	jmp    801cd5 <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801cb0:	e8 bc ef ff ff       	call   800c71 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801cb5:	e8 4d ef ff ff       	call   800c07 <sys_cgetc>
  801cba:	85 c0                	test   %eax,%eax
  801cbc:	74 f2                	je     801cb0 <devcons_read+0xe>
  801cbe:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  801cc0:	85 c0                	test   %eax,%eax
  801cc2:	78 1d                	js     801ce1 <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801cc4:	83 f8 04             	cmp    $0x4,%eax
  801cc7:	74 13                	je     801cdc <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  801cc9:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ccc:	88 10                	mov    %dl,(%eax)
	return 1;
  801cce:	b8 01 00 00 00       	mov    $0x1,%eax
  801cd3:	eb 0c                	jmp    801ce1 <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  801cd5:	b8 00 00 00 00       	mov    $0x0,%eax
  801cda:	eb 05                	jmp    801ce1 <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801cdc:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801ce1:	c9                   	leave  
  801ce2:	c3                   	ret    

00801ce3 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801ce3:	55                   	push   %ebp
  801ce4:	89 e5                	mov    %esp,%ebp
  801ce6:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801ce9:	8b 45 08             	mov    0x8(%ebp),%eax
  801cec:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801cef:	6a 01                	push   $0x1
  801cf1:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801cf4:	50                   	push   %eax
  801cf5:	e8 e7 ee ff ff       	call   800be1 <sys_cputs>
  801cfa:	83 c4 10             	add    $0x10,%esp
}
  801cfd:	c9                   	leave  
  801cfe:	c3                   	ret    

00801cff <getchar>:

int
getchar(void)
{
  801cff:	55                   	push   %ebp
  801d00:	89 e5                	mov    %esp,%ebp
  801d02:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801d05:	6a 01                	push   $0x1
  801d07:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801d0a:	50                   	push   %eax
  801d0b:	6a 00                	push   $0x0
  801d0d:	e8 fe f6 ff ff       	call   801410 <read>
	if (r < 0)
  801d12:	83 c4 10             	add    $0x10,%esp
  801d15:	85 c0                	test   %eax,%eax
  801d17:	78 0f                	js     801d28 <getchar+0x29>
		return r;
	if (r < 1)
  801d19:	85 c0                	test   %eax,%eax
  801d1b:	7e 06                	jle    801d23 <getchar+0x24>
		return -E_EOF;
	return c;
  801d1d:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801d21:	eb 05                	jmp    801d28 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801d23:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801d28:	c9                   	leave  
  801d29:	c3                   	ret    

00801d2a <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801d2a:	55                   	push   %ebp
  801d2b:	89 e5                	mov    %esp,%ebp
  801d2d:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801d30:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d33:	50                   	push   %eax
  801d34:	ff 75 08             	pushl  0x8(%ebp)
  801d37:	e8 53 f4 ff ff       	call   80118f <fd_lookup>
  801d3c:	83 c4 10             	add    $0x10,%esp
  801d3f:	85 c0                	test   %eax,%eax
  801d41:	78 11                	js     801d54 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801d43:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d46:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801d4c:	39 10                	cmp    %edx,(%eax)
  801d4e:	0f 94 c0             	sete   %al
  801d51:	0f b6 c0             	movzbl %al,%eax
}
  801d54:	c9                   	leave  
  801d55:	c3                   	ret    

00801d56 <opencons>:

int
opencons(void)
{
  801d56:	55                   	push   %ebp
  801d57:	89 e5                	mov    %esp,%ebp
  801d59:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801d5c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d5f:	50                   	push   %eax
  801d60:	e8 b7 f3 ff ff       	call   80111c <fd_alloc>
  801d65:	83 c4 10             	add    $0x10,%esp
  801d68:	85 c0                	test   %eax,%eax
  801d6a:	78 3a                	js     801da6 <opencons+0x50>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801d6c:	83 ec 04             	sub    $0x4,%esp
  801d6f:	68 07 04 00 00       	push   $0x407
  801d74:	ff 75 f4             	pushl  -0xc(%ebp)
  801d77:	6a 00                	push   $0x0
  801d79:	e8 1a ef ff ff       	call   800c98 <sys_page_alloc>
  801d7e:	83 c4 10             	add    $0x10,%esp
  801d81:	85 c0                	test   %eax,%eax
  801d83:	78 21                	js     801da6 <opencons+0x50>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801d85:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801d8b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d8e:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801d90:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d93:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801d9a:	83 ec 0c             	sub    $0xc,%esp
  801d9d:	50                   	push   %eax
  801d9e:	e8 51 f3 ff ff       	call   8010f4 <fd2num>
  801da3:	83 c4 10             	add    $0x10,%esp
}
  801da6:	c9                   	leave  
  801da7:	c3                   	ret    

00801da8 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801da8:	55                   	push   %ebp
  801da9:	89 e5                	mov    %esp,%ebp
  801dab:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  801dae:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801db5:	75 52                	jne    801e09 <set_pgfault_handler+0x61>
		// First time through!	
		// LAB 4: Your code here.

		//int sys_page_alloc(envid_t envid, void *va, int perm)
		r = sys_page_alloc(0, (void*)(UXSTACKTOP - PGSIZE), PTE_U | PTE_W | PTE_P);
  801db7:	83 ec 04             	sub    $0x4,%esp
  801dba:	6a 07                	push   $0x7
  801dbc:	68 00 f0 bf ee       	push   $0xeebff000
  801dc1:	6a 00                	push   $0x0
  801dc3:	e8 d0 ee ff ff       	call   800c98 <sys_page_alloc>
		if (r < 0) {
  801dc8:	83 c4 10             	add    $0x10,%esp
  801dcb:	85 c0                	test   %eax,%eax
  801dcd:	79 12                	jns    801de1 <set_pgfault_handler+0x39>
			panic("sys_page_alloc error : %e\n", r);
  801dcf:	50                   	push   %eax
  801dd0:	68 1a 28 80 00       	push   $0x80281a
  801dd5:	6a 24                	push   $0x24
  801dd7:	68 35 28 80 00       	push   $0x802835
  801ddc:	e8 a7 e3 ff ff       	call   800188 <_panic>
		}

		// how to know envid, put 0, envid2env will help us to get curenv in syscall
		r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);		
  801de1:	83 ec 08             	sub    $0x8,%esp
  801de4:	68 14 1e 80 00       	push   $0x801e14
  801de9:	6a 00                	push   $0x0
  801deb:	e8 5b ef ff ff       	call   800d4b <sys_env_set_pgfault_upcall>
		if (r < 0) {
  801df0:	83 c4 10             	add    $0x10,%esp
  801df3:	85 c0                	test   %eax,%eax
  801df5:	79 12                	jns    801e09 <set_pgfault_handler+0x61>
			panic("sys_env_set_pgfault_upcall error : %e\n", r);
  801df7:	50                   	push   %eax
  801df8:	68 44 28 80 00       	push   $0x802844
  801dfd:	6a 2a                	push   $0x2a
  801dff:	68 35 28 80 00       	push   $0x802835
  801e04:	e8 7f e3 ff ff       	call   800188 <_panic>
		}
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801e09:	8b 45 08             	mov    0x8(%ebp),%eax
  801e0c:	a3 00 60 80 00       	mov    %eax,0x806000
}
  801e11:	c9                   	leave  
  801e12:	c3                   	ret    
	...

00801e14 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801e14:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801e15:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  801e1a:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801e1c:	83 c4 04             	add    $0x4,%esp
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	
	// fix old esp
	movl 0x30(%esp), %eax
  801e1f:	8b 44 24 30          	mov    0x30(%esp),%eax
	subl $0x4, %eax
  801e23:	83 e8 04             	sub    $0x4,%eax
	movl %eax, 0x30(%esp)
  801e26:	89 44 24 30          	mov    %eax,0x30(%esp)

	// set trap-time %eip
	movl 0x28(%esp), %ebx
  801e2a:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	movl %ebx, (%eax)
  801e2e:	89 18                	mov    %ebx,(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $0x08, %esp 	// ignore err_code and fault_va
  801e30:	83 c4 08             	add    $0x8,%esp
	popal 				// restore registers
  801e33:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x04, %esp 	// ignore eip 
  801e34:	83 c4 04             	add    $0x4,%esp
	popfl				// modify eflags
  801e37:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  801e38:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  801e39:	c3                   	ret    
	...

00801e3c <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801e3c:	55                   	push   %ebp
  801e3d:	89 e5                	mov    %esp,%ebp
  801e3f:	56                   	push   %esi
  801e40:	53                   	push   %ebx
  801e41:	8b 75 08             	mov    0x8(%ebp),%esi
  801e44:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e47:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// cprintf("0x%x 0x%x 0x%x\n", (uint32_t)from_env_store, (uint32_t)pg, (uint32_t)perm_store);
	int r;
	if (pg != NULL) {
  801e4a:	85 c0                	test   %eax,%eax
  801e4c:	74 0e                	je     801e5c <ipc_recv+0x20>
		r = sys_ipc_recv(pg);
  801e4e:	83 ec 0c             	sub    $0xc,%esp
  801e51:	50                   	push   %eax
  801e52:	e8 3c ef ff ff       	call   800d93 <sys_ipc_recv>
  801e57:	83 c4 10             	add    $0x10,%esp
  801e5a:	eb 10                	jmp    801e6c <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv((void *)UTOP);
  801e5c:	83 ec 0c             	sub    $0xc,%esp
  801e5f:	68 00 00 c0 ee       	push   $0xeec00000
  801e64:	e8 2a ef ff ff       	call   800d93 <sys_ipc_recv>
  801e69:	83 c4 10             	add    $0x10,%esp
	}

	if (r == 0) {
  801e6c:	85 c0                	test   %eax,%eax
  801e6e:	75 26                	jne    801e96 <ipc_recv+0x5a>
		if (from_env_store != NULL) *from_env_store = thisenv->env_ipc_from;
  801e70:	85 f6                	test   %esi,%esi
  801e72:	74 0a                	je     801e7e <ipc_recv+0x42>
  801e74:	a1 08 40 80 00       	mov    0x804008,%eax
  801e79:	8b 40 74             	mov    0x74(%eax),%eax
  801e7c:	89 06                	mov    %eax,(%esi)
		if (perm_store != NULL) *perm_store = thisenv->env_ipc_perm;
  801e7e:	85 db                	test   %ebx,%ebx
  801e80:	74 0a                	je     801e8c <ipc_recv+0x50>
  801e82:	a1 08 40 80 00       	mov    0x804008,%eax
  801e87:	8b 40 78             	mov    0x78(%eax),%eax
  801e8a:	89 03                	mov    %eax,(%ebx)
		return thisenv->env_ipc_value;
  801e8c:	a1 08 40 80 00       	mov    0x804008,%eax
  801e91:	8b 40 70             	mov    0x70(%eax),%eax
  801e94:	eb 14                	jmp    801eaa <ipc_recv+0x6e>
	} else {
		// fails;
		if (from_env_store != NULL) *from_env_store = 0;
  801e96:	85 f6                	test   %esi,%esi
  801e98:	74 06                	je     801ea0 <ipc_recv+0x64>
  801e9a:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if (perm_store != NULL) *perm_store = 0;
  801ea0:	85 db                	test   %ebx,%ebx
  801ea2:	74 06                	je     801eaa <ipc_recv+0x6e>
  801ea4:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		return r;
	}
}
  801eaa:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ead:	5b                   	pop    %ebx
  801eae:	5e                   	pop    %esi
  801eaf:	c9                   	leave  
  801eb0:	c3                   	ret    

00801eb1 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801eb1:	55                   	push   %ebp
  801eb2:	89 e5                	mov    %esp,%ebp
  801eb4:	57                   	push   %edi
  801eb5:	56                   	push   %esi
  801eb6:	53                   	push   %ebx
  801eb7:	83 ec 0c             	sub    $0xc,%esp
  801eba:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801ebd:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801ec0:	8b 75 14             	mov    0x14(%ebp),%esi
	// LAB 4: Your code here.
	// int sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
	int r;
	if (pg == NULL) pg = (void *)UTOP;
  801ec3:	85 db                	test   %ebx,%ebx
  801ec5:	75 25                	jne    801eec <ipc_send+0x3b>
  801ec7:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
  801ecc:	eb 1e                	jmp    801eec <ipc_send+0x3b>
	
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) != 0) {
		if (r == -E_IPC_NOT_RECV) {
  801ece:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801ed1:	75 07                	jne    801eda <ipc_send+0x29>
			// cprintf("Try Again and Again....\n");
			sys_yield();
  801ed3:	e8 99 ed ff ff       	call   800c71 <sys_yield>
  801ed8:	eb 12                	jmp    801eec <ipc_send+0x3b>
		} else {
			panic("ipc_send error %e\n", r);
  801eda:	50                   	push   %eax
  801edb:	68 6c 28 80 00       	push   $0x80286c
  801ee0:	6a 43                	push   $0x43
  801ee2:	68 7f 28 80 00       	push   $0x80287f
  801ee7:	e8 9c e2 ff ff       	call   800188 <_panic>
	// LAB 4: Your code here.
	// int sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
	int r;
	if (pg == NULL) pg = (void *)UTOP;
	
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) != 0) {
  801eec:	56                   	push   %esi
  801eed:	53                   	push   %ebx
  801eee:	57                   	push   %edi
  801eef:	ff 75 08             	pushl  0x8(%ebp)
  801ef2:	e8 77 ee ff ff       	call   800d6e <sys_ipc_try_send>
  801ef7:	83 c4 10             	add    $0x10,%esp
  801efa:	85 c0                	test   %eax,%eax
  801efc:	75 d0                	jne    801ece <ipc_send+0x1d>
		} else {
			panic("ipc_send error %e\n", r);
		}
	}
	return;
}
  801efe:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f01:	5b                   	pop    %ebx
  801f02:	5e                   	pop    %esi
  801f03:	5f                   	pop    %edi
  801f04:	c9                   	leave  
  801f05:	c3                   	ret    

00801f06 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801f06:	55                   	push   %ebp
  801f07:	89 e5                	mov    %esp,%ebp
  801f09:	53                   	push   %ebx
  801f0a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  801f0d:	39 1d 50 00 c0 ee    	cmp    %ebx,0xeec00050
  801f13:	74 22                	je     801f37 <ipc_find_env+0x31>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801f15:	b8 01 00 00 00       	mov    $0x1,%eax
		if (envs[i].env_type == type)
  801f1a:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  801f21:	89 c2                	mov    %eax,%edx
  801f23:	c1 e2 07             	shl    $0x7,%edx
  801f26:	29 ca                	sub    %ecx,%edx
  801f28:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801f2e:	8b 52 50             	mov    0x50(%edx),%edx
  801f31:	39 da                	cmp    %ebx,%edx
  801f33:	75 1d                	jne    801f52 <ipc_find_env+0x4c>
  801f35:	eb 05                	jmp    801f3c <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801f37:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
			return envs[i].env_id;
  801f3c:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  801f43:	c1 e0 07             	shl    $0x7,%eax
  801f46:	29 d0                	sub    %edx,%eax
  801f48:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  801f4d:	8b 40 40             	mov    0x40(%eax),%eax
  801f50:	eb 0c                	jmp    801f5e <ipc_find_env+0x58>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801f52:	40                   	inc    %eax
  801f53:	3d 00 04 00 00       	cmp    $0x400,%eax
  801f58:	75 c0                	jne    801f1a <ipc_find_env+0x14>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801f5a:	66 b8 00 00          	mov    $0x0,%ax
}
  801f5e:	5b                   	pop    %ebx
  801f5f:	c9                   	leave  
  801f60:	c3                   	ret    
  801f61:	00 00                	add    %al,(%eax)
	...

00801f64 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801f64:	55                   	push   %ebp
  801f65:	89 e5                	mov    %esp,%ebp
  801f67:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801f6a:	89 c2                	mov    %eax,%edx
  801f6c:	c1 ea 16             	shr    $0x16,%edx
  801f6f:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801f76:	f6 c2 01             	test   $0x1,%dl
  801f79:	74 1e                	je     801f99 <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  801f7b:	c1 e8 0c             	shr    $0xc,%eax
  801f7e:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801f85:	a8 01                	test   $0x1,%al
  801f87:	74 17                	je     801fa0 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801f89:	c1 e8 0c             	shr    $0xc,%eax
  801f8c:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  801f93:	ef 
  801f94:	0f b7 c0             	movzwl %ax,%eax
  801f97:	eb 0c                	jmp    801fa5 <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  801f99:	b8 00 00 00 00       	mov    $0x0,%eax
  801f9e:	eb 05                	jmp    801fa5 <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  801fa0:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  801fa5:	c9                   	leave  
  801fa6:	c3                   	ret    
	...

00801fa8 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  801fa8:	55                   	push   %ebp
  801fa9:	89 e5                	mov    %esp,%ebp
  801fab:	57                   	push   %edi
  801fac:	56                   	push   %esi
  801fad:	83 ec 10             	sub    $0x10,%esp
  801fb0:	8b 7d 08             	mov    0x8(%ebp),%edi
  801fb3:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  801fb6:	89 7d f0             	mov    %edi,-0x10(%ebp)
  801fb9:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  801fbc:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  801fbf:	8b 45 14             	mov    0x14(%ebp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  801fc2:	85 c0                	test   %eax,%eax
  801fc4:	75 2e                	jne    801ff4 <__udivdi3+0x4c>
    {
      if (d0 > n1)
  801fc6:	39 f1                	cmp    %esi,%ecx
  801fc8:	77 5a                	ja     802024 <__udivdi3+0x7c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  801fca:	85 c9                	test   %ecx,%ecx
  801fcc:	75 0b                	jne    801fd9 <__udivdi3+0x31>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  801fce:	b8 01 00 00 00       	mov    $0x1,%eax
  801fd3:	31 d2                	xor    %edx,%edx
  801fd5:	f7 f1                	div    %ecx
  801fd7:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  801fd9:	31 d2                	xor    %edx,%edx
  801fdb:	89 f0                	mov    %esi,%eax
  801fdd:	f7 f1                	div    %ecx
  801fdf:	89 c6                	mov    %eax,%esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801fe1:	89 f8                	mov    %edi,%eax
  801fe3:	f7 f1                	div    %ecx
  801fe5:	89 c7                	mov    %eax,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801fe7:	89 f8                	mov    %edi,%eax
  801fe9:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801feb:	83 c4 10             	add    $0x10,%esp
  801fee:	5e                   	pop    %esi
  801fef:	5f                   	pop    %edi
  801ff0:	c9                   	leave  
  801ff1:	c3                   	ret    
  801ff2:	66 90                	xchg   %ax,%ax
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801ff4:	39 f0                	cmp    %esi,%eax
  801ff6:	77 1c                	ja     802014 <__udivdi3+0x6c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  801ff8:	0f bd f8             	bsr    %eax,%edi
	  if (bm == 0)
  801ffb:	83 f7 1f             	xor    $0x1f,%edi
  801ffe:	75 3c                	jne    80203c <__udivdi3+0x94>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802000:	39 f0                	cmp    %esi,%eax
  802002:	0f 82 90 00 00 00    	jb     802098 <__udivdi3+0xf0>
  802008:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80200b:	39 55 f4             	cmp    %edx,-0xc(%ebp)
  80200e:	0f 86 84 00 00 00    	jbe    802098 <__udivdi3+0xf0>
  802014:	31 f6                	xor    %esi,%esi
  802016:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  802018:	89 f8                	mov    %edi,%eax
  80201a:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  80201c:	83 c4 10             	add    $0x10,%esp
  80201f:	5e                   	pop    %esi
  802020:	5f                   	pop    %edi
  802021:	c9                   	leave  
  802022:	c3                   	ret    
  802023:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802024:	89 f2                	mov    %esi,%edx
  802026:	89 f8                	mov    %edi,%eax
  802028:	f7 f1                	div    %ecx
  80202a:	89 c7                	mov    %eax,%edi
  80202c:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  80202e:	89 f8                	mov    %edi,%eax
  802030:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802032:	83 c4 10             	add    $0x10,%esp
  802035:	5e                   	pop    %esi
  802036:	5f                   	pop    %edi
  802037:	c9                   	leave  
  802038:	c3                   	ret    
  802039:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  80203c:	89 f9                	mov    %edi,%ecx
  80203e:	d3 e0                	shl    %cl,%eax
  802040:	89 45 e8             	mov    %eax,-0x18(%ebp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  802043:	b8 20 00 00 00       	mov    $0x20,%eax
  802048:	29 f8                	sub    %edi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  80204a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80204d:	88 c1                	mov    %al,%cl
  80204f:	d3 ea                	shr    %cl,%edx
  802051:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  802054:	09 ca                	or     %ecx,%edx
  802056:	89 55 ec             	mov    %edx,-0x14(%ebp)
	      d0 = d0 << bm;
  802059:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80205c:	89 f9                	mov    %edi,%ecx
  80205e:	d3 e2                	shl    %cl,%edx
  802060:	89 55 f4             	mov    %edx,-0xc(%ebp)
	      n2 = n1 >> b;
  802063:	89 f2                	mov    %esi,%edx
  802065:	88 c1                	mov    %al,%cl
  802067:	d3 ea                	shr    %cl,%edx
  802069:	89 55 e8             	mov    %edx,-0x18(%ebp)
	      n1 = (n1 << bm) | (n0 >> b);
  80206c:	89 f2                	mov    %esi,%edx
  80206e:	89 f9                	mov    %edi,%ecx
  802070:	d3 e2                	shl    %cl,%edx
  802072:	8b 75 f0             	mov    -0x10(%ebp),%esi
  802075:	88 c1                	mov    %al,%cl
  802077:	d3 ee                	shr    %cl,%esi
  802079:	09 d6                	or     %edx,%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  80207b:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  80207e:	89 f0                	mov    %esi,%eax
  802080:	89 ca                	mov    %ecx,%edx
  802082:	f7 75 ec             	divl   -0x14(%ebp)
  802085:	89 d1                	mov    %edx,%ecx
  802087:	89 c6                	mov    %eax,%esi
	      umul_ppmm (m1, m0, q0, d0);
  802089:	f7 65 f4             	mull   -0xc(%ebp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  80208c:	39 d1                	cmp    %edx,%ecx
  80208e:	72 28                	jb     8020b8 <__udivdi3+0x110>
  802090:	74 1a                	je     8020ac <__udivdi3+0x104>
  802092:	89 f7                	mov    %esi,%edi
  802094:	31 f6                	xor    %esi,%esi
  802096:	eb 80                	jmp    802018 <__udivdi3+0x70>
	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  802098:	31 f6                	xor    %esi,%esi
  80209a:	bf 01 00 00 00       	mov    $0x1,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  80209f:	89 f8                	mov    %edi,%eax
  8020a1:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  8020a3:	83 c4 10             	add    $0x10,%esp
  8020a6:	5e                   	pop    %esi
  8020a7:	5f                   	pop    %edi
  8020a8:	c9                   	leave  
  8020a9:	c3                   	ret    
  8020aa:	66 90                	xchg   %ax,%ax

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  8020ac:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8020af:	89 f9                	mov    %edi,%ecx
  8020b1:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8020b3:	39 c2                	cmp    %eax,%edx
  8020b5:	73 db                	jae    802092 <__udivdi3+0xea>
  8020b7:	90                   	nop
		{
		  q0--;
  8020b8:	8d 7e ff             	lea    -0x1(%esi),%edi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  8020bb:	31 f6                	xor    %esi,%esi
  8020bd:	e9 56 ff ff ff       	jmp    802018 <__udivdi3+0x70>
	...

008020c4 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  8020c4:	55                   	push   %ebp
  8020c5:	89 e5                	mov    %esp,%ebp
  8020c7:	57                   	push   %edi
  8020c8:	56                   	push   %esi
  8020c9:	83 ec 20             	sub    $0x20,%esp
  8020cc:	8b 45 08             	mov    0x8(%ebp),%eax
  8020cf:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  8020d2:	89 45 e8             	mov    %eax,-0x18(%ebp)
  8020d5:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  8020d8:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  8020db:	8b 7d 14             	mov    0x14(%ebp),%edi
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  8020de:	89 45 f0             	mov    %eax,-0x10(%ebp)
  n1 = nn.s.high;
  8020e1:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  8020e3:	85 ff                	test   %edi,%edi
  8020e5:	75 15                	jne    8020fc <__umoddi3+0x38>
    {
      if (d0 > n1)
  8020e7:	39 f1                	cmp    %esi,%ecx
  8020e9:	0f 86 99 00 00 00    	jbe    802188 <__umoddi3+0xc4>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8020ef:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  8020f1:	89 d0                	mov    %edx,%eax
  8020f3:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8020f5:	83 c4 20             	add    $0x20,%esp
  8020f8:	5e                   	pop    %esi
  8020f9:	5f                   	pop    %edi
  8020fa:	c9                   	leave  
  8020fb:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  8020fc:	39 f7                	cmp    %esi,%edi
  8020fe:	0f 87 a4 00 00 00    	ja     8021a8 <__umoddi3+0xe4>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  802104:	0f bd c7             	bsr    %edi,%eax
	  if (bm == 0)
  802107:	83 f0 1f             	xor    $0x1f,%eax
  80210a:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80210d:	0f 84 a1 00 00 00    	je     8021b4 <__umoddi3+0xf0>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  802113:	89 f8                	mov    %edi,%eax
  802115:	8a 4d ec             	mov    -0x14(%ebp),%cl
  802118:	d3 e0                	shl    %cl,%eax
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  80211a:	bf 20 00 00 00       	mov    $0x20,%edi
  80211f:	2b 7d ec             	sub    -0x14(%ebp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  802122:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802125:	89 f9                	mov    %edi,%ecx
  802127:	d3 ea                	shr    %cl,%edx
  802129:	09 c2                	or     %eax,%edx
  80212b:	89 55 f0             	mov    %edx,-0x10(%ebp)
	      d0 = d0 << bm;
  80212e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802131:	8a 4d ec             	mov    -0x14(%ebp),%cl
  802134:	d3 e0                	shl    %cl,%eax
  802136:	89 45 f4             	mov    %eax,-0xc(%ebp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  802139:	89 f2                	mov    %esi,%edx
  80213b:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  80213d:	8b 45 e8             	mov    -0x18(%ebp),%eax
  802140:	d3 e0                	shl    %cl,%eax
  802142:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  802145:	8b 45 e8             	mov    -0x18(%ebp),%eax
  802148:	89 f9                	mov    %edi,%ecx
  80214a:	d3 e8                	shr    %cl,%eax
  80214c:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  80214e:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  802150:	89 f2                	mov    %esi,%edx
  802152:	f7 75 f0             	divl   -0x10(%ebp)
  802155:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  802157:	f7 65 f4             	mull   -0xc(%ebp)
  80215a:	89 55 e8             	mov    %edx,-0x18(%ebp)
  80215d:	89 c1                	mov    %eax,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  80215f:	39 d6                	cmp    %edx,%esi
  802161:	72 71                	jb     8021d4 <__umoddi3+0x110>
  802163:	74 7f                	je     8021e4 <__umoddi3+0x120>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  802165:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802168:	29 c8                	sub    %ecx,%eax
  80216a:	19 d6                	sbb    %edx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  80216c:	8a 4d ec             	mov    -0x14(%ebp),%cl
  80216f:	d3 e8                	shr    %cl,%eax
  802171:	89 f2                	mov    %esi,%edx
  802173:	89 f9                	mov    %edi,%ecx
  802175:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  802177:	09 d0                	or     %edx,%eax
  802179:	89 f2                	mov    %esi,%edx
  80217b:	8a 4d ec             	mov    -0x14(%ebp),%cl
  80217e:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802180:	83 c4 20             	add    $0x20,%esp
  802183:	5e                   	pop    %esi
  802184:	5f                   	pop    %edi
  802185:	c9                   	leave  
  802186:	c3                   	ret    
  802187:	90                   	nop
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  802188:	85 c9                	test   %ecx,%ecx
  80218a:	75 0b                	jne    802197 <__umoddi3+0xd3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  80218c:	b8 01 00 00 00       	mov    $0x1,%eax
  802191:	31 d2                	xor    %edx,%edx
  802193:	f7 f1                	div    %ecx
  802195:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  802197:	89 f0                	mov    %esi,%eax
  802199:	31 d2                	xor    %edx,%edx
  80219b:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  80219d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8021a0:	f7 f1                	div    %ecx
  8021a2:	e9 4a ff ff ff       	jmp    8020f1 <__umoddi3+0x2d>
  8021a7:	90                   	nop
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  8021a8:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8021aa:	83 c4 20             	add    $0x20,%esp
  8021ad:	5e                   	pop    %esi
  8021ae:	5f                   	pop    %edi
  8021af:	c9                   	leave  
  8021b0:	c3                   	ret    
  8021b1:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  8021b4:	39 f7                	cmp    %esi,%edi
  8021b6:	72 05                	jb     8021bd <__umoddi3+0xf9>
  8021b8:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
  8021bb:	77 0c                	ja     8021c9 <__umoddi3+0x105>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  8021bd:	89 f2                	mov    %esi,%edx
  8021bf:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8021c2:	29 c8                	sub    %ecx,%eax
  8021c4:	19 fa                	sbb    %edi,%edx
  8021c6:	89 45 f0             	mov    %eax,-0x10(%ebp)

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  8021c9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8021cc:	83 c4 20             	add    $0x20,%esp
  8021cf:	5e                   	pop    %esi
  8021d0:	5f                   	pop    %edi
  8021d1:	c9                   	leave  
  8021d2:	c3                   	ret    
  8021d3:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  8021d4:	8b 55 e8             	mov    -0x18(%ebp),%edx
  8021d7:	89 c1                	mov    %eax,%ecx
  8021d9:	2b 4d f4             	sub    -0xc(%ebp),%ecx
  8021dc:	1b 55 f0             	sbb    -0x10(%ebp),%edx
  8021df:	eb 84                	jmp    802165 <__umoddi3+0xa1>
  8021e1:	8d 76 00             	lea    0x0(%esi),%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8021e4:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  8021e7:	72 eb                	jb     8021d4 <__umoddi3+0x110>
  8021e9:	89 f2                	mov    %esi,%edx
  8021eb:	e9 75 ff ff ff       	jmp    802165 <__umoddi3+0xa1>
