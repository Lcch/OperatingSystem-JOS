
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
  800060:	68 00 20 80 00       	push   $0x802000
  800065:	e8 ae 16 00 00       	call   801718 <printf>
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
  80007f:	e8 e0 11 00 00       	call   801264 <write>
  800084:	83 c4 10             	add    $0x10,%esp
  800087:	83 f8 01             	cmp    $0x1,%eax
  80008a:	74 16                	je     8000a2 <num+0x6e>
			panic("write error copying %s: %e", s, r);
  80008c:	83 ec 0c             	sub    $0xc,%esp
  80008f:	50                   	push   %eax
  800090:	57                   	push   %edi
  800091:	68 05 20 80 00       	push   $0x802005
  800096:	6a 13                	push   $0x13
  800098:	68 20 20 80 00       	push   $0x802020
  80009d:	e8 52 01 00 00       	call   8001f4 <_panic>
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
  8000b9:	e8 ca 10 00 00       	call   801188 <read>
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
  8000ce:	68 2b 20 80 00       	push   $0x80202b
  8000d3:	6a 18                	push   $0x18
  8000d5:	68 20 20 80 00       	push   $0x802020
  8000da:	e8 15 01 00 00       	call   8001f4 <_panic>
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
  8000f0:	c7 05 04 30 80 00 40 	movl   $0x802040,0x803004
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
  80010b:	68 44 20 80 00       	push   $0x802044
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
  800131:	e8 56 14 00 00       	call   80158c <open>
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
  800148:	68 4c 20 80 00       	push   $0x80204c
  80014d:	6a 27                	push   $0x27
  80014f:	68 20 20 80 00       	push   $0x802020
  800154:	e8 9b 00 00 00       	call   8001f4 <_panic>
			else {
				num(f, argv[i]);
  800159:	83 ec 08             	sub    $0x8,%esp
  80015c:	ff 36                	pushl  (%esi)
  80015e:	50                   	push   %eax
  80015f:	e8 d0 fe ff ff       	call   800034 <num>
				close(f);
  800164:	89 1c 24             	mov    %ebx,(%esp)
  800167:	e8 df 0e 00 00       	call   80104b <close>

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
  800178:	e8 5b 00 00 00       	call   8001d8 <exit>
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
  800193:	e8 21 0b 00 00       	call   800cb9 <sys_getenvid>
  800198:	25 ff 03 00 00       	and    $0x3ff,%eax
  80019d:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  8001a4:	c1 e0 07             	shl    $0x7,%eax
  8001a7:	29 d0                	sub    %edx,%eax
  8001a9:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8001ae:	a3 08 40 80 00       	mov    %eax,0x804008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8001b3:	85 f6                	test   %esi,%esi
  8001b5:	7e 07                	jle    8001be <libmain+0x36>
		binaryname = argv[0];
  8001b7:	8b 03                	mov    (%ebx),%eax
  8001b9:	a3 04 30 80 00       	mov    %eax,0x803004
	// call user main routine
	umain(argc, argv);
  8001be:	83 ec 08             	sub    $0x8,%esp
  8001c1:	53                   	push   %ebx
  8001c2:	56                   	push   %esi
  8001c3:	e8 1f ff ff ff       	call   8000e7 <umain>

	// exit gracefully
	exit();
  8001c8:	e8 0b 00 00 00       	call   8001d8 <exit>
  8001cd:	83 c4 10             	add    $0x10,%esp
}
  8001d0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8001d3:	5b                   	pop    %ebx
  8001d4:	5e                   	pop    %esi
  8001d5:	c9                   	leave  
  8001d6:	c3                   	ret    
	...

008001d8 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8001d8:	55                   	push   %ebp
  8001d9:	89 e5                	mov    %esp,%ebp
  8001db:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8001de:	e8 93 0e 00 00       	call   801076 <close_all>
	sys_env_destroy(0);
  8001e3:	83 ec 0c             	sub    $0xc,%esp
  8001e6:	6a 00                	push   $0x0
  8001e8:	e8 aa 0a 00 00       	call   800c97 <sys_env_destroy>
  8001ed:	83 c4 10             	add    $0x10,%esp
}
  8001f0:	c9                   	leave  
  8001f1:	c3                   	ret    
	...

008001f4 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8001f4:	55                   	push   %ebp
  8001f5:	89 e5                	mov    %esp,%ebp
  8001f7:	56                   	push   %esi
  8001f8:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8001f9:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8001fc:	8b 1d 04 30 80 00    	mov    0x803004,%ebx
  800202:	e8 b2 0a 00 00       	call   800cb9 <sys_getenvid>
  800207:	83 ec 0c             	sub    $0xc,%esp
  80020a:	ff 75 0c             	pushl  0xc(%ebp)
  80020d:	ff 75 08             	pushl  0x8(%ebp)
  800210:	53                   	push   %ebx
  800211:	50                   	push   %eax
  800212:	68 68 20 80 00       	push   $0x802068
  800217:	e8 b0 00 00 00       	call   8002cc <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80021c:	83 c4 18             	add    $0x18,%esp
  80021f:	56                   	push   %esi
  800220:	ff 75 10             	pushl  0x10(%ebp)
  800223:	e8 53 00 00 00       	call   80027b <vcprintf>
	cprintf("\n");
  800228:	c7 04 24 87 24 80 00 	movl   $0x802487,(%esp)
  80022f:	e8 98 00 00 00       	call   8002cc <cprintf>
  800234:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800237:	cc                   	int3   
  800238:	eb fd                	jmp    800237 <_panic+0x43>
	...

0080023c <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80023c:	55                   	push   %ebp
  80023d:	89 e5                	mov    %esp,%ebp
  80023f:	53                   	push   %ebx
  800240:	83 ec 04             	sub    $0x4,%esp
  800243:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800246:	8b 03                	mov    (%ebx),%eax
  800248:	8b 55 08             	mov    0x8(%ebp),%edx
  80024b:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  80024f:	40                   	inc    %eax
  800250:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  800252:	3d ff 00 00 00       	cmp    $0xff,%eax
  800257:	75 1a                	jne    800273 <putch+0x37>
		sys_cputs(b->buf, b->idx);
  800259:	83 ec 08             	sub    $0x8,%esp
  80025c:	68 ff 00 00 00       	push   $0xff
  800261:	8d 43 08             	lea    0x8(%ebx),%eax
  800264:	50                   	push   %eax
  800265:	e8 e3 09 00 00       	call   800c4d <sys_cputs>
		b->idx = 0;
  80026a:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800270:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800273:	ff 43 04             	incl   0x4(%ebx)
}
  800276:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800279:	c9                   	leave  
  80027a:	c3                   	ret    

0080027b <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80027b:	55                   	push   %ebp
  80027c:	89 e5                	mov    %esp,%ebp
  80027e:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800284:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80028b:	00 00 00 
	b.cnt = 0;
  80028e:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800295:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800298:	ff 75 0c             	pushl  0xc(%ebp)
  80029b:	ff 75 08             	pushl  0x8(%ebp)
  80029e:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8002a4:	50                   	push   %eax
  8002a5:	68 3c 02 80 00       	push   $0x80023c
  8002aa:	e8 82 01 00 00       	call   800431 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8002af:	83 c4 08             	add    $0x8,%esp
  8002b2:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8002b8:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8002be:	50                   	push   %eax
  8002bf:	e8 89 09 00 00       	call   800c4d <sys_cputs>

	return b.cnt;
}
  8002c4:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8002ca:	c9                   	leave  
  8002cb:	c3                   	ret    

008002cc <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8002cc:	55                   	push   %ebp
  8002cd:	89 e5                	mov    %esp,%ebp
  8002cf:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8002d2:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8002d5:	50                   	push   %eax
  8002d6:	ff 75 08             	pushl  0x8(%ebp)
  8002d9:	e8 9d ff ff ff       	call   80027b <vcprintf>
	va_end(ap);

	return cnt;
}
  8002de:	c9                   	leave  
  8002df:	c3                   	ret    

008002e0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8002e0:	55                   	push   %ebp
  8002e1:	89 e5                	mov    %esp,%ebp
  8002e3:	57                   	push   %edi
  8002e4:	56                   	push   %esi
  8002e5:	53                   	push   %ebx
  8002e6:	83 ec 2c             	sub    $0x2c,%esp
  8002e9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8002ec:	89 d6                	mov    %edx,%esi
  8002ee:	8b 45 08             	mov    0x8(%ebp),%eax
  8002f1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002f4:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8002f7:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8002fa:	8b 45 10             	mov    0x10(%ebp),%eax
  8002fd:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800300:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800303:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800306:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  80030d:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
  800310:	72 0c                	jb     80031e <printnum+0x3e>
  800312:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  800315:	76 07                	jbe    80031e <printnum+0x3e>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800317:	4b                   	dec    %ebx
  800318:	85 db                	test   %ebx,%ebx
  80031a:	7f 31                	jg     80034d <printnum+0x6d>
  80031c:	eb 3f                	jmp    80035d <printnum+0x7d>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80031e:	83 ec 0c             	sub    $0xc,%esp
  800321:	57                   	push   %edi
  800322:	4b                   	dec    %ebx
  800323:	53                   	push   %ebx
  800324:	50                   	push   %eax
  800325:	83 ec 08             	sub    $0x8,%esp
  800328:	ff 75 d4             	pushl  -0x2c(%ebp)
  80032b:	ff 75 d0             	pushl  -0x30(%ebp)
  80032e:	ff 75 dc             	pushl  -0x24(%ebp)
  800331:	ff 75 d8             	pushl  -0x28(%ebp)
  800334:	e8 67 1a 00 00       	call   801da0 <__udivdi3>
  800339:	83 c4 18             	add    $0x18,%esp
  80033c:	52                   	push   %edx
  80033d:	50                   	push   %eax
  80033e:	89 f2                	mov    %esi,%edx
  800340:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800343:	e8 98 ff ff ff       	call   8002e0 <printnum>
  800348:	83 c4 20             	add    $0x20,%esp
  80034b:	eb 10                	jmp    80035d <printnum+0x7d>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80034d:	83 ec 08             	sub    $0x8,%esp
  800350:	56                   	push   %esi
  800351:	57                   	push   %edi
  800352:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800355:	4b                   	dec    %ebx
  800356:	83 c4 10             	add    $0x10,%esp
  800359:	85 db                	test   %ebx,%ebx
  80035b:	7f f0                	jg     80034d <printnum+0x6d>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80035d:	83 ec 08             	sub    $0x8,%esp
  800360:	56                   	push   %esi
  800361:	83 ec 04             	sub    $0x4,%esp
  800364:	ff 75 d4             	pushl  -0x2c(%ebp)
  800367:	ff 75 d0             	pushl  -0x30(%ebp)
  80036a:	ff 75 dc             	pushl  -0x24(%ebp)
  80036d:	ff 75 d8             	pushl  -0x28(%ebp)
  800370:	e8 47 1b 00 00       	call   801ebc <__umoddi3>
  800375:	83 c4 14             	add    $0x14,%esp
  800378:	0f be 80 8b 20 80 00 	movsbl 0x80208b(%eax),%eax
  80037f:	50                   	push   %eax
  800380:	ff 55 e4             	call   *-0x1c(%ebp)
  800383:	83 c4 10             	add    $0x10,%esp
}
  800386:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800389:	5b                   	pop    %ebx
  80038a:	5e                   	pop    %esi
  80038b:	5f                   	pop    %edi
  80038c:	c9                   	leave  
  80038d:	c3                   	ret    

0080038e <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80038e:	55                   	push   %ebp
  80038f:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800391:	83 fa 01             	cmp    $0x1,%edx
  800394:	7e 0e                	jle    8003a4 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800396:	8b 10                	mov    (%eax),%edx
  800398:	8d 4a 08             	lea    0x8(%edx),%ecx
  80039b:	89 08                	mov    %ecx,(%eax)
  80039d:	8b 02                	mov    (%edx),%eax
  80039f:	8b 52 04             	mov    0x4(%edx),%edx
  8003a2:	eb 22                	jmp    8003c6 <getuint+0x38>
	else if (lflag)
  8003a4:	85 d2                	test   %edx,%edx
  8003a6:	74 10                	je     8003b8 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8003a8:	8b 10                	mov    (%eax),%edx
  8003aa:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003ad:	89 08                	mov    %ecx,(%eax)
  8003af:	8b 02                	mov    (%edx),%eax
  8003b1:	ba 00 00 00 00       	mov    $0x0,%edx
  8003b6:	eb 0e                	jmp    8003c6 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8003b8:	8b 10                	mov    (%eax),%edx
  8003ba:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003bd:	89 08                	mov    %ecx,(%eax)
  8003bf:	8b 02                	mov    (%edx),%eax
  8003c1:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8003c6:	c9                   	leave  
  8003c7:	c3                   	ret    

008003c8 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  8003c8:	55                   	push   %ebp
  8003c9:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8003cb:	83 fa 01             	cmp    $0x1,%edx
  8003ce:	7e 0e                	jle    8003de <getint+0x16>
		return va_arg(*ap, long long);
  8003d0:	8b 10                	mov    (%eax),%edx
  8003d2:	8d 4a 08             	lea    0x8(%edx),%ecx
  8003d5:	89 08                	mov    %ecx,(%eax)
  8003d7:	8b 02                	mov    (%edx),%eax
  8003d9:	8b 52 04             	mov    0x4(%edx),%edx
  8003dc:	eb 1a                	jmp    8003f8 <getint+0x30>
	else if (lflag)
  8003de:	85 d2                	test   %edx,%edx
  8003e0:	74 0c                	je     8003ee <getint+0x26>
		return va_arg(*ap, long);
  8003e2:	8b 10                	mov    (%eax),%edx
  8003e4:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003e7:	89 08                	mov    %ecx,(%eax)
  8003e9:	8b 02                	mov    (%edx),%eax
  8003eb:	99                   	cltd   
  8003ec:	eb 0a                	jmp    8003f8 <getint+0x30>
	else
		return va_arg(*ap, int);
  8003ee:	8b 10                	mov    (%eax),%edx
  8003f0:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003f3:	89 08                	mov    %ecx,(%eax)
  8003f5:	8b 02                	mov    (%edx),%eax
  8003f7:	99                   	cltd   
}
  8003f8:	c9                   	leave  
  8003f9:	c3                   	ret    

008003fa <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8003fa:	55                   	push   %ebp
  8003fb:	89 e5                	mov    %esp,%ebp
  8003fd:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800400:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  800403:	8b 10                	mov    (%eax),%edx
  800405:	3b 50 04             	cmp    0x4(%eax),%edx
  800408:	73 08                	jae    800412 <sprintputch+0x18>
		*b->buf++ = ch;
  80040a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80040d:	88 0a                	mov    %cl,(%edx)
  80040f:	42                   	inc    %edx
  800410:	89 10                	mov    %edx,(%eax)
}
  800412:	c9                   	leave  
  800413:	c3                   	ret    

00800414 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800414:	55                   	push   %ebp
  800415:	89 e5                	mov    %esp,%ebp
  800417:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80041a:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80041d:	50                   	push   %eax
  80041e:	ff 75 10             	pushl  0x10(%ebp)
  800421:	ff 75 0c             	pushl  0xc(%ebp)
  800424:	ff 75 08             	pushl  0x8(%ebp)
  800427:	e8 05 00 00 00       	call   800431 <vprintfmt>
	va_end(ap);
  80042c:	83 c4 10             	add    $0x10,%esp
}
  80042f:	c9                   	leave  
  800430:	c3                   	ret    

