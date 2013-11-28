
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
  800082:	68 8c 2b 80 00       	push   $0x802b8c
  800087:	6a 13                	push   $0x13
  800089:	68 9f 2b 80 00       	push   $0x802b9f
  80008e:	e8 5d 01 00 00       	call   8001f0 <_panic>

	// check fork
	if ((r = fork()) < 0)
  800093:	e8 a2 0e 00 00       	call   800f3a <fork>
  800098:	89 c3                	mov    %eax,%ebx
  80009a:	85 c0                	test   %eax,%eax
  80009c:	79 12                	jns    8000b0 <umain+0x5c>
		panic("fork: %e", r);
  80009e:	50                   	push   %eax
  80009f:	68 b3 2b 80 00       	push   $0x802bb3
  8000a4:	6a 17                	push   $0x17
  8000a6:	68 9f 2b 80 00       	push   $0x802b9f
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
  8000d3:	e8 34 24 00 00       	call   80250c <wait>
	cprintf("fork handles PTE_SHARE %s\n", strcmp(VA, msg) == 0 ? "right" : "wrong");
  8000d8:	83 c4 08             	add    $0x8,%esp
  8000db:	ff 35 00 40 80 00    	pushl  0x804000
  8000e1:	68 00 00 00 a0       	push   $0xa0000000
  8000e6:	e8 4c 08 00 00       	call   800937 <strcmp>
  8000eb:	83 c4 10             	add    $0x10,%esp
  8000ee:	85 c0                	test   %eax,%eax
  8000f0:	75 07                	jne    8000f9 <umain+0xa5>
  8000f2:	b8 80 2b 80 00       	mov    $0x802b80,%eax
  8000f7:	eb 05                	jmp    8000fe <umain+0xaa>
  8000f9:	b8 86 2b 80 00       	mov    $0x802b86,%eax
  8000fe:	83 ec 08             	sub    $0x8,%esp
  800101:	50                   	push   %eax
  800102:	68 bc 2b 80 00       	push   $0x802bbc
  800107:	e8 bc 01 00 00       	call   8002c8 <cprintf>

	// check spawn
	if ((r = spawnl("/testpteshare", "testpteshare", "arg", 0)) < 0)
  80010c:	6a 00                	push   $0x0
  80010e:	68 d7 2b 80 00       	push   $0x802bd7
  800113:	68 dc 2b 80 00       	push   $0x802bdc
  800118:	68 db 2b 80 00       	push   $0x802bdb
  80011d:	e8 ee 1f 00 00       	call   802110 <spawnl>
  800122:	83 c4 20             	add    $0x20,%esp
  800125:	85 c0                	test   %eax,%eax
  800127:	79 12                	jns    80013b <umain+0xe7>
		panic("spawn: %e", r);
  800129:	50                   	push   %eax
  80012a:	68 e9 2b 80 00       	push   $0x802be9
  80012f:	6a 21                	push   $0x21
  800131:	68 9f 2b 80 00       	push   $0x802b9f
  800136:	e8 b5 00 00 00       	call   8001f0 <_panic>
	wait(r);
  80013b:	83 ec 0c             	sub    $0xc,%esp
  80013e:	50                   	push   %eax
  80013f:	e8 c8 23 00 00       	call   80250c <wait>
	cprintf("spawn handles PTE_SHARE %s\n", strcmp(VA, msg2) == 0 ? "right" : "wrong");
  800144:	83 c4 08             	add    $0x8,%esp
  800147:	ff 35 04 40 80 00    	pushl  0x804004
  80014d:	68 00 00 00 a0       	push   $0xa0000000
  800152:	e8 e0 07 00 00       	call   800937 <strcmp>
  800157:	83 c4 10             	add    $0x10,%esp
  80015a:	85 c0                	test   %eax,%eax
  80015c:	75 07                	jne    800165 <umain+0x111>
  80015e:	b8 80 2b 80 00       	mov    $0x802b80,%eax
  800163:	eb 05                	jmp    80016a <umain+0x116>
  800165:	b8 86 2b 80 00       	mov    $0x802b86,%eax
  80016a:	83 ec 08             	sub    $0x8,%esp
  80016d:	50                   	push   %eax
  80016e:	68 f3 2b 80 00       	push   $0x802bf3
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
  8001da:	e8 af 11 00 00       	call   80138e <close_all>
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
  80020e:	68 38 2c 80 00       	push   $0x802c38
  800213:	e8 b0 00 00 00       	call   8002c8 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800218:	83 c4 18             	add    $0x18,%esp
  80021b:	56                   	push   %esi
  80021c:	ff 75 10             	pushl  0x10(%ebp)
  80021f:	e8 53 00 00 00       	call   800277 <vcprintf>
	cprintf("\n");
  800224:	c7 04 24 9a 32 80 00 	movl   $0x80329a,(%esp)
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
  800330:	e8 ef 25 00 00       	call   802924 <__udivdi3>
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
  80036c:	e8 cf 26 00 00       	call   802a40 <__umoddi3>
  800371:	83 c4 14             	add    $0x14,%esp
  800374:	0f be 80 5b 2c 80 00 	movsbl 0x802c5b(%eax),%eax
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
  8004b8:	ff 24 85 a0 2d 80 00 	jmp    *0x802da0(,%eax,4)
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
  800564:	8b 04 85 00 2f 80 00 	mov    0x802f00(,%eax,4),%eax
  80056b:	85 c0                	test   %eax,%eax
  80056d:	75 1a                	jne    800589 <vprintfmt+0x15c>
				printfmt(putch, putdat, "error %d", err);
  80056f:	52                   	push   %edx
  800570:	68 73 2c 80 00       	push   $0x802c73
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
  80058a:	68 b5 31 80 00       	push   $0x8031b5
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
  8005c0:	c7 45 d0 6c 2c 80 00 	movl   $0x802c6c,-0x30(%ebp)
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
  800c2e:	68 5f 2f 80 00       	push   $0x802f5f
  800c33:	6a 42                	push   $0x42
  800c35:	68 7c 2f 80 00       	push   $0x802f7c
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
  800e63:	c9                   	leave  
  800e64:	c3                   	ret    
  800e65:	00 00                	add    %al,(%eax)
	...

00800e68 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800e68:	55                   	push   %ebp
  800e69:	89 e5                	mov    %esp,%ebp
  800e6b:	53                   	push   %ebx
  800e6c:	83 ec 04             	sub    $0x4,%esp
  800e6f:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800e72:	8b 18                	mov    (%eax),%ebx

	// LAB 4: Your code here.
	
	// cprintf("PAGE FAULT HANDLER, 0x%08x %d\n", (uint32_t)addr, err & FEC_WR);
	
	if ((err & FEC_WR) == 0)
  800e74:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800e78:	75 14                	jne    800e8e <pgfault+0x26>
		panic("pgfault, the fault is not a write\n");
  800e7a:	83 ec 04             	sub    $0x4,%esp
  800e7d:	68 8c 2f 80 00       	push   $0x802f8c
  800e82:	6a 20                	push   $0x20
  800e84:	68 d0 30 80 00       	push   $0x8030d0
  800e89:	e8 62 f3 ff ff       	call   8001f0 <_panic>

	uint32_t uaddr = (uint32_t) addr;
	if ((uvpd[PDX(addr)] & PTE_P) == 0 || (uvpt[uaddr / PGSIZE] & PTE_COW) == 0) {
  800e8e:	89 d8                	mov    %ebx,%eax
  800e90:	c1 e8 16             	shr    $0x16,%eax
  800e93:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800e9a:	a8 01                	test   $0x1,%al
  800e9c:	74 11                	je     800eaf <pgfault+0x47>
  800e9e:	89 d8                	mov    %ebx,%eax
  800ea0:	c1 e8 0c             	shr    $0xc,%eax
  800ea3:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800eaa:	f6 c4 08             	test   $0x8,%ah
  800ead:	75 14                	jne    800ec3 <pgfault+0x5b>
		panic("pgfault, not a copy-on-write page\n");
  800eaf:	83 ec 04             	sub    $0x4,%esp
  800eb2:	68 b0 2f 80 00       	push   $0x802fb0
  800eb7:	6a 24                	push   $0x24
  800eb9:	68 d0 30 80 00       	push   $0x8030d0
  800ebe:	e8 2d f3 ff ff       	call   8001f0 <_panic>
	//   No need to explicitly delete the old page's mapping.

	// LAB 4: Your code here.

	// static int sys_page_alloc(envid_t envid, void *va, int perm)
	r = sys_page_alloc(0, (void *)PFTEMP, PTE_W | PTE_U | PTE_P);
  800ec3:	83 ec 04             	sub    $0x4,%esp
  800ec6:	6a 07                	push   $0x7
  800ec8:	68 00 f0 7f 00       	push   $0x7ff000
  800ecd:	6a 00                	push   $0x0
  800ecf:	e8 2c fe ff ff       	call   800d00 <sys_page_alloc>
	if (r < 0) panic("pgfault, sys_page_alloc error : %e\n", r);
  800ed4:	83 c4 10             	add    $0x10,%esp
  800ed7:	85 c0                	test   %eax,%eax
  800ed9:	79 12                	jns    800eed <pgfault+0x85>
  800edb:	50                   	push   %eax
  800edc:	68 d4 2f 80 00       	push   $0x802fd4
  800ee1:	6a 32                	push   $0x32
  800ee3:	68 d0 30 80 00       	push   $0x8030d0
  800ee8:	e8 03 f3 ff ff       	call   8001f0 <_panic>

	// Oh my god, I forget this at the first, it waste me a lot of time to debug!!!
	addr = ROUNDDOWN(addr, PGSIZE);
  800eed:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	
	memcpy(PFTEMP, addr, PGSIZE);
  800ef3:	83 ec 04             	sub    $0x4,%esp
  800ef6:	68 00 10 00 00       	push   $0x1000
  800efb:	53                   	push   %ebx
  800efc:	68 00 f0 7f 00       	push   $0x7ff000
  800f01:	e8 a3 fb ff ff       	call   800aa9 <memcpy>
	
	r = sys_page_map(0, PFTEMP, 0, addr, PTE_W | PTE_U | PTE_P);
  800f06:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800f0d:	53                   	push   %ebx
  800f0e:	6a 00                	push   $0x0
  800f10:	68 00 f0 7f 00       	push   $0x7ff000
  800f15:	6a 00                	push   $0x0
  800f17:	e8 08 fe ff ff       	call   800d24 <sys_page_map>
	if (r < 0) panic("pgfault, sys_page_map error : %e\n", r);
  800f1c:	83 c4 20             	add    $0x20,%esp
  800f1f:	85 c0                	test   %eax,%eax
  800f21:	79 12                	jns    800f35 <pgfault+0xcd>
  800f23:	50                   	push   %eax
  800f24:	68 f8 2f 80 00       	push   $0x802ff8
  800f29:	6a 3a                	push   $0x3a
  800f2b:	68 d0 30 80 00       	push   $0x8030d0
  800f30:	e8 bb f2 ff ff       	call   8001f0 <_panic>

	return;
}
  800f35:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f38:	c9                   	leave  
  800f39:	c3                   	ret    

