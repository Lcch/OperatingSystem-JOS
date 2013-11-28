
obj/user/cat.debug:     file format elf32-i386


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
  80002c:	e8 0f 01 00 00       	call   800140 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <cat>:

char buf[8192];

void
cat(int f, char *s)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	57                   	push   %edi
  800038:	56                   	push   %esi
  800039:	53                   	push   %ebx
  80003a:	83 ec 0c             	sub    $0xc,%esp
  80003d:	8b 75 08             	mov    0x8(%ebp),%esi
  800040:	8b 7d 0c             	mov    0xc(%ebp),%edi
	long n;
	int r;

	while ((n = read(f, buf, (long)sizeof(buf))) > 0)
  800043:	eb 2d                	jmp    800072 <cat+0x3e>
		if ((r = write(1, buf, n)) != n)
  800045:	83 ec 04             	sub    $0x4,%esp
  800048:	53                   	push   %ebx
  800049:	68 20 40 80 00       	push   $0x804020
  80004e:	6a 01                	push   $0x1
  800050:	e8 c7 11 00 00       	call   80121c <write>
  800055:	83 c4 10             	add    $0x10,%esp
  800058:	39 d8                	cmp    %ebx,%eax
  80005a:	74 16                	je     800072 <cat+0x3e>
			panic("write error copying %s: %e", s, r);
  80005c:	83 ec 0c             	sub    $0xc,%esp
  80005f:	50                   	push   %eax
  800060:	57                   	push   %edi
  800061:	68 a0 1f 80 00       	push   $0x801fa0
  800066:	6a 0d                	push   $0xd
  800068:	68 bb 1f 80 00       	push   $0x801fbb
  80006d:	e8 3a 01 00 00       	call   8001ac <_panic>
cat(int f, char *s)
{
	long n;
	int r;

	while ((n = read(f, buf, (long)sizeof(buf))) > 0)
  800072:	83 ec 04             	sub    $0x4,%esp
  800075:	68 00 20 00 00       	push   $0x2000
  80007a:	68 20 40 80 00       	push   $0x804020
  80007f:	56                   	push   %esi
  800080:	e8 bb 10 00 00       	call   801140 <read>
  800085:	89 c3                	mov    %eax,%ebx
  800087:	83 c4 10             	add    $0x10,%esp
  80008a:	85 c0                	test   %eax,%eax
  80008c:	7f b7                	jg     800045 <cat+0x11>
		if ((r = write(1, buf, n)) != n)
			panic("write error copying %s: %e", s, r);
	if (n < 0)
  80008e:	85 c0                	test   %eax,%eax
  800090:	79 16                	jns    8000a8 <cat+0x74>
		panic("error reading %s: %e", s, n);
  800092:	83 ec 0c             	sub    $0xc,%esp
  800095:	50                   	push   %eax
  800096:	57                   	push   %edi
  800097:	68 c6 1f 80 00       	push   $0x801fc6
  80009c:	6a 0f                	push   $0xf
  80009e:	68 bb 1f 80 00       	push   $0x801fbb
  8000a3:	e8 04 01 00 00       	call   8001ac <_panic>
}
  8000a8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8000ab:	5b                   	pop    %ebx
  8000ac:	5e                   	pop    %esi
  8000ad:	5f                   	pop    %edi
  8000ae:	c9                   	leave  
  8000af:	c3                   	ret    

008000b0 <umain>:

void
umain(int argc, char **argv)
{
  8000b0:	55                   	push   %ebp
  8000b1:	89 e5                	mov    %esp,%ebp
  8000b3:	57                   	push   %edi
  8000b4:	56                   	push   %esi
  8000b5:	53                   	push   %ebx
  8000b6:	83 ec 0c             	sub    $0xc,%esp
  8000b9:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int f, i;

	binaryname = "cat";
  8000bc:	c7 05 00 30 80 00 db 	movl   $0x801fdb,0x803000
  8000c3:	1f 80 00 
	if (argc == 1)
  8000c6:	83 7d 08 01          	cmpl   $0x1,0x8(%ebp)
  8000ca:	74 08                	je     8000d4 <umain+0x24>
		cat(0, "<stdin>");
	else
		for (i = 1; i < argc; i++) {
  8000cc:	83 7d 08 01          	cmpl   $0x1,0x8(%ebp)
  8000d0:	7f 16                	jg     8000e8 <umain+0x38>
  8000d2:	eb 62                	jmp    800136 <umain+0x86>
{
	int f, i;

	binaryname = "cat";
	if (argc == 1)
		cat(0, "<stdin>");
  8000d4:	83 ec 08             	sub    $0x8,%esp
  8000d7:	68 df 1f 80 00       	push   $0x801fdf
  8000dc:	6a 00                	push   $0x0
  8000de:	e8 51 ff ff ff       	call   800034 <cat>
  8000e3:	83 c4 10             	add    $0x10,%esp
  8000e6:	eb 4e                	jmp    800136 <umain+0x86>
	else
		for (i = 1; i < argc; i++) {
  8000e8:	be 01 00 00 00       	mov    $0x1,%esi
			f = open(argv[i], O_RDONLY);
  8000ed:	83 ec 08             	sub    $0x8,%esp
  8000f0:	6a 00                	push   $0x0
  8000f2:	ff 34 b7             	pushl  (%edi,%esi,4)
  8000f5:	e8 4a 14 00 00       	call   801544 <open>
  8000fa:	89 c3                	mov    %eax,%ebx
			if (f < 0)
  8000fc:	83 c4 10             	add    $0x10,%esp
  8000ff:	85 c0                	test   %eax,%eax
  800101:	79 16                	jns    800119 <umain+0x69>
				printf("can't open %s: %e\n", argv[i], f);
  800103:	83 ec 04             	sub    $0x4,%esp
  800106:	50                   	push   %eax
  800107:	ff 34 b7             	pushl  (%edi,%esi,4)
  80010a:	68 e7 1f 80 00       	push   $0x801fe7
  80010f:	e8 bc 15 00 00       	call   8016d0 <printf>
  800114:	83 c4 10             	add    $0x10,%esp
  800117:	eb 17                	jmp    800130 <umain+0x80>
			else {
				cat(f, argv[i]);
  800119:	83 ec 08             	sub    $0x8,%esp
  80011c:	ff 34 b7             	pushl  (%edi,%esi,4)
  80011f:	50                   	push   %eax
  800120:	e8 0f ff ff ff       	call   800034 <cat>
				close(f);
  800125:	89 1c 24             	mov    %ebx,(%esp)
  800128:	e8 d6 0e 00 00       	call   801003 <close>
  80012d:	83 c4 10             	add    $0x10,%esp

	binaryname = "cat";
	if (argc == 1)
		cat(0, "<stdin>");
	else
		for (i = 1; i < argc; i++) {
  800130:	46                   	inc    %esi
  800131:	39 75 08             	cmp    %esi,0x8(%ebp)
  800134:	7f b7                	jg     8000ed <umain+0x3d>
			else {
				cat(f, argv[i]);
				close(f);
			}
		}
}
  800136:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800139:	5b                   	pop    %ebx
  80013a:	5e                   	pop    %esi
  80013b:	5f                   	pop    %edi
  80013c:	c9                   	leave  
  80013d:	c3                   	ret    
	...

00800140 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800140:	55                   	push   %ebp
  800141:	89 e5                	mov    %esp,%ebp
  800143:	56                   	push   %esi
  800144:	53                   	push   %ebx
  800145:	8b 75 08             	mov    0x8(%ebp),%esi
  800148:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs + ENVX(sys_getenvid());
  80014b:	e8 21 0b 00 00       	call   800c71 <sys_getenvid>
  800150:	25 ff 03 00 00       	and    $0x3ff,%eax
  800155:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  80015c:	c1 e0 07             	shl    $0x7,%eax
  80015f:	29 d0                	sub    %edx,%eax
  800161:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800166:	a3 20 60 80 00       	mov    %eax,0x806020

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80016b:	85 f6                	test   %esi,%esi
  80016d:	7e 07                	jle    800176 <libmain+0x36>
		binaryname = argv[0];
  80016f:	8b 03                	mov    (%ebx),%eax
  800171:	a3 00 30 80 00       	mov    %eax,0x803000
	// call user main routine
	umain(argc, argv);
  800176:	83 ec 08             	sub    $0x8,%esp
  800179:	53                   	push   %ebx
  80017a:	56                   	push   %esi
  80017b:	e8 30 ff ff ff       	call   8000b0 <umain>

	// exit gracefully
	exit();
  800180:	e8 0b 00 00 00       	call   800190 <exit>
  800185:	83 c4 10             	add    $0x10,%esp
}
  800188:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80018b:	5b                   	pop    %ebx
  80018c:	5e                   	pop    %esi
  80018d:	c9                   	leave  
  80018e:	c3                   	ret    
	...

00800190 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800190:	55                   	push   %ebp
  800191:	89 e5                	mov    %esp,%ebp
  800193:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800196:	e8 93 0e 00 00       	call   80102e <close_all>
	sys_env_destroy(0);
  80019b:	83 ec 0c             	sub    $0xc,%esp
  80019e:	6a 00                	push   $0x0
  8001a0:	e8 aa 0a 00 00       	call   800c4f <sys_env_destroy>
  8001a5:	83 c4 10             	add    $0x10,%esp
}
  8001a8:	c9                   	leave  
  8001a9:	c3                   	ret    
	...

008001ac <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8001ac:	55                   	push   %ebp
  8001ad:	89 e5                	mov    %esp,%ebp
  8001af:	56                   	push   %esi
  8001b0:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8001b1:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8001b4:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  8001ba:	e8 b2 0a 00 00       	call   800c71 <sys_getenvid>
  8001bf:	83 ec 0c             	sub    $0xc,%esp
  8001c2:	ff 75 0c             	pushl  0xc(%ebp)
  8001c5:	ff 75 08             	pushl  0x8(%ebp)
  8001c8:	53                   	push   %ebx
  8001c9:	50                   	push   %eax
  8001ca:	68 04 20 80 00       	push   $0x802004
  8001cf:	e8 b0 00 00 00       	call   800284 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8001d4:	83 c4 18             	add    $0x18,%esp
  8001d7:	56                   	push   %esi
  8001d8:	ff 75 10             	pushl  0x10(%ebp)
  8001db:	e8 53 00 00 00       	call   800233 <vcprintf>
	cprintf("\n");
  8001e0:	c7 04 24 27 24 80 00 	movl   $0x802427,(%esp)
  8001e7:	e8 98 00 00 00       	call   800284 <cprintf>
  8001ec:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8001ef:	cc                   	int3   
  8001f0:	eb fd                	jmp    8001ef <_panic+0x43>
	...

008001f4 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001f4:	55                   	push   %ebp
  8001f5:	89 e5                	mov    %esp,%ebp
  8001f7:	53                   	push   %ebx
  8001f8:	83 ec 04             	sub    $0x4,%esp
  8001fb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001fe:	8b 03                	mov    (%ebx),%eax
  800200:	8b 55 08             	mov    0x8(%ebp),%edx
  800203:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  800207:	40                   	inc    %eax
  800208:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  80020a:	3d ff 00 00 00       	cmp    $0xff,%eax
  80020f:	75 1a                	jne    80022b <putch+0x37>
		sys_cputs(b->buf, b->idx);
  800211:	83 ec 08             	sub    $0x8,%esp
  800214:	68 ff 00 00 00       	push   $0xff
  800219:	8d 43 08             	lea    0x8(%ebx),%eax
  80021c:	50                   	push   %eax
  80021d:	e8 e3 09 00 00       	call   800c05 <sys_cputs>
		b->idx = 0;
  800222:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800228:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80022b:	ff 43 04             	incl   0x4(%ebx)
}
  80022e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800231:	c9                   	leave  
  800232:	c3                   	ret    

00800233 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800233:	55                   	push   %ebp
  800234:	89 e5                	mov    %esp,%ebp
  800236:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80023c:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800243:	00 00 00 
	b.cnt = 0;
  800246:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80024d:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800250:	ff 75 0c             	pushl  0xc(%ebp)
  800253:	ff 75 08             	pushl  0x8(%ebp)
  800256:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80025c:	50                   	push   %eax
  80025d:	68 f4 01 80 00       	push   $0x8001f4
  800262:	e8 82 01 00 00       	call   8003e9 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800267:	83 c4 08             	add    $0x8,%esp
  80026a:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800270:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800276:	50                   	push   %eax
  800277:	e8 89 09 00 00       	call   800c05 <sys_cputs>

	return b.cnt;
}
  80027c:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800282:	c9                   	leave  
  800283:	c3                   	ret    

00800284 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800284:	55                   	push   %ebp
  800285:	89 e5                	mov    %esp,%ebp
  800287:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80028a:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80028d:	50                   	push   %eax
  80028e:	ff 75 08             	pushl  0x8(%ebp)
  800291:	e8 9d ff ff ff       	call   800233 <vcprintf>
	va_end(ap);

	return cnt;
}
  800296:	c9                   	leave  
  800297:	c3                   	ret    

00800298 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800298:	55                   	push   %ebp
  800299:	89 e5                	mov    %esp,%ebp
  80029b:	57                   	push   %edi
  80029c:	56                   	push   %esi
  80029d:	53                   	push   %ebx
  80029e:	83 ec 2c             	sub    $0x2c,%esp
  8002a1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8002a4:	89 d6                	mov    %edx,%esi
  8002a6:	8b 45 08             	mov    0x8(%ebp),%eax
  8002a9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002ac:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8002af:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8002b2:	8b 45 10             	mov    0x10(%ebp),%eax
  8002b5:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8002b8:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8002bb:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8002be:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  8002c5:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
  8002c8:	72 0c                	jb     8002d6 <printnum+0x3e>
  8002ca:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  8002cd:	76 07                	jbe    8002d6 <printnum+0x3e>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002cf:	4b                   	dec    %ebx
  8002d0:	85 db                	test   %ebx,%ebx
  8002d2:	7f 31                	jg     800305 <printnum+0x6d>
  8002d4:	eb 3f                	jmp    800315 <printnum+0x7d>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002d6:	83 ec 0c             	sub    $0xc,%esp
  8002d9:	57                   	push   %edi
  8002da:	4b                   	dec    %ebx
  8002db:	53                   	push   %ebx
  8002dc:	50                   	push   %eax
  8002dd:	83 ec 08             	sub    $0x8,%esp
  8002e0:	ff 75 d4             	pushl  -0x2c(%ebp)
  8002e3:	ff 75 d0             	pushl  -0x30(%ebp)
  8002e6:	ff 75 dc             	pushl  -0x24(%ebp)
  8002e9:	ff 75 d8             	pushl  -0x28(%ebp)
  8002ec:	e8 67 1a 00 00       	call   801d58 <__udivdi3>
  8002f1:	83 c4 18             	add    $0x18,%esp
  8002f4:	52                   	push   %edx
  8002f5:	50                   	push   %eax
  8002f6:	89 f2                	mov    %esi,%edx
  8002f8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8002fb:	e8 98 ff ff ff       	call   800298 <printnum>
  800300:	83 c4 20             	add    $0x20,%esp
  800303:	eb 10                	jmp    800315 <printnum+0x7d>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800305:	83 ec 08             	sub    $0x8,%esp
  800308:	56                   	push   %esi
  800309:	57                   	push   %edi
  80030a:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80030d:	4b                   	dec    %ebx
  80030e:	83 c4 10             	add    $0x10,%esp
  800311:	85 db                	test   %ebx,%ebx
  800313:	7f f0                	jg     800305 <printnum+0x6d>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800315:	83 ec 08             	sub    $0x8,%esp
  800318:	56                   	push   %esi
  800319:	83 ec 04             	sub    $0x4,%esp
  80031c:	ff 75 d4             	pushl  -0x2c(%ebp)
  80031f:	ff 75 d0             	pushl  -0x30(%ebp)
  800322:	ff 75 dc             	pushl  -0x24(%ebp)
  800325:	ff 75 d8             	pushl  -0x28(%ebp)
  800328:	e8 47 1b 00 00       	call   801e74 <__umoddi3>
  80032d:	83 c4 14             	add    $0x14,%esp
  800330:	0f be 80 27 20 80 00 	movsbl 0x802027(%eax),%eax
  800337:	50                   	push   %eax
  800338:	ff 55 e4             	call   *-0x1c(%ebp)
  80033b:	83 c4 10             	add    $0x10,%esp
}
  80033e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800341:	5b                   	pop    %ebx
  800342:	5e                   	pop    %esi
  800343:	5f                   	pop    %edi
  800344:	c9                   	leave  
  800345:	c3                   	ret    

00800346 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800346:	55                   	push   %ebp
  800347:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800349:	83 fa 01             	cmp    $0x1,%edx
  80034c:	7e 0e                	jle    80035c <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80034e:	8b 10                	mov    (%eax),%edx
  800350:	8d 4a 08             	lea    0x8(%edx),%ecx
  800353:	89 08                	mov    %ecx,(%eax)
  800355:	8b 02                	mov    (%edx),%eax
  800357:	8b 52 04             	mov    0x4(%edx),%edx
  80035a:	eb 22                	jmp    80037e <getuint+0x38>
	else if (lflag)
  80035c:	85 d2                	test   %edx,%edx
  80035e:	74 10                	je     800370 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800360:	8b 10                	mov    (%eax),%edx
  800362:	8d 4a 04             	lea    0x4(%edx),%ecx
  800365:	89 08                	mov    %ecx,(%eax)
  800367:	8b 02                	mov    (%edx),%eax
  800369:	ba 00 00 00 00       	mov    $0x0,%edx
  80036e:	eb 0e                	jmp    80037e <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800370:	8b 10                	mov    (%eax),%edx
  800372:	8d 4a 04             	lea    0x4(%edx),%ecx
  800375:	89 08                	mov    %ecx,(%eax)
  800377:	8b 02                	mov    (%edx),%eax
  800379:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80037e:	c9                   	leave  
  80037f:	c3                   	ret    

00800380 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  800380:	55                   	push   %ebp
  800381:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800383:	83 fa 01             	cmp    $0x1,%edx
  800386:	7e 0e                	jle    800396 <getint+0x16>
		return va_arg(*ap, long long);
  800388:	8b 10                	mov    (%eax),%edx
  80038a:	8d 4a 08             	lea    0x8(%edx),%ecx
  80038d:	89 08                	mov    %ecx,(%eax)
  80038f:	8b 02                	mov    (%edx),%eax
  800391:	8b 52 04             	mov    0x4(%edx),%edx
  800394:	eb 1a                	jmp    8003b0 <getint+0x30>
	else if (lflag)
  800396:	85 d2                	test   %edx,%edx
  800398:	74 0c                	je     8003a6 <getint+0x26>
		return va_arg(*ap, long);
  80039a:	8b 10                	mov    (%eax),%edx
  80039c:	8d 4a 04             	lea    0x4(%edx),%ecx
  80039f:	89 08                	mov    %ecx,(%eax)
  8003a1:	8b 02                	mov    (%edx),%eax
  8003a3:	99                   	cltd   
  8003a4:	eb 0a                	jmp    8003b0 <getint+0x30>
	else
		return va_arg(*ap, int);
  8003a6:	8b 10                	mov    (%eax),%edx
  8003a8:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003ab:	89 08                	mov    %ecx,(%eax)
  8003ad:	8b 02                	mov    (%edx),%eax
  8003af:	99                   	cltd   
}
  8003b0:	c9                   	leave  
  8003b1:	c3                   	ret    

008003b2 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8003b2:	55                   	push   %ebp
  8003b3:	89 e5                	mov    %esp,%ebp
  8003b5:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8003b8:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  8003bb:	8b 10                	mov    (%eax),%edx
  8003bd:	3b 50 04             	cmp    0x4(%eax),%edx
  8003c0:	73 08                	jae    8003ca <sprintputch+0x18>
		*b->buf++ = ch;
  8003c2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8003c5:	88 0a                	mov    %cl,(%edx)
  8003c7:	42                   	inc    %edx
  8003c8:	89 10                	mov    %edx,(%eax)
}
  8003ca:	c9                   	leave  
  8003cb:	c3                   	ret    

008003cc <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8003cc:	55                   	push   %ebp
  8003cd:	89 e5                	mov    %esp,%ebp
  8003cf:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8003d2:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8003d5:	50                   	push   %eax
  8003d6:	ff 75 10             	pushl  0x10(%ebp)
  8003d9:	ff 75 0c             	pushl  0xc(%ebp)
  8003dc:	ff 75 08             	pushl  0x8(%ebp)
  8003df:	e8 05 00 00 00       	call   8003e9 <vprintfmt>
	va_end(ap);
  8003e4:	83 c4 10             	add    $0x10,%esp
}
  8003e7:	c9                   	leave  
  8003e8:	c3                   	ret    

