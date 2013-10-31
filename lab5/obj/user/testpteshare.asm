
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
  800082:	68 2c 29 80 00       	push   $0x80292c
  800087:	6a 13                	push   $0x13
  800089:	68 3f 29 80 00       	push   $0x80293f
  80008e:	e8 5d 01 00 00       	call   8001f0 <_panic>

	// check fork
	if ((r = fork()) < 0)
  800093:	e8 7a 0e 00 00       	call   800f12 <fork>
  800098:	89 c3                	mov    %eax,%ebx
  80009a:	85 c0                	test   %eax,%eax
  80009c:	79 12                	jns    8000b0 <umain+0x5c>
		panic("fork: %e", r);
  80009e:	50                   	push   %eax
  80009f:	68 53 29 80 00       	push   $0x802953
  8000a4:	6a 17                	push   $0x17
  8000a6:	68 3f 29 80 00       	push   $0x80293f
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
  8000d3:	e8 e0 21 00 00       	call   8022b8 <wait>
	cprintf("fork handles PTE_SHARE %s\n", strcmp(VA, msg) == 0 ? "right" : "wrong");
  8000d8:	83 c4 08             	add    $0x8,%esp
  8000db:	ff 35 00 40 80 00    	pushl  0x804000
  8000e1:	68 00 00 00 a0       	push   $0xa0000000
  8000e6:	e8 4c 08 00 00       	call   800937 <strcmp>
  8000eb:	83 c4 10             	add    $0x10,%esp
  8000ee:	85 c0                	test   %eax,%eax
  8000f0:	75 07                	jne    8000f9 <umain+0xa5>
  8000f2:	b8 20 29 80 00       	mov    $0x802920,%eax
  8000f7:	eb 05                	jmp    8000fe <umain+0xaa>
  8000f9:	b8 26 29 80 00       	mov    $0x802926,%eax
  8000fe:	83 ec 08             	sub    $0x8,%esp
  800101:	50                   	push   %eax
  800102:	68 5c 29 80 00       	push   $0x80295c
  800107:	e8 bc 01 00 00       	call   8002c8 <cprintf>

	// check spawn
	if ((r = spawnl("/testpteshare", "testpteshare", "arg", 0)) < 0)
  80010c:	6a 00                	push   $0x0
  80010e:	68 77 29 80 00       	push   $0x802977
  800113:	68 7c 29 80 00       	push   $0x80297c
  800118:	68 7b 29 80 00       	push   $0x80297b
  80011d:	e8 9a 1d 00 00       	call   801ebc <spawnl>
  800122:	83 c4 20             	add    $0x20,%esp
  800125:	85 c0                	test   %eax,%eax
  800127:	79 12                	jns    80013b <umain+0xe7>
		panic("spawn: %e", r);
  800129:	50                   	push   %eax
  80012a:	68 89 29 80 00       	push   $0x802989
  80012f:	6a 21                	push   $0x21
  800131:	68 3f 29 80 00       	push   $0x80293f
  800136:	e8 b5 00 00 00       	call   8001f0 <_panic>
	wait(r);
  80013b:	83 ec 0c             	sub    $0xc,%esp
  80013e:	50                   	push   %eax
  80013f:	e8 74 21 00 00       	call   8022b8 <wait>
	cprintf("spawn handles PTE_SHARE %s\n", strcmp(VA, msg2) == 0 ? "right" : "wrong");
  800144:	83 c4 08             	add    $0x8,%esp
  800147:	ff 35 04 40 80 00    	pushl  0x804004
  80014d:	68 00 00 00 a0       	push   $0xa0000000
  800152:	e8 e0 07 00 00       	call   800937 <strcmp>
  800157:	83 c4 10             	add    $0x10,%esp
  80015a:	85 c0                	test   %eax,%eax
  80015c:	75 07                	jne    800165 <umain+0x111>
  80015e:	b8 20 29 80 00       	mov    $0x802920,%eax
  800163:	eb 05                	jmp    80016a <umain+0x116>
  800165:	b8 26 29 80 00       	mov    $0x802926,%eax
  80016a:	83 ec 08             	sub    $0x8,%esp
  80016d:	50                   	push   %eax
  80016e:	68 93 29 80 00       	push   $0x802993
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
  8001da:	e8 87 11 00 00       	call   801366 <close_all>
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
  80020e:	68 d8 29 80 00       	push   $0x8029d8
  800213:	e8 b0 00 00 00       	call   8002c8 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800218:	83 c4 18             	add    $0x18,%esp
  80021b:	56                   	push   %esi
  80021c:	ff 75 10             	pushl  0x10(%ebp)
  80021f:	e8 53 00 00 00       	call   800277 <vcprintf>
	cprintf("\n");
  800224:	c7 04 24 3a 30 80 00 	movl   $0x80303a,(%esp)
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
  800330:	e8 9b 23 00 00       	call   8026d0 <__udivdi3>
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
  80036c:	e8 7b 24 00 00       	call   8027ec <__umoddi3>
  800371:	83 c4 14             	add    $0x14,%esp
  800374:	0f be 80 fb 29 80 00 	movsbl 0x8029fb(%eax),%eax
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
  8004b8:	ff 24 85 40 2b 80 00 	jmp    *0x802b40(,%eax,4)
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
  800564:	8b 04 85 a0 2c 80 00 	mov    0x802ca0(,%eax,4),%eax
  80056b:	85 c0                	test   %eax,%eax
  80056d:	75 1a                	jne    800589 <vprintfmt+0x15c>
				printfmt(putch, putdat, "error %d", err);
  80056f:	52                   	push   %edx
  800570:	68 13 2a 80 00       	push   $0x802a13
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
  80058a:	68 55 2f 80 00       	push   $0x802f55
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
  8005c0:	c7 45 d0 0c 2a 80 00 	movl   $0x802a0c,-0x30(%ebp)
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
  800c2e:	68 ff 2c 80 00       	push   $0x802cff
  800c33:	6a 42                	push   $0x42
  800c35:	68 1c 2d 80 00       	push   $0x802d1c
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
  800e55:	68 2c 2d 80 00       	push   $0x802d2c
  800e5a:	6a 20                	push   $0x20
  800e5c:	68 70 2e 80 00       	push   $0x802e70
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
  800e8a:	68 50 2d 80 00       	push   $0x802d50
  800e8f:	6a 24                	push   $0x24
  800e91:	68 70 2e 80 00       	push   $0x802e70
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
  800eb4:	68 74 2d 80 00       	push   $0x802d74
  800eb9:	6a 32                	push   $0x32
  800ebb:	68 70 2e 80 00       	push   $0x802e70
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
  800efc:	68 98 2d 80 00       	push   $0x802d98
  800f01:	6a 3a                	push   $0x3a
  800f03:	68 70 2e 80 00       	push   $0x802e70
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
  800f20:	e8 ab 15 00 00       	call   8024d0 <set_pgfault_handler>
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
  800f3b:	68 7b 2e 80 00       	push   $0x802e7b
  800f40:	6a 7f                	push   $0x7f
  800f42:	68 70 2e 80 00       	push   $0x802e70
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
  800f72:	e9 be 01 00 00       	jmp    801135 <fork+0x223>
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
  800f8a:	0f 84 10 01 00 00    	je     8010a0 <fork+0x18e>
  800f90:	89 d8                	mov    %ebx,%eax
  800f92:	c1 e8 0c             	shr    $0xc,%eax
  800f95:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800f9c:	f6 c2 01             	test   $0x1,%dl
  800f9f:	0f 84 fb 00 00 00    	je     8010a0 <fork+0x18e>
  800fa5:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800fac:	f6 c2 04             	test   $0x4,%dl
  800faf:	0f 84 eb 00 00 00    	je     8010a0 <fork+0x18e>
//
static int
duppage(envid_t envid, unsigned pn)
{
	// do not dup exception stack
	if (pn * PGSIZE == UXSTACKTOP - PGSIZE) return 0;
  800fb5:	89 c6                	mov    %eax,%esi
  800fb7:	c1 e6 0c             	shl    $0xc,%esi
  800fba:	81 fe 00 f0 bf ee    	cmp    $0xeebff000,%esi
  800fc0:	0f 84 da 00 00 00    	je     8010a0 <fork+0x18e>

	int r;
	void * addr = (void *)(pn * PGSIZE);
    if (uvpt[pn] & PTE_SHARE) {
  800fc6:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800fcd:	f6 c6 04             	test   $0x4,%dh
  800fd0:	74 37                	je     801009 <fork+0xf7>
        r = sys_page_map(0, addr, envid, addr, uvpt[pn] & PTE_SYSCALL);
  800fd2:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800fd9:	83 ec 0c             	sub    $0xc,%esp
  800fdc:	25 07 0e 00 00       	and    $0xe07,%eax
  800fe1:	50                   	push   %eax
  800fe2:	56                   	push   %esi
  800fe3:	57                   	push   %edi
  800fe4:	56                   	push   %esi
  800fe5:	6a 00                	push   $0x0
  800fe7:	e8 38 fd ff ff       	call   800d24 <sys_page_map>
        if (r < 0) panic("duppage sys_page_map error : %e\n", r);
  800fec:	83 c4 20             	add    $0x20,%esp
  800fef:	85 c0                	test   %eax,%eax
  800ff1:	0f 89 a9 00 00 00    	jns    8010a0 <fork+0x18e>
  800ff7:	50                   	push   %eax
  800ff8:	68 bc 2d 80 00       	push   $0x802dbc
  800ffd:	6a 54                	push   $0x54
  800fff:	68 70 2e 80 00       	push   $0x802e70
  801004:	e8 e7 f1 ff ff       	call   8001f0 <_panic>
    } else
	if ((uvpt[pn] & PTE_W) || (uvpt[pn] & PTE_COW)) {
  801009:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801010:	f6 c2 02             	test   $0x2,%dl
  801013:	75 0c                	jne    801021 <fork+0x10f>
  801015:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80101c:	f6 c4 08             	test   $0x8,%ah
  80101f:	74 57                	je     801078 <fork+0x166>
		// cow
		r = sys_page_map(0, addr, envid, addr, PTE_COW | PTE_P | PTE_U);
  801021:	83 ec 0c             	sub    $0xc,%esp
  801024:	68 05 08 00 00       	push   $0x805
  801029:	56                   	push   %esi
  80102a:	57                   	push   %edi
  80102b:	56                   	push   %esi
  80102c:	6a 00                	push   $0x0
  80102e:	e8 f1 fc ff ff       	call   800d24 <sys_page_map>
		if (r < 0) panic("duppage sys_page_map error : %e\n", r);
  801033:	83 c4 20             	add    $0x20,%esp
  801036:	85 c0                	test   %eax,%eax
  801038:	79 12                	jns    80104c <fork+0x13a>
  80103a:	50                   	push   %eax
  80103b:	68 bc 2d 80 00       	push   $0x802dbc
  801040:	6a 59                	push   $0x59
  801042:	68 70 2e 80 00       	push   $0x802e70
  801047:	e8 a4 f1 ff ff       	call   8001f0 <_panic>
		
		r = sys_page_map(0, addr, 0, addr, PTE_COW | PTE_P | PTE_U);
  80104c:	83 ec 0c             	sub    $0xc,%esp
  80104f:	68 05 08 00 00       	push   $0x805
  801054:	56                   	push   %esi
  801055:	6a 00                	push   $0x0
  801057:	56                   	push   %esi
  801058:	6a 00                	push   $0x0
  80105a:	e8 c5 fc ff ff       	call   800d24 <sys_page_map>
		if (r < 0) panic("duppage sys_page_map error : %e\n", r);
  80105f:	83 c4 20             	add    $0x20,%esp
  801062:	85 c0                	test   %eax,%eax
  801064:	79 3a                	jns    8010a0 <fork+0x18e>
  801066:	50                   	push   %eax
  801067:	68 bc 2d 80 00       	push   $0x802dbc
  80106c:	6a 5c                	push   $0x5c
  80106e:	68 70 2e 80 00       	push   $0x802e70
  801073:	e8 78 f1 ff ff       	call   8001f0 <_panic>
	} else {
		// read only
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U);
  801078:	83 ec 0c             	sub    $0xc,%esp
  80107b:	6a 05                	push   $0x5
  80107d:	56                   	push   %esi
  80107e:	57                   	push   %edi
  80107f:	56                   	push   %esi
  801080:	6a 00                	push   $0x0
  801082:	e8 9d fc ff ff       	call   800d24 <sys_page_map>
		if (r < 0) panic("duppage sys_page_map error : %e\n", r);
  801087:	83 c4 20             	add    $0x20,%esp
  80108a:	85 c0                	test   %eax,%eax
  80108c:	79 12                	jns    8010a0 <fork+0x18e>
  80108e:	50                   	push   %eax
  80108f:	68 bc 2d 80 00       	push   $0x802dbc
  801094:	6a 60                	push   $0x60
  801096:	68 70 2e 80 00       	push   $0x802e70
  80109b:	e8 50 f1 ff ff       	call   8001f0 <_panic>
		return 0;
	} else {
		// map page to new environment
		// kernel page is already in new environment
		uint32_t i;
		for (i = 0; i != UTOP; i += PGSIZE) 
  8010a0:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  8010a6:	81 fb 00 00 c0 ee    	cmp    $0xeec00000,%ebx
  8010ac:	0f 85 ca fe ff ff    	jne    800f7c <fork+0x6a>
		if ((uvpd[PDX(i)] & PTE_P) && (uvpt[i / PGSIZE] & PTE_P) && (uvpt[i / PGSIZE] & PTE_U)) {
			duppage(childpid, i / PGSIZE);
		}

		// allocate exception stack
		r = sys_page_alloc(childpid, (void *)(UXSTACKTOP - PGSIZE), PTE_U | PTE_W | PTE_P);
  8010b2:	83 ec 04             	sub    $0x4,%esp
  8010b5:	6a 07                	push   $0x7
  8010b7:	68 00 f0 bf ee       	push   $0xeebff000
  8010bc:	ff 75 e4             	pushl  -0x1c(%ebp)
  8010bf:	e8 3c fc ff ff       	call   800d00 <sys_page_alloc>
		if (r < 0) panic("fork, sys_page_alloc user exception stack error : %e\n", r);
  8010c4:	83 c4 10             	add    $0x10,%esp
  8010c7:	85 c0                	test   %eax,%eax
  8010c9:	79 15                	jns    8010e0 <fork+0x1ce>
  8010cb:	50                   	push   %eax
  8010cc:	68 e0 2d 80 00       	push   $0x802de0
  8010d1:	68 94 00 00 00       	push   $0x94
  8010d6:	68 70 2e 80 00       	push   $0x802e70
  8010db:	e8 10 f1 ff ff       	call   8001f0 <_panic>

		// set user environment user page fault handler 
		extern void _pgfault_upcall(void);
		r = sys_env_set_pgfault_upcall(childpid, _pgfault_upcall);
  8010e0:	83 ec 08             	sub    $0x8,%esp
  8010e3:	68 3c 25 80 00       	push   $0x80253c
  8010e8:	ff 75 e4             	pushl  -0x1c(%ebp)
  8010eb:	e8 c3 fc ff ff       	call   800db3 <sys_env_set_pgfault_upcall>
		if (r < 0) panic("fork, set pgfault upcall fail : %e\n", r);
  8010f0:	83 c4 10             	add    $0x10,%esp
  8010f3:	85 c0                	test   %eax,%eax
  8010f5:	79 15                	jns    80110c <fork+0x1fa>
  8010f7:	50                   	push   %eax
  8010f8:	68 18 2e 80 00       	push   $0x802e18
  8010fd:	68 99 00 00 00       	push   $0x99
  801102:	68 70 2e 80 00       	push   $0x802e70
  801107:	e8 e4 f0 ff ff       	call   8001f0 <_panic>
		r = sys_set_priority(childpid, num);
		if (r < 0) panic("fork, set priority error\n");
		*/

		// mark the child as runnable and return
		r = sys_env_set_status(childpid, ENV_RUNNABLE);
  80110c:	83 ec 08             	sub    $0x8,%esp
  80110f:	6a 02                	push   $0x2
  801111:	ff 75 e4             	pushl  -0x1c(%ebp)
  801114:	e8 54 fc ff ff       	call   800d6d <sys_env_set_status>
		if (r < 0) panic("fork, set child process to ENV_RUNNABLE error : %e\n", r);
  801119:	83 c4 10             	add    $0x10,%esp
  80111c:	85 c0                	test   %eax,%eax
  80111e:	79 15                	jns    801135 <fork+0x223>
  801120:	50                   	push   %eax
  801121:	68 3c 2e 80 00       	push   $0x802e3c
  801126:	68 a4 00 00 00       	push   $0xa4
  80112b:	68 70 2e 80 00       	push   $0x802e70
  801130:	e8 bb f0 ff ff       	call   8001f0 <_panic>
		// cprintf("fork father ok!")
		return childpid;
	}

	panic("fork not implemented");
}
  801135:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801138:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80113b:	5b                   	pop    %ebx
  80113c:	5e                   	pop    %esi
  80113d:	5f                   	pop    %edi
  80113e:	c9                   	leave  
  80113f:	c3                   	ret    

00801140 <sfork>:

// Challenge!
int
sfork(void)
{
  801140:	55                   	push   %ebp
  801141:	89 e5                	mov    %esp,%ebp
  801143:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  801146:	68 98 2e 80 00       	push   $0x802e98
  80114b:	68 b1 00 00 00       	push   $0xb1
  801150:	68 70 2e 80 00       	push   $0x802e70
  801155:	e8 96 f0 ff ff       	call   8001f0 <_panic>
	...

0080115c <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  80115c:	55                   	push   %ebp
  80115d:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80115f:	8b 45 08             	mov    0x8(%ebp),%eax
  801162:	05 00 00 00 30       	add    $0x30000000,%eax
  801167:	c1 e8 0c             	shr    $0xc,%eax
}
  80116a:	c9                   	leave  
  80116b:	c3                   	ret    

