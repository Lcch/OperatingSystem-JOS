
obj/user/testfdsharing.debug:     file format elf32-i386


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
  80002c:	e8 8b 01 00 00       	call   8001bc <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <umain>:

char buf[512], buf2[512];

void
umain(int argc, char **argv)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	57                   	push   %edi
  800038:	56                   	push   %esi
  800039:	53                   	push   %ebx
  80003a:	83 ec 14             	sub    $0x14,%esp
	int fd, r, n, n2;

	if ((fd = open("motd", O_RDONLY)) < 0)
  80003d:	6a 00                	push   $0x0
  80003f:	68 40 23 80 00       	push   $0x802340
  800044:	e8 3a 18 00 00       	call   801883 <open>
  800049:	89 c3                	mov    %eax,%ebx
  80004b:	83 c4 10             	add    $0x10,%esp
  80004e:	85 c0                	test   %eax,%eax
  800050:	79 12                	jns    800064 <umain+0x30>
		panic("open motd: %e", fd);
  800052:	50                   	push   %eax
  800053:	68 45 23 80 00       	push   $0x802345
  800058:	6a 0c                	push   $0xc
  80005a:	68 53 23 80 00       	push   $0x802353
  80005f:	e8 c4 01 00 00       	call   800228 <_panic>
	seek(fd, 0);
  800064:	83 ec 08             	sub    $0x8,%esp
  800067:	6a 00                	push   $0x0
  800069:	50                   	push   %eax
  80006a:	e8 5b 15 00 00       	call   8015ca <seek>
	if ((n = readn(fd, buf, sizeof buf)) <= 0)
  80006f:	83 c4 0c             	add    $0xc,%esp
  800072:	68 00 02 00 00       	push   $0x200
  800077:	68 20 42 80 00       	push   $0x804220
  80007c:	53                   	push   %ebx
  80007d:	e8 71 14 00 00       	call   8014f3 <readn>
  800082:	89 c7                	mov    %eax,%edi
  800084:	83 c4 10             	add    $0x10,%esp
  800087:	85 c0                	test   %eax,%eax
  800089:	7f 12                	jg     80009d <umain+0x69>
		panic("readn: %e", n);
  80008b:	50                   	push   %eax
  80008c:	68 68 23 80 00       	push   $0x802368
  800091:	6a 0f                	push   $0xf
  800093:	68 53 23 80 00       	push   $0x802353
  800098:	e8 8b 01 00 00       	call   800228 <_panic>

	if ((r = fork()) < 0)
  80009d:	e8 a8 0e 00 00       	call   800f4a <fork>
  8000a2:	89 c6                	mov    %eax,%esi
  8000a4:	85 c0                	test   %eax,%eax
  8000a6:	79 12                	jns    8000ba <umain+0x86>
		panic("fork: %e", r);
  8000a8:	50                   	push   %eax
  8000a9:	68 72 23 80 00       	push   $0x802372
  8000ae:	6a 12                	push   $0x12
  8000b0:	68 53 23 80 00       	push   $0x802353
  8000b5:	e8 6e 01 00 00       	call   800228 <_panic>
	if (r == 0) {
  8000ba:	85 c0                	test   %eax,%eax
  8000bc:	0f 85 9d 00 00 00    	jne    80015f <umain+0x12b>
		seek(fd, 0);
  8000c2:	83 ec 08             	sub    $0x8,%esp
  8000c5:	6a 00                	push   $0x0
  8000c7:	53                   	push   %ebx
  8000c8:	e8 fd 14 00 00       	call   8015ca <seek>
		cprintf("going to read in child (might page fault if your sharing is buggy)\n");
  8000cd:	c7 04 24 b0 23 80 00 	movl   $0x8023b0,(%esp)
  8000d4:	e8 27 02 00 00       	call   800300 <cprintf>
		if ((n2 = readn(fd, buf2, sizeof buf2)) != n)
  8000d9:	83 c4 0c             	add    $0xc,%esp
  8000dc:	68 00 02 00 00       	push   $0x200
  8000e1:	68 20 40 80 00       	push   $0x804020
  8000e6:	53                   	push   %ebx
  8000e7:	e8 07 14 00 00       	call   8014f3 <readn>
  8000ec:	83 c4 10             	add    $0x10,%esp
  8000ef:	39 f8                	cmp    %edi,%eax
  8000f1:	74 16                	je     800109 <umain+0xd5>
			panic("read in parent got %d, read in child got %d", n, n2);
  8000f3:	83 ec 0c             	sub    $0xc,%esp
  8000f6:	50                   	push   %eax
  8000f7:	57                   	push   %edi
  8000f8:	68 f4 23 80 00       	push   $0x8023f4
  8000fd:	6a 17                	push   $0x17
  8000ff:	68 53 23 80 00       	push   $0x802353
  800104:	e8 1f 01 00 00       	call   800228 <_panic>
		if (memcmp(buf, buf2, n) != 0)
  800109:	83 ec 04             	sub    $0x4,%esp
  80010c:	50                   	push   %eax
  80010d:	68 20 40 80 00       	push   $0x804020
  800112:	68 20 42 80 00       	push   $0x804220
  800117:	e8 d8 09 00 00       	call   800af4 <memcmp>
  80011c:	83 c4 10             	add    $0x10,%esp
  80011f:	85 c0                	test   %eax,%eax
  800121:	74 14                	je     800137 <umain+0x103>
			panic("read in parent got different bytes from read in child");
  800123:	83 ec 04             	sub    $0x4,%esp
  800126:	68 20 24 80 00       	push   $0x802420
  80012b:	6a 19                	push   $0x19
  80012d:	68 53 23 80 00       	push   $0x802353
  800132:	e8 f1 00 00 00       	call   800228 <_panic>
		cprintf("read in child succeeded\n");
  800137:	83 ec 0c             	sub    $0xc,%esp
  80013a:	68 7b 23 80 00       	push   $0x80237b
  80013f:	e8 bc 01 00 00       	call   800300 <cprintf>
		seek(fd, 0);
  800144:	83 c4 08             	add    $0x8,%esp
  800147:	6a 00                	push   $0x0
  800149:	53                   	push   %ebx
  80014a:	e8 7b 14 00 00       	call   8015ca <seek>
		close(fd);
  80014f:	89 1c 24             	mov    %ebx,(%esp)
  800152:	e8 d8 11 00 00       	call   80132f <close>
		exit();
  800157:	e8 b0 00 00 00       	call   80020c <exit>
  80015c:	83 c4 10             	add    $0x10,%esp
	}
	wait(r);
  80015f:	83 ec 0c             	sub    $0xc,%esp
  800162:	56                   	push   %esi
  800163:	e8 2c 1b 00 00       	call   801c94 <wait>
	if ((n2 = readn(fd, buf2, sizeof buf2)) != n)
  800168:	83 c4 0c             	add    $0xc,%esp
  80016b:	68 00 02 00 00       	push   $0x200
  800170:	68 20 40 80 00       	push   $0x804020
  800175:	53                   	push   %ebx
  800176:	e8 78 13 00 00       	call   8014f3 <readn>
  80017b:	83 c4 10             	add    $0x10,%esp
  80017e:	39 f8                	cmp    %edi,%eax
  800180:	74 16                	je     800198 <umain+0x164>
		panic("read in parent got %d, then got %d", n, n2);
  800182:	83 ec 0c             	sub    $0xc,%esp
  800185:	50                   	push   %eax
  800186:	57                   	push   %edi
  800187:	68 58 24 80 00       	push   $0x802458
  80018c:	6a 21                	push   $0x21
  80018e:	68 53 23 80 00       	push   $0x802353
  800193:	e8 90 00 00 00       	call   800228 <_panic>
	cprintf("read in parent succeeded\n");
  800198:	83 ec 0c             	sub    $0xc,%esp
  80019b:	68 94 23 80 00       	push   $0x802394
  8001a0:	e8 5b 01 00 00       	call   800300 <cprintf>
	close(fd);
  8001a5:	89 1c 24             	mov    %ebx,(%esp)
  8001a8:	e8 82 11 00 00       	call   80132f <close>
	: "c" (msr), "a" (val1), "d" (val2))

static __inline void
breakpoint(void)
{
	__asm __volatile("int3");
  8001ad:	cc                   	int3   
  8001ae:	83 c4 10             	add    $0x10,%esp

	breakpoint();
}
  8001b1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001b4:	5b                   	pop    %ebx
  8001b5:	5e                   	pop    %esi
  8001b6:	5f                   	pop    %edi
  8001b7:	c9                   	leave  
  8001b8:	c3                   	ret    
  8001b9:	00 00                	add    %al,(%eax)
	...

008001bc <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8001bc:	55                   	push   %ebp
  8001bd:	89 e5                	mov    %esp,%ebp
  8001bf:	56                   	push   %esi
  8001c0:	53                   	push   %ebx
  8001c1:	8b 75 08             	mov    0x8(%ebp),%esi
  8001c4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs + ENVX(sys_getenvid());
  8001c7:	e8 21 0b 00 00       	call   800ced <sys_getenvid>
  8001cc:	25 ff 03 00 00       	and    $0x3ff,%eax
  8001d1:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  8001d8:	c1 e0 07             	shl    $0x7,%eax
  8001db:	29 d0                	sub    %edx,%eax
  8001dd:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8001e2:	a3 20 44 80 00       	mov    %eax,0x804420

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8001e7:	85 f6                	test   %esi,%esi
  8001e9:	7e 07                	jle    8001f2 <libmain+0x36>
		binaryname = argv[0];
  8001eb:	8b 03                	mov    (%ebx),%eax
  8001ed:	a3 00 30 80 00       	mov    %eax,0x803000
	// call user main routine
	umain(argc, argv);
  8001f2:	83 ec 08             	sub    $0x8,%esp
  8001f5:	53                   	push   %ebx
  8001f6:	56                   	push   %esi
  8001f7:	e8 38 fe ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  8001fc:	e8 0b 00 00 00       	call   80020c <exit>
  800201:	83 c4 10             	add    $0x10,%esp
}
  800204:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800207:	5b                   	pop    %ebx
  800208:	5e                   	pop    %esi
  800209:	c9                   	leave  
  80020a:	c3                   	ret    
	...

0080020c <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80020c:	55                   	push   %ebp
  80020d:	89 e5                	mov    %esp,%ebp
  80020f:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800212:	e8 43 11 00 00       	call   80135a <close_all>
	sys_env_destroy(0);
  800217:	83 ec 0c             	sub    $0xc,%esp
  80021a:	6a 00                	push   $0x0
  80021c:	e8 aa 0a 00 00       	call   800ccb <sys_env_destroy>
  800221:	83 c4 10             	add    $0x10,%esp
}
  800224:	c9                   	leave  
  800225:	c3                   	ret    
	...

00800228 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800228:	55                   	push   %ebp
  800229:	89 e5                	mov    %esp,%ebp
  80022b:	56                   	push   %esi
  80022c:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80022d:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800230:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  800236:	e8 b2 0a 00 00       	call   800ced <sys_getenvid>
  80023b:	83 ec 0c             	sub    $0xc,%esp
  80023e:	ff 75 0c             	pushl  0xc(%ebp)
  800241:	ff 75 08             	pushl  0x8(%ebp)
  800244:	53                   	push   %ebx
  800245:	50                   	push   %eax
  800246:	68 88 24 80 00       	push   $0x802488
  80024b:	e8 b0 00 00 00       	call   800300 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800250:	83 c4 18             	add    $0x18,%esp
  800253:	56                   	push   %esi
  800254:	ff 75 10             	pushl  0x10(%ebp)
  800257:	e8 53 00 00 00       	call   8002af <vcprintf>
	cprintf("\n");
  80025c:	c7 04 24 19 2a 80 00 	movl   $0x802a19,(%esp)
  800263:	e8 98 00 00 00       	call   800300 <cprintf>
  800268:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80026b:	cc                   	int3   
  80026c:	eb fd                	jmp    80026b <_panic+0x43>
	...

00800270 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800270:	55                   	push   %ebp
  800271:	89 e5                	mov    %esp,%ebp
  800273:	53                   	push   %ebx
  800274:	83 ec 04             	sub    $0x4,%esp
  800277:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80027a:	8b 03                	mov    (%ebx),%eax
  80027c:	8b 55 08             	mov    0x8(%ebp),%edx
  80027f:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  800283:	40                   	inc    %eax
  800284:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  800286:	3d ff 00 00 00       	cmp    $0xff,%eax
  80028b:	75 1a                	jne    8002a7 <putch+0x37>
		sys_cputs(b->buf, b->idx);
  80028d:	83 ec 08             	sub    $0x8,%esp
  800290:	68 ff 00 00 00       	push   $0xff
  800295:	8d 43 08             	lea    0x8(%ebx),%eax
  800298:	50                   	push   %eax
  800299:	e8 e3 09 00 00       	call   800c81 <sys_cputs>
		b->idx = 0;
  80029e:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8002a4:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8002a7:	ff 43 04             	incl   0x4(%ebx)
}
  8002aa:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8002ad:	c9                   	leave  
  8002ae:	c3                   	ret    

008002af <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8002af:	55                   	push   %ebp
  8002b0:	89 e5                	mov    %esp,%ebp
  8002b2:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8002b8:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8002bf:	00 00 00 
	b.cnt = 0;
  8002c2:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8002c9:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8002cc:	ff 75 0c             	pushl  0xc(%ebp)
  8002cf:	ff 75 08             	pushl  0x8(%ebp)
  8002d2:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8002d8:	50                   	push   %eax
  8002d9:	68 70 02 80 00       	push   $0x800270
  8002de:	e8 82 01 00 00       	call   800465 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8002e3:	83 c4 08             	add    $0x8,%esp
  8002e6:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8002ec:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8002f2:	50                   	push   %eax
  8002f3:	e8 89 09 00 00       	call   800c81 <sys_cputs>

	return b.cnt;
}
  8002f8:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8002fe:	c9                   	leave  
  8002ff:	c3                   	ret    

00800300 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800300:	55                   	push   %ebp
  800301:	89 e5                	mov    %esp,%ebp
  800303:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800306:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800309:	50                   	push   %eax
  80030a:	ff 75 08             	pushl  0x8(%ebp)
  80030d:	e8 9d ff ff ff       	call   8002af <vcprintf>
	va_end(ap);

	return cnt;
}
  800312:	c9                   	leave  
  800313:	c3                   	ret    

00800314 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800314:	55                   	push   %ebp
  800315:	89 e5                	mov    %esp,%ebp
  800317:	57                   	push   %edi
  800318:	56                   	push   %esi
  800319:	53                   	push   %ebx
  80031a:	83 ec 2c             	sub    $0x2c,%esp
  80031d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800320:	89 d6                	mov    %edx,%esi
  800322:	8b 45 08             	mov    0x8(%ebp),%eax
  800325:	8b 55 0c             	mov    0xc(%ebp),%edx
  800328:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80032b:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80032e:	8b 45 10             	mov    0x10(%ebp),%eax
  800331:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800334:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800337:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80033a:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  800341:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
  800344:	72 0c                	jb     800352 <printnum+0x3e>
  800346:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  800349:	76 07                	jbe    800352 <printnum+0x3e>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80034b:	4b                   	dec    %ebx
  80034c:	85 db                	test   %ebx,%ebx
  80034e:	7f 31                	jg     800381 <printnum+0x6d>
  800350:	eb 3f                	jmp    800391 <printnum+0x7d>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800352:	83 ec 0c             	sub    $0xc,%esp
  800355:	57                   	push   %edi
  800356:	4b                   	dec    %ebx
  800357:	53                   	push   %ebx
  800358:	50                   	push   %eax
  800359:	83 ec 08             	sub    $0x8,%esp
  80035c:	ff 75 d4             	pushl  -0x2c(%ebp)
  80035f:	ff 75 d0             	pushl  -0x30(%ebp)
  800362:	ff 75 dc             	pushl  -0x24(%ebp)
  800365:	ff 75 d8             	pushl  -0x28(%ebp)
  800368:	e8 6f 1d 00 00       	call   8020dc <__udivdi3>
  80036d:	83 c4 18             	add    $0x18,%esp
  800370:	52                   	push   %edx
  800371:	50                   	push   %eax
  800372:	89 f2                	mov    %esi,%edx
  800374:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800377:	e8 98 ff ff ff       	call   800314 <printnum>
  80037c:	83 c4 20             	add    $0x20,%esp
  80037f:	eb 10                	jmp    800391 <printnum+0x7d>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800381:	83 ec 08             	sub    $0x8,%esp
  800384:	56                   	push   %esi
  800385:	57                   	push   %edi
  800386:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800389:	4b                   	dec    %ebx
  80038a:	83 c4 10             	add    $0x10,%esp
  80038d:	85 db                	test   %ebx,%ebx
  80038f:	7f f0                	jg     800381 <printnum+0x6d>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800391:	83 ec 08             	sub    $0x8,%esp
  800394:	56                   	push   %esi
  800395:	83 ec 04             	sub    $0x4,%esp
  800398:	ff 75 d4             	pushl  -0x2c(%ebp)
  80039b:	ff 75 d0             	pushl  -0x30(%ebp)
  80039e:	ff 75 dc             	pushl  -0x24(%ebp)
  8003a1:	ff 75 d8             	pushl  -0x28(%ebp)
  8003a4:	e8 4f 1e 00 00       	call   8021f8 <__umoddi3>
  8003a9:	83 c4 14             	add    $0x14,%esp
  8003ac:	0f be 80 ab 24 80 00 	movsbl 0x8024ab(%eax),%eax
  8003b3:	50                   	push   %eax
  8003b4:	ff 55 e4             	call   *-0x1c(%ebp)
  8003b7:	83 c4 10             	add    $0x10,%esp
}
  8003ba:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8003bd:	5b                   	pop    %ebx
  8003be:	5e                   	pop    %esi
  8003bf:	5f                   	pop    %edi
  8003c0:	c9                   	leave  
  8003c1:	c3                   	ret    

008003c2 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8003c2:	55                   	push   %ebp
  8003c3:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8003c5:	83 fa 01             	cmp    $0x1,%edx
  8003c8:	7e 0e                	jle    8003d8 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8003ca:	8b 10                	mov    (%eax),%edx
  8003cc:	8d 4a 08             	lea    0x8(%edx),%ecx
  8003cf:	89 08                	mov    %ecx,(%eax)
  8003d1:	8b 02                	mov    (%edx),%eax
  8003d3:	8b 52 04             	mov    0x4(%edx),%edx
  8003d6:	eb 22                	jmp    8003fa <getuint+0x38>
	else if (lflag)
  8003d8:	85 d2                	test   %edx,%edx
  8003da:	74 10                	je     8003ec <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8003dc:	8b 10                	mov    (%eax),%edx
  8003de:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003e1:	89 08                	mov    %ecx,(%eax)
  8003e3:	8b 02                	mov    (%edx),%eax
  8003e5:	ba 00 00 00 00       	mov    $0x0,%edx
  8003ea:	eb 0e                	jmp    8003fa <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8003ec:	8b 10                	mov    (%eax),%edx
  8003ee:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003f1:	89 08                	mov    %ecx,(%eax)
  8003f3:	8b 02                	mov    (%edx),%eax
  8003f5:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8003fa:	c9                   	leave  
  8003fb:	c3                   	ret    

008003fc <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  8003fc:	55                   	push   %ebp
  8003fd:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8003ff:	83 fa 01             	cmp    $0x1,%edx
  800402:	7e 0e                	jle    800412 <getint+0x16>
		return va_arg(*ap, long long);
  800404:	8b 10                	mov    (%eax),%edx
  800406:	8d 4a 08             	lea    0x8(%edx),%ecx
  800409:	89 08                	mov    %ecx,(%eax)
  80040b:	8b 02                	mov    (%edx),%eax
  80040d:	8b 52 04             	mov    0x4(%edx),%edx
  800410:	eb 1a                	jmp    80042c <getint+0x30>
	else if (lflag)
  800412:	85 d2                	test   %edx,%edx
  800414:	74 0c                	je     800422 <getint+0x26>
		return va_arg(*ap, long);
  800416:	8b 10                	mov    (%eax),%edx
  800418:	8d 4a 04             	lea    0x4(%edx),%ecx
  80041b:	89 08                	mov    %ecx,(%eax)
  80041d:	8b 02                	mov    (%edx),%eax
  80041f:	99                   	cltd   
  800420:	eb 0a                	jmp    80042c <getint+0x30>
	else
		return va_arg(*ap, int);
  800422:	8b 10                	mov    (%eax),%edx
  800424:	8d 4a 04             	lea    0x4(%edx),%ecx
  800427:	89 08                	mov    %ecx,(%eax)
  800429:	8b 02                	mov    (%edx),%eax
  80042b:	99                   	cltd   
}
  80042c:	c9                   	leave  
  80042d:	c3                   	ret    

0080042e <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80042e:	55                   	push   %ebp
  80042f:	89 e5                	mov    %esp,%ebp
  800431:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800434:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  800437:	8b 10                	mov    (%eax),%edx
  800439:	3b 50 04             	cmp    0x4(%eax),%edx
  80043c:	73 08                	jae    800446 <sprintputch+0x18>
		*b->buf++ = ch;
  80043e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800441:	88 0a                	mov    %cl,(%edx)
  800443:	42                   	inc    %edx
  800444:	89 10                	mov    %edx,(%eax)
}
  800446:	c9                   	leave  
  800447:	c3                   	ret    

00800448 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800448:	55                   	push   %ebp
  800449:	89 e5                	mov    %esp,%ebp
  80044b:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80044e:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800451:	50                   	push   %eax
  800452:	ff 75 10             	pushl  0x10(%ebp)
  800455:	ff 75 0c             	pushl  0xc(%ebp)
  800458:	ff 75 08             	pushl  0x8(%ebp)
  80045b:	e8 05 00 00 00       	call   800465 <vprintfmt>
	va_end(ap);
  800460:	83 c4 10             	add    $0x10,%esp
}
  800463:	c9                   	leave  
  800464:	c3                   	ret    

