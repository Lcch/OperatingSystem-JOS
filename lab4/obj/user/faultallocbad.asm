
obj/user/faultallocbad:     file format elf32-i386


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
  80002c:	e8 87 00 00 00       	call   8000b8 <libmain>
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
  800041:	68 a0 0f 80 00       	push   $0x800fa0
  800046:	e8 a9 01 00 00       	call   8001f4 <cprintf>
	if ((r = sys_page_alloc(0, ROUNDDOWN(addr, PGSIZE),
  80004b:	83 c4 0c             	add    $0xc,%esp
  80004e:	6a 07                	push   $0x7
  800050:	89 d8                	mov    %ebx,%eax
  800052:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800057:	50                   	push   %eax
  800058:	6a 00                	push   $0x0
  80005a:	e8 cd 0b 00 00       	call   800c2c <sys_page_alloc>
  80005f:	83 c4 10             	add    $0x10,%esp
  800062:	85 c0                	test   %eax,%eax
  800064:	79 16                	jns    80007c <handler+0x48>
				PTE_P|PTE_U|PTE_W)) < 0)
		panic("allocating at %x in page fault handler: %e", addr, r);
  800066:	83 ec 0c             	sub    $0xc,%esp
  800069:	50                   	push   %eax
  80006a:	53                   	push   %ebx
  80006b:	68 c0 0f 80 00       	push   $0x800fc0
  800070:	6a 0f                	push   $0xf
  800072:	68 aa 0f 80 00       	push   $0x800faa
  800077:	e8 a0 00 00 00       	call   80011c <_panic>
	snprintf((char*) addr, 100, "this string was faulted in at %x", addr);
  80007c:	53                   	push   %ebx
  80007d:	68 ec 0f 80 00       	push   $0x800fec
  800082:	6a 64                	push   $0x64
  800084:	53                   	push   %ebx
  800085:	e8 b2 06 00 00       	call   80073c <snprintf>
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
  80009d:	e8 86 0c 00 00       	call   800d28 <set_pgfault_handler>
	sys_cputs((char*)0xDEADBEEF, 4);
  8000a2:	83 c4 08             	add    $0x8,%esp
  8000a5:	6a 04                	push   $0x4
  8000a7:	68 ef be ad de       	push   $0xdeadbeef
  8000ac:	e8 c4 0a 00 00       	call   800b75 <sys_cputs>
  8000b1:	83 c4 10             	add    $0x10,%esp
}
  8000b4:	c9                   	leave  
  8000b5:	c3                   	ret    
	...

008000b8 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000b8:	55                   	push   %ebp
  8000b9:	89 e5                	mov    %esp,%ebp
  8000bb:	56                   	push   %esi
  8000bc:	53                   	push   %ebx
  8000bd:	8b 75 08             	mov    0x8(%ebp),%esi
  8000c0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs + ENVX(sys_getenvid());
  8000c3:	e8 19 0b 00 00       	call   800be1 <sys_getenvid>
  8000c8:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000cd:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  8000d4:	c1 e0 07             	shl    $0x7,%eax
  8000d7:	29 d0                	sub    %edx,%eax
  8000d9:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000de:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000e3:	85 f6                	test   %esi,%esi
  8000e5:	7e 07                	jle    8000ee <libmain+0x36>
		binaryname = argv[0];
  8000e7:	8b 03                	mov    (%ebx),%eax
  8000e9:	a3 00 20 80 00       	mov    %eax,0x802000
	// call user main routine
	umain(argc, argv);
  8000ee:	83 ec 08             	sub    $0x8,%esp
  8000f1:	53                   	push   %ebx
  8000f2:	56                   	push   %esi
  8000f3:	e8 9a ff ff ff       	call   800092 <umain>

	// exit gracefully
	exit();
  8000f8:	e8 0b 00 00 00       	call   800108 <exit>
  8000fd:	83 c4 10             	add    $0x10,%esp
}
  800100:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800103:	5b                   	pop    %ebx
  800104:	5e                   	pop    %esi
  800105:	c9                   	leave  
  800106:	c3                   	ret    
	...

00800108 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800108:	55                   	push   %ebp
  800109:	89 e5                	mov    %esp,%ebp
  80010b:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  80010e:	6a 00                	push   $0x0
  800110:	e8 aa 0a 00 00       	call   800bbf <sys_env_destroy>
  800115:	83 c4 10             	add    $0x10,%esp
}
  800118:	c9                   	leave  
  800119:	c3                   	ret    
	...

0080011c <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80011c:	55                   	push   %ebp
  80011d:	89 e5                	mov    %esp,%ebp
  80011f:	56                   	push   %esi
  800120:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800121:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800124:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  80012a:	e8 b2 0a 00 00       	call   800be1 <sys_getenvid>
  80012f:	83 ec 0c             	sub    $0xc,%esp
  800132:	ff 75 0c             	pushl  0xc(%ebp)
  800135:	ff 75 08             	pushl  0x8(%ebp)
  800138:	53                   	push   %ebx
  800139:	50                   	push   %eax
  80013a:	68 18 10 80 00       	push   $0x801018
  80013f:	e8 b0 00 00 00       	call   8001f4 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800144:	83 c4 18             	add    $0x18,%esp
  800147:	56                   	push   %esi
  800148:	ff 75 10             	pushl  0x10(%ebp)
  80014b:	e8 53 00 00 00       	call   8001a3 <vcprintf>
	cprintf("\n");
  800150:	c7 04 24 a8 0f 80 00 	movl   $0x800fa8,(%esp)
  800157:	e8 98 00 00 00       	call   8001f4 <cprintf>
  80015c:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80015f:	cc                   	int3   
  800160:	eb fd                	jmp    80015f <_panic+0x43>
	...

00800164 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800164:	55                   	push   %ebp
  800165:	89 e5                	mov    %esp,%ebp
  800167:	53                   	push   %ebx
  800168:	83 ec 04             	sub    $0x4,%esp
  80016b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80016e:	8b 03                	mov    (%ebx),%eax
  800170:	8b 55 08             	mov    0x8(%ebp),%edx
  800173:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  800177:	40                   	inc    %eax
  800178:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  80017a:	3d ff 00 00 00       	cmp    $0xff,%eax
  80017f:	75 1a                	jne    80019b <putch+0x37>
		sys_cputs(b->buf, b->idx);
  800181:	83 ec 08             	sub    $0x8,%esp
  800184:	68 ff 00 00 00       	push   $0xff
  800189:	8d 43 08             	lea    0x8(%ebx),%eax
  80018c:	50                   	push   %eax
  80018d:	e8 e3 09 00 00       	call   800b75 <sys_cputs>
		b->idx = 0;
  800192:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800198:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80019b:	ff 43 04             	incl   0x4(%ebx)
}
  80019e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001a1:	c9                   	leave  
  8001a2:	c3                   	ret    

008001a3 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001a3:	55                   	push   %ebp
  8001a4:	89 e5                	mov    %esp,%ebp
  8001a6:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001ac:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001b3:	00 00 00 
	b.cnt = 0;
  8001b6:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001bd:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001c0:	ff 75 0c             	pushl  0xc(%ebp)
  8001c3:	ff 75 08             	pushl  0x8(%ebp)
  8001c6:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001cc:	50                   	push   %eax
  8001cd:	68 64 01 80 00       	push   $0x800164
  8001d2:	e8 82 01 00 00       	call   800359 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001d7:	83 c4 08             	add    $0x8,%esp
  8001da:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8001e0:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001e6:	50                   	push   %eax
  8001e7:	e8 89 09 00 00       	call   800b75 <sys_cputs>

	return b.cnt;
}
  8001ec:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001f2:	c9                   	leave  
  8001f3:	c3                   	ret    

008001f4 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001f4:	55                   	push   %ebp
  8001f5:	89 e5                	mov    %esp,%ebp
  8001f7:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001fa:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001fd:	50                   	push   %eax
  8001fe:	ff 75 08             	pushl  0x8(%ebp)
  800201:	e8 9d ff ff ff       	call   8001a3 <vcprintf>
	va_end(ap);

	return cnt;
}
  800206:	c9                   	leave  
  800207:	c3                   	ret    

00800208 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800208:	55                   	push   %ebp
  800209:	89 e5                	mov    %esp,%ebp
  80020b:	57                   	push   %edi
  80020c:	56                   	push   %esi
  80020d:	53                   	push   %ebx
  80020e:	83 ec 2c             	sub    $0x2c,%esp
  800211:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800214:	89 d6                	mov    %edx,%esi
  800216:	8b 45 08             	mov    0x8(%ebp),%eax
  800219:	8b 55 0c             	mov    0xc(%ebp),%edx
  80021c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80021f:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800222:	8b 45 10             	mov    0x10(%ebp),%eax
  800225:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800228:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80022b:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80022e:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  800235:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
  800238:	72 0c                	jb     800246 <printnum+0x3e>
  80023a:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  80023d:	76 07                	jbe    800246 <printnum+0x3e>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80023f:	4b                   	dec    %ebx
  800240:	85 db                	test   %ebx,%ebx
  800242:	7f 31                	jg     800275 <printnum+0x6d>
  800244:	eb 3f                	jmp    800285 <printnum+0x7d>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800246:	83 ec 0c             	sub    $0xc,%esp
  800249:	57                   	push   %edi
  80024a:	4b                   	dec    %ebx
  80024b:	53                   	push   %ebx
  80024c:	50                   	push   %eax
  80024d:	83 ec 08             	sub    $0x8,%esp
  800250:	ff 75 d4             	pushl  -0x2c(%ebp)
  800253:	ff 75 d0             	pushl  -0x30(%ebp)
  800256:	ff 75 dc             	pushl  -0x24(%ebp)
  800259:	ff 75 d8             	pushl  -0x28(%ebp)
  80025c:	e8 f7 0a 00 00       	call   800d58 <__udivdi3>
  800261:	83 c4 18             	add    $0x18,%esp
  800264:	52                   	push   %edx
  800265:	50                   	push   %eax
  800266:	89 f2                	mov    %esi,%edx
  800268:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80026b:	e8 98 ff ff ff       	call   800208 <printnum>
  800270:	83 c4 20             	add    $0x20,%esp
  800273:	eb 10                	jmp    800285 <printnum+0x7d>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800275:	83 ec 08             	sub    $0x8,%esp
  800278:	56                   	push   %esi
  800279:	57                   	push   %edi
  80027a:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80027d:	4b                   	dec    %ebx
  80027e:	83 c4 10             	add    $0x10,%esp
  800281:	85 db                	test   %ebx,%ebx
  800283:	7f f0                	jg     800275 <printnum+0x6d>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800285:	83 ec 08             	sub    $0x8,%esp
  800288:	56                   	push   %esi
  800289:	83 ec 04             	sub    $0x4,%esp
  80028c:	ff 75 d4             	pushl  -0x2c(%ebp)
  80028f:	ff 75 d0             	pushl  -0x30(%ebp)
  800292:	ff 75 dc             	pushl  -0x24(%ebp)
  800295:	ff 75 d8             	pushl  -0x28(%ebp)
  800298:	e8 d7 0b 00 00       	call   800e74 <__umoddi3>
  80029d:	83 c4 14             	add    $0x14,%esp
  8002a0:	0f be 80 3b 10 80 00 	movsbl 0x80103b(%eax),%eax
  8002a7:	50                   	push   %eax
  8002a8:	ff 55 e4             	call   *-0x1c(%ebp)
  8002ab:	83 c4 10             	add    $0x10,%esp
}
  8002ae:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002b1:	5b                   	pop    %ebx
  8002b2:	5e                   	pop    %esi
  8002b3:	5f                   	pop    %edi
  8002b4:	c9                   	leave  
  8002b5:	c3                   	ret    

