
obj/user/testpteshare.debug:     file format elf32-i386


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
  80002c:	e8 53 01 00 00       	call   800184 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <childofspawn>:
	breakpoint();
}

void
childofspawn(void)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	83 ec 10             	sub    $0x10,%esp
	strcpy(VA, msg2);
  80003a:	ff 35 04 40 80 00    	pushl  0x804004
  800040:	68 00 00 00 a0       	push   $0xa0000000
  800045:	e8 30 08 00 00       	call   80087a <strcpy>
	exit();
  80004a:	e8 81 01 00 00       	call   8001d0 <exit>
  80004f:	83 c4 10             	add    $0x10,%esp
}
  800052:	c9                   	leave  
  800053:	c3                   	ret    

00800054 <umain>:

void childofspawn(void);

void
umain(int argc, char **argv)
{
  800054:	55                   	push   %ebp
  800055:	89 e5                	mov    %esp,%ebp
  800057:	53                   	push   %ebx
  800058:	83 ec 04             	sub    $0x4,%esp
	int r;

	if (argc != 0)
  80005b:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  80005f:	74 05                	je     800066 <umain+0x12>
		childofspawn();
  800061:	e8 ce ff ff ff       	call   800034 <childofspawn>

	if ((r = sys_page_alloc(0, VA, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800066:	83 ec 04             	sub    $0x4,%esp
  800069:	68 07 04 00 00       	push   $0x407
  80006e:	68 00 00 00 a0       	push   $0xa0000000
  800073:	6a 00                	push   $0x0
  800075:	e8 82 0c 00 00       	call   800cfc <sys_page_alloc>
  80007a:	83 c4 10             	add    $0x10,%esp
  80007d:	85 c0                	test   %eax,%eax
  80007f:	79 12                	jns    800093 <umain+0x3f>
		panic("sys_page_alloc: %e", r);
  800081:	50                   	push   %eax
  800082:	68 ac 2b 80 00       	push   $0x802bac
  800087:	6a 13                	push   $0x13
  800089:	68 bf 2b 80 00       	push   $0x802bbf
  80008e:	e8 59 01 00 00       	call   8001ec <_panic>

	// check fork
	if ((r = fork()) < 0)
  800093:	e8 e2 0e 00 00       	call   800f7a <fork>
  800098:	89 c3                	mov    %eax,%ebx
  80009a:	85 c0                	test   %eax,%eax
  80009c:	79 12                	jns    8000b0 <umain+0x5c>
		panic("fork: %e", r);
  80009e:	50                   	push   %eax
  80009f:	68 d3 2b 80 00       	push   $0x802bd3
  8000a4:	6a 17                	push   $0x17
  8000a6:	68 bf 2b 80 00       	push   $0x802bbf
  8000ab:	e8 3c 01 00 00       	call   8001ec <_panic>
	if (r == 0) {
  8000b0:	85 c0                	test   %eax,%eax
  8000b2:	75 1b                	jne    8000cf <umain+0x7b>
		strcpy(VA, msg);
  8000b4:	83 ec 08             	sub    $0x8,%esp
  8000b7:	ff 35 00 40 80 00    	pushl  0x804000
  8000bd:	68 00 00 00 a0       	push   $0xa0000000
  8000c2:	e8 b3 07 00 00       	call   80087a <strcpy>
		exit();
  8000c7:	e8 04 01 00 00       	call   8001d0 <exit>
  8000cc:	83 c4 10             	add    $0x10,%esp
	}
	wait(r);
  8000cf:	83 ec 0c             	sub    $0xc,%esp
  8000d2:	53                   	push   %ebx
  8000d3:	e8 6c 24 00 00       	call   802544 <wait>
	cprintf("fork handles PTE_SHARE %s\n", strcmp(VA, msg) == 0 ? "right" : "wrong");
  8000d8:	83 c4 08             	add    $0x8,%esp
  8000db:	ff 35 00 40 80 00    	pushl  0x804000
  8000e1:	68 00 00 00 a0       	push   $0xa0000000
  8000e6:	e8 48 08 00 00       	call   800933 <strcmp>
  8000eb:	83 c4 10             	add    $0x10,%esp
  8000ee:	85 c0                	test   %eax,%eax
  8000f0:	75 07                	jne    8000f9 <umain+0xa5>
  8000f2:	b8 a0 2b 80 00       	mov    $0x802ba0,%eax
  8000f7:	eb 05                	jmp    8000fe <umain+0xaa>
  8000f9:	b8 a6 2b 80 00       	mov    $0x802ba6,%eax
  8000fe:	83 ec 08             	sub    $0x8,%esp
  800101:	50                   	push   %eax
  800102:	68 dc 2b 80 00       	push   $0x802bdc
  800107:	e8 b8 01 00 00       	call   8002c4 <cprintf>

	// check spawn
	if ((r = spawnl("/testpteshare", "testpteshare", "arg", 0)) < 0)
  80010c:	6a 00                	push   $0x0
  80010e:	68 f7 2b 80 00       	push   $0x802bf7
  800113:	68 fc 2b 80 00       	push   $0x802bfc
  800118:	68 fb 2b 80 00       	push   $0x802bfb
  80011d:	e8 24 20 00 00       	call   802146 <spawnl>
  800122:	83 c4 20             	add    $0x20,%esp
  800125:	85 c0                	test   %eax,%eax
  800127:	79 12                	jns    80013b <umain+0xe7>
		panic("spawn: %e", r);
  800129:	50                   	push   %eax
  80012a:	68 09 2c 80 00       	push   $0x802c09
  80012f:	6a 21                	push   $0x21
  800131:	68 bf 2b 80 00       	push   $0x802bbf
  800136:	e8 b1 00 00 00       	call   8001ec <_panic>
	wait(r);
  80013b:	83 ec 0c             	sub    $0xc,%esp
  80013e:	50                   	push   %eax
  80013f:	e8 00 24 00 00       	call   802544 <wait>
	cprintf("spawn handles PTE_SHARE %s\n", strcmp(VA, msg2) == 0 ? "right" : "wrong");
  800144:	83 c4 08             	add    $0x8,%esp
  800147:	ff 35 04 40 80 00    	pushl  0x804004
  80014d:	68 00 00 00 a0       	push   $0xa0000000
  800152:	e8 dc 07 00 00       	call   800933 <strcmp>
  800157:	83 c4 10             	add    $0x10,%esp
  80015a:	85 c0                	test   %eax,%eax
  80015c:	75 07                	jne    800165 <umain+0x111>
  80015e:	b8 a0 2b 80 00       	mov    $0x802ba0,%eax
  800163:	eb 05                	jmp    80016a <umain+0x116>
  800165:	b8 a6 2b 80 00       	mov    $0x802ba6,%eax
  80016a:	83 ec 08             	sub    $0x8,%esp
  80016d:	50                   	push   %eax
  80016e:	68 13 2c 80 00       	push   $0x802c13
  800173:	e8 4c 01 00 00       	call   8002c4 <cprintf>
	: "c" (msr), "a" (val1), "d" (val2))

static __inline void
breakpoint(void)
{
	__asm __volatile("int3");
  800178:	cc                   	int3   
  800179:	83 c4 10             	add    $0x10,%esp

	breakpoint();
}
  80017c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80017f:	c9                   	leave  
  800180:	c3                   	ret    
  800181:	00 00                	add    %al,(%eax)
	...

00800184 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800184:	55                   	push   %ebp
  800185:	89 e5                	mov    %esp,%ebp
  800187:	56                   	push   %esi
  800188:	53                   	push   %ebx
  800189:	8b 75 08             	mov    0x8(%ebp),%esi
  80018c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs + ENVX(sys_getenvid());
  80018f:	e8 1d 0b 00 00       	call   800cb1 <sys_getenvid>
  800194:	25 ff 03 00 00       	and    $0x3ff,%eax
  800199:	89 c2                	mov    %eax,%edx
  80019b:	c1 e2 07             	shl    $0x7,%edx
  80019e:	8d 84 82 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,4),%eax
  8001a5:	a3 04 50 80 00       	mov    %eax,0x805004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8001aa:	85 f6                	test   %esi,%esi
  8001ac:	7e 07                	jle    8001b5 <libmain+0x31>
		binaryname = argv[0];
  8001ae:	8b 03                	mov    (%ebx),%eax
  8001b0:	a3 08 40 80 00       	mov    %eax,0x804008
	// call user main routine
	umain(argc, argv);
  8001b5:	83 ec 08             	sub    $0x8,%esp
  8001b8:	53                   	push   %ebx
  8001b9:	56                   	push   %esi
  8001ba:	e8 95 fe ff ff       	call   800054 <umain>

	// exit gracefully
	exit();
  8001bf:	e8 0c 00 00 00       	call   8001d0 <exit>
  8001c4:	83 c4 10             	add    $0x10,%esp
}
  8001c7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8001ca:	5b                   	pop    %ebx
  8001cb:	5e                   	pop    %esi
  8001cc:	c9                   	leave  
  8001cd:	c3                   	ret    
	...

008001d0 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8001d0:	55                   	push   %ebp
  8001d1:	89 e5                	mov    %esp,%ebp
  8001d3:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8001d6:	e8 ef 11 00 00       	call   8013ca <close_all>
	sys_env_destroy(0);
  8001db:	83 ec 0c             	sub    $0xc,%esp
  8001de:	6a 00                	push   $0x0
  8001e0:	e8 aa 0a 00 00       	call   800c8f <sys_env_destroy>
  8001e5:	83 c4 10             	add    $0x10,%esp
}
  8001e8:	c9                   	leave  
  8001e9:	c3                   	ret    
	...

008001ec <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8001ec:	55                   	push   %ebp
  8001ed:	89 e5                	mov    %esp,%ebp
  8001ef:	56                   	push   %esi
  8001f0:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8001f1:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8001f4:	8b 1d 08 40 80 00    	mov    0x804008,%ebx
  8001fa:	e8 b2 0a 00 00       	call   800cb1 <sys_getenvid>
  8001ff:	83 ec 0c             	sub    $0xc,%esp
  800202:	ff 75 0c             	pushl  0xc(%ebp)
  800205:	ff 75 08             	pushl  0x8(%ebp)
  800208:	53                   	push   %ebx
  800209:	50                   	push   %eax
  80020a:	68 58 2c 80 00       	push   $0x802c58
  80020f:	e8 b0 00 00 00       	call   8002c4 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800214:	83 c4 18             	add    $0x18,%esp
  800217:	56                   	push   %esi
  800218:	ff 75 10             	pushl  0x10(%ebp)
  80021b:	e8 53 00 00 00       	call   800273 <vcprintf>
	cprintf("\n");
  800220:	c7 04 24 ba 32 80 00 	movl   $0x8032ba,(%esp)
  800227:	e8 98 00 00 00       	call   8002c4 <cprintf>
  80022c:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80022f:	cc                   	int3   
  800230:	eb fd                	jmp    80022f <_panic+0x43>
	...

00800234 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800234:	55                   	push   %ebp
  800235:	89 e5                	mov    %esp,%ebp
  800237:	53                   	push   %ebx
  800238:	83 ec 04             	sub    $0x4,%esp
  80023b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80023e:	8b 03                	mov    (%ebx),%eax
  800240:	8b 55 08             	mov    0x8(%ebp),%edx
  800243:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  800247:	40                   	inc    %eax
  800248:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  80024a:	3d ff 00 00 00       	cmp    $0xff,%eax
  80024f:	75 1a                	jne    80026b <putch+0x37>
		sys_cputs(b->buf, b->idx);
  800251:	83 ec 08             	sub    $0x8,%esp
  800254:	68 ff 00 00 00       	push   $0xff
  800259:	8d 43 08             	lea    0x8(%ebx),%eax
  80025c:	50                   	push   %eax
  80025d:	e8 e3 09 00 00       	call   800c45 <sys_cputs>
		b->idx = 0;
  800262:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800268:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80026b:	ff 43 04             	incl   0x4(%ebx)
}
  80026e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800271:	c9                   	leave  
  800272:	c3                   	ret    

00800273 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800273:	55                   	push   %ebp
  800274:	89 e5                	mov    %esp,%ebp
  800276:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80027c:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800283:	00 00 00 
	b.cnt = 0;
  800286:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80028d:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800290:	ff 75 0c             	pushl  0xc(%ebp)
  800293:	ff 75 08             	pushl  0x8(%ebp)
  800296:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80029c:	50                   	push   %eax
  80029d:	68 34 02 80 00       	push   $0x800234
  8002a2:	e8 82 01 00 00       	call   800429 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8002a7:	83 c4 08             	add    $0x8,%esp
  8002aa:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8002b0:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8002b6:	50                   	push   %eax
  8002b7:	e8 89 09 00 00       	call   800c45 <sys_cputs>

	return b.cnt;
}
  8002bc:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8002c2:	c9                   	leave  
  8002c3:	c3                   	ret    

008002c4 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8002c4:	55                   	push   %ebp
  8002c5:	89 e5                	mov    %esp,%ebp
  8002c7:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8002ca:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8002cd:	50                   	push   %eax
  8002ce:	ff 75 08             	pushl  0x8(%ebp)
  8002d1:	e8 9d ff ff ff       	call   800273 <vcprintf>
	va_end(ap);

	return cnt;
}
  8002d6:	c9                   	leave  
  8002d7:	c3                   	ret    

008002d8 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8002d8:	55                   	push   %ebp
  8002d9:	89 e5                	mov    %esp,%ebp
  8002db:	57                   	push   %edi
  8002dc:	56                   	push   %esi
  8002dd:	53                   	push   %ebx
  8002de:	83 ec 2c             	sub    $0x2c,%esp
  8002e1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8002e4:	89 d6                	mov    %edx,%esi
  8002e6:	8b 45 08             	mov    0x8(%ebp),%eax
  8002e9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002ec:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8002ef:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8002f2:	8b 45 10             	mov    0x10(%ebp),%eax
  8002f5:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8002f8:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8002fb:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8002fe:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  800305:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
  800308:	72 0c                	jb     800316 <printnum+0x3e>
  80030a:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  80030d:	76 07                	jbe    800316 <printnum+0x3e>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80030f:	4b                   	dec    %ebx
  800310:	85 db                	test   %ebx,%ebx
  800312:	7f 31                	jg     800345 <printnum+0x6d>
  800314:	eb 3f                	jmp    800355 <printnum+0x7d>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800316:	83 ec 0c             	sub    $0xc,%esp
  800319:	57                   	push   %edi
  80031a:	4b                   	dec    %ebx
  80031b:	53                   	push   %ebx
  80031c:	50                   	push   %eax
  80031d:	83 ec 08             	sub    $0x8,%esp
  800320:	ff 75 d4             	pushl  -0x2c(%ebp)
  800323:	ff 75 d0             	pushl  -0x30(%ebp)
  800326:	ff 75 dc             	pushl  -0x24(%ebp)
  800329:	ff 75 d8             	pushl  -0x28(%ebp)
  80032c:	e8 13 26 00 00       	call   802944 <__udivdi3>
  800331:	83 c4 18             	add    $0x18,%esp
  800334:	52                   	push   %edx
  800335:	50                   	push   %eax
  800336:	89 f2                	mov    %esi,%edx
  800338:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80033b:	e8 98 ff ff ff       	call   8002d8 <printnum>
  800340:	83 c4 20             	add    $0x20,%esp
  800343:	eb 10                	jmp    800355 <printnum+0x7d>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800345:	83 ec 08             	sub    $0x8,%esp
  800348:	56                   	push   %esi
  800349:	57                   	push   %edi
  80034a:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80034d:	4b                   	dec    %ebx
  80034e:	83 c4 10             	add    $0x10,%esp
  800351:	85 db                	test   %ebx,%ebx
  800353:	7f f0                	jg     800345 <printnum+0x6d>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800355:	83 ec 08             	sub    $0x8,%esp
  800358:	56                   	push   %esi
  800359:	83 ec 04             	sub    $0x4,%esp
  80035c:	ff 75 d4             	pushl  -0x2c(%ebp)
  80035f:	ff 75 d0             	pushl  -0x30(%ebp)
  800362:	ff 75 dc             	pushl  -0x24(%ebp)
  800365:	ff 75 d8             	pushl  -0x28(%ebp)
  800368:	e8 f3 26 00 00       	call   802a60 <__umoddi3>
  80036d:	83 c4 14             	add    $0x14,%esp
  800370:	0f be 80 7b 2c 80 00 	movsbl 0x802c7b(%eax),%eax
  800377:	50                   	push   %eax
  800378:	ff 55 e4             	call   *-0x1c(%ebp)
  80037b:	83 c4 10             	add    $0x10,%esp
}
  80037e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800381:	5b                   	pop    %ebx
  800382:	5e                   	pop    %esi
  800383:	5f                   	pop    %edi
  800384:	c9                   	leave  
  800385:	c3                   	ret    

00800386 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800386:	55                   	push   %ebp
  800387:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800389:	83 fa 01             	cmp    $0x1,%edx
  80038c:	7e 0e                	jle    80039c <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80038e:	8b 10                	mov    (%eax),%edx
  800390:	8d 4a 08             	lea    0x8(%edx),%ecx
  800393:	89 08                	mov    %ecx,(%eax)
  800395:	8b 02                	mov    (%edx),%eax
  800397:	8b 52 04             	mov    0x4(%edx),%edx
  80039a:	eb 22                	jmp    8003be <getuint+0x38>
	else if (lflag)
  80039c:	85 d2                	test   %edx,%edx
  80039e:	74 10                	je     8003b0 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8003a0:	8b 10                	mov    (%eax),%edx
  8003a2:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003a5:	89 08                	mov    %ecx,(%eax)
  8003a7:	8b 02                	mov    (%edx),%eax
  8003a9:	ba 00 00 00 00       	mov    $0x0,%edx
  8003ae:	eb 0e                	jmp    8003be <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8003b0:	8b 10                	mov    (%eax),%edx
  8003b2:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003b5:	89 08                	mov    %ecx,(%eax)
  8003b7:	8b 02                	mov    (%edx),%eax
  8003b9:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8003be:	c9                   	leave  
  8003bf:	c3                   	ret    

008003c0 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  8003c0:	55                   	push   %ebp
  8003c1:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8003c3:	83 fa 01             	cmp    $0x1,%edx
  8003c6:	7e 0e                	jle    8003d6 <getint+0x16>
		return va_arg(*ap, long long);
  8003c8:	8b 10                	mov    (%eax),%edx
  8003ca:	8d 4a 08             	lea    0x8(%edx),%ecx
  8003cd:	89 08                	mov    %ecx,(%eax)
  8003cf:	8b 02                	mov    (%edx),%eax
  8003d1:	8b 52 04             	mov    0x4(%edx),%edx
  8003d4:	eb 1a                	jmp    8003f0 <getint+0x30>
	else if (lflag)
  8003d6:	85 d2                	test   %edx,%edx
  8003d8:	74 0c                	je     8003e6 <getint+0x26>
		return va_arg(*ap, long);
  8003da:	8b 10                	mov    (%eax),%edx
  8003dc:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003df:	89 08                	mov    %ecx,(%eax)
  8003e1:	8b 02                	mov    (%edx),%eax
  8003e3:	99                   	cltd   
  8003e4:	eb 0a                	jmp    8003f0 <getint+0x30>
	else
		return va_arg(*ap, int);
  8003e6:	8b 10                	mov    (%eax),%edx
  8003e8:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003eb:	89 08                	mov    %ecx,(%eax)
  8003ed:	8b 02                	mov    (%edx),%eax
  8003ef:	99                   	cltd   
}
  8003f0:	c9                   	leave  
  8003f1:	c3                   	ret    

008003f2 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8003f2:	55                   	push   %ebp
  8003f3:	89 e5                	mov    %esp,%ebp
  8003f5:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8003f8:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  8003fb:	8b 10                	mov    (%eax),%edx
  8003fd:	3b 50 04             	cmp    0x4(%eax),%edx
  800400:	73 08                	jae    80040a <sprintputch+0x18>
		*b->buf++ = ch;
  800402:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800405:	88 0a                	mov    %cl,(%edx)
  800407:	42                   	inc    %edx
  800408:	89 10                	mov    %edx,(%eax)
}
  80040a:	c9                   	leave  
  80040b:	c3                   	ret    

0080040c <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80040c:	55                   	push   %ebp
  80040d:	89 e5                	mov    %esp,%ebp
  80040f:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800412:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800415:	50                   	push   %eax
  800416:	ff 75 10             	pushl  0x10(%ebp)
  800419:	ff 75 0c             	pushl  0xc(%ebp)
  80041c:	ff 75 08             	pushl  0x8(%ebp)
  80041f:	e8 05 00 00 00       	call   800429 <vprintfmt>
	va_end(ap);
  800424:	83 c4 10             	add    $0x10,%esp
}
  800427:	c9                   	leave  
  800428:	c3                   	ret    

