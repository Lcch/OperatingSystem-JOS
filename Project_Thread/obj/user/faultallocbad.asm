
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
  800041:	68 e0 1e 80 00       	push   $0x801ee0
  800046:	e8 ad 01 00 00       	call   8001f8 <cprintf>
	if ((r = sys_page_alloc(0, ROUNDDOWN(addr, PGSIZE),
  80004b:	83 c4 0c             	add    $0xc,%esp
  80004e:	6a 07                	push   $0x7
  800050:	89 d8                	mov    %ebx,%eax
  800052:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800057:	50                   	push   %eax
  800058:	6a 00                	push   $0x0
  80005a:	e8 d1 0b 00 00       	call   800c30 <sys_page_alloc>
  80005f:	83 c4 10             	add    $0x10,%esp
  800062:	85 c0                	test   %eax,%eax
  800064:	79 16                	jns    80007c <handler+0x48>
				PTE_P|PTE_U|PTE_W)) < 0)
		panic("allocating at %x in page fault handler: %e", addr, r);
  800066:	83 ec 0c             	sub    $0xc,%esp
  800069:	50                   	push   %eax
  80006a:	53                   	push   %ebx
  80006b:	68 00 1f 80 00       	push   $0x801f00
  800070:	6a 0f                	push   $0xf
  800072:	68 ea 1e 80 00       	push   $0x801eea
  800077:	e8 a4 00 00 00       	call   800120 <_panic>
	snprintf((char*) addr, 100, "this string was faulted in at %x", addr);
  80007c:	53                   	push   %ebx
  80007d:	68 2c 1f 80 00       	push   $0x801f2c
  800082:	6a 64                	push   $0x64
  800084:	53                   	push   %ebx
  800085:	e8 b6 06 00 00       	call   800740 <snprintf>
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
  80009d:	e8 3a 0d 00 00       	call   800ddc <set_pgfault_handler>
	sys_cputs((char*)0xDEADBEEF, 4);
  8000a2:	83 c4 08             	add    $0x8,%esp
  8000a5:	6a 04                	push   $0x4
  8000a7:	68 ef be ad de       	push   $0xdeadbeef
  8000ac:	e8 c8 0a 00 00       	call   800b79 <sys_cputs>
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
  8000c3:	e8 1d 0b 00 00       	call   800be5 <sys_getenvid>
  8000c8:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000cd:	89 c2                	mov    %eax,%edx
  8000cf:	c1 e2 07             	shl    $0x7,%edx
  8000d2:	8d 84 82 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,4),%eax
  8000d9:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000de:	85 f6                	test   %esi,%esi
  8000e0:	7e 07                	jle    8000e9 <libmain+0x31>
		binaryname = argv[0];
  8000e2:	8b 03                	mov    (%ebx),%eax
  8000e4:	a3 00 30 80 00       	mov    %eax,0x803000
	// call user main routine
	umain(argc, argv);
  8000e9:	83 ec 08             	sub    $0x8,%esp
  8000ec:	53                   	push   %ebx
  8000ed:	56                   	push   %esi
  8000ee:	e8 9f ff ff ff       	call   800092 <umain>

	// exit gracefully
	exit();
  8000f3:	e8 0c 00 00 00       	call   800104 <exit>
  8000f8:	83 c4 10             	add    $0x10,%esp
}
  8000fb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000fe:	5b                   	pop    %ebx
  8000ff:	5e                   	pop    %esi
  800100:	c9                   	leave  
  800101:	c3                   	ret    
	...

00800104 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800104:	55                   	push   %ebp
  800105:	89 e5                	mov    %esp,%ebp
  800107:	83 ec 08             	sub    $0x8,%esp
	close_all();
  80010a:	e8 6b 0f 00 00       	call   80107a <close_all>
	sys_env_destroy(0);
  80010f:	83 ec 0c             	sub    $0xc,%esp
  800112:	6a 00                	push   $0x0
  800114:	e8 aa 0a 00 00       	call   800bc3 <sys_env_destroy>
  800119:	83 c4 10             	add    $0x10,%esp
}
  80011c:	c9                   	leave  
  80011d:	c3                   	ret    
	...

00800120 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800120:	55                   	push   %ebp
  800121:	89 e5                	mov    %esp,%ebp
  800123:	56                   	push   %esi
  800124:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800125:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800128:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  80012e:	e8 b2 0a 00 00       	call   800be5 <sys_getenvid>
  800133:	83 ec 0c             	sub    $0xc,%esp
  800136:	ff 75 0c             	pushl  0xc(%ebp)
  800139:	ff 75 08             	pushl  0x8(%ebp)
  80013c:	53                   	push   %ebx
  80013d:	50                   	push   %eax
  80013e:	68 58 1f 80 00       	push   $0x801f58
  800143:	e8 b0 00 00 00       	call   8001f8 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800148:	83 c4 18             	add    $0x18,%esp
  80014b:	56                   	push   %esi
  80014c:	ff 75 10             	pushl  0x10(%ebp)
  80014f:	e8 53 00 00 00       	call   8001a7 <vcprintf>
	cprintf("\n");
  800154:	c7 04 24 d7 23 80 00 	movl   $0x8023d7,(%esp)
  80015b:	e8 98 00 00 00       	call   8001f8 <cprintf>
  800160:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800163:	cc                   	int3   
  800164:	eb fd                	jmp    800163 <_panic+0x43>
	...

00800168 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800168:	55                   	push   %ebp
  800169:	89 e5                	mov    %esp,%ebp
  80016b:	53                   	push   %ebx
  80016c:	83 ec 04             	sub    $0x4,%esp
  80016f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800172:	8b 03                	mov    (%ebx),%eax
  800174:	8b 55 08             	mov    0x8(%ebp),%edx
  800177:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  80017b:	40                   	inc    %eax
  80017c:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  80017e:	3d ff 00 00 00       	cmp    $0xff,%eax
  800183:	75 1a                	jne    80019f <putch+0x37>
		sys_cputs(b->buf, b->idx);
  800185:	83 ec 08             	sub    $0x8,%esp
  800188:	68 ff 00 00 00       	push   $0xff
  80018d:	8d 43 08             	lea    0x8(%ebx),%eax
  800190:	50                   	push   %eax
  800191:	e8 e3 09 00 00       	call   800b79 <sys_cputs>
		b->idx = 0;
  800196:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80019c:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80019f:	ff 43 04             	incl   0x4(%ebx)
}
  8001a2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001a5:	c9                   	leave  
  8001a6:	c3                   	ret    

008001a7 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001a7:	55                   	push   %ebp
  8001a8:	89 e5                	mov    %esp,%ebp
  8001aa:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001b0:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001b7:	00 00 00 
	b.cnt = 0;
  8001ba:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001c1:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001c4:	ff 75 0c             	pushl  0xc(%ebp)
  8001c7:	ff 75 08             	pushl  0x8(%ebp)
  8001ca:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001d0:	50                   	push   %eax
  8001d1:	68 68 01 80 00       	push   $0x800168
  8001d6:	e8 82 01 00 00       	call   80035d <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001db:	83 c4 08             	add    $0x8,%esp
  8001de:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8001e4:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001ea:	50                   	push   %eax
  8001eb:	e8 89 09 00 00       	call   800b79 <sys_cputs>

	return b.cnt;
}
  8001f0:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001f6:	c9                   	leave  
  8001f7:	c3                   	ret    

008001f8 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001f8:	55                   	push   %ebp
  8001f9:	89 e5                	mov    %esp,%ebp
  8001fb:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001fe:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800201:	50                   	push   %eax
  800202:	ff 75 08             	pushl  0x8(%ebp)
  800205:	e8 9d ff ff ff       	call   8001a7 <vcprintf>
	va_end(ap);

	return cnt;
}
  80020a:	c9                   	leave  
  80020b:	c3                   	ret    

0080020c <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80020c:	55                   	push   %ebp
  80020d:	89 e5                	mov    %esp,%ebp
  80020f:	57                   	push   %edi
  800210:	56                   	push   %esi
  800211:	53                   	push   %ebx
  800212:	83 ec 2c             	sub    $0x2c,%esp
  800215:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800218:	89 d6                	mov    %edx,%esi
  80021a:	8b 45 08             	mov    0x8(%ebp),%eax
  80021d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800220:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800223:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800226:	8b 45 10             	mov    0x10(%ebp),%eax
  800229:	8b 5d 14             	mov    0x14(%ebp),%ebx
  80022c:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80022f:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800232:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  800239:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
  80023c:	72 0c                	jb     80024a <printnum+0x3e>
  80023e:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  800241:	76 07                	jbe    80024a <printnum+0x3e>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800243:	4b                   	dec    %ebx
  800244:	85 db                	test   %ebx,%ebx
  800246:	7f 31                	jg     800279 <printnum+0x6d>
  800248:	eb 3f                	jmp    800289 <printnum+0x7d>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80024a:	83 ec 0c             	sub    $0xc,%esp
  80024d:	57                   	push   %edi
  80024e:	4b                   	dec    %ebx
  80024f:	53                   	push   %ebx
  800250:	50                   	push   %eax
  800251:	83 ec 08             	sub    $0x8,%esp
  800254:	ff 75 d4             	pushl  -0x2c(%ebp)
  800257:	ff 75 d0             	pushl  -0x30(%ebp)
  80025a:	ff 75 dc             	pushl  -0x24(%ebp)
  80025d:	ff 75 d8             	pushl  -0x28(%ebp)
  800260:	e8 1b 1a 00 00       	call   801c80 <__udivdi3>
  800265:	83 c4 18             	add    $0x18,%esp
  800268:	52                   	push   %edx
  800269:	50                   	push   %eax
  80026a:	89 f2                	mov    %esi,%edx
  80026c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80026f:	e8 98 ff ff ff       	call   80020c <printnum>
  800274:	83 c4 20             	add    $0x20,%esp
  800277:	eb 10                	jmp    800289 <printnum+0x7d>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800279:	83 ec 08             	sub    $0x8,%esp
  80027c:	56                   	push   %esi
  80027d:	57                   	push   %edi
  80027e:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800281:	4b                   	dec    %ebx
  800282:	83 c4 10             	add    $0x10,%esp
  800285:	85 db                	test   %ebx,%ebx
  800287:	7f f0                	jg     800279 <printnum+0x6d>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800289:	83 ec 08             	sub    $0x8,%esp
  80028c:	56                   	push   %esi
  80028d:	83 ec 04             	sub    $0x4,%esp
  800290:	ff 75 d4             	pushl  -0x2c(%ebp)
  800293:	ff 75 d0             	pushl  -0x30(%ebp)
  800296:	ff 75 dc             	pushl  -0x24(%ebp)
  800299:	ff 75 d8             	pushl  -0x28(%ebp)
  80029c:	e8 fb 1a 00 00       	call   801d9c <__umoddi3>
  8002a1:	83 c4 14             	add    $0x14,%esp
  8002a4:	0f be 80 7b 1f 80 00 	movsbl 0x801f7b(%eax),%eax
  8002ab:	50                   	push   %eax
  8002ac:	ff 55 e4             	call   *-0x1c(%ebp)
  8002af:	83 c4 10             	add    $0x10,%esp
}
  8002b2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002b5:	5b                   	pop    %ebx
  8002b6:	5e                   	pop    %esi
  8002b7:	5f                   	pop    %edi
  8002b8:	c9                   	leave  
  8002b9:	c3                   	ret    

008002ba <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002ba:	55                   	push   %ebp
  8002bb:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002bd:	83 fa 01             	cmp    $0x1,%edx
  8002c0:	7e 0e                	jle    8002d0 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8002c2:	8b 10                	mov    (%eax),%edx
  8002c4:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002c7:	89 08                	mov    %ecx,(%eax)
  8002c9:	8b 02                	mov    (%edx),%eax
  8002cb:	8b 52 04             	mov    0x4(%edx),%edx
  8002ce:	eb 22                	jmp    8002f2 <getuint+0x38>
	else if (lflag)
  8002d0:	85 d2                	test   %edx,%edx
  8002d2:	74 10                	je     8002e4 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8002d4:	8b 10                	mov    (%eax),%edx
  8002d6:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002d9:	89 08                	mov    %ecx,(%eax)
  8002db:	8b 02                	mov    (%edx),%eax
  8002dd:	ba 00 00 00 00       	mov    $0x0,%edx
  8002e2:	eb 0e                	jmp    8002f2 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8002e4:	8b 10                	mov    (%eax),%edx
  8002e6:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002e9:	89 08                	mov    %ecx,(%eax)
  8002eb:	8b 02                	mov    (%edx),%eax
  8002ed:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002f2:	c9                   	leave  
  8002f3:	c3                   	ret    

008002f4 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  8002f4:	55                   	push   %ebp
  8002f5:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002f7:	83 fa 01             	cmp    $0x1,%edx
  8002fa:	7e 0e                	jle    80030a <getint+0x16>
		return va_arg(*ap, long long);
  8002fc:	8b 10                	mov    (%eax),%edx
  8002fe:	8d 4a 08             	lea    0x8(%edx),%ecx
  800301:	89 08                	mov    %ecx,(%eax)
  800303:	8b 02                	mov    (%edx),%eax
  800305:	8b 52 04             	mov    0x4(%edx),%edx
  800308:	eb 1a                	jmp    800324 <getint+0x30>
	else if (lflag)
  80030a:	85 d2                	test   %edx,%edx
  80030c:	74 0c                	je     80031a <getint+0x26>
		return va_arg(*ap, long);
  80030e:	8b 10                	mov    (%eax),%edx
  800310:	8d 4a 04             	lea    0x4(%edx),%ecx
  800313:	89 08                	mov    %ecx,(%eax)
  800315:	8b 02                	mov    (%edx),%eax
  800317:	99                   	cltd   
  800318:	eb 0a                	jmp    800324 <getint+0x30>
	else
		return va_arg(*ap, int);
  80031a:	8b 10                	mov    (%eax),%edx
  80031c:	8d 4a 04             	lea    0x4(%edx),%ecx
  80031f:	89 08                	mov    %ecx,(%eax)
  800321:	8b 02                	mov    (%edx),%eax
  800323:	99                   	cltd   
}
  800324:	c9                   	leave  
  800325:	c3                   	ret    

00800326 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800326:	55                   	push   %ebp
  800327:	89 e5                	mov    %esp,%ebp
  800329:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80032c:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  80032f:	8b 10                	mov    (%eax),%edx
  800331:	3b 50 04             	cmp    0x4(%eax),%edx
  800334:	73 08                	jae    80033e <sprintputch+0x18>
		*b->buf++ = ch;
  800336:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800339:	88 0a                	mov    %cl,(%edx)
  80033b:	42                   	inc    %edx
  80033c:	89 10                	mov    %edx,(%eax)
}
  80033e:	c9                   	leave  
  80033f:	c3                   	ret    

00800340 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800340:	55                   	push   %ebp
  800341:	89 e5                	mov    %esp,%ebp
  800343:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800346:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800349:	50                   	push   %eax
  80034a:	ff 75 10             	pushl  0x10(%ebp)
  80034d:	ff 75 0c             	pushl  0xc(%ebp)
  800350:	ff 75 08             	pushl  0x8(%ebp)
  800353:	e8 05 00 00 00       	call   80035d <vprintfmt>
	va_end(ap);
  800358:	83 c4 10             	add    $0x10,%esp
}
  80035b:	c9                   	leave  
  80035c:	c3                   	ret    

