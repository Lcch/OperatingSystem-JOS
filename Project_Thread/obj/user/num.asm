
obj/user/num.debug:     file format elf32-i386


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
  80002c:	e8 57 01 00 00       	call   800188 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <num>:
int bol = 1;
int line = 0;

void
num(int f, const char *s)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	57                   	push   %edi
  800038:	56                   	push   %esi
  800039:	53                   	push   %ebx
  80003a:	83 ec 1c             	sub    $0x1c,%esp
  80003d:	8b 75 08             	mov    0x8(%ebp),%esi
  800040:	8b 7d 0c             	mov    0xc(%ebp),%edi
	long n;
	int r;
	char c;

	while ((n = read(f, &c, 1)) > 0) {
  800043:	8d 5d e7             	lea    -0x19(%ebp),%ebx
  800046:	eb 6a                	jmp    8000b2 <num+0x7e>
		if (bol) {
  800048:	83 3d 00 30 80 00 00 	cmpl   $0x0,0x803000
  80004f:	74 26                	je     800077 <num+0x43>
			printf("%5d ", ++line);
  800051:	a1 00 40 80 00       	mov    0x804000,%eax
  800056:	40                   	inc    %eax
  800057:	a3 00 40 80 00       	mov    %eax,0x804000
  80005c:	83 ec 08             	sub    $0x8,%esp
  80005f:	50                   	push   %eax
  800060:	68 20 20 80 00       	push   $0x802020
  800065:	e8 ee 16 00 00       	call   801758 <printf>
			bol = 0;
  80006a:	c7 05 00 30 80 00 00 	movl   $0x0,0x803000
  800071:	00 00 00 
  800074:	83 c4 10             	add    $0x10,%esp
		}
		if ((r = write(1, &c, 1)) != 1)
  800077:	83 ec 04             	sub    $0x4,%esp
  80007a:	6a 01                	push   $0x1
  80007c:	53                   	push   %ebx
  80007d:	6a 01                	push   $0x1
  80007f:	e8 20 12 00 00       	call   8012a4 <write>
  800084:	83 c4 10             	add    $0x10,%esp
  800087:	83 f8 01             	cmp    $0x1,%eax
  80008a:	74 16                	je     8000a2 <num+0x6e>
			panic("write error copying %s: %e", s, r);
  80008c:	83 ec 0c             	sub    $0xc,%esp
  80008f:	50                   	push   %eax
  800090:	57                   	push   %edi
  800091:	68 25 20 80 00       	push   $0x802025
  800096:	6a 13                	push   $0x13
  800098:	68 40 20 80 00       	push   $0x802040
  80009d:	e8 4e 01 00 00       	call   8001f0 <_panic>
		if (c == '\n')
  8000a2:	80 7d e7 0a          	cmpb   $0xa,-0x19(%ebp)
  8000a6:	75 0a                	jne    8000b2 <num+0x7e>
			bol = 1;
  8000a8:	c7 05 00 30 80 00 01 	movl   $0x1,0x803000
  8000af:	00 00 00 
{
	long n;
	int r;
	char c;

	while ((n = read(f, &c, 1)) > 0) {
  8000b2:	83 ec 04             	sub    $0x4,%esp
  8000b5:	6a 01                	push   $0x1
  8000b7:	53                   	push   %ebx
  8000b8:	56                   	push   %esi
  8000b9:	e8 0a 11 00 00       	call   8011c8 <read>
  8000be:	83 c4 10             	add    $0x10,%esp
  8000c1:	85 c0                	test   %eax,%eax
  8000c3:	7f 83                	jg     800048 <num+0x14>
		if ((r = write(1, &c, 1)) != 1)
			panic("write error copying %s: %e", s, r);
		if (c == '\n')
			bol = 1;
	}
	if (n < 0)
  8000c5:	85 c0                	test   %eax,%eax
  8000c7:	79 16                	jns    8000df <num+0xab>
		panic("error reading %s: %e", s, n);
  8000c9:	83 ec 0c             	sub    $0xc,%esp
  8000cc:	50                   	push   %eax
  8000cd:	57                   	push   %edi
  8000ce:	68 4b 20 80 00       	push   $0x80204b
  8000d3:	6a 18                	push   $0x18
  8000d5:	68 40 20 80 00       	push   $0x802040
  8000da:	e8 11 01 00 00       	call   8001f0 <_panic>
}
  8000df:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8000e2:	5b                   	pop    %ebx
  8000e3:	5e                   	pop    %esi
  8000e4:	5f                   	pop    %edi
  8000e5:	c9                   	leave  
  8000e6:	c3                   	ret    

008000e7 <umain>:

void
umain(int argc, char **argv)
{
  8000e7:	55                   	push   %ebp
  8000e8:	89 e5                	mov    %esp,%ebp
  8000ea:	57                   	push   %edi
  8000eb:	56                   	push   %esi
  8000ec:	53                   	push   %ebx
  8000ed:	83 ec 1c             	sub    $0x1c,%esp
	int f, i;

	binaryname = "num";
  8000f0:	c7 05 04 30 80 00 60 	movl   $0x802060,0x803004
  8000f7:	20 80 00 
	if (argc == 1)
  8000fa:	83 7d 08 01          	cmpl   $0x1,0x8(%ebp)
  8000fe:	74 08                	je     800108 <umain+0x21>
		num(0, "<stdin>");
	else
		for (i = 1; i < argc; i++) {
  800100:	83 7d 08 01          	cmpl   $0x1,0x8(%ebp)
  800104:	7f 16                	jg     80011c <umain+0x35>
  800106:	eb 70                	jmp    800178 <umain+0x91>
{
	int f, i;

	binaryname = "num";
	if (argc == 1)
		num(0, "<stdin>");
  800108:	83 ec 08             	sub    $0x8,%esp
  80010b:	68 64 20 80 00       	push   $0x802064
  800110:	6a 00                	push   $0x0
  800112:	e8 1d ff ff ff       	call   800034 <num>
  800117:	83 c4 10             	add    $0x10,%esp
  80011a:	eb 5c                	jmp    800178 <umain+0x91>
	if (n < 0)
		panic("error reading %s: %e", s, n);
}

void
umain(int argc, char **argv)
  80011c:	8b 75 0c             	mov    0xc(%ebp),%esi
  80011f:	83 c6 04             	add    $0x4,%esi
  800122:	bf 01 00 00 00       	mov    $0x1,%edi
{
	int f, i;

	binaryname = "num";
	if (argc == 1)
		num(0, "<stdin>");
  800127:	89 75 e4             	mov    %esi,-0x1c(%ebp)
	else
		for (i = 1; i < argc; i++) {
			f = open(argv[i], O_RDONLY);
  80012a:	83 ec 08             	sub    $0x8,%esp
  80012d:	6a 00                	push   $0x0
  80012f:	ff 36                	pushl  (%esi)
  800131:	e8 96 14 00 00       	call   8015cc <open>
  800136:	89 c3                	mov    %eax,%ebx
			if (f < 0)
  800138:	83 c4 10             	add    $0x10,%esp
  80013b:	85 c0                	test   %eax,%eax
  80013d:	79 1a                	jns    800159 <umain+0x72>
				panic("can't open %s: %e", argv[i], f);
  80013f:	83 ec 0c             	sub    $0xc,%esp
  800142:	50                   	push   %eax
  800143:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800146:	ff 30                	pushl  (%eax)
  800148:	68 6c 20 80 00       	push   $0x80206c
  80014d:	6a 27                	push   $0x27
  80014f:	68 40 20 80 00       	push   $0x802040
  800154:	e8 97 00 00 00       	call   8001f0 <_panic>
			else {
				num(f, argv[i]);
  800159:	83 ec 08             	sub    $0x8,%esp
  80015c:	ff 36                	pushl  (%esi)
  80015e:	50                   	push   %eax
  80015f:	e8 d0 fe ff ff       	call   800034 <num>
				close(f);
  800164:	89 1c 24             	mov    %ebx,(%esp)
  800167:	e8 1f 0f 00 00       	call   80108b <close>

	binaryname = "num";
	if (argc == 1)
		num(0, "<stdin>");
	else
		for (i = 1; i < argc; i++) {
  80016c:	47                   	inc    %edi
  80016d:	83 c6 04             	add    $0x4,%esi
  800170:	83 c4 10             	add    $0x10,%esp
  800173:	39 7d 08             	cmp    %edi,0x8(%ebp)
  800176:	7f af                	jg     800127 <umain+0x40>
			else {
				num(f, argv[i]);
				close(f);
			}
		}
	exit();
  800178:	e8 57 00 00 00       	call   8001d4 <exit>
}
  80017d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800180:	5b                   	pop    %ebx
  800181:	5e                   	pop    %esi
  800182:	5f                   	pop    %edi
  800183:	c9                   	leave  
  800184:	c3                   	ret    
  800185:	00 00                	add    %al,(%eax)
	...

00800188 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800188:	55                   	push   %ebp
  800189:	89 e5                	mov    %esp,%ebp
  80018b:	56                   	push   %esi
  80018c:	53                   	push   %ebx
  80018d:	8b 75 08             	mov    0x8(%ebp),%esi
  800190:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs + ENVX(sys_getenvid());
  800193:	e8 1d 0b 00 00       	call   800cb5 <sys_getenvid>
  800198:	25 ff 03 00 00       	and    $0x3ff,%eax
  80019d:	89 c2                	mov    %eax,%edx
  80019f:	c1 e2 07             	shl    $0x7,%edx
  8001a2:	8d 84 82 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,4),%eax
  8001a9:	a3 08 40 80 00       	mov    %eax,0x804008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8001ae:	85 f6                	test   %esi,%esi
  8001b0:	7e 07                	jle    8001b9 <libmain+0x31>
		binaryname = argv[0];
  8001b2:	8b 03                	mov    (%ebx),%eax
  8001b4:	a3 04 30 80 00       	mov    %eax,0x803004
	// call user main routine
	umain(argc, argv);
  8001b9:	83 ec 08             	sub    $0x8,%esp
  8001bc:	53                   	push   %ebx
  8001bd:	56                   	push   %esi
  8001be:	e8 24 ff ff ff       	call   8000e7 <umain>

	// exit gracefully
	exit();
  8001c3:	e8 0c 00 00 00       	call   8001d4 <exit>
  8001c8:	83 c4 10             	add    $0x10,%esp
}
  8001cb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8001ce:	5b                   	pop    %ebx
  8001cf:	5e                   	pop    %esi
  8001d0:	c9                   	leave  
  8001d1:	c3                   	ret    
	...

008001d4 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8001d4:	55                   	push   %ebp
  8001d5:	89 e5                	mov    %esp,%ebp
  8001d7:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8001da:	e8 d7 0e 00 00       	call   8010b6 <close_all>
	sys_env_destroy(0);
  8001df:	83 ec 0c             	sub    $0xc,%esp
  8001e2:	6a 00                	push   $0x0
  8001e4:	e8 aa 0a 00 00       	call   800c93 <sys_env_destroy>
  8001e9:	83 c4 10             	add    $0x10,%esp
}
  8001ec:	c9                   	leave  
  8001ed:	c3                   	ret    
	...

008001f0 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8001f0:	55                   	push   %ebp
  8001f1:	89 e5                	mov    %esp,%ebp
  8001f3:	56                   	push   %esi
  8001f4:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8001f5:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8001f8:	8b 1d 04 30 80 00    	mov    0x803004,%ebx
  8001fe:	e8 b2 0a 00 00       	call   800cb5 <sys_getenvid>
  800203:	83 ec 0c             	sub    $0xc,%esp
  800206:	ff 75 0c             	pushl  0xc(%ebp)
  800209:	ff 75 08             	pushl  0x8(%ebp)
  80020c:	53                   	push   %ebx
  80020d:	50                   	push   %eax
  80020e:	68 88 20 80 00       	push   $0x802088
  800213:	e8 b0 00 00 00       	call   8002c8 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800218:	83 c4 18             	add    $0x18,%esp
  80021b:	56                   	push   %esi
  80021c:	ff 75 10             	pushl  0x10(%ebp)
  80021f:	e8 53 00 00 00       	call   800277 <vcprintf>
	cprintf("\n");
  800224:	c7 04 24 a7 24 80 00 	movl   $0x8024a7,(%esp)
  80022b:	e8 98 00 00 00       	call   8002c8 <cprintf>
  800230:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800233:	cc                   	int3   
  800234:	eb fd                	jmp    800233 <_panic+0x43>
	...

00800238 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800238:	55                   	push   %ebp
  800239:	89 e5                	mov    %esp,%ebp
  80023b:	53                   	push   %ebx
  80023c:	83 ec 04             	sub    $0x4,%esp
  80023f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800242:	8b 03                	mov    (%ebx),%eax
  800244:	8b 55 08             	mov    0x8(%ebp),%edx
  800247:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  80024b:	40                   	inc    %eax
  80024c:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  80024e:	3d ff 00 00 00       	cmp    $0xff,%eax
  800253:	75 1a                	jne    80026f <putch+0x37>
		sys_cputs(b->buf, b->idx);
  800255:	83 ec 08             	sub    $0x8,%esp
  800258:	68 ff 00 00 00       	push   $0xff
  80025d:	8d 43 08             	lea    0x8(%ebx),%eax
  800260:	50                   	push   %eax
  800261:	e8 e3 09 00 00       	call   800c49 <sys_cputs>
		b->idx = 0;
  800266:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80026c:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80026f:	ff 43 04             	incl   0x4(%ebx)
}
  800272:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800275:	c9                   	leave  
  800276:	c3                   	ret    

00800277 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800277:	55                   	push   %ebp
  800278:	89 e5                	mov    %esp,%ebp
  80027a:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800280:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800287:	00 00 00 
	b.cnt = 0;
  80028a:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800291:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800294:	ff 75 0c             	pushl  0xc(%ebp)
  800297:	ff 75 08             	pushl  0x8(%ebp)
  80029a:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8002a0:	50                   	push   %eax
  8002a1:	68 38 02 80 00       	push   $0x800238
  8002a6:	e8 82 01 00 00       	call   80042d <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8002ab:	83 c4 08             	add    $0x8,%esp
  8002ae:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8002b4:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8002ba:	50                   	push   %eax
  8002bb:	e8 89 09 00 00       	call   800c49 <sys_cputs>

	return b.cnt;
}
  8002c0:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8002c6:	c9                   	leave  
  8002c7:	c3                   	ret    

008002c8 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8002c8:	55                   	push   %ebp
  8002c9:	89 e5                	mov    %esp,%ebp
  8002cb:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8002ce:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8002d1:	50                   	push   %eax
  8002d2:	ff 75 08             	pushl  0x8(%ebp)
  8002d5:	e8 9d ff ff ff       	call   800277 <vcprintf>
	va_end(ap);

	return cnt;
}
  8002da:	c9                   	leave  
  8002db:	c3                   	ret    

008002dc <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8002dc:	55                   	push   %ebp
  8002dd:	89 e5                	mov    %esp,%ebp
  8002df:	57                   	push   %edi
  8002e0:	56                   	push   %esi
  8002e1:	53                   	push   %ebx
  8002e2:	83 ec 2c             	sub    $0x2c,%esp
  8002e5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8002e8:	89 d6                	mov    %edx,%esi
  8002ea:	8b 45 08             	mov    0x8(%ebp),%eax
  8002ed:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002f0:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8002f3:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8002f6:	8b 45 10             	mov    0x10(%ebp),%eax
  8002f9:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8002fc:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8002ff:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800302:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  800309:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
  80030c:	72 0c                	jb     80031a <printnum+0x3e>
  80030e:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  800311:	76 07                	jbe    80031a <printnum+0x3e>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800313:	4b                   	dec    %ebx
  800314:	85 db                	test   %ebx,%ebx
  800316:	7f 31                	jg     800349 <printnum+0x6d>
  800318:	eb 3f                	jmp    800359 <printnum+0x7d>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80031a:	83 ec 0c             	sub    $0xc,%esp
  80031d:	57                   	push   %edi
  80031e:	4b                   	dec    %ebx
  80031f:	53                   	push   %ebx
  800320:	50                   	push   %eax
  800321:	83 ec 08             	sub    $0x8,%esp
  800324:	ff 75 d4             	pushl  -0x2c(%ebp)
  800327:	ff 75 d0             	pushl  -0x30(%ebp)
  80032a:	ff 75 dc             	pushl  -0x24(%ebp)
  80032d:	ff 75 d8             	pushl  -0x28(%ebp)
  800330:	e8 9b 1a 00 00       	call   801dd0 <__udivdi3>
  800335:	83 c4 18             	add    $0x18,%esp
  800338:	52                   	push   %edx
  800339:	50                   	push   %eax
  80033a:	89 f2                	mov    %esi,%edx
  80033c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80033f:	e8 98 ff ff ff       	call   8002dc <printnum>
  800344:	83 c4 20             	add    $0x20,%esp
  800347:	eb 10                	jmp    800359 <printnum+0x7d>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800349:	83 ec 08             	sub    $0x8,%esp
  80034c:	56                   	push   %esi
  80034d:	57                   	push   %edi
  80034e:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800351:	4b                   	dec    %ebx
  800352:	83 c4 10             	add    $0x10,%esp
  800355:	85 db                	test   %ebx,%ebx
  800357:	7f f0                	jg     800349 <printnum+0x6d>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800359:	83 ec 08             	sub    $0x8,%esp
  80035c:	56                   	push   %esi
  80035d:	83 ec 04             	sub    $0x4,%esp
  800360:	ff 75 d4             	pushl  -0x2c(%ebp)
  800363:	ff 75 d0             	pushl  -0x30(%ebp)
  800366:	ff 75 dc             	pushl  -0x24(%ebp)
  800369:	ff 75 d8             	pushl  -0x28(%ebp)
  80036c:	e8 7b 1b 00 00       	call   801eec <__umoddi3>
  800371:	83 c4 14             	add    $0x14,%esp
  800374:	0f be 80 ab 20 80 00 	movsbl 0x8020ab(%eax),%eax
  80037b:	50                   	push   %eax
  80037c:	ff 55 e4             	call   *-0x1c(%ebp)
  80037f:	83 c4 10             	add    $0x10,%esp
}
  800382:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800385:	5b                   	pop    %ebx
  800386:	5e                   	pop    %esi
  800387:	5f                   	pop    %edi
  800388:	c9                   	leave  
  800389:	c3                   	ret    

0080038a <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80038a:	55                   	push   %ebp
  80038b:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80038d:	83 fa 01             	cmp    $0x1,%edx
  800390:	7e 0e                	jle    8003a0 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800392:	8b 10                	mov    (%eax),%edx
  800394:	8d 4a 08             	lea    0x8(%edx),%ecx
  800397:	89 08                	mov    %ecx,(%eax)
  800399:	8b 02                	mov    (%edx),%eax
  80039b:	8b 52 04             	mov    0x4(%edx),%edx
  80039e:	eb 22                	jmp    8003c2 <getuint+0x38>
	else if (lflag)
  8003a0:	85 d2                	test   %edx,%edx
  8003a2:	74 10                	je     8003b4 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8003a4:	8b 10                	mov    (%eax),%edx
  8003a6:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003a9:	89 08                	mov    %ecx,(%eax)
  8003ab:	8b 02                	mov    (%edx),%eax
  8003ad:	ba 00 00 00 00       	mov    $0x0,%edx
  8003b2:	eb 0e                	jmp    8003c2 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8003b4:	8b 10                	mov    (%eax),%edx
  8003b6:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003b9:	89 08                	mov    %ecx,(%eax)
  8003bb:	8b 02                	mov    (%edx),%eax
  8003bd:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8003c2:	c9                   	leave  
  8003c3:	c3                   	ret    

008003c4 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  8003c4:	55                   	push   %ebp
  8003c5:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8003c7:	83 fa 01             	cmp    $0x1,%edx
  8003ca:	7e 0e                	jle    8003da <getint+0x16>
		return va_arg(*ap, long long);
  8003cc:	8b 10                	mov    (%eax),%edx
  8003ce:	8d 4a 08             	lea    0x8(%edx),%ecx
  8003d1:	89 08                	mov    %ecx,(%eax)
  8003d3:	8b 02                	mov    (%edx),%eax
  8003d5:	8b 52 04             	mov    0x4(%edx),%edx
  8003d8:	eb 1a                	jmp    8003f4 <getint+0x30>
	else if (lflag)
  8003da:	85 d2                	test   %edx,%edx
  8003dc:	74 0c                	je     8003ea <getint+0x26>
		return va_arg(*ap, long);
  8003de:	8b 10                	mov    (%eax),%edx
  8003e0:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003e3:	89 08                	mov    %ecx,(%eax)
  8003e5:	8b 02                	mov    (%edx),%eax
  8003e7:	99                   	cltd   
  8003e8:	eb 0a                	jmp    8003f4 <getint+0x30>
	else
		return va_arg(*ap, int);
  8003ea:	8b 10                	mov    (%eax),%edx
  8003ec:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003ef:	89 08                	mov    %ecx,(%eax)
  8003f1:	8b 02                	mov    (%edx),%eax
  8003f3:	99                   	cltd   
}
  8003f4:	c9                   	leave  
  8003f5:	c3                   	ret    

008003f6 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8003f6:	55                   	push   %ebp
  8003f7:	89 e5                	mov    %esp,%ebp
  8003f9:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8003fc:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  8003ff:	8b 10                	mov    (%eax),%edx
  800401:	3b 50 04             	cmp    0x4(%eax),%edx
  800404:	73 08                	jae    80040e <sprintputch+0x18>
		*b->buf++ = ch;
  800406:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800409:	88 0a                	mov    %cl,(%edx)
  80040b:	42                   	inc    %edx
  80040c:	89 10                	mov    %edx,(%eax)
}
  80040e:	c9                   	leave  
  80040f:	c3                   	ret    

