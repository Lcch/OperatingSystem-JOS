
obj/user/testpteshare.debug:     file format elf32-i386


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
  80002c:	e8 53 01 00 00       	call   800184 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <childofspawn>:
	breakpoint();
}

void
childofspawn(void)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	83 ec 10             	sub    $0x10,%esp
	strcpy(VA, msg2);
  80003a:	ff 35 04 40 80 00    	pushl  0x804004
  800040:	68 00 00 00 a0       	push   $0xa0000000
  800045:	e8 34 08 00 00       	call   80087e <strcpy>
	exit();
  80004a:	e8 85 01 00 00       	call   8001d4 <exit>
  80004f:	83 c4 10             	add    $0x10,%esp
}
  800052:	c9                   	leave  
  800053:	c3                   	ret    

00800054 <umain>:

void childofspawn(void);

void
umain(int argc, char **argv)
{
  800054:	55                   	push   %ebp
  800055:	89 e5                	mov    %esp,%ebp
  800057:	53                   	push   %ebx
  800058:	83 ec 04             	sub    $0x4,%esp
	int r;

	if (argc != 0)
  80005b:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  80005f:	74 05                	je     800066 <umain+0x12>
		childofspawn();
  800061:	e8 ce ff ff ff       	call   800034 <childofspawn>

	if ((r = sys_page_alloc(0, VA, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800066:	83 ec 04             	sub    $0x4,%esp
  800069:	68 07 04 00 00       	push   $0x407
  80006e:	68 00 00 00 a0       	push   $0xa0000000
  800073:	6a 00                	push   $0x0
  800075:	e8 86 0c 00 00       	call   800d00 <sys_page_alloc>
  80007a:	83 c4 10             	add    $0x10,%esp
  80007d:	85 c0                	test   %eax,%eax
  80007f:	79 12                	jns    800093 <umain+0x3f>
		panic("sys_page_alloc: %e", r);
  800081:	50                   	push   %eax
  800082:	68 ac 28 80 00       	push   $0x8028ac
  800087:	6a 13                	push   $0x13
  800089:	68 bf 28 80 00       	push   $0x8028bf
  80008e:	e8 5d 01 00 00       	call   8001f0 <_panic>

	// check fork
	if ((r = fork()) < 0)
  800093:	e8 7a 0e 00 00       	call   800f12 <fork>
  800098:	89 c3                	mov    %eax,%ebx
  80009a:	85 c0                	test   %eax,%eax
  80009c:	79 12                	jns    8000b0 <umain+0x5c>
		panic("fork: %e", r);
  80009e:	50                   	push   %eax
  80009f:	68 d3 28 80 00       	push   $0x8028d3
  8000a4:	6a 17                	push   $0x17
  8000a6:	68 bf 28 80 00       	push   $0x8028bf
  8000ab:	e8 40 01 00 00       	call   8001f0 <_panic>
	if (r == 0) {
  8000b0:	85 c0                	test   %eax,%eax
  8000b2:	75 1b                	jne    8000cf <umain+0x7b>
		strcpy(VA, msg);
  8000b4:	83 ec 08             	sub    $0x8,%esp
  8000b7:	ff 35 00 40 80 00    	pushl  0x804000
  8000bd:	68 00 00 00 a0       	push   $0xa0000000
  8000c2:	e8 b7 07 00 00       	call   80087e <strcpy>
		exit();
  8000c7:	e8 08 01 00 00       	call   8001d4 <exit>
  8000cc:	83 c4 10             	add    $0x10,%esp
	}
	wait(r);
  8000cf:	83 ec 0c             	sub    $0xc,%esp
  8000d2:	53                   	push   %ebx
  8000d3:	e8 30 21 00 00       	call   802208 <wait>
	cprintf("fork handles PTE_SHARE %s\n", strcmp(VA, msg) == 0 ? "right" : "wrong");
  8000d8:	83 c4 08             	add    $0x8,%esp
  8000db:	ff 35 00 40 80 00    	pushl  0x804000
  8000e1:	68 00 00 00 a0       	push   $0xa0000000
  8000e6:	e8 4c 08 00 00       	call   800937 <strcmp>
  8000eb:	83 c4 10             	add    $0x10,%esp
  8000ee:	85 c0                	test   %eax,%eax
  8000f0:	75 07                	jne    8000f9 <umain+0xa5>
  8000f2:	b8 a0 28 80 00       	mov    $0x8028a0,%eax
  8000f7:	eb 05                	jmp    8000fe <umain+0xaa>
  8000f9:	b8 a6 28 80 00       	mov    $0x8028a6,%eax
  8000fe:	83 ec 08             	sub    $0x8,%esp
  800101:	50                   	push   %eax
  800102:	68 dc 28 80 00       	push   $0x8028dc
  800107:	e8 bc 01 00 00       	call   8002c8 <cprintf>

	// check spawn
	if ((r = spawnl("/testpteshare", "testpteshare", "arg", 0)) < 0)
  80010c:	6a 00                	push   $0x0
  80010e:	68 f7 28 80 00       	push   $0x8028f7
  800113:	68 fc 28 80 00       	push   $0x8028fc
  800118:	68 fb 28 80 00       	push   $0x8028fb
  80011d:	e8 e9 1c 00 00       	call   801e0b <spawnl>
  800122:	83 c4 20             	add    $0x20,%esp
  800125:	85 c0                	test   %eax,%eax
  800127:	79 12                	jns    80013b <umain+0xe7>
		panic("spawn: %e", r);
  800129:	50                   	push   %eax
  80012a:	68 09 29 80 00       	push   $0x802909
  80012f:	6a 21                	push   $0x21
  800131:	68 bf 28 80 00       	push   $0x8028bf
  800136:	e8 b5 00 00 00       	call   8001f0 <_panic>
	wait(r);
  80013b:	83 ec 0c             	sub    $0xc,%esp
  80013e:	50                   	push   %eax
  80013f:	e8 c4 20 00 00       	call   802208 <wait>
	cprintf("spawn handles PTE_SHARE %s\n", strcmp(VA, msg2) == 0 ? "right" : "wrong");
  800144:	83 c4 08             	add    $0x8,%esp
  800147:	ff 35 04 40 80 00    	pushl  0x804004
  80014d:	68 00 00 00 a0       	push   $0xa0000000
  800152:	e8 e0 07 00 00       	call   800937 <strcmp>
  800157:	83 c4 10             	add    $0x10,%esp
  80015a:	85 c0                	test   %eax,%eax
  80015c:	75 07                	jne    800165 <umain+0x111>
  80015e:	b8 a0 28 80 00       	mov    $0x8028a0,%eax
  800163:	eb 05                	jmp    80016a <umain+0x116>
  800165:	b8 a6 28 80 00       	mov    $0x8028a6,%eax
  80016a:	83 ec 08             	sub    $0x8,%esp
  80016d:	50                   	push   %eax
  80016e:	68 13 29 80 00       	push   $0x802913
  800173:	e8 50 01 00 00       	call   8002c8 <cprintf>
	: "c" (msr), "a" (val1), "d" (val2))

static __inline void
breakpoint(void)
{
	__asm __volatile("int3");
  800178:	cc                   	int3   
  800179:	83 c4 10             	add    $0x10,%esp

	breakpoint();
}
  80017c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80017f:	c9                   	leave  
  800180:	c3                   	ret    
  800181:	00 00                	add    %al,(%eax)
	...

00800184 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800184:	55                   	push   %ebp
  800185:	89 e5                	mov    %esp,%ebp
  800187:	56                   	push   %esi
  800188:	53                   	push   %ebx
  800189:	8b 75 08             	mov    0x8(%ebp),%esi
  80018c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs + ENVX(sys_getenvid());
  80018f:	e8 21 0b 00 00       	call   800cb5 <sys_getenvid>
  800194:	25 ff 03 00 00       	and    $0x3ff,%eax
  800199:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  8001a0:	c1 e0 07             	shl    $0x7,%eax
  8001a3:	29 d0                	sub    %edx,%eax
  8001a5:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8001aa:	a3 04 50 80 00       	mov    %eax,0x805004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8001af:	85 f6                	test   %esi,%esi
  8001b1:	7e 07                	jle    8001ba <libmain+0x36>
		binaryname = argv[0];
  8001b3:	8b 03                	mov    (%ebx),%eax
  8001b5:	a3 08 40 80 00       	mov    %eax,0x804008
	// call user main routine
	umain(argc, argv);
  8001ba:	83 ec 08             	sub    $0x8,%esp
  8001bd:	53                   	push   %ebx
  8001be:	56                   	push   %esi
  8001bf:	e8 90 fe ff ff       	call   800054 <umain>

	// exit gracefully
	exit();
  8001c4:	e8 0b 00 00 00       	call   8001d4 <exit>
  8001c9:	83 c4 10             	add    $0x10,%esp
}
  8001cc:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8001cf:	5b                   	pop    %ebx
  8001d0:	5e                   	pop    %esi
  8001d1:	c9                   	leave  
  8001d2:	c3                   	ret    
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
  8001da:	e8 43 11 00 00       	call   801322 <close_all>
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
  8001f8:	8b 1d 08 40 80 00    	mov    0x804008,%ebx
  8001fe:	e8 b2 0a 00 00       	call   800cb5 <sys_getenvid>
  800203:	83 ec 0c             	sub    $0xc,%esp
  800206:	ff 75 0c             	pushl  0xc(%ebp)
  800209:	ff 75 08             	pushl  0x8(%ebp)
  80020c:	53                   	push   %ebx
  80020d:	50                   	push   %eax
  80020e:	68 58 29 80 00       	push   $0x802958
  800213:	e8 b0 00 00 00       	call   8002c8 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800218:	83 c4 18             	add    $0x18,%esp
  80021b:	56                   	push   %esi
  80021c:	ff 75 10             	pushl  0x10(%ebp)
  80021f:	e8 53 00 00 00       	call   800277 <vcprintf>
	cprintf("\n");
  800224:	c7 04 24 f9 2e 80 00 	movl   $0x802ef9,(%esp)
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
  800330:	e8 1b 23 00 00       	call   802650 <__udivdi3>
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
  80036c:	e8 fb 23 00 00       	call   80276c <__umoddi3>
  800371:	83 c4 14             	add    $0x14,%esp
  800374:	0f be 80 7b 29 80 00 	movsbl 0x80297b(%eax),%eax
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
  8004b8:	ff 24 85 c0 2a 80 00 	jmp    *0x802ac0(,%eax,4)
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
  800564:	8b 04 85 20 2c 80 00 	mov    0x802c20(,%eax,4),%eax
  80056b:	85 c0                	test   %eax,%eax
  80056d:	75 1a                	jne    800589 <vprintfmt+0x15c>
				printfmt(putch, putdat, "error %d", err);
  80056f:	52                   	push   %edx
  800570:	68 93 29 80 00       	push   $0x802993
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
  80058a:	68 db 2e 80 00       	push   $0x802edb
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
  8005c0:	c7 45 d0 8c 29 80 00 	movl   $0x80298c,-0x30(%ebp)
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
  800c2e:	68 7f 2c 80 00       	push   $0x802c7f
  800c33:	6a 42                	push   $0x42
  800c35:	68 9c 2c 80 00       	push   $0x802c9c
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

00800e40 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800e40:	55                   	push   %ebp
  800e41:	89 e5                	mov    %esp,%ebp
  800e43:	53                   	push   %ebx
  800e44:	83 ec 04             	sub    $0x4,%esp
  800e47:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800e4a:	8b 18                	mov    (%eax),%ebx

	// LAB 4: Your code here.
	
	// cprintf("PAGE FAULT HANDLER, 0x%08x %d\n", (uint32_t)addr, err & FEC_WR);
	
	if ((err & FEC_WR) == 0)
  800e4c:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800e50:	75 14                	jne    800e66 <pgfault+0x26>
		panic("pgfault, the fault is not a write\n");
  800e52:	83 ec 04             	sub    $0x4,%esp
  800e55:	68 ac 2c 80 00       	push   $0x802cac
  800e5a:	6a 20                	push   $0x20
  800e5c:	68 f0 2d 80 00       	push   $0x802df0
  800e61:	e8 8a f3 ff ff       	call   8001f0 <_panic>

	uint32_t uaddr = (uint32_t) addr;
	if ((uvpd[PDX(addr)] & PTE_P) == 0 || (uvpt[uaddr / PGSIZE] & PTE_COW) == 0) {
  800e66:	89 d8                	mov    %ebx,%eax
  800e68:	c1 e8 16             	shr    $0x16,%eax
  800e6b:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800e72:	a8 01                	test   $0x1,%al
  800e74:	74 11                	je     800e87 <pgfault+0x47>
  800e76:	89 d8                	mov    %ebx,%eax
  800e78:	c1 e8 0c             	shr    $0xc,%eax
  800e7b:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800e82:	f6 c4 08             	test   $0x8,%ah
  800e85:	75 14                	jne    800e9b <pgfault+0x5b>
		panic("pgfault, not a copy-on-write page\n");
  800e87:	83 ec 04             	sub    $0x4,%esp
  800e8a:	68 d0 2c 80 00       	push   $0x802cd0
  800e8f:	6a 24                	push   $0x24
  800e91:	68 f0 2d 80 00       	push   $0x802df0
  800e96:	e8 55 f3 ff ff       	call   8001f0 <_panic>
	//   No need to explicitly delete the old page's mapping.

	// LAB 4: Your code here.

	// static int sys_page_alloc(envid_t envid, void *va, int perm)
	r = sys_page_alloc(0, (void *)PFTEMP, PTE_W | PTE_U | PTE_P);
  800e9b:	83 ec 04             	sub    $0x4,%esp
  800e9e:	6a 07                	push   $0x7
  800ea0:	68 00 f0 7f 00       	push   $0x7ff000
  800ea5:	6a 00                	push   $0x0
  800ea7:	e8 54 fe ff ff       	call   800d00 <sys_page_alloc>
	if (r < 0) panic("pgfault, sys_page_alloc error : %e\n", r);
  800eac:	83 c4 10             	add    $0x10,%esp
  800eaf:	85 c0                	test   %eax,%eax
  800eb1:	79 12                	jns    800ec5 <pgfault+0x85>
  800eb3:	50                   	push   %eax
  800eb4:	68 f4 2c 80 00       	push   $0x802cf4
  800eb9:	6a 32                	push   $0x32
  800ebb:	68 f0 2d 80 00       	push   $0x802df0
  800ec0:	e8 2b f3 ff ff       	call   8001f0 <_panic>

	// Oh my god, I forget this at the first, it waste me a lot of time to debug!!!
	addr = ROUNDDOWN(addr, PGSIZE);
  800ec5:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	
	memcpy(PFTEMP, addr, PGSIZE);
  800ecb:	83 ec 04             	sub    $0x4,%esp
  800ece:	68 00 10 00 00       	push   $0x1000
  800ed3:	53                   	push   %ebx
  800ed4:	68 00 f0 7f 00       	push   $0x7ff000
  800ed9:	e8 cb fb ff ff       	call   800aa9 <memcpy>
	
	r = sys_page_map(0, PFTEMP, 0, addr, PTE_W | PTE_U | PTE_P);
  800ede:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800ee5:	53                   	push   %ebx
  800ee6:	6a 00                	push   $0x0
  800ee8:	68 00 f0 7f 00       	push   $0x7ff000
  800eed:	6a 00                	push   $0x0
  800eef:	e8 30 fe ff ff       	call   800d24 <sys_page_map>
	if (r < 0) panic("pgfault, sys_page_map error : %e\n", r);
  800ef4:	83 c4 20             	add    $0x20,%esp
  800ef7:	85 c0                	test   %eax,%eax
  800ef9:	79 12                	jns    800f0d <pgfault+0xcd>
  800efb:	50                   	push   %eax
  800efc:	68 18 2d 80 00       	push   $0x802d18
  800f01:	6a 3a                	push   $0x3a
  800f03:	68 f0 2d 80 00       	push   $0x802df0
  800f08:	e8 e3 f2 ff ff       	call   8001f0 <_panic>

	return;
}
  800f0d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f10:	c9                   	leave  
  800f11:	c3                   	ret    

00800f12 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800f12:	55                   	push   %ebp
  800f13:	89 e5                	mov    %esp,%ebp
  800f15:	57                   	push   %edi
  800f16:	56                   	push   %esi
  800f17:	53                   	push   %ebx
  800f18:	83 ec 28             	sub    $0x28,%esp
	// static int num = 0x100;

	// LAB 4: Your code here.
	set_pgfault_handler(pgfault);
  800f1b:	68 40 0e 80 00       	push   $0x800e40
  800f20:	e8 fb 14 00 00       	call   802420 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  800f25:	ba 07 00 00 00       	mov    $0x7,%edx
  800f2a:	89 d0                	mov    %edx,%eax
  800f2c:	cd 30                	int    $0x30
  800f2e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800f31:	89 c7                	mov    %eax,%edi
	int childpid = sys_exofork();
	if (childpid < 0) {
  800f33:	83 c4 10             	add    $0x10,%esp
  800f36:	85 c0                	test   %eax,%eax
  800f38:	79 12                	jns    800f4c <fork+0x3a>
		panic("fork sys_exofork error : %e\n", childpid);
  800f3a:	50                   	push   %eax
  800f3b:	68 fb 2d 80 00       	push   $0x802dfb
  800f40:	6a 7b                	push   $0x7b
  800f42:	68 f0 2d 80 00       	push   $0x802df0
  800f47:	e8 a4 f2 ff ff       	call   8001f0 <_panic>
	}
	int r;

	if (childpid == 0) {
  800f4c:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800f50:	75 25                	jne    800f77 <fork+0x65>
		// child process
		// Remember to fix "thisenv" in the child process. ??? 
		thisenv = &envs[ENVX(sys_getenvid())];
  800f52:	e8 5e fd ff ff       	call   800cb5 <sys_getenvid>
  800f57:	25 ff 03 00 00       	and    $0x3ff,%eax
  800f5c:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800f63:	c1 e0 07             	shl    $0x7,%eax
  800f66:	29 d0                	sub    %edx,%eax
  800f68:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800f6d:	a3 04 50 80 00       	mov    %eax,0x805004
		// cprintf("fork child ok\n");
		return 0;
  800f72:	e9 7b 01 00 00       	jmp    8010f2 <fork+0x1e0>
	if (childpid < 0) {
		panic("fork sys_exofork error : %e\n", childpid);
	}
	int r;

	if (childpid == 0) {
  800f77:	bb 00 00 00 00       	mov    $0x0,%ebx
	} else {
		// map page to new environment
		// kernel page is already in new environment
		uint32_t i;
		for (i = 0; i != UTOP; i += PGSIZE) 
		if ((uvpd[PDX(i)] & PTE_P) && (uvpt[i / PGSIZE] & PTE_P) && (uvpt[i / PGSIZE] & PTE_U)) {
  800f7c:	89 d8                	mov    %ebx,%eax
  800f7e:	c1 e8 16             	shr    $0x16,%eax
  800f81:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800f88:	a8 01                	test   $0x1,%al
  800f8a:	0f 84 cd 00 00 00    	je     80105d <fork+0x14b>
  800f90:	89 d8                	mov    %ebx,%eax
  800f92:	c1 e8 0c             	shr    $0xc,%eax
  800f95:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800f9c:	f6 c2 01             	test   $0x1,%dl
  800f9f:	0f 84 b8 00 00 00    	je     80105d <fork+0x14b>
  800fa5:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800fac:	f6 c2 04             	test   $0x4,%dl
  800faf:	0f 84 a8 00 00 00    	je     80105d <fork+0x14b>
//
static int
duppage(envid_t envid, unsigned pn)
{
	// do not dup exception stack
	if (pn * PGSIZE == UXSTACKTOP - PGSIZE) return 0;
  800fb5:	89 c6                	mov    %eax,%esi
  800fb7:	c1 e6 0c             	shl    $0xc,%esi
  800fba:	81 fe 00 f0 bf ee    	cmp    $0xeebff000,%esi
  800fc0:	0f 84 97 00 00 00    	je     80105d <fork+0x14b>

	int r;
	void * addr = (void *)(pn * PGSIZE);
	if ((uvpt[pn] & PTE_W) || (uvpt[pn] & PTE_COW)) {
  800fc6:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800fcd:	f6 c2 02             	test   $0x2,%dl
  800fd0:	75 0c                	jne    800fde <fork+0xcc>
  800fd2:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800fd9:	f6 c4 08             	test   $0x8,%ah
  800fdc:	74 57                	je     801035 <fork+0x123>
		// cow
		r = sys_page_map(0, addr, envid, addr, PTE_COW | PTE_P | PTE_U);
  800fde:	83 ec 0c             	sub    $0xc,%esp
  800fe1:	68 05 08 00 00       	push   $0x805
  800fe6:	56                   	push   %esi
  800fe7:	57                   	push   %edi
  800fe8:	56                   	push   %esi
  800fe9:	6a 00                	push   $0x0
  800feb:	e8 34 fd ff ff       	call   800d24 <sys_page_map>
		if (r < 0) panic("duppage sys_page_map error : %e\n", r);
  800ff0:	83 c4 20             	add    $0x20,%esp
  800ff3:	85 c0                	test   %eax,%eax
  800ff5:	79 12                	jns    801009 <fork+0xf7>
  800ff7:	50                   	push   %eax
  800ff8:	68 3c 2d 80 00       	push   $0x802d3c
  800ffd:	6a 55                	push   $0x55
  800fff:	68 f0 2d 80 00       	push   $0x802df0
  801004:	e8 e7 f1 ff ff       	call   8001f0 <_panic>
		
		r = sys_page_map(0, addr, 0, addr, PTE_COW | PTE_P | PTE_U);
  801009:	83 ec 0c             	sub    $0xc,%esp
  80100c:	68 05 08 00 00       	push   $0x805
  801011:	56                   	push   %esi
  801012:	6a 00                	push   $0x0
  801014:	56                   	push   %esi
  801015:	6a 00                	push   $0x0
  801017:	e8 08 fd ff ff       	call   800d24 <sys_page_map>
		if (r < 0) panic("duppage sys_page_map error : %e\n", r);
  80101c:	83 c4 20             	add    $0x20,%esp
  80101f:	85 c0                	test   %eax,%eax
  801021:	79 3a                	jns    80105d <fork+0x14b>
  801023:	50                   	push   %eax
  801024:	68 3c 2d 80 00       	push   $0x802d3c
  801029:	6a 58                	push   $0x58
  80102b:	68 f0 2d 80 00       	push   $0x802df0
  801030:	e8 bb f1 ff ff       	call   8001f0 <_panic>
	} else {
		// read only
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U);
  801035:	83 ec 0c             	sub    $0xc,%esp
  801038:	6a 05                	push   $0x5
  80103a:	56                   	push   %esi
  80103b:	57                   	push   %edi
  80103c:	56                   	push   %esi
  80103d:	6a 00                	push   $0x0
  80103f:	e8 e0 fc ff ff       	call   800d24 <sys_page_map>
		if (r < 0) panic("duppage sys_page_map error : %e\n", r);
  801044:	83 c4 20             	add    $0x20,%esp
  801047:	85 c0                	test   %eax,%eax
  801049:	79 12                	jns    80105d <fork+0x14b>
  80104b:	50                   	push   %eax
  80104c:	68 3c 2d 80 00       	push   $0x802d3c
  801051:	6a 5c                	push   $0x5c
  801053:	68 f0 2d 80 00       	push   $0x802df0
  801058:	e8 93 f1 ff ff       	call   8001f0 <_panic>
		return 0;
	} else {
		// map page to new environment
		// kernel page is already in new environment
		uint32_t i;
		for (i = 0; i != UTOP; i += PGSIZE) 
  80105d:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801063:	81 fb 00 00 c0 ee    	cmp    $0xeec00000,%ebx
  801069:	0f 85 0d ff ff ff    	jne    800f7c <fork+0x6a>
		if ((uvpd[PDX(i)] & PTE_P) && (uvpt[i / PGSIZE] & PTE_P) && (uvpt[i / PGSIZE] & PTE_U)) {
			duppage(childpid, i / PGSIZE);
		}

		// allocate exception stack
		r = sys_page_alloc(childpid, (void *)(UXSTACKTOP - PGSIZE), PTE_U | PTE_W | PTE_P);
  80106f:	83 ec 04             	sub    $0x4,%esp
  801072:	6a 07                	push   $0x7
  801074:	68 00 f0 bf ee       	push   $0xeebff000
  801079:	ff 75 e4             	pushl  -0x1c(%ebp)
  80107c:	e8 7f fc ff ff       	call   800d00 <sys_page_alloc>
		if (r < 0) panic("fork, sys_page_alloc user exception stack error : %e\n", r);
  801081:	83 c4 10             	add    $0x10,%esp
  801084:	85 c0                	test   %eax,%eax
  801086:	79 15                	jns    80109d <fork+0x18b>
  801088:	50                   	push   %eax
  801089:	68 60 2d 80 00       	push   $0x802d60
  80108e:	68 90 00 00 00       	push   $0x90
  801093:	68 f0 2d 80 00       	push   $0x802df0
  801098:	e8 53 f1 ff ff       	call   8001f0 <_panic>

		// set user environment user page fault handler 
		extern void _pgfault_upcall(void);
		r = sys_env_set_pgfault_upcall(childpid, _pgfault_upcall);
  80109d:	83 ec 08             	sub    $0x8,%esp
  8010a0:	68 8c 24 80 00       	push   $0x80248c
  8010a5:	ff 75 e4             	pushl  -0x1c(%ebp)
  8010a8:	e8 06 fd ff ff       	call   800db3 <sys_env_set_pgfault_upcall>
		if (r < 0) panic("fork, set pgfault upcall fail : %e\n", r);
  8010ad:	83 c4 10             	add    $0x10,%esp
  8010b0:	85 c0                	test   %eax,%eax
  8010b2:	79 15                	jns    8010c9 <fork+0x1b7>
  8010b4:	50                   	push   %eax
  8010b5:	68 98 2d 80 00       	push   $0x802d98
  8010ba:	68 95 00 00 00       	push   $0x95
  8010bf:	68 f0 2d 80 00       	push   $0x802df0
  8010c4:	e8 27 f1 ff ff       	call   8001f0 <_panic>
		r = sys_set_priority(childpid, num);
		if (r < 0) panic("fork, set priority error\n");
		*/

		// mark the child as runnable and return
		r = sys_env_set_status(childpid, ENV_RUNNABLE);
  8010c9:	83 ec 08             	sub    $0x8,%esp
  8010cc:	6a 02                	push   $0x2
  8010ce:	ff 75 e4             	pushl  -0x1c(%ebp)
  8010d1:	e8 97 fc ff ff       	call   800d6d <sys_env_set_status>
		if (r < 0) panic("fork, set child process to ENV_RUNNABLE error : %e\n", r);
  8010d6:	83 c4 10             	add    $0x10,%esp
  8010d9:	85 c0                	test   %eax,%eax
  8010db:	79 15                	jns    8010f2 <fork+0x1e0>
  8010dd:	50                   	push   %eax
  8010de:	68 bc 2d 80 00       	push   $0x802dbc
  8010e3:	68 a0 00 00 00       	push   $0xa0
  8010e8:	68 f0 2d 80 00       	push   $0x802df0
  8010ed:	e8 fe f0 ff ff       	call   8001f0 <_panic>
		// cprintf("fork father ok!")
		return childpid;
	}

	panic("fork not implemented");
}
  8010f2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8010f5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010f8:	5b                   	pop    %ebx
  8010f9:	5e                   	pop    %esi
  8010fa:	5f                   	pop    %edi
  8010fb:	c9                   	leave  
  8010fc:	c3                   	ret    

008010fd <sfork>:

// Challenge!
int
sfork(void)
{
  8010fd:	55                   	push   %ebp
  8010fe:	89 e5                	mov    %esp,%ebp
  801100:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  801103:	68 18 2e 80 00       	push   $0x802e18
  801108:	68 ad 00 00 00       	push   $0xad
  80110d:	68 f0 2d 80 00       	push   $0x802df0
  801112:	e8 d9 f0 ff ff       	call   8001f0 <_panic>
	...

00801118 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801118:	55                   	push   %ebp
  801119:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80111b:	8b 45 08             	mov    0x8(%ebp),%eax
  80111e:	05 00 00 00 30       	add    $0x30000000,%eax
  801123:	c1 e8 0c             	shr    $0xc,%eax
}
  801126:	c9                   	leave  
  801127:	c3                   	ret    

00801128 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801128:	55                   	push   %ebp
  801129:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  80112b:	ff 75 08             	pushl  0x8(%ebp)
  80112e:	e8 e5 ff ff ff       	call   801118 <fd2num>
  801133:	83 c4 04             	add    $0x4,%esp
  801136:	05 20 00 0d 00       	add    $0xd0020,%eax
  80113b:	c1 e0 0c             	shl    $0xc,%eax
}
  80113e:	c9                   	leave  
  80113f:	c3                   	ret    

00801140 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801140:	55                   	push   %ebp
  801141:	89 e5                	mov    %esp,%ebp
  801143:	53                   	push   %ebx
  801144:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801147:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  80114c:	a8 01                	test   $0x1,%al
  80114e:	74 34                	je     801184 <fd_alloc+0x44>
  801150:	a1 00 00 74 ef       	mov    0xef740000,%eax
  801155:	a8 01                	test   $0x1,%al
  801157:	74 32                	je     80118b <fd_alloc+0x4b>
  801159:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
  80115e:	89 c1                	mov    %eax,%ecx
  801160:	89 c2                	mov    %eax,%edx
  801162:	c1 ea 16             	shr    $0x16,%edx
  801165:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80116c:	f6 c2 01             	test   $0x1,%dl
  80116f:	74 1f                	je     801190 <fd_alloc+0x50>
  801171:	89 c2                	mov    %eax,%edx
  801173:	c1 ea 0c             	shr    $0xc,%edx
  801176:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80117d:	f6 c2 01             	test   $0x1,%dl
  801180:	75 17                	jne    801199 <fd_alloc+0x59>
  801182:	eb 0c                	jmp    801190 <fd_alloc+0x50>
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  801184:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
  801189:	eb 05                	jmp    801190 <fd_alloc+0x50>
  80118b:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
  801190:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  801192:	b8 00 00 00 00       	mov    $0x0,%eax
  801197:	eb 17                	jmp    8011b0 <fd_alloc+0x70>
  801199:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  80119e:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8011a3:	75 b9                	jne    80115e <fd_alloc+0x1e>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8011a5:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  8011ab:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8011b0:	5b                   	pop    %ebx
  8011b1:	c9                   	leave  
  8011b2:	c3                   	ret    

008011b3 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8011b3:	55                   	push   %ebp
  8011b4:	89 e5                	mov    %esp,%ebp
  8011b6:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8011b9:	83 f8 1f             	cmp    $0x1f,%eax
  8011bc:	77 36                	ja     8011f4 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8011be:	05 00 00 0d 00       	add    $0xd0000,%eax
  8011c3:	c1 e0 0c             	shl    $0xc,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8011c6:	89 c2                	mov    %eax,%edx
  8011c8:	c1 ea 16             	shr    $0x16,%edx
  8011cb:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8011d2:	f6 c2 01             	test   $0x1,%dl
  8011d5:	74 24                	je     8011fb <fd_lookup+0x48>
  8011d7:	89 c2                	mov    %eax,%edx
  8011d9:	c1 ea 0c             	shr    $0xc,%edx
  8011dc:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8011e3:	f6 c2 01             	test   $0x1,%dl
  8011e6:	74 1a                	je     801202 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8011e8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8011eb:	89 02                	mov    %eax,(%edx)
	return 0;
  8011ed:	b8 00 00 00 00       	mov    $0x0,%eax
  8011f2:	eb 13                	jmp    801207 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8011f4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8011f9:	eb 0c                	jmp    801207 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8011fb:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801200:	eb 05                	jmp    801207 <fd_lookup+0x54>
  801202:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801207:	c9                   	leave  
  801208:	c3                   	ret    

00801209 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801209:	55                   	push   %ebp
  80120a:	89 e5                	mov    %esp,%ebp
  80120c:	53                   	push   %ebx
  80120d:	83 ec 04             	sub    $0x4,%esp
  801210:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801213:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  801216:	39 0d 0c 40 80 00    	cmp    %ecx,0x80400c
  80121c:	74 0d                	je     80122b <dev_lookup+0x22>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80121e:	b8 00 00 00 00       	mov    $0x0,%eax
  801223:	eb 14                	jmp    801239 <dev_lookup+0x30>
		if (devtab[i]->dev_id == dev_id) {
  801225:	39 0a                	cmp    %ecx,(%edx)
  801227:	75 10                	jne    801239 <dev_lookup+0x30>
  801229:	eb 05                	jmp    801230 <dev_lookup+0x27>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80122b:	ba 0c 40 80 00       	mov    $0x80400c,%edx
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
  801230:	89 13                	mov    %edx,(%ebx)
			return 0;
  801232:	b8 00 00 00 00       	mov    $0x0,%eax
  801237:	eb 31                	jmp    80126a <dev_lookup+0x61>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801239:	40                   	inc    %eax
  80123a:	8b 14 85 ac 2e 80 00 	mov    0x802eac(,%eax,4),%edx
  801241:	85 d2                	test   %edx,%edx
  801243:	75 e0                	jne    801225 <dev_lookup+0x1c>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801245:	a1 04 50 80 00       	mov    0x805004,%eax
  80124a:	8b 40 48             	mov    0x48(%eax),%eax
  80124d:	83 ec 04             	sub    $0x4,%esp
  801250:	51                   	push   %ecx
  801251:	50                   	push   %eax
  801252:	68 30 2e 80 00       	push   $0x802e30
  801257:	e8 6c f0 ff ff       	call   8002c8 <cprintf>
	*dev = 0;
  80125c:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  801262:	83 c4 10             	add    $0x10,%esp
  801265:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80126a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80126d:	c9                   	leave  
  80126e:	c3                   	ret    

0080126f <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80126f:	55                   	push   %ebp
  801270:	89 e5                	mov    %esp,%ebp
  801272:	56                   	push   %esi
  801273:	53                   	push   %ebx
  801274:	83 ec 20             	sub    $0x20,%esp
  801277:	8b 75 08             	mov    0x8(%ebp),%esi
  80127a:	8a 45 0c             	mov    0xc(%ebp),%al
  80127d:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801280:	56                   	push   %esi
  801281:	e8 92 fe ff ff       	call   801118 <fd2num>
  801286:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801289:	89 14 24             	mov    %edx,(%esp)
  80128c:	50                   	push   %eax
  80128d:	e8 21 ff ff ff       	call   8011b3 <fd_lookup>
  801292:	89 c3                	mov    %eax,%ebx
  801294:	83 c4 08             	add    $0x8,%esp
  801297:	85 c0                	test   %eax,%eax
  801299:	78 05                	js     8012a0 <fd_close+0x31>
	    || fd != fd2)
  80129b:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80129e:	74 0d                	je     8012ad <fd_close+0x3e>
		return (must_exist ? r : 0);
  8012a0:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  8012a4:	75 48                	jne    8012ee <fd_close+0x7f>
  8012a6:	bb 00 00 00 00       	mov    $0x0,%ebx
  8012ab:	eb 41                	jmp    8012ee <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8012ad:	83 ec 08             	sub    $0x8,%esp
  8012b0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012b3:	50                   	push   %eax
  8012b4:	ff 36                	pushl  (%esi)
  8012b6:	e8 4e ff ff ff       	call   801209 <dev_lookup>
  8012bb:	89 c3                	mov    %eax,%ebx
  8012bd:	83 c4 10             	add    $0x10,%esp
  8012c0:	85 c0                	test   %eax,%eax
  8012c2:	78 1c                	js     8012e0 <fd_close+0x71>
		if (dev->dev_close)
  8012c4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012c7:	8b 40 10             	mov    0x10(%eax),%eax
  8012ca:	85 c0                	test   %eax,%eax
  8012cc:	74 0d                	je     8012db <fd_close+0x6c>
			r = (*dev->dev_close)(fd);
  8012ce:	83 ec 0c             	sub    $0xc,%esp
  8012d1:	56                   	push   %esi
  8012d2:	ff d0                	call   *%eax
  8012d4:	89 c3                	mov    %eax,%ebx
  8012d6:	83 c4 10             	add    $0x10,%esp
  8012d9:	eb 05                	jmp    8012e0 <fd_close+0x71>
		else
			r = 0;
  8012db:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8012e0:	83 ec 08             	sub    $0x8,%esp
  8012e3:	56                   	push   %esi
  8012e4:	6a 00                	push   $0x0
  8012e6:	e8 5f fa ff ff       	call   800d4a <sys_page_unmap>
	return r;
  8012eb:	83 c4 10             	add    $0x10,%esp
}
  8012ee:	89 d8                	mov    %ebx,%eax
  8012f0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8012f3:	5b                   	pop    %ebx
  8012f4:	5e                   	pop    %esi
  8012f5:	c9                   	leave  
  8012f6:	c3                   	ret    

008012f7 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8012f7:	55                   	push   %ebp
  8012f8:	89 e5                	mov    %esp,%ebp
  8012fa:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8012fd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801300:	50                   	push   %eax
  801301:	ff 75 08             	pushl  0x8(%ebp)
  801304:	e8 aa fe ff ff       	call   8011b3 <fd_lookup>
  801309:	83 c4 08             	add    $0x8,%esp
  80130c:	85 c0                	test   %eax,%eax
  80130e:	78 10                	js     801320 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801310:	83 ec 08             	sub    $0x8,%esp
  801313:	6a 01                	push   $0x1
  801315:	ff 75 f4             	pushl  -0xc(%ebp)
  801318:	e8 52 ff ff ff       	call   80126f <fd_close>
  80131d:	83 c4 10             	add    $0x10,%esp
}
  801320:	c9                   	leave  
  801321:	c3                   	ret    

00801322 <close_all>:

void
close_all(void)
{
  801322:	55                   	push   %ebp
  801323:	89 e5                	mov    %esp,%ebp
  801325:	53                   	push   %ebx
  801326:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801329:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80132e:	83 ec 0c             	sub    $0xc,%esp
  801331:	53                   	push   %ebx
  801332:	e8 c0 ff ff ff       	call   8012f7 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801337:	43                   	inc    %ebx
  801338:	83 c4 10             	add    $0x10,%esp
  80133b:	83 fb 20             	cmp    $0x20,%ebx
  80133e:	75 ee                	jne    80132e <close_all+0xc>
		close(i);
}
  801340:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801343:	c9                   	leave  
  801344:	c3                   	ret    

00801345 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801345:	55                   	push   %ebp
  801346:	89 e5                	mov    %esp,%ebp
  801348:	57                   	push   %edi
  801349:	56                   	push   %esi
  80134a:	53                   	push   %ebx
  80134b:	83 ec 2c             	sub    $0x2c,%esp
  80134e:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801351:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801354:	50                   	push   %eax
  801355:	ff 75 08             	pushl  0x8(%ebp)
  801358:	e8 56 fe ff ff       	call   8011b3 <fd_lookup>
  80135d:	89 c3                	mov    %eax,%ebx
  80135f:	83 c4 08             	add    $0x8,%esp
  801362:	85 c0                	test   %eax,%eax
  801364:	0f 88 c0 00 00 00    	js     80142a <dup+0xe5>
		return r;
	close(newfdnum);
  80136a:	83 ec 0c             	sub    $0xc,%esp
  80136d:	57                   	push   %edi
  80136e:	e8 84 ff ff ff       	call   8012f7 <close>

	newfd = INDEX2FD(newfdnum);
  801373:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  801379:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  80137c:	83 c4 04             	add    $0x4,%esp
  80137f:	ff 75 e4             	pushl  -0x1c(%ebp)
  801382:	e8 a1 fd ff ff       	call   801128 <fd2data>
  801387:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801389:	89 34 24             	mov    %esi,(%esp)
  80138c:	e8 97 fd ff ff       	call   801128 <fd2data>
  801391:	83 c4 10             	add    $0x10,%esp
  801394:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801397:	89 d8                	mov    %ebx,%eax
  801399:	c1 e8 16             	shr    $0x16,%eax
  80139c:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8013a3:	a8 01                	test   $0x1,%al
  8013a5:	74 37                	je     8013de <dup+0x99>
  8013a7:	89 d8                	mov    %ebx,%eax
  8013a9:	c1 e8 0c             	shr    $0xc,%eax
  8013ac:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8013b3:	f6 c2 01             	test   $0x1,%dl
  8013b6:	74 26                	je     8013de <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8013b8:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8013bf:	83 ec 0c             	sub    $0xc,%esp
  8013c2:	25 07 0e 00 00       	and    $0xe07,%eax
  8013c7:	50                   	push   %eax
  8013c8:	ff 75 d4             	pushl  -0x2c(%ebp)
  8013cb:	6a 00                	push   $0x0
  8013cd:	53                   	push   %ebx
  8013ce:	6a 00                	push   $0x0
  8013d0:	e8 4f f9 ff ff       	call   800d24 <sys_page_map>
  8013d5:	89 c3                	mov    %eax,%ebx
  8013d7:	83 c4 20             	add    $0x20,%esp
  8013da:	85 c0                	test   %eax,%eax
  8013dc:	78 2d                	js     80140b <dup+0xc6>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8013de:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8013e1:	89 c2                	mov    %eax,%edx
  8013e3:	c1 ea 0c             	shr    $0xc,%edx
  8013e6:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8013ed:	83 ec 0c             	sub    $0xc,%esp
  8013f0:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  8013f6:	52                   	push   %edx
  8013f7:	56                   	push   %esi
  8013f8:	6a 00                	push   $0x0
  8013fa:	50                   	push   %eax
  8013fb:	6a 00                	push   $0x0
  8013fd:	e8 22 f9 ff ff       	call   800d24 <sys_page_map>
  801402:	89 c3                	mov    %eax,%ebx
  801404:	83 c4 20             	add    $0x20,%esp
  801407:	85 c0                	test   %eax,%eax
  801409:	79 1d                	jns    801428 <dup+0xe3>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80140b:	83 ec 08             	sub    $0x8,%esp
  80140e:	56                   	push   %esi
  80140f:	6a 00                	push   $0x0
  801411:	e8 34 f9 ff ff       	call   800d4a <sys_page_unmap>
	sys_page_unmap(0, nva);
  801416:	83 c4 08             	add    $0x8,%esp
  801419:	ff 75 d4             	pushl  -0x2c(%ebp)
  80141c:	6a 00                	push   $0x0
  80141e:	e8 27 f9 ff ff       	call   800d4a <sys_page_unmap>
	return r;
  801423:	83 c4 10             	add    $0x10,%esp
  801426:	eb 02                	jmp    80142a <dup+0xe5>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  801428:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  80142a:	89 d8                	mov    %ebx,%eax
  80142c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80142f:	5b                   	pop    %ebx
  801430:	5e                   	pop    %esi
  801431:	5f                   	pop    %edi
  801432:	c9                   	leave  
  801433:	c3                   	ret    

00801434 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801434:	55                   	push   %ebp
  801435:	89 e5                	mov    %esp,%ebp
  801437:	53                   	push   %ebx
  801438:	83 ec 14             	sub    $0x14,%esp
  80143b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80143e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801441:	50                   	push   %eax
  801442:	53                   	push   %ebx
  801443:	e8 6b fd ff ff       	call   8011b3 <fd_lookup>
  801448:	83 c4 08             	add    $0x8,%esp
  80144b:	85 c0                	test   %eax,%eax
  80144d:	78 67                	js     8014b6 <read+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80144f:	83 ec 08             	sub    $0x8,%esp
  801452:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801455:	50                   	push   %eax
  801456:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801459:	ff 30                	pushl  (%eax)
  80145b:	e8 a9 fd ff ff       	call   801209 <dev_lookup>
  801460:	83 c4 10             	add    $0x10,%esp
  801463:	85 c0                	test   %eax,%eax
  801465:	78 4f                	js     8014b6 <read+0x82>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801467:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80146a:	8b 50 08             	mov    0x8(%eax),%edx
  80146d:	83 e2 03             	and    $0x3,%edx
  801470:	83 fa 01             	cmp    $0x1,%edx
  801473:	75 21                	jne    801496 <read+0x62>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801475:	a1 04 50 80 00       	mov    0x805004,%eax
  80147a:	8b 40 48             	mov    0x48(%eax),%eax
  80147d:	83 ec 04             	sub    $0x4,%esp
  801480:	53                   	push   %ebx
  801481:	50                   	push   %eax
  801482:	68 71 2e 80 00       	push   $0x802e71
  801487:	e8 3c ee ff ff       	call   8002c8 <cprintf>
		return -E_INVAL;
  80148c:	83 c4 10             	add    $0x10,%esp
  80148f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801494:	eb 20                	jmp    8014b6 <read+0x82>
	}
	if (!dev->dev_read)
  801496:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801499:	8b 52 08             	mov    0x8(%edx),%edx
  80149c:	85 d2                	test   %edx,%edx
  80149e:	74 11                	je     8014b1 <read+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8014a0:	83 ec 04             	sub    $0x4,%esp
  8014a3:	ff 75 10             	pushl  0x10(%ebp)
  8014a6:	ff 75 0c             	pushl  0xc(%ebp)
  8014a9:	50                   	push   %eax
  8014aa:	ff d2                	call   *%edx
  8014ac:	83 c4 10             	add    $0x10,%esp
  8014af:	eb 05                	jmp    8014b6 <read+0x82>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8014b1:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  8014b6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014b9:	c9                   	leave  
  8014ba:	c3                   	ret    