00800429 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800429:	55                   	push   %ebp
  80042a:	89 e5                	mov    %esp,%ebp
  80042c:	57                   	push   %edi
  80042d:	56                   	push   %esi
  80042e:	53                   	push   %ebx
  80042f:	83 ec 2c             	sub    $0x2c,%esp
  800432:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800435:	8b 75 10             	mov    0x10(%ebp),%esi
  800438:	eb 13                	jmp    80044d <vprintfmt+0x24>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80043a:	85 c0                	test   %eax,%eax
  80043c:	0f 84 6d 03 00 00    	je     8007af <vprintfmt+0x386>
				return;
			putch(ch, putdat);
  800442:	83 ec 08             	sub    $0x8,%esp
  800445:	57                   	push   %edi
  800446:	50                   	push   %eax
  800447:	ff 55 08             	call   *0x8(%ebp)
  80044a:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80044d:	0f b6 06             	movzbl (%esi),%eax
  800450:	46                   	inc    %esi
  800451:	83 f8 25             	cmp    $0x25,%eax
  800454:	75 e4                	jne    80043a <vprintfmt+0x11>
  800456:	c6 45 dc 20          	movb   $0x20,-0x24(%ebp)
  80045a:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  800461:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  800468:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  80046f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800474:	eb 28                	jmp    80049e <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800476:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800478:	c6 45 dc 2d          	movb   $0x2d,-0x24(%ebp)
  80047c:	eb 20                	jmp    80049e <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80047e:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800480:	c6 45 dc 30          	movb   $0x30,-0x24(%ebp)
  800484:	eb 18                	jmp    80049e <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800486:	89 de                	mov    %ebx,%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800488:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  80048f:	eb 0d                	jmp    80049e <vprintfmt+0x75>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800491:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800494:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800497:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80049e:	8a 06                	mov    (%esi),%al
  8004a0:	0f b6 d0             	movzbl %al,%edx
  8004a3:	8d 5e 01             	lea    0x1(%esi),%ebx
  8004a6:	83 e8 23             	sub    $0x23,%eax
  8004a9:	3c 55                	cmp    $0x55,%al
  8004ab:	0f 87 e0 02 00 00    	ja     800791 <vprintfmt+0x368>
  8004b1:	0f b6 c0             	movzbl %al,%eax
  8004b4:	ff 24 85 c0 2d 80 00 	jmp    *0x802dc0(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8004bb:	83 ea 30             	sub    $0x30,%edx
  8004be:	89 55 d4             	mov    %edx,-0x2c(%ebp)
				ch = *fmt;
  8004c1:	0f be 03             	movsbl (%ebx),%eax
				if (ch < '0' || ch > '9')
  8004c4:	8d 50 d0             	lea    -0x30(%eax),%edx
  8004c7:	83 fa 09             	cmp    $0x9,%edx
  8004ca:	77 44                	ja     800510 <vprintfmt+0xe7>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004cc:	89 de                	mov    %ebx,%esi
  8004ce:	8b 55 d4             	mov    -0x2c(%ebp),%edx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8004d1:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
  8004d2:	8d 14 92             	lea    (%edx,%edx,4),%edx
  8004d5:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
  8004d9:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8004dc:	8d 58 d0             	lea    -0x30(%eax),%ebx
  8004df:	83 fb 09             	cmp    $0x9,%ebx
  8004e2:	76 ed                	jbe    8004d1 <vprintfmt+0xa8>
  8004e4:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  8004e7:	eb 29                	jmp    800512 <vprintfmt+0xe9>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8004e9:	8b 45 14             	mov    0x14(%ebp),%eax
  8004ec:	8d 50 04             	lea    0x4(%eax),%edx
  8004ef:	89 55 14             	mov    %edx,0x14(%ebp)
  8004f2:	8b 00                	mov    (%eax),%eax
  8004f4:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004f7:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8004f9:	eb 17                	jmp    800512 <vprintfmt+0xe9>

		case '.':
			if (width < 0)
  8004fb:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8004ff:	78 85                	js     800486 <vprintfmt+0x5d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800501:	89 de                	mov    %ebx,%esi
  800503:	eb 99                	jmp    80049e <vprintfmt+0x75>
  800505:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800507:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  80050e:	eb 8e                	jmp    80049e <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800510:	89 de                	mov    %ebx,%esi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  800512:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800516:	79 86                	jns    80049e <vprintfmt+0x75>
  800518:	e9 74 ff ff ff       	jmp    800491 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80051d:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80051e:	89 de                	mov    %ebx,%esi
  800520:	e9 79 ff ff ff       	jmp    80049e <vprintfmt+0x75>
  800525:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800528:	8b 45 14             	mov    0x14(%ebp),%eax
  80052b:	8d 50 04             	lea    0x4(%eax),%edx
  80052e:	89 55 14             	mov    %edx,0x14(%ebp)
  800531:	83 ec 08             	sub    $0x8,%esp
  800534:	57                   	push   %edi
  800535:	ff 30                	pushl  (%eax)
  800537:	ff 55 08             	call   *0x8(%ebp)
			break;
  80053a:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80053d:	8b 75 d8             	mov    -0x28(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800540:	e9 08 ff ff ff       	jmp    80044d <vprintfmt+0x24>
  800545:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  800548:	8b 45 14             	mov    0x14(%ebp),%eax
  80054b:	8d 50 04             	lea    0x4(%eax),%edx
  80054e:	89 55 14             	mov    %edx,0x14(%ebp)
  800551:	8b 00                	mov    (%eax),%eax
  800553:	85 c0                	test   %eax,%eax
  800555:	79 02                	jns    800559 <vprintfmt+0x130>
  800557:	f7 d8                	neg    %eax
  800559:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80055b:	83 f8 0f             	cmp    $0xf,%eax
  80055e:	7f 0b                	jg     80056b <vprintfmt+0x142>
  800560:	8b 04 85 20 2f 80 00 	mov    0x802f20(,%eax,4),%eax
  800567:	85 c0                	test   %eax,%eax
  800569:	75 1a                	jne    800585 <vprintfmt+0x15c>
				printfmt(putch, putdat, "error %d", err);
  80056b:	52                   	push   %edx
  80056c:	68 93 2c 80 00       	push   $0x802c93
  800571:	57                   	push   %edi
  800572:	ff 75 08             	pushl  0x8(%ebp)
  800575:	e8 92 fe ff ff       	call   80040c <printfmt>
  80057a:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80057d:	8b 75 d8             	mov    -0x28(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800580:	e9 c8 fe ff ff       	jmp    80044d <vprintfmt+0x24>
			else
				printfmt(putch, putdat, "%s", p);
  800585:	50                   	push   %eax
  800586:	68 d5 31 80 00       	push   $0x8031d5
  80058b:	57                   	push   %edi
  80058c:	ff 75 08             	pushl  0x8(%ebp)
  80058f:	e8 78 fe ff ff       	call   80040c <printfmt>
  800594:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800597:	8b 75 d8             	mov    -0x28(%ebp),%esi
  80059a:	e9 ae fe ff ff       	jmp    80044d <vprintfmt+0x24>
  80059f:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  8005a2:	89 de                	mov    %ebx,%esi
  8005a4:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  8005a7:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8005aa:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ad:	8d 50 04             	lea    0x4(%eax),%edx
  8005b0:	89 55 14             	mov    %edx,0x14(%ebp)
  8005b3:	8b 00                	mov    (%eax),%eax
  8005b5:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8005b8:	85 c0                	test   %eax,%eax
  8005ba:	75 07                	jne    8005c3 <vprintfmt+0x19a>
				p = "(null)";
  8005bc:	c7 45 d0 8c 2c 80 00 	movl   $0x802c8c,-0x30(%ebp)
			if (width > 0 && padc != '-')
  8005c3:	85 db                	test   %ebx,%ebx
  8005c5:	7e 42                	jle    800609 <vprintfmt+0x1e0>
  8005c7:	80 7d dc 2d          	cmpb   $0x2d,-0x24(%ebp)
  8005cb:	74 3c                	je     800609 <vprintfmt+0x1e0>
				for (width -= strnlen(p, precision); width > 0; width--)
  8005cd:	83 ec 08             	sub    $0x8,%esp
  8005d0:	51                   	push   %ecx
  8005d1:	ff 75 d0             	pushl  -0x30(%ebp)
  8005d4:	e8 6f 02 00 00       	call   800848 <strnlen>
  8005d9:	29 c3                	sub    %eax,%ebx
  8005db:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8005de:	83 c4 10             	add    $0x10,%esp
  8005e1:	85 db                	test   %ebx,%ebx
  8005e3:	7e 24                	jle    800609 <vprintfmt+0x1e0>
					putch(padc, putdat);
  8005e5:	0f be 5d dc          	movsbl -0x24(%ebp),%ebx
  8005e9:	89 75 dc             	mov    %esi,-0x24(%ebp)
  8005ec:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  8005ef:	83 ec 08             	sub    $0x8,%esp
  8005f2:	57                   	push   %edi
  8005f3:	53                   	push   %ebx
  8005f4:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005f7:	4e                   	dec    %esi
  8005f8:	83 c4 10             	add    $0x10,%esp
  8005fb:	85 f6                	test   %esi,%esi
  8005fd:	7f f0                	jg     8005ef <vprintfmt+0x1c6>
  8005ff:	8b 75 dc             	mov    -0x24(%ebp),%esi
  800602:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800609:	8b 55 d0             	mov    -0x30(%ebp),%edx
  80060c:	0f be 02             	movsbl (%edx),%eax
  80060f:	85 c0                	test   %eax,%eax
  800611:	75 47                	jne    80065a <vprintfmt+0x231>
  800613:	eb 37                	jmp    80064c <vprintfmt+0x223>
				if (altflag && (ch < ' ' || ch > '~'))
  800615:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800619:	74 16                	je     800631 <vprintfmt+0x208>
  80061b:	8d 50 e0             	lea    -0x20(%eax),%edx
  80061e:	83 fa 5e             	cmp    $0x5e,%edx
  800621:	76 0e                	jbe    800631 <vprintfmt+0x208>
					putch('?', putdat);
  800623:	83 ec 08             	sub    $0x8,%esp
  800626:	57                   	push   %edi
  800627:	6a 3f                	push   $0x3f
  800629:	ff 55 08             	call   *0x8(%ebp)
  80062c:	83 c4 10             	add    $0x10,%esp
  80062f:	eb 0b                	jmp    80063c <vprintfmt+0x213>
				else
					putch(ch, putdat);
  800631:	83 ec 08             	sub    $0x8,%esp
  800634:	57                   	push   %edi
  800635:	50                   	push   %eax
  800636:	ff 55 08             	call   *0x8(%ebp)
  800639:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80063c:	ff 4d e4             	decl   -0x1c(%ebp)
  80063f:	0f be 03             	movsbl (%ebx),%eax
  800642:	85 c0                	test   %eax,%eax
  800644:	74 03                	je     800649 <vprintfmt+0x220>
  800646:	43                   	inc    %ebx
  800647:	eb 1b                	jmp    800664 <vprintfmt+0x23b>
  800649:	8b 75 dc             	mov    -0x24(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80064c:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800650:	7f 1e                	jg     800670 <vprintfmt+0x247>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800652:	8b 75 d8             	mov    -0x28(%ebp),%esi
  800655:	e9 f3 fd ff ff       	jmp    80044d <vprintfmt+0x24>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80065a:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  80065d:	43                   	inc    %ebx
  80065e:	89 75 dc             	mov    %esi,-0x24(%ebp)
  800661:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  800664:	85 f6                	test   %esi,%esi
  800666:	78 ad                	js     800615 <vprintfmt+0x1ec>
  800668:	4e                   	dec    %esi
  800669:	79 aa                	jns    800615 <vprintfmt+0x1ec>
  80066b:	8b 75 dc             	mov    -0x24(%ebp),%esi
  80066e:	eb dc                	jmp    80064c <vprintfmt+0x223>
  800670:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800673:	83 ec 08             	sub    $0x8,%esp
  800676:	57                   	push   %edi
  800677:	6a 20                	push   $0x20
  800679:	ff 55 08             	call   *0x8(%ebp)
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80067c:	4b                   	dec    %ebx
  80067d:	83 c4 10             	add    $0x10,%esp
  800680:	85 db                	test   %ebx,%ebx
  800682:	7f ef                	jg     800673 <vprintfmt+0x24a>
  800684:	e9 c4 fd ff ff       	jmp    80044d <vprintfmt+0x24>
  800689:	89 5d d8             	mov    %ebx,-0x28(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80068c:	89 ca                	mov    %ecx,%edx
  80068e:	8d 45 14             	lea    0x14(%ebp),%eax
  800691:	e8 2a fd ff ff       	call   8003c0 <getint>
  800696:	89 c3                	mov    %eax,%ebx
  800698:	89 d6                	mov    %edx,%esi
			if ((long long) num < 0) {
  80069a:	85 d2                	test   %edx,%edx
  80069c:	78 0a                	js     8006a8 <vprintfmt+0x27f>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80069e:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006a3:	e9 b0 00 00 00       	jmp    800758 <vprintfmt+0x32f>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  8006a8:	83 ec 08             	sub    $0x8,%esp
  8006ab:	57                   	push   %edi
  8006ac:	6a 2d                	push   $0x2d
  8006ae:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8006b1:	f7 db                	neg    %ebx
  8006b3:	83 d6 00             	adc    $0x0,%esi
  8006b6:	f7 de                	neg    %esi
  8006b8:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8006bb:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006c0:	e9 93 00 00 00       	jmp    800758 <vprintfmt+0x32f>
  8006c5:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8006c8:	89 ca                	mov    %ecx,%edx
  8006ca:	8d 45 14             	lea    0x14(%ebp),%eax
  8006cd:	e8 b4 fc ff ff       	call   800386 <getuint>
  8006d2:	89 c3                	mov    %eax,%ebx
  8006d4:	89 d6                	mov    %edx,%esi
			base = 10;
  8006d6:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  8006db:	eb 7b                	jmp    800758 <vprintfmt+0x32f>
  8006dd:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
  8006e0:	89 ca                	mov    %ecx,%edx
  8006e2:	8d 45 14             	lea    0x14(%ebp),%eax
  8006e5:	e8 d6 fc ff ff       	call   8003c0 <getint>
  8006ea:	89 c3                	mov    %eax,%ebx
  8006ec:	89 d6                	mov    %edx,%esi
            if ((long long) num < 0) {
  8006ee:	85 d2                	test   %edx,%edx
  8006f0:	78 07                	js     8006f9 <vprintfmt+0x2d0>
                putch('-', putdat);
                num = -(long long) num;
            }
            base = 8;
  8006f2:	b8 08 00 00 00       	mov    $0x8,%eax
  8006f7:	eb 5f                	jmp    800758 <vprintfmt+0x32f>
		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
            if ((long long) num < 0) {
                putch('-', putdat);
  8006f9:	83 ec 08             	sub    $0x8,%esp
  8006fc:	57                   	push   %edi
  8006fd:	6a 2d                	push   $0x2d
  8006ff:	ff 55 08             	call   *0x8(%ebp)
                num = -(long long) num;
  800702:	f7 db                	neg    %ebx
  800704:	83 d6 00             	adc    $0x0,%esi
  800707:	f7 de                	neg    %esi
  800709:	83 c4 10             	add    $0x10,%esp
            }
            base = 8;
  80070c:	b8 08 00 00 00       	mov    $0x8,%eax
  800711:	eb 45                	jmp    800758 <vprintfmt+0x32f>
  800713:	89 5d d8             	mov    %ebx,-0x28(%ebp)
            goto number;

        // pointer
		case 'p':
			putch('0', putdat);
  800716:	83 ec 08             	sub    $0x8,%esp
  800719:	57                   	push   %edi
  80071a:	6a 30                	push   $0x30
  80071c:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  80071f:	83 c4 08             	add    $0x8,%esp
  800722:	57                   	push   %edi
  800723:	6a 78                	push   $0x78
  800725:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800728:	8b 45 14             	mov    0x14(%ebp),%eax
  80072b:	8d 50 04             	lea    0x4(%eax),%edx
  80072e:	89 55 14             	mov    %edx,0x14(%ebp)

        // pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800731:	8b 18                	mov    (%eax),%ebx
  800733:	be 00 00 00 00       	mov    $0x0,%esi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800738:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80073b:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800740:	eb 16                	jmp    800758 <vprintfmt+0x32f>
  800742:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800745:	89 ca                	mov    %ecx,%edx
  800747:	8d 45 14             	lea    0x14(%ebp),%eax
  80074a:	e8 37 fc ff ff       	call   800386 <getuint>
  80074f:	89 c3                	mov    %eax,%ebx
  800751:	89 d6                	mov    %edx,%esi
			base = 16;
  800753:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800758:	83 ec 0c             	sub    $0xc,%esp
  80075b:	0f be 55 dc          	movsbl -0x24(%ebp),%edx
  80075f:	52                   	push   %edx
  800760:	ff 75 e4             	pushl  -0x1c(%ebp)
  800763:	50                   	push   %eax
  800764:	56                   	push   %esi
  800765:	53                   	push   %ebx
  800766:	89 fa                	mov    %edi,%edx
  800768:	8b 45 08             	mov    0x8(%ebp),%eax
  80076b:	e8 68 fb ff ff       	call   8002d8 <printnum>
			break;
  800770:	83 c4 20             	add    $0x20,%esp
  800773:	8b 75 d8             	mov    -0x28(%ebp),%esi
  800776:	e9 d2 fc ff ff       	jmp    80044d <vprintfmt+0x24>
  80077b:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80077e:	83 ec 08             	sub    $0x8,%esp
  800781:	57                   	push   %edi
  800782:	52                   	push   %edx
  800783:	ff 55 08             	call   *0x8(%ebp)
			break;
  800786:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800789:	8b 75 d8             	mov    -0x28(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80078c:	e9 bc fc ff ff       	jmp    80044d <vprintfmt+0x24>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800791:	83 ec 08             	sub    $0x8,%esp
  800794:	57                   	push   %edi
  800795:	6a 25                	push   $0x25
  800797:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  80079a:	83 c4 10             	add    $0x10,%esp
  80079d:	eb 02                	jmp    8007a1 <vprintfmt+0x378>
  80079f:	89 c6                	mov    %eax,%esi
  8007a1:	8d 46 ff             	lea    -0x1(%esi),%eax
  8007a4:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  8007a8:	75 f5                	jne    80079f <vprintfmt+0x376>
  8007aa:	e9 9e fc ff ff       	jmp    80044d <vprintfmt+0x24>
				/* do nothing */;
			break;
		}
	}
}
  8007af:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8007b2:	5b                   	pop    %ebx
  8007b3:	5e                   	pop    %esi
  8007b4:	5f                   	pop    %edi
  8007b5:	c9                   	leave  
  8007b6:	c3                   	ret    

008007b7 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8007b7:	55                   	push   %ebp
  8007b8:	89 e5                	mov    %esp,%ebp
  8007ba:	83 ec 18             	sub    $0x18,%esp
  8007bd:	8b 45 08             	mov    0x8(%ebp),%eax
  8007c0:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8007c3:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8007c6:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8007ca:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8007cd:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8007d4:	85 c0                	test   %eax,%eax
  8007d6:	74 26                	je     8007fe <vsnprintf+0x47>
  8007d8:	85 d2                	test   %edx,%edx
  8007da:	7e 29                	jle    800805 <vsnprintf+0x4e>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8007dc:	ff 75 14             	pushl  0x14(%ebp)
  8007df:	ff 75 10             	pushl  0x10(%ebp)
  8007e2:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8007e5:	50                   	push   %eax
  8007e6:	68 f2 03 80 00       	push   $0x8003f2
  8007eb:	e8 39 fc ff ff       	call   800429 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8007f0:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007f3:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8007f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007f9:	83 c4 10             	add    $0x10,%esp
  8007fc:	eb 0c                	jmp    80080a <vsnprintf+0x53>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8007fe:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800803:	eb 05                	jmp    80080a <vsnprintf+0x53>
  800805:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80080a:	c9                   	leave  
  80080b:	c3                   	ret    

0080080c <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80080c:	55                   	push   %ebp
  80080d:	89 e5                	mov    %esp,%ebp
  80080f:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800812:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800815:	50                   	push   %eax
  800816:	ff 75 10             	pushl  0x10(%ebp)
  800819:	ff 75 0c             	pushl  0xc(%ebp)
  80081c:	ff 75 08             	pushl  0x8(%ebp)
  80081f:	e8 93 ff ff ff       	call   8007b7 <vsnprintf>
	va_end(ap);

	return rc;
}
  800824:	c9                   	leave  
  800825:	c3                   	ret    
	...

00800828 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800828:	55                   	push   %ebp
  800829:	89 e5                	mov    %esp,%ebp
  80082b:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80082e:	80 3a 00             	cmpb   $0x0,(%edx)
  800831:	74 0e                	je     800841 <strlen+0x19>
  800833:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800838:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800839:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80083d:	75 f9                	jne    800838 <strlen+0x10>
  80083f:	eb 05                	jmp    800846 <strlen+0x1e>
  800841:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800846:	c9                   	leave  
  800847:	c3                   	ret    

00800848 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800848:	55                   	push   %ebp
  800849:	89 e5                	mov    %esp,%ebp
  80084b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80084e:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800851:	85 d2                	test   %edx,%edx
  800853:	74 17                	je     80086c <strnlen+0x24>
  800855:	80 39 00             	cmpb   $0x0,(%ecx)
  800858:	74 19                	je     800873 <strnlen+0x2b>
  80085a:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  80085f:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800860:	39 d0                	cmp    %edx,%eax
  800862:	74 14                	je     800878 <strnlen+0x30>
  800864:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800868:	75 f5                	jne    80085f <strnlen+0x17>
  80086a:	eb 0c                	jmp    800878 <strnlen+0x30>
  80086c:	b8 00 00 00 00       	mov    $0x0,%eax
  800871:	eb 05                	jmp    800878 <strnlen+0x30>
  800873:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800878:	c9                   	leave  
  800879:	c3                   	ret    

0080087a <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80087a:	55                   	push   %ebp
  80087b:	89 e5                	mov    %esp,%ebp
  80087d:	53                   	push   %ebx
  80087e:	8b 45 08             	mov    0x8(%ebp),%eax
  800881:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800884:	ba 00 00 00 00       	mov    $0x0,%edx
  800889:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  80088c:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  80088f:	42                   	inc    %edx
  800890:	84 c9                	test   %cl,%cl
  800892:	75 f5                	jne    800889 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800894:	5b                   	pop    %ebx
  800895:	c9                   	leave  
  800896:	c3                   	ret    

00800897 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800897:	55                   	push   %ebp
  800898:	89 e5                	mov    %esp,%ebp
  80089a:	53                   	push   %ebx
  80089b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80089e:	53                   	push   %ebx
  80089f:	e8 84 ff ff ff       	call   800828 <strlen>
  8008a4:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8008a7:	ff 75 0c             	pushl  0xc(%ebp)
  8008aa:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  8008ad:	50                   	push   %eax
  8008ae:	e8 c7 ff ff ff       	call   80087a <strcpy>
	return dst;
}
  8008b3:	89 d8                	mov    %ebx,%eax
  8008b5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008b8:	c9                   	leave  
  8008b9:	c3                   	ret    

008008ba <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8008ba:	55                   	push   %ebp
  8008bb:	89 e5                	mov    %esp,%ebp
  8008bd:	56                   	push   %esi
  8008be:	53                   	push   %ebx
  8008bf:	8b 45 08             	mov    0x8(%ebp),%eax
  8008c2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008c5:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008c8:	85 f6                	test   %esi,%esi
  8008ca:	74 15                	je     8008e1 <strncpy+0x27>
  8008cc:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  8008d1:	8a 1a                	mov    (%edx),%bl
  8008d3:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8008d6:	80 3a 01             	cmpb   $0x1,(%edx)
  8008d9:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008dc:	41                   	inc    %ecx
  8008dd:	39 ce                	cmp    %ecx,%esi
  8008df:	77 f0                	ja     8008d1 <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8008e1:	5b                   	pop    %ebx
  8008e2:	5e                   	pop    %esi
  8008e3:	c9                   	leave  
  8008e4:	c3                   	ret    

008008e5 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8008e5:	55                   	push   %ebp
  8008e6:	89 e5                	mov    %esp,%ebp
  8008e8:	57                   	push   %edi
  8008e9:	56                   	push   %esi
  8008ea:	53                   	push   %ebx
  8008eb:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008ee:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8008f1:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8008f4:	85 f6                	test   %esi,%esi
  8008f6:	74 32                	je     80092a <strlcpy+0x45>
		while (--size > 0 && *src != '\0')
  8008f8:	83 fe 01             	cmp    $0x1,%esi
  8008fb:	74 22                	je     80091f <strlcpy+0x3a>
  8008fd:	8a 0b                	mov    (%ebx),%cl
  8008ff:	84 c9                	test   %cl,%cl
  800901:	74 20                	je     800923 <strlcpy+0x3e>
  800903:	89 f8                	mov    %edi,%eax
  800905:	ba 00 00 00 00       	mov    $0x0,%edx
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
  80090a:	83 ee 02             	sub    $0x2,%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80090d:	88 08                	mov    %cl,(%eax)
  80090f:	40                   	inc    %eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800910:	39 f2                	cmp    %esi,%edx
  800912:	74 11                	je     800925 <strlcpy+0x40>
  800914:	8a 4c 13 01          	mov    0x1(%ebx,%edx,1),%cl
  800918:	42                   	inc    %edx
  800919:	84 c9                	test   %cl,%cl
  80091b:	75 f0                	jne    80090d <strlcpy+0x28>
  80091d:	eb 06                	jmp    800925 <strlcpy+0x40>
  80091f:	89 f8                	mov    %edi,%eax
  800921:	eb 02                	jmp    800925 <strlcpy+0x40>
  800923:	89 f8                	mov    %edi,%eax
			*dst++ = *src++;
		*dst = '\0';
  800925:	c6 00 00             	movb   $0x0,(%eax)
  800928:	eb 02                	jmp    80092c <strlcpy+0x47>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80092a:	89 f8                	mov    %edi,%eax
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
		*dst = '\0';
	}
	return dst - dst_in;
  80092c:	29 f8                	sub    %edi,%eax
}
  80092e:	5b                   	pop    %ebx
  80092f:	5e                   	pop    %esi
  800930:	5f                   	pop    %edi
  800931:	c9                   	leave  
  800932:	c3                   	ret    

00800933 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800933:	55                   	push   %ebp
  800934:	89 e5                	mov    %esp,%ebp
  800936:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800939:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80093c:	8a 01                	mov    (%ecx),%al
  80093e:	84 c0                	test   %al,%al
  800940:	74 10                	je     800952 <strcmp+0x1f>
  800942:	3a 02                	cmp    (%edx),%al
  800944:	75 0c                	jne    800952 <strcmp+0x1f>
		p++, q++;
  800946:	41                   	inc    %ecx
  800947:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800948:	8a 01                	mov    (%ecx),%al
  80094a:	84 c0                	test   %al,%al
  80094c:	74 04                	je     800952 <strcmp+0x1f>
  80094e:	3a 02                	cmp    (%edx),%al
  800950:	74 f4                	je     800946 <strcmp+0x13>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800952:	0f b6 c0             	movzbl %al,%eax
  800955:	0f b6 12             	movzbl (%edx),%edx
  800958:	29 d0                	sub    %edx,%eax
}
  80095a:	c9                   	leave  
  80095b:	c3                   	ret    

0080095c <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80095c:	55                   	push   %ebp
  80095d:	89 e5                	mov    %esp,%ebp
  80095f:	53                   	push   %ebx
  800960:	8b 55 08             	mov    0x8(%ebp),%edx
  800963:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800966:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  800969:	85 c0                	test   %eax,%eax
  80096b:	74 1b                	je     800988 <strncmp+0x2c>
  80096d:	8a 1a                	mov    (%edx),%bl
  80096f:	84 db                	test   %bl,%bl
  800971:	74 24                	je     800997 <strncmp+0x3b>
  800973:	3a 19                	cmp    (%ecx),%bl
  800975:	75 20                	jne    800997 <strncmp+0x3b>
  800977:	48                   	dec    %eax
  800978:	74 15                	je     80098f <strncmp+0x33>
		n--, p++, q++;
  80097a:	42                   	inc    %edx
  80097b:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80097c:	8a 1a                	mov    (%edx),%bl
  80097e:	84 db                	test   %bl,%bl
  800980:	74 15                	je     800997 <strncmp+0x3b>
  800982:	3a 19                	cmp    (%ecx),%bl
  800984:	74 f1                	je     800977 <strncmp+0x1b>
  800986:	eb 0f                	jmp    800997 <strncmp+0x3b>
		n--, p++, q++;
	if (n == 0)
		return 0;
  800988:	b8 00 00 00 00       	mov    $0x0,%eax
  80098d:	eb 05                	jmp    800994 <strncmp+0x38>
  80098f:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800994:	5b                   	pop    %ebx
  800995:	c9                   	leave  
  800996:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800997:	0f b6 02             	movzbl (%edx),%eax
  80099a:	0f b6 11             	movzbl (%ecx),%edx
  80099d:	29 d0                	sub    %edx,%eax
  80099f:	eb f3                	jmp    800994 <strncmp+0x38>

008009a1 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8009a1:	55                   	push   %ebp
  8009a2:	89 e5                	mov    %esp,%ebp
  8009a4:	8b 45 08             	mov    0x8(%ebp),%eax
  8009a7:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8009aa:	8a 10                	mov    (%eax),%dl
  8009ac:	84 d2                	test   %dl,%dl
  8009ae:	74 18                	je     8009c8 <strchr+0x27>
		if (*s == c)
  8009b0:	38 ca                	cmp    %cl,%dl
  8009b2:	75 06                	jne    8009ba <strchr+0x19>
  8009b4:	eb 17                	jmp    8009cd <strchr+0x2c>
  8009b6:	38 ca                	cmp    %cl,%dl
  8009b8:	74 13                	je     8009cd <strchr+0x2c>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8009ba:	40                   	inc    %eax
  8009bb:	8a 10                	mov    (%eax),%dl
  8009bd:	84 d2                	test   %dl,%dl
  8009bf:	75 f5                	jne    8009b6 <strchr+0x15>
		if (*s == c)
			return (char *) s;
	return 0;
  8009c1:	b8 00 00 00 00       	mov    $0x0,%eax
  8009c6:	eb 05                	jmp    8009cd <strchr+0x2c>
  8009c8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009cd:	c9                   	leave  
  8009ce:	c3                   	ret    

008009cf <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8009cf:	55                   	push   %ebp
  8009d0:	89 e5                	mov    %esp,%ebp
  8009d2:	8b 45 08             	mov    0x8(%ebp),%eax
  8009d5:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8009d8:	8a 10                	mov    (%eax),%dl
  8009da:	84 d2                	test   %dl,%dl
  8009dc:	74 11                	je     8009ef <strfind+0x20>
		if (*s == c)
  8009de:	38 ca                	cmp    %cl,%dl
  8009e0:	75 06                	jne    8009e8 <strfind+0x19>
  8009e2:	eb 0b                	jmp    8009ef <strfind+0x20>
  8009e4:	38 ca                	cmp    %cl,%dl
  8009e6:	74 07                	je     8009ef <strfind+0x20>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  8009e8:	40                   	inc    %eax
  8009e9:	8a 10                	mov    (%eax),%dl
  8009eb:	84 d2                	test   %dl,%dl
  8009ed:	75 f5                	jne    8009e4 <strfind+0x15>
		if (*s == c)
			break;
	return (char *) s;
}
  8009ef:	c9                   	leave  
  8009f0:	c3                   	ret    

008009f1 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8009f1:	55                   	push   %ebp
  8009f2:	89 e5                	mov    %esp,%ebp
  8009f4:	57                   	push   %edi
  8009f5:	56                   	push   %esi
  8009f6:	53                   	push   %ebx
  8009f7:	8b 7d 08             	mov    0x8(%ebp),%edi
  8009fa:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009fd:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800a00:	85 c9                	test   %ecx,%ecx
  800a02:	74 30                	je     800a34 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a04:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a0a:	75 25                	jne    800a31 <memset+0x40>
  800a0c:	f6 c1 03             	test   $0x3,%cl
  800a0f:	75 20                	jne    800a31 <memset+0x40>
		c &= 0xFF;
  800a11:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a14:	89 d3                	mov    %edx,%ebx
  800a16:	c1 e3 08             	shl    $0x8,%ebx
  800a19:	89 d6                	mov    %edx,%esi
  800a1b:	c1 e6 18             	shl    $0x18,%esi
  800a1e:	89 d0                	mov    %edx,%eax
  800a20:	c1 e0 10             	shl    $0x10,%eax
  800a23:	09 f0                	or     %esi,%eax
  800a25:	09 d0                	or     %edx,%eax
  800a27:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800a29:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800a2c:	fc                   	cld    
  800a2d:	f3 ab                	rep stos %eax,%es:(%edi)
  800a2f:	eb 03                	jmp    800a34 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a31:	fc                   	cld    
  800a32:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a34:	89 f8                	mov    %edi,%eax
  800a36:	5b                   	pop    %ebx
  800a37:	5e                   	pop    %esi
  800a38:	5f                   	pop    %edi
  800a39:	c9                   	leave  
  800a3a:	c3                   	ret    

00800a3b <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a3b:	55                   	push   %ebp
  800a3c:	89 e5                	mov    %esp,%ebp
  800a3e:	57                   	push   %edi
  800a3f:	56                   	push   %esi
  800a40:	8b 45 08             	mov    0x8(%ebp),%eax
  800a43:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a46:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a49:	39 c6                	cmp    %eax,%esi
  800a4b:	73 34                	jae    800a81 <memmove+0x46>
  800a4d:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a50:	39 d0                	cmp    %edx,%eax
  800a52:	73 2d                	jae    800a81 <memmove+0x46>
		s += n;
		d += n;
  800a54:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a57:	f6 c2 03             	test   $0x3,%dl
  800a5a:	75 1b                	jne    800a77 <memmove+0x3c>
  800a5c:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a62:	75 13                	jne    800a77 <memmove+0x3c>
  800a64:	f6 c1 03             	test   $0x3,%cl
  800a67:	75 0e                	jne    800a77 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800a69:	83 ef 04             	sub    $0x4,%edi
  800a6c:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a6f:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800a72:	fd                   	std    
  800a73:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a75:	eb 07                	jmp    800a7e <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800a77:	4f                   	dec    %edi
  800a78:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800a7b:	fd                   	std    
  800a7c:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a7e:	fc                   	cld    
  800a7f:	eb 20                	jmp    800aa1 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a81:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a87:	75 13                	jne    800a9c <memmove+0x61>
  800a89:	a8 03                	test   $0x3,%al
  800a8b:	75 0f                	jne    800a9c <memmove+0x61>
  800a8d:	f6 c1 03             	test   $0x3,%cl
  800a90:	75 0a                	jne    800a9c <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800a92:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800a95:	89 c7                	mov    %eax,%edi
  800a97:	fc                   	cld    
  800a98:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a9a:	eb 05                	jmp    800aa1 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a9c:	89 c7                	mov    %eax,%edi
  800a9e:	fc                   	cld    
  800a9f:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800aa1:	5e                   	pop    %esi
  800aa2:	5f                   	pop    %edi
  800aa3:	c9                   	leave  
  800aa4:	c3                   	ret    

00800aa5 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800aa5:	55                   	push   %ebp
  800aa6:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800aa8:	ff 75 10             	pushl  0x10(%ebp)
  800aab:	ff 75 0c             	pushl  0xc(%ebp)
  800aae:	ff 75 08             	pushl  0x8(%ebp)
  800ab1:	e8 85 ff ff ff       	call   800a3b <memmove>
}
  800ab6:	c9                   	leave  
  800ab7:	c3                   	ret    

00800ab8 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800ab8:	55                   	push   %ebp
  800ab9:	89 e5                	mov    %esp,%ebp
  800abb:	57                   	push   %edi
  800abc:	56                   	push   %esi
  800abd:	53                   	push   %ebx
  800abe:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800ac1:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ac4:	8b 7d 10             	mov    0x10(%ebp),%edi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800ac7:	85 ff                	test   %edi,%edi
  800ac9:	74 32                	je     800afd <memcmp+0x45>
		if (*s1 != *s2)
  800acb:	8a 03                	mov    (%ebx),%al
  800acd:	8a 0e                	mov    (%esi),%cl
  800acf:	38 c8                	cmp    %cl,%al
  800ad1:	74 19                	je     800aec <memcmp+0x34>
  800ad3:	eb 0d                	jmp    800ae2 <memcmp+0x2a>
  800ad5:	8a 44 13 01          	mov    0x1(%ebx,%edx,1),%al
  800ad9:	8a 4c 16 01          	mov    0x1(%esi,%edx,1),%cl
  800add:	42                   	inc    %edx
  800ade:	38 c8                	cmp    %cl,%al
  800ae0:	74 10                	je     800af2 <memcmp+0x3a>
			return (int) *s1 - (int) *s2;
  800ae2:	0f b6 c0             	movzbl %al,%eax
  800ae5:	0f b6 c9             	movzbl %cl,%ecx
  800ae8:	29 c8                	sub    %ecx,%eax
  800aea:	eb 16                	jmp    800b02 <memcmp+0x4a>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800aec:	4f                   	dec    %edi
  800aed:	ba 00 00 00 00       	mov    $0x0,%edx
  800af2:	39 fa                	cmp    %edi,%edx
  800af4:	75 df                	jne    800ad5 <memcmp+0x1d>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800af6:	b8 00 00 00 00       	mov    $0x0,%eax
  800afb:	eb 05                	jmp    800b02 <memcmp+0x4a>
  800afd:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b02:	5b                   	pop    %ebx
  800b03:	5e                   	pop    %esi
  800b04:	5f                   	pop    %edi
  800b05:	c9                   	leave  
  800b06:	c3                   	ret    

00800b07 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b07:	55                   	push   %ebp
  800b08:	89 e5                	mov    %esp,%ebp
  800b0a:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800b0d:	89 c2                	mov    %eax,%edx
  800b0f:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800b12:	39 d0                	cmp    %edx,%eax
  800b14:	73 12                	jae    800b28 <memfind+0x21>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b16:	8a 4d 0c             	mov    0xc(%ebp),%cl
  800b19:	38 08                	cmp    %cl,(%eax)
  800b1b:	75 06                	jne    800b23 <memfind+0x1c>
  800b1d:	eb 09                	jmp    800b28 <memfind+0x21>
  800b1f:	38 08                	cmp    %cl,(%eax)
  800b21:	74 05                	je     800b28 <memfind+0x21>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800b23:	40                   	inc    %eax
  800b24:	39 c2                	cmp    %eax,%edx
  800b26:	77 f7                	ja     800b1f <memfind+0x18>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800b28:	c9                   	leave  
  800b29:	c3                   	ret    