00800410 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800410:	55                   	push   %ebp
  800411:	89 e5                	mov    %esp,%ebp
  800413:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800416:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800419:	50                   	push   %eax
  80041a:	ff 75 10             	pushl  0x10(%ebp)
  80041d:	ff 75 0c             	pushl  0xc(%ebp)
  800420:	ff 75 08             	pushl  0x8(%ebp)
  800423:	e8 05 00 00 00       	call   80042d <vprintfmt>
	va_end(ap);
  800428:	83 c4 10             	add    $0x10,%esp
}
  80042b:	c9                   	leave  
  80042c:	c3                   	ret    

0080042d <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80042d:	55                   	push   %ebp
  80042e:	89 e5                	mov    %esp,%ebp
  800430:	57                   	push   %edi
  800431:	56                   	push   %esi
  800432:	53                   	push   %ebx
  800433:	83 ec 2c             	sub    $0x2c,%esp
  800436:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800439:	8b 75 10             	mov    0x10(%ebp),%esi
  80043c:	eb 13                	jmp    800451 <vprintfmt+0x24>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80043e:	85 c0                	test   %eax,%eax
  800440:	0f 84 6d 03 00 00    	je     8007b3 <vprintfmt+0x386>
				return;
			putch(ch, putdat);
  800446:	83 ec 08             	sub    $0x8,%esp
  800449:	57                   	push   %edi
  80044a:	50                   	push   %eax
  80044b:	ff 55 08             	call   *0x8(%ebp)
  80044e:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800451:	0f b6 06             	movzbl (%esi),%eax
  800454:	46                   	inc    %esi
  800455:	83 f8 25             	cmp    $0x25,%eax
  800458:	75 e4                	jne    80043e <vprintfmt+0x11>
  80045a:	c6 45 dc 20          	movb   $0x20,-0x24(%ebp)
  80045e:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  800465:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  80046c:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800473:	b9 00 00 00 00       	mov    $0x0,%ecx
  800478:	eb 28                	jmp    8004a2 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80047a:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  80047c:	c6 45 dc 2d          	movb   $0x2d,-0x24(%ebp)
  800480:	eb 20                	jmp    8004a2 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800482:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800484:	c6 45 dc 30          	movb   $0x30,-0x24(%ebp)
  800488:	eb 18                	jmp    8004a2 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80048a:	89 de                	mov    %ebx,%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  80048c:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800493:	eb 0d                	jmp    8004a2 <vprintfmt+0x75>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800495:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800498:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80049b:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004a2:	8a 06                	mov    (%esi),%al
  8004a4:	0f b6 d0             	movzbl %al,%edx
  8004a7:	8d 5e 01             	lea    0x1(%esi),%ebx
  8004aa:	83 e8 23             	sub    $0x23,%eax
  8004ad:	3c 55                	cmp    $0x55,%al
  8004af:	0f 87 e0 02 00 00    	ja     800795 <vprintfmt+0x368>
  8004b5:	0f b6 c0             	movzbl %al,%eax
  8004b8:	ff 24 85 e0 21 80 00 	jmp    *0x8021e0(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8004bf:	83 ea 30             	sub    $0x30,%edx
  8004c2:	89 55 d4             	mov    %edx,-0x2c(%ebp)
				ch = *fmt;
  8004c5:	0f be 03             	movsbl (%ebx),%eax
				if (ch < '0' || ch > '9')
  8004c8:	8d 50 d0             	lea    -0x30(%eax),%edx
  8004cb:	83 fa 09             	cmp    $0x9,%edx
  8004ce:	77 44                	ja     800514 <vprintfmt+0xe7>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004d0:	89 de                	mov    %ebx,%esi
  8004d2:	8b 55 d4             	mov    -0x2c(%ebp),%edx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8004d5:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
  8004d6:	8d 14 92             	lea    (%edx,%edx,4),%edx
  8004d9:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
  8004dd:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8004e0:	8d 58 d0             	lea    -0x30(%eax),%ebx
  8004e3:	83 fb 09             	cmp    $0x9,%ebx
  8004e6:	76 ed                	jbe    8004d5 <vprintfmt+0xa8>
  8004e8:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  8004eb:	eb 29                	jmp    800516 <vprintfmt+0xe9>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8004ed:	8b 45 14             	mov    0x14(%ebp),%eax
  8004f0:	8d 50 04             	lea    0x4(%eax),%edx
  8004f3:	89 55 14             	mov    %edx,0x14(%ebp)
  8004f6:	8b 00                	mov    (%eax),%eax
  8004f8:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004fb:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8004fd:	eb 17                	jmp    800516 <vprintfmt+0xe9>

		case '.':
			if (width < 0)
  8004ff:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800503:	78 85                	js     80048a <vprintfmt+0x5d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800505:	89 de                	mov    %ebx,%esi
  800507:	eb 99                	jmp    8004a2 <vprintfmt+0x75>
  800509:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80050b:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  800512:	eb 8e                	jmp    8004a2 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800514:	89 de                	mov    %ebx,%esi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  800516:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80051a:	79 86                	jns    8004a2 <vprintfmt+0x75>
  80051c:	e9 74 ff ff ff       	jmp    800495 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800521:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800522:	89 de                	mov    %ebx,%esi
  800524:	e9 79 ff ff ff       	jmp    8004a2 <vprintfmt+0x75>
  800529:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80052c:	8b 45 14             	mov    0x14(%ebp),%eax
  80052f:	8d 50 04             	lea    0x4(%eax),%edx
  800532:	89 55 14             	mov    %edx,0x14(%ebp)
  800535:	83 ec 08             	sub    $0x8,%esp
  800538:	57                   	push   %edi
  800539:	ff 30                	pushl  (%eax)
  80053b:	ff 55 08             	call   *0x8(%ebp)
			break;
  80053e:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800541:	8b 75 d8             	mov    -0x28(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800544:	e9 08 ff ff ff       	jmp    800451 <vprintfmt+0x24>
  800549:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  80054c:	8b 45 14             	mov    0x14(%ebp),%eax
  80054f:	8d 50 04             	lea    0x4(%eax),%edx
  800552:	89 55 14             	mov    %edx,0x14(%ebp)
  800555:	8b 00                	mov    (%eax),%eax
  800557:	85 c0                	test   %eax,%eax
  800559:	79 02                	jns    80055d <vprintfmt+0x130>
  80055b:	f7 d8                	neg    %eax
  80055d:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80055f:	83 f8 0f             	cmp    $0xf,%eax
  800562:	7f 0b                	jg     80056f <vprintfmt+0x142>
  800564:	8b 04 85 40 23 80 00 	mov    0x802340(,%eax,4),%eax
  80056b:	85 c0                	test   %eax,%eax
  80056d:	75 1a                	jne    800589 <vprintfmt+0x15c>
				printfmt(putch, putdat, "error %d", err);
  80056f:	52                   	push   %edx
  800570:	68 c3 20 80 00       	push   $0x8020c3
  800575:	57                   	push   %edi
  800576:	ff 75 08             	pushl  0x8(%ebp)
  800579:	e8 92 fe ff ff       	call   800410 <printfmt>
  80057e:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800581:	8b 75 d8             	mov    -0x28(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800584:	e9 c8 fe ff ff       	jmp    800451 <vprintfmt+0x24>
			else
				printfmt(putch, putdat, "%s", p);
  800589:	50                   	push   %eax
  80058a:	68 75 24 80 00       	push   $0x802475
  80058f:	57                   	push   %edi
  800590:	ff 75 08             	pushl  0x8(%ebp)
  800593:	e8 78 fe ff ff       	call   800410 <printfmt>
  800598:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80059b:	8b 75 d8             	mov    -0x28(%ebp),%esi
  80059e:	e9 ae fe ff ff       	jmp    800451 <vprintfmt+0x24>
  8005a3:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  8005a6:	89 de                	mov    %ebx,%esi
  8005a8:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  8005ab:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8005ae:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b1:	8d 50 04             	lea    0x4(%eax),%edx
  8005b4:	89 55 14             	mov    %edx,0x14(%ebp)
  8005b7:	8b 00                	mov    (%eax),%eax
  8005b9:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8005bc:	85 c0                	test   %eax,%eax
  8005be:	75 07                	jne    8005c7 <vprintfmt+0x19a>
				p = "(null)";
  8005c0:	c7 45 d0 bc 20 80 00 	movl   $0x8020bc,-0x30(%ebp)
			if (width > 0 && padc != '-')
  8005c7:	85 db                	test   %ebx,%ebx
  8005c9:	7e 42                	jle    80060d <vprintfmt+0x1e0>
  8005cb:	80 7d dc 2d          	cmpb   $0x2d,-0x24(%ebp)
  8005cf:	74 3c                	je     80060d <vprintfmt+0x1e0>
				for (width -= strnlen(p, precision); width > 0; width--)
  8005d1:	83 ec 08             	sub    $0x8,%esp
  8005d4:	51                   	push   %ecx
  8005d5:	ff 75 d0             	pushl  -0x30(%ebp)
  8005d8:	e8 6f 02 00 00       	call   80084c <strnlen>
  8005dd:	29 c3                	sub    %eax,%ebx
  8005df:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8005e2:	83 c4 10             	add    $0x10,%esp
  8005e5:	85 db                	test   %ebx,%ebx
  8005e7:	7e 24                	jle    80060d <vprintfmt+0x1e0>
					putch(padc, putdat);
  8005e9:	0f be 5d dc          	movsbl -0x24(%ebp),%ebx
  8005ed:	89 75 dc             	mov    %esi,-0x24(%ebp)
  8005f0:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  8005f3:	83 ec 08             	sub    $0x8,%esp
  8005f6:	57                   	push   %edi
  8005f7:	53                   	push   %ebx
  8005f8:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005fb:	4e                   	dec    %esi
  8005fc:	83 c4 10             	add    $0x10,%esp
  8005ff:	85 f6                	test   %esi,%esi
  800601:	7f f0                	jg     8005f3 <vprintfmt+0x1c6>
  800603:	8b 75 dc             	mov    -0x24(%ebp),%esi
  800606:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80060d:	8b 55 d0             	mov    -0x30(%ebp),%edx
  800610:	0f be 02             	movsbl (%edx),%eax
  800613:	85 c0                	test   %eax,%eax
  800615:	75 47                	jne    80065e <vprintfmt+0x231>
  800617:	eb 37                	jmp    800650 <vprintfmt+0x223>
				if (altflag && (ch < ' ' || ch > '~'))
  800619:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80061d:	74 16                	je     800635 <vprintfmt+0x208>
  80061f:	8d 50 e0             	lea    -0x20(%eax),%edx
  800622:	83 fa 5e             	cmp    $0x5e,%edx
  800625:	76 0e                	jbe    800635 <vprintfmt+0x208>
					putch('?', putdat);
  800627:	83 ec 08             	sub    $0x8,%esp
  80062a:	57                   	push   %edi
  80062b:	6a 3f                	push   $0x3f
  80062d:	ff 55 08             	call   *0x8(%ebp)
  800630:	83 c4 10             	add    $0x10,%esp
  800633:	eb 0b                	jmp    800640 <vprintfmt+0x213>
				else
					putch(ch, putdat);
  800635:	83 ec 08             	sub    $0x8,%esp
  800638:	57                   	push   %edi
  800639:	50                   	push   %eax
  80063a:	ff 55 08             	call   *0x8(%ebp)
  80063d:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800640:	ff 4d e4             	decl   -0x1c(%ebp)
  800643:	0f be 03             	movsbl (%ebx),%eax
  800646:	85 c0                	test   %eax,%eax
  800648:	74 03                	je     80064d <vprintfmt+0x220>
  80064a:	43                   	inc    %ebx
  80064b:	eb 1b                	jmp    800668 <vprintfmt+0x23b>
  80064d:	8b 75 dc             	mov    -0x24(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800650:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800654:	7f 1e                	jg     800674 <vprintfmt+0x247>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800656:	8b 75 d8             	mov    -0x28(%ebp),%esi
  800659:	e9 f3 fd ff ff       	jmp    800451 <vprintfmt+0x24>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80065e:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800661:	43                   	inc    %ebx
  800662:	89 75 dc             	mov    %esi,-0x24(%ebp)
  800665:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  800668:	85 f6                	test   %esi,%esi
  80066a:	78 ad                	js     800619 <vprintfmt+0x1ec>
  80066c:	4e                   	dec    %esi
  80066d:	79 aa                	jns    800619 <vprintfmt+0x1ec>
  80066f:	8b 75 dc             	mov    -0x24(%ebp),%esi
  800672:	eb dc                	jmp    800650 <vprintfmt+0x223>
  800674:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800677:	83 ec 08             	sub    $0x8,%esp
  80067a:	57                   	push   %edi
  80067b:	6a 20                	push   $0x20
  80067d:	ff 55 08             	call   *0x8(%ebp)
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800680:	4b                   	dec    %ebx
  800681:	83 c4 10             	add    $0x10,%esp
  800684:	85 db                	test   %ebx,%ebx
  800686:	7f ef                	jg     800677 <vprintfmt+0x24a>
  800688:	e9 c4 fd ff ff       	jmp    800451 <vprintfmt+0x24>
  80068d:	89 5d d8             	mov    %ebx,-0x28(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800690:	89 ca                	mov    %ecx,%edx
  800692:	8d 45 14             	lea    0x14(%ebp),%eax
  800695:	e8 2a fd ff ff       	call   8003c4 <getint>
  80069a:	89 c3                	mov    %eax,%ebx
  80069c:	89 d6                	mov    %edx,%esi
			if ((long long) num < 0) {
  80069e:	85 d2                	test   %edx,%edx
  8006a0:	78 0a                	js     8006ac <vprintfmt+0x27f>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8006a2:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006a7:	e9 b0 00 00 00       	jmp    80075c <vprintfmt+0x32f>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  8006ac:	83 ec 08             	sub    $0x8,%esp
  8006af:	57                   	push   %edi
  8006b0:	6a 2d                	push   $0x2d
  8006b2:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8006b5:	f7 db                	neg    %ebx
  8006b7:	83 d6 00             	adc    $0x0,%esi
  8006ba:	f7 de                	neg    %esi
  8006bc:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8006bf:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006c4:	e9 93 00 00 00       	jmp    80075c <vprintfmt+0x32f>
  8006c9:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8006cc:	89 ca                	mov    %ecx,%edx
  8006ce:	8d 45 14             	lea    0x14(%ebp),%eax
  8006d1:	e8 b4 fc ff ff       	call   80038a <getuint>
  8006d6:	89 c3                	mov    %eax,%ebx
  8006d8:	89 d6                	mov    %edx,%esi
			base = 10;
  8006da:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  8006df:	eb 7b                	jmp    80075c <vprintfmt+0x32f>
  8006e1:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
  8006e4:	89 ca                	mov    %ecx,%edx
  8006e6:	8d 45 14             	lea    0x14(%ebp),%eax
  8006e9:	e8 d6 fc ff ff       	call   8003c4 <getint>
  8006ee:	89 c3                	mov    %eax,%ebx
  8006f0:	89 d6                	mov    %edx,%esi
            if ((long long) num < 0) {
  8006f2:	85 d2                	test   %edx,%edx
  8006f4:	78 07                	js     8006fd <vprintfmt+0x2d0>
                putch('-', putdat);
                num = -(long long) num;
            }
            base = 8;
  8006f6:	b8 08 00 00 00       	mov    $0x8,%eax
  8006fb:	eb 5f                	jmp    80075c <vprintfmt+0x32f>
		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
            if ((long long) num < 0) {
                putch('-', putdat);
  8006fd:	83 ec 08             	sub    $0x8,%esp
  800700:	57                   	push   %edi
  800701:	6a 2d                	push   $0x2d
  800703:	ff 55 08             	call   *0x8(%ebp)
                num = -(long long) num;
  800706:	f7 db                	neg    %ebx
  800708:	83 d6 00             	adc    $0x0,%esi
  80070b:	f7 de                	neg    %esi
  80070d:	83 c4 10             	add    $0x10,%esp
            }
            base = 8;
  800710:	b8 08 00 00 00       	mov    $0x8,%eax
  800715:	eb 45                	jmp    80075c <vprintfmt+0x32f>
  800717:	89 5d d8             	mov    %ebx,-0x28(%ebp)
            goto number;

        // pointer
		case 'p':
			putch('0', putdat);
  80071a:	83 ec 08             	sub    $0x8,%esp
  80071d:	57                   	push   %edi
  80071e:	6a 30                	push   $0x30
  800720:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800723:	83 c4 08             	add    $0x8,%esp
  800726:	57                   	push   %edi
  800727:	6a 78                	push   $0x78
  800729:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80072c:	8b 45 14             	mov    0x14(%ebp),%eax
  80072f:	8d 50 04             	lea    0x4(%eax),%edx
  800732:	89 55 14             	mov    %edx,0x14(%ebp)

        // pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800735:	8b 18                	mov    (%eax),%ebx
  800737:	be 00 00 00 00       	mov    $0x0,%esi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80073c:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80073f:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800744:	eb 16                	jmp    80075c <vprintfmt+0x32f>
  800746:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800749:	89 ca                	mov    %ecx,%edx
  80074b:	8d 45 14             	lea    0x14(%ebp),%eax
  80074e:	e8 37 fc ff ff       	call   80038a <getuint>
  800753:	89 c3                	mov    %eax,%ebx
  800755:	89 d6                	mov    %edx,%esi
			base = 16;
  800757:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  80075c:	83 ec 0c             	sub    $0xc,%esp
  80075f:	0f be 55 dc          	movsbl -0x24(%ebp),%edx
  800763:	52                   	push   %edx
  800764:	ff 75 e4             	pushl  -0x1c(%ebp)
  800767:	50                   	push   %eax
  800768:	56                   	push   %esi
  800769:	53                   	push   %ebx
  80076a:	89 fa                	mov    %edi,%edx
  80076c:	8b 45 08             	mov    0x8(%ebp),%eax
  80076f:	e8 68 fb ff ff       	call   8002dc <printnum>
			break;
  800774:	83 c4 20             	add    $0x20,%esp
  800777:	8b 75 d8             	mov    -0x28(%ebp),%esi
  80077a:	e9 d2 fc ff ff       	jmp    800451 <vprintfmt+0x24>
  80077f:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800782:	83 ec 08             	sub    $0x8,%esp
  800785:	57                   	push   %edi
  800786:	52                   	push   %edx
  800787:	ff 55 08             	call   *0x8(%ebp)
			break;
  80078a:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80078d:	8b 75 d8             	mov    -0x28(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800790:	e9 bc fc ff ff       	jmp    800451 <vprintfmt+0x24>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800795:	83 ec 08             	sub    $0x8,%esp
  800798:	57                   	push   %edi
  800799:	6a 25                	push   $0x25
  80079b:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  80079e:	83 c4 10             	add    $0x10,%esp
  8007a1:	eb 02                	jmp    8007a5 <vprintfmt+0x378>
  8007a3:	89 c6                	mov    %eax,%esi
  8007a5:	8d 46 ff             	lea    -0x1(%esi),%eax
  8007a8:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  8007ac:	75 f5                	jne    8007a3 <vprintfmt+0x376>
  8007ae:	e9 9e fc ff ff       	jmp    800451 <vprintfmt+0x24>
				/* do nothing */;
			break;
		}
	}
}
  8007b3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8007b6:	5b                   	pop    %ebx
  8007b7:	5e                   	pop    %esi
  8007b8:	5f                   	pop    %edi
  8007b9:	c9                   	leave  
  8007ba:	c3                   	ret    

008007bb <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8007bb:	55                   	push   %ebp
  8007bc:	89 e5                	mov    %esp,%ebp
  8007be:	83 ec 18             	sub    $0x18,%esp
  8007c1:	8b 45 08             	mov    0x8(%ebp),%eax
  8007c4:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8007c7:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8007ca:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8007ce:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8007d1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8007d8:	85 c0                	test   %eax,%eax
  8007da:	74 26                	je     800802 <vsnprintf+0x47>
  8007dc:	85 d2                	test   %edx,%edx
  8007de:	7e 29                	jle    800809 <vsnprintf+0x4e>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8007e0:	ff 75 14             	pushl  0x14(%ebp)
  8007e3:	ff 75 10             	pushl  0x10(%ebp)
  8007e6:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8007e9:	50                   	push   %eax
  8007ea:	68 f6 03 80 00       	push   $0x8003f6
  8007ef:	e8 39 fc ff ff       	call   80042d <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8007f4:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007f7:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8007fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007fd:	83 c4 10             	add    $0x10,%esp
  800800:	eb 0c                	jmp    80080e <vsnprintf+0x53>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800802:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800807:	eb 05                	jmp    80080e <vsnprintf+0x53>
  800809:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80080e:	c9                   	leave  
  80080f:	c3                   	ret    

00800810 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800810:	55                   	push   %ebp
  800811:	89 e5                	mov    %esp,%ebp
  800813:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800816:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800819:	50                   	push   %eax
  80081a:	ff 75 10             	pushl  0x10(%ebp)
  80081d:	ff 75 0c             	pushl  0xc(%ebp)
  800820:	ff 75 08             	pushl  0x8(%ebp)
  800823:	e8 93 ff ff ff       	call   8007bb <vsnprintf>
	va_end(ap);

	return rc;
}
  800828:	c9                   	leave  
  800829:	c3                   	ret    
	...

0080082c <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80082c:	55                   	push   %ebp
  80082d:	89 e5                	mov    %esp,%ebp
  80082f:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800832:	80 3a 00             	cmpb   $0x0,(%edx)
  800835:	74 0e                	je     800845 <strlen+0x19>
  800837:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  80083c:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80083d:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800841:	75 f9                	jne    80083c <strlen+0x10>
  800843:	eb 05                	jmp    80084a <strlen+0x1e>
  800845:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  80084a:	c9                   	leave  
  80084b:	c3                   	ret    

0080084c <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80084c:	55                   	push   %ebp
  80084d:	89 e5                	mov    %esp,%ebp
  80084f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800852:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800855:	85 d2                	test   %edx,%edx
  800857:	74 17                	je     800870 <strnlen+0x24>
  800859:	80 39 00             	cmpb   $0x0,(%ecx)
  80085c:	74 19                	je     800877 <strnlen+0x2b>
  80085e:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800863:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800864:	39 d0                	cmp    %edx,%eax
  800866:	74 14                	je     80087c <strnlen+0x30>
  800868:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  80086c:	75 f5                	jne    800863 <strnlen+0x17>
  80086e:	eb 0c                	jmp    80087c <strnlen+0x30>
  800870:	b8 00 00 00 00       	mov    $0x0,%eax
  800875:	eb 05                	jmp    80087c <strnlen+0x30>
  800877:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  80087c:	c9                   	leave  
  80087d:	c3                   	ret    

0080087e <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80087e:	55                   	push   %ebp
  80087f:	89 e5                	mov    %esp,%ebp
  800881:	53                   	push   %ebx
  800882:	8b 45 08             	mov    0x8(%ebp),%eax
  800885:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800888:	ba 00 00 00 00       	mov    $0x0,%edx
  80088d:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  800890:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800893:	42                   	inc    %edx
  800894:	84 c9                	test   %cl,%cl
  800896:	75 f5                	jne    80088d <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800898:	5b                   	pop    %ebx
  800899:	c9                   	leave  
  80089a:	c3                   	ret    

0080089b <strcat>:

char *
strcat(char *dst, const char *src)
{
  80089b:	55                   	push   %ebp
  80089c:	89 e5                	mov    %esp,%ebp
  80089e:	53                   	push   %ebx
  80089f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8008a2:	53                   	push   %ebx
  8008a3:	e8 84 ff ff ff       	call   80082c <strlen>
  8008a8:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8008ab:	ff 75 0c             	pushl  0xc(%ebp)
  8008ae:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  8008b1:	50                   	push   %eax
  8008b2:	e8 c7 ff ff ff       	call   80087e <strcpy>
	return dst;
}
  8008b7:	89 d8                	mov    %ebx,%eax
  8008b9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008bc:	c9                   	leave  
  8008bd:	c3                   	ret    

008008be <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8008be:	55                   	push   %ebp
  8008bf:	89 e5                	mov    %esp,%ebp
  8008c1:	56                   	push   %esi
  8008c2:	53                   	push   %ebx
  8008c3:	8b 45 08             	mov    0x8(%ebp),%eax
  8008c6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008c9:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008cc:	85 f6                	test   %esi,%esi
  8008ce:	74 15                	je     8008e5 <strncpy+0x27>
  8008d0:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  8008d5:	8a 1a                	mov    (%edx),%bl
  8008d7:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8008da:	80 3a 01             	cmpb   $0x1,(%edx)
  8008dd:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008e0:	41                   	inc    %ecx
  8008e1:	39 ce                	cmp    %ecx,%esi
  8008e3:	77 f0                	ja     8008d5 <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8008e5:	5b                   	pop    %ebx
  8008e6:	5e                   	pop    %esi
  8008e7:	c9                   	leave  
  8008e8:	c3                   	ret    

008008e9 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8008e9:	55                   	push   %ebp
  8008ea:	89 e5                	mov    %esp,%ebp
  8008ec:	57                   	push   %edi
  8008ed:	56                   	push   %esi
  8008ee:	53                   	push   %ebx
  8008ef:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008f2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8008f5:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8008f8:	85 f6                	test   %esi,%esi
  8008fa:	74 32                	je     80092e <strlcpy+0x45>
		while (--size > 0 && *src != '\0')
  8008fc:	83 fe 01             	cmp    $0x1,%esi
  8008ff:	74 22                	je     800923 <strlcpy+0x3a>
  800901:	8a 0b                	mov    (%ebx),%cl
  800903:	84 c9                	test   %cl,%cl
  800905:	74 20                	je     800927 <strlcpy+0x3e>
  800907:	89 f8                	mov    %edi,%eax
  800909:	ba 00 00 00 00       	mov    $0x0,%edx
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
  80090e:	83 ee 02             	sub    $0x2,%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800911:	88 08                	mov    %cl,(%eax)
  800913:	40                   	inc    %eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800914:	39 f2                	cmp    %esi,%edx
  800916:	74 11                	je     800929 <strlcpy+0x40>
  800918:	8a 4c 13 01          	mov    0x1(%ebx,%edx,1),%cl
  80091c:	42                   	inc    %edx
  80091d:	84 c9                	test   %cl,%cl
  80091f:	75 f0                	jne    800911 <strlcpy+0x28>
  800921:	eb 06                	jmp    800929 <strlcpy+0x40>
  800923:	89 f8                	mov    %edi,%eax
  800925:	eb 02                	jmp    800929 <strlcpy+0x40>
  800927:	89 f8                	mov    %edi,%eax
			*dst++ = *src++;
		*dst = '\0';
  800929:	c6 00 00             	movb   $0x0,(%eax)
  80092c:	eb 02                	jmp    800930 <strlcpy+0x47>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80092e:	89 f8                	mov    %edi,%eax
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
		*dst = '\0';
	}
	return dst - dst_in;
  800930:	29 f8                	sub    %edi,%eax
}
  800932:	5b                   	pop    %ebx
  800933:	5e                   	pop    %esi
  800934:	5f                   	pop    %edi
  800935:	c9                   	leave  
  800936:	c3                   	ret    

00800937 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800937:	55                   	push   %ebp
  800938:	89 e5                	mov    %esp,%ebp
  80093a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80093d:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800940:	8a 01                	mov    (%ecx),%al
  800942:	84 c0                	test   %al,%al
  800944:	74 10                	je     800956 <strcmp+0x1f>
  800946:	3a 02                	cmp    (%edx),%al
  800948:	75 0c                	jne    800956 <strcmp+0x1f>
		p++, q++;
  80094a:	41                   	inc    %ecx
  80094b:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80094c:	8a 01                	mov    (%ecx),%al
  80094e:	84 c0                	test   %al,%al
  800950:	74 04                	je     800956 <strcmp+0x1f>
  800952:	3a 02                	cmp    (%edx),%al
  800954:	74 f4                	je     80094a <strcmp+0x13>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800956:	0f b6 c0             	movzbl %al,%eax
  800959:	0f b6 12             	movzbl (%edx),%edx
  80095c:	29 d0                	sub    %edx,%eax
}
  80095e:	c9                   	leave  
  80095f:	c3                   	ret    