00800431 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800431:	55                   	push   %ebp
  800432:	89 e5                	mov    %esp,%ebp
  800434:	57                   	push   %edi
  800435:	56                   	push   %esi
  800436:	53                   	push   %ebx
  800437:	83 ec 2c             	sub    $0x2c,%esp
  80043a:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80043d:	8b 75 10             	mov    0x10(%ebp),%esi
  800440:	eb 13                	jmp    800455 <vprintfmt+0x24>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800442:	85 c0                	test   %eax,%eax
  800444:	0f 84 6d 03 00 00    	je     8007b7 <vprintfmt+0x386>
				return;
			putch(ch, putdat);
  80044a:	83 ec 08             	sub    $0x8,%esp
  80044d:	57                   	push   %edi
  80044e:	50                   	push   %eax
  80044f:	ff 55 08             	call   *0x8(%ebp)
  800452:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800455:	0f b6 06             	movzbl (%esi),%eax
  800458:	46                   	inc    %esi
  800459:	83 f8 25             	cmp    $0x25,%eax
  80045c:	75 e4                	jne    800442 <vprintfmt+0x11>
  80045e:	c6 45 dc 20          	movb   $0x20,-0x24(%ebp)
  800462:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  800469:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  800470:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800477:	b9 00 00 00 00       	mov    $0x0,%ecx
  80047c:	eb 28                	jmp    8004a6 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80047e:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800480:	c6 45 dc 2d          	movb   $0x2d,-0x24(%ebp)
  800484:	eb 20                	jmp    8004a6 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800486:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800488:	c6 45 dc 30          	movb   $0x30,-0x24(%ebp)
  80048c:	eb 18                	jmp    8004a6 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80048e:	89 de                	mov    %ebx,%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800490:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800497:	eb 0d                	jmp    8004a6 <vprintfmt+0x75>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800499:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80049c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80049f:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004a6:	8a 06                	mov    (%esi),%al
  8004a8:	0f b6 d0             	movzbl %al,%edx
  8004ab:	8d 5e 01             	lea    0x1(%esi),%ebx
  8004ae:	83 e8 23             	sub    $0x23,%eax
  8004b1:	3c 55                	cmp    $0x55,%al
  8004b3:	0f 87 e0 02 00 00    	ja     800799 <vprintfmt+0x368>
  8004b9:	0f b6 c0             	movzbl %al,%eax
  8004bc:	ff 24 85 c0 21 80 00 	jmp    *0x8021c0(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8004c3:	83 ea 30             	sub    $0x30,%edx
  8004c6:	89 55 d4             	mov    %edx,-0x2c(%ebp)
				ch = *fmt;
  8004c9:	0f be 03             	movsbl (%ebx),%eax
				if (ch < '0' || ch > '9')
  8004cc:	8d 50 d0             	lea    -0x30(%eax),%edx
  8004cf:	83 fa 09             	cmp    $0x9,%edx
  8004d2:	77 44                	ja     800518 <vprintfmt+0xe7>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004d4:	89 de                	mov    %ebx,%esi
  8004d6:	8b 55 d4             	mov    -0x2c(%ebp),%edx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8004d9:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
  8004da:	8d 14 92             	lea    (%edx,%edx,4),%edx
  8004dd:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
  8004e1:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8004e4:	8d 58 d0             	lea    -0x30(%eax),%ebx
  8004e7:	83 fb 09             	cmp    $0x9,%ebx
  8004ea:	76 ed                	jbe    8004d9 <vprintfmt+0xa8>
  8004ec:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  8004ef:	eb 29                	jmp    80051a <vprintfmt+0xe9>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8004f1:	8b 45 14             	mov    0x14(%ebp),%eax
  8004f4:	8d 50 04             	lea    0x4(%eax),%edx
  8004f7:	89 55 14             	mov    %edx,0x14(%ebp)
  8004fa:	8b 00                	mov    (%eax),%eax
  8004fc:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004ff:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800501:	eb 17                	jmp    80051a <vprintfmt+0xe9>

		case '.':
			if (width < 0)
  800503:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800507:	78 85                	js     80048e <vprintfmt+0x5d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800509:	89 de                	mov    %ebx,%esi
  80050b:	eb 99                	jmp    8004a6 <vprintfmt+0x75>
  80050d:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80050f:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  800516:	eb 8e                	jmp    8004a6 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800518:	89 de                	mov    %ebx,%esi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  80051a:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80051e:	79 86                	jns    8004a6 <vprintfmt+0x75>
  800520:	e9 74 ff ff ff       	jmp    800499 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800525:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800526:	89 de                	mov    %ebx,%esi
  800528:	e9 79 ff ff ff       	jmp    8004a6 <vprintfmt+0x75>
  80052d:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800530:	8b 45 14             	mov    0x14(%ebp),%eax
  800533:	8d 50 04             	lea    0x4(%eax),%edx
  800536:	89 55 14             	mov    %edx,0x14(%ebp)
  800539:	83 ec 08             	sub    $0x8,%esp
  80053c:	57                   	push   %edi
  80053d:	ff 30                	pushl  (%eax)
  80053f:	ff 55 08             	call   *0x8(%ebp)
			break;
  800542:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800545:	8b 75 d8             	mov    -0x28(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800548:	e9 08 ff ff ff       	jmp    800455 <vprintfmt+0x24>
  80054d:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  800550:	8b 45 14             	mov    0x14(%ebp),%eax
  800553:	8d 50 04             	lea    0x4(%eax),%edx
  800556:	89 55 14             	mov    %edx,0x14(%ebp)
  800559:	8b 00                	mov    (%eax),%eax
  80055b:	85 c0                	test   %eax,%eax
  80055d:	79 02                	jns    800561 <vprintfmt+0x130>
  80055f:	f7 d8                	neg    %eax
  800561:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800563:	83 f8 0f             	cmp    $0xf,%eax
  800566:	7f 0b                	jg     800573 <vprintfmt+0x142>
  800568:	8b 04 85 20 23 80 00 	mov    0x802320(,%eax,4),%eax
  80056f:	85 c0                	test   %eax,%eax
  800571:	75 1a                	jne    80058d <vprintfmt+0x15c>
				printfmt(putch, putdat, "error %d", err);
  800573:	52                   	push   %edx
  800574:	68 a3 20 80 00       	push   $0x8020a3
  800579:	57                   	push   %edi
  80057a:	ff 75 08             	pushl  0x8(%ebp)
  80057d:	e8 92 fe ff ff       	call   800414 <printfmt>
  800582:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800585:	8b 75 d8             	mov    -0x28(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800588:	e9 c8 fe ff ff       	jmp    800455 <vprintfmt+0x24>
			else
				printfmt(putch, putdat, "%s", p);
  80058d:	50                   	push   %eax
  80058e:	68 55 24 80 00       	push   $0x802455
  800593:	57                   	push   %edi
  800594:	ff 75 08             	pushl  0x8(%ebp)
  800597:	e8 78 fe ff ff       	call   800414 <printfmt>
  80059c:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80059f:	8b 75 d8             	mov    -0x28(%ebp),%esi
  8005a2:	e9 ae fe ff ff       	jmp    800455 <vprintfmt+0x24>
  8005a7:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  8005aa:	89 de                	mov    %ebx,%esi
  8005ac:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  8005af:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8005b2:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b5:	8d 50 04             	lea    0x4(%eax),%edx
  8005b8:	89 55 14             	mov    %edx,0x14(%ebp)
  8005bb:	8b 00                	mov    (%eax),%eax
  8005bd:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8005c0:	85 c0                	test   %eax,%eax
  8005c2:	75 07                	jne    8005cb <vprintfmt+0x19a>
				p = "(null)";
  8005c4:	c7 45 d0 9c 20 80 00 	movl   $0x80209c,-0x30(%ebp)
			if (width > 0 && padc != '-')
  8005cb:	85 db                	test   %ebx,%ebx
  8005cd:	7e 42                	jle    800611 <vprintfmt+0x1e0>
  8005cf:	80 7d dc 2d          	cmpb   $0x2d,-0x24(%ebp)
  8005d3:	74 3c                	je     800611 <vprintfmt+0x1e0>
				for (width -= strnlen(p, precision); width > 0; width--)
  8005d5:	83 ec 08             	sub    $0x8,%esp
  8005d8:	51                   	push   %ecx
  8005d9:	ff 75 d0             	pushl  -0x30(%ebp)
  8005dc:	e8 6f 02 00 00       	call   800850 <strnlen>
  8005e1:	29 c3                	sub    %eax,%ebx
  8005e3:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8005e6:	83 c4 10             	add    $0x10,%esp
  8005e9:	85 db                	test   %ebx,%ebx
  8005eb:	7e 24                	jle    800611 <vprintfmt+0x1e0>
					putch(padc, putdat);
  8005ed:	0f be 5d dc          	movsbl -0x24(%ebp),%ebx
  8005f1:	89 75 dc             	mov    %esi,-0x24(%ebp)
  8005f4:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  8005f7:	83 ec 08             	sub    $0x8,%esp
  8005fa:	57                   	push   %edi
  8005fb:	53                   	push   %ebx
  8005fc:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005ff:	4e                   	dec    %esi
  800600:	83 c4 10             	add    $0x10,%esp
  800603:	85 f6                	test   %esi,%esi
  800605:	7f f0                	jg     8005f7 <vprintfmt+0x1c6>
  800607:	8b 75 dc             	mov    -0x24(%ebp),%esi
  80060a:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800611:	8b 55 d0             	mov    -0x30(%ebp),%edx
  800614:	0f be 02             	movsbl (%edx),%eax
  800617:	85 c0                	test   %eax,%eax
  800619:	75 47                	jne    800662 <vprintfmt+0x231>
  80061b:	eb 37                	jmp    800654 <vprintfmt+0x223>
				if (altflag && (ch < ' ' || ch > '~'))
  80061d:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800621:	74 16                	je     800639 <vprintfmt+0x208>
  800623:	8d 50 e0             	lea    -0x20(%eax),%edx
  800626:	83 fa 5e             	cmp    $0x5e,%edx
  800629:	76 0e                	jbe    800639 <vprintfmt+0x208>
					putch('?', putdat);
  80062b:	83 ec 08             	sub    $0x8,%esp
  80062e:	57                   	push   %edi
  80062f:	6a 3f                	push   $0x3f
  800631:	ff 55 08             	call   *0x8(%ebp)
  800634:	83 c4 10             	add    $0x10,%esp
  800637:	eb 0b                	jmp    800644 <vprintfmt+0x213>
				else
					putch(ch, putdat);
  800639:	83 ec 08             	sub    $0x8,%esp
  80063c:	57                   	push   %edi
  80063d:	50                   	push   %eax
  80063e:	ff 55 08             	call   *0x8(%ebp)
  800641:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800644:	ff 4d e4             	decl   -0x1c(%ebp)
  800647:	0f be 03             	movsbl (%ebx),%eax
  80064a:	85 c0                	test   %eax,%eax
  80064c:	74 03                	je     800651 <vprintfmt+0x220>
  80064e:	43                   	inc    %ebx
  80064f:	eb 1b                	jmp    80066c <vprintfmt+0x23b>
  800651:	8b 75 dc             	mov    -0x24(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800654:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800658:	7f 1e                	jg     800678 <vprintfmt+0x247>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80065a:	8b 75 d8             	mov    -0x28(%ebp),%esi
  80065d:	e9 f3 fd ff ff       	jmp    800455 <vprintfmt+0x24>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800662:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800665:	43                   	inc    %ebx
  800666:	89 75 dc             	mov    %esi,-0x24(%ebp)
  800669:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  80066c:	85 f6                	test   %esi,%esi
  80066e:	78 ad                	js     80061d <vprintfmt+0x1ec>
  800670:	4e                   	dec    %esi
  800671:	79 aa                	jns    80061d <vprintfmt+0x1ec>
  800673:	8b 75 dc             	mov    -0x24(%ebp),%esi
  800676:	eb dc                	jmp    800654 <vprintfmt+0x223>
  800678:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80067b:	83 ec 08             	sub    $0x8,%esp
  80067e:	57                   	push   %edi
  80067f:	6a 20                	push   $0x20
  800681:	ff 55 08             	call   *0x8(%ebp)
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800684:	4b                   	dec    %ebx
  800685:	83 c4 10             	add    $0x10,%esp
  800688:	85 db                	test   %ebx,%ebx
  80068a:	7f ef                	jg     80067b <vprintfmt+0x24a>
  80068c:	e9 c4 fd ff ff       	jmp    800455 <vprintfmt+0x24>
  800691:	89 5d d8             	mov    %ebx,-0x28(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800694:	89 ca                	mov    %ecx,%edx
  800696:	8d 45 14             	lea    0x14(%ebp),%eax
  800699:	e8 2a fd ff ff       	call   8003c8 <getint>
  80069e:	89 c3                	mov    %eax,%ebx
  8006a0:	89 d6                	mov    %edx,%esi
			if ((long long) num < 0) {
  8006a2:	85 d2                	test   %edx,%edx
  8006a4:	78 0a                	js     8006b0 <vprintfmt+0x27f>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8006a6:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006ab:	e9 b0 00 00 00       	jmp    800760 <vprintfmt+0x32f>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  8006b0:	83 ec 08             	sub    $0x8,%esp
  8006b3:	57                   	push   %edi
  8006b4:	6a 2d                	push   $0x2d
  8006b6:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8006b9:	f7 db                	neg    %ebx
  8006bb:	83 d6 00             	adc    $0x0,%esi
  8006be:	f7 de                	neg    %esi
  8006c0:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8006c3:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006c8:	e9 93 00 00 00       	jmp    800760 <vprintfmt+0x32f>
  8006cd:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8006d0:	89 ca                	mov    %ecx,%edx
  8006d2:	8d 45 14             	lea    0x14(%ebp),%eax
  8006d5:	e8 b4 fc ff ff       	call   80038e <getuint>
  8006da:	89 c3                	mov    %eax,%ebx
  8006dc:	89 d6                	mov    %edx,%esi
			base = 10;
  8006de:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  8006e3:	eb 7b                	jmp    800760 <vprintfmt+0x32f>
  8006e5:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
  8006e8:	89 ca                	mov    %ecx,%edx
  8006ea:	8d 45 14             	lea    0x14(%ebp),%eax
  8006ed:	e8 d6 fc ff ff       	call   8003c8 <getint>
  8006f2:	89 c3                	mov    %eax,%ebx
  8006f4:	89 d6                	mov    %edx,%esi
            if ((long long) num < 0) {
  8006f6:	85 d2                	test   %edx,%edx
  8006f8:	78 07                	js     800701 <vprintfmt+0x2d0>
                putch('-', putdat);
                num = -(long long) num;
            }
            base = 8;
  8006fa:	b8 08 00 00 00       	mov    $0x8,%eax
  8006ff:	eb 5f                	jmp    800760 <vprintfmt+0x32f>
		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
            if ((long long) num < 0) {
                putch('-', putdat);
  800701:	83 ec 08             	sub    $0x8,%esp
  800704:	57                   	push   %edi
  800705:	6a 2d                	push   $0x2d
  800707:	ff 55 08             	call   *0x8(%ebp)
                num = -(long long) num;
  80070a:	f7 db                	neg    %ebx
  80070c:	83 d6 00             	adc    $0x0,%esi
  80070f:	f7 de                	neg    %esi
  800711:	83 c4 10             	add    $0x10,%esp
            }
            base = 8;
  800714:	b8 08 00 00 00       	mov    $0x8,%eax
  800719:	eb 45                	jmp    800760 <vprintfmt+0x32f>
  80071b:	89 5d d8             	mov    %ebx,-0x28(%ebp)
            goto number;

        // pointer
		case 'p':
			putch('0', putdat);
  80071e:	83 ec 08             	sub    $0x8,%esp
  800721:	57                   	push   %edi
  800722:	6a 30                	push   $0x30
  800724:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800727:	83 c4 08             	add    $0x8,%esp
  80072a:	57                   	push   %edi
  80072b:	6a 78                	push   $0x78
  80072d:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800730:	8b 45 14             	mov    0x14(%ebp),%eax
  800733:	8d 50 04             	lea    0x4(%eax),%edx
  800736:	89 55 14             	mov    %edx,0x14(%ebp)

        // pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800739:	8b 18                	mov    (%eax),%ebx
  80073b:	be 00 00 00 00       	mov    $0x0,%esi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800740:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800743:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800748:	eb 16                	jmp    800760 <vprintfmt+0x32f>
  80074a:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80074d:	89 ca                	mov    %ecx,%edx
  80074f:	8d 45 14             	lea    0x14(%ebp),%eax
  800752:	e8 37 fc ff ff       	call   80038e <getuint>
  800757:	89 c3                	mov    %eax,%ebx
  800759:	89 d6                	mov    %edx,%esi
			base = 16;
  80075b:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800760:	83 ec 0c             	sub    $0xc,%esp
  800763:	0f be 55 dc          	movsbl -0x24(%ebp),%edx
  800767:	52                   	push   %edx
  800768:	ff 75 e4             	pushl  -0x1c(%ebp)
  80076b:	50                   	push   %eax
  80076c:	56                   	push   %esi
  80076d:	53                   	push   %ebx
  80076e:	89 fa                	mov    %edi,%edx
  800770:	8b 45 08             	mov    0x8(%ebp),%eax
  800773:	e8 68 fb ff ff       	call   8002e0 <printnum>
			break;
  800778:	83 c4 20             	add    $0x20,%esp
  80077b:	8b 75 d8             	mov    -0x28(%ebp),%esi
  80077e:	e9 d2 fc ff ff       	jmp    800455 <vprintfmt+0x24>
  800783:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800786:	83 ec 08             	sub    $0x8,%esp
  800789:	57                   	push   %edi
  80078a:	52                   	push   %edx
  80078b:	ff 55 08             	call   *0x8(%ebp)
			break;
  80078e:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800791:	8b 75 d8             	mov    -0x28(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800794:	e9 bc fc ff ff       	jmp    800455 <vprintfmt+0x24>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800799:	83 ec 08             	sub    $0x8,%esp
  80079c:	57                   	push   %edi
  80079d:	6a 25                	push   $0x25
  80079f:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8007a2:	83 c4 10             	add    $0x10,%esp
  8007a5:	eb 02                	jmp    8007a9 <vprintfmt+0x378>
  8007a7:	89 c6                	mov    %eax,%esi
  8007a9:	8d 46 ff             	lea    -0x1(%esi),%eax
  8007ac:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  8007b0:	75 f5                	jne    8007a7 <vprintfmt+0x376>
  8007b2:	e9 9e fc ff ff       	jmp    800455 <vprintfmt+0x24>
				/* do nothing */;
			break;
		}
	}
}
  8007b7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8007ba:	5b                   	pop    %ebx
  8007bb:	5e                   	pop    %esi
  8007bc:	5f                   	pop    %edi
  8007bd:	c9                   	leave  
  8007be:	c3                   	ret    

008007bf <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8007bf:	55                   	push   %ebp
  8007c0:	89 e5                	mov    %esp,%ebp
  8007c2:	83 ec 18             	sub    $0x18,%esp
  8007c5:	8b 45 08             	mov    0x8(%ebp),%eax
  8007c8:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8007cb:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8007ce:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8007d2:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8007d5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8007dc:	85 c0                	test   %eax,%eax
  8007de:	74 26                	je     800806 <vsnprintf+0x47>
  8007e0:	85 d2                	test   %edx,%edx
  8007e2:	7e 29                	jle    80080d <vsnprintf+0x4e>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8007e4:	ff 75 14             	pushl  0x14(%ebp)
  8007e7:	ff 75 10             	pushl  0x10(%ebp)
  8007ea:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8007ed:	50                   	push   %eax
  8007ee:	68 fa 03 80 00       	push   $0x8003fa
  8007f3:	e8 39 fc ff ff       	call   800431 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8007f8:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007fb:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8007fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800801:	83 c4 10             	add    $0x10,%esp
  800804:	eb 0c                	jmp    800812 <vsnprintf+0x53>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800806:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80080b:	eb 05                	jmp    800812 <vsnprintf+0x53>
  80080d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800812:	c9                   	leave  
  800813:	c3                   	ret    

00800814 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800814:	55                   	push   %ebp
  800815:	89 e5                	mov    %esp,%ebp
  800817:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80081a:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80081d:	50                   	push   %eax
  80081e:	ff 75 10             	pushl  0x10(%ebp)
  800821:	ff 75 0c             	pushl  0xc(%ebp)
  800824:	ff 75 08             	pushl  0x8(%ebp)
  800827:	e8 93 ff ff ff       	call   8007bf <vsnprintf>
	va_end(ap);

	return rc;
}
  80082c:	c9                   	leave  
  80082d:	c3                   	ret    
	...

00800830 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800830:	55                   	push   %ebp
  800831:	89 e5                	mov    %esp,%ebp
  800833:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800836:	80 3a 00             	cmpb   $0x0,(%edx)
  800839:	74 0e                	je     800849 <strlen+0x19>
  80083b:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800840:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800841:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800845:	75 f9                	jne    800840 <strlen+0x10>
  800847:	eb 05                	jmp    80084e <strlen+0x1e>
  800849:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  80084e:	c9                   	leave  
  80084f:	c3                   	ret    

00800850 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800850:	55                   	push   %ebp
  800851:	89 e5                	mov    %esp,%ebp
  800853:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800856:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800859:	85 d2                	test   %edx,%edx
  80085b:	74 17                	je     800874 <strnlen+0x24>
  80085d:	80 39 00             	cmpb   $0x0,(%ecx)
  800860:	74 19                	je     80087b <strnlen+0x2b>
  800862:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800867:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800868:	39 d0                	cmp    %edx,%eax
  80086a:	74 14                	je     800880 <strnlen+0x30>
  80086c:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800870:	75 f5                	jne    800867 <strnlen+0x17>
  800872:	eb 0c                	jmp    800880 <strnlen+0x30>
  800874:	b8 00 00 00 00       	mov    $0x0,%eax
  800879:	eb 05                	jmp    800880 <strnlen+0x30>
  80087b:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800880:	c9                   	leave  
  800881:	c3                   	ret    

00800882 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800882:	55                   	push   %ebp
  800883:	89 e5                	mov    %esp,%ebp
  800885:	53                   	push   %ebx
  800886:	8b 45 08             	mov    0x8(%ebp),%eax
  800889:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80088c:	ba 00 00 00 00       	mov    $0x0,%edx
  800891:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  800894:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800897:	42                   	inc    %edx
  800898:	84 c9                	test   %cl,%cl
  80089a:	75 f5                	jne    800891 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  80089c:	5b                   	pop    %ebx
  80089d:	c9                   	leave  
  80089e:	c3                   	ret    

0080089f <strcat>:

char *
strcat(char *dst, const char *src)
{
  80089f:	55                   	push   %ebp
  8008a0:	89 e5                	mov    %esp,%ebp
  8008a2:	53                   	push   %ebx
  8008a3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8008a6:	53                   	push   %ebx
  8008a7:	e8 84 ff ff ff       	call   800830 <strlen>
  8008ac:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8008af:	ff 75 0c             	pushl  0xc(%ebp)
  8008b2:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  8008b5:	50                   	push   %eax
  8008b6:	e8 c7 ff ff ff       	call   800882 <strcpy>
	return dst;
}
  8008bb:	89 d8                	mov    %ebx,%eax
  8008bd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008c0:	c9                   	leave  
  8008c1:	c3                   	ret    

008008c2 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8008c2:	55                   	push   %ebp
  8008c3:	89 e5                	mov    %esp,%ebp
  8008c5:	56                   	push   %esi
  8008c6:	53                   	push   %ebx
  8008c7:	8b 45 08             	mov    0x8(%ebp),%eax
  8008ca:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008cd:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008d0:	85 f6                	test   %esi,%esi
  8008d2:	74 15                	je     8008e9 <strncpy+0x27>
  8008d4:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  8008d9:	8a 1a                	mov    (%edx),%bl
  8008db:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8008de:	80 3a 01             	cmpb   $0x1,(%edx)
  8008e1:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008e4:	41                   	inc    %ecx
  8008e5:	39 ce                	cmp    %ecx,%esi
  8008e7:	77 f0                	ja     8008d9 <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8008e9:	5b                   	pop    %ebx
  8008ea:	5e                   	pop    %esi
  8008eb:	c9                   	leave  
  8008ec:	c3                   	ret    

008008ed <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8008ed:	55                   	push   %ebp
  8008ee:	89 e5                	mov    %esp,%ebp
  8008f0:	57                   	push   %edi
  8008f1:	56                   	push   %esi
  8008f2:	53                   	push   %ebx
  8008f3:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008f6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8008f9:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8008fc:	85 f6                	test   %esi,%esi
  8008fe:	74 32                	je     800932 <strlcpy+0x45>
		while (--size > 0 && *src != '\0')
  800900:	83 fe 01             	cmp    $0x1,%esi
  800903:	74 22                	je     800927 <strlcpy+0x3a>
  800905:	8a 0b                	mov    (%ebx),%cl
  800907:	84 c9                	test   %cl,%cl
  800909:	74 20                	je     80092b <strlcpy+0x3e>
  80090b:	89 f8                	mov    %edi,%eax
  80090d:	ba 00 00 00 00       	mov    $0x0,%edx
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
  800912:	83 ee 02             	sub    $0x2,%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800915:	88 08                	mov    %cl,(%eax)
  800917:	40                   	inc    %eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800918:	39 f2                	cmp    %esi,%edx
  80091a:	74 11                	je     80092d <strlcpy+0x40>
  80091c:	8a 4c 13 01          	mov    0x1(%ebx,%edx,1),%cl
  800920:	42                   	inc    %edx
  800921:	84 c9                	test   %cl,%cl
  800923:	75 f0                	jne    800915 <strlcpy+0x28>
  800925:	eb 06                	jmp    80092d <strlcpy+0x40>
  800927:	89 f8                	mov    %edi,%eax
  800929:	eb 02                	jmp    80092d <strlcpy+0x40>
  80092b:	89 f8                	mov    %edi,%eax
			*dst++ = *src++;
		*dst = '\0';
  80092d:	c6 00 00             	movb   $0x0,(%eax)
  800930:	eb 02                	jmp    800934 <strlcpy+0x47>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800932:	89 f8                	mov    %edi,%eax
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
		*dst = '\0';
	}
	return dst - dst_in;
  800934:	29 f8                	sub    %edi,%eax
}
  800936:	5b                   	pop    %ebx
  800937:	5e                   	pop    %esi
  800938:	5f                   	pop    %edi
  800939:	c9                   	leave  
  80093a:	c3                   	ret    

0080093b <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80093b:	55                   	push   %ebp
  80093c:	89 e5                	mov    %esp,%ebp
  80093e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800941:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800944:	8a 01                	mov    (%ecx),%al
  800946:	84 c0                	test   %al,%al
  800948:	74 10                	je     80095a <strcmp+0x1f>
  80094a:	3a 02                	cmp    (%edx),%al
  80094c:	75 0c                	jne    80095a <strcmp+0x1f>
		p++, q++;
  80094e:	41                   	inc    %ecx
  80094f:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800950:	8a 01                	mov    (%ecx),%al
  800952:	84 c0                	test   %al,%al
  800954:	74 04                	je     80095a <strcmp+0x1f>
  800956:	3a 02                	cmp    (%edx),%al
  800958:	74 f4                	je     80094e <strcmp+0x13>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80095a:	0f b6 c0             	movzbl %al,%eax
  80095d:	0f b6 12             	movzbl (%edx),%edx
  800960:	29 d0                	sub    %edx,%eax
}
  800962:	c9                   	leave  
  800963:	c3                   	ret    