00800b2a <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b2a:	55                   	push   %ebp
  800b2b:	89 e5                	mov    %esp,%ebp
  800b2d:	57                   	push   %edi
  800b2e:	56                   	push   %esi
  800b2f:	53                   	push   %ebx
  800b30:	8b 55 08             	mov    0x8(%ebp),%edx
  800b33:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b36:	eb 01                	jmp    800b39 <strtol+0xf>
		s++;
  800b38:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b39:	8a 02                	mov    (%edx),%al
  800b3b:	3c 20                	cmp    $0x20,%al
  800b3d:	74 f9                	je     800b38 <strtol+0xe>
  800b3f:	3c 09                	cmp    $0x9,%al
  800b41:	74 f5                	je     800b38 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800b43:	3c 2b                	cmp    $0x2b,%al
  800b45:	75 08                	jne    800b4f <strtol+0x25>
		s++;
  800b47:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800b48:	bf 00 00 00 00       	mov    $0x0,%edi
  800b4d:	eb 13                	jmp    800b62 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800b4f:	3c 2d                	cmp    $0x2d,%al
  800b51:	75 0a                	jne    800b5d <strtol+0x33>
		s++, neg = 1;
  800b53:	8d 52 01             	lea    0x1(%edx),%edx
  800b56:	bf 01 00 00 00       	mov    $0x1,%edi
  800b5b:	eb 05                	jmp    800b62 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800b5d:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b62:	85 db                	test   %ebx,%ebx
  800b64:	74 05                	je     800b6b <strtol+0x41>
  800b66:	83 fb 10             	cmp    $0x10,%ebx
  800b69:	75 28                	jne    800b93 <strtol+0x69>
  800b6b:	8a 02                	mov    (%edx),%al
  800b6d:	3c 30                	cmp    $0x30,%al
  800b6f:	75 10                	jne    800b81 <strtol+0x57>
  800b71:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800b75:	75 0a                	jne    800b81 <strtol+0x57>
		s += 2, base = 16;
  800b77:	83 c2 02             	add    $0x2,%edx
  800b7a:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b7f:	eb 12                	jmp    800b93 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800b81:	85 db                	test   %ebx,%ebx
  800b83:	75 0e                	jne    800b93 <strtol+0x69>
  800b85:	3c 30                	cmp    $0x30,%al
  800b87:	75 05                	jne    800b8e <strtol+0x64>
		s++, base = 8;
  800b89:	42                   	inc    %edx
  800b8a:	b3 08                	mov    $0x8,%bl
  800b8c:	eb 05                	jmp    800b93 <strtol+0x69>
	else if (base == 0)
		base = 10;
  800b8e:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800b93:	b8 00 00 00 00       	mov    $0x0,%eax
  800b98:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800b9a:	8a 0a                	mov    (%edx),%cl
  800b9c:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800b9f:	80 fb 09             	cmp    $0x9,%bl
  800ba2:	77 08                	ja     800bac <strtol+0x82>
			dig = *s - '0';
  800ba4:	0f be c9             	movsbl %cl,%ecx
  800ba7:	83 e9 30             	sub    $0x30,%ecx
  800baa:	eb 1e                	jmp    800bca <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800bac:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800baf:	80 fb 19             	cmp    $0x19,%bl
  800bb2:	77 08                	ja     800bbc <strtol+0x92>
			dig = *s - 'a' + 10;
  800bb4:	0f be c9             	movsbl %cl,%ecx
  800bb7:	83 e9 57             	sub    $0x57,%ecx
  800bba:	eb 0e                	jmp    800bca <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800bbc:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800bbf:	80 fb 19             	cmp    $0x19,%bl
  800bc2:	77 13                	ja     800bd7 <strtol+0xad>
			dig = *s - 'A' + 10;
  800bc4:	0f be c9             	movsbl %cl,%ecx
  800bc7:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800bca:	39 f1                	cmp    %esi,%ecx
  800bcc:	7d 0d                	jge    800bdb <strtol+0xb1>
			break;
		s++, val = (val * base) + dig;
  800bce:	42                   	inc    %edx
  800bcf:	0f af c6             	imul   %esi,%eax
  800bd2:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  800bd5:	eb c3                	jmp    800b9a <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800bd7:	89 c1                	mov    %eax,%ecx
  800bd9:	eb 02                	jmp    800bdd <strtol+0xb3>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800bdb:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800bdd:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800be1:	74 05                	je     800be8 <strtol+0xbe>
		*endptr = (char *) s;
  800be3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800be6:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800be8:	85 ff                	test   %edi,%edi
  800bea:	74 04                	je     800bf0 <strtol+0xc6>
  800bec:	89 c8                	mov    %ecx,%eax
  800bee:	f7 d8                	neg    %eax
}
  800bf0:	5b                   	pop    %ebx
  800bf1:	5e                   	pop    %esi
  800bf2:	5f                   	pop    %edi
  800bf3:	c9                   	leave  
  800bf4:	c3                   	ret    
  800bf5:	00 00                	add    %al,(%eax)
	...

00800bf8 <syscall>:
	return ret;
}

static int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800bf8:	55                   	push   %ebp
  800bf9:	89 e5                	mov    %esp,%ebp
  800bfb:	57                   	push   %edi
  800bfc:	56                   	push   %esi
  800bfd:	53                   	push   %ebx
  800bfe:	83 ec 1c             	sub    $0x1c,%esp
  800c01:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800c04:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800c07:	89 ca                	mov    %ecx,%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c09:	8b 75 14             	mov    0x14(%ebp),%esi
  800c0c:	8b 7d 10             	mov    0x10(%ebp),%edi
  800c0f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800c12:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c15:	cd 30                	int    $0x30
  800c17:	89 c2                	mov    %eax,%edx
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c19:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800c1d:	74 1c                	je     800c3b <syscall+0x43>
  800c1f:	85 c0                	test   %eax,%eax
  800c21:	7e 18                	jle    800c3b <syscall+0x43>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c23:	83 ec 0c             	sub    $0xc,%esp
  800c26:	50                   	push   %eax
  800c27:	ff 75 e4             	pushl  -0x1c(%ebp)
  800c2a:	68 7f 2f 80 00       	push   $0x802f7f
  800c2f:	6a 42                	push   $0x42
  800c31:	68 9c 2f 80 00       	push   $0x802f9c
  800c36:	e8 b1 f5 ff ff       	call   8001ec <_panic>

	return ret;
}
  800c3b:	89 d0                	mov    %edx,%eax
  800c3d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c40:	5b                   	pop    %ebx
  800c41:	5e                   	pop    %esi
  800c42:	5f                   	pop    %edi
  800c43:	c9                   	leave  
  800c44:	c3                   	ret    

00800c45 <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{	
  800c45:	55                   	push   %ebp
  800c46:	89 e5                	mov    %esp,%ebp
  800c48:	83 ec 08             	sub    $0x8,%esp
	// my_sysenter(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
	// return;
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  800c4b:	6a 00                	push   $0x0
  800c4d:	6a 00                	push   $0x0
  800c4f:	6a 00                	push   $0x0
  800c51:	ff 75 0c             	pushl  0xc(%ebp)
  800c54:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c57:	ba 00 00 00 00       	mov    $0x0,%edx
  800c5c:	b8 00 00 00 00       	mov    $0x0,%eax
  800c61:	e8 92 ff ff ff       	call   800bf8 <syscall>
  800c66:	83 c4 10             	add    $0x10,%esp
	return;
}
  800c69:	c9                   	leave  
  800c6a:	c3                   	ret    

00800c6b <sys_cgetc>:

int
sys_cgetc(void)
{
  800c6b:	55                   	push   %ebp
  800c6c:	89 e5                	mov    %esp,%ebp
  800c6e:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_cgetc, 0, 0, 0, 0, 0, 0);
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  800c71:	6a 00                	push   $0x0
  800c73:	6a 00                	push   $0x0
  800c75:	6a 00                	push   $0x0
  800c77:	6a 00                	push   $0x0
  800c79:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c7e:	ba 00 00 00 00       	mov    $0x0,%edx
  800c83:	b8 01 00 00 00       	mov    $0x1,%eax
  800c88:	e8 6b ff ff ff       	call   800bf8 <syscall>
}
  800c8d:	c9                   	leave  
  800c8e:	c3                   	ret    

00800c8f <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800c8f:	55                   	push   %ebp
  800c90:	89 e5                	mov    %esp,%ebp
  800c92:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  800c95:	6a 00                	push   $0x0
  800c97:	6a 00                	push   $0x0
  800c99:	6a 00                	push   $0x0
  800c9b:	6a 00                	push   $0x0
  800c9d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ca0:	ba 01 00 00 00       	mov    $0x1,%edx
  800ca5:	b8 03 00 00 00       	mov    $0x3,%eax
  800caa:	e8 49 ff ff ff       	call   800bf8 <syscall>
}
  800caf:	c9                   	leave  
  800cb0:	c3                   	ret    

00800cb1 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800cb1:	55                   	push   %ebp
  800cb2:	89 e5                	mov    %esp,%ebp
  800cb4:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_getenvid, 0, 0, 0, 0, 0, 0);
	return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  800cb7:	6a 00                	push   $0x0
  800cb9:	6a 00                	push   $0x0
  800cbb:	6a 00                	push   $0x0
  800cbd:	6a 00                	push   $0x0
  800cbf:	b9 00 00 00 00       	mov    $0x0,%ecx
  800cc4:	ba 00 00 00 00       	mov    $0x0,%edx
  800cc9:	b8 02 00 00 00       	mov    $0x2,%eax
  800cce:	e8 25 ff ff ff       	call   800bf8 <syscall>
}
  800cd3:	c9                   	leave  
  800cd4:	c3                   	ret    

00800cd5 <sys_yield>:

void
sys_yield(void)
{
  800cd5:	55                   	push   %ebp
  800cd6:	89 e5                	mov    %esp,%ebp
  800cd8:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  800cdb:	6a 00                	push   $0x0
  800cdd:	6a 00                	push   $0x0
  800cdf:	6a 00                	push   $0x0
  800ce1:	6a 00                	push   $0x0
  800ce3:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ce8:	ba 00 00 00 00       	mov    $0x0,%edx
  800ced:	b8 0b 00 00 00       	mov    $0xb,%eax
  800cf2:	e8 01 ff ff ff       	call   800bf8 <syscall>
  800cf7:	83 c4 10             	add    $0x10,%esp
}
  800cfa:	c9                   	leave  
  800cfb:	c3                   	ret    

00800cfc <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800cfc:	55                   	push   %ebp
  800cfd:	89 e5                	mov    %esp,%ebp
  800cff:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  800d02:	6a 00                	push   $0x0
  800d04:	6a 00                	push   $0x0
  800d06:	ff 75 10             	pushl  0x10(%ebp)
  800d09:	ff 75 0c             	pushl  0xc(%ebp)
  800d0c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d0f:	ba 01 00 00 00       	mov    $0x1,%edx
  800d14:	b8 04 00 00 00       	mov    $0x4,%eax
  800d19:	e8 da fe ff ff       	call   800bf8 <syscall>
}
  800d1e:	c9                   	leave  
  800d1f:	c3                   	ret    

00800d20 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800d20:	55                   	push   %ebp
  800d21:	89 e5                	mov    %esp,%ebp
  800d23:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
  800d26:	ff 75 18             	pushl  0x18(%ebp)
  800d29:	ff 75 14             	pushl  0x14(%ebp)
  800d2c:	ff 75 10             	pushl  0x10(%ebp)
  800d2f:	ff 75 0c             	pushl  0xc(%ebp)
  800d32:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d35:	ba 01 00 00 00       	mov    $0x1,%edx
  800d3a:	b8 05 00 00 00       	mov    $0x5,%eax
  800d3f:	e8 b4 fe ff ff       	call   800bf8 <syscall>
}
  800d44:	c9                   	leave  
  800d45:	c3                   	ret    

00800d46 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800d46:	55                   	push   %ebp
  800d47:	89 e5                	mov    %esp,%ebp
  800d49:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  800d4c:	6a 00                	push   $0x0
  800d4e:	6a 00                	push   $0x0
  800d50:	6a 00                	push   $0x0
  800d52:	ff 75 0c             	pushl  0xc(%ebp)
  800d55:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d58:	ba 01 00 00 00       	mov    $0x1,%edx
  800d5d:	b8 06 00 00 00       	mov    $0x6,%eax
  800d62:	e8 91 fe ff ff       	call   800bf8 <syscall>
}
  800d67:	c9                   	leave  
  800d68:	c3                   	ret    

00800d69 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800d69:	55                   	push   %ebp
  800d6a:	89 e5                	mov    %esp,%ebp
  800d6c:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  800d6f:	6a 00                	push   $0x0
  800d71:	6a 00                	push   $0x0
  800d73:	6a 00                	push   $0x0
  800d75:	ff 75 0c             	pushl  0xc(%ebp)
  800d78:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d7b:	ba 01 00 00 00       	mov    $0x1,%edx
  800d80:	b8 08 00 00 00       	mov    $0x8,%eax
  800d85:	e8 6e fe ff ff       	call   800bf8 <syscall>
}
  800d8a:	c9                   	leave  
  800d8b:	c3                   	ret    

00800d8c <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800d8c:	55                   	push   %ebp
  800d8d:	89 e5                	mov    %esp,%ebp
  800d8f:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
  800d92:	6a 00                	push   $0x0
  800d94:	6a 00                	push   $0x0
  800d96:	6a 00                	push   $0x0
  800d98:	ff 75 0c             	pushl  0xc(%ebp)
  800d9b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d9e:	ba 01 00 00 00       	mov    $0x1,%edx
  800da3:	b8 09 00 00 00       	mov    $0x9,%eax
  800da8:	e8 4b fe ff ff       	call   800bf8 <syscall>
}
  800dad:	c9                   	leave  
  800dae:	c3                   	ret    

00800daf <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800daf:	55                   	push   %ebp
  800db0:	89 e5                	mov    %esp,%ebp
  800db2:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  800db5:	6a 00                	push   $0x0
  800db7:	6a 00                	push   $0x0
  800db9:	6a 00                	push   $0x0
  800dbb:	ff 75 0c             	pushl  0xc(%ebp)
  800dbe:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800dc1:	ba 01 00 00 00       	mov    $0x1,%edx
  800dc6:	b8 0a 00 00 00       	mov    $0xa,%eax
  800dcb:	e8 28 fe ff ff       	call   800bf8 <syscall>
}
  800dd0:	c9                   	leave  
  800dd1:	c3                   	ret    

00800dd2 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800dd2:	55                   	push   %ebp
  800dd3:	89 e5                	mov    %esp,%ebp
  800dd5:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  800dd8:	6a 00                	push   $0x0
  800dda:	ff 75 14             	pushl  0x14(%ebp)
  800ddd:	ff 75 10             	pushl  0x10(%ebp)
  800de0:	ff 75 0c             	pushl  0xc(%ebp)
  800de3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800de6:	ba 00 00 00 00       	mov    $0x0,%edx
  800deb:	b8 0c 00 00 00       	mov    $0xc,%eax
  800df0:	e8 03 fe ff ff       	call   800bf8 <syscall>
}
  800df5:	c9                   	leave  
  800df6:	c3                   	ret    

00800df7 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800df7:	55                   	push   %ebp
  800df8:	89 e5                	mov    %esp,%ebp
  800dfa:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  800dfd:	6a 00                	push   $0x0
  800dff:	6a 00                	push   $0x0
  800e01:	6a 00                	push   $0x0
  800e03:	6a 00                	push   $0x0
  800e05:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e08:	ba 01 00 00 00       	mov    $0x1,%edx
  800e0d:	b8 0d 00 00 00       	mov    $0xd,%eax
  800e12:	e8 e1 fd ff ff       	call   800bf8 <syscall>
}
  800e17:	c9                   	leave  
  800e18:	c3                   	ret    

00800e19 <sys_set_priority>:

int
sys_set_priority(envid_t envid, uint32_t new_priority)
{
  800e19:	55                   	push   %ebp
  800e1a:	89 e5                	mov    %esp,%ebp
  800e1c:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_set_priority, 0, envid, new_priority, 0, 0, 0);
  800e1f:	6a 00                	push   $0x0
  800e21:	6a 00                	push   $0x0
  800e23:	6a 00                	push   $0x0
  800e25:	ff 75 0c             	pushl  0xc(%ebp)
  800e28:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e2b:	ba 00 00 00 00       	mov    $0x0,%edx
  800e30:	b8 0e 00 00 00       	mov    $0xe,%eax
  800e35:	e8 be fd ff ff       	call   800bf8 <syscall>
}
  800e3a:	c9                   	leave  
  800e3b:	c3                   	ret    

00800e3c <sys_exec>:

int
sys_exec(uint32_t eip, uint32_t esp, void * ph, uint32_t elf_phnum)
{
  800e3c:	55                   	push   %ebp
  800e3d:	89 e5                	mov    %esp,%ebp
  800e3f:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_exec, 0, eip, esp, (uint32_t)ph, elf_phnum, 0);
  800e42:	6a 00                	push   $0x0
  800e44:	ff 75 14             	pushl  0x14(%ebp)
  800e47:	ff 75 10             	pushl  0x10(%ebp)
  800e4a:	ff 75 0c             	pushl  0xc(%ebp)
  800e4d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e50:	ba 00 00 00 00       	mov    $0x0,%edx
  800e55:	b8 0f 00 00 00       	mov    $0xf,%eax
  800e5a:	e8 99 fd ff ff       	call   800bf8 <syscall>
} 
  800e5f:	c9                   	leave  
  800e60:	c3                   	ret    

00800e61 <sys_join>:

// thread:
int
sys_join(envid_t envid)
{
  800e61:	55                   	push   %ebp
  800e62:	89 e5                	mov    %esp,%ebp
  800e64:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_join, 0, envid, 0, 0, 0, 0);
  800e67:	6a 00                	push   $0x0
  800e69:	6a 00                	push   $0x0
  800e6b:	6a 00                	push   $0x0
  800e6d:	6a 00                	push   $0x0
  800e6f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e72:	ba 00 00 00 00       	mov    $0x0,%edx
  800e77:	b8 11 00 00 00       	mov    $0x11,%eax
  800e7c:	e8 77 fd ff ff       	call   800bf8 <syscall>
}
  800e81:	c9                   	leave  
  800e82:	c3                   	ret    

00800e83 <sys_getpid>:

envid_t
sys_getpid(void)
{
  800e83:	55                   	push   %ebp
  800e84:	89 e5                	mov    %esp,%ebp
  800e86:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_getpid, 0, 0, 0, 0, 0, 0);
  800e89:	6a 00                	push   $0x0
  800e8b:	6a 00                	push   $0x0
  800e8d:	6a 00                	push   $0x0
  800e8f:	6a 00                	push   $0x0
  800e91:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e96:	ba 00 00 00 00       	mov    $0x0,%edx
  800e9b:	b8 10 00 00 00       	mov    $0x10,%eax
  800ea0:	e8 53 fd ff ff       	call   800bf8 <syscall>
  800ea5:	c9                   	leave  
  800ea6:	c3                   	ret    
	...

00800ea8 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800ea8:	55                   	push   %ebp
  800ea9:	89 e5                	mov    %esp,%ebp
  800eab:	53                   	push   %ebx
  800eac:	83 ec 04             	sub    $0x4,%esp
  800eaf:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800eb2:	8b 18                	mov    (%eax),%ebx

	// LAB 4: Your code here.
	
	// cprintf("PAGE FAULT HANDLER, 0x%08x %d\n", (uint32_t)addr, err & FEC_WR);
	
	if ((err & FEC_WR) == 0)
  800eb4:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800eb8:	75 14                	jne    800ece <pgfault+0x26>
		panic("pgfault, the fault is not a write\n");
  800eba:	83 ec 04             	sub    $0x4,%esp
  800ebd:	68 ac 2f 80 00       	push   $0x802fac
  800ec2:	6a 20                	push   $0x20
  800ec4:	68 f0 30 80 00       	push   $0x8030f0
  800ec9:	e8 1e f3 ff ff       	call   8001ec <_panic>

	uint32_t uaddr = (uint32_t) addr;
	if ((uvpd[PDX(addr)] & PTE_P) == 0 || (uvpt[uaddr / PGSIZE] & PTE_COW) == 0) {
  800ece:	89 d8                	mov    %ebx,%eax
  800ed0:	c1 e8 16             	shr    $0x16,%eax
  800ed3:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800eda:	a8 01                	test   $0x1,%al
  800edc:	74 11                	je     800eef <pgfault+0x47>
  800ede:	89 d8                	mov    %ebx,%eax
  800ee0:	c1 e8 0c             	shr    $0xc,%eax
  800ee3:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800eea:	f6 c4 08             	test   $0x8,%ah
  800eed:	75 14                	jne    800f03 <pgfault+0x5b>
		panic("pgfault, not a copy-on-write page\n");
  800eef:	83 ec 04             	sub    $0x4,%esp
  800ef2:	68 d0 2f 80 00       	push   $0x802fd0
  800ef7:	6a 24                	push   $0x24
  800ef9:	68 f0 30 80 00       	push   $0x8030f0
  800efe:	e8 e9 f2 ff ff       	call   8001ec <_panic>
	//   No need to explicitly delete the old page's mapping.

	// LAB 4: Your code here.

	// static int sys_page_alloc(envid_t envid, void *va, int perm)
	r = sys_page_alloc(0, (void *)PFTEMP, PTE_W | PTE_U | PTE_P);
  800f03:	83 ec 04             	sub    $0x4,%esp
  800f06:	6a 07                	push   $0x7
  800f08:	68 00 f0 7f 00       	push   $0x7ff000
  800f0d:	6a 00                	push   $0x0
  800f0f:	e8 e8 fd ff ff       	call   800cfc <sys_page_alloc>
	if (r < 0) panic("pgfault, sys_page_alloc error : %e\n", r);
  800f14:	83 c4 10             	add    $0x10,%esp
  800f17:	85 c0                	test   %eax,%eax
  800f19:	79 12                	jns    800f2d <pgfault+0x85>
  800f1b:	50                   	push   %eax
  800f1c:	68 f4 2f 80 00       	push   $0x802ff4
  800f21:	6a 32                	push   $0x32
  800f23:	68 f0 30 80 00       	push   $0x8030f0
  800f28:	e8 bf f2 ff ff       	call   8001ec <_panic>

	// Oh my god, I forget this at the first, it waste me a lot of time to debug!!!
	addr = ROUNDDOWN(addr, PGSIZE);
  800f2d:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	
	memcpy(PFTEMP, addr, PGSIZE);
  800f33:	83 ec 04             	sub    $0x4,%esp
  800f36:	68 00 10 00 00       	push   $0x1000
  800f3b:	53                   	push   %ebx
  800f3c:	68 00 f0 7f 00       	push   $0x7ff000
  800f41:	e8 5f fb ff ff       	call   800aa5 <memcpy>
	
	r = sys_page_map(0, PFTEMP, 0, addr, PTE_W | PTE_U | PTE_P);
  800f46:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800f4d:	53                   	push   %ebx
  800f4e:	6a 00                	push   $0x0
  800f50:	68 00 f0 7f 00       	push   $0x7ff000
  800f55:	6a 00                	push   $0x0
  800f57:	e8 c4 fd ff ff       	call   800d20 <sys_page_map>
	if (r < 0) panic("pgfault, sys_page_map error : %e\n", r);
  800f5c:	83 c4 20             	add    $0x20,%esp
  800f5f:	85 c0                	test   %eax,%eax
  800f61:	79 12                	jns    800f75 <pgfault+0xcd>
  800f63:	50                   	push   %eax
  800f64:	68 18 30 80 00       	push   $0x803018
  800f69:	6a 3a                	push   $0x3a
  800f6b:	68 f0 30 80 00       	push   $0x8030f0
  800f70:	e8 77 f2 ff ff       	call   8001ec <_panic>

	return;
}
  800f75:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f78:	c9                   	leave  
  800f79:	c3                   	ret    

