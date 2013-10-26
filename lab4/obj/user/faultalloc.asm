
obj/user/faultalloc:     file format elf32-i386


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
  800041:	68 40 10 80 00       	push   $0x801040
  800046:	e8 b5 01 00 00       	call   800200 <cprintf>
	if ((r = sys_page_alloc(0, ROUNDDOWN(addr, PGSIZE),
  80004b:	83 c4 0c             	add    $0xc,%esp
  80004e:	6a 07                	push   $0x7
  800050:	89 d8                	mov    %ebx,%eax
  800052:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800057:	50                   	push   %eax
  800058:	6a 00                	push   $0x0
  80005a:	e8 d9 0b 00 00       	call   800c38 <sys_page_alloc>
  80005f:	83 c4 10             	add    $0x10,%esp
  800062:	85 c0                	test   %eax,%eax
  800064:	79 16                	jns    80007c <handler+0x48>
				PTE_P|PTE_U|PTE_W)) < 0)
		panic("allocating at %x in page fault handler: %e", addr, r);
  800066:	83 ec 0c             	sub    $0xc,%esp
  800069:	50                   	push   %eax
  80006a:	53                   	push   %ebx
  80006b:	68 60 10 80 00       	push   $0x801060
  800070:	6a 0e                	push   $0xe
  800072:	68 4a 10 80 00       	push   $0x80104a
  800077:	e8 ac 00 00 00       	call   800128 <_panic>
	snprintf((char*) addr, 100, "this string was faulted in at %x", addr);
  80007c:	53                   	push   %ebx
  80007d:	68 8c 10 80 00       	push   $0x80108c
  800082:	6a 64                	push   $0x64
  800084:	53                   	push   %ebx
  800085:	e8 be 06 00 00       	call   800748 <snprintf>
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
  80009d:	e8 b6 0c 00 00       	call   800d58 <set_pgfault_handler>
	cprintf("%s\n", (char*)0xDeadBeef);
  8000a2:	83 c4 08             	add    $0x8,%esp
  8000a5:	68 ef be ad de       	push   $0xdeadbeef
  8000aa:	68 5c 10 80 00       	push   $0x80105c
  8000af:	e8 4c 01 00 00       	call   800200 <cprintf>
	cprintf("%s\n", (char*)0xCafeBffe);
  8000b4:	83 c4 08             	add    $0x8,%esp
  8000b7:	68 fe bf fe ca       	push   $0xcafebffe
  8000bc:	68 5c 10 80 00       	push   $0x80105c
  8000c1:	e8 3a 01 00 00       	call   800200 <cprintf>
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
  8000d7:	e8 11 0b 00 00       	call   800bed <sys_getenvid>
  8000dc:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000e1:	c1 e0 07             	shl    $0x7,%eax
  8000e4:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000e9:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000ee:	85 f6                	test   %esi,%esi
  8000f0:	7e 07                	jle    8000f9 <libmain+0x2d>
		binaryname = argv[0];
  8000f2:	8b 03                	mov    (%ebx),%eax
  8000f4:	a3 00 20 80 00       	mov    %eax,0x802000
	// call user main routine
	umain(argc, argv);
  8000f9:	83 ec 08             	sub    $0x8,%esp
  8000fc:	53                   	push   %ebx
  8000fd:	56                   	push   %esi
  8000fe:	e8 8f ff ff ff       	call   800092 <umain>

	// exit gracefully
	exit();
  800103:	e8 0c 00 00 00       	call   800114 <exit>
  800108:	83 c4 10             	add    $0x10,%esp
}
  80010b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80010e:	5b                   	pop    %ebx
  80010f:	5e                   	pop    %esi
  800110:	c9                   	leave  
  800111:	c3                   	ret    
	...

00800114 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800114:	55                   	push   %ebp
  800115:	89 e5                	mov    %esp,%ebp
  800117:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  80011a:	6a 00                	push   $0x0
  80011c:	e8 aa 0a 00 00       	call   800bcb <sys_env_destroy>
  800121:	83 c4 10             	add    $0x10,%esp
}
  800124:	c9                   	leave  
  800125:	c3                   	ret    
	...

00800128 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800128:	55                   	push   %ebp
  800129:	89 e5                	mov    %esp,%ebp
  80012b:	56                   	push   %esi
  80012c:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80012d:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800130:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  800136:	e8 b2 0a 00 00       	call   800bed <sys_getenvid>
  80013b:	83 ec 0c             	sub    $0xc,%esp
  80013e:	ff 75 0c             	pushl  0xc(%ebp)
  800141:	ff 75 08             	pushl  0x8(%ebp)
  800144:	53                   	push   %ebx
  800145:	50                   	push   %eax
  800146:	68 b8 10 80 00       	push   $0x8010b8
  80014b:	e8 b0 00 00 00       	call   800200 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800150:	83 c4 18             	add    $0x18,%esp
  800153:	56                   	push   %esi
  800154:	ff 75 10             	pushl  0x10(%ebp)
  800157:	e8 53 00 00 00       	call   8001af <vcprintf>
	cprintf("\n");
  80015c:	c7 04 24 68 13 80 00 	movl   $0x801368,(%esp)
  800163:	e8 98 00 00 00       	call   800200 <cprintf>
  800168:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80016b:	cc                   	int3   
  80016c:	eb fd                	jmp    80016b <_panic+0x43>
	...

00800170 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800170:	55                   	push   %ebp
  800171:	89 e5                	mov    %esp,%ebp
  800173:	53                   	push   %ebx
  800174:	83 ec 04             	sub    $0x4,%esp
  800177:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80017a:	8b 03                	mov    (%ebx),%eax
  80017c:	8b 55 08             	mov    0x8(%ebp),%edx
  80017f:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  800183:	40                   	inc    %eax
  800184:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  800186:	3d ff 00 00 00       	cmp    $0xff,%eax
  80018b:	75 1a                	jne    8001a7 <putch+0x37>
		sys_cputs(b->buf, b->idx);
  80018d:	83 ec 08             	sub    $0x8,%esp
  800190:	68 ff 00 00 00       	push   $0xff
  800195:	8d 43 08             	lea    0x8(%ebx),%eax
  800198:	50                   	push   %eax
  800199:	e8 e3 09 00 00       	call   800b81 <sys_cputs>
		b->idx = 0;
  80019e:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001a4:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8001a7:	ff 43 04             	incl   0x4(%ebx)
}
  8001aa:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001ad:	c9                   	leave  
  8001ae:	c3                   	ret    

008001af <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001af:	55                   	push   %ebp
  8001b0:	89 e5                	mov    %esp,%ebp
  8001b2:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001b8:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001bf:	00 00 00 
	b.cnt = 0;
  8001c2:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001c9:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001cc:	ff 75 0c             	pushl  0xc(%ebp)
  8001cf:	ff 75 08             	pushl  0x8(%ebp)
  8001d2:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001d8:	50                   	push   %eax
  8001d9:	68 70 01 80 00       	push   $0x800170
  8001de:	e8 82 01 00 00       	call   800365 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001e3:	83 c4 08             	add    $0x8,%esp
  8001e6:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8001ec:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001f2:	50                   	push   %eax
  8001f3:	e8 89 09 00 00       	call   800b81 <sys_cputs>

	return b.cnt;
}
  8001f8:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001fe:	c9                   	leave  
  8001ff:	c3                   	ret    

00800200 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800200:	55                   	push   %ebp
  800201:	89 e5                	mov    %esp,%ebp
  800203:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800206:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800209:	50                   	push   %eax
  80020a:	ff 75 08             	pushl  0x8(%ebp)
  80020d:	e8 9d ff ff ff       	call   8001af <vcprintf>
	va_end(ap);

	return cnt;
}
  800212:	c9                   	leave  
  800213:	c3                   	ret    

00800214 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800214:	55                   	push   %ebp
  800215:	89 e5                	mov    %esp,%ebp
  800217:	57                   	push   %edi
  800218:	56                   	push   %esi
  800219:	53                   	push   %ebx
  80021a:	83 ec 2c             	sub    $0x2c,%esp
  80021d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800220:	89 d6                	mov    %edx,%esi
  800222:	8b 45 08             	mov    0x8(%ebp),%eax
  800225:	8b 55 0c             	mov    0xc(%ebp),%edx
  800228:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80022b:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80022e:	8b 45 10             	mov    0x10(%ebp),%eax
  800231:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800234:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800237:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80023a:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  800241:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
  800244:	72 0c                	jb     800252 <printnum+0x3e>
  800246:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  800249:	76 07                	jbe    800252 <printnum+0x3e>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80024b:	4b                   	dec    %ebx
  80024c:	85 db                	test   %ebx,%ebx
  80024e:	7f 31                	jg     800281 <printnum+0x6d>
  800250:	eb 3f                	jmp    800291 <printnum+0x7d>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800252:	83 ec 0c             	sub    $0xc,%esp
  800255:	57                   	push   %edi
  800256:	4b                   	dec    %ebx
  800257:	53                   	push   %ebx
  800258:	50                   	push   %eax
  800259:	83 ec 08             	sub    $0x8,%esp
  80025c:	ff 75 d4             	pushl  -0x2c(%ebp)
  80025f:	ff 75 d0             	pushl  -0x30(%ebp)
  800262:	ff 75 dc             	pushl  -0x24(%ebp)
  800265:	ff 75 d8             	pushl  -0x28(%ebp)
  800268:	e8 7f 0b 00 00       	call   800dec <__udivdi3>
  80026d:	83 c4 18             	add    $0x18,%esp
  800270:	52                   	push   %edx
  800271:	50                   	push   %eax
  800272:	89 f2                	mov    %esi,%edx
  800274:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800277:	e8 98 ff ff ff       	call   800214 <printnum>
  80027c:	83 c4 20             	add    $0x20,%esp
  80027f:	eb 10                	jmp    800291 <printnum+0x7d>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800281:	83 ec 08             	sub    $0x8,%esp
  800284:	56                   	push   %esi
  800285:	57                   	push   %edi
  800286:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800289:	4b                   	dec    %ebx
  80028a:	83 c4 10             	add    $0x10,%esp
  80028d:	85 db                	test   %ebx,%ebx
  80028f:	7f f0                	jg     800281 <printnum+0x6d>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800291:	83 ec 08             	sub    $0x8,%esp
  800294:	56                   	push   %esi
  800295:	83 ec 04             	sub    $0x4,%esp
  800298:	ff 75 d4             	pushl  -0x2c(%ebp)
  80029b:	ff 75 d0             	pushl  -0x30(%ebp)
  80029e:	ff 75 dc             	pushl  -0x24(%ebp)
  8002a1:	ff 75 d8             	pushl  -0x28(%ebp)
  8002a4:	e8 5f 0c 00 00       	call   800f08 <__umoddi3>
  8002a9:	83 c4 14             	add    $0x14,%esp
  8002ac:	0f be 80 db 10 80 00 	movsbl 0x8010db(%eax),%eax
  8002b3:	50                   	push   %eax
  8002b4:	ff 55 e4             	call   *-0x1c(%ebp)
  8002b7:	83 c4 10             	add    $0x10,%esp
}
  8002ba:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002bd:	5b                   	pop    %ebx
  8002be:	5e                   	pop    %esi
  8002bf:	5f                   	pop    %edi
  8002c0:	c9                   	leave  
  8002c1:	c3                   	ret    

