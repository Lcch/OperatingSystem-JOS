
obj/user/icode.debug:     file format elf32-i386


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
  80002c:	e8 07 01 00 00       	call   800138 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <umain>:
#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	81 ec 1c 02 00 00    	sub    $0x21c,%esp
	int fd, n, r;
	char buf[512+1];

	binaryname = "icode";
  80003f:	c7 05 00 30 80 00 00 	movl   $0x802700,0x803000
  800046:	27 80 00 

	cprintf("icode startup\n");
  800049:	68 06 27 80 00       	push   $0x802706
  80004e:	e8 29 02 00 00       	call   80027c <cprintf>

	cprintf("icode: open /motd\n");
  800053:	c7 04 24 15 27 80 00 	movl   $0x802715,(%esp)
  80005a:	e8 1d 02 00 00       	call   80027c <cprintf>
	if ((fd = open("/motd", O_RDONLY)) < 0)
  80005f:	83 c4 08             	add    $0x8,%esp
  800062:	6a 00                	push   $0x0
  800064:	68 28 27 80 00       	push   $0x802728
  800069:	e8 ce 14 00 00       	call   80153c <open>
  80006e:	89 c6                	mov    %eax,%esi
  800070:	83 c4 10             	add    $0x10,%esp
  800073:	85 c0                	test   %eax,%eax
  800075:	79 12                	jns    800089 <umain+0x55>
		panic("icode: open /motd: %e", fd);
  800077:	50                   	push   %eax
  800078:	68 2e 27 80 00       	push   $0x80272e
  80007d:	6a 0f                	push   $0xf
  80007f:	68 44 27 80 00       	push   $0x802744
  800084:	e8 1b 01 00 00       	call   8001a4 <_panic>

	cprintf("icode: read /motd\n");
  800089:	83 ec 0c             	sub    $0xc,%esp
  80008c:	68 51 27 80 00       	push   $0x802751
  800091:	e8 e6 01 00 00       	call   80027c <cprintf>
	while ((n = read(fd, buf, sizeof buf-1)) > 0)
  800096:	83 c4 10             	add    $0x10,%esp
  800099:	8d 9d f7 fd ff ff    	lea    -0x209(%ebp),%ebx
  80009f:	eb 0d                	jmp    8000ae <umain+0x7a>
		sys_cputs(buf, n);
  8000a1:	83 ec 08             	sub    $0x8,%esp
  8000a4:	50                   	push   %eax
  8000a5:	53                   	push   %ebx
  8000a6:	e8 52 0b 00 00       	call   800bfd <sys_cputs>
  8000ab:	83 c4 10             	add    $0x10,%esp
	cprintf("icode: open /motd\n");
	if ((fd = open("/motd", O_RDONLY)) < 0)
		panic("icode: open /motd: %e", fd);

	cprintf("icode: read /motd\n");
	while ((n = read(fd, buf, sizeof buf-1)) > 0)
  8000ae:	83 ec 04             	sub    $0x4,%esp
  8000b1:	68 00 02 00 00       	push   $0x200
  8000b6:	53                   	push   %ebx
  8000b7:	56                   	push   %esi
  8000b8:	e8 7b 10 00 00       	call   801138 <read>
  8000bd:	83 c4 10             	add    $0x10,%esp
  8000c0:	85 c0                	test   %eax,%eax
  8000c2:	7f dd                	jg     8000a1 <umain+0x6d>
		sys_cputs(buf, n);

	cprintf("icode: close /motd\n");
  8000c4:	83 ec 0c             	sub    $0xc,%esp
  8000c7:	68 64 27 80 00       	push   $0x802764
  8000cc:	e8 ab 01 00 00       	call   80027c <cprintf>
	close(fd);
  8000d1:	89 34 24             	mov    %esi,(%esp)
  8000d4:	e8 22 0f 00 00       	call   800ffb <close>

	cprintf("icode: spawn /init\n");
  8000d9:	c7 04 24 78 27 80 00 	movl   $0x802778,(%esp)
  8000e0:	e8 97 01 00 00       	call   80027c <cprintf>
	if ((r = spawnl("/init", "init", "initarg1", "initarg2", (char*)0)) < 0)
  8000e5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000ec:	68 8c 27 80 00       	push   $0x80278c
  8000f1:	68 95 27 80 00       	push   $0x802795
  8000f6:	68 9f 27 80 00       	push   $0x80279f
  8000fb:	68 9e 27 80 00       	push   $0x80279e
  800100:	e8 a3 1c 00 00       	call   801da8 <spawnl>
  800105:	83 c4 20             	add    $0x20,%esp
  800108:	85 c0                	test   %eax,%eax
  80010a:	79 12                	jns    80011e <umain+0xea>
		panic("icode: spawn /init: %e", r);
  80010c:	50                   	push   %eax
  80010d:	68 a4 27 80 00       	push   $0x8027a4
  800112:	6a 1a                	push   $0x1a
  800114:	68 44 27 80 00       	push   $0x802744
  800119:	e8 86 00 00 00       	call   8001a4 <_panic>

	cprintf("icode: exiting\n");
  80011e:	83 ec 0c             	sub    $0xc,%esp
  800121:	68 bb 27 80 00       	push   $0x8027bb
  800126:	e8 51 01 00 00       	call   80027c <cprintf>
  80012b:	83 c4 10             	add    $0x10,%esp
}
  80012e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800131:	5b                   	pop    %ebx
  800132:	5e                   	pop    %esi
  800133:	c9                   	leave  
  800134:	c3                   	ret    
  800135:	00 00                	add    %al,(%eax)
	...

00800138 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800138:	55                   	push   %ebp
  800139:	89 e5                	mov    %esp,%ebp
  80013b:	56                   	push   %esi
  80013c:	53                   	push   %ebx
  80013d:	8b 75 08             	mov    0x8(%ebp),%esi
  800140:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs + ENVX(sys_getenvid());
  800143:	e8 21 0b 00 00       	call   800c69 <sys_getenvid>
  800148:	25 ff 03 00 00       	and    $0x3ff,%eax
  80014d:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800154:	c1 e0 07             	shl    $0x7,%eax
  800157:	29 d0                	sub    %edx,%eax
  800159:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80015e:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800163:	85 f6                	test   %esi,%esi
  800165:	7e 07                	jle    80016e <libmain+0x36>
		binaryname = argv[0];
  800167:	8b 03                	mov    (%ebx),%eax
  800169:	a3 00 30 80 00       	mov    %eax,0x803000
	// call user main routine
	umain(argc, argv);
  80016e:	83 ec 08             	sub    $0x8,%esp
  800171:	53                   	push   %ebx
  800172:	56                   	push   %esi
  800173:	e8 bc fe ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  800178:	e8 0b 00 00 00       	call   800188 <exit>
  80017d:	83 c4 10             	add    $0x10,%esp
}
  800180:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800183:	5b                   	pop    %ebx
  800184:	5e                   	pop    %esi
  800185:	c9                   	leave  
  800186:	c3                   	ret    
	...

00800188 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800188:	55                   	push   %ebp
  800189:	89 e5                	mov    %esp,%ebp
  80018b:	83 ec 08             	sub    $0x8,%esp
	close_all();
  80018e:	e8 93 0e 00 00       	call   801026 <close_all>
	sys_env_destroy(0);
  800193:	83 ec 0c             	sub    $0xc,%esp
  800196:	6a 00                	push   $0x0
  800198:	e8 aa 0a 00 00       	call   800c47 <sys_env_destroy>
  80019d:	83 c4 10             	add    $0x10,%esp
}
  8001a0:	c9                   	leave  
  8001a1:	c3                   	ret    
	...

008001a4 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8001a4:	55                   	push   %ebp
  8001a5:	89 e5                	mov    %esp,%ebp
  8001a7:	56                   	push   %esi
  8001a8:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8001a9:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8001ac:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  8001b2:	e8 b2 0a 00 00       	call   800c69 <sys_getenvid>
  8001b7:	83 ec 0c             	sub    $0xc,%esp
  8001ba:	ff 75 0c             	pushl  0xc(%ebp)
  8001bd:	ff 75 08             	pushl  0x8(%ebp)
  8001c0:	53                   	push   %ebx
  8001c1:	50                   	push   %eax
  8001c2:	68 d8 27 80 00       	push   $0x8027d8
  8001c7:	e8 b0 00 00 00       	call   80027c <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8001cc:	83 c4 18             	add    $0x18,%esp
  8001cf:	56                   	push   %esi
  8001d0:	ff 75 10             	pushl  0x10(%ebp)
  8001d3:	e8 53 00 00 00       	call   80022b <vcprintf>
	cprintf("\n");
  8001d8:	c7 04 24 b8 2c 80 00 	movl   $0x802cb8,(%esp)
  8001df:	e8 98 00 00 00       	call   80027c <cprintf>
  8001e4:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8001e7:	cc                   	int3   
  8001e8:	eb fd                	jmp    8001e7 <_panic+0x43>
	...

008001ec <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001ec:	55                   	push   %ebp
  8001ed:	89 e5                	mov    %esp,%ebp
  8001ef:	53                   	push   %ebx
  8001f0:	83 ec 04             	sub    $0x4,%esp
  8001f3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001f6:	8b 03                	mov    (%ebx),%eax
  8001f8:	8b 55 08             	mov    0x8(%ebp),%edx
  8001fb:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8001ff:	40                   	inc    %eax
  800200:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  800202:	3d ff 00 00 00       	cmp    $0xff,%eax
  800207:	75 1a                	jne    800223 <putch+0x37>
		sys_cputs(b->buf, b->idx);
  800209:	83 ec 08             	sub    $0x8,%esp
  80020c:	68 ff 00 00 00       	push   $0xff
  800211:	8d 43 08             	lea    0x8(%ebx),%eax
  800214:	50                   	push   %eax
  800215:	e8 e3 09 00 00       	call   800bfd <sys_cputs>
		b->idx = 0;
  80021a:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800220:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800223:	ff 43 04             	incl   0x4(%ebx)
}
  800226:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800229:	c9                   	leave  
  80022a:	c3                   	ret    

0080022b <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80022b:	55                   	push   %ebp
  80022c:	89 e5                	mov    %esp,%ebp
  80022e:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800234:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80023b:	00 00 00 
	b.cnt = 0;
  80023e:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800245:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800248:	ff 75 0c             	pushl  0xc(%ebp)
  80024b:	ff 75 08             	pushl  0x8(%ebp)
  80024e:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800254:	50                   	push   %eax
  800255:	68 ec 01 80 00       	push   $0x8001ec
  80025a:	e8 82 01 00 00       	call   8003e1 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80025f:	83 c4 08             	add    $0x8,%esp
  800262:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800268:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80026e:	50                   	push   %eax
  80026f:	e8 89 09 00 00       	call   800bfd <sys_cputs>

	return b.cnt;
}
  800274:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80027a:	c9                   	leave  
  80027b:	c3                   	ret    

0080027c <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80027c:	55                   	push   %ebp
  80027d:	89 e5                	mov    %esp,%ebp
  80027f:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800282:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800285:	50                   	push   %eax
  800286:	ff 75 08             	pushl  0x8(%ebp)
  800289:	e8 9d ff ff ff       	call   80022b <vcprintf>
	va_end(ap);

	return cnt;
}
  80028e:	c9                   	leave  
  80028f:	c3                   	ret    

00800290 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800290:	55                   	push   %ebp
  800291:	89 e5                	mov    %esp,%ebp
  800293:	57                   	push   %edi
  800294:	56                   	push   %esi
  800295:	53                   	push   %ebx
  800296:	83 ec 2c             	sub    $0x2c,%esp
  800299:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80029c:	89 d6                	mov    %edx,%esi
  80029e:	8b 45 08             	mov    0x8(%ebp),%eax
  8002a1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002a4:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8002a7:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8002aa:	8b 45 10             	mov    0x10(%ebp),%eax
  8002ad:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8002b0:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8002b3:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8002b6:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  8002bd:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
  8002c0:	72 0c                	jb     8002ce <printnum+0x3e>
  8002c2:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  8002c5:	76 07                	jbe    8002ce <printnum+0x3e>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002c7:	4b                   	dec    %ebx
  8002c8:	85 db                	test   %ebx,%ebx
  8002ca:	7f 31                	jg     8002fd <printnum+0x6d>
  8002cc:	eb 3f                	jmp    80030d <printnum+0x7d>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002ce:	83 ec 0c             	sub    $0xc,%esp
  8002d1:	57                   	push   %edi
  8002d2:	4b                   	dec    %ebx
  8002d3:	53                   	push   %ebx
  8002d4:	50                   	push   %eax
  8002d5:	83 ec 08             	sub    $0x8,%esp
  8002d8:	ff 75 d4             	pushl  -0x2c(%ebp)
  8002db:	ff 75 d0             	pushl  -0x30(%ebp)
  8002de:	ff 75 dc             	pushl  -0x24(%ebp)
  8002e1:	ff 75 d8             	pushl  -0x28(%ebp)
  8002e4:	e8 b7 21 00 00       	call   8024a0 <__udivdi3>
  8002e9:	83 c4 18             	add    $0x18,%esp
  8002ec:	52                   	push   %edx
  8002ed:	50                   	push   %eax
  8002ee:	89 f2                	mov    %esi,%edx
  8002f0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8002f3:	e8 98 ff ff ff       	call   800290 <printnum>
  8002f8:	83 c4 20             	add    $0x20,%esp
  8002fb:	eb 10                	jmp    80030d <printnum+0x7d>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002fd:	83 ec 08             	sub    $0x8,%esp
  800300:	56                   	push   %esi
  800301:	57                   	push   %edi
  800302:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800305:	4b                   	dec    %ebx
  800306:	83 c4 10             	add    $0x10,%esp
  800309:	85 db                	test   %ebx,%ebx
  80030b:	7f f0                	jg     8002fd <printnum+0x6d>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80030d:	83 ec 08             	sub    $0x8,%esp
  800310:	56                   	push   %esi
  800311:	83 ec 04             	sub    $0x4,%esp
  800314:	ff 75 d4             	pushl  -0x2c(%ebp)
  800317:	ff 75 d0             	pushl  -0x30(%ebp)
  80031a:	ff 75 dc             	pushl  -0x24(%ebp)
  80031d:	ff 75 d8             	pushl  -0x28(%ebp)
  800320:	e8 97 22 00 00       	call   8025bc <__umoddi3>
  800325:	83 c4 14             	add    $0x14,%esp
  800328:	0f be 80 fb 27 80 00 	movsbl 0x8027fb(%eax),%eax
  80032f:	50                   	push   %eax
  800330:	ff 55 e4             	call   *-0x1c(%ebp)
  800333:	83 c4 10             	add    $0x10,%esp
}
  800336:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800339:	5b                   	pop    %ebx
  80033a:	5e                   	pop    %esi
  80033b:	5f                   	pop    %edi
  80033c:	c9                   	leave  
  80033d:	c3                   	ret    

0080033e <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80033e:	55                   	push   %ebp
  80033f:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800341:	83 fa 01             	cmp    $0x1,%edx
  800344:	7e 0e                	jle    800354 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800346:	8b 10                	mov    (%eax),%edx
  800348:	8d 4a 08             	lea    0x8(%edx),%ecx
  80034b:	89 08                	mov    %ecx,(%eax)
  80034d:	8b 02                	mov    (%edx),%eax
  80034f:	8b 52 04             	mov    0x4(%edx),%edx
  800352:	eb 22                	jmp    800376 <getuint+0x38>
	else if (lflag)
  800354:	85 d2                	test   %edx,%edx
  800356:	74 10                	je     800368 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800358:	8b 10                	mov    (%eax),%edx
  80035a:	8d 4a 04             	lea    0x4(%edx),%ecx
  80035d:	89 08                	mov    %ecx,(%eax)
  80035f:	8b 02                	mov    (%edx),%eax
  800361:	ba 00 00 00 00       	mov    $0x0,%edx
  800366:	eb 0e                	jmp    800376 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800368:	8b 10                	mov    (%eax),%edx
  80036a:	8d 4a 04             	lea    0x4(%edx),%ecx
  80036d:	89 08                	mov    %ecx,(%eax)
  80036f:	8b 02                	mov    (%edx),%eax
  800371:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800376:	c9                   	leave  
  800377:	c3                   	ret    

00800378 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  800378:	55                   	push   %ebp
  800379:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80037b:	83 fa 01             	cmp    $0x1,%edx
  80037e:	7e 0e                	jle    80038e <getint+0x16>
		return va_arg(*ap, long long);
  800380:	8b 10                	mov    (%eax),%edx
  800382:	8d 4a 08             	lea    0x8(%edx),%ecx
  800385:	89 08                	mov    %ecx,(%eax)
  800387:	8b 02                	mov    (%edx),%eax
  800389:	8b 52 04             	mov    0x4(%edx),%edx
  80038c:	eb 1a                	jmp    8003a8 <getint+0x30>
	else if (lflag)
  80038e:	85 d2                	test   %edx,%edx
  800390:	74 0c                	je     80039e <getint+0x26>
		return va_arg(*ap, long);
  800392:	8b 10                	mov    (%eax),%edx
  800394:	8d 4a 04             	lea    0x4(%edx),%ecx
  800397:	89 08                	mov    %ecx,(%eax)
  800399:	8b 02                	mov    (%edx),%eax
  80039b:	99                   	cltd   
  80039c:	eb 0a                	jmp    8003a8 <getint+0x30>
	else
		return va_arg(*ap, int);
  80039e:	8b 10                	mov    (%eax),%edx
  8003a0:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003a3:	89 08                	mov    %ecx,(%eax)
  8003a5:	8b 02                	mov    (%edx),%eax
  8003a7:	99                   	cltd   
}
  8003a8:	c9                   	leave  
  8003a9:	c3                   	ret    

008003aa <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8003aa:	55                   	push   %ebp
  8003ab:	89 e5                	mov    %esp,%ebp
  8003ad:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8003b0:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  8003b3:	8b 10                	mov    (%eax),%edx
  8003b5:	3b 50 04             	cmp    0x4(%eax),%edx
  8003b8:	73 08                	jae    8003c2 <sprintputch+0x18>
		*b->buf++ = ch;
  8003ba:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8003bd:	88 0a                	mov    %cl,(%edx)
  8003bf:	42                   	inc    %edx
  8003c0:	89 10                	mov    %edx,(%eax)
}
  8003c2:	c9                   	leave  
  8003c3:	c3                   	ret    

008003c4 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8003c4:	55                   	push   %ebp
  8003c5:	89 e5                	mov    %esp,%ebp
  8003c7:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8003ca:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8003cd:	50                   	push   %eax
  8003ce:	ff 75 10             	pushl  0x10(%ebp)
  8003d1:	ff 75 0c             	pushl  0xc(%ebp)
  8003d4:	ff 75 08             	pushl  0x8(%ebp)
  8003d7:	e8 05 00 00 00       	call   8003e1 <vprintfmt>
	va_end(ap);
  8003dc:	83 c4 10             	add    $0x10,%esp
}
  8003df:	c9                   	leave  
  8003e0:	c3                   	ret    