00800f3a <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800f3a:	55                   	push   %ebp
  800f3b:	89 e5                	mov    %esp,%ebp
  800f3d:	57                   	push   %edi
  800f3e:	56                   	push   %esi
  800f3f:	53                   	push   %ebx
  800f40:	83 ec 28             	sub    $0x28,%esp
	// static int num = 0x100;

	// LAB 4: Your code here.
	set_pgfault_handler(pgfault);
  800f43:	68 68 0e 80 00       	push   $0x800e68
  800f48:	e8 d7 17 00 00       	call   802724 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  800f4d:	ba 07 00 00 00       	mov    $0x7,%edx
  800f52:	89 d0                	mov    %edx,%eax
  800f54:	cd 30                	int    $0x30
  800f56:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800f59:	89 c7                	mov    %eax,%edi
	int childpid = sys_exofork();
	if (childpid < 0) {
  800f5b:	83 c4 10             	add    $0x10,%esp
  800f5e:	85 c0                	test   %eax,%eax
  800f60:	79 12                	jns    800f74 <fork+0x3a>
		panic("fork sys_exofork error : %e\n", childpid);
  800f62:	50                   	push   %eax
  800f63:	68 db 30 80 00       	push   $0x8030db
  800f68:	6a 7f                	push   $0x7f
  800f6a:	68 d0 30 80 00       	push   $0x8030d0
  800f6f:	e8 7c f2 ff ff       	call   8001f0 <_panic>
	}
	int r;

	if (childpid == 0) {
  800f74:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800f78:	75 25                	jne    800f9f <fork+0x65>
		// child process
		// Remember to fix "thisenv" in the child process. ??? 
		thisenv = &envs[ENVX(sys_getenvid())];
  800f7a:	e8 36 fd ff ff       	call   800cb5 <sys_getenvid>
  800f7f:	25 ff 03 00 00       	and    $0x3ff,%eax
  800f84:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800f8b:	c1 e0 07             	shl    $0x7,%eax
  800f8e:	29 d0                	sub    %edx,%eax
  800f90:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800f95:	a3 04 50 80 00       	mov    %eax,0x805004
		// cprintf("fork child ok\n");
		return 0;
  800f9a:	e9 be 01 00 00       	jmp    80115d <fork+0x223>
	if (childpid < 0) {
		panic("fork sys_exofork error : %e\n", childpid);
	}
	int r;

	if (childpid == 0) {
  800f9f:	bb 00 00 00 00       	mov    $0x0,%ebx
	} else {
		// map page to new environment
		// kernel page is already in new environment
		uint32_t i;
		for (i = 0; i != UTOP; i += PGSIZE) 
		if ((uvpd[PDX(i)] & PTE_P) && (uvpt[i / PGSIZE] & PTE_P) && (uvpt[i / PGSIZE] & PTE_U)) {
  800fa4:	89 d8                	mov    %ebx,%eax
  800fa6:	c1 e8 16             	shr    $0x16,%eax
  800fa9:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800fb0:	a8 01                	test   $0x1,%al
  800fb2:	0f 84 10 01 00 00    	je     8010c8 <fork+0x18e>
  800fb8:	89 d8                	mov    %ebx,%eax
  800fba:	c1 e8 0c             	shr    $0xc,%eax
  800fbd:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800fc4:	f6 c2 01             	test   $0x1,%dl
  800fc7:	0f 84 fb 00 00 00    	je     8010c8 <fork+0x18e>
  800fcd:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800fd4:	f6 c2 04             	test   $0x4,%dl
  800fd7:	0f 84 eb 00 00 00    	je     8010c8 <fork+0x18e>
//
static int
duppage(envid_t envid, unsigned pn)
{
	// do not dup exception stack
	if (pn * PGSIZE == UXSTACKTOP - PGSIZE) return 0;
  800fdd:	89 c6                	mov    %eax,%esi
  800fdf:	c1 e6 0c             	shl    $0xc,%esi
  800fe2:	81 fe 00 f0 bf ee    	cmp    $0xeebff000,%esi
  800fe8:	0f 84 da 00 00 00    	je     8010c8 <fork+0x18e>

	int r;
	void * addr = (void *)(pn * PGSIZE);
    if (uvpt[pn] & PTE_SHARE) {
  800fee:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800ff5:	f6 c6 04             	test   $0x4,%dh
  800ff8:	74 37                	je     801031 <fork+0xf7>
        r = sys_page_map(0, addr, envid, addr, uvpt[pn] & PTE_SYSCALL);
  800ffa:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801001:	83 ec 0c             	sub    $0xc,%esp
  801004:	25 07 0e 00 00       	and    $0xe07,%eax
  801009:	50                   	push   %eax
  80100a:	56                   	push   %esi
  80100b:	57                   	push   %edi
  80100c:	56                   	push   %esi
  80100d:	6a 00                	push   $0x0
  80100f:	e8 10 fd ff ff       	call   800d24 <sys_page_map>
        if (r < 0) panic("duppage sys_page_map error : %e\n", r);
  801014:	83 c4 20             	add    $0x20,%esp
  801017:	85 c0                	test   %eax,%eax
  801019:	0f 89 a9 00 00 00    	jns    8010c8 <fork+0x18e>
  80101f:	50                   	push   %eax
  801020:	68 1c 30 80 00       	push   $0x80301c
  801025:	6a 54                	push   $0x54
  801027:	68 d0 30 80 00       	push   $0x8030d0
  80102c:	e8 bf f1 ff ff       	call   8001f0 <_panic>
    } else
	if ((uvpt[pn] & PTE_W) || (uvpt[pn] & PTE_COW)) {
  801031:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801038:	f6 c2 02             	test   $0x2,%dl
  80103b:	75 0c                	jne    801049 <fork+0x10f>
  80103d:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801044:	f6 c4 08             	test   $0x8,%ah
  801047:	74 57                	je     8010a0 <fork+0x166>
		// cow
		r = sys_page_map(0, addr, envid, addr, PTE_COW | PTE_P | PTE_U);
  801049:	83 ec 0c             	sub    $0xc,%esp
  80104c:	68 05 08 00 00       	push   $0x805
  801051:	56                   	push   %esi
  801052:	57                   	push   %edi
  801053:	56                   	push   %esi
  801054:	6a 00                	push   $0x0
  801056:	e8 c9 fc ff ff       	call   800d24 <sys_page_map>
		if (r < 0) panic("duppage sys_page_map error : %e\n", r);
  80105b:	83 c4 20             	add    $0x20,%esp
  80105e:	85 c0                	test   %eax,%eax
  801060:	79 12                	jns    801074 <fork+0x13a>
  801062:	50                   	push   %eax
  801063:	68 1c 30 80 00       	push   $0x80301c
  801068:	6a 59                	push   $0x59
  80106a:	68 d0 30 80 00       	push   $0x8030d0
  80106f:	e8 7c f1 ff ff       	call   8001f0 <_panic>
		
		r = sys_page_map(0, addr, 0, addr, PTE_COW | PTE_P | PTE_U);
  801074:	83 ec 0c             	sub    $0xc,%esp
  801077:	68 05 08 00 00       	push   $0x805
  80107c:	56                   	push   %esi
  80107d:	6a 00                	push   $0x0
  80107f:	56                   	push   %esi
  801080:	6a 00                	push   $0x0
  801082:	e8 9d fc ff ff       	call   800d24 <sys_page_map>
		if (r < 0) panic("duppage sys_page_map error : %e\n", r);
  801087:	83 c4 20             	add    $0x20,%esp
  80108a:	85 c0                	test   %eax,%eax
  80108c:	79 3a                	jns    8010c8 <fork+0x18e>
  80108e:	50                   	push   %eax
  80108f:	68 1c 30 80 00       	push   $0x80301c
  801094:	6a 5c                	push   $0x5c
  801096:	68 d0 30 80 00       	push   $0x8030d0
  80109b:	e8 50 f1 ff ff       	call   8001f0 <_panic>
	} else {
		// read only
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U);
  8010a0:	83 ec 0c             	sub    $0xc,%esp
  8010a3:	6a 05                	push   $0x5
  8010a5:	56                   	push   %esi
  8010a6:	57                   	push   %edi
  8010a7:	56                   	push   %esi
  8010a8:	6a 00                	push   $0x0
  8010aa:	e8 75 fc ff ff       	call   800d24 <sys_page_map>
		if (r < 0) panic("duppage sys_page_map error : %e\n", r);
  8010af:	83 c4 20             	add    $0x20,%esp
  8010b2:	85 c0                	test   %eax,%eax
  8010b4:	79 12                	jns    8010c8 <fork+0x18e>
  8010b6:	50                   	push   %eax
  8010b7:	68 1c 30 80 00       	push   $0x80301c
  8010bc:	6a 60                	push   $0x60
  8010be:	68 d0 30 80 00       	push   $0x8030d0
  8010c3:	e8 28 f1 ff ff       	call   8001f0 <_panic>
		return 0;
	} else {
		// map page to new environment
		// kernel page is already in new environment
		uint32_t i;
		for (i = 0; i != UTOP; i += PGSIZE) 
  8010c8:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  8010ce:	81 fb 00 00 c0 ee    	cmp    $0xeec00000,%ebx
  8010d4:	0f 85 ca fe ff ff    	jne    800fa4 <fork+0x6a>
		if ((uvpd[PDX(i)] & PTE_P) && (uvpt[i / PGSIZE] & PTE_P) && (uvpt[i / PGSIZE] & PTE_U)) {
			duppage(childpid, i / PGSIZE);
		}

		// allocate exception stack
		r = sys_page_alloc(childpid, (void *)(UXSTACKTOP - PGSIZE), PTE_U | PTE_W | PTE_P);
  8010da:	83 ec 04             	sub    $0x4,%esp
  8010dd:	6a 07                	push   $0x7
  8010df:	68 00 f0 bf ee       	push   $0xeebff000
  8010e4:	ff 75 e4             	pushl  -0x1c(%ebp)
  8010e7:	e8 14 fc ff ff       	call   800d00 <sys_page_alloc>
		if (r < 0) panic("fork, sys_page_alloc user exception stack error : %e\n", r);
  8010ec:	83 c4 10             	add    $0x10,%esp
  8010ef:	85 c0                	test   %eax,%eax
  8010f1:	79 15                	jns    801108 <fork+0x1ce>
  8010f3:	50                   	push   %eax
  8010f4:	68 40 30 80 00       	push   $0x803040
  8010f9:	68 94 00 00 00       	push   $0x94
  8010fe:	68 d0 30 80 00       	push   $0x8030d0
  801103:	e8 e8 f0 ff ff       	call   8001f0 <_panic>

		// set user environment user page fault handler 
		extern void _pgfault_upcall(void);
		r = sys_env_set_pgfault_upcall(childpid, _pgfault_upcall);
  801108:	83 ec 08             	sub    $0x8,%esp
  80110b:	68 90 27 80 00       	push   $0x802790
  801110:	ff 75 e4             	pushl  -0x1c(%ebp)
  801113:	e8 9b fc ff ff       	call   800db3 <sys_env_set_pgfault_upcall>
		if (r < 0) panic("fork, set pgfault upcall fail : %e\n", r);
  801118:	83 c4 10             	add    $0x10,%esp
  80111b:	85 c0                	test   %eax,%eax
  80111d:	79 15                	jns    801134 <fork+0x1fa>
  80111f:	50                   	push   %eax
  801120:	68 78 30 80 00       	push   $0x803078
  801125:	68 99 00 00 00       	push   $0x99
  80112a:	68 d0 30 80 00       	push   $0x8030d0
  80112f:	e8 bc f0 ff ff       	call   8001f0 <_panic>
		r = sys_set_priority(childpid, num);
		if (r < 0) panic("fork, set priority error\n");
		*/

		// mark the child as runnable and return
		r = sys_env_set_status(childpid, ENV_RUNNABLE);
  801134:	83 ec 08             	sub    $0x8,%esp
  801137:	6a 02                	push   $0x2
  801139:	ff 75 e4             	pushl  -0x1c(%ebp)
  80113c:	e8 2c fc ff ff       	call   800d6d <sys_env_set_status>
		if (r < 0) panic("fork, set child process to ENV_RUNNABLE error : %e\n", r);
  801141:	83 c4 10             	add    $0x10,%esp
  801144:	85 c0                	test   %eax,%eax
  801146:	79 15                	jns    80115d <fork+0x223>
  801148:	50                   	push   %eax
  801149:	68 9c 30 80 00       	push   $0x80309c
  80114e:	68 a4 00 00 00       	push   $0xa4
  801153:	68 d0 30 80 00       	push   $0x8030d0
  801158:	e8 93 f0 ff ff       	call   8001f0 <_panic>
		// cprintf("fork father ok!")
		return childpid;
	}

	panic("fork not implemented");
}
  80115d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801160:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801163:	5b                   	pop    %ebx
  801164:	5e                   	pop    %esi
  801165:	5f                   	pop    %edi
  801166:	c9                   	leave  
  801167:	c3                   	ret    

00801168 <sfork>:

// Challenge!
int
sfork(void)
{
  801168:	55                   	push   %ebp
  801169:	89 e5                	mov    %esp,%ebp
  80116b:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  80116e:	68 f8 30 80 00       	push   $0x8030f8
  801173:	68 b1 00 00 00       	push   $0xb1
  801178:	68 d0 30 80 00       	push   $0x8030d0
  80117d:	e8 6e f0 ff ff       	call   8001f0 <_panic>
	...

00801184 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801184:	55                   	push   %ebp
  801185:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801187:	8b 45 08             	mov    0x8(%ebp),%eax
  80118a:	05 00 00 00 30       	add    $0x30000000,%eax
  80118f:	c1 e8 0c             	shr    $0xc,%eax
}
  801192:	c9                   	leave  
  801193:	c3                   	ret    

00801194 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801194:	55                   	push   %ebp
  801195:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  801197:	ff 75 08             	pushl  0x8(%ebp)
  80119a:	e8 e5 ff ff ff       	call   801184 <fd2num>
  80119f:	83 c4 04             	add    $0x4,%esp
  8011a2:	05 20 00 0d 00       	add    $0xd0020,%eax
  8011a7:	c1 e0 0c             	shl    $0xc,%eax
}
  8011aa:	c9                   	leave  
  8011ab:	c3                   	ret    

008011ac <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8011ac:	55                   	push   %ebp
  8011ad:	89 e5                	mov    %esp,%ebp
  8011af:	53                   	push   %ebx
  8011b0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8011b3:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  8011b8:	a8 01                	test   $0x1,%al
  8011ba:	74 34                	je     8011f0 <fd_alloc+0x44>
  8011bc:	a1 00 00 74 ef       	mov    0xef740000,%eax
  8011c1:	a8 01                	test   $0x1,%al
  8011c3:	74 32                	je     8011f7 <fd_alloc+0x4b>
  8011c5:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
  8011ca:	89 c1                	mov    %eax,%ecx
  8011cc:	89 c2                	mov    %eax,%edx
  8011ce:	c1 ea 16             	shr    $0x16,%edx
  8011d1:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8011d8:	f6 c2 01             	test   $0x1,%dl
  8011db:	74 1f                	je     8011fc <fd_alloc+0x50>
  8011dd:	89 c2                	mov    %eax,%edx
  8011df:	c1 ea 0c             	shr    $0xc,%edx
  8011e2:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8011e9:	f6 c2 01             	test   $0x1,%dl
  8011ec:	75 17                	jne    801205 <fd_alloc+0x59>
  8011ee:	eb 0c                	jmp    8011fc <fd_alloc+0x50>
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  8011f0:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
  8011f5:	eb 05                	jmp    8011fc <fd_alloc+0x50>
  8011f7:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
  8011fc:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  8011fe:	b8 00 00 00 00       	mov    $0x0,%eax
  801203:	eb 17                	jmp    80121c <fd_alloc+0x70>
  801205:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  80120a:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80120f:	75 b9                	jne    8011ca <fd_alloc+0x1e>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801211:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  801217:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  80121c:	5b                   	pop    %ebx
  80121d:	c9                   	leave  
  80121e:	c3                   	ret    

0080121f <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80121f:	55                   	push   %ebp
  801220:	89 e5                	mov    %esp,%ebp
  801222:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801225:	83 f8 1f             	cmp    $0x1f,%eax
  801228:	77 36                	ja     801260 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80122a:	05 00 00 0d 00       	add    $0xd0000,%eax
  80122f:	c1 e0 0c             	shl    $0xc,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801232:	89 c2                	mov    %eax,%edx
  801234:	c1 ea 16             	shr    $0x16,%edx
  801237:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80123e:	f6 c2 01             	test   $0x1,%dl
  801241:	74 24                	je     801267 <fd_lookup+0x48>
  801243:	89 c2                	mov    %eax,%edx
  801245:	c1 ea 0c             	shr    $0xc,%edx
  801248:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80124f:	f6 c2 01             	test   $0x1,%dl
  801252:	74 1a                	je     80126e <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801254:	8b 55 0c             	mov    0xc(%ebp),%edx
  801257:	89 02                	mov    %eax,(%edx)
	return 0;
  801259:	b8 00 00 00 00       	mov    $0x0,%eax
  80125e:	eb 13                	jmp    801273 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801260:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801265:	eb 0c                	jmp    801273 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801267:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80126c:	eb 05                	jmp    801273 <fd_lookup+0x54>
  80126e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801273:	c9                   	leave  
  801274:	c3                   	ret    

00801275 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801275:	55                   	push   %ebp
  801276:	89 e5                	mov    %esp,%ebp
  801278:	53                   	push   %ebx
  801279:	83 ec 04             	sub    $0x4,%esp
  80127c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80127f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  801282:	39 0d 0c 40 80 00    	cmp    %ecx,0x80400c
  801288:	74 0d                	je     801297 <dev_lookup+0x22>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80128a:	b8 00 00 00 00       	mov    $0x0,%eax
  80128f:	eb 14                	jmp    8012a5 <dev_lookup+0x30>
		if (devtab[i]->dev_id == dev_id) {
  801291:	39 0a                	cmp    %ecx,(%edx)
  801293:	75 10                	jne    8012a5 <dev_lookup+0x30>
  801295:	eb 05                	jmp    80129c <dev_lookup+0x27>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801297:	ba 0c 40 80 00       	mov    $0x80400c,%edx
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
  80129c:	89 13                	mov    %edx,(%ebx)
			return 0;
  80129e:	b8 00 00 00 00       	mov    $0x0,%eax
  8012a3:	eb 31                	jmp    8012d6 <dev_lookup+0x61>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8012a5:	40                   	inc    %eax
  8012a6:	8b 14 85 8c 31 80 00 	mov    0x80318c(,%eax,4),%edx
  8012ad:	85 d2                	test   %edx,%edx
  8012af:	75 e0                	jne    801291 <dev_lookup+0x1c>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8012b1:	a1 04 50 80 00       	mov    0x805004,%eax
  8012b6:	8b 40 48             	mov    0x48(%eax),%eax
  8012b9:	83 ec 04             	sub    $0x4,%esp
  8012bc:	51                   	push   %ecx
  8012bd:	50                   	push   %eax
  8012be:	68 10 31 80 00       	push   $0x803110
  8012c3:	e8 00 f0 ff ff       	call   8002c8 <cprintf>
	*dev = 0;
  8012c8:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  8012ce:	83 c4 10             	add    $0x10,%esp
  8012d1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8012d6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012d9:	c9                   	leave  
  8012da:	c3                   	ret    

008012db <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8012db:	55                   	push   %ebp
  8012dc:	89 e5                	mov    %esp,%ebp
  8012de:	56                   	push   %esi
  8012df:	53                   	push   %ebx
  8012e0:	83 ec 20             	sub    $0x20,%esp
  8012e3:	8b 75 08             	mov    0x8(%ebp),%esi
  8012e6:	8a 45 0c             	mov    0xc(%ebp),%al
  8012e9:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8012ec:	56                   	push   %esi
  8012ed:	e8 92 fe ff ff       	call   801184 <fd2num>
  8012f2:	8d 55 f4             	lea    -0xc(%ebp),%edx
  8012f5:	89 14 24             	mov    %edx,(%esp)
  8012f8:	50                   	push   %eax
  8012f9:	e8 21 ff ff ff       	call   80121f <fd_lookup>
  8012fe:	89 c3                	mov    %eax,%ebx
  801300:	83 c4 08             	add    $0x8,%esp
  801303:	85 c0                	test   %eax,%eax
  801305:	78 05                	js     80130c <fd_close+0x31>
	    || fd != fd2)
  801307:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80130a:	74 0d                	je     801319 <fd_close+0x3e>
		return (must_exist ? r : 0);
  80130c:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  801310:	75 48                	jne    80135a <fd_close+0x7f>
  801312:	bb 00 00 00 00       	mov    $0x0,%ebx
  801317:	eb 41                	jmp    80135a <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801319:	83 ec 08             	sub    $0x8,%esp
  80131c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80131f:	50                   	push   %eax
  801320:	ff 36                	pushl  (%esi)
  801322:	e8 4e ff ff ff       	call   801275 <dev_lookup>
  801327:	89 c3                	mov    %eax,%ebx
  801329:	83 c4 10             	add    $0x10,%esp
  80132c:	85 c0                	test   %eax,%eax
  80132e:	78 1c                	js     80134c <fd_close+0x71>
		if (dev->dev_close)
  801330:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801333:	8b 40 10             	mov    0x10(%eax),%eax
  801336:	85 c0                	test   %eax,%eax
  801338:	74 0d                	je     801347 <fd_close+0x6c>
			r = (*dev->dev_close)(fd);
  80133a:	83 ec 0c             	sub    $0xc,%esp
  80133d:	56                   	push   %esi
  80133e:	ff d0                	call   *%eax
  801340:	89 c3                	mov    %eax,%ebx
  801342:	83 c4 10             	add    $0x10,%esp
  801345:	eb 05                	jmp    80134c <fd_close+0x71>
		else
			r = 0;
  801347:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  80134c:	83 ec 08             	sub    $0x8,%esp
  80134f:	56                   	push   %esi
  801350:	6a 00                	push   $0x0
  801352:	e8 f3 f9 ff ff       	call   800d4a <sys_page_unmap>
	return r;
  801357:	83 c4 10             	add    $0x10,%esp
}
  80135a:	89 d8                	mov    %ebx,%eax
  80135c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80135f:	5b                   	pop    %ebx
  801360:	5e                   	pop    %esi
  801361:	c9                   	leave  
  801362:	c3                   	ret    

00801363 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801363:	55                   	push   %ebp
  801364:	89 e5                	mov    %esp,%ebp
  801366:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801369:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80136c:	50                   	push   %eax
  80136d:	ff 75 08             	pushl  0x8(%ebp)
  801370:	e8 aa fe ff ff       	call   80121f <fd_lookup>
  801375:	83 c4 08             	add    $0x8,%esp
  801378:	85 c0                	test   %eax,%eax
  80137a:	78 10                	js     80138c <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  80137c:	83 ec 08             	sub    $0x8,%esp
  80137f:	6a 01                	push   $0x1
  801381:	ff 75 f4             	pushl  -0xc(%ebp)
  801384:	e8 52 ff ff ff       	call   8012db <fd_close>
  801389:	83 c4 10             	add    $0x10,%esp
}
  80138c:	c9                   	leave  
  80138d:	c3                   	ret    

0080138e <close_all>:

void
close_all(void)
{
  80138e:	55                   	push   %ebp
  80138f:	89 e5                	mov    %esp,%ebp
  801391:	53                   	push   %ebx
  801392:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801395:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80139a:	83 ec 0c             	sub    $0xc,%esp
  80139d:	53                   	push   %ebx
  80139e:	e8 c0 ff ff ff       	call   801363 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8013a3:	43                   	inc    %ebx
  8013a4:	83 c4 10             	add    $0x10,%esp
  8013a7:	83 fb 20             	cmp    $0x20,%ebx
  8013aa:	75 ee                	jne    80139a <close_all+0xc>
		close(i);
}
  8013ac:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013af:	c9                   	leave  
  8013b0:	c3                   	ret    

008013b1 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8013b1:	55                   	push   %ebp
  8013b2:	89 e5                	mov    %esp,%ebp
  8013b4:	57                   	push   %edi
  8013b5:	56                   	push   %esi
  8013b6:	53                   	push   %ebx
  8013b7:	83 ec 2c             	sub    $0x2c,%esp
  8013ba:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8013bd:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8013c0:	50                   	push   %eax
  8013c1:	ff 75 08             	pushl  0x8(%ebp)
  8013c4:	e8 56 fe ff ff       	call   80121f <fd_lookup>
  8013c9:	89 c3                	mov    %eax,%ebx
  8013cb:	83 c4 08             	add    $0x8,%esp
  8013ce:	85 c0                	test   %eax,%eax
  8013d0:	0f 88 c0 00 00 00    	js     801496 <dup+0xe5>
		return r;
	close(newfdnum);
  8013d6:	83 ec 0c             	sub    $0xc,%esp
  8013d9:	57                   	push   %edi
  8013da:	e8 84 ff ff ff       	call   801363 <close>

	newfd = INDEX2FD(newfdnum);
  8013df:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  8013e5:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  8013e8:	83 c4 04             	add    $0x4,%esp
  8013eb:	ff 75 e4             	pushl  -0x1c(%ebp)
  8013ee:	e8 a1 fd ff ff       	call   801194 <fd2data>
  8013f3:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  8013f5:	89 34 24             	mov    %esi,(%esp)
  8013f8:	e8 97 fd ff ff       	call   801194 <fd2data>
  8013fd:	83 c4 10             	add    $0x10,%esp
  801400:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801403:	89 d8                	mov    %ebx,%eax
  801405:	c1 e8 16             	shr    $0x16,%eax
  801408:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80140f:	a8 01                	test   $0x1,%al
  801411:	74 37                	je     80144a <dup+0x99>
  801413:	89 d8                	mov    %ebx,%eax
  801415:	c1 e8 0c             	shr    $0xc,%eax
  801418:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80141f:	f6 c2 01             	test   $0x1,%dl
  801422:	74 26                	je     80144a <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801424:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80142b:	83 ec 0c             	sub    $0xc,%esp
  80142e:	25 07 0e 00 00       	and    $0xe07,%eax
  801433:	50                   	push   %eax
  801434:	ff 75 d4             	pushl  -0x2c(%ebp)
  801437:	6a 00                	push   $0x0
  801439:	53                   	push   %ebx
  80143a:	6a 00                	push   $0x0
  80143c:	e8 e3 f8 ff ff       	call   800d24 <sys_page_map>
  801441:	89 c3                	mov    %eax,%ebx
  801443:	83 c4 20             	add    $0x20,%esp
  801446:	85 c0                	test   %eax,%eax
  801448:	78 2d                	js     801477 <dup+0xc6>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80144a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80144d:	89 c2                	mov    %eax,%edx
  80144f:	c1 ea 0c             	shr    $0xc,%edx
  801452:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801459:	83 ec 0c             	sub    $0xc,%esp
  80145c:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  801462:	52                   	push   %edx
  801463:	56                   	push   %esi
  801464:	6a 00                	push   $0x0
  801466:	50                   	push   %eax
  801467:	6a 00                	push   $0x0
  801469:	e8 b6 f8 ff ff       	call   800d24 <sys_page_map>
  80146e:	89 c3                	mov    %eax,%ebx
  801470:	83 c4 20             	add    $0x20,%esp
  801473:	85 c0                	test   %eax,%eax
  801475:	79 1d                	jns    801494 <dup+0xe3>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801477:	83 ec 08             	sub    $0x8,%esp
  80147a:	56                   	push   %esi
  80147b:	6a 00                	push   $0x0
  80147d:	e8 c8 f8 ff ff       	call   800d4a <sys_page_unmap>
	sys_page_unmap(0, nva);
  801482:	83 c4 08             	add    $0x8,%esp
  801485:	ff 75 d4             	pushl  -0x2c(%ebp)
  801488:	6a 00                	push   $0x0
  80148a:	e8 bb f8 ff ff       	call   800d4a <sys_page_unmap>
	return r;
  80148f:	83 c4 10             	add    $0x10,%esp
  801492:	eb 02                	jmp    801496 <dup+0xe5>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  801494:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  801496:	89 d8                	mov    %ebx,%eax
  801498:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80149b:	5b                   	pop    %ebx
  80149c:	5e                   	pop    %esi
  80149d:	5f                   	pop    %edi
  80149e:	c9                   	leave  
  80149f:	c3                   	ret    

008014a0 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8014a0:	55                   	push   %ebp
  8014a1:	89 e5                	mov    %esp,%ebp
  8014a3:	53                   	push   %ebx
  8014a4:	83 ec 14             	sub    $0x14,%esp
  8014a7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8014aa:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014ad:	50                   	push   %eax
  8014ae:	53                   	push   %ebx
  8014af:	e8 6b fd ff ff       	call   80121f <fd_lookup>
  8014b4:	83 c4 08             	add    $0x8,%esp
  8014b7:	85 c0                	test   %eax,%eax
  8014b9:	78 67                	js     801522 <read+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014bb:	83 ec 08             	sub    $0x8,%esp
  8014be:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014c1:	50                   	push   %eax
  8014c2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014c5:	ff 30                	pushl  (%eax)
  8014c7:	e8 a9 fd ff ff       	call   801275 <dev_lookup>
  8014cc:	83 c4 10             	add    $0x10,%esp
  8014cf:	85 c0                	test   %eax,%eax
  8014d1:	78 4f                	js     801522 <read+0x82>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8014d3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014d6:	8b 50 08             	mov    0x8(%eax),%edx
  8014d9:	83 e2 03             	and    $0x3,%edx
  8014dc:	83 fa 01             	cmp    $0x1,%edx
  8014df:	75 21                	jne    801502 <read+0x62>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8014e1:	a1 04 50 80 00       	mov    0x805004,%eax
  8014e6:	8b 40 48             	mov    0x48(%eax),%eax
  8014e9:	83 ec 04             	sub    $0x4,%esp
  8014ec:	53                   	push   %ebx
  8014ed:	50                   	push   %eax
  8014ee:	68 51 31 80 00       	push   $0x803151
  8014f3:	e8 d0 ed ff ff       	call   8002c8 <cprintf>
		return -E_INVAL;
  8014f8:	83 c4 10             	add    $0x10,%esp
  8014fb:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801500:	eb 20                	jmp    801522 <read+0x82>
	}
	if (!dev->dev_read)
  801502:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801505:	8b 52 08             	mov    0x8(%edx),%edx
  801508:	85 d2                	test   %edx,%edx
  80150a:	74 11                	je     80151d <read+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80150c:	83 ec 04             	sub    $0x4,%esp
  80150f:	ff 75 10             	pushl  0x10(%ebp)
  801512:	ff 75 0c             	pushl  0xc(%ebp)
  801515:	50                   	push   %eax
  801516:	ff d2                	call   *%edx
  801518:	83 c4 10             	add    $0x10,%esp
  80151b:	eb 05                	jmp    801522 <read+0x82>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80151d:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  801522:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801525:	c9                   	leave  
  801526:	c3                   	ret    