00800465 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800465:	55                   	push   %ebp
  800466:	89 e5                	mov    %esp,%ebp
  800468:	57                   	push   %edi
  800469:	56                   	push   %esi
  80046a:	53                   	push   %ebx
  80046b:	83 ec 2c             	sub    $0x2c,%esp
  80046e:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800471:	8b 75 10             	mov    0x10(%ebp),%esi
  800474:	eb 13                	jmp    800489 <vprintfmt+0x24>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800476:	85 c0                	test   %eax,%eax
  800478:	0f 84 6d 03 00 00    	je     8007eb <vprintfmt+0x386>
				return;
			putch(ch, putdat);
  80047e:	83 ec 08             	sub    $0x8,%esp
  800481:	57                   	push   %edi
  800482:	50                   	push   %eax
  800483:	ff 55 08             	call   *0x8(%ebp)
  800486:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800489:	0f b6 06             	movzbl (%esi),%eax
  80048c:	46                   	inc    %esi
  80048d:	83 f8 25             	cmp    $0x25,%eax
  800490:	75 e4                	jne    800476 <vprintfmt+0x11>
  800492:	c6 45 dc 20          	movb   $0x20,-0x24(%ebp)
  800496:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  80049d:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  8004a4:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  8004ab:	b9 00 00 00 00       	mov    $0x0,%ecx
  8004b0:	eb 28                	jmp    8004da <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004b2:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  8004b4:	c6 45 dc 2d          	movb   $0x2d,-0x24(%ebp)
  8004b8:	eb 20                	jmp    8004da <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004ba:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8004bc:	c6 45 dc 30          	movb   $0x30,-0x24(%ebp)
  8004c0:	eb 18                	jmp    8004da <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004c2:	89 de                	mov    %ebx,%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  8004c4:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8004cb:	eb 0d                	jmp    8004da <vprintfmt+0x75>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  8004cd:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8004d0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8004d3:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004da:	8a 06                	mov    (%esi),%al
  8004dc:	0f b6 d0             	movzbl %al,%edx
  8004df:	8d 5e 01             	lea    0x1(%esi),%ebx
  8004e2:	83 e8 23             	sub    $0x23,%eax
  8004e5:	3c 55                	cmp    $0x55,%al
  8004e7:	0f 87 e0 02 00 00    	ja     8007cd <vprintfmt+0x368>
  8004ed:	0f b6 c0             	movzbl %al,%eax
  8004f0:	ff 24 85 e0 25 80 00 	jmp    *0x8025e0(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8004f7:	83 ea 30             	sub    $0x30,%edx
  8004fa:	89 55 d4             	mov    %edx,-0x2c(%ebp)
				ch = *fmt;
  8004fd:	0f be 03             	movsbl (%ebx),%eax
				if (ch < '0' || ch > '9')
  800500:	8d 50 d0             	lea    -0x30(%eax),%edx
  800503:	83 fa 09             	cmp    $0x9,%edx
  800506:	77 44                	ja     80054c <vprintfmt+0xe7>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800508:	89 de                	mov    %ebx,%esi
  80050a:	8b 55 d4             	mov    -0x2c(%ebp),%edx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80050d:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
  80050e:	8d 14 92             	lea    (%edx,%edx,4),%edx
  800511:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
  800515:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800518:	8d 58 d0             	lea    -0x30(%eax),%ebx
  80051b:	83 fb 09             	cmp    $0x9,%ebx
  80051e:	76 ed                	jbe    80050d <vprintfmt+0xa8>
  800520:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  800523:	eb 29                	jmp    80054e <vprintfmt+0xe9>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800525:	8b 45 14             	mov    0x14(%ebp),%eax
  800528:	8d 50 04             	lea    0x4(%eax),%edx
  80052b:	89 55 14             	mov    %edx,0x14(%ebp)
  80052e:	8b 00                	mov    (%eax),%eax
  800530:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800533:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800535:	eb 17                	jmp    80054e <vprintfmt+0xe9>

		case '.':
			if (width < 0)
  800537:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80053b:	78 85                	js     8004c2 <vprintfmt+0x5d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80053d:	89 de                	mov    %ebx,%esi
  80053f:	eb 99                	jmp    8004da <vprintfmt+0x75>
  800541:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800543:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  80054a:	eb 8e                	jmp    8004da <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80054c:	89 de                	mov    %ebx,%esi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  80054e:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800552:	79 86                	jns    8004da <vprintfmt+0x75>
  800554:	e9 74 ff ff ff       	jmp    8004cd <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800559:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80055a:	89 de                	mov    %ebx,%esi
  80055c:	e9 79 ff ff ff       	jmp    8004da <vprintfmt+0x75>
  800561:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800564:	8b 45 14             	mov    0x14(%ebp),%eax
  800567:	8d 50 04             	lea    0x4(%eax),%edx
  80056a:	89 55 14             	mov    %edx,0x14(%ebp)
  80056d:	83 ec 08             	sub    $0x8,%esp
  800570:	57                   	push   %edi
  800571:	ff 30                	pushl  (%eax)
  800573:	ff 55 08             	call   *0x8(%ebp)
			break;
  800576:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800579:	8b 75 d8             	mov    -0x28(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80057c:	e9 08 ff ff ff       	jmp    800489 <vprintfmt+0x24>
  800581:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  800584:	8b 45 14             	mov    0x14(%ebp),%eax
  800587:	8d 50 04             	lea    0x4(%eax),%edx
  80058a:	89 55 14             	mov    %edx,0x14(%ebp)
  80058d:	8b 00                	mov    (%eax),%eax
  80058f:	85 c0                	test   %eax,%eax
  800591:	79 02                	jns    800595 <vprintfmt+0x130>
  800593:	f7 d8                	neg    %eax
  800595:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800597:	83 f8 0f             	cmp    $0xf,%eax
  80059a:	7f 0b                	jg     8005a7 <vprintfmt+0x142>
  80059c:	8b 04 85 40 27 80 00 	mov    0x802740(,%eax,4),%eax
  8005a3:	85 c0                	test   %eax,%eax
  8005a5:	75 1a                	jne    8005c1 <vprintfmt+0x15c>
				printfmt(putch, putdat, "error %d", err);
  8005a7:	52                   	push   %edx
  8005a8:	68 c3 24 80 00       	push   $0x8024c3
  8005ad:	57                   	push   %edi
  8005ae:	ff 75 08             	pushl  0x8(%ebp)
  8005b1:	e8 92 fe ff ff       	call   800448 <printfmt>
  8005b6:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005b9:	8b 75 d8             	mov    -0x28(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8005bc:	e9 c8 fe ff ff       	jmp    800489 <vprintfmt+0x24>
			else
				printfmt(putch, putdat, "%s", p);
  8005c1:	50                   	push   %eax
  8005c2:	68 fb 29 80 00       	push   $0x8029fb
  8005c7:	57                   	push   %edi
  8005c8:	ff 75 08             	pushl  0x8(%ebp)
  8005cb:	e8 78 fe ff ff       	call   800448 <printfmt>
  8005d0:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005d3:	8b 75 d8             	mov    -0x28(%ebp),%esi
  8005d6:	e9 ae fe ff ff       	jmp    800489 <vprintfmt+0x24>
  8005db:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  8005de:	89 de                	mov    %ebx,%esi
  8005e0:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  8005e3:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8005e6:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e9:	8d 50 04             	lea    0x4(%eax),%edx
  8005ec:	89 55 14             	mov    %edx,0x14(%ebp)
  8005ef:	8b 00                	mov    (%eax),%eax
  8005f1:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8005f4:	85 c0                	test   %eax,%eax
  8005f6:	75 07                	jne    8005ff <vprintfmt+0x19a>
				p = "(null)";
  8005f8:	c7 45 d0 bc 24 80 00 	movl   $0x8024bc,-0x30(%ebp)
			if (width > 0 && padc != '-')
  8005ff:	85 db                	test   %ebx,%ebx
  800601:	7e 42                	jle    800645 <vprintfmt+0x1e0>
  800603:	80 7d dc 2d          	cmpb   $0x2d,-0x24(%ebp)
  800607:	74 3c                	je     800645 <vprintfmt+0x1e0>
				for (width -= strnlen(p, precision); width > 0; width--)
  800609:	83 ec 08             	sub    $0x8,%esp
  80060c:	51                   	push   %ecx
  80060d:	ff 75 d0             	pushl  -0x30(%ebp)
  800610:	e8 6f 02 00 00       	call   800884 <strnlen>
  800615:	29 c3                	sub    %eax,%ebx
  800617:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80061a:	83 c4 10             	add    $0x10,%esp
  80061d:	85 db                	test   %ebx,%ebx
  80061f:	7e 24                	jle    800645 <vprintfmt+0x1e0>
					putch(padc, putdat);
  800621:	0f be 5d dc          	movsbl -0x24(%ebp),%ebx
  800625:	89 75 dc             	mov    %esi,-0x24(%ebp)
  800628:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  80062b:	83 ec 08             	sub    $0x8,%esp
  80062e:	57                   	push   %edi
  80062f:	53                   	push   %ebx
  800630:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800633:	4e                   	dec    %esi
  800634:	83 c4 10             	add    $0x10,%esp
  800637:	85 f6                	test   %esi,%esi
  800639:	7f f0                	jg     80062b <vprintfmt+0x1c6>
  80063b:	8b 75 dc             	mov    -0x24(%ebp),%esi
  80063e:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800645:	8b 55 d0             	mov    -0x30(%ebp),%edx
  800648:	0f be 02             	movsbl (%edx),%eax
  80064b:	85 c0                	test   %eax,%eax
  80064d:	75 47                	jne    800696 <vprintfmt+0x231>
  80064f:	eb 37                	jmp    800688 <vprintfmt+0x223>
				if (altflag && (ch < ' ' || ch > '~'))
  800651:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800655:	74 16                	je     80066d <vprintfmt+0x208>
  800657:	8d 50 e0             	lea    -0x20(%eax),%edx
  80065a:	83 fa 5e             	cmp    $0x5e,%edx
  80065d:	76 0e                	jbe    80066d <vprintfmt+0x208>
					putch('?', putdat);
  80065f:	83 ec 08             	sub    $0x8,%esp
  800662:	57                   	push   %edi
  800663:	6a 3f                	push   $0x3f
  800665:	ff 55 08             	call   *0x8(%ebp)
  800668:	83 c4 10             	add    $0x10,%esp
  80066b:	eb 0b                	jmp    800678 <vprintfmt+0x213>
				else
					putch(ch, putdat);
  80066d:	83 ec 08             	sub    $0x8,%esp
  800670:	57                   	push   %edi
  800671:	50                   	push   %eax
  800672:	ff 55 08             	call   *0x8(%ebp)
  800675:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800678:	ff 4d e4             	decl   -0x1c(%ebp)
  80067b:	0f be 03             	movsbl (%ebx),%eax
  80067e:	85 c0                	test   %eax,%eax
  800680:	74 03                	je     800685 <vprintfmt+0x220>
  800682:	43                   	inc    %ebx
  800683:	eb 1b                	jmp    8006a0 <vprintfmt+0x23b>
  800685:	8b 75 dc             	mov    -0x24(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800688:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80068c:	7f 1e                	jg     8006ac <vprintfmt+0x247>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80068e:	8b 75 d8             	mov    -0x28(%ebp),%esi
  800691:	e9 f3 fd ff ff       	jmp    800489 <vprintfmt+0x24>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800696:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800699:	43                   	inc    %ebx
  80069a:	89 75 dc             	mov    %esi,-0x24(%ebp)
  80069d:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  8006a0:	85 f6                	test   %esi,%esi
  8006a2:	78 ad                	js     800651 <vprintfmt+0x1ec>
  8006a4:	4e                   	dec    %esi
  8006a5:	79 aa                	jns    800651 <vprintfmt+0x1ec>
  8006a7:	8b 75 dc             	mov    -0x24(%ebp),%esi
  8006aa:	eb dc                	jmp    800688 <vprintfmt+0x223>
  8006ac:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8006af:	83 ec 08             	sub    $0x8,%esp
  8006b2:	57                   	push   %edi
  8006b3:	6a 20                	push   $0x20
  8006b5:	ff 55 08             	call   *0x8(%ebp)
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8006b8:	4b                   	dec    %ebx
  8006b9:	83 c4 10             	add    $0x10,%esp
  8006bc:	85 db                	test   %ebx,%ebx
  8006be:	7f ef                	jg     8006af <vprintfmt+0x24a>
  8006c0:	e9 c4 fd ff ff       	jmp    800489 <vprintfmt+0x24>
  8006c5:	89 5d d8             	mov    %ebx,-0x28(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8006c8:	89 ca                	mov    %ecx,%edx
  8006ca:	8d 45 14             	lea    0x14(%ebp),%eax
  8006cd:	e8 2a fd ff ff       	call   8003fc <getint>
  8006d2:	89 c3                	mov    %eax,%ebx
  8006d4:	89 d6                	mov    %edx,%esi
			if ((long long) num < 0) {
  8006d6:	85 d2                	test   %edx,%edx
  8006d8:	78 0a                	js     8006e4 <vprintfmt+0x27f>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8006da:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006df:	e9 b0 00 00 00       	jmp    800794 <vprintfmt+0x32f>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  8006e4:	83 ec 08             	sub    $0x8,%esp
  8006e7:	57                   	push   %edi
  8006e8:	6a 2d                	push   $0x2d
  8006ea:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8006ed:	f7 db                	neg    %ebx
  8006ef:	83 d6 00             	adc    $0x0,%esi
  8006f2:	f7 de                	neg    %esi
  8006f4:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8006f7:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006fc:	e9 93 00 00 00       	jmp    800794 <vprintfmt+0x32f>
  800701:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800704:	89 ca                	mov    %ecx,%edx
  800706:	8d 45 14             	lea    0x14(%ebp),%eax
  800709:	e8 b4 fc ff ff       	call   8003c2 <getuint>
  80070e:	89 c3                	mov    %eax,%ebx
  800710:	89 d6                	mov    %edx,%esi
			base = 10;
  800712:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  800717:	eb 7b                	jmp    800794 <vprintfmt+0x32f>
  800719:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
  80071c:	89 ca                	mov    %ecx,%edx
  80071e:	8d 45 14             	lea    0x14(%ebp),%eax
  800721:	e8 d6 fc ff ff       	call   8003fc <getint>
  800726:	89 c3                	mov    %eax,%ebx
  800728:	89 d6                	mov    %edx,%esi
            if ((long long) num < 0) {
  80072a:	85 d2                	test   %edx,%edx
  80072c:	78 07                	js     800735 <vprintfmt+0x2d0>
                putch('-', putdat);
                num = -(long long) num;
            }
            base = 8;
  80072e:	b8 08 00 00 00       	mov    $0x8,%eax
  800733:	eb 5f                	jmp    800794 <vprintfmt+0x32f>
		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
            if ((long long) num < 0) {
                putch('-', putdat);
  800735:	83 ec 08             	sub    $0x8,%esp
  800738:	57                   	push   %edi
  800739:	6a 2d                	push   $0x2d
  80073b:	ff 55 08             	call   *0x8(%ebp)
                num = -(long long) num;
  80073e:	f7 db                	neg    %ebx
  800740:	83 d6 00             	adc    $0x0,%esi
  800743:	f7 de                	neg    %esi
  800745:	83 c4 10             	add    $0x10,%esp
            }
            base = 8;
  800748:	b8 08 00 00 00       	mov    $0x8,%eax
  80074d:	eb 45                	jmp    800794 <vprintfmt+0x32f>
  80074f:	89 5d d8             	mov    %ebx,-0x28(%ebp)
            goto number;

        // pointer
		case 'p':
			putch('0', putdat);
  800752:	83 ec 08             	sub    $0x8,%esp
  800755:	57                   	push   %edi
  800756:	6a 30                	push   $0x30
  800758:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  80075b:	83 c4 08             	add    $0x8,%esp
  80075e:	57                   	push   %edi
  80075f:	6a 78                	push   $0x78
  800761:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800764:	8b 45 14             	mov    0x14(%ebp),%eax
  800767:	8d 50 04             	lea    0x4(%eax),%edx
  80076a:	89 55 14             	mov    %edx,0x14(%ebp)

        // pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80076d:	8b 18                	mov    (%eax),%ebx
  80076f:	be 00 00 00 00       	mov    $0x0,%esi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800774:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800777:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  80077c:	eb 16                	jmp    800794 <vprintfmt+0x32f>
  80077e:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800781:	89 ca                	mov    %ecx,%edx
  800783:	8d 45 14             	lea    0x14(%ebp),%eax
  800786:	e8 37 fc ff ff       	call   8003c2 <getuint>
  80078b:	89 c3                	mov    %eax,%ebx
  80078d:	89 d6                	mov    %edx,%esi
			base = 16;
  80078f:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800794:	83 ec 0c             	sub    $0xc,%esp
  800797:	0f be 55 dc          	movsbl -0x24(%ebp),%edx
  80079b:	52                   	push   %edx
  80079c:	ff 75 e4             	pushl  -0x1c(%ebp)
  80079f:	50                   	push   %eax
  8007a0:	56                   	push   %esi
  8007a1:	53                   	push   %ebx
  8007a2:	89 fa                	mov    %edi,%edx
  8007a4:	8b 45 08             	mov    0x8(%ebp),%eax
  8007a7:	e8 68 fb ff ff       	call   800314 <printnum>
			break;
  8007ac:	83 c4 20             	add    $0x20,%esp
  8007af:	8b 75 d8             	mov    -0x28(%ebp),%esi
  8007b2:	e9 d2 fc ff ff       	jmp    800489 <vprintfmt+0x24>
  8007b7:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8007ba:	83 ec 08             	sub    $0x8,%esp
  8007bd:	57                   	push   %edi
  8007be:	52                   	push   %edx
  8007bf:	ff 55 08             	call   *0x8(%ebp)
			break;
  8007c2:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007c5:	8b 75 d8             	mov    -0x28(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8007c8:	e9 bc fc ff ff       	jmp    800489 <vprintfmt+0x24>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8007cd:	83 ec 08             	sub    $0x8,%esp
  8007d0:	57                   	push   %edi
  8007d1:	6a 25                	push   $0x25
  8007d3:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8007d6:	83 c4 10             	add    $0x10,%esp
  8007d9:	eb 02                	jmp    8007dd <vprintfmt+0x378>
  8007db:	89 c6                	mov    %eax,%esi
  8007dd:	8d 46 ff             	lea    -0x1(%esi),%eax
  8007e0:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  8007e4:	75 f5                	jne    8007db <vprintfmt+0x376>
  8007e6:	e9 9e fc ff ff       	jmp    800489 <vprintfmt+0x24>
				/* do nothing */;
			break;
		}
	}
}
  8007eb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8007ee:	5b                   	pop    %ebx
  8007ef:	5e                   	pop    %esi
  8007f0:	5f                   	pop    %edi
  8007f1:	c9                   	leave  
  8007f2:	c3                   	ret    

008007f3 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8007f3:	55                   	push   %ebp
  8007f4:	89 e5                	mov    %esp,%ebp
  8007f6:	83 ec 18             	sub    $0x18,%esp
  8007f9:	8b 45 08             	mov    0x8(%ebp),%eax
  8007fc:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8007ff:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800802:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800806:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800809:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800810:	85 c0                	test   %eax,%eax
  800812:	74 26                	je     80083a <vsnprintf+0x47>
  800814:	85 d2                	test   %edx,%edx
  800816:	7e 29                	jle    800841 <vsnprintf+0x4e>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800818:	ff 75 14             	pushl  0x14(%ebp)
  80081b:	ff 75 10             	pushl  0x10(%ebp)
  80081e:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800821:	50                   	push   %eax
  800822:	68 2e 04 80 00       	push   $0x80042e
  800827:	e8 39 fc ff ff       	call   800465 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80082c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80082f:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800832:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800835:	83 c4 10             	add    $0x10,%esp
  800838:	eb 0c                	jmp    800846 <vsnprintf+0x53>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80083a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80083f:	eb 05                	jmp    800846 <vsnprintf+0x53>
  800841:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800846:	c9                   	leave  
  800847:	c3                   	ret    

00800848 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800848:	55                   	push   %ebp
  800849:	89 e5                	mov    %esp,%ebp
  80084b:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80084e:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800851:	50                   	push   %eax
  800852:	ff 75 10             	pushl  0x10(%ebp)
  800855:	ff 75 0c             	pushl  0xc(%ebp)
  800858:	ff 75 08             	pushl  0x8(%ebp)
  80085b:	e8 93 ff ff ff       	call   8007f3 <vsnprintf>
	va_end(ap);

	return rc;
}
  800860:	c9                   	leave  
  800861:	c3                   	ret    
	...

00800864 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800864:	55                   	push   %ebp
  800865:	89 e5                	mov    %esp,%ebp
  800867:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80086a:	80 3a 00             	cmpb   $0x0,(%edx)
  80086d:	74 0e                	je     80087d <strlen+0x19>
  80086f:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800874:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800875:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800879:	75 f9                	jne    800874 <strlen+0x10>
  80087b:	eb 05                	jmp    800882 <strlen+0x1e>
  80087d:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800882:	c9                   	leave  
  800883:	c3                   	ret    

00800884 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800884:	55                   	push   %ebp
  800885:	89 e5                	mov    %esp,%ebp
  800887:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80088a:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80088d:	85 d2                	test   %edx,%edx
  80088f:	74 17                	je     8008a8 <strnlen+0x24>
  800891:	80 39 00             	cmpb   $0x0,(%ecx)
  800894:	74 19                	je     8008af <strnlen+0x2b>
  800896:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  80089b:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80089c:	39 d0                	cmp    %edx,%eax
  80089e:	74 14                	je     8008b4 <strnlen+0x30>
  8008a0:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8008a4:	75 f5                	jne    80089b <strnlen+0x17>
  8008a6:	eb 0c                	jmp    8008b4 <strnlen+0x30>
  8008a8:	b8 00 00 00 00       	mov    $0x0,%eax
  8008ad:	eb 05                	jmp    8008b4 <strnlen+0x30>
  8008af:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  8008b4:	c9                   	leave  
  8008b5:	c3                   	ret    

008008b6 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8008b6:	55                   	push   %ebp
  8008b7:	89 e5                	mov    %esp,%ebp
  8008b9:	53                   	push   %ebx
  8008ba:	8b 45 08             	mov    0x8(%ebp),%eax
  8008bd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8008c0:	ba 00 00 00 00       	mov    $0x0,%edx
  8008c5:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  8008c8:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  8008cb:	42                   	inc    %edx
  8008cc:	84 c9                	test   %cl,%cl
  8008ce:	75 f5                	jne    8008c5 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8008d0:	5b                   	pop    %ebx
  8008d1:	c9                   	leave  
  8008d2:	c3                   	ret    

008008d3 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8008d3:	55                   	push   %ebp
  8008d4:	89 e5                	mov    %esp,%ebp
  8008d6:	53                   	push   %ebx
  8008d7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8008da:	53                   	push   %ebx
  8008db:	e8 84 ff ff ff       	call   800864 <strlen>
  8008e0:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8008e3:	ff 75 0c             	pushl  0xc(%ebp)
  8008e6:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  8008e9:	50                   	push   %eax
  8008ea:	e8 c7 ff ff ff       	call   8008b6 <strcpy>
	return dst;
}
  8008ef:	89 d8                	mov    %ebx,%eax
  8008f1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008f4:	c9                   	leave  
  8008f5:	c3                   	ret    

008008f6 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8008f6:	55                   	push   %ebp
  8008f7:	89 e5                	mov    %esp,%ebp
  8008f9:	56                   	push   %esi
  8008fa:	53                   	push   %ebx
  8008fb:	8b 45 08             	mov    0x8(%ebp),%eax
  8008fe:	8b 55 0c             	mov    0xc(%ebp),%edx
  800901:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800904:	85 f6                	test   %esi,%esi
  800906:	74 15                	je     80091d <strncpy+0x27>
  800908:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  80090d:	8a 1a                	mov    (%edx),%bl
  80090f:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800912:	80 3a 01             	cmpb   $0x1,(%edx)
  800915:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800918:	41                   	inc    %ecx
  800919:	39 ce                	cmp    %ecx,%esi
  80091b:	77 f0                	ja     80090d <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80091d:	5b                   	pop    %ebx
  80091e:	5e                   	pop    %esi
  80091f:	c9                   	leave  
  800920:	c3                   	ret    

00800921 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800921:	55                   	push   %ebp
  800922:	89 e5                	mov    %esp,%ebp
  800924:	57                   	push   %edi
  800925:	56                   	push   %esi
  800926:	53                   	push   %ebx
  800927:	8b 7d 08             	mov    0x8(%ebp),%edi
  80092a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80092d:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800930:	85 f6                	test   %esi,%esi
  800932:	74 32                	je     800966 <strlcpy+0x45>
		while (--size > 0 && *src != '\0')
  800934:	83 fe 01             	cmp    $0x1,%esi
  800937:	74 22                	je     80095b <strlcpy+0x3a>
  800939:	8a 0b                	mov    (%ebx),%cl
  80093b:	84 c9                	test   %cl,%cl
  80093d:	74 20                	je     80095f <strlcpy+0x3e>
  80093f:	89 f8                	mov    %edi,%eax
  800941:	ba 00 00 00 00       	mov    $0x0,%edx
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
  800946:	83 ee 02             	sub    $0x2,%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800949:	88 08                	mov    %cl,(%eax)
  80094b:	40                   	inc    %eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80094c:	39 f2                	cmp    %esi,%edx
  80094e:	74 11                	je     800961 <strlcpy+0x40>
  800950:	8a 4c 13 01          	mov    0x1(%ebx,%edx,1),%cl
  800954:	42                   	inc    %edx
  800955:	84 c9                	test   %cl,%cl
  800957:	75 f0                	jne    800949 <strlcpy+0x28>
  800959:	eb 06                	jmp    800961 <strlcpy+0x40>
  80095b:	89 f8                	mov    %edi,%eax
  80095d:	eb 02                	jmp    800961 <strlcpy+0x40>
  80095f:	89 f8                	mov    %edi,%eax
			*dst++ = *src++;
		*dst = '\0';
  800961:	c6 00 00             	movb   $0x0,(%eax)
  800964:	eb 02                	jmp    800968 <strlcpy+0x47>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800966:	89 f8                	mov    %edi,%eax
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
		*dst = '\0';
	}
	return dst - dst_in;
  800968:	29 f8                	sub    %edi,%eax
}
  80096a:	5b                   	pop    %ebx
  80096b:	5e                   	pop    %esi
  80096c:	5f                   	pop    %edi
  80096d:	c9                   	leave  
  80096e:	c3                   	ret    

