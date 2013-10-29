
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
  80003f:	c7 05 00 30 80 00 60 	movl   $0x802460,0x803000
  800046:	24 80 00 

	cprintf("icode startup\n");
  800049:	68 66 24 80 00       	push   $0x802466
  80004e:	e8 29 02 00 00       	call   80027c <cprintf>

	cprintf("icode: open /motd\n");
  800053:	c7 04 24 75 24 80 00 	movl   $0x802475,(%esp)
  80005a:	e8 1d 02 00 00       	call   80027c <cprintf>
	if ((fd = open("/motd", O_RDONLY)) < 0)
  80005f:	83 c4 08             	add    $0x8,%esp
  800062:	6a 00                	push   $0x0
  800064:	68 88 24 80 00       	push   $0x802488
  800069:	e8 b9 14 00 00       	call   801527 <open>
  80006e:	89 c6                	mov    %eax,%esi
  800070:	83 c4 10             	add    $0x10,%esp
  800073:	85 c0                	test   %eax,%eax
  800075:	79 12                	jns    800089 <umain+0x55>
		panic("icode: open /motd: %e", fd);
  800077:	50                   	push   %eax
  800078:	68 8e 24 80 00       	push   $0x80248e
  80007d:	6a 0f                	push   $0xf
  80007f:	68 a4 24 80 00       	push   $0x8024a4
  800084:	e8 1b 01 00 00       	call   8001a4 <_panic>

	cprintf("icode: read /motd\n");
  800089:	83 ec 0c             	sub    $0xc,%esp
  80008c:	68 b1 24 80 00       	push   $0x8024b1
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
  8000b8:	e8 53 10 00 00       	call   801110 <read>
  8000bd:	83 c4 10             	add    $0x10,%esp
  8000c0:	85 c0                	test   %eax,%eax
  8000c2:	7f dd                	jg     8000a1 <umain+0x6d>
		sys_cputs(buf, n);

	cprintf("icode: close /motd\n");
  8000c4:	83 ec 0c             	sub    $0xc,%esp
  8000c7:	68 c4 24 80 00       	push   $0x8024c4
  8000cc:	e8 ab 01 00 00       	call   80027c <cprintf>
	close(fd);
  8000d1:	89 34 24             	mov    %esi,(%esp)
  8000d4:	e8 fa 0e 00 00       	call   800fd3 <close>

	cprintf("icode: spawn /init\n");
  8000d9:	c7 04 24 d8 24 80 00 	movl   $0x8024d8,(%esp)
  8000e0:	e8 97 01 00 00       	call   80027c <cprintf>
	if ((r = spawnl("/init", "init", "initarg1", "initarg2", (char*)0)) < 0)
  8000e5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000ec:	68 ec 24 80 00       	push   $0x8024ec
  8000f1:	68 f5 24 80 00       	push   $0x8024f5
  8000f6:	68 ff 24 80 00       	push   $0x8024ff
  8000fb:	68 fe 24 80 00       	push   $0x8024fe
  800100:	e8 e2 19 00 00       	call   801ae7 <spawnl>
  800105:	83 c4 20             	add    $0x20,%esp
  800108:	85 c0                	test   %eax,%eax
  80010a:	79 12                	jns    80011e <umain+0xea>
		panic("icode: spawn /init: %e", r);
  80010c:	50                   	push   %eax
  80010d:	68 04 25 80 00       	push   $0x802504
  800112:	6a 1a                	push   $0x1a
  800114:	68 a4 24 80 00       	push   $0x8024a4
  800119:	e8 86 00 00 00       	call   8001a4 <_panic>

	cprintf("icode: exiting\n");
  80011e:	83 ec 0c             	sub    $0xc,%esp
  800121:	68 1b 25 80 00       	push   $0x80251b
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
  80018e:	e8 6b 0e 00 00       	call   800ffe <close_all>
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
  8001c2:	68 38 25 80 00       	push   $0x802538
  8001c7:	e8 b0 00 00 00       	call   80027c <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8001cc:	83 c4 18             	add    $0x18,%esp
  8001cf:	56                   	push   %esi
  8001d0:	ff 75 10             	pushl  0x10(%ebp)
  8001d3:	e8 53 00 00 00       	call   80022b <vcprintf>
	cprintf("\n");
  8001d8:	c7 04 24 55 29 80 00 	movl   $0x802955,(%esp)
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
  8002e4:	e8 27 1f 00 00       	call   802210 <__udivdi3>
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
  800320:	e8 07 20 00 00       	call   80232c <__umoddi3>
  800325:	83 c4 14             	add    $0x14,%esp
  800328:	0f be 80 5b 25 80 00 	movsbl 0x80255b(%eax),%eax
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
  80046c:	ff 24 85 a0 26 80 00 	jmp    *0x8026a0(,%eax,4)
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
  800518:	8b 04 85 00 28 80 00 	mov    0x802800(,%eax,4),%eax
  80051f:	85 c0                	test   %eax,%eax
  800521:	75 1a                	jne    80053d <vprintfmt+0x15c>
				printfmt(putch, putdat, "error %d", err);
  800523:	52                   	push   %edx
  800524:	68 73 25 80 00       	push   $0x802573
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
  80053e:	68 37 29 80 00       	push   $0x802937
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
  800574:	c7 45 d0 6c 25 80 00 	movl   $0x80256c,-0x30(%ebp)
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
  800be2:	68 5f 28 80 00       	push   $0x80285f
  800be7:	6a 42                	push   $0x42
  800be9:	68 7c 28 80 00       	push   $0x80287c
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

00800df4 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800df4:	55                   	push   %ebp
  800df5:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800df7:	8b 45 08             	mov    0x8(%ebp),%eax
  800dfa:	05 00 00 00 30       	add    $0x30000000,%eax
  800dff:	c1 e8 0c             	shr    $0xc,%eax
}
  800e02:	c9                   	leave  
  800e03:	c3                   	ret    

00800e04 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800e04:	55                   	push   %ebp
  800e05:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800e07:	ff 75 08             	pushl  0x8(%ebp)
  800e0a:	e8 e5 ff ff ff       	call   800df4 <fd2num>
  800e0f:	83 c4 04             	add    $0x4,%esp
  800e12:	05 20 00 0d 00       	add    $0xd0020,%eax
  800e17:	c1 e0 0c             	shl    $0xc,%eax
}
  800e1a:	c9                   	leave  
  800e1b:	c3                   	ret    

00800e1c <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800e1c:	55                   	push   %ebp
  800e1d:	89 e5                	mov    %esp,%ebp
  800e1f:	53                   	push   %ebx
  800e20:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800e23:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  800e28:	a8 01                	test   $0x1,%al
  800e2a:	74 34                	je     800e60 <fd_alloc+0x44>
  800e2c:	a1 00 00 74 ef       	mov    0xef740000,%eax
  800e31:	a8 01                	test   $0x1,%al
  800e33:	74 32                	je     800e67 <fd_alloc+0x4b>
  800e35:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
  800e3a:	89 c1                	mov    %eax,%ecx
  800e3c:	89 c2                	mov    %eax,%edx
  800e3e:	c1 ea 16             	shr    $0x16,%edx
  800e41:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800e48:	f6 c2 01             	test   $0x1,%dl
  800e4b:	74 1f                	je     800e6c <fd_alloc+0x50>
  800e4d:	89 c2                	mov    %eax,%edx
  800e4f:	c1 ea 0c             	shr    $0xc,%edx
  800e52:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e59:	f6 c2 01             	test   $0x1,%dl
  800e5c:	75 17                	jne    800e75 <fd_alloc+0x59>
  800e5e:	eb 0c                	jmp    800e6c <fd_alloc+0x50>
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  800e60:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
  800e65:	eb 05                	jmp    800e6c <fd_alloc+0x50>
  800e67:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
  800e6c:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  800e6e:	b8 00 00 00 00       	mov    $0x0,%eax
  800e73:	eb 17                	jmp    800e8c <fd_alloc+0x70>
  800e75:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800e7a:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800e7f:	75 b9                	jne    800e3a <fd_alloc+0x1e>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800e81:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  800e87:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800e8c:	5b                   	pop    %ebx
  800e8d:	c9                   	leave  
  800e8e:	c3                   	ret    

00800e8f <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800e8f:	55                   	push   %ebp
  800e90:	89 e5                	mov    %esp,%ebp
  800e92:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800e95:	83 f8 1f             	cmp    $0x1f,%eax
  800e98:	77 36                	ja     800ed0 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800e9a:	05 00 00 0d 00       	add    $0xd0000,%eax
  800e9f:	c1 e0 0c             	shl    $0xc,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800ea2:	89 c2                	mov    %eax,%edx
  800ea4:	c1 ea 16             	shr    $0x16,%edx
  800ea7:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800eae:	f6 c2 01             	test   $0x1,%dl
  800eb1:	74 24                	je     800ed7 <fd_lookup+0x48>
  800eb3:	89 c2                	mov    %eax,%edx
  800eb5:	c1 ea 0c             	shr    $0xc,%edx
  800eb8:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800ebf:	f6 c2 01             	test   $0x1,%dl
  800ec2:	74 1a                	je     800ede <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800ec4:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ec7:	89 02                	mov    %eax,(%edx)
	return 0;
  800ec9:	b8 00 00 00 00       	mov    $0x0,%eax
  800ece:	eb 13                	jmp    800ee3 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800ed0:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800ed5:	eb 0c                	jmp    800ee3 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800ed7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800edc:	eb 05                	jmp    800ee3 <fd_lookup+0x54>
  800ede:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800ee3:	c9                   	leave  
  800ee4:	c3                   	ret    

00800ee5 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800ee5:	55                   	push   %ebp
  800ee6:	89 e5                	mov    %esp,%ebp
  800ee8:	53                   	push   %ebx
  800ee9:	83 ec 04             	sub    $0x4,%esp
  800eec:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800eef:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  800ef2:	39 0d 04 30 80 00    	cmp    %ecx,0x803004
  800ef8:	74 0d                	je     800f07 <dev_lookup+0x22>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800efa:	b8 00 00 00 00       	mov    $0x0,%eax
  800eff:	eb 14                	jmp    800f15 <dev_lookup+0x30>
		if (devtab[i]->dev_id == dev_id) {
  800f01:	39 0a                	cmp    %ecx,(%edx)
  800f03:	75 10                	jne    800f15 <dev_lookup+0x30>
  800f05:	eb 05                	jmp    800f0c <dev_lookup+0x27>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800f07:	ba 04 30 80 00       	mov    $0x803004,%edx
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
  800f0c:	89 13                	mov    %edx,(%ebx)
			return 0;
  800f0e:	b8 00 00 00 00       	mov    $0x0,%eax
  800f13:	eb 31                	jmp    800f46 <dev_lookup+0x61>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800f15:	40                   	inc    %eax
  800f16:	8b 14 85 08 29 80 00 	mov    0x802908(,%eax,4),%edx
  800f1d:	85 d2                	test   %edx,%edx
  800f1f:	75 e0                	jne    800f01 <dev_lookup+0x1c>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800f21:	a1 04 40 80 00       	mov    0x804004,%eax
  800f26:	8b 40 48             	mov    0x48(%eax),%eax
  800f29:	83 ec 04             	sub    $0x4,%esp
  800f2c:	51                   	push   %ecx
  800f2d:	50                   	push   %eax
  800f2e:	68 8c 28 80 00       	push   $0x80288c
  800f33:	e8 44 f3 ff ff       	call   80027c <cprintf>
	*dev = 0;
  800f38:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  800f3e:	83 c4 10             	add    $0x10,%esp
  800f41:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800f46:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f49:	c9                   	leave  
  800f4a:	c3                   	ret    

00800f4b <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800f4b:	55                   	push   %ebp
  800f4c:	89 e5                	mov    %esp,%ebp
  800f4e:	56                   	push   %esi
  800f4f:	53                   	push   %ebx
  800f50:	83 ec 20             	sub    $0x20,%esp
  800f53:	8b 75 08             	mov    0x8(%ebp),%esi
  800f56:	8a 45 0c             	mov    0xc(%ebp),%al
  800f59:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800f5c:	56                   	push   %esi
  800f5d:	e8 92 fe ff ff       	call   800df4 <fd2num>
  800f62:	8d 55 f4             	lea    -0xc(%ebp),%edx
  800f65:	89 14 24             	mov    %edx,(%esp)
  800f68:	50                   	push   %eax
  800f69:	e8 21 ff ff ff       	call   800e8f <fd_lookup>
  800f6e:	89 c3                	mov    %eax,%ebx
  800f70:	83 c4 08             	add    $0x8,%esp
  800f73:	85 c0                	test   %eax,%eax
  800f75:	78 05                	js     800f7c <fd_close+0x31>
	    || fd != fd2)
  800f77:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800f7a:	74 0d                	je     800f89 <fd_close+0x3e>
		return (must_exist ? r : 0);
  800f7c:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  800f80:	75 48                	jne    800fca <fd_close+0x7f>
  800f82:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f87:	eb 41                	jmp    800fca <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800f89:	83 ec 08             	sub    $0x8,%esp
  800f8c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800f8f:	50                   	push   %eax
  800f90:	ff 36                	pushl  (%esi)
  800f92:	e8 4e ff ff ff       	call   800ee5 <dev_lookup>
  800f97:	89 c3                	mov    %eax,%ebx
  800f99:	83 c4 10             	add    $0x10,%esp
  800f9c:	85 c0                	test   %eax,%eax
  800f9e:	78 1c                	js     800fbc <fd_close+0x71>
		if (dev->dev_close)
  800fa0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800fa3:	8b 40 10             	mov    0x10(%eax),%eax
  800fa6:	85 c0                	test   %eax,%eax
  800fa8:	74 0d                	je     800fb7 <fd_close+0x6c>
			r = (*dev->dev_close)(fd);
  800faa:	83 ec 0c             	sub    $0xc,%esp
  800fad:	56                   	push   %esi
  800fae:	ff d0                	call   *%eax
  800fb0:	89 c3                	mov    %eax,%ebx
  800fb2:	83 c4 10             	add    $0x10,%esp
  800fb5:	eb 05                	jmp    800fbc <fd_close+0x71>
		else
			r = 0;
  800fb7:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800fbc:	83 ec 08             	sub    $0x8,%esp
  800fbf:	56                   	push   %esi
  800fc0:	6a 00                	push   $0x0
  800fc2:	e8 37 fd ff ff       	call   800cfe <sys_page_unmap>
	return r;
  800fc7:	83 c4 10             	add    $0x10,%esp
}
  800fca:	89 d8                	mov    %ebx,%eax
  800fcc:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800fcf:	5b                   	pop    %ebx
  800fd0:	5e                   	pop    %esi
  800fd1:	c9                   	leave  
  800fd2:	c3                   	ret    

00800fd3 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800fd3:	55                   	push   %ebp
  800fd4:	89 e5                	mov    %esp,%ebp
  800fd6:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800fd9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fdc:	50                   	push   %eax
  800fdd:	ff 75 08             	pushl  0x8(%ebp)
  800fe0:	e8 aa fe ff ff       	call   800e8f <fd_lookup>
  800fe5:	83 c4 08             	add    $0x8,%esp
  800fe8:	85 c0                	test   %eax,%eax
  800fea:	78 10                	js     800ffc <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800fec:	83 ec 08             	sub    $0x8,%esp
  800fef:	6a 01                	push   $0x1
  800ff1:	ff 75 f4             	pushl  -0xc(%ebp)
  800ff4:	e8 52 ff ff ff       	call   800f4b <fd_close>
  800ff9:	83 c4 10             	add    $0x10,%esp
}
  800ffc:	c9                   	leave  
  800ffd:	c3                   	ret    