0080035d <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80035d:	55                   	push   %ebp
  80035e:	89 e5                	mov    %esp,%ebp
  800360:	57                   	push   %edi
  800361:	56                   	push   %esi
  800362:	53                   	push   %ebx
  800363:	83 ec 2c             	sub    $0x2c,%esp
  800366:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800369:	8b 75 10             	mov    0x10(%ebp),%esi
  80036c:	eb 13                	jmp    800381 <vprintfmt+0x24>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80036e:	85 c0                	test   %eax,%eax
  800370:	0f 84 6d 03 00 00    	je     8006e3 <vprintfmt+0x386>
				return;
			putch(ch, putdat);
  800376:	83 ec 08             	sub    $0x8,%esp
  800379:	57                   	push   %edi
  80037a:	50                   	push   %eax
  80037b:	ff 55 08             	call   *0x8(%ebp)
  80037e:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800381:	0f b6 06             	movzbl (%esi),%eax
  800384:	46                   	inc    %esi
  800385:	83 f8 25             	cmp    $0x25,%eax
  800388:	75 e4                	jne    80036e <vprintfmt+0x11>
  80038a:	c6 45 dc 20          	movb   $0x20,-0x24(%ebp)
  80038e:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  800395:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  80039c:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  8003a3:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003a8:	eb 28                	jmp    8003d2 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003aa:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  8003ac:	c6 45 dc 2d          	movb   $0x2d,-0x24(%ebp)
  8003b0:	eb 20                	jmp    8003d2 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003b2:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8003b4:	c6 45 dc 30          	movb   $0x30,-0x24(%ebp)
  8003b8:	eb 18                	jmp    8003d2 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ba:	89 de                	mov    %ebx,%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  8003bc:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8003c3:	eb 0d                	jmp    8003d2 <vprintfmt+0x75>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  8003c5:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8003c8:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003cb:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003d2:	8a 06                	mov    (%esi),%al
  8003d4:	0f b6 d0             	movzbl %al,%edx
  8003d7:	8d 5e 01             	lea    0x1(%esi),%ebx
  8003da:	83 e8 23             	sub    $0x23,%eax
  8003dd:	3c 55                	cmp    $0x55,%al
  8003df:	0f 87 e0 02 00 00    	ja     8006c5 <vprintfmt+0x368>
  8003e5:	0f b6 c0             	movzbl %al,%eax
  8003e8:	ff 24 85 c0 20 80 00 	jmp    *0x8020c0(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003ef:	83 ea 30             	sub    $0x30,%edx
  8003f2:	89 55 d4             	mov    %edx,-0x2c(%ebp)
				ch = *fmt;
  8003f5:	0f be 03             	movsbl (%ebx),%eax
				if (ch < '0' || ch > '9')
  8003f8:	8d 50 d0             	lea    -0x30(%eax),%edx
  8003fb:	83 fa 09             	cmp    $0x9,%edx
  8003fe:	77 44                	ja     800444 <vprintfmt+0xe7>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800400:	89 de                	mov    %ebx,%esi
  800402:	8b 55 d4             	mov    -0x2c(%ebp),%edx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800405:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
  800406:	8d 14 92             	lea    (%edx,%edx,4),%edx
  800409:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
  80040d:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800410:	8d 58 d0             	lea    -0x30(%eax),%ebx
  800413:	83 fb 09             	cmp    $0x9,%ebx
  800416:	76 ed                	jbe    800405 <vprintfmt+0xa8>
  800418:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  80041b:	eb 29                	jmp    800446 <vprintfmt+0xe9>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80041d:	8b 45 14             	mov    0x14(%ebp),%eax
  800420:	8d 50 04             	lea    0x4(%eax),%edx
  800423:	89 55 14             	mov    %edx,0x14(%ebp)
  800426:	8b 00                	mov    (%eax),%eax
  800428:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80042b:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80042d:	eb 17                	jmp    800446 <vprintfmt+0xe9>

		case '.':
			if (width < 0)
  80042f:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800433:	78 85                	js     8003ba <vprintfmt+0x5d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800435:	89 de                	mov    %ebx,%esi
  800437:	eb 99                	jmp    8003d2 <vprintfmt+0x75>
  800439:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80043b:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  800442:	eb 8e                	jmp    8003d2 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800444:	89 de                	mov    %ebx,%esi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  800446:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80044a:	79 86                	jns    8003d2 <vprintfmt+0x75>
  80044c:	e9 74 ff ff ff       	jmp    8003c5 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800451:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800452:	89 de                	mov    %ebx,%esi
  800454:	e9 79 ff ff ff       	jmp    8003d2 <vprintfmt+0x75>
  800459:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80045c:	8b 45 14             	mov    0x14(%ebp),%eax
  80045f:	8d 50 04             	lea    0x4(%eax),%edx
  800462:	89 55 14             	mov    %edx,0x14(%ebp)
  800465:	83 ec 08             	sub    $0x8,%esp
  800468:	57                   	push   %edi
  800469:	ff 30                	pushl  (%eax)
  80046b:	ff 55 08             	call   *0x8(%ebp)
			break;
  80046e:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800471:	8b 75 d8             	mov    -0x28(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800474:	e9 08 ff ff ff       	jmp    800381 <vprintfmt+0x24>
  800479:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  80047c:	8b 45 14             	mov    0x14(%ebp),%eax
  80047f:	8d 50 04             	lea    0x4(%eax),%edx
  800482:	89 55 14             	mov    %edx,0x14(%ebp)
  800485:	8b 00                	mov    (%eax),%eax
  800487:	85 c0                	test   %eax,%eax
  800489:	79 02                	jns    80048d <vprintfmt+0x130>
  80048b:	f7 d8                	neg    %eax
  80048d:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80048f:	83 f8 0f             	cmp    $0xf,%eax
  800492:	7f 0b                	jg     80049f <vprintfmt+0x142>
  800494:	8b 04 85 20 22 80 00 	mov    0x802220(,%eax,4),%eax
  80049b:	85 c0                	test   %eax,%eax
  80049d:	75 1a                	jne    8004b9 <vprintfmt+0x15c>
				printfmt(putch, putdat, "error %d", err);
  80049f:	52                   	push   %edx
  8004a0:	68 93 1f 80 00       	push   $0x801f93
  8004a5:	57                   	push   %edi
  8004a6:	ff 75 08             	pushl  0x8(%ebp)
  8004a9:	e8 92 fe ff ff       	call   800340 <printfmt>
  8004ae:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004b1:	8b 75 d8             	mov    -0x28(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8004b4:	e9 c8 fe ff ff       	jmp    800381 <vprintfmt+0x24>
			else
				printfmt(putch, putdat, "%s", p);
  8004b9:	50                   	push   %eax
  8004ba:	68 a5 23 80 00       	push   $0x8023a5
  8004bf:	57                   	push   %edi
  8004c0:	ff 75 08             	pushl  0x8(%ebp)
  8004c3:	e8 78 fe ff ff       	call   800340 <printfmt>
  8004c8:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004cb:	8b 75 d8             	mov    -0x28(%ebp),%esi
  8004ce:	e9 ae fe ff ff       	jmp    800381 <vprintfmt+0x24>
  8004d3:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  8004d6:	89 de                	mov    %ebx,%esi
  8004d8:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  8004db:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004de:	8b 45 14             	mov    0x14(%ebp),%eax
  8004e1:	8d 50 04             	lea    0x4(%eax),%edx
  8004e4:	89 55 14             	mov    %edx,0x14(%ebp)
  8004e7:	8b 00                	mov    (%eax),%eax
  8004e9:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8004ec:	85 c0                	test   %eax,%eax
  8004ee:	75 07                	jne    8004f7 <vprintfmt+0x19a>
				p = "(null)";
  8004f0:	c7 45 d0 8c 1f 80 00 	movl   $0x801f8c,-0x30(%ebp)
			if (width > 0 && padc != '-')
  8004f7:	85 db                	test   %ebx,%ebx
  8004f9:	7e 42                	jle    80053d <vprintfmt+0x1e0>
  8004fb:	80 7d dc 2d          	cmpb   $0x2d,-0x24(%ebp)
  8004ff:	74 3c                	je     80053d <vprintfmt+0x1e0>
				for (width -= strnlen(p, precision); width > 0; width--)
  800501:	83 ec 08             	sub    $0x8,%esp
  800504:	51                   	push   %ecx
  800505:	ff 75 d0             	pushl  -0x30(%ebp)
  800508:	e8 6f 02 00 00       	call   80077c <strnlen>
  80050d:	29 c3                	sub    %eax,%ebx
  80050f:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800512:	83 c4 10             	add    $0x10,%esp
  800515:	85 db                	test   %ebx,%ebx
  800517:	7e 24                	jle    80053d <vprintfmt+0x1e0>
					putch(padc, putdat);
  800519:	0f be 5d dc          	movsbl -0x24(%ebp),%ebx
  80051d:	89 75 dc             	mov    %esi,-0x24(%ebp)
  800520:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  800523:	83 ec 08             	sub    $0x8,%esp
  800526:	57                   	push   %edi
  800527:	53                   	push   %ebx
  800528:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80052b:	4e                   	dec    %esi
  80052c:	83 c4 10             	add    $0x10,%esp
  80052f:	85 f6                	test   %esi,%esi
  800531:	7f f0                	jg     800523 <vprintfmt+0x1c6>
  800533:	8b 75 dc             	mov    -0x24(%ebp),%esi
  800536:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80053d:	8b 55 d0             	mov    -0x30(%ebp),%edx
  800540:	0f be 02             	movsbl (%edx),%eax
  800543:	85 c0                	test   %eax,%eax
  800545:	75 47                	jne    80058e <vprintfmt+0x231>
  800547:	eb 37                	jmp    800580 <vprintfmt+0x223>
				if (altflag && (ch < ' ' || ch > '~'))
  800549:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80054d:	74 16                	je     800565 <vprintfmt+0x208>
  80054f:	8d 50 e0             	lea    -0x20(%eax),%edx
  800552:	83 fa 5e             	cmp    $0x5e,%edx
  800555:	76 0e                	jbe    800565 <vprintfmt+0x208>
					putch('?', putdat);
  800557:	83 ec 08             	sub    $0x8,%esp
  80055a:	57                   	push   %edi
  80055b:	6a 3f                	push   $0x3f
  80055d:	ff 55 08             	call   *0x8(%ebp)
  800560:	83 c4 10             	add    $0x10,%esp
  800563:	eb 0b                	jmp    800570 <vprintfmt+0x213>
				else
					putch(ch, putdat);
  800565:	83 ec 08             	sub    $0x8,%esp
  800568:	57                   	push   %edi
  800569:	50                   	push   %eax
  80056a:	ff 55 08             	call   *0x8(%ebp)
  80056d:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800570:	ff 4d e4             	decl   -0x1c(%ebp)
  800573:	0f be 03             	movsbl (%ebx),%eax
  800576:	85 c0                	test   %eax,%eax
  800578:	74 03                	je     80057d <vprintfmt+0x220>
  80057a:	43                   	inc    %ebx
  80057b:	eb 1b                	jmp    800598 <vprintfmt+0x23b>
  80057d:	8b 75 dc             	mov    -0x24(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800580:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800584:	7f 1e                	jg     8005a4 <vprintfmt+0x247>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800586:	8b 75 d8             	mov    -0x28(%ebp),%esi
  800589:	e9 f3 fd ff ff       	jmp    800381 <vprintfmt+0x24>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80058e:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800591:	43                   	inc    %ebx
  800592:	89 75 dc             	mov    %esi,-0x24(%ebp)
  800595:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  800598:	85 f6                	test   %esi,%esi
  80059a:	78 ad                	js     800549 <vprintfmt+0x1ec>
  80059c:	4e                   	dec    %esi
  80059d:	79 aa                	jns    800549 <vprintfmt+0x1ec>
  80059f:	8b 75 dc             	mov    -0x24(%ebp),%esi
  8005a2:	eb dc                	jmp    800580 <vprintfmt+0x223>
  8005a4:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8005a7:	83 ec 08             	sub    $0x8,%esp
  8005aa:	57                   	push   %edi
  8005ab:	6a 20                	push   $0x20
  8005ad:	ff 55 08             	call   *0x8(%ebp)
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005b0:	4b                   	dec    %ebx
  8005b1:	83 c4 10             	add    $0x10,%esp
  8005b4:	85 db                	test   %ebx,%ebx
  8005b6:	7f ef                	jg     8005a7 <vprintfmt+0x24a>
  8005b8:	e9 c4 fd ff ff       	jmp    800381 <vprintfmt+0x24>
  8005bd:	89 5d d8             	mov    %ebx,-0x28(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8005c0:	89 ca                	mov    %ecx,%edx
  8005c2:	8d 45 14             	lea    0x14(%ebp),%eax
  8005c5:	e8 2a fd ff ff       	call   8002f4 <getint>
  8005ca:	89 c3                	mov    %eax,%ebx
  8005cc:	89 d6                	mov    %edx,%esi
			if ((long long) num < 0) {
  8005ce:	85 d2                	test   %edx,%edx
  8005d0:	78 0a                	js     8005dc <vprintfmt+0x27f>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8005d2:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005d7:	e9 b0 00 00 00       	jmp    80068c <vprintfmt+0x32f>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  8005dc:	83 ec 08             	sub    $0x8,%esp
  8005df:	57                   	push   %edi
  8005e0:	6a 2d                	push   $0x2d
  8005e2:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8005e5:	f7 db                	neg    %ebx
  8005e7:	83 d6 00             	adc    $0x0,%esi
  8005ea:	f7 de                	neg    %esi
  8005ec:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8005ef:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005f4:	e9 93 00 00 00       	jmp    80068c <vprintfmt+0x32f>
  8005f9:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8005fc:	89 ca                	mov    %ecx,%edx
  8005fe:	8d 45 14             	lea    0x14(%ebp),%eax
  800601:	e8 b4 fc ff ff       	call   8002ba <getuint>
  800606:	89 c3                	mov    %eax,%ebx
  800608:	89 d6                	mov    %edx,%esi
			base = 10;
  80060a:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  80060f:	eb 7b                	jmp    80068c <vprintfmt+0x32f>
  800611:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
  800614:	89 ca                	mov    %ecx,%edx
  800616:	8d 45 14             	lea    0x14(%ebp),%eax
  800619:	e8 d6 fc ff ff       	call   8002f4 <getint>
  80061e:	89 c3                	mov    %eax,%ebx
  800620:	89 d6                	mov    %edx,%esi
            if ((long long) num < 0) {
  800622:	85 d2                	test   %edx,%edx
  800624:	78 07                	js     80062d <vprintfmt+0x2d0>
                putch('-', putdat);
                num = -(long long) num;
            }
            base = 8;
  800626:	b8 08 00 00 00       	mov    $0x8,%eax
  80062b:	eb 5f                	jmp    80068c <vprintfmt+0x32f>
		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
            if ((long long) num < 0) {
                putch('-', putdat);
  80062d:	83 ec 08             	sub    $0x8,%esp
  800630:	57                   	push   %edi
  800631:	6a 2d                	push   $0x2d
  800633:	ff 55 08             	call   *0x8(%ebp)
                num = -(long long) num;
  800636:	f7 db                	neg    %ebx
  800638:	83 d6 00             	adc    $0x0,%esi
  80063b:	f7 de                	neg    %esi
  80063d:	83 c4 10             	add    $0x10,%esp
            }
            base = 8;
  800640:	b8 08 00 00 00       	mov    $0x8,%eax
  800645:	eb 45                	jmp    80068c <vprintfmt+0x32f>
  800647:	89 5d d8             	mov    %ebx,-0x28(%ebp)
            goto number;

        // pointer
		case 'p':
			putch('0', putdat);
  80064a:	83 ec 08             	sub    $0x8,%esp
  80064d:	57                   	push   %edi
  80064e:	6a 30                	push   $0x30
  800650:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800653:	83 c4 08             	add    $0x8,%esp
  800656:	57                   	push   %edi
  800657:	6a 78                	push   $0x78
  800659:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80065c:	8b 45 14             	mov    0x14(%ebp),%eax
  80065f:	8d 50 04             	lea    0x4(%eax),%edx
  800662:	89 55 14             	mov    %edx,0x14(%ebp)

        // pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800665:	8b 18                	mov    (%eax),%ebx
  800667:	be 00 00 00 00       	mov    $0x0,%esi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80066c:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80066f:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800674:	eb 16                	jmp    80068c <vprintfmt+0x32f>
  800676:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800679:	89 ca                	mov    %ecx,%edx
  80067b:	8d 45 14             	lea    0x14(%ebp),%eax
  80067e:	e8 37 fc ff ff       	call   8002ba <getuint>
  800683:	89 c3                	mov    %eax,%ebx
  800685:	89 d6                	mov    %edx,%esi
			base = 16;
  800687:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  80068c:	83 ec 0c             	sub    $0xc,%esp
  80068f:	0f be 55 dc          	movsbl -0x24(%ebp),%edx
  800693:	52                   	push   %edx
  800694:	ff 75 e4             	pushl  -0x1c(%ebp)
  800697:	50                   	push   %eax
  800698:	56                   	push   %esi
  800699:	53                   	push   %ebx
  80069a:	89 fa                	mov    %edi,%edx
  80069c:	8b 45 08             	mov    0x8(%ebp),%eax
  80069f:	e8 68 fb ff ff       	call   80020c <printnum>
			break;
  8006a4:	83 c4 20             	add    $0x20,%esp
  8006a7:	8b 75 d8             	mov    -0x28(%ebp),%esi
  8006aa:	e9 d2 fc ff ff       	jmp    800381 <vprintfmt+0x24>
  8006af:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006b2:	83 ec 08             	sub    $0x8,%esp
  8006b5:	57                   	push   %edi
  8006b6:	52                   	push   %edx
  8006b7:	ff 55 08             	call   *0x8(%ebp)
			break;
  8006ba:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006bd:	8b 75 d8             	mov    -0x28(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8006c0:	e9 bc fc ff ff       	jmp    800381 <vprintfmt+0x24>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8006c5:	83 ec 08             	sub    $0x8,%esp
  8006c8:	57                   	push   %edi
  8006c9:	6a 25                	push   $0x25
  8006cb:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006ce:	83 c4 10             	add    $0x10,%esp
  8006d1:	eb 02                	jmp    8006d5 <vprintfmt+0x378>
  8006d3:	89 c6                	mov    %eax,%esi
  8006d5:	8d 46 ff             	lea    -0x1(%esi),%eax
  8006d8:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  8006dc:	75 f5                	jne    8006d3 <vprintfmt+0x376>
  8006de:	e9 9e fc ff ff       	jmp    800381 <vprintfmt+0x24>
				/* do nothing */;
			break;
		}
	}
}
  8006e3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006e6:	5b                   	pop    %ebx
  8006e7:	5e                   	pop    %esi
  8006e8:	5f                   	pop    %edi
  8006e9:	c9                   	leave  
  8006ea:	c3                   	ret    

008006eb <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006eb:	55                   	push   %ebp
  8006ec:	89 e5                	mov    %esp,%ebp
  8006ee:	83 ec 18             	sub    $0x18,%esp
  8006f1:	8b 45 08             	mov    0x8(%ebp),%eax
  8006f4:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006f7:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006fa:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8006fe:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800701:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800708:	85 c0                	test   %eax,%eax
  80070a:	74 26                	je     800732 <vsnprintf+0x47>
  80070c:	85 d2                	test   %edx,%edx
  80070e:	7e 29                	jle    800739 <vsnprintf+0x4e>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800710:	ff 75 14             	pushl  0x14(%ebp)
  800713:	ff 75 10             	pushl  0x10(%ebp)
  800716:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800719:	50                   	push   %eax
  80071a:	68 26 03 80 00       	push   $0x800326
  80071f:	e8 39 fc ff ff       	call   80035d <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800724:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800727:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80072a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80072d:	83 c4 10             	add    $0x10,%esp
  800730:	eb 0c                	jmp    80073e <vsnprintf+0x53>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800732:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800737:	eb 05                	jmp    80073e <vsnprintf+0x53>
  800739:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80073e:	c9                   	leave  
  80073f:	c3                   	ret    

00800740 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800740:	55                   	push   %ebp
  800741:	89 e5                	mov    %esp,%ebp
  800743:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800746:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800749:	50                   	push   %eax
  80074a:	ff 75 10             	pushl  0x10(%ebp)
  80074d:	ff 75 0c             	pushl  0xc(%ebp)
  800750:	ff 75 08             	pushl  0x8(%ebp)
  800753:	e8 93 ff ff ff       	call   8006eb <vsnprintf>
	va_end(ap);

	return rc;
}
  800758:	c9                   	leave  
  800759:	c3                   	ret    
	...

0080075c <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80075c:	55                   	push   %ebp
  80075d:	89 e5                	mov    %esp,%ebp
  80075f:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800762:	80 3a 00             	cmpb   $0x0,(%edx)
  800765:	74 0e                	je     800775 <strlen+0x19>
  800767:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  80076c:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80076d:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800771:	75 f9                	jne    80076c <strlen+0x10>
  800773:	eb 05                	jmp    80077a <strlen+0x1e>
  800775:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  80077a:	c9                   	leave  
  80077b:	c3                   	ret    

0080077c <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80077c:	55                   	push   %ebp
  80077d:	89 e5                	mov    %esp,%ebp
  80077f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800782:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800785:	85 d2                	test   %edx,%edx
  800787:	74 17                	je     8007a0 <strnlen+0x24>
  800789:	80 39 00             	cmpb   $0x0,(%ecx)
  80078c:	74 19                	je     8007a7 <strnlen+0x2b>
  80078e:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800793:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800794:	39 d0                	cmp    %edx,%eax
  800796:	74 14                	je     8007ac <strnlen+0x30>
  800798:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  80079c:	75 f5                	jne    800793 <strnlen+0x17>
  80079e:	eb 0c                	jmp    8007ac <strnlen+0x30>
  8007a0:	b8 00 00 00 00       	mov    $0x0,%eax
  8007a5:	eb 05                	jmp    8007ac <strnlen+0x30>
  8007a7:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  8007ac:	c9                   	leave  
  8007ad:	c3                   	ret    

008007ae <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007ae:	55                   	push   %ebp
  8007af:	89 e5                	mov    %esp,%ebp
  8007b1:	53                   	push   %ebx
  8007b2:	8b 45 08             	mov    0x8(%ebp),%eax
  8007b5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007b8:	ba 00 00 00 00       	mov    $0x0,%edx
  8007bd:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  8007c0:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  8007c3:	42                   	inc    %edx
  8007c4:	84 c9                	test   %cl,%cl
  8007c6:	75 f5                	jne    8007bd <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8007c8:	5b                   	pop    %ebx
  8007c9:	c9                   	leave  
  8007ca:	c3                   	ret    

008007cb <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007cb:	55                   	push   %ebp
  8007cc:	89 e5                	mov    %esp,%ebp
  8007ce:	53                   	push   %ebx
  8007cf:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007d2:	53                   	push   %ebx
  8007d3:	e8 84 ff ff ff       	call   80075c <strlen>
  8007d8:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8007db:	ff 75 0c             	pushl  0xc(%ebp)
  8007de:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  8007e1:	50                   	push   %eax
  8007e2:	e8 c7 ff ff ff       	call   8007ae <strcpy>
	return dst;
}
  8007e7:	89 d8                	mov    %ebx,%eax
  8007e9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007ec:	c9                   	leave  
  8007ed:	c3                   	ret    

008007ee <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007ee:	55                   	push   %ebp
  8007ef:	89 e5                	mov    %esp,%ebp
  8007f1:	56                   	push   %esi
  8007f2:	53                   	push   %ebx
  8007f3:	8b 45 08             	mov    0x8(%ebp),%eax
  8007f6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007f9:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007fc:	85 f6                	test   %esi,%esi
  8007fe:	74 15                	je     800815 <strncpy+0x27>
  800800:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  800805:	8a 1a                	mov    (%edx),%bl
  800807:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80080a:	80 3a 01             	cmpb   $0x1,(%edx)
  80080d:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800810:	41                   	inc    %ecx
  800811:	39 ce                	cmp    %ecx,%esi
  800813:	77 f0                	ja     800805 <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800815:	5b                   	pop    %ebx
  800816:	5e                   	pop    %esi
  800817:	c9                   	leave  
  800818:	c3                   	ret    

00800819 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800819:	55                   	push   %ebp
  80081a:	89 e5                	mov    %esp,%ebp
  80081c:	57                   	push   %edi
  80081d:	56                   	push   %esi
  80081e:	53                   	push   %ebx
  80081f:	8b 7d 08             	mov    0x8(%ebp),%edi
  800822:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800825:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800828:	85 f6                	test   %esi,%esi
  80082a:	74 32                	je     80085e <strlcpy+0x45>
		while (--size > 0 && *src != '\0')
  80082c:	83 fe 01             	cmp    $0x1,%esi
  80082f:	74 22                	je     800853 <strlcpy+0x3a>
  800831:	8a 0b                	mov    (%ebx),%cl
  800833:	84 c9                	test   %cl,%cl
  800835:	74 20                	je     800857 <strlcpy+0x3e>
  800837:	89 f8                	mov    %edi,%eax
  800839:	ba 00 00 00 00       	mov    $0x0,%edx
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
  80083e:	83 ee 02             	sub    $0x2,%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800841:	88 08                	mov    %cl,(%eax)
  800843:	40                   	inc    %eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800844:	39 f2                	cmp    %esi,%edx
  800846:	74 11                	je     800859 <strlcpy+0x40>
  800848:	8a 4c 13 01          	mov    0x1(%ebx,%edx,1),%cl
  80084c:	42                   	inc    %edx
  80084d:	84 c9                	test   %cl,%cl
  80084f:	75 f0                	jne    800841 <strlcpy+0x28>
  800851:	eb 06                	jmp    800859 <strlcpy+0x40>
  800853:	89 f8                	mov    %edi,%eax
  800855:	eb 02                	jmp    800859 <strlcpy+0x40>
  800857:	89 f8                	mov    %edi,%eax
			*dst++ = *src++;
		*dst = '\0';
  800859:	c6 00 00             	movb   $0x0,(%eax)
  80085c:	eb 02                	jmp    800860 <strlcpy+0x47>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80085e:	89 f8                	mov    %edi,%eax
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
		*dst = '\0';
	}
	return dst - dst_in;
  800860:	29 f8                	sub    %edi,%eax
}
  800862:	5b                   	pop    %ebx
  800863:	5e                   	pop    %esi
  800864:	5f                   	pop    %edi
  800865:	c9                   	leave  
  800866:	c3                   	ret    

