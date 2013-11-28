
obj/user/faultallocbad.debug:     file format elf32-i386


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
  800041:	68 a0 1e 80 00       	push   $0x801ea0
  800046:	e8 b1 01 00 00       	call   8001fc <cprintf>
	if ((r = sys_page_alloc(0, ROUNDDOWN(addr, PGSIZE),
  80004b:	83 c4 0c             	add    $0xc,%esp
  80004e:	6a 07                	push   $0x7
  800050:	89 d8                	mov    %ebx,%eax
  800052:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800057:	50                   	push   %eax
  800058:	6a 00                	push   $0x0
  80005a:	e8 d5 0b 00 00       	call   800c34 <sys_page_alloc>
  80005f:	83 c4 10             	add    $0x10,%esp
  800062:	85 c0                	test   %eax,%eax
  800064:	79 16                	jns    80007c <handler+0x48>
				PTE_P|PTE_U|PTE_W)) < 0)
		panic("allocating at %x in page fault handler: %e", addr, r);
  800066:	83 ec 0c             	sub    $0xc,%esp
  800069:	50                   	push   %eax
  80006a:	53                   	push   %ebx
  80006b:	68 c0 1e 80 00       	push   $0x801ec0
  800070:	6a 0f                	push   $0xf
  800072:	68 aa 1e 80 00       	push   $0x801eaa
  800077:	e8 a8 00 00 00       	call   800124 <_panic>
	snprintf((char*) addr, 100, "this string was faulted in at %x", addr);
  80007c:	53                   	push   %ebx
  80007d:	68 ec 1e 80 00       	push   $0x801eec
  800082:	6a 64                	push   $0x64
  800084:	53                   	push   %ebx
  800085:	e8 ba 06 00 00       	call   800744 <snprintf>
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
  80009d:	e8 fa 0c 00 00       	call   800d9c <set_pgfault_handler>
	sys_cputs((char*)0xDEADBEEF, 4);
  8000a2:	83 c4 08             	add    $0x8,%esp
  8000a5:	6a 04                	push   $0x4
  8000a7:	68 ef be ad de       	push   $0xdeadbeef
  8000ac:	e8 cc 0a 00 00       	call   800b7d <sys_cputs>
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
  8000c3:	e8 21 0b 00 00       	call   800be9 <sys_getenvid>
  8000c8:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000cd:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  8000d4:	c1 e0 07             	shl    $0x7,%eax
  8000d7:	29 d0                	sub    %edx,%eax
  8000d9:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000de:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000e3:	85 f6                	test   %esi,%esi
  8000e5:	7e 07                	jle    8000ee <libmain+0x36>
		binaryname = argv[0];
  8000e7:	8b 03                	mov    (%ebx),%eax
  8000e9:	a3 00 30 80 00       	mov    %eax,0x803000
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
  80010b:	83 ec 08             	sub    $0x8,%esp
	close_all();
  80010e:	e8 27 0f 00 00       	call   80103a <close_all>
	sys_env_destroy(0);
  800113:	83 ec 0c             	sub    $0xc,%esp
  800116:	6a 00                	push   $0x0
  800118:	e8 aa 0a 00 00       	call   800bc7 <sys_env_destroy>
  80011d:	83 c4 10             	add    $0x10,%esp
}
  800120:	c9                   	leave  
  800121:	c3                   	ret    
	...

00800124 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800124:	55                   	push   %ebp
  800125:	89 e5                	mov    %esp,%ebp
  800127:	56                   	push   %esi
  800128:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800129:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80012c:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  800132:	e8 b2 0a 00 00       	call   800be9 <sys_getenvid>
  800137:	83 ec 0c             	sub    $0xc,%esp
  80013a:	ff 75 0c             	pushl  0xc(%ebp)
  80013d:	ff 75 08             	pushl  0x8(%ebp)
  800140:	53                   	push   %ebx
  800141:	50                   	push   %eax
  800142:	68 18 1f 80 00       	push   $0x801f18
  800147:	e8 b0 00 00 00       	call   8001fc <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80014c:	83 c4 18             	add    $0x18,%esp
  80014f:	56                   	push   %esi
  800150:	ff 75 10             	pushl  0x10(%ebp)
  800153:	e8 53 00 00 00       	call   8001ab <vcprintf>
	cprintf("\n");
  800158:	c7 04 24 97 23 80 00 	movl   $0x802397,(%esp)
  80015f:	e8 98 00 00 00       	call   8001fc <cprintf>
  800164:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800167:	cc                   	int3   
  800168:	eb fd                	jmp    800167 <_panic+0x43>
	...

0080016c <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80016c:	55                   	push   %ebp
  80016d:	89 e5                	mov    %esp,%ebp
  80016f:	53                   	push   %ebx
  800170:	83 ec 04             	sub    $0x4,%esp
  800173:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800176:	8b 03                	mov    (%ebx),%eax
  800178:	8b 55 08             	mov    0x8(%ebp),%edx
  80017b:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  80017f:	40                   	inc    %eax
  800180:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  800182:	3d ff 00 00 00       	cmp    $0xff,%eax
  800187:	75 1a                	jne    8001a3 <putch+0x37>
		sys_cputs(b->buf, b->idx);
  800189:	83 ec 08             	sub    $0x8,%esp
  80018c:	68 ff 00 00 00       	push   $0xff
  800191:	8d 43 08             	lea    0x8(%ebx),%eax
  800194:	50                   	push   %eax
  800195:	e8 e3 09 00 00       	call   800b7d <sys_cputs>
		b->idx = 0;
  80019a:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001a0:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8001a3:	ff 43 04             	incl   0x4(%ebx)
}
  8001a6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001a9:	c9                   	leave  
  8001aa:	c3                   	ret    

008001ab <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001ab:	55                   	push   %ebp
  8001ac:	89 e5                	mov    %esp,%ebp
  8001ae:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001b4:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001bb:	00 00 00 
	b.cnt = 0;
  8001be:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001c5:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001c8:	ff 75 0c             	pushl  0xc(%ebp)
  8001cb:	ff 75 08             	pushl  0x8(%ebp)
  8001ce:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001d4:	50                   	push   %eax
  8001d5:	68 6c 01 80 00       	push   $0x80016c
  8001da:	e8 82 01 00 00       	call   800361 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001df:	83 c4 08             	add    $0x8,%esp
  8001e2:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8001e8:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001ee:	50                   	push   %eax
  8001ef:	e8 89 09 00 00       	call   800b7d <sys_cputs>

	return b.cnt;
}
  8001f4:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001fa:	c9                   	leave  
  8001fb:	c3                   	ret    

008001fc <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001fc:	55                   	push   %ebp
  8001fd:	89 e5                	mov    %esp,%ebp
  8001ff:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800202:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800205:	50                   	push   %eax
  800206:	ff 75 08             	pushl  0x8(%ebp)
  800209:	e8 9d ff ff ff       	call   8001ab <vcprintf>
	va_end(ap);

	return cnt;
}
  80020e:	c9                   	leave  
  80020f:	c3                   	ret    

00800210 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800210:	55                   	push   %ebp
  800211:	89 e5                	mov    %esp,%ebp
  800213:	57                   	push   %edi
  800214:	56                   	push   %esi
  800215:	53                   	push   %ebx
  800216:	83 ec 2c             	sub    $0x2c,%esp
  800219:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80021c:	89 d6                	mov    %edx,%esi
  80021e:	8b 45 08             	mov    0x8(%ebp),%eax
  800221:	8b 55 0c             	mov    0xc(%ebp),%edx
  800224:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800227:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80022a:	8b 45 10             	mov    0x10(%ebp),%eax
  80022d:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800230:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800233:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800236:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  80023d:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
  800240:	72 0c                	jb     80024e <printnum+0x3e>
  800242:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  800245:	76 07                	jbe    80024e <printnum+0x3e>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800247:	4b                   	dec    %ebx
  800248:	85 db                	test   %ebx,%ebx
  80024a:	7f 31                	jg     80027d <printnum+0x6d>
  80024c:	eb 3f                	jmp    80028d <printnum+0x7d>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80024e:	83 ec 0c             	sub    $0xc,%esp
  800251:	57                   	push   %edi
  800252:	4b                   	dec    %ebx
  800253:	53                   	push   %ebx
  800254:	50                   	push   %eax
  800255:	83 ec 08             	sub    $0x8,%esp
  800258:	ff 75 d4             	pushl  -0x2c(%ebp)
  80025b:	ff 75 d0             	pushl  -0x30(%ebp)
  80025e:	ff 75 dc             	pushl  -0x24(%ebp)
  800261:	ff 75 d8             	pushl  -0x28(%ebp)
  800264:	e8 e7 19 00 00       	call   801c50 <__udivdi3>
  800269:	83 c4 18             	add    $0x18,%esp
  80026c:	52                   	push   %edx
  80026d:	50                   	push   %eax
  80026e:	89 f2                	mov    %esi,%edx
  800270:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800273:	e8 98 ff ff ff       	call   800210 <printnum>
  800278:	83 c4 20             	add    $0x20,%esp
  80027b:	eb 10                	jmp    80028d <printnum+0x7d>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80027d:	83 ec 08             	sub    $0x8,%esp
  800280:	56                   	push   %esi
  800281:	57                   	push   %edi
  800282:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800285:	4b                   	dec    %ebx
  800286:	83 c4 10             	add    $0x10,%esp
  800289:	85 db                	test   %ebx,%ebx
  80028b:	7f f0                	jg     80027d <printnum+0x6d>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80028d:	83 ec 08             	sub    $0x8,%esp
  800290:	56                   	push   %esi
  800291:	83 ec 04             	sub    $0x4,%esp
  800294:	ff 75 d4             	pushl  -0x2c(%ebp)
  800297:	ff 75 d0             	pushl  -0x30(%ebp)
  80029a:	ff 75 dc             	pushl  -0x24(%ebp)
  80029d:	ff 75 d8             	pushl  -0x28(%ebp)
  8002a0:	e8 c7 1a 00 00       	call   801d6c <__umoddi3>
  8002a5:	83 c4 14             	add    $0x14,%esp
  8002a8:	0f be 80 3b 1f 80 00 	movsbl 0x801f3b(%eax),%eax
  8002af:	50                   	push   %eax
  8002b0:	ff 55 e4             	call   *-0x1c(%ebp)
  8002b3:	83 c4 10             	add    $0x10,%esp
}
  8002b6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002b9:	5b                   	pop    %ebx
  8002ba:	5e                   	pop    %esi
  8002bb:	5f                   	pop    %edi
  8002bc:	c9                   	leave  
  8002bd:	c3                   	ret    

008002be <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002be:	55                   	push   %ebp
  8002bf:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002c1:	83 fa 01             	cmp    $0x1,%edx
  8002c4:	7e 0e                	jle    8002d4 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8002c6:	8b 10                	mov    (%eax),%edx
  8002c8:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002cb:	89 08                	mov    %ecx,(%eax)
  8002cd:	8b 02                	mov    (%edx),%eax
  8002cf:	8b 52 04             	mov    0x4(%edx),%edx
  8002d2:	eb 22                	jmp    8002f6 <getuint+0x38>
	else if (lflag)
  8002d4:	85 d2                	test   %edx,%edx
  8002d6:	74 10                	je     8002e8 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8002d8:	8b 10                	mov    (%eax),%edx
  8002da:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002dd:	89 08                	mov    %ecx,(%eax)
  8002df:	8b 02                	mov    (%edx),%eax
  8002e1:	ba 00 00 00 00       	mov    $0x0,%edx
  8002e6:	eb 0e                	jmp    8002f6 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8002e8:	8b 10                	mov    (%eax),%edx
  8002ea:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002ed:	89 08                	mov    %ecx,(%eax)
  8002ef:	8b 02                	mov    (%edx),%eax
  8002f1:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002f6:	c9                   	leave  
  8002f7:	c3                   	ret    

008002f8 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  8002f8:	55                   	push   %ebp
  8002f9:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002fb:	83 fa 01             	cmp    $0x1,%edx
  8002fe:	7e 0e                	jle    80030e <getint+0x16>
		return va_arg(*ap, long long);
  800300:	8b 10                	mov    (%eax),%edx
  800302:	8d 4a 08             	lea    0x8(%edx),%ecx
  800305:	89 08                	mov    %ecx,(%eax)
  800307:	8b 02                	mov    (%edx),%eax
  800309:	8b 52 04             	mov    0x4(%edx),%edx
  80030c:	eb 1a                	jmp    800328 <getint+0x30>
	else if (lflag)
  80030e:	85 d2                	test   %edx,%edx
  800310:	74 0c                	je     80031e <getint+0x26>
		return va_arg(*ap, long);
  800312:	8b 10                	mov    (%eax),%edx
  800314:	8d 4a 04             	lea    0x4(%edx),%ecx
  800317:	89 08                	mov    %ecx,(%eax)
  800319:	8b 02                	mov    (%edx),%eax
  80031b:	99                   	cltd   
  80031c:	eb 0a                	jmp    800328 <getint+0x30>
	else
		return va_arg(*ap, int);
  80031e:	8b 10                	mov    (%eax),%edx
  800320:	8d 4a 04             	lea    0x4(%edx),%ecx
  800323:	89 08                	mov    %ecx,(%eax)
  800325:	8b 02                	mov    (%edx),%eax
  800327:	99                   	cltd   
}
  800328:	c9                   	leave  
  800329:	c3                   	ret    

0080032a <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80032a:	55                   	push   %ebp
  80032b:	89 e5                	mov    %esp,%ebp
  80032d:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800330:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  800333:	8b 10                	mov    (%eax),%edx
  800335:	3b 50 04             	cmp    0x4(%eax),%edx
  800338:	73 08                	jae    800342 <sprintputch+0x18>
		*b->buf++ = ch;
  80033a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80033d:	88 0a                	mov    %cl,(%edx)
  80033f:	42                   	inc    %edx
  800340:	89 10                	mov    %edx,(%eax)
}
  800342:	c9                   	leave  
  800343:	c3                   	ret    

00800344 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800344:	55                   	push   %ebp
  800345:	89 e5                	mov    %esp,%ebp
  800347:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80034a:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80034d:	50                   	push   %eax
  80034e:	ff 75 10             	pushl  0x10(%ebp)
  800351:	ff 75 0c             	pushl  0xc(%ebp)
  800354:	ff 75 08             	pushl  0x8(%ebp)
  800357:	e8 05 00 00 00       	call   800361 <vprintfmt>
	va_end(ap);
  80035c:	83 c4 10             	add    $0x10,%esp
}
  80035f:	c9                   	leave  
  800360:	c3                   	ret    