008014bb <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8014bb:	55                   	push   %ebp
  8014bc:	89 e5                	mov    %esp,%ebp
  8014be:	57                   	push   %edi
  8014bf:	56                   	push   %esi
  8014c0:	53                   	push   %ebx
  8014c1:	83 ec 0c             	sub    $0xc,%esp
  8014c4:	8b 7d 08             	mov    0x8(%ebp),%edi
  8014c7:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8014ca:	85 f6                	test   %esi,%esi
  8014cc:	74 31                	je     8014ff <readn+0x44>
  8014ce:	b8 00 00 00 00       	mov    $0x0,%eax
  8014d3:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = read(fdnum, (char*)buf + tot, n - tot);
  8014d8:	83 ec 04             	sub    $0x4,%esp
  8014db:	89 f2                	mov    %esi,%edx
  8014dd:	29 c2                	sub    %eax,%edx
  8014df:	52                   	push   %edx
  8014e0:	03 45 0c             	add    0xc(%ebp),%eax
  8014e3:	50                   	push   %eax
  8014e4:	57                   	push   %edi
  8014e5:	e8 4a ff ff ff       	call   801434 <read>
		if (m < 0)
  8014ea:	83 c4 10             	add    $0x10,%esp
  8014ed:	85 c0                	test   %eax,%eax
  8014ef:	78 17                	js     801508 <readn+0x4d>
			return m;
		if (m == 0)
  8014f1:	85 c0                	test   %eax,%eax
  8014f3:	74 11                	je     801506 <readn+0x4b>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8014f5:	01 c3                	add    %eax,%ebx
  8014f7:	89 d8                	mov    %ebx,%eax
  8014f9:	39 f3                	cmp    %esi,%ebx
  8014fb:	72 db                	jb     8014d8 <readn+0x1d>
  8014fd:	eb 09                	jmp    801508 <readn+0x4d>
  8014ff:	b8 00 00 00 00       	mov    $0x0,%eax
  801504:	eb 02                	jmp    801508 <readn+0x4d>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  801506:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  801508:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80150b:	5b                   	pop    %ebx
  80150c:	5e                   	pop    %esi
  80150d:	5f                   	pop    %edi
  80150e:	c9                   	leave  
  80150f:	c3                   	ret    