008002c2 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002c2:	55                   	push   %ebp
  8002c3:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002c5:	83 fa 01             	cmp    $0x1,%edx
  8002c8:	7e 0e                	jle    8002d8 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8002ca:	8b 10                	mov    (%eax),%edx
  8002cc:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002cf:	89 08                	mov    %ecx,(%eax)
  8002d1:	8b 02                	mov    (%edx),%eax
  8002d3:	8b 52 04             	mov    0x4(%edx),%edx
  8002d6:	eb 22                	jmp    8002fa <getuint+0x38>
	else if (lflag)
  8002d8:	85 d2                	test   %edx,%edx
  8002da:	74 10                	je     8002ec <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8002dc:	8b 10                	mov    (%eax),%edx
  8002de:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002e1:	89 08                	mov    %ecx,(%eax)
  8002e3:	8b 02                	mov    (%edx),%eax
  8002e5:	ba 00 00 00 00       	mov    $0x0,%edx
  8002ea:	eb 0e                	jmp    8002fa <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8002ec:	8b 10                	mov    (%eax),%edx
  8002ee:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002f1:	89 08                	mov    %ecx,(%eax)
  8002f3:	8b 02                	mov    (%edx),%eax
  8002f5:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002fa:	c9                   	leave  
  8002fb:	c3                   	ret    

008002fc <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  8002fc:	55                   	push   %ebp
  8002fd:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002ff:	83 fa 01             	cmp    $0x1,%edx
  800302:	7e 0e                	jle    800312 <getint+0x16>
		return va_arg(*ap, long long);
  800304:	8b 10                	mov    (%eax),%edx
  800306:	8d 4a 08             	lea    0x8(%edx),%ecx
  800309:	89 08                	mov    %ecx,(%eax)
  80030b:	8b 02                	mov    (%edx),%eax
  80030d:	8b 52 04             	mov    0x4(%edx),%edx
  800310:	eb 1a                	jmp    80032c <getint+0x30>
	else if (lflag)
  800312:	85 d2                	test   %edx,%edx
  800314:	74 0c                	je     800322 <getint+0x26>
		return va_arg(*ap, long);
  800316:	8b 10                	mov    (%eax),%edx
  800318:	8d 4a 04             	lea    0x4(%edx),%ecx
  80031b:	89 08                	mov    %ecx,(%eax)
  80031d:	8b 02                	mov    (%edx),%eax
  80031f:	99                   	cltd   
  800320:	eb 0a                	jmp    80032c <getint+0x30>
	else
		return va_arg(*ap, int);
  800322:	8b 10                	mov    (%eax),%edx
  800324:	8d 4a 04             	lea    0x4(%edx),%ecx
  800327:	89 08                	mov    %ecx,(%eax)
  800329:	8b 02                	mov    (%edx),%eax
  80032b:	99                   	cltd   
}
  80032c:	c9                   	leave  
  80032d:	c3                   	ret    

0080032e <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80032e:	55                   	push   %ebp
  80032f:	89 e5                	mov    %esp,%ebp
  800331:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800334:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  800337:	8b 10                	mov    (%eax),%edx
  800339:	3b 50 04             	cmp    0x4(%eax),%edx
  80033c:	73 08                	jae    800346 <sprintputch+0x18>
		*b->buf++ = ch;
  80033e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800341:	88 0a                	mov    %cl,(%edx)
  800343:	42                   	inc    %edx
  800344:	89 10                	mov    %edx,(%eax)
}
  800346:	c9                   	leave  
  800347:	c3                   	ret    

00800348 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800348:	55                   	push   %ebp
  800349:	89 e5                	mov    %esp,%ebp
  80034b:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80034e:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800351:	50                   	push   %eax
  800352:	ff 75 10             	pushl  0x10(%ebp)
  800355:	ff 75 0c             	pushl  0xc(%ebp)
  800358:	ff 75 08             	pushl  0x8(%ebp)
  80035b:	e8 05 00 00 00       	call   800365 <vprintfmt>
	va_end(ap);
  800360:	83 c4 10             	add    $0x10,%esp
}
  800363:	c9                   	leave  
  800364:	c3                   	ret    

