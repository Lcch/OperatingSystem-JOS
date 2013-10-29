
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
  800172:	e8 43 11 00 00       	call   8012ba <close_all>
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
  8001bc:	c7 04 24 f9 27 80 00 	movl   $0x8027f9,(%esp)
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
  8002c8:	e8 e7 1c 00 00       	call   801fb4 <__udivdi3>
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
  800304:	e8 c7 1d 00 00       	call   8020d0 <__umoddi3>
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
  800522:	68 db 27 80 00       	push   $0x8027db
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
  800eb8:	e8 c7 0e 00 00       	call   801d84 <set_pgfault_handler>
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
  800ed8:	6a 7b                	push   $0x7b
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
  800f0a:	e9 7b 01 00 00       	jmp    80108a <fork+0x1e0>
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
  800f22:	0f 84 cd 00 00 00    	je     800ff5 <fork+0x14b>
  800f28:	89 d8                	mov    %ebx,%eax
  800f2a:	c1 e8 0c             	shr    $0xc,%eax
  800f2d:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800f34:	f6 c2 01             	test   $0x1,%dl
  800f37:	0f 84 b8 00 00 00    	je     800ff5 <fork+0x14b>
  800f3d:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800f44:	f6 c2 04             	test   $0x4,%dl
  800f47:	0f 84 a8 00 00 00    	je     800ff5 <fork+0x14b>
//
static int
duppage(envid_t envid, unsigned pn)
{
	// do not dup exception stack
	if (pn * PGSIZE == UXSTACKTOP - PGSIZE) return 0;
  800f4d:	89 c6                	mov    %eax,%esi
  800f4f:	c1 e6 0c             	shl    $0xc,%esi
  800f52:	81 fe 00 f0 bf ee    	cmp    $0xeebff000,%esi
  800f58:	0f 84 97 00 00 00    	je     800ff5 <fork+0x14b>

	int r;
	void * addr = (void *)(pn * PGSIZE);
	if ((uvpt[pn] & PTE_W) || (uvpt[pn] & PTE_COW)) {
  800f5e:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800f65:	f6 c2 02             	test   $0x2,%dl
  800f68:	75 0c                	jne    800f76 <fork+0xcc>
  800f6a:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f71:	f6 c4 08             	test   $0x8,%ah
  800f74:	74 57                	je     800fcd <fork+0x123>
		// cow
		r = sys_page_map(0, addr, envid, addr, PTE_COW | PTE_P | PTE_U);
  800f76:	83 ec 0c             	sub    $0xc,%esp
  800f79:	68 05 08 00 00       	push   $0x805
  800f7e:	56                   	push   %esi
  800f7f:	57                   	push   %edi
  800f80:	56                   	push   %esi
  800f81:	6a 00                	push   $0x0
  800f83:	e8 34 fd ff ff       	call   800cbc <sys_page_map>
		if (r < 0) panic("duppage sys_page_map error : %e\n", r);
  800f88:	83 c4 20             	add    $0x20,%esp
  800f8b:	85 c0                	test   %eax,%eax
  800f8d:	79 12                	jns    800fa1 <fork+0xf7>
  800f8f:	50                   	push   %eax
  800f90:	68 3c 26 80 00       	push   $0x80263c
  800f95:	6a 55                	push   $0x55
  800f97:	68 f0 26 80 00       	push   $0x8026f0
  800f9c:	e8 e7 f1 ff ff       	call   800188 <_panic>
		
		r = sys_page_map(0, addr, 0, addr, PTE_COW | PTE_P | PTE_U);
  800fa1:	83 ec 0c             	sub    $0xc,%esp
  800fa4:	68 05 08 00 00       	push   $0x805
  800fa9:	56                   	push   %esi
  800faa:	6a 00                	push   $0x0
  800fac:	56                   	push   %esi
  800fad:	6a 00                	push   $0x0
  800faf:	e8 08 fd ff ff       	call   800cbc <sys_page_map>
		if (r < 0) panic("duppage sys_page_map error : %e\n", r);
  800fb4:	83 c4 20             	add    $0x20,%esp
  800fb7:	85 c0                	test   %eax,%eax
  800fb9:	79 3a                	jns    800ff5 <fork+0x14b>
  800fbb:	50                   	push   %eax
  800fbc:	68 3c 26 80 00       	push   $0x80263c
  800fc1:	6a 58                	push   $0x58
  800fc3:	68 f0 26 80 00       	push   $0x8026f0
  800fc8:	e8 bb f1 ff ff       	call   800188 <_panic>
	} else {
		// read only
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U);
  800fcd:	83 ec 0c             	sub    $0xc,%esp
  800fd0:	6a 05                	push   $0x5
  800fd2:	56                   	push   %esi
  800fd3:	57                   	push   %edi
  800fd4:	56                   	push   %esi
  800fd5:	6a 00                	push   $0x0
  800fd7:	e8 e0 fc ff ff       	call   800cbc <sys_page_map>
		if (r < 0) panic("duppage sys_page_map error : %e\n", r);
  800fdc:	83 c4 20             	add    $0x20,%esp
  800fdf:	85 c0                	test   %eax,%eax
  800fe1:	79 12                	jns    800ff5 <fork+0x14b>
  800fe3:	50                   	push   %eax
  800fe4:	68 3c 26 80 00       	push   $0x80263c
  800fe9:	6a 5c                	push   $0x5c
  800feb:	68 f0 26 80 00       	push   $0x8026f0
  800ff0:	e8 93 f1 ff ff       	call   800188 <_panic>
		return 0;
	} else {
		// map page to new environment
		// kernel page is already in new environment
		uint32_t i;
		for (i = 0; i != UTOP; i += PGSIZE) 
  800ff5:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  800ffb:	81 fb 00 00 c0 ee    	cmp    $0xeec00000,%ebx
  801001:	0f 85 0d ff ff ff    	jne    800f14 <fork+0x6a>
		if ((uvpd[PDX(i)] & PTE_P) && (uvpt[i / PGSIZE] & PTE_P) && (uvpt[i / PGSIZE] & PTE_U)) {
			duppage(childpid, i / PGSIZE);
		}

		// allocate exception stack
		r = sys_page_alloc(childpid, (void *)(UXSTACKTOP - PGSIZE), PTE_U | PTE_W | PTE_P);
  801007:	83 ec 04             	sub    $0x4,%esp
  80100a:	6a 07                	push   $0x7
  80100c:	68 00 f0 bf ee       	push   $0xeebff000
  801011:	ff 75 e4             	pushl  -0x1c(%ebp)
  801014:	e8 7f fc ff ff       	call   800c98 <sys_page_alloc>
		if (r < 0) panic("fork, sys_page_alloc user exception stack error : %e\n", r);
  801019:	83 c4 10             	add    $0x10,%esp
  80101c:	85 c0                	test   %eax,%eax
  80101e:	79 15                	jns    801035 <fork+0x18b>
  801020:	50                   	push   %eax
  801021:	68 60 26 80 00       	push   $0x802660
  801026:	68 90 00 00 00       	push   $0x90
  80102b:	68 f0 26 80 00       	push   $0x8026f0
  801030:	e8 53 f1 ff ff       	call   800188 <_panic>

		// set user environment user page fault handler 
		extern void _pgfault_upcall(void);
		r = sys_env_set_pgfault_upcall(childpid, _pgfault_upcall);
  801035:	83 ec 08             	sub    $0x8,%esp
  801038:	68 f0 1d 80 00       	push   $0x801df0
  80103d:	ff 75 e4             	pushl  -0x1c(%ebp)
  801040:	e8 06 fd ff ff       	call   800d4b <sys_env_set_pgfault_upcall>
		if (r < 0) panic("fork, set pgfault upcall fail : %e\n", r);
  801045:	83 c4 10             	add    $0x10,%esp
  801048:	85 c0                	test   %eax,%eax
  80104a:	79 15                	jns    801061 <fork+0x1b7>
  80104c:	50                   	push   %eax
  80104d:	68 98 26 80 00       	push   $0x802698
  801052:	68 95 00 00 00       	push   $0x95
  801057:	68 f0 26 80 00       	push   $0x8026f0
  80105c:	e8 27 f1 ff ff       	call   800188 <_panic>
		r = sys_set_priority(childpid, num);
		if (r < 0) panic("fork, set priority error\n");
		*/

		// mark the child as runnable and return
		r = sys_env_set_status(childpid, ENV_RUNNABLE);
  801061:	83 ec 08             	sub    $0x8,%esp
  801064:	6a 02                	push   $0x2
  801066:	ff 75 e4             	pushl  -0x1c(%ebp)
  801069:	e8 97 fc ff ff       	call   800d05 <sys_env_set_status>
		if (r < 0) panic("fork, set child process to ENV_RUNNABLE error : %e\n", r);
  80106e:	83 c4 10             	add    $0x10,%esp
  801071:	85 c0                	test   %eax,%eax
  801073:	79 15                	jns    80108a <fork+0x1e0>
  801075:	50                   	push   %eax
  801076:	68 bc 26 80 00       	push   $0x8026bc
  80107b:	68 a0 00 00 00       	push   $0xa0
  801080:	68 f0 26 80 00       	push   $0x8026f0
  801085:	e8 fe f0 ff ff       	call   800188 <_panic>
		// cprintf("fork father ok!")
		return childpid;
	}

	panic("fork not implemented");
}
  80108a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80108d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801090:	5b                   	pop    %ebx
  801091:	5e                   	pop    %esi
  801092:	5f                   	pop    %edi
  801093:	c9                   	leave  
  801094:	c3                   	ret    

00801095 <sfork>:

// Challenge!
int
sfork(void)
{
  801095:	55                   	push   %ebp
  801096:	89 e5                	mov    %esp,%ebp
  801098:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  80109b:	68 18 27 80 00       	push   $0x802718
  8010a0:	68 ad 00 00 00       	push   $0xad
  8010a5:	68 f0 26 80 00       	push   $0x8026f0
  8010aa:	e8 d9 f0 ff ff       	call   800188 <_panic>
	...

008010b0 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8010b0:	55                   	push   %ebp
  8010b1:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8010b3:	8b 45 08             	mov    0x8(%ebp),%eax
  8010b6:	05 00 00 00 30       	add    $0x30000000,%eax
  8010bb:	c1 e8 0c             	shr    $0xc,%eax
}
  8010be:	c9                   	leave  
  8010bf:	c3                   	ret    

008010c0 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8010c0:	55                   	push   %ebp
  8010c1:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  8010c3:	ff 75 08             	pushl  0x8(%ebp)
  8010c6:	e8 e5 ff ff ff       	call   8010b0 <fd2num>
  8010cb:	83 c4 04             	add    $0x4,%esp
  8010ce:	05 20 00 0d 00       	add    $0xd0020,%eax
  8010d3:	c1 e0 0c             	shl    $0xc,%eax
}
  8010d6:	c9                   	leave  
  8010d7:	c3                   	ret    

008010d8 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8010d8:	55                   	push   %ebp
  8010d9:	89 e5                	mov    %esp,%ebp
  8010db:	53                   	push   %ebx
  8010dc:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8010df:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  8010e4:	a8 01                	test   $0x1,%al
  8010e6:	74 34                	je     80111c <fd_alloc+0x44>
  8010e8:	a1 00 00 74 ef       	mov    0xef740000,%eax
  8010ed:	a8 01                	test   $0x1,%al
  8010ef:	74 32                	je     801123 <fd_alloc+0x4b>
  8010f1:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
  8010f6:	89 c1                	mov    %eax,%ecx
  8010f8:	89 c2                	mov    %eax,%edx
  8010fa:	c1 ea 16             	shr    $0x16,%edx
  8010fd:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801104:	f6 c2 01             	test   $0x1,%dl
  801107:	74 1f                	je     801128 <fd_alloc+0x50>
  801109:	89 c2                	mov    %eax,%edx
  80110b:	c1 ea 0c             	shr    $0xc,%edx
  80110e:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801115:	f6 c2 01             	test   $0x1,%dl
  801118:	75 17                	jne    801131 <fd_alloc+0x59>
  80111a:	eb 0c                	jmp    801128 <fd_alloc+0x50>
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  80111c:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
  801121:	eb 05                	jmp    801128 <fd_alloc+0x50>
  801123:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
  801128:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  80112a:	b8 00 00 00 00       	mov    $0x0,%eax
  80112f:	eb 17                	jmp    801148 <fd_alloc+0x70>
  801131:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801136:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80113b:	75 b9                	jne    8010f6 <fd_alloc+0x1e>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  80113d:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  801143:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801148:	5b                   	pop    %ebx
  801149:	c9                   	leave  
  80114a:	c3                   	ret    