008002b6 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002b6:	55                   	push   %ebp
  8002b7:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002b9:	83 fa 01             	cmp    $0x1,%edx
  8002bc:	7e 0e                	jle    8002cc <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8002be:	8b 10                	mov    (%eax),%edx
  8002c0:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002c3:	89 08                	mov    %ecx,(%eax)
  8002c5:	8b 02                	mov    (%edx),%eax
  8002c7:	8b 52 04             	mov    0x4(%edx),%edx
  8002ca:	eb 22                	jmp    8002ee <getuint+0x38>
	else if (lflag)
  8002cc:	85 d2                	test   %edx,%edx
  8002ce:	74 10                	je     8002e0 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8002d0:	8b 10                	mov    (%eax),%edx
  8002d2:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002d5:	89 08                	mov    %ecx,(%eax)
  8002d7:	8b 02                	mov    (%edx),%eax
  8002d9:	ba 00 00 00 00       	mov    $0x0,%edx
  8002de:	eb 0e                	jmp    8002ee <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8002e0:	8b 10                	mov    (%eax),%edx
  8002e2:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002e5:	89 08                	mov    %ecx,(%eax)
  8002e7:	8b 02                	mov    (%edx),%eax
  8002e9:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002ee:	c9                   	leave  
  8002ef:	c3                   	ret    

008002f0 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  8002f0:	55                   	push   %ebp
  8002f1:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002f3:	83 fa 01             	cmp    $0x1,%edx
  8002f6:	7e 0e                	jle    800306 <getint+0x16>
		return va_arg(*ap, long long);
  8002f8:	8b 10                	mov    (%eax),%edx
  8002fa:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002fd:	89 08                	mov    %ecx,(%eax)
  8002ff:	8b 02                	mov    (%edx),%eax
  800301:	8b 52 04             	mov    0x4(%edx),%edx
  800304:	eb 1a                	jmp    800320 <getint+0x30>
	else if (lflag)
  800306:	85 d2                	test   %edx,%edx
  800308:	74 0c                	je     800316 <getint+0x26>
		return va_arg(*ap, long);
  80030a:	8b 10                	mov    (%eax),%edx
  80030c:	8d 4a 04             	lea    0x4(%edx),%ecx
  80030f:	89 08                	mov    %ecx,(%eax)
  800311:	8b 02                	mov    (%edx),%eax
  800313:	99                   	cltd   
  800314:	eb 0a                	jmp    800320 <getint+0x30>
	else
		return va_arg(*ap, int);
  800316:	8b 10                	mov    (%eax),%edx
  800318:	8d 4a 04             	lea    0x4(%edx),%ecx
  80031b:	89 08                	mov    %ecx,(%eax)
  80031d:	8b 02                	mov    (%edx),%eax
  80031f:	99                   	cltd   
}
  800320:	c9                   	leave  
  800321:	c3                   	ret    

00800322 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800322:	55                   	push   %ebp
  800323:	89 e5                	mov    %esp,%ebp
  800325:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800328:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  80032b:	8b 10                	mov    (%eax),%edx
  80032d:	3b 50 04             	cmp    0x4(%eax),%edx
  800330:	73 08                	jae    80033a <sprintputch+0x18>
		*b->buf++ = ch;
  800332:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800335:	88 0a                	mov    %cl,(%edx)
  800337:	42                   	inc    %edx
  800338:	89 10                	mov    %edx,(%eax)
}
  80033a:	c9                   	leave  
  80033b:	c3                   	ret    

0080033c <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80033c:	55                   	push   %ebp
  80033d:	89 e5                	mov    %esp,%ebp
  80033f:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800342:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800345:	50                   	push   %eax
  800346:	ff 75 10             	pushl  0x10(%ebp)
  800349:	ff 75 0c             	pushl  0xc(%ebp)
  80034c:	ff 75 08             	pushl  0x8(%ebp)
  80034f:	e8 05 00 00 00       	call   800359 <vprintfmt>
	va_end(ap);
  800354:	83 c4 10             	add    $0x10,%esp
}
  800357:	c9                   	leave  
  800358:	c3                   	ret    

