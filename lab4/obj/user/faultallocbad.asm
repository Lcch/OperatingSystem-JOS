
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
  800041:	68 20 10 80 00       	push   $0x801020
  800046:	e8 a1 01 00 00       	call   8001ec <cprintf>
	if ((r = sys_page_alloc(0, ROUNDDOWN(addr, PGSIZE),
  80004b:	83 c4 0c             	add    $0xc,%esp
  80004e:	6a 07                	push   $0x7
  800050:	89 d8                	mov    %ebx,%eax
  800052:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800057:	50                   	push   %eax
  800058:	6a 00                	push   $0x0
  80005a:	e8 c5 0b 00 00       	call   800c24 <sys_page_alloc>
  80005f:	83 c4 10             	add    $0x10,%esp
  800062:	85 c0                	test   %eax,%eax
  800064:	79 16                	jns    80007c <handler+0x48>
				PTE_P|PTE_U|PTE_W)) < 0)
		panic("allocating at %x in page fault handler: %e", addr, r);
  800066:	83 ec 0c             	sub    $0xc,%esp
  800069:	50                   	push   %eax
  80006a:	53                   	push   %ebx
  80006b:	68 40 10 80 00       	push   $0x801040
  800070:	6a 0f                	push   $0xf
  800072:	68 2a 10 80 00       	push   $0x80102a
  800077:	e8 98 00 00 00       	call   800114 <_panic>
	snprintf((char*) addr, 100, "this string was faulted in at %x", addr);
  80007c:	53                   	push   %ebx
  80007d:	68 6c 10 80 00       	push   $0x80106c
  800082:	6a 64                	push   $0x64
  800084:	53                   	push   %ebx
  800085:	e8 aa 06 00 00       	call   800734 <snprintf>
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
  80009d:	e8 a2 0c 00 00       	call   800d44 <set_pgfault_handler>
	sys_cputs((char*)0xDEADBEEF, 4);
  8000a2:	83 c4 08             	add    $0x8,%esp
  8000a5:	6a 04                	push   $0x4
  8000a7:	68 ef be ad de       	push   $0xdeadbeef
  8000ac:	e8 bc 0a 00 00       	call   800b6d <sys_cputs>
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
  8000c3:	e8 11 0b 00 00       	call   800bd9 <sys_getenvid>
  8000c8:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000cd:	c1 e0 07             	shl    $0x7,%eax
  8000d0:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000d5:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000da:	85 f6                	test   %esi,%esi
  8000dc:	7e 07                	jle    8000e5 <libmain+0x2d>
		binaryname = argv[0];
  8000de:	8b 03                	mov    (%ebx),%eax
  8000e0:	a3 00 20 80 00       	mov    %eax,0x802000
	// call user main routine
	umain(argc, argv);
  8000e5:	83 ec 08             	sub    $0x8,%esp
  8000e8:	53                   	push   %ebx
  8000e9:	56                   	push   %esi
  8000ea:	e8 a3 ff ff ff       	call   800092 <umain>

	// exit gracefully
	exit();
  8000ef:	e8 0c 00 00 00       	call   800100 <exit>
  8000f4:	83 c4 10             	add    $0x10,%esp
}
  8000f7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000fa:	5b                   	pop    %ebx
  8000fb:	5e                   	pop    %esi
  8000fc:	c9                   	leave  
  8000fd:	c3                   	ret    
	...

00800100 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800100:	55                   	push   %ebp
  800101:	89 e5                	mov    %esp,%ebp
  800103:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  800106:	6a 00                	push   $0x0
  800108:	e8 aa 0a 00 00       	call   800bb7 <sys_env_destroy>
  80010d:	83 c4 10             	add    $0x10,%esp
}
  800110:	c9                   	leave  
  800111:	c3                   	ret    
	...

00800114 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800114:	55                   	push   %ebp
  800115:	89 e5                	mov    %esp,%ebp
  800117:	56                   	push   %esi
  800118:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800119:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80011c:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  800122:	e8 b2 0a 00 00       	call   800bd9 <sys_getenvid>
  800127:	83 ec 0c             	sub    $0xc,%esp
  80012a:	ff 75 0c             	pushl  0xc(%ebp)
  80012d:	ff 75 08             	pushl  0x8(%ebp)
  800130:	53                   	push   %ebx
  800131:	50                   	push   %eax
  800132:	68 98 10 80 00       	push   $0x801098
  800137:	e8 b0 00 00 00       	call   8001ec <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80013c:	83 c4 18             	add    $0x18,%esp
  80013f:	56                   	push   %esi
  800140:	ff 75 10             	pushl  0x10(%ebp)
  800143:	e8 53 00 00 00       	call   80019b <vcprintf>
	cprintf("\n");
  800148:	c7 04 24 48 13 80 00 	movl   $0x801348,(%esp)
  80014f:	e8 98 00 00 00       	call   8001ec <cprintf>
  800154:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800157:	cc                   	int3   
  800158:	eb fd                	jmp    800157 <_panic+0x43>
	...

0080015c <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80015c:	55                   	push   %ebp
  80015d:	89 e5                	mov    %esp,%ebp
  80015f:	53                   	push   %ebx
  800160:	83 ec 04             	sub    $0x4,%esp
  800163:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800166:	8b 03                	mov    (%ebx),%eax
  800168:	8b 55 08             	mov    0x8(%ebp),%edx
  80016b:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  80016f:	40                   	inc    %eax
  800170:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  800172:	3d ff 00 00 00       	cmp    $0xff,%eax
  800177:	75 1a                	jne    800193 <putch+0x37>
		sys_cputs(b->buf, b->idx);
  800179:	83 ec 08             	sub    $0x8,%esp
  80017c:	68 ff 00 00 00       	push   $0xff
  800181:	8d 43 08             	lea    0x8(%ebx),%eax
  800184:	50                   	push   %eax
  800185:	e8 e3 09 00 00       	call   800b6d <sys_cputs>
		b->idx = 0;
  80018a:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800190:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800193:	ff 43 04             	incl   0x4(%ebx)
}
  800196:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800199:	c9                   	leave  
  80019a:	c3                   	ret    

0080019b <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80019b:	55                   	push   %ebp
  80019c:	89 e5                	mov    %esp,%ebp
  80019e:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001a4:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001ab:	00 00 00 
	b.cnt = 0;
  8001ae:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001b5:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001b8:	ff 75 0c             	pushl  0xc(%ebp)
  8001bb:	ff 75 08             	pushl  0x8(%ebp)
  8001be:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001c4:	50                   	push   %eax
  8001c5:	68 5c 01 80 00       	push   $0x80015c
  8001ca:	e8 82 01 00 00       	call   800351 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001cf:	83 c4 08             	add    $0x8,%esp
  8001d2:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8001d8:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001de:	50                   	push   %eax
  8001df:	e8 89 09 00 00       	call   800b6d <sys_cputs>

	return b.cnt;
}
  8001e4:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001ea:	c9                   	leave  
  8001eb:	c3                   	ret    

008001ec <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001ec:	55                   	push   %ebp
  8001ed:	89 e5                	mov    %esp,%ebp
  8001ef:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001f2:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001f5:	50                   	push   %eax
  8001f6:	ff 75 08             	pushl  0x8(%ebp)
  8001f9:	e8 9d ff ff ff       	call   80019b <vcprintf>
	va_end(ap);

	return cnt;
}
  8001fe:	c9                   	leave  
  8001ff:	c3                   	ret    

00800200 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800200:	55                   	push   %ebp
  800201:	89 e5                	mov    %esp,%ebp
  800203:	57                   	push   %edi
  800204:	56                   	push   %esi
  800205:	53                   	push   %ebx
  800206:	83 ec 2c             	sub    $0x2c,%esp
  800209:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80020c:	89 d6                	mov    %edx,%esi
  80020e:	8b 45 08             	mov    0x8(%ebp),%eax
  800211:	8b 55 0c             	mov    0xc(%ebp),%edx
  800214:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800217:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80021a:	8b 45 10             	mov    0x10(%ebp),%eax
  80021d:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800220:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800223:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800226:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  80022d:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
  800230:	72 0c                	jb     80023e <printnum+0x3e>
  800232:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  800235:	76 07                	jbe    80023e <printnum+0x3e>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800237:	4b                   	dec    %ebx
  800238:	85 db                	test   %ebx,%ebx
  80023a:	7f 31                	jg     80026d <printnum+0x6d>
  80023c:	eb 3f                	jmp    80027d <printnum+0x7d>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80023e:	83 ec 0c             	sub    $0xc,%esp
  800241:	57                   	push   %edi
  800242:	4b                   	dec    %ebx
  800243:	53                   	push   %ebx
  800244:	50                   	push   %eax
  800245:	83 ec 08             	sub    $0x8,%esp
  800248:	ff 75 d4             	pushl  -0x2c(%ebp)
  80024b:	ff 75 d0             	pushl  -0x30(%ebp)
  80024e:	ff 75 dc             	pushl  -0x24(%ebp)
  800251:	ff 75 d8             	pushl  -0x28(%ebp)
  800254:	e8 7f 0b 00 00       	call   800dd8 <__udivdi3>
  800259:	83 c4 18             	add    $0x18,%esp
  80025c:	52                   	push   %edx
  80025d:	50                   	push   %eax
  80025e:	89 f2                	mov    %esi,%edx
  800260:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800263:	e8 98 ff ff ff       	call   800200 <printnum>
  800268:	83 c4 20             	add    $0x20,%esp
  80026b:	eb 10                	jmp    80027d <printnum+0x7d>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80026d:	83 ec 08             	sub    $0x8,%esp
  800270:	56                   	push   %esi
  800271:	57                   	push   %edi
  800272:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800275:	4b                   	dec    %ebx
  800276:	83 c4 10             	add    $0x10,%esp
  800279:	85 db                	test   %ebx,%ebx
  80027b:	7f f0                	jg     80026d <printnum+0x6d>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80027d:	83 ec 08             	sub    $0x8,%esp
  800280:	56                   	push   %esi
  800281:	83 ec 04             	sub    $0x4,%esp
  800284:	ff 75 d4             	pushl  -0x2c(%ebp)
  800287:	ff 75 d0             	pushl  -0x30(%ebp)
  80028a:	ff 75 dc             	pushl  -0x24(%ebp)
  80028d:	ff 75 d8             	pushl  -0x28(%ebp)
  800290:	e8 5f 0c 00 00       	call   800ef4 <__umoddi3>
  800295:	83 c4 14             	add    $0x14,%esp
  800298:	0f be 80 bb 10 80 00 	movsbl 0x8010bb(%eax),%eax
  80029f:	50                   	push   %eax
  8002a0:	ff 55 e4             	call   *-0x1c(%ebp)
  8002a3:	83 c4 10             	add    $0x10,%esp
}
  8002a6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002a9:	5b                   	pop    %ebx
  8002aa:	5e                   	pop    %esi
  8002ab:	5f                   	pop    %edi
  8002ac:	c9                   	leave  
  8002ad:	c3                   	ret    

