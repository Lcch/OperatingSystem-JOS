
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
  800050:	e8 9f 11 00 00       	call   8011f4 <write>
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
  800080:	e8 93 10 00 00       	call   801118 <read>
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
  8000f5:	e8 35 14 00 00       	call   80152f <open>
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
  80010f:	e8 b4 15 00 00       	call   8016c8 <printf>
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
  800128:	e8 ae 0e 00 00       	call   800fdb <close>
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
  800196:	e8 6b 0e 00 00       	call   801006 <close_all>
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
  8001ca:	68 44 20 80 00       	push   $0x802044
  8001cf:	e8 b0 00 00 00       	call   800284 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8001d4:	83 c4 18             	add    $0x18,%esp
  8001d7:	56                   	push   %esi
  8001d8:	ff 75 10             	pushl  0x10(%ebp)
  8001db:	e8 53 00 00 00       	call   800233 <vcprintf>
	cprintf("\n");
  8001e0:	c7 04 24 59 24 80 00 	movl   $0x802459,(%esp)
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
  8002ec:	e8 8f 1a 00 00       	call   801d80 <__udivdi3>
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
  800328:	e8 6f 1b 00 00       	call   801e9c <__umoddi3>
  80032d:	83 c4 14             	add    $0x14,%esp
  800330:	0f be 80 67 20 80 00 	movsbl 0x802067(%eax),%eax
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
  800474:	ff 24 85 a0 21 80 00 	jmp    *0x8021a0(,%eax,4)
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
  800520:	8b 04 85 00 23 80 00 	mov    0x802300(,%eax,4),%eax
  800527:	85 c0                	test   %eax,%eax
  800529:	75 1a                	jne    800545 <vprintfmt+0x15c>
				printfmt(putch, putdat, "error %d", err);
  80052b:	52                   	push   %edx
  80052c:	68 7f 20 80 00       	push   $0x80207f
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
  800546:	68 3b 24 80 00       	push   $0x80243b
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
  80057c:	c7 45 d0 78 20 80 00 	movl   $0x802078,-0x30(%ebp)
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
  800bea:	68 5f 23 80 00       	push   $0x80235f
  800bef:	6a 42                	push   $0x42
  800bf1:	68 7c 23 80 00       	push   $0x80237c
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

00800dfc <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800dfc:	55                   	push   %ebp
  800dfd:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800dff:	8b 45 08             	mov    0x8(%ebp),%eax
  800e02:	05 00 00 00 30       	add    $0x30000000,%eax
  800e07:	c1 e8 0c             	shr    $0xc,%eax
}
  800e0a:	c9                   	leave  
  800e0b:	c3                   	ret    

00800e0c <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800e0c:	55                   	push   %ebp
  800e0d:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800e0f:	ff 75 08             	pushl  0x8(%ebp)
  800e12:	e8 e5 ff ff ff       	call   800dfc <fd2num>
  800e17:	83 c4 04             	add    $0x4,%esp
  800e1a:	05 20 00 0d 00       	add    $0xd0020,%eax
  800e1f:	c1 e0 0c             	shl    $0xc,%eax
}
  800e22:	c9                   	leave  
  800e23:	c3                   	ret    

00800e24 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800e24:	55                   	push   %ebp
  800e25:	89 e5                	mov    %esp,%ebp
  800e27:	53                   	push   %ebx
  800e28:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800e2b:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  800e30:	a8 01                	test   $0x1,%al
  800e32:	74 34                	je     800e68 <fd_alloc+0x44>
  800e34:	a1 00 00 74 ef       	mov    0xef740000,%eax
  800e39:	a8 01                	test   $0x1,%al
  800e3b:	74 32                	je     800e6f <fd_alloc+0x4b>
  800e3d:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
  800e42:	89 c1                	mov    %eax,%ecx
  800e44:	89 c2                	mov    %eax,%edx
  800e46:	c1 ea 16             	shr    $0x16,%edx
  800e49:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800e50:	f6 c2 01             	test   $0x1,%dl
  800e53:	74 1f                	je     800e74 <fd_alloc+0x50>
  800e55:	89 c2                	mov    %eax,%edx
  800e57:	c1 ea 0c             	shr    $0xc,%edx
  800e5a:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e61:	f6 c2 01             	test   $0x1,%dl
  800e64:	75 17                	jne    800e7d <fd_alloc+0x59>
  800e66:	eb 0c                	jmp    800e74 <fd_alloc+0x50>
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  800e68:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
  800e6d:	eb 05                	jmp    800e74 <fd_alloc+0x50>
  800e6f:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
  800e74:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  800e76:	b8 00 00 00 00       	mov    $0x0,%eax
  800e7b:	eb 17                	jmp    800e94 <fd_alloc+0x70>
  800e7d:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800e82:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800e87:	75 b9                	jne    800e42 <fd_alloc+0x1e>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800e89:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  800e8f:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800e94:	5b                   	pop    %ebx
  800e95:	c9                   	leave  
  800e96:	c3                   	ret    

00800e97 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800e97:	55                   	push   %ebp
  800e98:	89 e5                	mov    %esp,%ebp
  800e9a:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800e9d:	83 f8 1f             	cmp    $0x1f,%eax
  800ea0:	77 36                	ja     800ed8 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800ea2:	05 00 00 0d 00       	add    $0xd0000,%eax
  800ea7:	c1 e0 0c             	shl    $0xc,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800eaa:	89 c2                	mov    %eax,%edx
  800eac:	c1 ea 16             	shr    $0x16,%edx
  800eaf:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800eb6:	f6 c2 01             	test   $0x1,%dl
  800eb9:	74 24                	je     800edf <fd_lookup+0x48>
  800ebb:	89 c2                	mov    %eax,%edx
  800ebd:	c1 ea 0c             	shr    $0xc,%edx
  800ec0:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800ec7:	f6 c2 01             	test   $0x1,%dl
  800eca:	74 1a                	je     800ee6 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800ecc:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ecf:	89 02                	mov    %eax,(%edx)
	return 0;
  800ed1:	b8 00 00 00 00       	mov    $0x0,%eax
  800ed6:	eb 13                	jmp    800eeb <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800ed8:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800edd:	eb 0c                	jmp    800eeb <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800edf:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800ee4:	eb 05                	jmp    800eeb <fd_lookup+0x54>
  800ee6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800eeb:	c9                   	leave  
  800eec:	c3                   	ret    

00800eed <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800eed:	55                   	push   %ebp
  800eee:	89 e5                	mov    %esp,%ebp
  800ef0:	53                   	push   %ebx
  800ef1:	83 ec 04             	sub    $0x4,%esp
  800ef4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ef7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  800efa:	39 0d 04 30 80 00    	cmp    %ecx,0x803004
  800f00:	74 0d                	je     800f0f <dev_lookup+0x22>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800f02:	b8 00 00 00 00       	mov    $0x0,%eax
  800f07:	eb 14                	jmp    800f1d <dev_lookup+0x30>
		if (devtab[i]->dev_id == dev_id) {
  800f09:	39 0a                	cmp    %ecx,(%edx)
  800f0b:	75 10                	jne    800f1d <dev_lookup+0x30>
  800f0d:	eb 05                	jmp    800f14 <dev_lookup+0x27>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800f0f:	ba 04 30 80 00       	mov    $0x803004,%edx
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
  800f14:	89 13                	mov    %edx,(%ebx)
			return 0;
  800f16:	b8 00 00 00 00       	mov    $0x0,%eax
  800f1b:	eb 31                	jmp    800f4e <dev_lookup+0x61>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800f1d:	40                   	inc    %eax
  800f1e:	8b 14 85 0c 24 80 00 	mov    0x80240c(,%eax,4),%edx
  800f25:	85 d2                	test   %edx,%edx
  800f27:	75 e0                	jne    800f09 <dev_lookup+0x1c>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800f29:	a1 20 60 80 00       	mov    0x806020,%eax
  800f2e:	8b 40 48             	mov    0x48(%eax),%eax
  800f31:	83 ec 04             	sub    $0x4,%esp
  800f34:	51                   	push   %ecx
  800f35:	50                   	push   %eax
  800f36:	68 8c 23 80 00       	push   $0x80238c
  800f3b:	e8 44 f3 ff ff       	call   800284 <cprintf>
	*dev = 0;
  800f40:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  800f46:	83 c4 10             	add    $0x10,%esp
  800f49:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800f4e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f51:	c9                   	leave  
  800f52:	c3                   	ret    

00800f53 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800f53:	55                   	push   %ebp
  800f54:	89 e5                	mov    %esp,%ebp
  800f56:	56                   	push   %esi
  800f57:	53                   	push   %ebx
  800f58:	83 ec 20             	sub    $0x20,%esp
  800f5b:	8b 75 08             	mov    0x8(%ebp),%esi
  800f5e:	8a 45 0c             	mov    0xc(%ebp),%al
  800f61:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800f64:	56                   	push   %esi
  800f65:	e8 92 fe ff ff       	call   800dfc <fd2num>
  800f6a:	8d 55 f4             	lea    -0xc(%ebp),%edx
  800f6d:	89 14 24             	mov    %edx,(%esp)
  800f70:	50                   	push   %eax
  800f71:	e8 21 ff ff ff       	call   800e97 <fd_lookup>
  800f76:	89 c3                	mov    %eax,%ebx
  800f78:	83 c4 08             	add    $0x8,%esp
  800f7b:	85 c0                	test   %eax,%eax
  800f7d:	78 05                	js     800f84 <fd_close+0x31>
	    || fd != fd2)
  800f7f:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800f82:	74 0d                	je     800f91 <fd_close+0x3e>
		return (must_exist ? r : 0);
  800f84:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  800f88:	75 48                	jne    800fd2 <fd_close+0x7f>
  800f8a:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f8f:	eb 41                	jmp    800fd2 <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800f91:	83 ec 08             	sub    $0x8,%esp
  800f94:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800f97:	50                   	push   %eax
  800f98:	ff 36                	pushl  (%esi)
  800f9a:	e8 4e ff ff ff       	call   800eed <dev_lookup>
  800f9f:	89 c3                	mov    %eax,%ebx
  800fa1:	83 c4 10             	add    $0x10,%esp
  800fa4:	85 c0                	test   %eax,%eax
  800fa6:	78 1c                	js     800fc4 <fd_close+0x71>
		if (dev->dev_close)
  800fa8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800fab:	8b 40 10             	mov    0x10(%eax),%eax
  800fae:	85 c0                	test   %eax,%eax
  800fb0:	74 0d                	je     800fbf <fd_close+0x6c>
			r = (*dev->dev_close)(fd);
  800fb2:	83 ec 0c             	sub    $0xc,%esp
  800fb5:	56                   	push   %esi
  800fb6:	ff d0                	call   *%eax
  800fb8:	89 c3                	mov    %eax,%ebx
  800fba:	83 c4 10             	add    $0x10,%esp
  800fbd:	eb 05                	jmp    800fc4 <fd_close+0x71>
		else
			r = 0;
  800fbf:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800fc4:	83 ec 08             	sub    $0x8,%esp
  800fc7:	56                   	push   %esi
  800fc8:	6a 00                	push   $0x0
  800fca:	e8 37 fd ff ff       	call   800d06 <sys_page_unmap>
	return r;
  800fcf:	83 c4 10             	add    $0x10,%esp
}
  800fd2:	89 d8                	mov    %ebx,%eax
  800fd4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800fd7:	5b                   	pop    %ebx
  800fd8:	5e                   	pop    %esi
  800fd9:	c9                   	leave  
  800fda:	c3                   	ret    

00800fdb <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800fdb:	55                   	push   %ebp
  800fdc:	89 e5                	mov    %esp,%ebp
  800fde:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800fe1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fe4:	50                   	push   %eax
  800fe5:	ff 75 08             	pushl  0x8(%ebp)
  800fe8:	e8 aa fe ff ff       	call   800e97 <fd_lookup>
  800fed:	83 c4 08             	add    $0x8,%esp
  800ff0:	85 c0                	test   %eax,%eax
  800ff2:	78 10                	js     801004 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800ff4:	83 ec 08             	sub    $0x8,%esp
  800ff7:	6a 01                	push   $0x1
  800ff9:	ff 75 f4             	pushl  -0xc(%ebp)
  800ffc:	e8 52 ff ff ff       	call   800f53 <fd_close>
  801001:	83 c4 10             	add    $0x10,%esp
}
  801004:	c9                   	leave  
  801005:	c3                   	ret    

