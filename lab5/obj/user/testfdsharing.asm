
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
  800044:	e8 93 18 00 00       	call   8018dc <open>
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
  80006a:	e8 c7 15 00 00       	call   801636 <seek>
	if ((n = readn(fd, buf, sizeof buf)) <= 0)
  80006f:	83 c4 0c             	add    $0xc,%esp
  800072:	68 00 02 00 00       	push   $0x200
  800077:	68 20 42 80 00       	push   $0x804220
  80007c:	53                   	push   %ebx
  80007d:	e8 dd 14 00 00       	call   80155f <readn>
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
  80009d:	e8 d0 0e 00 00       	call   800f72 <fork>
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
  8000c8:	e8 69 15 00 00       	call   801636 <seek>
		cprintf("going to read in child (might page fault if your sharing is buggy)\n");
  8000cd:	c7 04 24 b0 23 80 00 	movl   $0x8023b0,(%esp)
  8000d4:	e8 27 02 00 00       	call   800300 <cprintf>
		if ((n2 = readn(fd, buf2, sizeof buf2)) != n)
  8000d9:	83 c4 0c             	add    $0xc,%esp
  8000dc:	68 00 02 00 00       	push   $0x200
  8000e1:	68 20 40 80 00       	push   $0x804020
  8000e6:	53                   	push   %ebx
  8000e7:	e8 73 14 00 00       	call   80155f <readn>
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
  80014a:	e8 e7 14 00 00       	call   801636 <seek>
		close(fd);
  80014f:	89 1c 24             	mov    %ebx,(%esp)
  800152:	e8 44 12 00 00       	call   80139b <close>
		exit();
  800157:	e8 b0 00 00 00       	call   80020c <exit>
  80015c:	83 c4 10             	add    $0x10,%esp
	}
	wait(r);
  80015f:	83 ec 0c             	sub    $0xc,%esp
  800162:	56                   	push   %esi
  800163:	e8 78 1b 00 00       	call   801ce0 <wait>
	if ((n2 = readn(fd, buf2, sizeof buf2)) != n)
  800168:	83 c4 0c             	add    $0xc,%esp
  80016b:	68 00 02 00 00       	push   $0x200
  800170:	68 20 40 80 00       	push   $0x804020
  800175:	53                   	push   %ebx
  800176:	e8 e4 13 00 00       	call   80155f <readn>
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
  8001a8:	e8 ee 11 00 00       	call   80139b <close>
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
  800212:	e8 af 11 00 00       	call   8013c6 <close_all>
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
  80025c:	c7 04 24 92 23 80 00 	movl   $0x802392,(%esp)
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
  800368:	e8 8b 1d 00 00       	call   8020f8 <__udivdi3>
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
  8003a4:	e8 6b 1e 00 00       	call   802214 <__umoddi3>
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
  8005c2:	68 f5 29 80 00       	push   $0x8029f5
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

00800e78 <sys_exec>:

int
sys_exec(uint32_t eip, uint32_t esp, void * ph, uint32_t elf_phnum)
{
  800e78:	55                   	push   %ebp
  800e79:	89 e5                	mov    %esp,%ebp
  800e7b:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_exec, 0, eip, esp, (uint32_t)ph, elf_phnum, 0);
  800e7e:	6a 00                	push   $0x0
  800e80:	ff 75 14             	pushl  0x14(%ebp)
  800e83:	ff 75 10             	pushl  0x10(%ebp)
  800e86:	ff 75 0c             	pushl  0xc(%ebp)
  800e89:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e8c:	ba 00 00 00 00       	mov    $0x0,%edx
  800e91:	b8 0f 00 00 00       	mov    $0xf,%eax
  800e96:	e8 99 fd ff ff       	call   800c34 <syscall>
  800e9b:	c9                   	leave  
  800e9c:	c3                   	ret    
  800e9d:	00 00                	add    %al,(%eax)
	...

00800ea0 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800ea0:	55                   	push   %ebp
  800ea1:	89 e5                	mov    %esp,%ebp
  800ea3:	53                   	push   %ebx
  800ea4:	83 ec 04             	sub    $0x4,%esp
  800ea7:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800eaa:	8b 18                	mov    (%eax),%ebx

	// LAB 4: Your code here.
	
	// cprintf("PAGE FAULT HANDLER, 0x%08x %d\n", (uint32_t)addr, err & FEC_WR);
	
	if ((err & FEC_WR) == 0)
  800eac:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800eb0:	75 14                	jne    800ec6 <pgfault+0x26>
		panic("pgfault, the fault is not a write\n");
  800eb2:	83 ec 04             	sub    $0x4,%esp
  800eb5:	68 cc 27 80 00       	push   $0x8027cc
  800eba:	6a 20                	push   $0x20
  800ebc:	68 10 29 80 00       	push   $0x802910
  800ec1:	e8 62 f3 ff ff       	call   800228 <_panic>

	uint32_t uaddr = (uint32_t) addr;
	if ((uvpd[PDX(addr)] & PTE_P) == 0 || (uvpt[uaddr / PGSIZE] & PTE_COW) == 0) {
  800ec6:	89 d8                	mov    %ebx,%eax
  800ec8:	c1 e8 16             	shr    $0x16,%eax
  800ecb:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800ed2:	a8 01                	test   $0x1,%al
  800ed4:	74 11                	je     800ee7 <pgfault+0x47>
  800ed6:	89 d8                	mov    %ebx,%eax
  800ed8:	c1 e8 0c             	shr    $0xc,%eax
  800edb:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800ee2:	f6 c4 08             	test   $0x8,%ah
  800ee5:	75 14                	jne    800efb <pgfault+0x5b>
		panic("pgfault, not a copy-on-write page\n");
  800ee7:	83 ec 04             	sub    $0x4,%esp
  800eea:	68 f0 27 80 00       	push   $0x8027f0
  800eef:	6a 24                	push   $0x24
  800ef1:	68 10 29 80 00       	push   $0x802910
  800ef6:	e8 2d f3 ff ff       	call   800228 <_panic>
	//   No need to explicitly delete the old page's mapping.

	// LAB 4: Your code here.

	// static int sys_page_alloc(envid_t envid, void *va, int perm)
	r = sys_page_alloc(0, (void *)PFTEMP, PTE_W | PTE_U | PTE_P);
  800efb:	83 ec 04             	sub    $0x4,%esp
  800efe:	6a 07                	push   $0x7
  800f00:	68 00 f0 7f 00       	push   $0x7ff000
  800f05:	6a 00                	push   $0x0
  800f07:	e8 2c fe ff ff       	call   800d38 <sys_page_alloc>
	if (r < 0) panic("pgfault, sys_page_alloc error : %e\n", r);
  800f0c:	83 c4 10             	add    $0x10,%esp
  800f0f:	85 c0                	test   %eax,%eax
  800f11:	79 12                	jns    800f25 <pgfault+0x85>
  800f13:	50                   	push   %eax
  800f14:	68 14 28 80 00       	push   $0x802814
  800f19:	6a 32                	push   $0x32
  800f1b:	68 10 29 80 00       	push   $0x802910
  800f20:	e8 03 f3 ff ff       	call   800228 <_panic>

	// Oh my god, I forget this at the first, it waste me a lot of time to debug!!!
	addr = ROUNDDOWN(addr, PGSIZE);
  800f25:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	
	memcpy(PFTEMP, addr, PGSIZE);
  800f2b:	83 ec 04             	sub    $0x4,%esp
  800f2e:	68 00 10 00 00       	push   $0x1000
  800f33:	53                   	push   %ebx
  800f34:	68 00 f0 7f 00       	push   $0x7ff000
  800f39:	e8 a3 fb ff ff       	call   800ae1 <memcpy>
	
	r = sys_page_map(0, PFTEMP, 0, addr, PTE_W | PTE_U | PTE_P);
  800f3e:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800f45:	53                   	push   %ebx
  800f46:	6a 00                	push   $0x0
  800f48:	68 00 f0 7f 00       	push   $0x7ff000
  800f4d:	6a 00                	push   $0x0
  800f4f:	e8 08 fe ff ff       	call   800d5c <sys_page_map>
	if (r < 0) panic("pgfault, sys_page_map error : %e\n", r);
  800f54:	83 c4 20             	add    $0x20,%esp
  800f57:	85 c0                	test   %eax,%eax
  800f59:	79 12                	jns    800f6d <pgfault+0xcd>
  800f5b:	50                   	push   %eax
  800f5c:	68 38 28 80 00       	push   $0x802838
  800f61:	6a 3a                	push   $0x3a
  800f63:	68 10 29 80 00       	push   $0x802910
  800f68:	e8 bb f2 ff ff       	call   800228 <_panic>

	return;
}
  800f6d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f70:	c9                   	leave  
  800f71:	c3                   	ret    