008003e1 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8003e1:	55                   	push   %ebp
  8003e2:	89 e5                	mov    %esp,%ebp
  8003e4:	57                   	push   %edi
  8003e5:	56                   	push   %esi
  8003e6:	53                   	push   %ebx
  8003e7:	83 ec 2c             	sub    $0x2c,%esp
  8003ea:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8003ed:	8b 75 10             	mov    0x10(%ebp),%esi
  8003f0:	eb 13                	jmp    800405 <vprintfmt+0x24>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8003f2:	85 c0                	test   %eax,%eax
  8003f4:	0f 84 6d 03 00 00    	je     800767 <vprintfmt+0x386>
				return;
			putch(ch, putdat);
  8003fa:	83 ec 08             	sub    $0x8,%esp
  8003fd:	57                   	push   %edi
  8003fe:	50                   	push   %eax
  8003ff:	ff 55 08             	call   *0x8(%ebp)
  800402:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800405:	0f b6 06             	movzbl (%esi),%eax
  800408:	46                   	inc    %esi
  800409:	83 f8 25             	cmp    $0x25,%eax
  80040c:	75 e4                	jne    8003f2 <vprintfmt+0x11>
  80040e:	c6 45 dc 20          	movb   $0x20,-0x24(%ebp)
  800412:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  800419:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  800420:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800427:	b9 00 00 00 00       	mov    $0x0,%ecx
  80042c:	eb 28                	jmp    800456 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80042e:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800430:	c6 45 dc 2d          	movb   $0x2d,-0x24(%ebp)
  800434:	eb 20                	jmp    800456 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800436:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800438:	c6 45 dc 30          	movb   $0x30,-0x24(%ebp)
  80043c:	eb 18                	jmp    800456 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80043e:	89 de                	mov    %ebx,%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800440:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800447:	eb 0d                	jmp    800456 <vprintfmt+0x75>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800449:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80044c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80044f:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800456:	8a 06                	mov    (%esi),%al
  800458:	0f b6 d0             	movzbl %al,%edx
  80045b:	8d 5e 01             	lea    0x1(%esi),%ebx
  80045e:	83 e8 23             	sub    $0x23,%eax
  800461:	3c 55                	cmp    $0x55,%al
  800463:	0f 87 e0 02 00 00    	ja     800749 <vprintfmt+0x368>
  800469:	0f b6 c0             	movzbl %al,%eax
  80046c:	ff 24 85 40 29 80 00 	jmp    *0x802940(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800473:	83 ea 30             	sub    $0x30,%edx
  800476:	89 55 d4             	mov    %edx,-0x2c(%ebp)
				ch = *fmt;
  800479:	0f be 03             	movsbl (%ebx),%eax
				if (ch < '0' || ch > '9')
  80047c:	8d 50 d0             	lea    -0x30(%eax),%edx
  80047f:	83 fa 09             	cmp    $0x9,%edx
  800482:	77 44                	ja     8004c8 <vprintfmt+0xe7>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800484:	89 de                	mov    %ebx,%esi
  800486:	8b 55 d4             	mov    -0x2c(%ebp),%edx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800489:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
  80048a:	8d 14 92             	lea    (%edx,%edx,4),%edx
  80048d:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
  800491:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800494:	8d 58 d0             	lea    -0x30(%eax),%ebx
  800497:	83 fb 09             	cmp    $0x9,%ebx
  80049a:	76 ed                	jbe    800489 <vprintfmt+0xa8>
  80049c:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  80049f:	eb 29                	jmp    8004ca <vprintfmt+0xe9>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8004a1:	8b 45 14             	mov    0x14(%ebp),%eax
  8004a4:	8d 50 04             	lea    0x4(%eax),%edx
  8004a7:	89 55 14             	mov    %edx,0x14(%ebp)
  8004aa:	8b 00                	mov    (%eax),%eax
  8004ac:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004af:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8004b1:	eb 17                	jmp    8004ca <vprintfmt+0xe9>

		case '.':
			if (width < 0)
  8004b3:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8004b7:	78 85                	js     80043e <vprintfmt+0x5d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004b9:	89 de                	mov    %ebx,%esi
  8004bb:	eb 99                	jmp    800456 <vprintfmt+0x75>
  8004bd:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8004bf:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  8004c6:	eb 8e                	jmp    800456 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004c8:	89 de                	mov    %ebx,%esi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  8004ca:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8004ce:	79 86                	jns    800456 <vprintfmt+0x75>
  8004d0:	e9 74 ff ff ff       	jmp    800449 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8004d5:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004d6:	89 de                	mov    %ebx,%esi
  8004d8:	e9 79 ff ff ff       	jmp    800456 <vprintfmt+0x75>
  8004dd:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8004e0:	8b 45 14             	mov    0x14(%ebp),%eax
  8004e3:	8d 50 04             	lea    0x4(%eax),%edx
  8004e6:	89 55 14             	mov    %edx,0x14(%ebp)
  8004e9:	83 ec 08             	sub    $0x8,%esp
  8004ec:	57                   	push   %edi
  8004ed:	ff 30                	pushl  (%eax)
  8004ef:	ff 55 08             	call   *0x8(%ebp)
			break;
  8004f2:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004f5:	8b 75 d8             	mov    -0x28(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8004f8:	e9 08 ff ff ff       	jmp    800405 <vprintfmt+0x24>
  8004fd:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  800500:	8b 45 14             	mov    0x14(%ebp),%eax
  800503:	8d 50 04             	lea    0x4(%eax),%edx
  800506:	89 55 14             	mov    %edx,0x14(%ebp)
  800509:	8b 00                	mov    (%eax),%eax
  80050b:	85 c0                	test   %eax,%eax
  80050d:	79 02                	jns    800511 <vprintfmt+0x130>
  80050f:	f7 d8                	neg    %eax
  800511:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800513:	83 f8 0f             	cmp    $0xf,%eax
  800516:	7f 0b                	jg     800523 <vprintfmt+0x142>
  800518:	8b 04 85 a0 2a 80 00 	mov    0x802aa0(,%eax,4),%eax
  80051f:	85 c0                	test   %eax,%eax
  800521:	75 1a                	jne    80053d <vprintfmt+0x15c>
				printfmt(putch, putdat, "error %d", err);
  800523:	52                   	push   %edx
  800524:	68 13 28 80 00       	push   $0x802813
  800529:	57                   	push   %edi
  80052a:	ff 75 08             	pushl  0x8(%ebp)
  80052d:	e8 92 fe ff ff       	call   8003c4 <printfmt>
  800532:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800535:	8b 75 d8             	mov    -0x28(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800538:	e9 c8 fe ff ff       	jmp    800405 <vprintfmt+0x24>
			else
				printfmt(putch, putdat, "%s", p);
  80053d:	50                   	push   %eax
  80053e:	68 d1 2b 80 00       	push   $0x802bd1
  800543:	57                   	push   %edi
  800544:	ff 75 08             	pushl  0x8(%ebp)
  800547:	e8 78 fe ff ff       	call   8003c4 <printfmt>
  80054c:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80054f:	8b 75 d8             	mov    -0x28(%ebp),%esi
  800552:	e9 ae fe ff ff       	jmp    800405 <vprintfmt+0x24>
  800557:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  80055a:	89 de                	mov    %ebx,%esi
  80055c:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  80055f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800562:	8b 45 14             	mov    0x14(%ebp),%eax
  800565:	8d 50 04             	lea    0x4(%eax),%edx
  800568:	89 55 14             	mov    %edx,0x14(%ebp)
  80056b:	8b 00                	mov    (%eax),%eax
  80056d:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800570:	85 c0                	test   %eax,%eax
  800572:	75 07                	jne    80057b <vprintfmt+0x19a>
				p = "(null)";
  800574:	c7 45 d0 0c 28 80 00 	movl   $0x80280c,-0x30(%ebp)
			if (width > 0 && padc != '-')
  80057b:	85 db                	test   %ebx,%ebx
  80057d:	7e 42                	jle    8005c1 <vprintfmt+0x1e0>
  80057f:	80 7d dc 2d          	cmpb   $0x2d,-0x24(%ebp)
  800583:	74 3c                	je     8005c1 <vprintfmt+0x1e0>
				for (width -= strnlen(p, precision); width > 0; width--)
  800585:	83 ec 08             	sub    $0x8,%esp
  800588:	51                   	push   %ecx
  800589:	ff 75 d0             	pushl  -0x30(%ebp)
  80058c:	e8 6f 02 00 00       	call   800800 <strnlen>
  800591:	29 c3                	sub    %eax,%ebx
  800593:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800596:	83 c4 10             	add    $0x10,%esp
  800599:	85 db                	test   %ebx,%ebx
  80059b:	7e 24                	jle    8005c1 <vprintfmt+0x1e0>
					putch(padc, putdat);
  80059d:	0f be 5d dc          	movsbl -0x24(%ebp),%ebx
  8005a1:	89 75 dc             	mov    %esi,-0x24(%ebp)
  8005a4:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  8005a7:	83 ec 08             	sub    $0x8,%esp
  8005aa:	57                   	push   %edi
  8005ab:	53                   	push   %ebx
  8005ac:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005af:	4e                   	dec    %esi
  8005b0:	83 c4 10             	add    $0x10,%esp
  8005b3:	85 f6                	test   %esi,%esi
  8005b5:	7f f0                	jg     8005a7 <vprintfmt+0x1c6>
  8005b7:	8b 75 dc             	mov    -0x24(%ebp),%esi
  8005ba:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005c1:	8b 55 d0             	mov    -0x30(%ebp),%edx
  8005c4:	0f be 02             	movsbl (%edx),%eax
  8005c7:	85 c0                	test   %eax,%eax
  8005c9:	75 47                	jne    800612 <vprintfmt+0x231>
  8005cb:	eb 37                	jmp    800604 <vprintfmt+0x223>
				if (altflag && (ch < ' ' || ch > '~'))
  8005cd:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8005d1:	74 16                	je     8005e9 <vprintfmt+0x208>
  8005d3:	8d 50 e0             	lea    -0x20(%eax),%edx
  8005d6:	83 fa 5e             	cmp    $0x5e,%edx
  8005d9:	76 0e                	jbe    8005e9 <vprintfmt+0x208>
					putch('?', putdat);
  8005db:	83 ec 08             	sub    $0x8,%esp
  8005de:	57                   	push   %edi
  8005df:	6a 3f                	push   $0x3f
  8005e1:	ff 55 08             	call   *0x8(%ebp)
  8005e4:	83 c4 10             	add    $0x10,%esp
  8005e7:	eb 0b                	jmp    8005f4 <vprintfmt+0x213>
				else
					putch(ch, putdat);
  8005e9:	83 ec 08             	sub    $0x8,%esp
  8005ec:	57                   	push   %edi
  8005ed:	50                   	push   %eax
  8005ee:	ff 55 08             	call   *0x8(%ebp)
  8005f1:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005f4:	ff 4d e4             	decl   -0x1c(%ebp)
  8005f7:	0f be 03             	movsbl (%ebx),%eax
  8005fa:	85 c0                	test   %eax,%eax
  8005fc:	74 03                	je     800601 <vprintfmt+0x220>
  8005fe:	43                   	inc    %ebx
  8005ff:	eb 1b                	jmp    80061c <vprintfmt+0x23b>
  800601:	8b 75 dc             	mov    -0x24(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800604:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800608:	7f 1e                	jg     800628 <vprintfmt+0x247>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80060a:	8b 75 d8             	mov    -0x28(%ebp),%esi
  80060d:	e9 f3 fd ff ff       	jmp    800405 <vprintfmt+0x24>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800612:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800615:	43                   	inc    %ebx
  800616:	89 75 dc             	mov    %esi,-0x24(%ebp)
  800619:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  80061c:	85 f6                	test   %esi,%esi
  80061e:	78 ad                	js     8005cd <vprintfmt+0x1ec>
  800620:	4e                   	dec    %esi
  800621:	79 aa                	jns    8005cd <vprintfmt+0x1ec>
  800623:	8b 75 dc             	mov    -0x24(%ebp),%esi
  800626:	eb dc                	jmp    800604 <vprintfmt+0x223>
  800628:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80062b:	83 ec 08             	sub    $0x8,%esp
  80062e:	57                   	push   %edi
  80062f:	6a 20                	push   $0x20
  800631:	ff 55 08             	call   *0x8(%ebp)
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800634:	4b                   	dec    %ebx
  800635:	83 c4 10             	add    $0x10,%esp
  800638:	85 db                	test   %ebx,%ebx
  80063a:	7f ef                	jg     80062b <vprintfmt+0x24a>
  80063c:	e9 c4 fd ff ff       	jmp    800405 <vprintfmt+0x24>
  800641:	89 5d d8             	mov    %ebx,-0x28(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800644:	89 ca                	mov    %ecx,%edx
  800646:	8d 45 14             	lea    0x14(%ebp),%eax
  800649:	e8 2a fd ff ff       	call   800378 <getint>
  80064e:	89 c3                	mov    %eax,%ebx
  800650:	89 d6                	mov    %edx,%esi
			if ((long long) num < 0) {
  800652:	85 d2                	test   %edx,%edx
  800654:	78 0a                	js     800660 <vprintfmt+0x27f>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800656:	b8 0a 00 00 00       	mov    $0xa,%eax
  80065b:	e9 b0 00 00 00       	jmp    800710 <vprintfmt+0x32f>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  800660:	83 ec 08             	sub    $0x8,%esp
  800663:	57                   	push   %edi
  800664:	6a 2d                	push   $0x2d
  800666:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800669:	f7 db                	neg    %ebx
  80066b:	83 d6 00             	adc    $0x0,%esi
  80066e:	f7 de                	neg    %esi
  800670:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800673:	b8 0a 00 00 00       	mov    $0xa,%eax
  800678:	e9 93 00 00 00       	jmp    800710 <vprintfmt+0x32f>
  80067d:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800680:	89 ca                	mov    %ecx,%edx
  800682:	8d 45 14             	lea    0x14(%ebp),%eax
  800685:	e8 b4 fc ff ff       	call   80033e <getuint>
  80068a:	89 c3                	mov    %eax,%ebx
  80068c:	89 d6                	mov    %edx,%esi
			base = 10;
  80068e:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  800693:	eb 7b                	jmp    800710 <vprintfmt+0x32f>
  800695:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
  800698:	89 ca                	mov    %ecx,%edx
  80069a:	8d 45 14             	lea    0x14(%ebp),%eax
  80069d:	e8 d6 fc ff ff       	call   800378 <getint>
  8006a2:	89 c3                	mov    %eax,%ebx
  8006a4:	89 d6                	mov    %edx,%esi
            if ((long long) num < 0) {
  8006a6:	85 d2                	test   %edx,%edx
  8006a8:	78 07                	js     8006b1 <vprintfmt+0x2d0>
                putch('-', putdat);
                num = -(long long) num;
            }
            base = 8;
  8006aa:	b8 08 00 00 00       	mov    $0x8,%eax
  8006af:	eb 5f                	jmp    800710 <vprintfmt+0x32f>
		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
            if ((long long) num < 0) {
                putch('-', putdat);
  8006b1:	83 ec 08             	sub    $0x8,%esp
  8006b4:	57                   	push   %edi
  8006b5:	6a 2d                	push   $0x2d
  8006b7:	ff 55 08             	call   *0x8(%ebp)
                num = -(long long) num;
  8006ba:	f7 db                	neg    %ebx
  8006bc:	83 d6 00             	adc    $0x0,%esi
  8006bf:	f7 de                	neg    %esi
  8006c1:	83 c4 10             	add    $0x10,%esp
            }
            base = 8;
  8006c4:	b8 08 00 00 00       	mov    $0x8,%eax
  8006c9:	eb 45                	jmp    800710 <vprintfmt+0x32f>
  8006cb:	89 5d d8             	mov    %ebx,-0x28(%ebp)
            goto number;

        // pointer
		case 'p':
			putch('0', putdat);
  8006ce:	83 ec 08             	sub    $0x8,%esp
  8006d1:	57                   	push   %edi
  8006d2:	6a 30                	push   $0x30
  8006d4:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8006d7:	83 c4 08             	add    $0x8,%esp
  8006da:	57                   	push   %edi
  8006db:	6a 78                	push   $0x78
  8006dd:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8006e0:	8b 45 14             	mov    0x14(%ebp),%eax
  8006e3:	8d 50 04             	lea    0x4(%eax),%edx
  8006e6:	89 55 14             	mov    %edx,0x14(%ebp)

        // pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8006e9:	8b 18                	mov    (%eax),%ebx
  8006eb:	be 00 00 00 00       	mov    $0x0,%esi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8006f0:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8006f3:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8006f8:	eb 16                	jmp    800710 <vprintfmt+0x32f>
  8006fa:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8006fd:	89 ca                	mov    %ecx,%edx
  8006ff:	8d 45 14             	lea    0x14(%ebp),%eax
  800702:	e8 37 fc ff ff       	call   80033e <getuint>
  800707:	89 c3                	mov    %eax,%ebx
  800709:	89 d6                	mov    %edx,%esi
			base = 16;
  80070b:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800710:	83 ec 0c             	sub    $0xc,%esp
  800713:	0f be 55 dc          	movsbl -0x24(%ebp),%edx
  800717:	52                   	push   %edx
  800718:	ff 75 e4             	pushl  -0x1c(%ebp)
  80071b:	50                   	push   %eax
  80071c:	56                   	push   %esi
  80071d:	53                   	push   %ebx
  80071e:	89 fa                	mov    %edi,%edx
  800720:	8b 45 08             	mov    0x8(%ebp),%eax
  800723:	e8 68 fb ff ff       	call   800290 <printnum>
			break;
  800728:	83 c4 20             	add    $0x20,%esp
  80072b:	8b 75 d8             	mov    -0x28(%ebp),%esi
  80072e:	e9 d2 fc ff ff       	jmp    800405 <vprintfmt+0x24>
  800733:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800736:	83 ec 08             	sub    $0x8,%esp
  800739:	57                   	push   %edi
  80073a:	52                   	push   %edx
  80073b:	ff 55 08             	call   *0x8(%ebp)
			break;
  80073e:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800741:	8b 75 d8             	mov    -0x28(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800744:	e9 bc fc ff ff       	jmp    800405 <vprintfmt+0x24>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800749:	83 ec 08             	sub    $0x8,%esp
  80074c:	57                   	push   %edi
  80074d:	6a 25                	push   $0x25
  80074f:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800752:	83 c4 10             	add    $0x10,%esp
  800755:	eb 02                	jmp    800759 <vprintfmt+0x378>
  800757:	89 c6                	mov    %eax,%esi
  800759:	8d 46 ff             	lea    -0x1(%esi),%eax
  80075c:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800760:	75 f5                	jne    800757 <vprintfmt+0x376>
  800762:	e9 9e fc ff ff       	jmp    800405 <vprintfmt+0x24>
				/* do nothing */;
			break;
		}
	}
}
  800767:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80076a:	5b                   	pop    %ebx
  80076b:	5e                   	pop    %esi
  80076c:	5f                   	pop    %edi
  80076d:	c9                   	leave  
  80076e:	c3                   	ret    

0080076f <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80076f:	55                   	push   %ebp
  800770:	89 e5                	mov    %esp,%ebp
  800772:	83 ec 18             	sub    $0x18,%esp
  800775:	8b 45 08             	mov    0x8(%ebp),%eax
  800778:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80077b:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80077e:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800782:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800785:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80078c:	85 c0                	test   %eax,%eax
  80078e:	74 26                	je     8007b6 <vsnprintf+0x47>
  800790:	85 d2                	test   %edx,%edx
  800792:	7e 29                	jle    8007bd <vsnprintf+0x4e>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800794:	ff 75 14             	pushl  0x14(%ebp)
  800797:	ff 75 10             	pushl  0x10(%ebp)
  80079a:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80079d:	50                   	push   %eax
  80079e:	68 aa 03 80 00       	push   $0x8003aa
  8007a3:	e8 39 fc ff ff       	call   8003e1 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8007a8:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007ab:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8007ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007b1:	83 c4 10             	add    $0x10,%esp
  8007b4:	eb 0c                	jmp    8007c2 <vsnprintf+0x53>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8007b6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8007bb:	eb 05                	jmp    8007c2 <vsnprintf+0x53>
  8007bd:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8007c2:	c9                   	leave  
  8007c3:	c3                   	ret    

008007c4 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007c4:	55                   	push   %ebp
  8007c5:	89 e5                	mov    %esp,%ebp
  8007c7:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007ca:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8007cd:	50                   	push   %eax
  8007ce:	ff 75 10             	pushl  0x10(%ebp)
  8007d1:	ff 75 0c             	pushl  0xc(%ebp)
  8007d4:	ff 75 08             	pushl  0x8(%ebp)
  8007d7:	e8 93 ff ff ff       	call   80076f <vsnprintf>
	va_end(ap);

	return rc;
}
  8007dc:	c9                   	leave  
  8007dd:	c3                   	ret    
	...

008007e0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007e0:	55                   	push   %ebp
  8007e1:	89 e5                	mov    %esp,%ebp
  8007e3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007e6:	80 3a 00             	cmpb   $0x0,(%edx)
  8007e9:	74 0e                	je     8007f9 <strlen+0x19>
  8007eb:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  8007f0:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8007f1:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007f5:	75 f9                	jne    8007f0 <strlen+0x10>
  8007f7:	eb 05                	jmp    8007fe <strlen+0x1e>
  8007f9:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  8007fe:	c9                   	leave  
  8007ff:	c3                   	ret    

00800800 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800800:	55                   	push   %ebp
  800801:	89 e5                	mov    %esp,%ebp
  800803:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800806:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800809:	85 d2                	test   %edx,%edx
  80080b:	74 17                	je     800824 <strnlen+0x24>
  80080d:	80 39 00             	cmpb   $0x0,(%ecx)
  800810:	74 19                	je     80082b <strnlen+0x2b>
  800812:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800817:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800818:	39 d0                	cmp    %edx,%eax
  80081a:	74 14                	je     800830 <strnlen+0x30>
  80081c:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800820:	75 f5                	jne    800817 <strnlen+0x17>
  800822:	eb 0c                	jmp    800830 <strnlen+0x30>
  800824:	b8 00 00 00 00       	mov    $0x0,%eax
  800829:	eb 05                	jmp    800830 <strnlen+0x30>
  80082b:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800830:	c9                   	leave  
  800831:	c3                   	ret    

00800832 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800832:	55                   	push   %ebp
  800833:	89 e5                	mov    %esp,%ebp
  800835:	53                   	push   %ebx
  800836:	8b 45 08             	mov    0x8(%ebp),%eax
  800839:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80083c:	ba 00 00 00 00       	mov    $0x0,%edx
  800841:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  800844:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800847:	42                   	inc    %edx
  800848:	84 c9                	test   %cl,%cl
  80084a:	75 f5                	jne    800841 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  80084c:	5b                   	pop    %ebx
  80084d:	c9                   	leave  
  80084e:	c3                   	ret    

0080084f <strcat>:

char *
strcat(char *dst, const char *src)
{
  80084f:	55                   	push   %ebp
  800850:	89 e5                	mov    %esp,%ebp
  800852:	53                   	push   %ebx
  800853:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800856:	53                   	push   %ebx
  800857:	e8 84 ff ff ff       	call   8007e0 <strlen>
  80085c:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  80085f:	ff 75 0c             	pushl  0xc(%ebp)
  800862:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  800865:	50                   	push   %eax
  800866:	e8 c7 ff ff ff       	call   800832 <strcpy>
	return dst;
}
  80086b:	89 d8                	mov    %ebx,%eax
  80086d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800870:	c9                   	leave  
  800871:	c3                   	ret    

00800872 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800872:	55                   	push   %ebp
  800873:	89 e5                	mov    %esp,%ebp
  800875:	56                   	push   %esi
  800876:	53                   	push   %ebx
  800877:	8b 45 08             	mov    0x8(%ebp),%eax
  80087a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80087d:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800880:	85 f6                	test   %esi,%esi
  800882:	74 15                	je     800899 <strncpy+0x27>
  800884:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  800889:	8a 1a                	mov    (%edx),%bl
  80088b:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80088e:	80 3a 01             	cmpb   $0x1,(%edx)
  800891:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800894:	41                   	inc    %ecx
  800895:	39 ce                	cmp    %ecx,%esi
  800897:	77 f0                	ja     800889 <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800899:	5b                   	pop    %ebx
  80089a:	5e                   	pop    %esi
  80089b:	c9                   	leave  
  80089c:	c3                   	ret    

0080089d <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80089d:	55                   	push   %ebp
  80089e:	89 e5                	mov    %esp,%ebp
  8008a0:	57                   	push   %edi
  8008a1:	56                   	push   %esi
  8008a2:	53                   	push   %ebx
  8008a3:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008a6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8008a9:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8008ac:	85 f6                	test   %esi,%esi
  8008ae:	74 32                	je     8008e2 <strlcpy+0x45>
		while (--size > 0 && *src != '\0')
  8008b0:	83 fe 01             	cmp    $0x1,%esi
  8008b3:	74 22                	je     8008d7 <strlcpy+0x3a>
  8008b5:	8a 0b                	mov    (%ebx),%cl
  8008b7:	84 c9                	test   %cl,%cl
  8008b9:	74 20                	je     8008db <strlcpy+0x3e>
  8008bb:	89 f8                	mov    %edi,%eax
  8008bd:	ba 00 00 00 00       	mov    $0x0,%edx
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
  8008c2:	83 ee 02             	sub    $0x2,%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8008c5:	88 08                	mov    %cl,(%eax)
  8008c7:	40                   	inc    %eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8008c8:	39 f2                	cmp    %esi,%edx
  8008ca:	74 11                	je     8008dd <strlcpy+0x40>
  8008cc:	8a 4c 13 01          	mov    0x1(%ebx,%edx,1),%cl
  8008d0:	42                   	inc    %edx
  8008d1:	84 c9                	test   %cl,%cl
  8008d3:	75 f0                	jne    8008c5 <strlcpy+0x28>
  8008d5:	eb 06                	jmp    8008dd <strlcpy+0x40>
  8008d7:	89 f8                	mov    %edi,%eax
  8008d9:	eb 02                	jmp    8008dd <strlcpy+0x40>
  8008db:	89 f8                	mov    %edi,%eax
			*dst++ = *src++;
		*dst = '\0';
  8008dd:	c6 00 00             	movb   $0x0,(%eax)
  8008e0:	eb 02                	jmp    8008e4 <strlcpy+0x47>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8008e2:	89 f8                	mov    %edi,%eax
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
		*dst = '\0';
	}
	return dst - dst_in;
  8008e4:	29 f8                	sub    %edi,%eax
}
  8008e6:	5b                   	pop    %ebx
  8008e7:	5e                   	pop    %esi
  8008e8:	5f                   	pop    %edi
  8008e9:	c9                   	leave  
  8008ea:	c3                   	ret    

008008eb <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8008eb:	55                   	push   %ebp
  8008ec:	89 e5                	mov    %esp,%ebp
  8008ee:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008f1:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008f4:	8a 01                	mov    (%ecx),%al
  8008f6:	84 c0                	test   %al,%al
  8008f8:	74 10                	je     80090a <strcmp+0x1f>
  8008fa:	3a 02                	cmp    (%edx),%al
  8008fc:	75 0c                	jne    80090a <strcmp+0x1f>
		p++, q++;
  8008fe:	41                   	inc    %ecx
  8008ff:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800900:	8a 01                	mov    (%ecx),%al
  800902:	84 c0                	test   %al,%al
  800904:	74 04                	je     80090a <strcmp+0x1f>
  800906:	3a 02                	cmp    (%edx),%al
  800908:	74 f4                	je     8008fe <strcmp+0x13>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80090a:	0f b6 c0             	movzbl %al,%eax
  80090d:	0f b6 12             	movzbl (%edx),%edx
  800910:	29 d0                	sub    %edx,%eax
}
  800912:	c9                   	leave  
  800913:	c3                   	ret    

00800914 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800914:	55                   	push   %ebp
  800915:	89 e5                	mov    %esp,%ebp
  800917:	53                   	push   %ebx
  800918:	8b 55 08             	mov    0x8(%ebp),%edx
  80091b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80091e:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  800921:	85 c0                	test   %eax,%eax
  800923:	74 1b                	je     800940 <strncmp+0x2c>
  800925:	8a 1a                	mov    (%edx),%bl
  800927:	84 db                	test   %bl,%bl
  800929:	74 24                	je     80094f <strncmp+0x3b>
  80092b:	3a 19                	cmp    (%ecx),%bl
  80092d:	75 20                	jne    80094f <strncmp+0x3b>
  80092f:	48                   	dec    %eax
  800930:	74 15                	je     800947 <strncmp+0x33>
		n--, p++, q++;
  800932:	42                   	inc    %edx
  800933:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800934:	8a 1a                	mov    (%edx),%bl
  800936:	84 db                	test   %bl,%bl
  800938:	74 15                	je     80094f <strncmp+0x3b>
  80093a:	3a 19                	cmp    (%ecx),%bl
  80093c:	74 f1                	je     80092f <strncmp+0x1b>
  80093e:	eb 0f                	jmp    80094f <strncmp+0x3b>
		n--, p++, q++;
	if (n == 0)
		return 0;
  800940:	b8 00 00 00 00       	mov    $0x0,%eax
  800945:	eb 05                	jmp    80094c <strncmp+0x38>
  800947:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80094c:	5b                   	pop    %ebx
  80094d:	c9                   	leave  
  80094e:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80094f:	0f b6 02             	movzbl (%edx),%eax
  800952:	0f b6 11             	movzbl (%ecx),%edx
  800955:	29 d0                	sub    %edx,%eax
  800957:	eb f3                	jmp    80094c <strncmp+0x38>

00800959 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800959:	55                   	push   %ebp
  80095a:	89 e5                	mov    %esp,%ebp
  80095c:	8b 45 08             	mov    0x8(%ebp),%eax
  80095f:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800962:	8a 10                	mov    (%eax),%dl
  800964:	84 d2                	test   %dl,%dl
  800966:	74 18                	je     800980 <strchr+0x27>
		if (*s == c)
  800968:	38 ca                	cmp    %cl,%dl
  80096a:	75 06                	jne    800972 <strchr+0x19>
  80096c:	eb 17                	jmp    800985 <strchr+0x2c>
  80096e:	38 ca                	cmp    %cl,%dl
  800970:	74 13                	je     800985 <strchr+0x2c>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800972:	40                   	inc    %eax
  800973:	8a 10                	mov    (%eax),%dl
  800975:	84 d2                	test   %dl,%dl
  800977:	75 f5                	jne    80096e <strchr+0x15>
		if (*s == c)
			return (char *) s;
	return 0;
  800979:	b8 00 00 00 00       	mov    $0x0,%eax
  80097e:	eb 05                	jmp    800985 <strchr+0x2c>
  800980:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800985:	c9                   	leave  
  800986:	c3                   	ret    

00800987 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800987:	55                   	push   %ebp
  800988:	89 e5                	mov    %esp,%ebp
  80098a:	8b 45 08             	mov    0x8(%ebp),%eax
  80098d:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800990:	8a 10                	mov    (%eax),%dl
  800992:	84 d2                	test   %dl,%dl
  800994:	74 11                	je     8009a7 <strfind+0x20>
		if (*s == c)
  800996:	38 ca                	cmp    %cl,%dl
  800998:	75 06                	jne    8009a0 <strfind+0x19>
  80099a:	eb 0b                	jmp    8009a7 <strfind+0x20>
  80099c:	38 ca                	cmp    %cl,%dl
  80099e:	74 07                	je     8009a7 <strfind+0x20>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  8009a0:	40                   	inc    %eax
  8009a1:	8a 10                	mov    (%eax),%dl
  8009a3:	84 d2                	test   %dl,%dl
  8009a5:	75 f5                	jne    80099c <strfind+0x15>
		if (*s == c)
			break;
	return (char *) s;
}
  8009a7:	c9                   	leave  
  8009a8:	c3                   	ret    

008009a9 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8009a9:	55                   	push   %ebp
  8009aa:	89 e5                	mov    %esp,%ebp
  8009ac:	57                   	push   %edi
  8009ad:	56                   	push   %esi
  8009ae:	53                   	push   %ebx
  8009af:	8b 7d 08             	mov    0x8(%ebp),%edi
  8009b2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009b5:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8009b8:	85 c9                	test   %ecx,%ecx
  8009ba:	74 30                	je     8009ec <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8009bc:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8009c2:	75 25                	jne    8009e9 <memset+0x40>
  8009c4:	f6 c1 03             	test   $0x3,%cl
  8009c7:	75 20                	jne    8009e9 <memset+0x40>
		c &= 0xFF;
  8009c9:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8009cc:	89 d3                	mov    %edx,%ebx
  8009ce:	c1 e3 08             	shl    $0x8,%ebx
  8009d1:	89 d6                	mov    %edx,%esi
  8009d3:	c1 e6 18             	shl    $0x18,%esi
  8009d6:	89 d0                	mov    %edx,%eax
  8009d8:	c1 e0 10             	shl    $0x10,%eax
  8009db:	09 f0                	or     %esi,%eax
  8009dd:	09 d0                	or     %edx,%eax
  8009df:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  8009e1:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  8009e4:	fc                   	cld    
  8009e5:	f3 ab                	rep stos %eax,%es:(%edi)
  8009e7:	eb 03                	jmp    8009ec <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8009e9:	fc                   	cld    
  8009ea:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8009ec:	89 f8                	mov    %edi,%eax
  8009ee:	5b                   	pop    %ebx
  8009ef:	5e                   	pop    %esi
  8009f0:	5f                   	pop    %edi
  8009f1:	c9                   	leave  
  8009f2:	c3                   	ret    