0080116c <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80116c:	55                   	push   %ebp
  80116d:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  80116f:	ff 75 08             	pushl  0x8(%ebp)
  801172:	e8 e5 ff ff ff       	call   80115c <fd2num>
  801177:	83 c4 04             	add    $0x4,%esp
  80117a:	05 20 00 0d 00       	add    $0xd0020,%eax
  80117f:	c1 e0 0c             	shl    $0xc,%eax
}
  801182:	c9                   	leave  
  801183:	c3                   	ret    

00801184 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801184:	55                   	push   %ebp
  801185:	89 e5                	mov    %esp,%ebp
  801187:	53                   	push   %ebx
  801188:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80118b:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  801190:	a8 01                	test   $0x1,%al
  801192:	74 34                	je     8011c8 <fd_alloc+0x44>
  801194:	a1 00 00 74 ef       	mov    0xef740000,%eax
  801199:	a8 01                	test   $0x1,%al
  80119b:	74 32                	je     8011cf <fd_alloc+0x4b>
  80119d:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
  8011a2:	89 c1                	mov    %eax,%ecx
  8011a4:	89 c2                	mov    %eax,%edx
  8011a6:	c1 ea 16             	shr    $0x16,%edx
  8011a9:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8011b0:	f6 c2 01             	test   $0x1,%dl
  8011b3:	74 1f                	je     8011d4 <fd_alloc+0x50>
  8011b5:	89 c2                	mov    %eax,%edx
  8011b7:	c1 ea 0c             	shr    $0xc,%edx
  8011ba:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8011c1:	f6 c2 01             	test   $0x1,%dl
  8011c4:	75 17                	jne    8011dd <fd_alloc+0x59>
  8011c6:	eb 0c                	jmp    8011d4 <fd_alloc+0x50>
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  8011c8:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
  8011cd:	eb 05                	jmp    8011d4 <fd_alloc+0x50>
  8011cf:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
  8011d4:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  8011d6:	b8 00 00 00 00       	mov    $0x0,%eax
  8011db:	eb 17                	jmp    8011f4 <fd_alloc+0x70>
  8011dd:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8011e2:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8011e7:	75 b9                	jne    8011a2 <fd_alloc+0x1e>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8011e9:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  8011ef:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8011f4:	5b                   	pop    %ebx
  8011f5:	c9                   	leave  
  8011f6:	c3                   	ret    

008011f7 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8011f7:	55                   	push   %ebp
  8011f8:	89 e5                	mov    %esp,%ebp
  8011fa:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8011fd:	83 f8 1f             	cmp    $0x1f,%eax
  801200:	77 36                	ja     801238 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801202:	05 00 00 0d 00       	add    $0xd0000,%eax
  801207:	c1 e0 0c             	shl    $0xc,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80120a:	89 c2                	mov    %eax,%edx
  80120c:	c1 ea 16             	shr    $0x16,%edx
  80120f:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801216:	f6 c2 01             	test   $0x1,%dl
  801219:	74 24                	je     80123f <fd_lookup+0x48>
  80121b:	89 c2                	mov    %eax,%edx
  80121d:	c1 ea 0c             	shr    $0xc,%edx
  801220:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801227:	f6 c2 01             	test   $0x1,%dl
  80122a:	74 1a                	je     801246 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80122c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80122f:	89 02                	mov    %eax,(%edx)
	return 0;
  801231:	b8 00 00 00 00       	mov    $0x0,%eax
  801236:	eb 13                	jmp    80124b <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801238:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80123d:	eb 0c                	jmp    80124b <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80123f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801244:	eb 05                	jmp    80124b <fd_lookup+0x54>
  801246:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  80124b:	c9                   	leave  
  80124c:	c3                   	ret    

0080124d <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80124d:	55                   	push   %ebp
  80124e:	89 e5                	mov    %esp,%ebp
  801250:	53                   	push   %ebx
  801251:	83 ec 04             	sub    $0x4,%esp
  801254:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801257:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  80125a:	39 0d 0c 40 80 00    	cmp    %ecx,0x80400c
  801260:	74 0d                	je     80126f <dev_lookup+0x22>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801262:	b8 00 00 00 00       	mov    $0x0,%eax
  801267:	eb 14                	jmp    80127d <dev_lookup+0x30>
		if (devtab[i]->dev_id == dev_id) {
  801269:	39 0a                	cmp    %ecx,(%edx)
  80126b:	75 10                	jne    80127d <dev_lookup+0x30>
  80126d:	eb 05                	jmp    801274 <dev_lookup+0x27>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80126f:	ba 0c 40 80 00       	mov    $0x80400c,%edx
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
  801274:	89 13                	mov    %edx,(%ebx)
			return 0;
  801276:	b8 00 00 00 00       	mov    $0x0,%eax
  80127b:	eb 31                	jmp    8012ae <dev_lookup+0x61>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80127d:	40                   	inc    %eax
  80127e:	8b 14 85 2c 2f 80 00 	mov    0x802f2c(,%eax,4),%edx
  801285:	85 d2                	test   %edx,%edx
  801287:	75 e0                	jne    801269 <dev_lookup+0x1c>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801289:	a1 04 50 80 00       	mov    0x805004,%eax
  80128e:	8b 40 48             	mov    0x48(%eax),%eax
  801291:	83 ec 04             	sub    $0x4,%esp
  801294:	51                   	push   %ecx
  801295:	50                   	push   %eax
  801296:	68 b0 2e 80 00       	push   $0x802eb0
  80129b:	e8 28 f0 ff ff       	call   8002c8 <cprintf>
	*dev = 0;
  8012a0:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  8012a6:	83 c4 10             	add    $0x10,%esp
  8012a9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8012ae:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012b1:	c9                   	leave  
  8012b2:	c3                   	ret    

008012b3 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8012b3:	55                   	push   %ebp
  8012b4:	89 e5                	mov    %esp,%ebp
  8012b6:	56                   	push   %esi
  8012b7:	53                   	push   %ebx
  8012b8:	83 ec 20             	sub    $0x20,%esp
  8012bb:	8b 75 08             	mov    0x8(%ebp),%esi
  8012be:	8a 45 0c             	mov    0xc(%ebp),%al
  8012c1:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8012c4:	56                   	push   %esi
  8012c5:	e8 92 fe ff ff       	call   80115c <fd2num>
  8012ca:	8d 55 f4             	lea    -0xc(%ebp),%edx
  8012cd:	89 14 24             	mov    %edx,(%esp)
  8012d0:	50                   	push   %eax
  8012d1:	e8 21 ff ff ff       	call   8011f7 <fd_lookup>
  8012d6:	89 c3                	mov    %eax,%ebx
  8012d8:	83 c4 08             	add    $0x8,%esp
  8012db:	85 c0                	test   %eax,%eax
  8012dd:	78 05                	js     8012e4 <fd_close+0x31>
	    || fd != fd2)
  8012df:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8012e2:	74 0d                	je     8012f1 <fd_close+0x3e>
		return (must_exist ? r : 0);
  8012e4:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  8012e8:	75 48                	jne    801332 <fd_close+0x7f>
  8012ea:	bb 00 00 00 00       	mov    $0x0,%ebx
  8012ef:	eb 41                	jmp    801332 <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8012f1:	83 ec 08             	sub    $0x8,%esp
  8012f4:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012f7:	50                   	push   %eax
  8012f8:	ff 36                	pushl  (%esi)
  8012fa:	e8 4e ff ff ff       	call   80124d <dev_lookup>
  8012ff:	89 c3                	mov    %eax,%ebx
  801301:	83 c4 10             	add    $0x10,%esp
  801304:	85 c0                	test   %eax,%eax
  801306:	78 1c                	js     801324 <fd_close+0x71>
		if (dev->dev_close)
  801308:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80130b:	8b 40 10             	mov    0x10(%eax),%eax
  80130e:	85 c0                	test   %eax,%eax
  801310:	74 0d                	je     80131f <fd_close+0x6c>
			r = (*dev->dev_close)(fd);
  801312:	83 ec 0c             	sub    $0xc,%esp
  801315:	56                   	push   %esi
  801316:	ff d0                	call   *%eax
  801318:	89 c3                	mov    %eax,%ebx
  80131a:	83 c4 10             	add    $0x10,%esp
  80131d:	eb 05                	jmp    801324 <fd_close+0x71>
		else
			r = 0;
  80131f:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801324:	83 ec 08             	sub    $0x8,%esp
  801327:	56                   	push   %esi
  801328:	6a 00                	push   $0x0
  80132a:	e8 1b fa ff ff       	call   800d4a <sys_page_unmap>
	return r;
  80132f:	83 c4 10             	add    $0x10,%esp
}
  801332:	89 d8                	mov    %ebx,%eax
  801334:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801337:	5b                   	pop    %ebx
  801338:	5e                   	pop    %esi
  801339:	c9                   	leave  
  80133a:	c3                   	ret    

0080133b <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80133b:	55                   	push   %ebp
  80133c:	89 e5                	mov    %esp,%ebp
  80133e:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801341:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801344:	50                   	push   %eax
  801345:	ff 75 08             	pushl  0x8(%ebp)
  801348:	e8 aa fe ff ff       	call   8011f7 <fd_lookup>
  80134d:	83 c4 08             	add    $0x8,%esp
  801350:	85 c0                	test   %eax,%eax
  801352:	78 10                	js     801364 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801354:	83 ec 08             	sub    $0x8,%esp
  801357:	6a 01                	push   $0x1
  801359:	ff 75 f4             	pushl  -0xc(%ebp)
  80135c:	e8 52 ff ff ff       	call   8012b3 <fd_close>
  801361:	83 c4 10             	add    $0x10,%esp
}
  801364:	c9                   	leave  
  801365:	c3                   	ret    

00801366 <close_all>:

void
close_all(void)
{
  801366:	55                   	push   %ebp
  801367:	89 e5                	mov    %esp,%ebp
  801369:	53                   	push   %ebx
  80136a:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80136d:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801372:	83 ec 0c             	sub    $0xc,%esp
  801375:	53                   	push   %ebx
  801376:	e8 c0 ff ff ff       	call   80133b <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80137b:	43                   	inc    %ebx
  80137c:	83 c4 10             	add    $0x10,%esp
  80137f:	83 fb 20             	cmp    $0x20,%ebx
  801382:	75 ee                	jne    801372 <close_all+0xc>
		close(i);
}
  801384:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801387:	c9                   	leave  
  801388:	c3                   	ret    

00801389 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801389:	55                   	push   %ebp
  80138a:	89 e5                	mov    %esp,%ebp
  80138c:	57                   	push   %edi
  80138d:	56                   	push   %esi
  80138e:	53                   	push   %ebx
  80138f:	83 ec 2c             	sub    $0x2c,%esp
  801392:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801395:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801398:	50                   	push   %eax
  801399:	ff 75 08             	pushl  0x8(%ebp)
  80139c:	e8 56 fe ff ff       	call   8011f7 <fd_lookup>
  8013a1:	89 c3                	mov    %eax,%ebx
  8013a3:	83 c4 08             	add    $0x8,%esp
  8013a6:	85 c0                	test   %eax,%eax
  8013a8:	0f 88 c0 00 00 00    	js     80146e <dup+0xe5>
		return r;
	close(newfdnum);
  8013ae:	83 ec 0c             	sub    $0xc,%esp
  8013b1:	57                   	push   %edi
  8013b2:	e8 84 ff ff ff       	call   80133b <close>

	newfd = INDEX2FD(newfdnum);
  8013b7:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  8013bd:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  8013c0:	83 c4 04             	add    $0x4,%esp
  8013c3:	ff 75 e4             	pushl  -0x1c(%ebp)
  8013c6:	e8 a1 fd ff ff       	call   80116c <fd2data>
  8013cb:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  8013cd:	89 34 24             	mov    %esi,(%esp)
  8013d0:	e8 97 fd ff ff       	call   80116c <fd2data>
  8013d5:	83 c4 10             	add    $0x10,%esp
  8013d8:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8013db:	89 d8                	mov    %ebx,%eax
  8013dd:	c1 e8 16             	shr    $0x16,%eax
  8013e0:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8013e7:	a8 01                	test   $0x1,%al
  8013e9:	74 37                	je     801422 <dup+0x99>
  8013eb:	89 d8                	mov    %ebx,%eax
  8013ed:	c1 e8 0c             	shr    $0xc,%eax
  8013f0:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8013f7:	f6 c2 01             	test   $0x1,%dl
  8013fa:	74 26                	je     801422 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8013fc:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801403:	83 ec 0c             	sub    $0xc,%esp
  801406:	25 07 0e 00 00       	and    $0xe07,%eax
  80140b:	50                   	push   %eax
  80140c:	ff 75 d4             	pushl  -0x2c(%ebp)
  80140f:	6a 00                	push   $0x0
  801411:	53                   	push   %ebx
  801412:	6a 00                	push   $0x0
  801414:	e8 0b f9 ff ff       	call   800d24 <sys_page_map>
  801419:	89 c3                	mov    %eax,%ebx
  80141b:	83 c4 20             	add    $0x20,%esp
  80141e:	85 c0                	test   %eax,%eax
  801420:	78 2d                	js     80144f <dup+0xc6>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801422:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801425:	89 c2                	mov    %eax,%edx
  801427:	c1 ea 0c             	shr    $0xc,%edx
  80142a:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801431:	83 ec 0c             	sub    $0xc,%esp
  801434:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  80143a:	52                   	push   %edx
  80143b:	56                   	push   %esi
  80143c:	6a 00                	push   $0x0
  80143e:	50                   	push   %eax
  80143f:	6a 00                	push   $0x0
  801441:	e8 de f8 ff ff       	call   800d24 <sys_page_map>
  801446:	89 c3                	mov    %eax,%ebx
  801448:	83 c4 20             	add    $0x20,%esp
  80144b:	85 c0                	test   %eax,%eax
  80144d:	79 1d                	jns    80146c <dup+0xe3>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80144f:	83 ec 08             	sub    $0x8,%esp
  801452:	56                   	push   %esi
  801453:	6a 00                	push   $0x0
  801455:	e8 f0 f8 ff ff       	call   800d4a <sys_page_unmap>
	sys_page_unmap(0, nva);
  80145a:	83 c4 08             	add    $0x8,%esp
  80145d:	ff 75 d4             	pushl  -0x2c(%ebp)
  801460:	6a 00                	push   $0x0
  801462:	e8 e3 f8 ff ff       	call   800d4a <sys_page_unmap>
	return r;
  801467:	83 c4 10             	add    $0x10,%esp
  80146a:	eb 02                	jmp    80146e <dup+0xe5>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  80146c:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  80146e:	89 d8                	mov    %ebx,%eax
  801470:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801473:	5b                   	pop    %ebx
  801474:	5e                   	pop    %esi
  801475:	5f                   	pop    %edi
  801476:	c9                   	leave  
  801477:	c3                   	ret    

00801478 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801478:	55                   	push   %ebp
  801479:	89 e5                	mov    %esp,%ebp
  80147b:	53                   	push   %ebx
  80147c:	83 ec 14             	sub    $0x14,%esp
  80147f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801482:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801485:	50                   	push   %eax
  801486:	53                   	push   %ebx
  801487:	e8 6b fd ff ff       	call   8011f7 <fd_lookup>
  80148c:	83 c4 08             	add    $0x8,%esp
  80148f:	85 c0                	test   %eax,%eax
  801491:	78 67                	js     8014fa <read+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801493:	83 ec 08             	sub    $0x8,%esp
  801496:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801499:	50                   	push   %eax
  80149a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80149d:	ff 30                	pushl  (%eax)
  80149f:	e8 a9 fd ff ff       	call   80124d <dev_lookup>
  8014a4:	83 c4 10             	add    $0x10,%esp
  8014a7:	85 c0                	test   %eax,%eax
  8014a9:	78 4f                	js     8014fa <read+0x82>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8014ab:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014ae:	8b 50 08             	mov    0x8(%eax),%edx
  8014b1:	83 e2 03             	and    $0x3,%edx
  8014b4:	83 fa 01             	cmp    $0x1,%edx
  8014b7:	75 21                	jne    8014da <read+0x62>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8014b9:	a1 04 50 80 00       	mov    0x805004,%eax
  8014be:	8b 40 48             	mov    0x48(%eax),%eax
  8014c1:	83 ec 04             	sub    $0x4,%esp
  8014c4:	53                   	push   %ebx
  8014c5:	50                   	push   %eax
  8014c6:	68 f1 2e 80 00       	push   $0x802ef1
  8014cb:	e8 f8 ed ff ff       	call   8002c8 <cprintf>
		return -E_INVAL;
  8014d0:	83 c4 10             	add    $0x10,%esp
  8014d3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8014d8:	eb 20                	jmp    8014fa <read+0x82>
	}
	if (!dev->dev_read)
  8014da:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8014dd:	8b 52 08             	mov    0x8(%edx),%edx
  8014e0:	85 d2                	test   %edx,%edx
  8014e2:	74 11                	je     8014f5 <read+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8014e4:	83 ec 04             	sub    $0x4,%esp
  8014e7:	ff 75 10             	pushl  0x10(%ebp)
  8014ea:	ff 75 0c             	pushl  0xc(%ebp)
  8014ed:	50                   	push   %eax
  8014ee:	ff d2                	call   *%edx
  8014f0:	83 c4 10             	add    $0x10,%esp
  8014f3:	eb 05                	jmp    8014fa <read+0x82>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8014f5:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  8014fa:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014fd:	c9                   	leave  
  8014fe:	c3                   	ret    