008002ae <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002ae:	55                   	push   %ebp
  8002af:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002b1:	83 fa 01             	cmp    $0x1,%edx
  8002b4:	7e 0e                	jle    8002c4 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8002b6:	8b 10                	mov    (%eax),%edx
  8002b8:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002bb:	89 08                	mov    %ecx,(%eax)
  8002bd:	8b 02                	mov    (%edx),%eax
  8002bf:	8b 52 04             	mov    0x4(%edx),%edx
  8002c2:	eb 22                	jmp    8002e6 <getuint+0x38>
	else if (lflag)
  8002c4:	85 d2                	test   %edx,%edx
  8002c6:	74 10                	je     8002d8 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8002c8:	8b 10                	mov    (%eax),%edx
  8002ca:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002cd:	89 08                	mov    %ecx,(%eax)
  8002cf:	8b 02                	mov    (%edx),%eax
  8002d1:	ba 00 00 00 00       	mov    $0x0,%edx
  8002d6:	eb 0e                	jmp    8002e6 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8002d8:	8b 10                	mov    (%eax),%edx
  8002da:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002dd:	89 08                	mov    %ecx,(%eax)
  8002df:	8b 02                	mov    (%edx),%eax
  8002e1:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002e6:	c9                   	leave  
  8002e7:	c3                   	ret    

008002e8 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  8002e8:	55                   	push   %ebp
  8002e9:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002eb:	83 fa 01             	cmp    $0x1,%edx
  8002ee:	7e 0e                	jle    8002fe <getint+0x16>
		return va_arg(*ap, long long);
  8002f0:	8b 10                	mov    (%eax),%edx
  8002f2:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002f5:	89 08                	mov    %ecx,(%eax)
  8002f7:	8b 02                	mov    (%edx),%eax
  8002f9:	8b 52 04             	mov    0x4(%edx),%edx
  8002fc:	eb 1a                	jmp    800318 <getint+0x30>
	else if (lflag)
  8002fe:	85 d2                	test   %edx,%edx
  800300:	74 0c                	je     80030e <getint+0x26>
		return va_arg(*ap, long);
  800302:	8b 10                	mov    (%eax),%edx
  800304:	8d 4a 04             	lea    0x4(%edx),%ecx
  800307:	89 08                	mov    %ecx,(%eax)
  800309:	8b 02                	mov    (%edx),%eax
  80030b:	99                   	cltd   
  80030c:	eb 0a                	jmp    800318 <getint+0x30>
	else
		return va_arg(*ap, int);
  80030e:	8b 10                	mov    (%eax),%edx
  800310:	8d 4a 04             	lea    0x4(%edx),%ecx
  800313:	89 08                	mov    %ecx,(%eax)
  800315:	8b 02                	mov    (%edx),%eax
  800317:	99                   	cltd   
}
  800318:	c9                   	leave  
  800319:	c3                   	ret    

0080031a <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80031a:	55                   	push   %ebp
  80031b:	89 e5                	mov    %esp,%ebp
  80031d:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800320:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  800323:	8b 10                	mov    (%eax),%edx
  800325:	3b 50 04             	cmp    0x4(%eax),%edx
  800328:	73 08                	jae    800332 <sprintputch+0x18>
		*b->buf++ = ch;
  80032a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80032d:	88 0a                	mov    %cl,(%edx)
  80032f:	42                   	inc    %edx
  800330:	89 10                	mov    %edx,(%eax)
}
  800332:	c9                   	leave  
  800333:	c3                   	ret    

00800334 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800334:	55                   	push   %ebp
  800335:	89 e5                	mov    %esp,%ebp
  800337:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80033a:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80033d:	50                   	push   %eax
  80033e:	ff 75 10             	pushl  0x10(%ebp)
  800341:	ff 75 0c             	pushl  0xc(%ebp)
  800344:	ff 75 08             	pushl  0x8(%ebp)
  800347:	e8 05 00 00 00       	call   800351 <vprintfmt>
	va_end(ap);
  80034c:	83 c4 10             	add    $0x10,%esp
}
  80034f:	c9                   	leave  
  800350:	c3                   	ret    