00800361 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800361:	55                   	push   %ebp
  800362:	89 e5                	mov    %esp,%ebp
  800364:	57                   	push   %edi
  800365:	56                   	push   %esi
  800366:	53                   	push   %ebx
  800367:	83 ec 2c             	sub    $0x2c,%esp
  80036a:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80036d:	8b 75 10             	mov    0x10(%ebp),%esi
  800370:	eb 13                	jmp    800385 <vprintfmt+0x24>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800372:	85 c0                	test   %eax,%eax
  800374:	0f 84 6d 03 00 00    	je     8006e7 <vprintfmt+0x386>
				return;
			putch(ch, putdat);
  80037a:	83 ec 08             	sub    $0x8,%esp
  80037d:	57                   	push   %edi
  80037e:	50                   	push   %eax
  80037f:	ff 55 08             	call   *0x8(%ebp)
  800382:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800385:	0f b6 06             	movzbl (%esi),%eax
  800388:	46                   	inc    %esi
  800389:	83 f8 25             	cmp    $0x25,%eax
  80038c:	75 e4                	jne    800372 <vprintfmt+0x11>
  80038e:	c6 45 dc 20          	movb   $0x20,-0x24(%ebp)
  800392:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  800399:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  8003a0:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  8003a7:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003ac:	eb 28                	jmp    8003d6 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ae:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  8003b0:	c6 45 dc 2d          	movb   $0x2d,-0x24(%ebp)
  8003b4:	eb 20                	jmp    8003d6 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003b6:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8003b8:	c6 45 dc 30          	movb   $0x30,-0x24(%ebp)
  8003bc:	eb 18                	jmp    8003d6 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003be:	89 de                	mov    %ebx,%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  8003c0:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8003c7:	eb 0d                	jmp    8003d6 <vprintfmt+0x75>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  8003c9:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8003cc:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003cf:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003d6:	8a 06                	mov    (%esi),%al
  8003d8:	0f b6 d0             	movzbl %al,%edx
  8003db:	8d 5e 01             	lea    0x1(%esi),%ebx
  8003de:	83 e8 23             	sub    $0x23,%eax
  8003e1:	3c 55                	cmp    $0x55,%al
  8003e3:	0f 87 e0 02 00 00    	ja     8006c9 <vprintfmt+0x368>
  8003e9:	0f b6 c0             	movzbl %al,%eax
  8003ec:	ff 24 85 80 20 80 00 	jmp    *0x802080(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003f3:	83 ea 30             	sub    $0x30,%edx
  8003f6:	89 55 d4             	mov    %edx,-0x2c(%ebp)
				ch = *fmt;
  8003f9:	0f be 03             	movsbl (%ebx),%eax
				if (ch < '0' || ch > '9')
  8003fc:	8d 50 d0             	lea    -0x30(%eax),%edx
  8003ff:	83 fa 09             	cmp    $0x9,%edx
  800402:	77 44                	ja     800448 <vprintfmt+0xe7>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800404:	89 de                	mov    %ebx,%esi
  800406:	8b 55 d4             	mov    -0x2c(%ebp),%edx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800409:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
  80040a:	8d 14 92             	lea    (%edx,%edx,4),%edx
  80040d:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
  800411:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800414:	8d 58 d0             	lea    -0x30(%eax),%ebx
  800417:	83 fb 09             	cmp    $0x9,%ebx
  80041a:	76 ed                	jbe    800409 <vprintfmt+0xa8>
  80041c:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  80041f:	eb 29                	jmp    80044a <vprintfmt+0xe9>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800421:	8b 45 14             	mov    0x14(%ebp),%eax
  800424:	8d 50 04             	lea    0x4(%eax),%edx
  800427:	89 55 14             	mov    %edx,0x14(%ebp)
  80042a:	8b 00                	mov    (%eax),%eax
  80042c:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80042f:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800431:	eb 17                	jmp    80044a <vprintfmt+0xe9>

		case '.':
			if (width < 0)
  800433:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800437:	78 85                	js     8003be <vprintfmt+0x5d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800439:	89 de                	mov    %ebx,%esi
  80043b:	eb 99                	jmp    8003d6 <vprintfmt+0x75>
  80043d:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80043f:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  800446:	eb 8e                	jmp    8003d6 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800448:	89 de                	mov    %ebx,%esi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  80044a:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80044e:	79 86                	jns    8003d6 <vprintfmt+0x75>
  800450:	e9 74 ff ff ff       	jmp    8003c9 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800455:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800456:	89 de                	mov    %ebx,%esi
  800458:	e9 79 ff ff ff       	jmp    8003d6 <vprintfmt+0x75>
  80045d:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800460:	8b 45 14             	mov    0x14(%ebp),%eax
  800463:	8d 50 04             	lea    0x4(%eax),%edx
  800466:	89 55 14             	mov    %edx,0x14(%ebp)
  800469:	83 ec 08             	sub    $0x8,%esp
  80046c:	57                   	push   %edi
  80046d:	ff 30                	pushl  (%eax)
  80046f:	ff 55 08             	call   *0x8(%ebp)
			break;
  800472:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800475:	8b 75 d8             	mov    -0x28(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800478:	e9 08 ff ff ff       	jmp    800385 <vprintfmt+0x24>
  80047d:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  800480:	8b 45 14             	mov    0x14(%ebp),%eax
  800483:	8d 50 04             	lea    0x4(%eax),%edx
  800486:	89 55 14             	mov    %edx,0x14(%ebp)
  800489:	8b 00                	mov    (%eax),%eax
  80048b:	85 c0                	test   %eax,%eax
  80048d:	79 02                	jns    800491 <vprintfmt+0x130>
  80048f:	f7 d8                	neg    %eax
  800491:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800493:	83 f8 0f             	cmp    $0xf,%eax
  800496:	7f 0b                	jg     8004a3 <vprintfmt+0x142>
  800498:	8b 04 85 e0 21 80 00 	mov    0x8021e0(,%eax,4),%eax
  80049f:	85 c0                	test   %eax,%eax
  8004a1:	75 1a                	jne    8004bd <vprintfmt+0x15c>
				printfmt(putch, putdat, "error %d", err);
  8004a3:	52                   	push   %edx
  8004a4:	68 53 1f 80 00       	push   $0x801f53
  8004a9:	57                   	push   %edi
  8004aa:	ff 75 08             	pushl  0x8(%ebp)
  8004ad:	e8 92 fe ff ff       	call   800344 <printfmt>
  8004b2:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004b5:	8b 75 d8             	mov    -0x28(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8004b8:	e9 c8 fe ff ff       	jmp    800385 <vprintfmt+0x24>
			else
				printfmt(putch, putdat, "%s", p);
  8004bd:	50                   	push   %eax
  8004be:	68 65 23 80 00       	push   $0x802365
  8004c3:	57                   	push   %edi
  8004c4:	ff 75 08             	pushl  0x8(%ebp)
  8004c7:	e8 78 fe ff ff       	call   800344 <printfmt>
  8004cc:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004cf:	8b 75 d8             	mov    -0x28(%ebp),%esi
  8004d2:	e9 ae fe ff ff       	jmp    800385 <vprintfmt+0x24>
  8004d7:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  8004da:	89 de                	mov    %ebx,%esi
  8004dc:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  8004df:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004e2:	8b 45 14             	mov    0x14(%ebp),%eax
  8004e5:	8d 50 04             	lea    0x4(%eax),%edx
  8004e8:	89 55 14             	mov    %edx,0x14(%ebp)
  8004eb:	8b 00                	mov    (%eax),%eax
  8004ed:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8004f0:	85 c0                	test   %eax,%eax
  8004f2:	75 07                	jne    8004fb <vprintfmt+0x19a>
				p = "(null)";
  8004f4:	c7 45 d0 4c 1f 80 00 	movl   $0x801f4c,-0x30(%ebp)
			if (width > 0 && padc != '-')
  8004fb:	85 db                	test   %ebx,%ebx
  8004fd:	7e 42                	jle    800541 <vprintfmt+0x1e0>
  8004ff:	80 7d dc 2d          	cmpb   $0x2d,-0x24(%ebp)
  800503:	74 3c                	je     800541 <vprintfmt+0x1e0>
				for (width -= strnlen(p, precision); width > 0; width--)
  800505:	83 ec 08             	sub    $0x8,%esp
  800508:	51                   	push   %ecx
  800509:	ff 75 d0             	pushl  -0x30(%ebp)
  80050c:	e8 6f 02 00 00       	call   800780 <strnlen>
  800511:	29 c3                	sub    %eax,%ebx
  800513:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800516:	83 c4 10             	add    $0x10,%esp
  800519:	85 db                	test   %ebx,%ebx
  80051b:	7e 24                	jle    800541 <vprintfmt+0x1e0>
					putch(padc, putdat);
  80051d:	0f be 5d dc          	movsbl -0x24(%ebp),%ebx
  800521:	89 75 dc             	mov    %esi,-0x24(%ebp)
  800524:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  800527:	83 ec 08             	sub    $0x8,%esp
  80052a:	57                   	push   %edi
  80052b:	53                   	push   %ebx
  80052c:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80052f:	4e                   	dec    %esi
  800530:	83 c4 10             	add    $0x10,%esp
  800533:	85 f6                	test   %esi,%esi
  800535:	7f f0                	jg     800527 <vprintfmt+0x1c6>
  800537:	8b 75 dc             	mov    -0x24(%ebp),%esi
  80053a:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800541:	8b 55 d0             	mov    -0x30(%ebp),%edx
  800544:	0f be 02             	movsbl (%edx),%eax
  800547:	85 c0                	test   %eax,%eax
  800549:	75 47                	jne    800592 <vprintfmt+0x231>
  80054b:	eb 37                	jmp    800584 <vprintfmt+0x223>
				if (altflag && (ch < ' ' || ch > '~'))
  80054d:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800551:	74 16                	je     800569 <vprintfmt+0x208>
  800553:	8d 50 e0             	lea    -0x20(%eax),%edx
  800556:	83 fa 5e             	cmp    $0x5e,%edx
  800559:	76 0e                	jbe    800569 <vprintfmt+0x208>
					putch('?', putdat);
  80055b:	83 ec 08             	sub    $0x8,%esp
  80055e:	57                   	push   %edi
  80055f:	6a 3f                	push   $0x3f
  800561:	ff 55 08             	call   *0x8(%ebp)
  800564:	83 c4 10             	add    $0x10,%esp
  800567:	eb 0b                	jmp    800574 <vprintfmt+0x213>
				else
					putch(ch, putdat);
  800569:	83 ec 08             	sub    $0x8,%esp
  80056c:	57                   	push   %edi
  80056d:	50                   	push   %eax
  80056e:	ff 55 08             	call   *0x8(%ebp)
  800571:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800574:	ff 4d e4             	decl   -0x1c(%ebp)
  800577:	0f be 03             	movsbl (%ebx),%eax
  80057a:	85 c0                	test   %eax,%eax
  80057c:	74 03                	je     800581 <vprintfmt+0x220>
  80057e:	43                   	inc    %ebx
  80057f:	eb 1b                	jmp    80059c <vprintfmt+0x23b>
  800581:	8b 75 dc             	mov    -0x24(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800584:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800588:	7f 1e                	jg     8005a8 <vprintfmt+0x247>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80058a:	8b 75 d8             	mov    -0x28(%ebp),%esi
  80058d:	e9 f3 fd ff ff       	jmp    800385 <vprintfmt+0x24>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800592:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800595:	43                   	inc    %ebx
  800596:	89 75 dc             	mov    %esi,-0x24(%ebp)
  800599:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  80059c:	85 f6                	test   %esi,%esi
  80059e:	78 ad                	js     80054d <vprintfmt+0x1ec>
  8005a0:	4e                   	dec    %esi
  8005a1:	79 aa                	jns    80054d <vprintfmt+0x1ec>
  8005a3:	8b 75 dc             	mov    -0x24(%ebp),%esi
  8005a6:	eb dc                	jmp    800584 <vprintfmt+0x223>
  8005a8:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8005ab:	83 ec 08             	sub    $0x8,%esp
  8005ae:	57                   	push   %edi
  8005af:	6a 20                	push   $0x20
  8005b1:	ff 55 08             	call   *0x8(%ebp)
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005b4:	4b                   	dec    %ebx
  8005b5:	83 c4 10             	add    $0x10,%esp
  8005b8:	85 db                	test   %ebx,%ebx
  8005ba:	7f ef                	jg     8005ab <vprintfmt+0x24a>
  8005bc:	e9 c4 fd ff ff       	jmp    800385 <vprintfmt+0x24>
  8005c1:	89 5d d8             	mov    %ebx,-0x28(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8005c4:	89 ca                	mov    %ecx,%edx
  8005c6:	8d 45 14             	lea    0x14(%ebp),%eax
  8005c9:	e8 2a fd ff ff       	call   8002f8 <getint>
  8005ce:	89 c3                	mov    %eax,%ebx
  8005d0:	89 d6                	mov    %edx,%esi
			if ((long long) num < 0) {
  8005d2:	85 d2                	test   %edx,%edx
  8005d4:	78 0a                	js     8005e0 <vprintfmt+0x27f>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8005d6:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005db:	e9 b0 00 00 00       	jmp    800690 <vprintfmt+0x32f>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  8005e0:	83 ec 08             	sub    $0x8,%esp
  8005e3:	57                   	push   %edi
  8005e4:	6a 2d                	push   $0x2d
  8005e6:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8005e9:	f7 db                	neg    %ebx
  8005eb:	83 d6 00             	adc    $0x0,%esi
  8005ee:	f7 de                	neg    %esi
  8005f0:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8005f3:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005f8:	e9 93 00 00 00       	jmp    800690 <vprintfmt+0x32f>
  8005fd:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800600:	89 ca                	mov    %ecx,%edx
  800602:	8d 45 14             	lea    0x14(%ebp),%eax
  800605:	e8 b4 fc ff ff       	call   8002be <getuint>
  80060a:	89 c3                	mov    %eax,%ebx
  80060c:	89 d6                	mov    %edx,%esi
			base = 10;
  80060e:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  800613:	eb 7b                	jmp    800690 <vprintfmt+0x32f>
  800615:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
  800618:	89 ca                	mov    %ecx,%edx
  80061a:	8d 45 14             	lea    0x14(%ebp),%eax
  80061d:	e8 d6 fc ff ff       	call   8002f8 <getint>
  800622:	89 c3                	mov    %eax,%ebx
  800624:	89 d6                	mov    %edx,%esi
            if ((long long) num < 0) {
  800626:	85 d2                	test   %edx,%edx
  800628:	78 07                	js     800631 <vprintfmt+0x2d0>
                putch('-', putdat);
                num = -(long long) num;
            }
            base = 8;
  80062a:	b8 08 00 00 00       	mov    $0x8,%eax
  80062f:	eb 5f                	jmp    800690 <vprintfmt+0x32f>
		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
            if ((long long) num < 0) {
                putch('-', putdat);
  800631:	83 ec 08             	sub    $0x8,%esp
  800634:	57                   	push   %edi
  800635:	6a 2d                	push   $0x2d
  800637:	ff 55 08             	call   *0x8(%ebp)
                num = -(long long) num;
  80063a:	f7 db                	neg    %ebx
  80063c:	83 d6 00             	adc    $0x0,%esi
  80063f:	f7 de                	neg    %esi
  800641:	83 c4 10             	add    $0x10,%esp
            }
            base = 8;
  800644:	b8 08 00 00 00       	mov    $0x8,%eax
  800649:	eb 45                	jmp    800690 <vprintfmt+0x32f>
  80064b:	89 5d d8             	mov    %ebx,-0x28(%ebp)
            goto number;

        // pointer
		case 'p':
			putch('0', putdat);
  80064e:	83 ec 08             	sub    $0x8,%esp
  800651:	57                   	push   %edi
  800652:	6a 30                	push   $0x30
  800654:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800657:	83 c4 08             	add    $0x8,%esp
  80065a:	57                   	push   %edi
  80065b:	6a 78                	push   $0x78
  80065d:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800660:	8b 45 14             	mov    0x14(%ebp),%eax
  800663:	8d 50 04             	lea    0x4(%eax),%edx
  800666:	89 55 14             	mov    %edx,0x14(%ebp)

        // pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800669:	8b 18                	mov    (%eax),%ebx
  80066b:	be 00 00 00 00       	mov    $0x0,%esi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800670:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800673:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800678:	eb 16                	jmp    800690 <vprintfmt+0x32f>
  80067a:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80067d:	89 ca                	mov    %ecx,%edx
  80067f:	8d 45 14             	lea    0x14(%ebp),%eax
  800682:	e8 37 fc ff ff       	call   8002be <getuint>
  800687:	89 c3                	mov    %eax,%ebx
  800689:	89 d6                	mov    %edx,%esi
			base = 16;
  80068b:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800690:	83 ec 0c             	sub    $0xc,%esp
  800693:	0f be 55 dc          	movsbl -0x24(%ebp),%edx
  800697:	52                   	push   %edx
  800698:	ff 75 e4             	pushl  -0x1c(%ebp)
  80069b:	50                   	push   %eax
  80069c:	56                   	push   %esi
  80069d:	53                   	push   %ebx
  80069e:	89 fa                	mov    %edi,%edx
  8006a0:	8b 45 08             	mov    0x8(%ebp),%eax
  8006a3:	e8 68 fb ff ff       	call   800210 <printnum>
			break;
  8006a8:	83 c4 20             	add    $0x20,%esp
  8006ab:	8b 75 d8             	mov    -0x28(%ebp),%esi
  8006ae:	e9 d2 fc ff ff       	jmp    800385 <vprintfmt+0x24>
  8006b3:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006b6:	83 ec 08             	sub    $0x8,%esp
  8006b9:	57                   	push   %edi
  8006ba:	52                   	push   %edx
  8006bb:	ff 55 08             	call   *0x8(%ebp)
			break;
  8006be:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006c1:	8b 75 d8             	mov    -0x28(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8006c4:	e9 bc fc ff ff       	jmp    800385 <vprintfmt+0x24>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8006c9:	83 ec 08             	sub    $0x8,%esp
  8006cc:	57                   	push   %edi
  8006cd:	6a 25                	push   $0x25
  8006cf:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006d2:	83 c4 10             	add    $0x10,%esp
  8006d5:	eb 02                	jmp    8006d9 <vprintfmt+0x378>
  8006d7:	89 c6                	mov    %eax,%esi
  8006d9:	8d 46 ff             	lea    -0x1(%esi),%eax
  8006dc:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  8006e0:	75 f5                	jne    8006d7 <vprintfmt+0x376>
  8006e2:	e9 9e fc ff ff       	jmp    800385 <vprintfmt+0x24>
				/* do nothing */;
			break;
		}
	}
}
  8006e7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006ea:	5b                   	pop    %ebx
  8006eb:	5e                   	pop    %esi
  8006ec:	5f                   	pop    %edi
  8006ed:	c9                   	leave  
  8006ee:	c3                   	ret    

008006ef <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006ef:	55                   	push   %ebp
  8006f0:	89 e5                	mov    %esp,%ebp
  8006f2:	83 ec 18             	sub    $0x18,%esp
  8006f5:	8b 45 08             	mov    0x8(%ebp),%eax
  8006f8:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006fb:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006fe:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800702:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800705:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80070c:	85 c0                	test   %eax,%eax
  80070e:	74 26                	je     800736 <vsnprintf+0x47>
  800710:	85 d2                	test   %edx,%edx
  800712:	7e 29                	jle    80073d <vsnprintf+0x4e>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800714:	ff 75 14             	pushl  0x14(%ebp)
  800717:	ff 75 10             	pushl  0x10(%ebp)
  80071a:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80071d:	50                   	push   %eax
  80071e:	68 2a 03 80 00       	push   $0x80032a
  800723:	e8 39 fc ff ff       	call   800361 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800728:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80072b:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80072e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800731:	83 c4 10             	add    $0x10,%esp
  800734:	eb 0c                	jmp    800742 <vsnprintf+0x53>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800736:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80073b:	eb 05                	jmp    800742 <vsnprintf+0x53>
  80073d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800742:	c9                   	leave  
  800743:	c3                   	ret    

00800744 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800744:	55                   	push   %ebp
  800745:	89 e5                	mov    %esp,%ebp
  800747:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80074a:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80074d:	50                   	push   %eax
  80074e:	ff 75 10             	pushl  0x10(%ebp)
  800751:	ff 75 0c             	pushl  0xc(%ebp)
  800754:	ff 75 08             	pushl  0x8(%ebp)
  800757:	e8 93 ff ff ff       	call   8006ef <vsnprintf>
	va_end(ap);

	return rc;
}
  80075c:	c9                   	leave  
  80075d:	c3                   	ret    
	...

00800760 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800760:	55                   	push   %ebp
  800761:	89 e5                	mov    %esp,%ebp
  800763:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800766:	80 3a 00             	cmpb   $0x0,(%edx)
  800769:	74 0e                	je     800779 <strlen+0x19>
  80076b:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800770:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800771:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800775:	75 f9                	jne    800770 <strlen+0x10>
  800777:	eb 05                	jmp    80077e <strlen+0x1e>
  800779:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  80077e:	c9                   	leave  
  80077f:	c3                   	ret    

00800780 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800780:	55                   	push   %ebp
  800781:	89 e5                	mov    %esp,%ebp
  800783:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800786:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800789:	85 d2                	test   %edx,%edx
  80078b:	74 17                	je     8007a4 <strnlen+0x24>
  80078d:	80 39 00             	cmpb   $0x0,(%ecx)
  800790:	74 19                	je     8007ab <strnlen+0x2b>
  800792:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800797:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800798:	39 d0                	cmp    %edx,%eax
  80079a:	74 14                	je     8007b0 <strnlen+0x30>
  80079c:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8007a0:	75 f5                	jne    800797 <strnlen+0x17>
  8007a2:	eb 0c                	jmp    8007b0 <strnlen+0x30>
  8007a4:	b8 00 00 00 00       	mov    $0x0,%eax
  8007a9:	eb 05                	jmp    8007b0 <strnlen+0x30>
  8007ab:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  8007b0:	c9                   	leave  
  8007b1:	c3                   	ret    

008007b2 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007b2:	55                   	push   %ebp
  8007b3:	89 e5                	mov    %esp,%ebp
  8007b5:	53                   	push   %ebx
  8007b6:	8b 45 08             	mov    0x8(%ebp),%eax
  8007b9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007bc:	ba 00 00 00 00       	mov    $0x0,%edx
  8007c1:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  8007c4:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  8007c7:	42                   	inc    %edx
  8007c8:	84 c9                	test   %cl,%cl
  8007ca:	75 f5                	jne    8007c1 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8007cc:	5b                   	pop    %ebx
  8007cd:	c9                   	leave  
  8007ce:	c3                   	ret    

008007cf <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007cf:	55                   	push   %ebp
  8007d0:	89 e5                	mov    %esp,%ebp
  8007d2:	53                   	push   %ebx
  8007d3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007d6:	53                   	push   %ebx
  8007d7:	e8 84 ff ff ff       	call   800760 <strlen>
  8007dc:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8007df:	ff 75 0c             	pushl  0xc(%ebp)
  8007e2:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  8007e5:	50                   	push   %eax
  8007e6:	e8 c7 ff ff ff       	call   8007b2 <strcpy>
	return dst;
}
  8007eb:	89 d8                	mov    %ebx,%eax
  8007ed:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007f0:	c9                   	leave  
  8007f1:	c3                   	ret    

008007f2 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007f2:	55                   	push   %ebp
  8007f3:	89 e5                	mov    %esp,%ebp
  8007f5:	56                   	push   %esi
  8007f6:	53                   	push   %ebx
  8007f7:	8b 45 08             	mov    0x8(%ebp),%eax
  8007fa:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007fd:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800800:	85 f6                	test   %esi,%esi
  800802:	74 15                	je     800819 <strncpy+0x27>
  800804:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  800809:	8a 1a                	mov    (%edx),%bl
  80080b:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80080e:	80 3a 01             	cmpb   $0x1,(%edx)
  800811:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800814:	41                   	inc    %ecx
  800815:	39 ce                	cmp    %ecx,%esi
  800817:	77 f0                	ja     800809 <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800819:	5b                   	pop    %ebx
  80081a:	5e                   	pop    %esi
  80081b:	c9                   	leave  
  80081c:	c3                   	ret    

0080081d <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80081d:	55                   	push   %ebp
  80081e:	89 e5                	mov    %esp,%ebp
  800820:	57                   	push   %edi
  800821:	56                   	push   %esi
  800822:	53                   	push   %ebx
  800823:	8b 7d 08             	mov    0x8(%ebp),%edi
  800826:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800829:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80082c:	85 f6                	test   %esi,%esi
  80082e:	74 32                	je     800862 <strlcpy+0x45>
		while (--size > 0 && *src != '\0')
  800830:	83 fe 01             	cmp    $0x1,%esi
  800833:	74 22                	je     800857 <strlcpy+0x3a>
  800835:	8a 0b                	mov    (%ebx),%cl
  800837:	84 c9                	test   %cl,%cl
  800839:	74 20                	je     80085b <strlcpy+0x3e>
  80083b:	89 f8                	mov    %edi,%eax
  80083d:	ba 00 00 00 00       	mov    $0x0,%edx
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
  800842:	83 ee 02             	sub    $0x2,%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800845:	88 08                	mov    %cl,(%eax)
  800847:	40                   	inc    %eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800848:	39 f2                	cmp    %esi,%edx
  80084a:	74 11                	je     80085d <strlcpy+0x40>
  80084c:	8a 4c 13 01          	mov    0x1(%ebx,%edx,1),%cl
  800850:	42                   	inc    %edx
  800851:	84 c9                	test   %cl,%cl
  800853:	75 f0                	jne    800845 <strlcpy+0x28>
  800855:	eb 06                	jmp    80085d <strlcpy+0x40>
  800857:	89 f8                	mov    %edi,%eax
  800859:	eb 02                	jmp    80085d <strlcpy+0x40>
  80085b:	89 f8                	mov    %edi,%eax
			*dst++ = *src++;
		*dst = '\0';
  80085d:	c6 00 00             	movb   $0x0,(%eax)
  800860:	eb 02                	jmp    800864 <strlcpy+0x47>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800862:	89 f8                	mov    %edi,%eax
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
		*dst = '\0';
	}
	return dst - dst_in;
  800864:	29 f8                	sub    %edi,%eax
}
  800866:	5b                   	pop    %ebx
  800867:	5e                   	pop    %esi
  800868:	5f                   	pop    %edi
  800869:	c9                   	leave  
  80086a:	c3                   	ret    