008009f3 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8009f3:	55                   	push   %ebp
  8009f4:	89 e5                	mov    %esp,%ebp
  8009f6:	57                   	push   %edi
  8009f7:	56                   	push   %esi
  8009f8:	8b 45 08             	mov    0x8(%ebp),%eax
  8009fb:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009fe:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a01:	39 c6                	cmp    %eax,%esi
  800a03:	73 34                	jae    800a39 <memmove+0x46>
  800a05:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a08:	39 d0                	cmp    %edx,%eax
  800a0a:	73 2d                	jae    800a39 <memmove+0x46>
		s += n;
		d += n;
  800a0c:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a0f:	f6 c2 03             	test   $0x3,%dl
  800a12:	75 1b                	jne    800a2f <memmove+0x3c>
  800a14:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a1a:	75 13                	jne    800a2f <memmove+0x3c>
  800a1c:	f6 c1 03             	test   $0x3,%cl
  800a1f:	75 0e                	jne    800a2f <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800a21:	83 ef 04             	sub    $0x4,%edi
  800a24:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a27:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800a2a:	fd                   	std    
  800a2b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a2d:	eb 07                	jmp    800a36 <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800a2f:	4f                   	dec    %edi
  800a30:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800a33:	fd                   	std    
  800a34:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a36:	fc                   	cld    
  800a37:	eb 20                	jmp    800a59 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a39:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a3f:	75 13                	jne    800a54 <memmove+0x61>
  800a41:	a8 03                	test   $0x3,%al
  800a43:	75 0f                	jne    800a54 <memmove+0x61>
  800a45:	f6 c1 03             	test   $0x3,%cl
  800a48:	75 0a                	jne    800a54 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800a4a:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800a4d:	89 c7                	mov    %eax,%edi
  800a4f:	fc                   	cld    
  800a50:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a52:	eb 05                	jmp    800a59 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a54:	89 c7                	mov    %eax,%edi
  800a56:	fc                   	cld    
  800a57:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a59:	5e                   	pop    %esi
  800a5a:	5f                   	pop    %edi
  800a5b:	c9                   	leave  
  800a5c:	c3                   	ret    

00800a5d <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a5d:	55                   	push   %ebp
  800a5e:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800a60:	ff 75 10             	pushl  0x10(%ebp)
  800a63:	ff 75 0c             	pushl  0xc(%ebp)
  800a66:	ff 75 08             	pushl  0x8(%ebp)
  800a69:	e8 85 ff ff ff       	call   8009f3 <memmove>
}
  800a6e:	c9                   	leave  
  800a6f:	c3                   	ret    

00800a70 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a70:	55                   	push   %ebp
  800a71:	89 e5                	mov    %esp,%ebp
  800a73:	57                   	push   %edi
  800a74:	56                   	push   %esi
  800a75:	53                   	push   %ebx
  800a76:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800a79:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a7c:	8b 7d 10             	mov    0x10(%ebp),%edi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a7f:	85 ff                	test   %edi,%edi
  800a81:	74 32                	je     800ab5 <memcmp+0x45>
		if (*s1 != *s2)
  800a83:	8a 03                	mov    (%ebx),%al
  800a85:	8a 0e                	mov    (%esi),%cl
  800a87:	38 c8                	cmp    %cl,%al
  800a89:	74 19                	je     800aa4 <memcmp+0x34>
  800a8b:	eb 0d                	jmp    800a9a <memcmp+0x2a>
  800a8d:	8a 44 13 01          	mov    0x1(%ebx,%edx,1),%al
  800a91:	8a 4c 16 01          	mov    0x1(%esi,%edx,1),%cl
  800a95:	42                   	inc    %edx
  800a96:	38 c8                	cmp    %cl,%al
  800a98:	74 10                	je     800aaa <memcmp+0x3a>
			return (int) *s1 - (int) *s2;
  800a9a:	0f b6 c0             	movzbl %al,%eax
  800a9d:	0f b6 c9             	movzbl %cl,%ecx
  800aa0:	29 c8                	sub    %ecx,%eax
  800aa2:	eb 16                	jmp    800aba <memcmp+0x4a>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800aa4:	4f                   	dec    %edi
  800aa5:	ba 00 00 00 00       	mov    $0x0,%edx
  800aaa:	39 fa                	cmp    %edi,%edx
  800aac:	75 df                	jne    800a8d <memcmp+0x1d>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800aae:	b8 00 00 00 00       	mov    $0x0,%eax
  800ab3:	eb 05                	jmp    800aba <memcmp+0x4a>
  800ab5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800aba:	5b                   	pop    %ebx
  800abb:	5e                   	pop    %esi
  800abc:	5f                   	pop    %edi
  800abd:	c9                   	leave  
  800abe:	c3                   	ret    

00800abf <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800abf:	55                   	push   %ebp
  800ac0:	89 e5                	mov    %esp,%ebp
  800ac2:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800ac5:	89 c2                	mov    %eax,%edx
  800ac7:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800aca:	39 d0                	cmp    %edx,%eax
  800acc:	73 12                	jae    800ae0 <memfind+0x21>
		if (*(const unsigned char *) s == (unsigned char) c)
  800ace:	8a 4d 0c             	mov    0xc(%ebp),%cl
  800ad1:	38 08                	cmp    %cl,(%eax)
  800ad3:	75 06                	jne    800adb <memfind+0x1c>
  800ad5:	eb 09                	jmp    800ae0 <memfind+0x21>
  800ad7:	38 08                	cmp    %cl,(%eax)
  800ad9:	74 05                	je     800ae0 <memfind+0x21>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800adb:	40                   	inc    %eax
  800adc:	39 c2                	cmp    %eax,%edx
  800ade:	77 f7                	ja     800ad7 <memfind+0x18>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800ae0:	c9                   	leave  
  800ae1:	c3                   	ret    

00800ae2 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800ae2:	55                   	push   %ebp
  800ae3:	89 e5                	mov    %esp,%ebp
  800ae5:	57                   	push   %edi
  800ae6:	56                   	push   %esi
  800ae7:	53                   	push   %ebx
  800ae8:	8b 55 08             	mov    0x8(%ebp),%edx
  800aeb:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800aee:	eb 01                	jmp    800af1 <strtol+0xf>
		s++;
  800af0:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800af1:	8a 02                	mov    (%edx),%al
  800af3:	3c 20                	cmp    $0x20,%al
  800af5:	74 f9                	je     800af0 <strtol+0xe>
  800af7:	3c 09                	cmp    $0x9,%al
  800af9:	74 f5                	je     800af0 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800afb:	3c 2b                	cmp    $0x2b,%al
  800afd:	75 08                	jne    800b07 <strtol+0x25>
		s++;
  800aff:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800b00:	bf 00 00 00 00       	mov    $0x0,%edi
  800b05:	eb 13                	jmp    800b1a <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800b07:	3c 2d                	cmp    $0x2d,%al
  800b09:	75 0a                	jne    800b15 <strtol+0x33>
		s++, neg = 1;
  800b0b:	8d 52 01             	lea    0x1(%edx),%edx
  800b0e:	bf 01 00 00 00       	mov    $0x1,%edi
  800b13:	eb 05                	jmp    800b1a <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800b15:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b1a:	85 db                	test   %ebx,%ebx
  800b1c:	74 05                	je     800b23 <strtol+0x41>
  800b1e:	83 fb 10             	cmp    $0x10,%ebx
  800b21:	75 28                	jne    800b4b <strtol+0x69>
  800b23:	8a 02                	mov    (%edx),%al
  800b25:	3c 30                	cmp    $0x30,%al
  800b27:	75 10                	jne    800b39 <strtol+0x57>
  800b29:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800b2d:	75 0a                	jne    800b39 <strtol+0x57>
		s += 2, base = 16;
  800b2f:	83 c2 02             	add    $0x2,%edx
  800b32:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b37:	eb 12                	jmp    800b4b <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800b39:	85 db                	test   %ebx,%ebx
  800b3b:	75 0e                	jne    800b4b <strtol+0x69>
  800b3d:	3c 30                	cmp    $0x30,%al
  800b3f:	75 05                	jne    800b46 <strtol+0x64>
		s++, base = 8;
  800b41:	42                   	inc    %edx
  800b42:	b3 08                	mov    $0x8,%bl
  800b44:	eb 05                	jmp    800b4b <strtol+0x69>
	else if (base == 0)
		base = 10;
  800b46:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800b4b:	b8 00 00 00 00       	mov    $0x0,%eax
  800b50:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800b52:	8a 0a                	mov    (%edx),%cl
  800b54:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800b57:	80 fb 09             	cmp    $0x9,%bl
  800b5a:	77 08                	ja     800b64 <strtol+0x82>
			dig = *s - '0';
  800b5c:	0f be c9             	movsbl %cl,%ecx
  800b5f:	83 e9 30             	sub    $0x30,%ecx
  800b62:	eb 1e                	jmp    800b82 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800b64:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800b67:	80 fb 19             	cmp    $0x19,%bl
  800b6a:	77 08                	ja     800b74 <strtol+0x92>
			dig = *s - 'a' + 10;
  800b6c:	0f be c9             	movsbl %cl,%ecx
  800b6f:	83 e9 57             	sub    $0x57,%ecx
  800b72:	eb 0e                	jmp    800b82 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800b74:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800b77:	80 fb 19             	cmp    $0x19,%bl
  800b7a:	77 13                	ja     800b8f <strtol+0xad>
			dig = *s - 'A' + 10;
  800b7c:	0f be c9             	movsbl %cl,%ecx
  800b7f:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800b82:	39 f1                	cmp    %esi,%ecx
  800b84:	7d 0d                	jge    800b93 <strtol+0xb1>
			break;
		s++, val = (val * base) + dig;
  800b86:	42                   	inc    %edx
  800b87:	0f af c6             	imul   %esi,%eax
  800b8a:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  800b8d:	eb c3                	jmp    800b52 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800b8f:	89 c1                	mov    %eax,%ecx
  800b91:	eb 02                	jmp    800b95 <strtol+0xb3>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800b93:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800b95:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b99:	74 05                	je     800ba0 <strtol+0xbe>
		*endptr = (char *) s;
  800b9b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800b9e:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800ba0:	85 ff                	test   %edi,%edi
  800ba2:	74 04                	je     800ba8 <strtol+0xc6>
  800ba4:	89 c8                	mov    %ecx,%eax
  800ba6:	f7 d8                	neg    %eax
}
  800ba8:	5b                   	pop    %ebx
  800ba9:	5e                   	pop    %esi
  800baa:	5f                   	pop    %edi
  800bab:	c9                   	leave  
  800bac:	c3                   	ret    
  800bad:	00 00                	add    %al,(%eax)
	...

00800bb0 <syscall>:
	return ret;
}

static int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800bb0:	55                   	push   %ebp
  800bb1:	89 e5                	mov    %esp,%ebp
  800bb3:	57                   	push   %edi
  800bb4:	56                   	push   %esi
  800bb5:	53                   	push   %ebx
  800bb6:	83 ec 1c             	sub    $0x1c,%esp
  800bb9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800bbc:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800bbf:	89 ca                	mov    %ecx,%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bc1:	8b 75 14             	mov    0x14(%ebp),%esi
  800bc4:	8b 7d 10             	mov    0x10(%ebp),%edi
  800bc7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800bca:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800bcd:	cd 30                	int    $0x30
  800bcf:	89 c2                	mov    %eax,%edx
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800bd1:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800bd5:	74 1c                	je     800bf3 <syscall+0x43>
  800bd7:	85 c0                	test   %eax,%eax
  800bd9:	7e 18                	jle    800bf3 <syscall+0x43>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bdb:	83 ec 0c             	sub    $0xc,%esp
  800bde:	50                   	push   %eax
  800bdf:	ff 75 e4             	pushl  -0x1c(%ebp)
  800be2:	68 ff 2a 80 00       	push   $0x802aff
  800be7:	6a 42                	push   $0x42
  800be9:	68 1c 2b 80 00       	push   $0x802b1c
  800bee:	e8 b1 f5 ff ff       	call   8001a4 <_panic>

	return ret;
}
  800bf3:	89 d0                	mov    %edx,%eax
  800bf5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bf8:	5b                   	pop    %ebx
  800bf9:	5e                   	pop    %esi
  800bfa:	5f                   	pop    %edi
  800bfb:	c9                   	leave  
  800bfc:	c3                   	ret    

00800bfd <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{	
  800bfd:	55                   	push   %ebp
  800bfe:	89 e5                	mov    %esp,%ebp
  800c00:	83 ec 08             	sub    $0x8,%esp
	// my_sysenter(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
	// return;
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  800c03:	6a 00                	push   $0x0
  800c05:	6a 00                	push   $0x0
  800c07:	6a 00                	push   $0x0
  800c09:	ff 75 0c             	pushl  0xc(%ebp)
  800c0c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c0f:	ba 00 00 00 00       	mov    $0x0,%edx
  800c14:	b8 00 00 00 00       	mov    $0x0,%eax
  800c19:	e8 92 ff ff ff       	call   800bb0 <syscall>
  800c1e:	83 c4 10             	add    $0x10,%esp
	return;
}
  800c21:	c9                   	leave  
  800c22:	c3                   	ret    

00800c23 <sys_cgetc>:

int
sys_cgetc(void)
{
  800c23:	55                   	push   %ebp
  800c24:	89 e5                	mov    %esp,%ebp
  800c26:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_cgetc, 0, 0, 0, 0, 0, 0);
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  800c29:	6a 00                	push   $0x0
  800c2b:	6a 00                	push   $0x0
  800c2d:	6a 00                	push   $0x0
  800c2f:	6a 00                	push   $0x0
  800c31:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c36:	ba 00 00 00 00       	mov    $0x0,%edx
  800c3b:	b8 01 00 00 00       	mov    $0x1,%eax
  800c40:	e8 6b ff ff ff       	call   800bb0 <syscall>
}
  800c45:	c9                   	leave  
  800c46:	c3                   	ret    

00800c47 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800c47:	55                   	push   %ebp
  800c48:	89 e5                	mov    %esp,%ebp
  800c4a:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  800c4d:	6a 00                	push   $0x0
  800c4f:	6a 00                	push   $0x0
  800c51:	6a 00                	push   $0x0
  800c53:	6a 00                	push   $0x0
  800c55:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c58:	ba 01 00 00 00       	mov    $0x1,%edx
  800c5d:	b8 03 00 00 00       	mov    $0x3,%eax
  800c62:	e8 49 ff ff ff       	call   800bb0 <syscall>
}
  800c67:	c9                   	leave  
  800c68:	c3                   	ret    

00800c69 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c69:	55                   	push   %ebp
  800c6a:	89 e5                	mov    %esp,%ebp
  800c6c:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_getenvid, 0, 0, 0, 0, 0, 0);
	return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  800c6f:	6a 00                	push   $0x0
  800c71:	6a 00                	push   $0x0
  800c73:	6a 00                	push   $0x0
  800c75:	6a 00                	push   $0x0
  800c77:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c7c:	ba 00 00 00 00       	mov    $0x0,%edx
  800c81:	b8 02 00 00 00       	mov    $0x2,%eax
  800c86:	e8 25 ff ff ff       	call   800bb0 <syscall>
}
  800c8b:	c9                   	leave  
  800c8c:	c3                   	ret    

00800c8d <sys_yield>:

void
sys_yield(void)
{
  800c8d:	55                   	push   %ebp
  800c8e:	89 e5                	mov    %esp,%ebp
  800c90:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  800c93:	6a 00                	push   $0x0
  800c95:	6a 00                	push   $0x0
  800c97:	6a 00                	push   $0x0
  800c99:	6a 00                	push   $0x0
  800c9b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ca0:	ba 00 00 00 00       	mov    $0x0,%edx
  800ca5:	b8 0b 00 00 00       	mov    $0xb,%eax
  800caa:	e8 01 ff ff ff       	call   800bb0 <syscall>
  800caf:	83 c4 10             	add    $0x10,%esp
}
  800cb2:	c9                   	leave  
  800cb3:	c3                   	ret    

00800cb4 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800cb4:	55                   	push   %ebp
  800cb5:	89 e5                	mov    %esp,%ebp
  800cb7:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  800cba:	6a 00                	push   $0x0
  800cbc:	6a 00                	push   $0x0
  800cbe:	ff 75 10             	pushl  0x10(%ebp)
  800cc1:	ff 75 0c             	pushl  0xc(%ebp)
  800cc4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800cc7:	ba 01 00 00 00       	mov    $0x1,%edx
  800ccc:	b8 04 00 00 00       	mov    $0x4,%eax
  800cd1:	e8 da fe ff ff       	call   800bb0 <syscall>
}
  800cd6:	c9                   	leave  
  800cd7:	c3                   	ret    

00800cd8 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800cd8:	55                   	push   %ebp
  800cd9:	89 e5                	mov    %esp,%ebp
  800cdb:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
  800cde:	ff 75 18             	pushl  0x18(%ebp)
  800ce1:	ff 75 14             	pushl  0x14(%ebp)
  800ce4:	ff 75 10             	pushl  0x10(%ebp)
  800ce7:	ff 75 0c             	pushl  0xc(%ebp)
  800cea:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ced:	ba 01 00 00 00       	mov    $0x1,%edx
  800cf2:	b8 05 00 00 00       	mov    $0x5,%eax
  800cf7:	e8 b4 fe ff ff       	call   800bb0 <syscall>
}
  800cfc:	c9                   	leave  
  800cfd:	c3                   	ret    

00800cfe <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800cfe:	55                   	push   %ebp
  800cff:	89 e5                	mov    %esp,%ebp
  800d01:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  800d04:	6a 00                	push   $0x0
  800d06:	6a 00                	push   $0x0
  800d08:	6a 00                	push   $0x0
  800d0a:	ff 75 0c             	pushl  0xc(%ebp)
  800d0d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d10:	ba 01 00 00 00       	mov    $0x1,%edx
  800d15:	b8 06 00 00 00       	mov    $0x6,%eax
  800d1a:	e8 91 fe ff ff       	call   800bb0 <syscall>
}
  800d1f:	c9                   	leave  
  800d20:	c3                   	ret    

00800d21 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800d21:	55                   	push   %ebp
  800d22:	89 e5                	mov    %esp,%ebp
  800d24:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  800d27:	6a 00                	push   $0x0
  800d29:	6a 00                	push   $0x0
  800d2b:	6a 00                	push   $0x0
  800d2d:	ff 75 0c             	pushl  0xc(%ebp)
  800d30:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d33:	ba 01 00 00 00       	mov    $0x1,%edx
  800d38:	b8 08 00 00 00       	mov    $0x8,%eax
  800d3d:	e8 6e fe ff ff       	call   800bb0 <syscall>
}
  800d42:	c9                   	leave  
  800d43:	c3                   	ret    

00800d44 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800d44:	55                   	push   %ebp
  800d45:	89 e5                	mov    %esp,%ebp
  800d47:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
  800d4a:	6a 00                	push   $0x0
  800d4c:	6a 00                	push   $0x0
  800d4e:	6a 00                	push   $0x0
  800d50:	ff 75 0c             	pushl  0xc(%ebp)
  800d53:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d56:	ba 01 00 00 00       	mov    $0x1,%edx
  800d5b:	b8 09 00 00 00       	mov    $0x9,%eax
  800d60:	e8 4b fe ff ff       	call   800bb0 <syscall>
}
  800d65:	c9                   	leave  
  800d66:	c3                   	ret    

00800d67 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d67:	55                   	push   %ebp
  800d68:	89 e5                	mov    %esp,%ebp
  800d6a:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  800d6d:	6a 00                	push   $0x0
  800d6f:	6a 00                	push   $0x0
  800d71:	6a 00                	push   $0x0
  800d73:	ff 75 0c             	pushl  0xc(%ebp)
  800d76:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d79:	ba 01 00 00 00       	mov    $0x1,%edx
  800d7e:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d83:	e8 28 fe ff ff       	call   800bb0 <syscall>
}
  800d88:	c9                   	leave  
  800d89:	c3                   	ret    

00800d8a <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d8a:	55                   	push   %ebp
  800d8b:	89 e5                	mov    %esp,%ebp
  800d8d:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  800d90:	6a 00                	push   $0x0
  800d92:	ff 75 14             	pushl  0x14(%ebp)
  800d95:	ff 75 10             	pushl  0x10(%ebp)
  800d98:	ff 75 0c             	pushl  0xc(%ebp)
  800d9b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d9e:	ba 00 00 00 00       	mov    $0x0,%edx
  800da3:	b8 0c 00 00 00       	mov    $0xc,%eax
  800da8:	e8 03 fe ff ff       	call   800bb0 <syscall>
}
  800dad:	c9                   	leave  
  800dae:	c3                   	ret    

00800daf <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800daf:	55                   	push   %ebp
  800db0:	89 e5                	mov    %esp,%ebp
  800db2:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  800db5:	6a 00                	push   $0x0
  800db7:	6a 00                	push   $0x0
  800db9:	6a 00                	push   $0x0
  800dbb:	6a 00                	push   $0x0
  800dbd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800dc0:	ba 01 00 00 00       	mov    $0x1,%edx
  800dc5:	b8 0d 00 00 00       	mov    $0xd,%eax
  800dca:	e8 e1 fd ff ff       	call   800bb0 <syscall>
}
  800dcf:	c9                   	leave  
  800dd0:	c3                   	ret    

00800dd1 <sys_set_priority>:

int
sys_set_priority(envid_t envid, uint32_t new_priority)
{
  800dd1:	55                   	push   %ebp
  800dd2:	89 e5                	mov    %esp,%ebp
  800dd4:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_set_priority, 0, envid, new_priority, 0, 0, 0);
  800dd7:	6a 00                	push   $0x0
  800dd9:	6a 00                	push   $0x0
  800ddb:	6a 00                	push   $0x0
  800ddd:	ff 75 0c             	pushl  0xc(%ebp)
  800de0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800de3:	ba 00 00 00 00       	mov    $0x0,%edx
  800de8:	b8 0e 00 00 00       	mov    $0xe,%eax
  800ded:	e8 be fd ff ff       	call   800bb0 <syscall>
}
  800df2:	c9                   	leave  
  800df3:	c3                   	ret    

00800df4 <sys_exec>:

int
sys_exec(uint32_t eip, uint32_t esp, void * ph, uint32_t elf_phnum)
{
  800df4:	55                   	push   %ebp
  800df5:	89 e5                	mov    %esp,%ebp
  800df7:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_exec, 0, eip, esp, (uint32_t)ph, elf_phnum, 0);
  800dfa:	6a 00                	push   $0x0
  800dfc:	ff 75 14             	pushl  0x14(%ebp)
  800dff:	ff 75 10             	pushl  0x10(%ebp)
  800e02:	ff 75 0c             	pushl  0xc(%ebp)
  800e05:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e08:	ba 00 00 00 00       	mov    $0x0,%edx
  800e0d:	b8 0f 00 00 00       	mov    $0xf,%eax
  800e12:	e8 99 fd ff ff       	call   800bb0 <syscall>
  800e17:	c9                   	leave  
  800e18:	c3                   	ret    
  800e19:	00 00                	add    %al,(%eax)
	...

00800e1c <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800e1c:	55                   	push   %ebp
  800e1d:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800e1f:	8b 45 08             	mov    0x8(%ebp),%eax
  800e22:	05 00 00 00 30       	add    $0x30000000,%eax
  800e27:	c1 e8 0c             	shr    $0xc,%eax
}
  800e2a:	c9                   	leave  
  800e2b:	c3                   	ret    

00800e2c <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800e2c:	55                   	push   %ebp
  800e2d:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800e2f:	ff 75 08             	pushl  0x8(%ebp)
  800e32:	e8 e5 ff ff ff       	call   800e1c <fd2num>
  800e37:	83 c4 04             	add    $0x4,%esp
  800e3a:	05 20 00 0d 00       	add    $0xd0020,%eax
  800e3f:	c1 e0 0c             	shl    $0xc,%eax
}
  800e42:	c9                   	leave  
  800e43:	c3                   	ret    

00800e44 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800e44:	55                   	push   %ebp
  800e45:	89 e5                	mov    %esp,%ebp
  800e47:	53                   	push   %ebx
  800e48:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800e4b:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  800e50:	a8 01                	test   $0x1,%al
  800e52:	74 34                	je     800e88 <fd_alloc+0x44>
  800e54:	a1 00 00 74 ef       	mov    0xef740000,%eax
  800e59:	a8 01                	test   $0x1,%al
  800e5b:	74 32                	je     800e8f <fd_alloc+0x4b>
  800e5d:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
  800e62:	89 c1                	mov    %eax,%ecx
  800e64:	89 c2                	mov    %eax,%edx
  800e66:	c1 ea 16             	shr    $0x16,%edx
  800e69:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800e70:	f6 c2 01             	test   $0x1,%dl
  800e73:	74 1f                	je     800e94 <fd_alloc+0x50>
  800e75:	89 c2                	mov    %eax,%edx
  800e77:	c1 ea 0c             	shr    $0xc,%edx
  800e7a:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e81:	f6 c2 01             	test   $0x1,%dl
  800e84:	75 17                	jne    800e9d <fd_alloc+0x59>
  800e86:	eb 0c                	jmp    800e94 <fd_alloc+0x50>
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  800e88:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
  800e8d:	eb 05                	jmp    800e94 <fd_alloc+0x50>
  800e8f:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
  800e94:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  800e96:	b8 00 00 00 00       	mov    $0x0,%eax
  800e9b:	eb 17                	jmp    800eb4 <fd_alloc+0x70>
  800e9d:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800ea2:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800ea7:	75 b9                	jne    800e62 <fd_alloc+0x1e>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800ea9:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  800eaf:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800eb4:	5b                   	pop    %ebx
  800eb5:	c9                   	leave  
  800eb6:	c3                   	ret    

00800eb7 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800eb7:	55                   	push   %ebp
  800eb8:	89 e5                	mov    %esp,%ebp
  800eba:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800ebd:	83 f8 1f             	cmp    $0x1f,%eax
  800ec0:	77 36                	ja     800ef8 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800ec2:	05 00 00 0d 00       	add    $0xd0000,%eax
  800ec7:	c1 e0 0c             	shl    $0xc,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800eca:	89 c2                	mov    %eax,%edx
  800ecc:	c1 ea 16             	shr    $0x16,%edx
  800ecf:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800ed6:	f6 c2 01             	test   $0x1,%dl
  800ed9:	74 24                	je     800eff <fd_lookup+0x48>
  800edb:	89 c2                	mov    %eax,%edx
  800edd:	c1 ea 0c             	shr    $0xc,%edx
  800ee0:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800ee7:	f6 c2 01             	test   $0x1,%dl
  800eea:	74 1a                	je     800f06 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800eec:	8b 55 0c             	mov    0xc(%ebp),%edx
  800eef:	89 02                	mov    %eax,(%edx)
	return 0;
  800ef1:	b8 00 00 00 00       	mov    $0x0,%eax
  800ef6:	eb 13                	jmp    800f0b <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800ef8:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800efd:	eb 0c                	jmp    800f0b <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800eff:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f04:	eb 05                	jmp    800f0b <fd_lookup+0x54>
  800f06:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800f0b:	c9                   	leave  
  800f0c:	c3                   	ret    

