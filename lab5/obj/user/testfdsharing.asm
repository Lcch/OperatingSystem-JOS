
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
  80003f:	68 20 23 80 00       	push   $0x802320
  800044:	e8 6b 18 00 00       	call   8018b4 <open>
  800049:	89 c3                	mov    %eax,%ebx
  80004b:	83 c4 10             	add    $0x10,%esp
  80004e:	85 c0                	test   %eax,%eax
  800050:	79 12                	jns    800064 <umain+0x30>
		panic("open motd: %e", fd);
  800052:	50                   	push   %eax
  800053:	68 25 23 80 00       	push   $0x802325
  800058:	6a 0c                	push   $0xc
  80005a:	68 33 23 80 00       	push   $0x802333
  80005f:	e8 c4 01 00 00       	call   800228 <_panic>
	seek(fd, 0);
  800064:	83 ec 08             	sub    $0x8,%esp
  800067:	6a 00                	push   $0x0
  800069:	50                   	push   %eax
  80006a:	e8 9f 15 00 00       	call   80160e <seek>
	if ((n = readn(fd, buf, sizeof buf)) <= 0)
  80006f:	83 c4 0c             	add    $0xc,%esp
  800072:	68 00 02 00 00       	push   $0x200
  800077:	68 20 42 80 00       	push   $0x804220
  80007c:	53                   	push   %ebx
  80007d:	e8 b5 14 00 00       	call   801537 <readn>
  800082:	89 c7                	mov    %eax,%edi
  800084:	83 c4 10             	add    $0x10,%esp
  800087:	85 c0                	test   %eax,%eax
  800089:	7f 12                	jg     80009d <umain+0x69>
		panic("readn: %e", n);
  80008b:	50                   	push   %eax
  80008c:	68 48 23 80 00       	push   $0x802348
  800091:	6a 0f                	push   $0xf
  800093:	68 33 23 80 00       	push   $0x802333
  800098:	e8 8b 01 00 00       	call   800228 <_panic>

	if ((r = fork()) < 0)
  80009d:	e8 a8 0e 00 00       	call   800f4a <fork>
  8000a2:	89 c6                	mov    %eax,%esi
  8000a4:	85 c0                	test   %eax,%eax
  8000a6:	79 12                	jns    8000ba <umain+0x86>
		panic("fork: %e", r);
  8000a8:	50                   	push   %eax
  8000a9:	68 52 23 80 00       	push   $0x802352
  8000ae:	6a 12                	push   $0x12
  8000b0:	68 33 23 80 00       	push   $0x802333
  8000b5:	e8 6e 01 00 00       	call   800228 <_panic>
	if (r == 0) {
  8000ba:	85 c0                	test   %eax,%eax
  8000bc:	0f 85 9d 00 00 00    	jne    80015f <umain+0x12b>
		seek(fd, 0);
  8000c2:	83 ec 08             	sub    $0x8,%esp
  8000c5:	6a 00                	push   $0x0
  8000c7:	53                   	push   %ebx
  8000c8:	e8 41 15 00 00       	call   80160e <seek>
		cprintf("going to read in child (might page fault if your sharing is buggy)\n");
  8000cd:	c7 04 24 90 23 80 00 	movl   $0x802390,(%esp)
  8000d4:	e8 27 02 00 00       	call   800300 <cprintf>
		if ((n2 = readn(fd, buf2, sizeof buf2)) != n)
  8000d9:	83 c4 0c             	add    $0xc,%esp
  8000dc:	68 00 02 00 00       	push   $0x200
  8000e1:	68 20 40 80 00       	push   $0x804020
  8000e6:	53                   	push   %ebx
  8000e7:	e8 4b 14 00 00       	call   801537 <readn>
  8000ec:	83 c4 10             	add    $0x10,%esp
  8000ef:	39 f8                	cmp    %edi,%eax
  8000f1:	74 16                	je     800109 <umain+0xd5>
			panic("read in parent got %d, read in child got %d", n, n2);
  8000f3:	83 ec 0c             	sub    $0xc,%esp
  8000f6:	50                   	push   %eax
  8000f7:	57                   	push   %edi
  8000f8:	68 d4 23 80 00       	push   $0x8023d4
  8000fd:	6a 17                	push   $0x17
  8000ff:	68 33 23 80 00       	push   $0x802333
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
  800126:	68 00 24 80 00       	push   $0x802400
  80012b:	6a 19                	push   $0x19
  80012d:	68 33 23 80 00       	push   $0x802333
  800132:	e8 f1 00 00 00       	call   800228 <_panic>
		cprintf("read in child succeeded\n");
  800137:	83 ec 0c             	sub    $0xc,%esp
  80013a:	68 5b 23 80 00       	push   $0x80235b
  80013f:	e8 bc 01 00 00       	call   800300 <cprintf>
		seek(fd, 0);
  800144:	83 c4 08             	add    $0x8,%esp
  800147:	6a 00                	push   $0x0
  800149:	53                   	push   %ebx
  80014a:	e8 bf 14 00 00       	call   80160e <seek>
		close(fd);
  80014f:	89 1c 24             	mov    %ebx,(%esp)
  800152:	e8 1c 12 00 00       	call   801373 <close>
		exit();
  800157:	e8 b0 00 00 00       	call   80020c <exit>
  80015c:	83 c4 10             	add    $0x10,%esp
	}
	wait(r);
  80015f:	83 ec 0c             	sub    $0xc,%esp
  800162:	56                   	push   %esi
  800163:	e8 50 1b 00 00       	call   801cb8 <wait>
	if ((n2 = readn(fd, buf2, sizeof buf2)) != n)
  800168:	83 c4 0c             	add    $0xc,%esp
  80016b:	68 00 02 00 00       	push   $0x200
  800170:	68 20 40 80 00       	push   $0x804020
  800175:	53                   	push   %ebx
  800176:	e8 bc 13 00 00       	call   801537 <readn>
  80017b:	83 c4 10             	add    $0x10,%esp
  80017e:	39 f8                	cmp    %edi,%eax
  800180:	74 16                	je     800198 <umain+0x164>
		panic("read in parent got %d, then got %d", n, n2);
  800182:	83 ec 0c             	sub    $0xc,%esp
  800185:	50                   	push   %eax
  800186:	57                   	push   %edi
  800187:	68 38 24 80 00       	push   $0x802438
  80018c:	6a 21                	push   $0x21
  80018e:	68 33 23 80 00       	push   $0x802333
  800193:	e8 90 00 00 00       	call   800228 <_panic>
	cprintf("read in parent succeeded\n");
  800198:	83 ec 0c             	sub    $0xc,%esp
  80019b:	68 74 23 80 00       	push   $0x802374
  8001a0:	e8 5b 01 00 00       	call   800300 <cprintf>
	close(fd);
  8001a5:	89 1c 24             	mov    %ebx,(%esp)
  8001a8:	e8 c6 11 00 00       	call   801373 <close>
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
  800212:	e8 87 11 00 00       	call   80139e <close_all>
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
  800246:	68 68 24 80 00       	push   $0x802468
  80024b:	e8 b0 00 00 00       	call   800300 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800250:	83 c4 18             	add    $0x18,%esp
  800253:	56                   	push   %esi
  800254:	ff 75 10             	pushl  0x10(%ebp)
  800257:	e8 53 00 00 00       	call   8002af <vcprintf>
	cprintf("\n");
  80025c:	c7 04 24 72 23 80 00 	movl   $0x802372,(%esp)
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
  800368:	e8 63 1d 00 00       	call   8020d0 <__udivdi3>
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
  8003a4:	e8 43 1e 00 00       	call   8021ec <__umoddi3>
  8003a9:	83 c4 14             	add    $0x14,%esp
  8003ac:	0f be 80 8b 24 80 00 	movsbl 0x80248b(%eax),%eax
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
  8004f0:	ff 24 85 c0 25 80 00 	jmp    *0x8025c0(,%eax,4)
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
  80059c:	8b 04 85 20 27 80 00 	mov    0x802720(,%eax,4),%eax
  8005a3:	85 c0                	test   %eax,%eax
  8005a5:	75 1a                	jne    8005c1 <vprintfmt+0x15c>
				printfmt(putch, putdat, "error %d", err);
  8005a7:	52                   	push   %edx
  8005a8:	68 a3 24 80 00       	push   $0x8024a3
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
  8005c2:	68 d5 29 80 00       	push   $0x8029d5
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
  8005f8:	c7 45 d0 9c 24 80 00 	movl   $0x80249c,-0x30(%ebp)
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
  800c66:	68 7f 27 80 00       	push   $0x80277f
  800c6b:	6a 42                	push   $0x42
  800c6d:	68 9c 27 80 00       	push   $0x80279c
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
  800e8d:	68 ac 27 80 00       	push   $0x8027ac
  800e92:	6a 20                	push   $0x20
  800e94:	68 f0 28 80 00       	push   $0x8028f0
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
  800ec2:	68 d0 27 80 00       	push   $0x8027d0
  800ec7:	6a 24                	push   $0x24
  800ec9:	68 f0 28 80 00       	push   $0x8028f0
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
  800eec:	68 f4 27 80 00       	push   $0x8027f4
  800ef1:	6a 32                	push   $0x32
  800ef3:	68 f0 28 80 00       	push   $0x8028f0
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
  800f34:	68 18 28 80 00       	push   $0x802818
  800f39:	6a 3a                	push   $0x3a
  800f3b:	68 f0 28 80 00       	push   $0x8028f0
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
  800f58:	e8 73 0f 00 00       	call   801ed0 <set_pgfault_handler>
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
  800f73:	68 fb 28 80 00       	push   $0x8028fb
  800f78:	6a 7f                	push   $0x7f
  800f7a:	68 f0 28 80 00       	push   $0x8028f0
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
  800faa:	e9 be 01 00 00       	jmp    80116d <fork+0x223>
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
  800fc2:	0f 84 10 01 00 00    	je     8010d8 <fork+0x18e>
  800fc8:	89 d8                	mov    %ebx,%eax
  800fca:	c1 e8 0c             	shr    $0xc,%eax
  800fcd:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800fd4:	f6 c2 01             	test   $0x1,%dl
  800fd7:	0f 84 fb 00 00 00    	je     8010d8 <fork+0x18e>
  800fdd:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800fe4:	f6 c2 04             	test   $0x4,%dl
  800fe7:	0f 84 eb 00 00 00    	je     8010d8 <fork+0x18e>