00800f7a <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800f7a:	55                   	push   %ebp
  800f7b:	89 e5                	mov    %esp,%ebp
  800f7d:	57                   	push   %edi
  800f7e:	56                   	push   %esi
  800f7f:	53                   	push   %ebx
  800f80:	83 ec 28             	sub    $0x28,%esp
	// static int num = 0x100;

	// LAB 4: Your code here.
	set_pgfault_handler(pgfault);
  800f83:	68 a8 0e 80 00       	push   $0x800ea8
  800f88:	e8 c7 17 00 00       	call   802754 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  800f8d:	ba 07 00 00 00       	mov    $0x7,%edx
  800f92:	89 d0                	mov    %edx,%eax
  800f94:	cd 30                	int    $0x30
  800f96:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800f99:	89 c7                	mov    %eax,%edi
	int childpid = sys_exofork();
	if (childpid < 0) {
  800f9b:	83 c4 10             	add    $0x10,%esp
  800f9e:	85 c0                	test   %eax,%eax
  800fa0:	79 12                	jns    800fb4 <fork+0x3a>
		panic("fork sys_exofork error : %e\n", childpid);
  800fa2:	50                   	push   %eax
  800fa3:	68 fb 30 80 00       	push   $0x8030fb
  800fa8:	6a 7f                	push   $0x7f
  800faa:	68 f0 30 80 00       	push   $0x8030f0
  800faf:	e8 38 f2 ff ff       	call   8001ec <_panic>
	}
	int r;

	if (childpid == 0) {
  800fb4:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800fb8:	75 20                	jne    800fda <fork+0x60>
		// child process
		// Remember to fix "thisenv" in the child process. ??? 
		thisenv = &envs[ENVX(sys_getenvid())];
  800fba:	e8 f2 fc ff ff       	call   800cb1 <sys_getenvid>
  800fbf:	25 ff 03 00 00       	and    $0x3ff,%eax
  800fc4:	89 c2                	mov    %eax,%edx
  800fc6:	c1 e2 07             	shl    $0x7,%edx
  800fc9:	8d 84 82 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,4),%eax
  800fd0:	a3 04 50 80 00       	mov    %eax,0x805004
		// cprintf("fork child ok\n");
		return 0;
  800fd5:	e9 be 01 00 00       	jmp    801198 <fork+0x21e>
	if (childpid < 0) {
		panic("fork sys_exofork error : %e\n", childpid);
	}
	int r;

	if (childpid == 0) {
  800fda:	bb 00 00 00 00       	mov    $0x0,%ebx
	} else {
		// map page to new environment
		// kernel page is already in new environment
		uint32_t i;
		for (i = 0; i != UTOP; i += PGSIZE) 
		if ((uvpd[PDX(i)] & PTE_P) && (uvpt[i / PGSIZE] & PTE_P) && (uvpt[i / PGSIZE] & PTE_U)) {
  800fdf:	89 d8                	mov    %ebx,%eax
  800fe1:	c1 e8 16             	shr    $0x16,%eax
  800fe4:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800feb:	a8 01                	test   $0x1,%al
  800fed:	0f 84 10 01 00 00    	je     801103 <fork+0x189>
  800ff3:	89 d8                	mov    %ebx,%eax
  800ff5:	c1 e8 0c             	shr    $0xc,%eax
  800ff8:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800fff:	f6 c2 01             	test   $0x1,%dl
  801002:	0f 84 fb 00 00 00    	je     801103 <fork+0x189>
  801008:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80100f:	f6 c2 04             	test   $0x4,%dl
  801012:	0f 84 eb 00 00 00    	je     801103 <fork+0x189>
//
static int
duppage(envid_t envid, unsigned pn)
{
	// do not dup exception stack
	if (pn * PGSIZE == UXSTACKTOP - PGSIZE) return 0;
  801018:	89 c6                	mov    %eax,%esi
  80101a:	c1 e6 0c             	shl    $0xc,%esi
  80101d:	81 fe 00 f0 bf ee    	cmp    $0xeebff000,%esi
  801023:	0f 84 da 00 00 00    	je     801103 <fork+0x189>

	int r;
	void * addr = (void *)(pn * PGSIZE);
    if (uvpt[pn] & PTE_SHARE) {
  801029:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801030:	f6 c6 04             	test   $0x4,%dh
  801033:	74 37                	je     80106c <fork+0xf2>
        r = sys_page_map(0, addr, envid, addr, uvpt[pn] & PTE_SYSCALL);
  801035:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80103c:	83 ec 0c             	sub    $0xc,%esp
  80103f:	25 07 0e 00 00       	and    $0xe07,%eax
  801044:	50                   	push   %eax
  801045:	56                   	push   %esi
  801046:	57                   	push   %edi
  801047:	56                   	push   %esi
  801048:	6a 00                	push   $0x0
  80104a:	e8 d1 fc ff ff       	call   800d20 <sys_page_map>
        if (r < 0) panic("duppage sys_page_map error : %e\n", r);
  80104f:	83 c4 20             	add    $0x20,%esp
  801052:	85 c0                	test   %eax,%eax
  801054:	0f 89 a9 00 00 00    	jns    801103 <fork+0x189>
  80105a:	50                   	push   %eax
  80105b:	68 3c 30 80 00       	push   $0x80303c
  801060:	6a 54                	push   $0x54
  801062:	68 f0 30 80 00       	push   $0x8030f0
  801067:	e8 80 f1 ff ff       	call   8001ec <_panic>
    } else
	if ((uvpt[pn] & PTE_W) || (uvpt[pn] & PTE_COW)) {
  80106c:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801073:	f6 c2 02             	test   $0x2,%dl
  801076:	75 0c                	jne    801084 <fork+0x10a>
  801078:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80107f:	f6 c4 08             	test   $0x8,%ah
  801082:	74 57                	je     8010db <fork+0x161>
		// cow
		r = sys_page_map(0, addr, envid, addr, PTE_COW | PTE_P | PTE_U);
  801084:	83 ec 0c             	sub    $0xc,%esp
  801087:	68 05 08 00 00       	push   $0x805
  80108c:	56                   	push   %esi
  80108d:	57                   	push   %edi
  80108e:	56                   	push   %esi
  80108f:	6a 00                	push   $0x0
  801091:	e8 8a fc ff ff       	call   800d20 <sys_page_map>
		if (r < 0) panic("duppage sys_page_map error : %e\n", r);
  801096:	83 c4 20             	add    $0x20,%esp
  801099:	85 c0                	test   %eax,%eax
  80109b:	79 12                	jns    8010af <fork+0x135>
  80109d:	50                   	push   %eax
  80109e:	68 3c 30 80 00       	push   $0x80303c
  8010a3:	6a 59                	push   $0x59
  8010a5:	68 f0 30 80 00       	push   $0x8030f0
  8010aa:	e8 3d f1 ff ff       	call   8001ec <_panic>
		
		r = sys_page_map(0, addr, 0, addr, PTE_COW | PTE_P | PTE_U);
  8010af:	83 ec 0c             	sub    $0xc,%esp
  8010b2:	68 05 08 00 00       	push   $0x805
  8010b7:	56                   	push   %esi
  8010b8:	6a 00                	push   $0x0
  8010ba:	56                   	push   %esi
  8010bb:	6a 00                	push   $0x0
  8010bd:	e8 5e fc ff ff       	call   800d20 <sys_page_map>
		if (r < 0) panic("duppage sys_page_map error : %e\n", r);
  8010c2:	83 c4 20             	add    $0x20,%esp
  8010c5:	85 c0                	test   %eax,%eax
  8010c7:	79 3a                	jns    801103 <fork+0x189>
  8010c9:	50                   	push   %eax
  8010ca:	68 3c 30 80 00       	push   $0x80303c
  8010cf:	6a 5c                	push   $0x5c
  8010d1:	68 f0 30 80 00       	push   $0x8030f0
  8010d6:	e8 11 f1 ff ff       	call   8001ec <_panic>
	} else {
		// read only
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U);
  8010db:	83 ec 0c             	sub    $0xc,%esp
  8010de:	6a 05                	push   $0x5
  8010e0:	56                   	push   %esi
  8010e1:	57                   	push   %edi
  8010e2:	56                   	push   %esi
  8010e3:	6a 00                	push   $0x0
  8010e5:	e8 36 fc ff ff       	call   800d20 <sys_page_map>
		if (r < 0) panic("duppage sys_page_map error : %e\n", r);
  8010ea:	83 c4 20             	add    $0x20,%esp
  8010ed:	85 c0                	test   %eax,%eax
  8010ef:	79 12                	jns    801103 <fork+0x189>
  8010f1:	50                   	push   %eax
  8010f2:	68 3c 30 80 00       	push   $0x80303c
  8010f7:	6a 60                	push   $0x60
  8010f9:	68 f0 30 80 00       	push   $0x8030f0
  8010fe:	e8 e9 f0 ff ff       	call   8001ec <_panic>
		return 0;
	} else {
		// map page to new environment
		// kernel page is already in new environment
		uint32_t i;
		for (i = 0; i != UTOP; i += PGSIZE) 
  801103:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801109:	81 fb 00 00 c0 ee    	cmp    $0xeec00000,%ebx
  80110f:	0f 85 ca fe ff ff    	jne    800fdf <fork+0x65>
		if ((uvpd[PDX(i)] & PTE_P) && (uvpt[i / PGSIZE] & PTE_P) && (uvpt[i / PGSIZE] & PTE_U)) {
			duppage(childpid, i / PGSIZE);
		}

		// allocate exception stack
		r = sys_page_alloc(childpid, (void *)(UXSTACKTOP - PGSIZE), PTE_U | PTE_W | PTE_P);
  801115:	83 ec 04             	sub    $0x4,%esp
  801118:	6a 07                	push   $0x7
  80111a:	68 00 f0 bf ee       	push   $0xeebff000
  80111f:	ff 75 e4             	pushl  -0x1c(%ebp)
  801122:	e8 d5 fb ff ff       	call   800cfc <sys_page_alloc>
		if (r < 0) panic("fork, sys_page_alloc user exception stack error : %e\n", r);
  801127:	83 c4 10             	add    $0x10,%esp
  80112a:	85 c0                	test   %eax,%eax
  80112c:	79 15                	jns    801143 <fork+0x1c9>
  80112e:	50                   	push   %eax
  80112f:	68 60 30 80 00       	push   $0x803060
  801134:	68 94 00 00 00       	push   $0x94
  801139:	68 f0 30 80 00       	push   $0x8030f0
  80113e:	e8 a9 f0 ff ff       	call   8001ec <_panic>

		// set user environment user page fault handler 
		extern void _pgfault_upcall(void);
		r = sys_env_set_pgfault_upcall(childpid, _pgfault_upcall);
  801143:	83 ec 08             	sub    $0x8,%esp
  801146:	68 c0 27 80 00       	push   $0x8027c0
  80114b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80114e:	e8 5c fc ff ff       	call   800daf <sys_env_set_pgfault_upcall>
		if (r < 0) panic("fork, set pgfault upcall fail : %e\n", r);
  801153:	83 c4 10             	add    $0x10,%esp
  801156:	85 c0                	test   %eax,%eax
  801158:	79 15                	jns    80116f <fork+0x1f5>
  80115a:	50                   	push   %eax
  80115b:	68 98 30 80 00       	push   $0x803098
  801160:	68 99 00 00 00       	push   $0x99
  801165:	68 f0 30 80 00       	push   $0x8030f0
  80116a:	e8 7d f0 ff ff       	call   8001ec <_panic>
		r = sys_set_priority(childpid, num);
		if (r < 0) panic("fork, set priority error\n");
		*/

		// mark the child as runnable and return
		r = sys_env_set_status(childpid, ENV_RUNNABLE);
  80116f:	83 ec 08             	sub    $0x8,%esp
  801172:	6a 02                	push   $0x2
  801174:	ff 75 e4             	pushl  -0x1c(%ebp)
  801177:	e8 ed fb ff ff       	call   800d69 <sys_env_set_status>
		if (r < 0) panic("fork, set child process to ENV_RUNNABLE error : %e\n", r);
  80117c:	83 c4 10             	add    $0x10,%esp
  80117f:	85 c0                	test   %eax,%eax
  801181:	79 15                	jns    801198 <fork+0x21e>
  801183:	50                   	push   %eax
  801184:	68 bc 30 80 00       	push   $0x8030bc
  801189:	68 a4 00 00 00       	push   $0xa4
  80118e:	68 f0 30 80 00       	push   $0x8030f0
  801193:	e8 54 f0 ff ff       	call   8001ec <_panic>
		// cprintf("fork father ok!")
		return childpid;
	}

	panic("fork not implemented");
}
  801198:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80119b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80119e:	5b                   	pop    %ebx
  80119f:	5e                   	pop    %esi
  8011a0:	5f                   	pop    %edi
  8011a1:	c9                   	leave  
  8011a2:	c3                   	ret    

008011a3 <sfork>:

// Challenge!
int
sfork(void)
{
  8011a3:	55                   	push   %ebp
  8011a4:	89 e5                	mov    %esp,%ebp
  8011a6:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  8011a9:	68 18 31 80 00       	push   $0x803118
  8011ae:	68 b1 00 00 00       	push   $0xb1
  8011b3:	68 f0 30 80 00       	push   $0x8030f0
  8011b8:	e8 2f f0 ff ff       	call   8001ec <_panic>
  8011bd:	00 00                	add    %al,(%eax)
	...

008011c0 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8011c0:	55                   	push   %ebp
  8011c1:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8011c3:	8b 45 08             	mov    0x8(%ebp),%eax
  8011c6:	05 00 00 00 30       	add    $0x30000000,%eax
  8011cb:	c1 e8 0c             	shr    $0xc,%eax
}
  8011ce:	c9                   	leave  
  8011cf:	c3                   	ret    

008011d0 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8011d0:	55                   	push   %ebp
  8011d1:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  8011d3:	ff 75 08             	pushl  0x8(%ebp)
  8011d6:	e8 e5 ff ff ff       	call   8011c0 <fd2num>
  8011db:	83 c4 04             	add    $0x4,%esp
  8011de:	05 20 00 0d 00       	add    $0xd0020,%eax
  8011e3:	c1 e0 0c             	shl    $0xc,%eax
}
  8011e6:	c9                   	leave  
  8011e7:	c3                   	ret    

008011e8 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8011e8:	55                   	push   %ebp
  8011e9:	89 e5                	mov    %esp,%ebp
  8011eb:	53                   	push   %ebx
  8011ec:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8011ef:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  8011f4:	a8 01                	test   $0x1,%al
  8011f6:	74 34                	je     80122c <fd_alloc+0x44>
  8011f8:	a1 00 00 74 ef       	mov    0xef740000,%eax
  8011fd:	a8 01                	test   $0x1,%al
  8011ff:	74 32                	je     801233 <fd_alloc+0x4b>
  801201:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
  801206:	89 c1                	mov    %eax,%ecx
  801208:	89 c2                	mov    %eax,%edx
  80120a:	c1 ea 16             	shr    $0x16,%edx
  80120d:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801214:	f6 c2 01             	test   $0x1,%dl
  801217:	74 1f                	je     801238 <fd_alloc+0x50>
  801219:	89 c2                	mov    %eax,%edx
  80121b:	c1 ea 0c             	shr    $0xc,%edx
  80121e:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801225:	f6 c2 01             	test   $0x1,%dl
  801228:	75 17                	jne    801241 <fd_alloc+0x59>
  80122a:	eb 0c                	jmp    801238 <fd_alloc+0x50>
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  80122c:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
  801231:	eb 05                	jmp    801238 <fd_alloc+0x50>
  801233:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
  801238:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  80123a:	b8 00 00 00 00       	mov    $0x0,%eax
  80123f:	eb 17                	jmp    801258 <fd_alloc+0x70>
  801241:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801246:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80124b:	75 b9                	jne    801206 <fd_alloc+0x1e>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  80124d:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  801253:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801258:	5b                   	pop    %ebx
  801259:	c9                   	leave  
  80125a:	c3                   	ret    

0080125b <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80125b:	55                   	push   %ebp
  80125c:	89 e5                	mov    %esp,%ebp
  80125e:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801261:	83 f8 1f             	cmp    $0x1f,%eax
  801264:	77 36                	ja     80129c <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801266:	05 00 00 0d 00       	add    $0xd0000,%eax
  80126b:	c1 e0 0c             	shl    $0xc,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80126e:	89 c2                	mov    %eax,%edx
  801270:	c1 ea 16             	shr    $0x16,%edx
  801273:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80127a:	f6 c2 01             	test   $0x1,%dl
  80127d:	74 24                	je     8012a3 <fd_lookup+0x48>
  80127f:	89 c2                	mov    %eax,%edx
  801281:	c1 ea 0c             	shr    $0xc,%edx
  801284:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80128b:	f6 c2 01             	test   $0x1,%dl
  80128e:	74 1a                	je     8012aa <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801290:	8b 55 0c             	mov    0xc(%ebp),%edx
  801293:	89 02                	mov    %eax,(%edx)
	return 0;
  801295:	b8 00 00 00 00       	mov    $0x0,%eax
  80129a:	eb 13                	jmp    8012af <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80129c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012a1:	eb 0c                	jmp    8012af <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8012a3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012a8:	eb 05                	jmp    8012af <fd_lookup+0x54>
  8012aa:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8012af:	c9                   	leave  
  8012b0:	c3                   	ret    

008012b1 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8012b1:	55                   	push   %ebp
  8012b2:	89 e5                	mov    %esp,%ebp
  8012b4:	53                   	push   %ebx
  8012b5:	83 ec 04             	sub    $0x4,%esp
  8012b8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8012bb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  8012be:	39 0d 0c 40 80 00    	cmp    %ecx,0x80400c
  8012c4:	74 0d                	je     8012d3 <dev_lookup+0x22>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8012c6:	b8 00 00 00 00       	mov    $0x0,%eax
  8012cb:	eb 14                	jmp    8012e1 <dev_lookup+0x30>
		if (devtab[i]->dev_id == dev_id) {
  8012cd:	39 0a                	cmp    %ecx,(%edx)
  8012cf:	75 10                	jne    8012e1 <dev_lookup+0x30>
  8012d1:	eb 05                	jmp    8012d8 <dev_lookup+0x27>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8012d3:	ba 0c 40 80 00       	mov    $0x80400c,%edx
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
  8012d8:	89 13                	mov    %edx,(%ebx)
			return 0;
  8012da:	b8 00 00 00 00       	mov    $0x0,%eax
  8012df:	eb 31                	jmp    801312 <dev_lookup+0x61>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8012e1:	40                   	inc    %eax
  8012e2:	8b 14 85 ac 31 80 00 	mov    0x8031ac(,%eax,4),%edx
  8012e9:	85 d2                	test   %edx,%edx
  8012eb:	75 e0                	jne    8012cd <dev_lookup+0x1c>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8012ed:	a1 04 50 80 00       	mov    0x805004,%eax
  8012f2:	8b 40 48             	mov    0x48(%eax),%eax
  8012f5:	83 ec 04             	sub    $0x4,%esp
  8012f8:	51                   	push   %ecx
  8012f9:	50                   	push   %eax
  8012fa:	68 30 31 80 00       	push   $0x803130
  8012ff:	e8 c0 ef ff ff       	call   8002c4 <cprintf>
	*dev = 0;
  801304:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  80130a:	83 c4 10             	add    $0x10,%esp
  80130d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801312:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801315:	c9                   	leave  
  801316:	c3                   	ret    

00801317 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801317:	55                   	push   %ebp
  801318:	89 e5                	mov    %esp,%ebp
  80131a:	56                   	push   %esi
  80131b:	53                   	push   %ebx
  80131c:	83 ec 20             	sub    $0x20,%esp
  80131f:	8b 75 08             	mov    0x8(%ebp),%esi
  801322:	8a 45 0c             	mov    0xc(%ebp),%al
  801325:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801328:	56                   	push   %esi
  801329:	e8 92 fe ff ff       	call   8011c0 <fd2num>
  80132e:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801331:	89 14 24             	mov    %edx,(%esp)
  801334:	50                   	push   %eax
  801335:	e8 21 ff ff ff       	call   80125b <fd_lookup>
  80133a:	89 c3                	mov    %eax,%ebx
  80133c:	83 c4 08             	add    $0x8,%esp
  80133f:	85 c0                	test   %eax,%eax
  801341:	78 05                	js     801348 <fd_close+0x31>
	    || fd != fd2)
  801343:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801346:	74 0d                	je     801355 <fd_close+0x3e>
		return (must_exist ? r : 0);
  801348:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  80134c:	75 48                	jne    801396 <fd_close+0x7f>
  80134e:	bb 00 00 00 00       	mov    $0x0,%ebx
  801353:	eb 41                	jmp    801396 <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801355:	83 ec 08             	sub    $0x8,%esp
  801358:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80135b:	50                   	push   %eax
  80135c:	ff 36                	pushl  (%esi)
  80135e:	e8 4e ff ff ff       	call   8012b1 <dev_lookup>
  801363:	89 c3                	mov    %eax,%ebx
  801365:	83 c4 10             	add    $0x10,%esp
  801368:	85 c0                	test   %eax,%eax
  80136a:	78 1c                	js     801388 <fd_close+0x71>
		if (dev->dev_close)
  80136c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80136f:	8b 40 10             	mov    0x10(%eax),%eax
  801372:	85 c0                	test   %eax,%eax
  801374:	74 0d                	je     801383 <fd_close+0x6c>
			r = (*dev->dev_close)(fd);
  801376:	83 ec 0c             	sub    $0xc,%esp
  801379:	56                   	push   %esi
  80137a:	ff d0                	call   *%eax
  80137c:	89 c3                	mov    %eax,%ebx
  80137e:	83 c4 10             	add    $0x10,%esp
  801381:	eb 05                	jmp    801388 <fd_close+0x71>
		else
			r = 0;
  801383:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801388:	83 ec 08             	sub    $0x8,%esp
  80138b:	56                   	push   %esi
  80138c:	6a 00                	push   $0x0
  80138e:	e8 b3 f9 ff ff       	call   800d46 <sys_page_unmap>
	return r;
  801393:	83 c4 10             	add    $0x10,%esp
}
  801396:	89 d8                	mov    %ebx,%eax
  801398:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80139b:	5b                   	pop    %ebx
  80139c:	5e                   	pop    %esi
  80139d:	c9                   	leave  
  80139e:	c3                   	ret    

0080139f <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80139f:	55                   	push   %ebp
  8013a0:	89 e5                	mov    %esp,%ebp
  8013a2:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8013a5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013a8:	50                   	push   %eax
  8013a9:	ff 75 08             	pushl  0x8(%ebp)
  8013ac:	e8 aa fe ff ff       	call   80125b <fd_lookup>
  8013b1:	83 c4 08             	add    $0x8,%esp
  8013b4:	85 c0                	test   %eax,%eax
  8013b6:	78 10                	js     8013c8 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  8013b8:	83 ec 08             	sub    $0x8,%esp
  8013bb:	6a 01                	push   $0x1
  8013bd:	ff 75 f4             	pushl  -0xc(%ebp)
  8013c0:	e8 52 ff ff ff       	call   801317 <fd_close>
  8013c5:	83 c4 10             	add    $0x10,%esp
}
  8013c8:	c9                   	leave  
  8013c9:	c3                   	ret    

008013ca <close_all>:

void
close_all(void)
{
  8013ca:	55                   	push   %ebp
  8013cb:	89 e5                	mov    %esp,%ebp
  8013cd:	53                   	push   %ebx
  8013ce:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8013d1:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8013d6:	83 ec 0c             	sub    $0xc,%esp
  8013d9:	53                   	push   %ebx
  8013da:	e8 c0 ff ff ff       	call   80139f <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8013df:	43                   	inc    %ebx
  8013e0:	83 c4 10             	add    $0x10,%esp
  8013e3:	83 fb 20             	cmp    $0x20,%ebx
  8013e6:	75 ee                	jne    8013d6 <close_all+0xc>
		close(i);
}
  8013e8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013eb:	c9                   	leave  
  8013ec:	c3                   	ret    

008013ed <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8013ed:	55                   	push   %ebp
  8013ee:	89 e5                	mov    %esp,%ebp
  8013f0:	57                   	push   %edi
  8013f1:	56                   	push   %esi
  8013f2:	53                   	push   %ebx
  8013f3:	83 ec 2c             	sub    $0x2c,%esp
  8013f6:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8013f9:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8013fc:	50                   	push   %eax
  8013fd:	ff 75 08             	pushl  0x8(%ebp)
  801400:	e8 56 fe ff ff       	call   80125b <fd_lookup>
  801405:	89 c3                	mov    %eax,%ebx
  801407:	83 c4 08             	add    $0x8,%esp
  80140a:	85 c0                	test   %eax,%eax
  80140c:	0f 88 c0 00 00 00    	js     8014d2 <dup+0xe5>
		return r;
	close(newfdnum);
  801412:	83 ec 0c             	sub    $0xc,%esp
  801415:	57                   	push   %edi
  801416:	e8 84 ff ff ff       	call   80139f <close>

	newfd = INDEX2FD(newfdnum);
  80141b:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  801421:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  801424:	83 c4 04             	add    $0x4,%esp
  801427:	ff 75 e4             	pushl  -0x1c(%ebp)
  80142a:	e8 a1 fd ff ff       	call   8011d0 <fd2data>
  80142f:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801431:	89 34 24             	mov    %esi,(%esp)
  801434:	e8 97 fd ff ff       	call   8011d0 <fd2data>
  801439:	83 c4 10             	add    $0x10,%esp
  80143c:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80143f:	89 d8                	mov    %ebx,%eax
  801441:	c1 e8 16             	shr    $0x16,%eax
  801444:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80144b:	a8 01                	test   $0x1,%al
  80144d:	74 37                	je     801486 <dup+0x99>
  80144f:	89 d8                	mov    %ebx,%eax
  801451:	c1 e8 0c             	shr    $0xc,%eax
  801454:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80145b:	f6 c2 01             	test   $0x1,%dl
  80145e:	74 26                	je     801486 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801460:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801467:	83 ec 0c             	sub    $0xc,%esp
  80146a:	25 07 0e 00 00       	and    $0xe07,%eax
  80146f:	50                   	push   %eax
  801470:	ff 75 d4             	pushl  -0x2c(%ebp)
  801473:	6a 00                	push   $0x0
  801475:	53                   	push   %ebx
  801476:	6a 00                	push   $0x0
  801478:	e8 a3 f8 ff ff       	call   800d20 <sys_page_map>
  80147d:	89 c3                	mov    %eax,%ebx
  80147f:	83 c4 20             	add    $0x20,%esp
  801482:	85 c0                	test   %eax,%eax
  801484:	78 2d                	js     8014b3 <dup+0xc6>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801486:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801489:	89 c2                	mov    %eax,%edx
  80148b:	c1 ea 0c             	shr    $0xc,%edx
  80148e:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801495:	83 ec 0c             	sub    $0xc,%esp
  801498:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  80149e:	52                   	push   %edx
  80149f:	56                   	push   %esi
  8014a0:	6a 00                	push   $0x0
  8014a2:	50                   	push   %eax
  8014a3:	6a 00                	push   $0x0
  8014a5:	e8 76 f8 ff ff       	call   800d20 <sys_page_map>
  8014aa:	89 c3                	mov    %eax,%ebx
  8014ac:	83 c4 20             	add    $0x20,%esp
  8014af:	85 c0                	test   %eax,%eax
  8014b1:	79 1d                	jns    8014d0 <dup+0xe3>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8014b3:	83 ec 08             	sub    $0x8,%esp
  8014b6:	56                   	push   %esi
  8014b7:	6a 00                	push   $0x0
  8014b9:	e8 88 f8 ff ff       	call   800d46 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8014be:	83 c4 08             	add    $0x8,%esp
  8014c1:	ff 75 d4             	pushl  -0x2c(%ebp)
  8014c4:	6a 00                	push   $0x0
  8014c6:	e8 7b f8 ff ff       	call   800d46 <sys_page_unmap>
	return r;
  8014cb:	83 c4 10             	add    $0x10,%esp
  8014ce:	eb 02                	jmp    8014d2 <dup+0xe5>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  8014d0:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  8014d2:	89 d8                	mov    %ebx,%eax
  8014d4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8014d7:	5b                   	pop    %ebx
  8014d8:	5e                   	pop    %esi
  8014d9:	5f                   	pop    %edi
  8014da:	c9                   	leave  
  8014db:	c3                   	ret    

008014dc <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8014dc:	55                   	push   %ebp
  8014dd:	89 e5                	mov    %esp,%ebp
  8014df:	53                   	push   %ebx
  8014e0:	83 ec 14             	sub    $0x14,%esp
  8014e3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8014e6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014e9:	50                   	push   %eax
  8014ea:	53                   	push   %ebx
  8014eb:	e8 6b fd ff ff       	call   80125b <fd_lookup>
  8014f0:	83 c4 08             	add    $0x8,%esp
  8014f3:	85 c0                	test   %eax,%eax
  8014f5:	78 67                	js     80155e <read+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014f7:	83 ec 08             	sub    $0x8,%esp
  8014fa:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014fd:	50                   	push   %eax
  8014fe:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801501:	ff 30                	pushl  (%eax)
  801503:	e8 a9 fd ff ff       	call   8012b1 <dev_lookup>
  801508:	83 c4 10             	add    $0x10,%esp
  80150b:	85 c0                	test   %eax,%eax
  80150d:	78 4f                	js     80155e <read+0x82>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80150f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801512:	8b 50 08             	mov    0x8(%eax),%edx
  801515:	83 e2 03             	and    $0x3,%edx
  801518:	83 fa 01             	cmp    $0x1,%edx
  80151b:	75 21                	jne    80153e <read+0x62>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80151d:	a1 04 50 80 00       	mov    0x805004,%eax
  801522:	8b 40 48             	mov    0x48(%eax),%eax
  801525:	83 ec 04             	sub    $0x4,%esp
  801528:	53                   	push   %ebx
  801529:	50                   	push   %eax
  80152a:	68 71 31 80 00       	push   $0x803171
  80152f:	e8 90 ed ff ff       	call   8002c4 <cprintf>
		return -E_INVAL;
  801534:	83 c4 10             	add    $0x10,%esp
  801537:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80153c:	eb 20                	jmp    80155e <read+0x82>
	}
	if (!dev->dev_read)
  80153e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801541:	8b 52 08             	mov    0x8(%edx),%edx
  801544:	85 d2                	test   %edx,%edx
  801546:	74 11                	je     801559 <read+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801548:	83 ec 04             	sub    $0x4,%esp
  80154b:	ff 75 10             	pushl  0x10(%ebp)
  80154e:	ff 75 0c             	pushl  0xc(%ebp)
  801551:	50                   	push   %eax
  801552:	ff d2                	call   *%edx
  801554:	83 c4 10             	add    $0x10,%esp
  801557:	eb 05                	jmp    80155e <read+0x82>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801559:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  80155e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801561:	c9                   	leave  
  801562:	c3                   	ret    

00801563 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801563:	55                   	push   %ebp
  801564:	89 e5                	mov    %esp,%ebp
  801566:	57                   	push   %edi
  801567:	56                   	push   %esi
  801568:	53                   	push   %ebx
  801569:	83 ec 0c             	sub    $0xc,%esp
  80156c:	8b 7d 08             	mov    0x8(%ebp),%edi
  80156f:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801572:	85 f6                	test   %esi,%esi
  801574:	74 31                	je     8015a7 <readn+0x44>
  801576:	b8 00 00 00 00       	mov    $0x0,%eax
  80157b:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = read(fdnum, (char*)buf + tot, n - tot);
  801580:	83 ec 04             	sub    $0x4,%esp
  801583:	89 f2                	mov    %esi,%edx
  801585:	29 c2                	sub    %eax,%edx
  801587:	52                   	push   %edx
  801588:	03 45 0c             	add    0xc(%ebp),%eax
  80158b:	50                   	push   %eax
  80158c:	57                   	push   %edi
  80158d:	e8 4a ff ff ff       	call   8014dc <read>
		if (m < 0)
  801592:	83 c4 10             	add    $0x10,%esp
  801595:	85 c0                	test   %eax,%eax
  801597:	78 17                	js     8015b0 <readn+0x4d>
			return m;
		if (m == 0)
  801599:	85 c0                	test   %eax,%eax
  80159b:	74 11                	je     8015ae <readn+0x4b>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80159d:	01 c3                	add    %eax,%ebx
  80159f:	89 d8                	mov    %ebx,%eax
  8015a1:	39 f3                	cmp    %esi,%ebx
  8015a3:	72 db                	jb     801580 <readn+0x1d>
  8015a5:	eb 09                	jmp    8015b0 <readn+0x4d>
  8015a7:	b8 00 00 00 00       	mov    $0x0,%eax
  8015ac:	eb 02                	jmp    8015b0 <readn+0x4d>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  8015ae:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  8015b0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8015b3:	5b                   	pop    %ebx
  8015b4:	5e                   	pop    %esi
  8015b5:	5f                   	pop    %edi
  8015b6:	c9                   	leave  
  8015b7:	c3                   	ret    

008015b8 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8015b8:	55                   	push   %ebp
  8015b9:	89 e5                	mov    %esp,%ebp
  8015bb:	53                   	push   %ebx
  8015bc:	83 ec 14             	sub    $0x14,%esp
  8015bf:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015c2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015c5:	50                   	push   %eax
  8015c6:	53                   	push   %ebx
  8015c7:	e8 8f fc ff ff       	call   80125b <fd_lookup>
  8015cc:	83 c4 08             	add    $0x8,%esp
  8015cf:	85 c0                	test   %eax,%eax
  8015d1:	78 62                	js     801635 <write+0x7d>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015d3:	83 ec 08             	sub    $0x8,%esp
  8015d6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015d9:	50                   	push   %eax
  8015da:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015dd:	ff 30                	pushl  (%eax)
  8015df:	e8 cd fc ff ff       	call   8012b1 <dev_lookup>
  8015e4:	83 c4 10             	add    $0x10,%esp
  8015e7:	85 c0                	test   %eax,%eax
  8015e9:	78 4a                	js     801635 <write+0x7d>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8015eb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015ee:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8015f2:	75 21                	jne    801615 <write+0x5d>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8015f4:	a1 04 50 80 00       	mov    0x805004,%eax
  8015f9:	8b 40 48             	mov    0x48(%eax),%eax
  8015fc:	83 ec 04             	sub    $0x4,%esp
  8015ff:	53                   	push   %ebx
  801600:	50                   	push   %eax
  801601:	68 8d 31 80 00       	push   $0x80318d
  801606:	e8 b9 ec ff ff       	call   8002c4 <cprintf>
		return -E_INVAL;
  80160b:	83 c4 10             	add    $0x10,%esp
  80160e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801613:	eb 20                	jmp    801635 <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801615:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801618:	8b 52 0c             	mov    0xc(%edx),%edx
  80161b:	85 d2                	test   %edx,%edx
  80161d:	74 11                	je     801630 <write+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80161f:	83 ec 04             	sub    $0x4,%esp
  801622:	ff 75 10             	pushl  0x10(%ebp)
  801625:	ff 75 0c             	pushl  0xc(%ebp)
  801628:	50                   	push   %eax
  801629:	ff d2                	call   *%edx
  80162b:	83 c4 10             	add    $0x10,%esp
  80162e:	eb 05                	jmp    801635 <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801630:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  801635:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801638:	c9                   	leave  
  801639:	c3                   	ret    

0080163a <seek>:

int
seek(int fdnum, off_t offset)
{
  80163a:	55                   	push   %ebp
  80163b:	89 e5                	mov    %esp,%ebp
  80163d:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801640:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801643:	50                   	push   %eax
  801644:	ff 75 08             	pushl  0x8(%ebp)
  801647:	e8 0f fc ff ff       	call   80125b <fd_lookup>
  80164c:	83 c4 08             	add    $0x8,%esp
  80164f:	85 c0                	test   %eax,%eax
  801651:	78 0e                	js     801661 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801653:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801656:	8b 55 0c             	mov    0xc(%ebp),%edx
  801659:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80165c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801661:	c9                   	leave  
  801662:	c3                   	ret    

00801663 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801663:	55                   	push   %ebp
  801664:	89 e5                	mov    %esp,%ebp
  801666:	53                   	push   %ebx
  801667:	83 ec 14             	sub    $0x14,%esp
  80166a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80166d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801670:	50                   	push   %eax
  801671:	53                   	push   %ebx
  801672:	e8 e4 fb ff ff       	call   80125b <fd_lookup>
  801677:	83 c4 08             	add    $0x8,%esp
  80167a:	85 c0                	test   %eax,%eax
  80167c:	78 5f                	js     8016dd <ftruncate+0x7a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80167e:	83 ec 08             	sub    $0x8,%esp
  801681:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801684:	50                   	push   %eax
  801685:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801688:	ff 30                	pushl  (%eax)
  80168a:	e8 22 fc ff ff       	call   8012b1 <dev_lookup>
  80168f:	83 c4 10             	add    $0x10,%esp
  801692:	85 c0                	test   %eax,%eax
  801694:	78 47                	js     8016dd <ftruncate+0x7a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801696:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801699:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80169d:	75 21                	jne    8016c0 <ftruncate+0x5d>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80169f:	a1 04 50 80 00       	mov    0x805004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8016a4:	8b 40 48             	mov    0x48(%eax),%eax
  8016a7:	83 ec 04             	sub    $0x4,%esp
  8016aa:	53                   	push   %ebx
  8016ab:	50                   	push   %eax
  8016ac:	68 50 31 80 00       	push   $0x803150
  8016b1:	e8 0e ec ff ff       	call   8002c4 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8016b6:	83 c4 10             	add    $0x10,%esp
  8016b9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8016be:	eb 1d                	jmp    8016dd <ftruncate+0x7a>
	}
	if (!dev->dev_trunc)
  8016c0:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8016c3:	8b 52 18             	mov    0x18(%edx),%edx
  8016c6:	85 d2                	test   %edx,%edx
  8016c8:	74 0e                	je     8016d8 <ftruncate+0x75>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8016ca:	83 ec 08             	sub    $0x8,%esp
  8016cd:	ff 75 0c             	pushl  0xc(%ebp)
  8016d0:	50                   	push   %eax
  8016d1:	ff d2                	call   *%edx
  8016d3:	83 c4 10             	add    $0x10,%esp
  8016d6:	eb 05                	jmp    8016dd <ftruncate+0x7a>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8016d8:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  8016dd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016e0:	c9                   	leave  
  8016e1:	c3                   	ret    