00800964 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800964:	55                   	push   %ebp
  800965:	89 e5                	mov    %esp,%ebp
  800967:	53                   	push   %ebx
  800968:	8b 55 08             	mov    0x8(%ebp),%edx
  80096b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80096e:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  800971:	85 c0                	test   %eax,%eax
  800973:	74 1b                	je     800990 <strncmp+0x2c>
  800975:	8a 1a                	mov    (%edx),%bl
  800977:	84 db                	test   %bl,%bl
  800979:	74 24                	je     80099f <strncmp+0x3b>
  80097b:	3a 19                	cmp    (%ecx),%bl
  80097d:	75 20                	jne    80099f <strncmp+0x3b>
  80097f:	48                   	dec    %eax
  800980:	74 15                	je     800997 <strncmp+0x33>
		n--, p++, q++;
  800982:	42                   	inc    %edx
  800983:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800984:	8a 1a                	mov    (%edx),%bl
  800986:	84 db                	test   %bl,%bl
  800988:	74 15                	je     80099f <strncmp+0x3b>
  80098a:	3a 19                	cmp    (%ecx),%bl
  80098c:	74 f1                	je     80097f <strncmp+0x1b>
  80098e:	eb 0f                	jmp    80099f <strncmp+0x3b>
		n--, p++, q++;
	if (n == 0)
		return 0;
  800990:	b8 00 00 00 00       	mov    $0x0,%eax
  800995:	eb 05                	jmp    80099c <strncmp+0x38>
  800997:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80099c:	5b                   	pop    %ebx
  80099d:	c9                   	leave  
  80099e:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80099f:	0f b6 02             	movzbl (%edx),%eax
  8009a2:	0f b6 11             	movzbl (%ecx),%edx
  8009a5:	29 d0                	sub    %edx,%eax
  8009a7:	eb f3                	jmp    80099c <strncmp+0x38>

008009a9 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8009a9:	55                   	push   %ebp
  8009aa:	89 e5                	mov    %esp,%ebp
  8009ac:	8b 45 08             	mov    0x8(%ebp),%eax
  8009af:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8009b2:	8a 10                	mov    (%eax),%dl
  8009b4:	84 d2                	test   %dl,%dl
  8009b6:	74 18                	je     8009d0 <strchr+0x27>
		if (*s == c)
  8009b8:	38 ca                	cmp    %cl,%dl
  8009ba:	75 06                	jne    8009c2 <strchr+0x19>
  8009bc:	eb 17                	jmp    8009d5 <strchr+0x2c>
  8009be:	38 ca                	cmp    %cl,%dl
  8009c0:	74 13                	je     8009d5 <strchr+0x2c>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8009c2:	40                   	inc    %eax
  8009c3:	8a 10                	mov    (%eax),%dl
  8009c5:	84 d2                	test   %dl,%dl
  8009c7:	75 f5                	jne    8009be <strchr+0x15>
		if (*s == c)
			return (char *) s;
	return 0;
  8009c9:	b8 00 00 00 00       	mov    $0x0,%eax
  8009ce:	eb 05                	jmp    8009d5 <strchr+0x2c>
  8009d0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009d5:	c9                   	leave  
  8009d6:	c3                   	ret    

008009d7 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8009d7:	55                   	push   %ebp
  8009d8:	89 e5                	mov    %esp,%ebp
  8009da:	8b 45 08             	mov    0x8(%ebp),%eax
  8009dd:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8009e0:	8a 10                	mov    (%eax),%dl
  8009e2:	84 d2                	test   %dl,%dl
  8009e4:	74 11                	je     8009f7 <strfind+0x20>
		if (*s == c)
  8009e6:	38 ca                	cmp    %cl,%dl
  8009e8:	75 06                	jne    8009f0 <strfind+0x19>
  8009ea:	eb 0b                	jmp    8009f7 <strfind+0x20>
  8009ec:	38 ca                	cmp    %cl,%dl
  8009ee:	74 07                	je     8009f7 <strfind+0x20>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  8009f0:	40                   	inc    %eax
  8009f1:	8a 10                	mov    (%eax),%dl
  8009f3:	84 d2                	test   %dl,%dl
  8009f5:	75 f5                	jne    8009ec <strfind+0x15>
		if (*s == c)
			break;
	return (char *) s;
}
  8009f7:	c9                   	leave  
  8009f8:	c3                   	ret    

008009f9 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8009f9:	55                   	push   %ebp
  8009fa:	89 e5                	mov    %esp,%ebp
  8009fc:	57                   	push   %edi
  8009fd:	56                   	push   %esi
  8009fe:	53                   	push   %ebx
  8009ff:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a02:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a05:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800a08:	85 c9                	test   %ecx,%ecx
  800a0a:	74 30                	je     800a3c <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a0c:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a12:	75 25                	jne    800a39 <memset+0x40>
  800a14:	f6 c1 03             	test   $0x3,%cl
  800a17:	75 20                	jne    800a39 <memset+0x40>
		c &= 0xFF;
  800a19:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a1c:	89 d3                	mov    %edx,%ebx
  800a1e:	c1 e3 08             	shl    $0x8,%ebx
  800a21:	89 d6                	mov    %edx,%esi
  800a23:	c1 e6 18             	shl    $0x18,%esi
  800a26:	89 d0                	mov    %edx,%eax
  800a28:	c1 e0 10             	shl    $0x10,%eax
  800a2b:	09 f0                	or     %esi,%eax
  800a2d:	09 d0                	or     %edx,%eax
  800a2f:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800a31:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800a34:	fc                   	cld    
  800a35:	f3 ab                	rep stos %eax,%es:(%edi)
  800a37:	eb 03                	jmp    800a3c <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a39:	fc                   	cld    
  800a3a:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a3c:	89 f8                	mov    %edi,%eax
  800a3e:	5b                   	pop    %ebx
  800a3f:	5e                   	pop    %esi
  800a40:	5f                   	pop    %edi
  800a41:	c9                   	leave  
  800a42:	c3                   	ret    

00800a43 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a43:	55                   	push   %ebp
  800a44:	89 e5                	mov    %esp,%ebp
  800a46:	57                   	push   %edi
  800a47:	56                   	push   %esi
  800a48:	8b 45 08             	mov    0x8(%ebp),%eax
  800a4b:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a4e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a51:	39 c6                	cmp    %eax,%esi
  800a53:	73 34                	jae    800a89 <memmove+0x46>
  800a55:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a58:	39 d0                	cmp    %edx,%eax
  800a5a:	73 2d                	jae    800a89 <memmove+0x46>
		s += n;
		d += n;
  800a5c:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a5f:	f6 c2 03             	test   $0x3,%dl
  800a62:	75 1b                	jne    800a7f <memmove+0x3c>
  800a64:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a6a:	75 13                	jne    800a7f <memmove+0x3c>
  800a6c:	f6 c1 03             	test   $0x3,%cl
  800a6f:	75 0e                	jne    800a7f <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800a71:	83 ef 04             	sub    $0x4,%edi
  800a74:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a77:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800a7a:	fd                   	std    
  800a7b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a7d:	eb 07                	jmp    800a86 <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800a7f:	4f                   	dec    %edi
  800a80:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800a83:	fd                   	std    
  800a84:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a86:	fc                   	cld    
  800a87:	eb 20                	jmp    800aa9 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a89:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a8f:	75 13                	jne    800aa4 <memmove+0x61>
  800a91:	a8 03                	test   $0x3,%al
  800a93:	75 0f                	jne    800aa4 <memmove+0x61>
  800a95:	f6 c1 03             	test   $0x3,%cl
  800a98:	75 0a                	jne    800aa4 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800a9a:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800a9d:	89 c7                	mov    %eax,%edi
  800a9f:	fc                   	cld    
  800aa0:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800aa2:	eb 05                	jmp    800aa9 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800aa4:	89 c7                	mov    %eax,%edi
  800aa6:	fc                   	cld    
  800aa7:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800aa9:	5e                   	pop    %esi
  800aaa:	5f                   	pop    %edi
  800aab:	c9                   	leave  
  800aac:	c3                   	ret    

00800aad <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800aad:	55                   	push   %ebp
  800aae:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800ab0:	ff 75 10             	pushl  0x10(%ebp)
  800ab3:	ff 75 0c             	pushl  0xc(%ebp)
  800ab6:	ff 75 08             	pushl  0x8(%ebp)
  800ab9:	e8 85 ff ff ff       	call   800a43 <memmove>
}
  800abe:	c9                   	leave  
  800abf:	c3                   	ret    

00800ac0 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800ac0:	55                   	push   %ebp
  800ac1:	89 e5                	mov    %esp,%ebp
  800ac3:	57                   	push   %edi
  800ac4:	56                   	push   %esi
  800ac5:	53                   	push   %ebx
  800ac6:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800ac9:	8b 75 0c             	mov    0xc(%ebp),%esi
  800acc:	8b 7d 10             	mov    0x10(%ebp),%edi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800acf:	85 ff                	test   %edi,%edi
  800ad1:	74 32                	je     800b05 <memcmp+0x45>
		if (*s1 != *s2)
  800ad3:	8a 03                	mov    (%ebx),%al
  800ad5:	8a 0e                	mov    (%esi),%cl
  800ad7:	38 c8                	cmp    %cl,%al
  800ad9:	74 19                	je     800af4 <memcmp+0x34>
  800adb:	eb 0d                	jmp    800aea <memcmp+0x2a>
  800add:	8a 44 13 01          	mov    0x1(%ebx,%edx,1),%al
  800ae1:	8a 4c 16 01          	mov    0x1(%esi,%edx,1),%cl
  800ae5:	42                   	inc    %edx
  800ae6:	38 c8                	cmp    %cl,%al
  800ae8:	74 10                	je     800afa <memcmp+0x3a>
			return (int) *s1 - (int) *s2;
  800aea:	0f b6 c0             	movzbl %al,%eax
  800aed:	0f b6 c9             	movzbl %cl,%ecx
  800af0:	29 c8                	sub    %ecx,%eax
  800af2:	eb 16                	jmp    800b0a <memcmp+0x4a>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800af4:	4f                   	dec    %edi
  800af5:	ba 00 00 00 00       	mov    $0x0,%edx
  800afa:	39 fa                	cmp    %edi,%edx
  800afc:	75 df                	jne    800add <memcmp+0x1d>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800afe:	b8 00 00 00 00       	mov    $0x0,%eax
  800b03:	eb 05                	jmp    800b0a <memcmp+0x4a>
  800b05:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b0a:	5b                   	pop    %ebx
  800b0b:	5e                   	pop    %esi
  800b0c:	5f                   	pop    %edi
  800b0d:	c9                   	leave  
  800b0e:	c3                   	ret    

00800b0f <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b0f:	55                   	push   %ebp
  800b10:	89 e5                	mov    %esp,%ebp
  800b12:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800b15:	89 c2                	mov    %eax,%edx
  800b17:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800b1a:	39 d0                	cmp    %edx,%eax
  800b1c:	73 12                	jae    800b30 <memfind+0x21>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b1e:	8a 4d 0c             	mov    0xc(%ebp),%cl
  800b21:	38 08                	cmp    %cl,(%eax)
  800b23:	75 06                	jne    800b2b <memfind+0x1c>
  800b25:	eb 09                	jmp    800b30 <memfind+0x21>
  800b27:	38 08                	cmp    %cl,(%eax)
  800b29:	74 05                	je     800b30 <memfind+0x21>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800b2b:	40                   	inc    %eax
  800b2c:	39 c2                	cmp    %eax,%edx
  800b2e:	77 f7                	ja     800b27 <memfind+0x18>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800b30:	c9                   	leave  
  800b31:	c3                   	ret    

00800b32 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b32:	55                   	push   %ebp
  800b33:	89 e5                	mov    %esp,%ebp
  800b35:	57                   	push   %edi
  800b36:	56                   	push   %esi
  800b37:	53                   	push   %ebx
  800b38:	8b 55 08             	mov    0x8(%ebp),%edx
  800b3b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b3e:	eb 01                	jmp    800b41 <strtol+0xf>
		s++;
  800b40:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b41:	8a 02                	mov    (%edx),%al
  800b43:	3c 20                	cmp    $0x20,%al
  800b45:	74 f9                	je     800b40 <strtol+0xe>
  800b47:	3c 09                	cmp    $0x9,%al
  800b49:	74 f5                	je     800b40 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800b4b:	3c 2b                	cmp    $0x2b,%al
  800b4d:	75 08                	jne    800b57 <strtol+0x25>
		s++;
  800b4f:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800b50:	bf 00 00 00 00       	mov    $0x0,%edi
  800b55:	eb 13                	jmp    800b6a <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800b57:	3c 2d                	cmp    $0x2d,%al
  800b59:	75 0a                	jne    800b65 <strtol+0x33>
		s++, neg = 1;
  800b5b:	8d 52 01             	lea    0x1(%edx),%edx
  800b5e:	bf 01 00 00 00       	mov    $0x1,%edi
  800b63:	eb 05                	jmp    800b6a <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800b65:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b6a:	85 db                	test   %ebx,%ebx
  800b6c:	74 05                	je     800b73 <strtol+0x41>
  800b6e:	83 fb 10             	cmp    $0x10,%ebx
  800b71:	75 28                	jne    800b9b <strtol+0x69>
  800b73:	8a 02                	mov    (%edx),%al
  800b75:	3c 30                	cmp    $0x30,%al
  800b77:	75 10                	jne    800b89 <strtol+0x57>
  800b79:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800b7d:	75 0a                	jne    800b89 <strtol+0x57>
		s += 2, base = 16;
  800b7f:	83 c2 02             	add    $0x2,%edx
  800b82:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b87:	eb 12                	jmp    800b9b <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800b89:	85 db                	test   %ebx,%ebx
  800b8b:	75 0e                	jne    800b9b <strtol+0x69>
  800b8d:	3c 30                	cmp    $0x30,%al
  800b8f:	75 05                	jne    800b96 <strtol+0x64>
		s++, base = 8;
  800b91:	42                   	inc    %edx
  800b92:	b3 08                	mov    $0x8,%bl
  800b94:	eb 05                	jmp    800b9b <strtol+0x69>
	else if (base == 0)
		base = 10;
  800b96:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800b9b:	b8 00 00 00 00       	mov    $0x0,%eax
  800ba0:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800ba2:	8a 0a                	mov    (%edx),%cl
  800ba4:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800ba7:	80 fb 09             	cmp    $0x9,%bl
  800baa:	77 08                	ja     800bb4 <strtol+0x82>
			dig = *s - '0';
  800bac:	0f be c9             	movsbl %cl,%ecx
  800baf:	83 e9 30             	sub    $0x30,%ecx
  800bb2:	eb 1e                	jmp    800bd2 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800bb4:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800bb7:	80 fb 19             	cmp    $0x19,%bl
  800bba:	77 08                	ja     800bc4 <strtol+0x92>
			dig = *s - 'a' + 10;
  800bbc:	0f be c9             	movsbl %cl,%ecx
  800bbf:	83 e9 57             	sub    $0x57,%ecx
  800bc2:	eb 0e                	jmp    800bd2 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800bc4:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800bc7:	80 fb 19             	cmp    $0x19,%bl
  800bca:	77 13                	ja     800bdf <strtol+0xad>
			dig = *s - 'A' + 10;
  800bcc:	0f be c9             	movsbl %cl,%ecx
  800bcf:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800bd2:	39 f1                	cmp    %esi,%ecx
  800bd4:	7d 0d                	jge    800be3 <strtol+0xb1>
			break;
		s++, val = (val * base) + dig;
  800bd6:	42                   	inc    %edx
  800bd7:	0f af c6             	imul   %esi,%eax
  800bda:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  800bdd:	eb c3                	jmp    800ba2 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800bdf:	89 c1                	mov    %eax,%ecx
  800be1:	eb 02                	jmp    800be5 <strtol+0xb3>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800be3:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800be5:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800be9:	74 05                	je     800bf0 <strtol+0xbe>
		*endptr = (char *) s;
  800beb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800bee:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800bf0:	85 ff                	test   %edi,%edi
  800bf2:	74 04                	je     800bf8 <strtol+0xc6>
  800bf4:	89 c8                	mov    %ecx,%eax
  800bf6:	f7 d8                	neg    %eax
}
  800bf8:	5b                   	pop    %ebx
  800bf9:	5e                   	pop    %esi
  800bfa:	5f                   	pop    %edi
  800bfb:	c9                   	leave  
  800bfc:	c3                   	ret    
  800bfd:	00 00                	add    %al,(%eax)
	...

00800c00 <syscall>:
	return ret;
}

static int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800c00:	55                   	push   %ebp
  800c01:	89 e5                	mov    %esp,%ebp
  800c03:	57                   	push   %edi
  800c04:	56                   	push   %esi
  800c05:	53                   	push   %ebx
  800c06:	83 ec 1c             	sub    $0x1c,%esp
  800c09:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800c0c:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800c0f:	89 ca                	mov    %ecx,%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c11:	8b 75 14             	mov    0x14(%ebp),%esi
  800c14:	8b 7d 10             	mov    0x10(%ebp),%edi
  800c17:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800c1a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c1d:	cd 30                	int    $0x30
  800c1f:	89 c2                	mov    %eax,%edx
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c21:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800c25:	74 1c                	je     800c43 <syscall+0x43>
  800c27:	85 c0                	test   %eax,%eax
  800c29:	7e 18                	jle    800c43 <syscall+0x43>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c2b:	83 ec 0c             	sub    $0xc,%esp
  800c2e:	50                   	push   %eax
  800c2f:	ff 75 e4             	pushl  -0x1c(%ebp)
  800c32:	68 7f 23 80 00       	push   $0x80237f
  800c37:	6a 42                	push   $0x42
  800c39:	68 9c 23 80 00       	push   $0x80239c
  800c3e:	e8 b1 f5 ff ff       	call   8001f4 <_panic>

	return ret;
}
  800c43:	89 d0                	mov    %edx,%eax
  800c45:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c48:	5b                   	pop    %ebx
  800c49:	5e                   	pop    %esi
  800c4a:	5f                   	pop    %edi
  800c4b:	c9                   	leave  
  800c4c:	c3                   	ret    