00800f72 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800f72:	55                   	push   %ebp
  800f73:	89 e5                	mov    %esp,%ebp
  800f75:	57                   	push   %edi
  800f76:	56                   	push   %esi
  800f77:	53                   	push   %ebx
  800f78:	83 ec 28             	sub    $0x28,%esp
	// static int num = 0x100;

	// LAB 4: Your code here.
	set_pgfault_handler(pgfault);
  800f7b:	68 a0 0e 80 00       	push   $0x800ea0
  800f80:	e8 73 0f 00 00       	call   801ef8 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  800f85:	ba 07 00 00 00       	mov    $0x7,%edx
  800f8a:	89 d0                	mov    %edx,%eax
  800f8c:	cd 30                	int    $0x30
  800f8e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800f91:	89 c7                	mov    %eax,%edi
	int childpid = sys_exofork();
	if (childpid < 0) {
  800f93:	83 c4 10             	add    $0x10,%esp
  800f96:	85 c0                	test   %eax,%eax
  800f98:	79 12                	jns    800fac <fork+0x3a>
		panic("fork sys_exofork error : %e\n", childpid);
  800f9a:	50                   	push   %eax
  800f9b:	68 1b 29 80 00       	push   $0x80291b
  800fa0:	6a 7f                	push   $0x7f
  800fa2:	68 10 29 80 00       	push   $0x802910
  800fa7:	e8 7c f2 ff ff       	call   800228 <_panic>
	}
	int r;

	if (childpid == 0) {
  800fac:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800fb0:	75 25                	jne    800fd7 <fork+0x65>
		// child process
		// Remember to fix "thisenv" in the child process. ??? 
		thisenv = &envs[ENVX(sys_getenvid())];
  800fb2:	e8 36 fd ff ff       	call   800ced <sys_getenvid>
  800fb7:	25 ff 03 00 00       	and    $0x3ff,%eax
  800fbc:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800fc3:	c1 e0 07             	shl    $0x7,%eax
  800fc6:	29 d0                	sub    %edx,%eax
  800fc8:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800fcd:	a3 20 44 80 00       	mov    %eax,0x804420
		// cprintf("fork child ok\n");
		return 0;
  800fd2:	e9 be 01 00 00       	jmp    801195 <fork+0x223>
	if (childpid < 0) {
		panic("fork sys_exofork error : %e\n", childpid);
	}
	int r;

	if (childpid == 0) {
  800fd7:	bb 00 00 00 00       	mov    $0x0,%ebx
	} else {
		// map page to new environment
		// kernel page is already in new environment
		uint32_t i;
		for (i = 0; i != UTOP; i += PGSIZE) 
		if ((uvpd[PDX(i)] & PTE_P) && (uvpt[i / PGSIZE] & PTE_P) && (uvpt[i / PGSIZE] & PTE_U)) {
  800fdc:	89 d8                	mov    %ebx,%eax
  800fde:	c1 e8 16             	shr    $0x16,%eax
  800fe1:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800fe8:	a8 01                	test   $0x1,%al
  800fea:	0f 84 10 01 00 00    	je     801100 <fork+0x18e>
  800ff0:	89 d8                	mov    %ebx,%eax
  800ff2:	c1 e8 0c             	shr    $0xc,%eax
  800ff5:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800ffc:	f6 c2 01             	test   $0x1,%dl
  800fff:	0f 84 fb 00 00 00    	je     801100 <fork+0x18e>
  801005:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80100c:	f6 c2 04             	test   $0x4,%dl
  80100f:	0f 84 eb 00 00 00    	je     801100 <fork+0x18e>
//
static int
duppage(envid_t envid, unsigned pn)
{
	// do not dup exception stack
	if (pn * PGSIZE == UXSTACKTOP - PGSIZE) return 0;
  801015:	89 c6                	mov    %eax,%esi
  801017:	c1 e6 0c             	shl    $0xc,%esi
  80101a:	81 fe 00 f0 bf ee    	cmp    $0xeebff000,%esi
  801020:	0f 84 da 00 00 00    	je     801100 <fork+0x18e>

	int r;
	void * addr = (void *)(pn * PGSIZE);
    if (uvpt[pn] & PTE_SHARE) {
  801026:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80102d:	f6 c6 04             	test   $0x4,%dh
  801030:	74 37                	je     801069 <fork+0xf7>
        r = sys_page_map(0, addr, envid, addr, uvpt[pn] & PTE_SYSCALL);
  801032:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801039:	83 ec 0c             	sub    $0xc,%esp
  80103c:	25 07 0e 00 00       	and    $0xe07,%eax
  801041:	50                   	push   %eax
  801042:	56                   	push   %esi
  801043:	57                   	push   %edi
  801044:	56                   	push   %esi
  801045:	6a 00                	push   $0x0
  801047:	e8 10 fd ff ff       	call   800d5c <sys_page_map>
        if (r < 0) panic("duppage sys_page_map error : %e\n", r);
  80104c:	83 c4 20             	add    $0x20,%esp
  80104f:	85 c0                	test   %eax,%eax
  801051:	0f 89 a9 00 00 00    	jns    801100 <fork+0x18e>
  801057:	50                   	push   %eax
  801058:	68 5c 28 80 00       	push   $0x80285c
  80105d:	6a 54                	push   $0x54
  80105f:	68 10 29 80 00       	push   $0x802910
  801064:	e8 bf f1 ff ff       	call   800228 <_panic>
    } else
	if ((uvpt[pn] & PTE_W) || (uvpt[pn] & PTE_COW)) {
  801069:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801070:	f6 c2 02             	test   $0x2,%dl
  801073:	75 0c                	jne    801081 <fork+0x10f>
  801075:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80107c:	f6 c4 08             	test   $0x8,%ah
  80107f:	74 57                	je     8010d8 <fork+0x166>
		// cow
		r = sys_page_map(0, addr, envid, addr, PTE_COW | PTE_P | PTE_U);
  801081:	83 ec 0c             	sub    $0xc,%esp
  801084:	68 05 08 00 00       	push   $0x805
  801089:	56                   	push   %esi
  80108a:	57                   	push   %edi
  80108b:	56                   	push   %esi
  80108c:	6a 00                	push   $0x0
  80108e:	e8 c9 fc ff ff       	call   800d5c <sys_page_map>
		if (r < 0) panic("duppage sys_page_map error : %e\n", r);
  801093:	83 c4 20             	add    $0x20,%esp
  801096:	85 c0                	test   %eax,%eax
  801098:	79 12                	jns    8010ac <fork+0x13a>
  80109a:	50                   	push   %eax
  80109b:	68 5c 28 80 00       	push   $0x80285c
  8010a0:	6a 59                	push   $0x59
  8010a2:	68 10 29 80 00       	push   $0x802910
  8010a7:	e8 7c f1 ff ff       	call   800228 <_panic>
		
		r = sys_page_map(0, addr, 0, addr, PTE_COW | PTE_P | PTE_U);
  8010ac:	83 ec 0c             	sub    $0xc,%esp
  8010af:	68 05 08 00 00       	push   $0x805
  8010b4:	56                   	push   %esi
  8010b5:	6a 00                	push   $0x0
  8010b7:	56                   	push   %esi
  8010b8:	6a 00                	push   $0x0
  8010ba:	e8 9d fc ff ff       	call   800d5c <sys_page_map>
		if (r < 0) panic("duppage sys_page_map error : %e\n", r);
  8010bf:	83 c4 20             	add    $0x20,%esp
  8010c2:	85 c0                	test   %eax,%eax
  8010c4:	79 3a                	jns    801100 <fork+0x18e>
  8010c6:	50                   	push   %eax
  8010c7:	68 5c 28 80 00       	push   $0x80285c
  8010cc:	6a 5c                	push   $0x5c
  8010ce:	68 10 29 80 00       	push   $0x802910
  8010d3:	e8 50 f1 ff ff       	call   800228 <_panic>
	} else {
		// read only
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U);
  8010d8:	83 ec 0c             	sub    $0xc,%esp
  8010db:	6a 05                	push   $0x5
  8010dd:	56                   	push   %esi
  8010de:	57                   	push   %edi
  8010df:	56                   	push   %esi
  8010e0:	6a 00                	push   $0x0
  8010e2:	e8 75 fc ff ff       	call   800d5c <sys_page_map>
		if (r < 0) panic("duppage sys_page_map error : %e\n", r);
  8010e7:	83 c4 20             	add    $0x20,%esp
  8010ea:	85 c0                	test   %eax,%eax
  8010ec:	79 12                	jns    801100 <fork+0x18e>
  8010ee:	50                   	push   %eax
  8010ef:	68 5c 28 80 00       	push   $0x80285c
  8010f4:	6a 60                	push   $0x60
  8010f6:	68 10 29 80 00       	push   $0x802910
  8010fb:	e8 28 f1 ff ff       	call   800228 <_panic>
		return 0;
	} else {
		// map page to new environment
		// kernel page is already in new environment
		uint32_t i;
		for (i = 0; i != UTOP; i += PGSIZE) 
  801100:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801106:	81 fb 00 00 c0 ee    	cmp    $0xeec00000,%ebx
  80110c:	0f 85 ca fe ff ff    	jne    800fdc <fork+0x6a>
		if ((uvpd[PDX(i)] & PTE_P) && (uvpt[i / PGSIZE] & PTE_P) && (uvpt[i / PGSIZE] & PTE_U)) {
			duppage(childpid, i / PGSIZE);
		}

		// allocate exception stack
		r = sys_page_alloc(childpid, (void *)(UXSTACKTOP - PGSIZE), PTE_U | PTE_W | PTE_P);
  801112:	83 ec 04             	sub    $0x4,%esp
  801115:	6a 07                	push   $0x7
  801117:	68 00 f0 bf ee       	push   $0xeebff000
  80111c:	ff 75 e4             	pushl  -0x1c(%ebp)
  80111f:	e8 14 fc ff ff       	call   800d38 <sys_page_alloc>
		if (r < 0) panic("fork, sys_page_alloc user exception stack error : %e\n", r);
  801124:	83 c4 10             	add    $0x10,%esp
  801127:	85 c0                	test   %eax,%eax
  801129:	79 15                	jns    801140 <fork+0x1ce>
  80112b:	50                   	push   %eax
  80112c:	68 80 28 80 00       	push   $0x802880
  801131:	68 94 00 00 00       	push   $0x94
  801136:	68 10 29 80 00       	push   $0x802910
  80113b:	e8 e8 f0 ff ff       	call   800228 <_panic>

		// set user environment user page fault handler 
		extern void _pgfault_upcall(void);
		r = sys_env_set_pgfault_upcall(childpid, _pgfault_upcall);
  801140:	83 ec 08             	sub    $0x8,%esp
  801143:	68 64 1f 80 00       	push   $0x801f64
  801148:	ff 75 e4             	pushl  -0x1c(%ebp)
  80114b:	e8 9b fc ff ff       	call   800deb <sys_env_set_pgfault_upcall>
		if (r < 0) panic("fork, set pgfault upcall fail : %e\n", r);
  801150:	83 c4 10             	add    $0x10,%esp
  801153:	85 c0                	test   %eax,%eax
  801155:	79 15                	jns    80116c <fork+0x1fa>
  801157:	50                   	push   %eax
  801158:	68 b8 28 80 00       	push   $0x8028b8
  80115d:	68 99 00 00 00       	push   $0x99
  801162:	68 10 29 80 00       	push   $0x802910
  801167:	e8 bc f0 ff ff       	call   800228 <_panic>
		r = sys_set_priority(childpid, num);
		if (r < 0) panic("fork, set priority error\n");
		*/

		// mark the child as runnable and return
		r = sys_env_set_status(childpid, ENV_RUNNABLE);
  80116c:	83 ec 08             	sub    $0x8,%esp
  80116f:	6a 02                	push   $0x2
  801171:	ff 75 e4             	pushl  -0x1c(%ebp)
  801174:	e8 2c fc ff ff       	call   800da5 <sys_env_set_status>
		if (r < 0) panic("fork, set child process to ENV_RUNNABLE error : %e\n", r);
  801179:	83 c4 10             	add    $0x10,%esp
  80117c:	85 c0                	test   %eax,%eax
  80117e:	79 15                	jns    801195 <fork+0x223>
  801180:	50                   	push   %eax
  801181:	68 dc 28 80 00       	push   $0x8028dc
  801186:	68 a4 00 00 00       	push   $0xa4
  80118b:	68 10 29 80 00       	push   $0x802910
  801190:	e8 93 f0 ff ff       	call   800228 <_panic>
		// cprintf("fork father ok!")
		return childpid;
	}

	panic("fork not implemented");
}
  801195:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801198:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80119b:	5b                   	pop    %ebx
  80119c:	5e                   	pop    %esi
  80119d:	5f                   	pop    %edi
  80119e:	c9                   	leave  
  80119f:	c3                   	ret    

008011a0 <sfork>:

// Challenge!
int
sfork(void)
{
  8011a0:	55                   	push   %ebp
  8011a1:	89 e5                	mov    %esp,%ebp
  8011a3:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  8011a6:	68 38 29 80 00       	push   $0x802938
  8011ab:	68 b1 00 00 00       	push   $0xb1
  8011b0:	68 10 29 80 00       	push   $0x802910
  8011b5:	e8 6e f0 ff ff       	call   800228 <_panic>
	...

008011bc <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8011bc:	55                   	push   %ebp
  8011bd:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8011bf:	8b 45 08             	mov    0x8(%ebp),%eax
  8011c2:	05 00 00 00 30       	add    $0x30000000,%eax
  8011c7:	c1 e8 0c             	shr    $0xc,%eax
}
  8011ca:	c9                   	leave  
  8011cb:	c3                   	ret    

008011cc <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8011cc:	55                   	push   %ebp
  8011cd:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  8011cf:	ff 75 08             	pushl  0x8(%ebp)
  8011d2:	e8 e5 ff ff ff       	call   8011bc <fd2num>
  8011d7:	83 c4 04             	add    $0x4,%esp
  8011da:	05 20 00 0d 00       	add    $0xd0020,%eax
  8011df:	c1 e0 0c             	shl    $0xc,%eax
}
  8011e2:	c9                   	leave  
  8011e3:	c3                   	ret    

008011e4 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8011e4:	55                   	push   %ebp
  8011e5:	89 e5                	mov    %esp,%ebp
  8011e7:	53                   	push   %ebx
  8011e8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8011eb:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  8011f0:	a8 01                	test   $0x1,%al
  8011f2:	74 34                	je     801228 <fd_alloc+0x44>
  8011f4:	a1 00 00 74 ef       	mov    0xef740000,%eax
  8011f9:	a8 01                	test   $0x1,%al
  8011fb:	74 32                	je     80122f <fd_alloc+0x4b>
  8011fd:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
  801202:	89 c1                	mov    %eax,%ecx
  801204:	89 c2                	mov    %eax,%edx
  801206:	c1 ea 16             	shr    $0x16,%edx
  801209:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801210:	f6 c2 01             	test   $0x1,%dl
  801213:	74 1f                	je     801234 <fd_alloc+0x50>
  801215:	89 c2                	mov    %eax,%edx
  801217:	c1 ea 0c             	shr    $0xc,%edx
  80121a:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801221:	f6 c2 01             	test   $0x1,%dl
  801224:	75 17                	jne    80123d <fd_alloc+0x59>
  801226:	eb 0c                	jmp    801234 <fd_alloc+0x50>
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  801228:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
  80122d:	eb 05                	jmp    801234 <fd_alloc+0x50>
  80122f:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
  801234:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  801236:	b8 00 00 00 00       	mov    $0x0,%eax
  80123b:	eb 17                	jmp    801254 <fd_alloc+0x70>
  80123d:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801242:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801247:	75 b9                	jne    801202 <fd_alloc+0x1e>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801249:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  80124f:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801254:	5b                   	pop    %ebx
  801255:	c9                   	leave  
  801256:	c3                   	ret    

00801257 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801257:	55                   	push   %ebp
  801258:	89 e5                	mov    %esp,%ebp
  80125a:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80125d:	83 f8 1f             	cmp    $0x1f,%eax
  801260:	77 36                	ja     801298 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801262:	05 00 00 0d 00       	add    $0xd0000,%eax
  801267:	c1 e0 0c             	shl    $0xc,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80126a:	89 c2                	mov    %eax,%edx
  80126c:	c1 ea 16             	shr    $0x16,%edx
  80126f:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801276:	f6 c2 01             	test   $0x1,%dl
  801279:	74 24                	je     80129f <fd_lookup+0x48>
  80127b:	89 c2                	mov    %eax,%edx
  80127d:	c1 ea 0c             	shr    $0xc,%edx
  801280:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801287:	f6 c2 01             	test   $0x1,%dl
  80128a:	74 1a                	je     8012a6 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80128c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80128f:	89 02                	mov    %eax,(%edx)
	return 0;
  801291:	b8 00 00 00 00       	mov    $0x0,%eax
  801296:	eb 13                	jmp    8012ab <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801298:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80129d:	eb 0c                	jmp    8012ab <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80129f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012a4:	eb 05                	jmp    8012ab <fd_lookup+0x54>
  8012a6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8012ab:	c9                   	leave  
  8012ac:	c3                   	ret    

008012ad <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8012ad:	55                   	push   %ebp
  8012ae:	89 e5                	mov    %esp,%ebp
  8012b0:	53                   	push   %ebx
  8012b1:	83 ec 04             	sub    $0x4,%esp
  8012b4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8012b7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  8012ba:	39 0d 04 30 80 00    	cmp    %ecx,0x803004
  8012c0:	74 0d                	je     8012cf <dev_lookup+0x22>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8012c2:	b8 00 00 00 00       	mov    $0x0,%eax
  8012c7:	eb 14                	jmp    8012dd <dev_lookup+0x30>
		if (devtab[i]->dev_id == dev_id) {
  8012c9:	39 0a                	cmp    %ecx,(%edx)
  8012cb:	75 10                	jne    8012dd <dev_lookup+0x30>
  8012cd:	eb 05                	jmp    8012d4 <dev_lookup+0x27>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8012cf:	ba 04 30 80 00       	mov    $0x803004,%edx
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
  8012d4:	89 13                	mov    %edx,(%ebx)
			return 0;
  8012d6:	b8 00 00 00 00       	mov    $0x0,%eax
  8012db:	eb 31                	jmp    80130e <dev_lookup+0x61>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8012dd:	40                   	inc    %eax
  8012de:	8b 14 85 cc 29 80 00 	mov    0x8029cc(,%eax,4),%edx
  8012e5:	85 d2                	test   %edx,%edx
  8012e7:	75 e0                	jne    8012c9 <dev_lookup+0x1c>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8012e9:	a1 20 44 80 00       	mov    0x804420,%eax
  8012ee:	8b 40 48             	mov    0x48(%eax),%eax
  8012f1:	83 ec 04             	sub    $0x4,%esp
  8012f4:	51                   	push   %ecx
  8012f5:	50                   	push   %eax
  8012f6:	68 50 29 80 00       	push   $0x802950
  8012fb:	e8 00 f0 ff ff       	call   800300 <cprintf>
	*dev = 0;
  801300:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  801306:	83 c4 10             	add    $0x10,%esp
  801309:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80130e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801311:	c9                   	leave  
  801312:	c3                   	ret    

00801313 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801313:	55                   	push   %ebp
  801314:	89 e5                	mov    %esp,%ebp
  801316:	56                   	push   %esi
  801317:	53                   	push   %ebx
  801318:	83 ec 20             	sub    $0x20,%esp
  80131b:	8b 75 08             	mov    0x8(%ebp),%esi
  80131e:	8a 45 0c             	mov    0xc(%ebp),%al
  801321:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801324:	56                   	push   %esi
  801325:	e8 92 fe ff ff       	call   8011bc <fd2num>
  80132a:	8d 55 f4             	lea    -0xc(%ebp),%edx
  80132d:	89 14 24             	mov    %edx,(%esp)
  801330:	50                   	push   %eax
  801331:	e8 21 ff ff ff       	call   801257 <fd_lookup>
  801336:	89 c3                	mov    %eax,%ebx
  801338:	83 c4 08             	add    $0x8,%esp
  80133b:	85 c0                	test   %eax,%eax
  80133d:	78 05                	js     801344 <fd_close+0x31>
	    || fd != fd2)
  80133f:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801342:	74 0d                	je     801351 <fd_close+0x3e>
		return (must_exist ? r : 0);
  801344:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  801348:	75 48                	jne    801392 <fd_close+0x7f>
  80134a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80134f:	eb 41                	jmp    801392 <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801351:	83 ec 08             	sub    $0x8,%esp
  801354:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801357:	50                   	push   %eax
  801358:	ff 36                	pushl  (%esi)
  80135a:	e8 4e ff ff ff       	call   8012ad <dev_lookup>
  80135f:	89 c3                	mov    %eax,%ebx
  801361:	83 c4 10             	add    $0x10,%esp
  801364:	85 c0                	test   %eax,%eax
  801366:	78 1c                	js     801384 <fd_close+0x71>
		if (dev->dev_close)
  801368:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80136b:	8b 40 10             	mov    0x10(%eax),%eax
  80136e:	85 c0                	test   %eax,%eax
  801370:	74 0d                	je     80137f <fd_close+0x6c>
			r = (*dev->dev_close)(fd);
  801372:	83 ec 0c             	sub    $0xc,%esp
  801375:	56                   	push   %esi
  801376:	ff d0                	call   *%eax
  801378:	89 c3                	mov    %eax,%ebx
  80137a:	83 c4 10             	add    $0x10,%esp
  80137d:	eb 05                	jmp    801384 <fd_close+0x71>
		else
			r = 0;
  80137f:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801384:	83 ec 08             	sub    $0x8,%esp
  801387:	56                   	push   %esi
  801388:	6a 00                	push   $0x0
  80138a:	e8 f3 f9 ff ff       	call   800d82 <sys_page_unmap>
	return r;
  80138f:	83 c4 10             	add    $0x10,%esp
}
  801392:	89 d8                	mov    %ebx,%eax
  801394:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801397:	5b                   	pop    %ebx
  801398:	5e                   	pop    %esi
  801399:	c9                   	leave  
  80139a:	c3                   	ret    