00800365 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800365:	55                   	push   %ebp
  800366:	89 e5                	mov    %esp,%ebp
  800368:	57                   	push   %edi
  800369:	56                   	push   %esi
  80036a:	53                   	push   %ebx
  80036b:	83 ec 2c             	sub    $0x2c,%esp
  80036e:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800371:	8b 75 10             	mov    0x10(%ebp),%esi
  800374:	eb 13                	jmp    800389 <vprintfmt+0x24>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800376:	85 c0                	test   %eax,%eax
  800378:	0f 84 6d 03 00 00    	je     8006eb <vprintfmt+0x386>
				return;
			putch(ch, putdat);
  80037e:	83 ec 08             	sub    $0x8,%esp
  800381:	57                   	push   %edi
  800382:	50                   	push   %eax
  800383:	ff 55 08             	call   *0x8(%ebp)
  800386:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800389:	0f b6 06             	movzbl (%esi),%eax
  80038c:	46                   	inc    %esi
  80038d:	83 f8 25             	cmp    $0x25,%eax
  800390:	75 e4                	jne    800376 <vprintfmt+0x11>
  800392:	c6 45 dc 20          	movb   $0x20,-0x24(%ebp)
  800396:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  80039d:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  8003a4:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  8003ab:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003b0:	eb 28                	jmp    8003da <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003b2:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  8003b4:	c6 45 dc 2d          	movb   $0x2d,-0x24(%ebp)
  8003b8:	eb 20                	jmp    8003da <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ba:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8003bc:	c6 45 dc 30          	movb   $0x30,-0x24(%ebp)
  8003c0:	eb 18                	jmp    8003da <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003c2:	89 de                	mov    %ebx,%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  8003c4:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8003cb:	eb 0d                	jmp    8003da <vprintfmt+0x75>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  8003cd:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8003d0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003d3:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003da:	8a 06                	mov    (%esi),%al
  8003dc:	0f b6 d0             	movzbl %al,%edx
  8003df:	8d 5e 01             	lea    0x1(%esi),%ebx
  8003e2:	83 e8 23             	sub    $0x23,%eax
  8003e5:	3c 55                	cmp    $0x55,%al
  8003e7:	0f 87 e0 02 00 00    	ja     8006cd <vprintfmt+0x368>
  8003ed:	0f b6 c0             	movzbl %al,%eax
  8003f0:	ff 24 85 a0 11 80 00 	jmp    *0x8011a0(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003f7:	83 ea 30             	sub    $0x30,%edx
  8003fa:	89 55 d4             	mov    %edx,-0x2c(%ebp)
				ch = *fmt;
  8003fd:	0f be 03             	movsbl (%ebx),%eax
				if (ch < '0' || ch > '9')
  800400:	8d 50 d0             	lea    -0x30(%eax),%edx
  800403:	83 fa 09             	cmp    $0x9,%edx
  800406:	77 44                	ja     80044c <vprintfmt+0xe7>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800408:	89 de                	mov    %ebx,%esi
  80040a:	8b 55 d4             	mov    -0x2c(%ebp),%edx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80040d:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
  80040e:	8d 14 92             	lea    (%edx,%edx,4),%edx
  800411:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
  800415:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800418:	8d 58 d0             	lea    -0x30(%eax),%ebx
  80041b:	83 fb 09             	cmp    $0x9,%ebx
  80041e:	76 ed                	jbe    80040d <vprintfmt+0xa8>
  800420:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  800423:	eb 29                	jmp    80044e <vprintfmt+0xe9>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800425:	8b 45 14             	mov    0x14(%ebp),%eax
  800428:	8d 50 04             	lea    0x4(%eax),%edx
  80042b:	89 55 14             	mov    %edx,0x14(%ebp)
  80042e:	8b 00                	mov    (%eax),%eax
  800430:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800433:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800435:	eb 17                	jmp    80044e <vprintfmt+0xe9>

		case '.':
			if (width < 0)
  800437:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80043b:	78 85                	js     8003c2 <vprintfmt+0x5d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80043d:	89 de                	mov    %ebx,%esi
  80043f:	eb 99                	jmp    8003da <vprintfmt+0x75>
  800441:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800443:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  80044a:	eb 8e                	jmp    8003da <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80044c:	89 de                	mov    %ebx,%esi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  80044e:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800452:	79 86                	jns    8003da <vprintfmt+0x75>
  800454:	e9 74 ff ff ff       	jmp    8003cd <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800459:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80045a:	89 de                	mov    %ebx,%esi
  80045c:	e9 79 ff ff ff       	jmp    8003da <vprintfmt+0x75>
  800461:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800464:	8b 45 14             	mov    0x14(%ebp),%eax
  800467:	8d 50 04             	lea    0x4(%eax),%edx
  80046a:	89 55 14             	mov    %edx,0x14(%ebp)
  80046d:	83 ec 08             	sub    $0x8,%esp
  800470:	57                   	push   %edi
  800471:	ff 30                	pushl  (%eax)
  800473:	ff 55 08             	call   *0x8(%ebp)
			break;
  800476:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800479:	8b 75 d8             	mov    -0x28(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80047c:	e9 08 ff ff ff       	jmp    800389 <vprintfmt+0x24>
  800481:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  800484:	8b 45 14             	mov    0x14(%ebp),%eax
  800487:	8d 50 04             	lea    0x4(%eax),%edx
  80048a:	89 55 14             	mov    %edx,0x14(%ebp)
  80048d:	8b 00                	mov    (%eax),%eax
  80048f:	85 c0                	test   %eax,%eax
  800491:	79 02                	jns    800495 <vprintfmt+0x130>
  800493:	f7 d8                	neg    %eax
  800495:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800497:	83 f8 08             	cmp    $0x8,%eax
  80049a:	7f 0b                	jg     8004a7 <vprintfmt+0x142>
  80049c:	8b 04 85 00 13 80 00 	mov    0x801300(,%eax,4),%eax
  8004a3:	85 c0                	test   %eax,%eax
  8004a5:	75 1a                	jne    8004c1 <vprintfmt+0x15c>
				printfmt(putch, putdat, "error %d", err);
  8004a7:	52                   	push   %edx
  8004a8:	68 f3 10 80 00       	push   $0x8010f3
  8004ad:	57                   	push   %edi
  8004ae:	ff 75 08             	pushl  0x8(%ebp)
  8004b1:	e8 92 fe ff ff       	call   800348 <printfmt>
  8004b6:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004b9:	8b 75 d8             	mov    -0x28(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8004bc:	e9 c8 fe ff ff       	jmp    800389 <vprintfmt+0x24>
			else
				printfmt(putch, putdat, "%s", p);
  8004c1:	50                   	push   %eax
  8004c2:	68 fc 10 80 00       	push   $0x8010fc
  8004c7:	57                   	push   %edi
  8004c8:	ff 75 08             	pushl  0x8(%ebp)
  8004cb:	e8 78 fe ff ff       	call   800348 <printfmt>
  8004d0:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004d3:	8b 75 d8             	mov    -0x28(%ebp),%esi
  8004d6:	e9 ae fe ff ff       	jmp    800389 <vprintfmt+0x24>
  8004db:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  8004de:	89 de                	mov    %ebx,%esi
  8004e0:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  8004e3:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004e6:	8b 45 14             	mov    0x14(%ebp),%eax
  8004e9:	8d 50 04             	lea    0x4(%eax),%edx
  8004ec:	89 55 14             	mov    %edx,0x14(%ebp)
  8004ef:	8b 00                	mov    (%eax),%eax
  8004f1:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8004f4:	85 c0                	test   %eax,%eax
  8004f6:	75 07                	jne    8004ff <vprintfmt+0x19a>
				p = "(null)";
  8004f8:	c7 45 d0 ec 10 80 00 	movl   $0x8010ec,-0x30(%ebp)
			if (width > 0 && padc != '-')
  8004ff:	85 db                	test   %ebx,%ebx
  800501:	7e 42                	jle    800545 <vprintfmt+0x1e0>
  800503:	80 7d dc 2d          	cmpb   $0x2d,-0x24(%ebp)
  800507:	74 3c                	je     800545 <vprintfmt+0x1e0>
				for (width -= strnlen(p, precision); width > 0; width--)
  800509:	83 ec 08             	sub    $0x8,%esp
  80050c:	51                   	push   %ecx
  80050d:	ff 75 d0             	pushl  -0x30(%ebp)
  800510:	e8 6f 02 00 00       	call   800784 <strnlen>
  800515:	29 c3                	sub    %eax,%ebx
  800517:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80051a:	83 c4 10             	add    $0x10,%esp
  80051d:	85 db                	test   %ebx,%ebx
  80051f:	7e 24                	jle    800545 <vprintfmt+0x1e0>
					putch(padc, putdat);
  800521:	0f be 5d dc          	movsbl -0x24(%ebp),%ebx
  800525:	89 75 dc             	mov    %esi,-0x24(%ebp)
  800528:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  80052b:	83 ec 08             	sub    $0x8,%esp
  80052e:	57                   	push   %edi
  80052f:	53                   	push   %ebx
  800530:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800533:	4e                   	dec    %esi
  800534:	83 c4 10             	add    $0x10,%esp
  800537:	85 f6                	test   %esi,%esi
  800539:	7f f0                	jg     80052b <vprintfmt+0x1c6>
  80053b:	8b 75 dc             	mov    -0x24(%ebp),%esi
  80053e:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800545:	8b 55 d0             	mov    -0x30(%ebp),%edx
  800548:	0f be 02             	movsbl (%edx),%eax
  80054b:	85 c0                	test   %eax,%eax
  80054d:	75 47                	jne    800596 <vprintfmt+0x231>
  80054f:	eb 37                	jmp    800588 <vprintfmt+0x223>
				if (altflag && (ch < ' ' || ch > '~'))
  800551:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800555:	74 16                	je     80056d <vprintfmt+0x208>
  800557:	8d 50 e0             	lea    -0x20(%eax),%edx
  80055a:	83 fa 5e             	cmp    $0x5e,%edx
  80055d:	76 0e                	jbe    80056d <vprintfmt+0x208>
					putch('?', putdat);
  80055f:	83 ec 08             	sub    $0x8,%esp
  800562:	57                   	push   %edi
  800563:	6a 3f                	push   $0x3f
  800565:	ff 55 08             	call   *0x8(%ebp)
  800568:	83 c4 10             	add    $0x10,%esp
  80056b:	eb 0b                	jmp    800578 <vprintfmt+0x213>
				else
					putch(ch, putdat);
  80056d:	83 ec 08             	sub    $0x8,%esp
  800570:	57                   	push   %edi
  800571:	50                   	push   %eax
  800572:	ff 55 08             	call   *0x8(%ebp)
  800575:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800578:	ff 4d e4             	decl   -0x1c(%ebp)
  80057b:	0f be 03             	movsbl (%ebx),%eax
  80057e:	85 c0                	test   %eax,%eax
  800580:	74 03                	je     800585 <vprintfmt+0x220>
  800582:	43                   	inc    %ebx
  800583:	eb 1b                	jmp    8005a0 <vprintfmt+0x23b>
  800585:	8b 75 dc             	mov    -0x24(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800588:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80058c:	7f 1e                	jg     8005ac <vprintfmt+0x247>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80058e:	8b 75 d8             	mov    -0x28(%ebp),%esi
  800591:	e9 f3 fd ff ff       	jmp    800389 <vprintfmt+0x24>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800596:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800599:	43                   	inc    %ebx
  80059a:	89 75 dc             	mov    %esi,-0x24(%ebp)
  80059d:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  8005a0:	85 f6                	test   %esi,%esi
  8005a2:	78 ad                	js     800551 <vprintfmt+0x1ec>
  8005a4:	4e                   	dec    %esi
  8005a5:	79 aa                	jns    800551 <vprintfmt+0x1ec>
  8005a7:	8b 75 dc             	mov    -0x24(%ebp),%esi
  8005aa:	eb dc                	jmp    800588 <vprintfmt+0x223>
  8005ac:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8005af:	83 ec 08             	sub    $0x8,%esp
  8005b2:	57                   	push   %edi
  8005b3:	6a 20                	push   $0x20
  8005b5:	ff 55 08             	call   *0x8(%ebp)
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005b8:	4b                   	dec    %ebx
  8005b9:	83 c4 10             	add    $0x10,%esp
  8005bc:	85 db                	test   %ebx,%ebx
  8005be:	7f ef                	jg     8005af <vprintfmt+0x24a>
  8005c0:	e9 c4 fd ff ff       	jmp    800389 <vprintfmt+0x24>
  8005c5:	89 5d d8             	mov    %ebx,-0x28(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8005c8:	89 ca                	mov    %ecx,%edx
  8005ca:	8d 45 14             	lea    0x14(%ebp),%eax
  8005cd:	e8 2a fd ff ff       	call   8002fc <getint>
  8005d2:	89 c3                	mov    %eax,%ebx
  8005d4:	89 d6                	mov    %edx,%esi
			if ((long long) num < 0) {
  8005d6:	85 d2                	test   %edx,%edx
  8005d8:	78 0a                	js     8005e4 <vprintfmt+0x27f>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8005da:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005df:	e9 b0 00 00 00       	jmp    800694 <vprintfmt+0x32f>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  8005e4:	83 ec 08             	sub    $0x8,%esp
  8005e7:	57                   	push   %edi
  8005e8:	6a 2d                	push   $0x2d
  8005ea:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8005ed:	f7 db                	neg    %ebx
  8005ef:	83 d6 00             	adc    $0x0,%esi
  8005f2:	f7 de                	neg    %esi
  8005f4:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8005f7:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005fc:	e9 93 00 00 00       	jmp    800694 <vprintfmt+0x32f>
  800601:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800604:	89 ca                	mov    %ecx,%edx
  800606:	8d 45 14             	lea    0x14(%ebp),%eax
  800609:	e8 b4 fc ff ff       	call   8002c2 <getuint>
  80060e:	89 c3                	mov    %eax,%ebx
  800610:	89 d6                	mov    %edx,%esi
			base = 10;
  800612:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  800617:	eb 7b                	jmp    800694 <vprintfmt+0x32f>
  800619:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
  80061c:	89 ca                	mov    %ecx,%edx
  80061e:	8d 45 14             	lea    0x14(%ebp),%eax
  800621:	e8 d6 fc ff ff       	call   8002fc <getint>
  800626:	89 c3                	mov    %eax,%ebx
  800628:	89 d6                	mov    %edx,%esi
            if ((long long) num < 0) {
  80062a:	85 d2                	test   %edx,%edx
  80062c:	78 07                	js     800635 <vprintfmt+0x2d0>
                putch('-', putdat);
                num = -(long long) num;
            }
            base = 8;
  80062e:	b8 08 00 00 00       	mov    $0x8,%eax
  800633:	eb 5f                	jmp    800694 <vprintfmt+0x32f>
		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
            if ((long long) num < 0) {
                putch('-', putdat);
  800635:	83 ec 08             	sub    $0x8,%esp
  800638:	57                   	push   %edi
  800639:	6a 2d                	push   $0x2d
  80063b:	ff 55 08             	call   *0x8(%ebp)
                num = -(long long) num;
  80063e:	f7 db                	neg    %ebx
  800640:	83 d6 00             	adc    $0x0,%esi
  800643:	f7 de                	neg    %esi
  800645:	83 c4 10             	add    $0x10,%esp
            }
            base = 8;
  800648:	b8 08 00 00 00       	mov    $0x8,%eax
  80064d:	eb 45                	jmp    800694 <vprintfmt+0x32f>
  80064f:	89 5d d8             	mov    %ebx,-0x28(%ebp)
            goto number;

        // pointer
		case 'p':
			putch('0', putdat);
  800652:	83 ec 08             	sub    $0x8,%esp
  800655:	57                   	push   %edi
  800656:	6a 30                	push   $0x30
  800658:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  80065b:	83 c4 08             	add    $0x8,%esp
  80065e:	57                   	push   %edi
  80065f:	6a 78                	push   $0x78
  800661:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800664:	8b 45 14             	mov    0x14(%ebp),%eax
  800667:	8d 50 04             	lea    0x4(%eax),%edx
  80066a:	89 55 14             	mov    %edx,0x14(%ebp)

        // pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80066d:	8b 18                	mov    (%eax),%ebx
  80066f:	be 00 00 00 00       	mov    $0x0,%esi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800674:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800677:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  80067c:	eb 16                	jmp    800694 <vprintfmt+0x32f>
  80067e:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800681:	89 ca                	mov    %ecx,%edx
  800683:	8d 45 14             	lea    0x14(%ebp),%eax
  800686:	e8 37 fc ff ff       	call   8002c2 <getuint>
  80068b:	89 c3                	mov    %eax,%ebx
  80068d:	89 d6                	mov    %edx,%esi
			base = 16;
  80068f:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800694:	83 ec 0c             	sub    $0xc,%esp
  800697:	0f be 55 dc          	movsbl -0x24(%ebp),%edx
  80069b:	52                   	push   %edx
  80069c:	ff 75 e4             	pushl  -0x1c(%ebp)
  80069f:	50                   	push   %eax
  8006a0:	56                   	push   %esi
  8006a1:	53                   	push   %ebx
  8006a2:	89 fa                	mov    %edi,%edx
  8006a4:	8b 45 08             	mov    0x8(%ebp),%eax
  8006a7:	e8 68 fb ff ff       	call   800214 <printnum>
			break;
  8006ac:	83 c4 20             	add    $0x20,%esp
  8006af:	8b 75 d8             	mov    -0x28(%ebp),%esi
  8006b2:	e9 d2 fc ff ff       	jmp    800389 <vprintfmt+0x24>
  8006b7:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006ba:	83 ec 08             	sub    $0x8,%esp
  8006bd:	57                   	push   %edi
  8006be:	52                   	push   %edx
  8006bf:	ff 55 08             	call   *0x8(%ebp)
			break;
  8006c2:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006c5:	8b 75 d8             	mov    -0x28(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8006c8:	e9 bc fc ff ff       	jmp    800389 <vprintfmt+0x24>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8006cd:	83 ec 08             	sub    $0x8,%esp
  8006d0:	57                   	push   %edi
  8006d1:	6a 25                	push   $0x25
  8006d3:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006d6:	83 c4 10             	add    $0x10,%esp
  8006d9:	eb 02                	jmp    8006dd <vprintfmt+0x378>
  8006db:	89 c6                	mov    %eax,%esi
  8006dd:	8d 46 ff             	lea    -0x1(%esi),%eax
  8006e0:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  8006e4:	75 f5                	jne    8006db <vprintfmt+0x376>
  8006e6:	e9 9e fc ff ff       	jmp    800389 <vprintfmt+0x24>
				/* do nothing */;
			break;
		}
	}
}
  8006eb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006ee:	5b                   	pop    %ebx
  8006ef:	5e                   	pop    %esi
  8006f0:	5f                   	pop    %edi
  8006f1:	c9                   	leave  
  8006f2:	c3                   	ret    

008006f3 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006f3:	55                   	push   %ebp
  8006f4:	89 e5                	mov    %esp,%ebp
  8006f6:	83 ec 18             	sub    $0x18,%esp
  8006f9:	8b 45 08             	mov    0x8(%ebp),%eax
  8006fc:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006ff:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800702:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800706:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800709:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800710:	85 c0                	test   %eax,%eax
  800712:	74 26                	je     80073a <vsnprintf+0x47>
  800714:	85 d2                	test   %edx,%edx
  800716:	7e 29                	jle    800741 <vsnprintf+0x4e>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800718:	ff 75 14             	pushl  0x14(%ebp)
  80071b:	ff 75 10             	pushl  0x10(%ebp)
  80071e:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800721:	50                   	push   %eax
  800722:	68 2e 03 80 00       	push   $0x80032e
  800727:	e8 39 fc ff ff       	call   800365 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80072c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80072f:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800732:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800735:	83 c4 10             	add    $0x10,%esp
  800738:	eb 0c                	jmp    800746 <vsnprintf+0x53>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80073a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80073f:	eb 05                	jmp    800746 <vsnprintf+0x53>
  800741:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800746:	c9                   	leave  
  800747:	c3                   	ret    

00800748 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800748:	55                   	push   %ebp
  800749:	89 e5                	mov    %esp,%ebp
  80074b:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80074e:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800751:	50                   	push   %eax
  800752:	ff 75 10             	pushl  0x10(%ebp)
  800755:	ff 75 0c             	pushl  0xc(%ebp)
  800758:	ff 75 08             	pushl  0x8(%ebp)
  80075b:	e8 93 ff ff ff       	call   8006f3 <vsnprintf>
	va_end(ap);

	return rc;
}
  800760:	c9                   	leave  
  800761:	c3                   	ret    
	...

00800764 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800764:	55                   	push   %ebp
  800765:	89 e5                	mov    %esp,%ebp
  800767:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80076a:	80 3a 00             	cmpb   $0x0,(%edx)
  80076d:	74 0e                	je     80077d <strlen+0x19>
  80076f:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800774:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800775:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800779:	75 f9                	jne    800774 <strlen+0x10>
  80077b:	eb 05                	jmp    800782 <strlen+0x1e>
  80077d:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800782:	c9                   	leave  
  800783:	c3                   	ret    

00800784 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800784:	55                   	push   %ebp
  800785:	89 e5                	mov    %esp,%ebp
  800787:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80078a:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80078d:	85 d2                	test   %edx,%edx
  80078f:	74 17                	je     8007a8 <strnlen+0x24>
  800791:	80 39 00             	cmpb   $0x0,(%ecx)
  800794:	74 19                	je     8007af <strnlen+0x2b>
  800796:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  80079b:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80079c:	39 d0                	cmp    %edx,%eax
  80079e:	74 14                	je     8007b4 <strnlen+0x30>
  8007a0:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8007a4:	75 f5                	jne    80079b <strnlen+0x17>
  8007a6:	eb 0c                	jmp    8007b4 <strnlen+0x30>
  8007a8:	b8 00 00 00 00       	mov    $0x0,%eax
  8007ad:	eb 05                	jmp    8007b4 <strnlen+0x30>
  8007af:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  8007b4:	c9                   	leave  
  8007b5:	c3                   	ret    

008007b6 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007b6:	55                   	push   %ebp
  8007b7:	89 e5                	mov    %esp,%ebp
  8007b9:	53                   	push   %ebx
  8007ba:	8b 45 08             	mov    0x8(%ebp),%eax
  8007bd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007c0:	ba 00 00 00 00       	mov    $0x0,%edx
  8007c5:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  8007c8:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  8007cb:	42                   	inc    %edx
  8007cc:	84 c9                	test   %cl,%cl
  8007ce:	75 f5                	jne    8007c5 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8007d0:	5b                   	pop    %ebx
  8007d1:	c9                   	leave  
  8007d2:	c3                   	ret    

008007d3 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007d3:	55                   	push   %ebp
  8007d4:	89 e5                	mov    %esp,%ebp
  8007d6:	53                   	push   %ebx
  8007d7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007da:	53                   	push   %ebx
  8007db:	e8 84 ff ff ff       	call   800764 <strlen>
  8007e0:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8007e3:	ff 75 0c             	pushl  0xc(%ebp)
  8007e6:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  8007e9:	50                   	push   %eax
  8007ea:	e8 c7 ff ff ff       	call   8007b6 <strcpy>
	return dst;
}
  8007ef:	89 d8                	mov    %ebx,%eax
  8007f1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007f4:	c9                   	leave  
  8007f5:	c3                   	ret    

008007f6 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007f6:	55                   	push   %ebp
  8007f7:	89 e5                	mov    %esp,%ebp
  8007f9:	56                   	push   %esi
  8007fa:	53                   	push   %ebx
  8007fb:	8b 45 08             	mov    0x8(%ebp),%eax
  8007fe:	8b 55 0c             	mov    0xc(%ebp),%edx
  800801:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800804:	85 f6                	test   %esi,%esi
  800806:	74 15                	je     80081d <strncpy+0x27>
  800808:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  80080d:	8a 1a                	mov    (%edx),%bl
  80080f:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800812:	80 3a 01             	cmpb   $0x1,(%edx)
  800815:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800818:	41                   	inc    %ecx
  800819:	39 ce                	cmp    %ecx,%esi
  80081b:	77 f0                	ja     80080d <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80081d:	5b                   	pop    %ebx
  80081e:	5e                   	pop    %esi
  80081f:	c9                   	leave  
  800820:	c3                   	ret    

00800821 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800821:	55                   	push   %ebp
  800822:	89 e5                	mov    %esp,%ebp
  800824:	57                   	push   %edi
  800825:	56                   	push   %esi
  800826:	53                   	push   %ebx
  800827:	8b 7d 08             	mov    0x8(%ebp),%edi
  80082a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80082d:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800830:	85 f6                	test   %esi,%esi
  800832:	74 32                	je     800866 <strlcpy+0x45>
		while (--size > 0 && *src != '\0')
  800834:	83 fe 01             	cmp    $0x1,%esi
  800837:	74 22                	je     80085b <strlcpy+0x3a>
  800839:	8a 0b                	mov    (%ebx),%cl
  80083b:	84 c9                	test   %cl,%cl
  80083d:	74 20                	je     80085f <strlcpy+0x3e>
  80083f:	89 f8                	mov    %edi,%eax
  800841:	ba 00 00 00 00       	mov    $0x0,%edx
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
  800846:	83 ee 02             	sub    $0x2,%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800849:	88 08                	mov    %cl,(%eax)
  80084b:	40                   	inc    %eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80084c:	39 f2                	cmp    %esi,%edx
  80084e:	74 11                	je     800861 <strlcpy+0x40>
  800850:	8a 4c 13 01          	mov    0x1(%ebx,%edx,1),%cl
  800854:	42                   	inc    %edx
  800855:	84 c9                	test   %cl,%cl
  800857:	75 f0                	jne    800849 <strlcpy+0x28>
  800859:	eb 06                	jmp    800861 <strlcpy+0x40>
  80085b:	89 f8                	mov    %edi,%eax
  80085d:	eb 02                	jmp    800861 <strlcpy+0x40>
  80085f:	89 f8                	mov    %edi,%eax
			*dst++ = *src++;
		*dst = '\0';
  800861:	c6 00 00             	movb   $0x0,(%eax)
  800864:	eb 02                	jmp    800868 <strlcpy+0x47>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800866:	89 f8                	mov    %edi,%eax
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
		*dst = '\0';
	}
	return dst - dst_in;
  800868:	29 f8                	sub    %edi,%eax
}
  80086a:	5b                   	pop    %ebx
  80086b:	5e                   	pop    %esi
  80086c:	5f                   	pop    %edi
  80086d:	c9                   	leave  
  80086e:	c3                   	ret    

