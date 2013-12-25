
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
  800041:	68 e0 1e 80 00       	push   $0x801ee0
  800046:	e8 c1 01 00 00       	call   80020c <cprintf>
	if ((r = sys_page_alloc(0, ROUNDDOWN(addr, PGSIZE),
  80004b:	83 c4 0c             	add    $0xc,%esp
  80004e:	6a 07                	push   $0x7
  800050:	89 d8                	mov    %ebx,%eax
  800052:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800057:	50                   	push   %eax
  800058:	6a 00                	push   $0x0
  80005a:	e8 e5 0b 00 00       	call   800c44 <sys_page_alloc>
  80005f:	83 c4 10             	add    $0x10,%esp
  800062:	85 c0                	test   %eax,%eax
  800064:	79 16                	jns    80007c <handler+0x48>
				PTE_P|PTE_U|PTE_W)) < 0)
		panic("allocating at %x in page fault handler: %e", addr, r);
  800066:	83 ec 0c             	sub    $0xc,%esp
  800069:	50                   	push   %eax
  80006a:	53                   	push   %ebx
  80006b:	68 00 1f 80 00       	push   $0x801f00
  800070:	6a 0e                	push   $0xe
  800072:	68 ea 1e 80 00       	push   $0x801eea
  800077:	e8 b8 00 00 00       	call   800134 <_panic>
	snprintf((char*) addr, 100, "this string was faulted in at %x", addr);
  80007c:	53                   	push   %ebx
  80007d:	68 2c 1f 80 00       	push   $0x801f2c
  800082:	6a 64                	push   $0x64
  800084:	53                   	push   %ebx
  800085:	e8 ca 06 00 00       	call   800754 <snprintf>
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
  80009d:	e8 4e 0d 00 00       	call   800df0 <set_pgfault_handler>
	cprintf("%s\n", (char*)0xDeadBeef);
  8000a2:	83 c4 08             	add    $0x8,%esp
  8000a5:	68 ef be ad de       	push   $0xdeadbeef
  8000aa:	68 fc 1e 80 00       	push   $0x801efc
  8000af:	e8 58 01 00 00       	call   80020c <cprintf>
	cprintf("%s\n", (char*)0xCafeBffe);
  8000b4:	83 c4 08             	add    $0x8,%esp
  8000b7:	68 fe bf fe ca       	push   $0xcafebffe
  8000bc:	68 fc 1e 80 00       	push   $0x801efc
  8000c1:	e8 46 01 00 00       	call   80020c <cprintf>
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
  8000d7:	e8 1d 0b 00 00       	call   800bf9 <sys_getenvid>
  8000dc:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000e1:	89 c2                	mov    %eax,%edx
  8000e3:	c1 e2 07             	shl    $0x7,%edx
  8000e6:	8d 84 82 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,4),%eax
  8000ed:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000f2:	85 f6                	test   %esi,%esi
  8000f4:	7e 07                	jle    8000fd <libmain+0x31>
		binaryname = argv[0];
  8000f6:	8b 03                	mov    (%ebx),%eax
  8000f8:	a3 00 30 80 00       	mov    %eax,0x803000
	// call user main routine
	umain(argc, argv);
  8000fd:	83 ec 08             	sub    $0x8,%esp
  800100:	53                   	push   %ebx
  800101:	56                   	push   %esi
  800102:	e8 8b ff ff ff       	call   800092 <umain>

	// exit gracefully
	exit();
  800107:	e8 0c 00 00 00       	call   800118 <exit>
  80010c:	83 c4 10             	add    $0x10,%esp
}
  80010f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800112:	5b                   	pop    %ebx
  800113:	5e                   	pop    %esi
  800114:	c9                   	leave  
  800115:	c3                   	ret    
	...

00800118 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800118:	55                   	push   %ebp
  800119:	89 e5                	mov    %esp,%ebp
  80011b:	83 ec 08             	sub    $0x8,%esp
	close_all();
  80011e:	e8 6b 0f 00 00       	call   80108e <close_all>
	sys_env_destroy(0);
  800123:	83 ec 0c             	sub    $0xc,%esp
  800126:	6a 00                	push   $0x0
  800128:	e8 aa 0a 00 00       	call   800bd7 <sys_env_destroy>
  80012d:	83 c4 10             	add    $0x10,%esp
}
  800130:	c9                   	leave  
  800131:	c3                   	ret    
	...

00800134 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800134:	55                   	push   %ebp
  800135:	89 e5                	mov    %esp,%ebp
  800137:	56                   	push   %esi
  800138:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800139:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80013c:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  800142:	e8 b2 0a 00 00       	call   800bf9 <sys_getenvid>
  800147:	83 ec 0c             	sub    $0xc,%esp
  80014a:	ff 75 0c             	pushl  0xc(%ebp)
  80014d:	ff 75 08             	pushl  0x8(%ebp)
  800150:	53                   	push   %ebx
  800151:	50                   	push   %eax
  800152:	68 58 1f 80 00       	push   $0x801f58
  800157:	e8 b0 00 00 00       	call   80020c <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80015c:	83 c4 18             	add    $0x18,%esp
  80015f:	56                   	push   %esi
  800160:	ff 75 10             	pushl  0x10(%ebp)
  800163:	e8 53 00 00 00       	call   8001bb <vcprintf>
	cprintf("\n");
  800168:	c7 04 24 d7 23 80 00 	movl   $0x8023d7,(%esp)
  80016f:	e8 98 00 00 00       	call   80020c <cprintf>
  800174:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800177:	cc                   	int3   
  800178:	eb fd                	jmp    800177 <_panic+0x43>
	...

0080017c <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80017c:	55                   	push   %ebp
  80017d:	89 e5                	mov    %esp,%ebp
  80017f:	53                   	push   %ebx
  800180:	83 ec 04             	sub    $0x4,%esp
  800183:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800186:	8b 03                	mov    (%ebx),%eax
  800188:	8b 55 08             	mov    0x8(%ebp),%edx
  80018b:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  80018f:	40                   	inc    %eax
  800190:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  800192:	3d ff 00 00 00       	cmp    $0xff,%eax
  800197:	75 1a                	jne    8001b3 <putch+0x37>
		sys_cputs(b->buf, b->idx);
  800199:	83 ec 08             	sub    $0x8,%esp
  80019c:	68 ff 00 00 00       	push   $0xff
  8001a1:	8d 43 08             	lea    0x8(%ebx),%eax
  8001a4:	50                   	push   %eax
  8001a5:	e8 e3 09 00 00       	call   800b8d <sys_cputs>
		b->idx = 0;
  8001aa:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001b0:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8001b3:	ff 43 04             	incl   0x4(%ebx)
}
  8001b6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001b9:	c9                   	leave  
  8001ba:	c3                   	ret    

008001bb <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001bb:	55                   	push   %ebp
  8001bc:	89 e5                	mov    %esp,%ebp
  8001be:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001c4:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001cb:	00 00 00 
	b.cnt = 0;
  8001ce:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001d5:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001d8:	ff 75 0c             	pushl  0xc(%ebp)
  8001db:	ff 75 08             	pushl  0x8(%ebp)
  8001de:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001e4:	50                   	push   %eax
  8001e5:	68 7c 01 80 00       	push   $0x80017c
  8001ea:	e8 82 01 00 00       	call   800371 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001ef:	83 c4 08             	add    $0x8,%esp
  8001f2:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8001f8:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001fe:	50                   	push   %eax
  8001ff:	e8 89 09 00 00       	call   800b8d <sys_cputs>

	return b.cnt;
}
  800204:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80020a:	c9                   	leave  
  80020b:	c3                   	ret    

0080020c <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80020c:	55                   	push   %ebp
  80020d:	89 e5                	mov    %esp,%ebp
  80020f:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800212:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800215:	50                   	push   %eax
  800216:	ff 75 08             	pushl  0x8(%ebp)
  800219:	e8 9d ff ff ff       	call   8001bb <vcprintf>
	va_end(ap);

	return cnt;
}
  80021e:	c9                   	leave  
  80021f:	c3                   	ret    

00800220 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800220:	55                   	push   %ebp
  800221:	89 e5                	mov    %esp,%ebp
  800223:	57                   	push   %edi
  800224:	56                   	push   %esi
  800225:	53                   	push   %ebx
  800226:	83 ec 2c             	sub    $0x2c,%esp
  800229:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80022c:	89 d6                	mov    %edx,%esi
  80022e:	8b 45 08             	mov    0x8(%ebp),%eax
  800231:	8b 55 0c             	mov    0xc(%ebp),%edx
  800234:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800237:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80023a:	8b 45 10             	mov    0x10(%ebp),%eax
  80023d:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800240:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800243:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800246:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  80024d:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
  800250:	72 0c                	jb     80025e <printnum+0x3e>
  800252:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  800255:	76 07                	jbe    80025e <printnum+0x3e>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800257:	4b                   	dec    %ebx
  800258:	85 db                	test   %ebx,%ebx
  80025a:	7f 31                	jg     80028d <printnum+0x6d>
  80025c:	eb 3f                	jmp    80029d <printnum+0x7d>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80025e:	83 ec 0c             	sub    $0xc,%esp
  800261:	57                   	push   %edi
  800262:	4b                   	dec    %ebx
  800263:	53                   	push   %ebx
  800264:	50                   	push   %eax
  800265:	83 ec 08             	sub    $0x8,%esp
  800268:	ff 75 d4             	pushl  -0x2c(%ebp)
  80026b:	ff 75 d0             	pushl  -0x30(%ebp)
  80026e:	ff 75 dc             	pushl  -0x24(%ebp)
  800271:	ff 75 d8             	pushl  -0x28(%ebp)
  800274:	e8 1b 1a 00 00       	call   801c94 <__udivdi3>
  800279:	83 c4 18             	add    $0x18,%esp
  80027c:	52                   	push   %edx
  80027d:	50                   	push   %eax
  80027e:	89 f2                	mov    %esi,%edx
  800280:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800283:	e8 98 ff ff ff       	call   800220 <printnum>
  800288:	83 c4 20             	add    $0x20,%esp
  80028b:	eb 10                	jmp    80029d <printnum+0x7d>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80028d:	83 ec 08             	sub    $0x8,%esp
  800290:	56                   	push   %esi
  800291:	57                   	push   %edi
  800292:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800295:	4b                   	dec    %ebx
  800296:	83 c4 10             	add    $0x10,%esp
  800299:	85 db                	test   %ebx,%ebx
  80029b:	7f f0                	jg     80028d <printnum+0x6d>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80029d:	83 ec 08             	sub    $0x8,%esp
  8002a0:	56                   	push   %esi
  8002a1:	83 ec 04             	sub    $0x4,%esp
  8002a4:	ff 75 d4             	pushl  -0x2c(%ebp)
  8002a7:	ff 75 d0             	pushl  -0x30(%ebp)
  8002aa:	ff 75 dc             	pushl  -0x24(%ebp)
  8002ad:	ff 75 d8             	pushl  -0x28(%ebp)
  8002b0:	e8 fb 1a 00 00       	call   801db0 <__umoddi3>
  8002b5:	83 c4 14             	add    $0x14,%esp
  8002b8:	0f be 80 7b 1f 80 00 	movsbl 0x801f7b(%eax),%eax
  8002bf:	50                   	push   %eax
  8002c0:	ff 55 e4             	call   *-0x1c(%ebp)
  8002c3:	83 c4 10             	add    $0x10,%esp
}
  8002c6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002c9:	5b                   	pop    %ebx
  8002ca:	5e                   	pop    %esi
  8002cb:	5f                   	pop    %edi
  8002cc:	c9                   	leave  
  8002cd:	c3                   	ret    

008002ce <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002ce:	55                   	push   %ebp
  8002cf:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002d1:	83 fa 01             	cmp    $0x1,%edx
  8002d4:	7e 0e                	jle    8002e4 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8002d6:	8b 10                	mov    (%eax),%edx
  8002d8:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002db:	89 08                	mov    %ecx,(%eax)
  8002dd:	8b 02                	mov    (%edx),%eax
  8002df:	8b 52 04             	mov    0x4(%edx),%edx
  8002e2:	eb 22                	jmp    800306 <getuint+0x38>
	else if (lflag)
  8002e4:	85 d2                	test   %edx,%edx
  8002e6:	74 10                	je     8002f8 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8002e8:	8b 10                	mov    (%eax),%edx
  8002ea:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002ed:	89 08                	mov    %ecx,(%eax)
  8002ef:	8b 02                	mov    (%edx),%eax
  8002f1:	ba 00 00 00 00       	mov    $0x0,%edx
  8002f6:	eb 0e                	jmp    800306 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8002f8:	8b 10                	mov    (%eax),%edx
  8002fa:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002fd:	89 08                	mov    %ecx,(%eax)
  8002ff:	8b 02                	mov    (%edx),%eax
  800301:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800306:	c9                   	leave  
  800307:	c3                   	ret    

00800308 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  800308:	55                   	push   %ebp
  800309:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80030b:	83 fa 01             	cmp    $0x1,%edx
  80030e:	7e 0e                	jle    80031e <getint+0x16>
		return va_arg(*ap, long long);
  800310:	8b 10                	mov    (%eax),%edx
  800312:	8d 4a 08             	lea    0x8(%edx),%ecx
  800315:	89 08                	mov    %ecx,(%eax)
  800317:	8b 02                	mov    (%edx),%eax
  800319:	8b 52 04             	mov    0x4(%edx),%edx
  80031c:	eb 1a                	jmp    800338 <getint+0x30>
	else if (lflag)
  80031e:	85 d2                	test   %edx,%edx
  800320:	74 0c                	je     80032e <getint+0x26>
		return va_arg(*ap, long);
  800322:	8b 10                	mov    (%eax),%edx
  800324:	8d 4a 04             	lea    0x4(%edx),%ecx
  800327:	89 08                	mov    %ecx,(%eax)
  800329:	8b 02                	mov    (%edx),%eax
  80032b:	99                   	cltd   
  80032c:	eb 0a                	jmp    800338 <getint+0x30>
	else
		return va_arg(*ap, int);
  80032e:	8b 10                	mov    (%eax),%edx
  800330:	8d 4a 04             	lea    0x4(%edx),%ecx
  800333:	89 08                	mov    %ecx,(%eax)
  800335:	8b 02                	mov    (%edx),%eax
  800337:	99                   	cltd   
}
  800338:	c9                   	leave  
  800339:	c3                   	ret    

0080033a <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80033a:	55                   	push   %ebp
  80033b:	89 e5                	mov    %esp,%ebp
  80033d:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800340:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  800343:	8b 10                	mov    (%eax),%edx
  800345:	3b 50 04             	cmp    0x4(%eax),%edx
  800348:	73 08                	jae    800352 <sprintputch+0x18>
		*b->buf++ = ch;
  80034a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80034d:	88 0a                	mov    %cl,(%edx)
  80034f:	42                   	inc    %edx
  800350:	89 10                	mov    %edx,(%eax)
}
  800352:	c9                   	leave  
  800353:	c3                   	ret    

00800354 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800354:	55                   	push   %ebp
  800355:	89 e5                	mov    %esp,%ebp
  800357:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80035a:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80035d:	50                   	push   %eax
  80035e:	ff 75 10             	pushl  0x10(%ebp)
  800361:	ff 75 0c             	pushl  0xc(%ebp)
  800364:	ff 75 08             	pushl  0x8(%ebp)
  800367:	e8 05 00 00 00       	call   800371 <vprintfmt>
	va_end(ap);
  80036c:	83 c4 10             	add    $0x10,%esp
}
  80036f:	c9                   	leave  
  800370:	c3                   	ret    