00800960 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800960:	55                   	push   %ebp
  800961:	89 e5                	mov    %esp,%ebp
  800963:	53                   	push   %ebx
  800964:	8b 55 08             	mov    0x8(%ebp),%edx
  800967:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80096a:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  80096d:	85 c0                	test   %eax,%eax
  80096f:	74 1b                	je     80098c <strncmp+0x2c>
  800971:	8a 1a                	mov    (%edx),%bl
  800973:	84 db                	test   %bl,%bl
  800975:	74 24                	je     80099b <strncmp+0x3b>
  800977:	3a 19                	cmp    (%ecx),%bl
  800979:	75 20                	jne    80099b <strncmp+0x3b>
  80097b:	48                   	dec    %eax
  80097c:	74 15                	je     800993 <strncmp+0x33>
		n--, p++, q++;
  80097e:	42                   	inc    %edx
  80097f:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800980:	8a 1a                	mov    (%edx),%bl
  800982:	84 db                	test   %bl,%bl
  800984:	74 15                	je     80099b <strncmp+0x3b>
  800986:	3a 19                	cmp    (%ecx),%bl
  800988:	74 f1                	je     80097b <strncmp+0x1b>
  80098a:	eb 0f                	jmp    80099b <strncmp+0x3b>
		n--, p++, q++;
	if (n == 0)
		return 0;
  80098c:	b8 00 00 00 00       	mov    $0x0,%eax
  800991:	eb 05                	jmp    800998 <strncmp+0x38>
  800993:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800998:	5b                   	pop    %ebx
  800999:	c9                   	leave  
  80099a:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80099b:	0f b6 02             	movzbl (%edx),%eax
  80099e:	0f b6 11             	movzbl (%ecx),%edx
  8009a1:	29 d0                	sub    %edx,%eax
  8009a3:	eb f3                	jmp    800998 <strncmp+0x38>

008009a5 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8009a5:	55                   	push   %ebp
  8009a6:	89 e5                	mov    %esp,%ebp
  8009a8:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ab:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8009ae:	8a 10                	mov    (%eax),%dl
  8009b0:	84 d2                	test   %dl,%dl
  8009b2:	74 18                	je     8009cc <strchr+0x27>
		if (*s == c)
  8009b4:	38 ca                	cmp    %cl,%dl
  8009b6:	75 06                	jne    8009be <strchr+0x19>
  8009b8:	eb 17                	jmp    8009d1 <strchr+0x2c>
  8009ba:	38 ca                	cmp    %cl,%dl
  8009bc:	74 13                	je     8009d1 <strchr+0x2c>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8009be:	40                   	inc    %eax
  8009bf:	8a 10                	mov    (%eax),%dl
  8009c1:	84 d2                	test   %dl,%dl
  8009c3:	75 f5                	jne    8009ba <strchr+0x15>
		if (*s == c)
			return (char *) s;
	return 0;
  8009c5:	b8 00 00 00 00       	mov    $0x0,%eax
  8009ca:	eb 05                	jmp    8009d1 <strchr+0x2c>
  8009cc:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009d1:	c9                   	leave  
  8009d2:	c3                   	ret    

008009d3 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8009d3:	55                   	push   %ebp
  8009d4:	89 e5                	mov    %esp,%ebp
  8009d6:	8b 45 08             	mov    0x8(%ebp),%eax
  8009d9:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8009dc:	8a 10                	mov    (%eax),%dl
  8009de:	84 d2                	test   %dl,%dl
  8009e0:	74 11                	je     8009f3 <strfind+0x20>
		if (*s == c)
  8009e2:	38 ca                	cmp    %cl,%dl
  8009e4:	75 06                	jne    8009ec <strfind+0x19>
  8009e6:	eb 0b                	jmp    8009f3 <strfind+0x20>
  8009e8:	38 ca                	cmp    %cl,%dl
  8009ea:	74 07                	je     8009f3 <strfind+0x20>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  8009ec:	40                   	inc    %eax
  8009ed:	8a 10                	mov    (%eax),%dl
  8009ef:	84 d2                	test   %dl,%dl
  8009f1:	75 f5                	jne    8009e8 <strfind+0x15>
		if (*s == c)
			break;
	return (char *) s;
}
  8009f3:	c9                   	leave  
  8009f4:	c3                   	ret    

008009f5 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8009f5:	55                   	push   %ebp
  8009f6:	89 e5                	mov    %esp,%ebp
  8009f8:	57                   	push   %edi
  8009f9:	56                   	push   %esi
  8009fa:	53                   	push   %ebx
  8009fb:	8b 7d 08             	mov    0x8(%ebp),%edi
  8009fe:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a01:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800a04:	85 c9                	test   %ecx,%ecx
  800a06:	74 30                	je     800a38 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a08:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a0e:	75 25                	jne    800a35 <memset+0x40>
  800a10:	f6 c1 03             	test   $0x3,%cl
  800a13:	75 20                	jne    800a35 <memset+0x40>
		c &= 0xFF;
  800a15:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a18:	89 d3                	mov    %edx,%ebx
  800a1a:	c1 e3 08             	shl    $0x8,%ebx
  800a1d:	89 d6                	mov    %edx,%esi
  800a1f:	c1 e6 18             	shl    $0x18,%esi
  800a22:	89 d0                	mov    %edx,%eax
  800a24:	c1 e0 10             	shl    $0x10,%eax
  800a27:	09 f0                	or     %esi,%eax
  800a29:	09 d0                	or     %edx,%eax
  800a2b:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800a2d:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800a30:	fc                   	cld    
  800a31:	f3 ab                	rep stos %eax,%es:(%edi)
  800a33:	eb 03                	jmp    800a38 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a35:	fc                   	cld    
  800a36:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a38:	89 f8                	mov    %edi,%eax
  800a3a:	5b                   	pop    %ebx
  800a3b:	5e                   	pop    %esi
  800a3c:	5f                   	pop    %edi
  800a3d:	c9                   	leave  
  800a3e:	c3                   	ret    

00800a3f <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a3f:	55                   	push   %ebp
  800a40:	89 e5                	mov    %esp,%ebp
  800a42:	57                   	push   %edi
  800a43:	56                   	push   %esi
  800a44:	8b 45 08             	mov    0x8(%ebp),%eax
  800a47:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a4a:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a4d:	39 c6                	cmp    %eax,%esi
  800a4f:	73 34                	jae    800a85 <memmove+0x46>
  800a51:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a54:	39 d0                	cmp    %edx,%eax
  800a56:	73 2d                	jae    800a85 <memmove+0x46>
		s += n;
		d += n;
  800a58:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a5b:	f6 c2 03             	test   $0x3,%dl
  800a5e:	75 1b                	jne    800a7b <memmove+0x3c>
  800a60:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a66:	75 13                	jne    800a7b <memmove+0x3c>
  800a68:	f6 c1 03             	test   $0x3,%cl
  800a6b:	75 0e                	jne    800a7b <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800a6d:	83 ef 04             	sub    $0x4,%edi
  800a70:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a73:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800a76:	fd                   	std    
  800a77:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a79:	eb 07                	jmp    800a82 <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800a7b:	4f                   	dec    %edi
  800a7c:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800a7f:	fd                   	std    
  800a80:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a82:	fc                   	cld    
  800a83:	eb 20                	jmp    800aa5 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a85:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a8b:	75 13                	jne    800aa0 <memmove+0x61>
  800a8d:	a8 03                	test   $0x3,%al
  800a8f:	75 0f                	jne    800aa0 <memmove+0x61>
  800a91:	f6 c1 03             	test   $0x3,%cl
  800a94:	75 0a                	jne    800aa0 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800a96:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800a99:	89 c7                	mov    %eax,%edi
  800a9b:	fc                   	cld    
  800a9c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a9e:	eb 05                	jmp    800aa5 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800aa0:	89 c7                	mov    %eax,%edi
  800aa2:	fc                   	cld    
  800aa3:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800aa5:	5e                   	pop    %esi
  800aa6:	5f                   	pop    %edi
  800aa7:	c9                   	leave  
  800aa8:	c3                   	ret    

00800aa9 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800aa9:	55                   	push   %ebp
  800aaa:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800aac:	ff 75 10             	pushl  0x10(%ebp)
  800aaf:	ff 75 0c             	pushl  0xc(%ebp)
  800ab2:	ff 75 08             	pushl  0x8(%ebp)
  800ab5:	e8 85 ff ff ff       	call   800a3f <memmove>
}
  800aba:	c9                   	leave  
  800abb:	c3                   	ret    

00800abc <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800abc:	55                   	push   %ebp
  800abd:	89 e5                	mov    %esp,%ebp
  800abf:	57                   	push   %edi
  800ac0:	56                   	push   %esi
  800ac1:	53                   	push   %ebx
  800ac2:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800ac5:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ac8:	8b 7d 10             	mov    0x10(%ebp),%edi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800acb:	85 ff                	test   %edi,%edi
  800acd:	74 32                	je     800b01 <memcmp+0x45>
		if (*s1 != *s2)
  800acf:	8a 03                	mov    (%ebx),%al
  800ad1:	8a 0e                	mov    (%esi),%cl
  800ad3:	38 c8                	cmp    %cl,%al
  800ad5:	74 19                	je     800af0 <memcmp+0x34>
  800ad7:	eb 0d                	jmp    800ae6 <memcmp+0x2a>
  800ad9:	8a 44 13 01          	mov    0x1(%ebx,%edx,1),%al
  800add:	8a 4c 16 01          	mov    0x1(%esi,%edx,1),%cl
  800ae1:	42                   	inc    %edx
  800ae2:	38 c8                	cmp    %cl,%al
  800ae4:	74 10                	je     800af6 <memcmp+0x3a>
			return (int) *s1 - (int) *s2;
  800ae6:	0f b6 c0             	movzbl %al,%eax
  800ae9:	0f b6 c9             	movzbl %cl,%ecx
  800aec:	29 c8                	sub    %ecx,%eax
  800aee:	eb 16                	jmp    800b06 <memcmp+0x4a>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800af0:	4f                   	dec    %edi
  800af1:	ba 00 00 00 00       	mov    $0x0,%edx
  800af6:	39 fa                	cmp    %edi,%edx
  800af8:	75 df                	jne    800ad9 <memcmp+0x1d>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800afa:	b8 00 00 00 00       	mov    $0x0,%eax
  800aff:	eb 05                	jmp    800b06 <memcmp+0x4a>
  800b01:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b06:	5b                   	pop    %ebx
  800b07:	5e                   	pop    %esi
  800b08:	5f                   	pop    %edi
  800b09:	c9                   	leave  
  800b0a:	c3                   	ret    

00800b0b <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b0b:	55                   	push   %ebp
  800b0c:	89 e5                	mov    %esp,%ebp
  800b0e:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800b11:	89 c2                	mov    %eax,%edx
  800b13:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800b16:	39 d0                	cmp    %edx,%eax
  800b18:	73 12                	jae    800b2c <memfind+0x21>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b1a:	8a 4d 0c             	mov    0xc(%ebp),%cl
  800b1d:	38 08                	cmp    %cl,(%eax)
  800b1f:	75 06                	jne    800b27 <memfind+0x1c>
  800b21:	eb 09                	jmp    800b2c <memfind+0x21>
  800b23:	38 08                	cmp    %cl,(%eax)
  800b25:	74 05                	je     800b2c <memfind+0x21>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800b27:	40                   	inc    %eax
  800b28:	39 c2                	cmp    %eax,%edx
  800b2a:	77 f7                	ja     800b23 <memfind+0x18>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800b2c:	c9                   	leave  
  800b2d:	c3                   	ret    

00800b2e <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b2e:	55                   	push   %ebp
  800b2f:	89 e5                	mov    %esp,%ebp
  800b31:	57                   	push   %edi
  800b32:	56                   	push   %esi
  800b33:	53                   	push   %ebx
  800b34:	8b 55 08             	mov    0x8(%ebp),%edx
  800b37:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b3a:	eb 01                	jmp    800b3d <strtol+0xf>
		s++;
  800b3c:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b3d:	8a 02                	mov    (%edx),%al
  800b3f:	3c 20                	cmp    $0x20,%al
  800b41:	74 f9                	je     800b3c <strtol+0xe>
  800b43:	3c 09                	cmp    $0x9,%al
  800b45:	74 f5                	je     800b3c <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800b47:	3c 2b                	cmp    $0x2b,%al
  800b49:	75 08                	jne    800b53 <strtol+0x25>
		s++;
  800b4b:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800b4c:	bf 00 00 00 00       	mov    $0x0,%edi
  800b51:	eb 13                	jmp    800b66 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800b53:	3c 2d                	cmp    $0x2d,%al
  800b55:	75 0a                	jne    800b61 <strtol+0x33>
		s++, neg = 1;
  800b57:	8d 52 01             	lea    0x1(%edx),%edx
  800b5a:	bf 01 00 00 00       	mov    $0x1,%edi
  800b5f:	eb 05                	jmp    800b66 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800b61:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b66:	85 db                	test   %ebx,%ebx
  800b68:	74 05                	je     800b6f <strtol+0x41>
  800b6a:	83 fb 10             	cmp    $0x10,%ebx
  800b6d:	75 28                	jne    800b97 <strtol+0x69>
  800b6f:	8a 02                	mov    (%edx),%al
  800b71:	3c 30                	cmp    $0x30,%al
  800b73:	75 10                	jne    800b85 <strtol+0x57>
  800b75:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800b79:	75 0a                	jne    800b85 <strtol+0x57>
		s += 2, base = 16;
  800b7b:	83 c2 02             	add    $0x2,%edx
  800b7e:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b83:	eb 12                	jmp    800b97 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800b85:	85 db                	test   %ebx,%ebx
  800b87:	75 0e                	jne    800b97 <strtol+0x69>
  800b89:	3c 30                	cmp    $0x30,%al
  800b8b:	75 05                	jne    800b92 <strtol+0x64>
		s++, base = 8;
  800b8d:	42                   	inc    %edx
  800b8e:	b3 08                	mov    $0x8,%bl
  800b90:	eb 05                	jmp    800b97 <strtol+0x69>
	else if (base == 0)
		base = 10;
  800b92:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800b97:	b8 00 00 00 00       	mov    $0x0,%eax
  800b9c:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800b9e:	8a 0a                	mov    (%edx),%cl
  800ba0:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800ba3:	80 fb 09             	cmp    $0x9,%bl
  800ba6:	77 08                	ja     800bb0 <strtol+0x82>
			dig = *s - '0';
  800ba8:	0f be c9             	movsbl %cl,%ecx
  800bab:	83 e9 30             	sub    $0x30,%ecx
  800bae:	eb 1e                	jmp    800bce <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800bb0:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800bb3:	80 fb 19             	cmp    $0x19,%bl
  800bb6:	77 08                	ja     800bc0 <strtol+0x92>
			dig = *s - 'a' + 10;
  800bb8:	0f be c9             	movsbl %cl,%ecx
  800bbb:	83 e9 57             	sub    $0x57,%ecx
  800bbe:	eb 0e                	jmp    800bce <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800bc0:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800bc3:	80 fb 19             	cmp    $0x19,%bl
  800bc6:	77 13                	ja     800bdb <strtol+0xad>
			dig = *s - 'A' + 10;
  800bc8:	0f be c9             	movsbl %cl,%ecx
  800bcb:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800bce:	39 f1                	cmp    %esi,%ecx
  800bd0:	7d 0d                	jge    800bdf <strtol+0xb1>
			break;
		s++, val = (val * base) + dig;
  800bd2:	42                   	inc    %edx
  800bd3:	0f af c6             	imul   %esi,%eax
  800bd6:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  800bd9:	eb c3                	jmp    800b9e <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800bdb:	89 c1                	mov    %eax,%ecx
  800bdd:	eb 02                	jmp    800be1 <strtol+0xb3>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800bdf:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800be1:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800be5:	74 05                	je     800bec <strtol+0xbe>
		*endptr = (char *) s;
  800be7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800bea:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800bec:	85 ff                	test   %edi,%edi
  800bee:	74 04                	je     800bf4 <strtol+0xc6>
  800bf0:	89 c8                	mov    %ecx,%eax
  800bf2:	f7 d8                	neg    %eax
}
  800bf4:	5b                   	pop    %ebx
  800bf5:	5e                   	pop    %esi
  800bf6:	5f                   	pop    %edi
  800bf7:	c9                   	leave  
  800bf8:	c3                   	ret    
  800bf9:	00 00                	add    %al,(%eax)
	...