008003e9 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8003e9:	55                   	push   %ebp
  8003ea:	89 e5                	mov    %esp,%ebp
  8003ec:	57                   	push   %edi
  8003ed:	56                   	push   %esi
  8003ee:	53                   	push   %ebx
  8003ef:	83 ec 2c             	sub    $0x2c,%esp
  8003f2:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8003f5:	8b 75 10             	mov    0x10(%ebp),%esi
  8003f8:	eb 13                	jmp    80040d <vprintfmt+0x24>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8003fa:	85 c0                	test   %eax,%eax
  8003fc:	0f 84 6d 03 00 00    	je     80076f <vprintfmt+0x386>
				return;
			putch(ch, putdat);
  800402:	83 ec 08             	sub    $0x8,%esp
  800405:	57                   	push   %edi
  800406:	50                   	push   %eax
  800407:	ff 55 08             	call   *0x8(%ebp)
  80040a:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80040d:	0f b6 06             	movzbl (%esi),%eax
  800410:	46                   	inc    %esi
  800411:	83 f8 25             	cmp    $0x25,%eax
  800414:	75 e4                	jne    8003fa <vprintfmt+0x11>
  800416:	c6 45 dc 20          	movb   $0x20,-0x24(%ebp)
  80041a:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  800421:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  800428:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  80042f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800434:	eb 28                	jmp    80045e <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800436:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800438:	c6 45 dc 2d          	movb   $0x2d,-0x24(%ebp)
  80043c:	eb 20                	jmp    80045e <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80043e:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800440:	c6 45 dc 30          	movb   $0x30,-0x24(%ebp)
  800444:	eb 18                	jmp    80045e <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800446:	89 de                	mov    %ebx,%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800448:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  80044f:	eb 0d                	jmp    80045e <vprintfmt+0x75>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800451:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800454:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800457:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80045e:	8a 06                	mov    (%esi),%al
  800460:	0f b6 d0             	movzbl %al,%edx
  800463:	8d 5e 01             	lea    0x1(%esi),%ebx
  800466:	83 e8 23             	sub    $0x23,%eax
  800469:	3c 55                	cmp    $0x55,%al
  80046b:	0f 87 e0 02 00 00    	ja     800751 <vprintfmt+0x368>
  800471:	0f b6 c0             	movzbl %al,%eax
  800474:	ff 24 85 60 21 80 00 	jmp    *0x802160(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80047b:	83 ea 30             	sub    $0x30,%edx
  80047e:	89 55 d4             	mov    %edx,-0x2c(%ebp)
				ch = *fmt;
  800481:	0f be 03             	movsbl (%ebx),%eax
				if (ch < '0' || ch > '9')
  800484:	8d 50 d0             	lea    -0x30(%eax),%edx
  800487:	83 fa 09             	cmp    $0x9,%edx
  80048a:	77 44                	ja     8004d0 <vprintfmt+0xe7>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80048c:	89 de                	mov    %ebx,%esi
  80048e:	8b 55 d4             	mov    -0x2c(%ebp),%edx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800491:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
  800492:	8d 14 92             	lea    (%edx,%edx,4),%edx
  800495:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
  800499:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  80049c:	8d 58 d0             	lea    -0x30(%eax),%ebx
  80049f:	83 fb 09             	cmp    $0x9,%ebx
  8004a2:	76 ed                	jbe    800491 <vprintfmt+0xa8>
  8004a4:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  8004a7:	eb 29                	jmp    8004d2 <vprintfmt+0xe9>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8004a9:	8b 45 14             	mov    0x14(%ebp),%eax
  8004ac:	8d 50 04             	lea    0x4(%eax),%edx
  8004af:	89 55 14             	mov    %edx,0x14(%ebp)
  8004b2:	8b 00                	mov    (%eax),%eax
  8004b4:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004b7:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8004b9:	eb 17                	jmp    8004d2 <vprintfmt+0xe9>

		case '.':
			if (width < 0)
  8004bb:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8004bf:	78 85                	js     800446 <vprintfmt+0x5d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004c1:	89 de                	mov    %ebx,%esi
  8004c3:	eb 99                	jmp    80045e <vprintfmt+0x75>
  8004c5:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8004c7:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  8004ce:	eb 8e                	jmp    80045e <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004d0:	89 de                	mov    %ebx,%esi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  8004d2:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8004d6:	79 86                	jns    80045e <vprintfmt+0x75>
  8004d8:	e9 74 ff ff ff       	jmp    800451 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8004dd:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004de:	89 de                	mov    %ebx,%esi
  8004e0:	e9 79 ff ff ff       	jmp    80045e <vprintfmt+0x75>
  8004e5:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8004e8:	8b 45 14             	mov    0x14(%ebp),%eax
  8004eb:	8d 50 04             	lea    0x4(%eax),%edx
  8004ee:	89 55 14             	mov    %edx,0x14(%ebp)
  8004f1:	83 ec 08             	sub    $0x8,%esp
  8004f4:	57                   	push   %edi
  8004f5:	ff 30                	pushl  (%eax)
  8004f7:	ff 55 08             	call   *0x8(%ebp)
			break;
  8004fa:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004fd:	8b 75 d8             	mov    -0x28(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800500:	e9 08 ff ff ff       	jmp    80040d <vprintfmt+0x24>
  800505:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  800508:	8b 45 14             	mov    0x14(%ebp),%eax
  80050b:	8d 50 04             	lea    0x4(%eax),%edx
  80050e:	89 55 14             	mov    %edx,0x14(%ebp)
  800511:	8b 00                	mov    (%eax),%eax
  800513:	85 c0                	test   %eax,%eax
  800515:	79 02                	jns    800519 <vprintfmt+0x130>
  800517:	f7 d8                	neg    %eax
  800519:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80051b:	83 f8 0f             	cmp    $0xf,%eax
  80051e:	7f 0b                	jg     80052b <vprintfmt+0x142>
  800520:	8b 04 85 c0 22 80 00 	mov    0x8022c0(,%eax,4),%eax
  800527:	85 c0                	test   %eax,%eax
  800529:	75 1a                	jne    800545 <vprintfmt+0x15c>
				printfmt(putch, putdat, "error %d", err);
  80052b:	52                   	push   %edx
  80052c:	68 3f 20 80 00       	push   $0x80203f
  800531:	57                   	push   %edi
  800532:	ff 75 08             	pushl  0x8(%ebp)
  800535:	e8 92 fe ff ff       	call   8003cc <printfmt>
  80053a:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80053d:	8b 75 d8             	mov    -0x28(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800540:	e9 c8 fe ff ff       	jmp    80040d <vprintfmt+0x24>
			else
				printfmt(putch, putdat, "%s", p);
  800545:	50                   	push   %eax
  800546:	68 f5 23 80 00       	push   $0x8023f5
  80054b:	57                   	push   %edi
  80054c:	ff 75 08             	pushl  0x8(%ebp)
  80054f:	e8 78 fe ff ff       	call   8003cc <printfmt>
  800554:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800557:	8b 75 d8             	mov    -0x28(%ebp),%esi
  80055a:	e9 ae fe ff ff       	jmp    80040d <vprintfmt+0x24>
  80055f:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  800562:	89 de                	mov    %ebx,%esi
  800564:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  800567:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80056a:	8b 45 14             	mov    0x14(%ebp),%eax
  80056d:	8d 50 04             	lea    0x4(%eax),%edx
  800570:	89 55 14             	mov    %edx,0x14(%ebp)
  800573:	8b 00                	mov    (%eax),%eax
  800575:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800578:	85 c0                	test   %eax,%eax
  80057a:	75 07                	jne    800583 <vprintfmt+0x19a>
				p = "(null)";
  80057c:	c7 45 d0 38 20 80 00 	movl   $0x802038,-0x30(%ebp)
			if (width > 0 && padc != '-')
  800583:	85 db                	test   %ebx,%ebx
  800585:	7e 42                	jle    8005c9 <vprintfmt+0x1e0>
  800587:	80 7d dc 2d          	cmpb   $0x2d,-0x24(%ebp)
  80058b:	74 3c                	je     8005c9 <vprintfmt+0x1e0>
				for (width -= strnlen(p, precision); width > 0; width--)
  80058d:	83 ec 08             	sub    $0x8,%esp
  800590:	51                   	push   %ecx
  800591:	ff 75 d0             	pushl  -0x30(%ebp)
  800594:	e8 6f 02 00 00       	call   800808 <strnlen>
  800599:	29 c3                	sub    %eax,%ebx
  80059b:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80059e:	83 c4 10             	add    $0x10,%esp
  8005a1:	85 db                	test   %ebx,%ebx
  8005a3:	7e 24                	jle    8005c9 <vprintfmt+0x1e0>
					putch(padc, putdat);
  8005a5:	0f be 5d dc          	movsbl -0x24(%ebp),%ebx
  8005a9:	89 75 dc             	mov    %esi,-0x24(%ebp)
  8005ac:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  8005af:	83 ec 08             	sub    $0x8,%esp
  8005b2:	57                   	push   %edi
  8005b3:	53                   	push   %ebx
  8005b4:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005b7:	4e                   	dec    %esi
  8005b8:	83 c4 10             	add    $0x10,%esp
  8005bb:	85 f6                	test   %esi,%esi
  8005bd:	7f f0                	jg     8005af <vprintfmt+0x1c6>
  8005bf:	8b 75 dc             	mov    -0x24(%ebp),%esi
  8005c2:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005c9:	8b 55 d0             	mov    -0x30(%ebp),%edx
  8005cc:	0f be 02             	movsbl (%edx),%eax
  8005cf:	85 c0                	test   %eax,%eax
  8005d1:	75 47                	jne    80061a <vprintfmt+0x231>
  8005d3:	eb 37                	jmp    80060c <vprintfmt+0x223>
				if (altflag && (ch < ' ' || ch > '~'))
  8005d5:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8005d9:	74 16                	je     8005f1 <vprintfmt+0x208>
  8005db:	8d 50 e0             	lea    -0x20(%eax),%edx
  8005de:	83 fa 5e             	cmp    $0x5e,%edx
  8005e1:	76 0e                	jbe    8005f1 <vprintfmt+0x208>
					putch('?', putdat);
  8005e3:	83 ec 08             	sub    $0x8,%esp
  8005e6:	57                   	push   %edi
  8005e7:	6a 3f                	push   $0x3f
  8005e9:	ff 55 08             	call   *0x8(%ebp)
  8005ec:	83 c4 10             	add    $0x10,%esp
  8005ef:	eb 0b                	jmp    8005fc <vprintfmt+0x213>
				else
					putch(ch, putdat);
  8005f1:	83 ec 08             	sub    $0x8,%esp
  8005f4:	57                   	push   %edi
  8005f5:	50                   	push   %eax
  8005f6:	ff 55 08             	call   *0x8(%ebp)
  8005f9:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005fc:	ff 4d e4             	decl   -0x1c(%ebp)
  8005ff:	0f be 03             	movsbl (%ebx),%eax
  800602:	85 c0                	test   %eax,%eax
  800604:	74 03                	je     800609 <vprintfmt+0x220>
  800606:	43                   	inc    %ebx
  800607:	eb 1b                	jmp    800624 <vprintfmt+0x23b>
  800609:	8b 75 dc             	mov    -0x24(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80060c:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800610:	7f 1e                	jg     800630 <vprintfmt+0x247>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800612:	8b 75 d8             	mov    -0x28(%ebp),%esi
  800615:	e9 f3 fd ff ff       	jmp    80040d <vprintfmt+0x24>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80061a:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  80061d:	43                   	inc    %ebx
  80061e:	89 75 dc             	mov    %esi,-0x24(%ebp)
  800621:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  800624:	85 f6                	test   %esi,%esi
  800626:	78 ad                	js     8005d5 <vprintfmt+0x1ec>
  800628:	4e                   	dec    %esi
  800629:	79 aa                	jns    8005d5 <vprintfmt+0x1ec>
  80062b:	8b 75 dc             	mov    -0x24(%ebp),%esi
  80062e:	eb dc                	jmp    80060c <vprintfmt+0x223>
  800630:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800633:	83 ec 08             	sub    $0x8,%esp
  800636:	57                   	push   %edi
  800637:	6a 20                	push   $0x20
  800639:	ff 55 08             	call   *0x8(%ebp)
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80063c:	4b                   	dec    %ebx
  80063d:	83 c4 10             	add    $0x10,%esp
  800640:	85 db                	test   %ebx,%ebx
  800642:	7f ef                	jg     800633 <vprintfmt+0x24a>
  800644:	e9 c4 fd ff ff       	jmp    80040d <vprintfmt+0x24>
  800649:	89 5d d8             	mov    %ebx,-0x28(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80064c:	89 ca                	mov    %ecx,%edx
  80064e:	8d 45 14             	lea    0x14(%ebp),%eax
  800651:	e8 2a fd ff ff       	call   800380 <getint>
  800656:	89 c3                	mov    %eax,%ebx
  800658:	89 d6                	mov    %edx,%esi
			if ((long long) num < 0) {
  80065a:	85 d2                	test   %edx,%edx
  80065c:	78 0a                	js     800668 <vprintfmt+0x27f>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80065e:	b8 0a 00 00 00       	mov    $0xa,%eax
  800663:	e9 b0 00 00 00       	jmp    800718 <vprintfmt+0x32f>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  800668:	83 ec 08             	sub    $0x8,%esp
  80066b:	57                   	push   %edi
  80066c:	6a 2d                	push   $0x2d
  80066e:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800671:	f7 db                	neg    %ebx
  800673:	83 d6 00             	adc    $0x0,%esi
  800676:	f7 de                	neg    %esi
  800678:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  80067b:	b8 0a 00 00 00       	mov    $0xa,%eax
  800680:	e9 93 00 00 00       	jmp    800718 <vprintfmt+0x32f>
  800685:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800688:	89 ca                	mov    %ecx,%edx
  80068a:	8d 45 14             	lea    0x14(%ebp),%eax
  80068d:	e8 b4 fc ff ff       	call   800346 <getuint>
  800692:	89 c3                	mov    %eax,%ebx
  800694:	89 d6                	mov    %edx,%esi
			base = 10;
  800696:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  80069b:	eb 7b                	jmp    800718 <vprintfmt+0x32f>
  80069d:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
  8006a0:	89 ca                	mov    %ecx,%edx
  8006a2:	8d 45 14             	lea    0x14(%ebp),%eax
  8006a5:	e8 d6 fc ff ff       	call   800380 <getint>
  8006aa:	89 c3                	mov    %eax,%ebx
  8006ac:	89 d6                	mov    %edx,%esi
            if ((long long) num < 0) {
  8006ae:	85 d2                	test   %edx,%edx
  8006b0:	78 07                	js     8006b9 <vprintfmt+0x2d0>
                putch('-', putdat);
                num = -(long long) num;
            }
            base = 8;
  8006b2:	b8 08 00 00 00       	mov    $0x8,%eax
  8006b7:	eb 5f                	jmp    800718 <vprintfmt+0x32f>
		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
            if ((long long) num < 0) {
                putch('-', putdat);
  8006b9:	83 ec 08             	sub    $0x8,%esp
  8006bc:	57                   	push   %edi
  8006bd:	6a 2d                	push   $0x2d
  8006bf:	ff 55 08             	call   *0x8(%ebp)
                num = -(long long) num;
  8006c2:	f7 db                	neg    %ebx
  8006c4:	83 d6 00             	adc    $0x0,%esi
  8006c7:	f7 de                	neg    %esi
  8006c9:	83 c4 10             	add    $0x10,%esp
            }
            base = 8;
  8006cc:	b8 08 00 00 00       	mov    $0x8,%eax
  8006d1:	eb 45                	jmp    800718 <vprintfmt+0x32f>
  8006d3:	89 5d d8             	mov    %ebx,-0x28(%ebp)
            goto number;

        // pointer
		case 'p':
			putch('0', putdat);
  8006d6:	83 ec 08             	sub    $0x8,%esp
  8006d9:	57                   	push   %edi
  8006da:	6a 30                	push   $0x30
  8006dc:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8006df:	83 c4 08             	add    $0x8,%esp
  8006e2:	57                   	push   %edi
  8006e3:	6a 78                	push   $0x78
  8006e5:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8006e8:	8b 45 14             	mov    0x14(%ebp),%eax
  8006eb:	8d 50 04             	lea    0x4(%eax),%edx
  8006ee:	89 55 14             	mov    %edx,0x14(%ebp)

        // pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8006f1:	8b 18                	mov    (%eax),%ebx
  8006f3:	be 00 00 00 00       	mov    $0x0,%esi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8006f8:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8006fb:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800700:	eb 16                	jmp    800718 <vprintfmt+0x32f>
  800702:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800705:	89 ca                	mov    %ecx,%edx
  800707:	8d 45 14             	lea    0x14(%ebp),%eax
  80070a:	e8 37 fc ff ff       	call   800346 <getuint>
  80070f:	89 c3                	mov    %eax,%ebx
  800711:	89 d6                	mov    %edx,%esi
			base = 16;
  800713:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800718:	83 ec 0c             	sub    $0xc,%esp
  80071b:	0f be 55 dc          	movsbl -0x24(%ebp),%edx
  80071f:	52                   	push   %edx
  800720:	ff 75 e4             	pushl  -0x1c(%ebp)
  800723:	50                   	push   %eax
  800724:	56                   	push   %esi
  800725:	53                   	push   %ebx
  800726:	89 fa                	mov    %edi,%edx
  800728:	8b 45 08             	mov    0x8(%ebp),%eax
  80072b:	e8 68 fb ff ff       	call   800298 <printnum>
			break;
  800730:	83 c4 20             	add    $0x20,%esp
  800733:	8b 75 d8             	mov    -0x28(%ebp),%esi
  800736:	e9 d2 fc ff ff       	jmp    80040d <vprintfmt+0x24>
  80073b:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80073e:	83 ec 08             	sub    $0x8,%esp
  800741:	57                   	push   %edi
  800742:	52                   	push   %edx
  800743:	ff 55 08             	call   *0x8(%ebp)
			break;
  800746:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800749:	8b 75 d8             	mov    -0x28(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80074c:	e9 bc fc ff ff       	jmp    80040d <vprintfmt+0x24>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800751:	83 ec 08             	sub    $0x8,%esp
  800754:	57                   	push   %edi
  800755:	6a 25                	push   $0x25
  800757:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  80075a:	83 c4 10             	add    $0x10,%esp
  80075d:	eb 02                	jmp    800761 <vprintfmt+0x378>
  80075f:	89 c6                	mov    %eax,%esi
  800761:	8d 46 ff             	lea    -0x1(%esi),%eax
  800764:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800768:	75 f5                	jne    80075f <vprintfmt+0x376>
  80076a:	e9 9e fc ff ff       	jmp    80040d <vprintfmt+0x24>
				/* do nothing */;
			break;
		}
	}
}
  80076f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800772:	5b                   	pop    %ebx
  800773:	5e                   	pop    %esi
  800774:	5f                   	pop    %edi
  800775:	c9                   	leave  
  800776:	c3                   	ret    

00800777 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800777:	55                   	push   %ebp
  800778:	89 e5                	mov    %esp,%ebp
  80077a:	83 ec 18             	sub    $0x18,%esp
  80077d:	8b 45 08             	mov    0x8(%ebp),%eax
  800780:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800783:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800786:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80078a:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80078d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800794:	85 c0                	test   %eax,%eax
  800796:	74 26                	je     8007be <vsnprintf+0x47>
  800798:	85 d2                	test   %edx,%edx
  80079a:	7e 29                	jle    8007c5 <vsnprintf+0x4e>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80079c:	ff 75 14             	pushl  0x14(%ebp)
  80079f:	ff 75 10             	pushl  0x10(%ebp)
  8007a2:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8007a5:	50                   	push   %eax
  8007a6:	68 b2 03 80 00       	push   $0x8003b2
  8007ab:	e8 39 fc ff ff       	call   8003e9 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8007b0:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007b3:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8007b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007b9:	83 c4 10             	add    $0x10,%esp
  8007bc:	eb 0c                	jmp    8007ca <vsnprintf+0x53>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8007be:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8007c3:	eb 05                	jmp    8007ca <vsnprintf+0x53>
  8007c5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8007ca:	c9                   	leave  
  8007cb:	c3                   	ret    

008007cc <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007cc:	55                   	push   %ebp
  8007cd:	89 e5                	mov    %esp,%ebp
  8007cf:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007d2:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8007d5:	50                   	push   %eax
  8007d6:	ff 75 10             	pushl  0x10(%ebp)
  8007d9:	ff 75 0c             	pushl  0xc(%ebp)
  8007dc:	ff 75 08             	pushl  0x8(%ebp)
  8007df:	e8 93 ff ff ff       	call   800777 <vsnprintf>
	va_end(ap);

	return rc;
}
  8007e4:	c9                   	leave  
  8007e5:	c3                   	ret    
	...

008007e8 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007e8:	55                   	push   %ebp
  8007e9:	89 e5                	mov    %esp,%ebp
  8007eb:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007ee:	80 3a 00             	cmpb   $0x0,(%edx)
  8007f1:	74 0e                	je     800801 <strlen+0x19>
  8007f3:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  8007f8:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8007f9:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007fd:	75 f9                	jne    8007f8 <strlen+0x10>
  8007ff:	eb 05                	jmp    800806 <strlen+0x1e>
  800801:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800806:	c9                   	leave  
  800807:	c3                   	ret    

00800808 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800808:	55                   	push   %ebp
  800809:	89 e5                	mov    %esp,%ebp
  80080b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80080e:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800811:	85 d2                	test   %edx,%edx
  800813:	74 17                	je     80082c <strnlen+0x24>
  800815:	80 39 00             	cmpb   $0x0,(%ecx)
  800818:	74 19                	je     800833 <strnlen+0x2b>
  80081a:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  80081f:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800820:	39 d0                	cmp    %edx,%eax
  800822:	74 14                	je     800838 <strnlen+0x30>
  800824:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800828:	75 f5                	jne    80081f <strnlen+0x17>
  80082a:	eb 0c                	jmp    800838 <strnlen+0x30>
  80082c:	b8 00 00 00 00       	mov    $0x0,%eax
  800831:	eb 05                	jmp    800838 <strnlen+0x30>
  800833:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800838:	c9                   	leave  
  800839:	c3                   	ret    

0080083a <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80083a:	55                   	push   %ebp
  80083b:	89 e5                	mov    %esp,%ebp
  80083d:	53                   	push   %ebx
  80083e:	8b 45 08             	mov    0x8(%ebp),%eax
  800841:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800844:	ba 00 00 00 00       	mov    $0x0,%edx
  800849:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  80084c:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  80084f:	42                   	inc    %edx
  800850:	84 c9                	test   %cl,%cl
  800852:	75 f5                	jne    800849 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800854:	5b                   	pop    %ebx
  800855:	c9                   	leave  
  800856:	c3                   	ret    

00800857 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800857:	55                   	push   %ebp
  800858:	89 e5                	mov    %esp,%ebp
  80085a:	53                   	push   %ebx
  80085b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80085e:	53                   	push   %ebx
  80085f:	e8 84 ff ff ff       	call   8007e8 <strlen>
  800864:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800867:	ff 75 0c             	pushl  0xc(%ebp)
  80086a:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  80086d:	50                   	push   %eax
  80086e:	e8 c7 ff ff ff       	call   80083a <strcpy>
	return dst;
}
  800873:	89 d8                	mov    %ebx,%eax
  800875:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800878:	c9                   	leave  
  800879:	c3                   	ret    

0080087a <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80087a:	55                   	push   %ebp
  80087b:	89 e5                	mov    %esp,%ebp
  80087d:	56                   	push   %esi
  80087e:	53                   	push   %ebx
  80087f:	8b 45 08             	mov    0x8(%ebp),%eax
  800882:	8b 55 0c             	mov    0xc(%ebp),%edx
  800885:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800888:	85 f6                	test   %esi,%esi
  80088a:	74 15                	je     8008a1 <strncpy+0x27>
  80088c:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  800891:	8a 1a                	mov    (%edx),%bl
  800893:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800896:	80 3a 01             	cmpb   $0x1,(%edx)
  800899:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80089c:	41                   	inc    %ecx
  80089d:	39 ce                	cmp    %ecx,%esi
  80089f:	77 f0                	ja     800891 <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8008a1:	5b                   	pop    %ebx
  8008a2:	5e                   	pop    %esi
  8008a3:	c9                   	leave  
  8008a4:	c3                   	ret    

008008a5 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8008a5:	55                   	push   %ebp
  8008a6:	89 e5                	mov    %esp,%ebp
  8008a8:	57                   	push   %edi
  8008a9:	56                   	push   %esi
  8008aa:	53                   	push   %ebx
  8008ab:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008ae:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8008b1:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8008b4:	85 f6                	test   %esi,%esi
  8008b6:	74 32                	je     8008ea <strlcpy+0x45>
		while (--size > 0 && *src != '\0')
  8008b8:	83 fe 01             	cmp    $0x1,%esi
  8008bb:	74 22                	je     8008df <strlcpy+0x3a>
  8008bd:	8a 0b                	mov    (%ebx),%cl
  8008bf:	84 c9                	test   %cl,%cl
  8008c1:	74 20                	je     8008e3 <strlcpy+0x3e>
  8008c3:	89 f8                	mov    %edi,%eax
  8008c5:	ba 00 00 00 00       	mov    $0x0,%edx
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
  8008ca:	83 ee 02             	sub    $0x2,%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8008cd:	88 08                	mov    %cl,(%eax)
  8008cf:	40                   	inc    %eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8008d0:	39 f2                	cmp    %esi,%edx
  8008d2:	74 11                	je     8008e5 <strlcpy+0x40>
  8008d4:	8a 4c 13 01          	mov    0x1(%ebx,%edx,1),%cl
  8008d8:	42                   	inc    %edx
  8008d9:	84 c9                	test   %cl,%cl
  8008db:	75 f0                	jne    8008cd <strlcpy+0x28>
  8008dd:	eb 06                	jmp    8008e5 <strlcpy+0x40>
  8008df:	89 f8                	mov    %edi,%eax
  8008e1:	eb 02                	jmp    8008e5 <strlcpy+0x40>
  8008e3:	89 f8                	mov    %edi,%eax
			*dst++ = *src++;
		*dst = '\0';
  8008e5:	c6 00 00             	movb   $0x0,(%eax)
  8008e8:	eb 02                	jmp    8008ec <strlcpy+0x47>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8008ea:	89 f8                	mov    %edi,%eax
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
		*dst = '\0';
	}
	return dst - dst_in;
  8008ec:	29 f8                	sub    %edi,%eax
}
  8008ee:	5b                   	pop    %ebx
  8008ef:	5e                   	pop    %esi
  8008f0:	5f                   	pop    %edi
  8008f1:	c9                   	leave  
  8008f2:	c3                   	ret    