0080114b <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80114b:	55                   	push   %ebp
  80114c:	89 e5                	mov    %esp,%ebp
  80114e:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801151:	83 f8 1f             	cmp    $0x1f,%eax
  801154:	77 36                	ja     80118c <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801156:	05 00 00 0d 00       	add    $0xd0000,%eax
  80115b:	c1 e0 0c             	shl    $0xc,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80115e:	89 c2                	mov    %eax,%edx
  801160:	c1 ea 16             	shr    $0x16,%edx
  801163:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80116a:	f6 c2 01             	test   $0x1,%dl
  80116d:	74 24                	je     801193 <fd_lookup+0x48>
  80116f:	89 c2                	mov    %eax,%edx
  801171:	c1 ea 0c             	shr    $0xc,%edx
  801174:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80117b:	f6 c2 01             	test   $0x1,%dl
  80117e:	74 1a                	je     80119a <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801180:	8b 55 0c             	mov    0xc(%ebp),%edx
  801183:	89 02                	mov    %eax,(%edx)
	return 0;
  801185:	b8 00 00 00 00       	mov    $0x0,%eax
  80118a:	eb 13                	jmp    80119f <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80118c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801191:	eb 0c                	jmp    80119f <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801193:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801198:	eb 05                	jmp    80119f <fd_lookup+0x54>
  80119a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  80119f:	c9                   	leave  
  8011a0:	c3                   	ret    

008011a1 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8011a1:	55                   	push   %ebp
  8011a2:	89 e5                	mov    %esp,%ebp
  8011a4:	53                   	push   %ebx
  8011a5:	83 ec 04             	sub    $0x4,%esp
  8011a8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8011ab:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  8011ae:	39 0d 04 30 80 00    	cmp    %ecx,0x803004
  8011b4:	74 0d                	je     8011c3 <dev_lookup+0x22>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8011b6:	b8 00 00 00 00       	mov    $0x0,%eax
  8011bb:	eb 14                	jmp    8011d1 <dev_lookup+0x30>
		if (devtab[i]->dev_id == dev_id) {
  8011bd:	39 0a                	cmp    %ecx,(%edx)
  8011bf:	75 10                	jne    8011d1 <dev_lookup+0x30>
  8011c1:	eb 05                	jmp    8011c8 <dev_lookup+0x27>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8011c3:	ba 04 30 80 00       	mov    $0x803004,%edx
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
  8011c8:	89 13                	mov    %edx,(%ebx)
			return 0;
  8011ca:	b8 00 00 00 00       	mov    $0x0,%eax
  8011cf:	eb 31                	jmp    801202 <dev_lookup+0x61>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8011d1:	40                   	inc    %eax
  8011d2:	8b 14 85 ac 27 80 00 	mov    0x8027ac(,%eax,4),%edx
  8011d9:	85 d2                	test   %edx,%edx
  8011db:	75 e0                	jne    8011bd <dev_lookup+0x1c>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8011dd:	a1 08 40 80 00       	mov    0x804008,%eax
  8011e2:	8b 40 48             	mov    0x48(%eax),%eax
  8011e5:	83 ec 04             	sub    $0x4,%esp
  8011e8:	51                   	push   %ecx
  8011e9:	50                   	push   %eax
  8011ea:	68 30 27 80 00       	push   $0x802730
  8011ef:	e8 6c f0 ff ff       	call   800260 <cprintf>
	*dev = 0;
  8011f4:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  8011fa:	83 c4 10             	add    $0x10,%esp
  8011fd:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801202:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801205:	c9                   	leave  
  801206:	c3                   	ret    

00801207 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801207:	55                   	push   %ebp
  801208:	89 e5                	mov    %esp,%ebp
  80120a:	56                   	push   %esi
  80120b:	53                   	push   %ebx
  80120c:	83 ec 20             	sub    $0x20,%esp
  80120f:	8b 75 08             	mov    0x8(%ebp),%esi
  801212:	8a 45 0c             	mov    0xc(%ebp),%al
  801215:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801218:	56                   	push   %esi
  801219:	e8 92 fe ff ff       	call   8010b0 <fd2num>
  80121e:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801221:	89 14 24             	mov    %edx,(%esp)
  801224:	50                   	push   %eax
  801225:	e8 21 ff ff ff       	call   80114b <fd_lookup>
  80122a:	89 c3                	mov    %eax,%ebx
  80122c:	83 c4 08             	add    $0x8,%esp
  80122f:	85 c0                	test   %eax,%eax
  801231:	78 05                	js     801238 <fd_close+0x31>
	    || fd != fd2)
  801233:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801236:	74 0d                	je     801245 <fd_close+0x3e>
		return (must_exist ? r : 0);
  801238:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  80123c:	75 48                	jne    801286 <fd_close+0x7f>
  80123e:	bb 00 00 00 00       	mov    $0x0,%ebx
  801243:	eb 41                	jmp    801286 <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801245:	83 ec 08             	sub    $0x8,%esp
  801248:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80124b:	50                   	push   %eax
  80124c:	ff 36                	pushl  (%esi)
  80124e:	e8 4e ff ff ff       	call   8011a1 <dev_lookup>
  801253:	89 c3                	mov    %eax,%ebx
  801255:	83 c4 10             	add    $0x10,%esp
  801258:	85 c0                	test   %eax,%eax
  80125a:	78 1c                	js     801278 <fd_close+0x71>
		if (dev->dev_close)
  80125c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80125f:	8b 40 10             	mov    0x10(%eax),%eax
  801262:	85 c0                	test   %eax,%eax
  801264:	74 0d                	je     801273 <fd_close+0x6c>
			r = (*dev->dev_close)(fd);
  801266:	83 ec 0c             	sub    $0xc,%esp
  801269:	56                   	push   %esi
  80126a:	ff d0                	call   *%eax
  80126c:	89 c3                	mov    %eax,%ebx
  80126e:	83 c4 10             	add    $0x10,%esp
  801271:	eb 05                	jmp    801278 <fd_close+0x71>
		else
			r = 0;
  801273:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801278:	83 ec 08             	sub    $0x8,%esp
  80127b:	56                   	push   %esi
  80127c:	6a 00                	push   $0x0
  80127e:	e8 5f fa ff ff       	call   800ce2 <sys_page_unmap>
	return r;
  801283:	83 c4 10             	add    $0x10,%esp
}
  801286:	89 d8                	mov    %ebx,%eax
  801288:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80128b:	5b                   	pop    %ebx
  80128c:	5e                   	pop    %esi
  80128d:	c9                   	leave  
  80128e:	c3                   	ret    

0080128f <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80128f:	55                   	push   %ebp
  801290:	89 e5                	mov    %esp,%ebp
  801292:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801295:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801298:	50                   	push   %eax
  801299:	ff 75 08             	pushl  0x8(%ebp)
  80129c:	e8 aa fe ff ff       	call   80114b <fd_lookup>
  8012a1:	83 c4 08             	add    $0x8,%esp
  8012a4:	85 c0                	test   %eax,%eax
  8012a6:	78 10                	js     8012b8 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  8012a8:	83 ec 08             	sub    $0x8,%esp
  8012ab:	6a 01                	push   $0x1
  8012ad:	ff 75 f4             	pushl  -0xc(%ebp)
  8012b0:	e8 52 ff ff ff       	call   801207 <fd_close>
  8012b5:	83 c4 10             	add    $0x10,%esp
}
  8012b8:	c9                   	leave  
  8012b9:	c3                   	ret    

008012ba <close_all>:

void
close_all(void)
{
  8012ba:	55                   	push   %ebp
  8012bb:	89 e5                	mov    %esp,%ebp
  8012bd:	53                   	push   %ebx
  8012be:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8012c1:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8012c6:	83 ec 0c             	sub    $0xc,%esp
  8012c9:	53                   	push   %ebx
  8012ca:	e8 c0 ff ff ff       	call   80128f <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8012cf:	43                   	inc    %ebx
  8012d0:	83 c4 10             	add    $0x10,%esp
  8012d3:	83 fb 20             	cmp    $0x20,%ebx
  8012d6:	75 ee                	jne    8012c6 <close_all+0xc>
		close(i);
}
  8012d8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012db:	c9                   	leave  
  8012dc:	c3                   	ret    

008012dd <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8012dd:	55                   	push   %ebp
  8012de:	89 e5                	mov    %esp,%ebp
  8012e0:	57                   	push   %edi
  8012e1:	56                   	push   %esi
  8012e2:	53                   	push   %ebx
  8012e3:	83 ec 2c             	sub    $0x2c,%esp
  8012e6:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8012e9:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8012ec:	50                   	push   %eax
  8012ed:	ff 75 08             	pushl  0x8(%ebp)
  8012f0:	e8 56 fe ff ff       	call   80114b <fd_lookup>
  8012f5:	89 c3                	mov    %eax,%ebx
  8012f7:	83 c4 08             	add    $0x8,%esp
  8012fa:	85 c0                	test   %eax,%eax
  8012fc:	0f 88 c0 00 00 00    	js     8013c2 <dup+0xe5>
		return r;
	close(newfdnum);
  801302:	83 ec 0c             	sub    $0xc,%esp
  801305:	57                   	push   %edi
  801306:	e8 84 ff ff ff       	call   80128f <close>

	newfd = INDEX2FD(newfdnum);
  80130b:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  801311:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  801314:	83 c4 04             	add    $0x4,%esp
  801317:	ff 75 e4             	pushl  -0x1c(%ebp)
  80131a:	e8 a1 fd ff ff       	call   8010c0 <fd2data>
  80131f:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801321:	89 34 24             	mov    %esi,(%esp)
  801324:	e8 97 fd ff ff       	call   8010c0 <fd2data>
  801329:	83 c4 10             	add    $0x10,%esp
  80132c:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80132f:	89 d8                	mov    %ebx,%eax
  801331:	c1 e8 16             	shr    $0x16,%eax
  801334:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80133b:	a8 01                	test   $0x1,%al
  80133d:	74 37                	je     801376 <dup+0x99>
  80133f:	89 d8                	mov    %ebx,%eax
  801341:	c1 e8 0c             	shr    $0xc,%eax
  801344:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80134b:	f6 c2 01             	test   $0x1,%dl
  80134e:	74 26                	je     801376 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801350:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801357:	83 ec 0c             	sub    $0xc,%esp
  80135a:	25 07 0e 00 00       	and    $0xe07,%eax
  80135f:	50                   	push   %eax
  801360:	ff 75 d4             	pushl  -0x2c(%ebp)
  801363:	6a 00                	push   $0x0
  801365:	53                   	push   %ebx
  801366:	6a 00                	push   $0x0
  801368:	e8 4f f9 ff ff       	call   800cbc <sys_page_map>
  80136d:	89 c3                	mov    %eax,%ebx
  80136f:	83 c4 20             	add    $0x20,%esp
  801372:	85 c0                	test   %eax,%eax
  801374:	78 2d                	js     8013a3 <dup+0xc6>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801376:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801379:	89 c2                	mov    %eax,%edx
  80137b:	c1 ea 0c             	shr    $0xc,%edx
  80137e:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801385:	83 ec 0c             	sub    $0xc,%esp
  801388:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  80138e:	52                   	push   %edx
  80138f:	56                   	push   %esi
  801390:	6a 00                	push   $0x0
  801392:	50                   	push   %eax
  801393:	6a 00                	push   $0x0
  801395:	e8 22 f9 ff ff       	call   800cbc <sys_page_map>
  80139a:	89 c3                	mov    %eax,%ebx
  80139c:	83 c4 20             	add    $0x20,%esp
  80139f:	85 c0                	test   %eax,%eax
  8013a1:	79 1d                	jns    8013c0 <dup+0xe3>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8013a3:	83 ec 08             	sub    $0x8,%esp
  8013a6:	56                   	push   %esi
  8013a7:	6a 00                	push   $0x0
  8013a9:	e8 34 f9 ff ff       	call   800ce2 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8013ae:	83 c4 08             	add    $0x8,%esp
  8013b1:	ff 75 d4             	pushl  -0x2c(%ebp)
  8013b4:	6a 00                	push   $0x0
  8013b6:	e8 27 f9 ff ff       	call   800ce2 <sys_page_unmap>
	return r;
  8013bb:	83 c4 10             	add    $0x10,%esp
  8013be:	eb 02                	jmp    8013c2 <dup+0xe5>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  8013c0:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  8013c2:	89 d8                	mov    %ebx,%eax
  8013c4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8013c7:	5b                   	pop    %ebx
  8013c8:	5e                   	pop    %esi
  8013c9:	5f                   	pop    %edi
  8013ca:	c9                   	leave  
  8013cb:	c3                   	ret    