00800867 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800867:	55                   	push   %ebp
  800868:	89 e5                	mov    %esp,%ebp
  80086a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80086d:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800870:	8a 01                	mov    (%ecx),%al
  800872:	84 c0                	test   %al,%al
  800874:	74 10                	je     800886 <strcmp+0x1f>
  800876:	3a 02                	cmp    (%edx),%al
  800878:	75 0c                	jne    800886 <strcmp+0x1f>
		p++, q++;
  80087a:	41                   	inc    %ecx
  80087b:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80087c:	8a 01                	mov    (%ecx),%al
  80087e:	84 c0                	test   %al,%al
  800880:	74 04                	je     800886 <strcmp+0x1f>
  800882:	3a 02                	cmp    (%edx),%al
  800884:	74 f4                	je     80087a <strcmp+0x13>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800886:	0f b6 c0             	movzbl %al,%eax
  800889:	0f b6 12             	movzbl (%edx),%edx
  80088c:	29 d0                	sub    %edx,%eax
}
  80088e:	c9                   	leave  
  80088f:	c3                   	ret    

00800890 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800890:	55                   	push   %ebp
  800891:	89 e5                	mov    %esp,%ebp
  800893:	53                   	push   %ebx
  800894:	8b 55 08             	mov    0x8(%ebp),%edx
  800897:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80089a:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  80089d:	85 c0                	test   %eax,%eax
  80089f:	74 1b                	je     8008bc <strncmp+0x2c>
  8008a1:	8a 1a                	mov    (%edx),%bl
  8008a3:	84 db                	test   %bl,%bl
  8008a5:	74 24                	je     8008cb <strncmp+0x3b>
  8008a7:	3a 19                	cmp    (%ecx),%bl
  8008a9:	75 20                	jne    8008cb <strncmp+0x3b>
  8008ab:	48                   	dec    %eax
  8008ac:	74 15                	je     8008c3 <strncmp+0x33>
		n--, p++, q++;
  8008ae:	42                   	inc    %edx
  8008af:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8008b0:	8a 1a                	mov    (%edx),%bl
  8008b2:	84 db                	test   %bl,%bl
  8008b4:	74 15                	je     8008cb <strncmp+0x3b>
  8008b6:	3a 19                	cmp    (%ecx),%bl
  8008b8:	74 f1                	je     8008ab <strncmp+0x1b>
  8008ba:	eb 0f                	jmp    8008cb <strncmp+0x3b>
		n--, p++, q++;
	if (n == 0)
		return 0;
  8008bc:	b8 00 00 00 00       	mov    $0x0,%eax
  8008c1:	eb 05                	jmp    8008c8 <strncmp+0x38>
  8008c3:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8008c8:	5b                   	pop    %ebx
  8008c9:	c9                   	leave  
  8008ca:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008cb:	0f b6 02             	movzbl (%edx),%eax
  8008ce:	0f b6 11             	movzbl (%ecx),%edx
  8008d1:	29 d0                	sub    %edx,%eax
  8008d3:	eb f3                	jmp    8008c8 <strncmp+0x38>

008008d5 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008d5:	55                   	push   %ebp
  8008d6:	89 e5                	mov    %esp,%ebp
  8008d8:	8b 45 08             	mov    0x8(%ebp),%eax
  8008db:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8008de:	8a 10                	mov    (%eax),%dl
  8008e0:	84 d2                	test   %dl,%dl
  8008e2:	74 18                	je     8008fc <strchr+0x27>
		if (*s == c)
  8008e4:	38 ca                	cmp    %cl,%dl
  8008e6:	75 06                	jne    8008ee <strchr+0x19>
  8008e8:	eb 17                	jmp    800901 <strchr+0x2c>
  8008ea:	38 ca                	cmp    %cl,%dl
  8008ec:	74 13                	je     800901 <strchr+0x2c>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8008ee:	40                   	inc    %eax
  8008ef:	8a 10                	mov    (%eax),%dl
  8008f1:	84 d2                	test   %dl,%dl
  8008f3:	75 f5                	jne    8008ea <strchr+0x15>
		if (*s == c)
			return (char *) s;
	return 0;
  8008f5:	b8 00 00 00 00       	mov    $0x0,%eax
  8008fa:	eb 05                	jmp    800901 <strchr+0x2c>
  8008fc:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800901:	c9                   	leave  
  800902:	c3                   	ret    

00800903 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800903:	55                   	push   %ebp
  800904:	89 e5                	mov    %esp,%ebp
  800906:	8b 45 08             	mov    0x8(%ebp),%eax
  800909:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  80090c:	8a 10                	mov    (%eax),%dl
  80090e:	84 d2                	test   %dl,%dl
  800910:	74 11                	je     800923 <strfind+0x20>
		if (*s == c)
  800912:	38 ca                	cmp    %cl,%dl
  800914:	75 06                	jne    80091c <strfind+0x19>
  800916:	eb 0b                	jmp    800923 <strfind+0x20>
  800918:	38 ca                	cmp    %cl,%dl
  80091a:	74 07                	je     800923 <strfind+0x20>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  80091c:	40                   	inc    %eax
  80091d:	8a 10                	mov    (%eax),%dl
  80091f:	84 d2                	test   %dl,%dl
  800921:	75 f5                	jne    800918 <strfind+0x15>
		if (*s == c)
			break;
	return (char *) s;
}
  800923:	c9                   	leave  
  800924:	c3                   	ret    

00800925 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800925:	55                   	push   %ebp
  800926:	89 e5                	mov    %esp,%ebp
  800928:	57                   	push   %edi
  800929:	56                   	push   %esi
  80092a:	53                   	push   %ebx
  80092b:	8b 7d 08             	mov    0x8(%ebp),%edi
  80092e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800931:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800934:	85 c9                	test   %ecx,%ecx
  800936:	74 30                	je     800968 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800938:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80093e:	75 25                	jne    800965 <memset+0x40>
  800940:	f6 c1 03             	test   $0x3,%cl
  800943:	75 20                	jne    800965 <memset+0x40>
		c &= 0xFF;
  800945:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800948:	89 d3                	mov    %edx,%ebx
  80094a:	c1 e3 08             	shl    $0x8,%ebx
  80094d:	89 d6                	mov    %edx,%esi
  80094f:	c1 e6 18             	shl    $0x18,%esi
  800952:	89 d0                	mov    %edx,%eax
  800954:	c1 e0 10             	shl    $0x10,%eax
  800957:	09 f0                	or     %esi,%eax
  800959:	09 d0                	or     %edx,%eax
  80095b:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  80095d:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800960:	fc                   	cld    
  800961:	f3 ab                	rep stos %eax,%es:(%edi)
  800963:	eb 03                	jmp    800968 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800965:	fc                   	cld    
  800966:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800968:	89 f8                	mov    %edi,%eax
  80096a:	5b                   	pop    %ebx
  80096b:	5e                   	pop    %esi
  80096c:	5f                   	pop    %edi
  80096d:	c9                   	leave  
  80096e:	c3                   	ret    

0080096f <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80096f:	55                   	push   %ebp
  800970:	89 e5                	mov    %esp,%ebp
  800972:	57                   	push   %edi
  800973:	56                   	push   %esi
  800974:	8b 45 08             	mov    0x8(%ebp),%eax
  800977:	8b 75 0c             	mov    0xc(%ebp),%esi
  80097a:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80097d:	39 c6                	cmp    %eax,%esi
  80097f:	73 34                	jae    8009b5 <memmove+0x46>
  800981:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800984:	39 d0                	cmp    %edx,%eax
  800986:	73 2d                	jae    8009b5 <memmove+0x46>
		s += n;
		d += n;
  800988:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80098b:	f6 c2 03             	test   $0x3,%dl
  80098e:	75 1b                	jne    8009ab <memmove+0x3c>
  800990:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800996:	75 13                	jne    8009ab <memmove+0x3c>
  800998:	f6 c1 03             	test   $0x3,%cl
  80099b:	75 0e                	jne    8009ab <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  80099d:	83 ef 04             	sub    $0x4,%edi
  8009a0:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009a3:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  8009a6:	fd                   	std    
  8009a7:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009a9:	eb 07                	jmp    8009b2 <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8009ab:	4f                   	dec    %edi
  8009ac:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8009af:	fd                   	std    
  8009b0:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009b2:	fc                   	cld    
  8009b3:	eb 20                	jmp    8009d5 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009b5:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009bb:	75 13                	jne    8009d0 <memmove+0x61>
  8009bd:	a8 03                	test   $0x3,%al
  8009bf:	75 0f                	jne    8009d0 <memmove+0x61>
  8009c1:	f6 c1 03             	test   $0x3,%cl
  8009c4:	75 0a                	jne    8009d0 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8009c6:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  8009c9:	89 c7                	mov    %eax,%edi
  8009cb:	fc                   	cld    
  8009cc:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009ce:	eb 05                	jmp    8009d5 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8009d0:	89 c7                	mov    %eax,%edi
  8009d2:	fc                   	cld    
  8009d3:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009d5:	5e                   	pop    %esi
  8009d6:	5f                   	pop    %edi
  8009d7:	c9                   	leave  
  8009d8:	c3                   	ret    

008009d9 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009d9:	55                   	push   %ebp
  8009da:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8009dc:	ff 75 10             	pushl  0x10(%ebp)
  8009df:	ff 75 0c             	pushl  0xc(%ebp)
  8009e2:	ff 75 08             	pushl  0x8(%ebp)
  8009e5:	e8 85 ff ff ff       	call   80096f <memmove>
}
  8009ea:	c9                   	leave  
  8009eb:	c3                   	ret    

008009ec <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009ec:	55                   	push   %ebp
  8009ed:	89 e5                	mov    %esp,%ebp
  8009ef:	57                   	push   %edi
  8009f0:	56                   	push   %esi
  8009f1:	53                   	push   %ebx
  8009f2:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8009f5:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009f8:	8b 7d 10             	mov    0x10(%ebp),%edi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009fb:	85 ff                	test   %edi,%edi
  8009fd:	74 32                	je     800a31 <memcmp+0x45>
		if (*s1 != *s2)
  8009ff:	8a 03                	mov    (%ebx),%al
  800a01:	8a 0e                	mov    (%esi),%cl
  800a03:	38 c8                	cmp    %cl,%al
  800a05:	74 19                	je     800a20 <memcmp+0x34>
  800a07:	eb 0d                	jmp    800a16 <memcmp+0x2a>
  800a09:	8a 44 13 01          	mov    0x1(%ebx,%edx,1),%al
  800a0d:	8a 4c 16 01          	mov    0x1(%esi,%edx,1),%cl
  800a11:	42                   	inc    %edx
  800a12:	38 c8                	cmp    %cl,%al
  800a14:	74 10                	je     800a26 <memcmp+0x3a>
			return (int) *s1 - (int) *s2;
  800a16:	0f b6 c0             	movzbl %al,%eax
  800a19:	0f b6 c9             	movzbl %cl,%ecx
  800a1c:	29 c8                	sub    %ecx,%eax
  800a1e:	eb 16                	jmp    800a36 <memcmp+0x4a>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a20:	4f                   	dec    %edi
  800a21:	ba 00 00 00 00       	mov    $0x0,%edx
  800a26:	39 fa                	cmp    %edi,%edx
  800a28:	75 df                	jne    800a09 <memcmp+0x1d>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a2a:	b8 00 00 00 00       	mov    $0x0,%eax
  800a2f:	eb 05                	jmp    800a36 <memcmp+0x4a>
  800a31:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a36:	5b                   	pop    %ebx
  800a37:	5e                   	pop    %esi
  800a38:	5f                   	pop    %edi
  800a39:	c9                   	leave  
  800a3a:	c3                   	ret    

00800a3b <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a3b:	55                   	push   %ebp
  800a3c:	89 e5                	mov    %esp,%ebp
  800a3e:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800a41:	89 c2                	mov    %eax,%edx
  800a43:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a46:	39 d0                	cmp    %edx,%eax
  800a48:	73 12                	jae    800a5c <memfind+0x21>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a4a:	8a 4d 0c             	mov    0xc(%ebp),%cl
  800a4d:	38 08                	cmp    %cl,(%eax)
  800a4f:	75 06                	jne    800a57 <memfind+0x1c>
  800a51:	eb 09                	jmp    800a5c <memfind+0x21>
  800a53:	38 08                	cmp    %cl,(%eax)
  800a55:	74 05                	je     800a5c <memfind+0x21>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a57:	40                   	inc    %eax
  800a58:	39 c2                	cmp    %eax,%edx
  800a5a:	77 f7                	ja     800a53 <memfind+0x18>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a5c:	c9                   	leave  
  800a5d:	c3                   	ret    

00800a5e <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a5e:	55                   	push   %ebp
  800a5f:	89 e5                	mov    %esp,%ebp
  800a61:	57                   	push   %edi
  800a62:	56                   	push   %esi
  800a63:	53                   	push   %ebx
  800a64:	8b 55 08             	mov    0x8(%ebp),%edx
  800a67:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a6a:	eb 01                	jmp    800a6d <strtol+0xf>
		s++;
  800a6c:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a6d:	8a 02                	mov    (%edx),%al
  800a6f:	3c 20                	cmp    $0x20,%al
  800a71:	74 f9                	je     800a6c <strtol+0xe>
  800a73:	3c 09                	cmp    $0x9,%al
  800a75:	74 f5                	je     800a6c <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a77:	3c 2b                	cmp    $0x2b,%al
  800a79:	75 08                	jne    800a83 <strtol+0x25>
		s++;
  800a7b:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a7c:	bf 00 00 00 00       	mov    $0x0,%edi
  800a81:	eb 13                	jmp    800a96 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a83:	3c 2d                	cmp    $0x2d,%al
  800a85:	75 0a                	jne    800a91 <strtol+0x33>
		s++, neg = 1;
  800a87:	8d 52 01             	lea    0x1(%edx),%edx
  800a8a:	bf 01 00 00 00       	mov    $0x1,%edi
  800a8f:	eb 05                	jmp    800a96 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a91:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a96:	85 db                	test   %ebx,%ebx
  800a98:	74 05                	je     800a9f <strtol+0x41>
  800a9a:	83 fb 10             	cmp    $0x10,%ebx
  800a9d:	75 28                	jne    800ac7 <strtol+0x69>
  800a9f:	8a 02                	mov    (%edx),%al
  800aa1:	3c 30                	cmp    $0x30,%al
  800aa3:	75 10                	jne    800ab5 <strtol+0x57>
  800aa5:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800aa9:	75 0a                	jne    800ab5 <strtol+0x57>
		s += 2, base = 16;
  800aab:	83 c2 02             	add    $0x2,%edx
  800aae:	bb 10 00 00 00       	mov    $0x10,%ebx
  800ab3:	eb 12                	jmp    800ac7 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800ab5:	85 db                	test   %ebx,%ebx
  800ab7:	75 0e                	jne    800ac7 <strtol+0x69>
  800ab9:	3c 30                	cmp    $0x30,%al
  800abb:	75 05                	jne    800ac2 <strtol+0x64>
		s++, base = 8;
  800abd:	42                   	inc    %edx
  800abe:	b3 08                	mov    $0x8,%bl
  800ac0:	eb 05                	jmp    800ac7 <strtol+0x69>
	else if (base == 0)
		base = 10;
  800ac2:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800ac7:	b8 00 00 00 00       	mov    $0x0,%eax
  800acc:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800ace:	8a 0a                	mov    (%edx),%cl
  800ad0:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800ad3:	80 fb 09             	cmp    $0x9,%bl
  800ad6:	77 08                	ja     800ae0 <strtol+0x82>
			dig = *s - '0';
  800ad8:	0f be c9             	movsbl %cl,%ecx
  800adb:	83 e9 30             	sub    $0x30,%ecx
  800ade:	eb 1e                	jmp    800afe <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800ae0:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800ae3:	80 fb 19             	cmp    $0x19,%bl
  800ae6:	77 08                	ja     800af0 <strtol+0x92>
			dig = *s - 'a' + 10;
  800ae8:	0f be c9             	movsbl %cl,%ecx
  800aeb:	83 e9 57             	sub    $0x57,%ecx
  800aee:	eb 0e                	jmp    800afe <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800af0:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800af3:	80 fb 19             	cmp    $0x19,%bl
  800af6:	77 13                	ja     800b0b <strtol+0xad>
			dig = *s - 'A' + 10;
  800af8:	0f be c9             	movsbl %cl,%ecx
  800afb:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800afe:	39 f1                	cmp    %esi,%ecx
  800b00:	7d 0d                	jge    800b0f <strtol+0xb1>
			break;
		s++, val = (val * base) + dig;
  800b02:	42                   	inc    %edx
  800b03:	0f af c6             	imul   %esi,%eax
  800b06:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  800b09:	eb c3                	jmp    800ace <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800b0b:	89 c1                	mov    %eax,%ecx
  800b0d:	eb 02                	jmp    800b11 <strtol+0xb3>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800b0f:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800b11:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b15:	74 05                	je     800b1c <strtol+0xbe>
		*endptr = (char *) s;
  800b17:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800b1a:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800b1c:	85 ff                	test   %edi,%edi
  800b1e:	74 04                	je     800b24 <strtol+0xc6>
  800b20:	89 c8                	mov    %ecx,%eax
  800b22:	f7 d8                	neg    %eax
}
  800b24:	5b                   	pop    %ebx
  800b25:	5e                   	pop    %esi
  800b26:	5f                   	pop    %edi
  800b27:	c9                   	leave  
  800b28:	c3                   	ret    
  800b29:	00 00                	add    %al,(%eax)
	...

00800b2c <syscall>:
	return ret;
}

static int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800b2c:	55                   	push   %ebp
  800b2d:	89 e5                	mov    %esp,%ebp
  800b2f:	57                   	push   %edi
  800b30:	56                   	push   %esi
  800b31:	53                   	push   %ebx
  800b32:	83 ec 1c             	sub    $0x1c,%esp
  800b35:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800b38:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800b3b:	89 ca                	mov    %ecx,%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b3d:	8b 75 14             	mov    0x14(%ebp),%esi
  800b40:	8b 7d 10             	mov    0x10(%ebp),%edi
  800b43:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800b46:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b49:	cd 30                	int    $0x30
  800b4b:	89 c2                	mov    %eax,%edx
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b4d:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800b51:	74 1c                	je     800b6f <syscall+0x43>
  800b53:	85 c0                	test   %eax,%eax
  800b55:	7e 18                	jle    800b6f <syscall+0x43>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b57:	83 ec 0c             	sub    $0xc,%esp
  800b5a:	50                   	push   %eax
  800b5b:	ff 75 e4             	pushl  -0x1c(%ebp)
  800b5e:	68 7f 22 80 00       	push   $0x80227f
  800b63:	6a 42                	push   $0x42
  800b65:	68 9c 22 80 00       	push   $0x80229c
  800b6a:	e8 b1 f5 ff ff       	call   800120 <_panic>

	return ret;
}
  800b6f:	89 d0                	mov    %edx,%eax
  800b71:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b74:	5b                   	pop    %ebx
  800b75:	5e                   	pop    %esi
  800b76:	5f                   	pop    %edi
  800b77:	c9                   	leave  
  800b78:	c3                   	ret    