008008f3 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8008f3:	55                   	push   %ebp
  8008f4:	89 e5                	mov    %esp,%ebp
  8008f6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008f9:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008fc:	8a 01                	mov    (%ecx),%al
  8008fe:	84 c0                	test   %al,%al
  800900:	74 10                	je     800912 <strcmp+0x1f>
  800902:	3a 02                	cmp    (%edx),%al
  800904:	75 0c                	jne    800912 <strcmp+0x1f>
		p++, q++;
  800906:	41                   	inc    %ecx
  800907:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800908:	8a 01                	mov    (%ecx),%al
  80090a:	84 c0                	test   %al,%al
  80090c:	74 04                	je     800912 <strcmp+0x1f>
  80090e:	3a 02                	cmp    (%edx),%al
  800910:	74 f4                	je     800906 <strcmp+0x13>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800912:	0f b6 c0             	movzbl %al,%eax
  800915:	0f b6 12             	movzbl (%edx),%edx
  800918:	29 d0                	sub    %edx,%eax
}
  80091a:	c9                   	leave  
  80091b:	c3                   	ret    

0080091c <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80091c:	55                   	push   %ebp
  80091d:	89 e5                	mov    %esp,%ebp
  80091f:	53                   	push   %ebx
  800920:	8b 55 08             	mov    0x8(%ebp),%edx
  800923:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800926:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  800929:	85 c0                	test   %eax,%eax
  80092b:	74 1b                	je     800948 <strncmp+0x2c>
  80092d:	8a 1a                	mov    (%edx),%bl
  80092f:	84 db                	test   %bl,%bl
  800931:	74 24                	je     800957 <strncmp+0x3b>
  800933:	3a 19                	cmp    (%ecx),%bl
  800935:	75 20                	jne    800957 <strncmp+0x3b>
  800937:	48                   	dec    %eax
  800938:	74 15                	je     80094f <strncmp+0x33>
		n--, p++, q++;
  80093a:	42                   	inc    %edx
  80093b:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80093c:	8a 1a                	mov    (%edx),%bl
  80093e:	84 db                	test   %bl,%bl
  800940:	74 15                	je     800957 <strncmp+0x3b>
  800942:	3a 19                	cmp    (%ecx),%bl
  800944:	74 f1                	je     800937 <strncmp+0x1b>
  800946:	eb 0f                	jmp    800957 <strncmp+0x3b>
		n--, p++, q++;
	if (n == 0)
		return 0;
  800948:	b8 00 00 00 00       	mov    $0x0,%eax
  80094d:	eb 05                	jmp    800954 <strncmp+0x38>
  80094f:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800954:	5b                   	pop    %ebx
  800955:	c9                   	leave  
  800956:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800957:	0f b6 02             	movzbl (%edx),%eax
  80095a:	0f b6 11             	movzbl (%ecx),%edx
  80095d:	29 d0                	sub    %edx,%eax
  80095f:	eb f3                	jmp    800954 <strncmp+0x38>

00800961 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800961:	55                   	push   %ebp
  800962:	89 e5                	mov    %esp,%ebp
  800964:	8b 45 08             	mov    0x8(%ebp),%eax
  800967:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  80096a:	8a 10                	mov    (%eax),%dl
  80096c:	84 d2                	test   %dl,%dl
  80096e:	74 18                	je     800988 <strchr+0x27>
		if (*s == c)
  800970:	38 ca                	cmp    %cl,%dl
  800972:	75 06                	jne    80097a <strchr+0x19>
  800974:	eb 17                	jmp    80098d <strchr+0x2c>
  800976:	38 ca                	cmp    %cl,%dl
  800978:	74 13                	je     80098d <strchr+0x2c>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80097a:	40                   	inc    %eax
  80097b:	8a 10                	mov    (%eax),%dl
  80097d:	84 d2                	test   %dl,%dl
  80097f:	75 f5                	jne    800976 <strchr+0x15>
		if (*s == c)
			return (char *) s;
	return 0;
  800981:	b8 00 00 00 00       	mov    $0x0,%eax
  800986:	eb 05                	jmp    80098d <strchr+0x2c>
  800988:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80098d:	c9                   	leave  
  80098e:	c3                   	ret    

0080098f <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80098f:	55                   	push   %ebp
  800990:	89 e5                	mov    %esp,%ebp
  800992:	8b 45 08             	mov    0x8(%ebp),%eax
  800995:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800998:	8a 10                	mov    (%eax),%dl
  80099a:	84 d2                	test   %dl,%dl
  80099c:	74 11                	je     8009af <strfind+0x20>
		if (*s == c)
  80099e:	38 ca                	cmp    %cl,%dl
  8009a0:	75 06                	jne    8009a8 <strfind+0x19>
  8009a2:	eb 0b                	jmp    8009af <strfind+0x20>
  8009a4:	38 ca                	cmp    %cl,%dl
  8009a6:	74 07                	je     8009af <strfind+0x20>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  8009a8:	40                   	inc    %eax
  8009a9:	8a 10                	mov    (%eax),%dl
  8009ab:	84 d2                	test   %dl,%dl
  8009ad:	75 f5                	jne    8009a4 <strfind+0x15>
		if (*s == c)
			break;
	return (char *) s;
}
  8009af:	c9                   	leave  
  8009b0:	c3                   	ret    

008009b1 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8009b1:	55                   	push   %ebp
  8009b2:	89 e5                	mov    %esp,%ebp
  8009b4:	57                   	push   %edi
  8009b5:	56                   	push   %esi
  8009b6:	53                   	push   %ebx
  8009b7:	8b 7d 08             	mov    0x8(%ebp),%edi
  8009ba:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009bd:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8009c0:	85 c9                	test   %ecx,%ecx
  8009c2:	74 30                	je     8009f4 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8009c4:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8009ca:	75 25                	jne    8009f1 <memset+0x40>
  8009cc:	f6 c1 03             	test   $0x3,%cl
  8009cf:	75 20                	jne    8009f1 <memset+0x40>
		c &= 0xFF;
  8009d1:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8009d4:	89 d3                	mov    %edx,%ebx
  8009d6:	c1 e3 08             	shl    $0x8,%ebx
  8009d9:	89 d6                	mov    %edx,%esi
  8009db:	c1 e6 18             	shl    $0x18,%esi
  8009de:	89 d0                	mov    %edx,%eax
  8009e0:	c1 e0 10             	shl    $0x10,%eax
  8009e3:	09 f0                	or     %esi,%eax
  8009e5:	09 d0                	or     %edx,%eax
  8009e7:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  8009e9:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  8009ec:	fc                   	cld    
  8009ed:	f3 ab                	rep stos %eax,%es:(%edi)
  8009ef:	eb 03                	jmp    8009f4 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8009f1:	fc                   	cld    
  8009f2:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8009f4:	89 f8                	mov    %edi,%eax
  8009f6:	5b                   	pop    %ebx
  8009f7:	5e                   	pop    %esi
  8009f8:	5f                   	pop    %edi
  8009f9:	c9                   	leave  
  8009fa:	c3                   	ret    

008009fb <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8009fb:	55                   	push   %ebp
  8009fc:	89 e5                	mov    %esp,%ebp
  8009fe:	57                   	push   %edi
  8009ff:	56                   	push   %esi
  800a00:	8b 45 08             	mov    0x8(%ebp),%eax
  800a03:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a06:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a09:	39 c6                	cmp    %eax,%esi
  800a0b:	73 34                	jae    800a41 <memmove+0x46>
  800a0d:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a10:	39 d0                	cmp    %edx,%eax
  800a12:	73 2d                	jae    800a41 <memmove+0x46>
		s += n;
		d += n;
  800a14:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a17:	f6 c2 03             	test   $0x3,%dl
  800a1a:	75 1b                	jne    800a37 <memmove+0x3c>
  800a1c:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a22:	75 13                	jne    800a37 <memmove+0x3c>
  800a24:	f6 c1 03             	test   $0x3,%cl
  800a27:	75 0e                	jne    800a37 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800a29:	83 ef 04             	sub    $0x4,%edi
  800a2c:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a2f:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800a32:	fd                   	std    
  800a33:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a35:	eb 07                	jmp    800a3e <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800a37:	4f                   	dec    %edi
  800a38:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800a3b:	fd                   	std    
  800a3c:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a3e:	fc                   	cld    
  800a3f:	eb 20                	jmp    800a61 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a41:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a47:	75 13                	jne    800a5c <memmove+0x61>
  800a49:	a8 03                	test   $0x3,%al
  800a4b:	75 0f                	jne    800a5c <memmove+0x61>
  800a4d:	f6 c1 03             	test   $0x3,%cl
  800a50:	75 0a                	jne    800a5c <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800a52:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800a55:	89 c7                	mov    %eax,%edi
  800a57:	fc                   	cld    
  800a58:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a5a:	eb 05                	jmp    800a61 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a5c:	89 c7                	mov    %eax,%edi
  800a5e:	fc                   	cld    
  800a5f:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a61:	5e                   	pop    %esi
  800a62:	5f                   	pop    %edi
  800a63:	c9                   	leave  
  800a64:	c3                   	ret    

00800a65 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a65:	55                   	push   %ebp
  800a66:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800a68:	ff 75 10             	pushl  0x10(%ebp)
  800a6b:	ff 75 0c             	pushl  0xc(%ebp)
  800a6e:	ff 75 08             	pushl  0x8(%ebp)
  800a71:	e8 85 ff ff ff       	call   8009fb <memmove>
}
  800a76:	c9                   	leave  
  800a77:	c3                   	ret    

00800a78 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a78:	55                   	push   %ebp
  800a79:	89 e5                	mov    %esp,%ebp
  800a7b:	57                   	push   %edi
  800a7c:	56                   	push   %esi
  800a7d:	53                   	push   %ebx
  800a7e:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800a81:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a84:	8b 7d 10             	mov    0x10(%ebp),%edi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a87:	85 ff                	test   %edi,%edi
  800a89:	74 32                	je     800abd <memcmp+0x45>
		if (*s1 != *s2)
  800a8b:	8a 03                	mov    (%ebx),%al
  800a8d:	8a 0e                	mov    (%esi),%cl
  800a8f:	38 c8                	cmp    %cl,%al
  800a91:	74 19                	je     800aac <memcmp+0x34>
  800a93:	eb 0d                	jmp    800aa2 <memcmp+0x2a>
  800a95:	8a 44 13 01          	mov    0x1(%ebx,%edx,1),%al
  800a99:	8a 4c 16 01          	mov    0x1(%esi,%edx,1),%cl
  800a9d:	42                   	inc    %edx
  800a9e:	38 c8                	cmp    %cl,%al
  800aa0:	74 10                	je     800ab2 <memcmp+0x3a>
			return (int) *s1 - (int) *s2;
  800aa2:	0f b6 c0             	movzbl %al,%eax
  800aa5:	0f b6 c9             	movzbl %cl,%ecx
  800aa8:	29 c8                	sub    %ecx,%eax
  800aaa:	eb 16                	jmp    800ac2 <memcmp+0x4a>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800aac:	4f                   	dec    %edi
  800aad:	ba 00 00 00 00       	mov    $0x0,%edx
  800ab2:	39 fa                	cmp    %edi,%edx
  800ab4:	75 df                	jne    800a95 <memcmp+0x1d>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800ab6:	b8 00 00 00 00       	mov    $0x0,%eax
  800abb:	eb 05                	jmp    800ac2 <memcmp+0x4a>
  800abd:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ac2:	5b                   	pop    %ebx
  800ac3:	5e                   	pop    %esi
  800ac4:	5f                   	pop    %edi
  800ac5:	c9                   	leave  
  800ac6:	c3                   	ret    

00800ac7 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800ac7:	55                   	push   %ebp
  800ac8:	89 e5                	mov    %esp,%ebp
  800aca:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800acd:	89 c2                	mov    %eax,%edx
  800acf:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800ad2:	39 d0                	cmp    %edx,%eax
  800ad4:	73 12                	jae    800ae8 <memfind+0x21>
		if (*(const unsigned char *) s == (unsigned char) c)
  800ad6:	8a 4d 0c             	mov    0xc(%ebp),%cl
  800ad9:	38 08                	cmp    %cl,(%eax)
  800adb:	75 06                	jne    800ae3 <memfind+0x1c>
  800add:	eb 09                	jmp    800ae8 <memfind+0x21>
  800adf:	38 08                	cmp    %cl,(%eax)
  800ae1:	74 05                	je     800ae8 <memfind+0x21>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800ae3:	40                   	inc    %eax
  800ae4:	39 c2                	cmp    %eax,%edx
  800ae6:	77 f7                	ja     800adf <memfind+0x18>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800ae8:	c9                   	leave  
  800ae9:	c3                   	ret    

00800aea <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800aea:	55                   	push   %ebp
  800aeb:	89 e5                	mov    %esp,%ebp
  800aed:	57                   	push   %edi
  800aee:	56                   	push   %esi
  800aef:	53                   	push   %ebx
  800af0:	8b 55 08             	mov    0x8(%ebp),%edx
  800af3:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800af6:	eb 01                	jmp    800af9 <strtol+0xf>
		s++;
  800af8:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800af9:	8a 02                	mov    (%edx),%al
  800afb:	3c 20                	cmp    $0x20,%al
  800afd:	74 f9                	je     800af8 <strtol+0xe>
  800aff:	3c 09                	cmp    $0x9,%al
  800b01:	74 f5                	je     800af8 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800b03:	3c 2b                	cmp    $0x2b,%al
  800b05:	75 08                	jne    800b0f <strtol+0x25>
		s++;
  800b07:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800b08:	bf 00 00 00 00       	mov    $0x0,%edi
  800b0d:	eb 13                	jmp    800b22 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800b0f:	3c 2d                	cmp    $0x2d,%al
  800b11:	75 0a                	jne    800b1d <strtol+0x33>
		s++, neg = 1;
  800b13:	8d 52 01             	lea    0x1(%edx),%edx
  800b16:	bf 01 00 00 00       	mov    $0x1,%edi
  800b1b:	eb 05                	jmp    800b22 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800b1d:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b22:	85 db                	test   %ebx,%ebx
  800b24:	74 05                	je     800b2b <strtol+0x41>
  800b26:	83 fb 10             	cmp    $0x10,%ebx
  800b29:	75 28                	jne    800b53 <strtol+0x69>
  800b2b:	8a 02                	mov    (%edx),%al
  800b2d:	3c 30                	cmp    $0x30,%al
  800b2f:	75 10                	jne    800b41 <strtol+0x57>
  800b31:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800b35:	75 0a                	jne    800b41 <strtol+0x57>
		s += 2, base = 16;
  800b37:	83 c2 02             	add    $0x2,%edx
  800b3a:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b3f:	eb 12                	jmp    800b53 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800b41:	85 db                	test   %ebx,%ebx
  800b43:	75 0e                	jne    800b53 <strtol+0x69>
  800b45:	3c 30                	cmp    $0x30,%al
  800b47:	75 05                	jne    800b4e <strtol+0x64>
		s++, base = 8;
  800b49:	42                   	inc    %edx
  800b4a:	b3 08                	mov    $0x8,%bl
  800b4c:	eb 05                	jmp    800b53 <strtol+0x69>
	else if (base == 0)
		base = 10;
  800b4e:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800b53:	b8 00 00 00 00       	mov    $0x0,%eax
  800b58:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800b5a:	8a 0a                	mov    (%edx),%cl
  800b5c:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800b5f:	80 fb 09             	cmp    $0x9,%bl
  800b62:	77 08                	ja     800b6c <strtol+0x82>
			dig = *s - '0';
  800b64:	0f be c9             	movsbl %cl,%ecx
  800b67:	83 e9 30             	sub    $0x30,%ecx
  800b6a:	eb 1e                	jmp    800b8a <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800b6c:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800b6f:	80 fb 19             	cmp    $0x19,%bl
  800b72:	77 08                	ja     800b7c <strtol+0x92>
			dig = *s - 'a' + 10;
  800b74:	0f be c9             	movsbl %cl,%ecx
  800b77:	83 e9 57             	sub    $0x57,%ecx
  800b7a:	eb 0e                	jmp    800b8a <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800b7c:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800b7f:	80 fb 19             	cmp    $0x19,%bl
  800b82:	77 13                	ja     800b97 <strtol+0xad>
			dig = *s - 'A' + 10;
  800b84:	0f be c9             	movsbl %cl,%ecx
  800b87:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800b8a:	39 f1                	cmp    %esi,%ecx
  800b8c:	7d 0d                	jge    800b9b <strtol+0xb1>
			break;
		s++, val = (val * base) + dig;
  800b8e:	42                   	inc    %edx
  800b8f:	0f af c6             	imul   %esi,%eax
  800b92:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  800b95:	eb c3                	jmp    800b5a <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800b97:	89 c1                	mov    %eax,%ecx
  800b99:	eb 02                	jmp    800b9d <strtol+0xb3>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800b9b:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800b9d:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ba1:	74 05                	je     800ba8 <strtol+0xbe>
		*endptr = (char *) s;
  800ba3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800ba6:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800ba8:	85 ff                	test   %edi,%edi
  800baa:	74 04                	je     800bb0 <strtol+0xc6>
  800bac:	89 c8                	mov    %ecx,%eax
  800bae:	f7 d8                	neg    %eax
}
  800bb0:	5b                   	pop    %ebx
  800bb1:	5e                   	pop    %esi
  800bb2:	5f                   	pop    %edi
  800bb3:	c9                   	leave  
  800bb4:	c3                   	ret    
  800bb5:	00 00                	add    %al,(%eax)
	...