00801006 <close_all>:

void
close_all(void)
{
  801006:	55                   	push   %ebp
  801007:	89 e5                	mov    %esp,%ebp
  801009:	53                   	push   %ebx
  80100a:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80100d:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801012:	83 ec 0c             	sub    $0xc,%esp
  801015:	53                   	push   %ebx
  801016:	e8 c0 ff ff ff       	call   800fdb <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80101b:	43                   	inc    %ebx
  80101c:	83 c4 10             	add    $0x10,%esp
  80101f:	83 fb 20             	cmp    $0x20,%ebx
  801022:	75 ee                	jne    801012 <close_all+0xc>
		close(i);
}
  801024:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801027:	c9                   	leave  
  801028:	c3                   	ret    

00801029 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801029:	55                   	push   %ebp
  80102a:	89 e5                	mov    %esp,%ebp
  80102c:	57                   	push   %edi
  80102d:	56                   	push   %esi
  80102e:	53                   	push   %ebx
  80102f:	83 ec 2c             	sub    $0x2c,%esp
  801032:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801035:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801038:	50                   	push   %eax
  801039:	ff 75 08             	pushl  0x8(%ebp)
  80103c:	e8 56 fe ff ff       	call   800e97 <fd_lookup>
  801041:	89 c3                	mov    %eax,%ebx
  801043:	83 c4 08             	add    $0x8,%esp
  801046:	85 c0                	test   %eax,%eax
  801048:	0f 88 c0 00 00 00    	js     80110e <dup+0xe5>
		return r;
	close(newfdnum);
  80104e:	83 ec 0c             	sub    $0xc,%esp
  801051:	57                   	push   %edi
  801052:	e8 84 ff ff ff       	call   800fdb <close>

	newfd = INDEX2FD(newfdnum);
  801057:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  80105d:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  801060:	83 c4 04             	add    $0x4,%esp
  801063:	ff 75 e4             	pushl  -0x1c(%ebp)
  801066:	e8 a1 fd ff ff       	call   800e0c <fd2data>
  80106b:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  80106d:	89 34 24             	mov    %esi,(%esp)
  801070:	e8 97 fd ff ff       	call   800e0c <fd2data>
  801075:	83 c4 10             	add    $0x10,%esp
  801078:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80107b:	89 d8                	mov    %ebx,%eax
  80107d:	c1 e8 16             	shr    $0x16,%eax
  801080:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801087:	a8 01                	test   $0x1,%al
  801089:	74 37                	je     8010c2 <dup+0x99>
  80108b:	89 d8                	mov    %ebx,%eax
  80108d:	c1 e8 0c             	shr    $0xc,%eax
  801090:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801097:	f6 c2 01             	test   $0x1,%dl
  80109a:	74 26                	je     8010c2 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80109c:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8010a3:	83 ec 0c             	sub    $0xc,%esp
  8010a6:	25 07 0e 00 00       	and    $0xe07,%eax
  8010ab:	50                   	push   %eax
  8010ac:	ff 75 d4             	pushl  -0x2c(%ebp)
  8010af:	6a 00                	push   $0x0
  8010b1:	53                   	push   %ebx
  8010b2:	6a 00                	push   $0x0
  8010b4:	e8 27 fc ff ff       	call   800ce0 <sys_page_map>
  8010b9:	89 c3                	mov    %eax,%ebx
  8010bb:	83 c4 20             	add    $0x20,%esp
  8010be:	85 c0                	test   %eax,%eax
  8010c0:	78 2d                	js     8010ef <dup+0xc6>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8010c2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8010c5:	89 c2                	mov    %eax,%edx
  8010c7:	c1 ea 0c             	shr    $0xc,%edx
  8010ca:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8010d1:	83 ec 0c             	sub    $0xc,%esp
  8010d4:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  8010da:	52                   	push   %edx
  8010db:	56                   	push   %esi
  8010dc:	6a 00                	push   $0x0
  8010de:	50                   	push   %eax
  8010df:	6a 00                	push   $0x0
  8010e1:	e8 fa fb ff ff       	call   800ce0 <sys_page_map>
  8010e6:	89 c3                	mov    %eax,%ebx
  8010e8:	83 c4 20             	add    $0x20,%esp
  8010eb:	85 c0                	test   %eax,%eax
  8010ed:	79 1d                	jns    80110c <dup+0xe3>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8010ef:	83 ec 08             	sub    $0x8,%esp
  8010f2:	56                   	push   %esi
  8010f3:	6a 00                	push   $0x0
  8010f5:	e8 0c fc ff ff       	call   800d06 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8010fa:	83 c4 08             	add    $0x8,%esp
  8010fd:	ff 75 d4             	pushl  -0x2c(%ebp)
  801100:	6a 00                	push   $0x0
  801102:	e8 ff fb ff ff       	call   800d06 <sys_page_unmap>
	return r;
  801107:	83 c4 10             	add    $0x10,%esp
  80110a:	eb 02                	jmp    80110e <dup+0xe5>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  80110c:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  80110e:	89 d8                	mov    %ebx,%eax
  801110:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801113:	5b                   	pop    %ebx
  801114:	5e                   	pop    %esi
  801115:	5f                   	pop    %edi
  801116:	c9                   	leave  
  801117:	c3                   	ret    

00801118 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801118:	55                   	push   %ebp
  801119:	89 e5                	mov    %esp,%ebp
  80111b:	53                   	push   %ebx
  80111c:	83 ec 14             	sub    $0x14,%esp
  80111f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801122:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801125:	50                   	push   %eax
  801126:	53                   	push   %ebx
  801127:	e8 6b fd ff ff       	call   800e97 <fd_lookup>
  80112c:	83 c4 08             	add    $0x8,%esp
  80112f:	85 c0                	test   %eax,%eax
  801131:	78 67                	js     80119a <read+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801133:	83 ec 08             	sub    $0x8,%esp
  801136:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801139:	50                   	push   %eax
  80113a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80113d:	ff 30                	pushl  (%eax)
  80113f:	e8 a9 fd ff ff       	call   800eed <dev_lookup>
  801144:	83 c4 10             	add    $0x10,%esp
  801147:	85 c0                	test   %eax,%eax
  801149:	78 4f                	js     80119a <read+0x82>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80114b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80114e:	8b 50 08             	mov    0x8(%eax),%edx
  801151:	83 e2 03             	and    $0x3,%edx
  801154:	83 fa 01             	cmp    $0x1,%edx
  801157:	75 21                	jne    80117a <read+0x62>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801159:	a1 20 60 80 00       	mov    0x806020,%eax
  80115e:	8b 40 48             	mov    0x48(%eax),%eax
  801161:	83 ec 04             	sub    $0x4,%esp
  801164:	53                   	push   %ebx
  801165:	50                   	push   %eax
  801166:	68 d0 23 80 00       	push   $0x8023d0
  80116b:	e8 14 f1 ff ff       	call   800284 <cprintf>
		return -E_INVAL;
  801170:	83 c4 10             	add    $0x10,%esp
  801173:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801178:	eb 20                	jmp    80119a <read+0x82>
	}
	if (!dev->dev_read)
  80117a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80117d:	8b 52 08             	mov    0x8(%edx),%edx
  801180:	85 d2                	test   %edx,%edx
  801182:	74 11                	je     801195 <read+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801184:	83 ec 04             	sub    $0x4,%esp
  801187:	ff 75 10             	pushl  0x10(%ebp)
  80118a:	ff 75 0c             	pushl  0xc(%ebp)
  80118d:	50                   	push   %eax
  80118e:	ff d2                	call   *%edx
  801190:	83 c4 10             	add    $0x10,%esp
  801193:	eb 05                	jmp    80119a <read+0x82>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801195:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  80119a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80119d:	c9                   	leave  
  80119e:	c3                   	ret    

0080119f <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80119f:	55                   	push   %ebp
  8011a0:	89 e5                	mov    %esp,%ebp
  8011a2:	57                   	push   %edi
  8011a3:	56                   	push   %esi
  8011a4:	53                   	push   %ebx
  8011a5:	83 ec 0c             	sub    $0xc,%esp
  8011a8:	8b 7d 08             	mov    0x8(%ebp),%edi
  8011ab:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8011ae:	85 f6                	test   %esi,%esi
  8011b0:	74 31                	je     8011e3 <readn+0x44>
  8011b2:	b8 00 00 00 00       	mov    $0x0,%eax
  8011b7:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = read(fdnum, (char*)buf + tot, n - tot);
  8011bc:	83 ec 04             	sub    $0x4,%esp
  8011bf:	89 f2                	mov    %esi,%edx
  8011c1:	29 c2                	sub    %eax,%edx
  8011c3:	52                   	push   %edx
  8011c4:	03 45 0c             	add    0xc(%ebp),%eax
  8011c7:	50                   	push   %eax
  8011c8:	57                   	push   %edi
  8011c9:	e8 4a ff ff ff       	call   801118 <read>
		if (m < 0)
  8011ce:	83 c4 10             	add    $0x10,%esp
  8011d1:	85 c0                	test   %eax,%eax
  8011d3:	78 17                	js     8011ec <readn+0x4d>
			return m;
		if (m == 0)
  8011d5:	85 c0                	test   %eax,%eax
  8011d7:	74 11                	je     8011ea <readn+0x4b>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8011d9:	01 c3                	add    %eax,%ebx
  8011db:	89 d8                	mov    %ebx,%eax
  8011dd:	39 f3                	cmp    %esi,%ebx
  8011df:	72 db                	jb     8011bc <readn+0x1d>
  8011e1:	eb 09                	jmp    8011ec <readn+0x4d>
  8011e3:	b8 00 00 00 00       	mov    $0x0,%eax
  8011e8:	eb 02                	jmp    8011ec <readn+0x4d>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  8011ea:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  8011ec:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011ef:	5b                   	pop    %ebx
  8011f0:	5e                   	pop    %esi
  8011f1:	5f                   	pop    %edi
  8011f2:	c9                   	leave  
  8011f3:	c3                   	ret    

008011f4 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8011f4:	55                   	push   %ebp
  8011f5:	89 e5                	mov    %esp,%ebp
  8011f7:	53                   	push   %ebx
  8011f8:	83 ec 14             	sub    $0x14,%esp
  8011fb:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8011fe:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801201:	50                   	push   %eax
  801202:	53                   	push   %ebx
  801203:	e8 8f fc ff ff       	call   800e97 <fd_lookup>
  801208:	83 c4 08             	add    $0x8,%esp
  80120b:	85 c0                	test   %eax,%eax
  80120d:	78 62                	js     801271 <write+0x7d>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80120f:	83 ec 08             	sub    $0x8,%esp
  801212:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801215:	50                   	push   %eax
  801216:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801219:	ff 30                	pushl  (%eax)
  80121b:	e8 cd fc ff ff       	call   800eed <dev_lookup>
  801220:	83 c4 10             	add    $0x10,%esp
  801223:	85 c0                	test   %eax,%eax
  801225:	78 4a                	js     801271 <write+0x7d>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801227:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80122a:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80122e:	75 21                	jne    801251 <write+0x5d>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801230:	a1 20 60 80 00       	mov    0x806020,%eax
  801235:	8b 40 48             	mov    0x48(%eax),%eax
  801238:	83 ec 04             	sub    $0x4,%esp
  80123b:	53                   	push   %ebx
  80123c:	50                   	push   %eax
  80123d:	68 ec 23 80 00       	push   $0x8023ec
  801242:	e8 3d f0 ff ff       	call   800284 <cprintf>
		return -E_INVAL;
  801247:	83 c4 10             	add    $0x10,%esp
  80124a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80124f:	eb 20                	jmp    801271 <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801251:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801254:	8b 52 0c             	mov    0xc(%edx),%edx
  801257:	85 d2                	test   %edx,%edx
  801259:	74 11                	je     80126c <write+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80125b:	83 ec 04             	sub    $0x4,%esp
  80125e:	ff 75 10             	pushl  0x10(%ebp)
  801261:	ff 75 0c             	pushl  0xc(%ebp)
  801264:	50                   	push   %eax
  801265:	ff d2                	call   *%edx
  801267:	83 c4 10             	add    $0x10,%esp
  80126a:	eb 05                	jmp    801271 <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80126c:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  801271:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801274:	c9                   	leave  
  801275:	c3                   	ret    