00800359 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800359:	55                   	push   %ebp
  80035a:	89 e5                	mov    %esp,%ebp
  80035c:	57                   	push   %edi
  80035d:	56                   	push   %esi
  80035e:	53                   	push   %ebx
  80035f:	83 ec 2c             	sub    $0x2c,%esp
  800362:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800365:	8b 75 10             	mov    0x10(%ebp),%esi
  800368:	eb 13                	jmp    80037d <vprintfmt+0x24>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80036a:	85 c0                	test   %eax,%eax
  80036c:	0f 84 6d 03 00 00    	je     8006df <vprintfmt+0x386>
				return;
			putch(ch, putdat);
  800372:	83 ec 08             	sub    $0x8,%esp
  800375:	57                   	push   %edi
  800376:	50                   	push   %eax
  800377:	ff 55 08             	call   *0x8(%ebp)
  80037a:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80037d:	0f b6 06             	movzbl (%esi),%eax
  800380:	46                   	inc    %esi
  800381:	83 f8 25             	cmp    $0x25,%eax
  800384:	75 e4                	jne    80036a <vprintfmt+0x11>
  800386:	c6 45 dc 20          	movb   $0x20,-0x24(%ebp)
  80038a:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  800391:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  800398:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  80039f:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003a4:	eb 28                	jmp    8003ce <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003a6:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  8003a8:	c6 45 dc 2d          	movb   $0x2d,-0x24(%ebp)
  8003ac:	eb 20                	jmp    8003ce <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ae:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8003b0:	c6 45 dc 30          	movb   $0x30,-0x24(%ebp)
  8003b4:	eb 18                	jmp    8003ce <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003b6:	89 de                	mov    %ebx,%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  8003b8:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8003bf:	eb 0d                	jmp    8003ce <vprintfmt+0x75>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  8003c1:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8003c4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003c7:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ce:	8a 06                	mov    (%esi),%al
  8003d0:	0f b6 d0             	movzbl %al,%edx
  8003d3:	8d 5e 01             	lea    0x1(%esi),%ebx
  8003d6:	83 e8 23             	sub    $0x23,%eax
  8003d9:	3c 55                	cmp    $0x55,%al
  8003db:	0f 87 e0 02 00 00    	ja     8006c1 <vprintfmt+0x368>
  8003e1:	0f b6 c0             	movzbl %al,%eax
  8003e4:	ff 24 85 00 11 80 00 	jmp    *0x801100(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003eb:	83 ea 30             	sub    $0x30,%edx
  8003ee:	89 55 d4             	mov    %edx,-0x2c(%ebp)
				ch = *fmt;
  8003f1:	0f be 03             	movsbl (%ebx),%eax
				if (ch < '0' || ch > '9')
  8003f4:	8d 50 d0             	lea    -0x30(%eax),%edx
  8003f7:	83 fa 09             	cmp    $0x9,%edx
  8003fa:	77 44                	ja     800440 <vprintfmt+0xe7>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003fc:	89 de                	mov    %ebx,%esi
  8003fe:	8b 55 d4             	mov    -0x2c(%ebp),%edx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800401:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
  800402:	8d 14 92             	lea    (%edx,%edx,4),%edx
  800405:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
  800409:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  80040c:	8d 58 d0             	lea    -0x30(%eax),%ebx
  80040f:	83 fb 09             	cmp    $0x9,%ebx
  800412:	76 ed                	jbe    800401 <vprintfmt+0xa8>
  800414:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  800417:	eb 29                	jmp    800442 <vprintfmt+0xe9>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800419:	8b 45 14             	mov    0x14(%ebp),%eax
  80041c:	8d 50 04             	lea    0x4(%eax),%edx
  80041f:	89 55 14             	mov    %edx,0x14(%ebp)
  800422:	8b 00                	mov    (%eax),%eax
  800424:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800427:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800429:	eb 17                	jmp    800442 <vprintfmt+0xe9>

		case '.':
			if (width < 0)
  80042b:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80042f:	78 85                	js     8003b6 <vprintfmt+0x5d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800431:	89 de                	mov    %ebx,%esi
  800433:	eb 99                	jmp    8003ce <vprintfmt+0x75>
  800435:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800437:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  80043e:	eb 8e                	jmp    8003ce <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800440:	89 de                	mov    %ebx,%esi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  800442:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800446:	79 86                	jns    8003ce <vprintfmt+0x75>
  800448:	e9 74 ff ff ff       	jmp    8003c1 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80044d:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80044e:	89 de                	mov    %ebx,%esi
  800450:	e9 79 ff ff ff       	jmp    8003ce <vprintfmt+0x75>
  800455:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800458:	8b 45 14             	mov    0x14(%ebp),%eax
  80045b:	8d 50 04             	lea    0x4(%eax),%edx
  80045e:	89 55 14             	mov    %edx,0x14(%ebp)
  800461:	83 ec 08             	sub    $0x8,%esp
  800464:	57                   	push   %edi
  800465:	ff 30                	pushl  (%eax)
  800467:	ff 55 08             	call   *0x8(%ebp)
			break;
  80046a:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80046d:	8b 75 d8             	mov    -0x28(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800470:	e9 08 ff ff ff       	jmp    80037d <vprintfmt+0x24>
  800475:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  800478:	8b 45 14             	mov    0x14(%ebp),%eax
  80047b:	8d 50 04             	lea    0x4(%eax),%edx
  80047e:	89 55 14             	mov    %edx,0x14(%ebp)
  800481:	8b 00                	mov    (%eax),%eax
  800483:	85 c0                	test   %eax,%eax
  800485:	79 02                	jns    800489 <vprintfmt+0x130>
  800487:	f7 d8                	neg    %eax
  800489:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80048b:	83 f8 08             	cmp    $0x8,%eax
  80048e:	7f 0b                	jg     80049b <vprintfmt+0x142>
  800490:	8b 04 85 60 12 80 00 	mov    0x801260(,%eax,4),%eax
  800497:	85 c0                	test   %eax,%eax
  800499:	75 1a                	jne    8004b5 <vprintfmt+0x15c>
				printfmt(putch, putdat, "error %d", err);
  80049b:	52                   	push   %edx
  80049c:	68 53 10 80 00       	push   $0x801053
  8004a1:	57                   	push   %edi
  8004a2:	ff 75 08             	pushl  0x8(%ebp)
  8004a5:	e8 92 fe ff ff       	call   80033c <printfmt>
  8004aa:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004ad:	8b 75 d8             	mov    -0x28(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8004b0:	e9 c8 fe ff ff       	jmp    80037d <vprintfmt+0x24>
			else
				printfmt(putch, putdat, "%s", p);
  8004b5:	50                   	push   %eax
  8004b6:	68 5c 10 80 00       	push   $0x80105c
  8004bb:	57                   	push   %edi
  8004bc:	ff 75 08             	pushl  0x8(%ebp)
  8004bf:	e8 78 fe ff ff       	call   80033c <printfmt>
  8004c4:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004c7:	8b 75 d8             	mov    -0x28(%ebp),%esi
  8004ca:	e9 ae fe ff ff       	jmp    80037d <vprintfmt+0x24>
  8004cf:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  8004d2:	89 de                	mov    %ebx,%esi
  8004d4:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  8004d7:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004da:	8b 45 14             	mov    0x14(%ebp),%eax
  8004dd:	8d 50 04             	lea    0x4(%eax),%edx
  8004e0:	89 55 14             	mov    %edx,0x14(%ebp)
  8004e3:	8b 00                	mov    (%eax),%eax
  8004e5:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8004e8:	85 c0                	test   %eax,%eax
  8004ea:	75 07                	jne    8004f3 <vprintfmt+0x19a>
				p = "(null)";
  8004ec:	c7 45 d0 4c 10 80 00 	movl   $0x80104c,-0x30(%ebp)
			if (width > 0 && padc != '-')
  8004f3:	85 db                	test   %ebx,%ebx
  8004f5:	7e 42                	jle    800539 <vprintfmt+0x1e0>
  8004f7:	80 7d dc 2d          	cmpb   $0x2d,-0x24(%ebp)
  8004fb:	74 3c                	je     800539 <vprintfmt+0x1e0>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004fd:	83 ec 08             	sub    $0x8,%esp
  800500:	51                   	push   %ecx
  800501:	ff 75 d0             	pushl  -0x30(%ebp)
  800504:	e8 6f 02 00 00       	call   800778 <strnlen>
  800509:	29 c3                	sub    %eax,%ebx
  80050b:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80050e:	83 c4 10             	add    $0x10,%esp
  800511:	85 db                	test   %ebx,%ebx
  800513:	7e 24                	jle    800539 <vprintfmt+0x1e0>
					putch(padc, putdat);
  800515:	0f be 5d dc          	movsbl -0x24(%ebp),%ebx
  800519:	89 75 dc             	mov    %esi,-0x24(%ebp)
  80051c:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  80051f:	83 ec 08             	sub    $0x8,%esp
  800522:	57                   	push   %edi
  800523:	53                   	push   %ebx
  800524:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800527:	4e                   	dec    %esi
  800528:	83 c4 10             	add    $0x10,%esp
  80052b:	85 f6                	test   %esi,%esi
  80052d:	7f f0                	jg     80051f <vprintfmt+0x1c6>
  80052f:	8b 75 dc             	mov    -0x24(%ebp),%esi
  800532:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800539:	8b 55 d0             	mov    -0x30(%ebp),%edx
  80053c:	0f be 02             	movsbl (%edx),%eax
  80053f:	85 c0                	test   %eax,%eax
  800541:	75 47                	jne    80058a <vprintfmt+0x231>
  800543:	eb 37                	jmp    80057c <vprintfmt+0x223>
				if (altflag && (ch < ' ' || ch > '~'))
  800545:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800549:	74 16                	je     800561 <vprintfmt+0x208>
  80054b:	8d 50 e0             	lea    -0x20(%eax),%edx
  80054e:	83 fa 5e             	cmp    $0x5e,%edx
  800551:	76 0e                	jbe    800561 <vprintfmt+0x208>
					putch('?', putdat);
  800553:	83 ec 08             	sub    $0x8,%esp
  800556:	57                   	push   %edi
  800557:	6a 3f                	push   $0x3f
  800559:	ff 55 08             	call   *0x8(%ebp)
  80055c:	83 c4 10             	add    $0x10,%esp
  80055f:	eb 0b                	jmp    80056c <vprintfmt+0x213>
				else
					putch(ch, putdat);
  800561:	83 ec 08             	sub    $0x8,%esp
  800564:	57                   	push   %edi
  800565:	50                   	push   %eax
  800566:	ff 55 08             	call   *0x8(%ebp)
  800569:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80056c:	ff 4d e4             	decl   -0x1c(%ebp)
  80056f:	0f be 03             	movsbl (%ebx),%eax
  800572:	85 c0                	test   %eax,%eax
  800574:	74 03                	je     800579 <vprintfmt+0x220>
  800576:	43                   	inc    %ebx
  800577:	eb 1b                	jmp    800594 <vprintfmt+0x23b>
  800579:	8b 75 dc             	mov    -0x24(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80057c:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800580:	7f 1e                	jg     8005a0 <vprintfmt+0x247>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800582:	8b 75 d8             	mov    -0x28(%ebp),%esi
  800585:	e9 f3 fd ff ff       	jmp    80037d <vprintfmt+0x24>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80058a:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  80058d:	43                   	inc    %ebx
  80058e:	89 75 dc             	mov    %esi,-0x24(%ebp)
  800591:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  800594:	85 f6                	test   %esi,%esi
  800596:	78 ad                	js     800545 <vprintfmt+0x1ec>
  800598:	4e                   	dec    %esi
  800599:	79 aa                	jns    800545 <vprintfmt+0x1ec>
  80059b:	8b 75 dc             	mov    -0x24(%ebp),%esi
  80059e:	eb dc                	jmp    80057c <vprintfmt+0x223>
  8005a0:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8005a3:	83 ec 08             	sub    $0x8,%esp
  8005a6:	57                   	push   %edi
  8005a7:	6a 20                	push   $0x20
  8005a9:	ff 55 08             	call   *0x8(%ebp)
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005ac:	4b                   	dec    %ebx
  8005ad:	83 c4 10             	add    $0x10,%esp
  8005b0:	85 db                	test   %ebx,%ebx
  8005b2:	7f ef                	jg     8005a3 <vprintfmt+0x24a>
  8005b4:	e9 c4 fd ff ff       	jmp    80037d <vprintfmt+0x24>
  8005b9:	89 5d d8             	mov    %ebx,-0x28(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8005bc:	89 ca                	mov    %ecx,%edx
  8005be:	8d 45 14             	lea    0x14(%ebp),%eax
  8005c1:	e8 2a fd ff ff       	call   8002f0 <getint>
  8005c6:	89 c3                	mov    %eax,%ebx
  8005c8:	89 d6                	mov    %edx,%esi
			if ((long long) num < 0) {
  8005ca:	85 d2                	test   %edx,%edx
  8005cc:	78 0a                	js     8005d8 <vprintfmt+0x27f>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8005ce:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005d3:	e9 b0 00 00 00       	jmp    800688 <vprintfmt+0x32f>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  8005d8:	83 ec 08             	sub    $0x8,%esp
  8005db:	57                   	push   %edi
  8005dc:	6a 2d                	push   $0x2d
  8005de:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8005e1:	f7 db                	neg    %ebx
  8005e3:	83 d6 00             	adc    $0x0,%esi
  8005e6:	f7 de                	neg    %esi
  8005e8:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8005eb:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005f0:	e9 93 00 00 00       	jmp    800688 <vprintfmt+0x32f>
  8005f5:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8005f8:	89 ca                	mov    %ecx,%edx
  8005fa:	8d 45 14             	lea    0x14(%ebp),%eax
  8005fd:	e8 b4 fc ff ff       	call   8002b6 <getuint>
  800602:	89 c3                	mov    %eax,%ebx
  800604:	89 d6                	mov    %edx,%esi
			base = 10;
  800606:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  80060b:	eb 7b                	jmp    800688 <vprintfmt+0x32f>
  80060d:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
  800610:	89 ca                	mov    %ecx,%edx
  800612:	8d 45 14             	lea    0x14(%ebp),%eax
  800615:	e8 d6 fc ff ff       	call   8002f0 <getint>
  80061a:	89 c3                	mov    %eax,%ebx
  80061c:	89 d6                	mov    %edx,%esi
            if ((long long) num < 0) {
  80061e:	85 d2                	test   %edx,%edx
  800620:	78 07                	js     800629 <vprintfmt+0x2d0>
                putch('-', putdat);
                num = -(long long) num;
            }
            base = 8;
  800622:	b8 08 00 00 00       	mov    $0x8,%eax
  800627:	eb 5f                	jmp    800688 <vprintfmt+0x32f>
		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
            if ((long long) num < 0) {
                putch('-', putdat);
  800629:	83 ec 08             	sub    $0x8,%esp
  80062c:	57                   	push   %edi
  80062d:	6a 2d                	push   $0x2d
  80062f:	ff 55 08             	call   *0x8(%ebp)
                num = -(long long) num;
  800632:	f7 db                	neg    %ebx
  800634:	83 d6 00             	adc    $0x0,%esi
  800637:	f7 de                	neg    %esi
  800639:	83 c4 10             	add    $0x10,%esp
            }
            base = 8;
  80063c:	b8 08 00 00 00       	mov    $0x8,%eax
  800641:	eb 45                	jmp    800688 <vprintfmt+0x32f>
  800643:	89 5d d8             	mov    %ebx,-0x28(%ebp)
            goto number;

        // pointer
		case 'p':
			putch('0', putdat);
  800646:	83 ec 08             	sub    $0x8,%esp
  800649:	57                   	push   %edi
  80064a:	6a 30                	push   $0x30
  80064c:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  80064f:	83 c4 08             	add    $0x8,%esp
  800652:	57                   	push   %edi
  800653:	6a 78                	push   $0x78
  800655:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800658:	8b 45 14             	mov    0x14(%ebp),%eax
  80065b:	8d 50 04             	lea    0x4(%eax),%edx
  80065e:	89 55 14             	mov    %edx,0x14(%ebp)

        // pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800661:	8b 18                	mov    (%eax),%ebx
  800663:	be 00 00 00 00       	mov    $0x0,%esi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800668:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80066b:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800670:	eb 16                	jmp    800688 <vprintfmt+0x32f>
  800672:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800675:	89 ca                	mov    %ecx,%edx
  800677:	8d 45 14             	lea    0x14(%ebp),%eax
  80067a:	e8 37 fc ff ff       	call   8002b6 <getuint>
  80067f:	89 c3                	mov    %eax,%ebx
  800681:	89 d6                	mov    %edx,%esi
			base = 16;
  800683:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800688:	83 ec 0c             	sub    $0xc,%esp
  80068b:	0f be 55 dc          	movsbl -0x24(%ebp),%edx
  80068f:	52                   	push   %edx
  800690:	ff 75 e4             	pushl  -0x1c(%ebp)
  800693:	50                   	push   %eax
  800694:	56                   	push   %esi
  800695:	53                   	push   %ebx
  800696:	89 fa                	mov    %edi,%edx
  800698:	8b 45 08             	mov    0x8(%ebp),%eax
  80069b:	e8 68 fb ff ff       	call   800208 <printnum>
			break;
  8006a0:	83 c4 20             	add    $0x20,%esp
  8006a3:	8b 75 d8             	mov    -0x28(%ebp),%esi
  8006a6:	e9 d2 fc ff ff       	jmp    80037d <vprintfmt+0x24>
  8006ab:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006ae:	83 ec 08             	sub    $0x8,%esp
  8006b1:	57                   	push   %edi
  8006b2:	52                   	push   %edx
  8006b3:	ff 55 08             	call   *0x8(%ebp)
			break;
  8006b6:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006b9:	8b 75 d8             	mov    -0x28(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8006bc:	e9 bc fc ff ff       	jmp    80037d <vprintfmt+0x24>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8006c1:	83 ec 08             	sub    $0x8,%esp
  8006c4:	57                   	push   %edi
  8006c5:	6a 25                	push   $0x25
  8006c7:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006ca:	83 c4 10             	add    $0x10,%esp
  8006cd:	eb 02                	jmp    8006d1 <vprintfmt+0x378>
  8006cf:	89 c6                	mov    %eax,%esi
  8006d1:	8d 46 ff             	lea    -0x1(%esi),%eax
  8006d4:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  8006d8:	75 f5                	jne    8006cf <vprintfmt+0x376>
  8006da:	e9 9e fc ff ff       	jmp    80037d <vprintfmt+0x24>
				/* do nothing */;
			break;
		}
	}
}
  8006df:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006e2:	5b                   	pop    %ebx
  8006e3:	5e                   	pop    %esi
  8006e4:	5f                   	pop    %edi
  8006e5:	c9                   	leave  
  8006e6:	c3                   	ret    

008006e7 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006e7:	55                   	push   %ebp
  8006e8:	89 e5                	mov    %esp,%ebp
  8006ea:	83 ec 18             	sub    $0x18,%esp
  8006ed:	8b 45 08             	mov    0x8(%ebp),%eax
  8006f0:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006f3:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006f6:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8006fa:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8006fd:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800704:	85 c0                	test   %eax,%eax
  800706:	74 26                	je     80072e <vsnprintf+0x47>
  800708:	85 d2                	test   %edx,%edx
  80070a:	7e 29                	jle    800735 <vsnprintf+0x4e>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80070c:	ff 75 14             	pushl  0x14(%ebp)
  80070f:	ff 75 10             	pushl  0x10(%ebp)
  800712:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800715:	50                   	push   %eax
  800716:	68 22 03 80 00       	push   $0x800322
  80071b:	e8 39 fc ff ff       	call   800359 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800720:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800723:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800726:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800729:	83 c4 10             	add    $0x10,%esp
  80072c:	eb 0c                	jmp    80073a <vsnprintf+0x53>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80072e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800733:	eb 05                	jmp    80073a <vsnprintf+0x53>
  800735:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80073a:	c9                   	leave  
  80073b:	c3                   	ret    

0080073c <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80073c:	55                   	push   %ebp
  80073d:	89 e5                	mov    %esp,%ebp
  80073f:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800742:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800745:	50                   	push   %eax
  800746:	ff 75 10             	pushl  0x10(%ebp)
  800749:	ff 75 0c             	pushl  0xc(%ebp)
  80074c:	ff 75 08             	pushl  0x8(%ebp)
  80074f:	e8 93 ff ff ff       	call   8006e7 <vsnprintf>
	va_end(ap);

	return rc;
}
  800754:	c9                   	leave  
  800755:	c3                   	ret    
	...

00800758 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800758:	55                   	push   %ebp
  800759:	89 e5                	mov    %esp,%ebp
  80075b:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80075e:	80 3a 00             	cmpb   $0x0,(%edx)
  800761:	74 0e                	je     800771 <strlen+0x19>
  800763:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800768:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800769:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80076d:	75 f9                	jne    800768 <strlen+0x10>
  80076f:	eb 05                	jmp    800776 <strlen+0x1e>
  800771:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800776:	c9                   	leave  
  800777:	c3                   	ret    

00800778 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800778:	55                   	push   %ebp
  800779:	89 e5                	mov    %esp,%ebp
  80077b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80077e:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800781:	85 d2                	test   %edx,%edx
  800783:	74 17                	je     80079c <strnlen+0x24>
  800785:	80 39 00             	cmpb   $0x0,(%ecx)
  800788:	74 19                	je     8007a3 <strnlen+0x2b>
  80078a:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  80078f:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800790:	39 d0                	cmp    %edx,%eax
  800792:	74 14                	je     8007a8 <strnlen+0x30>
  800794:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800798:	75 f5                	jne    80078f <strnlen+0x17>
  80079a:	eb 0c                	jmp    8007a8 <strnlen+0x30>
  80079c:	b8 00 00 00 00       	mov    $0x0,%eax
  8007a1:	eb 05                	jmp    8007a8 <strnlen+0x30>
  8007a3:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  8007a8:	c9                   	leave  
  8007a9:	c3                   	ret    

008007aa <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007aa:	55                   	push   %ebp
  8007ab:	89 e5                	mov    %esp,%ebp
  8007ad:	53                   	push   %ebx
  8007ae:	8b 45 08             	mov    0x8(%ebp),%eax
  8007b1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007b4:	ba 00 00 00 00       	mov    $0x0,%edx
  8007b9:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  8007bc:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  8007bf:	42                   	inc    %edx
  8007c0:	84 c9                	test   %cl,%cl
  8007c2:	75 f5                	jne    8007b9 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8007c4:	5b                   	pop    %ebx
  8007c5:	c9                   	leave  
  8007c6:	c3                   	ret    

008007c7 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007c7:	55                   	push   %ebp
  8007c8:	89 e5                	mov    %esp,%ebp
  8007ca:	53                   	push   %ebx
  8007cb:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007ce:	53                   	push   %ebx
  8007cf:	e8 84 ff ff ff       	call   800758 <strlen>
  8007d4:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8007d7:	ff 75 0c             	pushl  0xc(%ebp)
  8007da:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  8007dd:	50                   	push   %eax
  8007de:	e8 c7 ff ff ff       	call   8007aa <strcpy>
	return dst;
}
  8007e3:	89 d8                	mov    %ebx,%eax
  8007e5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007e8:	c9                   	leave  
  8007e9:	c3                   	ret    

008007ea <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007ea:	55                   	push   %ebp
  8007eb:	89 e5                	mov    %esp,%ebp
  8007ed:	56                   	push   %esi
  8007ee:	53                   	push   %ebx
  8007ef:	8b 45 08             	mov    0x8(%ebp),%eax
  8007f2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007f5:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007f8:	85 f6                	test   %esi,%esi
  8007fa:	74 15                	je     800811 <strncpy+0x27>
  8007fc:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  800801:	8a 1a                	mov    (%edx),%bl
  800803:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800806:	80 3a 01             	cmpb   $0x1,(%edx)
  800809:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80080c:	41                   	inc    %ecx
  80080d:	39 ce                	cmp    %ecx,%esi
  80080f:	77 f0                	ja     800801 <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800811:	5b                   	pop    %ebx
  800812:	5e                   	pop    %esi
  800813:	c9                   	leave  
  800814:	c3                   	ret    

00800815 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800815:	55                   	push   %ebp
  800816:	89 e5                	mov    %esp,%ebp
  800818:	57                   	push   %edi
  800819:	56                   	push   %esi
  80081a:	53                   	push   %ebx
  80081b:	8b 7d 08             	mov    0x8(%ebp),%edi
  80081e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800821:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800824:	85 f6                	test   %esi,%esi
  800826:	74 32                	je     80085a <strlcpy+0x45>
		while (--size > 0 && *src != '\0')
  800828:	83 fe 01             	cmp    $0x1,%esi
  80082b:	74 22                	je     80084f <strlcpy+0x3a>
  80082d:	8a 0b                	mov    (%ebx),%cl
  80082f:	84 c9                	test   %cl,%cl
  800831:	74 20                	je     800853 <strlcpy+0x3e>
  800833:	89 f8                	mov    %edi,%eax
  800835:	ba 00 00 00 00       	mov    $0x0,%edx
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
  80083a:	83 ee 02             	sub    $0x2,%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80083d:	88 08                	mov    %cl,(%eax)
  80083f:	40                   	inc    %eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800840:	39 f2                	cmp    %esi,%edx
  800842:	74 11                	je     800855 <strlcpy+0x40>
  800844:	8a 4c 13 01          	mov    0x1(%ebx,%edx,1),%cl
  800848:	42                   	inc    %edx
  800849:	84 c9                	test   %cl,%cl
  80084b:	75 f0                	jne    80083d <strlcpy+0x28>
  80084d:	eb 06                	jmp    800855 <strlcpy+0x40>
  80084f:	89 f8                	mov    %edi,%eax
  800851:	eb 02                	jmp    800855 <strlcpy+0x40>
  800853:	89 f8                	mov    %edi,%eax
			*dst++ = *src++;
		*dst = '\0';
  800855:	c6 00 00             	movb   $0x0,(%eax)
  800858:	eb 02                	jmp    80085c <strlcpy+0x47>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80085a:	89 f8                	mov    %edi,%eax
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
		*dst = '\0';
	}
	return dst - dst_in;
  80085c:	29 f8                	sub    %edi,%eax
}
  80085e:	5b                   	pop    %ebx
  80085f:	5e                   	pop    %esi
  800860:	5f                   	pop    %edi
  800861:	c9                   	leave  
  800862:	c3                   	ret    