00800ffe <close_all>:

void
close_all(void)
{
  800ffe:	55                   	push   %ebp
  800fff:	89 e5                	mov    %esp,%ebp
  801001:	53                   	push   %ebx
  801002:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801005:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80100a:	83 ec 0c             	sub    $0xc,%esp
  80100d:	53                   	push   %ebx
  80100e:	e8 c0 ff ff ff       	call   800fd3 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801013:	43                   	inc    %ebx
  801014:	83 c4 10             	add    $0x10,%esp
  801017:	83 fb 20             	cmp    $0x20,%ebx
  80101a:	75 ee                	jne    80100a <close_all+0xc>
		close(i);
}
  80101c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80101f:	c9                   	leave  
  801020:	c3                   	ret    

00801021 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801021:	55                   	push   %ebp
  801022:	89 e5                	mov    %esp,%ebp
  801024:	57                   	push   %edi
  801025:	56                   	push   %esi
  801026:	53                   	push   %ebx
  801027:	83 ec 2c             	sub    $0x2c,%esp
  80102a:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80102d:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801030:	50                   	push   %eax
  801031:	ff 75 08             	pushl  0x8(%ebp)
  801034:	e8 56 fe ff ff       	call   800e8f <fd_lookup>
  801039:	89 c3                	mov    %eax,%ebx
  80103b:	83 c4 08             	add    $0x8,%esp
  80103e:	85 c0                	test   %eax,%eax
  801040:	0f 88 c0 00 00 00    	js     801106 <dup+0xe5>
		return r;
	close(newfdnum);
  801046:	83 ec 0c             	sub    $0xc,%esp
  801049:	57                   	push   %edi
  80104a:	e8 84 ff ff ff       	call   800fd3 <close>

	newfd = INDEX2FD(newfdnum);
  80104f:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  801055:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  801058:	83 c4 04             	add    $0x4,%esp
  80105b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80105e:	e8 a1 fd ff ff       	call   800e04 <fd2data>
  801063:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801065:	89 34 24             	mov    %esi,(%esp)
  801068:	e8 97 fd ff ff       	call   800e04 <fd2data>
  80106d:	83 c4 10             	add    $0x10,%esp
  801070:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801073:	89 d8                	mov    %ebx,%eax
  801075:	c1 e8 16             	shr    $0x16,%eax
  801078:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80107f:	a8 01                	test   $0x1,%al
  801081:	74 37                	je     8010ba <dup+0x99>
  801083:	89 d8                	mov    %ebx,%eax
  801085:	c1 e8 0c             	shr    $0xc,%eax
  801088:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80108f:	f6 c2 01             	test   $0x1,%dl
  801092:	74 26                	je     8010ba <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801094:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80109b:	83 ec 0c             	sub    $0xc,%esp
  80109e:	25 07 0e 00 00       	and    $0xe07,%eax
  8010a3:	50                   	push   %eax
  8010a4:	ff 75 d4             	pushl  -0x2c(%ebp)
  8010a7:	6a 00                	push   $0x0
  8010a9:	53                   	push   %ebx
  8010aa:	6a 00                	push   $0x0
  8010ac:	e8 27 fc ff ff       	call   800cd8 <sys_page_map>
  8010b1:	89 c3                	mov    %eax,%ebx
  8010b3:	83 c4 20             	add    $0x20,%esp
  8010b6:	85 c0                	test   %eax,%eax
  8010b8:	78 2d                	js     8010e7 <dup+0xc6>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8010ba:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8010bd:	89 c2                	mov    %eax,%edx
  8010bf:	c1 ea 0c             	shr    $0xc,%edx
  8010c2:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8010c9:	83 ec 0c             	sub    $0xc,%esp
  8010cc:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  8010d2:	52                   	push   %edx
  8010d3:	56                   	push   %esi
  8010d4:	6a 00                	push   $0x0
  8010d6:	50                   	push   %eax
  8010d7:	6a 00                	push   $0x0
  8010d9:	e8 fa fb ff ff       	call   800cd8 <sys_page_map>
  8010de:	89 c3                	mov    %eax,%ebx
  8010e0:	83 c4 20             	add    $0x20,%esp
  8010e3:	85 c0                	test   %eax,%eax
  8010e5:	79 1d                	jns    801104 <dup+0xe3>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8010e7:	83 ec 08             	sub    $0x8,%esp
  8010ea:	56                   	push   %esi
  8010eb:	6a 00                	push   $0x0
  8010ed:	e8 0c fc ff ff       	call   800cfe <sys_page_unmap>
	sys_page_unmap(0, nva);
  8010f2:	83 c4 08             	add    $0x8,%esp
  8010f5:	ff 75 d4             	pushl  -0x2c(%ebp)
  8010f8:	6a 00                	push   $0x0
  8010fa:	e8 ff fb ff ff       	call   800cfe <sys_page_unmap>
	return r;
  8010ff:	83 c4 10             	add    $0x10,%esp
  801102:	eb 02                	jmp    801106 <dup+0xe5>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  801104:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  801106:	89 d8                	mov    %ebx,%eax
  801108:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80110b:	5b                   	pop    %ebx
  80110c:	5e                   	pop    %esi
  80110d:	5f                   	pop    %edi
  80110e:	c9                   	leave  
  80110f:	c3                   	ret    

00801110 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801110:	55                   	push   %ebp
  801111:	89 e5                	mov    %esp,%ebp
  801113:	53                   	push   %ebx
  801114:	83 ec 14             	sub    $0x14,%esp
  801117:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80111a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80111d:	50                   	push   %eax
  80111e:	53                   	push   %ebx
  80111f:	e8 6b fd ff ff       	call   800e8f <fd_lookup>
  801124:	83 c4 08             	add    $0x8,%esp
  801127:	85 c0                	test   %eax,%eax
  801129:	78 67                	js     801192 <read+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80112b:	83 ec 08             	sub    $0x8,%esp
  80112e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801131:	50                   	push   %eax
  801132:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801135:	ff 30                	pushl  (%eax)
  801137:	e8 a9 fd ff ff       	call   800ee5 <dev_lookup>
  80113c:	83 c4 10             	add    $0x10,%esp
  80113f:	85 c0                	test   %eax,%eax
  801141:	78 4f                	js     801192 <read+0x82>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801143:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801146:	8b 50 08             	mov    0x8(%eax),%edx
  801149:	83 e2 03             	and    $0x3,%edx
  80114c:	83 fa 01             	cmp    $0x1,%edx
  80114f:	75 21                	jne    801172 <read+0x62>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801151:	a1 04 40 80 00       	mov    0x804004,%eax
  801156:	8b 40 48             	mov    0x48(%eax),%eax
  801159:	83 ec 04             	sub    $0x4,%esp
  80115c:	53                   	push   %ebx
  80115d:	50                   	push   %eax
  80115e:	68 cd 28 80 00       	push   $0x8028cd
  801163:	e8 14 f1 ff ff       	call   80027c <cprintf>
		return -E_INVAL;
  801168:	83 c4 10             	add    $0x10,%esp
  80116b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801170:	eb 20                	jmp    801192 <read+0x82>
	}
	if (!dev->dev_read)
  801172:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801175:	8b 52 08             	mov    0x8(%edx),%edx
  801178:	85 d2                	test   %edx,%edx
  80117a:	74 11                	je     80118d <read+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80117c:	83 ec 04             	sub    $0x4,%esp
  80117f:	ff 75 10             	pushl  0x10(%ebp)
  801182:	ff 75 0c             	pushl  0xc(%ebp)
  801185:	50                   	push   %eax
  801186:	ff d2                	call   *%edx
  801188:	83 c4 10             	add    $0x10,%esp
  80118b:	eb 05                	jmp    801192 <read+0x82>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80118d:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  801192:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801195:	c9                   	leave  
  801196:	c3                   	ret    

00801197 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801197:	55                   	push   %ebp
  801198:	89 e5                	mov    %esp,%ebp
  80119a:	57                   	push   %edi
  80119b:	56                   	push   %esi
  80119c:	53                   	push   %ebx
  80119d:	83 ec 0c             	sub    $0xc,%esp
  8011a0:	8b 7d 08             	mov    0x8(%ebp),%edi
  8011a3:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8011a6:	85 f6                	test   %esi,%esi
  8011a8:	74 31                	je     8011db <readn+0x44>
  8011aa:	b8 00 00 00 00       	mov    $0x0,%eax
  8011af:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = read(fdnum, (char*)buf + tot, n - tot);
  8011b4:	83 ec 04             	sub    $0x4,%esp
  8011b7:	89 f2                	mov    %esi,%edx
  8011b9:	29 c2                	sub    %eax,%edx
  8011bb:	52                   	push   %edx
  8011bc:	03 45 0c             	add    0xc(%ebp),%eax
  8011bf:	50                   	push   %eax
  8011c0:	57                   	push   %edi
  8011c1:	e8 4a ff ff ff       	call   801110 <read>
		if (m < 0)
  8011c6:	83 c4 10             	add    $0x10,%esp
  8011c9:	85 c0                	test   %eax,%eax
  8011cb:	78 17                	js     8011e4 <readn+0x4d>
			return m;
		if (m == 0)
  8011cd:	85 c0                	test   %eax,%eax
  8011cf:	74 11                	je     8011e2 <readn+0x4b>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8011d1:	01 c3                	add    %eax,%ebx
  8011d3:	89 d8                	mov    %ebx,%eax
  8011d5:	39 f3                	cmp    %esi,%ebx
  8011d7:	72 db                	jb     8011b4 <readn+0x1d>
  8011d9:	eb 09                	jmp    8011e4 <readn+0x4d>
  8011db:	b8 00 00 00 00       	mov    $0x0,%eax
  8011e0:	eb 02                	jmp    8011e4 <readn+0x4d>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  8011e2:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  8011e4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011e7:	5b                   	pop    %ebx
  8011e8:	5e                   	pop    %esi
  8011e9:	5f                   	pop    %edi
  8011ea:	c9                   	leave  
  8011eb:	c3                   	ret    

008011ec <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8011ec:	55                   	push   %ebp
  8011ed:	89 e5                	mov    %esp,%ebp
  8011ef:	53                   	push   %ebx
  8011f0:	83 ec 14             	sub    $0x14,%esp
  8011f3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8011f6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011f9:	50                   	push   %eax
  8011fa:	53                   	push   %ebx
  8011fb:	e8 8f fc ff ff       	call   800e8f <fd_lookup>
  801200:	83 c4 08             	add    $0x8,%esp
  801203:	85 c0                	test   %eax,%eax
  801205:	78 62                	js     801269 <write+0x7d>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801207:	83 ec 08             	sub    $0x8,%esp
  80120a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80120d:	50                   	push   %eax
  80120e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801211:	ff 30                	pushl  (%eax)
  801213:	e8 cd fc ff ff       	call   800ee5 <dev_lookup>
  801218:	83 c4 10             	add    $0x10,%esp
  80121b:	85 c0                	test   %eax,%eax
  80121d:	78 4a                	js     801269 <write+0x7d>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80121f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801222:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801226:	75 21                	jne    801249 <write+0x5d>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801228:	a1 04 40 80 00       	mov    0x804004,%eax
  80122d:	8b 40 48             	mov    0x48(%eax),%eax
  801230:	83 ec 04             	sub    $0x4,%esp
  801233:	53                   	push   %ebx
  801234:	50                   	push   %eax
  801235:	68 e9 28 80 00       	push   $0x8028e9
  80123a:	e8 3d f0 ff ff       	call   80027c <cprintf>
		return -E_INVAL;
  80123f:	83 c4 10             	add    $0x10,%esp
  801242:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801247:	eb 20                	jmp    801269 <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801249:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80124c:	8b 52 0c             	mov    0xc(%edx),%edx
  80124f:	85 d2                	test   %edx,%edx
  801251:	74 11                	je     801264 <write+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801253:	83 ec 04             	sub    $0x4,%esp
  801256:	ff 75 10             	pushl  0x10(%ebp)
  801259:	ff 75 0c             	pushl  0xc(%ebp)
  80125c:	50                   	push   %eax
  80125d:	ff d2                	call   *%edx
  80125f:	83 c4 10             	add    $0x10,%esp
  801262:	eb 05                	jmp    801269 <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801264:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  801269:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80126c:	c9                   	leave  
  80126d:	c3                   	ret    

0080126e <seek>:

int
seek(int fdnum, off_t offset)
{
  80126e:	55                   	push   %ebp
  80126f:	89 e5                	mov    %esp,%ebp
  801271:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801274:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801277:	50                   	push   %eax
  801278:	ff 75 08             	pushl  0x8(%ebp)
  80127b:	e8 0f fc ff ff       	call   800e8f <fd_lookup>
  801280:	83 c4 08             	add    $0x8,%esp
  801283:	85 c0                	test   %eax,%eax
  801285:	78 0e                	js     801295 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801287:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80128a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80128d:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801290:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801295:	c9                   	leave  
  801296:	c3                   	ret    

00801297 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801297:	55                   	push   %ebp
  801298:	89 e5                	mov    %esp,%ebp
  80129a:	53                   	push   %ebx
  80129b:	83 ec 14             	sub    $0x14,%esp
  80129e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8012a1:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012a4:	50                   	push   %eax
  8012a5:	53                   	push   %ebx
  8012a6:	e8 e4 fb ff ff       	call   800e8f <fd_lookup>
  8012ab:	83 c4 08             	add    $0x8,%esp
  8012ae:	85 c0                	test   %eax,%eax
  8012b0:	78 5f                	js     801311 <ftruncate+0x7a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012b2:	83 ec 08             	sub    $0x8,%esp
  8012b5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012b8:	50                   	push   %eax
  8012b9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012bc:	ff 30                	pushl  (%eax)
  8012be:	e8 22 fc ff ff       	call   800ee5 <dev_lookup>
  8012c3:	83 c4 10             	add    $0x10,%esp
  8012c6:	85 c0                	test   %eax,%eax
  8012c8:	78 47                	js     801311 <ftruncate+0x7a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8012ca:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012cd:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8012d1:	75 21                	jne    8012f4 <ftruncate+0x5d>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8012d3:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8012d8:	8b 40 48             	mov    0x48(%eax),%eax
  8012db:	83 ec 04             	sub    $0x4,%esp
  8012de:	53                   	push   %ebx
  8012df:	50                   	push   %eax
  8012e0:	68 ac 28 80 00       	push   $0x8028ac
  8012e5:	e8 92 ef ff ff       	call   80027c <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8012ea:	83 c4 10             	add    $0x10,%esp
  8012ed:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012f2:	eb 1d                	jmp    801311 <ftruncate+0x7a>
	}
	if (!dev->dev_trunc)
  8012f4:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8012f7:	8b 52 18             	mov    0x18(%edx),%edx
  8012fa:	85 d2                	test   %edx,%edx
  8012fc:	74 0e                	je     80130c <ftruncate+0x75>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8012fe:	83 ec 08             	sub    $0x8,%esp
  801301:	ff 75 0c             	pushl  0xc(%ebp)
  801304:	50                   	push   %eax
  801305:	ff d2                	call   *%edx
  801307:	83 c4 10             	add    $0x10,%esp
  80130a:	eb 05                	jmp    801311 <ftruncate+0x7a>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80130c:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  801311:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801314:	c9                   	leave  
  801315:	c3                   	ret    