00801276 <seek>:

int
seek(int fdnum, off_t offset)
{
  801276:	55                   	push   %ebp
  801277:	89 e5                	mov    %esp,%ebp
  801279:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80127c:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80127f:	50                   	push   %eax
  801280:	ff 75 08             	pushl  0x8(%ebp)
  801283:	e8 0f fc ff ff       	call   800e97 <fd_lookup>
  801288:	83 c4 08             	add    $0x8,%esp
  80128b:	85 c0                	test   %eax,%eax
  80128d:	78 0e                	js     80129d <seek+0x27>
		return r;
	fd->fd_offset = offset;
  80128f:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801292:	8b 55 0c             	mov    0xc(%ebp),%edx
  801295:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801298:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80129d:	c9                   	leave  
  80129e:	c3                   	ret    

0080129f <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80129f:	55                   	push   %ebp
  8012a0:	89 e5                	mov    %esp,%ebp
  8012a2:	53                   	push   %ebx
  8012a3:	83 ec 14             	sub    $0x14,%esp
  8012a6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8012a9:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012ac:	50                   	push   %eax
  8012ad:	53                   	push   %ebx
  8012ae:	e8 e4 fb ff ff       	call   800e97 <fd_lookup>
  8012b3:	83 c4 08             	add    $0x8,%esp
  8012b6:	85 c0                	test   %eax,%eax
  8012b8:	78 5f                	js     801319 <ftruncate+0x7a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012ba:	83 ec 08             	sub    $0x8,%esp
  8012bd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012c0:	50                   	push   %eax
  8012c1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012c4:	ff 30                	pushl  (%eax)
  8012c6:	e8 22 fc ff ff       	call   800eed <dev_lookup>
  8012cb:	83 c4 10             	add    $0x10,%esp
  8012ce:	85 c0                	test   %eax,%eax
  8012d0:	78 47                	js     801319 <ftruncate+0x7a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8012d2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012d5:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8012d9:	75 21                	jne    8012fc <ftruncate+0x5d>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8012db:	a1 20 60 80 00       	mov    0x806020,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8012e0:	8b 40 48             	mov    0x48(%eax),%eax
  8012e3:	83 ec 04             	sub    $0x4,%esp
  8012e6:	53                   	push   %ebx
  8012e7:	50                   	push   %eax
  8012e8:	68 ac 23 80 00       	push   $0x8023ac
  8012ed:	e8 92 ef ff ff       	call   800284 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8012f2:	83 c4 10             	add    $0x10,%esp
  8012f5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012fa:	eb 1d                	jmp    801319 <ftruncate+0x7a>
	}
	if (!dev->dev_trunc)
  8012fc:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8012ff:	8b 52 18             	mov    0x18(%edx),%edx
  801302:	85 d2                	test   %edx,%edx
  801304:	74 0e                	je     801314 <ftruncate+0x75>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801306:	83 ec 08             	sub    $0x8,%esp
  801309:	ff 75 0c             	pushl  0xc(%ebp)
  80130c:	50                   	push   %eax
  80130d:	ff d2                	call   *%edx
  80130f:	83 c4 10             	add    $0x10,%esp
  801312:	eb 05                	jmp    801319 <ftruncate+0x7a>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801314:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  801319:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80131c:	c9                   	leave  
  80131d:	c3                   	ret    

0080131e <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80131e:	55                   	push   %ebp
  80131f:	89 e5                	mov    %esp,%ebp
  801321:	53                   	push   %ebx
  801322:	83 ec 14             	sub    $0x14,%esp
  801325:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801328:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80132b:	50                   	push   %eax
  80132c:	ff 75 08             	pushl  0x8(%ebp)
  80132f:	e8 63 fb ff ff       	call   800e97 <fd_lookup>
  801334:	83 c4 08             	add    $0x8,%esp
  801337:	85 c0                	test   %eax,%eax
  801339:	78 52                	js     80138d <fstat+0x6f>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80133b:	83 ec 08             	sub    $0x8,%esp
  80133e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801341:	50                   	push   %eax
  801342:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801345:	ff 30                	pushl  (%eax)
  801347:	e8 a1 fb ff ff       	call   800eed <dev_lookup>
  80134c:	83 c4 10             	add    $0x10,%esp
  80134f:	85 c0                	test   %eax,%eax
  801351:	78 3a                	js     80138d <fstat+0x6f>
		return r;
	if (!dev->dev_stat)
  801353:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801356:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80135a:	74 2c                	je     801388 <fstat+0x6a>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80135c:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80135f:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801366:	00 00 00 
	stat->st_isdir = 0;
  801369:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801370:	00 00 00 
	stat->st_dev = dev;
  801373:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801379:	83 ec 08             	sub    $0x8,%esp
  80137c:	53                   	push   %ebx
  80137d:	ff 75 f0             	pushl  -0x10(%ebp)
  801380:	ff 50 14             	call   *0x14(%eax)
  801383:	83 c4 10             	add    $0x10,%esp
  801386:	eb 05                	jmp    80138d <fstat+0x6f>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801388:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  80138d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801390:	c9                   	leave  
  801391:	c3                   	ret    

00801392 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801392:	55                   	push   %ebp
  801393:	89 e5                	mov    %esp,%ebp
  801395:	56                   	push   %esi
  801396:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801397:	83 ec 08             	sub    $0x8,%esp
  80139a:	6a 00                	push   $0x0
  80139c:	ff 75 08             	pushl  0x8(%ebp)
  80139f:	e8 8b 01 00 00       	call   80152f <open>
  8013a4:	89 c3                	mov    %eax,%ebx
  8013a6:	83 c4 10             	add    $0x10,%esp
  8013a9:	85 c0                	test   %eax,%eax
  8013ab:	78 1b                	js     8013c8 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8013ad:	83 ec 08             	sub    $0x8,%esp
  8013b0:	ff 75 0c             	pushl  0xc(%ebp)
  8013b3:	50                   	push   %eax
  8013b4:	e8 65 ff ff ff       	call   80131e <fstat>
  8013b9:	89 c6                	mov    %eax,%esi
	close(fd);
  8013bb:	89 1c 24             	mov    %ebx,(%esp)
  8013be:	e8 18 fc ff ff       	call   800fdb <close>
	return r;
  8013c3:	83 c4 10             	add    $0x10,%esp
  8013c6:	89 f3                	mov    %esi,%ebx
}
  8013c8:	89 d8                	mov    %ebx,%eax
  8013ca:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8013cd:	5b                   	pop    %ebx
  8013ce:	5e                   	pop    %esi
  8013cf:	c9                   	leave  
  8013d0:	c3                   	ret    
  8013d1:	00 00                	add    %al,(%eax)
	...

008013d4 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8013d4:	55                   	push   %ebp
  8013d5:	89 e5                	mov    %esp,%ebp
  8013d7:	56                   	push   %esi
  8013d8:	53                   	push   %ebx
  8013d9:	89 c3                	mov    %eax,%ebx
  8013db:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  8013dd:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8013e4:	75 12                	jne    8013f8 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8013e6:	83 ec 0c             	sub    $0xc,%esp
  8013e9:	6a 01                	push   $0x1
  8013eb:	e8 f1 08 00 00       	call   801ce1 <ipc_find_env>
  8013f0:	a3 00 40 80 00       	mov    %eax,0x804000
  8013f5:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8013f8:	6a 07                	push   $0x7
  8013fa:	68 00 70 80 00       	push   $0x807000
  8013ff:	53                   	push   %ebx
  801400:	ff 35 00 40 80 00    	pushl  0x804000
  801406:	e8 81 08 00 00       	call   801c8c <ipc_send>
	
	return ipc_recv(NULL, dstva, NULL);
  80140b:	83 c4 0c             	add    $0xc,%esp
  80140e:	6a 00                	push   $0x0
  801410:	56                   	push   %esi
  801411:	6a 00                	push   $0x0
  801413:	e8 cc 07 00 00       	call   801be4 <ipc_recv>
}
  801418:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80141b:	5b                   	pop    %ebx
  80141c:	5e                   	pop    %esi
  80141d:	c9                   	leave  
  80141e:	c3                   	ret    

0080141f <devfile_stat>:
}


static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80141f:	55                   	push   %ebp
  801420:	89 e5                	mov    %esp,%ebp
  801422:	53                   	push   %ebx
  801423:	83 ec 04             	sub    $0x4,%esp
  801426:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801429:	8b 45 08             	mov    0x8(%ebp),%eax
  80142c:	8b 40 0c             	mov    0xc(%eax),%eax
  80142f:	a3 00 70 80 00       	mov    %eax,0x807000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0) {
  801434:	ba 00 00 00 00       	mov    $0x0,%edx
  801439:	b8 05 00 00 00       	mov    $0x5,%eax
  80143e:	e8 91 ff ff ff       	call   8013d4 <fsipc>
  801443:	85 c0                	test   %eax,%eax
  801445:	78 39                	js     801480 <devfile_stat+0x61>
		return r;
	}
	cprintf("OVER\n");
  801447:	83 ec 0c             	sub    $0xc,%esp
  80144a:	68 1c 24 80 00       	push   $0x80241c
  80144f:	e8 30 ee ff ff       	call   800284 <cprintf>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801454:	83 c4 08             	add    $0x8,%esp
  801457:	68 00 70 80 00       	push   $0x807000
  80145c:	53                   	push   %ebx
  80145d:	e8 d8 f3 ff ff       	call   80083a <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801462:	a1 80 70 80 00       	mov    0x807080,%eax
  801467:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80146d:	a1 84 70 80 00       	mov    0x807084,%eax
  801472:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801478:	83 c4 10             	add    $0x10,%esp
  80147b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801480:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801483:	c9                   	leave  
  801484:	c3                   	ret    

00801485 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801485:	55                   	push   %ebp
  801486:	89 e5                	mov    %esp,%ebp
  801488:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80148b:	8b 45 08             	mov    0x8(%ebp),%eax
  80148e:	8b 40 0c             	mov    0xc(%eax),%eax
  801491:	a3 00 70 80 00       	mov    %eax,0x807000
	return fsipc(FSREQ_FLUSH, NULL);
  801496:	ba 00 00 00 00       	mov    $0x0,%edx
  80149b:	b8 06 00 00 00       	mov    $0x6,%eax
  8014a0:	e8 2f ff ff ff       	call   8013d4 <fsipc>
}
  8014a5:	c9                   	leave  
  8014a6:	c3                   	ret    