//
static int
duppage(envid_t envid, unsigned pn)
{
	// do not dup exception stack
	if (pn * PGSIZE == UXSTACKTOP - PGSIZE) return 0;
  800fed:	89 c6                	mov    %eax,%esi
  800fef:	c1 e6 0c             	shl    $0xc,%esi
  800ff2:	81 fe 00 f0 bf ee    	cmp    $0xeebff000,%esi
  800ff8:	0f 84 da 00 00 00    	je     8010d8 <fork+0x18e>

	int r;
	void * addr = (void *)(pn * PGSIZE);
    if (uvpt[pn] & PTE_SHARE) {
  800ffe:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801005:	f6 c6 04             	test   $0x4,%dh
  801008:	74 37                	je     801041 <fork+0xf7>
        r = sys_page_map(0, addr, envid, addr, uvpt[pn] & PTE_SYSCALL);
  80100a:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801011:	83 ec 0c             	sub    $0xc,%esp
  801014:	25 07 0e 00 00       	and    $0xe07,%eax
  801019:	50                   	push   %eax
  80101a:	56                   	push   %esi
  80101b:	57                   	push   %edi
  80101c:	56                   	push   %esi
  80101d:	6a 00                	push   $0x0
  80101f:	e8 38 fd ff ff       	call   800d5c <sys_page_map>
        if (r < 0) panic("duppage sys_page_map error : %e\n", r);
  801024:	83 c4 20             	add    $0x20,%esp
  801027:	85 c0                	test   %eax,%eax
  801029:	0f 89 a9 00 00 00    	jns    8010d8 <fork+0x18e>
  80102f:	50                   	push   %eax
  801030:	68 3c 28 80 00       	push   $0x80283c
  801035:	6a 54                	push   $0x54
  801037:	68 f0 28 80 00       	push   $0x8028f0
  80103c:	e8 e7 f1 ff ff       	call   800228 <_panic>
    } else
	if ((uvpt[pn] & PTE_W) || (uvpt[pn] & PTE_COW)) {
  801041:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801048:	f6 c2 02             	test   $0x2,%dl
  80104b:	75 0c                	jne    801059 <fork+0x10f>
  80104d:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801054:	f6 c4 08             	test   $0x8,%ah
  801057:	74 57                	je     8010b0 <fork+0x166>
		// cow
		r = sys_page_map(0, addr, envid, addr, PTE_COW | PTE_P | PTE_U);
  801059:	83 ec 0c             	sub    $0xc,%esp
  80105c:	68 05 08 00 00       	push   $0x805
  801061:	56                   	push   %esi
  801062:	57                   	push   %edi
  801063:	56                   	push   %esi
  801064:	6a 00                	push   $0x0
  801066:	e8 f1 fc ff ff       	call   800d5c <sys_page_map>
		if (r < 0) panic("duppage sys_page_map error : %e\n", r);
  80106b:	83 c4 20             	add    $0x20,%esp
  80106e:	85 c0                	test   %eax,%eax
  801070:	79 12                	jns    801084 <fork+0x13a>
  801072:	50                   	push   %eax
  801073:	68 3c 28 80 00       	push   $0x80283c
  801078:	6a 59                	push   $0x59
  80107a:	68 f0 28 80 00       	push   $0x8028f0
  80107f:	e8 a4 f1 ff ff       	call   800228 <_panic>
		
		r = sys_page_map(0, addr, 0, addr, PTE_COW | PTE_P | PTE_U);
  801084:	83 ec 0c             	sub    $0xc,%esp
  801087:	68 05 08 00 00       	push   $0x805
  80108c:	56                   	push   %esi
  80108d:	6a 00                	push   $0x0
  80108f:	56                   	push   %esi
  801090:	6a 00                	push   $0x0
  801092:	e8 c5 fc ff ff       	call   800d5c <sys_page_map>
		if (r < 0) panic("duppage sys_page_map error : %e\n", r);
  801097:	83 c4 20             	add    $0x20,%esp
  80109a:	85 c0                	test   %eax,%eax
  80109c:	79 3a                	jns    8010d8 <fork+0x18e>
  80109e:	50                   	push   %eax
  80109f:	68 3c 28 80 00       	push   $0x80283c
  8010a4:	6a 5c                	push   $0x5c
  8010a6:	68 f0 28 80 00       	push   $0x8028f0
  8010ab:	e8 78 f1 ff ff       	call   800228 <_panic>
	} else {
		// read only
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U);
  8010b0:	83 ec 0c             	sub    $0xc,%esp
  8010b3:	6a 05                	push   $0x5
  8010b5:	56                   	push   %esi
  8010b6:	57                   	push   %edi
  8010b7:	56                   	push   %esi
  8010b8:	6a 00                	push   $0x0
  8010ba:	e8 9d fc ff ff       	call   800d5c <sys_page_map>
		if (r < 0) panic("duppage sys_page_map error : %e\n", r);
  8010bf:	83 c4 20             	add    $0x20,%esp
  8010c2:	85 c0                	test   %eax,%eax
  8010c4:	79 12                	jns    8010d8 <fork+0x18e>
  8010c6:	50                   	push   %eax
  8010c7:	68 3c 28 80 00       	push   $0x80283c
  8010cc:	6a 60                	push   $0x60
  8010ce:	68 f0 28 80 00       	push   $0x8028f0
  8010d3:	e8 50 f1 ff ff       	call   800228 <_panic>
		return 0;
	} else {
		// map page to new environment
		// kernel page is already in new environment
		uint32_t i;
		for (i = 0; i != UTOP; i += PGSIZE) 
  8010d8:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  8010de:	81 fb 00 00 c0 ee    	cmp    $0xeec00000,%ebx
  8010e4:	0f 85 ca fe ff ff    	jne    800fb4 <fork+0x6a>
		if ((uvpd[PDX(i)] & PTE_P) && (uvpt[i / PGSIZE] & PTE_P) && (uvpt[i / PGSIZE] & PTE_U)) {
			duppage(childpid, i / PGSIZE);
		}

		// allocate exception stack
		r = sys_page_alloc(childpid, (void *)(UXSTACKTOP - PGSIZE), PTE_U | PTE_W | PTE_P);
  8010ea:	83 ec 04             	sub    $0x4,%esp
  8010ed:	6a 07                	push   $0x7
  8010ef:	68 00 f0 bf ee       	push   $0xeebff000
  8010f4:	ff 75 e4             	pushl  -0x1c(%ebp)
  8010f7:	e8 3c fc ff ff       	call   800d38 <sys_page_alloc>
		if (r < 0) panic("fork, sys_page_alloc user exception stack error : %e\n", r);
  8010fc:	83 c4 10             	add    $0x10,%esp
  8010ff:	85 c0                	test   %eax,%eax
  801101:	79 15                	jns    801118 <fork+0x1ce>
  801103:	50                   	push   %eax
  801104:	68 60 28 80 00       	push   $0x802860
  801109:	68 94 00 00 00       	push   $0x94
  80110e:	68 f0 28 80 00       	push   $0x8028f0
  801113:	e8 10 f1 ff ff       	call   800228 <_panic>

		// set user environment user page fault handler 
		extern void _pgfault_upcall(void);
		r = sys_env_set_pgfault_upcall(childpid, _pgfault_upcall);
  801118:	83 ec 08             	sub    $0x8,%esp
  80111b:	68 3c 1f 80 00       	push   $0x801f3c
  801120:	ff 75 e4             	pushl  -0x1c(%ebp)
  801123:	e8 c3 fc ff ff       	call   800deb <sys_env_set_pgfault_upcall>
		if (r < 0) panic("fork, set pgfault upcall fail : %e\n", r);
  801128:	83 c4 10             	add    $0x10,%esp
  80112b:	85 c0                	test   %eax,%eax
  80112d:	79 15                	jns    801144 <fork+0x1fa>
  80112f:	50                   	push   %eax
  801130:	68 98 28 80 00       	push   $0x802898
  801135:	68 99 00 00 00       	push   $0x99
  80113a:	68 f0 28 80 00       	push   $0x8028f0
  80113f:	e8 e4 f0 ff ff       	call   800228 <_panic>
		r = sys_set_priority(childpid, num);
		if (r < 0) panic("fork, set priority error\n");
		*/

		// mark the child as runnable and return
		r = sys_env_set_status(childpid, ENV_RUNNABLE);
  801144:	83 ec 08             	sub    $0x8,%esp
  801147:	6a 02                	push   $0x2
  801149:	ff 75 e4             	pushl  -0x1c(%ebp)
  80114c:	e8 54 fc ff ff       	call   800da5 <sys_env_set_status>
		if (r < 0) panic("fork, set child process to ENV_RUNNABLE error : %e\n", r);
  801151:	83 c4 10             	add    $0x10,%esp
  801154:	85 c0                	test   %eax,%eax
  801156:	79 15                	jns    80116d <fork+0x223>
  801158:	50                   	push   %eax
  801159:	68 bc 28 80 00       	push   $0x8028bc
  80115e:	68 a4 00 00 00       	push   $0xa4
  801163:	68 f0 28 80 00       	push   $0x8028f0
  801168:	e8 bb f0 ff ff       	call   800228 <_panic>
		// cprintf("fork father ok!")
		return childpid;
	}

	panic("fork not implemented");
}
  80116d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801170:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801173:	5b                   	pop    %ebx
  801174:	5e                   	pop    %esi
  801175:	5f                   	pop    %edi
  801176:	c9                   	leave  
  801177:	c3                   	ret    

00801178 <sfork>:

// Challenge!
int
sfork(void)
{
  801178:	55                   	push   %ebp
  801179:	89 e5                	mov    %esp,%ebp
  80117b:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  80117e:	68 18 29 80 00       	push   $0x802918
  801183:	68 b1 00 00 00       	push   $0xb1
  801188:	68 f0 28 80 00       	push   $0x8028f0
  80118d:	e8 96 f0 ff ff       	call   800228 <_panic>
	...

00801194 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801194:	55                   	push   %ebp
  801195:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801197:	8b 45 08             	mov    0x8(%ebp),%eax
  80119a:	05 00 00 00 30       	add    $0x30000000,%eax
  80119f:	c1 e8 0c             	shr    $0xc,%eax
}
  8011a2:	c9                   	leave  
  8011a3:	c3                   	ret    

008011a4 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8011a4:	55                   	push   %ebp
  8011a5:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  8011a7:	ff 75 08             	pushl  0x8(%ebp)
  8011aa:	e8 e5 ff ff ff       	call   801194 <fd2num>
  8011af:	83 c4 04             	add    $0x4,%esp
  8011b2:	05 20 00 0d 00       	add    $0xd0020,%eax
  8011b7:	c1 e0 0c             	shl    $0xc,%eax
}
  8011ba:	c9                   	leave  
  8011bb:	c3                   	ret    

008011bc <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8011bc:	55                   	push   %ebp
  8011bd:	89 e5                	mov    %esp,%ebp
  8011bf:	53                   	push   %ebx
  8011c0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8011c3:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  8011c8:	a8 01                	test   $0x1,%al
  8011ca:	74 34                	je     801200 <fd_alloc+0x44>
  8011cc:	a1 00 00 74 ef       	mov    0xef740000,%eax
  8011d1:	a8 01                	test   $0x1,%al
  8011d3:	74 32                	je     801207 <fd_alloc+0x4b>
  8011d5:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
  8011da:	89 c1                	mov    %eax,%ecx
  8011dc:	89 c2                	mov    %eax,%edx
  8011de:	c1 ea 16             	shr    $0x16,%edx
  8011e1:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8011e8:	f6 c2 01             	test   $0x1,%dl
  8011eb:	74 1f                	je     80120c <fd_alloc+0x50>
  8011ed:	89 c2                	mov    %eax,%edx
  8011ef:	c1 ea 0c             	shr    $0xc,%edx
  8011f2:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8011f9:	f6 c2 01             	test   $0x1,%dl
  8011fc:	75 17                	jne    801215 <fd_alloc+0x59>
  8011fe:	eb 0c                	jmp    80120c <fd_alloc+0x50>
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  801200:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
  801205:	eb 05                	jmp    80120c <fd_alloc+0x50>
  801207:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
  80120c:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  80120e:	b8 00 00 00 00       	mov    $0x0,%eax
  801213:	eb 17                	jmp    80122c <fd_alloc+0x70>
  801215:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  80121a:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80121f:	75 b9                	jne    8011da <fd_alloc+0x1e>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801221:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  801227:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  80122c:	5b                   	pop    %ebx
  80122d:	c9                   	leave  
  80122e:	c3                   	ret    

0080122f <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80122f:	55                   	push   %ebp
  801230:	89 e5                	mov    %esp,%ebp
  801232:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801235:	83 f8 1f             	cmp    $0x1f,%eax
  801238:	77 36                	ja     801270 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80123a:	05 00 00 0d 00       	add    $0xd0000,%eax
  80123f:	c1 e0 0c             	shl    $0xc,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801242:	89 c2                	mov    %eax,%edx
  801244:	c1 ea 16             	shr    $0x16,%edx
  801247:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80124e:	f6 c2 01             	test   $0x1,%dl
  801251:	74 24                	je     801277 <fd_lookup+0x48>
  801253:	89 c2                	mov    %eax,%edx
  801255:	c1 ea 0c             	shr    $0xc,%edx
  801258:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80125f:	f6 c2 01             	test   $0x1,%dl
  801262:	74 1a                	je     80127e <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801264:	8b 55 0c             	mov    0xc(%ebp),%edx
  801267:	89 02                	mov    %eax,(%edx)
	return 0;
  801269:	b8 00 00 00 00       	mov    $0x0,%eax
  80126e:	eb 13                	jmp    801283 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801270:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801275:	eb 0c                	jmp    801283 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801277:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80127c:	eb 05                	jmp    801283 <fd_lookup+0x54>
  80127e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801283:	c9                   	leave  
  801284:	c3                   	ret    

00801285 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801285:	55                   	push   %ebp
  801286:	89 e5                	mov    %esp,%ebp
  801288:	53                   	push   %ebx
  801289:	83 ec 04             	sub    $0x4,%esp
  80128c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80128f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  801292:	39 0d 04 30 80 00    	cmp    %ecx,0x803004
  801298:	74 0d                	je     8012a7 <dev_lookup+0x22>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80129a:	b8 00 00 00 00       	mov    $0x0,%eax
  80129f:	eb 14                	jmp    8012b5 <dev_lookup+0x30>
		if (devtab[i]->dev_id == dev_id) {
  8012a1:	39 0a                	cmp    %ecx,(%edx)
  8012a3:	75 10                	jne    8012b5 <dev_lookup+0x30>
  8012a5:	eb 05                	jmp    8012ac <dev_lookup+0x27>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8012a7:	ba 04 30 80 00       	mov    $0x803004,%edx
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
  8012ac:	89 13                	mov    %edx,(%ebx)
			return 0;
  8012ae:	b8 00 00 00 00       	mov    $0x0,%eax
  8012b3:	eb 31                	jmp    8012e6 <dev_lookup+0x61>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8012b5:	40                   	inc    %eax
  8012b6:	8b 14 85 ac 29 80 00 	mov    0x8029ac(,%eax,4),%edx
  8012bd:	85 d2                	test   %edx,%edx
  8012bf:	75 e0                	jne    8012a1 <dev_lookup+0x1c>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8012c1:	a1 20 44 80 00       	mov    0x804420,%eax
  8012c6:	8b 40 48             	mov    0x48(%eax),%eax
  8012c9:	83 ec 04             	sub    $0x4,%esp
  8012cc:	51                   	push   %ecx
  8012cd:	50                   	push   %eax
  8012ce:	68 30 29 80 00       	push   $0x802930
  8012d3:	e8 28 f0 ff ff       	call   800300 <cprintf>
	*dev = 0;
  8012d8:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  8012de:	83 c4 10             	add    $0x10,%esp
  8012e1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8012e6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012e9:	c9                   	leave  
  8012ea:	c3                   	ret    

008012eb <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8012eb:	55                   	push   %ebp
  8012ec:	89 e5                	mov    %esp,%ebp
  8012ee:	56                   	push   %esi
  8012ef:	53                   	push   %ebx
  8012f0:	83 ec 20             	sub    $0x20,%esp
  8012f3:	8b 75 08             	mov    0x8(%ebp),%esi
  8012f6:	8a 45 0c             	mov    0xc(%ebp),%al
  8012f9:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8012fc:	56                   	push   %esi
  8012fd:	e8 92 fe ff ff       	call   801194 <fd2num>
  801302:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801305:	89 14 24             	mov    %edx,(%esp)
  801308:	50                   	push   %eax
  801309:	e8 21 ff ff ff       	call   80122f <fd_lookup>
  80130e:	89 c3                	mov    %eax,%ebx
  801310:	83 c4 08             	add    $0x8,%esp
  801313:	85 c0                	test   %eax,%eax
  801315:	78 05                	js     80131c <fd_close+0x31>
	    || fd != fd2)
  801317:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80131a:	74 0d                	je     801329 <fd_close+0x3e>
		return (must_exist ? r : 0);
  80131c:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  801320:	75 48                	jne    80136a <fd_close+0x7f>
  801322:	bb 00 00 00 00       	mov    $0x0,%ebx
  801327:	eb 41                	jmp    80136a <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801329:	83 ec 08             	sub    $0x8,%esp
  80132c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80132f:	50                   	push   %eax
  801330:	ff 36                	pushl  (%esi)
  801332:	e8 4e ff ff ff       	call   801285 <dev_lookup>
  801337:	89 c3                	mov    %eax,%ebx
  801339:	83 c4 10             	add    $0x10,%esp
  80133c:	85 c0                	test   %eax,%eax
  80133e:	78 1c                	js     80135c <fd_close+0x71>
		if (dev->dev_close)
  801340:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801343:	8b 40 10             	mov    0x10(%eax),%eax
  801346:	85 c0                	test   %eax,%eax
  801348:	74 0d                	je     801357 <fd_close+0x6c>
			r = (*dev->dev_close)(fd);
  80134a:	83 ec 0c             	sub    $0xc,%esp
  80134d:	56                   	push   %esi
  80134e:	ff d0                	call   *%eax
  801350:	89 c3                	mov    %eax,%ebx
  801352:	83 c4 10             	add    $0x10,%esp
  801355:	eb 05                	jmp    80135c <fd_close+0x71>
		else
			r = 0;
  801357:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  80135c:	83 ec 08             	sub    $0x8,%esp
  80135f:	56                   	push   %esi
  801360:	6a 00                	push   $0x0
  801362:	e8 1b fa ff ff       	call   800d82 <sys_page_unmap>
	return r;
  801367:	83 c4 10             	add    $0x10,%esp
}
  80136a:	89 d8                	mov    %ebx,%eax
  80136c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80136f:	5b                   	pop    %ebx
  801370:	5e                   	pop    %esi
  801371:	c9                   	leave  
  801372:	c3                   	ret    