00800bfc <syscall>:
	return ret;
}

static int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800bfc:	55                   	push   %ebp
  800bfd:	89 e5                	mov    %esp,%ebp
  800bff:	57                   	push   %edi
  800c00:	56                   	push   %esi
  800c01:	53                   	push   %ebx
  800c02:	83 ec 1c             	sub    $0x1c,%esp
  800c05:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800c08:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800c0b:	89 ca                	mov    %ecx,%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c0d:	8b 75 14             	mov    0x14(%ebp),%esi
  800c10:	8b 7d 10             	mov    0x10(%ebp),%edi
  800c13:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800c16:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c19:	cd 30                	int    $0x30
  800c1b:	89 c2                	mov    %eax,%edx
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c1d:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800c21:	74 1c                	je     800c3f <syscall+0x43>
  800c23:	85 c0                	test   %eax,%eax
  800c25:	7e 18                	jle    800c3f <syscall+0x43>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c27:	83 ec 0c             	sub    $0xc,%esp
  800c2a:	50                   	push   %eax
  800c2b:	ff 75 e4             	pushl  -0x1c(%ebp)
  800c2e:	68 9f 23 80 00       	push   $0x80239f
  800c33:	6a 42                	push   $0x42
  800c35:	68 bc 23 80 00       	push   $0x8023bc
  800c3a:	e8 b1 f5 ff ff       	call   8001f0 <_panic>

	return ret;
}
  800c3f:	89 d0                	mov    %edx,%eax
  800c41:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c44:	5b                   	pop    %ebx
  800c45:	5e                   	pop    %esi
  800c46:	5f                   	pop    %edi
  800c47:	c9                   	leave  
  800c48:	c3                   	ret    

00800c49 <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{	
  800c49:	55                   	push   %ebp
  800c4a:	89 e5                	mov    %esp,%ebp
  800c4c:	83 ec 08             	sub    $0x8,%esp
	// my_sysenter(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
	// return;
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  800c4f:	6a 00                	push   $0x0
  800c51:	6a 00                	push   $0x0
  800c53:	6a 00                	push   $0x0
  800c55:	ff 75 0c             	pushl  0xc(%ebp)
  800c58:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c5b:	ba 00 00 00 00       	mov    $0x0,%edx
  800c60:	b8 00 00 00 00       	mov    $0x0,%eax
  800c65:	e8 92 ff ff ff       	call   800bfc <syscall>
  800c6a:	83 c4 10             	add    $0x10,%esp
	return;
}
  800c6d:	c9                   	leave  
  800c6e:	c3                   	ret    

00800c6f <sys_cgetc>:

int
sys_cgetc(void)
{
  800c6f:	55                   	push   %ebp
  800c70:	89 e5                	mov    %esp,%ebp
  800c72:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_cgetc, 0, 0, 0, 0, 0, 0);
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  800c75:	6a 00                	push   $0x0
  800c77:	6a 00                	push   $0x0
  800c79:	6a 00                	push   $0x0
  800c7b:	6a 00                	push   $0x0
  800c7d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c82:	ba 00 00 00 00       	mov    $0x0,%edx
  800c87:	b8 01 00 00 00       	mov    $0x1,%eax
  800c8c:	e8 6b ff ff ff       	call   800bfc <syscall>
}
  800c91:	c9                   	leave  
  800c92:	c3                   	ret    

00800c93 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800c93:	55                   	push   %ebp
  800c94:	89 e5                	mov    %esp,%ebp
  800c96:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  800c99:	6a 00                	push   $0x0
  800c9b:	6a 00                	push   $0x0
  800c9d:	6a 00                	push   $0x0
  800c9f:	6a 00                	push   $0x0
  800ca1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ca4:	ba 01 00 00 00       	mov    $0x1,%edx
  800ca9:	b8 03 00 00 00       	mov    $0x3,%eax
  800cae:	e8 49 ff ff ff       	call   800bfc <syscall>
}
  800cb3:	c9                   	leave  
  800cb4:	c3                   	ret    

00800cb5 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800cb5:	55                   	push   %ebp
  800cb6:	89 e5                	mov    %esp,%ebp
  800cb8:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_getenvid, 0, 0, 0, 0, 0, 0);
	return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  800cbb:	6a 00                	push   $0x0
  800cbd:	6a 00                	push   $0x0
  800cbf:	6a 00                	push   $0x0
  800cc1:	6a 00                	push   $0x0
  800cc3:	b9 00 00 00 00       	mov    $0x0,%ecx
  800cc8:	ba 00 00 00 00       	mov    $0x0,%edx
  800ccd:	b8 02 00 00 00       	mov    $0x2,%eax
  800cd2:	e8 25 ff ff ff       	call   800bfc <syscall>
}
  800cd7:	c9                   	leave  
  800cd8:	c3                   	ret    

00800cd9 <sys_yield>:

void
sys_yield(void)
{
  800cd9:	55                   	push   %ebp
  800cda:	89 e5                	mov    %esp,%ebp
  800cdc:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  800cdf:	6a 00                	push   $0x0
  800ce1:	6a 00                	push   $0x0
  800ce3:	6a 00                	push   $0x0
  800ce5:	6a 00                	push   $0x0
  800ce7:	b9 00 00 00 00       	mov    $0x0,%ecx
  800cec:	ba 00 00 00 00       	mov    $0x0,%edx
  800cf1:	b8 0b 00 00 00       	mov    $0xb,%eax
  800cf6:	e8 01 ff ff ff       	call   800bfc <syscall>
  800cfb:	83 c4 10             	add    $0x10,%esp
}
  800cfe:	c9                   	leave  
  800cff:	c3                   	ret    

00800d00 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800d00:	55                   	push   %ebp
  800d01:	89 e5                	mov    %esp,%ebp
  800d03:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  800d06:	6a 00                	push   $0x0
  800d08:	6a 00                	push   $0x0
  800d0a:	ff 75 10             	pushl  0x10(%ebp)
  800d0d:	ff 75 0c             	pushl  0xc(%ebp)
  800d10:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d13:	ba 01 00 00 00       	mov    $0x1,%edx
  800d18:	b8 04 00 00 00       	mov    $0x4,%eax
  800d1d:	e8 da fe ff ff       	call   800bfc <syscall>
}
  800d22:	c9                   	leave  
  800d23:	c3                   	ret    

00800d24 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800d24:	55                   	push   %ebp
  800d25:	89 e5                	mov    %esp,%ebp
  800d27:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
  800d2a:	ff 75 18             	pushl  0x18(%ebp)
  800d2d:	ff 75 14             	pushl  0x14(%ebp)
  800d30:	ff 75 10             	pushl  0x10(%ebp)
  800d33:	ff 75 0c             	pushl  0xc(%ebp)
  800d36:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d39:	ba 01 00 00 00       	mov    $0x1,%edx
  800d3e:	b8 05 00 00 00       	mov    $0x5,%eax
  800d43:	e8 b4 fe ff ff       	call   800bfc <syscall>
}
  800d48:	c9                   	leave  
  800d49:	c3                   	ret    

00800d4a <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800d4a:	55                   	push   %ebp
  800d4b:	89 e5                	mov    %esp,%ebp
  800d4d:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  800d50:	6a 00                	push   $0x0
  800d52:	6a 00                	push   $0x0
  800d54:	6a 00                	push   $0x0
  800d56:	ff 75 0c             	pushl  0xc(%ebp)
  800d59:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d5c:	ba 01 00 00 00       	mov    $0x1,%edx
  800d61:	b8 06 00 00 00       	mov    $0x6,%eax
  800d66:	e8 91 fe ff ff       	call   800bfc <syscall>
}
  800d6b:	c9                   	leave  
  800d6c:	c3                   	ret    

00800d6d <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800d6d:	55                   	push   %ebp
  800d6e:	89 e5                	mov    %esp,%ebp
  800d70:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  800d73:	6a 00                	push   $0x0
  800d75:	6a 00                	push   $0x0
  800d77:	6a 00                	push   $0x0
  800d79:	ff 75 0c             	pushl  0xc(%ebp)
  800d7c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d7f:	ba 01 00 00 00       	mov    $0x1,%edx
  800d84:	b8 08 00 00 00       	mov    $0x8,%eax
  800d89:	e8 6e fe ff ff       	call   800bfc <syscall>
}
  800d8e:	c9                   	leave  
  800d8f:	c3                   	ret    

00800d90 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800d90:	55                   	push   %ebp
  800d91:	89 e5                	mov    %esp,%ebp
  800d93:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
  800d96:	6a 00                	push   $0x0
  800d98:	6a 00                	push   $0x0
  800d9a:	6a 00                	push   $0x0
  800d9c:	ff 75 0c             	pushl  0xc(%ebp)
  800d9f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800da2:	ba 01 00 00 00       	mov    $0x1,%edx
  800da7:	b8 09 00 00 00       	mov    $0x9,%eax
  800dac:	e8 4b fe ff ff       	call   800bfc <syscall>
}
  800db1:	c9                   	leave  
  800db2:	c3                   	ret    

00800db3 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800db3:	55                   	push   %ebp
  800db4:	89 e5                	mov    %esp,%ebp
  800db6:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  800db9:	6a 00                	push   $0x0
  800dbb:	6a 00                	push   $0x0
  800dbd:	6a 00                	push   $0x0
  800dbf:	ff 75 0c             	pushl  0xc(%ebp)
  800dc2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800dc5:	ba 01 00 00 00       	mov    $0x1,%edx
  800dca:	b8 0a 00 00 00       	mov    $0xa,%eax
  800dcf:	e8 28 fe ff ff       	call   800bfc <syscall>
}
  800dd4:	c9                   	leave  
  800dd5:	c3                   	ret    

00800dd6 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800dd6:	55                   	push   %ebp
  800dd7:	89 e5                	mov    %esp,%ebp
  800dd9:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  800ddc:	6a 00                	push   $0x0
  800dde:	ff 75 14             	pushl  0x14(%ebp)
  800de1:	ff 75 10             	pushl  0x10(%ebp)
  800de4:	ff 75 0c             	pushl  0xc(%ebp)
  800de7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800dea:	ba 00 00 00 00       	mov    $0x0,%edx
  800def:	b8 0c 00 00 00       	mov    $0xc,%eax
  800df4:	e8 03 fe ff ff       	call   800bfc <syscall>
}
  800df9:	c9                   	leave  
  800dfa:	c3                   	ret    

00800dfb <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800dfb:	55                   	push   %ebp
  800dfc:	89 e5                	mov    %esp,%ebp
  800dfe:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  800e01:	6a 00                	push   $0x0
  800e03:	6a 00                	push   $0x0
  800e05:	6a 00                	push   $0x0
  800e07:	6a 00                	push   $0x0
  800e09:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e0c:	ba 01 00 00 00       	mov    $0x1,%edx
  800e11:	b8 0d 00 00 00       	mov    $0xd,%eax
  800e16:	e8 e1 fd ff ff       	call   800bfc <syscall>
}
  800e1b:	c9                   	leave  
  800e1c:	c3                   	ret    

00800e1d <sys_set_priority>:

int
sys_set_priority(envid_t envid, uint32_t new_priority)
{
  800e1d:	55                   	push   %ebp
  800e1e:	89 e5                	mov    %esp,%ebp
  800e20:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_set_priority, 0, envid, new_priority, 0, 0, 0);
  800e23:	6a 00                	push   $0x0
  800e25:	6a 00                	push   $0x0
  800e27:	6a 00                	push   $0x0
  800e29:	ff 75 0c             	pushl  0xc(%ebp)
  800e2c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e2f:	ba 00 00 00 00       	mov    $0x0,%edx
  800e34:	b8 0e 00 00 00       	mov    $0xe,%eax
  800e39:	e8 be fd ff ff       	call   800bfc <syscall>
}
  800e3e:	c9                   	leave  
  800e3f:	c3                   	ret    

00800e40 <sys_exec>:

int
sys_exec(uint32_t eip, uint32_t esp, void * ph, uint32_t elf_phnum)
{
  800e40:	55                   	push   %ebp
  800e41:	89 e5                	mov    %esp,%ebp
  800e43:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_exec, 0, eip, esp, (uint32_t)ph, elf_phnum, 0);
  800e46:	6a 00                	push   $0x0
  800e48:	ff 75 14             	pushl  0x14(%ebp)
  800e4b:	ff 75 10             	pushl  0x10(%ebp)
  800e4e:	ff 75 0c             	pushl  0xc(%ebp)
  800e51:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e54:	ba 00 00 00 00       	mov    $0x0,%edx
  800e59:	b8 0f 00 00 00       	mov    $0xf,%eax
  800e5e:	e8 99 fd ff ff       	call   800bfc <syscall>
} 
  800e63:	c9                   	leave  
  800e64:	c3                   	ret    

00800e65 <sys_join>:

// thread:
int
sys_join(envid_t envid)
{
  800e65:	55                   	push   %ebp
  800e66:	89 e5                	mov    %esp,%ebp
  800e68:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_join, 0, envid, 0, 0, 0, 0);
  800e6b:	6a 00                	push   $0x0
  800e6d:	6a 00                	push   $0x0
  800e6f:	6a 00                	push   $0x0
  800e71:	6a 00                	push   $0x0
  800e73:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e76:	ba 00 00 00 00       	mov    $0x0,%edx
  800e7b:	b8 11 00 00 00       	mov    $0x11,%eax
  800e80:	e8 77 fd ff ff       	call   800bfc <syscall>
}
  800e85:	c9                   	leave  
  800e86:	c3                   	ret    

00800e87 <sys_getpid>:

envid_t
sys_getpid(void)
{
  800e87:	55                   	push   %ebp
  800e88:	89 e5                	mov    %esp,%ebp
  800e8a:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_getpid, 0, 0, 0, 0, 0, 0);
  800e8d:	6a 00                	push   $0x0
  800e8f:	6a 00                	push   $0x0
  800e91:	6a 00                	push   $0x0
  800e93:	6a 00                	push   $0x0
  800e95:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e9a:	ba 00 00 00 00       	mov    $0x0,%edx
  800e9f:	b8 10 00 00 00       	mov    $0x10,%eax
  800ea4:	e8 53 fd ff ff       	call   800bfc <syscall>
  800ea9:	c9                   	leave  
  800eaa:	c3                   	ret    
	...

00800eac <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800eac:	55                   	push   %ebp
  800ead:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800eaf:	8b 45 08             	mov    0x8(%ebp),%eax
  800eb2:	05 00 00 00 30       	add    $0x30000000,%eax
  800eb7:	c1 e8 0c             	shr    $0xc,%eax
}
  800eba:	c9                   	leave  
  800ebb:	c3                   	ret    

00800ebc <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800ebc:	55                   	push   %ebp
  800ebd:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800ebf:	ff 75 08             	pushl  0x8(%ebp)
  800ec2:	e8 e5 ff ff ff       	call   800eac <fd2num>
  800ec7:	83 c4 04             	add    $0x4,%esp
  800eca:	05 20 00 0d 00       	add    $0xd0020,%eax
  800ecf:	c1 e0 0c             	shl    $0xc,%eax
}
  800ed2:	c9                   	leave  
  800ed3:	c3                   	ret    

00800ed4 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800ed4:	55                   	push   %ebp
  800ed5:	89 e5                	mov    %esp,%ebp
  800ed7:	53                   	push   %ebx
  800ed8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800edb:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  800ee0:	a8 01                	test   $0x1,%al
  800ee2:	74 34                	je     800f18 <fd_alloc+0x44>
  800ee4:	a1 00 00 74 ef       	mov    0xef740000,%eax
  800ee9:	a8 01                	test   $0x1,%al
  800eeb:	74 32                	je     800f1f <fd_alloc+0x4b>
  800eed:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
  800ef2:	89 c1                	mov    %eax,%ecx
  800ef4:	89 c2                	mov    %eax,%edx
  800ef6:	c1 ea 16             	shr    $0x16,%edx
  800ef9:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800f00:	f6 c2 01             	test   $0x1,%dl
  800f03:	74 1f                	je     800f24 <fd_alloc+0x50>
  800f05:	89 c2                	mov    %eax,%edx
  800f07:	c1 ea 0c             	shr    $0xc,%edx
  800f0a:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800f11:	f6 c2 01             	test   $0x1,%dl
  800f14:	75 17                	jne    800f2d <fd_alloc+0x59>
  800f16:	eb 0c                	jmp    800f24 <fd_alloc+0x50>
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  800f18:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
  800f1d:	eb 05                	jmp    800f24 <fd_alloc+0x50>
  800f1f:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
  800f24:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  800f26:	b8 00 00 00 00       	mov    $0x0,%eax
  800f2b:	eb 17                	jmp    800f44 <fd_alloc+0x70>
  800f2d:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800f32:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800f37:	75 b9                	jne    800ef2 <fd_alloc+0x1e>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800f39:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  800f3f:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800f44:	5b                   	pop    %ebx
  800f45:	c9                   	leave  
  800f46:	c3                   	ret    

00800f47 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800f47:	55                   	push   %ebp
  800f48:	89 e5                	mov    %esp,%ebp
  800f4a:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800f4d:	83 f8 1f             	cmp    $0x1f,%eax
  800f50:	77 36                	ja     800f88 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800f52:	05 00 00 0d 00       	add    $0xd0000,%eax
  800f57:	c1 e0 0c             	shl    $0xc,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800f5a:	89 c2                	mov    %eax,%edx
  800f5c:	c1 ea 16             	shr    $0x16,%edx
  800f5f:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800f66:	f6 c2 01             	test   $0x1,%dl
  800f69:	74 24                	je     800f8f <fd_lookup+0x48>
  800f6b:	89 c2                	mov    %eax,%edx
  800f6d:	c1 ea 0c             	shr    $0xc,%edx
  800f70:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800f77:	f6 c2 01             	test   $0x1,%dl
  800f7a:	74 1a                	je     800f96 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800f7c:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f7f:	89 02                	mov    %eax,(%edx)
	return 0;
  800f81:	b8 00 00 00 00       	mov    $0x0,%eax
  800f86:	eb 13                	jmp    800f9b <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800f88:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f8d:	eb 0c                	jmp    800f9b <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800f8f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f94:	eb 05                	jmp    800f9b <fd_lookup+0x54>
  800f96:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800f9b:	c9                   	leave  
  800f9c:	c3                   	ret    