00800371 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800371:	55                   	push   %ebp
  800372:	89 e5                	mov    %esp,%ebp
  800374:	57                   	push   %edi
  800375:	56                   	push   %esi
  800376:	53                   	push   %ebx
  800377:	83 ec 2c             	sub    $0x2c,%esp
  80037a:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80037d:	8b 75 10             	mov    0x10(%ebp),%esi
  800380:	eb 13                	jmp    800395 <vprintfmt+0x24>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800382:	85 c0                	test   %eax,%eax
  800384:	0f 84 6d 03 00 00    	je     8006f7 <vprintfmt+0x386>
				return;
			putch(ch, putdat);
  80038a:	83 ec 08             	sub    $0x8,%esp
  80038d:	57                   	push   %edi
  80038e:	50                   	push   %eax
  80038f:	ff 55 08             	call   *0x8(%ebp)
  800392:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800395:	0f b6 06             	movzbl (%esi),%eax
  800398:	46                   	inc    %esi
  800399:	83 f8 25             	cmp    $0x25,%eax
  80039c:	75 e4                	jne    800382 <vprintfmt+0x11>
  80039e:	c6 45 dc 20          	movb   $0x20,-0x24(%ebp)
  8003a2:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  8003a9:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  8003b0:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  8003b7:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003bc:	eb 28                	jmp    8003e6 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003be:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  8003c0:	c6 45 dc 2d          	movb   $0x2d,-0x24(%ebp)
  8003c4:	eb 20                	jmp    8003e6 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003c6:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8003c8:	c6 45 dc 30          	movb   $0x30,-0x24(%ebp)
  8003cc:	eb 18                	jmp    8003e6 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ce:	89 de                	mov    %ebx,%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  8003d0:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8003d7:	eb 0d                	jmp    8003e6 <vprintfmt+0x75>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  8003d9:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8003dc:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003df:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003e6:	8a 06                	mov    (%esi),%al
  8003e8:	0f b6 d0             	movzbl %al,%edx
  8003eb:	8d 5e 01             	lea    0x1(%esi),%ebx
  8003ee:	83 e8 23             	sub    $0x23,%eax
  8003f1:	3c 55                	cmp    $0x55,%al
  8003f3:	0f 87 e0 02 00 00    	ja     8006d9 <vprintfmt+0x368>
  8003f9:	0f b6 c0             	movzbl %al,%eax
  8003fc:	ff 24 85 c0 20 80 00 	jmp    *0x8020c0(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800403:	83 ea 30             	sub    $0x30,%edx
  800406:	89 55 d4             	mov    %edx,-0x2c(%ebp)
				ch = *fmt;
  800409:	0f be 03             	movsbl (%ebx),%eax
				if (ch < '0' || ch > '9')
  80040c:	8d 50 d0             	lea    -0x30(%eax),%edx
  80040f:	83 fa 09             	cmp    $0x9,%edx
  800412:	77 44                	ja     800458 <vprintfmt+0xe7>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800414:	89 de                	mov    %ebx,%esi
  800416:	8b 55 d4             	mov    -0x2c(%ebp),%edx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800419:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
  80041a:	8d 14 92             	lea    (%edx,%edx,4),%edx
  80041d:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
  800421:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800424:	8d 58 d0             	lea    -0x30(%eax),%ebx
  800427:	83 fb 09             	cmp    $0x9,%ebx
  80042a:	76 ed                	jbe    800419 <vprintfmt+0xa8>
  80042c:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  80042f:	eb 29                	jmp    80045a <vprintfmt+0xe9>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800431:	8b 45 14             	mov    0x14(%ebp),%eax
  800434:	8d 50 04             	lea    0x4(%eax),%edx
  800437:	89 55 14             	mov    %edx,0x14(%ebp)
  80043a:	8b 00                	mov    (%eax),%eax
  80043c:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80043f:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800441:	eb 17                	jmp    80045a <vprintfmt+0xe9>

		case '.':
			if (width < 0)
  800443:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800447:	78 85                	js     8003ce <vprintfmt+0x5d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800449:	89 de                	mov    %ebx,%esi
  80044b:	eb 99                	jmp    8003e6 <vprintfmt+0x75>
  80044d:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80044f:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  800456:	eb 8e                	jmp    8003e6 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800458:	89 de                	mov    %ebx,%esi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  80045a:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80045e:	79 86                	jns    8003e6 <vprintfmt+0x75>
  800460:	e9 74 ff ff ff       	jmp    8003d9 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800465:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800466:	89 de                	mov    %ebx,%esi
  800468:	e9 79 ff ff ff       	jmp    8003e6 <vprintfmt+0x75>
  80046d:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800470:	8b 45 14             	mov    0x14(%ebp),%eax
  800473:	8d 50 04             	lea    0x4(%eax),%edx
  800476:	89 55 14             	mov    %edx,0x14(%ebp)
  800479:	83 ec 08             	sub    $0x8,%esp
  80047c:	57                   	push   %edi
  80047d:	ff 30                	pushl  (%eax)
  80047f:	ff 55 08             	call   *0x8(%ebp)
			break;
  800482:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800485:	8b 75 d8             	mov    -0x28(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800488:	e9 08 ff ff ff       	jmp    800395 <vprintfmt+0x24>
  80048d:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  800490:	8b 45 14             	mov    0x14(%ebp),%eax
  800493:	8d 50 04             	lea    0x4(%eax),%edx
  800496:	89 55 14             	mov    %edx,0x14(%ebp)
  800499:	8b 00                	mov    (%eax),%eax
  80049b:	85 c0                	test   %eax,%eax
  80049d:	79 02                	jns    8004a1 <vprintfmt+0x130>
  80049f:	f7 d8                	neg    %eax
  8004a1:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004a3:	83 f8 0f             	cmp    $0xf,%eax
  8004a6:	7f 0b                	jg     8004b3 <vprintfmt+0x142>
  8004a8:	8b 04 85 20 22 80 00 	mov    0x802220(,%eax,4),%eax
  8004af:	85 c0                	test   %eax,%eax
  8004b1:	75 1a                	jne    8004cd <vprintfmt+0x15c>
				printfmt(putch, putdat, "error %d", err);
  8004b3:	52                   	push   %edx
  8004b4:	68 93 1f 80 00       	push   $0x801f93
  8004b9:	57                   	push   %edi
  8004ba:	ff 75 08             	pushl  0x8(%ebp)
  8004bd:	e8 92 fe ff ff       	call   800354 <printfmt>
  8004c2:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004c5:	8b 75 d8             	mov    -0x28(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8004c8:	e9 c8 fe ff ff       	jmp    800395 <vprintfmt+0x24>
			else
				printfmt(putch, putdat, "%s", p);
  8004cd:	50                   	push   %eax
  8004ce:	68 a5 23 80 00       	push   $0x8023a5
  8004d3:	57                   	push   %edi
  8004d4:	ff 75 08             	pushl  0x8(%ebp)
  8004d7:	e8 78 fe ff ff       	call   800354 <printfmt>
  8004dc:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004df:	8b 75 d8             	mov    -0x28(%ebp),%esi
  8004e2:	e9 ae fe ff ff       	jmp    800395 <vprintfmt+0x24>
  8004e7:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  8004ea:	89 de                	mov    %ebx,%esi
  8004ec:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  8004ef:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004f2:	8b 45 14             	mov    0x14(%ebp),%eax
  8004f5:	8d 50 04             	lea    0x4(%eax),%edx
  8004f8:	89 55 14             	mov    %edx,0x14(%ebp)
  8004fb:	8b 00                	mov    (%eax),%eax
  8004fd:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800500:	85 c0                	test   %eax,%eax
  800502:	75 07                	jne    80050b <vprintfmt+0x19a>
				p = "(null)";
  800504:	c7 45 d0 8c 1f 80 00 	movl   $0x801f8c,-0x30(%ebp)
			if (width > 0 && padc != '-')
  80050b:	85 db                	test   %ebx,%ebx
  80050d:	7e 42                	jle    800551 <vprintfmt+0x1e0>
  80050f:	80 7d dc 2d          	cmpb   $0x2d,-0x24(%ebp)
  800513:	74 3c                	je     800551 <vprintfmt+0x1e0>
				for (width -= strnlen(p, precision); width > 0; width--)
  800515:	83 ec 08             	sub    $0x8,%esp
  800518:	51                   	push   %ecx
  800519:	ff 75 d0             	pushl  -0x30(%ebp)
  80051c:	e8 6f 02 00 00       	call   800790 <strnlen>
  800521:	29 c3                	sub    %eax,%ebx
  800523:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800526:	83 c4 10             	add    $0x10,%esp
  800529:	85 db                	test   %ebx,%ebx
  80052b:	7e 24                	jle    800551 <vprintfmt+0x1e0>
					putch(padc, putdat);
  80052d:	0f be 5d dc          	movsbl -0x24(%ebp),%ebx
  800531:	89 75 dc             	mov    %esi,-0x24(%ebp)
  800534:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  800537:	83 ec 08             	sub    $0x8,%esp
  80053a:	57                   	push   %edi
  80053b:	53                   	push   %ebx
  80053c:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80053f:	4e                   	dec    %esi
  800540:	83 c4 10             	add    $0x10,%esp
  800543:	85 f6                	test   %esi,%esi
  800545:	7f f0                	jg     800537 <vprintfmt+0x1c6>
  800547:	8b 75 dc             	mov    -0x24(%ebp),%esi
  80054a:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800551:	8b 55 d0             	mov    -0x30(%ebp),%edx
  800554:	0f be 02             	movsbl (%edx),%eax
  800557:	85 c0                	test   %eax,%eax
  800559:	75 47                	jne    8005a2 <vprintfmt+0x231>
  80055b:	eb 37                	jmp    800594 <vprintfmt+0x223>
				if (altflag && (ch < ' ' || ch > '~'))
  80055d:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800561:	74 16                	je     800579 <vprintfmt+0x208>
  800563:	8d 50 e0             	lea    -0x20(%eax),%edx
  800566:	83 fa 5e             	cmp    $0x5e,%edx
  800569:	76 0e                	jbe    800579 <vprintfmt+0x208>
					putch('?', putdat);
  80056b:	83 ec 08             	sub    $0x8,%esp
  80056e:	57                   	push   %edi
  80056f:	6a 3f                	push   $0x3f
  800571:	ff 55 08             	call   *0x8(%ebp)
  800574:	83 c4 10             	add    $0x10,%esp
  800577:	eb 0b                	jmp    800584 <vprintfmt+0x213>
				else
					putch(ch, putdat);
  800579:	83 ec 08             	sub    $0x8,%esp
  80057c:	57                   	push   %edi
  80057d:	50                   	push   %eax
  80057e:	ff 55 08             	call   *0x8(%ebp)
  800581:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800584:	ff 4d e4             	decl   -0x1c(%ebp)
  800587:	0f be 03             	movsbl (%ebx),%eax
  80058a:	85 c0                	test   %eax,%eax
  80058c:	74 03                	je     800591 <vprintfmt+0x220>
  80058e:	43                   	inc    %ebx
  80058f:	eb 1b                	jmp    8005ac <vprintfmt+0x23b>
  800591:	8b 75 dc             	mov    -0x24(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800594:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800598:	7f 1e                	jg     8005b8 <vprintfmt+0x247>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80059a:	8b 75 d8             	mov    -0x28(%ebp),%esi
  80059d:	e9 f3 fd ff ff       	jmp    800395 <vprintfmt+0x24>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005a2:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  8005a5:	43                   	inc    %ebx
  8005a6:	89 75 dc             	mov    %esi,-0x24(%ebp)
  8005a9:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  8005ac:	85 f6                	test   %esi,%esi
  8005ae:	78 ad                	js     80055d <vprintfmt+0x1ec>
  8005b0:	4e                   	dec    %esi
  8005b1:	79 aa                	jns    80055d <vprintfmt+0x1ec>
  8005b3:	8b 75 dc             	mov    -0x24(%ebp),%esi
  8005b6:	eb dc                	jmp    800594 <vprintfmt+0x223>
  8005b8:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8005bb:	83 ec 08             	sub    $0x8,%esp
  8005be:	57                   	push   %edi
  8005bf:	6a 20                	push   $0x20
  8005c1:	ff 55 08             	call   *0x8(%ebp)
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005c4:	4b                   	dec    %ebx
  8005c5:	83 c4 10             	add    $0x10,%esp
  8005c8:	85 db                	test   %ebx,%ebx
  8005ca:	7f ef                	jg     8005bb <vprintfmt+0x24a>
  8005cc:	e9 c4 fd ff ff       	jmp    800395 <vprintfmt+0x24>
  8005d1:	89 5d d8             	mov    %ebx,-0x28(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8005d4:	89 ca                	mov    %ecx,%edx
  8005d6:	8d 45 14             	lea    0x14(%ebp),%eax
  8005d9:	e8 2a fd ff ff       	call   800308 <getint>
  8005de:	89 c3                	mov    %eax,%ebx
  8005e0:	89 d6                	mov    %edx,%esi
			if ((long long) num < 0) {
  8005e2:	85 d2                	test   %edx,%edx
  8005e4:	78 0a                	js     8005f0 <vprintfmt+0x27f>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8005e6:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005eb:	e9 b0 00 00 00       	jmp    8006a0 <vprintfmt+0x32f>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  8005f0:	83 ec 08             	sub    $0x8,%esp
  8005f3:	57                   	push   %edi
  8005f4:	6a 2d                	push   $0x2d
  8005f6:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8005f9:	f7 db                	neg    %ebx
  8005fb:	83 d6 00             	adc    $0x0,%esi
  8005fe:	f7 de                	neg    %esi
  800600:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800603:	b8 0a 00 00 00       	mov    $0xa,%eax
  800608:	e9 93 00 00 00       	jmp    8006a0 <vprintfmt+0x32f>
  80060d:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800610:	89 ca                	mov    %ecx,%edx
  800612:	8d 45 14             	lea    0x14(%ebp),%eax
  800615:	e8 b4 fc ff ff       	call   8002ce <getuint>
  80061a:	89 c3                	mov    %eax,%ebx
  80061c:	89 d6                	mov    %edx,%esi
			base = 10;
  80061e:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  800623:	eb 7b                	jmp    8006a0 <vprintfmt+0x32f>
  800625:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
  800628:	89 ca                	mov    %ecx,%edx
  80062a:	8d 45 14             	lea    0x14(%ebp),%eax
  80062d:	e8 d6 fc ff ff       	call   800308 <getint>
  800632:	89 c3                	mov    %eax,%ebx
  800634:	89 d6                	mov    %edx,%esi
            if ((long long) num < 0) {
  800636:	85 d2                	test   %edx,%edx
  800638:	78 07                	js     800641 <vprintfmt+0x2d0>
                putch('-', putdat);
                num = -(long long) num;
            }
            base = 8;
  80063a:	b8 08 00 00 00       	mov    $0x8,%eax
  80063f:	eb 5f                	jmp    8006a0 <vprintfmt+0x32f>
		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
            if ((long long) num < 0) {
                putch('-', putdat);
  800641:	83 ec 08             	sub    $0x8,%esp
  800644:	57                   	push   %edi
  800645:	6a 2d                	push   $0x2d
  800647:	ff 55 08             	call   *0x8(%ebp)
                num = -(long long) num;
  80064a:	f7 db                	neg    %ebx
  80064c:	83 d6 00             	adc    $0x0,%esi
  80064f:	f7 de                	neg    %esi
  800651:	83 c4 10             	add    $0x10,%esp
            }
            base = 8;
  800654:	b8 08 00 00 00       	mov    $0x8,%eax
  800659:	eb 45                	jmp    8006a0 <vprintfmt+0x32f>
  80065b:	89 5d d8             	mov    %ebx,-0x28(%ebp)
            goto number;

        // pointer
		case 'p':
			putch('0', putdat);
  80065e:	83 ec 08             	sub    $0x8,%esp
  800661:	57                   	push   %edi
  800662:	6a 30                	push   $0x30
  800664:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800667:	83 c4 08             	add    $0x8,%esp
  80066a:	57                   	push   %edi
  80066b:	6a 78                	push   $0x78
  80066d:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800670:	8b 45 14             	mov    0x14(%ebp),%eax
  800673:	8d 50 04             	lea    0x4(%eax),%edx
  800676:	89 55 14             	mov    %edx,0x14(%ebp)

        // pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800679:	8b 18                	mov    (%eax),%ebx
  80067b:	be 00 00 00 00       	mov    $0x0,%esi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800680:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800683:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800688:	eb 16                	jmp    8006a0 <vprintfmt+0x32f>
  80068a:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80068d:	89 ca                	mov    %ecx,%edx
  80068f:	8d 45 14             	lea    0x14(%ebp),%eax
  800692:	e8 37 fc ff ff       	call   8002ce <getuint>
  800697:	89 c3                	mov    %eax,%ebx
  800699:	89 d6                	mov    %edx,%esi
			base = 16;
  80069b:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006a0:	83 ec 0c             	sub    $0xc,%esp
  8006a3:	0f be 55 dc          	movsbl -0x24(%ebp),%edx
  8006a7:	52                   	push   %edx
  8006a8:	ff 75 e4             	pushl  -0x1c(%ebp)
  8006ab:	50                   	push   %eax
  8006ac:	56                   	push   %esi
  8006ad:	53                   	push   %ebx
  8006ae:	89 fa                	mov    %edi,%edx
  8006b0:	8b 45 08             	mov    0x8(%ebp),%eax
  8006b3:	e8 68 fb ff ff       	call   800220 <printnum>
			break;
  8006b8:	83 c4 20             	add    $0x20,%esp
  8006bb:	8b 75 d8             	mov    -0x28(%ebp),%esi
  8006be:	e9 d2 fc ff ff       	jmp    800395 <vprintfmt+0x24>
  8006c3:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006c6:	83 ec 08             	sub    $0x8,%esp
  8006c9:	57                   	push   %edi
  8006ca:	52                   	push   %edx
  8006cb:	ff 55 08             	call   *0x8(%ebp)
			break;
  8006ce:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006d1:	8b 75 d8             	mov    -0x28(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8006d4:	e9 bc fc ff ff       	jmp    800395 <vprintfmt+0x24>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8006d9:	83 ec 08             	sub    $0x8,%esp
  8006dc:	57                   	push   %edi
  8006dd:	6a 25                	push   $0x25
  8006df:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006e2:	83 c4 10             	add    $0x10,%esp
  8006e5:	eb 02                	jmp    8006e9 <vprintfmt+0x378>
  8006e7:	89 c6                	mov    %eax,%esi
  8006e9:	8d 46 ff             	lea    -0x1(%esi),%eax
  8006ec:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  8006f0:	75 f5                	jne    8006e7 <vprintfmt+0x376>
  8006f2:	e9 9e fc ff ff       	jmp    800395 <vprintfmt+0x24>
				/* do nothing */;
			break;
		}
	}
}
  8006f7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006fa:	5b                   	pop    %ebx
  8006fb:	5e                   	pop    %esi
  8006fc:	5f                   	pop    %edi
  8006fd:	c9                   	leave  
  8006fe:	c3                   	ret    

008006ff <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006ff:	55                   	push   %ebp
  800700:	89 e5                	mov    %esp,%ebp
  800702:	83 ec 18             	sub    $0x18,%esp
  800705:	8b 45 08             	mov    0x8(%ebp),%eax
  800708:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80070b:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80070e:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800712:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800715:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80071c:	85 c0                	test   %eax,%eax
  80071e:	74 26                	je     800746 <vsnprintf+0x47>
  800720:	85 d2                	test   %edx,%edx
  800722:	7e 29                	jle    80074d <vsnprintf+0x4e>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800724:	ff 75 14             	pushl  0x14(%ebp)
  800727:	ff 75 10             	pushl  0x10(%ebp)
  80072a:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80072d:	50                   	push   %eax
  80072e:	68 3a 03 80 00       	push   $0x80033a
  800733:	e8 39 fc ff ff       	call   800371 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800738:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80073b:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80073e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800741:	83 c4 10             	add    $0x10,%esp
  800744:	eb 0c                	jmp    800752 <vsnprintf+0x53>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800746:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80074b:	eb 05                	jmp    800752 <vsnprintf+0x53>
  80074d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800752:	c9                   	leave  
  800753:	c3                   	ret    

00800754 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800754:	55                   	push   %ebp
  800755:	89 e5                	mov    %esp,%ebp
  800757:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80075a:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80075d:	50                   	push   %eax
  80075e:	ff 75 10             	pushl  0x10(%ebp)
  800761:	ff 75 0c             	pushl  0xc(%ebp)
  800764:	ff 75 08             	pushl  0x8(%ebp)
  800767:	e8 93 ff ff ff       	call   8006ff <vsnprintf>
	va_end(ap);

	return rc;
}
  80076c:	c9                   	leave  
  80076d:	c3                   	ret    
	...

00800770 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800770:	55                   	push   %ebp
  800771:	89 e5                	mov    %esp,%ebp
  800773:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800776:	80 3a 00             	cmpb   $0x0,(%edx)
  800779:	74 0e                	je     800789 <strlen+0x19>
  80077b:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800780:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800781:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800785:	75 f9                	jne    800780 <strlen+0x10>
  800787:	eb 05                	jmp    80078e <strlen+0x1e>
  800789:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  80078e:	c9                   	leave  
  80078f:	c3                   	ret    

00800790 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800790:	55                   	push   %ebp
  800791:	89 e5                	mov    %esp,%ebp
  800793:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800796:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800799:	85 d2                	test   %edx,%edx
  80079b:	74 17                	je     8007b4 <strnlen+0x24>
  80079d:	80 39 00             	cmpb   $0x0,(%ecx)
  8007a0:	74 19                	je     8007bb <strnlen+0x2b>
  8007a2:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  8007a7:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007a8:	39 d0                	cmp    %edx,%eax
  8007aa:	74 14                	je     8007c0 <strnlen+0x30>
  8007ac:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8007b0:	75 f5                	jne    8007a7 <strnlen+0x17>
  8007b2:	eb 0c                	jmp    8007c0 <strnlen+0x30>
  8007b4:	b8 00 00 00 00       	mov    $0x0,%eax
  8007b9:	eb 05                	jmp    8007c0 <strnlen+0x30>
  8007bb:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  8007c0:	c9                   	leave  
  8007c1:	c3                   	ret    

008007c2 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007c2:	55                   	push   %ebp
  8007c3:	89 e5                	mov    %esp,%ebp
  8007c5:	53                   	push   %ebx
  8007c6:	8b 45 08             	mov    0x8(%ebp),%eax
  8007c9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007cc:	ba 00 00 00 00       	mov    $0x0,%edx
  8007d1:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  8007d4:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  8007d7:	42                   	inc    %edx
  8007d8:	84 c9                	test   %cl,%cl
  8007da:	75 f5                	jne    8007d1 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8007dc:	5b                   	pop    %ebx
  8007dd:	c9                   	leave  
  8007de:	c3                   	ret    

008007df <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007df:	55                   	push   %ebp
  8007e0:	89 e5                	mov    %esp,%ebp
  8007e2:	53                   	push   %ebx
  8007e3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007e6:	53                   	push   %ebx
  8007e7:	e8 84 ff ff ff       	call   800770 <strlen>
  8007ec:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8007ef:	ff 75 0c             	pushl  0xc(%ebp)
  8007f2:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  8007f5:	50                   	push   %eax
  8007f6:	e8 c7 ff ff ff       	call   8007c2 <strcpy>
	return dst;
}
  8007fb:	89 d8                	mov    %ebx,%eax
  8007fd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800800:	c9                   	leave  
  800801:	c3                   	ret    

00800802 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800802:	55                   	push   %ebp
  800803:	89 e5                	mov    %esp,%ebp
  800805:	56                   	push   %esi
  800806:	53                   	push   %ebx
  800807:	8b 45 08             	mov    0x8(%ebp),%eax
  80080a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80080d:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800810:	85 f6                	test   %esi,%esi
  800812:	74 15                	je     800829 <strncpy+0x27>
  800814:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  800819:	8a 1a                	mov    (%edx),%bl
  80081b:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80081e:	80 3a 01             	cmpb   $0x1,(%edx)
  800821:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800824:	41                   	inc    %ecx
  800825:	39 ce                	cmp    %ecx,%esi
  800827:	77 f0                	ja     800819 <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800829:	5b                   	pop    %ebx
  80082a:	5e                   	pop    %esi
  80082b:	c9                   	leave  
  80082c:	c3                   	ret    

0080082d <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80082d:	55                   	push   %ebp
  80082e:	89 e5                	mov    %esp,%ebp
  800830:	57                   	push   %edi
  800831:	56                   	push   %esi
  800832:	53                   	push   %ebx
  800833:	8b 7d 08             	mov    0x8(%ebp),%edi
  800836:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800839:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80083c:	85 f6                	test   %esi,%esi
  80083e:	74 32                	je     800872 <strlcpy+0x45>
		while (--size > 0 && *src != '\0')
  800840:	83 fe 01             	cmp    $0x1,%esi
  800843:	74 22                	je     800867 <strlcpy+0x3a>
  800845:	8a 0b                	mov    (%ebx),%cl
  800847:	84 c9                	test   %cl,%cl
  800849:	74 20                	je     80086b <strlcpy+0x3e>
  80084b:	89 f8                	mov    %edi,%eax
  80084d:	ba 00 00 00 00       	mov    $0x0,%edx
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
  800852:	83 ee 02             	sub    $0x2,%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800855:	88 08                	mov    %cl,(%eax)
  800857:	40                   	inc    %eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800858:	39 f2                	cmp    %esi,%edx
  80085a:	74 11                	je     80086d <strlcpy+0x40>
  80085c:	8a 4c 13 01          	mov    0x1(%ebx,%edx,1),%cl
  800860:	42                   	inc    %edx
  800861:	84 c9                	test   %cl,%cl
  800863:	75 f0                	jne    800855 <strlcpy+0x28>
  800865:	eb 06                	jmp    80086d <strlcpy+0x40>
  800867:	89 f8                	mov    %edi,%eax
  800869:	eb 02                	jmp    80086d <strlcpy+0x40>
  80086b:	89 f8                	mov    %edi,%eax
			*dst++ = *src++;
		*dst = '\0';
  80086d:	c6 00 00             	movb   $0x0,(%eax)
  800870:	eb 02                	jmp    800874 <strlcpy+0x47>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800872:	89 f8                	mov    %edi,%eax
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
		*dst = '\0';
	}
	return dst - dst_in;
  800874:	29 f8                	sub    %edi,%eax
}
  800876:	5b                   	pop    %ebx
  800877:	5e                   	pop    %esi
  800878:	5f                   	pop    %edi
  800879:	c9                   	leave  
  80087a:	c3                   	ret    