008014ff <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8014ff:	55                   	push   %ebp
  801500:	89 e5                	mov    %esp,%ebp
  801502:	57                   	push   %edi
  801503:	56                   	push   %esi
  801504:	53                   	push   %ebx
  801505:	83 ec 0c             	sub    $0xc,%esp
  801508:	8b 7d 08             	mov    0x8(%ebp),%edi
  80150b:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80150e:	85 f6                	test   %esi,%esi
  801510:	74 31                	je     801543 <readn+0x44>
  801512:	b8 00 00 00 00       	mov    $0x0,%eax
  801517:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = read(fdnum, (char*)buf + tot, n - tot);
  80151c:	83 ec 04             	sub    $0x4,%esp
  80151f:	89 f2                	mov    %esi,%edx
  801521:	29 c2                	sub    %eax,%edx
  801523:	52                   	push   %edx
  801524:	03 45 0c             	add    0xc(%ebp),%eax
  801527:	50                   	push   %eax
  801528:	57                   	push   %edi
  801529:	e8 4a ff ff ff       	call   801478 <read>
		if (m < 0)
  80152e:	83 c4 10             	add    $0x10,%esp
  801531:	85 c0                	test   %eax,%eax
  801533:	78 17                	js     80154c <readn+0x4d>
			return m;
		if (m == 0)
  801535:	85 c0                	test   %eax,%eax
  801537:	74 11                	je     80154a <readn+0x4b>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801539:	01 c3                	add    %eax,%ebx
  80153b:	89 d8                	mov    %ebx,%eax
  80153d:	39 f3                	cmp    %esi,%ebx
  80153f:	72 db                	jb     80151c <readn+0x1d>
  801541:	eb 09                	jmp    80154c <readn+0x4d>
  801543:	b8 00 00 00 00       	mov    $0x0,%eax
  801548:	eb 02                	jmp    80154c <readn+0x4d>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  80154a:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  80154c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80154f:	5b                   	pop    %ebx
  801550:	5e                   	pop    %esi
  801551:	5f                   	pop    %edi
  801552:	c9                   	leave  
  801553:	c3                   	ret    

00801554 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801554:	55                   	push   %ebp
  801555:	89 e5                	mov    %esp,%ebp
  801557:	53                   	push   %ebx
  801558:	83 ec 14             	sub    $0x14,%esp
  80155b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80155e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801561:	50                   	push   %eax
  801562:	53                   	push   %ebx
  801563:	e8 8f fc ff ff       	call   8011f7 <fd_lookup>
  801568:	83 c4 08             	add    $0x8,%esp
  80156b:	85 c0                	test   %eax,%eax
  80156d:	78 62                	js     8015d1 <write+0x7d>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80156f:	83 ec 08             	sub    $0x8,%esp
  801572:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801575:	50                   	push   %eax
  801576:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801579:	ff 30                	pushl  (%eax)
  80157b:	e8 cd fc ff ff       	call   80124d <dev_lookup>
  801580:	83 c4 10             	add    $0x10,%esp
  801583:	85 c0                	test   %eax,%eax
  801585:	78 4a                	js     8015d1 <write+0x7d>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801587:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80158a:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80158e:	75 21                	jne    8015b1 <write+0x5d>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801590:	a1 04 50 80 00       	mov    0x805004,%eax
  801595:	8b 40 48             	mov    0x48(%eax),%eax
  801598:	83 ec 04             	sub    $0x4,%esp
  80159b:	53                   	push   %ebx
  80159c:	50                   	push   %eax
  80159d:	68 0d 2f 80 00       	push   $0x802f0d
  8015a2:	e8 21 ed ff ff       	call   8002c8 <cprintf>
		return -E_INVAL;
  8015a7:	83 c4 10             	add    $0x10,%esp
  8015aa:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8015af:	eb 20                	jmp    8015d1 <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8015b1:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8015b4:	8b 52 0c             	mov    0xc(%edx),%edx
  8015b7:	85 d2                	test   %edx,%edx
  8015b9:	74 11                	je     8015cc <write+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8015bb:	83 ec 04             	sub    $0x4,%esp
  8015be:	ff 75 10             	pushl  0x10(%ebp)
  8015c1:	ff 75 0c             	pushl  0xc(%ebp)
  8015c4:	50                   	push   %eax
  8015c5:	ff d2                	call   *%edx
  8015c7:	83 c4 10             	add    $0x10,%esp
  8015ca:	eb 05                	jmp    8015d1 <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8015cc:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  8015d1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015d4:	c9                   	leave  
  8015d5:	c3                   	ret    

008015d6 <seek>:

int
seek(int fdnum, off_t offset)
{
  8015d6:	55                   	push   %ebp
  8015d7:	89 e5                	mov    %esp,%ebp
  8015d9:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8015dc:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8015df:	50                   	push   %eax
  8015e0:	ff 75 08             	pushl  0x8(%ebp)
  8015e3:	e8 0f fc ff ff       	call   8011f7 <fd_lookup>
  8015e8:	83 c4 08             	add    $0x8,%esp
  8015eb:	85 c0                	test   %eax,%eax
  8015ed:	78 0e                	js     8015fd <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8015ef:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8015f2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8015f5:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8015f8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8015fd:	c9                   	leave  
  8015fe:	c3                   	ret    

008015ff <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8015ff:	55                   	push   %ebp
  801600:	89 e5                	mov    %esp,%ebp
  801602:	53                   	push   %ebx
  801603:	83 ec 14             	sub    $0x14,%esp
  801606:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801609:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80160c:	50                   	push   %eax
  80160d:	53                   	push   %ebx
  80160e:	e8 e4 fb ff ff       	call   8011f7 <fd_lookup>
  801613:	83 c4 08             	add    $0x8,%esp
  801616:	85 c0                	test   %eax,%eax
  801618:	78 5f                	js     801679 <ftruncate+0x7a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80161a:	83 ec 08             	sub    $0x8,%esp
  80161d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801620:	50                   	push   %eax
  801621:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801624:	ff 30                	pushl  (%eax)
  801626:	e8 22 fc ff ff       	call   80124d <dev_lookup>
  80162b:	83 c4 10             	add    $0x10,%esp
  80162e:	85 c0                	test   %eax,%eax
  801630:	78 47                	js     801679 <ftruncate+0x7a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801632:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801635:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801639:	75 21                	jne    80165c <ftruncate+0x5d>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80163b:	a1 04 50 80 00       	mov    0x805004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801640:	8b 40 48             	mov    0x48(%eax),%eax
  801643:	83 ec 04             	sub    $0x4,%esp
  801646:	53                   	push   %ebx
  801647:	50                   	push   %eax
  801648:	68 d0 2e 80 00       	push   $0x802ed0
  80164d:	e8 76 ec ff ff       	call   8002c8 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801652:	83 c4 10             	add    $0x10,%esp
  801655:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80165a:	eb 1d                	jmp    801679 <ftruncate+0x7a>
	}
	if (!dev->dev_trunc)
  80165c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80165f:	8b 52 18             	mov    0x18(%edx),%edx
  801662:	85 d2                	test   %edx,%edx
  801664:	74 0e                	je     801674 <ftruncate+0x75>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801666:	83 ec 08             	sub    $0x8,%esp
  801669:	ff 75 0c             	pushl  0xc(%ebp)
  80166c:	50                   	push   %eax
  80166d:	ff d2                	call   *%edx
  80166f:	83 c4 10             	add    $0x10,%esp
  801672:	eb 05                	jmp    801679 <ftruncate+0x7a>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801674:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  801679:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80167c:	c9                   	leave  
  80167d:	c3                   	ret    

0080167e <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80167e:	55                   	push   %ebp
  80167f:	89 e5                	mov    %esp,%ebp
  801681:	53                   	push   %ebx
  801682:	83 ec 14             	sub    $0x14,%esp
  801685:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801688:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80168b:	50                   	push   %eax
  80168c:	ff 75 08             	pushl  0x8(%ebp)
  80168f:	e8 63 fb ff ff       	call   8011f7 <fd_lookup>
  801694:	83 c4 08             	add    $0x8,%esp
  801697:	85 c0                	test   %eax,%eax
  801699:	78 52                	js     8016ed <fstat+0x6f>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80169b:	83 ec 08             	sub    $0x8,%esp
  80169e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016a1:	50                   	push   %eax
  8016a2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016a5:	ff 30                	pushl  (%eax)
  8016a7:	e8 a1 fb ff ff       	call   80124d <dev_lookup>
  8016ac:	83 c4 10             	add    $0x10,%esp
  8016af:	85 c0                	test   %eax,%eax
  8016b1:	78 3a                	js     8016ed <fstat+0x6f>
		return r;
	if (!dev->dev_stat)
  8016b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016b6:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8016ba:	74 2c                	je     8016e8 <fstat+0x6a>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8016bc:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8016bf:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8016c6:	00 00 00 
	stat->st_isdir = 0;
  8016c9:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8016d0:	00 00 00 
	stat->st_dev = dev;
  8016d3:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8016d9:	83 ec 08             	sub    $0x8,%esp
  8016dc:	53                   	push   %ebx
  8016dd:	ff 75 f0             	pushl  -0x10(%ebp)
  8016e0:	ff 50 14             	call   *0x14(%eax)
  8016e3:	83 c4 10             	add    $0x10,%esp
  8016e6:	eb 05                	jmp    8016ed <fstat+0x6f>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8016e8:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8016ed:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016f0:	c9                   	leave  
  8016f1:	c3                   	ret    

008016f2 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8016f2:	55                   	push   %ebp
  8016f3:	89 e5                	mov    %esp,%ebp
  8016f5:	56                   	push   %esi
  8016f6:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8016f7:	83 ec 08             	sub    $0x8,%esp
  8016fa:	6a 00                	push   $0x0
  8016fc:	ff 75 08             	pushl  0x8(%ebp)
  8016ff:	e8 78 01 00 00       	call   80187c <open>
  801704:	89 c3                	mov    %eax,%ebx
  801706:	83 c4 10             	add    $0x10,%esp
  801709:	85 c0                	test   %eax,%eax
  80170b:	78 1b                	js     801728 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  80170d:	83 ec 08             	sub    $0x8,%esp
  801710:	ff 75 0c             	pushl  0xc(%ebp)
  801713:	50                   	push   %eax
  801714:	e8 65 ff ff ff       	call   80167e <fstat>
  801719:	89 c6                	mov    %eax,%esi
	close(fd);
  80171b:	89 1c 24             	mov    %ebx,(%esp)
  80171e:	e8 18 fc ff ff       	call   80133b <close>
	return r;
  801723:	83 c4 10             	add    $0x10,%esp
  801726:	89 f3                	mov    %esi,%ebx
}
  801728:	89 d8                	mov    %ebx,%eax
  80172a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80172d:	5b                   	pop    %ebx
  80172e:	5e                   	pop    %esi
  80172f:	c9                   	leave  
  801730:	c3                   	ret    
  801731:	00 00                	add    %al,(%eax)
	...

00801734 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801734:	55                   	push   %ebp
  801735:	89 e5                	mov    %esp,%ebp
  801737:	56                   	push   %esi
  801738:	53                   	push   %ebx
  801739:	89 c3                	mov    %eax,%ebx
  80173b:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  80173d:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  801744:	75 12                	jne    801758 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801746:	83 ec 0c             	sub    $0xc,%esp
  801749:	6a 01                	push   $0x1
  80174b:	e8 de 0e 00 00       	call   80262e <ipc_find_env>
  801750:	a3 00 50 80 00       	mov    %eax,0x805000
  801755:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801758:	6a 07                	push   $0x7
  80175a:	68 00 60 80 00       	push   $0x806000
  80175f:	53                   	push   %ebx
  801760:	ff 35 00 50 80 00    	pushl  0x805000
  801766:	e8 6e 0e 00 00       	call   8025d9 <ipc_send>
	
	return ipc_recv(NULL, dstva, NULL);
  80176b:	83 c4 0c             	add    $0xc,%esp
  80176e:	6a 00                	push   $0x0
  801770:	56                   	push   %esi
  801771:	6a 00                	push   $0x0
  801773:	e8 ec 0d 00 00       	call   802564 <ipc_recv>
}
  801778:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80177b:	5b                   	pop    %ebx
  80177c:	5e                   	pop    %esi
  80177d:	c9                   	leave  
  80177e:	c3                   	ret    

0080177f <devfile_stat>:
}


static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80177f:	55                   	push   %ebp
  801780:	89 e5                	mov    %esp,%ebp
  801782:	53                   	push   %ebx
  801783:	83 ec 04             	sub    $0x4,%esp
  801786:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801789:	8b 45 08             	mov    0x8(%ebp),%eax
  80178c:	8b 40 0c             	mov    0xc(%eax),%eax
  80178f:	a3 00 60 80 00       	mov    %eax,0x806000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0) {
  801794:	ba 00 00 00 00       	mov    $0x0,%edx
  801799:	b8 05 00 00 00       	mov    $0x5,%eax
  80179e:	e8 91 ff ff ff       	call   801734 <fsipc>
  8017a3:	85 c0                	test   %eax,%eax
  8017a5:	78 2c                	js     8017d3 <devfile_stat+0x54>
		return r;
	}
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8017a7:	83 ec 08             	sub    $0x8,%esp
  8017aa:	68 00 60 80 00       	push   $0x806000
  8017af:	53                   	push   %ebx
  8017b0:	e8 c9 f0 ff ff       	call   80087e <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8017b5:	a1 80 60 80 00       	mov    0x806080,%eax
  8017ba:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8017c0:	a1 84 60 80 00       	mov    0x806084,%eax
  8017c5:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8017cb:	83 c4 10             	add    $0x10,%esp
  8017ce:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8017d3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017d6:	c9                   	leave  
  8017d7:	c3                   	ret    

008017d8 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8017d8:	55                   	push   %ebp
  8017d9:	89 e5                	mov    %esp,%ebp
  8017db:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8017de:	8b 45 08             	mov    0x8(%ebp),%eax
  8017e1:	8b 40 0c             	mov    0xc(%eax),%eax
  8017e4:	a3 00 60 80 00       	mov    %eax,0x806000
	return fsipc(FSREQ_FLUSH, NULL);
  8017e9:	ba 00 00 00 00       	mov    $0x0,%edx
  8017ee:	b8 06 00 00 00       	mov    $0x6,%eax
  8017f3:	e8 3c ff ff ff       	call   801734 <fsipc>
}
  8017f8:	c9                   	leave  
  8017f9:	c3                   	ret    

008017fa <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8017fa:	55                   	push   %ebp
  8017fb:	89 e5                	mov    %esp,%ebp
  8017fd:	56                   	push   %esi
  8017fe:	53                   	push   %ebx
  8017ff:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801802:	8b 45 08             	mov    0x8(%ebp),%eax
  801805:	8b 40 0c             	mov    0xc(%eax),%eax
  801808:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.read.req_n = n;
  80180d:	89 35 04 60 80 00    	mov    %esi,0x806004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801813:	ba 00 00 00 00       	mov    $0x0,%edx
  801818:	b8 03 00 00 00       	mov    $0x3,%eax
  80181d:	e8 12 ff ff ff       	call   801734 <fsipc>
  801822:	89 c3                	mov    %eax,%ebx
  801824:	85 c0                	test   %eax,%eax
  801826:	78 4b                	js     801873 <devfile_read+0x79>
		return r;
	assert(r <= n);
  801828:	39 c6                	cmp    %eax,%esi
  80182a:	73 16                	jae    801842 <devfile_read+0x48>
  80182c:	68 3c 2f 80 00       	push   $0x802f3c
  801831:	68 43 2f 80 00       	push   $0x802f43
  801836:	6a 7d                	push   $0x7d
  801838:	68 58 2f 80 00       	push   $0x802f58
  80183d:	e8 ae e9 ff ff       	call   8001f0 <_panic>
	assert(r <= PGSIZE);
  801842:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801847:	7e 16                	jle    80185f <devfile_read+0x65>
  801849:	68 63 2f 80 00       	push   $0x802f63
  80184e:	68 43 2f 80 00       	push   $0x802f43
  801853:	6a 7e                	push   $0x7e
  801855:	68 58 2f 80 00       	push   $0x802f58
  80185a:	e8 91 e9 ff ff       	call   8001f0 <_panic>
	memmove(buf, &fsipcbuf, r);
  80185f:	83 ec 04             	sub    $0x4,%esp
  801862:	50                   	push   %eax
  801863:	68 00 60 80 00       	push   $0x806000
  801868:	ff 75 0c             	pushl  0xc(%ebp)
  80186b:	e8 cf f1 ff ff       	call   800a3f <memmove>
	return r;
  801870:	83 c4 10             	add    $0x10,%esp
}
  801873:	89 d8                	mov    %ebx,%eax
  801875:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801878:	5b                   	pop    %ebx
  801879:	5e                   	pop    %esi
  80187a:	c9                   	leave  
  80187b:	c3                   	ret    

0080187c <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  80187c:	55                   	push   %ebp
  80187d:	89 e5                	mov    %esp,%ebp
  80187f:	56                   	push   %esi
  801880:	53                   	push   %ebx
  801881:	83 ec 1c             	sub    $0x1c,%esp
  801884:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801887:	56                   	push   %esi
  801888:	e8 9f ef ff ff       	call   80082c <strlen>
  80188d:	83 c4 10             	add    $0x10,%esp
  801890:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801895:	7f 65                	jg     8018fc <open+0x80>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801897:	83 ec 0c             	sub    $0xc,%esp
  80189a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80189d:	50                   	push   %eax
  80189e:	e8 e1 f8 ff ff       	call   801184 <fd_alloc>
  8018a3:	89 c3                	mov    %eax,%ebx
  8018a5:	83 c4 10             	add    $0x10,%esp
  8018a8:	85 c0                	test   %eax,%eax
  8018aa:	78 55                	js     801901 <open+0x85>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8018ac:	83 ec 08             	sub    $0x8,%esp
  8018af:	56                   	push   %esi
  8018b0:	68 00 60 80 00       	push   $0x806000
  8018b5:	e8 c4 ef ff ff       	call   80087e <strcpy>
	fsipcbuf.open.req_omode = mode;
  8018ba:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018bd:	a3 00 64 80 00       	mov    %eax,0x806400



	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8018c2:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8018c5:	b8 01 00 00 00       	mov    $0x1,%eax
  8018ca:	e8 65 fe ff ff       	call   801734 <fsipc>
  8018cf:	89 c3                	mov    %eax,%ebx
  8018d1:	83 c4 10             	add    $0x10,%esp
  8018d4:	85 c0                	test   %eax,%eax
  8018d6:	79 12                	jns    8018ea <open+0x6e>
		fd_close(fd, 0);
  8018d8:	83 ec 08             	sub    $0x8,%esp
  8018db:	6a 00                	push   $0x0
  8018dd:	ff 75 f4             	pushl  -0xc(%ebp)
  8018e0:	e8 ce f9 ff ff       	call   8012b3 <fd_close>
		return r;
  8018e5:	83 c4 10             	add    $0x10,%esp
  8018e8:	eb 17                	jmp    801901 <open+0x85>
	}

	return fd2num(fd);
  8018ea:	83 ec 0c             	sub    $0xc,%esp
  8018ed:	ff 75 f4             	pushl  -0xc(%ebp)
  8018f0:	e8 67 f8 ff ff       	call   80115c <fd2num>
  8018f5:	89 c3                	mov    %eax,%ebx
  8018f7:	83 c4 10             	add    $0x10,%esp
  8018fa:	eb 05                	jmp    801901 <open+0x85>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8018fc:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801901:	89 d8                	mov    %ebx,%eax
  801903:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801906:	5b                   	pop    %ebx
  801907:	5e                   	pop    %esi
  801908:	c9                   	leave  
  801909:	c3                   	ret    
	...