00800bb8 <syscall>:
	return ret;
}

static int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800bb8:	55                   	push   %ebp
  800bb9:	89 e5                	mov    %esp,%ebp
  800bbb:	57                   	push   %edi
  800bbc:	56                   	push   %esi
  800bbd:	53                   	push   %ebx
  800bbe:	83 ec 1c             	sub    $0x1c,%esp
  800bc1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800bc4:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800bc7:	89 ca                	mov    %ecx,%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bc9:	8b 75 14             	mov    0x14(%ebp),%esi
  800bcc:	8b 7d 10             	mov    0x10(%ebp),%edi
  800bcf:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800bd2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800bd5:	cd 30                	int    $0x30
  800bd7:	89 c2                	mov    %eax,%edx
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800bd9:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800bdd:	74 1c                	je     800bfb <syscall+0x43>
  800bdf:	85 c0                	test   %eax,%eax
  800be1:	7e 18                	jle    800bfb <syscall+0x43>
		panic("syscall %d returned %d (> 0)", num, ret);
  800be3:	83 ec 0c             	sub    $0xc,%esp
  800be6:	50                   	push   %eax
  800be7:	ff 75 e4             	pushl  -0x1c(%ebp)
  800bea:	68 1f 23 80 00       	push   $0x80231f
  800bef:	6a 42                	push   $0x42
  800bf1:	68 3c 23 80 00       	push   $0x80233c
  800bf6:	e8 b1 f5 ff ff       	call   8001ac <_panic>

	return ret;
}
  800bfb:	89 d0                	mov    %edx,%eax
  800bfd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c00:	5b                   	pop    %ebx
  800c01:	5e                   	pop    %esi
  800c02:	5f                   	pop    %edi
  800c03:	c9                   	leave  
  800c04:	c3                   	ret    

00800c05 <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{	
  800c05:	55                   	push   %ebp
  800c06:	89 e5                	mov    %esp,%ebp
  800c08:	83 ec 08             	sub    $0x8,%esp
	// my_sysenter(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
	// return;
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  800c0b:	6a 00                	push   $0x0
  800c0d:	6a 00                	push   $0x0
  800c0f:	6a 00                	push   $0x0
  800c11:	ff 75 0c             	pushl  0xc(%ebp)
  800c14:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c17:	ba 00 00 00 00       	mov    $0x0,%edx
  800c1c:	b8 00 00 00 00       	mov    $0x0,%eax
  800c21:	e8 92 ff ff ff       	call   800bb8 <syscall>
  800c26:	83 c4 10             	add    $0x10,%esp
	return;
}
  800c29:	c9                   	leave  
  800c2a:	c3                   	ret    

00800c2b <sys_cgetc>:

int
sys_cgetc(void)
{
  800c2b:	55                   	push   %ebp
  800c2c:	89 e5                	mov    %esp,%ebp
  800c2e:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_cgetc, 0, 0, 0, 0, 0, 0);
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  800c31:	6a 00                	push   $0x0
  800c33:	6a 00                	push   $0x0
  800c35:	6a 00                	push   $0x0
  800c37:	6a 00                	push   $0x0
  800c39:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c3e:	ba 00 00 00 00       	mov    $0x0,%edx
  800c43:	b8 01 00 00 00       	mov    $0x1,%eax
  800c48:	e8 6b ff ff ff       	call   800bb8 <syscall>
}
  800c4d:	c9                   	leave  
  800c4e:	c3                   	ret    

00800c4f <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800c4f:	55                   	push   %ebp
  800c50:	89 e5                	mov    %esp,%ebp
  800c52:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  800c55:	6a 00                	push   $0x0
  800c57:	6a 00                	push   $0x0
  800c59:	6a 00                	push   $0x0
  800c5b:	6a 00                	push   $0x0
  800c5d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c60:	ba 01 00 00 00       	mov    $0x1,%edx
  800c65:	b8 03 00 00 00       	mov    $0x3,%eax
  800c6a:	e8 49 ff ff ff       	call   800bb8 <syscall>
}
  800c6f:	c9                   	leave  
  800c70:	c3                   	ret    

00800c71 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c71:	55                   	push   %ebp
  800c72:	89 e5                	mov    %esp,%ebp
  800c74:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_getenvid, 0, 0, 0, 0, 0, 0);
	return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  800c77:	6a 00                	push   $0x0
  800c79:	6a 00                	push   $0x0
  800c7b:	6a 00                	push   $0x0
  800c7d:	6a 00                	push   $0x0
  800c7f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c84:	ba 00 00 00 00       	mov    $0x0,%edx
  800c89:	b8 02 00 00 00       	mov    $0x2,%eax
  800c8e:	e8 25 ff ff ff       	call   800bb8 <syscall>
}
  800c93:	c9                   	leave  
  800c94:	c3                   	ret    

00800c95 <sys_yield>:

void
sys_yield(void)
{
  800c95:	55                   	push   %ebp
  800c96:	89 e5                	mov    %esp,%ebp
  800c98:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  800c9b:	6a 00                	push   $0x0
  800c9d:	6a 00                	push   $0x0
  800c9f:	6a 00                	push   $0x0
  800ca1:	6a 00                	push   $0x0
  800ca3:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ca8:	ba 00 00 00 00       	mov    $0x0,%edx
  800cad:	b8 0b 00 00 00       	mov    $0xb,%eax
  800cb2:	e8 01 ff ff ff       	call   800bb8 <syscall>
  800cb7:	83 c4 10             	add    $0x10,%esp
}
  800cba:	c9                   	leave  
  800cbb:	c3                   	ret    

00800cbc <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800cbc:	55                   	push   %ebp
  800cbd:	89 e5                	mov    %esp,%ebp
  800cbf:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  800cc2:	6a 00                	push   $0x0
  800cc4:	6a 00                	push   $0x0
  800cc6:	ff 75 10             	pushl  0x10(%ebp)
  800cc9:	ff 75 0c             	pushl  0xc(%ebp)
  800ccc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ccf:	ba 01 00 00 00       	mov    $0x1,%edx
  800cd4:	b8 04 00 00 00       	mov    $0x4,%eax
  800cd9:	e8 da fe ff ff       	call   800bb8 <syscall>
}
  800cde:	c9                   	leave  
  800cdf:	c3                   	ret    

00800ce0 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800ce0:	55                   	push   %ebp
  800ce1:	89 e5                	mov    %esp,%ebp
  800ce3:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
  800ce6:	ff 75 18             	pushl  0x18(%ebp)
  800ce9:	ff 75 14             	pushl  0x14(%ebp)
  800cec:	ff 75 10             	pushl  0x10(%ebp)
  800cef:	ff 75 0c             	pushl  0xc(%ebp)
  800cf2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800cf5:	ba 01 00 00 00       	mov    $0x1,%edx
  800cfa:	b8 05 00 00 00       	mov    $0x5,%eax
  800cff:	e8 b4 fe ff ff       	call   800bb8 <syscall>
}
  800d04:	c9                   	leave  
  800d05:	c3                   	ret    

00800d06 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800d06:	55                   	push   %ebp
  800d07:	89 e5                	mov    %esp,%ebp
  800d09:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  800d0c:	6a 00                	push   $0x0
  800d0e:	6a 00                	push   $0x0
  800d10:	6a 00                	push   $0x0
  800d12:	ff 75 0c             	pushl  0xc(%ebp)
  800d15:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d18:	ba 01 00 00 00       	mov    $0x1,%edx
  800d1d:	b8 06 00 00 00       	mov    $0x6,%eax
  800d22:	e8 91 fe ff ff       	call   800bb8 <syscall>
}
  800d27:	c9                   	leave  
  800d28:	c3                   	ret    

00800d29 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800d29:	55                   	push   %ebp
  800d2a:	89 e5                	mov    %esp,%ebp
  800d2c:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  800d2f:	6a 00                	push   $0x0
  800d31:	6a 00                	push   $0x0
  800d33:	6a 00                	push   $0x0
  800d35:	ff 75 0c             	pushl  0xc(%ebp)
  800d38:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d3b:	ba 01 00 00 00       	mov    $0x1,%edx
  800d40:	b8 08 00 00 00       	mov    $0x8,%eax
  800d45:	e8 6e fe ff ff       	call   800bb8 <syscall>
}
  800d4a:	c9                   	leave  
  800d4b:	c3                   	ret    

00800d4c <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800d4c:	55                   	push   %ebp
  800d4d:	89 e5                	mov    %esp,%ebp
  800d4f:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
  800d52:	6a 00                	push   $0x0
  800d54:	6a 00                	push   $0x0
  800d56:	6a 00                	push   $0x0
  800d58:	ff 75 0c             	pushl  0xc(%ebp)
  800d5b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d5e:	ba 01 00 00 00       	mov    $0x1,%edx
  800d63:	b8 09 00 00 00       	mov    $0x9,%eax
  800d68:	e8 4b fe ff ff       	call   800bb8 <syscall>
}
  800d6d:	c9                   	leave  
  800d6e:	c3                   	ret    

00800d6f <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d6f:	55                   	push   %ebp
  800d70:	89 e5                	mov    %esp,%ebp
  800d72:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  800d75:	6a 00                	push   $0x0
  800d77:	6a 00                	push   $0x0
  800d79:	6a 00                	push   $0x0
  800d7b:	ff 75 0c             	pushl  0xc(%ebp)
  800d7e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d81:	ba 01 00 00 00       	mov    $0x1,%edx
  800d86:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d8b:	e8 28 fe ff ff       	call   800bb8 <syscall>
}
  800d90:	c9                   	leave  
  800d91:	c3                   	ret    

00800d92 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d92:	55                   	push   %ebp
  800d93:	89 e5                	mov    %esp,%ebp
  800d95:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  800d98:	6a 00                	push   $0x0
  800d9a:	ff 75 14             	pushl  0x14(%ebp)
  800d9d:	ff 75 10             	pushl  0x10(%ebp)
  800da0:	ff 75 0c             	pushl  0xc(%ebp)
  800da3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800da6:	ba 00 00 00 00       	mov    $0x0,%edx
  800dab:	b8 0c 00 00 00       	mov    $0xc,%eax
  800db0:	e8 03 fe ff ff       	call   800bb8 <syscall>
}
  800db5:	c9                   	leave  
  800db6:	c3                   	ret    

00800db7 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800db7:	55                   	push   %ebp
  800db8:	89 e5                	mov    %esp,%ebp
  800dba:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  800dbd:	6a 00                	push   $0x0
  800dbf:	6a 00                	push   $0x0
  800dc1:	6a 00                	push   $0x0
  800dc3:	6a 00                	push   $0x0
  800dc5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800dc8:	ba 01 00 00 00       	mov    $0x1,%edx
  800dcd:	b8 0d 00 00 00       	mov    $0xd,%eax
  800dd2:	e8 e1 fd ff ff       	call   800bb8 <syscall>
}
  800dd7:	c9                   	leave  
  800dd8:	c3                   	ret    

00800dd9 <sys_set_priority>:

int
sys_set_priority(envid_t envid, uint32_t new_priority)
{
  800dd9:	55                   	push   %ebp
  800dda:	89 e5                	mov    %esp,%ebp
  800ddc:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_set_priority, 0, envid, new_priority, 0, 0, 0);
  800ddf:	6a 00                	push   $0x0
  800de1:	6a 00                	push   $0x0
  800de3:	6a 00                	push   $0x0
  800de5:	ff 75 0c             	pushl  0xc(%ebp)
  800de8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800deb:	ba 00 00 00 00       	mov    $0x0,%edx
  800df0:	b8 0e 00 00 00       	mov    $0xe,%eax
  800df5:	e8 be fd ff ff       	call   800bb8 <syscall>
}
  800dfa:	c9                   	leave  
  800dfb:	c3                   	ret    

00800dfc <sys_exec>:

int
sys_exec(uint32_t eip, uint32_t esp, void * ph, uint32_t elf_phnum)
{
  800dfc:	55                   	push   %ebp
  800dfd:	89 e5                	mov    %esp,%ebp
  800dff:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_exec, 0, eip, esp, (uint32_t)ph, elf_phnum, 0);
  800e02:	6a 00                	push   $0x0
  800e04:	ff 75 14             	pushl  0x14(%ebp)
  800e07:	ff 75 10             	pushl  0x10(%ebp)
  800e0a:	ff 75 0c             	pushl  0xc(%ebp)
  800e0d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e10:	ba 00 00 00 00       	mov    $0x0,%edx
  800e15:	b8 0f 00 00 00       	mov    $0xf,%eax
  800e1a:	e8 99 fd ff ff       	call   800bb8 <syscall>
  800e1f:	c9                   	leave  
  800e20:	c3                   	ret    
  800e21:	00 00                	add    %al,(%eax)
	...

00800e24 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800e24:	55                   	push   %ebp
  800e25:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800e27:	8b 45 08             	mov    0x8(%ebp),%eax
  800e2a:	05 00 00 00 30       	add    $0x30000000,%eax
  800e2f:	c1 e8 0c             	shr    $0xc,%eax
}
  800e32:	c9                   	leave  
  800e33:	c3                   	ret    

00800e34 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800e34:	55                   	push   %ebp
  800e35:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800e37:	ff 75 08             	pushl  0x8(%ebp)
  800e3a:	e8 e5 ff ff ff       	call   800e24 <fd2num>
  800e3f:	83 c4 04             	add    $0x4,%esp
  800e42:	05 20 00 0d 00       	add    $0xd0020,%eax
  800e47:	c1 e0 0c             	shl    $0xc,%eax
}
  800e4a:	c9                   	leave  
  800e4b:	c3                   	ret    

00800e4c <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800e4c:	55                   	push   %ebp
  800e4d:	89 e5                	mov    %esp,%ebp
  800e4f:	53                   	push   %ebx
  800e50:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800e53:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  800e58:	a8 01                	test   $0x1,%al
  800e5a:	74 34                	je     800e90 <fd_alloc+0x44>
  800e5c:	a1 00 00 74 ef       	mov    0xef740000,%eax
  800e61:	a8 01                	test   $0x1,%al
  800e63:	74 32                	je     800e97 <fd_alloc+0x4b>
  800e65:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
  800e6a:	89 c1                	mov    %eax,%ecx
  800e6c:	89 c2                	mov    %eax,%edx
  800e6e:	c1 ea 16             	shr    $0x16,%edx
  800e71:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800e78:	f6 c2 01             	test   $0x1,%dl
  800e7b:	74 1f                	je     800e9c <fd_alloc+0x50>
  800e7d:	89 c2                	mov    %eax,%edx
  800e7f:	c1 ea 0c             	shr    $0xc,%edx
  800e82:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e89:	f6 c2 01             	test   $0x1,%dl
  800e8c:	75 17                	jne    800ea5 <fd_alloc+0x59>
  800e8e:	eb 0c                	jmp    800e9c <fd_alloc+0x50>
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  800e90:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
  800e95:	eb 05                	jmp    800e9c <fd_alloc+0x50>
  800e97:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
  800e9c:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  800e9e:	b8 00 00 00 00       	mov    $0x0,%eax
  800ea3:	eb 17                	jmp    800ebc <fd_alloc+0x70>
  800ea5:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800eaa:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800eaf:	75 b9                	jne    800e6a <fd_alloc+0x1e>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800eb1:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  800eb7:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800ebc:	5b                   	pop    %ebx
  800ebd:	c9                   	leave  
  800ebe:	c3                   	ret    

00800ebf <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800ebf:	55                   	push   %ebp
  800ec0:	89 e5                	mov    %esp,%ebp
  800ec2:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800ec5:	83 f8 1f             	cmp    $0x1f,%eax
  800ec8:	77 36                	ja     800f00 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800eca:	05 00 00 0d 00       	add    $0xd0000,%eax
  800ecf:	c1 e0 0c             	shl    $0xc,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800ed2:	89 c2                	mov    %eax,%edx
  800ed4:	c1 ea 16             	shr    $0x16,%edx
  800ed7:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800ede:	f6 c2 01             	test   $0x1,%dl
  800ee1:	74 24                	je     800f07 <fd_lookup+0x48>
  800ee3:	89 c2                	mov    %eax,%edx
  800ee5:	c1 ea 0c             	shr    $0xc,%edx
  800ee8:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800eef:	f6 c2 01             	test   $0x1,%dl
  800ef2:	74 1a                	je     800f0e <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800ef4:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ef7:	89 02                	mov    %eax,(%edx)
	return 0;
  800ef9:	b8 00 00 00 00       	mov    $0x0,%eax
  800efe:	eb 13                	jmp    800f13 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800f00:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f05:	eb 0c                	jmp    800f13 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800f07:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f0c:	eb 05                	jmp    800f13 <fd_lookup+0x54>
  800f0e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800f13:	c9                   	leave  
  800f14:	c3                   	ret    

00800f15 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800f15:	55                   	push   %ebp
  800f16:	89 e5                	mov    %esp,%ebp
  800f18:	53                   	push   %ebx
  800f19:	83 ec 04             	sub    $0x4,%esp
  800f1c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f1f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  800f22:	39 0d 04 30 80 00    	cmp    %ecx,0x803004
  800f28:	74 0d                	je     800f37 <dev_lookup+0x22>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800f2a:	b8 00 00 00 00       	mov    $0x0,%eax
  800f2f:	eb 14                	jmp    800f45 <dev_lookup+0x30>
		if (devtab[i]->dev_id == dev_id) {
  800f31:	39 0a                	cmp    %ecx,(%edx)
  800f33:	75 10                	jne    800f45 <dev_lookup+0x30>
  800f35:	eb 05                	jmp    800f3c <dev_lookup+0x27>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800f37:	ba 04 30 80 00       	mov    $0x803004,%edx
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
  800f3c:	89 13                	mov    %edx,(%ebx)
			return 0;
  800f3e:	b8 00 00 00 00       	mov    $0x0,%eax
  800f43:	eb 31                	jmp    800f76 <dev_lookup+0x61>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800f45:	40                   	inc    %eax
  800f46:	8b 14 85 cc 23 80 00 	mov    0x8023cc(,%eax,4),%edx
  800f4d:	85 d2                	test   %edx,%edx
  800f4f:	75 e0                	jne    800f31 <dev_lookup+0x1c>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800f51:	a1 20 60 80 00       	mov    0x806020,%eax
  800f56:	8b 40 48             	mov    0x48(%eax),%eax
  800f59:	83 ec 04             	sub    $0x4,%esp
  800f5c:	51                   	push   %ecx
  800f5d:	50                   	push   %eax
  800f5e:	68 4c 23 80 00       	push   $0x80234c
  800f63:	e8 1c f3 ff ff       	call   800284 <cprintf>
	*dev = 0;
  800f68:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  800f6e:	83 c4 10             	add    $0x10,%esp
  800f71:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800f76:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f79:	c9                   	leave  
  800f7a:	c3                   	ret    

00800f7b <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800f7b:	55                   	push   %ebp
  800f7c:	89 e5                	mov    %esp,%ebp
  800f7e:	56                   	push   %esi
  800f7f:	53                   	push   %ebx
  800f80:	83 ec 20             	sub    $0x20,%esp
  800f83:	8b 75 08             	mov    0x8(%ebp),%esi
  800f86:	8a 45 0c             	mov    0xc(%ebp),%al
  800f89:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800f8c:	56                   	push   %esi
  800f8d:	e8 92 fe ff ff       	call   800e24 <fd2num>
  800f92:	8d 55 f4             	lea    -0xc(%ebp),%edx
  800f95:	89 14 24             	mov    %edx,(%esp)
  800f98:	50                   	push   %eax
  800f99:	e8 21 ff ff ff       	call   800ebf <fd_lookup>
  800f9e:	89 c3                	mov    %eax,%ebx
  800fa0:	83 c4 08             	add    $0x8,%esp
  800fa3:	85 c0                	test   %eax,%eax
  800fa5:	78 05                	js     800fac <fd_close+0x31>
	    || fd != fd2)
  800fa7:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800faa:	74 0d                	je     800fb9 <fd_close+0x3e>
		return (must_exist ? r : 0);
  800fac:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  800fb0:	75 48                	jne    800ffa <fd_close+0x7f>
  800fb2:	bb 00 00 00 00       	mov    $0x0,%ebx
  800fb7:	eb 41                	jmp    800ffa <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800fb9:	83 ec 08             	sub    $0x8,%esp
  800fbc:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800fbf:	50                   	push   %eax
  800fc0:	ff 36                	pushl  (%esi)
  800fc2:	e8 4e ff ff ff       	call   800f15 <dev_lookup>
  800fc7:	89 c3                	mov    %eax,%ebx
  800fc9:	83 c4 10             	add    $0x10,%esp
  800fcc:	85 c0                	test   %eax,%eax
  800fce:	78 1c                	js     800fec <fd_close+0x71>
		if (dev->dev_close)
  800fd0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800fd3:	8b 40 10             	mov    0x10(%eax),%eax
  800fd6:	85 c0                	test   %eax,%eax
  800fd8:	74 0d                	je     800fe7 <fd_close+0x6c>
			r = (*dev->dev_close)(fd);
  800fda:	83 ec 0c             	sub    $0xc,%esp
  800fdd:	56                   	push   %esi
  800fde:	ff d0                	call   *%eax
  800fe0:	89 c3                	mov    %eax,%ebx
  800fe2:	83 c4 10             	add    $0x10,%esp
  800fe5:	eb 05                	jmp    800fec <fd_close+0x71>
		else
			r = 0;
  800fe7:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800fec:	83 ec 08             	sub    $0x8,%esp
  800fef:	56                   	push   %esi
  800ff0:	6a 00                	push   $0x0
  800ff2:	e8 0f fd ff ff       	call   800d06 <sys_page_unmap>
	return r;
  800ff7:	83 c4 10             	add    $0x10,%esp
}
  800ffa:	89 d8                	mov    %ebx,%eax
  800ffc:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800fff:	5b                   	pop    %ebx
  801000:	5e                   	pop    %esi
  801001:	c9                   	leave  
  801002:	c3                   	ret    