00800351 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800351:	55                   	push   %ebp
  800352:	89 e5                	mov    %esp,%ebp
  800354:	57                   	push   %edi
  800355:	56                   	push   %esi
  800356:	53                   	push   %ebx
  800357:	83 ec 2c             	sub    $0x2c,%esp
  80035a:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80035d:	8b 75 10             	mov    0x10(%ebp),%esi
  800360:	eb 13                	jmp    800375 <vprintfmt+0x24>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800362:	85 c0                	test   %eax,%eax
  800364:	0f 84 6d 03 00 00    	je     8006d7 <vprintfmt+0x386>
				return;
			putch(ch, putdat);
  80036a:	83 ec 08             	sub    $0x8,%esp
  80036d:	57                   	push   %edi
  80036e:	50                   	push   %eax
  80036f:	ff 55 08             	call   *0x8(%ebp)
  800372:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800375:	0f b6 06             	movzbl (%esi),%eax
  800378:	46                   	inc    %esi
  800379:	83 f8 25             	cmp    $0x25,%eax
  80037c:	75 e4                	jne    800362 <vprintfmt+0x11>
  80037e:	c6 45 dc 20          	movb   $0x20,-0x24(%ebp)
  800382:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  800389:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  800390:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800397:	b9 00 00 00 00       	mov    $0x0,%ecx
  80039c:	eb 28                	jmp    8003c6 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80039e:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  8003a0:	c6 45 dc 2d          	movb   $0x2d,-0x24(%ebp)
  8003a4:	eb 20                	jmp    8003c6 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003a6:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8003a8:	c6 45 dc 30          	movb   $0x30,-0x24(%ebp)
  8003ac:	eb 18                	jmp    8003c6 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ae:	89 de                	mov    %ebx,%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  8003b0:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8003b7:	eb 0d                	jmp    8003c6 <vprintfmt+0x75>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  8003b9:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8003bc:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003bf:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003c6:	8a 06                	mov    (%esi),%al
  8003c8:	0f b6 d0             	movzbl %al,%edx
  8003cb:	8d 5e 01             	lea    0x1(%esi),%ebx
  8003ce:	83 e8 23             	sub    $0x23,%eax
  8003d1:	3c 55                	cmp    $0x55,%al
  8003d3:	0f 87 e0 02 00 00    	ja     8006b9 <vprintfmt+0x368>
  8003d9:	0f b6 c0             	movzbl %al,%eax
  8003dc:	ff 24 85 80 11 80 00 	jmp    *0x801180(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003e3:	83 ea 30             	sub    $0x30,%edx
  8003e6:	89 55 d4             	mov    %edx,-0x2c(%ebp)
				ch = *fmt;
  8003e9:	0f be 03             	movsbl (%ebx),%eax
				if (ch < '0' || ch > '9')
  8003ec:	8d 50 d0             	lea    -0x30(%eax),%edx
  8003ef:	83 fa 09             	cmp    $0x9,%edx
  8003f2:	77 44                	ja     800438 <vprintfmt+0xe7>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003f4:	89 de                	mov    %ebx,%esi
  8003f6:	8b 55 d4             	mov    -0x2c(%ebp),%edx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003f9:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
  8003fa:	8d 14 92             	lea    (%edx,%edx,4),%edx
  8003fd:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
  800401:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800404:	8d 58 d0             	lea    -0x30(%eax),%ebx
  800407:	83 fb 09             	cmp    $0x9,%ebx
  80040a:	76 ed                	jbe    8003f9 <vprintfmt+0xa8>
  80040c:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  80040f:	eb 29                	jmp    80043a <vprintfmt+0xe9>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800411:	8b 45 14             	mov    0x14(%ebp),%eax
  800414:	8d 50 04             	lea    0x4(%eax),%edx
  800417:	89 55 14             	mov    %edx,0x14(%ebp)
  80041a:	8b 00                	mov    (%eax),%eax
  80041c:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80041f:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800421:	eb 17                	jmp    80043a <vprintfmt+0xe9>

		case '.':
			if (width < 0)
  800423:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800427:	78 85                	js     8003ae <vprintfmt+0x5d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800429:	89 de                	mov    %ebx,%esi
  80042b:	eb 99                	jmp    8003c6 <vprintfmt+0x75>
  80042d:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80042f:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  800436:	eb 8e                	jmp    8003c6 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800438:	89 de                	mov    %ebx,%esi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  80043a:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80043e:	79 86                	jns    8003c6 <vprintfmt+0x75>
  800440:	e9 74 ff ff ff       	jmp    8003b9 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800445:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800446:	89 de                	mov    %ebx,%esi
  800448:	e9 79 ff ff ff       	jmp    8003c6 <vprintfmt+0x75>
  80044d:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800450:	8b 45 14             	mov    0x14(%ebp),%eax
  800453:	8d 50 04             	lea    0x4(%eax),%edx
  800456:	89 55 14             	mov    %edx,0x14(%ebp)
  800459:	83 ec 08             	sub    $0x8,%esp
  80045c:	57                   	push   %edi
  80045d:	ff 30                	pushl  (%eax)
  80045f:	ff 55 08             	call   *0x8(%ebp)
			break;
  800462:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800465:	8b 75 d8             	mov    -0x28(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800468:	e9 08 ff ff ff       	jmp    800375 <vprintfmt+0x24>
  80046d:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  800470:	8b 45 14             	mov    0x14(%ebp),%eax
  800473:	8d 50 04             	lea    0x4(%eax),%edx
  800476:	89 55 14             	mov    %edx,0x14(%ebp)
  800479:	8b 00                	mov    (%eax),%eax
  80047b:	85 c0                	test   %eax,%eax
  80047d:	79 02                	jns    800481 <vprintfmt+0x130>
  80047f:	f7 d8                	neg    %eax
  800481:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800483:	83 f8 08             	cmp    $0x8,%eax
  800486:	7f 0b                	jg     800493 <vprintfmt+0x142>
  800488:	8b 04 85 e0 12 80 00 	mov    0x8012e0(,%eax,4),%eax
  80048f:	85 c0                	test   %eax,%eax
  800491:	75 1a                	jne    8004ad <vprintfmt+0x15c>
				printfmt(putch, putdat, "error %d", err);
  800493:	52                   	push   %edx
  800494:	68 d3 10 80 00       	push   $0x8010d3
  800499:	57                   	push   %edi
  80049a:	ff 75 08             	pushl  0x8(%ebp)
  80049d:	e8 92 fe ff ff       	call   800334 <printfmt>
  8004a2:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004a5:	8b 75 d8             	mov    -0x28(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8004a8:	e9 c8 fe ff ff       	jmp    800375 <vprintfmt+0x24>
			else
				printfmt(putch, putdat, "%s", p);
  8004ad:	50                   	push   %eax
  8004ae:	68 dc 10 80 00       	push   $0x8010dc
  8004b3:	57                   	push   %edi
  8004b4:	ff 75 08             	pushl  0x8(%ebp)
  8004b7:	e8 78 fe ff ff       	call   800334 <printfmt>
  8004bc:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004bf:	8b 75 d8             	mov    -0x28(%ebp),%esi
  8004c2:	e9 ae fe ff ff       	jmp    800375 <vprintfmt+0x24>
  8004c7:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  8004ca:	89 de                	mov    %ebx,%esi
  8004cc:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  8004cf:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004d2:	8b 45 14             	mov    0x14(%ebp),%eax
  8004d5:	8d 50 04             	lea    0x4(%eax),%edx
  8004d8:	89 55 14             	mov    %edx,0x14(%ebp)
  8004db:	8b 00                	mov    (%eax),%eax
  8004dd:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8004e0:	85 c0                	test   %eax,%eax
  8004e2:	75 07                	jne    8004eb <vprintfmt+0x19a>
				p = "(null)";
  8004e4:	c7 45 d0 cc 10 80 00 	movl   $0x8010cc,-0x30(%ebp)
			if (width > 0 && padc != '-')
  8004eb:	85 db                	test   %ebx,%ebx
  8004ed:	7e 42                	jle    800531 <vprintfmt+0x1e0>
  8004ef:	80 7d dc 2d          	cmpb   $0x2d,-0x24(%ebp)
  8004f3:	74 3c                	je     800531 <vprintfmt+0x1e0>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004f5:	83 ec 08             	sub    $0x8,%esp
  8004f8:	51                   	push   %ecx
  8004f9:	ff 75 d0             	pushl  -0x30(%ebp)
  8004fc:	e8 6f 02 00 00       	call   800770 <strnlen>
  800501:	29 c3                	sub    %eax,%ebx
  800503:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800506:	83 c4 10             	add    $0x10,%esp
  800509:	85 db                	test   %ebx,%ebx
  80050b:	7e 24                	jle    800531 <vprintfmt+0x1e0>
					putch(padc, putdat);
  80050d:	0f be 5d dc          	movsbl -0x24(%ebp),%ebx
  800511:	89 75 dc             	mov    %esi,-0x24(%ebp)
  800514:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  800517:	83 ec 08             	sub    $0x8,%esp
  80051a:	57                   	push   %edi
  80051b:	53                   	push   %ebx
  80051c:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80051f:	4e                   	dec    %esi
  800520:	83 c4 10             	add    $0x10,%esp
  800523:	85 f6                	test   %esi,%esi
  800525:	7f f0                	jg     800517 <vprintfmt+0x1c6>
  800527:	8b 75 dc             	mov    -0x24(%ebp),%esi
  80052a:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800531:	8b 55 d0             	mov    -0x30(%ebp),%edx
  800534:	0f be 02             	movsbl (%edx),%eax
  800537:	85 c0                	test   %eax,%eax
  800539:	75 47                	jne    800582 <vprintfmt+0x231>
  80053b:	eb 37                	jmp    800574 <vprintfmt+0x223>
				if (altflag && (ch < ' ' || ch > '~'))
  80053d:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800541:	74 16                	je     800559 <vprintfmt+0x208>
  800543:	8d 50 e0             	lea    -0x20(%eax),%edx
  800546:	83 fa 5e             	cmp    $0x5e,%edx
  800549:	76 0e                	jbe    800559 <vprintfmt+0x208>
					putch('?', putdat);
  80054b:	83 ec 08             	sub    $0x8,%esp
  80054e:	57                   	push   %edi
  80054f:	6a 3f                	push   $0x3f
  800551:	ff 55 08             	call   *0x8(%ebp)
  800554:	83 c4 10             	add    $0x10,%esp
  800557:	eb 0b                	jmp    800564 <vprintfmt+0x213>
				else
					putch(ch, putdat);
  800559:	83 ec 08             	sub    $0x8,%esp
  80055c:	57                   	push   %edi
  80055d:	50                   	push   %eax
  80055e:	ff 55 08             	call   *0x8(%ebp)
  800561:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800564:	ff 4d e4             	decl   -0x1c(%ebp)
  800567:	0f be 03             	movsbl (%ebx),%eax
  80056a:	85 c0                	test   %eax,%eax
  80056c:	74 03                	je     800571 <vprintfmt+0x220>
  80056e:	43                   	inc    %ebx
  80056f:	eb 1b                	jmp    80058c <vprintfmt+0x23b>
  800571:	8b 75 dc             	mov    -0x24(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800574:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800578:	7f 1e                	jg     800598 <vprintfmt+0x247>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80057a:	8b 75 d8             	mov    -0x28(%ebp),%esi
  80057d:	e9 f3 fd ff ff       	jmp    800375 <vprintfmt+0x24>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800582:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800585:	43                   	inc    %ebx
  800586:	89 75 dc             	mov    %esi,-0x24(%ebp)
  800589:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  80058c:	85 f6                	test   %esi,%esi
  80058e:	78 ad                	js     80053d <vprintfmt+0x1ec>
  800590:	4e                   	dec    %esi
  800591:	79 aa                	jns    80053d <vprintfmt+0x1ec>
  800593:	8b 75 dc             	mov    -0x24(%ebp),%esi
  800596:	eb dc                	jmp    800574 <vprintfmt+0x223>
  800598:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80059b:	83 ec 08             	sub    $0x8,%esp
  80059e:	57                   	push   %edi
  80059f:	6a 20                	push   $0x20
  8005a1:	ff 55 08             	call   *0x8(%ebp)
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005a4:	4b                   	dec    %ebx
  8005a5:	83 c4 10             	add    $0x10,%esp
  8005a8:	85 db                	test   %ebx,%ebx
  8005aa:	7f ef                	jg     80059b <vprintfmt+0x24a>
  8005ac:	e9 c4 fd ff ff       	jmp    800375 <vprintfmt+0x24>
  8005b1:	89 5d d8             	mov    %ebx,-0x28(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8005b4:	89 ca                	mov    %ecx,%edx
  8005b6:	8d 45 14             	lea    0x14(%ebp),%eax
  8005b9:	e8 2a fd ff ff       	call   8002e8 <getint>
  8005be:	89 c3                	mov    %eax,%ebx
  8005c0:	89 d6                	mov    %edx,%esi
			if ((long long) num < 0) {
  8005c2:	85 d2                	test   %edx,%edx
  8005c4:	78 0a                	js     8005d0 <vprintfmt+0x27f>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8005c6:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005cb:	e9 b0 00 00 00       	jmp    800680 <vprintfmt+0x32f>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  8005d0:	83 ec 08             	sub    $0x8,%esp
  8005d3:	57                   	push   %edi
  8005d4:	6a 2d                	push   $0x2d
  8005d6:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8005d9:	f7 db                	neg    %ebx
  8005db:	83 d6 00             	adc    $0x0,%esi
  8005de:	f7 de                	neg    %esi
  8005e0:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8005e3:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005e8:	e9 93 00 00 00       	jmp    800680 <vprintfmt+0x32f>
  8005ed:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8005f0:	89 ca                	mov    %ecx,%edx
  8005f2:	8d 45 14             	lea    0x14(%ebp),%eax
  8005f5:	e8 b4 fc ff ff       	call   8002ae <getuint>
  8005fa:	89 c3                	mov    %eax,%ebx
  8005fc:	89 d6                	mov    %edx,%esi
			base = 10;
  8005fe:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  800603:	eb 7b                	jmp    800680 <vprintfmt+0x32f>
  800605:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
  800608:	89 ca                	mov    %ecx,%edx
  80060a:	8d 45 14             	lea    0x14(%ebp),%eax
  80060d:	e8 d6 fc ff ff       	call   8002e8 <getint>
  800612:	89 c3                	mov    %eax,%ebx
  800614:	89 d6                	mov    %edx,%esi
            if ((long long) num < 0) {
  800616:	85 d2                	test   %edx,%edx
  800618:	78 07                	js     800621 <vprintfmt+0x2d0>
                putch('-', putdat);
                num = -(long long) num;
            }
            base = 8;
  80061a:	b8 08 00 00 00       	mov    $0x8,%eax
  80061f:	eb 5f                	jmp    800680 <vprintfmt+0x32f>
		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
            if ((long long) num < 0) {
                putch('-', putdat);
  800621:	83 ec 08             	sub    $0x8,%esp
  800624:	57                   	push   %edi
  800625:	6a 2d                	push   $0x2d
  800627:	ff 55 08             	call   *0x8(%ebp)
                num = -(long long) num;
  80062a:	f7 db                	neg    %ebx
  80062c:	83 d6 00             	adc    $0x0,%esi
  80062f:	f7 de                	neg    %esi
  800631:	83 c4 10             	add    $0x10,%esp
            }
            base = 8;
  800634:	b8 08 00 00 00       	mov    $0x8,%eax
  800639:	eb 45                	jmp    800680 <vprintfmt+0x32f>
  80063b:	89 5d d8             	mov    %ebx,-0x28(%ebp)
            goto number;

        // pointer
		case 'p':
			putch('0', putdat);
  80063e:	83 ec 08             	sub    $0x8,%esp
  800641:	57                   	push   %edi
  800642:	6a 30                	push   $0x30
  800644:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800647:	83 c4 08             	add    $0x8,%esp
  80064a:	57                   	push   %edi
  80064b:	6a 78                	push   $0x78
  80064d:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800650:	8b 45 14             	mov    0x14(%ebp),%eax
  800653:	8d 50 04             	lea    0x4(%eax),%edx
  800656:	89 55 14             	mov    %edx,0x14(%ebp)

        // pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800659:	8b 18                	mov    (%eax),%ebx
  80065b:	be 00 00 00 00       	mov    $0x0,%esi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800660:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800663:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800668:	eb 16                	jmp    800680 <vprintfmt+0x32f>
  80066a:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80066d:	89 ca                	mov    %ecx,%edx
  80066f:	8d 45 14             	lea    0x14(%ebp),%eax
  800672:	e8 37 fc ff ff       	call   8002ae <getuint>
  800677:	89 c3                	mov    %eax,%ebx
  800679:	89 d6                	mov    %edx,%esi
			base = 16;
  80067b:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800680:	83 ec 0c             	sub    $0xc,%esp
  800683:	0f be 55 dc          	movsbl -0x24(%ebp),%edx
  800687:	52                   	push   %edx
  800688:	ff 75 e4             	pushl  -0x1c(%ebp)
  80068b:	50                   	push   %eax
  80068c:	56                   	push   %esi
  80068d:	53                   	push   %ebx
  80068e:	89 fa                	mov    %edi,%edx
  800690:	8b 45 08             	mov    0x8(%ebp),%eax
  800693:	e8 68 fb ff ff       	call   800200 <printnum>
			break;
  800698:	83 c4 20             	add    $0x20,%esp
  80069b:	8b 75 d8             	mov    -0x28(%ebp),%esi
  80069e:	e9 d2 fc ff ff       	jmp    800375 <vprintfmt+0x24>
  8006a3:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006a6:	83 ec 08             	sub    $0x8,%esp
  8006a9:	57                   	push   %edi
  8006aa:	52                   	push   %edx
  8006ab:	ff 55 08             	call   *0x8(%ebp)
			break;
  8006ae:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006b1:	8b 75 d8             	mov    -0x28(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8006b4:	e9 bc fc ff ff       	jmp    800375 <vprintfmt+0x24>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8006b9:	83 ec 08             	sub    $0x8,%esp
  8006bc:	57                   	push   %edi
  8006bd:	6a 25                	push   $0x25
  8006bf:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006c2:	83 c4 10             	add    $0x10,%esp
  8006c5:	eb 02                	jmp    8006c9 <vprintfmt+0x378>
  8006c7:	89 c6                	mov    %eax,%esi
  8006c9:	8d 46 ff             	lea    -0x1(%esi),%eax
  8006cc:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  8006d0:	75 f5                	jne    8006c7 <vprintfmt+0x376>
  8006d2:	e9 9e fc ff ff       	jmp    800375 <vprintfmt+0x24>
				/* do nothing */;
			break;
		}
	}
}
  8006d7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006da:	5b                   	pop    %ebx
  8006db:	5e                   	pop    %esi
  8006dc:	5f                   	pop    %edi
  8006dd:	c9                   	leave  
  8006de:	c3                   	ret    

008006df <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006df:	55                   	push   %ebp
  8006e0:	89 e5                	mov    %esp,%ebp
  8006e2:	83 ec 18             	sub    $0x18,%esp
  8006e5:	8b 45 08             	mov    0x8(%ebp),%eax
  8006e8:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006eb:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006ee:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8006f2:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8006f5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8006fc:	85 c0                	test   %eax,%eax
  8006fe:	74 26                	je     800726 <vsnprintf+0x47>
  800700:	85 d2                	test   %edx,%edx
  800702:	7e 29                	jle    80072d <vsnprintf+0x4e>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800704:	ff 75 14             	pushl  0x14(%ebp)
  800707:	ff 75 10             	pushl  0x10(%ebp)
  80070a:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80070d:	50                   	push   %eax
  80070e:	68 1a 03 80 00       	push   $0x80031a
  800713:	e8 39 fc ff ff       	call   800351 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800718:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80071b:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80071e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800721:	83 c4 10             	add    $0x10,%esp
  800724:	eb 0c                	jmp    800732 <vsnprintf+0x53>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800726:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80072b:	eb 05                	jmp    800732 <vsnprintf+0x53>
  80072d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800732:	c9                   	leave  
  800733:	c3                   	ret    

00800734 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800734:	55                   	push   %ebp
  800735:	89 e5                	mov    %esp,%ebp
  800737:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80073a:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80073d:	50                   	push   %eax
  80073e:	ff 75 10             	pushl  0x10(%ebp)
  800741:	ff 75 0c             	pushl  0xc(%ebp)
  800744:	ff 75 08             	pushl  0x8(%ebp)
  800747:	e8 93 ff ff ff       	call   8006df <vsnprintf>
	va_end(ap);

	return rc;
}
  80074c:	c9                   	leave  
  80074d:	c3                   	ret    
	...

00800750 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800750:	55                   	push   %ebp
  800751:	89 e5                	mov    %esp,%ebp
  800753:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800756:	80 3a 00             	cmpb   $0x0,(%edx)
  800759:	74 0e                	je     800769 <strlen+0x19>
  80075b:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800760:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800761:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800765:	75 f9                	jne    800760 <strlen+0x10>
  800767:	eb 05                	jmp    80076e <strlen+0x1e>
  800769:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  80076e:	c9                   	leave  
  80076f:	c3                   	ret    

00800770 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800770:	55                   	push   %ebp
  800771:	89 e5                	mov    %esp,%ebp
  800773:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800776:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800779:	85 d2                	test   %edx,%edx
  80077b:	74 17                	je     800794 <strnlen+0x24>
  80077d:	80 39 00             	cmpb   $0x0,(%ecx)
  800780:	74 19                	je     80079b <strnlen+0x2b>
  800782:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800787:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800788:	39 d0                	cmp    %edx,%eax
  80078a:	74 14                	je     8007a0 <strnlen+0x30>
  80078c:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800790:	75 f5                	jne    800787 <strnlen+0x17>
  800792:	eb 0c                	jmp    8007a0 <strnlen+0x30>
  800794:	b8 00 00 00 00       	mov    $0x0,%eax
  800799:	eb 05                	jmp    8007a0 <strnlen+0x30>
  80079b:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  8007a0:	c9                   	leave  
  8007a1:	c3                   	ret    

008007a2 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007a2:	55                   	push   %ebp
  8007a3:	89 e5                	mov    %esp,%ebp
  8007a5:	53                   	push   %ebx
  8007a6:	8b 45 08             	mov    0x8(%ebp),%eax
  8007a9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007ac:	ba 00 00 00 00       	mov    $0x0,%edx
  8007b1:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  8007b4:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  8007b7:	42                   	inc    %edx
  8007b8:	84 c9                	test   %cl,%cl
  8007ba:	75 f5                	jne    8007b1 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8007bc:	5b                   	pop    %ebx
  8007bd:	c9                   	leave  
  8007be:	c3                   	ret    

008007bf <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007bf:	55                   	push   %ebp
  8007c0:	89 e5                	mov    %esp,%ebp
  8007c2:	53                   	push   %ebx
  8007c3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007c6:	53                   	push   %ebx
  8007c7:	e8 84 ff ff ff       	call   800750 <strlen>
  8007cc:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8007cf:	ff 75 0c             	pushl  0xc(%ebp)
  8007d2:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  8007d5:	50                   	push   %eax
  8007d6:	e8 c7 ff ff ff       	call   8007a2 <strcpy>
	return dst;
}
  8007db:	89 d8                	mov    %ebx,%eax
  8007dd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007e0:	c9                   	leave  
  8007e1:	c3                   	ret    

008007e2 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007e2:	55                   	push   %ebp
  8007e3:	89 e5                	mov    %esp,%ebp
  8007e5:	56                   	push   %esi
  8007e6:	53                   	push   %ebx
  8007e7:	8b 45 08             	mov    0x8(%ebp),%eax
  8007ea:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007ed:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007f0:	85 f6                	test   %esi,%esi
  8007f2:	74 15                	je     800809 <strncpy+0x27>
  8007f4:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  8007f9:	8a 1a                	mov    (%edx),%bl
  8007fb:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007fe:	80 3a 01             	cmpb   $0x1,(%edx)
  800801:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800804:	41                   	inc    %ecx
  800805:	39 ce                	cmp    %ecx,%esi
  800807:	77 f0                	ja     8007f9 <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800809:	5b                   	pop    %ebx
  80080a:	5e                   	pop    %esi
  80080b:	c9                   	leave  
  80080c:	c3                   	ret    

0080080d <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80080d:	55                   	push   %ebp
  80080e:	89 e5                	mov    %esp,%ebp
  800810:	57                   	push   %edi
  800811:	56                   	push   %esi
  800812:	53                   	push   %ebx
  800813:	8b 7d 08             	mov    0x8(%ebp),%edi
  800816:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800819:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80081c:	85 f6                	test   %esi,%esi
  80081e:	74 32                	je     800852 <strlcpy+0x45>
		while (--size > 0 && *src != '\0')
  800820:	83 fe 01             	cmp    $0x1,%esi
  800823:	74 22                	je     800847 <strlcpy+0x3a>
  800825:	8a 0b                	mov    (%ebx),%cl
  800827:	84 c9                	test   %cl,%cl
  800829:	74 20                	je     80084b <strlcpy+0x3e>
  80082b:	89 f8                	mov    %edi,%eax
  80082d:	ba 00 00 00 00       	mov    $0x0,%edx
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
  800832:	83 ee 02             	sub    $0x2,%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800835:	88 08                	mov    %cl,(%eax)
  800837:	40                   	inc    %eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800838:	39 f2                	cmp    %esi,%edx
  80083a:	74 11                	je     80084d <strlcpy+0x40>
  80083c:	8a 4c 13 01          	mov    0x1(%ebx,%edx,1),%cl
  800840:	42                   	inc    %edx
  800841:	84 c9                	test   %cl,%cl
  800843:	75 f0                	jne    800835 <strlcpy+0x28>
  800845:	eb 06                	jmp    80084d <strlcpy+0x40>
  800847:	89 f8                	mov    %edi,%eax
  800849:	eb 02                	jmp    80084d <strlcpy+0x40>
  80084b:	89 f8                	mov    %edi,%eax
			*dst++ = *src++;
		*dst = '\0';
  80084d:	c6 00 00             	movb   $0x0,(%eax)
  800850:	eb 02                	jmp    800854 <strlcpy+0x47>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800852:	89 f8                	mov    %edi,%eax
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
		*dst = '\0';
	}
	return dst - dst_in;
  800854:	29 f8                	sub    %edi,%eax
}
  800856:	5b                   	pop    %ebx
  800857:	5e                   	pop    %esi
  800858:	5f                   	pop    %edi
  800859:	c9                   	leave  
  80085a:	c3                   	ret    