0080139b <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80139b:	55                   	push   %ebp
  80139c:	89 e5                	mov    %esp,%ebp
  80139e:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8013a1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013a4:	50                   	push   %eax
  8013a5:	ff 75 08             	pushl  0x8(%ebp)
  8013a8:	e8 aa fe ff ff       	call   801257 <fd_lookup>
  8013ad:	83 c4 08             	add    $0x8,%esp
  8013b0:	85 c0                	test   %eax,%eax
  8013b2:	78 10                	js     8013c4 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  8013b4:	83 ec 08             	sub    $0x8,%esp
  8013b7:	6a 01                	push   $0x1
  8013b9:	ff 75 f4             	pushl  -0xc(%ebp)
  8013bc:	e8 52 ff ff ff       	call   801313 <fd_close>
  8013c1:	83 c4 10             	add    $0x10,%esp
}
  8013c4:	c9                   	leave  
  8013c5:	c3                   	ret    

008013c6 <close_all>:

void
close_all(void)
{
  8013c6:	55                   	push   %ebp
  8013c7:	89 e5                	mov    %esp,%ebp
  8013c9:	53                   	push   %ebx
  8013ca:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8013cd:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8013d2:	83 ec 0c             	sub    $0xc,%esp
  8013d5:	53                   	push   %ebx
  8013d6:	e8 c0 ff ff ff       	call   80139b <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8013db:	43                   	inc    %ebx
  8013dc:	83 c4 10             	add    $0x10,%esp
  8013df:	83 fb 20             	cmp    $0x20,%ebx
  8013e2:	75 ee                	jne    8013d2 <close_all+0xc>
		close(i);
}
  8013e4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013e7:	c9                   	leave  
  8013e8:	c3                   	ret    

008013e9 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8013e9:	55                   	push   %ebp
  8013ea:	89 e5                	mov    %esp,%ebp
  8013ec:	57                   	push   %edi
  8013ed:	56                   	push   %esi
  8013ee:	53                   	push   %ebx
  8013ef:	83 ec 2c             	sub    $0x2c,%esp
  8013f2:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8013f5:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8013f8:	50                   	push   %eax
  8013f9:	ff 75 08             	pushl  0x8(%ebp)
  8013fc:	e8 56 fe ff ff       	call   801257 <fd_lookup>
  801401:	89 c3                	mov    %eax,%ebx
  801403:	83 c4 08             	add    $0x8,%esp
  801406:	85 c0                	test   %eax,%eax
  801408:	0f 88 c0 00 00 00    	js     8014ce <dup+0xe5>
		return r;
	close(newfdnum);
  80140e:	83 ec 0c             	sub    $0xc,%esp
  801411:	57                   	push   %edi
  801412:	e8 84 ff ff ff       	call   80139b <close>

	newfd = INDEX2FD(newfdnum);
  801417:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  80141d:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  801420:	83 c4 04             	add    $0x4,%esp
  801423:	ff 75 e4             	pushl  -0x1c(%ebp)
  801426:	e8 a1 fd ff ff       	call   8011cc <fd2data>
  80142b:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  80142d:	89 34 24             	mov    %esi,(%esp)
  801430:	e8 97 fd ff ff       	call   8011cc <fd2data>
  801435:	83 c4 10             	add    $0x10,%esp
  801438:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80143b:	89 d8                	mov    %ebx,%eax
  80143d:	c1 e8 16             	shr    $0x16,%eax
  801440:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801447:	a8 01                	test   $0x1,%al
  801449:	74 37                	je     801482 <dup+0x99>
  80144b:	89 d8                	mov    %ebx,%eax
  80144d:	c1 e8 0c             	shr    $0xc,%eax
  801450:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801457:	f6 c2 01             	test   $0x1,%dl
  80145a:	74 26                	je     801482 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80145c:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801463:	83 ec 0c             	sub    $0xc,%esp
  801466:	25 07 0e 00 00       	and    $0xe07,%eax
  80146b:	50                   	push   %eax
  80146c:	ff 75 d4             	pushl  -0x2c(%ebp)
  80146f:	6a 00                	push   $0x0
  801471:	53                   	push   %ebx
  801472:	6a 00                	push   $0x0
  801474:	e8 e3 f8 ff ff       	call   800d5c <sys_page_map>
  801479:	89 c3                	mov    %eax,%ebx
  80147b:	83 c4 20             	add    $0x20,%esp
  80147e:	85 c0                	test   %eax,%eax
  801480:	78 2d                	js     8014af <dup+0xc6>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801482:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801485:	89 c2                	mov    %eax,%edx
  801487:	c1 ea 0c             	shr    $0xc,%edx
  80148a:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801491:	83 ec 0c             	sub    $0xc,%esp
  801494:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  80149a:	52                   	push   %edx
  80149b:	56                   	push   %esi
  80149c:	6a 00                	push   $0x0
  80149e:	50                   	push   %eax
  80149f:	6a 00                	push   $0x0
  8014a1:	e8 b6 f8 ff ff       	call   800d5c <sys_page_map>
  8014a6:	89 c3                	mov    %eax,%ebx
  8014a8:	83 c4 20             	add    $0x20,%esp
  8014ab:	85 c0                	test   %eax,%eax
  8014ad:	79 1d                	jns    8014cc <dup+0xe3>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8014af:	83 ec 08             	sub    $0x8,%esp
  8014b2:	56                   	push   %esi
  8014b3:	6a 00                	push   $0x0
  8014b5:	e8 c8 f8 ff ff       	call   800d82 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8014ba:	83 c4 08             	add    $0x8,%esp
  8014bd:	ff 75 d4             	pushl  -0x2c(%ebp)
  8014c0:	6a 00                	push   $0x0
  8014c2:	e8 bb f8 ff ff       	call   800d82 <sys_page_unmap>
	return r;
  8014c7:	83 c4 10             	add    $0x10,%esp
  8014ca:	eb 02                	jmp    8014ce <dup+0xe5>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  8014cc:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  8014ce:	89 d8                	mov    %ebx,%eax
  8014d0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8014d3:	5b                   	pop    %ebx
  8014d4:	5e                   	pop    %esi
  8014d5:	5f                   	pop    %edi
  8014d6:	c9                   	leave  
  8014d7:	c3                   	ret    

008014d8 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8014d8:	55                   	push   %ebp
  8014d9:	89 e5                	mov    %esp,%ebp
  8014db:	53                   	push   %ebx
  8014dc:	83 ec 14             	sub    $0x14,%esp
  8014df:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8014e2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014e5:	50                   	push   %eax
  8014e6:	53                   	push   %ebx
  8014e7:	e8 6b fd ff ff       	call   801257 <fd_lookup>
  8014ec:	83 c4 08             	add    $0x8,%esp
  8014ef:	85 c0                	test   %eax,%eax
  8014f1:	78 67                	js     80155a <read+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014f3:	83 ec 08             	sub    $0x8,%esp
  8014f6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014f9:	50                   	push   %eax
  8014fa:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014fd:	ff 30                	pushl  (%eax)
  8014ff:	e8 a9 fd ff ff       	call   8012ad <dev_lookup>
  801504:	83 c4 10             	add    $0x10,%esp
  801507:	85 c0                	test   %eax,%eax
  801509:	78 4f                	js     80155a <read+0x82>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80150b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80150e:	8b 50 08             	mov    0x8(%eax),%edx
  801511:	83 e2 03             	and    $0x3,%edx
  801514:	83 fa 01             	cmp    $0x1,%edx
  801517:	75 21                	jne    80153a <read+0x62>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801519:	a1 20 44 80 00       	mov    0x804420,%eax
  80151e:	8b 40 48             	mov    0x48(%eax),%eax
  801521:	83 ec 04             	sub    $0x4,%esp
  801524:	53                   	push   %ebx
  801525:	50                   	push   %eax
  801526:	68 91 29 80 00       	push   $0x802991
  80152b:	e8 d0 ed ff ff       	call   800300 <cprintf>
		return -E_INVAL;
  801530:	83 c4 10             	add    $0x10,%esp
  801533:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801538:	eb 20                	jmp    80155a <read+0x82>
	}
	if (!dev->dev_read)
  80153a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80153d:	8b 52 08             	mov    0x8(%edx),%edx
  801540:	85 d2                	test   %edx,%edx
  801542:	74 11                	je     801555 <read+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801544:	83 ec 04             	sub    $0x4,%esp
  801547:	ff 75 10             	pushl  0x10(%ebp)
  80154a:	ff 75 0c             	pushl  0xc(%ebp)
  80154d:	50                   	push   %eax
  80154e:	ff d2                	call   *%edx
  801550:	83 c4 10             	add    $0x10,%esp
  801553:	eb 05                	jmp    80155a <read+0x82>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801555:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  80155a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80155d:	c9                   	leave  
  80155e:	c3                   	ret    

0080155f <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80155f:	55                   	push   %ebp
  801560:	89 e5                	mov    %esp,%ebp
  801562:	57                   	push   %edi
  801563:	56                   	push   %esi
  801564:	53                   	push   %ebx
  801565:	83 ec 0c             	sub    $0xc,%esp
  801568:	8b 7d 08             	mov    0x8(%ebp),%edi
  80156b:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80156e:	85 f6                	test   %esi,%esi
  801570:	74 31                	je     8015a3 <readn+0x44>
  801572:	b8 00 00 00 00       	mov    $0x0,%eax
  801577:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = read(fdnum, (char*)buf + tot, n - tot);
  80157c:	83 ec 04             	sub    $0x4,%esp
  80157f:	89 f2                	mov    %esi,%edx
  801581:	29 c2                	sub    %eax,%edx
  801583:	52                   	push   %edx
  801584:	03 45 0c             	add    0xc(%ebp),%eax
  801587:	50                   	push   %eax
  801588:	57                   	push   %edi
  801589:	e8 4a ff ff ff       	call   8014d8 <read>
		if (m < 0)
  80158e:	83 c4 10             	add    $0x10,%esp
  801591:	85 c0                	test   %eax,%eax
  801593:	78 17                	js     8015ac <readn+0x4d>
			return m;
		if (m == 0)
  801595:	85 c0                	test   %eax,%eax
  801597:	74 11                	je     8015aa <readn+0x4b>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801599:	01 c3                	add    %eax,%ebx
  80159b:	89 d8                	mov    %ebx,%eax
  80159d:	39 f3                	cmp    %esi,%ebx
  80159f:	72 db                	jb     80157c <readn+0x1d>
  8015a1:	eb 09                	jmp    8015ac <readn+0x4d>
  8015a3:	b8 00 00 00 00       	mov    $0x0,%eax
  8015a8:	eb 02                	jmp    8015ac <readn+0x4d>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  8015aa:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  8015ac:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8015af:	5b                   	pop    %ebx
  8015b0:	5e                   	pop    %esi
  8015b1:	5f                   	pop    %edi
  8015b2:	c9                   	leave  
  8015b3:	c3                   	ret    