0080087b <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80087b:	55                   	push   %ebp
  80087c:	89 e5                	mov    %esp,%ebp
  80087e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800881:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800884:	8a 01                	mov    (%ecx),%al
  800886:	84 c0                	test   %al,%al
  800888:	74 10                	je     80089a <strcmp+0x1f>
  80088a:	3a 02                	cmp    (%edx),%al
  80088c:	75 0c                	jne    80089a <strcmp+0x1f>
		p++, q++;
  80088e:	41                   	inc    %ecx
  80088f:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800890:	8a 01                	mov    (%ecx),%al
  800892:	84 c0                	test   %al,%al
  800894:	74 04                	je     80089a <strcmp+0x1f>
  800896:	3a 02                	cmp    (%edx),%al
  800898:	74 f4                	je     80088e <strcmp+0x13>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80089a:	0f b6 c0             	movzbl %al,%eax
  80089d:	0f b6 12             	movzbl (%edx),%edx
  8008a0:	29 d0                	sub    %edx,%eax
}
  8008a2:	c9                   	leave  
  8008a3:	c3                   	ret    

008008a4 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008a4:	55                   	push   %ebp
  8008a5:	89 e5                	mov    %esp,%ebp
  8008a7:	53                   	push   %ebx
  8008a8:	8b 55 08             	mov    0x8(%ebp),%edx
  8008ab:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008ae:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  8008b1:	85 c0                	test   %eax,%eax
  8008b3:	74 1b                	je     8008d0 <strncmp+0x2c>
  8008b5:	8a 1a                	mov    (%edx),%bl
  8008b7:	84 db                	test   %bl,%bl
  8008b9:	74 24                	je     8008df <strncmp+0x3b>
  8008bb:	3a 19                	cmp    (%ecx),%bl
  8008bd:	75 20                	jne    8008df <strncmp+0x3b>
  8008bf:	48                   	dec    %eax
  8008c0:	74 15                	je     8008d7 <strncmp+0x33>
		n--, p++, q++;
  8008c2:	42                   	inc    %edx
  8008c3:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8008c4:	8a 1a                	mov    (%edx),%bl
  8008c6:	84 db                	test   %bl,%bl
  8008c8:	74 15                	je     8008df <strncmp+0x3b>
  8008ca:	3a 19                	cmp    (%ecx),%bl
  8008cc:	74 f1                	je     8008bf <strncmp+0x1b>
  8008ce:	eb 0f                	jmp    8008df <strncmp+0x3b>
		n--, p++, q++;
	if (n == 0)
		return 0;
  8008d0:	b8 00 00 00 00       	mov    $0x0,%eax
  8008d5:	eb 05                	jmp    8008dc <strncmp+0x38>
  8008d7:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8008dc:	5b                   	pop    %ebx
  8008dd:	c9                   	leave  
  8008de:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008df:	0f b6 02             	movzbl (%edx),%eax
  8008e2:	0f b6 11             	movzbl (%ecx),%edx
  8008e5:	29 d0                	sub    %edx,%eax
  8008e7:	eb f3                	jmp    8008dc <strncmp+0x38>

008008e9 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008e9:	55                   	push   %ebp
  8008ea:	89 e5                	mov    %esp,%ebp
  8008ec:	8b 45 08             	mov    0x8(%ebp),%eax
  8008ef:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8008f2:	8a 10                	mov    (%eax),%dl
  8008f4:	84 d2                	test   %dl,%dl
  8008f6:	74 18                	je     800910 <strchr+0x27>
		if (*s == c)
  8008f8:	38 ca                	cmp    %cl,%dl
  8008fa:	75 06                	jne    800902 <strchr+0x19>
  8008fc:	eb 17                	jmp    800915 <strchr+0x2c>
  8008fe:	38 ca                	cmp    %cl,%dl
  800900:	74 13                	je     800915 <strchr+0x2c>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800902:	40                   	inc    %eax
  800903:	8a 10                	mov    (%eax),%dl
  800905:	84 d2                	test   %dl,%dl
  800907:	75 f5                	jne    8008fe <strchr+0x15>
		if (*s == c)
			return (char *) s;
	return 0;
  800909:	b8 00 00 00 00       	mov    $0x0,%eax
  80090e:	eb 05                	jmp    800915 <strchr+0x2c>
  800910:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800915:	c9                   	leave  
  800916:	c3                   	ret    

00800917 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800917:	55                   	push   %ebp
  800918:	89 e5                	mov    %esp,%ebp
  80091a:	8b 45 08             	mov    0x8(%ebp),%eax
  80091d:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800920:	8a 10                	mov    (%eax),%dl
  800922:	84 d2                	test   %dl,%dl
  800924:	74 11                	je     800937 <strfind+0x20>
		if (*s == c)
  800926:	38 ca                	cmp    %cl,%dl
  800928:	75 06                	jne    800930 <strfind+0x19>
  80092a:	eb 0b                	jmp    800937 <strfind+0x20>
  80092c:	38 ca                	cmp    %cl,%dl
  80092e:	74 07                	je     800937 <strfind+0x20>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800930:	40                   	inc    %eax
  800931:	8a 10                	mov    (%eax),%dl
  800933:	84 d2                	test   %dl,%dl
  800935:	75 f5                	jne    80092c <strfind+0x15>
		if (*s == c)
			break;
	return (char *) s;
}
  800937:	c9                   	leave  
  800938:	c3                   	ret    

00800939 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800939:	55                   	push   %ebp
  80093a:	89 e5                	mov    %esp,%ebp
  80093c:	57                   	push   %edi
  80093d:	56                   	push   %esi
  80093e:	53                   	push   %ebx
  80093f:	8b 7d 08             	mov    0x8(%ebp),%edi
  800942:	8b 45 0c             	mov    0xc(%ebp),%eax
  800945:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800948:	85 c9                	test   %ecx,%ecx
  80094a:	74 30                	je     80097c <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80094c:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800952:	75 25                	jne    800979 <memset+0x40>
  800954:	f6 c1 03             	test   $0x3,%cl
  800957:	75 20                	jne    800979 <memset+0x40>
		c &= 0xFF;
  800959:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80095c:	89 d3                	mov    %edx,%ebx
  80095e:	c1 e3 08             	shl    $0x8,%ebx
  800961:	89 d6                	mov    %edx,%esi
  800963:	c1 e6 18             	shl    $0x18,%esi
  800966:	89 d0                	mov    %edx,%eax
  800968:	c1 e0 10             	shl    $0x10,%eax
  80096b:	09 f0                	or     %esi,%eax
  80096d:	09 d0                	or     %edx,%eax
  80096f:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800971:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800974:	fc                   	cld    
  800975:	f3 ab                	rep stos %eax,%es:(%edi)
  800977:	eb 03                	jmp    80097c <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800979:	fc                   	cld    
  80097a:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80097c:	89 f8                	mov    %edi,%eax
  80097e:	5b                   	pop    %ebx
  80097f:	5e                   	pop    %esi
  800980:	5f                   	pop    %edi
  800981:	c9                   	leave  
  800982:	c3                   	ret    

00800983 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800983:	55                   	push   %ebp
  800984:	89 e5                	mov    %esp,%ebp
  800986:	57                   	push   %edi
  800987:	56                   	push   %esi
  800988:	8b 45 08             	mov    0x8(%ebp),%eax
  80098b:	8b 75 0c             	mov    0xc(%ebp),%esi
  80098e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800991:	39 c6                	cmp    %eax,%esi
  800993:	73 34                	jae    8009c9 <memmove+0x46>
  800995:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800998:	39 d0                	cmp    %edx,%eax
  80099a:	73 2d                	jae    8009c9 <memmove+0x46>
		s += n;
		d += n;
  80099c:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80099f:	f6 c2 03             	test   $0x3,%dl
  8009a2:	75 1b                	jne    8009bf <memmove+0x3c>
  8009a4:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8009aa:	75 13                	jne    8009bf <memmove+0x3c>
  8009ac:	f6 c1 03             	test   $0x3,%cl
  8009af:	75 0e                	jne    8009bf <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8009b1:	83 ef 04             	sub    $0x4,%edi
  8009b4:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009b7:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  8009ba:	fd                   	std    
  8009bb:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009bd:	eb 07                	jmp    8009c6 <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8009bf:	4f                   	dec    %edi
  8009c0:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8009c3:	fd                   	std    
  8009c4:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009c6:	fc                   	cld    
  8009c7:	eb 20                	jmp    8009e9 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009c9:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009cf:	75 13                	jne    8009e4 <memmove+0x61>
  8009d1:	a8 03                	test   $0x3,%al
  8009d3:	75 0f                	jne    8009e4 <memmove+0x61>
  8009d5:	f6 c1 03             	test   $0x3,%cl
  8009d8:	75 0a                	jne    8009e4 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8009da:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  8009dd:	89 c7                	mov    %eax,%edi
  8009df:	fc                   	cld    
  8009e0:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009e2:	eb 05                	jmp    8009e9 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8009e4:	89 c7                	mov    %eax,%edi
  8009e6:	fc                   	cld    
  8009e7:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009e9:	5e                   	pop    %esi
  8009ea:	5f                   	pop    %edi
  8009eb:	c9                   	leave  
  8009ec:	c3                   	ret    

008009ed <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009ed:	55                   	push   %ebp
  8009ee:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8009f0:	ff 75 10             	pushl  0x10(%ebp)
  8009f3:	ff 75 0c             	pushl  0xc(%ebp)
  8009f6:	ff 75 08             	pushl  0x8(%ebp)
  8009f9:	e8 85 ff ff ff       	call   800983 <memmove>
}
  8009fe:	c9                   	leave  
  8009ff:	c3                   	ret    

00800a00 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a00:	55                   	push   %ebp
  800a01:	89 e5                	mov    %esp,%ebp
  800a03:	57                   	push   %edi
  800a04:	56                   	push   %esi
  800a05:	53                   	push   %ebx
  800a06:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800a09:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a0c:	8b 7d 10             	mov    0x10(%ebp),%edi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a0f:	85 ff                	test   %edi,%edi
  800a11:	74 32                	je     800a45 <memcmp+0x45>
		if (*s1 != *s2)
  800a13:	8a 03                	mov    (%ebx),%al
  800a15:	8a 0e                	mov    (%esi),%cl
  800a17:	38 c8                	cmp    %cl,%al
  800a19:	74 19                	je     800a34 <memcmp+0x34>
  800a1b:	eb 0d                	jmp    800a2a <memcmp+0x2a>
  800a1d:	8a 44 13 01          	mov    0x1(%ebx,%edx,1),%al
  800a21:	8a 4c 16 01          	mov    0x1(%esi,%edx,1),%cl
  800a25:	42                   	inc    %edx
  800a26:	38 c8                	cmp    %cl,%al
  800a28:	74 10                	je     800a3a <memcmp+0x3a>
			return (int) *s1 - (int) *s2;
  800a2a:	0f b6 c0             	movzbl %al,%eax
  800a2d:	0f b6 c9             	movzbl %cl,%ecx
  800a30:	29 c8                	sub    %ecx,%eax
  800a32:	eb 16                	jmp    800a4a <memcmp+0x4a>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a34:	4f                   	dec    %edi
  800a35:	ba 00 00 00 00       	mov    $0x0,%edx
  800a3a:	39 fa                	cmp    %edi,%edx
  800a3c:	75 df                	jne    800a1d <memcmp+0x1d>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a3e:	b8 00 00 00 00       	mov    $0x0,%eax
  800a43:	eb 05                	jmp    800a4a <memcmp+0x4a>
  800a45:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a4a:	5b                   	pop    %ebx
  800a4b:	5e                   	pop    %esi
  800a4c:	5f                   	pop    %edi
  800a4d:	c9                   	leave  
  800a4e:	c3                   	ret    

00800a4f <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a4f:	55                   	push   %ebp
  800a50:	89 e5                	mov    %esp,%ebp
  800a52:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800a55:	89 c2                	mov    %eax,%edx
  800a57:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a5a:	39 d0                	cmp    %edx,%eax
  800a5c:	73 12                	jae    800a70 <memfind+0x21>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a5e:	8a 4d 0c             	mov    0xc(%ebp),%cl
  800a61:	38 08                	cmp    %cl,(%eax)
  800a63:	75 06                	jne    800a6b <memfind+0x1c>
  800a65:	eb 09                	jmp    800a70 <memfind+0x21>
  800a67:	38 08                	cmp    %cl,(%eax)
  800a69:	74 05                	je     800a70 <memfind+0x21>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a6b:	40                   	inc    %eax
  800a6c:	39 c2                	cmp    %eax,%edx
  800a6e:	77 f7                	ja     800a67 <memfind+0x18>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a70:	c9                   	leave  
  800a71:	c3                   	ret    

00800a72 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a72:	55                   	push   %ebp
  800a73:	89 e5                	mov    %esp,%ebp
  800a75:	57                   	push   %edi
  800a76:	56                   	push   %esi
  800a77:	53                   	push   %ebx
  800a78:	8b 55 08             	mov    0x8(%ebp),%edx
  800a7b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a7e:	eb 01                	jmp    800a81 <strtol+0xf>
		s++;
  800a80:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a81:	8a 02                	mov    (%edx),%al
  800a83:	3c 20                	cmp    $0x20,%al
  800a85:	74 f9                	je     800a80 <strtol+0xe>
  800a87:	3c 09                	cmp    $0x9,%al
  800a89:	74 f5                	je     800a80 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a8b:	3c 2b                	cmp    $0x2b,%al
  800a8d:	75 08                	jne    800a97 <strtol+0x25>
		s++;
  800a8f:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a90:	bf 00 00 00 00       	mov    $0x0,%edi
  800a95:	eb 13                	jmp    800aaa <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a97:	3c 2d                	cmp    $0x2d,%al
  800a99:	75 0a                	jne    800aa5 <strtol+0x33>
		s++, neg = 1;
  800a9b:	8d 52 01             	lea    0x1(%edx),%edx
  800a9e:	bf 01 00 00 00       	mov    $0x1,%edi
  800aa3:	eb 05                	jmp    800aaa <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800aa5:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800aaa:	85 db                	test   %ebx,%ebx
  800aac:	74 05                	je     800ab3 <strtol+0x41>
  800aae:	83 fb 10             	cmp    $0x10,%ebx
  800ab1:	75 28                	jne    800adb <strtol+0x69>
  800ab3:	8a 02                	mov    (%edx),%al
  800ab5:	3c 30                	cmp    $0x30,%al
  800ab7:	75 10                	jne    800ac9 <strtol+0x57>
  800ab9:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800abd:	75 0a                	jne    800ac9 <strtol+0x57>
		s += 2, base = 16;
  800abf:	83 c2 02             	add    $0x2,%edx
  800ac2:	bb 10 00 00 00       	mov    $0x10,%ebx
  800ac7:	eb 12                	jmp    800adb <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800ac9:	85 db                	test   %ebx,%ebx
  800acb:	75 0e                	jne    800adb <strtol+0x69>
  800acd:	3c 30                	cmp    $0x30,%al
  800acf:	75 05                	jne    800ad6 <strtol+0x64>
		s++, base = 8;
  800ad1:	42                   	inc    %edx
  800ad2:	b3 08                	mov    $0x8,%bl
  800ad4:	eb 05                	jmp    800adb <strtol+0x69>
	else if (base == 0)
		base = 10;
  800ad6:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800adb:	b8 00 00 00 00       	mov    $0x0,%eax
  800ae0:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800ae2:	8a 0a                	mov    (%edx),%cl
  800ae4:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800ae7:	80 fb 09             	cmp    $0x9,%bl
  800aea:	77 08                	ja     800af4 <strtol+0x82>
			dig = *s - '0';
  800aec:	0f be c9             	movsbl %cl,%ecx
  800aef:	83 e9 30             	sub    $0x30,%ecx
  800af2:	eb 1e                	jmp    800b12 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800af4:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800af7:	80 fb 19             	cmp    $0x19,%bl
  800afa:	77 08                	ja     800b04 <strtol+0x92>
			dig = *s - 'a' + 10;
  800afc:	0f be c9             	movsbl %cl,%ecx
  800aff:	83 e9 57             	sub    $0x57,%ecx
  800b02:	eb 0e                	jmp    800b12 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800b04:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800b07:	80 fb 19             	cmp    $0x19,%bl
  800b0a:	77 13                	ja     800b1f <strtol+0xad>
			dig = *s - 'A' + 10;
  800b0c:	0f be c9             	movsbl %cl,%ecx
  800b0f:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800b12:	39 f1                	cmp    %esi,%ecx
  800b14:	7d 0d                	jge    800b23 <strtol+0xb1>
			break;
		s++, val = (val * base) + dig;
  800b16:	42                   	inc    %edx
  800b17:	0f af c6             	imul   %esi,%eax
  800b1a:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  800b1d:	eb c3                	jmp    800ae2 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800b1f:	89 c1                	mov    %eax,%ecx
  800b21:	eb 02                	jmp    800b25 <strtol+0xb3>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800b23:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800b25:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b29:	74 05                	je     800b30 <strtol+0xbe>
		*endptr = (char *) s;
  800b2b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800b2e:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800b30:	85 ff                	test   %edi,%edi
  800b32:	74 04                	je     800b38 <strtol+0xc6>
  800b34:	89 c8                	mov    %ecx,%eax
  800b36:	f7 d8                	neg    %eax
}
  800b38:	5b                   	pop    %ebx
  800b39:	5e                   	pop    %esi
  800b3a:	5f                   	pop    %edi
  800b3b:	c9                   	leave  
  800b3c:	c3                   	ret    
  800b3d:	00 00                	add    %al,(%eax)
	...

00800b40 <syscall>:
	return ret;
}

static int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800b40:	55                   	push   %ebp
  800b41:	89 e5                	mov    %esp,%ebp
  800b43:	57                   	push   %edi
  800b44:	56                   	push   %esi
  800b45:	53                   	push   %ebx
  800b46:	83 ec 1c             	sub    $0x1c,%esp
  800b49:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800b4c:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800b4f:	89 ca                	mov    %ecx,%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b51:	8b 75 14             	mov    0x14(%ebp),%esi
  800b54:	8b 7d 10             	mov    0x10(%ebp),%edi
  800b57:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800b5a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b5d:	cd 30                	int    $0x30
  800b5f:	89 c2                	mov    %eax,%edx
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b61:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800b65:	74 1c                	je     800b83 <syscall+0x43>
  800b67:	85 c0                	test   %eax,%eax
  800b69:	7e 18                	jle    800b83 <syscall+0x43>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b6b:	83 ec 0c             	sub    $0xc,%esp
  800b6e:	50                   	push   %eax
  800b6f:	ff 75 e4             	pushl  -0x1c(%ebp)
  800b72:	68 7f 22 80 00       	push   $0x80227f
  800b77:	6a 42                	push   $0x42
  800b79:	68 9c 22 80 00       	push   $0x80229c
  800b7e:	e8 b1 f5 ff ff       	call   800134 <_panic>

	return ret;
}
  800b83:	89 d0                	mov    %edx,%eax
  800b85:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b88:	5b                   	pop    %ebx
  800b89:	5e                   	pop    %esi
  800b8a:	5f                   	pop    %edi
  800b8b:	c9                   	leave  
  800b8c:	c3                   	ret    