0080085b <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80085b:	55                   	push   %ebp
  80085c:	89 e5                	mov    %esp,%ebp
  80085e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800861:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800864:	8a 01                	mov    (%ecx),%al
  800866:	84 c0                	test   %al,%al
  800868:	74 10                	je     80087a <strcmp+0x1f>
  80086a:	3a 02                	cmp    (%edx),%al
  80086c:	75 0c                	jne    80087a <strcmp+0x1f>
		p++, q++;
  80086e:	41                   	inc    %ecx
  80086f:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800870:	8a 01                	mov    (%ecx),%al
  800872:	84 c0                	test   %al,%al
  800874:	74 04                	je     80087a <strcmp+0x1f>
  800876:	3a 02                	cmp    (%edx),%al
  800878:	74 f4                	je     80086e <strcmp+0x13>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80087a:	0f b6 c0             	movzbl %al,%eax
  80087d:	0f b6 12             	movzbl (%edx),%edx
  800880:	29 d0                	sub    %edx,%eax
}
  800882:	c9                   	leave  
  800883:	c3                   	ret    

00800884 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800884:	55                   	push   %ebp
  800885:	89 e5                	mov    %esp,%ebp
  800887:	53                   	push   %ebx
  800888:	8b 55 08             	mov    0x8(%ebp),%edx
  80088b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80088e:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  800891:	85 c0                	test   %eax,%eax
  800893:	74 1b                	je     8008b0 <strncmp+0x2c>
  800895:	8a 1a                	mov    (%edx),%bl
  800897:	84 db                	test   %bl,%bl
  800899:	74 24                	je     8008bf <strncmp+0x3b>
  80089b:	3a 19                	cmp    (%ecx),%bl
  80089d:	75 20                	jne    8008bf <strncmp+0x3b>
  80089f:	48                   	dec    %eax
  8008a0:	74 15                	je     8008b7 <strncmp+0x33>
		n--, p++, q++;
  8008a2:	42                   	inc    %edx
  8008a3:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8008a4:	8a 1a                	mov    (%edx),%bl
  8008a6:	84 db                	test   %bl,%bl
  8008a8:	74 15                	je     8008bf <strncmp+0x3b>
  8008aa:	3a 19                	cmp    (%ecx),%bl
  8008ac:	74 f1                	je     80089f <strncmp+0x1b>
  8008ae:	eb 0f                	jmp    8008bf <strncmp+0x3b>
		n--, p++, q++;
	if (n == 0)
		return 0;
  8008b0:	b8 00 00 00 00       	mov    $0x0,%eax
  8008b5:	eb 05                	jmp    8008bc <strncmp+0x38>
  8008b7:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8008bc:	5b                   	pop    %ebx
  8008bd:	c9                   	leave  
  8008be:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008bf:	0f b6 02             	movzbl (%edx),%eax
  8008c2:	0f b6 11             	movzbl (%ecx),%edx
  8008c5:	29 d0                	sub    %edx,%eax
  8008c7:	eb f3                	jmp    8008bc <strncmp+0x38>