0080086b <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80086b:	55                   	push   %ebp
  80086c:	89 e5                	mov    %esp,%ebp
  80086e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800871:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800874:	8a 01                	mov    (%ecx),%al
  800876:	84 c0                	test   %al,%al
  800878:	74 10                	je     80088a <strcmp+0x1f>
  80087a:	3a 02                	cmp    (%edx),%al
  80087c:	75 0c                	jne    80088a <strcmp+0x1f>
		p++, q++;
  80087e:	41                   	inc    %ecx
  80087f:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800880:	8a 01                	mov    (%ecx),%al
  800882:	84 c0                	test   %al,%al
  800884:	74 04                	je     80088a <strcmp+0x1f>
  800886:	3a 02                	cmp    (%edx),%al
  800888:	74 f4                	je     80087e <strcmp+0x13>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80088a:	0f b6 c0             	movzbl %al,%eax
  80088d:	0f b6 12             	movzbl (%edx),%edx
  800890:	29 d0                	sub    %edx,%eax
}
  800892:	c9                   	leave  
  800893:	c3                   	ret    

00800894 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800894:	55                   	push   %ebp
  800895:	89 e5                	mov    %esp,%ebp
  800897:	53                   	push   %ebx
  800898:	8b 55 08             	mov    0x8(%ebp),%edx
  80089b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80089e:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  8008a1:	85 c0                	test   %eax,%eax
  8008a3:	74 1b                	je     8008c0 <strncmp+0x2c>
  8008a5:	8a 1a                	mov    (%edx),%bl
  8008a7:	84 db                	test   %bl,%bl
  8008a9:	74 24                	je     8008cf <strncmp+0x3b>
  8008ab:	3a 19                	cmp    (%ecx),%bl
  8008ad:	75 20                	jne    8008cf <strncmp+0x3b>
  8008af:	48                   	dec    %eax
  8008b0:	74 15                	je     8008c7 <strncmp+0x33>
		n--, p++, q++;
  8008b2:	42                   	inc    %edx
  8008b3:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8008b4:	8a 1a                	mov    (%edx),%bl
  8008b6:	84 db                	test   %bl,%bl
  8008b8:	74 15                	je     8008cf <strncmp+0x3b>
  8008ba:	3a 19                	cmp    (%ecx),%bl
  8008bc:	74 f1                	je     8008af <strncmp+0x1b>
  8008be:	eb 0f                	jmp    8008cf <strncmp+0x3b>
		n--, p++, q++;
	if (n == 0)
		return 0;
  8008c0:	b8 00 00 00 00       	mov    $0x0,%eax
  8008c5:	eb 05                	jmp    8008cc <strncmp+0x38>
  8008c7:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8008cc:	5b                   	pop    %ebx
  8008cd:	c9                   	leave  
  8008ce:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008cf:	0f b6 02             	movzbl (%edx),%eax
  8008d2:	0f b6 11             	movzbl (%ecx),%edx
  8008d5:	29 d0                	sub    %edx,%eax
  8008d7:	eb f3                	jmp    8008cc <strncmp+0x38>

008008d9 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008d9:	55                   	push   %ebp
  8008da:	89 e5                	mov    %esp,%ebp
  8008dc:	8b 45 08             	mov    0x8(%ebp),%eax
  8008df:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8008e2:	8a 10                	mov    (%eax),%dl
  8008e4:	84 d2                	test   %dl,%dl
  8008e6:	74 18                	je     800900 <strchr+0x27>
		if (*s == c)
  8008e8:	38 ca                	cmp    %cl,%dl
  8008ea:	75 06                	jne    8008f2 <strchr+0x19>
  8008ec:	eb 17                	jmp    800905 <strchr+0x2c>
  8008ee:	38 ca                	cmp    %cl,%dl
  8008f0:	74 13                	je     800905 <strchr+0x2c>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8008f2:	40                   	inc    %eax
  8008f3:	8a 10                	mov    (%eax),%dl
  8008f5:	84 d2                	test   %dl,%dl
  8008f7:	75 f5                	jne    8008ee <strchr+0x15>
		if (*s == c)
			return (char *) s;
	return 0;
  8008f9:	b8 00 00 00 00       	mov    $0x0,%eax
  8008fe:	eb 05                	jmp    800905 <strchr+0x2c>
  800900:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800905:	c9                   	leave  
  800906:	c3                   	ret    

00800907 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800907:	55                   	push   %ebp
  800908:	89 e5                	mov    %esp,%ebp
  80090a:	8b 45 08             	mov    0x8(%ebp),%eax
  80090d:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800910:	8a 10                	mov    (%eax),%dl
  800912:	84 d2                	test   %dl,%dl
  800914:	74 11                	je     800927 <strfind+0x20>
		if (*s == c)
  800916:	38 ca                	cmp    %cl,%dl
  800918:	75 06                	jne    800920 <strfind+0x19>
  80091a:	eb 0b                	jmp    800927 <strfind+0x20>
  80091c:	38 ca                	cmp    %cl,%dl
  80091e:	74 07                	je     800927 <strfind+0x20>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800920:	40                   	inc    %eax
  800921:	8a 10                	mov    (%eax),%dl
  800923:	84 d2                	test   %dl,%dl
  800925:	75 f5                	jne    80091c <strfind+0x15>
		if (*s == c)
			break;
	return (char *) s;
}
  800927:	c9                   	leave  
  800928:	c3                   	ret    

00800929 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800929:	55                   	push   %ebp
  80092a:	89 e5                	mov    %esp,%ebp
  80092c:	57                   	push   %edi
  80092d:	56                   	push   %esi
  80092e:	53                   	push   %ebx
  80092f:	8b 7d 08             	mov    0x8(%ebp),%edi
  800932:	8b 45 0c             	mov    0xc(%ebp),%eax
  800935:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800938:	85 c9                	test   %ecx,%ecx
  80093a:	74 30                	je     80096c <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80093c:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800942:	75 25                	jne    800969 <memset+0x40>
  800944:	f6 c1 03             	test   $0x3,%cl
  800947:	75 20                	jne    800969 <memset+0x40>
		c &= 0xFF;
  800949:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80094c:	89 d3                	mov    %edx,%ebx
  80094e:	c1 e3 08             	shl    $0x8,%ebx
  800951:	89 d6                	mov    %edx,%esi
  800953:	c1 e6 18             	shl    $0x18,%esi
  800956:	89 d0                	mov    %edx,%eax
  800958:	c1 e0 10             	shl    $0x10,%eax
  80095b:	09 f0                	or     %esi,%eax
  80095d:	09 d0                	or     %edx,%eax
  80095f:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800961:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800964:	fc                   	cld    
  800965:	f3 ab                	rep stos %eax,%es:(%edi)
  800967:	eb 03                	jmp    80096c <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800969:	fc                   	cld    
  80096a:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80096c:	89 f8                	mov    %edi,%eax
  80096e:	5b                   	pop    %ebx
  80096f:	5e                   	pop    %esi
  800970:	5f                   	pop    %edi
  800971:	c9                   	leave  
  800972:	c3                   	ret    

00800973 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800973:	55                   	push   %ebp
  800974:	89 e5                	mov    %esp,%ebp
  800976:	57                   	push   %edi
  800977:	56                   	push   %esi
  800978:	8b 45 08             	mov    0x8(%ebp),%eax
  80097b:	8b 75 0c             	mov    0xc(%ebp),%esi
  80097e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800981:	39 c6                	cmp    %eax,%esi
  800983:	73 34                	jae    8009b9 <memmove+0x46>
  800985:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800988:	39 d0                	cmp    %edx,%eax
  80098a:	73 2d                	jae    8009b9 <memmove+0x46>
		s += n;
		d += n;
  80098c:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80098f:	f6 c2 03             	test   $0x3,%dl
  800992:	75 1b                	jne    8009af <memmove+0x3c>
  800994:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80099a:	75 13                	jne    8009af <memmove+0x3c>
  80099c:	f6 c1 03             	test   $0x3,%cl
  80099f:	75 0e                	jne    8009af <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8009a1:	83 ef 04             	sub    $0x4,%edi
  8009a4:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009a7:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  8009aa:	fd                   	std    
  8009ab:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009ad:	eb 07                	jmp    8009b6 <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8009af:	4f                   	dec    %edi
  8009b0:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8009b3:	fd                   	std    
  8009b4:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009b6:	fc                   	cld    
  8009b7:	eb 20                	jmp    8009d9 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009b9:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009bf:	75 13                	jne    8009d4 <memmove+0x61>
  8009c1:	a8 03                	test   $0x3,%al
  8009c3:	75 0f                	jne    8009d4 <memmove+0x61>
  8009c5:	f6 c1 03             	test   $0x3,%cl
  8009c8:	75 0a                	jne    8009d4 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8009ca:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  8009cd:	89 c7                	mov    %eax,%edi
  8009cf:	fc                   	cld    
  8009d0:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009d2:	eb 05                	jmp    8009d9 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8009d4:	89 c7                	mov    %eax,%edi
  8009d6:	fc                   	cld    
  8009d7:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009d9:	5e                   	pop    %esi
  8009da:	5f                   	pop    %edi
  8009db:	c9                   	leave  
  8009dc:	c3                   	ret    

008009dd <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009dd:	55                   	push   %ebp
  8009de:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8009e0:	ff 75 10             	pushl  0x10(%ebp)
  8009e3:	ff 75 0c             	pushl  0xc(%ebp)
  8009e6:	ff 75 08             	pushl  0x8(%ebp)
  8009e9:	e8 85 ff ff ff       	call   800973 <memmove>
}
  8009ee:	c9                   	leave  
  8009ef:	c3                   	ret    

008009f0 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009f0:	55                   	push   %ebp
  8009f1:	89 e5                	mov    %esp,%ebp
  8009f3:	57                   	push   %edi
  8009f4:	56                   	push   %esi
  8009f5:	53                   	push   %ebx
  8009f6:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8009f9:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009fc:	8b 7d 10             	mov    0x10(%ebp),%edi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009ff:	85 ff                	test   %edi,%edi
  800a01:	74 32                	je     800a35 <memcmp+0x45>
		if (*s1 != *s2)
  800a03:	8a 03                	mov    (%ebx),%al
  800a05:	8a 0e                	mov    (%esi),%cl
  800a07:	38 c8                	cmp    %cl,%al
  800a09:	74 19                	je     800a24 <memcmp+0x34>
  800a0b:	eb 0d                	jmp    800a1a <memcmp+0x2a>
  800a0d:	8a 44 13 01          	mov    0x1(%ebx,%edx,1),%al
  800a11:	8a 4c 16 01          	mov    0x1(%esi,%edx,1),%cl
  800a15:	42                   	inc    %edx
  800a16:	38 c8                	cmp    %cl,%al
  800a18:	74 10                	je     800a2a <memcmp+0x3a>
			return (int) *s1 - (int) *s2;
  800a1a:	0f b6 c0             	movzbl %al,%eax
  800a1d:	0f b6 c9             	movzbl %cl,%ecx
  800a20:	29 c8                	sub    %ecx,%eax
  800a22:	eb 16                	jmp    800a3a <memcmp+0x4a>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a24:	4f                   	dec    %edi
  800a25:	ba 00 00 00 00       	mov    $0x0,%edx
  800a2a:	39 fa                	cmp    %edi,%edx
  800a2c:	75 df                	jne    800a0d <memcmp+0x1d>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a2e:	b8 00 00 00 00       	mov    $0x0,%eax
  800a33:	eb 05                	jmp    800a3a <memcmp+0x4a>
  800a35:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a3a:	5b                   	pop    %ebx
  800a3b:	5e                   	pop    %esi
  800a3c:	5f                   	pop    %edi
  800a3d:	c9                   	leave  
  800a3e:	c3                   	ret    

00800a3f <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a3f:	55                   	push   %ebp
  800a40:	89 e5                	mov    %esp,%ebp
  800a42:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800a45:	89 c2                	mov    %eax,%edx
  800a47:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a4a:	39 d0                	cmp    %edx,%eax
  800a4c:	73 12                	jae    800a60 <memfind+0x21>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a4e:	8a 4d 0c             	mov    0xc(%ebp),%cl
  800a51:	38 08                	cmp    %cl,(%eax)
  800a53:	75 06                	jne    800a5b <memfind+0x1c>
  800a55:	eb 09                	jmp    800a60 <memfind+0x21>
  800a57:	38 08                	cmp    %cl,(%eax)
  800a59:	74 05                	je     800a60 <memfind+0x21>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a5b:	40                   	inc    %eax
  800a5c:	39 c2                	cmp    %eax,%edx
  800a5e:	77 f7                	ja     800a57 <memfind+0x18>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a60:	c9                   	leave  
  800a61:	c3                   	ret    

00800a62 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a62:	55                   	push   %ebp
  800a63:	89 e5                	mov    %esp,%ebp
  800a65:	57                   	push   %edi
  800a66:	56                   	push   %esi
  800a67:	53                   	push   %ebx
  800a68:	8b 55 08             	mov    0x8(%ebp),%edx
  800a6b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a6e:	eb 01                	jmp    800a71 <strtol+0xf>
		s++;
  800a70:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a71:	8a 02                	mov    (%edx),%al
  800a73:	3c 20                	cmp    $0x20,%al
  800a75:	74 f9                	je     800a70 <strtol+0xe>
  800a77:	3c 09                	cmp    $0x9,%al
  800a79:	74 f5                	je     800a70 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a7b:	3c 2b                	cmp    $0x2b,%al
  800a7d:	75 08                	jne    800a87 <strtol+0x25>
		s++;
  800a7f:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a80:	bf 00 00 00 00       	mov    $0x0,%edi
  800a85:	eb 13                	jmp    800a9a <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a87:	3c 2d                	cmp    $0x2d,%al
  800a89:	75 0a                	jne    800a95 <strtol+0x33>
		s++, neg = 1;
  800a8b:	8d 52 01             	lea    0x1(%edx),%edx
  800a8e:	bf 01 00 00 00       	mov    $0x1,%edi
  800a93:	eb 05                	jmp    800a9a <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a95:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a9a:	85 db                	test   %ebx,%ebx
  800a9c:	74 05                	je     800aa3 <strtol+0x41>
  800a9e:	83 fb 10             	cmp    $0x10,%ebx
  800aa1:	75 28                	jne    800acb <strtol+0x69>
  800aa3:	8a 02                	mov    (%edx),%al
  800aa5:	3c 30                	cmp    $0x30,%al
  800aa7:	75 10                	jne    800ab9 <strtol+0x57>
  800aa9:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800aad:	75 0a                	jne    800ab9 <strtol+0x57>
		s += 2, base = 16;
  800aaf:	83 c2 02             	add    $0x2,%edx
  800ab2:	bb 10 00 00 00       	mov    $0x10,%ebx
  800ab7:	eb 12                	jmp    800acb <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800ab9:	85 db                	test   %ebx,%ebx
  800abb:	75 0e                	jne    800acb <strtol+0x69>
  800abd:	3c 30                	cmp    $0x30,%al
  800abf:	75 05                	jne    800ac6 <strtol+0x64>
		s++, base = 8;
  800ac1:	42                   	inc    %edx
  800ac2:	b3 08                	mov    $0x8,%bl
  800ac4:	eb 05                	jmp    800acb <strtol+0x69>
	else if (base == 0)
		base = 10;
  800ac6:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800acb:	b8 00 00 00 00       	mov    $0x0,%eax
  800ad0:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800ad2:	8a 0a                	mov    (%edx),%cl
  800ad4:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800ad7:	80 fb 09             	cmp    $0x9,%bl
  800ada:	77 08                	ja     800ae4 <strtol+0x82>
			dig = *s - '0';
  800adc:	0f be c9             	movsbl %cl,%ecx
  800adf:	83 e9 30             	sub    $0x30,%ecx
  800ae2:	eb 1e                	jmp    800b02 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800ae4:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800ae7:	80 fb 19             	cmp    $0x19,%bl
  800aea:	77 08                	ja     800af4 <strtol+0x92>
			dig = *s - 'a' + 10;
  800aec:	0f be c9             	movsbl %cl,%ecx
  800aef:	83 e9 57             	sub    $0x57,%ecx
  800af2:	eb 0e                	jmp    800b02 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800af4:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800af7:	80 fb 19             	cmp    $0x19,%bl
  800afa:	77 13                	ja     800b0f <strtol+0xad>
			dig = *s - 'A' + 10;
  800afc:	0f be c9             	movsbl %cl,%ecx
  800aff:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800b02:	39 f1                	cmp    %esi,%ecx
  800b04:	7d 0d                	jge    800b13 <strtol+0xb1>
			break;
		s++, val = (val * base) + dig;
  800b06:	42                   	inc    %edx
  800b07:	0f af c6             	imul   %esi,%eax
  800b0a:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  800b0d:	eb c3                	jmp    800ad2 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800b0f:	89 c1                	mov    %eax,%ecx
  800b11:	eb 02                	jmp    800b15 <strtol+0xb3>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800b13:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800b15:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b19:	74 05                	je     800b20 <strtol+0xbe>
		*endptr = (char *) s;
  800b1b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800b1e:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800b20:	85 ff                	test   %edi,%edi
  800b22:	74 04                	je     800b28 <strtol+0xc6>
  800b24:	89 c8                	mov    %ecx,%eax
  800b26:	f7 d8                	neg    %eax
}
  800b28:	5b                   	pop    %ebx
  800b29:	5e                   	pop    %esi
  800b2a:	5f                   	pop    %edi
  800b2b:	c9                   	leave  
  800b2c:	c3                   	ret    
  800b2d:	00 00                	add    %al,(%eax)
	...

00800b30 <syscall>:
	return ret;
}

static int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800b30:	55                   	push   %ebp
  800b31:	89 e5                	mov    %esp,%ebp
  800b33:	57                   	push   %edi
  800b34:	56                   	push   %esi
  800b35:	53                   	push   %ebx
  800b36:	83 ec 1c             	sub    $0x1c,%esp
  800b39:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800b3c:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800b3f:	89 ca                	mov    %ecx,%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b41:	8b 75 14             	mov    0x14(%ebp),%esi
  800b44:	8b 7d 10             	mov    0x10(%ebp),%edi
  800b47:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800b4a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b4d:	cd 30                	int    $0x30
  800b4f:	89 c2                	mov    %eax,%edx
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b51:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800b55:	74 1c                	je     800b73 <syscall+0x43>
  800b57:	85 c0                	test   %eax,%eax
  800b59:	7e 18                	jle    800b73 <syscall+0x43>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b5b:	83 ec 0c             	sub    $0xc,%esp
  800b5e:	50                   	push   %eax
  800b5f:	ff 75 e4             	pushl  -0x1c(%ebp)
  800b62:	68 3f 22 80 00       	push   $0x80223f
  800b67:	6a 42                	push   $0x42
  800b69:	68 5c 22 80 00       	push   $0x80225c
  800b6e:	e8 b1 f5 ff ff       	call   800124 <_panic>

	return ret;
}
  800b73:	89 d0                	mov    %edx,%eax
  800b75:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b78:	5b                   	pop    %ebx
  800b79:	5e                   	pop    %esi
  800b7a:	5f                   	pop    %edi
  800b7b:	c9                   	leave  
  800b7c:	c3                   	ret    