00800b8d <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{	
  800b8d:	55                   	push   %ebp
  800b8e:	89 e5                	mov    %esp,%ebp
  800b90:	83 ec 08             	sub    $0x8,%esp
	// my_sysenter(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
	// return;
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  800b93:	6a 00                	push   $0x0
  800b95:	6a 00                	push   $0x0
  800b97:	6a 00                	push   $0x0
  800b99:	ff 75 0c             	pushl  0xc(%ebp)
  800b9c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b9f:	ba 00 00 00 00       	mov    $0x0,%edx
  800ba4:	b8 00 00 00 00       	mov    $0x0,%eax
  800ba9:	e8 92 ff ff ff       	call   800b40 <syscall>
  800bae:	83 c4 10             	add    $0x10,%esp
	return;
}
  800bb1:	c9                   	leave  
  800bb2:	c3                   	ret    

00800bb3 <sys_cgetc>:

int
sys_cgetc(void)
{
  800bb3:	55                   	push   %ebp
  800bb4:	89 e5                	mov    %esp,%ebp
  800bb6:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_cgetc, 0, 0, 0, 0, 0, 0);
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  800bb9:	6a 00                	push   $0x0
  800bbb:	6a 00                	push   $0x0
  800bbd:	6a 00                	push   $0x0
  800bbf:	6a 00                	push   $0x0
  800bc1:	b9 00 00 00 00       	mov    $0x0,%ecx
  800bc6:	ba 00 00 00 00       	mov    $0x0,%edx
  800bcb:	b8 01 00 00 00       	mov    $0x1,%eax
  800bd0:	e8 6b ff ff ff       	call   800b40 <syscall>
}
  800bd5:	c9                   	leave  
  800bd6:	c3                   	ret    

00800bd7 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800bd7:	55                   	push   %ebp
  800bd8:	89 e5                	mov    %esp,%ebp
  800bda:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  800bdd:	6a 00                	push   $0x0
  800bdf:	6a 00                	push   $0x0
  800be1:	6a 00                	push   $0x0
  800be3:	6a 00                	push   $0x0
  800be5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800be8:	ba 01 00 00 00       	mov    $0x1,%edx
  800bed:	b8 03 00 00 00       	mov    $0x3,%eax
  800bf2:	e8 49 ff ff ff       	call   800b40 <syscall>
}
  800bf7:	c9                   	leave  
  800bf8:	c3                   	ret    

00800bf9 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800bf9:	55                   	push   %ebp
  800bfa:	89 e5                	mov    %esp,%ebp
  800bfc:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_getenvid, 0, 0, 0, 0, 0, 0);
	return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  800bff:	6a 00                	push   $0x0
  800c01:	6a 00                	push   $0x0
  800c03:	6a 00                	push   $0x0
  800c05:	6a 00                	push   $0x0
  800c07:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c0c:	ba 00 00 00 00       	mov    $0x0,%edx
  800c11:	b8 02 00 00 00       	mov    $0x2,%eax
  800c16:	e8 25 ff ff ff       	call   800b40 <syscall>
}
  800c1b:	c9                   	leave  
  800c1c:	c3                   	ret    

00800c1d <sys_yield>:

void
sys_yield(void)
{
  800c1d:	55                   	push   %ebp
  800c1e:	89 e5                	mov    %esp,%ebp
  800c20:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  800c23:	6a 00                	push   $0x0
  800c25:	6a 00                	push   $0x0
  800c27:	6a 00                	push   $0x0
  800c29:	6a 00                	push   $0x0
  800c2b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c30:	ba 00 00 00 00       	mov    $0x0,%edx
  800c35:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c3a:	e8 01 ff ff ff       	call   800b40 <syscall>
  800c3f:	83 c4 10             	add    $0x10,%esp
}
  800c42:	c9                   	leave  
  800c43:	c3                   	ret    

00800c44 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c44:	55                   	push   %ebp
  800c45:	89 e5                	mov    %esp,%ebp
  800c47:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  800c4a:	6a 00                	push   $0x0
  800c4c:	6a 00                	push   $0x0
  800c4e:	ff 75 10             	pushl  0x10(%ebp)
  800c51:	ff 75 0c             	pushl  0xc(%ebp)
  800c54:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c57:	ba 01 00 00 00       	mov    $0x1,%edx
  800c5c:	b8 04 00 00 00       	mov    $0x4,%eax
  800c61:	e8 da fe ff ff       	call   800b40 <syscall>
}
  800c66:	c9                   	leave  
  800c67:	c3                   	ret    

00800c68 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c68:	55                   	push   %ebp
  800c69:	89 e5                	mov    %esp,%ebp
  800c6b:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
  800c6e:	ff 75 18             	pushl  0x18(%ebp)
  800c71:	ff 75 14             	pushl  0x14(%ebp)
  800c74:	ff 75 10             	pushl  0x10(%ebp)
  800c77:	ff 75 0c             	pushl  0xc(%ebp)
  800c7a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c7d:	ba 01 00 00 00       	mov    $0x1,%edx
  800c82:	b8 05 00 00 00       	mov    $0x5,%eax
  800c87:	e8 b4 fe ff ff       	call   800b40 <syscall>
}
  800c8c:	c9                   	leave  
  800c8d:	c3                   	ret    

00800c8e <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c8e:	55                   	push   %ebp
  800c8f:	89 e5                	mov    %esp,%ebp
  800c91:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  800c94:	6a 00                	push   $0x0
  800c96:	6a 00                	push   $0x0
  800c98:	6a 00                	push   $0x0
  800c9a:	ff 75 0c             	pushl  0xc(%ebp)
  800c9d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ca0:	ba 01 00 00 00       	mov    $0x1,%edx
  800ca5:	b8 06 00 00 00       	mov    $0x6,%eax
  800caa:	e8 91 fe ff ff       	call   800b40 <syscall>
}
  800caf:	c9                   	leave  
  800cb0:	c3                   	ret    

00800cb1 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800cb1:	55                   	push   %ebp
  800cb2:	89 e5                	mov    %esp,%ebp
  800cb4:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  800cb7:	6a 00                	push   $0x0
  800cb9:	6a 00                	push   $0x0
  800cbb:	6a 00                	push   $0x0
  800cbd:	ff 75 0c             	pushl  0xc(%ebp)
  800cc0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800cc3:	ba 01 00 00 00       	mov    $0x1,%edx
  800cc8:	b8 08 00 00 00       	mov    $0x8,%eax
  800ccd:	e8 6e fe ff ff       	call   800b40 <syscall>
}
  800cd2:	c9                   	leave  
  800cd3:	c3                   	ret    

00800cd4 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800cd4:	55                   	push   %ebp
  800cd5:	89 e5                	mov    %esp,%ebp
  800cd7:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
  800cda:	6a 00                	push   $0x0
  800cdc:	6a 00                	push   $0x0
  800cde:	6a 00                	push   $0x0
  800ce0:	ff 75 0c             	pushl  0xc(%ebp)
  800ce3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ce6:	ba 01 00 00 00       	mov    $0x1,%edx
  800ceb:	b8 09 00 00 00       	mov    $0x9,%eax
  800cf0:	e8 4b fe ff ff       	call   800b40 <syscall>
}
  800cf5:	c9                   	leave  
  800cf6:	c3                   	ret    

00800cf7 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800cf7:	55                   	push   %ebp
  800cf8:	89 e5                	mov    %esp,%ebp
  800cfa:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  800cfd:	6a 00                	push   $0x0
  800cff:	6a 00                	push   $0x0
  800d01:	6a 00                	push   $0x0
  800d03:	ff 75 0c             	pushl  0xc(%ebp)
  800d06:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d09:	ba 01 00 00 00       	mov    $0x1,%edx
  800d0e:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d13:	e8 28 fe ff ff       	call   800b40 <syscall>
}
  800d18:	c9                   	leave  
  800d19:	c3                   	ret    

00800d1a <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d1a:	55                   	push   %ebp
  800d1b:	89 e5                	mov    %esp,%ebp
  800d1d:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  800d20:	6a 00                	push   $0x0
  800d22:	ff 75 14             	pushl  0x14(%ebp)
  800d25:	ff 75 10             	pushl  0x10(%ebp)
  800d28:	ff 75 0c             	pushl  0xc(%ebp)
  800d2b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d2e:	ba 00 00 00 00       	mov    $0x0,%edx
  800d33:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d38:	e8 03 fe ff ff       	call   800b40 <syscall>
}
  800d3d:	c9                   	leave  
  800d3e:	c3                   	ret    

00800d3f <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d3f:	55                   	push   %ebp
  800d40:	89 e5                	mov    %esp,%ebp
  800d42:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  800d45:	6a 00                	push   $0x0
  800d47:	6a 00                	push   $0x0
  800d49:	6a 00                	push   $0x0
  800d4b:	6a 00                	push   $0x0
  800d4d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d50:	ba 01 00 00 00       	mov    $0x1,%edx
  800d55:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d5a:	e8 e1 fd ff ff       	call   800b40 <syscall>
}
  800d5f:	c9                   	leave  
  800d60:	c3                   	ret    

00800d61 <sys_set_priority>:

int
sys_set_priority(envid_t envid, uint32_t new_priority)
{
  800d61:	55                   	push   %ebp
  800d62:	89 e5                	mov    %esp,%ebp
  800d64:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_set_priority, 0, envid, new_priority, 0, 0, 0);
  800d67:	6a 00                	push   $0x0
  800d69:	6a 00                	push   $0x0
  800d6b:	6a 00                	push   $0x0
  800d6d:	ff 75 0c             	pushl  0xc(%ebp)
  800d70:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d73:	ba 00 00 00 00       	mov    $0x0,%edx
  800d78:	b8 0e 00 00 00       	mov    $0xe,%eax
  800d7d:	e8 be fd ff ff       	call   800b40 <syscall>
}
  800d82:	c9                   	leave  
  800d83:	c3                   	ret    

00800d84 <sys_exec>:

int
sys_exec(uint32_t eip, uint32_t esp, void * ph, uint32_t elf_phnum)
{
  800d84:	55                   	push   %ebp
  800d85:	89 e5                	mov    %esp,%ebp
  800d87:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_exec, 0, eip, esp, (uint32_t)ph, elf_phnum, 0);
  800d8a:	6a 00                	push   $0x0
  800d8c:	ff 75 14             	pushl  0x14(%ebp)
  800d8f:	ff 75 10             	pushl  0x10(%ebp)
  800d92:	ff 75 0c             	pushl  0xc(%ebp)
  800d95:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d98:	ba 00 00 00 00       	mov    $0x0,%edx
  800d9d:	b8 0f 00 00 00       	mov    $0xf,%eax
  800da2:	e8 99 fd ff ff       	call   800b40 <syscall>
} 
  800da7:	c9                   	leave  
  800da8:	c3                   	ret    

00800da9 <sys_join>:

// thread:
int
sys_join(envid_t envid)
{
  800da9:	55                   	push   %ebp
  800daa:	89 e5                	mov    %esp,%ebp
  800dac:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_join, 0, envid, 0, 0, 0, 0);
  800daf:	6a 00                	push   $0x0
  800db1:	6a 00                	push   $0x0
  800db3:	6a 00                	push   $0x0
  800db5:	6a 00                	push   $0x0
  800db7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800dba:	ba 00 00 00 00       	mov    $0x0,%edx
  800dbf:	b8 11 00 00 00       	mov    $0x11,%eax
  800dc4:	e8 77 fd ff ff       	call   800b40 <syscall>
}
  800dc9:	c9                   	leave  
  800dca:	c3                   	ret    

00800dcb <sys_getpid>:

envid_t
sys_getpid(void)
{
  800dcb:	55                   	push   %ebp
  800dcc:	89 e5                	mov    %esp,%ebp
  800dce:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_getpid, 0, 0, 0, 0, 0, 0);
  800dd1:	6a 00                	push   $0x0
  800dd3:	6a 00                	push   $0x0
  800dd5:	6a 00                	push   $0x0
  800dd7:	6a 00                	push   $0x0
  800dd9:	b9 00 00 00 00       	mov    $0x0,%ecx
  800dde:	ba 00 00 00 00       	mov    $0x0,%edx
  800de3:	b8 10 00 00 00       	mov    $0x10,%eax
  800de8:	e8 53 fd ff ff       	call   800b40 <syscall>
  800ded:	c9                   	leave  
  800dee:	c3                   	ret    
	...

00800df0 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  800df0:	55                   	push   %ebp
  800df1:	89 e5                	mov    %esp,%ebp
  800df3:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  800df6:	83 3d 08 40 80 00 00 	cmpl   $0x0,0x804008
  800dfd:	75 52                	jne    800e51 <set_pgfault_handler+0x61>
		// First time through!	
		// LAB 4: Your code here.

		//int sys_page_alloc(envid_t envid, void *va, int perm)
		r = sys_page_alloc(0, (void*)(UXSTACKTOP - PGSIZE), PTE_U | PTE_W | PTE_P);
  800dff:	83 ec 04             	sub    $0x4,%esp
  800e02:	6a 07                	push   $0x7
  800e04:	68 00 f0 bf ee       	push   $0xeebff000
  800e09:	6a 00                	push   $0x0
  800e0b:	e8 34 fe ff ff       	call   800c44 <sys_page_alloc>
		if (r < 0) {
  800e10:	83 c4 10             	add    $0x10,%esp
  800e13:	85 c0                	test   %eax,%eax
  800e15:	79 12                	jns    800e29 <set_pgfault_handler+0x39>
			panic("sys_page_alloc error : %e\n", r);
  800e17:	50                   	push   %eax
  800e18:	68 aa 22 80 00       	push   $0x8022aa
  800e1d:	6a 24                	push   $0x24
  800e1f:	68 c5 22 80 00       	push   $0x8022c5
  800e24:	e8 0b f3 ff ff       	call   800134 <_panic>
		}

		// how to know envid, put 0, envid2env will help us to get curenv in syscall
		r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);		
  800e29:	83 ec 08             	sub    $0x8,%esp
  800e2c:	68 5c 0e 80 00       	push   $0x800e5c
  800e31:	6a 00                	push   $0x0
  800e33:	e8 bf fe ff ff       	call   800cf7 <sys_env_set_pgfault_upcall>
		if (r < 0) {
  800e38:	83 c4 10             	add    $0x10,%esp
  800e3b:	85 c0                	test   %eax,%eax
  800e3d:	79 12                	jns    800e51 <set_pgfault_handler+0x61>
			panic("sys_env_set_pgfault_upcall error : %e\n", r);
  800e3f:	50                   	push   %eax
  800e40:	68 d4 22 80 00       	push   $0x8022d4
  800e45:	6a 2a                	push   $0x2a
  800e47:	68 c5 22 80 00       	push   $0x8022c5
  800e4c:	e8 e3 f2 ff ff       	call   800134 <_panic>
		}
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  800e51:	8b 45 08             	mov    0x8(%ebp),%eax
  800e54:	a3 08 40 80 00       	mov    %eax,0x804008
}
  800e59:	c9                   	leave  
  800e5a:	c3                   	ret    
	...

00800e5c <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  800e5c:	54                   	push   %esp
	movl _pgfault_handler, %eax
  800e5d:	a1 08 40 80 00       	mov    0x804008,%eax
	call *%eax
  800e62:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  800e64:	83 c4 04             	add    $0x4,%esp
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	
	// fix old esp
	movl 0x30(%esp), %eax
  800e67:	8b 44 24 30          	mov    0x30(%esp),%eax
	subl $0x4, %eax
  800e6b:	83 e8 04             	sub    $0x4,%eax
	movl %eax, 0x30(%esp)
  800e6e:	89 44 24 30          	mov    %eax,0x30(%esp)

	// set trap-time %eip
	movl 0x28(%esp), %ebx
  800e72:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	movl %ebx, (%eax)
  800e76:	89 18                	mov    %ebx,(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $0x08, %esp 	// ignore err_code and fault_va
  800e78:	83 c4 08             	add    $0x8,%esp
	popal 				// restore registers
  800e7b:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x04, %esp 	// ignore eip 
  800e7c:	83 c4 04             	add    $0x4,%esp
	popfl				// modify eflags
  800e7f:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  800e80:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  800e81:	c3                   	ret    
	...

00800e84 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800e84:	55                   	push   %ebp
  800e85:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800e87:	8b 45 08             	mov    0x8(%ebp),%eax
  800e8a:	05 00 00 00 30       	add    $0x30000000,%eax
  800e8f:	c1 e8 0c             	shr    $0xc,%eax
}
  800e92:	c9                   	leave  
  800e93:	c3                   	ret    

00800e94 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800e94:	55                   	push   %ebp
  800e95:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800e97:	ff 75 08             	pushl  0x8(%ebp)
  800e9a:	e8 e5 ff ff ff       	call   800e84 <fd2num>
  800e9f:	83 c4 04             	add    $0x4,%esp
  800ea2:	05 20 00 0d 00       	add    $0xd0020,%eax
  800ea7:	c1 e0 0c             	shl    $0xc,%eax
}
  800eaa:	c9                   	leave  
  800eab:	c3                   	ret    

00800eac <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800eac:	55                   	push   %ebp
  800ead:	89 e5                	mov    %esp,%ebp
  800eaf:	53                   	push   %ebx
  800eb0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800eb3:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  800eb8:	a8 01                	test   $0x1,%al
  800eba:	74 34                	je     800ef0 <fd_alloc+0x44>
  800ebc:	a1 00 00 74 ef       	mov    0xef740000,%eax
  800ec1:	a8 01                	test   $0x1,%al
  800ec3:	74 32                	je     800ef7 <fd_alloc+0x4b>
  800ec5:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
  800eca:	89 c1                	mov    %eax,%ecx
  800ecc:	89 c2                	mov    %eax,%edx
  800ece:	c1 ea 16             	shr    $0x16,%edx
  800ed1:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800ed8:	f6 c2 01             	test   $0x1,%dl
  800edb:	74 1f                	je     800efc <fd_alloc+0x50>
  800edd:	89 c2                	mov    %eax,%edx
  800edf:	c1 ea 0c             	shr    $0xc,%edx
  800ee2:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800ee9:	f6 c2 01             	test   $0x1,%dl
  800eec:	75 17                	jne    800f05 <fd_alloc+0x59>
  800eee:	eb 0c                	jmp    800efc <fd_alloc+0x50>
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  800ef0:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
  800ef5:	eb 05                	jmp    800efc <fd_alloc+0x50>
  800ef7:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
  800efc:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  800efe:	b8 00 00 00 00       	mov    $0x0,%eax
  800f03:	eb 17                	jmp    800f1c <fd_alloc+0x70>
  800f05:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800f0a:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800f0f:	75 b9                	jne    800eca <fd_alloc+0x1e>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800f11:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  800f17:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800f1c:	5b                   	pop    %ebx
  800f1d:	c9                   	leave  
  800f1e:	c3                   	ret    

00800f1f <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800f1f:	55                   	push   %ebp
  800f20:	89 e5                	mov    %esp,%ebp
  800f22:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800f25:	83 f8 1f             	cmp    $0x1f,%eax
  800f28:	77 36                	ja     800f60 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800f2a:	05 00 00 0d 00       	add    $0xd0000,%eax
  800f2f:	c1 e0 0c             	shl    $0xc,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800f32:	89 c2                	mov    %eax,%edx
  800f34:	c1 ea 16             	shr    $0x16,%edx
  800f37:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800f3e:	f6 c2 01             	test   $0x1,%dl
  800f41:	74 24                	je     800f67 <fd_lookup+0x48>
  800f43:	89 c2                	mov    %eax,%edx
  800f45:	c1 ea 0c             	shr    $0xc,%edx
  800f48:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800f4f:	f6 c2 01             	test   $0x1,%dl
  800f52:	74 1a                	je     800f6e <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800f54:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f57:	89 02                	mov    %eax,(%edx)
	return 0;
  800f59:	b8 00 00 00 00       	mov    $0x0,%eax
  800f5e:	eb 13                	jmp    800f73 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800f60:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f65:	eb 0c                	jmp    800f73 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800f67:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f6c:	eb 05                	jmp    800f73 <fd_lookup+0x54>
  800f6e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800f73:	c9                   	leave  
  800f74:	c3                   	ret    