00800c4d <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{	
  800c4d:	55                   	push   %ebp
  800c4e:	89 e5                	mov    %esp,%ebp
  800c50:	83 ec 08             	sub    $0x8,%esp
	// my_sysenter(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
	// return;
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  800c53:	6a 00                	push   $0x0
  800c55:	6a 00                	push   $0x0
  800c57:	6a 00                	push   $0x0
  800c59:	ff 75 0c             	pushl  0xc(%ebp)
  800c5c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c5f:	ba 00 00 00 00       	mov    $0x0,%edx
  800c64:	b8 00 00 00 00       	mov    $0x0,%eax
  800c69:	e8 92 ff ff ff       	call   800c00 <syscall>
  800c6e:	83 c4 10             	add    $0x10,%esp
	return;
}
  800c71:	c9                   	leave  
  800c72:	c3                   	ret    

00800c73 <sys_cgetc>:

int
sys_cgetc(void)
{
  800c73:	55                   	push   %ebp
  800c74:	89 e5                	mov    %esp,%ebp
  800c76:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_cgetc, 0, 0, 0, 0, 0, 0);
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  800c79:	6a 00                	push   $0x0
  800c7b:	6a 00                	push   $0x0
  800c7d:	6a 00                	push   $0x0
  800c7f:	6a 00                	push   $0x0
  800c81:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c86:	ba 00 00 00 00       	mov    $0x0,%edx
  800c8b:	b8 01 00 00 00       	mov    $0x1,%eax
  800c90:	e8 6b ff ff ff       	call   800c00 <syscall>
}
  800c95:	c9                   	leave  
  800c96:	c3                   	ret    

00800c97 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800c97:	55                   	push   %ebp
  800c98:	89 e5                	mov    %esp,%ebp
  800c9a:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  800c9d:	6a 00                	push   $0x0
  800c9f:	6a 00                	push   $0x0
  800ca1:	6a 00                	push   $0x0
  800ca3:	6a 00                	push   $0x0
  800ca5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ca8:	ba 01 00 00 00       	mov    $0x1,%edx
  800cad:	b8 03 00 00 00       	mov    $0x3,%eax
  800cb2:	e8 49 ff ff ff       	call   800c00 <syscall>
}
  800cb7:	c9                   	leave  
  800cb8:	c3                   	ret    

00800cb9 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800cb9:	55                   	push   %ebp
  800cba:	89 e5                	mov    %esp,%ebp
  800cbc:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_getenvid, 0, 0, 0, 0, 0, 0);
	return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  800cbf:	6a 00                	push   $0x0
  800cc1:	6a 00                	push   $0x0
  800cc3:	6a 00                	push   $0x0
  800cc5:	6a 00                	push   $0x0
  800cc7:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ccc:	ba 00 00 00 00       	mov    $0x0,%edx
  800cd1:	b8 02 00 00 00       	mov    $0x2,%eax
  800cd6:	e8 25 ff ff ff       	call   800c00 <syscall>
}
  800cdb:	c9                   	leave  
  800cdc:	c3                   	ret    

00800cdd <sys_yield>:

void
sys_yield(void)
{
  800cdd:	55                   	push   %ebp
  800cde:	89 e5                	mov    %esp,%ebp
  800ce0:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  800ce3:	6a 00                	push   $0x0
  800ce5:	6a 00                	push   $0x0
  800ce7:	6a 00                	push   $0x0
  800ce9:	6a 00                	push   $0x0
  800ceb:	b9 00 00 00 00       	mov    $0x0,%ecx
  800cf0:	ba 00 00 00 00       	mov    $0x0,%edx
  800cf5:	b8 0b 00 00 00       	mov    $0xb,%eax
  800cfa:	e8 01 ff ff ff       	call   800c00 <syscall>
  800cff:	83 c4 10             	add    $0x10,%esp
}
  800d02:	c9                   	leave  
  800d03:	c3                   	ret    

00800d04 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800d04:	55                   	push   %ebp
  800d05:	89 e5                	mov    %esp,%ebp
  800d07:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  800d0a:	6a 00                	push   $0x0
  800d0c:	6a 00                	push   $0x0
  800d0e:	ff 75 10             	pushl  0x10(%ebp)
  800d11:	ff 75 0c             	pushl  0xc(%ebp)
  800d14:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d17:	ba 01 00 00 00       	mov    $0x1,%edx
  800d1c:	b8 04 00 00 00       	mov    $0x4,%eax
  800d21:	e8 da fe ff ff       	call   800c00 <syscall>
}
  800d26:	c9                   	leave  
  800d27:	c3                   	ret    

00800d28 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800d28:	55                   	push   %ebp
  800d29:	89 e5                	mov    %esp,%ebp
  800d2b:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
  800d2e:	ff 75 18             	pushl  0x18(%ebp)
  800d31:	ff 75 14             	pushl  0x14(%ebp)
  800d34:	ff 75 10             	pushl  0x10(%ebp)
  800d37:	ff 75 0c             	pushl  0xc(%ebp)
  800d3a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d3d:	ba 01 00 00 00       	mov    $0x1,%edx
  800d42:	b8 05 00 00 00       	mov    $0x5,%eax
  800d47:	e8 b4 fe ff ff       	call   800c00 <syscall>
}
  800d4c:	c9                   	leave  
  800d4d:	c3                   	ret    

00800d4e <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800d4e:	55                   	push   %ebp
  800d4f:	89 e5                	mov    %esp,%ebp
  800d51:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  800d54:	6a 00                	push   $0x0
  800d56:	6a 00                	push   $0x0
  800d58:	6a 00                	push   $0x0
  800d5a:	ff 75 0c             	pushl  0xc(%ebp)
  800d5d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d60:	ba 01 00 00 00       	mov    $0x1,%edx
  800d65:	b8 06 00 00 00       	mov    $0x6,%eax
  800d6a:	e8 91 fe ff ff       	call   800c00 <syscall>
}
  800d6f:	c9                   	leave  
  800d70:	c3                   	ret    

00800d71 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800d71:	55                   	push   %ebp
  800d72:	89 e5                	mov    %esp,%ebp
  800d74:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  800d77:	6a 00                	push   $0x0
  800d79:	6a 00                	push   $0x0
  800d7b:	6a 00                	push   $0x0
  800d7d:	ff 75 0c             	pushl  0xc(%ebp)
  800d80:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d83:	ba 01 00 00 00       	mov    $0x1,%edx
  800d88:	b8 08 00 00 00       	mov    $0x8,%eax
  800d8d:	e8 6e fe ff ff       	call   800c00 <syscall>
}
  800d92:	c9                   	leave  
  800d93:	c3                   	ret    

00800d94 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800d94:	55                   	push   %ebp
  800d95:	89 e5                	mov    %esp,%ebp
  800d97:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
  800d9a:	6a 00                	push   $0x0
  800d9c:	6a 00                	push   $0x0
  800d9e:	6a 00                	push   $0x0
  800da0:	ff 75 0c             	pushl  0xc(%ebp)
  800da3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800da6:	ba 01 00 00 00       	mov    $0x1,%edx
  800dab:	b8 09 00 00 00       	mov    $0x9,%eax
  800db0:	e8 4b fe ff ff       	call   800c00 <syscall>
}
  800db5:	c9                   	leave  
  800db6:	c3                   	ret    

00800db7 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800db7:	55                   	push   %ebp
  800db8:	89 e5                	mov    %esp,%ebp
  800dba:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  800dbd:	6a 00                	push   $0x0
  800dbf:	6a 00                	push   $0x0
  800dc1:	6a 00                	push   $0x0
  800dc3:	ff 75 0c             	pushl  0xc(%ebp)
  800dc6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800dc9:	ba 01 00 00 00       	mov    $0x1,%edx
  800dce:	b8 0a 00 00 00       	mov    $0xa,%eax
  800dd3:	e8 28 fe ff ff       	call   800c00 <syscall>
}
  800dd8:	c9                   	leave  
  800dd9:	c3                   	ret    

00800dda <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800dda:	55                   	push   %ebp
  800ddb:	89 e5                	mov    %esp,%ebp
  800ddd:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  800de0:	6a 00                	push   $0x0
  800de2:	ff 75 14             	pushl  0x14(%ebp)
  800de5:	ff 75 10             	pushl  0x10(%ebp)
  800de8:	ff 75 0c             	pushl  0xc(%ebp)
  800deb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800dee:	ba 00 00 00 00       	mov    $0x0,%edx
  800df3:	b8 0c 00 00 00       	mov    $0xc,%eax
  800df8:	e8 03 fe ff ff       	call   800c00 <syscall>
}
  800dfd:	c9                   	leave  
  800dfe:	c3                   	ret    

00800dff <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800dff:	55                   	push   %ebp
  800e00:	89 e5                	mov    %esp,%ebp
  800e02:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  800e05:	6a 00                	push   $0x0
  800e07:	6a 00                	push   $0x0
  800e09:	6a 00                	push   $0x0
  800e0b:	6a 00                	push   $0x0
  800e0d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e10:	ba 01 00 00 00       	mov    $0x1,%edx
  800e15:	b8 0d 00 00 00       	mov    $0xd,%eax
  800e1a:	e8 e1 fd ff ff       	call   800c00 <syscall>
}
  800e1f:	c9                   	leave  
  800e20:	c3                   	ret    

00800e21 <sys_set_priority>:

int
sys_set_priority(envid_t envid, uint32_t new_priority)
{
  800e21:	55                   	push   %ebp
  800e22:	89 e5                	mov    %esp,%ebp
  800e24:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_set_priority, 0, envid, new_priority, 0, 0, 0);
  800e27:	6a 00                	push   $0x0
  800e29:	6a 00                	push   $0x0
  800e2b:	6a 00                	push   $0x0
  800e2d:	ff 75 0c             	pushl  0xc(%ebp)
  800e30:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e33:	ba 00 00 00 00       	mov    $0x0,%edx
  800e38:	b8 0e 00 00 00       	mov    $0xe,%eax
  800e3d:	e8 be fd ff ff       	call   800c00 <syscall>
}
  800e42:	c9                   	leave  
  800e43:	c3                   	ret    

00800e44 <sys_exec>:

int
sys_exec(uint32_t eip, uint32_t esp, void * ph, uint32_t elf_phnum)
{
  800e44:	55                   	push   %ebp
  800e45:	89 e5                	mov    %esp,%ebp
  800e47:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_exec, 0, eip, esp, (uint32_t)ph, elf_phnum, 0);
  800e4a:	6a 00                	push   $0x0
  800e4c:	ff 75 14             	pushl  0x14(%ebp)
  800e4f:	ff 75 10             	pushl  0x10(%ebp)
  800e52:	ff 75 0c             	pushl  0xc(%ebp)
  800e55:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e58:	ba 00 00 00 00       	mov    $0x0,%edx
  800e5d:	b8 0f 00 00 00       	mov    $0xf,%eax
  800e62:	e8 99 fd ff ff       	call   800c00 <syscall>
  800e67:	c9                   	leave  
  800e68:	c3                   	ret    
  800e69:	00 00                	add    %al,(%eax)
	...

00800e6c <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800e6c:	55                   	push   %ebp
  800e6d:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800e6f:	8b 45 08             	mov    0x8(%ebp),%eax
  800e72:	05 00 00 00 30       	add    $0x30000000,%eax
  800e77:	c1 e8 0c             	shr    $0xc,%eax
}
  800e7a:	c9                   	leave  
  800e7b:	c3                   	ret    

00800e7c <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800e7c:	55                   	push   %ebp
  800e7d:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800e7f:	ff 75 08             	pushl  0x8(%ebp)
  800e82:	e8 e5 ff ff ff       	call   800e6c <fd2num>
  800e87:	83 c4 04             	add    $0x4,%esp
  800e8a:	05 20 00 0d 00       	add    $0xd0020,%eax
  800e8f:	c1 e0 0c             	shl    $0xc,%eax
}
  800e92:	c9                   	leave  
  800e93:	c3                   	ret    

00800e94 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800e94:	55                   	push   %ebp
  800e95:	89 e5                	mov    %esp,%ebp
  800e97:	53                   	push   %ebx
  800e98:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800e9b:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  800ea0:	a8 01                	test   $0x1,%al
  800ea2:	74 34                	je     800ed8 <fd_alloc+0x44>
  800ea4:	a1 00 00 74 ef       	mov    0xef740000,%eax
  800ea9:	a8 01                	test   $0x1,%al
  800eab:	74 32                	je     800edf <fd_alloc+0x4b>
  800ead:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
  800eb2:	89 c1                	mov    %eax,%ecx
  800eb4:	89 c2                	mov    %eax,%edx
  800eb6:	c1 ea 16             	shr    $0x16,%edx
  800eb9:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800ec0:	f6 c2 01             	test   $0x1,%dl
  800ec3:	74 1f                	je     800ee4 <fd_alloc+0x50>
  800ec5:	89 c2                	mov    %eax,%edx
  800ec7:	c1 ea 0c             	shr    $0xc,%edx
  800eca:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800ed1:	f6 c2 01             	test   $0x1,%dl
  800ed4:	75 17                	jne    800eed <fd_alloc+0x59>
  800ed6:	eb 0c                	jmp    800ee4 <fd_alloc+0x50>
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  800ed8:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
  800edd:	eb 05                	jmp    800ee4 <fd_alloc+0x50>
  800edf:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
  800ee4:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  800ee6:	b8 00 00 00 00       	mov    $0x0,%eax
  800eeb:	eb 17                	jmp    800f04 <fd_alloc+0x70>
  800eed:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800ef2:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800ef7:	75 b9                	jne    800eb2 <fd_alloc+0x1e>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800ef9:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  800eff:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800f04:	5b                   	pop    %ebx
  800f05:	c9                   	leave  
  800f06:	c3                   	ret    

00800f07 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800f07:	55                   	push   %ebp
  800f08:	89 e5                	mov    %esp,%ebp
  800f0a:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800f0d:	83 f8 1f             	cmp    $0x1f,%eax
  800f10:	77 36                	ja     800f48 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800f12:	05 00 00 0d 00       	add    $0xd0000,%eax
  800f17:	c1 e0 0c             	shl    $0xc,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800f1a:	89 c2                	mov    %eax,%edx
  800f1c:	c1 ea 16             	shr    $0x16,%edx
  800f1f:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800f26:	f6 c2 01             	test   $0x1,%dl
  800f29:	74 24                	je     800f4f <fd_lookup+0x48>
  800f2b:	89 c2                	mov    %eax,%edx
  800f2d:	c1 ea 0c             	shr    $0xc,%edx
  800f30:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800f37:	f6 c2 01             	test   $0x1,%dl
  800f3a:	74 1a                	je     800f56 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800f3c:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f3f:	89 02                	mov    %eax,(%edx)
	return 0;
  800f41:	b8 00 00 00 00       	mov    $0x0,%eax
  800f46:	eb 13                	jmp    800f5b <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800f48:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f4d:	eb 0c                	jmp    800f5b <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800f4f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f54:	eb 05                	jmp    800f5b <fd_lookup+0x54>
  800f56:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800f5b:	c9                   	leave  
  800f5c:	c3                   	ret    

00800f5d <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800f5d:	55                   	push   %ebp
  800f5e:	89 e5                	mov    %esp,%ebp
  800f60:	53                   	push   %ebx
  800f61:	83 ec 04             	sub    $0x4,%esp
  800f64:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f67:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  800f6a:	39 0d 08 30 80 00    	cmp    %ecx,0x803008
  800f70:	74 0d                	je     800f7f <dev_lookup+0x22>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800f72:	b8 00 00 00 00       	mov    $0x0,%eax
  800f77:	eb 14                	jmp    800f8d <dev_lookup+0x30>
		if (devtab[i]->dev_id == dev_id) {
  800f79:	39 0a                	cmp    %ecx,(%edx)
  800f7b:	75 10                	jne    800f8d <dev_lookup+0x30>
  800f7d:	eb 05                	jmp    800f84 <dev_lookup+0x27>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800f7f:	ba 08 30 80 00       	mov    $0x803008,%edx
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
  800f84:	89 13                	mov    %edx,(%ebx)
			return 0;
  800f86:	b8 00 00 00 00       	mov    $0x0,%eax
  800f8b:	eb 31                	jmp    800fbe <dev_lookup+0x61>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800f8d:	40                   	inc    %eax
  800f8e:	8b 14 85 2c 24 80 00 	mov    0x80242c(,%eax,4),%edx
  800f95:	85 d2                	test   %edx,%edx
  800f97:	75 e0                	jne    800f79 <dev_lookup+0x1c>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800f99:	a1 08 40 80 00       	mov    0x804008,%eax
  800f9e:	8b 40 48             	mov    0x48(%eax),%eax
  800fa1:	83 ec 04             	sub    $0x4,%esp
  800fa4:	51                   	push   %ecx
  800fa5:	50                   	push   %eax
  800fa6:	68 ac 23 80 00       	push   $0x8023ac
  800fab:	e8 1c f3 ff ff       	call   8002cc <cprintf>
	*dev = 0;
  800fb0:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  800fb6:	83 c4 10             	add    $0x10,%esp
  800fb9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800fbe:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800fc1:	c9                   	leave  
  800fc2:	c3                   	ret    

00800fc3 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800fc3:	55                   	push   %ebp
  800fc4:	89 e5                	mov    %esp,%ebp
  800fc6:	56                   	push   %esi
  800fc7:	53                   	push   %ebx
  800fc8:	83 ec 20             	sub    $0x20,%esp
  800fcb:	8b 75 08             	mov    0x8(%ebp),%esi
  800fce:	8a 45 0c             	mov    0xc(%ebp),%al
  800fd1:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800fd4:	56                   	push   %esi
  800fd5:	e8 92 fe ff ff       	call   800e6c <fd2num>
  800fda:	8d 55 f4             	lea    -0xc(%ebp),%edx
  800fdd:	89 14 24             	mov    %edx,(%esp)
  800fe0:	50                   	push   %eax
  800fe1:	e8 21 ff ff ff       	call   800f07 <fd_lookup>
  800fe6:	89 c3                	mov    %eax,%ebx
  800fe8:	83 c4 08             	add    $0x8,%esp
  800feb:	85 c0                	test   %eax,%eax
  800fed:	78 05                	js     800ff4 <fd_close+0x31>
	    || fd != fd2)
  800fef:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800ff2:	74 0d                	je     801001 <fd_close+0x3e>
		return (must_exist ? r : 0);
  800ff4:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  800ff8:	75 48                	jne    801042 <fd_close+0x7f>
  800ffa:	bb 00 00 00 00       	mov    $0x0,%ebx
  800fff:	eb 41                	jmp    801042 <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801001:	83 ec 08             	sub    $0x8,%esp
  801004:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801007:	50                   	push   %eax
  801008:	ff 36                	pushl  (%esi)
  80100a:	e8 4e ff ff ff       	call   800f5d <dev_lookup>
  80100f:	89 c3                	mov    %eax,%ebx
  801011:	83 c4 10             	add    $0x10,%esp
  801014:	85 c0                	test   %eax,%eax
  801016:	78 1c                	js     801034 <fd_close+0x71>
		if (dev->dev_close)
  801018:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80101b:	8b 40 10             	mov    0x10(%eax),%eax
  80101e:	85 c0                	test   %eax,%eax
  801020:	74 0d                	je     80102f <fd_close+0x6c>
			r = (*dev->dev_close)(fd);
  801022:	83 ec 0c             	sub    $0xc,%esp
  801025:	56                   	push   %esi
  801026:	ff d0                	call   *%eax
  801028:	89 c3                	mov    %eax,%ebx
  80102a:	83 c4 10             	add    $0x10,%esp
  80102d:	eb 05                	jmp    801034 <fd_close+0x71>
		else
			r = 0;
  80102f:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801034:	83 ec 08             	sub    $0x8,%esp
  801037:	56                   	push   %esi
  801038:	6a 00                	push   $0x0
  80103a:	e8 0f fd ff ff       	call   800d4e <sys_page_unmap>
	return r;
  80103f:	83 c4 10             	add    $0x10,%esp
}
  801042:	89 d8                	mov    %ebx,%eax
  801044:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801047:	5b                   	pop    %ebx
  801048:	5e                   	pop    %esi
  801049:	c9                   	leave  
  80104a:	c3                   	ret    

0080104b <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80104b:	55                   	push   %ebp
  80104c:	89 e5                	mov    %esp,%ebp
  80104e:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801051:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801054:	50                   	push   %eax
  801055:	ff 75 08             	pushl  0x8(%ebp)
  801058:	e8 aa fe ff ff       	call   800f07 <fd_lookup>
  80105d:	83 c4 08             	add    $0x8,%esp
  801060:	85 c0                	test   %eax,%eax
  801062:	78 10                	js     801074 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801064:	83 ec 08             	sub    $0x8,%esp
  801067:	6a 01                	push   $0x1
  801069:	ff 75 f4             	pushl  -0xc(%ebp)
  80106c:	e8 52 ff ff ff       	call   800fc3 <fd_close>
  801071:	83 c4 10             	add    $0x10,%esp
}
  801074:	c9                   	leave  
  801075:	c3                   	ret    