0080190c <spawn>:
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
{
  80190c:	55                   	push   %ebp
  80190d:	89 e5                	mov    %esp,%ebp
  80190f:	57                   	push   %edi
  801910:	56                   	push   %esi
  801911:	53                   	push   %ebx
  801912:	81 ec 94 02 00 00    	sub    $0x294,%esp
	//   - Call sys_env_set_trapframe(child, &child_tf) to set up the
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
  801918:	6a 00                	push   $0x0
  80191a:	ff 75 08             	pushl  0x8(%ebp)
  80191d:	e8 5a ff ff ff       	call   80187c <open>
  801922:	89 85 88 fd ff ff    	mov    %eax,-0x278(%ebp)
  801928:	83 c4 10             	add    $0x10,%esp
  80192b:	85 c0                	test   %eax,%eax
  80192d:	0f 88 36 05 00 00    	js     801e69 <spawn+0x55d>
		return r;
	fd = r;

	// Read elf header
	elf = (struct Elf*) elf_buf;
	if (readn(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf)
  801933:	83 ec 04             	sub    $0x4,%esp
  801936:	68 00 02 00 00       	push   $0x200
  80193b:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  801941:	50                   	push   %eax
  801942:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  801948:	e8 b2 fb ff ff       	call   8014ff <readn>
  80194d:	83 c4 10             	add    $0x10,%esp
  801950:	3d 00 02 00 00       	cmp    $0x200,%eax
  801955:	75 0c                	jne    801963 <spawn+0x57>
	    || elf->e_magic != ELF_MAGIC) {
  801957:	81 bd e8 fd ff ff 7f 	cmpl   $0x464c457f,-0x218(%ebp)
  80195e:	45 4c 46 
  801961:	74 38                	je     80199b <spawn+0x8f>
		close(fd);
  801963:	83 ec 0c             	sub    $0xc,%esp
  801966:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  80196c:	e8 ca f9 ff ff       	call   80133b <close>
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
  801971:	83 c4 0c             	add    $0xc,%esp
  801974:	68 7f 45 4c 46       	push   $0x464c457f
  801979:	ff b5 e8 fd ff ff    	pushl  -0x218(%ebp)
  80197f:	68 6f 2f 80 00       	push   $0x802f6f
  801984:	e8 3f e9 ff ff       	call   8002c8 <cprintf>
		return -E_NOT_EXEC;
  801989:	83 c4 10             	add    $0x10,%esp
  80198c:	c7 85 84 fd ff ff f2 	movl   $0xfffffff2,-0x27c(%ebp)
  801993:	ff ff ff 
  801996:	e9 da 04 00 00       	jmp    801e75 <spawn+0x569>
  80199b:	ba 07 00 00 00       	mov    $0x7,%edx
  8019a0:	89 d0                	mov    %edx,%eax
  8019a2:	cd 30                	int    $0x30
  8019a4:	89 85 74 fd ff ff    	mov    %eax,-0x28c(%ebp)
  8019aa:	89 85 84 fd ff ff    	mov    %eax,-0x27c(%ebp)
	}


	// Create new child environment
	if ((r = sys_exofork()) < 0)
  8019b0:	85 c0                	test   %eax,%eax
  8019b2:	0f 88 bd 04 00 00    	js     801e75 <spawn+0x569>
	child = r;



	// Set up trap frame, including initial stack.
	child_tf = envs[ENVX(child)].env_tf;
  8019b8:	25 ff 03 00 00       	and    $0x3ff,%eax
  8019bd:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  8019c4:	89 c6                	mov    %eax,%esi
  8019c6:	c1 e6 07             	shl    $0x7,%esi
  8019c9:	29 d6                	sub    %edx,%esi
  8019cb:	81 c6 00 00 c0 ee    	add    $0xeec00000,%esi
  8019d1:	8d bd a4 fd ff ff    	lea    -0x25c(%ebp),%edi
  8019d7:	b9 11 00 00 00       	mov    $0x11,%ecx
  8019dc:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	child_tf.tf_eip = elf->e_entry;
  8019de:	8b 85 00 fe ff ff    	mov    -0x200(%ebp),%eax
  8019e4:	89 85 d4 fd ff ff    	mov    %eax,-0x22c(%ebp)
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  8019ea:	8b 55 0c             	mov    0xc(%ebp),%edx
  8019ed:	8b 02                	mov    (%edx),%eax
  8019ef:	85 c0                	test   %eax,%eax
  8019f1:	74 39                	je     801a2c <spawn+0x120>
	char *string_store;
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
  8019f3:	be 00 00 00 00       	mov    $0x0,%esi
	for (argc = 0; argv[argc] != 0; argc++)
  8019f8:	bb 00 00 00 00       	mov    $0x0,%ebx
  8019fd:	89 d7                	mov    %edx,%edi
		string_size += strlen(argv[argc]) + 1;
  8019ff:	83 ec 0c             	sub    $0xc,%esp
  801a02:	50                   	push   %eax
  801a03:	e8 24 ee ff ff       	call   80082c <strlen>
  801a08:	8d 74 30 01          	lea    0x1(%eax,%esi,1),%esi
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  801a0c:	43                   	inc    %ebx
  801a0d:	8d 0c 9d 00 00 00 00 	lea    0x0(,%ebx,4),%ecx
  801a14:	8b 04 9f             	mov    (%edi,%ebx,4),%eax
  801a17:	83 c4 10             	add    $0x10,%esp
  801a1a:	85 c0                	test   %eax,%eax
  801a1c:	75 e1                	jne    8019ff <spawn+0xf3>
  801a1e:	89 9d 80 fd ff ff    	mov    %ebx,-0x280(%ebp)
  801a24:	89 8d 7c fd ff ff    	mov    %ecx,-0x284(%ebp)
  801a2a:	eb 1e                	jmp    801a4a <spawn+0x13e>
  801a2c:	c7 85 7c fd ff ff 00 	movl   $0x0,-0x284(%ebp)
  801a33:	00 00 00 
  801a36:	c7 85 80 fd ff ff 00 	movl   $0x0,-0x280(%ebp)
  801a3d:	00 00 00 
	char *string_store;
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
  801a40:	be 00 00 00 00       	mov    $0x0,%esi
	for (argc = 0; argv[argc] != 0; argc++)
  801a45:	bb 00 00 00 00       	mov    $0x0,%ebx
	// Determine where to place the strings and the argv array.
	// Set up pointers into the temporary page 'UTEMP'; we'll map a page
	// there later, then remap that page into the child environment
	// at (USTACKTOP - PGSIZE).
	// strings is the topmost thing on the stack.
	string_store = (char*) UTEMP + PGSIZE - string_size;
  801a4a:	f7 de                	neg    %esi
  801a4c:	8d be 00 10 40 00    	lea    0x401000(%esi),%edi
	// argv is below that.  There's one argument pointer per argument, plus
	// a null pointer.
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));
  801a52:	89 fa                	mov    %edi,%edx
  801a54:	83 e2 fc             	and    $0xfffffffc,%edx
  801a57:	89 d8                	mov    %ebx,%eax
  801a59:	f7 d0                	not    %eax
  801a5b:	8d 04 82             	lea    (%edx,%eax,4),%eax
  801a5e:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
  801a64:	83 e8 08             	sub    $0x8,%eax
  801a67:	3d ff ff 3f 00       	cmp    $0x3fffff,%eax
  801a6c:	0f 86 11 04 00 00    	jbe    801e83 <spawn+0x577>
		return -E_NO_MEM;

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801a72:	83 ec 04             	sub    $0x4,%esp
  801a75:	6a 07                	push   $0x7
  801a77:	68 00 00 40 00       	push   $0x400000
  801a7c:	6a 00                	push   $0x0
  801a7e:	e8 7d f2 ff ff       	call   800d00 <sys_page_alloc>
  801a83:	83 c4 10             	add    $0x10,%esp
  801a86:	85 c0                	test   %eax,%eax
  801a88:	0f 88 01 04 00 00    	js     801e8f <spawn+0x583>
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  801a8e:	85 db                	test   %ebx,%ebx
  801a90:	7e 44                	jle    801ad6 <spawn+0x1ca>
  801a92:	be 00 00 00 00       	mov    $0x0,%esi
  801a97:	89 9d 8c fd ff ff    	mov    %ebx,-0x274(%ebp)
  801a9d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
		argv_store[i] = UTEMP2USTACK(string_store);
  801aa0:	8d 87 00 d0 7f ee    	lea    -0x11803000(%edi),%eax
  801aa6:	8b 95 94 fd ff ff    	mov    -0x26c(%ebp),%edx
  801aac:	89 04 b2             	mov    %eax,(%edx,%esi,4)
		strcpy(string_store, argv[i]);
  801aaf:	83 ec 08             	sub    $0x8,%esp
  801ab2:	ff 34 b3             	pushl  (%ebx,%esi,4)
  801ab5:	57                   	push   %edi
  801ab6:	e8 c3 ed ff ff       	call   80087e <strcpy>
		string_store += strlen(argv[i]) + 1;
  801abb:	83 c4 04             	add    $0x4,%esp
  801abe:	ff 34 b3             	pushl  (%ebx,%esi,4)
  801ac1:	e8 66 ed ff ff       	call   80082c <strlen>
  801ac6:	8d 7c 07 01          	lea    0x1(%edi,%eax,1),%edi
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  801aca:	46                   	inc    %esi
  801acb:	83 c4 10             	add    $0x10,%esp
  801ace:	3b b5 8c fd ff ff    	cmp    -0x274(%ebp),%esi
  801ad4:	7c ca                	jl     801aa0 <spawn+0x194>
		argv_store[i] = UTEMP2USTACK(string_store);
		strcpy(string_store, argv[i]);
		string_store += strlen(argv[i]) + 1;
	}
	argv_store[argc] = 0;
  801ad6:	8b 95 94 fd ff ff    	mov    -0x26c(%ebp),%edx
  801adc:	8b 85 7c fd ff ff    	mov    -0x284(%ebp),%eax
  801ae2:	c7 04 02 00 00 00 00 	movl   $0x0,(%edx,%eax,1)
	assert(string_store == (char*)UTEMP + PGSIZE);
  801ae9:	81 ff 00 10 40 00    	cmp    $0x401000,%edi
  801aef:	74 19                	je     801b0a <spawn+0x1fe>
  801af1:	68 fc 2f 80 00       	push   $0x802ffc
  801af6:	68 43 2f 80 00       	push   $0x802f43
  801afb:	68 f5 00 00 00       	push   $0xf5
  801b00:	68 89 2f 80 00       	push   $0x802f89
  801b05:	e8 e6 e6 ff ff       	call   8001f0 <_panic>

	argv_store[-1] = UTEMP2USTACK(argv_store);
  801b0a:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  801b10:	2d 00 30 80 11       	sub    $0x11803000,%eax
  801b15:	8b 95 94 fd ff ff    	mov    -0x26c(%ebp),%edx
  801b1b:	89 42 fc             	mov    %eax,-0x4(%edx)
	argv_store[-2] = argc;
  801b1e:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  801b24:	89 42 f8             	mov    %eax,-0x8(%edx)

	*init_esp = UTEMP2USTACK(&argv_store[-2]);
  801b27:	89 d0                	mov    %edx,%eax
  801b29:	2d 08 30 80 11       	sub    $0x11803008,%eax
  801b2e:	89 85 e0 fd ff ff    	mov    %eax,-0x220(%ebp)

	// After completing the stack, map it into the child's address space
	// and unmap it from ours!
	if ((r = sys_page_map(0, UTEMP, child, (void*) (USTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W)) < 0)
  801b34:	83 ec 0c             	sub    $0xc,%esp
  801b37:	6a 07                	push   $0x7
  801b39:	68 00 d0 bf ee       	push   $0xeebfd000
  801b3e:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801b44:	68 00 00 40 00       	push   $0x400000
  801b49:	6a 00                	push   $0x0
  801b4b:	e8 d4 f1 ff ff       	call   800d24 <sys_page_map>
  801b50:	89 c3                	mov    %eax,%ebx
  801b52:	83 c4 20             	add    $0x20,%esp
  801b55:	85 c0                	test   %eax,%eax
  801b57:	78 18                	js     801b71 <spawn+0x265>
		goto error;
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  801b59:	83 ec 08             	sub    $0x8,%esp
  801b5c:	68 00 00 40 00       	push   $0x400000
  801b61:	6a 00                	push   $0x0
  801b63:	e8 e2 f1 ff ff       	call   800d4a <sys_page_unmap>
  801b68:	89 c3                	mov    %eax,%ebx
  801b6a:	83 c4 10             	add    $0x10,%esp
  801b6d:	85 c0                	test   %eax,%eax
  801b6f:	79 1d                	jns    801b8e <spawn+0x282>
		goto error;

	return 0;

error:
	sys_page_unmap(0, UTEMP);
  801b71:	83 ec 08             	sub    $0x8,%esp
  801b74:	68 00 00 40 00       	push   $0x400000
  801b79:	6a 00                	push   $0x0
  801b7b:	e8 ca f1 ff ff       	call   800d4a <sys_page_unmap>
  801b80:	83 c4 10             	add    $0x10,%esp
	return r;
  801b83:	89 9d 84 fd ff ff    	mov    %ebx,-0x27c(%ebp)
  801b89:	e9 e7 02 00 00       	jmp    801e75 <spawn+0x569>
	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;


	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  801b8e:	8b 85 04 fe ff ff    	mov    -0x1fc(%ebp),%eax
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801b94:	66 83 bd 14 fe ff ff 	cmpw   $0x0,-0x1ec(%ebp)
  801b9b:	00 
  801b9c:	0f 84 c3 01 00 00    	je     801d65 <spawn+0x459>
	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;


	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  801ba2:	8d 84 05 e8 fd ff ff 	lea    -0x218(%ebp,%eax,1),%eax
  801ba9:	89 85 80 fd ff ff    	mov    %eax,-0x280(%ebp)
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801baf:	c7 85 7c fd ff ff 00 	movl   $0x0,-0x284(%ebp)
  801bb6:	00 00 00 
		if (ph->p_type != ELF_PROG_LOAD)
  801bb9:	8b 95 80 fd ff ff    	mov    -0x280(%ebp),%edx
  801bbf:	83 3a 01             	cmpl   $0x1,(%edx)
  801bc2:	0f 85 7c 01 00 00    	jne    801d44 <spawn+0x438>
			continue;
		perm = PTE_P | PTE_U;
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
  801bc8:	8b 42 18             	mov    0x18(%edx),%eax
  801bcb:	83 e0 02             	and    $0x2,%eax
	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
		if (ph->p_type != ELF_PROG_LOAD)
			continue;
		perm = PTE_P | PTE_U;
  801bce:	83 f8 01             	cmp    $0x1,%eax
  801bd1:	19 db                	sbb    %ebx,%ebx
  801bd3:	83 e3 fe             	and    $0xfffffffe,%ebx
  801bd6:	83 c3 07             	add    $0x7,%ebx
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
  801bd9:	8b 42 04             	mov    0x4(%edx),%eax
  801bdc:	89 85 78 fd ff ff    	mov    %eax,-0x288(%ebp)
  801be2:	8b 52 10             	mov    0x10(%edx),%edx
  801be5:	89 95 94 fd ff ff    	mov    %edx,-0x26c(%ebp)
  801beb:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  801bf1:	8b 40 14             	mov    0x14(%eax),%eax
  801bf4:	89 85 8c fd ff ff    	mov    %eax,-0x274(%ebp)
  801bfa:	8b 95 80 fd ff ff    	mov    -0x280(%ebp),%edx
  801c00:	8b 52 08             	mov    0x8(%edx),%edx
  801c03:	89 95 90 fd ff ff    	mov    %edx,-0x270(%ebp)
	int i, r;
	void *blk;

	//cprintf("map_segment %x+%x\n", va, memsz);

	if ((i = PGOFF(va))) {
  801c09:	89 d0                	mov    %edx,%eax
  801c0b:	25 ff 0f 00 00       	and    $0xfff,%eax
  801c10:	74 1a                	je     801c2c <spawn+0x320>
		va -= i;
  801c12:	29 c2                	sub    %eax,%edx
  801c14:	89 95 90 fd ff ff    	mov    %edx,-0x270(%ebp)
		memsz += i;
  801c1a:	01 85 8c fd ff ff    	add    %eax,-0x274(%ebp)
		filesz += i;
  801c20:	01 85 94 fd ff ff    	add    %eax,-0x26c(%ebp)
		fileoffset -= i;
  801c26:	29 85 78 fd ff ff    	sub    %eax,-0x288(%ebp)
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  801c2c:	83 bd 8c fd ff ff 00 	cmpl   $0x0,-0x274(%ebp)
  801c33:	0f 84 0b 01 00 00    	je     801d44 <spawn+0x438>
  801c39:	bf 00 00 00 00       	mov    $0x0,%edi
  801c3e:	be 00 00 00 00       	mov    $0x0,%esi
		if (i >= filesz) {
  801c43:	3b bd 94 fd ff ff    	cmp    -0x26c(%ebp),%edi
  801c49:	72 28                	jb     801c73 <spawn+0x367>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
  801c4b:	83 ec 04             	sub    $0x4,%esp
  801c4e:	53                   	push   %ebx
  801c4f:	03 bd 90 fd ff ff    	add    -0x270(%ebp),%edi
  801c55:	57                   	push   %edi
  801c56:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  801c5c:	e8 9f f0 ff ff       	call   800d00 <sys_page_alloc>
  801c61:	83 c4 10             	add    $0x10,%esp
  801c64:	85 c0                	test   %eax,%eax
  801c66:	0f 89 c4 00 00 00    	jns    801d30 <spawn+0x424>
  801c6c:	89 c3                	mov    %eax,%ebx
  801c6e:	e9 cf 01 00 00       	jmp    801e42 <spawn+0x536>
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801c73:	83 ec 04             	sub    $0x4,%esp
  801c76:	6a 07                	push   $0x7
  801c78:	68 00 00 40 00       	push   $0x400000
  801c7d:	6a 00                	push   $0x0
  801c7f:	e8 7c f0 ff ff       	call   800d00 <sys_page_alloc>
  801c84:	83 c4 10             	add    $0x10,%esp
  801c87:	85 c0                	test   %eax,%eax
  801c89:	0f 88 a9 01 00 00    	js     801e38 <spawn+0x52c>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  801c8f:	83 ec 08             	sub    $0x8,%esp
// prog: the pathname of the program to run.
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
  801c92:	8b 85 78 fd ff ff    	mov    -0x288(%ebp),%eax
  801c98:	8d 04 06             	lea    (%esi,%eax,1),%eax
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  801c9b:	50                   	push   %eax
  801c9c:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  801ca2:	e8 2f f9 ff ff       	call   8015d6 <seek>
  801ca7:	83 c4 10             	add    $0x10,%esp
  801caa:	85 c0                	test   %eax,%eax
  801cac:	0f 88 8a 01 00 00    	js     801e3c <spawn+0x530>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  801cb2:	83 ec 04             	sub    $0x4,%esp
  801cb5:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  801cbb:	29 f8                	sub    %edi,%eax
  801cbd:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801cc2:	76 05                	jbe    801cc9 <spawn+0x3bd>
  801cc4:	b8 00 10 00 00       	mov    $0x1000,%eax
  801cc9:	50                   	push   %eax
  801cca:	68 00 00 40 00       	push   $0x400000
  801ccf:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  801cd5:	e8 25 f8 ff ff       	call   8014ff <readn>
  801cda:	83 c4 10             	add    $0x10,%esp
  801cdd:	85 c0                	test   %eax,%eax
  801cdf:	0f 88 5b 01 00 00    	js     801e40 <spawn+0x534>
				return r;
			if ((r = sys_page_map(0, UTEMP, child, (void*) (va + i), perm)) < 0)
  801ce5:	83 ec 0c             	sub    $0xc,%esp
  801ce8:	53                   	push   %ebx
  801ce9:	03 bd 90 fd ff ff    	add    -0x270(%ebp),%edi
  801cef:	57                   	push   %edi
  801cf0:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  801cf6:	68 00 00 40 00       	push   $0x400000
  801cfb:	6a 00                	push   $0x0
  801cfd:	e8 22 f0 ff ff       	call   800d24 <sys_page_map>
  801d02:	83 c4 20             	add    $0x20,%esp
  801d05:	85 c0                	test   %eax,%eax
  801d07:	79 15                	jns    801d1e <spawn+0x412>
				panic("spawn: sys_page_map data: %e", r);
  801d09:	50                   	push   %eax
  801d0a:	68 95 2f 80 00       	push   $0x802f95
  801d0f:	68 28 01 00 00       	push   $0x128
  801d14:	68 89 2f 80 00       	push   $0x802f89
  801d19:	e8 d2 e4 ff ff       	call   8001f0 <_panic>
			sys_page_unmap(0, UTEMP);
  801d1e:	83 ec 08             	sub    $0x8,%esp
  801d21:	68 00 00 40 00       	push   $0x400000
  801d26:	6a 00                	push   $0x0
  801d28:	e8 1d f0 ff ff       	call   800d4a <sys_page_unmap>
  801d2d:	83 c4 10             	add    $0x10,%esp
		memsz += i;
		filesz += i;
		fileoffset -= i;
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  801d30:	81 c6 00 10 00 00    	add    $0x1000,%esi
  801d36:	89 f7                	mov    %esi,%edi
  801d38:	39 b5 8c fd ff ff    	cmp    %esi,-0x274(%ebp)
  801d3e:	0f 87 ff fe ff ff    	ja     801c43 <spawn+0x337>
		return r;


	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801d44:	ff 85 7c fd ff ff    	incl   -0x284(%ebp)
  801d4a:	0f b7 85 14 fe ff ff 	movzwl -0x1ec(%ebp),%eax
  801d51:	3b 85 7c fd ff ff    	cmp    -0x284(%ebp),%eax
  801d57:	7e 0c                	jle    801d65 <spawn+0x459>
  801d59:	83 85 80 fd ff ff 20 	addl   $0x20,-0x280(%ebp)
  801d60:	e9 54 fe ff ff       	jmp    801bb9 <spawn+0x2ad>
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
				     fd, ph->p_filesz, ph->p_offset, perm)) < 0)
			goto error;
	}
	close(fd);
  801d65:	83 ec 0c             	sub    $0xc,%esp
  801d68:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  801d6e:	e8 c8 f5 ff ff       	call   80133b <close>
  801d73:	83 c4 10             	add    $0x10,%esp