00801527 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801527:	55                   	push   %ebp
  801528:	89 e5                	mov    %esp,%ebp
  80152a:	57                   	push   %edi
  80152b:	56                   	push   %esi
  80152c:	53                   	push   %ebx
  80152d:	83 ec 0c             	sub    $0xc,%esp
  801530:	8b 7d 08             	mov    0x8(%ebp),%edi
  801533:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801536:	85 f6                	test   %esi,%esi
  801538:	74 31                	je     80156b <readn+0x44>
  80153a:	b8 00 00 00 00       	mov    $0x0,%eax
  80153f:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = read(fdnum, (char*)buf + tot, n - tot);
  801544:	83 ec 04             	sub    $0x4,%esp
  801547:	89 f2                	mov    %esi,%edx
  801549:	29 c2                	sub    %eax,%edx
  80154b:	52                   	push   %edx
  80154c:	03 45 0c             	add    0xc(%ebp),%eax
  80154f:	50                   	push   %eax
  801550:	57                   	push   %edi
  801551:	e8 4a ff ff ff       	call   8014a0 <read>
		if (m < 0)
  801556:	83 c4 10             	add    $0x10,%esp
  801559:	85 c0                	test   %eax,%eax
  80155b:	78 17                	js     801574 <readn+0x4d>
			return m;
		if (m == 0)
  80155d:	85 c0                	test   %eax,%eax
  80155f:	74 11                	je     801572 <readn+0x4b>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801561:	01 c3                	add    %eax,%ebx
  801563:	89 d8                	mov    %ebx,%eax
  801565:	39 f3                	cmp    %esi,%ebx
  801567:	72 db                	jb     801544 <readn+0x1d>
  801569:	eb 09                	jmp    801574 <readn+0x4d>
  80156b:	b8 00 00 00 00       	mov    $0x0,%eax
  801570:	eb 02                	jmp    801574 <readn+0x4d>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  801572:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  801574:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801577:	5b                   	pop    %ebx
  801578:	5e                   	pop    %esi
  801579:	5f                   	pop    %edi
  80157a:	c9                   	leave  
  80157b:	c3                   	ret    

0080157c <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80157c:	55                   	push   %ebp
  80157d:	89 e5                	mov    %esp,%ebp
  80157f:	53                   	push   %ebx
  801580:	83 ec 14             	sub    $0x14,%esp
  801583:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801586:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801589:	50                   	push   %eax
  80158a:	53                   	push   %ebx
  80158b:	e8 8f fc ff ff       	call   80121f <fd_lookup>
  801590:	83 c4 08             	add    $0x8,%esp
  801593:	85 c0                	test   %eax,%eax
  801595:	78 62                	js     8015f9 <write+0x7d>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801597:	83 ec 08             	sub    $0x8,%esp
  80159a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80159d:	50                   	push   %eax
  80159e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015a1:	ff 30                	pushl  (%eax)
  8015a3:	e8 cd fc ff ff       	call   801275 <dev_lookup>
  8015a8:	83 c4 10             	add    $0x10,%esp
  8015ab:	85 c0                	test   %eax,%eax
  8015ad:	78 4a                	js     8015f9 <write+0x7d>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8015af:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015b2:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8015b6:	75 21                	jne    8015d9 <write+0x5d>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8015b8:	a1 04 50 80 00       	mov    0x805004,%eax
  8015bd:	8b 40 48             	mov    0x48(%eax),%eax
  8015c0:	83 ec 04             	sub    $0x4,%esp
  8015c3:	53                   	push   %ebx
  8015c4:	50                   	push   %eax
  8015c5:	68 6d 31 80 00       	push   $0x80316d
  8015ca:	e8 f9 ec ff ff       	call   8002c8 <cprintf>
		return -E_INVAL;
  8015cf:	83 c4 10             	add    $0x10,%esp
  8015d2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8015d7:	eb 20                	jmp    8015f9 <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8015d9:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8015dc:	8b 52 0c             	mov    0xc(%edx),%edx
  8015df:	85 d2                	test   %edx,%edx
  8015e1:	74 11                	je     8015f4 <write+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8015e3:	83 ec 04             	sub    $0x4,%esp
  8015e6:	ff 75 10             	pushl  0x10(%ebp)
  8015e9:	ff 75 0c             	pushl  0xc(%ebp)
  8015ec:	50                   	push   %eax
  8015ed:	ff d2                	call   *%edx
  8015ef:	83 c4 10             	add    $0x10,%esp
  8015f2:	eb 05                	jmp    8015f9 <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8015f4:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  8015f9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015fc:	c9                   	leave  
  8015fd:	c3                   	ret    

008015fe <seek>:

int
seek(int fdnum, off_t offset)
{
  8015fe:	55                   	push   %ebp
  8015ff:	89 e5                	mov    %esp,%ebp
  801601:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801604:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801607:	50                   	push   %eax
  801608:	ff 75 08             	pushl  0x8(%ebp)
  80160b:	e8 0f fc ff ff       	call   80121f <fd_lookup>
  801610:	83 c4 08             	add    $0x8,%esp
  801613:	85 c0                	test   %eax,%eax
  801615:	78 0e                	js     801625 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801617:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80161a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80161d:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801620:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801625:	c9                   	leave  
  801626:	c3                   	ret    

00801627 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801627:	55                   	push   %ebp
  801628:	89 e5                	mov    %esp,%ebp
  80162a:	53                   	push   %ebx
  80162b:	83 ec 14             	sub    $0x14,%esp
  80162e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801631:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801634:	50                   	push   %eax
  801635:	53                   	push   %ebx
  801636:	e8 e4 fb ff ff       	call   80121f <fd_lookup>
  80163b:	83 c4 08             	add    $0x8,%esp
  80163e:	85 c0                	test   %eax,%eax
  801640:	78 5f                	js     8016a1 <ftruncate+0x7a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801642:	83 ec 08             	sub    $0x8,%esp
  801645:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801648:	50                   	push   %eax
  801649:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80164c:	ff 30                	pushl  (%eax)
  80164e:	e8 22 fc ff ff       	call   801275 <dev_lookup>
  801653:	83 c4 10             	add    $0x10,%esp
  801656:	85 c0                	test   %eax,%eax
  801658:	78 47                	js     8016a1 <ftruncate+0x7a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80165a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80165d:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801661:	75 21                	jne    801684 <ftruncate+0x5d>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801663:	a1 04 50 80 00       	mov    0x805004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801668:	8b 40 48             	mov    0x48(%eax),%eax
  80166b:	83 ec 04             	sub    $0x4,%esp
  80166e:	53                   	push   %ebx
  80166f:	50                   	push   %eax
  801670:	68 30 31 80 00       	push   $0x803130
  801675:	e8 4e ec ff ff       	call   8002c8 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80167a:	83 c4 10             	add    $0x10,%esp
  80167d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801682:	eb 1d                	jmp    8016a1 <ftruncate+0x7a>
	}
	if (!dev->dev_trunc)
  801684:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801687:	8b 52 18             	mov    0x18(%edx),%edx
  80168a:	85 d2                	test   %edx,%edx
  80168c:	74 0e                	je     80169c <ftruncate+0x75>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80168e:	83 ec 08             	sub    $0x8,%esp
  801691:	ff 75 0c             	pushl  0xc(%ebp)
  801694:	50                   	push   %eax
  801695:	ff d2                	call   *%edx
  801697:	83 c4 10             	add    $0x10,%esp
  80169a:	eb 05                	jmp    8016a1 <ftruncate+0x7a>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80169c:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  8016a1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016a4:	c9                   	leave  
  8016a5:	c3                   	ret    

008016a6 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8016a6:	55                   	push   %ebp
  8016a7:	89 e5                	mov    %esp,%ebp
  8016a9:	53                   	push   %ebx
  8016aa:	83 ec 14             	sub    $0x14,%esp
  8016ad:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016b0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016b3:	50                   	push   %eax
  8016b4:	ff 75 08             	pushl  0x8(%ebp)
  8016b7:	e8 63 fb ff ff       	call   80121f <fd_lookup>
  8016bc:	83 c4 08             	add    $0x8,%esp
  8016bf:	85 c0                	test   %eax,%eax
  8016c1:	78 52                	js     801715 <fstat+0x6f>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016c3:	83 ec 08             	sub    $0x8,%esp
  8016c6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016c9:	50                   	push   %eax
  8016ca:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016cd:	ff 30                	pushl  (%eax)
  8016cf:	e8 a1 fb ff ff       	call   801275 <dev_lookup>
  8016d4:	83 c4 10             	add    $0x10,%esp
  8016d7:	85 c0                	test   %eax,%eax
  8016d9:	78 3a                	js     801715 <fstat+0x6f>
		return r;
	if (!dev->dev_stat)
  8016db:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016de:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8016e2:	74 2c                	je     801710 <fstat+0x6a>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8016e4:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8016e7:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8016ee:	00 00 00 
	stat->st_isdir = 0;
  8016f1:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8016f8:	00 00 00 
	stat->st_dev = dev;
  8016fb:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801701:	83 ec 08             	sub    $0x8,%esp
  801704:	53                   	push   %ebx
  801705:	ff 75 f0             	pushl  -0x10(%ebp)
  801708:	ff 50 14             	call   *0x14(%eax)
  80170b:	83 c4 10             	add    $0x10,%esp
  80170e:	eb 05                	jmp    801715 <fstat+0x6f>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801710:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801715:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801718:	c9                   	leave  
  801719:	c3                   	ret    

0080171a <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80171a:	55                   	push   %ebp
  80171b:	89 e5                	mov    %esp,%ebp
  80171d:	56                   	push   %esi
  80171e:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80171f:	83 ec 08             	sub    $0x8,%esp
  801722:	6a 00                	push   $0x0
  801724:	ff 75 08             	pushl  0x8(%ebp)
  801727:	e8 78 01 00 00       	call   8018a4 <open>
  80172c:	89 c3                	mov    %eax,%ebx
  80172e:	83 c4 10             	add    $0x10,%esp
  801731:	85 c0                	test   %eax,%eax
  801733:	78 1b                	js     801750 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801735:	83 ec 08             	sub    $0x8,%esp
  801738:	ff 75 0c             	pushl  0xc(%ebp)
  80173b:	50                   	push   %eax
  80173c:	e8 65 ff ff ff       	call   8016a6 <fstat>
  801741:	89 c6                	mov    %eax,%esi
	close(fd);
  801743:	89 1c 24             	mov    %ebx,(%esp)
  801746:	e8 18 fc ff ff       	call   801363 <close>
	return r;
  80174b:	83 c4 10             	add    $0x10,%esp
  80174e:	89 f3                	mov    %esi,%ebx
}
  801750:	89 d8                	mov    %ebx,%eax
  801752:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801755:	5b                   	pop    %ebx
  801756:	5e                   	pop    %esi
  801757:	c9                   	leave  
  801758:	c3                   	ret    
  801759:	00 00                	add    %al,(%eax)
	...

0080175c <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80175c:	55                   	push   %ebp
  80175d:	89 e5                	mov    %esp,%ebp
  80175f:	56                   	push   %esi
  801760:	53                   	push   %ebx
  801761:	89 c3                	mov    %eax,%ebx
  801763:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  801765:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  80176c:	75 12                	jne    801780 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80176e:	83 ec 0c             	sub    $0xc,%esp
  801771:	6a 01                	push   $0x1
  801773:	e8 0a 11 00 00       	call   802882 <ipc_find_env>
  801778:	a3 00 50 80 00       	mov    %eax,0x805000
  80177d:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801780:	6a 07                	push   $0x7
  801782:	68 00 60 80 00       	push   $0x806000
  801787:	53                   	push   %ebx
  801788:	ff 35 00 50 80 00    	pushl  0x805000
  80178e:	e8 9a 10 00 00       	call   80282d <ipc_send>
	
	return ipc_recv(NULL, dstva, NULL);
  801793:	83 c4 0c             	add    $0xc,%esp
  801796:	6a 00                	push   $0x0
  801798:	56                   	push   %esi
  801799:	6a 00                	push   $0x0
  80179b:	e8 18 10 00 00       	call   8027b8 <ipc_recv>
}
  8017a0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017a3:	5b                   	pop    %ebx
  8017a4:	5e                   	pop    %esi
  8017a5:	c9                   	leave  
  8017a6:	c3                   	ret    

008017a7 <devfile_stat>:
}


static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8017a7:	55                   	push   %ebp
  8017a8:	89 e5                	mov    %esp,%ebp
  8017aa:	53                   	push   %ebx
  8017ab:	83 ec 04             	sub    $0x4,%esp
  8017ae:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8017b1:	8b 45 08             	mov    0x8(%ebp),%eax
  8017b4:	8b 40 0c             	mov    0xc(%eax),%eax
  8017b7:	a3 00 60 80 00       	mov    %eax,0x806000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0) {
  8017bc:	ba 00 00 00 00       	mov    $0x0,%edx
  8017c1:	b8 05 00 00 00       	mov    $0x5,%eax
  8017c6:	e8 91 ff ff ff       	call   80175c <fsipc>
  8017cb:	85 c0                	test   %eax,%eax
  8017cd:	78 2c                	js     8017fb <devfile_stat+0x54>
		return r;
	}
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8017cf:	83 ec 08             	sub    $0x8,%esp
  8017d2:	68 00 60 80 00       	push   $0x806000
  8017d7:	53                   	push   %ebx
  8017d8:	e8 a1 f0 ff ff       	call   80087e <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8017dd:	a1 80 60 80 00       	mov    0x806080,%eax
  8017e2:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8017e8:	a1 84 60 80 00       	mov    0x806084,%eax
  8017ed:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8017f3:	83 c4 10             	add    $0x10,%esp
  8017f6:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8017fb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017fe:	c9                   	leave  
  8017ff:	c3                   	ret    

00801800 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801800:	55                   	push   %ebp
  801801:	89 e5                	mov    %esp,%ebp
  801803:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801806:	8b 45 08             	mov    0x8(%ebp),%eax
  801809:	8b 40 0c             	mov    0xc(%eax),%eax
  80180c:	a3 00 60 80 00       	mov    %eax,0x806000
	return fsipc(FSREQ_FLUSH, NULL);
  801811:	ba 00 00 00 00       	mov    $0x0,%edx
  801816:	b8 06 00 00 00       	mov    $0x6,%eax
  80181b:	e8 3c ff ff ff       	call   80175c <fsipc>
}
  801820:	c9                   	leave  
  801821:	c3                   	ret    

00801822 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801822:	55                   	push   %ebp
  801823:	89 e5                	mov    %esp,%ebp
  801825:	56                   	push   %esi
  801826:	53                   	push   %ebx
  801827:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80182a:	8b 45 08             	mov    0x8(%ebp),%eax
  80182d:	8b 40 0c             	mov    0xc(%eax),%eax
  801830:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.read.req_n = n;
  801835:	89 35 04 60 80 00    	mov    %esi,0x806004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80183b:	ba 00 00 00 00       	mov    $0x0,%edx
  801840:	b8 03 00 00 00       	mov    $0x3,%eax
  801845:	e8 12 ff ff ff       	call   80175c <fsipc>
  80184a:	89 c3                	mov    %eax,%ebx
  80184c:	85 c0                	test   %eax,%eax
  80184e:	78 4b                	js     80189b <devfile_read+0x79>
		return r;
	assert(r <= n);
  801850:	39 c6                	cmp    %eax,%esi
  801852:	73 16                	jae    80186a <devfile_read+0x48>
  801854:	68 9c 31 80 00       	push   $0x80319c
  801859:	68 a3 31 80 00       	push   $0x8031a3
  80185e:	6a 7d                	push   $0x7d
  801860:	68 b8 31 80 00       	push   $0x8031b8
  801865:	e8 86 e9 ff ff       	call   8001f0 <_panic>
	assert(r <= PGSIZE);
  80186a:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80186f:	7e 16                	jle    801887 <devfile_read+0x65>
  801871:	68 c3 31 80 00       	push   $0x8031c3
  801876:	68 a3 31 80 00       	push   $0x8031a3
  80187b:	6a 7e                	push   $0x7e
  80187d:	68 b8 31 80 00       	push   $0x8031b8
  801882:	e8 69 e9 ff ff       	call   8001f0 <_panic>
	memmove(buf, &fsipcbuf, r);
  801887:	83 ec 04             	sub    $0x4,%esp
  80188a:	50                   	push   %eax
  80188b:	68 00 60 80 00       	push   $0x806000
  801890:	ff 75 0c             	pushl  0xc(%ebp)
  801893:	e8 a7 f1 ff ff       	call   800a3f <memmove>
	return r;
  801898:	83 c4 10             	add    $0x10,%esp
}
  80189b:	89 d8                	mov    %ebx,%eax
  80189d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018a0:	5b                   	pop    %ebx
  8018a1:	5e                   	pop    %esi
  8018a2:	c9                   	leave  
  8018a3:	c3                   	ret    

008018a4 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8018a4:	55                   	push   %ebp
  8018a5:	89 e5                	mov    %esp,%ebp
  8018a7:	56                   	push   %esi
  8018a8:	53                   	push   %ebx
  8018a9:	83 ec 1c             	sub    $0x1c,%esp
  8018ac:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8018af:	56                   	push   %esi
  8018b0:	e8 77 ef ff ff       	call   80082c <strlen>
  8018b5:	83 c4 10             	add    $0x10,%esp
  8018b8:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8018bd:	7f 65                	jg     801924 <open+0x80>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8018bf:	83 ec 0c             	sub    $0xc,%esp
  8018c2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018c5:	50                   	push   %eax
  8018c6:	e8 e1 f8 ff ff       	call   8011ac <fd_alloc>
  8018cb:	89 c3                	mov    %eax,%ebx
  8018cd:	83 c4 10             	add    $0x10,%esp
  8018d0:	85 c0                	test   %eax,%eax
  8018d2:	78 55                	js     801929 <open+0x85>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8018d4:	83 ec 08             	sub    $0x8,%esp
  8018d7:	56                   	push   %esi
  8018d8:	68 00 60 80 00       	push   $0x806000
  8018dd:	e8 9c ef ff ff       	call   80087e <strcpy>
	fsipcbuf.open.req_omode = mode;
  8018e2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018e5:	a3 00 64 80 00       	mov    %eax,0x806400



	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8018ea:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8018ed:	b8 01 00 00 00       	mov    $0x1,%eax
  8018f2:	e8 65 fe ff ff       	call   80175c <fsipc>
  8018f7:	89 c3                	mov    %eax,%ebx
  8018f9:	83 c4 10             	add    $0x10,%esp
  8018fc:	85 c0                	test   %eax,%eax
  8018fe:	79 12                	jns    801912 <open+0x6e>
		fd_close(fd, 0);
  801900:	83 ec 08             	sub    $0x8,%esp
  801903:	6a 00                	push   $0x0
  801905:	ff 75 f4             	pushl  -0xc(%ebp)
  801908:	e8 ce f9 ff ff       	call   8012db <fd_close>
		return r;
  80190d:	83 c4 10             	add    $0x10,%esp
  801910:	eb 17                	jmp    801929 <open+0x85>
	}

	return fd2num(fd);
  801912:	83 ec 0c             	sub    $0xc,%esp
  801915:	ff 75 f4             	pushl  -0xc(%ebp)
  801918:	e8 67 f8 ff ff       	call   801184 <fd2num>
  80191d:	89 c3                	mov    %eax,%ebx
  80191f:	83 c4 10             	add    $0x10,%esp
  801922:	eb 05                	jmp    801929 <open+0x85>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801924:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801929:	89 d8                	mov    %ebx,%eax
  80192b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80192e:	5b                   	pop    %ebx
  80192f:	5e                   	pop    %esi
  801930:	c9                   	leave  
  801931:	c3                   	ret    
	...

00801934 <map_segment>:
}