00800f0d <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800f0d:	55                   	push   %ebp
  800f0e:	89 e5                	mov    %esp,%ebp
  800f10:	53                   	push   %ebx
  800f11:	83 ec 04             	sub    $0x4,%esp
  800f14:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f17:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  800f1a:	39 0d 04 30 80 00    	cmp    %ecx,0x803004
  800f20:	74 0d                	je     800f2f <dev_lookup+0x22>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800f22:	b8 00 00 00 00       	mov    $0x0,%eax
  800f27:	eb 14                	jmp    800f3d <dev_lookup+0x30>
		if (devtab[i]->dev_id == dev_id) {
  800f29:	39 0a                	cmp    %ecx,(%edx)
  800f2b:	75 10                	jne    800f3d <dev_lookup+0x30>
  800f2d:	eb 05                	jmp    800f34 <dev_lookup+0x27>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800f2f:	ba 04 30 80 00       	mov    $0x803004,%edx
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
  800f34:	89 13                	mov    %edx,(%ebx)
			return 0;
  800f36:	b8 00 00 00 00       	mov    $0x0,%eax
  800f3b:	eb 31                	jmp    800f6e <dev_lookup+0x61>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800f3d:	40                   	inc    %eax
  800f3e:	8b 14 85 a8 2b 80 00 	mov    0x802ba8(,%eax,4),%edx
  800f45:	85 d2                	test   %edx,%edx
  800f47:	75 e0                	jne    800f29 <dev_lookup+0x1c>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800f49:	a1 04 40 80 00       	mov    0x804004,%eax
  800f4e:	8b 40 48             	mov    0x48(%eax),%eax
  800f51:	83 ec 04             	sub    $0x4,%esp
  800f54:	51                   	push   %ecx
  800f55:	50                   	push   %eax
  800f56:	68 2c 2b 80 00       	push   $0x802b2c
  800f5b:	e8 1c f3 ff ff       	call   80027c <cprintf>
	*dev = 0;
  800f60:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  800f66:	83 c4 10             	add    $0x10,%esp
  800f69:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800f6e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f71:	c9                   	leave  
  800f72:	c3                   	ret    

00800f73 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800f73:	55                   	push   %ebp
  800f74:	89 e5                	mov    %esp,%ebp
  800f76:	56                   	push   %esi
  800f77:	53                   	push   %ebx
  800f78:	83 ec 20             	sub    $0x20,%esp
  800f7b:	8b 75 08             	mov    0x8(%ebp),%esi
  800f7e:	8a 45 0c             	mov    0xc(%ebp),%al
  800f81:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800f84:	56                   	push   %esi
  800f85:	e8 92 fe ff ff       	call   800e1c <fd2num>
  800f8a:	8d 55 f4             	lea    -0xc(%ebp),%edx
  800f8d:	89 14 24             	mov    %edx,(%esp)
  800f90:	50                   	push   %eax
  800f91:	e8 21 ff ff ff       	call   800eb7 <fd_lookup>
  800f96:	89 c3                	mov    %eax,%ebx
  800f98:	83 c4 08             	add    $0x8,%esp
  800f9b:	85 c0                	test   %eax,%eax
  800f9d:	78 05                	js     800fa4 <fd_close+0x31>
	    || fd != fd2)
  800f9f:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800fa2:	74 0d                	je     800fb1 <fd_close+0x3e>
		return (must_exist ? r : 0);
  800fa4:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  800fa8:	75 48                	jne    800ff2 <fd_close+0x7f>
  800faa:	bb 00 00 00 00       	mov    $0x0,%ebx
  800faf:	eb 41                	jmp    800ff2 <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800fb1:	83 ec 08             	sub    $0x8,%esp
  800fb4:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800fb7:	50                   	push   %eax
  800fb8:	ff 36                	pushl  (%esi)
  800fba:	e8 4e ff ff ff       	call   800f0d <dev_lookup>
  800fbf:	89 c3                	mov    %eax,%ebx
  800fc1:	83 c4 10             	add    $0x10,%esp
  800fc4:	85 c0                	test   %eax,%eax
  800fc6:	78 1c                	js     800fe4 <fd_close+0x71>
		if (dev->dev_close)
  800fc8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800fcb:	8b 40 10             	mov    0x10(%eax),%eax
  800fce:	85 c0                	test   %eax,%eax
  800fd0:	74 0d                	je     800fdf <fd_close+0x6c>
			r = (*dev->dev_close)(fd);
  800fd2:	83 ec 0c             	sub    $0xc,%esp
  800fd5:	56                   	push   %esi
  800fd6:	ff d0                	call   *%eax
  800fd8:	89 c3                	mov    %eax,%ebx
  800fda:	83 c4 10             	add    $0x10,%esp
  800fdd:	eb 05                	jmp    800fe4 <fd_close+0x71>
		else
			r = 0;
  800fdf:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800fe4:	83 ec 08             	sub    $0x8,%esp
  800fe7:	56                   	push   %esi
  800fe8:	6a 00                	push   $0x0
  800fea:	e8 0f fd ff ff       	call   800cfe <sys_page_unmap>
	return r;
  800fef:	83 c4 10             	add    $0x10,%esp
}
  800ff2:	89 d8                	mov    %ebx,%eax
  800ff4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800ff7:	5b                   	pop    %ebx
  800ff8:	5e                   	pop    %esi
  800ff9:	c9                   	leave  
  800ffa:	c3                   	ret    

00800ffb <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800ffb:	55                   	push   %ebp
  800ffc:	89 e5                	mov    %esp,%ebp
  800ffe:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801001:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801004:	50                   	push   %eax
  801005:	ff 75 08             	pushl  0x8(%ebp)
  801008:	e8 aa fe ff ff       	call   800eb7 <fd_lookup>
  80100d:	83 c4 08             	add    $0x8,%esp
  801010:	85 c0                	test   %eax,%eax
  801012:	78 10                	js     801024 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801014:	83 ec 08             	sub    $0x8,%esp
  801017:	6a 01                	push   $0x1
  801019:	ff 75 f4             	pushl  -0xc(%ebp)
  80101c:	e8 52 ff ff ff       	call   800f73 <fd_close>
  801021:	83 c4 10             	add    $0x10,%esp
}
  801024:	c9                   	leave  
  801025:	c3                   	ret    

00801026 <close_all>:

void
close_all(void)
{
  801026:	55                   	push   %ebp
  801027:	89 e5                	mov    %esp,%ebp
  801029:	53                   	push   %ebx
  80102a:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80102d:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801032:	83 ec 0c             	sub    $0xc,%esp
  801035:	53                   	push   %ebx
  801036:	e8 c0 ff ff ff       	call   800ffb <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80103b:	43                   	inc    %ebx
  80103c:	83 c4 10             	add    $0x10,%esp
  80103f:	83 fb 20             	cmp    $0x20,%ebx
  801042:	75 ee                	jne    801032 <close_all+0xc>
		close(i);
}
  801044:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801047:	c9                   	leave  
  801048:	c3                   	ret    

00801049 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801049:	55                   	push   %ebp
  80104a:	89 e5                	mov    %esp,%ebp
  80104c:	57                   	push   %edi
  80104d:	56                   	push   %esi
  80104e:	53                   	push   %ebx
  80104f:	83 ec 2c             	sub    $0x2c,%esp
  801052:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801055:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801058:	50                   	push   %eax
  801059:	ff 75 08             	pushl  0x8(%ebp)
  80105c:	e8 56 fe ff ff       	call   800eb7 <fd_lookup>
  801061:	89 c3                	mov    %eax,%ebx
  801063:	83 c4 08             	add    $0x8,%esp
  801066:	85 c0                	test   %eax,%eax
  801068:	0f 88 c0 00 00 00    	js     80112e <dup+0xe5>
		return r;
	close(newfdnum);
  80106e:	83 ec 0c             	sub    $0xc,%esp
  801071:	57                   	push   %edi
  801072:	e8 84 ff ff ff       	call   800ffb <close>

	newfd = INDEX2FD(newfdnum);
  801077:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  80107d:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  801080:	83 c4 04             	add    $0x4,%esp
  801083:	ff 75 e4             	pushl  -0x1c(%ebp)
  801086:	e8 a1 fd ff ff       	call   800e2c <fd2data>
  80108b:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  80108d:	89 34 24             	mov    %esi,(%esp)
  801090:	e8 97 fd ff ff       	call   800e2c <fd2data>
  801095:	83 c4 10             	add    $0x10,%esp
  801098:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80109b:	89 d8                	mov    %ebx,%eax
  80109d:	c1 e8 16             	shr    $0x16,%eax
  8010a0:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8010a7:	a8 01                	test   $0x1,%al
  8010a9:	74 37                	je     8010e2 <dup+0x99>
  8010ab:	89 d8                	mov    %ebx,%eax
  8010ad:	c1 e8 0c             	shr    $0xc,%eax
  8010b0:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8010b7:	f6 c2 01             	test   $0x1,%dl
  8010ba:	74 26                	je     8010e2 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8010bc:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8010c3:	83 ec 0c             	sub    $0xc,%esp
  8010c6:	25 07 0e 00 00       	and    $0xe07,%eax
  8010cb:	50                   	push   %eax
  8010cc:	ff 75 d4             	pushl  -0x2c(%ebp)
  8010cf:	6a 00                	push   $0x0
  8010d1:	53                   	push   %ebx
  8010d2:	6a 00                	push   $0x0
  8010d4:	e8 ff fb ff ff       	call   800cd8 <sys_page_map>
  8010d9:	89 c3                	mov    %eax,%ebx
  8010db:	83 c4 20             	add    $0x20,%esp
  8010de:	85 c0                	test   %eax,%eax
  8010e0:	78 2d                	js     80110f <dup+0xc6>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8010e2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8010e5:	89 c2                	mov    %eax,%edx
  8010e7:	c1 ea 0c             	shr    $0xc,%edx
  8010ea:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8010f1:	83 ec 0c             	sub    $0xc,%esp
  8010f4:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  8010fa:	52                   	push   %edx
  8010fb:	56                   	push   %esi
  8010fc:	6a 00                	push   $0x0
  8010fe:	50                   	push   %eax
  8010ff:	6a 00                	push   $0x0
  801101:	e8 d2 fb ff ff       	call   800cd8 <sys_page_map>
  801106:	89 c3                	mov    %eax,%ebx
  801108:	83 c4 20             	add    $0x20,%esp
  80110b:	85 c0                	test   %eax,%eax
  80110d:	79 1d                	jns    80112c <dup+0xe3>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80110f:	83 ec 08             	sub    $0x8,%esp
  801112:	56                   	push   %esi
  801113:	6a 00                	push   $0x0
  801115:	e8 e4 fb ff ff       	call   800cfe <sys_page_unmap>
	sys_page_unmap(0, nva);
  80111a:	83 c4 08             	add    $0x8,%esp
  80111d:	ff 75 d4             	pushl  -0x2c(%ebp)
  801120:	6a 00                	push   $0x0
  801122:	e8 d7 fb ff ff       	call   800cfe <sys_page_unmap>
	return r;
  801127:	83 c4 10             	add    $0x10,%esp
  80112a:	eb 02                	jmp    80112e <dup+0xe5>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  80112c:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  80112e:	89 d8                	mov    %ebx,%eax
  801130:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801133:	5b                   	pop    %ebx
  801134:	5e                   	pop    %esi
  801135:	5f                   	pop    %edi
  801136:	c9                   	leave  
  801137:	c3                   	ret    

00801138 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801138:	55                   	push   %ebp
  801139:	89 e5                	mov    %esp,%ebp
  80113b:	53                   	push   %ebx
  80113c:	83 ec 14             	sub    $0x14,%esp
  80113f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801142:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801145:	50                   	push   %eax
  801146:	53                   	push   %ebx
  801147:	e8 6b fd ff ff       	call   800eb7 <fd_lookup>
  80114c:	83 c4 08             	add    $0x8,%esp
  80114f:	85 c0                	test   %eax,%eax
  801151:	78 67                	js     8011ba <read+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801153:	83 ec 08             	sub    $0x8,%esp
  801156:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801159:	50                   	push   %eax
  80115a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80115d:	ff 30                	pushl  (%eax)
  80115f:	e8 a9 fd ff ff       	call   800f0d <dev_lookup>
  801164:	83 c4 10             	add    $0x10,%esp
  801167:	85 c0                	test   %eax,%eax
  801169:	78 4f                	js     8011ba <read+0x82>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80116b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80116e:	8b 50 08             	mov    0x8(%eax),%edx
  801171:	83 e2 03             	and    $0x3,%edx
  801174:	83 fa 01             	cmp    $0x1,%edx
  801177:	75 21                	jne    80119a <read+0x62>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801179:	a1 04 40 80 00       	mov    0x804004,%eax
  80117e:	8b 40 48             	mov    0x48(%eax),%eax
  801181:	83 ec 04             	sub    $0x4,%esp
  801184:	53                   	push   %ebx
  801185:	50                   	push   %eax
  801186:	68 6d 2b 80 00       	push   $0x802b6d
  80118b:	e8 ec f0 ff ff       	call   80027c <cprintf>
		return -E_INVAL;
  801190:	83 c4 10             	add    $0x10,%esp
  801193:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801198:	eb 20                	jmp    8011ba <read+0x82>
	}
	if (!dev->dev_read)
  80119a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80119d:	8b 52 08             	mov    0x8(%edx),%edx
  8011a0:	85 d2                	test   %edx,%edx
  8011a2:	74 11                	je     8011b5 <read+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8011a4:	83 ec 04             	sub    $0x4,%esp
  8011a7:	ff 75 10             	pushl  0x10(%ebp)
  8011aa:	ff 75 0c             	pushl  0xc(%ebp)
  8011ad:	50                   	push   %eax
  8011ae:	ff d2                	call   *%edx
  8011b0:	83 c4 10             	add    $0x10,%esp
  8011b3:	eb 05                	jmp    8011ba <read+0x82>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8011b5:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  8011ba:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8011bd:	c9                   	leave  
  8011be:	c3                   	ret    

008011bf <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8011bf:	55                   	push   %ebp
  8011c0:	89 e5                	mov    %esp,%ebp
  8011c2:	57                   	push   %edi
  8011c3:	56                   	push   %esi
  8011c4:	53                   	push   %ebx
  8011c5:	83 ec 0c             	sub    $0xc,%esp
  8011c8:	8b 7d 08             	mov    0x8(%ebp),%edi
  8011cb:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8011ce:	85 f6                	test   %esi,%esi
  8011d0:	74 31                	je     801203 <readn+0x44>
  8011d2:	b8 00 00 00 00       	mov    $0x0,%eax
  8011d7:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = read(fdnum, (char*)buf + tot, n - tot);
  8011dc:	83 ec 04             	sub    $0x4,%esp
  8011df:	89 f2                	mov    %esi,%edx
  8011e1:	29 c2                	sub    %eax,%edx
  8011e3:	52                   	push   %edx
  8011e4:	03 45 0c             	add    0xc(%ebp),%eax
  8011e7:	50                   	push   %eax
  8011e8:	57                   	push   %edi
  8011e9:	e8 4a ff ff ff       	call   801138 <read>
		if (m < 0)
  8011ee:	83 c4 10             	add    $0x10,%esp
  8011f1:	85 c0                	test   %eax,%eax
  8011f3:	78 17                	js     80120c <readn+0x4d>
			return m;
		if (m == 0)
  8011f5:	85 c0                	test   %eax,%eax
  8011f7:	74 11                	je     80120a <readn+0x4b>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8011f9:	01 c3                	add    %eax,%ebx
  8011fb:	89 d8                	mov    %ebx,%eax
  8011fd:	39 f3                	cmp    %esi,%ebx
  8011ff:	72 db                	jb     8011dc <readn+0x1d>
  801201:	eb 09                	jmp    80120c <readn+0x4d>
  801203:	b8 00 00 00 00       	mov    $0x0,%eax
  801208:	eb 02                	jmp    80120c <readn+0x4d>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  80120a:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  80120c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80120f:	5b                   	pop    %ebx
  801210:	5e                   	pop    %esi
  801211:	5f                   	pop    %edi
  801212:	c9                   	leave  
  801213:	c3                   	ret    

00801214 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801214:	55                   	push   %ebp
  801215:	89 e5                	mov    %esp,%ebp
  801217:	53                   	push   %ebx
  801218:	83 ec 14             	sub    $0x14,%esp
  80121b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80121e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801221:	50                   	push   %eax
  801222:	53                   	push   %ebx
  801223:	e8 8f fc ff ff       	call   800eb7 <fd_lookup>
  801228:	83 c4 08             	add    $0x8,%esp
  80122b:	85 c0                	test   %eax,%eax
  80122d:	78 62                	js     801291 <write+0x7d>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80122f:	83 ec 08             	sub    $0x8,%esp
  801232:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801235:	50                   	push   %eax
  801236:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801239:	ff 30                	pushl  (%eax)
  80123b:	e8 cd fc ff ff       	call   800f0d <dev_lookup>
  801240:	83 c4 10             	add    $0x10,%esp
  801243:	85 c0                	test   %eax,%eax
  801245:	78 4a                	js     801291 <write+0x7d>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801247:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80124a:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80124e:	75 21                	jne    801271 <write+0x5d>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801250:	a1 04 40 80 00       	mov    0x804004,%eax
  801255:	8b 40 48             	mov    0x48(%eax),%eax
  801258:	83 ec 04             	sub    $0x4,%esp
  80125b:	53                   	push   %ebx
  80125c:	50                   	push   %eax
  80125d:	68 89 2b 80 00       	push   $0x802b89
  801262:	e8 15 f0 ff ff       	call   80027c <cprintf>
		return -E_INVAL;
  801267:	83 c4 10             	add    $0x10,%esp
  80126a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80126f:	eb 20                	jmp    801291 <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801271:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801274:	8b 52 0c             	mov    0xc(%edx),%edx
  801277:	85 d2                	test   %edx,%edx
  801279:	74 11                	je     80128c <write+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80127b:	83 ec 04             	sub    $0x4,%esp
  80127e:	ff 75 10             	pushl  0x10(%ebp)
  801281:	ff 75 0c             	pushl  0xc(%ebp)
  801284:	50                   	push   %eax
  801285:	ff d2                	call   *%edx
  801287:	83 c4 10             	add    $0x10,%esp
  80128a:	eb 05                	jmp    801291 <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80128c:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  801291:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801294:	c9                   	leave  
  801295:	c3                   	ret    

00801296 <seek>:

int
seek(int fdnum, off_t offset)
{
  801296:	55                   	push   %ebp
  801297:	89 e5                	mov    %esp,%ebp
  801299:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80129c:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80129f:	50                   	push   %eax
  8012a0:	ff 75 08             	pushl  0x8(%ebp)
  8012a3:	e8 0f fc ff ff       	call   800eb7 <fd_lookup>
  8012a8:	83 c4 08             	add    $0x8,%esp
  8012ab:	85 c0                	test   %eax,%eax
  8012ad:	78 0e                	js     8012bd <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8012af:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8012b2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8012b5:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8012b8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8012bd:	c9                   	leave  
  8012be:	c3                   	ret    

008012bf <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8012bf:	55                   	push   %ebp
  8012c0:	89 e5                	mov    %esp,%ebp
  8012c2:	53                   	push   %ebx
  8012c3:	83 ec 14             	sub    $0x14,%esp
  8012c6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8012c9:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012cc:	50                   	push   %eax
  8012cd:	53                   	push   %ebx
  8012ce:	e8 e4 fb ff ff       	call   800eb7 <fd_lookup>
  8012d3:	83 c4 08             	add    $0x8,%esp
  8012d6:	85 c0                	test   %eax,%eax
  8012d8:	78 5f                	js     801339 <ftruncate+0x7a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012da:	83 ec 08             	sub    $0x8,%esp
  8012dd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012e0:	50                   	push   %eax
  8012e1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012e4:	ff 30                	pushl  (%eax)
  8012e6:	e8 22 fc ff ff       	call   800f0d <dev_lookup>
  8012eb:	83 c4 10             	add    $0x10,%esp
  8012ee:	85 c0                	test   %eax,%eax
  8012f0:	78 47                	js     801339 <ftruncate+0x7a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8012f2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012f5:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8012f9:	75 21                	jne    80131c <ftruncate+0x5d>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8012fb:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801300:	8b 40 48             	mov    0x48(%eax),%eax
  801303:	83 ec 04             	sub    $0x4,%esp
  801306:	53                   	push   %ebx
  801307:	50                   	push   %eax
  801308:	68 4c 2b 80 00       	push   $0x802b4c
  80130d:	e8 6a ef ff ff       	call   80027c <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801312:	83 c4 10             	add    $0x10,%esp
  801315:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80131a:	eb 1d                	jmp    801339 <ftruncate+0x7a>
	}
	if (!dev->dev_trunc)
  80131c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80131f:	8b 52 18             	mov    0x18(%edx),%edx
  801322:	85 d2                	test   %edx,%edx
  801324:	74 0e                	je     801334 <ftruncate+0x75>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801326:	83 ec 08             	sub    $0x8,%esp
  801329:	ff 75 0c             	pushl  0xc(%ebp)
  80132c:	50                   	push   %eax
  80132d:	ff d2                	call   *%edx
  80132f:	83 c4 10             	add    $0x10,%esp
  801332:	eb 05                	jmp    801339 <ftruncate+0x7a>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801334:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  801339:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80133c:	c9                   	leave  
  80133d:	c3                   	ret    

0080133e <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80133e:	55                   	push   %ebp
  80133f:	89 e5                	mov    %esp,%ebp
  801341:	53                   	push   %ebx
  801342:	83 ec 14             	sub    $0x14,%esp
  801345:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801348:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80134b:	50                   	push   %eax
  80134c:	ff 75 08             	pushl  0x8(%ebp)
  80134f:	e8 63 fb ff ff       	call   800eb7 <fd_lookup>
  801354:	83 c4 08             	add    $0x8,%esp
  801357:	85 c0                	test   %eax,%eax
  801359:	78 52                	js     8013ad <fstat+0x6f>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80135b:	83 ec 08             	sub    $0x8,%esp
  80135e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801361:	50                   	push   %eax
  801362:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801365:	ff 30                	pushl  (%eax)
  801367:	e8 a1 fb ff ff       	call   800f0d <dev_lookup>
  80136c:	83 c4 10             	add    $0x10,%esp
  80136f:	85 c0                	test   %eax,%eax
  801371:	78 3a                	js     8013ad <fstat+0x6f>
		return r;
	if (!dev->dev_stat)
  801373:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801376:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80137a:	74 2c                	je     8013a8 <fstat+0x6a>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80137c:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80137f:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801386:	00 00 00 
	stat->st_isdir = 0;
  801389:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801390:	00 00 00 
	stat->st_dev = dev;
  801393:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801399:	83 ec 08             	sub    $0x8,%esp
  80139c:	53                   	push   %ebx
  80139d:	ff 75 f0             	pushl  -0x10(%ebp)
  8013a0:	ff 50 14             	call   *0x14(%eax)
  8013a3:	83 c4 10             	add    $0x10,%esp
  8013a6:	eb 05                	jmp    8013ad <fstat+0x6f>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8013a8:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8013ad:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013b0:	c9                   	leave  
  8013b1:	c3                   	ret    

008013b2 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8013b2:	55                   	push   %ebp
  8013b3:	89 e5                	mov    %esp,%ebp
  8013b5:	56                   	push   %esi
  8013b6:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8013b7:	83 ec 08             	sub    $0x8,%esp
  8013ba:	6a 00                	push   $0x0
  8013bc:	ff 75 08             	pushl  0x8(%ebp)
  8013bf:	e8 78 01 00 00       	call   80153c <open>
  8013c4:	89 c3                	mov    %eax,%ebx
  8013c6:	83 c4 10             	add    $0x10,%esp
  8013c9:	85 c0                	test   %eax,%eax
  8013cb:	78 1b                	js     8013e8 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8013cd:	83 ec 08             	sub    $0x8,%esp
  8013d0:	ff 75 0c             	pushl  0xc(%ebp)
  8013d3:	50                   	push   %eax
  8013d4:	e8 65 ff ff ff       	call   80133e <fstat>
  8013d9:	89 c6                	mov    %eax,%esi
	close(fd);
  8013db:	89 1c 24             	mov    %ebx,(%esp)
  8013de:	e8 18 fc ff ff       	call   800ffb <close>
	return r;
  8013e3:	83 c4 10             	add    $0x10,%esp
  8013e6:	89 f3                	mov    %esi,%ebx
}
  8013e8:	89 d8                	mov    %ebx,%eax
  8013ea:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8013ed:	5b                   	pop    %ebx
  8013ee:	5e                   	pop    %esi
  8013ef:	c9                   	leave  
  8013f0:	c3                   	ret    
  8013f1:	00 00                	add    %al,(%eax)
	...

008013f4 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8013f4:	55                   	push   %ebp
  8013f5:	89 e5                	mov    %esp,%ebp
  8013f7:	56                   	push   %esi
  8013f8:	53                   	push   %ebx
  8013f9:	89 c3                	mov    %eax,%ebx
  8013fb:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  8013fd:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801404:	75 12                	jne    801418 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801406:	83 ec 0c             	sub    $0xc,%esp
  801409:	6a 01                	push   $0x1
  80140b:	e8 ee 0f 00 00       	call   8023fe <ipc_find_env>
  801410:	a3 00 40 80 00       	mov    %eax,0x804000
  801415:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801418:	6a 07                	push   $0x7
  80141a:	68 00 50 80 00       	push   $0x805000
  80141f:	53                   	push   %ebx
  801420:	ff 35 00 40 80 00    	pushl  0x804000
  801426:	e8 7e 0f 00 00       	call   8023a9 <ipc_send>
	
	return ipc_recv(NULL, dstva, NULL);
  80142b:	83 c4 0c             	add    $0xc,%esp
  80142e:	6a 00                	push   $0x0
  801430:	56                   	push   %esi
  801431:	6a 00                	push   $0x0
  801433:	e8 fc 0e 00 00       	call   802334 <ipc_recv>
}
  801438:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80143b:	5b                   	pop    %ebx
  80143c:	5e                   	pop    %esi
  80143d:	c9                   	leave  
  80143e:	c3                   	ret    

0080143f <devfile_stat>:
}