copy_shared_pages(envid_t child)
{
	// LAB 5: Your code here.
    uint32_t i;
    int r;
    for (i = 0; i != UTOP; i += PGSIZE) 
  801d76:	bb 00 00 00 00       	mov    $0x0,%ebx
  801d7b:	8b b5 84 fd ff ff    	mov    -0x27c(%ebp),%esi
    if ((uvpd[PDX(i)] & PTE_P) && (uvpt[i / PGSIZE] & PTE_P) && (uvpt[i / PGSIZE] & PTE_SHARE)) {
  801d81:	89 d8                	mov    %ebx,%eax
  801d83:	c1 e8 16             	shr    $0x16,%eax
  801d86:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801d8d:	a8 01                	test   $0x1,%al
  801d8f:	74 3e                	je     801dcf <spawn+0x4c3>
  801d91:	89 d8                	mov    %ebx,%eax
  801d93:	c1 e8 0c             	shr    $0xc,%eax
  801d96:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801d9d:	f6 c2 01             	test   $0x1,%dl
  801da0:	74 2d                	je     801dcf <spawn+0x4c3>
  801da2:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801da9:	f6 c6 04             	test   $0x4,%dh
  801dac:	74 21                	je     801dcf <spawn+0x4c3>
        r = sys_page_map(0, (void *)i, child, (void *)i, uvpt[i / PGSIZE] & PTE_SYSCALL);
  801dae:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801db5:	83 ec 0c             	sub    $0xc,%esp
  801db8:	25 07 0e 00 00       	and    $0xe07,%eax
  801dbd:	50                   	push   %eax
  801dbe:	53                   	push   %ebx
  801dbf:	56                   	push   %esi
  801dc0:	53                   	push   %ebx
  801dc1:	6a 00                	push   $0x0
  801dc3:	e8 5c ef ff ff       	call   800d24 <sys_page_map>
        if (r < 0) return r;
  801dc8:	83 c4 20             	add    $0x20,%esp
  801dcb:	85 c0                	test   %eax,%eax
  801dcd:	78 13                	js     801de2 <spawn+0x4d6>
copy_shared_pages(envid_t child)
{
	// LAB 5: Your code here.
    uint32_t i;
    int r;
    for (i = 0; i != UTOP; i += PGSIZE) 
  801dcf:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801dd5:	81 fb 00 00 c0 ee    	cmp    $0xeec00000,%ebx
  801ddb:	75 a4                	jne    801d81 <spawn+0x475>
  801ddd:	e9 b5 00 00 00       	jmp    801e97 <spawn+0x58b>
	close(fd);
	fd = -1;

	// Copy shared library state.
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);
  801de2:	50                   	push   %eax
  801de3:	68 b2 2f 80 00       	push   $0x802fb2
  801de8:	68 86 00 00 00       	push   $0x86
  801ded:	68 89 2f 80 00       	push   $0x802f89
  801df2:	e8 f9 e3 ff ff       	call   8001f0 <_panic>

	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
		panic("sys_env_set_trapframe: %e", r);
  801df7:	50                   	push   %eax
  801df8:	68 c8 2f 80 00       	push   $0x802fc8
  801dfd:	68 89 00 00 00       	push   $0x89
  801e02:	68 89 2f 80 00       	push   $0x802f89
  801e07:	e8 e4 e3 ff ff       	call   8001f0 <_panic>

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
  801e0c:	83 ec 08             	sub    $0x8,%esp
  801e0f:	6a 02                	push   $0x2
  801e11:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801e17:	e8 51 ef ff ff       	call   800d6d <sys_env_set_status>
  801e1c:	83 c4 10             	add    $0x10,%esp
  801e1f:	85 c0                	test   %eax,%eax
  801e21:	79 52                	jns    801e75 <spawn+0x569>
		panic("sys_env_set_status: %e", r);
  801e23:	50                   	push   %eax
  801e24:	68 e2 2f 80 00       	push   $0x802fe2
  801e29:	68 8c 00 00 00       	push   $0x8c
  801e2e:	68 89 2f 80 00       	push   $0x802f89
  801e33:	e8 b8 e3 ff ff       	call   8001f0 <_panic>
  801e38:	89 c3                	mov    %eax,%ebx
  801e3a:	eb 06                	jmp    801e42 <spawn+0x536>
  801e3c:	89 c3                	mov    %eax,%ebx
  801e3e:	eb 02                	jmp    801e42 <spawn+0x536>
  801e40:	89 c3                	mov    %eax,%ebx

	return child;

error:
	sys_env_destroy(child);
  801e42:	83 ec 0c             	sub    $0xc,%esp
  801e45:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801e4b:	e8 43 ee ff ff       	call   800c93 <sys_env_destroy>
	close(fd);
  801e50:	83 c4 04             	add    $0x4,%esp
  801e53:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  801e59:	e8 dd f4 ff ff       	call   80133b <close>
	return r;
  801e5e:	83 c4 10             	add    $0x10,%esp
  801e61:	89 9d 84 fd ff ff    	mov    %ebx,-0x27c(%ebp)
  801e67:	eb 0c                	jmp    801e75 <spawn+0x569>
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
		return r;
  801e69:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  801e6f:	89 85 84 fd ff ff    	mov    %eax,-0x27c(%ebp)

error:
	sys_env_destroy(child);
	close(fd);
	return r;
}
  801e75:	8b 85 84 fd ff ff    	mov    -0x27c(%ebp),%eax
  801e7b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e7e:	5b                   	pop    %ebx
  801e7f:	5e                   	pop    %esi
  801e80:	5f                   	pop    %edi
  801e81:	c9                   	leave  
  801e82:	c3                   	ret    
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
		return -E_NO_MEM;
  801e83:	c7 85 84 fd ff ff fc 	movl   $0xfffffffc,-0x27c(%ebp)
  801e8a:	ff ff ff 
  801e8d:	eb e6                	jmp    801e75 <spawn+0x569>

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
		return r;
  801e8f:	89 85 84 fd ff ff    	mov    %eax,-0x27c(%ebp)
  801e95:	eb de                	jmp    801e75 <spawn+0x569>

	// Copy shared library state.
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);

	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
  801e97:	83 ec 08             	sub    $0x8,%esp
  801e9a:	8d 85 a4 fd ff ff    	lea    -0x25c(%ebp),%eax
  801ea0:	50                   	push   %eax
  801ea1:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801ea7:	e8 e4 ee ff ff       	call   800d90 <sys_env_set_trapframe>
  801eac:	83 c4 10             	add    $0x10,%esp
  801eaf:	85 c0                	test   %eax,%eax
  801eb1:	0f 89 55 ff ff ff    	jns    801e0c <spawn+0x500>
  801eb7:	e9 3b ff ff ff       	jmp    801df7 <spawn+0x4eb>

00801ebc <spawnl>:
// Spawn, taking command-line arguments array directly on the stack.
// NOTE: Must have a sentinal of NULL at the end of the args
// (none of the args may be NULL).
int
spawnl(const char *prog, const char *arg0, ...)
{
  801ebc:	55                   	push   %ebp
  801ebd:	89 e5                	mov    %esp,%ebp
  801ebf:	56                   	push   %esi
  801ec0:	53                   	push   %ebx
  801ec1:	8b 75 0c             	mov    0xc(%ebp),%esi
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801ec4:	8d 45 14             	lea    0x14(%ebp),%eax
  801ec7:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801ecb:	74 5f                	je     801f2c <spawnl+0x70>
{
	// We calculate argc by advancing the args until we hit NULL.
	// The contract of the function guarantees that the last
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
  801ecd:	b9 00 00 00 00       	mov    $0x0,%ecx
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
		argc++;
  801ed2:	41                   	inc    %ecx
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801ed3:	89 c2                	mov    %eax,%edx
  801ed5:	83 c0 04             	add    $0x4,%eax
  801ed8:	83 3a 00             	cmpl   $0x0,(%edx)
  801edb:	75 f5                	jne    801ed2 <spawnl+0x16>
		argc++;
	va_end(vl);

	// Now that we have the size of the args, do a second pass
	// and store the values in a VLA, which has the format of argv
	const char *argv[argc+2];
  801edd:	8d 04 8d 26 00 00 00 	lea    0x26(,%ecx,4),%eax
  801ee4:	83 e0 f0             	and    $0xfffffff0,%eax
  801ee7:	29 c4                	sub    %eax,%esp
  801ee9:	8d 44 24 0f          	lea    0xf(%esp),%eax
  801eed:	83 e0 f0             	and    $0xfffffff0,%eax
  801ef0:	89 c3                	mov    %eax,%ebx
	argv[0] = arg0;
  801ef2:	89 30                	mov    %esi,(%eax)
	argv[argc+1] = NULL;
  801ef4:	c7 44 88 04 00 00 00 	movl   $0x0,0x4(%eax,%ecx,4)
  801efb:	00 

	va_start(vl, arg0);
  801efc:	8d 55 10             	lea    0x10(%ebp),%edx
	unsigned i;
	for(i=0;i<argc;i++)
  801eff:	89 ce                	mov    %ecx,%esi
  801f01:	85 c9                	test   %ecx,%ecx
  801f03:	74 14                	je     801f19 <spawnl+0x5d>
  801f05:	b8 00 00 00 00       	mov    $0x0,%eax
		argv[i+1] = va_arg(vl, const char *);
  801f0a:	40                   	inc    %eax
  801f0b:	89 d1                	mov    %edx,%ecx
  801f0d:	83 c2 04             	add    $0x4,%edx
  801f10:	8b 09                	mov    (%ecx),%ecx
  801f12:	89 0c 83             	mov    %ecx,(%ebx,%eax,4)
	argv[0] = arg0;
	argv[argc+1] = NULL;

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  801f15:	39 f0                	cmp    %esi,%eax
  801f17:	72 f1                	jb     801f0a <spawnl+0x4e>
		argv[i+1] = va_arg(vl, const char *);
	va_end(vl);
	return spawn(prog, argv);
  801f19:	83 ec 08             	sub    $0x8,%esp
  801f1c:	53                   	push   %ebx
  801f1d:	ff 75 08             	pushl  0x8(%ebp)
  801f20:	e8 e7 f9 ff ff       	call   80190c <spawn>
}
  801f25:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f28:	5b                   	pop    %ebx
  801f29:	5e                   	pop    %esi
  801f2a:	c9                   	leave  
  801f2b:	c3                   	ret    
		argc++;
	va_end(vl);

	// Now that we have the size of the args, do a second pass
	// and store the values in a VLA, which has the format of argv
	const char *argv[argc+2];
  801f2c:	83 ec 20             	sub    $0x20,%esp
  801f2f:	8d 44 24 0f          	lea    0xf(%esp),%eax
  801f33:	83 e0 f0             	and    $0xfffffff0,%eax
  801f36:	89 c3                	mov    %eax,%ebx
	argv[0] = arg0;
  801f38:	89 30                	mov    %esi,(%eax)
	argv[argc+1] = NULL;
  801f3a:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
  801f41:	eb d6                	jmp    801f19 <spawnl+0x5d>
	...

00801f44 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801f44:	55                   	push   %ebp
  801f45:	89 e5                	mov    %esp,%ebp
  801f47:	56                   	push   %esi
  801f48:	53                   	push   %ebx
  801f49:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801f4c:	83 ec 0c             	sub    $0xc,%esp
  801f4f:	ff 75 08             	pushl  0x8(%ebp)
  801f52:	e8 15 f2 ff ff       	call   80116c <fd2data>
  801f57:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  801f59:	83 c4 08             	add    $0x8,%esp
  801f5c:	68 22 30 80 00       	push   $0x803022
  801f61:	56                   	push   %esi
  801f62:	e8 17 e9 ff ff       	call   80087e <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801f67:	8b 43 04             	mov    0x4(%ebx),%eax
  801f6a:	2b 03                	sub    (%ebx),%eax
  801f6c:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  801f72:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  801f79:	00 00 00 
	stat->st_dev = &devpipe;
  801f7c:	c7 86 88 00 00 00 28 	movl   $0x804028,0x88(%esi)
  801f83:	40 80 00 
	return 0;
}
  801f86:	b8 00 00 00 00       	mov    $0x0,%eax
  801f8b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f8e:	5b                   	pop    %ebx
  801f8f:	5e                   	pop    %esi
  801f90:	c9                   	leave  
  801f91:	c3                   	ret    