00800f75 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800f75:	55                   	push   %ebp
  800f76:	89 e5                	mov    %esp,%ebp
  800f78:	53                   	push   %ebx
  800f79:	83 ec 04             	sub    $0x4,%esp
  800f7c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f7f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  800f82:	39 0d 04 30 80 00    	cmp    %ecx,0x803004
  800f88:	74 0d                	je     800f97 <dev_lookup+0x22>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800f8a:	b8 00 00 00 00       	mov    $0x0,%eax
  800f8f:	eb 14                	jmp    800fa5 <dev_lookup+0x30>
		if (devtab[i]->dev_id == dev_id) {
  800f91:	39 0a                	cmp    %ecx,(%edx)
  800f93:	75 10                	jne    800fa5 <dev_lookup+0x30>
  800f95:	eb 05                	jmp    800f9c <dev_lookup+0x27>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800f97:	ba 04 30 80 00       	mov    $0x803004,%edx
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
  800f9c:	89 13                	mov    %edx,(%ebx)
			return 0;
  800f9e:	b8 00 00 00 00       	mov    $0x0,%eax
  800fa3:	eb 31                	jmp    800fd6 <dev_lookup+0x61>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800fa5:	40                   	inc    %eax
  800fa6:	8b 14 85 7c 23 80 00 	mov    0x80237c(,%eax,4),%edx
  800fad:	85 d2                	test   %edx,%edx
  800faf:	75 e0                	jne    800f91 <dev_lookup+0x1c>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800fb1:	a1 04 40 80 00       	mov    0x804004,%eax
  800fb6:	8b 40 48             	mov    0x48(%eax),%eax
  800fb9:	83 ec 04             	sub    $0x4,%esp
  800fbc:	51                   	push   %ecx
  800fbd:	50                   	push   %eax
  800fbe:	68 fc 22 80 00       	push   $0x8022fc
  800fc3:	e8 44 f2 ff ff       	call   80020c <cprintf>
	*dev = 0;
  800fc8:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  800fce:	83 c4 10             	add    $0x10,%esp
  800fd1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800fd6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800fd9:	c9                   	leave  
  800fda:	c3                   	ret    

00800fdb <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800fdb:	55                   	push   %ebp
  800fdc:	89 e5                	mov    %esp,%ebp
  800fde:	56                   	push   %esi
  800fdf:	53                   	push   %ebx
  800fe0:	83 ec 20             	sub    $0x20,%esp
  800fe3:	8b 75 08             	mov    0x8(%ebp),%esi
  800fe6:	8a 45 0c             	mov    0xc(%ebp),%al
  800fe9:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800fec:	56                   	push   %esi
  800fed:	e8 92 fe ff ff       	call   800e84 <fd2num>
  800ff2:	8d 55 f4             	lea    -0xc(%ebp),%edx
  800ff5:	89 14 24             	mov    %edx,(%esp)
  800ff8:	50                   	push   %eax
  800ff9:	e8 21 ff ff ff       	call   800f1f <fd_lookup>
  800ffe:	89 c3                	mov    %eax,%ebx
  801000:	83 c4 08             	add    $0x8,%esp
  801003:	85 c0                	test   %eax,%eax
  801005:	78 05                	js     80100c <fd_close+0x31>
	    || fd != fd2)
  801007:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80100a:	74 0d                	je     801019 <fd_close+0x3e>
		return (must_exist ? r : 0);
  80100c:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  801010:	75 48                	jne    80105a <fd_close+0x7f>
  801012:	bb 00 00 00 00       	mov    $0x0,%ebx
  801017:	eb 41                	jmp    80105a <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801019:	83 ec 08             	sub    $0x8,%esp
  80101c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80101f:	50                   	push   %eax
  801020:	ff 36                	pushl  (%esi)
  801022:	e8 4e ff ff ff       	call   800f75 <dev_lookup>
  801027:	89 c3                	mov    %eax,%ebx
  801029:	83 c4 10             	add    $0x10,%esp
  80102c:	85 c0                	test   %eax,%eax
  80102e:	78 1c                	js     80104c <fd_close+0x71>
		if (dev->dev_close)
  801030:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801033:	8b 40 10             	mov    0x10(%eax),%eax
  801036:	85 c0                	test   %eax,%eax
  801038:	74 0d                	je     801047 <fd_close+0x6c>
			r = (*dev->dev_close)(fd);
  80103a:	83 ec 0c             	sub    $0xc,%esp
  80103d:	56                   	push   %esi
  80103e:	ff d0                	call   *%eax
  801040:	89 c3                	mov    %eax,%ebx
  801042:	83 c4 10             	add    $0x10,%esp
  801045:	eb 05                	jmp    80104c <fd_close+0x71>
		else
			r = 0;
  801047:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  80104c:	83 ec 08             	sub    $0x8,%esp
  80104f:	56                   	push   %esi
  801050:	6a 00                	push   $0x0
  801052:	e8 37 fc ff ff       	call   800c8e <sys_page_unmap>
	return r;
  801057:	83 c4 10             	add    $0x10,%esp
}
  80105a:	89 d8                	mov    %ebx,%eax
  80105c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80105f:	5b                   	pop    %ebx
  801060:	5e                   	pop    %esi
  801061:	c9                   	leave  
  801062:	c3                   	ret    

00801063 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801063:	55                   	push   %ebp
  801064:	89 e5                	mov    %esp,%ebp
  801066:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801069:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80106c:	50                   	push   %eax
  80106d:	ff 75 08             	pushl  0x8(%ebp)
  801070:	e8 aa fe ff ff       	call   800f1f <fd_lookup>
  801075:	83 c4 08             	add    $0x8,%esp
  801078:	85 c0                	test   %eax,%eax
  80107a:	78 10                	js     80108c <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  80107c:	83 ec 08             	sub    $0x8,%esp
  80107f:	6a 01                	push   $0x1
  801081:	ff 75 f4             	pushl  -0xc(%ebp)
  801084:	e8 52 ff ff ff       	call   800fdb <fd_close>
  801089:	83 c4 10             	add    $0x10,%esp
}
  80108c:	c9                   	leave  
  80108d:	c3                   	ret    

0080108e <close_all>:

void
close_all(void)
{
  80108e:	55                   	push   %ebp
  80108f:	89 e5                	mov    %esp,%ebp
  801091:	53                   	push   %ebx
  801092:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801095:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80109a:	83 ec 0c             	sub    $0xc,%esp
  80109d:	53                   	push   %ebx
  80109e:	e8 c0 ff ff ff       	call   801063 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8010a3:	43                   	inc    %ebx
  8010a4:	83 c4 10             	add    $0x10,%esp
  8010a7:	83 fb 20             	cmp    $0x20,%ebx
  8010aa:	75 ee                	jne    80109a <close_all+0xc>
		close(i);
}
  8010ac:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8010af:	c9                   	leave  
  8010b0:	c3                   	ret    

008010b1 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8010b1:	55                   	push   %ebp
  8010b2:	89 e5                	mov    %esp,%ebp
  8010b4:	57                   	push   %edi
  8010b5:	56                   	push   %esi
  8010b6:	53                   	push   %ebx
  8010b7:	83 ec 2c             	sub    $0x2c,%esp
  8010ba:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8010bd:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8010c0:	50                   	push   %eax
  8010c1:	ff 75 08             	pushl  0x8(%ebp)
  8010c4:	e8 56 fe ff ff       	call   800f1f <fd_lookup>
  8010c9:	89 c3                	mov    %eax,%ebx
  8010cb:	83 c4 08             	add    $0x8,%esp
  8010ce:	85 c0                	test   %eax,%eax
  8010d0:	0f 88 c0 00 00 00    	js     801196 <dup+0xe5>
		return r;
	close(newfdnum);
  8010d6:	83 ec 0c             	sub    $0xc,%esp
  8010d9:	57                   	push   %edi
  8010da:	e8 84 ff ff ff       	call   801063 <close>

	newfd = INDEX2FD(newfdnum);
  8010df:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  8010e5:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  8010e8:	83 c4 04             	add    $0x4,%esp
  8010eb:	ff 75 e4             	pushl  -0x1c(%ebp)
  8010ee:	e8 a1 fd ff ff       	call   800e94 <fd2data>
  8010f3:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  8010f5:	89 34 24             	mov    %esi,(%esp)
  8010f8:	e8 97 fd ff ff       	call   800e94 <fd2data>
  8010fd:	83 c4 10             	add    $0x10,%esp
  801100:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801103:	89 d8                	mov    %ebx,%eax
  801105:	c1 e8 16             	shr    $0x16,%eax
  801108:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80110f:	a8 01                	test   $0x1,%al
  801111:	74 37                	je     80114a <dup+0x99>
  801113:	89 d8                	mov    %ebx,%eax
  801115:	c1 e8 0c             	shr    $0xc,%eax
  801118:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80111f:	f6 c2 01             	test   $0x1,%dl
  801122:	74 26                	je     80114a <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801124:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80112b:	83 ec 0c             	sub    $0xc,%esp
  80112e:	25 07 0e 00 00       	and    $0xe07,%eax
  801133:	50                   	push   %eax
  801134:	ff 75 d4             	pushl  -0x2c(%ebp)
  801137:	6a 00                	push   $0x0
  801139:	53                   	push   %ebx
  80113a:	6a 00                	push   $0x0
  80113c:	e8 27 fb ff ff       	call   800c68 <sys_page_map>
  801141:	89 c3                	mov    %eax,%ebx
  801143:	83 c4 20             	add    $0x20,%esp
  801146:	85 c0                	test   %eax,%eax
  801148:	78 2d                	js     801177 <dup+0xc6>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80114a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80114d:	89 c2                	mov    %eax,%edx
  80114f:	c1 ea 0c             	shr    $0xc,%edx
  801152:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801159:	83 ec 0c             	sub    $0xc,%esp
  80115c:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  801162:	52                   	push   %edx
  801163:	56                   	push   %esi
  801164:	6a 00                	push   $0x0
  801166:	50                   	push   %eax
  801167:	6a 00                	push   $0x0
  801169:	e8 fa fa ff ff       	call   800c68 <sys_page_map>
  80116e:	89 c3                	mov    %eax,%ebx
  801170:	83 c4 20             	add    $0x20,%esp
  801173:	85 c0                	test   %eax,%eax
  801175:	79 1d                	jns    801194 <dup+0xe3>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801177:	83 ec 08             	sub    $0x8,%esp
  80117a:	56                   	push   %esi
  80117b:	6a 00                	push   $0x0
  80117d:	e8 0c fb ff ff       	call   800c8e <sys_page_unmap>
	sys_page_unmap(0, nva);
  801182:	83 c4 08             	add    $0x8,%esp
  801185:	ff 75 d4             	pushl  -0x2c(%ebp)
  801188:	6a 00                	push   $0x0
  80118a:	e8 ff fa ff ff       	call   800c8e <sys_page_unmap>
	return r;
  80118f:	83 c4 10             	add    $0x10,%esp
  801192:	eb 02                	jmp    801196 <dup+0xe5>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  801194:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  801196:	89 d8                	mov    %ebx,%eax
  801198:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80119b:	5b                   	pop    %ebx
  80119c:	5e                   	pop    %esi
  80119d:	5f                   	pop    %edi
  80119e:	c9                   	leave  
  80119f:	c3                   	ret    

008011a0 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8011a0:	55                   	push   %ebp
  8011a1:	89 e5                	mov    %esp,%ebp
  8011a3:	53                   	push   %ebx
  8011a4:	83 ec 14             	sub    $0x14,%esp
  8011a7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8011aa:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011ad:	50                   	push   %eax
  8011ae:	53                   	push   %ebx
  8011af:	e8 6b fd ff ff       	call   800f1f <fd_lookup>
  8011b4:	83 c4 08             	add    $0x8,%esp
  8011b7:	85 c0                	test   %eax,%eax
  8011b9:	78 67                	js     801222 <read+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011bb:	83 ec 08             	sub    $0x8,%esp
  8011be:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011c1:	50                   	push   %eax
  8011c2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011c5:	ff 30                	pushl  (%eax)
  8011c7:	e8 a9 fd ff ff       	call   800f75 <dev_lookup>
  8011cc:	83 c4 10             	add    $0x10,%esp
  8011cf:	85 c0                	test   %eax,%eax
  8011d1:	78 4f                	js     801222 <read+0x82>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8011d3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011d6:	8b 50 08             	mov    0x8(%eax),%edx
  8011d9:	83 e2 03             	and    $0x3,%edx
  8011dc:	83 fa 01             	cmp    $0x1,%edx
  8011df:	75 21                	jne    801202 <read+0x62>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8011e1:	a1 04 40 80 00       	mov    0x804004,%eax
  8011e6:	8b 40 48             	mov    0x48(%eax),%eax
  8011e9:	83 ec 04             	sub    $0x4,%esp
  8011ec:	53                   	push   %ebx
  8011ed:	50                   	push   %eax
  8011ee:	68 40 23 80 00       	push   $0x802340
  8011f3:	e8 14 f0 ff ff       	call   80020c <cprintf>
		return -E_INVAL;
  8011f8:	83 c4 10             	add    $0x10,%esp
  8011fb:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801200:	eb 20                	jmp    801222 <read+0x82>
	}
	if (!dev->dev_read)
  801202:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801205:	8b 52 08             	mov    0x8(%edx),%edx
  801208:	85 d2                	test   %edx,%edx
  80120a:	74 11                	je     80121d <read+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80120c:	83 ec 04             	sub    $0x4,%esp
  80120f:	ff 75 10             	pushl  0x10(%ebp)
  801212:	ff 75 0c             	pushl  0xc(%ebp)
  801215:	50                   	push   %eax
  801216:	ff d2                	call   *%edx
  801218:	83 c4 10             	add    $0x10,%esp
  80121b:	eb 05                	jmp    801222 <read+0x82>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80121d:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  801222:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801225:	c9                   	leave  
  801226:	c3                   	ret    

00801227 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801227:	55                   	push   %ebp
  801228:	89 e5                	mov    %esp,%ebp
  80122a:	57                   	push   %edi
  80122b:	56                   	push   %esi
  80122c:	53                   	push   %ebx
  80122d:	83 ec 0c             	sub    $0xc,%esp
  801230:	8b 7d 08             	mov    0x8(%ebp),%edi
  801233:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801236:	85 f6                	test   %esi,%esi
  801238:	74 31                	je     80126b <readn+0x44>
  80123a:	b8 00 00 00 00       	mov    $0x0,%eax
  80123f:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = read(fdnum, (char*)buf + tot, n - tot);
  801244:	83 ec 04             	sub    $0x4,%esp
  801247:	89 f2                	mov    %esi,%edx
  801249:	29 c2                	sub    %eax,%edx
  80124b:	52                   	push   %edx
  80124c:	03 45 0c             	add    0xc(%ebp),%eax
  80124f:	50                   	push   %eax
  801250:	57                   	push   %edi
  801251:	e8 4a ff ff ff       	call   8011a0 <read>
		if (m < 0)
  801256:	83 c4 10             	add    $0x10,%esp
  801259:	85 c0                	test   %eax,%eax
  80125b:	78 17                	js     801274 <readn+0x4d>
			return m;
		if (m == 0)
  80125d:	85 c0                	test   %eax,%eax
  80125f:	74 11                	je     801272 <readn+0x4b>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801261:	01 c3                	add    %eax,%ebx
  801263:	89 d8                	mov    %ebx,%eax
  801265:	39 f3                	cmp    %esi,%ebx
  801267:	72 db                	jb     801244 <readn+0x1d>
  801269:	eb 09                	jmp    801274 <readn+0x4d>
  80126b:	b8 00 00 00 00       	mov    $0x0,%eax
  801270:	eb 02                	jmp    801274 <readn+0x4d>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  801272:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  801274:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801277:	5b                   	pop    %ebx
  801278:	5e                   	pop    %esi
  801279:	5f                   	pop    %edi
  80127a:	c9                   	leave  
  80127b:	c3                   	ret    

0080127c <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80127c:	55                   	push   %ebp
  80127d:	89 e5                	mov    %esp,%ebp
  80127f:	53                   	push   %ebx
  801280:	83 ec 14             	sub    $0x14,%esp
  801283:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801286:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801289:	50                   	push   %eax
  80128a:	53                   	push   %ebx
  80128b:	e8 8f fc ff ff       	call   800f1f <fd_lookup>
  801290:	83 c4 08             	add    $0x8,%esp
  801293:	85 c0                	test   %eax,%eax
  801295:	78 62                	js     8012f9 <write+0x7d>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801297:	83 ec 08             	sub    $0x8,%esp
  80129a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80129d:	50                   	push   %eax
  80129e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012a1:	ff 30                	pushl  (%eax)
  8012a3:	e8 cd fc ff ff       	call   800f75 <dev_lookup>
  8012a8:	83 c4 10             	add    $0x10,%esp
  8012ab:	85 c0                	test   %eax,%eax
  8012ad:	78 4a                	js     8012f9 <write+0x7d>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8012af:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012b2:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8012b6:	75 21                	jne    8012d9 <write+0x5d>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8012b8:	a1 04 40 80 00       	mov    0x804004,%eax
  8012bd:	8b 40 48             	mov    0x48(%eax),%eax
  8012c0:	83 ec 04             	sub    $0x4,%esp
  8012c3:	53                   	push   %ebx
  8012c4:	50                   	push   %eax
  8012c5:	68 5c 23 80 00       	push   $0x80235c
  8012ca:	e8 3d ef ff ff       	call   80020c <cprintf>
		return -E_INVAL;
  8012cf:	83 c4 10             	add    $0x10,%esp
  8012d2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012d7:	eb 20                	jmp    8012f9 <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8012d9:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8012dc:	8b 52 0c             	mov    0xc(%edx),%edx
  8012df:	85 d2                	test   %edx,%edx
  8012e1:	74 11                	je     8012f4 <write+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8012e3:	83 ec 04             	sub    $0x4,%esp
  8012e6:	ff 75 10             	pushl  0x10(%ebp)
  8012e9:	ff 75 0c             	pushl  0xc(%ebp)
  8012ec:	50                   	push   %eax
  8012ed:	ff d2                	call   *%edx
  8012ef:	83 c4 10             	add    $0x10,%esp
  8012f2:	eb 05                	jmp    8012f9 <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8012f4:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  8012f9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012fc:	c9                   	leave  
  8012fd:	c3                   	ret    

008012fe <seek>:

int
seek(int fdnum, off_t offset)
{
  8012fe:	55                   	push   %ebp
  8012ff:	89 e5                	mov    %esp,%ebp
  801301:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801304:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801307:	50                   	push   %eax
  801308:	ff 75 08             	pushl  0x8(%ebp)
  80130b:	e8 0f fc ff ff       	call   800f1f <fd_lookup>
  801310:	83 c4 08             	add    $0x8,%esp
  801313:	85 c0                	test   %eax,%eax
  801315:	78 0e                	js     801325 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801317:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80131a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80131d:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801320:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801325:	c9                   	leave  
  801326:	c3                   	ret    

00801327 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801327:	55                   	push   %ebp
  801328:	89 e5                	mov    %esp,%ebp
  80132a:	53                   	push   %ebx
  80132b:	83 ec 14             	sub    $0x14,%esp
  80132e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801331:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801334:	50                   	push   %eax
  801335:	53                   	push   %ebx
  801336:	e8 e4 fb ff ff       	call   800f1f <fd_lookup>
  80133b:	83 c4 08             	add    $0x8,%esp
  80133e:	85 c0                	test   %eax,%eax
  801340:	78 5f                	js     8013a1 <ftruncate+0x7a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801342:	83 ec 08             	sub    $0x8,%esp
  801345:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801348:	50                   	push   %eax
  801349:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80134c:	ff 30                	pushl  (%eax)
  80134e:	e8 22 fc ff ff       	call   800f75 <dev_lookup>
  801353:	83 c4 10             	add    $0x10,%esp
  801356:	85 c0                	test   %eax,%eax
  801358:	78 47                	js     8013a1 <ftruncate+0x7a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80135a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80135d:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801361:	75 21                	jne    801384 <ftruncate+0x5d>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801363:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801368:	8b 40 48             	mov    0x48(%eax),%eax
  80136b:	83 ec 04             	sub    $0x4,%esp
  80136e:	53                   	push   %ebx
  80136f:	50                   	push   %eax
  801370:	68 1c 23 80 00       	push   $0x80231c
  801375:	e8 92 ee ff ff       	call   80020c <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80137a:	83 c4 10             	add    $0x10,%esp
  80137d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801382:	eb 1d                	jmp    8013a1 <ftruncate+0x7a>
	}
	if (!dev->dev_trunc)
  801384:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801387:	8b 52 18             	mov    0x18(%edx),%edx
  80138a:	85 d2                	test   %edx,%edx
  80138c:	74 0e                	je     80139c <ftruncate+0x75>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80138e:	83 ec 08             	sub    $0x8,%esp
  801391:	ff 75 0c             	pushl  0xc(%ebp)
  801394:	50                   	push   %eax
  801395:	ff d2                	call   *%edx
  801397:	83 c4 10             	add    $0x10,%esp
  80139a:	eb 05                	jmp    8013a1 <ftruncate+0x7a>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80139c:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  8013a1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013a4:	c9                   	leave  
  8013a5:	c3                   	ret    