static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80143f:	55                   	push   %ebp
  801440:	89 e5                	mov    %esp,%ebp
  801442:	53                   	push   %ebx
  801443:	83 ec 04             	sub    $0x4,%esp
  801446:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801449:	8b 45 08             	mov    0x8(%ebp),%eax
  80144c:	8b 40 0c             	mov    0xc(%eax),%eax
  80144f:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0) {
  801454:	ba 00 00 00 00       	mov    $0x0,%edx
  801459:	b8 05 00 00 00       	mov    $0x5,%eax
  80145e:	e8 91 ff ff ff       	call   8013f4 <fsipc>
  801463:	85 c0                	test   %eax,%eax
  801465:	78 2c                	js     801493 <devfile_stat+0x54>
		return r;
	}
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801467:	83 ec 08             	sub    $0x8,%esp
  80146a:	68 00 50 80 00       	push   $0x805000
  80146f:	53                   	push   %ebx
  801470:	e8 bd f3 ff ff       	call   800832 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801475:	a1 80 50 80 00       	mov    0x805080,%eax
  80147a:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801480:	a1 84 50 80 00       	mov    0x805084,%eax
  801485:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80148b:	83 c4 10             	add    $0x10,%esp
  80148e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801493:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801496:	c9                   	leave  
  801497:	c3                   	ret    

00801498 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801498:	55                   	push   %ebp
  801499:	89 e5                	mov    %esp,%ebp
  80149b:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80149e:	8b 45 08             	mov    0x8(%ebp),%eax
  8014a1:	8b 40 0c             	mov    0xc(%eax),%eax
  8014a4:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8014a9:	ba 00 00 00 00       	mov    $0x0,%edx
  8014ae:	b8 06 00 00 00       	mov    $0x6,%eax
  8014b3:	e8 3c ff ff ff       	call   8013f4 <fsipc>
}
  8014b8:	c9                   	leave  
  8014b9:	c3                   	ret    

008014ba <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8014ba:	55                   	push   %ebp
  8014bb:	89 e5                	mov    %esp,%ebp
  8014bd:	56                   	push   %esi
  8014be:	53                   	push   %ebx
  8014bf:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8014c2:	8b 45 08             	mov    0x8(%ebp),%eax
  8014c5:	8b 40 0c             	mov    0xc(%eax),%eax
  8014c8:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8014cd:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8014d3:	ba 00 00 00 00       	mov    $0x0,%edx
  8014d8:	b8 03 00 00 00       	mov    $0x3,%eax
  8014dd:	e8 12 ff ff ff       	call   8013f4 <fsipc>
  8014e2:	89 c3                	mov    %eax,%ebx
  8014e4:	85 c0                	test   %eax,%eax
  8014e6:	78 4b                	js     801533 <devfile_read+0x79>
		return r;
	assert(r <= n);
  8014e8:	39 c6                	cmp    %eax,%esi
  8014ea:	73 16                	jae    801502 <devfile_read+0x48>
  8014ec:	68 b8 2b 80 00       	push   $0x802bb8
  8014f1:	68 bf 2b 80 00       	push   $0x802bbf
  8014f6:	6a 7d                	push   $0x7d
  8014f8:	68 d4 2b 80 00       	push   $0x802bd4
  8014fd:	e8 a2 ec ff ff       	call   8001a4 <_panic>
	assert(r <= PGSIZE);
  801502:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801507:	7e 16                	jle    80151f <devfile_read+0x65>
  801509:	68 df 2b 80 00       	push   $0x802bdf
  80150e:	68 bf 2b 80 00       	push   $0x802bbf
  801513:	6a 7e                	push   $0x7e
  801515:	68 d4 2b 80 00       	push   $0x802bd4
  80151a:	e8 85 ec ff ff       	call   8001a4 <_panic>
	memmove(buf, &fsipcbuf, r);
  80151f:	83 ec 04             	sub    $0x4,%esp
  801522:	50                   	push   %eax
  801523:	68 00 50 80 00       	push   $0x805000
  801528:	ff 75 0c             	pushl  0xc(%ebp)
  80152b:	e8 c3 f4 ff ff       	call   8009f3 <memmove>
	return r;
  801530:	83 c4 10             	add    $0x10,%esp
}
  801533:	89 d8                	mov    %ebx,%eax
  801535:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801538:	5b                   	pop    %ebx
  801539:	5e                   	pop    %esi
  80153a:	c9                   	leave  
  80153b:	c3                   	ret    

0080153c <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  80153c:	55                   	push   %ebp
  80153d:	89 e5                	mov    %esp,%ebp
  80153f:	56                   	push   %esi
  801540:	53                   	push   %ebx
  801541:	83 ec 1c             	sub    $0x1c,%esp
  801544:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801547:	56                   	push   %esi
  801548:	e8 93 f2 ff ff       	call   8007e0 <strlen>
  80154d:	83 c4 10             	add    $0x10,%esp
  801550:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801555:	7f 65                	jg     8015bc <open+0x80>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801557:	83 ec 0c             	sub    $0xc,%esp
  80155a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80155d:	50                   	push   %eax
  80155e:	e8 e1 f8 ff ff       	call   800e44 <fd_alloc>
  801563:	89 c3                	mov    %eax,%ebx
  801565:	83 c4 10             	add    $0x10,%esp
  801568:	85 c0                	test   %eax,%eax
  80156a:	78 55                	js     8015c1 <open+0x85>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  80156c:	83 ec 08             	sub    $0x8,%esp
  80156f:	56                   	push   %esi
  801570:	68 00 50 80 00       	push   $0x805000
  801575:	e8 b8 f2 ff ff       	call   800832 <strcpy>
	fsipcbuf.open.req_omode = mode;
  80157a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80157d:	a3 00 54 80 00       	mov    %eax,0x805400



	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801582:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801585:	b8 01 00 00 00       	mov    $0x1,%eax
  80158a:	e8 65 fe ff ff       	call   8013f4 <fsipc>
  80158f:	89 c3                	mov    %eax,%ebx
  801591:	83 c4 10             	add    $0x10,%esp
  801594:	85 c0                	test   %eax,%eax
  801596:	79 12                	jns    8015aa <open+0x6e>
		fd_close(fd, 0);
  801598:	83 ec 08             	sub    $0x8,%esp
  80159b:	6a 00                	push   $0x0
  80159d:	ff 75 f4             	pushl  -0xc(%ebp)
  8015a0:	e8 ce f9 ff ff       	call   800f73 <fd_close>
		return r;
  8015a5:	83 c4 10             	add    $0x10,%esp
  8015a8:	eb 17                	jmp    8015c1 <open+0x85>
	}

	return fd2num(fd);
  8015aa:	83 ec 0c             	sub    $0xc,%esp
  8015ad:	ff 75 f4             	pushl  -0xc(%ebp)
  8015b0:	e8 67 f8 ff ff       	call   800e1c <fd2num>
  8015b5:	89 c3                	mov    %eax,%ebx
  8015b7:	83 c4 10             	add    $0x10,%esp
  8015ba:	eb 05                	jmp    8015c1 <open+0x85>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8015bc:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8015c1:	89 d8                	mov    %ebx,%eax
  8015c3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8015c6:	5b                   	pop    %ebx
  8015c7:	5e                   	pop    %esi
  8015c8:	c9                   	leave  
  8015c9:	c3                   	ret    
	...

008015cc <map_segment>:
}

static int
map_segment(envid_t child, uintptr_t va, size_t memsz,
	int fd, size_t filesz, off_t fileoffset, int perm)
{
  8015cc:	55                   	push   %ebp
  8015cd:	89 e5                	mov    %esp,%ebp
  8015cf:	57                   	push   %edi
  8015d0:	56                   	push   %esi
  8015d1:	53                   	push   %ebx
  8015d2:	83 ec 1c             	sub    $0x1c,%esp
  8015d5:	89 c7                	mov    %eax,%edi
  8015d7:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8015da:	89 4d e0             	mov    %ecx,-0x20(%ebp)
	int i, r;
	void *blk;

	//cprintf("map_segment %x+%x\n", va, memsz);

	if ((i = PGOFF(va))) {
  8015dd:	89 d0                	mov    %edx,%eax
  8015df:	25 ff 0f 00 00       	and    $0xfff,%eax
  8015e4:	74 0c                	je     8015f2 <map_segment+0x26>
		va -= i;
  8015e6:	29 45 e4             	sub    %eax,-0x1c(%ebp)
		memsz += i;
  8015e9:	01 45 e0             	add    %eax,-0x20(%ebp)
		filesz += i;
  8015ec:	01 45 0c             	add    %eax,0xc(%ebp)
		fileoffset -= i;
  8015ef:	29 45 10             	sub    %eax,0x10(%ebp)
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  8015f2:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8015f6:	0f 84 ee 00 00 00    	je     8016ea <map_segment+0x11e>
  8015fc:	be 00 00 00 00       	mov    $0x0,%esi
  801601:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (i >= filesz) {
  801606:	39 75 0c             	cmp    %esi,0xc(%ebp)
  801609:	77 20                	ja     80162b <map_segment+0x5f>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
  80160b:	83 ec 04             	sub    $0x4,%esp
  80160e:	ff 75 14             	pushl  0x14(%ebp)
  801611:	03 75 e4             	add    -0x1c(%ebp),%esi
  801614:	56                   	push   %esi
  801615:	57                   	push   %edi
  801616:	e8 99 f6 ff ff       	call   800cb4 <sys_page_alloc>
  80161b:	83 c4 10             	add    $0x10,%esp
  80161e:	85 c0                	test   %eax,%eax
  801620:	0f 89 ac 00 00 00    	jns    8016d2 <map_segment+0x106>
  801626:	e9 c4 00 00 00       	jmp    8016ef <map_segment+0x123>
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  80162b:	83 ec 04             	sub    $0x4,%esp
  80162e:	6a 07                	push   $0x7
  801630:	68 00 00 40 00       	push   $0x400000
  801635:	6a 00                	push   $0x0
  801637:	e8 78 f6 ff ff       	call   800cb4 <sys_page_alloc>
  80163c:	83 c4 10             	add    $0x10,%esp
  80163f:	85 c0                	test   %eax,%eax
  801641:	0f 88 a8 00 00 00    	js     8016ef <map_segment+0x123>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  801647:	83 ec 08             	sub    $0x8,%esp
	sys_page_unmap(0, UTEMP);
	return r;
}

static int
map_segment(envid_t child, uintptr_t va, size_t memsz,
  80164a:	8b 45 10             	mov    0x10(%ebp),%eax
  80164d:	8d 04 03             	lea    (%ebx,%eax,1),%eax
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  801650:	50                   	push   %eax
  801651:	ff 75 08             	pushl  0x8(%ebp)
  801654:	e8 3d fc ff ff       	call   801296 <seek>
  801659:	83 c4 10             	add    $0x10,%esp
  80165c:	85 c0                	test   %eax,%eax
  80165e:	0f 88 8b 00 00 00    	js     8016ef <map_segment+0x123>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  801664:	83 ec 04             	sub    $0x4,%esp
  801667:	8b 45 0c             	mov    0xc(%ebp),%eax
  80166a:	29 f0                	sub    %esi,%eax
  80166c:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801671:	76 05                	jbe    801678 <map_segment+0xac>
  801673:	b8 00 10 00 00       	mov    $0x1000,%eax
  801678:	50                   	push   %eax
  801679:	68 00 00 40 00       	push   $0x400000
  80167e:	ff 75 08             	pushl  0x8(%ebp)
  801681:	e8 39 fb ff ff       	call   8011bf <readn>
  801686:	83 c4 10             	add    $0x10,%esp
  801689:	85 c0                	test   %eax,%eax
  80168b:	78 62                	js     8016ef <map_segment+0x123>
				return r;
			if ((r = sys_page_map(0, UTEMP, child, (void*) (va + i), perm)) < 0)
  80168d:	83 ec 0c             	sub    $0xc,%esp
  801690:	ff 75 14             	pushl  0x14(%ebp)
  801693:	03 75 e4             	add    -0x1c(%ebp),%esi
  801696:	56                   	push   %esi
  801697:	57                   	push   %edi
  801698:	68 00 00 40 00       	push   $0x400000
  80169d:	6a 00                	push   $0x0
  80169f:	e8 34 f6 ff ff       	call   800cd8 <sys_page_map>
  8016a4:	83 c4 20             	add    $0x20,%esp
  8016a7:	85 c0                	test   %eax,%eax
  8016a9:	79 15                	jns    8016c0 <map_segment+0xf4>
				panic("spawn: sys_page_map data: %e", r);
  8016ab:	50                   	push   %eax
  8016ac:	68 eb 2b 80 00       	push   $0x802beb
  8016b1:	68 84 01 00 00       	push   $0x184
  8016b6:	68 08 2c 80 00       	push   $0x802c08
  8016bb:	e8 e4 ea ff ff       	call   8001a4 <_panic>
			sys_page_unmap(0, UTEMP);
  8016c0:	83 ec 08             	sub    $0x8,%esp
  8016c3:	68 00 00 40 00       	push   $0x400000
  8016c8:	6a 00                	push   $0x0
  8016ca:	e8 2f f6 ff ff       	call   800cfe <sys_page_unmap>
  8016cf:	83 c4 10             	add    $0x10,%esp
		memsz += i;
		filesz += i;
		fileoffset -= i;
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  8016d2:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  8016d8:	89 de                	mov    %ebx,%esi
  8016da:	39 5d e0             	cmp    %ebx,-0x20(%ebp)
  8016dd:	0f 87 23 ff ff ff    	ja     801606 <map_segment+0x3a>
			if ((r = sys_page_map(0, UTEMP, child, (void*) (va + i), perm)) < 0)
				panic("spawn: sys_page_map data: %e", r);
			sys_page_unmap(0, UTEMP);
		}
	}
	return 0;
  8016e3:	b8 00 00 00 00       	mov    $0x0,%eax
  8016e8:	eb 05                	jmp    8016ef <map_segment+0x123>
  8016ea:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8016ef:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8016f2:	5b                   	pop    %ebx
  8016f3:	5e                   	pop    %esi
  8016f4:	5f                   	pop    %edi
  8016f5:	c9                   	leave  
  8016f6:	c3                   	ret    

008016f7 <init_stack>:
// On success, returns 0 and sets *init_esp
// to the initial stack pointer with which the child should start.
// Returns < 0 on failure.
static int
init_stack(envid_t child, const char **argv, uintptr_t *init_esp, uint32_t stack_addr)
{
  8016f7:	55                   	push   %ebp
  8016f8:	89 e5                	mov    %esp,%ebp
  8016fa:	57                   	push   %edi
  8016fb:	56                   	push   %esi
  8016fc:	53                   	push   %ebx
  8016fd:	83 ec 2c             	sub    $0x2c,%esp
  801700:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801703:	89 d7                	mov    %edx,%edi
  801705:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  801708:	8b 02                	mov    (%edx),%eax
  80170a:	85 c0                	test   %eax,%eax
  80170c:	74 31                	je     80173f <init_stack+0x48>
  80170e:	bb 00 00 00 00       	mov    $0x0,%ebx
	char *string_store;
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
  801713:	be 00 00 00 00       	mov    $0x0,%esi
	for (argc = 0; argv[argc] != 0; argc++)
		string_size += strlen(argv[argc]) + 1;
  801718:	83 ec 0c             	sub    $0xc,%esp
  80171b:	50                   	push   %eax
  80171c:	e8 bf f0 ff ff       	call   8007e0 <strlen>
  801721:	8d 74 30 01          	lea    0x1(%eax,%esi,1),%esi
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  801725:	43                   	inc    %ebx
  801726:	8d 0c 9d 00 00 00 00 	lea    0x0(,%ebx,4),%ecx
  80172d:	8b 04 9f             	mov    (%edi,%ebx,4),%eax
  801730:	83 c4 10             	add    $0x10,%esp
  801733:	85 c0                	test   %eax,%eax
  801735:	75 e1                	jne    801718 <init_stack+0x21>
  801737:	89 5d d0             	mov    %ebx,-0x30(%ebp)
  80173a:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  80173d:	eb 18                	jmp    801757 <init_stack+0x60>
  80173f:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
  801746:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
  80174d:	bb 00 00 00 00       	mov    $0x0,%ebx
	char *string_store;
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
  801752:	be 00 00 00 00       	mov    $0x0,%esi
	// Determine where to place the strings and the argv array.
	// Set up pointers into the temporary page 'UTEMP'; we'll map a page
	// there later, then remap that page into the child environment
	// at (USTACKTOP - PGSIZE).
	// strings is the topmost thing on the stack.
	string_store = (char*) UTEMP + PGSIZE - string_size;
  801757:	f7 de                	neg    %esi
  801759:	81 c6 00 10 40 00    	add    $0x401000,%esi
  80175f:	89 75 dc             	mov    %esi,-0x24(%ebp)
	// argv is below that.  There's one argument pointer per argument, plus
	// a null pointer.
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));
  801762:	89 f2                	mov    %esi,%edx
  801764:	83 e2 fc             	and    $0xfffffffc,%edx
  801767:	89 d8                	mov    %ebx,%eax
  801769:	f7 d0                	not    %eax
  80176b:	8d 04 82             	lea    (%edx,%eax,4),%eax
  80176e:	89 45 e4             	mov    %eax,-0x1c(%ebp)

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
  801771:	83 e8 08             	sub    $0x8,%eax
  801774:	3d ff ff 3f 00       	cmp    $0x3fffff,%eax
  801779:	0f 86 fb 00 00 00    	jbe    80187a <init_stack+0x183>
		return -E_NO_MEM;

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  80177f:	83 ec 04             	sub    $0x4,%esp
  801782:	6a 07                	push   $0x7
  801784:	68 00 00 40 00       	push   $0x400000
  801789:	6a 00                	push   $0x0
  80178b:	e8 24 f5 ff ff       	call   800cb4 <sys_page_alloc>
  801790:	89 c6                	mov    %eax,%esi
  801792:	83 c4 10             	add    $0x10,%esp
  801795:	85 c0                	test   %eax,%eax
  801797:	0f 88 e9 00 00 00    	js     801886 <init_stack+0x18f>
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  80179d:	85 db                	test   %ebx,%ebx
  80179f:	7e 3e                	jle    8017df <init_stack+0xe8>
  8017a1:	be 00 00 00 00       	mov    $0x0,%esi
  8017a6:	89 5d e0             	mov    %ebx,-0x20(%ebp)
  8017a9:	8b 5d dc             	mov    -0x24(%ebp),%ebx
		argv_store[i] = UTEMP2USTACK(string_store);
  8017ac:	8d 83 00 d0 7f ee    	lea    -0x11803000(%ebx),%eax
  8017b2:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8017b5:	89 04 b2             	mov    %eax,(%edx,%esi,4)
		strcpy(string_store, argv[i]);
  8017b8:	83 ec 08             	sub    $0x8,%esp
  8017bb:	ff 34 b7             	pushl  (%edi,%esi,4)
  8017be:	53                   	push   %ebx
  8017bf:	e8 6e f0 ff ff       	call   800832 <strcpy>
		string_store += strlen(argv[i]) + 1;
  8017c4:	83 c4 04             	add    $0x4,%esp
  8017c7:	ff 34 b7             	pushl  (%edi,%esi,4)
  8017ca:	e8 11 f0 ff ff       	call   8007e0 <strlen>
  8017cf:	8d 5c 03 01          	lea    0x1(%ebx,%eax,1),%ebx
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  8017d3:	46                   	inc    %esi
  8017d4:	83 c4 10             	add    $0x10,%esp
  8017d7:	3b 75 e0             	cmp    -0x20(%ebp),%esi
  8017da:	7c d0                	jl     8017ac <init_stack+0xb5>
  8017dc:	89 5d dc             	mov    %ebx,-0x24(%ebp)
		argv_store[i] = UTEMP2USTACK(string_store);
		strcpy(string_store, argv[i]);
		string_store += strlen(argv[i]) + 1;
	}
	argv_store[argc] = 0;
  8017df:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8017e2:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8017e5:	c7 04 02 00 00 00 00 	movl   $0x0,(%edx,%eax,1)
	assert(string_store == (char*)UTEMP + PGSIZE);
  8017ec:	81 7d dc 00 10 40 00 	cmpl   $0x401000,-0x24(%ebp)
  8017f3:	74 19                	je     80180e <init_stack+0x117>
  8017f5:	68 78 2c 80 00       	push   $0x802c78
  8017fa:	68 bf 2b 80 00       	push   $0x802bbf
  8017ff:	68 51 01 00 00       	push   $0x151
  801804:	68 08 2c 80 00       	push   $0x802c08
  801809:	e8 96 e9 ff ff       	call   8001a4 <_panic>

	argv_store[-1] = UTEMP2USTACK(argv_store);
  80180e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801811:	2d 00 30 80 11       	sub    $0x11803000,%eax
  801816:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801819:	89 42 fc             	mov    %eax,-0x4(%edx)
	argv_store[-2] = argc;
  80181c:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80181f:	89 42 f8             	mov    %eax,-0x8(%edx)

	*init_esp = UTEMP2USTACK(&argv_store[-2]);
  801822:	89 d0                	mov    %edx,%eax
  801824:	2d 08 30 80 11       	sub    $0x11803008,%eax
  801829:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  80182c:	89 02                	mov    %eax,(%edx)

	// After completing the stack, map it into the child's address space
	// and unmap it from ours!
	
	if ((r = sys_page_map(0, UTEMP, child, (void*) stack_addr, PTE_P | PTE_U | PTE_W)) < 0)
  80182e:	83 ec 0c             	sub    $0xc,%esp
  801831:	6a 07                	push   $0x7
  801833:	ff 75 08             	pushl  0x8(%ebp)
  801836:	ff 75 d8             	pushl  -0x28(%ebp)
  801839:	68 00 00 40 00       	push   $0x400000
  80183e:	6a 00                	push   $0x0
  801840:	e8 93 f4 ff ff       	call   800cd8 <sys_page_map>
  801845:	89 c6                	mov    %eax,%esi
  801847:	83 c4 20             	add    $0x20,%esp
  80184a:	85 c0                	test   %eax,%eax
  80184c:	78 18                	js     801866 <init_stack+0x16f>
		goto error;
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  80184e:	83 ec 08             	sub    $0x8,%esp
  801851:	68 00 00 40 00       	push   $0x400000
  801856:	6a 00                	push   $0x0
  801858:	e8 a1 f4 ff ff       	call   800cfe <sys_page_unmap>
  80185d:	89 c6                	mov    %eax,%esi
  80185f:	83 c4 10             	add    $0x10,%esp
  801862:	85 c0                	test   %eax,%eax
  801864:	79 1b                	jns    801881 <init_stack+0x18a>
		goto error;
	return 0;

error:
	sys_page_unmap(0, UTEMP);
  801866:	83 ec 08             	sub    $0x8,%esp
  801869:	68 00 00 40 00       	push   $0x400000
  80186e:	6a 00                	push   $0x0
  801870:	e8 89 f4 ff ff       	call   800cfe <sys_page_unmap>
	return r;
  801875:	83 c4 10             	add    $0x10,%esp
  801878:	eb 0c                	jmp    801886 <init_stack+0x18f>
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
		return -E_NO_MEM;
  80187a:	be fc ff ff ff       	mov    $0xfffffffc,%esi
  80187f:	eb 05                	jmp    801886 <init_stack+0x18f>
	
	if ((r = sys_page_map(0, UTEMP, child, (void*) stack_addr, PTE_P | PTE_U | PTE_W)) < 0)
		goto error;
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
		goto error;
	return 0;
  801881:	be 00 00 00 00       	mov    $0x0,%esi

error:
	sys_page_unmap(0, UTEMP);
	return r;
}
  801886:	89 f0                	mov    %esi,%eax
  801888:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80188b:	5b                   	pop    %ebx
  80188c:	5e                   	pop    %esi
  80188d:	5f                   	pop    %edi
  80188e:	c9                   	leave  
  80188f:	c3                   	ret    

