
obj/user/faultalloc.debug:     file format elf32-i386


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
  80002c:	e8 9b 00 00 00       	call   8000cc <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <handler>:

#include <inc/lib.h>

void
handler(struct UTrapframe *utf)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	53                   	push   %ebx
  800038:	83 ec 0c             	sub    $0xc,%esp
	int r;
	void *addr = (void*)utf->utf_fault_va;
  80003b:	8b 45 08             	mov    0x8(%ebp),%eax
  80003e:	8b 18                	mov    (%eax),%ebx

	cprintf("fault %x\n", addr);
  800040:	53                   	push   %ebx
  800041:	68 a0 1e 80 00       	push   $0x801ea0
  800046:	e8 c5 01 00 00       	call   800210 <cprintf>
	if ((r = sys_page_alloc(0, ROUNDDOWN(addr, PGSIZE),
  80004b:	83 c4 0c             	add    $0xc,%esp
  80004e:	6a 07                	push   $0x7
  800050:	89 d8                	mov    %ebx,%eax
  800052:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800057:	50                   	push   %eax
  800058:	6a 00                	push   $0x0
  80005a:	e8 e9 0b 00 00       	call   800c48 <sys_page_alloc>
  80005f:	83 c4 10             	add    $0x10,%esp
  800062:	85 c0                	test   %eax,%eax
  800064:	79 16                	jns    80007c <handler+0x48>
				PTE_P|PTE_U|PTE_W)) < 0)
		panic("allocating at %x in page fault handler: %e", addr, r);
  800066:	83 ec 0c             	sub    $0xc,%esp
  800069:	50                   	push   %eax
  80006a:	53                   	push   %ebx
  80006b:	68 c0 1e 80 00       	push   $0x801ec0
  800070:	6a 0e                	push   $0xe
  800072:	68 aa 1e 80 00       	push   $0x801eaa
  800077:	e8 bc 00 00 00       	call   800138 <_panic>
	snprintf((char*) addr, 100, "this string was faulted in at %x", addr);
  80007c:	53                   	push   %ebx
  80007d:	68 ec 1e 80 00       	push   $0x801eec
  800082:	6a 64                	push   $0x64
  800084:	53                   	push   %ebx
  800085:	e8 ce 06 00 00       	call   800758 <snprintf>
  80008a:	83 c4 10             	add    $0x10,%esp
}
  80008d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800090:	c9                   	leave  
  800091:	c3                   	ret    

00800092 <umain>:

void
umain(int argc, char **argv)
{
  800092:	55                   	push   %ebp
  800093:	89 e5                	mov    %esp,%ebp
  800095:	83 ec 14             	sub    $0x14,%esp
	set_pgfault_handler(handler);
  800098:	68 34 00 80 00       	push   $0x800034
  80009d:	e8 e6 0c 00 00       	call   800d88 <set_pgfault_handler>
	cprintf("%s\n", (char*)0xDeadBeef);
  8000a2:	83 c4 08             	add    $0x8,%esp
  8000a5:	68 ef be ad de       	push   $0xdeadbeef
  8000aa:	68 bc 1e 80 00       	push   $0x801ebc
  8000af:	e8 5c 01 00 00       	call   800210 <cprintf>
	cprintf("%s\n", (char*)0xCafeBffe);
  8000b4:	83 c4 08             	add    $0x8,%esp
  8000b7:	68 fe bf fe ca       	push   $0xcafebffe
  8000bc:	68 bc 1e 80 00       	push   $0x801ebc
  8000c1:	e8 4a 01 00 00       	call   800210 <cprintf>
  8000c6:	83 c4 10             	add    $0x10,%esp
}
  8000c9:	c9                   	leave  
  8000ca:	c3                   	ret    
	...

008000cc <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000cc:	55                   	push   %ebp
  8000cd:	89 e5                	mov    %esp,%ebp
  8000cf:	56                   	push   %esi
  8000d0:	53                   	push   %ebx
  8000d1:	8b 75 08             	mov    0x8(%ebp),%esi
  8000d4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs + ENVX(sys_getenvid());
  8000d7:	e8 21 0b 00 00       	call   800bfd <sys_getenvid>
  8000dc:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000e1:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  8000e8:	c1 e0 07             	shl    $0x7,%eax
  8000eb:	29 d0                	sub    %edx,%eax
  8000ed:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000f2:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000f7:	85 f6                	test   %esi,%esi
  8000f9:	7e 07                	jle    800102 <libmain+0x36>
		binaryname = argv[0];
  8000fb:	8b 03                	mov    (%ebx),%eax
  8000fd:	a3 00 30 80 00       	mov    %eax,0x803000
	// call user main routine
	umain(argc, argv);
  800102:	83 ec 08             	sub    $0x8,%esp
  800105:	53                   	push   %ebx
  800106:	56                   	push   %esi
  800107:	e8 86 ff ff ff       	call   800092 <umain>

	// exit gracefully
	exit();
  80010c:	e8 0b 00 00 00       	call   80011c <exit>
  800111:	83 c4 10             	add    $0x10,%esp
}
  800114:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800117:	5b                   	pop    %ebx
  800118:	5e                   	pop    %esi
  800119:	c9                   	leave  
  80011a:	c3                   	ret    
	...

0080011c <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80011c:	55                   	push   %ebp
  80011d:	89 e5                	mov    %esp,%ebp
  80011f:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800122:	e8 ff 0e 00 00       	call   801026 <close_all>
	sys_env_destroy(0);
  800127:	83 ec 0c             	sub    $0xc,%esp
  80012a:	6a 00                	push   $0x0
  80012c:	e8 aa 0a 00 00       	call   800bdb <sys_env_destroy>
  800131:	83 c4 10             	add    $0x10,%esp
}
  800134:	c9                   	leave  
  800135:	c3                   	ret    
	...

00800138 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800138:	55                   	push   %ebp
  800139:	89 e5                	mov    %esp,%ebp
  80013b:	56                   	push   %esi
  80013c:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80013d:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800140:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  800146:	e8 b2 0a 00 00       	call   800bfd <sys_getenvid>
  80014b:	83 ec 0c             	sub    $0xc,%esp
  80014e:	ff 75 0c             	pushl  0xc(%ebp)
  800151:	ff 75 08             	pushl  0x8(%ebp)
  800154:	53                   	push   %ebx
  800155:	50                   	push   %eax
  800156:	68 18 1f 80 00       	push   $0x801f18
  80015b:	e8 b0 00 00 00       	call   800210 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800160:	83 c4 18             	add    $0x18,%esp
  800163:	56                   	push   %esi
  800164:	ff 75 10             	pushl  0x10(%ebp)
  800167:	e8 53 00 00 00       	call   8001bf <vcprintf>
	cprintf("\n");
  80016c:	c7 04 24 97 23 80 00 	movl   $0x802397,(%esp)
  800173:	e8 98 00 00 00       	call   800210 <cprintf>
  800178:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80017b:	cc                   	int3   
  80017c:	eb fd                	jmp    80017b <_panic+0x43>
	...

00800180 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800180:	55                   	push   %ebp
  800181:	89 e5                	mov    %esp,%ebp
  800183:	53                   	push   %ebx
  800184:	83 ec 04             	sub    $0x4,%esp
  800187:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80018a:	8b 03                	mov    (%ebx),%eax
  80018c:	8b 55 08             	mov    0x8(%ebp),%edx
  80018f:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  800193:	40                   	inc    %eax
  800194:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  800196:	3d ff 00 00 00       	cmp    $0xff,%eax
  80019b:	75 1a                	jne    8001b7 <putch+0x37>
		sys_cputs(b->buf, b->idx);
  80019d:	83 ec 08             	sub    $0x8,%esp
  8001a0:	68 ff 00 00 00       	push   $0xff
  8001a5:	8d 43 08             	lea    0x8(%ebx),%eax
  8001a8:	50                   	push   %eax
  8001a9:	e8 e3 09 00 00       	call   800b91 <sys_cputs>
		b->idx = 0;
  8001ae:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001b4:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8001b7:	ff 43 04             	incl   0x4(%ebx)
}
  8001ba:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001bd:	c9                   	leave  
  8001be:	c3                   	ret    

008001bf <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001bf:	55                   	push   %ebp
  8001c0:	89 e5                	mov    %esp,%ebp
  8001c2:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001c8:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001cf:	00 00 00 
	b.cnt = 0;
  8001d2:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001d9:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001dc:	ff 75 0c             	pushl  0xc(%ebp)
  8001df:	ff 75 08             	pushl  0x8(%ebp)
  8001e2:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001e8:	50                   	push   %eax
  8001e9:	68 80 01 80 00       	push   $0x800180
  8001ee:	e8 82 01 00 00       	call   800375 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001f3:	83 c4 08             	add    $0x8,%esp
  8001f6:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8001fc:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800202:	50                   	push   %eax
  800203:	e8 89 09 00 00       	call   800b91 <sys_cputs>

	return b.cnt;
}
  800208:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80020e:	c9                   	leave  
  80020f:	c3                   	ret    

00800210 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800210:	55                   	push   %ebp
  800211:	89 e5                	mov    %esp,%ebp
  800213:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800216:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800219:	50                   	push   %eax
  80021a:	ff 75 08             	pushl  0x8(%ebp)
  80021d:	e8 9d ff ff ff       	call   8001bf <vcprintf>
	va_end(ap);

	return cnt;
}
  800222:	c9                   	leave  
  800223:	c3                   	ret    

00800224 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800224:	55                   	push   %ebp
  800225:	89 e5                	mov    %esp,%ebp
  800227:	57                   	push   %edi
  800228:	56                   	push   %esi
  800229:	53                   	push   %ebx
  80022a:	83 ec 2c             	sub    $0x2c,%esp
  80022d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800230:	89 d6                	mov    %edx,%esi
  800232:	8b 45 08             	mov    0x8(%ebp),%eax
  800235:	8b 55 0c             	mov    0xc(%ebp),%edx
  800238:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80023b:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80023e:	8b 45 10             	mov    0x10(%ebp),%eax
  800241:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800244:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800247:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80024a:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  800251:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
  800254:	72 0c                	jb     800262 <printnum+0x3e>
  800256:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  800259:	76 07                	jbe    800262 <printnum+0x3e>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80025b:	4b                   	dec    %ebx
  80025c:	85 db                	test   %ebx,%ebx
  80025e:	7f 31                	jg     800291 <printnum+0x6d>
  800260:	eb 3f                	jmp    8002a1 <printnum+0x7d>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800262:	83 ec 0c             	sub    $0xc,%esp
  800265:	57                   	push   %edi
  800266:	4b                   	dec    %ebx
  800267:	53                   	push   %ebx
  800268:	50                   	push   %eax
  800269:	83 ec 08             	sub    $0x8,%esp
  80026c:	ff 75 d4             	pushl  -0x2c(%ebp)
  80026f:	ff 75 d0             	pushl  -0x30(%ebp)
  800272:	ff 75 dc             	pushl  -0x24(%ebp)
  800275:	ff 75 d8             	pushl  -0x28(%ebp)
  800278:	e8 bf 19 00 00       	call   801c3c <__udivdi3>
  80027d:	83 c4 18             	add    $0x18,%esp
  800280:	52                   	push   %edx
  800281:	50                   	push   %eax
  800282:	89 f2                	mov    %esi,%edx
  800284:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800287:	e8 98 ff ff ff       	call   800224 <printnum>
  80028c:	83 c4 20             	add    $0x20,%esp
  80028f:	eb 10                	jmp    8002a1 <printnum+0x7d>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800291:	83 ec 08             	sub    $0x8,%esp
  800294:	56                   	push   %esi
  800295:	57                   	push   %edi
  800296:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800299:	4b                   	dec    %ebx
  80029a:	83 c4 10             	add    $0x10,%esp
  80029d:	85 db                	test   %ebx,%ebx
  80029f:	7f f0                	jg     800291 <printnum+0x6d>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002a1:	83 ec 08             	sub    $0x8,%esp
  8002a4:	56                   	push   %esi
  8002a5:	83 ec 04             	sub    $0x4,%esp
  8002a8:	ff 75 d4             	pushl  -0x2c(%ebp)
  8002ab:	ff 75 d0             	pushl  -0x30(%ebp)
  8002ae:	ff 75 dc             	pushl  -0x24(%ebp)
  8002b1:	ff 75 d8             	pushl  -0x28(%ebp)
  8002b4:	e8 9f 1a 00 00       	call   801d58 <__umoddi3>
  8002b9:	83 c4 14             	add    $0x14,%esp
  8002bc:	0f be 80 3b 1f 80 00 	movsbl 0x801f3b(%eax),%eax
  8002c3:	50                   	push   %eax
  8002c4:	ff 55 e4             	call   *-0x1c(%ebp)
  8002c7:	83 c4 10             	add    $0x10,%esp
}
  8002ca:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002cd:	5b                   	pop    %ebx
  8002ce:	5e                   	pop    %esi
  8002cf:	5f                   	pop    %edi
  8002d0:	c9                   	leave  
  8002d1:	c3                   	ret    

008002d2 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002d2:	55                   	push   %ebp
  8002d3:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002d5:	83 fa 01             	cmp    $0x1,%edx
  8002d8:	7e 0e                	jle    8002e8 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8002da:	8b 10                	mov    (%eax),%edx
  8002dc:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002df:	89 08                	mov    %ecx,(%eax)
  8002e1:	8b 02                	mov    (%edx),%eax
  8002e3:	8b 52 04             	mov    0x4(%edx),%edx
  8002e6:	eb 22                	jmp    80030a <getuint+0x38>
	else if (lflag)
  8002e8:	85 d2                	test   %edx,%edx
  8002ea:	74 10                	je     8002fc <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8002ec:	8b 10                	mov    (%eax),%edx
  8002ee:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002f1:	89 08                	mov    %ecx,(%eax)
  8002f3:	8b 02                	mov    (%edx),%eax
  8002f5:	ba 00 00 00 00       	mov    $0x0,%edx
  8002fa:	eb 0e                	jmp    80030a <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8002fc:	8b 10                	mov    (%eax),%edx
  8002fe:	8d 4a 04             	lea    0x4(%edx),%ecx
  800301:	89 08                	mov    %ecx,(%eax)
  800303:	8b 02                	mov    (%edx),%eax
  800305:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80030a:	c9                   	leave  
  80030b:	c3                   	ret    

0080030c <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  80030c:	55                   	push   %ebp
  80030d:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80030f:	83 fa 01             	cmp    $0x1,%edx
  800312:	7e 0e                	jle    800322 <getint+0x16>
		return va_arg(*ap, long long);
  800314:	8b 10                	mov    (%eax),%edx
  800316:	8d 4a 08             	lea    0x8(%edx),%ecx
  800319:	89 08                	mov    %ecx,(%eax)
  80031b:	8b 02                	mov    (%edx),%eax
  80031d:	8b 52 04             	mov    0x4(%edx),%edx
  800320:	eb 1a                	jmp    80033c <getint+0x30>
	else if (lflag)
  800322:	85 d2                	test   %edx,%edx
  800324:	74 0c                	je     800332 <getint+0x26>
		return va_arg(*ap, long);
  800326:	8b 10                	mov    (%eax),%edx
  800328:	8d 4a 04             	lea    0x4(%edx),%ecx
  80032b:	89 08                	mov    %ecx,(%eax)
  80032d:	8b 02                	mov    (%edx),%eax
  80032f:	99                   	cltd   
  800330:	eb 0a                	jmp    80033c <getint+0x30>
	else
		return va_arg(*ap, int);
  800332:	8b 10                	mov    (%eax),%edx
  800334:	8d 4a 04             	lea    0x4(%edx),%ecx
  800337:	89 08                	mov    %ecx,(%eax)
  800339:	8b 02                	mov    (%edx),%eax
  80033b:	99                   	cltd   
}
  80033c:	c9                   	leave  
  80033d:	c3                   	ret    