00801f92 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801f92:	55                   	push   %ebp
  801f93:	89 e5                	mov    %esp,%ebp
  801f95:	53                   	push   %ebx
  801f96:	83 ec 0c             	sub    $0xc,%esp
  801f99:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801f9c:	53                   	push   %ebx
  801f9d:	6a 00                	push   $0x0
  801f9f:	e8 a6 ed ff ff       	call   800d4a <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801fa4:	89 1c 24             	mov    %ebx,(%esp)
  801fa7:	e8 c0 f1 ff ff       	call   80116c <fd2data>
  801fac:	83 c4 08             	add    $0x8,%esp
  801faf:	50                   	push   %eax
  801fb0:	6a 00                	push   $0x0
  801fb2:	e8 93 ed ff ff       	call   800d4a <sys_page_unmap>
}
  801fb7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801fba:	c9                   	leave  
  801fbb:	c3                   	ret    

00801fbc <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801fbc:	55                   	push   %ebp
  801fbd:	89 e5                	mov    %esp,%ebp
  801fbf:	57                   	push   %edi
  801fc0:	56                   	push   %esi
  801fc1:	53                   	push   %ebx
  801fc2:	83 ec 1c             	sub    $0x1c,%esp
  801fc5:	89 c7                	mov    %eax,%edi
  801fc7:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801fca:	a1 04 50 80 00       	mov    0x805004,%eax
  801fcf:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801fd2:	83 ec 0c             	sub    $0xc,%esp
  801fd5:	57                   	push   %edi
  801fd6:	e8 b1 06 00 00       	call   80268c <pageref>
  801fdb:	89 c6                	mov    %eax,%esi
  801fdd:	83 c4 04             	add    $0x4,%esp
  801fe0:	ff 75 e4             	pushl  -0x1c(%ebp)
  801fe3:	e8 a4 06 00 00       	call   80268c <pageref>
  801fe8:	83 c4 10             	add    $0x10,%esp
  801feb:	39 c6                	cmp    %eax,%esi
  801fed:	0f 94 c0             	sete   %al
  801ff0:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  801ff3:	8b 15 04 50 80 00    	mov    0x805004,%edx
  801ff9:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801ffc:	39 cb                	cmp    %ecx,%ebx
  801ffe:	75 08                	jne    802008 <_pipeisclosed+0x4c>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  802000:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802003:	5b                   	pop    %ebx
  802004:	5e                   	pop    %esi
  802005:	5f                   	pop    %edi
  802006:	c9                   	leave  
  802007:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  802008:	83 f8 01             	cmp    $0x1,%eax
  80200b:	75 bd                	jne    801fca <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  80200d:	8b 42 58             	mov    0x58(%edx),%eax
  802010:	6a 01                	push   $0x1
  802012:	50                   	push   %eax
  802013:	53                   	push   %ebx
  802014:	68 29 30 80 00       	push   $0x803029
  802019:	e8 aa e2 ff ff       	call   8002c8 <cprintf>
  80201e:	83 c4 10             	add    $0x10,%esp
  802021:	eb a7                	jmp    801fca <_pipeisclosed+0xe>

00802023 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  802023:	55                   	push   %ebp
  802024:	89 e5                	mov    %esp,%ebp
  802026:	57                   	push   %edi
  802027:	56                   	push   %esi
  802028:	53                   	push   %ebx
  802029:	83 ec 28             	sub    $0x28,%esp
  80202c:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  80202f:	56                   	push   %esi
  802030:	e8 37 f1 ff ff       	call   80116c <fd2data>
  802035:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802037:	83 c4 10             	add    $0x10,%esp
  80203a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80203e:	75 4a                	jne    80208a <devpipe_write+0x67>
  802040:	bf 00 00 00 00       	mov    $0x0,%edi
  802045:	eb 56                	jmp    80209d <devpipe_write+0x7a>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  802047:	89 da                	mov    %ebx,%edx
  802049:	89 f0                	mov    %esi,%eax
  80204b:	e8 6c ff ff ff       	call   801fbc <_pipeisclosed>
  802050:	85 c0                	test   %eax,%eax
  802052:	75 4d                	jne    8020a1 <devpipe_write+0x7e>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  802054:	e8 80 ec ff ff       	call   800cd9 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  802059:	8b 43 04             	mov    0x4(%ebx),%eax
  80205c:	8b 13                	mov    (%ebx),%edx
  80205e:	83 c2 20             	add    $0x20,%edx
  802061:	39 d0                	cmp    %edx,%eax
  802063:	73 e2                	jae    802047 <devpipe_write+0x24>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  802065:	89 c2                	mov    %eax,%edx
  802067:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  80206d:	79 05                	jns    802074 <devpipe_write+0x51>
  80206f:	4a                   	dec    %edx
  802070:	83 ca e0             	or     $0xffffffe0,%edx
  802073:	42                   	inc    %edx
  802074:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802077:	8a 0c 39             	mov    (%ecx,%edi,1),%cl
  80207a:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  80207e:	40                   	inc    %eax
  80207f:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802082:	47                   	inc    %edi
  802083:	39 7d 10             	cmp    %edi,0x10(%ebp)
  802086:	77 07                	ja     80208f <devpipe_write+0x6c>
  802088:	eb 13                	jmp    80209d <devpipe_write+0x7a>
  80208a:	bf 00 00 00 00       	mov    $0x0,%edi
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  80208f:	8b 43 04             	mov    0x4(%ebx),%eax
  802092:	8b 13                	mov    (%ebx),%edx
  802094:	83 c2 20             	add    $0x20,%edx
  802097:	39 d0                	cmp    %edx,%eax
  802099:	73 ac                	jae    802047 <devpipe_write+0x24>
  80209b:	eb c8                	jmp    802065 <devpipe_write+0x42>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  80209d:	89 f8                	mov    %edi,%eax
  80209f:	eb 05                	jmp    8020a6 <devpipe_write+0x83>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8020a1:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  8020a6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8020a9:	5b                   	pop    %ebx
  8020aa:	5e                   	pop    %esi
  8020ab:	5f                   	pop    %edi
  8020ac:	c9                   	leave  
  8020ad:	c3                   	ret    

008020ae <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  8020ae:	55                   	push   %ebp
  8020af:	89 e5                	mov    %esp,%ebp
  8020b1:	57                   	push   %edi
  8020b2:	56                   	push   %esi
  8020b3:	53                   	push   %ebx
  8020b4:	83 ec 18             	sub    $0x18,%esp
  8020b7:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  8020ba:	57                   	push   %edi
  8020bb:	e8 ac f0 ff ff       	call   80116c <fd2data>
  8020c0:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8020c2:	83 c4 10             	add    $0x10,%esp
  8020c5:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8020c9:	75 44                	jne    80210f <devpipe_read+0x61>
  8020cb:	be 00 00 00 00       	mov    $0x0,%esi
  8020d0:	eb 4f                	jmp    802121 <devpipe_read+0x73>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
				return i;
  8020d2:	89 f0                	mov    %esi,%eax
  8020d4:	eb 54                	jmp    80212a <devpipe_read+0x7c>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  8020d6:	89 da                	mov    %ebx,%edx
  8020d8:	89 f8                	mov    %edi,%eax
  8020da:	e8 dd fe ff ff       	call   801fbc <_pipeisclosed>
  8020df:	85 c0                	test   %eax,%eax
  8020e1:	75 42                	jne    802125 <devpipe_read+0x77>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  8020e3:	e8 f1 eb ff ff       	call   800cd9 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8020e8:	8b 03                	mov    (%ebx),%eax
  8020ea:	3b 43 04             	cmp    0x4(%ebx),%eax
  8020ed:	74 e7                	je     8020d6 <devpipe_read+0x28>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8020ef:	25 1f 00 00 80       	and    $0x8000001f,%eax
  8020f4:	79 05                	jns    8020fb <devpipe_read+0x4d>
  8020f6:	48                   	dec    %eax
  8020f7:	83 c8 e0             	or     $0xffffffe0,%eax
  8020fa:	40                   	inc    %eax
  8020fb:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  8020ff:	8b 55 0c             	mov    0xc(%ebp),%edx
  802102:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  802105:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802107:	46                   	inc    %esi
  802108:	39 75 10             	cmp    %esi,0x10(%ebp)
  80210b:	77 07                	ja     802114 <devpipe_read+0x66>
  80210d:	eb 12                	jmp    802121 <devpipe_read+0x73>
  80210f:	be 00 00 00 00       	mov    $0x0,%esi
		while (p->p_rpos == p->p_wpos) {
  802114:	8b 03                	mov    (%ebx),%eax
  802116:	3b 43 04             	cmp    0x4(%ebx),%eax
  802119:	75 d4                	jne    8020ef <devpipe_read+0x41>
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  80211b:	85 f6                	test   %esi,%esi
  80211d:	75 b3                	jne    8020d2 <devpipe_read+0x24>
  80211f:	eb b5                	jmp    8020d6 <devpipe_read+0x28>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  802121:	89 f0                	mov    %esi,%eax
  802123:	eb 05                	jmp    80212a <devpipe_read+0x7c>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802125:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  80212a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80212d:	5b                   	pop    %ebx
  80212e:	5e                   	pop    %esi
  80212f:	5f                   	pop    %edi
  802130:	c9                   	leave  
  802131:	c3                   	ret    

00802132 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  802132:	55                   	push   %ebp
  802133:	89 e5                	mov    %esp,%ebp
  802135:	57                   	push   %edi
  802136:	56                   	push   %esi
  802137:	53                   	push   %ebx
  802138:	83 ec 28             	sub    $0x28,%esp
  80213b:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  80213e:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  802141:	50                   	push   %eax
  802142:	e8 3d f0 ff ff       	call   801184 <fd_alloc>
  802147:	89 c3                	mov    %eax,%ebx
  802149:	83 c4 10             	add    $0x10,%esp
  80214c:	85 c0                	test   %eax,%eax
  80214e:	0f 88 24 01 00 00    	js     802278 <pipe+0x146>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802154:	83 ec 04             	sub    $0x4,%esp
  802157:	68 07 04 00 00       	push   $0x407
  80215c:	ff 75 e4             	pushl  -0x1c(%ebp)
  80215f:	6a 00                	push   $0x0
  802161:	e8 9a eb ff ff       	call   800d00 <sys_page_alloc>
  802166:	89 c3                	mov    %eax,%ebx
  802168:	83 c4 10             	add    $0x10,%esp
  80216b:	85 c0                	test   %eax,%eax
  80216d:	0f 88 05 01 00 00    	js     802278 <pipe+0x146>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  802173:	83 ec 0c             	sub    $0xc,%esp
  802176:	8d 45 e0             	lea    -0x20(%ebp),%eax
  802179:	50                   	push   %eax
  80217a:	e8 05 f0 ff ff       	call   801184 <fd_alloc>
  80217f:	89 c3                	mov    %eax,%ebx
  802181:	83 c4 10             	add    $0x10,%esp
  802184:	85 c0                	test   %eax,%eax
  802186:	0f 88 dc 00 00 00    	js     802268 <pipe+0x136>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80218c:	83 ec 04             	sub    $0x4,%esp
  80218f:	68 07 04 00 00       	push   $0x407
  802194:	ff 75 e0             	pushl  -0x20(%ebp)
  802197:	6a 00                	push   $0x0
  802199:	e8 62 eb ff ff       	call   800d00 <sys_page_alloc>
  80219e:	89 c3                	mov    %eax,%ebx
  8021a0:	83 c4 10             	add    $0x10,%esp
  8021a3:	85 c0                	test   %eax,%eax
  8021a5:	0f 88 bd 00 00 00    	js     802268 <pipe+0x136>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  8021ab:	83 ec 0c             	sub    $0xc,%esp
  8021ae:	ff 75 e4             	pushl  -0x1c(%ebp)
  8021b1:	e8 b6 ef ff ff       	call   80116c <fd2data>
  8021b6:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8021b8:	83 c4 0c             	add    $0xc,%esp
  8021bb:	68 07 04 00 00       	push   $0x407
  8021c0:	50                   	push   %eax
  8021c1:	6a 00                	push   $0x0
  8021c3:	e8 38 eb ff ff       	call   800d00 <sys_page_alloc>
  8021c8:	89 c3                	mov    %eax,%ebx
  8021ca:	83 c4 10             	add    $0x10,%esp
  8021cd:	85 c0                	test   %eax,%eax
  8021cf:	0f 88 83 00 00 00    	js     802258 <pipe+0x126>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8021d5:	83 ec 0c             	sub    $0xc,%esp
  8021d8:	ff 75 e0             	pushl  -0x20(%ebp)
  8021db:	e8 8c ef ff ff       	call   80116c <fd2data>
  8021e0:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  8021e7:	50                   	push   %eax
  8021e8:	6a 00                	push   $0x0
  8021ea:	56                   	push   %esi
  8021eb:	6a 00                	push   $0x0
  8021ed:	e8 32 eb ff ff       	call   800d24 <sys_page_map>
  8021f2:	89 c3                	mov    %eax,%ebx
  8021f4:	83 c4 20             	add    $0x20,%esp
  8021f7:	85 c0                	test   %eax,%eax
  8021f9:	78 4f                	js     80224a <pipe+0x118>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  8021fb:	8b 15 28 40 80 00    	mov    0x804028,%edx
  802201:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802204:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  802206:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802209:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  802210:	8b 15 28 40 80 00    	mov    0x804028,%edx
  802216:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802219:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  80221b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80221e:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  802225:	83 ec 0c             	sub    $0xc,%esp
  802228:	ff 75 e4             	pushl  -0x1c(%ebp)
  80222b:	e8 2c ef ff ff       	call   80115c <fd2num>
  802230:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  802232:	83 c4 04             	add    $0x4,%esp
  802235:	ff 75 e0             	pushl  -0x20(%ebp)
  802238:	e8 1f ef ff ff       	call   80115c <fd2num>
  80223d:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  802240:	83 c4 10             	add    $0x10,%esp
  802243:	bb 00 00 00 00       	mov    $0x0,%ebx
  802248:	eb 2e                	jmp    802278 <pipe+0x146>

    err3:
	sys_page_unmap(0, va);
  80224a:	83 ec 08             	sub    $0x8,%esp
  80224d:	56                   	push   %esi
  80224e:	6a 00                	push   $0x0
  802250:	e8 f5 ea ff ff       	call   800d4a <sys_page_unmap>
  802255:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  802258:	83 ec 08             	sub    $0x8,%esp
  80225b:	ff 75 e0             	pushl  -0x20(%ebp)
  80225e:	6a 00                	push   $0x0
  802260:	e8 e5 ea ff ff       	call   800d4a <sys_page_unmap>
  802265:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  802268:	83 ec 08             	sub    $0x8,%esp
  80226b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80226e:	6a 00                	push   $0x0
  802270:	e8 d5 ea ff ff       	call   800d4a <sys_page_unmap>
  802275:	83 c4 10             	add    $0x10,%esp
    err:
	return r;
}
  802278:	89 d8                	mov    %ebx,%eax
  80227a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80227d:	5b                   	pop    %ebx
  80227e:	5e                   	pop    %esi
  80227f:	5f                   	pop    %edi
  802280:	c9                   	leave  
  802281:	c3                   	ret    

00802282 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  802282:	55                   	push   %ebp
  802283:	89 e5                	mov    %esp,%ebp
  802285:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802288:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80228b:	50                   	push   %eax
  80228c:	ff 75 08             	pushl  0x8(%ebp)
  80228f:	e8 63 ef ff ff       	call   8011f7 <fd_lookup>
  802294:	83 c4 10             	add    $0x10,%esp
  802297:	85 c0                	test   %eax,%eax
  802299:	78 18                	js     8022b3 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  80229b:	83 ec 0c             	sub    $0xc,%esp
  80229e:	ff 75 f4             	pushl  -0xc(%ebp)
  8022a1:	e8 c6 ee ff ff       	call   80116c <fd2data>
	return _pipeisclosed(fd, p);
  8022a6:	89 c2                	mov    %eax,%edx
  8022a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8022ab:	e8 0c fd ff ff       	call   801fbc <_pipeisclosed>
  8022b0:	83 c4 10             	add    $0x10,%esp
}
  8022b3:	c9                   	leave  
  8022b4:	c3                   	ret    
  8022b5:	00 00                	add    %al,(%eax)
	...

008022b8 <wait>:
#include <inc/lib.h>