0080086f <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80086f:	55                   	push   %ebp
  800870:	89 e5                	mov    %esp,%ebp
  800872:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800875:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800878:	8a 01                	mov    (%ecx),%al
  80087a:	84 c0                	test   %al,%al
  80087c:	74 10                	je     80088e <strcmp+0x1f>
  80087e:	3a 02                	cmp    (%edx),%al
  800880:	75 0c                	jne    80088e <strcmp+0x1f>
		p++, q++;
  800882:	41                   	inc    %ecx
  800883:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800884:	8a 01                	mov    (%ecx),%al
  800886:	84 c0                	test   %al,%al
  800888:	74 04                	je     80088e <strcmp+0x1f>
  80088a:	3a 02                	cmp    (%edx),%al
  80088c:	74 f4                	je     800882 <strcmp+0x13>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80088e:	0f b6 c0             	movzbl %al,%eax
  800891:	0f b6 12             	movzbl (%edx),%edx
  800894:	29 d0                	sub    %edx,%eax
}
  800896:	c9                   	leave  
  800897:	c3                   	ret    

00800898 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800898:	55                   	push   %ebp
  800899:	89 e5                	mov    %esp,%ebp
  80089b:	53                   	push   %ebx
  80089c:	8b 55 08             	mov    0x8(%ebp),%edx
  80089f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008a2:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  8008a5:	85 c0                	test   %eax,%eax
  8008a7:	74 1b                	je     8008c4 <strncmp+0x2c>
  8008a9:	8a 1a                	mov    (%edx),%bl
  8008ab:	84 db                	test   %bl,%bl
  8008ad:	74 24                	je     8008d3 <strncmp+0x3b>
  8008af:	3a 19                	cmp    (%ecx),%bl
  8008b1:	75 20                	jne    8008d3 <strncmp+0x3b>
  8008b3:	48                   	dec    %eax
  8008b4:	74 15                	je     8008cb <strncmp+0x33>
		n--, p++, q++;
  8008b6:	42                   	inc    %edx
  8008b7:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8008b8:	8a 1a                	mov    (%edx),%bl
  8008ba:	84 db                	test   %bl,%bl
  8008bc:	74 15                	je     8008d3 <strncmp+0x3b>
  8008be:	3a 19                	cmp    (%ecx),%bl
  8008c0:	74 f1                	je     8008b3 <strncmp+0x1b>
  8008c2:	eb 0f                	jmp    8008d3 <strncmp+0x3b>
		n--, p++, q++;
	if (n == 0)
		return 0;
  8008c4:	b8 00 00 00 00       	mov    $0x0,%eax
  8008c9:	eb 05                	jmp    8008d0 <strncmp+0x38>
  8008cb:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8008d0:	5b                   	pop    %ebx
  8008d1:	c9                   	leave  
  8008d2:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008d3:	0f b6 02             	movzbl (%edx),%eax
  8008d6:	0f b6 11             	movzbl (%ecx),%edx
  8008d9:	29 d0                	sub    %edx,%eax
  8008db:	eb f3                	jmp    8008d0 <strncmp+0x38>