0080033e <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80033e:	55                   	push   %ebp
  80033f:	89 e5                	mov    %esp,%ebp
  800341:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800344:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  800347:	8b 10                	mov    (%eax),%edx
  800349:	3b 50 04             	cmp    0x4(%eax),%edx
  80034c:	73 08                	jae    800356 <sprintputch+0x18>
		*b->buf++ = ch;
  80034e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800351:	88 0a                	mov    %cl,(%edx)
  800353:	42                   	inc    %edx
  800354:	89 10                	mov    %edx,(%eax)
}
  800356:	c9                   	leave  
  800357:	c3                   	ret    

00800358 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800358:	55                   	push   %ebp
  800359:	89 e5                	mov    %esp,%ebp
  80035b:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80035e:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800361:	50                   	push   %eax
  800362:	ff 75 10             	pushl  0x10(%ebp)
  800365:	ff 75 0c             	pushl  0xc(%ebp)
  800368:	ff 75 08             	pushl  0x8(%ebp)
  80036b:	e8 05 00 00 00       	call   800375 <vprintfmt>
	va_end(ap);
  800370:	83 c4 10             	add    $0x10,%esp
}
  800373:	c9                   	leave  
  800374:	c3                   	ret    

00800375 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800375:	55                   	push   %ebp
  800376:	89 e5                	mov    %esp,%ebp
  800378:	57                   	push   %edi
  800379:	56                   	push   %esi
  80037a:	53                   	push   %ebx
  80037b:	83 ec 2c             	sub    $0x2c,%esp
  80037e:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800381:	8b 75 10             	mov    0x10(%ebp),%esi
  800384:	eb 13                	jmp    800399 <vprintfmt+0x24>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800386:	85 c0                	test   %eax,%eax
  800388:	0f 84 6d 03 00 00    	je     8006fb <vprintfmt+0x386>
				return;
			putch(ch, putdat);
  80038e:	83 ec 08             	sub    $0x8,%esp
  800391:	57                   	push   %edi
  800392:	50                   	push   %eax
  800393:	ff 55 08             	call   *0x8(%ebp)
  800396:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800399:	0f b6 06             	movzbl (%esi),%eax
  80039c:	46                   	inc    %esi
  80039d:	83 f8 25             	cmp    $0x25,%eax
  8003a0:	75 e4                	jne    800386 <vprintfmt+0x11>
  8003a2:	c6 45 dc 20          	movb   $0x20,-0x24(%ebp)
  8003a6:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  8003ad:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  8003b4:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  8003bb:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003c0:	eb 28                	jmp    8003ea <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003c2:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  8003c4:	c6 45 dc 2d          	movb   $0x2d,-0x24(%ebp)
  8003c8:	eb 20                	jmp    8003ea <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ca:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8003cc:	c6 45 dc 30          	movb   $0x30,-0x24(%ebp)
  8003d0:	eb 18                	jmp    8003ea <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003d2:	89 de                	mov    %ebx,%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  8003d4:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8003db:	eb 0d                	jmp    8003ea <vprintfmt+0x75>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  8003dd:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8003e0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003e3:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ea:	8a 06                	mov    (%esi),%al
  8003ec:	0f b6 d0             	movzbl %al,%edx
  8003ef:	8d 5e 01             	lea    0x1(%esi),%ebx
  8003f2:	83 e8 23             	sub    $0x23,%eax
  8003f5:	3c 55                	cmp    $0x55,%al
  8003f7:	0f 87 e0 02 00 00    	ja     8006dd <vprintfmt+0x368>
  8003fd:	0f b6 c0             	movzbl %al,%eax
  800400:	ff 24 85 80 20 80 00 	jmp    *0x802080(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800407:	83 ea 30             	sub    $0x30,%edx
  80040a:	89 55 d4             	mov    %edx,-0x2c(%ebp)
				ch = *fmt;
  80040d:	0f be 03             	movsbl (%ebx),%eax
				if (ch < '0' || ch > '9')
  800410:	8d 50 d0             	lea    -0x30(%eax),%edx
  800413:	83 fa 09             	cmp    $0x9,%edx
  800416:	77 44                	ja     80045c <vprintfmt+0xe7>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800418:	89 de                	mov    %ebx,%esi
  80041a:	8b 55 d4             	mov    -0x2c(%ebp),%edx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80041d:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
  80041e:	8d 14 92             	lea    (%edx,%edx,4),%edx
  800421:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
  800425:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800428:	8d 58 d0             	lea    -0x30(%eax),%ebx
  80042b:	83 fb 09             	cmp    $0x9,%ebx
  80042e:	76 ed                	jbe    80041d <vprintfmt+0xa8>
  800430:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  800433:	eb 29                	jmp    80045e <vprintfmt+0xe9>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800435:	8b 45 14             	mov    0x14(%ebp),%eax
  800438:	8d 50 04             	lea    0x4(%eax),%edx
  80043b:	89 55 14             	mov    %edx,0x14(%ebp)
  80043e:	8b 00                	mov    (%eax),%eax
  800440:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800443:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800445:	eb 17                	jmp    80045e <vprintfmt+0xe9>

		case '.':
			if (width < 0)
  800447:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80044b:	78 85                	js     8003d2 <vprintfmt+0x5d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80044d:	89 de                	mov    %ebx,%esi
  80044f:	eb 99                	jmp    8003ea <vprintfmt+0x75>
  800451:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800453:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  80045a:	eb 8e                	jmp    8003ea <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80045c:	89 de                	mov    %ebx,%esi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  80045e:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800462:	79 86                	jns    8003ea <vprintfmt+0x75>
  800464:	e9 74 ff ff ff       	jmp    8003dd <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800469:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80046a:	89 de                	mov    %ebx,%esi
  80046c:	e9 79 ff ff ff       	jmp    8003ea <vprintfmt+0x75>
  800471:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800474:	8b 45 14             	mov    0x14(%ebp),%eax
  800477:	8d 50 04             	lea    0x4(%eax),%edx
  80047a:	89 55 14             	mov    %edx,0x14(%ebp)
  80047d:	83 ec 08             	sub    $0x8,%esp
  800480:	57                   	push   %edi
  800481:	ff 30                	pushl  (%eax)
  800483:	ff 55 08             	call   *0x8(%ebp)
			break;
  800486:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800489:	8b 75 d8             	mov    -0x28(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80048c:	e9 08 ff ff ff       	jmp    800399 <vprintfmt+0x24>
  800491:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  800494:	8b 45 14             	mov    0x14(%ebp),%eax
  800497:	8d 50 04             	lea    0x4(%eax),%edx
  80049a:	89 55 14             	mov    %edx,0x14(%ebp)
  80049d:	8b 00                	mov    (%eax),%eax
  80049f:	85 c0                	test   %eax,%eax
  8004a1:	79 02                	jns    8004a5 <vprintfmt+0x130>
  8004a3:	f7 d8                	neg    %eax
  8004a5:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004a7:	83 f8 0f             	cmp    $0xf,%eax
  8004aa:	7f 0b                	jg     8004b7 <vprintfmt+0x142>
  8004ac:	8b 04 85 e0 21 80 00 	mov    0x8021e0(,%eax,4),%eax
  8004b3:	85 c0                	test   %eax,%eax
  8004b5:	75 1a                	jne    8004d1 <vprintfmt+0x15c>
				printfmt(putch, putdat, "error %d", err);
  8004b7:	52                   	push   %edx
  8004b8:	68 53 1f 80 00       	push   $0x801f53
  8004bd:	57                   	push   %edi
  8004be:	ff 75 08             	pushl  0x8(%ebp)
  8004c1:	e8 92 fe ff ff       	call   800358 <printfmt>
  8004c6:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004c9:	8b 75 d8             	mov    -0x28(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8004cc:	e9 c8 fe ff ff       	jmp    800399 <vprintfmt+0x24>
			else
				printfmt(putch, putdat, "%s", p);
  8004d1:	50                   	push   %eax
  8004d2:	68 65 23 80 00       	push   $0x802365
  8004d7:	57                   	push   %edi
  8004d8:	ff 75 08             	pushl  0x8(%ebp)
  8004db:	e8 78 fe ff ff       	call   800358 <printfmt>
  8004e0:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004e3:	8b 75 d8             	mov    -0x28(%ebp),%esi
  8004e6:	e9 ae fe ff ff       	jmp    800399 <vprintfmt+0x24>
  8004eb:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  8004ee:	89 de                	mov    %ebx,%esi
  8004f0:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  8004f3:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004f6:	8b 45 14             	mov    0x14(%ebp),%eax
  8004f9:	8d 50 04             	lea    0x4(%eax),%edx
  8004fc:	89 55 14             	mov    %edx,0x14(%ebp)
  8004ff:	8b 00                	mov    (%eax),%eax
  800501:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800504:	85 c0                	test   %eax,%eax
  800506:	75 07                	jne    80050f <vprintfmt+0x19a>
				p = "(null)";
  800508:	c7 45 d0 4c 1f 80 00 	movl   $0x801f4c,-0x30(%ebp)
			if (width > 0 && padc != '-')
  80050f:	85 db                	test   %ebx,%ebx
  800511:	7e 42                	jle    800555 <vprintfmt+0x1e0>
  800513:	80 7d dc 2d          	cmpb   $0x2d,-0x24(%ebp)
  800517:	74 3c                	je     800555 <vprintfmt+0x1e0>
				for (width -= strnlen(p, precision); width > 0; width--)
  800519:	83 ec 08             	sub    $0x8,%esp
  80051c:	51                   	push   %ecx
  80051d:	ff 75 d0             	pushl  -0x30(%ebp)
  800520:	e8 6f 02 00 00       	call   800794 <strnlen>
  800525:	29 c3                	sub    %eax,%ebx
  800527:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80052a:	83 c4 10             	add    $0x10,%esp
  80052d:	85 db                	test   %ebx,%ebx
  80052f:	7e 24                	jle    800555 <vprintfmt+0x1e0>
					putch(padc, putdat);
  800531:	0f be 5d dc          	movsbl -0x24(%ebp),%ebx
  800535:	89 75 dc             	mov    %esi,-0x24(%ebp)
  800538:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  80053b:	83 ec 08             	sub    $0x8,%esp
  80053e:	57                   	push   %edi
  80053f:	53                   	push   %ebx
  800540:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800543:	4e                   	dec    %esi
  800544:	83 c4 10             	add    $0x10,%esp
  800547:	85 f6                	test   %esi,%esi
  800549:	7f f0                	jg     80053b <vprintfmt+0x1c6>
  80054b:	8b 75 dc             	mov    -0x24(%ebp),%esi
  80054e:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800555:	8b 55 d0             	mov    -0x30(%ebp),%edx
  800558:	0f be 02             	movsbl (%edx),%eax
  80055b:	85 c0                	test   %eax,%eax
  80055d:	75 47                	jne    8005a6 <vprintfmt+0x231>
  80055f:	eb 37                	jmp    800598 <vprintfmt+0x223>
				if (altflag && (ch < ' ' || ch > '~'))
  800561:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800565:	74 16                	je     80057d <vprintfmt+0x208>
  800567:	8d 50 e0             	lea    -0x20(%eax),%edx
  80056a:	83 fa 5e             	cmp    $0x5e,%edx
  80056d:	76 0e                	jbe    80057d <vprintfmt+0x208>
					putch('?', putdat);
  80056f:	83 ec 08             	sub    $0x8,%esp
  800572:	57                   	push   %edi
  800573:	6a 3f                	push   $0x3f
  800575:	ff 55 08             	call   *0x8(%ebp)
  800578:	83 c4 10             	add    $0x10,%esp
  80057b:	eb 0b                	jmp    800588 <vprintfmt+0x213>
				else
					putch(ch, putdat);
  80057d:	83 ec 08             	sub    $0x8,%esp
  800580:	57                   	push   %edi
  800581:	50                   	push   %eax
  800582:	ff 55 08             	call   *0x8(%ebp)
  800585:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800588:	ff 4d e4             	decl   -0x1c(%ebp)
  80058b:	0f be 03             	movsbl (%ebx),%eax
  80058e:	85 c0                	test   %eax,%eax
  800590:	74 03                	je     800595 <vprintfmt+0x220>
  800592:	43                   	inc    %ebx
  800593:	eb 1b                	jmp    8005b0 <vprintfmt+0x23b>
  800595:	8b 75 dc             	mov    -0x24(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800598:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80059c:	7f 1e                	jg     8005bc <vprintfmt+0x247>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80059e:	8b 75 d8             	mov    -0x28(%ebp),%esi
  8005a1:	e9 f3 fd ff ff       	jmp    800399 <vprintfmt+0x24>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005a6:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  8005a9:	43                   	inc    %ebx
  8005aa:	89 75 dc             	mov    %esi,-0x24(%ebp)
  8005ad:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  8005b0:	85 f6                	test   %esi,%esi
  8005b2:	78 ad                	js     800561 <vprintfmt+0x1ec>
  8005b4:	4e                   	dec    %esi
  8005b5:	79 aa                	jns    800561 <vprintfmt+0x1ec>
  8005b7:	8b 75 dc             	mov    -0x24(%ebp),%esi
  8005ba:	eb dc                	jmp    800598 <vprintfmt+0x223>
  8005bc:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8005bf:	83 ec 08             	sub    $0x8,%esp
  8005c2:	57                   	push   %edi
  8005c3:	6a 20                	push   $0x20
  8005c5:	ff 55 08             	call   *0x8(%ebp)
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005c8:	4b                   	dec    %ebx
  8005c9:	83 c4 10             	add    $0x10,%esp
  8005cc:	85 db                	test   %ebx,%ebx
  8005ce:	7f ef                	jg     8005bf <vprintfmt+0x24a>
  8005d0:	e9 c4 fd ff ff       	jmp    800399 <vprintfmt+0x24>
  8005d5:	89 5d d8             	mov    %ebx,-0x28(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8005d8:	89 ca                	mov    %ecx,%edx
  8005da:	8d 45 14             	lea    0x14(%ebp),%eax
  8005dd:	e8 2a fd ff ff       	call   80030c <getint>
  8005e2:	89 c3                	mov    %eax,%ebx
  8005e4:	89 d6                	mov    %edx,%esi
			if ((long long) num < 0) {
  8005e6:	85 d2                	test   %edx,%edx
  8005e8:	78 0a                	js     8005f4 <vprintfmt+0x27f>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8005ea:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005ef:	e9 b0 00 00 00       	jmp    8006a4 <vprintfmt+0x32f>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  8005f4:	83 ec 08             	sub    $0x8,%esp
  8005f7:	57                   	push   %edi
  8005f8:	6a 2d                	push   $0x2d
  8005fa:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8005fd:	f7 db                	neg    %ebx
  8005ff:	83 d6 00             	adc    $0x0,%esi
  800602:	f7 de                	neg    %esi
  800604:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800607:	b8 0a 00 00 00       	mov    $0xa,%eax
  80060c:	e9 93 00 00 00       	jmp    8006a4 <vprintfmt+0x32f>
  800611:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800614:	89 ca                	mov    %ecx,%edx
  800616:	8d 45 14             	lea    0x14(%ebp),%eax
  800619:	e8 b4 fc ff ff       	call   8002d2 <getuint>
  80061e:	89 c3                	mov    %eax,%ebx
  800620:	89 d6                	mov    %edx,%esi
			base = 10;
  800622:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  800627:	eb 7b                	jmp    8006a4 <vprintfmt+0x32f>
  800629:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
  80062c:	89 ca                	mov    %ecx,%edx
  80062e:	8d 45 14             	lea    0x14(%ebp),%eax
  800631:	e8 d6 fc ff ff       	call   80030c <getint>
  800636:	89 c3                	mov    %eax,%ebx
  800638:	89 d6                	mov    %edx,%esi
            if ((long long) num < 0) {
  80063a:	85 d2                	test   %edx,%edx
  80063c:	78 07                	js     800645 <vprintfmt+0x2d0>
                putch('-', putdat);
                num = -(long long) num;
            }
            base = 8;
  80063e:	b8 08 00 00 00       	mov    $0x8,%eax
  800643:	eb 5f                	jmp    8006a4 <vprintfmt+0x32f>
		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
            if ((long long) num < 0) {
                putch('-', putdat);
  800645:	83 ec 08             	sub    $0x8,%esp
  800648:	57                   	push   %edi
  800649:	6a 2d                	push   $0x2d
  80064b:	ff 55 08             	call   *0x8(%ebp)
                num = -(long long) num;
  80064e:	f7 db                	neg    %ebx
  800650:	83 d6 00             	adc    $0x0,%esi
  800653:	f7 de                	neg    %esi
  800655:	83 c4 10             	add    $0x10,%esp
            }
            base = 8;
  800658:	b8 08 00 00 00       	mov    $0x8,%eax
  80065d:	eb 45                	jmp    8006a4 <vprintfmt+0x32f>
  80065f:	89 5d d8             	mov    %ebx,-0x28(%ebp)
            goto number;

        // pointer
		case 'p':
			putch('0', putdat);
  800662:	83 ec 08             	sub    $0x8,%esp
  800665:	57                   	push   %edi
  800666:	6a 30                	push   $0x30
  800668:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  80066b:	83 c4 08             	add    $0x8,%esp
  80066e:	57                   	push   %edi
  80066f:	6a 78                	push   $0x78
  800671:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800674:	8b 45 14             	mov    0x14(%ebp),%eax
  800677:	8d 50 04             	lea    0x4(%eax),%edx
  80067a:	89 55 14             	mov    %edx,0x14(%ebp)

        // pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80067d:	8b 18                	mov    (%eax),%ebx
  80067f:	be 00 00 00 00       	mov    $0x0,%esi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800684:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800687:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  80068c:	eb 16                	jmp    8006a4 <vprintfmt+0x32f>
  80068e:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800691:	89 ca                	mov    %ecx,%edx
  800693:	8d 45 14             	lea    0x14(%ebp),%eax
  800696:	e8 37 fc ff ff       	call   8002d2 <getuint>
  80069b:	89 c3                	mov    %eax,%ebx
  80069d:	89 d6                	mov    %edx,%esi
			base = 16;
  80069f:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006a4:	83 ec 0c             	sub    $0xc,%esp
  8006a7:	0f be 55 dc          	movsbl -0x24(%ebp),%edx
  8006ab:	52                   	push   %edx
  8006ac:	ff 75 e4             	pushl  -0x1c(%ebp)
  8006af:	50                   	push   %eax
  8006b0:	56                   	push   %esi
  8006b1:	53                   	push   %ebx
  8006b2:	89 fa                	mov    %edi,%edx
  8006b4:	8b 45 08             	mov    0x8(%ebp),%eax
  8006b7:	e8 68 fb ff ff       	call   800224 <printnum>
			break;
  8006bc:	83 c4 20             	add    $0x20,%esp
  8006bf:	8b 75 d8             	mov    -0x28(%ebp),%esi
  8006c2:	e9 d2 fc ff ff       	jmp    800399 <vprintfmt+0x24>
  8006c7:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006ca:	83 ec 08             	sub    $0x8,%esp
  8006cd:	57                   	push   %edi
  8006ce:	52                   	push   %edx
  8006cf:	ff 55 08             	call   *0x8(%ebp)
			break;
  8006d2:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006d5:	8b 75 d8             	mov    -0x28(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8006d8:	e9 bc fc ff ff       	jmp    800399 <vprintfmt+0x24>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8006dd:	83 ec 08             	sub    $0x8,%esp
  8006e0:	57                   	push   %edi
  8006e1:	6a 25                	push   $0x25
  8006e3:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006e6:	83 c4 10             	add    $0x10,%esp
  8006e9:	eb 02                	jmp    8006ed <vprintfmt+0x378>
  8006eb:	89 c6                	mov    %eax,%esi
  8006ed:	8d 46 ff             	lea    -0x1(%esi),%eax
  8006f0:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  8006f4:	75 f5                	jne    8006eb <vprintfmt+0x376>
  8006f6:	e9 9e fc ff ff       	jmp    800399 <vprintfmt+0x24>
				/* do nothing */;
			break;
		}
	}
}
  8006fb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006fe:	5b                   	pop    %ebx
  8006ff:	5e                   	pop    %esi
  800700:	5f                   	pop    %edi
  800701:	c9                   	leave  
  800702:	c3                   	ret    

00800703 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800703:	55                   	push   %ebp
  800704:	89 e5                	mov    %esp,%ebp
  800706:	83 ec 18             	sub    $0x18,%esp
  800709:	8b 45 08             	mov    0x8(%ebp),%eax
  80070c:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80070f:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800712:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800716:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800719:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800720:	85 c0                	test   %eax,%eax
  800722:	74 26                	je     80074a <vsnprintf+0x47>
  800724:	85 d2                	test   %edx,%edx
  800726:	7e 29                	jle    800751 <vsnprintf+0x4e>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800728:	ff 75 14             	pushl  0x14(%ebp)
  80072b:	ff 75 10             	pushl  0x10(%ebp)
  80072e:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800731:	50                   	push   %eax
  800732:	68 3e 03 80 00       	push   $0x80033e
  800737:	e8 39 fc ff ff       	call   800375 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80073c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80073f:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800742:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800745:	83 c4 10             	add    $0x10,%esp
  800748:	eb 0c                	jmp    800756 <vsnprintf+0x53>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80074a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80074f:	eb 05                	jmp    800756 <vsnprintf+0x53>
  800751:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800756:	c9                   	leave  
  800757:	c3                   	ret    

00800758 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800758:	55                   	push   %ebp
  800759:	89 e5                	mov    %esp,%ebp
  80075b:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80075e:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800761:	50                   	push   %eax
  800762:	ff 75 10             	pushl  0x10(%ebp)
  800765:	ff 75 0c             	pushl  0xc(%ebp)
  800768:	ff 75 08             	pushl  0x8(%ebp)
  80076b:	e8 93 ff ff ff       	call   800703 <vsnprintf>
	va_end(ap);

	return rc;
}
  800770:	c9                   	leave  
  800771:	c3                   	ret    
	...

00800774 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800774:	55                   	push   %ebp
  800775:	89 e5                	mov    %esp,%ebp
  800777:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80077a:	80 3a 00             	cmpb   $0x0,(%edx)
  80077d:	74 0e                	je     80078d <strlen+0x19>
  80077f:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800784:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800785:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800789:	75 f9                	jne    800784 <strlen+0x10>
  80078b:	eb 05                	jmp    800792 <strlen+0x1e>
  80078d:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800792:	c9                   	leave  
  800793:	c3                   	ret    

00800794 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800794:	55                   	push   %ebp
  800795:	89 e5                	mov    %esp,%ebp
  800797:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80079a:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80079d:	85 d2                	test   %edx,%edx
  80079f:	74 17                	je     8007b8 <strnlen+0x24>
  8007a1:	80 39 00             	cmpb   $0x0,(%ecx)
  8007a4:	74 19                	je     8007bf <strnlen+0x2b>
  8007a6:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  8007ab:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007ac:	39 d0                	cmp    %edx,%eax
  8007ae:	74 14                	je     8007c4 <strnlen+0x30>
  8007b0:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8007b4:	75 f5                	jne    8007ab <strnlen+0x17>
  8007b6:	eb 0c                	jmp    8007c4 <strnlen+0x30>
  8007b8:	b8 00 00 00 00       	mov    $0x0,%eax
  8007bd:	eb 05                	jmp    8007c4 <strnlen+0x30>
  8007bf:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  8007c4:	c9                   	leave  
  8007c5:	c3                   	ret    

008007c6 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007c6:	55                   	push   %ebp
  8007c7:	89 e5                	mov    %esp,%ebp
  8007c9:	53                   	push   %ebx
  8007ca:	8b 45 08             	mov    0x8(%ebp),%eax
  8007cd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007d0:	ba 00 00 00 00       	mov    $0x0,%edx
  8007d5:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  8007d8:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  8007db:	42                   	inc    %edx
  8007dc:	84 c9                	test   %cl,%cl
  8007de:	75 f5                	jne    8007d5 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8007e0:	5b                   	pop    %ebx
  8007e1:	c9                   	leave  
  8007e2:	c3                   	ret    

008007e3 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007e3:	55                   	push   %ebp
  8007e4:	89 e5                	mov    %esp,%ebp
  8007e6:	53                   	push   %ebx
  8007e7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007ea:	53                   	push   %ebx
  8007eb:	e8 84 ff ff ff       	call   800774 <strlen>
  8007f0:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8007f3:	ff 75 0c             	pushl  0xc(%ebp)
  8007f6:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  8007f9:	50                   	push   %eax
  8007fa:	e8 c7 ff ff ff       	call   8007c6 <strcpy>
	return dst;
}
  8007ff:	89 d8                	mov    %ebx,%eax
  800801:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800804:	c9                   	leave  
  800805:	c3                   	ret    

00800806 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800806:	55                   	push   %ebp
  800807:	89 e5                	mov    %esp,%ebp
  800809:	56                   	push   %esi
  80080a:	53                   	push   %ebx
  80080b:	8b 45 08             	mov    0x8(%ebp),%eax
  80080e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800811:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800814:	85 f6                	test   %esi,%esi
  800816:	74 15                	je     80082d <strncpy+0x27>
  800818:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  80081d:	8a 1a                	mov    (%edx),%bl
  80081f:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800822:	80 3a 01             	cmpb   $0x1,(%edx)
  800825:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800828:	41                   	inc    %ecx
  800829:	39 ce                	cmp    %ecx,%esi
  80082b:	77 f0                	ja     80081d <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80082d:	5b                   	pop    %ebx
  80082e:	5e                   	pop    %esi
  80082f:	c9                   	leave  
  800830:	c3                   	ret    

00800831 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800831:	55                   	push   %ebp
  800832:	89 e5                	mov    %esp,%ebp
  800834:	57                   	push   %edi
  800835:	56                   	push   %esi
  800836:	53                   	push   %ebx
  800837:	8b 7d 08             	mov    0x8(%ebp),%edi
  80083a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80083d:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800840:	85 f6                	test   %esi,%esi
  800842:	74 32                	je     800876 <strlcpy+0x45>
		while (--size > 0 && *src != '\0')
  800844:	83 fe 01             	cmp    $0x1,%esi
  800847:	74 22                	je     80086b <strlcpy+0x3a>
  800849:	8a 0b                	mov    (%ebx),%cl
  80084b:	84 c9                	test   %cl,%cl
  80084d:	74 20                	je     80086f <strlcpy+0x3e>
  80084f:	89 f8                	mov    %edi,%eax
  800851:	ba 00 00 00 00       	mov    $0x0,%edx
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
  800856:	83 ee 02             	sub    $0x2,%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800859:	88 08                	mov    %cl,(%eax)
  80085b:	40                   	inc    %eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80085c:	39 f2                	cmp    %esi,%edx
  80085e:	74 11                	je     800871 <strlcpy+0x40>
  800860:	8a 4c 13 01          	mov    0x1(%ebx,%edx,1),%cl
  800864:	42                   	inc    %edx
  800865:	84 c9                	test   %cl,%cl
  800867:	75 f0                	jne    800859 <strlcpy+0x28>
  800869:	eb 06                	jmp    800871 <strlcpy+0x40>
  80086b:	89 f8                	mov    %edi,%eax
  80086d:	eb 02                	jmp    800871 <strlcpy+0x40>
  80086f:	89 f8                	mov    %edi,%eax
			*dst++ = *src++;
		*dst = '\0';
  800871:	c6 00 00             	movb   $0x0,(%eax)
  800874:	eb 02                	jmp    800878 <strlcpy+0x47>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800876:	89 f8                	mov    %edi,%eax
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
		*dst = '\0';
	}
	return dst - dst_in;
  800878:	29 f8                	sub    %edi,%eax
}
  80087a:	5b                   	pop    %ebx
  80087b:	5e                   	pop    %esi
  80087c:	5f                   	pop    %edi
  80087d:	c9                   	leave  
  80087e:	c3                   	ret    

