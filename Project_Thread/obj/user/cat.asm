
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
  800050:	e8 07 12 00 00       	call   80125c <write>
  800055:	83 c4 10             	add    $0x10,%esp
  800058:	39 d8                	cmp    %ebx,%eax
  80005a:	74 16                	je     800072 <cat+0x3e>
			panic("write error copying %s: %e", s, r);
  80005c:	83 ec 0c             	sub    $0xc,%esp
  80005f:	50                   	push   %eax
  800060:	57                   	push   %edi
  800061:	68 e0 1f 80 00       	push   $0x801fe0
  800066:	6a 0d                	push   $0xd
  800068:	68 fb 1f 80 00       	push   $0x801ffb
  80006d:	e8 36 01 00 00       	call   8001a8 <_panic>
cat(int f, char *s)
{
	long n;
	int r;

	while ((n = read(f, buf, (long)sizeof(buf))) > 0)
  800072:	83 ec 04             	sub    $0x4,%esp
  800075:	68 00 20 00 00       	push   $0x2000
  80007a:	68 20 40 80 00       	push   $0x804020
  80007f:	56                   	push   %esi
  800080:	e8 fb 10 00 00       	call   801180 <read>
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
  800097:	68 06 20 80 00       	push   $0x802006
  80009c:	6a 0f                	push   $0xf
  80009e:	68 fb 1f 80 00       	push   $0x801ffb
  8000a3:	e8 00 01 00 00       	call   8001a8 <_panic>
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
  8000bc:	c7 05 00 30 80 00 1b 	movl   $0x80201b,0x803000
  8000c3:	20 80 00 
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
  8000d7:	68 1f 20 80 00       	push   $0x80201f
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
  8000f5:	e8 8a 14 00 00       	call   801584 <open>
  8000fa:	89 c3                	mov    %eax,%ebx
			if (f < 0)
  8000fc:	83 c4 10             	add    $0x10,%esp
  8000ff:	85 c0                	test   %eax,%eax
  800101:	79 16                	jns    800119 <umain+0x69>
				printf("can't open %s: %e\n", argv[i], f);
  800103:	83 ec 04             	sub    $0x4,%esp
  800106:	50                   	push   %eax
  800107:	ff 34 b7             	pushl  (%edi,%esi,4)
  80010a:	68 27 20 80 00       	push   $0x802027
  80010f:	e8 fc 15 00 00       	call   801710 <printf>
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
  800128:	e8 16 0f 00 00       	call   801043 <close>
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
  80014b:	e8 1d 0b 00 00       	call   800c6d <sys_getenvid>
  800150:	25 ff 03 00 00       	and    $0x3ff,%eax
  800155:	89 c2                	mov    %eax,%edx
  800157:	c1 e2 07             	shl    $0x7,%edx
  80015a:	8d 84 82 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,4),%eax
  800161:	a3 20 60 80 00       	mov    %eax,0x806020

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800166:	85 f6                	test   %esi,%esi
  800168:	7e 07                	jle    800171 <libmain+0x31>
		binaryname = argv[0];
  80016a:	8b 03                	mov    (%ebx),%eax
  80016c:	a3 00 30 80 00       	mov    %eax,0x803000
	// call user main routine
	umain(argc, argv);
  800171:	83 ec 08             	sub    $0x8,%esp
  800174:	53                   	push   %ebx
  800175:	56                   	push   %esi
  800176:	e8 35 ff ff ff       	call   8000b0 <umain>

	// exit gracefully
	exit();
  80017b:	e8 0c 00 00 00       	call   80018c <exit>
  800180:	83 c4 10             	add    $0x10,%esp
}
  800183:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800186:	5b                   	pop    %ebx
  800187:	5e                   	pop    %esi
  800188:	c9                   	leave  
  800189:	c3                   	ret    
	...

0080018c <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80018c:	55                   	push   %ebp
  80018d:	89 e5                	mov    %esp,%ebp
  80018f:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800192:	e8 d7 0e 00 00       	call   80106e <close_all>
	sys_env_destroy(0);
  800197:	83 ec 0c             	sub    $0xc,%esp
  80019a:	6a 00                	push   $0x0
  80019c:	e8 aa 0a 00 00       	call   800c4b <sys_env_destroy>
  8001a1:	83 c4 10             	add    $0x10,%esp
}
  8001a4:	c9                   	leave  
  8001a5:	c3                   	ret    
	...

008001a8 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8001a8:	55                   	push   %ebp
  8001a9:	89 e5                	mov    %esp,%ebp
  8001ab:	56                   	push   %esi
  8001ac:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8001ad:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8001b0:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  8001b6:	e8 b2 0a 00 00       	call   800c6d <sys_getenvid>
  8001bb:	83 ec 0c             	sub    $0xc,%esp
  8001be:	ff 75 0c             	pushl  0xc(%ebp)
  8001c1:	ff 75 08             	pushl  0x8(%ebp)
  8001c4:	53                   	push   %ebx
  8001c5:	50                   	push   %eax
  8001c6:	68 44 20 80 00       	push   $0x802044
  8001cb:	e8 b0 00 00 00       	call   800280 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8001d0:	83 c4 18             	add    $0x18,%esp
  8001d3:	56                   	push   %esi
  8001d4:	ff 75 10             	pushl  0x10(%ebp)
  8001d7:	e8 53 00 00 00       	call   80022f <vcprintf>
	cprintf("\n");
  8001dc:	c7 04 24 67 24 80 00 	movl   $0x802467,(%esp)
  8001e3:	e8 98 00 00 00       	call   800280 <cprintf>
  8001e8:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8001eb:	cc                   	int3   
  8001ec:	eb fd                	jmp    8001eb <_panic+0x43>
	...

008001f0 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001f0:	55                   	push   %ebp
  8001f1:	89 e5                	mov    %esp,%ebp
  8001f3:	53                   	push   %ebx
  8001f4:	83 ec 04             	sub    $0x4,%esp
  8001f7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001fa:	8b 03                	mov    (%ebx),%eax
  8001fc:	8b 55 08             	mov    0x8(%ebp),%edx
  8001ff:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  800203:	40                   	inc    %eax
  800204:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  800206:	3d ff 00 00 00       	cmp    $0xff,%eax
  80020b:	75 1a                	jne    800227 <putch+0x37>
		sys_cputs(b->buf, b->idx);
  80020d:	83 ec 08             	sub    $0x8,%esp
  800210:	68 ff 00 00 00       	push   $0xff
  800215:	8d 43 08             	lea    0x8(%ebx),%eax
  800218:	50                   	push   %eax
  800219:	e8 e3 09 00 00       	call   800c01 <sys_cputs>
		b->idx = 0;
  80021e:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800224:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800227:	ff 43 04             	incl   0x4(%ebx)
}
  80022a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80022d:	c9                   	leave  
  80022e:	c3                   	ret    

0080022f <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80022f:	55                   	push   %ebp
  800230:	89 e5                	mov    %esp,%ebp
  800232:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800238:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80023f:	00 00 00 
	b.cnt = 0;
  800242:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800249:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80024c:	ff 75 0c             	pushl  0xc(%ebp)
  80024f:	ff 75 08             	pushl  0x8(%ebp)
  800252:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800258:	50                   	push   %eax
  800259:	68 f0 01 80 00       	push   $0x8001f0
  80025e:	e8 82 01 00 00       	call   8003e5 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800263:	83 c4 08             	add    $0x8,%esp
  800266:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80026c:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800272:	50                   	push   %eax
  800273:	e8 89 09 00 00       	call   800c01 <sys_cputs>

	return b.cnt;
}
  800278:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80027e:	c9                   	leave  
  80027f:	c3                   	ret    

00800280 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800280:	55                   	push   %ebp
  800281:	89 e5                	mov    %esp,%ebp
  800283:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800286:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800289:	50                   	push   %eax
  80028a:	ff 75 08             	pushl  0x8(%ebp)
  80028d:	e8 9d ff ff ff       	call   80022f <vcprintf>
	va_end(ap);

	return cnt;
}
  800292:	c9                   	leave  
  800293:	c3                   	ret    

00800294 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800294:	55                   	push   %ebp
  800295:	89 e5                	mov    %esp,%ebp
  800297:	57                   	push   %edi
  800298:	56                   	push   %esi
  800299:	53                   	push   %ebx
  80029a:	83 ec 2c             	sub    $0x2c,%esp
  80029d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8002a0:	89 d6                	mov    %edx,%esi
  8002a2:	8b 45 08             	mov    0x8(%ebp),%eax
  8002a5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002a8:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8002ab:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8002ae:	8b 45 10             	mov    0x10(%ebp),%eax
  8002b1:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8002b4:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8002b7:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8002ba:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  8002c1:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
  8002c4:	72 0c                	jb     8002d2 <printnum+0x3e>
  8002c6:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  8002c9:	76 07                	jbe    8002d2 <printnum+0x3e>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002cb:	4b                   	dec    %ebx
  8002cc:	85 db                	test   %ebx,%ebx
  8002ce:	7f 31                	jg     800301 <printnum+0x6d>
  8002d0:	eb 3f                	jmp    800311 <printnum+0x7d>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002d2:	83 ec 0c             	sub    $0xc,%esp
  8002d5:	57                   	push   %edi
  8002d6:	4b                   	dec    %ebx
  8002d7:	53                   	push   %ebx
  8002d8:	50                   	push   %eax
  8002d9:	83 ec 08             	sub    $0x8,%esp
  8002dc:	ff 75 d4             	pushl  -0x2c(%ebp)
  8002df:	ff 75 d0             	pushl  -0x30(%ebp)
  8002e2:	ff 75 dc             	pushl  -0x24(%ebp)
  8002e5:	ff 75 d8             	pushl  -0x28(%ebp)
  8002e8:	e8 9b 1a 00 00       	call   801d88 <__udivdi3>
  8002ed:	83 c4 18             	add    $0x18,%esp
  8002f0:	52                   	push   %edx
  8002f1:	50                   	push   %eax
  8002f2:	89 f2                	mov    %esi,%edx
  8002f4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8002f7:	e8 98 ff ff ff       	call   800294 <printnum>
  8002fc:	83 c4 20             	add    $0x20,%esp
  8002ff:	eb 10                	jmp    800311 <printnum+0x7d>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800301:	83 ec 08             	sub    $0x8,%esp
  800304:	56                   	push   %esi
  800305:	57                   	push   %edi
  800306:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800309:	4b                   	dec    %ebx
  80030a:	83 c4 10             	add    $0x10,%esp
  80030d:	85 db                	test   %ebx,%ebx
  80030f:	7f f0                	jg     800301 <printnum+0x6d>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800311:	83 ec 08             	sub    $0x8,%esp
  800314:	56                   	push   %esi
  800315:	83 ec 04             	sub    $0x4,%esp
  800318:	ff 75 d4             	pushl  -0x2c(%ebp)
  80031b:	ff 75 d0             	pushl  -0x30(%ebp)
  80031e:	ff 75 dc             	pushl  -0x24(%ebp)
  800321:	ff 75 d8             	pushl  -0x28(%ebp)
  800324:	e8 7b 1b 00 00       	call   801ea4 <__umoddi3>
  800329:	83 c4 14             	add    $0x14,%esp
  80032c:	0f be 80 67 20 80 00 	movsbl 0x802067(%eax),%eax
  800333:	50                   	push   %eax
  800334:	ff 55 e4             	call   *-0x1c(%ebp)
  800337:	83 c4 10             	add    $0x10,%esp
}
  80033a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80033d:	5b                   	pop    %ebx
  80033e:	5e                   	pop    %esi
  80033f:	5f                   	pop    %edi
  800340:	c9                   	leave  
  800341:	c3                   	ret    

00800342 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800342:	55                   	push   %ebp
  800343:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800345:	83 fa 01             	cmp    $0x1,%edx
  800348:	7e 0e                	jle    800358 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80034a:	8b 10                	mov    (%eax),%edx
  80034c:	8d 4a 08             	lea    0x8(%edx),%ecx
  80034f:	89 08                	mov    %ecx,(%eax)
  800351:	8b 02                	mov    (%edx),%eax
  800353:	8b 52 04             	mov    0x4(%edx),%edx
  800356:	eb 22                	jmp    80037a <getuint+0x38>
	else if (lflag)
  800358:	85 d2                	test   %edx,%edx
  80035a:	74 10                	je     80036c <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80035c:	8b 10                	mov    (%eax),%edx
  80035e:	8d 4a 04             	lea    0x4(%edx),%ecx
  800361:	89 08                	mov    %ecx,(%eax)
  800363:	8b 02                	mov    (%edx),%eax
  800365:	ba 00 00 00 00       	mov    $0x0,%edx
  80036a:	eb 0e                	jmp    80037a <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80036c:	8b 10                	mov    (%eax),%edx
  80036e:	8d 4a 04             	lea    0x4(%edx),%ecx
  800371:	89 08                	mov    %ecx,(%eax)
  800373:	8b 02                	mov    (%edx),%eax
  800375:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80037a:	c9                   	leave  
  80037b:	c3                   	ret    

0080037c <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  80037c:	55                   	push   %ebp
  80037d:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80037f:	83 fa 01             	cmp    $0x1,%edx
  800382:	7e 0e                	jle    800392 <getint+0x16>
		return va_arg(*ap, long long);
  800384:	8b 10                	mov    (%eax),%edx
  800386:	8d 4a 08             	lea    0x8(%edx),%ecx
  800389:	89 08                	mov    %ecx,(%eax)
  80038b:	8b 02                	mov    (%edx),%eax
  80038d:	8b 52 04             	mov    0x4(%edx),%edx
  800390:	eb 1a                	jmp    8003ac <getint+0x30>
	else if (lflag)
  800392:	85 d2                	test   %edx,%edx
  800394:	74 0c                	je     8003a2 <getint+0x26>
		return va_arg(*ap, long);
  800396:	8b 10                	mov    (%eax),%edx
  800398:	8d 4a 04             	lea    0x4(%edx),%ecx
  80039b:	89 08                	mov    %ecx,(%eax)
  80039d:	8b 02                	mov    (%edx),%eax
  80039f:	99                   	cltd   
  8003a0:	eb 0a                	jmp    8003ac <getint+0x30>
	else
		return va_arg(*ap, int);
  8003a2:	8b 10                	mov    (%eax),%edx
  8003a4:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003a7:	89 08                	mov    %ecx,(%eax)
  8003a9:	8b 02                	mov    (%edx),%eax
  8003ab:	99                   	cltd   
}
  8003ac:	c9                   	leave  
  8003ad:	c3                   	ret    

008003ae <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8003ae:	55                   	push   %ebp
  8003af:	89 e5                	mov    %esp,%ebp
  8003b1:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8003b4:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  8003b7:	8b 10                	mov    (%eax),%edx
  8003b9:	3b 50 04             	cmp    0x4(%eax),%edx
  8003bc:	73 08                	jae    8003c6 <sprintputch+0x18>
		*b->buf++ = ch;
  8003be:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8003c1:	88 0a                	mov    %cl,(%edx)
  8003c3:	42                   	inc    %edx
  8003c4:	89 10                	mov    %edx,(%eax)
}
  8003c6:	c9                   	leave  
  8003c7:	c3                   	ret    

008003c8 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8003c8:	55                   	push   %ebp
  8003c9:	89 e5                	mov    %esp,%ebp
  8003cb:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8003ce:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8003d1:	50                   	push   %eax
  8003d2:	ff 75 10             	pushl  0x10(%ebp)
  8003d5:	ff 75 0c             	pushl  0xc(%ebp)
  8003d8:	ff 75 08             	pushl  0x8(%ebp)
  8003db:	e8 05 00 00 00       	call   8003e5 <vprintfmt>
	va_end(ap);
  8003e0:	83 c4 10             	add    $0x10,%esp
}
  8003e3:	c9                   	leave  
  8003e4:	c3                   	ret    