008015b4 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8015b4:	55                   	push   %ebp
  8015b5:	89 e5                	mov    %esp,%ebp
  8015b7:	53                   	push   %ebx
  8015b8:	83 ec 14             	sub    $0x14,%esp
  8015bb:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015be:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015c1:	50                   	push   %eax
  8015c2:	53                   	push   %ebx
  8015c3:	e8 8f fc ff ff       	call   801257 <fd_lookup>
  8015c8:	83 c4 08             	add    $0x8,%esp
  8015cb:	85 c0                	test   %eax,%eax
  8015cd:	78 62                	js     801631 <write+0x7d>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015cf:	83 ec 08             	sub    $0x8,%esp
  8015d2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015d5:	50                   	push   %eax
  8015d6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015d9:	ff 30                	pushl  (%eax)
  8015db:	e8 cd fc ff ff       	call   8012ad <dev_lookup>
  8015e0:	83 c4 10             	add    $0x10,%esp
  8015e3:	85 c0                	test   %eax,%eax
  8015e5:	78 4a                	js     801631 <write+0x7d>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8015e7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015ea:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8015ee:	75 21                	jne    801611 <write+0x5d>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8015f0:	a1 20 44 80 00       	mov    0x804420,%eax
  8015f5:	8b 40 48             	mov    0x48(%eax),%eax
  8015f8:	83 ec 04             	sub    $0x4,%esp
  8015fb:	53                   	push   %ebx
  8015fc:	50                   	push   %eax
  8015fd:	68 ad 29 80 00       	push   $0x8029ad
  801602:	e8 f9 ec ff ff       	call   800300 <cprintf>
		return -E_INVAL;
  801607:	83 c4 10             	add    $0x10,%esp
  80160a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80160f:	eb 20                	jmp    801631 <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801611:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801614:	8b 52 0c             	mov    0xc(%edx),%edx
  801617:	85 d2                	test   %edx,%edx
  801619:	74 11                	je     80162c <write+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80161b:	83 ec 04             	sub    $0x4,%esp
  80161e:	ff 75 10             	pushl  0x10(%ebp)
  801621:	ff 75 0c             	pushl  0xc(%ebp)
  801624:	50                   	push   %eax
  801625:	ff d2                	call   *%edx
  801627:	83 c4 10             	add    $0x10,%esp
  80162a:	eb 05                	jmp    801631 <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80162c:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  801631:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801634:	c9                   	leave  
  801635:	c3                   	ret    

00801636 <seek>:

int
seek(int fdnum, off_t offset)
{
  801636:	55                   	push   %ebp
  801637:	89 e5                	mov    %esp,%ebp
  801639:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80163c:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80163f:	50                   	push   %eax
  801640:	ff 75 08             	pushl  0x8(%ebp)
  801643:	e8 0f fc ff ff       	call   801257 <fd_lookup>
  801648:	83 c4 08             	add    $0x8,%esp
  80164b:	85 c0                	test   %eax,%eax
  80164d:	78 0e                	js     80165d <seek+0x27>
		return r;
	fd->fd_offset = offset;
  80164f:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801652:	8b 55 0c             	mov    0xc(%ebp),%edx
  801655:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801658:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80165d:	c9                   	leave  
  80165e:	c3                   	ret    

0080165f <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80165f:	55                   	push   %ebp
  801660:	89 e5                	mov    %esp,%ebp
  801662:	53                   	push   %ebx
  801663:	83 ec 14             	sub    $0x14,%esp
  801666:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801669:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80166c:	50                   	push   %eax
  80166d:	53                   	push   %ebx
  80166e:	e8 e4 fb ff ff       	call   801257 <fd_lookup>
  801673:	83 c4 08             	add    $0x8,%esp
  801676:	85 c0                	test   %eax,%eax
  801678:	78 5f                	js     8016d9 <ftruncate+0x7a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80167a:	83 ec 08             	sub    $0x8,%esp
  80167d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801680:	50                   	push   %eax
  801681:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801684:	ff 30                	pushl  (%eax)
  801686:	e8 22 fc ff ff       	call   8012ad <dev_lookup>
  80168b:	83 c4 10             	add    $0x10,%esp
  80168e:	85 c0                	test   %eax,%eax
  801690:	78 47                	js     8016d9 <ftruncate+0x7a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801692:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801695:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801699:	75 21                	jne    8016bc <ftruncate+0x5d>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80169b:	a1 20 44 80 00       	mov    0x804420,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8016a0:	8b 40 48             	mov    0x48(%eax),%eax
  8016a3:	83 ec 04             	sub    $0x4,%esp
  8016a6:	53                   	push   %ebx
  8016a7:	50                   	push   %eax
  8016a8:	68 70 29 80 00       	push   $0x802970
  8016ad:	e8 4e ec ff ff       	call   800300 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8016b2:	83 c4 10             	add    $0x10,%esp
  8016b5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8016ba:	eb 1d                	jmp    8016d9 <ftruncate+0x7a>
	}
	if (!dev->dev_trunc)
  8016bc:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8016bf:	8b 52 18             	mov    0x18(%edx),%edx
  8016c2:	85 d2                	test   %edx,%edx
  8016c4:	74 0e                	je     8016d4 <ftruncate+0x75>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8016c6:	83 ec 08             	sub    $0x8,%esp
  8016c9:	ff 75 0c             	pushl  0xc(%ebp)
  8016cc:	50                   	push   %eax
  8016cd:	ff d2                	call   *%edx
  8016cf:	83 c4 10             	add    $0x10,%esp
  8016d2:	eb 05                	jmp    8016d9 <ftruncate+0x7a>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8016d4:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  8016d9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016dc:	c9                   	leave  
  8016dd:	c3                   	ret    

008016de <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8016de:	55                   	push   %ebp
  8016df:	89 e5                	mov    %esp,%ebp
  8016e1:	53                   	push   %ebx
  8016e2:	83 ec 14             	sub    $0x14,%esp
  8016e5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016e8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016eb:	50                   	push   %eax
  8016ec:	ff 75 08             	pushl  0x8(%ebp)
  8016ef:	e8 63 fb ff ff       	call   801257 <fd_lookup>
  8016f4:	83 c4 08             	add    $0x8,%esp
  8016f7:	85 c0                	test   %eax,%eax
  8016f9:	78 52                	js     80174d <fstat+0x6f>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016fb:	83 ec 08             	sub    $0x8,%esp
  8016fe:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801701:	50                   	push   %eax
  801702:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801705:	ff 30                	pushl  (%eax)
  801707:	e8 a1 fb ff ff       	call   8012ad <dev_lookup>
  80170c:	83 c4 10             	add    $0x10,%esp
  80170f:	85 c0                	test   %eax,%eax
  801711:	78 3a                	js     80174d <fstat+0x6f>
		return r;
	if (!dev->dev_stat)
  801713:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801716:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80171a:	74 2c                	je     801748 <fstat+0x6a>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80171c:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80171f:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801726:	00 00 00 
	stat->st_isdir = 0;
  801729:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801730:	00 00 00 
	stat->st_dev = dev;
  801733:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801739:	83 ec 08             	sub    $0x8,%esp
  80173c:	53                   	push   %ebx
  80173d:	ff 75 f0             	pushl  -0x10(%ebp)
  801740:	ff 50 14             	call   *0x14(%eax)
  801743:	83 c4 10             	add    $0x10,%esp
  801746:	eb 05                	jmp    80174d <fstat+0x6f>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801748:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  80174d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801750:	c9                   	leave  
  801751:	c3                   	ret    

00801752 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801752:	55                   	push   %ebp
  801753:	89 e5                	mov    %esp,%ebp
  801755:	56                   	push   %esi
  801756:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801757:	83 ec 08             	sub    $0x8,%esp
  80175a:	6a 00                	push   $0x0
  80175c:	ff 75 08             	pushl  0x8(%ebp)
  80175f:	e8 78 01 00 00       	call   8018dc <open>
  801764:	89 c3                	mov    %eax,%ebx
  801766:	83 c4 10             	add    $0x10,%esp
  801769:	85 c0                	test   %eax,%eax
  80176b:	78 1b                	js     801788 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  80176d:	83 ec 08             	sub    $0x8,%esp
  801770:	ff 75 0c             	pushl  0xc(%ebp)
  801773:	50                   	push   %eax
  801774:	e8 65 ff ff ff       	call   8016de <fstat>
  801779:	89 c6                	mov    %eax,%esi
	close(fd);
  80177b:	89 1c 24             	mov    %ebx,(%esp)
  80177e:	e8 18 fc ff ff       	call   80139b <close>
	return r;
  801783:	83 c4 10             	add    $0x10,%esp
  801786:	89 f3                	mov    %esi,%ebx
}
  801788:	89 d8                	mov    %ebx,%eax
  80178a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80178d:	5b                   	pop    %ebx
  80178e:	5e                   	pop    %esi
  80178f:	c9                   	leave  
  801790:	c3                   	ret    
  801791:	00 00                	add    %al,(%eax)
	...

00801794 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801794:	55                   	push   %ebp
  801795:	89 e5                	mov    %esp,%ebp
  801797:	56                   	push   %esi
  801798:	53                   	push   %ebx
  801799:	89 c3                	mov    %eax,%ebx
  80179b:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  80179d:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8017a4:	75 12                	jne    8017b8 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8017a6:	83 ec 0c             	sub    $0xc,%esp
  8017a9:	6a 01                	push   $0x1
  8017ab:	e8 a6 08 00 00       	call   802056 <ipc_find_env>
  8017b0:	a3 00 40 80 00       	mov    %eax,0x804000
  8017b5:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8017b8:	6a 07                	push   $0x7
  8017ba:	68 00 50 80 00       	push   $0x805000
  8017bf:	53                   	push   %ebx
  8017c0:	ff 35 00 40 80 00    	pushl  0x804000
  8017c6:	e8 36 08 00 00       	call   802001 <ipc_send>
	
	return ipc_recv(NULL, dstva, NULL);
  8017cb:	83 c4 0c             	add    $0xc,%esp
  8017ce:	6a 00                	push   $0x0
  8017d0:	56                   	push   %esi
  8017d1:	6a 00                	push   $0x0
  8017d3:	e8 b4 07 00 00       	call   801f8c <ipc_recv>
}
  8017d8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017db:	5b                   	pop    %ebx
  8017dc:	5e                   	pop    %esi
  8017dd:	c9                   	leave  
  8017de:	c3                   	ret    

008017df <devfile_stat>:
}


static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8017df:	55                   	push   %ebp
  8017e0:	89 e5                	mov    %esp,%ebp
  8017e2:	53                   	push   %ebx
  8017e3:	83 ec 04             	sub    $0x4,%esp
  8017e6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8017e9:	8b 45 08             	mov    0x8(%ebp),%eax
  8017ec:	8b 40 0c             	mov    0xc(%eax),%eax
  8017ef:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0) {
  8017f4:	ba 00 00 00 00       	mov    $0x0,%edx
  8017f9:	b8 05 00 00 00       	mov    $0x5,%eax
  8017fe:	e8 91 ff ff ff       	call   801794 <fsipc>
  801803:	85 c0                	test   %eax,%eax
  801805:	78 2c                	js     801833 <devfile_stat+0x54>
		return r;
	}
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801807:	83 ec 08             	sub    $0x8,%esp
  80180a:	68 00 50 80 00       	push   $0x805000
  80180f:	53                   	push   %ebx
  801810:	e8 a1 f0 ff ff       	call   8008b6 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801815:	a1 80 50 80 00       	mov    0x805080,%eax
  80181a:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801820:	a1 84 50 80 00       	mov    0x805084,%eax
  801825:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80182b:	83 c4 10             	add    $0x10,%esp
  80182e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801833:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801836:	c9                   	leave  
  801837:	c3                   	ret    

00801838 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801838:	55                   	push   %ebp
  801839:	89 e5                	mov    %esp,%ebp
  80183b:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80183e:	8b 45 08             	mov    0x8(%ebp),%eax
  801841:	8b 40 0c             	mov    0xc(%eax),%eax
  801844:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801849:	ba 00 00 00 00       	mov    $0x0,%edx
  80184e:	b8 06 00 00 00       	mov    $0x6,%eax
  801853:	e8 3c ff ff ff       	call   801794 <fsipc>
}
  801858:	c9                   	leave  
  801859:	c3                   	ret    

0080185a <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  80185a:	55                   	push   %ebp
  80185b:	89 e5                	mov    %esp,%ebp
  80185d:	56                   	push   %esi
  80185e:	53                   	push   %ebx
  80185f:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801862:	8b 45 08             	mov    0x8(%ebp),%eax
  801865:	8b 40 0c             	mov    0xc(%eax),%eax
  801868:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  80186d:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801873:	ba 00 00 00 00       	mov    $0x0,%edx
  801878:	b8 03 00 00 00       	mov    $0x3,%eax
  80187d:	e8 12 ff ff ff       	call   801794 <fsipc>
  801882:	89 c3                	mov    %eax,%ebx
  801884:	85 c0                	test   %eax,%eax
  801886:	78 4b                	js     8018d3 <devfile_read+0x79>
		return r;
	assert(r <= n);
  801888:	39 c6                	cmp    %eax,%esi
  80188a:	73 16                	jae    8018a2 <devfile_read+0x48>
  80188c:	68 dc 29 80 00       	push   $0x8029dc
  801891:	68 e3 29 80 00       	push   $0x8029e3
  801896:	6a 7d                	push   $0x7d
  801898:	68 f8 29 80 00       	push   $0x8029f8
  80189d:	e8 86 e9 ff ff       	call   800228 <_panic>
	assert(r <= PGSIZE);
  8018a2:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8018a7:	7e 16                	jle    8018bf <devfile_read+0x65>
  8018a9:	68 03 2a 80 00       	push   $0x802a03
  8018ae:	68 e3 29 80 00       	push   $0x8029e3
  8018b3:	6a 7e                	push   $0x7e
  8018b5:	68 f8 29 80 00       	push   $0x8029f8
  8018ba:	e8 69 e9 ff ff       	call   800228 <_panic>
	memmove(buf, &fsipcbuf, r);
  8018bf:	83 ec 04             	sub    $0x4,%esp
  8018c2:	50                   	push   %eax
  8018c3:	68 00 50 80 00       	push   $0x805000
  8018c8:	ff 75 0c             	pushl  0xc(%ebp)
  8018cb:	e8 a7 f1 ff ff       	call   800a77 <memmove>
	return r;
  8018d0:	83 c4 10             	add    $0x10,%esp
}
  8018d3:	89 d8                	mov    %ebx,%eax
  8018d5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018d8:	5b                   	pop    %ebx
  8018d9:	5e                   	pop    %esi
  8018da:	c9                   	leave  
  8018db:	c3                   	ret    