00801510 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801510:	55                   	push   %ebp
  801511:	89 e5                	mov    %esp,%ebp
  801513:	53                   	push   %ebx
  801514:	83 ec 14             	sub    $0x14,%esp
  801517:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80151a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80151d:	50                   	push   %eax
  80151e:	53                   	push   %ebx
  80151f:	e8 8f fc ff ff       	call   8011b3 <fd_lookup>
  801524:	83 c4 08             	add    $0x8,%esp
  801527:	85 c0                	test   %eax,%eax
  801529:	78 62                	js     80158d <write+0x7d>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80152b:	83 ec 08             	sub    $0x8,%esp
  80152e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801531:	50                   	push   %eax
  801532:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801535:	ff 30                	pushl  (%eax)
  801537:	e8 cd fc ff ff       	call   801209 <dev_lookup>
  80153c:	83 c4 10             	add    $0x10,%esp
  80153f:	85 c0                	test   %eax,%eax
  801541:	78 4a                	js     80158d <write+0x7d>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801543:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801546:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80154a:	75 21                	jne    80156d <write+0x5d>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80154c:	a1 04 50 80 00       	mov    0x805004,%eax
  801551:	8b 40 48             	mov    0x48(%eax),%eax
  801554:	83 ec 04             	sub    $0x4,%esp
  801557:	53                   	push   %ebx
  801558:	50                   	push   %eax
  801559:	68 8d 2e 80 00       	push   $0x802e8d
  80155e:	e8 65 ed ff ff       	call   8002c8 <cprintf>
		return -E_INVAL;
  801563:	83 c4 10             	add    $0x10,%esp
  801566:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80156b:	eb 20                	jmp    80158d <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80156d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801570:	8b 52 0c             	mov    0xc(%edx),%edx
  801573:	85 d2                	test   %edx,%edx
  801575:	74 11                	je     801588 <write+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801577:	83 ec 04             	sub    $0x4,%esp
  80157a:	ff 75 10             	pushl  0x10(%ebp)
  80157d:	ff 75 0c             	pushl  0xc(%ebp)
  801580:	50                   	push   %eax
  801581:	ff d2                	call   *%edx
  801583:	83 c4 10             	add    $0x10,%esp
  801586:	eb 05                	jmp    80158d <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801588:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  80158d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801590:	c9                   	leave  
  801591:	c3                   	ret    

00801592 <seek>:

int
seek(int fdnum, off_t offset)
{
  801592:	55                   	push   %ebp
  801593:	89 e5                	mov    %esp,%ebp
  801595:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801598:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80159b:	50                   	push   %eax
  80159c:	ff 75 08             	pushl  0x8(%ebp)
  80159f:	e8 0f fc ff ff       	call   8011b3 <fd_lookup>
  8015a4:	83 c4 08             	add    $0x8,%esp
  8015a7:	85 c0                	test   %eax,%eax
  8015a9:	78 0e                	js     8015b9 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8015ab:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8015ae:	8b 55 0c             	mov    0xc(%ebp),%edx
  8015b1:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8015b4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8015b9:	c9                   	leave  
  8015ba:	c3                   	ret    

008015bb <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8015bb:	55                   	push   %ebp
  8015bc:	89 e5                	mov    %esp,%ebp
  8015be:	53                   	push   %ebx
  8015bf:	83 ec 14             	sub    $0x14,%esp
  8015c2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015c5:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015c8:	50                   	push   %eax
  8015c9:	53                   	push   %ebx
  8015ca:	e8 e4 fb ff ff       	call   8011b3 <fd_lookup>
  8015cf:	83 c4 08             	add    $0x8,%esp
  8015d2:	85 c0                	test   %eax,%eax
  8015d4:	78 5f                	js     801635 <ftruncate+0x7a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015d6:	83 ec 08             	sub    $0x8,%esp
  8015d9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015dc:	50                   	push   %eax
  8015dd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015e0:	ff 30                	pushl  (%eax)
  8015e2:	e8 22 fc ff ff       	call   801209 <dev_lookup>
  8015e7:	83 c4 10             	add    $0x10,%esp
  8015ea:	85 c0                	test   %eax,%eax
  8015ec:	78 47                	js     801635 <ftruncate+0x7a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8015ee:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015f1:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8015f5:	75 21                	jne    801618 <ftruncate+0x5d>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8015f7:	a1 04 50 80 00       	mov    0x805004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8015fc:	8b 40 48             	mov    0x48(%eax),%eax
  8015ff:	83 ec 04             	sub    $0x4,%esp
  801602:	53                   	push   %ebx
  801603:	50                   	push   %eax
  801604:	68 50 2e 80 00       	push   $0x802e50
  801609:	e8 ba ec ff ff       	call   8002c8 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80160e:	83 c4 10             	add    $0x10,%esp
  801611:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801616:	eb 1d                	jmp    801635 <ftruncate+0x7a>
	}
	if (!dev->dev_trunc)
  801618:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80161b:	8b 52 18             	mov    0x18(%edx),%edx
  80161e:	85 d2                	test   %edx,%edx
  801620:	74 0e                	je     801630 <ftruncate+0x75>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801622:	83 ec 08             	sub    $0x8,%esp
  801625:	ff 75 0c             	pushl  0xc(%ebp)
  801628:	50                   	push   %eax
  801629:	ff d2                	call   *%edx
  80162b:	83 c4 10             	add    $0x10,%esp
  80162e:	eb 05                	jmp    801635 <ftruncate+0x7a>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801630:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  801635:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801638:	c9                   	leave  
  801639:	c3                   	ret    

0080163a <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80163a:	55                   	push   %ebp
  80163b:	89 e5                	mov    %esp,%ebp
  80163d:	53                   	push   %ebx
  80163e:	83 ec 14             	sub    $0x14,%esp
  801641:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801644:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801647:	50                   	push   %eax
  801648:	ff 75 08             	pushl  0x8(%ebp)
  80164b:	e8 63 fb ff ff       	call   8011b3 <fd_lookup>
  801650:	83 c4 08             	add    $0x8,%esp
  801653:	85 c0                	test   %eax,%eax
  801655:	78 52                	js     8016a9 <fstat+0x6f>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801657:	83 ec 08             	sub    $0x8,%esp
  80165a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80165d:	50                   	push   %eax
  80165e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801661:	ff 30                	pushl  (%eax)
  801663:	e8 a1 fb ff ff       	call   801209 <dev_lookup>
  801668:	83 c4 10             	add    $0x10,%esp
  80166b:	85 c0                	test   %eax,%eax
  80166d:	78 3a                	js     8016a9 <fstat+0x6f>
		return r;
	if (!dev->dev_stat)
  80166f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801672:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801676:	74 2c                	je     8016a4 <fstat+0x6a>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801678:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80167b:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801682:	00 00 00 
	stat->st_isdir = 0;
  801685:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80168c:	00 00 00 
	stat->st_dev = dev;
  80168f:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801695:	83 ec 08             	sub    $0x8,%esp
  801698:	53                   	push   %ebx
  801699:	ff 75 f0             	pushl  -0x10(%ebp)
  80169c:	ff 50 14             	call   *0x14(%eax)
  80169f:	83 c4 10             	add    $0x10,%esp
  8016a2:	eb 05                	jmp    8016a9 <fstat+0x6f>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8016a4:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8016a9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016ac:	c9                   	leave  
  8016ad:	c3                   	ret    

008016ae <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8016ae:	55                   	push   %ebp
  8016af:	89 e5                	mov    %esp,%ebp
  8016b1:	56                   	push   %esi
  8016b2:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8016b3:	83 ec 08             	sub    $0x8,%esp
  8016b6:	6a 00                	push   $0x0
  8016b8:	ff 75 08             	pushl  0x8(%ebp)
  8016bb:	e8 8b 01 00 00       	call   80184b <open>
  8016c0:	89 c3                	mov    %eax,%ebx
  8016c2:	83 c4 10             	add    $0x10,%esp
  8016c5:	85 c0                	test   %eax,%eax
  8016c7:	78 1b                	js     8016e4 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8016c9:	83 ec 08             	sub    $0x8,%esp
  8016cc:	ff 75 0c             	pushl  0xc(%ebp)
  8016cf:	50                   	push   %eax
  8016d0:	e8 65 ff ff ff       	call   80163a <fstat>
  8016d5:	89 c6                	mov    %eax,%esi
	close(fd);
  8016d7:	89 1c 24             	mov    %ebx,(%esp)
  8016da:	e8 18 fc ff ff       	call   8012f7 <close>
	return r;
  8016df:	83 c4 10             	add    $0x10,%esp
  8016e2:	89 f3                	mov    %esi,%ebx
}
  8016e4:	89 d8                	mov    %ebx,%eax
  8016e6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8016e9:	5b                   	pop    %ebx
  8016ea:	5e                   	pop    %esi
  8016eb:	c9                   	leave  
  8016ec:	c3                   	ret    
  8016ed:	00 00                	add    %al,(%eax)
	...