008003e5 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8003e5:	55                   	push   %ebp
  8003e6:	89 e5                	mov    %esp,%ebp
  8003e8:	57                   	push   %edi
  8003e9:	56                   	push   %esi
  8003ea:	53                   	push   %ebx
  8003eb:	83 ec 2c             	sub    $0x2c,%esp
  8003ee:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8003f1:	8b 75 10             	mov    0x10(%ebp),%esi
  8003f4:	eb 13                	jmp    800409 <vprintfmt+0x24>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8003f6:	85 c0                	test   %eax,%eax
  8003f8:	0f 84 6d 03 00 00    	je     80076b <vprintfmt+0x386>
				return;
			putch(ch, putdat);
  8003fe:	83 ec 08             	sub    $0x8,%esp
  800401:	57                   	push   %edi
  800402:	50                   	push   %eax
  800403:	ff 55 08             	call   *0x8(%ebp)
  800406:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800409:	0f b6 06             	movzbl (%esi),%eax
  80040c:	46                   	inc    %esi
  80040d:	83 f8 25             	cmp    $0x25,%eax
  800410:	75 e4                	jne    8003f6 <vprintfmt+0x11>
  800412:	c6 45 dc 20          	movb   $0x20,-0x24(%ebp)
  800416:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  80041d:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  800424:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  80042b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800430:	eb 28                	jmp    80045a <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800432:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800434:	c6 45 dc 2d          	movb   $0x2d,-0x24(%ebp)
  800438:	eb 20                	jmp    80045a <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80043a:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80043c:	c6 45 dc 30          	movb   $0x30,-0x24(%ebp)
  800440:	eb 18                	jmp    80045a <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800442:	89 de                	mov    %ebx,%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800444:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  80044b:	eb 0d                	jmp    80045a <vprintfmt+0x75>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  80044d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800450:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800453:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80045a:	8a 06                	mov    (%esi),%al
  80045c:	0f b6 d0             	movzbl %al,%edx
  80045f:	8d 5e 01             	lea    0x1(%esi),%ebx
  800462:	83 e8 23             	sub    $0x23,%eax
  800465:	3c 55                	cmp    $0x55,%al
  800467:	0f 87 e0 02 00 00    	ja     80074d <vprintfmt+0x368>
  80046d:	0f b6 c0             	movzbl %al,%eax
  800470:	ff 24 85 a0 21 80 00 	jmp    *0x8021a0(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800477:	83 ea 30             	sub    $0x30,%edx
  80047a:	89 55 d4             	mov    %edx,-0x2c(%ebp)
				ch = *fmt;
  80047d:	0f be 03             	movsbl (%ebx),%eax
				if (ch < '0' || ch > '9')
  800480:	8d 50 d0             	lea    -0x30(%eax),%edx
  800483:	83 fa 09             	cmp    $0x9,%edx
  800486:	77 44                	ja     8004cc <vprintfmt+0xe7>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800488:	89 de                	mov    %ebx,%esi
  80048a:	8b 55 d4             	mov    -0x2c(%ebp),%edx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80048d:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
  80048e:	8d 14 92             	lea    (%edx,%edx,4),%edx
  800491:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
  800495:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800498:	8d 58 d0             	lea    -0x30(%eax),%ebx
  80049b:	83 fb 09             	cmp    $0x9,%ebx
  80049e:	76 ed                	jbe    80048d <vprintfmt+0xa8>
  8004a0:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  8004a3:	eb 29                	jmp    8004ce <vprintfmt+0xe9>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8004a5:	8b 45 14             	mov    0x14(%ebp),%eax
  8004a8:	8d 50 04             	lea    0x4(%eax),%edx
  8004ab:	89 55 14             	mov    %edx,0x14(%ebp)
  8004ae:	8b 00                	mov    (%eax),%eax
  8004b0:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004b3:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8004b5:	eb 17                	jmp    8004ce <vprintfmt+0xe9>

		case '.':
			if (width < 0)
  8004b7:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8004bb:	78 85                	js     800442 <vprintfmt+0x5d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004bd:	89 de                	mov    %ebx,%esi
  8004bf:	eb 99                	jmp    80045a <vprintfmt+0x75>
  8004c1:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8004c3:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  8004ca:	eb 8e                	jmp    80045a <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004cc:	89 de                	mov    %ebx,%esi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  8004ce:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8004d2:	79 86                	jns    80045a <vprintfmt+0x75>
  8004d4:	e9 74 ff ff ff       	jmp    80044d <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8004d9:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004da:	89 de                	mov    %ebx,%esi
  8004dc:	e9 79 ff ff ff       	jmp    80045a <vprintfmt+0x75>
  8004e1:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8004e4:	8b 45 14             	mov    0x14(%ebp),%eax
  8004e7:	8d 50 04             	lea    0x4(%eax),%edx
  8004ea:	89 55 14             	mov    %edx,0x14(%ebp)
  8004ed:	83 ec 08             	sub    $0x8,%esp
  8004f0:	57                   	push   %edi
  8004f1:	ff 30                	pushl  (%eax)
  8004f3:	ff 55 08             	call   *0x8(%ebp)
			break;
  8004f6:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004f9:	8b 75 d8             	mov    -0x28(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8004fc:	e9 08 ff ff ff       	jmp    800409 <vprintfmt+0x24>
  800501:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  800504:	8b 45 14             	mov    0x14(%ebp),%eax
  800507:	8d 50 04             	lea    0x4(%eax),%edx
  80050a:	89 55 14             	mov    %edx,0x14(%ebp)
  80050d:	8b 00                	mov    (%eax),%eax
  80050f:	85 c0                	test   %eax,%eax
  800511:	79 02                	jns    800515 <vprintfmt+0x130>
  800513:	f7 d8                	neg    %eax
  800515:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800517:	83 f8 0f             	cmp    $0xf,%eax
  80051a:	7f 0b                	jg     800527 <vprintfmt+0x142>
  80051c:	8b 04 85 00 23 80 00 	mov    0x802300(,%eax,4),%eax
  800523:	85 c0                	test   %eax,%eax
  800525:	75 1a                	jne    800541 <vprintfmt+0x15c>
				printfmt(putch, putdat, "error %d", err);
  800527:	52                   	push   %edx
  800528:	68 7f 20 80 00       	push   $0x80207f
  80052d:	57                   	push   %edi
  80052e:	ff 75 08             	pushl  0x8(%ebp)
  800531:	e8 92 fe ff ff       	call   8003c8 <printfmt>
  800536:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800539:	8b 75 d8             	mov    -0x28(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80053c:	e9 c8 fe ff ff       	jmp    800409 <vprintfmt+0x24>
			else
				printfmt(putch, putdat, "%s", p);
  800541:	50                   	push   %eax
  800542:	68 35 24 80 00       	push   $0x802435
  800547:	57                   	push   %edi
  800548:	ff 75 08             	pushl  0x8(%ebp)
  80054b:	e8 78 fe ff ff       	call   8003c8 <printfmt>
  800550:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800553:	8b 75 d8             	mov    -0x28(%ebp),%esi
  800556:	e9 ae fe ff ff       	jmp    800409 <vprintfmt+0x24>
  80055b:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  80055e:	89 de                	mov    %ebx,%esi
  800560:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  800563:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800566:	8b 45 14             	mov    0x14(%ebp),%eax
  800569:	8d 50 04             	lea    0x4(%eax),%edx
  80056c:	89 55 14             	mov    %edx,0x14(%ebp)
  80056f:	8b 00                	mov    (%eax),%eax
  800571:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800574:	85 c0                	test   %eax,%eax
  800576:	75 07                	jne    80057f <vprintfmt+0x19a>
				p = "(null)";
  800578:	c7 45 d0 78 20 80 00 	movl   $0x802078,-0x30(%ebp)
			if (width > 0 && padc != '-')
  80057f:	85 db                	test   %ebx,%ebx
  800581:	7e 42                	jle    8005c5 <vprintfmt+0x1e0>
  800583:	80 7d dc 2d          	cmpb   $0x2d,-0x24(%ebp)
  800587:	74 3c                	je     8005c5 <vprintfmt+0x1e0>
				for (width -= strnlen(p, precision); width > 0; width--)
  800589:	83 ec 08             	sub    $0x8,%esp
  80058c:	51                   	push   %ecx
  80058d:	ff 75 d0             	pushl  -0x30(%ebp)
  800590:	e8 6f 02 00 00       	call   800804 <strnlen>
  800595:	29 c3                	sub    %eax,%ebx
  800597:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80059a:	83 c4 10             	add    $0x10,%esp
  80059d:	85 db                	test   %ebx,%ebx
  80059f:	7e 24                	jle    8005c5 <vprintfmt+0x1e0>
					putch(padc, putdat);
  8005a1:	0f be 5d dc          	movsbl -0x24(%ebp),%ebx
  8005a5:	89 75 dc             	mov    %esi,-0x24(%ebp)
  8005a8:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  8005ab:	83 ec 08             	sub    $0x8,%esp
  8005ae:	57                   	push   %edi
  8005af:	53                   	push   %ebx
  8005b0:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005b3:	4e                   	dec    %esi
  8005b4:	83 c4 10             	add    $0x10,%esp
  8005b7:	85 f6                	test   %esi,%esi
  8005b9:	7f f0                	jg     8005ab <vprintfmt+0x1c6>
  8005bb:	8b 75 dc             	mov    -0x24(%ebp),%esi
  8005be:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005c5:	8b 55 d0             	mov    -0x30(%ebp),%edx
  8005c8:	0f be 02             	movsbl (%edx),%eax
  8005cb:	85 c0                	test   %eax,%eax
  8005cd:	75 47                	jne    800616 <vprintfmt+0x231>
  8005cf:	eb 37                	jmp    800608 <vprintfmt+0x223>
				if (altflag && (ch < ' ' || ch > '~'))
  8005d1:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8005d5:	74 16                	je     8005ed <vprintfmt+0x208>
  8005d7:	8d 50 e0             	lea    -0x20(%eax),%edx
  8005da:	83 fa 5e             	cmp    $0x5e,%edx
  8005dd:	76 0e                	jbe    8005ed <vprintfmt+0x208>
					putch('?', putdat);
  8005df:	83 ec 08             	sub    $0x8,%esp
  8005e2:	57                   	push   %edi
  8005e3:	6a 3f                	push   $0x3f
  8005e5:	ff 55 08             	call   *0x8(%ebp)
  8005e8:	83 c4 10             	add    $0x10,%esp
  8005eb:	eb 0b                	jmp    8005f8 <vprintfmt+0x213>
				else
					putch(ch, putdat);
  8005ed:	83 ec 08             	sub    $0x8,%esp
  8005f0:	57                   	push   %edi
  8005f1:	50                   	push   %eax
  8005f2:	ff 55 08             	call   *0x8(%ebp)
  8005f5:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005f8:	ff 4d e4             	decl   -0x1c(%ebp)
  8005fb:	0f be 03             	movsbl (%ebx),%eax
  8005fe:	85 c0                	test   %eax,%eax
  800600:	74 03                	je     800605 <vprintfmt+0x220>
  800602:	43                   	inc    %ebx
  800603:	eb 1b                	jmp    800620 <vprintfmt+0x23b>
  800605:	8b 75 dc             	mov    -0x24(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800608:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80060c:	7f 1e                	jg     80062c <vprintfmt+0x247>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80060e:	8b 75 d8             	mov    -0x28(%ebp),%esi
  800611:	e9 f3 fd ff ff       	jmp    800409 <vprintfmt+0x24>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800616:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800619:	43                   	inc    %ebx
  80061a:	89 75 dc             	mov    %esi,-0x24(%ebp)
  80061d:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  800620:	85 f6                	test   %esi,%esi
  800622:	78 ad                	js     8005d1 <vprintfmt+0x1ec>
  800624:	4e                   	dec    %esi
  800625:	79 aa                	jns    8005d1 <vprintfmt+0x1ec>
  800627:	8b 75 dc             	mov    -0x24(%ebp),%esi
  80062a:	eb dc                	jmp    800608 <vprintfmt+0x223>
  80062c:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80062f:	83 ec 08             	sub    $0x8,%esp
  800632:	57                   	push   %edi
  800633:	6a 20                	push   $0x20
  800635:	ff 55 08             	call   *0x8(%ebp)
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800638:	4b                   	dec    %ebx
  800639:	83 c4 10             	add    $0x10,%esp
  80063c:	85 db                	test   %ebx,%ebx
  80063e:	7f ef                	jg     80062f <vprintfmt+0x24a>
  800640:	e9 c4 fd ff ff       	jmp    800409 <vprintfmt+0x24>
  800645:	89 5d d8             	mov    %ebx,-0x28(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800648:	89 ca                	mov    %ecx,%edx
  80064a:	8d 45 14             	lea    0x14(%ebp),%eax
  80064d:	e8 2a fd ff ff       	call   80037c <getint>
  800652:	89 c3                	mov    %eax,%ebx
  800654:	89 d6                	mov    %edx,%esi
			if ((long long) num < 0) {
  800656:	85 d2                	test   %edx,%edx
  800658:	78 0a                	js     800664 <vprintfmt+0x27f>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80065a:	b8 0a 00 00 00       	mov    $0xa,%eax
  80065f:	e9 b0 00 00 00       	jmp    800714 <vprintfmt+0x32f>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  800664:	83 ec 08             	sub    $0x8,%esp
  800667:	57                   	push   %edi
  800668:	6a 2d                	push   $0x2d
  80066a:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  80066d:	f7 db                	neg    %ebx
  80066f:	83 d6 00             	adc    $0x0,%esi
  800672:	f7 de                	neg    %esi
  800674:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800677:	b8 0a 00 00 00       	mov    $0xa,%eax
  80067c:	e9 93 00 00 00       	jmp    800714 <vprintfmt+0x32f>
  800681:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800684:	89 ca                	mov    %ecx,%edx
  800686:	8d 45 14             	lea    0x14(%ebp),%eax
  800689:	e8 b4 fc ff ff       	call   800342 <getuint>
  80068e:	89 c3                	mov    %eax,%ebx
  800690:	89 d6                	mov    %edx,%esi
			base = 10;
  800692:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  800697:	eb 7b                	jmp    800714 <vprintfmt+0x32f>
  800699:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
  80069c:	89 ca                	mov    %ecx,%edx
  80069e:	8d 45 14             	lea    0x14(%ebp),%eax
  8006a1:	e8 d6 fc ff ff       	call   80037c <getint>
  8006a6:	89 c3                	mov    %eax,%ebx
  8006a8:	89 d6                	mov    %edx,%esi
            if ((long long) num < 0) {
  8006aa:	85 d2                	test   %edx,%edx
  8006ac:	78 07                	js     8006b5 <vprintfmt+0x2d0>
                putch('-', putdat);
                num = -(long long) num;
            }
            base = 8;
  8006ae:	b8 08 00 00 00       	mov    $0x8,%eax
  8006b3:	eb 5f                	jmp    800714 <vprintfmt+0x32f>
		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
            if ((long long) num < 0) {
                putch('-', putdat);
  8006b5:	83 ec 08             	sub    $0x8,%esp
  8006b8:	57                   	push   %edi
  8006b9:	6a 2d                	push   $0x2d
  8006bb:	ff 55 08             	call   *0x8(%ebp)
                num = -(long long) num;
  8006be:	f7 db                	neg    %ebx
  8006c0:	83 d6 00             	adc    $0x0,%esi
  8006c3:	f7 de                	neg    %esi
  8006c5:	83 c4 10             	add    $0x10,%esp
            }
            base = 8;
  8006c8:	b8 08 00 00 00       	mov    $0x8,%eax
  8006cd:	eb 45                	jmp    800714 <vprintfmt+0x32f>
  8006cf:	89 5d d8             	mov    %ebx,-0x28(%ebp)
            goto number;

        // pointer
		case 'p':
			putch('0', putdat);
  8006d2:	83 ec 08             	sub    $0x8,%esp
  8006d5:	57                   	push   %edi
  8006d6:	6a 30                	push   $0x30
  8006d8:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8006db:	83 c4 08             	add    $0x8,%esp
  8006de:	57                   	push   %edi
  8006df:	6a 78                	push   $0x78
  8006e1:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8006e4:	8b 45 14             	mov    0x14(%ebp),%eax
  8006e7:	8d 50 04             	lea    0x4(%eax),%edx
  8006ea:	89 55 14             	mov    %edx,0x14(%ebp)

        // pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8006ed:	8b 18                	mov    (%eax),%ebx
  8006ef:	be 00 00 00 00       	mov    $0x0,%esi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8006f4:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8006f7:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8006fc:	eb 16                	jmp    800714 <vprintfmt+0x32f>
  8006fe:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800701:	89 ca                	mov    %ecx,%edx
  800703:	8d 45 14             	lea    0x14(%ebp),%eax
  800706:	e8 37 fc ff ff       	call   800342 <getuint>
  80070b:	89 c3                	mov    %eax,%ebx
  80070d:	89 d6                	mov    %edx,%esi
			base = 16;
  80070f:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800714:	83 ec 0c             	sub    $0xc,%esp
  800717:	0f be 55 dc          	movsbl -0x24(%ebp),%edx
  80071b:	52                   	push   %edx
  80071c:	ff 75 e4             	pushl  -0x1c(%ebp)
  80071f:	50                   	push   %eax
  800720:	56                   	push   %esi
  800721:	53                   	push   %ebx
  800722:	89 fa                	mov    %edi,%edx
  800724:	8b 45 08             	mov    0x8(%ebp),%eax
  800727:	e8 68 fb ff ff       	call   800294 <printnum>
			break;
  80072c:	83 c4 20             	add    $0x20,%esp
  80072f:	8b 75 d8             	mov    -0x28(%ebp),%esi
  800732:	e9 d2 fc ff ff       	jmp    800409 <vprintfmt+0x24>
  800737:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80073a:	83 ec 08             	sub    $0x8,%esp
  80073d:	57                   	push   %edi
  80073e:	52                   	push   %edx
  80073f:	ff 55 08             	call   *0x8(%ebp)
			break;
  800742:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800745:	8b 75 d8             	mov    -0x28(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800748:	e9 bc fc ff ff       	jmp    800409 <vprintfmt+0x24>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80074d:	83 ec 08             	sub    $0x8,%esp
  800750:	57                   	push   %edi
  800751:	6a 25                	push   $0x25
  800753:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800756:	83 c4 10             	add    $0x10,%esp
  800759:	eb 02                	jmp    80075d <vprintfmt+0x378>
  80075b:	89 c6                	mov    %eax,%esi
  80075d:	8d 46 ff             	lea    -0x1(%esi),%eax
  800760:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800764:	75 f5                	jne    80075b <vprintfmt+0x376>
  800766:	e9 9e fc ff ff       	jmp    800409 <vprintfmt+0x24>
				/* do nothing */;
			break;
		}
	}
}
  80076b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80076e:	5b                   	pop    %ebx
  80076f:	5e                   	pop    %esi
  800770:	5f                   	pop    %edi
  800771:	c9                   	leave  
  800772:	c3                   	ret    

00800773 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800773:	55                   	push   %ebp
  800774:	89 e5                	mov    %esp,%ebp
  800776:	83 ec 18             	sub    $0x18,%esp
  800779:	8b 45 08             	mov    0x8(%ebp),%eax
  80077c:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80077f:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800782:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800786:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800789:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800790:	85 c0                	test   %eax,%eax
  800792:	74 26                	je     8007ba <vsnprintf+0x47>
  800794:	85 d2                	test   %edx,%edx
  800796:	7e 29                	jle    8007c1 <vsnprintf+0x4e>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800798:	ff 75 14             	pushl  0x14(%ebp)
  80079b:	ff 75 10             	pushl  0x10(%ebp)
  80079e:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8007a1:	50                   	push   %eax
  8007a2:	68 ae 03 80 00       	push   $0x8003ae
  8007a7:	e8 39 fc ff ff       	call   8003e5 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8007ac:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007af:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8007b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007b5:	83 c4 10             	add    $0x10,%esp
  8007b8:	eb 0c                	jmp    8007c6 <vsnprintf+0x53>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8007ba:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8007bf:	eb 05                	jmp    8007c6 <vsnprintf+0x53>
  8007c1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8007c6:	c9                   	leave  
  8007c7:	c3                   	ret    

008007c8 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007c8:	55                   	push   %ebp
  8007c9:	89 e5                	mov    %esp,%ebp
  8007cb:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007ce:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8007d1:	50                   	push   %eax
  8007d2:	ff 75 10             	pushl  0x10(%ebp)
  8007d5:	ff 75 0c             	pushl  0xc(%ebp)
  8007d8:	ff 75 08             	pushl  0x8(%ebp)
  8007db:	e8 93 ff ff ff       	call   800773 <vsnprintf>
	va_end(ap);

	return rc;
}
  8007e0:	c9                   	leave  
  8007e1:	c3                   	ret    
	...

008007e4 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007e4:	55                   	push   %ebp
  8007e5:	89 e5                	mov    %esp,%ebp
  8007e7:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007ea:	80 3a 00             	cmpb   $0x0,(%edx)
  8007ed:	74 0e                	je     8007fd <strlen+0x19>
  8007ef:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  8007f4:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8007f5:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007f9:	75 f9                	jne    8007f4 <strlen+0x10>
  8007fb:	eb 05                	jmp    800802 <strlen+0x1e>
  8007fd:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800802:	c9                   	leave  
  800803:	c3                   	ret    

00800804 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800804:	55                   	push   %ebp
  800805:	89 e5                	mov    %esp,%ebp
  800807:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80080a:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80080d:	85 d2                	test   %edx,%edx
  80080f:	74 17                	je     800828 <strnlen+0x24>
  800811:	80 39 00             	cmpb   $0x0,(%ecx)
  800814:	74 19                	je     80082f <strnlen+0x2b>
  800816:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  80081b:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80081c:	39 d0                	cmp    %edx,%eax
  80081e:	74 14                	je     800834 <strnlen+0x30>
  800820:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800824:	75 f5                	jne    80081b <strnlen+0x17>
  800826:	eb 0c                	jmp    800834 <strnlen+0x30>
  800828:	b8 00 00 00 00       	mov    $0x0,%eax
  80082d:	eb 05                	jmp    800834 <strnlen+0x30>
  80082f:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800834:	c9                   	leave  
  800835:	c3                   	ret    

00800836 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800836:	55                   	push   %ebp
  800837:	89 e5                	mov    %esp,%ebp
  800839:	53                   	push   %ebx
  80083a:	8b 45 08             	mov    0x8(%ebp),%eax
  80083d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800840:	ba 00 00 00 00       	mov    $0x0,%edx
  800845:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  800848:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  80084b:	42                   	inc    %edx
  80084c:	84 c9                	test   %cl,%cl
  80084e:	75 f5                	jne    800845 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800850:	5b                   	pop    %ebx
  800851:	c9                   	leave  
  800852:	c3                   	ret    

00800853 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800853:	55                   	push   %ebp
  800854:	89 e5                	mov    %esp,%ebp
  800856:	53                   	push   %ebx
  800857:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80085a:	53                   	push   %ebx
  80085b:	e8 84 ff ff ff       	call   8007e4 <strlen>
  800860:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800863:	ff 75 0c             	pushl  0xc(%ebp)
  800866:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  800869:	50                   	push   %eax
  80086a:	e8 c7 ff ff ff       	call   800836 <strcpy>
	return dst;
}
  80086f:	89 d8                	mov    %ebx,%eax
  800871:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800874:	c9                   	leave  
  800875:	c3                   	ret    

00800876 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800876:	55                   	push   %ebp
  800877:	89 e5                	mov    %esp,%ebp
  800879:	56                   	push   %esi
  80087a:	53                   	push   %ebx
  80087b:	8b 45 08             	mov    0x8(%ebp),%eax
  80087e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800881:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800884:	85 f6                	test   %esi,%esi
  800886:	74 15                	je     80089d <strncpy+0x27>
  800888:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  80088d:	8a 1a                	mov    (%edx),%bl
  80088f:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800892:	80 3a 01             	cmpb   $0x1,(%edx)
  800895:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800898:	41                   	inc    %ecx
  800899:	39 ce                	cmp    %ecx,%esi
  80089b:	77 f0                	ja     80088d <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80089d:	5b                   	pop    %ebx
  80089e:	5e                   	pop    %esi
  80089f:	c9                   	leave  
  8008a0:	c3                   	ret    

008008a1 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8008a1:	55                   	push   %ebp
  8008a2:	89 e5                	mov    %esp,%ebp
  8008a4:	57                   	push   %edi
  8008a5:	56                   	push   %esi
  8008a6:	53                   	push   %ebx
  8008a7:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008aa:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8008ad:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8008b0:	85 f6                	test   %esi,%esi
  8008b2:	74 32                	je     8008e6 <strlcpy+0x45>
		while (--size > 0 && *src != '\0')
  8008b4:	83 fe 01             	cmp    $0x1,%esi
  8008b7:	74 22                	je     8008db <strlcpy+0x3a>
  8008b9:	8a 0b                	mov    (%ebx),%cl
  8008bb:	84 c9                	test   %cl,%cl
  8008bd:	74 20                	je     8008df <strlcpy+0x3e>
  8008bf:	89 f8                	mov    %edi,%eax
  8008c1:	ba 00 00 00 00       	mov    $0x0,%edx
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
  8008c6:	83 ee 02             	sub    $0x2,%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8008c9:	88 08                	mov    %cl,(%eax)
  8008cb:	40                   	inc    %eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8008cc:	39 f2                	cmp    %esi,%edx
  8008ce:	74 11                	je     8008e1 <strlcpy+0x40>
  8008d0:	8a 4c 13 01          	mov    0x1(%ebx,%edx,1),%cl
  8008d4:	42                   	inc    %edx
  8008d5:	84 c9                	test   %cl,%cl
  8008d7:	75 f0                	jne    8008c9 <strlcpy+0x28>
  8008d9:	eb 06                	jmp    8008e1 <strlcpy+0x40>
  8008db:	89 f8                	mov    %edi,%eax
  8008dd:	eb 02                	jmp    8008e1 <strlcpy+0x40>
  8008df:	89 f8                	mov    %edi,%eax
			*dst++ = *src++;
		*dst = '\0';
  8008e1:	c6 00 00             	movb   $0x0,(%eax)
  8008e4:	eb 02                	jmp    8008e8 <strlcpy+0x47>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8008e6:	89 f8                	mov    %edi,%eax
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
		*dst = '\0';
	}
	return dst - dst_in;
  8008e8:	29 f8                	sub    %edi,%eax
}
  8008ea:	5b                   	pop    %ebx
  8008eb:	5e                   	pop    %esi
  8008ec:	5f                   	pop    %edi
  8008ed:	c9                   	leave  
  8008ee:	c3                   	ret    