// Waits until 'envid' exits.
void
wait(envid_t envid)
{
  8022b8:	55                   	push   %ebp
  8022b9:	89 e5                	mov    %esp,%ebp
  8022bb:	57                   	push   %edi
  8022bc:	56                   	push   %esi
  8022bd:	53                   	push   %ebx
  8022be:	83 ec 0c             	sub    $0xc,%esp
  8022c1:	8b 45 08             	mov    0x8(%ebp),%eax
	const volatile struct Env *e;

	assert(envid != 0);
  8022c4:	85 c0                	test   %eax,%eax
  8022c6:	75 16                	jne    8022de <wait+0x26>
  8022c8:	68 41 30 80 00       	push   $0x803041
  8022cd:	68 43 2f 80 00       	push   $0x802f43
  8022d2:	6a 09                	push   $0x9
  8022d4:	68 4c 30 80 00       	push   $0x80304c
  8022d9:	e8 12 df ff ff       	call   8001f0 <_panic>
	e = &envs[ENVX(envid)];
  8022de:	89 c6                	mov    %eax,%esi
  8022e0:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
	while (e->env_id == envid && e->env_status != ENV_FREE)
  8022e6:	8d 0c b5 00 00 00 00 	lea    0x0(,%esi,4),%ecx
  8022ed:	89 f2                	mov    %esi,%edx
  8022ef:	c1 e2 07             	shl    $0x7,%edx
  8022f2:	29 ca                	sub    %ecx,%edx
  8022f4:	81 c2 08 00 c0 ee    	add    $0xeec00008,%edx
  8022fa:	8b 7a 40             	mov    0x40(%edx),%edi
  8022fd:	39 c7                	cmp    %eax,%edi
  8022ff:	75 37                	jne    802338 <wait+0x80>
  802301:	89 f0                	mov    %esi,%eax
  802303:	c1 e0 07             	shl    $0x7,%eax
  802306:	29 c8                	sub    %ecx,%eax
  802308:	05 04 00 c0 ee       	add    $0xeec00004,%eax
  80230d:	8b 40 50             	mov    0x50(%eax),%eax
  802310:	85 c0                	test   %eax,%eax
  802312:	74 24                	je     802338 <wait+0x80>
  802314:	c1 e6 07             	shl    $0x7,%esi
  802317:	29 ce                	sub    %ecx,%esi
  802319:	8d 9e 08 00 c0 ee    	lea    -0x113ffff8(%esi),%ebx
  80231f:	81 c6 04 00 c0 ee    	add    $0xeec00004,%esi
		sys_yield();
  802325:	e8 af e9 ff ff       	call   800cd9 <sys_yield>
{
	const volatile struct Env *e;

	assert(envid != 0);
	e = &envs[ENVX(envid)];
	while (e->env_id == envid && e->env_status != ENV_FREE)
  80232a:	8b 43 40             	mov    0x40(%ebx),%eax
  80232d:	39 f8                	cmp    %edi,%eax
  80232f:	75 07                	jne    802338 <wait+0x80>
  802331:	8b 46 50             	mov    0x50(%esi),%eax
  802334:	85 c0                	test   %eax,%eax
  802336:	75 ed                	jne    802325 <wait+0x6d>
		sys_yield();
}
  802338:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80233b:	5b                   	pop    %ebx
  80233c:	5e                   	pop    %esi
  80233d:	5f                   	pop    %edi
  80233e:	c9                   	leave  
  80233f:	c3                   	ret    

00802340 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  802340:	55                   	push   %ebp
  802341:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  802343:	b8 00 00 00 00       	mov    $0x0,%eax
  802348:	c9                   	leave  
  802349:	c3                   	ret    

0080234a <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80234a:	55                   	push   %ebp
  80234b:	89 e5                	mov    %esp,%ebp
  80234d:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  802350:	68 57 30 80 00       	push   $0x803057
  802355:	ff 75 0c             	pushl  0xc(%ebp)
  802358:	e8 21 e5 ff ff       	call   80087e <strcpy>
	return 0;
}
  80235d:	b8 00 00 00 00       	mov    $0x0,%eax
  802362:	c9                   	leave  
  802363:	c3                   	ret    

00802364 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  802364:	55                   	push   %ebp
  802365:	89 e5                	mov    %esp,%ebp
  802367:	57                   	push   %edi
  802368:	56                   	push   %esi
  802369:	53                   	push   %ebx
  80236a:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802370:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  802374:	74 45                	je     8023bb <devcons_write+0x57>
  802376:	b8 00 00 00 00       	mov    $0x0,%eax
  80237b:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  802380:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  802386:	8b 5d 10             	mov    0x10(%ebp),%ebx
  802389:	29 c3                	sub    %eax,%ebx
		if (m > sizeof(buf) - 1)
  80238b:	83 fb 7f             	cmp    $0x7f,%ebx
  80238e:	76 05                	jbe    802395 <devcons_write+0x31>
			m = sizeof(buf) - 1;
  802390:	bb 7f 00 00 00       	mov    $0x7f,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  802395:	83 ec 04             	sub    $0x4,%esp
  802398:	53                   	push   %ebx
  802399:	03 45 0c             	add    0xc(%ebp),%eax
  80239c:	50                   	push   %eax
  80239d:	57                   	push   %edi
  80239e:	e8 9c e6 ff ff       	call   800a3f <memmove>
		sys_cputs(buf, m);
  8023a3:	83 c4 08             	add    $0x8,%esp
  8023a6:	53                   	push   %ebx
  8023a7:	57                   	push   %edi
  8023a8:	e8 9c e8 ff ff       	call   800c49 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8023ad:	01 de                	add    %ebx,%esi
  8023af:	89 f0                	mov    %esi,%eax
  8023b1:	83 c4 10             	add    $0x10,%esp
  8023b4:	3b 75 10             	cmp    0x10(%ebp),%esi
  8023b7:	72 cd                	jb     802386 <devcons_write+0x22>
  8023b9:	eb 05                	jmp    8023c0 <devcons_write+0x5c>
  8023bb:	be 00 00 00 00       	mov    $0x0,%esi
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8023c0:	89 f0                	mov    %esi,%eax
  8023c2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8023c5:	5b                   	pop    %ebx
  8023c6:	5e                   	pop    %esi
  8023c7:	5f                   	pop    %edi
  8023c8:	c9                   	leave  
  8023c9:	c3                   	ret    

008023ca <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8023ca:	55                   	push   %ebp
  8023cb:	89 e5                	mov    %esp,%ebp
  8023cd:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  8023d0:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8023d4:	75 07                	jne    8023dd <devcons_read+0x13>
  8023d6:	eb 25                	jmp    8023fd <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8023d8:	e8 fc e8 ff ff       	call   800cd9 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8023dd:	e8 8d e8 ff ff       	call   800c6f <sys_cgetc>
  8023e2:	85 c0                	test   %eax,%eax
  8023e4:	74 f2                	je     8023d8 <devcons_read+0xe>
  8023e6:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  8023e8:	85 c0                	test   %eax,%eax
  8023ea:	78 1d                	js     802409 <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8023ec:	83 f8 04             	cmp    $0x4,%eax
  8023ef:	74 13                	je     802404 <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  8023f1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8023f4:	88 10                	mov    %dl,(%eax)
	return 1;
  8023f6:	b8 01 00 00 00       	mov    $0x1,%eax
  8023fb:	eb 0c                	jmp    802409 <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  8023fd:	b8 00 00 00 00       	mov    $0x0,%eax
  802402:	eb 05                	jmp    802409 <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  802404:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  802409:	c9                   	leave  
  80240a:	c3                   	ret    

0080240b <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  80240b:	55                   	push   %ebp
  80240c:	89 e5                	mov    %esp,%ebp
  80240e:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  802411:	8b 45 08             	mov    0x8(%ebp),%eax
  802414:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  802417:	6a 01                	push   $0x1
  802419:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80241c:	50                   	push   %eax
  80241d:	e8 27 e8 ff ff       	call   800c49 <sys_cputs>
  802422:	83 c4 10             	add    $0x10,%esp
}
  802425:	c9                   	leave  
  802426:	c3                   	ret    

00802427 <getchar>:

int
getchar(void)
{
  802427:	55                   	push   %ebp
  802428:	89 e5                	mov    %esp,%ebp
  80242a:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  80242d:	6a 01                	push   $0x1
  80242f:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802432:	50                   	push   %eax
  802433:	6a 00                	push   $0x0
  802435:	e8 3e f0 ff ff       	call   801478 <read>
	if (r < 0)
  80243a:	83 c4 10             	add    $0x10,%esp
  80243d:	85 c0                	test   %eax,%eax
  80243f:	78 0f                	js     802450 <getchar+0x29>
		return r;
	if (r < 1)
  802441:	85 c0                	test   %eax,%eax
  802443:	7e 06                	jle    80244b <getchar+0x24>
		return -E_EOF;
	return c;
  802445:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  802449:	eb 05                	jmp    802450 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  80244b:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  802450:	c9                   	leave  
  802451:	c3                   	ret    

00802452 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  802452:	55                   	push   %ebp
  802453:	89 e5                	mov    %esp,%ebp
  802455:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802458:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80245b:	50                   	push   %eax
  80245c:	ff 75 08             	pushl  0x8(%ebp)
  80245f:	e8 93 ed ff ff       	call   8011f7 <fd_lookup>
  802464:	83 c4 10             	add    $0x10,%esp
  802467:	85 c0                	test   %eax,%eax
  802469:	78 11                	js     80247c <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  80246b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80246e:	8b 15 44 40 80 00    	mov    0x804044,%edx
  802474:	39 10                	cmp    %edx,(%eax)
  802476:	0f 94 c0             	sete   %al
  802479:	0f b6 c0             	movzbl %al,%eax
}
  80247c:	c9                   	leave  
  80247d:	c3                   	ret    

0080247e <opencons>:

int
opencons(void)
{
  80247e:	55                   	push   %ebp
  80247f:	89 e5                	mov    %esp,%ebp
  802481:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802484:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802487:	50                   	push   %eax
  802488:	e8 f7 ec ff ff       	call   801184 <fd_alloc>
  80248d:	83 c4 10             	add    $0x10,%esp
  802490:	85 c0                	test   %eax,%eax
  802492:	78 3a                	js     8024ce <opencons+0x50>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802494:	83 ec 04             	sub    $0x4,%esp
  802497:	68 07 04 00 00       	push   $0x407
  80249c:	ff 75 f4             	pushl  -0xc(%ebp)
  80249f:	6a 00                	push   $0x0
  8024a1:	e8 5a e8 ff ff       	call   800d00 <sys_page_alloc>
  8024a6:	83 c4 10             	add    $0x10,%esp
  8024a9:	85 c0                	test   %eax,%eax
  8024ab:	78 21                	js     8024ce <opencons+0x50>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8024ad:	8b 15 44 40 80 00    	mov    0x804044,%edx
  8024b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8024b6:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8024b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8024bb:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8024c2:	83 ec 0c             	sub    $0xc,%esp
  8024c5:	50                   	push   %eax
  8024c6:	e8 91 ec ff ff       	call   80115c <fd2num>
  8024cb:	83 c4 10             	add    $0x10,%esp
}
  8024ce:	c9                   	leave  
  8024cf:	c3                   	ret    

008024d0 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  8024d0:	55                   	push   %ebp
  8024d1:	89 e5                	mov    %esp,%ebp
  8024d3:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  8024d6:	83 3d 00 70 80 00 00 	cmpl   $0x0,0x807000
  8024dd:	75 52                	jne    802531 <set_pgfault_handler+0x61>
		// First time through!	
		// LAB 4: Your code here.

		//int sys_page_alloc(envid_t envid, void *va, int perm)
		r = sys_page_alloc(0, (void*)(UXSTACKTOP - PGSIZE), PTE_U | PTE_W | PTE_P);
  8024df:	83 ec 04             	sub    $0x4,%esp
  8024e2:	6a 07                	push   $0x7
  8024e4:	68 00 f0 bf ee       	push   $0xeebff000
  8024e9:	6a 00                	push   $0x0
  8024eb:	e8 10 e8 ff ff       	call   800d00 <sys_page_alloc>
		if (r < 0) {
  8024f0:	83 c4 10             	add    $0x10,%esp
  8024f3:	85 c0                	test   %eax,%eax
  8024f5:	79 12                	jns    802509 <set_pgfault_handler+0x39>
			panic("sys_page_alloc error : %e\n", r);
  8024f7:	50                   	push   %eax
  8024f8:	68 63 30 80 00       	push   $0x803063
  8024fd:	6a 24                	push   $0x24
  8024ff:	68 7e 30 80 00       	push   $0x80307e
  802504:	e8 e7 dc ff ff       	call   8001f0 <_panic>
		}

		// how to know envid, put 0, envid2env will help us to get curenv in syscall
		r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);		
  802509:	83 ec 08             	sub    $0x8,%esp
  80250c:	68 3c 25 80 00       	push   $0x80253c
  802511:	6a 00                	push   $0x0
  802513:	e8 9b e8 ff ff       	call   800db3 <sys_env_set_pgfault_upcall>
		if (r < 0) {
  802518:	83 c4 10             	add    $0x10,%esp
  80251b:	85 c0                	test   %eax,%eax
  80251d:	79 12                	jns    802531 <set_pgfault_handler+0x61>
			panic("sys_env_set_pgfault_upcall error : %e\n", r);
  80251f:	50                   	push   %eax
  802520:	68 8c 30 80 00       	push   $0x80308c
  802525:	6a 2a                	push   $0x2a
  802527:	68 7e 30 80 00       	push   $0x80307e
  80252c:	e8 bf dc ff ff       	call   8001f0 <_panic>
		}
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  802531:	8b 45 08             	mov    0x8(%ebp),%eax
  802534:	a3 00 70 80 00       	mov    %eax,0x807000
}
  802539:	c9                   	leave  
  80253a:	c3                   	ret    
	...

0080253c <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  80253c:	54                   	push   %esp
	movl _pgfault_handler, %eax
  80253d:	a1 00 70 80 00       	mov    0x807000,%eax
	call *%eax
  802542:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  802544:	83 c4 04             	add    $0x4,%esp
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	
	// fix old esp
	movl 0x30(%esp), %eax
  802547:	8b 44 24 30          	mov    0x30(%esp),%eax
	subl $0x4, %eax
  80254b:	83 e8 04             	sub    $0x4,%eax
	movl %eax, 0x30(%esp)
  80254e:	89 44 24 30          	mov    %eax,0x30(%esp)

	// set trap-time %eip
	movl 0x28(%esp), %ebx
  802552:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	movl %ebx, (%eax)
  802556:	89 18                	mov    %ebx,(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $0x08, %esp 	// ignore err_code and fault_va
  802558:	83 c4 08             	add    $0x8,%esp
	popal 				// restore registers
  80255b:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x04, %esp 	// ignore eip 
  80255c:	83 c4 04             	add    $0x4,%esp
	popfl				// modify eflags
  80255f:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  802560:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  802561:	c3                   	ret    
	...

00802564 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802564:	55                   	push   %ebp
  802565:	89 e5                	mov    %esp,%ebp
  802567:	56                   	push   %esi
  802568:	53                   	push   %ebx
  802569:	8b 75 08             	mov    0x8(%ebp),%esi
  80256c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80256f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// cprintf("0x%x 0x%x 0x%x\n", (uint32_t)from_env_store, (uint32_t)pg, (uint32_t)perm_store);
	int r;
	if (pg != NULL) {
  802572:	85 c0                	test   %eax,%eax
  802574:	74 0e                	je     802584 <ipc_recv+0x20>
		r = sys_ipc_recv(pg);
  802576:	83 ec 0c             	sub    $0xc,%esp
  802579:	50                   	push   %eax
  80257a:	e8 7c e8 ff ff       	call   800dfb <sys_ipc_recv>
  80257f:	83 c4 10             	add    $0x10,%esp
  802582:	eb 10                	jmp    802594 <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv((void *)UTOP);
  802584:	83 ec 0c             	sub    $0xc,%esp
  802587:	68 00 00 c0 ee       	push   $0xeec00000
  80258c:	e8 6a e8 ff ff       	call   800dfb <sys_ipc_recv>
  802591:	83 c4 10             	add    $0x10,%esp
	}

	if (r == 0) {
  802594:	85 c0                	test   %eax,%eax
  802596:	75 26                	jne    8025be <ipc_recv+0x5a>
		if (from_env_store != NULL) *from_env_store = thisenv->env_ipc_from;
  802598:	85 f6                	test   %esi,%esi
  80259a:	74 0a                	je     8025a6 <ipc_recv+0x42>
  80259c:	a1 04 50 80 00       	mov    0x805004,%eax
  8025a1:	8b 40 74             	mov    0x74(%eax),%eax
  8025a4:	89 06                	mov    %eax,(%esi)
		if (perm_store != NULL) *perm_store = thisenv->env_ipc_perm;
  8025a6:	85 db                	test   %ebx,%ebx
  8025a8:	74 0a                	je     8025b4 <ipc_recv+0x50>
  8025aa:	a1 04 50 80 00       	mov    0x805004,%eax
  8025af:	8b 40 78             	mov    0x78(%eax),%eax
  8025b2:	89 03                	mov    %eax,(%ebx)
		return thisenv->env_ipc_value;
  8025b4:	a1 04 50 80 00       	mov    0x805004,%eax
  8025b9:	8b 40 70             	mov    0x70(%eax),%eax
  8025bc:	eb 14                	jmp    8025d2 <ipc_recv+0x6e>
	} else {
		// fails;
		if (from_env_store != NULL) *from_env_store = 0;
  8025be:	85 f6                	test   %esi,%esi
  8025c0:	74 06                	je     8025c8 <ipc_recv+0x64>
  8025c2:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if (perm_store != NULL) *perm_store = 0;
  8025c8:	85 db                	test   %ebx,%ebx
  8025ca:	74 06                	je     8025d2 <ipc_recv+0x6e>
  8025cc:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		return r;
	}
}
  8025d2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8025d5:	5b                   	pop    %ebx
  8025d6:	5e                   	pop    %esi
  8025d7:	c9                   	leave  
  8025d8:	c3                   	ret    