00801076 <close_all>:

void
close_all(void)
{
  801076:	55                   	push   %ebp
  801077:	89 e5                	mov    %esp,%ebp
  801079:	53                   	push   %ebx
  80107a:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80107d:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801082:	83 ec 0c             	sub    $0xc,%esp
  801085:	53                   	push   %ebx
  801086:	e8 c0 ff ff ff       	call   80104b <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80108b:	43                   	inc    %ebx
  80108c:	83 c4 10             	add    $0x10,%esp
  80108f:	83 fb 20             	cmp    $0x20,%ebx
  801092:	75 ee                	jne    801082 <close_all+0xc>
		close(i);
}
  801094:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801097:	c9                   	leave  
  801098:	c3                   	ret    

00801099 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801099:	55                   	push   %ebp
  80109a:	89 e5                	mov    %esp,%ebp
  80109c:	57                   	push   %edi
  80109d:	56                   	push   %esi
  80109e:	53                   	push   %ebx
  80109f:	83 ec 2c             	sub    $0x2c,%esp
  8010a2:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8010a5:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8010a8:	50                   	push   %eax
  8010a9:	ff 75 08             	pushl  0x8(%ebp)
  8010ac:	e8 56 fe ff ff       	call   800f07 <fd_lookup>
  8010b1:	89 c3                	mov    %eax,%ebx
  8010b3:	83 c4 08             	add    $0x8,%esp
  8010b6:	85 c0                	test   %eax,%eax
  8010b8:	0f 88 c0 00 00 00    	js     80117e <dup+0xe5>
		return r;
	close(newfdnum);
  8010be:	83 ec 0c             	sub    $0xc,%esp
  8010c1:	57                   	push   %edi
  8010c2:	e8 84 ff ff ff       	call   80104b <close>

	newfd = INDEX2FD(newfdnum);
  8010c7:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  8010cd:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  8010d0:	83 c4 04             	add    $0x4,%esp
  8010d3:	ff 75 e4             	pushl  -0x1c(%ebp)
  8010d6:	e8 a1 fd ff ff       	call   800e7c <fd2data>
  8010db:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  8010dd:	89 34 24             	mov    %esi,(%esp)
  8010e0:	e8 97 fd ff ff       	call   800e7c <fd2data>
  8010e5:	83 c4 10             	add    $0x10,%esp
  8010e8:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8010eb:	89 d8                	mov    %ebx,%eax
  8010ed:	c1 e8 16             	shr    $0x16,%eax
  8010f0:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8010f7:	a8 01                	test   $0x1,%al
  8010f9:	74 37                	je     801132 <dup+0x99>
  8010fb:	89 d8                	mov    %ebx,%eax
  8010fd:	c1 e8 0c             	shr    $0xc,%eax
  801100:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801107:	f6 c2 01             	test   $0x1,%dl
  80110a:	74 26                	je     801132 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80110c:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801113:	83 ec 0c             	sub    $0xc,%esp
  801116:	25 07 0e 00 00       	and    $0xe07,%eax
  80111b:	50                   	push   %eax
  80111c:	ff 75 d4             	pushl  -0x2c(%ebp)
  80111f:	6a 00                	push   $0x0
  801121:	53                   	push   %ebx
  801122:	6a 00                	push   $0x0
  801124:	e8 ff fb ff ff       	call   800d28 <sys_page_map>
  801129:	89 c3                	mov    %eax,%ebx
  80112b:	83 c4 20             	add    $0x20,%esp
  80112e:	85 c0                	test   %eax,%eax
  801130:	78 2d                	js     80115f <dup+0xc6>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801132:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801135:	89 c2                	mov    %eax,%edx
  801137:	c1 ea 0c             	shr    $0xc,%edx
  80113a:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801141:	83 ec 0c             	sub    $0xc,%esp
  801144:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  80114a:	52                   	push   %edx
  80114b:	56                   	push   %esi
  80114c:	6a 00                	push   $0x0
  80114e:	50                   	push   %eax
  80114f:	6a 00                	push   $0x0
  801151:	e8 d2 fb ff ff       	call   800d28 <sys_page_map>
  801156:	89 c3                	mov    %eax,%ebx
  801158:	83 c4 20             	add    $0x20,%esp
  80115b:	85 c0                	test   %eax,%eax
  80115d:	79 1d                	jns    80117c <dup+0xe3>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80115f:	83 ec 08             	sub    $0x8,%esp
  801162:	56                   	push   %esi
  801163:	6a 00                	push   $0x0
  801165:	e8 e4 fb ff ff       	call   800d4e <sys_page_unmap>
	sys_page_unmap(0, nva);
  80116a:	83 c4 08             	add    $0x8,%esp
  80116d:	ff 75 d4             	pushl  -0x2c(%ebp)
  801170:	6a 00                	push   $0x0
  801172:	e8 d7 fb ff ff       	call   800d4e <sys_page_unmap>
	return r;
  801177:	83 c4 10             	add    $0x10,%esp
  80117a:	eb 02                	jmp    80117e <dup+0xe5>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  80117c:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  80117e:	89 d8                	mov    %ebx,%eax
  801180:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801183:	5b                   	pop    %ebx
  801184:	5e                   	pop    %esi
  801185:	5f                   	pop    %edi
  801186:	c9                   	leave  
  801187:	c3                   	ret    

00801188 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801188:	55                   	push   %ebp
  801189:	89 e5                	mov    %esp,%ebp
  80118b:	53                   	push   %ebx
  80118c:	83 ec 14             	sub    $0x14,%esp
  80118f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801192:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801195:	50                   	push   %eax
  801196:	53                   	push   %ebx
  801197:	e8 6b fd ff ff       	call   800f07 <fd_lookup>
  80119c:	83 c4 08             	add    $0x8,%esp
  80119f:	85 c0                	test   %eax,%eax
  8011a1:	78 67                	js     80120a <read+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011a3:	83 ec 08             	sub    $0x8,%esp
  8011a6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011a9:	50                   	push   %eax
  8011aa:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011ad:	ff 30                	pushl  (%eax)
  8011af:	e8 a9 fd ff ff       	call   800f5d <dev_lookup>
  8011b4:	83 c4 10             	add    $0x10,%esp
  8011b7:	85 c0                	test   %eax,%eax
  8011b9:	78 4f                	js     80120a <read+0x82>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8011bb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011be:	8b 50 08             	mov    0x8(%eax),%edx
  8011c1:	83 e2 03             	and    $0x3,%edx
  8011c4:	83 fa 01             	cmp    $0x1,%edx
  8011c7:	75 21                	jne    8011ea <read+0x62>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8011c9:	a1 08 40 80 00       	mov    0x804008,%eax
  8011ce:	8b 40 48             	mov    0x48(%eax),%eax
  8011d1:	83 ec 04             	sub    $0x4,%esp
  8011d4:	53                   	push   %ebx
  8011d5:	50                   	push   %eax
  8011d6:	68 f0 23 80 00       	push   $0x8023f0
  8011db:	e8 ec f0 ff ff       	call   8002cc <cprintf>
		return -E_INVAL;
  8011e0:	83 c4 10             	add    $0x10,%esp
  8011e3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8011e8:	eb 20                	jmp    80120a <read+0x82>
	}
	if (!dev->dev_read)
  8011ea:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8011ed:	8b 52 08             	mov    0x8(%edx),%edx
  8011f0:	85 d2                	test   %edx,%edx
  8011f2:	74 11                	je     801205 <read+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8011f4:	83 ec 04             	sub    $0x4,%esp
  8011f7:	ff 75 10             	pushl  0x10(%ebp)
  8011fa:	ff 75 0c             	pushl  0xc(%ebp)
  8011fd:	50                   	push   %eax
  8011fe:	ff d2                	call   *%edx
  801200:	83 c4 10             	add    $0x10,%esp
  801203:	eb 05                	jmp    80120a <read+0x82>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801205:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  80120a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80120d:	c9                   	leave  
  80120e:	c3                   	ret    

0080120f <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80120f:	55                   	push   %ebp
  801210:	89 e5                	mov    %esp,%ebp
  801212:	57                   	push   %edi
  801213:	56                   	push   %esi
  801214:	53                   	push   %ebx
  801215:	83 ec 0c             	sub    $0xc,%esp
  801218:	8b 7d 08             	mov    0x8(%ebp),%edi
  80121b:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80121e:	85 f6                	test   %esi,%esi
  801220:	74 31                	je     801253 <readn+0x44>
  801222:	b8 00 00 00 00       	mov    $0x0,%eax
  801227:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = read(fdnum, (char*)buf + tot, n - tot);
  80122c:	83 ec 04             	sub    $0x4,%esp
  80122f:	89 f2                	mov    %esi,%edx
  801231:	29 c2                	sub    %eax,%edx
  801233:	52                   	push   %edx
  801234:	03 45 0c             	add    0xc(%ebp),%eax
  801237:	50                   	push   %eax
  801238:	57                   	push   %edi
  801239:	e8 4a ff ff ff       	call   801188 <read>
		if (m < 0)
  80123e:	83 c4 10             	add    $0x10,%esp
  801241:	85 c0                	test   %eax,%eax
  801243:	78 17                	js     80125c <readn+0x4d>
			return m;
		if (m == 0)
  801245:	85 c0                	test   %eax,%eax
  801247:	74 11                	je     80125a <readn+0x4b>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801249:	01 c3                	add    %eax,%ebx
  80124b:	89 d8                	mov    %ebx,%eax
  80124d:	39 f3                	cmp    %esi,%ebx
  80124f:	72 db                	jb     80122c <readn+0x1d>
  801251:	eb 09                	jmp    80125c <readn+0x4d>
  801253:	b8 00 00 00 00       	mov    $0x0,%eax
  801258:	eb 02                	jmp    80125c <readn+0x4d>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  80125a:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  80125c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80125f:	5b                   	pop    %ebx
  801260:	5e                   	pop    %esi
  801261:	5f                   	pop    %edi
  801262:	c9                   	leave  
  801263:	c3                   	ret    

00801264 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801264:	55                   	push   %ebp
  801265:	89 e5                	mov    %esp,%ebp
  801267:	53                   	push   %ebx
  801268:	83 ec 14             	sub    $0x14,%esp
  80126b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80126e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801271:	50                   	push   %eax
  801272:	53                   	push   %ebx
  801273:	e8 8f fc ff ff       	call   800f07 <fd_lookup>
  801278:	83 c4 08             	add    $0x8,%esp
  80127b:	85 c0                	test   %eax,%eax
  80127d:	78 62                	js     8012e1 <write+0x7d>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80127f:	83 ec 08             	sub    $0x8,%esp
  801282:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801285:	50                   	push   %eax
  801286:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801289:	ff 30                	pushl  (%eax)
  80128b:	e8 cd fc ff ff       	call   800f5d <dev_lookup>
  801290:	83 c4 10             	add    $0x10,%esp
  801293:	85 c0                	test   %eax,%eax
  801295:	78 4a                	js     8012e1 <write+0x7d>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801297:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80129a:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80129e:	75 21                	jne    8012c1 <write+0x5d>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8012a0:	a1 08 40 80 00       	mov    0x804008,%eax
  8012a5:	8b 40 48             	mov    0x48(%eax),%eax
  8012a8:	83 ec 04             	sub    $0x4,%esp
  8012ab:	53                   	push   %ebx
  8012ac:	50                   	push   %eax
  8012ad:	68 0c 24 80 00       	push   $0x80240c
  8012b2:	e8 15 f0 ff ff       	call   8002cc <cprintf>
		return -E_INVAL;
  8012b7:	83 c4 10             	add    $0x10,%esp
  8012ba:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012bf:	eb 20                	jmp    8012e1 <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8012c1:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8012c4:	8b 52 0c             	mov    0xc(%edx),%edx
  8012c7:	85 d2                	test   %edx,%edx
  8012c9:	74 11                	je     8012dc <write+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8012cb:	83 ec 04             	sub    $0x4,%esp
  8012ce:	ff 75 10             	pushl  0x10(%ebp)
  8012d1:	ff 75 0c             	pushl  0xc(%ebp)
  8012d4:	50                   	push   %eax
  8012d5:	ff d2                	call   *%edx
  8012d7:	83 c4 10             	add    $0x10,%esp
  8012da:	eb 05                	jmp    8012e1 <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8012dc:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  8012e1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012e4:	c9                   	leave  
  8012e5:	c3                   	ret    

008012e6 <seek>:

int
seek(int fdnum, off_t offset)
{
  8012e6:	55                   	push   %ebp
  8012e7:	89 e5                	mov    %esp,%ebp
  8012e9:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8012ec:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8012ef:	50                   	push   %eax
  8012f0:	ff 75 08             	pushl  0x8(%ebp)
  8012f3:	e8 0f fc ff ff       	call   800f07 <fd_lookup>
  8012f8:	83 c4 08             	add    $0x8,%esp
  8012fb:	85 c0                	test   %eax,%eax
  8012fd:	78 0e                	js     80130d <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8012ff:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801302:	8b 55 0c             	mov    0xc(%ebp),%edx
  801305:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801308:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80130d:	c9                   	leave  
  80130e:	c3                   	ret    

0080130f <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80130f:	55                   	push   %ebp
  801310:	89 e5                	mov    %esp,%ebp
  801312:	53                   	push   %ebx
  801313:	83 ec 14             	sub    $0x14,%esp
  801316:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801319:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80131c:	50                   	push   %eax
  80131d:	53                   	push   %ebx
  80131e:	e8 e4 fb ff ff       	call   800f07 <fd_lookup>
  801323:	83 c4 08             	add    $0x8,%esp
  801326:	85 c0                	test   %eax,%eax
  801328:	78 5f                	js     801389 <ftruncate+0x7a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80132a:	83 ec 08             	sub    $0x8,%esp
  80132d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801330:	50                   	push   %eax
  801331:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801334:	ff 30                	pushl  (%eax)
  801336:	e8 22 fc ff ff       	call   800f5d <dev_lookup>
  80133b:	83 c4 10             	add    $0x10,%esp
  80133e:	85 c0                	test   %eax,%eax
  801340:	78 47                	js     801389 <ftruncate+0x7a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801342:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801345:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801349:	75 21                	jne    80136c <ftruncate+0x5d>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80134b:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801350:	8b 40 48             	mov    0x48(%eax),%eax
  801353:	83 ec 04             	sub    $0x4,%esp
  801356:	53                   	push   %ebx
  801357:	50                   	push   %eax
  801358:	68 cc 23 80 00       	push   $0x8023cc
  80135d:	e8 6a ef ff ff       	call   8002cc <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801362:	83 c4 10             	add    $0x10,%esp
  801365:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80136a:	eb 1d                	jmp    801389 <ftruncate+0x7a>
	}
	if (!dev->dev_trunc)
  80136c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80136f:	8b 52 18             	mov    0x18(%edx),%edx
  801372:	85 d2                	test   %edx,%edx
  801374:	74 0e                	je     801384 <ftruncate+0x75>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801376:	83 ec 08             	sub    $0x8,%esp
  801379:	ff 75 0c             	pushl  0xc(%ebp)
  80137c:	50                   	push   %eax
  80137d:	ff d2                	call   *%edx
  80137f:	83 c4 10             	add    $0x10,%esp
  801382:	eb 05                	jmp    801389 <ftruncate+0x7a>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801384:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  801389:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80138c:	c9                   	leave  
  80138d:	c3                   	ret    

0080138e <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80138e:	55                   	push   %ebp
  80138f:	89 e5                	mov    %esp,%ebp
  801391:	53                   	push   %ebx
  801392:	83 ec 14             	sub    $0x14,%esp
  801395:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801398:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80139b:	50                   	push   %eax
  80139c:	ff 75 08             	pushl  0x8(%ebp)
  80139f:	e8 63 fb ff ff       	call   800f07 <fd_lookup>
  8013a4:	83 c4 08             	add    $0x8,%esp
  8013a7:	85 c0                	test   %eax,%eax
  8013a9:	78 52                	js     8013fd <fstat+0x6f>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013ab:	83 ec 08             	sub    $0x8,%esp
  8013ae:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013b1:	50                   	push   %eax
  8013b2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013b5:	ff 30                	pushl  (%eax)
  8013b7:	e8 a1 fb ff ff       	call   800f5d <dev_lookup>
  8013bc:	83 c4 10             	add    $0x10,%esp
  8013bf:	85 c0                	test   %eax,%eax
  8013c1:	78 3a                	js     8013fd <fstat+0x6f>
		return r;
	if (!dev->dev_stat)
  8013c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013c6:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8013ca:	74 2c                	je     8013f8 <fstat+0x6a>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8013cc:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8013cf:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8013d6:	00 00 00 
	stat->st_isdir = 0;
  8013d9:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8013e0:	00 00 00 
	stat->st_dev = dev;
  8013e3:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8013e9:	83 ec 08             	sub    $0x8,%esp
  8013ec:	53                   	push   %ebx
  8013ed:	ff 75 f0             	pushl  -0x10(%ebp)
  8013f0:	ff 50 14             	call   *0x14(%eax)
  8013f3:	83 c4 10             	add    $0x10,%esp
  8013f6:	eb 05                	jmp    8013fd <fstat+0x6f>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8013f8:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8013fd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801400:	c9                   	leave  
  801401:	c3                   	ret    

00801402 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801402:	55                   	push   %ebp
  801403:	89 e5                	mov    %esp,%ebp
  801405:	56                   	push   %esi
  801406:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801407:	83 ec 08             	sub    $0x8,%esp
  80140a:	6a 00                	push   $0x0
  80140c:	ff 75 08             	pushl  0x8(%ebp)
  80140f:	e8 78 01 00 00       	call   80158c <open>
  801414:	89 c3                	mov    %eax,%ebx
  801416:	83 c4 10             	add    $0x10,%esp
  801419:	85 c0                	test   %eax,%eax
  80141b:	78 1b                	js     801438 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  80141d:	83 ec 08             	sub    $0x8,%esp
  801420:	ff 75 0c             	pushl  0xc(%ebp)
  801423:	50                   	push   %eax
  801424:	e8 65 ff ff ff       	call   80138e <fstat>
  801429:	89 c6                	mov    %eax,%esi
	close(fd);
  80142b:	89 1c 24             	mov    %ebx,(%esp)
  80142e:	e8 18 fc ff ff       	call   80104b <close>
	return r;
  801433:	83 c4 10             	add    $0x10,%esp
  801436:	89 f3                	mov    %esi,%ebx
}
  801438:	89 d8                	mov    %ebx,%eax
  80143a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80143d:	5b                   	pop    %ebx
  80143e:	5e                   	pop    %esi
  80143f:	c9                   	leave  
  801440:	c3                   	ret    
  801441:	00 00                	add    %al,(%eax)
	...

00801444 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801444:	55                   	push   %ebp
  801445:	89 e5                	mov    %esp,%ebp
  801447:	56                   	push   %esi
  801448:	53                   	push   %ebx
  801449:	89 c3                	mov    %eax,%ebx
  80144b:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  80144d:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  801454:	75 12                	jne    801468 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801456:	83 ec 0c             	sub    $0xc,%esp
  801459:	6a 01                	push   $0x1
  80145b:	e8 9e 08 00 00       	call   801cfe <ipc_find_env>
  801460:	a3 04 40 80 00       	mov    %eax,0x804004
  801465:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801468:	6a 07                	push   $0x7
  80146a:	68 00 50 80 00       	push   $0x805000
  80146f:	53                   	push   %ebx
  801470:	ff 35 04 40 80 00    	pushl  0x804004
  801476:	e8 2e 08 00 00       	call   801ca9 <ipc_send>
	
	return ipc_recv(NULL, dstva, NULL);
  80147b:	83 c4 0c             	add    $0xc,%esp
  80147e:	6a 00                	push   $0x0
  801480:	56                   	push   %esi
  801481:	6a 00                	push   $0x0
  801483:	e8 ac 07 00 00       	call   801c34 <ipc_recv>
}
  801488:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80148b:	5b                   	pop    %ebx
  80148c:	5e                   	pop    %esi
  80148d:	c9                   	leave  
  80148e:	c3                   	ret    

0080148f <devfile_stat>:
}