00800863 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800863:	55                   	push   %ebp
  800864:	89 e5                	mov    %esp,%ebp
  800866:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800869:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80086c:	8a 01                	mov    (%ecx),%al
  80086e:	84 c0                	test   %al,%al
  800870:	74 10                	je     800882 <strcmp+0x1f>
  800872:	3a 02                	cmp    (%edx),%al
  800874:	75 0c                	jne    800882 <strcmp+0x1f>
		p++, q++;
  800876:	41                   	inc    %ecx
  800877:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800878:	8a 01                	mov    (%ecx),%al
  80087a:	84 c0                	test   %al,%al
  80087c:	74 04                	je     800882 <strcmp+0x1f>
  80087e:	3a 02                	cmp    (%edx),%al
  800880:	74 f4                	je     800876 <strcmp+0x13>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800882:	0f b6 c0             	movzbl %al,%eax
  800885:	0f b6 12             	movzbl (%edx),%edx
  800888:	29 d0                	sub    %edx,%eax
}
  80088a:	c9                   	leave  
  80088b:	c3                   	ret    

0080088c <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80088c:	55                   	push   %ebp
  80088d:	89 e5                	mov    %esp,%ebp
  80088f:	53                   	push   %ebx
  800890:	8b 55 08             	mov    0x8(%ebp),%edx
  800893:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800896:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  800899:	85 c0                	test   %eax,%eax
  80089b:	74 1b                	je     8008b8 <strncmp+0x2c>
  80089d:	8a 1a                	mov    (%edx),%bl
  80089f:	84 db                	test   %bl,%bl
  8008a1:	74 24                	je     8008c7 <strncmp+0x3b>
  8008a3:	3a 19                	cmp    (%ecx),%bl
  8008a5:	75 20                	jne    8008c7 <strncmp+0x3b>
  8008a7:	48                   	dec    %eax
  8008a8:	74 15                	je     8008bf <strncmp+0x33>
		n--, p++, q++;
  8008aa:	42                   	inc    %edx
  8008ab:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8008ac:	8a 1a                	mov    (%edx),%bl
  8008ae:	84 db                	test   %bl,%bl
  8008b0:	74 15                	je     8008c7 <strncmp+0x3b>
  8008b2:	3a 19                	cmp    (%ecx),%bl
  8008b4:	74 f1                	je     8008a7 <strncmp+0x1b>
  8008b6:	eb 0f                	jmp    8008c7 <strncmp+0x3b>
		n--, p++, q++;
	if (n == 0)
		return 0;
  8008b8:	b8 00 00 00 00       	mov    $0x0,%eax
  8008bd:	eb 05                	jmp    8008c4 <strncmp+0x38>
  8008bf:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8008c4:	5b                   	pop    %ebx
  8008c5:	c9                   	leave  
  8008c6:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008c7:	0f b6 02             	movzbl (%edx),%eax
  8008ca:	0f b6 11             	movzbl (%ecx),%edx
  8008cd:	29 d0                	sub    %edx,%eax
  8008cf:	eb f3                	jmp    8008c4 <strncmp+0x38>