008018dc <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8018dc:	55                   	push   %ebp
  8018dd:	89 e5                	mov    %esp,%ebp
  8018df:	56                   	push   %esi
  8018e0:	53                   	push   %ebx
  8018e1:	83 ec 1c             	sub    $0x1c,%esp
  8018e4:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8018e7:	56                   	push   %esi
  8018e8:	e8 77 ef ff ff       	call   800864 <strlen>
  8018ed:	83 c4 10             	add    $0x10,%esp
  8018f0:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8018f5:	7f 65                	jg     80195c <open+0x80>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8018f7:	83 ec 0c             	sub    $0xc,%esp
  8018fa:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018fd:	50                   	push   %eax
  8018fe:	e8 e1 f8 ff ff       	call   8011e4 <fd_alloc>
  801903:	89 c3                	mov    %eax,%ebx
  801905:	83 c4 10             	add    $0x10,%esp
  801908:	85 c0                	test   %eax,%eax
  80190a:	78 55                	js     801961 <open+0x85>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  80190c:	83 ec 08             	sub    $0x8,%esp
  80190f:	56                   	push   %esi
  801910:	68 00 50 80 00       	push   $0x805000
  801915:	e8 9c ef ff ff       	call   8008b6 <strcpy>
	fsipcbuf.open.req_omode = mode;
  80191a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80191d:	a3 00 54 80 00       	mov    %eax,0x805400



	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801922:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801925:	b8 01 00 00 00       	mov    $0x1,%eax
  80192a:	e8 65 fe ff ff       	call   801794 <fsipc>
  80192f:	89 c3                	mov    %eax,%ebx
  801931:	83 c4 10             	add    $0x10,%esp
  801934:	85 c0                	test   %eax,%eax
  801936:	79 12                	jns    80194a <open+0x6e>
		fd_close(fd, 0);
  801938:	83 ec 08             	sub    $0x8,%esp
  80193b:	6a 00                	push   $0x0
  80193d:	ff 75 f4             	pushl  -0xc(%ebp)
  801940:	e8 ce f9 ff ff       	call   801313 <fd_close>
		return r;
  801945:	83 c4 10             	add    $0x10,%esp
  801948:	eb 17                	jmp    801961 <open+0x85>
	}

	return fd2num(fd);
  80194a:	83 ec 0c             	sub    $0xc,%esp
  80194d:	ff 75 f4             	pushl  -0xc(%ebp)
  801950:	e8 67 f8 ff ff       	call   8011bc <fd2num>
  801955:	89 c3                	mov    %eax,%ebx
  801957:	83 c4 10             	add    $0x10,%esp
  80195a:	eb 05                	jmp    801961 <open+0x85>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  80195c:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801961:	89 d8                	mov    %ebx,%eax
  801963:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801966:	5b                   	pop    %ebx
  801967:	5e                   	pop    %esi
  801968:	c9                   	leave  
  801969:	c3                   	ret    
	...

0080196c <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  80196c:	55                   	push   %ebp
  80196d:	89 e5                	mov    %esp,%ebp
  80196f:	56                   	push   %esi
  801970:	53                   	push   %ebx
  801971:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801974:	83 ec 0c             	sub    $0xc,%esp
  801977:	ff 75 08             	pushl  0x8(%ebp)
  80197a:	e8 4d f8 ff ff       	call   8011cc <fd2data>
  80197f:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  801981:	83 c4 08             	add    $0x8,%esp
  801984:	68 0f 2a 80 00       	push   $0x802a0f
  801989:	56                   	push   %esi
  80198a:	e8 27 ef ff ff       	call   8008b6 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  80198f:	8b 43 04             	mov    0x4(%ebx),%eax
  801992:	2b 03                	sub    (%ebx),%eax
  801994:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  80199a:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  8019a1:	00 00 00 
	stat->st_dev = &devpipe;
  8019a4:	c7 86 88 00 00 00 20 	movl   $0x803020,0x88(%esi)
  8019ab:	30 80 00 
	return 0;
}
  8019ae:	b8 00 00 00 00       	mov    $0x0,%eax
  8019b3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8019b6:	5b                   	pop    %ebx
  8019b7:	5e                   	pop    %esi
  8019b8:	c9                   	leave  
  8019b9:	c3                   	ret    

008019ba <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8019ba:	55                   	push   %ebp
  8019bb:	89 e5                	mov    %esp,%ebp
  8019bd:	53                   	push   %ebx
  8019be:	83 ec 0c             	sub    $0xc,%esp
  8019c1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8019c4:	53                   	push   %ebx
  8019c5:	6a 00                	push   $0x0
  8019c7:	e8 b6 f3 ff ff       	call   800d82 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8019cc:	89 1c 24             	mov    %ebx,(%esp)
  8019cf:	e8 f8 f7 ff ff       	call   8011cc <fd2data>
  8019d4:	83 c4 08             	add    $0x8,%esp
  8019d7:	50                   	push   %eax
  8019d8:	6a 00                	push   $0x0
  8019da:	e8 a3 f3 ff ff       	call   800d82 <sys_page_unmap>
}
  8019df:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019e2:	c9                   	leave  
  8019e3:	c3                   	ret    

008019e4 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8019e4:	55                   	push   %ebp
  8019e5:	89 e5                	mov    %esp,%ebp
  8019e7:	57                   	push   %edi
  8019e8:	56                   	push   %esi
  8019e9:	53                   	push   %ebx
  8019ea:	83 ec 1c             	sub    $0x1c,%esp
  8019ed:	89 c7                	mov    %eax,%edi
  8019ef:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8019f2:	a1 20 44 80 00       	mov    0x804420,%eax
  8019f7:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  8019fa:	83 ec 0c             	sub    $0xc,%esp
  8019fd:	57                   	push   %edi
  8019fe:	e8 b1 06 00 00       	call   8020b4 <pageref>
  801a03:	89 c6                	mov    %eax,%esi
  801a05:	83 c4 04             	add    $0x4,%esp
  801a08:	ff 75 e4             	pushl  -0x1c(%ebp)
  801a0b:	e8 a4 06 00 00       	call   8020b4 <pageref>
  801a10:	83 c4 10             	add    $0x10,%esp
  801a13:	39 c6                	cmp    %eax,%esi
  801a15:	0f 94 c0             	sete   %al
  801a18:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  801a1b:	8b 15 20 44 80 00    	mov    0x804420,%edx
  801a21:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801a24:	39 cb                	cmp    %ecx,%ebx
  801a26:	75 08                	jne    801a30 <_pipeisclosed+0x4c>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  801a28:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a2b:	5b                   	pop    %ebx
  801a2c:	5e                   	pop    %esi
  801a2d:	5f                   	pop    %edi
  801a2e:	c9                   	leave  
  801a2f:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  801a30:	83 f8 01             	cmp    $0x1,%eax
  801a33:	75 bd                	jne    8019f2 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801a35:	8b 42 58             	mov    0x58(%edx),%eax
  801a38:	6a 01                	push   $0x1
  801a3a:	50                   	push   %eax
  801a3b:	53                   	push   %ebx
  801a3c:	68 16 2a 80 00       	push   $0x802a16
  801a41:	e8 ba e8 ff ff       	call   800300 <cprintf>
  801a46:	83 c4 10             	add    $0x10,%esp
  801a49:	eb a7                	jmp    8019f2 <_pipeisclosed+0xe>

00801a4b <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801a4b:	55                   	push   %ebp
  801a4c:	89 e5                	mov    %esp,%ebp
  801a4e:	57                   	push   %edi
  801a4f:	56                   	push   %esi
  801a50:	53                   	push   %ebx
  801a51:	83 ec 28             	sub    $0x28,%esp
  801a54:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801a57:	56                   	push   %esi
  801a58:	e8 6f f7 ff ff       	call   8011cc <fd2data>
  801a5d:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801a5f:	83 c4 10             	add    $0x10,%esp
  801a62:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801a66:	75 4a                	jne    801ab2 <devpipe_write+0x67>
  801a68:	bf 00 00 00 00       	mov    $0x0,%edi
  801a6d:	eb 56                	jmp    801ac5 <devpipe_write+0x7a>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801a6f:	89 da                	mov    %ebx,%edx
  801a71:	89 f0                	mov    %esi,%eax
  801a73:	e8 6c ff ff ff       	call   8019e4 <_pipeisclosed>
  801a78:	85 c0                	test   %eax,%eax
  801a7a:	75 4d                	jne    801ac9 <devpipe_write+0x7e>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801a7c:	e8 90 f2 ff ff       	call   800d11 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801a81:	8b 43 04             	mov    0x4(%ebx),%eax
  801a84:	8b 13                	mov    (%ebx),%edx
  801a86:	83 c2 20             	add    $0x20,%edx
  801a89:	39 d0                	cmp    %edx,%eax
  801a8b:	73 e2                	jae    801a6f <devpipe_write+0x24>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801a8d:	89 c2                	mov    %eax,%edx
  801a8f:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  801a95:	79 05                	jns    801a9c <devpipe_write+0x51>
  801a97:	4a                   	dec    %edx
  801a98:	83 ca e0             	or     $0xffffffe0,%edx
  801a9b:	42                   	inc    %edx
  801a9c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801a9f:	8a 0c 39             	mov    (%ecx,%edi,1),%cl
  801aa2:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801aa6:	40                   	inc    %eax
  801aa7:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801aaa:	47                   	inc    %edi
  801aab:	39 7d 10             	cmp    %edi,0x10(%ebp)
  801aae:	77 07                	ja     801ab7 <devpipe_write+0x6c>
  801ab0:	eb 13                	jmp    801ac5 <devpipe_write+0x7a>
  801ab2:	bf 00 00 00 00       	mov    $0x0,%edi
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801ab7:	8b 43 04             	mov    0x4(%ebx),%eax
  801aba:	8b 13                	mov    (%ebx),%edx
  801abc:	83 c2 20             	add    $0x20,%edx
  801abf:	39 d0                	cmp    %edx,%eax
  801ac1:	73 ac                	jae    801a6f <devpipe_write+0x24>
  801ac3:	eb c8                	jmp    801a8d <devpipe_write+0x42>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801ac5:	89 f8                	mov    %edi,%eax
  801ac7:	eb 05                	jmp    801ace <devpipe_write+0x83>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801ac9:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801ace:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ad1:	5b                   	pop    %ebx
  801ad2:	5e                   	pop    %esi
  801ad3:	5f                   	pop    %edi
  801ad4:	c9                   	leave  
  801ad5:	c3                   	ret    