00800b79 <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{	
  800b79:	55                   	push   %ebp
  800b7a:	89 e5                	mov    %esp,%ebp
  800b7c:	83 ec 08             	sub    $0x8,%esp
	// my_sysenter(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
	// return;
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  800b7f:	6a 00                	push   $0x0
  800b81:	6a 00                	push   $0x0
  800b83:	6a 00                	push   $0x0
  800b85:	ff 75 0c             	pushl  0xc(%ebp)
  800b88:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b8b:	ba 00 00 00 00       	mov    $0x0,%edx
  800b90:	b8 00 00 00 00       	mov    $0x0,%eax
  800b95:	e8 92 ff ff ff       	call   800b2c <syscall>
  800b9a:	83 c4 10             	add    $0x10,%esp
	return;
}
  800b9d:	c9                   	leave  
  800b9e:	c3                   	ret    

00800b9f <sys_cgetc>:

int
sys_cgetc(void)
{
  800b9f:	55                   	push   %ebp
  800ba0:	89 e5                	mov    %esp,%ebp
  800ba2:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_cgetc, 0, 0, 0, 0, 0, 0);
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  800ba5:	6a 00                	push   $0x0
  800ba7:	6a 00                	push   $0x0
  800ba9:	6a 00                	push   $0x0
  800bab:	6a 00                	push   $0x0
  800bad:	b9 00 00 00 00       	mov    $0x0,%ecx
  800bb2:	ba 00 00 00 00       	mov    $0x0,%edx
  800bb7:	b8 01 00 00 00       	mov    $0x1,%eax
  800bbc:	e8 6b ff ff ff       	call   800b2c <syscall>
}
  800bc1:	c9                   	leave  
  800bc2:	c3                   	ret    

00800bc3 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800bc3:	55                   	push   %ebp
  800bc4:	89 e5                	mov    %esp,%ebp
  800bc6:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  800bc9:	6a 00                	push   $0x0
  800bcb:	6a 00                	push   $0x0
  800bcd:	6a 00                	push   $0x0
  800bcf:	6a 00                	push   $0x0
  800bd1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800bd4:	ba 01 00 00 00       	mov    $0x1,%edx
  800bd9:	b8 03 00 00 00       	mov    $0x3,%eax
  800bde:	e8 49 ff ff ff       	call   800b2c <syscall>
}
  800be3:	c9                   	leave  
  800be4:	c3                   	ret    

00800be5 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800be5:	55                   	push   %ebp
  800be6:	89 e5                	mov    %esp,%ebp
  800be8:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_getenvid, 0, 0, 0, 0, 0, 0);
	return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  800beb:	6a 00                	push   $0x0
  800bed:	6a 00                	push   $0x0
  800bef:	6a 00                	push   $0x0
  800bf1:	6a 00                	push   $0x0
  800bf3:	b9 00 00 00 00       	mov    $0x0,%ecx
  800bf8:	ba 00 00 00 00       	mov    $0x0,%edx
  800bfd:	b8 02 00 00 00       	mov    $0x2,%eax
  800c02:	e8 25 ff ff ff       	call   800b2c <syscall>
}
  800c07:	c9                   	leave  
  800c08:	c3                   	ret    

00800c09 <sys_yield>:

void
sys_yield(void)
{
  800c09:	55                   	push   %ebp
  800c0a:	89 e5                	mov    %esp,%ebp
  800c0c:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  800c0f:	6a 00                	push   $0x0
  800c11:	6a 00                	push   $0x0
  800c13:	6a 00                	push   $0x0
  800c15:	6a 00                	push   $0x0
  800c17:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c1c:	ba 00 00 00 00       	mov    $0x0,%edx
  800c21:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c26:	e8 01 ff ff ff       	call   800b2c <syscall>
  800c2b:	83 c4 10             	add    $0x10,%esp
}
  800c2e:	c9                   	leave  
  800c2f:	c3                   	ret    

00800c30 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c30:	55                   	push   %ebp
  800c31:	89 e5                	mov    %esp,%ebp
  800c33:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  800c36:	6a 00                	push   $0x0
  800c38:	6a 00                	push   $0x0
  800c3a:	ff 75 10             	pushl  0x10(%ebp)
  800c3d:	ff 75 0c             	pushl  0xc(%ebp)
  800c40:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c43:	ba 01 00 00 00       	mov    $0x1,%edx
  800c48:	b8 04 00 00 00       	mov    $0x4,%eax
  800c4d:	e8 da fe ff ff       	call   800b2c <syscall>
}
  800c52:	c9                   	leave  
  800c53:	c3                   	ret    

00800c54 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c54:	55                   	push   %ebp
  800c55:	89 e5                	mov    %esp,%ebp
  800c57:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
  800c5a:	ff 75 18             	pushl  0x18(%ebp)
  800c5d:	ff 75 14             	pushl  0x14(%ebp)
  800c60:	ff 75 10             	pushl  0x10(%ebp)
  800c63:	ff 75 0c             	pushl  0xc(%ebp)
  800c66:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c69:	ba 01 00 00 00       	mov    $0x1,%edx
  800c6e:	b8 05 00 00 00       	mov    $0x5,%eax
  800c73:	e8 b4 fe ff ff       	call   800b2c <syscall>
}
  800c78:	c9                   	leave  
  800c79:	c3                   	ret    

00800c7a <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c7a:	55                   	push   %ebp
  800c7b:	89 e5                	mov    %esp,%ebp
  800c7d:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  800c80:	6a 00                	push   $0x0
  800c82:	6a 00                	push   $0x0
  800c84:	6a 00                	push   $0x0
  800c86:	ff 75 0c             	pushl  0xc(%ebp)
  800c89:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c8c:	ba 01 00 00 00       	mov    $0x1,%edx
  800c91:	b8 06 00 00 00       	mov    $0x6,%eax
  800c96:	e8 91 fe ff ff       	call   800b2c <syscall>
}
  800c9b:	c9                   	leave  
  800c9c:	c3                   	ret    

00800c9d <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c9d:	55                   	push   %ebp
  800c9e:	89 e5                	mov    %esp,%ebp
  800ca0:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  800ca3:	6a 00                	push   $0x0
  800ca5:	6a 00                	push   $0x0
  800ca7:	6a 00                	push   $0x0
  800ca9:	ff 75 0c             	pushl  0xc(%ebp)
  800cac:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800caf:	ba 01 00 00 00       	mov    $0x1,%edx
  800cb4:	b8 08 00 00 00       	mov    $0x8,%eax
  800cb9:	e8 6e fe ff ff       	call   800b2c <syscall>
}
  800cbe:	c9                   	leave  
  800cbf:	c3                   	ret    

00800cc0 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800cc0:	55                   	push   %ebp
  800cc1:	89 e5                	mov    %esp,%ebp
  800cc3:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
  800cc6:	6a 00                	push   $0x0
  800cc8:	6a 00                	push   $0x0
  800cca:	6a 00                	push   $0x0
  800ccc:	ff 75 0c             	pushl  0xc(%ebp)
  800ccf:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800cd2:	ba 01 00 00 00       	mov    $0x1,%edx
  800cd7:	b8 09 00 00 00       	mov    $0x9,%eax
  800cdc:	e8 4b fe ff ff       	call   800b2c <syscall>
}
  800ce1:	c9                   	leave  
  800ce2:	c3                   	ret    

00800ce3 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800ce3:	55                   	push   %ebp
  800ce4:	89 e5                	mov    %esp,%ebp
  800ce6:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  800ce9:	6a 00                	push   $0x0
  800ceb:	6a 00                	push   $0x0
  800ced:	6a 00                	push   $0x0
  800cef:	ff 75 0c             	pushl  0xc(%ebp)
  800cf2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800cf5:	ba 01 00 00 00       	mov    $0x1,%edx
  800cfa:	b8 0a 00 00 00       	mov    $0xa,%eax
  800cff:	e8 28 fe ff ff       	call   800b2c <syscall>
}
  800d04:	c9                   	leave  
  800d05:	c3                   	ret    

00800d06 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d06:	55                   	push   %ebp
  800d07:	89 e5                	mov    %esp,%ebp
  800d09:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  800d0c:	6a 00                	push   $0x0
  800d0e:	ff 75 14             	pushl  0x14(%ebp)
  800d11:	ff 75 10             	pushl  0x10(%ebp)
  800d14:	ff 75 0c             	pushl  0xc(%ebp)
  800d17:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d1a:	ba 00 00 00 00       	mov    $0x0,%edx
  800d1f:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d24:	e8 03 fe ff ff       	call   800b2c <syscall>
}
  800d29:	c9                   	leave  
  800d2a:	c3                   	ret    

00800d2b <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d2b:	55                   	push   %ebp
  800d2c:	89 e5                	mov    %esp,%ebp
  800d2e:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  800d31:	6a 00                	push   $0x0
  800d33:	6a 00                	push   $0x0
  800d35:	6a 00                	push   $0x0
  800d37:	6a 00                	push   $0x0
  800d39:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d3c:	ba 01 00 00 00       	mov    $0x1,%edx
  800d41:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d46:	e8 e1 fd ff ff       	call   800b2c <syscall>
}
  800d4b:	c9                   	leave  
  800d4c:	c3                   	ret    

00800d4d <sys_set_priority>:

int
sys_set_priority(envid_t envid, uint32_t new_priority)
{
  800d4d:	55                   	push   %ebp
  800d4e:	89 e5                	mov    %esp,%ebp
  800d50:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_set_priority, 0, envid, new_priority, 0, 0, 0);
  800d53:	6a 00                	push   $0x0
  800d55:	6a 00                	push   $0x0
  800d57:	6a 00                	push   $0x0
  800d59:	ff 75 0c             	pushl  0xc(%ebp)
  800d5c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d5f:	ba 00 00 00 00       	mov    $0x0,%edx
  800d64:	b8 0e 00 00 00       	mov    $0xe,%eax
  800d69:	e8 be fd ff ff       	call   800b2c <syscall>
}
  800d6e:	c9                   	leave  
  800d6f:	c3                   	ret    

00800d70 <sys_exec>:

int
sys_exec(uint32_t eip, uint32_t esp, void * ph, uint32_t elf_phnum)
{
  800d70:	55                   	push   %ebp
  800d71:	89 e5                	mov    %esp,%ebp
  800d73:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_exec, 0, eip, esp, (uint32_t)ph, elf_phnum, 0);
  800d76:	6a 00                	push   $0x0
  800d78:	ff 75 14             	pushl  0x14(%ebp)
  800d7b:	ff 75 10             	pushl  0x10(%ebp)
  800d7e:	ff 75 0c             	pushl  0xc(%ebp)
  800d81:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d84:	ba 00 00 00 00       	mov    $0x0,%edx
  800d89:	b8 0f 00 00 00       	mov    $0xf,%eax
  800d8e:	e8 99 fd ff ff       	call   800b2c <syscall>
} 
  800d93:	c9                   	leave  
  800d94:	c3                   	ret    

00800d95 <sys_join>:

// thread:
int
sys_join(envid_t envid)
{
  800d95:	55                   	push   %ebp
  800d96:	89 e5                	mov    %esp,%ebp
  800d98:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_join, 0, envid, 0, 0, 0, 0);
  800d9b:	6a 00                	push   $0x0
  800d9d:	6a 00                	push   $0x0
  800d9f:	6a 00                	push   $0x0
  800da1:	6a 00                	push   $0x0
  800da3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800da6:	ba 00 00 00 00       	mov    $0x0,%edx
  800dab:	b8 11 00 00 00       	mov    $0x11,%eax
  800db0:	e8 77 fd ff ff       	call   800b2c <syscall>
}
  800db5:	c9                   	leave  
  800db6:	c3                   	ret    

00800db7 <sys_getpid>:

envid_t
sys_getpid(void)
{
  800db7:	55                   	push   %ebp
  800db8:	89 e5                	mov    %esp,%ebp
  800dba:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_getpid, 0, 0, 0, 0, 0, 0);
  800dbd:	6a 00                	push   $0x0
  800dbf:	6a 00                	push   $0x0
  800dc1:	6a 00                	push   $0x0
  800dc3:	6a 00                	push   $0x0
  800dc5:	b9 00 00 00 00       	mov    $0x0,%ecx
  800dca:	ba 00 00 00 00       	mov    $0x0,%edx
  800dcf:	b8 10 00 00 00       	mov    $0x10,%eax
  800dd4:	e8 53 fd ff ff       	call   800b2c <syscall>
  800dd9:	c9                   	leave  
  800dda:	c3                   	ret    
	...

00800ddc <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  800ddc:	55                   	push   %ebp
  800ddd:	89 e5                	mov    %esp,%ebp
  800ddf:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  800de2:	83 3d 08 40 80 00 00 	cmpl   $0x0,0x804008
  800de9:	75 52                	jne    800e3d <set_pgfault_handler+0x61>
		// First time through!	
		// LAB 4: Your code here.

		//int sys_page_alloc(envid_t envid, void *va, int perm)
		r = sys_page_alloc(0, (void*)(UXSTACKTOP - PGSIZE), PTE_U | PTE_W | PTE_P);
  800deb:	83 ec 04             	sub    $0x4,%esp
  800dee:	6a 07                	push   $0x7
  800df0:	68 00 f0 bf ee       	push   $0xeebff000
  800df5:	6a 00                	push   $0x0
  800df7:	e8 34 fe ff ff       	call   800c30 <sys_page_alloc>
		if (r < 0) {
  800dfc:	83 c4 10             	add    $0x10,%esp
  800dff:	85 c0                	test   %eax,%eax
  800e01:	79 12                	jns    800e15 <set_pgfault_handler+0x39>
			panic("sys_page_alloc error : %e\n", r);
  800e03:	50                   	push   %eax
  800e04:	68 aa 22 80 00       	push   $0x8022aa
  800e09:	6a 24                	push   $0x24
  800e0b:	68 c5 22 80 00       	push   $0x8022c5
  800e10:	e8 0b f3 ff ff       	call   800120 <_panic>
		}

		// how to know envid, put 0, envid2env will help us to get curenv in syscall
		r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);		
  800e15:	83 ec 08             	sub    $0x8,%esp
  800e18:	68 48 0e 80 00       	push   $0x800e48
  800e1d:	6a 00                	push   $0x0
  800e1f:	e8 bf fe ff ff       	call   800ce3 <sys_env_set_pgfault_upcall>
		if (r < 0) {
  800e24:	83 c4 10             	add    $0x10,%esp
  800e27:	85 c0                	test   %eax,%eax
  800e29:	79 12                	jns    800e3d <set_pgfault_handler+0x61>
			panic("sys_env_set_pgfault_upcall error : %e\n", r);
  800e2b:	50                   	push   %eax
  800e2c:	68 d4 22 80 00       	push   $0x8022d4
  800e31:	6a 2a                	push   $0x2a
  800e33:	68 c5 22 80 00       	push   $0x8022c5
  800e38:	e8 e3 f2 ff ff       	call   800120 <_panic>
		}
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  800e3d:	8b 45 08             	mov    0x8(%ebp),%eax
  800e40:	a3 08 40 80 00       	mov    %eax,0x804008
}
  800e45:	c9                   	leave  
  800e46:	c3                   	ret    
	...

00800e48 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  800e48:	54                   	push   %esp
	movl _pgfault_handler, %eax
  800e49:	a1 08 40 80 00       	mov    0x804008,%eax
	call *%eax
  800e4e:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  800e50:	83 c4 04             	add    $0x4,%esp
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	
	// fix old esp
	movl 0x30(%esp), %eax
  800e53:	8b 44 24 30          	mov    0x30(%esp),%eax
	subl $0x4, %eax
  800e57:	83 e8 04             	sub    $0x4,%eax
	movl %eax, 0x30(%esp)
  800e5a:	89 44 24 30          	mov    %eax,0x30(%esp)

	// set trap-time %eip
	movl 0x28(%esp), %ebx
  800e5e:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	movl %ebx, (%eax)
  800e62:	89 18                	mov    %ebx,(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $0x08, %esp 	// ignore err_code and fault_va
  800e64:	83 c4 08             	add    $0x8,%esp
	popal 				// restore registers
  800e67:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x04, %esp 	// ignore eip 
  800e68:	83 c4 04             	add    $0x4,%esp
	popfl				// modify eflags
  800e6b:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  800e6c:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  800e6d:	c3                   	ret    
	...

00800e70 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800e70:	55                   	push   %ebp
  800e71:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800e73:	8b 45 08             	mov    0x8(%ebp),%eax
  800e76:	05 00 00 00 30       	add    $0x30000000,%eax
  800e7b:	c1 e8 0c             	shr    $0xc,%eax
}
  800e7e:	c9                   	leave  
  800e7f:	c3                   	ret    

00800e80 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800e80:	55                   	push   %ebp
  800e81:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800e83:	ff 75 08             	pushl  0x8(%ebp)
  800e86:	e8 e5 ff ff ff       	call   800e70 <fd2num>
  800e8b:	83 c4 04             	add    $0x4,%esp
  800e8e:	05 20 00 0d 00       	add    $0xd0020,%eax
  800e93:	c1 e0 0c             	shl    $0xc,%eax
}
  800e96:	c9                   	leave  
  800e97:	c3                   	ret    

00800e98 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800e98:	55                   	push   %ebp
  800e99:	89 e5                	mov    %esp,%ebp
  800e9b:	53                   	push   %ebx
  800e9c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800e9f:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  800ea4:	a8 01                	test   $0x1,%al
  800ea6:	74 34                	je     800edc <fd_alloc+0x44>
  800ea8:	a1 00 00 74 ef       	mov    0xef740000,%eax
  800ead:	a8 01                	test   $0x1,%al
  800eaf:	74 32                	je     800ee3 <fd_alloc+0x4b>
  800eb1:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
  800eb6:	89 c1                	mov    %eax,%ecx
  800eb8:	89 c2                	mov    %eax,%edx
  800eba:	c1 ea 16             	shr    $0x16,%edx
  800ebd:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800ec4:	f6 c2 01             	test   $0x1,%dl
  800ec7:	74 1f                	je     800ee8 <fd_alloc+0x50>
  800ec9:	89 c2                	mov    %eax,%edx
  800ecb:	c1 ea 0c             	shr    $0xc,%edx
  800ece:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800ed5:	f6 c2 01             	test   $0x1,%dl
  800ed8:	75 17                	jne    800ef1 <fd_alloc+0x59>
  800eda:	eb 0c                	jmp    800ee8 <fd_alloc+0x50>
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  800edc:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
  800ee1:	eb 05                	jmp    800ee8 <fd_alloc+0x50>
  800ee3:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
  800ee8:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  800eea:	b8 00 00 00 00       	mov    $0x0,%eax
  800eef:	eb 17                	jmp    800f08 <fd_alloc+0x70>
  800ef1:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800ef6:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800efb:	75 b9                	jne    800eb6 <fd_alloc+0x1e>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800efd:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  800f03:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800f08:	5b                   	pop    %ebx
  800f09:	c9                   	leave  
  800f0a:	c3                   	ret    

00800f0b <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800f0b:	55                   	push   %ebp
  800f0c:	89 e5                	mov    %esp,%ebp
  800f0e:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800f11:	83 f8 1f             	cmp    $0x1f,%eax
  800f14:	77 36                	ja     800f4c <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800f16:	05 00 00 0d 00       	add    $0xd0000,%eax
  800f1b:	c1 e0 0c             	shl    $0xc,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800f1e:	89 c2                	mov    %eax,%edx
  800f20:	c1 ea 16             	shr    $0x16,%edx
  800f23:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800f2a:	f6 c2 01             	test   $0x1,%dl
  800f2d:	74 24                	je     800f53 <fd_lookup+0x48>
  800f2f:	89 c2                	mov    %eax,%edx
  800f31:	c1 ea 0c             	shr    $0xc,%edx
  800f34:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800f3b:	f6 c2 01             	test   $0x1,%dl
  800f3e:	74 1a                	je     800f5a <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800f40:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f43:	89 02                	mov    %eax,(%edx)
	return 0;
  800f45:	b8 00 00 00 00       	mov    $0x0,%eax
  800f4a:	eb 13                	jmp    800f5f <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800f4c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f51:	eb 0c                	jmp    800f5f <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800f53:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f58:	eb 05                	jmp    800f5f <fd_lookup+0x54>
  800f5a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800f5f:	c9                   	leave  
  800f60:	c3                   	ret    