0080096f <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80096f:	55                   	push   %ebp
  800970:	89 e5                	mov    %esp,%ebp
  800972:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800975:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800978:	8a 01                	mov    (%ecx),%al
  80097a:	84 c0                	test   %al,%al
  80097c:	74 10                	je     80098e <strcmp+0x1f>
  80097e:	3a 02                	cmp    (%edx),%al
  800980:	75 0c                	jne    80098e <strcmp+0x1f>
		p++, q++;
  800982:	41                   	inc    %ecx
  800983:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800984:	8a 01                	mov    (%ecx),%al
  800986:	84 c0                	test   %al,%al
  800988:	74 04                	je     80098e <strcmp+0x1f>
  80098a:	3a 02                	cmp    (%edx),%al
  80098c:	74 f4                	je     800982 <strcmp+0x13>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80098e:	0f b6 c0             	movzbl %al,%eax
  800991:	0f b6 12             	movzbl (%edx),%edx
  800994:	29 d0                	sub    %edx,%eax
}
  800996:	c9                   	leave  
  800997:	c3                   	ret    

00800998 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800998:	55                   	push   %ebp
  800999:	89 e5                	mov    %esp,%ebp
  80099b:	53                   	push   %ebx
  80099c:	8b 55 08             	mov    0x8(%ebp),%edx
  80099f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8009a2:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  8009a5:	85 c0                	test   %eax,%eax
  8009a7:	74 1b                	je     8009c4 <strncmp+0x2c>
  8009a9:	8a 1a                	mov    (%edx),%bl
  8009ab:	84 db                	test   %bl,%bl
  8009ad:	74 24                	je     8009d3 <strncmp+0x3b>
  8009af:	3a 19                	cmp    (%ecx),%bl
  8009b1:	75 20                	jne    8009d3 <strncmp+0x3b>
  8009b3:	48                   	dec    %eax
  8009b4:	74 15                	je     8009cb <strncmp+0x33>
		n--, p++, q++;
  8009b6:	42                   	inc    %edx
  8009b7:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8009b8:	8a 1a                	mov    (%edx),%bl
  8009ba:	84 db                	test   %bl,%bl
  8009bc:	74 15                	je     8009d3 <strncmp+0x3b>
  8009be:	3a 19                	cmp    (%ecx),%bl
  8009c0:	74 f1                	je     8009b3 <strncmp+0x1b>
  8009c2:	eb 0f                	jmp    8009d3 <strncmp+0x3b>
		n--, p++, q++;
	if (n == 0)
		return 0;
  8009c4:	b8 00 00 00 00       	mov    $0x0,%eax
  8009c9:	eb 05                	jmp    8009d0 <strncmp+0x38>
  8009cb:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8009d0:	5b                   	pop    %ebx
  8009d1:	c9                   	leave  
  8009d2:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8009d3:	0f b6 02             	movzbl (%edx),%eax
  8009d6:	0f b6 11             	movzbl (%ecx),%edx
  8009d9:	29 d0                	sub    %edx,%eax
  8009db:	eb f3                	jmp    8009d0 <strncmp+0x38>

008009dd <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8009dd:	55                   	push   %ebp
  8009de:	89 e5                	mov    %esp,%ebp
  8009e0:	8b 45 08             	mov    0x8(%ebp),%eax
  8009e3:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8009e6:	8a 10                	mov    (%eax),%dl
  8009e8:	84 d2                	test   %dl,%dl
  8009ea:	74 18                	je     800a04 <strchr+0x27>
		if (*s == c)
  8009ec:	38 ca                	cmp    %cl,%dl
  8009ee:	75 06                	jne    8009f6 <strchr+0x19>
  8009f0:	eb 17                	jmp    800a09 <strchr+0x2c>
  8009f2:	38 ca                	cmp    %cl,%dl
  8009f4:	74 13                	je     800a09 <strchr+0x2c>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8009f6:	40                   	inc    %eax
  8009f7:	8a 10                	mov    (%eax),%dl
  8009f9:	84 d2                	test   %dl,%dl
  8009fb:	75 f5                	jne    8009f2 <strchr+0x15>
		if (*s == c)
			return (char *) s;
	return 0;
  8009fd:	b8 00 00 00 00       	mov    $0x0,%eax
  800a02:	eb 05                	jmp    800a09 <strchr+0x2c>
  800a04:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a09:	c9                   	leave  
  800a0a:	c3                   	ret    

00800a0b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a0b:	55                   	push   %ebp
  800a0c:	89 e5                	mov    %esp,%ebp
  800a0e:	8b 45 08             	mov    0x8(%ebp),%eax
  800a11:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800a14:	8a 10                	mov    (%eax),%dl
  800a16:	84 d2                	test   %dl,%dl
  800a18:	74 11                	je     800a2b <strfind+0x20>
		if (*s == c)
  800a1a:	38 ca                	cmp    %cl,%dl
  800a1c:	75 06                	jne    800a24 <strfind+0x19>
  800a1e:	eb 0b                	jmp    800a2b <strfind+0x20>
  800a20:	38 ca                	cmp    %cl,%dl
  800a22:	74 07                	je     800a2b <strfind+0x20>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800a24:	40                   	inc    %eax
  800a25:	8a 10                	mov    (%eax),%dl
  800a27:	84 d2                	test   %dl,%dl
  800a29:	75 f5                	jne    800a20 <strfind+0x15>
		if (*s == c)
			break;
	return (char *) s;
}
  800a2b:	c9                   	leave  
  800a2c:	c3                   	ret    

00800a2d <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a2d:	55                   	push   %ebp
  800a2e:	89 e5                	mov    %esp,%ebp
  800a30:	57                   	push   %edi
  800a31:	56                   	push   %esi
  800a32:	53                   	push   %ebx
  800a33:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a36:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a39:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800a3c:	85 c9                	test   %ecx,%ecx
  800a3e:	74 30                	je     800a70 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a40:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a46:	75 25                	jne    800a6d <memset+0x40>
  800a48:	f6 c1 03             	test   $0x3,%cl
  800a4b:	75 20                	jne    800a6d <memset+0x40>
		c &= 0xFF;
  800a4d:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a50:	89 d3                	mov    %edx,%ebx
  800a52:	c1 e3 08             	shl    $0x8,%ebx
  800a55:	89 d6                	mov    %edx,%esi
  800a57:	c1 e6 18             	shl    $0x18,%esi
  800a5a:	89 d0                	mov    %edx,%eax
  800a5c:	c1 e0 10             	shl    $0x10,%eax
  800a5f:	09 f0                	or     %esi,%eax
  800a61:	09 d0                	or     %edx,%eax
  800a63:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800a65:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800a68:	fc                   	cld    
  800a69:	f3 ab                	rep stos %eax,%es:(%edi)
  800a6b:	eb 03                	jmp    800a70 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a6d:	fc                   	cld    
  800a6e:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a70:	89 f8                	mov    %edi,%eax
  800a72:	5b                   	pop    %ebx
  800a73:	5e                   	pop    %esi
  800a74:	5f                   	pop    %edi
  800a75:	c9                   	leave  
  800a76:	c3                   	ret    

00800a77 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a77:	55                   	push   %ebp
  800a78:	89 e5                	mov    %esp,%ebp
  800a7a:	57                   	push   %edi
  800a7b:	56                   	push   %esi
  800a7c:	8b 45 08             	mov    0x8(%ebp),%eax
  800a7f:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a82:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a85:	39 c6                	cmp    %eax,%esi
  800a87:	73 34                	jae    800abd <memmove+0x46>
  800a89:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a8c:	39 d0                	cmp    %edx,%eax
  800a8e:	73 2d                	jae    800abd <memmove+0x46>
		s += n;
		d += n;
  800a90:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a93:	f6 c2 03             	test   $0x3,%dl
  800a96:	75 1b                	jne    800ab3 <memmove+0x3c>
  800a98:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a9e:	75 13                	jne    800ab3 <memmove+0x3c>
  800aa0:	f6 c1 03             	test   $0x3,%cl
  800aa3:	75 0e                	jne    800ab3 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800aa5:	83 ef 04             	sub    $0x4,%edi
  800aa8:	8d 72 fc             	lea    -0x4(%edx),%esi
  800aab:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800aae:	fd                   	std    
  800aaf:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ab1:	eb 07                	jmp    800aba <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800ab3:	4f                   	dec    %edi
  800ab4:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800ab7:	fd                   	std    
  800ab8:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800aba:	fc                   	cld    
  800abb:	eb 20                	jmp    800add <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800abd:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800ac3:	75 13                	jne    800ad8 <memmove+0x61>
  800ac5:	a8 03                	test   $0x3,%al
  800ac7:	75 0f                	jne    800ad8 <memmove+0x61>
  800ac9:	f6 c1 03             	test   $0x3,%cl
  800acc:	75 0a                	jne    800ad8 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800ace:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800ad1:	89 c7                	mov    %eax,%edi
  800ad3:	fc                   	cld    
  800ad4:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ad6:	eb 05                	jmp    800add <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800ad8:	89 c7                	mov    %eax,%edi
  800ada:	fc                   	cld    
  800adb:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800add:	5e                   	pop    %esi
  800ade:	5f                   	pop    %edi
  800adf:	c9                   	leave  
  800ae0:	c3                   	ret    

00800ae1 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800ae1:	55                   	push   %ebp
  800ae2:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800ae4:	ff 75 10             	pushl  0x10(%ebp)
  800ae7:	ff 75 0c             	pushl  0xc(%ebp)
  800aea:	ff 75 08             	pushl  0x8(%ebp)
  800aed:	e8 85 ff ff ff       	call   800a77 <memmove>
}
  800af2:	c9                   	leave  
  800af3:	c3                   	ret    

00800af4 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800af4:	55                   	push   %ebp
  800af5:	89 e5                	mov    %esp,%ebp
  800af7:	57                   	push   %edi
  800af8:	56                   	push   %esi
  800af9:	53                   	push   %ebx
  800afa:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800afd:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b00:	8b 7d 10             	mov    0x10(%ebp),%edi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b03:	85 ff                	test   %edi,%edi
  800b05:	74 32                	je     800b39 <memcmp+0x45>
		if (*s1 != *s2)
  800b07:	8a 03                	mov    (%ebx),%al
  800b09:	8a 0e                	mov    (%esi),%cl
  800b0b:	38 c8                	cmp    %cl,%al
  800b0d:	74 19                	je     800b28 <memcmp+0x34>
  800b0f:	eb 0d                	jmp    800b1e <memcmp+0x2a>
  800b11:	8a 44 13 01          	mov    0x1(%ebx,%edx,1),%al
  800b15:	8a 4c 16 01          	mov    0x1(%esi,%edx,1),%cl
  800b19:	42                   	inc    %edx
  800b1a:	38 c8                	cmp    %cl,%al
  800b1c:	74 10                	je     800b2e <memcmp+0x3a>
			return (int) *s1 - (int) *s2;
  800b1e:	0f b6 c0             	movzbl %al,%eax
  800b21:	0f b6 c9             	movzbl %cl,%ecx
  800b24:	29 c8                	sub    %ecx,%eax
  800b26:	eb 16                	jmp    800b3e <memcmp+0x4a>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b28:	4f                   	dec    %edi
  800b29:	ba 00 00 00 00       	mov    $0x0,%edx
  800b2e:	39 fa                	cmp    %edi,%edx
  800b30:	75 df                	jne    800b11 <memcmp+0x1d>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800b32:	b8 00 00 00 00       	mov    $0x0,%eax
  800b37:	eb 05                	jmp    800b3e <memcmp+0x4a>
  800b39:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b3e:	5b                   	pop    %ebx
  800b3f:	5e                   	pop    %esi
  800b40:	5f                   	pop    %edi
  800b41:	c9                   	leave  
  800b42:	c3                   	ret    

00800b43 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b43:	55                   	push   %ebp
  800b44:	89 e5                	mov    %esp,%ebp
  800b46:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800b49:	89 c2                	mov    %eax,%edx
  800b4b:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800b4e:	39 d0                	cmp    %edx,%eax
  800b50:	73 12                	jae    800b64 <memfind+0x21>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b52:	8a 4d 0c             	mov    0xc(%ebp),%cl
  800b55:	38 08                	cmp    %cl,(%eax)
  800b57:	75 06                	jne    800b5f <memfind+0x1c>
  800b59:	eb 09                	jmp    800b64 <memfind+0x21>
  800b5b:	38 08                	cmp    %cl,(%eax)
  800b5d:	74 05                	je     800b64 <memfind+0x21>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800b5f:	40                   	inc    %eax
  800b60:	39 c2                	cmp    %eax,%edx
  800b62:	77 f7                	ja     800b5b <memfind+0x18>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800b64:	c9                   	leave  
  800b65:	c3                   	ret    

00800b66 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b66:	55                   	push   %ebp
  800b67:	89 e5                	mov    %esp,%ebp
  800b69:	57                   	push   %edi
  800b6a:	56                   	push   %esi
  800b6b:	53                   	push   %ebx
  800b6c:	8b 55 08             	mov    0x8(%ebp),%edx
  800b6f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b72:	eb 01                	jmp    800b75 <strtol+0xf>
		s++;
  800b74:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b75:	8a 02                	mov    (%edx),%al
  800b77:	3c 20                	cmp    $0x20,%al
  800b79:	74 f9                	je     800b74 <strtol+0xe>
  800b7b:	3c 09                	cmp    $0x9,%al
  800b7d:	74 f5                	je     800b74 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800b7f:	3c 2b                	cmp    $0x2b,%al
  800b81:	75 08                	jne    800b8b <strtol+0x25>
		s++;
  800b83:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800b84:	bf 00 00 00 00       	mov    $0x0,%edi
  800b89:	eb 13                	jmp    800b9e <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800b8b:	3c 2d                	cmp    $0x2d,%al
  800b8d:	75 0a                	jne    800b99 <strtol+0x33>
		s++, neg = 1;
  800b8f:	8d 52 01             	lea    0x1(%edx),%edx
  800b92:	bf 01 00 00 00       	mov    $0x1,%edi
  800b97:	eb 05                	jmp    800b9e <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800b99:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b9e:	85 db                	test   %ebx,%ebx
  800ba0:	74 05                	je     800ba7 <strtol+0x41>
  800ba2:	83 fb 10             	cmp    $0x10,%ebx
  800ba5:	75 28                	jne    800bcf <strtol+0x69>
  800ba7:	8a 02                	mov    (%edx),%al
  800ba9:	3c 30                	cmp    $0x30,%al
  800bab:	75 10                	jne    800bbd <strtol+0x57>
  800bad:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800bb1:	75 0a                	jne    800bbd <strtol+0x57>
		s += 2, base = 16;
  800bb3:	83 c2 02             	add    $0x2,%edx
  800bb6:	bb 10 00 00 00       	mov    $0x10,%ebx
  800bbb:	eb 12                	jmp    800bcf <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800bbd:	85 db                	test   %ebx,%ebx
  800bbf:	75 0e                	jne    800bcf <strtol+0x69>
  800bc1:	3c 30                	cmp    $0x30,%al
  800bc3:	75 05                	jne    800bca <strtol+0x64>
		s++, base = 8;
  800bc5:	42                   	inc    %edx
  800bc6:	b3 08                	mov    $0x8,%bl
  800bc8:	eb 05                	jmp    800bcf <strtol+0x69>
	else if (base == 0)
		base = 10;
  800bca:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800bcf:	b8 00 00 00 00       	mov    $0x0,%eax
  800bd4:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800bd6:	8a 0a                	mov    (%edx),%cl
  800bd8:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800bdb:	80 fb 09             	cmp    $0x9,%bl
  800bde:	77 08                	ja     800be8 <strtol+0x82>
			dig = *s - '0';
  800be0:	0f be c9             	movsbl %cl,%ecx
  800be3:	83 e9 30             	sub    $0x30,%ecx
  800be6:	eb 1e                	jmp    800c06 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800be8:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800beb:	80 fb 19             	cmp    $0x19,%bl
  800bee:	77 08                	ja     800bf8 <strtol+0x92>
			dig = *s - 'a' + 10;
  800bf0:	0f be c9             	movsbl %cl,%ecx
  800bf3:	83 e9 57             	sub    $0x57,%ecx
  800bf6:	eb 0e                	jmp    800c06 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800bf8:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800bfb:	80 fb 19             	cmp    $0x19,%bl
  800bfe:	77 13                	ja     800c13 <strtol+0xad>
			dig = *s - 'A' + 10;
  800c00:	0f be c9             	movsbl %cl,%ecx
  800c03:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800c06:	39 f1                	cmp    %esi,%ecx
  800c08:	7d 0d                	jge    800c17 <strtol+0xb1>
			break;
		s++, val = (val * base) + dig;
  800c0a:	42                   	inc    %edx
  800c0b:	0f af c6             	imul   %esi,%eax
  800c0e:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  800c11:	eb c3                	jmp    800bd6 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800c13:	89 c1                	mov    %eax,%ecx
  800c15:	eb 02                	jmp    800c19 <strtol+0xb3>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800c17:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800c19:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c1d:	74 05                	je     800c24 <strtol+0xbe>
		*endptr = (char *) s;
  800c1f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800c22:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800c24:	85 ff                	test   %edi,%edi
  800c26:	74 04                	je     800c2c <strtol+0xc6>
  800c28:	89 c8                	mov    %ecx,%eax
  800c2a:	f7 d8                	neg    %eax
}
  800c2c:	5b                   	pop    %ebx
  800c2d:	5e                   	pop    %esi
  800c2e:	5f                   	pop    %edi
  800c2f:	c9                   	leave  
  800c30:	c3                   	ret    
  800c31:	00 00                	add    %al,(%eax)
	...

00800c34 <syscall>:
	return ret;
}

static int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800c34:	55                   	push   %ebp
  800c35:	89 e5                	mov    %esp,%ebp
  800c37:	57                   	push   %edi
  800c38:	56                   	push   %esi
  800c39:	53                   	push   %ebx
  800c3a:	83 ec 1c             	sub    $0x1c,%esp
  800c3d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800c40:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800c43:	89 ca                	mov    %ecx,%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c45:	8b 75 14             	mov    0x14(%ebp),%esi
  800c48:	8b 7d 10             	mov    0x10(%ebp),%edi
  800c4b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800c4e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c51:	cd 30                	int    $0x30
  800c53:	89 c2                	mov    %eax,%edx
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c55:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800c59:	74 1c                	je     800c77 <syscall+0x43>
  800c5b:	85 c0                	test   %eax,%eax
  800c5d:	7e 18                	jle    800c77 <syscall+0x43>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c5f:	83 ec 0c             	sub    $0xc,%esp
  800c62:	50                   	push   %eax
  800c63:	ff 75 e4             	pushl  -0x1c(%ebp)
  800c66:	68 9f 27 80 00       	push   $0x80279f
  800c6b:	6a 42                	push   $0x42
  800c6d:	68 bc 27 80 00       	push   $0x8027bc
  800c72:	e8 b1 f5 ff ff       	call   800228 <_panic>

	return ret;
}
  800c77:	89 d0                	mov    %edx,%eax
  800c79:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c7c:	5b                   	pop    %ebx
  800c7d:	5e                   	pop    %esi
  800c7e:	5f                   	pop    %edi
  800c7f:	c9                   	leave  
  800c80:	c3                   	ret    

00800c81 <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{	
  800c81:	55                   	push   %ebp
  800c82:	89 e5                	mov    %esp,%ebp
  800c84:	83 ec 08             	sub    $0x8,%esp
	// my_sysenter(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
	// return;
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  800c87:	6a 00                	push   $0x0
  800c89:	6a 00                	push   $0x0
  800c8b:	6a 00                	push   $0x0
  800c8d:	ff 75 0c             	pushl  0xc(%ebp)
  800c90:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c93:	ba 00 00 00 00       	mov    $0x0,%edx
  800c98:	b8 00 00 00 00       	mov    $0x0,%eax
  800c9d:	e8 92 ff ff ff       	call   800c34 <syscall>
  800ca2:	83 c4 10             	add    $0x10,%esp
	return;
}
  800ca5:	c9                   	leave  
  800ca6:	c3                   	ret    

00800ca7 <sys_cgetc>:

int
sys_cgetc(void)
{
  800ca7:	55                   	push   %ebp
  800ca8:	89 e5                	mov    %esp,%ebp
  800caa:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_cgetc, 0, 0, 0, 0, 0, 0);
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  800cad:	6a 00                	push   $0x0
  800caf:	6a 00                	push   $0x0
  800cb1:	6a 00                	push   $0x0
  800cb3:	6a 00                	push   $0x0
  800cb5:	b9 00 00 00 00       	mov    $0x0,%ecx
  800cba:	ba 00 00 00 00       	mov    $0x0,%edx
  800cbf:	b8 01 00 00 00       	mov    $0x1,%eax
  800cc4:	e8 6b ff ff ff       	call   800c34 <syscall>
}
  800cc9:	c9                   	leave  
  800cca:	c3                   	ret    

00800ccb <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800ccb:	55                   	push   %ebp
  800ccc:	89 e5                	mov    %esp,%ebp
  800cce:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  800cd1:	6a 00                	push   $0x0
  800cd3:	6a 00                	push   $0x0
  800cd5:	6a 00                	push   $0x0
  800cd7:	6a 00                	push   $0x0
  800cd9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800cdc:	ba 01 00 00 00       	mov    $0x1,%edx
  800ce1:	b8 03 00 00 00       	mov    $0x3,%eax
  800ce6:	e8 49 ff ff ff       	call   800c34 <syscall>
}
  800ceb:	c9                   	leave  
  800cec:	c3                   	ret    