008016e2 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8016e2:	55                   	push   %ebp
  8016e3:	89 e5                	mov    %esp,%ebp
  8016e5:	53                   	push   %ebx
  8016e6:	83 ec 14             	sub    $0x14,%esp
  8016e9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016ec:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016ef:	50                   	push   %eax
  8016f0:	ff 75 08             	pushl  0x8(%ebp)
  8016f3:	e8 63 fb ff ff       	call   80125b <fd_lookup>
  8016f8:	83 c4 08             	add    $0x8,%esp
  8016fb:	85 c0                	test   %eax,%eax
  8016fd:	78 52                	js     801751 <fstat+0x6f>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016ff:	83 ec 08             	sub    $0x8,%esp
  801702:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801705:	50                   	push   %eax
  801706:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801709:	ff 30                	pushl  (%eax)
  80170b:	e8 a1 fb ff ff       	call   8012b1 <dev_lookup>
  801710:	83 c4 10             	add    $0x10,%esp
  801713:	85 c0                	test   %eax,%eax
  801715:	78 3a                	js     801751 <fstat+0x6f>
		return r;
	if (!dev->dev_stat)
  801717:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80171a:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80171e:	74 2c                	je     80174c <fstat+0x6a>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801720:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801723:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80172a:	00 00 00 
	stat->st_isdir = 0;
  80172d:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801734:	00 00 00 
	stat->st_dev = dev;
  801737:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80173d:	83 ec 08             	sub    $0x8,%esp
  801740:	53                   	push   %ebx
  801741:	ff 75 f0             	pushl  -0x10(%ebp)
  801744:	ff 50 14             	call   *0x14(%eax)
  801747:	83 c4 10             	add    $0x10,%esp
  80174a:	eb 05                	jmp    801751 <fstat+0x6f>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  80174c:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801751:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801754:	c9                   	leave  
  801755:	c3                   	ret    

00801756 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801756:	55                   	push   %ebp
  801757:	89 e5                	mov    %esp,%ebp
  801759:	56                   	push   %esi
  80175a:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80175b:	83 ec 08             	sub    $0x8,%esp
  80175e:	6a 00                	push   $0x0
  801760:	ff 75 08             	pushl  0x8(%ebp)
  801763:	e8 78 01 00 00       	call   8018e0 <open>
  801768:	89 c3                	mov    %eax,%ebx
  80176a:	83 c4 10             	add    $0x10,%esp
  80176d:	85 c0                	test   %eax,%eax
  80176f:	78 1b                	js     80178c <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801771:	83 ec 08             	sub    $0x8,%esp
  801774:	ff 75 0c             	pushl  0xc(%ebp)
  801777:	50                   	push   %eax
  801778:	e8 65 ff ff ff       	call   8016e2 <fstat>
  80177d:	89 c6                	mov    %eax,%esi
	close(fd);
  80177f:	89 1c 24             	mov    %ebx,(%esp)
  801782:	e8 18 fc ff ff       	call   80139f <close>
	return r;
  801787:	83 c4 10             	add    $0x10,%esp
  80178a:	89 f3                	mov    %esi,%ebx
}
  80178c:	89 d8                	mov    %ebx,%eax
  80178e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801791:	5b                   	pop    %ebx
  801792:	5e                   	pop    %esi
  801793:	c9                   	leave  
  801794:	c3                   	ret    
  801795:	00 00                	add    %al,(%eax)
	...

00801798 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801798:	55                   	push   %ebp
  801799:	89 e5                	mov    %esp,%ebp
  80179b:	56                   	push   %esi
  80179c:	53                   	push   %ebx
  80179d:	89 c3                	mov    %eax,%ebx
  80179f:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  8017a1:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  8017a8:	75 12                	jne    8017bc <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8017aa:	83 ec 0c             	sub    $0xc,%esp
  8017ad:	6a 01                	push   $0x1
  8017af:	e8 fe 10 00 00       	call   8028b2 <ipc_find_env>
  8017b4:	a3 00 50 80 00       	mov    %eax,0x805000
  8017b9:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8017bc:	6a 07                	push   $0x7
  8017be:	68 00 60 80 00       	push   $0x806000
  8017c3:	53                   	push   %ebx
  8017c4:	ff 35 00 50 80 00    	pushl  0x805000
  8017ca:	e8 8e 10 00 00       	call   80285d <ipc_send>
	
	return ipc_recv(NULL, dstva, NULL);
  8017cf:	83 c4 0c             	add    $0xc,%esp
  8017d2:	6a 00                	push   $0x0
  8017d4:	56                   	push   %esi
  8017d5:	6a 00                	push   $0x0
  8017d7:	e8 0c 10 00 00       	call   8027e8 <ipc_recv>
}
  8017dc:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017df:	5b                   	pop    %ebx
  8017e0:	5e                   	pop    %esi
  8017e1:	c9                   	leave  
  8017e2:	c3                   	ret    

008017e3 <devfile_stat>:
}


static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8017e3:	55                   	push   %ebp
  8017e4:	89 e5                	mov    %esp,%ebp
  8017e6:	53                   	push   %ebx
  8017e7:	83 ec 04             	sub    $0x4,%esp
  8017ea:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8017ed:	8b 45 08             	mov    0x8(%ebp),%eax
  8017f0:	8b 40 0c             	mov    0xc(%eax),%eax
  8017f3:	a3 00 60 80 00       	mov    %eax,0x806000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0) {
  8017f8:	ba 00 00 00 00       	mov    $0x0,%edx
  8017fd:	b8 05 00 00 00       	mov    $0x5,%eax
  801802:	e8 91 ff ff ff       	call   801798 <fsipc>
  801807:	85 c0                	test   %eax,%eax
  801809:	78 2c                	js     801837 <devfile_stat+0x54>
		return r;
	}
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80180b:	83 ec 08             	sub    $0x8,%esp
  80180e:	68 00 60 80 00       	push   $0x806000
  801813:	53                   	push   %ebx
  801814:	e8 61 f0 ff ff       	call   80087a <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801819:	a1 80 60 80 00       	mov    0x806080,%eax
  80181e:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801824:	a1 84 60 80 00       	mov    0x806084,%eax
  801829:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80182f:	83 c4 10             	add    $0x10,%esp
  801832:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801837:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80183a:	c9                   	leave  
  80183b:	c3                   	ret    

0080183c <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80183c:	55                   	push   %ebp
  80183d:	89 e5                	mov    %esp,%ebp
  80183f:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801842:	8b 45 08             	mov    0x8(%ebp),%eax
  801845:	8b 40 0c             	mov    0xc(%eax),%eax
  801848:	a3 00 60 80 00       	mov    %eax,0x806000
	return fsipc(FSREQ_FLUSH, NULL);
  80184d:	ba 00 00 00 00       	mov    $0x0,%edx
  801852:	b8 06 00 00 00       	mov    $0x6,%eax
  801857:	e8 3c ff ff ff       	call   801798 <fsipc>
}
  80185c:	c9                   	leave  
  80185d:	c3                   	ret    

0080185e <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  80185e:	55                   	push   %ebp
  80185f:	89 e5                	mov    %esp,%ebp
  801861:	56                   	push   %esi
  801862:	53                   	push   %ebx
  801863:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801866:	8b 45 08             	mov    0x8(%ebp),%eax
  801869:	8b 40 0c             	mov    0xc(%eax),%eax
  80186c:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.read.req_n = n;
  801871:	89 35 04 60 80 00    	mov    %esi,0x806004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801877:	ba 00 00 00 00       	mov    $0x0,%edx
  80187c:	b8 03 00 00 00       	mov    $0x3,%eax
  801881:	e8 12 ff ff ff       	call   801798 <fsipc>
  801886:	89 c3                	mov    %eax,%ebx
  801888:	85 c0                	test   %eax,%eax
  80188a:	78 4b                	js     8018d7 <devfile_read+0x79>
		return r;
	assert(r <= n);
  80188c:	39 c6                	cmp    %eax,%esi
  80188e:	73 16                	jae    8018a6 <devfile_read+0x48>
  801890:	68 bc 31 80 00       	push   $0x8031bc
  801895:	68 c3 31 80 00       	push   $0x8031c3
  80189a:	6a 7d                	push   $0x7d
  80189c:	68 d8 31 80 00       	push   $0x8031d8
  8018a1:	e8 46 e9 ff ff       	call   8001ec <_panic>
	assert(r <= PGSIZE);
  8018a6:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8018ab:	7e 16                	jle    8018c3 <devfile_read+0x65>
  8018ad:	68 e3 31 80 00       	push   $0x8031e3
  8018b2:	68 c3 31 80 00       	push   $0x8031c3
  8018b7:	6a 7e                	push   $0x7e
  8018b9:	68 d8 31 80 00       	push   $0x8031d8
  8018be:	e8 29 e9 ff ff       	call   8001ec <_panic>
	memmove(buf, &fsipcbuf, r);
  8018c3:	83 ec 04             	sub    $0x4,%esp
  8018c6:	50                   	push   %eax
  8018c7:	68 00 60 80 00       	push   $0x806000
  8018cc:	ff 75 0c             	pushl  0xc(%ebp)
  8018cf:	e8 67 f1 ff ff       	call   800a3b <memmove>
	return r;
  8018d4:	83 c4 10             	add    $0x10,%esp
}
  8018d7:	89 d8                	mov    %ebx,%eax
  8018d9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018dc:	5b                   	pop    %ebx
  8018dd:	5e                   	pop    %esi
  8018de:	c9                   	leave  
  8018df:	c3                   	ret    

008018e0 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8018e0:	55                   	push   %ebp
  8018e1:	89 e5                	mov    %esp,%ebp
  8018e3:	56                   	push   %esi
  8018e4:	53                   	push   %ebx
  8018e5:	83 ec 1c             	sub    $0x1c,%esp
  8018e8:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8018eb:	56                   	push   %esi
  8018ec:	e8 37 ef ff ff       	call   800828 <strlen>
  8018f1:	83 c4 10             	add    $0x10,%esp
  8018f4:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8018f9:	7f 65                	jg     801960 <open+0x80>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8018fb:	83 ec 0c             	sub    $0xc,%esp
  8018fe:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801901:	50                   	push   %eax
  801902:	e8 e1 f8 ff ff       	call   8011e8 <fd_alloc>
  801907:	89 c3                	mov    %eax,%ebx
  801909:	83 c4 10             	add    $0x10,%esp
  80190c:	85 c0                	test   %eax,%eax
  80190e:	78 55                	js     801965 <open+0x85>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801910:	83 ec 08             	sub    $0x8,%esp
  801913:	56                   	push   %esi
  801914:	68 00 60 80 00       	push   $0x806000
  801919:	e8 5c ef ff ff       	call   80087a <strcpy>
	fsipcbuf.open.req_omode = mode;
  80191e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801921:	a3 00 64 80 00       	mov    %eax,0x806400



	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801926:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801929:	b8 01 00 00 00       	mov    $0x1,%eax
  80192e:	e8 65 fe ff ff       	call   801798 <fsipc>
  801933:	89 c3                	mov    %eax,%ebx
  801935:	83 c4 10             	add    $0x10,%esp
  801938:	85 c0                	test   %eax,%eax
  80193a:	79 12                	jns    80194e <open+0x6e>
		fd_close(fd, 0);
  80193c:	83 ec 08             	sub    $0x8,%esp
  80193f:	6a 00                	push   $0x0
  801941:	ff 75 f4             	pushl  -0xc(%ebp)
  801944:	e8 ce f9 ff ff       	call   801317 <fd_close>
		return r;
  801949:	83 c4 10             	add    $0x10,%esp
  80194c:	eb 17                	jmp    801965 <open+0x85>
	}

	return fd2num(fd);
  80194e:	83 ec 0c             	sub    $0xc,%esp
  801951:	ff 75 f4             	pushl  -0xc(%ebp)
  801954:	e8 67 f8 ff ff       	call   8011c0 <fd2num>
  801959:	89 c3                	mov    %eax,%ebx
  80195b:	83 c4 10             	add    $0x10,%esp
  80195e:	eb 05                	jmp    801965 <open+0x85>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801960:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801965:	89 d8                	mov    %ebx,%eax
  801967:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80196a:	5b                   	pop    %ebx
  80196b:	5e                   	pop    %esi
  80196c:	c9                   	leave  
  80196d:	c3                   	ret    
	...

00801970 <map_segment>:
}

static int
map_segment(envid_t child, uintptr_t va, size_t memsz,
	int fd, size_t filesz, off_t fileoffset, int perm)
{
  801970:	55                   	push   %ebp
  801971:	89 e5                	mov    %esp,%ebp
  801973:	57                   	push   %edi
  801974:	56                   	push   %esi
  801975:	53                   	push   %ebx
  801976:	83 ec 1c             	sub    $0x1c,%esp
  801979:	89 c7                	mov    %eax,%edi
  80197b:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  80197e:	89 4d e0             	mov    %ecx,-0x20(%ebp)
	int i, r;
	void *blk;

	//cprintf("map_segment %x+%x\n", va, memsz);

	if ((i = PGOFF(va))) {
  801981:	89 d0                	mov    %edx,%eax
  801983:	25 ff 0f 00 00       	and    $0xfff,%eax
  801988:	74 0c                	je     801996 <map_segment+0x26>
		va -= i;
  80198a:	29 45 e4             	sub    %eax,-0x1c(%ebp)
		memsz += i;
  80198d:	01 45 e0             	add    %eax,-0x20(%ebp)
		filesz += i;
  801990:	01 45 0c             	add    %eax,0xc(%ebp)
		fileoffset -= i;
  801993:	29 45 10             	sub    %eax,0x10(%ebp)
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  801996:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80199a:	0f 84 ee 00 00 00    	je     801a8e <map_segment+0x11e>
  8019a0:	be 00 00 00 00       	mov    $0x0,%esi
  8019a5:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (i >= filesz) {
  8019aa:	39 75 0c             	cmp    %esi,0xc(%ebp)
  8019ad:	77 20                	ja     8019cf <map_segment+0x5f>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
  8019af:	83 ec 04             	sub    $0x4,%esp
  8019b2:	ff 75 14             	pushl  0x14(%ebp)
  8019b5:	03 75 e4             	add    -0x1c(%ebp),%esi
  8019b8:	56                   	push   %esi
  8019b9:	57                   	push   %edi
  8019ba:	e8 3d f3 ff ff       	call   800cfc <sys_page_alloc>
  8019bf:	83 c4 10             	add    $0x10,%esp
  8019c2:	85 c0                	test   %eax,%eax
  8019c4:	0f 89 ac 00 00 00    	jns    801a76 <map_segment+0x106>
  8019ca:	e9 c4 00 00 00       	jmp    801a93 <map_segment+0x123>
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  8019cf:	83 ec 04             	sub    $0x4,%esp
  8019d2:	6a 07                	push   $0x7
  8019d4:	68 00 00 40 00       	push   $0x400000
  8019d9:	6a 00                	push   $0x0
  8019db:	e8 1c f3 ff ff       	call   800cfc <sys_page_alloc>
  8019e0:	83 c4 10             	add    $0x10,%esp
  8019e3:	85 c0                	test   %eax,%eax
  8019e5:	0f 88 a8 00 00 00    	js     801a93 <map_segment+0x123>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  8019eb:	83 ec 08             	sub    $0x8,%esp
	sys_page_unmap(0, UTEMP);
	return r;
}

static int
map_segment(envid_t child, uintptr_t va, size_t memsz,
  8019ee:	8b 45 10             	mov    0x10(%ebp),%eax
  8019f1:	8d 04 03             	lea    (%ebx,%eax,1),%eax
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  8019f4:	50                   	push   %eax
  8019f5:	ff 75 08             	pushl  0x8(%ebp)
  8019f8:	e8 3d fc ff ff       	call   80163a <seek>
  8019fd:	83 c4 10             	add    $0x10,%esp
  801a00:	85 c0                	test   %eax,%eax
  801a02:	0f 88 8b 00 00 00    	js     801a93 <map_segment+0x123>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  801a08:	83 ec 04             	sub    $0x4,%esp
  801a0b:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a0e:	29 f0                	sub    %esi,%eax
  801a10:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801a15:	76 05                	jbe    801a1c <map_segment+0xac>
  801a17:	b8 00 10 00 00       	mov    $0x1000,%eax
  801a1c:	50                   	push   %eax
  801a1d:	68 00 00 40 00       	push   $0x400000
  801a22:	ff 75 08             	pushl  0x8(%ebp)
  801a25:	e8 39 fb ff ff       	call   801563 <readn>
  801a2a:	83 c4 10             	add    $0x10,%esp
  801a2d:	85 c0                	test   %eax,%eax
  801a2f:	78 62                	js     801a93 <map_segment+0x123>
				return r;
			if ((r = sys_page_map(0, UTEMP, child, (void*) (va + i), perm)) < 0)
  801a31:	83 ec 0c             	sub    $0xc,%esp
  801a34:	ff 75 14             	pushl  0x14(%ebp)
  801a37:	03 75 e4             	add    -0x1c(%ebp),%esi
  801a3a:	56                   	push   %esi
  801a3b:	57                   	push   %edi
  801a3c:	68 00 00 40 00       	push   $0x400000
  801a41:	6a 00                	push   $0x0
  801a43:	e8 d8 f2 ff ff       	call   800d20 <sys_page_map>
  801a48:	83 c4 20             	add    $0x20,%esp
  801a4b:	85 c0                	test   %eax,%eax
  801a4d:	79 15                	jns    801a64 <map_segment+0xf4>
				panic("spawn: sys_page_map data: %e", r);
  801a4f:	50                   	push   %eax
  801a50:	68 ef 31 80 00       	push   $0x8031ef
  801a55:	68 84 01 00 00       	push   $0x184
  801a5a:	68 0c 32 80 00       	push   $0x80320c
  801a5f:	e8 88 e7 ff ff       	call   8001ec <_panic>
			sys_page_unmap(0, UTEMP);
  801a64:	83 ec 08             	sub    $0x8,%esp
  801a67:	68 00 00 40 00       	push   $0x400000
  801a6c:	6a 00                	push   $0x0
  801a6e:	e8 d3 f2 ff ff       	call   800d46 <sys_page_unmap>
  801a73:	83 c4 10             	add    $0x10,%esp
		memsz += i;
		filesz += i;
		fileoffset -= i;
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  801a76:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801a7c:	89 de                	mov    %ebx,%esi
  801a7e:	39 5d e0             	cmp    %ebx,-0x20(%ebp)
  801a81:	0f 87 23 ff ff ff    	ja     8019aa <map_segment+0x3a>
			if ((r = sys_page_map(0, UTEMP, child, (void*) (va + i), perm)) < 0)
				panic("spawn: sys_page_map data: %e", r);
			sys_page_unmap(0, UTEMP);
		}
	}
	return 0;
  801a87:	b8 00 00 00 00       	mov    $0x0,%eax
  801a8c:	eb 05                	jmp    801a93 <map_segment+0x123>
  801a8e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801a93:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a96:	5b                   	pop    %ebx
  801a97:	5e                   	pop    %esi
  801a98:	5f                   	pop    %edi
  801a99:	c9                   	leave  
  801a9a:	c3                   	ret    

00801a9b <init_stack>:
// On success, returns 0 and sets *init_esp
// to the initial stack pointer with which the child should start.
// Returns < 0 on failure.
static int
init_stack(envid_t child, const char **argv, uintptr_t *init_esp, uint32_t stack_addr)
{
  801a9b:	55                   	push   %ebp
  801a9c:	89 e5                	mov    %esp,%ebp
  801a9e:	57                   	push   %edi
  801a9f:	56                   	push   %esi
  801aa0:	53                   	push   %ebx
  801aa1:	83 ec 2c             	sub    $0x2c,%esp
  801aa4:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801aa7:	89 d7                	mov    %edx,%edi
  801aa9:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  801aac:	8b 02                	mov    (%edx),%eax
  801aae:	85 c0                	test   %eax,%eax
  801ab0:	74 31                	je     801ae3 <init_stack+0x48>
  801ab2:	bb 00 00 00 00       	mov    $0x0,%ebx
	char *string_store;
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
  801ab7:	be 00 00 00 00       	mov    $0x0,%esi
	for (argc = 0; argv[argc] != 0; argc++)
		string_size += strlen(argv[argc]) + 1;
  801abc:	83 ec 0c             	sub    $0xc,%esp
  801abf:	50                   	push   %eax
  801ac0:	e8 63 ed ff ff       	call   800828 <strlen>
  801ac5:	8d 74 30 01          	lea    0x1(%eax,%esi,1),%esi
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  801ac9:	43                   	inc    %ebx
  801aca:	8d 0c 9d 00 00 00 00 	lea    0x0(,%ebx,4),%ecx
  801ad1:	8b 04 9f             	mov    (%edi,%ebx,4),%eax
  801ad4:	83 c4 10             	add    $0x10,%esp
  801ad7:	85 c0                	test   %eax,%eax
  801ad9:	75 e1                	jne    801abc <init_stack+0x21>
  801adb:	89 5d d0             	mov    %ebx,-0x30(%ebp)
  801ade:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  801ae1:	eb 18                	jmp    801afb <init_stack+0x60>
  801ae3:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
  801aea:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
  801af1:	bb 00 00 00 00       	mov    $0x0,%ebx
	char *string_store;
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
  801af6:	be 00 00 00 00       	mov    $0x0,%esi
	// Determine where to place the strings and the argv array.
	// Set up pointers into the temporary page 'UTEMP'; we'll map a page
	// there later, then remap that page into the child environment
	// at (USTACKTOP - PGSIZE).
	// strings is the topmost thing on the stack.
	string_store = (char*) UTEMP + PGSIZE - string_size;
  801afb:	f7 de                	neg    %esi
  801afd:	81 c6 00 10 40 00    	add    $0x401000,%esi
  801b03:	89 75 dc             	mov    %esi,-0x24(%ebp)
	// argv is below that.  There's one argument pointer per argument, plus
	// a null pointer.
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));
  801b06:	89 f2                	mov    %esi,%edx
  801b08:	83 e2 fc             	and    $0xfffffffc,%edx
  801b0b:	89 d8                	mov    %ebx,%eax
  801b0d:	f7 d0                	not    %eax
  801b0f:	8d 04 82             	lea    (%edx,%eax,4),%eax
  801b12:	89 45 e4             	mov    %eax,-0x1c(%ebp)

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
  801b15:	83 e8 08             	sub    $0x8,%eax
  801b18:	3d ff ff 3f 00       	cmp    $0x3fffff,%eax
  801b1d:	0f 86 fb 00 00 00    	jbe    801c1e <init_stack+0x183>
		return -E_NO_MEM;

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801b23:	83 ec 04             	sub    $0x4,%esp
  801b26:	6a 07                	push   $0x7
  801b28:	68 00 00 40 00       	push   $0x400000
  801b2d:	6a 00                	push   $0x0
  801b2f:	e8 c8 f1 ff ff       	call   800cfc <sys_page_alloc>
  801b34:	89 c6                	mov    %eax,%esi
  801b36:	83 c4 10             	add    $0x10,%esp
  801b39:	85 c0                	test   %eax,%eax
  801b3b:	0f 88 e9 00 00 00    	js     801c2a <init_stack+0x18f>
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  801b41:	85 db                	test   %ebx,%ebx
  801b43:	7e 3e                	jle    801b83 <init_stack+0xe8>
  801b45:	be 00 00 00 00       	mov    $0x0,%esi
  801b4a:	89 5d e0             	mov    %ebx,-0x20(%ebp)
  801b4d:	8b 5d dc             	mov    -0x24(%ebp),%ebx
		argv_store[i] = UTEMP2USTACK(string_store);
  801b50:	8d 83 00 d0 7f ee    	lea    -0x11803000(%ebx),%eax
  801b56:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801b59:	89 04 b2             	mov    %eax,(%edx,%esi,4)
		strcpy(string_store, argv[i]);
  801b5c:	83 ec 08             	sub    $0x8,%esp
  801b5f:	ff 34 b7             	pushl  (%edi,%esi,4)
  801b62:	53                   	push   %ebx
  801b63:	e8 12 ed ff ff       	call   80087a <strcpy>
		string_store += strlen(argv[i]) + 1;
  801b68:	83 c4 04             	add    $0x4,%esp
  801b6b:	ff 34 b7             	pushl  (%edi,%esi,4)
  801b6e:	e8 b5 ec ff ff       	call   800828 <strlen>
  801b73:	8d 5c 03 01          	lea    0x1(%ebx,%eax,1),%ebx
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  801b77:	46                   	inc    %esi
  801b78:	83 c4 10             	add    $0x10,%esp
  801b7b:	3b 75 e0             	cmp    -0x20(%ebp),%esi
  801b7e:	7c d0                	jl     801b50 <init_stack+0xb5>
  801b80:	89 5d dc             	mov    %ebx,-0x24(%ebp)
		argv_store[i] = UTEMP2USTACK(string_store);
		strcpy(string_store, argv[i]);
		string_store += strlen(argv[i]) + 1;
	}
	argv_store[argc] = 0;
  801b83:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801b86:	8b 45 cc             	mov    -0x34(%ebp),%eax
  801b89:	c7 04 02 00 00 00 00 	movl   $0x0,(%edx,%eax,1)
	assert(string_store == (char*)UTEMP + PGSIZE);
  801b90:	81 7d dc 00 10 40 00 	cmpl   $0x401000,-0x24(%ebp)
  801b97:	74 19                	je     801bb2 <init_stack+0x117>
  801b99:	68 7c 32 80 00       	push   $0x80327c
  801b9e:	68 c3 31 80 00       	push   $0x8031c3
  801ba3:	68 51 01 00 00       	push   $0x151
  801ba8:	68 0c 32 80 00       	push   $0x80320c
  801bad:	e8 3a e6 ff ff       	call   8001ec <_panic>

	argv_store[-1] = UTEMP2USTACK(argv_store);
  801bb2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801bb5:	2d 00 30 80 11       	sub    $0x11803000,%eax
  801bba:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801bbd:	89 42 fc             	mov    %eax,-0x4(%edx)
	argv_store[-2] = argc;
  801bc0:	8b 45 d0             	mov    -0x30(%ebp),%eax
  801bc3:	89 42 f8             	mov    %eax,-0x8(%edx)

	*init_esp = UTEMP2USTACK(&argv_store[-2]);
  801bc6:	89 d0                	mov    %edx,%eax
  801bc8:	2d 08 30 80 11       	sub    $0x11803008,%eax
  801bcd:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  801bd0:	89 02                	mov    %eax,(%edx)

	// After completing the stack, map it into the child's address space
	// and unmap it from ours!
	
	if ((r = sys_page_map(0, UTEMP, child, (void*) stack_addr, PTE_P | PTE_U | PTE_W)) < 0)
  801bd2:	83 ec 0c             	sub    $0xc,%esp
  801bd5:	6a 07                	push   $0x7
  801bd7:	ff 75 08             	pushl  0x8(%ebp)
  801bda:	ff 75 d8             	pushl  -0x28(%ebp)
  801bdd:	68 00 00 40 00       	push   $0x400000
  801be2:	6a 00                	push   $0x0
  801be4:	e8 37 f1 ff ff       	call   800d20 <sys_page_map>
  801be9:	89 c6                	mov    %eax,%esi
  801beb:	83 c4 20             	add    $0x20,%esp
  801bee:	85 c0                	test   %eax,%eax
  801bf0:	78 18                	js     801c0a <init_stack+0x16f>
		goto error;
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  801bf2:	83 ec 08             	sub    $0x8,%esp
  801bf5:	68 00 00 40 00       	push   $0x400000
  801bfa:	6a 00                	push   $0x0
  801bfc:	e8 45 f1 ff ff       	call   800d46 <sys_page_unmap>
  801c01:	89 c6                	mov    %eax,%esi
  801c03:	83 c4 10             	add    $0x10,%esp
  801c06:	85 c0                	test   %eax,%eax
  801c08:	79 1b                	jns    801c25 <init_stack+0x18a>
		goto error;
	return 0;

error:
	sys_page_unmap(0, UTEMP);
  801c0a:	83 ec 08             	sub    $0x8,%esp
  801c0d:	68 00 00 40 00       	push   $0x400000
  801c12:	6a 00                	push   $0x0
  801c14:	e8 2d f1 ff ff       	call   800d46 <sys_page_unmap>
	return r;
  801c19:	83 c4 10             	add    $0x10,%esp
  801c1c:	eb 0c                	jmp    801c2a <init_stack+0x18f>
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
		return -E_NO_MEM;
  801c1e:	be fc ff ff ff       	mov    $0xfffffffc,%esi
  801c23:	eb 05                	jmp    801c2a <init_stack+0x18f>
	
	if ((r = sys_page_map(0, UTEMP, child, (void*) stack_addr, PTE_P | PTE_U | PTE_W)) < 0)
		goto error;
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
		goto error;
	return 0;
  801c25:	be 00 00 00 00       	mov    $0x0,%esi