00800f61 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800f61:	55                   	push   %ebp
  800f62:	89 e5                	mov    %esp,%ebp
  800f64:	53                   	push   %ebx
  800f65:	83 ec 04             	sub    $0x4,%esp
  800f68:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f6b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  800f6e:	39 0d 04 30 80 00    	cmp    %ecx,0x803004
  800f74:	74 0d                	je     800f83 <dev_lookup+0x22>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800f76:	b8 00 00 00 00       	mov    $0x0,%eax
  800f7b:	eb 14                	jmp    800f91 <dev_lookup+0x30>
		if (devtab[i]->dev_id == dev_id) {
  800f7d:	39 0a                	cmp    %ecx,(%edx)
  800f7f:	75 10                	jne    800f91 <dev_lookup+0x30>
  800f81:	eb 05                	jmp    800f88 <dev_lookup+0x27>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800f83:	ba 04 30 80 00       	mov    $0x803004,%edx
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
  800f88:	89 13                	mov    %edx,(%ebx)
			return 0;
  800f8a:	b8 00 00 00 00       	mov    $0x0,%eax
  800f8f:	eb 31                	jmp    800fc2 <dev_lookup+0x61>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800f91:	40                   	inc    %eax
  800f92:	8b 14 85 7c 23 80 00 	mov    0x80237c(,%eax,4),%edx
  800f99:	85 d2                	test   %edx,%edx
  800f9b:	75 e0                	jne    800f7d <dev_lookup+0x1c>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800f9d:	a1 04 40 80 00       	mov    0x804004,%eax
  800fa2:	8b 40 48             	mov    0x48(%eax),%eax
  800fa5:	83 ec 04             	sub    $0x4,%esp
  800fa8:	51                   	push   %ecx
  800fa9:	50                   	push   %eax
  800faa:	68 fc 22 80 00       	push   $0x8022fc
  800faf:	e8 44 f2 ff ff       	call   8001f8 <cprintf>
	*dev = 0;
  800fb4:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  800fba:	83 c4 10             	add    $0x10,%esp
  800fbd:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800fc2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800fc5:	c9                   	leave  
  800fc6:	c3                   	ret    

00800fc7 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800fc7:	55                   	push   %ebp
  800fc8:	89 e5                	mov    %esp,%ebp
  800fca:	56                   	push   %esi
  800fcb:	53                   	push   %ebx
  800fcc:	83 ec 20             	sub    $0x20,%esp
  800fcf:	8b 75 08             	mov    0x8(%ebp),%esi
  800fd2:	8a 45 0c             	mov    0xc(%ebp),%al
  800fd5:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800fd8:	56                   	push   %esi
  800fd9:	e8 92 fe ff ff       	call   800e70 <fd2num>
  800fde:	8d 55 f4             	lea    -0xc(%ebp),%edx
  800fe1:	89 14 24             	mov    %edx,(%esp)
  800fe4:	50                   	push   %eax
  800fe5:	e8 21 ff ff ff       	call   800f0b <fd_lookup>
  800fea:	89 c3                	mov    %eax,%ebx
  800fec:	83 c4 08             	add    $0x8,%esp
  800fef:	85 c0                	test   %eax,%eax
  800ff1:	78 05                	js     800ff8 <fd_close+0x31>
	    || fd != fd2)
  800ff3:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800ff6:	74 0d                	je     801005 <fd_close+0x3e>
		return (must_exist ? r : 0);
  800ff8:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  800ffc:	75 48                	jne    801046 <fd_close+0x7f>
  800ffe:	bb 00 00 00 00       	mov    $0x0,%ebx
  801003:	eb 41                	jmp    801046 <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801005:	83 ec 08             	sub    $0x8,%esp
  801008:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80100b:	50                   	push   %eax
  80100c:	ff 36                	pushl  (%esi)
  80100e:	e8 4e ff ff ff       	call   800f61 <dev_lookup>
  801013:	89 c3                	mov    %eax,%ebx
  801015:	83 c4 10             	add    $0x10,%esp
  801018:	85 c0                	test   %eax,%eax
  80101a:	78 1c                	js     801038 <fd_close+0x71>
		if (dev->dev_close)
  80101c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80101f:	8b 40 10             	mov    0x10(%eax),%eax
  801022:	85 c0                	test   %eax,%eax
  801024:	74 0d                	je     801033 <fd_close+0x6c>
			r = (*dev->dev_close)(fd);
  801026:	83 ec 0c             	sub    $0xc,%esp
  801029:	56                   	push   %esi
  80102a:	ff d0                	call   *%eax
  80102c:	89 c3                	mov    %eax,%ebx
  80102e:	83 c4 10             	add    $0x10,%esp
  801031:	eb 05                	jmp    801038 <fd_close+0x71>
		else
			r = 0;
  801033:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801038:	83 ec 08             	sub    $0x8,%esp
  80103b:	56                   	push   %esi
  80103c:	6a 00                	push   $0x0
  80103e:	e8 37 fc ff ff       	call   800c7a <sys_page_unmap>
	return r;
  801043:	83 c4 10             	add    $0x10,%esp
}
  801046:	89 d8                	mov    %ebx,%eax
  801048:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80104b:	5b                   	pop    %ebx
  80104c:	5e                   	pop    %esi
  80104d:	c9                   	leave  
  80104e:	c3                   	ret    

0080104f <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80104f:	55                   	push   %ebp
  801050:	89 e5                	mov    %esp,%ebp
  801052:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801055:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801058:	50                   	push   %eax
  801059:	ff 75 08             	pushl  0x8(%ebp)
  80105c:	e8 aa fe ff ff       	call   800f0b <fd_lookup>
  801061:	83 c4 08             	add    $0x8,%esp
  801064:	85 c0                	test   %eax,%eax
  801066:	78 10                	js     801078 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801068:	83 ec 08             	sub    $0x8,%esp
  80106b:	6a 01                	push   $0x1
  80106d:	ff 75 f4             	pushl  -0xc(%ebp)
  801070:	e8 52 ff ff ff       	call   800fc7 <fd_close>
  801075:	83 c4 10             	add    $0x10,%esp
}
  801078:	c9                   	leave  
  801079:	c3                   	ret    

0080107a <close_all>:

void
close_all(void)
{
  80107a:	55                   	push   %ebp
  80107b:	89 e5                	mov    %esp,%ebp
  80107d:	53                   	push   %ebx
  80107e:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801081:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801086:	83 ec 0c             	sub    $0xc,%esp
  801089:	53                   	push   %ebx
  80108a:	e8 c0 ff ff ff       	call   80104f <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80108f:	43                   	inc    %ebx
  801090:	83 c4 10             	add    $0x10,%esp
  801093:	83 fb 20             	cmp    $0x20,%ebx
  801096:	75 ee                	jne    801086 <close_all+0xc>
		close(i);
}
  801098:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80109b:	c9                   	leave  
  80109c:	c3                   	ret    

0080109d <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80109d:	55                   	push   %ebp
  80109e:	89 e5                	mov    %esp,%ebp
  8010a0:	57                   	push   %edi
  8010a1:	56                   	push   %esi
  8010a2:	53                   	push   %ebx
  8010a3:	83 ec 2c             	sub    $0x2c,%esp
  8010a6:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8010a9:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8010ac:	50                   	push   %eax
  8010ad:	ff 75 08             	pushl  0x8(%ebp)
  8010b0:	e8 56 fe ff ff       	call   800f0b <fd_lookup>
  8010b5:	89 c3                	mov    %eax,%ebx
  8010b7:	83 c4 08             	add    $0x8,%esp
  8010ba:	85 c0                	test   %eax,%eax
  8010bc:	0f 88 c0 00 00 00    	js     801182 <dup+0xe5>
		return r;
	close(newfdnum);
  8010c2:	83 ec 0c             	sub    $0xc,%esp
  8010c5:	57                   	push   %edi
  8010c6:	e8 84 ff ff ff       	call   80104f <close>

	newfd = INDEX2FD(newfdnum);
  8010cb:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  8010d1:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  8010d4:	83 c4 04             	add    $0x4,%esp
  8010d7:	ff 75 e4             	pushl  -0x1c(%ebp)
  8010da:	e8 a1 fd ff ff       	call   800e80 <fd2data>
  8010df:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  8010e1:	89 34 24             	mov    %esi,(%esp)
  8010e4:	e8 97 fd ff ff       	call   800e80 <fd2data>
  8010e9:	83 c4 10             	add    $0x10,%esp
  8010ec:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8010ef:	89 d8                	mov    %ebx,%eax
  8010f1:	c1 e8 16             	shr    $0x16,%eax
  8010f4:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8010fb:	a8 01                	test   $0x1,%al
  8010fd:	74 37                	je     801136 <dup+0x99>
  8010ff:	89 d8                	mov    %ebx,%eax
  801101:	c1 e8 0c             	shr    $0xc,%eax
  801104:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80110b:	f6 c2 01             	test   $0x1,%dl
  80110e:	74 26                	je     801136 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801110:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801117:	83 ec 0c             	sub    $0xc,%esp
  80111a:	25 07 0e 00 00       	and    $0xe07,%eax
  80111f:	50                   	push   %eax
  801120:	ff 75 d4             	pushl  -0x2c(%ebp)
  801123:	6a 00                	push   $0x0
  801125:	53                   	push   %ebx
  801126:	6a 00                	push   $0x0
  801128:	e8 27 fb ff ff       	call   800c54 <sys_page_map>
  80112d:	89 c3                	mov    %eax,%ebx
  80112f:	83 c4 20             	add    $0x20,%esp
  801132:	85 c0                	test   %eax,%eax
  801134:	78 2d                	js     801163 <dup+0xc6>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801136:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801139:	89 c2                	mov    %eax,%edx
  80113b:	c1 ea 0c             	shr    $0xc,%edx
  80113e:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801145:	83 ec 0c             	sub    $0xc,%esp
  801148:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  80114e:	52                   	push   %edx
  80114f:	56                   	push   %esi
  801150:	6a 00                	push   $0x0
  801152:	50                   	push   %eax
  801153:	6a 00                	push   $0x0
  801155:	e8 fa fa ff ff       	call   800c54 <sys_page_map>
  80115a:	89 c3                	mov    %eax,%ebx
  80115c:	83 c4 20             	add    $0x20,%esp
  80115f:	85 c0                	test   %eax,%eax
  801161:	79 1d                	jns    801180 <dup+0xe3>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801163:	83 ec 08             	sub    $0x8,%esp
  801166:	56                   	push   %esi
  801167:	6a 00                	push   $0x0
  801169:	e8 0c fb ff ff       	call   800c7a <sys_page_unmap>
	sys_page_unmap(0, nva);
  80116e:	83 c4 08             	add    $0x8,%esp
  801171:	ff 75 d4             	pushl  -0x2c(%ebp)
  801174:	6a 00                	push   $0x0
  801176:	e8 ff fa ff ff       	call   800c7a <sys_page_unmap>
	return r;
  80117b:	83 c4 10             	add    $0x10,%esp
  80117e:	eb 02                	jmp    801182 <dup+0xe5>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  801180:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  801182:	89 d8                	mov    %ebx,%eax
  801184:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801187:	5b                   	pop    %ebx
  801188:	5e                   	pop    %esi
  801189:	5f                   	pop    %edi
  80118a:	c9                   	leave  
  80118b:	c3                   	ret    

0080118c <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80118c:	55                   	push   %ebp
  80118d:	89 e5                	mov    %esp,%ebp
  80118f:	53                   	push   %ebx
  801190:	83 ec 14             	sub    $0x14,%esp
  801193:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801196:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801199:	50                   	push   %eax
  80119a:	53                   	push   %ebx
  80119b:	e8 6b fd ff ff       	call   800f0b <fd_lookup>
  8011a0:	83 c4 08             	add    $0x8,%esp
  8011a3:	85 c0                	test   %eax,%eax
  8011a5:	78 67                	js     80120e <read+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011a7:	83 ec 08             	sub    $0x8,%esp
  8011aa:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011ad:	50                   	push   %eax
  8011ae:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011b1:	ff 30                	pushl  (%eax)
  8011b3:	e8 a9 fd ff ff       	call   800f61 <dev_lookup>
  8011b8:	83 c4 10             	add    $0x10,%esp
  8011bb:	85 c0                	test   %eax,%eax
  8011bd:	78 4f                	js     80120e <read+0x82>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8011bf:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011c2:	8b 50 08             	mov    0x8(%eax),%edx
  8011c5:	83 e2 03             	and    $0x3,%edx
  8011c8:	83 fa 01             	cmp    $0x1,%edx
  8011cb:	75 21                	jne    8011ee <read+0x62>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8011cd:	a1 04 40 80 00       	mov    0x804004,%eax
  8011d2:	8b 40 48             	mov    0x48(%eax),%eax
  8011d5:	83 ec 04             	sub    $0x4,%esp
  8011d8:	53                   	push   %ebx
  8011d9:	50                   	push   %eax
  8011da:	68 40 23 80 00       	push   $0x802340
  8011df:	e8 14 f0 ff ff       	call   8001f8 <cprintf>
		return -E_INVAL;
  8011e4:	83 c4 10             	add    $0x10,%esp
  8011e7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8011ec:	eb 20                	jmp    80120e <read+0x82>
	}
	if (!dev->dev_read)
  8011ee:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8011f1:	8b 52 08             	mov    0x8(%edx),%edx
  8011f4:	85 d2                	test   %edx,%edx
  8011f6:	74 11                	je     801209 <read+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8011f8:	83 ec 04             	sub    $0x4,%esp
  8011fb:	ff 75 10             	pushl  0x10(%ebp)
  8011fe:	ff 75 0c             	pushl  0xc(%ebp)
  801201:	50                   	push   %eax
  801202:	ff d2                	call   *%edx
  801204:	83 c4 10             	add    $0x10,%esp
  801207:	eb 05                	jmp    80120e <read+0x82>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801209:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  80120e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801211:	c9                   	leave  
  801212:	c3                   	ret    

00801213 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801213:	55                   	push   %ebp
  801214:	89 e5                	mov    %esp,%ebp
  801216:	57                   	push   %edi
  801217:	56                   	push   %esi
  801218:	53                   	push   %ebx
  801219:	83 ec 0c             	sub    $0xc,%esp
  80121c:	8b 7d 08             	mov    0x8(%ebp),%edi
  80121f:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801222:	85 f6                	test   %esi,%esi
  801224:	74 31                	je     801257 <readn+0x44>
  801226:	b8 00 00 00 00       	mov    $0x0,%eax
  80122b:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = read(fdnum, (char*)buf + tot, n - tot);
  801230:	83 ec 04             	sub    $0x4,%esp
  801233:	89 f2                	mov    %esi,%edx
  801235:	29 c2                	sub    %eax,%edx
  801237:	52                   	push   %edx
  801238:	03 45 0c             	add    0xc(%ebp),%eax
  80123b:	50                   	push   %eax
  80123c:	57                   	push   %edi
  80123d:	e8 4a ff ff ff       	call   80118c <read>
		if (m < 0)
  801242:	83 c4 10             	add    $0x10,%esp
  801245:	85 c0                	test   %eax,%eax
  801247:	78 17                	js     801260 <readn+0x4d>
			return m;
		if (m == 0)
  801249:	85 c0                	test   %eax,%eax
  80124b:	74 11                	je     80125e <readn+0x4b>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80124d:	01 c3                	add    %eax,%ebx
  80124f:	89 d8                	mov    %ebx,%eax
  801251:	39 f3                	cmp    %esi,%ebx
  801253:	72 db                	jb     801230 <readn+0x1d>
  801255:	eb 09                	jmp    801260 <readn+0x4d>
  801257:	b8 00 00 00 00       	mov    $0x0,%eax
  80125c:	eb 02                	jmp    801260 <readn+0x4d>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  80125e:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  801260:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801263:	5b                   	pop    %ebx
  801264:	5e                   	pop    %esi
  801265:	5f                   	pop    %edi
  801266:	c9                   	leave  
  801267:	c3                   	ret    

00801268 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801268:	55                   	push   %ebp
  801269:	89 e5                	mov    %esp,%ebp
  80126b:	53                   	push   %ebx
  80126c:	83 ec 14             	sub    $0x14,%esp
  80126f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801272:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801275:	50                   	push   %eax
  801276:	53                   	push   %ebx
  801277:	e8 8f fc ff ff       	call   800f0b <fd_lookup>
  80127c:	83 c4 08             	add    $0x8,%esp
  80127f:	85 c0                	test   %eax,%eax
  801281:	78 62                	js     8012e5 <write+0x7d>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801283:	83 ec 08             	sub    $0x8,%esp
  801286:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801289:	50                   	push   %eax
  80128a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80128d:	ff 30                	pushl  (%eax)
  80128f:	e8 cd fc ff ff       	call   800f61 <dev_lookup>
  801294:	83 c4 10             	add    $0x10,%esp
  801297:	85 c0                	test   %eax,%eax
  801299:	78 4a                	js     8012e5 <write+0x7d>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80129b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80129e:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8012a2:	75 21                	jne    8012c5 <write+0x5d>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8012a4:	a1 04 40 80 00       	mov    0x804004,%eax
  8012a9:	8b 40 48             	mov    0x48(%eax),%eax
  8012ac:	83 ec 04             	sub    $0x4,%esp
  8012af:	53                   	push   %ebx
  8012b0:	50                   	push   %eax
  8012b1:	68 5c 23 80 00       	push   $0x80235c
  8012b6:	e8 3d ef ff ff       	call   8001f8 <cprintf>
		return -E_INVAL;
  8012bb:	83 c4 10             	add    $0x10,%esp
  8012be:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012c3:	eb 20                	jmp    8012e5 <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8012c5:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8012c8:	8b 52 0c             	mov    0xc(%edx),%edx
  8012cb:	85 d2                	test   %edx,%edx
  8012cd:	74 11                	je     8012e0 <write+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8012cf:	83 ec 04             	sub    $0x4,%esp
  8012d2:	ff 75 10             	pushl  0x10(%ebp)
  8012d5:	ff 75 0c             	pushl  0xc(%ebp)
  8012d8:	50                   	push   %eax
  8012d9:	ff d2                	call   *%edx
  8012db:	83 c4 10             	add    $0x10,%esp
  8012de:	eb 05                	jmp    8012e5 <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8012e0:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  8012e5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012e8:	c9                   	leave  
  8012e9:	c3                   	ret    

008012ea <seek>:

int
seek(int fdnum, off_t offset)
{
  8012ea:	55                   	push   %ebp
  8012eb:	89 e5                	mov    %esp,%ebp
  8012ed:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8012f0:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8012f3:	50                   	push   %eax
  8012f4:	ff 75 08             	pushl  0x8(%ebp)
  8012f7:	e8 0f fc ff ff       	call   800f0b <fd_lookup>
  8012fc:	83 c4 08             	add    $0x8,%esp
  8012ff:	85 c0                	test   %eax,%eax
  801301:	78 0e                	js     801311 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801303:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801306:	8b 55 0c             	mov    0xc(%ebp),%edx
  801309:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80130c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801311:	c9                   	leave  
  801312:	c3                   	ret    

00801313 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801313:	55                   	push   %ebp
  801314:	89 e5                	mov    %esp,%ebp
  801316:	53                   	push   %ebx
  801317:	83 ec 14             	sub    $0x14,%esp
  80131a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80131d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801320:	50                   	push   %eax
  801321:	53                   	push   %ebx
  801322:	e8 e4 fb ff ff       	call   800f0b <fd_lookup>
  801327:	83 c4 08             	add    $0x8,%esp
  80132a:	85 c0                	test   %eax,%eax
  80132c:	78 5f                	js     80138d <ftruncate+0x7a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80132e:	83 ec 08             	sub    $0x8,%esp
  801331:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801334:	50                   	push   %eax
  801335:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801338:	ff 30                	pushl  (%eax)
  80133a:	e8 22 fc ff ff       	call   800f61 <dev_lookup>
  80133f:	83 c4 10             	add    $0x10,%esp
  801342:	85 c0                	test   %eax,%eax
  801344:	78 47                	js     80138d <ftruncate+0x7a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801346:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801349:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80134d:	75 21                	jne    801370 <ftruncate+0x5d>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80134f:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801354:	8b 40 48             	mov    0x48(%eax),%eax
  801357:	83 ec 04             	sub    $0x4,%esp
  80135a:	53                   	push   %ebx
  80135b:	50                   	push   %eax
  80135c:	68 1c 23 80 00       	push   $0x80231c
  801361:	e8 92 ee ff ff       	call   8001f8 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801366:	83 c4 10             	add    $0x10,%esp
  801369:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80136e:	eb 1d                	jmp    80138d <ftruncate+0x7a>
	}
	if (!dev->dev_trunc)
  801370:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801373:	8b 52 18             	mov    0x18(%edx),%edx
  801376:	85 d2                	test   %edx,%edx
  801378:	74 0e                	je     801388 <ftruncate+0x75>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80137a:	83 ec 08             	sub    $0x8,%esp
  80137d:	ff 75 0c             	pushl  0xc(%ebp)
  801380:	50                   	push   %eax
  801381:	ff d2                	call   *%edx
  801383:	83 c4 10             	add    $0x10,%esp
  801386:	eb 05                	jmp    80138d <ftruncate+0x7a>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801388:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  80138d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801390:	c9                   	leave  
  801391:	c3                   	ret    