00801316 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801316:	55                   	push   %ebp
  801317:	89 e5                	mov    %esp,%ebp
  801319:	53                   	push   %ebx
  80131a:	83 ec 14             	sub    $0x14,%esp
  80131d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801320:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801323:	50                   	push   %eax
  801324:	ff 75 08             	pushl  0x8(%ebp)
  801327:	e8 63 fb ff ff       	call   800e8f <fd_lookup>
  80132c:	83 c4 08             	add    $0x8,%esp
  80132f:	85 c0                	test   %eax,%eax
  801331:	78 52                	js     801385 <fstat+0x6f>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801333:	83 ec 08             	sub    $0x8,%esp
  801336:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801339:	50                   	push   %eax
  80133a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80133d:	ff 30                	pushl  (%eax)
  80133f:	e8 a1 fb ff ff       	call   800ee5 <dev_lookup>
  801344:	83 c4 10             	add    $0x10,%esp
  801347:	85 c0                	test   %eax,%eax
  801349:	78 3a                	js     801385 <fstat+0x6f>
		return r;
	if (!dev->dev_stat)
  80134b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80134e:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801352:	74 2c                	je     801380 <fstat+0x6a>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801354:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801357:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80135e:	00 00 00 
	stat->st_isdir = 0;
  801361:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801368:	00 00 00 
	stat->st_dev = dev;
  80136b:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801371:	83 ec 08             	sub    $0x8,%esp
  801374:	53                   	push   %ebx
  801375:	ff 75 f0             	pushl  -0x10(%ebp)
  801378:	ff 50 14             	call   *0x14(%eax)
  80137b:	83 c4 10             	add    $0x10,%esp
  80137e:	eb 05                	jmp    801385 <fstat+0x6f>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801380:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801385:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801388:	c9                   	leave  
  801389:	c3                   	ret    

0080138a <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80138a:	55                   	push   %ebp
  80138b:	89 e5                	mov    %esp,%ebp
  80138d:	56                   	push   %esi
  80138e:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80138f:	83 ec 08             	sub    $0x8,%esp
  801392:	6a 00                	push   $0x0
  801394:	ff 75 08             	pushl  0x8(%ebp)
  801397:	e8 8b 01 00 00       	call   801527 <open>
  80139c:	89 c3                	mov    %eax,%ebx
  80139e:	83 c4 10             	add    $0x10,%esp
  8013a1:	85 c0                	test   %eax,%eax
  8013a3:	78 1b                	js     8013c0 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8013a5:	83 ec 08             	sub    $0x8,%esp
  8013a8:	ff 75 0c             	pushl  0xc(%ebp)
  8013ab:	50                   	push   %eax
  8013ac:	e8 65 ff ff ff       	call   801316 <fstat>
  8013b1:	89 c6                	mov    %eax,%esi
	close(fd);
  8013b3:	89 1c 24             	mov    %ebx,(%esp)
  8013b6:	e8 18 fc ff ff       	call   800fd3 <close>
	return r;
  8013bb:	83 c4 10             	add    $0x10,%esp
  8013be:	89 f3                	mov    %esi,%ebx
}
  8013c0:	89 d8                	mov    %ebx,%eax
  8013c2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8013c5:	5b                   	pop    %ebx
  8013c6:	5e                   	pop    %esi
  8013c7:	c9                   	leave  
  8013c8:	c3                   	ret    
  8013c9:	00 00                	add    %al,(%eax)
	...

008013cc <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8013cc:	55                   	push   %ebp
  8013cd:	89 e5                	mov    %esp,%ebp
  8013cf:	56                   	push   %esi
  8013d0:	53                   	push   %ebx
  8013d1:	89 c3                	mov    %eax,%ebx
  8013d3:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  8013d5:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8013dc:	75 12                	jne    8013f0 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8013de:	83 ec 0c             	sub    $0xc,%esp
  8013e1:	6a 01                	push   $0x1
  8013e3:	e8 89 0d 00 00       	call   802171 <ipc_find_env>
  8013e8:	a3 00 40 80 00       	mov    %eax,0x804000
  8013ed:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8013f0:	6a 07                	push   $0x7
  8013f2:	68 00 50 80 00       	push   $0x805000
  8013f7:	53                   	push   %ebx
  8013f8:	ff 35 00 40 80 00    	pushl  0x804000
  8013fe:	e8 19 0d 00 00       	call   80211c <ipc_send>
	
	return ipc_recv(NULL, dstva, NULL);
  801403:	83 c4 0c             	add    $0xc,%esp
  801406:	6a 00                	push   $0x0
  801408:	56                   	push   %esi
  801409:	6a 00                	push   $0x0
  80140b:	e8 64 0c 00 00       	call   802074 <ipc_recv>
}
  801410:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801413:	5b                   	pop    %ebx
  801414:	5e                   	pop    %esi
  801415:	c9                   	leave  
  801416:	c3                   	ret    

00801417 <devfile_stat>:
}


static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801417:	55                   	push   %ebp
  801418:	89 e5                	mov    %esp,%ebp
  80141a:	53                   	push   %ebx
  80141b:	83 ec 04             	sub    $0x4,%esp
  80141e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801421:	8b 45 08             	mov    0x8(%ebp),%eax
  801424:	8b 40 0c             	mov    0xc(%eax),%eax
  801427:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0) {
  80142c:	ba 00 00 00 00       	mov    $0x0,%edx
  801431:	b8 05 00 00 00       	mov    $0x5,%eax
  801436:	e8 91 ff ff ff       	call   8013cc <fsipc>
  80143b:	85 c0                	test   %eax,%eax
  80143d:	78 39                	js     801478 <devfile_stat+0x61>
		return r;
	}
	cprintf("OVER\n");
  80143f:	83 ec 0c             	sub    $0xc,%esp
  801442:	68 18 29 80 00       	push   $0x802918
  801447:	e8 30 ee ff ff       	call   80027c <cprintf>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80144c:	83 c4 08             	add    $0x8,%esp
  80144f:	68 00 50 80 00       	push   $0x805000
  801454:	53                   	push   %ebx
  801455:	e8 d8 f3 ff ff       	call   800832 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  80145a:	a1 80 50 80 00       	mov    0x805080,%eax
  80145f:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801465:	a1 84 50 80 00       	mov    0x805084,%eax
  80146a:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801470:	83 c4 10             	add    $0x10,%esp
  801473:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801478:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80147b:	c9                   	leave  
  80147c:	c3                   	ret    

0080147d <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80147d:	55                   	push   %ebp
  80147e:	89 e5                	mov    %esp,%ebp
  801480:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801483:	8b 45 08             	mov    0x8(%ebp),%eax
  801486:	8b 40 0c             	mov    0xc(%eax),%eax
  801489:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80148e:	ba 00 00 00 00       	mov    $0x0,%edx
  801493:	b8 06 00 00 00       	mov    $0x6,%eax
  801498:	e8 2f ff ff ff       	call   8013cc <fsipc>
}
  80149d:	c9                   	leave  
  80149e:	c3                   	ret    

0080149f <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  80149f:	55                   	push   %ebp
  8014a0:	89 e5                	mov    %esp,%ebp
  8014a2:	56                   	push   %esi
  8014a3:	53                   	push   %ebx
  8014a4:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8014a7:	8b 45 08             	mov    0x8(%ebp),%eax
  8014aa:	8b 40 0c             	mov    0xc(%eax),%eax
  8014ad:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8014b2:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8014b8:	ba 00 00 00 00       	mov    $0x0,%edx
  8014bd:	b8 03 00 00 00       	mov    $0x3,%eax
  8014c2:	e8 05 ff ff ff       	call   8013cc <fsipc>
  8014c7:	89 c3                	mov    %eax,%ebx
  8014c9:	85 c0                	test   %eax,%eax
  8014cb:	78 51                	js     80151e <devfile_read+0x7f>
		return r;
	assert(r <= n);
  8014cd:	39 c6                	cmp    %eax,%esi
  8014cf:	73 19                	jae    8014ea <devfile_read+0x4b>
  8014d1:	68 1e 29 80 00       	push   $0x80291e
  8014d6:	68 25 29 80 00       	push   $0x802925
  8014db:	68 80 00 00 00       	push   $0x80
  8014e0:	68 3a 29 80 00       	push   $0x80293a
  8014e5:	e8 ba ec ff ff       	call   8001a4 <_panic>
	assert(r <= PGSIZE);
  8014ea:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8014ef:	7e 19                	jle    80150a <devfile_read+0x6b>
  8014f1:	68 45 29 80 00       	push   $0x802945
  8014f6:	68 25 29 80 00       	push   $0x802925
  8014fb:	68 81 00 00 00       	push   $0x81
  801500:	68 3a 29 80 00       	push   $0x80293a
  801505:	e8 9a ec ff ff       	call   8001a4 <_panic>
	memmove(buf, &fsipcbuf, r);
  80150a:	83 ec 04             	sub    $0x4,%esp
  80150d:	50                   	push   %eax
  80150e:	68 00 50 80 00       	push   $0x805000
  801513:	ff 75 0c             	pushl  0xc(%ebp)
  801516:	e8 d8 f4 ff ff       	call   8009f3 <memmove>
	return r;
  80151b:	83 c4 10             	add    $0x10,%esp
}
  80151e:	89 d8                	mov    %ebx,%eax
  801520:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801523:	5b                   	pop    %ebx
  801524:	5e                   	pop    %esi
  801525:	c9                   	leave  
  801526:	c3                   	ret    

00801527 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801527:	55                   	push   %ebp
  801528:	89 e5                	mov    %esp,%ebp
  80152a:	56                   	push   %esi
  80152b:	53                   	push   %ebx
  80152c:	83 ec 1c             	sub    $0x1c,%esp
  80152f:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801532:	56                   	push   %esi
  801533:	e8 a8 f2 ff ff       	call   8007e0 <strlen>
  801538:	83 c4 10             	add    $0x10,%esp
  80153b:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801540:	7f 72                	jg     8015b4 <open+0x8d>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801542:	83 ec 0c             	sub    $0xc,%esp
  801545:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801548:	50                   	push   %eax
  801549:	e8 ce f8 ff ff       	call   800e1c <fd_alloc>
  80154e:	89 c3                	mov    %eax,%ebx
  801550:	83 c4 10             	add    $0x10,%esp
  801553:	85 c0                	test   %eax,%eax
  801555:	78 62                	js     8015b9 <open+0x92>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801557:	83 ec 08             	sub    $0x8,%esp
  80155a:	56                   	push   %esi
  80155b:	68 00 50 80 00       	push   $0x805000
  801560:	e8 cd f2 ff ff       	call   800832 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801565:	8b 45 0c             	mov    0xc(%ebp),%eax
  801568:	a3 00 54 80 00       	mov    %eax,0x805400



	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  80156d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801570:	b8 01 00 00 00       	mov    $0x1,%eax
  801575:	e8 52 fe ff ff       	call   8013cc <fsipc>
  80157a:	89 c3                	mov    %eax,%ebx
  80157c:	83 c4 10             	add    $0x10,%esp
  80157f:	85 c0                	test   %eax,%eax
  801581:	79 12                	jns    801595 <open+0x6e>
		fd_close(fd, 0);
  801583:	83 ec 08             	sub    $0x8,%esp
  801586:	6a 00                	push   $0x0
  801588:	ff 75 f4             	pushl  -0xc(%ebp)
  80158b:	e8 bb f9 ff ff       	call   800f4b <fd_close>
		return r;
  801590:	83 c4 10             	add    $0x10,%esp
  801593:	eb 24                	jmp    8015b9 <open+0x92>
	}


	cprintf("OPEN\n");
  801595:	83 ec 0c             	sub    $0xc,%esp
  801598:	68 51 29 80 00       	push   $0x802951
  80159d:	e8 da ec ff ff       	call   80027c <cprintf>

	return fd2num(fd);
  8015a2:	83 c4 04             	add    $0x4,%esp
  8015a5:	ff 75 f4             	pushl  -0xc(%ebp)
  8015a8:	e8 47 f8 ff ff       	call   800df4 <fd2num>
  8015ad:	89 c3                	mov    %eax,%ebx
  8015af:	83 c4 10             	add    $0x10,%esp
  8015b2:	eb 05                	jmp    8015b9 <open+0x92>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8015b4:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx


	cprintf("OPEN\n");

	return fd2num(fd);
}
  8015b9:	89 d8                	mov    %ebx,%eax
  8015bb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8015be:	5b                   	pop    %ebx
  8015bf:	5e                   	pop    %esi
  8015c0:	c9                   	leave  
  8015c1:	c3                   	ret    
	...