008013a6 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8013a6:	55                   	push   %ebp
  8013a7:	89 e5                	mov    %esp,%ebp
  8013a9:	53                   	push   %ebx
  8013aa:	83 ec 14             	sub    $0x14,%esp
  8013ad:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8013b0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8013b3:	50                   	push   %eax
  8013b4:	ff 75 08             	pushl  0x8(%ebp)
  8013b7:	e8 63 fb ff ff       	call   800f1f <fd_lookup>
  8013bc:	83 c4 08             	add    $0x8,%esp
  8013bf:	85 c0                	test   %eax,%eax
  8013c1:	78 52                	js     801415 <fstat+0x6f>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013c3:	83 ec 08             	sub    $0x8,%esp
  8013c6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013c9:	50                   	push   %eax
  8013ca:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013cd:	ff 30                	pushl  (%eax)
  8013cf:	e8 a1 fb ff ff       	call   800f75 <dev_lookup>
  8013d4:	83 c4 10             	add    $0x10,%esp
  8013d7:	85 c0                	test   %eax,%eax
  8013d9:	78 3a                	js     801415 <fstat+0x6f>
		return r;
	if (!dev->dev_stat)
  8013db:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013de:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8013e2:	74 2c                	je     801410 <fstat+0x6a>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8013e4:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8013e7:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8013ee:	00 00 00 
	stat->st_isdir = 0;
  8013f1:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8013f8:	00 00 00 
	stat->st_dev = dev;
  8013fb:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801401:	83 ec 08             	sub    $0x8,%esp
  801404:	53                   	push   %ebx
  801405:	ff 75 f0             	pushl  -0x10(%ebp)
  801408:	ff 50 14             	call   *0x14(%eax)
  80140b:	83 c4 10             	add    $0x10,%esp
  80140e:	eb 05                	jmp    801415 <fstat+0x6f>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801410:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801415:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801418:	c9                   	leave  
  801419:	c3                   	ret    

0080141a <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80141a:	55                   	push   %ebp
  80141b:	89 e5                	mov    %esp,%ebp
  80141d:	56                   	push   %esi
  80141e:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80141f:	83 ec 08             	sub    $0x8,%esp
  801422:	6a 00                	push   $0x0
  801424:	ff 75 08             	pushl  0x8(%ebp)
  801427:	e8 78 01 00 00       	call   8015a4 <open>
  80142c:	89 c3                	mov    %eax,%ebx
  80142e:	83 c4 10             	add    $0x10,%esp
  801431:	85 c0                	test   %eax,%eax
  801433:	78 1b                	js     801450 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801435:	83 ec 08             	sub    $0x8,%esp
  801438:	ff 75 0c             	pushl  0xc(%ebp)
  80143b:	50                   	push   %eax
  80143c:	e8 65 ff ff ff       	call   8013a6 <fstat>
  801441:	89 c6                	mov    %eax,%esi
	close(fd);
  801443:	89 1c 24             	mov    %ebx,(%esp)
  801446:	e8 18 fc ff ff       	call   801063 <close>
	return r;
  80144b:	83 c4 10             	add    $0x10,%esp
  80144e:	89 f3                	mov    %esi,%ebx
}
  801450:	89 d8                	mov    %ebx,%eax
  801452:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801455:	5b                   	pop    %ebx
  801456:	5e                   	pop    %esi
  801457:	c9                   	leave  
  801458:	c3                   	ret    
  801459:	00 00                	add    %al,(%eax)
	...

0080145c <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80145c:	55                   	push   %ebp
  80145d:	89 e5                	mov    %esp,%ebp
  80145f:	56                   	push   %esi
  801460:	53                   	push   %ebx
  801461:	89 c3                	mov    %eax,%ebx
  801463:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  801465:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  80146c:	75 12                	jne    801480 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80146e:	83 ec 0c             	sub    $0xc,%esp
  801471:	6a 01                	push   $0x1
  801473:	e8 8a 07 00 00       	call   801c02 <ipc_find_env>
  801478:	a3 00 40 80 00       	mov    %eax,0x804000
  80147d:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801480:	6a 07                	push   $0x7
  801482:	68 00 50 80 00       	push   $0x805000
  801487:	53                   	push   %ebx
  801488:	ff 35 00 40 80 00    	pushl  0x804000
  80148e:	e8 1a 07 00 00       	call   801bad <ipc_send>
	
	return ipc_recv(NULL, dstva, NULL);
  801493:	83 c4 0c             	add    $0xc,%esp
  801496:	6a 00                	push   $0x0
  801498:	56                   	push   %esi
  801499:	6a 00                	push   $0x0
  80149b:	e8 98 06 00 00       	call   801b38 <ipc_recv>
}
  8014a0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8014a3:	5b                   	pop    %ebx
  8014a4:	5e                   	pop    %esi
  8014a5:	c9                   	leave  
  8014a6:	c3                   	ret    

008014a7 <devfile_stat>:
}


static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8014a7:	55                   	push   %ebp
  8014a8:	89 e5                	mov    %esp,%ebp
  8014aa:	53                   	push   %ebx
  8014ab:	83 ec 04             	sub    $0x4,%esp
  8014ae:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8014b1:	8b 45 08             	mov    0x8(%ebp),%eax
  8014b4:	8b 40 0c             	mov    0xc(%eax),%eax
  8014b7:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0) {
  8014bc:	ba 00 00 00 00       	mov    $0x0,%edx
  8014c1:	b8 05 00 00 00       	mov    $0x5,%eax
  8014c6:	e8 91 ff ff ff       	call   80145c <fsipc>
  8014cb:	85 c0                	test   %eax,%eax
  8014cd:	78 2c                	js     8014fb <devfile_stat+0x54>
		return r;
	}
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8014cf:	83 ec 08             	sub    $0x8,%esp
  8014d2:	68 00 50 80 00       	push   $0x805000
  8014d7:	53                   	push   %ebx
  8014d8:	e8 e5 f2 ff ff       	call   8007c2 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8014dd:	a1 80 50 80 00       	mov    0x805080,%eax
  8014e2:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8014e8:	a1 84 50 80 00       	mov    0x805084,%eax
  8014ed:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8014f3:	83 c4 10             	add    $0x10,%esp
  8014f6:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8014fb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014fe:	c9                   	leave  
  8014ff:	c3                   	ret    

00801500 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801500:	55                   	push   %ebp
  801501:	89 e5                	mov    %esp,%ebp
  801503:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801506:	8b 45 08             	mov    0x8(%ebp),%eax
  801509:	8b 40 0c             	mov    0xc(%eax),%eax
  80150c:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801511:	ba 00 00 00 00       	mov    $0x0,%edx
  801516:	b8 06 00 00 00       	mov    $0x6,%eax
  80151b:	e8 3c ff ff ff       	call   80145c <fsipc>
}
  801520:	c9                   	leave  
  801521:	c3                   	ret    

00801522 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801522:	55                   	push   %ebp
  801523:	89 e5                	mov    %esp,%ebp
  801525:	56                   	push   %esi
  801526:	53                   	push   %ebx
  801527:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80152a:	8b 45 08             	mov    0x8(%ebp),%eax
  80152d:	8b 40 0c             	mov    0xc(%eax),%eax
  801530:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801535:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80153b:	ba 00 00 00 00       	mov    $0x0,%edx
  801540:	b8 03 00 00 00       	mov    $0x3,%eax
  801545:	e8 12 ff ff ff       	call   80145c <fsipc>
  80154a:	89 c3                	mov    %eax,%ebx
  80154c:	85 c0                	test   %eax,%eax
  80154e:	78 4b                	js     80159b <devfile_read+0x79>
		return r;
	assert(r <= n);
  801550:	39 c6                	cmp    %eax,%esi
  801552:	73 16                	jae    80156a <devfile_read+0x48>
  801554:	68 8c 23 80 00       	push   $0x80238c
  801559:	68 93 23 80 00       	push   $0x802393
  80155e:	6a 7d                	push   $0x7d
  801560:	68 a8 23 80 00       	push   $0x8023a8
  801565:	e8 ca eb ff ff       	call   800134 <_panic>
	assert(r <= PGSIZE);
  80156a:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80156f:	7e 16                	jle    801587 <devfile_read+0x65>
  801571:	68 b3 23 80 00       	push   $0x8023b3
  801576:	68 93 23 80 00       	push   $0x802393
  80157b:	6a 7e                	push   $0x7e
  80157d:	68 a8 23 80 00       	push   $0x8023a8
  801582:	e8 ad eb ff ff       	call   800134 <_panic>
	memmove(buf, &fsipcbuf, r);
  801587:	83 ec 04             	sub    $0x4,%esp
  80158a:	50                   	push   %eax
  80158b:	68 00 50 80 00       	push   $0x805000
  801590:	ff 75 0c             	pushl  0xc(%ebp)
  801593:	e8 eb f3 ff ff       	call   800983 <memmove>
	return r;
  801598:	83 c4 10             	add    $0x10,%esp
}
  80159b:	89 d8                	mov    %ebx,%eax
  80159d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8015a0:	5b                   	pop    %ebx
  8015a1:	5e                   	pop    %esi
  8015a2:	c9                   	leave  
  8015a3:	c3                   	ret    

008015a4 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8015a4:	55                   	push   %ebp
  8015a5:	89 e5                	mov    %esp,%ebp
  8015a7:	56                   	push   %esi
  8015a8:	53                   	push   %ebx
  8015a9:	83 ec 1c             	sub    $0x1c,%esp
  8015ac:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8015af:	56                   	push   %esi
  8015b0:	e8 bb f1 ff ff       	call   800770 <strlen>
  8015b5:	83 c4 10             	add    $0x10,%esp
  8015b8:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8015bd:	7f 65                	jg     801624 <open+0x80>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8015bf:	83 ec 0c             	sub    $0xc,%esp
  8015c2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015c5:	50                   	push   %eax
  8015c6:	e8 e1 f8 ff ff       	call   800eac <fd_alloc>
  8015cb:	89 c3                	mov    %eax,%ebx
  8015cd:	83 c4 10             	add    $0x10,%esp
  8015d0:	85 c0                	test   %eax,%eax
  8015d2:	78 55                	js     801629 <open+0x85>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8015d4:	83 ec 08             	sub    $0x8,%esp
  8015d7:	56                   	push   %esi
  8015d8:	68 00 50 80 00       	push   $0x805000
  8015dd:	e8 e0 f1 ff ff       	call   8007c2 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8015e2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8015e5:	a3 00 54 80 00       	mov    %eax,0x805400



	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8015ea:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8015ed:	b8 01 00 00 00       	mov    $0x1,%eax
  8015f2:	e8 65 fe ff ff       	call   80145c <fsipc>
  8015f7:	89 c3                	mov    %eax,%ebx
  8015f9:	83 c4 10             	add    $0x10,%esp
  8015fc:	85 c0                	test   %eax,%eax
  8015fe:	79 12                	jns    801612 <open+0x6e>
		fd_close(fd, 0);
  801600:	83 ec 08             	sub    $0x8,%esp
  801603:	6a 00                	push   $0x0
  801605:	ff 75 f4             	pushl  -0xc(%ebp)
  801608:	e8 ce f9 ff ff       	call   800fdb <fd_close>
		return r;
  80160d:	83 c4 10             	add    $0x10,%esp
  801610:	eb 17                	jmp    801629 <open+0x85>
	}

	return fd2num(fd);
  801612:	83 ec 0c             	sub    $0xc,%esp
  801615:	ff 75 f4             	pushl  -0xc(%ebp)
  801618:	e8 67 f8 ff ff       	call   800e84 <fd2num>
  80161d:	89 c3                	mov    %eax,%ebx
  80161f:	83 c4 10             	add    $0x10,%esp
  801622:	eb 05                	jmp    801629 <open+0x85>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801624:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801629:	89 d8                	mov    %ebx,%eax
  80162b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80162e:	5b                   	pop    %ebx
  80162f:	5e                   	pop    %esi
  801630:	c9                   	leave  
  801631:	c3                   	ret    
	...

00801634 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801634:	55                   	push   %ebp
  801635:	89 e5                	mov    %esp,%ebp
  801637:	56                   	push   %esi
  801638:	53                   	push   %ebx
  801639:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  80163c:	83 ec 0c             	sub    $0xc,%esp
  80163f:	ff 75 08             	pushl  0x8(%ebp)
  801642:	e8 4d f8 ff ff       	call   800e94 <fd2data>
  801647:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  801649:	83 c4 08             	add    $0x8,%esp
  80164c:	68 bf 23 80 00       	push   $0x8023bf
  801651:	56                   	push   %esi
  801652:	e8 6b f1 ff ff       	call   8007c2 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801657:	8b 43 04             	mov    0x4(%ebx),%eax
  80165a:	2b 03                	sub    (%ebx),%eax
  80165c:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  801662:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  801669:	00 00 00 
	stat->st_dev = &devpipe;
  80166c:	c7 86 88 00 00 00 20 	movl   $0x803020,0x88(%esi)
  801673:	30 80 00 
	return 0;
}
  801676:	b8 00 00 00 00       	mov    $0x0,%eax
  80167b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80167e:	5b                   	pop    %ebx
  80167f:	5e                   	pop    %esi
  801680:	c9                   	leave  
  801681:	c3                   	ret    

00801682 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801682:	55                   	push   %ebp
  801683:	89 e5                	mov    %esp,%ebp
  801685:	53                   	push   %ebx
  801686:	83 ec 0c             	sub    $0xc,%esp
  801689:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  80168c:	53                   	push   %ebx
  80168d:	6a 00                	push   $0x0
  80168f:	e8 fa f5 ff ff       	call   800c8e <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801694:	89 1c 24             	mov    %ebx,(%esp)
  801697:	e8 f8 f7 ff ff       	call   800e94 <fd2data>
  80169c:	83 c4 08             	add    $0x8,%esp
  80169f:	50                   	push   %eax
  8016a0:	6a 00                	push   $0x0
  8016a2:	e8 e7 f5 ff ff       	call   800c8e <sys_page_unmap>
}
  8016a7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016aa:	c9                   	leave  
  8016ab:	c3                   	ret    

008016ac <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8016ac:	55                   	push   %ebp
  8016ad:	89 e5                	mov    %esp,%ebp
  8016af:	57                   	push   %edi
  8016b0:	56                   	push   %esi
  8016b1:	53                   	push   %ebx
  8016b2:	83 ec 1c             	sub    $0x1c,%esp
  8016b5:	89 c7                	mov    %eax,%edi
  8016b7:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8016ba:	a1 04 40 80 00       	mov    0x804004,%eax
  8016bf:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  8016c2:	83 ec 0c             	sub    $0xc,%esp
  8016c5:	57                   	push   %edi
  8016c6:	e8 85 05 00 00       	call   801c50 <pageref>
  8016cb:	89 c6                	mov    %eax,%esi
  8016cd:	83 c4 04             	add    $0x4,%esp
  8016d0:	ff 75 e4             	pushl  -0x1c(%ebp)
  8016d3:	e8 78 05 00 00       	call   801c50 <pageref>
  8016d8:	83 c4 10             	add    $0x10,%esp
  8016db:	39 c6                	cmp    %eax,%esi
  8016dd:	0f 94 c0             	sete   %al
  8016e0:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  8016e3:	8b 15 04 40 80 00    	mov    0x804004,%edx
  8016e9:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  8016ec:	39 cb                	cmp    %ecx,%ebx
  8016ee:	75 08                	jne    8016f8 <_pipeisclosed+0x4c>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  8016f0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8016f3:	5b                   	pop    %ebx
  8016f4:	5e                   	pop    %esi
  8016f5:	5f                   	pop    %edi
  8016f6:	c9                   	leave  
  8016f7:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  8016f8:	83 f8 01             	cmp    $0x1,%eax
  8016fb:	75 bd                	jne    8016ba <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8016fd:	8b 42 58             	mov    0x58(%edx),%eax
  801700:	6a 01                	push   $0x1
  801702:	50                   	push   %eax
  801703:	53                   	push   %ebx
  801704:	68 c6 23 80 00       	push   $0x8023c6
  801709:	e8 fe ea ff ff       	call   80020c <cprintf>
  80170e:	83 c4 10             	add    $0x10,%esp
  801711:	eb a7                	jmp    8016ba <_pipeisclosed+0xe>

00801713 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801713:	55                   	push   %ebp
  801714:	89 e5                	mov    %esp,%ebp
  801716:	57                   	push   %edi
  801717:	56                   	push   %esi
  801718:	53                   	push   %ebx
  801719:	83 ec 28             	sub    $0x28,%esp
  80171c:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  80171f:	56                   	push   %esi
  801720:	e8 6f f7 ff ff       	call   800e94 <fd2data>
  801725:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801727:	83 c4 10             	add    $0x10,%esp
  80172a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80172e:	75 4a                	jne    80177a <devpipe_write+0x67>
  801730:	bf 00 00 00 00       	mov    $0x0,%edi
  801735:	eb 56                	jmp    80178d <devpipe_write+0x7a>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801737:	89 da                	mov    %ebx,%edx
  801739:	89 f0                	mov    %esi,%eax
  80173b:	e8 6c ff ff ff       	call   8016ac <_pipeisclosed>
  801740:	85 c0                	test   %eax,%eax
  801742:	75 4d                	jne    801791 <devpipe_write+0x7e>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801744:	e8 d4 f4 ff ff       	call   800c1d <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801749:	8b 43 04             	mov    0x4(%ebx),%eax
  80174c:	8b 13                	mov    (%ebx),%edx
  80174e:	83 c2 20             	add    $0x20,%edx
  801751:	39 d0                	cmp    %edx,%eax
  801753:	73 e2                	jae    801737 <devpipe_write+0x24>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801755:	89 c2                	mov    %eax,%edx
  801757:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  80175d:	79 05                	jns    801764 <devpipe_write+0x51>
  80175f:	4a                   	dec    %edx
  801760:	83 ca e0             	or     $0xffffffe0,%edx
  801763:	42                   	inc    %edx
  801764:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801767:	8a 0c 39             	mov    (%ecx,%edi,1),%cl
  80176a:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  80176e:	40                   	inc    %eax
  80176f:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801772:	47                   	inc    %edi
  801773:	39 7d 10             	cmp    %edi,0x10(%ebp)
  801776:	77 07                	ja     80177f <devpipe_write+0x6c>
  801778:	eb 13                	jmp    80178d <devpipe_write+0x7a>
  80177a:	bf 00 00 00 00       	mov    $0x0,%edi
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  80177f:	8b 43 04             	mov    0x4(%ebx),%eax
  801782:	8b 13                	mov    (%ebx),%edx
  801784:	83 c2 20             	add    $0x20,%edx
  801787:	39 d0                	cmp    %edx,%eax
  801789:	73 ac                	jae    801737 <devpipe_write+0x24>
  80178b:	eb c8                	jmp    801755 <devpipe_write+0x42>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  80178d:	89 f8                	mov    %edi,%eax
  80178f:	eb 05                	jmp    801796 <devpipe_write+0x83>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801791:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801796:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801799:	5b                   	pop    %ebx
  80179a:	5e                   	pop    %esi
  80179b:	5f                   	pop    %edi
  80179c:	c9                   	leave  
  80179d:	c3                   	ret    