00801ad6 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801ad6:	55                   	push   %ebp
  801ad7:	89 e5                	mov    %esp,%ebp
  801ad9:	57                   	push   %edi
  801ada:	56                   	push   %esi
  801adb:	53                   	push   %ebx
  801adc:	83 ec 18             	sub    $0x18,%esp
  801adf:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801ae2:	57                   	push   %edi
  801ae3:	e8 e4 f6 ff ff       	call   8011cc <fd2data>
  801ae8:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801aea:	83 c4 10             	add    $0x10,%esp
  801aed:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801af1:	75 44                	jne    801b37 <devpipe_read+0x61>
  801af3:	be 00 00 00 00       	mov    $0x0,%esi
  801af8:	eb 4f                	jmp    801b49 <devpipe_read+0x73>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
				return i;
  801afa:	89 f0                	mov    %esi,%eax
  801afc:	eb 54                	jmp    801b52 <devpipe_read+0x7c>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801afe:	89 da                	mov    %ebx,%edx
  801b00:	89 f8                	mov    %edi,%eax
  801b02:	e8 dd fe ff ff       	call   8019e4 <_pipeisclosed>
  801b07:	85 c0                	test   %eax,%eax
  801b09:	75 42                	jne    801b4d <devpipe_read+0x77>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801b0b:	e8 01 f2 ff ff       	call   800d11 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801b10:	8b 03                	mov    (%ebx),%eax
  801b12:	3b 43 04             	cmp    0x4(%ebx),%eax
  801b15:	74 e7                	je     801afe <devpipe_read+0x28>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801b17:	25 1f 00 00 80       	and    $0x8000001f,%eax
  801b1c:	79 05                	jns    801b23 <devpipe_read+0x4d>
  801b1e:	48                   	dec    %eax
  801b1f:	83 c8 e0             	or     $0xffffffe0,%eax
  801b22:	40                   	inc    %eax
  801b23:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  801b27:	8b 55 0c             	mov    0xc(%ebp),%edx
  801b2a:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  801b2d:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b2f:	46                   	inc    %esi
  801b30:	39 75 10             	cmp    %esi,0x10(%ebp)
  801b33:	77 07                	ja     801b3c <devpipe_read+0x66>
  801b35:	eb 12                	jmp    801b49 <devpipe_read+0x73>
  801b37:	be 00 00 00 00       	mov    $0x0,%esi
		while (p->p_rpos == p->p_wpos) {
  801b3c:	8b 03                	mov    (%ebx),%eax
  801b3e:	3b 43 04             	cmp    0x4(%ebx),%eax
  801b41:	75 d4                	jne    801b17 <devpipe_read+0x41>
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801b43:	85 f6                	test   %esi,%esi
  801b45:	75 b3                	jne    801afa <devpipe_read+0x24>
  801b47:	eb b5                	jmp    801afe <devpipe_read+0x28>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801b49:	89 f0                	mov    %esi,%eax
  801b4b:	eb 05                	jmp    801b52 <devpipe_read+0x7c>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801b4d:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801b52:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b55:	5b                   	pop    %ebx
  801b56:	5e                   	pop    %esi
  801b57:	5f                   	pop    %edi
  801b58:	c9                   	leave  
  801b59:	c3                   	ret    

00801b5a <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801b5a:	55                   	push   %ebp
  801b5b:	89 e5                	mov    %esp,%ebp
  801b5d:	57                   	push   %edi
  801b5e:	56                   	push   %esi
  801b5f:	53                   	push   %ebx
  801b60:	83 ec 28             	sub    $0x28,%esp
  801b63:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801b66:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801b69:	50                   	push   %eax
  801b6a:	e8 75 f6 ff ff       	call   8011e4 <fd_alloc>
  801b6f:	89 c3                	mov    %eax,%ebx
  801b71:	83 c4 10             	add    $0x10,%esp
  801b74:	85 c0                	test   %eax,%eax
  801b76:	0f 88 24 01 00 00    	js     801ca0 <pipe+0x146>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b7c:	83 ec 04             	sub    $0x4,%esp
  801b7f:	68 07 04 00 00       	push   $0x407
  801b84:	ff 75 e4             	pushl  -0x1c(%ebp)
  801b87:	6a 00                	push   $0x0
  801b89:	e8 aa f1 ff ff       	call   800d38 <sys_page_alloc>
  801b8e:	89 c3                	mov    %eax,%ebx
  801b90:	83 c4 10             	add    $0x10,%esp
  801b93:	85 c0                	test   %eax,%eax
  801b95:	0f 88 05 01 00 00    	js     801ca0 <pipe+0x146>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801b9b:	83 ec 0c             	sub    $0xc,%esp
  801b9e:	8d 45 e0             	lea    -0x20(%ebp),%eax
  801ba1:	50                   	push   %eax
  801ba2:	e8 3d f6 ff ff       	call   8011e4 <fd_alloc>
  801ba7:	89 c3                	mov    %eax,%ebx
  801ba9:	83 c4 10             	add    $0x10,%esp
  801bac:	85 c0                	test   %eax,%eax
  801bae:	0f 88 dc 00 00 00    	js     801c90 <pipe+0x136>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801bb4:	83 ec 04             	sub    $0x4,%esp
  801bb7:	68 07 04 00 00       	push   $0x407
  801bbc:	ff 75 e0             	pushl  -0x20(%ebp)
  801bbf:	6a 00                	push   $0x0
  801bc1:	e8 72 f1 ff ff       	call   800d38 <sys_page_alloc>
  801bc6:	89 c3                	mov    %eax,%ebx
  801bc8:	83 c4 10             	add    $0x10,%esp
  801bcb:	85 c0                	test   %eax,%eax
  801bcd:	0f 88 bd 00 00 00    	js     801c90 <pipe+0x136>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801bd3:	83 ec 0c             	sub    $0xc,%esp
  801bd6:	ff 75 e4             	pushl  -0x1c(%ebp)
  801bd9:	e8 ee f5 ff ff       	call   8011cc <fd2data>
  801bde:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801be0:	83 c4 0c             	add    $0xc,%esp
  801be3:	68 07 04 00 00       	push   $0x407
  801be8:	50                   	push   %eax
  801be9:	6a 00                	push   $0x0
  801beb:	e8 48 f1 ff ff       	call   800d38 <sys_page_alloc>
  801bf0:	89 c3                	mov    %eax,%ebx
  801bf2:	83 c4 10             	add    $0x10,%esp
  801bf5:	85 c0                	test   %eax,%eax
  801bf7:	0f 88 83 00 00 00    	js     801c80 <pipe+0x126>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801bfd:	83 ec 0c             	sub    $0xc,%esp
  801c00:	ff 75 e0             	pushl  -0x20(%ebp)
  801c03:	e8 c4 f5 ff ff       	call   8011cc <fd2data>
  801c08:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801c0f:	50                   	push   %eax
  801c10:	6a 00                	push   $0x0
  801c12:	56                   	push   %esi
  801c13:	6a 00                	push   $0x0
  801c15:	e8 42 f1 ff ff       	call   800d5c <sys_page_map>
  801c1a:	89 c3                	mov    %eax,%ebx
  801c1c:	83 c4 20             	add    $0x20,%esp
  801c1f:	85 c0                	test   %eax,%eax
  801c21:	78 4f                	js     801c72 <pipe+0x118>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801c23:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801c29:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801c2c:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801c2e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801c31:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801c38:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801c3e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801c41:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801c43:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801c46:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801c4d:	83 ec 0c             	sub    $0xc,%esp
  801c50:	ff 75 e4             	pushl  -0x1c(%ebp)
  801c53:	e8 64 f5 ff ff       	call   8011bc <fd2num>
  801c58:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  801c5a:	83 c4 04             	add    $0x4,%esp
  801c5d:	ff 75 e0             	pushl  -0x20(%ebp)
  801c60:	e8 57 f5 ff ff       	call   8011bc <fd2num>
  801c65:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  801c68:	83 c4 10             	add    $0x10,%esp
  801c6b:	bb 00 00 00 00       	mov    $0x0,%ebx
  801c70:	eb 2e                	jmp    801ca0 <pipe+0x146>

    err3:
	sys_page_unmap(0, va);
  801c72:	83 ec 08             	sub    $0x8,%esp
  801c75:	56                   	push   %esi
  801c76:	6a 00                	push   $0x0
  801c78:	e8 05 f1 ff ff       	call   800d82 <sys_page_unmap>
  801c7d:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801c80:	83 ec 08             	sub    $0x8,%esp
  801c83:	ff 75 e0             	pushl  -0x20(%ebp)
  801c86:	6a 00                	push   $0x0
  801c88:	e8 f5 f0 ff ff       	call   800d82 <sys_page_unmap>
  801c8d:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801c90:	83 ec 08             	sub    $0x8,%esp
  801c93:	ff 75 e4             	pushl  -0x1c(%ebp)
  801c96:	6a 00                	push   $0x0
  801c98:	e8 e5 f0 ff ff       	call   800d82 <sys_page_unmap>
  801c9d:	83 c4 10             	add    $0x10,%esp
    err:
	return r;
}
  801ca0:	89 d8                	mov    %ebx,%eax
  801ca2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ca5:	5b                   	pop    %ebx
  801ca6:	5e                   	pop    %esi
  801ca7:	5f                   	pop    %edi
  801ca8:	c9                   	leave  
  801ca9:	c3                   	ret    

00801caa <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801caa:	55                   	push   %ebp
  801cab:	89 e5                	mov    %esp,%ebp
  801cad:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801cb0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801cb3:	50                   	push   %eax
  801cb4:	ff 75 08             	pushl  0x8(%ebp)
  801cb7:	e8 9b f5 ff ff       	call   801257 <fd_lookup>
  801cbc:	83 c4 10             	add    $0x10,%esp
  801cbf:	85 c0                	test   %eax,%eax
  801cc1:	78 18                	js     801cdb <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801cc3:	83 ec 0c             	sub    $0xc,%esp
  801cc6:	ff 75 f4             	pushl  -0xc(%ebp)
  801cc9:	e8 fe f4 ff ff       	call   8011cc <fd2data>
	return _pipeisclosed(fd, p);
  801cce:	89 c2                	mov    %eax,%edx
  801cd0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cd3:	e8 0c fd ff ff       	call   8019e4 <_pipeisclosed>
  801cd8:	83 c4 10             	add    $0x10,%esp
}
  801cdb:	c9                   	leave  
  801cdc:	c3                   	ret    
  801cdd:	00 00                	add    %al,(%eax)
	...

00801ce0 <wait>:
#include <inc/lib.h>

// Waits until 'envid' exits.
void
wait(envid_t envid)
{
  801ce0:	55                   	push   %ebp
  801ce1:	89 e5                	mov    %esp,%ebp
  801ce3:	57                   	push   %edi
  801ce4:	56                   	push   %esi
  801ce5:	53                   	push   %ebx
  801ce6:	83 ec 0c             	sub    $0xc,%esp
  801ce9:	8b 45 08             	mov    0x8(%ebp),%eax
	const volatile struct Env *e;

	assert(envid != 0);
  801cec:	85 c0                	test   %eax,%eax
  801cee:	75 16                	jne    801d06 <wait+0x26>
  801cf0:	68 2e 2a 80 00       	push   $0x802a2e
  801cf5:	68 e3 29 80 00       	push   $0x8029e3
  801cfa:	6a 09                	push   $0x9
  801cfc:	68 39 2a 80 00       	push   $0x802a39
  801d01:	e8 22 e5 ff ff       	call   800228 <_panic>
	e = &envs[ENVX(envid)];
  801d06:	89 c6                	mov    %eax,%esi
  801d08:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
	while (e->env_id == envid && e->env_status != ENV_FREE)
  801d0e:	8d 0c b5 00 00 00 00 	lea    0x0(,%esi,4),%ecx
  801d15:	89 f2                	mov    %esi,%edx
  801d17:	c1 e2 07             	shl    $0x7,%edx
  801d1a:	29 ca                	sub    %ecx,%edx
  801d1c:	81 c2 08 00 c0 ee    	add    $0xeec00008,%edx
  801d22:	8b 7a 40             	mov    0x40(%edx),%edi
  801d25:	39 c7                	cmp    %eax,%edi
  801d27:	75 37                	jne    801d60 <wait+0x80>
  801d29:	89 f0                	mov    %esi,%eax
  801d2b:	c1 e0 07             	shl    $0x7,%eax
  801d2e:	29 c8                	sub    %ecx,%eax
  801d30:	05 04 00 c0 ee       	add    $0xeec00004,%eax
  801d35:	8b 40 50             	mov    0x50(%eax),%eax
  801d38:	85 c0                	test   %eax,%eax
  801d3a:	74 24                	je     801d60 <wait+0x80>
  801d3c:	c1 e6 07             	shl    $0x7,%esi
  801d3f:	29 ce                	sub    %ecx,%esi
  801d41:	8d 9e 08 00 c0 ee    	lea    -0x113ffff8(%esi),%ebx
  801d47:	81 c6 04 00 c0 ee    	add    $0xeec00004,%esi
		sys_yield();
  801d4d:	e8 bf ef ff ff       	call   800d11 <sys_yield>
{
	const volatile struct Env *e;

	assert(envid != 0);
	e = &envs[ENVX(envid)];
	while (e->env_id == envid && e->env_status != ENV_FREE)
  801d52:	8b 43 40             	mov    0x40(%ebx),%eax
  801d55:	39 f8                	cmp    %edi,%eax
  801d57:	75 07                	jne    801d60 <wait+0x80>
  801d59:	8b 46 50             	mov    0x50(%esi),%eax
  801d5c:	85 c0                	test   %eax,%eax
  801d5e:	75 ed                	jne    801d4d <wait+0x6d>
		sys_yield();
}
  801d60:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d63:	5b                   	pop    %ebx
  801d64:	5e                   	pop    %esi
  801d65:	5f                   	pop    %edi
  801d66:	c9                   	leave  
  801d67:	c3                   	ret    

00801d68 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801d68:	55                   	push   %ebp
  801d69:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801d6b:	b8 00 00 00 00       	mov    $0x0,%eax
  801d70:	c9                   	leave  
  801d71:	c3                   	ret    

00801d72 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801d72:	55                   	push   %ebp
  801d73:	89 e5                	mov    %esp,%ebp
  801d75:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801d78:	68 44 2a 80 00       	push   $0x802a44
  801d7d:	ff 75 0c             	pushl  0xc(%ebp)
  801d80:	e8 31 eb ff ff       	call   8008b6 <strcpy>
	return 0;
}
  801d85:	b8 00 00 00 00       	mov    $0x0,%eax
  801d8a:	c9                   	leave  
  801d8b:	c3                   	ret    

00801d8c <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801d8c:	55                   	push   %ebp
  801d8d:	89 e5                	mov    %esp,%ebp
  801d8f:	57                   	push   %edi
  801d90:	56                   	push   %esi
  801d91:	53                   	push   %ebx
  801d92:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801d98:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801d9c:	74 45                	je     801de3 <devcons_write+0x57>
  801d9e:	b8 00 00 00 00       	mov    $0x0,%eax
  801da3:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801da8:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801dae:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801db1:	29 c3                	sub    %eax,%ebx
		if (m > sizeof(buf) - 1)
  801db3:	83 fb 7f             	cmp    $0x7f,%ebx
  801db6:	76 05                	jbe    801dbd <devcons_write+0x31>
			m = sizeof(buf) - 1;
  801db8:	bb 7f 00 00 00       	mov    $0x7f,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  801dbd:	83 ec 04             	sub    $0x4,%esp
  801dc0:	53                   	push   %ebx
  801dc1:	03 45 0c             	add    0xc(%ebp),%eax
  801dc4:	50                   	push   %eax
  801dc5:	57                   	push   %edi
  801dc6:	e8 ac ec ff ff       	call   800a77 <memmove>
		sys_cputs(buf, m);
  801dcb:	83 c4 08             	add    $0x8,%esp
  801dce:	53                   	push   %ebx
  801dcf:	57                   	push   %edi
  801dd0:	e8 ac ee ff ff       	call   800c81 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801dd5:	01 de                	add    %ebx,%esi
  801dd7:	89 f0                	mov    %esi,%eax
  801dd9:	83 c4 10             	add    $0x10,%esp
  801ddc:	3b 75 10             	cmp    0x10(%ebp),%esi
  801ddf:	72 cd                	jb     801dae <devcons_write+0x22>
  801de1:	eb 05                	jmp    801de8 <devcons_write+0x5c>
  801de3:	be 00 00 00 00       	mov    $0x0,%esi
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801de8:	89 f0                	mov    %esi,%eax
  801dea:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ded:	5b                   	pop    %ebx
  801dee:	5e                   	pop    %esi
  801def:	5f                   	pop    %edi
  801df0:	c9                   	leave  
  801df1:	c3                   	ret    

00801df2 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801df2:	55                   	push   %ebp
  801df3:	89 e5                	mov    %esp,%ebp
  801df5:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  801df8:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801dfc:	75 07                	jne    801e05 <devcons_read+0x13>
  801dfe:	eb 25                	jmp    801e25 <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801e00:	e8 0c ef ff ff       	call   800d11 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801e05:	e8 9d ee ff ff       	call   800ca7 <sys_cgetc>
  801e0a:	85 c0                	test   %eax,%eax
  801e0c:	74 f2                	je     801e00 <devcons_read+0xe>
  801e0e:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  801e10:	85 c0                	test   %eax,%eax
  801e12:	78 1d                	js     801e31 <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801e14:	83 f8 04             	cmp    $0x4,%eax
  801e17:	74 13                	je     801e2c <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  801e19:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e1c:	88 10                	mov    %dl,(%eax)
	return 1;
  801e1e:	b8 01 00 00 00       	mov    $0x1,%eax
  801e23:	eb 0c                	jmp    801e31 <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  801e25:	b8 00 00 00 00       	mov    $0x0,%eax
  801e2a:	eb 05                	jmp    801e31 <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801e2c:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801e31:	c9                   	leave  
  801e32:	c3                   	ret    

00801e33 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801e33:	55                   	push   %ebp
  801e34:	89 e5                	mov    %esp,%ebp
  801e36:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801e39:	8b 45 08             	mov    0x8(%ebp),%eax
  801e3c:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801e3f:	6a 01                	push   $0x1
  801e41:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801e44:	50                   	push   %eax
  801e45:	e8 37 ee ff ff       	call   800c81 <sys_cputs>
  801e4a:	83 c4 10             	add    $0x10,%esp
}
  801e4d:	c9                   	leave  
  801e4e:	c3                   	ret    

00801e4f <getchar>:

int
getchar(void)
{
  801e4f:	55                   	push   %ebp
  801e50:	89 e5                	mov    %esp,%ebp
  801e52:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801e55:	6a 01                	push   $0x1
  801e57:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801e5a:	50                   	push   %eax
  801e5b:	6a 00                	push   $0x0
  801e5d:	e8 76 f6 ff ff       	call   8014d8 <read>
	if (r < 0)
  801e62:	83 c4 10             	add    $0x10,%esp
  801e65:	85 c0                	test   %eax,%eax
  801e67:	78 0f                	js     801e78 <getchar+0x29>
		return r;
	if (r < 1)
  801e69:	85 c0                	test   %eax,%eax
  801e6b:	7e 06                	jle    801e73 <getchar+0x24>
		return -E_EOF;
	return c;
  801e6d:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801e71:	eb 05                	jmp    801e78 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801e73:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801e78:	c9                   	leave  
  801e79:	c3                   	ret    

00801e7a <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801e7a:	55                   	push   %ebp
  801e7b:	89 e5                	mov    %esp,%ebp
  801e7d:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801e80:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e83:	50                   	push   %eax
  801e84:	ff 75 08             	pushl  0x8(%ebp)
  801e87:	e8 cb f3 ff ff       	call   801257 <fd_lookup>
  801e8c:	83 c4 10             	add    $0x10,%esp
  801e8f:	85 c0                	test   %eax,%eax
  801e91:	78 11                	js     801ea4 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801e93:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e96:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801e9c:	39 10                	cmp    %edx,(%eax)
  801e9e:	0f 94 c0             	sete   %al
  801ea1:	0f b6 c0             	movzbl %al,%eax
}
  801ea4:	c9                   	leave  
  801ea5:	c3                   	ret    

00801ea6 <opencons>:

int
opencons(void)
{
  801ea6:	55                   	push   %ebp
  801ea7:	89 e5                	mov    %esp,%ebp
  801ea9:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801eac:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801eaf:	50                   	push   %eax
  801eb0:	e8 2f f3 ff ff       	call   8011e4 <fd_alloc>
  801eb5:	83 c4 10             	add    $0x10,%esp
  801eb8:	85 c0                	test   %eax,%eax
  801eba:	78 3a                	js     801ef6 <opencons+0x50>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801ebc:	83 ec 04             	sub    $0x4,%esp
  801ebf:	68 07 04 00 00       	push   $0x407
  801ec4:	ff 75 f4             	pushl  -0xc(%ebp)
  801ec7:	6a 00                	push   $0x0
  801ec9:	e8 6a ee ff ff       	call   800d38 <sys_page_alloc>
  801ece:	83 c4 10             	add    $0x10,%esp
  801ed1:	85 c0                	test   %eax,%eax
  801ed3:	78 21                	js     801ef6 <opencons+0x50>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801ed5:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801edb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ede:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801ee0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ee3:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801eea:	83 ec 0c             	sub    $0xc,%esp
  801eed:	50                   	push   %eax
  801eee:	e8 c9 f2 ff ff       	call   8011bc <fd2num>
  801ef3:	83 c4 10             	add    $0x10,%esp
}
  801ef6:	c9                   	leave  
  801ef7:	c3                   	ret    

00801ef8 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801ef8:	55                   	push   %ebp
  801ef9:	89 e5                	mov    %esp,%ebp
  801efb:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  801efe:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801f05:	75 52                	jne    801f59 <set_pgfault_handler+0x61>
		// First time through!	
		// LAB 4: Your code here.

		//int sys_page_alloc(envid_t envid, void *va, int perm)
		r = sys_page_alloc(0, (void*)(UXSTACKTOP - PGSIZE), PTE_U | PTE_W | PTE_P);
  801f07:	83 ec 04             	sub    $0x4,%esp
  801f0a:	6a 07                	push   $0x7
  801f0c:	68 00 f0 bf ee       	push   $0xeebff000
  801f11:	6a 00                	push   $0x0
  801f13:	e8 20 ee ff ff       	call   800d38 <sys_page_alloc>
		if (r < 0) {
  801f18:	83 c4 10             	add    $0x10,%esp
  801f1b:	85 c0                	test   %eax,%eax
  801f1d:	79 12                	jns    801f31 <set_pgfault_handler+0x39>
			panic("sys_page_alloc error : %e\n", r);
  801f1f:	50                   	push   %eax
  801f20:	68 50 2a 80 00       	push   $0x802a50
  801f25:	6a 24                	push   $0x24
  801f27:	68 6b 2a 80 00       	push   $0x802a6b
  801f2c:	e8 f7 e2 ff ff       	call   800228 <_panic>
		}

		// how to know envid, put 0, envid2env will help us to get curenv in syscall
		r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);		
  801f31:	83 ec 08             	sub    $0x8,%esp
  801f34:	68 64 1f 80 00       	push   $0x801f64
  801f39:	6a 00                	push   $0x0
  801f3b:	e8 ab ee ff ff       	call   800deb <sys_env_set_pgfault_upcall>
		if (r < 0) {
  801f40:	83 c4 10             	add    $0x10,%esp
  801f43:	85 c0                	test   %eax,%eax
  801f45:	79 12                	jns    801f59 <set_pgfault_handler+0x61>
			panic("sys_env_set_pgfault_upcall error : %e\n", r);
  801f47:	50                   	push   %eax
  801f48:	68 7c 2a 80 00       	push   $0x802a7c
  801f4d:	6a 2a                	push   $0x2a
  801f4f:	68 6b 2a 80 00       	push   $0x802a6b
  801f54:	e8 cf e2 ff ff       	call   800228 <_panic>
		}
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801f59:	8b 45 08             	mov    0x8(%ebp),%eax
  801f5c:	a3 00 60 80 00       	mov    %eax,0x806000
}
  801f61:	c9                   	leave  
  801f62:	c3                   	ret    
	...

00801f64 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801f64:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801f65:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  801f6a:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801f6c:	83 c4 04             	add    $0x4,%esp
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	
	// fix old esp
	movl 0x30(%esp), %eax
  801f6f:	8b 44 24 30          	mov    0x30(%esp),%eax
	subl $0x4, %eax
  801f73:	83 e8 04             	sub    $0x4,%eax
	movl %eax, 0x30(%esp)
  801f76:	89 44 24 30          	mov    %eax,0x30(%esp)

	// set trap-time %eip
	movl 0x28(%esp), %ebx
  801f7a:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	movl %ebx, (%eax)
  801f7e:	89 18                	mov    %ebx,(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $0x08, %esp 	// ignore err_code and fault_va
  801f80:	83 c4 08             	add    $0x8,%esp
	popal 				// restore registers
  801f83:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x04, %esp 	// ignore eip 
  801f84:	83 c4 04             	add    $0x4,%esp
	popfl				// modify eflags
  801f87:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  801f88:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  801f89:	c3                   	ret    
	...

00801f8c <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801f8c:	55                   	push   %ebp
  801f8d:	89 e5                	mov    %esp,%ebp
  801f8f:	56                   	push   %esi
  801f90:	53                   	push   %ebx
  801f91:	8b 75 08             	mov    0x8(%ebp),%esi
  801f94:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f97:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// cprintf("0x%x 0x%x 0x%x\n", (uint32_t)from_env_store, (uint32_t)pg, (uint32_t)perm_store);
	int r;
	if (pg != NULL) {
  801f9a:	85 c0                	test   %eax,%eax
  801f9c:	74 0e                	je     801fac <ipc_recv+0x20>
		r = sys_ipc_recv(pg);
  801f9e:	83 ec 0c             	sub    $0xc,%esp
  801fa1:	50                   	push   %eax
  801fa2:	e8 8c ee ff ff       	call   800e33 <sys_ipc_recv>
  801fa7:	83 c4 10             	add    $0x10,%esp
  801faa:	eb 10                	jmp    801fbc <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv((void *)UTOP);
  801fac:	83 ec 0c             	sub    $0xc,%esp
  801faf:	68 00 00 c0 ee       	push   $0xeec00000
  801fb4:	e8 7a ee ff ff       	call   800e33 <sys_ipc_recv>
  801fb9:	83 c4 10             	add    $0x10,%esp
	}

	if (r == 0) {
  801fbc:	85 c0                	test   %eax,%eax
  801fbe:	75 26                	jne    801fe6 <ipc_recv+0x5a>
		if (from_env_store != NULL) *from_env_store = thisenv->env_ipc_from;
  801fc0:	85 f6                	test   %esi,%esi
  801fc2:	74 0a                	je     801fce <ipc_recv+0x42>
  801fc4:	a1 20 44 80 00       	mov    0x804420,%eax
  801fc9:	8b 40 74             	mov    0x74(%eax),%eax
  801fcc:	89 06                	mov    %eax,(%esi)
		if (perm_store != NULL) *perm_store = thisenv->env_ipc_perm;
  801fce:	85 db                	test   %ebx,%ebx
  801fd0:	74 0a                	je     801fdc <ipc_recv+0x50>
  801fd2:	a1 20 44 80 00       	mov    0x804420,%eax
  801fd7:	8b 40 78             	mov    0x78(%eax),%eax
  801fda:	89 03                	mov    %eax,(%ebx)
		return thisenv->env_ipc_value;
  801fdc:	a1 20 44 80 00       	mov    0x804420,%eax
  801fe1:	8b 40 70             	mov    0x70(%eax),%eax
  801fe4:	eb 14                	jmp    801ffa <ipc_recv+0x6e>
	} else {
		// fails;
		if (from_env_store != NULL) *from_env_store = 0;
  801fe6:	85 f6                	test   %esi,%esi
  801fe8:	74 06                	je     801ff0 <ipc_recv+0x64>
  801fea:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if (perm_store != NULL) *perm_store = 0;
  801ff0:	85 db                	test   %ebx,%ebx
  801ff2:	74 06                	je     801ffa <ipc_recv+0x6e>
  801ff4:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		return r;
	}
}
  801ffa:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ffd:	5b                   	pop    %ebx
  801ffe:	5e                   	pop    %esi
  801fff:	c9                   	leave  
  802000:	c3                   	ret    

00802001 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802001:	55                   	push   %ebp
  802002:	89 e5                	mov    %esp,%ebp
  802004:	57                   	push   %edi
  802005:	56                   	push   %esi
  802006:	53                   	push   %ebx
  802007:	83 ec 0c             	sub    $0xc,%esp
  80200a:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80200d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  802010:	8b 75 14             	mov    0x14(%ebp),%esi
	// LAB 4: Your code here.
	// int sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
	int r;
	if (pg == NULL) pg = (void *)UTOP;
  802013:	85 db                	test   %ebx,%ebx
  802015:	75 25                	jne    80203c <ipc_send+0x3b>
  802017:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
  80201c:	eb 1e                	jmp    80203c <ipc_send+0x3b>
	
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) != 0) {
		if (r == -E_IPC_NOT_RECV) {
  80201e:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802021:	75 07                	jne    80202a <ipc_send+0x29>
			// cprintf("Try Again and Again....\n");
			sys_yield();
  802023:	e8 e9 ec ff ff       	call   800d11 <sys_yield>
  802028:	eb 12                	jmp    80203c <ipc_send+0x3b>
		} else {
			panic("ipc_send error %e\n", r);
  80202a:	50                   	push   %eax
  80202b:	68 a4 2a 80 00       	push   $0x802aa4
  802030:	6a 43                	push   $0x43
  802032:	68 b7 2a 80 00       	push   $0x802ab7
  802037:	e8 ec e1 ff ff       	call   800228 <_panic>
	// LAB 4: Your code here.
	// int sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
	int r;
	if (pg == NULL) pg = (void *)UTOP;
	
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) != 0) {
  80203c:	56                   	push   %esi
  80203d:	53                   	push   %ebx
  80203e:	57                   	push   %edi
  80203f:	ff 75 08             	pushl  0x8(%ebp)
  802042:	e8 c7 ed ff ff       	call   800e0e <sys_ipc_try_send>
  802047:	83 c4 10             	add    $0x10,%esp
  80204a:	85 c0                	test   %eax,%eax
  80204c:	75 d0                	jne    80201e <ipc_send+0x1d>
		} else {
			panic("ipc_send error %e\n", r);
		}
	}
	return;
}
  80204e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802051:	5b                   	pop    %ebx
  802052:	5e                   	pop    %esi
  802053:	5f                   	pop    %edi
  802054:	c9                   	leave  
  802055:	c3                   	ret    

00802056 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802056:	55                   	push   %ebp
  802057:	89 e5                	mov    %esp,%ebp
  802059:	53                   	push   %ebx
  80205a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  80205d:	39 1d 50 00 c0 ee    	cmp    %ebx,0xeec00050
  802063:	74 22                	je     802087 <ipc_find_env+0x31>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802065:	b8 01 00 00 00       	mov    $0x1,%eax
		if (envs[i].env_type == type)
  80206a:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  802071:	89 c2                	mov    %eax,%edx
  802073:	c1 e2 07             	shl    $0x7,%edx
  802076:	29 ca                	sub    %ecx,%edx
  802078:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  80207e:	8b 52 50             	mov    0x50(%edx),%edx
  802081:	39 da                	cmp    %ebx,%edx
  802083:	75 1d                	jne    8020a2 <ipc_find_env+0x4c>
  802085:	eb 05                	jmp    80208c <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802087:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
			return envs[i].env_id;
  80208c:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  802093:	c1 e0 07             	shl    $0x7,%eax
  802096:	29 d0                	sub    %edx,%eax
  802098:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  80209d:	8b 40 40             	mov    0x40(%eax),%eax
  8020a0:	eb 0c                	jmp    8020ae <ipc_find_env+0x58>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8020a2:	40                   	inc    %eax
  8020a3:	3d 00 04 00 00       	cmp    $0x400,%eax
  8020a8:	75 c0                	jne    80206a <ipc_find_env+0x14>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8020aa:	66 b8 00 00          	mov    $0x0,%ax
}
  8020ae:	5b                   	pop    %ebx
  8020af:	c9                   	leave  
  8020b0:	c3                   	ret    
  8020b1:	00 00                	add    %al,(%eax)
	...