00800f9d <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800f9d:	55                   	push   %ebp
  800f9e:	89 e5                	mov    %esp,%ebp
  800fa0:	53                   	push   %ebx
  800fa1:	83 ec 04             	sub    $0x4,%esp
  800fa4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800fa7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  800faa:	39 0d 08 30 80 00    	cmp    %ecx,0x803008
  800fb0:	74 0d                	je     800fbf <dev_lookup+0x22>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800fb2:	b8 00 00 00 00       	mov    $0x0,%eax
  800fb7:	eb 14                	jmp    800fcd <dev_lookup+0x30>
		if (devtab[i]->dev_id == dev_id) {
  800fb9:	39 0a                	cmp    %ecx,(%edx)
  800fbb:	75 10                	jne    800fcd <dev_lookup+0x30>
  800fbd:	eb 05                	jmp    800fc4 <dev_lookup+0x27>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800fbf:	ba 08 30 80 00       	mov    $0x803008,%edx
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
  800fc4:	89 13                	mov    %edx,(%ebx)
			return 0;
  800fc6:	b8 00 00 00 00       	mov    $0x0,%eax
  800fcb:	eb 31                	jmp    800ffe <dev_lookup+0x61>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800fcd:	40                   	inc    %eax
  800fce:	8b 14 85 4c 24 80 00 	mov    0x80244c(,%eax,4),%edx
  800fd5:	85 d2                	test   %edx,%edx
  800fd7:	75 e0                	jne    800fb9 <dev_lookup+0x1c>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800fd9:	a1 08 40 80 00       	mov    0x804008,%eax
  800fde:	8b 40 48             	mov    0x48(%eax),%eax
  800fe1:	83 ec 04             	sub    $0x4,%esp
  800fe4:	51                   	push   %ecx
  800fe5:	50                   	push   %eax
  800fe6:	68 cc 23 80 00       	push   $0x8023cc
  800feb:	e8 d8 f2 ff ff       	call   8002c8 <cprintf>
	*dev = 0;
  800ff0:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  800ff6:	83 c4 10             	add    $0x10,%esp
  800ff9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800ffe:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801001:	c9                   	leave  
  801002:	c3                   	ret    

00801003 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801003:	55                   	push   %ebp
  801004:	89 e5                	mov    %esp,%ebp
  801006:	56                   	push   %esi
  801007:	53                   	push   %ebx
  801008:	83 ec 20             	sub    $0x20,%esp
  80100b:	8b 75 08             	mov    0x8(%ebp),%esi
  80100e:	8a 45 0c             	mov    0xc(%ebp),%al
  801011:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801014:	56                   	push   %esi
  801015:	e8 92 fe ff ff       	call   800eac <fd2num>
  80101a:	8d 55 f4             	lea    -0xc(%ebp),%edx
  80101d:	89 14 24             	mov    %edx,(%esp)
  801020:	50                   	push   %eax
  801021:	e8 21 ff ff ff       	call   800f47 <fd_lookup>
  801026:	89 c3                	mov    %eax,%ebx
  801028:	83 c4 08             	add    $0x8,%esp
  80102b:	85 c0                	test   %eax,%eax
  80102d:	78 05                	js     801034 <fd_close+0x31>
	    || fd != fd2)
  80102f:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801032:	74 0d                	je     801041 <fd_close+0x3e>
		return (must_exist ? r : 0);
  801034:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  801038:	75 48                	jne    801082 <fd_close+0x7f>
  80103a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80103f:	eb 41                	jmp    801082 <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801041:	83 ec 08             	sub    $0x8,%esp
  801044:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801047:	50                   	push   %eax
  801048:	ff 36                	pushl  (%esi)
  80104a:	e8 4e ff ff ff       	call   800f9d <dev_lookup>
  80104f:	89 c3                	mov    %eax,%ebx
  801051:	83 c4 10             	add    $0x10,%esp
  801054:	85 c0                	test   %eax,%eax
  801056:	78 1c                	js     801074 <fd_close+0x71>
		if (dev->dev_close)
  801058:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80105b:	8b 40 10             	mov    0x10(%eax),%eax
  80105e:	85 c0                	test   %eax,%eax
  801060:	74 0d                	je     80106f <fd_close+0x6c>
			r = (*dev->dev_close)(fd);
  801062:	83 ec 0c             	sub    $0xc,%esp
  801065:	56                   	push   %esi
  801066:	ff d0                	call   *%eax
  801068:	89 c3                	mov    %eax,%ebx
  80106a:	83 c4 10             	add    $0x10,%esp
  80106d:	eb 05                	jmp    801074 <fd_close+0x71>
		else
			r = 0;
  80106f:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801074:	83 ec 08             	sub    $0x8,%esp
  801077:	56                   	push   %esi
  801078:	6a 00                	push   $0x0
  80107a:	e8 cb fc ff ff       	call   800d4a <sys_page_unmap>
	return r;
  80107f:	83 c4 10             	add    $0x10,%esp
}
  801082:	89 d8                	mov    %ebx,%eax
  801084:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801087:	5b                   	pop    %ebx
  801088:	5e                   	pop    %esi
  801089:	c9                   	leave  
  80108a:	c3                   	ret    

0080108b <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80108b:	55                   	push   %ebp
  80108c:	89 e5                	mov    %esp,%ebp
  80108e:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801091:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801094:	50                   	push   %eax
  801095:	ff 75 08             	pushl  0x8(%ebp)
  801098:	e8 aa fe ff ff       	call   800f47 <fd_lookup>
  80109d:	83 c4 08             	add    $0x8,%esp
  8010a0:	85 c0                	test   %eax,%eax
  8010a2:	78 10                	js     8010b4 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  8010a4:	83 ec 08             	sub    $0x8,%esp
  8010a7:	6a 01                	push   $0x1
  8010a9:	ff 75 f4             	pushl  -0xc(%ebp)
  8010ac:	e8 52 ff ff ff       	call   801003 <fd_close>
  8010b1:	83 c4 10             	add    $0x10,%esp
}
  8010b4:	c9                   	leave  
  8010b5:	c3                   	ret    

008010b6 <close_all>:

void
close_all(void)
{
  8010b6:	55                   	push   %ebp
  8010b7:	89 e5                	mov    %esp,%ebp
  8010b9:	53                   	push   %ebx
  8010ba:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8010bd:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8010c2:	83 ec 0c             	sub    $0xc,%esp
  8010c5:	53                   	push   %ebx
  8010c6:	e8 c0 ff ff ff       	call   80108b <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8010cb:	43                   	inc    %ebx
  8010cc:	83 c4 10             	add    $0x10,%esp
  8010cf:	83 fb 20             	cmp    $0x20,%ebx
  8010d2:	75 ee                	jne    8010c2 <close_all+0xc>
		close(i);
}
  8010d4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8010d7:	c9                   	leave  
  8010d8:	c3                   	ret    

008010d9 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8010d9:	55                   	push   %ebp
  8010da:	89 e5                	mov    %esp,%ebp
  8010dc:	57                   	push   %edi
  8010dd:	56                   	push   %esi
  8010de:	53                   	push   %ebx
  8010df:	83 ec 2c             	sub    $0x2c,%esp
  8010e2:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8010e5:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8010e8:	50                   	push   %eax
  8010e9:	ff 75 08             	pushl  0x8(%ebp)
  8010ec:	e8 56 fe ff ff       	call   800f47 <fd_lookup>
  8010f1:	89 c3                	mov    %eax,%ebx
  8010f3:	83 c4 08             	add    $0x8,%esp
  8010f6:	85 c0                	test   %eax,%eax
  8010f8:	0f 88 c0 00 00 00    	js     8011be <dup+0xe5>
		return r;
	close(newfdnum);
  8010fe:	83 ec 0c             	sub    $0xc,%esp
  801101:	57                   	push   %edi
  801102:	e8 84 ff ff ff       	call   80108b <close>

	newfd = INDEX2FD(newfdnum);
  801107:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  80110d:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  801110:	83 c4 04             	add    $0x4,%esp
  801113:	ff 75 e4             	pushl  -0x1c(%ebp)
  801116:	e8 a1 fd ff ff       	call   800ebc <fd2data>
  80111b:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  80111d:	89 34 24             	mov    %esi,(%esp)
  801120:	e8 97 fd ff ff       	call   800ebc <fd2data>
  801125:	83 c4 10             	add    $0x10,%esp
  801128:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80112b:	89 d8                	mov    %ebx,%eax
  80112d:	c1 e8 16             	shr    $0x16,%eax
  801130:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801137:	a8 01                	test   $0x1,%al
  801139:	74 37                	je     801172 <dup+0x99>
  80113b:	89 d8                	mov    %ebx,%eax
  80113d:	c1 e8 0c             	shr    $0xc,%eax
  801140:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801147:	f6 c2 01             	test   $0x1,%dl
  80114a:	74 26                	je     801172 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80114c:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801153:	83 ec 0c             	sub    $0xc,%esp
  801156:	25 07 0e 00 00       	and    $0xe07,%eax
  80115b:	50                   	push   %eax
  80115c:	ff 75 d4             	pushl  -0x2c(%ebp)
  80115f:	6a 00                	push   $0x0
  801161:	53                   	push   %ebx
  801162:	6a 00                	push   $0x0
  801164:	e8 bb fb ff ff       	call   800d24 <sys_page_map>
  801169:	89 c3                	mov    %eax,%ebx
  80116b:	83 c4 20             	add    $0x20,%esp
  80116e:	85 c0                	test   %eax,%eax
  801170:	78 2d                	js     80119f <dup+0xc6>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801172:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801175:	89 c2                	mov    %eax,%edx
  801177:	c1 ea 0c             	shr    $0xc,%edx
  80117a:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801181:	83 ec 0c             	sub    $0xc,%esp
  801184:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  80118a:	52                   	push   %edx
  80118b:	56                   	push   %esi
  80118c:	6a 00                	push   $0x0
  80118e:	50                   	push   %eax
  80118f:	6a 00                	push   $0x0
  801191:	e8 8e fb ff ff       	call   800d24 <sys_page_map>
  801196:	89 c3                	mov    %eax,%ebx
  801198:	83 c4 20             	add    $0x20,%esp
  80119b:	85 c0                	test   %eax,%eax
  80119d:	79 1d                	jns    8011bc <dup+0xe3>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80119f:	83 ec 08             	sub    $0x8,%esp
  8011a2:	56                   	push   %esi
  8011a3:	6a 00                	push   $0x0
  8011a5:	e8 a0 fb ff ff       	call   800d4a <sys_page_unmap>
	sys_page_unmap(0, nva);
  8011aa:	83 c4 08             	add    $0x8,%esp
  8011ad:	ff 75 d4             	pushl  -0x2c(%ebp)
  8011b0:	6a 00                	push   $0x0
  8011b2:	e8 93 fb ff ff       	call   800d4a <sys_page_unmap>
	return r;
  8011b7:	83 c4 10             	add    $0x10,%esp
  8011ba:	eb 02                	jmp    8011be <dup+0xe5>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  8011bc:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  8011be:	89 d8                	mov    %ebx,%eax
  8011c0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011c3:	5b                   	pop    %ebx
  8011c4:	5e                   	pop    %esi
  8011c5:	5f                   	pop    %edi
  8011c6:	c9                   	leave  
  8011c7:	c3                   	ret    

008011c8 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8011c8:	55                   	push   %ebp
  8011c9:	89 e5                	mov    %esp,%ebp
  8011cb:	53                   	push   %ebx
  8011cc:	83 ec 14             	sub    $0x14,%esp
  8011cf:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8011d2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011d5:	50                   	push   %eax
  8011d6:	53                   	push   %ebx
  8011d7:	e8 6b fd ff ff       	call   800f47 <fd_lookup>
  8011dc:	83 c4 08             	add    $0x8,%esp
  8011df:	85 c0                	test   %eax,%eax
  8011e1:	78 67                	js     80124a <read+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011e3:	83 ec 08             	sub    $0x8,%esp
  8011e6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011e9:	50                   	push   %eax
  8011ea:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011ed:	ff 30                	pushl  (%eax)
  8011ef:	e8 a9 fd ff ff       	call   800f9d <dev_lookup>
  8011f4:	83 c4 10             	add    $0x10,%esp
  8011f7:	85 c0                	test   %eax,%eax
  8011f9:	78 4f                	js     80124a <read+0x82>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8011fb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011fe:	8b 50 08             	mov    0x8(%eax),%edx
  801201:	83 e2 03             	and    $0x3,%edx
  801204:	83 fa 01             	cmp    $0x1,%edx
  801207:	75 21                	jne    80122a <read+0x62>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801209:	a1 08 40 80 00       	mov    0x804008,%eax
  80120e:	8b 40 48             	mov    0x48(%eax),%eax
  801211:	83 ec 04             	sub    $0x4,%esp
  801214:	53                   	push   %ebx
  801215:	50                   	push   %eax
  801216:	68 10 24 80 00       	push   $0x802410
  80121b:	e8 a8 f0 ff ff       	call   8002c8 <cprintf>
		return -E_INVAL;
  801220:	83 c4 10             	add    $0x10,%esp
  801223:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801228:	eb 20                	jmp    80124a <read+0x82>
	}
	if (!dev->dev_read)
  80122a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80122d:	8b 52 08             	mov    0x8(%edx),%edx
  801230:	85 d2                	test   %edx,%edx
  801232:	74 11                	je     801245 <read+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801234:	83 ec 04             	sub    $0x4,%esp
  801237:	ff 75 10             	pushl  0x10(%ebp)
  80123a:	ff 75 0c             	pushl  0xc(%ebp)
  80123d:	50                   	push   %eax
  80123e:	ff d2                	call   *%edx
  801240:	83 c4 10             	add    $0x10,%esp
  801243:	eb 05                	jmp    80124a <read+0x82>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801245:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  80124a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80124d:	c9                   	leave  
  80124e:	c3                   	ret    

0080124f <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80124f:	55                   	push   %ebp
  801250:	89 e5                	mov    %esp,%ebp
  801252:	57                   	push   %edi
  801253:	56                   	push   %esi
  801254:	53                   	push   %ebx
  801255:	83 ec 0c             	sub    $0xc,%esp
  801258:	8b 7d 08             	mov    0x8(%ebp),%edi
  80125b:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80125e:	85 f6                	test   %esi,%esi
  801260:	74 31                	je     801293 <readn+0x44>
  801262:	b8 00 00 00 00       	mov    $0x0,%eax
  801267:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = read(fdnum, (char*)buf + tot, n - tot);
  80126c:	83 ec 04             	sub    $0x4,%esp
  80126f:	89 f2                	mov    %esi,%edx
  801271:	29 c2                	sub    %eax,%edx
  801273:	52                   	push   %edx
  801274:	03 45 0c             	add    0xc(%ebp),%eax
  801277:	50                   	push   %eax
  801278:	57                   	push   %edi
  801279:	e8 4a ff ff ff       	call   8011c8 <read>
		if (m < 0)
  80127e:	83 c4 10             	add    $0x10,%esp
  801281:	85 c0                	test   %eax,%eax
  801283:	78 17                	js     80129c <readn+0x4d>
			return m;
		if (m == 0)
  801285:	85 c0                	test   %eax,%eax
  801287:	74 11                	je     80129a <readn+0x4b>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801289:	01 c3                	add    %eax,%ebx
  80128b:	89 d8                	mov    %ebx,%eax
  80128d:	39 f3                	cmp    %esi,%ebx
  80128f:	72 db                	jb     80126c <readn+0x1d>
  801291:	eb 09                	jmp    80129c <readn+0x4d>
  801293:	b8 00 00 00 00       	mov    $0x0,%eax
  801298:	eb 02                	jmp    80129c <readn+0x4d>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  80129a:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  80129c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80129f:	5b                   	pop    %ebx
  8012a0:	5e                   	pop    %esi
  8012a1:	5f                   	pop    %edi
  8012a2:	c9                   	leave  
  8012a3:	c3                   	ret    

008012a4 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8012a4:	55                   	push   %ebp
  8012a5:	89 e5                	mov    %esp,%ebp
  8012a7:	53                   	push   %ebx
  8012a8:	83 ec 14             	sub    $0x14,%esp
  8012ab:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8012ae:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012b1:	50                   	push   %eax
  8012b2:	53                   	push   %ebx
  8012b3:	e8 8f fc ff ff       	call   800f47 <fd_lookup>
  8012b8:	83 c4 08             	add    $0x8,%esp
  8012bb:	85 c0                	test   %eax,%eax
  8012bd:	78 62                	js     801321 <write+0x7d>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012bf:	83 ec 08             	sub    $0x8,%esp
  8012c2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012c5:	50                   	push   %eax
  8012c6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012c9:	ff 30                	pushl  (%eax)
  8012cb:	e8 cd fc ff ff       	call   800f9d <dev_lookup>
  8012d0:	83 c4 10             	add    $0x10,%esp
  8012d3:	85 c0                	test   %eax,%eax
  8012d5:	78 4a                	js     801321 <write+0x7d>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8012d7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012da:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8012de:	75 21                	jne    801301 <write+0x5d>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8012e0:	a1 08 40 80 00       	mov    0x804008,%eax
  8012e5:	8b 40 48             	mov    0x48(%eax),%eax
  8012e8:	83 ec 04             	sub    $0x4,%esp
  8012eb:	53                   	push   %ebx
  8012ec:	50                   	push   %eax
  8012ed:	68 2c 24 80 00       	push   $0x80242c
  8012f2:	e8 d1 ef ff ff       	call   8002c8 <cprintf>
		return -E_INVAL;
  8012f7:	83 c4 10             	add    $0x10,%esp
  8012fa:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012ff:	eb 20                	jmp    801321 <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801301:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801304:	8b 52 0c             	mov    0xc(%edx),%edx
  801307:	85 d2                	test   %edx,%edx
  801309:	74 11                	je     80131c <write+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80130b:	83 ec 04             	sub    $0x4,%esp
  80130e:	ff 75 10             	pushl  0x10(%ebp)
  801311:	ff 75 0c             	pushl  0xc(%ebp)
  801314:	50                   	push   %eax
  801315:	ff d2                	call   *%edx
  801317:	83 c4 10             	add    $0x10,%esp
  80131a:	eb 05                	jmp    801321 <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80131c:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  801321:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801324:	c9                   	leave  
  801325:	c3                   	ret    

00801326 <seek>:

int
seek(int fdnum, off_t offset)
{
  801326:	55                   	push   %ebp
  801327:	89 e5                	mov    %esp,%ebp
  801329:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80132c:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80132f:	50                   	push   %eax
  801330:	ff 75 08             	pushl  0x8(%ebp)
  801333:	e8 0f fc ff ff       	call   800f47 <fd_lookup>
  801338:	83 c4 08             	add    $0x8,%esp
  80133b:	85 c0                	test   %eax,%eax
  80133d:	78 0e                	js     80134d <seek+0x27>
		return r;
	fd->fd_offset = offset;
  80133f:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801342:	8b 55 0c             	mov    0xc(%ebp),%edx
  801345:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801348:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80134d:	c9                   	leave  
  80134e:	c3                   	ret    

0080134f <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80134f:	55                   	push   %ebp
  801350:	89 e5                	mov    %esp,%ebp
  801352:	53                   	push   %ebx
  801353:	83 ec 14             	sub    $0x14,%esp
  801356:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801359:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80135c:	50                   	push   %eax
  80135d:	53                   	push   %ebx
  80135e:	e8 e4 fb ff ff       	call   800f47 <fd_lookup>
  801363:	83 c4 08             	add    $0x8,%esp
  801366:	85 c0                	test   %eax,%eax
  801368:	78 5f                	js     8013c9 <ftruncate+0x7a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80136a:	83 ec 08             	sub    $0x8,%esp
  80136d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801370:	50                   	push   %eax
  801371:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801374:	ff 30                	pushl  (%eax)
  801376:	e8 22 fc ff ff       	call   800f9d <dev_lookup>
  80137b:	83 c4 10             	add    $0x10,%esp
  80137e:	85 c0                	test   %eax,%eax
  801380:	78 47                	js     8013c9 <ftruncate+0x7a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801382:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801385:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801389:	75 21                	jne    8013ac <ftruncate+0x5d>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80138b:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801390:	8b 40 48             	mov    0x48(%eax),%eax
  801393:	83 ec 04             	sub    $0x4,%esp
  801396:	53                   	push   %ebx
  801397:	50                   	push   %eax
  801398:	68 ec 23 80 00       	push   $0x8023ec
  80139d:	e8 26 ef ff ff       	call   8002c8 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8013a2:	83 c4 10             	add    $0x10,%esp
  8013a5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8013aa:	eb 1d                	jmp    8013c9 <ftruncate+0x7a>
	}
	if (!dev->dev_trunc)
  8013ac:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8013af:	8b 52 18             	mov    0x18(%edx),%edx
  8013b2:	85 d2                	test   %edx,%edx
  8013b4:	74 0e                	je     8013c4 <ftruncate+0x75>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8013b6:	83 ec 08             	sub    $0x8,%esp
  8013b9:	ff 75 0c             	pushl  0xc(%ebp)
  8013bc:	50                   	push   %eax
  8013bd:	ff d2                	call   *%edx
  8013bf:	83 c4 10             	add    $0x10,%esp
  8013c2:	eb 05                	jmp    8013c9 <ftruncate+0x7a>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8013c4:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  8013c9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013cc:	c9                   	leave  
  8013cd:	c3                   	ret    

008013ce <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8013ce:	55                   	push   %ebp
  8013cf:	89 e5                	mov    %esp,%ebp
  8013d1:	53                   	push   %ebx
  8013d2:	83 ec 14             	sub    $0x14,%esp
  8013d5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8013d8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8013db:	50                   	push   %eax
  8013dc:	ff 75 08             	pushl  0x8(%ebp)
  8013df:	e8 63 fb ff ff       	call   800f47 <fd_lookup>
  8013e4:	83 c4 08             	add    $0x8,%esp
  8013e7:	85 c0                	test   %eax,%eax
  8013e9:	78 52                	js     80143d <fstat+0x6f>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013eb:	83 ec 08             	sub    $0x8,%esp
  8013ee:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013f1:	50                   	push   %eax
  8013f2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013f5:	ff 30                	pushl  (%eax)
  8013f7:	e8 a1 fb ff ff       	call   800f9d <dev_lookup>
  8013fc:	83 c4 10             	add    $0x10,%esp
  8013ff:	85 c0                	test   %eax,%eax
  801401:	78 3a                	js     80143d <fstat+0x6f>
		return r;
	if (!dev->dev_stat)
  801403:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801406:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80140a:	74 2c                	je     801438 <fstat+0x6a>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80140c:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80140f:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801416:	00 00 00 
	stat->st_isdir = 0;
  801419:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801420:	00 00 00 
	stat->st_dev = dev;
  801423:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801429:	83 ec 08             	sub    $0x8,%esp
  80142c:	53                   	push   %ebx
  80142d:	ff 75 f0             	pushl  -0x10(%ebp)
  801430:	ff 50 14             	call   *0x14(%eax)
  801433:	83 c4 10             	add    $0x10,%esp
  801436:	eb 05                	jmp    80143d <fstat+0x6f>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801438:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  80143d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801440:	c9                   	leave  
  801441:	c3                   	ret    