008013cc <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8013cc:	55                   	push   %ebp
  8013cd:	89 e5                	mov    %esp,%ebp
  8013cf:	53                   	push   %ebx
  8013d0:	83 ec 14             	sub    $0x14,%esp
  8013d3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8013d6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8013d9:	50                   	push   %eax
  8013da:	53                   	push   %ebx
  8013db:	e8 6b fd ff ff       	call   80114b <fd_lookup>
  8013e0:	83 c4 08             	add    $0x8,%esp
  8013e3:	85 c0                	test   %eax,%eax
  8013e5:	78 67                	js     80144e <read+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013e7:	83 ec 08             	sub    $0x8,%esp
  8013ea:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013ed:	50                   	push   %eax
  8013ee:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013f1:	ff 30                	pushl  (%eax)
  8013f3:	e8 a9 fd ff ff       	call   8011a1 <dev_lookup>
  8013f8:	83 c4 10             	add    $0x10,%esp
  8013fb:	85 c0                	test   %eax,%eax
  8013fd:	78 4f                	js     80144e <read+0x82>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8013ff:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801402:	8b 50 08             	mov    0x8(%eax),%edx
  801405:	83 e2 03             	and    $0x3,%edx
  801408:	83 fa 01             	cmp    $0x1,%edx
  80140b:	75 21                	jne    80142e <read+0x62>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80140d:	a1 08 40 80 00       	mov    0x804008,%eax
  801412:	8b 40 48             	mov    0x48(%eax),%eax
  801415:	83 ec 04             	sub    $0x4,%esp
  801418:	53                   	push   %ebx
  801419:	50                   	push   %eax
  80141a:	68 71 27 80 00       	push   $0x802771
  80141f:	e8 3c ee ff ff       	call   800260 <cprintf>
		return -E_INVAL;
  801424:	83 c4 10             	add    $0x10,%esp
  801427:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80142c:	eb 20                	jmp    80144e <read+0x82>
	}
	if (!dev->dev_read)
  80142e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801431:	8b 52 08             	mov    0x8(%edx),%edx
  801434:	85 d2                	test   %edx,%edx
  801436:	74 11                	je     801449 <read+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801438:	83 ec 04             	sub    $0x4,%esp
  80143b:	ff 75 10             	pushl  0x10(%ebp)
  80143e:	ff 75 0c             	pushl  0xc(%ebp)
  801441:	50                   	push   %eax
  801442:	ff d2                	call   *%edx
  801444:	83 c4 10             	add    $0x10,%esp
  801447:	eb 05                	jmp    80144e <read+0x82>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801449:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  80144e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801451:	c9                   	leave  
  801452:	c3                   	ret    

00801453 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801453:	55                   	push   %ebp
  801454:	89 e5                	mov    %esp,%ebp
  801456:	57                   	push   %edi
  801457:	56                   	push   %esi
  801458:	53                   	push   %ebx
  801459:	83 ec 0c             	sub    $0xc,%esp
  80145c:	8b 7d 08             	mov    0x8(%ebp),%edi
  80145f:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801462:	85 f6                	test   %esi,%esi
  801464:	74 31                	je     801497 <readn+0x44>
  801466:	b8 00 00 00 00       	mov    $0x0,%eax
  80146b:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = read(fdnum, (char*)buf + tot, n - tot);
  801470:	83 ec 04             	sub    $0x4,%esp
  801473:	89 f2                	mov    %esi,%edx
  801475:	29 c2                	sub    %eax,%edx
  801477:	52                   	push   %edx
  801478:	03 45 0c             	add    0xc(%ebp),%eax
  80147b:	50                   	push   %eax
  80147c:	57                   	push   %edi
  80147d:	e8 4a ff ff ff       	call   8013cc <read>
		if (m < 0)
  801482:	83 c4 10             	add    $0x10,%esp
  801485:	85 c0                	test   %eax,%eax
  801487:	78 17                	js     8014a0 <readn+0x4d>
			return m;
		if (m == 0)
  801489:	85 c0                	test   %eax,%eax
  80148b:	74 11                	je     80149e <readn+0x4b>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80148d:	01 c3                	add    %eax,%ebx
  80148f:	89 d8                	mov    %ebx,%eax
  801491:	39 f3                	cmp    %esi,%ebx
  801493:	72 db                	jb     801470 <readn+0x1d>
  801495:	eb 09                	jmp    8014a0 <readn+0x4d>
  801497:	b8 00 00 00 00       	mov    $0x0,%eax
  80149c:	eb 02                	jmp    8014a0 <readn+0x4d>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  80149e:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  8014a0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8014a3:	5b                   	pop    %ebx
  8014a4:	5e                   	pop    %esi
  8014a5:	5f                   	pop    %edi
  8014a6:	c9                   	leave  
  8014a7:	c3                   	ret    

008014a8 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8014a8:	55                   	push   %ebp
  8014a9:	89 e5                	mov    %esp,%ebp
  8014ab:	53                   	push   %ebx
  8014ac:	83 ec 14             	sub    $0x14,%esp
  8014af:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8014b2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014b5:	50                   	push   %eax
  8014b6:	53                   	push   %ebx
  8014b7:	e8 8f fc ff ff       	call   80114b <fd_lookup>
  8014bc:	83 c4 08             	add    $0x8,%esp
  8014bf:	85 c0                	test   %eax,%eax
  8014c1:	78 62                	js     801525 <write+0x7d>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014c3:	83 ec 08             	sub    $0x8,%esp
  8014c6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014c9:	50                   	push   %eax
  8014ca:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014cd:	ff 30                	pushl  (%eax)
  8014cf:	e8 cd fc ff ff       	call   8011a1 <dev_lookup>
  8014d4:	83 c4 10             	add    $0x10,%esp
  8014d7:	85 c0                	test   %eax,%eax
  8014d9:	78 4a                	js     801525 <write+0x7d>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8014db:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014de:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8014e2:	75 21                	jne    801505 <write+0x5d>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8014e4:	a1 08 40 80 00       	mov    0x804008,%eax
  8014e9:	8b 40 48             	mov    0x48(%eax),%eax
  8014ec:	83 ec 04             	sub    $0x4,%esp
  8014ef:	53                   	push   %ebx
  8014f0:	50                   	push   %eax
  8014f1:	68 8d 27 80 00       	push   $0x80278d
  8014f6:	e8 65 ed ff ff       	call   800260 <cprintf>
		return -E_INVAL;
  8014fb:	83 c4 10             	add    $0x10,%esp
  8014fe:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801503:	eb 20                	jmp    801525 <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801505:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801508:	8b 52 0c             	mov    0xc(%edx),%edx
  80150b:	85 d2                	test   %edx,%edx
  80150d:	74 11                	je     801520 <write+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80150f:	83 ec 04             	sub    $0x4,%esp
  801512:	ff 75 10             	pushl  0x10(%ebp)
  801515:	ff 75 0c             	pushl  0xc(%ebp)
  801518:	50                   	push   %eax
  801519:	ff d2                	call   *%edx
  80151b:	83 c4 10             	add    $0x10,%esp
  80151e:	eb 05                	jmp    801525 <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801520:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  801525:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801528:	c9                   	leave  
  801529:	c3                   	ret    

0080152a <seek>:

int
seek(int fdnum, off_t offset)
{
  80152a:	55                   	push   %ebp
  80152b:	89 e5                	mov    %esp,%ebp
  80152d:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801530:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801533:	50                   	push   %eax
  801534:	ff 75 08             	pushl  0x8(%ebp)
  801537:	e8 0f fc ff ff       	call   80114b <fd_lookup>
  80153c:	83 c4 08             	add    $0x8,%esp
  80153f:	85 c0                	test   %eax,%eax
  801541:	78 0e                	js     801551 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801543:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801546:	8b 55 0c             	mov    0xc(%ebp),%edx
  801549:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80154c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801551:	c9                   	leave  
  801552:	c3                   	ret    

00801553 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801553:	55                   	push   %ebp
  801554:	89 e5                	mov    %esp,%ebp
  801556:	53                   	push   %ebx
  801557:	83 ec 14             	sub    $0x14,%esp
  80155a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80155d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801560:	50                   	push   %eax
  801561:	53                   	push   %ebx
  801562:	e8 e4 fb ff ff       	call   80114b <fd_lookup>
  801567:	83 c4 08             	add    $0x8,%esp
  80156a:	85 c0                	test   %eax,%eax
  80156c:	78 5f                	js     8015cd <ftruncate+0x7a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80156e:	83 ec 08             	sub    $0x8,%esp
  801571:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801574:	50                   	push   %eax
  801575:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801578:	ff 30                	pushl  (%eax)
  80157a:	e8 22 fc ff ff       	call   8011a1 <dev_lookup>
  80157f:	83 c4 10             	add    $0x10,%esp
  801582:	85 c0                	test   %eax,%eax
  801584:	78 47                	js     8015cd <ftruncate+0x7a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801586:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801589:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80158d:	75 21                	jne    8015b0 <ftruncate+0x5d>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80158f:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801594:	8b 40 48             	mov    0x48(%eax),%eax
  801597:	83 ec 04             	sub    $0x4,%esp
  80159a:	53                   	push   %ebx
  80159b:	50                   	push   %eax
  80159c:	68 50 27 80 00       	push   $0x802750
  8015a1:	e8 ba ec ff ff       	call   800260 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8015a6:	83 c4 10             	add    $0x10,%esp
  8015a9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8015ae:	eb 1d                	jmp    8015cd <ftruncate+0x7a>
	}
	if (!dev->dev_trunc)
  8015b0:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8015b3:	8b 52 18             	mov    0x18(%edx),%edx
  8015b6:	85 d2                	test   %edx,%edx
  8015b8:	74 0e                	je     8015c8 <ftruncate+0x75>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8015ba:	83 ec 08             	sub    $0x8,%esp
  8015bd:	ff 75 0c             	pushl  0xc(%ebp)
  8015c0:	50                   	push   %eax
  8015c1:	ff d2                	call   *%edx
  8015c3:	83 c4 10             	add    $0x10,%esp
  8015c6:	eb 05                	jmp    8015cd <ftruncate+0x7a>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8015c8:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  8015cd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015d0:	c9                   	leave  
  8015d1:	c3                   	ret    

008015d2 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8015d2:	55                   	push   %ebp
  8015d3:	89 e5                	mov    %esp,%ebp
  8015d5:	53                   	push   %ebx
  8015d6:	83 ec 14             	sub    $0x14,%esp
  8015d9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015dc:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015df:	50                   	push   %eax
  8015e0:	ff 75 08             	pushl  0x8(%ebp)
  8015e3:	e8 63 fb ff ff       	call   80114b <fd_lookup>
  8015e8:	83 c4 08             	add    $0x8,%esp
  8015eb:	85 c0                	test   %eax,%eax
  8015ed:	78 52                	js     801641 <fstat+0x6f>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015ef:	83 ec 08             	sub    $0x8,%esp
  8015f2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015f5:	50                   	push   %eax
  8015f6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015f9:	ff 30                	pushl  (%eax)
  8015fb:	e8 a1 fb ff ff       	call   8011a1 <dev_lookup>
  801600:	83 c4 10             	add    $0x10,%esp
  801603:	85 c0                	test   %eax,%eax
  801605:	78 3a                	js     801641 <fstat+0x6f>
		return r;
	if (!dev->dev_stat)
  801607:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80160a:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80160e:	74 2c                	je     80163c <fstat+0x6a>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801610:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801613:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80161a:	00 00 00 
	stat->st_isdir = 0;
  80161d:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801624:	00 00 00 
	stat->st_dev = dev;
  801627:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80162d:	83 ec 08             	sub    $0x8,%esp
  801630:	53                   	push   %ebx
  801631:	ff 75 f0             	pushl  -0x10(%ebp)
  801634:	ff 50 14             	call   *0x14(%eax)
  801637:	83 c4 10             	add    $0x10,%esp
  80163a:	eb 05                	jmp    801641 <fstat+0x6f>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  80163c:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801641:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801644:	c9                   	leave  
  801645:	c3                   	ret    