008008ef <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8008ef:	55                   	push   %ebp
  8008f0:	89 e5                	mov    %esp,%ebp
  8008f2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008f5:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008f8:	8a 01                	mov    (%ecx),%al
  8008fa:	84 c0                	test   %al,%al
  8008fc:	74 10                	je     80090e <strcmp+0x1f>
  8008fe:	3a 02                	cmp    (%edx),%al
  800900:	75 0c                	jne    80090e <strcmp+0x1f>
		p++, q++;
  800902:	41                   	inc    %ecx
  800903:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800904:	8a 01                	mov    (%ecx),%al
  800906:	84 c0                	test   %al,%al
  800908:	74 04                	je     80090e <strcmp+0x1f>
  80090a:	3a 02                	cmp    (%edx),%al
  80090c:	74 f4                	je     800902 <strcmp+0x13>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80090e:	0f b6 c0             	movzbl %al,%eax
  800911:	0f b6 12             	movzbl (%edx),%edx
  800914:	29 d0                	sub    %edx,%eax
}
  800916:	c9                   	leave  
  800917:	c3                   	ret    

00800918 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800918:	55                   	push   %ebp
  800919:	89 e5                	mov    %esp,%ebp
  80091b:	53                   	push   %ebx
  80091c:	8b 55 08             	mov    0x8(%ebp),%edx
  80091f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800922:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  800925:	85 c0                	test   %eax,%eax
  800927:	74 1b                	je     800944 <strncmp+0x2c>
  800929:	8a 1a                	mov    (%edx),%bl
  80092b:	84 db                	test   %bl,%bl
  80092d:	74 24                	je     800953 <strncmp+0x3b>
  80092f:	3a 19                	cmp    (%ecx),%bl
  800931:	75 20                	jne    800953 <strncmp+0x3b>
  800933:	48                   	dec    %eax
  800934:	74 15                	je     80094b <strncmp+0x33>
		n--, p++, q++;
  800936:	42                   	inc    %edx
  800937:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800938:	8a 1a                	mov    (%edx),%bl
  80093a:	84 db                	test   %bl,%bl
  80093c:	74 15                	je     800953 <strncmp+0x3b>
  80093e:	3a 19                	cmp    (%ecx),%bl
  800940:	74 f1                	je     800933 <strncmp+0x1b>
  800942:	eb 0f                	jmp    800953 <strncmp+0x3b>
		n--, p++, q++;
	if (n == 0)
		return 0;
  800944:	b8 00 00 00 00       	mov    $0x0,%eax
  800949:	eb 05                	jmp    800950 <strncmp+0x38>
  80094b:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800950:	5b                   	pop    %ebx
  800951:	c9                   	leave  
  800952:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800953:	0f b6 02             	movzbl (%edx),%eax
  800956:	0f b6 11             	movzbl (%ecx),%edx
  800959:	29 d0                	sub    %edx,%eax
  80095b:	eb f3                	jmp    800950 <strncmp+0x38>

0080095d <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80095d:	55                   	push   %ebp
  80095e:	89 e5                	mov    %esp,%ebp
  800960:	8b 45 08             	mov    0x8(%ebp),%eax
  800963:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800966:	8a 10                	mov    (%eax),%dl
  800968:	84 d2                	test   %dl,%dl
  80096a:	74 18                	je     800984 <strchr+0x27>
		if (*s == c)
  80096c:	38 ca                	cmp    %cl,%dl
  80096e:	75 06                	jne    800976 <strchr+0x19>
  800970:	eb 17                	jmp    800989 <strchr+0x2c>
  800972:	38 ca                	cmp    %cl,%dl
  800974:	74 13                	je     800989 <strchr+0x2c>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800976:	40                   	inc    %eax
  800977:	8a 10                	mov    (%eax),%dl
  800979:	84 d2                	test   %dl,%dl
  80097b:	75 f5                	jne    800972 <strchr+0x15>
		if (*s == c)
			return (char *) s;
	return 0;
  80097d:	b8 00 00 00 00       	mov    $0x0,%eax
  800982:	eb 05                	jmp    800989 <strchr+0x2c>
  800984:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800989:	c9                   	leave  
  80098a:	c3                   	ret    

0080098b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80098b:	55                   	push   %ebp
  80098c:	89 e5                	mov    %esp,%ebp
  80098e:	8b 45 08             	mov    0x8(%ebp),%eax
  800991:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800994:	8a 10                	mov    (%eax),%dl
  800996:	84 d2                	test   %dl,%dl
  800998:	74 11                	je     8009ab <strfind+0x20>
		if (*s == c)
  80099a:	38 ca                	cmp    %cl,%dl
  80099c:	75 06                	jne    8009a4 <strfind+0x19>
  80099e:	eb 0b                	jmp    8009ab <strfind+0x20>
  8009a0:	38 ca                	cmp    %cl,%dl
  8009a2:	74 07                	je     8009ab <strfind+0x20>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  8009a4:	40                   	inc    %eax
  8009a5:	8a 10                	mov    (%eax),%dl
  8009a7:	84 d2                	test   %dl,%dl
  8009a9:	75 f5                	jne    8009a0 <strfind+0x15>
		if (*s == c)
			break;
	return (char *) s;
}
  8009ab:	c9                   	leave  
  8009ac:	c3                   	ret    

008009ad <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8009ad:	55                   	push   %ebp
  8009ae:	89 e5                	mov    %esp,%ebp
  8009b0:	57                   	push   %edi
  8009b1:	56                   	push   %esi
  8009b2:	53                   	push   %ebx
  8009b3:	8b 7d 08             	mov    0x8(%ebp),%edi
  8009b6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009b9:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8009bc:	85 c9                	test   %ecx,%ecx
  8009be:	74 30                	je     8009f0 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8009c0:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8009c6:	75 25                	jne    8009ed <memset+0x40>
  8009c8:	f6 c1 03             	test   $0x3,%cl
  8009cb:	75 20                	jne    8009ed <memset+0x40>
		c &= 0xFF;
  8009cd:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8009d0:	89 d3                	mov    %edx,%ebx
  8009d2:	c1 e3 08             	shl    $0x8,%ebx
  8009d5:	89 d6                	mov    %edx,%esi
  8009d7:	c1 e6 18             	shl    $0x18,%esi
  8009da:	89 d0                	mov    %edx,%eax
  8009dc:	c1 e0 10             	shl    $0x10,%eax
  8009df:	09 f0                	or     %esi,%eax
  8009e1:	09 d0                	or     %edx,%eax
  8009e3:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  8009e5:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  8009e8:	fc                   	cld    
  8009e9:	f3 ab                	rep stos %eax,%es:(%edi)
  8009eb:	eb 03                	jmp    8009f0 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8009ed:	fc                   	cld    
  8009ee:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8009f0:	89 f8                	mov    %edi,%eax
  8009f2:	5b                   	pop    %ebx
  8009f3:	5e                   	pop    %esi
  8009f4:	5f                   	pop    %edi
  8009f5:	c9                   	leave  
  8009f6:	c3                   	ret    

008009f7 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8009f7:	55                   	push   %ebp
  8009f8:	89 e5                	mov    %esp,%ebp
  8009fa:	57                   	push   %edi
  8009fb:	56                   	push   %esi
  8009fc:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ff:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a02:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a05:	39 c6                	cmp    %eax,%esi
  800a07:	73 34                	jae    800a3d <memmove+0x46>
  800a09:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a0c:	39 d0                	cmp    %edx,%eax
  800a0e:	73 2d                	jae    800a3d <memmove+0x46>
		s += n;
		d += n;
  800a10:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a13:	f6 c2 03             	test   $0x3,%dl
  800a16:	75 1b                	jne    800a33 <memmove+0x3c>
  800a18:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a1e:	75 13                	jne    800a33 <memmove+0x3c>
  800a20:	f6 c1 03             	test   $0x3,%cl
  800a23:	75 0e                	jne    800a33 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800a25:	83 ef 04             	sub    $0x4,%edi
  800a28:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a2b:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800a2e:	fd                   	std    
  800a2f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a31:	eb 07                	jmp    800a3a <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800a33:	4f                   	dec    %edi
  800a34:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800a37:	fd                   	std    
  800a38:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a3a:	fc                   	cld    
  800a3b:	eb 20                	jmp    800a5d <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a3d:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a43:	75 13                	jne    800a58 <memmove+0x61>
  800a45:	a8 03                	test   $0x3,%al
  800a47:	75 0f                	jne    800a58 <memmove+0x61>
  800a49:	f6 c1 03             	test   $0x3,%cl
  800a4c:	75 0a                	jne    800a58 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800a4e:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800a51:	89 c7                	mov    %eax,%edi
  800a53:	fc                   	cld    
  800a54:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a56:	eb 05                	jmp    800a5d <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a58:	89 c7                	mov    %eax,%edi
  800a5a:	fc                   	cld    
  800a5b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a5d:	5e                   	pop    %esi
  800a5e:	5f                   	pop    %edi
  800a5f:	c9                   	leave  
  800a60:	c3                   	ret    

00800a61 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a61:	55                   	push   %ebp
  800a62:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800a64:	ff 75 10             	pushl  0x10(%ebp)
  800a67:	ff 75 0c             	pushl  0xc(%ebp)
  800a6a:	ff 75 08             	pushl  0x8(%ebp)
  800a6d:	e8 85 ff ff ff       	call   8009f7 <memmove>
}
  800a72:	c9                   	leave  
  800a73:	c3                   	ret    

00800a74 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a74:	55                   	push   %ebp
  800a75:	89 e5                	mov    %esp,%ebp
  800a77:	57                   	push   %edi
  800a78:	56                   	push   %esi
  800a79:	53                   	push   %ebx
  800a7a:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800a7d:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a80:	8b 7d 10             	mov    0x10(%ebp),%edi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a83:	85 ff                	test   %edi,%edi
  800a85:	74 32                	je     800ab9 <memcmp+0x45>
		if (*s1 != *s2)
  800a87:	8a 03                	mov    (%ebx),%al
  800a89:	8a 0e                	mov    (%esi),%cl
  800a8b:	38 c8                	cmp    %cl,%al
  800a8d:	74 19                	je     800aa8 <memcmp+0x34>
  800a8f:	eb 0d                	jmp    800a9e <memcmp+0x2a>
  800a91:	8a 44 13 01          	mov    0x1(%ebx,%edx,1),%al
  800a95:	8a 4c 16 01          	mov    0x1(%esi,%edx,1),%cl
  800a99:	42                   	inc    %edx
  800a9a:	38 c8                	cmp    %cl,%al
  800a9c:	74 10                	je     800aae <memcmp+0x3a>
			return (int) *s1 - (int) *s2;
  800a9e:	0f b6 c0             	movzbl %al,%eax
  800aa1:	0f b6 c9             	movzbl %cl,%ecx
  800aa4:	29 c8                	sub    %ecx,%eax
  800aa6:	eb 16                	jmp    800abe <memcmp+0x4a>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800aa8:	4f                   	dec    %edi
  800aa9:	ba 00 00 00 00       	mov    $0x0,%edx
  800aae:	39 fa                	cmp    %edi,%edx
  800ab0:	75 df                	jne    800a91 <memcmp+0x1d>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800ab2:	b8 00 00 00 00       	mov    $0x0,%eax
  800ab7:	eb 05                	jmp    800abe <memcmp+0x4a>
  800ab9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800abe:	5b                   	pop    %ebx
  800abf:	5e                   	pop    %esi
  800ac0:	5f                   	pop    %edi
  800ac1:	c9                   	leave  
  800ac2:	c3                   	ret    

00800ac3 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800ac3:	55                   	push   %ebp
  800ac4:	89 e5                	mov    %esp,%ebp
  800ac6:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800ac9:	89 c2                	mov    %eax,%edx
  800acb:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800ace:	39 d0                	cmp    %edx,%eax
  800ad0:	73 12                	jae    800ae4 <memfind+0x21>
		if (*(const unsigned char *) s == (unsigned char) c)
  800ad2:	8a 4d 0c             	mov    0xc(%ebp),%cl
  800ad5:	38 08                	cmp    %cl,(%eax)
  800ad7:	75 06                	jne    800adf <memfind+0x1c>
  800ad9:	eb 09                	jmp    800ae4 <memfind+0x21>
  800adb:	38 08                	cmp    %cl,(%eax)
  800add:	74 05                	je     800ae4 <memfind+0x21>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800adf:	40                   	inc    %eax
  800ae0:	39 c2                	cmp    %eax,%edx
  800ae2:	77 f7                	ja     800adb <memfind+0x18>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800ae4:	c9                   	leave  
  800ae5:	c3                   	ret    

00800ae6 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800ae6:	55                   	push   %ebp
  800ae7:	89 e5                	mov    %esp,%ebp
  800ae9:	57                   	push   %edi
  800aea:	56                   	push   %esi
  800aeb:	53                   	push   %ebx
  800aec:	8b 55 08             	mov    0x8(%ebp),%edx
  800aef:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800af2:	eb 01                	jmp    800af5 <strtol+0xf>
		s++;
  800af4:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800af5:	8a 02                	mov    (%edx),%al
  800af7:	3c 20                	cmp    $0x20,%al
  800af9:	74 f9                	je     800af4 <strtol+0xe>
  800afb:	3c 09                	cmp    $0x9,%al
  800afd:	74 f5                	je     800af4 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800aff:	3c 2b                	cmp    $0x2b,%al
  800b01:	75 08                	jne    800b0b <strtol+0x25>
		s++;
  800b03:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800b04:	bf 00 00 00 00       	mov    $0x0,%edi
  800b09:	eb 13                	jmp    800b1e <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800b0b:	3c 2d                	cmp    $0x2d,%al
  800b0d:	75 0a                	jne    800b19 <strtol+0x33>
		s++, neg = 1;
  800b0f:	8d 52 01             	lea    0x1(%edx),%edx
  800b12:	bf 01 00 00 00       	mov    $0x1,%edi
  800b17:	eb 05                	jmp    800b1e <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800b19:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b1e:	85 db                	test   %ebx,%ebx
  800b20:	74 05                	je     800b27 <strtol+0x41>
  800b22:	83 fb 10             	cmp    $0x10,%ebx
  800b25:	75 28                	jne    800b4f <strtol+0x69>
  800b27:	8a 02                	mov    (%edx),%al
  800b29:	3c 30                	cmp    $0x30,%al
  800b2b:	75 10                	jne    800b3d <strtol+0x57>
  800b2d:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800b31:	75 0a                	jne    800b3d <strtol+0x57>
		s += 2, base = 16;
  800b33:	83 c2 02             	add    $0x2,%edx
  800b36:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b3b:	eb 12                	jmp    800b4f <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800b3d:	85 db                	test   %ebx,%ebx
  800b3f:	75 0e                	jne    800b4f <strtol+0x69>
  800b41:	3c 30                	cmp    $0x30,%al
  800b43:	75 05                	jne    800b4a <strtol+0x64>
		s++, base = 8;
  800b45:	42                   	inc    %edx
  800b46:	b3 08                	mov    $0x8,%bl
  800b48:	eb 05                	jmp    800b4f <strtol+0x69>
	else if (base == 0)
		base = 10;
  800b4a:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800b4f:	b8 00 00 00 00       	mov    $0x0,%eax
  800b54:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800b56:	8a 0a                	mov    (%edx),%cl
  800b58:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800b5b:	80 fb 09             	cmp    $0x9,%bl
  800b5e:	77 08                	ja     800b68 <strtol+0x82>
			dig = *s - '0';
  800b60:	0f be c9             	movsbl %cl,%ecx
  800b63:	83 e9 30             	sub    $0x30,%ecx
  800b66:	eb 1e                	jmp    800b86 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800b68:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800b6b:	80 fb 19             	cmp    $0x19,%bl
  800b6e:	77 08                	ja     800b78 <strtol+0x92>
			dig = *s - 'a' + 10;
  800b70:	0f be c9             	movsbl %cl,%ecx
  800b73:	83 e9 57             	sub    $0x57,%ecx
  800b76:	eb 0e                	jmp    800b86 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800b78:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800b7b:	80 fb 19             	cmp    $0x19,%bl
  800b7e:	77 13                	ja     800b93 <strtol+0xad>
			dig = *s - 'A' + 10;
  800b80:	0f be c9             	movsbl %cl,%ecx
  800b83:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800b86:	39 f1                	cmp    %esi,%ecx
  800b88:	7d 0d                	jge    800b97 <strtol+0xb1>
			break;
		s++, val = (val * base) + dig;
  800b8a:	42                   	inc    %edx
  800b8b:	0f af c6             	imul   %esi,%eax
  800b8e:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  800b91:	eb c3                	jmp    800b56 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800b93:	89 c1                	mov    %eax,%ecx
  800b95:	eb 02                	jmp    800b99 <strtol+0xb3>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800b97:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800b99:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b9d:	74 05                	je     800ba4 <strtol+0xbe>
		*endptr = (char *) s;
  800b9f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800ba2:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800ba4:	85 ff                	test   %edi,%edi
  800ba6:	74 04                	je     800bac <strtol+0xc6>
  800ba8:	89 c8                	mov    %ecx,%eax
  800baa:	f7 d8                	neg    %eax
}
  800bac:	5b                   	pop    %ebx
  800bad:	5e                   	pop    %esi
  800bae:	5f                   	pop    %edi
  800baf:	c9                   	leave  
  800bb0:	c3                   	ret    
  800bb1:	00 00                	add    %al,(%eax)
	...

00800bb4 <syscall>:
	return ret;
}

static int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800bb4:	55                   	push   %ebp
  800bb5:	89 e5                	mov    %esp,%ebp
  800bb7:	57                   	push   %edi
  800bb8:	56                   	push   %esi
  800bb9:	53                   	push   %ebx
  800bba:	83 ec 1c             	sub    $0x1c,%esp
  800bbd:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800bc0:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800bc3:	89 ca                	mov    %ecx,%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bc5:	8b 75 14             	mov    0x14(%ebp),%esi
  800bc8:	8b 7d 10             	mov    0x10(%ebp),%edi
  800bcb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800bce:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800bd1:	cd 30                	int    $0x30
  800bd3:	89 c2                	mov    %eax,%edx
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800bd5:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800bd9:	74 1c                	je     800bf7 <syscall+0x43>
  800bdb:	85 c0                	test   %eax,%eax
  800bdd:	7e 18                	jle    800bf7 <syscall+0x43>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bdf:	83 ec 0c             	sub    $0xc,%esp
  800be2:	50                   	push   %eax
  800be3:	ff 75 e4             	pushl  -0x1c(%ebp)
  800be6:	68 5f 23 80 00       	push   $0x80235f
  800beb:	6a 42                	push   $0x42
  800bed:	68 7c 23 80 00       	push   $0x80237c
  800bf2:	e8 b1 f5 ff ff       	call   8001a8 <_panic>

	return ret;
}
  800bf7:	89 d0                	mov    %edx,%eax
  800bf9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bfc:	5b                   	pop    %ebx
  800bfd:	5e                   	pop    %esi
  800bfe:	5f                   	pop    %edi
  800bff:	c9                   	leave  
  800c00:	c3                   	ret    