008020b4 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8020b4:	55                   	push   %ebp
  8020b5:	89 e5                	mov    %esp,%ebp
  8020b7:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8020ba:	89 c2                	mov    %eax,%edx
  8020bc:	c1 ea 16             	shr    $0x16,%edx
  8020bf:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8020c6:	f6 c2 01             	test   $0x1,%dl
  8020c9:	74 1e                	je     8020e9 <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  8020cb:	c1 e8 0c             	shr    $0xc,%eax
  8020ce:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  8020d5:	a8 01                	test   $0x1,%al
  8020d7:	74 17                	je     8020f0 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8020d9:	c1 e8 0c             	shr    $0xc,%eax
  8020dc:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  8020e3:	ef 
  8020e4:	0f b7 c0             	movzwl %ax,%eax
  8020e7:	eb 0c                	jmp    8020f5 <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  8020e9:	b8 00 00 00 00       	mov    $0x0,%eax
  8020ee:	eb 05                	jmp    8020f5 <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  8020f0:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  8020f5:	c9                   	leave  
  8020f6:	c3                   	ret    
	...

008020f8 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  8020f8:	55                   	push   %ebp
  8020f9:	89 e5                	mov    %esp,%ebp
  8020fb:	57                   	push   %edi
  8020fc:	56                   	push   %esi
  8020fd:	83 ec 10             	sub    $0x10,%esp
  802100:	8b 7d 08             	mov    0x8(%ebp),%edi
  802103:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  802106:	89 7d f0             	mov    %edi,-0x10(%ebp)
  802109:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  80210c:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  80210f:	8b 45 14             	mov    0x14(%ebp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  802112:	85 c0                	test   %eax,%eax
  802114:	75 2e                	jne    802144 <__udivdi3+0x4c>
    {
      if (d0 > n1)
  802116:	39 f1                	cmp    %esi,%ecx
  802118:	77 5a                	ja     802174 <__udivdi3+0x7c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  80211a:	85 c9                	test   %ecx,%ecx
  80211c:	75 0b                	jne    802129 <__udivdi3+0x31>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  80211e:	b8 01 00 00 00       	mov    $0x1,%eax
  802123:	31 d2                	xor    %edx,%edx
  802125:	f7 f1                	div    %ecx
  802127:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  802129:	31 d2                	xor    %edx,%edx
  80212b:	89 f0                	mov    %esi,%eax
  80212d:	f7 f1                	div    %ecx
  80212f:	89 c6                	mov    %eax,%esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802131:	89 f8                	mov    %edi,%eax
  802133:	f7 f1                	div    %ecx
  802135:	89 c7                	mov    %eax,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  802137:	89 f8                	mov    %edi,%eax
  802139:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  80213b:	83 c4 10             	add    $0x10,%esp
  80213e:	5e                   	pop    %esi
  80213f:	5f                   	pop    %edi
  802140:	c9                   	leave  
  802141:	c3                   	ret    
  802142:	66 90                	xchg   %ax,%ax
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  802144:	39 f0                	cmp    %esi,%eax
  802146:	77 1c                	ja     802164 <__udivdi3+0x6c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  802148:	0f bd f8             	bsr    %eax,%edi
	  if (bm == 0)
  80214b:	83 f7 1f             	xor    $0x1f,%edi
  80214e:	75 3c                	jne    80218c <__udivdi3+0x94>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802150:	39 f0                	cmp    %esi,%eax
  802152:	0f 82 90 00 00 00    	jb     8021e8 <__udivdi3+0xf0>
  802158:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80215b:	39 55 f4             	cmp    %edx,-0xc(%ebp)
  80215e:	0f 86 84 00 00 00    	jbe    8021e8 <__udivdi3+0xf0>
  802164:	31 f6                	xor    %esi,%esi
  802166:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  802168:	89 f8                	mov    %edi,%eax
  80216a:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  80216c:	83 c4 10             	add    $0x10,%esp
  80216f:	5e                   	pop    %esi
  802170:	5f                   	pop    %edi
  802171:	c9                   	leave  
  802172:	c3                   	ret    
  802173:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802174:	89 f2                	mov    %esi,%edx
  802176:	89 f8                	mov    %edi,%eax
  802178:	f7 f1                	div    %ecx
  80217a:	89 c7                	mov    %eax,%edi
  80217c:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  80217e:	89 f8                	mov    %edi,%eax
  802180:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802182:	83 c4 10             	add    $0x10,%esp
  802185:	5e                   	pop    %esi
  802186:	5f                   	pop    %edi
  802187:	c9                   	leave  
  802188:	c3                   	ret    
  802189:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  80218c:	89 f9                	mov    %edi,%ecx
  80218e:	d3 e0                	shl    %cl,%eax
  802190:	89 45 e8             	mov    %eax,-0x18(%ebp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  802193:	b8 20 00 00 00       	mov    $0x20,%eax
  802198:	29 f8                	sub    %edi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  80219a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80219d:	88 c1                	mov    %al,%cl
  80219f:	d3 ea                	shr    %cl,%edx
  8021a1:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  8021a4:	09 ca                	or     %ecx,%edx
  8021a6:	89 55 ec             	mov    %edx,-0x14(%ebp)
	      d0 = d0 << bm;
  8021a9:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8021ac:	89 f9                	mov    %edi,%ecx
  8021ae:	d3 e2                	shl    %cl,%edx
  8021b0:	89 55 f4             	mov    %edx,-0xc(%ebp)
	      n2 = n1 >> b;
  8021b3:	89 f2                	mov    %esi,%edx
  8021b5:	88 c1                	mov    %al,%cl
  8021b7:	d3 ea                	shr    %cl,%edx
  8021b9:	89 55 e8             	mov    %edx,-0x18(%ebp)
	      n1 = (n1 << bm) | (n0 >> b);
  8021bc:	89 f2                	mov    %esi,%edx
  8021be:	89 f9                	mov    %edi,%ecx
  8021c0:	d3 e2                	shl    %cl,%edx
  8021c2:	8b 75 f0             	mov    -0x10(%ebp),%esi
  8021c5:	88 c1                	mov    %al,%cl
  8021c7:	d3 ee                	shr    %cl,%esi
  8021c9:	09 d6                	or     %edx,%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  8021cb:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  8021ce:	89 f0                	mov    %esi,%eax
  8021d0:	89 ca                	mov    %ecx,%edx
  8021d2:	f7 75 ec             	divl   -0x14(%ebp)
  8021d5:	89 d1                	mov    %edx,%ecx
  8021d7:	89 c6                	mov    %eax,%esi
	      umul_ppmm (m1, m0, q0, d0);
  8021d9:	f7 65 f4             	mull   -0xc(%ebp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8021dc:	39 d1                	cmp    %edx,%ecx
  8021de:	72 28                	jb     802208 <__udivdi3+0x110>
  8021e0:	74 1a                	je     8021fc <__udivdi3+0x104>
  8021e2:	89 f7                	mov    %esi,%edi
  8021e4:	31 f6                	xor    %esi,%esi
  8021e6:	eb 80                	jmp    802168 <__udivdi3+0x70>
	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  8021e8:	31 f6                	xor    %esi,%esi
  8021ea:	bf 01 00 00 00       	mov    $0x1,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  8021ef:	89 f8                	mov    %edi,%eax
  8021f1:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  8021f3:	83 c4 10             	add    $0x10,%esp
  8021f6:	5e                   	pop    %esi
  8021f7:	5f                   	pop    %edi
  8021f8:	c9                   	leave  
  8021f9:	c3                   	ret    
  8021fa:	66 90                	xchg   %ax,%ax

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  8021fc:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8021ff:	89 f9                	mov    %edi,%ecx
  802201:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802203:	39 c2                	cmp    %eax,%edx
  802205:	73 db                	jae    8021e2 <__udivdi3+0xea>
  802207:	90                   	nop
		{
		  q0--;
  802208:	8d 7e ff             	lea    -0x1(%esi),%edi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  80220b:	31 f6                	xor    %esi,%esi
  80220d:	e9 56 ff ff ff       	jmp    802168 <__udivdi3+0x70>
	...

00802214 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  802214:	55                   	push   %ebp
  802215:	89 e5                	mov    %esp,%ebp
  802217:	57                   	push   %edi
  802218:	56                   	push   %esi
  802219:	83 ec 20             	sub    $0x20,%esp
  80221c:	8b 45 08             	mov    0x8(%ebp),%eax
  80221f:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  802222:	89 45 e8             	mov    %eax,-0x18(%ebp)
  802225:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  802228:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  80222b:	8b 7d 14             	mov    0x14(%ebp),%edi
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  80222e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  n1 = nn.s.high;
  802231:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  802233:	85 ff                	test   %edi,%edi
  802235:	75 15                	jne    80224c <__umoddi3+0x38>
    {
      if (d0 > n1)
  802237:	39 f1                	cmp    %esi,%ecx
  802239:	0f 86 99 00 00 00    	jbe    8022d8 <__umoddi3+0xc4>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  80223f:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  802241:	89 d0                	mov    %edx,%eax
  802243:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802245:	83 c4 20             	add    $0x20,%esp
  802248:	5e                   	pop    %esi
  802249:	5f                   	pop    %edi
  80224a:	c9                   	leave  
  80224b:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  80224c:	39 f7                	cmp    %esi,%edi
  80224e:	0f 87 a4 00 00 00    	ja     8022f8 <__umoddi3+0xe4>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  802254:	0f bd c7             	bsr    %edi,%eax
	  if (bm == 0)
  802257:	83 f0 1f             	xor    $0x1f,%eax
  80225a:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80225d:	0f 84 a1 00 00 00    	je     802304 <__umoddi3+0xf0>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  802263:	89 f8                	mov    %edi,%eax
  802265:	8a 4d ec             	mov    -0x14(%ebp),%cl
  802268:	d3 e0                	shl    %cl,%eax
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  80226a:	bf 20 00 00 00       	mov    $0x20,%edi
  80226f:	2b 7d ec             	sub    -0x14(%ebp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  802272:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802275:	89 f9                	mov    %edi,%ecx
  802277:	d3 ea                	shr    %cl,%edx
  802279:	09 c2                	or     %eax,%edx
  80227b:	89 55 f0             	mov    %edx,-0x10(%ebp)
	      d0 = d0 << bm;
  80227e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802281:	8a 4d ec             	mov    -0x14(%ebp),%cl
  802284:	d3 e0                	shl    %cl,%eax
  802286:	89 45 f4             	mov    %eax,-0xc(%ebp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  802289:	89 f2                	mov    %esi,%edx
  80228b:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  80228d:	8b 45 e8             	mov    -0x18(%ebp),%eax
  802290:	d3 e0                	shl    %cl,%eax
  802292:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  802295:	8b 45 e8             	mov    -0x18(%ebp),%eax
  802298:	89 f9                	mov    %edi,%ecx
  80229a:	d3 e8                	shr    %cl,%eax
  80229c:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  80229e:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  8022a0:	89 f2                	mov    %esi,%edx
  8022a2:	f7 75 f0             	divl   -0x10(%ebp)
  8022a5:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  8022a7:	f7 65 f4             	mull   -0xc(%ebp)
  8022aa:	89 55 e8             	mov    %edx,-0x18(%ebp)
  8022ad:	89 c1                	mov    %eax,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8022af:	39 d6                	cmp    %edx,%esi
  8022b1:	72 71                	jb     802324 <__umoddi3+0x110>
  8022b3:	74 7f                	je     802334 <__umoddi3+0x120>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  8022b5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8022b8:	29 c8                	sub    %ecx,%eax
  8022ba:	19 d6                	sbb    %edx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  8022bc:	8a 4d ec             	mov    -0x14(%ebp),%cl
  8022bf:	d3 e8                	shr    %cl,%eax
  8022c1:	89 f2                	mov    %esi,%edx
  8022c3:	89 f9                	mov    %edi,%ecx
  8022c5:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  8022c7:	09 d0                	or     %edx,%eax
  8022c9:	89 f2                	mov    %esi,%edx
  8022cb:	8a 4d ec             	mov    -0x14(%ebp),%cl
  8022ce:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8022d0:	83 c4 20             	add    $0x20,%esp
  8022d3:	5e                   	pop    %esi
  8022d4:	5f                   	pop    %edi
  8022d5:	c9                   	leave  
  8022d6:	c3                   	ret    
  8022d7:	90                   	nop
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  8022d8:	85 c9                	test   %ecx,%ecx
  8022da:	75 0b                	jne    8022e7 <__umoddi3+0xd3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  8022dc:	b8 01 00 00 00       	mov    $0x1,%eax
  8022e1:	31 d2                	xor    %edx,%edx
  8022e3:	f7 f1                	div    %ecx
  8022e5:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  8022e7:	89 f0                	mov    %esi,%eax
  8022e9:	31 d2                	xor    %edx,%edx
  8022eb:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8022ed:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8022f0:	f7 f1                	div    %ecx
  8022f2:	e9 4a ff ff ff       	jmp    802241 <__umoddi3+0x2d>
  8022f7:	90                   	nop
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  8022f8:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8022fa:	83 c4 20             	add    $0x20,%esp
  8022fd:	5e                   	pop    %esi
  8022fe:	5f                   	pop    %edi
  8022ff:	c9                   	leave  
  802300:	c3                   	ret    
  802301:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802304:	39 f7                	cmp    %esi,%edi
  802306:	72 05                	jb     80230d <__umoddi3+0xf9>
  802308:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
  80230b:	77 0c                	ja     802319 <__umoddi3+0x105>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  80230d:	89 f2                	mov    %esi,%edx
  80230f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802312:	29 c8                	sub    %ecx,%eax
  802314:	19 fa                	sbb    %edi,%edx
  802316:	89 45 f0             	mov    %eax,-0x10(%ebp)

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  802319:	8b 45 f0             	mov    -0x10(%ebp),%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  80231c:	83 c4 20             	add    $0x20,%esp
  80231f:	5e                   	pop    %esi
  802320:	5f                   	pop    %edi
  802321:	c9                   	leave  
  802322:	c3                   	ret    
  802323:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  802324:	8b 55 e8             	mov    -0x18(%ebp),%edx
  802327:	89 c1                	mov    %eax,%ecx
  802329:	2b 4d f4             	sub    -0xc(%ebp),%ecx
  80232c:	1b 55 f0             	sbb    -0x10(%ebp),%edx
  80232f:	eb 84                	jmp    8022b5 <__umoddi3+0xa1>
  802331:	8d 76 00             	lea    0x0(%esi),%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802334:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  802337:	72 eb                	jb     802324 <__umoddi3+0x110>
  802339:	89 f2                	mov    %esi,%edx
  80233b:	e9 75 ff ff ff       	jmp    8022b5 <__umoddi3+0xa1>