008008c9 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008c9:	55                   	push   %ebp
  8008ca:	89 e5                	mov    %esp,%ebp
  8008cc:	8b 45 08             	mov    0x8(%ebp),%eax
  8008cf:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8008d2:	8a 10                	mov    (%eax),%dl
  8008d4:	84 d2                	test   %dl,%dl
  8008d6:	74 18                	je     8008f0 <strchr+0x27>
		if (*s == c)
  8008d8:	38 ca                	cmp    %cl,%dl
  8008da:	75 06                	jne    8008e2 <strchr+0x19>
  8008dc:	eb 17                	jmp    8008f5 <strchr+0x2c>
  8008de:	38 ca                	cmp    %cl,%dl
  8008e0:	74 13                	je     8008f5 <strchr+0x2c>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8008e2:	40                   	inc    %eax
  8008e3:	8a 10                	mov    (%eax),%dl
  8008e5:	84 d2                	test   %dl,%dl
  8008e7:	75 f5                	jne    8008de <strchr+0x15>
		if (*s == c)
			return (char *) s;
	return 0;
  8008e9:	b8 00 00 00 00       	mov    $0x0,%eax
  8008ee:	eb 05                	jmp    8008f5 <strchr+0x2c>
  8008f0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008f5:	c9                   	leave  
  8008f6:	c3                   	ret    

008008f7 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008f7:	55                   	push   %ebp
  8008f8:	89 e5                	mov    %esp,%ebp
  8008fa:	8b 45 08             	mov    0x8(%ebp),%eax
  8008fd:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800900:	8a 10                	mov    (%eax),%dl
  800902:	84 d2                	test   %dl,%dl
  800904:	74 11                	je     800917 <strfind+0x20>
		if (*s == c)
  800906:	38 ca                	cmp    %cl,%dl
  800908:	75 06                	jne    800910 <strfind+0x19>
  80090a:	eb 0b                	jmp    800917 <strfind+0x20>
  80090c:	38 ca                	cmp    %cl,%dl
  80090e:	74 07                	je     800917 <strfind+0x20>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800910:	40                   	inc    %eax
  800911:	8a 10                	mov    (%eax),%dl
  800913:	84 d2                	test   %dl,%dl
  800915:	75 f5                	jne    80090c <strfind+0x15>
		if (*s == c)
			break;
	return (char *) s;
}
  800917:	c9                   	leave  
  800918:	c3                   	ret    

00800919 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800919:	55                   	push   %ebp
  80091a:	89 e5                	mov    %esp,%ebp
  80091c:	57                   	push   %edi
  80091d:	56                   	push   %esi
  80091e:	53                   	push   %ebx
  80091f:	8b 7d 08             	mov    0x8(%ebp),%edi
  800922:	8b 45 0c             	mov    0xc(%ebp),%eax
  800925:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800928:	85 c9                	test   %ecx,%ecx
  80092a:	74 30                	je     80095c <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80092c:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800932:	75 25                	jne    800959 <memset+0x40>
  800934:	f6 c1 03             	test   $0x3,%cl
  800937:	75 20                	jne    800959 <memset+0x40>
		c &= 0xFF;
  800939:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80093c:	89 d3                	mov    %edx,%ebx
  80093e:	c1 e3 08             	shl    $0x8,%ebx
  800941:	89 d6                	mov    %edx,%esi
  800943:	c1 e6 18             	shl    $0x18,%esi
  800946:	89 d0                	mov    %edx,%eax
  800948:	c1 e0 10             	shl    $0x10,%eax
  80094b:	09 f0                	or     %esi,%eax
  80094d:	09 d0                	or     %edx,%eax
  80094f:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800951:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800954:	fc                   	cld    
  800955:	f3 ab                	rep stos %eax,%es:(%edi)
  800957:	eb 03                	jmp    80095c <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800959:	fc                   	cld    
  80095a:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80095c:	89 f8                	mov    %edi,%eax
  80095e:	5b                   	pop    %ebx
  80095f:	5e                   	pop    %esi
  800960:	5f                   	pop    %edi
  800961:	c9                   	leave  
  800962:	c3                   	ret    

00800963 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800963:	55                   	push   %ebp
  800964:	89 e5                	mov    %esp,%ebp
  800966:	57                   	push   %edi
  800967:	56                   	push   %esi
  800968:	8b 45 08             	mov    0x8(%ebp),%eax
  80096b:	8b 75 0c             	mov    0xc(%ebp),%esi
  80096e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800971:	39 c6                	cmp    %eax,%esi
  800973:	73 34                	jae    8009a9 <memmove+0x46>
  800975:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800978:	39 d0                	cmp    %edx,%eax
  80097a:	73 2d                	jae    8009a9 <memmove+0x46>
		s += n;
		d += n;
  80097c:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80097f:	f6 c2 03             	test   $0x3,%dl
  800982:	75 1b                	jne    80099f <memmove+0x3c>
  800984:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80098a:	75 13                	jne    80099f <memmove+0x3c>
  80098c:	f6 c1 03             	test   $0x3,%cl
  80098f:	75 0e                	jne    80099f <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800991:	83 ef 04             	sub    $0x4,%edi
  800994:	8d 72 fc             	lea    -0x4(%edx),%esi
  800997:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  80099a:	fd                   	std    
  80099b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80099d:	eb 07                	jmp    8009a6 <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  80099f:	4f                   	dec    %edi
  8009a0:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8009a3:	fd                   	std    
  8009a4:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009a6:	fc                   	cld    
  8009a7:	eb 20                	jmp    8009c9 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009a9:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009af:	75 13                	jne    8009c4 <memmove+0x61>
  8009b1:	a8 03                	test   $0x3,%al
  8009b3:	75 0f                	jne    8009c4 <memmove+0x61>
  8009b5:	f6 c1 03             	test   $0x3,%cl
  8009b8:	75 0a                	jne    8009c4 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8009ba:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  8009bd:	89 c7                	mov    %eax,%edi
  8009bf:	fc                   	cld    
  8009c0:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009c2:	eb 05                	jmp    8009c9 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8009c4:	89 c7                	mov    %eax,%edi
  8009c6:	fc                   	cld    
  8009c7:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009c9:	5e                   	pop    %esi
  8009ca:	5f                   	pop    %edi
  8009cb:	c9                   	leave  
  8009cc:	c3                   	ret    

008009cd <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009cd:	55                   	push   %ebp
  8009ce:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8009d0:	ff 75 10             	pushl  0x10(%ebp)
  8009d3:	ff 75 0c             	pushl  0xc(%ebp)
  8009d6:	ff 75 08             	pushl  0x8(%ebp)
  8009d9:	e8 85 ff ff ff       	call   800963 <memmove>
}
  8009de:	c9                   	leave  
  8009df:	c3                   	ret    

008009e0 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009e0:	55                   	push   %ebp
  8009e1:	89 e5                	mov    %esp,%ebp
  8009e3:	57                   	push   %edi
  8009e4:	56                   	push   %esi
  8009e5:	53                   	push   %ebx
  8009e6:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8009e9:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009ec:	8b 7d 10             	mov    0x10(%ebp),%edi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009ef:	85 ff                	test   %edi,%edi
  8009f1:	74 32                	je     800a25 <memcmp+0x45>
		if (*s1 != *s2)
  8009f3:	8a 03                	mov    (%ebx),%al
  8009f5:	8a 0e                	mov    (%esi),%cl
  8009f7:	38 c8                	cmp    %cl,%al
  8009f9:	74 19                	je     800a14 <memcmp+0x34>
  8009fb:	eb 0d                	jmp    800a0a <memcmp+0x2a>
  8009fd:	8a 44 13 01          	mov    0x1(%ebx,%edx,1),%al
  800a01:	8a 4c 16 01          	mov    0x1(%esi,%edx,1),%cl
  800a05:	42                   	inc    %edx
  800a06:	38 c8                	cmp    %cl,%al
  800a08:	74 10                	je     800a1a <memcmp+0x3a>
			return (int) *s1 - (int) *s2;
  800a0a:	0f b6 c0             	movzbl %al,%eax
  800a0d:	0f b6 c9             	movzbl %cl,%ecx
  800a10:	29 c8                	sub    %ecx,%eax
  800a12:	eb 16                	jmp    800a2a <memcmp+0x4a>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a14:	4f                   	dec    %edi
  800a15:	ba 00 00 00 00       	mov    $0x0,%edx
  800a1a:	39 fa                	cmp    %edi,%edx
  800a1c:	75 df                	jne    8009fd <memcmp+0x1d>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a1e:	b8 00 00 00 00       	mov    $0x0,%eax
  800a23:	eb 05                	jmp    800a2a <memcmp+0x4a>
  800a25:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a2a:	5b                   	pop    %ebx
  800a2b:	5e                   	pop    %esi
  800a2c:	5f                   	pop    %edi
  800a2d:	c9                   	leave  
  800a2e:	c3                   	ret    

00800a2f <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a2f:	55                   	push   %ebp
  800a30:	89 e5                	mov    %esp,%ebp
  800a32:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800a35:	89 c2                	mov    %eax,%edx
  800a37:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a3a:	39 d0                	cmp    %edx,%eax
  800a3c:	73 12                	jae    800a50 <memfind+0x21>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a3e:	8a 4d 0c             	mov    0xc(%ebp),%cl
  800a41:	38 08                	cmp    %cl,(%eax)
  800a43:	75 06                	jne    800a4b <memfind+0x1c>
  800a45:	eb 09                	jmp    800a50 <memfind+0x21>
  800a47:	38 08                	cmp    %cl,(%eax)
  800a49:	74 05                	je     800a50 <memfind+0x21>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a4b:	40                   	inc    %eax
  800a4c:	39 c2                	cmp    %eax,%edx
  800a4e:	77 f7                	ja     800a47 <memfind+0x18>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a50:	c9                   	leave  
  800a51:	c3                   	ret    