008008dd <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008dd:	55                   	push   %ebp
  8008de:	89 e5                	mov    %esp,%ebp
  8008e0:	8b 45 08             	mov    0x8(%ebp),%eax
  8008e3:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8008e6:	8a 10                	mov    (%eax),%dl
  8008e8:	84 d2                	test   %dl,%dl
  8008ea:	74 18                	je     800904 <strchr+0x27>
		if (*s == c)
  8008ec:	38 ca                	cmp    %cl,%dl
  8008ee:	75 06                	jne    8008f6 <strchr+0x19>
  8008f0:	eb 17                	jmp    800909 <strchr+0x2c>
  8008f2:	38 ca                	cmp    %cl,%dl
  8008f4:	74 13                	je     800909 <strchr+0x2c>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8008f6:	40                   	inc    %eax
  8008f7:	8a 10                	mov    (%eax),%dl
  8008f9:	84 d2                	test   %dl,%dl
  8008fb:	75 f5                	jne    8008f2 <strchr+0x15>
		if (*s == c)
			return (char *) s;
	return 0;
  8008fd:	b8 00 00 00 00       	mov    $0x0,%eax
  800902:	eb 05                	jmp    800909 <strchr+0x2c>
  800904:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800909:	c9                   	leave  
  80090a:	c3                   	ret    

0080090b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80090b:	55                   	push   %ebp
  80090c:	89 e5                	mov    %esp,%ebp
  80090e:	8b 45 08             	mov    0x8(%ebp),%eax
  800911:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800914:	8a 10                	mov    (%eax),%dl
  800916:	84 d2                	test   %dl,%dl
  800918:	74 11                	je     80092b <strfind+0x20>
		if (*s == c)
  80091a:	38 ca                	cmp    %cl,%dl
  80091c:	75 06                	jne    800924 <strfind+0x19>
  80091e:	eb 0b                	jmp    80092b <strfind+0x20>
  800920:	38 ca                	cmp    %cl,%dl
  800922:	74 07                	je     80092b <strfind+0x20>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800924:	40                   	inc    %eax
  800925:	8a 10                	mov    (%eax),%dl
  800927:	84 d2                	test   %dl,%dl
  800929:	75 f5                	jne    800920 <strfind+0x15>
		if (*s == c)
			break;
	return (char *) s;
}
  80092b:	c9                   	leave  
  80092c:	c3                   	ret    

0080092d <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80092d:	55                   	push   %ebp
  80092e:	89 e5                	mov    %esp,%ebp
  800930:	57                   	push   %edi
  800931:	56                   	push   %esi
  800932:	53                   	push   %ebx
  800933:	8b 7d 08             	mov    0x8(%ebp),%edi
  800936:	8b 45 0c             	mov    0xc(%ebp),%eax
  800939:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80093c:	85 c9                	test   %ecx,%ecx
  80093e:	74 30                	je     800970 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800940:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800946:	75 25                	jne    80096d <memset+0x40>
  800948:	f6 c1 03             	test   $0x3,%cl
  80094b:	75 20                	jne    80096d <memset+0x40>
		c &= 0xFF;
  80094d:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800950:	89 d3                	mov    %edx,%ebx
  800952:	c1 e3 08             	shl    $0x8,%ebx
  800955:	89 d6                	mov    %edx,%esi
  800957:	c1 e6 18             	shl    $0x18,%esi
  80095a:	89 d0                	mov    %edx,%eax
  80095c:	c1 e0 10             	shl    $0x10,%eax
  80095f:	09 f0                	or     %esi,%eax
  800961:	09 d0                	or     %edx,%eax
  800963:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800965:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800968:	fc                   	cld    
  800969:	f3 ab                	rep stos %eax,%es:(%edi)
  80096b:	eb 03                	jmp    800970 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80096d:	fc                   	cld    
  80096e:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800970:	89 f8                	mov    %edi,%eax
  800972:	5b                   	pop    %ebx
  800973:	5e                   	pop    %esi
  800974:	5f                   	pop    %edi
  800975:	c9                   	leave  
  800976:	c3                   	ret    

00800977 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800977:	55                   	push   %ebp
  800978:	89 e5                	mov    %esp,%ebp
  80097a:	57                   	push   %edi
  80097b:	56                   	push   %esi
  80097c:	8b 45 08             	mov    0x8(%ebp),%eax
  80097f:	8b 75 0c             	mov    0xc(%ebp),%esi
  800982:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800985:	39 c6                	cmp    %eax,%esi
  800987:	73 34                	jae    8009bd <memmove+0x46>
  800989:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80098c:	39 d0                	cmp    %edx,%eax
  80098e:	73 2d                	jae    8009bd <memmove+0x46>
		s += n;
		d += n;
  800990:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800993:	f6 c2 03             	test   $0x3,%dl
  800996:	75 1b                	jne    8009b3 <memmove+0x3c>
  800998:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80099e:	75 13                	jne    8009b3 <memmove+0x3c>
  8009a0:	f6 c1 03             	test   $0x3,%cl
  8009a3:	75 0e                	jne    8009b3 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8009a5:	83 ef 04             	sub    $0x4,%edi
  8009a8:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009ab:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  8009ae:	fd                   	std    
  8009af:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009b1:	eb 07                	jmp    8009ba <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8009b3:	4f                   	dec    %edi
  8009b4:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8009b7:	fd                   	std    
  8009b8:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009ba:	fc                   	cld    
  8009bb:	eb 20                	jmp    8009dd <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009bd:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009c3:	75 13                	jne    8009d8 <memmove+0x61>
  8009c5:	a8 03                	test   $0x3,%al
  8009c7:	75 0f                	jne    8009d8 <memmove+0x61>
  8009c9:	f6 c1 03             	test   $0x3,%cl
  8009cc:	75 0a                	jne    8009d8 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8009ce:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  8009d1:	89 c7                	mov    %eax,%edi
  8009d3:	fc                   	cld    
  8009d4:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009d6:	eb 05                	jmp    8009dd <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8009d8:	89 c7                	mov    %eax,%edi
  8009da:	fc                   	cld    
  8009db:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009dd:	5e                   	pop    %esi
  8009de:	5f                   	pop    %edi
  8009df:	c9                   	leave  
  8009e0:	c3                   	ret    

008009e1 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009e1:	55                   	push   %ebp
  8009e2:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8009e4:	ff 75 10             	pushl  0x10(%ebp)
  8009e7:	ff 75 0c             	pushl  0xc(%ebp)
  8009ea:	ff 75 08             	pushl  0x8(%ebp)
  8009ed:	e8 85 ff ff ff       	call   800977 <memmove>
}
  8009f2:	c9                   	leave  
  8009f3:	c3                   	ret    

008009f4 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009f4:	55                   	push   %ebp
  8009f5:	89 e5                	mov    %esp,%ebp
  8009f7:	57                   	push   %edi
  8009f8:	56                   	push   %esi
  8009f9:	53                   	push   %ebx
  8009fa:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8009fd:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a00:	8b 7d 10             	mov    0x10(%ebp),%edi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a03:	85 ff                	test   %edi,%edi
  800a05:	74 32                	je     800a39 <memcmp+0x45>
		if (*s1 != *s2)
  800a07:	8a 03                	mov    (%ebx),%al
  800a09:	8a 0e                	mov    (%esi),%cl
  800a0b:	38 c8                	cmp    %cl,%al
  800a0d:	74 19                	je     800a28 <memcmp+0x34>
  800a0f:	eb 0d                	jmp    800a1e <memcmp+0x2a>
  800a11:	8a 44 13 01          	mov    0x1(%ebx,%edx,1),%al
  800a15:	8a 4c 16 01          	mov    0x1(%esi,%edx,1),%cl
  800a19:	42                   	inc    %edx
  800a1a:	38 c8                	cmp    %cl,%al
  800a1c:	74 10                	je     800a2e <memcmp+0x3a>
			return (int) *s1 - (int) *s2;
  800a1e:	0f b6 c0             	movzbl %al,%eax
  800a21:	0f b6 c9             	movzbl %cl,%ecx
  800a24:	29 c8                	sub    %ecx,%eax
  800a26:	eb 16                	jmp    800a3e <memcmp+0x4a>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a28:	4f                   	dec    %edi
  800a29:	ba 00 00 00 00       	mov    $0x0,%edx
  800a2e:	39 fa                	cmp    %edi,%edx
  800a30:	75 df                	jne    800a11 <memcmp+0x1d>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a32:	b8 00 00 00 00       	mov    $0x0,%eax
  800a37:	eb 05                	jmp    800a3e <memcmp+0x4a>
  800a39:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a3e:	5b                   	pop    %ebx
  800a3f:	5e                   	pop    %esi
  800a40:	5f                   	pop    %edi
  800a41:	c9                   	leave  
  800a42:	c3                   	ret    

00800a43 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a43:	55                   	push   %ebp
  800a44:	89 e5                	mov    %esp,%ebp
  800a46:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800a49:	89 c2                	mov    %eax,%edx
  800a4b:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a4e:	39 d0                	cmp    %edx,%eax
  800a50:	73 12                	jae    800a64 <memfind+0x21>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a52:	8a 4d 0c             	mov    0xc(%ebp),%cl
  800a55:	38 08                	cmp    %cl,(%eax)
  800a57:	75 06                	jne    800a5f <memfind+0x1c>
  800a59:	eb 09                	jmp    800a64 <memfind+0x21>
  800a5b:	38 08                	cmp    %cl,(%eax)
  800a5d:	74 05                	je     800a64 <memfind+0x21>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a5f:	40                   	inc    %eax
  800a60:	39 c2                	cmp    %eax,%edx
  800a62:	77 f7                	ja     800a5b <memfind+0x18>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a64:	c9                   	leave  
  800a65:	c3                   	ret    