00801646 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801646:	55                   	push   %ebp
  801647:	89 e5                	mov    %esp,%ebp
  801649:	56                   	push   %esi
  80164a:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80164b:	83 ec 08             	sub    $0x8,%esp
  80164e:	6a 00                	push   $0x0
  801650:	ff 75 08             	pushl  0x8(%ebp)
  801653:	e8 8b 01 00 00       	call   8017e3 <open>
  801658:	89 c3                	mov    %eax,%ebx
  80165a:	83 c4 10             	add    $0x10,%esp
  80165d:	85 c0                	test   %eax,%eax
  80165f:	78 1b                	js     80167c <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801661:	83 ec 08             	sub    $0x8,%esp
  801664:	ff 75 0c             	pushl  0xc(%ebp)
  801667:	50                   	push   %eax
  801668:	e8 65 ff ff ff       	call   8015d2 <fstat>
  80166d:	89 c6                	mov    %eax,%esi
	close(fd);
  80166f:	89 1c 24             	mov    %ebx,(%esp)
  801672:	e8 18 fc ff ff       	call   80128f <close>
	return r;
  801677:	83 c4 10             	add    $0x10,%esp
  80167a:	89 f3                	mov    %esi,%ebx
}
  80167c:	89 d8                	mov    %ebx,%eax
  80167e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801681:	5b                   	pop    %ebx
  801682:	5e                   	pop    %esi
  801683:	c9                   	leave  
  801684:	c3                   	ret    
  801685:	00 00                	add    %al,(%eax)
	...

00801688 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801688:	55                   	push   %ebp
  801689:	89 e5                	mov    %esp,%ebp
  80168b:	56                   	push   %esi
  80168c:	53                   	push   %ebx
  80168d:	89 c3                	mov    %eax,%ebx
  80168f:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  801691:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801698:	75 12                	jne    8016ac <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80169a:	83 ec 0c             	sub    $0xc,%esp
  80169d:	6a 01                	push   $0x1
  80169f:	e8 71 08 00 00       	call   801f15 <ipc_find_env>
  8016a4:	a3 00 40 80 00       	mov    %eax,0x804000
  8016a9:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8016ac:	6a 07                	push   $0x7
  8016ae:	68 00 50 80 00       	push   $0x805000
  8016b3:	53                   	push   %ebx
  8016b4:	ff 35 00 40 80 00    	pushl  0x804000
  8016ba:	e8 01 08 00 00       	call   801ec0 <ipc_send>
	
	return ipc_recv(NULL, dstva, NULL);
  8016bf:	83 c4 0c             	add    $0xc,%esp
  8016c2:	6a 00                	push   $0x0
  8016c4:	56                   	push   %esi
  8016c5:	6a 00                	push   $0x0
  8016c7:	e8 4c 07 00 00       	call   801e18 <ipc_recv>
}
  8016cc:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8016cf:	5b                   	pop    %ebx
  8016d0:	5e                   	pop    %esi
  8016d1:	c9                   	leave  
  8016d2:	c3                   	ret    

008016d3 <devfile_stat>:
}


static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8016d3:	55                   	push   %ebp
  8016d4:	89 e5                	mov    %esp,%ebp
  8016d6:	53                   	push   %ebx
  8016d7:	83 ec 04             	sub    $0x4,%esp
  8016da:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8016dd:	8b 45 08             	mov    0x8(%ebp),%eax
  8016e0:	8b 40 0c             	mov    0xc(%eax),%eax
  8016e3:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0) {
  8016e8:	ba 00 00 00 00       	mov    $0x0,%edx
  8016ed:	b8 05 00 00 00       	mov    $0x5,%eax
  8016f2:	e8 91 ff ff ff       	call   801688 <fsipc>
  8016f7:	85 c0                	test   %eax,%eax
  8016f9:	78 39                	js     801734 <devfile_stat+0x61>
		return r;
	}
	cprintf("OVER\n");
  8016fb:	83 ec 0c             	sub    $0xc,%esp
  8016fe:	68 bc 27 80 00       	push   $0x8027bc
  801703:	e8 58 eb ff ff       	call   800260 <cprintf>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801708:	83 c4 08             	add    $0x8,%esp
  80170b:	68 00 50 80 00       	push   $0x805000
  801710:	53                   	push   %ebx
  801711:	e8 00 f1 ff ff       	call   800816 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801716:	a1 80 50 80 00       	mov    0x805080,%eax
  80171b:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801721:	a1 84 50 80 00       	mov    0x805084,%eax
  801726:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80172c:	83 c4 10             	add    $0x10,%esp
  80172f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801734:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801737:	c9                   	leave  
  801738:	c3                   	ret    

00801739 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801739:	55                   	push   %ebp
  80173a:	89 e5                	mov    %esp,%ebp
  80173c:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80173f:	8b 45 08             	mov    0x8(%ebp),%eax
  801742:	8b 40 0c             	mov    0xc(%eax),%eax
  801745:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80174a:	ba 00 00 00 00       	mov    $0x0,%edx
  80174f:	b8 06 00 00 00       	mov    $0x6,%eax
  801754:	e8 2f ff ff ff       	call   801688 <fsipc>
}
  801759:	c9                   	leave  
  80175a:	c3                   	ret    

0080175b <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  80175b:	55                   	push   %ebp
  80175c:	89 e5                	mov    %esp,%ebp
  80175e:	56                   	push   %esi
  80175f:	53                   	push   %ebx
  801760:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801763:	8b 45 08             	mov    0x8(%ebp),%eax
  801766:	8b 40 0c             	mov    0xc(%eax),%eax
  801769:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  80176e:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801774:	ba 00 00 00 00       	mov    $0x0,%edx
  801779:	b8 03 00 00 00       	mov    $0x3,%eax
  80177e:	e8 05 ff ff ff       	call   801688 <fsipc>
  801783:	89 c3                	mov    %eax,%ebx
  801785:	85 c0                	test   %eax,%eax
  801787:	78 51                	js     8017da <devfile_read+0x7f>
		return r;
	assert(r <= n);
  801789:	39 c6                	cmp    %eax,%esi
  80178b:	73 19                	jae    8017a6 <devfile_read+0x4b>
  80178d:	68 c2 27 80 00       	push   $0x8027c2
  801792:	68 c9 27 80 00       	push   $0x8027c9
  801797:	68 80 00 00 00       	push   $0x80
  80179c:	68 de 27 80 00       	push   $0x8027de
  8017a1:	e8 e2 e9 ff ff       	call   800188 <_panic>
	assert(r <= PGSIZE);
  8017a6:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8017ab:	7e 19                	jle    8017c6 <devfile_read+0x6b>
  8017ad:	68 e9 27 80 00       	push   $0x8027e9
  8017b2:	68 c9 27 80 00       	push   $0x8027c9
  8017b7:	68 81 00 00 00       	push   $0x81
  8017bc:	68 de 27 80 00       	push   $0x8027de
  8017c1:	e8 c2 e9 ff ff       	call   800188 <_panic>
	memmove(buf, &fsipcbuf, r);
  8017c6:	83 ec 04             	sub    $0x4,%esp
  8017c9:	50                   	push   %eax
  8017ca:	68 00 50 80 00       	push   $0x805000
  8017cf:	ff 75 0c             	pushl  0xc(%ebp)
  8017d2:	e8 00 f2 ff ff       	call   8009d7 <memmove>
	return r;
  8017d7:	83 c4 10             	add    $0x10,%esp
}
  8017da:	89 d8                	mov    %ebx,%eax
  8017dc:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017df:	5b                   	pop    %ebx
  8017e0:	5e                   	pop    %esi
  8017e1:	c9                   	leave  
  8017e2:	c3                   	ret    

008017e3 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8017e3:	55                   	push   %ebp
  8017e4:	89 e5                	mov    %esp,%ebp
  8017e6:	56                   	push   %esi
  8017e7:	53                   	push   %ebx
  8017e8:	83 ec 1c             	sub    $0x1c,%esp
  8017eb:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8017ee:	56                   	push   %esi
  8017ef:	e8 d0 ef ff ff       	call   8007c4 <strlen>
  8017f4:	83 c4 10             	add    $0x10,%esp
  8017f7:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8017fc:	7f 72                	jg     801870 <open+0x8d>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8017fe:	83 ec 0c             	sub    $0xc,%esp
  801801:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801804:	50                   	push   %eax
  801805:	e8 ce f8 ff ff       	call   8010d8 <fd_alloc>
  80180a:	89 c3                	mov    %eax,%ebx
  80180c:	83 c4 10             	add    $0x10,%esp
  80180f:	85 c0                	test   %eax,%eax
  801811:	78 62                	js     801875 <open+0x92>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801813:	83 ec 08             	sub    $0x8,%esp
  801816:	56                   	push   %esi
  801817:	68 00 50 80 00       	push   $0x805000
  80181c:	e8 f5 ef ff ff       	call   800816 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801821:	8b 45 0c             	mov    0xc(%ebp),%eax
  801824:	a3 00 54 80 00       	mov    %eax,0x805400



	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801829:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80182c:	b8 01 00 00 00       	mov    $0x1,%eax
  801831:	e8 52 fe ff ff       	call   801688 <fsipc>
  801836:	89 c3                	mov    %eax,%ebx
  801838:	83 c4 10             	add    $0x10,%esp
  80183b:	85 c0                	test   %eax,%eax
  80183d:	79 12                	jns    801851 <open+0x6e>
		fd_close(fd, 0);
  80183f:	83 ec 08             	sub    $0x8,%esp
  801842:	6a 00                	push   $0x0
  801844:	ff 75 f4             	pushl  -0xc(%ebp)
  801847:	e8 bb f9 ff ff       	call   801207 <fd_close>
		return r;
  80184c:	83 c4 10             	add    $0x10,%esp
  80184f:	eb 24                	jmp    801875 <open+0x92>
	}


	cprintf("OPEN\n");
  801851:	83 ec 0c             	sub    $0xc,%esp
  801854:	68 f5 27 80 00       	push   $0x8027f5
  801859:	e8 02 ea ff ff       	call   800260 <cprintf>

	return fd2num(fd);
  80185e:	83 c4 04             	add    $0x4,%esp
  801861:	ff 75 f4             	pushl  -0xc(%ebp)
  801864:	e8 47 f8 ff ff       	call   8010b0 <fd2num>
  801869:	89 c3                	mov    %eax,%ebx
  80186b:	83 c4 10             	add    $0x10,%esp
  80186e:	eb 05                	jmp    801875 <open+0x92>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801870:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx


	cprintf("OPEN\n");

	return fd2num(fd);
}
  801875:	89 d8                	mov    %ebx,%eax
  801877:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80187a:	5b                   	pop    %ebx
  80187b:	5e                   	pop    %esi
  80187c:	c9                   	leave  
  80187d:	c3                   	ret    
	...

00801880 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801880:	55                   	push   %ebp
  801881:	89 e5                	mov    %esp,%ebp
  801883:	56                   	push   %esi
  801884:	53                   	push   %ebx
  801885:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801888:	83 ec 0c             	sub    $0xc,%esp
  80188b:	ff 75 08             	pushl  0x8(%ebp)
  80188e:	e8 2d f8 ff ff       	call   8010c0 <fd2data>
  801893:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  801895:	83 c4 08             	add    $0x8,%esp
  801898:	68 fb 27 80 00       	push   $0x8027fb
  80189d:	56                   	push   %esi
  80189e:	e8 73 ef ff ff       	call   800816 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8018a3:	8b 43 04             	mov    0x4(%ebx),%eax
  8018a6:	2b 03                	sub    (%ebx),%eax
  8018a8:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  8018ae:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  8018b5:	00 00 00 
	stat->st_dev = &devpipe;
  8018b8:	c7 86 88 00 00 00 20 	movl   $0x803020,0x88(%esi)
  8018bf:	30 80 00 
	return 0;
}
  8018c2:	b8 00 00 00 00       	mov    $0x0,%eax
  8018c7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018ca:	5b                   	pop    %ebx
  8018cb:	5e                   	pop    %esi
  8018cc:	c9                   	leave  
  8018cd:	c3                   	ret    

008018ce <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8018ce:	55                   	push   %ebp
  8018cf:	89 e5                	mov    %esp,%ebp
  8018d1:	53                   	push   %ebx
  8018d2:	83 ec 0c             	sub    $0xc,%esp
  8018d5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8018d8:	53                   	push   %ebx
  8018d9:	6a 00                	push   $0x0
  8018db:	e8 02 f4 ff ff       	call   800ce2 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8018e0:	89 1c 24             	mov    %ebx,(%esp)
  8018e3:	e8 d8 f7 ff ff       	call   8010c0 <fd2data>
  8018e8:	83 c4 08             	add    $0x8,%esp
  8018eb:	50                   	push   %eax
  8018ec:	6a 00                	push   $0x0
  8018ee:	e8 ef f3 ff ff       	call   800ce2 <sys_page_unmap>
}
  8018f3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018f6:	c9                   	leave  
  8018f7:	c3                   	ret    