00800ced <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800ced:	55                   	push   %ebp
  800cee:	89 e5                	mov    %esp,%ebp
  800cf0:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_getenvid, 0, 0, 0, 0, 0, 0);
	return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  800cf3:	6a 00                	push   $0x0
  800cf5:	6a 00                	push   $0x0
  800cf7:	6a 00                	push   $0x0
  800cf9:	6a 00                	push   $0x0
  800cfb:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d00:	ba 00 00 00 00       	mov    $0x0,%edx
  800d05:	b8 02 00 00 00       	mov    $0x2,%eax
  800d0a:	e8 25 ff ff ff       	call   800c34 <syscall>
}
  800d0f:	c9                   	leave  
  800d10:	c3                   	ret    

00800d11 <sys_yield>:

void
sys_yield(void)
{
  800d11:	55                   	push   %ebp
  800d12:	89 e5                	mov    %esp,%ebp
  800d14:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  800d17:	6a 00                	push   $0x0
  800d19:	6a 00                	push   $0x0
  800d1b:	6a 00                	push   $0x0
  800d1d:	6a 00                	push   $0x0
  800d1f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d24:	ba 00 00 00 00       	mov    $0x0,%edx
  800d29:	b8 0b 00 00 00       	mov    $0xb,%eax
  800d2e:	e8 01 ff ff ff       	call   800c34 <syscall>
  800d33:	83 c4 10             	add    $0x10,%esp
}
  800d36:	c9                   	leave  
  800d37:	c3                   	ret    

00800d38 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800d38:	55                   	push   %ebp
  800d39:	89 e5                	mov    %esp,%ebp
  800d3b:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  800d3e:	6a 00                	push   $0x0
  800d40:	6a 00                	push   $0x0
  800d42:	ff 75 10             	pushl  0x10(%ebp)
  800d45:	ff 75 0c             	pushl  0xc(%ebp)
  800d48:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d4b:	ba 01 00 00 00       	mov    $0x1,%edx
  800d50:	b8 04 00 00 00       	mov    $0x4,%eax
  800d55:	e8 da fe ff ff       	call   800c34 <syscall>
}
  800d5a:	c9                   	leave  
  800d5b:	c3                   	ret    

00800d5c <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800d5c:	55                   	push   %ebp
  800d5d:	89 e5                	mov    %esp,%ebp
  800d5f:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
  800d62:	ff 75 18             	pushl  0x18(%ebp)
  800d65:	ff 75 14             	pushl  0x14(%ebp)
  800d68:	ff 75 10             	pushl  0x10(%ebp)
  800d6b:	ff 75 0c             	pushl  0xc(%ebp)
  800d6e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d71:	ba 01 00 00 00       	mov    $0x1,%edx
  800d76:	b8 05 00 00 00       	mov    $0x5,%eax
  800d7b:	e8 b4 fe ff ff       	call   800c34 <syscall>
}
  800d80:	c9                   	leave  
  800d81:	c3                   	ret    

00800d82 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800d82:	55                   	push   %ebp
  800d83:	89 e5                	mov    %esp,%ebp
  800d85:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  800d88:	6a 00                	push   $0x0
  800d8a:	6a 00                	push   $0x0
  800d8c:	6a 00                	push   $0x0
  800d8e:	ff 75 0c             	pushl  0xc(%ebp)
  800d91:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d94:	ba 01 00 00 00       	mov    $0x1,%edx
  800d99:	b8 06 00 00 00       	mov    $0x6,%eax
  800d9e:	e8 91 fe ff ff       	call   800c34 <syscall>
}
  800da3:	c9                   	leave  
  800da4:	c3                   	ret    

00800da5 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800da5:	55                   	push   %ebp
  800da6:	89 e5                	mov    %esp,%ebp
  800da8:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  800dab:	6a 00                	push   $0x0
  800dad:	6a 00                	push   $0x0
  800daf:	6a 00                	push   $0x0
  800db1:	ff 75 0c             	pushl  0xc(%ebp)
  800db4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800db7:	ba 01 00 00 00       	mov    $0x1,%edx
  800dbc:	b8 08 00 00 00       	mov    $0x8,%eax
  800dc1:	e8 6e fe ff ff       	call   800c34 <syscall>
}
  800dc6:	c9                   	leave  
  800dc7:	c3                   	ret    

00800dc8 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800dc8:	55                   	push   %ebp
  800dc9:	89 e5                	mov    %esp,%ebp
  800dcb:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
  800dce:	6a 00                	push   $0x0
  800dd0:	6a 00                	push   $0x0
  800dd2:	6a 00                	push   $0x0
  800dd4:	ff 75 0c             	pushl  0xc(%ebp)
  800dd7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800dda:	ba 01 00 00 00       	mov    $0x1,%edx
  800ddf:	b8 09 00 00 00       	mov    $0x9,%eax
  800de4:	e8 4b fe ff ff       	call   800c34 <syscall>
}
  800de9:	c9                   	leave  
  800dea:	c3                   	ret    

00800deb <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800deb:	55                   	push   %ebp
  800dec:	89 e5                	mov    %esp,%ebp
  800dee:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  800df1:	6a 00                	push   $0x0
  800df3:	6a 00                	push   $0x0
  800df5:	6a 00                	push   $0x0
  800df7:	ff 75 0c             	pushl  0xc(%ebp)
  800dfa:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800dfd:	ba 01 00 00 00       	mov    $0x1,%edx
  800e02:	b8 0a 00 00 00       	mov    $0xa,%eax
  800e07:	e8 28 fe ff ff       	call   800c34 <syscall>
}
  800e0c:	c9                   	leave  
  800e0d:	c3                   	ret    

00800e0e <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800e0e:	55                   	push   %ebp
  800e0f:	89 e5                	mov    %esp,%ebp
  800e11:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  800e14:	6a 00                	push   $0x0
  800e16:	ff 75 14             	pushl  0x14(%ebp)
  800e19:	ff 75 10             	pushl  0x10(%ebp)
  800e1c:	ff 75 0c             	pushl  0xc(%ebp)
  800e1f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e22:	ba 00 00 00 00       	mov    $0x0,%edx
  800e27:	b8 0c 00 00 00       	mov    $0xc,%eax
  800e2c:	e8 03 fe ff ff       	call   800c34 <syscall>
}
  800e31:	c9                   	leave  
  800e32:	c3                   	ret    

00800e33 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800e33:	55                   	push   %ebp
  800e34:	89 e5                	mov    %esp,%ebp
  800e36:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  800e39:	6a 00                	push   $0x0
  800e3b:	6a 00                	push   $0x0
  800e3d:	6a 00                	push   $0x0
  800e3f:	6a 00                	push   $0x0
  800e41:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e44:	ba 01 00 00 00       	mov    $0x1,%edx
  800e49:	b8 0d 00 00 00       	mov    $0xd,%eax
  800e4e:	e8 e1 fd ff ff       	call   800c34 <syscall>
}
  800e53:	c9                   	leave  
  800e54:	c3                   	ret    

00800e55 <sys_set_priority>:

int
sys_set_priority(envid_t envid, uint32_t new_priority)
{
  800e55:	55                   	push   %ebp
  800e56:	89 e5                	mov    %esp,%ebp
  800e58:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_set_priority, 0, envid, new_priority, 0, 0, 0);
  800e5b:	6a 00                	push   $0x0
  800e5d:	6a 00                	push   $0x0
  800e5f:	6a 00                	push   $0x0
  800e61:	ff 75 0c             	pushl  0xc(%ebp)
  800e64:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e67:	ba 00 00 00 00       	mov    $0x0,%edx
  800e6c:	b8 0e 00 00 00       	mov    $0xe,%eax
  800e71:	e8 be fd ff ff       	call   800c34 <syscall>
}
  800e76:	c9                   	leave  
  800e77:	c3                   	ret    

00800e78 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800e78:	55                   	push   %ebp
  800e79:	89 e5                	mov    %esp,%ebp
  800e7b:	53                   	push   %ebx
  800e7c:	83 ec 04             	sub    $0x4,%esp
  800e7f:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800e82:	8b 18                	mov    (%eax),%ebx

	// LAB 4: Your code here.
	
	// cprintf("PAGE FAULT HANDLER, 0x%08x %d\n", (uint32_t)addr, err & FEC_WR);
	
	if ((err & FEC_WR) == 0)
  800e84:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800e88:	75 14                	jne    800e9e <pgfault+0x26>
		panic("pgfault, the fault is not a write\n");
  800e8a:	83 ec 04             	sub    $0x4,%esp
  800e8d:	68 cc 27 80 00       	push   $0x8027cc
  800e92:	6a 20                	push   $0x20
  800e94:	68 10 29 80 00       	push   $0x802910
  800e99:	e8 8a f3 ff ff       	call   800228 <_panic>

	uint32_t uaddr = (uint32_t) addr;
	if ((uvpd[PDX(addr)] & PTE_P) == 0 || (uvpt[uaddr / PGSIZE] & PTE_COW) == 0) {
  800e9e:	89 d8                	mov    %ebx,%eax
  800ea0:	c1 e8 16             	shr    $0x16,%eax
  800ea3:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800eaa:	a8 01                	test   $0x1,%al
  800eac:	74 11                	je     800ebf <pgfault+0x47>
  800eae:	89 d8                	mov    %ebx,%eax
  800eb0:	c1 e8 0c             	shr    $0xc,%eax
  800eb3:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800eba:	f6 c4 08             	test   $0x8,%ah
  800ebd:	75 14                	jne    800ed3 <pgfault+0x5b>
		panic("pgfault, not a copy-on-write page\n");
  800ebf:	83 ec 04             	sub    $0x4,%esp
  800ec2:	68 f0 27 80 00       	push   $0x8027f0
  800ec7:	6a 24                	push   $0x24
  800ec9:	68 10 29 80 00       	push   $0x802910
  800ece:	e8 55 f3 ff ff       	call   800228 <_panic>
	//   No need to explicitly delete the old page's mapping.

	// LAB 4: Your code here.

	// static int sys_page_alloc(envid_t envid, void *va, int perm)
	r = sys_page_alloc(0, (void *)PFTEMP, PTE_W | PTE_U | PTE_P);
  800ed3:	83 ec 04             	sub    $0x4,%esp
  800ed6:	6a 07                	push   $0x7
  800ed8:	68 00 f0 7f 00       	push   $0x7ff000
  800edd:	6a 00                	push   $0x0
  800edf:	e8 54 fe ff ff       	call   800d38 <sys_page_alloc>
	if (r < 0) panic("pgfault, sys_page_alloc error : %e\n", r);
  800ee4:	83 c4 10             	add    $0x10,%esp
  800ee7:	85 c0                	test   %eax,%eax
  800ee9:	79 12                	jns    800efd <pgfault+0x85>
  800eeb:	50                   	push   %eax
  800eec:	68 14 28 80 00       	push   $0x802814
  800ef1:	6a 32                	push   $0x32
  800ef3:	68 10 29 80 00       	push   $0x802910
  800ef8:	e8 2b f3 ff ff       	call   800228 <_panic>

	// Oh my god, I forget this at the first, it waste me a lot of time to debug!!!
	addr = ROUNDDOWN(addr, PGSIZE);
  800efd:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	
	memcpy(PFTEMP, addr, PGSIZE);
  800f03:	83 ec 04             	sub    $0x4,%esp
  800f06:	68 00 10 00 00       	push   $0x1000
  800f0b:	53                   	push   %ebx
  800f0c:	68 00 f0 7f 00       	push   $0x7ff000
  800f11:	e8 cb fb ff ff       	call   800ae1 <memcpy>
	
	r = sys_page_map(0, PFTEMP, 0, addr, PTE_W | PTE_U | PTE_P);
  800f16:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800f1d:	53                   	push   %ebx
  800f1e:	6a 00                	push   $0x0
  800f20:	68 00 f0 7f 00       	push   $0x7ff000
  800f25:	6a 00                	push   $0x0
  800f27:	e8 30 fe ff ff       	call   800d5c <sys_page_map>
	if (r < 0) panic("pgfault, sys_page_map error : %e\n", r);
  800f2c:	83 c4 20             	add    $0x20,%esp
  800f2f:	85 c0                	test   %eax,%eax
  800f31:	79 12                	jns    800f45 <pgfault+0xcd>
  800f33:	50                   	push   %eax
  800f34:	68 38 28 80 00       	push   $0x802838
  800f39:	6a 3a                	push   $0x3a
  800f3b:	68 10 29 80 00       	push   $0x802910
  800f40:	e8 e3 f2 ff ff       	call   800228 <_panic>

	return;
}
  800f45:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f48:	c9                   	leave  
  800f49:	c3                   	ret    

00800f4a <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800f4a:	55                   	push   %ebp
  800f4b:	89 e5                	mov    %esp,%ebp
  800f4d:	57                   	push   %edi
  800f4e:	56                   	push   %esi
  800f4f:	53                   	push   %ebx
  800f50:	83 ec 28             	sub    $0x28,%esp
	// static int num = 0x100;

	// LAB 4: Your code here.
	set_pgfault_handler(pgfault);
  800f53:	68 78 0e 80 00       	push   $0x800e78
  800f58:	e8 4f 0f 00 00       	call   801eac <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  800f5d:	ba 07 00 00 00       	mov    $0x7,%edx
  800f62:	89 d0                	mov    %edx,%eax
  800f64:	cd 30                	int    $0x30
  800f66:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800f69:	89 c7                	mov    %eax,%edi
	int childpid = sys_exofork();
	if (childpid < 0) {
  800f6b:	83 c4 10             	add    $0x10,%esp
  800f6e:	85 c0                	test   %eax,%eax
  800f70:	79 12                	jns    800f84 <fork+0x3a>
		panic("fork sys_exofork error : %e\n", childpid);
  800f72:	50                   	push   %eax
  800f73:	68 1b 29 80 00       	push   $0x80291b
  800f78:	6a 7b                	push   $0x7b
  800f7a:	68 10 29 80 00       	push   $0x802910
  800f7f:	e8 a4 f2 ff ff       	call   800228 <_panic>
	}
	int r;

	if (childpid == 0) {
  800f84:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800f88:	75 25                	jne    800faf <fork+0x65>
		// child process
		// Remember to fix "thisenv" in the child process. ??? 
		thisenv = &envs[ENVX(sys_getenvid())];
  800f8a:	e8 5e fd ff ff       	call   800ced <sys_getenvid>
  800f8f:	25 ff 03 00 00       	and    $0x3ff,%eax
  800f94:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800f9b:	c1 e0 07             	shl    $0x7,%eax
  800f9e:	29 d0                	sub    %edx,%eax
  800fa0:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800fa5:	a3 20 44 80 00       	mov    %eax,0x804420
		// cprintf("fork child ok\n");
		return 0;
  800faa:	e9 7b 01 00 00       	jmp    80112a <fork+0x1e0>
	if (childpid < 0) {
		panic("fork sys_exofork error : %e\n", childpid);
	}
	int r;

	if (childpid == 0) {
  800faf:	bb 00 00 00 00       	mov    $0x0,%ebx
	} else {
		// map page to new environment
		// kernel page is already in new environment
		uint32_t i;
		for (i = 0; i != UTOP; i += PGSIZE) 
		if ((uvpd[PDX(i)] & PTE_P) && (uvpt[i / PGSIZE] & PTE_P) && (uvpt[i / PGSIZE] & PTE_U)) {
  800fb4:	89 d8                	mov    %ebx,%eax
  800fb6:	c1 e8 16             	shr    $0x16,%eax
  800fb9:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800fc0:	a8 01                	test   $0x1,%al
  800fc2:	0f 84 cd 00 00 00    	je     801095 <fork+0x14b>
  800fc8:	89 d8                	mov    %ebx,%eax
  800fca:	c1 e8 0c             	shr    $0xc,%eax
  800fcd:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800fd4:	f6 c2 01             	test   $0x1,%dl
  800fd7:	0f 84 b8 00 00 00    	je     801095 <fork+0x14b>
  800fdd:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800fe4:	f6 c2 04             	test   $0x4,%dl
  800fe7:	0f 84 a8 00 00 00    	je     801095 <fork+0x14b>
//
static int
duppage(envid_t envid, unsigned pn)
{
	// do not dup exception stack
	if (pn * PGSIZE == UXSTACKTOP - PGSIZE) return 0;
  800fed:	89 c6                	mov    %eax,%esi
  800fef:	c1 e6 0c             	shl    $0xc,%esi
  800ff2:	81 fe 00 f0 bf ee    	cmp    $0xeebff000,%esi
  800ff8:	0f 84 97 00 00 00    	je     801095 <fork+0x14b>

	int r;
	void * addr = (void *)(pn * PGSIZE);
	if ((uvpt[pn] & PTE_W) || (uvpt[pn] & PTE_COW)) {
  800ffe:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801005:	f6 c2 02             	test   $0x2,%dl
  801008:	75 0c                	jne    801016 <fork+0xcc>
  80100a:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801011:	f6 c4 08             	test   $0x8,%ah
  801014:	74 57                	je     80106d <fork+0x123>
		// cow
		r = sys_page_map(0, addr, envid, addr, PTE_COW | PTE_P | PTE_U);
  801016:	83 ec 0c             	sub    $0xc,%esp
  801019:	68 05 08 00 00       	push   $0x805
  80101e:	56                   	push   %esi
  80101f:	57                   	push   %edi
  801020:	56                   	push   %esi
  801021:	6a 00                	push   $0x0
  801023:	e8 34 fd ff ff       	call   800d5c <sys_page_map>
		if (r < 0) panic("duppage sys_page_map error : %e\n", r);
  801028:	83 c4 20             	add    $0x20,%esp
  80102b:	85 c0                	test   %eax,%eax
  80102d:	79 12                	jns    801041 <fork+0xf7>
  80102f:	50                   	push   %eax
  801030:	68 5c 28 80 00       	push   $0x80285c
  801035:	6a 55                	push   $0x55
  801037:	68 10 29 80 00       	push   $0x802910
  80103c:	e8 e7 f1 ff ff       	call   800228 <_panic>
		
		r = sys_page_map(0, addr, 0, addr, PTE_COW | PTE_P | PTE_U);
  801041:	83 ec 0c             	sub    $0xc,%esp
  801044:	68 05 08 00 00       	push   $0x805
  801049:	56                   	push   %esi
  80104a:	6a 00                	push   $0x0
  80104c:	56                   	push   %esi
  80104d:	6a 00                	push   $0x0
  80104f:	e8 08 fd ff ff       	call   800d5c <sys_page_map>
		if (r < 0) panic("duppage sys_page_map error : %e\n", r);
  801054:	83 c4 20             	add    $0x20,%esp
  801057:	85 c0                	test   %eax,%eax
  801059:	79 3a                	jns    801095 <fork+0x14b>
  80105b:	50                   	push   %eax
  80105c:	68 5c 28 80 00       	push   $0x80285c
  801061:	6a 58                	push   $0x58
  801063:	68 10 29 80 00       	push   $0x802910
  801068:	e8 bb f1 ff ff       	call   800228 <_panic>
	} else {
		// read only
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U);
  80106d:	83 ec 0c             	sub    $0xc,%esp
  801070:	6a 05                	push   $0x5
  801072:	56                   	push   %esi
  801073:	57                   	push   %edi
  801074:	56                   	push   %esi
  801075:	6a 00                	push   $0x0
  801077:	e8 e0 fc ff ff       	call   800d5c <sys_page_map>
		if (r < 0) panic("duppage sys_page_map error : %e\n", r);
  80107c:	83 c4 20             	add    $0x20,%esp
  80107f:	85 c0                	test   %eax,%eax
  801081:	79 12                	jns    801095 <fork+0x14b>
  801083:	50                   	push   %eax
  801084:	68 5c 28 80 00       	push   $0x80285c
  801089:	6a 5c                	push   $0x5c
  80108b:	68 10 29 80 00       	push   $0x802910
  801090:	e8 93 f1 ff ff       	call   800228 <_panic>
		return 0;
	} else {
		// map page to new environment
		// kernel page is already in new environment
		uint32_t i;
		for (i = 0; i != UTOP; i += PGSIZE) 
  801095:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  80109b:	81 fb 00 00 c0 ee    	cmp    $0xeec00000,%ebx
  8010a1:	0f 85 0d ff ff ff    	jne    800fb4 <fork+0x6a>
		if ((uvpd[PDX(i)] & PTE_P) && (uvpt[i / PGSIZE] & PTE_P) && (uvpt[i / PGSIZE] & PTE_U)) {
			duppage(childpid, i / PGSIZE);
		}

		// allocate exception stack
		r = sys_page_alloc(childpid, (void *)(UXSTACKTOP - PGSIZE), PTE_U | PTE_W | PTE_P);
  8010a7:	83 ec 04             	sub    $0x4,%esp
  8010aa:	6a 07                	push   $0x7
  8010ac:	68 00 f0 bf ee       	push   $0xeebff000
  8010b1:	ff 75 e4             	pushl  -0x1c(%ebp)
  8010b4:	e8 7f fc ff ff       	call   800d38 <sys_page_alloc>
		if (r < 0) panic("fork, sys_page_alloc user exception stack error : %e\n", r);
  8010b9:	83 c4 10             	add    $0x10,%esp
  8010bc:	85 c0                	test   %eax,%eax
  8010be:	79 15                	jns    8010d5 <fork+0x18b>
  8010c0:	50                   	push   %eax
  8010c1:	68 80 28 80 00       	push   $0x802880
  8010c6:	68 90 00 00 00       	push   $0x90
  8010cb:	68 10 29 80 00       	push   $0x802910
  8010d0:	e8 53 f1 ff ff       	call   800228 <_panic>

		// set user environment user page fault handler 
		extern void _pgfault_upcall(void);
		r = sys_env_set_pgfault_upcall(childpid, _pgfault_upcall);
  8010d5:	83 ec 08             	sub    $0x8,%esp
  8010d8:	68 18 1f 80 00       	push   $0x801f18
  8010dd:	ff 75 e4             	pushl  -0x1c(%ebp)
  8010e0:	e8 06 fd ff ff       	call   800deb <sys_env_set_pgfault_upcall>
		if (r < 0) panic("fork, set pgfault upcall fail : %e\n", r);
  8010e5:	83 c4 10             	add    $0x10,%esp
  8010e8:	85 c0                	test   %eax,%eax
  8010ea:	79 15                	jns    801101 <fork+0x1b7>
  8010ec:	50                   	push   %eax
  8010ed:	68 b8 28 80 00       	push   $0x8028b8
  8010f2:	68 95 00 00 00       	push   $0x95
  8010f7:	68 10 29 80 00       	push   $0x802910
  8010fc:	e8 27 f1 ff ff       	call   800228 <_panic>
		r = sys_set_priority(childpid, num);
		if (r < 0) panic("fork, set priority error\n");
		*/

		// mark the child as runnable and return
		r = sys_env_set_status(childpid, ENV_RUNNABLE);
  801101:	83 ec 08             	sub    $0x8,%esp
  801104:	6a 02                	push   $0x2
  801106:	ff 75 e4             	pushl  -0x1c(%ebp)
  801109:	e8 97 fc ff ff       	call   800da5 <sys_env_set_status>
		if (r < 0) panic("fork, set child process to ENV_RUNNABLE error : %e\n", r);
  80110e:	83 c4 10             	add    $0x10,%esp
  801111:	85 c0                	test   %eax,%eax
  801113:	79 15                	jns    80112a <fork+0x1e0>
  801115:	50                   	push   %eax
  801116:	68 dc 28 80 00       	push   $0x8028dc
  80111b:	68 a0 00 00 00       	push   $0xa0
  801120:	68 10 29 80 00       	push   $0x802910
  801125:	e8 fe f0 ff ff       	call   800228 <_panic>
		// cprintf("fork father ok!")
		return childpid;
	}

	panic("fork not implemented");
}
  80112a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80112d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801130:	5b                   	pop    %ebx
  801131:	5e                   	pop    %esi
  801132:	5f                   	pop    %edi
  801133:	c9                   	leave  
  801134:	c3                   	ret    

00801135 <sfork>:

// Challenge!
int
sfork(void)
{
  801135:	55                   	push   %ebp
  801136:	89 e5                	mov    %esp,%ebp
  801138:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  80113b:	68 38 29 80 00       	push   $0x802938
  801140:	68 ad 00 00 00       	push   $0xad
  801145:	68 10 29 80 00       	push   $0x802910
  80114a:	e8 d9 f0 ff ff       	call   800228 <_panic>
	...

00801150 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801150:	55                   	push   %ebp
  801151:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801153:	8b 45 08             	mov    0x8(%ebp),%eax
  801156:	05 00 00 00 30       	add    $0x30000000,%eax
  80115b:	c1 e8 0c             	shr    $0xc,%eax
}
  80115e:	c9                   	leave  
  80115f:	c3                   	ret    

00801160 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801160:	55                   	push   %ebp
  801161:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  801163:	ff 75 08             	pushl  0x8(%ebp)
  801166:	e8 e5 ff ff ff       	call   801150 <fd2num>
  80116b:	83 c4 04             	add    $0x4,%esp
  80116e:	05 20 00 0d 00       	add    $0xd0020,%eax
  801173:	c1 e0 0c             	shl    $0xc,%eax
}
  801176:	c9                   	leave  
  801177:	c3                   	ret    

00801178 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801178:	55                   	push   %ebp
  801179:	89 e5                	mov    %esp,%ebp
  80117b:	53                   	push   %ebx
  80117c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80117f:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  801184:	a8 01                	test   $0x1,%al
  801186:	74 34                	je     8011bc <fd_alloc+0x44>
  801188:	a1 00 00 74 ef       	mov    0xef740000,%eax
  80118d:	a8 01                	test   $0x1,%al
  80118f:	74 32                	je     8011c3 <fd_alloc+0x4b>
  801191:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
  801196:	89 c1                	mov    %eax,%ecx
  801198:	89 c2                	mov    %eax,%edx
  80119a:	c1 ea 16             	shr    $0x16,%edx
  80119d:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8011a4:	f6 c2 01             	test   $0x1,%dl
  8011a7:	74 1f                	je     8011c8 <fd_alloc+0x50>
  8011a9:	89 c2                	mov    %eax,%edx
  8011ab:	c1 ea 0c             	shr    $0xc,%edx
  8011ae:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8011b5:	f6 c2 01             	test   $0x1,%dl
  8011b8:	75 17                	jne    8011d1 <fd_alloc+0x59>
  8011ba:	eb 0c                	jmp    8011c8 <fd_alloc+0x50>
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  8011bc:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
  8011c1:	eb 05                	jmp    8011c8 <fd_alloc+0x50>
  8011c3:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
  8011c8:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  8011ca:	b8 00 00 00 00       	mov    $0x0,%eax
  8011cf:	eb 17                	jmp    8011e8 <fd_alloc+0x70>
  8011d1:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8011d6:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8011db:	75 b9                	jne    801196 <fd_alloc+0x1e>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8011dd:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  8011e3:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8011e8:	5b                   	pop    %ebx
  8011e9:	c9                   	leave  
  8011ea:	c3                   	ret    

008011eb <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8011eb:	55                   	push   %ebp
  8011ec:	89 e5                	mov    %esp,%ebp
  8011ee:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8011f1:	83 f8 1f             	cmp    $0x1f,%eax
  8011f4:	77 36                	ja     80122c <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8011f6:	05 00 00 0d 00       	add    $0xd0000,%eax
  8011fb:	c1 e0 0c             	shl    $0xc,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8011fe:	89 c2                	mov    %eax,%edx
  801200:	c1 ea 16             	shr    $0x16,%edx
  801203:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80120a:	f6 c2 01             	test   $0x1,%dl
  80120d:	74 24                	je     801233 <fd_lookup+0x48>
  80120f:	89 c2                	mov    %eax,%edx
  801211:	c1 ea 0c             	shr    $0xc,%edx
  801214:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80121b:	f6 c2 01             	test   $0x1,%dl
  80121e:	74 1a                	je     80123a <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801220:	8b 55 0c             	mov    0xc(%ebp),%edx
  801223:	89 02                	mov    %eax,(%edx)
	return 0;
  801225:	b8 00 00 00 00       	mov    $0x0,%eax
  80122a:	eb 13                	jmp    80123f <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80122c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801231:	eb 0c                	jmp    80123f <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801233:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801238:	eb 05                	jmp    80123f <fd_lookup+0x54>
  80123a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  80123f:	c9                   	leave  
  801240:	c3                   	ret    

00801241 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801241:	55                   	push   %ebp
  801242:	89 e5                	mov    %esp,%ebp
  801244:	53                   	push   %ebx
  801245:	83 ec 04             	sub    $0x4,%esp
  801248:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80124b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  80124e:	39 0d 04 30 80 00    	cmp    %ecx,0x803004
  801254:	74 0d                	je     801263 <dev_lookup+0x22>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801256:	b8 00 00 00 00       	mov    $0x0,%eax
  80125b:	eb 14                	jmp    801271 <dev_lookup+0x30>
		if (devtab[i]->dev_id == dev_id) {
  80125d:	39 0a                	cmp    %ecx,(%edx)
  80125f:	75 10                	jne    801271 <dev_lookup+0x30>
  801261:	eb 05                	jmp    801268 <dev_lookup+0x27>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801263:	ba 04 30 80 00       	mov    $0x803004,%edx
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
  801268:	89 13                	mov    %edx,(%ebx)
			return 0;
  80126a:	b8 00 00 00 00       	mov    $0x0,%eax
  80126f:	eb 31                	jmp    8012a2 <dev_lookup+0x61>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801271:	40                   	inc    %eax
  801272:	8b 14 85 cc 29 80 00 	mov    0x8029cc(,%eax,4),%edx
  801279:	85 d2                	test   %edx,%edx
  80127b:	75 e0                	jne    80125d <dev_lookup+0x1c>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80127d:	a1 20 44 80 00       	mov    0x804420,%eax
  801282:	8b 40 48             	mov    0x48(%eax),%eax
  801285:	83 ec 04             	sub    $0x4,%esp
  801288:	51                   	push   %ecx
  801289:	50                   	push   %eax
  80128a:	68 50 29 80 00       	push   $0x802950
  80128f:	e8 6c f0 ff ff       	call   800300 <cprintf>
	*dev = 0;
  801294:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  80129a:	83 c4 10             	add    $0x10,%esp
  80129d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8012a2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012a5:	c9                   	leave  
  8012a6:	c3                   	ret    

008012a7 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8012a7:	55                   	push   %ebp
  8012a8:	89 e5                	mov    %esp,%ebp
  8012aa:	56                   	push   %esi
  8012ab:	53                   	push   %ebx
  8012ac:	83 ec 20             	sub    $0x20,%esp
  8012af:	8b 75 08             	mov    0x8(%ebp),%esi
  8012b2:	8a 45 0c             	mov    0xc(%ebp),%al
  8012b5:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8012b8:	56                   	push   %esi
  8012b9:	e8 92 fe ff ff       	call   801150 <fd2num>
  8012be:	8d 55 f4             	lea    -0xc(%ebp),%edx
  8012c1:	89 14 24             	mov    %edx,(%esp)
  8012c4:	50                   	push   %eax
  8012c5:	e8 21 ff ff ff       	call   8011eb <fd_lookup>
  8012ca:	89 c3                	mov    %eax,%ebx
  8012cc:	83 c4 08             	add    $0x8,%esp
  8012cf:	85 c0                	test   %eax,%eax
  8012d1:	78 05                	js     8012d8 <fd_close+0x31>
	    || fd != fd2)
  8012d3:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8012d6:	74 0d                	je     8012e5 <fd_close+0x3e>
		return (must_exist ? r : 0);
  8012d8:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  8012dc:	75 48                	jne    801326 <fd_close+0x7f>
  8012de:	bb 00 00 00 00       	mov    $0x0,%ebx
  8012e3:	eb 41                	jmp    801326 <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8012e5:	83 ec 08             	sub    $0x8,%esp
  8012e8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012eb:	50                   	push   %eax
  8012ec:	ff 36                	pushl  (%esi)
  8012ee:	e8 4e ff ff ff       	call   801241 <dev_lookup>
  8012f3:	89 c3                	mov    %eax,%ebx
  8012f5:	83 c4 10             	add    $0x10,%esp
  8012f8:	85 c0                	test   %eax,%eax
  8012fa:	78 1c                	js     801318 <fd_close+0x71>
		if (dev->dev_close)
  8012fc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012ff:	8b 40 10             	mov    0x10(%eax),%eax
  801302:	85 c0                	test   %eax,%eax
  801304:	74 0d                	je     801313 <fd_close+0x6c>
			r = (*dev->dev_close)(fd);
  801306:	83 ec 0c             	sub    $0xc,%esp
  801309:	56                   	push   %esi
  80130a:	ff d0                	call   *%eax
  80130c:	89 c3                	mov    %eax,%ebx
  80130e:	83 c4 10             	add    $0x10,%esp
  801311:	eb 05                	jmp    801318 <fd_close+0x71>
		else
			r = 0;
  801313:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801318:	83 ec 08             	sub    $0x8,%esp
  80131b:	56                   	push   %esi
  80131c:	6a 00                	push   $0x0
  80131e:	e8 5f fa ff ff       	call   800d82 <sys_page_unmap>
	return r;
  801323:	83 c4 10             	add    $0x10,%esp
}
  801326:	89 d8                	mov    %ebx,%eax
  801328:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80132b:	5b                   	pop    %ebx
  80132c:	5e                   	pop    %esi
  80132d:	c9                   	leave  
  80132e:	c3                   	ret    