00800b7d <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{	
  800b7d:	55                   	push   %ebp
  800b7e:	89 e5                	mov    %esp,%ebp
  800b80:	83 ec 08             	sub    $0x8,%esp
	// my_sysenter(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
	// return;
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  800b83:	6a 00                	push   $0x0
  800b85:	6a 00                	push   $0x0
  800b87:	6a 00                	push   $0x0
  800b89:	ff 75 0c             	pushl  0xc(%ebp)
  800b8c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b8f:	ba 00 00 00 00       	mov    $0x0,%edx
  800b94:	b8 00 00 00 00       	mov    $0x0,%eax
  800b99:	e8 92 ff ff ff       	call   800b30 <syscall>
  800b9e:	83 c4 10             	add    $0x10,%esp
	return;
}
  800ba1:	c9                   	leave  
  800ba2:	c3                   	ret    

00800ba3 <sys_cgetc>:

int
sys_cgetc(void)
{
  800ba3:	55                   	push   %ebp
  800ba4:	89 e5                	mov    %esp,%ebp
  800ba6:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_cgetc, 0, 0, 0, 0, 0, 0);
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  800ba9:	6a 00                	push   $0x0
  800bab:	6a 00                	push   $0x0
  800bad:	6a 00                	push   $0x0
  800baf:	6a 00                	push   $0x0
  800bb1:	b9 00 00 00 00       	mov    $0x0,%ecx
  800bb6:	ba 00 00 00 00       	mov    $0x0,%edx
  800bbb:	b8 01 00 00 00       	mov    $0x1,%eax
  800bc0:	e8 6b ff ff ff       	call   800b30 <syscall>
}
  800bc5:	c9                   	leave  
  800bc6:	c3                   	ret    

00800bc7 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800bc7:	55                   	push   %ebp
  800bc8:	89 e5                	mov    %esp,%ebp
  800bca:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  800bcd:	6a 00                	push   $0x0
  800bcf:	6a 00                	push   $0x0
  800bd1:	6a 00                	push   $0x0
  800bd3:	6a 00                	push   $0x0
  800bd5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800bd8:	ba 01 00 00 00       	mov    $0x1,%edx
  800bdd:	b8 03 00 00 00       	mov    $0x3,%eax
  800be2:	e8 49 ff ff ff       	call   800b30 <syscall>
}
  800be7:	c9                   	leave  
  800be8:	c3                   	ret    

00800be9 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800be9:	55                   	push   %ebp
  800bea:	89 e5                	mov    %esp,%ebp
  800bec:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_getenvid, 0, 0, 0, 0, 0, 0);
	return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  800bef:	6a 00                	push   $0x0
  800bf1:	6a 00                	push   $0x0
  800bf3:	6a 00                	push   $0x0
  800bf5:	6a 00                	push   $0x0
  800bf7:	b9 00 00 00 00       	mov    $0x0,%ecx
  800bfc:	ba 00 00 00 00       	mov    $0x0,%edx
  800c01:	b8 02 00 00 00       	mov    $0x2,%eax
  800c06:	e8 25 ff ff ff       	call   800b30 <syscall>
}
  800c0b:	c9                   	leave  
  800c0c:	c3                   	ret    

00800c0d <sys_yield>:

void
sys_yield(void)
{
  800c0d:	55                   	push   %ebp
  800c0e:	89 e5                	mov    %esp,%ebp
  800c10:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  800c13:	6a 00                	push   $0x0
  800c15:	6a 00                	push   $0x0
  800c17:	6a 00                	push   $0x0
  800c19:	6a 00                	push   $0x0
  800c1b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c20:	ba 00 00 00 00       	mov    $0x0,%edx
  800c25:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c2a:	e8 01 ff ff ff       	call   800b30 <syscall>
  800c2f:	83 c4 10             	add    $0x10,%esp
}
  800c32:	c9                   	leave  
  800c33:	c3                   	ret    

00800c34 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c34:	55                   	push   %ebp
  800c35:	89 e5                	mov    %esp,%ebp
  800c37:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  800c3a:	6a 00                	push   $0x0
  800c3c:	6a 00                	push   $0x0
  800c3e:	ff 75 10             	pushl  0x10(%ebp)
  800c41:	ff 75 0c             	pushl  0xc(%ebp)
  800c44:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c47:	ba 01 00 00 00       	mov    $0x1,%edx
  800c4c:	b8 04 00 00 00       	mov    $0x4,%eax
  800c51:	e8 da fe ff ff       	call   800b30 <syscall>
}
  800c56:	c9                   	leave  
  800c57:	c3                   	ret    

00800c58 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c58:	55                   	push   %ebp
  800c59:	89 e5                	mov    %esp,%ebp
  800c5b:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
  800c5e:	ff 75 18             	pushl  0x18(%ebp)
  800c61:	ff 75 14             	pushl  0x14(%ebp)
  800c64:	ff 75 10             	pushl  0x10(%ebp)
  800c67:	ff 75 0c             	pushl  0xc(%ebp)
  800c6a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c6d:	ba 01 00 00 00       	mov    $0x1,%edx
  800c72:	b8 05 00 00 00       	mov    $0x5,%eax
  800c77:	e8 b4 fe ff ff       	call   800b30 <syscall>
}
  800c7c:	c9                   	leave  
  800c7d:	c3                   	ret    

00800c7e <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c7e:	55                   	push   %ebp
  800c7f:	89 e5                	mov    %esp,%ebp
  800c81:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  800c84:	6a 00                	push   $0x0
  800c86:	6a 00                	push   $0x0
  800c88:	6a 00                	push   $0x0
  800c8a:	ff 75 0c             	pushl  0xc(%ebp)
  800c8d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c90:	ba 01 00 00 00       	mov    $0x1,%edx
  800c95:	b8 06 00 00 00       	mov    $0x6,%eax
  800c9a:	e8 91 fe ff ff       	call   800b30 <syscall>
}
  800c9f:	c9                   	leave  
  800ca0:	c3                   	ret    

00800ca1 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800ca1:	55                   	push   %ebp
  800ca2:	89 e5                	mov    %esp,%ebp
  800ca4:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  800ca7:	6a 00                	push   $0x0
  800ca9:	6a 00                	push   $0x0
  800cab:	6a 00                	push   $0x0
  800cad:	ff 75 0c             	pushl  0xc(%ebp)
  800cb0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800cb3:	ba 01 00 00 00       	mov    $0x1,%edx
  800cb8:	b8 08 00 00 00       	mov    $0x8,%eax
  800cbd:	e8 6e fe ff ff       	call   800b30 <syscall>
}
  800cc2:	c9                   	leave  
  800cc3:	c3                   	ret    

00800cc4 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800cc4:	55                   	push   %ebp
  800cc5:	89 e5                	mov    %esp,%ebp
  800cc7:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
  800cca:	6a 00                	push   $0x0
  800ccc:	6a 00                	push   $0x0
  800cce:	6a 00                	push   $0x0
  800cd0:	ff 75 0c             	pushl  0xc(%ebp)
  800cd3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800cd6:	ba 01 00 00 00       	mov    $0x1,%edx
  800cdb:	b8 09 00 00 00       	mov    $0x9,%eax
  800ce0:	e8 4b fe ff ff       	call   800b30 <syscall>
}
  800ce5:	c9                   	leave  
  800ce6:	c3                   	ret    

00800ce7 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800ce7:	55                   	push   %ebp
  800ce8:	89 e5                	mov    %esp,%ebp
  800cea:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  800ced:	6a 00                	push   $0x0
  800cef:	6a 00                	push   $0x0
  800cf1:	6a 00                	push   $0x0
  800cf3:	ff 75 0c             	pushl  0xc(%ebp)
  800cf6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800cf9:	ba 01 00 00 00       	mov    $0x1,%edx
  800cfe:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d03:	e8 28 fe ff ff       	call   800b30 <syscall>
}
  800d08:	c9                   	leave  
  800d09:	c3                   	ret    

00800d0a <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d0a:	55                   	push   %ebp
  800d0b:	89 e5                	mov    %esp,%ebp
  800d0d:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  800d10:	6a 00                	push   $0x0
  800d12:	ff 75 14             	pushl  0x14(%ebp)
  800d15:	ff 75 10             	pushl  0x10(%ebp)
  800d18:	ff 75 0c             	pushl  0xc(%ebp)
  800d1b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d1e:	ba 00 00 00 00       	mov    $0x0,%edx
  800d23:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d28:	e8 03 fe ff ff       	call   800b30 <syscall>
}
  800d2d:	c9                   	leave  
  800d2e:	c3                   	ret    

00800d2f <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d2f:	55                   	push   %ebp
  800d30:	89 e5                	mov    %esp,%ebp
  800d32:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  800d35:	6a 00                	push   $0x0
  800d37:	6a 00                	push   $0x0
  800d39:	6a 00                	push   $0x0
  800d3b:	6a 00                	push   $0x0
  800d3d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d40:	ba 01 00 00 00       	mov    $0x1,%edx
  800d45:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d4a:	e8 e1 fd ff ff       	call   800b30 <syscall>
}
  800d4f:	c9                   	leave  
  800d50:	c3                   	ret    

00800d51 <sys_set_priority>:

int
sys_set_priority(envid_t envid, uint32_t new_priority)
{
  800d51:	55                   	push   %ebp
  800d52:	89 e5                	mov    %esp,%ebp
  800d54:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_set_priority, 0, envid, new_priority, 0, 0, 0);
  800d57:	6a 00                	push   $0x0
  800d59:	6a 00                	push   $0x0
  800d5b:	6a 00                	push   $0x0
  800d5d:	ff 75 0c             	pushl  0xc(%ebp)
  800d60:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d63:	ba 00 00 00 00       	mov    $0x0,%edx
  800d68:	b8 0e 00 00 00       	mov    $0xe,%eax
  800d6d:	e8 be fd ff ff       	call   800b30 <syscall>
}
  800d72:	c9                   	leave  
  800d73:	c3                   	ret    

00800d74 <sys_exec>:

int
sys_exec(uint32_t eip, uint32_t esp, void * ph, uint32_t elf_phnum)
{
  800d74:	55                   	push   %ebp
  800d75:	89 e5                	mov    %esp,%ebp
  800d77:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_exec, 0, eip, esp, (uint32_t)ph, elf_phnum, 0);
  800d7a:	6a 00                	push   $0x0
  800d7c:	ff 75 14             	pushl  0x14(%ebp)
  800d7f:	ff 75 10             	pushl  0x10(%ebp)
  800d82:	ff 75 0c             	pushl  0xc(%ebp)
  800d85:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d88:	ba 00 00 00 00       	mov    $0x0,%edx
  800d8d:	b8 0f 00 00 00       	mov    $0xf,%eax
  800d92:	e8 99 fd ff ff       	call   800b30 <syscall>
  800d97:	c9                   	leave  
  800d98:	c3                   	ret    
  800d99:	00 00                	add    %al,(%eax)
	...

00800d9c <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  800d9c:	55                   	push   %ebp
  800d9d:	89 e5                	mov    %esp,%ebp
  800d9f:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  800da2:	83 3d 08 40 80 00 00 	cmpl   $0x0,0x804008
  800da9:	75 52                	jne    800dfd <set_pgfault_handler+0x61>
		// First time through!	
		// LAB 4: Your code here.

		//int sys_page_alloc(envid_t envid, void *va, int perm)
		r = sys_page_alloc(0, (void*)(UXSTACKTOP - PGSIZE), PTE_U | PTE_W | PTE_P);
  800dab:	83 ec 04             	sub    $0x4,%esp
  800dae:	6a 07                	push   $0x7
  800db0:	68 00 f0 bf ee       	push   $0xeebff000
  800db5:	6a 00                	push   $0x0
  800db7:	e8 78 fe ff ff       	call   800c34 <sys_page_alloc>
		if (r < 0) {
  800dbc:	83 c4 10             	add    $0x10,%esp
  800dbf:	85 c0                	test   %eax,%eax
  800dc1:	79 12                	jns    800dd5 <set_pgfault_handler+0x39>
			panic("sys_page_alloc error : %e\n", r);
  800dc3:	50                   	push   %eax
  800dc4:	68 6a 22 80 00       	push   $0x80226a
  800dc9:	6a 24                	push   $0x24
  800dcb:	68 85 22 80 00       	push   $0x802285
  800dd0:	e8 4f f3 ff ff       	call   800124 <_panic>
		}

		// how to know envid, put 0, envid2env will help us to get curenv in syscall
		r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);		
  800dd5:	83 ec 08             	sub    $0x8,%esp
  800dd8:	68 08 0e 80 00       	push   $0x800e08
  800ddd:	6a 00                	push   $0x0
  800ddf:	e8 03 ff ff ff       	call   800ce7 <sys_env_set_pgfault_upcall>
		if (r < 0) {
  800de4:	83 c4 10             	add    $0x10,%esp
  800de7:	85 c0                	test   %eax,%eax
  800de9:	79 12                	jns    800dfd <set_pgfault_handler+0x61>
			panic("sys_env_set_pgfault_upcall error : %e\n", r);
  800deb:	50                   	push   %eax
  800dec:	68 94 22 80 00       	push   $0x802294
  800df1:	6a 2a                	push   $0x2a
  800df3:	68 85 22 80 00       	push   $0x802285
  800df8:	e8 27 f3 ff ff       	call   800124 <_panic>
		}
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  800dfd:	8b 45 08             	mov    0x8(%ebp),%eax
  800e00:	a3 08 40 80 00       	mov    %eax,0x804008
}
  800e05:	c9                   	leave  
  800e06:	c3                   	ret    
	...

00800e08 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  800e08:	54                   	push   %esp
	movl _pgfault_handler, %eax
  800e09:	a1 08 40 80 00       	mov    0x804008,%eax
	call *%eax
  800e0e:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  800e10:	83 c4 04             	add    $0x4,%esp
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	
	// fix old esp
	movl 0x30(%esp), %eax
  800e13:	8b 44 24 30          	mov    0x30(%esp),%eax
	subl $0x4, %eax
  800e17:	83 e8 04             	sub    $0x4,%eax
	movl %eax, 0x30(%esp)
  800e1a:	89 44 24 30          	mov    %eax,0x30(%esp)

	// set trap-time %eip
	movl 0x28(%esp), %ebx
  800e1e:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	movl %ebx, (%eax)
  800e22:	89 18                	mov    %ebx,(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $0x08, %esp 	// ignore err_code and fault_va
  800e24:	83 c4 08             	add    $0x8,%esp
	popal 				// restore registers
  800e27:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x04, %esp 	// ignore eip 
  800e28:	83 c4 04             	add    $0x4,%esp
	popfl				// modify eflags
  800e2b:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  800e2c:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  800e2d:	c3                   	ret    
	...

00800e30 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800e30:	55                   	push   %ebp
  800e31:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800e33:	8b 45 08             	mov    0x8(%ebp),%eax
  800e36:	05 00 00 00 30       	add    $0x30000000,%eax
  800e3b:	c1 e8 0c             	shr    $0xc,%eax
}
  800e3e:	c9                   	leave  
  800e3f:	c3                   	ret    

00800e40 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800e40:	55                   	push   %ebp
  800e41:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800e43:	ff 75 08             	pushl  0x8(%ebp)
  800e46:	e8 e5 ff ff ff       	call   800e30 <fd2num>
  800e4b:	83 c4 04             	add    $0x4,%esp
  800e4e:	05 20 00 0d 00       	add    $0xd0020,%eax
  800e53:	c1 e0 0c             	shl    $0xc,%eax
}
  800e56:	c9                   	leave  
  800e57:	c3                   	ret    

00800e58 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800e58:	55                   	push   %ebp
  800e59:	89 e5                	mov    %esp,%ebp
  800e5b:	53                   	push   %ebx
  800e5c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800e5f:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  800e64:	a8 01                	test   $0x1,%al
  800e66:	74 34                	je     800e9c <fd_alloc+0x44>
  800e68:	a1 00 00 74 ef       	mov    0xef740000,%eax
  800e6d:	a8 01                	test   $0x1,%al
  800e6f:	74 32                	je     800ea3 <fd_alloc+0x4b>
  800e71:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
  800e76:	89 c1                	mov    %eax,%ecx
  800e78:	89 c2                	mov    %eax,%edx
  800e7a:	c1 ea 16             	shr    $0x16,%edx
  800e7d:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800e84:	f6 c2 01             	test   $0x1,%dl
  800e87:	74 1f                	je     800ea8 <fd_alloc+0x50>
  800e89:	89 c2                	mov    %eax,%edx
  800e8b:	c1 ea 0c             	shr    $0xc,%edx
  800e8e:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e95:	f6 c2 01             	test   $0x1,%dl
  800e98:	75 17                	jne    800eb1 <fd_alloc+0x59>
  800e9a:	eb 0c                	jmp    800ea8 <fd_alloc+0x50>
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  800e9c:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
  800ea1:	eb 05                	jmp    800ea8 <fd_alloc+0x50>
  800ea3:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
  800ea8:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  800eaa:	b8 00 00 00 00       	mov    $0x0,%eax
  800eaf:	eb 17                	jmp    800ec8 <fd_alloc+0x70>
  800eb1:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800eb6:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800ebb:	75 b9                	jne    800e76 <fd_alloc+0x1e>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800ebd:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  800ec3:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800ec8:	5b                   	pop    %ebx
  800ec9:	c9                   	leave  
  800eca:	c3                   	ret    

00800ecb <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800ecb:	55                   	push   %ebp
  800ecc:	89 e5                	mov    %esp,%ebp
  800ece:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800ed1:	83 f8 1f             	cmp    $0x1f,%eax
  800ed4:	77 36                	ja     800f0c <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800ed6:	05 00 00 0d 00       	add    $0xd0000,%eax
  800edb:	c1 e0 0c             	shl    $0xc,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800ede:	89 c2                	mov    %eax,%edx
  800ee0:	c1 ea 16             	shr    $0x16,%edx
  800ee3:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800eea:	f6 c2 01             	test   $0x1,%dl
  800eed:	74 24                	je     800f13 <fd_lookup+0x48>
  800eef:	89 c2                	mov    %eax,%edx
  800ef1:	c1 ea 0c             	shr    $0xc,%edx
  800ef4:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800efb:	f6 c2 01             	test   $0x1,%dl
  800efe:	74 1a                	je     800f1a <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800f00:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f03:	89 02                	mov    %eax,(%edx)
	return 0;
  800f05:	b8 00 00 00 00       	mov    $0x0,%eax
  800f0a:	eb 13                	jmp    800f1f <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800f0c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f11:	eb 0c                	jmp    800f1f <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800f13:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f18:	eb 05                	jmp    800f1f <fd_lookup+0x54>
  800f1a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800f1f:	c9                   	leave  
  800f20:	c3                   	ret    