static int
map_segment(envid_t child, uintptr_t va, size_t memsz,
	int fd, size_t filesz, off_t fileoffset, int perm)
{
  801934:	55                   	push   %ebp
  801935:	89 e5                	mov    %esp,%ebp
  801937:	57                   	push   %edi
  801938:	56                   	push   %esi
  801939:	53                   	push   %ebx
  80193a:	83 ec 1c             	sub    $0x1c,%esp
  80193d:	89 c7                	mov    %eax,%edi
  80193f:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  801942:	89 4d e0             	mov    %ecx,-0x20(%ebp)
	int i, r;
	void *blk;

	//cprintf("map_segment %x+%x\n", va, memsz);

	if ((i = PGOFF(va))) {
  801945:	89 d0                	mov    %edx,%eax
  801947:	25 ff 0f 00 00       	and    $0xfff,%eax
  80194c:	74 0c                	je     80195a <map_segment+0x26>
		va -= i;
  80194e:	29 45 e4             	sub    %eax,-0x1c(%ebp)
		memsz += i;
  801951:	01 45 e0             	add    %eax,-0x20(%ebp)
		filesz += i;
  801954:	01 45 0c             	add    %eax,0xc(%ebp)
		fileoffset -= i;
  801957:	29 45 10             	sub    %eax,0x10(%ebp)
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  80195a:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80195e:	0f 84 ee 00 00 00    	je     801a52 <map_segment+0x11e>
  801964:	be 00 00 00 00       	mov    $0x0,%esi
  801969:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (i >= filesz) {
  80196e:	39 75 0c             	cmp    %esi,0xc(%ebp)
  801971:	77 20                	ja     801993 <map_segment+0x5f>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
  801973:	83 ec 04             	sub    $0x4,%esp
  801976:	ff 75 14             	pushl  0x14(%ebp)
  801979:	03 75 e4             	add    -0x1c(%ebp),%esi
  80197c:	56                   	push   %esi
  80197d:	57                   	push   %edi
  80197e:	e8 7d f3 ff ff       	call   800d00 <sys_page_alloc>
  801983:	83 c4 10             	add    $0x10,%esp
  801986:	85 c0                	test   %eax,%eax
  801988:	0f 89 ac 00 00 00    	jns    801a3a <map_segment+0x106>
  80198e:	e9 c4 00 00 00       	jmp    801a57 <map_segment+0x123>
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801993:	83 ec 04             	sub    $0x4,%esp
  801996:	6a 07                	push   $0x7
  801998:	68 00 00 40 00       	push   $0x400000
  80199d:	6a 00                	push   $0x0
  80199f:	e8 5c f3 ff ff       	call   800d00 <sys_page_alloc>
  8019a4:	83 c4 10             	add    $0x10,%esp
  8019a7:	85 c0                	test   %eax,%eax
  8019a9:	0f 88 a8 00 00 00    	js     801a57 <map_segment+0x123>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  8019af:	83 ec 08             	sub    $0x8,%esp
	sys_page_unmap(0, UTEMP);
	return r;
}

static int
map_segment(envid_t child, uintptr_t va, size_t memsz,
  8019b2:	8b 45 10             	mov    0x10(%ebp),%eax
  8019b5:	8d 04 03             	lea    (%ebx,%eax,1),%eax
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  8019b8:	50                   	push   %eax
  8019b9:	ff 75 08             	pushl  0x8(%ebp)
  8019bc:	e8 3d fc ff ff       	call   8015fe <seek>
  8019c1:	83 c4 10             	add    $0x10,%esp
  8019c4:	85 c0                	test   %eax,%eax
  8019c6:	0f 88 8b 00 00 00    	js     801a57 <map_segment+0x123>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  8019cc:	83 ec 04             	sub    $0x4,%esp
  8019cf:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019d2:	29 f0                	sub    %esi,%eax
  8019d4:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8019d9:	76 05                	jbe    8019e0 <map_segment+0xac>
  8019db:	b8 00 10 00 00       	mov    $0x1000,%eax
  8019e0:	50                   	push   %eax
  8019e1:	68 00 00 40 00       	push   $0x400000
  8019e6:	ff 75 08             	pushl  0x8(%ebp)
  8019e9:	e8 39 fb ff ff       	call   801527 <readn>
  8019ee:	83 c4 10             	add    $0x10,%esp
  8019f1:	85 c0                	test   %eax,%eax
  8019f3:	78 62                	js     801a57 <map_segment+0x123>
				return r;
			if ((r = sys_page_map(0, UTEMP, child, (void*) (va + i), perm)) < 0)
  8019f5:	83 ec 0c             	sub    $0xc,%esp
  8019f8:	ff 75 14             	pushl  0x14(%ebp)
  8019fb:	03 75 e4             	add    -0x1c(%ebp),%esi
  8019fe:	56                   	push   %esi
  8019ff:	57                   	push   %edi
  801a00:	68 00 00 40 00       	push   $0x400000
  801a05:	6a 00                	push   $0x0
  801a07:	e8 18 f3 ff ff       	call   800d24 <sys_page_map>
  801a0c:	83 c4 20             	add    $0x20,%esp
  801a0f:	85 c0                	test   %eax,%eax
  801a11:	79 15                	jns    801a28 <map_segment+0xf4>
				panic("spawn: sys_page_map data: %e", r);
  801a13:	50                   	push   %eax
  801a14:	68 cf 31 80 00       	push   $0x8031cf
  801a19:	68 84 01 00 00       	push   $0x184
  801a1e:	68 ec 31 80 00       	push   $0x8031ec
  801a23:	e8 c8 e7 ff ff       	call   8001f0 <_panic>
			sys_page_unmap(0, UTEMP);
  801a28:	83 ec 08             	sub    $0x8,%esp
  801a2b:	68 00 00 40 00       	push   $0x400000
  801a30:	6a 00                	push   $0x0
  801a32:	e8 13 f3 ff ff       	call   800d4a <sys_page_unmap>
  801a37:	83 c4 10             	add    $0x10,%esp
		memsz += i;
		filesz += i;
		fileoffset -= i;
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  801a3a:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801a40:	89 de                	mov    %ebx,%esi
  801a42:	39 5d e0             	cmp    %ebx,-0x20(%ebp)
  801a45:	0f 87 23 ff ff ff    	ja     80196e <map_segment+0x3a>
			if ((r = sys_page_map(0, UTEMP, child, (void*) (va + i), perm)) < 0)
				panic("spawn: sys_page_map data: %e", r);
			sys_page_unmap(0, UTEMP);
		}
	}
	return 0;
  801a4b:	b8 00 00 00 00       	mov    $0x0,%eax
  801a50:	eb 05                	jmp    801a57 <map_segment+0x123>
  801a52:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801a57:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a5a:	5b                   	pop    %ebx
  801a5b:	5e                   	pop    %esi
  801a5c:	5f                   	pop    %edi
  801a5d:	c9                   	leave  
  801a5e:	c3                   	ret    

00801a5f <init_stack>:
// On success, returns 0 and sets *init_esp
// to the initial stack pointer with which the child should start.
// Returns < 0 on failure.
static int
init_stack(envid_t child, const char **argv, uintptr_t *init_esp, uint32_t stack_addr)
{
  801a5f:	55                   	push   %ebp
  801a60:	89 e5                	mov    %esp,%ebp
  801a62:	57                   	push   %edi
  801a63:	56                   	push   %esi
  801a64:	53                   	push   %ebx
  801a65:	83 ec 2c             	sub    $0x2c,%esp
  801a68:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801a6b:	89 d7                	mov    %edx,%edi
  801a6d:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  801a70:	8b 02                	mov    (%edx),%eax
  801a72:	85 c0                	test   %eax,%eax
  801a74:	74 31                	je     801aa7 <init_stack+0x48>
  801a76:	bb 00 00 00 00       	mov    $0x0,%ebx
	char *string_store;
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
  801a7b:	be 00 00 00 00       	mov    $0x0,%esi
	for (argc = 0; argv[argc] != 0; argc++)
		string_size += strlen(argv[argc]) + 1;
  801a80:	83 ec 0c             	sub    $0xc,%esp
  801a83:	50                   	push   %eax
  801a84:	e8 a3 ed ff ff       	call   80082c <strlen>
  801a89:	8d 74 30 01          	lea    0x1(%eax,%esi,1),%esi
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  801a8d:	43                   	inc    %ebx
  801a8e:	8d 0c 9d 00 00 00 00 	lea    0x0(,%ebx,4),%ecx
  801a95:	8b 04 9f             	mov    (%edi,%ebx,4),%eax
  801a98:	83 c4 10             	add    $0x10,%esp
  801a9b:	85 c0                	test   %eax,%eax
  801a9d:	75 e1                	jne    801a80 <init_stack+0x21>
  801a9f:	89 5d d0             	mov    %ebx,-0x30(%ebp)
  801aa2:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  801aa5:	eb 18                	jmp    801abf <init_stack+0x60>
  801aa7:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
  801aae:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
  801ab5:	bb 00 00 00 00       	mov    $0x0,%ebx
	char *string_store;
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
  801aba:	be 00 00 00 00       	mov    $0x0,%esi
	// Determine where to place the strings and the argv array.
	// Set up pointers into the temporary page 'UTEMP'; we'll map a page
	// there later, then remap that page into the child environment
	// at (USTACKTOP - PGSIZE).
	// strings is the topmost thing on the stack.
	string_store = (char*) UTEMP + PGSIZE - string_size;
  801abf:	f7 de                	neg    %esi
  801ac1:	81 c6 00 10 40 00    	add    $0x401000,%esi
  801ac7:	89 75 dc             	mov    %esi,-0x24(%ebp)
	// argv is below that.  There's one argument pointer per argument, plus
	// a null pointer.
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));
  801aca:	89 f2                	mov    %esi,%edx
  801acc:	83 e2 fc             	and    $0xfffffffc,%edx
  801acf:	89 d8                	mov    %ebx,%eax
  801ad1:	f7 d0                	not    %eax
  801ad3:	8d 04 82             	lea    (%edx,%eax,4),%eax
  801ad6:	89 45 e4             	mov    %eax,-0x1c(%ebp)

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
  801ad9:	83 e8 08             	sub    $0x8,%eax
  801adc:	3d ff ff 3f 00       	cmp    $0x3fffff,%eax
  801ae1:	0f 86 fb 00 00 00    	jbe    801be2 <init_stack+0x183>
		return -E_NO_MEM;

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801ae7:	83 ec 04             	sub    $0x4,%esp
  801aea:	6a 07                	push   $0x7
  801aec:	68 00 00 40 00       	push   $0x400000
  801af1:	6a 00                	push   $0x0
  801af3:	e8 08 f2 ff ff       	call   800d00 <sys_page_alloc>
  801af8:	89 c6                	mov    %eax,%esi
  801afa:	83 c4 10             	add    $0x10,%esp
  801afd:	85 c0                	test   %eax,%eax
  801aff:	0f 88 e9 00 00 00    	js     801bee <init_stack+0x18f>
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  801b05:	85 db                	test   %ebx,%ebx
  801b07:	7e 3e                	jle    801b47 <init_stack+0xe8>
  801b09:	be 00 00 00 00       	mov    $0x0,%esi
  801b0e:	89 5d e0             	mov    %ebx,-0x20(%ebp)
  801b11:	8b 5d dc             	mov    -0x24(%ebp),%ebx
		argv_store[i] = UTEMP2USTACK(string_store);
  801b14:	8d 83 00 d0 7f ee    	lea    -0x11803000(%ebx),%eax
  801b1a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801b1d:	89 04 b2             	mov    %eax,(%edx,%esi,4)
		strcpy(string_store, argv[i]);
  801b20:	83 ec 08             	sub    $0x8,%esp
  801b23:	ff 34 b7             	pushl  (%edi,%esi,4)
  801b26:	53                   	push   %ebx
  801b27:	e8 52 ed ff ff       	call   80087e <strcpy>
		string_store += strlen(argv[i]) + 1;
  801b2c:	83 c4 04             	add    $0x4,%esp
  801b2f:	ff 34 b7             	pushl  (%edi,%esi,4)
  801b32:	e8 f5 ec ff ff       	call   80082c <strlen>
  801b37:	8d 5c 03 01          	lea    0x1(%ebx,%eax,1),%ebx
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  801b3b:	46                   	inc    %esi
  801b3c:	83 c4 10             	add    $0x10,%esp
  801b3f:	3b 75 e0             	cmp    -0x20(%ebp),%esi
  801b42:	7c d0                	jl     801b14 <init_stack+0xb5>
  801b44:	89 5d dc             	mov    %ebx,-0x24(%ebp)
		argv_store[i] = UTEMP2USTACK(string_store);
		strcpy(string_store, argv[i]);
		string_store += strlen(argv[i]) + 1;
	}
	argv_store[argc] = 0;
  801b47:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801b4a:	8b 45 cc             	mov    -0x34(%ebp),%eax
  801b4d:	c7 04 02 00 00 00 00 	movl   $0x0,(%edx,%eax,1)
	assert(string_store == (char*)UTEMP + PGSIZE);
  801b54:	81 7d dc 00 10 40 00 	cmpl   $0x401000,-0x24(%ebp)
  801b5b:	74 19                	je     801b76 <init_stack+0x117>
  801b5d:	68 5c 32 80 00       	push   $0x80325c
  801b62:	68 a3 31 80 00       	push   $0x8031a3
  801b67:	68 51 01 00 00       	push   $0x151
  801b6c:	68 ec 31 80 00       	push   $0x8031ec
  801b71:	e8 7a e6 ff ff       	call   8001f0 <_panic>

	argv_store[-1] = UTEMP2USTACK(argv_store);
  801b76:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801b79:	2d 00 30 80 11       	sub    $0x11803000,%eax
  801b7e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801b81:	89 42 fc             	mov    %eax,-0x4(%edx)
	argv_store[-2] = argc;
  801b84:	8b 45 d0             	mov    -0x30(%ebp),%eax
  801b87:	89 42 f8             	mov    %eax,-0x8(%edx)

	*init_esp = UTEMP2USTACK(&argv_store[-2]);
  801b8a:	89 d0                	mov    %edx,%eax
  801b8c:	2d 08 30 80 11       	sub    $0x11803008,%eax
  801b91:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  801b94:	89 02                	mov    %eax,(%edx)

	// After completing the stack, map it into the child's address space
	// and unmap it from ours!
	
	if ((r = sys_page_map(0, UTEMP, child, (void*) stack_addr, PTE_P | PTE_U | PTE_W)) < 0)
  801b96:	83 ec 0c             	sub    $0xc,%esp
  801b99:	6a 07                	push   $0x7
  801b9b:	ff 75 08             	pushl  0x8(%ebp)
  801b9e:	ff 75 d8             	pushl  -0x28(%ebp)
  801ba1:	68 00 00 40 00       	push   $0x400000
  801ba6:	6a 00                	push   $0x0
  801ba8:	e8 77 f1 ff ff       	call   800d24 <sys_page_map>
  801bad:	89 c6                	mov    %eax,%esi
  801baf:	83 c4 20             	add    $0x20,%esp
  801bb2:	85 c0                	test   %eax,%eax
  801bb4:	78 18                	js     801bce <init_stack+0x16f>
		goto error;
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  801bb6:	83 ec 08             	sub    $0x8,%esp
  801bb9:	68 00 00 40 00       	push   $0x400000
  801bbe:	6a 00                	push   $0x0
  801bc0:	e8 85 f1 ff ff       	call   800d4a <sys_page_unmap>
  801bc5:	89 c6                	mov    %eax,%esi
  801bc7:	83 c4 10             	add    $0x10,%esp
  801bca:	85 c0                	test   %eax,%eax
  801bcc:	79 1b                	jns    801be9 <init_stack+0x18a>
		goto error;
	return 0;

error:
	sys_page_unmap(0, UTEMP);
  801bce:	83 ec 08             	sub    $0x8,%esp
  801bd1:	68 00 00 40 00       	push   $0x400000
  801bd6:	6a 00                	push   $0x0
  801bd8:	e8 6d f1 ff ff       	call   800d4a <sys_page_unmap>
	return r;
  801bdd:	83 c4 10             	add    $0x10,%esp
  801be0:	eb 0c                	jmp    801bee <init_stack+0x18f>
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
		return -E_NO_MEM;
  801be2:	be fc ff ff ff       	mov    $0xfffffffc,%esi
  801be7:	eb 05                	jmp    801bee <init_stack+0x18f>
	
	if ((r = sys_page_map(0, UTEMP, child, (void*) stack_addr, PTE_P | PTE_U | PTE_W)) < 0)
		goto error;
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
		goto error;
	return 0;
  801be9:	be 00 00 00 00       	mov    $0x0,%esi

error:
	sys_page_unmap(0, UTEMP);
	return r;
}
  801bee:	89 f0                	mov    %esi,%eax
  801bf0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801bf3:	5b                   	pop    %ebx
  801bf4:	5e                   	pop    %esi
  801bf5:	5f                   	pop    %edi
  801bf6:	c9                   	leave  
  801bf7:	c3                   	ret    

00801bf8 <spawn>:
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
{
  801bf8:	55                   	push   %ebp
  801bf9:	89 e5                	mov    %esp,%ebp
  801bfb:	57                   	push   %edi
  801bfc:	56                   	push   %esi
  801bfd:	53                   	push   %ebx
  801bfe:	81 ec 74 02 00 00    	sub    $0x274,%esp
	//   - Call sys_env_set_trapframe(child, &child_tf) to set up the
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
  801c04:	6a 00                	push   $0x0
  801c06:	ff 75 08             	pushl  0x8(%ebp)
  801c09:	e8 96 fc ff ff       	call   8018a4 <open>
  801c0e:	89 85 90 fd ff ff    	mov    %eax,-0x270(%ebp)
  801c14:	83 c4 10             	add    $0x10,%esp
  801c17:	85 c0                	test   %eax,%eax
  801c19:	0f 88 45 02 00 00    	js     801e64 <spawn+0x26c>
		return r;
	fd = r;

	// Read elf header
	elf = (struct Elf*) elf_buf;
	if (readn(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf)
  801c1f:	83 ec 04             	sub    $0x4,%esp
  801c22:	68 00 02 00 00       	push   $0x200
  801c27:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  801c2d:	50                   	push   %eax
  801c2e:	ff b5 90 fd ff ff    	pushl  -0x270(%ebp)
  801c34:	e8 ee f8 ff ff       	call   801527 <readn>
  801c39:	83 c4 10             	add    $0x10,%esp
  801c3c:	3d 00 02 00 00       	cmp    $0x200,%eax
  801c41:	75 0c                	jne    801c4f <spawn+0x57>
	    || elf->e_magic != ELF_MAGIC) {
  801c43:	81 bd e8 fd ff ff 7f 	cmpl   $0x464c457f,-0x218(%ebp)
  801c4a:	45 4c 46 
  801c4d:	74 38                	je     801c87 <spawn+0x8f>
		close(fd);
  801c4f:	83 ec 0c             	sub    $0xc,%esp
  801c52:	ff b5 90 fd ff ff    	pushl  -0x270(%ebp)
  801c58:	e8 06 f7 ff ff       	call   801363 <close>
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
  801c5d:	83 c4 0c             	add    $0xc,%esp
  801c60:	68 7f 45 4c 46       	push   $0x464c457f
  801c65:	ff b5 e8 fd ff ff    	pushl  -0x218(%ebp)
  801c6b:	68 f8 31 80 00       	push   $0x8031f8
  801c70:	e8 53 e6 ff ff       	call   8002c8 <cprintf>
		return -E_NOT_EXEC;
  801c75:	83 c4 10             	add    $0x10,%esp
  801c78:	c7 85 94 fd ff ff f2 	movl   $0xfffffff2,-0x26c(%ebp)
  801c7f:	ff ff ff 
  801c82:	e9 f1 01 00 00       	jmp    801e78 <spawn+0x280>
  801c87:	ba 07 00 00 00       	mov    $0x7,%edx
  801c8c:	89 d0                	mov    %edx,%eax
  801c8e:	cd 30                	int    $0x30
  801c90:	89 85 8c fd ff ff    	mov    %eax,-0x274(%ebp)
  801c96:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)
	}


	// Create new child environment
	if ((r = sys_exofork()) < 0)
  801c9c:	85 c0                	test   %eax,%eax
  801c9e:	0f 88 d4 01 00 00    	js     801e78 <spawn+0x280>
		return r;
	child = r;

	// Set up trap frame, including initial stack.
	child_tf = envs[ENVX(child)].env_tf;
  801ca4:	25 ff 03 00 00       	and    $0x3ff,%eax
  801ca9:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  801cb0:	c1 e0 07             	shl    $0x7,%eax
  801cb3:	29 d0                	sub    %edx,%eax
  801cb5:	8d b0 00 00 c0 ee    	lea    -0x11400000(%eax),%esi
  801cbb:	8d bd a4 fd ff ff    	lea    -0x25c(%ebp),%edi
  801cc1:	b9 11 00 00 00       	mov    $0x11,%ecx
  801cc6:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	child_tf.tf_eip = elf->e_entry;
  801cc8:	8b 85 00 fe ff ff    	mov    -0x200(%ebp),%eax
  801cce:	89 85 d4 fd ff ff    	mov    %eax,-0x22c(%ebp)

	if ((r = init_stack(child, argv, &child_tf.tf_esp, (USTACKTOP - PGSIZE))) < 0)
  801cd4:	83 ec 0c             	sub    $0xc,%esp
  801cd7:	8d 8d e0 fd ff ff    	lea    -0x220(%ebp),%ecx
  801cdd:	68 00 d0 bf ee       	push   $0xeebfd000
  801ce2:	8b 55 0c             	mov    0xc(%ebp),%edx
  801ce5:	8b 85 8c fd ff ff    	mov    -0x274(%ebp),%eax
  801ceb:	e8 6f fd ff ff       	call   801a5f <init_stack>
  801cf0:	83 c4 10             	add    $0x10,%esp
  801cf3:	85 c0                	test   %eax,%eax
  801cf5:	0f 88 77 01 00 00    	js     801e72 <spawn+0x27a>
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  801cfb:	8b 85 04 fe ff ff    	mov    -0x1fc(%ebp),%eax
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801d01:	66 83 bd 14 fe ff ff 	cmpw   $0x0,-0x1ec(%ebp)
  801d08:	00 
  801d09:	74 5d                	je     801d68 <spawn+0x170>

	if ((r = init_stack(child, argv, &child_tf.tf_esp, (USTACKTOP - PGSIZE))) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  801d0b:	8d 9c 05 e8 fd ff ff 	lea    -0x218(%ebp,%eax,1),%ebx
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801d12:	be 00 00 00 00       	mov    $0x0,%esi
  801d17:	8b bd 90 fd ff ff    	mov    -0x270(%ebp),%edi
		if (ph->p_type != ELF_PROG_LOAD)
  801d1d:	83 3b 01             	cmpl   $0x1,(%ebx)
  801d20:	75 35                	jne    801d57 <spawn+0x15f>
			continue;
		perm = PTE_P | PTE_U;
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
  801d22:	8b 43 18             	mov    0x18(%ebx),%eax
  801d25:	83 e0 02             	and    $0x2,%eax
	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
		if (ph->p_type != ELF_PROG_LOAD)
			continue;
		perm = PTE_P | PTE_U;
  801d28:	83 f8 01             	cmp    $0x1,%eax
  801d2b:	19 c0                	sbb    %eax,%eax
  801d2d:	83 e0 fe             	and    $0xfffffffe,%eax
  801d30:	83 c0 07             	add    $0x7,%eax
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
  801d33:	8b 4b 14             	mov    0x14(%ebx),%ecx
  801d36:	8b 53 08             	mov    0x8(%ebx),%edx
  801d39:	50                   	push   %eax
  801d3a:	ff 73 04             	pushl  0x4(%ebx)
  801d3d:	ff 73 10             	pushl  0x10(%ebx)
  801d40:	57                   	push   %edi
  801d41:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  801d47:	e8 e8 fb ff ff       	call   801934 <map_segment>
  801d4c:	83 c4 10             	add    $0x10,%esp
  801d4f:	85 c0                	test   %eax,%eax
  801d51:	0f 88 e4 00 00 00    	js     801e3b <spawn+0x243>
	if ((r = init_stack(child, argv, &child_tf.tf_esp, (USTACKTOP - PGSIZE))) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801d57:	46                   	inc    %esi
  801d58:	0f b7 85 14 fe ff ff 	movzwl -0x1ec(%ebp),%eax
  801d5f:	39 f0                	cmp    %esi,%eax
  801d61:	7e 05                	jle    801d68 <spawn+0x170>
  801d63:	83 c3 20             	add    $0x20,%ebx
  801d66:	eb b5                	jmp    801d1d <spawn+0x125>
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
				     fd, ph->p_filesz, ph->p_offset, perm)) < 0)
			goto error;
	}
	close(fd);
  801d68:	83 ec 0c             	sub    $0xc,%esp
  801d6b:	ff b5 90 fd ff ff    	pushl  -0x270(%ebp)
  801d71:	e8 ed f5 ff ff       	call   801363 <close>
  801d76:	83 c4 10             	add    $0x10,%esp