00801392 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801392:	55                   	push   %ebp
  801393:	89 e5                	mov    %esp,%ebp
  801395:	53                   	push   %ebx
  801396:	83 ec 14             	sub    $0x14,%esp
  801399:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80139c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80139f:	50                   	push   %eax
  8013a0:	ff 75 08             	pushl  0x8(%ebp)
  8013a3:	e8 63 fb ff ff       	call   800f0b <fd_lookup>
  8013a8:	83 c4 08             	add    $0x8,%esp
  8013ab:	85 c0                	test   %eax,%eax
  8013ad:	78 52                	js     801401 <fstat+0x6f>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013af:	83 ec 08             	sub    $0x8,%esp
  8013b2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013b5:	50                   	push   %eax
  8013b6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013b9:	ff 30                	pushl  (%eax)
  8013bb:	e8 a1 fb ff ff       	call   800f61 <dev_lookup>
  8013c0:	83 c4 10             	add    $0x10,%esp
  8013c3:	85 c0                	test   %eax,%eax
  8013c5:	78 3a                	js     801401 <fstat+0x6f>
		return r;
	if (!dev->dev_stat)
  8013c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013ca:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8013ce:	74 2c                	je     8013fc <fstat+0x6a>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8013d0:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8013d3:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8013da:	00 00 00 
	stat->st_isdir = 0;
  8013dd:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8013e4:	00 00 00 
	stat->st_dev = dev;
  8013e7:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8013ed:	83 ec 08             	sub    $0x8,%esp
  8013f0:	53                   	push   %ebx
  8013f1:	ff 75 f0             	pushl  -0x10(%ebp)
  8013f4:	ff 50 14             	call   *0x14(%eax)
  8013f7:	83 c4 10             	add    $0x10,%esp
  8013fa:	eb 05                	jmp    801401 <fstat+0x6f>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8013fc:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801401:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801404:	c9                   	leave  
  801405:	c3                   	ret    

00801406 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801406:	55                   	push   %ebp
  801407:	89 e5                	mov    %esp,%ebp
  801409:	56                   	push   %esi
  80140a:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80140b:	83 ec 08             	sub    $0x8,%esp
  80140e:	6a 00                	push   $0x0
  801410:	ff 75 08             	pushl  0x8(%ebp)
  801413:	e8 78 01 00 00       	call   801590 <open>
  801418:	89 c3                	mov    %eax,%ebx
  80141a:	83 c4 10             	add    $0x10,%esp
  80141d:	85 c0                	test   %eax,%eax
  80141f:	78 1b                	js     80143c <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801421:	83 ec 08             	sub    $0x8,%esp
  801424:	ff 75 0c             	pushl  0xc(%ebp)
  801427:	50                   	push   %eax
  801428:	e8 65 ff ff ff       	call   801392 <fstat>
  80142d:	89 c6                	mov    %eax,%esi
	close(fd);
  80142f:	89 1c 24             	mov    %ebx,(%esp)
  801432:	e8 18 fc ff ff       	call   80104f <close>
	return r;
  801437:	83 c4 10             	add    $0x10,%esp
  80143a:	89 f3                	mov    %esi,%ebx
}
  80143c:	89 d8                	mov    %ebx,%eax
  80143e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801441:	5b                   	pop    %ebx
  801442:	5e                   	pop    %esi
  801443:	c9                   	leave  
  801444:	c3                   	ret    
  801445:	00 00                	add    %al,(%eax)
	...

00801448 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801448:	55                   	push   %ebp
  801449:	89 e5                	mov    %esp,%ebp
  80144b:	56                   	push   %esi
  80144c:	53                   	push   %ebx
  80144d:	89 c3                	mov    %eax,%ebx
  80144f:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  801451:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801458:	75 12                	jne    80146c <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80145a:	83 ec 0c             	sub    $0xc,%esp
  80145d:	6a 01                	push   $0x1
  80145f:	e8 8a 07 00 00       	call   801bee <ipc_find_env>
  801464:	a3 00 40 80 00       	mov    %eax,0x804000
  801469:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80146c:	6a 07                	push   $0x7
  80146e:	68 00 50 80 00       	push   $0x805000
  801473:	53                   	push   %ebx
  801474:	ff 35 00 40 80 00    	pushl  0x804000
  80147a:	e8 1a 07 00 00       	call   801b99 <ipc_send>
	
	return ipc_recv(NULL, dstva, NULL);
  80147f:	83 c4 0c             	add    $0xc,%esp
  801482:	6a 00                	push   $0x0
  801484:	56                   	push   %esi
  801485:	6a 00                	push   $0x0
  801487:	e8 98 06 00 00       	call   801b24 <ipc_recv>
}
  80148c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80148f:	5b                   	pop    %ebx
  801490:	5e                   	pop    %esi
  801491:	c9                   	leave  
  801492:	c3                   	ret    

00801493 <devfile_stat>:
}


static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801493:	55                   	push   %ebp
  801494:	89 e5                	mov    %esp,%ebp
  801496:	53                   	push   %ebx
  801497:	83 ec 04             	sub    $0x4,%esp
  80149a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80149d:	8b 45 08             	mov    0x8(%ebp),%eax
  8014a0:	8b 40 0c             	mov    0xc(%eax),%eax
  8014a3:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0) {
  8014a8:	ba 00 00 00 00       	mov    $0x0,%edx
  8014ad:	b8 05 00 00 00       	mov    $0x5,%eax
  8014b2:	e8 91 ff ff ff       	call   801448 <fsipc>
  8014b7:	85 c0                	test   %eax,%eax
  8014b9:	78 2c                	js     8014e7 <devfile_stat+0x54>
		return r;
	}
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8014bb:	83 ec 08             	sub    $0x8,%esp
  8014be:	68 00 50 80 00       	push   $0x805000
  8014c3:	53                   	push   %ebx
  8014c4:	e8 e5 f2 ff ff       	call   8007ae <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8014c9:	a1 80 50 80 00       	mov    0x805080,%eax
  8014ce:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8014d4:	a1 84 50 80 00       	mov    0x805084,%eax
  8014d9:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8014df:	83 c4 10             	add    $0x10,%esp
  8014e2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8014e7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014ea:	c9                   	leave  
  8014eb:	c3                   	ret    

008014ec <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8014ec:	55                   	push   %ebp
  8014ed:	89 e5                	mov    %esp,%ebp
  8014ef:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8014f2:	8b 45 08             	mov    0x8(%ebp),%eax
  8014f5:	8b 40 0c             	mov    0xc(%eax),%eax
  8014f8:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8014fd:	ba 00 00 00 00       	mov    $0x0,%edx
  801502:	b8 06 00 00 00       	mov    $0x6,%eax
  801507:	e8 3c ff ff ff       	call   801448 <fsipc>
}
  80150c:	c9                   	leave  
  80150d:	c3                   	ret    

0080150e <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  80150e:	55                   	push   %ebp
  80150f:	89 e5                	mov    %esp,%ebp
  801511:	56                   	push   %esi
  801512:	53                   	push   %ebx
  801513:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801516:	8b 45 08             	mov    0x8(%ebp),%eax
  801519:	8b 40 0c             	mov    0xc(%eax),%eax
  80151c:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801521:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801527:	ba 00 00 00 00       	mov    $0x0,%edx
  80152c:	b8 03 00 00 00       	mov    $0x3,%eax
  801531:	e8 12 ff ff ff       	call   801448 <fsipc>
  801536:	89 c3                	mov    %eax,%ebx
  801538:	85 c0                	test   %eax,%eax
  80153a:	78 4b                	js     801587 <devfile_read+0x79>
		return r;
	assert(r <= n);
  80153c:	39 c6                	cmp    %eax,%esi
  80153e:	73 16                	jae    801556 <devfile_read+0x48>
  801540:	68 8c 23 80 00       	push   $0x80238c
  801545:	68 93 23 80 00       	push   $0x802393
  80154a:	6a 7d                	push   $0x7d
  80154c:	68 a8 23 80 00       	push   $0x8023a8
  801551:	e8 ca eb ff ff       	call   800120 <_panic>
	assert(r <= PGSIZE);
  801556:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80155b:	7e 16                	jle    801573 <devfile_read+0x65>
  80155d:	68 b3 23 80 00       	push   $0x8023b3
  801562:	68 93 23 80 00       	push   $0x802393
  801567:	6a 7e                	push   $0x7e
  801569:	68 a8 23 80 00       	push   $0x8023a8
  80156e:	e8 ad eb ff ff       	call   800120 <_panic>
	memmove(buf, &fsipcbuf, r);
  801573:	83 ec 04             	sub    $0x4,%esp
  801576:	50                   	push   %eax
  801577:	68 00 50 80 00       	push   $0x805000
  80157c:	ff 75 0c             	pushl  0xc(%ebp)
  80157f:	e8 eb f3 ff ff       	call   80096f <memmove>
	return r;
  801584:	83 c4 10             	add    $0x10,%esp
}
  801587:	89 d8                	mov    %ebx,%eax
  801589:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80158c:	5b                   	pop    %ebx
  80158d:	5e                   	pop    %esi
  80158e:	c9                   	leave  
  80158f:	c3                   	ret    

00801590 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801590:	55                   	push   %ebp
  801591:	89 e5                	mov    %esp,%ebp
  801593:	56                   	push   %esi
  801594:	53                   	push   %ebx
  801595:	83 ec 1c             	sub    $0x1c,%esp
  801598:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  80159b:	56                   	push   %esi
  80159c:	e8 bb f1 ff ff       	call   80075c <strlen>
  8015a1:	83 c4 10             	add    $0x10,%esp
  8015a4:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8015a9:	7f 65                	jg     801610 <open+0x80>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8015ab:	83 ec 0c             	sub    $0xc,%esp
  8015ae:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015b1:	50                   	push   %eax
  8015b2:	e8 e1 f8 ff ff       	call   800e98 <fd_alloc>
  8015b7:	89 c3                	mov    %eax,%ebx
  8015b9:	83 c4 10             	add    $0x10,%esp
  8015bc:	85 c0                	test   %eax,%eax
  8015be:	78 55                	js     801615 <open+0x85>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8015c0:	83 ec 08             	sub    $0x8,%esp
  8015c3:	56                   	push   %esi
  8015c4:	68 00 50 80 00       	push   $0x805000
  8015c9:	e8 e0 f1 ff ff       	call   8007ae <strcpy>
	fsipcbuf.open.req_omode = mode;
  8015ce:	8b 45 0c             	mov    0xc(%ebp),%eax
  8015d1:	a3 00 54 80 00       	mov    %eax,0x805400



	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8015d6:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8015d9:	b8 01 00 00 00       	mov    $0x1,%eax
  8015de:	e8 65 fe ff ff       	call   801448 <fsipc>
  8015e3:	89 c3                	mov    %eax,%ebx
  8015e5:	83 c4 10             	add    $0x10,%esp
  8015e8:	85 c0                	test   %eax,%eax
  8015ea:	79 12                	jns    8015fe <open+0x6e>
		fd_close(fd, 0);
  8015ec:	83 ec 08             	sub    $0x8,%esp
  8015ef:	6a 00                	push   $0x0
  8015f1:	ff 75 f4             	pushl  -0xc(%ebp)
  8015f4:	e8 ce f9 ff ff       	call   800fc7 <fd_close>
		return r;
  8015f9:	83 c4 10             	add    $0x10,%esp
  8015fc:	eb 17                	jmp    801615 <open+0x85>
	}

	return fd2num(fd);
  8015fe:	83 ec 0c             	sub    $0xc,%esp
  801601:	ff 75 f4             	pushl  -0xc(%ebp)
  801604:	e8 67 f8 ff ff       	call   800e70 <fd2num>
  801609:	89 c3                	mov    %eax,%ebx
  80160b:	83 c4 10             	add    $0x10,%esp
  80160e:	eb 05                	jmp    801615 <open+0x85>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801610:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801615:	89 d8                	mov    %ebx,%eax
  801617:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80161a:	5b                   	pop    %ebx
  80161b:	5e                   	pop    %esi
  80161c:	c9                   	leave  
  80161d:	c3                   	ret    
	...

00801620 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801620:	55                   	push   %ebp
  801621:	89 e5                	mov    %esp,%ebp
  801623:	56                   	push   %esi
  801624:	53                   	push   %ebx
  801625:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801628:	83 ec 0c             	sub    $0xc,%esp
  80162b:	ff 75 08             	pushl  0x8(%ebp)
  80162e:	e8 4d f8 ff ff       	call   800e80 <fd2data>
  801633:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  801635:	83 c4 08             	add    $0x8,%esp
  801638:	68 bf 23 80 00       	push   $0x8023bf
  80163d:	56                   	push   %esi
  80163e:	e8 6b f1 ff ff       	call   8007ae <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801643:	8b 43 04             	mov    0x4(%ebx),%eax
  801646:	2b 03                	sub    (%ebx),%eax
  801648:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  80164e:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  801655:	00 00 00 
	stat->st_dev = &devpipe;
  801658:	c7 86 88 00 00 00 20 	movl   $0x803020,0x88(%esi)
  80165f:	30 80 00 
	return 0;
}
  801662:	b8 00 00 00 00       	mov    $0x0,%eax
  801667:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80166a:	5b                   	pop    %ebx
  80166b:	5e                   	pop    %esi
  80166c:	c9                   	leave  
  80166d:	c3                   	ret    

0080166e <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  80166e:	55                   	push   %ebp
  80166f:	89 e5                	mov    %esp,%ebp
  801671:	53                   	push   %ebx
  801672:	83 ec 0c             	sub    $0xc,%esp
  801675:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801678:	53                   	push   %ebx
  801679:	6a 00                	push   $0x0
  80167b:	e8 fa f5 ff ff       	call   800c7a <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801680:	89 1c 24             	mov    %ebx,(%esp)
  801683:	e8 f8 f7 ff ff       	call   800e80 <fd2data>
  801688:	83 c4 08             	add    $0x8,%esp
  80168b:	50                   	push   %eax
  80168c:	6a 00                	push   $0x0
  80168e:	e8 e7 f5 ff ff       	call   800c7a <sys_page_unmap>
}
  801693:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801696:	c9                   	leave  
  801697:	c3                   	ret    

00801698 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801698:	55                   	push   %ebp
  801699:	89 e5                	mov    %esp,%ebp
  80169b:	57                   	push   %edi
  80169c:	56                   	push   %esi
  80169d:	53                   	push   %ebx
  80169e:	83 ec 1c             	sub    $0x1c,%esp
  8016a1:	89 c7                	mov    %eax,%edi
  8016a3:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8016a6:	a1 04 40 80 00       	mov    0x804004,%eax
  8016ab:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  8016ae:	83 ec 0c             	sub    $0xc,%esp
  8016b1:	57                   	push   %edi
  8016b2:	e8 85 05 00 00       	call   801c3c <pageref>
  8016b7:	89 c6                	mov    %eax,%esi
  8016b9:	83 c4 04             	add    $0x4,%esp
  8016bc:	ff 75 e4             	pushl  -0x1c(%ebp)
  8016bf:	e8 78 05 00 00       	call   801c3c <pageref>
  8016c4:	83 c4 10             	add    $0x10,%esp
  8016c7:	39 c6                	cmp    %eax,%esi
  8016c9:	0f 94 c0             	sete   %al
  8016cc:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  8016cf:	8b 15 04 40 80 00    	mov    0x804004,%edx
  8016d5:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  8016d8:	39 cb                	cmp    %ecx,%ebx
  8016da:	75 08                	jne    8016e4 <_pipeisclosed+0x4c>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  8016dc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8016df:	5b                   	pop    %ebx
  8016e0:	5e                   	pop    %esi
  8016e1:	5f                   	pop    %edi
  8016e2:	c9                   	leave  
  8016e3:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  8016e4:	83 f8 01             	cmp    $0x1,%eax
  8016e7:	75 bd                	jne    8016a6 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8016e9:	8b 42 58             	mov    0x58(%edx),%eax
  8016ec:	6a 01                	push   $0x1
  8016ee:	50                   	push   %eax
  8016ef:	53                   	push   %ebx
  8016f0:	68 c6 23 80 00       	push   $0x8023c6
  8016f5:	e8 fe ea ff ff       	call   8001f8 <cprintf>
  8016fa:	83 c4 10             	add    $0x10,%esp
  8016fd:	eb a7                	jmp    8016a6 <_pipeisclosed+0xe>

008016ff <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8016ff:	55                   	push   %ebp
  801700:	89 e5                	mov    %esp,%ebp
  801702:	57                   	push   %edi
  801703:	56                   	push   %esi
  801704:	53                   	push   %ebx
  801705:	83 ec 28             	sub    $0x28,%esp
  801708:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  80170b:	56                   	push   %esi
  80170c:	e8 6f f7 ff ff       	call   800e80 <fd2data>
  801711:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801713:	83 c4 10             	add    $0x10,%esp
  801716:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80171a:	75 4a                	jne    801766 <devpipe_write+0x67>
  80171c:	bf 00 00 00 00       	mov    $0x0,%edi
  801721:	eb 56                	jmp    801779 <devpipe_write+0x7a>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801723:	89 da                	mov    %ebx,%edx
  801725:	89 f0                	mov    %esi,%eax
  801727:	e8 6c ff ff ff       	call   801698 <_pipeisclosed>
  80172c:	85 c0                	test   %eax,%eax
  80172e:	75 4d                	jne    80177d <devpipe_write+0x7e>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801730:	e8 d4 f4 ff ff       	call   800c09 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801735:	8b 43 04             	mov    0x4(%ebx),%eax
  801738:	8b 13                	mov    (%ebx),%edx
  80173a:	83 c2 20             	add    $0x20,%edx
  80173d:	39 d0                	cmp    %edx,%eax
  80173f:	73 e2                	jae    801723 <devpipe_write+0x24>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801741:	89 c2                	mov    %eax,%edx
  801743:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  801749:	79 05                	jns    801750 <devpipe_write+0x51>
  80174b:	4a                   	dec    %edx
  80174c:	83 ca e0             	or     $0xffffffe0,%edx
  80174f:	42                   	inc    %edx
  801750:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801753:	8a 0c 39             	mov    (%ecx,%edi,1),%cl
  801756:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  80175a:	40                   	inc    %eax
  80175b:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80175e:	47                   	inc    %edi
  80175f:	39 7d 10             	cmp    %edi,0x10(%ebp)
  801762:	77 07                	ja     80176b <devpipe_write+0x6c>
  801764:	eb 13                	jmp    801779 <devpipe_write+0x7a>
  801766:	bf 00 00 00 00       	mov    $0x0,%edi
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  80176b:	8b 43 04             	mov    0x4(%ebx),%eax
  80176e:	8b 13                	mov    (%ebx),%edx
  801770:	83 c2 20             	add    $0x20,%edx
  801773:	39 d0                	cmp    %edx,%eax
  801775:	73 ac                	jae    801723 <devpipe_write+0x24>
  801777:	eb c8                	jmp    801741 <devpipe_write+0x42>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801779:	89 f8                	mov    %edi,%eax
  80177b:	eb 05                	jmp    801782 <devpipe_write+0x83>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80177d:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801782:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801785:	5b                   	pop    %ebx
  801786:	5e                   	pop    %esi
  801787:	5f                   	pop    %edi
  801788:	c9                   	leave  
  801789:	c3                   	ret    