00801890 <spawn>:
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
{
  801890:	55                   	push   %ebp
  801891:	89 e5                	mov    %esp,%ebp
  801893:	57                   	push   %edi
  801894:	56                   	push   %esi
  801895:	53                   	push   %ebx
  801896:	81 ec 74 02 00 00    	sub    $0x274,%esp
	//   - Call sys_env_set_trapframe(child, &child_tf) to set up the
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
  80189c:	6a 00                	push   $0x0
  80189e:	ff 75 08             	pushl  0x8(%ebp)
  8018a1:	e8 96 fc ff ff       	call   80153c <open>
  8018a6:	89 85 90 fd ff ff    	mov    %eax,-0x270(%ebp)
  8018ac:	83 c4 10             	add    $0x10,%esp
  8018af:	85 c0                	test   %eax,%eax
  8018b1:	0f 88 45 02 00 00    	js     801afc <spawn+0x26c>
		return r;
	fd = r;

	// Read elf header
	elf = (struct Elf*) elf_buf;
	if (readn(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf)
  8018b7:	83 ec 04             	sub    $0x4,%esp
  8018ba:	68 00 02 00 00       	push   $0x200
  8018bf:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  8018c5:	50                   	push   %eax
  8018c6:	ff b5 90 fd ff ff    	pushl  -0x270(%ebp)
  8018cc:	e8 ee f8 ff ff       	call   8011bf <readn>
  8018d1:	83 c4 10             	add    $0x10,%esp
  8018d4:	3d 00 02 00 00       	cmp    $0x200,%eax
  8018d9:	75 0c                	jne    8018e7 <spawn+0x57>
	    || elf->e_magic != ELF_MAGIC) {
  8018db:	81 bd e8 fd ff ff 7f 	cmpl   $0x464c457f,-0x218(%ebp)
  8018e2:	45 4c 46 
  8018e5:	74 38                	je     80191f <spawn+0x8f>
		close(fd);
  8018e7:	83 ec 0c             	sub    $0xc,%esp
  8018ea:	ff b5 90 fd ff ff    	pushl  -0x270(%ebp)
  8018f0:	e8 06 f7 ff ff       	call   800ffb <close>
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
  8018f5:	83 c4 0c             	add    $0xc,%esp
  8018f8:	68 7f 45 4c 46       	push   $0x464c457f
  8018fd:	ff b5 e8 fd ff ff    	pushl  -0x218(%ebp)
  801903:	68 14 2c 80 00       	push   $0x802c14
  801908:	e8 6f e9 ff ff       	call   80027c <cprintf>
		return -E_NOT_EXEC;
  80190d:	83 c4 10             	add    $0x10,%esp
  801910:	c7 85 94 fd ff ff f2 	movl   $0xfffffff2,-0x26c(%ebp)
  801917:	ff ff ff 
  80191a:	e9 f1 01 00 00       	jmp    801b10 <spawn+0x280>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  80191f:	ba 07 00 00 00       	mov    $0x7,%edx
  801924:	89 d0                	mov    %edx,%eax
  801926:	cd 30                	int    $0x30
  801928:	89 85 8c fd ff ff    	mov    %eax,-0x274(%ebp)
  80192e:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)
	}


	// Create new child environment
	if ((r = sys_exofork()) < 0)
  801934:	85 c0                	test   %eax,%eax
  801936:	0f 88 d4 01 00 00    	js     801b10 <spawn+0x280>
		return r;
	child = r;

	// Set up trap frame, including initial stack.
	child_tf = envs[ENVX(child)].env_tf;
  80193c:	25 ff 03 00 00       	and    $0x3ff,%eax
  801941:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  801948:	c1 e0 07             	shl    $0x7,%eax
  80194b:	29 d0                	sub    %edx,%eax
  80194d:	8d b0 00 00 c0 ee    	lea    -0x11400000(%eax),%esi
  801953:	8d bd a4 fd ff ff    	lea    -0x25c(%ebp),%edi
  801959:	b9 11 00 00 00       	mov    $0x11,%ecx
  80195e:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	child_tf.tf_eip = elf->e_entry;
  801960:	8b 85 00 fe ff ff    	mov    -0x200(%ebp),%eax
  801966:	89 85 d4 fd ff ff    	mov    %eax,-0x22c(%ebp)

	if ((r = init_stack(child, argv, &child_tf.tf_esp, (USTACKTOP - PGSIZE))) < 0)
  80196c:	83 ec 0c             	sub    $0xc,%esp
  80196f:	8d 8d e0 fd ff ff    	lea    -0x220(%ebp),%ecx
  801975:	68 00 d0 bf ee       	push   $0xeebfd000
  80197a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80197d:	8b 85 8c fd ff ff    	mov    -0x274(%ebp),%eax
  801983:	e8 6f fd ff ff       	call   8016f7 <init_stack>
  801988:	83 c4 10             	add    $0x10,%esp
  80198b:	85 c0                	test   %eax,%eax
  80198d:	0f 88 77 01 00 00    	js     801b0a <spawn+0x27a>
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  801993:	8b 85 04 fe ff ff    	mov    -0x1fc(%ebp),%eax
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801999:	66 83 bd 14 fe ff ff 	cmpw   $0x0,-0x1ec(%ebp)
  8019a0:	00 
  8019a1:	74 5d                	je     801a00 <spawn+0x170>

	if ((r = init_stack(child, argv, &child_tf.tf_esp, (USTACKTOP - PGSIZE))) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  8019a3:	8d 9c 05 e8 fd ff ff 	lea    -0x218(%ebp,%eax,1),%ebx
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  8019aa:	be 00 00 00 00       	mov    $0x0,%esi
  8019af:	8b bd 90 fd ff ff    	mov    -0x270(%ebp),%edi
		if (ph->p_type != ELF_PROG_LOAD)
  8019b5:	83 3b 01             	cmpl   $0x1,(%ebx)
  8019b8:	75 35                	jne    8019ef <spawn+0x15f>
			continue;
		perm = PTE_P | PTE_U;
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
  8019ba:	8b 43 18             	mov    0x18(%ebx),%eax
  8019bd:	83 e0 02             	and    $0x2,%eax
	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
		if (ph->p_type != ELF_PROG_LOAD)
			continue;
		perm = PTE_P | PTE_U;
  8019c0:	83 f8 01             	cmp    $0x1,%eax
  8019c3:	19 c0                	sbb    %eax,%eax
  8019c5:	83 e0 fe             	and    $0xfffffffe,%eax
  8019c8:	83 c0 07             	add    $0x7,%eax
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
  8019cb:	8b 4b 14             	mov    0x14(%ebx),%ecx
  8019ce:	8b 53 08             	mov    0x8(%ebx),%edx
  8019d1:	50                   	push   %eax
  8019d2:	ff 73 04             	pushl  0x4(%ebx)
  8019d5:	ff 73 10             	pushl  0x10(%ebx)
  8019d8:	57                   	push   %edi
  8019d9:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  8019df:	e8 e8 fb ff ff       	call   8015cc <map_segment>
  8019e4:	83 c4 10             	add    $0x10,%esp
  8019e7:	85 c0                	test   %eax,%eax
  8019e9:	0f 88 e4 00 00 00    	js     801ad3 <spawn+0x243>
	if ((r = init_stack(child, argv, &child_tf.tf_esp, (USTACKTOP - PGSIZE))) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  8019ef:	46                   	inc    %esi
  8019f0:	0f b7 85 14 fe ff ff 	movzwl -0x1ec(%ebp),%eax
  8019f7:	39 f0                	cmp    %esi,%eax
  8019f9:	7e 05                	jle    801a00 <spawn+0x170>
  8019fb:	83 c3 20             	add    $0x20,%ebx
  8019fe:	eb b5                	jmp    8019b5 <spawn+0x125>
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
				     fd, ph->p_filesz, ph->p_offset, perm)) < 0)
			goto error;
	}
	close(fd);
  801a00:	83 ec 0c             	sub    $0xc,%esp
  801a03:	ff b5 90 fd ff ff    	pushl  -0x270(%ebp)
  801a09:	e8 ed f5 ff ff       	call   800ffb <close>
  801a0e:	83 c4 10             	add    $0x10,%esp
copy_shared_pages(envid_t child)
{
	// LAB 5: Your code here.
    uint32_t i;
    int r;
    for (i = 0; i != UTOP; i += PGSIZE) 
  801a11:	bb 00 00 00 00       	mov    $0x0,%ebx
  801a16:	8b b5 94 fd ff ff    	mov    -0x26c(%ebp),%esi
    if ((uvpd[PDX(i)] & PTE_P) && (uvpt[i / PGSIZE] & PTE_P) && (uvpt[i / PGSIZE] & PTE_SHARE)) {
  801a1c:	89 d8                	mov    %ebx,%eax
  801a1e:	c1 e8 16             	shr    $0x16,%eax
  801a21:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801a28:	a8 01                	test   $0x1,%al
  801a2a:	74 3e                	je     801a6a <spawn+0x1da>
  801a2c:	89 d8                	mov    %ebx,%eax
  801a2e:	c1 e8 0c             	shr    $0xc,%eax
  801a31:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801a38:	f6 c2 01             	test   $0x1,%dl
  801a3b:	74 2d                	je     801a6a <spawn+0x1da>
  801a3d:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801a44:	f6 c6 04             	test   $0x4,%dh
  801a47:	74 21                	je     801a6a <spawn+0x1da>
        r = sys_page_map(0, (void *)i, child, (void *)i, uvpt[i / PGSIZE] & PTE_SYSCALL);
  801a49:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801a50:	83 ec 0c             	sub    $0xc,%esp
  801a53:	25 07 0e 00 00       	and    $0xe07,%eax
  801a58:	50                   	push   %eax
  801a59:	53                   	push   %ebx
  801a5a:	56                   	push   %esi
  801a5b:	53                   	push   %ebx
  801a5c:	6a 00                	push   $0x0
  801a5e:	e8 75 f2 ff ff       	call   800cd8 <sys_page_map>
        if (r < 0) return r;
  801a63:	83 c4 20             	add    $0x20,%esp
  801a66:	85 c0                	test   %eax,%eax
  801a68:	78 13                	js     801a7d <spawn+0x1ed>
copy_shared_pages(envid_t child)
{
	// LAB 5: Your code here.
    uint32_t i;
    int r;
    for (i = 0; i != UTOP; i += PGSIZE) 
  801a6a:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801a70:	81 fb 00 00 c0 ee    	cmp    $0xeec00000,%ebx
  801a76:	75 a4                	jne    801a1c <spawn+0x18c>
  801a78:	e9 a1 00 00 00       	jmp    801b1e <spawn+0x28e>
	close(fd);
	fd = -1;

	// Copy shared library state.
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);
  801a7d:	50                   	push   %eax
  801a7e:	68 2e 2c 80 00       	push   $0x802c2e
  801a83:	68 85 00 00 00       	push   $0x85
  801a88:	68 08 2c 80 00       	push   $0x802c08
  801a8d:	e8 12 e7 ff ff       	call   8001a4 <_panic>

	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
		panic("sys_env_set_trapframe: %e", r);
  801a92:	50                   	push   %eax
  801a93:	68 44 2c 80 00       	push   $0x802c44
  801a98:	68 88 00 00 00       	push   $0x88
  801a9d:	68 08 2c 80 00       	push   $0x802c08
  801aa2:	e8 fd e6 ff ff       	call   8001a4 <_panic>

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
  801aa7:	83 ec 08             	sub    $0x8,%esp
  801aaa:	6a 02                	push   $0x2
  801aac:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801ab2:	e8 6a f2 ff ff       	call   800d21 <sys_env_set_status>
  801ab7:	83 c4 10             	add    $0x10,%esp
  801aba:	85 c0                	test   %eax,%eax
  801abc:	79 52                	jns    801b10 <spawn+0x280>
		panic("sys_env_set_status: %e", r);
  801abe:	50                   	push   %eax
  801abf:	68 5e 2c 80 00       	push   $0x802c5e
  801ac4:	68 8b 00 00 00       	push   $0x8b
  801ac9:	68 08 2c 80 00       	push   $0x802c08
  801ace:	e8 d1 e6 ff ff       	call   8001a4 <_panic>
  801ad3:	89 c7                	mov    %eax,%edi

	return child;

error:
	sys_env_destroy(child);
  801ad5:	83 ec 0c             	sub    $0xc,%esp
  801ad8:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801ade:	e8 64 f1 ff ff       	call   800c47 <sys_env_destroy>
	close(fd);
  801ae3:	83 c4 04             	add    $0x4,%esp
  801ae6:	ff b5 90 fd ff ff    	pushl  -0x270(%ebp)
  801aec:	e8 0a f5 ff ff       	call   800ffb <close>
	return r;
  801af1:	83 c4 10             	add    $0x10,%esp
		if (ph->p_type != ELF_PROG_LOAD)
			continue;
		perm = PTE_P | PTE_U;
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
  801af4:	89 bd 94 fd ff ff    	mov    %edi,-0x26c(%ebp)
	return child;

error:
	sys_env_destroy(child);
	close(fd);
	return r;
  801afa:	eb 14                	jmp    801b10 <spawn+0x280>
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
		return r;
  801afc:	8b 85 90 fd ff ff    	mov    -0x270(%ebp),%eax
  801b02:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)
  801b08:	eb 06                	jmp    801b10 <spawn+0x280>
	// Set up trap frame, including initial stack.
	child_tf = envs[ENVX(child)].env_tf;
	child_tf.tf_eip = elf->e_entry;

	if ((r = init_stack(child, argv, &child_tf.tf_esp, (USTACKTOP - PGSIZE))) < 0)
		return r;
  801b0a:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)

error:
	sys_env_destroy(child);
	close(fd);
	return r;
}
  801b10:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  801b16:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b19:	5b                   	pop    %ebx
  801b1a:	5e                   	pop    %esi
  801b1b:	5f                   	pop    %edi
  801b1c:	c9                   	leave  
  801b1d:	c3                   	ret    

	// Copy shared library state.
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);

	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
  801b1e:	83 ec 08             	sub    $0x8,%esp
  801b21:	8d 85 a4 fd ff ff    	lea    -0x25c(%ebp),%eax
  801b27:	50                   	push   %eax
  801b28:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801b2e:	e8 11 f2 ff ff       	call   800d44 <sys_env_set_trapframe>
  801b33:	83 c4 10             	add    $0x10,%esp
  801b36:	85 c0                	test   %eax,%eax
  801b38:	0f 89 69 ff ff ff    	jns    801aa7 <spawn+0x217>
  801b3e:	e9 4f ff ff ff       	jmp    801a92 <spawn+0x202>

00801b43 <exec>:
// 		 0x80000000(MYTEMPLATE) to be template block cache. Then sys_exec is a system call to complete 
// 		 memory setting.
// Remember: When there is virtual memory in ELF linking address overlaped with MYTEMPLATE, exec will fail.
int
exec(const char *prog, const char **argv)
{
  801b43:	55                   	push   %ebp
  801b44:	89 e5                	mov    %esp,%ebp
  801b46:	57                   	push   %edi
  801b47:	56                   	push   %esi
  801b48:	53                   	push   %ebx
  801b49:	81 ec 34 02 00 00    	sub    $0x234,%esp
	struct Elf *elf;
	struct Proghdr *ph;
	int perm;	


	if ((r = open(prog, O_RDONLY)) < 0)
  801b4f:	6a 00                	push   $0x0
  801b51:	ff 75 08             	pushl  0x8(%ebp)
  801b54:	e8 e3 f9 ff ff       	call   80153c <open>
  801b59:	89 85 d0 fd ff ff    	mov    %eax,-0x230(%ebp)
  801b5f:	83 c4 10             	add    $0x10,%esp
  801b62:	85 c0                	test   %eax,%eax
  801b64:	0f 88 a9 01 00 00    	js     801d13 <exec+0x1d0>
		return r;
	fd = r;

	// Read elf header
	elf = (struct Elf*) elf_buf;
  801b6a:	8d bd e8 fd ff ff    	lea    -0x218(%ebp),%edi
	if (readn(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf)
  801b70:	83 ec 04             	sub    $0x4,%esp
  801b73:	68 00 02 00 00       	push   $0x200
  801b78:	57                   	push   %edi
  801b79:	50                   	push   %eax
  801b7a:	e8 40 f6 ff ff       	call   8011bf <readn>
  801b7f:	83 c4 10             	add    $0x10,%esp
  801b82:	3d 00 02 00 00       	cmp    $0x200,%eax
  801b87:	75 0c                	jne    801b95 <exec+0x52>
	    || elf->e_magic != ELF_MAGIC) {
  801b89:	81 bd e8 fd ff ff 7f 	cmpl   $0x464c457f,-0x218(%ebp)
  801b90:	45 4c 46 
  801b93:	74 34                	je     801bc9 <exec+0x86>
		close(fd);
  801b95:	83 ec 0c             	sub    $0xc,%esp
  801b98:	ff b5 d0 fd ff ff    	pushl  -0x230(%ebp)
  801b9e:	e8 58 f4 ff ff       	call   800ffb <close>
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
  801ba3:	83 c4 0c             	add    $0xc,%esp
  801ba6:	68 7f 45 4c 46       	push   $0x464c457f
  801bab:	ff 37                	pushl  (%edi)
  801bad:	68 14 2c 80 00       	push   $0x802c14
  801bb2:	e8 c5 e6 ff ff       	call   80027c <cprintf>
		return -E_NOT_EXEC;
  801bb7:	83 c4 10             	add    $0x10,%esp
  801bba:	c7 85 d0 fd ff ff f2 	movl   $0xfffffff2,-0x230(%ebp)
  801bc1:	ff ff ff 
  801bc4:	e9 4a 01 00 00       	jmp    801d13 <exec+0x1d0>
	}


	// Set up program segments as defined in ELF header.
	uint32_t now_addr = MYTEMPLATE;
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  801bc9:	8b 47 1c             	mov    0x1c(%edi),%eax
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801bcc:	66 83 7f 2c 00       	cmpw   $0x0,0x2c(%edi)
  801bd1:	0f 84 8b 00 00 00    	je     801c62 <exec+0x11f>
	}


	// Set up program segments as defined in ELF header.
	uint32_t now_addr = MYTEMPLATE;
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  801bd7:	8d 9c 05 e8 fd ff ff 	lea    -0x218(%ebp,%eax,1),%ebx
		return -E_NOT_EXEC;
	}


	// Set up program segments as defined in ELF header.
	uint32_t now_addr = MYTEMPLATE;
  801bde:	c7 85 d4 fd ff ff 00 	movl   $0x80000000,-0x22c(%ebp)
  801be5:	00 00 80 
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801be8:	be 00 00 00 00       	mov    $0x0,%esi
		if (ph->p_type != ELF_PROG_LOAD)
  801bed:	83 3b 01             	cmpl   $0x1,(%ebx)
  801bf0:	75 62                	jne    801c54 <exec+0x111>
			continue;
		perm = PTE_P | PTE_U;
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
  801bf2:	8b 43 18             	mov    0x18(%ebx),%eax
  801bf5:	83 e0 02             	and    $0x2,%eax
	uint32_t now_addr = MYTEMPLATE;
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
		if (ph->p_type != ELF_PROG_LOAD)
			continue;
		perm = PTE_P | PTE_U;
  801bf8:	83 f8 01             	cmp    $0x1,%eax
  801bfb:	19 c0                	sbb    %eax,%eax
  801bfd:	83 e0 fe             	and    $0xfffffffe,%eax
  801c00:	83 c0 07             	add    $0x7,%eax
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
			perm |= PTE_W;
		if ((r = map_segment(0, PGOFF(ph->p_va) + now_addr, ph->p_memsz,
  801c03:	8b 4b 14             	mov    0x14(%ebx),%ecx
  801c06:	8b 53 08             	mov    0x8(%ebx),%edx
  801c09:	81 e2 ff 0f 00 00    	and    $0xfff,%edx
  801c0f:	03 95 d4 fd ff ff    	add    -0x22c(%ebp),%edx
  801c15:	50                   	push   %eax
  801c16:	ff 73 04             	pushl  0x4(%ebx)
  801c19:	ff 73 10             	pushl  0x10(%ebx)
  801c1c:	ff b5 d0 fd ff ff    	pushl  -0x230(%ebp)
  801c22:	b8 00 00 00 00       	mov    $0x0,%eax
  801c27:	e8 a0 f9 ff ff       	call   8015cc <map_segment>
  801c2c:	83 c4 10             	add    $0x10,%esp
  801c2f:	85 c0                	test   %eax,%eax
  801c31:	0f 88 a3 00 00 00    	js     801cda <exec+0x197>
				     fd, ph->p_filesz, ph->p_offset, perm)) < 0)
			goto error;
		now_addr += ROUNDUP(ph->p_memsz + PGOFF(ph->p_va), PGSIZE);
  801c37:	8b 53 14             	mov    0x14(%ebx),%edx
  801c3a:	8b 43 08             	mov    0x8(%ebx),%eax
  801c3d:	25 ff 0f 00 00       	and    $0xfff,%eax
  801c42:	8d 84 02 ff 0f 00 00 	lea    0xfff(%edx,%eax,1),%eax
  801c49:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801c4e:	01 85 d4 fd ff ff    	add    %eax,-0x22c(%ebp)


	// Set up program segments as defined in ELF header.
	uint32_t now_addr = MYTEMPLATE;
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801c54:	46                   	inc    %esi
  801c55:	0f b7 47 2c          	movzwl 0x2c(%edi),%eax
  801c59:	39 f0                	cmp    %esi,%eax
  801c5b:	7e 0f                	jle    801c6c <exec+0x129>
  801c5d:	83 c3 20             	add    $0x20,%ebx
  801c60:	eb 8b                	jmp    801bed <exec+0xaa>
		return -E_NOT_EXEC;
	}


	// Set up program segments as defined in ELF header.
	uint32_t now_addr = MYTEMPLATE;
  801c62:	c7 85 d4 fd ff ff 00 	movl   $0x80000000,-0x22c(%ebp)
  801c69:	00 00 80 
		if ((r = map_segment(0, PGOFF(ph->p_va) + now_addr, ph->p_memsz,
				     fd, ph->p_filesz, ph->p_offset, perm)) < 0)
			goto error;
		now_addr += ROUNDUP(ph->p_memsz + PGOFF(ph->p_va), PGSIZE);
	}
	close(fd);
  801c6c:	83 ec 0c             	sub    $0xc,%esp
  801c6f:	ff b5 d0 fd ff ff    	pushl  -0x230(%ebp)
  801c75:	e8 81 f3 ff ff       	call   800ffb <close>
	fd = -1;

	// Set up Stack 
	if ((r = init_stack(0, argv, &tf_esp, now_addr)) < 0)
  801c7a:	83 c4 04             	add    $0x4,%esp
  801c7d:	8d 8d e4 fd ff ff    	lea    -0x21c(%ebp),%ecx
  801c83:	ff b5 d4 fd ff ff    	pushl  -0x22c(%ebp)
  801c89:	8b 55 0c             	mov    0xc(%ebp),%edx
  801c8c:	b8 00 00 00 00       	mov    $0x0,%eax
  801c91:	e8 61 fa ff ff       	call   8016f7 <init_stack>
  801c96:	89 85 d0 fd ff ff    	mov    %eax,-0x230(%ebp)
  801c9c:	83 c4 10             	add    $0x10,%esp
  801c9f:	85 c0                	test   %eax,%eax
  801ca1:	78 70                	js     801d13 <exec+0x1d0>
		return r;

	// Syscall to exec
	if (sys_exec(elf->e_entry, tf_esp, (void *)(elf_buf + elf->e_phoff), elf->e_phnum) < 0)
  801ca3:	0f b7 47 2c          	movzwl 0x2c(%edi),%eax
  801ca7:	50                   	push   %eax
  801ca8:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  801cae:	03 47 1c             	add    0x1c(%edi),%eax
  801cb1:	50                   	push   %eax
  801cb2:	ff b5 e4 fd ff ff    	pushl  -0x21c(%ebp)
  801cb8:	ff 77 18             	pushl  0x18(%edi)
  801cbb:	e8 34 f1 ff ff       	call   800df4 <sys_exec>
  801cc0:	83 c4 10             	add    $0x10,%esp
  801cc3:	85 c0                	test   %eax,%eax
  801cc5:	79 42                	jns    801d09 <exec+0x1c6>
	}
	close(fd);
	fd = -1;

	// Set up Stack 
	if ((r = init_stack(0, argv, &tf_esp, now_addr)) < 0)
  801cc7:	8b 85 d0 fd ff ff    	mov    -0x230(%ebp),%eax
  801ccd:	89 85 d4 fd ff ff    	mov    %eax,-0x22c(%ebp)
				     fd, ph->p_filesz, ph->p_offset, perm)) < 0)
			goto error;
		now_addr += ROUNDUP(ph->p_memsz + PGOFF(ph->p_va), PGSIZE);
	}
	close(fd);
	fd = -1;
  801cd3:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
  801cd8:	eb 0c                	jmp    801ce6 <exec+0x1a3>
  801cda:	89 85 d4 fd ff ff    	mov    %eax,-0x22c(%ebp)
	int perm;	


	if ((r = open(prog, O_RDONLY)) < 0)
		return r;
	fd = r;
  801ce0:	8b 9d d0 fd ff ff    	mov    -0x230(%ebp),%ebx
	if (sys_exec(elf->e_entry, tf_esp, (void *)(elf_buf + elf->e_phoff), elf->e_phnum) < 0)
		goto error;
	return 0;

error:
	sys_env_destroy(0);
  801ce6:	83 ec 0c             	sub    $0xc,%esp
  801ce9:	6a 00                	push   $0x0
  801ceb:	e8 57 ef ff ff       	call   800c47 <sys_env_destroy>
	close(fd);
  801cf0:	89 1c 24             	mov    %ebx,(%esp)
  801cf3:	e8 03 f3 ff ff       	call   800ffb <close>
	return r;
  801cf8:	83 c4 10             	add    $0x10,%esp
  801cfb:	8b 85 d4 fd ff ff    	mov    -0x22c(%ebp),%eax
  801d01:	89 85 d0 fd ff ff    	mov    %eax,-0x230(%ebp)
  801d07:	eb 0a                	jmp    801d13 <exec+0x1d0>
		return r;

	// Syscall to exec
	if (sys_exec(elf->e_entry, tf_esp, (void *)(elf_buf + elf->e_phoff), elf->e_phnum) < 0)
		goto error;
	return 0;
  801d09:	c7 85 d0 fd ff ff 00 	movl   $0x0,-0x230(%ebp)
  801d10:	00 00 00 

error:
	sys_env_destroy(0);
	close(fd);
	return r;
}
  801d13:	8b 85 d0 fd ff ff    	mov    -0x230(%ebp),%eax
  801d19:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d1c:	5b                   	pop    %ebx
  801d1d:	5e                   	pop    %esi
  801d1e:	5f                   	pop    %edi
  801d1f:	c9                   	leave  
  801d20:	c3                   	ret    