008016f0 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8016f0:	55                   	push   %ebp
  8016f1:	89 e5                	mov    %esp,%ebp
  8016f3:	56                   	push   %esi
  8016f4:	53                   	push   %ebx
  8016f5:	89 c3                	mov    %eax,%ebx
  8016f7:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  8016f9:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  801700:	75 12                	jne    801714 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801702:	83 ec 0c             	sub    $0xc,%esp
  801705:	6a 01                	push   $0x1
  801707:	e8 a5 0e 00 00       	call   8025b1 <ipc_find_env>
  80170c:	a3 00 50 80 00       	mov    %eax,0x805000
  801711:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801714:	6a 07                	push   $0x7
  801716:	68 00 60 80 00       	push   $0x806000
  80171b:	53                   	push   %ebx
  80171c:	ff 35 00 50 80 00    	pushl  0x805000
  801722:	e8 35 0e 00 00       	call   80255c <ipc_send>
	
	return ipc_recv(NULL, dstva, NULL);
  801727:	83 c4 0c             	add    $0xc,%esp
  80172a:	6a 00                	push   $0x0
  80172c:	56                   	push   %esi
  80172d:	6a 00                	push   $0x0
  80172f:	e8 80 0d 00 00       	call   8024b4 <ipc_recv>
}
  801734:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801737:	5b                   	pop    %ebx
  801738:	5e                   	pop    %esi
  801739:	c9                   	leave  
  80173a:	c3                   	ret    

0080173b <devfile_stat>:
}


static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80173b:	55                   	push   %ebp
  80173c:	89 e5                	mov    %esp,%ebp
  80173e:	53                   	push   %ebx
  80173f:	83 ec 04             	sub    $0x4,%esp
  801742:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801745:	8b 45 08             	mov    0x8(%ebp),%eax
  801748:	8b 40 0c             	mov    0xc(%eax),%eax
  80174b:	a3 00 60 80 00       	mov    %eax,0x806000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0) {
  801750:	ba 00 00 00 00       	mov    $0x0,%edx
  801755:	b8 05 00 00 00       	mov    $0x5,%eax
  80175a:	e8 91 ff ff ff       	call   8016f0 <fsipc>
  80175f:	85 c0                	test   %eax,%eax
  801761:	78 39                	js     80179c <devfile_stat+0x61>
		return r;
	}
	cprintf("OVER\n");
  801763:	83 ec 0c             	sub    $0xc,%esp
  801766:	68 bc 2e 80 00       	push   $0x802ebc
  80176b:	e8 58 eb ff ff       	call   8002c8 <cprintf>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801770:	83 c4 08             	add    $0x8,%esp
  801773:	68 00 60 80 00       	push   $0x806000
  801778:	53                   	push   %ebx
  801779:	e8 00 f1 ff ff       	call   80087e <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  80177e:	a1 80 60 80 00       	mov    0x806080,%eax
  801783:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801789:	a1 84 60 80 00       	mov    0x806084,%eax
  80178e:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801794:	83 c4 10             	add    $0x10,%esp
  801797:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80179c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80179f:	c9                   	leave  
  8017a0:	c3                   	ret    

008017a1 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8017a1:	55                   	push   %ebp
  8017a2:	89 e5                	mov    %esp,%ebp
  8017a4:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8017a7:	8b 45 08             	mov    0x8(%ebp),%eax
  8017aa:	8b 40 0c             	mov    0xc(%eax),%eax
  8017ad:	a3 00 60 80 00       	mov    %eax,0x806000
	return fsipc(FSREQ_FLUSH, NULL);
  8017b2:	ba 00 00 00 00       	mov    $0x0,%edx
  8017b7:	b8 06 00 00 00       	mov    $0x6,%eax
  8017bc:	e8 2f ff ff ff       	call   8016f0 <fsipc>
}
  8017c1:	c9                   	leave  
  8017c2:	c3                   	ret    

008017c3 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8017c3:	55                   	push   %ebp
  8017c4:	89 e5                	mov    %esp,%ebp
  8017c6:	56                   	push   %esi
  8017c7:	53                   	push   %ebx
  8017c8:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8017cb:	8b 45 08             	mov    0x8(%ebp),%eax
  8017ce:	8b 40 0c             	mov    0xc(%eax),%eax
  8017d1:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.read.req_n = n;
  8017d6:	89 35 04 60 80 00    	mov    %esi,0x806004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8017dc:	ba 00 00 00 00       	mov    $0x0,%edx
  8017e1:	b8 03 00 00 00       	mov    $0x3,%eax
  8017e6:	e8 05 ff ff ff       	call   8016f0 <fsipc>
  8017eb:	89 c3                	mov    %eax,%ebx
  8017ed:	85 c0                	test   %eax,%eax
  8017ef:	78 51                	js     801842 <devfile_read+0x7f>
		return r;
	assert(r <= n);
  8017f1:	39 c6                	cmp    %eax,%esi
  8017f3:	73 19                	jae    80180e <devfile_read+0x4b>
  8017f5:	68 c2 2e 80 00       	push   $0x802ec2
  8017fa:	68 c9 2e 80 00       	push   $0x802ec9
  8017ff:	68 80 00 00 00       	push   $0x80
  801804:	68 de 2e 80 00       	push   $0x802ede
  801809:	e8 e2 e9 ff ff       	call   8001f0 <_panic>
	assert(r <= PGSIZE);
  80180e:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801813:	7e 19                	jle    80182e <devfile_read+0x6b>
  801815:	68 e9 2e 80 00       	push   $0x802ee9
  80181a:	68 c9 2e 80 00       	push   $0x802ec9
  80181f:	68 81 00 00 00       	push   $0x81
  801824:	68 de 2e 80 00       	push   $0x802ede
  801829:	e8 c2 e9 ff ff       	call   8001f0 <_panic>
	memmove(buf, &fsipcbuf, r);
  80182e:	83 ec 04             	sub    $0x4,%esp
  801831:	50                   	push   %eax
  801832:	68 00 60 80 00       	push   $0x806000
  801837:	ff 75 0c             	pushl  0xc(%ebp)
  80183a:	e8 00 f2 ff ff       	call   800a3f <memmove>
	return r;
  80183f:	83 c4 10             	add    $0x10,%esp
}
  801842:	89 d8                	mov    %ebx,%eax
  801844:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801847:	5b                   	pop    %ebx
  801848:	5e                   	pop    %esi
  801849:	c9                   	leave  
  80184a:	c3                   	ret    

0080184b <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  80184b:	55                   	push   %ebp
  80184c:	89 e5                	mov    %esp,%ebp
  80184e:	56                   	push   %esi
  80184f:	53                   	push   %ebx
  801850:	83 ec 1c             	sub    $0x1c,%esp
  801853:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801856:	56                   	push   %esi
  801857:	e8 d0 ef ff ff       	call   80082c <strlen>
  80185c:	83 c4 10             	add    $0x10,%esp
  80185f:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801864:	7f 72                	jg     8018d8 <open+0x8d>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801866:	83 ec 0c             	sub    $0xc,%esp
  801869:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80186c:	50                   	push   %eax
  80186d:	e8 ce f8 ff ff       	call   801140 <fd_alloc>
  801872:	89 c3                	mov    %eax,%ebx
  801874:	83 c4 10             	add    $0x10,%esp
  801877:	85 c0                	test   %eax,%eax
  801879:	78 62                	js     8018dd <open+0x92>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  80187b:	83 ec 08             	sub    $0x8,%esp
  80187e:	56                   	push   %esi
  80187f:	68 00 60 80 00       	push   $0x806000
  801884:	e8 f5 ef ff ff       	call   80087e <strcpy>
	fsipcbuf.open.req_omode = mode;
  801889:	8b 45 0c             	mov    0xc(%ebp),%eax
  80188c:	a3 00 64 80 00       	mov    %eax,0x806400



	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801891:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801894:	b8 01 00 00 00       	mov    $0x1,%eax
  801899:	e8 52 fe ff ff       	call   8016f0 <fsipc>
  80189e:	89 c3                	mov    %eax,%ebx
  8018a0:	83 c4 10             	add    $0x10,%esp
  8018a3:	85 c0                	test   %eax,%eax
  8018a5:	79 12                	jns    8018b9 <open+0x6e>
		fd_close(fd, 0);
  8018a7:	83 ec 08             	sub    $0x8,%esp
  8018aa:	6a 00                	push   $0x0
  8018ac:	ff 75 f4             	pushl  -0xc(%ebp)
  8018af:	e8 bb f9 ff ff       	call   80126f <fd_close>
		return r;
  8018b4:	83 c4 10             	add    $0x10,%esp
  8018b7:	eb 24                	jmp    8018dd <open+0x92>
	}


	cprintf("OPEN\n");
  8018b9:	83 ec 0c             	sub    $0xc,%esp
  8018bc:	68 f5 2e 80 00       	push   $0x802ef5
  8018c1:	e8 02 ea ff ff       	call   8002c8 <cprintf>

	return fd2num(fd);
  8018c6:	83 c4 04             	add    $0x4,%esp
  8018c9:	ff 75 f4             	pushl  -0xc(%ebp)
  8018cc:	e8 47 f8 ff ff       	call   801118 <fd2num>
  8018d1:	89 c3                	mov    %eax,%ebx
  8018d3:	83 c4 10             	add    $0x10,%esp
  8018d6:	eb 05                	jmp    8018dd <open+0x92>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8018d8:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx


	cprintf("OPEN\n");

	return fd2num(fd);
}
  8018dd:	89 d8                	mov    %ebx,%eax
  8018df:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018e2:	5b                   	pop    %ebx
  8018e3:	5e                   	pop    %esi
  8018e4:	c9                   	leave  
  8018e5:	c3                   	ret    
	...