error:
	sys_page_unmap(0, UTEMP);
	return r;
}
  801c2a:	89 f0                	mov    %esi,%eax
  801c2c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c2f:	5b                   	pop    %ebx
  801c30:	5e                   	pop    %esi
  801c31:	5f                   	pop    %edi
  801c32:	c9                   	leave  
  801c33:	c3                   	ret    

00801c34 <spawn>:
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
{
  801c34:	55                   	push   %ebp
  801c35:	89 e5                	mov    %esp,%ebp
  801c37:	57                   	push   %edi
  801c38:	56                   	push   %esi
  801c39:	53                   	push   %ebx
  801c3a:	81 ec 74 02 00 00    	sub    $0x274,%esp
	//   - Call sys_env_set_trapframe(child, &child_tf) to set up the
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
  801c40:	6a 00                	push   $0x0
  801c42:	ff 75 08             	pushl  0x8(%ebp)
  801c45:	e8 96 fc ff ff       	call   8018e0 <open>
  801c4a:	89 85 90 fd ff ff    	mov    %eax,-0x270(%ebp)
  801c50:	83 c4 10             	add    $0x10,%esp
  801c53:	85 c0                	test   %eax,%eax
  801c55:	0f 88 3f 02 00 00    	js     801e9a <spawn+0x266>
		return r;
	fd = r;

	// Read elf header
	elf = (struct Elf*) elf_buf;
	if (readn(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf)
  801c5b:	83 ec 04             	sub    $0x4,%esp
  801c5e:	68 00 02 00 00       	push   $0x200
  801c63:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  801c69:	50                   	push   %eax
  801c6a:	ff b5 90 fd ff ff    	pushl  -0x270(%ebp)
  801c70:	e8 ee f8 ff ff       	call   801563 <readn>
  801c75:	83 c4 10             	add    $0x10,%esp
  801c78:	3d 00 02 00 00       	cmp    $0x200,%eax
  801c7d:	75 0c                	jne    801c8b <spawn+0x57>
	    || elf->e_magic != ELF_MAGIC) {
  801c7f:	81 bd e8 fd ff ff 7f 	cmpl   $0x464c457f,-0x218(%ebp)
  801c86:	45 4c 46 
  801c89:	74 38                	je     801cc3 <spawn+0x8f>
		close(fd);
  801c8b:	83 ec 0c             	sub    $0xc,%esp
  801c8e:	ff b5 90 fd ff ff    	pushl  -0x270(%ebp)
  801c94:	e8 06 f7 ff ff       	call   80139f <close>
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
  801c99:	83 c4 0c             	add    $0xc,%esp
  801c9c:	68 7f 45 4c 46       	push   $0x464c457f
  801ca1:	ff b5 e8 fd ff ff    	pushl  -0x218(%ebp)
  801ca7:	68 18 32 80 00       	push   $0x803218
  801cac:	e8 13 e6 ff ff       	call   8002c4 <cprintf>
		return -E_NOT_EXEC;
  801cb1:	83 c4 10             	add    $0x10,%esp
  801cb4:	c7 85 94 fd ff ff f2 	movl   $0xfffffff2,-0x26c(%ebp)
  801cbb:	ff ff ff 
  801cbe:	e9 eb 01 00 00       	jmp    801eae <spawn+0x27a>
  801cc3:	ba 07 00 00 00       	mov    $0x7,%edx
  801cc8:	89 d0                	mov    %edx,%eax
  801cca:	cd 30                	int    $0x30
  801ccc:	89 85 8c fd ff ff    	mov    %eax,-0x274(%ebp)
  801cd2:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)
	}


	// Create new child environment
	if ((r = sys_exofork()) < 0)
  801cd8:	85 c0                	test   %eax,%eax
  801cda:	0f 88 ce 01 00 00    	js     801eae <spawn+0x27a>
		return r;
	child = r;

	// Set up trap frame, including initial stack.
	child_tf = envs[ENVX(child)].env_tf;
  801ce0:	25 ff 03 00 00       	and    $0x3ff,%eax
  801ce5:	89 c2                	mov    %eax,%edx
  801ce7:	c1 e2 07             	shl    $0x7,%edx
  801cea:	8d b4 82 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,4),%esi
  801cf1:	8d bd a4 fd ff ff    	lea    -0x25c(%ebp),%edi
  801cf7:	b9 11 00 00 00       	mov    $0x11,%ecx
  801cfc:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	child_tf.tf_eip = elf->e_entry;
  801cfe:	8b 85 00 fe ff ff    	mov    -0x200(%ebp),%eax
  801d04:	89 85 d4 fd ff ff    	mov    %eax,-0x22c(%ebp)

	if ((r = init_stack(child, argv, &child_tf.tf_esp, (USTACKTOP - PGSIZE))) < 0)
  801d0a:	83 ec 0c             	sub    $0xc,%esp
  801d0d:	8d 8d e0 fd ff ff    	lea    -0x220(%ebp),%ecx
  801d13:	68 00 d0 bf ee       	push   $0xeebfd000
  801d18:	8b 55 0c             	mov    0xc(%ebp),%edx
  801d1b:	8b 85 8c fd ff ff    	mov    -0x274(%ebp),%eax
  801d21:	e8 75 fd ff ff       	call   801a9b <init_stack>
  801d26:	83 c4 10             	add    $0x10,%esp
  801d29:	85 c0                	test   %eax,%eax
  801d2b:	0f 88 77 01 00 00    	js     801ea8 <spawn+0x274>
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  801d31:	8b 85 04 fe ff ff    	mov    -0x1fc(%ebp),%eax
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801d37:	66 83 bd 14 fe ff ff 	cmpw   $0x0,-0x1ec(%ebp)
  801d3e:	00 
  801d3f:	74 5d                	je     801d9e <spawn+0x16a>

	if ((r = init_stack(child, argv, &child_tf.tf_esp, (USTACKTOP - PGSIZE))) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  801d41:	8d 9c 05 e8 fd ff ff 	lea    -0x218(%ebp,%eax,1),%ebx
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801d48:	be 00 00 00 00       	mov    $0x0,%esi
  801d4d:	8b bd 90 fd ff ff    	mov    -0x270(%ebp),%edi
		if (ph->p_type != ELF_PROG_LOAD)
  801d53:	83 3b 01             	cmpl   $0x1,(%ebx)
  801d56:	75 35                	jne    801d8d <spawn+0x159>
			continue;
		perm = PTE_P | PTE_U;
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
  801d58:	8b 43 18             	mov    0x18(%ebx),%eax
  801d5b:	83 e0 02             	and    $0x2,%eax
	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
		if (ph->p_type != ELF_PROG_LOAD)
			continue;
		perm = PTE_P | PTE_U;
  801d5e:	83 f8 01             	cmp    $0x1,%eax
  801d61:	19 c0                	sbb    %eax,%eax
  801d63:	83 e0 fe             	and    $0xfffffffe,%eax
  801d66:	83 c0 07             	add    $0x7,%eax
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
  801d69:	8b 4b 14             	mov    0x14(%ebx),%ecx
  801d6c:	8b 53 08             	mov    0x8(%ebx),%edx
  801d6f:	50                   	push   %eax
  801d70:	ff 73 04             	pushl  0x4(%ebx)
  801d73:	ff 73 10             	pushl  0x10(%ebx)
  801d76:	57                   	push   %edi
  801d77:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  801d7d:	e8 ee fb ff ff       	call   801970 <map_segment>
  801d82:	83 c4 10             	add    $0x10,%esp
  801d85:	85 c0                	test   %eax,%eax
  801d87:	0f 88 e4 00 00 00    	js     801e71 <spawn+0x23d>
	if ((r = init_stack(child, argv, &child_tf.tf_esp, (USTACKTOP - PGSIZE))) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801d8d:	46                   	inc    %esi
  801d8e:	0f b7 85 14 fe ff ff 	movzwl -0x1ec(%ebp),%eax
  801d95:	39 f0                	cmp    %esi,%eax
  801d97:	7e 05                	jle    801d9e <spawn+0x16a>
  801d99:	83 c3 20             	add    $0x20,%ebx
  801d9c:	eb b5                	jmp    801d53 <spawn+0x11f>
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
				     fd, ph->p_filesz, ph->p_offset, perm)) < 0)
			goto error;
	}
	close(fd);
  801d9e:	83 ec 0c             	sub    $0xc,%esp
  801da1:	ff b5 90 fd ff ff    	pushl  -0x270(%ebp)
  801da7:	e8 f3 f5 ff ff       	call   80139f <close>
  801dac:	83 c4 10             	add    $0x10,%esp
copy_shared_pages(envid_t child)
{
	// LAB 5: Your code here.
    uint32_t i;
    int r;
    for (i = 0; i != UTOP; i += PGSIZE) 
  801daf:	bb 00 00 00 00       	mov    $0x0,%ebx
  801db4:	8b b5 94 fd ff ff    	mov    -0x26c(%ebp),%esi
    if ((uvpd[PDX(i)] & PTE_P) && (uvpt[i / PGSIZE] & PTE_P) && (uvpt[i / PGSIZE] & PTE_SHARE)) {
  801dba:	89 d8                	mov    %ebx,%eax
  801dbc:	c1 e8 16             	shr    $0x16,%eax
  801dbf:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801dc6:	a8 01                	test   $0x1,%al
  801dc8:	74 3e                	je     801e08 <spawn+0x1d4>
  801dca:	89 d8                	mov    %ebx,%eax
  801dcc:	c1 e8 0c             	shr    $0xc,%eax
  801dcf:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801dd6:	f6 c2 01             	test   $0x1,%dl
  801dd9:	74 2d                	je     801e08 <spawn+0x1d4>
  801ddb:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801de2:	f6 c6 04             	test   $0x4,%dh
  801de5:	74 21                	je     801e08 <spawn+0x1d4>
        r = sys_page_map(0, (void *)i, child, (void *)i, uvpt[i / PGSIZE] & PTE_SYSCALL);
  801de7:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801dee:	83 ec 0c             	sub    $0xc,%esp
  801df1:	25 07 0e 00 00       	and    $0xe07,%eax
  801df6:	50                   	push   %eax
  801df7:	53                   	push   %ebx
  801df8:	56                   	push   %esi
  801df9:	53                   	push   %ebx
  801dfa:	6a 00                	push   $0x0
  801dfc:	e8 1f ef ff ff       	call   800d20 <sys_page_map>
        if (r < 0) return r;
  801e01:	83 c4 20             	add    $0x20,%esp
  801e04:	85 c0                	test   %eax,%eax
  801e06:	78 13                	js     801e1b <spawn+0x1e7>
copy_shared_pages(envid_t child)
{
	// LAB 5: Your code here.
    uint32_t i;
    int r;
    for (i = 0; i != UTOP; i += PGSIZE) 
  801e08:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801e0e:	81 fb 00 00 c0 ee    	cmp    $0xeec00000,%ebx
  801e14:	75 a4                	jne    801dba <spawn+0x186>
  801e16:	e9 a1 00 00 00       	jmp    801ebc <spawn+0x288>
	close(fd);
	fd = -1;

	// Copy shared library state.
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);
  801e1b:	50                   	push   %eax
  801e1c:	68 32 32 80 00       	push   $0x803232
  801e21:	68 85 00 00 00       	push   $0x85
  801e26:	68 0c 32 80 00       	push   $0x80320c
  801e2b:	e8 bc e3 ff ff       	call   8001ec <_panic>

	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
		panic("sys_env_set_trapframe: %e", r);
  801e30:	50                   	push   %eax
  801e31:	68 48 32 80 00       	push   $0x803248
  801e36:	68 88 00 00 00       	push   $0x88
  801e3b:	68 0c 32 80 00       	push   $0x80320c
  801e40:	e8 a7 e3 ff ff       	call   8001ec <_panic>

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
  801e45:	83 ec 08             	sub    $0x8,%esp
  801e48:	6a 02                	push   $0x2
  801e4a:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801e50:	e8 14 ef ff ff       	call   800d69 <sys_env_set_status>
  801e55:	83 c4 10             	add    $0x10,%esp
  801e58:	85 c0                	test   %eax,%eax
  801e5a:	79 52                	jns    801eae <spawn+0x27a>
		panic("sys_env_set_status: %e", r);
  801e5c:	50                   	push   %eax
  801e5d:	68 62 32 80 00       	push   $0x803262
  801e62:	68 8b 00 00 00       	push   $0x8b
  801e67:	68 0c 32 80 00       	push   $0x80320c
  801e6c:	e8 7b e3 ff ff       	call   8001ec <_panic>
  801e71:	89 c7                	mov    %eax,%edi

	return child;

error:
	sys_env_destroy(child);
  801e73:	83 ec 0c             	sub    $0xc,%esp
  801e76:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801e7c:	e8 0e ee ff ff       	call   800c8f <sys_env_destroy>
	close(fd);
  801e81:	83 c4 04             	add    $0x4,%esp
  801e84:	ff b5 90 fd ff ff    	pushl  -0x270(%ebp)
  801e8a:	e8 10 f5 ff ff       	call   80139f <close>
	return r;
  801e8f:	83 c4 10             	add    $0x10,%esp
		if (ph->p_type != ELF_PROG_LOAD)
			continue;
		perm = PTE_P | PTE_U;
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
  801e92:	89 bd 94 fd ff ff    	mov    %edi,-0x26c(%ebp)
	return child;

error:
	sys_env_destroy(child);
	close(fd);
	return r;
  801e98:	eb 14                	jmp    801eae <spawn+0x27a>
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
		return r;
  801e9a:	8b 85 90 fd ff ff    	mov    -0x270(%ebp),%eax
  801ea0:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)
  801ea6:	eb 06                	jmp    801eae <spawn+0x27a>
	// Set up trap frame, including initial stack.
	child_tf = envs[ENVX(child)].env_tf;
	child_tf.tf_eip = elf->e_entry;

	if ((r = init_stack(child, argv, &child_tf.tf_esp, (USTACKTOP - PGSIZE))) < 0)
		return r;
  801ea8:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)

error:
	sys_env_destroy(child);
	close(fd);
	return r;
}
  801eae:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  801eb4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801eb7:	5b                   	pop    %ebx
  801eb8:	5e                   	pop    %esi
  801eb9:	5f                   	pop    %edi
  801eba:	c9                   	leave  
  801ebb:	c3                   	ret    

	// Copy shared library state.
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);

	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
  801ebc:	83 ec 08             	sub    $0x8,%esp
  801ebf:	8d 85 a4 fd ff ff    	lea    -0x25c(%ebp),%eax
  801ec5:	50                   	push   %eax
  801ec6:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801ecc:	e8 bb ee ff ff       	call   800d8c <sys_env_set_trapframe>
  801ed1:	83 c4 10             	add    $0x10,%esp
  801ed4:	85 c0                	test   %eax,%eax
  801ed6:	0f 89 69 ff ff ff    	jns    801e45 <spawn+0x211>
  801edc:	e9 4f ff ff ff       	jmp    801e30 <spawn+0x1fc>

00801ee1 <exec>:
// 		 0x80000000(MYTEMPLATE) to be template block cache. Then sys_exec is a system call to complete 
// 		 memory setting.
// Remember: When there is virtual memory in ELF linking address overlaped with MYTEMPLATE, exec will fail.
int
exec(const char *prog, const char **argv)
{
  801ee1:	55                   	push   %ebp
  801ee2:	89 e5                	mov    %esp,%ebp
  801ee4:	57                   	push   %edi
  801ee5:	56                   	push   %esi
  801ee6:	53                   	push   %ebx
  801ee7:	81 ec 34 02 00 00    	sub    $0x234,%esp
	struct Elf *elf;
	struct Proghdr *ph;
	int perm;	


	if ((r = open(prog, O_RDONLY)) < 0)
  801eed:	6a 00                	push   $0x0
  801eef:	ff 75 08             	pushl  0x8(%ebp)
  801ef2:	e8 e9 f9 ff ff       	call   8018e0 <open>
  801ef7:	89 85 d0 fd ff ff    	mov    %eax,-0x230(%ebp)
  801efd:	83 c4 10             	add    $0x10,%esp
  801f00:	85 c0                	test   %eax,%eax
  801f02:	0f 88 a9 01 00 00    	js     8020b1 <exec+0x1d0>
		return r;
	fd = r;

	// Read elf header
	elf = (struct Elf*) elf_buf;
  801f08:	8d bd e8 fd ff ff    	lea    -0x218(%ebp),%edi
	if (readn(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf)
  801f0e:	83 ec 04             	sub    $0x4,%esp
  801f11:	68 00 02 00 00       	push   $0x200
  801f16:	57                   	push   %edi
  801f17:	50                   	push   %eax
  801f18:	e8 46 f6 ff ff       	call   801563 <readn>
  801f1d:	83 c4 10             	add    $0x10,%esp
  801f20:	3d 00 02 00 00       	cmp    $0x200,%eax
  801f25:	75 0c                	jne    801f33 <exec+0x52>
	    || elf->e_magic != ELF_MAGIC) {
  801f27:	81 bd e8 fd ff ff 7f 	cmpl   $0x464c457f,-0x218(%ebp)
  801f2e:	45 4c 46 
  801f31:	74 34                	je     801f67 <exec+0x86>
		close(fd);
  801f33:	83 ec 0c             	sub    $0xc,%esp
  801f36:	ff b5 d0 fd ff ff    	pushl  -0x230(%ebp)
  801f3c:	e8 5e f4 ff ff       	call   80139f <close>
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
  801f41:	83 c4 0c             	add    $0xc,%esp
  801f44:	68 7f 45 4c 46       	push   $0x464c457f
  801f49:	ff 37                	pushl  (%edi)
  801f4b:	68 18 32 80 00       	push   $0x803218
  801f50:	e8 6f e3 ff ff       	call   8002c4 <cprintf>
		return -E_NOT_EXEC;
  801f55:	83 c4 10             	add    $0x10,%esp
  801f58:	c7 85 d0 fd ff ff f2 	movl   $0xfffffff2,-0x230(%ebp)
  801f5f:	ff ff ff 
  801f62:	e9 4a 01 00 00       	jmp    8020b1 <exec+0x1d0>
	}


	// Set up program segments as defined in ELF header.
	uint32_t now_addr = MYTEMPLATE;
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  801f67:	8b 47 1c             	mov    0x1c(%edi),%eax
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801f6a:	66 83 7f 2c 00       	cmpw   $0x0,0x2c(%edi)
  801f6f:	0f 84 8b 00 00 00    	je     802000 <exec+0x11f>
	}


	// Set up program segments as defined in ELF header.
	uint32_t now_addr = MYTEMPLATE;
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  801f75:	8d 9c 05 e8 fd ff ff 	lea    -0x218(%ebp,%eax,1),%ebx
		return -E_NOT_EXEC;
	}


	// Set up program segments as defined in ELF header.
	uint32_t now_addr = MYTEMPLATE;
  801f7c:	c7 85 d4 fd ff ff 00 	movl   $0x80000000,-0x22c(%ebp)
  801f83:	00 00 80 
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801f86:	be 00 00 00 00       	mov    $0x0,%esi
		if (ph->p_type != ELF_PROG_LOAD)
  801f8b:	83 3b 01             	cmpl   $0x1,(%ebx)
  801f8e:	75 62                	jne    801ff2 <exec+0x111>
			continue;
		perm = PTE_P | PTE_U;
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
  801f90:	8b 43 18             	mov    0x18(%ebx),%eax
  801f93:	83 e0 02             	and    $0x2,%eax
	uint32_t now_addr = MYTEMPLATE;
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
		if (ph->p_type != ELF_PROG_LOAD)
			continue;
		perm = PTE_P | PTE_U;
  801f96:	83 f8 01             	cmp    $0x1,%eax
  801f99:	19 c0                	sbb    %eax,%eax
  801f9b:	83 e0 fe             	and    $0xfffffffe,%eax
  801f9e:	83 c0 07             	add    $0x7,%eax
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
			perm |= PTE_W;
		if ((r = map_segment(0, PGOFF(ph->p_va) + now_addr, ph->p_memsz,
  801fa1:	8b 4b 14             	mov    0x14(%ebx),%ecx
  801fa4:	8b 53 08             	mov    0x8(%ebx),%edx
  801fa7:	81 e2 ff 0f 00 00    	and    $0xfff,%edx
  801fad:	03 95 d4 fd ff ff    	add    -0x22c(%ebp),%edx
  801fb3:	50                   	push   %eax
  801fb4:	ff 73 04             	pushl  0x4(%ebx)
  801fb7:	ff 73 10             	pushl  0x10(%ebx)
  801fba:	ff b5 d0 fd ff ff    	pushl  -0x230(%ebp)
  801fc0:	b8 00 00 00 00       	mov    $0x0,%eax
  801fc5:	e8 a6 f9 ff ff       	call   801970 <map_segment>
  801fca:	83 c4 10             	add    $0x10,%esp
  801fcd:	85 c0                	test   %eax,%eax
  801fcf:	0f 88 a3 00 00 00    	js     802078 <exec+0x197>
				     fd, ph->p_filesz, ph->p_offset, perm)) < 0)
			goto error;
		now_addr += ROUNDUP(ph->p_memsz + PGOFF(ph->p_va), PGSIZE);
  801fd5:	8b 53 14             	mov    0x14(%ebx),%edx
  801fd8:	8b 43 08             	mov    0x8(%ebx),%eax
  801fdb:	25 ff 0f 00 00       	and    $0xfff,%eax
  801fe0:	8d 84 02 ff 0f 00 00 	lea    0xfff(%edx,%eax,1),%eax
  801fe7:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801fec:	01 85 d4 fd ff ff    	add    %eax,-0x22c(%ebp)


	// Set up program segments as defined in ELF header.
	uint32_t now_addr = MYTEMPLATE;
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801ff2:	46                   	inc    %esi
  801ff3:	0f b7 47 2c          	movzwl 0x2c(%edi),%eax
  801ff7:	39 f0                	cmp    %esi,%eax
  801ff9:	7e 0f                	jle    80200a <exec+0x129>
  801ffb:	83 c3 20             	add    $0x20,%ebx
  801ffe:	eb 8b                	jmp    801f8b <exec+0xaa>
		return -E_NOT_EXEC;
	}


	// Set up program segments as defined in ELF header.
	uint32_t now_addr = MYTEMPLATE;
  802000:	c7 85 d4 fd ff ff 00 	movl   $0x80000000,-0x22c(%ebp)
  802007:	00 00 80 
		if ((r = map_segment(0, PGOFF(ph->p_va) + now_addr, ph->p_memsz,
				     fd, ph->p_filesz, ph->p_offset, perm)) < 0)
			goto error;
		now_addr += ROUNDUP(ph->p_memsz + PGOFF(ph->p_va), PGSIZE);
	}
	close(fd);
  80200a:	83 ec 0c             	sub    $0xc,%esp
  80200d:	ff b5 d0 fd ff ff    	pushl  -0x230(%ebp)
  802013:	e8 87 f3 ff ff       	call   80139f <close>
	fd = -1;

	// Set up Stack 
	if ((r = init_stack(0, argv, &tf_esp, now_addr)) < 0)
  802018:	83 c4 04             	add    $0x4,%esp
  80201b:	8d 8d e4 fd ff ff    	lea    -0x21c(%ebp),%ecx
  802021:	ff b5 d4 fd ff ff    	pushl  -0x22c(%ebp)
  802027:	8b 55 0c             	mov    0xc(%ebp),%edx
  80202a:	b8 00 00 00 00       	mov    $0x0,%eax
  80202f:	e8 67 fa ff ff       	call   801a9b <init_stack>
  802034:	89 85 d0 fd ff ff    	mov    %eax,-0x230(%ebp)
  80203a:	83 c4 10             	add    $0x10,%esp
  80203d:	85 c0                	test   %eax,%eax
  80203f:	78 70                	js     8020b1 <exec+0x1d0>
		return r;

	// Syscall to exec
	if (sys_exec(elf->e_entry, tf_esp, (void *)(elf_buf + elf->e_phoff), elf->e_phnum) < 0)
  802041:	0f b7 47 2c          	movzwl 0x2c(%edi),%eax
  802045:	50                   	push   %eax
  802046:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  80204c:	03 47 1c             	add    0x1c(%edi),%eax
  80204f:	50                   	push   %eax
  802050:	ff b5 e4 fd ff ff    	pushl  -0x21c(%ebp)
  802056:	ff 77 18             	pushl  0x18(%edi)
  802059:	e8 de ed ff ff       	call   800e3c <sys_exec>
  80205e:	83 c4 10             	add    $0x10,%esp
  802061:	85 c0                	test   %eax,%eax
  802063:	79 42                	jns    8020a7 <exec+0x1c6>
	}
	close(fd);
	fd = -1;

	// Set up Stack 
	if ((r = init_stack(0, argv, &tf_esp, now_addr)) < 0)
  802065:	8b 85 d0 fd ff ff    	mov    -0x230(%ebp),%eax
  80206b:	89 85 d4 fd ff ff    	mov    %eax,-0x22c(%ebp)
				     fd, ph->p_filesz, ph->p_offset, perm)) < 0)
			goto error;
		now_addr += ROUNDUP(ph->p_memsz + PGOFF(ph->p_va), PGSIZE);
	}
	close(fd);
	fd = -1;
  802071:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
  802076:	eb 0c                	jmp    802084 <exec+0x1a3>
  802078:	89 85 d4 fd ff ff    	mov    %eax,-0x22c(%ebp)
	int perm;	


	if ((r = open(prog, O_RDONLY)) < 0)
		return r;
	fd = r;
  80207e:	8b 9d d0 fd ff ff    	mov    -0x230(%ebp),%ebx
	if (sys_exec(elf->e_entry, tf_esp, (void *)(elf_buf + elf->e_phoff), elf->e_phnum) < 0)
		goto error;
	return 0;

error:
	sys_env_destroy(0);
  802084:	83 ec 0c             	sub    $0xc,%esp
  802087:	6a 00                	push   $0x0
  802089:	e8 01 ec ff ff       	call   800c8f <sys_env_destroy>
	close(fd);
  80208e:	89 1c 24             	mov    %ebx,(%esp)
  802091:	e8 09 f3 ff ff       	call   80139f <close>
	return r;
  802096:	83 c4 10             	add    $0x10,%esp
  802099:	8b 85 d4 fd ff ff    	mov    -0x22c(%ebp),%eax
  80209f:	89 85 d0 fd ff ff    	mov    %eax,-0x230(%ebp)
  8020a5:	eb 0a                	jmp    8020b1 <exec+0x1d0>
		return r;

	// Syscall to exec
	if (sys_exec(elf->e_entry, tf_esp, (void *)(elf_buf + elf->e_phoff), elf->e_phnum) < 0)
		goto error;
	return 0;
  8020a7:	c7 85 d0 fd ff ff 00 	movl   $0x0,-0x230(%ebp)
  8020ae:	00 00 00 

error:
	sys_env_destroy(0);
	close(fd);
	return r;
}
  8020b1:	8b 85 d0 fd ff ff    	mov    -0x230(%ebp),%eax
  8020b7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8020ba:	5b                   	pop    %ebx
  8020bb:	5e                   	pop    %esi
  8020bc:	5f                   	pop    %edi
  8020bd:	c9                   	leave  
  8020be:	c3                   	ret    