00800a52 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a52:	55                   	push   %ebp
  800a53:	89 e5                	mov    %esp,%ebp
  800a55:	57                   	push   %edi
  800a56:	56                   	push   %esi
  800a57:	53                   	push   %ebx
  800a58:	8b 55 08             	mov    0x8(%ebp),%edx
  800a5b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a5e:	eb 01                	jmp    800a61 <strtol+0xf>
		s++;
  800a60:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a61:	8a 02                	mov    (%edx),%al
  800a63:	3c 20                	cmp    $0x20,%al
  800a65:	74 f9                	je     800a60 <strtol+0xe>
  800a67:	3c 09                	cmp    $0x9,%al
  800a69:	74 f5                	je     800a60 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a6b:	3c 2b                	cmp    $0x2b,%al
  800a6d:	75 08                	jne    800a77 <strtol+0x25>
		s++;
  800a6f:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a70:	bf 00 00 00 00       	mov    $0x0,%edi
  800a75:	eb 13                	jmp    800a8a <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a77:	3c 2d                	cmp    $0x2d,%al
  800a79:	75 0a                	jne    800a85 <strtol+0x33>
		s++, neg = 1;
  800a7b:	8d 52 01             	lea    0x1(%edx),%edx
  800a7e:	bf 01 00 00 00       	mov    $0x1,%edi
  800a83:	eb 05                	jmp    800a8a <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a85:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a8a:	85 db                	test   %ebx,%ebx
  800a8c:	74 05                	je     800a93 <strtol+0x41>
  800a8e:	83 fb 10             	cmp    $0x10,%ebx
  800a91:	75 28                	jne    800abb <strtol+0x69>
  800a93:	8a 02                	mov    (%edx),%al
  800a95:	3c 30                	cmp    $0x30,%al
  800a97:	75 10                	jne    800aa9 <strtol+0x57>
  800a99:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800a9d:	75 0a                	jne    800aa9 <strtol+0x57>
		s += 2, base = 16;
  800a9f:	83 c2 02             	add    $0x2,%edx
  800aa2:	bb 10 00 00 00       	mov    $0x10,%ebx
  800aa7:	eb 12                	jmp    800abb <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800aa9:	85 db                	test   %ebx,%ebx
  800aab:	75 0e                	jne    800abb <strtol+0x69>
  800aad:	3c 30                	cmp    $0x30,%al
  800aaf:	75 05                	jne    800ab6 <strtol+0x64>
		s++, base = 8;
  800ab1:	42                   	inc    %edx
  800ab2:	b3 08                	mov    $0x8,%bl
  800ab4:	eb 05                	jmp    800abb <strtol+0x69>
	else if (base == 0)
		base = 10;
  800ab6:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800abb:	b8 00 00 00 00       	mov    $0x0,%eax
  800ac0:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800ac2:	8a 0a                	mov    (%edx),%cl
  800ac4:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800ac7:	80 fb 09             	cmp    $0x9,%bl
  800aca:	77 08                	ja     800ad4 <strtol+0x82>
			dig = *s - '0';
  800acc:	0f be c9             	movsbl %cl,%ecx
  800acf:	83 e9 30             	sub    $0x30,%ecx
  800ad2:	eb 1e                	jmp    800af2 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800ad4:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800ad7:	80 fb 19             	cmp    $0x19,%bl
  800ada:	77 08                	ja     800ae4 <strtol+0x92>
			dig = *s - 'a' + 10;
  800adc:	0f be c9             	movsbl %cl,%ecx
  800adf:	83 e9 57             	sub    $0x57,%ecx
  800ae2:	eb 0e                	jmp    800af2 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800ae4:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800ae7:	80 fb 19             	cmp    $0x19,%bl
  800aea:	77 13                	ja     800aff <strtol+0xad>
			dig = *s - 'A' + 10;
  800aec:	0f be c9             	movsbl %cl,%ecx
  800aef:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800af2:	39 f1                	cmp    %esi,%ecx
  800af4:	7d 0d                	jge    800b03 <strtol+0xb1>
			break;
		s++, val = (val * base) + dig;
  800af6:	42                   	inc    %edx
  800af7:	0f af c6             	imul   %esi,%eax
  800afa:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  800afd:	eb c3                	jmp    800ac2 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800aff:	89 c1                	mov    %eax,%ecx
  800b01:	eb 02                	jmp    800b05 <strtol+0xb3>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800b03:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800b05:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b09:	74 05                	je     800b10 <strtol+0xbe>
		*endptr = (char *) s;
  800b0b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800b0e:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800b10:	85 ff                	test   %edi,%edi
  800b12:	74 04                	je     800b18 <strtol+0xc6>
  800b14:	89 c8                	mov    %ecx,%eax
  800b16:	f7 d8                	neg    %eax
}
  800b18:	5b                   	pop    %ebx
  800b19:	5e                   	pop    %esi
  800b1a:	5f                   	pop    %edi
  800b1b:	c9                   	leave  
  800b1c:	c3                   	ret    
  800b1d:	00 00                	add    %al,(%eax)
	...

00800b20 <syscall>:
	return ret;
}

static int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800b20:	55                   	push   %ebp
  800b21:	89 e5                	mov    %esp,%ebp
  800b23:	57                   	push   %edi
  800b24:	56                   	push   %esi
  800b25:	53                   	push   %ebx
  800b26:	83 ec 1c             	sub    $0x1c,%esp
  800b29:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800b2c:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800b2f:	89 ca                	mov    %ecx,%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b31:	8b 75 14             	mov    0x14(%ebp),%esi
  800b34:	8b 7d 10             	mov    0x10(%ebp),%edi
  800b37:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800b3a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b3d:	cd 30                	int    $0x30
  800b3f:	89 c2                	mov    %eax,%edx
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b41:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800b45:	74 1c                	je     800b63 <syscall+0x43>
  800b47:	85 c0                	test   %eax,%eax
  800b49:	7e 18                	jle    800b63 <syscall+0x43>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b4b:	83 ec 0c             	sub    $0xc,%esp
  800b4e:	50                   	push   %eax
  800b4f:	ff 75 e4             	pushl  -0x1c(%ebp)
  800b52:	68 04 13 80 00       	push   $0x801304
  800b57:	6a 42                	push   $0x42
  800b59:	68 21 13 80 00       	push   $0x801321
  800b5e:	e8 b1 f5 ff ff       	call   800114 <_panic>

	return ret;
}
  800b63:	89 d0                	mov    %edx,%eax
  800b65:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b68:	5b                   	pop    %ebx
  800b69:	5e                   	pop    %esi
  800b6a:	5f                   	pop    %edi
  800b6b:	c9                   	leave  
  800b6c:	c3                   	ret    

00800b6d <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{	
  800b6d:	55                   	push   %ebp
  800b6e:	89 e5                	mov    %esp,%ebp
  800b70:	83 ec 08             	sub    $0x8,%esp
	// my_sysenter(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
	// return;
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  800b73:	6a 00                	push   $0x0
  800b75:	6a 00                	push   $0x0
  800b77:	6a 00                	push   $0x0
  800b79:	ff 75 0c             	pushl  0xc(%ebp)
  800b7c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b7f:	ba 00 00 00 00       	mov    $0x0,%edx
  800b84:	b8 00 00 00 00       	mov    $0x0,%eax
  800b89:	e8 92 ff ff ff       	call   800b20 <syscall>
  800b8e:	83 c4 10             	add    $0x10,%esp
	return;
}
  800b91:	c9                   	leave  
  800b92:	c3                   	ret    

00800b93 <sys_cgetc>:

int
sys_cgetc(void)
{
  800b93:	55                   	push   %ebp
  800b94:	89 e5                	mov    %esp,%ebp
  800b96:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_cgetc, 0, 0, 0, 0, 0, 0);
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  800b99:	6a 00                	push   $0x0
  800b9b:	6a 00                	push   $0x0
  800b9d:	6a 00                	push   $0x0
  800b9f:	6a 00                	push   $0x0
  800ba1:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ba6:	ba 00 00 00 00       	mov    $0x0,%edx
  800bab:	b8 01 00 00 00       	mov    $0x1,%eax
  800bb0:	e8 6b ff ff ff       	call   800b20 <syscall>
}
  800bb5:	c9                   	leave  
  800bb6:	c3                   	ret    

00800bb7 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800bb7:	55                   	push   %ebp
  800bb8:	89 e5                	mov    %esp,%ebp
  800bba:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  800bbd:	6a 00                	push   $0x0
  800bbf:	6a 00                	push   $0x0
  800bc1:	6a 00                	push   $0x0
  800bc3:	6a 00                	push   $0x0
  800bc5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800bc8:	ba 01 00 00 00       	mov    $0x1,%edx
  800bcd:	b8 03 00 00 00       	mov    $0x3,%eax
  800bd2:	e8 49 ff ff ff       	call   800b20 <syscall>
}
  800bd7:	c9                   	leave  
  800bd8:	c3                   	ret    

00800bd9 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800bd9:	55                   	push   %ebp
  800bda:	89 e5                	mov    %esp,%ebp
  800bdc:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_getenvid, 0, 0, 0, 0, 0, 0);
	return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  800bdf:	6a 00                	push   $0x0
  800be1:	6a 00                	push   $0x0
  800be3:	6a 00                	push   $0x0
  800be5:	6a 00                	push   $0x0
  800be7:	b9 00 00 00 00       	mov    $0x0,%ecx
  800bec:	ba 00 00 00 00       	mov    $0x0,%edx
  800bf1:	b8 02 00 00 00       	mov    $0x2,%eax
  800bf6:	e8 25 ff ff ff       	call   800b20 <syscall>
}
  800bfb:	c9                   	leave  
  800bfc:	c3                   	ret    

00800bfd <sys_yield>:

void
sys_yield(void)
{
  800bfd:	55                   	push   %ebp
  800bfe:	89 e5                	mov    %esp,%ebp
  800c00:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  800c03:	6a 00                	push   $0x0
  800c05:	6a 00                	push   $0x0
  800c07:	6a 00                	push   $0x0
  800c09:	6a 00                	push   $0x0
  800c0b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c10:	ba 00 00 00 00       	mov    $0x0,%edx
  800c15:	b8 0a 00 00 00       	mov    $0xa,%eax
  800c1a:	e8 01 ff ff ff       	call   800b20 <syscall>
  800c1f:	83 c4 10             	add    $0x10,%esp
}
  800c22:	c9                   	leave  
  800c23:	c3                   	ret    

00800c24 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c24:	55                   	push   %ebp
  800c25:	89 e5                	mov    %esp,%ebp
  800c27:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  800c2a:	6a 00                	push   $0x0
  800c2c:	6a 00                	push   $0x0
  800c2e:	ff 75 10             	pushl  0x10(%ebp)
  800c31:	ff 75 0c             	pushl  0xc(%ebp)
  800c34:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c37:	ba 01 00 00 00       	mov    $0x1,%edx
  800c3c:	b8 04 00 00 00       	mov    $0x4,%eax
  800c41:	e8 da fe ff ff       	call   800b20 <syscall>
}
  800c46:	c9                   	leave  
  800c47:	c3                   	ret    

00800c48 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c48:	55                   	push   %ebp
  800c49:	89 e5                	mov    %esp,%ebp
  800c4b:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
  800c4e:	ff 75 18             	pushl  0x18(%ebp)
  800c51:	ff 75 14             	pushl  0x14(%ebp)
  800c54:	ff 75 10             	pushl  0x10(%ebp)
  800c57:	ff 75 0c             	pushl  0xc(%ebp)
  800c5a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c5d:	ba 01 00 00 00       	mov    $0x1,%edx
  800c62:	b8 05 00 00 00       	mov    $0x5,%eax
  800c67:	e8 b4 fe ff ff       	call   800b20 <syscall>
}
  800c6c:	c9                   	leave  
  800c6d:	c3                   	ret    