copy_shared_pages(envid_t child)
{
	// LAB 5: Your code here.
    uint32_t i;
    int r;
    for (i = 0; i != UTOP; i += PGSIZE) 
  801d79:	bb 00 00 00 00       	mov    $0x0,%ebx
  801d7e:	8b b5 94 fd ff ff    	mov    -0x26c(%ebp),%esi
    if ((uvpd[PDX(i)] & PTE_P) && (uvpt[i / PGSIZE] & PTE_P) && (uvpt[i / PGSIZE] & PTE_SHARE)) {
  801d84:	89 d8                	mov    %ebx,%eax
  801d86:	c1 e8 16             	shr    $0x16,%eax
  801d89:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801d90:	a8 01                	test   $0x1,%al
  801d92:	74 3e                	je     801dd2 <spawn+0x1da>
  801d94:	89 d8                	mov    %ebx,%eax
  801d96:	c1 e8 0c             	shr    $0xc,%eax
  801d99:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801da0:	f6 c2 01             	test   $0x1,%dl
  801da3:	74 2d                	je     801dd2 <spawn+0x1da>
  801da5:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801dac:	f6 c6 04             	test   $0x4,%dh
  801daf:	74 21                	je     801dd2 <spawn+0x1da>
        r = sys_page_map(0, (void *)i, child, (void *)i, uvpt[i / PGSIZE] & PTE_SYSCALL);
  801db1:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801db8:	83 ec 0c             	sub    $0xc,%esp
  801dbb:	25 07 0e 00 00       	and    $0xe07,%eax
  801dc0:	50                   	push   %eax
  801dc1:	53                   	push   %ebx
  801dc2:	56                   	push   %esi
  801dc3:	53                   	push   %ebx
  801dc4:	6a 00                	push   $0x0
  801dc6:	e8 59 ef ff ff       	call   800d24 <sys_page_map>
        if (r < 0) return r;
  801dcb:	83 c4 20             	add    $0x20,%esp
  801dce:	85 c0                	test   %eax,%eax
  801dd0:	78 13                	js     801de5 <spawn+0x1ed>
copy_shared_pages(envid_t child)
{
	// LAB 5: Your code here.
    uint32_t i;
    int r;
    for (i = 0; i != UTOP; i += PGSIZE) 
  801dd2:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801dd8:	81 fb 00 00 c0 ee    	cmp    $0xeec00000,%ebx
  801dde:	75 a4                	jne    801d84 <spawn+0x18c>
  801de0:	e9 a1 00 00 00       	jmp    801e86 <spawn+0x28e>
	close(fd);
	fd = -1;

	// Copy shared library state.
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);
  801de5:	50                   	push   %eax
  801de6:	68 12 32 80 00       	push   $0x803212
  801deb:	68 85 00 00 00       	push   $0x85
  801df0:	68 ec 31 80 00       	push   $0x8031ec
  801df5:	e8 f6 e3 ff ff       	call   8001f0 <_panic>

	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
		panic("sys_env_set_trapframe: %e", r);
  801dfa:	50                   	push   %eax
  801dfb:	68 28 32 80 00       	push   $0x803228
  801e00:	68 88 00 00 00       	push   $0x88
  801e05:	68 ec 31 80 00       	push   $0x8031ec
  801e0a:	e8 e1 e3 ff ff       	call   8001f0 <_panic>

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
  801e0f:	83 ec 08             	sub    $0x8,%esp
  801e12:	6a 02                	push   $0x2
  801e14:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801e1a:	e8 4e ef ff ff       	call   800d6d <sys_env_set_status>
  801e1f:	83 c4 10             	add    $0x10,%esp
  801e22:	85 c0                	test   %eax,%eax
  801e24:	79 52                	jns    801e78 <spawn+0x280>
		panic("sys_env_set_status: %e", r);
  801e26:	50                   	push   %eax
  801e27:	68 42 32 80 00       	push   $0x803242
  801e2c:	68 8b 00 00 00       	push   $0x8b
  801e31:	68 ec 31 80 00       	push   $0x8031ec
  801e36:	e8 b5 e3 ff ff       	call   8001f0 <_panic>
  801e3b:	89 c7                	mov    %eax,%edi

	return child;

error:
	sys_env_destroy(child);
  801e3d:	83 ec 0c             	sub    $0xc,%esp
  801e40:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801e46:	e8 48 ee ff ff       	call   800c93 <sys_env_destroy>
	close(fd);
  801e4b:	83 c4 04             	add    $0x4,%esp
  801e4e:	ff b5 90 fd ff ff    	pushl  -0x270(%ebp)
  801e54:	e8 0a f5 ff ff       	call   801363 <close>
	return r;
  801e59:	83 c4 10             	add    $0x10,%esp
		if (ph->p_type != ELF_PROG_LOAD)
			continue;
		perm = PTE_P | PTE_U;
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
  801e5c:	89 bd 94 fd ff ff    	mov    %edi,-0x26c(%ebp)
	return child;

error:
	sys_env_destroy(child);
	close(fd);
	return r;
  801e62:	eb 14                	jmp    801e78 <spawn+0x280>
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
		return r;
  801e64:	8b 85 90 fd ff ff    	mov    -0x270(%ebp),%eax
  801e6a:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)
  801e70:	eb 06                	jmp    801e78 <spawn+0x280>
	// Set up trap frame, including initial stack.
	child_tf = envs[ENVX(child)].env_tf;
	child_tf.tf_eip = elf->e_entry;

	if ((r = init_stack(child, argv, &child_tf.tf_esp, (USTACKTOP - PGSIZE))) < 0)
		return r;
  801e72:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)

error:
	sys_env_destroy(child);
	close(fd);
	return r;
}
  801e78:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  801e7e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e81:	5b                   	pop    %ebx
  801e82:	5e                   	pop    %esi
  801e83:	5f                   	pop    %edi
  801e84:	c9                   	leave  
  801e85:	c3                   	ret    

	// Copy shared library state.
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);

	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
  801e86:	83 ec 08             	sub    $0x8,%esp
  801e89:	8d 85 a4 fd ff ff    	lea    -0x25c(%ebp),%eax
  801e8f:	50                   	push   %eax
  801e90:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801e96:	e8 f5 ee ff ff       	call   800d90 <sys_env_set_trapframe>
  801e9b:	83 c4 10             	add    $0x10,%esp
  801e9e:	85 c0                	test   %eax,%eax
  801ea0:	0f 89 69 ff ff ff    	jns    801e0f <spawn+0x217>
  801ea6:	e9 4f ff ff ff       	jmp    801dfa <spawn+0x202>

00801eab <exec>:
// 		 0x80000000(MYTEMPLATE) to be template block cache. Then sys_exec is a system call to complete 
// 		 memory setting.
// Remember: When there is virtual memory in ELF linking address overlaped with MYTEMPLATE, exec will fail.
int
exec(const char *prog, const char **argv)
{
  801eab:	55                   	push   %ebp
  801eac:	89 e5                	mov    %esp,%ebp
  801eae:	57                   	push   %edi
  801eaf:	56                   	push   %esi
  801eb0:	53                   	push   %ebx
  801eb1:	81 ec 34 02 00 00    	sub    $0x234,%esp
	struct Elf *elf;
	struct Proghdr *ph;
	int perm;	


	if ((r = open(prog, O_RDONLY)) < 0)
  801eb7:	6a 00                	push   $0x0
  801eb9:	ff 75 08             	pushl  0x8(%ebp)
  801ebc:	e8 e3 f9 ff ff       	call   8018a4 <open>
  801ec1:	89 85 d0 fd ff ff    	mov    %eax,-0x230(%ebp)
  801ec7:	83 c4 10             	add    $0x10,%esp
  801eca:	85 c0                	test   %eax,%eax
  801ecc:	0f 88 a9 01 00 00    	js     80207b <exec+0x1d0>
		return r;
	fd = r;

	// Read elf header
	elf = (struct Elf*) elf_buf;
  801ed2:	8d bd e8 fd ff ff    	lea    -0x218(%ebp),%edi
	if (readn(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf)
  801ed8:	83 ec 04             	sub    $0x4,%esp
  801edb:	68 00 02 00 00       	push   $0x200
  801ee0:	57                   	push   %edi
  801ee1:	50                   	push   %eax
  801ee2:	e8 40 f6 ff ff       	call   801527 <readn>
  801ee7:	83 c4 10             	add    $0x10,%esp
  801eea:	3d 00 02 00 00       	cmp    $0x200,%eax
  801eef:	75 0c                	jne    801efd <exec+0x52>
	    || elf->e_magic != ELF_MAGIC) {
  801ef1:	81 bd e8 fd ff ff 7f 	cmpl   $0x464c457f,-0x218(%ebp)
  801ef8:	45 4c 46 
  801efb:	74 34                	je     801f31 <exec+0x86>
		close(fd);
  801efd:	83 ec 0c             	sub    $0xc,%esp
  801f00:	ff b5 d0 fd ff ff    	pushl  -0x230(%ebp)
  801f06:	e8 58 f4 ff ff       	call   801363 <close>
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
  801f0b:	83 c4 0c             	add    $0xc,%esp
  801f0e:	68 7f 45 4c 46       	push   $0x464c457f
  801f13:	ff 37                	pushl  (%edi)
  801f15:	68 f8 31 80 00       	push   $0x8031f8
  801f1a:	e8 a9 e3 ff ff       	call   8002c8 <cprintf>
		return -E_NOT_EXEC;
  801f1f:	83 c4 10             	add    $0x10,%esp
  801f22:	c7 85 d0 fd ff ff f2 	movl   $0xfffffff2,-0x230(%ebp)
  801f29:	ff ff ff 
  801f2c:	e9 4a 01 00 00       	jmp    80207b <exec+0x1d0>
	}


	// Set up program segments as defined in ELF header.
	uint32_t now_addr = MYTEMPLATE;
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  801f31:	8b 47 1c             	mov    0x1c(%edi),%eax
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801f34:	66 83 7f 2c 00       	cmpw   $0x0,0x2c(%edi)
  801f39:	0f 84 8b 00 00 00    	je     801fca <exec+0x11f>
	}


	// Set up program segments as defined in ELF header.
	uint32_t now_addr = MYTEMPLATE;
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  801f3f:	8d 9c 05 e8 fd ff ff 	lea    -0x218(%ebp,%eax,1),%ebx
		return -E_NOT_EXEC;
	}


	// Set up program segments as defined in ELF header.
	uint32_t now_addr = MYTEMPLATE;
  801f46:	c7 85 d4 fd ff ff 00 	movl   $0x80000000,-0x22c(%ebp)
  801f4d:	00 00 80 
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801f50:	be 00 00 00 00       	mov    $0x0,%esi
		if (ph->p_type != ELF_PROG_LOAD)
  801f55:	83 3b 01             	cmpl   $0x1,(%ebx)
  801f58:	75 62                	jne    801fbc <exec+0x111>
			continue;
		perm = PTE_P | PTE_U;
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
  801f5a:	8b 43 18             	mov    0x18(%ebx),%eax
  801f5d:	83 e0 02             	and    $0x2,%eax
	uint32_t now_addr = MYTEMPLATE;
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
		if (ph->p_type != ELF_PROG_LOAD)
			continue;
		perm = PTE_P | PTE_U;
  801f60:	83 f8 01             	cmp    $0x1,%eax
  801f63:	19 c0                	sbb    %eax,%eax
  801f65:	83 e0 fe             	and    $0xfffffffe,%eax
  801f68:	83 c0 07             	add    $0x7,%eax
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
			perm |= PTE_W;
		if ((r = map_segment(0, PGOFF(ph->p_va) + now_addr, ph->p_memsz,
  801f6b:	8b 4b 14             	mov    0x14(%ebx),%ecx
  801f6e:	8b 53 08             	mov    0x8(%ebx),%edx
  801f71:	81 e2 ff 0f 00 00    	and    $0xfff,%edx
  801f77:	03 95 d4 fd ff ff    	add    -0x22c(%ebp),%edx
  801f7d:	50                   	push   %eax
  801f7e:	ff 73 04             	pushl  0x4(%ebx)
  801f81:	ff 73 10             	pushl  0x10(%ebx)
  801f84:	ff b5 d0 fd ff ff    	pushl  -0x230(%ebp)
  801f8a:	b8 00 00 00 00       	mov    $0x0,%eax
  801f8f:	e8 a0 f9 ff ff       	call   801934 <map_segment>
  801f94:	83 c4 10             	add    $0x10,%esp
  801f97:	85 c0                	test   %eax,%eax
  801f99:	0f 88 a3 00 00 00    	js     802042 <exec+0x197>
				     fd, ph->p_filesz, ph->p_offset, perm)) < 0)
			goto error;
		now_addr += ROUNDUP(ph->p_memsz + PGOFF(ph->p_va), PGSIZE);
  801f9f:	8b 53 14             	mov    0x14(%ebx),%edx
  801fa2:	8b 43 08             	mov    0x8(%ebx),%eax
  801fa5:	25 ff 0f 00 00       	and    $0xfff,%eax
  801faa:	8d 84 02 ff 0f 00 00 	lea    0xfff(%edx,%eax,1),%eax
  801fb1:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801fb6:	01 85 d4 fd ff ff    	add    %eax,-0x22c(%ebp)


	// Set up program segments as defined in ELF header.
	uint32_t now_addr = MYTEMPLATE;
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801fbc:	46                   	inc    %esi
  801fbd:	0f b7 47 2c          	movzwl 0x2c(%edi),%eax
  801fc1:	39 f0                	cmp    %esi,%eax
  801fc3:	7e 0f                	jle    801fd4 <exec+0x129>
  801fc5:	83 c3 20             	add    $0x20,%ebx
  801fc8:	eb 8b                	jmp    801f55 <exec+0xaa>
		return -E_NOT_EXEC;
	}


	// Set up program segments as defined in ELF header.
	uint32_t now_addr = MYTEMPLATE;
  801fca:	c7 85 d4 fd ff ff 00 	movl   $0x80000000,-0x22c(%ebp)
  801fd1:	00 00 80 
		if ((r = map_segment(0, PGOFF(ph->p_va) + now_addr, ph->p_memsz,
				     fd, ph->p_filesz, ph->p_offset, perm)) < 0)
			goto error;
		now_addr += ROUNDUP(ph->p_memsz + PGOFF(ph->p_va), PGSIZE);
	}
	close(fd);
  801fd4:	83 ec 0c             	sub    $0xc,%esp
  801fd7:	ff b5 d0 fd ff ff    	pushl  -0x230(%ebp)
  801fdd:	e8 81 f3 ff ff       	call   801363 <close>
	fd = -1;

	// Set up Stack 
	if ((r = init_stack(0, argv, &tf_esp, now_addr)) < 0)
  801fe2:	83 c4 04             	add    $0x4,%esp
  801fe5:	8d 8d e4 fd ff ff    	lea    -0x21c(%ebp),%ecx
  801feb:	ff b5 d4 fd ff ff    	pushl  -0x22c(%ebp)
  801ff1:	8b 55 0c             	mov    0xc(%ebp),%edx
  801ff4:	b8 00 00 00 00       	mov    $0x0,%eax
  801ff9:	e8 61 fa ff ff       	call   801a5f <init_stack>
  801ffe:	89 85 d0 fd ff ff    	mov    %eax,-0x230(%ebp)
  802004:	83 c4 10             	add    $0x10,%esp
  802007:	85 c0                	test   %eax,%eax
  802009:	78 70                	js     80207b <exec+0x1d0>
		return r;

	// Syscall to exec
	if (sys_exec(elf->e_entry, tf_esp, (void *)(elf_buf + elf->e_phoff), elf->e_phnum) < 0)
  80200b:	0f b7 47 2c          	movzwl 0x2c(%edi),%eax
  80200f:	50                   	push   %eax
  802010:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  802016:	03 47 1c             	add    0x1c(%edi),%eax
  802019:	50                   	push   %eax
  80201a:	ff b5 e4 fd ff ff    	pushl  -0x21c(%ebp)
  802020:	ff 77 18             	pushl  0x18(%edi)
  802023:	e8 18 ee ff ff       	call   800e40 <sys_exec>
  802028:	83 c4 10             	add    $0x10,%esp
  80202b:	85 c0                	test   %eax,%eax
  80202d:	79 42                	jns    802071 <exec+0x1c6>
	}
	close(fd);
	fd = -1;

	// Set up Stack 
	if ((r = init_stack(0, argv, &tf_esp, now_addr)) < 0)
  80202f:	8b 85 d0 fd ff ff    	mov    -0x230(%ebp),%eax
  802035:	89 85 d4 fd ff ff    	mov    %eax,-0x22c(%ebp)
				     fd, ph->p_filesz, ph->p_offset, perm)) < 0)
			goto error;
		now_addr += ROUNDUP(ph->p_memsz + PGOFF(ph->p_va), PGSIZE);
	}
	close(fd);
	fd = -1;
  80203b:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
  802040:	eb 0c                	jmp    80204e <exec+0x1a3>
  802042:	89 85 d4 fd ff ff    	mov    %eax,-0x22c(%ebp)
	int perm;	


	if ((r = open(prog, O_RDONLY)) < 0)
		return r;
	fd = r;
  802048:	8b 9d d0 fd ff ff    	mov    -0x230(%ebp),%ebx
	if (sys_exec(elf->e_entry, tf_esp, (void *)(elf_buf + elf->e_phoff), elf->e_phnum) < 0)
		goto error;
	return 0;

error:
	sys_env_destroy(0);
  80204e:	83 ec 0c             	sub    $0xc,%esp
  802051:	6a 00                	push   $0x0
  802053:	e8 3b ec ff ff       	call   800c93 <sys_env_destroy>
	close(fd);
  802058:	89 1c 24             	mov    %ebx,(%esp)
  80205b:	e8 03 f3 ff ff       	call   801363 <close>
	return r;
  802060:	83 c4 10             	add    $0x10,%esp
  802063:	8b 85 d4 fd ff ff    	mov    -0x22c(%ebp),%eax
  802069:	89 85 d0 fd ff ff    	mov    %eax,-0x230(%ebp)
  80206f:	eb 0a                	jmp    80207b <exec+0x1d0>
		return r;

	// Syscall to exec
	if (sys_exec(elf->e_entry, tf_esp, (void *)(elf_buf + elf->e_phoff), elf->e_phnum) < 0)
		goto error;
	return 0;
  802071:	c7 85 d0 fd ff ff 00 	movl   $0x0,-0x230(%ebp)
  802078:	00 00 00 

error:
	sys_env_destroy(0);
	close(fd);
	return r;
}
  80207b:	8b 85 d0 fd ff ff    	mov    -0x230(%ebp),%eax
  802081:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802084:	5b                   	pop    %ebx
  802085:	5e                   	pop    %esi
  802086:	5f                   	pop    %edi
  802087:	c9                   	leave  
  802088:	c3                   	ret    