008008d1 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008d1:	55                   	push   %ebp
  8008d2:	89 e5                	mov    %esp,%ebp
  8008d4:	8b 45 08             	mov    0x8(%ebp),%eax
  8008d7:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8008da:	8a 10                	mov    (%eax),%dl
  8008dc:	84 d2                	test   %dl,%dl
  8008de:	74 18                	je     8008f8 <strchr+0x27>
		if (*s == c)
  8008e0:	38 ca                	cmp    %cl,%dl
  8008e2:	75 06                	jne    8008ea <strchr+0x19>
  8008e4:	eb 17                	jmp    8008fd <strchr+0x2c>
  8008e6:	38 ca                	cmp    %cl,%dl
  8008e8:	74 13                	je     8008fd <strchr+0x2c>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8008ea:	40                   	inc    %eax
  8008eb:	8a 10                	mov    (%eax),%dl
  8008ed:	84 d2                	test   %dl,%dl
  8008ef:	75 f5                	jne    8008e6 <strchr+0x15>
		if (*s == c)
			return (char *) s;
	return 0;
  8008f1:	b8 00 00 00 00       	mov    $0x0,%eax
  8008f6:	eb 05                	jmp    8008fd <strchr+0x2c>
  8008f8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008fd:	c9                   	leave  
  8008fe:	c3                   	ret    

008008ff <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008ff:	55                   	push   %ebp
  800900:	89 e5                	mov    %esp,%ebp
  800902:	8b 45 08             	mov    0x8(%ebp),%eax
  800905:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800908:	8a 10                	mov    (%eax),%dl
  80090a:	84 d2                	test   %dl,%dl
  80090c:	74 11                	je     80091f <strfind+0x20>
		if (*s == c)
  80090e:	38 ca                	cmp    %cl,%dl
  800910:	75 06                	jne    800918 <strfind+0x19>
  800912:	eb 0b                	jmp    80091f <strfind+0x20>
  800914:	38 ca                	cmp    %cl,%dl
  800916:	74 07                	je     80091f <strfind+0x20>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800918:	40                   	inc    %eax
  800919:	8a 10                	mov    (%eax),%dl
  80091b:	84 d2                	test   %dl,%dl
  80091d:	75 f5                	jne    800914 <strfind+0x15>
		if (*s == c)
			break;
	return (char *) s;
}
  80091f:	c9                   	leave  
  800920:	c3                   	ret    

00800921 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800921:	55                   	push   %ebp
  800922:	89 e5                	mov    %esp,%ebp
  800924:	57                   	push   %edi
  800925:	56                   	push   %esi
  800926:	53                   	push   %ebx
  800927:	8b 7d 08             	mov    0x8(%ebp),%edi
  80092a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80092d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800930:	85 c9                	test   %ecx,%ecx
  800932:	74 30                	je     800964 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800934:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80093a:	75 25                	jne    800961 <memset+0x40>
  80093c:	f6 c1 03             	test   $0x3,%cl
  80093f:	75 20                	jne    800961 <memset+0x40>
		c &= 0xFF;
  800941:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800944:	89 d3                	mov    %edx,%ebx
  800946:	c1 e3 08             	shl    $0x8,%ebx
  800949:	89 d6                	mov    %edx,%esi
  80094b:	c1 e6 18             	shl    $0x18,%esi
  80094e:	89 d0                	mov    %edx,%eax
  800950:	c1 e0 10             	shl    $0x10,%eax
  800953:	09 f0                	or     %esi,%eax
  800955:	09 d0                	or     %edx,%eax
  800957:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800959:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  80095c:	fc                   	cld    
  80095d:	f3 ab                	rep stos %eax,%es:(%edi)
  80095f:	eb 03                	jmp    800964 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800961:	fc                   	cld    
  800962:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800964:	89 f8                	mov    %edi,%eax
  800966:	5b                   	pop    %ebx
  800967:	5e                   	pop    %esi
  800968:	5f                   	pop    %edi
  800969:	c9                   	leave  
  80096a:	c3                   	ret    

0080096b <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80096b:	55                   	push   %ebp
  80096c:	89 e5                	mov    %esp,%ebp
  80096e:	57                   	push   %edi
  80096f:	56                   	push   %esi
  800970:	8b 45 08             	mov    0x8(%ebp),%eax
  800973:	8b 75 0c             	mov    0xc(%ebp),%esi
  800976:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800979:	39 c6                	cmp    %eax,%esi
  80097b:	73 34                	jae    8009b1 <memmove+0x46>
  80097d:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800980:	39 d0                	cmp    %edx,%eax
  800982:	73 2d                	jae    8009b1 <memmove+0x46>
		s += n;
		d += n;
  800984:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800987:	f6 c2 03             	test   $0x3,%dl
  80098a:	75 1b                	jne    8009a7 <memmove+0x3c>
  80098c:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800992:	75 13                	jne    8009a7 <memmove+0x3c>
  800994:	f6 c1 03             	test   $0x3,%cl
  800997:	75 0e                	jne    8009a7 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800999:	83 ef 04             	sub    $0x4,%edi
  80099c:	8d 72 fc             	lea    -0x4(%edx),%esi
  80099f:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  8009a2:	fd                   	std    
  8009a3:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009a5:	eb 07                	jmp    8009ae <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8009a7:	4f                   	dec    %edi
  8009a8:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8009ab:	fd                   	std    
  8009ac:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009ae:	fc                   	cld    
  8009af:	eb 20                	jmp    8009d1 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009b1:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009b7:	75 13                	jne    8009cc <memmove+0x61>
  8009b9:	a8 03                	test   $0x3,%al
  8009bb:	75 0f                	jne    8009cc <memmove+0x61>
  8009bd:	f6 c1 03             	test   $0x3,%cl
  8009c0:	75 0a                	jne    8009cc <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8009c2:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  8009c5:	89 c7                	mov    %eax,%edi
  8009c7:	fc                   	cld    
  8009c8:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009ca:	eb 05                	jmp    8009d1 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8009cc:	89 c7                	mov    %eax,%edi
  8009ce:	fc                   	cld    
  8009cf:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009d1:	5e                   	pop    %esi
  8009d2:	5f                   	pop    %edi
  8009d3:	c9                   	leave  
  8009d4:	c3                   	ret    

008009d5 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009d5:	55                   	push   %ebp
  8009d6:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8009d8:	ff 75 10             	pushl  0x10(%ebp)
  8009db:	ff 75 0c             	pushl  0xc(%ebp)
  8009de:	ff 75 08             	pushl  0x8(%ebp)
  8009e1:	e8 85 ff ff ff       	call   80096b <memmove>
}
  8009e6:	c9                   	leave  
  8009e7:	c3                   	ret    

008009e8 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009e8:	55                   	push   %ebp
  8009e9:	89 e5                	mov    %esp,%ebp
  8009eb:	57                   	push   %edi
  8009ec:	56                   	push   %esi
  8009ed:	53                   	push   %ebx
  8009ee:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8009f1:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009f4:	8b 7d 10             	mov    0x10(%ebp),%edi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009f7:	85 ff                	test   %edi,%edi
  8009f9:	74 32                	je     800a2d <memcmp+0x45>
		if (*s1 != *s2)
  8009fb:	8a 03                	mov    (%ebx),%al
  8009fd:	8a 0e                	mov    (%esi),%cl
  8009ff:	38 c8                	cmp    %cl,%al
  800a01:	74 19                	je     800a1c <memcmp+0x34>
  800a03:	eb 0d                	jmp    800a12 <memcmp+0x2a>
  800a05:	8a 44 13 01          	mov    0x1(%ebx,%edx,1),%al
  800a09:	8a 4c 16 01          	mov    0x1(%esi,%edx,1),%cl
  800a0d:	42                   	inc    %edx
  800a0e:	38 c8                	cmp    %cl,%al
  800a10:	74 10                	je     800a22 <memcmp+0x3a>
			return (int) *s1 - (int) *s2;
  800a12:	0f b6 c0             	movzbl %al,%eax
  800a15:	0f b6 c9             	movzbl %cl,%ecx
  800a18:	29 c8                	sub    %ecx,%eax
  800a1a:	eb 16                	jmp    800a32 <memcmp+0x4a>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a1c:	4f                   	dec    %edi
  800a1d:	ba 00 00 00 00       	mov    $0x0,%edx
  800a22:	39 fa                	cmp    %edi,%edx
  800a24:	75 df                	jne    800a05 <memcmp+0x1d>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a26:	b8 00 00 00 00       	mov    $0x0,%eax
  800a2b:	eb 05                	jmp    800a32 <memcmp+0x4a>
  800a2d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a32:	5b                   	pop    %ebx
  800a33:	5e                   	pop    %esi
  800a34:	5f                   	pop    %edi
  800a35:	c9                   	leave  
  800a36:	c3                   	ret    