00801003 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801003:	55                   	push   %ebp
  801004:	89 e5                	mov    %esp,%ebp
  801006:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801009:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80100c:	50                   	push   %eax
  80100d:	ff 75 08             	pushl  0x8(%ebp)
  801010:	e8 aa fe ff ff       	call   800ebf <fd_lookup>
  801015:	83 c4 08             	add    $0x8,%esp
  801018:	85 c0                	test   %eax,%eax
  80101a:	78 10                	js     80102c <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  80101c:	83 ec 08             	sub    $0x8,%esp
  80101f:	6a 01                	push   $0x1
  801021:	ff 75 f4             	pushl  -0xc(%ebp)
  801024:	e8 52 ff ff ff       	call   800f7b <fd_close>
  801029:	83 c4 10             	add    $0x10,%esp
}
  80102c:	c9                   	leave  
  80102d:	c3                   	ret    

0080102e <close_all>:

void
close_all(void)
{
  80102e:	55                   	push   %ebp
  80102f:	89 e5                	mov    %esp,%ebp
  801031:	53                   	push   %ebx
  801032:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801035:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80103a:	83 ec 0c             	sub    $0xc,%esp
  80103d:	53                   	push   %ebx
  80103e:	e8 c0 ff ff ff       	call   801003 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801043:	43                   	inc    %ebx
  801044:	83 c4 10             	add    $0x10,%esp
  801047:	83 fb 20             	cmp    $0x20,%ebx
  80104a:	75 ee                	jne    80103a <close_all+0xc>
		close(i);
}
  80104c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80104f:	c9                   	leave  
  801050:	c3                   	ret    

00801051 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801051:	55                   	push   %ebp
  801052:	89 e5                	mov    %esp,%ebp
  801054:	57                   	push   %edi
  801055:	56                   	push   %esi
  801056:	53                   	push   %ebx
  801057:	83 ec 2c             	sub    $0x2c,%esp
  80105a:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80105d:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801060:	50                   	push   %eax
  801061:	ff 75 08             	pushl  0x8(%ebp)
  801064:	e8 56 fe ff ff       	call   800ebf <fd_lookup>
  801069:	89 c3                	mov    %eax,%ebx
  80106b:	83 c4 08             	add    $0x8,%esp
  80106e:	85 c0                	test   %eax,%eax
  801070:	0f 88 c0 00 00 00    	js     801136 <dup+0xe5>
		return r;
	close(newfdnum);
  801076:	83 ec 0c             	sub    $0xc,%esp
  801079:	57                   	push   %edi
  80107a:	e8 84 ff ff ff       	call   801003 <close>

	newfd = INDEX2FD(newfdnum);
  80107f:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  801085:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  801088:	83 c4 04             	add    $0x4,%esp
  80108b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80108e:	e8 a1 fd ff ff       	call   800e34 <fd2data>
  801093:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801095:	89 34 24             	mov    %esi,(%esp)
  801098:	e8 97 fd ff ff       	call   800e34 <fd2data>
  80109d:	83 c4 10             	add    $0x10,%esp
  8010a0:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8010a3:	89 d8                	mov    %ebx,%eax
  8010a5:	c1 e8 16             	shr    $0x16,%eax
  8010a8:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8010af:	a8 01                	test   $0x1,%al
  8010b1:	74 37                	je     8010ea <dup+0x99>
  8010b3:	89 d8                	mov    %ebx,%eax
  8010b5:	c1 e8 0c             	shr    $0xc,%eax
  8010b8:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8010bf:	f6 c2 01             	test   $0x1,%dl
  8010c2:	74 26                	je     8010ea <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8010c4:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8010cb:	83 ec 0c             	sub    $0xc,%esp
  8010ce:	25 07 0e 00 00       	and    $0xe07,%eax
  8010d3:	50                   	push   %eax
  8010d4:	ff 75 d4             	pushl  -0x2c(%ebp)
  8010d7:	6a 00                	push   $0x0
  8010d9:	53                   	push   %ebx
  8010da:	6a 00                	push   $0x0
  8010dc:	e8 ff fb ff ff       	call   800ce0 <sys_page_map>
  8010e1:	89 c3                	mov    %eax,%ebx
  8010e3:	83 c4 20             	add    $0x20,%esp
  8010e6:	85 c0                	test   %eax,%eax
  8010e8:	78 2d                	js     801117 <dup+0xc6>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8010ea:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8010ed:	89 c2                	mov    %eax,%edx
  8010ef:	c1 ea 0c             	shr    $0xc,%edx
  8010f2:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8010f9:	83 ec 0c             	sub    $0xc,%esp
  8010fc:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  801102:	52                   	push   %edx
  801103:	56                   	push   %esi
  801104:	6a 00                	push   $0x0
  801106:	50                   	push   %eax
  801107:	6a 00                	push   $0x0
  801109:	e8 d2 fb ff ff       	call   800ce0 <sys_page_map>
  80110e:	89 c3                	mov    %eax,%ebx
  801110:	83 c4 20             	add    $0x20,%esp
  801113:	85 c0                	test   %eax,%eax
  801115:	79 1d                	jns    801134 <dup+0xe3>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801117:	83 ec 08             	sub    $0x8,%esp
  80111a:	56                   	push   %esi
  80111b:	6a 00                	push   $0x0
  80111d:	e8 e4 fb ff ff       	call   800d06 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801122:	83 c4 08             	add    $0x8,%esp
  801125:	ff 75 d4             	pushl  -0x2c(%ebp)
  801128:	6a 00                	push   $0x0
  80112a:	e8 d7 fb ff ff       	call   800d06 <sys_page_unmap>
	return r;
  80112f:	83 c4 10             	add    $0x10,%esp
  801132:	eb 02                	jmp    801136 <dup+0xe5>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  801134:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  801136:	89 d8                	mov    %ebx,%eax
  801138:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80113b:	5b                   	pop    %ebx
  80113c:	5e                   	pop    %esi
  80113d:	5f                   	pop    %edi
  80113e:	c9                   	leave  
  80113f:	c3                   	ret    

00801140 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801140:	55                   	push   %ebp
  801141:	89 e5                	mov    %esp,%ebp
  801143:	53                   	push   %ebx
  801144:	83 ec 14             	sub    $0x14,%esp
  801147:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80114a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80114d:	50                   	push   %eax
  80114e:	53                   	push   %ebx
  80114f:	e8 6b fd ff ff       	call   800ebf <fd_lookup>
  801154:	83 c4 08             	add    $0x8,%esp
  801157:	85 c0                	test   %eax,%eax
  801159:	78 67                	js     8011c2 <read+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80115b:	83 ec 08             	sub    $0x8,%esp
  80115e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801161:	50                   	push   %eax
  801162:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801165:	ff 30                	pushl  (%eax)
  801167:	e8 a9 fd ff ff       	call   800f15 <dev_lookup>
  80116c:	83 c4 10             	add    $0x10,%esp
  80116f:	85 c0                	test   %eax,%eax
  801171:	78 4f                	js     8011c2 <read+0x82>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801173:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801176:	8b 50 08             	mov    0x8(%eax),%edx
  801179:	83 e2 03             	and    $0x3,%edx
  80117c:	83 fa 01             	cmp    $0x1,%edx
  80117f:	75 21                	jne    8011a2 <read+0x62>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801181:	a1 20 60 80 00       	mov    0x806020,%eax
  801186:	8b 40 48             	mov    0x48(%eax),%eax
  801189:	83 ec 04             	sub    $0x4,%esp
  80118c:	53                   	push   %ebx
  80118d:	50                   	push   %eax
  80118e:	68 90 23 80 00       	push   $0x802390
  801193:	e8 ec f0 ff ff       	call   800284 <cprintf>
		return -E_INVAL;
  801198:	83 c4 10             	add    $0x10,%esp
  80119b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8011a0:	eb 20                	jmp    8011c2 <read+0x82>
	}
	if (!dev->dev_read)
  8011a2:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8011a5:	8b 52 08             	mov    0x8(%edx),%edx
  8011a8:	85 d2                	test   %edx,%edx
  8011aa:	74 11                	je     8011bd <read+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8011ac:	83 ec 04             	sub    $0x4,%esp
  8011af:	ff 75 10             	pushl  0x10(%ebp)
  8011b2:	ff 75 0c             	pushl  0xc(%ebp)
  8011b5:	50                   	push   %eax
  8011b6:	ff d2                	call   *%edx
  8011b8:	83 c4 10             	add    $0x10,%esp
  8011bb:	eb 05                	jmp    8011c2 <read+0x82>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8011bd:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  8011c2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8011c5:	c9                   	leave  
  8011c6:	c3                   	ret    

008011c7 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8011c7:	55                   	push   %ebp
  8011c8:	89 e5                	mov    %esp,%ebp
  8011ca:	57                   	push   %edi
  8011cb:	56                   	push   %esi
  8011cc:	53                   	push   %ebx
  8011cd:	83 ec 0c             	sub    $0xc,%esp
  8011d0:	8b 7d 08             	mov    0x8(%ebp),%edi
  8011d3:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8011d6:	85 f6                	test   %esi,%esi
  8011d8:	74 31                	je     80120b <readn+0x44>
  8011da:	b8 00 00 00 00       	mov    $0x0,%eax
  8011df:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = read(fdnum, (char*)buf + tot, n - tot);
  8011e4:	83 ec 04             	sub    $0x4,%esp
  8011e7:	89 f2                	mov    %esi,%edx
  8011e9:	29 c2                	sub    %eax,%edx
  8011eb:	52                   	push   %edx
  8011ec:	03 45 0c             	add    0xc(%ebp),%eax
  8011ef:	50                   	push   %eax
  8011f0:	57                   	push   %edi
  8011f1:	e8 4a ff ff ff       	call   801140 <read>
		if (m < 0)
  8011f6:	83 c4 10             	add    $0x10,%esp
  8011f9:	85 c0                	test   %eax,%eax
  8011fb:	78 17                	js     801214 <readn+0x4d>
			return m;
		if (m == 0)
  8011fd:	85 c0                	test   %eax,%eax
  8011ff:	74 11                	je     801212 <readn+0x4b>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801201:	01 c3                	add    %eax,%ebx
  801203:	89 d8                	mov    %ebx,%eax
  801205:	39 f3                	cmp    %esi,%ebx
  801207:	72 db                	jb     8011e4 <readn+0x1d>
  801209:	eb 09                	jmp    801214 <readn+0x4d>
  80120b:	b8 00 00 00 00       	mov    $0x0,%eax
  801210:	eb 02                	jmp    801214 <readn+0x4d>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  801212:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  801214:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801217:	5b                   	pop    %ebx
  801218:	5e                   	pop    %esi
  801219:	5f                   	pop    %edi
  80121a:	c9                   	leave  
  80121b:	c3                   	ret    

0080121c <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80121c:	55                   	push   %ebp
  80121d:	89 e5                	mov    %esp,%ebp
  80121f:	53                   	push   %ebx
  801220:	83 ec 14             	sub    $0x14,%esp
  801223:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801226:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801229:	50                   	push   %eax
  80122a:	53                   	push   %ebx
  80122b:	e8 8f fc ff ff       	call   800ebf <fd_lookup>
  801230:	83 c4 08             	add    $0x8,%esp
  801233:	85 c0                	test   %eax,%eax
  801235:	78 62                	js     801299 <write+0x7d>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801237:	83 ec 08             	sub    $0x8,%esp
  80123a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80123d:	50                   	push   %eax
  80123e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801241:	ff 30                	pushl  (%eax)
  801243:	e8 cd fc ff ff       	call   800f15 <dev_lookup>
  801248:	83 c4 10             	add    $0x10,%esp
  80124b:	85 c0                	test   %eax,%eax
  80124d:	78 4a                	js     801299 <write+0x7d>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80124f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801252:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801256:	75 21                	jne    801279 <write+0x5d>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801258:	a1 20 60 80 00       	mov    0x806020,%eax
  80125d:	8b 40 48             	mov    0x48(%eax),%eax
  801260:	83 ec 04             	sub    $0x4,%esp
  801263:	53                   	push   %ebx
  801264:	50                   	push   %eax
  801265:	68 ac 23 80 00       	push   $0x8023ac
  80126a:	e8 15 f0 ff ff       	call   800284 <cprintf>
		return -E_INVAL;
  80126f:	83 c4 10             	add    $0x10,%esp
  801272:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801277:	eb 20                	jmp    801299 <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801279:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80127c:	8b 52 0c             	mov    0xc(%edx),%edx
  80127f:	85 d2                	test   %edx,%edx
  801281:	74 11                	je     801294 <write+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801283:	83 ec 04             	sub    $0x4,%esp
  801286:	ff 75 10             	pushl  0x10(%ebp)
  801289:	ff 75 0c             	pushl  0xc(%ebp)
  80128c:	50                   	push   %eax
  80128d:	ff d2                	call   *%edx
  80128f:	83 c4 10             	add    $0x10,%esp
  801292:	eb 05                	jmp    801299 <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801294:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  801299:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80129c:	c9                   	leave  
  80129d:	c3                   	ret    

0080129e <seek>:

int
seek(int fdnum, off_t offset)
{
  80129e:	55                   	push   %ebp
  80129f:	89 e5                	mov    %esp,%ebp
  8012a1:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8012a4:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8012a7:	50                   	push   %eax
  8012a8:	ff 75 08             	pushl  0x8(%ebp)
  8012ab:	e8 0f fc ff ff       	call   800ebf <fd_lookup>
  8012b0:	83 c4 08             	add    $0x8,%esp
  8012b3:	85 c0                	test   %eax,%eax
  8012b5:	78 0e                	js     8012c5 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8012b7:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8012ba:	8b 55 0c             	mov    0xc(%ebp),%edx
  8012bd:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8012c0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8012c5:	c9                   	leave  
  8012c6:	c3                   	ret    

008012c7 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8012c7:	55                   	push   %ebp
  8012c8:	89 e5                	mov    %esp,%ebp
  8012ca:	53                   	push   %ebx
  8012cb:	83 ec 14             	sub    $0x14,%esp
  8012ce:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8012d1:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012d4:	50                   	push   %eax
  8012d5:	53                   	push   %ebx
  8012d6:	e8 e4 fb ff ff       	call   800ebf <fd_lookup>
  8012db:	83 c4 08             	add    $0x8,%esp
  8012de:	85 c0                	test   %eax,%eax
  8012e0:	78 5f                	js     801341 <ftruncate+0x7a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012e2:	83 ec 08             	sub    $0x8,%esp
  8012e5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012e8:	50                   	push   %eax
  8012e9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012ec:	ff 30                	pushl  (%eax)
  8012ee:	e8 22 fc ff ff       	call   800f15 <dev_lookup>
  8012f3:	83 c4 10             	add    $0x10,%esp
  8012f6:	85 c0                	test   %eax,%eax
  8012f8:	78 47                	js     801341 <ftruncate+0x7a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8012fa:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012fd:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801301:	75 21                	jne    801324 <ftruncate+0x5d>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801303:	a1 20 60 80 00       	mov    0x806020,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801308:	8b 40 48             	mov    0x48(%eax),%eax
  80130b:	83 ec 04             	sub    $0x4,%esp
  80130e:	53                   	push   %ebx
  80130f:	50                   	push   %eax
  801310:	68 6c 23 80 00       	push   $0x80236c
  801315:	e8 6a ef ff ff       	call   800284 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80131a:	83 c4 10             	add    $0x10,%esp
  80131d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801322:	eb 1d                	jmp    801341 <ftruncate+0x7a>
	}
	if (!dev->dev_trunc)
  801324:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801327:	8b 52 18             	mov    0x18(%edx),%edx
  80132a:	85 d2                	test   %edx,%edx
  80132c:	74 0e                	je     80133c <ftruncate+0x75>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80132e:	83 ec 08             	sub    $0x8,%esp
  801331:	ff 75 0c             	pushl  0xc(%ebp)
  801334:	50                   	push   %eax
  801335:	ff d2                	call   *%edx
  801337:	83 c4 10             	add    $0x10,%esp
  80133a:	eb 05                	jmp    801341 <ftruncate+0x7a>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80133c:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  801341:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801344:	c9                   	leave  
  801345:	c3                   	ret    

00801346 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801346:	55                   	push   %ebp
  801347:	89 e5                	mov    %esp,%ebp
  801349:	53                   	push   %ebx
  80134a:	83 ec 14             	sub    $0x14,%esp
  80134d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801350:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801353:	50                   	push   %eax
  801354:	ff 75 08             	pushl  0x8(%ebp)
  801357:	e8 63 fb ff ff       	call   800ebf <fd_lookup>
  80135c:	83 c4 08             	add    $0x8,%esp
  80135f:	85 c0                	test   %eax,%eax
  801361:	78 52                	js     8013b5 <fstat+0x6f>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801363:	83 ec 08             	sub    $0x8,%esp
  801366:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801369:	50                   	push   %eax
  80136a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80136d:	ff 30                	pushl  (%eax)
  80136f:	e8 a1 fb ff ff       	call   800f15 <dev_lookup>
  801374:	83 c4 10             	add    $0x10,%esp
  801377:	85 c0                	test   %eax,%eax
  801379:	78 3a                	js     8013b5 <fstat+0x6f>
		return r;
	if (!dev->dev_stat)
  80137b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80137e:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801382:	74 2c                	je     8013b0 <fstat+0x6a>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801384:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801387:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80138e:	00 00 00 
	stat->st_isdir = 0;
  801391:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801398:	00 00 00 
	stat->st_dev = dev;
  80139b:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8013a1:	83 ec 08             	sub    $0x8,%esp
  8013a4:	53                   	push   %ebx
  8013a5:	ff 75 f0             	pushl  -0x10(%ebp)
  8013a8:	ff 50 14             	call   *0x14(%eax)
  8013ab:	83 c4 10             	add    $0x10,%esp
  8013ae:	eb 05                	jmp    8013b5 <fstat+0x6f>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8013b0:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8013b5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013b8:	c9                   	leave  
  8013b9:	c3                   	ret    

008013ba <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8013ba:	55                   	push   %ebp
  8013bb:	89 e5                	mov    %esp,%ebp
  8013bd:	56                   	push   %esi
  8013be:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8013bf:	83 ec 08             	sub    $0x8,%esp
  8013c2:	6a 00                	push   $0x0
  8013c4:	ff 75 08             	pushl  0x8(%ebp)
  8013c7:	e8 78 01 00 00       	call   801544 <open>
  8013cc:	89 c3                	mov    %eax,%ebx
  8013ce:	83 c4 10             	add    $0x10,%esp
  8013d1:	85 c0                	test   %eax,%eax
  8013d3:	78 1b                	js     8013f0 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8013d5:	83 ec 08             	sub    $0x8,%esp
  8013d8:	ff 75 0c             	pushl  0xc(%ebp)
  8013db:	50                   	push   %eax
  8013dc:	e8 65 ff ff ff       	call   801346 <fstat>
  8013e1:	89 c6                	mov    %eax,%esi
	close(fd);
  8013e3:	89 1c 24             	mov    %ebx,(%esp)
  8013e6:	e8 18 fc ff ff       	call   801003 <close>
	return r;
  8013eb:	83 c4 10             	add    $0x10,%esp
  8013ee:	89 f3                	mov    %esi,%ebx
}
  8013f0:	89 d8                	mov    %ebx,%eax
  8013f2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8013f5:	5b                   	pop    %ebx
  8013f6:	5e                   	pop    %esi
  8013f7:	c9                   	leave  
  8013f8:	c3                   	ret    
  8013f9:	00 00                	add    %al,(%eax)
	...