0080132f <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80132f:	55                   	push   %ebp
  801330:	89 e5                	mov    %esp,%ebp
  801332:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801335:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801338:	50                   	push   %eax
  801339:	ff 75 08             	pushl  0x8(%ebp)
  80133c:	e8 aa fe ff ff       	call   8011eb <fd_lookup>
  801341:	83 c4 08             	add    $0x8,%esp
  801344:	85 c0                	test   %eax,%eax
  801346:	78 10                	js     801358 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801348:	83 ec 08             	sub    $0x8,%esp
  80134b:	6a 01                	push   $0x1
  80134d:	ff 75 f4             	pushl  -0xc(%ebp)
  801350:	e8 52 ff ff ff       	call   8012a7 <fd_close>
  801355:	83 c4 10             	add    $0x10,%esp
}
  801358:	c9                   	leave  
  801359:	c3                   	ret    

0080135a <close_all>:

void
close_all(void)
{
  80135a:	55                   	push   %ebp
  80135b:	89 e5                	mov    %esp,%ebp
  80135d:	53                   	push   %ebx
  80135e:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801361:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801366:	83 ec 0c             	sub    $0xc,%esp
  801369:	53                   	push   %ebx
  80136a:	e8 c0 ff ff ff       	call   80132f <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80136f:	43                   	inc    %ebx
  801370:	83 c4 10             	add    $0x10,%esp
  801373:	83 fb 20             	cmp    $0x20,%ebx
  801376:	75 ee                	jne    801366 <close_all+0xc>
		close(i);
}
  801378:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80137b:	c9                   	leave  
  80137c:	c3                   	ret    

0080137d <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80137d:	55                   	push   %ebp
  80137e:	89 e5                	mov    %esp,%ebp
  801380:	57                   	push   %edi
  801381:	56                   	push   %esi
  801382:	53                   	push   %ebx
  801383:	83 ec 2c             	sub    $0x2c,%esp
  801386:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801389:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80138c:	50                   	push   %eax
  80138d:	ff 75 08             	pushl  0x8(%ebp)
  801390:	e8 56 fe ff ff       	call   8011eb <fd_lookup>
  801395:	89 c3                	mov    %eax,%ebx
  801397:	83 c4 08             	add    $0x8,%esp
  80139a:	85 c0                	test   %eax,%eax
  80139c:	0f 88 c0 00 00 00    	js     801462 <dup+0xe5>
		return r;
	close(newfdnum);
  8013a2:	83 ec 0c             	sub    $0xc,%esp
  8013a5:	57                   	push   %edi
  8013a6:	e8 84 ff ff ff       	call   80132f <close>

	newfd = INDEX2FD(newfdnum);
  8013ab:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  8013b1:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  8013b4:	83 c4 04             	add    $0x4,%esp
  8013b7:	ff 75 e4             	pushl  -0x1c(%ebp)
  8013ba:	e8 a1 fd ff ff       	call   801160 <fd2data>
  8013bf:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  8013c1:	89 34 24             	mov    %esi,(%esp)
  8013c4:	e8 97 fd ff ff       	call   801160 <fd2data>
  8013c9:	83 c4 10             	add    $0x10,%esp
  8013cc:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8013cf:	89 d8                	mov    %ebx,%eax
  8013d1:	c1 e8 16             	shr    $0x16,%eax
  8013d4:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8013db:	a8 01                	test   $0x1,%al
  8013dd:	74 37                	je     801416 <dup+0x99>
  8013df:	89 d8                	mov    %ebx,%eax
  8013e1:	c1 e8 0c             	shr    $0xc,%eax
  8013e4:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8013eb:	f6 c2 01             	test   $0x1,%dl
  8013ee:	74 26                	je     801416 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8013f0:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8013f7:	83 ec 0c             	sub    $0xc,%esp
  8013fa:	25 07 0e 00 00       	and    $0xe07,%eax
  8013ff:	50                   	push   %eax
  801400:	ff 75 d4             	pushl  -0x2c(%ebp)
  801403:	6a 00                	push   $0x0
  801405:	53                   	push   %ebx
  801406:	6a 00                	push   $0x0
  801408:	e8 4f f9 ff ff       	call   800d5c <sys_page_map>
  80140d:	89 c3                	mov    %eax,%ebx
  80140f:	83 c4 20             	add    $0x20,%esp
  801412:	85 c0                	test   %eax,%eax
  801414:	78 2d                	js     801443 <dup+0xc6>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801416:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801419:	89 c2                	mov    %eax,%edx
  80141b:	c1 ea 0c             	shr    $0xc,%edx
  80141e:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801425:	83 ec 0c             	sub    $0xc,%esp
  801428:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  80142e:	52                   	push   %edx
  80142f:	56                   	push   %esi
  801430:	6a 00                	push   $0x0
  801432:	50                   	push   %eax
  801433:	6a 00                	push   $0x0
  801435:	e8 22 f9 ff ff       	call   800d5c <sys_page_map>
  80143a:	89 c3                	mov    %eax,%ebx
  80143c:	83 c4 20             	add    $0x20,%esp
  80143f:	85 c0                	test   %eax,%eax
  801441:	79 1d                	jns    801460 <dup+0xe3>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801443:	83 ec 08             	sub    $0x8,%esp
  801446:	56                   	push   %esi
  801447:	6a 00                	push   $0x0
  801449:	e8 34 f9 ff ff       	call   800d82 <sys_page_unmap>
	sys_page_unmap(0, nva);
  80144e:	83 c4 08             	add    $0x8,%esp
  801451:	ff 75 d4             	pushl  -0x2c(%ebp)
  801454:	6a 00                	push   $0x0
  801456:	e8 27 f9 ff ff       	call   800d82 <sys_page_unmap>
	return r;
  80145b:	83 c4 10             	add    $0x10,%esp
  80145e:	eb 02                	jmp    801462 <dup+0xe5>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  801460:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  801462:	89 d8                	mov    %ebx,%eax
  801464:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801467:	5b                   	pop    %ebx
  801468:	5e                   	pop    %esi
  801469:	5f                   	pop    %edi
  80146a:	c9                   	leave  
  80146b:	c3                   	ret    

0080146c <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80146c:	55                   	push   %ebp
  80146d:	89 e5                	mov    %esp,%ebp
  80146f:	53                   	push   %ebx
  801470:	83 ec 14             	sub    $0x14,%esp
  801473:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801476:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801479:	50                   	push   %eax
  80147a:	53                   	push   %ebx
  80147b:	e8 6b fd ff ff       	call   8011eb <fd_lookup>
  801480:	83 c4 08             	add    $0x8,%esp
  801483:	85 c0                	test   %eax,%eax
  801485:	78 67                	js     8014ee <read+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801487:	83 ec 08             	sub    $0x8,%esp
  80148a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80148d:	50                   	push   %eax
  80148e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801491:	ff 30                	pushl  (%eax)
  801493:	e8 a9 fd ff ff       	call   801241 <dev_lookup>
  801498:	83 c4 10             	add    $0x10,%esp
  80149b:	85 c0                	test   %eax,%eax
  80149d:	78 4f                	js     8014ee <read+0x82>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80149f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014a2:	8b 50 08             	mov    0x8(%eax),%edx
  8014a5:	83 e2 03             	and    $0x3,%edx
  8014a8:	83 fa 01             	cmp    $0x1,%edx
  8014ab:	75 21                	jne    8014ce <read+0x62>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8014ad:	a1 20 44 80 00       	mov    0x804420,%eax
  8014b2:	8b 40 48             	mov    0x48(%eax),%eax
  8014b5:	83 ec 04             	sub    $0x4,%esp
  8014b8:	53                   	push   %ebx
  8014b9:	50                   	push   %eax
  8014ba:	68 91 29 80 00       	push   $0x802991
  8014bf:	e8 3c ee ff ff       	call   800300 <cprintf>
		return -E_INVAL;
  8014c4:	83 c4 10             	add    $0x10,%esp
  8014c7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8014cc:	eb 20                	jmp    8014ee <read+0x82>
	}
	if (!dev->dev_read)
  8014ce:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8014d1:	8b 52 08             	mov    0x8(%edx),%edx
  8014d4:	85 d2                	test   %edx,%edx
  8014d6:	74 11                	je     8014e9 <read+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8014d8:	83 ec 04             	sub    $0x4,%esp
  8014db:	ff 75 10             	pushl  0x10(%ebp)
  8014de:	ff 75 0c             	pushl  0xc(%ebp)
  8014e1:	50                   	push   %eax
  8014e2:	ff d2                	call   *%edx
  8014e4:	83 c4 10             	add    $0x10,%esp
  8014e7:	eb 05                	jmp    8014ee <read+0x82>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8014e9:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  8014ee:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014f1:	c9                   	leave  
  8014f2:	c3                   	ret    

008014f3 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8014f3:	55                   	push   %ebp
  8014f4:	89 e5                	mov    %esp,%ebp
  8014f6:	57                   	push   %edi
  8014f7:	56                   	push   %esi
  8014f8:	53                   	push   %ebx
  8014f9:	83 ec 0c             	sub    $0xc,%esp
  8014fc:	8b 7d 08             	mov    0x8(%ebp),%edi
  8014ff:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801502:	85 f6                	test   %esi,%esi
  801504:	74 31                	je     801537 <readn+0x44>
  801506:	b8 00 00 00 00       	mov    $0x0,%eax
  80150b:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = read(fdnum, (char*)buf + tot, n - tot);
  801510:	83 ec 04             	sub    $0x4,%esp
  801513:	89 f2                	mov    %esi,%edx
  801515:	29 c2                	sub    %eax,%edx
  801517:	52                   	push   %edx
  801518:	03 45 0c             	add    0xc(%ebp),%eax
  80151b:	50                   	push   %eax
  80151c:	57                   	push   %edi
  80151d:	e8 4a ff ff ff       	call   80146c <read>
		if (m < 0)
  801522:	83 c4 10             	add    $0x10,%esp
  801525:	85 c0                	test   %eax,%eax
  801527:	78 17                	js     801540 <readn+0x4d>
			return m;
		if (m == 0)
  801529:	85 c0                	test   %eax,%eax
  80152b:	74 11                	je     80153e <readn+0x4b>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80152d:	01 c3                	add    %eax,%ebx
  80152f:	89 d8                	mov    %ebx,%eax
  801531:	39 f3                	cmp    %esi,%ebx
  801533:	72 db                	jb     801510 <readn+0x1d>
  801535:	eb 09                	jmp    801540 <readn+0x4d>
  801537:	b8 00 00 00 00       	mov    $0x0,%eax
  80153c:	eb 02                	jmp    801540 <readn+0x4d>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  80153e:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  801540:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801543:	5b                   	pop    %ebx
  801544:	5e                   	pop    %esi
  801545:	5f                   	pop    %edi
  801546:	c9                   	leave  
  801547:	c3                   	ret    

00801548 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801548:	55                   	push   %ebp
  801549:	89 e5                	mov    %esp,%ebp
  80154b:	53                   	push   %ebx
  80154c:	83 ec 14             	sub    $0x14,%esp
  80154f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801552:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801555:	50                   	push   %eax
  801556:	53                   	push   %ebx
  801557:	e8 8f fc ff ff       	call   8011eb <fd_lookup>
  80155c:	83 c4 08             	add    $0x8,%esp
  80155f:	85 c0                	test   %eax,%eax
  801561:	78 62                	js     8015c5 <write+0x7d>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801563:	83 ec 08             	sub    $0x8,%esp
  801566:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801569:	50                   	push   %eax
  80156a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80156d:	ff 30                	pushl  (%eax)
  80156f:	e8 cd fc ff ff       	call   801241 <dev_lookup>
  801574:	83 c4 10             	add    $0x10,%esp
  801577:	85 c0                	test   %eax,%eax
  801579:	78 4a                	js     8015c5 <write+0x7d>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80157b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80157e:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801582:	75 21                	jne    8015a5 <write+0x5d>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801584:	a1 20 44 80 00       	mov    0x804420,%eax
  801589:	8b 40 48             	mov    0x48(%eax),%eax
  80158c:	83 ec 04             	sub    $0x4,%esp
  80158f:	53                   	push   %ebx
  801590:	50                   	push   %eax
  801591:	68 ad 29 80 00       	push   $0x8029ad
  801596:	e8 65 ed ff ff       	call   800300 <cprintf>
		return -E_INVAL;
  80159b:	83 c4 10             	add    $0x10,%esp
  80159e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8015a3:	eb 20                	jmp    8015c5 <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8015a5:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8015a8:	8b 52 0c             	mov    0xc(%edx),%edx
  8015ab:	85 d2                	test   %edx,%edx
  8015ad:	74 11                	je     8015c0 <write+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8015af:	83 ec 04             	sub    $0x4,%esp
  8015b2:	ff 75 10             	pushl  0x10(%ebp)
  8015b5:	ff 75 0c             	pushl  0xc(%ebp)
  8015b8:	50                   	push   %eax
  8015b9:	ff d2                	call   *%edx
  8015bb:	83 c4 10             	add    $0x10,%esp
  8015be:	eb 05                	jmp    8015c5 <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8015c0:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  8015c5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015c8:	c9                   	leave  
  8015c9:	c3                   	ret    

008015ca <seek>:

int
seek(int fdnum, off_t offset)
{
  8015ca:	55                   	push   %ebp
  8015cb:	89 e5                	mov    %esp,%ebp
  8015cd:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8015d0:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8015d3:	50                   	push   %eax
  8015d4:	ff 75 08             	pushl  0x8(%ebp)
  8015d7:	e8 0f fc ff ff       	call   8011eb <fd_lookup>
  8015dc:	83 c4 08             	add    $0x8,%esp
  8015df:	85 c0                	test   %eax,%eax
  8015e1:	78 0e                	js     8015f1 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8015e3:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8015e6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8015e9:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8015ec:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8015f1:	c9                   	leave  
  8015f2:	c3                   	ret    

008015f3 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8015f3:	55                   	push   %ebp
  8015f4:	89 e5                	mov    %esp,%ebp
  8015f6:	53                   	push   %ebx
  8015f7:	83 ec 14             	sub    $0x14,%esp
  8015fa:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015fd:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801600:	50                   	push   %eax
  801601:	53                   	push   %ebx
  801602:	e8 e4 fb ff ff       	call   8011eb <fd_lookup>
  801607:	83 c4 08             	add    $0x8,%esp
  80160a:	85 c0                	test   %eax,%eax
  80160c:	78 5f                	js     80166d <ftruncate+0x7a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80160e:	83 ec 08             	sub    $0x8,%esp
  801611:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801614:	50                   	push   %eax
  801615:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801618:	ff 30                	pushl  (%eax)
  80161a:	e8 22 fc ff ff       	call   801241 <dev_lookup>
  80161f:	83 c4 10             	add    $0x10,%esp
  801622:	85 c0                	test   %eax,%eax
  801624:	78 47                	js     80166d <ftruncate+0x7a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801626:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801629:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80162d:	75 21                	jne    801650 <ftruncate+0x5d>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80162f:	a1 20 44 80 00       	mov    0x804420,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801634:	8b 40 48             	mov    0x48(%eax),%eax
  801637:	83 ec 04             	sub    $0x4,%esp
  80163a:	53                   	push   %ebx
  80163b:	50                   	push   %eax
  80163c:	68 70 29 80 00       	push   $0x802970
  801641:	e8 ba ec ff ff       	call   800300 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801646:	83 c4 10             	add    $0x10,%esp
  801649:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80164e:	eb 1d                	jmp    80166d <ftruncate+0x7a>
	}
	if (!dev->dev_trunc)
  801650:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801653:	8b 52 18             	mov    0x18(%edx),%edx
  801656:	85 d2                	test   %edx,%edx
  801658:	74 0e                	je     801668 <ftruncate+0x75>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80165a:	83 ec 08             	sub    $0x8,%esp
  80165d:	ff 75 0c             	pushl  0xc(%ebp)
  801660:	50                   	push   %eax
  801661:	ff d2                	call   *%edx
  801663:	83 c4 10             	add    $0x10,%esp
  801666:	eb 05                	jmp    80166d <ftruncate+0x7a>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801668:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  80166d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801670:	c9                   	leave  
  801671:	c3                   	ret    

00801672 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801672:	55                   	push   %ebp
  801673:	89 e5                	mov    %esp,%ebp
  801675:	53                   	push   %ebx
  801676:	83 ec 14             	sub    $0x14,%esp
  801679:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80167c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80167f:	50                   	push   %eax
  801680:	ff 75 08             	pushl  0x8(%ebp)
  801683:	e8 63 fb ff ff       	call   8011eb <fd_lookup>
  801688:	83 c4 08             	add    $0x8,%esp
  80168b:	85 c0                	test   %eax,%eax
  80168d:	78 52                	js     8016e1 <fstat+0x6f>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80168f:	83 ec 08             	sub    $0x8,%esp
  801692:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801695:	50                   	push   %eax
  801696:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801699:	ff 30                	pushl  (%eax)
  80169b:	e8 a1 fb ff ff       	call   801241 <dev_lookup>
  8016a0:	83 c4 10             	add    $0x10,%esp
  8016a3:	85 c0                	test   %eax,%eax
  8016a5:	78 3a                	js     8016e1 <fstat+0x6f>
		return r;
	if (!dev->dev_stat)
  8016a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016aa:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8016ae:	74 2c                	je     8016dc <fstat+0x6a>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8016b0:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8016b3:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8016ba:	00 00 00 
	stat->st_isdir = 0;
  8016bd:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8016c4:	00 00 00 
	stat->st_dev = dev;
  8016c7:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8016cd:	83 ec 08             	sub    $0x8,%esp
  8016d0:	53                   	push   %ebx
  8016d1:	ff 75 f0             	pushl  -0x10(%ebp)
  8016d4:	ff 50 14             	call   *0x14(%eax)
  8016d7:	83 c4 10             	add    $0x10,%esp
  8016da:	eb 05                	jmp    8016e1 <fstat+0x6f>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8016dc:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8016e1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016e4:	c9                   	leave  
  8016e5:	c3                   	ret    

008016e6 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8016e6:	55                   	push   %ebp
  8016e7:	89 e5                	mov    %esp,%ebp
  8016e9:	56                   	push   %esi
  8016ea:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8016eb:	83 ec 08             	sub    $0x8,%esp
  8016ee:	6a 00                	push   $0x0
  8016f0:	ff 75 08             	pushl  0x8(%ebp)
  8016f3:	e8 8b 01 00 00       	call   801883 <open>
  8016f8:	89 c3                	mov    %eax,%ebx
  8016fa:	83 c4 10             	add    $0x10,%esp
  8016fd:	85 c0                	test   %eax,%eax
  8016ff:	78 1b                	js     80171c <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801701:	83 ec 08             	sub    $0x8,%esp
  801704:	ff 75 0c             	pushl  0xc(%ebp)
  801707:	50                   	push   %eax
  801708:	e8 65 ff ff ff       	call   801672 <fstat>
  80170d:	89 c6                	mov    %eax,%esi
	close(fd);
  80170f:	89 1c 24             	mov    %ebx,(%esp)
  801712:	e8 18 fc ff ff       	call   80132f <close>
	return r;
  801717:	83 c4 10             	add    $0x10,%esp
  80171a:	89 f3                	mov    %esi,%ebx
}
  80171c:	89 d8                	mov    %ebx,%eax
  80171e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801721:	5b                   	pop    %ebx
  801722:	5e                   	pop    %esi
  801723:	c9                   	leave  
  801724:	c3                   	ret    
  801725:	00 00                	add    %al,(%eax)
	...

00801728 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801728:	55                   	push   %ebp
  801729:	89 e5                	mov    %esp,%ebp
  80172b:	56                   	push   %esi
  80172c:	53                   	push   %ebx
  80172d:	89 c3                	mov    %eax,%ebx
  80172f:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  801731:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801738:	75 12                	jne    80174c <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80173a:	83 ec 0c             	sub    $0xc,%esp
  80173d:	6a 01                	push   $0x1
  80173f:	e8 f9 08 00 00       	call   80203d <ipc_find_env>
  801744:	a3 00 40 80 00       	mov    %eax,0x804000
  801749:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80174c:	6a 07                	push   $0x7
  80174e:	68 00 50 80 00       	push   $0x805000
  801753:	53                   	push   %ebx
  801754:	ff 35 00 40 80 00    	pushl  0x804000
  80175a:	e8 89 08 00 00       	call   801fe8 <ipc_send>
	
	return ipc_recv(NULL, dstva, NULL);
  80175f:	83 c4 0c             	add    $0xc,%esp
  801762:	6a 00                	push   $0x0
  801764:	56                   	push   %esi
  801765:	6a 00                	push   $0x0
  801767:	e8 d4 07 00 00       	call   801f40 <ipc_recv>
}
  80176c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80176f:	5b                   	pop    %ebx
  801770:	5e                   	pop    %esi
  801771:	c9                   	leave  
  801772:	c3                   	ret    

00801773 <devfile_stat>:
}


static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801773:	55                   	push   %ebp
  801774:	89 e5                	mov    %esp,%ebp
  801776:	53                   	push   %ebx
  801777:	83 ec 04             	sub    $0x4,%esp
  80177a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80177d:	8b 45 08             	mov    0x8(%ebp),%eax
  801780:	8b 40 0c             	mov    0xc(%eax),%eax
  801783:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0) {
  801788:	ba 00 00 00 00       	mov    $0x0,%edx
  80178d:	b8 05 00 00 00       	mov    $0x5,%eax
  801792:	e8 91 ff ff ff       	call   801728 <fsipc>
  801797:	85 c0                	test   %eax,%eax
  801799:	78 39                	js     8017d4 <devfile_stat+0x61>
		return r;
	}
	cprintf("OVER\n");
  80179b:	83 ec 0c             	sub    $0xc,%esp
  80179e:	68 dc 29 80 00       	push   $0x8029dc
  8017a3:	e8 58 eb ff ff       	call   800300 <cprintf>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8017a8:	83 c4 08             	add    $0x8,%esp
  8017ab:	68 00 50 80 00       	push   $0x805000
  8017b0:	53                   	push   %ebx
  8017b1:	e8 00 f1 ff ff       	call   8008b6 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8017b6:	a1 80 50 80 00       	mov    0x805080,%eax
  8017bb:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8017c1:	a1 84 50 80 00       	mov    0x805084,%eax
  8017c6:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8017cc:	83 c4 10             	add    $0x10,%esp
  8017cf:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8017d4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017d7:	c9                   	leave  
  8017d8:	c3                   	ret    

008017d9 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8017d9:	55                   	push   %ebp
  8017da:	89 e5                	mov    %esp,%ebp
  8017dc:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8017df:	8b 45 08             	mov    0x8(%ebp),%eax
  8017e2:	8b 40 0c             	mov    0xc(%eax),%eax
  8017e5:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8017ea:	ba 00 00 00 00       	mov    $0x0,%edx
  8017ef:	b8 06 00 00 00       	mov    $0x6,%eax
  8017f4:	e8 2f ff ff ff       	call   801728 <fsipc>
}
  8017f9:	c9                   	leave  
  8017fa:	c3                   	ret    

008017fb <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8017fb:	55                   	push   %ebp
  8017fc:	89 e5                	mov    %esp,%ebp
  8017fe:	56                   	push   %esi
  8017ff:	53                   	push   %ebx
  801800:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801803:	8b 45 08             	mov    0x8(%ebp),%eax
  801806:	8b 40 0c             	mov    0xc(%eax),%eax
  801809:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  80180e:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801814:	ba 00 00 00 00       	mov    $0x0,%edx
  801819:	b8 03 00 00 00       	mov    $0x3,%eax
  80181e:	e8 05 ff ff ff       	call   801728 <fsipc>
  801823:	89 c3                	mov    %eax,%ebx
  801825:	85 c0                	test   %eax,%eax
  801827:	78 51                	js     80187a <devfile_read+0x7f>
		return r;
	assert(r <= n);
  801829:	39 c6                	cmp    %eax,%esi
  80182b:	73 19                	jae    801846 <devfile_read+0x4b>
  80182d:	68 e2 29 80 00       	push   $0x8029e2
  801832:	68 e9 29 80 00       	push   $0x8029e9
  801837:	68 80 00 00 00       	push   $0x80
  80183c:	68 fe 29 80 00       	push   $0x8029fe
  801841:	e8 e2 e9 ff ff       	call   800228 <_panic>
	assert(r <= PGSIZE);
  801846:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80184b:	7e 19                	jle    801866 <devfile_read+0x6b>
  80184d:	68 09 2a 80 00       	push   $0x802a09
  801852:	68 e9 29 80 00       	push   $0x8029e9
  801857:	68 81 00 00 00       	push   $0x81
  80185c:	68 fe 29 80 00       	push   $0x8029fe
  801861:	e8 c2 e9 ff ff       	call   800228 <_panic>
	memmove(buf, &fsipcbuf, r);
  801866:	83 ec 04             	sub    $0x4,%esp
  801869:	50                   	push   %eax
  80186a:	68 00 50 80 00       	push   $0x805000
  80186f:	ff 75 0c             	pushl  0xc(%ebp)
  801872:	e8 00 f2 ff ff       	call   800a77 <memmove>
	return r;
  801877:	83 c4 10             	add    $0x10,%esp
}
  80187a:	89 d8                	mov    %ebx,%eax
  80187c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80187f:	5b                   	pop    %ebx
  801880:	5e                   	pop    %esi
  801881:	c9                   	leave  
  801882:	c3                   	ret    

00801883 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801883:	55                   	push   %ebp
  801884:	89 e5                	mov    %esp,%ebp
  801886:	56                   	push   %esi
  801887:	53                   	push   %ebx
  801888:	83 ec 1c             	sub    $0x1c,%esp
  80188b:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  80188e:	56                   	push   %esi
  80188f:	e8 d0 ef ff ff       	call   800864 <strlen>
  801894:	83 c4 10             	add    $0x10,%esp
  801897:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  80189c:	7f 72                	jg     801910 <open+0x8d>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80189e:	83 ec 0c             	sub    $0xc,%esp
  8018a1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018a4:	50                   	push   %eax
  8018a5:	e8 ce f8 ff ff       	call   801178 <fd_alloc>
  8018aa:	89 c3                	mov    %eax,%ebx
  8018ac:	83 c4 10             	add    $0x10,%esp
  8018af:	85 c0                	test   %eax,%eax
  8018b1:	78 62                	js     801915 <open+0x92>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8018b3:	83 ec 08             	sub    $0x8,%esp
  8018b6:	56                   	push   %esi
  8018b7:	68 00 50 80 00       	push   $0x805000
  8018bc:	e8 f5 ef ff ff       	call   8008b6 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8018c1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018c4:	a3 00 54 80 00       	mov    %eax,0x805400



	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8018c9:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8018cc:	b8 01 00 00 00       	mov    $0x1,%eax
  8018d1:	e8 52 fe ff ff       	call   801728 <fsipc>
  8018d6:	89 c3                	mov    %eax,%ebx
  8018d8:	83 c4 10             	add    $0x10,%esp
  8018db:	85 c0                	test   %eax,%eax
  8018dd:	79 12                	jns    8018f1 <open+0x6e>
		fd_close(fd, 0);
  8018df:	83 ec 08             	sub    $0x8,%esp
  8018e2:	6a 00                	push   $0x0
  8018e4:	ff 75 f4             	pushl  -0xc(%ebp)
  8018e7:	e8 bb f9 ff ff       	call   8012a7 <fd_close>
		return r;
  8018ec:	83 c4 10             	add    $0x10,%esp
  8018ef:	eb 24                	jmp    801915 <open+0x92>
	}


	cprintf("OPEN\n");
  8018f1:	83 ec 0c             	sub    $0xc,%esp
  8018f4:	68 15 2a 80 00       	push   $0x802a15
  8018f9:	e8 02 ea ff ff       	call   800300 <cprintf>

	return fd2num(fd);
  8018fe:	83 c4 04             	add    $0x4,%esp
  801901:	ff 75 f4             	pushl  -0xc(%ebp)
  801904:	e8 47 f8 ff ff       	call   801150 <fd2num>
  801909:	89 c3                	mov    %eax,%ebx
  80190b:	83 c4 10             	add    $0x10,%esp
  80190e:	eb 05                	jmp    801915 <open+0x92>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801910:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx


	cprintf("OPEN\n");

	return fd2num(fd);
}
  801915:	89 d8                	mov    %ebx,%eax
  801917:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80191a:	5b                   	pop    %ebx
  80191b:	5e                   	pop    %esi
  80191c:	c9                   	leave  
  80191d:	c3                   	ret    
	...

00801920 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801920:	55                   	push   %ebp
  801921:	89 e5                	mov    %esp,%ebp
  801923:	56                   	push   %esi
  801924:	53                   	push   %ebx
  801925:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801928:	83 ec 0c             	sub    $0xc,%esp
  80192b:	ff 75 08             	pushl  0x8(%ebp)
  80192e:	e8 2d f8 ff ff       	call   801160 <fd2data>
  801933:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  801935:	83 c4 08             	add    $0x8,%esp
  801938:	68 1b 2a 80 00       	push   $0x802a1b
  80193d:	56                   	push   %esi
  80193e:	e8 73 ef ff ff       	call   8008b6 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801943:	8b 43 04             	mov    0x4(%ebx),%eax
  801946:	2b 03                	sub    (%ebx),%eax
  801948:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  80194e:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  801955:	00 00 00 
	stat->st_dev = &devpipe;
  801958:	c7 86 88 00 00 00 20 	movl   $0x803020,0x88(%esi)
  80195f:	30 80 00 
	return 0;
}
  801962:	b8 00 00 00 00       	mov    $0x0,%eax
  801967:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80196a:	5b                   	pop    %ebx
  80196b:	5e                   	pop    %esi
  80196c:	c9                   	leave  
  80196d:	c3                   	ret    

0080196e <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  80196e:	55                   	push   %ebp
  80196f:	89 e5                	mov    %esp,%ebp
  801971:	53                   	push   %ebx
  801972:	83 ec 0c             	sub    $0xc,%esp
  801975:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801978:	53                   	push   %ebx
  801979:	6a 00                	push   $0x0
  80197b:	e8 02 f4 ff ff       	call   800d82 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801980:	89 1c 24             	mov    %ebx,(%esp)
  801983:	e8 d8 f7 ff ff       	call   801160 <fd2data>
  801988:	83 c4 08             	add    $0x8,%esp
  80198b:	50                   	push   %eax
  80198c:	6a 00                	push   $0x0
  80198e:	e8 ef f3 ff ff       	call   800d82 <sys_page_unmap>
}
  801993:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801996:	c9                   	leave  
  801997:	c3                   	ret    

00801998 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801998:	55                   	push   %ebp
  801999:	89 e5                	mov    %esp,%ebp
  80199b:	57                   	push   %edi
  80199c:	56                   	push   %esi
  80199d:	53                   	push   %ebx
  80199e:	83 ec 1c             	sub    $0x1c,%esp
  8019a1:	89 c7                	mov    %eax,%edi
  8019a3:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8019a6:	a1 20 44 80 00       	mov    0x804420,%eax
  8019ab:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  8019ae:	83 ec 0c             	sub    $0xc,%esp
  8019b1:	57                   	push   %edi
  8019b2:	e8 e1 06 00 00       	call   802098 <pageref>
  8019b7:	89 c6                	mov    %eax,%esi
  8019b9:	83 c4 04             	add    $0x4,%esp
  8019bc:	ff 75 e4             	pushl  -0x1c(%ebp)
  8019bf:	e8 d4 06 00 00       	call   802098 <pageref>
  8019c4:	83 c4 10             	add    $0x10,%esp
  8019c7:	39 c6                	cmp    %eax,%esi
  8019c9:	0f 94 c0             	sete   %al
  8019cc:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  8019cf:	8b 15 20 44 80 00    	mov    0x804420,%edx
  8019d5:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  8019d8:	39 cb                	cmp    %ecx,%ebx
  8019da:	75 08                	jne    8019e4 <_pipeisclosed+0x4c>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  8019dc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8019df:	5b                   	pop    %ebx
  8019e0:	5e                   	pop    %esi
  8019e1:	5f                   	pop    %edi
  8019e2:	c9                   	leave  
  8019e3:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  8019e4:	83 f8 01             	cmp    $0x1,%eax
  8019e7:	75 bd                	jne    8019a6 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8019e9:	8b 42 58             	mov    0x58(%edx),%eax
  8019ec:	6a 01                	push   $0x1
  8019ee:	50                   	push   %eax
  8019ef:	53                   	push   %ebx
  8019f0:	68 22 2a 80 00       	push   $0x802a22
  8019f5:	e8 06 e9 ff ff       	call   800300 <cprintf>
  8019fa:	83 c4 10             	add    $0x10,%esp
  8019fd:	eb a7                	jmp    8019a6 <_pipeisclosed+0xe>

008019ff <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8019ff:	55                   	push   %ebp
  801a00:	89 e5                	mov    %esp,%ebp
  801a02:	57                   	push   %edi
  801a03:	56                   	push   %esi
  801a04:	53                   	push   %ebx
  801a05:	83 ec 28             	sub    $0x28,%esp
  801a08:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801a0b:	56                   	push   %esi
  801a0c:	e8 4f f7 ff ff       	call   801160 <fd2data>
  801a11:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801a13:	83 c4 10             	add    $0x10,%esp
  801a16:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801a1a:	75 4a                	jne    801a66 <devpipe_write+0x67>
  801a1c:	bf 00 00 00 00       	mov    $0x0,%edi
  801a21:	eb 56                	jmp    801a79 <devpipe_write+0x7a>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801a23:	89 da                	mov    %ebx,%edx
  801a25:	89 f0                	mov    %esi,%eax
  801a27:	e8 6c ff ff ff       	call   801998 <_pipeisclosed>
  801a2c:	85 c0                	test   %eax,%eax
  801a2e:	75 4d                	jne    801a7d <devpipe_write+0x7e>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801a30:	e8 dc f2 ff ff       	call   800d11 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801a35:	8b 43 04             	mov    0x4(%ebx),%eax
  801a38:	8b 13                	mov    (%ebx),%edx
  801a3a:	83 c2 20             	add    $0x20,%edx
  801a3d:	39 d0                	cmp    %edx,%eax
  801a3f:	73 e2                	jae    801a23 <devpipe_write+0x24>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801a41:	89 c2                	mov    %eax,%edx
  801a43:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  801a49:	79 05                	jns    801a50 <devpipe_write+0x51>
  801a4b:	4a                   	dec    %edx
  801a4c:	83 ca e0             	or     $0xffffffe0,%edx
  801a4f:	42                   	inc    %edx
  801a50:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801a53:	8a 0c 39             	mov    (%ecx,%edi,1),%cl
  801a56:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801a5a:	40                   	inc    %eax
  801a5b:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801a5e:	47                   	inc    %edi
  801a5f:	39 7d 10             	cmp    %edi,0x10(%ebp)
  801a62:	77 07                	ja     801a6b <devpipe_write+0x6c>
  801a64:	eb 13                	jmp    801a79 <devpipe_write+0x7a>
  801a66:	bf 00 00 00 00       	mov    $0x0,%edi
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801a6b:	8b 43 04             	mov    0x4(%ebx),%eax
  801a6e:	8b 13                	mov    (%ebx),%edx
  801a70:	83 c2 20             	add    $0x20,%edx
  801a73:	39 d0                	cmp    %edx,%eax
  801a75:	73 ac                	jae    801a23 <devpipe_write+0x24>
  801a77:	eb c8                	jmp    801a41 <devpipe_write+0x42>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801a79:	89 f8                	mov    %edi,%eax
  801a7b:	eb 05                	jmp    801a82 <devpipe_write+0x83>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801a7d:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801a82:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a85:	5b                   	pop    %ebx
  801a86:	5e                   	pop    %esi
  801a87:	5f                   	pop    %edi
  801a88:	c9                   	leave  
  801a89:	c3                   	ret    