00800f21 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800f21:	55                   	push   %ebp
  800f22:	89 e5                	mov    %esp,%ebp
  800f24:	53                   	push   %ebx
  800f25:	83 ec 04             	sub    $0x4,%esp
  800f28:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f2b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  800f2e:	39 0d 04 30 80 00    	cmp    %ecx,0x803004
  800f34:	74 0d                	je     800f43 <dev_lookup+0x22>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800f36:	b8 00 00 00 00       	mov    $0x0,%eax
  800f3b:	eb 14                	jmp    800f51 <dev_lookup+0x30>
		if (devtab[i]->dev_id == dev_id) {
  800f3d:	39 0a                	cmp    %ecx,(%edx)
  800f3f:	75 10                	jne    800f51 <dev_lookup+0x30>
  800f41:	eb 05                	jmp    800f48 <dev_lookup+0x27>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800f43:	ba 04 30 80 00       	mov    $0x803004,%edx
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
  800f48:	89 13                	mov    %edx,(%ebx)
			return 0;
  800f4a:	b8 00 00 00 00       	mov    $0x0,%eax
  800f4f:	eb 31                	jmp    800f82 <dev_lookup+0x61>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800f51:	40                   	inc    %eax
  800f52:	8b 14 85 3c 23 80 00 	mov    0x80233c(,%eax,4),%edx
  800f59:	85 d2                	test   %edx,%edx
  800f5b:	75 e0                	jne    800f3d <dev_lookup+0x1c>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800f5d:	a1 04 40 80 00       	mov    0x804004,%eax
  800f62:	8b 40 48             	mov    0x48(%eax),%eax
  800f65:	83 ec 04             	sub    $0x4,%esp
  800f68:	51                   	push   %ecx
  800f69:	50                   	push   %eax
  800f6a:	68 bc 22 80 00       	push   $0x8022bc
  800f6f:	e8 88 f2 ff ff       	call   8001fc <cprintf>
	*dev = 0;
  800f74:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  800f7a:	83 c4 10             	add    $0x10,%esp
  800f7d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800f82:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f85:	c9                   	leave  
  800f86:	c3                   	ret    

00800f87 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800f87:	55                   	push   %ebp
  800f88:	89 e5                	mov    %esp,%ebp
  800f8a:	56                   	push   %esi
  800f8b:	53                   	push   %ebx
  800f8c:	83 ec 20             	sub    $0x20,%esp
  800f8f:	8b 75 08             	mov    0x8(%ebp),%esi
  800f92:	8a 45 0c             	mov    0xc(%ebp),%al
  800f95:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800f98:	56                   	push   %esi
  800f99:	e8 92 fe ff ff       	call   800e30 <fd2num>
  800f9e:	8d 55 f4             	lea    -0xc(%ebp),%edx
  800fa1:	89 14 24             	mov    %edx,(%esp)
  800fa4:	50                   	push   %eax
  800fa5:	e8 21 ff ff ff       	call   800ecb <fd_lookup>
  800faa:	89 c3                	mov    %eax,%ebx
  800fac:	83 c4 08             	add    $0x8,%esp
  800faf:	85 c0                	test   %eax,%eax
  800fb1:	78 05                	js     800fb8 <fd_close+0x31>
	    || fd != fd2)
  800fb3:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800fb6:	74 0d                	je     800fc5 <fd_close+0x3e>
		return (must_exist ? r : 0);
  800fb8:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  800fbc:	75 48                	jne    801006 <fd_close+0x7f>
  800fbe:	bb 00 00 00 00       	mov    $0x0,%ebx
  800fc3:	eb 41                	jmp    801006 <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800fc5:	83 ec 08             	sub    $0x8,%esp
  800fc8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800fcb:	50                   	push   %eax
  800fcc:	ff 36                	pushl  (%esi)
  800fce:	e8 4e ff ff ff       	call   800f21 <dev_lookup>
  800fd3:	89 c3                	mov    %eax,%ebx
  800fd5:	83 c4 10             	add    $0x10,%esp
  800fd8:	85 c0                	test   %eax,%eax
  800fda:	78 1c                	js     800ff8 <fd_close+0x71>
		if (dev->dev_close)
  800fdc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800fdf:	8b 40 10             	mov    0x10(%eax),%eax
  800fe2:	85 c0                	test   %eax,%eax
  800fe4:	74 0d                	je     800ff3 <fd_close+0x6c>
			r = (*dev->dev_close)(fd);
  800fe6:	83 ec 0c             	sub    $0xc,%esp
  800fe9:	56                   	push   %esi
  800fea:	ff d0                	call   *%eax
  800fec:	89 c3                	mov    %eax,%ebx
  800fee:	83 c4 10             	add    $0x10,%esp
  800ff1:	eb 05                	jmp    800ff8 <fd_close+0x71>
		else
			r = 0;
  800ff3:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800ff8:	83 ec 08             	sub    $0x8,%esp
  800ffb:	56                   	push   %esi
  800ffc:	6a 00                	push   $0x0
  800ffe:	e8 7b fc ff ff       	call   800c7e <sys_page_unmap>
	return r;
  801003:	83 c4 10             	add    $0x10,%esp
}
  801006:	89 d8                	mov    %ebx,%eax
  801008:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80100b:	5b                   	pop    %ebx
  80100c:	5e                   	pop    %esi
  80100d:	c9                   	leave  
  80100e:	c3                   	ret    

0080100f <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80100f:	55                   	push   %ebp
  801010:	89 e5                	mov    %esp,%ebp
  801012:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801015:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801018:	50                   	push   %eax
  801019:	ff 75 08             	pushl  0x8(%ebp)
  80101c:	e8 aa fe ff ff       	call   800ecb <fd_lookup>
  801021:	83 c4 08             	add    $0x8,%esp
  801024:	85 c0                	test   %eax,%eax
  801026:	78 10                	js     801038 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801028:	83 ec 08             	sub    $0x8,%esp
  80102b:	6a 01                	push   $0x1
  80102d:	ff 75 f4             	pushl  -0xc(%ebp)
  801030:	e8 52 ff ff ff       	call   800f87 <fd_close>
  801035:	83 c4 10             	add    $0x10,%esp
}
  801038:	c9                   	leave  
  801039:	c3                   	ret    

0080103a <close_all>:

void
close_all(void)
{
  80103a:	55                   	push   %ebp
  80103b:	89 e5                	mov    %esp,%ebp
  80103d:	53                   	push   %ebx
  80103e:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801041:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801046:	83 ec 0c             	sub    $0xc,%esp
  801049:	53                   	push   %ebx
  80104a:	e8 c0 ff ff ff       	call   80100f <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80104f:	43                   	inc    %ebx
  801050:	83 c4 10             	add    $0x10,%esp
  801053:	83 fb 20             	cmp    $0x20,%ebx
  801056:	75 ee                	jne    801046 <close_all+0xc>
		close(i);
}
  801058:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80105b:	c9                   	leave  
  80105c:	c3                   	ret    

0080105d <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80105d:	55                   	push   %ebp
  80105e:	89 e5                	mov    %esp,%ebp
  801060:	57                   	push   %edi
  801061:	56                   	push   %esi
  801062:	53                   	push   %ebx
  801063:	83 ec 2c             	sub    $0x2c,%esp
  801066:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801069:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80106c:	50                   	push   %eax
  80106d:	ff 75 08             	pushl  0x8(%ebp)
  801070:	e8 56 fe ff ff       	call   800ecb <fd_lookup>
  801075:	89 c3                	mov    %eax,%ebx
  801077:	83 c4 08             	add    $0x8,%esp
  80107a:	85 c0                	test   %eax,%eax
  80107c:	0f 88 c0 00 00 00    	js     801142 <dup+0xe5>
		return r;
	close(newfdnum);
  801082:	83 ec 0c             	sub    $0xc,%esp
  801085:	57                   	push   %edi
  801086:	e8 84 ff ff ff       	call   80100f <close>

	newfd = INDEX2FD(newfdnum);
  80108b:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  801091:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  801094:	83 c4 04             	add    $0x4,%esp
  801097:	ff 75 e4             	pushl  -0x1c(%ebp)
  80109a:	e8 a1 fd ff ff       	call   800e40 <fd2data>
  80109f:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  8010a1:	89 34 24             	mov    %esi,(%esp)
  8010a4:	e8 97 fd ff ff       	call   800e40 <fd2data>
  8010a9:	83 c4 10             	add    $0x10,%esp
  8010ac:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8010af:	89 d8                	mov    %ebx,%eax
  8010b1:	c1 e8 16             	shr    $0x16,%eax
  8010b4:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8010bb:	a8 01                	test   $0x1,%al
  8010bd:	74 37                	je     8010f6 <dup+0x99>
  8010bf:	89 d8                	mov    %ebx,%eax
  8010c1:	c1 e8 0c             	shr    $0xc,%eax
  8010c4:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8010cb:	f6 c2 01             	test   $0x1,%dl
  8010ce:	74 26                	je     8010f6 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8010d0:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8010d7:	83 ec 0c             	sub    $0xc,%esp
  8010da:	25 07 0e 00 00       	and    $0xe07,%eax
  8010df:	50                   	push   %eax
  8010e0:	ff 75 d4             	pushl  -0x2c(%ebp)
  8010e3:	6a 00                	push   $0x0
  8010e5:	53                   	push   %ebx
  8010e6:	6a 00                	push   $0x0
  8010e8:	e8 6b fb ff ff       	call   800c58 <sys_page_map>
  8010ed:	89 c3                	mov    %eax,%ebx
  8010ef:	83 c4 20             	add    $0x20,%esp
  8010f2:	85 c0                	test   %eax,%eax
  8010f4:	78 2d                	js     801123 <dup+0xc6>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8010f6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8010f9:	89 c2                	mov    %eax,%edx
  8010fb:	c1 ea 0c             	shr    $0xc,%edx
  8010fe:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801105:	83 ec 0c             	sub    $0xc,%esp
  801108:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  80110e:	52                   	push   %edx
  80110f:	56                   	push   %esi
  801110:	6a 00                	push   $0x0
  801112:	50                   	push   %eax
  801113:	6a 00                	push   $0x0
  801115:	e8 3e fb ff ff       	call   800c58 <sys_page_map>
  80111a:	89 c3                	mov    %eax,%ebx
  80111c:	83 c4 20             	add    $0x20,%esp
  80111f:	85 c0                	test   %eax,%eax
  801121:	79 1d                	jns    801140 <dup+0xe3>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801123:	83 ec 08             	sub    $0x8,%esp
  801126:	56                   	push   %esi
  801127:	6a 00                	push   $0x0
  801129:	e8 50 fb ff ff       	call   800c7e <sys_page_unmap>
	sys_page_unmap(0, nva);
  80112e:	83 c4 08             	add    $0x8,%esp
  801131:	ff 75 d4             	pushl  -0x2c(%ebp)
  801134:	6a 00                	push   $0x0
  801136:	e8 43 fb ff ff       	call   800c7e <sys_page_unmap>
	return r;
  80113b:	83 c4 10             	add    $0x10,%esp
  80113e:	eb 02                	jmp    801142 <dup+0xe5>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  801140:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  801142:	89 d8                	mov    %ebx,%eax
  801144:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801147:	5b                   	pop    %ebx
  801148:	5e                   	pop    %esi
  801149:	5f                   	pop    %edi
  80114a:	c9                   	leave  
  80114b:	c3                   	ret    

0080114c <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80114c:	55                   	push   %ebp
  80114d:	89 e5                	mov    %esp,%ebp
  80114f:	53                   	push   %ebx
  801150:	83 ec 14             	sub    $0x14,%esp
  801153:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801156:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801159:	50                   	push   %eax
  80115a:	53                   	push   %ebx
  80115b:	e8 6b fd ff ff       	call   800ecb <fd_lookup>
  801160:	83 c4 08             	add    $0x8,%esp
  801163:	85 c0                	test   %eax,%eax
  801165:	78 67                	js     8011ce <read+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801167:	83 ec 08             	sub    $0x8,%esp
  80116a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80116d:	50                   	push   %eax
  80116e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801171:	ff 30                	pushl  (%eax)
  801173:	e8 a9 fd ff ff       	call   800f21 <dev_lookup>
  801178:	83 c4 10             	add    $0x10,%esp
  80117b:	85 c0                	test   %eax,%eax
  80117d:	78 4f                	js     8011ce <read+0x82>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80117f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801182:	8b 50 08             	mov    0x8(%eax),%edx
  801185:	83 e2 03             	and    $0x3,%edx
  801188:	83 fa 01             	cmp    $0x1,%edx
  80118b:	75 21                	jne    8011ae <read+0x62>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80118d:	a1 04 40 80 00       	mov    0x804004,%eax
  801192:	8b 40 48             	mov    0x48(%eax),%eax
  801195:	83 ec 04             	sub    $0x4,%esp
  801198:	53                   	push   %ebx
  801199:	50                   	push   %eax
  80119a:	68 00 23 80 00       	push   $0x802300
  80119f:	e8 58 f0 ff ff       	call   8001fc <cprintf>
		return -E_INVAL;
  8011a4:	83 c4 10             	add    $0x10,%esp
  8011a7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8011ac:	eb 20                	jmp    8011ce <read+0x82>
	}
	if (!dev->dev_read)
  8011ae:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8011b1:	8b 52 08             	mov    0x8(%edx),%edx
  8011b4:	85 d2                	test   %edx,%edx
  8011b6:	74 11                	je     8011c9 <read+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8011b8:	83 ec 04             	sub    $0x4,%esp
  8011bb:	ff 75 10             	pushl  0x10(%ebp)
  8011be:	ff 75 0c             	pushl  0xc(%ebp)
  8011c1:	50                   	push   %eax
  8011c2:	ff d2                	call   *%edx
  8011c4:	83 c4 10             	add    $0x10,%esp
  8011c7:	eb 05                	jmp    8011ce <read+0x82>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8011c9:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  8011ce:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8011d1:	c9                   	leave  
  8011d2:	c3                   	ret    

008011d3 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8011d3:	55                   	push   %ebp
  8011d4:	89 e5                	mov    %esp,%ebp
  8011d6:	57                   	push   %edi
  8011d7:	56                   	push   %esi
  8011d8:	53                   	push   %ebx
  8011d9:	83 ec 0c             	sub    $0xc,%esp
  8011dc:	8b 7d 08             	mov    0x8(%ebp),%edi
  8011df:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8011e2:	85 f6                	test   %esi,%esi
  8011e4:	74 31                	je     801217 <readn+0x44>
  8011e6:	b8 00 00 00 00       	mov    $0x0,%eax
  8011eb:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = read(fdnum, (char*)buf + tot, n - tot);
  8011f0:	83 ec 04             	sub    $0x4,%esp
  8011f3:	89 f2                	mov    %esi,%edx
  8011f5:	29 c2                	sub    %eax,%edx
  8011f7:	52                   	push   %edx
  8011f8:	03 45 0c             	add    0xc(%ebp),%eax
  8011fb:	50                   	push   %eax
  8011fc:	57                   	push   %edi
  8011fd:	e8 4a ff ff ff       	call   80114c <read>
		if (m < 0)
  801202:	83 c4 10             	add    $0x10,%esp
  801205:	85 c0                	test   %eax,%eax
  801207:	78 17                	js     801220 <readn+0x4d>
			return m;
		if (m == 0)
  801209:	85 c0                	test   %eax,%eax
  80120b:	74 11                	je     80121e <readn+0x4b>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80120d:	01 c3                	add    %eax,%ebx
  80120f:	89 d8                	mov    %ebx,%eax
  801211:	39 f3                	cmp    %esi,%ebx
  801213:	72 db                	jb     8011f0 <readn+0x1d>
  801215:	eb 09                	jmp    801220 <readn+0x4d>
  801217:	b8 00 00 00 00       	mov    $0x0,%eax
  80121c:	eb 02                	jmp    801220 <readn+0x4d>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  80121e:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  801220:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801223:	5b                   	pop    %ebx
  801224:	5e                   	pop    %esi
  801225:	5f                   	pop    %edi
  801226:	c9                   	leave  
  801227:	c3                   	ret    

00801228 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801228:	55                   	push   %ebp
  801229:	89 e5                	mov    %esp,%ebp
  80122b:	53                   	push   %ebx
  80122c:	83 ec 14             	sub    $0x14,%esp
  80122f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801232:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801235:	50                   	push   %eax
  801236:	53                   	push   %ebx
  801237:	e8 8f fc ff ff       	call   800ecb <fd_lookup>
  80123c:	83 c4 08             	add    $0x8,%esp
  80123f:	85 c0                	test   %eax,%eax
  801241:	78 62                	js     8012a5 <write+0x7d>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801243:	83 ec 08             	sub    $0x8,%esp
  801246:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801249:	50                   	push   %eax
  80124a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80124d:	ff 30                	pushl  (%eax)
  80124f:	e8 cd fc ff ff       	call   800f21 <dev_lookup>
  801254:	83 c4 10             	add    $0x10,%esp
  801257:	85 c0                	test   %eax,%eax
  801259:	78 4a                	js     8012a5 <write+0x7d>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80125b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80125e:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801262:	75 21                	jne    801285 <write+0x5d>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801264:	a1 04 40 80 00       	mov    0x804004,%eax
  801269:	8b 40 48             	mov    0x48(%eax),%eax
  80126c:	83 ec 04             	sub    $0x4,%esp
  80126f:	53                   	push   %ebx
  801270:	50                   	push   %eax
  801271:	68 1c 23 80 00       	push   $0x80231c
  801276:	e8 81 ef ff ff       	call   8001fc <cprintf>
		return -E_INVAL;
  80127b:	83 c4 10             	add    $0x10,%esp
  80127e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801283:	eb 20                	jmp    8012a5 <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801285:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801288:	8b 52 0c             	mov    0xc(%edx),%edx
  80128b:	85 d2                	test   %edx,%edx
  80128d:	74 11                	je     8012a0 <write+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80128f:	83 ec 04             	sub    $0x4,%esp
  801292:	ff 75 10             	pushl  0x10(%ebp)
  801295:	ff 75 0c             	pushl  0xc(%ebp)
  801298:	50                   	push   %eax
  801299:	ff d2                	call   *%edx
  80129b:	83 c4 10             	add    $0x10,%esp
  80129e:	eb 05                	jmp    8012a5 <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8012a0:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  8012a5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012a8:	c9                   	leave  
  8012a9:	c3                   	ret    

008012aa <seek>:

int
seek(int fdnum, off_t offset)
{
  8012aa:	55                   	push   %ebp
  8012ab:	89 e5                	mov    %esp,%ebp
  8012ad:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8012b0:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8012b3:	50                   	push   %eax
  8012b4:	ff 75 08             	pushl  0x8(%ebp)
  8012b7:	e8 0f fc ff ff       	call   800ecb <fd_lookup>
  8012bc:	83 c4 08             	add    $0x8,%esp
  8012bf:	85 c0                	test   %eax,%eax
  8012c1:	78 0e                	js     8012d1 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8012c3:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8012c6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8012c9:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8012cc:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8012d1:	c9                   	leave  
  8012d2:	c3                   	ret    

008012d3 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8012d3:	55                   	push   %ebp
  8012d4:	89 e5                	mov    %esp,%ebp
  8012d6:	53                   	push   %ebx
  8012d7:	83 ec 14             	sub    $0x14,%esp
  8012da:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8012dd:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012e0:	50                   	push   %eax
  8012e1:	53                   	push   %ebx
  8012e2:	e8 e4 fb ff ff       	call   800ecb <fd_lookup>
  8012e7:	83 c4 08             	add    $0x8,%esp
  8012ea:	85 c0                	test   %eax,%eax
  8012ec:	78 5f                	js     80134d <ftruncate+0x7a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012ee:	83 ec 08             	sub    $0x8,%esp
  8012f1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012f4:	50                   	push   %eax
  8012f5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012f8:	ff 30                	pushl  (%eax)
  8012fa:	e8 22 fc ff ff       	call   800f21 <dev_lookup>
  8012ff:	83 c4 10             	add    $0x10,%esp
  801302:	85 c0                	test   %eax,%eax
  801304:	78 47                	js     80134d <ftruncate+0x7a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801306:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801309:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80130d:	75 21                	jne    801330 <ftruncate+0x5d>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80130f:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801314:	8b 40 48             	mov    0x48(%eax),%eax
  801317:	83 ec 04             	sub    $0x4,%esp
  80131a:	53                   	push   %ebx
  80131b:	50                   	push   %eax
  80131c:	68 dc 22 80 00       	push   $0x8022dc
  801321:	e8 d6 ee ff ff       	call   8001fc <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801326:	83 c4 10             	add    $0x10,%esp
  801329:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80132e:	eb 1d                	jmp    80134d <ftruncate+0x7a>
	}
	if (!dev->dev_trunc)
  801330:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801333:	8b 52 18             	mov    0x18(%edx),%edx
  801336:	85 d2                	test   %edx,%edx
  801338:	74 0e                	je     801348 <ftruncate+0x75>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80133a:	83 ec 08             	sub    $0x8,%esp
  80133d:	ff 75 0c             	pushl  0xc(%ebp)
  801340:	50                   	push   %eax
  801341:	ff d2                	call   *%edx
  801343:	83 c4 10             	add    $0x10,%esp
  801346:	eb 05                	jmp    80134d <ftruncate+0x7a>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801348:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  80134d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801350:	c9                   	leave  
  801351:	c3                   	ret    