0080087f <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80087f:	55                   	push   %ebp
  800880:	89 e5                	mov    %esp,%ebp
  800882:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800885:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800888:	8a 01                	mov    (%ecx),%al
  80088a:	84 c0                	test   %al,%al
  80088c:	74 10                	je     80089e <strcmp+0x1f>
  80088e:	3a 02                	cmp    (%edx),%al
  800890:	75 0c                	jne    80089e <strcmp+0x1f>
		p++, q++;
  800892:	41                   	inc    %ecx
  800893:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800894:	8a 01                	mov    (%ecx),%al
  800896:	84 c0                	test   %al,%al
  800898:	74 04                	je     80089e <strcmp+0x1f>
  80089a:	3a 02                	cmp    (%edx),%al
  80089c:	74 f4                	je     800892 <strcmp+0x13>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80089e:	0f b6 c0             	movzbl %al,%eax
  8008a1:	0f b6 12             	movzbl (%edx),%edx
  8008a4:	29 d0                	sub    %edx,%eax
}
  8008a6:	c9                   	leave  
  8008a7:	c3                   	ret    

008008a8 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008a8:	55                   	push   %ebp
  8008a9:	89 e5                	mov    %esp,%ebp
  8008ab:	53                   	push   %ebx
  8008ac:	8b 55 08             	mov    0x8(%ebp),%edx
  8008af:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008b2:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  8008b5:	85 c0                	test   %eax,%eax
  8008b7:	74 1b                	je     8008d4 <strncmp+0x2c>
  8008b9:	8a 1a                	mov    (%edx),%bl
  8008bb:	84 db                	test   %bl,%bl
  8008bd:	74 24                	je     8008e3 <strncmp+0x3b>
  8008bf:	3a 19                	cmp    (%ecx),%bl
  8008c1:	75 20                	jne    8008e3 <strncmp+0x3b>
  8008c3:	48                   	dec    %eax
  8008c4:	74 15                	je     8008db <strncmp+0x33>
		n--, p++, q++;
  8008c6:	42                   	inc    %edx
  8008c7:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8008c8:	8a 1a                	mov    (%edx),%bl
  8008ca:	84 db                	test   %bl,%bl
  8008cc:	74 15                	je     8008e3 <strncmp+0x3b>
  8008ce:	3a 19                	cmp    (%ecx),%bl
  8008d0:	74 f1                	je     8008c3 <strncmp+0x1b>
  8008d2:	eb 0f                	jmp    8008e3 <strncmp+0x3b>
		n--, p++, q++;
	if (n == 0)
		return 0;
  8008d4:	b8 00 00 00 00       	mov    $0x0,%eax
  8008d9:	eb 05                	jmp    8008e0 <strncmp+0x38>
  8008db:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8008e0:	5b                   	pop    %ebx
  8008e1:	c9                   	leave  
  8008e2:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008e3:	0f b6 02             	movzbl (%edx),%eax
  8008e6:	0f b6 11             	movzbl (%ecx),%edx
  8008e9:	29 d0                	sub    %edx,%eax
  8008eb:	eb f3                	jmp    8008e0 <strncmp+0x38>

008008ed <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008ed:	55                   	push   %ebp
  8008ee:	89 e5                	mov    %esp,%ebp
  8008f0:	8b 45 08             	mov    0x8(%ebp),%eax
  8008f3:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8008f6:	8a 10                	mov    (%eax),%dl
  8008f8:	84 d2                	test   %dl,%dl
  8008fa:	74 18                	je     800914 <strchr+0x27>
		if (*s == c)
  8008fc:	38 ca                	cmp    %cl,%dl
  8008fe:	75 06                	jne    800906 <strchr+0x19>
  800900:	eb 17                	jmp    800919 <strchr+0x2c>
  800902:	38 ca                	cmp    %cl,%dl
  800904:	74 13                	je     800919 <strchr+0x2c>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800906:	40                   	inc    %eax
  800907:	8a 10                	mov    (%eax),%dl
  800909:	84 d2                	test   %dl,%dl
  80090b:	75 f5                	jne    800902 <strchr+0x15>
		if (*s == c)
			return (char *) s;
	return 0;
  80090d:	b8 00 00 00 00       	mov    $0x0,%eax
  800912:	eb 05                	jmp    800919 <strchr+0x2c>
  800914:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800919:	c9                   	leave  
  80091a:	c3                   	ret    