00800c01 <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{	
  800c01:	55                   	push   %ebp
  800c02:	89 e5                	mov    %esp,%ebp
  800c04:	83 ec 08             	sub    $0x8,%esp
	// my_sysenter(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
	// return;
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  800c07:	6a 00                	push   $0x0
  800c09:	6a 00                	push   $0x0
  800c0b:	6a 00                	push   $0x0
  800c0d:	ff 75 0c             	pushl  0xc(%ebp)
  800c10:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c13:	ba 00 00 00 00       	mov    $0x0,%edx
  800c18:	b8 00 00 00 00       	mov    $0x0,%eax
  800c1d:	e8 92 ff ff ff       	call   800bb4 <syscall>
  800c22:	83 c4 10             	add    $0x10,%esp
	return;
}
  800c25:	c9                   	leave  
  800c26:	c3                   	ret    

00800c27 <sys_cgetc>:

int
sys_cgetc(void)
{
  800c27:	55                   	push   %ebp
  800c28:	89 e5                	mov    %esp,%ebp
  800c2a:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_cgetc, 0, 0, 0, 0, 0, 0);
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  800c2d:	6a 00                	push   $0x0
  800c2f:	6a 00                	push   $0x0
  800c31:	6a 00                	push   $0x0
  800c33:	6a 00                	push   $0x0
  800c35:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c3a:	ba 00 00 00 00       	mov    $0x0,%edx
  800c3f:	b8 01 00 00 00       	mov    $0x1,%eax
  800c44:	e8 6b ff ff ff       	call   800bb4 <syscall>
}
  800c49:	c9                   	leave  
  800c4a:	c3                   	ret    

00800c4b <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800c4b:	55                   	push   %ebp
  800c4c:	89 e5                	mov    %esp,%ebp
  800c4e:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  800c51:	6a 00                	push   $0x0
  800c53:	6a 00                	push   $0x0
  800c55:	6a 00                	push   $0x0
  800c57:	6a 00                	push   $0x0
  800c59:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c5c:	ba 01 00 00 00       	mov    $0x1,%edx
  800c61:	b8 03 00 00 00       	mov    $0x3,%eax
  800c66:	e8 49 ff ff ff       	call   800bb4 <syscall>
}
  800c6b:	c9                   	leave  
  800c6c:	c3                   	ret    

00800c6d <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c6d:	55                   	push   %ebp
  800c6e:	89 e5                	mov    %esp,%ebp
  800c70:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_getenvid, 0, 0, 0, 0, 0, 0);
	return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  800c73:	6a 00                	push   $0x0
  800c75:	6a 00                	push   $0x0
  800c77:	6a 00                	push   $0x0
  800c79:	6a 00                	push   $0x0
  800c7b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c80:	ba 00 00 00 00       	mov    $0x0,%edx
  800c85:	b8 02 00 00 00       	mov    $0x2,%eax
  800c8a:	e8 25 ff ff ff       	call   800bb4 <syscall>
}
  800c8f:	c9                   	leave  
  800c90:	c3                   	ret    

00800c91 <sys_yield>:

void
sys_yield(void)
{
  800c91:	55                   	push   %ebp
  800c92:	89 e5                	mov    %esp,%ebp
  800c94:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  800c97:	6a 00                	push   $0x0
  800c99:	6a 00                	push   $0x0
  800c9b:	6a 00                	push   $0x0
  800c9d:	6a 00                	push   $0x0
  800c9f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ca4:	ba 00 00 00 00       	mov    $0x0,%edx
  800ca9:	b8 0b 00 00 00       	mov    $0xb,%eax
  800cae:	e8 01 ff ff ff       	call   800bb4 <syscall>
  800cb3:	83 c4 10             	add    $0x10,%esp
}
  800cb6:	c9                   	leave  
  800cb7:	c3                   	ret    

00800cb8 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800cb8:	55                   	push   %ebp
  800cb9:	89 e5                	mov    %esp,%ebp
  800cbb:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  800cbe:	6a 00                	push   $0x0
  800cc0:	6a 00                	push   $0x0
  800cc2:	ff 75 10             	pushl  0x10(%ebp)
  800cc5:	ff 75 0c             	pushl  0xc(%ebp)
  800cc8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ccb:	ba 01 00 00 00       	mov    $0x1,%edx
  800cd0:	b8 04 00 00 00       	mov    $0x4,%eax
  800cd5:	e8 da fe ff ff       	call   800bb4 <syscall>
}
  800cda:	c9                   	leave  
  800cdb:	c3                   	ret    

00800cdc <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800cdc:	55                   	push   %ebp
  800cdd:	89 e5                	mov    %esp,%ebp
  800cdf:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
  800ce2:	ff 75 18             	pushl  0x18(%ebp)
  800ce5:	ff 75 14             	pushl  0x14(%ebp)
  800ce8:	ff 75 10             	pushl  0x10(%ebp)
  800ceb:	ff 75 0c             	pushl  0xc(%ebp)
  800cee:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800cf1:	ba 01 00 00 00       	mov    $0x1,%edx
  800cf6:	b8 05 00 00 00       	mov    $0x5,%eax
  800cfb:	e8 b4 fe ff ff       	call   800bb4 <syscall>
}
  800d00:	c9                   	leave  
  800d01:	c3                   	ret    

00800d02 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800d02:	55                   	push   %ebp
  800d03:	89 e5                	mov    %esp,%ebp
  800d05:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  800d08:	6a 00                	push   $0x0
  800d0a:	6a 00                	push   $0x0
  800d0c:	6a 00                	push   $0x0
  800d0e:	ff 75 0c             	pushl  0xc(%ebp)
  800d11:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d14:	ba 01 00 00 00       	mov    $0x1,%edx
  800d19:	b8 06 00 00 00       	mov    $0x6,%eax
  800d1e:	e8 91 fe ff ff       	call   800bb4 <syscall>
}
  800d23:	c9                   	leave  
  800d24:	c3                   	ret    

00800d25 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800d25:	55                   	push   %ebp
  800d26:	89 e5                	mov    %esp,%ebp
  800d28:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  800d2b:	6a 00                	push   $0x0
  800d2d:	6a 00                	push   $0x0
  800d2f:	6a 00                	push   $0x0
  800d31:	ff 75 0c             	pushl  0xc(%ebp)
  800d34:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d37:	ba 01 00 00 00       	mov    $0x1,%edx
  800d3c:	b8 08 00 00 00       	mov    $0x8,%eax
  800d41:	e8 6e fe ff ff       	call   800bb4 <syscall>
}
  800d46:	c9                   	leave  
  800d47:	c3                   	ret    

00800d48 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800d48:	55                   	push   %ebp
  800d49:	89 e5                	mov    %esp,%ebp
  800d4b:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
  800d4e:	6a 00                	push   $0x0
  800d50:	6a 00                	push   $0x0
  800d52:	6a 00                	push   $0x0
  800d54:	ff 75 0c             	pushl  0xc(%ebp)
  800d57:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d5a:	ba 01 00 00 00       	mov    $0x1,%edx
  800d5f:	b8 09 00 00 00       	mov    $0x9,%eax
  800d64:	e8 4b fe ff ff       	call   800bb4 <syscall>
}
  800d69:	c9                   	leave  
  800d6a:	c3                   	ret    

00800d6b <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d6b:	55                   	push   %ebp
  800d6c:	89 e5                	mov    %esp,%ebp
  800d6e:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  800d71:	6a 00                	push   $0x0
  800d73:	6a 00                	push   $0x0
  800d75:	6a 00                	push   $0x0
  800d77:	ff 75 0c             	pushl  0xc(%ebp)
  800d7a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d7d:	ba 01 00 00 00       	mov    $0x1,%edx
  800d82:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d87:	e8 28 fe ff ff       	call   800bb4 <syscall>
}
  800d8c:	c9                   	leave  
  800d8d:	c3                   	ret    

00800d8e <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d8e:	55                   	push   %ebp
  800d8f:	89 e5                	mov    %esp,%ebp
  800d91:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  800d94:	6a 00                	push   $0x0
  800d96:	ff 75 14             	pushl  0x14(%ebp)
  800d99:	ff 75 10             	pushl  0x10(%ebp)
  800d9c:	ff 75 0c             	pushl  0xc(%ebp)
  800d9f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800da2:	ba 00 00 00 00       	mov    $0x0,%edx
  800da7:	b8 0c 00 00 00       	mov    $0xc,%eax
  800dac:	e8 03 fe ff ff       	call   800bb4 <syscall>
}
  800db1:	c9                   	leave  
  800db2:	c3                   	ret    

00800db3 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800db3:	55                   	push   %ebp
  800db4:	89 e5                	mov    %esp,%ebp
  800db6:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  800db9:	6a 00                	push   $0x0
  800dbb:	6a 00                	push   $0x0
  800dbd:	6a 00                	push   $0x0
  800dbf:	6a 00                	push   $0x0
  800dc1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800dc4:	ba 01 00 00 00       	mov    $0x1,%edx
  800dc9:	b8 0d 00 00 00       	mov    $0xd,%eax
  800dce:	e8 e1 fd ff ff       	call   800bb4 <syscall>
}
  800dd3:	c9                   	leave  
  800dd4:	c3                   	ret    

00800dd5 <sys_set_priority>:

int
sys_set_priority(envid_t envid, uint32_t new_priority)
{
  800dd5:	55                   	push   %ebp
  800dd6:	89 e5                	mov    %esp,%ebp
  800dd8:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_set_priority, 0, envid, new_priority, 0, 0, 0);
  800ddb:	6a 00                	push   $0x0
  800ddd:	6a 00                	push   $0x0
  800ddf:	6a 00                	push   $0x0
  800de1:	ff 75 0c             	pushl  0xc(%ebp)
  800de4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800de7:	ba 00 00 00 00       	mov    $0x0,%edx
  800dec:	b8 0e 00 00 00       	mov    $0xe,%eax
  800df1:	e8 be fd ff ff       	call   800bb4 <syscall>
}
  800df6:	c9                   	leave  
  800df7:	c3                   	ret    

00800df8 <sys_exec>:

int
sys_exec(uint32_t eip, uint32_t esp, void * ph, uint32_t elf_phnum)
{
  800df8:	55                   	push   %ebp
  800df9:	89 e5                	mov    %esp,%ebp
  800dfb:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_exec, 0, eip, esp, (uint32_t)ph, elf_phnum, 0);
  800dfe:	6a 00                	push   $0x0
  800e00:	ff 75 14             	pushl  0x14(%ebp)
  800e03:	ff 75 10             	pushl  0x10(%ebp)
  800e06:	ff 75 0c             	pushl  0xc(%ebp)
  800e09:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e0c:	ba 00 00 00 00       	mov    $0x0,%edx
  800e11:	b8 0f 00 00 00       	mov    $0xf,%eax
  800e16:	e8 99 fd ff ff       	call   800bb4 <syscall>
} 
  800e1b:	c9                   	leave  
  800e1c:	c3                   	ret    

00800e1d <sys_join>:

// thread:
int
sys_join(envid_t envid)
{
  800e1d:	55                   	push   %ebp
  800e1e:	89 e5                	mov    %esp,%ebp
  800e20:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_join, 0, envid, 0, 0, 0, 0);
  800e23:	6a 00                	push   $0x0
  800e25:	6a 00                	push   $0x0
  800e27:	6a 00                	push   $0x0
  800e29:	6a 00                	push   $0x0
  800e2b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e2e:	ba 00 00 00 00       	mov    $0x0,%edx
  800e33:	b8 11 00 00 00       	mov    $0x11,%eax
  800e38:	e8 77 fd ff ff       	call   800bb4 <syscall>
}
  800e3d:	c9                   	leave  
  800e3e:	c3                   	ret    

00800e3f <sys_getpid>:

envid_t
sys_getpid(void)
{
  800e3f:	55                   	push   %ebp
  800e40:	89 e5                	mov    %esp,%ebp
  800e42:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_getpid, 0, 0, 0, 0, 0, 0);
  800e45:	6a 00                	push   $0x0
  800e47:	6a 00                	push   $0x0
  800e49:	6a 00                	push   $0x0
  800e4b:	6a 00                	push   $0x0
  800e4d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e52:	ba 00 00 00 00       	mov    $0x0,%edx
  800e57:	b8 10 00 00 00       	mov    $0x10,%eax
  800e5c:	e8 53 fd ff ff       	call   800bb4 <syscall>
  800e61:	c9                   	leave  
  800e62:	c3                   	ret    
	...

00800e64 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800e64:	55                   	push   %ebp
  800e65:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800e67:	8b 45 08             	mov    0x8(%ebp),%eax
  800e6a:	05 00 00 00 30       	add    $0x30000000,%eax
  800e6f:	c1 e8 0c             	shr    $0xc,%eax
}
  800e72:	c9                   	leave  
  800e73:	c3                   	ret    

00800e74 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800e74:	55                   	push   %ebp
  800e75:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800e77:	ff 75 08             	pushl  0x8(%ebp)
  800e7a:	e8 e5 ff ff ff       	call   800e64 <fd2num>
  800e7f:	83 c4 04             	add    $0x4,%esp
  800e82:	05 20 00 0d 00       	add    $0xd0020,%eax
  800e87:	c1 e0 0c             	shl    $0xc,%eax
}
  800e8a:	c9                   	leave  
  800e8b:	c3                   	ret    

00800e8c <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800e8c:	55                   	push   %ebp
  800e8d:	89 e5                	mov    %esp,%ebp
  800e8f:	53                   	push   %ebx
  800e90:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800e93:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  800e98:	a8 01                	test   $0x1,%al
  800e9a:	74 34                	je     800ed0 <fd_alloc+0x44>
  800e9c:	a1 00 00 74 ef       	mov    0xef740000,%eax
  800ea1:	a8 01                	test   $0x1,%al
  800ea3:	74 32                	je     800ed7 <fd_alloc+0x4b>
  800ea5:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
  800eaa:	89 c1                	mov    %eax,%ecx
  800eac:	89 c2                	mov    %eax,%edx
  800eae:	c1 ea 16             	shr    $0x16,%edx
  800eb1:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800eb8:	f6 c2 01             	test   $0x1,%dl
  800ebb:	74 1f                	je     800edc <fd_alloc+0x50>
  800ebd:	89 c2                	mov    %eax,%edx
  800ebf:	c1 ea 0c             	shr    $0xc,%edx
  800ec2:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800ec9:	f6 c2 01             	test   $0x1,%dl
  800ecc:	75 17                	jne    800ee5 <fd_alloc+0x59>
  800ece:	eb 0c                	jmp    800edc <fd_alloc+0x50>
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  800ed0:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
  800ed5:	eb 05                	jmp    800edc <fd_alloc+0x50>
  800ed7:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
  800edc:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  800ede:	b8 00 00 00 00       	mov    $0x0,%eax
  800ee3:	eb 17                	jmp    800efc <fd_alloc+0x70>
  800ee5:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800eea:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800eef:	75 b9                	jne    800eaa <fd_alloc+0x1e>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800ef1:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  800ef7:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800efc:	5b                   	pop    %ebx
  800efd:	c9                   	leave  
  800efe:	c3                   	ret    

00800eff <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800eff:	55                   	push   %ebp
  800f00:	89 e5                	mov    %esp,%ebp
  800f02:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800f05:	83 f8 1f             	cmp    $0x1f,%eax
  800f08:	77 36                	ja     800f40 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800f0a:	05 00 00 0d 00       	add    $0xd0000,%eax
  800f0f:	c1 e0 0c             	shl    $0xc,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800f12:	89 c2                	mov    %eax,%edx
  800f14:	c1 ea 16             	shr    $0x16,%edx
  800f17:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800f1e:	f6 c2 01             	test   $0x1,%dl
  800f21:	74 24                	je     800f47 <fd_lookup+0x48>
  800f23:	89 c2                	mov    %eax,%edx
  800f25:	c1 ea 0c             	shr    $0xc,%edx
  800f28:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800f2f:	f6 c2 01             	test   $0x1,%dl
  800f32:	74 1a                	je     800f4e <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800f34:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f37:	89 02                	mov    %eax,(%edx)
	return 0;
  800f39:	b8 00 00 00 00       	mov    $0x0,%eax
  800f3e:	eb 13                	jmp    800f53 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800f40:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f45:	eb 0c                	jmp    800f53 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800f47:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f4c:	eb 05                	jmp    800f53 <fd_lookup+0x54>
  800f4e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800f53:	c9                   	leave  
  800f54:	c3                   	ret    

00800f55 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800f55:	55                   	push   %ebp
  800f56:	89 e5                	mov    %esp,%ebp
  800f58:	53                   	push   %ebx
  800f59:	83 ec 04             	sub    $0x4,%esp
  800f5c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f5f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  800f62:	39 0d 04 30 80 00    	cmp    %ecx,0x803004
  800f68:	74 0d                	je     800f77 <dev_lookup+0x22>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800f6a:	b8 00 00 00 00       	mov    $0x0,%eax
  800f6f:	eb 14                	jmp    800f85 <dev_lookup+0x30>
		if (devtab[i]->dev_id == dev_id) {
  800f71:	39 0a                	cmp    %ecx,(%edx)
  800f73:	75 10                	jne    800f85 <dev_lookup+0x30>
  800f75:	eb 05                	jmp    800f7c <dev_lookup+0x27>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800f77:	ba 04 30 80 00       	mov    $0x803004,%edx
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
  800f7c:	89 13                	mov    %edx,(%ebx)
			return 0;
  800f7e:	b8 00 00 00 00       	mov    $0x0,%eax
  800f83:	eb 31                	jmp    800fb6 <dev_lookup+0x61>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800f85:	40                   	inc    %eax
  800f86:	8b 14 85 0c 24 80 00 	mov    0x80240c(,%eax,4),%edx
  800f8d:	85 d2                	test   %edx,%edx
  800f8f:	75 e0                	jne    800f71 <dev_lookup+0x1c>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800f91:	a1 20 60 80 00       	mov    0x806020,%eax
  800f96:	8b 40 48             	mov    0x48(%eax),%eax
  800f99:	83 ec 04             	sub    $0x4,%esp
  800f9c:	51                   	push   %ecx
  800f9d:	50                   	push   %eax
  800f9e:	68 8c 23 80 00       	push   $0x80238c
  800fa3:	e8 d8 f2 ff ff       	call   800280 <cprintf>
	*dev = 0;
  800fa8:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  800fae:	83 c4 10             	add    $0x10,%esp
  800fb1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800fb6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800fb9:	c9                   	leave  
  800fba:	c3                   	ret    

00800fbb <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800fbb:	55                   	push   %ebp
  800fbc:	89 e5                	mov    %esp,%ebp
  800fbe:	56                   	push   %esi
  800fbf:	53                   	push   %ebx
  800fc0:	83 ec 20             	sub    $0x20,%esp
  800fc3:	8b 75 08             	mov    0x8(%ebp),%esi
  800fc6:	8a 45 0c             	mov    0xc(%ebp),%al
  800fc9:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800fcc:	56                   	push   %esi
  800fcd:	e8 92 fe ff ff       	call   800e64 <fd2num>
  800fd2:	8d 55 f4             	lea    -0xc(%ebp),%edx
  800fd5:	89 14 24             	mov    %edx,(%esp)
  800fd8:	50                   	push   %eax
  800fd9:	e8 21 ff ff ff       	call   800eff <fd_lookup>
  800fde:	89 c3                	mov    %eax,%ebx
  800fe0:	83 c4 08             	add    $0x8,%esp
  800fe3:	85 c0                	test   %eax,%eax
  800fe5:	78 05                	js     800fec <fd_close+0x31>
	    || fd != fd2)
  800fe7:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800fea:	74 0d                	je     800ff9 <fd_close+0x3e>
		return (must_exist ? r : 0);
  800fec:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  800ff0:	75 48                	jne    80103a <fd_close+0x7f>
  800ff2:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ff7:	eb 41                	jmp    80103a <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800ff9:	83 ec 08             	sub    $0x8,%esp
  800ffc:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800fff:	50                   	push   %eax
  801000:	ff 36                	pushl  (%esi)
  801002:	e8 4e ff ff ff       	call   800f55 <dev_lookup>
  801007:	89 c3                	mov    %eax,%ebx
  801009:	83 c4 10             	add    $0x10,%esp
  80100c:	85 c0                	test   %eax,%eax
  80100e:	78 1c                	js     80102c <fd_close+0x71>
		if (dev->dev_close)
  801010:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801013:	8b 40 10             	mov    0x10(%eax),%eax
  801016:	85 c0                	test   %eax,%eax
  801018:	74 0d                	je     801027 <fd_close+0x6c>
			r = (*dev->dev_close)(fd);
  80101a:	83 ec 0c             	sub    $0xc,%esp
  80101d:	56                   	push   %esi
  80101e:	ff d0                	call   *%eax
  801020:	89 c3                	mov    %eax,%ebx
  801022:	83 c4 10             	add    $0x10,%esp
  801025:	eb 05                	jmp    80102c <fd_close+0x71>
		else
			r = 0;
  801027:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  80102c:	83 ec 08             	sub    $0x8,%esp
  80102f:	56                   	push   %esi
  801030:	6a 00                	push   $0x0
  801032:	e8 cb fc ff ff       	call   800d02 <sys_page_unmap>
	return r;
  801037:	83 c4 10             	add    $0x10,%esp
}
  80103a:	89 d8                	mov    %ebx,%eax
  80103c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80103f:	5b                   	pop    %ebx
  801040:	5e                   	pop    %esi
  801041:	c9                   	leave  
  801042:	c3                   	ret    