static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80148f:	55                   	push   %ebp
  801490:	89 e5                	mov    %esp,%ebp
  801492:	53                   	push   %ebx
  801493:	83 ec 04             	sub    $0x4,%esp
  801496:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801499:	8b 45 08             	mov    0x8(%ebp),%eax
  80149c:	8b 40 0c             	mov    0xc(%eax),%eax
  80149f:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0) {
  8014a4:	ba 00 00 00 00       	mov    $0x0,%edx
  8014a9:	b8 05 00 00 00       	mov    $0x5,%eax
  8014ae:	e8 91 ff ff ff       	call   801444 <fsipc>
  8014b3:	85 c0                	test   %eax,%eax
  8014b5:	78 2c                	js     8014e3 <devfile_stat+0x54>
		return r;
	}
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8014b7:	83 ec 08             	sub    $0x8,%esp
  8014ba:	68 00 50 80 00       	push   $0x805000
  8014bf:	53                   	push   %ebx
  8014c0:	e8 bd f3 ff ff       	call   800882 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8014c5:	a1 80 50 80 00       	mov    0x805080,%eax
  8014ca:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8014d0:	a1 84 50 80 00       	mov    0x805084,%eax
  8014d5:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8014db:	83 c4 10             	add    $0x10,%esp
  8014de:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8014e3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014e6:	c9                   	leave  
  8014e7:	c3                   	ret    

008014e8 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8014e8:	55                   	push   %ebp
  8014e9:	89 e5                	mov    %esp,%ebp
  8014eb:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8014ee:	8b 45 08             	mov    0x8(%ebp),%eax
  8014f1:	8b 40 0c             	mov    0xc(%eax),%eax
  8014f4:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8014f9:	ba 00 00 00 00       	mov    $0x0,%edx
  8014fe:	b8 06 00 00 00       	mov    $0x6,%eax
  801503:	e8 3c ff ff ff       	call   801444 <fsipc>
}
  801508:	c9                   	leave  
  801509:	c3                   	ret    

0080150a <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  80150a:	55                   	push   %ebp
  80150b:	89 e5                	mov    %esp,%ebp
  80150d:	56                   	push   %esi
  80150e:	53                   	push   %ebx
  80150f:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801512:	8b 45 08             	mov    0x8(%ebp),%eax
  801515:	8b 40 0c             	mov    0xc(%eax),%eax
  801518:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  80151d:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801523:	ba 00 00 00 00       	mov    $0x0,%edx
  801528:	b8 03 00 00 00       	mov    $0x3,%eax
  80152d:	e8 12 ff ff ff       	call   801444 <fsipc>
  801532:	89 c3                	mov    %eax,%ebx
  801534:	85 c0                	test   %eax,%eax
  801536:	78 4b                	js     801583 <devfile_read+0x79>
		return r;
	assert(r <= n);
  801538:	39 c6                	cmp    %eax,%esi
  80153a:	73 16                	jae    801552 <devfile_read+0x48>
  80153c:	68 3c 24 80 00       	push   $0x80243c
  801541:	68 43 24 80 00       	push   $0x802443
  801546:	6a 7d                	push   $0x7d
  801548:	68 58 24 80 00       	push   $0x802458
  80154d:	e8 a2 ec ff ff       	call   8001f4 <_panic>
	assert(r <= PGSIZE);
  801552:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801557:	7e 16                	jle    80156f <devfile_read+0x65>
  801559:	68 63 24 80 00       	push   $0x802463
  80155e:	68 43 24 80 00       	push   $0x802443
  801563:	6a 7e                	push   $0x7e
  801565:	68 58 24 80 00       	push   $0x802458
  80156a:	e8 85 ec ff ff       	call   8001f4 <_panic>
	memmove(buf, &fsipcbuf, r);
  80156f:	83 ec 04             	sub    $0x4,%esp
  801572:	50                   	push   %eax
  801573:	68 00 50 80 00       	push   $0x805000
  801578:	ff 75 0c             	pushl  0xc(%ebp)
  80157b:	e8 c3 f4 ff ff       	call   800a43 <memmove>
	return r;
  801580:	83 c4 10             	add    $0x10,%esp
}
  801583:	89 d8                	mov    %ebx,%eax
  801585:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801588:	5b                   	pop    %ebx
  801589:	5e                   	pop    %esi
  80158a:	c9                   	leave  
  80158b:	c3                   	ret    

0080158c <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  80158c:	55                   	push   %ebp
  80158d:	89 e5                	mov    %esp,%ebp
  80158f:	56                   	push   %esi
  801590:	53                   	push   %ebx
  801591:	83 ec 1c             	sub    $0x1c,%esp
  801594:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801597:	56                   	push   %esi
  801598:	e8 93 f2 ff ff       	call   800830 <strlen>
  80159d:	83 c4 10             	add    $0x10,%esp
  8015a0:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8015a5:	7f 65                	jg     80160c <open+0x80>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8015a7:	83 ec 0c             	sub    $0xc,%esp
  8015aa:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015ad:	50                   	push   %eax
  8015ae:	e8 e1 f8 ff ff       	call   800e94 <fd_alloc>
  8015b3:	89 c3                	mov    %eax,%ebx
  8015b5:	83 c4 10             	add    $0x10,%esp
  8015b8:	85 c0                	test   %eax,%eax
  8015ba:	78 55                	js     801611 <open+0x85>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8015bc:	83 ec 08             	sub    $0x8,%esp
  8015bf:	56                   	push   %esi
  8015c0:	68 00 50 80 00       	push   $0x805000
  8015c5:	e8 b8 f2 ff ff       	call   800882 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8015ca:	8b 45 0c             	mov    0xc(%ebp),%eax
  8015cd:	a3 00 54 80 00       	mov    %eax,0x805400



	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8015d2:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8015d5:	b8 01 00 00 00       	mov    $0x1,%eax
  8015da:	e8 65 fe ff ff       	call   801444 <fsipc>
  8015df:	89 c3                	mov    %eax,%ebx
  8015e1:	83 c4 10             	add    $0x10,%esp
  8015e4:	85 c0                	test   %eax,%eax
  8015e6:	79 12                	jns    8015fa <open+0x6e>
		fd_close(fd, 0);
  8015e8:	83 ec 08             	sub    $0x8,%esp
  8015eb:	6a 00                	push   $0x0
  8015ed:	ff 75 f4             	pushl  -0xc(%ebp)
  8015f0:	e8 ce f9 ff ff       	call   800fc3 <fd_close>
		return r;
  8015f5:	83 c4 10             	add    $0x10,%esp
  8015f8:	eb 17                	jmp    801611 <open+0x85>
	}

	return fd2num(fd);
  8015fa:	83 ec 0c             	sub    $0xc,%esp
  8015fd:	ff 75 f4             	pushl  -0xc(%ebp)
  801600:	e8 67 f8 ff ff       	call   800e6c <fd2num>
  801605:	89 c3                	mov    %eax,%ebx
  801607:	83 c4 10             	add    $0x10,%esp
  80160a:	eb 05                	jmp    801611 <open+0x85>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  80160c:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801611:	89 d8                	mov    %ebx,%eax
  801613:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801616:	5b                   	pop    %ebx
  801617:	5e                   	pop    %esi
  801618:	c9                   	leave  
  801619:	c3                   	ret    
	...

0080161c <writebuf>:
};


static void
writebuf(struct printbuf *b)
{
  80161c:	55                   	push   %ebp
  80161d:	89 e5                	mov    %esp,%ebp
  80161f:	53                   	push   %ebx
  801620:	83 ec 04             	sub    $0x4,%esp
  801623:	89 c3                	mov    %eax,%ebx
	if (b->error > 0) {
  801625:	83 78 0c 00          	cmpl   $0x0,0xc(%eax)
  801629:	7e 2e                	jle    801659 <writebuf+0x3d>
		ssize_t result = write(b->fd, b->buf, b->idx);
  80162b:	83 ec 04             	sub    $0x4,%esp
  80162e:	ff 70 04             	pushl  0x4(%eax)
  801631:	8d 40 10             	lea    0x10(%eax),%eax
  801634:	50                   	push   %eax
  801635:	ff 33                	pushl  (%ebx)
  801637:	e8 28 fc ff ff       	call   801264 <write>
		if (result > 0)
  80163c:	83 c4 10             	add    $0x10,%esp
  80163f:	85 c0                	test   %eax,%eax
  801641:	7e 03                	jle    801646 <writebuf+0x2a>
			b->result += result;
  801643:	01 43 08             	add    %eax,0x8(%ebx)
		if (result != b->idx) // error, or wrote less than supplied
  801646:	39 43 04             	cmp    %eax,0x4(%ebx)
  801649:	74 0e                	je     801659 <writebuf+0x3d>
			b->error = (result < 0 ? result : 0);
  80164b:	89 c2                	mov    %eax,%edx
  80164d:	85 c0                	test   %eax,%eax
  80164f:	7e 05                	jle    801656 <writebuf+0x3a>
  801651:	ba 00 00 00 00       	mov    $0x0,%edx
  801656:	89 53 0c             	mov    %edx,0xc(%ebx)
	}
}
  801659:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80165c:	c9                   	leave  
  80165d:	c3                   	ret    

0080165e <putch>:

static void
putch(int ch, void *thunk)
{
  80165e:	55                   	push   %ebp
  80165f:	89 e5                	mov    %esp,%ebp
  801661:	53                   	push   %ebx
  801662:	83 ec 04             	sub    $0x4,%esp
  801665:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct printbuf *b = (struct printbuf *) thunk;
	b->buf[b->idx++] = ch;
  801668:	8b 43 04             	mov    0x4(%ebx),%eax
  80166b:	8b 55 08             	mov    0x8(%ebp),%edx
  80166e:	88 54 03 10          	mov    %dl,0x10(%ebx,%eax,1)
  801672:	40                   	inc    %eax
  801673:	89 43 04             	mov    %eax,0x4(%ebx)
	if (b->idx == 256) {
  801676:	3d 00 01 00 00       	cmp    $0x100,%eax
  80167b:	75 0e                	jne    80168b <putch+0x2d>
		writebuf(b);
  80167d:	89 d8                	mov    %ebx,%eax
  80167f:	e8 98 ff ff ff       	call   80161c <writebuf>
		b->idx = 0;
  801684:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	}
}
  80168b:	83 c4 04             	add    $0x4,%esp
  80168e:	5b                   	pop    %ebx
  80168f:	c9                   	leave  
  801690:	c3                   	ret    

00801691 <vfprintf>:

int
vfprintf(int fd, const char *fmt, va_list ap)
{
  801691:	55                   	push   %ebp
  801692:	89 e5                	mov    %esp,%ebp
  801694:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.fd = fd;
  80169a:	8b 45 08             	mov    0x8(%ebp),%eax
  80169d:	89 85 e8 fe ff ff    	mov    %eax,-0x118(%ebp)
	b.idx = 0;
  8016a3:	c7 85 ec fe ff ff 00 	movl   $0x0,-0x114(%ebp)
  8016aa:	00 00 00 
	b.result = 0;
  8016ad:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8016b4:	00 00 00 
	b.error = 1;
  8016b7:	c7 85 f4 fe ff ff 01 	movl   $0x1,-0x10c(%ebp)
  8016be:	00 00 00 
	vprintfmt(putch, &b, fmt, ap);
  8016c1:	ff 75 10             	pushl  0x10(%ebp)
  8016c4:	ff 75 0c             	pushl  0xc(%ebp)
  8016c7:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  8016cd:	50                   	push   %eax
  8016ce:	68 5e 16 80 00       	push   $0x80165e
  8016d3:	e8 59 ed ff ff       	call   800431 <vprintfmt>
	if (b.idx > 0)
  8016d8:	83 c4 10             	add    $0x10,%esp
  8016db:	83 bd ec fe ff ff 00 	cmpl   $0x0,-0x114(%ebp)
  8016e2:	7e 0b                	jle    8016ef <vfprintf+0x5e>
		writebuf(&b);
  8016e4:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  8016ea:	e8 2d ff ff ff       	call   80161c <writebuf>

	return (b.result ? b.result : b.error);
  8016ef:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8016f5:	85 c0                	test   %eax,%eax
  8016f7:	75 06                	jne    8016ff <vfprintf+0x6e>
  8016f9:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
}
  8016ff:	c9                   	leave  
  801700:	c3                   	ret    

00801701 <fprintf>:

int
fprintf(int fd, const char *fmt, ...)
{
  801701:	55                   	push   %ebp
  801702:	89 e5                	mov    %esp,%ebp
  801704:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801707:	8d 45 10             	lea    0x10(%ebp),%eax
	cnt = vfprintf(fd, fmt, ap);
  80170a:	50                   	push   %eax
  80170b:	ff 75 0c             	pushl  0xc(%ebp)
  80170e:	ff 75 08             	pushl  0x8(%ebp)
  801711:	e8 7b ff ff ff       	call   801691 <vfprintf>
	va_end(ap);

	return cnt;
}
  801716:	c9                   	leave  
  801717:	c3                   	ret    

00801718 <printf>:

int
printf(const char *fmt, ...)
{
  801718:	55                   	push   %ebp
  801719:	89 e5                	mov    %esp,%ebp
  80171b:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80171e:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vfprintf(1, fmt, ap);
  801721:	50                   	push   %eax
  801722:	ff 75 08             	pushl  0x8(%ebp)
  801725:	6a 01                	push   $0x1
  801727:	e8 65 ff ff ff       	call   801691 <vfprintf>
	va_end(ap);

	return cnt;
}
  80172c:	c9                   	leave  
  80172d:	c3                   	ret    
	...

00801730 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801730:	55                   	push   %ebp
  801731:	89 e5                	mov    %esp,%ebp
  801733:	56                   	push   %esi
  801734:	53                   	push   %ebx
  801735:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801738:	83 ec 0c             	sub    $0xc,%esp
  80173b:	ff 75 08             	pushl  0x8(%ebp)
  80173e:	e8 39 f7 ff ff       	call   800e7c <fd2data>
  801743:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  801745:	83 c4 08             	add    $0x8,%esp
  801748:	68 6f 24 80 00       	push   $0x80246f
  80174d:	56                   	push   %esi
  80174e:	e8 2f f1 ff ff       	call   800882 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801753:	8b 43 04             	mov    0x4(%ebx),%eax
  801756:	2b 03                	sub    (%ebx),%eax
  801758:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  80175e:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  801765:	00 00 00 
	stat->st_dev = &devpipe;
  801768:	c7 86 88 00 00 00 24 	movl   $0x803024,0x88(%esi)
  80176f:	30 80 00 
	return 0;
}
  801772:	b8 00 00 00 00       	mov    $0x0,%eax
  801777:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80177a:	5b                   	pop    %ebx
  80177b:	5e                   	pop    %esi
  80177c:	c9                   	leave  
  80177d:	c3                   	ret    

0080177e <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  80177e:	55                   	push   %ebp
  80177f:	89 e5                	mov    %esp,%ebp
  801781:	53                   	push   %ebx
  801782:	83 ec 0c             	sub    $0xc,%esp
  801785:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801788:	53                   	push   %ebx
  801789:	6a 00                	push   $0x0
  80178b:	e8 be f5 ff ff       	call   800d4e <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801790:	89 1c 24             	mov    %ebx,(%esp)
  801793:	e8 e4 f6 ff ff       	call   800e7c <fd2data>
  801798:	83 c4 08             	add    $0x8,%esp
  80179b:	50                   	push   %eax
  80179c:	6a 00                	push   $0x0
  80179e:	e8 ab f5 ff ff       	call   800d4e <sys_page_unmap>
}
  8017a3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017a6:	c9                   	leave  
  8017a7:	c3                   	ret    

008017a8 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8017a8:	55                   	push   %ebp
  8017a9:	89 e5                	mov    %esp,%ebp
  8017ab:	57                   	push   %edi
  8017ac:	56                   	push   %esi
  8017ad:	53                   	push   %ebx
  8017ae:	83 ec 1c             	sub    $0x1c,%esp
  8017b1:	89 c7                	mov    %eax,%edi
  8017b3:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8017b6:	a1 08 40 80 00       	mov    0x804008,%eax
  8017bb:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  8017be:	83 ec 0c             	sub    $0xc,%esp
  8017c1:	57                   	push   %edi
  8017c2:	e8 95 05 00 00       	call   801d5c <pageref>
  8017c7:	89 c6                	mov    %eax,%esi
  8017c9:	83 c4 04             	add    $0x4,%esp
  8017cc:	ff 75 e4             	pushl  -0x1c(%ebp)
  8017cf:	e8 88 05 00 00       	call   801d5c <pageref>
  8017d4:	83 c4 10             	add    $0x10,%esp
  8017d7:	39 c6                	cmp    %eax,%esi
  8017d9:	0f 94 c0             	sete   %al
  8017dc:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  8017df:	8b 15 08 40 80 00    	mov    0x804008,%edx
  8017e5:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  8017e8:	39 cb                	cmp    %ecx,%ebx
  8017ea:	75 08                	jne    8017f4 <_pipeisclosed+0x4c>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  8017ec:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8017ef:	5b                   	pop    %ebx
  8017f0:	5e                   	pop    %esi
  8017f1:	5f                   	pop    %edi
  8017f2:	c9                   	leave  
  8017f3:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  8017f4:	83 f8 01             	cmp    $0x1,%eax
  8017f7:	75 bd                	jne    8017b6 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8017f9:	8b 42 58             	mov    0x58(%edx),%eax
  8017fc:	6a 01                	push   $0x1
  8017fe:	50                   	push   %eax
  8017ff:	53                   	push   %ebx
  801800:	68 76 24 80 00       	push   $0x802476
  801805:	e8 c2 ea ff ff       	call   8002cc <cprintf>
  80180a:	83 c4 10             	add    $0x10,%esp
  80180d:	eb a7                	jmp    8017b6 <_pipeisclosed+0xe>

0080180f <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80180f:	55                   	push   %ebp
  801810:	89 e5                	mov    %esp,%ebp
  801812:	57                   	push   %edi
  801813:	56                   	push   %esi
  801814:	53                   	push   %ebx
  801815:	83 ec 28             	sub    $0x28,%esp
  801818:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  80181b:	56                   	push   %esi
  80181c:	e8 5b f6 ff ff       	call   800e7c <fd2data>
  801821:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801823:	83 c4 10             	add    $0x10,%esp
  801826:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80182a:	75 4a                	jne    801876 <devpipe_write+0x67>
  80182c:	bf 00 00 00 00       	mov    $0x0,%edi
  801831:	eb 56                	jmp    801889 <devpipe_write+0x7a>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801833:	89 da                	mov    %ebx,%edx
  801835:	89 f0                	mov    %esi,%eax
  801837:	e8 6c ff ff ff       	call   8017a8 <_pipeisclosed>
  80183c:	85 c0                	test   %eax,%eax
  80183e:	75 4d                	jne    80188d <devpipe_write+0x7e>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801840:	e8 98 f4 ff ff       	call   800cdd <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801845:	8b 43 04             	mov    0x4(%ebx),%eax
  801848:	8b 13                	mov    (%ebx),%edx
  80184a:	83 c2 20             	add    $0x20,%edx
  80184d:	39 d0                	cmp    %edx,%eax
  80184f:	73 e2                	jae    801833 <devpipe_write+0x24>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801851:	89 c2                	mov    %eax,%edx
  801853:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  801859:	79 05                	jns    801860 <devpipe_write+0x51>
  80185b:	4a                   	dec    %edx
  80185c:	83 ca e0             	or     $0xffffffe0,%edx
  80185f:	42                   	inc    %edx
  801860:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801863:	8a 0c 39             	mov    (%ecx,%edi,1),%cl
  801866:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  80186a:	40                   	inc    %eax
  80186b:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80186e:	47                   	inc    %edi
  80186f:	39 7d 10             	cmp    %edi,0x10(%ebp)
  801872:	77 07                	ja     80187b <devpipe_write+0x6c>
  801874:	eb 13                	jmp    801889 <devpipe_write+0x7a>
  801876:	bf 00 00 00 00       	mov    $0x0,%edi
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  80187b:	8b 43 04             	mov    0x4(%ebx),%eax
  80187e:	8b 13                	mov    (%ebx),%edx
  801880:	83 c2 20             	add    $0x20,%edx
  801883:	39 d0                	cmp    %edx,%eax
  801885:	73 ac                	jae    801833 <devpipe_write+0x24>
  801887:	eb c8                	jmp    801851 <devpipe_write+0x42>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801889:	89 f8                	mov    %edi,%eax
  80188b:	eb 05                	jmp    801892 <devpipe_write+0x83>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80188d:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801892:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801895:	5b                   	pop    %ebx
  801896:	5e                   	pop    %esi
  801897:	5f                   	pop    %edi
  801898:	c9                   	leave  
  801899:	c3                   	ret    