00802089 <execl>:
// Exec, taking command-line arguments array directly on the stack.
// NOTE: Must have a sentinal of NULL at the end of the args
// (none of the args may be NULL).
int
execl(const char *prog, const char *arg0, ...)
{
  802089:	55                   	push   %ebp
  80208a:	89 e5                	mov    %esp,%ebp
  80208c:	56                   	push   %esi
  80208d:	53                   	push   %ebx
  80208e:	8b 75 0c             	mov    0xc(%ebp),%esi
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  802091:	8d 45 14             	lea    0x14(%ebp),%eax
  802094:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  802098:	74 5f                	je     8020f9 <execl+0x70>
{
	// We calculate argc by advancing the args until we hit NULL.
	// The contract of the function guarantees that the last
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
  80209a:	b9 00 00 00 00       	mov    $0x0,%ecx
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
		argc++;
  80209f:	41                   	inc    %ecx
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  8020a0:	89 c2                	mov    %eax,%edx
  8020a2:	83 c0 04             	add    $0x4,%eax
  8020a5:	83 3a 00             	cmpl   $0x0,(%edx)
  8020a8:	75 f5                	jne    80209f <execl+0x16>
		argc++;
	va_end(vl);

	// Now that we have the size of the args, do a second pass
	// and store the values in a VLA, which has the format of argv
	const char *argv[argc+2];
  8020aa:	8d 04 8d 26 00 00 00 	lea    0x26(,%ecx,4),%eax
  8020b1:	83 e0 f0             	and    $0xfffffff0,%eax
  8020b4:	29 c4                	sub    %eax,%esp
  8020b6:	8d 44 24 0f          	lea    0xf(%esp),%eax
  8020ba:	83 e0 f0             	and    $0xfffffff0,%eax
  8020bd:	89 c3                	mov    %eax,%ebx
	argv[0] = arg0;
  8020bf:	89 30                	mov    %esi,(%eax)
	argv[argc+1] = NULL;
  8020c1:	c7 44 88 04 00 00 00 	movl   $0x0,0x4(%eax,%ecx,4)
  8020c8:	00 

	va_start(vl, arg0);
  8020c9:	8d 55 10             	lea    0x10(%ebp),%edx
	unsigned i;
	for(i=0;i<argc;i++)
  8020cc:	89 ce                	mov    %ecx,%esi
  8020ce:	85 c9                	test   %ecx,%ecx
  8020d0:	74 14                	je     8020e6 <execl+0x5d>
  8020d2:	b8 00 00 00 00       	mov    $0x0,%eax
		argv[i+1] = va_arg(vl, const char *);
  8020d7:	40                   	inc    %eax
  8020d8:	89 d1                	mov    %edx,%ecx
  8020da:	83 c2 04             	add    $0x4,%edx
  8020dd:	8b 09                	mov    (%ecx),%ecx
  8020df:	89 0c 83             	mov    %ecx,(%ebx,%eax,4)
	argv[0] = arg0;
	argv[argc+1] = NULL;

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  8020e2:	39 f0                	cmp    %esi,%eax
  8020e4:	72 f1                	jb     8020d7 <execl+0x4e>
		argv[i+1] = va_arg(vl, const char *);
	va_end(vl);
	return exec(prog, argv);
  8020e6:	83 ec 08             	sub    $0x8,%esp
  8020e9:	53                   	push   %ebx
  8020ea:	ff 75 08             	pushl  0x8(%ebp)
  8020ed:	e8 b9 fd ff ff       	call   801eab <exec>
}
  8020f2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8020f5:	5b                   	pop    %ebx
  8020f6:	5e                   	pop    %esi
  8020f7:	c9                   	leave  
  8020f8:	c3                   	ret    
		argc++;
	va_end(vl);

	// Now that we have the size of the args, do a second pass
	// and store the values in a VLA, which has the format of argv
	const char *argv[argc+2];
  8020f9:	83 ec 20             	sub    $0x20,%esp
  8020fc:	8d 44 24 0f          	lea    0xf(%esp),%eax
  802100:	83 e0 f0             	and    $0xfffffff0,%eax
  802103:	89 c3                	mov    %eax,%ebx
	argv[0] = arg0;
  802105:	89 30                	mov    %esi,(%eax)
	argv[argc+1] = NULL;
  802107:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
  80210e:	eb d6                	jmp    8020e6 <execl+0x5d>

00802110 <spawnl>:
// Spawn, taking command-line arguments array directly on the stack.
// NOTE: Must have a sentinal of NULL at the end of the args
// (none of the args may be NULL).
int
spawnl(const char *prog, const char *arg0, ...)
{
  802110:	55                   	push   %ebp
  802111:	89 e5                	mov    %esp,%ebp
  802113:	56                   	push   %esi
  802114:	53                   	push   %ebx
  802115:	8b 75 0c             	mov    0xc(%ebp),%esi
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  802118:	8d 45 14             	lea    0x14(%ebp),%eax
  80211b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80211f:	74 5f                	je     802180 <spawnl+0x70>
{
	// We calculate argc by advancing the args until we hit NULL.
	// The contract of the function guarantees that the last
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
  802121:	b9 00 00 00 00       	mov    $0x0,%ecx
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
		argc++;
  802126:	41                   	inc    %ecx
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  802127:	89 c2                	mov    %eax,%edx
  802129:	83 c0 04             	add    $0x4,%eax
  80212c:	83 3a 00             	cmpl   $0x0,(%edx)
  80212f:	75 f5                	jne    802126 <spawnl+0x16>
		argc++;
	va_end(vl);

	// Now that we have the size of the args, do a second pass
	// and store the values in a VLA, which has the format of argv
	const char *argv[argc+2];
  802131:	8d 04 8d 26 00 00 00 	lea    0x26(,%ecx,4),%eax
  802138:	83 e0 f0             	and    $0xfffffff0,%eax
  80213b:	29 c4                	sub    %eax,%esp
  80213d:	8d 44 24 0f          	lea    0xf(%esp),%eax
  802141:	83 e0 f0             	and    $0xfffffff0,%eax
  802144:	89 c3                	mov    %eax,%ebx
	argv[0] = arg0;
  802146:	89 30                	mov    %esi,(%eax)
	argv[argc+1] = NULL;
  802148:	c7 44 88 04 00 00 00 	movl   $0x0,0x4(%eax,%ecx,4)
  80214f:	00 

	va_start(vl, arg0);
  802150:	8d 55 10             	lea    0x10(%ebp),%edx
	unsigned i;
	for(i=0;i<argc;i++)
  802153:	89 ce                	mov    %ecx,%esi
  802155:	85 c9                	test   %ecx,%ecx
  802157:	74 14                	je     80216d <spawnl+0x5d>
  802159:	b8 00 00 00 00       	mov    $0x0,%eax
		argv[i+1] = va_arg(vl, const char *);
  80215e:	40                   	inc    %eax
  80215f:	89 d1                	mov    %edx,%ecx
  802161:	83 c2 04             	add    $0x4,%edx
  802164:	8b 09                	mov    (%ecx),%ecx
  802166:	89 0c 83             	mov    %ecx,(%ebx,%eax,4)
	argv[0] = arg0;
	argv[argc+1] = NULL;

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  802169:	39 f0                	cmp    %esi,%eax
  80216b:	72 f1                	jb     80215e <spawnl+0x4e>
		argv[i+1] = va_arg(vl, const char *);
	va_end(vl);
	return spawn(prog, argv);
  80216d:	83 ec 08             	sub    $0x8,%esp
  802170:	53                   	push   %ebx
  802171:	ff 75 08             	pushl  0x8(%ebp)
  802174:	e8 7f fa ff ff       	call   801bf8 <spawn>
}
  802179:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80217c:	5b                   	pop    %ebx
  80217d:	5e                   	pop    %esi
  80217e:	c9                   	leave  
  80217f:	c3                   	ret    
		argc++;
	va_end(vl);

	// Now that we have the size of the args, do a second pass
	// and store the values in a VLA, which has the format of argv
	const char *argv[argc+2];
  802180:	83 ec 20             	sub    $0x20,%esp
  802183:	8d 44 24 0f          	lea    0xf(%esp),%eax
  802187:	83 e0 f0             	and    $0xfffffff0,%eax
  80218a:	89 c3                	mov    %eax,%ebx
	argv[0] = arg0;
  80218c:	89 30                	mov    %esi,(%eax)
	argv[argc+1] = NULL;
  80218e:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
  802195:	eb d6                	jmp    80216d <spawnl+0x5d>
	...

00802198 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  802198:	55                   	push   %ebp
  802199:	89 e5                	mov    %esp,%ebp
  80219b:	56                   	push   %esi
  80219c:	53                   	push   %ebx
  80219d:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8021a0:	83 ec 0c             	sub    $0xc,%esp
  8021a3:	ff 75 08             	pushl  0x8(%ebp)
  8021a6:	e8 e9 ef ff ff       	call   801194 <fd2data>
  8021ab:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  8021ad:	83 c4 08             	add    $0x8,%esp
  8021b0:	68 82 32 80 00       	push   $0x803282
  8021b5:	56                   	push   %esi
  8021b6:	e8 c3 e6 ff ff       	call   80087e <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8021bb:	8b 43 04             	mov    0x4(%ebx),%eax
  8021be:	2b 03                	sub    (%ebx),%eax
  8021c0:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  8021c6:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  8021cd:	00 00 00 
	stat->st_dev = &devpipe;
  8021d0:	c7 86 88 00 00 00 28 	movl   $0x804028,0x88(%esi)
  8021d7:	40 80 00 
	return 0;
}
  8021da:	b8 00 00 00 00       	mov    $0x0,%eax
  8021df:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8021e2:	5b                   	pop    %ebx
  8021e3:	5e                   	pop    %esi
  8021e4:	c9                   	leave  
  8021e5:	c3                   	ret    

008021e6 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8021e6:	55                   	push   %ebp
  8021e7:	89 e5                	mov    %esp,%ebp
  8021e9:	53                   	push   %ebx
  8021ea:	83 ec 0c             	sub    $0xc,%esp
  8021ed:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8021f0:	53                   	push   %ebx
  8021f1:	6a 00                	push   $0x0
  8021f3:	e8 52 eb ff ff       	call   800d4a <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8021f8:	89 1c 24             	mov    %ebx,(%esp)
  8021fb:	e8 94 ef ff ff       	call   801194 <fd2data>
  802200:	83 c4 08             	add    $0x8,%esp
  802203:	50                   	push   %eax
  802204:	6a 00                	push   $0x0
  802206:	e8 3f eb ff ff       	call   800d4a <sys_page_unmap>
}
  80220b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80220e:	c9                   	leave  
  80220f:	c3                   	ret    

00802210 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  802210:	55                   	push   %ebp
  802211:	89 e5                	mov    %esp,%ebp
  802213:	57                   	push   %edi
  802214:	56                   	push   %esi
  802215:	53                   	push   %ebx
  802216:	83 ec 1c             	sub    $0x1c,%esp
  802219:	89 c7                	mov    %eax,%edi
  80221b:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  80221e:	a1 04 50 80 00       	mov    0x805004,%eax
  802223:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  802226:	83 ec 0c             	sub    $0xc,%esp
  802229:	57                   	push   %edi
  80222a:	e8 b1 06 00 00       	call   8028e0 <pageref>
  80222f:	89 c6                	mov    %eax,%esi
  802231:	83 c4 04             	add    $0x4,%esp
  802234:	ff 75 e4             	pushl  -0x1c(%ebp)
  802237:	e8 a4 06 00 00       	call   8028e0 <pageref>
  80223c:	83 c4 10             	add    $0x10,%esp
  80223f:	39 c6                	cmp    %eax,%esi
  802241:	0f 94 c0             	sete   %al
  802244:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  802247:	8b 15 04 50 80 00    	mov    0x805004,%edx
  80224d:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  802250:	39 cb                	cmp    %ecx,%ebx
  802252:	75 08                	jne    80225c <_pipeisclosed+0x4c>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  802254:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802257:	5b                   	pop    %ebx
  802258:	5e                   	pop    %esi
  802259:	5f                   	pop    %edi
  80225a:	c9                   	leave  
  80225b:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  80225c:	83 f8 01             	cmp    $0x1,%eax
  80225f:	75 bd                	jne    80221e <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  802261:	8b 42 58             	mov    0x58(%edx),%eax
  802264:	6a 01                	push   $0x1
  802266:	50                   	push   %eax
  802267:	53                   	push   %ebx
  802268:	68 89 32 80 00       	push   $0x803289
  80226d:	e8 56 e0 ff ff       	call   8002c8 <cprintf>
  802272:	83 c4 10             	add    $0x10,%esp
  802275:	eb a7                	jmp    80221e <_pipeisclosed+0xe>

00802277 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  802277:	55                   	push   %ebp
  802278:	89 e5                	mov    %esp,%ebp
  80227a:	57                   	push   %edi
  80227b:	56                   	push   %esi
  80227c:	53                   	push   %ebx
  80227d:	83 ec 28             	sub    $0x28,%esp
  802280:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  802283:	56                   	push   %esi
  802284:	e8 0b ef ff ff       	call   801194 <fd2data>
  802289:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80228b:	83 c4 10             	add    $0x10,%esp
  80228e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  802292:	75 4a                	jne    8022de <devpipe_write+0x67>
  802294:	bf 00 00 00 00       	mov    $0x0,%edi
  802299:	eb 56                	jmp    8022f1 <devpipe_write+0x7a>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  80229b:	89 da                	mov    %ebx,%edx
  80229d:	89 f0                	mov    %esi,%eax
  80229f:	e8 6c ff ff ff       	call   802210 <_pipeisclosed>
  8022a4:	85 c0                	test   %eax,%eax
  8022a6:	75 4d                	jne    8022f5 <devpipe_write+0x7e>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  8022a8:	e8 2c ea ff ff       	call   800cd9 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8022ad:	8b 43 04             	mov    0x4(%ebx),%eax
  8022b0:	8b 13                	mov    (%ebx),%edx
  8022b2:	83 c2 20             	add    $0x20,%edx
  8022b5:	39 d0                	cmp    %edx,%eax
  8022b7:	73 e2                	jae    80229b <devpipe_write+0x24>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  8022b9:	89 c2                	mov    %eax,%edx
  8022bb:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  8022c1:	79 05                	jns    8022c8 <devpipe_write+0x51>
  8022c3:	4a                   	dec    %edx
  8022c4:	83 ca e0             	or     $0xffffffe0,%edx
  8022c7:	42                   	inc    %edx
  8022c8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8022cb:	8a 0c 39             	mov    (%ecx,%edi,1),%cl
  8022ce:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  8022d2:	40                   	inc    %eax
  8022d3:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8022d6:	47                   	inc    %edi
  8022d7:	39 7d 10             	cmp    %edi,0x10(%ebp)
  8022da:	77 07                	ja     8022e3 <devpipe_write+0x6c>
  8022dc:	eb 13                	jmp    8022f1 <devpipe_write+0x7a>
  8022de:	bf 00 00 00 00       	mov    $0x0,%edi
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8022e3:	8b 43 04             	mov    0x4(%ebx),%eax
  8022e6:	8b 13                	mov    (%ebx),%edx
  8022e8:	83 c2 20             	add    $0x20,%edx
  8022eb:	39 d0                	cmp    %edx,%eax
  8022ed:	73 ac                	jae    80229b <devpipe_write+0x24>
  8022ef:	eb c8                	jmp    8022b9 <devpipe_write+0x42>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  8022f1:	89 f8                	mov    %edi,%eax
  8022f3:	eb 05                	jmp    8022fa <devpipe_write+0x83>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8022f5:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  8022fa:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8022fd:	5b                   	pop    %ebx
  8022fe:	5e                   	pop    %esi
  8022ff:	5f                   	pop    %edi
  802300:	c9                   	leave  
  802301:	c3                   	ret    

00802302 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  802302:	55                   	push   %ebp
  802303:	89 e5                	mov    %esp,%ebp
  802305:	57                   	push   %edi
  802306:	56                   	push   %esi
  802307:	53                   	push   %ebx
  802308:	83 ec 18             	sub    $0x18,%esp
  80230b:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  80230e:	57                   	push   %edi
  80230f:	e8 80 ee ff ff       	call   801194 <fd2data>
  802314:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802316:	83 c4 10             	add    $0x10,%esp
  802319:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80231d:	75 44                	jne    802363 <devpipe_read+0x61>
  80231f:	be 00 00 00 00       	mov    $0x0,%esi
  802324:	eb 4f                	jmp    802375 <devpipe_read+0x73>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
				return i;
  802326:	89 f0                	mov    %esi,%eax
  802328:	eb 54                	jmp    80237e <devpipe_read+0x7c>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  80232a:	89 da                	mov    %ebx,%edx
  80232c:	89 f8                	mov    %edi,%eax
  80232e:	e8 dd fe ff ff       	call   802210 <_pipeisclosed>
  802333:	85 c0                	test   %eax,%eax
  802335:	75 42                	jne    802379 <devpipe_read+0x77>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  802337:	e8 9d e9 ff ff       	call   800cd9 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  80233c:	8b 03                	mov    (%ebx),%eax
  80233e:	3b 43 04             	cmp    0x4(%ebx),%eax
  802341:	74 e7                	je     80232a <devpipe_read+0x28>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  802343:	25 1f 00 00 80       	and    $0x8000001f,%eax
  802348:	79 05                	jns    80234f <devpipe_read+0x4d>
  80234a:	48                   	dec    %eax
  80234b:	83 c8 e0             	or     $0xffffffe0,%eax
  80234e:	40                   	inc    %eax
  80234f:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  802353:	8b 55 0c             	mov    0xc(%ebp),%edx
  802356:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  802359:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80235b:	46                   	inc    %esi
  80235c:	39 75 10             	cmp    %esi,0x10(%ebp)
  80235f:	77 07                	ja     802368 <devpipe_read+0x66>
  802361:	eb 12                	jmp    802375 <devpipe_read+0x73>
  802363:	be 00 00 00 00       	mov    $0x0,%esi
		while (p->p_rpos == p->p_wpos) {
  802368:	8b 03                	mov    (%ebx),%eax
  80236a:	3b 43 04             	cmp    0x4(%ebx),%eax
  80236d:	75 d4                	jne    802343 <devpipe_read+0x41>
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  80236f:	85 f6                	test   %esi,%esi
  802371:	75 b3                	jne    802326 <devpipe_read+0x24>
  802373:	eb b5                	jmp    80232a <devpipe_read+0x28>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  802375:	89 f0                	mov    %esi,%eax
  802377:	eb 05                	jmp    80237e <devpipe_read+0x7c>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802379:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  80237e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802381:	5b                   	pop    %ebx
  802382:	5e                   	pop    %esi
  802383:	5f                   	pop    %edi
  802384:	c9                   	leave  
  802385:	c3                   	ret    

00802386 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  802386:	55                   	push   %ebp
  802387:	89 e5                	mov    %esp,%ebp
  802389:	57                   	push   %edi
  80238a:	56                   	push   %esi
  80238b:	53                   	push   %ebx
  80238c:	83 ec 28             	sub    $0x28,%esp
  80238f:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  802392:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  802395:	50                   	push   %eax
  802396:	e8 11 ee ff ff       	call   8011ac <fd_alloc>
  80239b:	89 c3                	mov    %eax,%ebx
  80239d:	83 c4 10             	add    $0x10,%esp
  8023a0:	85 c0                	test   %eax,%eax
  8023a2:	0f 88 24 01 00 00    	js     8024cc <pipe+0x146>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8023a8:	83 ec 04             	sub    $0x4,%esp
  8023ab:	68 07 04 00 00       	push   $0x407
  8023b0:	ff 75 e4             	pushl  -0x1c(%ebp)
  8023b3:	6a 00                	push   $0x0
  8023b5:	e8 46 e9 ff ff       	call   800d00 <sys_page_alloc>
  8023ba:	89 c3                	mov    %eax,%ebx
  8023bc:	83 c4 10             	add    $0x10,%esp
  8023bf:	85 c0                	test   %eax,%eax
  8023c1:	0f 88 05 01 00 00    	js     8024cc <pipe+0x146>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  8023c7:	83 ec 0c             	sub    $0xc,%esp
  8023ca:	8d 45 e0             	lea    -0x20(%ebp),%eax
  8023cd:	50                   	push   %eax
  8023ce:	e8 d9 ed ff ff       	call   8011ac <fd_alloc>
  8023d3:	89 c3                	mov    %eax,%ebx
  8023d5:	83 c4 10             	add    $0x10,%esp
  8023d8:	85 c0                	test   %eax,%eax
  8023da:	0f 88 dc 00 00 00    	js     8024bc <pipe+0x136>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8023e0:	83 ec 04             	sub    $0x4,%esp
  8023e3:	68 07 04 00 00       	push   $0x407
  8023e8:	ff 75 e0             	pushl  -0x20(%ebp)
  8023eb:	6a 00                	push   $0x0
  8023ed:	e8 0e e9 ff ff       	call   800d00 <sys_page_alloc>
  8023f2:	89 c3                	mov    %eax,%ebx
  8023f4:	83 c4 10             	add    $0x10,%esp
  8023f7:	85 c0                	test   %eax,%eax
  8023f9:	0f 88 bd 00 00 00    	js     8024bc <pipe+0x136>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  8023ff:	83 ec 0c             	sub    $0xc,%esp
  802402:	ff 75 e4             	pushl  -0x1c(%ebp)
  802405:	e8 8a ed ff ff       	call   801194 <fd2data>
  80240a:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80240c:	83 c4 0c             	add    $0xc,%esp
  80240f:	68 07 04 00 00       	push   $0x407
  802414:	50                   	push   %eax
  802415:	6a 00                	push   $0x0
  802417:	e8 e4 e8 ff ff       	call   800d00 <sys_page_alloc>
  80241c:	89 c3                	mov    %eax,%ebx
  80241e:	83 c4 10             	add    $0x10,%esp
  802421:	85 c0                	test   %eax,%eax
  802423:	0f 88 83 00 00 00    	js     8024ac <pipe+0x126>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802429:	83 ec 0c             	sub    $0xc,%esp
  80242c:	ff 75 e0             	pushl  -0x20(%ebp)
  80242f:	e8 60 ed ff ff       	call   801194 <fd2data>
  802434:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  80243b:	50                   	push   %eax
  80243c:	6a 00                	push   $0x0
  80243e:	56                   	push   %esi
  80243f:	6a 00                	push   $0x0
  802441:	e8 de e8 ff ff       	call   800d24 <sys_page_map>
  802446:	89 c3                	mov    %eax,%ebx
  802448:	83 c4 20             	add    $0x20,%esp
  80244b:	85 c0                	test   %eax,%eax
  80244d:	78 4f                	js     80249e <pipe+0x118>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  80244f:	8b 15 28 40 80 00    	mov    0x804028,%edx
  802455:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802458:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  80245a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80245d:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  802464:	8b 15 28 40 80 00    	mov    0x804028,%edx
  80246a:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80246d:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  80246f:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802472:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  802479:	83 ec 0c             	sub    $0xc,%esp
  80247c:	ff 75 e4             	pushl  -0x1c(%ebp)
  80247f:	e8 00 ed ff ff       	call   801184 <fd2num>
  802484:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  802486:	83 c4 04             	add    $0x4,%esp
  802489:	ff 75 e0             	pushl  -0x20(%ebp)
  80248c:	e8 f3 ec ff ff       	call   801184 <fd2num>
  802491:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  802494:	83 c4 10             	add    $0x10,%esp
  802497:	bb 00 00 00 00       	mov    $0x0,%ebx
  80249c:	eb 2e                	jmp    8024cc <pipe+0x146>

    err3:
	sys_page_unmap(0, va);
  80249e:	83 ec 08             	sub    $0x8,%esp
  8024a1:	56                   	push   %esi
  8024a2:	6a 00                	push   $0x0
  8024a4:	e8 a1 e8 ff ff       	call   800d4a <sys_page_unmap>
  8024a9:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  8024ac:	83 ec 08             	sub    $0x8,%esp
  8024af:	ff 75 e0             	pushl  -0x20(%ebp)
  8024b2:	6a 00                	push   $0x0
  8024b4:	e8 91 e8 ff ff       	call   800d4a <sys_page_unmap>
  8024b9:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  8024bc:	83 ec 08             	sub    $0x8,%esp
  8024bf:	ff 75 e4             	pushl  -0x1c(%ebp)
  8024c2:	6a 00                	push   $0x0
  8024c4:	e8 81 e8 ff ff       	call   800d4a <sys_page_unmap>
  8024c9:	83 c4 10             	add    $0x10,%esp
    err:
	return r;
}
  8024cc:	89 d8                	mov    %ebx,%eax
  8024ce:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8024d1:	5b                   	pop    %ebx
  8024d2:	5e                   	pop    %esi
  8024d3:	5f                   	pop    %edi
  8024d4:	c9                   	leave  
  8024d5:	c3                   	ret    