00801043 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801043:	55                   	push   %ebp
  801044:	89 e5                	mov    %esp,%ebp
  801046:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801049:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80104c:	50                   	push   %eax
  80104d:	ff 75 08             	pushl  0x8(%ebp)
  801050:	e8 aa fe ff ff       	call   800eff <fd_lookup>
  801055:	83 c4 08             	add    $0x8,%esp
  801058:	85 c0                	test   %eax,%eax
  80105a:	78 10                	js     80106c <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  80105c:	83 ec 08             	sub    $0x8,%esp
  80105f:	6a 01                	push   $0x1
  801061:	ff 75 f4             	pushl  -0xc(%ebp)
  801064:	e8 52 ff ff ff       	call   800fbb <fd_close>
  801069:	83 c4 10             	add    $0x10,%esp
}
  80106c:	c9                   	leave  
  80106d:	c3                   	ret    

0080106e <close_all>:

void
close_all(void)
{
  80106e:	55                   	push   %ebp
  80106f:	89 e5                	mov    %esp,%ebp
  801071:	53                   	push   %ebx
  801072:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801075:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80107a:	83 ec 0c             	sub    $0xc,%esp
  80107d:	53                   	push   %ebx
  80107e:	e8 c0 ff ff ff       	call   801043 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801083:	43                   	inc    %ebx
  801084:	83 c4 10             	add    $0x10,%esp
  801087:	83 fb 20             	cmp    $0x20,%ebx
  80108a:	75 ee                	jne    80107a <close_all+0xc>
		close(i);
}
  80108c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80108f:	c9                   	leave  
  801090:	c3                   	ret    

00801091 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801091:	55                   	push   %ebp
  801092:	89 e5                	mov    %esp,%ebp
  801094:	57                   	push   %edi
  801095:	56                   	push   %esi
  801096:	53                   	push   %ebx
  801097:	83 ec 2c             	sub    $0x2c,%esp
  80109a:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80109d:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8010a0:	50                   	push   %eax
  8010a1:	ff 75 08             	pushl  0x8(%ebp)
  8010a4:	e8 56 fe ff ff       	call   800eff <fd_lookup>
  8010a9:	89 c3                	mov    %eax,%ebx
  8010ab:	83 c4 08             	add    $0x8,%esp
  8010ae:	85 c0                	test   %eax,%eax
  8010b0:	0f 88 c0 00 00 00    	js     801176 <dup+0xe5>
		return r;
	close(newfdnum);
  8010b6:	83 ec 0c             	sub    $0xc,%esp
  8010b9:	57                   	push   %edi
  8010ba:	e8 84 ff ff ff       	call   801043 <close>

	newfd = INDEX2FD(newfdnum);
  8010bf:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  8010c5:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  8010c8:	83 c4 04             	add    $0x4,%esp
  8010cb:	ff 75 e4             	pushl  -0x1c(%ebp)
  8010ce:	e8 a1 fd ff ff       	call   800e74 <fd2data>
  8010d3:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  8010d5:	89 34 24             	mov    %esi,(%esp)
  8010d8:	e8 97 fd ff ff       	call   800e74 <fd2data>
  8010dd:	83 c4 10             	add    $0x10,%esp
  8010e0:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8010e3:	89 d8                	mov    %ebx,%eax
  8010e5:	c1 e8 16             	shr    $0x16,%eax
  8010e8:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8010ef:	a8 01                	test   $0x1,%al
  8010f1:	74 37                	je     80112a <dup+0x99>
  8010f3:	89 d8                	mov    %ebx,%eax
  8010f5:	c1 e8 0c             	shr    $0xc,%eax
  8010f8:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8010ff:	f6 c2 01             	test   $0x1,%dl
  801102:	74 26                	je     80112a <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801104:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80110b:	83 ec 0c             	sub    $0xc,%esp
  80110e:	25 07 0e 00 00       	and    $0xe07,%eax
  801113:	50                   	push   %eax
  801114:	ff 75 d4             	pushl  -0x2c(%ebp)
  801117:	6a 00                	push   $0x0
  801119:	53                   	push   %ebx
  80111a:	6a 00                	push   $0x0
  80111c:	e8 bb fb ff ff       	call   800cdc <sys_page_map>
  801121:	89 c3                	mov    %eax,%ebx
  801123:	83 c4 20             	add    $0x20,%esp
  801126:	85 c0                	test   %eax,%eax
  801128:	78 2d                	js     801157 <dup+0xc6>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80112a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80112d:	89 c2                	mov    %eax,%edx
  80112f:	c1 ea 0c             	shr    $0xc,%edx
  801132:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801139:	83 ec 0c             	sub    $0xc,%esp
  80113c:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  801142:	52                   	push   %edx
  801143:	56                   	push   %esi
  801144:	6a 00                	push   $0x0
  801146:	50                   	push   %eax
  801147:	6a 00                	push   $0x0
  801149:	e8 8e fb ff ff       	call   800cdc <sys_page_map>
  80114e:	89 c3                	mov    %eax,%ebx
  801150:	83 c4 20             	add    $0x20,%esp
  801153:	85 c0                	test   %eax,%eax
  801155:	79 1d                	jns    801174 <dup+0xe3>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801157:	83 ec 08             	sub    $0x8,%esp
  80115a:	56                   	push   %esi
  80115b:	6a 00                	push   $0x0
  80115d:	e8 a0 fb ff ff       	call   800d02 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801162:	83 c4 08             	add    $0x8,%esp
  801165:	ff 75 d4             	pushl  -0x2c(%ebp)
  801168:	6a 00                	push   $0x0
  80116a:	e8 93 fb ff ff       	call   800d02 <sys_page_unmap>
	return r;
  80116f:	83 c4 10             	add    $0x10,%esp
  801172:	eb 02                	jmp    801176 <dup+0xe5>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  801174:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  801176:	89 d8                	mov    %ebx,%eax
  801178:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80117b:	5b                   	pop    %ebx
  80117c:	5e                   	pop    %esi
  80117d:	5f                   	pop    %edi
  80117e:	c9                   	leave  
  80117f:	c3                   	ret    

00801180 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801180:	55                   	push   %ebp
  801181:	89 e5                	mov    %esp,%ebp
  801183:	53                   	push   %ebx
  801184:	83 ec 14             	sub    $0x14,%esp
  801187:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80118a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80118d:	50                   	push   %eax
  80118e:	53                   	push   %ebx
  80118f:	e8 6b fd ff ff       	call   800eff <fd_lookup>
  801194:	83 c4 08             	add    $0x8,%esp
  801197:	85 c0                	test   %eax,%eax
  801199:	78 67                	js     801202 <read+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80119b:	83 ec 08             	sub    $0x8,%esp
  80119e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011a1:	50                   	push   %eax
  8011a2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011a5:	ff 30                	pushl  (%eax)
  8011a7:	e8 a9 fd ff ff       	call   800f55 <dev_lookup>
  8011ac:	83 c4 10             	add    $0x10,%esp
  8011af:	85 c0                	test   %eax,%eax
  8011b1:	78 4f                	js     801202 <read+0x82>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8011b3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011b6:	8b 50 08             	mov    0x8(%eax),%edx
  8011b9:	83 e2 03             	and    $0x3,%edx
  8011bc:	83 fa 01             	cmp    $0x1,%edx
  8011bf:	75 21                	jne    8011e2 <read+0x62>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8011c1:	a1 20 60 80 00       	mov    0x806020,%eax
  8011c6:	8b 40 48             	mov    0x48(%eax),%eax
  8011c9:	83 ec 04             	sub    $0x4,%esp
  8011cc:	53                   	push   %ebx
  8011cd:	50                   	push   %eax
  8011ce:	68 d0 23 80 00       	push   $0x8023d0
  8011d3:	e8 a8 f0 ff ff       	call   800280 <cprintf>
		return -E_INVAL;
  8011d8:	83 c4 10             	add    $0x10,%esp
  8011db:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8011e0:	eb 20                	jmp    801202 <read+0x82>
	}
	if (!dev->dev_read)
  8011e2:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8011e5:	8b 52 08             	mov    0x8(%edx),%edx
  8011e8:	85 d2                	test   %edx,%edx
  8011ea:	74 11                	je     8011fd <read+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8011ec:	83 ec 04             	sub    $0x4,%esp
  8011ef:	ff 75 10             	pushl  0x10(%ebp)
  8011f2:	ff 75 0c             	pushl  0xc(%ebp)
  8011f5:	50                   	push   %eax
  8011f6:	ff d2                	call   *%edx
  8011f8:	83 c4 10             	add    $0x10,%esp
  8011fb:	eb 05                	jmp    801202 <read+0x82>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8011fd:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  801202:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801205:	c9                   	leave  
  801206:	c3                   	ret    

00801207 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801207:	55                   	push   %ebp
  801208:	89 e5                	mov    %esp,%ebp
  80120a:	57                   	push   %edi
  80120b:	56                   	push   %esi
  80120c:	53                   	push   %ebx
  80120d:	83 ec 0c             	sub    $0xc,%esp
  801210:	8b 7d 08             	mov    0x8(%ebp),%edi
  801213:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801216:	85 f6                	test   %esi,%esi
  801218:	74 31                	je     80124b <readn+0x44>
  80121a:	b8 00 00 00 00       	mov    $0x0,%eax
  80121f:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = read(fdnum, (char*)buf + tot, n - tot);
  801224:	83 ec 04             	sub    $0x4,%esp
  801227:	89 f2                	mov    %esi,%edx
  801229:	29 c2                	sub    %eax,%edx
  80122b:	52                   	push   %edx
  80122c:	03 45 0c             	add    0xc(%ebp),%eax
  80122f:	50                   	push   %eax
  801230:	57                   	push   %edi
  801231:	e8 4a ff ff ff       	call   801180 <read>
		if (m < 0)
  801236:	83 c4 10             	add    $0x10,%esp
  801239:	85 c0                	test   %eax,%eax
  80123b:	78 17                	js     801254 <readn+0x4d>
			return m;
		if (m == 0)
  80123d:	85 c0                	test   %eax,%eax
  80123f:	74 11                	je     801252 <readn+0x4b>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801241:	01 c3                	add    %eax,%ebx
  801243:	89 d8                	mov    %ebx,%eax
  801245:	39 f3                	cmp    %esi,%ebx
  801247:	72 db                	jb     801224 <readn+0x1d>
  801249:	eb 09                	jmp    801254 <readn+0x4d>
  80124b:	b8 00 00 00 00       	mov    $0x0,%eax
  801250:	eb 02                	jmp    801254 <readn+0x4d>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  801252:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  801254:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801257:	5b                   	pop    %ebx
  801258:	5e                   	pop    %esi
  801259:	5f                   	pop    %edi
  80125a:	c9                   	leave  
  80125b:	c3                   	ret    

0080125c <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80125c:	55                   	push   %ebp
  80125d:	89 e5                	mov    %esp,%ebp
  80125f:	53                   	push   %ebx
  801260:	83 ec 14             	sub    $0x14,%esp
  801263:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801266:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801269:	50                   	push   %eax
  80126a:	53                   	push   %ebx
  80126b:	e8 8f fc ff ff       	call   800eff <fd_lookup>
  801270:	83 c4 08             	add    $0x8,%esp
  801273:	85 c0                	test   %eax,%eax
  801275:	78 62                	js     8012d9 <write+0x7d>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801277:	83 ec 08             	sub    $0x8,%esp
  80127a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80127d:	50                   	push   %eax
  80127e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801281:	ff 30                	pushl  (%eax)
  801283:	e8 cd fc ff ff       	call   800f55 <dev_lookup>
  801288:	83 c4 10             	add    $0x10,%esp
  80128b:	85 c0                	test   %eax,%eax
  80128d:	78 4a                	js     8012d9 <write+0x7d>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80128f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801292:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801296:	75 21                	jne    8012b9 <write+0x5d>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801298:	a1 20 60 80 00       	mov    0x806020,%eax
  80129d:	8b 40 48             	mov    0x48(%eax),%eax
  8012a0:	83 ec 04             	sub    $0x4,%esp
  8012a3:	53                   	push   %ebx
  8012a4:	50                   	push   %eax
  8012a5:	68 ec 23 80 00       	push   $0x8023ec
  8012aa:	e8 d1 ef ff ff       	call   800280 <cprintf>
		return -E_INVAL;
  8012af:	83 c4 10             	add    $0x10,%esp
  8012b2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012b7:	eb 20                	jmp    8012d9 <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8012b9:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8012bc:	8b 52 0c             	mov    0xc(%edx),%edx
  8012bf:	85 d2                	test   %edx,%edx
  8012c1:	74 11                	je     8012d4 <write+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8012c3:	83 ec 04             	sub    $0x4,%esp
  8012c6:	ff 75 10             	pushl  0x10(%ebp)
  8012c9:	ff 75 0c             	pushl  0xc(%ebp)
  8012cc:	50                   	push   %eax
  8012cd:	ff d2                	call   *%edx
  8012cf:	83 c4 10             	add    $0x10,%esp
  8012d2:	eb 05                	jmp    8012d9 <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8012d4:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  8012d9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012dc:	c9                   	leave  
  8012dd:	c3                   	ret    

008012de <seek>:

int
seek(int fdnum, off_t offset)
{
  8012de:	55                   	push   %ebp
  8012df:	89 e5                	mov    %esp,%ebp
  8012e1:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8012e4:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8012e7:	50                   	push   %eax
  8012e8:	ff 75 08             	pushl  0x8(%ebp)
  8012eb:	e8 0f fc ff ff       	call   800eff <fd_lookup>
  8012f0:	83 c4 08             	add    $0x8,%esp
  8012f3:	85 c0                	test   %eax,%eax
  8012f5:	78 0e                	js     801305 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8012f7:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8012fa:	8b 55 0c             	mov    0xc(%ebp),%edx
  8012fd:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801300:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801305:	c9                   	leave  
  801306:	c3                   	ret    

00801307 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801307:	55                   	push   %ebp
  801308:	89 e5                	mov    %esp,%ebp
  80130a:	53                   	push   %ebx
  80130b:	83 ec 14             	sub    $0x14,%esp
  80130e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801311:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801314:	50                   	push   %eax
  801315:	53                   	push   %ebx
  801316:	e8 e4 fb ff ff       	call   800eff <fd_lookup>
  80131b:	83 c4 08             	add    $0x8,%esp
  80131e:	85 c0                	test   %eax,%eax
  801320:	78 5f                	js     801381 <ftruncate+0x7a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801322:	83 ec 08             	sub    $0x8,%esp
  801325:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801328:	50                   	push   %eax
  801329:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80132c:	ff 30                	pushl  (%eax)
  80132e:	e8 22 fc ff ff       	call   800f55 <dev_lookup>
  801333:	83 c4 10             	add    $0x10,%esp
  801336:	85 c0                	test   %eax,%eax
  801338:	78 47                	js     801381 <ftruncate+0x7a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80133a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80133d:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801341:	75 21                	jne    801364 <ftruncate+0x5d>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801343:	a1 20 60 80 00       	mov    0x806020,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801348:	8b 40 48             	mov    0x48(%eax),%eax
  80134b:	83 ec 04             	sub    $0x4,%esp
  80134e:	53                   	push   %ebx
  80134f:	50                   	push   %eax
  801350:	68 ac 23 80 00       	push   $0x8023ac
  801355:	e8 26 ef ff ff       	call   800280 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80135a:	83 c4 10             	add    $0x10,%esp
  80135d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801362:	eb 1d                	jmp    801381 <ftruncate+0x7a>
	}
	if (!dev->dev_trunc)
  801364:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801367:	8b 52 18             	mov    0x18(%edx),%edx
  80136a:	85 d2                	test   %edx,%edx
  80136c:	74 0e                	je     80137c <ftruncate+0x75>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80136e:	83 ec 08             	sub    $0x8,%esp
  801371:	ff 75 0c             	pushl  0xc(%ebp)
  801374:	50                   	push   %eax
  801375:	ff d2                	call   *%edx
  801377:	83 c4 10             	add    $0x10,%esp
  80137a:	eb 05                	jmp    801381 <ftruncate+0x7a>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80137c:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  801381:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801384:	c9                   	leave  
  801385:	c3                   	ret    

00801386 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801386:	55                   	push   %ebp
  801387:	89 e5                	mov    %esp,%ebp
  801389:	53                   	push   %ebx
  80138a:	83 ec 14             	sub    $0x14,%esp
  80138d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801390:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801393:	50                   	push   %eax
  801394:	ff 75 08             	pushl  0x8(%ebp)
  801397:	e8 63 fb ff ff       	call   800eff <fd_lookup>
  80139c:	83 c4 08             	add    $0x8,%esp
  80139f:	85 c0                	test   %eax,%eax
  8013a1:	78 52                	js     8013f5 <fstat+0x6f>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013a3:	83 ec 08             	sub    $0x8,%esp
  8013a6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013a9:	50                   	push   %eax
  8013aa:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013ad:	ff 30                	pushl  (%eax)
  8013af:	e8 a1 fb ff ff       	call   800f55 <dev_lookup>
  8013b4:	83 c4 10             	add    $0x10,%esp
  8013b7:	85 c0                	test   %eax,%eax
  8013b9:	78 3a                	js     8013f5 <fstat+0x6f>
		return r;
	if (!dev->dev_stat)
  8013bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013be:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8013c2:	74 2c                	je     8013f0 <fstat+0x6a>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8013c4:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8013c7:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8013ce:	00 00 00 
	stat->st_isdir = 0;
  8013d1:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8013d8:	00 00 00 
	stat->st_dev = dev;
  8013db:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8013e1:	83 ec 08             	sub    $0x8,%esp
  8013e4:	53                   	push   %ebx
  8013e5:	ff 75 f0             	pushl  -0x10(%ebp)
  8013e8:	ff 50 14             	call   *0x14(%eax)
  8013eb:	83 c4 10             	add    $0x10,%esp
  8013ee:	eb 05                	jmp    8013f5 <fstat+0x6f>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8013f0:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8013f5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013f8:	c9                   	leave  
  8013f9:	c3                   	ret    

008013fa <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8013fa:	55                   	push   %ebp
  8013fb:	89 e5                	mov    %esp,%ebp
  8013fd:	56                   	push   %esi
  8013fe:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8013ff:	83 ec 08             	sub    $0x8,%esp
  801402:	6a 00                	push   $0x0
  801404:	ff 75 08             	pushl  0x8(%ebp)
  801407:	e8 78 01 00 00       	call   801584 <open>
  80140c:	89 c3                	mov    %eax,%ebx
  80140e:	83 c4 10             	add    $0x10,%esp
  801411:	85 c0                	test   %eax,%eax
  801413:	78 1b                	js     801430 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801415:	83 ec 08             	sub    $0x8,%esp
  801418:	ff 75 0c             	pushl  0xc(%ebp)
  80141b:	50                   	push   %eax
  80141c:	e8 65 ff ff ff       	call   801386 <fstat>
  801421:	89 c6                	mov    %eax,%esi
	close(fd);
  801423:	89 1c 24             	mov    %ebx,(%esp)
  801426:	e8 18 fc ff ff       	call   801043 <close>
	return r;
  80142b:	83 c4 10             	add    $0x10,%esp
  80142e:	89 f3                	mov    %esi,%ebx
}
  801430:	89 d8                	mov    %ebx,%eax
  801432:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801435:	5b                   	pop    %ebx
  801436:	5e                   	pop    %esi
  801437:	c9                   	leave  
  801438:	c3                   	ret    
  801439:	00 00                	add    %al,(%eax)
	...

0080143c <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80143c:	55                   	push   %ebp
  80143d:	89 e5                	mov    %esp,%ebp
  80143f:	56                   	push   %esi
  801440:	53                   	push   %ebx
  801441:	89 c3                	mov    %eax,%ebx
  801443:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  801445:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  80144c:	75 12                	jne    801460 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80144e:	83 ec 0c             	sub    $0xc,%esp
  801451:	6a 01                	push   $0x1
  801453:	e8 9e 08 00 00       	call   801cf6 <ipc_find_env>
  801458:	a3 00 40 80 00       	mov    %eax,0x804000
  80145d:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801460:	6a 07                	push   $0x7
  801462:	68 00 70 80 00       	push   $0x807000
  801467:	53                   	push   %ebx
  801468:	ff 35 00 40 80 00    	pushl  0x804000
  80146e:	e8 2e 08 00 00       	call   801ca1 <ipc_send>
	
	return ipc_recv(NULL, dstva, NULL);
  801473:	83 c4 0c             	add    $0xc,%esp
  801476:	6a 00                	push   $0x0
  801478:	56                   	push   %esi
  801479:	6a 00                	push   $0x0
  80147b:	e8 ac 07 00 00       	call   801c2c <ipc_recv>
}
  801480:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801483:	5b                   	pop    %ebx
  801484:	5e                   	pop    %esi
  801485:	c9                   	leave  
  801486:	c3                   	ret    