008018f8 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8018f8:	55                   	push   %ebp
  8018f9:	89 e5                	mov    %esp,%ebp
  8018fb:	57                   	push   %edi
  8018fc:	56                   	push   %esi
  8018fd:	53                   	push   %ebx
  8018fe:	83 ec 1c             	sub    $0x1c,%esp
  801901:	89 c7                	mov    %eax,%edi
  801903:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801906:	a1 08 40 80 00       	mov    0x804008,%eax
  80190b:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  80190e:	83 ec 0c             	sub    $0xc,%esp
  801911:	57                   	push   %edi
  801912:	e8 59 06 00 00       	call   801f70 <pageref>
  801917:	89 c6                	mov    %eax,%esi
  801919:	83 c4 04             	add    $0x4,%esp
  80191c:	ff 75 e4             	pushl  -0x1c(%ebp)
  80191f:	e8 4c 06 00 00       	call   801f70 <pageref>
  801924:	83 c4 10             	add    $0x10,%esp
  801927:	39 c6                	cmp    %eax,%esi
  801929:	0f 94 c0             	sete   %al
  80192c:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  80192f:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801935:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801938:	39 cb                	cmp    %ecx,%ebx
  80193a:	75 08                	jne    801944 <_pipeisclosed+0x4c>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  80193c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80193f:	5b                   	pop    %ebx
  801940:	5e                   	pop    %esi
  801941:	5f                   	pop    %edi
  801942:	c9                   	leave  
  801943:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  801944:	83 f8 01             	cmp    $0x1,%eax
  801947:	75 bd                	jne    801906 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801949:	8b 42 58             	mov    0x58(%edx),%eax
  80194c:	6a 01                	push   $0x1
  80194e:	50                   	push   %eax
  80194f:	53                   	push   %ebx
  801950:	68 02 28 80 00       	push   $0x802802
  801955:	e8 06 e9 ff ff       	call   800260 <cprintf>
  80195a:	83 c4 10             	add    $0x10,%esp
  80195d:	eb a7                	jmp    801906 <_pipeisclosed+0xe>

0080195f <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80195f:	55                   	push   %ebp
  801960:	89 e5                	mov    %esp,%ebp
  801962:	57                   	push   %edi
  801963:	56                   	push   %esi
  801964:	53                   	push   %ebx
  801965:	83 ec 28             	sub    $0x28,%esp
  801968:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  80196b:	56                   	push   %esi
  80196c:	e8 4f f7 ff ff       	call   8010c0 <fd2data>
  801971:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801973:	83 c4 10             	add    $0x10,%esp
  801976:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80197a:	75 4a                	jne    8019c6 <devpipe_write+0x67>
  80197c:	bf 00 00 00 00       	mov    $0x0,%edi
  801981:	eb 56                	jmp    8019d9 <devpipe_write+0x7a>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801983:	89 da                	mov    %ebx,%edx
  801985:	89 f0                	mov    %esi,%eax
  801987:	e8 6c ff ff ff       	call   8018f8 <_pipeisclosed>
  80198c:	85 c0                	test   %eax,%eax
  80198e:	75 4d                	jne    8019dd <devpipe_write+0x7e>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801990:	e8 dc f2 ff ff       	call   800c71 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801995:	8b 43 04             	mov    0x4(%ebx),%eax
  801998:	8b 13                	mov    (%ebx),%edx
  80199a:	83 c2 20             	add    $0x20,%edx
  80199d:	39 d0                	cmp    %edx,%eax
  80199f:	73 e2                	jae    801983 <devpipe_write+0x24>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  8019a1:	89 c2                	mov    %eax,%edx
  8019a3:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  8019a9:	79 05                	jns    8019b0 <devpipe_write+0x51>
  8019ab:	4a                   	dec    %edx
  8019ac:	83 ca e0             	or     $0xffffffe0,%edx
  8019af:	42                   	inc    %edx
  8019b0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8019b3:	8a 0c 39             	mov    (%ecx,%edi,1),%cl
  8019b6:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  8019ba:	40                   	inc    %eax
  8019bb:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8019be:	47                   	inc    %edi
  8019bf:	39 7d 10             	cmp    %edi,0x10(%ebp)
  8019c2:	77 07                	ja     8019cb <devpipe_write+0x6c>
  8019c4:	eb 13                	jmp    8019d9 <devpipe_write+0x7a>
  8019c6:	bf 00 00 00 00       	mov    $0x0,%edi
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8019cb:	8b 43 04             	mov    0x4(%ebx),%eax
  8019ce:	8b 13                	mov    (%ebx),%edx
  8019d0:	83 c2 20             	add    $0x20,%edx
  8019d3:	39 d0                	cmp    %edx,%eax
  8019d5:	73 ac                	jae    801983 <devpipe_write+0x24>
  8019d7:	eb c8                	jmp    8019a1 <devpipe_write+0x42>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  8019d9:	89 f8                	mov    %edi,%eax
  8019db:	eb 05                	jmp    8019e2 <devpipe_write+0x83>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8019dd:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  8019e2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8019e5:	5b                   	pop    %ebx
  8019e6:	5e                   	pop    %esi
  8019e7:	5f                   	pop    %edi
  8019e8:	c9                   	leave  
  8019e9:	c3                   	ret    

008019ea <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  8019ea:	55                   	push   %ebp
  8019eb:	89 e5                	mov    %esp,%ebp
  8019ed:	57                   	push   %edi
  8019ee:	56                   	push   %esi
  8019ef:	53                   	push   %ebx
  8019f0:	83 ec 18             	sub    $0x18,%esp
  8019f3:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  8019f6:	57                   	push   %edi
  8019f7:	e8 c4 f6 ff ff       	call   8010c0 <fd2data>
  8019fc:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8019fe:	83 c4 10             	add    $0x10,%esp
  801a01:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801a05:	75 44                	jne    801a4b <devpipe_read+0x61>
  801a07:	be 00 00 00 00       	mov    $0x0,%esi
  801a0c:	eb 4f                	jmp    801a5d <devpipe_read+0x73>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
				return i;
  801a0e:	89 f0                	mov    %esi,%eax
  801a10:	eb 54                	jmp    801a66 <devpipe_read+0x7c>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801a12:	89 da                	mov    %ebx,%edx
  801a14:	89 f8                	mov    %edi,%eax
  801a16:	e8 dd fe ff ff       	call   8018f8 <_pipeisclosed>
  801a1b:	85 c0                	test   %eax,%eax
  801a1d:	75 42                	jne    801a61 <devpipe_read+0x77>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801a1f:	e8 4d f2 ff ff       	call   800c71 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801a24:	8b 03                	mov    (%ebx),%eax
  801a26:	3b 43 04             	cmp    0x4(%ebx),%eax
  801a29:	74 e7                	je     801a12 <devpipe_read+0x28>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801a2b:	25 1f 00 00 80       	and    $0x8000001f,%eax
  801a30:	79 05                	jns    801a37 <devpipe_read+0x4d>
  801a32:	48                   	dec    %eax
  801a33:	83 c8 e0             	or     $0xffffffe0,%eax
  801a36:	40                   	inc    %eax
  801a37:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  801a3b:	8b 55 0c             	mov    0xc(%ebp),%edx
  801a3e:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  801a41:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801a43:	46                   	inc    %esi
  801a44:	39 75 10             	cmp    %esi,0x10(%ebp)
  801a47:	77 07                	ja     801a50 <devpipe_read+0x66>
  801a49:	eb 12                	jmp    801a5d <devpipe_read+0x73>
  801a4b:	be 00 00 00 00       	mov    $0x0,%esi
		while (p->p_rpos == p->p_wpos) {
  801a50:	8b 03                	mov    (%ebx),%eax
  801a52:	3b 43 04             	cmp    0x4(%ebx),%eax
  801a55:	75 d4                	jne    801a2b <devpipe_read+0x41>
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801a57:	85 f6                	test   %esi,%esi
  801a59:	75 b3                	jne    801a0e <devpipe_read+0x24>
  801a5b:	eb b5                	jmp    801a12 <devpipe_read+0x28>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801a5d:	89 f0                	mov    %esi,%eax
  801a5f:	eb 05                	jmp    801a66 <devpipe_read+0x7c>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801a61:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801a66:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a69:	5b                   	pop    %ebx
  801a6a:	5e                   	pop    %esi
  801a6b:	5f                   	pop    %edi
  801a6c:	c9                   	leave  
  801a6d:	c3                   	ret    

00801a6e <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801a6e:	55                   	push   %ebp
  801a6f:	89 e5                	mov    %esp,%ebp
  801a71:	57                   	push   %edi
  801a72:	56                   	push   %esi
  801a73:	53                   	push   %ebx
  801a74:	83 ec 28             	sub    $0x28,%esp
  801a77:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801a7a:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801a7d:	50                   	push   %eax
  801a7e:	e8 55 f6 ff ff       	call   8010d8 <fd_alloc>
  801a83:	89 c3                	mov    %eax,%ebx
  801a85:	83 c4 10             	add    $0x10,%esp
  801a88:	85 c0                	test   %eax,%eax
  801a8a:	0f 88 24 01 00 00    	js     801bb4 <pipe+0x146>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801a90:	83 ec 04             	sub    $0x4,%esp
  801a93:	68 07 04 00 00       	push   $0x407
  801a98:	ff 75 e4             	pushl  -0x1c(%ebp)
  801a9b:	6a 00                	push   $0x0
  801a9d:	e8 f6 f1 ff ff       	call   800c98 <sys_page_alloc>
  801aa2:	89 c3                	mov    %eax,%ebx
  801aa4:	83 c4 10             	add    $0x10,%esp
  801aa7:	85 c0                	test   %eax,%eax
  801aa9:	0f 88 05 01 00 00    	js     801bb4 <pipe+0x146>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801aaf:	83 ec 0c             	sub    $0xc,%esp
  801ab2:	8d 45 e0             	lea    -0x20(%ebp),%eax
  801ab5:	50                   	push   %eax
  801ab6:	e8 1d f6 ff ff       	call   8010d8 <fd_alloc>
  801abb:	89 c3                	mov    %eax,%ebx
  801abd:	83 c4 10             	add    $0x10,%esp
  801ac0:	85 c0                	test   %eax,%eax
  801ac2:	0f 88 dc 00 00 00    	js     801ba4 <pipe+0x136>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ac8:	83 ec 04             	sub    $0x4,%esp
  801acb:	68 07 04 00 00       	push   $0x407
  801ad0:	ff 75 e0             	pushl  -0x20(%ebp)
  801ad3:	6a 00                	push   $0x0
  801ad5:	e8 be f1 ff ff       	call   800c98 <sys_page_alloc>
  801ada:	89 c3                	mov    %eax,%ebx
  801adc:	83 c4 10             	add    $0x10,%esp
  801adf:	85 c0                	test   %eax,%eax
  801ae1:	0f 88 bd 00 00 00    	js     801ba4 <pipe+0x136>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801ae7:	83 ec 0c             	sub    $0xc,%esp
  801aea:	ff 75 e4             	pushl  -0x1c(%ebp)
  801aed:	e8 ce f5 ff ff       	call   8010c0 <fd2data>
  801af2:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801af4:	83 c4 0c             	add    $0xc,%esp
  801af7:	68 07 04 00 00       	push   $0x407
  801afc:	50                   	push   %eax
  801afd:	6a 00                	push   $0x0
  801aff:	e8 94 f1 ff ff       	call   800c98 <sys_page_alloc>
  801b04:	89 c3                	mov    %eax,%ebx
  801b06:	83 c4 10             	add    $0x10,%esp
  801b09:	85 c0                	test   %eax,%eax
  801b0b:	0f 88 83 00 00 00    	js     801b94 <pipe+0x126>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b11:	83 ec 0c             	sub    $0xc,%esp
  801b14:	ff 75 e0             	pushl  -0x20(%ebp)
  801b17:	e8 a4 f5 ff ff       	call   8010c0 <fd2data>
  801b1c:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801b23:	50                   	push   %eax
  801b24:	6a 00                	push   $0x0
  801b26:	56                   	push   %esi
  801b27:	6a 00                	push   $0x0
  801b29:	e8 8e f1 ff ff       	call   800cbc <sys_page_map>
  801b2e:	89 c3                	mov    %eax,%ebx
  801b30:	83 c4 20             	add    $0x20,%esp
  801b33:	85 c0                	test   %eax,%eax
  801b35:	78 4f                	js     801b86 <pipe+0x118>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801b37:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801b3d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801b40:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801b42:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801b45:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801b4c:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801b52:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801b55:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801b57:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801b5a:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801b61:	83 ec 0c             	sub    $0xc,%esp
  801b64:	ff 75 e4             	pushl  -0x1c(%ebp)
  801b67:	e8 44 f5 ff ff       	call   8010b0 <fd2num>
  801b6c:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  801b6e:	83 c4 04             	add    $0x4,%esp
  801b71:	ff 75 e0             	pushl  -0x20(%ebp)
  801b74:	e8 37 f5 ff ff       	call   8010b0 <fd2num>
  801b79:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  801b7c:	83 c4 10             	add    $0x10,%esp
  801b7f:	bb 00 00 00 00       	mov    $0x0,%ebx
  801b84:	eb 2e                	jmp    801bb4 <pipe+0x146>

    err3:
	sys_page_unmap(0, va);
  801b86:	83 ec 08             	sub    $0x8,%esp
  801b89:	56                   	push   %esi
  801b8a:	6a 00                	push   $0x0
  801b8c:	e8 51 f1 ff ff       	call   800ce2 <sys_page_unmap>
  801b91:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801b94:	83 ec 08             	sub    $0x8,%esp
  801b97:	ff 75 e0             	pushl  -0x20(%ebp)
  801b9a:	6a 00                	push   $0x0
  801b9c:	e8 41 f1 ff ff       	call   800ce2 <sys_page_unmap>
  801ba1:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801ba4:	83 ec 08             	sub    $0x8,%esp
  801ba7:	ff 75 e4             	pushl  -0x1c(%ebp)
  801baa:	6a 00                	push   $0x0
  801bac:	e8 31 f1 ff ff       	call   800ce2 <sys_page_unmap>
  801bb1:	83 c4 10             	add    $0x10,%esp
    err:
	return r;
}
  801bb4:	89 d8                	mov    %ebx,%eax
  801bb6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801bb9:	5b                   	pop    %ebx
  801bba:	5e                   	pop    %esi
  801bbb:	5f                   	pop    %edi
  801bbc:	c9                   	leave  
  801bbd:	c3                   	ret    