008024d6 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  8024d6:	55                   	push   %ebp
  8024d7:	89 e5                	mov    %esp,%ebp
  8024d9:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8024dc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8024df:	50                   	push   %eax
  8024e0:	ff 75 08             	pushl  0x8(%ebp)
  8024e3:	e8 37 ed ff ff       	call   80121f <fd_lookup>
  8024e8:	83 c4 10             	add    $0x10,%esp
  8024eb:	85 c0                	test   %eax,%eax
  8024ed:	78 18                	js     802507 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  8024ef:	83 ec 0c             	sub    $0xc,%esp
  8024f2:	ff 75 f4             	pushl  -0xc(%ebp)
  8024f5:	e8 9a ec ff ff       	call   801194 <fd2data>
	return _pipeisclosed(fd, p);
  8024fa:	89 c2                	mov    %eax,%edx
  8024fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8024ff:	e8 0c fd ff ff       	call   802210 <_pipeisclosed>
  802504:	83 c4 10             	add    $0x10,%esp
}
  802507:	c9                   	leave  
  802508:	c3                   	ret    
  802509:	00 00                	add    %al,(%eax)
	...

0080250c <wait>:
#include <inc/lib.h>

// Waits until 'envid' exits.
void
wait(envid_t envid)
{
  80250c:	55                   	push   %ebp
  80250d:	89 e5                	mov    %esp,%ebp
  80250f:	57                   	push   %edi
  802510:	56                   	push   %esi
  802511:	53                   	push   %ebx
  802512:	83 ec 0c             	sub    $0xc,%esp
  802515:	8b 45 08             	mov    0x8(%ebp),%eax
	const volatile struct Env *e;

	assert(envid != 0);
  802518:	85 c0                	test   %eax,%eax
  80251a:	75 16                	jne    802532 <wait+0x26>
  80251c:	68 a1 32 80 00       	push   $0x8032a1
  802521:	68 a3 31 80 00       	push   $0x8031a3
  802526:	6a 09                	push   $0x9
  802528:	68 ac 32 80 00       	push   $0x8032ac
  80252d:	e8 be dc ff ff       	call   8001f0 <_panic>
	e = &envs[ENVX(envid)];
  802532:	89 c6                	mov    %eax,%esi
  802534:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
	while (e->env_id == envid && e->env_status != ENV_FREE)
  80253a:	8d 0c b5 00 00 00 00 	lea    0x0(,%esi,4),%ecx
  802541:	89 f2                	mov    %esi,%edx
  802543:	c1 e2 07             	shl    $0x7,%edx
  802546:	29 ca                	sub    %ecx,%edx
  802548:	81 c2 08 00 c0 ee    	add    $0xeec00008,%edx
  80254e:	8b 7a 40             	mov    0x40(%edx),%edi
  802551:	39 c7                	cmp    %eax,%edi
  802553:	75 37                	jne    80258c <wait+0x80>
  802555:	89 f0                	mov    %esi,%eax
  802557:	c1 e0 07             	shl    $0x7,%eax
  80255a:	29 c8                	sub    %ecx,%eax
  80255c:	05 04 00 c0 ee       	add    $0xeec00004,%eax
  802561:	8b 40 50             	mov    0x50(%eax),%eax
  802564:	85 c0                	test   %eax,%eax
  802566:	74 24                	je     80258c <wait+0x80>
  802568:	c1 e6 07             	shl    $0x7,%esi
  80256b:	29 ce                	sub    %ecx,%esi
  80256d:	8d 9e 08 00 c0 ee    	lea    -0x113ffff8(%esi),%ebx
  802573:	81 c6 04 00 c0 ee    	add    $0xeec00004,%esi
		sys_yield();
  802579:	e8 5b e7 ff ff       	call   800cd9 <sys_yield>
{
	const volatile struct Env *e;

	assert(envid != 0);
	e = &envs[ENVX(envid)];
	while (e->env_id == envid && e->env_status != ENV_FREE)
  80257e:	8b 43 40             	mov    0x40(%ebx),%eax
  802581:	39 f8                	cmp    %edi,%eax
  802583:	75 07                	jne    80258c <wait+0x80>
  802585:	8b 46 50             	mov    0x50(%esi),%eax
  802588:	85 c0                	test   %eax,%eax
  80258a:	75 ed                	jne    802579 <wait+0x6d>
		sys_yield();
}
  80258c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80258f:	5b                   	pop    %ebx
  802590:	5e                   	pop    %esi
  802591:	5f                   	pop    %edi
  802592:	c9                   	leave  
  802593:	c3                   	ret    

00802594 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  802594:	55                   	push   %ebp
  802595:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  802597:	b8 00 00 00 00       	mov    $0x0,%eax
  80259c:	c9                   	leave  
  80259d:	c3                   	ret    

0080259e <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80259e:	55                   	push   %ebp
  80259f:	89 e5                	mov    %esp,%ebp
  8025a1:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  8025a4:	68 b7 32 80 00       	push   $0x8032b7
  8025a9:	ff 75 0c             	pushl  0xc(%ebp)
  8025ac:	e8 cd e2 ff ff       	call   80087e <strcpy>
	return 0;
}
  8025b1:	b8 00 00 00 00       	mov    $0x0,%eax
  8025b6:	c9                   	leave  
  8025b7:	c3                   	ret    

008025b8 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8025b8:	55                   	push   %ebp
  8025b9:	89 e5                	mov    %esp,%ebp
  8025bb:	57                   	push   %edi
  8025bc:	56                   	push   %esi
  8025bd:	53                   	push   %ebx
  8025be:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8025c4:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8025c8:	74 45                	je     80260f <devcons_write+0x57>
  8025ca:	b8 00 00 00 00       	mov    $0x0,%eax
  8025cf:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8025d4:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  8025da:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8025dd:	29 c3                	sub    %eax,%ebx
		if (m > sizeof(buf) - 1)
  8025df:	83 fb 7f             	cmp    $0x7f,%ebx
  8025e2:	76 05                	jbe    8025e9 <devcons_write+0x31>
			m = sizeof(buf) - 1;
  8025e4:	bb 7f 00 00 00       	mov    $0x7f,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  8025e9:	83 ec 04             	sub    $0x4,%esp
  8025ec:	53                   	push   %ebx
  8025ed:	03 45 0c             	add    0xc(%ebp),%eax
  8025f0:	50                   	push   %eax
  8025f1:	57                   	push   %edi
  8025f2:	e8 48 e4 ff ff       	call   800a3f <memmove>
		sys_cputs(buf, m);
  8025f7:	83 c4 08             	add    $0x8,%esp
  8025fa:	53                   	push   %ebx
  8025fb:	57                   	push   %edi
  8025fc:	e8 48 e6 ff ff       	call   800c49 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802601:	01 de                	add    %ebx,%esi
  802603:	89 f0                	mov    %esi,%eax
  802605:	83 c4 10             	add    $0x10,%esp
  802608:	3b 75 10             	cmp    0x10(%ebp),%esi
  80260b:	72 cd                	jb     8025da <devcons_write+0x22>
  80260d:	eb 05                	jmp    802614 <devcons_write+0x5c>
  80260f:	be 00 00 00 00       	mov    $0x0,%esi
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  802614:	89 f0                	mov    %esi,%eax
  802616:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802619:	5b                   	pop    %ebx
  80261a:	5e                   	pop    %esi
  80261b:	5f                   	pop    %edi
  80261c:	c9                   	leave  
  80261d:	c3                   	ret    

0080261e <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  80261e:	55                   	push   %ebp
  80261f:	89 e5                	mov    %esp,%ebp
  802621:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  802624:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  802628:	75 07                	jne    802631 <devcons_read+0x13>
  80262a:	eb 25                	jmp    802651 <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  80262c:	e8 a8 e6 ff ff       	call   800cd9 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  802631:	e8 39 e6 ff ff       	call   800c6f <sys_cgetc>
  802636:	85 c0                	test   %eax,%eax
  802638:	74 f2                	je     80262c <devcons_read+0xe>
  80263a:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  80263c:	85 c0                	test   %eax,%eax
  80263e:	78 1d                	js     80265d <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  802640:	83 f8 04             	cmp    $0x4,%eax
  802643:	74 13                	je     802658 <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  802645:	8b 45 0c             	mov    0xc(%ebp),%eax
  802648:	88 10                	mov    %dl,(%eax)
	return 1;
  80264a:	b8 01 00 00 00       	mov    $0x1,%eax
  80264f:	eb 0c                	jmp    80265d <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  802651:	b8 00 00 00 00       	mov    $0x0,%eax
  802656:	eb 05                	jmp    80265d <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  802658:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  80265d:	c9                   	leave  
  80265e:	c3                   	ret    

0080265f <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  80265f:	55                   	push   %ebp
  802660:	89 e5                	mov    %esp,%ebp
  802662:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  802665:	8b 45 08             	mov    0x8(%ebp),%eax
  802668:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  80266b:	6a 01                	push   $0x1
  80266d:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802670:	50                   	push   %eax
  802671:	e8 d3 e5 ff ff       	call   800c49 <sys_cputs>
  802676:	83 c4 10             	add    $0x10,%esp
}
  802679:	c9                   	leave  
  80267a:	c3                   	ret    

0080267b <getchar>:

int
getchar(void)
{
  80267b:	55                   	push   %ebp
  80267c:	89 e5                	mov    %esp,%ebp
  80267e:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  802681:	6a 01                	push   $0x1
  802683:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802686:	50                   	push   %eax
  802687:	6a 00                	push   $0x0
  802689:	e8 12 ee ff ff       	call   8014a0 <read>
	if (r < 0)
  80268e:	83 c4 10             	add    $0x10,%esp
  802691:	85 c0                	test   %eax,%eax
  802693:	78 0f                	js     8026a4 <getchar+0x29>
		return r;
	if (r < 1)
  802695:	85 c0                	test   %eax,%eax
  802697:	7e 06                	jle    80269f <getchar+0x24>
		return -E_EOF;
	return c;
  802699:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  80269d:	eb 05                	jmp    8026a4 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  80269f:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  8026a4:	c9                   	leave  
  8026a5:	c3                   	ret    

008026a6 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  8026a6:	55                   	push   %ebp
  8026a7:	89 e5                	mov    %esp,%ebp
  8026a9:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8026ac:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8026af:	50                   	push   %eax
  8026b0:	ff 75 08             	pushl  0x8(%ebp)
  8026b3:	e8 67 eb ff ff       	call   80121f <fd_lookup>
  8026b8:	83 c4 10             	add    $0x10,%esp
  8026bb:	85 c0                	test   %eax,%eax
  8026bd:	78 11                	js     8026d0 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  8026bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8026c2:	8b 15 44 40 80 00    	mov    0x804044,%edx
  8026c8:	39 10                	cmp    %edx,(%eax)
  8026ca:	0f 94 c0             	sete   %al
  8026cd:	0f b6 c0             	movzbl %al,%eax
}
  8026d0:	c9                   	leave  
  8026d1:	c3                   	ret    

008026d2 <opencons>:

int
opencons(void)
{
  8026d2:	55                   	push   %ebp
  8026d3:	89 e5                	mov    %esp,%ebp
  8026d5:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8026d8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8026db:	50                   	push   %eax
  8026dc:	e8 cb ea ff ff       	call   8011ac <fd_alloc>
  8026e1:	83 c4 10             	add    $0x10,%esp
  8026e4:	85 c0                	test   %eax,%eax
  8026e6:	78 3a                	js     802722 <opencons+0x50>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8026e8:	83 ec 04             	sub    $0x4,%esp
  8026eb:	68 07 04 00 00       	push   $0x407
  8026f0:	ff 75 f4             	pushl  -0xc(%ebp)
  8026f3:	6a 00                	push   $0x0
  8026f5:	e8 06 e6 ff ff       	call   800d00 <sys_page_alloc>
  8026fa:	83 c4 10             	add    $0x10,%esp
  8026fd:	85 c0                	test   %eax,%eax
  8026ff:	78 21                	js     802722 <opencons+0x50>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  802701:	8b 15 44 40 80 00    	mov    0x804044,%edx
  802707:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80270a:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80270c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80270f:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  802716:	83 ec 0c             	sub    $0xc,%esp
  802719:	50                   	push   %eax
  80271a:	e8 65 ea ff ff       	call   801184 <fd2num>
  80271f:	83 c4 10             	add    $0x10,%esp
}
  802722:	c9                   	leave  
  802723:	c3                   	ret    

00802724 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  802724:	55                   	push   %ebp
  802725:	89 e5                	mov    %esp,%ebp
  802727:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  80272a:	83 3d 00 70 80 00 00 	cmpl   $0x0,0x807000
  802731:	75 52                	jne    802785 <set_pgfault_handler+0x61>
		// First time through!	
		// LAB 4: Your code here.

		//int sys_page_alloc(envid_t envid, void *va, int perm)
		r = sys_page_alloc(0, (void*)(UXSTACKTOP - PGSIZE), PTE_U | PTE_W | PTE_P);
  802733:	83 ec 04             	sub    $0x4,%esp
  802736:	6a 07                	push   $0x7
  802738:	68 00 f0 bf ee       	push   $0xeebff000
  80273d:	6a 00                	push   $0x0
  80273f:	e8 bc e5 ff ff       	call   800d00 <sys_page_alloc>
		if (r < 0) {
  802744:	83 c4 10             	add    $0x10,%esp
  802747:	85 c0                	test   %eax,%eax
  802749:	79 12                	jns    80275d <set_pgfault_handler+0x39>
			panic("sys_page_alloc error : %e\n", r);
  80274b:	50                   	push   %eax
  80274c:	68 c3 32 80 00       	push   $0x8032c3
  802751:	6a 24                	push   $0x24
  802753:	68 de 32 80 00       	push   $0x8032de
  802758:	e8 93 da ff ff       	call   8001f0 <_panic>
		}

		// how to know envid, put 0, envid2env will help us to get curenv in syscall
		r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);		
  80275d:	83 ec 08             	sub    $0x8,%esp
  802760:	68 90 27 80 00       	push   $0x802790
  802765:	6a 00                	push   $0x0
  802767:	e8 47 e6 ff ff       	call   800db3 <sys_env_set_pgfault_upcall>
		if (r < 0) {
  80276c:	83 c4 10             	add    $0x10,%esp
  80276f:	85 c0                	test   %eax,%eax
  802771:	79 12                	jns    802785 <set_pgfault_handler+0x61>
			panic("sys_env_set_pgfault_upcall error : %e\n", r);
  802773:	50                   	push   %eax
  802774:	68 ec 32 80 00       	push   $0x8032ec
  802779:	6a 2a                	push   $0x2a
  80277b:	68 de 32 80 00       	push   $0x8032de
  802780:	e8 6b da ff ff       	call   8001f0 <_panic>
		}
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  802785:	8b 45 08             	mov    0x8(%ebp),%eax
  802788:	a3 00 70 80 00       	mov    %eax,0x807000
}
  80278d:	c9                   	leave  
  80278e:	c3                   	ret    
	...

00802790 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  802790:	54                   	push   %esp
	movl _pgfault_handler, %eax
  802791:	a1 00 70 80 00       	mov    0x807000,%eax
	call *%eax
  802796:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  802798:	83 c4 04             	add    $0x4,%esp
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	
	// fix old esp
	movl 0x30(%esp), %eax
  80279b:	8b 44 24 30          	mov    0x30(%esp),%eax
	subl $0x4, %eax
  80279f:	83 e8 04             	sub    $0x4,%eax
	movl %eax, 0x30(%esp)
  8027a2:	89 44 24 30          	mov    %eax,0x30(%esp)

	// set trap-time %eip
	movl 0x28(%esp), %ebx
  8027a6:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	movl %ebx, (%eax)
  8027aa:	89 18                	mov    %ebx,(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $0x08, %esp 	// ignore err_code and fault_va
  8027ac:	83 c4 08             	add    $0x8,%esp
	popal 				// restore registers
  8027af:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x04, %esp 	// ignore eip 
  8027b0:	83 c4 04             	add    $0x4,%esp
	popfl				// modify eflags
  8027b3:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  8027b4:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  8027b5:	c3                   	ret    
	...

008027b8 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8027b8:	55                   	push   %ebp
  8027b9:	89 e5                	mov    %esp,%ebp
  8027bb:	56                   	push   %esi
  8027bc:	53                   	push   %ebx
  8027bd:	8b 75 08             	mov    0x8(%ebp),%esi
  8027c0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8027c3:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// cprintf("0x%x 0x%x 0x%x\n", (uint32_t)from_env_store, (uint32_t)pg, (uint32_t)perm_store);
	int r;
	if (pg != NULL) {
  8027c6:	85 c0                	test   %eax,%eax
  8027c8:	74 0e                	je     8027d8 <ipc_recv+0x20>
		r = sys_ipc_recv(pg);
  8027ca:	83 ec 0c             	sub    $0xc,%esp
  8027cd:	50                   	push   %eax
  8027ce:	e8 28 e6 ff ff       	call   800dfb <sys_ipc_recv>
  8027d3:	83 c4 10             	add    $0x10,%esp
  8027d6:	eb 10                	jmp    8027e8 <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv((void *)UTOP);
  8027d8:	83 ec 0c             	sub    $0xc,%esp
  8027db:	68 00 00 c0 ee       	push   $0xeec00000
  8027e0:	e8 16 e6 ff ff       	call   800dfb <sys_ipc_recv>
  8027e5:	83 c4 10             	add    $0x10,%esp
	}

	if (r == 0) {
  8027e8:	85 c0                	test   %eax,%eax
  8027ea:	75 26                	jne    802812 <ipc_recv+0x5a>
		if (from_env_store != NULL) *from_env_store = thisenv->env_ipc_from;
  8027ec:	85 f6                	test   %esi,%esi
  8027ee:	74 0a                	je     8027fa <ipc_recv+0x42>
  8027f0:	a1 04 50 80 00       	mov    0x805004,%eax
  8027f5:	8b 40 74             	mov    0x74(%eax),%eax
  8027f8:	89 06                	mov    %eax,(%esi)
		if (perm_store != NULL) *perm_store = thisenv->env_ipc_perm;
  8027fa:	85 db                	test   %ebx,%ebx
  8027fc:	74 0a                	je     802808 <ipc_recv+0x50>
  8027fe:	a1 04 50 80 00       	mov    0x805004,%eax
  802803:	8b 40 78             	mov    0x78(%eax),%eax
  802806:	89 03                	mov    %eax,(%ebx)
		return thisenv->env_ipc_value;
  802808:	a1 04 50 80 00       	mov    0x805004,%eax
  80280d:	8b 40 70             	mov    0x70(%eax),%eax
  802810:	eb 14                	jmp    802826 <ipc_recv+0x6e>
	} else {
		// fails;
		if (from_env_store != NULL) *from_env_store = 0;
  802812:	85 f6                	test   %esi,%esi
  802814:	74 06                	je     80281c <ipc_recv+0x64>
  802816:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if (perm_store != NULL) *perm_store = 0;
  80281c:	85 db                	test   %ebx,%ebx
  80281e:	74 06                	je     802826 <ipc_recv+0x6e>
  802820:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		return r;
	}
}
  802826:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802829:	5b                   	pop    %ebx
  80282a:	5e                   	pop    %esi
  80282b:	c9                   	leave  
  80282c:	c3                   	ret    