008014a7 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8014a7:	55                   	push   %ebp
  8014a8:	89 e5                	mov    %esp,%ebp
  8014aa:	56                   	push   %esi
  8014ab:	53                   	push   %ebx
  8014ac:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8014af:	8b 45 08             	mov    0x8(%ebp),%eax
  8014b2:	8b 40 0c             	mov    0xc(%eax),%eax
  8014b5:	a3 00 70 80 00       	mov    %eax,0x807000
	fsipcbuf.read.req_n = n;
  8014ba:	89 35 04 70 80 00    	mov    %esi,0x807004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8014c0:	ba 00 00 00 00       	mov    $0x0,%edx
  8014c5:	b8 03 00 00 00       	mov    $0x3,%eax
  8014ca:	e8 05 ff ff ff       	call   8013d4 <fsipc>
  8014cf:	89 c3                	mov    %eax,%ebx
  8014d1:	85 c0                	test   %eax,%eax
  8014d3:	78 51                	js     801526 <devfile_read+0x7f>
		return r;
	assert(r <= n);
  8014d5:	39 c6                	cmp    %eax,%esi
  8014d7:	73 19                	jae    8014f2 <devfile_read+0x4b>
  8014d9:	68 22 24 80 00       	push   $0x802422
  8014de:	68 29 24 80 00       	push   $0x802429
  8014e3:	68 80 00 00 00       	push   $0x80
  8014e8:	68 3e 24 80 00       	push   $0x80243e
  8014ed:	e8 ba ec ff ff       	call   8001ac <_panic>
	assert(r <= PGSIZE);
  8014f2:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8014f7:	7e 19                	jle    801512 <devfile_read+0x6b>
  8014f9:	68 49 24 80 00       	push   $0x802449
  8014fe:	68 29 24 80 00       	push   $0x802429
  801503:	68 81 00 00 00       	push   $0x81
  801508:	68 3e 24 80 00       	push   $0x80243e
  80150d:	e8 9a ec ff ff       	call   8001ac <_panic>
	memmove(buf, &fsipcbuf, r);
  801512:	83 ec 04             	sub    $0x4,%esp
  801515:	50                   	push   %eax
  801516:	68 00 70 80 00       	push   $0x807000
  80151b:	ff 75 0c             	pushl  0xc(%ebp)
  80151e:	e8 d8 f4 ff ff       	call   8009fb <memmove>
	return r;
  801523:	83 c4 10             	add    $0x10,%esp
}
  801526:	89 d8                	mov    %ebx,%eax
  801528:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80152b:	5b                   	pop    %ebx
  80152c:	5e                   	pop    %esi
  80152d:	c9                   	leave  
  80152e:	c3                   	ret    

0080152f <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  80152f:	55                   	push   %ebp
  801530:	89 e5                	mov    %esp,%ebp
  801532:	56                   	push   %esi
  801533:	53                   	push   %ebx
  801534:	83 ec 1c             	sub    $0x1c,%esp
  801537:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  80153a:	56                   	push   %esi
  80153b:	e8 a8 f2 ff ff       	call   8007e8 <strlen>
  801540:	83 c4 10             	add    $0x10,%esp
  801543:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801548:	7f 72                	jg     8015bc <open+0x8d>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80154a:	83 ec 0c             	sub    $0xc,%esp
  80154d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801550:	50                   	push   %eax
  801551:	e8 ce f8 ff ff       	call   800e24 <fd_alloc>
  801556:	89 c3                	mov    %eax,%ebx
  801558:	83 c4 10             	add    $0x10,%esp
  80155b:	85 c0                	test   %eax,%eax
  80155d:	78 62                	js     8015c1 <open+0x92>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  80155f:	83 ec 08             	sub    $0x8,%esp
  801562:	56                   	push   %esi
  801563:	68 00 70 80 00       	push   $0x807000
  801568:	e8 cd f2 ff ff       	call   80083a <strcpy>
	fsipcbuf.open.req_omode = mode;
  80156d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801570:	a3 00 74 80 00       	mov    %eax,0x807400



	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801575:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801578:	b8 01 00 00 00       	mov    $0x1,%eax
  80157d:	e8 52 fe ff ff       	call   8013d4 <fsipc>
  801582:	89 c3                	mov    %eax,%ebx
  801584:	83 c4 10             	add    $0x10,%esp
  801587:	85 c0                	test   %eax,%eax
  801589:	79 12                	jns    80159d <open+0x6e>
		fd_close(fd, 0);
  80158b:	83 ec 08             	sub    $0x8,%esp
  80158e:	6a 00                	push   $0x0
  801590:	ff 75 f4             	pushl  -0xc(%ebp)
  801593:	e8 bb f9 ff ff       	call   800f53 <fd_close>
		return r;
  801598:	83 c4 10             	add    $0x10,%esp
  80159b:	eb 24                	jmp    8015c1 <open+0x92>
	}


	cprintf("OPEN\n");
  80159d:	83 ec 0c             	sub    $0xc,%esp
  8015a0:	68 55 24 80 00       	push   $0x802455
  8015a5:	e8 da ec ff ff       	call   800284 <cprintf>

	return fd2num(fd);
  8015aa:	83 c4 04             	add    $0x4,%esp
  8015ad:	ff 75 f4             	pushl  -0xc(%ebp)
  8015b0:	e8 47 f8 ff ff       	call   800dfc <fd2num>
  8015b5:	89 c3                	mov    %eax,%ebx
  8015b7:	83 c4 10             	add    $0x10,%esp
  8015ba:	eb 05                	jmp    8015c1 <open+0x92>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8015bc:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx


	cprintf("OPEN\n");

	return fd2num(fd);
}
  8015c1:	89 d8                	mov    %ebx,%eax
  8015c3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8015c6:	5b                   	pop    %ebx
  8015c7:	5e                   	pop    %esi
  8015c8:	c9                   	leave  
  8015c9:	c3                   	ret    
	...

008015cc <writebuf>:
};


static void
writebuf(struct printbuf *b)
{
  8015cc:	55                   	push   %ebp
  8015cd:	89 e5                	mov    %esp,%ebp
  8015cf:	53                   	push   %ebx
  8015d0:	83 ec 04             	sub    $0x4,%esp
  8015d3:	89 c3                	mov    %eax,%ebx
	if (b->error > 0) {
  8015d5:	83 78 0c 00          	cmpl   $0x0,0xc(%eax)
  8015d9:	7e 2e                	jle    801609 <writebuf+0x3d>
		ssize_t result = write(b->fd, b->buf, b->idx);
  8015db:	83 ec 04             	sub    $0x4,%esp
  8015de:	ff 70 04             	pushl  0x4(%eax)
  8015e1:	8d 40 10             	lea    0x10(%eax),%eax
  8015e4:	50                   	push   %eax
  8015e5:	ff 33                	pushl  (%ebx)
  8015e7:	e8 08 fc ff ff       	call   8011f4 <write>
		if (result > 0)
  8015ec:	83 c4 10             	add    $0x10,%esp
  8015ef:	85 c0                	test   %eax,%eax
  8015f1:	7e 03                	jle    8015f6 <writebuf+0x2a>
			b->result += result;
  8015f3:	01 43 08             	add    %eax,0x8(%ebx)
		if (result != b->idx) // error, or wrote less than supplied
  8015f6:	39 43 04             	cmp    %eax,0x4(%ebx)
  8015f9:	74 0e                	je     801609 <writebuf+0x3d>
			b->error = (result < 0 ? result : 0);
  8015fb:	89 c2                	mov    %eax,%edx
  8015fd:	85 c0                	test   %eax,%eax
  8015ff:	7e 05                	jle    801606 <writebuf+0x3a>
  801601:	ba 00 00 00 00       	mov    $0x0,%edx
  801606:	89 53 0c             	mov    %edx,0xc(%ebx)
	}
}
  801609:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80160c:	c9                   	leave  
  80160d:	c3                   	ret    

0080160e <putch>:

static void
putch(int ch, void *thunk)
{
  80160e:	55                   	push   %ebp
  80160f:	89 e5                	mov    %esp,%ebp
  801611:	53                   	push   %ebx
  801612:	83 ec 04             	sub    $0x4,%esp
  801615:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct printbuf *b = (struct printbuf *) thunk;
	b->buf[b->idx++] = ch;
  801618:	8b 43 04             	mov    0x4(%ebx),%eax
  80161b:	8b 55 08             	mov    0x8(%ebp),%edx
  80161e:	88 54 03 10          	mov    %dl,0x10(%ebx,%eax,1)
  801622:	40                   	inc    %eax
  801623:	89 43 04             	mov    %eax,0x4(%ebx)
	if (b->idx == 256) {
  801626:	3d 00 01 00 00       	cmp    $0x100,%eax
  80162b:	75 0e                	jne    80163b <putch+0x2d>
		writebuf(b);
  80162d:	89 d8                	mov    %ebx,%eax
  80162f:	e8 98 ff ff ff       	call   8015cc <writebuf>
		b->idx = 0;
  801634:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	}
}
  80163b:	83 c4 04             	add    $0x4,%esp
  80163e:	5b                   	pop    %ebx
  80163f:	c9                   	leave  
  801640:	c3                   	ret    

00801641 <vfprintf>:

int
vfprintf(int fd, const char *fmt, va_list ap)
{
  801641:	55                   	push   %ebp
  801642:	89 e5                	mov    %esp,%ebp
  801644:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.fd = fd;
  80164a:	8b 45 08             	mov    0x8(%ebp),%eax
  80164d:	89 85 e8 fe ff ff    	mov    %eax,-0x118(%ebp)
	b.idx = 0;
  801653:	c7 85 ec fe ff ff 00 	movl   $0x0,-0x114(%ebp)
  80165a:	00 00 00 
	b.result = 0;
  80165d:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  801664:	00 00 00 
	b.error = 1;
  801667:	c7 85 f4 fe ff ff 01 	movl   $0x1,-0x10c(%ebp)
  80166e:	00 00 00 
	vprintfmt(putch, &b, fmt, ap);
  801671:	ff 75 10             	pushl  0x10(%ebp)
  801674:	ff 75 0c             	pushl  0xc(%ebp)
  801677:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  80167d:	50                   	push   %eax
  80167e:	68 0e 16 80 00       	push   $0x80160e
  801683:	e8 61 ed ff ff       	call   8003e9 <vprintfmt>
	if (b.idx > 0)
  801688:	83 c4 10             	add    $0x10,%esp
  80168b:	83 bd ec fe ff ff 00 	cmpl   $0x0,-0x114(%ebp)
  801692:	7e 0b                	jle    80169f <vfprintf+0x5e>
		writebuf(&b);
  801694:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  80169a:	e8 2d ff ff ff       	call   8015cc <writebuf>

	return (b.result ? b.result : b.error);
  80169f:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8016a5:	85 c0                	test   %eax,%eax
  8016a7:	75 06                	jne    8016af <vfprintf+0x6e>
  8016a9:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
}
  8016af:	c9                   	leave  
  8016b0:	c3                   	ret    

008016b1 <fprintf>:

int
fprintf(int fd, const char *fmt, ...)
{
  8016b1:	55                   	push   %ebp
  8016b2:	89 e5                	mov    %esp,%ebp
  8016b4:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8016b7:	8d 45 10             	lea    0x10(%ebp),%eax
	cnt = vfprintf(fd, fmt, ap);
  8016ba:	50                   	push   %eax
  8016bb:	ff 75 0c             	pushl  0xc(%ebp)
  8016be:	ff 75 08             	pushl  0x8(%ebp)
  8016c1:	e8 7b ff ff ff       	call   801641 <vfprintf>
	va_end(ap);

	return cnt;
}
  8016c6:	c9                   	leave  
  8016c7:	c3                   	ret    

008016c8 <printf>:

int
printf(const char *fmt, ...)
{
  8016c8:	55                   	push   %ebp
  8016c9:	89 e5                	mov    %esp,%ebp
  8016cb:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8016ce:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vfprintf(1, fmt, ap);
  8016d1:	50                   	push   %eax
  8016d2:	ff 75 08             	pushl  0x8(%ebp)
  8016d5:	6a 01                	push   $0x1
  8016d7:	e8 65 ff ff ff       	call   801641 <vfprintf>
	va_end(ap);

	return cnt;
}
  8016dc:	c9                   	leave  
  8016dd:	c3                   	ret    
	...

008016e0 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8016e0:	55                   	push   %ebp
  8016e1:	89 e5                	mov    %esp,%ebp
  8016e3:	56                   	push   %esi
  8016e4:	53                   	push   %ebx
  8016e5:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8016e8:	83 ec 0c             	sub    $0xc,%esp
  8016eb:	ff 75 08             	pushl  0x8(%ebp)
  8016ee:	e8 19 f7 ff ff       	call   800e0c <fd2data>
  8016f3:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  8016f5:	83 c4 08             	add    $0x8,%esp
  8016f8:	68 5b 24 80 00       	push   $0x80245b
  8016fd:	56                   	push   %esi
  8016fe:	e8 37 f1 ff ff       	call   80083a <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801703:	8b 43 04             	mov    0x4(%ebx),%eax
  801706:	2b 03                	sub    (%ebx),%eax
  801708:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  80170e:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  801715:	00 00 00 
	stat->st_dev = &devpipe;
  801718:	c7 86 88 00 00 00 20 	movl   $0x803020,0x88(%esi)
  80171f:	30 80 00 
	return 0;
}
  801722:	b8 00 00 00 00       	mov    $0x0,%eax
  801727:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80172a:	5b                   	pop    %ebx
  80172b:	5e                   	pop    %esi
  80172c:	c9                   	leave  
  80172d:	c3                   	ret    