008015c4 <spawn>:
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
{
  8015c4:	55                   	push   %ebp
  8015c5:	89 e5                	mov    %esp,%ebp
  8015c7:	57                   	push   %edi
  8015c8:	56                   	push   %esi
  8015c9:	53                   	push   %ebx
  8015ca:	81 ec 94 02 00 00    	sub    $0x294,%esp
	//   - Call sys_env_set_trapframe(child, &child_tf) to set up the
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
  8015d0:	6a 00                	push   $0x0
  8015d2:	ff 75 08             	pushl  0x8(%ebp)
  8015d5:	e8 4d ff ff ff       	call   801527 <open>
  8015da:	89 85 88 fd ff ff    	mov    %eax,-0x278(%ebp)
  8015e0:	83 c4 10             	add    $0x10,%esp
  8015e3:	85 c0                	test   %eax,%eax
  8015e5:	0f 88 ce 04 00 00    	js     801ab9 <spawn+0x4f5>
		return r;
	fd = r;

	// Read elf header
	elf = (struct Elf*) elf_buf;
	if (readn(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf)
  8015eb:	83 ec 04             	sub    $0x4,%esp
  8015ee:	68 00 02 00 00       	push   $0x200
  8015f3:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  8015f9:	50                   	push   %eax
  8015fa:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  801600:	e8 92 fb ff ff       	call   801197 <readn>
  801605:	83 c4 10             	add    $0x10,%esp
  801608:	3d 00 02 00 00       	cmp    $0x200,%eax
  80160d:	75 0c                	jne    80161b <spawn+0x57>
	    || elf->e_magic != ELF_MAGIC) {
  80160f:	81 bd e8 fd ff ff 7f 	cmpl   $0x464c457f,-0x218(%ebp)
  801616:	45 4c 46 
  801619:	74 38                	je     801653 <spawn+0x8f>
		close(fd);
  80161b:	83 ec 0c             	sub    $0xc,%esp
  80161e:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  801624:	e8 aa f9 ff ff       	call   800fd3 <close>
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
  801629:	83 c4 0c             	add    $0xc,%esp
  80162c:	68 7f 45 4c 46       	push   $0x464c457f
  801631:	ff b5 e8 fd ff ff    	pushl  -0x218(%ebp)
  801637:	68 57 29 80 00       	push   $0x802957
  80163c:	e8 3b ec ff ff       	call   80027c <cprintf>
		return -E_NOT_EXEC;
  801641:	83 c4 10             	add    $0x10,%esp
  801644:	c7 85 84 fd ff ff f2 	movl   $0xfffffff2,-0x27c(%ebp)
  80164b:	ff ff ff 
  80164e:	e9 72 04 00 00       	jmp    801ac5 <spawn+0x501>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  801653:	ba 07 00 00 00       	mov    $0x7,%edx
  801658:	89 d0                	mov    %edx,%eax
  80165a:	cd 30                	int    $0x30
  80165c:	89 85 74 fd ff ff    	mov    %eax,-0x28c(%ebp)
  801662:	89 85 84 fd ff ff    	mov    %eax,-0x27c(%ebp)
	}


	// Create new child environment
	if ((r = sys_exofork()) < 0)
  801668:	85 c0                	test   %eax,%eax
  80166a:	0f 88 55 04 00 00    	js     801ac5 <spawn+0x501>
	child = r;



	// Set up trap frame, including initial stack.
	child_tf = envs[ENVX(child)].env_tf;
  801670:	25 ff 03 00 00       	and    $0x3ff,%eax
  801675:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  80167c:	89 c6                	mov    %eax,%esi
  80167e:	c1 e6 07             	shl    $0x7,%esi
  801681:	29 d6                	sub    %edx,%esi
  801683:	81 c6 00 00 c0 ee    	add    $0xeec00000,%esi
  801689:	8d bd a4 fd ff ff    	lea    -0x25c(%ebp),%edi
  80168f:	b9 11 00 00 00       	mov    $0x11,%ecx
  801694:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	child_tf.tf_eip = elf->e_entry;
  801696:	8b 85 00 fe ff ff    	mov    -0x200(%ebp),%eax
  80169c:	89 85 d4 fd ff ff    	mov    %eax,-0x22c(%ebp)
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  8016a2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8016a5:	8b 02                	mov    (%edx),%eax
  8016a7:	85 c0                	test   %eax,%eax
  8016a9:	74 39                	je     8016e4 <spawn+0x120>
	char *string_store;
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
  8016ab:	be 00 00 00 00       	mov    $0x0,%esi
	for (argc = 0; argv[argc] != 0; argc++)
  8016b0:	bb 00 00 00 00       	mov    $0x0,%ebx
  8016b5:	89 d7                	mov    %edx,%edi
		string_size += strlen(argv[argc]) + 1;
  8016b7:	83 ec 0c             	sub    $0xc,%esp
  8016ba:	50                   	push   %eax
  8016bb:	e8 20 f1 ff ff       	call   8007e0 <strlen>
  8016c0:	8d 74 30 01          	lea    0x1(%eax,%esi,1),%esi
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  8016c4:	43                   	inc    %ebx
  8016c5:	8d 0c 9d 00 00 00 00 	lea    0x0(,%ebx,4),%ecx
  8016cc:	8b 04 9f             	mov    (%edi,%ebx,4),%eax
  8016cf:	83 c4 10             	add    $0x10,%esp
  8016d2:	85 c0                	test   %eax,%eax
  8016d4:	75 e1                	jne    8016b7 <spawn+0xf3>
  8016d6:	89 9d 80 fd ff ff    	mov    %ebx,-0x280(%ebp)
  8016dc:	89 8d 7c fd ff ff    	mov    %ecx,-0x284(%ebp)
  8016e2:	eb 1e                	jmp    801702 <spawn+0x13e>
  8016e4:	c7 85 7c fd ff ff 00 	movl   $0x0,-0x284(%ebp)
  8016eb:	00 00 00 
  8016ee:	c7 85 80 fd ff ff 00 	movl   $0x0,-0x280(%ebp)
  8016f5:	00 00 00 
	char *string_store;
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
  8016f8:	be 00 00 00 00       	mov    $0x0,%esi
	for (argc = 0; argv[argc] != 0; argc++)
  8016fd:	bb 00 00 00 00       	mov    $0x0,%ebx
	// Determine where to place the strings and the argv array.
	// Set up pointers into the temporary page 'UTEMP'; we'll map a page
	// there later, then remap that page into the child environment
	// at (USTACKTOP - PGSIZE).
	// strings is the topmost thing on the stack.
	string_store = (char*) UTEMP + PGSIZE - string_size;
  801702:	f7 de                	neg    %esi
  801704:	8d be 00 10 40 00    	lea    0x401000(%esi),%edi
	// argv is below that.  There's one argument pointer per argument, plus
	// a null pointer.
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));
  80170a:	89 fa                	mov    %edi,%edx
  80170c:	83 e2 fc             	and    $0xfffffffc,%edx
  80170f:	89 d8                	mov    %ebx,%eax
  801711:	f7 d0                	not    %eax
  801713:	8d 04 82             	lea    (%edx,%eax,4),%eax
  801716:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
  80171c:	83 e8 08             	sub    $0x8,%eax
  80171f:	3d ff ff 3f 00       	cmp    $0x3fffff,%eax
  801724:	0f 86 a9 03 00 00    	jbe    801ad3 <spawn+0x50f>
		return -E_NO_MEM;

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  80172a:	83 ec 04             	sub    $0x4,%esp
  80172d:	6a 07                	push   $0x7
  80172f:	68 00 00 40 00       	push   $0x400000
  801734:	6a 00                	push   $0x0
  801736:	e8 79 f5 ff ff       	call   800cb4 <sys_page_alloc>
  80173b:	83 c4 10             	add    $0x10,%esp
  80173e:	85 c0                	test   %eax,%eax
  801740:	0f 88 99 03 00 00    	js     801adf <spawn+0x51b>
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  801746:	85 db                	test   %ebx,%ebx
  801748:	7e 44                	jle    80178e <spawn+0x1ca>
  80174a:	be 00 00 00 00       	mov    $0x0,%esi
  80174f:	89 9d 8c fd ff ff    	mov    %ebx,-0x274(%ebp)
  801755:	8b 5d 0c             	mov    0xc(%ebp),%ebx
		argv_store[i] = UTEMP2USTACK(string_store);
  801758:	8d 87 00 d0 7f ee    	lea    -0x11803000(%edi),%eax
  80175e:	8b 95 94 fd ff ff    	mov    -0x26c(%ebp),%edx
  801764:	89 04 b2             	mov    %eax,(%edx,%esi,4)
		strcpy(string_store, argv[i]);
  801767:	83 ec 08             	sub    $0x8,%esp
  80176a:	ff 34 b3             	pushl  (%ebx,%esi,4)
  80176d:	57                   	push   %edi
  80176e:	e8 bf f0 ff ff       	call   800832 <strcpy>
		string_store += strlen(argv[i]) + 1;
  801773:	83 c4 04             	add    $0x4,%esp
  801776:	ff 34 b3             	pushl  (%ebx,%esi,4)
  801779:	e8 62 f0 ff ff       	call   8007e0 <strlen>
  80177e:	8d 7c 07 01          	lea    0x1(%edi,%eax,1),%edi
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  801782:	46                   	inc    %esi
  801783:	83 c4 10             	add    $0x10,%esp
  801786:	3b b5 8c fd ff ff    	cmp    -0x274(%ebp),%esi
  80178c:	7c ca                	jl     801758 <spawn+0x194>
		argv_store[i] = UTEMP2USTACK(string_store);
		strcpy(string_store, argv[i]);
		string_store += strlen(argv[i]) + 1;
	}
	argv_store[argc] = 0;
  80178e:	8b 95 94 fd ff ff    	mov    -0x26c(%ebp),%edx
  801794:	8b 85 7c fd ff ff    	mov    -0x284(%ebp),%eax
  80179a:	c7 04 02 00 00 00 00 	movl   $0x0,(%edx,%eax,1)
	assert(string_store == (char*)UTEMP + PGSIZE);
  8017a1:	81 ff 00 10 40 00    	cmp    $0x401000,%edi
  8017a7:	74 19                	je     8017c2 <spawn+0x1fe>
  8017a9:	68 cc 29 80 00       	push   $0x8029cc
  8017ae:	68 25 29 80 00       	push   $0x802925
  8017b3:	68 f5 00 00 00       	push   $0xf5
  8017b8:	68 71 29 80 00       	push   $0x802971
  8017bd:	e8 e2 e9 ff ff       	call   8001a4 <_panic>

	argv_store[-1] = UTEMP2USTACK(argv_store);
  8017c2:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  8017c8:	2d 00 30 80 11       	sub    $0x11803000,%eax
  8017cd:	8b 95 94 fd ff ff    	mov    -0x26c(%ebp),%edx
  8017d3:	89 42 fc             	mov    %eax,-0x4(%edx)
	argv_store[-2] = argc;
  8017d6:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  8017dc:	89 42 f8             	mov    %eax,-0x8(%edx)

	*init_esp = UTEMP2USTACK(&argv_store[-2]);
  8017df:	89 d0                	mov    %edx,%eax
  8017e1:	2d 08 30 80 11       	sub    $0x11803008,%eax
  8017e6:	89 85 e0 fd ff ff    	mov    %eax,-0x220(%ebp)

	// After completing the stack, map it into the child's address space
	// and unmap it from ours!
	if ((r = sys_page_map(0, UTEMP, child, (void*) (USTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W)) < 0)
  8017ec:	83 ec 0c             	sub    $0xc,%esp
  8017ef:	6a 07                	push   $0x7
  8017f1:	68 00 d0 bf ee       	push   $0xeebfd000
  8017f6:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  8017fc:	68 00 00 40 00       	push   $0x400000
  801801:	6a 00                	push   $0x0
  801803:	e8 d0 f4 ff ff       	call   800cd8 <sys_page_map>
  801808:	89 c3                	mov    %eax,%ebx
  80180a:	83 c4 20             	add    $0x20,%esp
  80180d:	85 c0                	test   %eax,%eax
  80180f:	78 18                	js     801829 <spawn+0x265>
		goto error;
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  801811:	83 ec 08             	sub    $0x8,%esp
  801814:	68 00 00 40 00       	push   $0x400000
  801819:	6a 00                	push   $0x0
  80181b:	e8 de f4 ff ff       	call   800cfe <sys_page_unmap>
  801820:	89 c3                	mov    %eax,%ebx
  801822:	83 c4 10             	add    $0x10,%esp
  801825:	85 c0                	test   %eax,%eax
  801827:	79 1d                	jns    801846 <spawn+0x282>
		goto error;

	return 0;

error:
	sys_page_unmap(0, UTEMP);
  801829:	83 ec 08             	sub    $0x8,%esp
  80182c:	68 00 00 40 00       	push   $0x400000
  801831:	6a 00                	push   $0x0
  801833:	e8 c6 f4 ff ff       	call   800cfe <sys_page_unmap>
  801838:	83 c4 10             	add    $0x10,%esp
	return r;
  80183b:	89 9d 84 fd ff ff    	mov    %ebx,-0x27c(%ebp)
  801841:	e9 7f 02 00 00       	jmp    801ac5 <spawn+0x501>
	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;


	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  801846:	8b 85 04 fe ff ff    	mov    -0x1fc(%ebp),%eax
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  80184c:	66 83 bd 14 fe ff ff 	cmpw   $0x0,-0x1ec(%ebp)
  801853:	00 
  801854:	0f 84 c3 01 00 00    	je     801a1d <spawn+0x459>
	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;


	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  80185a:	8d 84 05 e8 fd ff ff 	lea    -0x218(%ebp,%eax,1),%eax
  801861:	89 85 80 fd ff ff    	mov    %eax,-0x280(%ebp)
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801867:	c7 85 7c fd ff ff 00 	movl   $0x0,-0x284(%ebp)
  80186e:	00 00 00 
		if (ph->p_type != ELF_PROG_LOAD)
  801871:	8b 95 80 fd ff ff    	mov    -0x280(%ebp),%edx
  801877:	83 3a 01             	cmpl   $0x1,(%edx)
  80187a:	0f 85 7c 01 00 00    	jne    8019fc <spawn+0x438>
			continue;
		perm = PTE_P | PTE_U;
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
  801880:	8b 42 18             	mov    0x18(%edx),%eax
  801883:	83 e0 02             	and    $0x2,%eax
	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
		if (ph->p_type != ELF_PROG_LOAD)
			continue;
		perm = PTE_P | PTE_U;
  801886:	83 f8 01             	cmp    $0x1,%eax
  801889:	19 db                	sbb    %ebx,%ebx
  80188b:	83 e3 fe             	and    $0xfffffffe,%ebx
  80188e:	83 c3 07             	add    $0x7,%ebx
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
  801891:	8b 42 04             	mov    0x4(%edx),%eax
  801894:	89 85 78 fd ff ff    	mov    %eax,-0x288(%ebp)
  80189a:	8b 52 10             	mov    0x10(%edx),%edx
  80189d:	89 95 94 fd ff ff    	mov    %edx,-0x26c(%ebp)
  8018a3:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  8018a9:	8b 40 14             	mov    0x14(%eax),%eax
  8018ac:	89 85 8c fd ff ff    	mov    %eax,-0x274(%ebp)
  8018b2:	8b 95 80 fd ff ff    	mov    -0x280(%ebp),%edx
  8018b8:	8b 52 08             	mov    0x8(%edx),%edx
  8018bb:	89 95 90 fd ff ff    	mov    %edx,-0x270(%ebp)
	int i, r;
	void *blk;

	//cprintf("map_segment %x+%x\n", va, memsz);

	if ((i = PGOFF(va))) {
  8018c1:	89 d0                	mov    %edx,%eax
  8018c3:	25 ff 0f 00 00       	and    $0xfff,%eax
  8018c8:	74 1a                	je     8018e4 <spawn+0x320>
		va -= i;
  8018ca:	29 c2                	sub    %eax,%edx
  8018cc:	89 95 90 fd ff ff    	mov    %edx,-0x270(%ebp)
		memsz += i;
  8018d2:	01 85 8c fd ff ff    	add    %eax,-0x274(%ebp)
		filesz += i;
  8018d8:	01 85 94 fd ff ff    	add    %eax,-0x26c(%ebp)
		fileoffset -= i;
  8018de:	29 85 78 fd ff ff    	sub    %eax,-0x288(%ebp)
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  8018e4:	83 bd 8c fd ff ff 00 	cmpl   $0x0,-0x274(%ebp)
  8018eb:	0f 84 0b 01 00 00    	je     8019fc <spawn+0x438>
  8018f1:	bf 00 00 00 00       	mov    $0x0,%edi
  8018f6:	be 00 00 00 00       	mov    $0x0,%esi
		if (i >= filesz) {
  8018fb:	3b bd 94 fd ff ff    	cmp    -0x26c(%ebp),%edi
  801901:	72 28                	jb     80192b <spawn+0x367>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
  801903:	83 ec 04             	sub    $0x4,%esp
  801906:	53                   	push   %ebx
  801907:	03 bd 90 fd ff ff    	add    -0x270(%ebp),%edi
  80190d:	57                   	push   %edi
  80190e:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  801914:	e8 9b f3 ff ff       	call   800cb4 <sys_page_alloc>
  801919:	83 c4 10             	add    $0x10,%esp
  80191c:	85 c0                	test   %eax,%eax
  80191e:	0f 89 c4 00 00 00    	jns    8019e8 <spawn+0x424>
  801924:	89 c3                	mov    %eax,%ebx
  801926:	e9 67 01 00 00       	jmp    801a92 <spawn+0x4ce>
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  80192b:	83 ec 04             	sub    $0x4,%esp
  80192e:	6a 07                	push   $0x7
  801930:	68 00 00 40 00       	push   $0x400000
  801935:	6a 00                	push   $0x0
  801937:	e8 78 f3 ff ff       	call   800cb4 <sys_page_alloc>
  80193c:	83 c4 10             	add    $0x10,%esp
  80193f:	85 c0                	test   %eax,%eax
  801941:	0f 88 41 01 00 00    	js     801a88 <spawn+0x4c4>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  801947:	83 ec 08             	sub    $0x8,%esp
// prog: the pathname of the program to run.
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
  80194a:	8b 85 78 fd ff ff    	mov    -0x288(%ebp),%eax
  801950:	8d 04 06             	lea    (%esi,%eax,1),%eax
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  801953:	50                   	push   %eax
  801954:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  80195a:	e8 0f f9 ff ff       	call   80126e <seek>
  80195f:	83 c4 10             	add    $0x10,%esp
  801962:	85 c0                	test   %eax,%eax
  801964:	0f 88 22 01 00 00    	js     801a8c <spawn+0x4c8>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  80196a:	83 ec 04             	sub    $0x4,%esp
  80196d:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  801973:	29 f8                	sub    %edi,%eax
  801975:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80197a:	76 05                	jbe    801981 <spawn+0x3bd>
  80197c:	b8 00 10 00 00       	mov    $0x1000,%eax
  801981:	50                   	push   %eax
  801982:	68 00 00 40 00       	push   $0x400000
  801987:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  80198d:	e8 05 f8 ff ff       	call   801197 <readn>
  801992:	83 c4 10             	add    $0x10,%esp
  801995:	85 c0                	test   %eax,%eax
  801997:	0f 88 f3 00 00 00    	js     801a90 <spawn+0x4cc>
				return r;
			if ((r = sys_page_map(0, UTEMP, child, (void*) (va + i), perm)) < 0)
  80199d:	83 ec 0c             	sub    $0xc,%esp
  8019a0:	53                   	push   %ebx
  8019a1:	03 bd 90 fd ff ff    	add    -0x270(%ebp),%edi
  8019a7:	57                   	push   %edi
  8019a8:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  8019ae:	68 00 00 40 00       	push   $0x400000
  8019b3:	6a 00                	push   $0x0
  8019b5:	e8 1e f3 ff ff       	call   800cd8 <sys_page_map>
  8019ba:	83 c4 20             	add    $0x20,%esp
  8019bd:	85 c0                	test   %eax,%eax
  8019bf:	79 15                	jns    8019d6 <spawn+0x412>
				panic("spawn: sys_page_map data: %e", r);
  8019c1:	50                   	push   %eax
  8019c2:	68 7d 29 80 00       	push   $0x80297d
  8019c7:	68 28 01 00 00       	push   $0x128
  8019cc:	68 71 29 80 00       	push   $0x802971
  8019d1:	e8 ce e7 ff ff       	call   8001a4 <_panic>
			sys_page_unmap(0, UTEMP);
  8019d6:	83 ec 08             	sub    $0x8,%esp
  8019d9:	68 00 00 40 00       	push   $0x400000
  8019de:	6a 00                	push   $0x0
  8019e0:	e8 19 f3 ff ff       	call   800cfe <sys_page_unmap>
  8019e5:	83 c4 10             	add    $0x10,%esp
		memsz += i;
		filesz += i;
		fileoffset -= i;
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  8019e8:	81 c6 00 10 00 00    	add    $0x1000,%esi
  8019ee:	89 f7                	mov    %esi,%edi
  8019f0:	3b b5 8c fd ff ff    	cmp    -0x274(%ebp),%esi
  8019f6:	0f 82 ff fe ff ff    	jb     8018fb <spawn+0x337>
		return r;


	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  8019fc:	ff 85 7c fd ff ff    	incl   -0x284(%ebp)
  801a02:	0f b7 85 14 fe ff ff 	movzwl -0x1ec(%ebp),%eax
  801a09:	3b 85 7c fd ff ff    	cmp    -0x284(%ebp),%eax
  801a0f:	7e 0c                	jle    801a1d <spawn+0x459>
  801a11:	83 85 80 fd ff ff 20 	addl   $0x20,-0x280(%ebp)
  801a18:	e9 54 fe ff ff       	jmp    801871 <spawn+0x2ad>
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
				     fd, ph->p_filesz, ph->p_offset, perm)) < 0)
			goto error;
	}
	close(fd);
  801a1d:	83 ec 0c             	sub    $0xc,%esp
  801a20:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  801a26:	e8 a8 f5 ff ff       	call   800fd3 <close>

	// Copy shared library state.
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);

	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
  801a2b:	83 c4 08             	add    $0x8,%esp
  801a2e:	8d 85 a4 fd ff ff    	lea    -0x25c(%ebp),%eax
  801a34:	50                   	push   %eax
  801a35:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801a3b:	e8 04 f3 ff ff       	call   800d44 <sys_env_set_trapframe>
  801a40:	83 c4 10             	add    $0x10,%esp
  801a43:	85 c0                	test   %eax,%eax
  801a45:	79 15                	jns    801a5c <spawn+0x498>
		panic("sys_env_set_trapframe: %e", r);
  801a47:	50                   	push   %eax
  801a48:	68 9a 29 80 00       	push   $0x80299a
  801a4d:	68 89 00 00 00       	push   $0x89
  801a52:	68 71 29 80 00       	push   $0x802971
  801a57:	e8 48 e7 ff ff       	call   8001a4 <_panic>

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
  801a5c:	83 ec 08             	sub    $0x8,%esp
  801a5f:	6a 02                	push   $0x2
  801a61:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801a67:	e8 b5 f2 ff ff       	call   800d21 <sys_env_set_status>
  801a6c:	83 c4 10             	add    $0x10,%esp
  801a6f:	85 c0                	test   %eax,%eax
  801a71:	79 52                	jns    801ac5 <spawn+0x501>
		panic("sys_env_set_status: %e", r);
  801a73:	50                   	push   %eax
  801a74:	68 b4 29 80 00       	push   $0x8029b4
  801a79:	68 8c 00 00 00       	push   $0x8c
  801a7e:	68 71 29 80 00       	push   $0x802971
  801a83:	e8 1c e7 ff ff       	call   8001a4 <_panic>
  801a88:	89 c3                	mov    %eax,%ebx
  801a8a:	eb 06                	jmp    801a92 <spawn+0x4ce>
  801a8c:	89 c3                	mov    %eax,%ebx
  801a8e:	eb 02                	jmp    801a92 <spawn+0x4ce>
  801a90:	89 c3                	mov    %eax,%ebx

	return child;