0080282d <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80282d:	55                   	push   %ebp
  80282e:	89 e5                	mov    %esp,%ebp
  802830:	57                   	push   %edi
  802831:	56                   	push   %esi
  802832:	53                   	push   %ebx
  802833:	83 ec 0c             	sub    $0xc,%esp
  802836:	8b 7d 0c             	mov    0xc(%ebp),%edi
  802839:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80283c:	8b 75 14             	mov    0x14(%ebp),%esi
	// LAB 4: Your code here.
	// int sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
	int r;
	if (pg == NULL) pg = (void *)UTOP;
  80283f:	85 db                	test   %ebx,%ebx
  802841:	75 25                	jne    802868 <ipc_send+0x3b>
  802843:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
  802848:	eb 1e                	jmp    802868 <ipc_send+0x3b>
	
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) != 0) {
		if (r == -E_IPC_NOT_RECV) {
  80284a:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80284d:	75 07                	jne    802856 <ipc_send+0x29>
			// cprintf("Try Again and Again....\n");
			sys_yield();
  80284f:	e8 85 e4 ff ff       	call   800cd9 <sys_yield>
  802854:	eb 12                	jmp    802868 <ipc_send+0x3b>
		} else {
			panic("ipc_send error %e\n", r);
  802856:	50                   	push   %eax
  802857:	68 14 33 80 00       	push   $0x803314
  80285c:	6a 43                	push   $0x43
  80285e:	68 27 33 80 00       	push   $0x803327
  802863:	e8 88 d9 ff ff       	call   8001f0 <_panic>
	// LAB 4: Your code here.
	// int sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
	int r;
	if (pg == NULL) pg = (void *)UTOP;
	
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) != 0) {
  802868:	56                   	push   %esi
  802869:	53                   	push   %ebx
  80286a:	57                   	push   %edi
  80286b:	ff 75 08             	pushl  0x8(%ebp)
  80286e:	e8 63 e5 ff ff       	call   800dd6 <sys_ipc_try_send>
  802873:	83 c4 10             	add    $0x10,%esp
  802876:	85 c0                	test   %eax,%eax
  802878:	75 d0                	jne    80284a <ipc_send+0x1d>
		} else {
			panic("ipc_send error %e\n", r);
		}
	}
	return;
}
  80287a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80287d:	5b                   	pop    %ebx
  80287e:	5e                   	pop    %esi
  80287f:	5f                   	pop    %edi
  802880:	c9                   	leave  
  802881:	c3                   	ret    

00802882 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802882:	55                   	push   %ebp
  802883:	89 e5                	mov    %esp,%ebp
  802885:	53                   	push   %ebx
  802886:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  802889:	39 1d 50 00 c0 ee    	cmp    %ebx,0xeec00050
  80288f:	74 22                	je     8028b3 <ipc_find_env+0x31>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802891:	b8 01 00 00 00       	mov    $0x1,%eax
		if (envs[i].env_type == type)
  802896:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  80289d:	89 c2                	mov    %eax,%edx
  80289f:	c1 e2 07             	shl    $0x7,%edx
  8028a2:	29 ca                	sub    %ecx,%edx
  8028a4:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8028aa:	8b 52 50             	mov    0x50(%edx),%edx
  8028ad:	39 da                	cmp    %ebx,%edx
  8028af:	75 1d                	jne    8028ce <ipc_find_env+0x4c>
  8028b1:	eb 05                	jmp    8028b8 <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8028b3:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
			return envs[i].env_id;
  8028b8:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  8028bf:	c1 e0 07             	shl    $0x7,%eax
  8028c2:	29 d0                	sub    %edx,%eax
  8028c4:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  8028c9:	8b 40 40             	mov    0x40(%eax),%eax
  8028cc:	eb 0c                	jmp    8028da <ipc_find_env+0x58>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8028ce:	40                   	inc    %eax
  8028cf:	3d 00 04 00 00       	cmp    $0x400,%eax
  8028d4:	75 c0                	jne    802896 <ipc_find_env+0x14>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8028d6:	66 b8 00 00          	mov    $0x0,%ax
}
  8028da:	5b                   	pop    %ebx
  8028db:	c9                   	leave  
  8028dc:	c3                   	ret    
  8028dd:	00 00                	add    %al,(%eax)
	...

008028e0 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8028e0:	55                   	push   %ebp
  8028e1:	89 e5                	mov    %esp,%ebp
  8028e3:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8028e6:	89 c2                	mov    %eax,%edx
  8028e8:	c1 ea 16             	shr    $0x16,%edx
  8028eb:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8028f2:	f6 c2 01             	test   $0x1,%dl
  8028f5:	74 1e                	je     802915 <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  8028f7:	c1 e8 0c             	shr    $0xc,%eax
  8028fa:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  802901:	a8 01                	test   $0x1,%al
  802903:	74 17                	je     80291c <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802905:	c1 e8 0c             	shr    $0xc,%eax
  802908:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  80290f:	ef 
  802910:	0f b7 c0             	movzwl %ax,%eax
  802913:	eb 0c                	jmp    802921 <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  802915:	b8 00 00 00 00       	mov    $0x0,%eax
  80291a:	eb 05                	jmp    802921 <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  80291c:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  802921:	c9                   	leave  
  802922:	c3                   	ret    
	...

00802924 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  802924:	55                   	push   %ebp
  802925:	89 e5                	mov    %esp,%ebp
  802927:	57                   	push   %edi
  802928:	56                   	push   %esi
  802929:	83 ec 10             	sub    $0x10,%esp
  80292c:	8b 7d 08             	mov    0x8(%ebp),%edi
  80292f:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  802932:	89 7d f0             	mov    %edi,-0x10(%ebp)
  802935:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  802938:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  80293b:	8b 45 14             	mov    0x14(%ebp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  80293e:	85 c0                	test   %eax,%eax
  802940:	75 2e                	jne    802970 <__udivdi3+0x4c>
    {
      if (d0 > n1)
  802942:	39 f1                	cmp    %esi,%ecx
  802944:	77 5a                	ja     8029a0 <__udivdi3+0x7c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  802946:	85 c9                	test   %ecx,%ecx
  802948:	75 0b                	jne    802955 <__udivdi3+0x31>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  80294a:	b8 01 00 00 00       	mov    $0x1,%eax
  80294f:	31 d2                	xor    %edx,%edx
  802951:	f7 f1                	div    %ecx
  802953:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  802955:	31 d2                	xor    %edx,%edx
  802957:	89 f0                	mov    %esi,%eax
  802959:	f7 f1                	div    %ecx
  80295b:	89 c6                	mov    %eax,%esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  80295d:	89 f8                	mov    %edi,%eax
  80295f:	f7 f1                	div    %ecx
  802961:	89 c7                	mov    %eax,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  802963:	89 f8                	mov    %edi,%eax
  802965:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802967:	83 c4 10             	add    $0x10,%esp
  80296a:	5e                   	pop    %esi
  80296b:	5f                   	pop    %edi
  80296c:	c9                   	leave  
  80296d:	c3                   	ret    
  80296e:	66 90                	xchg   %ax,%ax
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  802970:	39 f0                	cmp    %esi,%eax
  802972:	77 1c                	ja     802990 <__udivdi3+0x6c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  802974:	0f bd f8             	bsr    %eax,%edi
	  if (bm == 0)
  802977:	83 f7 1f             	xor    $0x1f,%edi
  80297a:	75 3c                	jne    8029b8 <__udivdi3+0x94>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  80297c:	39 f0                	cmp    %esi,%eax
  80297e:	0f 82 90 00 00 00    	jb     802a14 <__udivdi3+0xf0>
  802984:	8b 55 f0             	mov    -0x10(%ebp),%edx
  802987:	39 55 f4             	cmp    %edx,-0xc(%ebp)
  80298a:	0f 86 84 00 00 00    	jbe    802a14 <__udivdi3+0xf0>
  802990:	31 f6                	xor    %esi,%esi
  802992:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  802994:	89 f8                	mov    %edi,%eax
  802996:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802998:	83 c4 10             	add    $0x10,%esp
  80299b:	5e                   	pop    %esi
  80299c:	5f                   	pop    %edi
  80299d:	c9                   	leave  
  80299e:	c3                   	ret    
  80299f:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8029a0:	89 f2                	mov    %esi,%edx
  8029a2:	89 f8                	mov    %edi,%eax
  8029a4:	f7 f1                	div    %ecx
  8029a6:	89 c7                	mov    %eax,%edi
  8029a8:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  8029aa:	89 f8                	mov    %edi,%eax
  8029ac:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  8029ae:	83 c4 10             	add    $0x10,%esp
  8029b1:	5e                   	pop    %esi
  8029b2:	5f                   	pop    %edi
  8029b3:	c9                   	leave  
  8029b4:	c3                   	ret    
  8029b5:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  8029b8:	89 f9                	mov    %edi,%ecx
  8029ba:	d3 e0                	shl    %cl,%eax
  8029bc:	89 45 e8             	mov    %eax,-0x18(%ebp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  8029bf:	b8 20 00 00 00       	mov    $0x20,%eax
  8029c4:	29 f8                	sub    %edi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  8029c6:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8029c9:	88 c1                	mov    %al,%cl
  8029cb:	d3 ea                	shr    %cl,%edx
  8029cd:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  8029d0:	09 ca                	or     %ecx,%edx
  8029d2:	89 55 ec             	mov    %edx,-0x14(%ebp)
	      d0 = d0 << bm;
  8029d5:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8029d8:	89 f9                	mov    %edi,%ecx
  8029da:	d3 e2                	shl    %cl,%edx
  8029dc:	89 55 f4             	mov    %edx,-0xc(%ebp)
	      n2 = n1 >> b;
  8029df:	89 f2                	mov    %esi,%edx
  8029e1:	88 c1                	mov    %al,%cl
  8029e3:	d3 ea                	shr    %cl,%edx
  8029e5:	89 55 e8             	mov    %edx,-0x18(%ebp)
	      n1 = (n1 << bm) | (n0 >> b);
  8029e8:	89 f2                	mov    %esi,%edx
  8029ea:	89 f9                	mov    %edi,%ecx
  8029ec:	d3 e2                	shl    %cl,%edx
  8029ee:	8b 75 f0             	mov    -0x10(%ebp),%esi
  8029f1:	88 c1                	mov    %al,%cl
  8029f3:	d3 ee                	shr    %cl,%esi
  8029f5:	09 d6                	or     %edx,%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  8029f7:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  8029fa:	89 f0                	mov    %esi,%eax
  8029fc:	89 ca                	mov    %ecx,%edx
  8029fe:	f7 75 ec             	divl   -0x14(%ebp)
  802a01:	89 d1                	mov    %edx,%ecx
  802a03:	89 c6                	mov    %eax,%esi
	      umul_ppmm (m1, m0, q0, d0);
  802a05:	f7 65 f4             	mull   -0xc(%ebp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802a08:	39 d1                	cmp    %edx,%ecx
  802a0a:	72 28                	jb     802a34 <__udivdi3+0x110>
  802a0c:	74 1a                	je     802a28 <__udivdi3+0x104>
  802a0e:	89 f7                	mov    %esi,%edi
  802a10:	31 f6                	xor    %esi,%esi
  802a12:	eb 80                	jmp    802994 <__udivdi3+0x70>
	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  802a14:	31 f6                	xor    %esi,%esi
  802a16:	bf 01 00 00 00       	mov    $0x1,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  802a1b:	89 f8                	mov    %edi,%eax
  802a1d:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802a1f:	83 c4 10             	add    $0x10,%esp
  802a22:	5e                   	pop    %esi
  802a23:	5f                   	pop    %edi
  802a24:	c9                   	leave  
  802a25:	c3                   	ret    
  802a26:	66 90                	xchg   %ax,%ax

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  802a28:	8b 55 f0             	mov    -0x10(%ebp),%edx
  802a2b:	89 f9                	mov    %edi,%ecx
  802a2d:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802a2f:	39 c2                	cmp    %eax,%edx
  802a31:	73 db                	jae    802a0e <__udivdi3+0xea>
  802a33:	90                   	nop
		{
		  q0--;
  802a34:	8d 7e ff             	lea    -0x1(%esi),%edi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  802a37:	31 f6                	xor    %esi,%esi
  802a39:	e9 56 ff ff ff       	jmp    802994 <__udivdi3+0x70>
	...

00802a40 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  802a40:	55                   	push   %ebp
  802a41:	89 e5                	mov    %esp,%ebp
  802a43:	57                   	push   %edi
  802a44:	56                   	push   %esi
  802a45:	83 ec 20             	sub    $0x20,%esp
  802a48:	8b 45 08             	mov    0x8(%ebp),%eax
  802a4b:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  802a4e:	89 45 e8             	mov    %eax,-0x18(%ebp)
  802a51:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  802a54:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  802a57:	8b 7d 14             	mov    0x14(%ebp),%edi
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  802a5a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  n1 = nn.s.high;
  802a5d:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  802a5f:	85 ff                	test   %edi,%edi
  802a61:	75 15                	jne    802a78 <__umoddi3+0x38>
    {
      if (d0 > n1)
  802a63:	39 f1                	cmp    %esi,%ecx
  802a65:	0f 86 99 00 00 00    	jbe    802b04 <__umoddi3+0xc4>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802a6b:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  802a6d:	89 d0                	mov    %edx,%eax
  802a6f:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802a71:	83 c4 20             	add    $0x20,%esp
  802a74:	5e                   	pop    %esi
  802a75:	5f                   	pop    %edi
  802a76:	c9                   	leave  
  802a77:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  802a78:	39 f7                	cmp    %esi,%edi
  802a7a:	0f 87 a4 00 00 00    	ja     802b24 <__umoddi3+0xe4>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  802a80:	0f bd c7             	bsr    %edi,%eax
	  if (bm == 0)
  802a83:	83 f0 1f             	xor    $0x1f,%eax
  802a86:	89 45 ec             	mov    %eax,-0x14(%ebp)
  802a89:	0f 84 a1 00 00 00    	je     802b30 <__umoddi3+0xf0>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  802a8f:	89 f8                	mov    %edi,%eax
  802a91:	8a 4d ec             	mov    -0x14(%ebp),%cl
  802a94:	d3 e0                	shl    %cl,%eax
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  802a96:	bf 20 00 00 00       	mov    $0x20,%edi
  802a9b:	2b 7d ec             	sub    -0x14(%ebp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  802a9e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802aa1:	89 f9                	mov    %edi,%ecx
  802aa3:	d3 ea                	shr    %cl,%edx
  802aa5:	09 c2                	or     %eax,%edx
  802aa7:	89 55 f0             	mov    %edx,-0x10(%ebp)
	      d0 = d0 << bm;
  802aaa:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802aad:	8a 4d ec             	mov    -0x14(%ebp),%cl
  802ab0:	d3 e0                	shl    %cl,%eax
  802ab2:	89 45 f4             	mov    %eax,-0xc(%ebp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  802ab5:	89 f2                	mov    %esi,%edx
  802ab7:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  802ab9:	8b 45 e8             	mov    -0x18(%ebp),%eax
  802abc:	d3 e0                	shl    %cl,%eax
  802abe:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  802ac1:	8b 45 e8             	mov    -0x18(%ebp),%eax
  802ac4:	89 f9                	mov    %edi,%ecx
  802ac6:	d3 e8                	shr    %cl,%eax
  802ac8:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  802aca:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  802acc:	89 f2                	mov    %esi,%edx
  802ace:	f7 75 f0             	divl   -0x10(%ebp)
  802ad1:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  802ad3:	f7 65 f4             	mull   -0xc(%ebp)
  802ad6:	89 55 e8             	mov    %edx,-0x18(%ebp)
  802ad9:	89 c1                	mov    %eax,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802adb:	39 d6                	cmp    %edx,%esi
  802add:	72 71                	jb     802b50 <__umoddi3+0x110>
  802adf:	74 7f                	je     802b60 <__umoddi3+0x120>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  802ae1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802ae4:	29 c8                	sub    %ecx,%eax
  802ae6:	19 d6                	sbb    %edx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  802ae8:	8a 4d ec             	mov    -0x14(%ebp),%cl
  802aeb:	d3 e8                	shr    %cl,%eax
  802aed:	89 f2                	mov    %esi,%edx
  802aef:	89 f9                	mov    %edi,%ecx
  802af1:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  802af3:	09 d0                	or     %edx,%eax
  802af5:	89 f2                	mov    %esi,%edx
  802af7:	8a 4d ec             	mov    -0x14(%ebp),%cl
  802afa:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802afc:	83 c4 20             	add    $0x20,%esp
  802aff:	5e                   	pop    %esi
  802b00:	5f                   	pop    %edi
  802b01:	c9                   	leave  
  802b02:	c3                   	ret    
  802b03:	90                   	nop
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  802b04:	85 c9                	test   %ecx,%ecx
  802b06:	75 0b                	jne    802b13 <__umoddi3+0xd3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  802b08:	b8 01 00 00 00       	mov    $0x1,%eax
  802b0d:	31 d2                	xor    %edx,%edx
  802b0f:	f7 f1                	div    %ecx
  802b11:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  802b13:	89 f0                	mov    %esi,%eax
  802b15:	31 d2                	xor    %edx,%edx
  802b17:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802b19:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802b1c:	f7 f1                	div    %ecx
  802b1e:	e9 4a ff ff ff       	jmp    802a6d <__umoddi3+0x2d>
  802b23:	90                   	nop
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  802b24:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802b26:	83 c4 20             	add    $0x20,%esp
  802b29:	5e                   	pop    %esi
  802b2a:	5f                   	pop    %edi
  802b2b:	c9                   	leave  
  802b2c:	c3                   	ret    
  802b2d:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802b30:	39 f7                	cmp    %esi,%edi
  802b32:	72 05                	jb     802b39 <__umoddi3+0xf9>
  802b34:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
  802b37:	77 0c                	ja     802b45 <__umoddi3+0x105>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  802b39:	89 f2                	mov    %esi,%edx
  802b3b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802b3e:	29 c8                	sub    %ecx,%eax
  802b40:	19 fa                	sbb    %edi,%edx
  802b42:	89 45 f0             	mov    %eax,-0x10(%ebp)

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  802b45:	8b 45 f0             	mov    -0x10(%ebp),%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802b48:	83 c4 20             	add    $0x20,%esp
  802b4b:	5e                   	pop    %esi
  802b4c:	5f                   	pop    %edi
  802b4d:	c9                   	leave  
  802b4e:	c3                   	ret    
  802b4f:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  802b50:	8b 55 e8             	mov    -0x18(%ebp),%edx
  802b53:	89 c1                	mov    %eax,%ecx
  802b55:	2b 4d f4             	sub    -0xc(%ebp),%ecx
  802b58:	1b 55 f0             	sbb    -0x10(%ebp),%edx
  802b5b:	eb 84                	jmp    802ae1 <__umoddi3+0xa1>
  802b5d:	8d 76 00             	lea    0x0(%esi),%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802b60:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  802b63:	72 eb                	jb     802b50 <__umoddi3+0x110>
  802b65:	89 f2                	mov    %esi,%edx
  802b67:	e9 75 ff ff ff       	jmp    802ae1 <__umoddi3+0xa1>