00801352 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801352:	55                   	push   %ebp
  801353:	89 e5                	mov    %esp,%ebp
  801355:	53                   	push   %ebx
  801356:	83 ec 14             	sub    $0x14,%esp
  801359:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80135c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80135f:	50                   	push   %eax
  801360:	ff 75 08             	pushl  0x8(%ebp)
  801363:	e8 63 fb ff ff       	call   800ecb <fd_lookup>
  801368:	83 c4 08             	add    $0x8,%esp
  80136b:	85 c0                	test   %eax,%eax
  80136d:	78 52                	js     8013c1 <fstat+0x6f>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80136f:	83 ec 08             	sub    $0x8,%esp
  801372:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801375:	50                   	push   %eax
  801376:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801379:	ff 30                	pushl  (%eax)
  80137b:	e8 a1 fb ff ff       	call   800f21 <dev_lookup>
  801380:	83 c4 10             	add    $0x10,%esp
  801383:	85 c0                	test   %eax,%eax
  801385:	78 3a                	js     8013c1 <fstat+0x6f>
		return r;
	if (!dev->dev_stat)
  801387:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80138a:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80138e:	74 2c                	je     8013bc <fstat+0x6a>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801390:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801393:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80139a:	00 00 00 
	stat->st_isdir = 0;
  80139d:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8013a4:	00 00 00 
	stat->st_dev = dev;
  8013a7:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8013ad:	83 ec 08             	sub    $0x8,%esp
  8013b0:	53                   	push   %ebx
  8013b1:	ff 75 f0             	pushl  -0x10(%ebp)
  8013b4:	ff 50 14             	call   *0x14(%eax)
  8013b7:	83 c4 10             	add    $0x10,%esp
  8013ba:	eb 05                	jmp    8013c1 <fstat+0x6f>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8013bc:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8013c1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013c4:	c9                   	leave  
  8013c5:	c3                   	ret    

008013c6 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8013c6:	55                   	push   %ebp
  8013c7:	89 e5                	mov    %esp,%ebp
  8013c9:	56                   	push   %esi
  8013ca:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8013cb:	83 ec 08             	sub    $0x8,%esp
  8013ce:	6a 00                	push   $0x0
  8013d0:	ff 75 08             	pushl  0x8(%ebp)
  8013d3:	e8 78 01 00 00       	call   801550 <open>
  8013d8:	89 c3                	mov    %eax,%ebx
  8013da:	83 c4 10             	add    $0x10,%esp
  8013dd:	85 c0                	test   %eax,%eax
  8013df:	78 1b                	js     8013fc <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8013e1:	83 ec 08             	sub    $0x8,%esp
  8013e4:	ff 75 0c             	pushl  0xc(%ebp)
  8013e7:	50                   	push   %eax
  8013e8:	e8 65 ff ff ff       	call   801352 <fstat>
  8013ed:	89 c6                	mov    %eax,%esi
	close(fd);
  8013ef:	89 1c 24             	mov    %ebx,(%esp)
  8013f2:	e8 18 fc ff ff       	call   80100f <close>
	return r;
  8013f7:	83 c4 10             	add    $0x10,%esp
  8013fa:	89 f3                	mov    %esi,%ebx
}
  8013fc:	89 d8                	mov    %ebx,%eax
  8013fe:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801401:	5b                   	pop    %ebx
  801402:	5e                   	pop    %esi
  801403:	c9                   	leave  
  801404:	c3                   	ret    
  801405:	00 00                	add    %al,(%eax)
	...

00801408 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801408:	55                   	push   %ebp
  801409:	89 e5                	mov    %esp,%ebp
  80140b:	56                   	push   %esi
  80140c:	53                   	push   %ebx
  80140d:	89 c3                	mov    %eax,%ebx
  80140f:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  801411:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801418:	75 12                	jne    80142c <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80141a:	83 ec 0c             	sub    $0xc,%esp
  80141d:	6a 01                	push   $0x1
  80141f:	e8 8a 07 00 00       	call   801bae <ipc_find_env>
  801424:	a3 00 40 80 00       	mov    %eax,0x804000
  801429:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80142c:	6a 07                	push   $0x7
  80142e:	68 00 50 80 00       	push   $0x805000
  801433:	53                   	push   %ebx
  801434:	ff 35 00 40 80 00    	pushl  0x804000
  80143a:	e8 1a 07 00 00       	call   801b59 <ipc_send>
	
	return ipc_recv(NULL, dstva, NULL);
  80143f:	83 c4 0c             	add    $0xc,%esp
  801442:	6a 00                	push   $0x0
  801444:	56                   	push   %esi
  801445:	6a 00                	push   $0x0
  801447:	e8 98 06 00 00       	call   801ae4 <ipc_recv>
}
  80144c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80144f:	5b                   	pop    %ebx
  801450:	5e                   	pop    %esi
  801451:	c9                   	leave  
  801452:	c3                   	ret    

00801453 <devfile_stat>:
}


static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801453:	55                   	push   %ebp
  801454:	89 e5                	mov    %esp,%ebp
  801456:	53                   	push   %ebx
  801457:	83 ec 04             	sub    $0x4,%esp
  80145a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80145d:	8b 45 08             	mov    0x8(%ebp),%eax
  801460:	8b 40 0c             	mov    0xc(%eax),%eax
  801463:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0) {
  801468:	ba 00 00 00 00       	mov    $0x0,%edx
  80146d:	b8 05 00 00 00       	mov    $0x5,%eax
  801472:	e8 91 ff ff ff       	call   801408 <fsipc>
  801477:	85 c0                	test   %eax,%eax
  801479:	78 2c                	js     8014a7 <devfile_stat+0x54>
		return r;
	}
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80147b:	83 ec 08             	sub    $0x8,%esp
  80147e:	68 00 50 80 00       	push   $0x805000
  801483:	53                   	push   %ebx
  801484:	e8 29 f3 ff ff       	call   8007b2 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801489:	a1 80 50 80 00       	mov    0x805080,%eax
  80148e:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801494:	a1 84 50 80 00       	mov    0x805084,%eax
  801499:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80149f:	83 c4 10             	add    $0x10,%esp
  8014a2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8014a7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014aa:	c9                   	leave  
  8014ab:	c3                   	ret    

008014ac <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8014ac:	55                   	push   %ebp
  8014ad:	89 e5                	mov    %esp,%ebp
  8014af:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8014b2:	8b 45 08             	mov    0x8(%ebp),%eax
  8014b5:	8b 40 0c             	mov    0xc(%eax),%eax
  8014b8:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8014bd:	ba 00 00 00 00       	mov    $0x0,%edx
  8014c2:	b8 06 00 00 00       	mov    $0x6,%eax
  8014c7:	e8 3c ff ff ff       	call   801408 <fsipc>
}
  8014cc:	c9                   	leave  
  8014cd:	c3                   	ret    

008014ce <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8014ce:	55                   	push   %ebp
  8014cf:	89 e5                	mov    %esp,%ebp
  8014d1:	56                   	push   %esi
  8014d2:	53                   	push   %ebx
  8014d3:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8014d6:	8b 45 08             	mov    0x8(%ebp),%eax
  8014d9:	8b 40 0c             	mov    0xc(%eax),%eax
  8014dc:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8014e1:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8014e7:	ba 00 00 00 00       	mov    $0x0,%edx
  8014ec:	b8 03 00 00 00       	mov    $0x3,%eax
  8014f1:	e8 12 ff ff ff       	call   801408 <fsipc>
  8014f6:	89 c3                	mov    %eax,%ebx
  8014f8:	85 c0                	test   %eax,%eax
  8014fa:	78 4b                	js     801547 <devfile_read+0x79>
		return r;
	assert(r <= n);
  8014fc:	39 c6                	cmp    %eax,%esi
  8014fe:	73 16                	jae    801516 <devfile_read+0x48>
  801500:	68 4c 23 80 00       	push   $0x80234c
  801505:	68 53 23 80 00       	push   $0x802353
  80150a:	6a 7d                	push   $0x7d
  80150c:	68 68 23 80 00       	push   $0x802368
  801511:	e8 0e ec ff ff       	call   800124 <_panic>
	assert(r <= PGSIZE);
  801516:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80151b:	7e 16                	jle    801533 <devfile_read+0x65>
  80151d:	68 73 23 80 00       	push   $0x802373
  801522:	68 53 23 80 00       	push   $0x802353
  801527:	6a 7e                	push   $0x7e
  801529:	68 68 23 80 00       	push   $0x802368
  80152e:	e8 f1 eb ff ff       	call   800124 <_panic>
	memmove(buf, &fsipcbuf, r);
  801533:	83 ec 04             	sub    $0x4,%esp
  801536:	50                   	push   %eax
  801537:	68 00 50 80 00       	push   $0x805000
  80153c:	ff 75 0c             	pushl  0xc(%ebp)
  80153f:	e8 2f f4 ff ff       	call   800973 <memmove>
	return r;
  801544:	83 c4 10             	add    $0x10,%esp
}
  801547:	89 d8                	mov    %ebx,%eax
  801549:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80154c:	5b                   	pop    %ebx
  80154d:	5e                   	pop    %esi
  80154e:	c9                   	leave  
  80154f:	c3                   	ret    

00801550 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801550:	55                   	push   %ebp
  801551:	89 e5                	mov    %esp,%ebp
  801553:	56                   	push   %esi
  801554:	53                   	push   %ebx
  801555:	83 ec 1c             	sub    $0x1c,%esp
  801558:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  80155b:	56                   	push   %esi
  80155c:	e8 ff f1 ff ff       	call   800760 <strlen>
  801561:	83 c4 10             	add    $0x10,%esp
  801564:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801569:	7f 65                	jg     8015d0 <open+0x80>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80156b:	83 ec 0c             	sub    $0xc,%esp
  80156e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801571:	50                   	push   %eax
  801572:	e8 e1 f8 ff ff       	call   800e58 <fd_alloc>
  801577:	89 c3                	mov    %eax,%ebx
  801579:	83 c4 10             	add    $0x10,%esp
  80157c:	85 c0                	test   %eax,%eax
  80157e:	78 55                	js     8015d5 <open+0x85>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801580:	83 ec 08             	sub    $0x8,%esp
  801583:	56                   	push   %esi
  801584:	68 00 50 80 00       	push   $0x805000
  801589:	e8 24 f2 ff ff       	call   8007b2 <strcpy>
	fsipcbuf.open.req_omode = mode;
  80158e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801591:	a3 00 54 80 00       	mov    %eax,0x805400



	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801596:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801599:	b8 01 00 00 00       	mov    $0x1,%eax
  80159e:	e8 65 fe ff ff       	call   801408 <fsipc>
  8015a3:	89 c3                	mov    %eax,%ebx
  8015a5:	83 c4 10             	add    $0x10,%esp
  8015a8:	85 c0                	test   %eax,%eax
  8015aa:	79 12                	jns    8015be <open+0x6e>
		fd_close(fd, 0);
  8015ac:	83 ec 08             	sub    $0x8,%esp
  8015af:	6a 00                	push   $0x0
  8015b1:	ff 75 f4             	pushl  -0xc(%ebp)
  8015b4:	e8 ce f9 ff ff       	call   800f87 <fd_close>
		return r;
  8015b9:	83 c4 10             	add    $0x10,%esp
  8015bc:	eb 17                	jmp    8015d5 <open+0x85>
	}

	return fd2num(fd);
  8015be:	83 ec 0c             	sub    $0xc,%esp
  8015c1:	ff 75 f4             	pushl  -0xc(%ebp)
  8015c4:	e8 67 f8 ff ff       	call   800e30 <fd2num>
  8015c9:	89 c3                	mov    %eax,%ebx
  8015cb:	83 c4 10             	add    $0x10,%esp
  8015ce:	eb 05                	jmp    8015d5 <open+0x85>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8015d0:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8015d5:	89 d8                	mov    %ebx,%eax
  8015d7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8015da:	5b                   	pop    %ebx
  8015db:	5e                   	pop    %esi
  8015dc:	c9                   	leave  
  8015dd:	c3                   	ret    
	...

008015e0 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8015e0:	55                   	push   %ebp
  8015e1:	89 e5                	mov    %esp,%ebp
  8015e3:	56                   	push   %esi
  8015e4:	53                   	push   %ebx
  8015e5:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8015e8:	83 ec 0c             	sub    $0xc,%esp
  8015eb:	ff 75 08             	pushl  0x8(%ebp)
  8015ee:	e8 4d f8 ff ff       	call   800e40 <fd2data>
  8015f3:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  8015f5:	83 c4 08             	add    $0x8,%esp
  8015f8:	68 7f 23 80 00       	push   $0x80237f
  8015fd:	56                   	push   %esi
  8015fe:	e8 af f1 ff ff       	call   8007b2 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801603:	8b 43 04             	mov    0x4(%ebx),%eax
  801606:	2b 03                	sub    (%ebx),%eax
  801608:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  80160e:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  801615:	00 00 00 
	stat->st_dev = &devpipe;
  801618:	c7 86 88 00 00 00 20 	movl   $0x803020,0x88(%esi)
  80161f:	30 80 00 
	return 0;
}
  801622:	b8 00 00 00 00       	mov    $0x0,%eax
  801627:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80162a:	5b                   	pop    %ebx
  80162b:	5e                   	pop    %esi
  80162c:	c9                   	leave  
  80162d:	c3                   	ret    

0080162e <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  80162e:	55                   	push   %ebp
  80162f:	89 e5                	mov    %esp,%ebp
  801631:	53                   	push   %ebx
  801632:	83 ec 0c             	sub    $0xc,%esp
  801635:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801638:	53                   	push   %ebx
  801639:	6a 00                	push   $0x0
  80163b:	e8 3e f6 ff ff       	call   800c7e <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801640:	89 1c 24             	mov    %ebx,(%esp)
  801643:	e8 f8 f7 ff ff       	call   800e40 <fd2data>
  801648:	83 c4 08             	add    $0x8,%esp
  80164b:	50                   	push   %eax
  80164c:	6a 00                	push   $0x0
  80164e:	e8 2b f6 ff ff       	call   800c7e <sys_page_unmap>
}
  801653:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801656:	c9                   	leave  
  801657:	c3                   	ret    

00801658 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801658:	55                   	push   %ebp
  801659:	89 e5                	mov    %esp,%ebp
  80165b:	57                   	push   %edi
  80165c:	56                   	push   %esi
  80165d:	53                   	push   %ebx
  80165e:	83 ec 1c             	sub    $0x1c,%esp
  801661:	89 c7                	mov    %eax,%edi
  801663:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801666:	a1 04 40 80 00       	mov    0x804004,%eax
  80166b:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  80166e:	83 ec 0c             	sub    $0xc,%esp
  801671:	57                   	push   %edi
  801672:	e8 95 05 00 00       	call   801c0c <pageref>
  801677:	89 c6                	mov    %eax,%esi
  801679:	83 c4 04             	add    $0x4,%esp
  80167c:	ff 75 e4             	pushl  -0x1c(%ebp)
  80167f:	e8 88 05 00 00       	call   801c0c <pageref>
  801684:	83 c4 10             	add    $0x10,%esp
  801687:	39 c6                	cmp    %eax,%esi
  801689:	0f 94 c0             	sete   %al
  80168c:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  80168f:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801695:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801698:	39 cb                	cmp    %ecx,%ebx
  80169a:	75 08                	jne    8016a4 <_pipeisclosed+0x4c>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  80169c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80169f:	5b                   	pop    %ebx
  8016a0:	5e                   	pop    %esi
  8016a1:	5f                   	pop    %edi
  8016a2:	c9                   	leave  
  8016a3:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  8016a4:	83 f8 01             	cmp    $0x1,%eax
  8016a7:	75 bd                	jne    801666 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8016a9:	8b 42 58             	mov    0x58(%edx),%eax
  8016ac:	6a 01                	push   $0x1
  8016ae:	50                   	push   %eax
  8016af:	53                   	push   %ebx
  8016b0:	68 86 23 80 00       	push   $0x802386
  8016b5:	e8 42 eb ff ff       	call   8001fc <cprintf>
  8016ba:	83 c4 10             	add    $0x10,%esp
  8016bd:	eb a7                	jmp    801666 <_pipeisclosed+0xe>

008016bf <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8016bf:	55                   	push   %ebp
  8016c0:	89 e5                	mov    %esp,%ebp
  8016c2:	57                   	push   %edi
  8016c3:	56                   	push   %esi
  8016c4:	53                   	push   %ebx
  8016c5:	83 ec 28             	sub    $0x28,%esp
  8016c8:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  8016cb:	56                   	push   %esi
  8016cc:	e8 6f f7 ff ff       	call   800e40 <fd2data>
  8016d1:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8016d3:	83 c4 10             	add    $0x10,%esp
  8016d6:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8016da:	75 4a                	jne    801726 <devpipe_write+0x67>
  8016dc:	bf 00 00 00 00       	mov    $0x0,%edi
  8016e1:	eb 56                	jmp    801739 <devpipe_write+0x7a>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  8016e3:	89 da                	mov    %ebx,%edx
  8016e5:	89 f0                	mov    %esi,%eax
  8016e7:	e8 6c ff ff ff       	call   801658 <_pipeisclosed>
  8016ec:	85 c0                	test   %eax,%eax
  8016ee:	75 4d                	jne    80173d <devpipe_write+0x7e>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  8016f0:	e8 18 f5 ff ff       	call   800c0d <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8016f5:	8b 43 04             	mov    0x4(%ebx),%eax
  8016f8:	8b 13                	mov    (%ebx),%edx
  8016fa:	83 c2 20             	add    $0x20,%edx
  8016fd:	39 d0                	cmp    %edx,%eax
  8016ff:	73 e2                	jae    8016e3 <devpipe_write+0x24>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801701:	89 c2                	mov    %eax,%edx
  801703:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  801709:	79 05                	jns    801710 <devpipe_write+0x51>
  80170b:	4a                   	dec    %edx
  80170c:	83 ca e0             	or     $0xffffffe0,%edx
  80170f:	42                   	inc    %edx
  801710:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801713:	8a 0c 39             	mov    (%ecx,%edi,1),%cl
  801716:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  80171a:	40                   	inc    %eax
  80171b:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80171e:	47                   	inc    %edi
  80171f:	39 7d 10             	cmp    %edi,0x10(%ebp)
  801722:	77 07                	ja     80172b <devpipe_write+0x6c>
  801724:	eb 13                	jmp    801739 <devpipe_write+0x7a>
  801726:	bf 00 00 00 00       	mov    $0x0,%edi
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  80172b:	8b 43 04             	mov    0x4(%ebx),%eax
  80172e:	8b 13                	mov    (%ebx),%edx
  801730:	83 c2 20             	add    $0x20,%edx
  801733:	39 d0                	cmp    %edx,%eax
  801735:	73 ac                	jae    8016e3 <devpipe_write+0x24>
  801737:	eb c8                	jmp    801701 <devpipe_write+0x42>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801739:	89 f8                	mov    %edi,%eax
  80173b:	eb 05                	jmp    801742 <devpipe_write+0x83>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80173d:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801742:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801745:	5b                   	pop    %ebx
  801746:	5e                   	pop    %esi
  801747:	5f                   	pop    %edi
  801748:	c9                   	leave  
  801749:	c3                   	ret    