error:
	sys_env_destroy(child);
  801a92:	83 ec 0c             	sub    $0xc,%esp
  801a95:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801a9b:	e8 a7 f1 ff ff       	call   800c47 <sys_env_destroy>
	close(fd);
  801aa0:	83 c4 04             	add    $0x4,%esp
  801aa3:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  801aa9:	e8 25 f5 ff ff       	call   800fd3 <close>
	return r;
  801aae:	83 c4 10             	add    $0x10,%esp
  801ab1:	89 9d 84 fd ff ff    	mov    %ebx,-0x27c(%ebp)
  801ab7:	eb 0c                	jmp    801ac5 <spawn+0x501>
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
		return r;
  801ab9:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  801abf:	89 85 84 fd ff ff    	mov    %eax,-0x27c(%ebp)

error:
	sys_env_destroy(child);
	close(fd);
	return r;
}
  801ac5:	8b 85 84 fd ff ff    	mov    -0x27c(%ebp),%eax
  801acb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ace:	5b                   	pop    %ebx
  801acf:	5e                   	pop    %esi
  801ad0:	5f                   	pop    %edi
  801ad1:	c9                   	leave  
  801ad2:	c3                   	ret    
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
		return -E_NO_MEM;
  801ad3:	c7 85 84 fd ff ff fc 	movl   $0xfffffffc,-0x27c(%ebp)
  801ada:	ff ff ff 
  801add:	eb e6                	jmp    801ac5 <spawn+0x501>

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
		return r;
  801adf:	89 85 84 fd ff ff    	mov    %eax,-0x27c(%ebp)
  801ae5:	eb de                	jmp    801ac5 <spawn+0x501>

00801ae7 <spawnl>:
// Spawn, taking command-line arguments array directly on the stack.
// NOTE: Must have a sentinal of NULL at the end of the args
// (none of the args may be NULL).
int
spawnl(const char *prog, const char *arg0, ...)
{
  801ae7:	55                   	push   %ebp
  801ae8:	89 e5                	mov    %esp,%ebp
  801aea:	56                   	push   %esi
  801aeb:	53                   	push   %ebx
  801aec:	8b 75 0c             	mov    0xc(%ebp),%esi
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801aef:	8d 45 14             	lea    0x14(%ebp),%eax
  801af2:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801af6:	74 5f                	je     801b57 <spawnl+0x70>
{
	// We calculate argc by advancing the args until we hit NULL.
	// The contract of the function guarantees that the last
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
  801af8:	b9 00 00 00 00       	mov    $0x0,%ecx
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
		argc++;
  801afd:	41                   	inc    %ecx
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801afe:	89 c2                	mov    %eax,%edx
  801b00:	83 c0 04             	add    $0x4,%eax
  801b03:	83 3a 00             	cmpl   $0x0,(%edx)
  801b06:	75 f5                	jne    801afd <spawnl+0x16>
		argc++;
	va_end(vl);

	// Now that we have the size of the args, do a second pass
	// and store the values in a VLA, which has the format of argv
	const char *argv[argc+2];
  801b08:	8d 04 8d 26 00 00 00 	lea    0x26(,%ecx,4),%eax
  801b0f:	83 e0 f0             	and    $0xfffffff0,%eax
  801b12:	29 c4                	sub    %eax,%esp
  801b14:	8d 44 24 0f          	lea    0xf(%esp),%eax
  801b18:	83 e0 f0             	and    $0xfffffff0,%eax
  801b1b:	89 c3                	mov    %eax,%ebx
	argv[0] = arg0;
  801b1d:	89 30                	mov    %esi,(%eax)
	argv[argc+1] = NULL;
  801b1f:	c7 44 88 04 00 00 00 	movl   $0x0,0x4(%eax,%ecx,4)
  801b26:	00 

	va_start(vl, arg0);
  801b27:	8d 55 10             	lea    0x10(%ebp),%edx
	unsigned i;
	for(i=0;i<argc;i++)
  801b2a:	89 ce                	mov    %ecx,%esi
  801b2c:	85 c9                	test   %ecx,%ecx
  801b2e:	74 14                	je     801b44 <spawnl+0x5d>
  801b30:	b8 00 00 00 00       	mov    $0x0,%eax
		argv[i+1] = va_arg(vl, const char *);
  801b35:	40                   	inc    %eax
  801b36:	89 d1                	mov    %edx,%ecx
  801b38:	83 c2 04             	add    $0x4,%edx
  801b3b:	8b 09                	mov    (%ecx),%ecx
  801b3d:	89 0c 83             	mov    %ecx,(%ebx,%eax,4)
	argv[0] = arg0;
	argv[argc+1] = NULL;

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  801b40:	39 f0                	cmp    %esi,%eax
  801b42:	72 f1                	jb     801b35 <spawnl+0x4e>
		argv[i+1] = va_arg(vl, const char *);
	va_end(vl);
	return spawn(prog, argv);
  801b44:	83 ec 08             	sub    $0x8,%esp
  801b47:	53                   	push   %ebx
  801b48:	ff 75 08             	pushl  0x8(%ebp)
  801b4b:	e8 74 fa ff ff       	call   8015c4 <spawn>
}
  801b50:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b53:	5b                   	pop    %ebx
  801b54:	5e                   	pop    %esi
  801b55:	c9                   	leave  
  801b56:	c3                   	ret    
		argc++;
	va_end(vl);

	// Now that we have the size of the args, do a second pass
	// and store the values in a VLA, which has the format of argv
	const char *argv[argc+2];
  801b57:	83 ec 20             	sub    $0x20,%esp
  801b5a:	8d 44 24 0f          	lea    0xf(%esp),%eax
  801b5e:	83 e0 f0             	and    $0xfffffff0,%eax
  801b61:	89 c3                	mov    %eax,%ebx
	argv[0] = arg0;
  801b63:	89 30                	mov    %esi,(%eax)
	argv[argc+1] = NULL;
  801b65:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
  801b6c:	eb d6                	jmp    801b44 <spawnl+0x5d>
	...

00801b70 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801b70:	55                   	push   %ebp
  801b71:	89 e5                	mov    %esp,%ebp
  801b73:	56                   	push   %esi
  801b74:	53                   	push   %ebx
  801b75:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801b78:	83 ec 0c             	sub    $0xc,%esp
  801b7b:	ff 75 08             	pushl  0x8(%ebp)
  801b7e:	e8 81 f2 ff ff       	call   800e04 <fd2data>
  801b83:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  801b85:	83 c4 08             	add    $0x8,%esp
  801b88:	68 f4 29 80 00       	push   $0x8029f4
  801b8d:	56                   	push   %esi
  801b8e:	e8 9f ec ff ff       	call   800832 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801b93:	8b 43 04             	mov    0x4(%ebx),%eax
  801b96:	2b 03                	sub    (%ebx),%eax
  801b98:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  801b9e:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  801ba5:	00 00 00 
	stat->st_dev = &devpipe;
  801ba8:	c7 86 88 00 00 00 20 	movl   $0x803020,0x88(%esi)
  801baf:	30 80 00 
	return 0;
}
  801bb2:	b8 00 00 00 00       	mov    $0x0,%eax
  801bb7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801bba:	5b                   	pop    %ebx
  801bbb:	5e                   	pop    %esi
  801bbc:	c9                   	leave  
  801bbd:	c3                   	ret    

00801bbe <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801bbe:	55                   	push   %ebp
  801bbf:	89 e5                	mov    %esp,%ebp
  801bc1:	53                   	push   %ebx
  801bc2:	83 ec 0c             	sub    $0xc,%esp
  801bc5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801bc8:	53                   	push   %ebx
  801bc9:	6a 00                	push   $0x0
  801bcb:	e8 2e f1 ff ff       	call   800cfe <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801bd0:	89 1c 24             	mov    %ebx,(%esp)
  801bd3:	e8 2c f2 ff ff       	call   800e04 <fd2data>
  801bd8:	83 c4 08             	add    $0x8,%esp
  801bdb:	50                   	push   %eax
  801bdc:	6a 00                	push   $0x0
  801bde:	e8 1b f1 ff ff       	call   800cfe <sys_page_unmap>
}
  801be3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801be6:	c9                   	leave  
  801be7:	c3                   	ret    