0080189a <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  80189a:	55                   	push   %ebp
  80189b:	89 e5                	mov    %esp,%ebp
  80189d:	57                   	push   %edi
  80189e:	56                   	push   %esi
  80189f:	53                   	push   %ebx
  8018a0:	83 ec 18             	sub    $0x18,%esp
  8018a3:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  8018a6:	57                   	push   %edi
  8018a7:	e8 d0 f5 ff ff       	call   800e7c <fd2data>
  8018ac:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8018ae:	83 c4 10             	add    $0x10,%esp
  8018b1:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8018b5:	75 44                	jne    8018fb <devpipe_read+0x61>
  8018b7:	be 00 00 00 00       	mov    $0x0,%esi
  8018bc:	eb 4f                	jmp    80190d <devpipe_read+0x73>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
				return i;
  8018be:	89 f0                	mov    %esi,%eax
  8018c0:	eb 54                	jmp    801916 <devpipe_read+0x7c>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  8018c2:	89 da                	mov    %ebx,%edx
  8018c4:	89 f8                	mov    %edi,%eax
  8018c6:	e8 dd fe ff ff       	call   8017a8 <_pipeisclosed>
  8018cb:	85 c0                	test   %eax,%eax
  8018cd:	75 42                	jne    801911 <devpipe_read+0x77>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  8018cf:	e8 09 f4 ff ff       	call   800cdd <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8018d4:	8b 03                	mov    (%ebx),%eax
  8018d6:	3b 43 04             	cmp    0x4(%ebx),%eax
  8018d9:	74 e7                	je     8018c2 <devpipe_read+0x28>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8018db:	25 1f 00 00 80       	and    $0x8000001f,%eax
  8018e0:	79 05                	jns    8018e7 <devpipe_read+0x4d>
  8018e2:	48                   	dec    %eax
  8018e3:	83 c8 e0             	or     $0xffffffe0,%eax
  8018e6:	40                   	inc    %eax
  8018e7:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  8018eb:	8b 55 0c             	mov    0xc(%ebp),%edx
  8018ee:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  8018f1:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8018f3:	46                   	inc    %esi
  8018f4:	39 75 10             	cmp    %esi,0x10(%ebp)
  8018f7:	77 07                	ja     801900 <devpipe_read+0x66>
  8018f9:	eb 12                	jmp    80190d <devpipe_read+0x73>
  8018fb:	be 00 00 00 00       	mov    $0x0,%esi
		while (p->p_rpos == p->p_wpos) {
  801900:	8b 03                	mov    (%ebx),%eax
  801902:	3b 43 04             	cmp    0x4(%ebx),%eax
  801905:	75 d4                	jne    8018db <devpipe_read+0x41>
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801907:	85 f6                	test   %esi,%esi
  801909:	75 b3                	jne    8018be <devpipe_read+0x24>
  80190b:	eb b5                	jmp    8018c2 <devpipe_read+0x28>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  80190d:	89 f0                	mov    %esi,%eax
  80190f:	eb 05                	jmp    801916 <devpipe_read+0x7c>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801911:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801916:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801919:	5b                   	pop    %ebx
  80191a:	5e                   	pop    %esi
  80191b:	5f                   	pop    %edi
  80191c:	c9                   	leave  
  80191d:	c3                   	ret    

0080191e <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  80191e:	55                   	push   %ebp
  80191f:	89 e5                	mov    %esp,%ebp
  801921:	57                   	push   %edi
  801922:	56                   	push   %esi
  801923:	53                   	push   %ebx
  801924:	83 ec 28             	sub    $0x28,%esp
  801927:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  80192a:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80192d:	50                   	push   %eax
  80192e:	e8 61 f5 ff ff       	call   800e94 <fd_alloc>
  801933:	89 c3                	mov    %eax,%ebx
  801935:	83 c4 10             	add    $0x10,%esp
  801938:	85 c0                	test   %eax,%eax
  80193a:	0f 88 24 01 00 00    	js     801a64 <pipe+0x146>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801940:	83 ec 04             	sub    $0x4,%esp
  801943:	68 07 04 00 00       	push   $0x407
  801948:	ff 75 e4             	pushl  -0x1c(%ebp)
  80194b:	6a 00                	push   $0x0
  80194d:	e8 b2 f3 ff ff       	call   800d04 <sys_page_alloc>
  801952:	89 c3                	mov    %eax,%ebx
  801954:	83 c4 10             	add    $0x10,%esp
  801957:	85 c0                	test   %eax,%eax
  801959:	0f 88 05 01 00 00    	js     801a64 <pipe+0x146>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  80195f:	83 ec 0c             	sub    $0xc,%esp
  801962:	8d 45 e0             	lea    -0x20(%ebp),%eax
  801965:	50                   	push   %eax
  801966:	e8 29 f5 ff ff       	call   800e94 <fd_alloc>
  80196b:	89 c3                	mov    %eax,%ebx
  80196d:	83 c4 10             	add    $0x10,%esp
  801970:	85 c0                	test   %eax,%eax
  801972:	0f 88 dc 00 00 00    	js     801a54 <pipe+0x136>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801978:	83 ec 04             	sub    $0x4,%esp
  80197b:	68 07 04 00 00       	push   $0x407
  801980:	ff 75 e0             	pushl  -0x20(%ebp)
  801983:	6a 00                	push   $0x0
  801985:	e8 7a f3 ff ff       	call   800d04 <sys_page_alloc>
  80198a:	89 c3                	mov    %eax,%ebx
  80198c:	83 c4 10             	add    $0x10,%esp
  80198f:	85 c0                	test   %eax,%eax
  801991:	0f 88 bd 00 00 00    	js     801a54 <pipe+0x136>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801997:	83 ec 0c             	sub    $0xc,%esp
  80199a:	ff 75 e4             	pushl  -0x1c(%ebp)
  80199d:	e8 da f4 ff ff       	call   800e7c <fd2data>
  8019a2:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8019a4:	83 c4 0c             	add    $0xc,%esp
  8019a7:	68 07 04 00 00       	push   $0x407
  8019ac:	50                   	push   %eax
  8019ad:	6a 00                	push   $0x0
  8019af:	e8 50 f3 ff ff       	call   800d04 <sys_page_alloc>
  8019b4:	89 c3                	mov    %eax,%ebx
  8019b6:	83 c4 10             	add    $0x10,%esp
  8019b9:	85 c0                	test   %eax,%eax
  8019bb:	0f 88 83 00 00 00    	js     801a44 <pipe+0x126>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8019c1:	83 ec 0c             	sub    $0xc,%esp
  8019c4:	ff 75 e0             	pushl  -0x20(%ebp)
  8019c7:	e8 b0 f4 ff ff       	call   800e7c <fd2data>
  8019cc:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  8019d3:	50                   	push   %eax
  8019d4:	6a 00                	push   $0x0
  8019d6:	56                   	push   %esi
  8019d7:	6a 00                	push   $0x0
  8019d9:	e8 4a f3 ff ff       	call   800d28 <sys_page_map>
  8019de:	89 c3                	mov    %eax,%ebx
  8019e0:	83 c4 20             	add    $0x20,%esp
  8019e3:	85 c0                	test   %eax,%eax
  8019e5:	78 4f                	js     801a36 <pipe+0x118>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  8019e7:	8b 15 24 30 80 00    	mov    0x803024,%edx
  8019ed:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8019f0:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8019f2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8019f5:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8019fc:	8b 15 24 30 80 00    	mov    0x803024,%edx
  801a02:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801a05:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801a07:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801a0a:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801a11:	83 ec 0c             	sub    $0xc,%esp
  801a14:	ff 75 e4             	pushl  -0x1c(%ebp)
  801a17:	e8 50 f4 ff ff       	call   800e6c <fd2num>
  801a1c:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  801a1e:	83 c4 04             	add    $0x4,%esp
  801a21:	ff 75 e0             	pushl  -0x20(%ebp)
  801a24:	e8 43 f4 ff ff       	call   800e6c <fd2num>
  801a29:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  801a2c:	83 c4 10             	add    $0x10,%esp
  801a2f:	bb 00 00 00 00       	mov    $0x0,%ebx
  801a34:	eb 2e                	jmp    801a64 <pipe+0x146>

    err3:
	sys_page_unmap(0, va);
  801a36:	83 ec 08             	sub    $0x8,%esp
  801a39:	56                   	push   %esi
  801a3a:	6a 00                	push   $0x0
  801a3c:	e8 0d f3 ff ff       	call   800d4e <sys_page_unmap>
  801a41:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801a44:	83 ec 08             	sub    $0x8,%esp
  801a47:	ff 75 e0             	pushl  -0x20(%ebp)
  801a4a:	6a 00                	push   $0x0
  801a4c:	e8 fd f2 ff ff       	call   800d4e <sys_page_unmap>
  801a51:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801a54:	83 ec 08             	sub    $0x8,%esp
  801a57:	ff 75 e4             	pushl  -0x1c(%ebp)
  801a5a:	6a 00                	push   $0x0
  801a5c:	e8 ed f2 ff ff       	call   800d4e <sys_page_unmap>
  801a61:	83 c4 10             	add    $0x10,%esp
    err:
	return r;
}
  801a64:	89 d8                	mov    %ebx,%eax
  801a66:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a69:	5b                   	pop    %ebx
  801a6a:	5e                   	pop    %esi
  801a6b:	5f                   	pop    %edi
  801a6c:	c9                   	leave  
  801a6d:	c3                   	ret    

00801a6e <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801a6e:	55                   	push   %ebp
  801a6f:	89 e5                	mov    %esp,%ebp
  801a71:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801a74:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a77:	50                   	push   %eax
  801a78:	ff 75 08             	pushl  0x8(%ebp)
  801a7b:	e8 87 f4 ff ff       	call   800f07 <fd_lookup>
  801a80:	83 c4 10             	add    $0x10,%esp
  801a83:	85 c0                	test   %eax,%eax
  801a85:	78 18                	js     801a9f <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801a87:	83 ec 0c             	sub    $0xc,%esp
  801a8a:	ff 75 f4             	pushl  -0xc(%ebp)
  801a8d:	e8 ea f3 ff ff       	call   800e7c <fd2data>
	return _pipeisclosed(fd, p);
  801a92:	89 c2                	mov    %eax,%edx
  801a94:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a97:	e8 0c fd ff ff       	call   8017a8 <_pipeisclosed>
  801a9c:	83 c4 10             	add    $0x10,%esp
}
  801a9f:	c9                   	leave  
  801aa0:	c3                   	ret    
  801aa1:	00 00                	add    %al,(%eax)
	...

00801aa4 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801aa4:	55                   	push   %ebp
  801aa5:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801aa7:	b8 00 00 00 00       	mov    $0x0,%eax
  801aac:	c9                   	leave  
  801aad:	c3                   	ret    

00801aae <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801aae:	55                   	push   %ebp
  801aaf:	89 e5                	mov    %esp,%ebp
  801ab1:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801ab4:	68 8e 24 80 00       	push   $0x80248e
  801ab9:	ff 75 0c             	pushl  0xc(%ebp)
  801abc:	e8 c1 ed ff ff       	call   800882 <strcpy>
	return 0;
}
  801ac1:	b8 00 00 00 00       	mov    $0x0,%eax
  801ac6:	c9                   	leave  
  801ac7:	c3                   	ret    

00801ac8 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801ac8:	55                   	push   %ebp
  801ac9:	89 e5                	mov    %esp,%ebp
  801acb:	57                   	push   %edi
  801acc:	56                   	push   %esi
  801acd:	53                   	push   %ebx
  801ace:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801ad4:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801ad8:	74 45                	je     801b1f <devcons_write+0x57>
  801ada:	b8 00 00 00 00       	mov    $0x0,%eax
  801adf:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801ae4:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801aea:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801aed:	29 c3                	sub    %eax,%ebx
		if (m > sizeof(buf) - 1)
  801aef:	83 fb 7f             	cmp    $0x7f,%ebx
  801af2:	76 05                	jbe    801af9 <devcons_write+0x31>
			m = sizeof(buf) - 1;
  801af4:	bb 7f 00 00 00       	mov    $0x7f,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  801af9:	83 ec 04             	sub    $0x4,%esp
  801afc:	53                   	push   %ebx
  801afd:	03 45 0c             	add    0xc(%ebp),%eax
  801b00:	50                   	push   %eax
  801b01:	57                   	push   %edi
  801b02:	e8 3c ef ff ff       	call   800a43 <memmove>
		sys_cputs(buf, m);
  801b07:	83 c4 08             	add    $0x8,%esp
  801b0a:	53                   	push   %ebx
  801b0b:	57                   	push   %edi
  801b0c:	e8 3c f1 ff ff       	call   800c4d <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801b11:	01 de                	add    %ebx,%esi
  801b13:	89 f0                	mov    %esi,%eax
  801b15:	83 c4 10             	add    $0x10,%esp
  801b18:	3b 75 10             	cmp    0x10(%ebp),%esi
  801b1b:	72 cd                	jb     801aea <devcons_write+0x22>
  801b1d:	eb 05                	jmp    801b24 <devcons_write+0x5c>
  801b1f:	be 00 00 00 00       	mov    $0x0,%esi
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801b24:	89 f0                	mov    %esi,%eax
  801b26:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b29:	5b                   	pop    %ebx
  801b2a:	5e                   	pop    %esi
  801b2b:	5f                   	pop    %edi
  801b2c:	c9                   	leave  
  801b2d:	c3                   	ret    

00801b2e <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801b2e:	55                   	push   %ebp
  801b2f:	89 e5                	mov    %esp,%ebp
  801b31:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  801b34:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801b38:	75 07                	jne    801b41 <devcons_read+0x13>
  801b3a:	eb 25                	jmp    801b61 <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801b3c:	e8 9c f1 ff ff       	call   800cdd <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801b41:	e8 2d f1 ff ff       	call   800c73 <sys_cgetc>
  801b46:	85 c0                	test   %eax,%eax
  801b48:	74 f2                	je     801b3c <devcons_read+0xe>
  801b4a:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  801b4c:	85 c0                	test   %eax,%eax
  801b4e:	78 1d                	js     801b6d <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801b50:	83 f8 04             	cmp    $0x4,%eax
  801b53:	74 13                	je     801b68 <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  801b55:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b58:	88 10                	mov    %dl,(%eax)
	return 1;
  801b5a:	b8 01 00 00 00       	mov    $0x1,%eax
  801b5f:	eb 0c                	jmp    801b6d <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  801b61:	b8 00 00 00 00       	mov    $0x0,%eax
  801b66:	eb 05                	jmp    801b6d <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801b68:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801b6d:	c9                   	leave  
  801b6e:	c3                   	ret    

00801b6f <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801b6f:	55                   	push   %ebp
  801b70:	89 e5                	mov    %esp,%ebp
  801b72:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801b75:	8b 45 08             	mov    0x8(%ebp),%eax
  801b78:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801b7b:	6a 01                	push   $0x1
  801b7d:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801b80:	50                   	push   %eax
  801b81:	e8 c7 f0 ff ff       	call   800c4d <sys_cputs>
  801b86:	83 c4 10             	add    $0x10,%esp
}
  801b89:	c9                   	leave  
  801b8a:	c3                   	ret    

00801b8b <getchar>:

int
getchar(void)
{
  801b8b:	55                   	push   %ebp
  801b8c:	89 e5                	mov    %esp,%ebp
  801b8e:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801b91:	6a 01                	push   $0x1
  801b93:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801b96:	50                   	push   %eax
  801b97:	6a 00                	push   $0x0
  801b99:	e8 ea f5 ff ff       	call   801188 <read>
	if (r < 0)
  801b9e:	83 c4 10             	add    $0x10,%esp
  801ba1:	85 c0                	test   %eax,%eax
  801ba3:	78 0f                	js     801bb4 <getchar+0x29>
		return r;
	if (r < 1)
  801ba5:	85 c0                	test   %eax,%eax
  801ba7:	7e 06                	jle    801baf <getchar+0x24>
		return -E_EOF;
	return c;
  801ba9:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801bad:	eb 05                	jmp    801bb4 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801baf:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801bb4:	c9                   	leave  
  801bb5:	c3                   	ret    

00801bb6 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801bb6:	55                   	push   %ebp
  801bb7:	89 e5                	mov    %esp,%ebp
  801bb9:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801bbc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801bbf:	50                   	push   %eax
  801bc0:	ff 75 08             	pushl  0x8(%ebp)
  801bc3:	e8 3f f3 ff ff       	call   800f07 <fd_lookup>
  801bc8:	83 c4 10             	add    $0x10,%esp
  801bcb:	85 c0                	test   %eax,%eax
  801bcd:	78 11                	js     801be0 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801bcf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801bd2:	8b 15 40 30 80 00    	mov    0x803040,%edx
  801bd8:	39 10                	cmp    %edx,(%eax)
  801bda:	0f 94 c0             	sete   %al
  801bdd:	0f b6 c0             	movzbl %al,%eax
}
  801be0:	c9                   	leave  
  801be1:	c3                   	ret    

00801be2 <opencons>:

int
opencons(void)
{
  801be2:	55                   	push   %ebp
  801be3:	89 e5                	mov    %esp,%ebp
  801be5:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801be8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801beb:	50                   	push   %eax
  801bec:	e8 a3 f2 ff ff       	call   800e94 <fd_alloc>
  801bf1:	83 c4 10             	add    $0x10,%esp
  801bf4:	85 c0                	test   %eax,%eax
  801bf6:	78 3a                	js     801c32 <opencons+0x50>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801bf8:	83 ec 04             	sub    $0x4,%esp
  801bfb:	68 07 04 00 00       	push   $0x407
  801c00:	ff 75 f4             	pushl  -0xc(%ebp)
  801c03:	6a 00                	push   $0x0
  801c05:	e8 fa f0 ff ff       	call   800d04 <sys_page_alloc>
  801c0a:	83 c4 10             	add    $0x10,%esp
  801c0d:	85 c0                	test   %eax,%eax
  801c0f:	78 21                	js     801c32 <opencons+0x50>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801c11:	8b 15 40 30 80 00    	mov    0x803040,%edx
  801c17:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c1a:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801c1c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c1f:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801c26:	83 ec 0c             	sub    $0xc,%esp
  801c29:	50                   	push   %eax
  801c2a:	e8 3d f2 ff ff       	call   800e6c <fd2num>
  801c2f:	83 c4 10             	add    $0x10,%esp
}
  801c32:	c9                   	leave  
  801c33:	c3                   	ret    

00801c34 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801c34:	55                   	push   %ebp
  801c35:	89 e5                	mov    %esp,%ebp
  801c37:	56                   	push   %esi
  801c38:	53                   	push   %ebx
  801c39:	8b 75 08             	mov    0x8(%ebp),%esi
  801c3c:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c3f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// cprintf("0x%x 0x%x 0x%x\n", (uint32_t)from_env_store, (uint32_t)pg, (uint32_t)perm_store);
	int r;
	if (pg != NULL) {
  801c42:	85 c0                	test   %eax,%eax
  801c44:	74 0e                	je     801c54 <ipc_recv+0x20>
		r = sys_ipc_recv(pg);
  801c46:	83 ec 0c             	sub    $0xc,%esp
  801c49:	50                   	push   %eax
  801c4a:	e8 b0 f1 ff ff       	call   800dff <sys_ipc_recv>
  801c4f:	83 c4 10             	add    $0x10,%esp
  801c52:	eb 10                	jmp    801c64 <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv((void *)UTOP);
  801c54:	83 ec 0c             	sub    $0xc,%esp
  801c57:	68 00 00 c0 ee       	push   $0xeec00000
  801c5c:	e8 9e f1 ff ff       	call   800dff <sys_ipc_recv>
  801c61:	83 c4 10             	add    $0x10,%esp
	}

	if (r == 0) {
  801c64:	85 c0                	test   %eax,%eax
  801c66:	75 26                	jne    801c8e <ipc_recv+0x5a>
		if (from_env_store != NULL) *from_env_store = thisenv->env_ipc_from;
  801c68:	85 f6                	test   %esi,%esi
  801c6a:	74 0a                	je     801c76 <ipc_recv+0x42>
  801c6c:	a1 08 40 80 00       	mov    0x804008,%eax
  801c71:	8b 40 74             	mov    0x74(%eax),%eax
  801c74:	89 06                	mov    %eax,(%esi)
		if (perm_store != NULL) *perm_store = thisenv->env_ipc_perm;
  801c76:	85 db                	test   %ebx,%ebx
  801c78:	74 0a                	je     801c84 <ipc_recv+0x50>
  801c7a:	a1 08 40 80 00       	mov    0x804008,%eax
  801c7f:	8b 40 78             	mov    0x78(%eax),%eax
  801c82:	89 03                	mov    %eax,(%ebx)
		return thisenv->env_ipc_value;
  801c84:	a1 08 40 80 00       	mov    0x804008,%eax
  801c89:	8b 40 70             	mov    0x70(%eax),%eax
  801c8c:	eb 14                	jmp    801ca2 <ipc_recv+0x6e>
	} else {
		// fails;
		if (from_env_store != NULL) *from_env_store = 0;
  801c8e:	85 f6                	test   %esi,%esi
  801c90:	74 06                	je     801c98 <ipc_recv+0x64>
  801c92:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if (perm_store != NULL) *perm_store = 0;
  801c98:	85 db                	test   %ebx,%ebx
  801c9a:	74 06                	je     801ca2 <ipc_recv+0x6e>
  801c9c:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		return r;
	}
}
  801ca2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ca5:	5b                   	pop    %ebx
  801ca6:	5e                   	pop    %esi
  801ca7:	c9                   	leave  
  801ca8:	c3                   	ret    