00801487 <devfile_stat>:
}


static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801487:	55                   	push   %ebp
  801488:	89 e5                	mov    %esp,%ebp
  80148a:	53                   	push   %ebx
  80148b:	83 ec 04             	sub    $0x4,%esp
  80148e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801491:	8b 45 08             	mov    0x8(%ebp),%eax
  801494:	8b 40 0c             	mov    0xc(%eax),%eax
  801497:	a3 00 70 80 00       	mov    %eax,0x807000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0) {
  80149c:	ba 00 00 00 00       	mov    $0x0,%edx
  8014a1:	b8 05 00 00 00       	mov    $0x5,%eax
  8014a6:	e8 91 ff ff ff       	call   80143c <fsipc>
  8014ab:	85 c0                	test   %eax,%eax
  8014ad:	78 2c                	js     8014db <devfile_stat+0x54>
		return r;
	}
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8014af:	83 ec 08             	sub    $0x8,%esp
  8014b2:	68 00 70 80 00       	push   $0x807000
  8014b7:	53                   	push   %ebx
  8014b8:	e8 79 f3 ff ff       	call   800836 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8014bd:	a1 80 70 80 00       	mov    0x807080,%eax
  8014c2:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8014c8:	a1 84 70 80 00       	mov    0x807084,%eax
  8014cd:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8014d3:	83 c4 10             	add    $0x10,%esp
  8014d6:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8014db:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014de:	c9                   	leave  
  8014df:	c3                   	ret    

008014e0 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8014e0:	55                   	push   %ebp
  8014e1:	89 e5                	mov    %esp,%ebp
  8014e3:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8014e6:	8b 45 08             	mov    0x8(%ebp),%eax
  8014e9:	8b 40 0c             	mov    0xc(%eax),%eax
  8014ec:	a3 00 70 80 00       	mov    %eax,0x807000
	return fsipc(FSREQ_FLUSH, NULL);
  8014f1:	ba 00 00 00 00       	mov    $0x0,%edx
  8014f6:	b8 06 00 00 00       	mov    $0x6,%eax
  8014fb:	e8 3c ff ff ff       	call   80143c <fsipc>
}
  801500:	c9                   	leave  
  801501:	c3                   	ret    

00801502 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801502:	55                   	push   %ebp
  801503:	89 e5                	mov    %esp,%ebp
  801505:	56                   	push   %esi
  801506:	53                   	push   %ebx
  801507:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80150a:	8b 45 08             	mov    0x8(%ebp),%eax
  80150d:	8b 40 0c             	mov    0xc(%eax),%eax
  801510:	a3 00 70 80 00       	mov    %eax,0x807000
	fsipcbuf.read.req_n = n;
  801515:	89 35 04 70 80 00    	mov    %esi,0x807004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80151b:	ba 00 00 00 00       	mov    $0x0,%edx
  801520:	b8 03 00 00 00       	mov    $0x3,%eax
  801525:	e8 12 ff ff ff       	call   80143c <fsipc>
  80152a:	89 c3                	mov    %eax,%ebx
  80152c:	85 c0                	test   %eax,%eax
  80152e:	78 4b                	js     80157b <devfile_read+0x79>
		return r;
	assert(r <= n);
  801530:	39 c6                	cmp    %eax,%esi
  801532:	73 16                	jae    80154a <devfile_read+0x48>
  801534:	68 1c 24 80 00       	push   $0x80241c
  801539:	68 23 24 80 00       	push   $0x802423
  80153e:	6a 7d                	push   $0x7d
  801540:	68 38 24 80 00       	push   $0x802438
  801545:	e8 5e ec ff ff       	call   8001a8 <_panic>
	assert(r <= PGSIZE);
  80154a:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80154f:	7e 16                	jle    801567 <devfile_read+0x65>
  801551:	68 43 24 80 00       	push   $0x802443
  801556:	68 23 24 80 00       	push   $0x802423
  80155b:	6a 7e                	push   $0x7e
  80155d:	68 38 24 80 00       	push   $0x802438
  801562:	e8 41 ec ff ff       	call   8001a8 <_panic>
	memmove(buf, &fsipcbuf, r);
  801567:	83 ec 04             	sub    $0x4,%esp
  80156a:	50                   	push   %eax
  80156b:	68 00 70 80 00       	push   $0x807000
  801570:	ff 75 0c             	pushl  0xc(%ebp)
  801573:	e8 7f f4 ff ff       	call   8009f7 <memmove>
	return r;
  801578:	83 c4 10             	add    $0x10,%esp
}
  80157b:	89 d8                	mov    %ebx,%eax
  80157d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801580:	5b                   	pop    %ebx
  801581:	5e                   	pop    %esi
  801582:	c9                   	leave  
  801583:	c3                   	ret    

00801584 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801584:	55                   	push   %ebp
  801585:	89 e5                	mov    %esp,%ebp
  801587:	56                   	push   %esi
  801588:	53                   	push   %ebx
  801589:	83 ec 1c             	sub    $0x1c,%esp
  80158c:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  80158f:	56                   	push   %esi
  801590:	e8 4f f2 ff ff       	call   8007e4 <strlen>
  801595:	83 c4 10             	add    $0x10,%esp
  801598:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  80159d:	7f 65                	jg     801604 <open+0x80>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80159f:	83 ec 0c             	sub    $0xc,%esp
  8015a2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015a5:	50                   	push   %eax
  8015a6:	e8 e1 f8 ff ff       	call   800e8c <fd_alloc>
  8015ab:	89 c3                	mov    %eax,%ebx
  8015ad:	83 c4 10             	add    $0x10,%esp
  8015b0:	85 c0                	test   %eax,%eax
  8015b2:	78 55                	js     801609 <open+0x85>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8015b4:	83 ec 08             	sub    $0x8,%esp
  8015b7:	56                   	push   %esi
  8015b8:	68 00 70 80 00       	push   $0x807000
  8015bd:	e8 74 f2 ff ff       	call   800836 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8015c2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8015c5:	a3 00 74 80 00       	mov    %eax,0x807400



	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8015ca:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8015cd:	b8 01 00 00 00       	mov    $0x1,%eax
  8015d2:	e8 65 fe ff ff       	call   80143c <fsipc>
  8015d7:	89 c3                	mov    %eax,%ebx
  8015d9:	83 c4 10             	add    $0x10,%esp
  8015dc:	85 c0                	test   %eax,%eax
  8015de:	79 12                	jns    8015f2 <open+0x6e>
		fd_close(fd, 0);
  8015e0:	83 ec 08             	sub    $0x8,%esp
  8015e3:	6a 00                	push   $0x0
  8015e5:	ff 75 f4             	pushl  -0xc(%ebp)
  8015e8:	e8 ce f9 ff ff       	call   800fbb <fd_close>
		return r;
  8015ed:	83 c4 10             	add    $0x10,%esp
  8015f0:	eb 17                	jmp    801609 <open+0x85>
	}

	return fd2num(fd);
  8015f2:	83 ec 0c             	sub    $0xc,%esp
  8015f5:	ff 75 f4             	pushl  -0xc(%ebp)
  8015f8:	e8 67 f8 ff ff       	call   800e64 <fd2num>
  8015fd:	89 c3                	mov    %eax,%ebx
  8015ff:	83 c4 10             	add    $0x10,%esp
  801602:	eb 05                	jmp    801609 <open+0x85>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801604:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801609:	89 d8                	mov    %ebx,%eax
  80160b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80160e:	5b                   	pop    %ebx
  80160f:	5e                   	pop    %esi
  801610:	c9                   	leave  
  801611:	c3                   	ret    
	...

00801614 <writebuf>:
};


static void
writebuf(struct printbuf *b)
{
  801614:	55                   	push   %ebp
  801615:	89 e5                	mov    %esp,%ebp
  801617:	53                   	push   %ebx
  801618:	83 ec 04             	sub    $0x4,%esp
  80161b:	89 c3                	mov    %eax,%ebx
	if (b->error > 0) {
  80161d:	83 78 0c 00          	cmpl   $0x0,0xc(%eax)
  801621:	7e 2e                	jle    801651 <writebuf+0x3d>
		ssize_t result = write(b->fd, b->buf, b->idx);
  801623:	83 ec 04             	sub    $0x4,%esp
  801626:	ff 70 04             	pushl  0x4(%eax)
  801629:	8d 40 10             	lea    0x10(%eax),%eax
  80162c:	50                   	push   %eax
  80162d:	ff 33                	pushl  (%ebx)
  80162f:	e8 28 fc ff ff       	call   80125c <write>
		if (result > 0)
  801634:	83 c4 10             	add    $0x10,%esp
  801637:	85 c0                	test   %eax,%eax
  801639:	7e 03                	jle    80163e <writebuf+0x2a>
			b->result += result;
  80163b:	01 43 08             	add    %eax,0x8(%ebx)
		if (result != b->idx) // error, or wrote less than supplied
  80163e:	39 43 04             	cmp    %eax,0x4(%ebx)
  801641:	74 0e                	je     801651 <writebuf+0x3d>
			b->error = (result < 0 ? result : 0);
  801643:	89 c2                	mov    %eax,%edx
  801645:	85 c0                	test   %eax,%eax
  801647:	7e 05                	jle    80164e <writebuf+0x3a>
  801649:	ba 00 00 00 00       	mov    $0x0,%edx
  80164e:	89 53 0c             	mov    %edx,0xc(%ebx)
	}
}
  801651:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801654:	c9                   	leave  
  801655:	c3                   	ret    

00801656 <putch>:

static void
putch(int ch, void *thunk)
{
  801656:	55                   	push   %ebp
  801657:	89 e5                	mov    %esp,%ebp
  801659:	53                   	push   %ebx
  80165a:	83 ec 04             	sub    $0x4,%esp
  80165d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct printbuf *b = (struct printbuf *) thunk;
	b->buf[b->idx++] = ch;
  801660:	8b 43 04             	mov    0x4(%ebx),%eax
  801663:	8b 55 08             	mov    0x8(%ebp),%edx
  801666:	88 54 03 10          	mov    %dl,0x10(%ebx,%eax,1)
  80166a:	40                   	inc    %eax
  80166b:	89 43 04             	mov    %eax,0x4(%ebx)
	if (b->idx == 256) {
  80166e:	3d 00 01 00 00       	cmp    $0x100,%eax
  801673:	75 0e                	jne    801683 <putch+0x2d>
		writebuf(b);
  801675:	89 d8                	mov    %ebx,%eax
  801677:	e8 98 ff ff ff       	call   801614 <writebuf>
		b->idx = 0;
  80167c:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	}
}
  801683:	83 c4 04             	add    $0x4,%esp
  801686:	5b                   	pop    %ebx
  801687:	c9                   	leave  
  801688:	c3                   	ret    

00801689 <vfprintf>:

int
vfprintf(int fd, const char *fmt, va_list ap)
{
  801689:	55                   	push   %ebp
  80168a:	89 e5                	mov    %esp,%ebp
  80168c:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.fd = fd;
  801692:	8b 45 08             	mov    0x8(%ebp),%eax
  801695:	89 85 e8 fe ff ff    	mov    %eax,-0x118(%ebp)
	b.idx = 0;
  80169b:	c7 85 ec fe ff ff 00 	movl   $0x0,-0x114(%ebp)
  8016a2:	00 00 00 
	b.result = 0;
  8016a5:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8016ac:	00 00 00 
	b.error = 1;
  8016af:	c7 85 f4 fe ff ff 01 	movl   $0x1,-0x10c(%ebp)
  8016b6:	00 00 00 
	vprintfmt(putch, &b, fmt, ap);
  8016b9:	ff 75 10             	pushl  0x10(%ebp)
  8016bc:	ff 75 0c             	pushl  0xc(%ebp)
  8016bf:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  8016c5:	50                   	push   %eax
  8016c6:	68 56 16 80 00       	push   $0x801656
  8016cb:	e8 15 ed ff ff       	call   8003e5 <vprintfmt>
	if (b.idx > 0)
  8016d0:	83 c4 10             	add    $0x10,%esp
  8016d3:	83 bd ec fe ff ff 00 	cmpl   $0x0,-0x114(%ebp)
  8016da:	7e 0b                	jle    8016e7 <vfprintf+0x5e>
		writebuf(&b);
  8016dc:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  8016e2:	e8 2d ff ff ff       	call   801614 <writebuf>

	return (b.result ? b.result : b.error);
  8016e7:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8016ed:	85 c0                	test   %eax,%eax
  8016ef:	75 06                	jne    8016f7 <vfprintf+0x6e>
  8016f1:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
}
  8016f7:	c9                   	leave  
  8016f8:	c3                   	ret    

008016f9 <fprintf>:

int
fprintf(int fd, const char *fmt, ...)
{
  8016f9:	55                   	push   %ebp
  8016fa:	89 e5                	mov    %esp,%ebp
  8016fc:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8016ff:	8d 45 10             	lea    0x10(%ebp),%eax
	cnt = vfprintf(fd, fmt, ap);
  801702:	50                   	push   %eax
  801703:	ff 75 0c             	pushl  0xc(%ebp)
  801706:	ff 75 08             	pushl  0x8(%ebp)
  801709:	e8 7b ff ff ff       	call   801689 <vfprintf>
	va_end(ap);

	return cnt;
}
  80170e:	c9                   	leave  
  80170f:	c3                   	ret    

00801710 <printf>:

int
printf(const char *fmt, ...)
{
  801710:	55                   	push   %ebp
  801711:	89 e5                	mov    %esp,%ebp
  801713:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801716:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vfprintf(1, fmt, ap);
  801719:	50                   	push   %eax
  80171a:	ff 75 08             	pushl  0x8(%ebp)
  80171d:	6a 01                	push   $0x1
  80171f:	e8 65 ff ff ff       	call   801689 <vfprintf>
	va_end(ap);

	return cnt;
}
  801724:	c9                   	leave  
  801725:	c3                   	ret    
	...

00801728 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801728:	55                   	push   %ebp
  801729:	89 e5                	mov    %esp,%ebp
  80172b:	56                   	push   %esi
  80172c:	53                   	push   %ebx
  80172d:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801730:	83 ec 0c             	sub    $0xc,%esp
  801733:	ff 75 08             	pushl  0x8(%ebp)
  801736:	e8 39 f7 ff ff       	call   800e74 <fd2data>
  80173b:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  80173d:	83 c4 08             	add    $0x8,%esp
  801740:	68 4f 24 80 00       	push   $0x80244f
  801745:	56                   	push   %esi
  801746:	e8 eb f0 ff ff       	call   800836 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  80174b:	8b 43 04             	mov    0x4(%ebx),%eax
  80174e:	2b 03                	sub    (%ebx),%eax
  801750:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  801756:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  80175d:	00 00 00 
	stat->st_dev = &devpipe;
  801760:	c7 86 88 00 00 00 20 	movl   $0x803020,0x88(%esi)
  801767:	30 80 00 
	return 0;
}
  80176a:	b8 00 00 00 00       	mov    $0x0,%eax
  80176f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801772:	5b                   	pop    %ebx
  801773:	5e                   	pop    %esi
  801774:	c9                   	leave  
  801775:	c3                   	ret    

00801776 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801776:	55                   	push   %ebp
  801777:	89 e5                	mov    %esp,%ebp
  801779:	53                   	push   %ebx
  80177a:	83 ec 0c             	sub    $0xc,%esp
  80177d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801780:	53                   	push   %ebx
  801781:	6a 00                	push   $0x0
  801783:	e8 7a f5 ff ff       	call   800d02 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801788:	89 1c 24             	mov    %ebx,(%esp)
  80178b:	e8 e4 f6 ff ff       	call   800e74 <fd2data>
  801790:	83 c4 08             	add    $0x8,%esp
  801793:	50                   	push   %eax
  801794:	6a 00                	push   $0x0
  801796:	e8 67 f5 ff ff       	call   800d02 <sys_page_unmap>
}
  80179b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80179e:	c9                   	leave  
  80179f:	c3                   	ret    

008017a0 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8017a0:	55                   	push   %ebp
  8017a1:	89 e5                	mov    %esp,%ebp
  8017a3:	57                   	push   %edi
  8017a4:	56                   	push   %esi
  8017a5:	53                   	push   %ebx
  8017a6:	83 ec 1c             	sub    $0x1c,%esp
  8017a9:	89 c7                	mov    %eax,%edi
  8017ab:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8017ae:	a1 20 60 80 00       	mov    0x806020,%eax
  8017b3:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  8017b6:	83 ec 0c             	sub    $0xc,%esp
  8017b9:	57                   	push   %edi
  8017ba:	e8 85 05 00 00       	call   801d44 <pageref>
  8017bf:	89 c6                	mov    %eax,%esi
  8017c1:	83 c4 04             	add    $0x4,%esp
  8017c4:	ff 75 e4             	pushl  -0x1c(%ebp)
  8017c7:	e8 78 05 00 00       	call   801d44 <pageref>
  8017cc:	83 c4 10             	add    $0x10,%esp
  8017cf:	39 c6                	cmp    %eax,%esi
  8017d1:	0f 94 c0             	sete   %al
  8017d4:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  8017d7:	8b 15 20 60 80 00    	mov    0x806020,%edx
  8017dd:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  8017e0:	39 cb                	cmp    %ecx,%ebx
  8017e2:	75 08                	jne    8017ec <_pipeisclosed+0x4c>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  8017e4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8017e7:	5b                   	pop    %ebx
  8017e8:	5e                   	pop    %esi
  8017e9:	5f                   	pop    %edi
  8017ea:	c9                   	leave  
  8017eb:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  8017ec:	83 f8 01             	cmp    $0x1,%eax
  8017ef:	75 bd                	jne    8017ae <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8017f1:	8b 42 58             	mov    0x58(%edx),%eax
  8017f4:	6a 01                	push   $0x1
  8017f6:	50                   	push   %eax
  8017f7:	53                   	push   %ebx
  8017f8:	68 56 24 80 00       	push   $0x802456
  8017fd:	e8 7e ea ff ff       	call   800280 <cprintf>
  801802:	83 c4 10             	add    $0x10,%esp
  801805:	eb a7                	jmp    8017ae <_pipeisclosed+0xe>

00801807 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801807:	55                   	push   %ebp
  801808:	89 e5                	mov    %esp,%ebp
  80180a:	57                   	push   %edi
  80180b:	56                   	push   %esi
  80180c:	53                   	push   %ebx
  80180d:	83 ec 28             	sub    $0x28,%esp
  801810:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801813:	56                   	push   %esi
  801814:	e8 5b f6 ff ff       	call   800e74 <fd2data>
  801819:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80181b:	83 c4 10             	add    $0x10,%esp
  80181e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801822:	75 4a                	jne    80186e <devpipe_write+0x67>
  801824:	bf 00 00 00 00       	mov    $0x0,%edi
  801829:	eb 56                	jmp    801881 <devpipe_write+0x7a>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  80182b:	89 da                	mov    %ebx,%edx
  80182d:	89 f0                	mov    %esi,%eax
  80182f:	e8 6c ff ff ff       	call   8017a0 <_pipeisclosed>
  801834:	85 c0                	test   %eax,%eax
  801836:	75 4d                	jne    801885 <devpipe_write+0x7e>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801838:	e8 54 f4 ff ff       	call   800c91 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  80183d:	8b 43 04             	mov    0x4(%ebx),%eax
  801840:	8b 13                	mov    (%ebx),%edx
  801842:	83 c2 20             	add    $0x20,%edx
  801845:	39 d0                	cmp    %edx,%eax
  801847:	73 e2                	jae    80182b <devpipe_write+0x24>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801849:	89 c2                	mov    %eax,%edx
  80184b:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  801851:	79 05                	jns    801858 <devpipe_write+0x51>
  801853:	4a                   	dec    %edx
  801854:	83 ca e0             	or     $0xffffffe0,%edx
  801857:	42                   	inc    %edx
  801858:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80185b:	8a 0c 39             	mov    (%ecx,%edi,1),%cl
  80185e:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801862:	40                   	inc    %eax
  801863:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801866:	47                   	inc    %edi
  801867:	39 7d 10             	cmp    %edi,0x10(%ebp)
  80186a:	77 07                	ja     801873 <devpipe_write+0x6c>
  80186c:	eb 13                	jmp    801881 <devpipe_write+0x7a>
  80186e:	bf 00 00 00 00       	mov    $0x0,%edi
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801873:	8b 43 04             	mov    0x4(%ebx),%eax
  801876:	8b 13                	mov    (%ebx),%edx
  801878:	83 c2 20             	add    $0x20,%edx
  80187b:	39 d0                	cmp    %edx,%eax
  80187d:	73 ac                	jae    80182b <devpipe_write+0x24>
  80187f:	eb c8                	jmp    801849 <devpipe_write+0x42>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801881:	89 f8                	mov    %edi,%eax
  801883:	eb 05                	jmp    80188a <devpipe_write+0x83>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801885:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  80188a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80188d:	5b                   	pop    %ebx
  80188e:	5e                   	pop    %esi
  80188f:	5f                   	pop    %edi
  801890:	c9                   	leave  
  801891:	c3                   	ret    