00801d21 <execl>:
// Exec, taking command-line arguments array directly on the stack.
// NOTE: Must have a sentinal of NULL at the end of the args
// (none of the args may be NULL).
int
execl(const char *prog, const char *arg0, ...)
{
  801d21:	55                   	push   %ebp
  801d22:	89 e5                	mov    %esp,%ebp
  801d24:	56                   	push   %esi
  801d25:	53                   	push   %ebx
  801d26:	8b 75 0c             	mov    0xc(%ebp),%esi
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801d29:	8d 45 14             	lea    0x14(%ebp),%eax
  801d2c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801d30:	74 5f                	je     801d91 <execl+0x70>
{
	// We calculate argc by advancing the args until we hit NULL.
	// The contract of the function guarantees that the last
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
  801d32:	b9 00 00 00 00       	mov    $0x0,%ecx
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
		argc++;
  801d37:	41                   	inc    %ecx
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801d38:	89 c2                	mov    %eax,%edx
  801d3a:	83 c0 04             	add    $0x4,%eax
  801d3d:	83 3a 00             	cmpl   $0x0,(%edx)
  801d40:	75 f5                	jne    801d37 <execl+0x16>
		argc++;
	va_end(vl);

	// Now that we have the size of the args, do a second pass
	// and store the values in a VLA, which has the format of argv
	const char *argv[argc+2];
  801d42:	8d 04 8d 26 00 00 00 	lea    0x26(,%ecx,4),%eax
  801d49:	83 e0 f0             	and    $0xfffffff0,%eax
  801d4c:	29 c4                	sub    %eax,%esp
  801d4e:	8d 44 24 0f          	lea    0xf(%esp),%eax
  801d52:	83 e0 f0             	and    $0xfffffff0,%eax
  801d55:	89 c3                	mov    %eax,%ebx
	argv[0] = arg0;
  801d57:	89 30                	mov    %esi,(%eax)
	argv[argc+1] = NULL;
  801d59:	c7 44 88 04 00 00 00 	movl   $0x0,0x4(%eax,%ecx,4)
  801d60:	00 

	va_start(vl, arg0);
  801d61:	8d 55 10             	lea    0x10(%ebp),%edx
	unsigned i;
	for(i=0;i<argc;i++)
  801d64:	89 ce                	mov    %ecx,%esi
  801d66:	85 c9                	test   %ecx,%ecx
  801d68:	74 14                	je     801d7e <execl+0x5d>
  801d6a:	b8 00 00 00 00       	mov    $0x0,%eax
		argv[i+1] = va_arg(vl, const char *);
  801d6f:	40                   	inc    %eax
  801d70:	89 d1                	mov    %edx,%ecx
  801d72:	83 c2 04             	add    $0x4,%edx
  801d75:	8b 09                	mov    (%ecx),%ecx
  801d77:	89 0c 83             	mov    %ecx,(%ebx,%eax,4)
	argv[0] = arg0;
	argv[argc+1] = NULL;

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  801d7a:	39 f0                	cmp    %esi,%eax
  801d7c:	72 f1                	jb     801d6f <execl+0x4e>
		argv[i+1] = va_arg(vl, const char *);
	va_end(vl);
	return exec(prog, argv);
  801d7e:	83 ec 08             	sub    $0x8,%esp
  801d81:	53                   	push   %ebx
  801d82:	ff 75 08             	pushl  0x8(%ebp)
  801d85:	e8 b9 fd ff ff       	call   801b43 <exec>
}
  801d8a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d8d:	5b                   	pop    %ebx
  801d8e:	5e                   	pop    %esi
  801d8f:	c9                   	leave  
  801d90:	c3                   	ret    
		argc++;
	va_end(vl);

	// Now that we have the size of the args, do a second pass
	// and store the values in a VLA, which has the format of argv
	const char *argv[argc+2];
  801d91:	83 ec 20             	sub    $0x20,%esp
  801d94:	8d 44 24 0f          	lea    0xf(%esp),%eax
  801d98:	83 e0 f0             	and    $0xfffffff0,%eax
  801d9b:	89 c3                	mov    %eax,%ebx
	argv[0] = arg0;
  801d9d:	89 30                	mov    %esi,(%eax)
	argv[argc+1] = NULL;
  801d9f:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
  801da6:	eb d6                	jmp    801d7e <execl+0x5d>

00801da8 <spawnl>:
// Spawn, taking command-line arguments array directly on the stack.
// NOTE: Must have a sentinal of NULL at the end of the args
// (none of the args may be NULL).
int
spawnl(const char *prog, const char *arg0, ...)
{
  801da8:	55                   	push   %ebp
  801da9:	89 e5                	mov    %esp,%ebp
  801dab:	56                   	push   %esi
  801dac:	53                   	push   %ebx
  801dad:	8b 75 0c             	mov    0xc(%ebp),%esi
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801db0:	8d 45 14             	lea    0x14(%ebp),%eax
  801db3:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801db7:	74 5f                	je     801e18 <spawnl+0x70>
{
	// We calculate argc by advancing the args until we hit NULL.
	// The contract of the function guarantees that the last
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
  801db9:	b9 00 00 00 00       	mov    $0x0,%ecx
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
		argc++;
  801dbe:	41                   	inc    %ecx
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801dbf:	89 c2                	mov    %eax,%edx
  801dc1:	83 c0 04             	add    $0x4,%eax
  801dc4:	83 3a 00             	cmpl   $0x0,(%edx)
  801dc7:	75 f5                	jne    801dbe <spawnl+0x16>
		argc++;
	va_end(vl);

	// Now that we have the size of the args, do a second pass
	// and store the values in a VLA, which has the format of argv
	const char *argv[argc+2];
  801dc9:	8d 04 8d 26 00 00 00 	lea    0x26(,%ecx,4),%eax
  801dd0:	83 e0 f0             	and    $0xfffffff0,%eax
  801dd3:	29 c4                	sub    %eax,%esp
  801dd5:	8d 44 24 0f          	lea    0xf(%esp),%eax
  801dd9:	83 e0 f0             	and    $0xfffffff0,%eax
  801ddc:	89 c3                	mov    %eax,%ebx
	argv[0] = arg0;
  801dde:	89 30                	mov    %esi,(%eax)
	argv[argc+1] = NULL;
  801de0:	c7 44 88 04 00 00 00 	movl   $0x0,0x4(%eax,%ecx,4)
  801de7:	00 

	va_start(vl, arg0);
  801de8:	8d 55 10             	lea    0x10(%ebp),%edx
	unsigned i;
	for(i=0;i<argc;i++)
  801deb:	89 ce                	mov    %ecx,%esi
  801ded:	85 c9                	test   %ecx,%ecx
  801def:	74 14                	je     801e05 <spawnl+0x5d>
  801df1:	b8 00 00 00 00       	mov    $0x0,%eax
		argv[i+1] = va_arg(vl, const char *);
  801df6:	40                   	inc    %eax
  801df7:	89 d1                	mov    %edx,%ecx
  801df9:	83 c2 04             	add    $0x4,%edx
  801dfc:	8b 09                	mov    (%ecx),%ecx
  801dfe:	89 0c 83             	mov    %ecx,(%ebx,%eax,4)
	argv[0] = arg0;
	argv[argc+1] = NULL;

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  801e01:	39 f0                	cmp    %esi,%eax
  801e03:	72 f1                	jb     801df6 <spawnl+0x4e>
		argv[i+1] = va_arg(vl, const char *);
	va_end(vl);
	return spawn(prog, argv);
  801e05:	83 ec 08             	sub    $0x8,%esp
  801e08:	53                   	push   %ebx
  801e09:	ff 75 08             	pushl  0x8(%ebp)
  801e0c:	e8 7f fa ff ff       	call   801890 <spawn>
}
  801e11:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e14:	5b                   	pop    %ebx
  801e15:	5e                   	pop    %esi
  801e16:	c9                   	leave  
  801e17:	c3                   	ret    
		argc++;
	va_end(vl);

	// Now that we have the size of the args, do a second pass
	// and store the values in a VLA, which has the format of argv
	const char *argv[argc+2];
  801e18:	83 ec 20             	sub    $0x20,%esp
  801e1b:	8d 44 24 0f          	lea    0xf(%esp),%eax
  801e1f:	83 e0 f0             	and    $0xfffffff0,%eax
  801e22:	89 c3                	mov    %eax,%ebx
	argv[0] = arg0;
  801e24:	89 30                	mov    %esi,(%eax)
	argv[argc+1] = NULL;
  801e26:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
  801e2d:	eb d6                	jmp    801e05 <spawnl+0x5d>
	...

00801e30 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801e30:	55                   	push   %ebp
  801e31:	89 e5                	mov    %esp,%ebp
  801e33:	56                   	push   %esi
  801e34:	53                   	push   %ebx
  801e35:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801e38:	83 ec 0c             	sub    $0xc,%esp
  801e3b:	ff 75 08             	pushl  0x8(%ebp)
  801e3e:	e8 e9 ef ff ff       	call   800e2c <fd2data>
  801e43:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  801e45:	83 c4 08             	add    $0x8,%esp
  801e48:	68 a0 2c 80 00       	push   $0x802ca0
  801e4d:	56                   	push   %esi
  801e4e:	e8 df e9 ff ff       	call   800832 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801e53:	8b 43 04             	mov    0x4(%ebx),%eax
  801e56:	2b 03                	sub    (%ebx),%eax
  801e58:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  801e5e:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  801e65:	00 00 00 
	stat->st_dev = &devpipe;
  801e68:	c7 86 88 00 00 00 20 	movl   $0x803020,0x88(%esi)
  801e6f:	30 80 00 
	return 0;
}
  801e72:	b8 00 00 00 00       	mov    $0x0,%eax
  801e77:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e7a:	5b                   	pop    %ebx
  801e7b:	5e                   	pop    %esi
  801e7c:	c9                   	leave  
  801e7d:	c3                   	ret    

00801e7e <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801e7e:	55                   	push   %ebp
  801e7f:	89 e5                	mov    %esp,%ebp
  801e81:	53                   	push   %ebx
  801e82:	83 ec 0c             	sub    $0xc,%esp
  801e85:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801e88:	53                   	push   %ebx
  801e89:	6a 00                	push   $0x0
  801e8b:	e8 6e ee ff ff       	call   800cfe <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801e90:	89 1c 24             	mov    %ebx,(%esp)
  801e93:	e8 94 ef ff ff       	call   800e2c <fd2data>
  801e98:	83 c4 08             	add    $0x8,%esp
  801e9b:	50                   	push   %eax
  801e9c:	6a 00                	push   $0x0
  801e9e:	e8 5b ee ff ff       	call   800cfe <sys_page_unmap>
}
  801ea3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801ea6:	c9                   	leave  
  801ea7:	c3                   	ret    

00801ea8 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801ea8:	55                   	push   %ebp
  801ea9:	89 e5                	mov    %esp,%ebp
  801eab:	57                   	push   %edi
  801eac:	56                   	push   %esi
  801ead:	53                   	push   %ebx
  801eae:	83 ec 1c             	sub    $0x1c,%esp
  801eb1:	89 c7                	mov    %eax,%edi
  801eb3:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801eb6:	a1 04 40 80 00       	mov    0x804004,%eax
  801ebb:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801ebe:	83 ec 0c             	sub    $0xc,%esp
  801ec1:	57                   	push   %edi
  801ec2:	e8 95 05 00 00       	call   80245c <pageref>
  801ec7:	89 c6                	mov    %eax,%esi
  801ec9:	83 c4 04             	add    $0x4,%esp
  801ecc:	ff 75 e4             	pushl  -0x1c(%ebp)
  801ecf:	e8 88 05 00 00       	call   80245c <pageref>
  801ed4:	83 c4 10             	add    $0x10,%esp
  801ed7:	39 c6                	cmp    %eax,%esi
  801ed9:	0f 94 c0             	sete   %al
  801edc:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  801edf:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801ee5:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801ee8:	39 cb                	cmp    %ecx,%ebx
  801eea:	75 08                	jne    801ef4 <_pipeisclosed+0x4c>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  801eec:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801eef:	5b                   	pop    %ebx
  801ef0:	5e                   	pop    %esi
  801ef1:	5f                   	pop    %edi
  801ef2:	c9                   	leave  
  801ef3:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  801ef4:	83 f8 01             	cmp    $0x1,%eax
  801ef7:	75 bd                	jne    801eb6 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801ef9:	8b 42 58             	mov    0x58(%edx),%eax
  801efc:	6a 01                	push   $0x1
  801efe:	50                   	push   %eax
  801eff:	53                   	push   %ebx
  801f00:	68 a7 2c 80 00       	push   $0x802ca7
  801f05:	e8 72 e3 ff ff       	call   80027c <cprintf>
  801f0a:	83 c4 10             	add    $0x10,%esp
  801f0d:	eb a7                	jmp    801eb6 <_pipeisclosed+0xe>

00801f0f <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801f0f:	55                   	push   %ebp
  801f10:	89 e5                	mov    %esp,%ebp
  801f12:	57                   	push   %edi
  801f13:	56                   	push   %esi
  801f14:	53                   	push   %ebx
  801f15:	83 ec 28             	sub    $0x28,%esp
  801f18:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801f1b:	56                   	push   %esi
  801f1c:	e8 0b ef ff ff       	call   800e2c <fd2data>
  801f21:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801f23:	83 c4 10             	add    $0x10,%esp
  801f26:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801f2a:	75 4a                	jne    801f76 <devpipe_write+0x67>
  801f2c:	bf 00 00 00 00       	mov    $0x0,%edi
  801f31:	eb 56                	jmp    801f89 <devpipe_write+0x7a>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801f33:	89 da                	mov    %ebx,%edx
  801f35:	89 f0                	mov    %esi,%eax
  801f37:	e8 6c ff ff ff       	call   801ea8 <_pipeisclosed>
  801f3c:	85 c0                	test   %eax,%eax
  801f3e:	75 4d                	jne    801f8d <devpipe_write+0x7e>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801f40:	e8 48 ed ff ff       	call   800c8d <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801f45:	8b 43 04             	mov    0x4(%ebx),%eax
  801f48:	8b 13                	mov    (%ebx),%edx
  801f4a:	83 c2 20             	add    $0x20,%edx
  801f4d:	39 d0                	cmp    %edx,%eax
  801f4f:	73 e2                	jae    801f33 <devpipe_write+0x24>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801f51:	89 c2                	mov    %eax,%edx
  801f53:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  801f59:	79 05                	jns    801f60 <devpipe_write+0x51>
  801f5b:	4a                   	dec    %edx
  801f5c:	83 ca e0             	or     $0xffffffe0,%edx
  801f5f:	42                   	inc    %edx
  801f60:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801f63:	8a 0c 39             	mov    (%ecx,%edi,1),%cl
  801f66:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801f6a:	40                   	inc    %eax
  801f6b:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801f6e:	47                   	inc    %edi
  801f6f:	39 7d 10             	cmp    %edi,0x10(%ebp)
  801f72:	77 07                	ja     801f7b <devpipe_write+0x6c>
  801f74:	eb 13                	jmp    801f89 <devpipe_write+0x7a>
  801f76:	bf 00 00 00 00       	mov    $0x0,%edi
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801f7b:	8b 43 04             	mov    0x4(%ebx),%eax
  801f7e:	8b 13                	mov    (%ebx),%edx
  801f80:	83 c2 20             	add    $0x20,%edx
  801f83:	39 d0                	cmp    %edx,%eax
  801f85:	73 ac                	jae    801f33 <devpipe_write+0x24>
  801f87:	eb c8                	jmp    801f51 <devpipe_write+0x42>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801f89:	89 f8                	mov    %edi,%eax
  801f8b:	eb 05                	jmp    801f92 <devpipe_write+0x83>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801f8d:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801f92:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f95:	5b                   	pop    %ebx
  801f96:	5e                   	pop    %esi
  801f97:	5f                   	pop    %edi
  801f98:	c9                   	leave  
  801f99:	c3                   	ret    

00801f9a <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801f9a:	55                   	push   %ebp
  801f9b:	89 e5                	mov    %esp,%ebp
  801f9d:	57                   	push   %edi
  801f9e:	56                   	push   %esi
  801f9f:	53                   	push   %ebx
  801fa0:	83 ec 18             	sub    $0x18,%esp
  801fa3:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801fa6:	57                   	push   %edi
  801fa7:	e8 80 ee ff ff       	call   800e2c <fd2data>
  801fac:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801fae:	83 c4 10             	add    $0x10,%esp
  801fb1:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801fb5:	75 44                	jne    801ffb <devpipe_read+0x61>
  801fb7:	be 00 00 00 00       	mov    $0x0,%esi
  801fbc:	eb 4f                	jmp    80200d <devpipe_read+0x73>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
				return i;
  801fbe:	89 f0                	mov    %esi,%eax
  801fc0:	eb 54                	jmp    802016 <devpipe_read+0x7c>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801fc2:	89 da                	mov    %ebx,%edx
  801fc4:	89 f8                	mov    %edi,%eax
  801fc6:	e8 dd fe ff ff       	call   801ea8 <_pipeisclosed>
  801fcb:	85 c0                	test   %eax,%eax
  801fcd:	75 42                	jne    802011 <devpipe_read+0x77>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801fcf:	e8 b9 ec ff ff       	call   800c8d <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801fd4:	8b 03                	mov    (%ebx),%eax
  801fd6:	3b 43 04             	cmp    0x4(%ebx),%eax
  801fd9:	74 e7                	je     801fc2 <devpipe_read+0x28>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801fdb:	25 1f 00 00 80       	and    $0x8000001f,%eax
  801fe0:	79 05                	jns    801fe7 <devpipe_read+0x4d>
  801fe2:	48                   	dec    %eax
  801fe3:	83 c8 e0             	or     $0xffffffe0,%eax
  801fe6:	40                   	inc    %eax
  801fe7:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  801feb:	8b 55 0c             	mov    0xc(%ebp),%edx
  801fee:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  801ff1:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801ff3:	46                   	inc    %esi
  801ff4:	39 75 10             	cmp    %esi,0x10(%ebp)
  801ff7:	77 07                	ja     802000 <devpipe_read+0x66>
  801ff9:	eb 12                	jmp    80200d <devpipe_read+0x73>
  801ffb:	be 00 00 00 00       	mov    $0x0,%esi
		while (p->p_rpos == p->p_wpos) {
  802000:	8b 03                	mov    (%ebx),%eax
  802002:	3b 43 04             	cmp    0x4(%ebx),%eax
  802005:	75 d4                	jne    801fdb <devpipe_read+0x41>
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  802007:	85 f6                	test   %esi,%esi
  802009:	75 b3                	jne    801fbe <devpipe_read+0x24>
  80200b:	eb b5                	jmp    801fc2 <devpipe_read+0x28>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  80200d:	89 f0                	mov    %esi,%eax
  80200f:	eb 05                	jmp    802016 <devpipe_read+0x7c>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802011:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  802016:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802019:	5b                   	pop    %ebx
  80201a:	5e                   	pop    %esi
  80201b:	5f                   	pop    %edi
  80201c:	c9                   	leave  
  80201d:	c3                   	ret    

0080201e <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  80201e:	55                   	push   %ebp
  80201f:	89 e5                	mov    %esp,%ebp
  802021:	57                   	push   %edi
  802022:	56                   	push   %esi
  802023:	53                   	push   %ebx
  802024:	83 ec 28             	sub    $0x28,%esp
  802027:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  80202a:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80202d:	50                   	push   %eax
  80202e:	e8 11 ee ff ff       	call   800e44 <fd_alloc>
  802033:	89 c3                	mov    %eax,%ebx
  802035:	83 c4 10             	add    $0x10,%esp
  802038:	85 c0                	test   %eax,%eax
  80203a:	0f 88 24 01 00 00    	js     802164 <pipe+0x146>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802040:	83 ec 04             	sub    $0x4,%esp
  802043:	68 07 04 00 00       	push   $0x407
  802048:	ff 75 e4             	pushl  -0x1c(%ebp)
  80204b:	6a 00                	push   $0x0
  80204d:	e8 62 ec ff ff       	call   800cb4 <sys_page_alloc>
  802052:	89 c3                	mov    %eax,%ebx
  802054:	83 c4 10             	add    $0x10,%esp
  802057:	85 c0                	test   %eax,%eax
  802059:	0f 88 05 01 00 00    	js     802164 <pipe+0x146>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  80205f:	83 ec 0c             	sub    $0xc,%esp
  802062:	8d 45 e0             	lea    -0x20(%ebp),%eax
  802065:	50                   	push   %eax
  802066:	e8 d9 ed ff ff       	call   800e44 <fd_alloc>
  80206b:	89 c3                	mov    %eax,%ebx
  80206d:	83 c4 10             	add    $0x10,%esp
  802070:	85 c0                	test   %eax,%eax
  802072:	0f 88 dc 00 00 00    	js     802154 <pipe+0x136>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802078:	83 ec 04             	sub    $0x4,%esp
  80207b:	68 07 04 00 00       	push   $0x407
  802080:	ff 75 e0             	pushl  -0x20(%ebp)
  802083:	6a 00                	push   $0x0
  802085:	e8 2a ec ff ff       	call   800cb4 <sys_page_alloc>
  80208a:	89 c3                	mov    %eax,%ebx
  80208c:	83 c4 10             	add    $0x10,%esp
  80208f:	85 c0                	test   %eax,%eax
  802091:	0f 88 bd 00 00 00    	js     802154 <pipe+0x136>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  802097:	83 ec 0c             	sub    $0xc,%esp
  80209a:	ff 75 e4             	pushl  -0x1c(%ebp)
  80209d:	e8 8a ed ff ff       	call   800e2c <fd2data>
  8020a2:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8020a4:	83 c4 0c             	add    $0xc,%esp
  8020a7:	68 07 04 00 00       	push   $0x407
  8020ac:	50                   	push   %eax
  8020ad:	6a 00                	push   $0x0
  8020af:	e8 00 ec ff ff       	call   800cb4 <sys_page_alloc>
  8020b4:	89 c3                	mov    %eax,%ebx
  8020b6:	83 c4 10             	add    $0x10,%esp
  8020b9:	85 c0                	test   %eax,%eax
  8020bb:	0f 88 83 00 00 00    	js     802144 <pipe+0x126>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8020c1:	83 ec 0c             	sub    $0xc,%esp
  8020c4:	ff 75 e0             	pushl  -0x20(%ebp)
  8020c7:	e8 60 ed ff ff       	call   800e2c <fd2data>
  8020cc:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  8020d3:	50                   	push   %eax
  8020d4:	6a 00                	push   $0x0
  8020d6:	56                   	push   %esi
  8020d7:	6a 00                	push   $0x0
  8020d9:	e8 fa eb ff ff       	call   800cd8 <sys_page_map>
  8020de:	89 c3                	mov    %eax,%ebx
  8020e0:	83 c4 20             	add    $0x20,%esp
  8020e3:	85 c0                	test   %eax,%eax
  8020e5:	78 4f                	js     802136 <pipe+0x118>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  8020e7:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8020ed:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8020f0:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8020f2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8020f5:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8020fc:	8b 15 20 30 80 00    	mov    0x803020,%edx
  802102:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802105:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  802107:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80210a:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  802111:	83 ec 0c             	sub    $0xc,%esp
  802114:	ff 75 e4             	pushl  -0x1c(%ebp)
  802117:	e8 00 ed ff ff       	call   800e1c <fd2num>
  80211c:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  80211e:	83 c4 04             	add    $0x4,%esp
  802121:	ff 75 e0             	pushl  -0x20(%ebp)
  802124:	e8 f3 ec ff ff       	call   800e1c <fd2num>
  802129:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  80212c:	83 c4 10             	add    $0x10,%esp
  80212f:	bb 00 00 00 00       	mov    $0x0,%ebx
  802134:	eb 2e                	jmp    802164 <pipe+0x146>

    err3:
	sys_page_unmap(0, va);
  802136:	83 ec 08             	sub    $0x8,%esp
  802139:	56                   	push   %esi
  80213a:	6a 00                	push   $0x0
  80213c:	e8 bd eb ff ff       	call   800cfe <sys_page_unmap>
  802141:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  802144:	83 ec 08             	sub    $0x8,%esp
  802147:	ff 75 e0             	pushl  -0x20(%ebp)
  80214a:	6a 00                	push   $0x0
  80214c:	e8 ad eb ff ff       	call   800cfe <sys_page_unmap>
  802151:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  802154:	83 ec 08             	sub    $0x8,%esp
  802157:	ff 75 e4             	pushl  -0x1c(%ebp)
  80215a:	6a 00                	push   $0x0
  80215c:	e8 9d eb ff ff       	call   800cfe <sys_page_unmap>
  802161:	83 c4 10             	add    $0x10,%esp
    err:
	return r;
}
  802164:	89 d8                	mov    %ebx,%eax
  802166:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802169:	5b                   	pop    %ebx
  80216a:	5e                   	pop    %esi
  80216b:	5f                   	pop    %edi
  80216c:	c9                   	leave  
  80216d:	c3                   	ret    

0080216e <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  80216e:	55                   	push   %ebp
  80216f:	89 e5                	mov    %esp,%ebp
  802171:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802174:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802177:	50                   	push   %eax
  802178:	ff 75 08             	pushl  0x8(%ebp)
  80217b:	e8 37 ed ff ff       	call   800eb7 <fd_lookup>
  802180:	83 c4 10             	add    $0x10,%esp
  802183:	85 c0                	test   %eax,%eax
  802185:	78 18                	js     80219f <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  802187:	83 ec 0c             	sub    $0xc,%esp
  80218a:	ff 75 f4             	pushl  -0xc(%ebp)
  80218d:	e8 9a ec ff ff       	call   800e2c <fd2data>
	return _pipeisclosed(fd, p);
  802192:	89 c2                	mov    %eax,%edx
  802194:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802197:	e8 0c fd ff ff       	call   801ea8 <_pipeisclosed>
  80219c:	83 c4 10             	add    $0x10,%esp
}
  80219f:	c9                   	leave  
  8021a0:	c3                   	ret    
  8021a1:	00 00                	add    %al,(%eax)
	...

008021a4 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  8021a4:	55                   	push   %ebp
  8021a5:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  8021a7:	b8 00 00 00 00       	mov    $0x0,%eax
  8021ac:	c9                   	leave  
  8021ad:	c3                   	ret    

008021ae <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8021ae:	55                   	push   %ebp
  8021af:	89 e5                	mov    %esp,%ebp
  8021b1:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  8021b4:	68 bf 2c 80 00       	push   $0x802cbf
  8021b9:	ff 75 0c             	pushl  0xc(%ebp)
  8021bc:	e8 71 e6 ff ff       	call   800832 <strcpy>
	return 0;
}
  8021c1:	b8 00 00 00 00       	mov    $0x0,%eax
  8021c6:	c9                   	leave  
  8021c7:	c3                   	ret    

008021c8 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8021c8:	55                   	push   %ebp
  8021c9:	89 e5                	mov    %esp,%ebp
  8021cb:	57                   	push   %edi
  8021cc:	56                   	push   %esi
  8021cd:	53                   	push   %ebx
  8021ce:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8021d4:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8021d8:	74 45                	je     80221f <devcons_write+0x57>
  8021da:	b8 00 00 00 00       	mov    $0x0,%eax
  8021df:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8021e4:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  8021ea:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8021ed:	29 c3                	sub    %eax,%ebx
		if (m > sizeof(buf) - 1)
  8021ef:	83 fb 7f             	cmp    $0x7f,%ebx
  8021f2:	76 05                	jbe    8021f9 <devcons_write+0x31>
			m = sizeof(buf) - 1;
  8021f4:	bb 7f 00 00 00       	mov    $0x7f,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  8021f9:	83 ec 04             	sub    $0x4,%esp
  8021fc:	53                   	push   %ebx
  8021fd:	03 45 0c             	add    0xc(%ebp),%eax
  802200:	50                   	push   %eax
  802201:	57                   	push   %edi
  802202:	e8 ec e7 ff ff       	call   8009f3 <memmove>
		sys_cputs(buf, m);
  802207:	83 c4 08             	add    $0x8,%esp
  80220a:	53                   	push   %ebx
  80220b:	57                   	push   %edi
  80220c:	e8 ec e9 ff ff       	call   800bfd <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802211:	01 de                	add    %ebx,%esi
  802213:	89 f0                	mov    %esi,%eax
  802215:	83 c4 10             	add    $0x10,%esp
  802218:	3b 75 10             	cmp    0x10(%ebp),%esi
  80221b:	72 cd                	jb     8021ea <devcons_write+0x22>
  80221d:	eb 05                	jmp    802224 <devcons_write+0x5c>
  80221f:	be 00 00 00 00       	mov    $0x0,%esi
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  802224:	89 f0                	mov    %esi,%eax
  802226:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802229:	5b                   	pop    %ebx
  80222a:	5e                   	pop    %esi
  80222b:	5f                   	pop    %edi
  80222c:	c9                   	leave  
  80222d:	c3                   	ret    