00801be8 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801be8:	55                   	push   %ebp
  801be9:	89 e5                	mov    %esp,%ebp
  801beb:	57                   	push   %edi
  801bec:	56                   	push   %esi
  801bed:	53                   	push   %ebx
  801bee:	83 ec 1c             	sub    $0x1c,%esp
  801bf1:	89 c7                	mov    %eax,%edi
  801bf3:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801bf6:	a1 04 40 80 00       	mov    0x804004,%eax
  801bfb:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801bfe:	83 ec 0c             	sub    $0xc,%esp
  801c01:	57                   	push   %edi
  801c02:	e8 c5 05 00 00       	call   8021cc <pageref>
  801c07:	89 c6                	mov    %eax,%esi
  801c09:	83 c4 04             	add    $0x4,%esp
  801c0c:	ff 75 e4             	pushl  -0x1c(%ebp)
  801c0f:	e8 b8 05 00 00       	call   8021cc <pageref>
  801c14:	83 c4 10             	add    $0x10,%esp
  801c17:	39 c6                	cmp    %eax,%esi
  801c19:	0f 94 c0             	sete   %al
  801c1c:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  801c1f:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801c25:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801c28:	39 cb                	cmp    %ecx,%ebx
  801c2a:	75 08                	jne    801c34 <_pipeisclosed+0x4c>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  801c2c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c2f:	5b                   	pop    %ebx
  801c30:	5e                   	pop    %esi
  801c31:	5f                   	pop    %edi
  801c32:	c9                   	leave  
  801c33:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  801c34:	83 f8 01             	cmp    $0x1,%eax
  801c37:	75 bd                	jne    801bf6 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801c39:	8b 42 58             	mov    0x58(%edx),%eax
  801c3c:	6a 01                	push   $0x1
  801c3e:	50                   	push   %eax
  801c3f:	53                   	push   %ebx
  801c40:	68 fb 29 80 00       	push   $0x8029fb
  801c45:	e8 32 e6 ff ff       	call   80027c <cprintf>
  801c4a:	83 c4 10             	add    $0x10,%esp
  801c4d:	eb a7                	jmp    801bf6 <_pipeisclosed+0xe>

00801c4f <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801c4f:	55                   	push   %ebp
  801c50:	89 e5                	mov    %esp,%ebp
  801c52:	57                   	push   %edi
  801c53:	56                   	push   %esi
  801c54:	53                   	push   %ebx
  801c55:	83 ec 28             	sub    $0x28,%esp
  801c58:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801c5b:	56                   	push   %esi
  801c5c:	e8 a3 f1 ff ff       	call   800e04 <fd2data>
  801c61:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c63:	83 c4 10             	add    $0x10,%esp
  801c66:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801c6a:	75 4a                	jne    801cb6 <devpipe_write+0x67>
  801c6c:	bf 00 00 00 00       	mov    $0x0,%edi
  801c71:	eb 56                	jmp    801cc9 <devpipe_write+0x7a>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801c73:	89 da                	mov    %ebx,%edx
  801c75:	89 f0                	mov    %esi,%eax
  801c77:	e8 6c ff ff ff       	call   801be8 <_pipeisclosed>
  801c7c:	85 c0                	test   %eax,%eax
  801c7e:	75 4d                	jne    801ccd <devpipe_write+0x7e>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801c80:	e8 08 f0 ff ff       	call   800c8d <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801c85:	8b 43 04             	mov    0x4(%ebx),%eax
  801c88:	8b 13                	mov    (%ebx),%edx
  801c8a:	83 c2 20             	add    $0x20,%edx
  801c8d:	39 d0                	cmp    %edx,%eax
  801c8f:	73 e2                	jae    801c73 <devpipe_write+0x24>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801c91:	89 c2                	mov    %eax,%edx
  801c93:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  801c99:	79 05                	jns    801ca0 <devpipe_write+0x51>
  801c9b:	4a                   	dec    %edx
  801c9c:	83 ca e0             	or     $0xffffffe0,%edx
  801c9f:	42                   	inc    %edx
  801ca0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801ca3:	8a 0c 39             	mov    (%ecx,%edi,1),%cl
  801ca6:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801caa:	40                   	inc    %eax
  801cab:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801cae:	47                   	inc    %edi
  801caf:	39 7d 10             	cmp    %edi,0x10(%ebp)
  801cb2:	77 07                	ja     801cbb <devpipe_write+0x6c>
  801cb4:	eb 13                	jmp    801cc9 <devpipe_write+0x7a>
  801cb6:	bf 00 00 00 00       	mov    $0x0,%edi
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801cbb:	8b 43 04             	mov    0x4(%ebx),%eax
  801cbe:	8b 13                	mov    (%ebx),%edx
  801cc0:	83 c2 20             	add    $0x20,%edx
  801cc3:	39 d0                	cmp    %edx,%eax
  801cc5:	73 ac                	jae    801c73 <devpipe_write+0x24>
  801cc7:	eb c8                	jmp    801c91 <devpipe_write+0x42>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801cc9:	89 f8                	mov    %edi,%eax
  801ccb:	eb 05                	jmp    801cd2 <devpipe_write+0x83>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801ccd:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801cd2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801cd5:	5b                   	pop    %ebx
  801cd6:	5e                   	pop    %esi
  801cd7:	5f                   	pop    %edi
  801cd8:	c9                   	leave  
  801cd9:	c3                   	ret    

00801cda <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801cda:	55                   	push   %ebp
  801cdb:	89 e5                	mov    %esp,%ebp
  801cdd:	57                   	push   %edi
  801cde:	56                   	push   %esi
  801cdf:	53                   	push   %ebx
  801ce0:	83 ec 18             	sub    $0x18,%esp
  801ce3:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801ce6:	57                   	push   %edi
  801ce7:	e8 18 f1 ff ff       	call   800e04 <fd2data>
  801cec:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801cee:	83 c4 10             	add    $0x10,%esp
  801cf1:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801cf5:	75 44                	jne    801d3b <devpipe_read+0x61>
  801cf7:	be 00 00 00 00       	mov    $0x0,%esi
  801cfc:	eb 4f                	jmp    801d4d <devpipe_read+0x73>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
				return i;
  801cfe:	89 f0                	mov    %esi,%eax
  801d00:	eb 54                	jmp    801d56 <devpipe_read+0x7c>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801d02:	89 da                	mov    %ebx,%edx
  801d04:	89 f8                	mov    %edi,%eax
  801d06:	e8 dd fe ff ff       	call   801be8 <_pipeisclosed>
  801d0b:	85 c0                	test   %eax,%eax
  801d0d:	75 42                	jne    801d51 <devpipe_read+0x77>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801d0f:	e8 79 ef ff ff       	call   800c8d <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801d14:	8b 03                	mov    (%ebx),%eax
  801d16:	3b 43 04             	cmp    0x4(%ebx),%eax
  801d19:	74 e7                	je     801d02 <devpipe_read+0x28>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801d1b:	25 1f 00 00 80       	and    $0x8000001f,%eax
  801d20:	79 05                	jns    801d27 <devpipe_read+0x4d>
  801d22:	48                   	dec    %eax
  801d23:	83 c8 e0             	or     $0xffffffe0,%eax
  801d26:	40                   	inc    %eax
  801d27:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  801d2b:	8b 55 0c             	mov    0xc(%ebp),%edx
  801d2e:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  801d31:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801d33:	46                   	inc    %esi
  801d34:	39 75 10             	cmp    %esi,0x10(%ebp)
  801d37:	77 07                	ja     801d40 <devpipe_read+0x66>
  801d39:	eb 12                	jmp    801d4d <devpipe_read+0x73>
  801d3b:	be 00 00 00 00       	mov    $0x0,%esi
		while (p->p_rpos == p->p_wpos) {
  801d40:	8b 03                	mov    (%ebx),%eax
  801d42:	3b 43 04             	cmp    0x4(%ebx),%eax
  801d45:	75 d4                	jne    801d1b <devpipe_read+0x41>
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801d47:	85 f6                	test   %esi,%esi
  801d49:	75 b3                	jne    801cfe <devpipe_read+0x24>
  801d4b:	eb b5                	jmp    801d02 <devpipe_read+0x28>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801d4d:	89 f0                	mov    %esi,%eax
  801d4f:	eb 05                	jmp    801d56 <devpipe_read+0x7c>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801d51:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801d56:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d59:	5b                   	pop    %ebx
  801d5a:	5e                   	pop    %esi
  801d5b:	5f                   	pop    %edi
  801d5c:	c9                   	leave  
  801d5d:	c3                   	ret    

00801d5e <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801d5e:	55                   	push   %ebp
  801d5f:	89 e5                	mov    %esp,%ebp
  801d61:	57                   	push   %edi
  801d62:	56                   	push   %esi
  801d63:	53                   	push   %ebx
  801d64:	83 ec 28             	sub    $0x28,%esp
  801d67:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801d6a:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801d6d:	50                   	push   %eax
  801d6e:	e8 a9 f0 ff ff       	call   800e1c <fd_alloc>
  801d73:	89 c3                	mov    %eax,%ebx
  801d75:	83 c4 10             	add    $0x10,%esp
  801d78:	85 c0                	test   %eax,%eax
  801d7a:	0f 88 24 01 00 00    	js     801ea4 <pipe+0x146>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d80:	83 ec 04             	sub    $0x4,%esp
  801d83:	68 07 04 00 00       	push   $0x407
  801d88:	ff 75 e4             	pushl  -0x1c(%ebp)
  801d8b:	6a 00                	push   $0x0
  801d8d:	e8 22 ef ff ff       	call   800cb4 <sys_page_alloc>
  801d92:	89 c3                	mov    %eax,%ebx
  801d94:	83 c4 10             	add    $0x10,%esp
  801d97:	85 c0                	test   %eax,%eax
  801d99:	0f 88 05 01 00 00    	js     801ea4 <pipe+0x146>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801d9f:	83 ec 0c             	sub    $0xc,%esp
  801da2:	8d 45 e0             	lea    -0x20(%ebp),%eax
  801da5:	50                   	push   %eax
  801da6:	e8 71 f0 ff ff       	call   800e1c <fd_alloc>
  801dab:	89 c3                	mov    %eax,%ebx
  801dad:	83 c4 10             	add    $0x10,%esp
  801db0:	85 c0                	test   %eax,%eax
  801db2:	0f 88 dc 00 00 00    	js     801e94 <pipe+0x136>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801db8:	83 ec 04             	sub    $0x4,%esp
  801dbb:	68 07 04 00 00       	push   $0x407
  801dc0:	ff 75 e0             	pushl  -0x20(%ebp)
  801dc3:	6a 00                	push   $0x0
  801dc5:	e8 ea ee ff ff       	call   800cb4 <sys_page_alloc>
  801dca:	89 c3                	mov    %eax,%ebx
  801dcc:	83 c4 10             	add    $0x10,%esp
  801dcf:	85 c0                	test   %eax,%eax
  801dd1:	0f 88 bd 00 00 00    	js     801e94 <pipe+0x136>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801dd7:	83 ec 0c             	sub    $0xc,%esp
  801dda:	ff 75 e4             	pushl  -0x1c(%ebp)
  801ddd:	e8 22 f0 ff ff       	call   800e04 <fd2data>
  801de2:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801de4:	83 c4 0c             	add    $0xc,%esp
  801de7:	68 07 04 00 00       	push   $0x407
  801dec:	50                   	push   %eax
  801ded:	6a 00                	push   $0x0
  801def:	e8 c0 ee ff ff       	call   800cb4 <sys_page_alloc>
  801df4:	89 c3                	mov    %eax,%ebx
  801df6:	83 c4 10             	add    $0x10,%esp
  801df9:	85 c0                	test   %eax,%eax
  801dfb:	0f 88 83 00 00 00    	js     801e84 <pipe+0x126>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e01:	83 ec 0c             	sub    $0xc,%esp
  801e04:	ff 75 e0             	pushl  -0x20(%ebp)
  801e07:	e8 f8 ef ff ff       	call   800e04 <fd2data>
  801e0c:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801e13:	50                   	push   %eax
  801e14:	6a 00                	push   $0x0
  801e16:	56                   	push   %esi
  801e17:	6a 00                	push   $0x0
  801e19:	e8 ba ee ff ff       	call   800cd8 <sys_page_map>
  801e1e:	89 c3                	mov    %eax,%ebx
  801e20:	83 c4 20             	add    $0x20,%esp
  801e23:	85 c0                	test   %eax,%eax
  801e25:	78 4f                	js     801e76 <pipe+0x118>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801e27:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801e2d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801e30:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801e32:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801e35:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801e3c:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801e42:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801e45:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801e47:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801e4a:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801e51:	83 ec 0c             	sub    $0xc,%esp
  801e54:	ff 75 e4             	pushl  -0x1c(%ebp)
  801e57:	e8 98 ef ff ff       	call   800df4 <fd2num>
  801e5c:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  801e5e:	83 c4 04             	add    $0x4,%esp
  801e61:	ff 75 e0             	pushl  -0x20(%ebp)
  801e64:	e8 8b ef ff ff       	call   800df4 <fd2num>
  801e69:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  801e6c:	83 c4 10             	add    $0x10,%esp
  801e6f:	bb 00 00 00 00       	mov    $0x0,%ebx
  801e74:	eb 2e                	jmp    801ea4 <pipe+0x146>

    err3:
	sys_page_unmap(0, va);
  801e76:	83 ec 08             	sub    $0x8,%esp
  801e79:	56                   	push   %esi
  801e7a:	6a 00                	push   $0x0
  801e7c:	e8 7d ee ff ff       	call   800cfe <sys_page_unmap>
  801e81:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801e84:	83 ec 08             	sub    $0x8,%esp
  801e87:	ff 75 e0             	pushl  -0x20(%ebp)
  801e8a:	6a 00                	push   $0x0
  801e8c:	e8 6d ee ff ff       	call   800cfe <sys_page_unmap>
  801e91:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801e94:	83 ec 08             	sub    $0x8,%esp
  801e97:	ff 75 e4             	pushl  -0x1c(%ebp)
  801e9a:	6a 00                	push   $0x0
  801e9c:	e8 5d ee ff ff       	call   800cfe <sys_page_unmap>
  801ea1:	83 c4 10             	add    $0x10,%esp
    err:
	return r;
}
  801ea4:	89 d8                	mov    %ebx,%eax
  801ea6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ea9:	5b                   	pop    %ebx
  801eaa:	5e                   	pop    %esi
  801eab:	5f                   	pop    %edi
  801eac:	c9                   	leave  
  801ead:	c3                   	ret    

00801eae <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801eae:	55                   	push   %ebp
  801eaf:	89 e5                	mov    %esp,%ebp
  801eb1:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801eb4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801eb7:	50                   	push   %eax
  801eb8:	ff 75 08             	pushl  0x8(%ebp)
  801ebb:	e8 cf ef ff ff       	call   800e8f <fd_lookup>
  801ec0:	83 c4 10             	add    $0x10,%esp
  801ec3:	85 c0                	test   %eax,%eax
  801ec5:	78 18                	js     801edf <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801ec7:	83 ec 0c             	sub    $0xc,%esp
  801eca:	ff 75 f4             	pushl  -0xc(%ebp)
  801ecd:	e8 32 ef ff ff       	call   800e04 <fd2data>
	return _pipeisclosed(fd, p);
  801ed2:	89 c2                	mov    %eax,%edx
  801ed4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ed7:	e8 0c fd ff ff       	call   801be8 <_pipeisclosed>
  801edc:	83 c4 10             	add    $0x10,%esp
}
  801edf:	c9                   	leave  
  801ee0:	c3                   	ret    
  801ee1:	00 00                	add    %al,(%eax)
	...

00801ee4 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801ee4:	55                   	push   %ebp
  801ee5:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801ee7:	b8 00 00 00 00       	mov    $0x0,%eax
  801eec:	c9                   	leave  
  801eed:	c3                   	ret    