0080172e <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  80172e:	55                   	push   %ebp
  80172f:	89 e5                	mov    %esp,%ebp
  801731:	53                   	push   %ebx
  801732:	83 ec 0c             	sub    $0xc,%esp
  801735:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801738:	53                   	push   %ebx
  801739:	6a 00                	push   $0x0
  80173b:	e8 c6 f5 ff ff       	call   800d06 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801740:	89 1c 24             	mov    %ebx,(%esp)
  801743:	e8 c4 f6 ff ff       	call   800e0c <fd2data>
  801748:	83 c4 08             	add    $0x8,%esp
  80174b:	50                   	push   %eax
  80174c:	6a 00                	push   $0x0
  80174e:	e8 b3 f5 ff ff       	call   800d06 <sys_page_unmap>
}
  801753:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801756:	c9                   	leave  
  801757:	c3                   	ret    

00801758 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801758:	55                   	push   %ebp
  801759:	89 e5                	mov    %esp,%ebp
  80175b:	57                   	push   %edi
  80175c:	56                   	push   %esi
  80175d:	53                   	push   %ebx
  80175e:	83 ec 1c             	sub    $0x1c,%esp
  801761:	89 c7                	mov    %eax,%edi
  801763:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801766:	a1 20 60 80 00       	mov    0x806020,%eax
  80176b:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  80176e:	83 ec 0c             	sub    $0xc,%esp
  801771:	57                   	push   %edi
  801772:	e8 c5 05 00 00       	call   801d3c <pageref>
  801777:	89 c6                	mov    %eax,%esi
  801779:	83 c4 04             	add    $0x4,%esp
  80177c:	ff 75 e4             	pushl  -0x1c(%ebp)
  80177f:	e8 b8 05 00 00       	call   801d3c <pageref>
  801784:	83 c4 10             	add    $0x10,%esp
  801787:	39 c6                	cmp    %eax,%esi
  801789:	0f 94 c0             	sete   %al
  80178c:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  80178f:	8b 15 20 60 80 00    	mov    0x806020,%edx
  801795:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801798:	39 cb                	cmp    %ecx,%ebx
  80179a:	75 08                	jne    8017a4 <_pipeisclosed+0x4c>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  80179c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80179f:	5b                   	pop    %ebx
  8017a0:	5e                   	pop    %esi
  8017a1:	5f                   	pop    %edi
  8017a2:	c9                   	leave  
  8017a3:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  8017a4:	83 f8 01             	cmp    $0x1,%eax
  8017a7:	75 bd                	jne    801766 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8017a9:	8b 42 58             	mov    0x58(%edx),%eax
  8017ac:	6a 01                	push   $0x1
  8017ae:	50                   	push   %eax
  8017af:	53                   	push   %ebx
  8017b0:	68 62 24 80 00       	push   $0x802462
  8017b5:	e8 ca ea ff ff       	call   800284 <cprintf>
  8017ba:	83 c4 10             	add    $0x10,%esp
  8017bd:	eb a7                	jmp    801766 <_pipeisclosed+0xe>

008017bf <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8017bf:	55                   	push   %ebp
  8017c0:	89 e5                	mov    %esp,%ebp
  8017c2:	57                   	push   %edi
  8017c3:	56                   	push   %esi
  8017c4:	53                   	push   %ebx
  8017c5:	83 ec 28             	sub    $0x28,%esp
  8017c8:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  8017cb:	56                   	push   %esi
  8017cc:	e8 3b f6 ff ff       	call   800e0c <fd2data>
  8017d1:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8017d3:	83 c4 10             	add    $0x10,%esp
  8017d6:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8017da:	75 4a                	jne    801826 <devpipe_write+0x67>
  8017dc:	bf 00 00 00 00       	mov    $0x0,%edi
  8017e1:	eb 56                	jmp    801839 <devpipe_write+0x7a>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  8017e3:	89 da                	mov    %ebx,%edx
  8017e5:	89 f0                	mov    %esi,%eax
  8017e7:	e8 6c ff ff ff       	call   801758 <_pipeisclosed>
  8017ec:	85 c0                	test   %eax,%eax
  8017ee:	75 4d                	jne    80183d <devpipe_write+0x7e>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  8017f0:	e8 a0 f4 ff ff       	call   800c95 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8017f5:	8b 43 04             	mov    0x4(%ebx),%eax
  8017f8:	8b 13                	mov    (%ebx),%edx
  8017fa:	83 c2 20             	add    $0x20,%edx
  8017fd:	39 d0                	cmp    %edx,%eax
  8017ff:	73 e2                	jae    8017e3 <devpipe_write+0x24>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801801:	89 c2                	mov    %eax,%edx
  801803:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  801809:	79 05                	jns    801810 <devpipe_write+0x51>
  80180b:	4a                   	dec    %edx
  80180c:	83 ca e0             	or     $0xffffffe0,%edx
  80180f:	42                   	inc    %edx
  801810:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801813:	8a 0c 39             	mov    (%ecx,%edi,1),%cl
  801816:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  80181a:	40                   	inc    %eax
  80181b:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80181e:	47                   	inc    %edi
  80181f:	39 7d 10             	cmp    %edi,0x10(%ebp)
  801822:	77 07                	ja     80182b <devpipe_write+0x6c>
  801824:	eb 13                	jmp    801839 <devpipe_write+0x7a>
  801826:	bf 00 00 00 00       	mov    $0x0,%edi
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  80182b:	8b 43 04             	mov    0x4(%ebx),%eax
  80182e:	8b 13                	mov    (%ebx),%edx
  801830:	83 c2 20             	add    $0x20,%edx
  801833:	39 d0                	cmp    %edx,%eax
  801835:	73 ac                	jae    8017e3 <devpipe_write+0x24>
  801837:	eb c8                	jmp    801801 <devpipe_write+0x42>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801839:	89 f8                	mov    %edi,%eax
  80183b:	eb 05                	jmp    801842 <devpipe_write+0x83>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80183d:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801842:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801845:	5b                   	pop    %ebx
  801846:	5e                   	pop    %esi
  801847:	5f                   	pop    %edi
  801848:	c9                   	leave  
  801849:	c3                   	ret    

0080184a <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  80184a:	55                   	push   %ebp
  80184b:	89 e5                	mov    %esp,%ebp
  80184d:	57                   	push   %edi
  80184e:	56                   	push   %esi
  80184f:	53                   	push   %ebx
  801850:	83 ec 18             	sub    $0x18,%esp
  801853:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801856:	57                   	push   %edi
  801857:	e8 b0 f5 ff ff       	call   800e0c <fd2data>
  80185c:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80185e:	83 c4 10             	add    $0x10,%esp
  801861:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801865:	75 44                	jne    8018ab <devpipe_read+0x61>
  801867:	be 00 00 00 00       	mov    $0x0,%esi
  80186c:	eb 4f                	jmp    8018bd <devpipe_read+0x73>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
				return i;
  80186e:	89 f0                	mov    %esi,%eax
  801870:	eb 54                	jmp    8018c6 <devpipe_read+0x7c>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801872:	89 da                	mov    %ebx,%edx
  801874:	89 f8                	mov    %edi,%eax
  801876:	e8 dd fe ff ff       	call   801758 <_pipeisclosed>
  80187b:	85 c0                	test   %eax,%eax
  80187d:	75 42                	jne    8018c1 <devpipe_read+0x77>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  80187f:	e8 11 f4 ff ff       	call   800c95 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801884:	8b 03                	mov    (%ebx),%eax
  801886:	3b 43 04             	cmp    0x4(%ebx),%eax
  801889:	74 e7                	je     801872 <devpipe_read+0x28>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  80188b:	25 1f 00 00 80       	and    $0x8000001f,%eax
  801890:	79 05                	jns    801897 <devpipe_read+0x4d>
  801892:	48                   	dec    %eax
  801893:	83 c8 e0             	or     $0xffffffe0,%eax
  801896:	40                   	inc    %eax
  801897:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  80189b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80189e:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  8018a1:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8018a3:	46                   	inc    %esi
  8018a4:	39 75 10             	cmp    %esi,0x10(%ebp)
  8018a7:	77 07                	ja     8018b0 <devpipe_read+0x66>
  8018a9:	eb 12                	jmp    8018bd <devpipe_read+0x73>
  8018ab:	be 00 00 00 00       	mov    $0x0,%esi
		while (p->p_rpos == p->p_wpos) {
  8018b0:	8b 03                	mov    (%ebx),%eax
  8018b2:	3b 43 04             	cmp    0x4(%ebx),%eax
  8018b5:	75 d4                	jne    80188b <devpipe_read+0x41>
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  8018b7:	85 f6                	test   %esi,%esi
  8018b9:	75 b3                	jne    80186e <devpipe_read+0x24>
  8018bb:	eb b5                	jmp    801872 <devpipe_read+0x28>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  8018bd:	89 f0                	mov    %esi,%eax
  8018bf:	eb 05                	jmp    8018c6 <devpipe_read+0x7c>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8018c1:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  8018c6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8018c9:	5b                   	pop    %ebx
  8018ca:	5e                   	pop    %esi
  8018cb:	5f                   	pop    %edi
  8018cc:	c9                   	leave  
  8018cd:	c3                   	ret    

008018ce <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  8018ce:	55                   	push   %ebp
  8018cf:	89 e5                	mov    %esp,%ebp
  8018d1:	57                   	push   %edi
  8018d2:	56                   	push   %esi
  8018d3:	53                   	push   %ebx
  8018d4:	83 ec 28             	sub    $0x28,%esp
  8018d7:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  8018da:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8018dd:	50                   	push   %eax
  8018de:	e8 41 f5 ff ff       	call   800e24 <fd_alloc>
  8018e3:	89 c3                	mov    %eax,%ebx
  8018e5:	83 c4 10             	add    $0x10,%esp
  8018e8:	85 c0                	test   %eax,%eax
  8018ea:	0f 88 24 01 00 00    	js     801a14 <pipe+0x146>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8018f0:	83 ec 04             	sub    $0x4,%esp
  8018f3:	68 07 04 00 00       	push   $0x407
  8018f8:	ff 75 e4             	pushl  -0x1c(%ebp)
  8018fb:	6a 00                	push   $0x0
  8018fd:	e8 ba f3 ff ff       	call   800cbc <sys_page_alloc>
  801902:	89 c3                	mov    %eax,%ebx
  801904:	83 c4 10             	add    $0x10,%esp
  801907:	85 c0                	test   %eax,%eax
  801909:	0f 88 05 01 00 00    	js     801a14 <pipe+0x146>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  80190f:	83 ec 0c             	sub    $0xc,%esp
  801912:	8d 45 e0             	lea    -0x20(%ebp),%eax
  801915:	50                   	push   %eax
  801916:	e8 09 f5 ff ff       	call   800e24 <fd_alloc>
  80191b:	89 c3                	mov    %eax,%ebx
  80191d:	83 c4 10             	add    $0x10,%esp
  801920:	85 c0                	test   %eax,%eax
  801922:	0f 88 dc 00 00 00    	js     801a04 <pipe+0x136>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801928:	83 ec 04             	sub    $0x4,%esp
  80192b:	68 07 04 00 00       	push   $0x407
  801930:	ff 75 e0             	pushl  -0x20(%ebp)
  801933:	6a 00                	push   $0x0
  801935:	e8 82 f3 ff ff       	call   800cbc <sys_page_alloc>
  80193a:	89 c3                	mov    %eax,%ebx
  80193c:	83 c4 10             	add    $0x10,%esp
  80193f:	85 c0                	test   %eax,%eax
  801941:	0f 88 bd 00 00 00    	js     801a04 <pipe+0x136>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801947:	83 ec 0c             	sub    $0xc,%esp
  80194a:	ff 75 e4             	pushl  -0x1c(%ebp)
  80194d:	e8 ba f4 ff ff       	call   800e0c <fd2data>
  801952:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801954:	83 c4 0c             	add    $0xc,%esp
  801957:	68 07 04 00 00       	push   $0x407
  80195c:	50                   	push   %eax
  80195d:	6a 00                	push   $0x0
  80195f:	e8 58 f3 ff ff       	call   800cbc <sys_page_alloc>
  801964:	89 c3                	mov    %eax,%ebx
  801966:	83 c4 10             	add    $0x10,%esp
  801969:	85 c0                	test   %eax,%eax
  80196b:	0f 88 83 00 00 00    	js     8019f4 <pipe+0x126>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801971:	83 ec 0c             	sub    $0xc,%esp
  801974:	ff 75 e0             	pushl  -0x20(%ebp)
  801977:	e8 90 f4 ff ff       	call   800e0c <fd2data>
  80197c:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801983:	50                   	push   %eax
  801984:	6a 00                	push   $0x0
  801986:	56                   	push   %esi
  801987:	6a 00                	push   $0x0
  801989:	e8 52 f3 ff ff       	call   800ce0 <sys_page_map>
  80198e:	89 c3                	mov    %eax,%ebx
  801990:	83 c4 20             	add    $0x20,%esp
  801993:	85 c0                	test   %eax,%eax
  801995:	78 4f                	js     8019e6 <pipe+0x118>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801997:	8b 15 20 30 80 00    	mov    0x803020,%edx
  80199d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8019a0:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8019a2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8019a5:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8019ac:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8019b2:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8019b5:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8019b7:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8019ba:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  8019c1:	83 ec 0c             	sub    $0xc,%esp
  8019c4:	ff 75 e4             	pushl  -0x1c(%ebp)
  8019c7:	e8 30 f4 ff ff       	call   800dfc <fd2num>
  8019cc:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  8019ce:	83 c4 04             	add    $0x4,%esp
  8019d1:	ff 75 e0             	pushl  -0x20(%ebp)
  8019d4:	e8 23 f4 ff ff       	call   800dfc <fd2num>
  8019d9:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  8019dc:	83 c4 10             	add    $0x10,%esp
  8019df:	bb 00 00 00 00       	mov    $0x0,%ebx
  8019e4:	eb 2e                	jmp    801a14 <pipe+0x146>

    err3:
	sys_page_unmap(0, va);
  8019e6:	83 ec 08             	sub    $0x8,%esp
  8019e9:	56                   	push   %esi
  8019ea:	6a 00                	push   $0x0
  8019ec:	e8 15 f3 ff ff       	call   800d06 <sys_page_unmap>
  8019f1:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  8019f4:	83 ec 08             	sub    $0x8,%esp
  8019f7:	ff 75 e0             	pushl  -0x20(%ebp)
  8019fa:	6a 00                	push   $0x0
  8019fc:	e8 05 f3 ff ff       	call   800d06 <sys_page_unmap>
  801a01:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801a04:	83 ec 08             	sub    $0x8,%esp
  801a07:	ff 75 e4             	pushl  -0x1c(%ebp)
  801a0a:	6a 00                	push   $0x0
  801a0c:	e8 f5 f2 ff ff       	call   800d06 <sys_page_unmap>
  801a11:	83 c4 10             	add    $0x10,%esp
    err:
	return r;
}
  801a14:	89 d8                	mov    %ebx,%eax
  801a16:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a19:	5b                   	pop    %ebx
  801a1a:	5e                   	pop    %esi
  801a1b:	5f                   	pop    %edi
  801a1c:	c9                   	leave  
  801a1d:	c3                   	ret    