008020bf <execl>:
// Exec, taking command-line arguments array directly on the stack.
// NOTE: Must have a sentinal of NULL at the end of the args
// (none of the args may be NULL).
int
execl(const char *prog, const char *arg0, ...)
{
  8020bf:	55                   	push   %ebp
  8020c0:	89 e5                	mov    %esp,%ebp
  8020c2:	56                   	push   %esi
  8020c3:	53                   	push   %ebx
  8020c4:	8b 75 0c             	mov    0xc(%ebp),%esi
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  8020c7:	8d 45 14             	lea    0x14(%ebp),%eax
  8020ca:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8020ce:	74 5f                	je     80212f <execl+0x70>
{
	// We calculate argc by advancing the args until we hit NULL.
	// The contract of the function guarantees that the last
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
  8020d0:	b9 00 00 00 00       	mov    $0x0,%ecx
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
		argc++;
  8020d5:	41                   	inc    %ecx
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  8020d6:	89 c2                	mov    %eax,%edx
  8020d8:	83 c0 04             	add    $0x4,%eax
  8020db:	83 3a 00             	cmpl   $0x0,(%edx)
  8020de:	75 f5                	jne    8020d5 <execl+0x16>
		argc++;
	va_end(vl);

	// Now that we have the size of the args, do a second pass
	// and store the values in a VLA, which has the format of argv
	const char *argv[argc+2];
  8020e0:	8d 04 8d 26 00 00 00 	lea    0x26(,%ecx,4),%eax
  8020e7:	83 e0 f0             	and    $0xfffffff0,%eax
  8020ea:	29 c4                	sub    %eax,%esp
  8020ec:	8d 44 24 0f          	lea    0xf(%esp),%eax
  8020f0:	83 e0 f0             	and    $0xfffffff0,%eax
  8020f3:	89 c3                	mov    %eax,%ebx
	argv[0] = arg0;
  8020f5:	89 30                	mov    %esi,(%eax)
	argv[argc+1] = NULL;
  8020f7:	c7 44 88 04 00 00 00 	movl   $0x0,0x4(%eax,%ecx,4)
  8020fe:	00 

	va_start(vl, arg0);
  8020ff:	8d 55 10             	lea    0x10(%ebp),%edx
	unsigned i;
	for(i=0;i<argc;i++)
  802102:	89 ce                	mov    %ecx,%esi
  802104:	85 c9                	test   %ecx,%ecx
  802106:	74 14                	je     80211c <execl+0x5d>
  802108:	b8 00 00 00 00       	mov    $0x0,%eax
		argv[i+1] = va_arg(vl, const char *);
  80210d:	40                   	inc    %eax
  80210e:	89 d1                	mov    %edx,%ecx
  802110:	83 c2 04             	add    $0x4,%edx
  802113:	8b 09                	mov    (%ecx),%ecx
  802115:	89 0c 83             	mov    %ecx,(%ebx,%eax,4)
	argv[0] = arg0;
	argv[argc+1] = NULL;

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  802118:	39 f0                	cmp    %esi,%eax
  80211a:	72 f1                	jb     80210d <execl+0x4e>
		argv[i+1] = va_arg(vl, const char *);
	va_end(vl);
	return exec(prog, argv);
  80211c:	83 ec 08             	sub    $0x8,%esp
  80211f:	53                   	push   %ebx
  802120:	ff 75 08             	pushl  0x8(%ebp)
  802123:	e8 b9 fd ff ff       	call   801ee1 <exec>
}
  802128:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80212b:	5b                   	pop    %ebx
  80212c:	5e                   	pop    %esi
  80212d:	c9                   	leave  
  80212e:	c3                   	ret    
		argc++;
	va_end(vl);

	// Now that we have the size of the args, do a second pass
	// and store the values in a VLA, which has the format of argv
	const char *argv[argc+2];
  80212f:	83 ec 20             	sub    $0x20,%esp
  802132:	8d 44 24 0f          	lea    0xf(%esp),%eax
  802136:	83 e0 f0             	and    $0xfffffff0,%eax
  802139:	89 c3                	mov    %eax,%ebx
	argv[0] = arg0;
  80213b:	89 30                	mov    %esi,(%eax)
	argv[argc+1] = NULL;
  80213d:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
  802144:	eb d6                	jmp    80211c <execl+0x5d>

00802146 <spawnl>:
// Spawn, taking command-line arguments array directly on the stack.
// NOTE: Must have a sentinal of NULL at the end of the args
// (none of the args may be NULL).
int
spawnl(const char *prog, const char *arg0, ...)
{
  802146:	55                   	push   %ebp
  802147:	89 e5                	mov    %esp,%ebp
  802149:	56                   	push   %esi
  80214a:	53                   	push   %ebx
  80214b:	8b 75 0c             	mov    0xc(%ebp),%esi
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  80214e:	8d 45 14             	lea    0x14(%ebp),%eax
  802151:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  802155:	74 5f                	je     8021b6 <spawnl+0x70>
{
	// We calculate argc by advancing the args until we hit NULL.
	// The contract of the function guarantees that the last
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
  802157:	b9 00 00 00 00       	mov    $0x0,%ecx
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
		argc++;
  80215c:	41                   	inc    %ecx
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  80215d:	89 c2                	mov    %eax,%edx
  80215f:	83 c0 04             	add    $0x4,%eax
  802162:	83 3a 00             	cmpl   $0x0,(%edx)
  802165:	75 f5                	jne    80215c <spawnl+0x16>
		argc++;
	va_end(vl);

	// Now that we have the size of the args, do a second pass
	// and store the values in a VLA, which has the format of argv
	const char *argv[argc+2];
  802167:	8d 04 8d 26 00 00 00 	lea    0x26(,%ecx,4),%eax
  80216e:	83 e0 f0             	and    $0xfffffff0,%eax
  802171:	29 c4                	sub    %eax,%esp
  802173:	8d 44 24 0f          	lea    0xf(%esp),%eax
  802177:	83 e0 f0             	and    $0xfffffff0,%eax
  80217a:	89 c3                	mov    %eax,%ebx
	argv[0] = arg0;
  80217c:	89 30                	mov    %esi,(%eax)
	argv[argc+1] = NULL;
  80217e:	c7 44 88 04 00 00 00 	movl   $0x0,0x4(%eax,%ecx,4)
  802185:	00 

	va_start(vl, arg0);
  802186:	8d 55 10             	lea    0x10(%ebp),%edx
	unsigned i;
	for(i=0;i<argc;i++)
  802189:	89 ce                	mov    %ecx,%esi
  80218b:	85 c9                	test   %ecx,%ecx
  80218d:	74 14                	je     8021a3 <spawnl+0x5d>
  80218f:	b8 00 00 00 00       	mov    $0x0,%eax
		argv[i+1] = va_arg(vl, const char *);
  802194:	40                   	inc    %eax
  802195:	89 d1                	mov    %edx,%ecx
  802197:	83 c2 04             	add    $0x4,%edx
  80219a:	8b 09                	mov    (%ecx),%ecx
  80219c:	89 0c 83             	mov    %ecx,(%ebx,%eax,4)
	argv[0] = arg0;
	argv[argc+1] = NULL;

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  80219f:	39 f0                	cmp    %esi,%eax
  8021a1:	72 f1                	jb     802194 <spawnl+0x4e>
		argv[i+1] = va_arg(vl, const char *);
	va_end(vl);
	return spawn(prog, argv);
  8021a3:	83 ec 08             	sub    $0x8,%esp
  8021a6:	53                   	push   %ebx
  8021a7:	ff 75 08             	pushl  0x8(%ebp)
  8021aa:	e8 85 fa ff ff       	call   801c34 <spawn>
}
  8021af:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8021b2:	5b                   	pop    %ebx
  8021b3:	5e                   	pop    %esi
  8021b4:	c9                   	leave  
  8021b5:	c3                   	ret    
		argc++;
	va_end(vl);

	// Now that we have the size of the args, do a second pass
	// and store the values in a VLA, which has the format of argv
	const char *argv[argc+2];
  8021b6:	83 ec 20             	sub    $0x20,%esp
  8021b9:	8d 44 24 0f          	lea    0xf(%esp),%eax
  8021bd:	83 e0 f0             	and    $0xfffffff0,%eax
  8021c0:	89 c3                	mov    %eax,%ebx
	argv[0] = arg0;
  8021c2:	89 30                	mov    %esi,(%eax)
	argv[argc+1] = NULL;
  8021c4:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
  8021cb:	eb d6                	jmp    8021a3 <spawnl+0x5d>
  8021cd:	00 00                	add    %al,(%eax)
	...

008021d0 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8021d0:	55                   	push   %ebp
  8021d1:	89 e5                	mov    %esp,%ebp
  8021d3:	56                   	push   %esi
  8021d4:	53                   	push   %ebx
  8021d5:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8021d8:	83 ec 0c             	sub    $0xc,%esp
  8021db:	ff 75 08             	pushl  0x8(%ebp)
  8021de:	e8 ed ef ff ff       	call   8011d0 <fd2data>
  8021e3:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  8021e5:	83 c4 08             	add    $0x8,%esp
  8021e8:	68 a2 32 80 00       	push   $0x8032a2
  8021ed:	56                   	push   %esi
  8021ee:	e8 87 e6 ff ff       	call   80087a <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8021f3:	8b 43 04             	mov    0x4(%ebx),%eax
  8021f6:	2b 03                	sub    (%ebx),%eax
  8021f8:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  8021fe:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  802205:	00 00 00 
	stat->st_dev = &devpipe;
  802208:	c7 86 88 00 00 00 28 	movl   $0x804028,0x88(%esi)
  80220f:	40 80 00 
	return 0;
}
  802212:	b8 00 00 00 00       	mov    $0x0,%eax
  802217:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80221a:	5b                   	pop    %ebx
  80221b:	5e                   	pop    %esi
  80221c:	c9                   	leave  
  80221d:	c3                   	ret    

0080221e <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  80221e:	55                   	push   %ebp
  80221f:	89 e5                	mov    %esp,%ebp
  802221:	53                   	push   %ebx
  802222:	83 ec 0c             	sub    $0xc,%esp
  802225:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  802228:	53                   	push   %ebx
  802229:	6a 00                	push   $0x0
  80222b:	e8 16 eb ff ff       	call   800d46 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  802230:	89 1c 24             	mov    %ebx,(%esp)
  802233:	e8 98 ef ff ff       	call   8011d0 <fd2data>
  802238:	83 c4 08             	add    $0x8,%esp
  80223b:	50                   	push   %eax
  80223c:	6a 00                	push   $0x0
  80223e:	e8 03 eb ff ff       	call   800d46 <sys_page_unmap>
}
  802243:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802246:	c9                   	leave  
  802247:	c3                   	ret    

00802248 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  802248:	55                   	push   %ebp
  802249:	89 e5                	mov    %esp,%ebp
  80224b:	57                   	push   %edi
  80224c:	56                   	push   %esi
  80224d:	53                   	push   %ebx
  80224e:	83 ec 1c             	sub    $0x1c,%esp
  802251:	89 c7                	mov    %eax,%edi
  802253:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  802256:	a1 04 50 80 00       	mov    0x805004,%eax
  80225b:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  80225e:	83 ec 0c             	sub    $0xc,%esp
  802261:	57                   	push   %edi
  802262:	e8 99 06 00 00       	call   802900 <pageref>
  802267:	89 c6                	mov    %eax,%esi
  802269:	83 c4 04             	add    $0x4,%esp
  80226c:	ff 75 e4             	pushl  -0x1c(%ebp)
  80226f:	e8 8c 06 00 00       	call   802900 <pageref>
  802274:	83 c4 10             	add    $0x10,%esp
  802277:	39 c6                	cmp    %eax,%esi
  802279:	0f 94 c0             	sete   %al
  80227c:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  80227f:	8b 15 04 50 80 00    	mov    0x805004,%edx
  802285:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  802288:	39 cb                	cmp    %ecx,%ebx
  80228a:	75 08                	jne    802294 <_pipeisclosed+0x4c>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  80228c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80228f:	5b                   	pop    %ebx
  802290:	5e                   	pop    %esi
  802291:	5f                   	pop    %edi
  802292:	c9                   	leave  
  802293:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  802294:	83 f8 01             	cmp    $0x1,%eax
  802297:	75 bd                	jne    802256 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  802299:	8b 42 58             	mov    0x58(%edx),%eax
  80229c:	6a 01                	push   $0x1
  80229e:	50                   	push   %eax
  80229f:	53                   	push   %ebx
  8022a0:	68 a9 32 80 00       	push   $0x8032a9
  8022a5:	e8 1a e0 ff ff       	call   8002c4 <cprintf>
  8022aa:	83 c4 10             	add    $0x10,%esp
  8022ad:	eb a7                	jmp    802256 <_pipeisclosed+0xe>

008022af <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8022af:	55                   	push   %ebp
  8022b0:	89 e5                	mov    %esp,%ebp
  8022b2:	57                   	push   %edi
  8022b3:	56                   	push   %esi
  8022b4:	53                   	push   %ebx
  8022b5:	83 ec 28             	sub    $0x28,%esp
  8022b8:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  8022bb:	56                   	push   %esi
  8022bc:	e8 0f ef ff ff       	call   8011d0 <fd2data>
  8022c1:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8022c3:	83 c4 10             	add    $0x10,%esp
  8022c6:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8022ca:	75 4a                	jne    802316 <devpipe_write+0x67>
  8022cc:	bf 00 00 00 00       	mov    $0x0,%edi
  8022d1:	eb 56                	jmp    802329 <devpipe_write+0x7a>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  8022d3:	89 da                	mov    %ebx,%edx
  8022d5:	89 f0                	mov    %esi,%eax
  8022d7:	e8 6c ff ff ff       	call   802248 <_pipeisclosed>
  8022dc:	85 c0                	test   %eax,%eax
  8022de:	75 4d                	jne    80232d <devpipe_write+0x7e>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  8022e0:	e8 f0 e9 ff ff       	call   800cd5 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8022e5:	8b 43 04             	mov    0x4(%ebx),%eax
  8022e8:	8b 13                	mov    (%ebx),%edx
  8022ea:	83 c2 20             	add    $0x20,%edx
  8022ed:	39 d0                	cmp    %edx,%eax
  8022ef:	73 e2                	jae    8022d3 <devpipe_write+0x24>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  8022f1:	89 c2                	mov    %eax,%edx
  8022f3:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  8022f9:	79 05                	jns    802300 <devpipe_write+0x51>
  8022fb:	4a                   	dec    %edx
  8022fc:	83 ca e0             	or     $0xffffffe0,%edx
  8022ff:	42                   	inc    %edx
  802300:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802303:	8a 0c 39             	mov    (%ecx,%edi,1),%cl
  802306:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  80230a:	40                   	inc    %eax
  80230b:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80230e:	47                   	inc    %edi
  80230f:	39 7d 10             	cmp    %edi,0x10(%ebp)
  802312:	77 07                	ja     80231b <devpipe_write+0x6c>
  802314:	eb 13                	jmp    802329 <devpipe_write+0x7a>
  802316:	bf 00 00 00 00       	mov    $0x0,%edi
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  80231b:	8b 43 04             	mov    0x4(%ebx),%eax
  80231e:	8b 13                	mov    (%ebx),%edx
  802320:	83 c2 20             	add    $0x20,%edx
  802323:	39 d0                	cmp    %edx,%eax
  802325:	73 ac                	jae    8022d3 <devpipe_write+0x24>
  802327:	eb c8                	jmp    8022f1 <devpipe_write+0x42>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  802329:	89 f8                	mov    %edi,%eax
  80232b:	eb 05                	jmp    802332 <devpipe_write+0x83>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80232d:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  802332:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802335:	5b                   	pop    %ebx
  802336:	5e                   	pop    %esi
  802337:	5f                   	pop    %edi
  802338:	c9                   	leave  
  802339:	c3                   	ret    

0080233a <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  80233a:	55                   	push   %ebp
  80233b:	89 e5                	mov    %esp,%ebp
  80233d:	57                   	push   %edi
  80233e:	56                   	push   %esi
  80233f:	53                   	push   %ebx
  802340:	83 ec 18             	sub    $0x18,%esp
  802343:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  802346:	57                   	push   %edi
  802347:	e8 84 ee ff ff       	call   8011d0 <fd2data>
  80234c:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80234e:	83 c4 10             	add    $0x10,%esp
  802351:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  802355:	75 44                	jne    80239b <devpipe_read+0x61>
  802357:	be 00 00 00 00       	mov    $0x0,%esi
  80235c:	eb 4f                	jmp    8023ad <devpipe_read+0x73>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
				return i;
  80235e:	89 f0                	mov    %esi,%eax
  802360:	eb 54                	jmp    8023b6 <devpipe_read+0x7c>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  802362:	89 da                	mov    %ebx,%edx
  802364:	89 f8                	mov    %edi,%eax
  802366:	e8 dd fe ff ff       	call   802248 <_pipeisclosed>
  80236b:	85 c0                	test   %eax,%eax
  80236d:	75 42                	jne    8023b1 <devpipe_read+0x77>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  80236f:	e8 61 e9 ff ff       	call   800cd5 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  802374:	8b 03                	mov    (%ebx),%eax
  802376:	3b 43 04             	cmp    0x4(%ebx),%eax
  802379:	74 e7                	je     802362 <devpipe_read+0x28>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  80237b:	25 1f 00 00 80       	and    $0x8000001f,%eax
  802380:	79 05                	jns    802387 <devpipe_read+0x4d>
  802382:	48                   	dec    %eax
  802383:	83 c8 e0             	or     $0xffffffe0,%eax
  802386:	40                   	inc    %eax
  802387:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  80238b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80238e:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  802391:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802393:	46                   	inc    %esi
  802394:	39 75 10             	cmp    %esi,0x10(%ebp)
  802397:	77 07                	ja     8023a0 <devpipe_read+0x66>
  802399:	eb 12                	jmp    8023ad <devpipe_read+0x73>
  80239b:	be 00 00 00 00       	mov    $0x0,%esi
		while (p->p_rpos == p->p_wpos) {
  8023a0:	8b 03                	mov    (%ebx),%eax
  8023a2:	3b 43 04             	cmp    0x4(%ebx),%eax
  8023a5:	75 d4                	jne    80237b <devpipe_read+0x41>
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  8023a7:	85 f6                	test   %esi,%esi
  8023a9:	75 b3                	jne    80235e <devpipe_read+0x24>
  8023ab:	eb b5                	jmp    802362 <devpipe_read+0x28>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  8023ad:	89 f0                	mov    %esi,%eax
  8023af:	eb 05                	jmp    8023b6 <devpipe_read+0x7c>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8023b1:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  8023b6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8023b9:	5b                   	pop    %ebx
  8023ba:	5e                   	pop    %esi
  8023bb:	5f                   	pop    %edi
  8023bc:	c9                   	leave  
  8023bd:	c3                   	ret    

008023be <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  8023be:	55                   	push   %ebp
  8023bf:	89 e5                	mov    %esp,%ebp
  8023c1:	57                   	push   %edi
  8023c2:	56                   	push   %esi
  8023c3:	53                   	push   %ebx
  8023c4:	83 ec 28             	sub    $0x28,%esp
  8023c7:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  8023ca:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8023cd:	50                   	push   %eax
  8023ce:	e8 15 ee ff ff       	call   8011e8 <fd_alloc>
  8023d3:	89 c3                	mov    %eax,%ebx
  8023d5:	83 c4 10             	add    $0x10,%esp
  8023d8:	85 c0                	test   %eax,%eax
  8023da:	0f 88 24 01 00 00    	js     802504 <pipe+0x146>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8023e0:	83 ec 04             	sub    $0x4,%esp
  8023e3:	68 07 04 00 00       	push   $0x407
  8023e8:	ff 75 e4             	pushl  -0x1c(%ebp)
  8023eb:	6a 00                	push   $0x0
  8023ed:	e8 0a e9 ff ff       	call   800cfc <sys_page_alloc>
  8023f2:	89 c3                	mov    %eax,%ebx
  8023f4:	83 c4 10             	add    $0x10,%esp
  8023f7:	85 c0                	test   %eax,%eax
  8023f9:	0f 88 05 01 00 00    	js     802504 <pipe+0x146>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  8023ff:	83 ec 0c             	sub    $0xc,%esp
  802402:	8d 45 e0             	lea    -0x20(%ebp),%eax
  802405:	50                   	push   %eax
  802406:	e8 dd ed ff ff       	call   8011e8 <fd_alloc>
  80240b:	89 c3                	mov    %eax,%ebx
  80240d:	83 c4 10             	add    $0x10,%esp
  802410:	85 c0                	test   %eax,%eax
  802412:	0f 88 dc 00 00 00    	js     8024f4 <pipe+0x136>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802418:	83 ec 04             	sub    $0x4,%esp
  80241b:	68 07 04 00 00       	push   $0x407
  802420:	ff 75 e0             	pushl  -0x20(%ebp)
  802423:	6a 00                	push   $0x0
  802425:	e8 d2 e8 ff ff       	call   800cfc <sys_page_alloc>
  80242a:	89 c3                	mov    %eax,%ebx
  80242c:	83 c4 10             	add    $0x10,%esp
  80242f:	85 c0                	test   %eax,%eax
  802431:	0f 88 bd 00 00 00    	js     8024f4 <pipe+0x136>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  802437:	83 ec 0c             	sub    $0xc,%esp
  80243a:	ff 75 e4             	pushl  -0x1c(%ebp)
  80243d:	e8 8e ed ff ff       	call   8011d0 <fd2data>
  802442:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802444:	83 c4 0c             	add    $0xc,%esp
  802447:	68 07 04 00 00       	push   $0x407
  80244c:	50                   	push   %eax
  80244d:	6a 00                	push   $0x0
  80244f:	e8 a8 e8 ff ff       	call   800cfc <sys_page_alloc>
  802454:	89 c3                	mov    %eax,%ebx
  802456:	83 c4 10             	add    $0x10,%esp
  802459:	85 c0                	test   %eax,%eax
  80245b:	0f 88 83 00 00 00    	js     8024e4 <pipe+0x126>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802461:	83 ec 0c             	sub    $0xc,%esp
  802464:	ff 75 e0             	pushl  -0x20(%ebp)
  802467:	e8 64 ed ff ff       	call   8011d0 <fd2data>
  80246c:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  802473:	50                   	push   %eax
  802474:	6a 00                	push   $0x0
  802476:	56                   	push   %esi
  802477:	6a 00                	push   $0x0
  802479:	e8 a2 e8 ff ff       	call   800d20 <sys_page_map>
  80247e:	89 c3                	mov    %eax,%ebx
  802480:	83 c4 20             	add    $0x20,%esp
  802483:	85 c0                	test   %eax,%eax
  802485:	78 4f                	js     8024d6 <pipe+0x118>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  802487:	8b 15 28 40 80 00    	mov    0x804028,%edx
  80248d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802490:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  802492:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802495:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  80249c:	8b 15 28 40 80 00    	mov    0x804028,%edx
  8024a2:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8024a5:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8024a7:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8024aa:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  8024b1:	83 ec 0c             	sub    $0xc,%esp
  8024b4:	ff 75 e4             	pushl  -0x1c(%ebp)
  8024b7:	e8 04 ed ff ff       	call   8011c0 <fd2num>
  8024bc:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  8024be:	83 c4 04             	add    $0x4,%esp
  8024c1:	ff 75 e0             	pushl  -0x20(%ebp)
  8024c4:	e8 f7 ec ff ff       	call   8011c0 <fd2num>
  8024c9:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  8024cc:	83 c4 10             	add    $0x10,%esp
  8024cf:	bb 00 00 00 00       	mov    $0x0,%ebx
  8024d4:	eb 2e                	jmp    802504 <pipe+0x146>

    err3:
	sys_page_unmap(0, va);
  8024d6:	83 ec 08             	sub    $0x8,%esp
  8024d9:	56                   	push   %esi
  8024da:	6a 00                	push   $0x0
  8024dc:	e8 65 e8 ff ff       	call   800d46 <sys_page_unmap>
  8024e1:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  8024e4:	83 ec 08             	sub    $0x8,%esp
  8024e7:	ff 75 e0             	pushl  -0x20(%ebp)
  8024ea:	6a 00                	push   $0x0
  8024ec:	e8 55 e8 ff ff       	call   800d46 <sys_page_unmap>
  8024f1:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  8024f4:	83 ec 08             	sub    $0x8,%esp
  8024f7:	ff 75 e4             	pushl  -0x1c(%ebp)
  8024fa:	6a 00                	push   $0x0
  8024fc:	e8 45 e8 ff ff       	call   800d46 <sys_page_unmap>
  802501:	83 c4 10             	add    $0x10,%esp
    err:
	return r;
}
  802504:	89 d8                	mov    %ebx,%eax
  802506:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802509:	5b                   	pop    %ebx
  80250a:	5e                   	pop    %esi
  80250b:	5f                   	pop    %edi
  80250c:	c9                   	leave  
  80250d:	c3                   	ret    

0080250e <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  80250e:	55                   	push   %ebp
  80250f:	89 e5                	mov    %esp,%ebp
  802511:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802514:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802517:	50                   	push   %eax
  802518:	ff 75 08             	pushl  0x8(%ebp)
  80251b:	e8 3b ed ff ff       	call   80125b <fd_lookup>
  802520:	83 c4 10             	add    $0x10,%esp
  802523:	85 c0                	test   %eax,%eax
  802525:	78 18                	js     80253f <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  802527:	83 ec 0c             	sub    $0xc,%esp
  80252a:	ff 75 f4             	pushl  -0xc(%ebp)
  80252d:	e8 9e ec ff ff       	call   8011d0 <fd2data>
	return _pipeisclosed(fd, p);
  802532:	89 c2                	mov    %eax,%edx
  802534:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802537:	e8 0c fd ff ff       	call   802248 <_pipeisclosed>
  80253c:	83 c4 10             	add    $0x10,%esp
}
  80253f:	c9                   	leave  
  802540:	c3                   	ret    
  802541:	00 00                	add    %al,(%eax)
	...

00802544 <wait>:
#include <inc/lib.h>

// Waits until 'envid' exits.
void
wait(envid_t envid)
{
  802544:	55                   	push   %ebp
  802545:	89 e5                	mov    %esp,%ebp
  802547:	57                   	push   %edi
  802548:	56                   	push   %esi
  802549:	53                   	push   %ebx
  80254a:	83 ec 0c             	sub    $0xc,%esp
  80254d:	8b 55 08             	mov    0x8(%ebp),%edx
	const volatile struct Env *e;

	assert(envid != 0);
  802550:	85 d2                	test   %edx,%edx
  802552:	75 16                	jne    80256a <wait+0x26>
  802554:	68 c1 32 80 00       	push   $0x8032c1
  802559:	68 c3 31 80 00       	push   $0x8031c3
  80255e:	6a 09                	push   $0x9
  802560:	68 cc 32 80 00       	push   $0x8032cc
  802565:	e8 82 dc ff ff       	call   8001ec <_panic>
	e = &envs[ENVX(envid)];
  80256a:	89 d0                	mov    %edx,%eax
  80256c:	25 ff 03 00 00       	and    $0x3ff,%eax
	while (e->env_id == envid && e->env_status != ENV_FREE)
  802571:	89 c1                	mov    %eax,%ecx
  802573:	c1 e1 07             	shl    $0x7,%ecx
  802576:	8d 8c 81 08 00 c0 ee 	lea    -0x113ffff8(%ecx,%eax,4),%ecx
  80257d:	8b 79 40             	mov    0x40(%ecx),%edi
  802580:	39 d7                	cmp    %edx,%edi
  802582:	75 36                	jne    8025ba <wait+0x76>
  802584:	89 c2                	mov    %eax,%edx
  802586:	c1 e2 07             	shl    $0x7,%edx
  802589:	8d 94 82 04 00 c0 ee 	lea    -0x113ffffc(%edx,%eax,4),%edx
  802590:	8b 52 50             	mov    0x50(%edx),%edx
  802593:	85 d2                	test   %edx,%edx
  802595:	74 23                	je     8025ba <wait+0x76>
  802597:	89 c2                	mov    %eax,%edx
  802599:	c1 e2 07             	shl    $0x7,%edx
  80259c:	8d 34 82             	lea    (%edx,%eax,4),%esi
  80259f:	89 cb                	mov    %ecx,%ebx
  8025a1:	81 c6 04 00 c0 ee    	add    $0xeec00004,%esi
		sys_yield();
  8025a7:	e8 29 e7 ff ff       	call   800cd5 <sys_yield>
{
	const volatile struct Env *e;

	assert(envid != 0);
	e = &envs[ENVX(envid)];
	while (e->env_id == envid && e->env_status != ENV_FREE)
  8025ac:	8b 43 40             	mov    0x40(%ebx),%eax
  8025af:	39 f8                	cmp    %edi,%eax
  8025b1:	75 07                	jne    8025ba <wait+0x76>
  8025b3:	8b 46 50             	mov    0x50(%esi),%eax
  8025b6:	85 c0                	test   %eax,%eax
  8025b8:	75 ed                	jne    8025a7 <wait+0x63>
		sys_yield();
}
  8025ba:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8025bd:	5b                   	pop    %ebx
  8025be:	5e                   	pop    %esi
  8025bf:	5f                   	pop    %edi
  8025c0:	c9                   	leave  
  8025c1:	c3                   	ret    
	...

008025c4 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  8025c4:	55                   	push   %ebp
  8025c5:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  8025c7:	b8 00 00 00 00       	mov    $0x0,%eax
  8025cc:	c9                   	leave  
  8025cd:	c3                   	ret    

008025ce <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8025ce:	55                   	push   %ebp
  8025cf:	89 e5                	mov    %esp,%ebp
  8025d1:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  8025d4:	68 d7 32 80 00       	push   $0x8032d7
  8025d9:	ff 75 0c             	pushl  0xc(%ebp)
  8025dc:	e8 99 e2 ff ff       	call   80087a <strcpy>
	return 0;
}
  8025e1:	b8 00 00 00 00       	mov    $0x0,%eax
  8025e6:	c9                   	leave  
  8025e7:	c3                   	ret    

008025e8 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8025e8:	55                   	push   %ebp
  8025e9:	89 e5                	mov    %esp,%ebp
  8025eb:	57                   	push   %edi
  8025ec:	56                   	push   %esi
  8025ed:	53                   	push   %ebx
  8025ee:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8025f4:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8025f8:	74 45                	je     80263f <devcons_write+0x57>
  8025fa:	b8 00 00 00 00       	mov    $0x0,%eax
  8025ff:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  802604:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  80260a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80260d:	29 c3                	sub    %eax,%ebx
		if (m > sizeof(buf) - 1)
  80260f:	83 fb 7f             	cmp    $0x7f,%ebx
  802612:	76 05                	jbe    802619 <devcons_write+0x31>
			m = sizeof(buf) - 1;
  802614:	bb 7f 00 00 00       	mov    $0x7f,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  802619:	83 ec 04             	sub    $0x4,%esp
  80261c:	53                   	push   %ebx
  80261d:	03 45 0c             	add    0xc(%ebp),%eax
  802620:	50                   	push   %eax
  802621:	57                   	push   %edi
  802622:	e8 14 e4 ff ff       	call   800a3b <memmove>
		sys_cputs(buf, m);
  802627:	83 c4 08             	add    $0x8,%esp
  80262a:	53                   	push   %ebx
  80262b:	57                   	push   %edi
  80262c:	e8 14 e6 ff ff       	call   800c45 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802631:	01 de                	add    %ebx,%esi
  802633:	89 f0                	mov    %esi,%eax
  802635:	83 c4 10             	add    $0x10,%esp
  802638:	3b 75 10             	cmp    0x10(%ebp),%esi
  80263b:	72 cd                	jb     80260a <devcons_write+0x22>
  80263d:	eb 05                	jmp    802644 <devcons_write+0x5c>
  80263f:	be 00 00 00 00       	mov    $0x0,%esi
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  802644:	89 f0                	mov    %esi,%eax
  802646:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802649:	5b                   	pop    %ebx
  80264a:	5e                   	pop    %esi
  80264b:	5f                   	pop    %edi
  80264c:	c9                   	leave  
  80264d:	c3                   	ret    

0080264e <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  80264e:	55                   	push   %ebp
  80264f:	89 e5                	mov    %esp,%ebp
  802651:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  802654:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  802658:	75 07                	jne    802661 <devcons_read+0x13>
  80265a:	eb 25                	jmp    802681 <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  80265c:	e8 74 e6 ff ff       	call   800cd5 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  802661:	e8 05 e6 ff ff       	call   800c6b <sys_cgetc>
  802666:	85 c0                	test   %eax,%eax
  802668:	74 f2                	je     80265c <devcons_read+0xe>
  80266a:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  80266c:	85 c0                	test   %eax,%eax
  80266e:	78 1d                	js     80268d <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  802670:	83 f8 04             	cmp    $0x4,%eax
  802673:	74 13                	je     802688 <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  802675:	8b 45 0c             	mov    0xc(%ebp),%eax
  802678:	88 10                	mov    %dl,(%eax)
	return 1;
  80267a:	b8 01 00 00 00       	mov    $0x1,%eax
  80267f:	eb 0c                	jmp    80268d <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  802681:	b8 00 00 00 00       	mov    $0x0,%eax
  802686:	eb 05                	jmp    80268d <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  802688:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  80268d:	c9                   	leave  
  80268e:	c3                   	ret    