0080178a <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  80178a:	55                   	push   %ebp
  80178b:	89 e5                	mov    %esp,%ebp
  80178d:	57                   	push   %edi
  80178e:	56                   	push   %esi
  80178f:	53                   	push   %ebx
  801790:	83 ec 18             	sub    $0x18,%esp
  801793:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801796:	57                   	push   %edi
  801797:	e8 e4 f6 ff ff       	call   800e80 <fd2data>
  80179c:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80179e:	83 c4 10             	add    $0x10,%esp
  8017a1:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8017a5:	75 44                	jne    8017eb <devpipe_read+0x61>
  8017a7:	be 00 00 00 00       	mov    $0x0,%esi
  8017ac:	eb 4f                	jmp    8017fd <devpipe_read+0x73>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
				return i;
  8017ae:	89 f0                	mov    %esi,%eax
  8017b0:	eb 54                	jmp    801806 <devpipe_read+0x7c>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  8017b2:	89 da                	mov    %ebx,%edx
  8017b4:	89 f8                	mov    %edi,%eax
  8017b6:	e8 dd fe ff ff       	call   801698 <_pipeisclosed>
  8017bb:	85 c0                	test   %eax,%eax
  8017bd:	75 42                	jne    801801 <devpipe_read+0x77>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  8017bf:	e8 45 f4 ff ff       	call   800c09 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8017c4:	8b 03                	mov    (%ebx),%eax
  8017c6:	3b 43 04             	cmp    0x4(%ebx),%eax
  8017c9:	74 e7                	je     8017b2 <devpipe_read+0x28>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8017cb:	25 1f 00 00 80       	and    $0x8000001f,%eax
  8017d0:	79 05                	jns    8017d7 <devpipe_read+0x4d>
  8017d2:	48                   	dec    %eax
  8017d3:	83 c8 e0             	or     $0xffffffe0,%eax
  8017d6:	40                   	inc    %eax
  8017d7:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  8017db:	8b 55 0c             	mov    0xc(%ebp),%edx
  8017de:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  8017e1:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8017e3:	46                   	inc    %esi
  8017e4:	39 75 10             	cmp    %esi,0x10(%ebp)
  8017e7:	77 07                	ja     8017f0 <devpipe_read+0x66>
  8017e9:	eb 12                	jmp    8017fd <devpipe_read+0x73>
  8017eb:	be 00 00 00 00       	mov    $0x0,%esi
		while (p->p_rpos == p->p_wpos) {
  8017f0:	8b 03                	mov    (%ebx),%eax
  8017f2:	3b 43 04             	cmp    0x4(%ebx),%eax
  8017f5:	75 d4                	jne    8017cb <devpipe_read+0x41>
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  8017f7:	85 f6                	test   %esi,%esi
  8017f9:	75 b3                	jne    8017ae <devpipe_read+0x24>
  8017fb:	eb b5                	jmp    8017b2 <devpipe_read+0x28>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  8017fd:	89 f0                	mov    %esi,%eax
  8017ff:	eb 05                	jmp    801806 <devpipe_read+0x7c>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801801:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801806:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801809:	5b                   	pop    %ebx
  80180a:	5e                   	pop    %esi
  80180b:	5f                   	pop    %edi
  80180c:	c9                   	leave  
  80180d:	c3                   	ret    

0080180e <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  80180e:	55                   	push   %ebp
  80180f:	89 e5                	mov    %esp,%ebp
  801811:	57                   	push   %edi
  801812:	56                   	push   %esi
  801813:	53                   	push   %ebx
  801814:	83 ec 28             	sub    $0x28,%esp
  801817:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  80181a:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80181d:	50                   	push   %eax
  80181e:	e8 75 f6 ff ff       	call   800e98 <fd_alloc>
  801823:	89 c3                	mov    %eax,%ebx
  801825:	83 c4 10             	add    $0x10,%esp
  801828:	85 c0                	test   %eax,%eax
  80182a:	0f 88 24 01 00 00    	js     801954 <pipe+0x146>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801830:	83 ec 04             	sub    $0x4,%esp
  801833:	68 07 04 00 00       	push   $0x407
  801838:	ff 75 e4             	pushl  -0x1c(%ebp)
  80183b:	6a 00                	push   $0x0
  80183d:	e8 ee f3 ff ff       	call   800c30 <sys_page_alloc>
  801842:	89 c3                	mov    %eax,%ebx
  801844:	83 c4 10             	add    $0x10,%esp
  801847:	85 c0                	test   %eax,%eax
  801849:	0f 88 05 01 00 00    	js     801954 <pipe+0x146>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  80184f:	83 ec 0c             	sub    $0xc,%esp
  801852:	8d 45 e0             	lea    -0x20(%ebp),%eax
  801855:	50                   	push   %eax
  801856:	e8 3d f6 ff ff       	call   800e98 <fd_alloc>
  80185b:	89 c3                	mov    %eax,%ebx
  80185d:	83 c4 10             	add    $0x10,%esp
  801860:	85 c0                	test   %eax,%eax
  801862:	0f 88 dc 00 00 00    	js     801944 <pipe+0x136>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801868:	83 ec 04             	sub    $0x4,%esp
  80186b:	68 07 04 00 00       	push   $0x407
  801870:	ff 75 e0             	pushl  -0x20(%ebp)
  801873:	6a 00                	push   $0x0
  801875:	e8 b6 f3 ff ff       	call   800c30 <sys_page_alloc>
  80187a:	89 c3                	mov    %eax,%ebx
  80187c:	83 c4 10             	add    $0x10,%esp
  80187f:	85 c0                	test   %eax,%eax
  801881:	0f 88 bd 00 00 00    	js     801944 <pipe+0x136>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801887:	83 ec 0c             	sub    $0xc,%esp
  80188a:	ff 75 e4             	pushl  -0x1c(%ebp)
  80188d:	e8 ee f5 ff ff       	call   800e80 <fd2data>
  801892:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801894:	83 c4 0c             	add    $0xc,%esp
  801897:	68 07 04 00 00       	push   $0x407
  80189c:	50                   	push   %eax
  80189d:	6a 00                	push   $0x0
  80189f:	e8 8c f3 ff ff       	call   800c30 <sys_page_alloc>
  8018a4:	89 c3                	mov    %eax,%ebx
  8018a6:	83 c4 10             	add    $0x10,%esp
  8018a9:	85 c0                	test   %eax,%eax
  8018ab:	0f 88 83 00 00 00    	js     801934 <pipe+0x126>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8018b1:	83 ec 0c             	sub    $0xc,%esp
  8018b4:	ff 75 e0             	pushl  -0x20(%ebp)
  8018b7:	e8 c4 f5 ff ff       	call   800e80 <fd2data>
  8018bc:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  8018c3:	50                   	push   %eax
  8018c4:	6a 00                	push   $0x0
  8018c6:	56                   	push   %esi
  8018c7:	6a 00                	push   $0x0
  8018c9:	e8 86 f3 ff ff       	call   800c54 <sys_page_map>
  8018ce:	89 c3                	mov    %eax,%ebx
  8018d0:	83 c4 20             	add    $0x20,%esp
  8018d3:	85 c0                	test   %eax,%eax
  8018d5:	78 4f                	js     801926 <pipe+0x118>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  8018d7:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8018dd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8018e0:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8018e2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8018e5:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8018ec:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8018f2:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8018f5:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8018f7:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8018fa:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801901:	83 ec 0c             	sub    $0xc,%esp
  801904:	ff 75 e4             	pushl  -0x1c(%ebp)
  801907:	e8 64 f5 ff ff       	call   800e70 <fd2num>
  80190c:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  80190e:	83 c4 04             	add    $0x4,%esp
  801911:	ff 75 e0             	pushl  -0x20(%ebp)
  801914:	e8 57 f5 ff ff       	call   800e70 <fd2num>
  801919:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  80191c:	83 c4 10             	add    $0x10,%esp
  80191f:	bb 00 00 00 00       	mov    $0x0,%ebx
  801924:	eb 2e                	jmp    801954 <pipe+0x146>

    err3:
	sys_page_unmap(0, va);
  801926:	83 ec 08             	sub    $0x8,%esp
  801929:	56                   	push   %esi
  80192a:	6a 00                	push   $0x0
  80192c:	e8 49 f3 ff ff       	call   800c7a <sys_page_unmap>
  801931:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801934:	83 ec 08             	sub    $0x8,%esp
  801937:	ff 75 e0             	pushl  -0x20(%ebp)
  80193a:	6a 00                	push   $0x0
  80193c:	e8 39 f3 ff ff       	call   800c7a <sys_page_unmap>
  801941:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801944:	83 ec 08             	sub    $0x8,%esp
  801947:	ff 75 e4             	pushl  -0x1c(%ebp)
  80194a:	6a 00                	push   $0x0
  80194c:	e8 29 f3 ff ff       	call   800c7a <sys_page_unmap>
  801951:	83 c4 10             	add    $0x10,%esp
    err:
	return r;
}
  801954:	89 d8                	mov    %ebx,%eax
  801956:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801959:	5b                   	pop    %ebx
  80195a:	5e                   	pop    %esi
  80195b:	5f                   	pop    %edi
  80195c:	c9                   	leave  
  80195d:	c3                   	ret    

0080195e <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  80195e:	55                   	push   %ebp
  80195f:	89 e5                	mov    %esp,%ebp
  801961:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801964:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801967:	50                   	push   %eax
  801968:	ff 75 08             	pushl  0x8(%ebp)
  80196b:	e8 9b f5 ff ff       	call   800f0b <fd_lookup>
  801970:	83 c4 10             	add    $0x10,%esp
  801973:	85 c0                	test   %eax,%eax
  801975:	78 18                	js     80198f <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801977:	83 ec 0c             	sub    $0xc,%esp
  80197a:	ff 75 f4             	pushl  -0xc(%ebp)
  80197d:	e8 fe f4 ff ff       	call   800e80 <fd2data>
	return _pipeisclosed(fd, p);
  801982:	89 c2                	mov    %eax,%edx
  801984:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801987:	e8 0c fd ff ff       	call   801698 <_pipeisclosed>
  80198c:	83 c4 10             	add    $0x10,%esp
}
  80198f:	c9                   	leave  
  801990:	c3                   	ret    
  801991:	00 00                	add    %al,(%eax)
	...

00801994 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801994:	55                   	push   %ebp
  801995:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801997:	b8 00 00 00 00       	mov    $0x0,%eax
  80199c:	c9                   	leave  
  80199d:	c3                   	ret    

0080199e <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80199e:	55                   	push   %ebp
  80199f:	89 e5                	mov    %esp,%ebp
  8019a1:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  8019a4:	68 de 23 80 00       	push   $0x8023de
  8019a9:	ff 75 0c             	pushl  0xc(%ebp)
  8019ac:	e8 fd ed ff ff       	call   8007ae <strcpy>
	return 0;
}
  8019b1:	b8 00 00 00 00       	mov    $0x0,%eax
  8019b6:	c9                   	leave  
  8019b7:	c3                   	ret    

008019b8 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8019b8:	55                   	push   %ebp
  8019b9:	89 e5                	mov    %esp,%ebp
  8019bb:	57                   	push   %edi
  8019bc:	56                   	push   %esi
  8019bd:	53                   	push   %ebx
  8019be:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8019c4:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8019c8:	74 45                	je     801a0f <devcons_write+0x57>
  8019ca:	b8 00 00 00 00       	mov    $0x0,%eax
  8019cf:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8019d4:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  8019da:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8019dd:	29 c3                	sub    %eax,%ebx
		if (m > sizeof(buf) - 1)
  8019df:	83 fb 7f             	cmp    $0x7f,%ebx
  8019e2:	76 05                	jbe    8019e9 <devcons_write+0x31>
			m = sizeof(buf) - 1;
  8019e4:	bb 7f 00 00 00       	mov    $0x7f,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  8019e9:	83 ec 04             	sub    $0x4,%esp
  8019ec:	53                   	push   %ebx
  8019ed:	03 45 0c             	add    0xc(%ebp),%eax
  8019f0:	50                   	push   %eax
  8019f1:	57                   	push   %edi
  8019f2:	e8 78 ef ff ff       	call   80096f <memmove>
		sys_cputs(buf, m);
  8019f7:	83 c4 08             	add    $0x8,%esp
  8019fa:	53                   	push   %ebx
  8019fb:	57                   	push   %edi
  8019fc:	e8 78 f1 ff ff       	call   800b79 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801a01:	01 de                	add    %ebx,%esi
  801a03:	89 f0                	mov    %esi,%eax
  801a05:	83 c4 10             	add    $0x10,%esp
  801a08:	3b 75 10             	cmp    0x10(%ebp),%esi
  801a0b:	72 cd                	jb     8019da <devcons_write+0x22>
  801a0d:	eb 05                	jmp    801a14 <devcons_write+0x5c>
  801a0f:	be 00 00 00 00       	mov    $0x0,%esi
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801a14:	89 f0                	mov    %esi,%eax
  801a16:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a19:	5b                   	pop    %ebx
  801a1a:	5e                   	pop    %esi
  801a1b:	5f                   	pop    %edi
  801a1c:	c9                   	leave  
  801a1d:	c3                   	ret    

00801a1e <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801a1e:	55                   	push   %ebp
  801a1f:	89 e5                	mov    %esp,%ebp
  801a21:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  801a24:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801a28:	75 07                	jne    801a31 <devcons_read+0x13>
  801a2a:	eb 25                	jmp    801a51 <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801a2c:	e8 d8 f1 ff ff       	call   800c09 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801a31:	e8 69 f1 ff ff       	call   800b9f <sys_cgetc>
  801a36:	85 c0                	test   %eax,%eax
  801a38:	74 f2                	je     801a2c <devcons_read+0xe>
  801a3a:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  801a3c:	85 c0                	test   %eax,%eax
  801a3e:	78 1d                	js     801a5d <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801a40:	83 f8 04             	cmp    $0x4,%eax
  801a43:	74 13                	je     801a58 <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  801a45:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a48:	88 10                	mov    %dl,(%eax)
	return 1;
  801a4a:	b8 01 00 00 00       	mov    $0x1,%eax
  801a4f:	eb 0c                	jmp    801a5d <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  801a51:	b8 00 00 00 00       	mov    $0x0,%eax
  801a56:	eb 05                	jmp    801a5d <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801a58:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801a5d:	c9                   	leave  
  801a5e:	c3                   	ret    

00801a5f <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801a5f:	55                   	push   %ebp
  801a60:	89 e5                	mov    %esp,%ebp
  801a62:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801a65:	8b 45 08             	mov    0x8(%ebp),%eax
  801a68:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801a6b:	6a 01                	push   $0x1
  801a6d:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801a70:	50                   	push   %eax
  801a71:	e8 03 f1 ff ff       	call   800b79 <sys_cputs>
  801a76:	83 c4 10             	add    $0x10,%esp
}
  801a79:	c9                   	leave  
  801a7a:	c3                   	ret    

00801a7b <getchar>:

int
getchar(void)
{
  801a7b:	55                   	push   %ebp
  801a7c:	89 e5                	mov    %esp,%ebp
  801a7e:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801a81:	6a 01                	push   $0x1
  801a83:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801a86:	50                   	push   %eax
  801a87:	6a 00                	push   $0x0
  801a89:	e8 fe f6 ff ff       	call   80118c <read>
	if (r < 0)
  801a8e:	83 c4 10             	add    $0x10,%esp
  801a91:	85 c0                	test   %eax,%eax
  801a93:	78 0f                	js     801aa4 <getchar+0x29>
		return r;
	if (r < 1)
  801a95:	85 c0                	test   %eax,%eax
  801a97:	7e 06                	jle    801a9f <getchar+0x24>
		return -E_EOF;
	return c;
  801a99:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801a9d:	eb 05                	jmp    801aa4 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801a9f:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801aa4:	c9                   	leave  
  801aa5:	c3                   	ret    

00801aa6 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801aa6:	55                   	push   %ebp
  801aa7:	89 e5                	mov    %esp,%ebp
  801aa9:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801aac:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801aaf:	50                   	push   %eax
  801ab0:	ff 75 08             	pushl  0x8(%ebp)
  801ab3:	e8 53 f4 ff ff       	call   800f0b <fd_lookup>
  801ab8:	83 c4 10             	add    $0x10,%esp
  801abb:	85 c0                	test   %eax,%eax
  801abd:	78 11                	js     801ad0 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801abf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ac2:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801ac8:	39 10                	cmp    %edx,(%eax)
  801aca:	0f 94 c0             	sete   %al
  801acd:	0f b6 c0             	movzbl %al,%eax
}
  801ad0:	c9                   	leave  
  801ad1:	c3                   	ret    

00801ad2 <opencons>:

int
opencons(void)
{
  801ad2:	55                   	push   %ebp
  801ad3:	89 e5                	mov    %esp,%ebp
  801ad5:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801ad8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801adb:	50                   	push   %eax
  801adc:	e8 b7 f3 ff ff       	call   800e98 <fd_alloc>
  801ae1:	83 c4 10             	add    $0x10,%esp
  801ae4:	85 c0                	test   %eax,%eax
  801ae6:	78 3a                	js     801b22 <opencons+0x50>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801ae8:	83 ec 04             	sub    $0x4,%esp
  801aeb:	68 07 04 00 00       	push   $0x407
  801af0:	ff 75 f4             	pushl  -0xc(%ebp)
  801af3:	6a 00                	push   $0x0
  801af5:	e8 36 f1 ff ff       	call   800c30 <sys_page_alloc>
  801afa:	83 c4 10             	add    $0x10,%esp
  801afd:	85 c0                	test   %eax,%eax
  801aff:	78 21                	js     801b22 <opencons+0x50>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801b01:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801b07:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b0a:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801b0c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b0f:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801b16:	83 ec 0c             	sub    $0xc,%esp
  801b19:	50                   	push   %eax
  801b1a:	e8 51 f3 ff ff       	call   800e70 <fd2num>
  801b1f:	83 c4 10             	add    $0x10,%esp
}
  801b22:	c9                   	leave  
  801b23:	c3                   	ret    

00801b24 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801b24:	55                   	push   %ebp
  801b25:	89 e5                	mov    %esp,%ebp
  801b27:	56                   	push   %esi
  801b28:	53                   	push   %ebx
  801b29:	8b 75 08             	mov    0x8(%ebp),%esi
  801b2c:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b2f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// cprintf("0x%x 0x%x 0x%x\n", (uint32_t)from_env_store, (uint32_t)pg, (uint32_t)perm_store);
	int r;
	if (pg != NULL) {
  801b32:	85 c0                	test   %eax,%eax
  801b34:	74 0e                	je     801b44 <ipc_recv+0x20>
		r = sys_ipc_recv(pg);
  801b36:	83 ec 0c             	sub    $0xc,%esp
  801b39:	50                   	push   %eax
  801b3a:	e8 ec f1 ff ff       	call   800d2b <sys_ipc_recv>
  801b3f:	83 c4 10             	add    $0x10,%esp
  801b42:	eb 10                	jmp    801b54 <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv((void *)UTOP);
  801b44:	83 ec 0c             	sub    $0xc,%esp
  801b47:	68 00 00 c0 ee       	push   $0xeec00000
  801b4c:	e8 da f1 ff ff       	call   800d2b <sys_ipc_recv>
  801b51:	83 c4 10             	add    $0x10,%esp
	}

	if (r == 0) {
  801b54:	85 c0                	test   %eax,%eax
  801b56:	75 26                	jne    801b7e <ipc_recv+0x5a>
		if (from_env_store != NULL) *from_env_store = thisenv->env_ipc_from;
  801b58:	85 f6                	test   %esi,%esi
  801b5a:	74 0a                	je     801b66 <ipc_recv+0x42>
  801b5c:	a1 04 40 80 00       	mov    0x804004,%eax
  801b61:	8b 40 74             	mov    0x74(%eax),%eax
  801b64:	89 06                	mov    %eax,(%esi)
		if (perm_store != NULL) *perm_store = thisenv->env_ipc_perm;
  801b66:	85 db                	test   %ebx,%ebx
  801b68:	74 0a                	je     801b74 <ipc_recv+0x50>
  801b6a:	a1 04 40 80 00       	mov    0x804004,%eax
  801b6f:	8b 40 78             	mov    0x78(%eax),%eax
  801b72:	89 03                	mov    %eax,(%ebx)
		return thisenv->env_ipc_value;
  801b74:	a1 04 40 80 00       	mov    0x804004,%eax
  801b79:	8b 40 70             	mov    0x70(%eax),%eax
  801b7c:	eb 14                	jmp    801b92 <ipc_recv+0x6e>
	} else {
		// fails;
		if (from_env_store != NULL) *from_env_store = 0;
  801b7e:	85 f6                	test   %esi,%esi
  801b80:	74 06                	je     801b88 <ipc_recv+0x64>
  801b82:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if (perm_store != NULL) *perm_store = 0;
  801b88:	85 db                	test   %ebx,%ebx
  801b8a:	74 06                	je     801b92 <ipc_recv+0x6e>
  801b8c:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		return r;
	}
}
  801b92:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b95:	5b                   	pop    %ebx
  801b96:	5e                   	pop    %esi
  801b97:	c9                   	leave  
  801b98:	c3                   	ret    