00801442 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801442:	55                   	push   %ebp
  801443:	89 e5                	mov    %esp,%ebp
  801445:	56                   	push   %esi
  801446:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801447:	83 ec 08             	sub    $0x8,%esp
  80144a:	6a 00                	push   $0x0
  80144c:	ff 75 08             	pushl  0x8(%ebp)
  80144f:	e8 78 01 00 00       	call   8015cc <open>
  801454:	89 c3                	mov    %eax,%ebx
  801456:	83 c4 10             	add    $0x10,%esp
  801459:	85 c0                	test   %eax,%eax
  80145b:	78 1b                	js     801478 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  80145d:	83 ec 08             	sub    $0x8,%esp
  801460:	ff 75 0c             	pushl  0xc(%ebp)
  801463:	50                   	push   %eax
  801464:	e8 65 ff ff ff       	call   8013ce <fstat>
  801469:	89 c6                	mov    %eax,%esi
	close(fd);
  80146b:	89 1c 24             	mov    %ebx,(%esp)
  80146e:	e8 18 fc ff ff       	call   80108b <close>
	return r;
  801473:	83 c4 10             	add    $0x10,%esp
  801476:	89 f3                	mov    %esi,%ebx
}
  801478:	89 d8                	mov    %ebx,%eax
  80147a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80147d:	5b                   	pop    %ebx
  80147e:	5e                   	pop    %esi
  80147f:	c9                   	leave  
  801480:	c3                   	ret    
  801481:	00 00                	add    %al,(%eax)
	...

00801484 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801484:	55                   	push   %ebp
  801485:	89 e5                	mov    %esp,%ebp
  801487:	56                   	push   %esi
  801488:	53                   	push   %ebx
  801489:	89 c3                	mov    %eax,%ebx
  80148b:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  80148d:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  801494:	75 12                	jne    8014a8 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801496:	83 ec 0c             	sub    $0xc,%esp
  801499:	6a 01                	push   $0x1
  80149b:	e8 9e 08 00 00       	call   801d3e <ipc_find_env>
  8014a0:	a3 04 40 80 00       	mov    %eax,0x804004
  8014a5:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8014a8:	6a 07                	push   $0x7
  8014aa:	68 00 50 80 00       	push   $0x805000
  8014af:	53                   	push   %ebx
  8014b0:	ff 35 04 40 80 00    	pushl  0x804004
  8014b6:	e8 2e 08 00 00       	call   801ce9 <ipc_send>
	
	return ipc_recv(NULL, dstva, NULL);
  8014bb:	83 c4 0c             	add    $0xc,%esp
  8014be:	6a 00                	push   $0x0
  8014c0:	56                   	push   %esi
  8014c1:	6a 00                	push   $0x0
  8014c3:	e8 ac 07 00 00       	call   801c74 <ipc_recv>
}
  8014c8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8014cb:	5b                   	pop    %ebx
  8014cc:	5e                   	pop    %esi
  8014cd:	c9                   	leave  
  8014ce:	c3                   	ret    

008014cf <devfile_stat>:
}


static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8014cf:	55                   	push   %ebp
  8014d0:	89 e5                	mov    %esp,%ebp
  8014d2:	53                   	push   %ebx
  8014d3:	83 ec 04             	sub    $0x4,%esp
  8014d6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8014d9:	8b 45 08             	mov    0x8(%ebp),%eax
  8014dc:	8b 40 0c             	mov    0xc(%eax),%eax
  8014df:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0) {
  8014e4:	ba 00 00 00 00       	mov    $0x0,%edx
  8014e9:	b8 05 00 00 00       	mov    $0x5,%eax
  8014ee:	e8 91 ff ff ff       	call   801484 <fsipc>
  8014f3:	85 c0                	test   %eax,%eax
  8014f5:	78 2c                	js     801523 <devfile_stat+0x54>
		return r;
	}
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8014f7:	83 ec 08             	sub    $0x8,%esp
  8014fa:	68 00 50 80 00       	push   $0x805000
  8014ff:	53                   	push   %ebx
  801500:	e8 79 f3 ff ff       	call   80087e <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801505:	a1 80 50 80 00       	mov    0x805080,%eax
  80150a:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801510:	a1 84 50 80 00       	mov    0x805084,%eax
  801515:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80151b:	83 c4 10             	add    $0x10,%esp
  80151e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801523:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801526:	c9                   	leave  
  801527:	c3                   	ret    

00801528 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801528:	55                   	push   %ebp
  801529:	89 e5                	mov    %esp,%ebp
  80152b:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80152e:	8b 45 08             	mov    0x8(%ebp),%eax
  801531:	8b 40 0c             	mov    0xc(%eax),%eax
  801534:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801539:	ba 00 00 00 00       	mov    $0x0,%edx
  80153e:	b8 06 00 00 00       	mov    $0x6,%eax
  801543:	e8 3c ff ff ff       	call   801484 <fsipc>
}
  801548:	c9                   	leave  
  801549:	c3                   	ret    

0080154a <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  80154a:	55                   	push   %ebp
  80154b:	89 e5                	mov    %esp,%ebp
  80154d:	56                   	push   %esi
  80154e:	53                   	push   %ebx
  80154f:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801552:	8b 45 08             	mov    0x8(%ebp),%eax
  801555:	8b 40 0c             	mov    0xc(%eax),%eax
  801558:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  80155d:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801563:	ba 00 00 00 00       	mov    $0x0,%edx
  801568:	b8 03 00 00 00       	mov    $0x3,%eax
  80156d:	e8 12 ff ff ff       	call   801484 <fsipc>
  801572:	89 c3                	mov    %eax,%ebx
  801574:	85 c0                	test   %eax,%eax
  801576:	78 4b                	js     8015c3 <devfile_read+0x79>
		return r;
	assert(r <= n);
  801578:	39 c6                	cmp    %eax,%esi
  80157a:	73 16                	jae    801592 <devfile_read+0x48>
  80157c:	68 5c 24 80 00       	push   $0x80245c
  801581:	68 63 24 80 00       	push   $0x802463
  801586:	6a 7d                	push   $0x7d
  801588:	68 78 24 80 00       	push   $0x802478
  80158d:	e8 5e ec ff ff       	call   8001f0 <_panic>
	assert(r <= PGSIZE);
  801592:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801597:	7e 16                	jle    8015af <devfile_read+0x65>
  801599:	68 83 24 80 00       	push   $0x802483
  80159e:	68 63 24 80 00       	push   $0x802463
  8015a3:	6a 7e                	push   $0x7e
  8015a5:	68 78 24 80 00       	push   $0x802478
  8015aa:	e8 41 ec ff ff       	call   8001f0 <_panic>
	memmove(buf, &fsipcbuf, r);
  8015af:	83 ec 04             	sub    $0x4,%esp
  8015b2:	50                   	push   %eax
  8015b3:	68 00 50 80 00       	push   $0x805000
  8015b8:	ff 75 0c             	pushl  0xc(%ebp)
  8015bb:	e8 7f f4 ff ff       	call   800a3f <memmove>
	return r;
  8015c0:	83 c4 10             	add    $0x10,%esp
}
  8015c3:	89 d8                	mov    %ebx,%eax
  8015c5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8015c8:	5b                   	pop    %ebx
  8015c9:	5e                   	pop    %esi
  8015ca:	c9                   	leave  
  8015cb:	c3                   	ret    

008015cc <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8015cc:	55                   	push   %ebp
  8015cd:	89 e5                	mov    %esp,%ebp
  8015cf:	56                   	push   %esi
  8015d0:	53                   	push   %ebx
  8015d1:	83 ec 1c             	sub    $0x1c,%esp
  8015d4:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8015d7:	56                   	push   %esi
  8015d8:	e8 4f f2 ff ff       	call   80082c <strlen>
  8015dd:	83 c4 10             	add    $0x10,%esp
  8015e0:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8015e5:	7f 65                	jg     80164c <open+0x80>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8015e7:	83 ec 0c             	sub    $0xc,%esp
  8015ea:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015ed:	50                   	push   %eax
  8015ee:	e8 e1 f8 ff ff       	call   800ed4 <fd_alloc>
  8015f3:	89 c3                	mov    %eax,%ebx
  8015f5:	83 c4 10             	add    $0x10,%esp
  8015f8:	85 c0                	test   %eax,%eax
  8015fa:	78 55                	js     801651 <open+0x85>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8015fc:	83 ec 08             	sub    $0x8,%esp
  8015ff:	56                   	push   %esi
  801600:	68 00 50 80 00       	push   $0x805000
  801605:	e8 74 f2 ff ff       	call   80087e <strcpy>
	fsipcbuf.open.req_omode = mode;
  80160a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80160d:	a3 00 54 80 00       	mov    %eax,0x805400



	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801612:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801615:	b8 01 00 00 00       	mov    $0x1,%eax
  80161a:	e8 65 fe ff ff       	call   801484 <fsipc>
  80161f:	89 c3                	mov    %eax,%ebx
  801621:	83 c4 10             	add    $0x10,%esp
  801624:	85 c0                	test   %eax,%eax
  801626:	79 12                	jns    80163a <open+0x6e>
		fd_close(fd, 0);
  801628:	83 ec 08             	sub    $0x8,%esp
  80162b:	6a 00                	push   $0x0
  80162d:	ff 75 f4             	pushl  -0xc(%ebp)
  801630:	e8 ce f9 ff ff       	call   801003 <fd_close>
		return r;
  801635:	83 c4 10             	add    $0x10,%esp
  801638:	eb 17                	jmp    801651 <open+0x85>
	}

	return fd2num(fd);
  80163a:	83 ec 0c             	sub    $0xc,%esp
  80163d:	ff 75 f4             	pushl  -0xc(%ebp)
  801640:	e8 67 f8 ff ff       	call   800eac <fd2num>
  801645:	89 c3                	mov    %eax,%ebx
  801647:	83 c4 10             	add    $0x10,%esp
  80164a:	eb 05                	jmp    801651 <open+0x85>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  80164c:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801651:	89 d8                	mov    %ebx,%eax
  801653:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801656:	5b                   	pop    %ebx
  801657:	5e                   	pop    %esi
  801658:	c9                   	leave  
  801659:	c3                   	ret    
	...

0080165c <writebuf>:
};


static void
writebuf(struct printbuf *b)
{
  80165c:	55                   	push   %ebp
  80165d:	89 e5                	mov    %esp,%ebp
  80165f:	53                   	push   %ebx
  801660:	83 ec 04             	sub    $0x4,%esp
  801663:	89 c3                	mov    %eax,%ebx
	if (b->error > 0) {
  801665:	83 78 0c 00          	cmpl   $0x0,0xc(%eax)
  801669:	7e 2e                	jle    801699 <writebuf+0x3d>
		ssize_t result = write(b->fd, b->buf, b->idx);
  80166b:	83 ec 04             	sub    $0x4,%esp
  80166e:	ff 70 04             	pushl  0x4(%eax)
  801671:	8d 40 10             	lea    0x10(%eax),%eax
  801674:	50                   	push   %eax
  801675:	ff 33                	pushl  (%ebx)
  801677:	e8 28 fc ff ff       	call   8012a4 <write>
		if (result > 0)
  80167c:	83 c4 10             	add    $0x10,%esp
  80167f:	85 c0                	test   %eax,%eax
  801681:	7e 03                	jle    801686 <writebuf+0x2a>
			b->result += result;
  801683:	01 43 08             	add    %eax,0x8(%ebx)
		if (result != b->idx) // error, or wrote less than supplied
  801686:	39 43 04             	cmp    %eax,0x4(%ebx)
  801689:	74 0e                	je     801699 <writebuf+0x3d>
			b->error = (result < 0 ? result : 0);
  80168b:	89 c2                	mov    %eax,%edx
  80168d:	85 c0                	test   %eax,%eax
  80168f:	7e 05                	jle    801696 <writebuf+0x3a>
  801691:	ba 00 00 00 00       	mov    $0x0,%edx
  801696:	89 53 0c             	mov    %edx,0xc(%ebx)
	}
}
  801699:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80169c:	c9                   	leave  
  80169d:	c3                   	ret    

0080169e <putch>:

static void
putch(int ch, void *thunk)
{
  80169e:	55                   	push   %ebp
  80169f:	89 e5                	mov    %esp,%ebp
  8016a1:	53                   	push   %ebx
  8016a2:	83 ec 04             	sub    $0x4,%esp
  8016a5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct printbuf *b = (struct printbuf *) thunk;
	b->buf[b->idx++] = ch;
  8016a8:	8b 43 04             	mov    0x4(%ebx),%eax
  8016ab:	8b 55 08             	mov    0x8(%ebp),%edx
  8016ae:	88 54 03 10          	mov    %dl,0x10(%ebx,%eax,1)
  8016b2:	40                   	inc    %eax
  8016b3:	89 43 04             	mov    %eax,0x4(%ebx)
	if (b->idx == 256) {
  8016b6:	3d 00 01 00 00       	cmp    $0x100,%eax
  8016bb:	75 0e                	jne    8016cb <putch+0x2d>
		writebuf(b);
  8016bd:	89 d8                	mov    %ebx,%eax
  8016bf:	e8 98 ff ff ff       	call   80165c <writebuf>
		b->idx = 0;
  8016c4:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	}
}
  8016cb:	83 c4 04             	add    $0x4,%esp
  8016ce:	5b                   	pop    %ebx
  8016cf:	c9                   	leave  
  8016d0:	c3                   	ret    

008016d1 <vfprintf>:

int
vfprintf(int fd, const char *fmt, va_list ap)
{
  8016d1:	55                   	push   %ebp
  8016d2:	89 e5                	mov    %esp,%ebp
  8016d4:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.fd = fd;
  8016da:	8b 45 08             	mov    0x8(%ebp),%eax
  8016dd:	89 85 e8 fe ff ff    	mov    %eax,-0x118(%ebp)
	b.idx = 0;
  8016e3:	c7 85 ec fe ff ff 00 	movl   $0x0,-0x114(%ebp)
  8016ea:	00 00 00 
	b.result = 0;
  8016ed:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8016f4:	00 00 00 
	b.error = 1;
  8016f7:	c7 85 f4 fe ff ff 01 	movl   $0x1,-0x10c(%ebp)
  8016fe:	00 00 00 
	vprintfmt(putch, &b, fmt, ap);
  801701:	ff 75 10             	pushl  0x10(%ebp)
  801704:	ff 75 0c             	pushl  0xc(%ebp)
  801707:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  80170d:	50                   	push   %eax
  80170e:	68 9e 16 80 00       	push   $0x80169e
  801713:	e8 15 ed ff ff       	call   80042d <vprintfmt>
	if (b.idx > 0)
  801718:	83 c4 10             	add    $0x10,%esp
  80171b:	83 bd ec fe ff ff 00 	cmpl   $0x0,-0x114(%ebp)
  801722:	7e 0b                	jle    80172f <vfprintf+0x5e>
		writebuf(&b);
  801724:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  80172a:	e8 2d ff ff ff       	call   80165c <writebuf>

	return (b.result ? b.result : b.error);
  80172f:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  801735:	85 c0                	test   %eax,%eax
  801737:	75 06                	jne    80173f <vfprintf+0x6e>
  801739:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
}
  80173f:	c9                   	leave  
  801740:	c3                   	ret    

00801741 <fprintf>:

int
fprintf(int fd, const char *fmt, ...)
{
  801741:	55                   	push   %ebp
  801742:	89 e5                	mov    %esp,%ebp
  801744:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801747:	8d 45 10             	lea    0x10(%ebp),%eax
	cnt = vfprintf(fd, fmt, ap);
  80174a:	50                   	push   %eax
  80174b:	ff 75 0c             	pushl  0xc(%ebp)
  80174e:	ff 75 08             	pushl  0x8(%ebp)
  801751:	e8 7b ff ff ff       	call   8016d1 <vfprintf>
	va_end(ap);

	return cnt;
}
  801756:	c9                   	leave  
  801757:	c3                   	ret    

00801758 <printf>:

int
printf(const char *fmt, ...)
{
  801758:	55                   	push   %ebp
  801759:	89 e5                	mov    %esp,%ebp
  80175b:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80175e:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vfprintf(1, fmt, ap);
  801761:	50                   	push   %eax
  801762:	ff 75 08             	pushl  0x8(%ebp)
  801765:	6a 01                	push   $0x1
  801767:	e8 65 ff ff ff       	call   8016d1 <vfprintf>
	va_end(ap);

	return cnt;
}
  80176c:	c9                   	leave  
  80176d:	c3                   	ret    
	...

00801770 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801770:	55                   	push   %ebp
  801771:	89 e5                	mov    %esp,%ebp
  801773:	56                   	push   %esi
  801774:	53                   	push   %ebx
  801775:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801778:	83 ec 0c             	sub    $0xc,%esp
  80177b:	ff 75 08             	pushl  0x8(%ebp)
  80177e:	e8 39 f7 ff ff       	call   800ebc <fd2data>
  801783:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  801785:	83 c4 08             	add    $0x8,%esp
  801788:	68 8f 24 80 00       	push   $0x80248f
  80178d:	56                   	push   %esi
  80178e:	e8 eb f0 ff ff       	call   80087e <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801793:	8b 43 04             	mov    0x4(%ebx),%eax
  801796:	2b 03                	sub    (%ebx),%eax
  801798:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  80179e:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  8017a5:	00 00 00 
	stat->st_dev = &devpipe;
  8017a8:	c7 86 88 00 00 00 24 	movl   $0x803024,0x88(%esi)
  8017af:	30 80 00 
	return 0;
}
  8017b2:	b8 00 00 00 00       	mov    $0x0,%eax
  8017b7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017ba:	5b                   	pop    %ebx
  8017bb:	5e                   	pop    %esi
  8017bc:	c9                   	leave  
  8017bd:	c3                   	ret    

008017be <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8017be:	55                   	push   %ebp
  8017bf:	89 e5                	mov    %esp,%ebp
  8017c1:	53                   	push   %ebx
  8017c2:	83 ec 0c             	sub    $0xc,%esp
  8017c5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8017c8:	53                   	push   %ebx
  8017c9:	6a 00                	push   $0x0
  8017cb:	e8 7a f5 ff ff       	call   800d4a <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8017d0:	89 1c 24             	mov    %ebx,(%esp)
  8017d3:	e8 e4 f6 ff ff       	call   800ebc <fd2data>
  8017d8:	83 c4 08             	add    $0x8,%esp
  8017db:	50                   	push   %eax
  8017dc:	6a 00                	push   $0x0
  8017de:	e8 67 f5 ff ff       	call   800d4a <sys_page_unmap>
}
  8017e3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017e6:	c9                   	leave  
  8017e7:	c3                   	ret    

008017e8 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8017e8:	55                   	push   %ebp
  8017e9:	89 e5                	mov    %esp,%ebp
  8017eb:	57                   	push   %edi
  8017ec:	56                   	push   %esi
  8017ed:	53                   	push   %ebx
  8017ee:	83 ec 1c             	sub    $0x1c,%esp
  8017f1:	89 c7                	mov    %eax,%edi
  8017f3:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8017f6:	a1 08 40 80 00       	mov    0x804008,%eax
  8017fb:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  8017fe:	83 ec 0c             	sub    $0xc,%esp
  801801:	57                   	push   %edi
  801802:	e8 85 05 00 00       	call   801d8c <pageref>
  801807:	89 c6                	mov    %eax,%esi
  801809:	83 c4 04             	add    $0x4,%esp
  80180c:	ff 75 e4             	pushl  -0x1c(%ebp)
  80180f:	e8 78 05 00 00       	call   801d8c <pageref>
  801814:	83 c4 10             	add    $0x10,%esp
  801817:	39 c6                	cmp    %eax,%esi
  801819:	0f 94 c0             	sete   %al
  80181c:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  80181f:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801825:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801828:	39 cb                	cmp    %ecx,%ebx
  80182a:	75 08                	jne    801834 <_pipeisclosed+0x4c>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  80182c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80182f:	5b                   	pop    %ebx
  801830:	5e                   	pop    %esi
  801831:	5f                   	pop    %edi
  801832:	c9                   	leave  
  801833:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  801834:	83 f8 01             	cmp    $0x1,%eax
  801837:	75 bd                	jne    8017f6 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801839:	8b 42 58             	mov    0x58(%edx),%eax
  80183c:	6a 01                	push   $0x1
  80183e:	50                   	push   %eax
  80183f:	53                   	push   %ebx
  801840:	68 96 24 80 00       	push   $0x802496
  801845:	e8 7e ea ff ff       	call   8002c8 <cprintf>
  80184a:	83 c4 10             	add    $0x10,%esp
  80184d:	eb a7                	jmp    8017f6 <_pipeisclosed+0xe>