00800a66 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a66:	55                   	push   %ebp
  800a67:	89 e5                	mov    %esp,%ebp
  800a69:	57                   	push   %edi
  800a6a:	56                   	push   %esi
  800a6b:	53                   	push   %ebx
  800a6c:	8b 55 08             	mov    0x8(%ebp),%edx
  800a6f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a72:	eb 01                	jmp    800a75 <strtol+0xf>
		s++;
  800a74:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a75:	8a 02                	mov    (%edx),%al
  800a77:	3c 20                	cmp    $0x20,%al
  800a79:	74 f9                	je     800a74 <strtol+0xe>
  800a7b:	3c 09                	cmp    $0x9,%al
  800a7d:	74 f5                	je     800a74 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a7f:	3c 2b                	cmp    $0x2b,%al
  800a81:	75 08                	jne    800a8b <strtol+0x25>
		s++;
  800a83:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a84:	bf 00 00 00 00       	mov    $0x0,%edi
  800a89:	eb 13                	jmp    800a9e <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a8b:	3c 2d                	cmp    $0x2d,%al
  800a8d:	75 0a                	jne    800a99 <strtol+0x33>
		s++, neg = 1;
  800a8f:	8d 52 01             	lea    0x1(%edx),%edx
  800a92:	bf 01 00 00 00       	mov    $0x1,%edi
  800a97:	eb 05                	jmp    800a9e <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a99:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a9e:	85 db                	test   %ebx,%ebx
  800aa0:	74 05                	je     800aa7 <strtol+0x41>
  800aa2:	83 fb 10             	cmp    $0x10,%ebx
  800aa5:	75 28                	jne    800acf <strtol+0x69>
  800aa7:	8a 02                	mov    (%edx),%al
  800aa9:	3c 30                	cmp    $0x30,%al
  800aab:	75 10                	jne    800abd <strtol+0x57>
  800aad:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800ab1:	75 0a                	jne    800abd <strtol+0x57>
		s += 2, base = 16;
  800ab3:	83 c2 02             	add    $0x2,%edx
  800ab6:	bb 10 00 00 00       	mov    $0x10,%ebx
  800abb:	eb 12                	jmp    800acf <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800abd:	85 db                	test   %ebx,%ebx
  800abf:	75 0e                	jne    800acf <strtol+0x69>
  800ac1:	3c 30                	cmp    $0x30,%al
  800ac3:	75 05                	jne    800aca <strtol+0x64>
		s++, base = 8;
  800ac5:	42                   	inc    %edx
  800ac6:	b3 08                	mov    $0x8,%bl
  800ac8:	eb 05                	jmp    800acf <strtol+0x69>
	else if (base == 0)
		base = 10;
  800aca:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800acf:	b8 00 00 00 00       	mov    $0x0,%eax
  800ad4:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800ad6:	8a 0a                	mov    (%edx),%cl
  800ad8:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800adb:	80 fb 09             	cmp    $0x9,%bl
  800ade:	77 08                	ja     800ae8 <strtol+0x82>
			dig = *s - '0';
  800ae0:	0f be c9             	movsbl %cl,%ecx
  800ae3:	83 e9 30             	sub    $0x30,%ecx
  800ae6:	eb 1e                	jmp    800b06 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800ae8:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800aeb:	80 fb 19             	cmp    $0x19,%bl
  800aee:	77 08                	ja     800af8 <strtol+0x92>
			dig = *s - 'a' + 10;
  800af0:	0f be c9             	movsbl %cl,%ecx
  800af3:	83 e9 57             	sub    $0x57,%ecx
  800af6:	eb 0e                	jmp    800b06 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800af8:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800afb:	80 fb 19             	cmp    $0x19,%bl
  800afe:	77 13                	ja     800b13 <strtol+0xad>
			dig = *s - 'A' + 10;
  800b00:	0f be c9             	movsbl %cl,%ecx
  800b03:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800b06:	39 f1                	cmp    %esi,%ecx
  800b08:	7d 0d                	jge    800b17 <strtol+0xb1>
			break;
		s++, val = (val * base) + dig;
  800b0a:	42                   	inc    %edx
  800b0b:	0f af c6             	imul   %esi,%eax
  800b0e:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  800b11:	eb c3                	jmp    800ad6 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800b13:	89 c1                	mov    %eax,%ecx
  800b15:	eb 02                	jmp    800b19 <strtol+0xb3>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800b17:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800b19:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b1d:	74 05                	je     800b24 <strtol+0xbe>
		*endptr = (char *) s;
  800b1f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800b22:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800b24:	85 ff                	test   %edi,%edi
  800b26:	74 04                	je     800b2c <strtol+0xc6>
  800b28:	89 c8                	mov    %ecx,%eax
  800b2a:	f7 d8                	neg    %eax
}
  800b2c:	5b                   	pop    %ebx
  800b2d:	5e                   	pop    %esi
  800b2e:	5f                   	pop    %edi
  800b2f:	c9                   	leave  
  800b30:	c3                   	ret    
  800b31:	00 00                	add    %al,(%eax)
	...

00800b34 <syscall>:
	return ret;
}

static int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800b34:	55                   	push   %ebp
  800b35:	89 e5                	mov    %esp,%ebp
  800b37:	57                   	push   %edi
  800b38:	56                   	push   %esi
  800b39:	53                   	push   %ebx
  800b3a:	83 ec 1c             	sub    $0x1c,%esp
  800b3d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800b40:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800b43:	89 ca                	mov    %ecx,%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b45:	8b 75 14             	mov    0x14(%ebp),%esi
  800b48:	8b 7d 10             	mov    0x10(%ebp),%edi
  800b4b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800b4e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b51:	cd 30                	int    $0x30
  800b53:	89 c2                	mov    %eax,%edx
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b55:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800b59:	74 1c                	je     800b77 <syscall+0x43>
  800b5b:	85 c0                	test   %eax,%eax
  800b5d:	7e 18                	jle    800b77 <syscall+0x43>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b5f:	83 ec 0c             	sub    $0xc,%esp
  800b62:	50                   	push   %eax
  800b63:	ff 75 e4             	pushl  -0x1c(%ebp)
  800b66:	68 24 13 80 00       	push   $0x801324
  800b6b:	6a 42                	push   $0x42
  800b6d:	68 41 13 80 00       	push   $0x801341
  800b72:	e8 b1 f5 ff ff       	call   800128 <_panic>

	return ret;
}
  800b77:	89 d0                	mov    %edx,%eax
  800b79:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b7c:	5b                   	pop    %ebx
  800b7d:	5e                   	pop    %esi
  800b7e:	5f                   	pop    %edi
  800b7f:	c9                   	leave  
  800b80:	c3                   	ret    

00800b81 <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{	
  800b81:	55                   	push   %ebp
  800b82:	89 e5                	mov    %esp,%ebp
  800b84:	83 ec 08             	sub    $0x8,%esp
	// my_sysenter(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
	// return;
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  800b87:	6a 00                	push   $0x0
  800b89:	6a 00                	push   $0x0
  800b8b:	6a 00                	push   $0x0
  800b8d:	ff 75 0c             	pushl  0xc(%ebp)
  800b90:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b93:	ba 00 00 00 00       	mov    $0x0,%edx
  800b98:	b8 00 00 00 00       	mov    $0x0,%eax
  800b9d:	e8 92 ff ff ff       	call   800b34 <syscall>
  800ba2:	83 c4 10             	add    $0x10,%esp
	return;
}
  800ba5:	c9                   	leave  
  800ba6:	c3                   	ret    

00800ba7 <sys_cgetc>:

int
sys_cgetc(void)
{
  800ba7:	55                   	push   %ebp
  800ba8:	89 e5                	mov    %esp,%ebp
  800baa:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_cgetc, 0, 0, 0, 0, 0, 0);
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  800bad:	6a 00                	push   $0x0
  800baf:	6a 00                	push   $0x0
  800bb1:	6a 00                	push   $0x0
  800bb3:	6a 00                	push   $0x0
  800bb5:	b9 00 00 00 00       	mov    $0x0,%ecx
  800bba:	ba 00 00 00 00       	mov    $0x0,%edx
  800bbf:	b8 01 00 00 00       	mov    $0x1,%eax
  800bc4:	e8 6b ff ff ff       	call   800b34 <syscall>
}
  800bc9:	c9                   	leave  
  800bca:	c3                   	ret    

00800bcb <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800bcb:	55                   	push   %ebp
  800bcc:	89 e5                	mov    %esp,%ebp
  800bce:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  800bd1:	6a 00                	push   $0x0
  800bd3:	6a 00                	push   $0x0
  800bd5:	6a 00                	push   $0x0
  800bd7:	6a 00                	push   $0x0
  800bd9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800bdc:	ba 01 00 00 00       	mov    $0x1,%edx
  800be1:	b8 03 00 00 00       	mov    $0x3,%eax
  800be6:	e8 49 ff ff ff       	call   800b34 <syscall>
}
  800beb:	c9                   	leave  
  800bec:	c3                   	ret    

00800bed <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800bed:	55                   	push   %ebp
  800bee:	89 e5                	mov    %esp,%ebp
  800bf0:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_getenvid, 0, 0, 0, 0, 0, 0);
	return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  800bf3:	6a 00                	push   $0x0
  800bf5:	6a 00                	push   $0x0
  800bf7:	6a 00                	push   $0x0
  800bf9:	6a 00                	push   $0x0
  800bfb:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c00:	ba 00 00 00 00       	mov    $0x0,%edx
  800c05:	b8 02 00 00 00       	mov    $0x2,%eax
  800c0a:	e8 25 ff ff ff       	call   800b34 <syscall>
}
  800c0f:	c9                   	leave  
  800c10:	c3                   	ret    

00800c11 <sys_yield>:

void
sys_yield(void)
{
  800c11:	55                   	push   %ebp
  800c12:	89 e5                	mov    %esp,%ebp
  800c14:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  800c17:	6a 00                	push   $0x0
  800c19:	6a 00                	push   $0x0
  800c1b:	6a 00                	push   $0x0
  800c1d:	6a 00                	push   $0x0
  800c1f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c24:	ba 00 00 00 00       	mov    $0x0,%edx
  800c29:	b8 0a 00 00 00       	mov    $0xa,%eax
  800c2e:	e8 01 ff ff ff       	call   800b34 <syscall>
  800c33:	83 c4 10             	add    $0x10,%esp
}
  800c36:	c9                   	leave  
  800c37:	c3                   	ret    

00800c38 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c38:	55                   	push   %ebp
  800c39:	89 e5                	mov    %esp,%ebp
  800c3b:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  800c3e:	6a 00                	push   $0x0
  800c40:	6a 00                	push   $0x0
  800c42:	ff 75 10             	pushl  0x10(%ebp)
  800c45:	ff 75 0c             	pushl  0xc(%ebp)
  800c48:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c4b:	ba 01 00 00 00       	mov    $0x1,%edx
  800c50:	b8 04 00 00 00       	mov    $0x4,%eax
  800c55:	e8 da fe ff ff       	call   800b34 <syscall>
}
  800c5a:	c9                   	leave  
  800c5b:	c3                   	ret    

00800c5c <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c5c:	55                   	push   %ebp
  800c5d:	89 e5                	mov    %esp,%ebp
  800c5f:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
  800c62:	ff 75 18             	pushl  0x18(%ebp)
  800c65:	ff 75 14             	pushl  0x14(%ebp)
  800c68:	ff 75 10             	pushl  0x10(%ebp)
  800c6b:	ff 75 0c             	pushl  0xc(%ebp)
  800c6e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c71:	ba 01 00 00 00       	mov    $0x1,%edx
  800c76:	b8 05 00 00 00       	mov    $0x5,%eax
  800c7b:	e8 b4 fe ff ff       	call   800b34 <syscall>
}
  800c80:	c9                   	leave  
  800c81:	c3                   	ret    