00801b99 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801b99:	55                   	push   %ebp
  801b9a:	89 e5                	mov    %esp,%ebp
  801b9c:	57                   	push   %edi
  801b9d:	56                   	push   %esi
  801b9e:	53                   	push   %ebx
  801b9f:	83 ec 0c             	sub    $0xc,%esp
  801ba2:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801ba5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801ba8:	8b 75 14             	mov    0x14(%ebp),%esi
	// LAB 4: Your code here.
	// int sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
	int r;
	if (pg == NULL) pg = (void *)UTOP;
  801bab:	85 db                	test   %ebx,%ebx
  801bad:	75 25                	jne    801bd4 <ipc_send+0x3b>
  801baf:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
  801bb4:	eb 1e                	jmp    801bd4 <ipc_send+0x3b>
	
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) != 0) {
		if (r == -E_IPC_NOT_RECV) {
  801bb6:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801bb9:	75 07                	jne    801bc2 <ipc_send+0x29>
			// cprintf("Try Again and Again....\n");
			sys_yield();
  801bbb:	e8 49 f0 ff ff       	call   800c09 <sys_yield>
  801bc0:	eb 12                	jmp    801bd4 <ipc_send+0x3b>
		} else {
			panic("ipc_send error %e\n", r);
  801bc2:	50                   	push   %eax
  801bc3:	68 ea 23 80 00       	push   $0x8023ea
  801bc8:	6a 43                	push   $0x43
  801bca:	68 fd 23 80 00       	push   $0x8023fd
  801bcf:	e8 4c e5 ff ff       	call   800120 <_panic>
	// LAB 4: Your code here.
	// int sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
	int r;
	if (pg == NULL) pg = (void *)UTOP;
	
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) != 0) {
  801bd4:	56                   	push   %esi
  801bd5:	53                   	push   %ebx
  801bd6:	57                   	push   %edi
  801bd7:	ff 75 08             	pushl  0x8(%ebp)
  801bda:	e8 27 f1 ff ff       	call   800d06 <sys_ipc_try_send>
  801bdf:	83 c4 10             	add    $0x10,%esp
  801be2:	85 c0                	test   %eax,%eax
  801be4:	75 d0                	jne    801bb6 <ipc_send+0x1d>
		} else {
			panic("ipc_send error %e\n", r);
		}
	}
	return;
}
  801be6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801be9:	5b                   	pop    %ebx
  801bea:	5e                   	pop    %esi
  801beb:	5f                   	pop    %edi
  801bec:	c9                   	leave  
  801bed:	c3                   	ret    

00801bee <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801bee:	55                   	push   %ebp
  801bef:	89 e5                	mov    %esp,%ebp
  801bf1:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  801bf4:	39 0d 50 00 c0 ee    	cmp    %ecx,0xeec00050
  801bfa:	74 1a                	je     801c16 <ipc_find_env+0x28>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801bfc:	b8 01 00 00 00       	mov    $0x1,%eax
		if (envs[i].env_type == type)
  801c01:	89 c2                	mov    %eax,%edx
  801c03:	c1 e2 07             	shl    $0x7,%edx
  801c06:	8d 94 82 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,4),%edx
  801c0d:	8b 52 50             	mov    0x50(%edx),%edx
  801c10:	39 ca                	cmp    %ecx,%edx
  801c12:	75 18                	jne    801c2c <ipc_find_env+0x3e>
  801c14:	eb 05                	jmp    801c1b <ipc_find_env+0x2d>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801c16:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
			return envs[i].env_id;
  801c1b:	89 c2                	mov    %eax,%edx
  801c1d:	c1 e2 07             	shl    $0x7,%edx
  801c20:	8d 84 82 08 00 c0 ee 	lea    -0x113ffff8(%edx,%eax,4),%eax
  801c27:	8b 40 40             	mov    0x40(%eax),%eax
  801c2a:	eb 0c                	jmp    801c38 <ipc_find_env+0x4a>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801c2c:	40                   	inc    %eax
  801c2d:	3d 00 04 00 00       	cmp    $0x400,%eax
  801c32:	75 cd                	jne    801c01 <ipc_find_env+0x13>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801c34:	66 b8 00 00          	mov    $0x0,%ax
}
  801c38:	c9                   	leave  
  801c39:	c3                   	ret    
	...

00801c3c <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801c3c:	55                   	push   %ebp
  801c3d:	89 e5                	mov    %esp,%ebp
  801c3f:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801c42:	89 c2                	mov    %eax,%edx
  801c44:	c1 ea 16             	shr    $0x16,%edx
  801c47:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801c4e:	f6 c2 01             	test   $0x1,%dl
  801c51:	74 1e                	je     801c71 <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  801c53:	c1 e8 0c             	shr    $0xc,%eax
  801c56:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801c5d:	a8 01                	test   $0x1,%al
  801c5f:	74 17                	je     801c78 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801c61:	c1 e8 0c             	shr    $0xc,%eax
  801c64:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  801c6b:	ef 
  801c6c:	0f b7 c0             	movzwl %ax,%eax
  801c6f:	eb 0c                	jmp    801c7d <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  801c71:	b8 00 00 00 00       	mov    $0x0,%eax
  801c76:	eb 05                	jmp    801c7d <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  801c78:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  801c7d:	c9                   	leave  
  801c7e:	c3                   	ret    
	...

00801c80 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  801c80:	55                   	push   %ebp
  801c81:	89 e5                	mov    %esp,%ebp
  801c83:	57                   	push   %edi
  801c84:	56                   	push   %esi
  801c85:	83 ec 10             	sub    $0x10,%esp
  801c88:	8b 7d 08             	mov    0x8(%ebp),%edi
  801c8b:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  801c8e:	89 7d f0             	mov    %edi,-0x10(%ebp)
  801c91:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  801c94:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  801c97:	8b 45 14             	mov    0x14(%ebp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  801c9a:	85 c0                	test   %eax,%eax
  801c9c:	75 2e                	jne    801ccc <__udivdi3+0x4c>
    {
      if (d0 > n1)
  801c9e:	39 f1                	cmp    %esi,%ecx
  801ca0:	77 5a                	ja     801cfc <__udivdi3+0x7c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  801ca2:	85 c9                	test   %ecx,%ecx
  801ca4:	75 0b                	jne    801cb1 <__udivdi3+0x31>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  801ca6:	b8 01 00 00 00       	mov    $0x1,%eax
  801cab:	31 d2                	xor    %edx,%edx
  801cad:	f7 f1                	div    %ecx
  801caf:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  801cb1:	31 d2                	xor    %edx,%edx
  801cb3:	89 f0                	mov    %esi,%eax
  801cb5:	f7 f1                	div    %ecx
  801cb7:	89 c6                	mov    %eax,%esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801cb9:	89 f8                	mov    %edi,%eax
  801cbb:	f7 f1                	div    %ecx
  801cbd:	89 c7                	mov    %eax,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801cbf:	89 f8                	mov    %edi,%eax
  801cc1:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801cc3:	83 c4 10             	add    $0x10,%esp
  801cc6:	5e                   	pop    %esi
  801cc7:	5f                   	pop    %edi
  801cc8:	c9                   	leave  
  801cc9:	c3                   	ret    
  801cca:	66 90                	xchg   %ax,%ax
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801ccc:	39 f0                	cmp    %esi,%eax
  801cce:	77 1c                	ja     801cec <__udivdi3+0x6c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  801cd0:	0f bd f8             	bsr    %eax,%edi
	  if (bm == 0)
  801cd3:	83 f7 1f             	xor    $0x1f,%edi
  801cd6:	75 3c                	jne    801d14 <__udivdi3+0x94>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801cd8:	39 f0                	cmp    %esi,%eax
  801cda:	0f 82 90 00 00 00    	jb     801d70 <__udivdi3+0xf0>
  801ce0:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801ce3:	39 55 f4             	cmp    %edx,-0xc(%ebp)
  801ce6:	0f 86 84 00 00 00    	jbe    801d70 <__udivdi3+0xf0>
  801cec:	31 f6                	xor    %esi,%esi
  801cee:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801cf0:	89 f8                	mov    %edi,%eax
  801cf2:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801cf4:	83 c4 10             	add    $0x10,%esp
  801cf7:	5e                   	pop    %esi
  801cf8:	5f                   	pop    %edi
  801cf9:	c9                   	leave  
  801cfa:	c3                   	ret    
  801cfb:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801cfc:	89 f2                	mov    %esi,%edx
  801cfe:	89 f8                	mov    %edi,%eax
  801d00:	f7 f1                	div    %ecx
  801d02:	89 c7                	mov    %eax,%edi
  801d04:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801d06:	89 f8                	mov    %edi,%eax
  801d08:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801d0a:	83 c4 10             	add    $0x10,%esp
  801d0d:	5e                   	pop    %esi
  801d0e:	5f                   	pop    %edi
  801d0f:	c9                   	leave  
  801d10:	c3                   	ret    
  801d11:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  801d14:	89 f9                	mov    %edi,%ecx
  801d16:	d3 e0                	shl    %cl,%eax
  801d18:	89 45 e8             	mov    %eax,-0x18(%ebp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  801d1b:	b8 20 00 00 00       	mov    $0x20,%eax
  801d20:	29 f8                	sub    %edi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  801d22:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801d25:	88 c1                	mov    %al,%cl
  801d27:	d3 ea                	shr    %cl,%edx
  801d29:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  801d2c:	09 ca                	or     %ecx,%edx
  801d2e:	89 55 ec             	mov    %edx,-0x14(%ebp)
	      d0 = d0 << bm;
  801d31:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801d34:	89 f9                	mov    %edi,%ecx
  801d36:	d3 e2                	shl    %cl,%edx
  801d38:	89 55 f4             	mov    %edx,-0xc(%ebp)
	      n2 = n1 >> b;
  801d3b:	89 f2                	mov    %esi,%edx
  801d3d:	88 c1                	mov    %al,%cl
  801d3f:	d3 ea                	shr    %cl,%edx
  801d41:	89 55 e8             	mov    %edx,-0x18(%ebp)
	      n1 = (n1 << bm) | (n0 >> b);
  801d44:	89 f2                	mov    %esi,%edx
  801d46:	89 f9                	mov    %edi,%ecx
  801d48:	d3 e2                	shl    %cl,%edx
  801d4a:	8b 75 f0             	mov    -0x10(%ebp),%esi
  801d4d:	88 c1                	mov    %al,%cl
  801d4f:	d3 ee                	shr    %cl,%esi
  801d51:	09 d6                	or     %edx,%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  801d53:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  801d56:	89 f0                	mov    %esi,%eax
  801d58:	89 ca                	mov    %ecx,%edx
  801d5a:	f7 75 ec             	divl   -0x14(%ebp)
  801d5d:	89 d1                	mov    %edx,%ecx
  801d5f:	89 c6                	mov    %eax,%esi
	      umul_ppmm (m1, m0, q0, d0);
  801d61:	f7 65 f4             	mull   -0xc(%ebp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801d64:	39 d1                	cmp    %edx,%ecx
  801d66:	72 28                	jb     801d90 <__udivdi3+0x110>
  801d68:	74 1a                	je     801d84 <__udivdi3+0x104>
  801d6a:	89 f7                	mov    %esi,%edi
  801d6c:	31 f6                	xor    %esi,%esi
  801d6e:	eb 80                	jmp    801cf0 <__udivdi3+0x70>
	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  801d70:	31 f6                	xor    %esi,%esi
  801d72:	bf 01 00 00 00       	mov    $0x1,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801d77:	89 f8                	mov    %edi,%eax
  801d79:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801d7b:	83 c4 10             	add    $0x10,%esp
  801d7e:	5e                   	pop    %esi
  801d7f:	5f                   	pop    %edi
  801d80:	c9                   	leave  
  801d81:	c3                   	ret    
  801d82:	66 90                	xchg   %ax,%ax

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  801d84:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801d87:	89 f9                	mov    %edi,%ecx
  801d89:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801d8b:	39 c2                	cmp    %eax,%edx
  801d8d:	73 db                	jae    801d6a <__udivdi3+0xea>
  801d8f:	90                   	nop
		{
		  q0--;
  801d90:	8d 7e ff             	lea    -0x1(%esi),%edi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  801d93:	31 f6                	xor    %esi,%esi
  801d95:	e9 56 ff ff ff       	jmp    801cf0 <__udivdi3+0x70>
	...

00801d9c <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  801d9c:	55                   	push   %ebp
  801d9d:	89 e5                	mov    %esp,%ebp
  801d9f:	57                   	push   %edi
  801da0:	56                   	push   %esi
  801da1:	83 ec 20             	sub    $0x20,%esp
  801da4:	8b 45 08             	mov    0x8(%ebp),%eax
  801da7:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  801daa:	89 45 e8             	mov    %eax,-0x18(%ebp)
  801dad:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  801db0:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  801db3:	8b 7d 14             	mov    0x14(%ebp),%edi
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  801db6:	89 45 f0             	mov    %eax,-0x10(%ebp)
  n1 = nn.s.high;
  801db9:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  801dbb:	85 ff                	test   %edi,%edi
  801dbd:	75 15                	jne    801dd4 <__umoddi3+0x38>
    {
      if (d0 > n1)
  801dbf:	39 f1                	cmp    %esi,%ecx
  801dc1:	0f 86 99 00 00 00    	jbe    801e60 <__umoddi3+0xc4>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801dc7:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  801dc9:	89 d0                	mov    %edx,%eax
  801dcb:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801dcd:	83 c4 20             	add    $0x20,%esp
  801dd0:	5e                   	pop    %esi
  801dd1:	5f                   	pop    %edi
  801dd2:	c9                   	leave  
  801dd3:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801dd4:	39 f7                	cmp    %esi,%edi
  801dd6:	0f 87 a4 00 00 00    	ja     801e80 <__umoddi3+0xe4>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  801ddc:	0f bd c7             	bsr    %edi,%eax
	  if (bm == 0)
  801ddf:	83 f0 1f             	xor    $0x1f,%eax
  801de2:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801de5:	0f 84 a1 00 00 00    	je     801e8c <__umoddi3+0xf0>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  801deb:	89 f8                	mov    %edi,%eax
  801ded:	8a 4d ec             	mov    -0x14(%ebp),%cl
  801df0:	d3 e0                	shl    %cl,%eax
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  801df2:	bf 20 00 00 00       	mov    $0x20,%edi
  801df7:	2b 7d ec             	sub    -0x14(%ebp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  801dfa:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801dfd:	89 f9                	mov    %edi,%ecx
  801dff:	d3 ea                	shr    %cl,%edx
  801e01:	09 c2                	or     %eax,%edx
  801e03:	89 55 f0             	mov    %edx,-0x10(%ebp)
	      d0 = d0 << bm;
  801e06:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e09:	8a 4d ec             	mov    -0x14(%ebp),%cl
  801e0c:	d3 e0                	shl    %cl,%eax
  801e0e:	89 45 f4             	mov    %eax,-0xc(%ebp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  801e11:	89 f2                	mov    %esi,%edx
  801e13:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  801e15:	8b 45 e8             	mov    -0x18(%ebp),%eax
  801e18:	d3 e0                	shl    %cl,%eax
  801e1a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  801e1d:	8b 45 e8             	mov    -0x18(%ebp),%eax
  801e20:	89 f9                	mov    %edi,%ecx
  801e22:	d3 e8                	shr    %cl,%eax
  801e24:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  801e26:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  801e28:	89 f2                	mov    %esi,%edx
  801e2a:	f7 75 f0             	divl   -0x10(%ebp)
  801e2d:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  801e2f:	f7 65 f4             	mull   -0xc(%ebp)
  801e32:	89 55 e8             	mov    %edx,-0x18(%ebp)
  801e35:	89 c1                	mov    %eax,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801e37:	39 d6                	cmp    %edx,%esi
  801e39:	72 71                	jb     801eac <__umoddi3+0x110>
  801e3b:	74 7f                	je     801ebc <__umoddi3+0x120>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  801e3d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801e40:	29 c8                	sub    %ecx,%eax
  801e42:	19 d6                	sbb    %edx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  801e44:	8a 4d ec             	mov    -0x14(%ebp),%cl
  801e47:	d3 e8                	shr    %cl,%eax
  801e49:	89 f2                	mov    %esi,%edx
  801e4b:	89 f9                	mov    %edi,%ecx
  801e4d:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  801e4f:	09 d0                	or     %edx,%eax
  801e51:	89 f2                	mov    %esi,%edx
  801e53:	8a 4d ec             	mov    -0x14(%ebp),%cl
  801e56:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801e58:	83 c4 20             	add    $0x20,%esp
  801e5b:	5e                   	pop    %esi
  801e5c:	5f                   	pop    %edi
  801e5d:	c9                   	leave  
  801e5e:	c3                   	ret    
  801e5f:	90                   	nop
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  801e60:	85 c9                	test   %ecx,%ecx
  801e62:	75 0b                	jne    801e6f <__umoddi3+0xd3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  801e64:	b8 01 00 00 00       	mov    $0x1,%eax
  801e69:	31 d2                	xor    %edx,%edx
  801e6b:	f7 f1                	div    %ecx
  801e6d:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  801e6f:	89 f0                	mov    %esi,%eax
  801e71:	31 d2                	xor    %edx,%edx
  801e73:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801e75:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801e78:	f7 f1                	div    %ecx
  801e7a:	e9 4a ff ff ff       	jmp    801dc9 <__umoddi3+0x2d>
  801e7f:	90                   	nop
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  801e80:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801e82:	83 c4 20             	add    $0x20,%esp
  801e85:	5e                   	pop    %esi
  801e86:	5f                   	pop    %edi
  801e87:	c9                   	leave  
  801e88:	c3                   	ret    
  801e89:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801e8c:	39 f7                	cmp    %esi,%edi
  801e8e:	72 05                	jb     801e95 <__umoddi3+0xf9>
  801e90:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
  801e93:	77 0c                	ja     801ea1 <__umoddi3+0x105>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  801e95:	89 f2                	mov    %esi,%edx
  801e97:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801e9a:	29 c8                	sub    %ecx,%eax
  801e9c:	19 fa                	sbb    %edi,%edx
  801e9e:	89 45 f0             	mov    %eax,-0x10(%ebp)

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  801ea1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801ea4:	83 c4 20             	add    $0x20,%esp
  801ea7:	5e                   	pop    %esi
  801ea8:	5f                   	pop    %edi
  801ea9:	c9                   	leave  
  801eaa:	c3                   	ret    
  801eab:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  801eac:	8b 55 e8             	mov    -0x18(%ebp),%edx
  801eaf:	89 c1                	mov    %eax,%ecx
  801eb1:	2b 4d f4             	sub    -0xc(%ebp),%ecx
  801eb4:	1b 55 f0             	sbb    -0x10(%ebp),%edx
  801eb7:	eb 84                	jmp    801e3d <__umoddi3+0xa1>
  801eb9:	8d 76 00             	lea    0x0(%esi),%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801ebc:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801ebf:	72 eb                	jb     801eac <__umoddi3+0x110>
  801ec1:	89 f2                	mov    %esi,%edx
  801ec3:	e9 75 ff ff ff       	jmp    801e3d <__umoddi3+0xa1>