00800c6e <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c6e:	55                   	push   %ebp
  800c6f:	89 e5                	mov    %esp,%ebp
  800c71:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  800c74:	6a 00                	push   $0x0
  800c76:	6a 00                	push   $0x0
  800c78:	6a 00                	push   $0x0
  800c7a:	ff 75 0c             	pushl  0xc(%ebp)
  800c7d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c80:	ba 01 00 00 00       	mov    $0x1,%edx
  800c85:	b8 06 00 00 00       	mov    $0x6,%eax
  800c8a:	e8 91 fe ff ff       	call   800b20 <syscall>
}
  800c8f:	c9                   	leave  
  800c90:	c3                   	ret    

00800c91 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c91:	55                   	push   %ebp
  800c92:	89 e5                	mov    %esp,%ebp
  800c94:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  800c97:	6a 00                	push   $0x0
  800c99:	6a 00                	push   $0x0
  800c9b:	6a 00                	push   $0x0
  800c9d:	ff 75 0c             	pushl  0xc(%ebp)
  800ca0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ca3:	ba 01 00 00 00       	mov    $0x1,%edx
  800ca8:	b8 08 00 00 00       	mov    $0x8,%eax
  800cad:	e8 6e fe ff ff       	call   800b20 <syscall>
}
  800cb2:	c9                   	leave  
  800cb3:	c3                   	ret    

00800cb4 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800cb4:	55                   	push   %ebp
  800cb5:	89 e5                	mov    %esp,%ebp
  800cb7:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  800cba:	6a 00                	push   $0x0
  800cbc:	6a 00                	push   $0x0
  800cbe:	6a 00                	push   $0x0
  800cc0:	ff 75 0c             	pushl  0xc(%ebp)
  800cc3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800cc6:	ba 01 00 00 00       	mov    $0x1,%edx
  800ccb:	b8 09 00 00 00       	mov    $0x9,%eax
  800cd0:	e8 4b fe ff ff       	call   800b20 <syscall>
}
  800cd5:	c9                   	leave  
  800cd6:	c3                   	ret    

00800cd7 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800cd7:	55                   	push   %ebp
  800cd8:	89 e5                	mov    %esp,%ebp
  800cda:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  800cdd:	6a 00                	push   $0x0
  800cdf:	ff 75 14             	pushl  0x14(%ebp)
  800ce2:	ff 75 10             	pushl  0x10(%ebp)
  800ce5:	ff 75 0c             	pushl  0xc(%ebp)
  800ce8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ceb:	ba 00 00 00 00       	mov    $0x0,%edx
  800cf0:	b8 0b 00 00 00       	mov    $0xb,%eax
  800cf5:	e8 26 fe ff ff       	call   800b20 <syscall>
}
  800cfa:	c9                   	leave  
  800cfb:	c3                   	ret    

00800cfc <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800cfc:	55                   	push   %ebp
  800cfd:	89 e5                	mov    %esp,%ebp
  800cff:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  800d02:	6a 00                	push   $0x0
  800d04:	6a 00                	push   $0x0
  800d06:	6a 00                	push   $0x0
  800d08:	6a 00                	push   $0x0
  800d0a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d0d:	ba 01 00 00 00       	mov    $0x1,%edx
  800d12:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d17:	e8 04 fe ff ff       	call   800b20 <syscall>
}
  800d1c:	c9                   	leave  
  800d1d:	c3                   	ret    

00800d1e <sys_set_priority>:

int
sys_set_priority(envid_t envid, uint32_t new_priority)
{
  800d1e:	55                   	push   %ebp
  800d1f:	89 e5                	mov    %esp,%ebp
  800d21:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_set_priority, 0, envid, new_priority, 0, 0, 0);
  800d24:	6a 00                	push   $0x0
  800d26:	6a 00                	push   $0x0
  800d28:	6a 00                	push   $0x0
  800d2a:	ff 75 0c             	pushl  0xc(%ebp)
  800d2d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d30:	ba 00 00 00 00       	mov    $0x0,%edx
  800d35:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d3a:	e8 e1 fd ff ff       	call   800b20 <syscall>
}
  800d3f:	c9                   	leave  
  800d40:	c3                   	ret    
  800d41:	00 00                	add    %al,(%eax)
	...

00800d44 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  800d44:	55                   	push   %ebp
  800d45:	89 e5                	mov    %esp,%ebp
  800d47:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  800d4a:	83 3d 08 20 80 00 00 	cmpl   $0x0,0x802008
  800d51:	75 52                	jne    800da5 <set_pgfault_handler+0x61>
		// First time through!	
		// LAB 4: Your code here.

		//int sys_page_alloc(envid_t envid, void *va, int perm)
		r = sys_page_alloc(0, (void*)(UXSTACKTOP - PGSIZE), PTE_U | PTE_W | PTE_P);
  800d53:	83 ec 04             	sub    $0x4,%esp
  800d56:	6a 07                	push   $0x7
  800d58:	68 00 f0 bf ee       	push   $0xeebff000
  800d5d:	6a 00                	push   $0x0
  800d5f:	e8 c0 fe ff ff       	call   800c24 <sys_page_alloc>
		if (r < 0) {
  800d64:	83 c4 10             	add    $0x10,%esp
  800d67:	85 c0                	test   %eax,%eax
  800d69:	79 12                	jns    800d7d <set_pgfault_handler+0x39>
			panic("sys_page_alloc error : %e\n", r);
  800d6b:	50                   	push   %eax
  800d6c:	68 2f 13 80 00       	push   $0x80132f
  800d71:	6a 24                	push   $0x24
  800d73:	68 4a 13 80 00       	push   $0x80134a
  800d78:	e8 97 f3 ff ff       	call   800114 <_panic>
		}

		// how to know envid, put 0, envid2env will help us to get curenv in syscall
		r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);		
  800d7d:	83 ec 08             	sub    $0x8,%esp
  800d80:	68 b0 0d 80 00       	push   $0x800db0
  800d85:	6a 00                	push   $0x0
  800d87:	e8 28 ff ff ff       	call   800cb4 <sys_env_set_pgfault_upcall>
		if (r < 0) {
  800d8c:	83 c4 10             	add    $0x10,%esp
  800d8f:	85 c0                	test   %eax,%eax
  800d91:	79 12                	jns    800da5 <set_pgfault_handler+0x61>
			panic("sys_env_set_pgfault_upcall error : %e\n", r);
  800d93:	50                   	push   %eax
  800d94:	68 58 13 80 00       	push   $0x801358
  800d99:	6a 2a                	push   $0x2a
  800d9b:	68 4a 13 80 00       	push   $0x80134a
  800da0:	e8 6f f3 ff ff       	call   800114 <_panic>
		}
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  800da5:	8b 45 08             	mov    0x8(%ebp),%eax
  800da8:	a3 08 20 80 00       	mov    %eax,0x802008
}
  800dad:	c9                   	leave  
  800dae:	c3                   	ret    
	...