0080091b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80091b:	55                   	push   %ebp
  80091c:	89 e5                	mov    %esp,%ebp
  80091e:	8b 45 08             	mov    0x8(%ebp),%eax
  800921:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800924:	8a 10                	mov    (%eax),%dl
  800926:	84 d2                	test   %dl,%dl
  800928:	74 11                	je     80093b <strfind+0x20>
		if (*s == c)
  80092a:	38 ca                	cmp    %cl,%dl
  80092c:	75 06                	jne    800934 <strfind+0x19>
  80092e:	eb 0b                	jmp    80093b <strfind+0x20>
  800930:	38 ca                	cmp    %cl,%dl
  800932:	74 07                	je     80093b <strfind+0x20>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800934:	40                   	inc    %eax
  800935:	8a 10                	mov    (%eax),%dl
  800937:	84 d2                	test   %dl,%dl
  800939:	75 f5                	jne    800930 <strfind+0x15>
		if (*s == c)
			break;
	return (char *) s;
}
  80093b:	c9                   	leave  
  80093c:	c3                   	ret    

0080093d <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80093d:	55                   	push   %ebp
  80093e:	89 e5                	mov    %esp,%ebp
  800940:	57                   	push   %edi
  800941:	56                   	push   %esi
  800942:	53                   	push   %ebx
  800943:	8b 7d 08             	mov    0x8(%ebp),%edi
  800946:	8b 45 0c             	mov    0xc(%ebp),%eax
  800949:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80094c:	85 c9                	test   %ecx,%ecx
  80094e:	74 30                	je     800980 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800950:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800956:	75 25                	jne    80097d <memset+0x40>
  800958:	f6 c1 03             	test   $0x3,%cl
  80095b:	75 20                	jne    80097d <memset+0x40>
		c &= 0xFF;
  80095d:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800960:	89 d3                	mov    %edx,%ebx
  800962:	c1 e3 08             	shl    $0x8,%ebx
  800965:	89 d6                	mov    %edx,%esi
  800967:	c1 e6 18             	shl    $0x18,%esi
  80096a:	89 d0                	mov    %edx,%eax
  80096c:	c1 e0 10             	shl    $0x10,%eax
  80096f:	09 f0                	or     %esi,%eax
  800971:	09 d0                	or     %edx,%eax
  800973:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800975:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800978:	fc                   	cld    
  800979:	f3 ab                	rep stos %eax,%es:(%edi)
  80097b:	eb 03                	jmp    800980 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80097d:	fc                   	cld    
  80097e:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800980:	89 f8                	mov    %edi,%eax
  800982:	5b                   	pop    %ebx
  800983:	5e                   	pop    %esi
  800984:	5f                   	pop    %edi
  800985:	c9                   	leave  
  800986:	c3                   	ret    

00800987 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800987:	55                   	push   %ebp
  800988:	89 e5                	mov    %esp,%ebp
  80098a:	57                   	push   %edi
  80098b:	56                   	push   %esi
  80098c:	8b 45 08             	mov    0x8(%ebp),%eax
  80098f:	8b 75 0c             	mov    0xc(%ebp),%esi
  800992:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800995:	39 c6                	cmp    %eax,%esi
  800997:	73 34                	jae    8009cd <memmove+0x46>
  800999:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80099c:	39 d0                	cmp    %edx,%eax
  80099e:	73 2d                	jae    8009cd <memmove+0x46>
		s += n;
		d += n;
  8009a0:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009a3:	f6 c2 03             	test   $0x3,%dl
  8009a6:	75 1b                	jne    8009c3 <memmove+0x3c>
  8009a8:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8009ae:	75 13                	jne    8009c3 <memmove+0x3c>
  8009b0:	f6 c1 03             	test   $0x3,%cl
  8009b3:	75 0e                	jne    8009c3 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8009b5:	83 ef 04             	sub    $0x4,%edi
  8009b8:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009bb:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  8009be:	fd                   	std    
  8009bf:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009c1:	eb 07                	jmp    8009ca <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8009c3:	4f                   	dec    %edi
  8009c4:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8009c7:	fd                   	std    
  8009c8:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009ca:	fc                   	cld    
  8009cb:	eb 20                	jmp    8009ed <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009cd:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009d3:	75 13                	jne    8009e8 <memmove+0x61>
  8009d5:	a8 03                	test   $0x3,%al
  8009d7:	75 0f                	jne    8009e8 <memmove+0x61>
  8009d9:	f6 c1 03             	test   $0x3,%cl
  8009dc:	75 0a                	jne    8009e8 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8009de:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  8009e1:	89 c7                	mov    %eax,%edi
  8009e3:	fc                   	cld    
  8009e4:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009e6:	eb 05                	jmp    8009ed <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8009e8:	89 c7                	mov    %eax,%edi
  8009ea:	fc                   	cld    
  8009eb:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009ed:	5e                   	pop    %esi
  8009ee:	5f                   	pop    %edi
  8009ef:	c9                   	leave  
  8009f0:	c3                   	ret    

008009f1 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009f1:	55                   	push   %ebp
  8009f2:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8009f4:	ff 75 10             	pushl  0x10(%ebp)
  8009f7:	ff 75 0c             	pushl  0xc(%ebp)
  8009fa:	ff 75 08             	pushl  0x8(%ebp)
  8009fd:	e8 85 ff ff ff       	call   800987 <memmove>
}
  800a02:	c9                   	leave  
  800a03:	c3                   	ret    

00800a04 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a04:	55                   	push   %ebp
  800a05:	89 e5                	mov    %esp,%ebp
  800a07:	57                   	push   %edi
  800a08:	56                   	push   %esi
  800a09:	53                   	push   %ebx
  800a0a:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800a0d:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a10:	8b 7d 10             	mov    0x10(%ebp),%edi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a13:	85 ff                	test   %edi,%edi
  800a15:	74 32                	je     800a49 <memcmp+0x45>
		if (*s1 != *s2)
  800a17:	8a 03                	mov    (%ebx),%al
  800a19:	8a 0e                	mov    (%esi),%cl
  800a1b:	38 c8                	cmp    %cl,%al
  800a1d:	74 19                	je     800a38 <memcmp+0x34>
  800a1f:	eb 0d                	jmp    800a2e <memcmp+0x2a>
  800a21:	8a 44 13 01          	mov    0x1(%ebx,%edx,1),%al
  800a25:	8a 4c 16 01          	mov    0x1(%esi,%edx,1),%cl
  800a29:	42                   	inc    %edx
  800a2a:	38 c8                	cmp    %cl,%al
  800a2c:	74 10                	je     800a3e <memcmp+0x3a>
			return (int) *s1 - (int) *s2;
  800a2e:	0f b6 c0             	movzbl %al,%eax
  800a31:	0f b6 c9             	movzbl %cl,%ecx
  800a34:	29 c8                	sub    %ecx,%eax
  800a36:	eb 16                	jmp    800a4e <memcmp+0x4a>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a38:	4f                   	dec    %edi
  800a39:	ba 00 00 00 00       	mov    $0x0,%edx
  800a3e:	39 fa                	cmp    %edi,%edx
  800a40:	75 df                	jne    800a21 <memcmp+0x1d>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a42:	b8 00 00 00 00       	mov    $0x0,%eax
  800a47:	eb 05                	jmp    800a4e <memcmp+0x4a>
  800a49:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a4e:	5b                   	pop    %ebx
  800a4f:	5e                   	pop    %esi
  800a50:	5f                   	pop    %edi
  800a51:	c9                   	leave  
  800a52:	c3                   	ret    

00800a53 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a53:	55                   	push   %ebp
  800a54:	89 e5                	mov    %esp,%ebp
  800a56:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800a59:	89 c2                	mov    %eax,%edx
  800a5b:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a5e:	39 d0                	cmp    %edx,%eax
  800a60:	73 12                	jae    800a74 <memfind+0x21>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a62:	8a 4d 0c             	mov    0xc(%ebp),%cl
  800a65:	38 08                	cmp    %cl,(%eax)
  800a67:	75 06                	jne    800a6f <memfind+0x1c>
  800a69:	eb 09                	jmp    800a74 <memfind+0x21>
  800a6b:	38 08                	cmp    %cl,(%eax)
  800a6d:	74 05                	je     800a74 <memfind+0x21>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a6f:	40                   	inc    %eax
  800a70:	39 c2                	cmp    %eax,%edx
  800a72:	77 f7                	ja     800a6b <memfind+0x18>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a74:	c9                   	leave  
  800a75:	c3                   	ret    

00800a76 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a76:	55                   	push   %ebp
  800a77:	89 e5                	mov    %esp,%ebp
  800a79:	57                   	push   %edi
  800a7a:	56                   	push   %esi
  800a7b:	53                   	push   %ebx
  800a7c:	8b 55 08             	mov    0x8(%ebp),%edx
  800a7f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a82:	eb 01                	jmp    800a85 <strtol+0xf>
		s++;
  800a84:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a85:	8a 02                	mov    (%edx),%al
  800a87:	3c 20                	cmp    $0x20,%al
  800a89:	74 f9                	je     800a84 <strtol+0xe>
  800a8b:	3c 09                	cmp    $0x9,%al
  800a8d:	74 f5                	je     800a84 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a8f:	3c 2b                	cmp    $0x2b,%al
  800a91:	75 08                	jne    800a9b <strtol+0x25>
		s++;
  800a93:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a94:	bf 00 00 00 00       	mov    $0x0,%edi
  800a99:	eb 13                	jmp    800aae <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a9b:	3c 2d                	cmp    $0x2d,%al
  800a9d:	75 0a                	jne    800aa9 <strtol+0x33>
		s++, neg = 1;
  800a9f:	8d 52 01             	lea    0x1(%edx),%edx
  800aa2:	bf 01 00 00 00       	mov    $0x1,%edi
  800aa7:	eb 05                	jmp    800aae <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800aa9:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800aae:	85 db                	test   %ebx,%ebx
  800ab0:	74 05                	je     800ab7 <strtol+0x41>
  800ab2:	83 fb 10             	cmp    $0x10,%ebx
  800ab5:	75 28                	jne    800adf <strtol+0x69>
  800ab7:	8a 02                	mov    (%edx),%al
  800ab9:	3c 30                	cmp    $0x30,%al
  800abb:	75 10                	jne    800acd <strtol+0x57>
  800abd:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800ac1:	75 0a                	jne    800acd <strtol+0x57>
		s += 2, base = 16;
  800ac3:	83 c2 02             	add    $0x2,%edx
  800ac6:	bb 10 00 00 00       	mov    $0x10,%ebx
  800acb:	eb 12                	jmp    800adf <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800acd:	85 db                	test   %ebx,%ebx
  800acf:	75 0e                	jne    800adf <strtol+0x69>
  800ad1:	3c 30                	cmp    $0x30,%al
  800ad3:	75 05                	jne    800ada <strtol+0x64>
		s++, base = 8;
  800ad5:	42                   	inc    %edx
  800ad6:	b3 08                	mov    $0x8,%bl
  800ad8:	eb 05                	jmp    800adf <strtol+0x69>
	else if (base == 0)
		base = 10;
  800ada:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800adf:	b8 00 00 00 00       	mov    $0x0,%eax
  800ae4:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800ae6:	8a 0a                	mov    (%edx),%cl
  800ae8:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800aeb:	80 fb 09             	cmp    $0x9,%bl
  800aee:	77 08                	ja     800af8 <strtol+0x82>
			dig = *s - '0';
  800af0:	0f be c9             	movsbl %cl,%ecx
  800af3:	83 e9 30             	sub    $0x30,%ecx
  800af6:	eb 1e                	jmp    800b16 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800af8:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800afb:	80 fb 19             	cmp    $0x19,%bl
  800afe:	77 08                	ja     800b08 <strtol+0x92>
			dig = *s - 'a' + 10;
  800b00:	0f be c9             	movsbl %cl,%ecx
  800b03:	83 e9 57             	sub    $0x57,%ecx
  800b06:	eb 0e                	jmp    800b16 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800b08:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800b0b:	80 fb 19             	cmp    $0x19,%bl
  800b0e:	77 13                	ja     800b23 <strtol+0xad>
			dig = *s - 'A' + 10;
  800b10:	0f be c9             	movsbl %cl,%ecx
  800b13:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800b16:	39 f1                	cmp    %esi,%ecx
  800b18:	7d 0d                	jge    800b27 <strtol+0xb1>
			break;
		s++, val = (val * base) + dig;
  800b1a:	42                   	inc    %edx
  800b1b:	0f af c6             	imul   %esi,%eax
  800b1e:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  800b21:	eb c3                	jmp    800ae6 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800b23:	89 c1                	mov    %eax,%ecx
  800b25:	eb 02                	jmp    800b29 <strtol+0xb3>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800b27:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800b29:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b2d:	74 05                	je     800b34 <strtol+0xbe>
		*endptr = (char *) s;
  800b2f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800b32:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800b34:	85 ff                	test   %edi,%edi
  800b36:	74 04                	je     800b3c <strtol+0xc6>
  800b38:	89 c8                	mov    %ecx,%eax
  800b3a:	f7 d8                	neg    %eax
}
  800b3c:	5b                   	pop    %ebx
  800b3d:	5e                   	pop    %esi
  800b3e:	5f                   	pop    %edi
  800b3f:	c9                   	leave  
  800b40:	c3                   	ret    
  800b41:	00 00                	add    %al,(%eax)
	...

00800b44 <syscall>:
	return ret;
}

static int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800b44:	55                   	push   %ebp
  800b45:	89 e5                	mov    %esp,%ebp
  800b47:	57                   	push   %edi
  800b48:	56                   	push   %esi
  800b49:	53                   	push   %ebx
  800b4a:	83 ec 1c             	sub    $0x1c,%esp
  800b4d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800b50:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800b53:	89 ca                	mov    %ecx,%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b55:	8b 75 14             	mov    0x14(%ebp),%esi
  800b58:	8b 7d 10             	mov    0x10(%ebp),%edi
  800b5b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800b5e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b61:	cd 30                	int    $0x30
  800b63:	89 c2                	mov    %eax,%edx
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b65:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800b69:	74 1c                	je     800b87 <syscall+0x43>
  800b6b:	85 c0                	test   %eax,%eax
  800b6d:	7e 18                	jle    800b87 <syscall+0x43>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b6f:	83 ec 0c             	sub    $0xc,%esp
  800b72:	50                   	push   %eax
  800b73:	ff 75 e4             	pushl  -0x1c(%ebp)
  800b76:	68 3f 22 80 00       	push   $0x80223f
  800b7b:	6a 42                	push   $0x42
  800b7d:	68 5c 22 80 00       	push   $0x80225c
  800b82:	e8 b1 f5 ff ff       	call   800138 <_panic>

	return ret;
}
  800b87:	89 d0                	mov    %edx,%eax
  800b89:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b8c:	5b                   	pop    %ebx
  800b8d:	5e                   	pop    %esi
  800b8e:	5f                   	pop    %edi
  800b8f:	c9                   	leave  
  800b90:	c3                   	ret    

00800b91 <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{	
  800b91:	55                   	push   %ebp
  800b92:	89 e5                	mov    %esp,%ebp
  800b94:	83 ec 08             	sub    $0x8,%esp
	// my_sysenter(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
	// return;
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  800b97:	6a 00                	push   $0x0
  800b99:	6a 00                	push   $0x0
  800b9b:	6a 00                	push   $0x0
  800b9d:	ff 75 0c             	pushl  0xc(%ebp)
  800ba0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ba3:	ba 00 00 00 00       	mov    $0x0,%edx
  800ba8:	b8 00 00 00 00       	mov    $0x0,%eax
  800bad:	e8 92 ff ff ff       	call   800b44 <syscall>
  800bb2:	83 c4 10             	add    $0x10,%esp
	return;
}
  800bb5:	c9                   	leave  
  800bb6:	c3                   	ret    