00801bbe <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801bbe:	55                   	push   %ebp
  801bbf:	89 e5                	mov    %esp,%ebp
  801bc1:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801bc4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801bc7:	50                   	push   %eax
  801bc8:	ff 75 08             	pushl  0x8(%ebp)
  801bcb:	e8 7b f5 ff ff       	call   80114b <fd_lookup>
  801bd0:	83 c4 10             	add    $0x10,%esp
  801bd3:	85 c0                	test   %eax,%eax
  801bd5:	78 18                	js     801bef <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801bd7:	83 ec 0c             	sub    $0xc,%esp
  801bda:	ff 75 f4             	pushl  -0xc(%ebp)
  801bdd:	e8 de f4 ff ff       	call   8010c0 <fd2data>
	return _pipeisclosed(fd, p);
  801be2:	89 c2                	mov    %eax,%edx
  801be4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801be7:	e8 0c fd ff ff       	call   8018f8 <_pipeisclosed>
  801bec:	83 c4 10             	add    $0x10,%esp
}
  801bef:	c9                   	leave  
  801bf0:	c3                   	ret    
  801bf1:	00 00                	add    %al,(%eax)
	...

00801bf4 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801bf4:	55                   	push   %ebp
  801bf5:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801bf7:	b8 00 00 00 00       	mov    $0x0,%eax
  801bfc:	c9                   	leave  
  801bfd:	c3                   	ret    

00801bfe <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801bfe:	55                   	push   %ebp
  801bff:	89 e5                	mov    %esp,%ebp
  801c01:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801c04:	68 1a 28 80 00       	push   $0x80281a
  801c09:	ff 75 0c             	pushl  0xc(%ebp)
  801c0c:	e8 05 ec ff ff       	call   800816 <strcpy>
	return 0;
}
  801c11:	b8 00 00 00 00       	mov    $0x0,%eax
  801c16:	c9                   	leave  
  801c17:	c3                   	ret    

00801c18 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801c18:	55                   	push   %ebp
  801c19:	89 e5                	mov    %esp,%ebp
  801c1b:	57                   	push   %edi
  801c1c:	56                   	push   %esi
  801c1d:	53                   	push   %ebx
  801c1e:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801c24:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801c28:	74 45                	je     801c6f <devcons_write+0x57>
  801c2a:	b8 00 00 00 00       	mov    $0x0,%eax
  801c2f:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801c34:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801c3a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801c3d:	29 c3                	sub    %eax,%ebx
		if (m > sizeof(buf) - 1)
  801c3f:	83 fb 7f             	cmp    $0x7f,%ebx
  801c42:	76 05                	jbe    801c49 <devcons_write+0x31>
			m = sizeof(buf) - 1;
  801c44:	bb 7f 00 00 00       	mov    $0x7f,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  801c49:	83 ec 04             	sub    $0x4,%esp
  801c4c:	53                   	push   %ebx
  801c4d:	03 45 0c             	add    0xc(%ebp),%eax
  801c50:	50                   	push   %eax
  801c51:	57                   	push   %edi
  801c52:	e8 80 ed ff ff       	call   8009d7 <memmove>
		sys_cputs(buf, m);
  801c57:	83 c4 08             	add    $0x8,%esp
  801c5a:	53                   	push   %ebx
  801c5b:	57                   	push   %edi
  801c5c:	e8 80 ef ff ff       	call   800be1 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801c61:	01 de                	add    %ebx,%esi
  801c63:	89 f0                	mov    %esi,%eax
  801c65:	83 c4 10             	add    $0x10,%esp
  801c68:	3b 75 10             	cmp    0x10(%ebp),%esi
  801c6b:	72 cd                	jb     801c3a <devcons_write+0x22>
  801c6d:	eb 05                	jmp    801c74 <devcons_write+0x5c>
  801c6f:	be 00 00 00 00       	mov    $0x0,%esi
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801c74:	89 f0                	mov    %esi,%eax
  801c76:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c79:	5b                   	pop    %ebx
  801c7a:	5e                   	pop    %esi
  801c7b:	5f                   	pop    %edi
  801c7c:	c9                   	leave  
  801c7d:	c3                   	ret    

00801c7e <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801c7e:	55                   	push   %ebp
  801c7f:	89 e5                	mov    %esp,%ebp
  801c81:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  801c84:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801c88:	75 07                	jne    801c91 <devcons_read+0x13>
  801c8a:	eb 25                	jmp    801cb1 <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801c8c:	e8 e0 ef ff ff       	call   800c71 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801c91:	e8 71 ef ff ff       	call   800c07 <sys_cgetc>
  801c96:	85 c0                	test   %eax,%eax
  801c98:	74 f2                	je     801c8c <devcons_read+0xe>
  801c9a:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  801c9c:	85 c0                	test   %eax,%eax
  801c9e:	78 1d                	js     801cbd <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801ca0:	83 f8 04             	cmp    $0x4,%eax
  801ca3:	74 13                	je     801cb8 <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  801ca5:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ca8:	88 10                	mov    %dl,(%eax)
	return 1;
  801caa:	b8 01 00 00 00       	mov    $0x1,%eax
  801caf:	eb 0c                	jmp    801cbd <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  801cb1:	b8 00 00 00 00       	mov    $0x0,%eax
  801cb6:	eb 05                	jmp    801cbd <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801cb8:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801cbd:	c9                   	leave  
  801cbe:	c3                   	ret    

00801cbf <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801cbf:	55                   	push   %ebp
  801cc0:	89 e5                	mov    %esp,%ebp
  801cc2:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801cc5:	8b 45 08             	mov    0x8(%ebp),%eax
  801cc8:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801ccb:	6a 01                	push   $0x1
  801ccd:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801cd0:	50                   	push   %eax
  801cd1:	e8 0b ef ff ff       	call   800be1 <sys_cputs>
  801cd6:	83 c4 10             	add    $0x10,%esp
}
  801cd9:	c9                   	leave  
  801cda:	c3                   	ret    

00801cdb <getchar>:

int
getchar(void)
{
  801cdb:	55                   	push   %ebp
  801cdc:	89 e5                	mov    %esp,%ebp
  801cde:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801ce1:	6a 01                	push   $0x1
  801ce3:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801ce6:	50                   	push   %eax
  801ce7:	6a 00                	push   $0x0
  801ce9:	e8 de f6 ff ff       	call   8013cc <read>
	if (r < 0)
  801cee:	83 c4 10             	add    $0x10,%esp
  801cf1:	85 c0                	test   %eax,%eax
  801cf3:	78 0f                	js     801d04 <getchar+0x29>
		return r;
	if (r < 1)
  801cf5:	85 c0                	test   %eax,%eax
  801cf7:	7e 06                	jle    801cff <getchar+0x24>
		return -E_EOF;
	return c;
  801cf9:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801cfd:	eb 05                	jmp    801d04 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801cff:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801d04:	c9                   	leave  
  801d05:	c3                   	ret    

00801d06 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801d06:	55                   	push   %ebp
  801d07:	89 e5                	mov    %esp,%ebp
  801d09:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801d0c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d0f:	50                   	push   %eax
  801d10:	ff 75 08             	pushl  0x8(%ebp)
  801d13:	e8 33 f4 ff ff       	call   80114b <fd_lookup>
  801d18:	83 c4 10             	add    $0x10,%esp
  801d1b:	85 c0                	test   %eax,%eax
  801d1d:	78 11                	js     801d30 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801d1f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d22:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801d28:	39 10                	cmp    %edx,(%eax)
  801d2a:	0f 94 c0             	sete   %al
  801d2d:	0f b6 c0             	movzbl %al,%eax
}
  801d30:	c9                   	leave  
  801d31:	c3                   	ret    

00801d32 <opencons>:

int
opencons(void)
{
  801d32:	55                   	push   %ebp
  801d33:	89 e5                	mov    %esp,%ebp
  801d35:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801d38:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d3b:	50                   	push   %eax
  801d3c:	e8 97 f3 ff ff       	call   8010d8 <fd_alloc>
  801d41:	83 c4 10             	add    $0x10,%esp
  801d44:	85 c0                	test   %eax,%eax
  801d46:	78 3a                	js     801d82 <opencons+0x50>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801d48:	83 ec 04             	sub    $0x4,%esp
  801d4b:	68 07 04 00 00       	push   $0x407
  801d50:	ff 75 f4             	pushl  -0xc(%ebp)
  801d53:	6a 00                	push   $0x0
  801d55:	e8 3e ef ff ff       	call   800c98 <sys_page_alloc>
  801d5a:	83 c4 10             	add    $0x10,%esp
  801d5d:	85 c0                	test   %eax,%eax
  801d5f:	78 21                	js     801d82 <opencons+0x50>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801d61:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801d67:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d6a:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801d6c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d6f:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801d76:	83 ec 0c             	sub    $0xc,%esp
  801d79:	50                   	push   %eax
  801d7a:	e8 31 f3 ff ff       	call   8010b0 <fd2num>
  801d7f:	83 c4 10             	add    $0x10,%esp
}
  801d82:	c9                   	leave  
  801d83:	c3                   	ret    

00801d84 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801d84:	55                   	push   %ebp
  801d85:	89 e5                	mov    %esp,%ebp
  801d87:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  801d8a:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801d91:	75 52                	jne    801de5 <set_pgfault_handler+0x61>
		// First time through!	
		// LAB 4: Your code here.

		//int sys_page_alloc(envid_t envid, void *va, int perm)
		r = sys_page_alloc(0, (void*)(UXSTACKTOP - PGSIZE), PTE_U | PTE_W | PTE_P);
  801d93:	83 ec 04             	sub    $0x4,%esp
  801d96:	6a 07                	push   $0x7
  801d98:	68 00 f0 bf ee       	push   $0xeebff000
  801d9d:	6a 00                	push   $0x0
  801d9f:	e8 f4 ee ff ff       	call   800c98 <sys_page_alloc>
		if (r < 0) {
  801da4:	83 c4 10             	add    $0x10,%esp
  801da7:	85 c0                	test   %eax,%eax
  801da9:	79 12                	jns    801dbd <set_pgfault_handler+0x39>
			panic("sys_page_alloc error : %e\n", r);
  801dab:	50                   	push   %eax
  801dac:	68 26 28 80 00       	push   $0x802826
  801db1:	6a 24                	push   $0x24
  801db3:	68 41 28 80 00       	push   $0x802841
  801db8:	e8 cb e3 ff ff       	call   800188 <_panic>
		}

		// how to know envid, put 0, envid2env will help us to get curenv in syscall
		r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);		
  801dbd:	83 ec 08             	sub    $0x8,%esp
  801dc0:	68 f0 1d 80 00       	push   $0x801df0
  801dc5:	6a 00                	push   $0x0
  801dc7:	e8 7f ef ff ff       	call   800d4b <sys_env_set_pgfault_upcall>
		if (r < 0) {
  801dcc:	83 c4 10             	add    $0x10,%esp
  801dcf:	85 c0                	test   %eax,%eax
  801dd1:	79 12                	jns    801de5 <set_pgfault_handler+0x61>
			panic("sys_env_set_pgfault_upcall error : %e\n", r);
  801dd3:	50                   	push   %eax
  801dd4:	68 50 28 80 00       	push   $0x802850
  801dd9:	6a 2a                	push   $0x2a
  801ddb:	68 41 28 80 00       	push   $0x802841
  801de0:	e8 a3 e3 ff ff       	call   800188 <_panic>
		}
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801de5:	8b 45 08             	mov    0x8(%ebp),%eax
  801de8:	a3 00 60 80 00       	mov    %eax,0x806000
}
  801ded:	c9                   	leave  
  801dee:	c3                   	ret    
	...