008025d9 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8025d9:	55                   	push   %ebp
  8025da:	89 e5                	mov    %esp,%ebp
  8025dc:	57                   	push   %edi
  8025dd:	56                   	push   %esi
  8025de:	53                   	push   %ebx
  8025df:	83 ec 0c             	sub    $0xc,%esp
  8025e2:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8025e5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8025e8:	8b 75 14             	mov    0x14(%ebp),%esi
	// LAB 4: Your code here.
	// int sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
	int r;
	if (pg == NULL) pg = (void *)UTOP;
  8025eb:	85 db                	test   %ebx,%ebx
  8025ed:	75 25                	jne    802614 <ipc_send+0x3b>
  8025ef:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
  8025f4:	eb 1e                	jmp    802614 <ipc_send+0x3b>
	
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) != 0) {
		if (r == -E_IPC_NOT_RECV) {
  8025f6:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8025f9:	75 07                	jne    802602 <ipc_send+0x29>
			// cprintf("Try Again and Again....\n");
			sys_yield();
  8025fb:	e8 d9 e6 ff ff       	call   800cd9 <sys_yield>
  802600:	eb 12                	jmp    802614 <ipc_send+0x3b>
		} else {
			panic("ipc_send error %e\n", r);
  802602:	50                   	push   %eax
  802603:	68 b4 30 80 00       	push   $0x8030b4
  802608:	6a 43                	push   $0x43
  80260a:	68 c7 30 80 00       	push   $0x8030c7
  80260f:	e8 dc db ff ff       	call   8001f0 <_panic>
	// LAB 4: Your code here.
	// int sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
	int r;
	if (pg == NULL) pg = (void *)UTOP;
	
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) != 0) {
  802614:	56                   	push   %esi
  802615:	53                   	push   %ebx
  802616:	57                   	push   %edi
  802617:	ff 75 08             	pushl  0x8(%ebp)
  80261a:	e8 b7 e7 ff ff       	call   800dd6 <sys_ipc_try_send>
  80261f:	83 c4 10             	add    $0x10,%esp
  802622:	85 c0                	test   %eax,%eax
  802624:	75 d0                	jne    8025f6 <ipc_send+0x1d>
		} else {
			panic("ipc_send error %e\n", r);
		}
	}
	return;
}
  802626:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802629:	5b                   	pop    %ebx
  80262a:	5e                   	pop    %esi
  80262b:	5f                   	pop    %edi
  80262c:	c9                   	leave  
  80262d:	c3                   	ret    

0080262e <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80262e:	55                   	push   %ebp
  80262f:	89 e5                	mov    %esp,%ebp
  802631:	53                   	push   %ebx
  802632:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  802635:	39 1d 50 00 c0 ee    	cmp    %ebx,0xeec00050
  80263b:	74 22                	je     80265f <ipc_find_env+0x31>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80263d:	b8 01 00 00 00       	mov    $0x1,%eax
		if (envs[i].env_type == type)
  802642:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  802649:	89 c2                	mov    %eax,%edx
  80264b:	c1 e2 07             	shl    $0x7,%edx
  80264e:	29 ca                	sub    %ecx,%edx
  802650:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802656:	8b 52 50             	mov    0x50(%edx),%edx
  802659:	39 da                	cmp    %ebx,%edx
  80265b:	75 1d                	jne    80267a <ipc_find_env+0x4c>
  80265d:	eb 05                	jmp    802664 <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80265f:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
			return envs[i].env_id;
  802664:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  80266b:	c1 e0 07             	shl    $0x7,%eax
  80266e:	29 d0                	sub    %edx,%eax
  802670:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  802675:	8b 40 40             	mov    0x40(%eax),%eax
  802678:	eb 0c                	jmp    802686 <ipc_find_env+0x58>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80267a:	40                   	inc    %eax
  80267b:	3d 00 04 00 00       	cmp    $0x400,%eax
  802680:	75 c0                	jne    802642 <ipc_find_env+0x14>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802682:	66 b8 00 00          	mov    $0x0,%ax
}
  802686:	5b                   	pop    %ebx
  802687:	c9                   	leave  
  802688:	c3                   	ret    
  802689:	00 00                	add    %al,(%eax)
	...

0080268c <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  80268c:	55                   	push   %ebp
  80268d:	89 e5                	mov    %esp,%ebp
  80268f:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802692:	89 c2                	mov    %eax,%edx
  802694:	c1 ea 16             	shr    $0x16,%edx
  802697:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80269e:	f6 c2 01             	test   $0x1,%dl
  8026a1:	74 1e                	je     8026c1 <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  8026a3:	c1 e8 0c             	shr    $0xc,%eax
  8026a6:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  8026ad:	a8 01                	test   $0x1,%al
  8026af:	74 17                	je     8026c8 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8026b1:	c1 e8 0c             	shr    $0xc,%eax
  8026b4:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  8026bb:	ef 
  8026bc:	0f b7 c0             	movzwl %ax,%eax
  8026bf:	eb 0c                	jmp    8026cd <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  8026c1:	b8 00 00 00 00       	mov    $0x0,%eax
  8026c6:	eb 05                	jmp    8026cd <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  8026c8:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  8026cd:	c9                   	leave  
  8026ce:	c3                   	ret    
	...

008026d0 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  8026d0:	55                   	push   %ebp
  8026d1:	89 e5                	mov    %esp,%ebp
  8026d3:	57                   	push   %edi
  8026d4:	56                   	push   %esi
  8026d5:	83 ec 10             	sub    $0x10,%esp
  8026d8:	8b 7d 08             	mov    0x8(%ebp),%edi
  8026db:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  8026de:	89 7d f0             	mov    %edi,-0x10(%ebp)
  8026e1:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  8026e4:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  8026e7:	8b 45 14             	mov    0x14(%ebp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  8026ea:	85 c0                	test   %eax,%eax
  8026ec:	75 2e                	jne    80271c <__udivdi3+0x4c>
    {
      if (d0 > n1)
  8026ee:	39 f1                	cmp    %esi,%ecx
  8026f0:	77 5a                	ja     80274c <__udivdi3+0x7c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  8026f2:	85 c9                	test   %ecx,%ecx
  8026f4:	75 0b                	jne    802701 <__udivdi3+0x31>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  8026f6:	b8 01 00 00 00       	mov    $0x1,%eax
  8026fb:	31 d2                	xor    %edx,%edx
  8026fd:	f7 f1                	div    %ecx
  8026ff:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  802701:	31 d2                	xor    %edx,%edx
  802703:	89 f0                	mov    %esi,%eax
  802705:	f7 f1                	div    %ecx
  802707:	89 c6                	mov    %eax,%esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802709:	89 f8                	mov    %edi,%eax
  80270b:	f7 f1                	div    %ecx
  80270d:	89 c7                	mov    %eax,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  80270f:	89 f8                	mov    %edi,%eax
  802711:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802713:	83 c4 10             	add    $0x10,%esp
  802716:	5e                   	pop    %esi
  802717:	5f                   	pop    %edi
  802718:	c9                   	leave  
  802719:	c3                   	ret    
  80271a:	66 90                	xchg   %ax,%ax
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  80271c:	39 f0                	cmp    %esi,%eax
  80271e:	77 1c                	ja     80273c <__udivdi3+0x6c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  802720:	0f bd f8             	bsr    %eax,%edi
	  if (bm == 0)
  802723:	83 f7 1f             	xor    $0x1f,%edi
  802726:	75 3c                	jne    802764 <__udivdi3+0x94>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802728:	39 f0                	cmp    %esi,%eax
  80272a:	0f 82 90 00 00 00    	jb     8027c0 <__udivdi3+0xf0>
  802730:	8b 55 f0             	mov    -0x10(%ebp),%edx
  802733:	39 55 f4             	cmp    %edx,-0xc(%ebp)
  802736:	0f 86 84 00 00 00    	jbe    8027c0 <__udivdi3+0xf0>
  80273c:	31 f6                	xor    %esi,%esi
  80273e:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  802740:	89 f8                	mov    %edi,%eax
  802742:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802744:	83 c4 10             	add    $0x10,%esp
  802747:	5e                   	pop    %esi
  802748:	5f                   	pop    %edi
  802749:	c9                   	leave  
  80274a:	c3                   	ret    
  80274b:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  80274c:	89 f2                	mov    %esi,%edx
  80274e:	89 f8                	mov    %edi,%eax
  802750:	f7 f1                	div    %ecx
  802752:	89 c7                	mov    %eax,%edi
  802754:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  802756:	89 f8                	mov    %edi,%eax
  802758:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  80275a:	83 c4 10             	add    $0x10,%esp
  80275d:	5e                   	pop    %esi
  80275e:	5f                   	pop    %edi
  80275f:	c9                   	leave  
  802760:	c3                   	ret    
  802761:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  802764:	89 f9                	mov    %edi,%ecx
  802766:	d3 e0                	shl    %cl,%eax
  802768:	89 45 e8             	mov    %eax,-0x18(%ebp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  80276b:	b8 20 00 00 00       	mov    $0x20,%eax
  802770:	29 f8                	sub    %edi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  802772:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802775:	88 c1                	mov    %al,%cl
  802777:	d3 ea                	shr    %cl,%edx
  802779:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  80277c:	09 ca                	or     %ecx,%edx
  80277e:	89 55 ec             	mov    %edx,-0x14(%ebp)
	      d0 = d0 << bm;
  802781:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802784:	89 f9                	mov    %edi,%ecx
  802786:	d3 e2                	shl    %cl,%edx
  802788:	89 55 f4             	mov    %edx,-0xc(%ebp)
	      n2 = n1 >> b;
  80278b:	89 f2                	mov    %esi,%edx
  80278d:	88 c1                	mov    %al,%cl
  80278f:	d3 ea                	shr    %cl,%edx
  802791:	89 55 e8             	mov    %edx,-0x18(%ebp)
	      n1 = (n1 << bm) | (n0 >> b);
  802794:	89 f2                	mov    %esi,%edx
  802796:	89 f9                	mov    %edi,%ecx
  802798:	d3 e2                	shl    %cl,%edx
  80279a:	8b 75 f0             	mov    -0x10(%ebp),%esi
  80279d:	88 c1                	mov    %al,%cl
  80279f:	d3 ee                	shr    %cl,%esi
  8027a1:	09 d6                	or     %edx,%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  8027a3:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  8027a6:	89 f0                	mov    %esi,%eax
  8027a8:	89 ca                	mov    %ecx,%edx
  8027aa:	f7 75 ec             	divl   -0x14(%ebp)
  8027ad:	89 d1                	mov    %edx,%ecx
  8027af:	89 c6                	mov    %eax,%esi
	      umul_ppmm (m1, m0, q0, d0);
  8027b1:	f7 65 f4             	mull   -0xc(%ebp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8027b4:	39 d1                	cmp    %edx,%ecx
  8027b6:	72 28                	jb     8027e0 <__udivdi3+0x110>
  8027b8:	74 1a                	je     8027d4 <__udivdi3+0x104>
  8027ba:	89 f7                	mov    %esi,%edi
  8027bc:	31 f6                	xor    %esi,%esi
  8027be:	eb 80                	jmp    802740 <__udivdi3+0x70>
	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  8027c0:	31 f6                	xor    %esi,%esi
  8027c2:	bf 01 00 00 00       	mov    $0x1,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  8027c7:	89 f8                	mov    %edi,%eax
  8027c9:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  8027cb:	83 c4 10             	add    $0x10,%esp
  8027ce:	5e                   	pop    %esi
  8027cf:	5f                   	pop    %edi
  8027d0:	c9                   	leave  
  8027d1:	c3                   	ret    
  8027d2:	66 90                	xchg   %ax,%ax

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  8027d4:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8027d7:	89 f9                	mov    %edi,%ecx
  8027d9:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8027db:	39 c2                	cmp    %eax,%edx
  8027dd:	73 db                	jae    8027ba <__udivdi3+0xea>
  8027df:	90                   	nop
		{
		  q0--;
  8027e0:	8d 7e ff             	lea    -0x1(%esi),%edi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  8027e3:	31 f6                	xor    %esi,%esi
  8027e5:	e9 56 ff ff ff       	jmp    802740 <__udivdi3+0x70>
	...

008027ec <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  8027ec:	55                   	push   %ebp
  8027ed:	89 e5                	mov    %esp,%ebp
  8027ef:	57                   	push   %edi
  8027f0:	56                   	push   %esi
  8027f1:	83 ec 20             	sub    $0x20,%esp
  8027f4:	8b 45 08             	mov    0x8(%ebp),%eax
  8027f7:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  8027fa:	89 45 e8             	mov    %eax,-0x18(%ebp)
  8027fd:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  802800:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  802803:	8b 7d 14             	mov    0x14(%ebp),%edi
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  802806:	89 45 f0             	mov    %eax,-0x10(%ebp)
  n1 = nn.s.high;
  802809:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  80280b:	85 ff                	test   %edi,%edi
  80280d:	75 15                	jne    802824 <__umoddi3+0x38>
    {
      if (d0 > n1)
  80280f:	39 f1                	cmp    %esi,%ecx
  802811:	0f 86 99 00 00 00    	jbe    8028b0 <__umoddi3+0xc4>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802817:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  802819:	89 d0                	mov    %edx,%eax
  80281b:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  80281d:	83 c4 20             	add    $0x20,%esp
  802820:	5e                   	pop    %esi
  802821:	5f                   	pop    %edi
  802822:	c9                   	leave  
  802823:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  802824:	39 f7                	cmp    %esi,%edi
  802826:	0f 87 a4 00 00 00    	ja     8028d0 <__umoddi3+0xe4>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  80282c:	0f bd c7             	bsr    %edi,%eax
	  if (bm == 0)
  80282f:	83 f0 1f             	xor    $0x1f,%eax
  802832:	89 45 ec             	mov    %eax,-0x14(%ebp)
  802835:	0f 84 a1 00 00 00    	je     8028dc <__umoddi3+0xf0>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  80283b:	89 f8                	mov    %edi,%eax
  80283d:	8a 4d ec             	mov    -0x14(%ebp),%cl
  802840:	d3 e0                	shl    %cl,%eax
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  802842:	bf 20 00 00 00       	mov    $0x20,%edi
  802847:	2b 7d ec             	sub    -0x14(%ebp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  80284a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80284d:	89 f9                	mov    %edi,%ecx
  80284f:	d3 ea                	shr    %cl,%edx
  802851:	09 c2                	or     %eax,%edx
  802853:	89 55 f0             	mov    %edx,-0x10(%ebp)
	      d0 = d0 << bm;
  802856:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802859:	8a 4d ec             	mov    -0x14(%ebp),%cl
  80285c:	d3 e0                	shl    %cl,%eax
  80285e:	89 45 f4             	mov    %eax,-0xc(%ebp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  802861:	89 f2                	mov    %esi,%edx
  802863:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  802865:	8b 45 e8             	mov    -0x18(%ebp),%eax
  802868:	d3 e0                	shl    %cl,%eax
  80286a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  80286d:	8b 45 e8             	mov    -0x18(%ebp),%eax
  802870:	89 f9                	mov    %edi,%ecx
  802872:	d3 e8                	shr    %cl,%eax
  802874:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  802876:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  802878:	89 f2                	mov    %esi,%edx
  80287a:	f7 75 f0             	divl   -0x10(%ebp)
  80287d:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  80287f:	f7 65 f4             	mull   -0xc(%ebp)
  802882:	89 55 e8             	mov    %edx,-0x18(%ebp)
  802885:	89 c1                	mov    %eax,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802887:	39 d6                	cmp    %edx,%esi
  802889:	72 71                	jb     8028fc <__umoddi3+0x110>
  80288b:	74 7f                	je     80290c <__umoddi3+0x120>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  80288d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802890:	29 c8                	sub    %ecx,%eax
  802892:	19 d6                	sbb    %edx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  802894:	8a 4d ec             	mov    -0x14(%ebp),%cl
  802897:	d3 e8                	shr    %cl,%eax
  802899:	89 f2                	mov    %esi,%edx
  80289b:	89 f9                	mov    %edi,%ecx
  80289d:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  80289f:	09 d0                	or     %edx,%eax
  8028a1:	89 f2                	mov    %esi,%edx
  8028a3:	8a 4d ec             	mov    -0x14(%ebp),%cl
  8028a6:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8028a8:	83 c4 20             	add    $0x20,%esp
  8028ab:	5e                   	pop    %esi
  8028ac:	5f                   	pop    %edi
  8028ad:	c9                   	leave  
  8028ae:	c3                   	ret    
  8028af:	90                   	nop
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  8028b0:	85 c9                	test   %ecx,%ecx
  8028b2:	75 0b                	jne    8028bf <__umoddi3+0xd3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  8028b4:	b8 01 00 00 00       	mov    $0x1,%eax
  8028b9:	31 d2                	xor    %edx,%edx
  8028bb:	f7 f1                	div    %ecx
  8028bd:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  8028bf:	89 f0                	mov    %esi,%eax
  8028c1:	31 d2                	xor    %edx,%edx
  8028c3:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8028c5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8028c8:	f7 f1                	div    %ecx
  8028ca:	e9 4a ff ff ff       	jmp    802819 <__umoddi3+0x2d>
  8028cf:	90                   	nop
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  8028d0:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8028d2:	83 c4 20             	add    $0x20,%esp
  8028d5:	5e                   	pop    %esi
  8028d6:	5f                   	pop    %edi
  8028d7:	c9                   	leave  
  8028d8:	c3                   	ret    
  8028d9:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  8028dc:	39 f7                	cmp    %esi,%edi
  8028de:	72 05                	jb     8028e5 <__umoddi3+0xf9>
  8028e0:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
  8028e3:	77 0c                	ja     8028f1 <__umoddi3+0x105>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  8028e5:	89 f2                	mov    %esi,%edx
  8028e7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8028ea:	29 c8                	sub    %ecx,%eax
  8028ec:	19 fa                	sbb    %edi,%edx
  8028ee:	89 45 f0             	mov    %eax,-0x10(%ebp)

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  8028f1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8028f4:	83 c4 20             	add    $0x20,%esp
  8028f7:	5e                   	pop    %esi
  8028f8:	5f                   	pop    %edi
  8028f9:	c9                   	leave  
  8028fa:	c3                   	ret    
  8028fb:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  8028fc:	8b 55 e8             	mov    -0x18(%ebp),%edx
  8028ff:	89 c1                	mov    %eax,%ecx
  802901:	2b 4d f4             	sub    -0xc(%ebp),%ecx
  802904:	1b 55 f0             	sbb    -0x10(%ebp),%edx
  802907:	eb 84                	jmp    80288d <__umoddi3+0xa1>
  802909:	8d 76 00             	lea    0x0(%esi),%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  80290c:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  80290f:	72 eb                	jb     8028fc <__umoddi3+0x110>
  802911:	89 f2                	mov    %esi,%edx
  802913:	e9 75 ff ff ff       	jmp    80288d <__umoddi3+0xa1>