0080184f <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80184f:	55                   	push   %ebp
  801850:	89 e5                	mov    %esp,%ebp
  801852:	57                   	push   %edi
  801853:	56                   	push   %esi
  801854:	53                   	push   %ebx
  801855:	83 ec 28             	sub    $0x28,%esp
  801858:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  80185b:	56                   	push   %esi
  80185c:	e8 5b f6 ff ff       	call   800ebc <fd2data>
  801861:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801863:	83 c4 10             	add    $0x10,%esp
  801866:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80186a:	75 4a                	jne    8018b6 <devpipe_write+0x67>
  80186c:	bf 00 00 00 00       	mov    $0x0,%edi
  801871:	eb 56                	jmp    8018c9 <devpipe_write+0x7a>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801873:	89 da                	mov    %ebx,%edx
  801875:	89 f0                	mov    %esi,%eax
  801877:	e8 6c ff ff ff       	call   8017e8 <_pipeisclosed>
  80187c:	85 c0                	test   %eax,%eax
  80187e:	75 4d                	jne    8018cd <devpipe_write+0x7e>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801880:	e8 54 f4 ff ff       	call   800cd9 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801885:	8b 43 04             	mov    0x4(%ebx),%eax
  801888:	8b 13                	mov    (%ebx),%edx
  80188a:	83 c2 20             	add    $0x20,%edx
  80188d:	39 d0                	cmp    %edx,%eax
  80188f:	73 e2                	jae    801873 <devpipe_write+0x24>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801891:	89 c2                	mov    %eax,%edx
  801893:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  801899:	79 05                	jns    8018a0 <devpipe_write+0x51>
  80189b:	4a                   	dec    %edx
  80189c:	83 ca e0             	or     $0xffffffe0,%edx
  80189f:	42                   	inc    %edx
  8018a0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8018a3:	8a 0c 39             	mov    (%ecx,%edi,1),%cl
  8018a6:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  8018aa:	40                   	inc    %eax
  8018ab:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8018ae:	47                   	inc    %edi
  8018af:	39 7d 10             	cmp    %edi,0x10(%ebp)
  8018b2:	77 07                	ja     8018bb <devpipe_write+0x6c>
  8018b4:	eb 13                	jmp    8018c9 <devpipe_write+0x7a>
  8018b6:	bf 00 00 00 00       	mov    $0x0,%edi
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8018bb:	8b 43 04             	mov    0x4(%ebx),%eax
  8018be:	8b 13                	mov    (%ebx),%edx
  8018c0:	83 c2 20             	add    $0x20,%edx
  8018c3:	39 d0                	cmp    %edx,%eax
  8018c5:	73 ac                	jae    801873 <devpipe_write+0x24>
  8018c7:	eb c8                	jmp    801891 <devpipe_write+0x42>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  8018c9:	89 f8                	mov    %edi,%eax
  8018cb:	eb 05                	jmp    8018d2 <devpipe_write+0x83>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8018cd:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  8018d2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8018d5:	5b                   	pop    %ebx
  8018d6:	5e                   	pop    %esi
  8018d7:	5f                   	pop    %edi
  8018d8:	c9                   	leave  
  8018d9:	c3                   	ret    

008018da <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  8018da:	55                   	push   %ebp
  8018db:	89 e5                	mov    %esp,%ebp
  8018dd:	57                   	push   %edi
  8018de:	56                   	push   %esi
  8018df:	53                   	push   %ebx
  8018e0:	83 ec 18             	sub    $0x18,%esp
  8018e3:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  8018e6:	57                   	push   %edi
  8018e7:	e8 d0 f5 ff ff       	call   800ebc <fd2data>
  8018ec:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8018ee:	83 c4 10             	add    $0x10,%esp
  8018f1:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8018f5:	75 44                	jne    80193b <devpipe_read+0x61>
  8018f7:	be 00 00 00 00       	mov    $0x0,%esi
  8018fc:	eb 4f                	jmp    80194d <devpipe_read+0x73>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
				return i;
  8018fe:	89 f0                	mov    %esi,%eax
  801900:	eb 54                	jmp    801956 <devpipe_read+0x7c>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801902:	89 da                	mov    %ebx,%edx
  801904:	89 f8                	mov    %edi,%eax
  801906:	e8 dd fe ff ff       	call   8017e8 <_pipeisclosed>
  80190b:	85 c0                	test   %eax,%eax
  80190d:	75 42                	jne    801951 <devpipe_read+0x77>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  80190f:	e8 c5 f3 ff ff       	call   800cd9 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801914:	8b 03                	mov    (%ebx),%eax
  801916:	3b 43 04             	cmp    0x4(%ebx),%eax
  801919:	74 e7                	je     801902 <devpipe_read+0x28>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  80191b:	25 1f 00 00 80       	and    $0x8000001f,%eax
  801920:	79 05                	jns    801927 <devpipe_read+0x4d>
  801922:	48                   	dec    %eax
  801923:	83 c8 e0             	or     $0xffffffe0,%eax
  801926:	40                   	inc    %eax
  801927:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  80192b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80192e:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  801931:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801933:	46                   	inc    %esi
  801934:	39 75 10             	cmp    %esi,0x10(%ebp)
  801937:	77 07                	ja     801940 <devpipe_read+0x66>
  801939:	eb 12                	jmp    80194d <devpipe_read+0x73>
  80193b:	be 00 00 00 00       	mov    $0x0,%esi
		while (p->p_rpos == p->p_wpos) {
  801940:	8b 03                	mov    (%ebx),%eax
  801942:	3b 43 04             	cmp    0x4(%ebx),%eax
  801945:	75 d4                	jne    80191b <devpipe_read+0x41>
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801947:	85 f6                	test   %esi,%esi
  801949:	75 b3                	jne    8018fe <devpipe_read+0x24>
  80194b:	eb b5                	jmp    801902 <devpipe_read+0x28>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  80194d:	89 f0                	mov    %esi,%eax
  80194f:	eb 05                	jmp    801956 <devpipe_read+0x7c>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801951:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801956:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801959:	5b                   	pop    %ebx
  80195a:	5e                   	pop    %esi
  80195b:	5f                   	pop    %edi
  80195c:	c9                   	leave  
  80195d:	c3                   	ret    

0080195e <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  80195e:	55                   	push   %ebp
  80195f:	89 e5                	mov    %esp,%ebp
  801961:	57                   	push   %edi
  801962:	56                   	push   %esi
  801963:	53                   	push   %ebx
  801964:	83 ec 28             	sub    $0x28,%esp
  801967:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  80196a:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80196d:	50                   	push   %eax
  80196e:	e8 61 f5 ff ff       	call   800ed4 <fd_alloc>
  801973:	89 c3                	mov    %eax,%ebx
  801975:	83 c4 10             	add    $0x10,%esp
  801978:	85 c0                	test   %eax,%eax
  80197a:	0f 88 24 01 00 00    	js     801aa4 <pipe+0x146>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801980:	83 ec 04             	sub    $0x4,%esp
  801983:	68 07 04 00 00       	push   $0x407
  801988:	ff 75 e4             	pushl  -0x1c(%ebp)
  80198b:	6a 00                	push   $0x0
  80198d:	e8 6e f3 ff ff       	call   800d00 <sys_page_alloc>
  801992:	89 c3                	mov    %eax,%ebx
  801994:	83 c4 10             	add    $0x10,%esp
  801997:	85 c0                	test   %eax,%eax
  801999:	0f 88 05 01 00 00    	js     801aa4 <pipe+0x146>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  80199f:	83 ec 0c             	sub    $0xc,%esp
  8019a2:	8d 45 e0             	lea    -0x20(%ebp),%eax
  8019a5:	50                   	push   %eax
  8019a6:	e8 29 f5 ff ff       	call   800ed4 <fd_alloc>
  8019ab:	89 c3                	mov    %eax,%ebx
  8019ad:	83 c4 10             	add    $0x10,%esp
  8019b0:	85 c0                	test   %eax,%eax
  8019b2:	0f 88 dc 00 00 00    	js     801a94 <pipe+0x136>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8019b8:	83 ec 04             	sub    $0x4,%esp
  8019bb:	68 07 04 00 00       	push   $0x407
  8019c0:	ff 75 e0             	pushl  -0x20(%ebp)
  8019c3:	6a 00                	push   $0x0
  8019c5:	e8 36 f3 ff ff       	call   800d00 <sys_page_alloc>
  8019ca:	89 c3                	mov    %eax,%ebx
  8019cc:	83 c4 10             	add    $0x10,%esp
  8019cf:	85 c0                	test   %eax,%eax
  8019d1:	0f 88 bd 00 00 00    	js     801a94 <pipe+0x136>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  8019d7:	83 ec 0c             	sub    $0xc,%esp
  8019da:	ff 75 e4             	pushl  -0x1c(%ebp)
  8019dd:	e8 da f4 ff ff       	call   800ebc <fd2data>
  8019e2:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8019e4:	83 c4 0c             	add    $0xc,%esp
  8019e7:	68 07 04 00 00       	push   $0x407
  8019ec:	50                   	push   %eax
  8019ed:	6a 00                	push   $0x0
  8019ef:	e8 0c f3 ff ff       	call   800d00 <sys_page_alloc>
  8019f4:	89 c3                	mov    %eax,%ebx
  8019f6:	83 c4 10             	add    $0x10,%esp
  8019f9:	85 c0                	test   %eax,%eax
  8019fb:	0f 88 83 00 00 00    	js     801a84 <pipe+0x126>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801a01:	83 ec 0c             	sub    $0xc,%esp
  801a04:	ff 75 e0             	pushl  -0x20(%ebp)
  801a07:	e8 b0 f4 ff ff       	call   800ebc <fd2data>
  801a0c:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801a13:	50                   	push   %eax
  801a14:	6a 00                	push   $0x0
  801a16:	56                   	push   %esi
  801a17:	6a 00                	push   $0x0
  801a19:	e8 06 f3 ff ff       	call   800d24 <sys_page_map>
  801a1e:	89 c3                	mov    %eax,%ebx
  801a20:	83 c4 20             	add    $0x20,%esp
  801a23:	85 c0                	test   %eax,%eax
  801a25:	78 4f                	js     801a76 <pipe+0x118>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801a27:	8b 15 24 30 80 00    	mov    0x803024,%edx
  801a2d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801a30:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801a32:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801a35:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801a3c:	8b 15 24 30 80 00    	mov    0x803024,%edx
  801a42:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801a45:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801a47:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801a4a:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801a51:	83 ec 0c             	sub    $0xc,%esp
  801a54:	ff 75 e4             	pushl  -0x1c(%ebp)
  801a57:	e8 50 f4 ff ff       	call   800eac <fd2num>
  801a5c:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  801a5e:	83 c4 04             	add    $0x4,%esp
  801a61:	ff 75 e0             	pushl  -0x20(%ebp)
  801a64:	e8 43 f4 ff ff       	call   800eac <fd2num>
  801a69:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  801a6c:	83 c4 10             	add    $0x10,%esp
  801a6f:	bb 00 00 00 00       	mov    $0x0,%ebx
  801a74:	eb 2e                	jmp    801aa4 <pipe+0x146>

    err3:
	sys_page_unmap(0, va);
  801a76:	83 ec 08             	sub    $0x8,%esp
  801a79:	56                   	push   %esi
  801a7a:	6a 00                	push   $0x0
  801a7c:	e8 c9 f2 ff ff       	call   800d4a <sys_page_unmap>
  801a81:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801a84:	83 ec 08             	sub    $0x8,%esp
  801a87:	ff 75 e0             	pushl  -0x20(%ebp)
  801a8a:	6a 00                	push   $0x0
  801a8c:	e8 b9 f2 ff ff       	call   800d4a <sys_page_unmap>
  801a91:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801a94:	83 ec 08             	sub    $0x8,%esp
  801a97:	ff 75 e4             	pushl  -0x1c(%ebp)
  801a9a:	6a 00                	push   $0x0
  801a9c:	e8 a9 f2 ff ff       	call   800d4a <sys_page_unmap>
  801aa1:	83 c4 10             	add    $0x10,%esp
    err:
	return r;
}
  801aa4:	89 d8                	mov    %ebx,%eax
  801aa6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801aa9:	5b                   	pop    %ebx
  801aaa:	5e                   	pop    %esi
  801aab:	5f                   	pop    %edi
  801aac:	c9                   	leave  
  801aad:	c3                   	ret    

00801aae <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801aae:	55                   	push   %ebp
  801aaf:	89 e5                	mov    %esp,%ebp
  801ab1:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801ab4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ab7:	50                   	push   %eax
  801ab8:	ff 75 08             	pushl  0x8(%ebp)
  801abb:	e8 87 f4 ff ff       	call   800f47 <fd_lookup>
  801ac0:	83 c4 10             	add    $0x10,%esp
  801ac3:	85 c0                	test   %eax,%eax
  801ac5:	78 18                	js     801adf <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801ac7:	83 ec 0c             	sub    $0xc,%esp
  801aca:	ff 75 f4             	pushl  -0xc(%ebp)
  801acd:	e8 ea f3 ff ff       	call   800ebc <fd2data>
	return _pipeisclosed(fd, p);
  801ad2:	89 c2                	mov    %eax,%edx
  801ad4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ad7:	e8 0c fd ff ff       	call   8017e8 <_pipeisclosed>
  801adc:	83 c4 10             	add    $0x10,%esp
}
  801adf:	c9                   	leave  
  801ae0:	c3                   	ret    
  801ae1:	00 00                	add    %al,(%eax)
	...

00801ae4 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801ae4:	55                   	push   %ebp
  801ae5:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801ae7:	b8 00 00 00 00       	mov    $0x0,%eax
  801aec:	c9                   	leave  
  801aed:	c3                   	ret    

00801aee <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801aee:	55                   	push   %ebp
  801aef:	89 e5                	mov    %esp,%ebp
  801af1:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801af4:	68 ae 24 80 00       	push   $0x8024ae
  801af9:	ff 75 0c             	pushl  0xc(%ebp)
  801afc:	e8 7d ed ff ff       	call   80087e <strcpy>
	return 0;
}
  801b01:	b8 00 00 00 00       	mov    $0x0,%eax
  801b06:	c9                   	leave  
  801b07:	c3                   	ret    

00801b08 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801b08:	55                   	push   %ebp
  801b09:	89 e5                	mov    %esp,%ebp
  801b0b:	57                   	push   %edi
  801b0c:	56                   	push   %esi
  801b0d:	53                   	push   %ebx
  801b0e:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801b14:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801b18:	74 45                	je     801b5f <devcons_write+0x57>
  801b1a:	b8 00 00 00 00       	mov    $0x0,%eax
  801b1f:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801b24:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801b2a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801b2d:	29 c3                	sub    %eax,%ebx
		if (m > sizeof(buf) - 1)
  801b2f:	83 fb 7f             	cmp    $0x7f,%ebx
  801b32:	76 05                	jbe    801b39 <devcons_write+0x31>
			m = sizeof(buf) - 1;
  801b34:	bb 7f 00 00 00       	mov    $0x7f,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  801b39:	83 ec 04             	sub    $0x4,%esp
  801b3c:	53                   	push   %ebx
  801b3d:	03 45 0c             	add    0xc(%ebp),%eax
  801b40:	50                   	push   %eax
  801b41:	57                   	push   %edi
  801b42:	e8 f8 ee ff ff       	call   800a3f <memmove>
		sys_cputs(buf, m);
  801b47:	83 c4 08             	add    $0x8,%esp
  801b4a:	53                   	push   %ebx
  801b4b:	57                   	push   %edi
  801b4c:	e8 f8 f0 ff ff       	call   800c49 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801b51:	01 de                	add    %ebx,%esi
  801b53:	89 f0                	mov    %esi,%eax
  801b55:	83 c4 10             	add    $0x10,%esp
  801b58:	3b 75 10             	cmp    0x10(%ebp),%esi
  801b5b:	72 cd                	jb     801b2a <devcons_write+0x22>
  801b5d:	eb 05                	jmp    801b64 <devcons_write+0x5c>
  801b5f:	be 00 00 00 00       	mov    $0x0,%esi
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801b64:	89 f0                	mov    %esi,%eax
  801b66:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b69:	5b                   	pop    %ebx
  801b6a:	5e                   	pop    %esi
  801b6b:	5f                   	pop    %edi
  801b6c:	c9                   	leave  
  801b6d:	c3                   	ret    

00801b6e <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801b6e:	55                   	push   %ebp
  801b6f:	89 e5                	mov    %esp,%ebp
  801b71:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  801b74:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801b78:	75 07                	jne    801b81 <devcons_read+0x13>
  801b7a:	eb 25                	jmp    801ba1 <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801b7c:	e8 58 f1 ff ff       	call   800cd9 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801b81:	e8 e9 f0 ff ff       	call   800c6f <sys_cgetc>
  801b86:	85 c0                	test   %eax,%eax
  801b88:	74 f2                	je     801b7c <devcons_read+0xe>
  801b8a:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  801b8c:	85 c0                	test   %eax,%eax
  801b8e:	78 1d                	js     801bad <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801b90:	83 f8 04             	cmp    $0x4,%eax
  801b93:	74 13                	je     801ba8 <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  801b95:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b98:	88 10                	mov    %dl,(%eax)
	return 1;
  801b9a:	b8 01 00 00 00       	mov    $0x1,%eax
  801b9f:	eb 0c                	jmp    801bad <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  801ba1:	b8 00 00 00 00       	mov    $0x0,%eax
  801ba6:	eb 05                	jmp    801bad <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801ba8:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801bad:	c9                   	leave  
  801bae:	c3                   	ret    

00801baf <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801baf:	55                   	push   %ebp
  801bb0:	89 e5                	mov    %esp,%ebp
  801bb2:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801bb5:	8b 45 08             	mov    0x8(%ebp),%eax
  801bb8:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801bbb:	6a 01                	push   $0x1
  801bbd:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801bc0:	50                   	push   %eax
  801bc1:	e8 83 f0 ff ff       	call   800c49 <sys_cputs>
  801bc6:	83 c4 10             	add    $0x10,%esp
}
  801bc9:	c9                   	leave  
  801bca:	c3                   	ret    

00801bcb <getchar>:

int
getchar(void)
{
  801bcb:	55                   	push   %ebp
  801bcc:	89 e5                	mov    %esp,%ebp
  801bce:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801bd1:	6a 01                	push   $0x1
  801bd3:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801bd6:	50                   	push   %eax
  801bd7:	6a 00                	push   $0x0
  801bd9:	e8 ea f5 ff ff       	call   8011c8 <read>
	if (r < 0)
  801bde:	83 c4 10             	add    $0x10,%esp
  801be1:	85 c0                	test   %eax,%eax
  801be3:	78 0f                	js     801bf4 <getchar+0x29>
		return r;
	if (r < 1)
  801be5:	85 c0                	test   %eax,%eax
  801be7:	7e 06                	jle    801bef <getchar+0x24>
		return -E_EOF;
	return c;
  801be9:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801bed:	eb 05                	jmp    801bf4 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801bef:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801bf4:	c9                   	leave  
  801bf5:	c3                   	ret    

00801bf6 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801bf6:	55                   	push   %ebp
  801bf7:	89 e5                	mov    %esp,%ebp
  801bf9:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801bfc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801bff:	50                   	push   %eax
  801c00:	ff 75 08             	pushl  0x8(%ebp)
  801c03:	e8 3f f3 ff ff       	call   800f47 <fd_lookup>
  801c08:	83 c4 10             	add    $0x10,%esp
  801c0b:	85 c0                	test   %eax,%eax
  801c0d:	78 11                	js     801c20 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801c0f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c12:	8b 15 40 30 80 00    	mov    0x803040,%edx
  801c18:	39 10                	cmp    %edx,(%eax)
  801c1a:	0f 94 c0             	sete   %al
  801c1d:	0f b6 c0             	movzbl %al,%eax
}
  801c20:	c9                   	leave  
  801c21:	c3                   	ret    

00801c22 <opencons>:

int
opencons(void)
{
  801c22:	55                   	push   %ebp
  801c23:	89 e5                	mov    %esp,%ebp
  801c25:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801c28:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c2b:	50                   	push   %eax
  801c2c:	e8 a3 f2 ff ff       	call   800ed4 <fd_alloc>
  801c31:	83 c4 10             	add    $0x10,%esp
  801c34:	85 c0                	test   %eax,%eax
  801c36:	78 3a                	js     801c72 <opencons+0x50>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801c38:	83 ec 04             	sub    $0x4,%esp
  801c3b:	68 07 04 00 00       	push   $0x407
  801c40:	ff 75 f4             	pushl  -0xc(%ebp)
  801c43:	6a 00                	push   $0x0
  801c45:	e8 b6 f0 ff ff       	call   800d00 <sys_page_alloc>
  801c4a:	83 c4 10             	add    $0x10,%esp
  801c4d:	85 c0                	test   %eax,%eax
  801c4f:	78 21                	js     801c72 <opencons+0x50>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801c51:	8b 15 40 30 80 00    	mov    0x803040,%edx
  801c57:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c5a:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801c5c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c5f:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801c66:	83 ec 0c             	sub    $0xc,%esp
  801c69:	50                   	push   %eax
  801c6a:	e8 3d f2 ff ff       	call   800eac <fd2num>
  801c6f:	83 c4 10             	add    $0x10,%esp
}
  801c72:	c9                   	leave  
  801c73:	c3                   	ret    