00800c82 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c82:	55                   	push   %ebp
  800c83:	89 e5                	mov    %esp,%ebp
  800c85:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  800c88:	6a 00                	push   $0x0
  800c8a:	6a 00                	push   $0x0
  800c8c:	6a 00                	push   $0x0
  800c8e:	ff 75 0c             	pushl  0xc(%ebp)
  800c91:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c94:	ba 01 00 00 00       	mov    $0x1,%edx
  800c99:	b8 06 00 00 00       	mov    $0x6,%eax
  800c9e:	e8 91 fe ff ff       	call   800b34 <syscall>
}
  800ca3:	c9                   	leave  
  800ca4:	c3                   	ret    

00800ca5 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800ca5:	55                   	push   %ebp
  800ca6:	89 e5                	mov    %esp,%ebp
  800ca8:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  800cab:	6a 00                	push   $0x0
  800cad:	6a 00                	push   $0x0
  800caf:	6a 00                	push   $0x0
  800cb1:	ff 75 0c             	pushl  0xc(%ebp)
  800cb4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800cb7:	ba 01 00 00 00       	mov    $0x1,%edx
  800cbc:	b8 08 00 00 00       	mov    $0x8,%eax
  800cc1:	e8 6e fe ff ff       	call   800b34 <syscall>
}
  800cc6:	c9                   	leave  
  800cc7:	c3                   	ret    

00800cc8 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800cc8:	55                   	push   %ebp
  800cc9:	89 e5                	mov    %esp,%ebp
  800ccb:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  800cce:	6a 00                	push   $0x0
  800cd0:	6a 00                	push   $0x0
  800cd2:	6a 00                	push   $0x0
  800cd4:	ff 75 0c             	pushl  0xc(%ebp)
  800cd7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800cda:	ba 01 00 00 00       	mov    $0x1,%edx
  800cdf:	b8 09 00 00 00       	mov    $0x9,%eax
  800ce4:	e8 4b fe ff ff       	call   800b34 <syscall>
}
  800ce9:	c9                   	leave  
  800cea:	c3                   	ret    

00800ceb <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800ceb:	55                   	push   %ebp
  800cec:	89 e5                	mov    %esp,%ebp
  800cee:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  800cf1:	6a 00                	push   $0x0
  800cf3:	ff 75 14             	pushl  0x14(%ebp)
  800cf6:	ff 75 10             	pushl  0x10(%ebp)
  800cf9:	ff 75 0c             	pushl  0xc(%ebp)
  800cfc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800cff:	ba 00 00 00 00       	mov    $0x0,%edx
  800d04:	b8 0b 00 00 00       	mov    $0xb,%eax
  800d09:	e8 26 fe ff ff       	call   800b34 <syscall>
}
  800d0e:	c9                   	leave  
  800d0f:	c3                   	ret    

00800d10 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d10:	55                   	push   %ebp
  800d11:	89 e5                	mov    %esp,%ebp
  800d13:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  800d16:	6a 00                	push   $0x0
  800d18:	6a 00                	push   $0x0
  800d1a:	6a 00                	push   $0x0
  800d1c:	6a 00                	push   $0x0
  800d1e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d21:	ba 01 00 00 00       	mov    $0x1,%edx
  800d26:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d2b:	e8 04 fe ff ff       	call   800b34 <syscall>
}
  800d30:	c9                   	leave  
  800d31:	c3                   	ret    

00800d32 <sys_set_priority>:

int
sys_set_priority(envid_t envid, uint32_t new_priority)
{
  800d32:	55                   	push   %ebp
  800d33:	89 e5                	mov    %esp,%ebp
  800d35:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_set_priority, 0, envid, new_priority, 0, 0, 0);
  800d38:	6a 00                	push   $0x0
  800d3a:	6a 00                	push   $0x0
  800d3c:	6a 00                	push   $0x0
  800d3e:	ff 75 0c             	pushl  0xc(%ebp)
  800d41:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d44:	ba 00 00 00 00       	mov    $0x0,%edx
  800d49:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d4e:	e8 e1 fd ff ff       	call   800b34 <syscall>
}
  800d53:	c9                   	leave  
  800d54:	c3                   	ret    
  800d55:	00 00                	add    %al,(%eax)
	...

00800d58 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  800d58:	55                   	push   %ebp
  800d59:	89 e5                	mov    %esp,%ebp
  800d5b:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  800d5e:	83 3d 08 20 80 00 00 	cmpl   $0x0,0x802008
  800d65:	75 52                	jne    800db9 <set_pgfault_handler+0x61>
		// First time through!	
		// LAB 4: Your code here.

		//int sys_page_alloc(envid_t envid, void *va, int perm)
		r = sys_page_alloc(0, (void*)(UXSTACKTOP - PGSIZE), PTE_U | PTE_W | PTE_P);
  800d67:	83 ec 04             	sub    $0x4,%esp
  800d6a:	6a 07                	push   $0x7
  800d6c:	68 00 f0 bf ee       	push   $0xeebff000
  800d71:	6a 00                	push   $0x0
  800d73:	e8 c0 fe ff ff       	call   800c38 <sys_page_alloc>
		if (r < 0) {
  800d78:	83 c4 10             	add    $0x10,%esp
  800d7b:	85 c0                	test   %eax,%eax
  800d7d:	79 12                	jns    800d91 <set_pgfault_handler+0x39>
			panic("sys_page_alloc error : %e\n", r);
  800d7f:	50                   	push   %eax
  800d80:	68 4f 13 80 00       	push   $0x80134f
  800d85:	6a 24                	push   $0x24
  800d87:	68 6a 13 80 00       	push   $0x80136a
  800d8c:	e8 97 f3 ff ff       	call   800128 <_panic>
		}

		// how to know envid, put 0, envid2env will help us to get curenv in syscall
		r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);		
  800d91:	83 ec 08             	sub    $0x8,%esp
  800d94:	68 c4 0d 80 00       	push   $0x800dc4
  800d99:	6a 00                	push   $0x0
  800d9b:	e8 28 ff ff ff       	call   800cc8 <sys_env_set_pgfault_upcall>
		if (r < 0) {
  800da0:	83 c4 10             	add    $0x10,%esp
  800da3:	85 c0                	test   %eax,%eax
  800da5:	79 12                	jns    800db9 <set_pgfault_handler+0x61>
			panic("sys_env_set_pgfault_upcall error : %e\n", r);
  800da7:	50                   	push   %eax
  800da8:	68 78 13 80 00       	push   $0x801378
  800dad:	6a 2a                	push   $0x2a
  800daf:	68 6a 13 80 00       	push   $0x80136a
  800db4:	e8 6f f3 ff ff       	call   800128 <_panic>
		}
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  800db9:	8b 45 08             	mov    0x8(%ebp),%eax
  800dbc:	a3 08 20 80 00       	mov    %eax,0x802008
}
  800dc1:	c9                   	leave  
  800dc2:	c3                   	ret    
	...