00801373 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801373:	55                   	push   %ebp
  801374:	89 e5                	mov    %esp,%ebp
  801376:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801379:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80137c:	50                   	push   %eax
  80137d:	ff 75 08             	pushl  0x8(%ebp)
  801380:	e8 aa fe ff ff       	call   80122f <fd_lookup>
  801385:	83 c4 08             	add    $0x8,%esp
  801388:	85 c0                	test   %eax,%eax
  80138a:	78 10                	js     80139c <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  80138c:	83 ec 08             	sub    $0x8,%esp
  80138f:	6a 01                	push   $0x1
  801391:	ff 75 f4             	pushl  -0xc(%ebp)
  801394:	e8 52 ff ff ff       	call   8012eb <fd_close>
  801399:	83 c4 10             	add    $0x10,%esp
}
  80139c:	c9                   	leave  
  80139d:	c3                   	ret    

0080139e <close_all>:

void
close_all(void)
{
  80139e:	55                   	push   %ebp
  80139f:	89 e5                	mov    %esp,%ebp
  8013a1:	53                   	push   %ebx
  8013a2:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8013a5:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8013aa:	83 ec 0c             	sub    $0xc,%esp
  8013ad:	53                   	push   %ebx
  8013ae:	e8 c0 ff ff ff       	call   801373 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8013b3:	43                   	inc    %ebx
  8013b4:	83 c4 10             	add    $0x10,%esp
  8013b7:	83 fb 20             	cmp    $0x20,%ebx
  8013ba:	75 ee                	jne    8013aa <close_all+0xc>
		close(i);
}
  8013bc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013bf:	c9                   	leave  
  8013c0:	c3                   	ret    

008013c1 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8013c1:	55                   	push   %ebp
  8013c2:	89 e5                	mov    %esp,%ebp
  8013c4:	57                   	push   %edi
  8013c5:	56                   	push   %esi
  8013c6:	53                   	push   %ebx
  8013c7:	83 ec 2c             	sub    $0x2c,%esp
  8013ca:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8013cd:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8013d0:	50                   	push   %eax
  8013d1:	ff 75 08             	pushl  0x8(%ebp)
  8013d4:	e8 56 fe ff ff       	call   80122f <fd_lookup>
  8013d9:	89 c3                	mov    %eax,%ebx
  8013db:	83 c4 08             	add    $0x8,%esp
  8013de:	85 c0                	test   %eax,%eax
  8013e0:	0f 88 c0 00 00 00    	js     8014a6 <dup+0xe5>
		return r;
	close(newfdnum);
  8013e6:	83 ec 0c             	sub    $0xc,%esp
  8013e9:	57                   	push   %edi
  8013ea:	e8 84 ff ff ff       	call   801373 <close>

	newfd = INDEX2FD(newfdnum);
  8013ef:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  8013f5:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  8013f8:	83 c4 04             	add    $0x4,%esp
  8013fb:	ff 75 e4             	pushl  -0x1c(%ebp)
  8013fe:	e8 a1 fd ff ff       	call   8011a4 <fd2data>
  801403:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801405:	89 34 24             	mov    %esi,(%esp)
  801408:	e8 97 fd ff ff       	call   8011a4 <fd2data>
  80140d:	83 c4 10             	add    $0x10,%esp
  801410:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801413:	89 d8                	mov    %ebx,%eax
  801415:	c1 e8 16             	shr    $0x16,%eax
  801418:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80141f:	a8 01                	test   $0x1,%al
  801421:	74 37                	je     80145a <dup+0x99>
  801423:	89 d8                	mov    %ebx,%eax
  801425:	c1 e8 0c             	shr    $0xc,%eax
  801428:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80142f:	f6 c2 01             	test   $0x1,%dl
  801432:	74 26                	je     80145a <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801434:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80143b:	83 ec 0c             	sub    $0xc,%esp
  80143e:	25 07 0e 00 00       	and    $0xe07,%eax
  801443:	50                   	push   %eax
  801444:	ff 75 d4             	pushl  -0x2c(%ebp)
  801447:	6a 00                	push   $0x0
  801449:	53                   	push   %ebx
  80144a:	6a 00                	push   $0x0
  80144c:	e8 0b f9 ff ff       	call   800d5c <sys_page_map>
  801451:	89 c3                	mov    %eax,%ebx
  801453:	83 c4 20             	add    $0x20,%esp
  801456:	85 c0                	test   %eax,%eax
  801458:	78 2d                	js     801487 <dup+0xc6>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80145a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80145d:	89 c2                	mov    %eax,%edx
  80145f:	c1 ea 0c             	shr    $0xc,%edx
  801462:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801469:	83 ec 0c             	sub    $0xc,%esp
  80146c:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  801472:	52                   	push   %edx
  801473:	56                   	push   %esi
  801474:	6a 00                	push   $0x0
  801476:	50                   	push   %eax
  801477:	6a 00                	push   $0x0
  801479:	e8 de f8 ff ff       	call   800d5c <sys_page_map>
  80147e:	89 c3                	mov    %eax,%ebx
  801480:	83 c4 20             	add    $0x20,%esp
  801483:	85 c0                	test   %eax,%eax
  801485:	79 1d                	jns    8014a4 <dup+0xe3>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801487:	83 ec 08             	sub    $0x8,%esp
  80148a:	56                   	push   %esi
  80148b:	6a 00                	push   $0x0
  80148d:	e8 f0 f8 ff ff       	call   800d82 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801492:	83 c4 08             	add    $0x8,%esp
  801495:	ff 75 d4             	pushl  -0x2c(%ebp)
  801498:	6a 00                	push   $0x0
  80149a:	e8 e3 f8 ff ff       	call   800d82 <sys_page_unmap>
	return r;
  80149f:	83 c4 10             	add    $0x10,%esp
  8014a2:	eb 02                	jmp    8014a6 <dup+0xe5>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  8014a4:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  8014a6:	89 d8                	mov    %ebx,%eax
  8014a8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8014ab:	5b                   	pop    %ebx
  8014ac:	5e                   	pop    %esi
  8014ad:	5f                   	pop    %edi
  8014ae:	c9                   	leave  
  8014af:	c3                   	ret    

008014b0 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8014b0:	55                   	push   %ebp
  8014b1:	89 e5                	mov    %esp,%ebp
  8014b3:	53                   	push   %ebx
  8014b4:	83 ec 14             	sub    $0x14,%esp
  8014b7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8014ba:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014bd:	50                   	push   %eax
  8014be:	53                   	push   %ebx
  8014bf:	e8 6b fd ff ff       	call   80122f <fd_lookup>
  8014c4:	83 c4 08             	add    $0x8,%esp
  8014c7:	85 c0                	test   %eax,%eax
  8014c9:	78 67                	js     801532 <read+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014cb:	83 ec 08             	sub    $0x8,%esp
  8014ce:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014d1:	50                   	push   %eax
  8014d2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014d5:	ff 30                	pushl  (%eax)
  8014d7:	e8 a9 fd ff ff       	call   801285 <dev_lookup>
  8014dc:	83 c4 10             	add    $0x10,%esp
  8014df:	85 c0                	test   %eax,%eax
  8014e1:	78 4f                	js     801532 <read+0x82>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8014e3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014e6:	8b 50 08             	mov    0x8(%eax),%edx
  8014e9:	83 e2 03             	and    $0x3,%edx
  8014ec:	83 fa 01             	cmp    $0x1,%edx
  8014ef:	75 21                	jne    801512 <read+0x62>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8014f1:	a1 20 44 80 00       	mov    0x804420,%eax
  8014f6:	8b 40 48             	mov    0x48(%eax),%eax
  8014f9:	83 ec 04             	sub    $0x4,%esp
  8014fc:	53                   	push   %ebx
  8014fd:	50                   	push   %eax
  8014fe:	68 71 29 80 00       	push   $0x802971
  801503:	e8 f8 ed ff ff       	call   800300 <cprintf>
		return -E_INVAL;
  801508:	83 c4 10             	add    $0x10,%esp
  80150b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801510:	eb 20                	jmp    801532 <read+0x82>
	}
	if (!dev->dev_read)
  801512:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801515:	8b 52 08             	mov    0x8(%edx),%edx
  801518:	85 d2                	test   %edx,%edx
  80151a:	74 11                	je     80152d <read+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80151c:	83 ec 04             	sub    $0x4,%esp
  80151f:	ff 75 10             	pushl  0x10(%ebp)
  801522:	ff 75 0c             	pushl  0xc(%ebp)
  801525:	50                   	push   %eax
  801526:	ff d2                	call   *%edx
  801528:	83 c4 10             	add    $0x10,%esp
  80152b:	eb 05                	jmp    801532 <read+0x82>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80152d:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  801532:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801535:	c9                   	leave  
  801536:	c3                   	ret    

00801537 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801537:	55                   	push   %ebp
  801538:	89 e5                	mov    %esp,%ebp
  80153a:	57                   	push   %edi
  80153b:	56                   	push   %esi
  80153c:	53                   	push   %ebx
  80153d:	83 ec 0c             	sub    $0xc,%esp
  801540:	8b 7d 08             	mov    0x8(%ebp),%edi
  801543:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801546:	85 f6                	test   %esi,%esi
  801548:	74 31                	je     80157b <readn+0x44>
  80154a:	b8 00 00 00 00       	mov    $0x0,%eax
  80154f:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = read(fdnum, (char*)buf + tot, n - tot);
  801554:	83 ec 04             	sub    $0x4,%esp
  801557:	89 f2                	mov    %esi,%edx
  801559:	29 c2                	sub    %eax,%edx
  80155b:	52                   	push   %edx
  80155c:	03 45 0c             	add    0xc(%ebp),%eax
  80155f:	50                   	push   %eax
  801560:	57                   	push   %edi
  801561:	e8 4a ff ff ff       	call   8014b0 <read>
		if (m < 0)
  801566:	83 c4 10             	add    $0x10,%esp
  801569:	85 c0                	test   %eax,%eax
  80156b:	78 17                	js     801584 <readn+0x4d>
			return m;
		if (m == 0)
  80156d:	85 c0                	test   %eax,%eax
  80156f:	74 11                	je     801582 <readn+0x4b>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801571:	01 c3                	add    %eax,%ebx
  801573:	89 d8                	mov    %ebx,%eax
  801575:	39 f3                	cmp    %esi,%ebx
  801577:	72 db                	jb     801554 <readn+0x1d>
  801579:	eb 09                	jmp    801584 <readn+0x4d>
  80157b:	b8 00 00 00 00       	mov    $0x0,%eax
  801580:	eb 02                	jmp    801584 <readn+0x4d>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  801582:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  801584:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801587:	5b                   	pop    %ebx
  801588:	5e                   	pop    %esi
  801589:	5f                   	pop    %edi
  80158a:	c9                   	leave  
  80158b:	c3                   	ret    

0080158c <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80158c:	55                   	push   %ebp
  80158d:	89 e5                	mov    %esp,%ebp
  80158f:	53                   	push   %ebx
  801590:	83 ec 14             	sub    $0x14,%esp
  801593:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801596:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801599:	50                   	push   %eax
  80159a:	53                   	push   %ebx
  80159b:	e8 8f fc ff ff       	call   80122f <fd_lookup>
  8015a0:	83 c4 08             	add    $0x8,%esp
  8015a3:	85 c0                	test   %eax,%eax
  8015a5:	78 62                	js     801609 <write+0x7d>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015a7:	83 ec 08             	sub    $0x8,%esp
  8015aa:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015ad:	50                   	push   %eax
  8015ae:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015b1:	ff 30                	pushl  (%eax)
  8015b3:	e8 cd fc ff ff       	call   801285 <dev_lookup>
  8015b8:	83 c4 10             	add    $0x10,%esp
  8015bb:	85 c0                	test   %eax,%eax
  8015bd:	78 4a                	js     801609 <write+0x7d>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8015bf:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015c2:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8015c6:	75 21                	jne    8015e9 <write+0x5d>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8015c8:	a1 20 44 80 00       	mov    0x804420,%eax
  8015cd:	8b 40 48             	mov    0x48(%eax),%eax
  8015d0:	83 ec 04             	sub    $0x4,%esp
  8015d3:	53                   	push   %ebx
  8015d4:	50                   	push   %eax
  8015d5:	68 8d 29 80 00       	push   $0x80298d
  8015da:	e8 21 ed ff ff       	call   800300 <cprintf>
		return -E_INVAL;
  8015df:	83 c4 10             	add    $0x10,%esp
  8015e2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8015e7:	eb 20                	jmp    801609 <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8015e9:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8015ec:	8b 52 0c             	mov    0xc(%edx),%edx
  8015ef:	85 d2                	test   %edx,%edx
  8015f1:	74 11                	je     801604 <write+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8015f3:	83 ec 04             	sub    $0x4,%esp
  8015f6:	ff 75 10             	pushl  0x10(%ebp)
  8015f9:	ff 75 0c             	pushl  0xc(%ebp)
  8015fc:	50                   	push   %eax
  8015fd:	ff d2                	call   *%edx
  8015ff:	83 c4 10             	add    $0x10,%esp
  801602:	eb 05                	jmp    801609 <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801604:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  801609:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80160c:	c9                   	leave  
  80160d:	c3                   	ret    