00800a37 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a37:	55                   	push   %ebp
  800a38:	89 e5                	mov    %esp,%ebp
  800a3a:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800a3d:	89 c2                	mov    %eax,%edx
  800a3f:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a42:	39 d0                	cmp    %edx,%eax
  800a44:	73 12                	jae    800a58 <memfind+0x21>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a46:	8a 4d 0c             	mov    0xc(%ebp),%cl
  800a49:	38 08                	cmp    %cl,(%eax)
  800a4b:	75 06                	jne    800a53 <memfind+0x1c>
  800a4d:	eb 09                	jmp    800a58 <memfind+0x21>
  800a4f:	38 08                	cmp    %cl,(%eax)
  800a51:	74 05                	je     800a58 <memfind+0x21>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a53:	40                   	inc    %eax
  800a54:	39 c2                	cmp    %eax,%edx
  800a56:	77 f7                	ja     800a4f <memfind+0x18>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a58:	c9                   	leave  
  800a59:	c3                   	ret    

00800a5a <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a5a:	55                   	push   %ebp
  800a5b:	89 e5                	mov    %esp,%ebp
  800a5d:	57                   	push   %edi
  800a5e:	56                   	push   %esi
  800a5f:	53                   	push   %ebx
  800a60:	8b 55 08             	mov    0x8(%ebp),%edx
  800a63:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a66:	eb 01                	jmp    800a69 <strtol+0xf>
		s++;
  800a68:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a69:	8a 02                	mov    (%edx),%al
  800a6b:	3c 20                	cmp    $0x20,%al
  800a6d:	74 f9                	je     800a68 <strtol+0xe>
  800a6f:	3c 09                	cmp    $0x9,%al
  800a71:	74 f5                	je     800a68 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a73:	3c 2b                	cmp    $0x2b,%al
  800a75:	75 08                	jne    800a7f <strtol+0x25>
		s++;
  800a77:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a78:	bf 00 00 00 00       	mov    $0x0,%edi
  800a7d:	eb 13                	jmp    800a92 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a7f:	3c 2d                	cmp    $0x2d,%al
  800a81:	75 0a                	jne    800a8d <strtol+0x33>
		s++, neg = 1;
  800a83:	8d 52 01             	lea    0x1(%edx),%edx
  800a86:	bf 01 00 00 00       	mov    $0x1,%edi
  800a8b:	eb 05                	jmp    800a92 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a8d:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a92:	85 db                	test   %ebx,%ebx
  800a94:	74 05                	je     800a9b <strtol+0x41>
  800a96:	83 fb 10             	cmp    $0x10,%ebx
  800a99:	75 28                	jne    800ac3 <strtol+0x69>
  800a9b:	8a 02                	mov    (%edx),%al
  800a9d:	3c 30                	cmp    $0x30,%al
  800a9f:	75 10                	jne    800ab1 <strtol+0x57>
  800aa1:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800aa5:	75 0a                	jne    800ab1 <strtol+0x57>
		s += 2, base = 16;
  800aa7:	83 c2 02             	add    $0x2,%edx
  800aaa:	bb 10 00 00 00       	mov    $0x10,%ebx
  800aaf:	eb 12                	jmp    800ac3 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800ab1:	85 db                	test   %ebx,%ebx
  800ab3:	75 0e                	jne    800ac3 <strtol+0x69>
  800ab5:	3c 30                	cmp    $0x30,%al
  800ab7:	75 05                	jne    800abe <strtol+0x64>
		s++, base = 8;
  800ab9:	42                   	inc    %edx
  800aba:	b3 08                	mov    $0x8,%bl
  800abc:	eb 05                	jmp    800ac3 <strtol+0x69>
	else if (base == 0)
		base = 10;
  800abe:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800ac3:	b8 00 00 00 00       	mov    $0x0,%eax
  800ac8:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800aca:	8a 0a                	mov    (%edx),%cl
  800acc:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800acf:	80 fb 09             	cmp    $0x9,%bl
  800ad2:	77 08                	ja     800adc <strtol+0x82>
			dig = *s - '0';
  800ad4:	0f be c9             	movsbl %cl,%ecx
  800ad7:	83 e9 30             	sub    $0x30,%ecx
  800ada:	eb 1e                	jmp    800afa <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800adc:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800adf:	80 fb 19             	cmp    $0x19,%bl
  800ae2:	77 08                	ja     800aec <strtol+0x92>
			dig = *s - 'a' + 10;
  800ae4:	0f be c9             	movsbl %cl,%ecx
  800ae7:	83 e9 57             	sub    $0x57,%ecx
  800aea:	eb 0e                	jmp    800afa <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800aec:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800aef:	80 fb 19             	cmp    $0x19,%bl
  800af2:	77 13                	ja     800b07 <strtol+0xad>
			dig = *s - 'A' + 10;
  800af4:	0f be c9             	movsbl %cl,%ecx
  800af7:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800afa:	39 f1                	cmp    %esi,%ecx
  800afc:	7d 0d                	jge    800b0b <strtol+0xb1>
			break;
		s++, val = (val * base) + dig;
  800afe:	42                   	inc    %edx
  800aff:	0f af c6             	imul   %esi,%eax
  800b02:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  800b05:	eb c3                	jmp    800aca <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800b07:	89 c1                	mov    %eax,%ecx
  800b09:	eb 02                	jmp    800b0d <strtol+0xb3>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800b0b:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800b0d:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b11:	74 05                	je     800b18 <strtol+0xbe>
		*endptr = (char *) s;
  800b13:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800b16:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800b18:	85 ff                	test   %edi,%edi
  800b1a:	74 04                	je     800b20 <strtol+0xc6>
  800b1c:	89 c8                	mov    %ecx,%eax
  800b1e:	f7 d8                	neg    %eax
}
  800b20:	5b                   	pop    %ebx
  800b21:	5e                   	pop    %esi
  800b22:	5f                   	pop    %edi
  800b23:	c9                   	leave  
  800b24:	c3                   	ret    
  800b25:	00 00                	add    %al,(%eax)
	...

00800b28 <syscall>:
	return ret;
}

static int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800b28:	55                   	push   %ebp
  800b29:	89 e5                	mov    %esp,%ebp
  800b2b:	57                   	push   %edi
  800b2c:	56                   	push   %esi
  800b2d:	53                   	push   %ebx
  800b2e:	83 ec 1c             	sub    $0x1c,%esp
  800b31:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800b34:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800b37:	89 ca                	mov    %ecx,%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b39:	8b 75 14             	mov    0x14(%ebp),%esi
  800b3c:	8b 7d 10             	mov    0x10(%ebp),%edi
  800b3f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800b42:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b45:	cd 30                	int    $0x30
  800b47:	89 c2                	mov    %eax,%edx
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b49:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800b4d:	74 1c                	je     800b6b <syscall+0x43>
  800b4f:	85 c0                	test   %eax,%eax
  800b51:	7e 18                	jle    800b6b <syscall+0x43>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b53:	83 ec 0c             	sub    $0xc,%esp
  800b56:	50                   	push   %eax
  800b57:	ff 75 e4             	pushl  -0x1c(%ebp)
  800b5a:	68 84 12 80 00       	push   $0x801284
  800b5f:	6a 42                	push   $0x42
  800b61:	68 a1 12 80 00       	push   $0x8012a1
  800b66:	e8 b1 f5 ff ff       	call   80011c <_panic>

	return ret;
}
  800b6b:	89 d0                	mov    %edx,%eax
  800b6d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b70:	5b                   	pop    %ebx
  800b71:	5e                   	pop    %esi
  800b72:	5f                   	pop    %edi
  800b73:	c9                   	leave  
  800b74:	c3                   	ret    

00800b75 <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{	
  800b75:	55                   	push   %ebp
  800b76:	89 e5                	mov    %esp,%ebp
  800b78:	83 ec 08             	sub    $0x8,%esp
	// my_sysenter(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
	// return;
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  800b7b:	6a 00                	push   $0x0
  800b7d:	6a 00                	push   $0x0
  800b7f:	6a 00                	push   $0x0
  800b81:	ff 75 0c             	pushl  0xc(%ebp)
  800b84:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b87:	ba 00 00 00 00       	mov    $0x0,%edx
  800b8c:	b8 00 00 00 00       	mov    $0x0,%eax
  800b91:	e8 92 ff ff ff       	call   800b28 <syscall>
  800b96:	83 c4 10             	add    $0x10,%esp
	return;
}
  800b99:	c9                   	leave  
  800b9a:	c3                   	ret    

00800b9b <sys_cgetc>:

int
sys_cgetc(void)
{
  800b9b:	55                   	push   %ebp
  800b9c:	89 e5                	mov    %esp,%ebp
  800b9e:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_cgetc, 0, 0, 0, 0, 0, 0);
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  800ba1:	6a 00                	push   $0x0
  800ba3:	6a 00                	push   $0x0
  800ba5:	6a 00                	push   $0x0
  800ba7:	6a 00                	push   $0x0
  800ba9:	b9 00 00 00 00       	mov    $0x0,%ecx
  800bae:	ba 00 00 00 00       	mov    $0x0,%edx
  800bb3:	b8 01 00 00 00       	mov    $0x1,%eax
  800bb8:	e8 6b ff ff ff       	call   800b28 <syscall>
}
  800bbd:	c9                   	leave  
  800bbe:	c3                   	ret    

00800bbf <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800bbf:	55                   	push   %ebp
  800bc0:	89 e5                	mov    %esp,%ebp
  800bc2:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  800bc5:	6a 00                	push   $0x0
  800bc7:	6a 00                	push   $0x0
  800bc9:	6a 00                	push   $0x0
  800bcb:	6a 00                	push   $0x0
  800bcd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800bd0:	ba 01 00 00 00       	mov    $0x1,%edx
  800bd5:	b8 03 00 00 00       	mov    $0x3,%eax
  800bda:	e8 49 ff ff ff       	call   800b28 <syscall>
}
  800bdf:	c9                   	leave  
  800be0:	c3                   	ret    