00801a8a <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801a8a:	55                   	push   %ebp
  801a8b:	89 e5                	mov    %esp,%ebp
  801a8d:	57                   	push   %edi
  801a8e:	56                   	push   %esi
  801a8f:	53                   	push   %ebx
  801a90:	83 ec 18             	sub    $0x18,%esp
  801a93:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801a96:	57                   	push   %edi
  801a97:	e8 c4 f6 ff ff       	call   801160 <fd2data>
  801a9c:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801a9e:	83 c4 10             	add    $0x10,%esp
  801aa1:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801aa5:	75 44                	jne    801aeb <devpipe_read+0x61>
  801aa7:	be 00 00 00 00       	mov    $0x0,%esi
  801aac:	eb 4f                	jmp    801afd <devpipe_read+0x73>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
				return i;
  801aae:	89 f0                	mov    %esi,%eax
  801ab0:	eb 54                	jmp    801b06 <devpipe_read+0x7c>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801ab2:	89 da                	mov    %ebx,%edx
  801ab4:	89 f8                	mov    %edi,%eax
  801ab6:	e8 dd fe ff ff       	call   801998 <_pipeisclosed>
  801abb:	85 c0                	test   %eax,%eax
  801abd:	75 42                	jne    801b01 <devpipe_read+0x77>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801abf:	e8 4d f2 ff ff       	call   800d11 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801ac4:	8b 03                	mov    (%ebx),%eax
  801ac6:	3b 43 04             	cmp    0x4(%ebx),%eax
  801ac9:	74 e7                	je     801ab2 <devpipe_read+0x28>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801acb:	25 1f 00 00 80       	and    $0x8000001f,%eax
  801ad0:	79 05                	jns    801ad7 <devpipe_read+0x4d>
  801ad2:	48                   	dec    %eax
  801ad3:	83 c8 e0             	or     $0xffffffe0,%eax
  801ad6:	40                   	inc    %eax
  801ad7:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  801adb:	8b 55 0c             	mov    0xc(%ebp),%edx
  801ade:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  801ae1:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801ae3:	46                   	inc    %esi
  801ae4:	39 75 10             	cmp    %esi,0x10(%ebp)
  801ae7:	77 07                	ja     801af0 <devpipe_read+0x66>
  801ae9:	eb 12                	jmp    801afd <devpipe_read+0x73>
  801aeb:	be 00 00 00 00       	mov    $0x0,%esi
		while (p->p_rpos == p->p_wpos) {
  801af0:	8b 03                	mov    (%ebx),%eax
  801af2:	3b 43 04             	cmp    0x4(%ebx),%eax
  801af5:	75 d4                	jne    801acb <devpipe_read+0x41>
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801af7:	85 f6                	test   %esi,%esi
  801af9:	75 b3                	jne    801aae <devpipe_read+0x24>
  801afb:	eb b5                	jmp    801ab2 <devpipe_read+0x28>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801afd:	89 f0                	mov    %esi,%eax
  801aff:	eb 05                	jmp    801b06 <devpipe_read+0x7c>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801b01:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801b06:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b09:	5b                   	pop    %ebx
  801b0a:	5e                   	pop    %esi
  801b0b:	5f                   	pop    %edi
  801b0c:	c9                   	leave  
  801b0d:	c3                   	ret    

00801b0e <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801b0e:	55                   	push   %ebp
  801b0f:	89 e5                	mov    %esp,%ebp
  801b11:	57                   	push   %edi
  801b12:	56                   	push   %esi
  801b13:	53                   	push   %ebx
  801b14:	83 ec 28             	sub    $0x28,%esp
  801b17:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801b1a:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801b1d:	50                   	push   %eax
  801b1e:	e8 55 f6 ff ff       	call   801178 <fd_alloc>
  801b23:	89 c3                	mov    %eax,%ebx
  801b25:	83 c4 10             	add    $0x10,%esp
  801b28:	85 c0                	test   %eax,%eax
  801b2a:	0f 88 24 01 00 00    	js     801c54 <pipe+0x146>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b30:	83 ec 04             	sub    $0x4,%esp
  801b33:	68 07 04 00 00       	push   $0x407
  801b38:	ff 75 e4             	pushl  -0x1c(%ebp)
  801b3b:	6a 00                	push   $0x0
  801b3d:	e8 f6 f1 ff ff       	call   800d38 <sys_page_alloc>
  801b42:	89 c3                	mov    %eax,%ebx
  801b44:	83 c4 10             	add    $0x10,%esp
  801b47:	85 c0                	test   %eax,%eax
  801b49:	0f 88 05 01 00 00    	js     801c54 <pipe+0x146>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801b4f:	83 ec 0c             	sub    $0xc,%esp
  801b52:	8d 45 e0             	lea    -0x20(%ebp),%eax
  801b55:	50                   	push   %eax
  801b56:	e8 1d f6 ff ff       	call   801178 <fd_alloc>
  801b5b:	89 c3                	mov    %eax,%ebx
  801b5d:	83 c4 10             	add    $0x10,%esp
  801b60:	85 c0                	test   %eax,%eax
  801b62:	0f 88 dc 00 00 00    	js     801c44 <pipe+0x136>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b68:	83 ec 04             	sub    $0x4,%esp
  801b6b:	68 07 04 00 00       	push   $0x407
  801b70:	ff 75 e0             	pushl  -0x20(%ebp)
  801b73:	6a 00                	push   $0x0
  801b75:	e8 be f1 ff ff       	call   800d38 <sys_page_alloc>
  801b7a:	89 c3                	mov    %eax,%ebx
  801b7c:	83 c4 10             	add    $0x10,%esp
  801b7f:	85 c0                	test   %eax,%eax
  801b81:	0f 88 bd 00 00 00    	js     801c44 <pipe+0x136>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801b87:	83 ec 0c             	sub    $0xc,%esp
  801b8a:	ff 75 e4             	pushl  -0x1c(%ebp)
  801b8d:	e8 ce f5 ff ff       	call   801160 <fd2data>
  801b92:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b94:	83 c4 0c             	add    $0xc,%esp
  801b97:	68 07 04 00 00       	push   $0x407
  801b9c:	50                   	push   %eax
  801b9d:	6a 00                	push   $0x0
  801b9f:	e8 94 f1 ff ff       	call   800d38 <sys_page_alloc>
  801ba4:	89 c3                	mov    %eax,%ebx
  801ba6:	83 c4 10             	add    $0x10,%esp
  801ba9:	85 c0                	test   %eax,%eax
  801bab:	0f 88 83 00 00 00    	js     801c34 <pipe+0x126>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801bb1:	83 ec 0c             	sub    $0xc,%esp
  801bb4:	ff 75 e0             	pushl  -0x20(%ebp)
  801bb7:	e8 a4 f5 ff ff       	call   801160 <fd2data>
  801bbc:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801bc3:	50                   	push   %eax
  801bc4:	6a 00                	push   $0x0
  801bc6:	56                   	push   %esi
  801bc7:	6a 00                	push   $0x0
  801bc9:	e8 8e f1 ff ff       	call   800d5c <sys_page_map>
  801bce:	89 c3                	mov    %eax,%ebx
  801bd0:	83 c4 20             	add    $0x20,%esp
  801bd3:	85 c0                	test   %eax,%eax
  801bd5:	78 4f                	js     801c26 <pipe+0x118>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801bd7:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801bdd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801be0:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801be2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801be5:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801bec:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801bf2:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801bf5:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801bf7:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801bfa:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801c01:	83 ec 0c             	sub    $0xc,%esp
  801c04:	ff 75 e4             	pushl  -0x1c(%ebp)
  801c07:	e8 44 f5 ff ff       	call   801150 <fd2num>
  801c0c:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  801c0e:	83 c4 04             	add    $0x4,%esp
  801c11:	ff 75 e0             	pushl  -0x20(%ebp)
  801c14:	e8 37 f5 ff ff       	call   801150 <fd2num>
  801c19:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  801c1c:	83 c4 10             	add    $0x10,%esp
  801c1f:	bb 00 00 00 00       	mov    $0x0,%ebx
  801c24:	eb 2e                	jmp    801c54 <pipe+0x146>

    err3:
	sys_page_unmap(0, va);
  801c26:	83 ec 08             	sub    $0x8,%esp
  801c29:	56                   	push   %esi
  801c2a:	6a 00                	push   $0x0
  801c2c:	e8 51 f1 ff ff       	call   800d82 <sys_page_unmap>
  801c31:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801c34:	83 ec 08             	sub    $0x8,%esp
  801c37:	ff 75 e0             	pushl  -0x20(%ebp)
  801c3a:	6a 00                	push   $0x0
  801c3c:	e8 41 f1 ff ff       	call   800d82 <sys_page_unmap>
  801c41:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801c44:	83 ec 08             	sub    $0x8,%esp
  801c47:	ff 75 e4             	pushl  -0x1c(%ebp)
  801c4a:	6a 00                	push   $0x0
  801c4c:	e8 31 f1 ff ff       	call   800d82 <sys_page_unmap>
  801c51:	83 c4 10             	add    $0x10,%esp
    err:
	return r;
}
  801c54:	89 d8                	mov    %ebx,%eax
  801c56:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c59:	5b                   	pop    %ebx
  801c5a:	5e                   	pop    %esi
  801c5b:	5f                   	pop    %edi
  801c5c:	c9                   	leave  
  801c5d:	c3                   	ret    

00801c5e <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801c5e:	55                   	push   %ebp
  801c5f:	89 e5                	mov    %esp,%ebp
  801c61:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801c64:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c67:	50                   	push   %eax
  801c68:	ff 75 08             	pushl  0x8(%ebp)
  801c6b:	e8 7b f5 ff ff       	call   8011eb <fd_lookup>
  801c70:	83 c4 10             	add    $0x10,%esp
  801c73:	85 c0                	test   %eax,%eax
  801c75:	78 18                	js     801c8f <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801c77:	83 ec 0c             	sub    $0xc,%esp
  801c7a:	ff 75 f4             	pushl  -0xc(%ebp)
  801c7d:	e8 de f4 ff ff       	call   801160 <fd2data>
	return _pipeisclosed(fd, p);
  801c82:	89 c2                	mov    %eax,%edx
  801c84:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c87:	e8 0c fd ff ff       	call   801998 <_pipeisclosed>
  801c8c:	83 c4 10             	add    $0x10,%esp
}
  801c8f:	c9                   	leave  
  801c90:	c3                   	ret    
  801c91:	00 00                	add    %al,(%eax)
	...

00801c94 <wait>:
#include <inc/lib.h>

// Waits until 'envid' exits.
void
wait(envid_t envid)
{
  801c94:	55                   	push   %ebp
  801c95:	89 e5                	mov    %esp,%ebp
  801c97:	57                   	push   %edi
  801c98:	56                   	push   %esi
  801c99:	53                   	push   %ebx
  801c9a:	83 ec 0c             	sub    $0xc,%esp
  801c9d:	8b 45 08             	mov    0x8(%ebp),%eax
	const volatile struct Env *e;

	assert(envid != 0);
  801ca0:	85 c0                	test   %eax,%eax
  801ca2:	75 16                	jne    801cba <wait+0x26>
  801ca4:	68 3a 2a 80 00       	push   $0x802a3a
  801ca9:	68 e9 29 80 00       	push   $0x8029e9
  801cae:	6a 09                	push   $0x9
  801cb0:	68 45 2a 80 00       	push   $0x802a45
  801cb5:	e8 6e e5 ff ff       	call   800228 <_panic>
	e = &envs[ENVX(envid)];
  801cba:	89 c6                	mov    %eax,%esi
  801cbc:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
	while (e->env_id == envid && e->env_status != ENV_FREE)
  801cc2:	8d 0c b5 00 00 00 00 	lea    0x0(,%esi,4),%ecx
  801cc9:	89 f2                	mov    %esi,%edx
  801ccb:	c1 e2 07             	shl    $0x7,%edx
  801cce:	29 ca                	sub    %ecx,%edx
  801cd0:	81 c2 08 00 c0 ee    	add    $0xeec00008,%edx
  801cd6:	8b 7a 40             	mov    0x40(%edx),%edi
  801cd9:	39 c7                	cmp    %eax,%edi
  801cdb:	75 37                	jne    801d14 <wait+0x80>
  801cdd:	89 f0                	mov    %esi,%eax
  801cdf:	c1 e0 07             	shl    $0x7,%eax
  801ce2:	29 c8                	sub    %ecx,%eax
  801ce4:	05 04 00 c0 ee       	add    $0xeec00004,%eax
  801ce9:	8b 40 50             	mov    0x50(%eax),%eax
  801cec:	85 c0                	test   %eax,%eax
  801cee:	74 24                	je     801d14 <wait+0x80>
  801cf0:	c1 e6 07             	shl    $0x7,%esi
  801cf3:	29 ce                	sub    %ecx,%esi
  801cf5:	8d 9e 08 00 c0 ee    	lea    -0x113ffff8(%esi),%ebx
  801cfb:	81 c6 04 00 c0 ee    	add    $0xeec00004,%esi
		sys_yield();
  801d01:	e8 0b f0 ff ff       	call   800d11 <sys_yield>
{
	const volatile struct Env *e;

	assert(envid != 0);
	e = &envs[ENVX(envid)];
	while (e->env_id == envid && e->env_status != ENV_FREE)
  801d06:	8b 43 40             	mov    0x40(%ebx),%eax
  801d09:	39 f8                	cmp    %edi,%eax
  801d0b:	75 07                	jne    801d14 <wait+0x80>
  801d0d:	8b 46 50             	mov    0x50(%esi),%eax
  801d10:	85 c0                	test   %eax,%eax
  801d12:	75 ed                	jne    801d01 <wait+0x6d>
		sys_yield();
}
  801d14:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d17:	5b                   	pop    %ebx
  801d18:	5e                   	pop    %esi
  801d19:	5f                   	pop    %edi
  801d1a:	c9                   	leave  
  801d1b:	c3                   	ret    

00801d1c <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801d1c:	55                   	push   %ebp
  801d1d:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801d1f:	b8 00 00 00 00       	mov    $0x0,%eax
  801d24:	c9                   	leave  
  801d25:	c3                   	ret    

00801d26 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801d26:	55                   	push   %ebp
  801d27:	89 e5                	mov    %esp,%ebp
  801d29:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801d2c:	68 50 2a 80 00       	push   $0x802a50
  801d31:	ff 75 0c             	pushl  0xc(%ebp)
  801d34:	e8 7d eb ff ff       	call   8008b6 <strcpy>
	return 0;
}
  801d39:	b8 00 00 00 00       	mov    $0x0,%eax
  801d3e:	c9                   	leave  
  801d3f:	c3                   	ret    

00801d40 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801d40:	55                   	push   %ebp
  801d41:	89 e5                	mov    %esp,%ebp
  801d43:	57                   	push   %edi
  801d44:	56                   	push   %esi
  801d45:	53                   	push   %ebx
  801d46:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801d4c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801d50:	74 45                	je     801d97 <devcons_write+0x57>
  801d52:	b8 00 00 00 00       	mov    $0x0,%eax
  801d57:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801d5c:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801d62:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801d65:	29 c3                	sub    %eax,%ebx
		if (m > sizeof(buf) - 1)
  801d67:	83 fb 7f             	cmp    $0x7f,%ebx
  801d6a:	76 05                	jbe    801d71 <devcons_write+0x31>
			m = sizeof(buf) - 1;
  801d6c:	bb 7f 00 00 00       	mov    $0x7f,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  801d71:	83 ec 04             	sub    $0x4,%esp
  801d74:	53                   	push   %ebx
  801d75:	03 45 0c             	add    0xc(%ebp),%eax
  801d78:	50                   	push   %eax
  801d79:	57                   	push   %edi
  801d7a:	e8 f8 ec ff ff       	call   800a77 <memmove>
		sys_cputs(buf, m);
  801d7f:	83 c4 08             	add    $0x8,%esp
  801d82:	53                   	push   %ebx
  801d83:	57                   	push   %edi
  801d84:	e8 f8 ee ff ff       	call   800c81 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801d89:	01 de                	add    %ebx,%esi
  801d8b:	89 f0                	mov    %esi,%eax
  801d8d:	83 c4 10             	add    $0x10,%esp
  801d90:	3b 75 10             	cmp    0x10(%ebp),%esi
  801d93:	72 cd                	jb     801d62 <devcons_write+0x22>
  801d95:	eb 05                	jmp    801d9c <devcons_write+0x5c>
  801d97:	be 00 00 00 00       	mov    $0x0,%esi
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801d9c:	89 f0                	mov    %esi,%eax
  801d9e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801da1:	5b                   	pop    %ebx
  801da2:	5e                   	pop    %esi
  801da3:	5f                   	pop    %edi
  801da4:	c9                   	leave  
  801da5:	c3                   	ret    

00801da6 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801da6:	55                   	push   %ebp
  801da7:	89 e5                	mov    %esp,%ebp
  801da9:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  801dac:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801db0:	75 07                	jne    801db9 <devcons_read+0x13>
  801db2:	eb 25                	jmp    801dd9 <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801db4:	e8 58 ef ff ff       	call   800d11 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801db9:	e8 e9 ee ff ff       	call   800ca7 <sys_cgetc>
  801dbe:	85 c0                	test   %eax,%eax
  801dc0:	74 f2                	je     801db4 <devcons_read+0xe>
  801dc2:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  801dc4:	85 c0                	test   %eax,%eax
  801dc6:	78 1d                	js     801de5 <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801dc8:	83 f8 04             	cmp    $0x4,%eax
  801dcb:	74 13                	je     801de0 <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  801dcd:	8b 45 0c             	mov    0xc(%ebp),%eax
  801dd0:	88 10                	mov    %dl,(%eax)
	return 1;
  801dd2:	b8 01 00 00 00       	mov    $0x1,%eax
  801dd7:	eb 0c                	jmp    801de5 <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  801dd9:	b8 00 00 00 00       	mov    $0x0,%eax
  801dde:	eb 05                	jmp    801de5 <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801de0:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801de5:	c9                   	leave  
  801de6:	c3                   	ret    

00801de7 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801de7:	55                   	push   %ebp
  801de8:	89 e5                	mov    %esp,%ebp
  801dea:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801ded:	8b 45 08             	mov    0x8(%ebp),%eax
  801df0:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801df3:	6a 01                	push   $0x1
  801df5:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801df8:	50                   	push   %eax
  801df9:	e8 83 ee ff ff       	call   800c81 <sys_cputs>
  801dfe:	83 c4 10             	add    $0x10,%esp
}
  801e01:	c9                   	leave  
  801e02:	c3                   	ret    

00801e03 <getchar>:

int
getchar(void)
{
  801e03:	55                   	push   %ebp
  801e04:	89 e5                	mov    %esp,%ebp
  801e06:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801e09:	6a 01                	push   $0x1
  801e0b:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801e0e:	50                   	push   %eax
  801e0f:	6a 00                	push   $0x0
  801e11:	e8 56 f6 ff ff       	call   80146c <read>
	if (r < 0)
  801e16:	83 c4 10             	add    $0x10,%esp
  801e19:	85 c0                	test   %eax,%eax
  801e1b:	78 0f                	js     801e2c <getchar+0x29>
		return r;
	if (r < 1)
  801e1d:	85 c0                	test   %eax,%eax
  801e1f:	7e 06                	jle    801e27 <getchar+0x24>
		return -E_EOF;
	return c;
  801e21:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801e25:	eb 05                	jmp    801e2c <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801e27:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801e2c:	c9                   	leave  
  801e2d:	c3                   	ret    

00801e2e <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801e2e:	55                   	push   %ebp
  801e2f:	89 e5                	mov    %esp,%ebp
  801e31:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801e34:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e37:	50                   	push   %eax
  801e38:	ff 75 08             	pushl  0x8(%ebp)
  801e3b:	e8 ab f3 ff ff       	call   8011eb <fd_lookup>
  801e40:	83 c4 10             	add    $0x10,%esp
  801e43:	85 c0                	test   %eax,%eax
  801e45:	78 11                	js     801e58 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801e47:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e4a:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801e50:	39 10                	cmp    %edx,(%eax)
  801e52:	0f 94 c0             	sete   %al
  801e55:	0f b6 c0             	movzbl %al,%eax
}
  801e58:	c9                   	leave  
  801e59:	c3                   	ret    

00801e5a <opencons>:

int
opencons(void)
{
  801e5a:	55                   	push   %ebp
  801e5b:	89 e5                	mov    %esp,%ebp
  801e5d:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801e60:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e63:	50                   	push   %eax
  801e64:	e8 0f f3 ff ff       	call   801178 <fd_alloc>
  801e69:	83 c4 10             	add    $0x10,%esp
  801e6c:	85 c0                	test   %eax,%eax
  801e6e:	78 3a                	js     801eaa <opencons+0x50>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801e70:	83 ec 04             	sub    $0x4,%esp
  801e73:	68 07 04 00 00       	push   $0x407
  801e78:	ff 75 f4             	pushl  -0xc(%ebp)
  801e7b:	6a 00                	push   $0x0
  801e7d:	e8 b6 ee ff ff       	call   800d38 <sys_page_alloc>
  801e82:	83 c4 10             	add    $0x10,%esp
  801e85:	85 c0                	test   %eax,%eax
  801e87:	78 21                	js     801eaa <opencons+0x50>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801e89:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801e8f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e92:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801e94:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e97:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801e9e:	83 ec 0c             	sub    $0xc,%esp
  801ea1:	50                   	push   %eax
  801ea2:	e8 a9 f2 ff ff       	call   801150 <fd2num>
  801ea7:	83 c4 10             	add    $0x10,%esp
}
  801eaa:	c9                   	leave  
  801eab:	c3                   	ret    

00801eac <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801eac:	55                   	push   %ebp
  801ead:	89 e5                	mov    %esp,%ebp
  801eaf:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  801eb2:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801eb9:	75 52                	jne    801f0d <set_pgfault_handler+0x61>
		// First time through!	
		// LAB 4: Your code here.

		//int sys_page_alloc(envid_t envid, void *va, int perm)
		r = sys_page_alloc(0, (void*)(UXSTACKTOP - PGSIZE), PTE_U | PTE_W | PTE_P);
  801ebb:	83 ec 04             	sub    $0x4,%esp
  801ebe:	6a 07                	push   $0x7
  801ec0:	68 00 f0 bf ee       	push   $0xeebff000
  801ec5:	6a 00                	push   $0x0
  801ec7:	e8 6c ee ff ff       	call   800d38 <sys_page_alloc>
		if (r < 0) {
  801ecc:	83 c4 10             	add    $0x10,%esp
  801ecf:	85 c0                	test   %eax,%eax
  801ed1:	79 12                	jns    801ee5 <set_pgfault_handler+0x39>
			panic("sys_page_alloc error : %e\n", r);
  801ed3:	50                   	push   %eax
  801ed4:	68 5c 2a 80 00       	push   $0x802a5c
  801ed9:	6a 24                	push   $0x24
  801edb:	68 77 2a 80 00       	push   $0x802a77
  801ee0:	e8 43 e3 ff ff       	call   800228 <_panic>
		}

		// how to know envid, put 0, envid2env will help us to get curenv in syscall
		r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);		
  801ee5:	83 ec 08             	sub    $0x8,%esp
  801ee8:	68 18 1f 80 00       	push   $0x801f18
  801eed:	6a 00                	push   $0x0
  801eef:	e8 f7 ee ff ff       	call   800deb <sys_env_set_pgfault_upcall>
		if (r < 0) {
  801ef4:	83 c4 10             	add    $0x10,%esp
  801ef7:	85 c0                	test   %eax,%eax
  801ef9:	79 12                	jns    801f0d <set_pgfault_handler+0x61>
			panic("sys_env_set_pgfault_upcall error : %e\n", r);
  801efb:	50                   	push   %eax
  801efc:	68 88 2a 80 00       	push   $0x802a88
  801f01:	6a 2a                	push   $0x2a
  801f03:	68 77 2a 80 00       	push   $0x802a77
  801f08:	e8 1b e3 ff ff       	call   800228 <_panic>
		}
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801f0d:	8b 45 08             	mov    0x8(%ebp),%eax
  801f10:	a3 00 60 80 00       	mov    %eax,0x806000
}
  801f15:	c9                   	leave  
  801f16:	c3                   	ret    
	...