00801df0 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801df0:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801df1:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  801df6:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801df8:	83 c4 04             	add    $0x4,%esp
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	
	// fix old esp
	movl 0x30(%esp), %eax
  801dfb:	8b 44 24 30          	mov    0x30(%esp),%eax
	subl $0x4, %eax
  801dff:	83 e8 04             	sub    $0x4,%eax
	movl %eax, 0x30(%esp)
  801e02:	89 44 24 30          	mov    %eax,0x30(%esp)

	// set trap-time %eip
	movl 0x28(%esp), %ebx
  801e06:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	movl %ebx, (%eax)
  801e0a:	89 18                	mov    %ebx,(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $0x08, %esp 	// ignore err_code and fault_va
  801e0c:	83 c4 08             	add    $0x8,%esp
	popal 				// restore registers
  801e0f:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x04, %esp 	// ignore eip 
  801e10:	83 c4 04             	add    $0x4,%esp
	popfl				// modify eflags
  801e13:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  801e14:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  801e15:	c3                   	ret    
	...

00801e18 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801e18:	55                   	push   %ebp
  801e19:	89 e5                	mov    %esp,%ebp
  801e1b:	57                   	push   %edi
  801e1c:	56                   	push   %esi
  801e1d:	53                   	push   %ebx
  801e1e:	83 ec 0c             	sub    $0xc,%esp
  801e21:	8b 7d 08             	mov    0x8(%ebp),%edi
  801e24:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801e27:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	cprintf("0x%x 0x%x 0x%x\n", (uint32_t)from_env_store, (uint32_t)pg, (uint32_t)perm_store);
  801e2a:	56                   	push   %esi
  801e2b:	53                   	push   %ebx
  801e2c:	57                   	push   %edi
  801e2d:	68 78 28 80 00       	push   $0x802878
  801e32:	e8 29 e4 ff ff       	call   800260 <cprintf>
	int r;
	if (pg != NULL) {
  801e37:	83 c4 10             	add    $0x10,%esp
  801e3a:	85 db                	test   %ebx,%ebx
  801e3c:	74 28                	je     801e66 <ipc_recv+0x4e>
		cprintf("BEGIN\n");
  801e3e:	83 ec 0c             	sub    $0xc,%esp
  801e41:	68 88 28 80 00       	push   $0x802888
  801e46:	e8 15 e4 ff ff       	call   800260 <cprintf>
		r = sys_ipc_recv(pg);
  801e4b:	89 1c 24             	mov    %ebx,(%esp)
  801e4e:	e8 40 ef ff ff       	call   800d93 <sys_ipc_recv>
  801e53:	89 c3                	mov    %eax,%ebx
		cprintf("OVER\n");
  801e55:	c7 04 24 bc 27 80 00 	movl   $0x8027bc,(%esp)
  801e5c:	e8 ff e3 ff ff       	call   800260 <cprintf>
  801e61:	83 c4 10             	add    $0x10,%esp
  801e64:	eb 12                	jmp    801e78 <ipc_recv+0x60>
	} else {
		r = sys_ipc_recv((void *)UTOP);
  801e66:	83 ec 0c             	sub    $0xc,%esp
  801e69:	68 00 00 c0 ee       	push   $0xeec00000
  801e6e:	e8 20 ef ff ff       	call   800d93 <sys_ipc_recv>
  801e73:	89 c3                	mov    %eax,%ebx
  801e75:	83 c4 10             	add    $0x10,%esp
	}

	if (r == 0) {
  801e78:	85 db                	test   %ebx,%ebx
  801e7a:	75 26                	jne    801ea2 <ipc_recv+0x8a>
		if (from_env_store != NULL) *from_env_store = thisenv->env_ipc_from;
  801e7c:	85 ff                	test   %edi,%edi
  801e7e:	74 0a                	je     801e8a <ipc_recv+0x72>
  801e80:	a1 08 40 80 00       	mov    0x804008,%eax
  801e85:	8b 40 74             	mov    0x74(%eax),%eax
  801e88:	89 07                	mov    %eax,(%edi)
		if (perm_store != NULL) *perm_store = thisenv->env_ipc_perm;
  801e8a:	85 f6                	test   %esi,%esi
  801e8c:	74 0a                	je     801e98 <ipc_recv+0x80>
  801e8e:	a1 08 40 80 00       	mov    0x804008,%eax
  801e93:	8b 40 78             	mov    0x78(%eax),%eax
  801e96:	89 06                	mov    %eax,(%esi)
		return thisenv->env_ipc_value;
  801e98:	a1 08 40 80 00       	mov    0x804008,%eax
  801e9d:	8b 58 70             	mov    0x70(%eax),%ebx
  801ea0:	eb 14                	jmp    801eb6 <ipc_recv+0x9e>
	} else {
		// fails;
		if (from_env_store != NULL) *from_env_store = 0;
  801ea2:	85 ff                	test   %edi,%edi
  801ea4:	74 06                	je     801eac <ipc_recv+0x94>
  801ea6:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
		if (perm_store != NULL) *perm_store = 0;
  801eac:	85 f6                	test   %esi,%esi
  801eae:	74 06                	je     801eb6 <ipc_recv+0x9e>
  801eb0:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		return r;
	}
}
  801eb6:	89 d8                	mov    %ebx,%eax
  801eb8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ebb:	5b                   	pop    %ebx
  801ebc:	5e                   	pop    %esi
  801ebd:	5f                   	pop    %edi
  801ebe:	c9                   	leave  
  801ebf:	c3                   	ret    

00801ec0 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801ec0:	55                   	push   %ebp
  801ec1:	89 e5                	mov    %esp,%ebp
  801ec3:	57                   	push   %edi
  801ec4:	56                   	push   %esi
  801ec5:	53                   	push   %ebx
  801ec6:	83 ec 0c             	sub    $0xc,%esp
  801ec9:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801ecc:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801ecf:	8b 75 14             	mov    0x14(%ebp),%esi
	// LAB 4: Your code here.
	// int sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
	int r;
	if (pg == NULL) pg = (void *)UTOP;
  801ed2:	85 db                	test   %ebx,%ebx
  801ed4:	75 25                	jne    801efb <ipc_send+0x3b>
  801ed6:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
  801edb:	eb 1e                	jmp    801efb <ipc_send+0x3b>
	
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) != 0) {
		if (r == -E_IPC_NOT_RECV) {
  801edd:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801ee0:	75 07                	jne    801ee9 <ipc_send+0x29>
			// cprintf("Try Again and Again....\n");
			sys_yield();
  801ee2:	e8 8a ed ff ff       	call   800c71 <sys_yield>
  801ee7:	eb 12                	jmp    801efb <ipc_send+0x3b>
		} else {
			panic("ipc_send error %e\n", r);
  801ee9:	50                   	push   %eax
  801eea:	68 8f 28 80 00       	push   $0x80288f
  801eef:	6a 45                	push   $0x45
  801ef1:	68 a2 28 80 00       	push   $0x8028a2
  801ef6:	e8 8d e2 ff ff       	call   800188 <_panic>
	// LAB 4: Your code here.
	// int sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
	int r;
	if (pg == NULL) pg = (void *)UTOP;
	
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) != 0) {
  801efb:	56                   	push   %esi
  801efc:	53                   	push   %ebx
  801efd:	57                   	push   %edi
  801efe:	ff 75 08             	pushl  0x8(%ebp)
  801f01:	e8 68 ee ff ff       	call   800d6e <sys_ipc_try_send>
  801f06:	83 c4 10             	add    $0x10,%esp
  801f09:	85 c0                	test   %eax,%eax
  801f0b:	75 d0                	jne    801edd <ipc_send+0x1d>
		} else {
			panic("ipc_send error %e\n", r);
		}
	}
	return;
}
  801f0d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f10:	5b                   	pop    %ebx
  801f11:	5e                   	pop    %esi
  801f12:	5f                   	pop    %edi
  801f13:	c9                   	leave  
  801f14:	c3                   	ret    

00801f15 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801f15:	55                   	push   %ebp
  801f16:	89 e5                	mov    %esp,%ebp
  801f18:	53                   	push   %ebx
  801f19:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  801f1c:	39 1d 50 00 c0 ee    	cmp    %ebx,0xeec00050
  801f22:	74 22                	je     801f46 <ipc_find_env+0x31>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801f24:	b8 01 00 00 00       	mov    $0x1,%eax
		if (envs[i].env_type == type)
  801f29:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  801f30:	89 c2                	mov    %eax,%edx
  801f32:	c1 e2 07             	shl    $0x7,%edx
  801f35:	29 ca                	sub    %ecx,%edx
  801f37:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801f3d:	8b 52 50             	mov    0x50(%edx),%edx
  801f40:	39 da                	cmp    %ebx,%edx
  801f42:	75 1d                	jne    801f61 <ipc_find_env+0x4c>
  801f44:	eb 05                	jmp    801f4b <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801f46:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
			return envs[i].env_id;
  801f4b:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  801f52:	c1 e0 07             	shl    $0x7,%eax
  801f55:	29 d0                	sub    %edx,%eax
  801f57:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  801f5c:	8b 40 40             	mov    0x40(%eax),%eax
  801f5f:	eb 0c                	jmp    801f6d <ipc_find_env+0x58>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801f61:	40                   	inc    %eax
  801f62:	3d 00 04 00 00       	cmp    $0x400,%eax
  801f67:	75 c0                	jne    801f29 <ipc_find_env+0x14>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801f69:	66 b8 00 00          	mov    $0x0,%ax
}
  801f6d:	5b                   	pop    %ebx
  801f6e:	c9                   	leave  
  801f6f:	c3                   	ret    

00801f70 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801f70:	55                   	push   %ebp
  801f71:	89 e5                	mov    %esp,%ebp
  801f73:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801f76:	89 c2                	mov    %eax,%edx
  801f78:	c1 ea 16             	shr    $0x16,%edx
  801f7b:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801f82:	f6 c2 01             	test   $0x1,%dl
  801f85:	74 1e                	je     801fa5 <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  801f87:	c1 e8 0c             	shr    $0xc,%eax
  801f8a:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801f91:	a8 01                	test   $0x1,%al
  801f93:	74 17                	je     801fac <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801f95:	c1 e8 0c             	shr    $0xc,%eax
  801f98:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  801f9f:	ef 
  801fa0:	0f b7 c0             	movzwl %ax,%eax
  801fa3:	eb 0c                	jmp    801fb1 <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  801fa5:	b8 00 00 00 00       	mov    $0x0,%eax
  801faa:	eb 05                	jmp    801fb1 <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  801fac:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  801fb1:	c9                   	leave  
  801fb2:	c3                   	ret    
	...