00801892 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801892:	55                   	push   %ebp
  801893:	89 e5                	mov    %esp,%ebp
  801895:	57                   	push   %edi
  801896:	56                   	push   %esi
  801897:	53                   	push   %ebx
  801898:	83 ec 18             	sub    $0x18,%esp
  80189b:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  80189e:	57                   	push   %edi
  80189f:	e8 d0 f5 ff ff       	call   800e74 <fd2data>
  8018a4:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8018a6:	83 c4 10             	add    $0x10,%esp
  8018a9:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8018ad:	75 44                	jne    8018f3 <devpipe_read+0x61>
  8018af:	be 00 00 00 00       	mov    $0x0,%esi
  8018b4:	eb 4f                	jmp    801905 <devpipe_read+0x73>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
				return i;
  8018b6:	89 f0                	mov    %esi,%eax
  8018b8:	eb 54                	jmp    80190e <devpipe_read+0x7c>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  8018ba:	89 da                	mov    %ebx,%edx
  8018bc:	89 f8                	mov    %edi,%eax
  8018be:	e8 dd fe ff ff       	call   8017a0 <_pipeisclosed>
  8018c3:	85 c0                	test   %eax,%eax
  8018c5:	75 42                	jne    801909 <devpipe_read+0x77>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  8018c7:	e8 c5 f3 ff ff       	call   800c91 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8018cc:	8b 03                	mov    (%ebx),%eax
  8018ce:	3b 43 04             	cmp    0x4(%ebx),%eax
  8018d1:	74 e7                	je     8018ba <devpipe_read+0x28>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8018d3:	25 1f 00 00 80       	and    $0x8000001f,%eax
  8018d8:	79 05                	jns    8018df <devpipe_read+0x4d>
  8018da:	48                   	dec    %eax
  8018db:	83 c8 e0             	or     $0xffffffe0,%eax
  8018de:	40                   	inc    %eax
  8018df:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  8018e3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8018e6:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  8018e9:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8018eb:	46                   	inc    %esi
  8018ec:	39 75 10             	cmp    %esi,0x10(%ebp)
  8018ef:	77 07                	ja     8018f8 <devpipe_read+0x66>
  8018f1:	eb 12                	jmp    801905 <devpipe_read+0x73>
  8018f3:	be 00 00 00 00       	mov    $0x0,%esi
		while (p->p_rpos == p->p_wpos) {
  8018f8:	8b 03                	mov    (%ebx),%eax
  8018fa:	3b 43 04             	cmp    0x4(%ebx),%eax
  8018fd:	75 d4                	jne    8018d3 <devpipe_read+0x41>
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  8018ff:	85 f6                	test   %esi,%esi
  801901:	75 b3                	jne    8018b6 <devpipe_read+0x24>
  801903:	eb b5                	jmp    8018ba <devpipe_read+0x28>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801905:	89 f0                	mov    %esi,%eax
  801907:	eb 05                	jmp    80190e <devpipe_read+0x7c>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801909:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  80190e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801911:	5b                   	pop    %ebx
  801912:	5e                   	pop    %esi
  801913:	5f                   	pop    %edi
  801914:	c9                   	leave  
  801915:	c3                   	ret    

00801916 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801916:	55                   	push   %ebp
  801917:	89 e5                	mov    %esp,%ebp
  801919:	57                   	push   %edi
  80191a:	56                   	push   %esi
  80191b:	53                   	push   %ebx
  80191c:	83 ec 28             	sub    $0x28,%esp
  80191f:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801922:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801925:	50                   	push   %eax
  801926:	e8 61 f5 ff ff       	call   800e8c <fd_alloc>
  80192b:	89 c3                	mov    %eax,%ebx
  80192d:	83 c4 10             	add    $0x10,%esp
  801930:	85 c0                	test   %eax,%eax
  801932:	0f 88 24 01 00 00    	js     801a5c <pipe+0x146>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801938:	83 ec 04             	sub    $0x4,%esp
  80193b:	68 07 04 00 00       	push   $0x407
  801940:	ff 75 e4             	pushl  -0x1c(%ebp)
  801943:	6a 00                	push   $0x0
  801945:	e8 6e f3 ff ff       	call   800cb8 <sys_page_alloc>
  80194a:	89 c3                	mov    %eax,%ebx
  80194c:	83 c4 10             	add    $0x10,%esp
  80194f:	85 c0                	test   %eax,%eax
  801951:	0f 88 05 01 00 00    	js     801a5c <pipe+0x146>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801957:	83 ec 0c             	sub    $0xc,%esp
  80195a:	8d 45 e0             	lea    -0x20(%ebp),%eax
  80195d:	50                   	push   %eax
  80195e:	e8 29 f5 ff ff       	call   800e8c <fd_alloc>
  801963:	89 c3                	mov    %eax,%ebx
  801965:	83 c4 10             	add    $0x10,%esp
  801968:	85 c0                	test   %eax,%eax
  80196a:	0f 88 dc 00 00 00    	js     801a4c <pipe+0x136>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801970:	83 ec 04             	sub    $0x4,%esp
  801973:	68 07 04 00 00       	push   $0x407
  801978:	ff 75 e0             	pushl  -0x20(%ebp)
  80197b:	6a 00                	push   $0x0
  80197d:	e8 36 f3 ff ff       	call   800cb8 <sys_page_alloc>
  801982:	89 c3                	mov    %eax,%ebx
  801984:	83 c4 10             	add    $0x10,%esp
  801987:	85 c0                	test   %eax,%eax
  801989:	0f 88 bd 00 00 00    	js     801a4c <pipe+0x136>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  80198f:	83 ec 0c             	sub    $0xc,%esp
  801992:	ff 75 e4             	pushl  -0x1c(%ebp)
  801995:	e8 da f4 ff ff       	call   800e74 <fd2data>
  80199a:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80199c:	83 c4 0c             	add    $0xc,%esp
  80199f:	68 07 04 00 00       	push   $0x407
  8019a4:	50                   	push   %eax
  8019a5:	6a 00                	push   $0x0
  8019a7:	e8 0c f3 ff ff       	call   800cb8 <sys_page_alloc>
  8019ac:	89 c3                	mov    %eax,%ebx
  8019ae:	83 c4 10             	add    $0x10,%esp
  8019b1:	85 c0                	test   %eax,%eax
  8019b3:	0f 88 83 00 00 00    	js     801a3c <pipe+0x126>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8019b9:	83 ec 0c             	sub    $0xc,%esp
  8019bc:	ff 75 e0             	pushl  -0x20(%ebp)
  8019bf:	e8 b0 f4 ff ff       	call   800e74 <fd2data>
  8019c4:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  8019cb:	50                   	push   %eax
  8019cc:	6a 00                	push   $0x0
  8019ce:	56                   	push   %esi
  8019cf:	6a 00                	push   $0x0
  8019d1:	e8 06 f3 ff ff       	call   800cdc <sys_page_map>
  8019d6:	89 c3                	mov    %eax,%ebx
  8019d8:	83 c4 20             	add    $0x20,%esp
  8019db:	85 c0                	test   %eax,%eax
  8019dd:	78 4f                	js     801a2e <pipe+0x118>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  8019df:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8019e5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8019e8:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8019ea:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8019ed:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8019f4:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8019fa:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8019fd:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8019ff:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801a02:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801a09:	83 ec 0c             	sub    $0xc,%esp
  801a0c:	ff 75 e4             	pushl  -0x1c(%ebp)
  801a0f:	e8 50 f4 ff ff       	call   800e64 <fd2num>
  801a14:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  801a16:	83 c4 04             	add    $0x4,%esp
  801a19:	ff 75 e0             	pushl  -0x20(%ebp)
  801a1c:	e8 43 f4 ff ff       	call   800e64 <fd2num>
  801a21:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  801a24:	83 c4 10             	add    $0x10,%esp
  801a27:	bb 00 00 00 00       	mov    $0x0,%ebx
  801a2c:	eb 2e                	jmp    801a5c <pipe+0x146>

    err3:
	sys_page_unmap(0, va);
  801a2e:	83 ec 08             	sub    $0x8,%esp
  801a31:	56                   	push   %esi
  801a32:	6a 00                	push   $0x0
  801a34:	e8 c9 f2 ff ff       	call   800d02 <sys_page_unmap>
  801a39:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801a3c:	83 ec 08             	sub    $0x8,%esp
  801a3f:	ff 75 e0             	pushl  -0x20(%ebp)
  801a42:	6a 00                	push   $0x0
  801a44:	e8 b9 f2 ff ff       	call   800d02 <sys_page_unmap>
  801a49:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801a4c:	83 ec 08             	sub    $0x8,%esp
  801a4f:	ff 75 e4             	pushl  -0x1c(%ebp)
  801a52:	6a 00                	push   $0x0
  801a54:	e8 a9 f2 ff ff       	call   800d02 <sys_page_unmap>
  801a59:	83 c4 10             	add    $0x10,%esp
    err:
	return r;
}
  801a5c:	89 d8                	mov    %ebx,%eax
  801a5e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a61:	5b                   	pop    %ebx
  801a62:	5e                   	pop    %esi
  801a63:	5f                   	pop    %edi
  801a64:	c9                   	leave  
  801a65:	c3                   	ret    

00801a66 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801a66:	55                   	push   %ebp
  801a67:	89 e5                	mov    %esp,%ebp
  801a69:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801a6c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a6f:	50                   	push   %eax
  801a70:	ff 75 08             	pushl  0x8(%ebp)
  801a73:	e8 87 f4 ff ff       	call   800eff <fd_lookup>
  801a78:	83 c4 10             	add    $0x10,%esp
  801a7b:	85 c0                	test   %eax,%eax
  801a7d:	78 18                	js     801a97 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801a7f:	83 ec 0c             	sub    $0xc,%esp
  801a82:	ff 75 f4             	pushl  -0xc(%ebp)
  801a85:	e8 ea f3 ff ff       	call   800e74 <fd2data>
	return _pipeisclosed(fd, p);
  801a8a:	89 c2                	mov    %eax,%edx
  801a8c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a8f:	e8 0c fd ff ff       	call   8017a0 <_pipeisclosed>
  801a94:	83 c4 10             	add    $0x10,%esp
}
  801a97:	c9                   	leave  
  801a98:	c3                   	ret    
  801a99:	00 00                	add    %al,(%eax)
	...

00801a9c <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801a9c:	55                   	push   %ebp
  801a9d:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801a9f:	b8 00 00 00 00       	mov    $0x0,%eax
  801aa4:	c9                   	leave  
  801aa5:	c3                   	ret    

00801aa6 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801aa6:	55                   	push   %ebp
  801aa7:	89 e5                	mov    %esp,%ebp
  801aa9:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801aac:	68 6e 24 80 00       	push   $0x80246e
  801ab1:	ff 75 0c             	pushl  0xc(%ebp)
  801ab4:	e8 7d ed ff ff       	call   800836 <strcpy>
	return 0;
}
  801ab9:	b8 00 00 00 00       	mov    $0x0,%eax
  801abe:	c9                   	leave  
  801abf:	c3                   	ret    

00801ac0 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801ac0:	55                   	push   %ebp
  801ac1:	89 e5                	mov    %esp,%ebp
  801ac3:	57                   	push   %edi
  801ac4:	56                   	push   %esi
  801ac5:	53                   	push   %ebx
  801ac6:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801acc:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801ad0:	74 45                	je     801b17 <devcons_write+0x57>
  801ad2:	b8 00 00 00 00       	mov    $0x0,%eax
  801ad7:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801adc:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801ae2:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801ae5:	29 c3                	sub    %eax,%ebx
		if (m > sizeof(buf) - 1)
  801ae7:	83 fb 7f             	cmp    $0x7f,%ebx
  801aea:	76 05                	jbe    801af1 <devcons_write+0x31>
			m = sizeof(buf) - 1;
  801aec:	bb 7f 00 00 00       	mov    $0x7f,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  801af1:	83 ec 04             	sub    $0x4,%esp
  801af4:	53                   	push   %ebx
  801af5:	03 45 0c             	add    0xc(%ebp),%eax
  801af8:	50                   	push   %eax
  801af9:	57                   	push   %edi
  801afa:	e8 f8 ee ff ff       	call   8009f7 <memmove>
		sys_cputs(buf, m);
  801aff:	83 c4 08             	add    $0x8,%esp
  801b02:	53                   	push   %ebx
  801b03:	57                   	push   %edi
  801b04:	e8 f8 f0 ff ff       	call   800c01 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801b09:	01 de                	add    %ebx,%esi
  801b0b:	89 f0                	mov    %esi,%eax
  801b0d:	83 c4 10             	add    $0x10,%esp
  801b10:	3b 75 10             	cmp    0x10(%ebp),%esi
  801b13:	72 cd                	jb     801ae2 <devcons_write+0x22>
  801b15:	eb 05                	jmp    801b1c <devcons_write+0x5c>
  801b17:	be 00 00 00 00       	mov    $0x0,%esi
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801b1c:	89 f0                	mov    %esi,%eax
  801b1e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b21:	5b                   	pop    %ebx
  801b22:	5e                   	pop    %esi
  801b23:	5f                   	pop    %edi
  801b24:	c9                   	leave  
  801b25:	c3                   	ret    

00801b26 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801b26:	55                   	push   %ebp
  801b27:	89 e5                	mov    %esp,%ebp
  801b29:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  801b2c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801b30:	75 07                	jne    801b39 <devcons_read+0x13>
  801b32:	eb 25                	jmp    801b59 <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801b34:	e8 58 f1 ff ff       	call   800c91 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801b39:	e8 e9 f0 ff ff       	call   800c27 <sys_cgetc>
  801b3e:	85 c0                	test   %eax,%eax
  801b40:	74 f2                	je     801b34 <devcons_read+0xe>
  801b42:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  801b44:	85 c0                	test   %eax,%eax
  801b46:	78 1d                	js     801b65 <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801b48:	83 f8 04             	cmp    $0x4,%eax
  801b4b:	74 13                	je     801b60 <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  801b4d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b50:	88 10                	mov    %dl,(%eax)
	return 1;
  801b52:	b8 01 00 00 00       	mov    $0x1,%eax
  801b57:	eb 0c                	jmp    801b65 <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  801b59:	b8 00 00 00 00       	mov    $0x0,%eax
  801b5e:	eb 05                	jmp    801b65 <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801b60:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801b65:	c9                   	leave  
  801b66:	c3                   	ret    

00801b67 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801b67:	55                   	push   %ebp
  801b68:	89 e5                	mov    %esp,%ebp
  801b6a:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801b6d:	8b 45 08             	mov    0x8(%ebp),%eax
  801b70:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801b73:	6a 01                	push   $0x1
  801b75:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801b78:	50                   	push   %eax
  801b79:	e8 83 f0 ff ff       	call   800c01 <sys_cputs>
  801b7e:	83 c4 10             	add    $0x10,%esp
}
  801b81:	c9                   	leave  
  801b82:	c3                   	ret    

00801b83 <getchar>:

int
getchar(void)
{
  801b83:	55                   	push   %ebp
  801b84:	89 e5                	mov    %esp,%ebp
  801b86:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801b89:	6a 01                	push   $0x1
  801b8b:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801b8e:	50                   	push   %eax
  801b8f:	6a 00                	push   $0x0
  801b91:	e8 ea f5 ff ff       	call   801180 <read>
	if (r < 0)
  801b96:	83 c4 10             	add    $0x10,%esp
  801b99:	85 c0                	test   %eax,%eax
  801b9b:	78 0f                	js     801bac <getchar+0x29>
		return r;
	if (r < 1)
  801b9d:	85 c0                	test   %eax,%eax
  801b9f:	7e 06                	jle    801ba7 <getchar+0x24>
		return -E_EOF;
	return c;
  801ba1:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801ba5:	eb 05                	jmp    801bac <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801ba7:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801bac:	c9                   	leave  
  801bad:	c3                   	ret    

00801bae <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801bae:	55                   	push   %ebp
  801baf:	89 e5                	mov    %esp,%ebp
  801bb1:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801bb4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801bb7:	50                   	push   %eax
  801bb8:	ff 75 08             	pushl  0x8(%ebp)
  801bbb:	e8 3f f3 ff ff       	call   800eff <fd_lookup>
  801bc0:	83 c4 10             	add    $0x10,%esp
  801bc3:	85 c0                	test   %eax,%eax
  801bc5:	78 11                	js     801bd8 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801bc7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801bca:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801bd0:	39 10                	cmp    %edx,(%eax)
  801bd2:	0f 94 c0             	sete   %al
  801bd5:	0f b6 c0             	movzbl %al,%eax
}
  801bd8:	c9                   	leave  
  801bd9:	c3                   	ret    

00801bda <opencons>:

int
opencons(void)
{
  801bda:	55                   	push   %ebp
  801bdb:	89 e5                	mov    %esp,%ebp
  801bdd:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801be0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801be3:	50                   	push   %eax
  801be4:	e8 a3 f2 ff ff       	call   800e8c <fd_alloc>
  801be9:	83 c4 10             	add    $0x10,%esp
  801bec:	85 c0                	test   %eax,%eax
  801bee:	78 3a                	js     801c2a <opencons+0x50>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801bf0:	83 ec 04             	sub    $0x4,%esp
  801bf3:	68 07 04 00 00       	push   $0x407
  801bf8:	ff 75 f4             	pushl  -0xc(%ebp)
  801bfb:	6a 00                	push   $0x0
  801bfd:	e8 b6 f0 ff ff       	call   800cb8 <sys_page_alloc>
  801c02:	83 c4 10             	add    $0x10,%esp
  801c05:	85 c0                	test   %eax,%eax
  801c07:	78 21                	js     801c2a <opencons+0x50>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801c09:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801c0f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c12:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801c14:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c17:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801c1e:	83 ec 0c             	sub    $0xc,%esp
  801c21:	50                   	push   %eax
  801c22:	e8 3d f2 ff ff       	call   800e64 <fd2num>
  801c27:	83 c4 10             	add    $0x10,%esp
}
  801c2a:	c9                   	leave  
  801c2b:	c3                   	ret    

00801c2c <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801c2c:	55                   	push   %ebp
  801c2d:	89 e5                	mov    %esp,%ebp
  801c2f:	56                   	push   %esi
  801c30:	53                   	push   %ebx
  801c31:	8b 75 08             	mov    0x8(%ebp),%esi
  801c34:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c37:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// cprintf("0x%x 0x%x 0x%x\n", (uint32_t)from_env_store, (uint32_t)pg, (uint32_t)perm_store);
	int r;
	if (pg != NULL) {
  801c3a:	85 c0                	test   %eax,%eax
  801c3c:	74 0e                	je     801c4c <ipc_recv+0x20>
		r = sys_ipc_recv(pg);
  801c3e:	83 ec 0c             	sub    $0xc,%esp
  801c41:	50                   	push   %eax
  801c42:	e8 6c f1 ff ff       	call   800db3 <sys_ipc_recv>
  801c47:	83 c4 10             	add    $0x10,%esp
  801c4a:	eb 10                	jmp    801c5c <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv((void *)UTOP);
  801c4c:	83 ec 0c             	sub    $0xc,%esp
  801c4f:	68 00 00 c0 ee       	push   $0xeec00000
  801c54:	e8 5a f1 ff ff       	call   800db3 <sys_ipc_recv>
  801c59:	83 c4 10             	add    $0x10,%esp
	}

	if (r == 0) {
  801c5c:	85 c0                	test   %eax,%eax
  801c5e:	75 26                	jne    801c86 <ipc_recv+0x5a>
		if (from_env_store != NULL) *from_env_store = thisenv->env_ipc_from;
  801c60:	85 f6                	test   %esi,%esi
  801c62:	74 0a                	je     801c6e <ipc_recv+0x42>
  801c64:	a1 20 60 80 00       	mov    0x806020,%eax
  801c69:	8b 40 74             	mov    0x74(%eax),%eax
  801c6c:	89 06                	mov    %eax,(%esi)
		if (perm_store != NULL) *perm_store = thisenv->env_ipc_perm;
  801c6e:	85 db                	test   %ebx,%ebx
  801c70:	74 0a                	je     801c7c <ipc_recv+0x50>
  801c72:	a1 20 60 80 00       	mov    0x806020,%eax
  801c77:	8b 40 78             	mov    0x78(%eax),%eax
  801c7a:	89 03                	mov    %eax,(%ebx)
		return thisenv->env_ipc_value;
  801c7c:	a1 20 60 80 00       	mov    0x806020,%eax
  801c81:	8b 40 70             	mov    0x70(%eax),%eax
  801c84:	eb 14                	jmp    801c9a <ipc_recv+0x6e>
	} else {
		// fails;
		if (from_env_store != NULL) *from_env_store = 0;
  801c86:	85 f6                	test   %esi,%esi
  801c88:	74 06                	je     801c90 <ipc_recv+0x64>
  801c8a:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if (perm_store != NULL) *perm_store = 0;
  801c90:	85 db                	test   %ebx,%ebx
  801c92:	74 06                	je     801c9a <ipc_recv+0x6e>
  801c94:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		return r;
	}
}
  801c9a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c9d:	5b                   	pop    %ebx
  801c9e:	5e                   	pop    %esi
  801c9f:	c9                   	leave  
  801ca0:	c3                   	ret    