0080268f <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  80268f:	55                   	push   %ebp
  802690:	89 e5                	mov    %esp,%ebp
  802692:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  802695:	8b 45 08             	mov    0x8(%ebp),%eax
  802698:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  80269b:	6a 01                	push   $0x1
  80269d:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8026a0:	50                   	push   %eax
  8026a1:	e8 9f e5 ff ff       	call   800c45 <sys_cputs>
  8026a6:	83 c4 10             	add    $0x10,%esp
}
  8026a9:	c9                   	leave  
  8026aa:	c3                   	ret    

008026ab <getchar>:

int
getchar(void)
{
  8026ab:	55                   	push   %ebp
  8026ac:	89 e5                	mov    %esp,%ebp
  8026ae:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  8026b1:	6a 01                	push   $0x1
  8026b3:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8026b6:	50                   	push   %eax
  8026b7:	6a 00                	push   $0x0
  8026b9:	e8 1e ee ff ff       	call   8014dc <read>
	if (r < 0)
  8026be:	83 c4 10             	add    $0x10,%esp
  8026c1:	85 c0                	test   %eax,%eax
  8026c3:	78 0f                	js     8026d4 <getchar+0x29>
		return r;
	if (r < 1)
  8026c5:	85 c0                	test   %eax,%eax
  8026c7:	7e 06                	jle    8026cf <getchar+0x24>
		return -E_EOF;
	return c;
  8026c9:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8026cd:	eb 05                	jmp    8026d4 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  8026cf:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  8026d4:	c9                   	leave  
  8026d5:	c3                   	ret    

008026d6 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  8026d6:	55                   	push   %ebp
  8026d7:	89 e5                	mov    %esp,%ebp
  8026d9:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8026dc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8026df:	50                   	push   %eax
  8026e0:	ff 75 08             	pushl  0x8(%ebp)
  8026e3:	e8 73 eb ff ff       	call   80125b <fd_lookup>
  8026e8:	83 c4 10             	add    $0x10,%esp
  8026eb:	85 c0                	test   %eax,%eax
  8026ed:	78 11                	js     802700 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  8026ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8026f2:	8b 15 44 40 80 00    	mov    0x804044,%edx
  8026f8:	39 10                	cmp    %edx,(%eax)
  8026fa:	0f 94 c0             	sete   %al
  8026fd:	0f b6 c0             	movzbl %al,%eax
}
  802700:	c9                   	leave  
  802701:	c3                   	ret    

00802702 <opencons>:

int
opencons(void)
{
  802702:	55                   	push   %ebp
  802703:	89 e5                	mov    %esp,%ebp
  802705:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802708:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80270b:	50                   	push   %eax
  80270c:	e8 d7 ea ff ff       	call   8011e8 <fd_alloc>
  802711:	83 c4 10             	add    $0x10,%esp
  802714:	85 c0                	test   %eax,%eax
  802716:	78 3a                	js     802752 <opencons+0x50>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802718:	83 ec 04             	sub    $0x4,%esp
  80271b:	68 07 04 00 00       	push   $0x407
  802720:	ff 75 f4             	pushl  -0xc(%ebp)
  802723:	6a 00                	push   $0x0
  802725:	e8 d2 e5 ff ff       	call   800cfc <sys_page_alloc>
  80272a:	83 c4 10             	add    $0x10,%esp
  80272d:	85 c0                	test   %eax,%eax
  80272f:	78 21                	js     802752 <opencons+0x50>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  802731:	8b 15 44 40 80 00    	mov    0x804044,%edx
  802737:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80273a:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80273c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80273f:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  802746:	83 ec 0c             	sub    $0xc,%esp
  802749:	50                   	push   %eax
  80274a:	e8 71 ea ff ff       	call   8011c0 <fd2num>
  80274f:	83 c4 10             	add    $0x10,%esp
}
  802752:	c9                   	leave  
  802753:	c3                   	ret    

00802754 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  802754:	55                   	push   %ebp
  802755:	89 e5                	mov    %esp,%ebp
  802757:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  80275a:	83 3d 00 70 80 00 00 	cmpl   $0x0,0x807000
  802761:	75 52                	jne    8027b5 <set_pgfault_handler+0x61>
		// First time through!	
		// LAB 4: Your code here.

		//int sys_page_alloc(envid_t envid, void *va, int perm)
		r = sys_page_alloc(0, (void*)(UXSTACKTOP - PGSIZE), PTE_U | PTE_W | PTE_P);
  802763:	83 ec 04             	sub    $0x4,%esp
  802766:	6a 07                	push   $0x7
  802768:	68 00 f0 bf ee       	push   $0xeebff000
  80276d:	6a 00                	push   $0x0
  80276f:	e8 88 e5 ff ff       	call   800cfc <sys_page_alloc>
		if (r < 0) {
  802774:	83 c4 10             	add    $0x10,%esp
  802777:	85 c0                	test   %eax,%eax
  802779:	79 12                	jns    80278d <set_pgfault_handler+0x39>
			panic("sys_page_alloc error : %e\n", r);
  80277b:	50                   	push   %eax
  80277c:	68 e3 32 80 00       	push   $0x8032e3
  802781:	6a 24                	push   $0x24
  802783:	68 fe 32 80 00       	push   $0x8032fe
  802788:	e8 5f da ff ff       	call   8001ec <_panic>
		}

		// how to know envid, put 0, envid2env will help us to get curenv in syscall
		r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);		
  80278d:	83 ec 08             	sub    $0x8,%esp
  802790:	68 c0 27 80 00       	push   $0x8027c0
  802795:	6a 00                	push   $0x0
  802797:	e8 13 e6 ff ff       	call   800daf <sys_env_set_pgfault_upcall>
		if (r < 0) {
  80279c:	83 c4 10             	add    $0x10,%esp
  80279f:	85 c0                	test   %eax,%eax
  8027a1:	79 12                	jns    8027b5 <set_pgfault_handler+0x61>
			panic("sys_env_set_pgfault_upcall error : %e\n", r);
  8027a3:	50                   	push   %eax
  8027a4:	68 0c 33 80 00       	push   $0x80330c
  8027a9:	6a 2a                	push   $0x2a
  8027ab:	68 fe 32 80 00       	push   $0x8032fe
  8027b0:	e8 37 da ff ff       	call   8001ec <_panic>
		}
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8027b5:	8b 45 08             	mov    0x8(%ebp),%eax
  8027b8:	a3 00 70 80 00       	mov    %eax,0x807000
}
  8027bd:	c9                   	leave  
  8027be:	c3                   	ret    
	...

008027c0 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8027c0:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8027c1:	a1 00 70 80 00       	mov    0x807000,%eax
	call *%eax
  8027c6:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8027c8:	83 c4 04             	add    $0x4,%esp
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	
	// fix old esp
	movl 0x30(%esp), %eax
  8027cb:	8b 44 24 30          	mov    0x30(%esp),%eax
	subl $0x4, %eax
  8027cf:	83 e8 04             	sub    $0x4,%eax
	movl %eax, 0x30(%esp)
  8027d2:	89 44 24 30          	mov    %eax,0x30(%esp)

	// set trap-time %eip
	movl 0x28(%esp), %ebx
  8027d6:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	movl %ebx, (%eax)
  8027da:	89 18                	mov    %ebx,(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $0x08, %esp 	// ignore err_code and fault_va
  8027dc:	83 c4 08             	add    $0x8,%esp
	popal 				// restore registers
  8027df:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x04, %esp 	// ignore eip 
  8027e0:	83 c4 04             	add    $0x4,%esp
	popfl				// modify eflags
  8027e3:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  8027e4:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  8027e5:	c3                   	ret    
	...

008027e8 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8027e8:	55                   	push   %ebp
  8027e9:	89 e5                	mov    %esp,%ebp
  8027eb:	56                   	push   %esi
  8027ec:	53                   	push   %ebx
  8027ed:	8b 75 08             	mov    0x8(%ebp),%esi
  8027f0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8027f3:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// cprintf("0x%x 0x%x 0x%x\n", (uint32_t)from_env_store, (uint32_t)pg, (uint32_t)perm_store);
	int r;
	if (pg != NULL) {
  8027f6:	85 c0                	test   %eax,%eax
  8027f8:	74 0e                	je     802808 <ipc_recv+0x20>
		r = sys_ipc_recv(pg);
  8027fa:	83 ec 0c             	sub    $0xc,%esp
  8027fd:	50                   	push   %eax
  8027fe:	e8 f4 e5 ff ff       	call   800df7 <sys_ipc_recv>
  802803:	83 c4 10             	add    $0x10,%esp
  802806:	eb 10                	jmp    802818 <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv((void *)UTOP);
  802808:	83 ec 0c             	sub    $0xc,%esp
  80280b:	68 00 00 c0 ee       	push   $0xeec00000
  802810:	e8 e2 e5 ff ff       	call   800df7 <sys_ipc_recv>
  802815:	83 c4 10             	add    $0x10,%esp
	}

	if (r == 0) {
  802818:	85 c0                	test   %eax,%eax
  80281a:	75 26                	jne    802842 <ipc_recv+0x5a>
		if (from_env_store != NULL) *from_env_store = thisenv->env_ipc_from;
  80281c:	85 f6                	test   %esi,%esi
  80281e:	74 0a                	je     80282a <ipc_recv+0x42>
  802820:	a1 04 50 80 00       	mov    0x805004,%eax
  802825:	8b 40 74             	mov    0x74(%eax),%eax
  802828:	89 06                	mov    %eax,(%esi)
		if (perm_store != NULL) *perm_store = thisenv->env_ipc_perm;
  80282a:	85 db                	test   %ebx,%ebx
  80282c:	74 0a                	je     802838 <ipc_recv+0x50>
  80282e:	a1 04 50 80 00       	mov    0x805004,%eax
  802833:	8b 40 78             	mov    0x78(%eax),%eax
  802836:	89 03                	mov    %eax,(%ebx)
		return thisenv->env_ipc_value;
  802838:	a1 04 50 80 00       	mov    0x805004,%eax
  80283d:	8b 40 70             	mov    0x70(%eax),%eax
  802840:	eb 14                	jmp    802856 <ipc_recv+0x6e>
	} else {
		// fails;
		if (from_env_store != NULL) *from_env_store = 0;
  802842:	85 f6                	test   %esi,%esi
  802844:	74 06                	je     80284c <ipc_recv+0x64>
  802846:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if (perm_store != NULL) *perm_store = 0;
  80284c:	85 db                	test   %ebx,%ebx
  80284e:	74 06                	je     802856 <ipc_recv+0x6e>
  802850:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		return r;
	}
}
  802856:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802859:	5b                   	pop    %ebx
  80285a:	5e                   	pop    %esi
  80285b:	c9                   	leave  
  80285c:	c3                   	ret    

0080285d <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80285d:	55                   	push   %ebp
  80285e:	89 e5                	mov    %esp,%ebp
  802860:	57                   	push   %edi
  802861:	56                   	push   %esi
  802862:	53                   	push   %ebx
  802863:	83 ec 0c             	sub    $0xc,%esp
  802866:	8b 7d 0c             	mov    0xc(%ebp),%edi
  802869:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80286c:	8b 75 14             	mov    0x14(%ebp),%esi
	// LAB 4: Your code here.
	// int sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
	int r;
	if (pg == NULL) pg = (void *)UTOP;
  80286f:	85 db                	test   %ebx,%ebx
  802871:	75 25                	jne    802898 <ipc_send+0x3b>
  802873:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
  802878:	eb 1e                	jmp    802898 <ipc_send+0x3b>
	
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) != 0) {
		if (r == -E_IPC_NOT_RECV) {
  80287a:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80287d:	75 07                	jne    802886 <ipc_send+0x29>
			// cprintf("Try Again and Again....\n");
			sys_yield();
  80287f:	e8 51 e4 ff ff       	call   800cd5 <sys_yield>
  802884:	eb 12                	jmp    802898 <ipc_send+0x3b>
		} else {
			panic("ipc_send error %e\n", r);
  802886:	50                   	push   %eax
  802887:	68 34 33 80 00       	push   $0x803334
  80288c:	6a 43                	push   $0x43
  80288e:	68 47 33 80 00       	push   $0x803347
  802893:	e8 54 d9 ff ff       	call   8001ec <_panic>
	// LAB 4: Your code here.
	// int sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
	int r;
	if (pg == NULL) pg = (void *)UTOP;
	
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) != 0) {
  802898:	56                   	push   %esi
  802899:	53                   	push   %ebx
  80289a:	57                   	push   %edi
  80289b:	ff 75 08             	pushl  0x8(%ebp)
  80289e:	e8 2f e5 ff ff       	call   800dd2 <sys_ipc_try_send>
  8028a3:	83 c4 10             	add    $0x10,%esp
  8028a6:	85 c0                	test   %eax,%eax
  8028a8:	75 d0                	jne    80287a <ipc_send+0x1d>
		} else {
			panic("ipc_send error %e\n", r);
		}
	}
	return;
}
  8028aa:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8028ad:	5b                   	pop    %ebx
  8028ae:	5e                   	pop    %esi
  8028af:	5f                   	pop    %edi
  8028b0:	c9                   	leave  
  8028b1:	c3                   	ret    

008028b2 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8028b2:	55                   	push   %ebp
  8028b3:	89 e5                	mov    %esp,%ebp
  8028b5:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  8028b8:	39 0d 50 00 c0 ee    	cmp    %ecx,0xeec00050
  8028be:	74 1a                	je     8028da <ipc_find_env+0x28>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8028c0:	b8 01 00 00 00       	mov    $0x1,%eax
		if (envs[i].env_type == type)
  8028c5:	89 c2                	mov    %eax,%edx
  8028c7:	c1 e2 07             	shl    $0x7,%edx
  8028ca:	8d 94 82 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,4),%edx
  8028d1:	8b 52 50             	mov    0x50(%edx),%edx
  8028d4:	39 ca                	cmp    %ecx,%edx
  8028d6:	75 18                	jne    8028f0 <ipc_find_env+0x3e>
  8028d8:	eb 05                	jmp    8028df <ipc_find_env+0x2d>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8028da:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
			return envs[i].env_id;
  8028df:	89 c2                	mov    %eax,%edx
  8028e1:	c1 e2 07             	shl    $0x7,%edx
  8028e4:	8d 84 82 08 00 c0 ee 	lea    -0x113ffff8(%edx,%eax,4),%eax
  8028eb:	8b 40 40             	mov    0x40(%eax),%eax
  8028ee:	eb 0c                	jmp    8028fc <ipc_find_env+0x4a>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8028f0:	40                   	inc    %eax
  8028f1:	3d 00 04 00 00       	cmp    $0x400,%eax
  8028f6:	75 cd                	jne    8028c5 <ipc_find_env+0x13>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8028f8:	66 b8 00 00          	mov    $0x0,%ax
}
  8028fc:	c9                   	leave  
  8028fd:	c3                   	ret    
	...

00802900 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802900:	55                   	push   %ebp
  802901:	89 e5                	mov    %esp,%ebp
  802903:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802906:	89 c2                	mov    %eax,%edx
  802908:	c1 ea 16             	shr    $0x16,%edx
  80290b:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  802912:	f6 c2 01             	test   $0x1,%dl
  802915:	74 1e                	je     802935 <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  802917:	c1 e8 0c             	shr    $0xc,%eax
  80291a:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  802921:	a8 01                	test   $0x1,%al
  802923:	74 17                	je     80293c <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802925:	c1 e8 0c             	shr    $0xc,%eax
  802928:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  80292f:	ef 
  802930:	0f b7 c0             	movzwl %ax,%eax
  802933:	eb 0c                	jmp    802941 <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  802935:	b8 00 00 00 00       	mov    $0x0,%eax
  80293a:	eb 05                	jmp    802941 <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  80293c:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  802941:	c9                   	leave  
  802942:	c3                   	ret    
	...

00802944 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  802944:	55                   	push   %ebp
  802945:	89 e5                	mov    %esp,%ebp
  802947:	57                   	push   %edi
  802948:	56                   	push   %esi
  802949:	83 ec 10             	sub    $0x10,%esp
  80294c:	8b 7d 08             	mov    0x8(%ebp),%edi
  80294f:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  802952:	89 7d f0             	mov    %edi,-0x10(%ebp)
  802955:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  802958:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  80295b:	8b 45 14             	mov    0x14(%ebp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  80295e:	85 c0                	test   %eax,%eax
  802960:	75 2e                	jne    802990 <__udivdi3+0x4c>
    {
      if (d0 > n1)
  802962:	39 f1                	cmp    %esi,%ecx
  802964:	77 5a                	ja     8029c0 <__udivdi3+0x7c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  802966:	85 c9                	test   %ecx,%ecx
  802968:	75 0b                	jne    802975 <__udivdi3+0x31>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  80296a:	b8 01 00 00 00       	mov    $0x1,%eax
  80296f:	31 d2                	xor    %edx,%edx
  802971:	f7 f1                	div    %ecx
  802973:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  802975:	31 d2                	xor    %edx,%edx
  802977:	89 f0                	mov    %esi,%eax
  802979:	f7 f1                	div    %ecx
  80297b:	89 c6                	mov    %eax,%esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  80297d:	89 f8                	mov    %edi,%eax
  80297f:	f7 f1                	div    %ecx
  802981:	89 c7                	mov    %eax,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  802983:	89 f8                	mov    %edi,%eax
  802985:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802987:	83 c4 10             	add    $0x10,%esp
  80298a:	5e                   	pop    %esi
  80298b:	5f                   	pop    %edi
  80298c:	c9                   	leave  
  80298d:	c3                   	ret    
  80298e:	66 90                	xchg   %ax,%ax
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  802990:	39 f0                	cmp    %esi,%eax
  802992:	77 1c                	ja     8029b0 <__udivdi3+0x6c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  802994:	0f bd f8             	bsr    %eax,%edi
	  if (bm == 0)
  802997:	83 f7 1f             	xor    $0x1f,%edi
  80299a:	75 3c                	jne    8029d8 <__udivdi3+0x94>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  80299c:	39 f0                	cmp    %esi,%eax
  80299e:	0f 82 90 00 00 00    	jb     802a34 <__udivdi3+0xf0>
  8029a4:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8029a7:	39 55 f4             	cmp    %edx,-0xc(%ebp)
  8029aa:	0f 86 84 00 00 00    	jbe    802a34 <__udivdi3+0xf0>
  8029b0:	31 f6                	xor    %esi,%esi
  8029b2:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  8029b4:	89 f8                	mov    %edi,%eax
  8029b6:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  8029b8:	83 c4 10             	add    $0x10,%esp
  8029bb:	5e                   	pop    %esi
  8029bc:	5f                   	pop    %edi
  8029bd:	c9                   	leave  
  8029be:	c3                   	ret    
  8029bf:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8029c0:	89 f2                	mov    %esi,%edx
  8029c2:	89 f8                	mov    %edi,%eax
  8029c4:	f7 f1                	div    %ecx
  8029c6:	89 c7                	mov    %eax,%edi
  8029c8:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  8029ca:	89 f8                	mov    %edi,%eax
  8029cc:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  8029ce:	83 c4 10             	add    $0x10,%esp
  8029d1:	5e                   	pop    %esi
  8029d2:	5f                   	pop    %edi
  8029d3:	c9                   	leave  
  8029d4:	c3                   	ret    
  8029d5:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  8029d8:	89 f9                	mov    %edi,%ecx
  8029da:	d3 e0                	shl    %cl,%eax
  8029dc:	89 45 e8             	mov    %eax,-0x18(%ebp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  8029df:	b8 20 00 00 00       	mov    $0x20,%eax
  8029e4:	29 f8                	sub    %edi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  8029e6:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8029e9:	88 c1                	mov    %al,%cl
  8029eb:	d3 ea                	shr    %cl,%edx
  8029ed:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  8029f0:	09 ca                	or     %ecx,%edx
  8029f2:	89 55 ec             	mov    %edx,-0x14(%ebp)
	      d0 = d0 << bm;
  8029f5:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8029f8:	89 f9                	mov    %edi,%ecx
  8029fa:	d3 e2                	shl    %cl,%edx
  8029fc:	89 55 f4             	mov    %edx,-0xc(%ebp)
	      n2 = n1 >> b;
  8029ff:	89 f2                	mov    %esi,%edx
  802a01:	88 c1                	mov    %al,%cl
  802a03:	d3 ea                	shr    %cl,%edx
  802a05:	89 55 e8             	mov    %edx,-0x18(%ebp)
	      n1 = (n1 << bm) | (n0 >> b);
  802a08:	89 f2                	mov    %esi,%edx
  802a0a:	89 f9                	mov    %edi,%ecx
  802a0c:	d3 e2                	shl    %cl,%edx
  802a0e:	8b 75 f0             	mov    -0x10(%ebp),%esi
  802a11:	88 c1                	mov    %al,%cl
  802a13:	d3 ee                	shr    %cl,%esi
  802a15:	09 d6                	or     %edx,%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  802a17:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  802a1a:	89 f0                	mov    %esi,%eax
  802a1c:	89 ca                	mov    %ecx,%edx
  802a1e:	f7 75 ec             	divl   -0x14(%ebp)
  802a21:	89 d1                	mov    %edx,%ecx
  802a23:	89 c6                	mov    %eax,%esi
	      umul_ppmm (m1, m0, q0, d0);
  802a25:	f7 65 f4             	mull   -0xc(%ebp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802a28:	39 d1                	cmp    %edx,%ecx
  802a2a:	72 28                	jb     802a54 <__udivdi3+0x110>
  802a2c:	74 1a                	je     802a48 <__udivdi3+0x104>
  802a2e:	89 f7                	mov    %esi,%edi
  802a30:	31 f6                	xor    %esi,%esi
  802a32:	eb 80                	jmp    8029b4 <__udivdi3+0x70>
	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  802a34:	31 f6                	xor    %esi,%esi
  802a36:	bf 01 00 00 00       	mov    $0x1,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  802a3b:	89 f8                	mov    %edi,%eax
  802a3d:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802a3f:	83 c4 10             	add    $0x10,%esp
  802a42:	5e                   	pop    %esi
  802a43:	5f                   	pop    %edi
  802a44:	c9                   	leave  
  802a45:	c3                   	ret    
  802a46:	66 90                	xchg   %ax,%ax

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  802a48:	8b 55 f0             	mov    -0x10(%ebp),%edx
  802a4b:	89 f9                	mov    %edi,%ecx
  802a4d:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802a4f:	39 c2                	cmp    %eax,%edx
  802a51:	73 db                	jae    802a2e <__udivdi3+0xea>
  802a53:	90                   	nop
		{
		  q0--;
  802a54:	8d 7e ff             	lea    -0x1(%esi),%edi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  802a57:	31 f6                	xor    %esi,%esi
  802a59:	e9 56 ff ff ff       	jmp    8029b4 <__udivdi3+0x70>
	...

00802a60 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  802a60:	55                   	push   %ebp
  802a61:	89 e5                	mov    %esp,%ebp
  802a63:	57                   	push   %edi
  802a64:	56                   	push   %esi
  802a65:	83 ec 20             	sub    $0x20,%esp
  802a68:	8b 45 08             	mov    0x8(%ebp),%eax
  802a6b:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  802a6e:	89 45 e8             	mov    %eax,-0x18(%ebp)
  802a71:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  802a74:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  802a77:	8b 7d 14             	mov    0x14(%ebp),%edi
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  802a7a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  n1 = nn.s.high;
  802a7d:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  802a7f:	85 ff                	test   %edi,%edi
  802a81:	75 15                	jne    802a98 <__umoddi3+0x38>
    {
      if (d0 > n1)
  802a83:	39 f1                	cmp    %esi,%ecx
  802a85:	0f 86 99 00 00 00    	jbe    802b24 <__umoddi3+0xc4>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802a8b:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  802a8d:	89 d0                	mov    %edx,%eax
  802a8f:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802a91:	83 c4 20             	add    $0x20,%esp
  802a94:	5e                   	pop    %esi
  802a95:	5f                   	pop    %edi
  802a96:	c9                   	leave  
  802a97:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  802a98:	39 f7                	cmp    %esi,%edi
  802a9a:	0f 87 a4 00 00 00    	ja     802b44 <__umoddi3+0xe4>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  802aa0:	0f bd c7             	bsr    %edi,%eax
	  if (bm == 0)
  802aa3:	83 f0 1f             	xor    $0x1f,%eax
  802aa6:	89 45 ec             	mov    %eax,-0x14(%ebp)
  802aa9:	0f 84 a1 00 00 00    	je     802b50 <__umoddi3+0xf0>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  802aaf:	89 f8                	mov    %edi,%eax
  802ab1:	8a 4d ec             	mov    -0x14(%ebp),%cl
  802ab4:	d3 e0                	shl    %cl,%eax
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  802ab6:	bf 20 00 00 00       	mov    $0x20,%edi
  802abb:	2b 7d ec             	sub    -0x14(%ebp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  802abe:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802ac1:	89 f9                	mov    %edi,%ecx
  802ac3:	d3 ea                	shr    %cl,%edx
  802ac5:	09 c2                	or     %eax,%edx
  802ac7:	89 55 f0             	mov    %edx,-0x10(%ebp)
	      d0 = d0 << bm;
  802aca:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802acd:	8a 4d ec             	mov    -0x14(%ebp),%cl
  802ad0:	d3 e0                	shl    %cl,%eax
  802ad2:	89 45 f4             	mov    %eax,-0xc(%ebp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  802ad5:	89 f2                	mov    %esi,%edx
  802ad7:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  802ad9:	8b 45 e8             	mov    -0x18(%ebp),%eax
  802adc:	d3 e0                	shl    %cl,%eax
  802ade:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  802ae1:	8b 45 e8             	mov    -0x18(%ebp),%eax
  802ae4:	89 f9                	mov    %edi,%ecx
  802ae6:	d3 e8                	shr    %cl,%eax
  802ae8:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  802aea:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  802aec:	89 f2                	mov    %esi,%edx
  802aee:	f7 75 f0             	divl   -0x10(%ebp)
  802af1:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  802af3:	f7 65 f4             	mull   -0xc(%ebp)
  802af6:	89 55 e8             	mov    %edx,-0x18(%ebp)
  802af9:	89 c1                	mov    %eax,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802afb:	39 d6                	cmp    %edx,%esi
  802afd:	72 71                	jb     802b70 <__umoddi3+0x110>
  802aff:	74 7f                	je     802b80 <__umoddi3+0x120>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  802b01:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802b04:	29 c8                	sub    %ecx,%eax
  802b06:	19 d6                	sbb    %edx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  802b08:	8a 4d ec             	mov    -0x14(%ebp),%cl
  802b0b:	d3 e8                	shr    %cl,%eax
  802b0d:	89 f2                	mov    %esi,%edx
  802b0f:	89 f9                	mov    %edi,%ecx
  802b11:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  802b13:	09 d0                	or     %edx,%eax
  802b15:	89 f2                	mov    %esi,%edx
  802b17:	8a 4d ec             	mov    -0x14(%ebp),%cl
  802b1a:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802b1c:	83 c4 20             	add    $0x20,%esp
  802b1f:	5e                   	pop    %esi
  802b20:	5f                   	pop    %edi
  802b21:	c9                   	leave  
  802b22:	c3                   	ret    
  802b23:	90                   	nop
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  802b24:	85 c9                	test   %ecx,%ecx
  802b26:	75 0b                	jne    802b33 <__umoddi3+0xd3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  802b28:	b8 01 00 00 00       	mov    $0x1,%eax
  802b2d:	31 d2                	xor    %edx,%edx
  802b2f:	f7 f1                	div    %ecx
  802b31:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  802b33:	89 f0                	mov    %esi,%eax
  802b35:	31 d2                	xor    %edx,%edx
  802b37:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802b39:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802b3c:	f7 f1                	div    %ecx
  802b3e:	e9 4a ff ff ff       	jmp    802a8d <__umoddi3+0x2d>
  802b43:	90                   	nop
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  802b44:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802b46:	83 c4 20             	add    $0x20,%esp
  802b49:	5e                   	pop    %esi
  802b4a:	5f                   	pop    %edi
  802b4b:	c9                   	leave  
  802b4c:	c3                   	ret    
  802b4d:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802b50:	39 f7                	cmp    %esi,%edi
  802b52:	72 05                	jb     802b59 <__umoddi3+0xf9>
  802b54:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
  802b57:	77 0c                	ja     802b65 <__umoddi3+0x105>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  802b59:	89 f2                	mov    %esi,%edx
  802b5b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802b5e:	29 c8                	sub    %ecx,%eax
  802b60:	19 fa                	sbb    %edi,%edx
  802b62:	89 45 f0             	mov    %eax,-0x10(%ebp)

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  802b65:	8b 45 f0             	mov    -0x10(%ebp),%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802b68:	83 c4 20             	add    $0x20,%esp
  802b6b:	5e                   	pop    %esi
  802b6c:	5f                   	pop    %edi
  802b6d:	c9                   	leave  
  802b6e:	c3                   	ret    
  802b6f:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  802b70:	8b 55 e8             	mov    -0x18(%ebp),%edx
  802b73:	89 c1                	mov    %eax,%ecx
  802b75:	2b 4d f4             	sub    -0xc(%ebp),%ecx
  802b78:	1b 55 f0             	sbb    -0x10(%ebp),%edx
  802b7b:	eb 84                	jmp    802b01 <__umoddi3+0xa1>
  802b7d:	8d 76 00             	lea    0x0(%esi),%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802b80:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  802b83:	72 eb                	jb     802b70 <__umoddi3+0x110>
  802b85:	89 f2                	mov    %esi,%edx
  802b87:	e9 75 ff ff ff       	jmp    802b01 <__umoddi3+0xa1>