00800dc4 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  800dc4:	54                   	push   %esp
	movl _pgfault_handler, %eax
  800dc5:	a1 08 20 80 00       	mov    0x802008,%eax
	call *%eax
  800dca:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  800dcc:	83 c4 04             	add    $0x4,%esp
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	
	// fix old esp
	movl 0x30(%esp), %eax
  800dcf:	8b 44 24 30          	mov    0x30(%esp),%eax
	subl $0x4, %eax
  800dd3:	83 e8 04             	sub    $0x4,%eax
	movl %eax, 0x30(%esp)
  800dd6:	89 44 24 30          	mov    %eax,0x30(%esp)

	// set trap-time %eip
	movl 0x28(%esp), %ebx
  800dda:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	movl %ebx, (%eax)
  800dde:	89 18                	mov    %ebx,(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $0x08, %esp 	// ignore err_code and fault_va
  800de0:	83 c4 08             	add    $0x8,%esp
	popal 				// restore registers
  800de3:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x04, %esp 	// ignore eip 
  800de4:	83 c4 04             	add    $0x4,%esp
	popfl				// modify eflags
  800de7:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  800de8:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  800de9:	c3                   	ret    
	...

00800dec <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  800dec:	55                   	push   %ebp
  800ded:	89 e5                	mov    %esp,%ebp
  800def:	57                   	push   %edi
  800df0:	56                   	push   %esi
  800df1:	83 ec 10             	sub    $0x10,%esp
  800df4:	8b 7d 08             	mov    0x8(%ebp),%edi
  800df7:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  800dfa:	89 7d f0             	mov    %edi,-0x10(%ebp)
  800dfd:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  800e00:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  800e03:	8b 45 14             	mov    0x14(%ebp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800e06:	85 c0                	test   %eax,%eax
  800e08:	75 2e                	jne    800e38 <__udivdi3+0x4c>
    {
      if (d0 > n1)
  800e0a:	39 f1                	cmp    %esi,%ecx
  800e0c:	77 5a                	ja     800e68 <__udivdi3+0x7c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  800e0e:	85 c9                	test   %ecx,%ecx
  800e10:	75 0b                	jne    800e1d <__udivdi3+0x31>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  800e12:	b8 01 00 00 00       	mov    $0x1,%eax
  800e17:	31 d2                	xor    %edx,%edx
  800e19:	f7 f1                	div    %ecx
  800e1b:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  800e1d:	31 d2                	xor    %edx,%edx
  800e1f:	89 f0                	mov    %esi,%eax
  800e21:	f7 f1                	div    %ecx
  800e23:	89 c6                	mov    %eax,%esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800e25:	89 f8                	mov    %edi,%eax
  800e27:	f7 f1                	div    %ecx
  800e29:	89 c7                	mov    %eax,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800e2b:	89 f8                	mov    %edi,%eax
  800e2d:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800e2f:	83 c4 10             	add    $0x10,%esp
  800e32:	5e                   	pop    %esi
  800e33:	5f                   	pop    %edi
  800e34:	c9                   	leave  
  800e35:	c3                   	ret    
  800e36:	66 90                	xchg   %ax,%ax
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800e38:	39 f0                	cmp    %esi,%eax
  800e3a:	77 1c                	ja     800e58 <__udivdi3+0x6c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  800e3c:	0f bd f8             	bsr    %eax,%edi
	  if (bm == 0)
  800e3f:	83 f7 1f             	xor    $0x1f,%edi
  800e42:	75 3c                	jne    800e80 <__udivdi3+0x94>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800e44:	39 f0                	cmp    %esi,%eax
  800e46:	0f 82 90 00 00 00    	jb     800edc <__udivdi3+0xf0>
  800e4c:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800e4f:	39 55 f4             	cmp    %edx,-0xc(%ebp)
  800e52:	0f 86 84 00 00 00    	jbe    800edc <__udivdi3+0xf0>
  800e58:	31 f6                	xor    %esi,%esi
  800e5a:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800e5c:	89 f8                	mov    %edi,%eax
  800e5e:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800e60:	83 c4 10             	add    $0x10,%esp
  800e63:	5e                   	pop    %esi
  800e64:	5f                   	pop    %edi
  800e65:	c9                   	leave  
  800e66:	c3                   	ret    
  800e67:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800e68:	89 f2                	mov    %esi,%edx
  800e6a:	89 f8                	mov    %edi,%eax
  800e6c:	f7 f1                	div    %ecx
  800e6e:	89 c7                	mov    %eax,%edi
  800e70:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800e72:	89 f8                	mov    %edi,%eax
  800e74:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800e76:	83 c4 10             	add    $0x10,%esp
  800e79:	5e                   	pop    %esi
  800e7a:	5f                   	pop    %edi
  800e7b:	c9                   	leave  
  800e7c:	c3                   	ret    
  800e7d:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  800e80:	89 f9                	mov    %edi,%ecx
  800e82:	d3 e0                	shl    %cl,%eax
  800e84:	89 45 e8             	mov    %eax,-0x18(%ebp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  800e87:	b8 20 00 00 00       	mov    $0x20,%eax
  800e8c:	29 f8                	sub    %edi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  800e8e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800e91:	88 c1                	mov    %al,%cl
  800e93:	d3 ea                	shr    %cl,%edx
  800e95:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  800e98:	09 ca                	or     %ecx,%edx
  800e9a:	89 55 ec             	mov    %edx,-0x14(%ebp)
	      d0 = d0 << bm;
  800e9d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800ea0:	89 f9                	mov    %edi,%ecx
  800ea2:	d3 e2                	shl    %cl,%edx
  800ea4:	89 55 f4             	mov    %edx,-0xc(%ebp)
	      n2 = n1 >> b;
  800ea7:	89 f2                	mov    %esi,%edx
  800ea9:	88 c1                	mov    %al,%cl
  800eab:	d3 ea                	shr    %cl,%edx
  800ead:	89 55 e8             	mov    %edx,-0x18(%ebp)
	      n1 = (n1 << bm) | (n0 >> b);
  800eb0:	89 f2                	mov    %esi,%edx
  800eb2:	89 f9                	mov    %edi,%ecx
  800eb4:	d3 e2                	shl    %cl,%edx
  800eb6:	8b 75 f0             	mov    -0x10(%ebp),%esi
  800eb9:	88 c1                	mov    %al,%cl
  800ebb:	d3 ee                	shr    %cl,%esi
  800ebd:	09 d6                	or     %edx,%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  800ebf:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  800ec2:	89 f0                	mov    %esi,%eax
  800ec4:	89 ca                	mov    %ecx,%edx
  800ec6:	f7 75 ec             	divl   -0x14(%ebp)
  800ec9:	89 d1                	mov    %edx,%ecx
  800ecb:	89 c6                	mov    %eax,%esi
	      umul_ppmm (m1, m0, q0, d0);
  800ecd:	f7 65 f4             	mull   -0xc(%ebp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800ed0:	39 d1                	cmp    %edx,%ecx
  800ed2:	72 28                	jb     800efc <__udivdi3+0x110>
  800ed4:	74 1a                	je     800ef0 <__udivdi3+0x104>
  800ed6:	89 f7                	mov    %esi,%edi
  800ed8:	31 f6                	xor    %esi,%esi
  800eda:	eb 80                	jmp    800e5c <__udivdi3+0x70>
	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  800edc:	31 f6                	xor    %esi,%esi
  800ede:	bf 01 00 00 00       	mov    $0x1,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800ee3:	89 f8                	mov    %edi,%eax
  800ee5:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800ee7:	83 c4 10             	add    $0x10,%esp
  800eea:	5e                   	pop    %esi
  800eeb:	5f                   	pop    %edi
  800eec:	c9                   	leave  
  800eed:	c3                   	ret    
  800eee:	66 90                	xchg   %ax,%ax

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  800ef0:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800ef3:	89 f9                	mov    %edi,%ecx
  800ef5:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800ef7:	39 c2                	cmp    %eax,%edx
  800ef9:	73 db                	jae    800ed6 <__udivdi3+0xea>
  800efb:	90                   	nop
		{
		  q0--;
  800efc:	8d 7e ff             	lea    -0x1(%esi),%edi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  800eff:	31 f6                	xor    %esi,%esi
  800f01:	e9 56 ff ff ff       	jmp    800e5c <__udivdi3+0x70>
	...

00800f08 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  800f08:	55                   	push   %ebp
  800f09:	89 e5                	mov    %esp,%ebp
  800f0b:	57                   	push   %edi
  800f0c:	56                   	push   %esi
  800f0d:	83 ec 20             	sub    $0x20,%esp
  800f10:	8b 45 08             	mov    0x8(%ebp),%eax
  800f13:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  800f16:	89 45 e8             	mov    %eax,-0x18(%ebp)
  800f19:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  800f1c:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  800f1f:	8b 7d 14             	mov    0x14(%ebp),%edi
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  800f22:	89 45 f0             	mov    %eax,-0x10(%ebp)
  n1 = nn.s.high;
  800f25:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800f27:	85 ff                	test   %edi,%edi
  800f29:	75 15                	jne    800f40 <__umoddi3+0x38>
    {
      if (d0 > n1)
  800f2b:	39 f1                	cmp    %esi,%ecx
  800f2d:	0f 86 99 00 00 00    	jbe    800fcc <__umoddi3+0xc4>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800f33:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  800f35:	89 d0                	mov    %edx,%eax
  800f37:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800f39:	83 c4 20             	add    $0x20,%esp
  800f3c:	5e                   	pop    %esi
  800f3d:	5f                   	pop    %edi
  800f3e:	c9                   	leave  
  800f3f:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800f40:	39 f7                	cmp    %esi,%edi
  800f42:	0f 87 a4 00 00 00    	ja     800fec <__umoddi3+0xe4>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  800f48:	0f bd c7             	bsr    %edi,%eax
	  if (bm == 0)
  800f4b:	83 f0 1f             	xor    $0x1f,%eax
  800f4e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800f51:	0f 84 a1 00 00 00    	je     800ff8 <__umoddi3+0xf0>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  800f57:	89 f8                	mov    %edi,%eax
  800f59:	8a 4d ec             	mov    -0x14(%ebp),%cl
  800f5c:	d3 e0                	shl    %cl,%eax
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  800f5e:	bf 20 00 00 00       	mov    $0x20,%edi
  800f63:	2b 7d ec             	sub    -0x14(%ebp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  800f66:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800f69:	89 f9                	mov    %edi,%ecx
  800f6b:	d3 ea                	shr    %cl,%edx
  800f6d:	09 c2                	or     %eax,%edx
  800f6f:	89 55 f0             	mov    %edx,-0x10(%ebp)
	      d0 = d0 << bm;
  800f72:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800f75:	8a 4d ec             	mov    -0x14(%ebp),%cl
  800f78:	d3 e0                	shl    %cl,%eax
  800f7a:	89 45 f4             	mov    %eax,-0xc(%ebp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  800f7d:	89 f2                	mov    %esi,%edx
  800f7f:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  800f81:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800f84:	d3 e0                	shl    %cl,%eax
  800f86:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  800f89:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800f8c:	89 f9                	mov    %edi,%ecx
  800f8e:	d3 e8                	shr    %cl,%eax
  800f90:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  800f92:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  800f94:	89 f2                	mov    %esi,%edx
  800f96:	f7 75 f0             	divl   -0x10(%ebp)
  800f99:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  800f9b:	f7 65 f4             	mull   -0xc(%ebp)
  800f9e:	89 55 e8             	mov    %edx,-0x18(%ebp)
  800fa1:	89 c1                	mov    %eax,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800fa3:	39 d6                	cmp    %edx,%esi
  800fa5:	72 71                	jb     801018 <__umoddi3+0x110>
  800fa7:	74 7f                	je     801028 <__umoddi3+0x120>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  800fa9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800fac:	29 c8                	sub    %ecx,%eax
  800fae:	19 d6                	sbb    %edx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  800fb0:	8a 4d ec             	mov    -0x14(%ebp),%cl
  800fb3:	d3 e8                	shr    %cl,%eax
  800fb5:	89 f2                	mov    %esi,%edx
  800fb7:	89 f9                	mov    %edi,%ecx
  800fb9:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  800fbb:	09 d0                	or     %edx,%eax
  800fbd:	89 f2                	mov    %esi,%edx
  800fbf:	8a 4d ec             	mov    -0x14(%ebp),%cl
  800fc2:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800fc4:	83 c4 20             	add    $0x20,%esp
  800fc7:	5e                   	pop    %esi
  800fc8:	5f                   	pop    %edi
  800fc9:	c9                   	leave  
  800fca:	c3                   	ret    
  800fcb:	90                   	nop
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  800fcc:	85 c9                	test   %ecx,%ecx
  800fce:	75 0b                	jne    800fdb <__umoddi3+0xd3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  800fd0:	b8 01 00 00 00       	mov    $0x1,%eax
  800fd5:	31 d2                	xor    %edx,%edx
  800fd7:	f7 f1                	div    %ecx
  800fd9:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  800fdb:	89 f0                	mov    %esi,%eax
  800fdd:	31 d2                	xor    %edx,%edx
  800fdf:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800fe1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800fe4:	f7 f1                	div    %ecx
  800fe6:	e9 4a ff ff ff       	jmp    800f35 <__umoddi3+0x2d>
  800feb:	90                   	nop
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  800fec:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800fee:	83 c4 20             	add    $0x20,%esp
  800ff1:	5e                   	pop    %esi
  800ff2:	5f                   	pop    %edi
  800ff3:	c9                   	leave  
  800ff4:	c3                   	ret    
  800ff5:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800ff8:	39 f7                	cmp    %esi,%edi
  800ffa:	72 05                	jb     801001 <__umoddi3+0xf9>
  800ffc:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
  800fff:	77 0c                	ja     80100d <__umoddi3+0x105>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  801001:	89 f2                	mov    %esi,%edx
  801003:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801006:	29 c8                	sub    %ecx,%eax
  801008:	19 fa                	sbb    %edi,%edx
  80100a:	89 45 f0             	mov    %eax,-0x10(%ebp)

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  80100d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801010:	83 c4 20             	add    $0x20,%esp
  801013:	5e                   	pop    %esi
  801014:	5f                   	pop    %edi
  801015:	c9                   	leave  
  801016:	c3                   	ret    
  801017:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  801018:	8b 55 e8             	mov    -0x18(%ebp),%edx
  80101b:	89 c1                	mov    %eax,%ecx
  80101d:	2b 4d f4             	sub    -0xc(%ebp),%ecx
  801020:	1b 55 f0             	sbb    -0x10(%ebp),%edx
  801023:	eb 84                	jmp    800fa9 <__umoddi3+0xa1>
  801025:	8d 76 00             	lea    0x0(%esi),%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801028:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  80102b:	72 eb                	jb     801018 <__umoddi3+0x110>
  80102d:	89 f2                	mov    %esi,%edx
  80102f:	e9 75 ff ff ff       	jmp    800fa9 <__umoddi3+0xa1>