00801eee <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801eee:	55                   	push   %ebp
  801eef:	89 e5                	mov    %esp,%ebp
  801ef1:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801ef4:	68 13 2a 80 00       	push   $0x802a13
  801ef9:	ff 75 0c             	pushl  0xc(%ebp)
  801efc:	e8 31 e9 ff ff       	call   800832 <strcpy>
	return 0;
}
  801f01:	b8 00 00 00 00       	mov    $0x0,%eax
  801f06:	c9                   	leave  
  801f07:	c3                   	ret    

00801f08 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801f08:	55                   	push   %ebp
  801f09:	89 e5                	mov    %esp,%ebp
  801f0b:	57                   	push   %edi
  801f0c:	56                   	push   %esi
  801f0d:	53                   	push   %ebx
  801f0e:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801f14:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801f18:	74 45                	je     801f5f <devcons_write+0x57>
  801f1a:	b8 00 00 00 00       	mov    $0x0,%eax
  801f1f:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801f24:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801f2a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801f2d:	29 c3                	sub    %eax,%ebx
		if (m > sizeof(buf) - 1)
  801f2f:	83 fb 7f             	cmp    $0x7f,%ebx
  801f32:	76 05                	jbe    801f39 <devcons_write+0x31>
			m = sizeof(buf) - 1;
  801f34:	bb 7f 00 00 00       	mov    $0x7f,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  801f39:	83 ec 04             	sub    $0x4,%esp
  801f3c:	53                   	push   %ebx
  801f3d:	03 45 0c             	add    0xc(%ebp),%eax
  801f40:	50                   	push   %eax
  801f41:	57                   	push   %edi
  801f42:	e8 ac ea ff ff       	call   8009f3 <memmove>
		sys_cputs(buf, m);
  801f47:	83 c4 08             	add    $0x8,%esp
  801f4a:	53                   	push   %ebx
  801f4b:	57                   	push   %edi
  801f4c:	e8 ac ec ff ff       	call   800bfd <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801f51:	01 de                	add    %ebx,%esi
  801f53:	89 f0                	mov    %esi,%eax
  801f55:	83 c4 10             	add    $0x10,%esp
  801f58:	3b 75 10             	cmp    0x10(%ebp),%esi
  801f5b:	72 cd                	jb     801f2a <devcons_write+0x22>
  801f5d:	eb 05                	jmp    801f64 <devcons_write+0x5c>
  801f5f:	be 00 00 00 00       	mov    $0x0,%esi
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801f64:	89 f0                	mov    %esi,%eax
  801f66:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f69:	5b                   	pop    %ebx
  801f6a:	5e                   	pop    %esi
  801f6b:	5f                   	pop    %edi
  801f6c:	c9                   	leave  
  801f6d:	c3                   	ret    

00801f6e <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801f6e:	55                   	push   %ebp
  801f6f:	89 e5                	mov    %esp,%ebp
  801f71:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  801f74:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801f78:	75 07                	jne    801f81 <devcons_read+0x13>
  801f7a:	eb 25                	jmp    801fa1 <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801f7c:	e8 0c ed ff ff       	call   800c8d <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801f81:	e8 9d ec ff ff       	call   800c23 <sys_cgetc>
  801f86:	85 c0                	test   %eax,%eax
  801f88:	74 f2                	je     801f7c <devcons_read+0xe>
  801f8a:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  801f8c:	85 c0                	test   %eax,%eax
  801f8e:	78 1d                	js     801fad <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801f90:	83 f8 04             	cmp    $0x4,%eax
  801f93:	74 13                	je     801fa8 <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  801f95:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f98:	88 10                	mov    %dl,(%eax)
	return 1;
  801f9a:	b8 01 00 00 00       	mov    $0x1,%eax
  801f9f:	eb 0c                	jmp    801fad <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  801fa1:	b8 00 00 00 00       	mov    $0x0,%eax
  801fa6:	eb 05                	jmp    801fad <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801fa8:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801fad:	c9                   	leave  
  801fae:	c3                   	ret    

00801faf <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801faf:	55                   	push   %ebp
  801fb0:	89 e5                	mov    %esp,%ebp
  801fb2:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801fb5:	8b 45 08             	mov    0x8(%ebp),%eax
  801fb8:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801fbb:	6a 01                	push   $0x1
  801fbd:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801fc0:	50                   	push   %eax
  801fc1:	e8 37 ec ff ff       	call   800bfd <sys_cputs>
  801fc6:	83 c4 10             	add    $0x10,%esp
}
  801fc9:	c9                   	leave  
  801fca:	c3                   	ret    

00801fcb <getchar>:

int
getchar(void)
{
  801fcb:	55                   	push   %ebp
  801fcc:	89 e5                	mov    %esp,%ebp
  801fce:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801fd1:	6a 01                	push   $0x1
  801fd3:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801fd6:	50                   	push   %eax
  801fd7:	6a 00                	push   $0x0
  801fd9:	e8 32 f1 ff ff       	call   801110 <read>
	if (r < 0)
  801fde:	83 c4 10             	add    $0x10,%esp
  801fe1:	85 c0                	test   %eax,%eax
  801fe3:	78 0f                	js     801ff4 <getchar+0x29>
		return r;
	if (r < 1)
  801fe5:	85 c0                	test   %eax,%eax
  801fe7:	7e 06                	jle    801fef <getchar+0x24>
		return -E_EOF;
	return c;
  801fe9:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801fed:	eb 05                	jmp    801ff4 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801fef:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801ff4:	c9                   	leave  
  801ff5:	c3                   	ret    

00801ff6 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801ff6:	55                   	push   %ebp
  801ff7:	89 e5                	mov    %esp,%ebp
  801ff9:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801ffc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801fff:	50                   	push   %eax
  802000:	ff 75 08             	pushl  0x8(%ebp)
  802003:	e8 87 ee ff ff       	call   800e8f <fd_lookup>
  802008:	83 c4 10             	add    $0x10,%esp
  80200b:	85 c0                	test   %eax,%eax
  80200d:	78 11                	js     802020 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  80200f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802012:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  802018:	39 10                	cmp    %edx,(%eax)
  80201a:	0f 94 c0             	sete   %al
  80201d:	0f b6 c0             	movzbl %al,%eax
}
  802020:	c9                   	leave  
  802021:	c3                   	ret    

00802022 <opencons>:

int
opencons(void)
{
  802022:	55                   	push   %ebp
  802023:	89 e5                	mov    %esp,%ebp
  802025:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802028:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80202b:	50                   	push   %eax
  80202c:	e8 eb ed ff ff       	call   800e1c <fd_alloc>
  802031:	83 c4 10             	add    $0x10,%esp
  802034:	85 c0                	test   %eax,%eax
  802036:	78 3a                	js     802072 <opencons+0x50>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802038:	83 ec 04             	sub    $0x4,%esp
  80203b:	68 07 04 00 00       	push   $0x407
  802040:	ff 75 f4             	pushl  -0xc(%ebp)
  802043:	6a 00                	push   $0x0
  802045:	e8 6a ec ff ff       	call   800cb4 <sys_page_alloc>
  80204a:	83 c4 10             	add    $0x10,%esp
  80204d:	85 c0                	test   %eax,%eax
  80204f:	78 21                	js     802072 <opencons+0x50>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  802051:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  802057:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80205a:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80205c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80205f:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  802066:	83 ec 0c             	sub    $0xc,%esp
  802069:	50                   	push   %eax
  80206a:	e8 85 ed ff ff       	call   800df4 <fd2num>
  80206f:	83 c4 10             	add    $0x10,%esp
}
  802072:	c9                   	leave  
  802073:	c3                   	ret    

00802074 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802074:	55                   	push   %ebp
  802075:	89 e5                	mov    %esp,%ebp
  802077:	57                   	push   %edi
  802078:	56                   	push   %esi
  802079:	53                   	push   %ebx
  80207a:	83 ec 0c             	sub    $0xc,%esp
  80207d:	8b 7d 08             	mov    0x8(%ebp),%edi
  802080:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  802083:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	cprintf("0x%x 0x%x 0x%x\n", (uint32_t)from_env_store, (uint32_t)pg, (uint32_t)perm_store);
  802086:	56                   	push   %esi
  802087:	53                   	push   %ebx
  802088:	57                   	push   %edi
  802089:	68 1f 2a 80 00       	push   $0x802a1f
  80208e:	e8 e9 e1 ff ff       	call   80027c <cprintf>
	int r;
	if (pg != NULL) {
  802093:	83 c4 10             	add    $0x10,%esp
  802096:	85 db                	test   %ebx,%ebx
  802098:	74 28                	je     8020c2 <ipc_recv+0x4e>
		cprintf("BEGIN\n");
  80209a:	83 ec 0c             	sub    $0xc,%esp
  80209d:	68 2f 2a 80 00       	push   $0x802a2f
  8020a2:	e8 d5 e1 ff ff       	call   80027c <cprintf>
		r = sys_ipc_recv(pg);
  8020a7:	89 1c 24             	mov    %ebx,(%esp)
  8020aa:	e8 00 ed ff ff       	call   800daf <sys_ipc_recv>
  8020af:	89 c3                	mov    %eax,%ebx
		cprintf("OVER\n");
  8020b1:	c7 04 24 18 29 80 00 	movl   $0x802918,(%esp)
  8020b8:	e8 bf e1 ff ff       	call   80027c <cprintf>
  8020bd:	83 c4 10             	add    $0x10,%esp
  8020c0:	eb 12                	jmp    8020d4 <ipc_recv+0x60>
	} else {
		r = sys_ipc_recv((void *)UTOP);
  8020c2:	83 ec 0c             	sub    $0xc,%esp
  8020c5:	68 00 00 c0 ee       	push   $0xeec00000
  8020ca:	e8 e0 ec ff ff       	call   800daf <sys_ipc_recv>
  8020cf:	89 c3                	mov    %eax,%ebx
  8020d1:	83 c4 10             	add    $0x10,%esp
	}

	if (r == 0) {
  8020d4:	85 db                	test   %ebx,%ebx
  8020d6:	75 26                	jne    8020fe <ipc_recv+0x8a>
		if (from_env_store != NULL) *from_env_store = thisenv->env_ipc_from;
  8020d8:	85 ff                	test   %edi,%edi
  8020da:	74 0a                	je     8020e6 <ipc_recv+0x72>
  8020dc:	a1 04 40 80 00       	mov    0x804004,%eax
  8020e1:	8b 40 74             	mov    0x74(%eax),%eax
  8020e4:	89 07                	mov    %eax,(%edi)
		if (perm_store != NULL) *perm_store = thisenv->env_ipc_perm;
  8020e6:	85 f6                	test   %esi,%esi
  8020e8:	74 0a                	je     8020f4 <ipc_recv+0x80>
  8020ea:	a1 04 40 80 00       	mov    0x804004,%eax
  8020ef:	8b 40 78             	mov    0x78(%eax),%eax
  8020f2:	89 06                	mov    %eax,(%esi)
		return thisenv->env_ipc_value;
  8020f4:	a1 04 40 80 00       	mov    0x804004,%eax
  8020f9:	8b 58 70             	mov    0x70(%eax),%ebx
  8020fc:	eb 14                	jmp    802112 <ipc_recv+0x9e>
	} else {
		// fails;
		if (from_env_store != NULL) *from_env_store = 0;
  8020fe:	85 ff                	test   %edi,%edi
  802100:	74 06                	je     802108 <ipc_recv+0x94>
  802102:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
		if (perm_store != NULL) *perm_store = 0;
  802108:	85 f6                	test   %esi,%esi
  80210a:	74 06                	je     802112 <ipc_recv+0x9e>
  80210c:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		return r;
	}
}
  802112:	89 d8                	mov    %ebx,%eax
  802114:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802117:	5b                   	pop    %ebx
  802118:	5e                   	pop    %esi
  802119:	5f                   	pop    %edi
  80211a:	c9                   	leave  
  80211b:	c3                   	ret    

0080211c <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80211c:	55                   	push   %ebp
  80211d:	89 e5                	mov    %esp,%ebp
  80211f:	57                   	push   %edi
  802120:	56                   	push   %esi
  802121:	53                   	push   %ebx
  802122:	83 ec 0c             	sub    $0xc,%esp
  802125:	8b 7d 0c             	mov    0xc(%ebp),%edi
  802128:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80212b:	8b 75 14             	mov    0x14(%ebp),%esi
	// LAB 4: Your code here.
	// int sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
	int r;
	if (pg == NULL) pg = (void *)UTOP;
  80212e:	85 db                	test   %ebx,%ebx
  802130:	75 25                	jne    802157 <ipc_send+0x3b>
  802132:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
  802137:	eb 1e                	jmp    802157 <ipc_send+0x3b>
	
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) != 0) {
		if (r == -E_IPC_NOT_RECV) {
  802139:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80213c:	75 07                	jne    802145 <ipc_send+0x29>
			// cprintf("Try Again and Again....\n");
			sys_yield();
  80213e:	e8 4a eb ff ff       	call   800c8d <sys_yield>
  802143:	eb 12                	jmp    802157 <ipc_send+0x3b>
		} else {
			panic("ipc_send error %e\n", r);
  802145:	50                   	push   %eax
  802146:	68 36 2a 80 00       	push   $0x802a36
  80214b:	6a 45                	push   $0x45
  80214d:	68 49 2a 80 00       	push   $0x802a49
  802152:	e8 4d e0 ff ff       	call   8001a4 <_panic>
	// LAB 4: Your code here.
	// int sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
	int r;
	if (pg == NULL) pg = (void *)UTOP;
	
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) != 0) {
  802157:	56                   	push   %esi
  802158:	53                   	push   %ebx
  802159:	57                   	push   %edi
  80215a:	ff 75 08             	pushl  0x8(%ebp)
  80215d:	e8 28 ec ff ff       	call   800d8a <sys_ipc_try_send>
  802162:	83 c4 10             	add    $0x10,%esp
  802165:	85 c0                	test   %eax,%eax
  802167:	75 d0                	jne    802139 <ipc_send+0x1d>
		} else {
			panic("ipc_send error %e\n", r);
		}
	}
	return;
}
  802169:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80216c:	5b                   	pop    %ebx
  80216d:	5e                   	pop    %esi
  80216e:	5f                   	pop    %edi
  80216f:	c9                   	leave  
  802170:	c3                   	ret    

00802171 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802171:	55                   	push   %ebp
  802172:	89 e5                	mov    %esp,%ebp
  802174:	53                   	push   %ebx
  802175:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  802178:	39 1d 50 00 c0 ee    	cmp    %ebx,0xeec00050
  80217e:	74 22                	je     8021a2 <ipc_find_env+0x31>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802180:	b8 01 00 00 00       	mov    $0x1,%eax
		if (envs[i].env_type == type)
  802185:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  80218c:	89 c2                	mov    %eax,%edx
  80218e:	c1 e2 07             	shl    $0x7,%edx
  802191:	29 ca                	sub    %ecx,%edx
  802193:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802199:	8b 52 50             	mov    0x50(%edx),%edx
  80219c:	39 da                	cmp    %ebx,%edx
  80219e:	75 1d                	jne    8021bd <ipc_find_env+0x4c>
  8021a0:	eb 05                	jmp    8021a7 <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8021a2:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
			return envs[i].env_id;
  8021a7:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  8021ae:	c1 e0 07             	shl    $0x7,%eax
  8021b1:	29 d0                	sub    %edx,%eax
  8021b3:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  8021b8:	8b 40 40             	mov    0x40(%eax),%eax
  8021bb:	eb 0c                	jmp    8021c9 <ipc_find_env+0x58>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8021bd:	40                   	inc    %eax
  8021be:	3d 00 04 00 00       	cmp    $0x400,%eax
  8021c3:	75 c0                	jne    802185 <ipc_find_env+0x14>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8021c5:	66 b8 00 00          	mov    $0x0,%ax
}
  8021c9:	5b                   	pop    %ebx
  8021ca:	c9                   	leave  
  8021cb:	c3                   	ret    