008018e8 <spawn>:
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
{
  8018e8:	55                   	push   %ebp
  8018e9:	89 e5                	mov    %esp,%ebp
  8018eb:	57                   	push   %edi
  8018ec:	56                   	push   %esi
  8018ed:	53                   	push   %ebx
  8018ee:	81 ec 94 02 00 00    	sub    $0x294,%esp
	//   - Call sys_env_set_trapframe(child, &child_tf) to set up the
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
  8018f4:	6a 00                	push   $0x0
  8018f6:	ff 75 08             	pushl  0x8(%ebp)
  8018f9:	e8 4d ff ff ff       	call   80184b <open>
  8018fe:	89 85 88 fd ff ff    	mov    %eax,-0x278(%ebp)
  801904:	83 c4 10             	add    $0x10,%esp
  801907:	85 c0                	test   %eax,%eax
  801909:	0f 88 ce 04 00 00    	js     801ddd <spawn+0x4f5>
		return r;
	fd = r;

	// Read elf header
	elf = (struct Elf*) elf_buf;
	if (readn(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf)
  80190f:	83 ec 04             	sub    $0x4,%esp
  801912:	68 00 02 00 00       	push   $0x200
  801917:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  80191d:	50                   	push   %eax
  80191e:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  801924:	e8 92 fb ff ff       	call   8014bb <readn>
  801929:	83 c4 10             	add    $0x10,%esp
  80192c:	3d 00 02 00 00       	cmp    $0x200,%eax
  801931:	75 0c                	jne    80193f <spawn+0x57>
	    || elf->e_magic != ELF_MAGIC) {
  801933:	81 bd e8 fd ff ff 7f 	cmpl   $0x464c457f,-0x218(%ebp)
  80193a:	45 4c 46 
  80193d:	74 38                	je     801977 <spawn+0x8f>
		close(fd);
  80193f:	83 ec 0c             	sub    $0xc,%esp
  801942:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  801948:	e8 aa f9 ff ff       	call   8012f7 <close>
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
  80194d:	83 c4 0c             	add    $0xc,%esp
  801950:	68 7f 45 4c 46       	push   $0x464c457f
  801955:	ff b5 e8 fd ff ff    	pushl  -0x218(%ebp)
  80195b:	68 fb 2e 80 00       	push   $0x802efb
  801960:	e8 63 e9 ff ff       	call   8002c8 <cprintf>
		return -E_NOT_EXEC;
  801965:	83 c4 10             	add    $0x10,%esp
  801968:	c7 85 84 fd ff ff f2 	movl   $0xfffffff2,-0x27c(%ebp)
  80196f:	ff ff ff 
  801972:	e9 72 04 00 00       	jmp    801de9 <spawn+0x501>
  801977:	ba 07 00 00 00       	mov    $0x7,%edx
  80197c:	89 d0                	mov    %edx,%eax
  80197e:	cd 30                	int    $0x30
  801980:	89 85 74 fd ff ff    	mov    %eax,-0x28c(%ebp)
  801986:	89 85 84 fd ff ff    	mov    %eax,-0x27c(%ebp)
	}


	// Create new child environment
	if ((r = sys_exofork()) < 0)
  80198c:	85 c0                	test   %eax,%eax
  80198e:	0f 88 55 04 00 00    	js     801de9 <spawn+0x501>
	child = r;



	// Set up trap frame, including initial stack.
	child_tf = envs[ENVX(child)].env_tf;
  801994:	25 ff 03 00 00       	and    $0x3ff,%eax
  801999:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  8019a0:	89 c6                	mov    %eax,%esi
  8019a2:	c1 e6 07             	shl    $0x7,%esi
  8019a5:	29 d6                	sub    %edx,%esi
  8019a7:	81 c6 00 00 c0 ee    	add    $0xeec00000,%esi
  8019ad:	8d bd a4 fd ff ff    	lea    -0x25c(%ebp),%edi
  8019b3:	b9 11 00 00 00       	mov    $0x11,%ecx
  8019b8:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	child_tf.tf_eip = elf->e_entry;
  8019ba:	8b 85 00 fe ff ff    	mov    -0x200(%ebp),%eax
  8019c0:	89 85 d4 fd ff ff    	mov    %eax,-0x22c(%ebp)
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  8019c6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8019c9:	8b 02                	mov    (%edx),%eax
  8019cb:	85 c0                	test   %eax,%eax
  8019cd:	74 39                	je     801a08 <spawn+0x120>
	char *string_store;
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
  8019cf:	be 00 00 00 00       	mov    $0x0,%esi
	for (argc = 0; argv[argc] != 0; argc++)
  8019d4:	bb 00 00 00 00       	mov    $0x0,%ebx
  8019d9:	89 d7                	mov    %edx,%edi
		string_size += strlen(argv[argc]) + 1;
  8019db:	83 ec 0c             	sub    $0xc,%esp
  8019de:	50                   	push   %eax
  8019df:	e8 48 ee ff ff       	call   80082c <strlen>
  8019e4:	8d 74 30 01          	lea    0x1(%eax,%esi,1),%esi
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  8019e8:	43                   	inc    %ebx
  8019e9:	8d 0c 9d 00 00 00 00 	lea    0x0(,%ebx,4),%ecx
  8019f0:	8b 04 9f             	mov    (%edi,%ebx,4),%eax
  8019f3:	83 c4 10             	add    $0x10,%esp
  8019f6:	85 c0                	test   %eax,%eax
  8019f8:	75 e1                	jne    8019db <spawn+0xf3>
  8019fa:	89 9d 80 fd ff ff    	mov    %ebx,-0x280(%ebp)
  801a00:	89 8d 7c fd ff ff    	mov    %ecx,-0x284(%ebp)
  801a06:	eb 1e                	jmp    801a26 <spawn+0x13e>
  801a08:	c7 85 7c fd ff ff 00 	movl   $0x0,-0x284(%ebp)
  801a0f:	00 00 00 
  801a12:	c7 85 80 fd ff ff 00 	movl   $0x0,-0x280(%ebp)
  801a19:	00 00 00 
	char *string_store;
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
  801a1c:	be 00 00 00 00       	mov    $0x0,%esi
	for (argc = 0; argv[argc] != 0; argc++)
  801a21:	bb 00 00 00 00       	mov    $0x0,%ebx
	// Determine where to place the strings and the argv array.
	// Set up pointers into the temporary page 'UTEMP'; we'll map a page
	// there later, then remap that page into the child environment
	// at (USTACKTOP - PGSIZE).
	// strings is the topmost thing on the stack.
	string_store = (char*) UTEMP + PGSIZE - string_size;
  801a26:	f7 de                	neg    %esi
  801a28:	8d be 00 10 40 00    	lea    0x401000(%esi),%edi
	// argv is below that.  There's one argument pointer per argument, plus
	// a null pointer.
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));
  801a2e:	89 fa                	mov    %edi,%edx
  801a30:	83 e2 fc             	and    $0xfffffffc,%edx
  801a33:	89 d8                	mov    %ebx,%eax
  801a35:	f7 d0                	not    %eax
  801a37:	8d 04 82             	lea    (%edx,%eax,4),%eax
  801a3a:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
  801a40:	83 e8 08             	sub    $0x8,%eax
  801a43:	3d ff ff 3f 00       	cmp    $0x3fffff,%eax
  801a48:	0f 86 a9 03 00 00    	jbe    801df7 <spawn+0x50f>
		return -E_NO_MEM;

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801a4e:	83 ec 04             	sub    $0x4,%esp
  801a51:	6a 07                	push   $0x7
  801a53:	68 00 00 40 00       	push   $0x400000
  801a58:	6a 00                	push   $0x0
  801a5a:	e8 a1 f2 ff ff       	call   800d00 <sys_page_alloc>
  801a5f:	83 c4 10             	add    $0x10,%esp
  801a62:	85 c0                	test   %eax,%eax
  801a64:	0f 88 99 03 00 00    	js     801e03 <spawn+0x51b>
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  801a6a:	85 db                	test   %ebx,%ebx
  801a6c:	7e 44                	jle    801ab2 <spawn+0x1ca>
  801a6e:	be 00 00 00 00       	mov    $0x0,%esi
  801a73:	89 9d 8c fd ff ff    	mov    %ebx,-0x274(%ebp)
  801a79:	8b 5d 0c             	mov    0xc(%ebp),%ebx
		argv_store[i] = UTEMP2USTACK(string_store);
  801a7c:	8d 87 00 d0 7f ee    	lea    -0x11803000(%edi),%eax
  801a82:	8b 95 94 fd ff ff    	mov    -0x26c(%ebp),%edx
  801a88:	89 04 b2             	mov    %eax,(%edx,%esi,4)
		strcpy(string_store, argv[i]);
  801a8b:	83 ec 08             	sub    $0x8,%esp
  801a8e:	ff 34 b3             	pushl  (%ebx,%esi,4)
  801a91:	57                   	push   %edi
  801a92:	e8 e7 ed ff ff       	call   80087e <strcpy>
		string_store += strlen(argv[i]) + 1;
  801a97:	83 c4 04             	add    $0x4,%esp
  801a9a:	ff 34 b3             	pushl  (%ebx,%esi,4)
  801a9d:	e8 8a ed ff ff       	call   80082c <strlen>
  801aa2:	8d 7c 07 01          	lea    0x1(%edi,%eax,1),%edi
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  801aa6:	46                   	inc    %esi
  801aa7:	83 c4 10             	add    $0x10,%esp
  801aaa:	3b b5 8c fd ff ff    	cmp    -0x274(%ebp),%esi
  801ab0:	7c ca                	jl     801a7c <spawn+0x194>
		argv_store[i] = UTEMP2USTACK(string_store);
		strcpy(string_store, argv[i]);
		string_store += strlen(argv[i]) + 1;
	}
	argv_store[argc] = 0;
  801ab2:	8b 95 94 fd ff ff    	mov    -0x26c(%ebp),%edx
  801ab8:	8b 85 7c fd ff ff    	mov    -0x284(%ebp),%eax
  801abe:	c7 04 02 00 00 00 00 	movl   $0x0,(%edx,%eax,1)
	assert(string_store == (char*)UTEMP + PGSIZE);
  801ac5:	81 ff 00 10 40 00    	cmp    $0x401000,%edi
  801acb:	74 19                	je     801ae6 <spawn+0x1fe>
  801acd:	68 70 2f 80 00       	push   $0x802f70
  801ad2:	68 c9 2e 80 00       	push   $0x802ec9
  801ad7:	68 f5 00 00 00       	push   $0xf5
  801adc:	68 15 2f 80 00       	push   $0x802f15
  801ae1:	e8 0a e7 ff ff       	call   8001f0 <_panic>

	argv_store[-1] = UTEMP2USTACK(argv_store);
  801ae6:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  801aec:	2d 00 30 80 11       	sub    $0x11803000,%eax
  801af1:	8b 95 94 fd ff ff    	mov    -0x26c(%ebp),%edx
  801af7:	89 42 fc             	mov    %eax,-0x4(%edx)
	argv_store[-2] = argc;
  801afa:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  801b00:	89 42 f8             	mov    %eax,-0x8(%edx)

	*init_esp = UTEMP2USTACK(&argv_store[-2]);
  801b03:	89 d0                	mov    %edx,%eax
  801b05:	2d 08 30 80 11       	sub    $0x11803008,%eax
  801b0a:	89 85 e0 fd ff ff    	mov    %eax,-0x220(%ebp)

	// After completing the stack, map it into the child's address space
	// and unmap it from ours!
	if ((r = sys_page_map(0, UTEMP, child, (void*) (USTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W)) < 0)
  801b10:	83 ec 0c             	sub    $0xc,%esp
  801b13:	6a 07                	push   $0x7
  801b15:	68 00 d0 bf ee       	push   $0xeebfd000
  801b1a:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801b20:	68 00 00 40 00       	push   $0x400000
  801b25:	6a 00                	push   $0x0
  801b27:	e8 f8 f1 ff ff       	call   800d24 <sys_page_map>
  801b2c:	89 c3                	mov    %eax,%ebx
  801b2e:	83 c4 20             	add    $0x20,%esp
  801b31:	85 c0                	test   %eax,%eax
  801b33:	78 18                	js     801b4d <spawn+0x265>
		goto error;
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  801b35:	83 ec 08             	sub    $0x8,%esp
  801b38:	68 00 00 40 00       	push   $0x400000
  801b3d:	6a 00                	push   $0x0
  801b3f:	e8 06 f2 ff ff       	call   800d4a <sys_page_unmap>
  801b44:	89 c3                	mov    %eax,%ebx
  801b46:	83 c4 10             	add    $0x10,%esp
  801b49:	85 c0                	test   %eax,%eax
  801b4b:	79 1d                	jns    801b6a <spawn+0x282>
		goto error;

	return 0;

error:
	sys_page_unmap(0, UTEMP);
  801b4d:	83 ec 08             	sub    $0x8,%esp
  801b50:	68 00 00 40 00       	push   $0x400000
  801b55:	6a 00                	push   $0x0
  801b57:	e8 ee f1 ff ff       	call   800d4a <sys_page_unmap>
  801b5c:	83 c4 10             	add    $0x10,%esp
	return r;
  801b5f:	89 9d 84 fd ff ff    	mov    %ebx,-0x27c(%ebp)
  801b65:	e9 7f 02 00 00       	jmp    801de9 <spawn+0x501>
	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;


	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  801b6a:	8b 85 04 fe ff ff    	mov    -0x1fc(%ebp),%eax
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801b70:	66 83 bd 14 fe ff ff 	cmpw   $0x0,-0x1ec(%ebp)
  801b77:	00 
  801b78:	0f 84 c3 01 00 00    	je     801d41 <spawn+0x459>
	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;


	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  801b7e:	8d 84 05 e8 fd ff ff 	lea    -0x218(%ebp,%eax,1),%eax
  801b85:	89 85 80 fd ff ff    	mov    %eax,-0x280(%ebp)
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801b8b:	c7 85 7c fd ff ff 00 	movl   $0x0,-0x284(%ebp)
  801b92:	00 00 00 
		if (ph->p_type != ELF_PROG_LOAD)
  801b95:	8b 95 80 fd ff ff    	mov    -0x280(%ebp),%edx
  801b9b:	83 3a 01             	cmpl   $0x1,(%edx)
  801b9e:	0f 85 7c 01 00 00    	jne    801d20 <spawn+0x438>
			continue;
		perm = PTE_P | PTE_U;
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
  801ba4:	8b 42 18             	mov    0x18(%edx),%eax
  801ba7:	83 e0 02             	and    $0x2,%eax
	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
		if (ph->p_type != ELF_PROG_LOAD)
			continue;
		perm = PTE_P | PTE_U;
  801baa:	83 f8 01             	cmp    $0x1,%eax
  801bad:	19 db                	sbb    %ebx,%ebx
  801baf:	83 e3 fe             	and    $0xfffffffe,%ebx
  801bb2:	83 c3 07             	add    $0x7,%ebx
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
  801bb5:	8b 42 04             	mov    0x4(%edx),%eax
  801bb8:	89 85 78 fd ff ff    	mov    %eax,-0x288(%ebp)
  801bbe:	8b 52 10             	mov    0x10(%edx),%edx
  801bc1:	89 95 94 fd ff ff    	mov    %edx,-0x26c(%ebp)
  801bc7:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  801bcd:	8b 40 14             	mov    0x14(%eax),%eax
  801bd0:	89 85 8c fd ff ff    	mov    %eax,-0x274(%ebp)
  801bd6:	8b 95 80 fd ff ff    	mov    -0x280(%ebp),%edx
  801bdc:	8b 52 08             	mov    0x8(%edx),%edx
  801bdf:	89 95 90 fd ff ff    	mov    %edx,-0x270(%ebp)
	int i, r;
	void *blk;

	//cprintf("map_segment %x+%x\n", va, memsz);

	if ((i = PGOFF(va))) {
  801be5:	89 d0                	mov    %edx,%eax
  801be7:	25 ff 0f 00 00       	and    $0xfff,%eax
  801bec:	74 1a                	je     801c08 <spawn+0x320>
		va -= i;
  801bee:	29 c2                	sub    %eax,%edx
  801bf0:	89 95 90 fd ff ff    	mov    %edx,-0x270(%ebp)
		memsz += i;
  801bf6:	01 85 8c fd ff ff    	add    %eax,-0x274(%ebp)
		filesz += i;
  801bfc:	01 85 94 fd ff ff    	add    %eax,-0x26c(%ebp)
		fileoffset -= i;
  801c02:	29 85 78 fd ff ff    	sub    %eax,-0x288(%ebp)
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  801c08:	83 bd 8c fd ff ff 00 	cmpl   $0x0,-0x274(%ebp)
  801c0f:	0f 84 0b 01 00 00    	je     801d20 <spawn+0x438>
  801c15:	bf 00 00 00 00       	mov    $0x0,%edi
  801c1a:	be 00 00 00 00       	mov    $0x0,%esi
		if (i >= filesz) {
  801c1f:	3b bd 94 fd ff ff    	cmp    -0x26c(%ebp),%edi
  801c25:	72 28                	jb     801c4f <spawn+0x367>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
  801c27:	83 ec 04             	sub    $0x4,%esp
  801c2a:	53                   	push   %ebx
  801c2b:	03 bd 90 fd ff ff    	add    -0x270(%ebp),%edi
  801c31:	57                   	push   %edi
  801c32:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  801c38:	e8 c3 f0 ff ff       	call   800d00 <sys_page_alloc>
  801c3d:	83 c4 10             	add    $0x10,%esp
  801c40:	85 c0                	test   %eax,%eax
  801c42:	0f 89 c4 00 00 00    	jns    801d0c <spawn+0x424>
  801c48:	89 c3                	mov    %eax,%ebx
  801c4a:	e9 67 01 00 00       	jmp    801db6 <spawn+0x4ce>
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801c4f:	83 ec 04             	sub    $0x4,%esp
  801c52:	6a 07                	push   $0x7
  801c54:	68 00 00 40 00       	push   $0x400000
  801c59:	6a 00                	push   $0x0
  801c5b:	e8 a0 f0 ff ff       	call   800d00 <sys_page_alloc>
  801c60:	83 c4 10             	add    $0x10,%esp
  801c63:	85 c0                	test   %eax,%eax
  801c65:	0f 88 41 01 00 00    	js     801dac <spawn+0x4c4>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  801c6b:	83 ec 08             	sub    $0x8,%esp
// prog: the pathname of the program to run.
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
  801c6e:	8b 85 78 fd ff ff    	mov    -0x288(%ebp),%eax
  801c74:	8d 04 06             	lea    (%esi,%eax,1),%eax
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  801c77:	50                   	push   %eax
  801c78:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  801c7e:	e8 0f f9 ff ff       	call   801592 <seek>
  801c83:	83 c4 10             	add    $0x10,%esp
  801c86:	85 c0                	test   %eax,%eax
  801c88:	0f 88 22 01 00 00    	js     801db0 <spawn+0x4c8>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  801c8e:	83 ec 04             	sub    $0x4,%esp
  801c91:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  801c97:	29 f8                	sub    %edi,%eax
  801c99:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801c9e:	76 05                	jbe    801ca5 <spawn+0x3bd>
  801ca0:	b8 00 10 00 00       	mov    $0x1000,%eax
  801ca5:	50                   	push   %eax
  801ca6:	68 00 00 40 00       	push   $0x400000
  801cab:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  801cb1:	e8 05 f8 ff ff       	call   8014bb <readn>
  801cb6:	83 c4 10             	add    $0x10,%esp
  801cb9:	85 c0                	test   %eax,%eax
  801cbb:	0f 88 f3 00 00 00    	js     801db4 <spawn+0x4cc>
				return r;
			if ((r = sys_page_map(0, UTEMP, child, (void*) (va + i), perm)) < 0)
  801cc1:	83 ec 0c             	sub    $0xc,%esp
  801cc4:	53                   	push   %ebx
  801cc5:	03 bd 90 fd ff ff    	add    -0x270(%ebp),%edi
  801ccb:	57                   	push   %edi
  801ccc:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  801cd2:	68 00 00 40 00       	push   $0x400000
  801cd7:	6a 00                	push   $0x0
  801cd9:	e8 46 f0 ff ff       	call   800d24 <sys_page_map>
  801cde:	83 c4 20             	add    $0x20,%esp
  801ce1:	85 c0                	test   %eax,%eax
  801ce3:	79 15                	jns    801cfa <spawn+0x412>
				panic("spawn: sys_page_map data: %e", r);
  801ce5:	50                   	push   %eax
  801ce6:	68 21 2f 80 00       	push   $0x802f21
  801ceb:	68 28 01 00 00       	push   $0x128
  801cf0:	68 15 2f 80 00       	push   $0x802f15
  801cf5:	e8 f6 e4 ff ff       	call   8001f0 <_panic>
			sys_page_unmap(0, UTEMP);
  801cfa:	83 ec 08             	sub    $0x8,%esp
  801cfd:	68 00 00 40 00       	push   $0x400000
  801d02:	6a 00                	push   $0x0
  801d04:	e8 41 f0 ff ff       	call   800d4a <sys_page_unmap>
  801d09:	83 c4 10             	add    $0x10,%esp
		memsz += i;
		filesz += i;
		fileoffset -= i;
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  801d0c:	81 c6 00 10 00 00    	add    $0x1000,%esi
  801d12:	89 f7                	mov    %esi,%edi
  801d14:	3b b5 8c fd ff ff    	cmp    -0x274(%ebp),%esi
  801d1a:	0f 82 ff fe ff ff    	jb     801c1f <spawn+0x337>
		return r;


	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801d20:	ff 85 7c fd ff ff    	incl   -0x284(%ebp)
  801d26:	0f b7 85 14 fe ff ff 	movzwl -0x1ec(%ebp),%eax
  801d2d:	3b 85 7c fd ff ff    	cmp    -0x284(%ebp),%eax
  801d33:	7e 0c                	jle    801d41 <spawn+0x459>
  801d35:	83 85 80 fd ff ff 20 	addl   $0x20,-0x280(%ebp)
  801d3c:	e9 54 fe ff ff       	jmp    801b95 <spawn+0x2ad>
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
				     fd, ph->p_filesz, ph->p_offset, perm)) < 0)
			goto error;
	}
	close(fd);
  801d41:	83 ec 0c             	sub    $0xc,%esp
  801d44:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  801d4a:	e8 a8 f5 ff ff       	call   8012f7 <close>

	// Copy shared library state.
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);

	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
  801d4f:	83 c4 08             	add    $0x8,%esp
  801d52:	8d 85 a4 fd ff ff    	lea    -0x25c(%ebp),%eax
  801d58:	50                   	push   %eax
  801d59:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801d5f:	e8 2c f0 ff ff       	call   800d90 <sys_env_set_trapframe>
  801d64:	83 c4 10             	add    $0x10,%esp
  801d67:	85 c0                	test   %eax,%eax
  801d69:	79 15                	jns    801d80 <spawn+0x498>
		panic("sys_env_set_trapframe: %e", r);
  801d6b:	50                   	push   %eax
  801d6c:	68 3e 2f 80 00       	push   $0x802f3e
  801d71:	68 89 00 00 00       	push   $0x89
  801d76:	68 15 2f 80 00       	push   $0x802f15
  801d7b:	e8 70 e4 ff ff       	call   8001f0 <_panic>

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
  801d80:	83 ec 08             	sub    $0x8,%esp
  801d83:	6a 02                	push   $0x2
  801d85:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801d8b:	e8 dd ef ff ff       	call   800d6d <sys_env_set_status>
  801d90:	83 c4 10             	add    $0x10,%esp
  801d93:	85 c0                	test   %eax,%eax
  801d95:	79 52                	jns    801de9 <spawn+0x501>
		panic("sys_env_set_status: %e", r);
  801d97:	50                   	push   %eax
  801d98:	68 58 2f 80 00       	push   $0x802f58
  801d9d:	68 8c 00 00 00       	push   $0x8c
  801da2:	68 15 2f 80 00       	push   $0x802f15
  801da7:	e8 44 e4 ff ff       	call   8001f0 <_panic>
  801dac:	89 c3                	mov    %eax,%ebx
  801dae:	eb 06                	jmp    801db6 <spawn+0x4ce>
  801db0:	89 c3                	mov    %eax,%ebx
  801db2:	eb 02                	jmp    801db6 <spawn+0x4ce>
  801db4:	89 c3                	mov    %eax,%ebx

	return child;

error:
	sys_env_destroy(child);
  801db6:	83 ec 0c             	sub    $0xc,%esp
  801db9:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801dbf:	e8 cf ee ff ff       	call   800c93 <sys_env_destroy>
	close(fd);
  801dc4:	83 c4 04             	add    $0x4,%esp
  801dc7:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  801dcd:	e8 25 f5 ff ff       	call   8012f7 <close>
	return r;
  801dd2:	83 c4 10             	add    $0x10,%esp
  801dd5:	89 9d 84 fd ff ff    	mov    %ebx,-0x27c(%ebp)
  801ddb:	eb 0c                	jmp    801de9 <spawn+0x501>
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
		return r;
  801ddd:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  801de3:	89 85 84 fd ff ff    	mov    %eax,-0x27c(%ebp)

error:
	sys_env_destroy(child);
	close(fd);
	return r;
}
  801de9:	8b 85 84 fd ff ff    	mov    -0x27c(%ebp),%eax
  801def:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801df2:	5b                   	pop    %ebx
  801df3:	5e                   	pop    %esi
  801df4:	5f                   	pop    %edi
  801df5:	c9                   	leave  
  801df6:	c3                   	ret    
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
		return -E_NO_MEM;
  801df7:	c7 85 84 fd ff ff fc 	movl   $0xfffffffc,-0x27c(%ebp)
  801dfe:	ff ff ff 
  801e01:	eb e6                	jmp    801de9 <spawn+0x501>

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
		return r;
  801e03:	89 85 84 fd ff ff    	mov    %eax,-0x27c(%ebp)
  801e09:	eb de                	jmp    801de9 <spawn+0x501>

00801e0b <spawnl>:
// Spawn, taking command-line arguments array directly on the stack.
// NOTE: Must have a sentinal of NULL at the end of the args
// (none of the args may be NULL).
int
spawnl(const char *prog, const char *arg0, ...)
{
  801e0b:	55                   	push   %ebp
  801e0c:	89 e5                	mov    %esp,%ebp
  801e0e:	56                   	push   %esi
  801e0f:	53                   	push   %ebx
  801e10:	8b 75 0c             	mov    0xc(%ebp),%esi
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801e13:	8d 45 14             	lea    0x14(%ebp),%eax
  801e16:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801e1a:	74 5f                	je     801e7b <spawnl+0x70>
{
	// We calculate argc by advancing the args until we hit NULL.
	// The contract of the function guarantees that the last
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
  801e1c:	b9 00 00 00 00       	mov    $0x0,%ecx
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
		argc++;
  801e21:	41                   	inc    %ecx
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801e22:	89 c2                	mov    %eax,%edx
  801e24:	83 c0 04             	add    $0x4,%eax
  801e27:	83 3a 00             	cmpl   $0x0,(%edx)
  801e2a:	75 f5                	jne    801e21 <spawnl+0x16>
		argc++;
	va_end(vl);

	// Now that we have the size of the args, do a second pass
	// and store the values in a VLA, which has the format of argv
	const char *argv[argc+2];
  801e2c:	8d 04 8d 26 00 00 00 	lea    0x26(,%ecx,4),%eax
  801e33:	83 e0 f0             	and    $0xfffffff0,%eax
  801e36:	29 c4                	sub    %eax,%esp
  801e38:	8d 44 24 0f          	lea    0xf(%esp),%eax
  801e3c:	83 e0 f0             	and    $0xfffffff0,%eax
  801e3f:	89 c3                	mov    %eax,%ebx
	argv[0] = arg0;
  801e41:	89 30                	mov    %esi,(%eax)
	argv[argc+1] = NULL;
  801e43:	c7 44 88 04 00 00 00 	movl   $0x0,0x4(%eax,%ecx,4)
  801e4a:	00 

	va_start(vl, arg0);
  801e4b:	8d 55 10             	lea    0x10(%ebp),%edx
	unsigned i;
	for(i=0;i<argc;i++)
  801e4e:	89 ce                	mov    %ecx,%esi
  801e50:	85 c9                	test   %ecx,%ecx
  801e52:	74 14                	je     801e68 <spawnl+0x5d>
  801e54:	b8 00 00 00 00       	mov    $0x0,%eax
		argv[i+1] = va_arg(vl, const char *);
  801e59:	40                   	inc    %eax
  801e5a:	89 d1                	mov    %edx,%ecx
  801e5c:	83 c2 04             	add    $0x4,%edx
  801e5f:	8b 09                	mov    (%ecx),%ecx
  801e61:	89 0c 83             	mov    %ecx,(%ebx,%eax,4)
	argv[0] = arg0;
	argv[argc+1] = NULL;

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  801e64:	39 f0                	cmp    %esi,%eax
  801e66:	72 f1                	jb     801e59 <spawnl+0x4e>
		argv[i+1] = va_arg(vl, const char *);
	va_end(vl);
	return spawn(prog, argv);
  801e68:	83 ec 08             	sub    $0x8,%esp
  801e6b:	53                   	push   %ebx
  801e6c:	ff 75 08             	pushl  0x8(%ebp)
  801e6f:	e8 74 fa ff ff       	call   8018e8 <spawn>
}
  801e74:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e77:	5b                   	pop    %ebx
  801e78:	5e                   	pop    %esi
  801e79:	c9                   	leave  
  801e7a:	c3                   	ret    
		argc++;
	va_end(vl);

	// Now that we have the size of the args, do a second pass
	// and store the values in a VLA, which has the format of argv
	const char *argv[argc+2];
  801e7b:	83 ec 20             	sub    $0x20,%esp
  801e7e:	8d 44 24 0f          	lea    0xf(%esp),%eax
  801e82:	83 e0 f0             	and    $0xfffffff0,%eax
  801e85:	89 c3                	mov    %eax,%ebx
	argv[0] = arg0;
  801e87:	89 30                	mov    %esi,(%eax)
	argv[argc+1] = NULL;
  801e89:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
  801e90:	eb d6                	jmp    801e68 <spawnl+0x5d>
	...

00801e94 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801e94:	55                   	push   %ebp
  801e95:	89 e5                	mov    %esp,%ebp
  801e97:	56                   	push   %esi
  801e98:	53                   	push   %ebx
  801e99:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801e9c:	83 ec 0c             	sub    $0xc,%esp
  801e9f:	ff 75 08             	pushl  0x8(%ebp)
  801ea2:	e8 81 f2 ff ff       	call   801128 <fd2data>
  801ea7:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  801ea9:	83 c4 08             	add    $0x8,%esp
  801eac:	68 96 2f 80 00       	push   $0x802f96
  801eb1:	56                   	push   %esi
  801eb2:	e8 c7 e9 ff ff       	call   80087e <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801eb7:	8b 43 04             	mov    0x4(%ebx),%eax
  801eba:	2b 03                	sub    (%ebx),%eax
  801ebc:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  801ec2:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  801ec9:	00 00 00 
	stat->st_dev = &devpipe;
  801ecc:	c7 86 88 00 00 00 28 	movl   $0x804028,0x88(%esi)
  801ed3:	40 80 00 
	return 0;
}
  801ed6:	b8 00 00 00 00       	mov    $0x0,%eax
  801edb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ede:	5b                   	pop    %ebx
  801edf:	5e                   	pop    %esi
  801ee0:	c9                   	leave  
  801ee1:	c3                   	ret    