00801f18 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801f18:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801f19:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  801f1e:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801f20:	83 c4 04             	add    $0x4,%esp
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	
	// fix old esp
	movl 0x30(%esp), %eax
  801f23:	8b 44 24 30          	mov    0x30(%esp),%eax
	subl $0x4, %eax
  801f27:	83 e8 04             	sub    $0x4,%eax
	movl %eax, 0x30(%esp)
  801f2a:	89 44 24 30          	mov    %eax,0x30(%esp)

	// set trap-time %eip
	movl 0x28(%esp), %ebx
  801f2e:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	movl %ebx, (%eax)
  801f32:	89 18                	mov    %ebx,(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $0x08, %esp 	// ignore err_code and fault_va
  801f34:	83 c4 08             	add    $0x8,%esp
	popal 				// restore registers
  801f37:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x04, %esp 	// ignore eip 
  801f38:	83 c4 04             	add    $0x4,%esp
	popfl				// modify eflags
  801f3b:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  801f3c:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  801f3d:	c3                   	ret    
	...

00801f40 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801f40:	55                   	push   %ebp
  801f41:	89 e5                	mov    %esp,%ebp
  801f43:	57                   	push   %edi
  801f44:	56                   	push   %esi
  801f45:	53                   	push   %ebx
  801f46:	83 ec 0c             	sub    $0xc,%esp
  801f49:	8b 7d 08             	mov    0x8(%ebp),%edi
  801f4c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801f4f:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	cprintf("0x%x 0x%x 0x%x\n", (uint32_t)from_env_store, (uint32_t)pg, (uint32_t)perm_store);
  801f52:	56                   	push   %esi
  801f53:	53                   	push   %ebx
  801f54:	57                   	push   %edi
  801f55:	68 b0 2a 80 00       	push   $0x802ab0
  801f5a:	e8 a1 e3 ff ff       	call   800300 <cprintf>
	int r;
	if (pg != NULL) {
  801f5f:	83 c4 10             	add    $0x10,%esp
  801f62:	85 db                	test   %ebx,%ebx
  801f64:	74 28                	je     801f8e <ipc_recv+0x4e>
		cprintf("BEGIN\n");
  801f66:	83 ec 0c             	sub    $0xc,%esp
  801f69:	68 c0 2a 80 00       	push   $0x802ac0
  801f6e:	e8 8d e3 ff ff       	call   800300 <cprintf>
		r = sys_ipc_recv(pg);
  801f73:	89 1c 24             	mov    %ebx,(%esp)
  801f76:	e8 b8 ee ff ff       	call   800e33 <sys_ipc_recv>
  801f7b:	89 c3                	mov    %eax,%ebx
		cprintf("OVER\n");
  801f7d:	c7 04 24 dc 29 80 00 	movl   $0x8029dc,(%esp)
  801f84:	e8 77 e3 ff ff       	call   800300 <cprintf>
  801f89:	83 c4 10             	add    $0x10,%esp
  801f8c:	eb 12                	jmp    801fa0 <ipc_recv+0x60>
	} else {
		r = sys_ipc_recv((void *)UTOP);
  801f8e:	83 ec 0c             	sub    $0xc,%esp
  801f91:	68 00 00 c0 ee       	push   $0xeec00000
  801f96:	e8 98 ee ff ff       	call   800e33 <sys_ipc_recv>
  801f9b:	89 c3                	mov    %eax,%ebx
  801f9d:	83 c4 10             	add    $0x10,%esp
	}

	if (r == 0) {
  801fa0:	85 db                	test   %ebx,%ebx
  801fa2:	75 26                	jne    801fca <ipc_recv+0x8a>
		if (from_env_store != NULL) *from_env_store = thisenv->env_ipc_from;
  801fa4:	85 ff                	test   %edi,%edi
  801fa6:	74 0a                	je     801fb2 <ipc_recv+0x72>
  801fa8:	a1 20 44 80 00       	mov    0x804420,%eax
  801fad:	8b 40 74             	mov    0x74(%eax),%eax
  801fb0:	89 07                	mov    %eax,(%edi)
		if (perm_store != NULL) *perm_store = thisenv->env_ipc_perm;
  801fb2:	85 f6                	test   %esi,%esi
  801fb4:	74 0a                	je     801fc0 <ipc_recv+0x80>
  801fb6:	a1 20 44 80 00       	mov    0x804420,%eax
  801fbb:	8b 40 78             	mov    0x78(%eax),%eax
  801fbe:	89 06                	mov    %eax,(%esi)
		return thisenv->env_ipc_value;
  801fc0:	a1 20 44 80 00       	mov    0x804420,%eax
  801fc5:	8b 58 70             	mov    0x70(%eax),%ebx
  801fc8:	eb 14                	jmp    801fde <ipc_recv+0x9e>
	} else {
		// fails;
		if (from_env_store != NULL) *from_env_store = 0;
  801fca:	85 ff                	test   %edi,%edi
  801fcc:	74 06                	je     801fd4 <ipc_recv+0x94>
  801fce:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
		if (perm_store != NULL) *perm_store = 0;
  801fd4:	85 f6                	test   %esi,%esi
  801fd6:	74 06                	je     801fde <ipc_recv+0x9e>
  801fd8:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		return r;
	}
}
  801fde:	89 d8                	mov    %ebx,%eax
  801fe0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801fe3:	5b                   	pop    %ebx
  801fe4:	5e                   	pop    %esi
  801fe5:	5f                   	pop    %edi
  801fe6:	c9                   	leave  
  801fe7:	c3                   	ret    

00801fe8 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801fe8:	55                   	push   %ebp
  801fe9:	89 e5                	mov    %esp,%ebp
  801feb:	57                   	push   %edi
  801fec:	56                   	push   %esi
  801fed:	53                   	push   %ebx
  801fee:	83 ec 0c             	sub    $0xc,%esp
  801ff1:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801ff4:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801ff7:	8b 75 14             	mov    0x14(%ebp),%esi
	// LAB 4: Your code here.
	// int sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
	int r;
	if (pg == NULL) pg = (void *)UTOP;
  801ffa:	85 db                	test   %ebx,%ebx
  801ffc:	75 25                	jne    802023 <ipc_send+0x3b>
  801ffe:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
  802003:	eb 1e                	jmp    802023 <ipc_send+0x3b>
	
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) != 0) {
		if (r == -E_IPC_NOT_RECV) {
  802005:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802008:	75 07                	jne    802011 <ipc_send+0x29>
			// cprintf("Try Again and Again....\n");
			sys_yield();
  80200a:	e8 02 ed ff ff       	call   800d11 <sys_yield>
  80200f:	eb 12                	jmp    802023 <ipc_send+0x3b>
		} else {
			panic("ipc_send error %e\n", r);
  802011:	50                   	push   %eax
  802012:	68 c7 2a 80 00       	push   $0x802ac7
  802017:	6a 45                	push   $0x45
  802019:	68 da 2a 80 00       	push   $0x802ada
  80201e:	e8 05 e2 ff ff       	call   800228 <_panic>
	// LAB 4: Your code here.
	// int sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
	int r;
	if (pg == NULL) pg = (void *)UTOP;
	
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) != 0) {
  802023:	56                   	push   %esi
  802024:	53                   	push   %ebx
  802025:	57                   	push   %edi
  802026:	ff 75 08             	pushl  0x8(%ebp)
  802029:	e8 e0 ed ff ff       	call   800e0e <sys_ipc_try_send>
  80202e:	83 c4 10             	add    $0x10,%esp
  802031:	85 c0                	test   %eax,%eax
  802033:	75 d0                	jne    802005 <ipc_send+0x1d>
		} else {
			panic("ipc_send error %e\n", r);
		}
	}
	return;
}
  802035:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802038:	5b                   	pop    %ebx
  802039:	5e                   	pop    %esi
  80203a:	5f                   	pop    %edi
  80203b:	c9                   	leave  
  80203c:	c3                   	ret    

0080203d <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80203d:	55                   	push   %ebp
  80203e:	89 e5                	mov    %esp,%ebp
  802040:	53                   	push   %ebx
  802041:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  802044:	39 1d 50 00 c0 ee    	cmp    %ebx,0xeec00050
  80204a:	74 22                	je     80206e <ipc_find_env+0x31>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80204c:	b8 01 00 00 00       	mov    $0x1,%eax
		if (envs[i].env_type == type)
  802051:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  802058:	89 c2                	mov    %eax,%edx
  80205a:	c1 e2 07             	shl    $0x7,%edx
  80205d:	29 ca                	sub    %ecx,%edx
  80205f:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802065:	8b 52 50             	mov    0x50(%edx),%edx
  802068:	39 da                	cmp    %ebx,%edx
  80206a:	75 1d                	jne    802089 <ipc_find_env+0x4c>
  80206c:	eb 05                	jmp    802073 <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80206e:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
			return envs[i].env_id;
  802073:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  80207a:	c1 e0 07             	shl    $0x7,%eax
  80207d:	29 d0                	sub    %edx,%eax
  80207f:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  802084:	8b 40 40             	mov    0x40(%eax),%eax
  802087:	eb 0c                	jmp    802095 <ipc_find_env+0x58>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802089:	40                   	inc    %eax
  80208a:	3d 00 04 00 00       	cmp    $0x400,%eax
  80208f:	75 c0                	jne    802051 <ipc_find_env+0x14>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802091:	66 b8 00 00          	mov    $0x0,%ax
}
  802095:	5b                   	pop    %ebx
  802096:	c9                   	leave  
  802097:	c3                   	ret    

00802098 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802098:	55                   	push   %ebp
  802099:	89 e5                	mov    %esp,%ebp
  80209b:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80209e:	89 c2                	mov    %eax,%edx
  8020a0:	c1 ea 16             	shr    $0x16,%edx
  8020a3:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8020aa:	f6 c2 01             	test   $0x1,%dl
  8020ad:	74 1e                	je     8020cd <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  8020af:	c1 e8 0c             	shr    $0xc,%eax
  8020b2:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  8020b9:	a8 01                	test   $0x1,%al
  8020bb:	74 17                	je     8020d4 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8020bd:	c1 e8 0c             	shr    $0xc,%eax
  8020c0:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  8020c7:	ef 
  8020c8:	0f b7 c0             	movzwl %ax,%eax
  8020cb:	eb 0c                	jmp    8020d9 <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  8020cd:	b8 00 00 00 00       	mov    $0x0,%eax
  8020d2:	eb 05                	jmp    8020d9 <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  8020d4:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  8020d9:	c9                   	leave  
  8020da:	c3                   	ret    
	...

008020dc <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  8020dc:	55                   	push   %ebp
  8020dd:	89 e5                	mov    %esp,%ebp
  8020df:	57                   	push   %edi
  8020e0:	56                   	push   %esi
  8020e1:	83 ec 10             	sub    $0x10,%esp
  8020e4:	8b 7d 08             	mov    0x8(%ebp),%edi
  8020e7:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  8020ea:	89 7d f0             	mov    %edi,-0x10(%ebp)
  8020ed:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  8020f0:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  8020f3:	8b 45 14             	mov    0x14(%ebp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  8020f6:	85 c0                	test   %eax,%eax
  8020f8:	75 2e                	jne    802128 <__udivdi3+0x4c>
    {
      if (d0 > n1)
  8020fa:	39 f1                	cmp    %esi,%ecx
  8020fc:	77 5a                	ja     802158 <__udivdi3+0x7c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  8020fe:	85 c9                	test   %ecx,%ecx
  802100:	75 0b                	jne    80210d <__udivdi3+0x31>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  802102:	b8 01 00 00 00       	mov    $0x1,%eax
  802107:	31 d2                	xor    %edx,%edx
  802109:	f7 f1                	div    %ecx
  80210b:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  80210d:	31 d2                	xor    %edx,%edx
  80210f:	89 f0                	mov    %esi,%eax
  802111:	f7 f1                	div    %ecx
  802113:	89 c6                	mov    %eax,%esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802115:	89 f8                	mov    %edi,%eax
  802117:	f7 f1                	div    %ecx
  802119:	89 c7                	mov    %eax,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  80211b:	89 f8                	mov    %edi,%eax
  80211d:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  80211f:	83 c4 10             	add    $0x10,%esp
  802122:	5e                   	pop    %esi
  802123:	5f                   	pop    %edi
  802124:	c9                   	leave  
  802125:	c3                   	ret    
  802126:	66 90                	xchg   %ax,%ax
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  802128:	39 f0                	cmp    %esi,%eax
  80212a:	77 1c                	ja     802148 <__udivdi3+0x6c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  80212c:	0f bd f8             	bsr    %eax,%edi
	  if (bm == 0)
  80212f:	83 f7 1f             	xor    $0x1f,%edi
  802132:	75 3c                	jne    802170 <__udivdi3+0x94>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802134:	39 f0                	cmp    %esi,%eax
  802136:	0f 82 90 00 00 00    	jb     8021cc <__udivdi3+0xf0>
  80213c:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80213f:	39 55 f4             	cmp    %edx,-0xc(%ebp)
  802142:	0f 86 84 00 00 00    	jbe    8021cc <__udivdi3+0xf0>
  802148:	31 f6                	xor    %esi,%esi
  80214a:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  80214c:	89 f8                	mov    %edi,%eax
  80214e:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802150:	83 c4 10             	add    $0x10,%esp
  802153:	5e                   	pop    %esi
  802154:	5f                   	pop    %edi
  802155:	c9                   	leave  
  802156:	c3                   	ret    
  802157:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802158:	89 f2                	mov    %esi,%edx
  80215a:	89 f8                	mov    %edi,%eax
  80215c:	f7 f1                	div    %ecx
  80215e:	89 c7                	mov    %eax,%edi
  802160:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  802162:	89 f8                	mov    %edi,%eax
  802164:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802166:	83 c4 10             	add    $0x10,%esp
  802169:	5e                   	pop    %esi
  80216a:	5f                   	pop    %edi
  80216b:	c9                   	leave  
  80216c:	c3                   	ret    
  80216d:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  802170:	89 f9                	mov    %edi,%ecx
  802172:	d3 e0                	shl    %cl,%eax
  802174:	89 45 e8             	mov    %eax,-0x18(%ebp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  802177:	b8 20 00 00 00       	mov    $0x20,%eax
  80217c:	29 f8                	sub    %edi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  80217e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802181:	88 c1                	mov    %al,%cl
  802183:	d3 ea                	shr    %cl,%edx
  802185:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  802188:	09 ca                	or     %ecx,%edx
  80218a:	89 55 ec             	mov    %edx,-0x14(%ebp)
	      d0 = d0 << bm;
  80218d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802190:	89 f9                	mov    %edi,%ecx
  802192:	d3 e2                	shl    %cl,%edx
  802194:	89 55 f4             	mov    %edx,-0xc(%ebp)
	      n2 = n1 >> b;
  802197:	89 f2                	mov    %esi,%edx
  802199:	88 c1                	mov    %al,%cl
  80219b:	d3 ea                	shr    %cl,%edx
  80219d:	89 55 e8             	mov    %edx,-0x18(%ebp)
	      n1 = (n1 << bm) | (n0 >> b);
  8021a0:	89 f2                	mov    %esi,%edx
  8021a2:	89 f9                	mov    %edi,%ecx
  8021a4:	d3 e2                	shl    %cl,%edx
  8021a6:	8b 75 f0             	mov    -0x10(%ebp),%esi
  8021a9:	88 c1                	mov    %al,%cl
  8021ab:	d3 ee                	shr    %cl,%esi
  8021ad:	09 d6                	or     %edx,%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  8021af:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  8021b2:	89 f0                	mov    %esi,%eax
  8021b4:	89 ca                	mov    %ecx,%edx
  8021b6:	f7 75 ec             	divl   -0x14(%ebp)
  8021b9:	89 d1                	mov    %edx,%ecx
  8021bb:	89 c6                	mov    %eax,%esi
	      umul_ppmm (m1, m0, q0, d0);
  8021bd:	f7 65 f4             	mull   -0xc(%ebp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8021c0:	39 d1                	cmp    %edx,%ecx
  8021c2:	72 28                	jb     8021ec <__udivdi3+0x110>
  8021c4:	74 1a                	je     8021e0 <__udivdi3+0x104>
  8021c6:	89 f7                	mov    %esi,%edi
  8021c8:	31 f6                	xor    %esi,%esi
  8021ca:	eb 80                	jmp    80214c <__udivdi3+0x70>
	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  8021cc:	31 f6                	xor    %esi,%esi
  8021ce:	bf 01 00 00 00       	mov    $0x1,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  8021d3:	89 f8                	mov    %edi,%eax
  8021d5:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  8021d7:	83 c4 10             	add    $0x10,%esp
  8021da:	5e                   	pop    %esi
  8021db:	5f                   	pop    %edi
  8021dc:	c9                   	leave  
  8021dd:	c3                   	ret    
  8021de:	66 90                	xchg   %ax,%ax

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  8021e0:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8021e3:	89 f9                	mov    %edi,%ecx
  8021e5:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8021e7:	39 c2                	cmp    %eax,%edx
  8021e9:	73 db                	jae    8021c6 <__udivdi3+0xea>
  8021eb:	90                   	nop
		{
		  q0--;
  8021ec:	8d 7e ff             	lea    -0x1(%esi),%edi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  8021ef:	31 f6                	xor    %esi,%esi
  8021f1:	e9 56 ff ff ff       	jmp    80214c <__udivdi3+0x70>
	...

008021f8 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  8021f8:	55                   	push   %ebp
  8021f9:	89 e5                	mov    %esp,%ebp
  8021fb:	57                   	push   %edi
  8021fc:	56                   	push   %esi
  8021fd:	83 ec 20             	sub    $0x20,%esp
  802200:	8b 45 08             	mov    0x8(%ebp),%eax
  802203:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  802206:	89 45 e8             	mov    %eax,-0x18(%ebp)
  802209:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  80220c:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  80220f:	8b 7d 14             	mov    0x14(%ebp),%edi
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  802212:	89 45 f0             	mov    %eax,-0x10(%ebp)
  n1 = nn.s.high;
  802215:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  802217:	85 ff                	test   %edi,%edi
  802219:	75 15                	jne    802230 <__umoddi3+0x38>
    {
      if (d0 > n1)
  80221b:	39 f1                	cmp    %esi,%ecx
  80221d:	0f 86 99 00 00 00    	jbe    8022bc <__umoddi3+0xc4>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802223:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  802225:	89 d0                	mov    %edx,%eax
  802227:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802229:	83 c4 20             	add    $0x20,%esp
  80222c:	5e                   	pop    %esi
  80222d:	5f                   	pop    %edi
  80222e:	c9                   	leave  
  80222f:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  802230:	39 f7                	cmp    %esi,%edi
  802232:	0f 87 a4 00 00 00    	ja     8022dc <__umoddi3+0xe4>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  802238:	0f bd c7             	bsr    %edi,%eax
	  if (bm == 0)
  80223b:	83 f0 1f             	xor    $0x1f,%eax
  80223e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  802241:	0f 84 a1 00 00 00    	je     8022e8 <__umoddi3+0xf0>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  802247:	89 f8                	mov    %edi,%eax
  802249:	8a 4d ec             	mov    -0x14(%ebp),%cl
  80224c:	d3 e0                	shl    %cl,%eax
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  80224e:	bf 20 00 00 00       	mov    $0x20,%edi
  802253:	2b 7d ec             	sub    -0x14(%ebp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  802256:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802259:	89 f9                	mov    %edi,%ecx
  80225b:	d3 ea                	shr    %cl,%edx
  80225d:	09 c2                	or     %eax,%edx
  80225f:	89 55 f0             	mov    %edx,-0x10(%ebp)
	      d0 = d0 << bm;
  802262:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802265:	8a 4d ec             	mov    -0x14(%ebp),%cl
  802268:	d3 e0                	shl    %cl,%eax
  80226a:	89 45 f4             	mov    %eax,-0xc(%ebp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  80226d:	89 f2                	mov    %esi,%edx
  80226f:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  802271:	8b 45 e8             	mov    -0x18(%ebp),%eax
  802274:	d3 e0                	shl    %cl,%eax
  802276:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  802279:	8b 45 e8             	mov    -0x18(%ebp),%eax
  80227c:	89 f9                	mov    %edi,%ecx
  80227e:	d3 e8                	shr    %cl,%eax
  802280:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  802282:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  802284:	89 f2                	mov    %esi,%edx
  802286:	f7 75 f0             	divl   -0x10(%ebp)
  802289:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  80228b:	f7 65 f4             	mull   -0xc(%ebp)
  80228e:	89 55 e8             	mov    %edx,-0x18(%ebp)
  802291:	89 c1                	mov    %eax,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802293:	39 d6                	cmp    %edx,%esi
  802295:	72 71                	jb     802308 <__umoddi3+0x110>
  802297:	74 7f                	je     802318 <__umoddi3+0x120>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  802299:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80229c:	29 c8                	sub    %ecx,%eax
  80229e:	19 d6                	sbb    %edx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  8022a0:	8a 4d ec             	mov    -0x14(%ebp),%cl
  8022a3:	d3 e8                	shr    %cl,%eax
  8022a5:	89 f2                	mov    %esi,%edx
  8022a7:	89 f9                	mov    %edi,%ecx
  8022a9:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  8022ab:	09 d0                	or     %edx,%eax
  8022ad:	89 f2                	mov    %esi,%edx
  8022af:	8a 4d ec             	mov    -0x14(%ebp),%cl
  8022b2:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8022b4:	83 c4 20             	add    $0x20,%esp
  8022b7:	5e                   	pop    %esi
  8022b8:	5f                   	pop    %edi
  8022b9:	c9                   	leave  
  8022ba:	c3                   	ret    
  8022bb:	90                   	nop
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  8022bc:	85 c9                	test   %ecx,%ecx
  8022be:	75 0b                	jne    8022cb <__umoddi3+0xd3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  8022c0:	b8 01 00 00 00       	mov    $0x1,%eax
  8022c5:	31 d2                	xor    %edx,%edx
  8022c7:	f7 f1                	div    %ecx
  8022c9:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  8022cb:	89 f0                	mov    %esi,%eax
  8022cd:	31 d2                	xor    %edx,%edx
  8022cf:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8022d1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8022d4:	f7 f1                	div    %ecx
  8022d6:	e9 4a ff ff ff       	jmp    802225 <__umoddi3+0x2d>
  8022db:	90                   	nop
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  8022dc:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8022de:	83 c4 20             	add    $0x20,%esp
  8022e1:	5e                   	pop    %esi
  8022e2:	5f                   	pop    %edi
  8022e3:	c9                   	leave  
  8022e4:	c3                   	ret    
  8022e5:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  8022e8:	39 f7                	cmp    %esi,%edi
  8022ea:	72 05                	jb     8022f1 <__umoddi3+0xf9>
  8022ec:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
  8022ef:	77 0c                	ja     8022fd <__umoddi3+0x105>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  8022f1:	89 f2                	mov    %esi,%edx
  8022f3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8022f6:	29 c8                	sub    %ecx,%eax
  8022f8:	19 fa                	sbb    %edi,%edx
  8022fa:	89 45 f0             	mov    %eax,-0x10(%ebp)

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  8022fd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802300:	83 c4 20             	add    $0x20,%esp
  802303:	5e                   	pop    %esi
  802304:	5f                   	pop    %edi
  802305:	c9                   	leave  
  802306:	c3                   	ret    
  802307:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  802308:	8b 55 e8             	mov    -0x18(%ebp),%edx
  80230b:	89 c1                	mov    %eax,%ecx
  80230d:	2b 4d f4             	sub    -0xc(%ebp),%ecx
  802310:	1b 55 f0             	sbb    -0x10(%ebp),%edx
  802313:	eb 84                	jmp    802299 <__umoddi3+0xa1>
  802315:	8d 76 00             	lea    0x0(%esi),%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802318:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  80231b:	72 eb                	jb     802308 <__umoddi3+0x110>
  80231d:	89 f2                	mov    %esi,%edx
  80231f:	e9 75 ff ff ff       	jmp    802299 <__umoddi3+0xa1>