0080160e <seek>:

int
seek(int fdnum, off_t offset)
{
  80160e:	55                   	push   %ebp
  80160f:	89 e5                	mov    %esp,%ebp
  801611:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801614:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801617:	50                   	push   %eax
  801618:	ff 75 08             	pushl  0x8(%ebp)
  80161b:	e8 0f fc ff ff       	call   80122f <fd_lookup>
  801620:	83 c4 08             	add    $0x8,%esp
  801623:	85 c0                	test   %eax,%eax
  801625:	78 0e                	js     801635 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801627:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80162a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80162d:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801630:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801635:	c9                   	leave  
  801636:	c3                   	ret    

00801637 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801637:	55                   	push   %ebp
  801638:	89 e5                	mov    %esp,%ebp
  80163a:	53                   	push   %ebx
  80163b:	83 ec 14             	sub    $0x14,%esp
  80163e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801641:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801644:	50                   	push   %eax
  801645:	53                   	push   %ebx
  801646:	e8 e4 fb ff ff       	call   80122f <fd_lookup>
  80164b:	83 c4 08             	add    $0x8,%esp
  80164e:	85 c0                	test   %eax,%eax
  801650:	78 5f                	js     8016b1 <ftruncate+0x7a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801652:	83 ec 08             	sub    $0x8,%esp
  801655:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801658:	50                   	push   %eax
  801659:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80165c:	ff 30                	pushl  (%eax)
  80165e:	e8 22 fc ff ff       	call   801285 <dev_lookup>
  801663:	83 c4 10             	add    $0x10,%esp
  801666:	85 c0                	test   %eax,%eax
  801668:	78 47                	js     8016b1 <ftruncate+0x7a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80166a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80166d:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801671:	75 21                	jne    801694 <ftruncate+0x5d>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801673:	a1 20 44 80 00       	mov    0x804420,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801678:	8b 40 48             	mov    0x48(%eax),%eax
  80167b:	83 ec 04             	sub    $0x4,%esp
  80167e:	53                   	push   %ebx
  80167f:	50                   	push   %eax
  801680:	68 50 29 80 00       	push   $0x802950
  801685:	e8 76 ec ff ff       	call   800300 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80168a:	83 c4 10             	add    $0x10,%esp
  80168d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801692:	eb 1d                	jmp    8016b1 <ftruncate+0x7a>
	}
	if (!dev->dev_trunc)
  801694:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801697:	8b 52 18             	mov    0x18(%edx),%edx
  80169a:	85 d2                	test   %edx,%edx
  80169c:	74 0e                	je     8016ac <ftruncate+0x75>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80169e:	83 ec 08             	sub    $0x8,%esp
  8016a1:	ff 75 0c             	pushl  0xc(%ebp)
  8016a4:	50                   	push   %eax
  8016a5:	ff d2                	call   *%edx
  8016a7:	83 c4 10             	add    $0x10,%esp
  8016aa:	eb 05                	jmp    8016b1 <ftruncate+0x7a>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8016ac:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  8016b1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016b4:	c9                   	leave  
  8016b5:	c3                   	ret    

008016b6 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8016b6:	55                   	push   %ebp
  8016b7:	89 e5                	mov    %esp,%ebp
  8016b9:	53                   	push   %ebx
  8016ba:	83 ec 14             	sub    $0x14,%esp
  8016bd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016c0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016c3:	50                   	push   %eax
  8016c4:	ff 75 08             	pushl  0x8(%ebp)
  8016c7:	e8 63 fb ff ff       	call   80122f <fd_lookup>
  8016cc:	83 c4 08             	add    $0x8,%esp
  8016cf:	85 c0                	test   %eax,%eax
  8016d1:	78 52                	js     801725 <fstat+0x6f>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016d3:	83 ec 08             	sub    $0x8,%esp
  8016d6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016d9:	50                   	push   %eax
  8016da:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016dd:	ff 30                	pushl  (%eax)
  8016df:	e8 a1 fb ff ff       	call   801285 <dev_lookup>
  8016e4:	83 c4 10             	add    $0x10,%esp
  8016e7:	85 c0                	test   %eax,%eax
  8016e9:	78 3a                	js     801725 <fstat+0x6f>
		return r;
	if (!dev->dev_stat)
  8016eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016ee:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8016f2:	74 2c                	je     801720 <fstat+0x6a>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8016f4:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8016f7:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8016fe:	00 00 00 
	stat->st_isdir = 0;
  801701:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801708:	00 00 00 
	stat->st_dev = dev;
  80170b:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801711:	83 ec 08             	sub    $0x8,%esp
  801714:	53                   	push   %ebx
  801715:	ff 75 f0             	pushl  -0x10(%ebp)
  801718:	ff 50 14             	call   *0x14(%eax)
  80171b:	83 c4 10             	add    $0x10,%esp
  80171e:	eb 05                	jmp    801725 <fstat+0x6f>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801720:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801725:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801728:	c9                   	leave  
  801729:	c3                   	ret    

0080172a <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80172a:	55                   	push   %ebp
  80172b:	89 e5                	mov    %esp,%ebp
  80172d:	56                   	push   %esi
  80172e:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80172f:	83 ec 08             	sub    $0x8,%esp
  801732:	6a 00                	push   $0x0
  801734:	ff 75 08             	pushl  0x8(%ebp)
  801737:	e8 78 01 00 00       	call   8018b4 <open>
  80173c:	89 c3                	mov    %eax,%ebx
  80173e:	83 c4 10             	add    $0x10,%esp
  801741:	85 c0                	test   %eax,%eax
  801743:	78 1b                	js     801760 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801745:	83 ec 08             	sub    $0x8,%esp
  801748:	ff 75 0c             	pushl  0xc(%ebp)
  80174b:	50                   	push   %eax
  80174c:	e8 65 ff ff ff       	call   8016b6 <fstat>
  801751:	89 c6                	mov    %eax,%esi
	close(fd);
  801753:	89 1c 24             	mov    %ebx,(%esp)
  801756:	e8 18 fc ff ff       	call   801373 <close>
	return r;
  80175b:	83 c4 10             	add    $0x10,%esp
  80175e:	89 f3                	mov    %esi,%ebx
}
  801760:	89 d8                	mov    %ebx,%eax
  801762:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801765:	5b                   	pop    %ebx
  801766:	5e                   	pop    %esi
  801767:	c9                   	leave  
  801768:	c3                   	ret    
  801769:	00 00                	add    %al,(%eax)
	...

0080176c <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80176c:	55                   	push   %ebp
  80176d:	89 e5                	mov    %esp,%ebp
  80176f:	56                   	push   %esi
  801770:	53                   	push   %ebx
  801771:	89 c3                	mov    %eax,%ebx
  801773:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  801775:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  80177c:	75 12                	jne    801790 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80177e:	83 ec 0c             	sub    $0xc,%esp
  801781:	6a 01                	push   $0x1
  801783:	e8 a6 08 00 00       	call   80202e <ipc_find_env>
  801788:	a3 00 40 80 00       	mov    %eax,0x804000
  80178d:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801790:	6a 07                	push   $0x7
  801792:	68 00 50 80 00       	push   $0x805000
  801797:	53                   	push   %ebx
  801798:	ff 35 00 40 80 00    	pushl  0x804000
  80179e:	e8 36 08 00 00       	call   801fd9 <ipc_send>
	
	return ipc_recv(NULL, dstva, NULL);
  8017a3:	83 c4 0c             	add    $0xc,%esp
  8017a6:	6a 00                	push   $0x0
  8017a8:	56                   	push   %esi
  8017a9:	6a 00                	push   $0x0
  8017ab:	e8 b4 07 00 00       	call   801f64 <ipc_recv>
}
  8017b0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017b3:	5b                   	pop    %ebx
  8017b4:	5e                   	pop    %esi
  8017b5:	c9                   	leave  
  8017b6:	c3                   	ret    

008017b7 <devfile_stat>:
}


static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8017b7:	55                   	push   %ebp
  8017b8:	89 e5                	mov    %esp,%ebp
  8017ba:	53                   	push   %ebx
  8017bb:	83 ec 04             	sub    $0x4,%esp
  8017be:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8017c1:	8b 45 08             	mov    0x8(%ebp),%eax
  8017c4:	8b 40 0c             	mov    0xc(%eax),%eax
  8017c7:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0) {
  8017cc:	ba 00 00 00 00       	mov    $0x0,%edx
  8017d1:	b8 05 00 00 00       	mov    $0x5,%eax
  8017d6:	e8 91 ff ff ff       	call   80176c <fsipc>
  8017db:	85 c0                	test   %eax,%eax
  8017dd:	78 2c                	js     80180b <devfile_stat+0x54>
		return r;
	}
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8017df:	83 ec 08             	sub    $0x8,%esp
  8017e2:	68 00 50 80 00       	push   $0x805000
  8017e7:	53                   	push   %ebx
  8017e8:	e8 c9 f0 ff ff       	call   8008b6 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8017ed:	a1 80 50 80 00       	mov    0x805080,%eax
  8017f2:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8017f8:	a1 84 50 80 00       	mov    0x805084,%eax
  8017fd:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801803:	83 c4 10             	add    $0x10,%esp
  801806:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80180b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80180e:	c9                   	leave  
  80180f:	c3                   	ret    

00801810 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801810:	55                   	push   %ebp
  801811:	89 e5                	mov    %esp,%ebp
  801813:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801816:	8b 45 08             	mov    0x8(%ebp),%eax
  801819:	8b 40 0c             	mov    0xc(%eax),%eax
  80181c:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801821:	ba 00 00 00 00       	mov    $0x0,%edx
  801826:	b8 06 00 00 00       	mov    $0x6,%eax
  80182b:	e8 3c ff ff ff       	call   80176c <fsipc>
}
  801830:	c9                   	leave  
  801831:	c3                   	ret    

00801832 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801832:	55                   	push   %ebp
  801833:	89 e5                	mov    %esp,%ebp
  801835:	56                   	push   %esi
  801836:	53                   	push   %ebx
  801837:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80183a:	8b 45 08             	mov    0x8(%ebp),%eax
  80183d:	8b 40 0c             	mov    0xc(%eax),%eax
  801840:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801845:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80184b:	ba 00 00 00 00       	mov    $0x0,%edx
  801850:	b8 03 00 00 00       	mov    $0x3,%eax
  801855:	e8 12 ff ff ff       	call   80176c <fsipc>
  80185a:	89 c3                	mov    %eax,%ebx
  80185c:	85 c0                	test   %eax,%eax
  80185e:	78 4b                	js     8018ab <devfile_read+0x79>
		return r;
	assert(r <= n);
  801860:	39 c6                	cmp    %eax,%esi
  801862:	73 16                	jae    80187a <devfile_read+0x48>
  801864:	68 bc 29 80 00       	push   $0x8029bc
  801869:	68 c3 29 80 00       	push   $0x8029c3
  80186e:	6a 7d                	push   $0x7d
  801870:	68 d8 29 80 00       	push   $0x8029d8
  801875:	e8 ae e9 ff ff       	call   800228 <_panic>
	assert(r <= PGSIZE);
  80187a:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80187f:	7e 16                	jle    801897 <devfile_read+0x65>
  801881:	68 e3 29 80 00       	push   $0x8029e3
  801886:	68 c3 29 80 00       	push   $0x8029c3
  80188b:	6a 7e                	push   $0x7e
  80188d:	68 d8 29 80 00       	push   $0x8029d8
  801892:	e8 91 e9 ff ff       	call   800228 <_panic>
	memmove(buf, &fsipcbuf, r);
  801897:	83 ec 04             	sub    $0x4,%esp
  80189a:	50                   	push   %eax
  80189b:	68 00 50 80 00       	push   $0x805000
  8018a0:	ff 75 0c             	pushl  0xc(%ebp)
  8018a3:	e8 cf f1 ff ff       	call   800a77 <memmove>
	return r;
  8018a8:	83 c4 10             	add    $0x10,%esp
}
  8018ab:	89 d8                	mov    %ebx,%eax
  8018ad:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018b0:	5b                   	pop    %ebx
  8018b1:	5e                   	pop    %esi
  8018b2:	c9                   	leave  
  8018b3:	c3                   	ret    

008018b4 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8018b4:	55                   	push   %ebp
  8018b5:	89 e5                	mov    %esp,%ebp
  8018b7:	56                   	push   %esi
  8018b8:	53                   	push   %ebx
  8018b9:	83 ec 1c             	sub    $0x1c,%esp
  8018bc:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8018bf:	56                   	push   %esi
  8018c0:	e8 9f ef ff ff       	call   800864 <strlen>
  8018c5:	83 c4 10             	add    $0x10,%esp
  8018c8:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8018cd:	7f 65                	jg     801934 <open+0x80>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8018cf:	83 ec 0c             	sub    $0xc,%esp
  8018d2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018d5:	50                   	push   %eax
  8018d6:	e8 e1 f8 ff ff       	call   8011bc <fd_alloc>
  8018db:	89 c3                	mov    %eax,%ebx
  8018dd:	83 c4 10             	add    $0x10,%esp
  8018e0:	85 c0                	test   %eax,%eax
  8018e2:	78 55                	js     801939 <open+0x85>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8018e4:	83 ec 08             	sub    $0x8,%esp
  8018e7:	56                   	push   %esi
  8018e8:	68 00 50 80 00       	push   $0x805000
  8018ed:	e8 c4 ef ff ff       	call   8008b6 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8018f2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018f5:	a3 00 54 80 00       	mov    %eax,0x805400



	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8018fa:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8018fd:	b8 01 00 00 00       	mov    $0x1,%eax
  801902:	e8 65 fe ff ff       	call   80176c <fsipc>
  801907:	89 c3                	mov    %eax,%ebx
  801909:	83 c4 10             	add    $0x10,%esp
  80190c:	85 c0                	test   %eax,%eax
  80190e:	79 12                	jns    801922 <open+0x6e>
		fd_close(fd, 0);
  801910:	83 ec 08             	sub    $0x8,%esp
  801913:	6a 00                	push   $0x0
  801915:	ff 75 f4             	pushl  -0xc(%ebp)
  801918:	e8 ce f9 ff ff       	call   8012eb <fd_close>
		return r;
  80191d:	83 c4 10             	add    $0x10,%esp
  801920:	eb 17                	jmp    801939 <open+0x85>
	}

	return fd2num(fd);
  801922:	83 ec 0c             	sub    $0xc,%esp
  801925:	ff 75 f4             	pushl  -0xc(%ebp)
  801928:	e8 67 f8 ff ff       	call   801194 <fd2num>
  80192d:	89 c3                	mov    %eax,%ebx
  80192f:	83 c4 10             	add    $0x10,%esp
  801932:	eb 05                	jmp    801939 <open+0x85>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801934:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801939:	89 d8                	mov    %ebx,%eax
  80193b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80193e:	5b                   	pop    %ebx
  80193f:	5e                   	pop    %esi
  801940:	c9                   	leave  
  801941:	c3                   	ret    
	...