0080222e <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  80222e:	55                   	push   %ebp
  80222f:	89 e5                	mov    %esp,%ebp
  802231:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  802234:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  802238:	75 07                	jne    802241 <devcons_read+0x13>
  80223a:	eb 25                	jmp    802261 <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  80223c:	e8 4c ea ff ff       	call   800c8d <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  802241:	e8 dd e9 ff ff       	call   800c23 <sys_cgetc>
  802246:	85 c0                	test   %eax,%eax
  802248:	74 f2                	je     80223c <devcons_read+0xe>
  80224a:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  80224c:	85 c0                	test   %eax,%eax
  80224e:	78 1d                	js     80226d <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  802250:	83 f8 04             	cmp    $0x4,%eax
  802253:	74 13                	je     802268 <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  802255:	8b 45 0c             	mov    0xc(%ebp),%eax
  802258:	88 10                	mov    %dl,(%eax)
	return 1;
  80225a:	b8 01 00 00 00       	mov    $0x1,%eax
  80225f:	eb 0c                	jmp    80226d <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  802261:	b8 00 00 00 00       	mov    $0x0,%eax
  802266:	eb 05                	jmp    80226d <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  802268:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  80226d:	c9                   	leave  
  80226e:	c3                   	ret    

0080226f <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  80226f:	55                   	push   %ebp
  802270:	89 e5                	mov    %esp,%ebp
  802272:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  802275:	8b 45 08             	mov    0x8(%ebp),%eax
  802278:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  80227b:	6a 01                	push   $0x1
  80227d:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802280:	50                   	push   %eax
  802281:	e8 77 e9 ff ff       	call   800bfd <sys_cputs>
  802286:	83 c4 10             	add    $0x10,%esp
}
  802289:	c9                   	leave  
  80228a:	c3                   	ret    

0080228b <getchar>:

int
getchar(void)
{
  80228b:	55                   	push   %ebp
  80228c:	89 e5                	mov    %esp,%ebp
  80228e:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  802291:	6a 01                	push   $0x1
  802293:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802296:	50                   	push   %eax
  802297:	6a 00                	push   $0x0
  802299:	e8 9a ee ff ff       	call   801138 <read>
	if (r < 0)
  80229e:	83 c4 10             	add    $0x10,%esp
  8022a1:	85 c0                	test   %eax,%eax
  8022a3:	78 0f                	js     8022b4 <getchar+0x29>
		return r;
	if (r < 1)
  8022a5:	85 c0                	test   %eax,%eax
  8022a7:	7e 06                	jle    8022af <getchar+0x24>
		return -E_EOF;
	return c;
  8022a9:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8022ad:	eb 05                	jmp    8022b4 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  8022af:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  8022b4:	c9                   	leave  
  8022b5:	c3                   	ret    

008022b6 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  8022b6:	55                   	push   %ebp
  8022b7:	89 e5                	mov    %esp,%ebp
  8022b9:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8022bc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8022bf:	50                   	push   %eax
  8022c0:	ff 75 08             	pushl  0x8(%ebp)
  8022c3:	e8 ef eb ff ff       	call   800eb7 <fd_lookup>
  8022c8:	83 c4 10             	add    $0x10,%esp
  8022cb:	85 c0                	test   %eax,%eax
  8022cd:	78 11                	js     8022e0 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  8022cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8022d2:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8022d8:	39 10                	cmp    %edx,(%eax)
  8022da:	0f 94 c0             	sete   %al
  8022dd:	0f b6 c0             	movzbl %al,%eax
}
  8022e0:	c9                   	leave  
  8022e1:	c3                   	ret    

008022e2 <opencons>:

int
opencons(void)
{
  8022e2:	55                   	push   %ebp
  8022e3:	89 e5                	mov    %esp,%ebp
  8022e5:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8022e8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8022eb:	50                   	push   %eax
  8022ec:	e8 53 eb ff ff       	call   800e44 <fd_alloc>
  8022f1:	83 c4 10             	add    $0x10,%esp
  8022f4:	85 c0                	test   %eax,%eax
  8022f6:	78 3a                	js     802332 <opencons+0x50>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8022f8:	83 ec 04             	sub    $0x4,%esp
  8022fb:	68 07 04 00 00       	push   $0x407
  802300:	ff 75 f4             	pushl  -0xc(%ebp)
  802303:	6a 00                	push   $0x0
  802305:	e8 aa e9 ff ff       	call   800cb4 <sys_page_alloc>
  80230a:	83 c4 10             	add    $0x10,%esp
  80230d:	85 c0                	test   %eax,%eax
  80230f:	78 21                	js     802332 <opencons+0x50>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  802311:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  802317:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80231a:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80231c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80231f:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  802326:	83 ec 0c             	sub    $0xc,%esp
  802329:	50                   	push   %eax
  80232a:	e8 ed ea ff ff       	call   800e1c <fd2num>
  80232f:	83 c4 10             	add    $0x10,%esp
}
  802332:	c9                   	leave  
  802333:	c3                   	ret    

00802334 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802334:	55                   	push   %ebp
  802335:	89 e5                	mov    %esp,%ebp
  802337:	56                   	push   %esi
  802338:	53                   	push   %ebx
  802339:	8b 75 08             	mov    0x8(%ebp),%esi
  80233c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80233f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// cprintf("0x%x 0x%x 0x%x\n", (uint32_t)from_env_store, (uint32_t)pg, (uint32_t)perm_store);
	int r;
	if (pg != NULL) {
  802342:	85 c0                	test   %eax,%eax
  802344:	74 0e                	je     802354 <ipc_recv+0x20>
		r = sys_ipc_recv(pg);
  802346:	83 ec 0c             	sub    $0xc,%esp
  802349:	50                   	push   %eax
  80234a:	e8 60 ea ff ff       	call   800daf <sys_ipc_recv>
  80234f:	83 c4 10             	add    $0x10,%esp
  802352:	eb 10                	jmp    802364 <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv((void *)UTOP);
  802354:	83 ec 0c             	sub    $0xc,%esp
  802357:	68 00 00 c0 ee       	push   $0xeec00000
  80235c:	e8 4e ea ff ff       	call   800daf <sys_ipc_recv>
  802361:	83 c4 10             	add    $0x10,%esp
	}

	if (r == 0) {
  802364:	85 c0                	test   %eax,%eax
  802366:	75 26                	jne    80238e <ipc_recv+0x5a>
		if (from_env_store != NULL) *from_env_store = thisenv->env_ipc_from;
  802368:	85 f6                	test   %esi,%esi
  80236a:	74 0a                	je     802376 <ipc_recv+0x42>
  80236c:	a1 04 40 80 00       	mov    0x804004,%eax
  802371:	8b 40 74             	mov    0x74(%eax),%eax
  802374:	89 06                	mov    %eax,(%esi)
		if (perm_store != NULL) *perm_store = thisenv->env_ipc_perm;
  802376:	85 db                	test   %ebx,%ebx
  802378:	74 0a                	je     802384 <ipc_recv+0x50>
  80237a:	a1 04 40 80 00       	mov    0x804004,%eax
  80237f:	8b 40 78             	mov    0x78(%eax),%eax
  802382:	89 03                	mov    %eax,(%ebx)
		return thisenv->env_ipc_value;
  802384:	a1 04 40 80 00       	mov    0x804004,%eax
  802389:	8b 40 70             	mov    0x70(%eax),%eax
  80238c:	eb 14                	jmp    8023a2 <ipc_recv+0x6e>
	} else {
		// fails;
		if (from_env_store != NULL) *from_env_store = 0;
  80238e:	85 f6                	test   %esi,%esi
  802390:	74 06                	je     802398 <ipc_recv+0x64>
  802392:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if (perm_store != NULL) *perm_store = 0;
  802398:	85 db                	test   %ebx,%ebx
  80239a:	74 06                	je     8023a2 <ipc_recv+0x6e>
  80239c:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		return r;
	}
}
  8023a2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8023a5:	5b                   	pop    %ebx
  8023a6:	5e                   	pop    %esi
  8023a7:	c9                   	leave  
  8023a8:	c3                   	ret    

008023a9 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8023a9:	55                   	push   %ebp
  8023aa:	89 e5                	mov    %esp,%ebp
  8023ac:	57                   	push   %edi
  8023ad:	56                   	push   %esi
  8023ae:	53                   	push   %ebx
  8023af:	83 ec 0c             	sub    $0xc,%esp
  8023b2:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8023b5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8023b8:	8b 75 14             	mov    0x14(%ebp),%esi
	// LAB 4: Your code here.
	// int sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
	int r;
	if (pg == NULL) pg = (void *)UTOP;
  8023bb:	85 db                	test   %ebx,%ebx
  8023bd:	75 25                	jne    8023e4 <ipc_send+0x3b>
  8023bf:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
  8023c4:	eb 1e                	jmp    8023e4 <ipc_send+0x3b>
	
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) != 0) {
		if (r == -E_IPC_NOT_RECV) {
  8023c6:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8023c9:	75 07                	jne    8023d2 <ipc_send+0x29>
			// cprintf("Try Again and Again....\n");
			sys_yield();
  8023cb:	e8 bd e8 ff ff       	call   800c8d <sys_yield>
  8023d0:	eb 12                	jmp    8023e4 <ipc_send+0x3b>
		} else {
			panic("ipc_send error %e\n", r);
  8023d2:	50                   	push   %eax
  8023d3:	68 cb 2c 80 00       	push   $0x802ccb
  8023d8:	6a 43                	push   $0x43
  8023da:	68 de 2c 80 00       	push   $0x802cde
  8023df:	e8 c0 dd ff ff       	call   8001a4 <_panic>
	// LAB 4: Your code here.
	// int sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
	int r;
	if (pg == NULL) pg = (void *)UTOP;
	
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) != 0) {
  8023e4:	56                   	push   %esi
  8023e5:	53                   	push   %ebx
  8023e6:	57                   	push   %edi
  8023e7:	ff 75 08             	pushl  0x8(%ebp)
  8023ea:	e8 9b e9 ff ff       	call   800d8a <sys_ipc_try_send>
  8023ef:	83 c4 10             	add    $0x10,%esp
  8023f2:	85 c0                	test   %eax,%eax
  8023f4:	75 d0                	jne    8023c6 <ipc_send+0x1d>
		} else {
			panic("ipc_send error %e\n", r);
		}
	}
	return;
}
  8023f6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8023f9:	5b                   	pop    %ebx
  8023fa:	5e                   	pop    %esi
  8023fb:	5f                   	pop    %edi
  8023fc:	c9                   	leave  
  8023fd:	c3                   	ret    

008023fe <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8023fe:	55                   	push   %ebp
  8023ff:	89 e5                	mov    %esp,%ebp
  802401:	53                   	push   %ebx
  802402:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  802405:	39 1d 50 00 c0 ee    	cmp    %ebx,0xeec00050
  80240b:	74 22                	je     80242f <ipc_find_env+0x31>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80240d:	b8 01 00 00 00       	mov    $0x1,%eax
		if (envs[i].env_type == type)
  802412:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  802419:	89 c2                	mov    %eax,%edx
  80241b:	c1 e2 07             	shl    $0x7,%edx
  80241e:	29 ca                	sub    %ecx,%edx
  802420:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802426:	8b 52 50             	mov    0x50(%edx),%edx
  802429:	39 da                	cmp    %ebx,%edx
  80242b:	75 1d                	jne    80244a <ipc_find_env+0x4c>
  80242d:	eb 05                	jmp    802434 <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80242f:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
			return envs[i].env_id;
  802434:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  80243b:	c1 e0 07             	shl    $0x7,%eax
  80243e:	29 d0                	sub    %edx,%eax
  802440:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  802445:	8b 40 40             	mov    0x40(%eax),%eax
  802448:	eb 0c                	jmp    802456 <ipc_find_env+0x58>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80244a:	40                   	inc    %eax
  80244b:	3d 00 04 00 00       	cmp    $0x400,%eax
  802450:	75 c0                	jne    802412 <ipc_find_env+0x14>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802452:	66 b8 00 00          	mov    $0x0,%ax
}
  802456:	5b                   	pop    %ebx
  802457:	c9                   	leave  
  802458:	c3                   	ret    
  802459:	00 00                	add    %al,(%eax)
	...

0080245c <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  80245c:	55                   	push   %ebp
  80245d:	89 e5                	mov    %esp,%ebp
  80245f:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802462:	89 c2                	mov    %eax,%edx
  802464:	c1 ea 16             	shr    $0x16,%edx
  802467:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80246e:	f6 c2 01             	test   $0x1,%dl
  802471:	74 1e                	je     802491 <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  802473:	c1 e8 0c             	shr    $0xc,%eax
  802476:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  80247d:	a8 01                	test   $0x1,%al
  80247f:	74 17                	je     802498 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802481:	c1 e8 0c             	shr    $0xc,%eax
  802484:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  80248b:	ef 
  80248c:	0f b7 c0             	movzwl %ax,%eax
  80248f:	eb 0c                	jmp    80249d <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  802491:	b8 00 00 00 00       	mov    $0x0,%eax
  802496:	eb 05                	jmp    80249d <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  802498:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  80249d:	c9                   	leave  
  80249e:	c3                   	ret    
	...

008024a0 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  8024a0:	55                   	push   %ebp
  8024a1:	89 e5                	mov    %esp,%ebp
  8024a3:	57                   	push   %edi
  8024a4:	56                   	push   %esi
  8024a5:	83 ec 10             	sub    $0x10,%esp
  8024a8:	8b 7d 08             	mov    0x8(%ebp),%edi
  8024ab:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  8024ae:	89 7d f0             	mov    %edi,-0x10(%ebp)
  8024b1:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  8024b4:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  8024b7:	8b 45 14             	mov    0x14(%ebp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  8024ba:	85 c0                	test   %eax,%eax
  8024bc:	75 2e                	jne    8024ec <__udivdi3+0x4c>
    {
      if (d0 > n1)
  8024be:	39 f1                	cmp    %esi,%ecx
  8024c0:	77 5a                	ja     80251c <__udivdi3+0x7c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  8024c2:	85 c9                	test   %ecx,%ecx
  8024c4:	75 0b                	jne    8024d1 <__udivdi3+0x31>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  8024c6:	b8 01 00 00 00       	mov    $0x1,%eax
  8024cb:	31 d2                	xor    %edx,%edx
  8024cd:	f7 f1                	div    %ecx
  8024cf:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  8024d1:	31 d2                	xor    %edx,%edx
  8024d3:	89 f0                	mov    %esi,%eax
  8024d5:	f7 f1                	div    %ecx
  8024d7:	89 c6                	mov    %eax,%esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8024d9:	89 f8                	mov    %edi,%eax
  8024db:	f7 f1                	div    %ecx
  8024dd:	89 c7                	mov    %eax,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  8024df:	89 f8                	mov    %edi,%eax
  8024e1:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  8024e3:	83 c4 10             	add    $0x10,%esp
  8024e6:	5e                   	pop    %esi
  8024e7:	5f                   	pop    %edi
  8024e8:	c9                   	leave  
  8024e9:	c3                   	ret    
  8024ea:	66 90                	xchg   %ax,%ax
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  8024ec:	39 f0                	cmp    %esi,%eax
  8024ee:	77 1c                	ja     80250c <__udivdi3+0x6c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  8024f0:	0f bd f8             	bsr    %eax,%edi
	  if (bm == 0)
  8024f3:	83 f7 1f             	xor    $0x1f,%edi
  8024f6:	75 3c                	jne    802534 <__udivdi3+0x94>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  8024f8:	39 f0                	cmp    %esi,%eax
  8024fa:	0f 82 90 00 00 00    	jb     802590 <__udivdi3+0xf0>
  802500:	8b 55 f0             	mov    -0x10(%ebp),%edx
  802503:	39 55 f4             	cmp    %edx,-0xc(%ebp)
  802506:	0f 86 84 00 00 00    	jbe    802590 <__udivdi3+0xf0>
  80250c:	31 f6                	xor    %esi,%esi
  80250e:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  802510:	89 f8                	mov    %edi,%eax
  802512:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802514:	83 c4 10             	add    $0x10,%esp
  802517:	5e                   	pop    %esi
  802518:	5f                   	pop    %edi
  802519:	c9                   	leave  
  80251a:	c3                   	ret    
  80251b:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  80251c:	89 f2                	mov    %esi,%edx
  80251e:	89 f8                	mov    %edi,%eax
  802520:	f7 f1                	div    %ecx
  802522:	89 c7                	mov    %eax,%edi
  802524:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  802526:	89 f8                	mov    %edi,%eax
  802528:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  80252a:	83 c4 10             	add    $0x10,%esp
  80252d:	5e                   	pop    %esi
  80252e:	5f                   	pop    %edi
  80252f:	c9                   	leave  
  802530:	c3                   	ret    
  802531:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  802534:	89 f9                	mov    %edi,%ecx
  802536:	d3 e0                	shl    %cl,%eax
  802538:	89 45 e8             	mov    %eax,-0x18(%ebp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  80253b:	b8 20 00 00 00       	mov    $0x20,%eax
  802540:	29 f8                	sub    %edi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  802542:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802545:	88 c1                	mov    %al,%cl
  802547:	d3 ea                	shr    %cl,%edx
  802549:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  80254c:	09 ca                	or     %ecx,%edx
  80254e:	89 55 ec             	mov    %edx,-0x14(%ebp)
	      d0 = d0 << bm;
  802551:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802554:	89 f9                	mov    %edi,%ecx
  802556:	d3 e2                	shl    %cl,%edx
  802558:	89 55 f4             	mov    %edx,-0xc(%ebp)
	      n2 = n1 >> b;
  80255b:	89 f2                	mov    %esi,%edx
  80255d:	88 c1                	mov    %al,%cl
  80255f:	d3 ea                	shr    %cl,%edx
  802561:	89 55 e8             	mov    %edx,-0x18(%ebp)
	      n1 = (n1 << bm) | (n0 >> b);
  802564:	89 f2                	mov    %esi,%edx
  802566:	89 f9                	mov    %edi,%ecx
  802568:	d3 e2                	shl    %cl,%edx
  80256a:	8b 75 f0             	mov    -0x10(%ebp),%esi
  80256d:	88 c1                	mov    %al,%cl
  80256f:	d3 ee                	shr    %cl,%esi
  802571:	09 d6                	or     %edx,%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  802573:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  802576:	89 f0                	mov    %esi,%eax
  802578:	89 ca                	mov    %ecx,%edx
  80257a:	f7 75 ec             	divl   -0x14(%ebp)
  80257d:	89 d1                	mov    %edx,%ecx
  80257f:	89 c6                	mov    %eax,%esi
	      umul_ppmm (m1, m0, q0, d0);
  802581:	f7 65 f4             	mull   -0xc(%ebp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802584:	39 d1                	cmp    %edx,%ecx
  802586:	72 28                	jb     8025b0 <__udivdi3+0x110>
  802588:	74 1a                	je     8025a4 <__udivdi3+0x104>
  80258a:	89 f7                	mov    %esi,%edi
  80258c:	31 f6                	xor    %esi,%esi
  80258e:	eb 80                	jmp    802510 <__udivdi3+0x70>
	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  802590:	31 f6                	xor    %esi,%esi
  802592:	bf 01 00 00 00       	mov    $0x1,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  802597:	89 f8                	mov    %edi,%eax
  802599:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  80259b:	83 c4 10             	add    $0x10,%esp
  80259e:	5e                   	pop    %esi
  80259f:	5f                   	pop    %edi
  8025a0:	c9                   	leave  
  8025a1:	c3                   	ret    
  8025a2:	66 90                	xchg   %ax,%ax

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  8025a4:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8025a7:	89 f9                	mov    %edi,%ecx
  8025a9:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8025ab:	39 c2                	cmp    %eax,%edx
  8025ad:	73 db                	jae    80258a <__udivdi3+0xea>
  8025af:	90                   	nop
		{
		  q0--;
  8025b0:	8d 7e ff             	lea    -0x1(%esi),%edi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  8025b3:	31 f6                	xor    %esi,%esi
  8025b5:	e9 56 ff ff ff       	jmp    802510 <__udivdi3+0x70>
	...

008025bc <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  8025bc:	55                   	push   %ebp
  8025bd:	89 e5                	mov    %esp,%ebp
  8025bf:	57                   	push   %edi
  8025c0:	56                   	push   %esi
  8025c1:	83 ec 20             	sub    $0x20,%esp
  8025c4:	8b 45 08             	mov    0x8(%ebp),%eax
  8025c7:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  8025ca:	89 45 e8             	mov    %eax,-0x18(%ebp)
  8025cd:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  8025d0:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  8025d3:	8b 7d 14             	mov    0x14(%ebp),%edi
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  8025d6:	89 45 f0             	mov    %eax,-0x10(%ebp)
  n1 = nn.s.high;
  8025d9:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  8025db:	85 ff                	test   %edi,%edi
  8025dd:	75 15                	jne    8025f4 <__umoddi3+0x38>
    {
      if (d0 > n1)
  8025df:	39 f1                	cmp    %esi,%ecx
  8025e1:	0f 86 99 00 00 00    	jbe    802680 <__umoddi3+0xc4>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8025e7:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  8025e9:	89 d0                	mov    %edx,%eax
  8025eb:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8025ed:	83 c4 20             	add    $0x20,%esp
  8025f0:	5e                   	pop    %esi
  8025f1:	5f                   	pop    %edi
  8025f2:	c9                   	leave  
  8025f3:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  8025f4:	39 f7                	cmp    %esi,%edi
  8025f6:	0f 87 a4 00 00 00    	ja     8026a0 <__umoddi3+0xe4>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  8025fc:	0f bd c7             	bsr    %edi,%eax
	  if (bm == 0)
  8025ff:	83 f0 1f             	xor    $0x1f,%eax
  802602:	89 45 ec             	mov    %eax,-0x14(%ebp)
  802605:	0f 84 a1 00 00 00    	je     8026ac <__umoddi3+0xf0>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  80260b:	89 f8                	mov    %edi,%eax
  80260d:	8a 4d ec             	mov    -0x14(%ebp),%cl
  802610:	d3 e0                	shl    %cl,%eax
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  802612:	bf 20 00 00 00       	mov    $0x20,%edi
  802617:	2b 7d ec             	sub    -0x14(%ebp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  80261a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80261d:	89 f9                	mov    %edi,%ecx
  80261f:	d3 ea                	shr    %cl,%edx
  802621:	09 c2                	or     %eax,%edx
  802623:	89 55 f0             	mov    %edx,-0x10(%ebp)
	      d0 = d0 << bm;
  802626:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802629:	8a 4d ec             	mov    -0x14(%ebp),%cl
  80262c:	d3 e0                	shl    %cl,%eax
  80262e:	89 45 f4             	mov    %eax,-0xc(%ebp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  802631:	89 f2                	mov    %esi,%edx
  802633:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  802635:	8b 45 e8             	mov    -0x18(%ebp),%eax
  802638:	d3 e0                	shl    %cl,%eax
  80263a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  80263d:	8b 45 e8             	mov    -0x18(%ebp),%eax
  802640:	89 f9                	mov    %edi,%ecx
  802642:	d3 e8                	shr    %cl,%eax
  802644:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  802646:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  802648:	89 f2                	mov    %esi,%edx
  80264a:	f7 75 f0             	divl   -0x10(%ebp)
  80264d:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  80264f:	f7 65 f4             	mull   -0xc(%ebp)
  802652:	89 55 e8             	mov    %edx,-0x18(%ebp)
  802655:	89 c1                	mov    %eax,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802657:	39 d6                	cmp    %edx,%esi
  802659:	72 71                	jb     8026cc <__umoddi3+0x110>
  80265b:	74 7f                	je     8026dc <__umoddi3+0x120>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  80265d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802660:	29 c8                	sub    %ecx,%eax
  802662:	19 d6                	sbb    %edx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  802664:	8a 4d ec             	mov    -0x14(%ebp),%cl
  802667:	d3 e8                	shr    %cl,%eax
  802669:	89 f2                	mov    %esi,%edx
  80266b:	89 f9                	mov    %edi,%ecx
  80266d:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  80266f:	09 d0                	or     %edx,%eax
  802671:	89 f2                	mov    %esi,%edx
  802673:	8a 4d ec             	mov    -0x14(%ebp),%cl
  802676:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802678:	83 c4 20             	add    $0x20,%esp
  80267b:	5e                   	pop    %esi
  80267c:	5f                   	pop    %edi
  80267d:	c9                   	leave  
  80267e:	c3                   	ret    
  80267f:	90                   	nop
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  802680:	85 c9                	test   %ecx,%ecx
  802682:	75 0b                	jne    80268f <__umoddi3+0xd3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  802684:	b8 01 00 00 00       	mov    $0x1,%eax
  802689:	31 d2                	xor    %edx,%edx
  80268b:	f7 f1                	div    %ecx
  80268d:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  80268f:	89 f0                	mov    %esi,%eax
  802691:	31 d2                	xor    %edx,%edx
  802693:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802695:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802698:	f7 f1                	div    %ecx
  80269a:	e9 4a ff ff ff       	jmp    8025e9 <__umoddi3+0x2d>
  80269f:	90                   	nop
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  8026a0:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8026a2:	83 c4 20             	add    $0x20,%esp
  8026a5:	5e                   	pop    %esi
  8026a6:	5f                   	pop    %edi
  8026a7:	c9                   	leave  
  8026a8:	c3                   	ret    
  8026a9:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  8026ac:	39 f7                	cmp    %esi,%edi
  8026ae:	72 05                	jb     8026b5 <__umoddi3+0xf9>
  8026b0:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
  8026b3:	77 0c                	ja     8026c1 <__umoddi3+0x105>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  8026b5:	89 f2                	mov    %esi,%edx
  8026b7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8026ba:	29 c8                	sub    %ecx,%eax
  8026bc:	19 fa                	sbb    %edi,%edx
  8026be:	89 45 f0             	mov    %eax,-0x10(%ebp)

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  8026c1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8026c4:	83 c4 20             	add    $0x20,%esp
  8026c7:	5e                   	pop    %esi
  8026c8:	5f                   	pop    %edi
  8026c9:	c9                   	leave  
  8026ca:	c3                   	ret    
  8026cb:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  8026cc:	8b 55 e8             	mov    -0x18(%ebp),%edx
  8026cf:	89 c1                	mov    %eax,%ecx
  8026d1:	2b 4d f4             	sub    -0xc(%ebp),%ecx
  8026d4:	1b 55 f0             	sbb    -0x10(%ebp),%edx
  8026d7:	eb 84                	jmp    80265d <__umoddi3+0xa1>
  8026d9:	8d 76 00             	lea    0x0(%esi),%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8026dc:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  8026df:	72 eb                	jb     8026cc <__umoddi3+0x110>
  8026e1:	89 f2                	mov    %esi,%edx
  8026e3:	e9 75 ff ff ff       	jmp    80265d <__umoddi3+0xa1>