0080179e <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  80179e:	55                   	push   %ebp
  80179f:	89 e5                	mov    %esp,%ebp
  8017a1:	57                   	push   %edi
  8017a2:	56                   	push   %esi
  8017a3:	53                   	push   %ebx
  8017a4:	83 ec 18             	sub    $0x18,%esp
  8017a7:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  8017aa:	57                   	push   %edi
  8017ab:	e8 e4 f6 ff ff       	call   800e94 <fd2data>
  8017b0:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8017b2:	83 c4 10             	add    $0x10,%esp
  8017b5:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8017b9:	75 44                	jne    8017ff <devpipe_read+0x61>
  8017bb:	be 00 00 00 00       	mov    $0x0,%esi
  8017c0:	eb 4f                	jmp    801811 <devpipe_read+0x73>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
				return i;
  8017c2:	89 f0                	mov    %esi,%eax
  8017c4:	eb 54                	jmp    80181a <devpipe_read+0x7c>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  8017c6:	89 da                	mov    %ebx,%edx
  8017c8:	89 f8                	mov    %edi,%eax
  8017ca:	e8 dd fe ff ff       	call   8016ac <_pipeisclosed>
  8017cf:	85 c0                	test   %eax,%eax
  8017d1:	75 42                	jne    801815 <devpipe_read+0x77>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  8017d3:	e8 45 f4 ff ff       	call   800c1d <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8017d8:	8b 03                	mov    (%ebx),%eax
  8017da:	3b 43 04             	cmp    0x4(%ebx),%eax
  8017dd:	74 e7                	je     8017c6 <devpipe_read+0x28>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8017df:	25 1f 00 00 80       	and    $0x8000001f,%eax
  8017e4:	79 05                	jns    8017eb <devpipe_read+0x4d>
  8017e6:	48                   	dec    %eax
  8017e7:	83 c8 e0             	or     $0xffffffe0,%eax
  8017ea:	40                   	inc    %eax
  8017eb:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  8017ef:	8b 55 0c             	mov    0xc(%ebp),%edx
  8017f2:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  8017f5:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8017f7:	46                   	inc    %esi
  8017f8:	39 75 10             	cmp    %esi,0x10(%ebp)
  8017fb:	77 07                	ja     801804 <devpipe_read+0x66>
  8017fd:	eb 12                	jmp    801811 <devpipe_read+0x73>
  8017ff:	be 00 00 00 00       	mov    $0x0,%esi
		while (p->p_rpos == p->p_wpos) {
  801804:	8b 03                	mov    (%ebx),%eax
  801806:	3b 43 04             	cmp    0x4(%ebx),%eax
  801809:	75 d4                	jne    8017df <devpipe_read+0x41>
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  80180b:	85 f6                	test   %esi,%esi
  80180d:	75 b3                	jne    8017c2 <devpipe_read+0x24>
  80180f:	eb b5                	jmp    8017c6 <devpipe_read+0x28>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801811:	89 f0                	mov    %esi,%eax
  801813:	eb 05                	jmp    80181a <devpipe_read+0x7c>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801815:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  80181a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80181d:	5b                   	pop    %ebx
  80181e:	5e                   	pop    %esi
  80181f:	5f                   	pop    %edi
  801820:	c9                   	leave  
  801821:	c3                   	ret    

00801822 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801822:	55                   	push   %ebp
  801823:	89 e5                	mov    %esp,%ebp
  801825:	57                   	push   %edi
  801826:	56                   	push   %esi
  801827:	53                   	push   %ebx
  801828:	83 ec 28             	sub    $0x28,%esp
  80182b:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  80182e:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801831:	50                   	push   %eax
  801832:	e8 75 f6 ff ff       	call   800eac <fd_alloc>
  801837:	89 c3                	mov    %eax,%ebx
  801839:	83 c4 10             	add    $0x10,%esp
  80183c:	85 c0                	test   %eax,%eax
  80183e:	0f 88 24 01 00 00    	js     801968 <pipe+0x146>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801844:	83 ec 04             	sub    $0x4,%esp
  801847:	68 07 04 00 00       	push   $0x407
  80184c:	ff 75 e4             	pushl  -0x1c(%ebp)
  80184f:	6a 00                	push   $0x0
  801851:	e8 ee f3 ff ff       	call   800c44 <sys_page_alloc>
  801856:	89 c3                	mov    %eax,%ebx
  801858:	83 c4 10             	add    $0x10,%esp
  80185b:	85 c0                	test   %eax,%eax
  80185d:	0f 88 05 01 00 00    	js     801968 <pipe+0x146>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801863:	83 ec 0c             	sub    $0xc,%esp
  801866:	8d 45 e0             	lea    -0x20(%ebp),%eax
  801869:	50                   	push   %eax
  80186a:	e8 3d f6 ff ff       	call   800eac <fd_alloc>
  80186f:	89 c3                	mov    %eax,%ebx
  801871:	83 c4 10             	add    $0x10,%esp
  801874:	85 c0                	test   %eax,%eax
  801876:	0f 88 dc 00 00 00    	js     801958 <pipe+0x136>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80187c:	83 ec 04             	sub    $0x4,%esp
  80187f:	68 07 04 00 00       	push   $0x407
  801884:	ff 75 e0             	pushl  -0x20(%ebp)
  801887:	6a 00                	push   $0x0
  801889:	e8 b6 f3 ff ff       	call   800c44 <sys_page_alloc>
  80188e:	89 c3                	mov    %eax,%ebx
  801890:	83 c4 10             	add    $0x10,%esp
  801893:	85 c0                	test   %eax,%eax
  801895:	0f 88 bd 00 00 00    	js     801958 <pipe+0x136>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  80189b:	83 ec 0c             	sub    $0xc,%esp
  80189e:	ff 75 e4             	pushl  -0x1c(%ebp)
  8018a1:	e8 ee f5 ff ff       	call   800e94 <fd2data>
  8018a6:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8018a8:	83 c4 0c             	add    $0xc,%esp
  8018ab:	68 07 04 00 00       	push   $0x407
  8018b0:	50                   	push   %eax
  8018b1:	6a 00                	push   $0x0
  8018b3:	e8 8c f3 ff ff       	call   800c44 <sys_page_alloc>
  8018b8:	89 c3                	mov    %eax,%ebx
  8018ba:	83 c4 10             	add    $0x10,%esp
  8018bd:	85 c0                	test   %eax,%eax
  8018bf:	0f 88 83 00 00 00    	js     801948 <pipe+0x126>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8018c5:	83 ec 0c             	sub    $0xc,%esp
  8018c8:	ff 75 e0             	pushl  -0x20(%ebp)
  8018cb:	e8 c4 f5 ff ff       	call   800e94 <fd2data>
  8018d0:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  8018d7:	50                   	push   %eax
  8018d8:	6a 00                	push   $0x0
  8018da:	56                   	push   %esi
  8018db:	6a 00                	push   $0x0
  8018dd:	e8 86 f3 ff ff       	call   800c68 <sys_page_map>
  8018e2:	89 c3                	mov    %eax,%ebx
  8018e4:	83 c4 20             	add    $0x20,%esp
  8018e7:	85 c0                	test   %eax,%eax
  8018e9:	78 4f                	js     80193a <pipe+0x118>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  8018eb:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8018f1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8018f4:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8018f6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8018f9:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801900:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801906:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801909:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  80190b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80190e:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801915:	83 ec 0c             	sub    $0xc,%esp
  801918:	ff 75 e4             	pushl  -0x1c(%ebp)
  80191b:	e8 64 f5 ff ff       	call   800e84 <fd2num>
  801920:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  801922:	83 c4 04             	add    $0x4,%esp
  801925:	ff 75 e0             	pushl  -0x20(%ebp)
  801928:	e8 57 f5 ff ff       	call   800e84 <fd2num>
  80192d:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  801930:	83 c4 10             	add    $0x10,%esp
  801933:	bb 00 00 00 00       	mov    $0x0,%ebx
  801938:	eb 2e                	jmp    801968 <pipe+0x146>

    err3:
	sys_page_unmap(0, va);
  80193a:	83 ec 08             	sub    $0x8,%esp
  80193d:	56                   	push   %esi
  80193e:	6a 00                	push   $0x0
  801940:	e8 49 f3 ff ff       	call   800c8e <sys_page_unmap>
  801945:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801948:	83 ec 08             	sub    $0x8,%esp
  80194b:	ff 75 e0             	pushl  -0x20(%ebp)
  80194e:	6a 00                	push   $0x0
  801950:	e8 39 f3 ff ff       	call   800c8e <sys_page_unmap>
  801955:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801958:	83 ec 08             	sub    $0x8,%esp
  80195b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80195e:	6a 00                	push   $0x0
  801960:	e8 29 f3 ff ff       	call   800c8e <sys_page_unmap>
  801965:	83 c4 10             	add    $0x10,%esp
    err:
	return r;
}
  801968:	89 d8                	mov    %ebx,%eax
  80196a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80196d:	5b                   	pop    %ebx
  80196e:	5e                   	pop    %esi
  80196f:	5f                   	pop    %edi
  801970:	c9                   	leave  
  801971:	c3                   	ret    

00801972 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801972:	55                   	push   %ebp
  801973:	89 e5                	mov    %esp,%ebp
  801975:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801978:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80197b:	50                   	push   %eax
  80197c:	ff 75 08             	pushl  0x8(%ebp)
  80197f:	e8 9b f5 ff ff       	call   800f1f <fd_lookup>
  801984:	83 c4 10             	add    $0x10,%esp
  801987:	85 c0                	test   %eax,%eax
  801989:	78 18                	js     8019a3 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  80198b:	83 ec 0c             	sub    $0xc,%esp
  80198e:	ff 75 f4             	pushl  -0xc(%ebp)
  801991:	e8 fe f4 ff ff       	call   800e94 <fd2data>
	return _pipeisclosed(fd, p);
  801996:	89 c2                	mov    %eax,%edx
  801998:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80199b:	e8 0c fd ff ff       	call   8016ac <_pipeisclosed>
  8019a0:	83 c4 10             	add    $0x10,%esp
}
  8019a3:	c9                   	leave  
  8019a4:	c3                   	ret    
  8019a5:	00 00                	add    %al,(%eax)
	...

008019a8 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  8019a8:	55                   	push   %ebp
  8019a9:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  8019ab:	b8 00 00 00 00       	mov    $0x0,%eax
  8019b0:	c9                   	leave  
  8019b1:	c3                   	ret    

008019b2 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8019b2:	55                   	push   %ebp
  8019b3:	89 e5                	mov    %esp,%ebp
  8019b5:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  8019b8:	68 de 23 80 00       	push   $0x8023de
  8019bd:	ff 75 0c             	pushl  0xc(%ebp)
  8019c0:	e8 fd ed ff ff       	call   8007c2 <strcpy>
	return 0;
}
  8019c5:	b8 00 00 00 00       	mov    $0x0,%eax
  8019ca:	c9                   	leave  
  8019cb:	c3                   	ret    

008019cc <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8019cc:	55                   	push   %ebp
  8019cd:	89 e5                	mov    %esp,%ebp
  8019cf:	57                   	push   %edi
  8019d0:	56                   	push   %esi
  8019d1:	53                   	push   %ebx
  8019d2:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8019d8:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8019dc:	74 45                	je     801a23 <devcons_write+0x57>
  8019de:	b8 00 00 00 00       	mov    $0x0,%eax
  8019e3:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8019e8:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  8019ee:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8019f1:	29 c3                	sub    %eax,%ebx
		if (m > sizeof(buf) - 1)
  8019f3:	83 fb 7f             	cmp    $0x7f,%ebx
  8019f6:	76 05                	jbe    8019fd <devcons_write+0x31>
			m = sizeof(buf) - 1;
  8019f8:	bb 7f 00 00 00       	mov    $0x7f,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  8019fd:	83 ec 04             	sub    $0x4,%esp
  801a00:	53                   	push   %ebx
  801a01:	03 45 0c             	add    0xc(%ebp),%eax
  801a04:	50                   	push   %eax
  801a05:	57                   	push   %edi
  801a06:	e8 78 ef ff ff       	call   800983 <memmove>
		sys_cputs(buf, m);
  801a0b:	83 c4 08             	add    $0x8,%esp
  801a0e:	53                   	push   %ebx
  801a0f:	57                   	push   %edi
  801a10:	e8 78 f1 ff ff       	call   800b8d <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801a15:	01 de                	add    %ebx,%esi
  801a17:	89 f0                	mov    %esi,%eax
  801a19:	83 c4 10             	add    $0x10,%esp
  801a1c:	3b 75 10             	cmp    0x10(%ebp),%esi
  801a1f:	72 cd                	jb     8019ee <devcons_write+0x22>
  801a21:	eb 05                	jmp    801a28 <devcons_write+0x5c>
  801a23:	be 00 00 00 00       	mov    $0x0,%esi
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801a28:	89 f0                	mov    %esi,%eax
  801a2a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a2d:	5b                   	pop    %ebx
  801a2e:	5e                   	pop    %esi
  801a2f:	5f                   	pop    %edi
  801a30:	c9                   	leave  
  801a31:	c3                   	ret    

00801a32 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801a32:	55                   	push   %ebp
  801a33:	89 e5                	mov    %esp,%ebp
  801a35:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  801a38:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801a3c:	75 07                	jne    801a45 <devcons_read+0x13>
  801a3e:	eb 25                	jmp    801a65 <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801a40:	e8 d8 f1 ff ff       	call   800c1d <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801a45:	e8 69 f1 ff ff       	call   800bb3 <sys_cgetc>
  801a4a:	85 c0                	test   %eax,%eax
  801a4c:	74 f2                	je     801a40 <devcons_read+0xe>
  801a4e:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  801a50:	85 c0                	test   %eax,%eax
  801a52:	78 1d                	js     801a71 <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801a54:	83 f8 04             	cmp    $0x4,%eax
  801a57:	74 13                	je     801a6c <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  801a59:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a5c:	88 10                	mov    %dl,(%eax)
	return 1;
  801a5e:	b8 01 00 00 00       	mov    $0x1,%eax
  801a63:	eb 0c                	jmp    801a71 <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  801a65:	b8 00 00 00 00       	mov    $0x0,%eax
  801a6a:	eb 05                	jmp    801a71 <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801a6c:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801a71:	c9                   	leave  
  801a72:	c3                   	ret    

00801a73 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801a73:	55                   	push   %ebp
  801a74:	89 e5                	mov    %esp,%ebp
  801a76:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801a79:	8b 45 08             	mov    0x8(%ebp),%eax
  801a7c:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801a7f:	6a 01                	push   $0x1
  801a81:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801a84:	50                   	push   %eax
  801a85:	e8 03 f1 ff ff       	call   800b8d <sys_cputs>
  801a8a:	83 c4 10             	add    $0x10,%esp
}
  801a8d:	c9                   	leave  
  801a8e:	c3                   	ret    

00801a8f <getchar>:

int
getchar(void)
{
  801a8f:	55                   	push   %ebp
  801a90:	89 e5                	mov    %esp,%ebp
  801a92:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801a95:	6a 01                	push   $0x1
  801a97:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801a9a:	50                   	push   %eax
  801a9b:	6a 00                	push   $0x0
  801a9d:	e8 fe f6 ff ff       	call   8011a0 <read>
	if (r < 0)
  801aa2:	83 c4 10             	add    $0x10,%esp
  801aa5:	85 c0                	test   %eax,%eax
  801aa7:	78 0f                	js     801ab8 <getchar+0x29>
		return r;
	if (r < 1)
  801aa9:	85 c0                	test   %eax,%eax
  801aab:	7e 06                	jle    801ab3 <getchar+0x24>
		return -E_EOF;
	return c;
  801aad:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801ab1:	eb 05                	jmp    801ab8 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801ab3:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801ab8:	c9                   	leave  
  801ab9:	c3                   	ret    

00801aba <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801aba:	55                   	push   %ebp
  801abb:	89 e5                	mov    %esp,%ebp
  801abd:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801ac0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ac3:	50                   	push   %eax
  801ac4:	ff 75 08             	pushl  0x8(%ebp)
  801ac7:	e8 53 f4 ff ff       	call   800f1f <fd_lookup>
  801acc:	83 c4 10             	add    $0x10,%esp
  801acf:	85 c0                	test   %eax,%eax
  801ad1:	78 11                	js     801ae4 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801ad3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ad6:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801adc:	39 10                	cmp    %edx,(%eax)
  801ade:	0f 94 c0             	sete   %al
  801ae1:	0f b6 c0             	movzbl %al,%eax
}
  801ae4:	c9                   	leave  
  801ae5:	c3                   	ret    

00801ae6 <opencons>:

int
opencons(void)
{
  801ae6:	55                   	push   %ebp
  801ae7:	89 e5                	mov    %esp,%ebp
  801ae9:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801aec:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801aef:	50                   	push   %eax
  801af0:	e8 b7 f3 ff ff       	call   800eac <fd_alloc>
  801af5:	83 c4 10             	add    $0x10,%esp
  801af8:	85 c0                	test   %eax,%eax
  801afa:	78 3a                	js     801b36 <opencons+0x50>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801afc:	83 ec 04             	sub    $0x4,%esp
  801aff:	68 07 04 00 00       	push   $0x407
  801b04:	ff 75 f4             	pushl  -0xc(%ebp)
  801b07:	6a 00                	push   $0x0
  801b09:	e8 36 f1 ff ff       	call   800c44 <sys_page_alloc>
  801b0e:	83 c4 10             	add    $0x10,%esp
  801b11:	85 c0                	test   %eax,%eax
  801b13:	78 21                	js     801b36 <opencons+0x50>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801b15:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801b1b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b1e:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801b20:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b23:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801b2a:	83 ec 0c             	sub    $0xc,%esp
  801b2d:	50                   	push   %eax
  801b2e:	e8 51 f3 ff ff       	call   800e84 <fd2num>
  801b33:	83 c4 10             	add    $0x10,%esp
}
  801b36:	c9                   	leave  
  801b37:	c3                   	ret    

00801b38 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801b38:	55                   	push   %ebp
  801b39:	89 e5                	mov    %esp,%ebp
  801b3b:	56                   	push   %esi
  801b3c:	53                   	push   %ebx
  801b3d:	8b 75 08             	mov    0x8(%ebp),%esi
  801b40:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b43:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// cprintf("0x%x 0x%x 0x%x\n", (uint32_t)from_env_store, (uint32_t)pg, (uint32_t)perm_store);
	int r;
	if (pg != NULL) {
  801b46:	85 c0                	test   %eax,%eax
  801b48:	74 0e                	je     801b58 <ipc_recv+0x20>
		r = sys_ipc_recv(pg);
  801b4a:	83 ec 0c             	sub    $0xc,%esp
  801b4d:	50                   	push   %eax
  801b4e:	e8 ec f1 ff ff       	call   800d3f <sys_ipc_recv>
  801b53:	83 c4 10             	add    $0x10,%esp
  801b56:	eb 10                	jmp    801b68 <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv((void *)UTOP);
  801b58:	83 ec 0c             	sub    $0xc,%esp
  801b5b:	68 00 00 c0 ee       	push   $0xeec00000
  801b60:	e8 da f1 ff ff       	call   800d3f <sys_ipc_recv>
  801b65:	83 c4 10             	add    $0x10,%esp
	}

	if (r == 0) {
  801b68:	85 c0                	test   %eax,%eax
  801b6a:	75 26                	jne    801b92 <ipc_recv+0x5a>
		if (from_env_store != NULL) *from_env_store = thisenv->env_ipc_from;
  801b6c:	85 f6                	test   %esi,%esi
  801b6e:	74 0a                	je     801b7a <ipc_recv+0x42>
  801b70:	a1 04 40 80 00       	mov    0x804004,%eax
  801b75:	8b 40 74             	mov    0x74(%eax),%eax
  801b78:	89 06                	mov    %eax,(%esi)
		if (perm_store != NULL) *perm_store = thisenv->env_ipc_perm;
  801b7a:	85 db                	test   %ebx,%ebx
  801b7c:	74 0a                	je     801b88 <ipc_recv+0x50>
  801b7e:	a1 04 40 80 00       	mov    0x804004,%eax
  801b83:	8b 40 78             	mov    0x78(%eax),%eax
  801b86:	89 03                	mov    %eax,(%ebx)
		return thisenv->env_ipc_value;
  801b88:	a1 04 40 80 00       	mov    0x804004,%eax
  801b8d:	8b 40 70             	mov    0x70(%eax),%eax
  801b90:	eb 14                	jmp    801ba6 <ipc_recv+0x6e>
	} else {
		// fails;
		if (from_env_store != NULL) *from_env_store = 0;
  801b92:	85 f6                	test   %esi,%esi
  801b94:	74 06                	je     801b9c <ipc_recv+0x64>
  801b96:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if (perm_store != NULL) *perm_store = 0;
  801b9c:	85 db                	test   %ebx,%ebx
  801b9e:	74 06                	je     801ba6 <ipc_recv+0x6e>
  801ba0:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		return r;
	}
}
  801ba6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ba9:	5b                   	pop    %ebx
  801baa:	5e                   	pop    %esi
  801bab:	c9                   	leave  
  801bac:	c3                   	ret    