00801944 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801944:	55                   	push   %ebp
  801945:	89 e5                	mov    %esp,%ebp
  801947:	56                   	push   %esi
  801948:	53                   	push   %ebx
  801949:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  80194c:	83 ec 0c             	sub    $0xc,%esp
  80194f:	ff 75 08             	pushl  0x8(%ebp)
  801952:	e8 4d f8 ff ff       	call   8011a4 <fd2data>
  801957:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  801959:	83 c4 08             	add    $0x8,%esp
  80195c:	68 ef 29 80 00       	push   $0x8029ef
  801961:	56                   	push   %esi
  801962:	e8 4f ef ff ff       	call   8008b6 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801967:	8b 43 04             	mov    0x4(%ebx),%eax
  80196a:	2b 03                	sub    (%ebx),%eax
  80196c:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  801972:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  801979:	00 00 00 
	stat->st_dev = &devpipe;
  80197c:	c7 86 88 00 00 00 20 	movl   $0x803020,0x88(%esi)
  801983:	30 80 00 
	return 0;
}
  801986:	b8 00 00 00 00       	mov    $0x0,%eax
  80198b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80198e:	5b                   	pop    %ebx
  80198f:	5e                   	pop    %esi
  801990:	c9                   	leave  
  801991:	c3                   	ret    

00801992 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801992:	55                   	push   %ebp
  801993:	89 e5                	mov    %esp,%ebp
  801995:	53                   	push   %ebx
  801996:	83 ec 0c             	sub    $0xc,%esp
  801999:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  80199c:	53                   	push   %ebx
  80199d:	6a 00                	push   $0x0
  80199f:	e8 de f3 ff ff       	call   800d82 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8019a4:	89 1c 24             	mov    %ebx,(%esp)
  8019a7:	e8 f8 f7 ff ff       	call   8011a4 <fd2data>
  8019ac:	83 c4 08             	add    $0x8,%esp
  8019af:	50                   	push   %eax
  8019b0:	6a 00                	push   $0x0
  8019b2:	e8 cb f3 ff ff       	call   800d82 <sys_page_unmap>
}
  8019b7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019ba:	c9                   	leave  
  8019bb:	c3                   	ret    

008019bc <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8019bc:	55                   	push   %ebp
  8019bd:	89 e5                	mov    %esp,%ebp
  8019bf:	57                   	push   %edi
  8019c0:	56                   	push   %esi
  8019c1:	53                   	push   %ebx
  8019c2:	83 ec 1c             	sub    $0x1c,%esp
  8019c5:	89 c7                	mov    %eax,%edi
  8019c7:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8019ca:	a1 20 44 80 00       	mov    0x804420,%eax
  8019cf:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  8019d2:	83 ec 0c             	sub    $0xc,%esp
  8019d5:	57                   	push   %edi
  8019d6:	e8 b1 06 00 00       	call   80208c <pageref>
  8019db:	89 c6                	mov    %eax,%esi
  8019dd:	83 c4 04             	add    $0x4,%esp
  8019e0:	ff 75 e4             	pushl  -0x1c(%ebp)
  8019e3:	e8 a4 06 00 00       	call   80208c <pageref>
  8019e8:	83 c4 10             	add    $0x10,%esp
  8019eb:	39 c6                	cmp    %eax,%esi
  8019ed:	0f 94 c0             	sete   %al
  8019f0:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  8019f3:	8b 15 20 44 80 00    	mov    0x804420,%edx
  8019f9:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  8019fc:	39 cb                	cmp    %ecx,%ebx
  8019fe:	75 08                	jne    801a08 <_pipeisclosed+0x4c>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  801a00:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a03:	5b                   	pop    %ebx
  801a04:	5e                   	pop    %esi
  801a05:	5f                   	pop    %edi
  801a06:	c9                   	leave  
  801a07:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  801a08:	83 f8 01             	cmp    $0x1,%eax
  801a0b:	75 bd                	jne    8019ca <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801a0d:	8b 42 58             	mov    0x58(%edx),%eax
  801a10:	6a 01                	push   $0x1
  801a12:	50                   	push   %eax
  801a13:	53                   	push   %ebx
  801a14:	68 f6 29 80 00       	push   $0x8029f6
  801a19:	e8 e2 e8 ff ff       	call   800300 <cprintf>
  801a1e:	83 c4 10             	add    $0x10,%esp
  801a21:	eb a7                	jmp    8019ca <_pipeisclosed+0xe>

00801a23 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801a23:	55                   	push   %ebp
  801a24:	89 e5                	mov    %esp,%ebp
  801a26:	57                   	push   %edi
  801a27:	56                   	push   %esi
  801a28:	53                   	push   %ebx
  801a29:	83 ec 28             	sub    $0x28,%esp
  801a2c:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801a2f:	56                   	push   %esi
  801a30:	e8 6f f7 ff ff       	call   8011a4 <fd2data>
  801a35:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801a37:	83 c4 10             	add    $0x10,%esp
  801a3a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801a3e:	75 4a                	jne    801a8a <devpipe_write+0x67>
  801a40:	bf 00 00 00 00       	mov    $0x0,%edi
  801a45:	eb 56                	jmp    801a9d <devpipe_write+0x7a>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801a47:	89 da                	mov    %ebx,%edx
  801a49:	89 f0                	mov    %esi,%eax
  801a4b:	e8 6c ff ff ff       	call   8019bc <_pipeisclosed>
  801a50:	85 c0                	test   %eax,%eax
  801a52:	75 4d                	jne    801aa1 <devpipe_write+0x7e>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801a54:	e8 b8 f2 ff ff       	call   800d11 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801a59:	8b 43 04             	mov    0x4(%ebx),%eax
  801a5c:	8b 13                	mov    (%ebx),%edx
  801a5e:	83 c2 20             	add    $0x20,%edx
  801a61:	39 d0                	cmp    %edx,%eax
  801a63:	73 e2                	jae    801a47 <devpipe_write+0x24>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801a65:	89 c2                	mov    %eax,%edx
  801a67:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  801a6d:	79 05                	jns    801a74 <devpipe_write+0x51>
  801a6f:	4a                   	dec    %edx
  801a70:	83 ca e0             	or     $0xffffffe0,%edx
  801a73:	42                   	inc    %edx
  801a74:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801a77:	8a 0c 39             	mov    (%ecx,%edi,1),%cl
  801a7a:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801a7e:	40                   	inc    %eax
  801a7f:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801a82:	47                   	inc    %edi
  801a83:	39 7d 10             	cmp    %edi,0x10(%ebp)
  801a86:	77 07                	ja     801a8f <devpipe_write+0x6c>
  801a88:	eb 13                	jmp    801a9d <devpipe_write+0x7a>
  801a8a:	bf 00 00 00 00       	mov    $0x0,%edi
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801a8f:	8b 43 04             	mov    0x4(%ebx),%eax
  801a92:	8b 13                	mov    (%ebx),%edx
  801a94:	83 c2 20             	add    $0x20,%edx
  801a97:	39 d0                	cmp    %edx,%eax
  801a99:	73 ac                	jae    801a47 <devpipe_write+0x24>
  801a9b:	eb c8                	jmp    801a65 <devpipe_write+0x42>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801a9d:	89 f8                	mov    %edi,%eax
  801a9f:	eb 05                	jmp    801aa6 <devpipe_write+0x83>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801aa1:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801aa6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801aa9:	5b                   	pop    %ebx
  801aaa:	5e                   	pop    %esi
  801aab:	5f                   	pop    %edi
  801aac:	c9                   	leave  
  801aad:	c3                   	ret    

00801aae <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801aae:	55                   	push   %ebp
  801aaf:	89 e5                	mov    %esp,%ebp
  801ab1:	57                   	push   %edi
  801ab2:	56                   	push   %esi
  801ab3:	53                   	push   %ebx
  801ab4:	83 ec 18             	sub    $0x18,%esp
  801ab7:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801aba:	57                   	push   %edi
  801abb:	e8 e4 f6 ff ff       	call   8011a4 <fd2data>
  801ac0:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801ac2:	83 c4 10             	add    $0x10,%esp
  801ac5:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801ac9:	75 44                	jne    801b0f <devpipe_read+0x61>
  801acb:	be 00 00 00 00       	mov    $0x0,%esi
  801ad0:	eb 4f                	jmp    801b21 <devpipe_read+0x73>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
				return i;
  801ad2:	89 f0                	mov    %esi,%eax
  801ad4:	eb 54                	jmp    801b2a <devpipe_read+0x7c>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801ad6:	89 da                	mov    %ebx,%edx
  801ad8:	89 f8                	mov    %edi,%eax
  801ada:	e8 dd fe ff ff       	call   8019bc <_pipeisclosed>
  801adf:	85 c0                	test   %eax,%eax
  801ae1:	75 42                	jne    801b25 <devpipe_read+0x77>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801ae3:	e8 29 f2 ff ff       	call   800d11 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801ae8:	8b 03                	mov    (%ebx),%eax
  801aea:	3b 43 04             	cmp    0x4(%ebx),%eax
  801aed:	74 e7                	je     801ad6 <devpipe_read+0x28>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801aef:	25 1f 00 00 80       	and    $0x8000001f,%eax
  801af4:	79 05                	jns    801afb <devpipe_read+0x4d>
  801af6:	48                   	dec    %eax
  801af7:	83 c8 e0             	or     $0xffffffe0,%eax
  801afa:	40                   	inc    %eax
  801afb:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  801aff:	8b 55 0c             	mov    0xc(%ebp),%edx
  801b02:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  801b05:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b07:	46                   	inc    %esi
  801b08:	39 75 10             	cmp    %esi,0x10(%ebp)
  801b0b:	77 07                	ja     801b14 <devpipe_read+0x66>
  801b0d:	eb 12                	jmp    801b21 <devpipe_read+0x73>
  801b0f:	be 00 00 00 00       	mov    $0x0,%esi
		while (p->p_rpos == p->p_wpos) {
  801b14:	8b 03                	mov    (%ebx),%eax
  801b16:	3b 43 04             	cmp    0x4(%ebx),%eax
  801b19:	75 d4                	jne    801aef <devpipe_read+0x41>
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801b1b:	85 f6                	test   %esi,%esi
  801b1d:	75 b3                	jne    801ad2 <devpipe_read+0x24>
  801b1f:	eb b5                	jmp    801ad6 <devpipe_read+0x28>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801b21:	89 f0                	mov    %esi,%eax
  801b23:	eb 05                	jmp    801b2a <devpipe_read+0x7c>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801b25:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801b2a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b2d:	5b                   	pop    %ebx
  801b2e:	5e                   	pop    %esi
  801b2f:	5f                   	pop    %edi
  801b30:	c9                   	leave  
  801b31:	c3                   	ret    

00801b32 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801b32:	55                   	push   %ebp
  801b33:	89 e5                	mov    %esp,%ebp
  801b35:	57                   	push   %edi
  801b36:	56                   	push   %esi
  801b37:	53                   	push   %ebx
  801b38:	83 ec 28             	sub    $0x28,%esp
  801b3b:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801b3e:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801b41:	50                   	push   %eax
  801b42:	e8 75 f6 ff ff       	call   8011bc <fd_alloc>
  801b47:	89 c3                	mov    %eax,%ebx
  801b49:	83 c4 10             	add    $0x10,%esp
  801b4c:	85 c0                	test   %eax,%eax
  801b4e:	0f 88 24 01 00 00    	js     801c78 <pipe+0x146>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b54:	83 ec 04             	sub    $0x4,%esp
  801b57:	68 07 04 00 00       	push   $0x407
  801b5c:	ff 75 e4             	pushl  -0x1c(%ebp)
  801b5f:	6a 00                	push   $0x0
  801b61:	e8 d2 f1 ff ff       	call   800d38 <sys_page_alloc>
  801b66:	89 c3                	mov    %eax,%ebx
  801b68:	83 c4 10             	add    $0x10,%esp
  801b6b:	85 c0                	test   %eax,%eax
  801b6d:	0f 88 05 01 00 00    	js     801c78 <pipe+0x146>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801b73:	83 ec 0c             	sub    $0xc,%esp
  801b76:	8d 45 e0             	lea    -0x20(%ebp),%eax
  801b79:	50                   	push   %eax
  801b7a:	e8 3d f6 ff ff       	call   8011bc <fd_alloc>
  801b7f:	89 c3                	mov    %eax,%ebx
  801b81:	83 c4 10             	add    $0x10,%esp
  801b84:	85 c0                	test   %eax,%eax
  801b86:	0f 88 dc 00 00 00    	js     801c68 <pipe+0x136>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b8c:	83 ec 04             	sub    $0x4,%esp
  801b8f:	68 07 04 00 00       	push   $0x407
  801b94:	ff 75 e0             	pushl  -0x20(%ebp)
  801b97:	6a 00                	push   $0x0
  801b99:	e8 9a f1 ff ff       	call   800d38 <sys_page_alloc>
  801b9e:	89 c3                	mov    %eax,%ebx
  801ba0:	83 c4 10             	add    $0x10,%esp
  801ba3:	85 c0                	test   %eax,%eax
  801ba5:	0f 88 bd 00 00 00    	js     801c68 <pipe+0x136>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801bab:	83 ec 0c             	sub    $0xc,%esp
  801bae:	ff 75 e4             	pushl  -0x1c(%ebp)
  801bb1:	e8 ee f5 ff ff       	call   8011a4 <fd2data>
  801bb6:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801bb8:	83 c4 0c             	add    $0xc,%esp
  801bbb:	68 07 04 00 00       	push   $0x407
  801bc0:	50                   	push   %eax
  801bc1:	6a 00                	push   $0x0
  801bc3:	e8 70 f1 ff ff       	call   800d38 <sys_page_alloc>
  801bc8:	89 c3                	mov    %eax,%ebx
  801bca:	83 c4 10             	add    $0x10,%esp
  801bcd:	85 c0                	test   %eax,%eax
  801bcf:	0f 88 83 00 00 00    	js     801c58 <pipe+0x126>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801bd5:	83 ec 0c             	sub    $0xc,%esp
  801bd8:	ff 75 e0             	pushl  -0x20(%ebp)
  801bdb:	e8 c4 f5 ff ff       	call   8011a4 <fd2data>
  801be0:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801be7:	50                   	push   %eax
  801be8:	6a 00                	push   $0x0
  801bea:	56                   	push   %esi
  801beb:	6a 00                	push   $0x0
  801bed:	e8 6a f1 ff ff       	call   800d5c <sys_page_map>
  801bf2:	89 c3                	mov    %eax,%ebx
  801bf4:	83 c4 20             	add    $0x20,%esp
  801bf7:	85 c0                	test   %eax,%eax
  801bf9:	78 4f                	js     801c4a <pipe+0x118>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801bfb:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801c01:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801c04:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801c06:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801c09:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801c10:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801c16:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801c19:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801c1b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801c1e:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801c25:	83 ec 0c             	sub    $0xc,%esp
  801c28:	ff 75 e4             	pushl  -0x1c(%ebp)
  801c2b:	e8 64 f5 ff ff       	call   801194 <fd2num>
  801c30:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  801c32:	83 c4 04             	add    $0x4,%esp
  801c35:	ff 75 e0             	pushl  -0x20(%ebp)
  801c38:	e8 57 f5 ff ff       	call   801194 <fd2num>
  801c3d:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  801c40:	83 c4 10             	add    $0x10,%esp
  801c43:	bb 00 00 00 00       	mov    $0x0,%ebx
  801c48:	eb 2e                	jmp    801c78 <pipe+0x146>

    err3:
	sys_page_unmap(0, va);
  801c4a:	83 ec 08             	sub    $0x8,%esp
  801c4d:	56                   	push   %esi
  801c4e:	6a 00                	push   $0x0
  801c50:	e8 2d f1 ff ff       	call   800d82 <sys_page_unmap>
  801c55:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801c58:	83 ec 08             	sub    $0x8,%esp
  801c5b:	ff 75 e0             	pushl  -0x20(%ebp)
  801c5e:	6a 00                	push   $0x0
  801c60:	e8 1d f1 ff ff       	call   800d82 <sys_page_unmap>
  801c65:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801c68:	83 ec 08             	sub    $0x8,%esp
  801c6b:	ff 75 e4             	pushl  -0x1c(%ebp)
  801c6e:	6a 00                	push   $0x0
  801c70:	e8 0d f1 ff ff       	call   800d82 <sys_page_unmap>
  801c75:	83 c4 10             	add    $0x10,%esp
    err:
	return r;
}
  801c78:	89 d8                	mov    %ebx,%eax
  801c7a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c7d:	5b                   	pop    %ebx
  801c7e:	5e                   	pop    %esi
  801c7f:	5f                   	pop    %edi
  801c80:	c9                   	leave  
  801c81:	c3                   	ret    