0080174a <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  80174a:	55                   	push   %ebp
  80174b:	89 e5                	mov    %esp,%ebp
  80174d:	57                   	push   %edi
  80174e:	56                   	push   %esi
  80174f:	53                   	push   %ebx
  801750:	83 ec 18             	sub    $0x18,%esp
  801753:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801756:	57                   	push   %edi
  801757:	e8 e4 f6 ff ff       	call   800e40 <fd2data>
  80175c:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80175e:	83 c4 10             	add    $0x10,%esp
  801761:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801765:	75 44                	jne    8017ab <devpipe_read+0x61>
  801767:	be 00 00 00 00       	mov    $0x0,%esi
  80176c:	eb 4f                	jmp    8017bd <devpipe_read+0x73>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
				return i;
  80176e:	89 f0                	mov    %esi,%eax
  801770:	eb 54                	jmp    8017c6 <devpipe_read+0x7c>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801772:	89 da                	mov    %ebx,%edx
  801774:	89 f8                	mov    %edi,%eax
  801776:	e8 dd fe ff ff       	call   801658 <_pipeisclosed>
  80177b:	85 c0                	test   %eax,%eax
  80177d:	75 42                	jne    8017c1 <devpipe_read+0x77>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  80177f:	e8 89 f4 ff ff       	call   800c0d <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801784:	8b 03                	mov    (%ebx),%eax
  801786:	3b 43 04             	cmp    0x4(%ebx),%eax
  801789:	74 e7                	je     801772 <devpipe_read+0x28>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  80178b:	25 1f 00 00 80       	and    $0x8000001f,%eax
  801790:	79 05                	jns    801797 <devpipe_read+0x4d>
  801792:	48                   	dec    %eax
  801793:	83 c8 e0             	or     $0xffffffe0,%eax
  801796:	40                   	inc    %eax
  801797:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  80179b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80179e:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  8017a1:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8017a3:	46                   	inc    %esi
  8017a4:	39 75 10             	cmp    %esi,0x10(%ebp)
  8017a7:	77 07                	ja     8017b0 <devpipe_read+0x66>
  8017a9:	eb 12                	jmp    8017bd <devpipe_read+0x73>
  8017ab:	be 00 00 00 00       	mov    $0x0,%esi
		while (p->p_rpos == p->p_wpos) {
  8017b0:	8b 03                	mov    (%ebx),%eax
  8017b2:	3b 43 04             	cmp    0x4(%ebx),%eax
  8017b5:	75 d4                	jne    80178b <devpipe_read+0x41>
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  8017b7:	85 f6                	test   %esi,%esi
  8017b9:	75 b3                	jne    80176e <devpipe_read+0x24>
  8017bb:	eb b5                	jmp    801772 <devpipe_read+0x28>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  8017bd:	89 f0                	mov    %esi,%eax
  8017bf:	eb 05                	jmp    8017c6 <devpipe_read+0x7c>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8017c1:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  8017c6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8017c9:	5b                   	pop    %ebx
  8017ca:	5e                   	pop    %esi
  8017cb:	5f                   	pop    %edi
  8017cc:	c9                   	leave  
  8017cd:	c3                   	ret    

008017ce <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  8017ce:	55                   	push   %ebp
  8017cf:	89 e5                	mov    %esp,%ebp
  8017d1:	57                   	push   %edi
  8017d2:	56                   	push   %esi
  8017d3:	53                   	push   %ebx
  8017d4:	83 ec 28             	sub    $0x28,%esp
  8017d7:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  8017da:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8017dd:	50                   	push   %eax
  8017de:	e8 75 f6 ff ff       	call   800e58 <fd_alloc>
  8017e3:	89 c3                	mov    %eax,%ebx
  8017e5:	83 c4 10             	add    $0x10,%esp
  8017e8:	85 c0                	test   %eax,%eax
  8017ea:	0f 88 24 01 00 00    	js     801914 <pipe+0x146>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8017f0:	83 ec 04             	sub    $0x4,%esp
  8017f3:	68 07 04 00 00       	push   $0x407
  8017f8:	ff 75 e4             	pushl  -0x1c(%ebp)
  8017fb:	6a 00                	push   $0x0
  8017fd:	e8 32 f4 ff ff       	call   800c34 <sys_page_alloc>
  801802:	89 c3                	mov    %eax,%ebx
  801804:	83 c4 10             	add    $0x10,%esp
  801807:	85 c0                	test   %eax,%eax
  801809:	0f 88 05 01 00 00    	js     801914 <pipe+0x146>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  80180f:	83 ec 0c             	sub    $0xc,%esp
  801812:	8d 45 e0             	lea    -0x20(%ebp),%eax
  801815:	50                   	push   %eax
  801816:	e8 3d f6 ff ff       	call   800e58 <fd_alloc>
  80181b:	89 c3                	mov    %eax,%ebx
  80181d:	83 c4 10             	add    $0x10,%esp
  801820:	85 c0                	test   %eax,%eax
  801822:	0f 88 dc 00 00 00    	js     801904 <pipe+0x136>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801828:	83 ec 04             	sub    $0x4,%esp
  80182b:	68 07 04 00 00       	push   $0x407
  801830:	ff 75 e0             	pushl  -0x20(%ebp)
  801833:	6a 00                	push   $0x0
  801835:	e8 fa f3 ff ff       	call   800c34 <sys_page_alloc>
  80183a:	89 c3                	mov    %eax,%ebx
  80183c:	83 c4 10             	add    $0x10,%esp
  80183f:	85 c0                	test   %eax,%eax
  801841:	0f 88 bd 00 00 00    	js     801904 <pipe+0x136>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801847:	83 ec 0c             	sub    $0xc,%esp
  80184a:	ff 75 e4             	pushl  -0x1c(%ebp)
  80184d:	e8 ee f5 ff ff       	call   800e40 <fd2data>
  801852:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801854:	83 c4 0c             	add    $0xc,%esp
  801857:	68 07 04 00 00       	push   $0x407
  80185c:	50                   	push   %eax
  80185d:	6a 00                	push   $0x0
  80185f:	e8 d0 f3 ff ff       	call   800c34 <sys_page_alloc>
  801864:	89 c3                	mov    %eax,%ebx
  801866:	83 c4 10             	add    $0x10,%esp
  801869:	85 c0                	test   %eax,%eax
  80186b:	0f 88 83 00 00 00    	js     8018f4 <pipe+0x126>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801871:	83 ec 0c             	sub    $0xc,%esp
  801874:	ff 75 e0             	pushl  -0x20(%ebp)
  801877:	e8 c4 f5 ff ff       	call   800e40 <fd2data>
  80187c:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801883:	50                   	push   %eax
  801884:	6a 00                	push   $0x0
  801886:	56                   	push   %esi
  801887:	6a 00                	push   $0x0
  801889:	e8 ca f3 ff ff       	call   800c58 <sys_page_map>
  80188e:	89 c3                	mov    %eax,%ebx
  801890:	83 c4 20             	add    $0x20,%esp
  801893:	85 c0                	test   %eax,%eax
  801895:	78 4f                	js     8018e6 <pipe+0x118>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801897:	8b 15 20 30 80 00    	mov    0x803020,%edx
  80189d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8018a0:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8018a2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8018a5:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8018ac:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8018b2:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8018b5:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8018b7:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8018ba:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  8018c1:	83 ec 0c             	sub    $0xc,%esp
  8018c4:	ff 75 e4             	pushl  -0x1c(%ebp)
  8018c7:	e8 64 f5 ff ff       	call   800e30 <fd2num>
  8018cc:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  8018ce:	83 c4 04             	add    $0x4,%esp
  8018d1:	ff 75 e0             	pushl  -0x20(%ebp)
  8018d4:	e8 57 f5 ff ff       	call   800e30 <fd2num>
  8018d9:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  8018dc:	83 c4 10             	add    $0x10,%esp
  8018df:	bb 00 00 00 00       	mov    $0x0,%ebx
  8018e4:	eb 2e                	jmp    801914 <pipe+0x146>

    err3:
	sys_page_unmap(0, va);
  8018e6:	83 ec 08             	sub    $0x8,%esp
  8018e9:	56                   	push   %esi
  8018ea:	6a 00                	push   $0x0
  8018ec:	e8 8d f3 ff ff       	call   800c7e <sys_page_unmap>
  8018f1:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  8018f4:	83 ec 08             	sub    $0x8,%esp
  8018f7:	ff 75 e0             	pushl  -0x20(%ebp)
  8018fa:	6a 00                	push   $0x0
  8018fc:	e8 7d f3 ff ff       	call   800c7e <sys_page_unmap>
  801901:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801904:	83 ec 08             	sub    $0x8,%esp
  801907:	ff 75 e4             	pushl  -0x1c(%ebp)
  80190a:	6a 00                	push   $0x0
  80190c:	e8 6d f3 ff ff       	call   800c7e <sys_page_unmap>
  801911:	83 c4 10             	add    $0x10,%esp
    err:
	return r;
}
  801914:	89 d8                	mov    %ebx,%eax
  801916:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801919:	5b                   	pop    %ebx
  80191a:	5e                   	pop    %esi
  80191b:	5f                   	pop    %edi
  80191c:	c9                   	leave  
  80191d:	c3                   	ret    

0080191e <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  80191e:	55                   	push   %ebp
  80191f:	89 e5                	mov    %esp,%ebp
  801921:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801924:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801927:	50                   	push   %eax
  801928:	ff 75 08             	pushl  0x8(%ebp)
  80192b:	e8 9b f5 ff ff       	call   800ecb <fd_lookup>
  801930:	83 c4 10             	add    $0x10,%esp
  801933:	85 c0                	test   %eax,%eax
  801935:	78 18                	js     80194f <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801937:	83 ec 0c             	sub    $0xc,%esp
  80193a:	ff 75 f4             	pushl  -0xc(%ebp)
  80193d:	e8 fe f4 ff ff       	call   800e40 <fd2data>
	return _pipeisclosed(fd, p);
  801942:	89 c2                	mov    %eax,%edx
  801944:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801947:	e8 0c fd ff ff       	call   801658 <_pipeisclosed>
  80194c:	83 c4 10             	add    $0x10,%esp
}
  80194f:	c9                   	leave  
  801950:	c3                   	ret    
  801951:	00 00                	add    %al,(%eax)
	...

00801954 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801954:	55                   	push   %ebp
  801955:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801957:	b8 00 00 00 00       	mov    $0x0,%eax
  80195c:	c9                   	leave  
  80195d:	c3                   	ret    

0080195e <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80195e:	55                   	push   %ebp
  80195f:	89 e5                	mov    %esp,%ebp
  801961:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801964:	68 9e 23 80 00       	push   $0x80239e
  801969:	ff 75 0c             	pushl  0xc(%ebp)
  80196c:	e8 41 ee ff ff       	call   8007b2 <strcpy>
	return 0;
}
  801971:	b8 00 00 00 00       	mov    $0x0,%eax
  801976:	c9                   	leave  
  801977:	c3                   	ret    

00801978 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801978:	55                   	push   %ebp
  801979:	89 e5                	mov    %esp,%ebp
  80197b:	57                   	push   %edi
  80197c:	56                   	push   %esi
  80197d:	53                   	push   %ebx
  80197e:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801984:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801988:	74 45                	je     8019cf <devcons_write+0x57>
  80198a:	b8 00 00 00 00       	mov    $0x0,%eax
  80198f:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801994:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  80199a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80199d:	29 c3                	sub    %eax,%ebx
		if (m > sizeof(buf) - 1)
  80199f:	83 fb 7f             	cmp    $0x7f,%ebx
  8019a2:	76 05                	jbe    8019a9 <devcons_write+0x31>
			m = sizeof(buf) - 1;
  8019a4:	bb 7f 00 00 00       	mov    $0x7f,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  8019a9:	83 ec 04             	sub    $0x4,%esp
  8019ac:	53                   	push   %ebx
  8019ad:	03 45 0c             	add    0xc(%ebp),%eax
  8019b0:	50                   	push   %eax
  8019b1:	57                   	push   %edi
  8019b2:	e8 bc ef ff ff       	call   800973 <memmove>
		sys_cputs(buf, m);
  8019b7:	83 c4 08             	add    $0x8,%esp
  8019ba:	53                   	push   %ebx
  8019bb:	57                   	push   %edi
  8019bc:	e8 bc f1 ff ff       	call   800b7d <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8019c1:	01 de                	add    %ebx,%esi
  8019c3:	89 f0                	mov    %esi,%eax
  8019c5:	83 c4 10             	add    $0x10,%esp
  8019c8:	3b 75 10             	cmp    0x10(%ebp),%esi
  8019cb:	72 cd                	jb     80199a <devcons_write+0x22>
  8019cd:	eb 05                	jmp    8019d4 <devcons_write+0x5c>
  8019cf:	be 00 00 00 00       	mov    $0x0,%esi
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8019d4:	89 f0                	mov    %esi,%eax
  8019d6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8019d9:	5b                   	pop    %ebx
  8019da:	5e                   	pop    %esi
  8019db:	5f                   	pop    %edi
  8019dc:	c9                   	leave  
  8019dd:	c3                   	ret    

008019de <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8019de:	55                   	push   %ebp
  8019df:	89 e5                	mov    %esp,%ebp
  8019e1:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  8019e4:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8019e8:	75 07                	jne    8019f1 <devcons_read+0x13>
  8019ea:	eb 25                	jmp    801a11 <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8019ec:	e8 1c f2 ff ff       	call   800c0d <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8019f1:	e8 ad f1 ff ff       	call   800ba3 <sys_cgetc>
  8019f6:	85 c0                	test   %eax,%eax
  8019f8:	74 f2                	je     8019ec <devcons_read+0xe>
  8019fa:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  8019fc:	85 c0                	test   %eax,%eax
  8019fe:	78 1d                	js     801a1d <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801a00:	83 f8 04             	cmp    $0x4,%eax
  801a03:	74 13                	je     801a18 <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  801a05:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a08:	88 10                	mov    %dl,(%eax)
	return 1;
  801a0a:	b8 01 00 00 00       	mov    $0x1,%eax
  801a0f:	eb 0c                	jmp    801a1d <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  801a11:	b8 00 00 00 00       	mov    $0x0,%eax
  801a16:	eb 05                	jmp    801a1d <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801a18:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801a1d:	c9                   	leave  
  801a1e:	c3                   	ret    

00801a1f <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801a1f:	55                   	push   %ebp
  801a20:	89 e5                	mov    %esp,%ebp
  801a22:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801a25:	8b 45 08             	mov    0x8(%ebp),%eax
  801a28:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801a2b:	6a 01                	push   $0x1
  801a2d:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801a30:	50                   	push   %eax
  801a31:	e8 47 f1 ff ff       	call   800b7d <sys_cputs>
  801a36:	83 c4 10             	add    $0x10,%esp
}
  801a39:	c9                   	leave  
  801a3a:	c3                   	ret    

00801a3b <getchar>:

int
getchar(void)
{
  801a3b:	55                   	push   %ebp
  801a3c:	89 e5                	mov    %esp,%ebp
  801a3e:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801a41:	6a 01                	push   $0x1
  801a43:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801a46:	50                   	push   %eax
  801a47:	6a 00                	push   $0x0
  801a49:	e8 fe f6 ff ff       	call   80114c <read>
	if (r < 0)
  801a4e:	83 c4 10             	add    $0x10,%esp
  801a51:	85 c0                	test   %eax,%eax
  801a53:	78 0f                	js     801a64 <getchar+0x29>
		return r;
	if (r < 1)
  801a55:	85 c0                	test   %eax,%eax
  801a57:	7e 06                	jle    801a5f <getchar+0x24>
		return -E_EOF;
	return c;
  801a59:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801a5d:	eb 05                	jmp    801a64 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801a5f:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801a64:	c9                   	leave  
  801a65:	c3                   	ret    

00801a66 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801a66:	55                   	push   %ebp
  801a67:	89 e5                	mov    %esp,%ebp
  801a69:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801a6c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a6f:	50                   	push   %eax
  801a70:	ff 75 08             	pushl  0x8(%ebp)
  801a73:	e8 53 f4 ff ff       	call   800ecb <fd_lookup>
  801a78:	83 c4 10             	add    $0x10,%esp
  801a7b:	85 c0                	test   %eax,%eax
  801a7d:	78 11                	js     801a90 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801a7f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a82:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801a88:	39 10                	cmp    %edx,(%eax)
  801a8a:	0f 94 c0             	sete   %al
  801a8d:	0f b6 c0             	movzbl %al,%eax
}
  801a90:	c9                   	leave  
  801a91:	c3                   	ret    

00801a92 <opencons>:

int
opencons(void)
{
  801a92:	55                   	push   %ebp
  801a93:	89 e5                	mov    %esp,%ebp
  801a95:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801a98:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a9b:	50                   	push   %eax
  801a9c:	e8 b7 f3 ff ff       	call   800e58 <fd_alloc>
  801aa1:	83 c4 10             	add    $0x10,%esp
  801aa4:	85 c0                	test   %eax,%eax
  801aa6:	78 3a                	js     801ae2 <opencons+0x50>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801aa8:	83 ec 04             	sub    $0x4,%esp
  801aab:	68 07 04 00 00       	push   $0x407
  801ab0:	ff 75 f4             	pushl  -0xc(%ebp)
  801ab3:	6a 00                	push   $0x0
  801ab5:	e8 7a f1 ff ff       	call   800c34 <sys_page_alloc>
  801aba:	83 c4 10             	add    $0x10,%esp
  801abd:	85 c0                	test   %eax,%eax
  801abf:	78 21                	js     801ae2 <opencons+0x50>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801ac1:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801ac7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801aca:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801acc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801acf:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801ad6:	83 ec 0c             	sub    $0xc,%esp
  801ad9:	50                   	push   %eax
  801ada:	e8 51 f3 ff ff       	call   800e30 <fd2num>
  801adf:	83 c4 10             	add    $0x10,%esp
}
  801ae2:	c9                   	leave  
  801ae3:	c3                   	ret    

00801ae4 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801ae4:	55                   	push   %ebp
  801ae5:	89 e5                	mov    %esp,%ebp
  801ae7:	56                   	push   %esi
  801ae8:	53                   	push   %ebx
  801ae9:	8b 75 08             	mov    0x8(%ebp),%esi
  801aec:	8b 45 0c             	mov    0xc(%ebp),%eax
  801aef:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// cprintf("0x%x 0x%x 0x%x\n", (uint32_t)from_env_store, (uint32_t)pg, (uint32_t)perm_store);
	int r;
	if (pg != NULL) {
  801af2:	85 c0                	test   %eax,%eax
  801af4:	74 0e                	je     801b04 <ipc_recv+0x20>
		r = sys_ipc_recv(pg);
  801af6:	83 ec 0c             	sub    $0xc,%esp
  801af9:	50                   	push   %eax
  801afa:	e8 30 f2 ff ff       	call   800d2f <sys_ipc_recv>
  801aff:	83 c4 10             	add    $0x10,%esp
  801b02:	eb 10                	jmp    801b14 <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv((void *)UTOP);
  801b04:	83 ec 0c             	sub    $0xc,%esp
  801b07:	68 00 00 c0 ee       	push   $0xeec00000
  801b0c:	e8 1e f2 ff ff       	call   800d2f <sys_ipc_recv>
  801b11:	83 c4 10             	add    $0x10,%esp
	}

	if (r == 0) {
  801b14:	85 c0                	test   %eax,%eax
  801b16:	75 26                	jne    801b3e <ipc_recv+0x5a>
		if (from_env_store != NULL) *from_env_store = thisenv->env_ipc_from;
  801b18:	85 f6                	test   %esi,%esi
  801b1a:	74 0a                	je     801b26 <ipc_recv+0x42>
  801b1c:	a1 04 40 80 00       	mov    0x804004,%eax
  801b21:	8b 40 74             	mov    0x74(%eax),%eax
  801b24:	89 06                	mov    %eax,(%esi)
		if (perm_store != NULL) *perm_store = thisenv->env_ipc_perm;
  801b26:	85 db                	test   %ebx,%ebx
  801b28:	74 0a                	je     801b34 <ipc_recv+0x50>
  801b2a:	a1 04 40 80 00       	mov    0x804004,%eax
  801b2f:	8b 40 78             	mov    0x78(%eax),%eax
  801b32:	89 03                	mov    %eax,(%ebx)
		return thisenv->env_ipc_value;
  801b34:	a1 04 40 80 00       	mov    0x804004,%eax
  801b39:	8b 40 70             	mov    0x70(%eax),%eax
  801b3c:	eb 14                	jmp    801b52 <ipc_recv+0x6e>
	} else {
		// fails;
		if (from_env_store != NULL) *from_env_store = 0;
  801b3e:	85 f6                	test   %esi,%esi
  801b40:	74 06                	je     801b48 <ipc_recv+0x64>
  801b42:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if (perm_store != NULL) *perm_store = 0;
  801b48:	85 db                	test   %ebx,%ebx
  801b4a:	74 06                	je     801b52 <ipc_recv+0x6e>
  801b4c:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		return r;
	}
}
  801b52:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b55:	5b                   	pop    %ebx
  801b56:	5e                   	pop    %esi
  801b57:	c9                   	leave  
  801b58:	c3                   	ret    