00800be1 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800be1:	55                   	push   %ebp
  800be2:	89 e5                	mov    %esp,%ebp
  800be4:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_getenvid, 0, 0, 0, 0, 0, 0);
	return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  800be7:	6a 00                	push   $0x0
  800be9:	6a 00                	push   $0x0
  800beb:	6a 00                	push   $0x0
  800bed:	6a 00                	push   $0x0
  800bef:	b9 00 00 00 00       	mov    $0x0,%ecx
  800bf4:	ba 00 00 00 00       	mov    $0x0,%edx
  800bf9:	b8 02 00 00 00       	mov    $0x2,%eax
  800bfe:	e8 25 ff ff ff       	call   800b28 <syscall>
}
  800c03:	c9                   	leave  
  800c04:	c3                   	ret    

00800c05 <sys_yield>:

void
sys_yield(void)
{
  800c05:	55                   	push   %ebp
  800c06:	89 e5                	mov    %esp,%ebp
  800c08:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  800c0b:	6a 00                	push   $0x0
  800c0d:	6a 00                	push   $0x0
  800c0f:	6a 00                	push   $0x0
  800c11:	6a 00                	push   $0x0
  800c13:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c18:	ba 00 00 00 00       	mov    $0x0,%edx
  800c1d:	b8 0a 00 00 00       	mov    $0xa,%eax
  800c22:	e8 01 ff ff ff       	call   800b28 <syscall>
  800c27:	83 c4 10             	add    $0x10,%esp
}
  800c2a:	c9                   	leave  
  800c2b:	c3                   	ret    

00800c2c <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c2c:	55                   	push   %ebp
  800c2d:	89 e5                	mov    %esp,%ebp
  800c2f:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  800c32:	6a 00                	push   $0x0
  800c34:	6a 00                	push   $0x0
  800c36:	ff 75 10             	pushl  0x10(%ebp)
  800c39:	ff 75 0c             	pushl  0xc(%ebp)
  800c3c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c3f:	ba 01 00 00 00       	mov    $0x1,%edx
  800c44:	b8 04 00 00 00       	mov    $0x4,%eax
  800c49:	e8 da fe ff ff       	call   800b28 <syscall>
}
  800c4e:	c9                   	leave  
  800c4f:	c3                   	ret    

00800c50 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c50:	55                   	push   %ebp
  800c51:	89 e5                	mov    %esp,%ebp
  800c53:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
  800c56:	ff 75 18             	pushl  0x18(%ebp)
  800c59:	ff 75 14             	pushl  0x14(%ebp)
  800c5c:	ff 75 10             	pushl  0x10(%ebp)
  800c5f:	ff 75 0c             	pushl  0xc(%ebp)
  800c62:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c65:	ba 01 00 00 00       	mov    $0x1,%edx
  800c6a:	b8 05 00 00 00       	mov    $0x5,%eax
  800c6f:	e8 b4 fe ff ff       	call   800b28 <syscall>
}
  800c74:	c9                   	leave  
  800c75:	c3                   	ret    

00800c76 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c76:	55                   	push   %ebp
  800c77:	89 e5                	mov    %esp,%ebp
  800c79:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  800c7c:	6a 00                	push   $0x0
  800c7e:	6a 00                	push   $0x0
  800c80:	6a 00                	push   $0x0
  800c82:	ff 75 0c             	pushl  0xc(%ebp)
  800c85:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c88:	ba 01 00 00 00       	mov    $0x1,%edx
  800c8d:	b8 06 00 00 00       	mov    $0x6,%eax
  800c92:	e8 91 fe ff ff       	call   800b28 <syscall>
}
  800c97:	c9                   	leave  
  800c98:	c3                   	ret    

00800c99 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c99:	55                   	push   %ebp
  800c9a:	89 e5                	mov    %esp,%ebp
  800c9c:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  800c9f:	6a 00                	push   $0x0
  800ca1:	6a 00                	push   $0x0
  800ca3:	6a 00                	push   $0x0
  800ca5:	ff 75 0c             	pushl  0xc(%ebp)
  800ca8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800cab:	ba 01 00 00 00       	mov    $0x1,%edx
  800cb0:	b8 08 00 00 00       	mov    $0x8,%eax
  800cb5:	e8 6e fe ff ff       	call   800b28 <syscall>
}
  800cba:	c9                   	leave  
  800cbb:	c3                   	ret    

00800cbc <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800cbc:	55                   	push   %ebp
  800cbd:	89 e5                	mov    %esp,%ebp
  800cbf:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  800cc2:	6a 00                	push   $0x0
  800cc4:	6a 00                	push   $0x0
  800cc6:	6a 00                	push   $0x0
  800cc8:	ff 75 0c             	pushl  0xc(%ebp)
  800ccb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800cce:	ba 01 00 00 00       	mov    $0x1,%edx
  800cd3:	b8 09 00 00 00       	mov    $0x9,%eax
  800cd8:	e8 4b fe ff ff       	call   800b28 <syscall>
}
  800cdd:	c9                   	leave  
  800cde:	c3                   	ret    

00800cdf <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800cdf:	55                   	push   %ebp
  800ce0:	89 e5                	mov    %esp,%ebp
  800ce2:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  800ce5:	6a 00                	push   $0x0
  800ce7:	ff 75 14             	pushl  0x14(%ebp)
  800cea:	ff 75 10             	pushl  0x10(%ebp)
  800ced:	ff 75 0c             	pushl  0xc(%ebp)
  800cf0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800cf3:	ba 00 00 00 00       	mov    $0x0,%edx
  800cf8:	b8 0b 00 00 00       	mov    $0xb,%eax
  800cfd:	e8 26 fe ff ff       	call   800b28 <syscall>
}
  800d02:	c9                   	leave  
  800d03:	c3                   	ret    

00800d04 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d04:	55                   	push   %ebp
  800d05:	89 e5                	mov    %esp,%ebp
  800d07:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  800d0a:	6a 00                	push   $0x0
  800d0c:	6a 00                	push   $0x0
  800d0e:	6a 00                	push   $0x0
  800d10:	6a 00                	push   $0x0
  800d12:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d15:	ba 01 00 00 00       	mov    $0x1,%edx
  800d1a:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d1f:	e8 04 fe ff ff       	call   800b28 <syscall>
}
  800d24:	c9                   	leave  
  800d25:	c3                   	ret    
	...

00800d28 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  800d28:	55                   	push   %ebp
  800d29:	89 e5                	mov    %esp,%ebp
  800d2b:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  800d2e:	83 3d 08 20 80 00 00 	cmpl   $0x0,0x802008
  800d35:	75 14                	jne    800d4b <set_pgfault_handler+0x23>
		// First time through!
		// LAB 4: Your code here.
		panic("set_pgfault_handler not implemented");
  800d37:	83 ec 04             	sub    $0x4,%esp
  800d3a:	68 b0 12 80 00       	push   $0x8012b0
  800d3f:	6a 20                	push   $0x20
  800d41:	68 d4 12 80 00       	push   $0x8012d4
  800d46:	e8 d1 f3 ff ff       	call   80011c <_panic>
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  800d4b:	8b 45 08             	mov    0x8(%ebp),%eax
  800d4e:	a3 08 20 80 00       	mov    %eax,0x802008
}
  800d53:	c9                   	leave  
  800d54:	c3                   	ret    
  800d55:	00 00                	add    %al,(%eax)
	...