00801c82 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801c82:	55                   	push   %ebp
  801c83:	89 e5                	mov    %esp,%ebp
  801c85:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801c88:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c8b:	50                   	push   %eax
  801c8c:	ff 75 08             	pushl  0x8(%ebp)
  801c8f:	e8 9b f5 ff ff       	call   80122f <fd_lookup>
  801c94:	83 c4 10             	add    $0x10,%esp
  801c97:	85 c0                	test   %eax,%eax
  801c99:	78 18                	js     801cb3 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801c9b:	83 ec 0c             	sub    $0xc,%esp
  801c9e:	ff 75 f4             	pushl  -0xc(%ebp)
  801ca1:	e8 fe f4 ff ff       	call   8011a4 <fd2data>
	return _pipeisclosed(fd, p);
  801ca6:	89 c2                	mov    %eax,%edx
  801ca8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cab:	e8 0c fd ff ff       	call   8019bc <_pipeisclosed>
  801cb0:	83 c4 10             	add    $0x10,%esp
}
  801cb3:	c9                   	leave  
  801cb4:	c3                   	ret    
  801cb5:	00 00                	add    %al,(%eax)
	...

00801cb8 <wait>:
#include <inc/lib.h>

// Waits until 'envid' exits.
void
wait(envid_t envid)
{
  801cb8:	55                   	push   %ebp
  801cb9:	89 e5                	mov    %esp,%ebp
  801cbb:	57                   	push   %edi
  801cbc:	56                   	push   %esi
  801cbd:	53                   	push   %ebx
  801cbe:	83 ec 0c             	sub    $0xc,%esp
  801cc1:	8b 45 08             	mov    0x8(%ebp),%eax
	const volatile struct Env *e;

	assert(envid != 0);
  801cc4:	85 c0                	test   %eax,%eax
  801cc6:	75 16                	jne    801cde <wait+0x26>
  801cc8:	68 0e 2a 80 00       	push   $0x802a0e
  801ccd:	68 c3 29 80 00       	push   $0x8029c3
  801cd2:	6a 09                	push   $0x9
  801cd4:	68 19 2a 80 00       	push   $0x802a19
  801cd9:	e8 4a e5 ff ff       	call   800228 <_panic>
	e = &envs[ENVX(envid)];
  801cde:	89 c6                	mov    %eax,%esi
  801ce0:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
	while (e->env_id == envid && e->env_status != ENV_FREE)
  801ce6:	8d 0c b5 00 00 00 00 	lea    0x0(,%esi,4),%ecx
  801ced:	89 f2                	mov    %esi,%edx
  801cef:	c1 e2 07             	shl    $0x7,%edx
  801cf2:	29 ca                	sub    %ecx,%edx
  801cf4:	81 c2 08 00 c0 ee    	add    $0xeec00008,%edx
  801cfa:	8b 7a 40             	mov    0x40(%edx),%edi
  801cfd:	39 c7                	cmp    %eax,%edi
  801cff:	75 37                	jne    801d38 <wait+0x80>
  801d01:	89 f0                	mov    %esi,%eax
  801d03:	c1 e0 07             	shl    $0x7,%eax
  801d06:	29 c8                	sub    %ecx,%eax
  801d08:	05 04 00 c0 ee       	add    $0xeec00004,%eax
  801d0d:	8b 40 50             	mov    0x50(%eax),%eax
  801d10:	85 c0                	test   %eax,%eax
  801d12:	74 24                	je     801d38 <wait+0x80>
  801d14:	c1 e6 07             	shl    $0x7,%esi
  801d17:	29 ce                	sub    %ecx,%esi
  801d19:	8d 9e 08 00 c0 ee    	lea    -0x113ffff8(%esi),%ebx
  801d1f:	81 c6 04 00 c0 ee    	add    $0xeec00004,%esi
		sys_yield();
  801d25:	e8 e7 ef ff ff       	call   800d11 <sys_yield>
{
	const volatile struct Env *e;

	assert(envid != 0);
	e = &envs[ENVX(envid)];
	while (e->env_id == envid && e->env_status != ENV_FREE)
  801d2a:	8b 43 40             	mov    0x40(%ebx),%eax
  801d2d:	39 f8                	cmp    %edi,%eax
  801d2f:	75 07                	jne    801d38 <wait+0x80>
  801d31:	8b 46 50             	mov    0x50(%esi),%eax
  801d34:	85 c0                	test   %eax,%eax
  801d36:	75 ed                	jne    801d25 <wait+0x6d>
		sys_yield();
}
  801d38:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d3b:	5b                   	pop    %ebx
  801d3c:	5e                   	pop    %esi
  801d3d:	5f                   	pop    %edi
  801d3e:	c9                   	leave  
  801d3f:	c3                   	ret    

00801d40 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801d40:	55                   	push   %ebp
  801d41:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801d43:	b8 00 00 00 00       	mov    $0x0,%eax
  801d48:	c9                   	leave  
  801d49:	c3                   	ret    

00801d4a <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801d4a:	55                   	push   %ebp
  801d4b:	89 e5                	mov    %esp,%ebp
  801d4d:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801d50:	68 24 2a 80 00       	push   $0x802a24
  801d55:	ff 75 0c             	pushl  0xc(%ebp)
  801d58:	e8 59 eb ff ff       	call   8008b6 <strcpy>
	return 0;
}
  801d5d:	b8 00 00 00 00       	mov    $0x0,%eax
  801d62:	c9                   	leave  
  801d63:	c3                   	ret    

00801d64 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801d64:	55                   	push   %ebp
  801d65:	89 e5                	mov    %esp,%ebp
  801d67:	57                   	push   %edi
  801d68:	56                   	push   %esi
  801d69:	53                   	push   %ebx
  801d6a:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801d70:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801d74:	74 45                	je     801dbb <devcons_write+0x57>
  801d76:	b8 00 00 00 00       	mov    $0x0,%eax
  801d7b:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801d80:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801d86:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801d89:	29 c3                	sub    %eax,%ebx
		if (m > sizeof(buf) - 1)
  801d8b:	83 fb 7f             	cmp    $0x7f,%ebx
  801d8e:	76 05                	jbe    801d95 <devcons_write+0x31>
			m = sizeof(buf) - 1;
  801d90:	bb 7f 00 00 00       	mov    $0x7f,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  801d95:	83 ec 04             	sub    $0x4,%esp
  801d98:	53                   	push   %ebx
  801d99:	03 45 0c             	add    0xc(%ebp),%eax
  801d9c:	50                   	push   %eax
  801d9d:	57                   	push   %edi
  801d9e:	e8 d4 ec ff ff       	call   800a77 <memmove>
		sys_cputs(buf, m);
  801da3:	83 c4 08             	add    $0x8,%esp
  801da6:	53                   	push   %ebx
  801da7:	57                   	push   %edi
  801da8:	e8 d4 ee ff ff       	call   800c81 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801dad:	01 de                	add    %ebx,%esi
  801daf:	89 f0                	mov    %esi,%eax
  801db1:	83 c4 10             	add    $0x10,%esp
  801db4:	3b 75 10             	cmp    0x10(%ebp),%esi
  801db7:	72 cd                	jb     801d86 <devcons_write+0x22>
  801db9:	eb 05                	jmp    801dc0 <devcons_write+0x5c>
  801dbb:	be 00 00 00 00       	mov    $0x0,%esi
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801dc0:	89 f0                	mov    %esi,%eax
  801dc2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801dc5:	5b                   	pop    %ebx
  801dc6:	5e                   	pop    %esi
  801dc7:	5f                   	pop    %edi
  801dc8:	c9                   	leave  
  801dc9:	c3                   	ret    

00801dca <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801dca:	55                   	push   %ebp
  801dcb:	89 e5                	mov    %esp,%ebp
  801dcd:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  801dd0:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801dd4:	75 07                	jne    801ddd <devcons_read+0x13>
  801dd6:	eb 25                	jmp    801dfd <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801dd8:	e8 34 ef ff ff       	call   800d11 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801ddd:	e8 c5 ee ff ff       	call   800ca7 <sys_cgetc>
  801de2:	85 c0                	test   %eax,%eax
  801de4:	74 f2                	je     801dd8 <devcons_read+0xe>
  801de6:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  801de8:	85 c0                	test   %eax,%eax
  801dea:	78 1d                	js     801e09 <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801dec:	83 f8 04             	cmp    $0x4,%eax
  801def:	74 13                	je     801e04 <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  801df1:	8b 45 0c             	mov    0xc(%ebp),%eax
  801df4:	88 10                	mov    %dl,(%eax)
	return 1;
  801df6:	b8 01 00 00 00       	mov    $0x1,%eax
  801dfb:	eb 0c                	jmp    801e09 <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  801dfd:	b8 00 00 00 00       	mov    $0x0,%eax
  801e02:	eb 05                	jmp    801e09 <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801e04:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801e09:	c9                   	leave  
  801e0a:	c3                   	ret    

00801e0b <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801e0b:	55                   	push   %ebp
  801e0c:	89 e5                	mov    %esp,%ebp
  801e0e:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801e11:	8b 45 08             	mov    0x8(%ebp),%eax
  801e14:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801e17:	6a 01                	push   $0x1
  801e19:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801e1c:	50                   	push   %eax
  801e1d:	e8 5f ee ff ff       	call   800c81 <sys_cputs>
  801e22:	83 c4 10             	add    $0x10,%esp
}
  801e25:	c9                   	leave  
  801e26:	c3                   	ret    

00801e27 <getchar>:

int
getchar(void)
{
  801e27:	55                   	push   %ebp
  801e28:	89 e5                	mov    %esp,%ebp
  801e2a:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801e2d:	6a 01                	push   $0x1
  801e2f:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801e32:	50                   	push   %eax
  801e33:	6a 00                	push   $0x0
  801e35:	e8 76 f6 ff ff       	call   8014b0 <read>
	if (r < 0)
  801e3a:	83 c4 10             	add    $0x10,%esp
  801e3d:	85 c0                	test   %eax,%eax
  801e3f:	78 0f                	js     801e50 <getchar+0x29>
		return r;
	if (r < 1)
  801e41:	85 c0                	test   %eax,%eax
  801e43:	7e 06                	jle    801e4b <getchar+0x24>
		return -E_EOF;
	return c;
  801e45:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801e49:	eb 05                	jmp    801e50 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801e4b:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801e50:	c9                   	leave  
  801e51:	c3                   	ret    

00801e52 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801e52:	55                   	push   %ebp
  801e53:	89 e5                	mov    %esp,%ebp
  801e55:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801e58:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e5b:	50                   	push   %eax
  801e5c:	ff 75 08             	pushl  0x8(%ebp)
  801e5f:	e8 cb f3 ff ff       	call   80122f <fd_lookup>
  801e64:	83 c4 10             	add    $0x10,%esp
  801e67:	85 c0                	test   %eax,%eax
  801e69:	78 11                	js     801e7c <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801e6b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e6e:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801e74:	39 10                	cmp    %edx,(%eax)
  801e76:	0f 94 c0             	sete   %al
  801e79:	0f b6 c0             	movzbl %al,%eax
}
  801e7c:	c9                   	leave  
  801e7d:	c3                   	ret    

00801e7e <opencons>:

int
opencons(void)
{
  801e7e:	55                   	push   %ebp
  801e7f:	89 e5                	mov    %esp,%ebp
  801e81:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801e84:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e87:	50                   	push   %eax
  801e88:	e8 2f f3 ff ff       	call   8011bc <fd_alloc>
  801e8d:	83 c4 10             	add    $0x10,%esp
  801e90:	85 c0                	test   %eax,%eax
  801e92:	78 3a                	js     801ece <opencons+0x50>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801e94:	83 ec 04             	sub    $0x4,%esp
  801e97:	68 07 04 00 00       	push   $0x407
  801e9c:	ff 75 f4             	pushl  -0xc(%ebp)
  801e9f:	6a 00                	push   $0x0
  801ea1:	e8 92 ee ff ff       	call   800d38 <sys_page_alloc>
  801ea6:	83 c4 10             	add    $0x10,%esp
  801ea9:	85 c0                	test   %eax,%eax
  801eab:	78 21                	js     801ece <opencons+0x50>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801ead:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801eb3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801eb6:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801eb8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ebb:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801ec2:	83 ec 0c             	sub    $0xc,%esp
  801ec5:	50                   	push   %eax
  801ec6:	e8 c9 f2 ff ff       	call   801194 <fd2num>
  801ecb:	83 c4 10             	add    $0x10,%esp
}
  801ece:	c9                   	leave  
  801ecf:	c3                   	ret    

00801ed0 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801ed0:	55                   	push   %ebp
  801ed1:	89 e5                	mov    %esp,%ebp
  801ed3:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  801ed6:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801edd:	75 52                	jne    801f31 <set_pgfault_handler+0x61>
		// First time through!	
		// LAB 4: Your code here.

		//int sys_page_alloc(envid_t envid, void *va, int perm)
		r = sys_page_alloc(0, (void*)(UXSTACKTOP - PGSIZE), PTE_U | PTE_W | PTE_P);
  801edf:	83 ec 04             	sub    $0x4,%esp
  801ee2:	6a 07                	push   $0x7
  801ee4:	68 00 f0 bf ee       	push   $0xeebff000
  801ee9:	6a 00                	push   $0x0
  801eeb:	e8 48 ee ff ff       	call   800d38 <sys_page_alloc>
		if (r < 0) {
  801ef0:	83 c4 10             	add    $0x10,%esp
  801ef3:	85 c0                	test   %eax,%eax
  801ef5:	79 12                	jns    801f09 <set_pgfault_handler+0x39>
			panic("sys_page_alloc error : %e\n", r);
  801ef7:	50                   	push   %eax
  801ef8:	68 30 2a 80 00       	push   $0x802a30
  801efd:	6a 24                	push   $0x24
  801eff:	68 4b 2a 80 00       	push   $0x802a4b
  801f04:	e8 1f e3 ff ff       	call   800228 <_panic>
		}

		// how to know envid, put 0, envid2env will help us to get curenv in syscall
		r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);		
  801f09:	83 ec 08             	sub    $0x8,%esp
  801f0c:	68 3c 1f 80 00       	push   $0x801f3c
  801f11:	6a 00                	push   $0x0
  801f13:	e8 d3 ee ff ff       	call   800deb <sys_env_set_pgfault_upcall>
		if (r < 0) {
  801f18:	83 c4 10             	add    $0x10,%esp
  801f1b:	85 c0                	test   %eax,%eax
  801f1d:	79 12                	jns    801f31 <set_pgfault_handler+0x61>
			panic("sys_env_set_pgfault_upcall error : %e\n", r);
  801f1f:	50                   	push   %eax
  801f20:	68 5c 2a 80 00       	push   $0x802a5c
  801f25:	6a 2a                	push   $0x2a
  801f27:	68 4b 2a 80 00       	push   $0x802a4b
  801f2c:	e8 f7 e2 ff ff       	call   800228 <_panic>
		}
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801f31:	8b 45 08             	mov    0x8(%ebp),%eax
  801f34:	a3 00 60 80 00       	mov    %eax,0x806000
}
  801f39:	c9                   	leave  
  801f3a:	c3                   	ret    
	...

00801f3c <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801f3c:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801f3d:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  801f42:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801f44:	83 c4 04             	add    $0x4,%esp
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	
	// fix old esp
	movl 0x30(%esp), %eax
  801f47:	8b 44 24 30          	mov    0x30(%esp),%eax
	subl $0x4, %eax
  801f4b:	83 e8 04             	sub    $0x4,%eax
	movl %eax, 0x30(%esp)
  801f4e:	89 44 24 30          	mov    %eax,0x30(%esp)

	// set trap-time %eip
	movl 0x28(%esp), %ebx
  801f52:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	movl %ebx, (%eax)
  801f56:	89 18                	mov    %ebx,(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $0x08, %esp 	// ignore err_code and fault_va
  801f58:	83 c4 08             	add    $0x8,%esp
	popal 				// restore registers
  801f5b:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x04, %esp 	// ignore eip 
  801f5c:	83 c4 04             	add    $0x4,%esp
	popfl				// modify eflags
  801f5f:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  801f60:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  801f61:	c3                   	ret    
	...

00801f64 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801f64:	55                   	push   %ebp
  801f65:	89 e5                	mov    %esp,%ebp
  801f67:	56                   	push   %esi
  801f68:	53                   	push   %ebx
  801f69:	8b 75 08             	mov    0x8(%ebp),%esi
  801f6c:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f6f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// cprintf("0x%x 0x%x 0x%x\n", (uint32_t)from_env_store, (uint32_t)pg, (uint32_t)perm_store);
	int r;
	if (pg != NULL) {
  801f72:	85 c0                	test   %eax,%eax
  801f74:	74 0e                	je     801f84 <ipc_recv+0x20>
		r = sys_ipc_recv(pg);
  801f76:	83 ec 0c             	sub    $0xc,%esp
  801f79:	50                   	push   %eax
  801f7a:	e8 b4 ee ff ff       	call   800e33 <sys_ipc_recv>
  801f7f:	83 c4 10             	add    $0x10,%esp
  801f82:	eb 10                	jmp    801f94 <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv((void *)UTOP);
  801f84:	83 ec 0c             	sub    $0xc,%esp
  801f87:	68 00 00 c0 ee       	push   $0xeec00000
  801f8c:	e8 a2 ee ff ff       	call   800e33 <sys_ipc_recv>
  801f91:	83 c4 10             	add    $0x10,%esp
	}

	if (r == 0) {
  801f94:	85 c0                	test   %eax,%eax
  801f96:	75 26                	jne    801fbe <ipc_recv+0x5a>
		if (from_env_store != NULL) *from_env_store = thisenv->env_ipc_from;
  801f98:	85 f6                	test   %esi,%esi
  801f9a:	74 0a                	je     801fa6 <ipc_recv+0x42>
  801f9c:	a1 20 44 80 00       	mov    0x804420,%eax
  801fa1:	8b 40 74             	mov    0x74(%eax),%eax
  801fa4:	89 06                	mov    %eax,(%esi)
		if (perm_store != NULL) *perm_store = thisenv->env_ipc_perm;
  801fa6:	85 db                	test   %ebx,%ebx
  801fa8:	74 0a                	je     801fb4 <ipc_recv+0x50>
  801faa:	a1 20 44 80 00       	mov    0x804420,%eax
  801faf:	8b 40 78             	mov    0x78(%eax),%eax
  801fb2:	89 03                	mov    %eax,(%ebx)
		return thisenv->env_ipc_value;
  801fb4:	a1 20 44 80 00       	mov    0x804420,%eax
  801fb9:	8b 40 70             	mov    0x70(%eax),%eax
  801fbc:	eb 14                	jmp    801fd2 <ipc_recv+0x6e>
	} else {
		// fails;
		if (from_env_store != NULL) *from_env_store = 0;
  801fbe:	85 f6                	test   %esi,%esi
  801fc0:	74 06                	je     801fc8 <ipc_recv+0x64>
  801fc2:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if (perm_store != NULL) *perm_store = 0;
  801fc8:	85 db                	test   %ebx,%ebx
  801fca:	74 06                	je     801fd2 <ipc_recv+0x6e>
  801fcc:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		return r;
	}
}
  801fd2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801fd5:	5b                   	pop    %ebx
  801fd6:	5e                   	pop    %esi
  801fd7:	c9                   	leave  
  801fd8:	c3                   	ret    

00801fd9 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801fd9:	55                   	push   %ebp
  801fda:	89 e5                	mov    %esp,%ebp
  801fdc:	57                   	push   %edi
  801fdd:	56                   	push   %esi
  801fde:	53                   	push   %ebx
  801fdf:	83 ec 0c             	sub    $0xc,%esp
  801fe2:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801fe5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801fe8:	8b 75 14             	mov    0x14(%ebp),%esi
	// LAB 4: Your code here.
	// int sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
	int r;
	if (pg == NULL) pg = (void *)UTOP;
  801feb:	85 db                	test   %ebx,%ebx
  801fed:	75 25                	jne    802014 <ipc_send+0x3b>
  801fef:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
  801ff4:	eb 1e                	jmp    802014 <ipc_send+0x3b>
	
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) != 0) {
		if (r == -E_IPC_NOT_RECV) {
  801ff6:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801ff9:	75 07                	jne    802002 <ipc_send+0x29>
			// cprintf("Try Again and Again....\n");
			sys_yield();
  801ffb:	e8 11 ed ff ff       	call   800d11 <sys_yield>
  802000:	eb 12                	jmp    802014 <ipc_send+0x3b>
		} else {
			panic("ipc_send error %e\n", r);
  802002:	50                   	push   %eax
  802003:	68 84 2a 80 00       	push   $0x802a84
  802008:	6a 43                	push   $0x43
  80200a:	68 97 2a 80 00       	push   $0x802a97
  80200f:	e8 14 e2 ff ff       	call   800228 <_panic>
	// LAB 4: Your code here.
	// int sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
	int r;
	if (pg == NULL) pg = (void *)UTOP;
	
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) != 0) {
  802014:	56                   	push   %esi
  802015:	53                   	push   %ebx
  802016:	57                   	push   %edi
  802017:	ff 75 08             	pushl  0x8(%ebp)
  80201a:	e8 ef ed ff ff       	call   800e0e <sys_ipc_try_send>
  80201f:	83 c4 10             	add    $0x10,%esp
  802022:	85 c0                	test   %eax,%eax
  802024:	75 d0                	jne    801ff6 <ipc_send+0x1d>
		} else {
			panic("ipc_send error %e\n", r);
		}
	}
	return;
}
  802026:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802029:	5b                   	pop    %ebx
  80202a:	5e                   	pop    %esi
  80202b:	5f                   	pop    %edi
  80202c:	c9                   	leave  
  80202d:	c3                   	ret    

0080202e <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80202e:	55                   	push   %ebp
  80202f:	89 e5                	mov    %esp,%ebp
  802031:	53                   	push   %ebx
  802032:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  802035:	39 1d 50 00 c0 ee    	cmp    %ebx,0xeec00050
  80203b:	74 22                	je     80205f <ipc_find_env+0x31>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80203d:	b8 01 00 00 00       	mov    $0x1,%eax
		if (envs[i].env_type == type)
  802042:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  802049:	89 c2                	mov    %eax,%edx
  80204b:	c1 e2 07             	shl    $0x7,%edx
  80204e:	29 ca                	sub    %ecx,%edx
  802050:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802056:	8b 52 50             	mov    0x50(%edx),%edx
  802059:	39 da                	cmp    %ebx,%edx
  80205b:	75 1d                	jne    80207a <ipc_find_env+0x4c>
  80205d:	eb 05                	jmp    802064 <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80205f:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
			return envs[i].env_id;
  802064:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  80206b:	c1 e0 07             	shl    $0x7,%eax
  80206e:	29 d0                	sub    %edx,%eax
  802070:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  802075:	8b 40 40             	mov    0x40(%eax),%eax
  802078:	eb 0c                	jmp    802086 <ipc_find_env+0x58>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80207a:	40                   	inc    %eax
  80207b:	3d 00 04 00 00       	cmp    $0x400,%eax
  802080:	75 c0                	jne    802042 <ipc_find_env+0x14>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802082:	66 b8 00 00          	mov    $0x0,%ax
}
  802086:	5b                   	pop    %ebx
  802087:	c9                   	leave  
  802088:	c3                   	ret    
  802089:	00 00                	add    %al,(%eax)
	...

0080208c <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  80208c:	55                   	push   %ebp
  80208d:	89 e5                	mov    %esp,%ebp
  80208f:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802092:	89 c2                	mov    %eax,%edx
  802094:	c1 ea 16             	shr    $0x16,%edx
  802097:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80209e:	f6 c2 01             	test   $0x1,%dl
  8020a1:	74 1e                	je     8020c1 <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  8020a3:	c1 e8 0c             	shr    $0xc,%eax
  8020a6:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  8020ad:	a8 01                	test   $0x1,%al
  8020af:	74 17                	je     8020c8 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8020b1:	c1 e8 0c             	shr    $0xc,%eax
  8020b4:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  8020bb:	ef 
  8020bc:	0f b7 c0             	movzwl %ax,%eax
  8020bf:	eb 0c                	jmp    8020cd <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  8020c1:	b8 00 00 00 00       	mov    $0x0,%eax
  8020c6:	eb 05                	jmp    8020cd <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  8020c8:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  8020cd:	c9                   	leave  
  8020ce:	c3                   	ret    
	...