00801a1e <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801a1e:	55                   	push   %ebp
  801a1f:	89 e5                	mov    %esp,%ebp
  801a21:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801a24:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a27:	50                   	push   %eax
  801a28:	ff 75 08             	pushl  0x8(%ebp)
  801a2b:	e8 67 f4 ff ff       	call   800e97 <fd_lookup>
  801a30:	83 c4 10             	add    $0x10,%esp
  801a33:	85 c0                	test   %eax,%eax
  801a35:	78 18                	js     801a4f <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801a37:	83 ec 0c             	sub    $0xc,%esp
  801a3a:	ff 75 f4             	pushl  -0xc(%ebp)
  801a3d:	e8 ca f3 ff ff       	call   800e0c <fd2data>
	return _pipeisclosed(fd, p);
  801a42:	89 c2                	mov    %eax,%edx
  801a44:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a47:	e8 0c fd ff ff       	call   801758 <_pipeisclosed>
  801a4c:	83 c4 10             	add    $0x10,%esp
}
  801a4f:	c9                   	leave  
  801a50:	c3                   	ret    
  801a51:	00 00                	add    %al,(%eax)
	...

00801a54 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801a54:	55                   	push   %ebp
  801a55:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801a57:	b8 00 00 00 00       	mov    $0x0,%eax
  801a5c:	c9                   	leave  
  801a5d:	c3                   	ret    

00801a5e <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801a5e:	55                   	push   %ebp
  801a5f:	89 e5                	mov    %esp,%ebp
  801a61:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801a64:	68 7a 24 80 00       	push   $0x80247a
  801a69:	ff 75 0c             	pushl  0xc(%ebp)
  801a6c:	e8 c9 ed ff ff       	call   80083a <strcpy>
	return 0;
}
  801a71:	b8 00 00 00 00       	mov    $0x0,%eax
  801a76:	c9                   	leave  
  801a77:	c3                   	ret    

00801a78 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801a78:	55                   	push   %ebp
  801a79:	89 e5                	mov    %esp,%ebp
  801a7b:	57                   	push   %edi
  801a7c:	56                   	push   %esi
  801a7d:	53                   	push   %ebx
  801a7e:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801a84:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801a88:	74 45                	je     801acf <devcons_write+0x57>
  801a8a:	b8 00 00 00 00       	mov    $0x0,%eax
  801a8f:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801a94:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801a9a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801a9d:	29 c3                	sub    %eax,%ebx
		if (m > sizeof(buf) - 1)
  801a9f:	83 fb 7f             	cmp    $0x7f,%ebx
  801aa2:	76 05                	jbe    801aa9 <devcons_write+0x31>
			m = sizeof(buf) - 1;
  801aa4:	bb 7f 00 00 00       	mov    $0x7f,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  801aa9:	83 ec 04             	sub    $0x4,%esp
  801aac:	53                   	push   %ebx
  801aad:	03 45 0c             	add    0xc(%ebp),%eax
  801ab0:	50                   	push   %eax
  801ab1:	57                   	push   %edi
  801ab2:	e8 44 ef ff ff       	call   8009fb <memmove>
		sys_cputs(buf, m);
  801ab7:	83 c4 08             	add    $0x8,%esp
  801aba:	53                   	push   %ebx
  801abb:	57                   	push   %edi
  801abc:	e8 44 f1 ff ff       	call   800c05 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801ac1:	01 de                	add    %ebx,%esi
  801ac3:	89 f0                	mov    %esi,%eax
  801ac5:	83 c4 10             	add    $0x10,%esp
  801ac8:	3b 75 10             	cmp    0x10(%ebp),%esi
  801acb:	72 cd                	jb     801a9a <devcons_write+0x22>
  801acd:	eb 05                	jmp    801ad4 <devcons_write+0x5c>
  801acf:	be 00 00 00 00       	mov    $0x0,%esi
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801ad4:	89 f0                	mov    %esi,%eax
  801ad6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ad9:	5b                   	pop    %ebx
  801ada:	5e                   	pop    %esi
  801adb:	5f                   	pop    %edi
  801adc:	c9                   	leave  
  801add:	c3                   	ret    

00801ade <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801ade:	55                   	push   %ebp
  801adf:	89 e5                	mov    %esp,%ebp
  801ae1:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  801ae4:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801ae8:	75 07                	jne    801af1 <devcons_read+0x13>
  801aea:	eb 25                	jmp    801b11 <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801aec:	e8 a4 f1 ff ff       	call   800c95 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801af1:	e8 35 f1 ff ff       	call   800c2b <sys_cgetc>
  801af6:	85 c0                	test   %eax,%eax
  801af8:	74 f2                	je     801aec <devcons_read+0xe>
  801afa:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  801afc:	85 c0                	test   %eax,%eax
  801afe:	78 1d                	js     801b1d <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801b00:	83 f8 04             	cmp    $0x4,%eax
  801b03:	74 13                	je     801b18 <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  801b05:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b08:	88 10                	mov    %dl,(%eax)
	return 1;
  801b0a:	b8 01 00 00 00       	mov    $0x1,%eax
  801b0f:	eb 0c                	jmp    801b1d <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  801b11:	b8 00 00 00 00       	mov    $0x0,%eax
  801b16:	eb 05                	jmp    801b1d <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801b18:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801b1d:	c9                   	leave  
  801b1e:	c3                   	ret    

00801b1f <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801b1f:	55                   	push   %ebp
  801b20:	89 e5                	mov    %esp,%ebp
  801b22:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801b25:	8b 45 08             	mov    0x8(%ebp),%eax
  801b28:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801b2b:	6a 01                	push   $0x1
  801b2d:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801b30:	50                   	push   %eax
  801b31:	e8 cf f0 ff ff       	call   800c05 <sys_cputs>
  801b36:	83 c4 10             	add    $0x10,%esp
}
  801b39:	c9                   	leave  
  801b3a:	c3                   	ret    

00801b3b <getchar>:

int
getchar(void)
{
  801b3b:	55                   	push   %ebp
  801b3c:	89 e5                	mov    %esp,%ebp
  801b3e:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801b41:	6a 01                	push   $0x1
  801b43:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801b46:	50                   	push   %eax
  801b47:	6a 00                	push   $0x0
  801b49:	e8 ca f5 ff ff       	call   801118 <read>
	if (r < 0)
  801b4e:	83 c4 10             	add    $0x10,%esp
  801b51:	85 c0                	test   %eax,%eax
  801b53:	78 0f                	js     801b64 <getchar+0x29>
		return r;
	if (r < 1)
  801b55:	85 c0                	test   %eax,%eax
  801b57:	7e 06                	jle    801b5f <getchar+0x24>
		return -E_EOF;
	return c;
  801b59:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801b5d:	eb 05                	jmp    801b64 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801b5f:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801b64:	c9                   	leave  
  801b65:	c3                   	ret    

00801b66 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801b66:	55                   	push   %ebp
  801b67:	89 e5                	mov    %esp,%ebp
  801b69:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801b6c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b6f:	50                   	push   %eax
  801b70:	ff 75 08             	pushl  0x8(%ebp)
  801b73:	e8 1f f3 ff ff       	call   800e97 <fd_lookup>
  801b78:	83 c4 10             	add    $0x10,%esp
  801b7b:	85 c0                	test   %eax,%eax
  801b7d:	78 11                	js     801b90 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801b7f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b82:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801b88:	39 10                	cmp    %edx,(%eax)
  801b8a:	0f 94 c0             	sete   %al
  801b8d:	0f b6 c0             	movzbl %al,%eax
}
  801b90:	c9                   	leave  
  801b91:	c3                   	ret    

00801b92 <opencons>:

int
opencons(void)
{
  801b92:	55                   	push   %ebp
  801b93:	89 e5                	mov    %esp,%ebp
  801b95:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801b98:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b9b:	50                   	push   %eax
  801b9c:	e8 83 f2 ff ff       	call   800e24 <fd_alloc>
  801ba1:	83 c4 10             	add    $0x10,%esp
  801ba4:	85 c0                	test   %eax,%eax
  801ba6:	78 3a                	js     801be2 <opencons+0x50>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801ba8:	83 ec 04             	sub    $0x4,%esp
  801bab:	68 07 04 00 00       	push   $0x407
  801bb0:	ff 75 f4             	pushl  -0xc(%ebp)
  801bb3:	6a 00                	push   $0x0
  801bb5:	e8 02 f1 ff ff       	call   800cbc <sys_page_alloc>
  801bba:	83 c4 10             	add    $0x10,%esp
  801bbd:	85 c0                	test   %eax,%eax
  801bbf:	78 21                	js     801be2 <opencons+0x50>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801bc1:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801bc7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801bca:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801bcc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801bcf:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801bd6:	83 ec 0c             	sub    $0xc,%esp
  801bd9:	50                   	push   %eax
  801bda:	e8 1d f2 ff ff       	call   800dfc <fd2num>
  801bdf:	83 c4 10             	add    $0x10,%esp
}
  801be2:	c9                   	leave  
  801be3:	c3                   	ret    