00800bb7 <sys_cgetc>:

int
sys_cgetc(void)
{
  800bb7:	55                   	push   %ebp
  800bb8:	89 e5                	mov    %esp,%ebp
  800bba:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_cgetc, 0, 0, 0, 0, 0, 0);
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  800bbd:	6a 00                	push   $0x0
  800bbf:	6a 00                	push   $0x0
  800bc1:	6a 00                	push   $0x0
  800bc3:	6a 00                	push   $0x0
  800bc5:	b9 00 00 00 00       	mov    $0x0,%ecx
  800bca:	ba 00 00 00 00       	mov    $0x0,%edx
  800bcf:	b8 01 00 00 00       	mov    $0x1,%eax
  800bd4:	e8 6b ff ff ff       	call   800b44 <syscall>
}
  800bd9:	c9                   	leave  
  800bda:	c3                   	ret    

00800bdb <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800bdb:	55                   	push   %ebp
  800bdc:	89 e5                	mov    %esp,%ebp
  800bde:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  800be1:	6a 00                	push   $0x0
  800be3:	6a 00                	push   $0x0
  800be5:	6a 00                	push   $0x0
  800be7:	6a 00                	push   $0x0
  800be9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800bec:	ba 01 00 00 00       	mov    $0x1,%edx
  800bf1:	b8 03 00 00 00       	mov    $0x3,%eax
  800bf6:	e8 49 ff ff ff       	call   800b44 <syscall>
}
  800bfb:	c9                   	leave  
  800bfc:	c3                   	ret    

00800bfd <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800bfd:	55                   	push   %ebp
  800bfe:	89 e5                	mov    %esp,%ebp
  800c00:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_getenvid, 0, 0, 0, 0, 0, 0);
	return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  800c03:	6a 00                	push   $0x0
  800c05:	6a 00                	push   $0x0
  800c07:	6a 00                	push   $0x0
  800c09:	6a 00                	push   $0x0
  800c0b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c10:	ba 00 00 00 00       	mov    $0x0,%edx
  800c15:	b8 02 00 00 00       	mov    $0x2,%eax
  800c1a:	e8 25 ff ff ff       	call   800b44 <syscall>
}
  800c1f:	c9                   	leave  
  800c20:	c3                   	ret    

00800c21 <sys_yield>:

void
sys_yield(void)
{
  800c21:	55                   	push   %ebp
  800c22:	89 e5                	mov    %esp,%ebp
  800c24:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  800c27:	6a 00                	push   $0x0
  800c29:	6a 00                	push   $0x0
  800c2b:	6a 00                	push   $0x0
  800c2d:	6a 00                	push   $0x0
  800c2f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c34:	ba 00 00 00 00       	mov    $0x0,%edx
  800c39:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c3e:	e8 01 ff ff ff       	call   800b44 <syscall>
  800c43:	83 c4 10             	add    $0x10,%esp
}
  800c46:	c9                   	leave  
  800c47:	c3                   	ret    

00800c48 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c48:	55                   	push   %ebp
  800c49:	89 e5                	mov    %esp,%ebp
  800c4b:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  800c4e:	6a 00                	push   $0x0
  800c50:	6a 00                	push   $0x0
  800c52:	ff 75 10             	pushl  0x10(%ebp)
  800c55:	ff 75 0c             	pushl  0xc(%ebp)
  800c58:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c5b:	ba 01 00 00 00       	mov    $0x1,%edx
  800c60:	b8 04 00 00 00       	mov    $0x4,%eax
  800c65:	e8 da fe ff ff       	call   800b44 <syscall>
}
  800c6a:	c9                   	leave  
  800c6b:	c3                   	ret    

00800c6c <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c6c:	55                   	push   %ebp
  800c6d:	89 e5                	mov    %esp,%ebp
  800c6f:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
  800c72:	ff 75 18             	pushl  0x18(%ebp)
  800c75:	ff 75 14             	pushl  0x14(%ebp)
  800c78:	ff 75 10             	pushl  0x10(%ebp)
  800c7b:	ff 75 0c             	pushl  0xc(%ebp)
  800c7e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c81:	ba 01 00 00 00       	mov    $0x1,%edx
  800c86:	b8 05 00 00 00       	mov    $0x5,%eax
  800c8b:	e8 b4 fe ff ff       	call   800b44 <syscall>
}
  800c90:	c9                   	leave  
  800c91:	c3                   	ret    

00800c92 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c92:	55                   	push   %ebp
  800c93:	89 e5                	mov    %esp,%ebp
  800c95:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  800c98:	6a 00                	push   $0x0
  800c9a:	6a 00                	push   $0x0
  800c9c:	6a 00                	push   $0x0
  800c9e:	ff 75 0c             	pushl  0xc(%ebp)
  800ca1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ca4:	ba 01 00 00 00       	mov    $0x1,%edx
  800ca9:	b8 06 00 00 00       	mov    $0x6,%eax
  800cae:	e8 91 fe ff ff       	call   800b44 <syscall>
}
  800cb3:	c9                   	leave  
  800cb4:	c3                   	ret    

00800cb5 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800cb5:	55                   	push   %ebp
  800cb6:	89 e5                	mov    %esp,%ebp
  800cb8:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  800cbb:	6a 00                	push   $0x0
  800cbd:	6a 00                	push   $0x0
  800cbf:	6a 00                	push   $0x0
  800cc1:	ff 75 0c             	pushl  0xc(%ebp)
  800cc4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800cc7:	ba 01 00 00 00       	mov    $0x1,%edx
  800ccc:	b8 08 00 00 00       	mov    $0x8,%eax
  800cd1:	e8 6e fe ff ff       	call   800b44 <syscall>
}
  800cd6:	c9                   	leave  
  800cd7:	c3                   	ret    

00800cd8 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800cd8:	55                   	push   %ebp
  800cd9:	89 e5                	mov    %esp,%ebp
  800cdb:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
  800cde:	6a 00                	push   $0x0
  800ce0:	6a 00                	push   $0x0
  800ce2:	6a 00                	push   $0x0
  800ce4:	ff 75 0c             	pushl  0xc(%ebp)
  800ce7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800cea:	ba 01 00 00 00       	mov    $0x1,%edx
  800cef:	b8 09 00 00 00       	mov    $0x9,%eax
  800cf4:	e8 4b fe ff ff       	call   800b44 <syscall>
}
  800cf9:	c9                   	leave  
  800cfa:	c3                   	ret    

00800cfb <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800cfb:	55                   	push   %ebp
  800cfc:	89 e5                	mov    %esp,%ebp
  800cfe:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  800d01:	6a 00                	push   $0x0
  800d03:	6a 00                	push   $0x0
  800d05:	6a 00                	push   $0x0
  800d07:	ff 75 0c             	pushl  0xc(%ebp)
  800d0a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d0d:	ba 01 00 00 00       	mov    $0x1,%edx
  800d12:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d17:	e8 28 fe ff ff       	call   800b44 <syscall>
}
  800d1c:	c9                   	leave  
  800d1d:	c3                   	ret    

00800d1e <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d1e:	55                   	push   %ebp
  800d1f:	89 e5                	mov    %esp,%ebp
  800d21:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  800d24:	6a 00                	push   $0x0
  800d26:	ff 75 14             	pushl  0x14(%ebp)
  800d29:	ff 75 10             	pushl  0x10(%ebp)
  800d2c:	ff 75 0c             	pushl  0xc(%ebp)
  800d2f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d32:	ba 00 00 00 00       	mov    $0x0,%edx
  800d37:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d3c:	e8 03 fe ff ff       	call   800b44 <syscall>
}
  800d41:	c9                   	leave  
  800d42:	c3                   	ret    

00800d43 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d43:	55                   	push   %ebp
  800d44:	89 e5                	mov    %esp,%ebp
  800d46:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  800d49:	6a 00                	push   $0x0
  800d4b:	6a 00                	push   $0x0
  800d4d:	6a 00                	push   $0x0
  800d4f:	6a 00                	push   $0x0
  800d51:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d54:	ba 01 00 00 00       	mov    $0x1,%edx
  800d59:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d5e:	e8 e1 fd ff ff       	call   800b44 <syscall>
}
  800d63:	c9                   	leave  
  800d64:	c3                   	ret    

00800d65 <sys_set_priority>:

int
sys_set_priority(envid_t envid, uint32_t new_priority)
{
  800d65:	55                   	push   %ebp
  800d66:	89 e5                	mov    %esp,%ebp
  800d68:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_set_priority, 0, envid, new_priority, 0, 0, 0);
  800d6b:	6a 00                	push   $0x0
  800d6d:	6a 00                	push   $0x0
  800d6f:	6a 00                	push   $0x0
  800d71:	ff 75 0c             	pushl  0xc(%ebp)
  800d74:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d77:	ba 00 00 00 00       	mov    $0x0,%edx
  800d7c:	b8 0e 00 00 00       	mov    $0xe,%eax
  800d81:	e8 be fd ff ff       	call   800b44 <syscall>
}
  800d86:	c9                   	leave  
  800d87:	c3                   	ret    

00800d88 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  800d88:	55                   	push   %ebp
  800d89:	89 e5                	mov    %esp,%ebp
  800d8b:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  800d8e:	83 3d 08 40 80 00 00 	cmpl   $0x0,0x804008
  800d95:	75 52                	jne    800de9 <set_pgfault_handler+0x61>
		// First time through!	
		// LAB 4: Your code here.

		//int sys_page_alloc(envid_t envid, void *va, int perm)
		r = sys_page_alloc(0, (void*)(UXSTACKTOP - PGSIZE), PTE_U | PTE_W | PTE_P);
  800d97:	83 ec 04             	sub    $0x4,%esp
  800d9a:	6a 07                	push   $0x7
  800d9c:	68 00 f0 bf ee       	push   $0xeebff000
  800da1:	6a 00                	push   $0x0
  800da3:	e8 a0 fe ff ff       	call   800c48 <sys_page_alloc>
		if (r < 0) {
  800da8:	83 c4 10             	add    $0x10,%esp
  800dab:	85 c0                	test   %eax,%eax
  800dad:	79 12                	jns    800dc1 <set_pgfault_handler+0x39>
			panic("sys_page_alloc error : %e\n", r);
  800daf:	50                   	push   %eax
  800db0:	68 6a 22 80 00       	push   $0x80226a
  800db5:	6a 24                	push   $0x24
  800db7:	68 85 22 80 00       	push   $0x802285
  800dbc:	e8 77 f3 ff ff       	call   800138 <_panic>
		}

		// how to know envid, put 0, envid2env will help us to get curenv in syscall
		r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);		
  800dc1:	83 ec 08             	sub    $0x8,%esp
  800dc4:	68 f4 0d 80 00       	push   $0x800df4
  800dc9:	6a 00                	push   $0x0
  800dcb:	e8 2b ff ff ff       	call   800cfb <sys_env_set_pgfault_upcall>
		if (r < 0) {
  800dd0:	83 c4 10             	add    $0x10,%esp
  800dd3:	85 c0                	test   %eax,%eax
  800dd5:	79 12                	jns    800de9 <set_pgfault_handler+0x61>
			panic("sys_env_set_pgfault_upcall error : %e\n", r);
  800dd7:	50                   	push   %eax
  800dd8:	68 94 22 80 00       	push   $0x802294
  800ddd:	6a 2a                	push   $0x2a
  800ddf:	68 85 22 80 00       	push   $0x802285
  800de4:	e8 4f f3 ff ff       	call   800138 <_panic>
		}
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  800de9:	8b 45 08             	mov    0x8(%ebp),%eax
  800dec:	a3 08 40 80 00       	mov    %eax,0x804008
}
  800df1:	c9                   	leave  
  800df2:	c3                   	ret    
	...

00800df4 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  800df4:	54                   	push   %esp
	movl _pgfault_handler, %eax
  800df5:	a1 08 40 80 00       	mov    0x804008,%eax
	call *%eax
  800dfa:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  800dfc:	83 c4 04             	add    $0x4,%esp
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	
	// fix old esp
	movl 0x30(%esp), %eax
  800dff:	8b 44 24 30          	mov    0x30(%esp),%eax
	subl $0x4, %eax
  800e03:	83 e8 04             	sub    $0x4,%eax
	movl %eax, 0x30(%esp)
  800e06:	89 44 24 30          	mov    %eax,0x30(%esp)

	// set trap-time %eip
	movl 0x28(%esp), %ebx
  800e0a:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	movl %ebx, (%eax)
  800e0e:	89 18                	mov    %ebx,(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $0x08, %esp 	// ignore err_code and fault_va
  800e10:	83 c4 08             	add    $0x8,%esp
	popal 				// restore registers
  800e13:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x04, %esp 	// ignore eip 
  800e14:	83 c4 04             	add    $0x4,%esp
	popfl				// modify eflags
  800e17:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  800e18:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  800e19:	c3                   	ret    
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
  800f3e:	8b 14 85 3c 23 80 00 	mov    0x80233c(,%eax,4),%edx
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
  800f56:	68 bc 22 80 00       	push   $0x8022bc
  800f5b:	e8 b0 f2 ff ff       	call   800210 <cprintf>
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
  800fea:	e8 a3 fc ff ff       	call   800c92 <sys_page_unmap>
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
  8010d4:	e8 93 fb ff ff       	call   800c6c <sys_page_map>
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
  801101:	e8 66 fb ff ff       	call   800c6c <sys_page_map>
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
  801115:	e8 78 fb ff ff       	call   800c92 <sys_page_unmap>
	sys_page_unmap(0, nva);
  80111a:	83 c4 08             	add    $0x8,%esp
  80111d:	ff 75 d4             	pushl  -0x2c(%ebp)
  801120:	6a 00                	push   $0x0
  801122:	e8 6b fb ff ff       	call   800c92 <sys_page_unmap>
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
  801186:	68 00 23 80 00       	push   $0x802300
  80118b:	e8 80 f0 ff ff       	call   800210 <cprintf>
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
  80125d:	68 1c 23 80 00       	push   $0x80231c
  801262:	e8 a9 ef ff ff       	call   800210 <cprintf>
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
  801308:	68 dc 22 80 00       	push   $0x8022dc
  80130d:	e8 fe ee ff ff       	call   800210 <cprintf>
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
  80140b:	e8 8a 07 00 00       	call   801b9a <ipc_find_env>
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
  801426:	e8 1a 07 00 00       	call   801b45 <ipc_send>
	
	return ipc_recv(NULL, dstva, NULL);
  80142b:	83 c4 0c             	add    $0xc,%esp
  80142e:	6a 00                	push   $0x0
  801430:	56                   	push   %esi
  801431:	6a 00                	push   $0x0
  801433:	e8 98 06 00 00       	call   801ad0 <ipc_recv>
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
  801470:	e8 51 f3 ff ff       	call   8007c6 <strcpy>
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
  8014ec:	68 4c 23 80 00       	push   $0x80234c
  8014f1:	68 53 23 80 00       	push   $0x802353
  8014f6:	6a 7d                	push   $0x7d
  8014f8:	68 68 23 80 00       	push   $0x802368
  8014fd:	e8 36 ec ff ff       	call   800138 <_panic>
	assert(r <= PGSIZE);
  801502:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801507:	7e 16                	jle    80151f <devfile_read+0x65>
  801509:	68 73 23 80 00       	push   $0x802373
  80150e:	68 53 23 80 00       	push   $0x802353
  801513:	6a 7e                	push   $0x7e
  801515:	68 68 23 80 00       	push   $0x802368
  80151a:	e8 19 ec ff ff       	call   800138 <_panic>
	memmove(buf, &fsipcbuf, r);
  80151f:	83 ec 04             	sub    $0x4,%esp
  801522:	50                   	push   %eax
  801523:	68 00 50 80 00       	push   $0x805000
  801528:	ff 75 0c             	pushl  0xc(%ebp)
  80152b:	e8 57 f4 ff ff       	call   800987 <memmove>
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
  801548:	e8 27 f2 ff ff       	call   800774 <strlen>
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
  801575:	e8 4c f2 ff ff       	call   8007c6 <strcpy>
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

008015cc <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8015cc:	55                   	push   %ebp
  8015cd:	89 e5                	mov    %esp,%ebp
  8015cf:	56                   	push   %esi
  8015d0:	53                   	push   %ebx
  8015d1:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8015d4:	83 ec 0c             	sub    $0xc,%esp
  8015d7:	ff 75 08             	pushl  0x8(%ebp)
  8015da:	e8 4d f8 ff ff       	call   800e2c <fd2data>
  8015df:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  8015e1:	83 c4 08             	add    $0x8,%esp
  8015e4:	68 7f 23 80 00       	push   $0x80237f
  8015e9:	56                   	push   %esi
  8015ea:	e8 d7 f1 ff ff       	call   8007c6 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8015ef:	8b 43 04             	mov    0x4(%ebx),%eax
  8015f2:	2b 03                	sub    (%ebx),%eax
  8015f4:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  8015fa:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  801601:	00 00 00 
	stat->st_dev = &devpipe;
  801604:	c7 86 88 00 00 00 20 	movl   $0x803020,0x88(%esi)
  80160b:	30 80 00 
	return 0;
}
  80160e:	b8 00 00 00 00       	mov    $0x0,%eax
  801613:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801616:	5b                   	pop    %ebx
  801617:	5e                   	pop    %esi
  801618:	c9                   	leave  
  801619:	c3                   	ret    