00801b59 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801b59:	55                   	push   %ebp
  801b5a:	89 e5                	mov    %esp,%ebp
  801b5c:	57                   	push   %edi
  801b5d:	56                   	push   %esi
  801b5e:	53                   	push   %ebx
  801b5f:	83 ec 0c             	sub    $0xc,%esp
  801b62:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801b65:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801b68:	8b 75 14             	mov    0x14(%ebp),%esi
	// LAB 4: Your code here.
	// int sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
	int r;
	if (pg == NULL) pg = (void *)UTOP;
  801b6b:	85 db                	test   %ebx,%ebx
  801b6d:	75 25                	jne    801b94 <ipc_send+0x3b>
  801b6f:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
  801b74:	eb 1e                	jmp    801b94 <ipc_send+0x3b>
	
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) != 0) {
		if (r == -E_IPC_NOT_RECV) {
  801b76:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801b79:	75 07                	jne    801b82 <ipc_send+0x29>
			// cprintf("Try Again and Again....\n");
			sys_yield();
  801b7b:	e8 8d f0 ff ff       	call   800c0d <sys_yield>
  801b80:	eb 12                	jmp    801b94 <ipc_send+0x3b>
		} else {
			panic("ipc_send error %e\n", r);
  801b82:	50                   	push   %eax
  801b83:	68 aa 23 80 00       	push   $0x8023aa
  801b88:	6a 43                	push   $0x43
  801b8a:	68 bd 23 80 00       	push   $0x8023bd
  801b8f:	e8 90 e5 ff ff       	call   800124 <_panic>
	// LAB 4: Your code here.
	// int sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
	int r;
	if (pg == NULL) pg = (void *)UTOP;
	
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) != 0) {
  801b94:	56                   	push   %esi
  801b95:	53                   	push   %ebx
  801b96:	57                   	push   %edi
  801b97:	ff 75 08             	pushl  0x8(%ebp)
  801b9a:	e8 6b f1 ff ff       	call   800d0a <sys_ipc_try_send>
  801b9f:	83 c4 10             	add    $0x10,%esp
  801ba2:	85 c0                	test   %eax,%eax
  801ba4:	75 d0                	jne    801b76 <ipc_send+0x1d>
		} else {
			panic("ipc_send error %e\n", r);
		}
	}
	return;
}
  801ba6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ba9:	5b                   	pop    %ebx
  801baa:	5e                   	pop    %esi
  801bab:	5f                   	pop    %edi
  801bac:	c9                   	leave  
  801bad:	c3                   	ret    

00801bae <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801bae:	55                   	push   %ebp
  801baf:	89 e5                	mov    %esp,%ebp
  801bb1:	53                   	push   %ebx
  801bb2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  801bb5:	39 1d 50 00 c0 ee    	cmp    %ebx,0xeec00050
  801bbb:	74 22                	je     801bdf <ipc_find_env+0x31>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801bbd:	b8 01 00 00 00       	mov    $0x1,%eax
		if (envs[i].env_type == type)
  801bc2:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  801bc9:	89 c2                	mov    %eax,%edx
  801bcb:	c1 e2 07             	shl    $0x7,%edx
  801bce:	29 ca                	sub    %ecx,%edx
  801bd0:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801bd6:	8b 52 50             	mov    0x50(%edx),%edx
  801bd9:	39 da                	cmp    %ebx,%edx
  801bdb:	75 1d                	jne    801bfa <ipc_find_env+0x4c>
  801bdd:	eb 05                	jmp    801be4 <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801bdf:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
			return envs[i].env_id;
  801be4:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  801beb:	c1 e0 07             	shl    $0x7,%eax
  801bee:	29 d0                	sub    %edx,%eax
  801bf0:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  801bf5:	8b 40 40             	mov    0x40(%eax),%eax
  801bf8:	eb 0c                	jmp    801c06 <ipc_find_env+0x58>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801bfa:	40                   	inc    %eax
  801bfb:	3d 00 04 00 00       	cmp    $0x400,%eax
  801c00:	75 c0                	jne    801bc2 <ipc_find_env+0x14>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801c02:	66 b8 00 00          	mov    $0x0,%ax
}
  801c06:	5b                   	pop    %ebx
  801c07:	c9                   	leave  
  801c08:	c3                   	ret    
  801c09:	00 00                	add    %al,(%eax)
	...

00801c0c <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801c0c:	55                   	push   %ebp
  801c0d:	89 e5                	mov    %esp,%ebp
  801c0f:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801c12:	89 c2                	mov    %eax,%edx
  801c14:	c1 ea 16             	shr    $0x16,%edx
  801c17:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801c1e:	f6 c2 01             	test   $0x1,%dl
  801c21:	74 1e                	je     801c41 <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  801c23:	c1 e8 0c             	shr    $0xc,%eax
  801c26:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801c2d:	a8 01                	test   $0x1,%al
  801c2f:	74 17                	je     801c48 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801c31:	c1 e8 0c             	shr    $0xc,%eax
  801c34:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  801c3b:	ef 
  801c3c:	0f b7 c0             	movzwl %ax,%eax
  801c3f:	eb 0c                	jmp    801c4d <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  801c41:	b8 00 00 00 00       	mov    $0x0,%eax
  801c46:	eb 05                	jmp    801c4d <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  801c48:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  801c4d:	c9                   	leave  
  801c4e:	c3                   	ret    
	...

00801c50 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  801c50:	55                   	push   %ebp
  801c51:	89 e5                	mov    %esp,%ebp
  801c53:	57                   	push   %edi
  801c54:	56                   	push   %esi
  801c55:	83 ec 10             	sub    $0x10,%esp
  801c58:	8b 7d 08             	mov    0x8(%ebp),%edi
  801c5b:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  801c5e:	89 7d f0             	mov    %edi,-0x10(%ebp)
  801c61:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  801c64:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  801c67:	8b 45 14             	mov    0x14(%ebp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  801c6a:	85 c0                	test   %eax,%eax
  801c6c:	75 2e                	jne    801c9c <__udivdi3+0x4c>
    {
      if (d0 > n1)
  801c6e:	39 f1                	cmp    %esi,%ecx
  801c70:	77 5a                	ja     801ccc <__udivdi3+0x7c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  801c72:	85 c9                	test   %ecx,%ecx
  801c74:	75 0b                	jne    801c81 <__udivdi3+0x31>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  801c76:	b8 01 00 00 00       	mov    $0x1,%eax
  801c7b:	31 d2                	xor    %edx,%edx
  801c7d:	f7 f1                	div    %ecx
  801c7f:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  801c81:	31 d2                	xor    %edx,%edx
  801c83:	89 f0                	mov    %esi,%eax
  801c85:	f7 f1                	div    %ecx
  801c87:	89 c6                	mov    %eax,%esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801c89:	89 f8                	mov    %edi,%eax
  801c8b:	f7 f1                	div    %ecx
  801c8d:	89 c7                	mov    %eax,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801c8f:	89 f8                	mov    %edi,%eax
  801c91:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801c93:	83 c4 10             	add    $0x10,%esp
  801c96:	5e                   	pop    %esi
  801c97:	5f                   	pop    %edi
  801c98:	c9                   	leave  
  801c99:	c3                   	ret    
  801c9a:	66 90                	xchg   %ax,%ax
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801c9c:	39 f0                	cmp    %esi,%eax
  801c9e:	77 1c                	ja     801cbc <__udivdi3+0x6c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  801ca0:	0f bd f8             	bsr    %eax,%edi
	  if (bm == 0)
  801ca3:	83 f7 1f             	xor    $0x1f,%edi
  801ca6:	75 3c                	jne    801ce4 <__udivdi3+0x94>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801ca8:	39 f0                	cmp    %esi,%eax
  801caa:	0f 82 90 00 00 00    	jb     801d40 <__udivdi3+0xf0>
  801cb0:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801cb3:	39 55 f4             	cmp    %edx,-0xc(%ebp)
  801cb6:	0f 86 84 00 00 00    	jbe    801d40 <__udivdi3+0xf0>
  801cbc:	31 f6                	xor    %esi,%esi
  801cbe:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801cc0:	89 f8                	mov    %edi,%eax
  801cc2:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801cc4:	83 c4 10             	add    $0x10,%esp
  801cc7:	5e                   	pop    %esi
  801cc8:	5f                   	pop    %edi
  801cc9:	c9                   	leave  
  801cca:	c3                   	ret    
  801ccb:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801ccc:	89 f2                	mov    %esi,%edx
  801cce:	89 f8                	mov    %edi,%eax
  801cd0:	f7 f1                	div    %ecx
  801cd2:	89 c7                	mov    %eax,%edi
  801cd4:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801cd6:	89 f8                	mov    %edi,%eax
  801cd8:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801cda:	83 c4 10             	add    $0x10,%esp
  801cdd:	5e                   	pop    %esi
  801cde:	5f                   	pop    %edi
  801cdf:	c9                   	leave  
  801ce0:	c3                   	ret    
  801ce1:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  801ce4:	89 f9                	mov    %edi,%ecx
  801ce6:	d3 e0                	shl    %cl,%eax
  801ce8:	89 45 e8             	mov    %eax,-0x18(%ebp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  801ceb:	b8 20 00 00 00       	mov    $0x20,%eax
  801cf0:	29 f8                	sub    %edi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  801cf2:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801cf5:	88 c1                	mov    %al,%cl
  801cf7:	d3 ea                	shr    %cl,%edx
  801cf9:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  801cfc:	09 ca                	or     %ecx,%edx
  801cfe:	89 55 ec             	mov    %edx,-0x14(%ebp)
	      d0 = d0 << bm;
  801d01:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801d04:	89 f9                	mov    %edi,%ecx
  801d06:	d3 e2                	shl    %cl,%edx
  801d08:	89 55 f4             	mov    %edx,-0xc(%ebp)
	      n2 = n1 >> b;
  801d0b:	89 f2                	mov    %esi,%edx
  801d0d:	88 c1                	mov    %al,%cl
  801d0f:	d3 ea                	shr    %cl,%edx
  801d11:	89 55 e8             	mov    %edx,-0x18(%ebp)
	      n1 = (n1 << bm) | (n0 >> b);
  801d14:	89 f2                	mov    %esi,%edx
  801d16:	89 f9                	mov    %edi,%ecx
  801d18:	d3 e2                	shl    %cl,%edx
  801d1a:	8b 75 f0             	mov    -0x10(%ebp),%esi
  801d1d:	88 c1                	mov    %al,%cl
  801d1f:	d3 ee                	shr    %cl,%esi
  801d21:	09 d6                	or     %edx,%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  801d23:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  801d26:	89 f0                	mov    %esi,%eax
  801d28:	89 ca                	mov    %ecx,%edx
  801d2a:	f7 75 ec             	divl   -0x14(%ebp)
  801d2d:	89 d1                	mov    %edx,%ecx
  801d2f:	89 c6                	mov    %eax,%esi
	      umul_ppmm (m1, m0, q0, d0);
  801d31:	f7 65 f4             	mull   -0xc(%ebp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801d34:	39 d1                	cmp    %edx,%ecx
  801d36:	72 28                	jb     801d60 <__udivdi3+0x110>
  801d38:	74 1a                	je     801d54 <__udivdi3+0x104>
  801d3a:	89 f7                	mov    %esi,%edi
  801d3c:	31 f6                	xor    %esi,%esi
  801d3e:	eb 80                	jmp    801cc0 <__udivdi3+0x70>
	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  801d40:	31 f6                	xor    %esi,%esi
  801d42:	bf 01 00 00 00       	mov    $0x1,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801d47:	89 f8                	mov    %edi,%eax
  801d49:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801d4b:	83 c4 10             	add    $0x10,%esp
  801d4e:	5e                   	pop    %esi
  801d4f:	5f                   	pop    %edi
  801d50:	c9                   	leave  
  801d51:	c3                   	ret    
  801d52:	66 90                	xchg   %ax,%ax

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  801d54:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801d57:	89 f9                	mov    %edi,%ecx
  801d59:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801d5b:	39 c2                	cmp    %eax,%edx
  801d5d:	73 db                	jae    801d3a <__udivdi3+0xea>
  801d5f:	90                   	nop
		{
		  q0--;
  801d60:	8d 7e ff             	lea    -0x1(%esi),%edi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  801d63:	31 f6                	xor    %esi,%esi
  801d65:	e9 56 ff ff ff       	jmp    801cc0 <__udivdi3+0x70>
	...

00801d6c <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  801d6c:	55                   	push   %ebp
  801d6d:	89 e5                	mov    %esp,%ebp
  801d6f:	57                   	push   %edi
  801d70:	56                   	push   %esi
  801d71:	83 ec 20             	sub    $0x20,%esp
  801d74:	8b 45 08             	mov    0x8(%ebp),%eax
  801d77:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  801d7a:	89 45 e8             	mov    %eax,-0x18(%ebp)
  801d7d:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  801d80:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  801d83:	8b 7d 14             	mov    0x14(%ebp),%edi
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  801d86:	89 45 f0             	mov    %eax,-0x10(%ebp)
  n1 = nn.s.high;
  801d89:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  801d8b:	85 ff                	test   %edi,%edi
  801d8d:	75 15                	jne    801da4 <__umoddi3+0x38>
    {
      if (d0 > n1)
  801d8f:	39 f1                	cmp    %esi,%ecx
  801d91:	0f 86 99 00 00 00    	jbe    801e30 <__umoddi3+0xc4>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801d97:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  801d99:	89 d0                	mov    %edx,%eax
  801d9b:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801d9d:	83 c4 20             	add    $0x20,%esp
  801da0:	5e                   	pop    %esi
  801da1:	5f                   	pop    %edi
  801da2:	c9                   	leave  
  801da3:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801da4:	39 f7                	cmp    %esi,%edi
  801da6:	0f 87 a4 00 00 00    	ja     801e50 <__umoddi3+0xe4>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  801dac:	0f bd c7             	bsr    %edi,%eax
	  if (bm == 0)
  801daf:	83 f0 1f             	xor    $0x1f,%eax
  801db2:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801db5:	0f 84 a1 00 00 00    	je     801e5c <__umoddi3+0xf0>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  801dbb:	89 f8                	mov    %edi,%eax
  801dbd:	8a 4d ec             	mov    -0x14(%ebp),%cl
  801dc0:	d3 e0                	shl    %cl,%eax
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  801dc2:	bf 20 00 00 00       	mov    $0x20,%edi
  801dc7:	2b 7d ec             	sub    -0x14(%ebp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  801dca:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801dcd:	89 f9                	mov    %edi,%ecx
  801dcf:	d3 ea                	shr    %cl,%edx
  801dd1:	09 c2                	or     %eax,%edx
  801dd3:	89 55 f0             	mov    %edx,-0x10(%ebp)
	      d0 = d0 << bm;
  801dd6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801dd9:	8a 4d ec             	mov    -0x14(%ebp),%cl
  801ddc:	d3 e0                	shl    %cl,%eax
  801dde:	89 45 f4             	mov    %eax,-0xc(%ebp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  801de1:	89 f2                	mov    %esi,%edx
  801de3:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  801de5:	8b 45 e8             	mov    -0x18(%ebp),%eax
  801de8:	d3 e0                	shl    %cl,%eax
  801dea:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  801ded:	8b 45 e8             	mov    -0x18(%ebp),%eax
  801df0:	89 f9                	mov    %edi,%ecx
  801df2:	d3 e8                	shr    %cl,%eax
  801df4:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  801df6:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  801df8:	89 f2                	mov    %esi,%edx
  801dfa:	f7 75 f0             	divl   -0x10(%ebp)
  801dfd:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  801dff:	f7 65 f4             	mull   -0xc(%ebp)
  801e02:	89 55 e8             	mov    %edx,-0x18(%ebp)
  801e05:	89 c1                	mov    %eax,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801e07:	39 d6                	cmp    %edx,%esi
  801e09:	72 71                	jb     801e7c <__umoddi3+0x110>
  801e0b:	74 7f                	je     801e8c <__umoddi3+0x120>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  801e0d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801e10:	29 c8                	sub    %ecx,%eax
  801e12:	19 d6                	sbb    %edx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  801e14:	8a 4d ec             	mov    -0x14(%ebp),%cl
  801e17:	d3 e8                	shr    %cl,%eax
  801e19:	89 f2                	mov    %esi,%edx
  801e1b:	89 f9                	mov    %edi,%ecx
  801e1d:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  801e1f:	09 d0                	or     %edx,%eax
  801e21:	89 f2                	mov    %esi,%edx
  801e23:	8a 4d ec             	mov    -0x14(%ebp),%cl
  801e26:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801e28:	83 c4 20             	add    $0x20,%esp
  801e2b:	5e                   	pop    %esi
  801e2c:	5f                   	pop    %edi
  801e2d:	c9                   	leave  
  801e2e:	c3                   	ret    
  801e2f:	90                   	nop
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  801e30:	85 c9                	test   %ecx,%ecx
  801e32:	75 0b                	jne    801e3f <__umoddi3+0xd3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  801e34:	b8 01 00 00 00       	mov    $0x1,%eax
  801e39:	31 d2                	xor    %edx,%edx
  801e3b:	f7 f1                	div    %ecx
  801e3d:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  801e3f:	89 f0                	mov    %esi,%eax
  801e41:	31 d2                	xor    %edx,%edx
  801e43:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801e45:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801e48:	f7 f1                	div    %ecx
  801e4a:	e9 4a ff ff ff       	jmp    801d99 <__umoddi3+0x2d>
  801e4f:	90                   	nop
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  801e50:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801e52:	83 c4 20             	add    $0x20,%esp
  801e55:	5e                   	pop    %esi
  801e56:	5f                   	pop    %edi
  801e57:	c9                   	leave  
  801e58:	c3                   	ret    
  801e59:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801e5c:	39 f7                	cmp    %esi,%edi
  801e5e:	72 05                	jb     801e65 <__umoddi3+0xf9>
  801e60:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
  801e63:	77 0c                	ja     801e71 <__umoddi3+0x105>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  801e65:	89 f2                	mov    %esi,%edx
  801e67:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801e6a:	29 c8                	sub    %ecx,%eax
  801e6c:	19 fa                	sbb    %edi,%edx
  801e6e:	89 45 f0             	mov    %eax,-0x10(%ebp)

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  801e71:	8b 45 f0             	mov    -0x10(%ebp),%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801e74:	83 c4 20             	add    $0x20,%esp
  801e77:	5e                   	pop    %esi
  801e78:	5f                   	pop    %edi
  801e79:	c9                   	leave  
  801e7a:	c3                   	ret    
  801e7b:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  801e7c:	8b 55 e8             	mov    -0x18(%ebp),%edx
  801e7f:	89 c1                	mov    %eax,%ecx
  801e81:	2b 4d f4             	sub    -0xc(%ebp),%ecx
  801e84:	1b 55 f0             	sbb    -0x10(%ebp),%edx
  801e87:	eb 84                	jmp    801e0d <__umoddi3+0xa1>
  801e89:	8d 76 00             	lea    0x0(%esi),%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801e8c:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801e8f:	72 eb                	jb     801e7c <__umoddi3+0x110>
  801e91:	89 f2                	mov    %esi,%edx
  801e93:	e9 75 ff ff ff       	jmp    801e0d <__umoddi3+0xa1>