00801bad <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801bad:	55                   	push   %ebp
  801bae:	89 e5                	mov    %esp,%ebp
  801bb0:	57                   	push   %edi
  801bb1:	56                   	push   %esi
  801bb2:	53                   	push   %ebx
  801bb3:	83 ec 0c             	sub    $0xc,%esp
  801bb6:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801bb9:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801bbc:	8b 75 14             	mov    0x14(%ebp),%esi
	// LAB 4: Your code here.
	// int sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
	int r;
	if (pg == NULL) pg = (void *)UTOP;
  801bbf:	85 db                	test   %ebx,%ebx
  801bc1:	75 25                	jne    801be8 <ipc_send+0x3b>
  801bc3:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
  801bc8:	eb 1e                	jmp    801be8 <ipc_send+0x3b>
	
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) != 0) {
		if (r == -E_IPC_NOT_RECV) {
  801bca:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801bcd:	75 07                	jne    801bd6 <ipc_send+0x29>
			// cprintf("Try Again and Again....\n");
			sys_yield();
  801bcf:	e8 49 f0 ff ff       	call   800c1d <sys_yield>
  801bd4:	eb 12                	jmp    801be8 <ipc_send+0x3b>
		} else {
			panic("ipc_send error %e\n", r);
  801bd6:	50                   	push   %eax
  801bd7:	68 ea 23 80 00       	push   $0x8023ea
  801bdc:	6a 43                	push   $0x43
  801bde:	68 fd 23 80 00       	push   $0x8023fd
  801be3:	e8 4c e5 ff ff       	call   800134 <_panic>
	// LAB 4: Your code here.
	// int sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
	int r;
	if (pg == NULL) pg = (void *)UTOP;
	
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) != 0) {
  801be8:	56                   	push   %esi
  801be9:	53                   	push   %ebx
  801bea:	57                   	push   %edi
  801beb:	ff 75 08             	pushl  0x8(%ebp)
  801bee:	e8 27 f1 ff ff       	call   800d1a <sys_ipc_try_send>
  801bf3:	83 c4 10             	add    $0x10,%esp
  801bf6:	85 c0                	test   %eax,%eax
  801bf8:	75 d0                	jne    801bca <ipc_send+0x1d>
		} else {
			panic("ipc_send error %e\n", r);
		}
	}
	return;
}
  801bfa:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801bfd:	5b                   	pop    %ebx
  801bfe:	5e                   	pop    %esi
  801bff:	5f                   	pop    %edi
  801c00:	c9                   	leave  
  801c01:	c3                   	ret    

00801c02 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801c02:	55                   	push   %ebp
  801c03:	89 e5                	mov    %esp,%ebp
  801c05:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  801c08:	39 0d 50 00 c0 ee    	cmp    %ecx,0xeec00050
  801c0e:	74 1a                	je     801c2a <ipc_find_env+0x28>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801c10:	b8 01 00 00 00       	mov    $0x1,%eax
		if (envs[i].env_type == type)
  801c15:	89 c2                	mov    %eax,%edx
  801c17:	c1 e2 07             	shl    $0x7,%edx
  801c1a:	8d 94 82 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,4),%edx
  801c21:	8b 52 50             	mov    0x50(%edx),%edx
  801c24:	39 ca                	cmp    %ecx,%edx
  801c26:	75 18                	jne    801c40 <ipc_find_env+0x3e>
  801c28:	eb 05                	jmp    801c2f <ipc_find_env+0x2d>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801c2a:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
			return envs[i].env_id;
  801c2f:	89 c2                	mov    %eax,%edx
  801c31:	c1 e2 07             	shl    $0x7,%edx
  801c34:	8d 84 82 08 00 c0 ee 	lea    -0x113ffff8(%edx,%eax,4),%eax
  801c3b:	8b 40 40             	mov    0x40(%eax),%eax
  801c3e:	eb 0c                	jmp    801c4c <ipc_find_env+0x4a>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801c40:	40                   	inc    %eax
  801c41:	3d 00 04 00 00       	cmp    $0x400,%eax
  801c46:	75 cd                	jne    801c15 <ipc_find_env+0x13>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801c48:	66 b8 00 00          	mov    $0x0,%ax
}
  801c4c:	c9                   	leave  
  801c4d:	c3                   	ret    
	...

00801c50 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801c50:	55                   	push   %ebp
  801c51:	89 e5                	mov    %esp,%ebp
  801c53:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801c56:	89 c2                	mov    %eax,%edx
  801c58:	c1 ea 16             	shr    $0x16,%edx
  801c5b:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801c62:	f6 c2 01             	test   $0x1,%dl
  801c65:	74 1e                	je     801c85 <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  801c67:	c1 e8 0c             	shr    $0xc,%eax
  801c6a:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801c71:	a8 01                	test   $0x1,%al
  801c73:	74 17                	je     801c8c <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801c75:	c1 e8 0c             	shr    $0xc,%eax
  801c78:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  801c7f:	ef 
  801c80:	0f b7 c0             	movzwl %ax,%eax
  801c83:	eb 0c                	jmp    801c91 <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  801c85:	b8 00 00 00 00       	mov    $0x0,%eax
  801c8a:	eb 05                	jmp    801c91 <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  801c8c:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  801c91:	c9                   	leave  
  801c92:	c3                   	ret    
	...

00801c94 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  801c94:	55                   	push   %ebp
  801c95:	89 e5                	mov    %esp,%ebp
  801c97:	57                   	push   %edi
  801c98:	56                   	push   %esi
  801c99:	83 ec 10             	sub    $0x10,%esp
  801c9c:	8b 7d 08             	mov    0x8(%ebp),%edi
  801c9f:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  801ca2:	89 7d f0             	mov    %edi,-0x10(%ebp)
  801ca5:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  801ca8:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  801cab:	8b 45 14             	mov    0x14(%ebp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  801cae:	85 c0                	test   %eax,%eax
  801cb0:	75 2e                	jne    801ce0 <__udivdi3+0x4c>
    {
      if (d0 > n1)
  801cb2:	39 f1                	cmp    %esi,%ecx
  801cb4:	77 5a                	ja     801d10 <__udivdi3+0x7c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  801cb6:	85 c9                	test   %ecx,%ecx
  801cb8:	75 0b                	jne    801cc5 <__udivdi3+0x31>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  801cba:	b8 01 00 00 00       	mov    $0x1,%eax
  801cbf:	31 d2                	xor    %edx,%edx
  801cc1:	f7 f1                	div    %ecx
  801cc3:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  801cc5:	31 d2                	xor    %edx,%edx
  801cc7:	89 f0                	mov    %esi,%eax
  801cc9:	f7 f1                	div    %ecx
  801ccb:	89 c6                	mov    %eax,%esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801ccd:	89 f8                	mov    %edi,%eax
  801ccf:	f7 f1                	div    %ecx
  801cd1:	89 c7                	mov    %eax,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801cd3:	89 f8                	mov    %edi,%eax
  801cd5:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801cd7:	83 c4 10             	add    $0x10,%esp
  801cda:	5e                   	pop    %esi
  801cdb:	5f                   	pop    %edi
  801cdc:	c9                   	leave  
  801cdd:	c3                   	ret    
  801cde:	66 90                	xchg   %ax,%ax
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801ce0:	39 f0                	cmp    %esi,%eax
  801ce2:	77 1c                	ja     801d00 <__udivdi3+0x6c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  801ce4:	0f bd f8             	bsr    %eax,%edi
	  if (bm == 0)
  801ce7:	83 f7 1f             	xor    $0x1f,%edi
  801cea:	75 3c                	jne    801d28 <__udivdi3+0x94>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801cec:	39 f0                	cmp    %esi,%eax
  801cee:	0f 82 90 00 00 00    	jb     801d84 <__udivdi3+0xf0>
  801cf4:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801cf7:	39 55 f4             	cmp    %edx,-0xc(%ebp)
  801cfa:	0f 86 84 00 00 00    	jbe    801d84 <__udivdi3+0xf0>
  801d00:	31 f6                	xor    %esi,%esi
  801d02:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801d04:	89 f8                	mov    %edi,%eax
  801d06:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801d08:	83 c4 10             	add    $0x10,%esp
  801d0b:	5e                   	pop    %esi
  801d0c:	5f                   	pop    %edi
  801d0d:	c9                   	leave  
  801d0e:	c3                   	ret    
  801d0f:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801d10:	89 f2                	mov    %esi,%edx
  801d12:	89 f8                	mov    %edi,%eax
  801d14:	f7 f1                	div    %ecx
  801d16:	89 c7                	mov    %eax,%edi
  801d18:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801d1a:	89 f8                	mov    %edi,%eax
  801d1c:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801d1e:	83 c4 10             	add    $0x10,%esp
  801d21:	5e                   	pop    %esi
  801d22:	5f                   	pop    %edi
  801d23:	c9                   	leave  
  801d24:	c3                   	ret    
  801d25:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  801d28:	89 f9                	mov    %edi,%ecx
  801d2a:	d3 e0                	shl    %cl,%eax
  801d2c:	89 45 e8             	mov    %eax,-0x18(%ebp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  801d2f:	b8 20 00 00 00       	mov    $0x20,%eax
  801d34:	29 f8                	sub    %edi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  801d36:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801d39:	88 c1                	mov    %al,%cl
  801d3b:	d3 ea                	shr    %cl,%edx
  801d3d:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  801d40:	09 ca                	or     %ecx,%edx
  801d42:	89 55 ec             	mov    %edx,-0x14(%ebp)
	      d0 = d0 << bm;
  801d45:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801d48:	89 f9                	mov    %edi,%ecx
  801d4a:	d3 e2                	shl    %cl,%edx
  801d4c:	89 55 f4             	mov    %edx,-0xc(%ebp)
	      n2 = n1 >> b;
  801d4f:	89 f2                	mov    %esi,%edx
  801d51:	88 c1                	mov    %al,%cl
  801d53:	d3 ea                	shr    %cl,%edx
  801d55:	89 55 e8             	mov    %edx,-0x18(%ebp)
	      n1 = (n1 << bm) | (n0 >> b);
  801d58:	89 f2                	mov    %esi,%edx
  801d5a:	89 f9                	mov    %edi,%ecx
  801d5c:	d3 e2                	shl    %cl,%edx
  801d5e:	8b 75 f0             	mov    -0x10(%ebp),%esi
  801d61:	88 c1                	mov    %al,%cl
  801d63:	d3 ee                	shr    %cl,%esi
  801d65:	09 d6                	or     %edx,%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  801d67:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  801d6a:	89 f0                	mov    %esi,%eax
  801d6c:	89 ca                	mov    %ecx,%edx
  801d6e:	f7 75 ec             	divl   -0x14(%ebp)
  801d71:	89 d1                	mov    %edx,%ecx
  801d73:	89 c6                	mov    %eax,%esi
	      umul_ppmm (m1, m0, q0, d0);
  801d75:	f7 65 f4             	mull   -0xc(%ebp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801d78:	39 d1                	cmp    %edx,%ecx
  801d7a:	72 28                	jb     801da4 <__udivdi3+0x110>
  801d7c:	74 1a                	je     801d98 <__udivdi3+0x104>
  801d7e:	89 f7                	mov    %esi,%edi
  801d80:	31 f6                	xor    %esi,%esi
  801d82:	eb 80                	jmp    801d04 <__udivdi3+0x70>
	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  801d84:	31 f6                	xor    %esi,%esi
  801d86:	bf 01 00 00 00       	mov    $0x1,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801d8b:	89 f8                	mov    %edi,%eax
  801d8d:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801d8f:	83 c4 10             	add    $0x10,%esp
  801d92:	5e                   	pop    %esi
  801d93:	5f                   	pop    %edi
  801d94:	c9                   	leave  
  801d95:	c3                   	ret    
  801d96:	66 90                	xchg   %ax,%ax

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  801d98:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801d9b:	89 f9                	mov    %edi,%ecx
  801d9d:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801d9f:	39 c2                	cmp    %eax,%edx
  801da1:	73 db                	jae    801d7e <__udivdi3+0xea>
  801da3:	90                   	nop
		{
		  q0--;
  801da4:	8d 7e ff             	lea    -0x1(%esi),%edi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  801da7:	31 f6                	xor    %esi,%esi
  801da9:	e9 56 ff ff ff       	jmp    801d04 <__udivdi3+0x70>
	...

00801db0 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  801db0:	55                   	push   %ebp
  801db1:	89 e5                	mov    %esp,%ebp
  801db3:	57                   	push   %edi
  801db4:	56                   	push   %esi
  801db5:	83 ec 20             	sub    $0x20,%esp
  801db8:	8b 45 08             	mov    0x8(%ebp),%eax
  801dbb:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  801dbe:	89 45 e8             	mov    %eax,-0x18(%ebp)
  801dc1:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  801dc4:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  801dc7:	8b 7d 14             	mov    0x14(%ebp),%edi
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  801dca:	89 45 f0             	mov    %eax,-0x10(%ebp)
  n1 = nn.s.high;
  801dcd:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  801dcf:	85 ff                	test   %edi,%edi
  801dd1:	75 15                	jne    801de8 <__umoddi3+0x38>
    {
      if (d0 > n1)
  801dd3:	39 f1                	cmp    %esi,%ecx
  801dd5:	0f 86 99 00 00 00    	jbe    801e74 <__umoddi3+0xc4>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801ddb:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  801ddd:	89 d0                	mov    %edx,%eax
  801ddf:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801de1:	83 c4 20             	add    $0x20,%esp
  801de4:	5e                   	pop    %esi
  801de5:	5f                   	pop    %edi
  801de6:	c9                   	leave  
  801de7:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801de8:	39 f7                	cmp    %esi,%edi
  801dea:	0f 87 a4 00 00 00    	ja     801e94 <__umoddi3+0xe4>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  801df0:	0f bd c7             	bsr    %edi,%eax
	  if (bm == 0)
  801df3:	83 f0 1f             	xor    $0x1f,%eax
  801df6:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801df9:	0f 84 a1 00 00 00    	je     801ea0 <__umoddi3+0xf0>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  801dff:	89 f8                	mov    %edi,%eax
  801e01:	8a 4d ec             	mov    -0x14(%ebp),%cl
  801e04:	d3 e0                	shl    %cl,%eax
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  801e06:	bf 20 00 00 00       	mov    $0x20,%edi
  801e0b:	2b 7d ec             	sub    -0x14(%ebp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  801e0e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801e11:	89 f9                	mov    %edi,%ecx
  801e13:	d3 ea                	shr    %cl,%edx
  801e15:	09 c2                	or     %eax,%edx
  801e17:	89 55 f0             	mov    %edx,-0x10(%ebp)
	      d0 = d0 << bm;
  801e1a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e1d:	8a 4d ec             	mov    -0x14(%ebp),%cl
  801e20:	d3 e0                	shl    %cl,%eax
  801e22:	89 45 f4             	mov    %eax,-0xc(%ebp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  801e25:	89 f2                	mov    %esi,%edx
  801e27:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  801e29:	8b 45 e8             	mov    -0x18(%ebp),%eax
  801e2c:	d3 e0                	shl    %cl,%eax
  801e2e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  801e31:	8b 45 e8             	mov    -0x18(%ebp),%eax
  801e34:	89 f9                	mov    %edi,%ecx
  801e36:	d3 e8                	shr    %cl,%eax
  801e38:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  801e3a:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  801e3c:	89 f2                	mov    %esi,%edx
  801e3e:	f7 75 f0             	divl   -0x10(%ebp)
  801e41:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  801e43:	f7 65 f4             	mull   -0xc(%ebp)
  801e46:	89 55 e8             	mov    %edx,-0x18(%ebp)
  801e49:	89 c1                	mov    %eax,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801e4b:	39 d6                	cmp    %edx,%esi
  801e4d:	72 71                	jb     801ec0 <__umoddi3+0x110>
  801e4f:	74 7f                	je     801ed0 <__umoddi3+0x120>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  801e51:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801e54:	29 c8                	sub    %ecx,%eax
  801e56:	19 d6                	sbb    %edx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  801e58:	8a 4d ec             	mov    -0x14(%ebp),%cl
  801e5b:	d3 e8                	shr    %cl,%eax
  801e5d:	89 f2                	mov    %esi,%edx
  801e5f:	89 f9                	mov    %edi,%ecx
  801e61:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  801e63:	09 d0                	or     %edx,%eax
  801e65:	89 f2                	mov    %esi,%edx
  801e67:	8a 4d ec             	mov    -0x14(%ebp),%cl
  801e6a:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801e6c:	83 c4 20             	add    $0x20,%esp
  801e6f:	5e                   	pop    %esi
  801e70:	5f                   	pop    %edi
  801e71:	c9                   	leave  
  801e72:	c3                   	ret    
  801e73:	90                   	nop
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  801e74:	85 c9                	test   %ecx,%ecx
  801e76:	75 0b                	jne    801e83 <__umoddi3+0xd3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  801e78:	b8 01 00 00 00       	mov    $0x1,%eax
  801e7d:	31 d2                	xor    %edx,%edx
  801e7f:	f7 f1                	div    %ecx
  801e81:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  801e83:	89 f0                	mov    %esi,%eax
  801e85:	31 d2                	xor    %edx,%edx
  801e87:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801e89:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801e8c:	f7 f1                	div    %ecx
  801e8e:	e9 4a ff ff ff       	jmp    801ddd <__umoddi3+0x2d>
  801e93:	90                   	nop
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  801e94:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801e96:	83 c4 20             	add    $0x20,%esp
  801e99:	5e                   	pop    %esi
  801e9a:	5f                   	pop    %edi
  801e9b:	c9                   	leave  
  801e9c:	c3                   	ret    
  801e9d:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801ea0:	39 f7                	cmp    %esi,%edi
  801ea2:	72 05                	jb     801ea9 <__umoddi3+0xf9>
  801ea4:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
  801ea7:	77 0c                	ja     801eb5 <__umoddi3+0x105>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  801ea9:	89 f2                	mov    %esi,%edx
  801eab:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801eae:	29 c8                	sub    %ecx,%eax
  801eb0:	19 fa                	sbb    %edi,%edx
  801eb2:	89 45 f0             	mov    %eax,-0x10(%ebp)

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  801eb5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801eb8:	83 c4 20             	add    $0x20,%esp
  801ebb:	5e                   	pop    %esi
  801ebc:	5f                   	pop    %edi
  801ebd:	c9                   	leave  
  801ebe:	c3                   	ret    
  801ebf:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  801ec0:	8b 55 e8             	mov    -0x18(%ebp),%edx
  801ec3:	89 c1                	mov    %eax,%ecx
  801ec5:	2b 4d f4             	sub    -0xc(%ebp),%ecx
  801ec8:	1b 55 f0             	sbb    -0x10(%ebp),%edx
  801ecb:	eb 84                	jmp    801e51 <__umoddi3+0xa1>
  801ecd:	8d 76 00             	lea    0x0(%esi),%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801ed0:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801ed3:	72 eb                	jb     801ec0 <__umoddi3+0x110>
  801ed5:	89 f2                	mov    %esi,%edx
  801ed7:	e9 75 ff ff ff       	jmp    801e51 <__umoddi3+0xa1>