00801ee2 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801ee2:	55                   	push   %ebp
  801ee3:	89 e5                	mov    %esp,%ebp
  801ee5:	53                   	push   %ebx
  801ee6:	83 ec 0c             	sub    $0xc,%esp
  801ee9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801eec:	53                   	push   %ebx
  801eed:	6a 00                	push   $0x0
  801eef:	e8 56 ee ff ff       	call   800d4a <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801ef4:	89 1c 24             	mov    %ebx,(%esp)
  801ef7:	e8 2c f2 ff ff       	call   801128 <fd2data>
  801efc:	83 c4 08             	add    $0x8,%esp
  801eff:	50                   	push   %eax
  801f00:	6a 00                	push   $0x0
  801f02:	e8 43 ee ff ff       	call   800d4a <sys_page_unmap>
}
  801f07:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801f0a:	c9                   	leave  
  801f0b:	c3                   	ret    

00801f0c <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801f0c:	55                   	push   %ebp
  801f0d:	89 e5                	mov    %esp,%ebp
  801f0f:	57                   	push   %edi
  801f10:	56                   	push   %esi
  801f11:	53                   	push   %ebx
  801f12:	83 ec 1c             	sub    $0x1c,%esp
  801f15:	89 c7                	mov    %eax,%edi
  801f17:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801f1a:	a1 04 50 80 00       	mov    0x805004,%eax
  801f1f:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801f22:	83 ec 0c             	sub    $0xc,%esp
  801f25:	57                   	push   %edi
  801f26:	e8 e1 06 00 00       	call   80260c <pageref>
  801f2b:	89 c6                	mov    %eax,%esi
  801f2d:	83 c4 04             	add    $0x4,%esp
  801f30:	ff 75 e4             	pushl  -0x1c(%ebp)
  801f33:	e8 d4 06 00 00       	call   80260c <pageref>
  801f38:	83 c4 10             	add    $0x10,%esp
  801f3b:	39 c6                	cmp    %eax,%esi
  801f3d:	0f 94 c0             	sete   %al
  801f40:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  801f43:	8b 15 04 50 80 00    	mov    0x805004,%edx
  801f49:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801f4c:	39 cb                	cmp    %ecx,%ebx
  801f4e:	75 08                	jne    801f58 <_pipeisclosed+0x4c>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  801f50:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f53:	5b                   	pop    %ebx
  801f54:	5e                   	pop    %esi
  801f55:	5f                   	pop    %edi
  801f56:	c9                   	leave  
  801f57:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  801f58:	83 f8 01             	cmp    $0x1,%eax
  801f5b:	75 bd                	jne    801f1a <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801f5d:	8b 42 58             	mov    0x58(%edx),%eax
  801f60:	6a 01                	push   $0x1
  801f62:	50                   	push   %eax
  801f63:	53                   	push   %ebx
  801f64:	68 9d 2f 80 00       	push   $0x802f9d
  801f69:	e8 5a e3 ff ff       	call   8002c8 <cprintf>
  801f6e:	83 c4 10             	add    $0x10,%esp
  801f71:	eb a7                	jmp    801f1a <_pipeisclosed+0xe>

00801f73 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801f73:	55                   	push   %ebp
  801f74:	89 e5                	mov    %esp,%ebp
  801f76:	57                   	push   %edi
  801f77:	56                   	push   %esi
  801f78:	53                   	push   %ebx
  801f79:	83 ec 28             	sub    $0x28,%esp
  801f7c:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801f7f:	56                   	push   %esi
  801f80:	e8 a3 f1 ff ff       	call   801128 <fd2data>
  801f85:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801f87:	83 c4 10             	add    $0x10,%esp
  801f8a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801f8e:	75 4a                	jne    801fda <devpipe_write+0x67>
  801f90:	bf 00 00 00 00       	mov    $0x0,%edi
  801f95:	eb 56                	jmp    801fed <devpipe_write+0x7a>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801f97:	89 da                	mov    %ebx,%edx
  801f99:	89 f0                	mov    %esi,%eax
  801f9b:	e8 6c ff ff ff       	call   801f0c <_pipeisclosed>
  801fa0:	85 c0                	test   %eax,%eax
  801fa2:	75 4d                	jne    801ff1 <devpipe_write+0x7e>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801fa4:	e8 30 ed ff ff       	call   800cd9 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801fa9:	8b 43 04             	mov    0x4(%ebx),%eax
  801fac:	8b 13                	mov    (%ebx),%edx
  801fae:	83 c2 20             	add    $0x20,%edx
  801fb1:	39 d0                	cmp    %edx,%eax
  801fb3:	73 e2                	jae    801f97 <devpipe_write+0x24>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801fb5:	89 c2                	mov    %eax,%edx
  801fb7:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  801fbd:	79 05                	jns    801fc4 <devpipe_write+0x51>
  801fbf:	4a                   	dec    %edx
  801fc0:	83 ca e0             	or     $0xffffffe0,%edx
  801fc3:	42                   	inc    %edx
  801fc4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801fc7:	8a 0c 39             	mov    (%ecx,%edi,1),%cl
  801fca:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801fce:	40                   	inc    %eax
  801fcf:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801fd2:	47                   	inc    %edi
  801fd3:	39 7d 10             	cmp    %edi,0x10(%ebp)
  801fd6:	77 07                	ja     801fdf <devpipe_write+0x6c>
  801fd8:	eb 13                	jmp    801fed <devpipe_write+0x7a>
  801fda:	bf 00 00 00 00       	mov    $0x0,%edi
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801fdf:	8b 43 04             	mov    0x4(%ebx),%eax
  801fe2:	8b 13                	mov    (%ebx),%edx
  801fe4:	83 c2 20             	add    $0x20,%edx
  801fe7:	39 d0                	cmp    %edx,%eax
  801fe9:	73 ac                	jae    801f97 <devpipe_write+0x24>
  801feb:	eb c8                	jmp    801fb5 <devpipe_write+0x42>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801fed:	89 f8                	mov    %edi,%eax
  801fef:	eb 05                	jmp    801ff6 <devpipe_write+0x83>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801ff1:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801ff6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ff9:	5b                   	pop    %ebx
  801ffa:	5e                   	pop    %esi
  801ffb:	5f                   	pop    %edi
  801ffc:	c9                   	leave  
  801ffd:	c3                   	ret    

00801ffe <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801ffe:	55                   	push   %ebp
  801fff:	89 e5                	mov    %esp,%ebp
  802001:	57                   	push   %edi
  802002:	56                   	push   %esi
  802003:	53                   	push   %ebx
  802004:	83 ec 18             	sub    $0x18,%esp
  802007:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  80200a:	57                   	push   %edi
  80200b:	e8 18 f1 ff ff       	call   801128 <fd2data>
  802010:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802012:	83 c4 10             	add    $0x10,%esp
  802015:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  802019:	75 44                	jne    80205f <devpipe_read+0x61>
  80201b:	be 00 00 00 00       	mov    $0x0,%esi
  802020:	eb 4f                	jmp    802071 <devpipe_read+0x73>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
				return i;
  802022:	89 f0                	mov    %esi,%eax
  802024:	eb 54                	jmp    80207a <devpipe_read+0x7c>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  802026:	89 da                	mov    %ebx,%edx
  802028:	89 f8                	mov    %edi,%eax
  80202a:	e8 dd fe ff ff       	call   801f0c <_pipeisclosed>
  80202f:	85 c0                	test   %eax,%eax
  802031:	75 42                	jne    802075 <devpipe_read+0x77>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  802033:	e8 a1 ec ff ff       	call   800cd9 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  802038:	8b 03                	mov    (%ebx),%eax
  80203a:	3b 43 04             	cmp    0x4(%ebx),%eax
  80203d:	74 e7                	je     802026 <devpipe_read+0x28>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  80203f:	25 1f 00 00 80       	and    $0x8000001f,%eax
  802044:	79 05                	jns    80204b <devpipe_read+0x4d>
  802046:	48                   	dec    %eax
  802047:	83 c8 e0             	or     $0xffffffe0,%eax
  80204a:	40                   	inc    %eax
  80204b:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  80204f:	8b 55 0c             	mov    0xc(%ebp),%edx
  802052:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  802055:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802057:	46                   	inc    %esi
  802058:	39 75 10             	cmp    %esi,0x10(%ebp)
  80205b:	77 07                	ja     802064 <devpipe_read+0x66>
  80205d:	eb 12                	jmp    802071 <devpipe_read+0x73>
  80205f:	be 00 00 00 00       	mov    $0x0,%esi
		while (p->p_rpos == p->p_wpos) {
  802064:	8b 03                	mov    (%ebx),%eax
  802066:	3b 43 04             	cmp    0x4(%ebx),%eax
  802069:	75 d4                	jne    80203f <devpipe_read+0x41>
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  80206b:	85 f6                	test   %esi,%esi
  80206d:	75 b3                	jne    802022 <devpipe_read+0x24>
  80206f:	eb b5                	jmp    802026 <devpipe_read+0x28>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  802071:	89 f0                	mov    %esi,%eax
  802073:	eb 05                	jmp    80207a <devpipe_read+0x7c>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802075:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  80207a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80207d:	5b                   	pop    %ebx
  80207e:	5e                   	pop    %esi
  80207f:	5f                   	pop    %edi
  802080:	c9                   	leave  
  802081:	c3                   	ret    

00802082 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  802082:	55                   	push   %ebp
  802083:	89 e5                	mov    %esp,%ebp
  802085:	57                   	push   %edi
  802086:	56                   	push   %esi
  802087:	53                   	push   %ebx
  802088:	83 ec 28             	sub    $0x28,%esp
  80208b:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  80208e:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  802091:	50                   	push   %eax
  802092:	e8 a9 f0 ff ff       	call   801140 <fd_alloc>
  802097:	89 c3                	mov    %eax,%ebx
  802099:	83 c4 10             	add    $0x10,%esp
  80209c:	85 c0                	test   %eax,%eax
  80209e:	0f 88 24 01 00 00    	js     8021c8 <pipe+0x146>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8020a4:	83 ec 04             	sub    $0x4,%esp
  8020a7:	68 07 04 00 00       	push   $0x407
  8020ac:	ff 75 e4             	pushl  -0x1c(%ebp)
  8020af:	6a 00                	push   $0x0
  8020b1:	e8 4a ec ff ff       	call   800d00 <sys_page_alloc>
  8020b6:	89 c3                	mov    %eax,%ebx
  8020b8:	83 c4 10             	add    $0x10,%esp
  8020bb:	85 c0                	test   %eax,%eax
  8020bd:	0f 88 05 01 00 00    	js     8021c8 <pipe+0x146>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  8020c3:	83 ec 0c             	sub    $0xc,%esp
  8020c6:	8d 45 e0             	lea    -0x20(%ebp),%eax
  8020c9:	50                   	push   %eax
  8020ca:	e8 71 f0 ff ff       	call   801140 <fd_alloc>
  8020cf:	89 c3                	mov    %eax,%ebx
  8020d1:	83 c4 10             	add    $0x10,%esp
  8020d4:	85 c0                	test   %eax,%eax
  8020d6:	0f 88 dc 00 00 00    	js     8021b8 <pipe+0x136>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8020dc:	83 ec 04             	sub    $0x4,%esp
  8020df:	68 07 04 00 00       	push   $0x407
  8020e4:	ff 75 e0             	pushl  -0x20(%ebp)
  8020e7:	6a 00                	push   $0x0
  8020e9:	e8 12 ec ff ff       	call   800d00 <sys_page_alloc>
  8020ee:	89 c3                	mov    %eax,%ebx
  8020f0:	83 c4 10             	add    $0x10,%esp
  8020f3:	85 c0                	test   %eax,%eax
  8020f5:	0f 88 bd 00 00 00    	js     8021b8 <pipe+0x136>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  8020fb:	83 ec 0c             	sub    $0xc,%esp
  8020fe:	ff 75 e4             	pushl  -0x1c(%ebp)
  802101:	e8 22 f0 ff ff       	call   801128 <fd2data>
  802106:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802108:	83 c4 0c             	add    $0xc,%esp
  80210b:	68 07 04 00 00       	push   $0x407
  802110:	50                   	push   %eax
  802111:	6a 00                	push   $0x0
  802113:	e8 e8 eb ff ff       	call   800d00 <sys_page_alloc>
  802118:	89 c3                	mov    %eax,%ebx
  80211a:	83 c4 10             	add    $0x10,%esp
  80211d:	85 c0                	test   %eax,%eax
  80211f:	0f 88 83 00 00 00    	js     8021a8 <pipe+0x126>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802125:	83 ec 0c             	sub    $0xc,%esp
  802128:	ff 75 e0             	pushl  -0x20(%ebp)
  80212b:	e8 f8 ef ff ff       	call   801128 <fd2data>
  802130:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  802137:	50                   	push   %eax
  802138:	6a 00                	push   $0x0
  80213a:	56                   	push   %esi
  80213b:	6a 00                	push   $0x0
  80213d:	e8 e2 eb ff ff       	call   800d24 <sys_page_map>
  802142:	89 c3                	mov    %eax,%ebx
  802144:	83 c4 20             	add    $0x20,%esp
  802147:	85 c0                	test   %eax,%eax
  802149:	78 4f                	js     80219a <pipe+0x118>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  80214b:	8b 15 28 40 80 00    	mov    0x804028,%edx
  802151:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802154:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  802156:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802159:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  802160:	8b 15 28 40 80 00    	mov    0x804028,%edx
  802166:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802169:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  80216b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80216e:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  802175:	83 ec 0c             	sub    $0xc,%esp
  802178:	ff 75 e4             	pushl  -0x1c(%ebp)
  80217b:	e8 98 ef ff ff       	call   801118 <fd2num>
  802180:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  802182:	83 c4 04             	add    $0x4,%esp
  802185:	ff 75 e0             	pushl  -0x20(%ebp)
  802188:	e8 8b ef ff ff       	call   801118 <fd2num>
  80218d:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  802190:	83 c4 10             	add    $0x10,%esp
  802193:	bb 00 00 00 00       	mov    $0x0,%ebx
  802198:	eb 2e                	jmp    8021c8 <pipe+0x146>

    err3:
	sys_page_unmap(0, va);
  80219a:	83 ec 08             	sub    $0x8,%esp
  80219d:	56                   	push   %esi
  80219e:	6a 00                	push   $0x0
  8021a0:	e8 a5 eb ff ff       	call   800d4a <sys_page_unmap>
  8021a5:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  8021a8:	83 ec 08             	sub    $0x8,%esp
  8021ab:	ff 75 e0             	pushl  -0x20(%ebp)
  8021ae:	6a 00                	push   $0x0
  8021b0:	e8 95 eb ff ff       	call   800d4a <sys_page_unmap>
  8021b5:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  8021b8:	83 ec 08             	sub    $0x8,%esp
  8021bb:	ff 75 e4             	pushl  -0x1c(%ebp)
  8021be:	6a 00                	push   $0x0
  8021c0:	e8 85 eb ff ff       	call   800d4a <sys_page_unmap>
  8021c5:	83 c4 10             	add    $0x10,%esp
    err:
	return r;
}
  8021c8:	89 d8                	mov    %ebx,%eax
  8021ca:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8021cd:	5b                   	pop    %ebx
  8021ce:	5e                   	pop    %esi
  8021cf:	5f                   	pop    %edi
  8021d0:	c9                   	leave  
  8021d1:	c3                   	ret    

008021d2 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  8021d2:	55                   	push   %ebp
  8021d3:	89 e5                	mov    %esp,%ebp
  8021d5:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8021d8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8021db:	50                   	push   %eax
  8021dc:	ff 75 08             	pushl  0x8(%ebp)
  8021df:	e8 cf ef ff ff       	call   8011b3 <fd_lookup>
  8021e4:	83 c4 10             	add    $0x10,%esp
  8021e7:	85 c0                	test   %eax,%eax
  8021e9:	78 18                	js     802203 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  8021eb:	83 ec 0c             	sub    $0xc,%esp
  8021ee:	ff 75 f4             	pushl  -0xc(%ebp)
  8021f1:	e8 32 ef ff ff       	call   801128 <fd2data>
	return _pipeisclosed(fd, p);
  8021f6:	89 c2                	mov    %eax,%edx
  8021f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8021fb:	e8 0c fd ff ff       	call   801f0c <_pipeisclosed>
  802200:	83 c4 10             	add    $0x10,%esp
}
  802203:	c9                   	leave  
  802204:	c3                   	ret    
  802205:	00 00                	add    %al,(%eax)
	...