00801ca9 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801ca9:	55                   	push   %ebp
  801caa:	89 e5                	mov    %esp,%ebp
  801cac:	57                   	push   %edi
  801cad:	56                   	push   %esi
  801cae:	53                   	push   %ebx
  801caf:	83 ec 0c             	sub    $0xc,%esp
  801cb2:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801cb5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801cb8:	8b 75 14             	mov    0x14(%ebp),%esi
	// LAB 4: Your code here.
	// int sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
	int r;
	if (pg == NULL) pg = (void *)UTOP;
  801cbb:	85 db                	test   %ebx,%ebx
  801cbd:	75 25                	jne    801ce4 <ipc_send+0x3b>
  801cbf:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
  801cc4:	eb 1e                	jmp    801ce4 <ipc_send+0x3b>
	
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) != 0) {
		if (r == -E_IPC_NOT_RECV) {
  801cc6:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801cc9:	75 07                	jne    801cd2 <ipc_send+0x29>
			// cprintf("Try Again and Again....\n");
			sys_yield();
  801ccb:	e8 0d f0 ff ff       	call   800cdd <sys_yield>
  801cd0:	eb 12                	jmp    801ce4 <ipc_send+0x3b>
		} else {
			panic("ipc_send error %e\n", r);
  801cd2:	50                   	push   %eax
  801cd3:	68 9a 24 80 00       	push   $0x80249a
  801cd8:	6a 43                	push   $0x43
  801cda:	68 ad 24 80 00       	push   $0x8024ad
  801cdf:	e8 10 e5 ff ff       	call   8001f4 <_panic>
	// LAB 4: Your code here.
	// int sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
	int r;
	if (pg == NULL) pg = (void *)UTOP;
	
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) != 0) {
  801ce4:	56                   	push   %esi
  801ce5:	53                   	push   %ebx
  801ce6:	57                   	push   %edi
  801ce7:	ff 75 08             	pushl  0x8(%ebp)
  801cea:	e8 eb f0 ff ff       	call   800dda <sys_ipc_try_send>
  801cef:	83 c4 10             	add    $0x10,%esp
  801cf2:	85 c0                	test   %eax,%eax
  801cf4:	75 d0                	jne    801cc6 <ipc_send+0x1d>
		} else {
			panic("ipc_send error %e\n", r);
		}
	}
	return;
}
  801cf6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801cf9:	5b                   	pop    %ebx
  801cfa:	5e                   	pop    %esi
  801cfb:	5f                   	pop    %edi
  801cfc:	c9                   	leave  
  801cfd:	c3                   	ret    

00801cfe <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801cfe:	55                   	push   %ebp
  801cff:	89 e5                	mov    %esp,%ebp
  801d01:	53                   	push   %ebx
  801d02:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  801d05:	39 1d 50 00 c0 ee    	cmp    %ebx,0xeec00050
  801d0b:	74 22                	je     801d2f <ipc_find_env+0x31>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801d0d:	b8 01 00 00 00       	mov    $0x1,%eax
		if (envs[i].env_type == type)
  801d12:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  801d19:	89 c2                	mov    %eax,%edx
  801d1b:	c1 e2 07             	shl    $0x7,%edx
  801d1e:	29 ca                	sub    %ecx,%edx
  801d20:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801d26:	8b 52 50             	mov    0x50(%edx),%edx
  801d29:	39 da                	cmp    %ebx,%edx
  801d2b:	75 1d                	jne    801d4a <ipc_find_env+0x4c>
  801d2d:	eb 05                	jmp    801d34 <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801d2f:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
			return envs[i].env_id;
  801d34:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  801d3b:	c1 e0 07             	shl    $0x7,%eax
  801d3e:	29 d0                	sub    %edx,%eax
  801d40:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  801d45:	8b 40 40             	mov    0x40(%eax),%eax
  801d48:	eb 0c                	jmp    801d56 <ipc_find_env+0x58>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801d4a:	40                   	inc    %eax
  801d4b:	3d 00 04 00 00       	cmp    $0x400,%eax
  801d50:	75 c0                	jne    801d12 <ipc_find_env+0x14>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801d52:	66 b8 00 00          	mov    $0x0,%ax
}
  801d56:	5b                   	pop    %ebx
  801d57:	c9                   	leave  
  801d58:	c3                   	ret    
  801d59:	00 00                	add    %al,(%eax)
	...

00801d5c <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801d5c:	55                   	push   %ebp
  801d5d:	89 e5                	mov    %esp,%ebp
  801d5f:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801d62:	89 c2                	mov    %eax,%edx
  801d64:	c1 ea 16             	shr    $0x16,%edx
  801d67:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801d6e:	f6 c2 01             	test   $0x1,%dl
  801d71:	74 1e                	je     801d91 <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  801d73:	c1 e8 0c             	shr    $0xc,%eax
  801d76:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801d7d:	a8 01                	test   $0x1,%al
  801d7f:	74 17                	je     801d98 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801d81:	c1 e8 0c             	shr    $0xc,%eax
  801d84:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  801d8b:	ef 
  801d8c:	0f b7 c0             	movzwl %ax,%eax
  801d8f:	eb 0c                	jmp    801d9d <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  801d91:	b8 00 00 00 00       	mov    $0x0,%eax
  801d96:	eb 05                	jmp    801d9d <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  801d98:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  801d9d:	c9                   	leave  
  801d9e:	c3                   	ret    
	...

00801da0 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  801da0:	55                   	push   %ebp
  801da1:	89 e5                	mov    %esp,%ebp
  801da3:	57                   	push   %edi
  801da4:	56                   	push   %esi
  801da5:	83 ec 10             	sub    $0x10,%esp
  801da8:	8b 7d 08             	mov    0x8(%ebp),%edi
  801dab:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  801dae:	89 7d f0             	mov    %edi,-0x10(%ebp)
  801db1:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  801db4:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  801db7:	8b 45 14             	mov    0x14(%ebp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  801dba:	85 c0                	test   %eax,%eax
  801dbc:	75 2e                	jne    801dec <__udivdi3+0x4c>
    {
      if (d0 > n1)
  801dbe:	39 f1                	cmp    %esi,%ecx
  801dc0:	77 5a                	ja     801e1c <__udivdi3+0x7c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  801dc2:	85 c9                	test   %ecx,%ecx
  801dc4:	75 0b                	jne    801dd1 <__udivdi3+0x31>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  801dc6:	b8 01 00 00 00       	mov    $0x1,%eax
  801dcb:	31 d2                	xor    %edx,%edx
  801dcd:	f7 f1                	div    %ecx
  801dcf:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  801dd1:	31 d2                	xor    %edx,%edx
  801dd3:	89 f0                	mov    %esi,%eax
  801dd5:	f7 f1                	div    %ecx
  801dd7:	89 c6                	mov    %eax,%esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801dd9:	89 f8                	mov    %edi,%eax
  801ddb:	f7 f1                	div    %ecx
  801ddd:	89 c7                	mov    %eax,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801ddf:	89 f8                	mov    %edi,%eax
  801de1:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801de3:	83 c4 10             	add    $0x10,%esp
  801de6:	5e                   	pop    %esi
  801de7:	5f                   	pop    %edi
  801de8:	c9                   	leave  
  801de9:	c3                   	ret    
  801dea:	66 90                	xchg   %ax,%ax
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801dec:	39 f0                	cmp    %esi,%eax
  801dee:	77 1c                	ja     801e0c <__udivdi3+0x6c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  801df0:	0f bd f8             	bsr    %eax,%edi
	  if (bm == 0)
  801df3:	83 f7 1f             	xor    $0x1f,%edi
  801df6:	75 3c                	jne    801e34 <__udivdi3+0x94>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801df8:	39 f0                	cmp    %esi,%eax
  801dfa:	0f 82 90 00 00 00    	jb     801e90 <__udivdi3+0xf0>
  801e00:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801e03:	39 55 f4             	cmp    %edx,-0xc(%ebp)
  801e06:	0f 86 84 00 00 00    	jbe    801e90 <__udivdi3+0xf0>
  801e0c:	31 f6                	xor    %esi,%esi
  801e0e:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801e10:	89 f8                	mov    %edi,%eax
  801e12:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801e14:	83 c4 10             	add    $0x10,%esp
  801e17:	5e                   	pop    %esi
  801e18:	5f                   	pop    %edi
  801e19:	c9                   	leave  
  801e1a:	c3                   	ret    
  801e1b:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801e1c:	89 f2                	mov    %esi,%edx
  801e1e:	89 f8                	mov    %edi,%eax
  801e20:	f7 f1                	div    %ecx
  801e22:	89 c7                	mov    %eax,%edi
  801e24:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801e26:	89 f8                	mov    %edi,%eax
  801e28:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801e2a:	83 c4 10             	add    $0x10,%esp
  801e2d:	5e                   	pop    %esi
  801e2e:	5f                   	pop    %edi
  801e2f:	c9                   	leave  
  801e30:	c3                   	ret    
  801e31:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  801e34:	89 f9                	mov    %edi,%ecx
  801e36:	d3 e0                	shl    %cl,%eax
  801e38:	89 45 e8             	mov    %eax,-0x18(%ebp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  801e3b:	b8 20 00 00 00       	mov    $0x20,%eax
  801e40:	29 f8                	sub    %edi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  801e42:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801e45:	88 c1                	mov    %al,%cl
  801e47:	d3 ea                	shr    %cl,%edx
  801e49:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  801e4c:	09 ca                	or     %ecx,%edx
  801e4e:	89 55 ec             	mov    %edx,-0x14(%ebp)
	      d0 = d0 << bm;
  801e51:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801e54:	89 f9                	mov    %edi,%ecx
  801e56:	d3 e2                	shl    %cl,%edx
  801e58:	89 55 f4             	mov    %edx,-0xc(%ebp)
	      n2 = n1 >> b;
  801e5b:	89 f2                	mov    %esi,%edx
  801e5d:	88 c1                	mov    %al,%cl
  801e5f:	d3 ea                	shr    %cl,%edx
  801e61:	89 55 e8             	mov    %edx,-0x18(%ebp)
	      n1 = (n1 << bm) | (n0 >> b);
  801e64:	89 f2                	mov    %esi,%edx
  801e66:	89 f9                	mov    %edi,%ecx
  801e68:	d3 e2                	shl    %cl,%edx
  801e6a:	8b 75 f0             	mov    -0x10(%ebp),%esi
  801e6d:	88 c1                	mov    %al,%cl
  801e6f:	d3 ee                	shr    %cl,%esi
  801e71:	09 d6                	or     %edx,%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  801e73:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  801e76:	89 f0                	mov    %esi,%eax
  801e78:	89 ca                	mov    %ecx,%edx
  801e7a:	f7 75 ec             	divl   -0x14(%ebp)
  801e7d:	89 d1                	mov    %edx,%ecx
  801e7f:	89 c6                	mov    %eax,%esi
	      umul_ppmm (m1, m0, q0, d0);
  801e81:	f7 65 f4             	mull   -0xc(%ebp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801e84:	39 d1                	cmp    %edx,%ecx
  801e86:	72 28                	jb     801eb0 <__udivdi3+0x110>
  801e88:	74 1a                	je     801ea4 <__udivdi3+0x104>
  801e8a:	89 f7                	mov    %esi,%edi
  801e8c:	31 f6                	xor    %esi,%esi
  801e8e:	eb 80                	jmp    801e10 <__udivdi3+0x70>
	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  801e90:	31 f6                	xor    %esi,%esi
  801e92:	bf 01 00 00 00       	mov    $0x1,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801e97:	89 f8                	mov    %edi,%eax
  801e99:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801e9b:	83 c4 10             	add    $0x10,%esp
  801e9e:	5e                   	pop    %esi
  801e9f:	5f                   	pop    %edi
  801ea0:	c9                   	leave  
  801ea1:	c3                   	ret    
  801ea2:	66 90                	xchg   %ax,%ax

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  801ea4:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801ea7:	89 f9                	mov    %edi,%ecx
  801ea9:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801eab:	39 c2                	cmp    %eax,%edx
  801ead:	73 db                	jae    801e8a <__udivdi3+0xea>
  801eaf:	90                   	nop
		{
		  q0--;
  801eb0:	8d 7e ff             	lea    -0x1(%esi),%edi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  801eb3:	31 f6                	xor    %esi,%esi
  801eb5:	e9 56 ff ff ff       	jmp    801e10 <__udivdi3+0x70>
	...

00801ebc <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  801ebc:	55                   	push   %ebp
  801ebd:	89 e5                	mov    %esp,%ebp
  801ebf:	57                   	push   %edi
  801ec0:	56                   	push   %esi
  801ec1:	83 ec 20             	sub    $0x20,%esp
  801ec4:	8b 45 08             	mov    0x8(%ebp),%eax
  801ec7:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  801eca:	89 45 e8             	mov    %eax,-0x18(%ebp)
  801ecd:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  801ed0:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  801ed3:	8b 7d 14             	mov    0x14(%ebp),%edi
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  801ed6:	89 45 f0             	mov    %eax,-0x10(%ebp)
  n1 = nn.s.high;
  801ed9:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  801edb:	85 ff                	test   %edi,%edi
  801edd:	75 15                	jne    801ef4 <__umoddi3+0x38>
    {
      if (d0 > n1)
  801edf:	39 f1                	cmp    %esi,%ecx
  801ee1:	0f 86 99 00 00 00    	jbe    801f80 <__umoddi3+0xc4>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801ee7:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  801ee9:	89 d0                	mov    %edx,%eax
  801eeb:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801eed:	83 c4 20             	add    $0x20,%esp
  801ef0:	5e                   	pop    %esi
  801ef1:	5f                   	pop    %edi
  801ef2:	c9                   	leave  
  801ef3:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801ef4:	39 f7                	cmp    %esi,%edi
  801ef6:	0f 87 a4 00 00 00    	ja     801fa0 <__umoddi3+0xe4>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  801efc:	0f bd c7             	bsr    %edi,%eax
	  if (bm == 0)
  801eff:	83 f0 1f             	xor    $0x1f,%eax
  801f02:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801f05:	0f 84 a1 00 00 00    	je     801fac <__umoddi3+0xf0>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  801f0b:	89 f8                	mov    %edi,%eax
  801f0d:	8a 4d ec             	mov    -0x14(%ebp),%cl
  801f10:	d3 e0                	shl    %cl,%eax
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  801f12:	bf 20 00 00 00       	mov    $0x20,%edi
  801f17:	2b 7d ec             	sub    -0x14(%ebp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  801f1a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801f1d:	89 f9                	mov    %edi,%ecx
  801f1f:	d3 ea                	shr    %cl,%edx
  801f21:	09 c2                	or     %eax,%edx
  801f23:	89 55 f0             	mov    %edx,-0x10(%ebp)
	      d0 = d0 << bm;
  801f26:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f29:	8a 4d ec             	mov    -0x14(%ebp),%cl
  801f2c:	d3 e0                	shl    %cl,%eax
  801f2e:	89 45 f4             	mov    %eax,-0xc(%ebp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  801f31:	89 f2                	mov    %esi,%edx
  801f33:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  801f35:	8b 45 e8             	mov    -0x18(%ebp),%eax
  801f38:	d3 e0                	shl    %cl,%eax
  801f3a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  801f3d:	8b 45 e8             	mov    -0x18(%ebp),%eax
  801f40:	89 f9                	mov    %edi,%ecx
  801f42:	d3 e8                	shr    %cl,%eax
  801f44:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  801f46:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  801f48:	89 f2                	mov    %esi,%edx
  801f4a:	f7 75 f0             	divl   -0x10(%ebp)
  801f4d:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  801f4f:	f7 65 f4             	mull   -0xc(%ebp)
  801f52:	89 55 e8             	mov    %edx,-0x18(%ebp)
  801f55:	89 c1                	mov    %eax,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801f57:	39 d6                	cmp    %edx,%esi
  801f59:	72 71                	jb     801fcc <__umoddi3+0x110>
  801f5b:	74 7f                	je     801fdc <__umoddi3+0x120>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  801f5d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801f60:	29 c8                	sub    %ecx,%eax
  801f62:	19 d6                	sbb    %edx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  801f64:	8a 4d ec             	mov    -0x14(%ebp),%cl
  801f67:	d3 e8                	shr    %cl,%eax
  801f69:	89 f2                	mov    %esi,%edx
  801f6b:	89 f9                	mov    %edi,%ecx
  801f6d:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  801f6f:	09 d0                	or     %edx,%eax
  801f71:	89 f2                	mov    %esi,%edx
  801f73:	8a 4d ec             	mov    -0x14(%ebp),%cl
  801f76:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801f78:	83 c4 20             	add    $0x20,%esp
  801f7b:	5e                   	pop    %esi
  801f7c:	5f                   	pop    %edi
  801f7d:	c9                   	leave  
  801f7e:	c3                   	ret    
  801f7f:	90                   	nop
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  801f80:	85 c9                	test   %ecx,%ecx
  801f82:	75 0b                	jne    801f8f <__umoddi3+0xd3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  801f84:	b8 01 00 00 00       	mov    $0x1,%eax
  801f89:	31 d2                	xor    %edx,%edx
  801f8b:	f7 f1                	div    %ecx
  801f8d:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  801f8f:	89 f0                	mov    %esi,%eax
  801f91:	31 d2                	xor    %edx,%edx
  801f93:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801f95:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801f98:	f7 f1                	div    %ecx
  801f9a:	e9 4a ff ff ff       	jmp    801ee9 <__umoddi3+0x2d>
  801f9f:	90                   	nop
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  801fa0:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801fa2:	83 c4 20             	add    $0x20,%esp
  801fa5:	5e                   	pop    %esi
  801fa6:	5f                   	pop    %edi
  801fa7:	c9                   	leave  
  801fa8:	c3                   	ret    
  801fa9:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801fac:	39 f7                	cmp    %esi,%edi
  801fae:	72 05                	jb     801fb5 <__umoddi3+0xf9>
  801fb0:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
  801fb3:	77 0c                	ja     801fc1 <__umoddi3+0x105>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  801fb5:	89 f2                	mov    %esi,%edx
  801fb7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801fba:	29 c8                	sub    %ecx,%eax
  801fbc:	19 fa                	sbb    %edi,%edx
  801fbe:	89 45 f0             	mov    %eax,-0x10(%ebp)

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  801fc1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801fc4:	83 c4 20             	add    $0x20,%esp
  801fc7:	5e                   	pop    %esi
  801fc8:	5f                   	pop    %edi
  801fc9:	c9                   	leave  
  801fca:	c3                   	ret    
  801fcb:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  801fcc:	8b 55 e8             	mov    -0x18(%ebp),%edx
  801fcf:	89 c1                	mov    %eax,%ecx
  801fd1:	2b 4d f4             	sub    -0xc(%ebp),%ecx
  801fd4:	1b 55 f0             	sbb    -0x10(%ebp),%edx
  801fd7:	eb 84                	jmp    801f5d <__umoddi3+0xa1>
  801fd9:	8d 76 00             	lea    0x0(%esi),%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801fdc:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801fdf:	72 eb                	jb     801fcc <__umoddi3+0x110>
  801fe1:	89 f2                	mov    %esi,%edx
  801fe3:	e9 75 ff ff ff       	jmp    801f5d <__umoddi3+0xa1>