00801ca1 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801ca1:	55                   	push   %ebp
  801ca2:	89 e5                	mov    %esp,%ebp
  801ca4:	57                   	push   %edi
  801ca5:	56                   	push   %esi
  801ca6:	53                   	push   %ebx
  801ca7:	83 ec 0c             	sub    $0xc,%esp
  801caa:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801cad:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801cb0:	8b 75 14             	mov    0x14(%ebp),%esi
	// LAB 4: Your code here.
	// int sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
	int r;
	if (pg == NULL) pg = (void *)UTOP;
  801cb3:	85 db                	test   %ebx,%ebx
  801cb5:	75 25                	jne    801cdc <ipc_send+0x3b>
  801cb7:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
  801cbc:	eb 1e                	jmp    801cdc <ipc_send+0x3b>
	
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) != 0) {
		if (r == -E_IPC_NOT_RECV) {
  801cbe:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801cc1:	75 07                	jne    801cca <ipc_send+0x29>
			// cprintf("Try Again and Again....\n");
			sys_yield();
  801cc3:	e8 c9 ef ff ff       	call   800c91 <sys_yield>
  801cc8:	eb 12                	jmp    801cdc <ipc_send+0x3b>
		} else {
			panic("ipc_send error %e\n", r);
  801cca:	50                   	push   %eax
  801ccb:	68 7a 24 80 00       	push   $0x80247a
  801cd0:	6a 43                	push   $0x43
  801cd2:	68 8d 24 80 00       	push   $0x80248d
  801cd7:	e8 cc e4 ff ff       	call   8001a8 <_panic>
	// LAB 4: Your code here.
	// int sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
	int r;
	if (pg == NULL) pg = (void *)UTOP;
	
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) != 0) {
  801cdc:	56                   	push   %esi
  801cdd:	53                   	push   %ebx
  801cde:	57                   	push   %edi
  801cdf:	ff 75 08             	pushl  0x8(%ebp)
  801ce2:	e8 a7 f0 ff ff       	call   800d8e <sys_ipc_try_send>
  801ce7:	83 c4 10             	add    $0x10,%esp
  801cea:	85 c0                	test   %eax,%eax
  801cec:	75 d0                	jne    801cbe <ipc_send+0x1d>
		} else {
			panic("ipc_send error %e\n", r);
		}
	}
	return;
}
  801cee:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801cf1:	5b                   	pop    %ebx
  801cf2:	5e                   	pop    %esi
  801cf3:	5f                   	pop    %edi
  801cf4:	c9                   	leave  
  801cf5:	c3                   	ret    

00801cf6 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801cf6:	55                   	push   %ebp
  801cf7:	89 e5                	mov    %esp,%ebp
  801cf9:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  801cfc:	39 0d 50 00 c0 ee    	cmp    %ecx,0xeec00050
  801d02:	74 1a                	je     801d1e <ipc_find_env+0x28>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801d04:	b8 01 00 00 00       	mov    $0x1,%eax
		if (envs[i].env_type == type)
  801d09:	89 c2                	mov    %eax,%edx
  801d0b:	c1 e2 07             	shl    $0x7,%edx
  801d0e:	8d 94 82 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,4),%edx
  801d15:	8b 52 50             	mov    0x50(%edx),%edx
  801d18:	39 ca                	cmp    %ecx,%edx
  801d1a:	75 18                	jne    801d34 <ipc_find_env+0x3e>
  801d1c:	eb 05                	jmp    801d23 <ipc_find_env+0x2d>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801d1e:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
			return envs[i].env_id;
  801d23:	89 c2                	mov    %eax,%edx
  801d25:	c1 e2 07             	shl    $0x7,%edx
  801d28:	8d 84 82 08 00 c0 ee 	lea    -0x113ffff8(%edx,%eax,4),%eax
  801d2f:	8b 40 40             	mov    0x40(%eax),%eax
  801d32:	eb 0c                	jmp    801d40 <ipc_find_env+0x4a>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801d34:	40                   	inc    %eax
  801d35:	3d 00 04 00 00       	cmp    $0x400,%eax
  801d3a:	75 cd                	jne    801d09 <ipc_find_env+0x13>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801d3c:	66 b8 00 00          	mov    $0x0,%ax
}
  801d40:	c9                   	leave  
  801d41:	c3                   	ret    
	...

00801d44 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801d44:	55                   	push   %ebp
  801d45:	89 e5                	mov    %esp,%ebp
  801d47:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801d4a:	89 c2                	mov    %eax,%edx
  801d4c:	c1 ea 16             	shr    $0x16,%edx
  801d4f:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801d56:	f6 c2 01             	test   $0x1,%dl
  801d59:	74 1e                	je     801d79 <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  801d5b:	c1 e8 0c             	shr    $0xc,%eax
  801d5e:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801d65:	a8 01                	test   $0x1,%al
  801d67:	74 17                	je     801d80 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801d69:	c1 e8 0c             	shr    $0xc,%eax
  801d6c:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  801d73:	ef 
  801d74:	0f b7 c0             	movzwl %ax,%eax
  801d77:	eb 0c                	jmp    801d85 <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  801d79:	b8 00 00 00 00       	mov    $0x0,%eax
  801d7e:	eb 05                	jmp    801d85 <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  801d80:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  801d85:	c9                   	leave  
  801d86:	c3                   	ret    
	...

00801d88 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  801d88:	55                   	push   %ebp
  801d89:	89 e5                	mov    %esp,%ebp
  801d8b:	57                   	push   %edi
  801d8c:	56                   	push   %esi
  801d8d:	83 ec 10             	sub    $0x10,%esp
  801d90:	8b 7d 08             	mov    0x8(%ebp),%edi
  801d93:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  801d96:	89 7d f0             	mov    %edi,-0x10(%ebp)
  801d99:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  801d9c:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  801d9f:	8b 45 14             	mov    0x14(%ebp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  801da2:	85 c0                	test   %eax,%eax
  801da4:	75 2e                	jne    801dd4 <__udivdi3+0x4c>
    {
      if (d0 > n1)
  801da6:	39 f1                	cmp    %esi,%ecx
  801da8:	77 5a                	ja     801e04 <__udivdi3+0x7c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  801daa:	85 c9                	test   %ecx,%ecx
  801dac:	75 0b                	jne    801db9 <__udivdi3+0x31>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  801dae:	b8 01 00 00 00       	mov    $0x1,%eax
  801db3:	31 d2                	xor    %edx,%edx
  801db5:	f7 f1                	div    %ecx
  801db7:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  801db9:	31 d2                	xor    %edx,%edx
  801dbb:	89 f0                	mov    %esi,%eax
  801dbd:	f7 f1                	div    %ecx
  801dbf:	89 c6                	mov    %eax,%esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801dc1:	89 f8                	mov    %edi,%eax
  801dc3:	f7 f1                	div    %ecx
  801dc5:	89 c7                	mov    %eax,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801dc7:	89 f8                	mov    %edi,%eax
  801dc9:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801dcb:	83 c4 10             	add    $0x10,%esp
  801dce:	5e                   	pop    %esi
  801dcf:	5f                   	pop    %edi
  801dd0:	c9                   	leave  
  801dd1:	c3                   	ret    
  801dd2:	66 90                	xchg   %ax,%ax
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801dd4:	39 f0                	cmp    %esi,%eax
  801dd6:	77 1c                	ja     801df4 <__udivdi3+0x6c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  801dd8:	0f bd f8             	bsr    %eax,%edi
	  if (bm == 0)
  801ddb:	83 f7 1f             	xor    $0x1f,%edi
  801dde:	75 3c                	jne    801e1c <__udivdi3+0x94>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801de0:	39 f0                	cmp    %esi,%eax
  801de2:	0f 82 90 00 00 00    	jb     801e78 <__udivdi3+0xf0>
  801de8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801deb:	39 55 f4             	cmp    %edx,-0xc(%ebp)
  801dee:	0f 86 84 00 00 00    	jbe    801e78 <__udivdi3+0xf0>
  801df4:	31 f6                	xor    %esi,%esi
  801df6:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801df8:	89 f8                	mov    %edi,%eax
  801dfa:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801dfc:	83 c4 10             	add    $0x10,%esp
  801dff:	5e                   	pop    %esi
  801e00:	5f                   	pop    %edi
  801e01:	c9                   	leave  
  801e02:	c3                   	ret    
  801e03:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801e04:	89 f2                	mov    %esi,%edx
  801e06:	89 f8                	mov    %edi,%eax
  801e08:	f7 f1                	div    %ecx
  801e0a:	89 c7                	mov    %eax,%edi
  801e0c:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801e0e:	89 f8                	mov    %edi,%eax
  801e10:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801e12:	83 c4 10             	add    $0x10,%esp
  801e15:	5e                   	pop    %esi
  801e16:	5f                   	pop    %edi
  801e17:	c9                   	leave  
  801e18:	c3                   	ret    
  801e19:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  801e1c:	89 f9                	mov    %edi,%ecx
  801e1e:	d3 e0                	shl    %cl,%eax
  801e20:	89 45 e8             	mov    %eax,-0x18(%ebp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  801e23:	b8 20 00 00 00       	mov    $0x20,%eax
  801e28:	29 f8                	sub    %edi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  801e2a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801e2d:	88 c1                	mov    %al,%cl
  801e2f:	d3 ea                	shr    %cl,%edx
  801e31:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  801e34:	09 ca                	or     %ecx,%edx
  801e36:	89 55 ec             	mov    %edx,-0x14(%ebp)
	      d0 = d0 << bm;
  801e39:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801e3c:	89 f9                	mov    %edi,%ecx
  801e3e:	d3 e2                	shl    %cl,%edx
  801e40:	89 55 f4             	mov    %edx,-0xc(%ebp)
	      n2 = n1 >> b;
  801e43:	89 f2                	mov    %esi,%edx
  801e45:	88 c1                	mov    %al,%cl
  801e47:	d3 ea                	shr    %cl,%edx
  801e49:	89 55 e8             	mov    %edx,-0x18(%ebp)
	      n1 = (n1 << bm) | (n0 >> b);
  801e4c:	89 f2                	mov    %esi,%edx
  801e4e:	89 f9                	mov    %edi,%ecx
  801e50:	d3 e2                	shl    %cl,%edx
  801e52:	8b 75 f0             	mov    -0x10(%ebp),%esi
  801e55:	88 c1                	mov    %al,%cl
  801e57:	d3 ee                	shr    %cl,%esi
  801e59:	09 d6                	or     %edx,%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  801e5b:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  801e5e:	89 f0                	mov    %esi,%eax
  801e60:	89 ca                	mov    %ecx,%edx
  801e62:	f7 75 ec             	divl   -0x14(%ebp)
  801e65:	89 d1                	mov    %edx,%ecx
  801e67:	89 c6                	mov    %eax,%esi
	      umul_ppmm (m1, m0, q0, d0);
  801e69:	f7 65 f4             	mull   -0xc(%ebp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801e6c:	39 d1                	cmp    %edx,%ecx
  801e6e:	72 28                	jb     801e98 <__udivdi3+0x110>
  801e70:	74 1a                	je     801e8c <__udivdi3+0x104>
  801e72:	89 f7                	mov    %esi,%edi
  801e74:	31 f6                	xor    %esi,%esi
  801e76:	eb 80                	jmp    801df8 <__udivdi3+0x70>
	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  801e78:	31 f6                	xor    %esi,%esi
  801e7a:	bf 01 00 00 00       	mov    $0x1,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801e7f:	89 f8                	mov    %edi,%eax
  801e81:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801e83:	83 c4 10             	add    $0x10,%esp
  801e86:	5e                   	pop    %esi
  801e87:	5f                   	pop    %edi
  801e88:	c9                   	leave  
  801e89:	c3                   	ret    
  801e8a:	66 90                	xchg   %ax,%ax

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  801e8c:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801e8f:	89 f9                	mov    %edi,%ecx
  801e91:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801e93:	39 c2                	cmp    %eax,%edx
  801e95:	73 db                	jae    801e72 <__udivdi3+0xea>
  801e97:	90                   	nop
		{
		  q0--;
  801e98:	8d 7e ff             	lea    -0x1(%esi),%edi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  801e9b:	31 f6                	xor    %esi,%esi
  801e9d:	e9 56 ff ff ff       	jmp    801df8 <__udivdi3+0x70>
	...

00801ea4 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  801ea4:	55                   	push   %ebp
  801ea5:	89 e5                	mov    %esp,%ebp
  801ea7:	57                   	push   %edi
  801ea8:	56                   	push   %esi
  801ea9:	83 ec 20             	sub    $0x20,%esp
  801eac:	8b 45 08             	mov    0x8(%ebp),%eax
  801eaf:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  801eb2:	89 45 e8             	mov    %eax,-0x18(%ebp)
  801eb5:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  801eb8:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  801ebb:	8b 7d 14             	mov    0x14(%ebp),%edi
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  801ebe:	89 45 f0             	mov    %eax,-0x10(%ebp)
  n1 = nn.s.high;
  801ec1:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  801ec3:	85 ff                	test   %edi,%edi
  801ec5:	75 15                	jne    801edc <__umoddi3+0x38>
    {
      if (d0 > n1)
  801ec7:	39 f1                	cmp    %esi,%ecx
  801ec9:	0f 86 99 00 00 00    	jbe    801f68 <__umoddi3+0xc4>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801ecf:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  801ed1:	89 d0                	mov    %edx,%eax
  801ed3:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801ed5:	83 c4 20             	add    $0x20,%esp
  801ed8:	5e                   	pop    %esi
  801ed9:	5f                   	pop    %edi
  801eda:	c9                   	leave  
  801edb:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801edc:	39 f7                	cmp    %esi,%edi
  801ede:	0f 87 a4 00 00 00    	ja     801f88 <__umoddi3+0xe4>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  801ee4:	0f bd c7             	bsr    %edi,%eax
	  if (bm == 0)
  801ee7:	83 f0 1f             	xor    $0x1f,%eax
  801eea:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801eed:	0f 84 a1 00 00 00    	je     801f94 <__umoddi3+0xf0>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  801ef3:	89 f8                	mov    %edi,%eax
  801ef5:	8a 4d ec             	mov    -0x14(%ebp),%cl
  801ef8:	d3 e0                	shl    %cl,%eax
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  801efa:	bf 20 00 00 00       	mov    $0x20,%edi
  801eff:	2b 7d ec             	sub    -0x14(%ebp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  801f02:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801f05:	89 f9                	mov    %edi,%ecx
  801f07:	d3 ea                	shr    %cl,%edx
  801f09:	09 c2                	or     %eax,%edx
  801f0b:	89 55 f0             	mov    %edx,-0x10(%ebp)
	      d0 = d0 << bm;
  801f0e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f11:	8a 4d ec             	mov    -0x14(%ebp),%cl
  801f14:	d3 e0                	shl    %cl,%eax
  801f16:	89 45 f4             	mov    %eax,-0xc(%ebp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  801f19:	89 f2                	mov    %esi,%edx
  801f1b:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  801f1d:	8b 45 e8             	mov    -0x18(%ebp),%eax
  801f20:	d3 e0                	shl    %cl,%eax
  801f22:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  801f25:	8b 45 e8             	mov    -0x18(%ebp),%eax
  801f28:	89 f9                	mov    %edi,%ecx
  801f2a:	d3 e8                	shr    %cl,%eax
  801f2c:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  801f2e:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  801f30:	89 f2                	mov    %esi,%edx
  801f32:	f7 75 f0             	divl   -0x10(%ebp)
  801f35:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  801f37:	f7 65 f4             	mull   -0xc(%ebp)
  801f3a:	89 55 e8             	mov    %edx,-0x18(%ebp)
  801f3d:	89 c1                	mov    %eax,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801f3f:	39 d6                	cmp    %edx,%esi
  801f41:	72 71                	jb     801fb4 <__umoddi3+0x110>
  801f43:	74 7f                	je     801fc4 <__umoddi3+0x120>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  801f45:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801f48:	29 c8                	sub    %ecx,%eax
  801f4a:	19 d6                	sbb    %edx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  801f4c:	8a 4d ec             	mov    -0x14(%ebp),%cl
  801f4f:	d3 e8                	shr    %cl,%eax
  801f51:	89 f2                	mov    %esi,%edx
  801f53:	89 f9                	mov    %edi,%ecx
  801f55:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  801f57:	09 d0                	or     %edx,%eax
  801f59:	89 f2                	mov    %esi,%edx
  801f5b:	8a 4d ec             	mov    -0x14(%ebp),%cl
  801f5e:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801f60:	83 c4 20             	add    $0x20,%esp
  801f63:	5e                   	pop    %esi
  801f64:	5f                   	pop    %edi
  801f65:	c9                   	leave  
  801f66:	c3                   	ret    
  801f67:	90                   	nop
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  801f68:	85 c9                	test   %ecx,%ecx
  801f6a:	75 0b                	jne    801f77 <__umoddi3+0xd3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  801f6c:	b8 01 00 00 00       	mov    $0x1,%eax
  801f71:	31 d2                	xor    %edx,%edx
  801f73:	f7 f1                	div    %ecx
  801f75:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  801f77:	89 f0                	mov    %esi,%eax
  801f79:	31 d2                	xor    %edx,%edx
  801f7b:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801f7d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801f80:	f7 f1                	div    %ecx
  801f82:	e9 4a ff ff ff       	jmp    801ed1 <__umoddi3+0x2d>
  801f87:	90                   	nop
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  801f88:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801f8a:	83 c4 20             	add    $0x20,%esp
  801f8d:	5e                   	pop    %esi
  801f8e:	5f                   	pop    %edi
  801f8f:	c9                   	leave  
  801f90:	c3                   	ret    
  801f91:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801f94:	39 f7                	cmp    %esi,%edi
  801f96:	72 05                	jb     801f9d <__umoddi3+0xf9>
  801f98:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
  801f9b:	77 0c                	ja     801fa9 <__umoddi3+0x105>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  801f9d:	89 f2                	mov    %esi,%edx
  801f9f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801fa2:	29 c8                	sub    %ecx,%eax
  801fa4:	19 fa                	sbb    %edi,%edx
  801fa6:	89 45 f0             	mov    %eax,-0x10(%ebp)

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  801fa9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801fac:	83 c4 20             	add    $0x20,%esp
  801faf:	5e                   	pop    %esi
  801fb0:	5f                   	pop    %edi
  801fb1:	c9                   	leave  
  801fb2:	c3                   	ret    
  801fb3:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  801fb4:	8b 55 e8             	mov    -0x18(%ebp),%edx
  801fb7:	89 c1                	mov    %eax,%ecx
  801fb9:	2b 4d f4             	sub    -0xc(%ebp),%ecx
  801fbc:	1b 55 f0             	sbb    -0x10(%ebp),%edx
  801fbf:	eb 84                	jmp    801f45 <__umoddi3+0xa1>
  801fc1:	8d 76 00             	lea    0x0(%esi),%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801fc4:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801fc7:	72 eb                	jb     801fb4 <__umoddi3+0x110>
  801fc9:	89 f2                	mov    %esi,%edx
  801fcb:	e9 75 ff ff ff       	jmp    801f45 <__umoddi3+0xa1>