008013fc <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8013fc:	55                   	push   %ebp
  8013fd:	89 e5                	mov    %esp,%ebp
  8013ff:	56                   	push   %esi
  801400:	53                   	push   %ebx
  801401:	89 c3                	mov    %eax,%ebx
  801403:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  801405:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  80140c:	75 12                	jne    801420 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80140e:	83 ec 0c             	sub    $0xc,%esp
  801411:	6a 01                	push   $0x1
  801413:	e8 9e 08 00 00       	call   801cb6 <ipc_find_env>
  801418:	a3 00 40 80 00       	mov    %eax,0x804000
  80141d:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801420:	6a 07                	push   $0x7
  801422:	68 00 70 80 00       	push   $0x807000
  801427:	53                   	push   %ebx
  801428:	ff 35 00 40 80 00    	pushl  0x804000
  80142e:	e8 2e 08 00 00       	call   801c61 <ipc_send>
	
	return ipc_recv(NULL, dstva, NULL);
  801433:	83 c4 0c             	add    $0xc,%esp
  801436:	6a 00                	push   $0x0
  801438:	56                   	push   %esi
  801439:	6a 00                	push   $0x0
  80143b:	e8 ac 07 00 00       	call   801bec <ipc_recv>
}
  801440:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801443:	5b                   	pop    %ebx
  801444:	5e                   	pop    %esi
  801445:	c9                   	leave  
  801446:	c3                   	ret    

00801447 <devfile_stat>:
}


static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801447:	55                   	push   %ebp
  801448:	89 e5                	mov    %esp,%ebp
  80144a:	53                   	push   %ebx
  80144b:	83 ec 04             	sub    $0x4,%esp
  80144e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801451:	8b 45 08             	mov    0x8(%ebp),%eax
  801454:	8b 40 0c             	mov    0xc(%eax),%eax
  801457:	a3 00 70 80 00       	mov    %eax,0x807000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0) {
  80145c:	ba 00 00 00 00       	mov    $0x0,%edx
  801461:	b8 05 00 00 00       	mov    $0x5,%eax
  801466:	e8 91 ff ff ff       	call   8013fc <fsipc>
  80146b:	85 c0                	test   %eax,%eax
  80146d:	78 2c                	js     80149b <devfile_stat+0x54>
		return r;
	}
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80146f:	83 ec 08             	sub    $0x8,%esp
  801472:	68 00 70 80 00       	push   $0x807000
  801477:	53                   	push   %ebx
  801478:	e8 bd f3 ff ff       	call   80083a <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  80147d:	a1 80 70 80 00       	mov    0x807080,%eax
  801482:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801488:	a1 84 70 80 00       	mov    0x807084,%eax
  80148d:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801493:	83 c4 10             	add    $0x10,%esp
  801496:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80149b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80149e:	c9                   	leave  
  80149f:	c3                   	ret    

008014a0 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8014a0:	55                   	push   %ebp
  8014a1:	89 e5                	mov    %esp,%ebp
  8014a3:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8014a6:	8b 45 08             	mov    0x8(%ebp),%eax
  8014a9:	8b 40 0c             	mov    0xc(%eax),%eax
  8014ac:	a3 00 70 80 00       	mov    %eax,0x807000
	return fsipc(FSREQ_FLUSH, NULL);
  8014b1:	ba 00 00 00 00       	mov    $0x0,%edx
  8014b6:	b8 06 00 00 00       	mov    $0x6,%eax
  8014bb:	e8 3c ff ff ff       	call   8013fc <fsipc>
}
  8014c0:	c9                   	leave  
  8014c1:	c3                   	ret    

008014c2 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8014c2:	55                   	push   %ebp
  8014c3:	89 e5                	mov    %esp,%ebp
  8014c5:	56                   	push   %esi
  8014c6:	53                   	push   %ebx
  8014c7:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8014ca:	8b 45 08             	mov    0x8(%ebp),%eax
  8014cd:	8b 40 0c             	mov    0xc(%eax),%eax
  8014d0:	a3 00 70 80 00       	mov    %eax,0x807000
	fsipcbuf.read.req_n = n;
  8014d5:	89 35 04 70 80 00    	mov    %esi,0x807004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8014db:	ba 00 00 00 00       	mov    $0x0,%edx
  8014e0:	b8 03 00 00 00       	mov    $0x3,%eax
  8014e5:	e8 12 ff ff ff       	call   8013fc <fsipc>
  8014ea:	89 c3                	mov    %eax,%ebx
  8014ec:	85 c0                	test   %eax,%eax
  8014ee:	78 4b                	js     80153b <devfile_read+0x79>
		return r;
	assert(r <= n);
  8014f0:	39 c6                	cmp    %eax,%esi
  8014f2:	73 16                	jae    80150a <devfile_read+0x48>
  8014f4:	68 dc 23 80 00       	push   $0x8023dc
  8014f9:	68 e3 23 80 00       	push   $0x8023e3
  8014fe:	6a 7d                	push   $0x7d
  801500:	68 f8 23 80 00       	push   $0x8023f8
  801505:	e8 a2 ec ff ff       	call   8001ac <_panic>
	assert(r <= PGSIZE);
  80150a:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80150f:	7e 16                	jle    801527 <devfile_read+0x65>
  801511:	68 03 24 80 00       	push   $0x802403
  801516:	68 e3 23 80 00       	push   $0x8023e3
  80151b:	6a 7e                	push   $0x7e
  80151d:	68 f8 23 80 00       	push   $0x8023f8
  801522:	e8 85 ec ff ff       	call   8001ac <_panic>
	memmove(buf, &fsipcbuf, r);
  801527:	83 ec 04             	sub    $0x4,%esp
  80152a:	50                   	push   %eax
  80152b:	68 00 70 80 00       	push   $0x807000
  801530:	ff 75 0c             	pushl  0xc(%ebp)
  801533:	e8 c3 f4 ff ff       	call   8009fb <memmove>
	return r;
  801538:	83 c4 10             	add    $0x10,%esp
}
  80153b:	89 d8                	mov    %ebx,%eax
  80153d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801540:	5b                   	pop    %ebx
  801541:	5e                   	pop    %esi
  801542:	c9                   	leave  
  801543:	c3                   	ret    

00801544 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801544:	55                   	push   %ebp
  801545:	89 e5                	mov    %esp,%ebp
  801547:	56                   	push   %esi
  801548:	53                   	push   %ebx
  801549:	83 ec 1c             	sub    $0x1c,%esp
  80154c:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  80154f:	56                   	push   %esi
  801550:	e8 93 f2 ff ff       	call   8007e8 <strlen>
  801555:	83 c4 10             	add    $0x10,%esp
  801558:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  80155d:	7f 65                	jg     8015c4 <open+0x80>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80155f:	83 ec 0c             	sub    $0xc,%esp
  801562:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801565:	50                   	push   %eax
  801566:	e8 e1 f8 ff ff       	call   800e4c <fd_alloc>
  80156b:	89 c3                	mov    %eax,%ebx
  80156d:	83 c4 10             	add    $0x10,%esp
  801570:	85 c0                	test   %eax,%eax
  801572:	78 55                	js     8015c9 <open+0x85>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801574:	83 ec 08             	sub    $0x8,%esp
  801577:	56                   	push   %esi
  801578:	68 00 70 80 00       	push   $0x807000
  80157d:	e8 b8 f2 ff ff       	call   80083a <strcpy>
	fsipcbuf.open.req_omode = mode;
  801582:	8b 45 0c             	mov    0xc(%ebp),%eax
  801585:	a3 00 74 80 00       	mov    %eax,0x807400



	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  80158a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80158d:	b8 01 00 00 00       	mov    $0x1,%eax
  801592:	e8 65 fe ff ff       	call   8013fc <fsipc>
  801597:	89 c3                	mov    %eax,%ebx
  801599:	83 c4 10             	add    $0x10,%esp
  80159c:	85 c0                	test   %eax,%eax
  80159e:	79 12                	jns    8015b2 <open+0x6e>
		fd_close(fd, 0);
  8015a0:	83 ec 08             	sub    $0x8,%esp
  8015a3:	6a 00                	push   $0x0
  8015a5:	ff 75 f4             	pushl  -0xc(%ebp)
  8015a8:	e8 ce f9 ff ff       	call   800f7b <fd_close>
		return r;
  8015ad:	83 c4 10             	add    $0x10,%esp
  8015b0:	eb 17                	jmp    8015c9 <open+0x85>
	}

	return fd2num(fd);
  8015b2:	83 ec 0c             	sub    $0xc,%esp
  8015b5:	ff 75 f4             	pushl  -0xc(%ebp)
  8015b8:	e8 67 f8 ff ff       	call   800e24 <fd2num>
  8015bd:	89 c3                	mov    %eax,%ebx
  8015bf:	83 c4 10             	add    $0x10,%esp
  8015c2:	eb 05                	jmp    8015c9 <open+0x85>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8015c4:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8015c9:	89 d8                	mov    %ebx,%eax
  8015cb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8015ce:	5b                   	pop    %ebx
  8015cf:	5e                   	pop    %esi
  8015d0:	c9                   	leave  
  8015d1:	c3                   	ret    
	...

008015d4 <writebuf>:
};


static void
writebuf(struct printbuf *b)
{
  8015d4:	55                   	push   %ebp
  8015d5:	89 e5                	mov    %esp,%ebp
  8015d7:	53                   	push   %ebx
  8015d8:	83 ec 04             	sub    $0x4,%esp
  8015db:	89 c3                	mov    %eax,%ebx
	if (b->error > 0) {
  8015dd:	83 78 0c 00          	cmpl   $0x0,0xc(%eax)
  8015e1:	7e 2e                	jle    801611 <writebuf+0x3d>
		ssize_t result = write(b->fd, b->buf, b->idx);
  8015e3:	83 ec 04             	sub    $0x4,%esp
  8015e6:	ff 70 04             	pushl  0x4(%eax)
  8015e9:	8d 40 10             	lea    0x10(%eax),%eax
  8015ec:	50                   	push   %eax
  8015ed:	ff 33                	pushl  (%ebx)
  8015ef:	e8 28 fc ff ff       	call   80121c <write>
		if (result > 0)
  8015f4:	83 c4 10             	add    $0x10,%esp
  8015f7:	85 c0                	test   %eax,%eax
  8015f9:	7e 03                	jle    8015fe <writebuf+0x2a>
			b->result += result;
  8015fb:	01 43 08             	add    %eax,0x8(%ebx)
		if (result != b->idx) // error, or wrote less than supplied
  8015fe:	39 43 04             	cmp    %eax,0x4(%ebx)
  801601:	74 0e                	je     801611 <writebuf+0x3d>
			b->error = (result < 0 ? result : 0);
  801603:	89 c2                	mov    %eax,%edx
  801605:	85 c0                	test   %eax,%eax
  801607:	7e 05                	jle    80160e <writebuf+0x3a>
  801609:	ba 00 00 00 00       	mov    $0x0,%edx
  80160e:	89 53 0c             	mov    %edx,0xc(%ebx)
	}
}
  801611:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801614:	c9                   	leave  
  801615:	c3                   	ret    

00801616 <putch>:

static void
putch(int ch, void *thunk)
{
  801616:	55                   	push   %ebp
  801617:	89 e5                	mov    %esp,%ebp
  801619:	53                   	push   %ebx
  80161a:	83 ec 04             	sub    $0x4,%esp
  80161d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct printbuf *b = (struct printbuf *) thunk;
	b->buf[b->idx++] = ch;
  801620:	8b 43 04             	mov    0x4(%ebx),%eax
  801623:	8b 55 08             	mov    0x8(%ebp),%edx
  801626:	88 54 03 10          	mov    %dl,0x10(%ebx,%eax,1)
  80162a:	40                   	inc    %eax
  80162b:	89 43 04             	mov    %eax,0x4(%ebx)
	if (b->idx == 256) {
  80162e:	3d 00 01 00 00       	cmp    $0x100,%eax
  801633:	75 0e                	jne    801643 <putch+0x2d>
		writebuf(b);
  801635:	89 d8                	mov    %ebx,%eax
  801637:	e8 98 ff ff ff       	call   8015d4 <writebuf>
		b->idx = 0;
  80163c:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	}
}
  801643:	83 c4 04             	add    $0x4,%esp
  801646:	5b                   	pop    %ebx
  801647:	c9                   	leave  
  801648:	c3                   	ret    

00801649 <vfprintf>:

int
vfprintf(int fd, const char *fmt, va_list ap)
{
  801649:	55                   	push   %ebp
  80164a:	89 e5                	mov    %esp,%ebp
  80164c:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.fd = fd;
  801652:	8b 45 08             	mov    0x8(%ebp),%eax
  801655:	89 85 e8 fe ff ff    	mov    %eax,-0x118(%ebp)
	b.idx = 0;
  80165b:	c7 85 ec fe ff ff 00 	movl   $0x0,-0x114(%ebp)
  801662:	00 00 00 
	b.result = 0;
  801665:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80166c:	00 00 00 
	b.error = 1;
  80166f:	c7 85 f4 fe ff ff 01 	movl   $0x1,-0x10c(%ebp)
  801676:	00 00 00 
	vprintfmt(putch, &b, fmt, ap);
  801679:	ff 75 10             	pushl  0x10(%ebp)
  80167c:	ff 75 0c             	pushl  0xc(%ebp)
  80167f:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  801685:	50                   	push   %eax
  801686:	68 16 16 80 00       	push   $0x801616
  80168b:	e8 59 ed ff ff       	call   8003e9 <vprintfmt>
	if (b.idx > 0)
  801690:	83 c4 10             	add    $0x10,%esp
  801693:	83 bd ec fe ff ff 00 	cmpl   $0x0,-0x114(%ebp)
  80169a:	7e 0b                	jle    8016a7 <vfprintf+0x5e>
		writebuf(&b);
  80169c:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  8016a2:	e8 2d ff ff ff       	call   8015d4 <writebuf>

	return (b.result ? b.result : b.error);
  8016a7:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8016ad:	85 c0                	test   %eax,%eax
  8016af:	75 06                	jne    8016b7 <vfprintf+0x6e>
  8016b1:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
}
  8016b7:	c9                   	leave  
  8016b8:	c3                   	ret    

008016b9 <fprintf>:

int
fprintf(int fd, const char *fmt, ...)
{
  8016b9:	55                   	push   %ebp
  8016ba:	89 e5                	mov    %esp,%ebp
  8016bc:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8016bf:	8d 45 10             	lea    0x10(%ebp),%eax
	cnt = vfprintf(fd, fmt, ap);
  8016c2:	50                   	push   %eax
  8016c3:	ff 75 0c             	pushl  0xc(%ebp)
  8016c6:	ff 75 08             	pushl  0x8(%ebp)
  8016c9:	e8 7b ff ff ff       	call   801649 <vfprintf>
	va_end(ap);

	return cnt;
}
  8016ce:	c9                   	leave  
  8016cf:	c3                   	ret    

008016d0 <printf>:

int
printf(const char *fmt, ...)
{
  8016d0:	55                   	push   %ebp
  8016d1:	89 e5                	mov    %esp,%ebp
  8016d3:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8016d6:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vfprintf(1, fmt, ap);
  8016d9:	50                   	push   %eax
  8016da:	ff 75 08             	pushl  0x8(%ebp)
  8016dd:	6a 01                	push   $0x1
  8016df:	e8 65 ff ff ff       	call   801649 <vfprintf>
	va_end(ap);

	return cnt;
}
  8016e4:	c9                   	leave  
  8016e5:	c3                   	ret    
	...

008016e8 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8016e8:	55                   	push   %ebp
  8016e9:	89 e5                	mov    %esp,%ebp
  8016eb:	56                   	push   %esi
  8016ec:	53                   	push   %ebx
  8016ed:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8016f0:	83 ec 0c             	sub    $0xc,%esp
  8016f3:	ff 75 08             	pushl  0x8(%ebp)
  8016f6:	e8 39 f7 ff ff       	call   800e34 <fd2data>
  8016fb:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  8016fd:	83 c4 08             	add    $0x8,%esp
  801700:	68 0f 24 80 00       	push   $0x80240f
  801705:	56                   	push   %esi
  801706:	e8 2f f1 ff ff       	call   80083a <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  80170b:	8b 43 04             	mov    0x4(%ebx),%eax
  80170e:	2b 03                	sub    (%ebx),%eax
  801710:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  801716:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  80171d:	00 00 00 
	stat->st_dev = &devpipe;
  801720:	c7 86 88 00 00 00 20 	movl   $0x803020,0x88(%esi)
  801727:	30 80 00 
	return 0;
}
  80172a:	b8 00 00 00 00       	mov    $0x0,%eax
  80172f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801732:	5b                   	pop    %ebx
  801733:	5e                   	pop    %esi
  801734:	c9                   	leave  
  801735:	c3                   	ret    

00801736 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801736:	55                   	push   %ebp
  801737:	89 e5                	mov    %esp,%ebp
  801739:	53                   	push   %ebx
  80173a:	83 ec 0c             	sub    $0xc,%esp
  80173d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801740:	53                   	push   %ebx
  801741:	6a 00                	push   $0x0
  801743:	e8 be f5 ff ff       	call   800d06 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801748:	89 1c 24             	mov    %ebx,(%esp)
  80174b:	e8 e4 f6 ff ff       	call   800e34 <fd2data>
  801750:	83 c4 08             	add    $0x8,%esp
  801753:	50                   	push   %eax
  801754:	6a 00                	push   $0x0
  801756:	e8 ab f5 ff ff       	call   800d06 <sys_page_unmap>
}
  80175b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80175e:	c9                   	leave  
  80175f:	c3                   	ret    

00801760 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801760:	55                   	push   %ebp
  801761:	89 e5                	mov    %esp,%ebp
  801763:	57                   	push   %edi
  801764:	56                   	push   %esi
  801765:	53                   	push   %ebx
  801766:	83 ec 1c             	sub    $0x1c,%esp
  801769:	89 c7                	mov    %eax,%edi
  80176b:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  80176e:	a1 20 60 80 00       	mov    0x806020,%eax
  801773:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801776:	83 ec 0c             	sub    $0xc,%esp
  801779:	57                   	push   %edi
  80177a:	e8 95 05 00 00       	call   801d14 <pageref>
  80177f:	89 c6                	mov    %eax,%esi
  801781:	83 c4 04             	add    $0x4,%esp
  801784:	ff 75 e4             	pushl  -0x1c(%ebp)
  801787:	e8 88 05 00 00       	call   801d14 <pageref>
  80178c:	83 c4 10             	add    $0x10,%esp
  80178f:	39 c6                	cmp    %eax,%esi
  801791:	0f 94 c0             	sete   %al
  801794:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  801797:	8b 15 20 60 80 00    	mov    0x806020,%edx
  80179d:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  8017a0:	39 cb                	cmp    %ecx,%ebx
  8017a2:	75 08                	jne    8017ac <_pipeisclosed+0x4c>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  8017a4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8017a7:	5b                   	pop    %ebx
  8017a8:	5e                   	pop    %esi
  8017a9:	5f                   	pop    %edi
  8017aa:	c9                   	leave  
  8017ab:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  8017ac:	83 f8 01             	cmp    $0x1,%eax
  8017af:	75 bd                	jne    80176e <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8017b1:	8b 42 58             	mov    0x58(%edx),%eax
  8017b4:	6a 01                	push   $0x1
  8017b6:	50                   	push   %eax
  8017b7:	53                   	push   %ebx
  8017b8:	68 16 24 80 00       	push   $0x802416
  8017bd:	e8 c2 ea ff ff       	call   800284 <cprintf>
  8017c2:	83 c4 10             	add    $0x10,%esp
  8017c5:	eb a7                	jmp    80176e <_pipeisclosed+0xe>