0080161a <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  80161a:	55                   	push   %ebp
  80161b:	89 e5                	mov    %esp,%ebp
  80161d:	53                   	push   %ebx
  80161e:	83 ec 0c             	sub    $0xc,%esp
  801621:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801624:	53                   	push   %ebx
  801625:	6a 00                	push   $0x0
  801627:	e8 66 f6 ff ff       	call   800c92 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  80162c:	89 1c 24             	mov    %ebx,(%esp)
  80162f:	e8 f8 f7 ff ff       	call   800e2c <fd2data>
  801634:	83 c4 08             	add    $0x8,%esp
  801637:	50                   	push   %eax
  801638:	6a 00                	push   $0x0
  80163a:	e8 53 f6 ff ff       	call   800c92 <sys_page_unmap>
}
  80163f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801642:	c9                   	leave  
  801643:	c3                   	ret    

00801644 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801644:	55                   	push   %ebp
  801645:	89 e5                	mov    %esp,%ebp
  801647:	57                   	push   %edi
  801648:	56                   	push   %esi
  801649:	53                   	push   %ebx
  80164a:	83 ec 1c             	sub    $0x1c,%esp
  80164d:	89 c7                	mov    %eax,%edi
  80164f:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801652:	a1 04 40 80 00       	mov    0x804004,%eax
  801657:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  80165a:	83 ec 0c             	sub    $0xc,%esp
  80165d:	57                   	push   %edi
  80165e:	e8 95 05 00 00       	call   801bf8 <pageref>
  801663:	89 c6                	mov    %eax,%esi
  801665:	83 c4 04             	add    $0x4,%esp
  801668:	ff 75 e4             	pushl  -0x1c(%ebp)
  80166b:	e8 88 05 00 00       	call   801bf8 <pageref>
  801670:	83 c4 10             	add    $0x10,%esp
  801673:	39 c6                	cmp    %eax,%esi
  801675:	0f 94 c0             	sete   %al
  801678:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  80167b:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801681:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801684:	39 cb                	cmp    %ecx,%ebx
  801686:	75 08                	jne    801690 <_pipeisclosed+0x4c>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  801688:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80168b:	5b                   	pop    %ebx
  80168c:	5e                   	pop    %esi
  80168d:	5f                   	pop    %edi
  80168e:	c9                   	leave  
  80168f:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  801690:	83 f8 01             	cmp    $0x1,%eax
  801693:	75 bd                	jne    801652 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801695:	8b 42 58             	mov    0x58(%edx),%eax
  801698:	6a 01                	push   $0x1
  80169a:	50                   	push   %eax
  80169b:	53                   	push   %ebx
  80169c:	68 86 23 80 00       	push   $0x802386
  8016a1:	e8 6a eb ff ff       	call   800210 <cprintf>
  8016a6:	83 c4 10             	add    $0x10,%esp
  8016a9:	eb a7                	jmp    801652 <_pipeisclosed+0xe>

008016ab <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8016ab:	55                   	push   %ebp
  8016ac:	89 e5                	mov    %esp,%ebp
  8016ae:	57                   	push   %edi
  8016af:	56                   	push   %esi
  8016b0:	53                   	push   %ebx
  8016b1:	83 ec 28             	sub    $0x28,%esp
  8016b4:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  8016b7:	56                   	push   %esi
  8016b8:	e8 6f f7 ff ff       	call   800e2c <fd2data>
  8016bd:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8016bf:	83 c4 10             	add    $0x10,%esp
  8016c2:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8016c6:	75 4a                	jne    801712 <devpipe_write+0x67>
  8016c8:	bf 00 00 00 00       	mov    $0x0,%edi
  8016cd:	eb 56                	jmp    801725 <devpipe_write+0x7a>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  8016cf:	89 da                	mov    %ebx,%edx
  8016d1:	89 f0                	mov    %esi,%eax
  8016d3:	e8 6c ff ff ff       	call   801644 <_pipeisclosed>
  8016d8:	85 c0                	test   %eax,%eax
  8016da:	75 4d                	jne    801729 <devpipe_write+0x7e>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  8016dc:	e8 40 f5 ff ff       	call   800c21 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8016e1:	8b 43 04             	mov    0x4(%ebx),%eax
  8016e4:	8b 13                	mov    (%ebx),%edx
  8016e6:	83 c2 20             	add    $0x20,%edx
  8016e9:	39 d0                	cmp    %edx,%eax
  8016eb:	73 e2                	jae    8016cf <devpipe_write+0x24>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  8016ed:	89 c2                	mov    %eax,%edx
  8016ef:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  8016f5:	79 05                	jns    8016fc <devpipe_write+0x51>
  8016f7:	4a                   	dec    %edx
  8016f8:	83 ca e0             	or     $0xffffffe0,%edx
  8016fb:	42                   	inc    %edx
  8016fc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8016ff:	8a 0c 39             	mov    (%ecx,%edi,1),%cl
  801702:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801706:	40                   	inc    %eax
  801707:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80170a:	47                   	inc    %edi
  80170b:	39 7d 10             	cmp    %edi,0x10(%ebp)
  80170e:	77 07                	ja     801717 <devpipe_write+0x6c>
  801710:	eb 13                	jmp    801725 <devpipe_write+0x7a>
  801712:	bf 00 00 00 00       	mov    $0x0,%edi
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801717:	8b 43 04             	mov    0x4(%ebx),%eax
  80171a:	8b 13                	mov    (%ebx),%edx
  80171c:	83 c2 20             	add    $0x20,%edx
  80171f:	39 d0                	cmp    %edx,%eax
  801721:	73 ac                	jae    8016cf <devpipe_write+0x24>
  801723:	eb c8                	jmp    8016ed <devpipe_write+0x42>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801725:	89 f8                	mov    %edi,%eax
  801727:	eb 05                	jmp    80172e <devpipe_write+0x83>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801729:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  80172e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801731:	5b                   	pop    %ebx
  801732:	5e                   	pop    %esi
  801733:	5f                   	pop    %edi
  801734:	c9                   	leave  
  801735:	c3                   	ret    

00801736 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801736:	55                   	push   %ebp
  801737:	89 e5                	mov    %esp,%ebp
  801739:	57                   	push   %edi
  80173a:	56                   	push   %esi
  80173b:	53                   	push   %ebx
  80173c:	83 ec 18             	sub    $0x18,%esp
  80173f:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801742:	57                   	push   %edi
  801743:	e8 e4 f6 ff ff       	call   800e2c <fd2data>
  801748:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80174a:	83 c4 10             	add    $0x10,%esp
  80174d:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801751:	75 44                	jne    801797 <devpipe_read+0x61>
  801753:	be 00 00 00 00       	mov    $0x0,%esi
  801758:	eb 4f                	jmp    8017a9 <devpipe_read+0x73>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
				return i;
  80175a:	89 f0                	mov    %esi,%eax
  80175c:	eb 54                	jmp    8017b2 <devpipe_read+0x7c>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  80175e:	89 da                	mov    %ebx,%edx
  801760:	89 f8                	mov    %edi,%eax
  801762:	e8 dd fe ff ff       	call   801644 <_pipeisclosed>
  801767:	85 c0                	test   %eax,%eax
  801769:	75 42                	jne    8017ad <devpipe_read+0x77>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  80176b:	e8 b1 f4 ff ff       	call   800c21 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801770:	8b 03                	mov    (%ebx),%eax
  801772:	3b 43 04             	cmp    0x4(%ebx),%eax
  801775:	74 e7                	je     80175e <devpipe_read+0x28>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801777:	25 1f 00 00 80       	and    $0x8000001f,%eax
  80177c:	79 05                	jns    801783 <devpipe_read+0x4d>
  80177e:	48                   	dec    %eax
  80177f:	83 c8 e0             	or     $0xffffffe0,%eax
  801782:	40                   	inc    %eax
  801783:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  801787:	8b 55 0c             	mov    0xc(%ebp),%edx
  80178a:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  80178d:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80178f:	46                   	inc    %esi
  801790:	39 75 10             	cmp    %esi,0x10(%ebp)
  801793:	77 07                	ja     80179c <devpipe_read+0x66>
  801795:	eb 12                	jmp    8017a9 <devpipe_read+0x73>
  801797:	be 00 00 00 00       	mov    $0x0,%esi
		while (p->p_rpos == p->p_wpos) {
  80179c:	8b 03                	mov    (%ebx),%eax
  80179e:	3b 43 04             	cmp    0x4(%ebx),%eax
  8017a1:	75 d4                	jne    801777 <devpipe_read+0x41>
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  8017a3:	85 f6                	test   %esi,%esi
  8017a5:	75 b3                	jne    80175a <devpipe_read+0x24>
  8017a7:	eb b5                	jmp    80175e <devpipe_read+0x28>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  8017a9:	89 f0                	mov    %esi,%eax
  8017ab:	eb 05                	jmp    8017b2 <devpipe_read+0x7c>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8017ad:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  8017b2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8017b5:	5b                   	pop    %ebx
  8017b6:	5e                   	pop    %esi
  8017b7:	5f                   	pop    %edi
  8017b8:	c9                   	leave  
  8017b9:	c3                   	ret    

008017ba <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  8017ba:	55                   	push   %ebp
  8017bb:	89 e5                	mov    %esp,%ebp
  8017bd:	57                   	push   %edi
  8017be:	56                   	push   %esi
  8017bf:	53                   	push   %ebx
  8017c0:	83 ec 28             	sub    $0x28,%esp
  8017c3:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  8017c6:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8017c9:	50                   	push   %eax
  8017ca:	e8 75 f6 ff ff       	call   800e44 <fd_alloc>
  8017cf:	89 c3                	mov    %eax,%ebx
  8017d1:	83 c4 10             	add    $0x10,%esp
  8017d4:	85 c0                	test   %eax,%eax
  8017d6:	0f 88 24 01 00 00    	js     801900 <pipe+0x146>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8017dc:	83 ec 04             	sub    $0x4,%esp
  8017df:	68 07 04 00 00       	push   $0x407
  8017e4:	ff 75 e4             	pushl  -0x1c(%ebp)
  8017e7:	6a 00                	push   $0x0
  8017e9:	e8 5a f4 ff ff       	call   800c48 <sys_page_alloc>
  8017ee:	89 c3                	mov    %eax,%ebx
  8017f0:	83 c4 10             	add    $0x10,%esp
  8017f3:	85 c0                	test   %eax,%eax
  8017f5:	0f 88 05 01 00 00    	js     801900 <pipe+0x146>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  8017fb:	83 ec 0c             	sub    $0xc,%esp
  8017fe:	8d 45 e0             	lea    -0x20(%ebp),%eax
  801801:	50                   	push   %eax
  801802:	e8 3d f6 ff ff       	call   800e44 <fd_alloc>
  801807:	89 c3                	mov    %eax,%ebx
  801809:	83 c4 10             	add    $0x10,%esp
  80180c:	85 c0                	test   %eax,%eax
  80180e:	0f 88 dc 00 00 00    	js     8018f0 <pipe+0x136>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801814:	83 ec 04             	sub    $0x4,%esp
  801817:	68 07 04 00 00       	push   $0x407
  80181c:	ff 75 e0             	pushl  -0x20(%ebp)
  80181f:	6a 00                	push   $0x0
  801821:	e8 22 f4 ff ff       	call   800c48 <sys_page_alloc>
  801826:	89 c3                	mov    %eax,%ebx
  801828:	83 c4 10             	add    $0x10,%esp
  80182b:	85 c0                	test   %eax,%eax
  80182d:	0f 88 bd 00 00 00    	js     8018f0 <pipe+0x136>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801833:	83 ec 0c             	sub    $0xc,%esp
  801836:	ff 75 e4             	pushl  -0x1c(%ebp)
  801839:	e8 ee f5 ff ff       	call   800e2c <fd2data>
  80183e:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801840:	83 c4 0c             	add    $0xc,%esp
  801843:	68 07 04 00 00       	push   $0x407
  801848:	50                   	push   %eax
  801849:	6a 00                	push   $0x0
  80184b:	e8 f8 f3 ff ff       	call   800c48 <sys_page_alloc>
  801850:	89 c3                	mov    %eax,%ebx
  801852:	83 c4 10             	add    $0x10,%esp
  801855:	85 c0                	test   %eax,%eax
  801857:	0f 88 83 00 00 00    	js     8018e0 <pipe+0x126>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80185d:	83 ec 0c             	sub    $0xc,%esp
  801860:	ff 75 e0             	pushl  -0x20(%ebp)
  801863:	e8 c4 f5 ff ff       	call   800e2c <fd2data>
  801868:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  80186f:	50                   	push   %eax
  801870:	6a 00                	push   $0x0
  801872:	56                   	push   %esi
  801873:	6a 00                	push   $0x0
  801875:	e8 f2 f3 ff ff       	call   800c6c <sys_page_map>
  80187a:	89 c3                	mov    %eax,%ebx
  80187c:	83 c4 20             	add    $0x20,%esp
  80187f:	85 c0                	test   %eax,%eax
  801881:	78 4f                	js     8018d2 <pipe+0x118>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801883:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801889:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80188c:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  80188e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801891:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801898:	8b 15 20 30 80 00    	mov    0x803020,%edx
  80189e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8018a1:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8018a3:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8018a6:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  8018ad:	83 ec 0c             	sub    $0xc,%esp
  8018b0:	ff 75 e4             	pushl  -0x1c(%ebp)
  8018b3:	e8 64 f5 ff ff       	call   800e1c <fd2num>
  8018b8:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  8018ba:	83 c4 04             	add    $0x4,%esp
  8018bd:	ff 75 e0             	pushl  -0x20(%ebp)
  8018c0:	e8 57 f5 ff ff       	call   800e1c <fd2num>
  8018c5:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  8018c8:	83 c4 10             	add    $0x10,%esp
  8018cb:	bb 00 00 00 00       	mov    $0x0,%ebx
  8018d0:	eb 2e                	jmp    801900 <pipe+0x146>

    err3:
	sys_page_unmap(0, va);
  8018d2:	83 ec 08             	sub    $0x8,%esp
  8018d5:	56                   	push   %esi
  8018d6:	6a 00                	push   $0x0
  8018d8:	e8 b5 f3 ff ff       	call   800c92 <sys_page_unmap>
  8018dd:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  8018e0:	83 ec 08             	sub    $0x8,%esp
  8018e3:	ff 75 e0             	pushl  -0x20(%ebp)
  8018e6:	6a 00                	push   $0x0
  8018e8:	e8 a5 f3 ff ff       	call   800c92 <sys_page_unmap>
  8018ed:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  8018f0:	83 ec 08             	sub    $0x8,%esp
  8018f3:	ff 75 e4             	pushl  -0x1c(%ebp)
  8018f6:	6a 00                	push   $0x0
  8018f8:	e8 95 f3 ff ff       	call   800c92 <sys_page_unmap>
  8018fd:	83 c4 10             	add    $0x10,%esp
    err:
	return r;
}
  801900:	89 d8                	mov    %ebx,%eax
  801902:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801905:	5b                   	pop    %ebx
  801906:	5e                   	pop    %esi
  801907:	5f                   	pop    %edi
  801908:	c9                   	leave  
  801909:	c3                   	ret    