00802208 <wait>:
#include <inc/lib.h>

// Waits until 'envid' exits.
void
wait(envid_t envid)
{
  802208:	55                   	push   %ebp
  802209:	89 e5                	mov    %esp,%ebp
  80220b:	57                   	push   %edi
  80220c:	56                   	push   %esi
  80220d:	53                   	push   %ebx
  80220e:	83 ec 0c             	sub    $0xc,%esp
  802211:	8b 45 08             	mov    0x8(%ebp),%eax
	const volatile struct Env *e;

	assert(envid != 0);
  802214:	85 c0                	test   %eax,%eax
  802216:	75 16                	jne    80222e <wait+0x26>
  802218:	68 b5 2f 80 00       	push   $0x802fb5
  80221d:	68 c9 2e 80 00       	push   $0x802ec9
  802222:	6a 09                	push   $0x9
  802224:	68 c0 2f 80 00       	push   $0x802fc0
  802229:	e8 c2 df ff ff       	call   8001f0 <_panic>
	e = &envs[ENVX(envid)];
  80222e:	89 c6                	mov    %eax,%esi
  802230:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
	while (e->env_id == envid && e->env_status != ENV_FREE)
  802236:	8d 0c b5 00 00 00 00 	lea    0x0(,%esi,4),%ecx
  80223d:	89 f2                	mov    %esi,%edx
  80223f:	c1 e2 07             	shl    $0x7,%edx
  802242:	29 ca                	sub    %ecx,%edx
  802244:	81 c2 08 00 c0 ee    	add    $0xeec00008,%edx
  80224a:	8b 7a 40             	mov    0x40(%edx),%edi
  80224d:	39 c7                	cmp    %eax,%edi
  80224f:	75 37                	jne    802288 <wait+0x80>
  802251:	89 f0                	mov    %esi,%eax
  802253:	c1 e0 07             	shl    $0x7,%eax
  802256:	29 c8                	sub    %ecx,%eax
  802258:	05 04 00 c0 ee       	add    $0xeec00004,%eax
  80225d:	8b 40 50             	mov    0x50(%eax),%eax
  802260:	85 c0                	test   %eax,%eax
  802262:	74 24                	je     802288 <wait+0x80>
  802264:	c1 e6 07             	shl    $0x7,%esi
  802267:	29 ce                	sub    %ecx,%esi
  802269:	8d 9e 08 00 c0 ee    	lea    -0x113ffff8(%esi),%ebx
  80226f:	81 c6 04 00 c0 ee    	add    $0xeec00004,%esi
		sys_yield();
  802275:	e8 5f ea ff ff       	call   800cd9 <sys_yield>
{
	const volatile struct Env *e;

	assert(envid != 0);
	e = &envs[ENVX(envid)];
	while (e->env_id == envid && e->env_status != ENV_FREE)
  80227a:	8b 43 40             	mov    0x40(%ebx),%eax
  80227d:	39 f8                	cmp    %edi,%eax
  80227f:	75 07                	jne    802288 <wait+0x80>
  802281:	8b 46 50             	mov    0x50(%esi),%eax
  802284:	85 c0                	test   %eax,%eax
  802286:	75 ed                	jne    802275 <wait+0x6d>
		sys_yield();
}
  802288:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80228b:	5b                   	pop    %ebx
  80228c:	5e                   	pop    %esi
  80228d:	5f                   	pop    %edi
  80228e:	c9                   	leave  
  80228f:	c3                   	ret    

00802290 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  802290:	55                   	push   %ebp
  802291:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  802293:	b8 00 00 00 00       	mov    $0x0,%eax
  802298:	c9                   	leave  
  802299:	c3                   	ret    

0080229a <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80229a:	55                   	push   %ebp
  80229b:	89 e5                	mov    %esp,%ebp
  80229d:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  8022a0:	68 cb 2f 80 00       	push   $0x802fcb
  8022a5:	ff 75 0c             	pushl  0xc(%ebp)
  8022a8:	e8 d1 e5 ff ff       	call   80087e <strcpy>
	return 0;
}
  8022ad:	b8 00 00 00 00       	mov    $0x0,%eax
  8022b2:	c9                   	leave  
  8022b3:	c3                   	ret    

008022b4 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8022b4:	55                   	push   %ebp
  8022b5:	89 e5                	mov    %esp,%ebp
  8022b7:	57                   	push   %edi
  8022b8:	56                   	push   %esi
  8022b9:	53                   	push   %ebx
  8022ba:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8022c0:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8022c4:	74 45                	je     80230b <devcons_write+0x57>
  8022c6:	b8 00 00 00 00       	mov    $0x0,%eax
  8022cb:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8022d0:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  8022d6:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8022d9:	29 c3                	sub    %eax,%ebx
		if (m > sizeof(buf) - 1)
  8022db:	83 fb 7f             	cmp    $0x7f,%ebx
  8022de:	76 05                	jbe    8022e5 <devcons_write+0x31>
			m = sizeof(buf) - 1;
  8022e0:	bb 7f 00 00 00       	mov    $0x7f,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  8022e5:	83 ec 04             	sub    $0x4,%esp
  8022e8:	53                   	push   %ebx
  8022e9:	03 45 0c             	add    0xc(%ebp),%eax
  8022ec:	50                   	push   %eax
  8022ed:	57                   	push   %edi
  8022ee:	e8 4c e7 ff ff       	call   800a3f <memmove>
		sys_cputs(buf, m);
  8022f3:	83 c4 08             	add    $0x8,%esp
  8022f6:	53                   	push   %ebx
  8022f7:	57                   	push   %edi
  8022f8:	e8 4c e9 ff ff       	call   800c49 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8022fd:	01 de                	add    %ebx,%esi
  8022ff:	89 f0                	mov    %esi,%eax
  802301:	83 c4 10             	add    $0x10,%esp
  802304:	3b 75 10             	cmp    0x10(%ebp),%esi
  802307:	72 cd                	jb     8022d6 <devcons_write+0x22>
  802309:	eb 05                	jmp    802310 <devcons_write+0x5c>
  80230b:	be 00 00 00 00       	mov    $0x0,%esi
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  802310:	89 f0                	mov    %esi,%eax
  802312:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802315:	5b                   	pop    %ebx
  802316:	5e                   	pop    %esi
  802317:	5f                   	pop    %edi
  802318:	c9                   	leave  
  802319:	c3                   	ret    

0080231a <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  80231a:	55                   	push   %ebp
  80231b:	89 e5                	mov    %esp,%ebp
  80231d:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  802320:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  802324:	75 07                	jne    80232d <devcons_read+0x13>
  802326:	eb 25                	jmp    80234d <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  802328:	e8 ac e9 ff ff       	call   800cd9 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  80232d:	e8 3d e9 ff ff       	call   800c6f <sys_cgetc>
  802332:	85 c0                	test   %eax,%eax
  802334:	74 f2                	je     802328 <devcons_read+0xe>
  802336:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  802338:	85 c0                	test   %eax,%eax
  80233a:	78 1d                	js     802359 <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  80233c:	83 f8 04             	cmp    $0x4,%eax
  80233f:	74 13                	je     802354 <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  802341:	8b 45 0c             	mov    0xc(%ebp),%eax
  802344:	88 10                	mov    %dl,(%eax)
	return 1;
  802346:	b8 01 00 00 00       	mov    $0x1,%eax
  80234b:	eb 0c                	jmp    802359 <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  80234d:	b8 00 00 00 00       	mov    $0x0,%eax
  802352:	eb 05                	jmp    802359 <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  802354:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  802359:	c9                   	leave  
  80235a:	c3                   	ret    

0080235b <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  80235b:	55                   	push   %ebp
  80235c:	89 e5                	mov    %esp,%ebp
  80235e:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  802361:	8b 45 08             	mov    0x8(%ebp),%eax
  802364:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  802367:	6a 01                	push   $0x1
  802369:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80236c:	50                   	push   %eax
  80236d:	e8 d7 e8 ff ff       	call   800c49 <sys_cputs>
  802372:	83 c4 10             	add    $0x10,%esp
}
  802375:	c9                   	leave  
  802376:	c3                   	ret    

00802377 <getchar>:

int
getchar(void)
{
  802377:	55                   	push   %ebp
  802378:	89 e5                	mov    %esp,%ebp
  80237a:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  80237d:	6a 01                	push   $0x1
  80237f:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802382:	50                   	push   %eax
  802383:	6a 00                	push   $0x0
  802385:	e8 aa f0 ff ff       	call   801434 <read>
	if (r < 0)
  80238a:	83 c4 10             	add    $0x10,%esp
  80238d:	85 c0                	test   %eax,%eax
  80238f:	78 0f                	js     8023a0 <getchar+0x29>
		return r;
	if (r < 1)
  802391:	85 c0                	test   %eax,%eax
  802393:	7e 06                	jle    80239b <getchar+0x24>
		return -E_EOF;
	return c;
  802395:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  802399:	eb 05                	jmp    8023a0 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  80239b:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  8023a0:	c9                   	leave  
  8023a1:	c3                   	ret    

008023a2 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  8023a2:	55                   	push   %ebp
  8023a3:	89 e5                	mov    %esp,%ebp
  8023a5:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8023a8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8023ab:	50                   	push   %eax
  8023ac:	ff 75 08             	pushl  0x8(%ebp)
  8023af:	e8 ff ed ff ff       	call   8011b3 <fd_lookup>
  8023b4:	83 c4 10             	add    $0x10,%esp
  8023b7:	85 c0                	test   %eax,%eax
  8023b9:	78 11                	js     8023cc <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  8023bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8023be:	8b 15 44 40 80 00    	mov    0x804044,%edx
  8023c4:	39 10                	cmp    %edx,(%eax)
  8023c6:	0f 94 c0             	sete   %al
  8023c9:	0f b6 c0             	movzbl %al,%eax
}
  8023cc:	c9                   	leave  
  8023cd:	c3                   	ret    

008023ce <opencons>:

int
opencons(void)
{
  8023ce:	55                   	push   %ebp
  8023cf:	89 e5                	mov    %esp,%ebp
  8023d1:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8023d4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8023d7:	50                   	push   %eax
  8023d8:	e8 63 ed ff ff       	call   801140 <fd_alloc>
  8023dd:	83 c4 10             	add    $0x10,%esp
  8023e0:	85 c0                	test   %eax,%eax
  8023e2:	78 3a                	js     80241e <opencons+0x50>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8023e4:	83 ec 04             	sub    $0x4,%esp
  8023e7:	68 07 04 00 00       	push   $0x407
  8023ec:	ff 75 f4             	pushl  -0xc(%ebp)
  8023ef:	6a 00                	push   $0x0
  8023f1:	e8 0a e9 ff ff       	call   800d00 <sys_page_alloc>
  8023f6:	83 c4 10             	add    $0x10,%esp
  8023f9:	85 c0                	test   %eax,%eax
  8023fb:	78 21                	js     80241e <opencons+0x50>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8023fd:	8b 15 44 40 80 00    	mov    0x804044,%edx
  802403:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802406:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  802408:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80240b:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  802412:	83 ec 0c             	sub    $0xc,%esp
  802415:	50                   	push   %eax
  802416:	e8 fd ec ff ff       	call   801118 <fd2num>
  80241b:	83 c4 10             	add    $0x10,%esp
}
  80241e:	c9                   	leave  
  80241f:	c3                   	ret    

00802420 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  802420:	55                   	push   %ebp
  802421:	89 e5                	mov    %esp,%ebp
  802423:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  802426:	83 3d 00 70 80 00 00 	cmpl   $0x0,0x807000
  80242d:	75 52                	jne    802481 <set_pgfault_handler+0x61>
		// First time through!	
		// LAB 4: Your code here.

		//int sys_page_alloc(envid_t envid, void *va, int perm)
		r = sys_page_alloc(0, (void*)(UXSTACKTOP - PGSIZE), PTE_U | PTE_W | PTE_P);
  80242f:	83 ec 04             	sub    $0x4,%esp
  802432:	6a 07                	push   $0x7
  802434:	68 00 f0 bf ee       	push   $0xeebff000
  802439:	6a 00                	push   $0x0
  80243b:	e8 c0 e8 ff ff       	call   800d00 <sys_page_alloc>
		if (r < 0) {
  802440:	83 c4 10             	add    $0x10,%esp
  802443:	85 c0                	test   %eax,%eax
  802445:	79 12                	jns    802459 <set_pgfault_handler+0x39>
			panic("sys_page_alloc error : %e\n", r);
  802447:	50                   	push   %eax
  802448:	68 d7 2f 80 00       	push   $0x802fd7
  80244d:	6a 24                	push   $0x24
  80244f:	68 f2 2f 80 00       	push   $0x802ff2
  802454:	e8 97 dd ff ff       	call   8001f0 <_panic>
		}

		// how to know envid, put 0, envid2env will help us to get curenv in syscall
		r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);		
  802459:	83 ec 08             	sub    $0x8,%esp
  80245c:	68 8c 24 80 00       	push   $0x80248c
  802461:	6a 00                	push   $0x0
  802463:	e8 4b e9 ff ff       	call   800db3 <sys_env_set_pgfault_upcall>
		if (r < 0) {
  802468:	83 c4 10             	add    $0x10,%esp
  80246b:	85 c0                	test   %eax,%eax
  80246d:	79 12                	jns    802481 <set_pgfault_handler+0x61>
			panic("sys_env_set_pgfault_upcall error : %e\n", r);
  80246f:	50                   	push   %eax
  802470:	68 00 30 80 00       	push   $0x803000
  802475:	6a 2a                	push   $0x2a
  802477:	68 f2 2f 80 00       	push   $0x802ff2
  80247c:	e8 6f dd ff ff       	call   8001f0 <_panic>
		}
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  802481:	8b 45 08             	mov    0x8(%ebp),%eax
  802484:	a3 00 70 80 00       	mov    %eax,0x807000
}
  802489:	c9                   	leave  
  80248a:	c3                   	ret    
	...

0080248c <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  80248c:	54                   	push   %esp
	movl _pgfault_handler, %eax
  80248d:	a1 00 70 80 00       	mov    0x807000,%eax
	call *%eax
  802492:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  802494:	83 c4 04             	add    $0x4,%esp
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	
	// fix old esp
	movl 0x30(%esp), %eax
  802497:	8b 44 24 30          	mov    0x30(%esp),%eax
	subl $0x4, %eax
  80249b:	83 e8 04             	sub    $0x4,%eax
	movl %eax, 0x30(%esp)
  80249e:	89 44 24 30          	mov    %eax,0x30(%esp)

	// set trap-time %eip
	movl 0x28(%esp), %ebx
  8024a2:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	movl %ebx, (%eax)
  8024a6:	89 18                	mov    %ebx,(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $0x08, %esp 	// ignore err_code and fault_va
  8024a8:	83 c4 08             	add    $0x8,%esp
	popal 				// restore registers
  8024ab:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x04, %esp 	// ignore eip 
  8024ac:	83 c4 04             	add    $0x4,%esp
	popfl				// modify eflags
  8024af:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  8024b0:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  8024b1:	c3                   	ret    
	...

008024b4 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8024b4:	55                   	push   %ebp
  8024b5:	89 e5                	mov    %esp,%ebp
  8024b7:	57                   	push   %edi
  8024b8:	56                   	push   %esi
  8024b9:	53                   	push   %ebx
  8024ba:	83 ec 0c             	sub    $0xc,%esp
  8024bd:	8b 7d 08             	mov    0x8(%ebp),%edi
  8024c0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8024c3:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	cprintf("0x%x 0x%x 0x%x\n", (uint32_t)from_env_store, (uint32_t)pg, (uint32_t)perm_store);
  8024c6:	56                   	push   %esi
  8024c7:	53                   	push   %ebx
  8024c8:	57                   	push   %edi
  8024c9:	68 28 30 80 00       	push   $0x803028
  8024ce:	e8 f5 dd ff ff       	call   8002c8 <cprintf>
	int r;
	if (pg != NULL) {
  8024d3:	83 c4 10             	add    $0x10,%esp
  8024d6:	85 db                	test   %ebx,%ebx
  8024d8:	74 28                	je     802502 <ipc_recv+0x4e>
		cprintf("BEGIN\n");
  8024da:	83 ec 0c             	sub    $0xc,%esp
  8024dd:	68 38 30 80 00       	push   $0x803038
  8024e2:	e8 e1 dd ff ff       	call   8002c8 <cprintf>
		r = sys_ipc_recv(pg);
  8024e7:	89 1c 24             	mov    %ebx,(%esp)
  8024ea:	e8 0c e9 ff ff       	call   800dfb <sys_ipc_recv>
  8024ef:	89 c3                	mov    %eax,%ebx
		cprintf("OVER\n");
  8024f1:	c7 04 24 bc 2e 80 00 	movl   $0x802ebc,(%esp)
  8024f8:	e8 cb dd ff ff       	call   8002c8 <cprintf>
  8024fd:	83 c4 10             	add    $0x10,%esp
  802500:	eb 12                	jmp    802514 <ipc_recv+0x60>
	} else {
		r = sys_ipc_recv((void *)UTOP);
  802502:	83 ec 0c             	sub    $0xc,%esp
  802505:	68 00 00 c0 ee       	push   $0xeec00000
  80250a:	e8 ec e8 ff ff       	call   800dfb <sys_ipc_recv>
  80250f:	89 c3                	mov    %eax,%ebx
  802511:	83 c4 10             	add    $0x10,%esp
	}

	if (r == 0) {
  802514:	85 db                	test   %ebx,%ebx
  802516:	75 26                	jne    80253e <ipc_recv+0x8a>
		if (from_env_store != NULL) *from_env_store = thisenv->env_ipc_from;
  802518:	85 ff                	test   %edi,%edi
  80251a:	74 0a                	je     802526 <ipc_recv+0x72>
  80251c:	a1 04 50 80 00       	mov    0x805004,%eax
  802521:	8b 40 74             	mov    0x74(%eax),%eax
  802524:	89 07                	mov    %eax,(%edi)
		if (perm_store != NULL) *perm_store = thisenv->env_ipc_perm;
  802526:	85 f6                	test   %esi,%esi
  802528:	74 0a                	je     802534 <ipc_recv+0x80>
  80252a:	a1 04 50 80 00       	mov    0x805004,%eax
  80252f:	8b 40 78             	mov    0x78(%eax),%eax
  802532:	89 06                	mov    %eax,(%esi)
		return thisenv->env_ipc_value;
  802534:	a1 04 50 80 00       	mov    0x805004,%eax
  802539:	8b 58 70             	mov    0x70(%eax),%ebx
  80253c:	eb 14                	jmp    802552 <ipc_recv+0x9e>
	} else {
		// fails;
		if (from_env_store != NULL) *from_env_store = 0;
  80253e:	85 ff                	test   %edi,%edi
  802540:	74 06                	je     802548 <ipc_recv+0x94>
  802542:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
		if (perm_store != NULL) *perm_store = 0;
  802548:	85 f6                	test   %esi,%esi
  80254a:	74 06                	je     802552 <ipc_recv+0x9e>
  80254c:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		return r;
	}
}
  802552:	89 d8                	mov    %ebx,%eax
  802554:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802557:	5b                   	pop    %ebx
  802558:	5e                   	pop    %esi
  802559:	5f                   	pop    %edi
  80255a:	c9                   	leave  
  80255b:	c3                   	ret    