008017c7 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8017c7:	55                   	push   %ebp
  8017c8:	89 e5                	mov    %esp,%ebp
  8017ca:	57                   	push   %edi
  8017cb:	56                   	push   %esi
  8017cc:	53                   	push   %ebx
  8017cd:	83 ec 28             	sub    $0x28,%esp
  8017d0:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  8017d3:	56                   	push   %esi
  8017d4:	e8 5b f6 ff ff       	call   800e34 <fd2data>
  8017d9:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8017db:	83 c4 10             	add    $0x10,%esp
  8017de:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8017e2:	75 4a                	jne    80182e <devpipe_write+0x67>
  8017e4:	bf 00 00 00 00       	mov    $0x0,%edi
  8017e9:	eb 56                	jmp    801841 <devpipe_write+0x7a>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  8017eb:	89 da                	mov    %ebx,%edx
  8017ed:	89 f0                	mov    %esi,%eax
  8017ef:	e8 6c ff ff ff       	call   801760 <_pipeisclosed>
  8017f4:	85 c0                	test   %eax,%eax
  8017f6:	75 4d                	jne    801845 <devpipe_write+0x7e>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  8017f8:	e8 98 f4 ff ff       	call   800c95 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8017fd:	8b 43 04             	mov    0x4(%ebx),%eax
  801800:	8b 13                	mov    (%ebx),%edx
  801802:	83 c2 20             	add    $0x20,%edx
  801805:	39 d0                	cmp    %edx,%eax
  801807:	73 e2                	jae    8017eb <devpipe_write+0x24>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801809:	89 c2                	mov    %eax,%edx
  80180b:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  801811:	79 05                	jns    801818 <devpipe_write+0x51>
  801813:	4a                   	dec    %edx
  801814:	83 ca e0             	or     $0xffffffe0,%edx
  801817:	42                   	inc    %edx
  801818:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80181b:	8a 0c 39             	mov    (%ecx,%edi,1),%cl
  80181e:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801822:	40                   	inc    %eax
  801823:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801826:	47                   	inc    %edi
  801827:	39 7d 10             	cmp    %edi,0x10(%ebp)
  80182a:	77 07                	ja     801833 <devpipe_write+0x6c>
  80182c:	eb 13                	jmp    801841 <devpipe_write+0x7a>
  80182e:	bf 00 00 00 00       	mov    $0x0,%edi
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801833:	8b 43 04             	mov    0x4(%ebx),%eax
  801836:	8b 13                	mov    (%ebx),%edx
  801838:	83 c2 20             	add    $0x20,%edx
  80183b:	39 d0                	cmp    %edx,%eax
  80183d:	73 ac                	jae    8017eb <devpipe_write+0x24>
  80183f:	eb c8                	jmp    801809 <devpipe_write+0x42>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801841:	89 f8                	mov    %edi,%eax
  801843:	eb 05                	jmp    80184a <devpipe_write+0x83>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801845:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  80184a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80184d:	5b                   	pop    %ebx
  80184e:	5e                   	pop    %esi
  80184f:	5f                   	pop    %edi
  801850:	c9                   	leave  
  801851:	c3                   	ret    

00801852 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801852:	55                   	push   %ebp
  801853:	89 e5                	mov    %esp,%ebp
  801855:	57                   	push   %edi
  801856:	56                   	push   %esi
  801857:	53                   	push   %ebx
  801858:	83 ec 18             	sub    $0x18,%esp
  80185b:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  80185e:	57                   	push   %edi
  80185f:	e8 d0 f5 ff ff       	call   800e34 <fd2data>
  801864:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801866:	83 c4 10             	add    $0x10,%esp
  801869:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80186d:	75 44                	jne    8018b3 <devpipe_read+0x61>
  80186f:	be 00 00 00 00       	mov    $0x0,%esi
  801874:	eb 4f                	jmp    8018c5 <devpipe_read+0x73>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
				return i;
  801876:	89 f0                	mov    %esi,%eax
  801878:	eb 54                	jmp    8018ce <devpipe_read+0x7c>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  80187a:	89 da                	mov    %ebx,%edx
  80187c:	89 f8                	mov    %edi,%eax
  80187e:	e8 dd fe ff ff       	call   801760 <_pipeisclosed>
  801883:	85 c0                	test   %eax,%eax
  801885:	75 42                	jne    8018c9 <devpipe_read+0x77>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801887:	e8 09 f4 ff ff       	call   800c95 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  80188c:	8b 03                	mov    (%ebx),%eax
  80188e:	3b 43 04             	cmp    0x4(%ebx),%eax
  801891:	74 e7                	je     80187a <devpipe_read+0x28>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801893:	25 1f 00 00 80       	and    $0x8000001f,%eax
  801898:	79 05                	jns    80189f <devpipe_read+0x4d>
  80189a:	48                   	dec    %eax
  80189b:	83 c8 e0             	or     $0xffffffe0,%eax
  80189e:	40                   	inc    %eax
  80189f:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  8018a3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8018a6:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  8018a9:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8018ab:	46                   	inc    %esi
  8018ac:	39 75 10             	cmp    %esi,0x10(%ebp)
  8018af:	77 07                	ja     8018b8 <devpipe_read+0x66>
  8018b1:	eb 12                	jmp    8018c5 <devpipe_read+0x73>
  8018b3:	be 00 00 00 00       	mov    $0x0,%esi
		while (p->p_rpos == p->p_wpos) {
  8018b8:	8b 03                	mov    (%ebx),%eax
  8018ba:	3b 43 04             	cmp    0x4(%ebx),%eax
  8018bd:	75 d4                	jne    801893 <devpipe_read+0x41>
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  8018bf:	85 f6                	test   %esi,%esi
  8018c1:	75 b3                	jne    801876 <devpipe_read+0x24>
  8018c3:	eb b5                	jmp    80187a <devpipe_read+0x28>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  8018c5:	89 f0                	mov    %esi,%eax
  8018c7:	eb 05                	jmp    8018ce <devpipe_read+0x7c>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8018c9:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  8018ce:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8018d1:	5b                   	pop    %ebx
  8018d2:	5e                   	pop    %esi
  8018d3:	5f                   	pop    %edi
  8018d4:	c9                   	leave  
  8018d5:	c3                   	ret    

008018d6 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  8018d6:	55                   	push   %ebp
  8018d7:	89 e5                	mov    %esp,%ebp
  8018d9:	57                   	push   %edi
  8018da:	56                   	push   %esi
  8018db:	53                   	push   %ebx
  8018dc:	83 ec 28             	sub    $0x28,%esp
  8018df:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  8018e2:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8018e5:	50                   	push   %eax
  8018e6:	e8 61 f5 ff ff       	call   800e4c <fd_alloc>
  8018eb:	89 c3                	mov    %eax,%ebx
  8018ed:	83 c4 10             	add    $0x10,%esp
  8018f0:	85 c0                	test   %eax,%eax
  8018f2:	0f 88 24 01 00 00    	js     801a1c <pipe+0x146>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8018f8:	83 ec 04             	sub    $0x4,%esp
  8018fb:	68 07 04 00 00       	push   $0x407
  801900:	ff 75 e4             	pushl  -0x1c(%ebp)
  801903:	6a 00                	push   $0x0
  801905:	e8 b2 f3 ff ff       	call   800cbc <sys_page_alloc>
  80190a:	89 c3                	mov    %eax,%ebx
  80190c:	83 c4 10             	add    $0x10,%esp
  80190f:	85 c0                	test   %eax,%eax
  801911:	0f 88 05 01 00 00    	js     801a1c <pipe+0x146>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801917:	83 ec 0c             	sub    $0xc,%esp
  80191a:	8d 45 e0             	lea    -0x20(%ebp),%eax
  80191d:	50                   	push   %eax
  80191e:	e8 29 f5 ff ff       	call   800e4c <fd_alloc>
  801923:	89 c3                	mov    %eax,%ebx
  801925:	83 c4 10             	add    $0x10,%esp
  801928:	85 c0                	test   %eax,%eax
  80192a:	0f 88 dc 00 00 00    	js     801a0c <pipe+0x136>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801930:	83 ec 04             	sub    $0x4,%esp
  801933:	68 07 04 00 00       	push   $0x407
  801938:	ff 75 e0             	pushl  -0x20(%ebp)
  80193b:	6a 00                	push   $0x0
  80193d:	e8 7a f3 ff ff       	call   800cbc <sys_page_alloc>
  801942:	89 c3                	mov    %eax,%ebx
  801944:	83 c4 10             	add    $0x10,%esp
  801947:	85 c0                	test   %eax,%eax
  801949:	0f 88 bd 00 00 00    	js     801a0c <pipe+0x136>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  80194f:	83 ec 0c             	sub    $0xc,%esp
  801952:	ff 75 e4             	pushl  -0x1c(%ebp)
  801955:	e8 da f4 ff ff       	call   800e34 <fd2data>
  80195a:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80195c:	83 c4 0c             	add    $0xc,%esp
  80195f:	68 07 04 00 00       	push   $0x407
  801964:	50                   	push   %eax
  801965:	6a 00                	push   $0x0
  801967:	e8 50 f3 ff ff       	call   800cbc <sys_page_alloc>
  80196c:	89 c3                	mov    %eax,%ebx
  80196e:	83 c4 10             	add    $0x10,%esp
  801971:	85 c0                	test   %eax,%eax
  801973:	0f 88 83 00 00 00    	js     8019fc <pipe+0x126>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801979:	83 ec 0c             	sub    $0xc,%esp
  80197c:	ff 75 e0             	pushl  -0x20(%ebp)
  80197f:	e8 b0 f4 ff ff       	call   800e34 <fd2data>
  801984:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  80198b:	50                   	push   %eax
  80198c:	6a 00                	push   $0x0
  80198e:	56                   	push   %esi
  80198f:	6a 00                	push   $0x0
  801991:	e8 4a f3 ff ff       	call   800ce0 <sys_page_map>
  801996:	89 c3                	mov    %eax,%ebx
  801998:	83 c4 20             	add    $0x20,%esp
  80199b:	85 c0                	test   %eax,%eax
  80199d:	78 4f                	js     8019ee <pipe+0x118>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  80199f:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8019a5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8019a8:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8019aa:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8019ad:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8019b4:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8019ba:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8019bd:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8019bf:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8019c2:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  8019c9:	83 ec 0c             	sub    $0xc,%esp
  8019cc:	ff 75 e4             	pushl  -0x1c(%ebp)
  8019cf:	e8 50 f4 ff ff       	call   800e24 <fd2num>
  8019d4:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  8019d6:	83 c4 04             	add    $0x4,%esp
  8019d9:	ff 75 e0             	pushl  -0x20(%ebp)
  8019dc:	e8 43 f4 ff ff       	call   800e24 <fd2num>
  8019e1:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  8019e4:	83 c4 10             	add    $0x10,%esp
  8019e7:	bb 00 00 00 00       	mov    $0x0,%ebx
  8019ec:	eb 2e                	jmp    801a1c <pipe+0x146>

    err3:
	sys_page_unmap(0, va);
  8019ee:	83 ec 08             	sub    $0x8,%esp
  8019f1:	56                   	push   %esi
  8019f2:	6a 00                	push   $0x0
  8019f4:	e8 0d f3 ff ff       	call   800d06 <sys_page_unmap>
  8019f9:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  8019fc:	83 ec 08             	sub    $0x8,%esp
  8019ff:	ff 75 e0             	pushl  -0x20(%ebp)
  801a02:	6a 00                	push   $0x0
  801a04:	e8 fd f2 ff ff       	call   800d06 <sys_page_unmap>
  801a09:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801a0c:	83 ec 08             	sub    $0x8,%esp
  801a0f:	ff 75 e4             	pushl  -0x1c(%ebp)
  801a12:	6a 00                	push   $0x0
  801a14:	e8 ed f2 ff ff       	call   800d06 <sys_page_unmap>
  801a19:	83 c4 10             	add    $0x10,%esp
    err:
	return r;
}
  801a1c:	89 d8                	mov    %ebx,%eax
  801a1e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a21:	5b                   	pop    %ebx
  801a22:	5e                   	pop    %esi
  801a23:	5f                   	pop    %edi
  801a24:	c9                   	leave  
  801a25:	c3                   	ret    

00801a26 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801a26:	55                   	push   %ebp
  801a27:	89 e5                	mov    %esp,%ebp
  801a29:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801a2c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a2f:	50                   	push   %eax
  801a30:	ff 75 08             	pushl  0x8(%ebp)
  801a33:	e8 87 f4 ff ff       	call   800ebf <fd_lookup>
  801a38:	83 c4 10             	add    $0x10,%esp
  801a3b:	85 c0                	test   %eax,%eax
  801a3d:	78 18                	js     801a57 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801a3f:	83 ec 0c             	sub    $0xc,%esp
  801a42:	ff 75 f4             	pushl  -0xc(%ebp)
  801a45:	e8 ea f3 ff ff       	call   800e34 <fd2data>
	return _pipeisclosed(fd, p);
  801a4a:	89 c2                	mov    %eax,%edx
  801a4c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a4f:	e8 0c fd ff ff       	call   801760 <_pipeisclosed>
  801a54:	83 c4 10             	add    $0x10,%esp
}
  801a57:	c9                   	leave  
  801a58:	c3                   	ret    
  801a59:	00 00                	add    %al,(%eax)
	...

00801a5c <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801a5c:	55                   	push   %ebp
  801a5d:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801a5f:	b8 00 00 00 00       	mov    $0x0,%eax
  801a64:	c9                   	leave  
  801a65:	c3                   	ret    

00801a66 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801a66:	55                   	push   %ebp
  801a67:	89 e5                	mov    %esp,%ebp
  801a69:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801a6c:	68 2e 24 80 00       	push   $0x80242e
  801a71:	ff 75 0c             	pushl  0xc(%ebp)
  801a74:	e8 c1 ed ff ff       	call   80083a <strcpy>
	return 0;
}
  801a79:	b8 00 00 00 00       	mov    $0x0,%eax
  801a7e:	c9                   	leave  
  801a7f:	c3                   	ret    

00801a80 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801a80:	55                   	push   %ebp
  801a81:	89 e5                	mov    %esp,%ebp
  801a83:	57                   	push   %edi
  801a84:	56                   	push   %esi
  801a85:	53                   	push   %ebx
  801a86:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801a8c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801a90:	74 45                	je     801ad7 <devcons_write+0x57>
  801a92:	b8 00 00 00 00       	mov    $0x0,%eax
  801a97:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801a9c:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801aa2:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801aa5:	29 c3                	sub    %eax,%ebx
		if (m > sizeof(buf) - 1)
  801aa7:	83 fb 7f             	cmp    $0x7f,%ebx
  801aaa:	76 05                	jbe    801ab1 <devcons_write+0x31>
			m = sizeof(buf) - 1;
  801aac:	bb 7f 00 00 00       	mov    $0x7f,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  801ab1:	83 ec 04             	sub    $0x4,%esp
  801ab4:	53                   	push   %ebx
  801ab5:	03 45 0c             	add    0xc(%ebp),%eax
  801ab8:	50                   	push   %eax
  801ab9:	57                   	push   %edi
  801aba:	e8 3c ef ff ff       	call   8009fb <memmove>
		sys_cputs(buf, m);
  801abf:	83 c4 08             	add    $0x8,%esp
  801ac2:	53                   	push   %ebx
  801ac3:	57                   	push   %edi
  801ac4:	e8 3c f1 ff ff       	call   800c05 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801ac9:	01 de                	add    %ebx,%esi
  801acb:	89 f0                	mov    %esi,%eax
  801acd:	83 c4 10             	add    $0x10,%esp
  801ad0:	3b 75 10             	cmp    0x10(%ebp),%esi
  801ad3:	72 cd                	jb     801aa2 <devcons_write+0x22>
  801ad5:	eb 05                	jmp    801adc <devcons_write+0x5c>
  801ad7:	be 00 00 00 00       	mov    $0x0,%esi
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801adc:	89 f0                	mov    %esi,%eax
  801ade:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ae1:	5b                   	pop    %ebx
  801ae2:	5e                   	pop    %esi
  801ae3:	5f                   	pop    %edi
  801ae4:	c9                   	leave  
  801ae5:	c3                   	ret    

00801ae6 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801ae6:	55                   	push   %ebp
  801ae7:	89 e5                	mov    %esp,%ebp
  801ae9:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  801aec:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801af0:	75 07                	jne    801af9 <devcons_read+0x13>
  801af2:	eb 25                	jmp    801b19 <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801af4:	e8 9c f1 ff ff       	call   800c95 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801af9:	e8 2d f1 ff ff       	call   800c2b <sys_cgetc>
  801afe:	85 c0                	test   %eax,%eax
  801b00:	74 f2                	je     801af4 <devcons_read+0xe>
  801b02:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  801b04:	85 c0                	test   %eax,%eax
  801b06:	78 1d                	js     801b25 <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801b08:	83 f8 04             	cmp    $0x4,%eax
  801b0b:	74 13                	je     801b20 <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  801b0d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b10:	88 10                	mov    %dl,(%eax)
	return 1;
  801b12:	b8 01 00 00 00       	mov    $0x1,%eax
  801b17:	eb 0c                	jmp    801b25 <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  801b19:	b8 00 00 00 00       	mov    $0x0,%eax
  801b1e:	eb 05                	jmp    801b25 <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801b20:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801b25:	c9                   	leave  
  801b26:	c3                   	ret    

00801b27 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801b27:	55                   	push   %ebp
  801b28:	89 e5                	mov    %esp,%ebp
  801b2a:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801b2d:	8b 45 08             	mov    0x8(%ebp),%eax
  801b30:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801b33:	6a 01                	push   $0x1
  801b35:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801b38:	50                   	push   %eax
  801b39:	e8 c7 f0 ff ff       	call   800c05 <sys_cputs>
  801b3e:	83 c4 10             	add    $0x10,%esp
}
  801b41:	c9                   	leave  
  801b42:	c3                   	ret    

00801b43 <getchar>:

int
getchar(void)
{
  801b43:	55                   	push   %ebp
  801b44:	89 e5                	mov    %esp,%ebp
  801b46:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801b49:	6a 01                	push   $0x1
  801b4b:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801b4e:	50                   	push   %eax
  801b4f:	6a 00                	push   $0x0
  801b51:	e8 ea f5 ff ff       	call   801140 <read>
	if (r < 0)
  801b56:	83 c4 10             	add    $0x10,%esp
  801b59:	85 c0                	test   %eax,%eax
  801b5b:	78 0f                	js     801b6c <getchar+0x29>
		return r;
	if (r < 1)
  801b5d:	85 c0                	test   %eax,%eax
  801b5f:	7e 06                	jle    801b67 <getchar+0x24>
		return -E_EOF;
	return c;
  801b61:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801b65:	eb 05                	jmp    801b6c <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801b67:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801b6c:	c9                   	leave  
  801b6d:	c3                   	ret    

00801b6e <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801b6e:	55                   	push   %ebp
  801b6f:	89 e5                	mov    %esp,%ebp
  801b71:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801b74:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b77:	50                   	push   %eax
  801b78:	ff 75 08             	pushl  0x8(%ebp)
  801b7b:	e8 3f f3 ff ff       	call   800ebf <fd_lookup>
  801b80:	83 c4 10             	add    $0x10,%esp
  801b83:	85 c0                	test   %eax,%eax
  801b85:	78 11                	js     801b98 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801b87:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b8a:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801b90:	39 10                	cmp    %edx,(%eax)
  801b92:	0f 94 c0             	sete   %al
  801b95:	0f b6 c0             	movzbl %al,%eax
}
  801b98:	c9                   	leave  
  801b99:	c3                   	ret    

00801b9a <opencons>:

int
opencons(void)
{
  801b9a:	55                   	push   %ebp
  801b9b:	89 e5                	mov    %esp,%ebp
  801b9d:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801ba0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ba3:	50                   	push   %eax
  801ba4:	e8 a3 f2 ff ff       	call   800e4c <fd_alloc>
  801ba9:	83 c4 10             	add    $0x10,%esp
  801bac:	85 c0                	test   %eax,%eax
  801bae:	78 3a                	js     801bea <opencons+0x50>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801bb0:	83 ec 04             	sub    $0x4,%esp
  801bb3:	68 07 04 00 00       	push   $0x407
  801bb8:	ff 75 f4             	pushl  -0xc(%ebp)
  801bbb:	6a 00                	push   $0x0
  801bbd:	e8 fa f0 ff ff       	call   800cbc <sys_page_alloc>
  801bc2:	83 c4 10             	add    $0x10,%esp
  801bc5:	85 c0                	test   %eax,%eax
  801bc7:	78 21                	js     801bea <opencons+0x50>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801bc9:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801bcf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801bd2:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801bd4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801bd7:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801bde:	83 ec 0c             	sub    $0xc,%esp
  801be1:	50                   	push   %eax
  801be2:	e8 3d f2 ff ff       	call   800e24 <fd2num>
  801be7:	83 c4 10             	add    $0x10,%esp
}
  801bea:	c9                   	leave  
  801beb:	c3                   	ret    