0080190a <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  80190a:	55                   	push   %ebp
  80190b:	89 e5                	mov    %esp,%ebp
  80190d:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801910:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801913:	50                   	push   %eax
  801914:	ff 75 08             	pushl  0x8(%ebp)
  801917:	e8 9b f5 ff ff       	call   800eb7 <fd_lookup>
  80191c:	83 c4 10             	add    $0x10,%esp
  80191f:	85 c0                	test   %eax,%eax
  801921:	78 18                	js     80193b <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801923:	83 ec 0c             	sub    $0xc,%esp
  801926:	ff 75 f4             	pushl  -0xc(%ebp)
  801929:	e8 fe f4 ff ff       	call   800e2c <fd2data>
	return _pipeisclosed(fd, p);
  80192e:	89 c2                	mov    %eax,%edx
  801930:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801933:	e8 0c fd ff ff       	call   801644 <_pipeisclosed>
  801938:	83 c4 10             	add    $0x10,%esp
}
  80193b:	c9                   	leave  
  80193c:	c3                   	ret    
  80193d:	00 00                	add    %al,(%eax)
	...

00801940 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801940:	55                   	push   %ebp
  801941:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801943:	b8 00 00 00 00       	mov    $0x0,%eax
  801948:	c9                   	leave  
  801949:	c3                   	ret    

0080194a <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80194a:	55                   	push   %ebp
  80194b:	89 e5                	mov    %esp,%ebp
  80194d:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801950:	68 9e 23 80 00       	push   $0x80239e
  801955:	ff 75 0c             	pushl  0xc(%ebp)
  801958:	e8 69 ee ff ff       	call   8007c6 <strcpy>
	return 0;
}
  80195d:	b8 00 00 00 00       	mov    $0x0,%eax
  801962:	c9                   	leave  
  801963:	c3                   	ret    

00801964 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801964:	55                   	push   %ebp
  801965:	89 e5                	mov    %esp,%ebp
  801967:	57                   	push   %edi
  801968:	56                   	push   %esi
  801969:	53                   	push   %ebx
  80196a:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801970:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801974:	74 45                	je     8019bb <devcons_write+0x57>
  801976:	b8 00 00 00 00       	mov    $0x0,%eax
  80197b:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801980:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801986:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801989:	29 c3                	sub    %eax,%ebx
		if (m > sizeof(buf) - 1)
  80198b:	83 fb 7f             	cmp    $0x7f,%ebx
  80198e:	76 05                	jbe    801995 <devcons_write+0x31>
			m = sizeof(buf) - 1;
  801990:	bb 7f 00 00 00       	mov    $0x7f,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  801995:	83 ec 04             	sub    $0x4,%esp
  801998:	53                   	push   %ebx
  801999:	03 45 0c             	add    0xc(%ebp),%eax
  80199c:	50                   	push   %eax
  80199d:	57                   	push   %edi
  80199e:	e8 e4 ef ff ff       	call   800987 <memmove>
		sys_cputs(buf, m);
  8019a3:	83 c4 08             	add    $0x8,%esp
  8019a6:	53                   	push   %ebx
  8019a7:	57                   	push   %edi
  8019a8:	e8 e4 f1 ff ff       	call   800b91 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8019ad:	01 de                	add    %ebx,%esi
  8019af:	89 f0                	mov    %esi,%eax
  8019b1:	83 c4 10             	add    $0x10,%esp
  8019b4:	3b 75 10             	cmp    0x10(%ebp),%esi
  8019b7:	72 cd                	jb     801986 <devcons_write+0x22>
  8019b9:	eb 05                	jmp    8019c0 <devcons_write+0x5c>
  8019bb:	be 00 00 00 00       	mov    $0x0,%esi
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8019c0:	89 f0                	mov    %esi,%eax
  8019c2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8019c5:	5b                   	pop    %ebx
  8019c6:	5e                   	pop    %esi
  8019c7:	5f                   	pop    %edi
  8019c8:	c9                   	leave  
  8019c9:	c3                   	ret    

008019ca <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8019ca:	55                   	push   %ebp
  8019cb:	89 e5                	mov    %esp,%ebp
  8019cd:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  8019d0:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8019d4:	75 07                	jne    8019dd <devcons_read+0x13>
  8019d6:	eb 25                	jmp    8019fd <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8019d8:	e8 44 f2 ff ff       	call   800c21 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8019dd:	e8 d5 f1 ff ff       	call   800bb7 <sys_cgetc>
  8019e2:	85 c0                	test   %eax,%eax
  8019e4:	74 f2                	je     8019d8 <devcons_read+0xe>
  8019e6:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  8019e8:	85 c0                	test   %eax,%eax
  8019ea:	78 1d                	js     801a09 <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8019ec:	83 f8 04             	cmp    $0x4,%eax
  8019ef:	74 13                	je     801a04 <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  8019f1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019f4:	88 10                	mov    %dl,(%eax)
	return 1;
  8019f6:	b8 01 00 00 00       	mov    $0x1,%eax
  8019fb:	eb 0c                	jmp    801a09 <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  8019fd:	b8 00 00 00 00       	mov    $0x0,%eax
  801a02:	eb 05                	jmp    801a09 <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801a04:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801a09:	c9                   	leave  
  801a0a:	c3                   	ret    

00801a0b <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801a0b:	55                   	push   %ebp
  801a0c:	89 e5                	mov    %esp,%ebp
  801a0e:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801a11:	8b 45 08             	mov    0x8(%ebp),%eax
  801a14:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801a17:	6a 01                	push   $0x1
  801a19:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801a1c:	50                   	push   %eax
  801a1d:	e8 6f f1 ff ff       	call   800b91 <sys_cputs>
  801a22:	83 c4 10             	add    $0x10,%esp
}
  801a25:	c9                   	leave  
  801a26:	c3                   	ret    

00801a27 <getchar>:

int
getchar(void)
{
  801a27:	55                   	push   %ebp
  801a28:	89 e5                	mov    %esp,%ebp
  801a2a:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801a2d:	6a 01                	push   $0x1
  801a2f:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801a32:	50                   	push   %eax
  801a33:	6a 00                	push   $0x0
  801a35:	e8 fe f6 ff ff       	call   801138 <read>
	if (r < 0)
  801a3a:	83 c4 10             	add    $0x10,%esp
  801a3d:	85 c0                	test   %eax,%eax
  801a3f:	78 0f                	js     801a50 <getchar+0x29>
		return r;
	if (r < 1)
  801a41:	85 c0                	test   %eax,%eax
  801a43:	7e 06                	jle    801a4b <getchar+0x24>
		return -E_EOF;
	return c;
  801a45:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801a49:	eb 05                	jmp    801a50 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801a4b:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801a50:	c9                   	leave  
  801a51:	c3                   	ret    

00801a52 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801a52:	55                   	push   %ebp
  801a53:	89 e5                	mov    %esp,%ebp
  801a55:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801a58:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a5b:	50                   	push   %eax
  801a5c:	ff 75 08             	pushl  0x8(%ebp)
  801a5f:	e8 53 f4 ff ff       	call   800eb7 <fd_lookup>
  801a64:	83 c4 10             	add    $0x10,%esp
  801a67:	85 c0                	test   %eax,%eax
  801a69:	78 11                	js     801a7c <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801a6b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a6e:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801a74:	39 10                	cmp    %edx,(%eax)
  801a76:	0f 94 c0             	sete   %al
  801a79:	0f b6 c0             	movzbl %al,%eax
}
  801a7c:	c9                   	leave  
  801a7d:	c3                   	ret    

00801a7e <opencons>:

int
opencons(void)
{
  801a7e:	55                   	push   %ebp
  801a7f:	89 e5                	mov    %esp,%ebp
  801a81:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801a84:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a87:	50                   	push   %eax
  801a88:	e8 b7 f3 ff ff       	call   800e44 <fd_alloc>
  801a8d:	83 c4 10             	add    $0x10,%esp
  801a90:	85 c0                	test   %eax,%eax
  801a92:	78 3a                	js     801ace <opencons+0x50>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801a94:	83 ec 04             	sub    $0x4,%esp
  801a97:	68 07 04 00 00       	push   $0x407
  801a9c:	ff 75 f4             	pushl  -0xc(%ebp)
  801a9f:	6a 00                	push   $0x0
  801aa1:	e8 a2 f1 ff ff       	call   800c48 <sys_page_alloc>
  801aa6:	83 c4 10             	add    $0x10,%esp
  801aa9:	85 c0                	test   %eax,%eax
  801aab:	78 21                	js     801ace <opencons+0x50>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801aad:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801ab3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ab6:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801ab8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801abb:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801ac2:	83 ec 0c             	sub    $0xc,%esp
  801ac5:	50                   	push   %eax
  801ac6:	e8 51 f3 ff ff       	call   800e1c <fd2num>
  801acb:	83 c4 10             	add    $0x10,%esp
}
  801ace:	c9                   	leave  
  801acf:	c3                   	ret    

00801ad0 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801ad0:	55                   	push   %ebp
  801ad1:	89 e5                	mov    %esp,%ebp
  801ad3:	56                   	push   %esi
  801ad4:	53                   	push   %ebx
  801ad5:	8b 75 08             	mov    0x8(%ebp),%esi
  801ad8:	8b 45 0c             	mov    0xc(%ebp),%eax
  801adb:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// cprintf("0x%x 0x%x 0x%x\n", (uint32_t)from_env_store, (uint32_t)pg, (uint32_t)perm_store);
	int r;
	if (pg != NULL) {
  801ade:	85 c0                	test   %eax,%eax
  801ae0:	74 0e                	je     801af0 <ipc_recv+0x20>
		r = sys_ipc_recv(pg);
  801ae2:	83 ec 0c             	sub    $0xc,%esp
  801ae5:	50                   	push   %eax
  801ae6:	e8 58 f2 ff ff       	call   800d43 <sys_ipc_recv>
  801aeb:	83 c4 10             	add    $0x10,%esp
  801aee:	eb 10                	jmp    801b00 <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv((void *)UTOP);
  801af0:	83 ec 0c             	sub    $0xc,%esp
  801af3:	68 00 00 c0 ee       	push   $0xeec00000
  801af8:	e8 46 f2 ff ff       	call   800d43 <sys_ipc_recv>
  801afd:	83 c4 10             	add    $0x10,%esp
	}

	if (r == 0) {
  801b00:	85 c0                	test   %eax,%eax
  801b02:	75 26                	jne    801b2a <ipc_recv+0x5a>
		if (from_env_store != NULL) *from_env_store = thisenv->env_ipc_from;
  801b04:	85 f6                	test   %esi,%esi
  801b06:	74 0a                	je     801b12 <ipc_recv+0x42>
  801b08:	a1 04 40 80 00       	mov    0x804004,%eax
  801b0d:	8b 40 74             	mov    0x74(%eax),%eax
  801b10:	89 06                	mov    %eax,(%esi)
		if (perm_store != NULL) *perm_store = thisenv->env_ipc_perm;
  801b12:	85 db                	test   %ebx,%ebx
  801b14:	74 0a                	je     801b20 <ipc_recv+0x50>
  801b16:	a1 04 40 80 00       	mov    0x804004,%eax
  801b1b:	8b 40 78             	mov    0x78(%eax),%eax
  801b1e:	89 03                	mov    %eax,(%ebx)
		return thisenv->env_ipc_value;
  801b20:	a1 04 40 80 00       	mov    0x804004,%eax
  801b25:	8b 40 70             	mov    0x70(%eax),%eax
  801b28:	eb 14                	jmp    801b3e <ipc_recv+0x6e>
	} else {
		// fails;
		if (from_env_store != NULL) *from_env_store = 0;
  801b2a:	85 f6                	test   %esi,%esi
  801b2c:	74 06                	je     801b34 <ipc_recv+0x64>
  801b2e:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if (perm_store != NULL) *perm_store = 0;
  801b34:	85 db                	test   %ebx,%ebx
  801b36:	74 06                	je     801b3e <ipc_recv+0x6e>
  801b38:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		return r;
	}
}
  801b3e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b41:	5b                   	pop    %ebx
  801b42:	5e                   	pop    %esi
  801b43:	c9                   	leave  
  801b44:	c3                   	ret    

00801b45 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801b45:	55                   	push   %ebp
  801b46:	89 e5                	mov    %esp,%ebp
  801b48:	57                   	push   %edi
  801b49:	56                   	push   %esi
  801b4a:	53                   	push   %ebx
  801b4b:	83 ec 0c             	sub    $0xc,%esp
  801b4e:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801b51:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801b54:	8b 75 14             	mov    0x14(%ebp),%esi
	// LAB 4: Your code here.
	// int sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
	int r;
	if (pg == NULL) pg = (void *)UTOP;
  801b57:	85 db                	test   %ebx,%ebx
  801b59:	75 25                	jne    801b80 <ipc_send+0x3b>
  801b5b:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
  801b60:	eb 1e                	jmp    801b80 <ipc_send+0x3b>
	
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) != 0) {
		if (r == -E_IPC_NOT_RECV) {
  801b62:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801b65:	75 07                	jne    801b6e <ipc_send+0x29>
			// cprintf("Try Again and Again....\n");
			sys_yield();
  801b67:	e8 b5 f0 ff ff       	call   800c21 <sys_yield>
  801b6c:	eb 12                	jmp    801b80 <ipc_send+0x3b>
		} else {
			panic("ipc_send error %e\n", r);
  801b6e:	50                   	push   %eax
  801b6f:	68 aa 23 80 00       	push   $0x8023aa
  801b74:	6a 43                	push   $0x43
  801b76:	68 bd 23 80 00       	push   $0x8023bd
  801b7b:	e8 b8 e5 ff ff       	call   800138 <_panic>
	// LAB 4: Your code here.
	// int sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
	int r;
	if (pg == NULL) pg = (void *)UTOP;
	
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) != 0) {
  801b80:	56                   	push   %esi
  801b81:	53                   	push   %ebx
  801b82:	57                   	push   %edi
  801b83:	ff 75 08             	pushl  0x8(%ebp)
  801b86:	e8 93 f1 ff ff       	call   800d1e <sys_ipc_try_send>
  801b8b:	83 c4 10             	add    $0x10,%esp
  801b8e:	85 c0                	test   %eax,%eax
  801b90:	75 d0                	jne    801b62 <ipc_send+0x1d>
		} else {
			panic("ipc_send error %e\n", r);
		}
	}
	return;
}
  801b92:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b95:	5b                   	pop    %ebx
  801b96:	5e                   	pop    %esi
  801b97:	5f                   	pop    %edi
  801b98:	c9                   	leave  
  801b99:	c3                   	ret    