00801fb4 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  801fb4:	55                   	push   %ebp
  801fb5:	89 e5                	mov    %esp,%ebp
  801fb7:	57                   	push   %edi
  801fb8:	56                   	push   %esi
  801fb9:	83 ec 10             	sub    $0x10,%esp
  801fbc:	8b 7d 08             	mov    0x8(%ebp),%edi
  801fbf:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  801fc2:	89 7d f0             	mov    %edi,-0x10(%ebp)
  801fc5:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  801fc8:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  801fcb:	8b 45 14             	mov    0x14(%ebp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  801fce:	85 c0                	test   %eax,%eax
  801fd0:	75 2e                	jne    802000 <__udivdi3+0x4c>
    {
      if (d0 > n1)
  801fd2:	39 f1                	cmp    %esi,%ecx
  801fd4:	77 5a                	ja     802030 <__udivdi3+0x7c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  801fd6:	85 c9                	test   %ecx,%ecx
  801fd8:	75 0b                	jne    801fe5 <__udivdi3+0x31>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  801fda:	b8 01 00 00 00       	mov    $0x1,%eax
  801fdf:	31 d2                	xor    %edx,%edx
  801fe1:	f7 f1                	div    %ecx
  801fe3:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  801fe5:	31 d2                	xor    %edx,%edx
  801fe7:	89 f0                	mov    %esi,%eax
  801fe9:	f7 f1                	div    %ecx
  801feb:	89 c6                	mov    %eax,%esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801fed:	89 f8                	mov    %edi,%eax
  801fef:	f7 f1                	div    %ecx
  801ff1:	89 c7                	mov    %eax,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801ff3:	89 f8                	mov    %edi,%eax
  801ff5:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801ff7:	83 c4 10             	add    $0x10,%esp
  801ffa:	5e                   	pop    %esi
  801ffb:	5f                   	pop    %edi
  801ffc:	c9                   	leave  
  801ffd:	c3                   	ret    
  801ffe:	66 90                	xchg   %ax,%ax
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  802000:	39 f0                	cmp    %esi,%eax
  802002:	77 1c                	ja     802020 <__udivdi3+0x6c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  802004:	0f bd f8             	bsr    %eax,%edi
	  if (bm == 0)
  802007:	83 f7 1f             	xor    $0x1f,%edi
  80200a:	75 3c                	jne    802048 <__udivdi3+0x94>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  80200c:	39 f0                	cmp    %esi,%eax
  80200e:	0f 82 90 00 00 00    	jb     8020a4 <__udivdi3+0xf0>
  802014:	8b 55 f0             	mov    -0x10(%ebp),%edx
  802017:	39 55 f4             	cmp    %edx,-0xc(%ebp)
  80201a:	0f 86 84 00 00 00    	jbe    8020a4 <__udivdi3+0xf0>
  802020:	31 f6                	xor    %esi,%esi
  802022:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  802024:	89 f8                	mov    %edi,%eax
  802026:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802028:	83 c4 10             	add    $0x10,%esp
  80202b:	5e                   	pop    %esi
  80202c:	5f                   	pop    %edi
  80202d:	c9                   	leave  
  80202e:	c3                   	ret    
  80202f:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802030:	89 f2                	mov    %esi,%edx
  802032:	89 f8                	mov    %edi,%eax
  802034:	f7 f1                	div    %ecx
  802036:	89 c7                	mov    %eax,%edi
  802038:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  80203a:	89 f8                	mov    %edi,%eax
  80203c:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  80203e:	83 c4 10             	add    $0x10,%esp
  802041:	5e                   	pop    %esi
  802042:	5f                   	pop    %edi
  802043:	c9                   	leave  
  802044:	c3                   	ret    
  802045:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  802048:	89 f9                	mov    %edi,%ecx
  80204a:	d3 e0                	shl    %cl,%eax
  80204c:	89 45 e8             	mov    %eax,-0x18(%ebp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  80204f:	b8 20 00 00 00       	mov    $0x20,%eax
  802054:	29 f8                	sub    %edi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  802056:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802059:	88 c1                	mov    %al,%cl
  80205b:	d3 ea                	shr    %cl,%edx
  80205d:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  802060:	09 ca                	or     %ecx,%edx
  802062:	89 55 ec             	mov    %edx,-0x14(%ebp)
	      d0 = d0 << bm;
  802065:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802068:	89 f9                	mov    %edi,%ecx
  80206a:	d3 e2                	shl    %cl,%edx
  80206c:	89 55 f4             	mov    %edx,-0xc(%ebp)
	      n2 = n1 >> b;
  80206f:	89 f2                	mov    %esi,%edx
  802071:	88 c1                	mov    %al,%cl
  802073:	d3 ea                	shr    %cl,%edx
  802075:	89 55 e8             	mov    %edx,-0x18(%ebp)
	      n1 = (n1 << bm) | (n0 >> b);
  802078:	89 f2                	mov    %esi,%edx
  80207a:	89 f9                	mov    %edi,%ecx
  80207c:	d3 e2                	shl    %cl,%edx
  80207e:	8b 75 f0             	mov    -0x10(%ebp),%esi
  802081:	88 c1                	mov    %al,%cl
  802083:	d3 ee                	shr    %cl,%esi
  802085:	09 d6                	or     %edx,%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  802087:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  80208a:	89 f0                	mov    %esi,%eax
  80208c:	89 ca                	mov    %ecx,%edx
  80208e:	f7 75 ec             	divl   -0x14(%ebp)
  802091:	89 d1                	mov    %edx,%ecx
  802093:	89 c6                	mov    %eax,%esi
	      umul_ppmm (m1, m0, q0, d0);
  802095:	f7 65 f4             	mull   -0xc(%ebp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802098:	39 d1                	cmp    %edx,%ecx
  80209a:	72 28                	jb     8020c4 <__udivdi3+0x110>
  80209c:	74 1a                	je     8020b8 <__udivdi3+0x104>
  80209e:	89 f7                	mov    %esi,%edi
  8020a0:	31 f6                	xor    %esi,%esi
  8020a2:	eb 80                	jmp    802024 <__udivdi3+0x70>
	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  8020a4:	31 f6                	xor    %esi,%esi
  8020a6:	bf 01 00 00 00       	mov    $0x1,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  8020ab:	89 f8                	mov    %edi,%eax
  8020ad:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  8020af:	83 c4 10             	add    $0x10,%esp
  8020b2:	5e                   	pop    %esi
  8020b3:	5f                   	pop    %edi
  8020b4:	c9                   	leave  
  8020b5:	c3                   	ret    
  8020b6:	66 90                	xchg   %ax,%ax

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  8020b8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8020bb:	89 f9                	mov    %edi,%ecx
  8020bd:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8020bf:	39 c2                	cmp    %eax,%edx
  8020c1:	73 db                	jae    80209e <__udivdi3+0xea>
  8020c3:	90                   	nop
		{
		  q0--;
  8020c4:	8d 7e ff             	lea    -0x1(%esi),%edi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  8020c7:	31 f6                	xor    %esi,%esi
  8020c9:	e9 56 ff ff ff       	jmp    802024 <__udivdi3+0x70>
	...

008020d0 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  8020d0:	55                   	push   %ebp
  8020d1:	89 e5                	mov    %esp,%ebp
  8020d3:	57                   	push   %edi
  8020d4:	56                   	push   %esi
  8020d5:	83 ec 20             	sub    $0x20,%esp
  8020d8:	8b 45 08             	mov    0x8(%ebp),%eax
  8020db:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  8020de:	89 45 e8             	mov    %eax,-0x18(%ebp)
  8020e1:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  8020e4:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  8020e7:	8b 7d 14             	mov    0x14(%ebp),%edi
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  8020ea:	89 45 f0             	mov    %eax,-0x10(%ebp)
  n1 = nn.s.high;
  8020ed:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  8020ef:	85 ff                	test   %edi,%edi
  8020f1:	75 15                	jne    802108 <__umoddi3+0x38>
    {
      if (d0 > n1)
  8020f3:	39 f1                	cmp    %esi,%ecx
  8020f5:	0f 86 99 00 00 00    	jbe    802194 <__umoddi3+0xc4>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8020fb:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  8020fd:	89 d0                	mov    %edx,%eax
  8020ff:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802101:	83 c4 20             	add    $0x20,%esp
  802104:	5e                   	pop    %esi
  802105:	5f                   	pop    %edi
  802106:	c9                   	leave  
  802107:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  802108:	39 f7                	cmp    %esi,%edi
  80210a:	0f 87 a4 00 00 00    	ja     8021b4 <__umoddi3+0xe4>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  802110:	0f bd c7             	bsr    %edi,%eax
	  if (bm == 0)
  802113:	83 f0 1f             	xor    $0x1f,%eax
  802116:	89 45 ec             	mov    %eax,-0x14(%ebp)
  802119:	0f 84 a1 00 00 00    	je     8021c0 <__umoddi3+0xf0>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  80211f:	89 f8                	mov    %edi,%eax
  802121:	8a 4d ec             	mov    -0x14(%ebp),%cl
  802124:	d3 e0                	shl    %cl,%eax
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  802126:	bf 20 00 00 00       	mov    $0x20,%edi
  80212b:	2b 7d ec             	sub    -0x14(%ebp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  80212e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802131:	89 f9                	mov    %edi,%ecx
  802133:	d3 ea                	shr    %cl,%edx
  802135:	09 c2                	or     %eax,%edx
  802137:	89 55 f0             	mov    %edx,-0x10(%ebp)
	      d0 = d0 << bm;
  80213a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80213d:	8a 4d ec             	mov    -0x14(%ebp),%cl
  802140:	d3 e0                	shl    %cl,%eax
  802142:	89 45 f4             	mov    %eax,-0xc(%ebp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  802145:	89 f2                	mov    %esi,%edx
  802147:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  802149:	8b 45 e8             	mov    -0x18(%ebp),%eax
  80214c:	d3 e0                	shl    %cl,%eax
  80214e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  802151:	8b 45 e8             	mov    -0x18(%ebp),%eax
  802154:	89 f9                	mov    %edi,%ecx
  802156:	d3 e8                	shr    %cl,%eax
  802158:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  80215a:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  80215c:	89 f2                	mov    %esi,%edx
  80215e:	f7 75 f0             	divl   -0x10(%ebp)
  802161:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  802163:	f7 65 f4             	mull   -0xc(%ebp)
  802166:	89 55 e8             	mov    %edx,-0x18(%ebp)
  802169:	89 c1                	mov    %eax,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  80216b:	39 d6                	cmp    %edx,%esi
  80216d:	72 71                	jb     8021e0 <__umoddi3+0x110>
  80216f:	74 7f                	je     8021f0 <__umoddi3+0x120>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  802171:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802174:	29 c8                	sub    %ecx,%eax
  802176:	19 d6                	sbb    %edx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  802178:	8a 4d ec             	mov    -0x14(%ebp),%cl
  80217b:	d3 e8                	shr    %cl,%eax
  80217d:	89 f2                	mov    %esi,%edx
  80217f:	89 f9                	mov    %edi,%ecx
  802181:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  802183:	09 d0                	or     %edx,%eax
  802185:	89 f2                	mov    %esi,%edx
  802187:	8a 4d ec             	mov    -0x14(%ebp),%cl
  80218a:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  80218c:	83 c4 20             	add    $0x20,%esp
  80218f:	5e                   	pop    %esi
  802190:	5f                   	pop    %edi
  802191:	c9                   	leave  
  802192:	c3                   	ret    
  802193:	90                   	nop
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  802194:	85 c9                	test   %ecx,%ecx
  802196:	75 0b                	jne    8021a3 <__umoddi3+0xd3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  802198:	b8 01 00 00 00       	mov    $0x1,%eax
  80219d:	31 d2                	xor    %edx,%edx
  80219f:	f7 f1                	div    %ecx
  8021a1:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  8021a3:	89 f0                	mov    %esi,%eax
  8021a5:	31 d2                	xor    %edx,%edx
  8021a7:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8021a9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8021ac:	f7 f1                	div    %ecx
  8021ae:	e9 4a ff ff ff       	jmp    8020fd <__umoddi3+0x2d>
  8021b3:	90                   	nop
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  8021b4:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8021b6:	83 c4 20             	add    $0x20,%esp
  8021b9:	5e                   	pop    %esi
  8021ba:	5f                   	pop    %edi
  8021bb:	c9                   	leave  
  8021bc:	c3                   	ret    
  8021bd:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  8021c0:	39 f7                	cmp    %esi,%edi
  8021c2:	72 05                	jb     8021c9 <__umoddi3+0xf9>
  8021c4:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
  8021c7:	77 0c                	ja     8021d5 <__umoddi3+0x105>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  8021c9:	89 f2                	mov    %esi,%edx
  8021cb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8021ce:	29 c8                	sub    %ecx,%eax
  8021d0:	19 fa                	sbb    %edi,%edx
  8021d2:	89 45 f0             	mov    %eax,-0x10(%ebp)

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  8021d5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8021d8:	83 c4 20             	add    $0x20,%esp
  8021db:	5e                   	pop    %esi
  8021dc:	5f                   	pop    %edi
  8021dd:	c9                   	leave  
  8021de:	c3                   	ret    
  8021df:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  8021e0:	8b 55 e8             	mov    -0x18(%ebp),%edx
  8021e3:	89 c1                	mov    %eax,%ecx
  8021e5:	2b 4d f4             	sub    -0xc(%ebp),%ecx
  8021e8:	1b 55 f0             	sbb    -0x10(%ebp),%edx
  8021eb:	eb 84                	jmp    802171 <__umoddi3+0xa1>
  8021ed:	8d 76 00             	lea    0x0(%esi),%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8021f0:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  8021f3:	72 eb                	jb     8021e0 <__umoddi3+0x110>
  8021f5:	89 f2                	mov    %esi,%edx
  8021f7:	e9 75 ff ff ff       	jmp    802171 <__umoddi3+0xa1>