00801be4 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801be4:	55                   	push   %ebp
  801be5:	89 e5                	mov    %esp,%ebp
  801be7:	57                   	push   %edi
  801be8:	56                   	push   %esi
  801be9:	53                   	push   %ebx
  801bea:	83 ec 0c             	sub    $0xc,%esp
  801bed:	8b 7d 08             	mov    0x8(%ebp),%edi
  801bf0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801bf3:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	cprintf("0x%x 0x%x 0x%x\n", (uint32_t)from_env_store, (uint32_t)pg, (uint32_t)perm_store);
  801bf6:	56                   	push   %esi
  801bf7:	53                   	push   %ebx
  801bf8:	57                   	push   %edi
  801bf9:	68 86 24 80 00       	push   $0x802486
  801bfe:	e8 81 e6 ff ff       	call   800284 <cprintf>
	int r;
	if (pg != NULL) {
  801c03:	83 c4 10             	add    $0x10,%esp
  801c06:	85 db                	test   %ebx,%ebx
  801c08:	74 28                	je     801c32 <ipc_recv+0x4e>
		cprintf("BEGIN\n");
  801c0a:	83 ec 0c             	sub    $0xc,%esp
  801c0d:	68 96 24 80 00       	push   $0x802496
  801c12:	e8 6d e6 ff ff       	call   800284 <cprintf>
		r = sys_ipc_recv(pg);
  801c17:	89 1c 24             	mov    %ebx,(%esp)
  801c1a:	e8 98 f1 ff ff       	call   800db7 <sys_ipc_recv>
  801c1f:	89 c3                	mov    %eax,%ebx
		cprintf("OVER\n");
  801c21:	c7 04 24 1c 24 80 00 	movl   $0x80241c,(%esp)
  801c28:	e8 57 e6 ff ff       	call   800284 <cprintf>
  801c2d:	83 c4 10             	add    $0x10,%esp
  801c30:	eb 12                	jmp    801c44 <ipc_recv+0x60>
	} else {
		r = sys_ipc_recv((void *)UTOP);
  801c32:	83 ec 0c             	sub    $0xc,%esp
  801c35:	68 00 00 c0 ee       	push   $0xeec00000
  801c3a:	e8 78 f1 ff ff       	call   800db7 <sys_ipc_recv>
  801c3f:	89 c3                	mov    %eax,%ebx
  801c41:	83 c4 10             	add    $0x10,%esp
	}

	if (r == 0) {
  801c44:	85 db                	test   %ebx,%ebx
  801c46:	75 26                	jne    801c6e <ipc_recv+0x8a>
		if (from_env_store != NULL) *from_env_store = thisenv->env_ipc_from;
  801c48:	85 ff                	test   %edi,%edi
  801c4a:	74 0a                	je     801c56 <ipc_recv+0x72>
  801c4c:	a1 20 60 80 00       	mov    0x806020,%eax
  801c51:	8b 40 74             	mov    0x74(%eax),%eax
  801c54:	89 07                	mov    %eax,(%edi)
		if (perm_store != NULL) *perm_store = thisenv->env_ipc_perm;
  801c56:	85 f6                	test   %esi,%esi
  801c58:	74 0a                	je     801c64 <ipc_recv+0x80>
  801c5a:	a1 20 60 80 00       	mov    0x806020,%eax
  801c5f:	8b 40 78             	mov    0x78(%eax),%eax
  801c62:	89 06                	mov    %eax,(%esi)
		return thisenv->env_ipc_value;
  801c64:	a1 20 60 80 00       	mov    0x806020,%eax
  801c69:	8b 58 70             	mov    0x70(%eax),%ebx
  801c6c:	eb 14                	jmp    801c82 <ipc_recv+0x9e>
	} else {
		// fails;
		if (from_env_store != NULL) *from_env_store = 0;
  801c6e:	85 ff                	test   %edi,%edi
  801c70:	74 06                	je     801c78 <ipc_recv+0x94>
  801c72:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
		if (perm_store != NULL) *perm_store = 0;
  801c78:	85 f6                	test   %esi,%esi
  801c7a:	74 06                	je     801c82 <ipc_recv+0x9e>
  801c7c:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		return r;
	}
}
  801c82:	89 d8                	mov    %ebx,%eax
  801c84:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c87:	5b                   	pop    %ebx
  801c88:	5e                   	pop    %esi
  801c89:	5f                   	pop    %edi
  801c8a:	c9                   	leave  
  801c8b:	c3                   	ret    

00801c8c <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801c8c:	55                   	push   %ebp
  801c8d:	89 e5                	mov    %esp,%ebp
  801c8f:	57                   	push   %edi
  801c90:	56                   	push   %esi
  801c91:	53                   	push   %ebx
  801c92:	83 ec 0c             	sub    $0xc,%esp
  801c95:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801c98:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801c9b:	8b 75 14             	mov    0x14(%ebp),%esi
	// LAB 4: Your code here.
	// int sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
	int r;
	if (pg == NULL) pg = (void *)UTOP;
  801c9e:	85 db                	test   %ebx,%ebx
  801ca0:	75 25                	jne    801cc7 <ipc_send+0x3b>
  801ca2:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
  801ca7:	eb 1e                	jmp    801cc7 <ipc_send+0x3b>
	
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) != 0) {
		if (r == -E_IPC_NOT_RECV) {
  801ca9:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801cac:	75 07                	jne    801cb5 <ipc_send+0x29>
			// cprintf("Try Again and Again....\n");
			sys_yield();
  801cae:	e8 e2 ef ff ff       	call   800c95 <sys_yield>
  801cb3:	eb 12                	jmp    801cc7 <ipc_send+0x3b>
		} else {
			panic("ipc_send error %e\n", r);
  801cb5:	50                   	push   %eax
  801cb6:	68 9d 24 80 00       	push   $0x80249d
  801cbb:	6a 45                	push   $0x45
  801cbd:	68 b0 24 80 00       	push   $0x8024b0
  801cc2:	e8 e5 e4 ff ff       	call   8001ac <_panic>
	// LAB 4: Your code here.
	// int sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
	int r;
	if (pg == NULL) pg = (void *)UTOP;
	
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) != 0) {
  801cc7:	56                   	push   %esi
  801cc8:	53                   	push   %ebx
  801cc9:	57                   	push   %edi
  801cca:	ff 75 08             	pushl  0x8(%ebp)
  801ccd:	e8 c0 f0 ff ff       	call   800d92 <sys_ipc_try_send>
  801cd2:	83 c4 10             	add    $0x10,%esp
  801cd5:	85 c0                	test   %eax,%eax
  801cd7:	75 d0                	jne    801ca9 <ipc_send+0x1d>
		} else {
			panic("ipc_send error %e\n", r);
		}
	}
	return;
}
  801cd9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801cdc:	5b                   	pop    %ebx
  801cdd:	5e                   	pop    %esi
  801cde:	5f                   	pop    %edi
  801cdf:	c9                   	leave  
  801ce0:	c3                   	ret    

00801ce1 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801ce1:	55                   	push   %ebp
  801ce2:	89 e5                	mov    %esp,%ebp
  801ce4:	53                   	push   %ebx
  801ce5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  801ce8:	39 1d 50 00 c0 ee    	cmp    %ebx,0xeec00050
  801cee:	74 22                	je     801d12 <ipc_find_env+0x31>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801cf0:	b8 01 00 00 00       	mov    $0x1,%eax
		if (envs[i].env_type == type)
  801cf5:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  801cfc:	89 c2                	mov    %eax,%edx
  801cfe:	c1 e2 07             	shl    $0x7,%edx
  801d01:	29 ca                	sub    %ecx,%edx
  801d03:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801d09:	8b 52 50             	mov    0x50(%edx),%edx
  801d0c:	39 da                	cmp    %ebx,%edx
  801d0e:	75 1d                	jne    801d2d <ipc_find_env+0x4c>
  801d10:	eb 05                	jmp    801d17 <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801d12:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
			return envs[i].env_id;
  801d17:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  801d1e:	c1 e0 07             	shl    $0x7,%eax
  801d21:	29 d0                	sub    %edx,%eax
  801d23:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  801d28:	8b 40 40             	mov    0x40(%eax),%eax
  801d2b:	eb 0c                	jmp    801d39 <ipc_find_env+0x58>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801d2d:	40                   	inc    %eax
  801d2e:	3d 00 04 00 00       	cmp    $0x400,%eax
  801d33:	75 c0                	jne    801cf5 <ipc_find_env+0x14>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801d35:	66 b8 00 00          	mov    $0x0,%ax
}
  801d39:	5b                   	pop    %ebx
  801d3a:	c9                   	leave  
  801d3b:	c3                   	ret    

00801d3c <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801d3c:	55                   	push   %ebp
  801d3d:	89 e5                	mov    %esp,%ebp
  801d3f:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801d42:	89 c2                	mov    %eax,%edx
  801d44:	c1 ea 16             	shr    $0x16,%edx
  801d47:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801d4e:	f6 c2 01             	test   $0x1,%dl
  801d51:	74 1e                	je     801d71 <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  801d53:	c1 e8 0c             	shr    $0xc,%eax
  801d56:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801d5d:	a8 01                	test   $0x1,%al
  801d5f:	74 17                	je     801d78 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801d61:	c1 e8 0c             	shr    $0xc,%eax
  801d64:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  801d6b:	ef 
  801d6c:	0f b7 c0             	movzwl %ax,%eax
  801d6f:	eb 0c                	jmp    801d7d <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  801d71:	b8 00 00 00 00       	mov    $0x0,%eax
  801d76:	eb 05                	jmp    801d7d <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  801d78:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  801d7d:	c9                   	leave  
  801d7e:	c3                   	ret    
	...