00801b9a <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801b9a:	55                   	push   %ebp
  801b9b:	89 e5                	mov    %esp,%ebp
  801b9d:	53                   	push   %ebx
  801b9e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  801ba1:	39 1d 50 00 c0 ee    	cmp    %ebx,0xeec00050
  801ba7:	74 22                	je     801bcb <ipc_find_env+0x31>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801ba9:	b8 01 00 00 00       	mov    $0x1,%eax
		if (envs[i].env_type == type)
  801bae:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  801bb5:	89 c2                	mov    %eax,%edx
  801bb7:	c1 e2 07             	shl    $0x7,%edx
  801bba:	29 ca                	sub    %ecx,%edx
  801bbc:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801bc2:	8b 52 50             	mov    0x50(%edx),%edx
  801bc5:	39 da                	cmp    %ebx,%edx
  801bc7:	75 1d                	jne    801be6 <ipc_find_env+0x4c>
  801bc9:	eb 05                	jmp    801bd0 <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801bcb:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
			return envs[i].env_id;
  801bd0:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  801bd7:	c1 e0 07             	shl    $0x7,%eax
  801bda:	29 d0                	sub    %edx,%eax
  801bdc:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  801be1:	8b 40 40             	mov    0x40(%eax),%eax
  801be4:	eb 0c                	jmp    801bf2 <ipc_find_env+0x58>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801be6:	40                   	inc    %eax
  801be7:	3d 00 04 00 00       	cmp    $0x400,%eax
  801bec:	75 c0                	jne    801bae <ipc_find_env+0x14>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801bee:	66 b8 00 00          	mov    $0x0,%ax
}
  801bf2:	5b                   	pop    %ebx
  801bf3:	c9                   	leave  
  801bf4:	c3                   	ret    
  801bf5:	00 00                	add    %al,(%eax)
	...

00801bf8 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801bf8:	55                   	push   %ebp
  801bf9:	89 e5                	mov    %esp,%ebp
  801bfb:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801bfe:	89 c2                	mov    %eax,%edx
  801c00:	c1 ea 16             	shr    $0x16,%edx
  801c03:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801c0a:	f6 c2 01             	test   $0x1,%dl
  801c0d:	74 1e                	je     801c2d <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  801c0f:	c1 e8 0c             	shr    $0xc,%eax
  801c12:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801c19:	a8 01                	test   $0x1,%al
  801c1b:	74 17                	je     801c34 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801c1d:	c1 e8 0c             	shr    $0xc,%eax
  801c20:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  801c27:	ef 
  801c28:	0f b7 c0             	movzwl %ax,%eax
  801c2b:	eb 0c                	jmp    801c39 <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  801c2d:	b8 00 00 00 00       	mov    $0x0,%eax
  801c32:	eb 05                	jmp    801c39 <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  801c34:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  801c39:	c9                   	leave  
  801c3a:	c3                   	ret    
	...

00801c3c <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  801c3c:	55                   	push   %ebp
  801c3d:	89 e5                	mov    %esp,%ebp
  801c3f:	57                   	push   %edi
  801c40:	56                   	push   %esi
  801c41:	83 ec 10             	sub    $0x10,%esp
  801c44:	8b 7d 08             	mov    0x8(%ebp),%edi
  801c47:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  801c4a:	89 7d f0             	mov    %edi,-0x10(%ebp)
  801c4d:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  801c50:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  801c53:	8b 45 14             	mov    0x14(%ebp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  801c56:	85 c0                	test   %eax,%eax
  801c58:	75 2e                	jne    801c88 <__udivdi3+0x4c>
    {
      if (d0 > n1)
  801c5a:	39 f1                	cmp    %esi,%ecx
  801c5c:	77 5a                	ja     801cb8 <__udivdi3+0x7c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  801c5e:	85 c9                	test   %ecx,%ecx
  801c60:	75 0b                	jne    801c6d <__udivdi3+0x31>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  801c62:	b8 01 00 00 00       	mov    $0x1,%eax
  801c67:	31 d2                	xor    %edx,%edx
  801c69:	f7 f1                	div    %ecx
  801c6b:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  801c6d:	31 d2                	xor    %edx,%edx
  801c6f:	89 f0                	mov    %esi,%eax
  801c71:	f7 f1                	div    %ecx
  801c73:	89 c6                	mov    %eax,%esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801c75:	89 f8                	mov    %edi,%eax
  801c77:	f7 f1                	div    %ecx
  801c79:	89 c7                	mov    %eax,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801c7b:	89 f8                	mov    %edi,%eax
  801c7d:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801c7f:	83 c4 10             	add    $0x10,%esp
  801c82:	5e                   	pop    %esi
  801c83:	5f                   	pop    %edi
  801c84:	c9                   	leave  
  801c85:	c3                   	ret    
  801c86:	66 90                	xchg   %ax,%ax
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801c88:	39 f0                	cmp    %esi,%eax
  801c8a:	77 1c                	ja     801ca8 <__udivdi3+0x6c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  801c8c:	0f bd f8             	bsr    %eax,%edi
	  if (bm == 0)
  801c8f:	83 f7 1f             	xor    $0x1f,%edi
  801c92:	75 3c                	jne    801cd0 <__udivdi3+0x94>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801c94:	39 f0                	cmp    %esi,%eax
  801c96:	0f 82 90 00 00 00    	jb     801d2c <__udivdi3+0xf0>
  801c9c:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801c9f:	39 55 f4             	cmp    %edx,-0xc(%ebp)
  801ca2:	0f 86 84 00 00 00    	jbe    801d2c <__udivdi3+0xf0>
  801ca8:	31 f6                	xor    %esi,%esi
  801caa:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801cac:	89 f8                	mov    %edi,%eax
  801cae:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801cb0:	83 c4 10             	add    $0x10,%esp
  801cb3:	5e                   	pop    %esi
  801cb4:	5f                   	pop    %edi
  801cb5:	c9                   	leave  
  801cb6:	c3                   	ret    
  801cb7:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801cb8:	89 f2                	mov    %esi,%edx
  801cba:	89 f8                	mov    %edi,%eax
  801cbc:	f7 f1                	div    %ecx
  801cbe:	89 c7                	mov    %eax,%edi
  801cc0:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801cc2:	89 f8                	mov    %edi,%eax
  801cc4:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801cc6:	83 c4 10             	add    $0x10,%esp
  801cc9:	5e                   	pop    %esi
  801cca:	5f                   	pop    %edi
  801ccb:	c9                   	leave  
  801ccc:	c3                   	ret    
  801ccd:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  801cd0:	89 f9                	mov    %edi,%ecx
  801cd2:	d3 e0                	shl    %cl,%eax
  801cd4:	89 45 e8             	mov    %eax,-0x18(%ebp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  801cd7:	b8 20 00 00 00       	mov    $0x20,%eax
  801cdc:	29 f8                	sub    %edi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  801cde:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801ce1:	88 c1                	mov    %al,%cl
  801ce3:	d3 ea                	shr    %cl,%edx
  801ce5:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  801ce8:	09 ca                	or     %ecx,%edx
  801cea:	89 55 ec             	mov    %edx,-0x14(%ebp)
	      d0 = d0 << bm;
  801ced:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801cf0:	89 f9                	mov    %edi,%ecx
  801cf2:	d3 e2                	shl    %cl,%edx
  801cf4:	89 55 f4             	mov    %edx,-0xc(%ebp)
	      n2 = n1 >> b;
  801cf7:	89 f2                	mov    %esi,%edx
  801cf9:	88 c1                	mov    %al,%cl
  801cfb:	d3 ea                	shr    %cl,%edx
  801cfd:	89 55 e8             	mov    %edx,-0x18(%ebp)
	      n1 = (n1 << bm) | (n0 >> b);
  801d00:	89 f2                	mov    %esi,%edx
  801d02:	89 f9                	mov    %edi,%ecx
  801d04:	d3 e2                	shl    %cl,%edx
  801d06:	8b 75 f0             	mov    -0x10(%ebp),%esi
  801d09:	88 c1                	mov    %al,%cl
  801d0b:	d3 ee                	shr    %cl,%esi
  801d0d:	09 d6                	or     %edx,%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  801d0f:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  801d12:	89 f0                	mov    %esi,%eax
  801d14:	89 ca                	mov    %ecx,%edx
  801d16:	f7 75 ec             	divl   -0x14(%ebp)
  801d19:	89 d1                	mov    %edx,%ecx
  801d1b:	89 c6                	mov    %eax,%esi
	      umul_ppmm (m1, m0, q0, d0);
  801d1d:	f7 65 f4             	mull   -0xc(%ebp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801d20:	39 d1                	cmp    %edx,%ecx
  801d22:	72 28                	jb     801d4c <__udivdi3+0x110>
  801d24:	74 1a                	je     801d40 <__udivdi3+0x104>
  801d26:	89 f7                	mov    %esi,%edi
  801d28:	31 f6                	xor    %esi,%esi
  801d2a:	eb 80                	jmp    801cac <__udivdi3+0x70>
	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  801d2c:	31 f6                	xor    %esi,%esi
  801d2e:	bf 01 00 00 00       	mov    $0x1,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801d33:	89 f8                	mov    %edi,%eax
  801d35:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801d37:	83 c4 10             	add    $0x10,%esp
  801d3a:	5e                   	pop    %esi
  801d3b:	5f                   	pop    %edi
  801d3c:	c9                   	leave  
  801d3d:	c3                   	ret    
  801d3e:	66 90                	xchg   %ax,%ax

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  801d40:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801d43:	89 f9                	mov    %edi,%ecx
  801d45:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801d47:	39 c2                	cmp    %eax,%edx
  801d49:	73 db                	jae    801d26 <__udivdi3+0xea>
  801d4b:	90                   	nop
		{
		  q0--;
  801d4c:	8d 7e ff             	lea    -0x1(%esi),%edi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  801d4f:	31 f6                	xor    %esi,%esi
  801d51:	e9 56 ff ff ff       	jmp    801cac <__udivdi3+0x70>
	...

00801d58 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  801d58:	55                   	push   %ebp
  801d59:	89 e5                	mov    %esp,%ebp
  801d5b:	57                   	push   %edi
  801d5c:	56                   	push   %esi
  801d5d:	83 ec 20             	sub    $0x20,%esp
  801d60:	8b 45 08             	mov    0x8(%ebp),%eax
  801d63:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  801d66:	89 45 e8             	mov    %eax,-0x18(%ebp)
  801d69:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  801d6c:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  801d6f:	8b 7d 14             	mov    0x14(%ebp),%edi
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  801d72:	89 45 f0             	mov    %eax,-0x10(%ebp)
  n1 = nn.s.high;
  801d75:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  801d77:	85 ff                	test   %edi,%edi
  801d79:	75 15                	jne    801d90 <__umoddi3+0x38>
    {
      if (d0 > n1)
  801d7b:	39 f1                	cmp    %esi,%ecx
  801d7d:	0f 86 99 00 00 00    	jbe    801e1c <__umoddi3+0xc4>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801d83:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  801d85:	89 d0                	mov    %edx,%eax
  801d87:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801d89:	83 c4 20             	add    $0x20,%esp
  801d8c:	5e                   	pop    %esi
  801d8d:	5f                   	pop    %edi
  801d8e:	c9                   	leave  
  801d8f:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801d90:	39 f7                	cmp    %esi,%edi
  801d92:	0f 87 a4 00 00 00    	ja     801e3c <__umoddi3+0xe4>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  801d98:	0f bd c7             	bsr    %edi,%eax
	  if (bm == 0)
  801d9b:	83 f0 1f             	xor    $0x1f,%eax
  801d9e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801da1:	0f 84 a1 00 00 00    	je     801e48 <__umoddi3+0xf0>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  801da7:	89 f8                	mov    %edi,%eax
  801da9:	8a 4d ec             	mov    -0x14(%ebp),%cl
  801dac:	d3 e0                	shl    %cl,%eax
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  801dae:	bf 20 00 00 00       	mov    $0x20,%edi
  801db3:	2b 7d ec             	sub    -0x14(%ebp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  801db6:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801db9:	89 f9                	mov    %edi,%ecx
  801dbb:	d3 ea                	shr    %cl,%edx
  801dbd:	09 c2                	or     %eax,%edx
  801dbf:	89 55 f0             	mov    %edx,-0x10(%ebp)
	      d0 = d0 << bm;
  801dc2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801dc5:	8a 4d ec             	mov    -0x14(%ebp),%cl
  801dc8:	d3 e0                	shl    %cl,%eax
  801dca:	89 45 f4             	mov    %eax,-0xc(%ebp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  801dcd:	89 f2                	mov    %esi,%edx
  801dcf:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  801dd1:	8b 45 e8             	mov    -0x18(%ebp),%eax
  801dd4:	d3 e0                	shl    %cl,%eax
  801dd6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  801dd9:	8b 45 e8             	mov    -0x18(%ebp),%eax
  801ddc:	89 f9                	mov    %edi,%ecx
  801dde:	d3 e8                	shr    %cl,%eax
  801de0:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  801de2:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  801de4:	89 f2                	mov    %esi,%edx
  801de6:	f7 75 f0             	divl   -0x10(%ebp)
  801de9:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  801deb:	f7 65 f4             	mull   -0xc(%ebp)
  801dee:	89 55 e8             	mov    %edx,-0x18(%ebp)
  801df1:	89 c1                	mov    %eax,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801df3:	39 d6                	cmp    %edx,%esi
  801df5:	72 71                	jb     801e68 <__umoddi3+0x110>
  801df7:	74 7f                	je     801e78 <__umoddi3+0x120>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  801df9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801dfc:	29 c8                	sub    %ecx,%eax
  801dfe:	19 d6                	sbb    %edx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  801e00:	8a 4d ec             	mov    -0x14(%ebp),%cl
  801e03:	d3 e8                	shr    %cl,%eax
  801e05:	89 f2                	mov    %esi,%edx
  801e07:	89 f9                	mov    %edi,%ecx
  801e09:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  801e0b:	09 d0                	or     %edx,%eax
  801e0d:	89 f2                	mov    %esi,%edx
  801e0f:	8a 4d ec             	mov    -0x14(%ebp),%cl
  801e12:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801e14:	83 c4 20             	add    $0x20,%esp
  801e17:	5e                   	pop    %esi
  801e18:	5f                   	pop    %edi
  801e19:	c9                   	leave  
  801e1a:	c3                   	ret    
  801e1b:	90                   	nop
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  801e1c:	85 c9                	test   %ecx,%ecx
  801e1e:	75 0b                	jne    801e2b <__umoddi3+0xd3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  801e20:	b8 01 00 00 00       	mov    $0x1,%eax
  801e25:	31 d2                	xor    %edx,%edx
  801e27:	f7 f1                	div    %ecx
  801e29:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  801e2b:	89 f0                	mov    %esi,%eax
  801e2d:	31 d2                	xor    %edx,%edx
  801e2f:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801e31:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801e34:	f7 f1                	div    %ecx
  801e36:	e9 4a ff ff ff       	jmp    801d85 <__umoddi3+0x2d>
  801e3b:	90                   	nop
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  801e3c:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801e3e:	83 c4 20             	add    $0x20,%esp
  801e41:	5e                   	pop    %esi
  801e42:	5f                   	pop    %edi
  801e43:	c9                   	leave  
  801e44:	c3                   	ret    
  801e45:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801e48:	39 f7                	cmp    %esi,%edi
  801e4a:	72 05                	jb     801e51 <__umoddi3+0xf9>
  801e4c:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
  801e4f:	77 0c                	ja     801e5d <__umoddi3+0x105>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  801e51:	89 f2                	mov    %esi,%edx
  801e53:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801e56:	29 c8                	sub    %ecx,%eax
  801e58:	19 fa                	sbb    %edi,%edx
  801e5a:	89 45 f0             	mov    %eax,-0x10(%ebp)

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  801e5d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801e60:	83 c4 20             	add    $0x20,%esp
  801e63:	5e                   	pop    %esi
  801e64:	5f                   	pop    %edi
  801e65:	c9                   	leave  
  801e66:	c3                   	ret    
  801e67:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  801e68:	8b 55 e8             	mov    -0x18(%ebp),%edx
  801e6b:	89 c1                	mov    %eax,%ecx
  801e6d:	2b 4d f4             	sub    -0xc(%ebp),%ecx
  801e70:	1b 55 f0             	sbb    -0x10(%ebp),%edx
  801e73:	eb 84                	jmp    801df9 <__umoddi3+0xa1>
  801e75:	8d 76 00             	lea    0x0(%esi),%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801e78:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801e7b:	72 eb                	jb     801e68 <__umoddi3+0x110>
  801e7d:	89 f2                	mov    %esi,%edx
  801e7f:	e9 75 ff ff ff       	jmp    801df9 <__umoddi3+0xa1>