00801bec <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801bec:	55                   	push   %ebp
  801bed:	89 e5                	mov    %esp,%ebp
  801bef:	56                   	push   %esi
  801bf0:	53                   	push   %ebx
  801bf1:	8b 75 08             	mov    0x8(%ebp),%esi
  801bf4:	8b 45 0c             	mov    0xc(%ebp),%eax
  801bf7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// cprintf("0x%x 0x%x 0x%x\n", (uint32_t)from_env_store, (uint32_t)pg, (uint32_t)perm_store);
	int r;
	if (pg != NULL) {
  801bfa:	85 c0                	test   %eax,%eax
  801bfc:	74 0e                	je     801c0c <ipc_recv+0x20>
		r = sys_ipc_recv(pg);
  801bfe:	83 ec 0c             	sub    $0xc,%esp
  801c01:	50                   	push   %eax
  801c02:	e8 b0 f1 ff ff       	call   800db7 <sys_ipc_recv>
  801c07:	83 c4 10             	add    $0x10,%esp
  801c0a:	eb 10                	jmp    801c1c <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv((void *)UTOP);
  801c0c:	83 ec 0c             	sub    $0xc,%esp
  801c0f:	68 00 00 c0 ee       	push   $0xeec00000
  801c14:	e8 9e f1 ff ff       	call   800db7 <sys_ipc_recv>
  801c19:	83 c4 10             	add    $0x10,%esp
	}

	if (r == 0) {
  801c1c:	85 c0                	test   %eax,%eax
  801c1e:	75 26                	jne    801c46 <ipc_recv+0x5a>
		if (from_env_store != NULL) *from_env_store = thisenv->env_ipc_from;
  801c20:	85 f6                	test   %esi,%esi
  801c22:	74 0a                	je     801c2e <ipc_recv+0x42>
  801c24:	a1 20 60 80 00       	mov    0x806020,%eax
  801c29:	8b 40 74             	mov    0x74(%eax),%eax
  801c2c:	89 06                	mov    %eax,(%esi)
		if (perm_store != NULL) *perm_store = thisenv->env_ipc_perm;
  801c2e:	85 db                	test   %ebx,%ebx
  801c30:	74 0a                	je     801c3c <ipc_recv+0x50>
  801c32:	a1 20 60 80 00       	mov    0x806020,%eax
  801c37:	8b 40 78             	mov    0x78(%eax),%eax
  801c3a:	89 03                	mov    %eax,(%ebx)
		return thisenv->env_ipc_value;
  801c3c:	a1 20 60 80 00       	mov    0x806020,%eax
  801c41:	8b 40 70             	mov    0x70(%eax),%eax
  801c44:	eb 14                	jmp    801c5a <ipc_recv+0x6e>
	} else {
		// fails;
		if (from_env_store != NULL) *from_env_store = 0;
  801c46:	85 f6                	test   %esi,%esi
  801c48:	74 06                	je     801c50 <ipc_recv+0x64>
  801c4a:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if (perm_store != NULL) *perm_store = 0;
  801c50:	85 db                	test   %ebx,%ebx
  801c52:	74 06                	je     801c5a <ipc_recv+0x6e>
  801c54:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		return r;
	}
}
  801c5a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c5d:	5b                   	pop    %ebx
  801c5e:	5e                   	pop    %esi
  801c5f:	c9                   	leave  
  801c60:	c3                   	ret    

00801c61 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801c61:	55                   	push   %ebp
  801c62:	89 e5                	mov    %esp,%ebp
  801c64:	57                   	push   %edi
  801c65:	56                   	push   %esi
  801c66:	53                   	push   %ebx
  801c67:	83 ec 0c             	sub    $0xc,%esp
  801c6a:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801c6d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801c70:	8b 75 14             	mov    0x14(%ebp),%esi
	// LAB 4: Your code here.
	// int sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
	int r;
	if (pg == NULL) pg = (void *)UTOP;
  801c73:	85 db                	test   %ebx,%ebx
  801c75:	75 25                	jne    801c9c <ipc_send+0x3b>
  801c77:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
  801c7c:	eb 1e                	jmp    801c9c <ipc_send+0x3b>
	
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) != 0) {
		if (r == -E_IPC_NOT_RECV) {
  801c7e:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801c81:	75 07                	jne    801c8a <ipc_send+0x29>
			// cprintf("Try Again and Again....\n");
			sys_yield();
  801c83:	e8 0d f0 ff ff       	call   800c95 <sys_yield>
  801c88:	eb 12                	jmp    801c9c <ipc_send+0x3b>
		} else {
			panic("ipc_send error %e\n", r);
  801c8a:	50                   	push   %eax
  801c8b:	68 3a 24 80 00       	push   $0x80243a
  801c90:	6a 43                	push   $0x43
  801c92:	68 4d 24 80 00       	push   $0x80244d
  801c97:	e8 10 e5 ff ff       	call   8001ac <_panic>
	// LAB 4: Your code here.
	// int sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
	int r;
	if (pg == NULL) pg = (void *)UTOP;
	
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) != 0) {
  801c9c:	56                   	push   %esi
  801c9d:	53                   	push   %ebx
  801c9e:	57                   	push   %edi
  801c9f:	ff 75 08             	pushl  0x8(%ebp)
  801ca2:	e8 eb f0 ff ff       	call   800d92 <sys_ipc_try_send>
  801ca7:	83 c4 10             	add    $0x10,%esp
  801caa:	85 c0                	test   %eax,%eax
  801cac:	75 d0                	jne    801c7e <ipc_send+0x1d>
		} else {
			panic("ipc_send error %e\n", r);
		}
	}
	return;
}
  801cae:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801cb1:	5b                   	pop    %ebx
  801cb2:	5e                   	pop    %esi
  801cb3:	5f                   	pop    %edi
  801cb4:	c9                   	leave  
  801cb5:	c3                   	ret    

00801cb6 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801cb6:	55                   	push   %ebp
  801cb7:	89 e5                	mov    %esp,%ebp
  801cb9:	53                   	push   %ebx
  801cba:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  801cbd:	39 1d 50 00 c0 ee    	cmp    %ebx,0xeec00050
  801cc3:	74 22                	je     801ce7 <ipc_find_env+0x31>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801cc5:	b8 01 00 00 00       	mov    $0x1,%eax
		if (envs[i].env_type == type)
  801cca:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  801cd1:	89 c2                	mov    %eax,%edx
  801cd3:	c1 e2 07             	shl    $0x7,%edx
  801cd6:	29 ca                	sub    %ecx,%edx
  801cd8:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801cde:	8b 52 50             	mov    0x50(%edx),%edx
  801ce1:	39 da                	cmp    %ebx,%edx
  801ce3:	75 1d                	jne    801d02 <ipc_find_env+0x4c>
  801ce5:	eb 05                	jmp    801cec <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801ce7:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
			return envs[i].env_id;
  801cec:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  801cf3:	c1 e0 07             	shl    $0x7,%eax
  801cf6:	29 d0                	sub    %edx,%eax
  801cf8:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  801cfd:	8b 40 40             	mov    0x40(%eax),%eax
  801d00:	eb 0c                	jmp    801d0e <ipc_find_env+0x58>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801d02:	40                   	inc    %eax
  801d03:	3d 00 04 00 00       	cmp    $0x400,%eax
  801d08:	75 c0                	jne    801cca <ipc_find_env+0x14>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801d0a:	66 b8 00 00          	mov    $0x0,%ax
}
  801d0e:	5b                   	pop    %ebx
  801d0f:	c9                   	leave  
  801d10:	c3                   	ret    
  801d11:	00 00                	add    %al,(%eax)
	...

00801d14 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801d14:	55                   	push   %ebp
  801d15:	89 e5                	mov    %esp,%ebp
  801d17:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801d1a:	89 c2                	mov    %eax,%edx
  801d1c:	c1 ea 16             	shr    $0x16,%edx
  801d1f:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801d26:	f6 c2 01             	test   $0x1,%dl
  801d29:	74 1e                	je     801d49 <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  801d2b:	c1 e8 0c             	shr    $0xc,%eax
  801d2e:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801d35:	a8 01                	test   $0x1,%al
  801d37:	74 17                	je     801d50 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801d39:	c1 e8 0c             	shr    $0xc,%eax
  801d3c:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  801d43:	ef 
  801d44:	0f b7 c0             	movzwl %ax,%eax
  801d47:	eb 0c                	jmp    801d55 <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  801d49:	b8 00 00 00 00       	mov    $0x0,%eax
  801d4e:	eb 05                	jmp    801d55 <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  801d50:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  801d55:	c9                   	leave  
  801d56:	c3                   	ret    
	...

00801d58 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  801d58:	55                   	push   %ebp
  801d59:	89 e5                	mov    %esp,%ebp
  801d5b:	57                   	push   %edi
  801d5c:	56                   	push   %esi
  801d5d:	83 ec 10             	sub    $0x10,%esp
  801d60:	8b 7d 08             	mov    0x8(%ebp),%edi
  801d63:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  801d66:	89 7d f0             	mov    %edi,-0x10(%ebp)
  801d69:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  801d6c:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  801d6f:	8b 45 14             	mov    0x14(%ebp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  801d72:	85 c0                	test   %eax,%eax
  801d74:	75 2e                	jne    801da4 <__udivdi3+0x4c>
    {
      if (d0 > n1)
  801d76:	39 f1                	cmp    %esi,%ecx
  801d78:	77 5a                	ja     801dd4 <__udivdi3+0x7c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  801d7a:	85 c9                	test   %ecx,%ecx
  801d7c:	75 0b                	jne    801d89 <__udivdi3+0x31>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  801d7e:	b8 01 00 00 00       	mov    $0x1,%eax
  801d83:	31 d2                	xor    %edx,%edx
  801d85:	f7 f1                	div    %ecx
  801d87:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  801d89:	31 d2                	xor    %edx,%edx
  801d8b:	89 f0                	mov    %esi,%eax
  801d8d:	f7 f1                	div    %ecx
  801d8f:	89 c6                	mov    %eax,%esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801d91:	89 f8                	mov    %edi,%eax
  801d93:	f7 f1                	div    %ecx
  801d95:	89 c7                	mov    %eax,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801d97:	89 f8                	mov    %edi,%eax
  801d99:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801d9b:	83 c4 10             	add    $0x10,%esp
  801d9e:	5e                   	pop    %esi
  801d9f:	5f                   	pop    %edi
  801da0:	c9                   	leave  
  801da1:	c3                   	ret    
  801da2:	66 90                	xchg   %ax,%ax
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801da4:	39 f0                	cmp    %esi,%eax
  801da6:	77 1c                	ja     801dc4 <__udivdi3+0x6c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  801da8:	0f bd f8             	bsr    %eax,%edi
	  if (bm == 0)
  801dab:	83 f7 1f             	xor    $0x1f,%edi
  801dae:	75 3c                	jne    801dec <__udivdi3+0x94>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801db0:	39 f0                	cmp    %esi,%eax
  801db2:	0f 82 90 00 00 00    	jb     801e48 <__udivdi3+0xf0>
  801db8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801dbb:	39 55 f4             	cmp    %edx,-0xc(%ebp)
  801dbe:	0f 86 84 00 00 00    	jbe    801e48 <__udivdi3+0xf0>
  801dc4:	31 f6                	xor    %esi,%esi
  801dc6:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801dc8:	89 f8                	mov    %edi,%eax
  801dca:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801dcc:	83 c4 10             	add    $0x10,%esp
  801dcf:	5e                   	pop    %esi
  801dd0:	5f                   	pop    %edi
  801dd1:	c9                   	leave  
  801dd2:	c3                   	ret    
  801dd3:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801dd4:	89 f2                	mov    %esi,%edx
  801dd6:	89 f8                	mov    %edi,%eax
  801dd8:	f7 f1                	div    %ecx
  801dda:	89 c7                	mov    %eax,%edi
  801ddc:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801dde:	89 f8                	mov    %edi,%eax
  801de0:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801de2:	83 c4 10             	add    $0x10,%esp
  801de5:	5e                   	pop    %esi
  801de6:	5f                   	pop    %edi
  801de7:	c9                   	leave  
  801de8:	c3                   	ret    
  801de9:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  801dec:	89 f9                	mov    %edi,%ecx
  801dee:	d3 e0                	shl    %cl,%eax
  801df0:	89 45 e8             	mov    %eax,-0x18(%ebp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  801df3:	b8 20 00 00 00       	mov    $0x20,%eax
  801df8:	29 f8                	sub    %edi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  801dfa:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801dfd:	88 c1                	mov    %al,%cl
  801dff:	d3 ea                	shr    %cl,%edx
  801e01:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  801e04:	09 ca                	or     %ecx,%edx
  801e06:	89 55 ec             	mov    %edx,-0x14(%ebp)
	      d0 = d0 << bm;
  801e09:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801e0c:	89 f9                	mov    %edi,%ecx
  801e0e:	d3 e2                	shl    %cl,%edx
  801e10:	89 55 f4             	mov    %edx,-0xc(%ebp)
	      n2 = n1 >> b;
  801e13:	89 f2                	mov    %esi,%edx
  801e15:	88 c1                	mov    %al,%cl
  801e17:	d3 ea                	shr    %cl,%edx
  801e19:	89 55 e8             	mov    %edx,-0x18(%ebp)
	      n1 = (n1 << bm) | (n0 >> b);
  801e1c:	89 f2                	mov    %esi,%edx
  801e1e:	89 f9                	mov    %edi,%ecx
  801e20:	d3 e2                	shl    %cl,%edx
  801e22:	8b 75 f0             	mov    -0x10(%ebp),%esi
  801e25:	88 c1                	mov    %al,%cl
  801e27:	d3 ee                	shr    %cl,%esi
  801e29:	09 d6                	or     %edx,%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  801e2b:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  801e2e:	89 f0                	mov    %esi,%eax
  801e30:	89 ca                	mov    %ecx,%edx
  801e32:	f7 75 ec             	divl   -0x14(%ebp)
  801e35:	89 d1                	mov    %edx,%ecx
  801e37:	89 c6                	mov    %eax,%esi
	      umul_ppmm (m1, m0, q0, d0);
  801e39:	f7 65 f4             	mull   -0xc(%ebp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801e3c:	39 d1                	cmp    %edx,%ecx
  801e3e:	72 28                	jb     801e68 <__udivdi3+0x110>
  801e40:	74 1a                	je     801e5c <__udivdi3+0x104>
  801e42:	89 f7                	mov    %esi,%edi
  801e44:	31 f6                	xor    %esi,%esi
  801e46:	eb 80                	jmp    801dc8 <__udivdi3+0x70>
	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  801e48:	31 f6                	xor    %esi,%esi
  801e4a:	bf 01 00 00 00       	mov    $0x1,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801e4f:	89 f8                	mov    %edi,%eax
  801e51:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801e53:	83 c4 10             	add    $0x10,%esp
  801e56:	5e                   	pop    %esi
  801e57:	5f                   	pop    %edi
  801e58:	c9                   	leave  
  801e59:	c3                   	ret    
  801e5a:	66 90                	xchg   %ax,%ax

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  801e5c:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801e5f:	89 f9                	mov    %edi,%ecx
  801e61:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801e63:	39 c2                	cmp    %eax,%edx
  801e65:	73 db                	jae    801e42 <__udivdi3+0xea>
  801e67:	90                   	nop
		{
		  q0--;
  801e68:	8d 7e ff             	lea    -0x1(%esi),%edi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  801e6b:	31 f6                	xor    %esi,%esi
  801e6d:	e9 56 ff ff ff       	jmp    801dc8 <__udivdi3+0x70>
	...

00801e74 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  801e74:	55                   	push   %ebp
  801e75:	89 e5                	mov    %esp,%ebp
  801e77:	57                   	push   %edi
  801e78:	56                   	push   %esi
  801e79:	83 ec 20             	sub    $0x20,%esp
  801e7c:	8b 45 08             	mov    0x8(%ebp),%eax
  801e7f:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  801e82:	89 45 e8             	mov    %eax,-0x18(%ebp)
  801e85:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  801e88:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  801e8b:	8b 7d 14             	mov    0x14(%ebp),%edi
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  801e8e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  n1 = nn.s.high;
  801e91:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  801e93:	85 ff                	test   %edi,%edi
  801e95:	75 15                	jne    801eac <__umoddi3+0x38>
    {
      if (d0 > n1)
  801e97:	39 f1                	cmp    %esi,%ecx
  801e99:	0f 86 99 00 00 00    	jbe    801f38 <__umoddi3+0xc4>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801e9f:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  801ea1:	89 d0                	mov    %edx,%eax
  801ea3:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801ea5:	83 c4 20             	add    $0x20,%esp
  801ea8:	5e                   	pop    %esi
  801ea9:	5f                   	pop    %edi
  801eaa:	c9                   	leave  
  801eab:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801eac:	39 f7                	cmp    %esi,%edi
  801eae:	0f 87 a4 00 00 00    	ja     801f58 <__umoddi3+0xe4>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  801eb4:	0f bd c7             	bsr    %edi,%eax
	  if (bm == 0)
  801eb7:	83 f0 1f             	xor    $0x1f,%eax
  801eba:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801ebd:	0f 84 a1 00 00 00    	je     801f64 <__umoddi3+0xf0>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  801ec3:	89 f8                	mov    %edi,%eax
  801ec5:	8a 4d ec             	mov    -0x14(%ebp),%cl
  801ec8:	d3 e0                	shl    %cl,%eax
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  801eca:	bf 20 00 00 00       	mov    $0x20,%edi
  801ecf:	2b 7d ec             	sub    -0x14(%ebp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  801ed2:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801ed5:	89 f9                	mov    %edi,%ecx
  801ed7:	d3 ea                	shr    %cl,%edx
  801ed9:	09 c2                	or     %eax,%edx
  801edb:	89 55 f0             	mov    %edx,-0x10(%ebp)
	      d0 = d0 << bm;
  801ede:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ee1:	8a 4d ec             	mov    -0x14(%ebp),%cl
  801ee4:	d3 e0                	shl    %cl,%eax
  801ee6:	89 45 f4             	mov    %eax,-0xc(%ebp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  801ee9:	89 f2                	mov    %esi,%edx
  801eeb:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  801eed:	8b 45 e8             	mov    -0x18(%ebp),%eax
  801ef0:	d3 e0                	shl    %cl,%eax
  801ef2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  801ef5:	8b 45 e8             	mov    -0x18(%ebp),%eax
  801ef8:	89 f9                	mov    %edi,%ecx
  801efa:	d3 e8                	shr    %cl,%eax
  801efc:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  801efe:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  801f00:	89 f2                	mov    %esi,%edx
  801f02:	f7 75 f0             	divl   -0x10(%ebp)
  801f05:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  801f07:	f7 65 f4             	mull   -0xc(%ebp)
  801f0a:	89 55 e8             	mov    %edx,-0x18(%ebp)
  801f0d:	89 c1                	mov    %eax,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801f0f:	39 d6                	cmp    %edx,%esi
  801f11:	72 71                	jb     801f84 <__umoddi3+0x110>
  801f13:	74 7f                	je     801f94 <__umoddi3+0x120>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  801f15:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801f18:	29 c8                	sub    %ecx,%eax
  801f1a:	19 d6                	sbb    %edx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  801f1c:	8a 4d ec             	mov    -0x14(%ebp),%cl
  801f1f:	d3 e8                	shr    %cl,%eax
  801f21:	89 f2                	mov    %esi,%edx
  801f23:	89 f9                	mov    %edi,%ecx
  801f25:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  801f27:	09 d0                	or     %edx,%eax
  801f29:	89 f2                	mov    %esi,%edx
  801f2b:	8a 4d ec             	mov    -0x14(%ebp),%cl
  801f2e:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801f30:	83 c4 20             	add    $0x20,%esp
  801f33:	5e                   	pop    %esi
  801f34:	5f                   	pop    %edi
  801f35:	c9                   	leave  
  801f36:	c3                   	ret    
  801f37:	90                   	nop
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  801f38:	85 c9                	test   %ecx,%ecx
  801f3a:	75 0b                	jne    801f47 <__umoddi3+0xd3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  801f3c:	b8 01 00 00 00       	mov    $0x1,%eax
  801f41:	31 d2                	xor    %edx,%edx
  801f43:	f7 f1                	div    %ecx
  801f45:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  801f47:	89 f0                	mov    %esi,%eax
  801f49:	31 d2                	xor    %edx,%edx
  801f4b:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801f4d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801f50:	f7 f1                	div    %ecx
  801f52:	e9 4a ff ff ff       	jmp    801ea1 <__umoddi3+0x2d>
  801f57:	90                   	nop
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  801f58:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801f5a:	83 c4 20             	add    $0x20,%esp
  801f5d:	5e                   	pop    %esi
  801f5e:	5f                   	pop    %edi
  801f5f:	c9                   	leave  
  801f60:	c3                   	ret    
  801f61:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801f64:	39 f7                	cmp    %esi,%edi
  801f66:	72 05                	jb     801f6d <__umoddi3+0xf9>
  801f68:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
  801f6b:	77 0c                	ja     801f79 <__umoddi3+0x105>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  801f6d:	89 f2                	mov    %esi,%edx
  801f6f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801f72:	29 c8                	sub    %ecx,%eax
  801f74:	19 fa                	sbb    %edi,%edx
  801f76:	89 45 f0             	mov    %eax,-0x10(%ebp)

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  801f79:	8b 45 f0             	mov    -0x10(%ebp),%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801f7c:	83 c4 20             	add    $0x20,%esp
  801f7f:	5e                   	pop    %esi
  801f80:	5f                   	pop    %edi
  801f81:	c9                   	leave  
  801f82:	c3                   	ret    
  801f83:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  801f84:	8b 55 e8             	mov    -0x18(%ebp),%edx
  801f87:	89 c1                	mov    %eax,%ecx
  801f89:	2b 4d f4             	sub    -0xc(%ebp),%ecx
  801f8c:	1b 55 f0             	sbb    -0x10(%ebp),%edx
  801f8f:	eb 84                	jmp    801f15 <__umoddi3+0xa1>
  801f91:	8d 76 00             	lea    0x0(%esi),%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801f94:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801f97:	72 eb                	jb     801f84 <__umoddi3+0x110>
  801f99:	89 f2                	mov    %esi,%edx
  801f9b:	e9 75 ff ff ff       	jmp    801f15 <__umoddi3+0xa1>