00801c74 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801c74:	55                   	push   %ebp
  801c75:	89 e5                	mov    %esp,%ebp
  801c77:	56                   	push   %esi
  801c78:	53                   	push   %ebx
  801c79:	8b 75 08             	mov    0x8(%ebp),%esi
  801c7c:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c7f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// cprintf("0x%x 0x%x 0x%x\n", (uint32_t)from_env_store, (uint32_t)pg, (uint32_t)perm_store);
	int r;
	if (pg != NULL) {
  801c82:	85 c0                	test   %eax,%eax
  801c84:	74 0e                	je     801c94 <ipc_recv+0x20>
		r = sys_ipc_recv(pg);
  801c86:	83 ec 0c             	sub    $0xc,%esp
  801c89:	50                   	push   %eax
  801c8a:	e8 6c f1 ff ff       	call   800dfb <sys_ipc_recv>
  801c8f:	83 c4 10             	add    $0x10,%esp
  801c92:	eb 10                	jmp    801ca4 <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv((void *)UTOP);
  801c94:	83 ec 0c             	sub    $0xc,%esp
  801c97:	68 00 00 c0 ee       	push   $0xeec00000
  801c9c:	e8 5a f1 ff ff       	call   800dfb <sys_ipc_recv>
  801ca1:	83 c4 10             	add    $0x10,%esp
	}

	if (r == 0) {
  801ca4:	85 c0                	test   %eax,%eax
  801ca6:	75 26                	jne    801cce <ipc_recv+0x5a>
		if (from_env_store != NULL) *from_env_store = thisenv->env_ipc_from;
  801ca8:	85 f6                	test   %esi,%esi
  801caa:	74 0a                	je     801cb6 <ipc_recv+0x42>
  801cac:	a1 08 40 80 00       	mov    0x804008,%eax
  801cb1:	8b 40 74             	mov    0x74(%eax),%eax
  801cb4:	89 06                	mov    %eax,(%esi)
		if (perm_store != NULL) *perm_store = thisenv->env_ipc_perm;
  801cb6:	85 db                	test   %ebx,%ebx
  801cb8:	74 0a                	je     801cc4 <ipc_recv+0x50>
  801cba:	a1 08 40 80 00       	mov    0x804008,%eax
  801cbf:	8b 40 78             	mov    0x78(%eax),%eax
  801cc2:	89 03                	mov    %eax,(%ebx)
		return thisenv->env_ipc_value;
  801cc4:	a1 08 40 80 00       	mov    0x804008,%eax
  801cc9:	8b 40 70             	mov    0x70(%eax),%eax
  801ccc:	eb 14                	jmp    801ce2 <ipc_recv+0x6e>
	} else {
		// fails;
		if (from_env_store != NULL) *from_env_store = 0;
  801cce:	85 f6                	test   %esi,%esi
  801cd0:	74 06                	je     801cd8 <ipc_recv+0x64>
  801cd2:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if (perm_store != NULL) *perm_store = 0;
  801cd8:	85 db                	test   %ebx,%ebx
  801cda:	74 06                	je     801ce2 <ipc_recv+0x6e>
  801cdc:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		return r;
	}
}
  801ce2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ce5:	5b                   	pop    %ebx
  801ce6:	5e                   	pop    %esi
  801ce7:	c9                   	leave  
  801ce8:	c3                   	ret    

00801ce9 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801ce9:	55                   	push   %ebp
  801cea:	89 e5                	mov    %esp,%ebp
  801cec:	57                   	push   %edi
  801ced:	56                   	push   %esi
  801cee:	53                   	push   %ebx
  801cef:	83 ec 0c             	sub    $0xc,%esp
  801cf2:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801cf5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801cf8:	8b 75 14             	mov    0x14(%ebp),%esi
	// LAB 4: Your code here.
	// int sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
	int r;
	if (pg == NULL) pg = (void *)UTOP;
  801cfb:	85 db                	test   %ebx,%ebx
  801cfd:	75 25                	jne    801d24 <ipc_send+0x3b>
  801cff:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
  801d04:	eb 1e                	jmp    801d24 <ipc_send+0x3b>
	
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) != 0) {
		if (r == -E_IPC_NOT_RECV) {
  801d06:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801d09:	75 07                	jne    801d12 <ipc_send+0x29>
			// cprintf("Try Again and Again....\n");
			sys_yield();
  801d0b:	e8 c9 ef ff ff       	call   800cd9 <sys_yield>
  801d10:	eb 12                	jmp    801d24 <ipc_send+0x3b>
		} else {
			panic("ipc_send error %e\n", r);
  801d12:	50                   	push   %eax
  801d13:	68 ba 24 80 00       	push   $0x8024ba
  801d18:	6a 43                	push   $0x43
  801d1a:	68 cd 24 80 00       	push   $0x8024cd
  801d1f:	e8 cc e4 ff ff       	call   8001f0 <_panic>
	// LAB 4: Your code here.
	// int sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
	int r;
	if (pg == NULL) pg = (void *)UTOP;
	
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) != 0) {
  801d24:	56                   	push   %esi
  801d25:	53                   	push   %ebx
  801d26:	57                   	push   %edi
  801d27:	ff 75 08             	pushl  0x8(%ebp)
  801d2a:	e8 a7 f0 ff ff       	call   800dd6 <sys_ipc_try_send>
  801d2f:	83 c4 10             	add    $0x10,%esp
  801d32:	85 c0                	test   %eax,%eax
  801d34:	75 d0                	jne    801d06 <ipc_send+0x1d>
		} else {
			panic("ipc_send error %e\n", r);
		}
	}
	return;
}
  801d36:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d39:	5b                   	pop    %ebx
  801d3a:	5e                   	pop    %esi
  801d3b:	5f                   	pop    %edi
  801d3c:	c9                   	leave  
  801d3d:	c3                   	ret    

00801d3e <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801d3e:	55                   	push   %ebp
  801d3f:	89 e5                	mov    %esp,%ebp
  801d41:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  801d44:	39 0d 50 00 c0 ee    	cmp    %ecx,0xeec00050
  801d4a:	74 1a                	je     801d66 <ipc_find_env+0x28>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801d4c:	b8 01 00 00 00       	mov    $0x1,%eax
		if (envs[i].env_type == type)
  801d51:	89 c2                	mov    %eax,%edx
  801d53:	c1 e2 07             	shl    $0x7,%edx
  801d56:	8d 94 82 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,4),%edx
  801d5d:	8b 52 50             	mov    0x50(%edx),%edx
  801d60:	39 ca                	cmp    %ecx,%edx
  801d62:	75 18                	jne    801d7c <ipc_find_env+0x3e>
  801d64:	eb 05                	jmp    801d6b <ipc_find_env+0x2d>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801d66:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
			return envs[i].env_id;
  801d6b:	89 c2                	mov    %eax,%edx
  801d6d:	c1 e2 07             	shl    $0x7,%edx
  801d70:	8d 84 82 08 00 c0 ee 	lea    -0x113ffff8(%edx,%eax,4),%eax
  801d77:	8b 40 40             	mov    0x40(%eax),%eax
  801d7a:	eb 0c                	jmp    801d88 <ipc_find_env+0x4a>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801d7c:	40                   	inc    %eax
  801d7d:	3d 00 04 00 00       	cmp    $0x400,%eax
  801d82:	75 cd                	jne    801d51 <ipc_find_env+0x13>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801d84:	66 b8 00 00          	mov    $0x0,%ax
}
  801d88:	c9                   	leave  
  801d89:	c3                   	ret    
	...

00801d8c <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801d8c:	55                   	push   %ebp
  801d8d:	89 e5                	mov    %esp,%ebp
  801d8f:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801d92:	89 c2                	mov    %eax,%edx
  801d94:	c1 ea 16             	shr    $0x16,%edx
  801d97:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801d9e:	f6 c2 01             	test   $0x1,%dl
  801da1:	74 1e                	je     801dc1 <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  801da3:	c1 e8 0c             	shr    $0xc,%eax
  801da6:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801dad:	a8 01                	test   $0x1,%al
  801daf:	74 17                	je     801dc8 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801db1:	c1 e8 0c             	shr    $0xc,%eax
  801db4:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  801dbb:	ef 
  801dbc:	0f b7 c0             	movzwl %ax,%eax
  801dbf:	eb 0c                	jmp    801dcd <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  801dc1:	b8 00 00 00 00       	mov    $0x0,%eax
  801dc6:	eb 05                	jmp    801dcd <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  801dc8:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  801dcd:	c9                   	leave  
  801dce:	c3                   	ret    
	...

00801dd0 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  801dd0:	55                   	push   %ebp
  801dd1:	89 e5                	mov    %esp,%ebp
  801dd3:	57                   	push   %edi
  801dd4:	56                   	push   %esi
  801dd5:	83 ec 10             	sub    $0x10,%esp
  801dd8:	8b 7d 08             	mov    0x8(%ebp),%edi
  801ddb:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  801dde:	89 7d f0             	mov    %edi,-0x10(%ebp)
  801de1:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  801de4:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  801de7:	8b 45 14             	mov    0x14(%ebp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  801dea:	85 c0                	test   %eax,%eax
  801dec:	75 2e                	jne    801e1c <__udivdi3+0x4c>
    {
      if (d0 > n1)
  801dee:	39 f1                	cmp    %esi,%ecx
  801df0:	77 5a                	ja     801e4c <__udivdi3+0x7c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  801df2:	85 c9                	test   %ecx,%ecx
  801df4:	75 0b                	jne    801e01 <__udivdi3+0x31>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  801df6:	b8 01 00 00 00       	mov    $0x1,%eax
  801dfb:	31 d2                	xor    %edx,%edx
  801dfd:	f7 f1                	div    %ecx
  801dff:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  801e01:	31 d2                	xor    %edx,%edx
  801e03:	89 f0                	mov    %esi,%eax
  801e05:	f7 f1                	div    %ecx
  801e07:	89 c6                	mov    %eax,%esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801e09:	89 f8                	mov    %edi,%eax
  801e0b:	f7 f1                	div    %ecx
  801e0d:	89 c7                	mov    %eax,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801e0f:	89 f8                	mov    %edi,%eax
  801e11:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801e13:	83 c4 10             	add    $0x10,%esp
  801e16:	5e                   	pop    %esi
  801e17:	5f                   	pop    %edi
  801e18:	c9                   	leave  
  801e19:	c3                   	ret    
  801e1a:	66 90                	xchg   %ax,%ax
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801e1c:	39 f0                	cmp    %esi,%eax
  801e1e:	77 1c                	ja     801e3c <__udivdi3+0x6c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  801e20:	0f bd f8             	bsr    %eax,%edi
	  if (bm == 0)
  801e23:	83 f7 1f             	xor    $0x1f,%edi
  801e26:	75 3c                	jne    801e64 <__udivdi3+0x94>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801e28:	39 f0                	cmp    %esi,%eax
  801e2a:	0f 82 90 00 00 00    	jb     801ec0 <__udivdi3+0xf0>
  801e30:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801e33:	39 55 f4             	cmp    %edx,-0xc(%ebp)
  801e36:	0f 86 84 00 00 00    	jbe    801ec0 <__udivdi3+0xf0>
  801e3c:	31 f6                	xor    %esi,%esi
  801e3e:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801e40:	89 f8                	mov    %edi,%eax
  801e42:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801e44:	83 c4 10             	add    $0x10,%esp
  801e47:	5e                   	pop    %esi
  801e48:	5f                   	pop    %edi
  801e49:	c9                   	leave  
  801e4a:	c3                   	ret    
  801e4b:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801e4c:	89 f2                	mov    %esi,%edx
  801e4e:	89 f8                	mov    %edi,%eax
  801e50:	f7 f1                	div    %ecx
  801e52:	89 c7                	mov    %eax,%edi
  801e54:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801e56:	89 f8                	mov    %edi,%eax
  801e58:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801e5a:	83 c4 10             	add    $0x10,%esp
  801e5d:	5e                   	pop    %esi
  801e5e:	5f                   	pop    %edi
  801e5f:	c9                   	leave  
  801e60:	c3                   	ret    
  801e61:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  801e64:	89 f9                	mov    %edi,%ecx
  801e66:	d3 e0                	shl    %cl,%eax
  801e68:	89 45 e8             	mov    %eax,-0x18(%ebp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  801e6b:	b8 20 00 00 00       	mov    $0x20,%eax
  801e70:	29 f8                	sub    %edi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  801e72:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801e75:	88 c1                	mov    %al,%cl
  801e77:	d3 ea                	shr    %cl,%edx
  801e79:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  801e7c:	09 ca                	or     %ecx,%edx
  801e7e:	89 55 ec             	mov    %edx,-0x14(%ebp)
	      d0 = d0 << bm;
  801e81:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801e84:	89 f9                	mov    %edi,%ecx
  801e86:	d3 e2                	shl    %cl,%edx
  801e88:	89 55 f4             	mov    %edx,-0xc(%ebp)
	      n2 = n1 >> b;
  801e8b:	89 f2                	mov    %esi,%edx
  801e8d:	88 c1                	mov    %al,%cl
  801e8f:	d3 ea                	shr    %cl,%edx
  801e91:	89 55 e8             	mov    %edx,-0x18(%ebp)
	      n1 = (n1 << bm) | (n0 >> b);
  801e94:	89 f2                	mov    %esi,%edx
  801e96:	89 f9                	mov    %edi,%ecx
  801e98:	d3 e2                	shl    %cl,%edx
  801e9a:	8b 75 f0             	mov    -0x10(%ebp),%esi
  801e9d:	88 c1                	mov    %al,%cl
  801e9f:	d3 ee                	shr    %cl,%esi
  801ea1:	09 d6                	or     %edx,%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  801ea3:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  801ea6:	89 f0                	mov    %esi,%eax
  801ea8:	89 ca                	mov    %ecx,%edx
  801eaa:	f7 75 ec             	divl   -0x14(%ebp)
  801ead:	89 d1                	mov    %edx,%ecx
  801eaf:	89 c6                	mov    %eax,%esi
	      umul_ppmm (m1, m0, q0, d0);
  801eb1:	f7 65 f4             	mull   -0xc(%ebp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801eb4:	39 d1                	cmp    %edx,%ecx
  801eb6:	72 28                	jb     801ee0 <__udivdi3+0x110>
  801eb8:	74 1a                	je     801ed4 <__udivdi3+0x104>
  801eba:	89 f7                	mov    %esi,%edi
  801ebc:	31 f6                	xor    %esi,%esi
  801ebe:	eb 80                	jmp    801e40 <__udivdi3+0x70>
	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  801ec0:	31 f6                	xor    %esi,%esi
  801ec2:	bf 01 00 00 00       	mov    $0x1,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801ec7:	89 f8                	mov    %edi,%eax
  801ec9:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801ecb:	83 c4 10             	add    $0x10,%esp
  801ece:	5e                   	pop    %esi
  801ecf:	5f                   	pop    %edi
  801ed0:	c9                   	leave  
  801ed1:	c3                   	ret    
  801ed2:	66 90                	xchg   %ax,%ax

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  801ed4:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801ed7:	89 f9                	mov    %edi,%ecx
  801ed9:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801edb:	39 c2                	cmp    %eax,%edx
  801edd:	73 db                	jae    801eba <__udivdi3+0xea>
  801edf:	90                   	nop
		{
		  q0--;
  801ee0:	8d 7e ff             	lea    -0x1(%esi),%edi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  801ee3:	31 f6                	xor    %esi,%esi
  801ee5:	e9 56 ff ff ff       	jmp    801e40 <__udivdi3+0x70>
	...

00801eec <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  801eec:	55                   	push   %ebp
  801eed:	89 e5                	mov    %esp,%ebp
  801eef:	57                   	push   %edi
  801ef0:	56                   	push   %esi
  801ef1:	83 ec 20             	sub    $0x20,%esp
  801ef4:	8b 45 08             	mov    0x8(%ebp),%eax
  801ef7:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  801efa:	89 45 e8             	mov    %eax,-0x18(%ebp)
  801efd:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  801f00:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  801f03:	8b 7d 14             	mov    0x14(%ebp),%edi
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  801f06:	89 45 f0             	mov    %eax,-0x10(%ebp)
  n1 = nn.s.high;
  801f09:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  801f0b:	85 ff                	test   %edi,%edi
  801f0d:	75 15                	jne    801f24 <__umoddi3+0x38>
    {
      if (d0 > n1)
  801f0f:	39 f1                	cmp    %esi,%ecx
  801f11:	0f 86 99 00 00 00    	jbe    801fb0 <__umoddi3+0xc4>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801f17:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  801f19:	89 d0                	mov    %edx,%eax
  801f1b:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801f1d:	83 c4 20             	add    $0x20,%esp
  801f20:	5e                   	pop    %esi
  801f21:	5f                   	pop    %edi
  801f22:	c9                   	leave  
  801f23:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801f24:	39 f7                	cmp    %esi,%edi
  801f26:	0f 87 a4 00 00 00    	ja     801fd0 <__umoddi3+0xe4>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  801f2c:	0f bd c7             	bsr    %edi,%eax
	  if (bm == 0)
  801f2f:	83 f0 1f             	xor    $0x1f,%eax
  801f32:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801f35:	0f 84 a1 00 00 00    	je     801fdc <__umoddi3+0xf0>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  801f3b:	89 f8                	mov    %edi,%eax
  801f3d:	8a 4d ec             	mov    -0x14(%ebp),%cl
  801f40:	d3 e0                	shl    %cl,%eax
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  801f42:	bf 20 00 00 00       	mov    $0x20,%edi
  801f47:	2b 7d ec             	sub    -0x14(%ebp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  801f4a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801f4d:	89 f9                	mov    %edi,%ecx
  801f4f:	d3 ea                	shr    %cl,%edx
  801f51:	09 c2                	or     %eax,%edx
  801f53:	89 55 f0             	mov    %edx,-0x10(%ebp)
	      d0 = d0 << bm;
  801f56:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f59:	8a 4d ec             	mov    -0x14(%ebp),%cl
  801f5c:	d3 e0                	shl    %cl,%eax
  801f5e:	89 45 f4             	mov    %eax,-0xc(%ebp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  801f61:	89 f2                	mov    %esi,%edx
  801f63:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  801f65:	8b 45 e8             	mov    -0x18(%ebp),%eax
  801f68:	d3 e0                	shl    %cl,%eax
  801f6a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  801f6d:	8b 45 e8             	mov    -0x18(%ebp),%eax
  801f70:	89 f9                	mov    %edi,%ecx
  801f72:	d3 e8                	shr    %cl,%eax
  801f74:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  801f76:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  801f78:	89 f2                	mov    %esi,%edx
  801f7a:	f7 75 f0             	divl   -0x10(%ebp)
  801f7d:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  801f7f:	f7 65 f4             	mull   -0xc(%ebp)
  801f82:	89 55 e8             	mov    %edx,-0x18(%ebp)
  801f85:	89 c1                	mov    %eax,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801f87:	39 d6                	cmp    %edx,%esi
  801f89:	72 71                	jb     801ffc <__umoddi3+0x110>
  801f8b:	74 7f                	je     80200c <__umoddi3+0x120>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  801f8d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801f90:	29 c8                	sub    %ecx,%eax
  801f92:	19 d6                	sbb    %edx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  801f94:	8a 4d ec             	mov    -0x14(%ebp),%cl
  801f97:	d3 e8                	shr    %cl,%eax
  801f99:	89 f2                	mov    %esi,%edx
  801f9b:	89 f9                	mov    %edi,%ecx
  801f9d:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  801f9f:	09 d0                	or     %edx,%eax
  801fa1:	89 f2                	mov    %esi,%edx
  801fa3:	8a 4d ec             	mov    -0x14(%ebp),%cl
  801fa6:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801fa8:	83 c4 20             	add    $0x20,%esp
  801fab:	5e                   	pop    %esi
  801fac:	5f                   	pop    %edi
  801fad:	c9                   	leave  
  801fae:	c3                   	ret    
  801faf:	90                   	nop
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  801fb0:	85 c9                	test   %ecx,%ecx
  801fb2:	75 0b                	jne    801fbf <__umoddi3+0xd3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  801fb4:	b8 01 00 00 00       	mov    $0x1,%eax
  801fb9:	31 d2                	xor    %edx,%edx
  801fbb:	f7 f1                	div    %ecx
  801fbd:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  801fbf:	89 f0                	mov    %esi,%eax
  801fc1:	31 d2                	xor    %edx,%edx
  801fc3:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801fc5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801fc8:	f7 f1                	div    %ecx
  801fca:	e9 4a ff ff ff       	jmp    801f19 <__umoddi3+0x2d>
  801fcf:	90                   	nop
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  801fd0:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801fd2:	83 c4 20             	add    $0x20,%esp
  801fd5:	5e                   	pop    %esi
  801fd6:	5f                   	pop    %edi
  801fd7:	c9                   	leave  
  801fd8:	c3                   	ret    
  801fd9:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801fdc:	39 f7                	cmp    %esi,%edi
  801fde:	72 05                	jb     801fe5 <__umoddi3+0xf9>
  801fe0:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
  801fe3:	77 0c                	ja     801ff1 <__umoddi3+0x105>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  801fe5:	89 f2                	mov    %esi,%edx
  801fe7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801fea:	29 c8                	sub    %ecx,%eax
  801fec:	19 fa                	sbb    %edi,%edx
  801fee:	89 45 f0             	mov    %eax,-0x10(%ebp)

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  801ff1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801ff4:	83 c4 20             	add    $0x20,%esp
  801ff7:	5e                   	pop    %esi
  801ff8:	5f                   	pop    %edi
  801ff9:	c9                   	leave  
  801ffa:	c3                   	ret    
  801ffb:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  801ffc:	8b 55 e8             	mov    -0x18(%ebp),%edx
  801fff:	89 c1                	mov    %eax,%ecx
  802001:	2b 4d f4             	sub    -0xc(%ebp),%ecx
  802004:	1b 55 f0             	sbb    -0x10(%ebp),%edx
  802007:	eb 84                	jmp    801f8d <__umoddi3+0xa1>
  802009:	8d 76 00             	lea    0x0(%esi),%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  80200c:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  80200f:	72 eb                	jb     801ffc <__umoddi3+0x110>
  802011:	89 f2                	mov    %esi,%edx
  802013:	e9 75 ff ff ff       	jmp    801f8d <__umoddi3+0xa1>