00800db0 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  800db0:	54                   	push   %esp
	movl _pgfault_handler, %eax
  800db1:	a1 08 20 80 00       	mov    0x802008,%eax
	call *%eax
  800db6:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  800db8:	83 c4 04             	add    $0x4,%esp
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	
	// fix old esp
	movl 0x30(%esp), %eax
  800dbb:	8b 44 24 30          	mov    0x30(%esp),%eax
	subl $0x4, %eax
  800dbf:	83 e8 04             	sub    $0x4,%eax
	movl %eax, 0x30(%esp)
  800dc2:	89 44 24 30          	mov    %eax,0x30(%esp)

	// set trap-time %eip
	movl 0x28(%esp), %ebx
  800dc6:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	movl %ebx, (%eax)
  800dca:	89 18                	mov    %ebx,(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $0x08, %esp 	// ignore err_code and fault_va
  800dcc:	83 c4 08             	add    $0x8,%esp
	popal 				// restore registers
  800dcf:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x04, %esp 	// ignore eip 
  800dd0:	83 c4 04             	add    $0x4,%esp
	popfl				// modify eflags
  800dd3:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  800dd4:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  800dd5:	c3                   	ret    
	...

00800dd8 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  800dd8:	55                   	push   %ebp
  800dd9:	89 e5                	mov    %esp,%ebp
  800ddb:	57                   	push   %edi
  800ddc:	56                   	push   %esi
  800ddd:	83 ec 10             	sub    $0x10,%esp
  800de0:	8b 7d 08             	mov    0x8(%ebp),%edi
  800de3:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  800de6:	89 7d f0             	mov    %edi,-0x10(%ebp)
  800de9:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  800dec:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  800def:	8b 45 14             	mov    0x14(%ebp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800df2:	85 c0                	test   %eax,%eax
  800df4:	75 2e                	jne    800e24 <__udivdi3+0x4c>
    {
      if (d0 > n1)
  800df6:	39 f1                	cmp    %esi,%ecx
  800df8:	77 5a                	ja     800e54 <__udivdi3+0x7c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  800dfa:	85 c9                	test   %ecx,%ecx
  800dfc:	75 0b                	jne    800e09 <__udivdi3+0x31>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  800dfe:	b8 01 00 00 00       	mov    $0x1,%eax
  800e03:	31 d2                	xor    %edx,%edx
  800e05:	f7 f1                	div    %ecx
  800e07:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  800e09:	31 d2                	xor    %edx,%edx
  800e0b:	89 f0                	mov    %esi,%eax
  800e0d:	f7 f1                	div    %ecx
  800e0f:	89 c6                	mov    %eax,%esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800e11:	89 f8                	mov    %edi,%eax
  800e13:	f7 f1                	div    %ecx
  800e15:	89 c7                	mov    %eax,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800e17:	89 f8                	mov    %edi,%eax
  800e19:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800e1b:	83 c4 10             	add    $0x10,%esp
  800e1e:	5e                   	pop    %esi
  800e1f:	5f                   	pop    %edi
  800e20:	c9                   	leave  
  800e21:	c3                   	ret    
  800e22:	66 90                	xchg   %ax,%ax
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800e24:	39 f0                	cmp    %esi,%eax
  800e26:	77 1c                	ja     800e44 <__udivdi3+0x6c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  800e28:	0f bd f8             	bsr    %eax,%edi
	  if (bm == 0)
  800e2b:	83 f7 1f             	xor    $0x1f,%edi
  800e2e:	75 3c                	jne    800e6c <__udivdi3+0x94>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800e30:	39 f0                	cmp    %esi,%eax
  800e32:	0f 82 90 00 00 00    	jb     800ec8 <__udivdi3+0xf0>
  800e38:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800e3b:	39 55 f4             	cmp    %edx,-0xc(%ebp)
  800e3e:	0f 86 84 00 00 00    	jbe    800ec8 <__udivdi3+0xf0>
  800e44:	31 f6                	xor    %esi,%esi
  800e46:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800e48:	89 f8                	mov    %edi,%eax
  800e4a:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800e4c:	83 c4 10             	add    $0x10,%esp
  800e4f:	5e                   	pop    %esi
  800e50:	5f                   	pop    %edi
  800e51:	c9                   	leave  
  800e52:	c3                   	ret    
  800e53:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800e54:	89 f2                	mov    %esi,%edx
  800e56:	89 f8                	mov    %edi,%eax
  800e58:	f7 f1                	div    %ecx
  800e5a:	89 c7                	mov    %eax,%edi
  800e5c:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800e5e:	89 f8                	mov    %edi,%eax
  800e60:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800e62:	83 c4 10             	add    $0x10,%esp
  800e65:	5e                   	pop    %esi
  800e66:	5f                   	pop    %edi
  800e67:	c9                   	leave  
  800e68:	c3                   	ret    
  800e69:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  800e6c:	89 f9                	mov    %edi,%ecx
  800e6e:	d3 e0                	shl    %cl,%eax
  800e70:	89 45 e8             	mov    %eax,-0x18(%ebp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  800e73:	b8 20 00 00 00       	mov    $0x20,%eax
  800e78:	29 f8                	sub    %edi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  800e7a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800e7d:	88 c1                	mov    %al,%cl
  800e7f:	d3 ea                	shr    %cl,%edx
  800e81:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  800e84:	09 ca                	or     %ecx,%edx
  800e86:	89 55 ec             	mov    %edx,-0x14(%ebp)
	      d0 = d0 << bm;
  800e89:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800e8c:	89 f9                	mov    %edi,%ecx
  800e8e:	d3 e2                	shl    %cl,%edx
  800e90:	89 55 f4             	mov    %edx,-0xc(%ebp)
	      n2 = n1 >> b;
  800e93:	89 f2                	mov    %esi,%edx
  800e95:	88 c1                	mov    %al,%cl
  800e97:	d3 ea                	shr    %cl,%edx
  800e99:	89 55 e8             	mov    %edx,-0x18(%ebp)
	      n1 = (n1 << bm) | (n0 >> b);
  800e9c:	89 f2                	mov    %esi,%edx
  800e9e:	89 f9                	mov    %edi,%ecx
  800ea0:	d3 e2                	shl    %cl,%edx
  800ea2:	8b 75 f0             	mov    -0x10(%ebp),%esi
  800ea5:	88 c1                	mov    %al,%cl
  800ea7:	d3 ee                	shr    %cl,%esi
  800ea9:	09 d6                	or     %edx,%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  800eab:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  800eae:	89 f0                	mov    %esi,%eax
  800eb0:	89 ca                	mov    %ecx,%edx
  800eb2:	f7 75 ec             	divl   -0x14(%ebp)
  800eb5:	89 d1                	mov    %edx,%ecx
  800eb7:	89 c6                	mov    %eax,%esi
	      umul_ppmm (m1, m0, q0, d0);
  800eb9:	f7 65 f4             	mull   -0xc(%ebp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800ebc:	39 d1                	cmp    %edx,%ecx
  800ebe:	72 28                	jb     800ee8 <__udivdi3+0x110>
  800ec0:	74 1a                	je     800edc <__udivdi3+0x104>
  800ec2:	89 f7                	mov    %esi,%edi
  800ec4:	31 f6                	xor    %esi,%esi
  800ec6:	eb 80                	jmp    800e48 <__udivdi3+0x70>
	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  800ec8:	31 f6                	xor    %esi,%esi
  800eca:	bf 01 00 00 00       	mov    $0x1,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800ecf:	89 f8                	mov    %edi,%eax
  800ed1:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800ed3:	83 c4 10             	add    $0x10,%esp
  800ed6:	5e                   	pop    %esi
  800ed7:	5f                   	pop    %edi
  800ed8:	c9                   	leave  
  800ed9:	c3                   	ret    
  800eda:	66 90                	xchg   %ax,%ax

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  800edc:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800edf:	89 f9                	mov    %edi,%ecx
  800ee1:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800ee3:	39 c2                	cmp    %eax,%edx
  800ee5:	73 db                	jae    800ec2 <__udivdi3+0xea>
  800ee7:	90                   	nop
		{
		  q0--;
  800ee8:	8d 7e ff             	lea    -0x1(%esi),%edi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  800eeb:	31 f6                	xor    %esi,%esi
  800eed:	e9 56 ff ff ff       	jmp    800e48 <__udivdi3+0x70>
	...

00800ef4 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  800ef4:	55                   	push   %ebp
  800ef5:	89 e5                	mov    %esp,%ebp
  800ef7:	57                   	push   %edi
  800ef8:	56                   	push   %esi
  800ef9:	83 ec 20             	sub    $0x20,%esp
  800efc:	8b 45 08             	mov    0x8(%ebp),%eax
  800eff:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  800f02:	89 45 e8             	mov    %eax,-0x18(%ebp)
  800f05:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  800f08:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  800f0b:	8b 7d 14             	mov    0x14(%ebp),%edi
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  800f0e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  n1 = nn.s.high;
  800f11:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800f13:	85 ff                	test   %edi,%edi
  800f15:	75 15                	jne    800f2c <__umoddi3+0x38>
    {
      if (d0 > n1)
  800f17:	39 f1                	cmp    %esi,%ecx
  800f19:	0f 86 99 00 00 00    	jbe    800fb8 <__umoddi3+0xc4>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800f1f:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  800f21:	89 d0                	mov    %edx,%eax
  800f23:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800f25:	83 c4 20             	add    $0x20,%esp
  800f28:	5e                   	pop    %esi
  800f29:	5f                   	pop    %edi
  800f2a:	c9                   	leave  
  800f2b:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800f2c:	39 f7                	cmp    %esi,%edi
  800f2e:	0f 87 a4 00 00 00    	ja     800fd8 <__umoddi3+0xe4>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  800f34:	0f bd c7             	bsr    %edi,%eax
	  if (bm == 0)
  800f37:	83 f0 1f             	xor    $0x1f,%eax
  800f3a:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800f3d:	0f 84 a1 00 00 00    	je     800fe4 <__umoddi3+0xf0>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  800f43:	89 f8                	mov    %edi,%eax
  800f45:	8a 4d ec             	mov    -0x14(%ebp),%cl
  800f48:	d3 e0                	shl    %cl,%eax
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  800f4a:	bf 20 00 00 00       	mov    $0x20,%edi
  800f4f:	2b 7d ec             	sub    -0x14(%ebp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  800f52:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800f55:	89 f9                	mov    %edi,%ecx
  800f57:	d3 ea                	shr    %cl,%edx
  800f59:	09 c2                	or     %eax,%edx
  800f5b:	89 55 f0             	mov    %edx,-0x10(%ebp)
	      d0 = d0 << bm;
  800f5e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800f61:	8a 4d ec             	mov    -0x14(%ebp),%cl
  800f64:	d3 e0                	shl    %cl,%eax
  800f66:	89 45 f4             	mov    %eax,-0xc(%ebp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  800f69:	89 f2                	mov    %esi,%edx
  800f6b:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  800f6d:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800f70:	d3 e0                	shl    %cl,%eax
  800f72:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  800f75:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800f78:	89 f9                	mov    %edi,%ecx
  800f7a:	d3 e8                	shr    %cl,%eax
  800f7c:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  800f7e:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  800f80:	89 f2                	mov    %esi,%edx
  800f82:	f7 75 f0             	divl   -0x10(%ebp)
  800f85:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  800f87:	f7 65 f4             	mull   -0xc(%ebp)
  800f8a:	89 55 e8             	mov    %edx,-0x18(%ebp)
  800f8d:	89 c1                	mov    %eax,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800f8f:	39 d6                	cmp    %edx,%esi
  800f91:	72 71                	jb     801004 <__umoddi3+0x110>
  800f93:	74 7f                	je     801014 <__umoddi3+0x120>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  800f95:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800f98:	29 c8                	sub    %ecx,%eax
  800f9a:	19 d6                	sbb    %edx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  800f9c:	8a 4d ec             	mov    -0x14(%ebp),%cl
  800f9f:	d3 e8                	shr    %cl,%eax
  800fa1:	89 f2                	mov    %esi,%edx
  800fa3:	89 f9                	mov    %edi,%ecx
  800fa5:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  800fa7:	09 d0                	or     %edx,%eax
  800fa9:	89 f2                	mov    %esi,%edx
  800fab:	8a 4d ec             	mov    -0x14(%ebp),%cl
  800fae:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800fb0:	83 c4 20             	add    $0x20,%esp
  800fb3:	5e                   	pop    %esi
  800fb4:	5f                   	pop    %edi
  800fb5:	c9                   	leave  
  800fb6:	c3                   	ret    
  800fb7:	90                   	nop
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  800fb8:	85 c9                	test   %ecx,%ecx
  800fba:	75 0b                	jne    800fc7 <__umoddi3+0xd3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  800fbc:	b8 01 00 00 00       	mov    $0x1,%eax
  800fc1:	31 d2                	xor    %edx,%edx
  800fc3:	f7 f1                	div    %ecx
  800fc5:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  800fc7:	89 f0                	mov    %esi,%eax
  800fc9:	31 d2                	xor    %edx,%edx
  800fcb:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800fcd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800fd0:	f7 f1                	div    %ecx
  800fd2:	e9 4a ff ff ff       	jmp    800f21 <__umoddi3+0x2d>
  800fd7:	90                   	nop
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  800fd8:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800fda:	83 c4 20             	add    $0x20,%esp
  800fdd:	5e                   	pop    %esi
  800fde:	5f                   	pop    %edi
  800fdf:	c9                   	leave  
  800fe0:	c3                   	ret    
  800fe1:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800fe4:	39 f7                	cmp    %esi,%edi
  800fe6:	72 05                	jb     800fed <__umoddi3+0xf9>
  800fe8:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
  800feb:	77 0c                	ja     800ff9 <__umoddi3+0x105>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  800fed:	89 f2                	mov    %esi,%edx
  800fef:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800ff2:	29 c8                	sub    %ecx,%eax
  800ff4:	19 fa                	sbb    %edi,%edx
  800ff6:	89 45 f0             	mov    %eax,-0x10(%ebp)

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  800ff9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800ffc:	83 c4 20             	add    $0x20,%esp
  800fff:	5e                   	pop    %esi
  801000:	5f                   	pop    %edi
  801001:	c9                   	leave  
  801002:	c3                   	ret    
  801003:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  801004:	8b 55 e8             	mov    -0x18(%ebp),%edx
  801007:	89 c1                	mov    %eax,%ecx
  801009:	2b 4d f4             	sub    -0xc(%ebp),%ecx
  80100c:	1b 55 f0             	sbb    -0x10(%ebp),%edx
  80100f:	eb 84                	jmp    800f95 <__umoddi3+0xa1>
  801011:	8d 76 00             	lea    0x0(%esi),%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801014:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801017:	72 eb                	jb     801004 <__umoddi3+0x110>
  801019:	89 f2                	mov    %esi,%edx
  80101b:	e9 75 ff ff ff       	jmp    800f95 <__umoddi3+0xa1>