008021cc <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8021cc:	55                   	push   %ebp
  8021cd:	89 e5                	mov    %esp,%ebp
  8021cf:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8021d2:	89 c2                	mov    %eax,%edx
  8021d4:	c1 ea 16             	shr    $0x16,%edx
  8021d7:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8021de:	f6 c2 01             	test   $0x1,%dl
  8021e1:	74 1e                	je     802201 <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  8021e3:	c1 e8 0c             	shr    $0xc,%eax
  8021e6:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  8021ed:	a8 01                	test   $0x1,%al
  8021ef:	74 17                	je     802208 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8021f1:	c1 e8 0c             	shr    $0xc,%eax
  8021f4:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  8021fb:	ef 
  8021fc:	0f b7 c0             	movzwl %ax,%eax
  8021ff:	eb 0c                	jmp    80220d <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  802201:	b8 00 00 00 00       	mov    $0x0,%eax
  802206:	eb 05                	jmp    80220d <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  802208:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  80220d:	c9                   	leave  
  80220e:	c3                   	ret    
	...

00802210 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  802210:	55                   	push   %ebp
  802211:	89 e5                	mov    %esp,%ebp
  802213:	57                   	push   %edi
  802214:	56                   	push   %esi
  802215:	83 ec 10             	sub    $0x10,%esp
  802218:	8b 7d 08             	mov    0x8(%ebp),%edi
  80221b:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  80221e:	89 7d f0             	mov    %edi,-0x10(%ebp)
  802221:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  802224:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  802227:	8b 45 14             	mov    0x14(%ebp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  80222a:	85 c0                	test   %eax,%eax
  80222c:	75 2e                	jne    80225c <__udivdi3+0x4c>
    {
      if (d0 > n1)
  80222e:	39 f1                	cmp    %esi,%ecx
  802230:	77 5a                	ja     80228c <__udivdi3+0x7c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  802232:	85 c9                	test   %ecx,%ecx
  802234:	75 0b                	jne    802241 <__udivdi3+0x31>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  802236:	b8 01 00 00 00       	mov    $0x1,%eax
  80223b:	31 d2                	xor    %edx,%edx
  80223d:	f7 f1                	div    %ecx
  80223f:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  802241:	31 d2                	xor    %edx,%edx
  802243:	89 f0                	mov    %esi,%eax
  802245:	f7 f1                	div    %ecx
  802247:	89 c6                	mov    %eax,%esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802249:	89 f8                	mov    %edi,%eax
  80224b:	f7 f1                	div    %ecx
  80224d:	89 c7                	mov    %eax,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  80224f:	89 f8                	mov    %edi,%eax
  802251:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802253:	83 c4 10             	add    $0x10,%esp
  802256:	5e                   	pop    %esi
  802257:	5f                   	pop    %edi
  802258:	c9                   	leave  
  802259:	c3                   	ret    
  80225a:	66 90                	xchg   %ax,%ax
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  80225c:	39 f0                	cmp    %esi,%eax
  80225e:	77 1c                	ja     80227c <__udivdi3+0x6c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  802260:	0f bd f8             	bsr    %eax,%edi
	  if (bm == 0)
  802263:	83 f7 1f             	xor    $0x1f,%edi
  802266:	75 3c                	jne    8022a4 <__udivdi3+0x94>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802268:	39 f0                	cmp    %esi,%eax
  80226a:	0f 82 90 00 00 00    	jb     802300 <__udivdi3+0xf0>
  802270:	8b 55 f0             	mov    -0x10(%ebp),%edx
  802273:	39 55 f4             	cmp    %edx,-0xc(%ebp)
  802276:	0f 86 84 00 00 00    	jbe    802300 <__udivdi3+0xf0>
  80227c:	31 f6                	xor    %esi,%esi
  80227e:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  802280:	89 f8                	mov    %edi,%eax
  802282:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802284:	83 c4 10             	add    $0x10,%esp
  802287:	5e                   	pop    %esi
  802288:	5f                   	pop    %edi
  802289:	c9                   	leave  
  80228a:	c3                   	ret    
  80228b:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  80228c:	89 f2                	mov    %esi,%edx
  80228e:	89 f8                	mov    %edi,%eax
  802290:	f7 f1                	div    %ecx
  802292:	89 c7                	mov    %eax,%edi
  802294:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  802296:	89 f8                	mov    %edi,%eax
  802298:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  80229a:	83 c4 10             	add    $0x10,%esp
  80229d:	5e                   	pop    %esi
  80229e:	5f                   	pop    %edi
  80229f:	c9                   	leave  
  8022a0:	c3                   	ret    
  8022a1:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  8022a4:	89 f9                	mov    %edi,%ecx
  8022a6:	d3 e0                	shl    %cl,%eax
  8022a8:	89 45 e8             	mov    %eax,-0x18(%ebp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  8022ab:	b8 20 00 00 00       	mov    $0x20,%eax
  8022b0:	29 f8                	sub    %edi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  8022b2:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8022b5:	88 c1                	mov    %al,%cl
  8022b7:	d3 ea                	shr    %cl,%edx
  8022b9:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  8022bc:	09 ca                	or     %ecx,%edx
  8022be:	89 55 ec             	mov    %edx,-0x14(%ebp)
	      d0 = d0 << bm;
  8022c1:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8022c4:	89 f9                	mov    %edi,%ecx
  8022c6:	d3 e2                	shl    %cl,%edx
  8022c8:	89 55 f4             	mov    %edx,-0xc(%ebp)
	      n2 = n1 >> b;
  8022cb:	89 f2                	mov    %esi,%edx
  8022cd:	88 c1                	mov    %al,%cl
  8022cf:	d3 ea                	shr    %cl,%edx
  8022d1:	89 55 e8             	mov    %edx,-0x18(%ebp)
	      n1 = (n1 << bm) | (n0 >> b);
  8022d4:	89 f2                	mov    %esi,%edx
  8022d6:	89 f9                	mov    %edi,%ecx
  8022d8:	d3 e2                	shl    %cl,%edx
  8022da:	8b 75 f0             	mov    -0x10(%ebp),%esi
  8022dd:	88 c1                	mov    %al,%cl
  8022df:	d3 ee                	shr    %cl,%esi
  8022e1:	09 d6                	or     %edx,%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  8022e3:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  8022e6:	89 f0                	mov    %esi,%eax
  8022e8:	89 ca                	mov    %ecx,%edx
  8022ea:	f7 75 ec             	divl   -0x14(%ebp)
  8022ed:	89 d1                	mov    %edx,%ecx
  8022ef:	89 c6                	mov    %eax,%esi
	      umul_ppmm (m1, m0, q0, d0);
  8022f1:	f7 65 f4             	mull   -0xc(%ebp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8022f4:	39 d1                	cmp    %edx,%ecx
  8022f6:	72 28                	jb     802320 <__udivdi3+0x110>
  8022f8:	74 1a                	je     802314 <__udivdi3+0x104>
  8022fa:	89 f7                	mov    %esi,%edi
  8022fc:	31 f6                	xor    %esi,%esi
  8022fe:	eb 80                	jmp    802280 <__udivdi3+0x70>
	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  802300:	31 f6                	xor    %esi,%esi
  802302:	bf 01 00 00 00       	mov    $0x1,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  802307:	89 f8                	mov    %edi,%eax
  802309:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  80230b:	83 c4 10             	add    $0x10,%esp
  80230e:	5e                   	pop    %esi
  80230f:	5f                   	pop    %edi
  802310:	c9                   	leave  
  802311:	c3                   	ret    
  802312:	66 90                	xchg   %ax,%ax

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  802314:	8b 55 f0             	mov    -0x10(%ebp),%edx
  802317:	89 f9                	mov    %edi,%ecx
  802319:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  80231b:	39 c2                	cmp    %eax,%edx
  80231d:	73 db                	jae    8022fa <__udivdi3+0xea>
  80231f:	90                   	nop
		{
		  q0--;
  802320:	8d 7e ff             	lea    -0x1(%esi),%edi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  802323:	31 f6                	xor    %esi,%esi
  802325:	e9 56 ff ff ff       	jmp    802280 <__udivdi3+0x70>
	...

0080232c <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  80232c:	55                   	push   %ebp
  80232d:	89 e5                	mov    %esp,%ebp
  80232f:	57                   	push   %edi
  802330:	56                   	push   %esi
  802331:	83 ec 20             	sub    $0x20,%esp
  802334:	8b 45 08             	mov    0x8(%ebp),%eax
  802337:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  80233a:	89 45 e8             	mov    %eax,-0x18(%ebp)
  80233d:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  802340:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  802343:	8b 7d 14             	mov    0x14(%ebp),%edi
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  802346:	89 45 f0             	mov    %eax,-0x10(%ebp)
  n1 = nn.s.high;
  802349:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  80234b:	85 ff                	test   %edi,%edi
  80234d:	75 15                	jne    802364 <__umoddi3+0x38>
    {
      if (d0 > n1)
  80234f:	39 f1                	cmp    %esi,%ecx
  802351:	0f 86 99 00 00 00    	jbe    8023f0 <__umoddi3+0xc4>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802357:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  802359:	89 d0                	mov    %edx,%eax
  80235b:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  80235d:	83 c4 20             	add    $0x20,%esp
  802360:	5e                   	pop    %esi
  802361:	5f                   	pop    %edi
  802362:	c9                   	leave  
  802363:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  802364:	39 f7                	cmp    %esi,%edi
  802366:	0f 87 a4 00 00 00    	ja     802410 <__umoddi3+0xe4>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  80236c:	0f bd c7             	bsr    %edi,%eax
	  if (bm == 0)
  80236f:	83 f0 1f             	xor    $0x1f,%eax
  802372:	89 45 ec             	mov    %eax,-0x14(%ebp)
  802375:	0f 84 a1 00 00 00    	je     80241c <__umoddi3+0xf0>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  80237b:	89 f8                	mov    %edi,%eax
  80237d:	8a 4d ec             	mov    -0x14(%ebp),%cl
  802380:	d3 e0                	shl    %cl,%eax
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  802382:	bf 20 00 00 00       	mov    $0x20,%edi
  802387:	2b 7d ec             	sub    -0x14(%ebp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  80238a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80238d:	89 f9                	mov    %edi,%ecx
  80238f:	d3 ea                	shr    %cl,%edx
  802391:	09 c2                	or     %eax,%edx
  802393:	89 55 f0             	mov    %edx,-0x10(%ebp)
	      d0 = d0 << bm;
  802396:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802399:	8a 4d ec             	mov    -0x14(%ebp),%cl
  80239c:	d3 e0                	shl    %cl,%eax
  80239e:	89 45 f4             	mov    %eax,-0xc(%ebp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  8023a1:	89 f2                	mov    %esi,%edx
  8023a3:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  8023a5:	8b 45 e8             	mov    -0x18(%ebp),%eax
  8023a8:	d3 e0                	shl    %cl,%eax
  8023aa:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  8023ad:	8b 45 e8             	mov    -0x18(%ebp),%eax
  8023b0:	89 f9                	mov    %edi,%ecx
  8023b2:	d3 e8                	shr    %cl,%eax
  8023b4:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  8023b6:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  8023b8:	89 f2                	mov    %esi,%edx
  8023ba:	f7 75 f0             	divl   -0x10(%ebp)
  8023bd:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  8023bf:	f7 65 f4             	mull   -0xc(%ebp)
  8023c2:	89 55 e8             	mov    %edx,-0x18(%ebp)
  8023c5:	89 c1                	mov    %eax,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8023c7:	39 d6                	cmp    %edx,%esi
  8023c9:	72 71                	jb     80243c <__umoddi3+0x110>
  8023cb:	74 7f                	je     80244c <__umoddi3+0x120>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  8023cd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8023d0:	29 c8                	sub    %ecx,%eax
  8023d2:	19 d6                	sbb    %edx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  8023d4:	8a 4d ec             	mov    -0x14(%ebp),%cl
  8023d7:	d3 e8                	shr    %cl,%eax
  8023d9:	89 f2                	mov    %esi,%edx
  8023db:	89 f9                	mov    %edi,%ecx
  8023dd:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  8023df:	09 d0                	or     %edx,%eax
  8023e1:	89 f2                	mov    %esi,%edx
  8023e3:	8a 4d ec             	mov    -0x14(%ebp),%cl
  8023e6:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8023e8:	83 c4 20             	add    $0x20,%esp
  8023eb:	5e                   	pop    %esi
  8023ec:	5f                   	pop    %edi
  8023ed:	c9                   	leave  
  8023ee:	c3                   	ret    
  8023ef:	90                   	nop
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  8023f0:	85 c9                	test   %ecx,%ecx
  8023f2:	75 0b                	jne    8023ff <__umoddi3+0xd3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  8023f4:	b8 01 00 00 00       	mov    $0x1,%eax
  8023f9:	31 d2                	xor    %edx,%edx
  8023fb:	f7 f1                	div    %ecx
  8023fd:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  8023ff:	89 f0                	mov    %esi,%eax
  802401:	31 d2                	xor    %edx,%edx
  802403:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802405:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802408:	f7 f1                	div    %ecx
  80240a:	e9 4a ff ff ff       	jmp    802359 <__umoddi3+0x2d>
  80240f:	90                   	nop
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  802410:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802412:	83 c4 20             	add    $0x20,%esp
  802415:	5e                   	pop    %esi
  802416:	5f                   	pop    %edi
  802417:	c9                   	leave  
  802418:	c3                   	ret    
  802419:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  80241c:	39 f7                	cmp    %esi,%edi
  80241e:	72 05                	jb     802425 <__umoddi3+0xf9>
  802420:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
  802423:	77 0c                	ja     802431 <__umoddi3+0x105>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  802425:	89 f2                	mov    %esi,%edx
  802427:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80242a:	29 c8                	sub    %ecx,%eax
  80242c:	19 fa                	sbb    %edi,%edx
  80242e:	89 45 f0             	mov    %eax,-0x10(%ebp)

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  802431:	8b 45 f0             	mov    -0x10(%ebp),%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802434:	83 c4 20             	add    $0x20,%esp
  802437:	5e                   	pop    %esi
  802438:	5f                   	pop    %edi
  802439:	c9                   	leave  
  80243a:	c3                   	ret    
  80243b:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  80243c:	8b 55 e8             	mov    -0x18(%ebp),%edx
  80243f:	89 c1                	mov    %eax,%ecx
  802441:	2b 4d f4             	sub    -0xc(%ebp),%ecx
  802444:	1b 55 f0             	sbb    -0x10(%ebp),%edx
  802447:	eb 84                	jmp    8023cd <__umoddi3+0xa1>
  802449:	8d 76 00             	lea    0x0(%esi),%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  80244c:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  80244f:	72 eb                	jb     80243c <__umoddi3+0x110>
  802451:	89 f2                	mov    %esi,%edx
  802453:	e9 75 ff ff ff       	jmp    8023cd <__umoddi3+0xa1>