008020d0 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  8020d0:	55                   	push   %ebp
  8020d1:	89 e5                	mov    %esp,%ebp
  8020d3:	57                   	push   %edi
  8020d4:	56                   	push   %esi
  8020d5:	83 ec 10             	sub    $0x10,%esp
  8020d8:	8b 7d 08             	mov    0x8(%ebp),%edi
  8020db:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  8020de:	89 7d f0             	mov    %edi,-0x10(%ebp)
  8020e1:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  8020e4:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  8020e7:	8b 45 14             	mov    0x14(%ebp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  8020ea:	85 c0                	test   %eax,%eax
  8020ec:	75 2e                	jne    80211c <__udivdi3+0x4c>
    {
      if (d0 > n1)
  8020ee:	39 f1                	cmp    %esi,%ecx
  8020f0:	77 5a                	ja     80214c <__udivdi3+0x7c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  8020f2:	85 c9                	test   %ecx,%ecx
  8020f4:	75 0b                	jne    802101 <__udivdi3+0x31>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  8020f6:	b8 01 00 00 00       	mov    $0x1,%eax
  8020fb:	31 d2                	xor    %edx,%edx
  8020fd:	f7 f1                	div    %ecx
  8020ff:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  802101:	31 d2                	xor    %edx,%edx
  802103:	89 f0                	mov    %esi,%eax
  802105:	f7 f1                	div    %ecx
  802107:	89 c6                	mov    %eax,%esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802109:	89 f8                	mov    %edi,%eax
  80210b:	f7 f1                	div    %ecx
  80210d:	89 c7                	mov    %eax,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  80210f:	89 f8                	mov    %edi,%eax
  802111:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802113:	83 c4 10             	add    $0x10,%esp
  802116:	5e                   	pop    %esi
  802117:	5f                   	pop    %edi
  802118:	c9                   	leave  
  802119:	c3                   	ret    
  80211a:	66 90                	xchg   %ax,%ax
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  80211c:	39 f0                	cmp    %esi,%eax
  80211e:	77 1c                	ja     80213c <__udivdi3+0x6c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  802120:	0f bd f8             	bsr    %eax,%edi
	  if (bm == 0)
  802123:	83 f7 1f             	xor    $0x1f,%edi
  802126:	75 3c                	jne    802164 <__udivdi3+0x94>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802128:	39 f0                	cmp    %esi,%eax
  80212a:	0f 82 90 00 00 00    	jb     8021c0 <__udivdi3+0xf0>
  802130:	8b 55 f0             	mov    -0x10(%ebp),%edx
  802133:	39 55 f4             	cmp    %edx,-0xc(%ebp)
  802136:	0f 86 84 00 00 00    	jbe    8021c0 <__udivdi3+0xf0>
  80213c:	31 f6                	xor    %esi,%esi
  80213e:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  802140:	89 f8                	mov    %edi,%eax
  802142:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802144:	83 c4 10             	add    $0x10,%esp
  802147:	5e                   	pop    %esi
  802148:	5f                   	pop    %edi
  802149:	c9                   	leave  
  80214a:	c3                   	ret    
  80214b:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  80214c:	89 f2                	mov    %esi,%edx
  80214e:	89 f8                	mov    %edi,%eax
  802150:	f7 f1                	div    %ecx
  802152:	89 c7                	mov    %eax,%edi
  802154:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  802156:	89 f8                	mov    %edi,%eax
  802158:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  80215a:	83 c4 10             	add    $0x10,%esp
  80215d:	5e                   	pop    %esi
  80215e:	5f                   	pop    %edi
  80215f:	c9                   	leave  
  802160:	c3                   	ret    
  802161:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  802164:	89 f9                	mov    %edi,%ecx
  802166:	d3 e0                	shl    %cl,%eax
  802168:	89 45 e8             	mov    %eax,-0x18(%ebp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  80216b:	b8 20 00 00 00       	mov    $0x20,%eax
  802170:	29 f8                	sub    %edi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  802172:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802175:	88 c1                	mov    %al,%cl
  802177:	d3 ea                	shr    %cl,%edx
  802179:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  80217c:	09 ca                	or     %ecx,%edx
  80217e:	89 55 ec             	mov    %edx,-0x14(%ebp)
	      d0 = d0 << bm;
  802181:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802184:	89 f9                	mov    %edi,%ecx
  802186:	d3 e2                	shl    %cl,%edx
  802188:	89 55 f4             	mov    %edx,-0xc(%ebp)
	      n2 = n1 >> b;
  80218b:	89 f2                	mov    %esi,%edx
  80218d:	88 c1                	mov    %al,%cl
  80218f:	d3 ea                	shr    %cl,%edx
  802191:	89 55 e8             	mov    %edx,-0x18(%ebp)
	      n1 = (n1 << bm) | (n0 >> b);
  802194:	89 f2                	mov    %esi,%edx
  802196:	89 f9                	mov    %edi,%ecx
  802198:	d3 e2                	shl    %cl,%edx
  80219a:	8b 75 f0             	mov    -0x10(%ebp),%esi
  80219d:	88 c1                	mov    %al,%cl
  80219f:	d3 ee                	shr    %cl,%esi
  8021a1:	09 d6                	or     %edx,%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  8021a3:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  8021a6:	89 f0                	mov    %esi,%eax
  8021a8:	89 ca                	mov    %ecx,%edx
  8021aa:	f7 75 ec             	divl   -0x14(%ebp)
  8021ad:	89 d1                	mov    %edx,%ecx
  8021af:	89 c6                	mov    %eax,%esi
	      umul_ppmm (m1, m0, q0, d0);
  8021b1:	f7 65 f4             	mull   -0xc(%ebp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8021b4:	39 d1                	cmp    %edx,%ecx
  8021b6:	72 28                	jb     8021e0 <__udivdi3+0x110>
  8021b8:	74 1a                	je     8021d4 <__udivdi3+0x104>
  8021ba:	89 f7                	mov    %esi,%edi
  8021bc:	31 f6                	xor    %esi,%esi
  8021be:	eb 80                	jmp    802140 <__udivdi3+0x70>
	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  8021c0:	31 f6                	xor    %esi,%esi
  8021c2:	bf 01 00 00 00       	mov    $0x1,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  8021c7:	89 f8                	mov    %edi,%eax
  8021c9:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  8021cb:	83 c4 10             	add    $0x10,%esp
  8021ce:	5e                   	pop    %esi
  8021cf:	5f                   	pop    %edi
  8021d0:	c9                   	leave  
  8021d1:	c3                   	ret    
  8021d2:	66 90                	xchg   %ax,%ax

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  8021d4:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8021d7:	89 f9                	mov    %edi,%ecx
  8021d9:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8021db:	39 c2                	cmp    %eax,%edx
  8021dd:	73 db                	jae    8021ba <__udivdi3+0xea>
  8021df:	90                   	nop
		{
		  q0--;
  8021e0:	8d 7e ff             	lea    -0x1(%esi),%edi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  8021e3:	31 f6                	xor    %esi,%esi
  8021e5:	e9 56 ff ff ff       	jmp    802140 <__udivdi3+0x70>
	...

008021ec <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  8021ec:	55                   	push   %ebp
  8021ed:	89 e5                	mov    %esp,%ebp
  8021ef:	57                   	push   %edi
  8021f0:	56                   	push   %esi
  8021f1:	83 ec 20             	sub    $0x20,%esp
  8021f4:	8b 45 08             	mov    0x8(%ebp),%eax
  8021f7:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  8021fa:	89 45 e8             	mov    %eax,-0x18(%ebp)
  8021fd:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  802200:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  802203:	8b 7d 14             	mov    0x14(%ebp),%edi
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  802206:	89 45 f0             	mov    %eax,-0x10(%ebp)
  n1 = nn.s.high;
  802209:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  80220b:	85 ff                	test   %edi,%edi
  80220d:	75 15                	jne    802224 <__umoddi3+0x38>
    {
      if (d0 > n1)
  80220f:	39 f1                	cmp    %esi,%ecx
  802211:	0f 86 99 00 00 00    	jbe    8022b0 <__umoddi3+0xc4>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802217:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  802219:	89 d0                	mov    %edx,%eax
  80221b:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  80221d:	83 c4 20             	add    $0x20,%esp
  802220:	5e                   	pop    %esi
  802221:	5f                   	pop    %edi
  802222:	c9                   	leave  
  802223:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  802224:	39 f7                	cmp    %esi,%edi
  802226:	0f 87 a4 00 00 00    	ja     8022d0 <__umoddi3+0xe4>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  80222c:	0f bd c7             	bsr    %edi,%eax
	  if (bm == 0)
  80222f:	83 f0 1f             	xor    $0x1f,%eax
  802232:	89 45 ec             	mov    %eax,-0x14(%ebp)
  802235:	0f 84 a1 00 00 00    	je     8022dc <__umoddi3+0xf0>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  80223b:	89 f8                	mov    %edi,%eax
  80223d:	8a 4d ec             	mov    -0x14(%ebp),%cl
  802240:	d3 e0                	shl    %cl,%eax
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  802242:	bf 20 00 00 00       	mov    $0x20,%edi
  802247:	2b 7d ec             	sub    -0x14(%ebp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  80224a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80224d:	89 f9                	mov    %edi,%ecx
  80224f:	d3 ea                	shr    %cl,%edx
  802251:	09 c2                	or     %eax,%edx
  802253:	89 55 f0             	mov    %edx,-0x10(%ebp)
	      d0 = d0 << bm;
  802256:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802259:	8a 4d ec             	mov    -0x14(%ebp),%cl
  80225c:	d3 e0                	shl    %cl,%eax
  80225e:	89 45 f4             	mov    %eax,-0xc(%ebp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  802261:	89 f2                	mov    %esi,%edx
  802263:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  802265:	8b 45 e8             	mov    -0x18(%ebp),%eax
  802268:	d3 e0                	shl    %cl,%eax
  80226a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  80226d:	8b 45 e8             	mov    -0x18(%ebp),%eax
  802270:	89 f9                	mov    %edi,%ecx
  802272:	d3 e8                	shr    %cl,%eax
  802274:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  802276:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  802278:	89 f2                	mov    %esi,%edx
  80227a:	f7 75 f0             	divl   -0x10(%ebp)
  80227d:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  80227f:	f7 65 f4             	mull   -0xc(%ebp)
  802282:	89 55 e8             	mov    %edx,-0x18(%ebp)
  802285:	89 c1                	mov    %eax,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802287:	39 d6                	cmp    %edx,%esi
  802289:	72 71                	jb     8022fc <__umoddi3+0x110>
  80228b:	74 7f                	je     80230c <__umoddi3+0x120>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  80228d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802290:	29 c8                	sub    %ecx,%eax
  802292:	19 d6                	sbb    %edx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  802294:	8a 4d ec             	mov    -0x14(%ebp),%cl
  802297:	d3 e8                	shr    %cl,%eax
  802299:	89 f2                	mov    %esi,%edx
  80229b:	89 f9                	mov    %edi,%ecx
  80229d:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  80229f:	09 d0                	or     %edx,%eax
  8022a1:	89 f2                	mov    %esi,%edx
  8022a3:	8a 4d ec             	mov    -0x14(%ebp),%cl
  8022a6:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8022a8:	83 c4 20             	add    $0x20,%esp
  8022ab:	5e                   	pop    %esi
  8022ac:	5f                   	pop    %edi
  8022ad:	c9                   	leave  
  8022ae:	c3                   	ret    
  8022af:	90                   	nop
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  8022b0:	85 c9                	test   %ecx,%ecx
  8022b2:	75 0b                	jne    8022bf <__umoddi3+0xd3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  8022b4:	b8 01 00 00 00       	mov    $0x1,%eax
  8022b9:	31 d2                	xor    %edx,%edx
  8022bb:	f7 f1                	div    %ecx
  8022bd:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  8022bf:	89 f0                	mov    %esi,%eax
  8022c1:	31 d2                	xor    %edx,%edx
  8022c3:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8022c5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8022c8:	f7 f1                	div    %ecx
  8022ca:	e9 4a ff ff ff       	jmp    802219 <__umoddi3+0x2d>
  8022cf:	90                   	nop
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  8022d0:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8022d2:	83 c4 20             	add    $0x20,%esp
  8022d5:	5e                   	pop    %esi
  8022d6:	5f                   	pop    %edi
  8022d7:	c9                   	leave  
  8022d8:	c3                   	ret    
  8022d9:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  8022dc:	39 f7                	cmp    %esi,%edi
  8022de:	72 05                	jb     8022e5 <__umoddi3+0xf9>
  8022e0:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
  8022e3:	77 0c                	ja     8022f1 <__umoddi3+0x105>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  8022e5:	89 f2                	mov    %esi,%edx
  8022e7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8022ea:	29 c8                	sub    %ecx,%eax
  8022ec:	19 fa                	sbb    %edi,%edx
  8022ee:	89 45 f0             	mov    %eax,-0x10(%ebp)

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  8022f1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8022f4:	83 c4 20             	add    $0x20,%esp
  8022f7:	5e                   	pop    %esi
  8022f8:	5f                   	pop    %edi
  8022f9:	c9                   	leave  
  8022fa:	c3                   	ret    
  8022fb:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  8022fc:	8b 55 e8             	mov    -0x18(%ebp),%edx
  8022ff:	89 c1                	mov    %eax,%ecx
  802301:	2b 4d f4             	sub    -0xc(%ebp),%ecx
  802304:	1b 55 f0             	sbb    -0x10(%ebp),%edx
  802307:	eb 84                	jmp    80228d <__umoddi3+0xa1>
  802309:	8d 76 00             	lea    0x0(%esi),%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  80230c:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  80230f:	72 eb                	jb     8022fc <__umoddi3+0x110>
  802311:	89 f2                	mov    %esi,%edx
  802313:	e9 75 ff ff ff       	jmp    80228d <__umoddi3+0xa1>