00800d58 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  800d58:	55                   	push   %ebp
  800d59:	89 e5                	mov    %esp,%ebp
  800d5b:	57                   	push   %edi
  800d5c:	56                   	push   %esi
  800d5d:	83 ec 10             	sub    $0x10,%esp
  800d60:	8b 7d 08             	mov    0x8(%ebp),%edi
  800d63:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  800d66:	89 7d f0             	mov    %edi,-0x10(%ebp)
  800d69:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  800d6c:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  800d6f:	8b 45 14             	mov    0x14(%ebp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800d72:	85 c0                	test   %eax,%eax
  800d74:	75 2e                	jne    800da4 <__udivdi3+0x4c>
    {
      if (d0 > n1)
  800d76:	39 f1                	cmp    %esi,%ecx
  800d78:	77 5a                	ja     800dd4 <__udivdi3+0x7c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  800d7a:	85 c9                	test   %ecx,%ecx
  800d7c:	75 0b                	jne    800d89 <__udivdi3+0x31>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  800d7e:	b8 01 00 00 00       	mov    $0x1,%eax
  800d83:	31 d2                	xor    %edx,%edx
  800d85:	f7 f1                	div    %ecx
  800d87:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  800d89:	31 d2                	xor    %edx,%edx
  800d8b:	89 f0                	mov    %esi,%eax
  800d8d:	f7 f1                	div    %ecx
  800d8f:	89 c6                	mov    %eax,%esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800d91:	89 f8                	mov    %edi,%eax
  800d93:	f7 f1                	div    %ecx
  800d95:	89 c7                	mov    %eax,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800d97:	89 f8                	mov    %edi,%eax
  800d99:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800d9b:	83 c4 10             	add    $0x10,%esp
  800d9e:	5e                   	pop    %esi
  800d9f:	5f                   	pop    %edi
  800da0:	c9                   	leave  
  800da1:	c3                   	ret    
  800da2:	66 90                	xchg   %ax,%ax
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800da4:	39 f0                	cmp    %esi,%eax
  800da6:	77 1c                	ja     800dc4 <__udivdi3+0x6c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  800da8:	0f bd f8             	bsr    %eax,%edi
	  if (bm == 0)
  800dab:	83 f7 1f             	xor    $0x1f,%edi
  800dae:	75 3c                	jne    800dec <__udivdi3+0x94>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800db0:	39 f0                	cmp    %esi,%eax
  800db2:	0f 82 90 00 00 00    	jb     800e48 <__udivdi3+0xf0>
  800db8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800dbb:	39 55 f4             	cmp    %edx,-0xc(%ebp)
  800dbe:	0f 86 84 00 00 00    	jbe    800e48 <__udivdi3+0xf0>
  800dc4:	31 f6                	xor    %esi,%esi
  800dc6:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800dc8:	89 f8                	mov    %edi,%eax
  800dca:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800dcc:	83 c4 10             	add    $0x10,%esp
  800dcf:	5e                   	pop    %esi
  800dd0:	5f                   	pop    %edi
  800dd1:	c9                   	leave  
  800dd2:	c3                   	ret    
  800dd3:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800dd4:	89 f2                	mov    %esi,%edx
  800dd6:	89 f8                	mov    %edi,%eax
  800dd8:	f7 f1                	div    %ecx
  800dda:	89 c7                	mov    %eax,%edi
  800ddc:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800dde:	89 f8                	mov    %edi,%eax
  800de0:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800de2:	83 c4 10             	add    $0x10,%esp
  800de5:	5e                   	pop    %esi
  800de6:	5f                   	pop    %edi
  800de7:	c9                   	leave  
  800de8:	c3                   	ret    
  800de9:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  800dec:	89 f9                	mov    %edi,%ecx
  800dee:	d3 e0                	shl    %cl,%eax
  800df0:	89 45 e8             	mov    %eax,-0x18(%ebp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  800df3:	b8 20 00 00 00       	mov    $0x20,%eax
  800df8:	29 f8                	sub    %edi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  800dfa:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800dfd:	88 c1                	mov    %al,%cl
  800dff:	d3 ea                	shr    %cl,%edx
  800e01:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  800e04:	09 ca                	or     %ecx,%edx
  800e06:	89 55 ec             	mov    %edx,-0x14(%ebp)
	      d0 = d0 << bm;
  800e09:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800e0c:	89 f9                	mov    %edi,%ecx
  800e0e:	d3 e2                	shl    %cl,%edx
  800e10:	89 55 f4             	mov    %edx,-0xc(%ebp)
	      n2 = n1 >> b;
  800e13:	89 f2                	mov    %esi,%edx
  800e15:	88 c1                	mov    %al,%cl
  800e17:	d3 ea                	shr    %cl,%edx
  800e19:	89 55 e8             	mov    %edx,-0x18(%ebp)
	      n1 = (n1 << bm) | (n0 >> b);
  800e1c:	89 f2                	mov    %esi,%edx
  800e1e:	89 f9                	mov    %edi,%ecx
  800e20:	d3 e2                	shl    %cl,%edx
  800e22:	8b 75 f0             	mov    -0x10(%ebp),%esi
  800e25:	88 c1                	mov    %al,%cl
  800e27:	d3 ee                	shr    %cl,%esi
  800e29:	09 d6                	or     %edx,%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  800e2b:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  800e2e:	89 f0                	mov    %esi,%eax
  800e30:	89 ca                	mov    %ecx,%edx
  800e32:	f7 75 ec             	divl   -0x14(%ebp)
  800e35:	89 d1                	mov    %edx,%ecx
  800e37:	89 c6                	mov    %eax,%esi
	      umul_ppmm (m1, m0, q0, d0);
  800e39:	f7 65 f4             	mull   -0xc(%ebp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800e3c:	39 d1                	cmp    %edx,%ecx
  800e3e:	72 28                	jb     800e68 <__udivdi3+0x110>
  800e40:	74 1a                	je     800e5c <__udivdi3+0x104>
  800e42:	89 f7                	mov    %esi,%edi
  800e44:	31 f6                	xor    %esi,%esi
  800e46:	eb 80                	jmp    800dc8 <__udivdi3+0x70>
	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  800e48:	31 f6                	xor    %esi,%esi
  800e4a:	bf 01 00 00 00       	mov    $0x1,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800e4f:	89 f8                	mov    %edi,%eax
  800e51:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800e53:	83 c4 10             	add    $0x10,%esp
  800e56:	5e                   	pop    %esi
  800e57:	5f                   	pop    %edi
  800e58:	c9                   	leave  
  800e59:	c3                   	ret    
  800e5a:	66 90                	xchg   %ax,%ax

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  800e5c:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800e5f:	89 f9                	mov    %edi,%ecx
  800e61:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800e63:	39 c2                	cmp    %eax,%edx
  800e65:	73 db                	jae    800e42 <__udivdi3+0xea>
  800e67:	90                   	nop
		{
		  q0--;
  800e68:	8d 7e ff             	lea    -0x1(%esi),%edi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  800e6b:	31 f6                	xor    %esi,%esi
  800e6d:	e9 56 ff ff ff       	jmp    800dc8 <__udivdi3+0x70>
	...

00800e74 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  800e74:	55                   	push   %ebp
  800e75:	89 e5                	mov    %esp,%ebp
  800e77:	57                   	push   %edi
  800e78:	56                   	push   %esi
  800e79:	83 ec 20             	sub    $0x20,%esp
  800e7c:	8b 45 08             	mov    0x8(%ebp),%eax
  800e7f:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  800e82:	89 45 e8             	mov    %eax,-0x18(%ebp)
  800e85:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  800e88:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  800e8b:	8b 7d 14             	mov    0x14(%ebp),%edi
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  800e8e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  n1 = nn.s.high;
  800e91:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800e93:	85 ff                	test   %edi,%edi
  800e95:	75 15                	jne    800eac <__umoddi3+0x38>
    {
      if (d0 > n1)
  800e97:	39 f1                	cmp    %esi,%ecx
  800e99:	0f 86 99 00 00 00    	jbe    800f38 <__umoddi3+0xc4>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800e9f:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  800ea1:	89 d0                	mov    %edx,%eax
  800ea3:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800ea5:	83 c4 20             	add    $0x20,%esp
  800ea8:	5e                   	pop    %esi
  800ea9:	5f                   	pop    %edi
  800eaa:	c9                   	leave  
  800eab:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800eac:	39 f7                	cmp    %esi,%edi
  800eae:	0f 87 a4 00 00 00    	ja     800f58 <__umoddi3+0xe4>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  800eb4:	0f bd c7             	bsr    %edi,%eax
	  if (bm == 0)
  800eb7:	83 f0 1f             	xor    $0x1f,%eax
  800eba:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800ebd:	0f 84 a1 00 00 00    	je     800f64 <__umoddi3+0xf0>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  800ec3:	89 f8                	mov    %edi,%eax
  800ec5:	8a 4d ec             	mov    -0x14(%ebp),%cl
  800ec8:	d3 e0                	shl    %cl,%eax
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  800eca:	bf 20 00 00 00       	mov    $0x20,%edi
  800ecf:	2b 7d ec             	sub    -0x14(%ebp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  800ed2:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800ed5:	89 f9                	mov    %edi,%ecx
  800ed7:	d3 ea                	shr    %cl,%edx
  800ed9:	09 c2                	or     %eax,%edx
  800edb:	89 55 f0             	mov    %edx,-0x10(%ebp)
	      d0 = d0 << bm;
  800ede:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800ee1:	8a 4d ec             	mov    -0x14(%ebp),%cl
  800ee4:	d3 e0                	shl    %cl,%eax
  800ee6:	89 45 f4             	mov    %eax,-0xc(%ebp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  800ee9:	89 f2                	mov    %esi,%edx
  800eeb:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  800eed:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800ef0:	d3 e0                	shl    %cl,%eax
  800ef2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  800ef5:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800ef8:	89 f9                	mov    %edi,%ecx
  800efa:	d3 e8                	shr    %cl,%eax
  800efc:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  800efe:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  800f00:	89 f2                	mov    %esi,%edx
  800f02:	f7 75 f0             	divl   -0x10(%ebp)
  800f05:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  800f07:	f7 65 f4             	mull   -0xc(%ebp)
  800f0a:	89 55 e8             	mov    %edx,-0x18(%ebp)
  800f0d:	89 c1                	mov    %eax,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800f0f:	39 d6                	cmp    %edx,%esi
  800f11:	72 71                	jb     800f84 <__umoddi3+0x110>
  800f13:	74 7f                	je     800f94 <__umoddi3+0x120>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  800f15:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800f18:	29 c8                	sub    %ecx,%eax
  800f1a:	19 d6                	sbb    %edx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  800f1c:	8a 4d ec             	mov    -0x14(%ebp),%cl
  800f1f:	d3 e8                	shr    %cl,%eax
  800f21:	89 f2                	mov    %esi,%edx
  800f23:	89 f9                	mov    %edi,%ecx
  800f25:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  800f27:	09 d0                	or     %edx,%eax
  800f29:	89 f2                	mov    %esi,%edx
  800f2b:	8a 4d ec             	mov    -0x14(%ebp),%cl
  800f2e:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800f30:	83 c4 20             	add    $0x20,%esp
  800f33:	5e                   	pop    %esi
  800f34:	5f                   	pop    %edi
  800f35:	c9                   	leave  
  800f36:	c3                   	ret    
  800f37:	90                   	nop
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  800f38:	85 c9                	test   %ecx,%ecx
  800f3a:	75 0b                	jne    800f47 <__umoddi3+0xd3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  800f3c:	b8 01 00 00 00       	mov    $0x1,%eax
  800f41:	31 d2                	xor    %edx,%edx
  800f43:	f7 f1                	div    %ecx
  800f45:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  800f47:	89 f0                	mov    %esi,%eax
  800f49:	31 d2                	xor    %edx,%edx
  800f4b:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800f4d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800f50:	f7 f1                	div    %ecx
  800f52:	e9 4a ff ff ff       	jmp    800ea1 <__umoddi3+0x2d>
  800f57:	90                   	nop
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  800f58:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800f5a:	83 c4 20             	add    $0x20,%esp
  800f5d:	5e                   	pop    %esi
  800f5e:	5f                   	pop    %edi
  800f5f:	c9                   	leave  
  800f60:	c3                   	ret    
  800f61:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800f64:	39 f7                	cmp    %esi,%edi
  800f66:	72 05                	jb     800f6d <__umoddi3+0xf9>
  800f68:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
  800f6b:	77 0c                	ja     800f79 <__umoddi3+0x105>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  800f6d:	89 f2                	mov    %esi,%edx
  800f6f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800f72:	29 c8                	sub    %ecx,%eax
  800f74:	19 fa                	sbb    %edi,%edx
  800f76:	89 45 f0             	mov    %eax,-0x10(%ebp)

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  800f79:	8b 45 f0             	mov    -0x10(%ebp),%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800f7c:	83 c4 20             	add    $0x20,%esp
  800f7f:	5e                   	pop    %esi
  800f80:	5f                   	pop    %edi
  800f81:	c9                   	leave  
  800f82:	c3                   	ret    
  800f83:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  800f84:	8b 55 e8             	mov    -0x18(%ebp),%edx
  800f87:	89 c1                	mov    %eax,%ecx
  800f89:	2b 4d f4             	sub    -0xc(%ebp),%ecx
  800f8c:	1b 55 f0             	sbb    -0x10(%ebp),%edx
  800f8f:	eb 84                	jmp    800f15 <__umoddi3+0xa1>
  800f91:	8d 76 00             	lea    0x0(%esi),%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800f94:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  800f97:	72 eb                	jb     800f84 <__umoddi3+0x110>
  800f99:	89 f2                	mov    %esi,%edx
  800f9b:	e9 75 ff ff ff       	jmp    800f15 <__umoddi3+0xa1>