0080255c <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80255c:	55                   	push   %ebp
  80255d:	89 e5                	mov    %esp,%ebp
  80255f:	57                   	push   %edi
  802560:	56                   	push   %esi
  802561:	53                   	push   %ebx
  802562:	83 ec 0c             	sub    $0xc,%esp
  802565:	8b 7d 0c             	mov    0xc(%ebp),%edi
  802568:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80256b:	8b 75 14             	mov    0x14(%ebp),%esi
	// LAB 4: Your code here.
	// int sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
	int r;
	if (pg == NULL) pg = (void *)UTOP;
  80256e:	85 db                	test   %ebx,%ebx
  802570:	75 25                	jne    802597 <ipc_send+0x3b>
  802572:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
  802577:	eb 1e                	jmp    802597 <ipc_send+0x3b>
	
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) != 0) {
		if (r == -E_IPC_NOT_RECV) {
  802579:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80257c:	75 07                	jne    802585 <ipc_send+0x29>
			// cprintf("Try Again and Again....\n");
			sys_yield();
  80257e:	e8 56 e7 ff ff       	call   800cd9 <sys_yield>
  802583:	eb 12                	jmp    802597 <ipc_send+0x3b>
		} else {
			panic("ipc_send error %e\n", r);
  802585:	50                   	push   %eax
  802586:	68 3f 30 80 00       	push   $0x80303f
  80258b:	6a 45                	push   $0x45
  80258d:	68 52 30 80 00       	push   $0x803052
  802592:	e8 59 dc ff ff       	call   8001f0 <_panic>
	// LAB 4: Your code here.
	// int sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
	int r;
	if (pg == NULL) pg = (void *)UTOP;
	
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) != 0) {
  802597:	56                   	push   %esi
  802598:	53                   	push   %ebx
  802599:	57                   	push   %edi
  80259a:	ff 75 08             	pushl  0x8(%ebp)
  80259d:	e8 34 e8 ff ff       	call   800dd6 <sys_ipc_try_send>
  8025a2:	83 c4 10             	add    $0x10,%esp
  8025a5:	85 c0                	test   %eax,%eax
  8025a7:	75 d0                	jne    802579 <ipc_send+0x1d>
		} else {
			panic("ipc_send error %e\n", r);
		}
	}
	return;
}
  8025a9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8025ac:	5b                   	pop    %ebx
  8025ad:	5e                   	pop    %esi
  8025ae:	5f                   	pop    %edi
  8025af:	c9                   	leave  
  8025b0:	c3                   	ret    

008025b1 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8025b1:	55                   	push   %ebp
  8025b2:	89 e5                	mov    %esp,%ebp
  8025b4:	53                   	push   %ebx
  8025b5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  8025b8:	39 1d 50 00 c0 ee    	cmp    %ebx,0xeec00050
  8025be:	74 22                	je     8025e2 <ipc_find_env+0x31>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8025c0:	b8 01 00 00 00       	mov    $0x1,%eax
		if (envs[i].env_type == type)
  8025c5:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  8025cc:	89 c2                	mov    %eax,%edx
  8025ce:	c1 e2 07             	shl    $0x7,%edx
  8025d1:	29 ca                	sub    %ecx,%edx
  8025d3:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8025d9:	8b 52 50             	mov    0x50(%edx),%edx
  8025dc:	39 da                	cmp    %ebx,%edx
  8025de:	75 1d                	jne    8025fd <ipc_find_env+0x4c>
  8025e0:	eb 05                	jmp    8025e7 <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8025e2:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
			return envs[i].env_id;
  8025e7:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  8025ee:	c1 e0 07             	shl    $0x7,%eax
  8025f1:	29 d0                	sub    %edx,%eax
  8025f3:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  8025f8:	8b 40 40             	mov    0x40(%eax),%eax
  8025fb:	eb 0c                	jmp    802609 <ipc_find_env+0x58>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8025fd:	40                   	inc    %eax
  8025fe:	3d 00 04 00 00       	cmp    $0x400,%eax
  802603:	75 c0                	jne    8025c5 <ipc_find_env+0x14>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802605:	66 b8 00 00          	mov    $0x0,%ax
}
  802609:	5b                   	pop    %ebx
  80260a:	c9                   	leave  
  80260b:	c3                   	ret    

0080260c <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  80260c:	55                   	push   %ebp
  80260d:	89 e5                	mov    %esp,%ebp
  80260f:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802612:	89 c2                	mov    %eax,%edx
  802614:	c1 ea 16             	shr    $0x16,%edx
  802617:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80261e:	f6 c2 01             	test   $0x1,%dl
  802621:	74 1e                	je     802641 <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  802623:	c1 e8 0c             	shr    $0xc,%eax
  802626:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  80262d:	a8 01                	test   $0x1,%al
  80262f:	74 17                	je     802648 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802631:	c1 e8 0c             	shr    $0xc,%eax
  802634:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  80263b:	ef 
  80263c:	0f b7 c0             	movzwl %ax,%eax
  80263f:	eb 0c                	jmp    80264d <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  802641:	b8 00 00 00 00       	mov    $0x0,%eax
  802646:	eb 05                	jmp    80264d <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  802648:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  80264d:	c9                   	leave  
  80264e:	c3                   	ret    
	...

00802650 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  802650:	55                   	push   %ebp
  802651:	89 e5                	mov    %esp,%ebp
  802653:	57                   	push   %edi
  802654:	56                   	push   %esi
  802655:	83 ec 10             	sub    $0x10,%esp
  802658:	8b 7d 08             	mov    0x8(%ebp),%edi
  80265b:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  80265e:	89 7d f0             	mov    %edi,-0x10(%ebp)
  802661:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  802664:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  802667:	8b 45 14             	mov    0x14(%ebp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  80266a:	85 c0                	test   %eax,%eax
  80266c:	75 2e                	jne    80269c <__udivdi3+0x4c>
    {
      if (d0 > n1)
  80266e:	39 f1                	cmp    %esi,%ecx
  802670:	77 5a                	ja     8026cc <__udivdi3+0x7c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  802672:	85 c9                	test   %ecx,%ecx
  802674:	75 0b                	jne    802681 <__udivdi3+0x31>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  802676:	b8 01 00 00 00       	mov    $0x1,%eax
  80267b:	31 d2                	xor    %edx,%edx
  80267d:	f7 f1                	div    %ecx
  80267f:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  802681:	31 d2                	xor    %edx,%edx
  802683:	89 f0                	mov    %esi,%eax
  802685:	f7 f1                	div    %ecx
  802687:	89 c6                	mov    %eax,%esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802689:	89 f8                	mov    %edi,%eax
  80268b:	f7 f1                	div    %ecx
  80268d:	89 c7                	mov    %eax,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  80268f:	89 f8                	mov    %edi,%eax
  802691:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802693:	83 c4 10             	add    $0x10,%esp
  802696:	5e                   	pop    %esi
  802697:	5f                   	pop    %edi
  802698:	c9                   	leave  
  802699:	c3                   	ret    
  80269a:	66 90                	xchg   %ax,%ax
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  80269c:	39 f0                	cmp    %esi,%eax
  80269e:	77 1c                	ja     8026bc <__udivdi3+0x6c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  8026a0:	0f bd f8             	bsr    %eax,%edi
	  if (bm == 0)
  8026a3:	83 f7 1f             	xor    $0x1f,%edi
  8026a6:	75 3c                	jne    8026e4 <__udivdi3+0x94>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  8026a8:	39 f0                	cmp    %esi,%eax
  8026aa:	0f 82 90 00 00 00    	jb     802740 <__udivdi3+0xf0>
  8026b0:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8026b3:	39 55 f4             	cmp    %edx,-0xc(%ebp)
  8026b6:	0f 86 84 00 00 00    	jbe    802740 <__udivdi3+0xf0>
  8026bc:	31 f6                	xor    %esi,%esi
  8026be:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  8026c0:	89 f8                	mov    %edi,%eax
  8026c2:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  8026c4:	83 c4 10             	add    $0x10,%esp
  8026c7:	5e                   	pop    %esi
  8026c8:	5f                   	pop    %edi
  8026c9:	c9                   	leave  
  8026ca:	c3                   	ret    
  8026cb:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8026cc:	89 f2                	mov    %esi,%edx
  8026ce:	89 f8                	mov    %edi,%eax
  8026d0:	f7 f1                	div    %ecx
  8026d2:	89 c7                	mov    %eax,%edi
  8026d4:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  8026d6:	89 f8                	mov    %edi,%eax
  8026d8:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  8026da:	83 c4 10             	add    $0x10,%esp
  8026dd:	5e                   	pop    %esi
  8026de:	5f                   	pop    %edi
  8026df:	c9                   	leave  
  8026e0:	c3                   	ret    
  8026e1:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  8026e4:	89 f9                	mov    %edi,%ecx
  8026e6:	d3 e0                	shl    %cl,%eax
  8026e8:	89 45 e8             	mov    %eax,-0x18(%ebp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  8026eb:	b8 20 00 00 00       	mov    $0x20,%eax
  8026f0:	29 f8                	sub    %edi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  8026f2:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8026f5:	88 c1                	mov    %al,%cl
  8026f7:	d3 ea                	shr    %cl,%edx
  8026f9:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  8026fc:	09 ca                	or     %ecx,%edx
  8026fe:	89 55 ec             	mov    %edx,-0x14(%ebp)
	      d0 = d0 << bm;
  802701:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802704:	89 f9                	mov    %edi,%ecx
  802706:	d3 e2                	shl    %cl,%edx
  802708:	89 55 f4             	mov    %edx,-0xc(%ebp)
	      n2 = n1 >> b;
  80270b:	89 f2                	mov    %esi,%edx
  80270d:	88 c1                	mov    %al,%cl
  80270f:	d3 ea                	shr    %cl,%edx
  802711:	89 55 e8             	mov    %edx,-0x18(%ebp)
	      n1 = (n1 << bm) | (n0 >> b);
  802714:	89 f2                	mov    %esi,%edx
  802716:	89 f9                	mov    %edi,%ecx
  802718:	d3 e2                	shl    %cl,%edx
  80271a:	8b 75 f0             	mov    -0x10(%ebp),%esi
  80271d:	88 c1                	mov    %al,%cl
  80271f:	d3 ee                	shr    %cl,%esi
  802721:	09 d6                	or     %edx,%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  802723:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  802726:	89 f0                	mov    %esi,%eax
  802728:	89 ca                	mov    %ecx,%edx
  80272a:	f7 75 ec             	divl   -0x14(%ebp)
  80272d:	89 d1                	mov    %edx,%ecx
  80272f:	89 c6                	mov    %eax,%esi
	      umul_ppmm (m1, m0, q0, d0);
  802731:	f7 65 f4             	mull   -0xc(%ebp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802734:	39 d1                	cmp    %edx,%ecx
  802736:	72 28                	jb     802760 <__udivdi3+0x110>
  802738:	74 1a                	je     802754 <__udivdi3+0x104>
  80273a:	89 f7                	mov    %esi,%edi
  80273c:	31 f6                	xor    %esi,%esi
  80273e:	eb 80                	jmp    8026c0 <__udivdi3+0x70>
	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  802740:	31 f6                	xor    %esi,%esi
  802742:	bf 01 00 00 00       	mov    $0x1,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  802747:	89 f8                	mov    %edi,%eax
  802749:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  80274b:	83 c4 10             	add    $0x10,%esp
  80274e:	5e                   	pop    %esi
  80274f:	5f                   	pop    %edi
  802750:	c9                   	leave  
  802751:	c3                   	ret    
  802752:	66 90                	xchg   %ax,%ax

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  802754:	8b 55 f0             	mov    -0x10(%ebp),%edx
  802757:	89 f9                	mov    %edi,%ecx
  802759:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  80275b:	39 c2                	cmp    %eax,%edx
  80275d:	73 db                	jae    80273a <__udivdi3+0xea>
  80275f:	90                   	nop
		{
		  q0--;
  802760:	8d 7e ff             	lea    -0x1(%esi),%edi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  802763:	31 f6                	xor    %esi,%esi
  802765:	e9 56 ff ff ff       	jmp    8026c0 <__udivdi3+0x70>
	...

0080276c <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  80276c:	55                   	push   %ebp
  80276d:	89 e5                	mov    %esp,%ebp
  80276f:	57                   	push   %edi
  802770:	56                   	push   %esi
  802771:	83 ec 20             	sub    $0x20,%esp
  802774:	8b 45 08             	mov    0x8(%ebp),%eax
  802777:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  80277a:	89 45 e8             	mov    %eax,-0x18(%ebp)
  80277d:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  802780:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  802783:	8b 7d 14             	mov    0x14(%ebp),%edi
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  802786:	89 45 f0             	mov    %eax,-0x10(%ebp)
  n1 = nn.s.high;
  802789:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  80278b:	85 ff                	test   %edi,%edi
  80278d:	75 15                	jne    8027a4 <__umoddi3+0x38>
    {
      if (d0 > n1)
  80278f:	39 f1                	cmp    %esi,%ecx
  802791:	0f 86 99 00 00 00    	jbe    802830 <__umoddi3+0xc4>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802797:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  802799:	89 d0                	mov    %edx,%eax
  80279b:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  80279d:	83 c4 20             	add    $0x20,%esp
  8027a0:	5e                   	pop    %esi
  8027a1:	5f                   	pop    %edi
  8027a2:	c9                   	leave  
  8027a3:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  8027a4:	39 f7                	cmp    %esi,%edi
  8027a6:	0f 87 a4 00 00 00    	ja     802850 <__umoddi3+0xe4>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  8027ac:	0f bd c7             	bsr    %edi,%eax
	  if (bm == 0)
  8027af:	83 f0 1f             	xor    $0x1f,%eax
  8027b2:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8027b5:	0f 84 a1 00 00 00    	je     80285c <__umoddi3+0xf0>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  8027bb:	89 f8                	mov    %edi,%eax
  8027bd:	8a 4d ec             	mov    -0x14(%ebp),%cl
  8027c0:	d3 e0                	shl    %cl,%eax
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  8027c2:	bf 20 00 00 00       	mov    $0x20,%edi
  8027c7:	2b 7d ec             	sub    -0x14(%ebp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  8027ca:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8027cd:	89 f9                	mov    %edi,%ecx
  8027cf:	d3 ea                	shr    %cl,%edx
  8027d1:	09 c2                	or     %eax,%edx
  8027d3:	89 55 f0             	mov    %edx,-0x10(%ebp)
	      d0 = d0 << bm;
  8027d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8027d9:	8a 4d ec             	mov    -0x14(%ebp),%cl
  8027dc:	d3 e0                	shl    %cl,%eax
  8027de:	89 45 f4             	mov    %eax,-0xc(%ebp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  8027e1:	89 f2                	mov    %esi,%edx
  8027e3:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  8027e5:	8b 45 e8             	mov    -0x18(%ebp),%eax
  8027e8:	d3 e0                	shl    %cl,%eax
  8027ea:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  8027ed:	8b 45 e8             	mov    -0x18(%ebp),%eax
  8027f0:	89 f9                	mov    %edi,%ecx
  8027f2:	d3 e8                	shr    %cl,%eax
  8027f4:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  8027f6:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  8027f8:	89 f2                	mov    %esi,%edx
  8027fa:	f7 75 f0             	divl   -0x10(%ebp)
  8027fd:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  8027ff:	f7 65 f4             	mull   -0xc(%ebp)
  802802:	89 55 e8             	mov    %edx,-0x18(%ebp)
  802805:	89 c1                	mov    %eax,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802807:	39 d6                	cmp    %edx,%esi
  802809:	72 71                	jb     80287c <__umoddi3+0x110>
  80280b:	74 7f                	je     80288c <__umoddi3+0x120>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  80280d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802810:	29 c8                	sub    %ecx,%eax
  802812:	19 d6                	sbb    %edx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  802814:	8a 4d ec             	mov    -0x14(%ebp),%cl
  802817:	d3 e8                	shr    %cl,%eax
  802819:	89 f2                	mov    %esi,%edx
  80281b:	89 f9                	mov    %edi,%ecx
  80281d:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  80281f:	09 d0                	or     %edx,%eax
  802821:	89 f2                	mov    %esi,%edx
  802823:	8a 4d ec             	mov    -0x14(%ebp),%cl
  802826:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802828:	83 c4 20             	add    $0x20,%esp
  80282b:	5e                   	pop    %esi
  80282c:	5f                   	pop    %edi
  80282d:	c9                   	leave  
  80282e:	c3                   	ret    
  80282f:	90                   	nop
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  802830:	85 c9                	test   %ecx,%ecx
  802832:	75 0b                	jne    80283f <__umoddi3+0xd3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  802834:	b8 01 00 00 00       	mov    $0x1,%eax
  802839:	31 d2                	xor    %edx,%edx
  80283b:	f7 f1                	div    %ecx
  80283d:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  80283f:	89 f0                	mov    %esi,%eax
  802841:	31 d2                	xor    %edx,%edx
  802843:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802845:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802848:	f7 f1                	div    %ecx
  80284a:	e9 4a ff ff ff       	jmp    802799 <__umoddi3+0x2d>
  80284f:	90                   	nop
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  802850:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802852:	83 c4 20             	add    $0x20,%esp
  802855:	5e                   	pop    %esi
  802856:	5f                   	pop    %edi
  802857:	c9                   	leave  
  802858:	c3                   	ret    
  802859:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  80285c:	39 f7                	cmp    %esi,%edi
  80285e:	72 05                	jb     802865 <__umoddi3+0xf9>
  802860:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
  802863:	77 0c                	ja     802871 <__umoddi3+0x105>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  802865:	89 f2                	mov    %esi,%edx
  802867:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80286a:	29 c8                	sub    %ecx,%eax
  80286c:	19 fa                	sbb    %edi,%edx
  80286e:	89 45 f0             	mov    %eax,-0x10(%ebp)

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  802871:	8b 45 f0             	mov    -0x10(%ebp),%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802874:	83 c4 20             	add    $0x20,%esp
  802877:	5e                   	pop    %esi
  802878:	5f                   	pop    %edi
  802879:	c9                   	leave  
  80287a:	c3                   	ret    
  80287b:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  80287c:	8b 55 e8             	mov    -0x18(%ebp),%edx
  80287f:	89 c1                	mov    %eax,%ecx
  802881:	2b 4d f4             	sub    -0xc(%ebp),%ecx
  802884:	1b 55 f0             	sbb    -0x10(%ebp),%edx
  802887:	eb 84                	jmp    80280d <__umoddi3+0xa1>
  802889:	8d 76 00             	lea    0x0(%esi),%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  80288c:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  80288f:	72 eb                	jb     80287c <__umoddi3+0x110>
  802891:	89 f2                	mov    %esi,%edx
  802893:	e9 75 ff ff ff       	jmp    80280d <__umoddi3+0xa1>