00801d80 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  801d80:	55                   	push   %ebp
  801d81:	89 e5                	mov    %esp,%ebp
  801d83:	57                   	push   %edi
  801d84:	56                   	push   %esi
  801d85:	83 ec 10             	sub    $0x10,%esp
  801d88:	8b 7d 08             	mov    0x8(%ebp),%edi
  801d8b:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  801d8e:	89 7d f0             	mov    %edi,-0x10(%ebp)
  801d91:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  801d94:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  801d97:	8b 45 14             	mov    0x14(%ebp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  801d9a:	85 c0                	test   %eax,%eax
  801d9c:	75 2e                	jne    801dcc <__udivdi3+0x4c>
    {
      if (d0 > n1)
  801d9e:	39 f1                	cmp    %esi,%ecx
  801da0:	77 5a                	ja     801dfc <__udivdi3+0x7c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  801da2:	85 c9                	test   %ecx,%ecx
  801da4:	75 0b                	jne    801db1 <__udivdi3+0x31>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  801da6:	b8 01 00 00 00       	mov    $0x1,%eax
  801dab:	31 d2                	xor    %edx,%edx
  801dad:	f7 f1                	div    %ecx
  801daf:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  801db1:	31 d2                	xor    %edx,%edx
  801db3:	89 f0                	mov    %esi,%eax
  801db5:	f7 f1                	div    %ecx
  801db7:	89 c6                	mov    %eax,%esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801db9:	89 f8                	mov    %edi,%eax
  801dbb:	f7 f1                	div    %ecx
  801dbd:	89 c7                	mov    %eax,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801dbf:	89 f8                	mov    %edi,%eax
  801dc1:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801dc3:	83 c4 10             	add    $0x10,%esp
  801dc6:	5e                   	pop    %esi
  801dc7:	5f                   	pop    %edi
  801dc8:	c9                   	leave  
  801dc9:	c3                   	ret    
  801dca:	66 90                	xchg   %ax,%ax
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801dcc:	39 f0                	cmp    %esi,%eax
  801dce:	77 1c                	ja     801dec <__udivdi3+0x6c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  801dd0:	0f bd f8             	bsr    %eax,%edi
	  if (bm == 0)
  801dd3:	83 f7 1f             	xor    $0x1f,%edi
  801dd6:	75 3c                	jne    801e14 <__udivdi3+0x94>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801dd8:	39 f0                	cmp    %esi,%eax
  801dda:	0f 82 90 00 00 00    	jb     801e70 <__udivdi3+0xf0>
  801de0:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801de3:	39 55 f4             	cmp    %edx,-0xc(%ebp)
  801de6:	0f 86 84 00 00 00    	jbe    801e70 <__udivdi3+0xf0>
  801dec:	31 f6                	xor    %esi,%esi
  801dee:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801df0:	89 f8                	mov    %edi,%eax
  801df2:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801df4:	83 c4 10             	add    $0x10,%esp
  801df7:	5e                   	pop    %esi
  801df8:	5f                   	pop    %edi
  801df9:	c9                   	leave  
  801dfa:	c3                   	ret    
  801dfb:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801dfc:	89 f2                	mov    %esi,%edx
  801dfe:	89 f8                	mov    %edi,%eax
  801e00:	f7 f1                	div    %ecx
  801e02:	89 c7                	mov    %eax,%edi
  801e04:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801e06:	89 f8                	mov    %edi,%eax
  801e08:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801e0a:	83 c4 10             	add    $0x10,%esp
  801e0d:	5e                   	pop    %esi
  801e0e:	5f                   	pop    %edi
  801e0f:	c9                   	leave  
  801e10:	c3                   	ret    
  801e11:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  801e14:	89 f9                	mov    %edi,%ecx
  801e16:	d3 e0                	shl    %cl,%eax
  801e18:	89 45 e8             	mov    %eax,-0x18(%ebp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  801e1b:	b8 20 00 00 00       	mov    $0x20,%eax
  801e20:	29 f8                	sub    %edi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  801e22:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801e25:	88 c1                	mov    %al,%cl
  801e27:	d3 ea                	shr    %cl,%edx
  801e29:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  801e2c:	09 ca                	or     %ecx,%edx
  801e2e:	89 55 ec             	mov    %edx,-0x14(%ebp)
	      d0 = d0 << bm;
  801e31:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801e34:	89 f9                	mov    %edi,%ecx
  801e36:	d3 e2                	shl    %cl,%edx
  801e38:	89 55 f4             	mov    %edx,-0xc(%ebp)
	      n2 = n1 >> b;
  801e3b:	89 f2                	mov    %esi,%edx
  801e3d:	88 c1                	mov    %al,%cl
  801e3f:	d3 ea                	shr    %cl,%edx
  801e41:	89 55 e8             	mov    %edx,-0x18(%ebp)
	      n1 = (n1 << bm) | (n0 >> b);
  801e44:	89 f2                	mov    %esi,%edx
  801e46:	89 f9                	mov    %edi,%ecx
  801e48:	d3 e2                	shl    %cl,%edx
  801e4a:	8b 75 f0             	mov    -0x10(%ebp),%esi
  801e4d:	88 c1                	mov    %al,%cl
  801e4f:	d3 ee                	shr    %cl,%esi
  801e51:	09 d6                	or     %edx,%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  801e53:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  801e56:	89 f0                	mov    %esi,%eax
  801e58:	89 ca                	mov    %ecx,%edx
  801e5a:	f7 75 ec             	divl   -0x14(%ebp)
  801e5d:	89 d1                	mov    %edx,%ecx
  801e5f:	89 c6                	mov    %eax,%esi
	      umul_ppmm (m1, m0, q0, d0);
  801e61:	f7 65 f4             	mull   -0xc(%ebp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801e64:	39 d1                	cmp    %edx,%ecx
  801e66:	72 28                	jb     801e90 <__udivdi3+0x110>
  801e68:	74 1a                	je     801e84 <__udivdi3+0x104>
  801e6a:	89 f7                	mov    %esi,%edi
  801e6c:	31 f6                	xor    %esi,%esi
  801e6e:	eb 80                	jmp    801df0 <__udivdi3+0x70>
	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  801e70:	31 f6                	xor    %esi,%esi
  801e72:	bf 01 00 00 00       	mov    $0x1,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801e77:	89 f8                	mov    %edi,%eax
  801e79:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801e7b:	83 c4 10             	add    $0x10,%esp
  801e7e:	5e                   	pop    %esi
  801e7f:	5f                   	pop    %edi
  801e80:	c9                   	leave  
  801e81:	c3                   	ret    
  801e82:	66 90                	xchg   %ax,%ax

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  801e84:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801e87:	89 f9                	mov    %edi,%ecx
  801e89:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801e8b:	39 c2                	cmp    %eax,%edx
  801e8d:	73 db                	jae    801e6a <__udivdi3+0xea>
  801e8f:	90                   	nop
		{
		  q0--;
  801e90:	8d 7e ff             	lea    -0x1(%esi),%edi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  801e93:	31 f6                	xor    %esi,%esi
  801e95:	e9 56 ff ff ff       	jmp    801df0 <__udivdi3+0x70>
	...

00801e9c <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  801e9c:	55                   	push   %ebp
  801e9d:	89 e5                	mov    %esp,%ebp
  801e9f:	57                   	push   %edi
  801ea0:	56                   	push   %esi
  801ea1:	83 ec 20             	sub    $0x20,%esp
  801ea4:	8b 45 08             	mov    0x8(%ebp),%eax
  801ea7:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  801eaa:	89 45 e8             	mov    %eax,-0x18(%ebp)
  801ead:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  801eb0:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  801eb3:	8b 7d 14             	mov    0x14(%ebp),%edi
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  801eb6:	89 45 f0             	mov    %eax,-0x10(%ebp)
  n1 = nn.s.high;
  801eb9:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  801ebb:	85 ff                	test   %edi,%edi
  801ebd:	75 15                	jne    801ed4 <__umoddi3+0x38>
    {
      if (d0 > n1)
  801ebf:	39 f1                	cmp    %esi,%ecx
  801ec1:	0f 86 99 00 00 00    	jbe    801f60 <__umoddi3+0xc4>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801ec7:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  801ec9:	89 d0                	mov    %edx,%eax
  801ecb:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801ecd:	83 c4 20             	add    $0x20,%esp
  801ed0:	5e                   	pop    %esi
  801ed1:	5f                   	pop    %edi
  801ed2:	c9                   	leave  
  801ed3:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801ed4:	39 f7                	cmp    %esi,%edi
  801ed6:	0f 87 a4 00 00 00    	ja     801f80 <__umoddi3+0xe4>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  801edc:	0f bd c7             	bsr    %edi,%eax
	  if (bm == 0)
  801edf:	83 f0 1f             	xor    $0x1f,%eax
  801ee2:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801ee5:	0f 84 a1 00 00 00    	je     801f8c <__umoddi3+0xf0>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  801eeb:	89 f8                	mov    %edi,%eax
  801eed:	8a 4d ec             	mov    -0x14(%ebp),%cl
  801ef0:	d3 e0                	shl    %cl,%eax
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  801ef2:	bf 20 00 00 00       	mov    $0x20,%edi
  801ef7:	2b 7d ec             	sub    -0x14(%ebp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  801efa:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801efd:	89 f9                	mov    %edi,%ecx
  801eff:	d3 ea                	shr    %cl,%edx
  801f01:	09 c2                	or     %eax,%edx
  801f03:	89 55 f0             	mov    %edx,-0x10(%ebp)
	      d0 = d0 << bm;
  801f06:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f09:	8a 4d ec             	mov    -0x14(%ebp),%cl
  801f0c:	d3 e0                	shl    %cl,%eax
  801f0e:	89 45 f4             	mov    %eax,-0xc(%ebp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  801f11:	89 f2                	mov    %esi,%edx
  801f13:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  801f15:	8b 45 e8             	mov    -0x18(%ebp),%eax
  801f18:	d3 e0                	shl    %cl,%eax
  801f1a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  801f1d:	8b 45 e8             	mov    -0x18(%ebp),%eax
  801f20:	89 f9                	mov    %edi,%ecx
  801f22:	d3 e8                	shr    %cl,%eax
  801f24:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  801f26:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  801f28:	89 f2                	mov    %esi,%edx
  801f2a:	f7 75 f0             	divl   -0x10(%ebp)
  801f2d:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  801f2f:	f7 65 f4             	mull   -0xc(%ebp)
  801f32:	89 55 e8             	mov    %edx,-0x18(%ebp)
  801f35:	89 c1                	mov    %eax,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801f37:	39 d6                	cmp    %edx,%esi
  801f39:	72 71                	jb     801fac <__umoddi3+0x110>
  801f3b:	74 7f                	je     801fbc <__umoddi3+0x120>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  801f3d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801f40:	29 c8                	sub    %ecx,%eax
  801f42:	19 d6                	sbb    %edx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  801f44:	8a 4d ec             	mov    -0x14(%ebp),%cl
  801f47:	d3 e8                	shr    %cl,%eax
  801f49:	89 f2                	mov    %esi,%edx
  801f4b:	89 f9                	mov    %edi,%ecx
  801f4d:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  801f4f:	09 d0                	or     %edx,%eax
  801f51:	89 f2                	mov    %esi,%edx
  801f53:	8a 4d ec             	mov    -0x14(%ebp),%cl
  801f56:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801f58:	83 c4 20             	add    $0x20,%esp
  801f5b:	5e                   	pop    %esi
  801f5c:	5f                   	pop    %edi
  801f5d:	c9                   	leave  
  801f5e:	c3                   	ret    
  801f5f:	90                   	nop
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  801f60:	85 c9                	test   %ecx,%ecx
  801f62:	75 0b                	jne    801f6f <__umoddi3+0xd3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  801f64:	b8 01 00 00 00       	mov    $0x1,%eax
  801f69:	31 d2                	xor    %edx,%edx
  801f6b:	f7 f1                	div    %ecx
  801f6d:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  801f6f:	89 f0                	mov    %esi,%eax
  801f71:	31 d2                	xor    %edx,%edx
  801f73:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801f75:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801f78:	f7 f1                	div    %ecx
  801f7a:	e9 4a ff ff ff       	jmp    801ec9 <__umoddi3+0x2d>
  801f7f:	90                   	nop
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  801f80:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801f82:	83 c4 20             	add    $0x20,%esp
  801f85:	5e                   	pop    %esi
  801f86:	5f                   	pop    %edi
  801f87:	c9                   	leave  
  801f88:	c3                   	ret    
  801f89:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801f8c:	39 f7                	cmp    %esi,%edi
  801f8e:	72 05                	jb     801f95 <__umoddi3+0xf9>
  801f90:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
  801f93:	77 0c                	ja     801fa1 <__umoddi3+0x105>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  801f95:	89 f2                	mov    %esi,%edx
  801f97:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801f9a:	29 c8                	sub    %ecx,%eax
  801f9c:	19 fa                	sbb    %edi,%edx
  801f9e:	89 45 f0             	mov    %eax,-0x10(%ebp)

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  801fa1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801fa4:	83 c4 20             	add    $0x20,%esp
  801fa7:	5e                   	pop    %esi
  801fa8:	5f                   	pop    %edi
  801fa9:	c9                   	leave  
  801faa:	c3                   	ret    
  801fab:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  801fac:	8b 55 e8             	mov    -0x18(%ebp),%edx
  801faf:	89 c1                	mov    %eax,%ecx
  801fb1:	2b 4d f4             	sub    -0xc(%ebp),%ecx
  801fb4:	1b 55 f0             	sbb    -0x10(%ebp),%edx
  801fb7:	eb 84                	jmp    801f3d <__umoddi3+0xa1>
  801fb9:	8d 76 00             	lea    0x0(%esi),%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801fbc:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801fbf:	72 eb                	jb     801fac <__umoddi3+0x110>
  801fc1:	89 f2                	mov    %esi,%edx
  801fc3:	e9 75 ff ff ff       	jmp    801f3d <__umoddi3+0xa1>
