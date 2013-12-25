
obj/user/pingpong.debug:     file format elf32-i386


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
  80002c:	e8 8f 00 00 00       	call   8000c0 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	57                   	push   %edi
  800038:	56                   	push   %esi
  800039:	53                   	push   %ebx
  80003a:	83 ec 1c             	sub    $0x1c,%esp
	envid_t who;

	if ((who = fork()) != 0) {
  80003d:	e8 2c 0e 00 00       	call   800e6e <fork>
  800042:	89 c3                	mov    %eax,%ebx
  800044:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800047:	85 c0                	test   %eax,%eax
  800049:	74 25                	je     800070 <umain+0x3c>
		// get the ball rolling
		cprintf("send 0 from %x to %x\n", sys_getenvid(), who);
  80004b:	e8 55 0b 00 00       	call   800ba5 <sys_getenvid>
  800050:	83 ec 04             	sub    $0x4,%esp
  800053:	53                   	push   %ebx
  800054:	50                   	push   %eax
  800055:	68 00 22 80 00       	push   $0x802200
  80005a:	e8 59 01 00 00       	call   8001b8 <cprintf>
		ipc_send(who, 0, 0, 0);
  80005f:	6a 00                	push   $0x0
  800061:	6a 00                	push   $0x0
  800063:	6a 00                	push   $0x0
  800065:	ff 75 e4             	pushl  -0x1c(%ebp)
  800068:	e8 bc 10 00 00       	call   801129 <ipc_send>
  80006d:	83 c4 20             	add    $0x20,%esp
	}

	while (1) {
		uint32_t i = ipc_recv(&who, 0, 0);
  800070:	8d 7d e4             	lea    -0x1c(%ebp),%edi
  800073:	83 ec 04             	sub    $0x4,%esp
  800076:	6a 00                	push   $0x0
  800078:	6a 00                	push   $0x0
  80007a:	57                   	push   %edi
  80007b:	e8 34 10 00 00       	call   8010b4 <ipc_recv>
  800080:	89 c3                	mov    %eax,%ebx
		cprintf("%x got %d from %x\n", sys_getenvid(), i, who);
  800082:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  800085:	e8 1b 0b 00 00       	call   800ba5 <sys_getenvid>
  80008a:	56                   	push   %esi
  80008b:	53                   	push   %ebx
  80008c:	50                   	push   %eax
  80008d:	68 16 22 80 00       	push   $0x802216
  800092:	e8 21 01 00 00       	call   8001b8 <cprintf>
		if (i == 10)
  800097:	83 c4 20             	add    $0x20,%esp
  80009a:	83 fb 0a             	cmp    $0xa,%ebx
  80009d:	74 16                	je     8000b5 <umain+0x81>
			return;
		i++;
  80009f:	43                   	inc    %ebx
		ipc_send(who, i, 0, 0);
  8000a0:	6a 00                	push   $0x0
  8000a2:	6a 00                	push   $0x0
  8000a4:	53                   	push   %ebx
  8000a5:	ff 75 e4             	pushl  -0x1c(%ebp)
  8000a8:	e8 7c 10 00 00       	call   801129 <ipc_send>
		if (i == 10)
  8000ad:	83 c4 10             	add    $0x10,%esp
  8000b0:	83 fb 0a             	cmp    $0xa,%ebx
  8000b3:	75 be                	jne    800073 <umain+0x3f>
			return;
	}

}
  8000b5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8000b8:	5b                   	pop    %ebx
  8000b9:	5e                   	pop    %esi
  8000ba:	5f                   	pop    %edi
  8000bb:	c9                   	leave  
  8000bc:	c3                   	ret    
  8000bd:	00 00                	add    %al,(%eax)
	...

008000c0 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000c0:	55                   	push   %ebp
  8000c1:	89 e5                	mov    %esp,%ebp
  8000c3:	56                   	push   %esi
  8000c4:	53                   	push   %ebx
  8000c5:	8b 75 08             	mov    0x8(%ebp),%esi
  8000c8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs + ENVX(sys_getenvid());
  8000cb:	e8 d5 0a 00 00       	call   800ba5 <sys_getenvid>
  8000d0:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000d5:	89 c2                	mov    %eax,%edx
  8000d7:	c1 e2 07             	shl    $0x7,%edx
  8000da:	8d 84 82 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,4),%eax
  8000e1:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000e6:	85 f6                	test   %esi,%esi
  8000e8:	7e 07                	jle    8000f1 <libmain+0x31>
		binaryname = argv[0];
  8000ea:	8b 03                	mov    (%ebx),%eax
  8000ec:	a3 00 30 80 00       	mov    %eax,0x803000
	// call user main routine
	umain(argc, argv);
  8000f1:	83 ec 08             	sub    $0x8,%esp
  8000f4:	53                   	push   %ebx
  8000f5:	56                   	push   %esi
  8000f6:	e8 39 ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  8000fb:	e8 0c 00 00 00       	call   80010c <exit>
  800100:	83 c4 10             	add    $0x10,%esp
}
  800103:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800106:	5b                   	pop    %ebx
  800107:	5e                   	pop    %esi
  800108:	c9                   	leave  
  800109:	c3                   	ret    
	...

0080010c <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80010c:	55                   	push   %ebp
  80010d:	89 e5                	mov    %esp,%ebp
  80010f:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800112:	e8 bf 12 00 00       	call   8013d6 <close_all>
	sys_env_destroy(0);
  800117:	83 ec 0c             	sub    $0xc,%esp
  80011a:	6a 00                	push   $0x0
  80011c:	e8 62 0a 00 00       	call   800b83 <sys_env_destroy>
  800121:	83 c4 10             	add    $0x10,%esp
}
  800124:	c9                   	leave  
  800125:	c3                   	ret    
	...

00800128 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800128:	55                   	push   %ebp
  800129:	89 e5                	mov    %esp,%ebp
  80012b:	53                   	push   %ebx
  80012c:	83 ec 04             	sub    $0x4,%esp
  80012f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800132:	8b 03                	mov    (%ebx),%eax
  800134:	8b 55 08             	mov    0x8(%ebp),%edx
  800137:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  80013b:	40                   	inc    %eax
  80013c:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  80013e:	3d ff 00 00 00       	cmp    $0xff,%eax
  800143:	75 1a                	jne    80015f <putch+0x37>
		sys_cputs(b->buf, b->idx);
  800145:	83 ec 08             	sub    $0x8,%esp
  800148:	68 ff 00 00 00       	push   $0xff
  80014d:	8d 43 08             	lea    0x8(%ebx),%eax
  800150:	50                   	push   %eax
  800151:	e8 e3 09 00 00       	call   800b39 <sys_cputs>
		b->idx = 0;
  800156:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80015c:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80015f:	ff 43 04             	incl   0x4(%ebx)
}
  800162:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800165:	c9                   	leave  
  800166:	c3                   	ret    

00800167 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800167:	55                   	push   %ebp
  800168:	89 e5                	mov    %esp,%ebp
  80016a:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800170:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800177:	00 00 00 
	b.cnt = 0;
  80017a:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800181:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800184:	ff 75 0c             	pushl  0xc(%ebp)
  800187:	ff 75 08             	pushl  0x8(%ebp)
  80018a:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800190:	50                   	push   %eax
  800191:	68 28 01 80 00       	push   $0x800128
  800196:	e8 82 01 00 00       	call   80031d <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80019b:	83 c4 08             	add    $0x8,%esp
  80019e:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8001a4:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001aa:	50                   	push   %eax
  8001ab:	e8 89 09 00 00       	call   800b39 <sys_cputs>

	return b.cnt;
}
  8001b0:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001b6:	c9                   	leave  
  8001b7:	c3                   	ret    

008001b8 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001b8:	55                   	push   %ebp
  8001b9:	89 e5                	mov    %esp,%ebp
  8001bb:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001be:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001c1:	50                   	push   %eax
  8001c2:	ff 75 08             	pushl  0x8(%ebp)
  8001c5:	e8 9d ff ff ff       	call   800167 <vcprintf>
	va_end(ap);

	return cnt;
}
  8001ca:	c9                   	leave  
  8001cb:	c3                   	ret    

008001cc <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001cc:	55                   	push   %ebp
  8001cd:	89 e5                	mov    %esp,%ebp
  8001cf:	57                   	push   %edi
  8001d0:	56                   	push   %esi
  8001d1:	53                   	push   %ebx
  8001d2:	83 ec 2c             	sub    $0x2c,%esp
  8001d5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8001d8:	89 d6                	mov    %edx,%esi
  8001da:	8b 45 08             	mov    0x8(%ebp),%eax
  8001dd:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001e0:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001e3:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8001e6:	8b 45 10             	mov    0x10(%ebp),%eax
  8001e9:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8001ec:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001ef:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8001f2:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  8001f9:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
  8001fc:	72 0c                	jb     80020a <printnum+0x3e>
  8001fe:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  800201:	76 07                	jbe    80020a <printnum+0x3e>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800203:	4b                   	dec    %ebx
  800204:	85 db                	test   %ebx,%ebx
  800206:	7f 31                	jg     800239 <printnum+0x6d>
  800208:	eb 3f                	jmp    800249 <printnum+0x7d>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80020a:	83 ec 0c             	sub    $0xc,%esp
  80020d:	57                   	push   %edi
  80020e:	4b                   	dec    %ebx
  80020f:	53                   	push   %ebx
  800210:	50                   	push   %eax
  800211:	83 ec 08             	sub    $0x8,%esp
  800214:	ff 75 d4             	pushl  -0x2c(%ebp)
  800217:	ff 75 d0             	pushl  -0x30(%ebp)
  80021a:	ff 75 dc             	pushl  -0x24(%ebp)
  80021d:	ff 75 d8             	pushl  -0x28(%ebp)
  800220:	e8 7b 1d 00 00       	call   801fa0 <__udivdi3>
  800225:	83 c4 18             	add    $0x18,%esp
  800228:	52                   	push   %edx
  800229:	50                   	push   %eax
  80022a:	89 f2                	mov    %esi,%edx
  80022c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80022f:	e8 98 ff ff ff       	call   8001cc <printnum>
  800234:	83 c4 20             	add    $0x20,%esp
  800237:	eb 10                	jmp    800249 <printnum+0x7d>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800239:	83 ec 08             	sub    $0x8,%esp
  80023c:	56                   	push   %esi
  80023d:	57                   	push   %edi
  80023e:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800241:	4b                   	dec    %ebx
  800242:	83 c4 10             	add    $0x10,%esp
  800245:	85 db                	test   %ebx,%ebx
  800247:	7f f0                	jg     800239 <printnum+0x6d>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800249:	83 ec 08             	sub    $0x8,%esp
  80024c:	56                   	push   %esi
  80024d:	83 ec 04             	sub    $0x4,%esp
  800250:	ff 75 d4             	pushl  -0x2c(%ebp)
  800253:	ff 75 d0             	pushl  -0x30(%ebp)
  800256:	ff 75 dc             	pushl  -0x24(%ebp)
  800259:	ff 75 d8             	pushl  -0x28(%ebp)
  80025c:	e8 5b 1e 00 00       	call   8020bc <__umoddi3>
  800261:	83 c4 14             	add    $0x14,%esp
  800264:	0f be 80 33 22 80 00 	movsbl 0x802233(%eax),%eax
  80026b:	50                   	push   %eax
  80026c:	ff 55 e4             	call   *-0x1c(%ebp)
  80026f:	83 c4 10             	add    $0x10,%esp
}
  800272:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800275:	5b                   	pop    %ebx
  800276:	5e                   	pop    %esi
  800277:	5f                   	pop    %edi
  800278:	c9                   	leave  
  800279:	c3                   	ret    

0080027a <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80027a:	55                   	push   %ebp
  80027b:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80027d:	83 fa 01             	cmp    $0x1,%edx
  800280:	7e 0e                	jle    800290 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800282:	8b 10                	mov    (%eax),%edx
  800284:	8d 4a 08             	lea    0x8(%edx),%ecx
  800287:	89 08                	mov    %ecx,(%eax)
  800289:	8b 02                	mov    (%edx),%eax
  80028b:	8b 52 04             	mov    0x4(%edx),%edx
  80028e:	eb 22                	jmp    8002b2 <getuint+0x38>
	else if (lflag)
  800290:	85 d2                	test   %edx,%edx
  800292:	74 10                	je     8002a4 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800294:	8b 10                	mov    (%eax),%edx
  800296:	8d 4a 04             	lea    0x4(%edx),%ecx
  800299:	89 08                	mov    %ecx,(%eax)
  80029b:	8b 02                	mov    (%edx),%eax
  80029d:	ba 00 00 00 00       	mov    $0x0,%edx
  8002a2:	eb 0e                	jmp    8002b2 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8002a4:	8b 10                	mov    (%eax),%edx
  8002a6:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002a9:	89 08                	mov    %ecx,(%eax)
  8002ab:	8b 02                	mov    (%edx),%eax
  8002ad:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002b2:	c9                   	leave  
  8002b3:	c3                   	ret    

008002b4 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  8002b4:	55                   	push   %ebp
  8002b5:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002b7:	83 fa 01             	cmp    $0x1,%edx
  8002ba:	7e 0e                	jle    8002ca <getint+0x16>
		return va_arg(*ap, long long);
  8002bc:	8b 10                	mov    (%eax),%edx
  8002be:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002c1:	89 08                	mov    %ecx,(%eax)
  8002c3:	8b 02                	mov    (%edx),%eax
  8002c5:	8b 52 04             	mov    0x4(%edx),%edx
  8002c8:	eb 1a                	jmp    8002e4 <getint+0x30>
	else if (lflag)
  8002ca:	85 d2                	test   %edx,%edx
  8002cc:	74 0c                	je     8002da <getint+0x26>
		return va_arg(*ap, long);
  8002ce:	8b 10                	mov    (%eax),%edx
  8002d0:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002d3:	89 08                	mov    %ecx,(%eax)
  8002d5:	8b 02                	mov    (%edx),%eax
  8002d7:	99                   	cltd   
  8002d8:	eb 0a                	jmp    8002e4 <getint+0x30>
	else
		return va_arg(*ap, int);
  8002da:	8b 10                	mov    (%eax),%edx
  8002dc:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002df:	89 08                	mov    %ecx,(%eax)
  8002e1:	8b 02                	mov    (%edx),%eax
  8002e3:	99                   	cltd   
}
  8002e4:	c9                   	leave  
  8002e5:	c3                   	ret    

008002e6 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002e6:	55                   	push   %ebp
  8002e7:	89 e5                	mov    %esp,%ebp
  8002e9:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002ec:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  8002ef:	8b 10                	mov    (%eax),%edx
  8002f1:	3b 50 04             	cmp    0x4(%eax),%edx
  8002f4:	73 08                	jae    8002fe <sprintputch+0x18>
		*b->buf++ = ch;
  8002f6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8002f9:	88 0a                	mov    %cl,(%edx)
  8002fb:	42                   	inc    %edx
  8002fc:	89 10                	mov    %edx,(%eax)
}
  8002fe:	c9                   	leave  
  8002ff:	c3                   	ret    

00800300 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800300:	55                   	push   %ebp
  800301:	89 e5                	mov    %esp,%ebp
  800303:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800306:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800309:	50                   	push   %eax
  80030a:	ff 75 10             	pushl  0x10(%ebp)
  80030d:	ff 75 0c             	pushl  0xc(%ebp)
  800310:	ff 75 08             	pushl  0x8(%ebp)
  800313:	e8 05 00 00 00       	call   80031d <vprintfmt>
	va_end(ap);
  800318:	83 c4 10             	add    $0x10,%esp
}
  80031b:	c9                   	leave  
  80031c:	c3                   	ret    

0080031d <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80031d:	55                   	push   %ebp
  80031e:	89 e5                	mov    %esp,%ebp
  800320:	57                   	push   %edi
  800321:	56                   	push   %esi
  800322:	53                   	push   %ebx
  800323:	83 ec 2c             	sub    $0x2c,%esp
  800326:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800329:	8b 75 10             	mov    0x10(%ebp),%esi
  80032c:	eb 13                	jmp    800341 <vprintfmt+0x24>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80032e:	85 c0                	test   %eax,%eax
  800330:	0f 84 6d 03 00 00    	je     8006a3 <vprintfmt+0x386>
				return;
			putch(ch, putdat);
  800336:	83 ec 08             	sub    $0x8,%esp
  800339:	57                   	push   %edi
  80033a:	50                   	push   %eax
  80033b:	ff 55 08             	call   *0x8(%ebp)
  80033e:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800341:	0f b6 06             	movzbl (%esi),%eax
  800344:	46                   	inc    %esi
  800345:	83 f8 25             	cmp    $0x25,%eax
  800348:	75 e4                	jne    80032e <vprintfmt+0x11>
  80034a:	c6 45 dc 20          	movb   $0x20,-0x24(%ebp)
  80034e:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  800355:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  80035c:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800363:	b9 00 00 00 00       	mov    $0x0,%ecx
  800368:	eb 28                	jmp    800392 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80036a:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  80036c:	c6 45 dc 2d          	movb   $0x2d,-0x24(%ebp)
  800370:	eb 20                	jmp    800392 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800372:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800374:	c6 45 dc 30          	movb   $0x30,-0x24(%ebp)
  800378:	eb 18                	jmp    800392 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80037a:	89 de                	mov    %ebx,%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  80037c:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800383:	eb 0d                	jmp    800392 <vprintfmt+0x75>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800385:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800388:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80038b:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800392:	8a 06                	mov    (%esi),%al
  800394:	0f b6 d0             	movzbl %al,%edx
  800397:	8d 5e 01             	lea    0x1(%esi),%ebx
  80039a:	83 e8 23             	sub    $0x23,%eax
  80039d:	3c 55                	cmp    $0x55,%al
  80039f:	0f 87 e0 02 00 00    	ja     800685 <vprintfmt+0x368>
  8003a5:	0f b6 c0             	movzbl %al,%eax
  8003a8:	ff 24 85 80 23 80 00 	jmp    *0x802380(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003af:	83 ea 30             	sub    $0x30,%edx
  8003b2:	89 55 d4             	mov    %edx,-0x2c(%ebp)
				ch = *fmt;
  8003b5:	0f be 03             	movsbl (%ebx),%eax
				if (ch < '0' || ch > '9')
  8003b8:	8d 50 d0             	lea    -0x30(%eax),%edx
  8003bb:	83 fa 09             	cmp    $0x9,%edx
  8003be:	77 44                	ja     800404 <vprintfmt+0xe7>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003c0:	89 de                	mov    %ebx,%esi
  8003c2:	8b 55 d4             	mov    -0x2c(%ebp),%edx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003c5:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
  8003c6:	8d 14 92             	lea    (%edx,%edx,4),%edx
  8003c9:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
  8003cd:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8003d0:	8d 58 d0             	lea    -0x30(%eax),%ebx
  8003d3:	83 fb 09             	cmp    $0x9,%ebx
  8003d6:	76 ed                	jbe    8003c5 <vprintfmt+0xa8>
  8003d8:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  8003db:	eb 29                	jmp    800406 <vprintfmt+0xe9>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003dd:	8b 45 14             	mov    0x14(%ebp),%eax
  8003e0:	8d 50 04             	lea    0x4(%eax),%edx
  8003e3:	89 55 14             	mov    %edx,0x14(%ebp)
  8003e6:	8b 00                	mov    (%eax),%eax
  8003e8:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003eb:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8003ed:	eb 17                	jmp    800406 <vprintfmt+0xe9>

		case '.':
			if (width < 0)
  8003ef:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8003f3:	78 85                	js     80037a <vprintfmt+0x5d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003f5:	89 de                	mov    %ebx,%esi
  8003f7:	eb 99                	jmp    800392 <vprintfmt+0x75>
  8003f9:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8003fb:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  800402:	eb 8e                	jmp    800392 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800404:	89 de                	mov    %ebx,%esi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  800406:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80040a:	79 86                	jns    800392 <vprintfmt+0x75>
  80040c:	e9 74 ff ff ff       	jmp    800385 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800411:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800412:	89 de                	mov    %ebx,%esi
  800414:	e9 79 ff ff ff       	jmp    800392 <vprintfmt+0x75>
  800419:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80041c:	8b 45 14             	mov    0x14(%ebp),%eax
  80041f:	8d 50 04             	lea    0x4(%eax),%edx
  800422:	89 55 14             	mov    %edx,0x14(%ebp)
  800425:	83 ec 08             	sub    $0x8,%esp
  800428:	57                   	push   %edi
  800429:	ff 30                	pushl  (%eax)
  80042b:	ff 55 08             	call   *0x8(%ebp)
			break;
  80042e:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800431:	8b 75 d8             	mov    -0x28(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800434:	e9 08 ff ff ff       	jmp    800341 <vprintfmt+0x24>
  800439:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  80043c:	8b 45 14             	mov    0x14(%ebp),%eax
  80043f:	8d 50 04             	lea    0x4(%eax),%edx
  800442:	89 55 14             	mov    %edx,0x14(%ebp)
  800445:	8b 00                	mov    (%eax),%eax
  800447:	85 c0                	test   %eax,%eax
  800449:	79 02                	jns    80044d <vprintfmt+0x130>
  80044b:	f7 d8                	neg    %eax
  80044d:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80044f:	83 f8 0f             	cmp    $0xf,%eax
  800452:	7f 0b                	jg     80045f <vprintfmt+0x142>
  800454:	8b 04 85 e0 24 80 00 	mov    0x8024e0(,%eax,4),%eax
  80045b:	85 c0                	test   %eax,%eax
  80045d:	75 1a                	jne    800479 <vprintfmt+0x15c>
				printfmt(putch, putdat, "error %d", err);
  80045f:	52                   	push   %edx
  800460:	68 4b 22 80 00       	push   $0x80224b
  800465:	57                   	push   %edi
  800466:	ff 75 08             	pushl  0x8(%ebp)
  800469:	e8 92 fe ff ff       	call   800300 <printfmt>
  80046e:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800471:	8b 75 d8             	mov    -0x28(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800474:	e9 c8 fe ff ff       	jmp    800341 <vprintfmt+0x24>
			else
				printfmt(putch, putdat, "%s", p);
  800479:	50                   	push   %eax
  80047a:	68 b1 27 80 00       	push   $0x8027b1
  80047f:	57                   	push   %edi
  800480:	ff 75 08             	pushl  0x8(%ebp)
  800483:	e8 78 fe ff ff       	call   800300 <printfmt>
  800488:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80048b:	8b 75 d8             	mov    -0x28(%ebp),%esi
  80048e:	e9 ae fe ff ff       	jmp    800341 <vprintfmt+0x24>
  800493:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  800496:	89 de                	mov    %ebx,%esi
  800498:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  80049b:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80049e:	8b 45 14             	mov    0x14(%ebp),%eax
  8004a1:	8d 50 04             	lea    0x4(%eax),%edx
  8004a4:	89 55 14             	mov    %edx,0x14(%ebp)
  8004a7:	8b 00                	mov    (%eax),%eax
  8004a9:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8004ac:	85 c0                	test   %eax,%eax
  8004ae:	75 07                	jne    8004b7 <vprintfmt+0x19a>
				p = "(null)";
  8004b0:	c7 45 d0 44 22 80 00 	movl   $0x802244,-0x30(%ebp)
			if (width > 0 && padc != '-')
  8004b7:	85 db                	test   %ebx,%ebx
  8004b9:	7e 42                	jle    8004fd <vprintfmt+0x1e0>
  8004bb:	80 7d dc 2d          	cmpb   $0x2d,-0x24(%ebp)
  8004bf:	74 3c                	je     8004fd <vprintfmt+0x1e0>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004c1:	83 ec 08             	sub    $0x8,%esp
  8004c4:	51                   	push   %ecx
  8004c5:	ff 75 d0             	pushl  -0x30(%ebp)
  8004c8:	e8 6f 02 00 00       	call   80073c <strnlen>
  8004cd:	29 c3                	sub    %eax,%ebx
  8004cf:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8004d2:	83 c4 10             	add    $0x10,%esp
  8004d5:	85 db                	test   %ebx,%ebx
  8004d7:	7e 24                	jle    8004fd <vprintfmt+0x1e0>
					putch(padc, putdat);
  8004d9:	0f be 5d dc          	movsbl -0x24(%ebp),%ebx
  8004dd:	89 75 dc             	mov    %esi,-0x24(%ebp)
  8004e0:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  8004e3:	83 ec 08             	sub    $0x8,%esp
  8004e6:	57                   	push   %edi
  8004e7:	53                   	push   %ebx
  8004e8:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004eb:	4e                   	dec    %esi
  8004ec:	83 c4 10             	add    $0x10,%esp
  8004ef:	85 f6                	test   %esi,%esi
  8004f1:	7f f0                	jg     8004e3 <vprintfmt+0x1c6>
  8004f3:	8b 75 dc             	mov    -0x24(%ebp),%esi
  8004f6:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004fd:	8b 55 d0             	mov    -0x30(%ebp),%edx
  800500:	0f be 02             	movsbl (%edx),%eax
  800503:	85 c0                	test   %eax,%eax
  800505:	75 47                	jne    80054e <vprintfmt+0x231>
  800507:	eb 37                	jmp    800540 <vprintfmt+0x223>
				if (altflag && (ch < ' ' || ch > '~'))
  800509:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80050d:	74 16                	je     800525 <vprintfmt+0x208>
  80050f:	8d 50 e0             	lea    -0x20(%eax),%edx
  800512:	83 fa 5e             	cmp    $0x5e,%edx
  800515:	76 0e                	jbe    800525 <vprintfmt+0x208>
					putch('?', putdat);
  800517:	83 ec 08             	sub    $0x8,%esp
  80051a:	57                   	push   %edi
  80051b:	6a 3f                	push   $0x3f
  80051d:	ff 55 08             	call   *0x8(%ebp)
  800520:	83 c4 10             	add    $0x10,%esp
  800523:	eb 0b                	jmp    800530 <vprintfmt+0x213>
				else
					putch(ch, putdat);
  800525:	83 ec 08             	sub    $0x8,%esp
  800528:	57                   	push   %edi
  800529:	50                   	push   %eax
  80052a:	ff 55 08             	call   *0x8(%ebp)
  80052d:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800530:	ff 4d e4             	decl   -0x1c(%ebp)
  800533:	0f be 03             	movsbl (%ebx),%eax
  800536:	85 c0                	test   %eax,%eax
  800538:	74 03                	je     80053d <vprintfmt+0x220>
  80053a:	43                   	inc    %ebx
  80053b:	eb 1b                	jmp    800558 <vprintfmt+0x23b>
  80053d:	8b 75 dc             	mov    -0x24(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800540:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800544:	7f 1e                	jg     800564 <vprintfmt+0x247>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800546:	8b 75 d8             	mov    -0x28(%ebp),%esi
  800549:	e9 f3 fd ff ff       	jmp    800341 <vprintfmt+0x24>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80054e:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800551:	43                   	inc    %ebx
  800552:	89 75 dc             	mov    %esi,-0x24(%ebp)
  800555:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  800558:	85 f6                	test   %esi,%esi
  80055a:	78 ad                	js     800509 <vprintfmt+0x1ec>
  80055c:	4e                   	dec    %esi
  80055d:	79 aa                	jns    800509 <vprintfmt+0x1ec>
  80055f:	8b 75 dc             	mov    -0x24(%ebp),%esi
  800562:	eb dc                	jmp    800540 <vprintfmt+0x223>
  800564:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800567:	83 ec 08             	sub    $0x8,%esp
  80056a:	57                   	push   %edi
  80056b:	6a 20                	push   $0x20
  80056d:	ff 55 08             	call   *0x8(%ebp)
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800570:	4b                   	dec    %ebx
  800571:	83 c4 10             	add    $0x10,%esp
  800574:	85 db                	test   %ebx,%ebx
  800576:	7f ef                	jg     800567 <vprintfmt+0x24a>
  800578:	e9 c4 fd ff ff       	jmp    800341 <vprintfmt+0x24>
  80057d:	89 5d d8             	mov    %ebx,-0x28(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800580:	89 ca                	mov    %ecx,%edx
  800582:	8d 45 14             	lea    0x14(%ebp),%eax
  800585:	e8 2a fd ff ff       	call   8002b4 <getint>
  80058a:	89 c3                	mov    %eax,%ebx
  80058c:	89 d6                	mov    %edx,%esi
			if ((long long) num < 0) {
  80058e:	85 d2                	test   %edx,%edx
  800590:	78 0a                	js     80059c <vprintfmt+0x27f>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800592:	b8 0a 00 00 00       	mov    $0xa,%eax
  800597:	e9 b0 00 00 00       	jmp    80064c <vprintfmt+0x32f>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  80059c:	83 ec 08             	sub    $0x8,%esp
  80059f:	57                   	push   %edi
  8005a0:	6a 2d                	push   $0x2d
  8005a2:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8005a5:	f7 db                	neg    %ebx
  8005a7:	83 d6 00             	adc    $0x0,%esi
  8005aa:	f7 de                	neg    %esi
  8005ac:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8005af:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005b4:	e9 93 00 00 00       	jmp    80064c <vprintfmt+0x32f>
  8005b9:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8005bc:	89 ca                	mov    %ecx,%edx
  8005be:	8d 45 14             	lea    0x14(%ebp),%eax
  8005c1:	e8 b4 fc ff ff       	call   80027a <getuint>
  8005c6:	89 c3                	mov    %eax,%ebx
  8005c8:	89 d6                	mov    %edx,%esi
			base = 10;
  8005ca:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  8005cf:	eb 7b                	jmp    80064c <vprintfmt+0x32f>
  8005d1:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
  8005d4:	89 ca                	mov    %ecx,%edx
  8005d6:	8d 45 14             	lea    0x14(%ebp),%eax
  8005d9:	e8 d6 fc ff ff       	call   8002b4 <getint>
  8005de:	89 c3                	mov    %eax,%ebx
  8005e0:	89 d6                	mov    %edx,%esi
            if ((long long) num < 0) {
  8005e2:	85 d2                	test   %edx,%edx
  8005e4:	78 07                	js     8005ed <vprintfmt+0x2d0>
                putch('-', putdat);
                num = -(long long) num;
            }
            base = 8;
  8005e6:	b8 08 00 00 00       	mov    $0x8,%eax
  8005eb:	eb 5f                	jmp    80064c <vprintfmt+0x32f>
		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
            if ((long long) num < 0) {
                putch('-', putdat);
  8005ed:	83 ec 08             	sub    $0x8,%esp
  8005f0:	57                   	push   %edi
  8005f1:	6a 2d                	push   $0x2d
  8005f3:	ff 55 08             	call   *0x8(%ebp)
                num = -(long long) num;
  8005f6:	f7 db                	neg    %ebx
  8005f8:	83 d6 00             	adc    $0x0,%esi
  8005fb:	f7 de                	neg    %esi
  8005fd:	83 c4 10             	add    $0x10,%esp
            }
            base = 8;
  800600:	b8 08 00 00 00       	mov    $0x8,%eax
  800605:	eb 45                	jmp    80064c <vprintfmt+0x32f>
  800607:	89 5d d8             	mov    %ebx,-0x28(%ebp)
            goto number;

        // pointer
		case 'p':
			putch('0', putdat);
  80060a:	83 ec 08             	sub    $0x8,%esp
  80060d:	57                   	push   %edi
  80060e:	6a 30                	push   $0x30
  800610:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800613:	83 c4 08             	add    $0x8,%esp
  800616:	57                   	push   %edi
  800617:	6a 78                	push   $0x78
  800619:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80061c:	8b 45 14             	mov    0x14(%ebp),%eax
  80061f:	8d 50 04             	lea    0x4(%eax),%edx
  800622:	89 55 14             	mov    %edx,0x14(%ebp)

        // pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800625:	8b 18                	mov    (%eax),%ebx
  800627:	be 00 00 00 00       	mov    $0x0,%esi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80062c:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80062f:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800634:	eb 16                	jmp    80064c <vprintfmt+0x32f>
  800636:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800639:	89 ca                	mov    %ecx,%edx
  80063b:	8d 45 14             	lea    0x14(%ebp),%eax
  80063e:	e8 37 fc ff ff       	call   80027a <getuint>
  800643:	89 c3                	mov    %eax,%ebx
  800645:	89 d6                	mov    %edx,%esi
			base = 16;
  800647:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  80064c:	83 ec 0c             	sub    $0xc,%esp
  80064f:	0f be 55 dc          	movsbl -0x24(%ebp),%edx
  800653:	52                   	push   %edx
  800654:	ff 75 e4             	pushl  -0x1c(%ebp)
  800657:	50                   	push   %eax
  800658:	56                   	push   %esi
  800659:	53                   	push   %ebx
  80065a:	89 fa                	mov    %edi,%edx
  80065c:	8b 45 08             	mov    0x8(%ebp),%eax
  80065f:	e8 68 fb ff ff       	call   8001cc <printnum>
			break;
  800664:	83 c4 20             	add    $0x20,%esp
  800667:	8b 75 d8             	mov    -0x28(%ebp),%esi
  80066a:	e9 d2 fc ff ff       	jmp    800341 <vprintfmt+0x24>
  80066f:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800672:	83 ec 08             	sub    $0x8,%esp
  800675:	57                   	push   %edi
  800676:	52                   	push   %edx
  800677:	ff 55 08             	call   *0x8(%ebp)
			break;
  80067a:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80067d:	8b 75 d8             	mov    -0x28(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800680:	e9 bc fc ff ff       	jmp    800341 <vprintfmt+0x24>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800685:	83 ec 08             	sub    $0x8,%esp
  800688:	57                   	push   %edi
  800689:	6a 25                	push   $0x25
  80068b:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  80068e:	83 c4 10             	add    $0x10,%esp
  800691:	eb 02                	jmp    800695 <vprintfmt+0x378>
  800693:	89 c6                	mov    %eax,%esi
  800695:	8d 46 ff             	lea    -0x1(%esi),%eax
  800698:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  80069c:	75 f5                	jne    800693 <vprintfmt+0x376>
  80069e:	e9 9e fc ff ff       	jmp    800341 <vprintfmt+0x24>
				/* do nothing */;
			break;
		}
	}
}
  8006a3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006a6:	5b                   	pop    %ebx
  8006a7:	5e                   	pop    %esi
  8006a8:	5f                   	pop    %edi
  8006a9:	c9                   	leave  
  8006aa:	c3                   	ret    

008006ab <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006ab:	55                   	push   %ebp
  8006ac:	89 e5                	mov    %esp,%ebp
  8006ae:	83 ec 18             	sub    $0x18,%esp
  8006b1:	8b 45 08             	mov    0x8(%ebp),%eax
  8006b4:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006b7:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006ba:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8006be:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8006c1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8006c8:	85 c0                	test   %eax,%eax
  8006ca:	74 26                	je     8006f2 <vsnprintf+0x47>
  8006cc:	85 d2                	test   %edx,%edx
  8006ce:	7e 29                	jle    8006f9 <vsnprintf+0x4e>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8006d0:	ff 75 14             	pushl  0x14(%ebp)
  8006d3:	ff 75 10             	pushl  0x10(%ebp)
  8006d6:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8006d9:	50                   	push   %eax
  8006da:	68 e6 02 80 00       	push   $0x8002e6
  8006df:	e8 39 fc ff ff       	call   80031d <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8006e4:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8006e7:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8006ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006ed:	83 c4 10             	add    $0x10,%esp
  8006f0:	eb 0c                	jmp    8006fe <vsnprintf+0x53>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8006f2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8006f7:	eb 05                	jmp    8006fe <vsnprintf+0x53>
  8006f9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8006fe:	c9                   	leave  
  8006ff:	c3                   	ret    

00800700 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800700:	55                   	push   %ebp
  800701:	89 e5                	mov    %esp,%ebp
  800703:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800706:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800709:	50                   	push   %eax
  80070a:	ff 75 10             	pushl  0x10(%ebp)
  80070d:	ff 75 0c             	pushl  0xc(%ebp)
  800710:	ff 75 08             	pushl  0x8(%ebp)
  800713:	e8 93 ff ff ff       	call   8006ab <vsnprintf>
	va_end(ap);

	return rc;
}
  800718:	c9                   	leave  
  800719:	c3                   	ret    
	...

0080071c <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80071c:	55                   	push   %ebp
  80071d:	89 e5                	mov    %esp,%ebp
  80071f:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800722:	80 3a 00             	cmpb   $0x0,(%edx)
  800725:	74 0e                	je     800735 <strlen+0x19>
  800727:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  80072c:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80072d:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800731:	75 f9                	jne    80072c <strlen+0x10>
  800733:	eb 05                	jmp    80073a <strlen+0x1e>
  800735:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  80073a:	c9                   	leave  
  80073b:	c3                   	ret    

0080073c <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80073c:	55                   	push   %ebp
  80073d:	89 e5                	mov    %esp,%ebp
  80073f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800742:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800745:	85 d2                	test   %edx,%edx
  800747:	74 17                	je     800760 <strnlen+0x24>
  800749:	80 39 00             	cmpb   $0x0,(%ecx)
  80074c:	74 19                	je     800767 <strnlen+0x2b>
  80074e:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800753:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800754:	39 d0                	cmp    %edx,%eax
  800756:	74 14                	je     80076c <strnlen+0x30>
  800758:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  80075c:	75 f5                	jne    800753 <strnlen+0x17>
  80075e:	eb 0c                	jmp    80076c <strnlen+0x30>
  800760:	b8 00 00 00 00       	mov    $0x0,%eax
  800765:	eb 05                	jmp    80076c <strnlen+0x30>
  800767:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  80076c:	c9                   	leave  
  80076d:	c3                   	ret    

0080076e <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80076e:	55                   	push   %ebp
  80076f:	89 e5                	mov    %esp,%ebp
  800771:	53                   	push   %ebx
  800772:	8b 45 08             	mov    0x8(%ebp),%eax
  800775:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800778:	ba 00 00 00 00       	mov    $0x0,%edx
  80077d:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  800780:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800783:	42                   	inc    %edx
  800784:	84 c9                	test   %cl,%cl
  800786:	75 f5                	jne    80077d <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800788:	5b                   	pop    %ebx
  800789:	c9                   	leave  
  80078a:	c3                   	ret    

0080078b <strcat>:

char *
strcat(char *dst, const char *src)
{
  80078b:	55                   	push   %ebp
  80078c:	89 e5                	mov    %esp,%ebp
  80078e:	53                   	push   %ebx
  80078f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800792:	53                   	push   %ebx
  800793:	e8 84 ff ff ff       	call   80071c <strlen>
  800798:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  80079b:	ff 75 0c             	pushl  0xc(%ebp)
  80079e:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  8007a1:	50                   	push   %eax
  8007a2:	e8 c7 ff ff ff       	call   80076e <strcpy>
	return dst;
}
  8007a7:	89 d8                	mov    %ebx,%eax
  8007a9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007ac:	c9                   	leave  
  8007ad:	c3                   	ret    

008007ae <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007ae:	55                   	push   %ebp
  8007af:	89 e5                	mov    %esp,%ebp
  8007b1:	56                   	push   %esi
  8007b2:	53                   	push   %ebx
  8007b3:	8b 45 08             	mov    0x8(%ebp),%eax
  8007b6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007b9:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007bc:	85 f6                	test   %esi,%esi
  8007be:	74 15                	je     8007d5 <strncpy+0x27>
  8007c0:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  8007c5:	8a 1a                	mov    (%edx),%bl
  8007c7:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007ca:	80 3a 01             	cmpb   $0x1,(%edx)
  8007cd:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007d0:	41                   	inc    %ecx
  8007d1:	39 ce                	cmp    %ecx,%esi
  8007d3:	77 f0                	ja     8007c5 <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8007d5:	5b                   	pop    %ebx
  8007d6:	5e                   	pop    %esi
  8007d7:	c9                   	leave  
  8007d8:	c3                   	ret    

008007d9 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8007d9:	55                   	push   %ebp
  8007da:	89 e5                	mov    %esp,%ebp
  8007dc:	57                   	push   %edi
  8007dd:	56                   	push   %esi
  8007de:	53                   	push   %ebx
  8007df:	8b 7d 08             	mov    0x8(%ebp),%edi
  8007e2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8007e5:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007e8:	85 f6                	test   %esi,%esi
  8007ea:	74 32                	je     80081e <strlcpy+0x45>
		while (--size > 0 && *src != '\0')
  8007ec:	83 fe 01             	cmp    $0x1,%esi
  8007ef:	74 22                	je     800813 <strlcpy+0x3a>
  8007f1:	8a 0b                	mov    (%ebx),%cl
  8007f3:	84 c9                	test   %cl,%cl
  8007f5:	74 20                	je     800817 <strlcpy+0x3e>
  8007f7:	89 f8                	mov    %edi,%eax
  8007f9:	ba 00 00 00 00       	mov    $0x0,%edx
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
  8007fe:	83 ee 02             	sub    $0x2,%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800801:	88 08                	mov    %cl,(%eax)
  800803:	40                   	inc    %eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800804:	39 f2                	cmp    %esi,%edx
  800806:	74 11                	je     800819 <strlcpy+0x40>
  800808:	8a 4c 13 01          	mov    0x1(%ebx,%edx,1),%cl
  80080c:	42                   	inc    %edx
  80080d:	84 c9                	test   %cl,%cl
  80080f:	75 f0                	jne    800801 <strlcpy+0x28>
  800811:	eb 06                	jmp    800819 <strlcpy+0x40>
  800813:	89 f8                	mov    %edi,%eax
  800815:	eb 02                	jmp    800819 <strlcpy+0x40>
  800817:	89 f8                	mov    %edi,%eax
			*dst++ = *src++;
		*dst = '\0';
  800819:	c6 00 00             	movb   $0x0,(%eax)
  80081c:	eb 02                	jmp    800820 <strlcpy+0x47>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80081e:	89 f8                	mov    %edi,%eax
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
		*dst = '\0';
	}
	return dst - dst_in;
  800820:	29 f8                	sub    %edi,%eax
}
  800822:	5b                   	pop    %ebx
  800823:	5e                   	pop    %esi
  800824:	5f                   	pop    %edi
  800825:	c9                   	leave  
  800826:	c3                   	ret    

00800827 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800827:	55                   	push   %ebp
  800828:	89 e5                	mov    %esp,%ebp
  80082a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80082d:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800830:	8a 01                	mov    (%ecx),%al
  800832:	84 c0                	test   %al,%al
  800834:	74 10                	je     800846 <strcmp+0x1f>
  800836:	3a 02                	cmp    (%edx),%al
  800838:	75 0c                	jne    800846 <strcmp+0x1f>
		p++, q++;
  80083a:	41                   	inc    %ecx
  80083b:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80083c:	8a 01                	mov    (%ecx),%al
  80083e:	84 c0                	test   %al,%al
  800840:	74 04                	je     800846 <strcmp+0x1f>
  800842:	3a 02                	cmp    (%edx),%al
  800844:	74 f4                	je     80083a <strcmp+0x13>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800846:	0f b6 c0             	movzbl %al,%eax
  800849:	0f b6 12             	movzbl (%edx),%edx
  80084c:	29 d0                	sub    %edx,%eax
}
  80084e:	c9                   	leave  
  80084f:	c3                   	ret    

00800850 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800850:	55                   	push   %ebp
  800851:	89 e5                	mov    %esp,%ebp
  800853:	53                   	push   %ebx
  800854:	8b 55 08             	mov    0x8(%ebp),%edx
  800857:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80085a:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  80085d:	85 c0                	test   %eax,%eax
  80085f:	74 1b                	je     80087c <strncmp+0x2c>
  800861:	8a 1a                	mov    (%edx),%bl
  800863:	84 db                	test   %bl,%bl
  800865:	74 24                	je     80088b <strncmp+0x3b>
  800867:	3a 19                	cmp    (%ecx),%bl
  800869:	75 20                	jne    80088b <strncmp+0x3b>
  80086b:	48                   	dec    %eax
  80086c:	74 15                	je     800883 <strncmp+0x33>
		n--, p++, q++;
  80086e:	42                   	inc    %edx
  80086f:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800870:	8a 1a                	mov    (%edx),%bl
  800872:	84 db                	test   %bl,%bl
  800874:	74 15                	je     80088b <strncmp+0x3b>
  800876:	3a 19                	cmp    (%ecx),%bl
  800878:	74 f1                	je     80086b <strncmp+0x1b>
  80087a:	eb 0f                	jmp    80088b <strncmp+0x3b>
		n--, p++, q++;
	if (n == 0)
		return 0;
  80087c:	b8 00 00 00 00       	mov    $0x0,%eax
  800881:	eb 05                	jmp    800888 <strncmp+0x38>
  800883:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800888:	5b                   	pop    %ebx
  800889:	c9                   	leave  
  80088a:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80088b:	0f b6 02             	movzbl (%edx),%eax
  80088e:	0f b6 11             	movzbl (%ecx),%edx
  800891:	29 d0                	sub    %edx,%eax
  800893:	eb f3                	jmp    800888 <strncmp+0x38>

00800895 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800895:	55                   	push   %ebp
  800896:	89 e5                	mov    %esp,%ebp
  800898:	8b 45 08             	mov    0x8(%ebp),%eax
  80089b:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  80089e:	8a 10                	mov    (%eax),%dl
  8008a0:	84 d2                	test   %dl,%dl
  8008a2:	74 18                	je     8008bc <strchr+0x27>
		if (*s == c)
  8008a4:	38 ca                	cmp    %cl,%dl
  8008a6:	75 06                	jne    8008ae <strchr+0x19>
  8008a8:	eb 17                	jmp    8008c1 <strchr+0x2c>
  8008aa:	38 ca                	cmp    %cl,%dl
  8008ac:	74 13                	je     8008c1 <strchr+0x2c>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8008ae:	40                   	inc    %eax
  8008af:	8a 10                	mov    (%eax),%dl
  8008b1:	84 d2                	test   %dl,%dl
  8008b3:	75 f5                	jne    8008aa <strchr+0x15>
		if (*s == c)
			return (char *) s;
	return 0;
  8008b5:	b8 00 00 00 00       	mov    $0x0,%eax
  8008ba:	eb 05                	jmp    8008c1 <strchr+0x2c>
  8008bc:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008c1:	c9                   	leave  
  8008c2:	c3                   	ret    

008008c3 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008c3:	55                   	push   %ebp
  8008c4:	89 e5                	mov    %esp,%ebp
  8008c6:	8b 45 08             	mov    0x8(%ebp),%eax
  8008c9:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8008cc:	8a 10                	mov    (%eax),%dl
  8008ce:	84 d2                	test   %dl,%dl
  8008d0:	74 11                	je     8008e3 <strfind+0x20>
		if (*s == c)
  8008d2:	38 ca                	cmp    %cl,%dl
  8008d4:	75 06                	jne    8008dc <strfind+0x19>
  8008d6:	eb 0b                	jmp    8008e3 <strfind+0x20>
  8008d8:	38 ca                	cmp    %cl,%dl
  8008da:	74 07                	je     8008e3 <strfind+0x20>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  8008dc:	40                   	inc    %eax
  8008dd:	8a 10                	mov    (%eax),%dl
  8008df:	84 d2                	test   %dl,%dl
  8008e1:	75 f5                	jne    8008d8 <strfind+0x15>
		if (*s == c)
			break;
	return (char *) s;
}
  8008e3:	c9                   	leave  
  8008e4:	c3                   	ret    

008008e5 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008e5:	55                   	push   %ebp
  8008e6:	89 e5                	mov    %esp,%ebp
  8008e8:	57                   	push   %edi
  8008e9:	56                   	push   %esi
  8008ea:	53                   	push   %ebx
  8008eb:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008ee:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008f1:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8008f4:	85 c9                	test   %ecx,%ecx
  8008f6:	74 30                	je     800928 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008f8:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008fe:	75 25                	jne    800925 <memset+0x40>
  800900:	f6 c1 03             	test   $0x3,%cl
  800903:	75 20                	jne    800925 <memset+0x40>
		c &= 0xFF;
  800905:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800908:	89 d3                	mov    %edx,%ebx
  80090a:	c1 e3 08             	shl    $0x8,%ebx
  80090d:	89 d6                	mov    %edx,%esi
  80090f:	c1 e6 18             	shl    $0x18,%esi
  800912:	89 d0                	mov    %edx,%eax
  800914:	c1 e0 10             	shl    $0x10,%eax
  800917:	09 f0                	or     %esi,%eax
  800919:	09 d0                	or     %edx,%eax
  80091b:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  80091d:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800920:	fc                   	cld    
  800921:	f3 ab                	rep stos %eax,%es:(%edi)
  800923:	eb 03                	jmp    800928 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800925:	fc                   	cld    
  800926:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800928:	89 f8                	mov    %edi,%eax
  80092a:	5b                   	pop    %ebx
  80092b:	5e                   	pop    %esi
  80092c:	5f                   	pop    %edi
  80092d:	c9                   	leave  
  80092e:	c3                   	ret    

0080092f <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80092f:	55                   	push   %ebp
  800930:	89 e5                	mov    %esp,%ebp
  800932:	57                   	push   %edi
  800933:	56                   	push   %esi
  800934:	8b 45 08             	mov    0x8(%ebp),%eax
  800937:	8b 75 0c             	mov    0xc(%ebp),%esi
  80093a:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80093d:	39 c6                	cmp    %eax,%esi
  80093f:	73 34                	jae    800975 <memmove+0x46>
  800941:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800944:	39 d0                	cmp    %edx,%eax
  800946:	73 2d                	jae    800975 <memmove+0x46>
		s += n;
		d += n;
  800948:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80094b:	f6 c2 03             	test   $0x3,%dl
  80094e:	75 1b                	jne    80096b <memmove+0x3c>
  800950:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800956:	75 13                	jne    80096b <memmove+0x3c>
  800958:	f6 c1 03             	test   $0x3,%cl
  80095b:	75 0e                	jne    80096b <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  80095d:	83 ef 04             	sub    $0x4,%edi
  800960:	8d 72 fc             	lea    -0x4(%edx),%esi
  800963:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800966:	fd                   	std    
  800967:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800969:	eb 07                	jmp    800972 <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  80096b:	4f                   	dec    %edi
  80096c:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  80096f:	fd                   	std    
  800970:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800972:	fc                   	cld    
  800973:	eb 20                	jmp    800995 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800975:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80097b:	75 13                	jne    800990 <memmove+0x61>
  80097d:	a8 03                	test   $0x3,%al
  80097f:	75 0f                	jne    800990 <memmove+0x61>
  800981:	f6 c1 03             	test   $0x3,%cl
  800984:	75 0a                	jne    800990 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800986:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800989:	89 c7                	mov    %eax,%edi
  80098b:	fc                   	cld    
  80098c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80098e:	eb 05                	jmp    800995 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800990:	89 c7                	mov    %eax,%edi
  800992:	fc                   	cld    
  800993:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800995:	5e                   	pop    %esi
  800996:	5f                   	pop    %edi
  800997:	c9                   	leave  
  800998:	c3                   	ret    

00800999 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800999:	55                   	push   %ebp
  80099a:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  80099c:	ff 75 10             	pushl  0x10(%ebp)
  80099f:	ff 75 0c             	pushl  0xc(%ebp)
  8009a2:	ff 75 08             	pushl  0x8(%ebp)
  8009a5:	e8 85 ff ff ff       	call   80092f <memmove>
}
  8009aa:	c9                   	leave  
  8009ab:	c3                   	ret    

008009ac <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009ac:	55                   	push   %ebp
  8009ad:	89 e5                	mov    %esp,%ebp
  8009af:	57                   	push   %edi
  8009b0:	56                   	push   %esi
  8009b1:	53                   	push   %ebx
  8009b2:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8009b5:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009b8:	8b 7d 10             	mov    0x10(%ebp),%edi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009bb:	85 ff                	test   %edi,%edi
  8009bd:	74 32                	je     8009f1 <memcmp+0x45>
		if (*s1 != *s2)
  8009bf:	8a 03                	mov    (%ebx),%al
  8009c1:	8a 0e                	mov    (%esi),%cl
  8009c3:	38 c8                	cmp    %cl,%al
  8009c5:	74 19                	je     8009e0 <memcmp+0x34>
  8009c7:	eb 0d                	jmp    8009d6 <memcmp+0x2a>
  8009c9:	8a 44 13 01          	mov    0x1(%ebx,%edx,1),%al
  8009cd:	8a 4c 16 01          	mov    0x1(%esi,%edx,1),%cl
  8009d1:	42                   	inc    %edx
  8009d2:	38 c8                	cmp    %cl,%al
  8009d4:	74 10                	je     8009e6 <memcmp+0x3a>
			return (int) *s1 - (int) *s2;
  8009d6:	0f b6 c0             	movzbl %al,%eax
  8009d9:	0f b6 c9             	movzbl %cl,%ecx
  8009dc:	29 c8                	sub    %ecx,%eax
  8009de:	eb 16                	jmp    8009f6 <memcmp+0x4a>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009e0:	4f                   	dec    %edi
  8009e1:	ba 00 00 00 00       	mov    $0x0,%edx
  8009e6:	39 fa                	cmp    %edi,%edx
  8009e8:	75 df                	jne    8009c9 <memcmp+0x1d>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8009ea:	b8 00 00 00 00       	mov    $0x0,%eax
  8009ef:	eb 05                	jmp    8009f6 <memcmp+0x4a>
  8009f1:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009f6:	5b                   	pop    %ebx
  8009f7:	5e                   	pop    %esi
  8009f8:	5f                   	pop    %edi
  8009f9:	c9                   	leave  
  8009fa:	c3                   	ret    

008009fb <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009fb:	55                   	push   %ebp
  8009fc:	89 e5                	mov    %esp,%ebp
  8009fe:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800a01:	89 c2                	mov    %eax,%edx
  800a03:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a06:	39 d0                	cmp    %edx,%eax
  800a08:	73 12                	jae    800a1c <memfind+0x21>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a0a:	8a 4d 0c             	mov    0xc(%ebp),%cl
  800a0d:	38 08                	cmp    %cl,(%eax)
  800a0f:	75 06                	jne    800a17 <memfind+0x1c>
  800a11:	eb 09                	jmp    800a1c <memfind+0x21>
  800a13:	38 08                	cmp    %cl,(%eax)
  800a15:	74 05                	je     800a1c <memfind+0x21>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a17:	40                   	inc    %eax
  800a18:	39 c2                	cmp    %eax,%edx
  800a1a:	77 f7                	ja     800a13 <memfind+0x18>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a1c:	c9                   	leave  
  800a1d:	c3                   	ret    

00800a1e <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a1e:	55                   	push   %ebp
  800a1f:	89 e5                	mov    %esp,%ebp
  800a21:	57                   	push   %edi
  800a22:	56                   	push   %esi
  800a23:	53                   	push   %ebx
  800a24:	8b 55 08             	mov    0x8(%ebp),%edx
  800a27:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a2a:	eb 01                	jmp    800a2d <strtol+0xf>
		s++;
  800a2c:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a2d:	8a 02                	mov    (%edx),%al
  800a2f:	3c 20                	cmp    $0x20,%al
  800a31:	74 f9                	je     800a2c <strtol+0xe>
  800a33:	3c 09                	cmp    $0x9,%al
  800a35:	74 f5                	je     800a2c <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a37:	3c 2b                	cmp    $0x2b,%al
  800a39:	75 08                	jne    800a43 <strtol+0x25>
		s++;
  800a3b:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a3c:	bf 00 00 00 00       	mov    $0x0,%edi
  800a41:	eb 13                	jmp    800a56 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a43:	3c 2d                	cmp    $0x2d,%al
  800a45:	75 0a                	jne    800a51 <strtol+0x33>
		s++, neg = 1;
  800a47:	8d 52 01             	lea    0x1(%edx),%edx
  800a4a:	bf 01 00 00 00       	mov    $0x1,%edi
  800a4f:	eb 05                	jmp    800a56 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a51:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a56:	85 db                	test   %ebx,%ebx
  800a58:	74 05                	je     800a5f <strtol+0x41>
  800a5a:	83 fb 10             	cmp    $0x10,%ebx
  800a5d:	75 28                	jne    800a87 <strtol+0x69>
  800a5f:	8a 02                	mov    (%edx),%al
  800a61:	3c 30                	cmp    $0x30,%al
  800a63:	75 10                	jne    800a75 <strtol+0x57>
  800a65:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800a69:	75 0a                	jne    800a75 <strtol+0x57>
		s += 2, base = 16;
  800a6b:	83 c2 02             	add    $0x2,%edx
  800a6e:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a73:	eb 12                	jmp    800a87 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800a75:	85 db                	test   %ebx,%ebx
  800a77:	75 0e                	jne    800a87 <strtol+0x69>
  800a79:	3c 30                	cmp    $0x30,%al
  800a7b:	75 05                	jne    800a82 <strtol+0x64>
		s++, base = 8;
  800a7d:	42                   	inc    %edx
  800a7e:	b3 08                	mov    $0x8,%bl
  800a80:	eb 05                	jmp    800a87 <strtol+0x69>
	else if (base == 0)
		base = 10;
  800a82:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800a87:	b8 00 00 00 00       	mov    $0x0,%eax
  800a8c:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a8e:	8a 0a                	mov    (%edx),%cl
  800a90:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800a93:	80 fb 09             	cmp    $0x9,%bl
  800a96:	77 08                	ja     800aa0 <strtol+0x82>
			dig = *s - '0';
  800a98:	0f be c9             	movsbl %cl,%ecx
  800a9b:	83 e9 30             	sub    $0x30,%ecx
  800a9e:	eb 1e                	jmp    800abe <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800aa0:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800aa3:	80 fb 19             	cmp    $0x19,%bl
  800aa6:	77 08                	ja     800ab0 <strtol+0x92>
			dig = *s - 'a' + 10;
  800aa8:	0f be c9             	movsbl %cl,%ecx
  800aab:	83 e9 57             	sub    $0x57,%ecx
  800aae:	eb 0e                	jmp    800abe <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800ab0:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800ab3:	80 fb 19             	cmp    $0x19,%bl
  800ab6:	77 13                	ja     800acb <strtol+0xad>
			dig = *s - 'A' + 10;
  800ab8:	0f be c9             	movsbl %cl,%ecx
  800abb:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800abe:	39 f1                	cmp    %esi,%ecx
  800ac0:	7d 0d                	jge    800acf <strtol+0xb1>
			break;
		s++, val = (val * base) + dig;
  800ac2:	42                   	inc    %edx
  800ac3:	0f af c6             	imul   %esi,%eax
  800ac6:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  800ac9:	eb c3                	jmp    800a8e <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800acb:	89 c1                	mov    %eax,%ecx
  800acd:	eb 02                	jmp    800ad1 <strtol+0xb3>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800acf:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800ad1:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ad5:	74 05                	je     800adc <strtol+0xbe>
		*endptr = (char *) s;
  800ad7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800ada:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800adc:	85 ff                	test   %edi,%edi
  800ade:	74 04                	je     800ae4 <strtol+0xc6>
  800ae0:	89 c8                	mov    %ecx,%eax
  800ae2:	f7 d8                	neg    %eax
}
  800ae4:	5b                   	pop    %ebx
  800ae5:	5e                   	pop    %esi
  800ae6:	5f                   	pop    %edi
  800ae7:	c9                   	leave  
  800ae8:	c3                   	ret    
  800ae9:	00 00                	add    %al,(%eax)
	...

00800aec <syscall>:
	return ret;
}

static int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800aec:	55                   	push   %ebp
  800aed:	89 e5                	mov    %esp,%ebp
  800aef:	57                   	push   %edi
  800af0:	56                   	push   %esi
  800af1:	53                   	push   %ebx
  800af2:	83 ec 1c             	sub    $0x1c,%esp
  800af5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800af8:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800afb:	89 ca                	mov    %ecx,%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800afd:	8b 75 14             	mov    0x14(%ebp),%esi
  800b00:	8b 7d 10             	mov    0x10(%ebp),%edi
  800b03:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800b06:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b09:	cd 30                	int    $0x30
  800b0b:	89 c2                	mov    %eax,%edx
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b0d:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800b11:	74 1c                	je     800b2f <syscall+0x43>
  800b13:	85 c0                	test   %eax,%eax
  800b15:	7e 18                	jle    800b2f <syscall+0x43>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b17:	83 ec 0c             	sub    $0xc,%esp
  800b1a:	50                   	push   %eax
  800b1b:	ff 75 e4             	pushl  -0x1c(%ebp)
  800b1e:	68 3f 25 80 00       	push   $0x80253f
  800b23:	6a 42                	push   $0x42
  800b25:	68 5c 25 80 00       	push   $0x80255c
  800b2a:	e8 51 13 00 00       	call   801e80 <_panic>

	return ret;
}
  800b2f:	89 d0                	mov    %edx,%eax
  800b31:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b34:	5b                   	pop    %ebx
  800b35:	5e                   	pop    %esi
  800b36:	5f                   	pop    %edi
  800b37:	c9                   	leave  
  800b38:	c3                   	ret    

00800b39 <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{	
  800b39:	55                   	push   %ebp
  800b3a:	89 e5                	mov    %esp,%ebp
  800b3c:	83 ec 08             	sub    $0x8,%esp
	// my_sysenter(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
	// return;
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  800b3f:	6a 00                	push   $0x0
  800b41:	6a 00                	push   $0x0
  800b43:	6a 00                	push   $0x0
  800b45:	ff 75 0c             	pushl  0xc(%ebp)
  800b48:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b4b:	ba 00 00 00 00       	mov    $0x0,%edx
  800b50:	b8 00 00 00 00       	mov    $0x0,%eax
  800b55:	e8 92 ff ff ff       	call   800aec <syscall>
  800b5a:	83 c4 10             	add    $0x10,%esp
	return;
}
  800b5d:	c9                   	leave  
  800b5e:	c3                   	ret    

00800b5f <sys_cgetc>:

int
sys_cgetc(void)
{
  800b5f:	55                   	push   %ebp
  800b60:	89 e5                	mov    %esp,%ebp
  800b62:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_cgetc, 0, 0, 0, 0, 0, 0);
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  800b65:	6a 00                	push   $0x0
  800b67:	6a 00                	push   $0x0
  800b69:	6a 00                	push   $0x0
  800b6b:	6a 00                	push   $0x0
  800b6d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b72:	ba 00 00 00 00       	mov    $0x0,%edx
  800b77:	b8 01 00 00 00       	mov    $0x1,%eax
  800b7c:	e8 6b ff ff ff       	call   800aec <syscall>
}
  800b81:	c9                   	leave  
  800b82:	c3                   	ret    

00800b83 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b83:	55                   	push   %ebp
  800b84:	89 e5                	mov    %esp,%ebp
  800b86:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  800b89:	6a 00                	push   $0x0
  800b8b:	6a 00                	push   $0x0
  800b8d:	6a 00                	push   $0x0
  800b8f:	6a 00                	push   $0x0
  800b91:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b94:	ba 01 00 00 00       	mov    $0x1,%edx
  800b99:	b8 03 00 00 00       	mov    $0x3,%eax
  800b9e:	e8 49 ff ff ff       	call   800aec <syscall>
}
  800ba3:	c9                   	leave  
  800ba4:	c3                   	ret    

00800ba5 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800ba5:	55                   	push   %ebp
  800ba6:	89 e5                	mov    %esp,%ebp
  800ba8:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_getenvid, 0, 0, 0, 0, 0, 0);
	return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  800bab:	6a 00                	push   $0x0
  800bad:	6a 00                	push   $0x0
  800baf:	6a 00                	push   $0x0
  800bb1:	6a 00                	push   $0x0
  800bb3:	b9 00 00 00 00       	mov    $0x0,%ecx
  800bb8:	ba 00 00 00 00       	mov    $0x0,%edx
  800bbd:	b8 02 00 00 00       	mov    $0x2,%eax
  800bc2:	e8 25 ff ff ff       	call   800aec <syscall>
}
  800bc7:	c9                   	leave  
  800bc8:	c3                   	ret    

00800bc9 <sys_yield>:

void
sys_yield(void)
{
  800bc9:	55                   	push   %ebp
  800bca:	89 e5                	mov    %esp,%ebp
  800bcc:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  800bcf:	6a 00                	push   $0x0
  800bd1:	6a 00                	push   $0x0
  800bd3:	6a 00                	push   $0x0
  800bd5:	6a 00                	push   $0x0
  800bd7:	b9 00 00 00 00       	mov    $0x0,%ecx
  800bdc:	ba 00 00 00 00       	mov    $0x0,%edx
  800be1:	b8 0b 00 00 00       	mov    $0xb,%eax
  800be6:	e8 01 ff ff ff       	call   800aec <syscall>
  800beb:	83 c4 10             	add    $0x10,%esp
}
  800bee:	c9                   	leave  
  800bef:	c3                   	ret    

00800bf0 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800bf0:	55                   	push   %ebp
  800bf1:	89 e5                	mov    %esp,%ebp
  800bf3:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  800bf6:	6a 00                	push   $0x0
  800bf8:	6a 00                	push   $0x0
  800bfa:	ff 75 10             	pushl  0x10(%ebp)
  800bfd:	ff 75 0c             	pushl  0xc(%ebp)
  800c00:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c03:	ba 01 00 00 00       	mov    $0x1,%edx
  800c08:	b8 04 00 00 00       	mov    $0x4,%eax
  800c0d:	e8 da fe ff ff       	call   800aec <syscall>
}
  800c12:	c9                   	leave  
  800c13:	c3                   	ret    

00800c14 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c14:	55                   	push   %ebp
  800c15:	89 e5                	mov    %esp,%ebp
  800c17:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
  800c1a:	ff 75 18             	pushl  0x18(%ebp)
  800c1d:	ff 75 14             	pushl  0x14(%ebp)
  800c20:	ff 75 10             	pushl  0x10(%ebp)
  800c23:	ff 75 0c             	pushl  0xc(%ebp)
  800c26:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c29:	ba 01 00 00 00       	mov    $0x1,%edx
  800c2e:	b8 05 00 00 00       	mov    $0x5,%eax
  800c33:	e8 b4 fe ff ff       	call   800aec <syscall>
}
  800c38:	c9                   	leave  
  800c39:	c3                   	ret    

00800c3a <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c3a:	55                   	push   %ebp
  800c3b:	89 e5                	mov    %esp,%ebp
  800c3d:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  800c40:	6a 00                	push   $0x0
  800c42:	6a 00                	push   $0x0
  800c44:	6a 00                	push   $0x0
  800c46:	ff 75 0c             	pushl  0xc(%ebp)
  800c49:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c4c:	ba 01 00 00 00       	mov    $0x1,%edx
  800c51:	b8 06 00 00 00       	mov    $0x6,%eax
  800c56:	e8 91 fe ff ff       	call   800aec <syscall>
}
  800c5b:	c9                   	leave  
  800c5c:	c3                   	ret    

00800c5d <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c5d:	55                   	push   %ebp
  800c5e:	89 e5                	mov    %esp,%ebp
  800c60:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  800c63:	6a 00                	push   $0x0
  800c65:	6a 00                	push   $0x0
  800c67:	6a 00                	push   $0x0
  800c69:	ff 75 0c             	pushl  0xc(%ebp)
  800c6c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c6f:	ba 01 00 00 00       	mov    $0x1,%edx
  800c74:	b8 08 00 00 00       	mov    $0x8,%eax
  800c79:	e8 6e fe ff ff       	call   800aec <syscall>
}
  800c7e:	c9                   	leave  
  800c7f:	c3                   	ret    

00800c80 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800c80:	55                   	push   %ebp
  800c81:	89 e5                	mov    %esp,%ebp
  800c83:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
  800c86:	6a 00                	push   $0x0
  800c88:	6a 00                	push   $0x0
  800c8a:	6a 00                	push   $0x0
  800c8c:	ff 75 0c             	pushl  0xc(%ebp)
  800c8f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c92:	ba 01 00 00 00       	mov    $0x1,%edx
  800c97:	b8 09 00 00 00       	mov    $0x9,%eax
  800c9c:	e8 4b fe ff ff       	call   800aec <syscall>
}
  800ca1:	c9                   	leave  
  800ca2:	c3                   	ret    

00800ca3 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800ca3:	55                   	push   %ebp
  800ca4:	89 e5                	mov    %esp,%ebp
  800ca6:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  800ca9:	6a 00                	push   $0x0
  800cab:	6a 00                	push   $0x0
  800cad:	6a 00                	push   $0x0
  800caf:	ff 75 0c             	pushl  0xc(%ebp)
  800cb2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800cb5:	ba 01 00 00 00       	mov    $0x1,%edx
  800cba:	b8 0a 00 00 00       	mov    $0xa,%eax
  800cbf:	e8 28 fe ff ff       	call   800aec <syscall>
}
  800cc4:	c9                   	leave  
  800cc5:	c3                   	ret    

00800cc6 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800cc6:	55                   	push   %ebp
  800cc7:	89 e5                	mov    %esp,%ebp
  800cc9:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  800ccc:	6a 00                	push   $0x0
  800cce:	ff 75 14             	pushl  0x14(%ebp)
  800cd1:	ff 75 10             	pushl  0x10(%ebp)
  800cd4:	ff 75 0c             	pushl  0xc(%ebp)
  800cd7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800cda:	ba 00 00 00 00       	mov    $0x0,%edx
  800cdf:	b8 0c 00 00 00       	mov    $0xc,%eax
  800ce4:	e8 03 fe ff ff       	call   800aec <syscall>
}
  800ce9:	c9                   	leave  
  800cea:	c3                   	ret    

00800ceb <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800ceb:	55                   	push   %ebp
  800cec:	89 e5                	mov    %esp,%ebp
  800cee:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  800cf1:	6a 00                	push   $0x0
  800cf3:	6a 00                	push   $0x0
  800cf5:	6a 00                	push   $0x0
  800cf7:	6a 00                	push   $0x0
  800cf9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800cfc:	ba 01 00 00 00       	mov    $0x1,%edx
  800d01:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d06:	e8 e1 fd ff ff       	call   800aec <syscall>
}
  800d0b:	c9                   	leave  
  800d0c:	c3                   	ret    

00800d0d <sys_set_priority>:

int
sys_set_priority(envid_t envid, uint32_t new_priority)
{
  800d0d:	55                   	push   %ebp
  800d0e:	89 e5                	mov    %esp,%ebp
  800d10:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_set_priority, 0, envid, new_priority, 0, 0, 0);
  800d13:	6a 00                	push   $0x0
  800d15:	6a 00                	push   $0x0
  800d17:	6a 00                	push   $0x0
  800d19:	ff 75 0c             	pushl  0xc(%ebp)
  800d1c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d1f:	ba 00 00 00 00       	mov    $0x0,%edx
  800d24:	b8 0e 00 00 00       	mov    $0xe,%eax
  800d29:	e8 be fd ff ff       	call   800aec <syscall>
}
  800d2e:	c9                   	leave  
  800d2f:	c3                   	ret    

00800d30 <sys_exec>:

int
sys_exec(uint32_t eip, uint32_t esp, void * ph, uint32_t elf_phnum)
{
  800d30:	55                   	push   %ebp
  800d31:	89 e5                	mov    %esp,%ebp
  800d33:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_exec, 0, eip, esp, (uint32_t)ph, elf_phnum, 0);
  800d36:	6a 00                	push   $0x0
  800d38:	ff 75 14             	pushl  0x14(%ebp)
  800d3b:	ff 75 10             	pushl  0x10(%ebp)
  800d3e:	ff 75 0c             	pushl  0xc(%ebp)
  800d41:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d44:	ba 00 00 00 00       	mov    $0x0,%edx
  800d49:	b8 0f 00 00 00       	mov    $0xf,%eax
  800d4e:	e8 99 fd ff ff       	call   800aec <syscall>
} 
  800d53:	c9                   	leave  
  800d54:	c3                   	ret    

00800d55 <sys_join>:

// thread:
int
sys_join(envid_t envid)
{
  800d55:	55                   	push   %ebp
  800d56:	89 e5                	mov    %esp,%ebp
  800d58:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_join, 0, envid, 0, 0, 0, 0);
  800d5b:	6a 00                	push   $0x0
  800d5d:	6a 00                	push   $0x0
  800d5f:	6a 00                	push   $0x0
  800d61:	6a 00                	push   $0x0
  800d63:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d66:	ba 00 00 00 00       	mov    $0x0,%edx
  800d6b:	b8 11 00 00 00       	mov    $0x11,%eax
  800d70:	e8 77 fd ff ff       	call   800aec <syscall>
}
  800d75:	c9                   	leave  
  800d76:	c3                   	ret    

00800d77 <sys_getpid>:

envid_t
sys_getpid(void)
{
  800d77:	55                   	push   %ebp
  800d78:	89 e5                	mov    %esp,%ebp
  800d7a:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_getpid, 0, 0, 0, 0, 0, 0);
  800d7d:	6a 00                	push   $0x0
  800d7f:	6a 00                	push   $0x0
  800d81:	6a 00                	push   $0x0
  800d83:	6a 00                	push   $0x0
  800d85:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d8a:	ba 00 00 00 00       	mov    $0x0,%edx
  800d8f:	b8 10 00 00 00       	mov    $0x10,%eax
  800d94:	e8 53 fd ff ff       	call   800aec <syscall>
  800d99:	c9                   	leave  
  800d9a:	c3                   	ret    
	...

00800d9c <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800d9c:	55                   	push   %ebp
  800d9d:	89 e5                	mov    %esp,%ebp
  800d9f:	53                   	push   %ebx
  800da0:	83 ec 04             	sub    $0x4,%esp
  800da3:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800da6:	8b 18                	mov    (%eax),%ebx

	// LAB 4: Your code here.
	
	// cprintf("PAGE FAULT HANDLER, 0x%08x %d\n", (uint32_t)addr, err & FEC_WR);
	
	if ((err & FEC_WR) == 0)
  800da8:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800dac:	75 14                	jne    800dc2 <pgfault+0x26>
		panic("pgfault, the fault is not a write\n");
  800dae:	83 ec 04             	sub    $0x4,%esp
  800db1:	68 6c 25 80 00       	push   $0x80256c
  800db6:	6a 20                	push   $0x20
  800db8:	68 b0 26 80 00       	push   $0x8026b0
  800dbd:	e8 be 10 00 00       	call   801e80 <_panic>

	uint32_t uaddr = (uint32_t) addr;
	if ((uvpd[PDX(addr)] & PTE_P) == 0 || (uvpt[uaddr / PGSIZE] & PTE_COW) == 0) {
  800dc2:	89 d8                	mov    %ebx,%eax
  800dc4:	c1 e8 16             	shr    $0x16,%eax
  800dc7:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800dce:	a8 01                	test   $0x1,%al
  800dd0:	74 11                	je     800de3 <pgfault+0x47>
  800dd2:	89 d8                	mov    %ebx,%eax
  800dd4:	c1 e8 0c             	shr    $0xc,%eax
  800dd7:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800dde:	f6 c4 08             	test   $0x8,%ah
  800de1:	75 14                	jne    800df7 <pgfault+0x5b>
		panic("pgfault, not a copy-on-write page\n");
  800de3:	83 ec 04             	sub    $0x4,%esp
  800de6:	68 90 25 80 00       	push   $0x802590
  800deb:	6a 24                	push   $0x24
  800ded:	68 b0 26 80 00       	push   $0x8026b0
  800df2:	e8 89 10 00 00       	call   801e80 <_panic>
	//   No need to explicitly delete the old page's mapping.

	// LAB 4: Your code here.

	// static int sys_page_alloc(envid_t envid, void *va, int perm)
	r = sys_page_alloc(0, (void *)PFTEMP, PTE_W | PTE_U | PTE_P);
  800df7:	83 ec 04             	sub    $0x4,%esp
  800dfa:	6a 07                	push   $0x7
  800dfc:	68 00 f0 7f 00       	push   $0x7ff000
  800e01:	6a 00                	push   $0x0
  800e03:	e8 e8 fd ff ff       	call   800bf0 <sys_page_alloc>
	if (r < 0) panic("pgfault, sys_page_alloc error : %e\n", r);
  800e08:	83 c4 10             	add    $0x10,%esp
  800e0b:	85 c0                	test   %eax,%eax
  800e0d:	79 12                	jns    800e21 <pgfault+0x85>
  800e0f:	50                   	push   %eax
  800e10:	68 b4 25 80 00       	push   $0x8025b4
  800e15:	6a 32                	push   $0x32
  800e17:	68 b0 26 80 00       	push   $0x8026b0
  800e1c:	e8 5f 10 00 00       	call   801e80 <_panic>

	// Oh my god, I forget this at the first, it waste me a lot of time to debug!!!
	addr = ROUNDDOWN(addr, PGSIZE);
  800e21:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	
	memcpy(PFTEMP, addr, PGSIZE);
  800e27:	83 ec 04             	sub    $0x4,%esp
  800e2a:	68 00 10 00 00       	push   $0x1000
  800e2f:	53                   	push   %ebx
  800e30:	68 00 f0 7f 00       	push   $0x7ff000
  800e35:	e8 5f fb ff ff       	call   800999 <memcpy>
	
	r = sys_page_map(0, PFTEMP, 0, addr, PTE_W | PTE_U | PTE_P);
  800e3a:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800e41:	53                   	push   %ebx
  800e42:	6a 00                	push   $0x0
  800e44:	68 00 f0 7f 00       	push   $0x7ff000
  800e49:	6a 00                	push   $0x0
  800e4b:	e8 c4 fd ff ff       	call   800c14 <sys_page_map>
	if (r < 0) panic("pgfault, sys_page_map error : %e\n", r);
  800e50:	83 c4 20             	add    $0x20,%esp
  800e53:	85 c0                	test   %eax,%eax
  800e55:	79 12                	jns    800e69 <pgfault+0xcd>
  800e57:	50                   	push   %eax
  800e58:	68 d8 25 80 00       	push   $0x8025d8
  800e5d:	6a 3a                	push   $0x3a
  800e5f:	68 b0 26 80 00       	push   $0x8026b0
  800e64:	e8 17 10 00 00       	call   801e80 <_panic>

	return;
}
  800e69:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e6c:	c9                   	leave  
  800e6d:	c3                   	ret    

00800e6e <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800e6e:	55                   	push   %ebp
  800e6f:	89 e5                	mov    %esp,%ebp
  800e71:	57                   	push   %edi
  800e72:	56                   	push   %esi
  800e73:	53                   	push   %ebx
  800e74:	83 ec 28             	sub    $0x28,%esp
	// static int num = 0x100;

	// LAB 4: Your code here.
	set_pgfault_handler(pgfault);
  800e77:	68 9c 0d 80 00       	push   $0x800d9c
  800e7c:	e8 47 10 00 00       	call   801ec8 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  800e81:	ba 07 00 00 00       	mov    $0x7,%edx
  800e86:	89 d0                	mov    %edx,%eax
  800e88:	cd 30                	int    $0x30
  800e8a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800e8d:	89 c7                	mov    %eax,%edi
	int childpid = sys_exofork();
	if (childpid < 0) {
  800e8f:	83 c4 10             	add    $0x10,%esp
  800e92:	85 c0                	test   %eax,%eax
  800e94:	79 12                	jns    800ea8 <fork+0x3a>
		panic("fork sys_exofork error : %e\n", childpid);
  800e96:	50                   	push   %eax
  800e97:	68 bb 26 80 00       	push   $0x8026bb
  800e9c:	6a 7f                	push   $0x7f
  800e9e:	68 b0 26 80 00       	push   $0x8026b0
  800ea3:	e8 d8 0f 00 00       	call   801e80 <_panic>
	}
	int r;

	if (childpid == 0) {
  800ea8:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800eac:	75 20                	jne    800ece <fork+0x60>
		// child process
		// Remember to fix "thisenv" in the child process. ??? 
		thisenv = &envs[ENVX(sys_getenvid())];
  800eae:	e8 f2 fc ff ff       	call   800ba5 <sys_getenvid>
  800eb3:	25 ff 03 00 00       	and    $0x3ff,%eax
  800eb8:	89 c2                	mov    %eax,%edx
  800eba:	c1 e2 07             	shl    $0x7,%edx
  800ebd:	8d 84 82 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,4),%eax
  800ec4:	a3 04 40 80 00       	mov    %eax,0x804004
		// cprintf("fork child ok\n");
		return 0;
  800ec9:	e9 be 01 00 00       	jmp    80108c <fork+0x21e>
	if (childpid < 0) {
		panic("fork sys_exofork error : %e\n", childpid);
	}
	int r;

	if (childpid == 0) {
  800ece:	bb 00 00 00 00       	mov    $0x0,%ebx
	} else {
		// map page to new environment
		// kernel page is already in new environment
		uint32_t i;
		for (i = 0; i != UTOP; i += PGSIZE) 
		if ((uvpd[PDX(i)] & PTE_P) && (uvpt[i / PGSIZE] & PTE_P) && (uvpt[i / PGSIZE] & PTE_U)) {
  800ed3:	89 d8                	mov    %ebx,%eax
  800ed5:	c1 e8 16             	shr    $0x16,%eax
  800ed8:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800edf:	a8 01                	test   $0x1,%al
  800ee1:	0f 84 10 01 00 00    	je     800ff7 <fork+0x189>
  800ee7:	89 d8                	mov    %ebx,%eax
  800ee9:	c1 e8 0c             	shr    $0xc,%eax
  800eec:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800ef3:	f6 c2 01             	test   $0x1,%dl
  800ef6:	0f 84 fb 00 00 00    	je     800ff7 <fork+0x189>
  800efc:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800f03:	f6 c2 04             	test   $0x4,%dl
  800f06:	0f 84 eb 00 00 00    	je     800ff7 <fork+0x189>
//
static int
duppage(envid_t envid, unsigned pn)
{
	// do not dup exception stack
	if (pn * PGSIZE == UXSTACKTOP - PGSIZE) return 0;
  800f0c:	89 c6                	mov    %eax,%esi
  800f0e:	c1 e6 0c             	shl    $0xc,%esi
  800f11:	81 fe 00 f0 bf ee    	cmp    $0xeebff000,%esi
  800f17:	0f 84 da 00 00 00    	je     800ff7 <fork+0x189>

	int r;
	void * addr = (void *)(pn * PGSIZE);
    if (uvpt[pn] & PTE_SHARE) {
  800f1d:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800f24:	f6 c6 04             	test   $0x4,%dh
  800f27:	74 37                	je     800f60 <fork+0xf2>
        r = sys_page_map(0, addr, envid, addr, uvpt[pn] & PTE_SYSCALL);
  800f29:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f30:	83 ec 0c             	sub    $0xc,%esp
  800f33:	25 07 0e 00 00       	and    $0xe07,%eax
  800f38:	50                   	push   %eax
  800f39:	56                   	push   %esi
  800f3a:	57                   	push   %edi
  800f3b:	56                   	push   %esi
  800f3c:	6a 00                	push   $0x0
  800f3e:	e8 d1 fc ff ff       	call   800c14 <sys_page_map>
        if (r < 0) panic("duppage sys_page_map error : %e\n", r);
  800f43:	83 c4 20             	add    $0x20,%esp
  800f46:	85 c0                	test   %eax,%eax
  800f48:	0f 89 a9 00 00 00    	jns    800ff7 <fork+0x189>
  800f4e:	50                   	push   %eax
  800f4f:	68 fc 25 80 00       	push   $0x8025fc
  800f54:	6a 54                	push   $0x54
  800f56:	68 b0 26 80 00       	push   $0x8026b0
  800f5b:	e8 20 0f 00 00       	call   801e80 <_panic>
    } else
	if ((uvpt[pn] & PTE_W) || (uvpt[pn] & PTE_COW)) {
  800f60:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800f67:	f6 c2 02             	test   $0x2,%dl
  800f6a:	75 0c                	jne    800f78 <fork+0x10a>
  800f6c:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f73:	f6 c4 08             	test   $0x8,%ah
  800f76:	74 57                	je     800fcf <fork+0x161>
		// cow
		r = sys_page_map(0, addr, envid, addr, PTE_COW | PTE_P | PTE_U);
  800f78:	83 ec 0c             	sub    $0xc,%esp
  800f7b:	68 05 08 00 00       	push   $0x805
  800f80:	56                   	push   %esi
  800f81:	57                   	push   %edi
  800f82:	56                   	push   %esi
  800f83:	6a 00                	push   $0x0
  800f85:	e8 8a fc ff ff       	call   800c14 <sys_page_map>
		if (r < 0) panic("duppage sys_page_map error : %e\n", r);
  800f8a:	83 c4 20             	add    $0x20,%esp
  800f8d:	85 c0                	test   %eax,%eax
  800f8f:	79 12                	jns    800fa3 <fork+0x135>
  800f91:	50                   	push   %eax
  800f92:	68 fc 25 80 00       	push   $0x8025fc
  800f97:	6a 59                	push   $0x59
  800f99:	68 b0 26 80 00       	push   $0x8026b0
  800f9e:	e8 dd 0e 00 00       	call   801e80 <_panic>
		
		r = sys_page_map(0, addr, 0, addr, PTE_COW | PTE_P | PTE_U);
  800fa3:	83 ec 0c             	sub    $0xc,%esp
  800fa6:	68 05 08 00 00       	push   $0x805
  800fab:	56                   	push   %esi
  800fac:	6a 00                	push   $0x0
  800fae:	56                   	push   %esi
  800faf:	6a 00                	push   $0x0
  800fb1:	e8 5e fc ff ff       	call   800c14 <sys_page_map>
		if (r < 0) panic("duppage sys_page_map error : %e\n", r);
  800fb6:	83 c4 20             	add    $0x20,%esp
  800fb9:	85 c0                	test   %eax,%eax
  800fbb:	79 3a                	jns    800ff7 <fork+0x189>
  800fbd:	50                   	push   %eax
  800fbe:	68 fc 25 80 00       	push   $0x8025fc
  800fc3:	6a 5c                	push   $0x5c
  800fc5:	68 b0 26 80 00       	push   $0x8026b0
  800fca:	e8 b1 0e 00 00       	call   801e80 <_panic>
	} else {
		// read only
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U);
  800fcf:	83 ec 0c             	sub    $0xc,%esp
  800fd2:	6a 05                	push   $0x5
  800fd4:	56                   	push   %esi
  800fd5:	57                   	push   %edi
  800fd6:	56                   	push   %esi
  800fd7:	6a 00                	push   $0x0
  800fd9:	e8 36 fc ff ff       	call   800c14 <sys_page_map>
		if (r < 0) panic("duppage sys_page_map error : %e\n", r);
  800fde:	83 c4 20             	add    $0x20,%esp
  800fe1:	85 c0                	test   %eax,%eax
  800fe3:	79 12                	jns    800ff7 <fork+0x189>
  800fe5:	50                   	push   %eax
  800fe6:	68 fc 25 80 00       	push   $0x8025fc
  800feb:	6a 60                	push   $0x60
  800fed:	68 b0 26 80 00       	push   $0x8026b0
  800ff2:	e8 89 0e 00 00       	call   801e80 <_panic>
		return 0;
	} else {
		// map page to new environment
		// kernel page is already in new environment
		uint32_t i;
		for (i = 0; i != UTOP; i += PGSIZE) 
  800ff7:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  800ffd:	81 fb 00 00 c0 ee    	cmp    $0xeec00000,%ebx
  801003:	0f 85 ca fe ff ff    	jne    800ed3 <fork+0x65>
		if ((uvpd[PDX(i)] & PTE_P) && (uvpt[i / PGSIZE] & PTE_P) && (uvpt[i / PGSIZE] & PTE_U)) {
			duppage(childpid, i / PGSIZE);
		}

		// allocate exception stack
		r = sys_page_alloc(childpid, (void *)(UXSTACKTOP - PGSIZE), PTE_U | PTE_W | PTE_P);
  801009:	83 ec 04             	sub    $0x4,%esp
  80100c:	6a 07                	push   $0x7
  80100e:	68 00 f0 bf ee       	push   $0xeebff000
  801013:	ff 75 e4             	pushl  -0x1c(%ebp)
  801016:	e8 d5 fb ff ff       	call   800bf0 <sys_page_alloc>
		if (r < 0) panic("fork, sys_page_alloc user exception stack error : %e\n", r);
  80101b:	83 c4 10             	add    $0x10,%esp
  80101e:	85 c0                	test   %eax,%eax
  801020:	79 15                	jns    801037 <fork+0x1c9>
  801022:	50                   	push   %eax
  801023:	68 20 26 80 00       	push   $0x802620
  801028:	68 94 00 00 00       	push   $0x94
  80102d:	68 b0 26 80 00       	push   $0x8026b0
  801032:	e8 49 0e 00 00       	call   801e80 <_panic>

		// set user environment user page fault handler 
		extern void _pgfault_upcall(void);
		r = sys_env_set_pgfault_upcall(childpid, _pgfault_upcall);
  801037:	83 ec 08             	sub    $0x8,%esp
  80103a:	68 34 1f 80 00       	push   $0x801f34
  80103f:	ff 75 e4             	pushl  -0x1c(%ebp)
  801042:	e8 5c fc ff ff       	call   800ca3 <sys_env_set_pgfault_upcall>
		if (r < 0) panic("fork, set pgfault upcall fail : %e\n", r);
  801047:	83 c4 10             	add    $0x10,%esp
  80104a:	85 c0                	test   %eax,%eax
  80104c:	79 15                	jns    801063 <fork+0x1f5>
  80104e:	50                   	push   %eax
  80104f:	68 58 26 80 00       	push   $0x802658
  801054:	68 99 00 00 00       	push   $0x99
  801059:	68 b0 26 80 00       	push   $0x8026b0
  80105e:	e8 1d 0e 00 00       	call   801e80 <_panic>
		r = sys_set_priority(childpid, num);
		if (r < 0) panic("fork, set priority error\n");
		*/

		// mark the child as runnable and return
		r = sys_env_set_status(childpid, ENV_RUNNABLE);
  801063:	83 ec 08             	sub    $0x8,%esp
  801066:	6a 02                	push   $0x2
  801068:	ff 75 e4             	pushl  -0x1c(%ebp)
  80106b:	e8 ed fb ff ff       	call   800c5d <sys_env_set_status>
		if (r < 0) panic("fork, set child process to ENV_RUNNABLE error : %e\n", r);
  801070:	83 c4 10             	add    $0x10,%esp
  801073:	85 c0                	test   %eax,%eax
  801075:	79 15                	jns    80108c <fork+0x21e>
  801077:	50                   	push   %eax
  801078:	68 7c 26 80 00       	push   $0x80267c
  80107d:	68 a4 00 00 00       	push   $0xa4
  801082:	68 b0 26 80 00       	push   $0x8026b0
  801087:	e8 f4 0d 00 00       	call   801e80 <_panic>
		// cprintf("fork father ok!")
		return childpid;
	}

	panic("fork not implemented");
}
  80108c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80108f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801092:	5b                   	pop    %ebx
  801093:	5e                   	pop    %esi
  801094:	5f                   	pop    %edi
  801095:	c9                   	leave  
  801096:	c3                   	ret    

00801097 <sfork>:

// Challenge!
int
sfork(void)
{
  801097:	55                   	push   %ebp
  801098:	89 e5                	mov    %esp,%ebp
  80109a:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  80109d:	68 d8 26 80 00       	push   $0x8026d8
  8010a2:	68 b1 00 00 00       	push   $0xb1
  8010a7:	68 b0 26 80 00       	push   $0x8026b0
  8010ac:	e8 cf 0d 00 00       	call   801e80 <_panic>
  8010b1:	00 00                	add    %al,(%eax)
	...

008010b4 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8010b4:	55                   	push   %ebp
  8010b5:	89 e5                	mov    %esp,%ebp
  8010b7:	56                   	push   %esi
  8010b8:	53                   	push   %ebx
  8010b9:	8b 75 08             	mov    0x8(%ebp),%esi
  8010bc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8010bf:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// cprintf("0x%x 0x%x 0x%x\n", (uint32_t)from_env_store, (uint32_t)pg, (uint32_t)perm_store);
	int r;
	if (pg != NULL) {
  8010c2:	85 c0                	test   %eax,%eax
  8010c4:	74 0e                	je     8010d4 <ipc_recv+0x20>
		r = sys_ipc_recv(pg);
  8010c6:	83 ec 0c             	sub    $0xc,%esp
  8010c9:	50                   	push   %eax
  8010ca:	e8 1c fc ff ff       	call   800ceb <sys_ipc_recv>
  8010cf:	83 c4 10             	add    $0x10,%esp
  8010d2:	eb 10                	jmp    8010e4 <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv((void *)UTOP);
  8010d4:	83 ec 0c             	sub    $0xc,%esp
  8010d7:	68 00 00 c0 ee       	push   $0xeec00000
  8010dc:	e8 0a fc ff ff       	call   800ceb <sys_ipc_recv>
  8010e1:	83 c4 10             	add    $0x10,%esp
	}

	if (r == 0) {
  8010e4:	85 c0                	test   %eax,%eax
  8010e6:	75 26                	jne    80110e <ipc_recv+0x5a>
		if (from_env_store != NULL) *from_env_store = thisenv->env_ipc_from;
  8010e8:	85 f6                	test   %esi,%esi
  8010ea:	74 0a                	je     8010f6 <ipc_recv+0x42>
  8010ec:	a1 04 40 80 00       	mov    0x804004,%eax
  8010f1:	8b 40 74             	mov    0x74(%eax),%eax
  8010f4:	89 06                	mov    %eax,(%esi)
		if (perm_store != NULL) *perm_store = thisenv->env_ipc_perm;
  8010f6:	85 db                	test   %ebx,%ebx
  8010f8:	74 0a                	je     801104 <ipc_recv+0x50>
  8010fa:	a1 04 40 80 00       	mov    0x804004,%eax
  8010ff:	8b 40 78             	mov    0x78(%eax),%eax
  801102:	89 03                	mov    %eax,(%ebx)
		return thisenv->env_ipc_value;
  801104:	a1 04 40 80 00       	mov    0x804004,%eax
  801109:	8b 40 70             	mov    0x70(%eax),%eax
  80110c:	eb 14                	jmp    801122 <ipc_recv+0x6e>
	} else {
		// fails;
		if (from_env_store != NULL) *from_env_store = 0;
  80110e:	85 f6                	test   %esi,%esi
  801110:	74 06                	je     801118 <ipc_recv+0x64>
  801112:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if (perm_store != NULL) *perm_store = 0;
  801118:	85 db                	test   %ebx,%ebx
  80111a:	74 06                	je     801122 <ipc_recv+0x6e>
  80111c:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		return r;
	}
}
  801122:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801125:	5b                   	pop    %ebx
  801126:	5e                   	pop    %esi
  801127:	c9                   	leave  
  801128:	c3                   	ret    

00801129 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801129:	55                   	push   %ebp
  80112a:	89 e5                	mov    %esp,%ebp
  80112c:	57                   	push   %edi
  80112d:	56                   	push   %esi
  80112e:	53                   	push   %ebx
  80112f:	83 ec 0c             	sub    $0xc,%esp
  801132:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801135:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801138:	8b 75 14             	mov    0x14(%ebp),%esi
	// LAB 4: Your code here.
	// int sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
	int r;
	if (pg == NULL) pg = (void *)UTOP;
  80113b:	85 db                	test   %ebx,%ebx
  80113d:	75 25                	jne    801164 <ipc_send+0x3b>
  80113f:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
  801144:	eb 1e                	jmp    801164 <ipc_send+0x3b>
	
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) != 0) {
		if (r == -E_IPC_NOT_RECV) {
  801146:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801149:	75 07                	jne    801152 <ipc_send+0x29>
			// cprintf("Try Again and Again....\n");
			sys_yield();
  80114b:	e8 79 fa ff ff       	call   800bc9 <sys_yield>
  801150:	eb 12                	jmp    801164 <ipc_send+0x3b>
		} else {
			panic("ipc_send error %e\n", r);
  801152:	50                   	push   %eax
  801153:	68 ee 26 80 00       	push   $0x8026ee
  801158:	6a 43                	push   $0x43
  80115a:	68 01 27 80 00       	push   $0x802701
  80115f:	e8 1c 0d 00 00       	call   801e80 <_panic>
	// LAB 4: Your code here.
	// int sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
	int r;
	if (pg == NULL) pg = (void *)UTOP;
	
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) != 0) {
  801164:	56                   	push   %esi
  801165:	53                   	push   %ebx
  801166:	57                   	push   %edi
  801167:	ff 75 08             	pushl  0x8(%ebp)
  80116a:	e8 57 fb ff ff       	call   800cc6 <sys_ipc_try_send>
  80116f:	83 c4 10             	add    $0x10,%esp
  801172:	85 c0                	test   %eax,%eax
  801174:	75 d0                	jne    801146 <ipc_send+0x1d>
		} else {
			panic("ipc_send error %e\n", r);
		}
	}
	return;
}
  801176:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801179:	5b                   	pop    %ebx
  80117a:	5e                   	pop    %esi
  80117b:	5f                   	pop    %edi
  80117c:	c9                   	leave  
  80117d:	c3                   	ret    

0080117e <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80117e:	55                   	push   %ebp
  80117f:	89 e5                	mov    %esp,%ebp
  801181:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  801184:	39 0d 50 00 c0 ee    	cmp    %ecx,0xeec00050
  80118a:	74 1a                	je     8011a6 <ipc_find_env+0x28>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80118c:	b8 01 00 00 00       	mov    $0x1,%eax
		if (envs[i].env_type == type)
  801191:	89 c2                	mov    %eax,%edx
  801193:	c1 e2 07             	shl    $0x7,%edx
  801196:	8d 94 82 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,4),%edx
  80119d:	8b 52 50             	mov    0x50(%edx),%edx
  8011a0:	39 ca                	cmp    %ecx,%edx
  8011a2:	75 18                	jne    8011bc <ipc_find_env+0x3e>
  8011a4:	eb 05                	jmp    8011ab <ipc_find_env+0x2d>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8011a6:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
			return envs[i].env_id;
  8011ab:	89 c2                	mov    %eax,%edx
  8011ad:	c1 e2 07             	shl    $0x7,%edx
  8011b0:	8d 84 82 08 00 c0 ee 	lea    -0x113ffff8(%edx,%eax,4),%eax
  8011b7:	8b 40 40             	mov    0x40(%eax),%eax
  8011ba:	eb 0c                	jmp    8011c8 <ipc_find_env+0x4a>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8011bc:	40                   	inc    %eax
  8011bd:	3d 00 04 00 00       	cmp    $0x400,%eax
  8011c2:	75 cd                	jne    801191 <ipc_find_env+0x13>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8011c4:	66 b8 00 00          	mov    $0x0,%ax
}
  8011c8:	c9                   	leave  
  8011c9:	c3                   	ret    
	...

008011cc <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8011cc:	55                   	push   %ebp
  8011cd:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8011cf:	8b 45 08             	mov    0x8(%ebp),%eax
  8011d2:	05 00 00 00 30       	add    $0x30000000,%eax
  8011d7:	c1 e8 0c             	shr    $0xc,%eax
}
  8011da:	c9                   	leave  
  8011db:	c3                   	ret    

008011dc <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8011dc:	55                   	push   %ebp
  8011dd:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  8011df:	ff 75 08             	pushl  0x8(%ebp)
  8011e2:	e8 e5 ff ff ff       	call   8011cc <fd2num>
  8011e7:	83 c4 04             	add    $0x4,%esp
  8011ea:	05 20 00 0d 00       	add    $0xd0020,%eax
  8011ef:	c1 e0 0c             	shl    $0xc,%eax
}
  8011f2:	c9                   	leave  
  8011f3:	c3                   	ret    

008011f4 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8011f4:	55                   	push   %ebp
  8011f5:	89 e5                	mov    %esp,%ebp
  8011f7:	53                   	push   %ebx
  8011f8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8011fb:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  801200:	a8 01                	test   $0x1,%al
  801202:	74 34                	je     801238 <fd_alloc+0x44>
  801204:	a1 00 00 74 ef       	mov    0xef740000,%eax
  801209:	a8 01                	test   $0x1,%al
  80120b:	74 32                	je     80123f <fd_alloc+0x4b>
  80120d:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
  801212:	89 c1                	mov    %eax,%ecx
  801214:	89 c2                	mov    %eax,%edx
  801216:	c1 ea 16             	shr    $0x16,%edx
  801219:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801220:	f6 c2 01             	test   $0x1,%dl
  801223:	74 1f                	je     801244 <fd_alloc+0x50>
  801225:	89 c2                	mov    %eax,%edx
  801227:	c1 ea 0c             	shr    $0xc,%edx
  80122a:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801231:	f6 c2 01             	test   $0x1,%dl
  801234:	75 17                	jne    80124d <fd_alloc+0x59>
  801236:	eb 0c                	jmp    801244 <fd_alloc+0x50>
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  801238:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
  80123d:	eb 05                	jmp    801244 <fd_alloc+0x50>
  80123f:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
  801244:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  801246:	b8 00 00 00 00       	mov    $0x0,%eax
  80124b:	eb 17                	jmp    801264 <fd_alloc+0x70>
  80124d:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801252:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801257:	75 b9                	jne    801212 <fd_alloc+0x1e>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801259:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  80125f:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801264:	5b                   	pop    %ebx
  801265:	c9                   	leave  
  801266:	c3                   	ret    

00801267 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801267:	55                   	push   %ebp
  801268:	89 e5                	mov    %esp,%ebp
  80126a:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80126d:	83 f8 1f             	cmp    $0x1f,%eax
  801270:	77 36                	ja     8012a8 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801272:	05 00 00 0d 00       	add    $0xd0000,%eax
  801277:	c1 e0 0c             	shl    $0xc,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80127a:	89 c2                	mov    %eax,%edx
  80127c:	c1 ea 16             	shr    $0x16,%edx
  80127f:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801286:	f6 c2 01             	test   $0x1,%dl
  801289:	74 24                	je     8012af <fd_lookup+0x48>
  80128b:	89 c2                	mov    %eax,%edx
  80128d:	c1 ea 0c             	shr    $0xc,%edx
  801290:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801297:	f6 c2 01             	test   $0x1,%dl
  80129a:	74 1a                	je     8012b6 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80129c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80129f:	89 02                	mov    %eax,(%edx)
	return 0;
  8012a1:	b8 00 00 00 00       	mov    $0x0,%eax
  8012a6:	eb 13                	jmp    8012bb <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8012a8:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012ad:	eb 0c                	jmp    8012bb <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8012af:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012b4:	eb 05                	jmp    8012bb <fd_lookup+0x54>
  8012b6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8012bb:	c9                   	leave  
  8012bc:	c3                   	ret    

008012bd <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8012bd:	55                   	push   %ebp
  8012be:	89 e5                	mov    %esp,%ebp
  8012c0:	53                   	push   %ebx
  8012c1:	83 ec 04             	sub    $0x4,%esp
  8012c4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8012c7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  8012ca:	39 0d 04 30 80 00    	cmp    %ecx,0x803004
  8012d0:	74 0d                	je     8012df <dev_lookup+0x22>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8012d2:	b8 00 00 00 00       	mov    $0x0,%eax
  8012d7:	eb 14                	jmp    8012ed <dev_lookup+0x30>
		if (devtab[i]->dev_id == dev_id) {
  8012d9:	39 0a                	cmp    %ecx,(%edx)
  8012db:	75 10                	jne    8012ed <dev_lookup+0x30>
  8012dd:	eb 05                	jmp    8012e4 <dev_lookup+0x27>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8012df:	ba 04 30 80 00       	mov    $0x803004,%edx
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
  8012e4:	89 13                	mov    %edx,(%ebx)
			return 0;
  8012e6:	b8 00 00 00 00       	mov    $0x0,%eax
  8012eb:	eb 31                	jmp    80131e <dev_lookup+0x61>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8012ed:	40                   	inc    %eax
  8012ee:	8b 14 85 88 27 80 00 	mov    0x802788(,%eax,4),%edx
  8012f5:	85 d2                	test   %edx,%edx
  8012f7:	75 e0                	jne    8012d9 <dev_lookup+0x1c>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8012f9:	a1 04 40 80 00       	mov    0x804004,%eax
  8012fe:	8b 40 48             	mov    0x48(%eax),%eax
  801301:	83 ec 04             	sub    $0x4,%esp
  801304:	51                   	push   %ecx
  801305:	50                   	push   %eax
  801306:	68 0c 27 80 00       	push   $0x80270c
  80130b:	e8 a8 ee ff ff       	call   8001b8 <cprintf>
	*dev = 0;
  801310:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  801316:	83 c4 10             	add    $0x10,%esp
  801319:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80131e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801321:	c9                   	leave  
  801322:	c3                   	ret    

00801323 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801323:	55                   	push   %ebp
  801324:	89 e5                	mov    %esp,%ebp
  801326:	56                   	push   %esi
  801327:	53                   	push   %ebx
  801328:	83 ec 20             	sub    $0x20,%esp
  80132b:	8b 75 08             	mov    0x8(%ebp),%esi
  80132e:	8a 45 0c             	mov    0xc(%ebp),%al
  801331:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801334:	56                   	push   %esi
  801335:	e8 92 fe ff ff       	call   8011cc <fd2num>
  80133a:	8d 55 f4             	lea    -0xc(%ebp),%edx
  80133d:	89 14 24             	mov    %edx,(%esp)
  801340:	50                   	push   %eax
  801341:	e8 21 ff ff ff       	call   801267 <fd_lookup>
  801346:	89 c3                	mov    %eax,%ebx
  801348:	83 c4 08             	add    $0x8,%esp
  80134b:	85 c0                	test   %eax,%eax
  80134d:	78 05                	js     801354 <fd_close+0x31>
	    || fd != fd2)
  80134f:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801352:	74 0d                	je     801361 <fd_close+0x3e>
		return (must_exist ? r : 0);
  801354:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  801358:	75 48                	jne    8013a2 <fd_close+0x7f>
  80135a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80135f:	eb 41                	jmp    8013a2 <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801361:	83 ec 08             	sub    $0x8,%esp
  801364:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801367:	50                   	push   %eax
  801368:	ff 36                	pushl  (%esi)
  80136a:	e8 4e ff ff ff       	call   8012bd <dev_lookup>
  80136f:	89 c3                	mov    %eax,%ebx
  801371:	83 c4 10             	add    $0x10,%esp
  801374:	85 c0                	test   %eax,%eax
  801376:	78 1c                	js     801394 <fd_close+0x71>
		if (dev->dev_close)
  801378:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80137b:	8b 40 10             	mov    0x10(%eax),%eax
  80137e:	85 c0                	test   %eax,%eax
  801380:	74 0d                	je     80138f <fd_close+0x6c>
			r = (*dev->dev_close)(fd);
  801382:	83 ec 0c             	sub    $0xc,%esp
  801385:	56                   	push   %esi
  801386:	ff d0                	call   *%eax
  801388:	89 c3                	mov    %eax,%ebx
  80138a:	83 c4 10             	add    $0x10,%esp
  80138d:	eb 05                	jmp    801394 <fd_close+0x71>
		else
			r = 0;
  80138f:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801394:	83 ec 08             	sub    $0x8,%esp
  801397:	56                   	push   %esi
  801398:	6a 00                	push   $0x0
  80139a:	e8 9b f8 ff ff       	call   800c3a <sys_page_unmap>
	return r;
  80139f:	83 c4 10             	add    $0x10,%esp
}
  8013a2:	89 d8                	mov    %ebx,%eax
  8013a4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8013a7:	5b                   	pop    %ebx
  8013a8:	5e                   	pop    %esi
  8013a9:	c9                   	leave  
  8013aa:	c3                   	ret    

008013ab <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8013ab:	55                   	push   %ebp
  8013ac:	89 e5                	mov    %esp,%ebp
  8013ae:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8013b1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013b4:	50                   	push   %eax
  8013b5:	ff 75 08             	pushl  0x8(%ebp)
  8013b8:	e8 aa fe ff ff       	call   801267 <fd_lookup>
  8013bd:	83 c4 08             	add    $0x8,%esp
  8013c0:	85 c0                	test   %eax,%eax
  8013c2:	78 10                	js     8013d4 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  8013c4:	83 ec 08             	sub    $0x8,%esp
  8013c7:	6a 01                	push   $0x1
  8013c9:	ff 75 f4             	pushl  -0xc(%ebp)
  8013cc:	e8 52 ff ff ff       	call   801323 <fd_close>
  8013d1:	83 c4 10             	add    $0x10,%esp
}
  8013d4:	c9                   	leave  
  8013d5:	c3                   	ret    

008013d6 <close_all>:

void
close_all(void)
{
  8013d6:	55                   	push   %ebp
  8013d7:	89 e5                	mov    %esp,%ebp
  8013d9:	53                   	push   %ebx
  8013da:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8013dd:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8013e2:	83 ec 0c             	sub    $0xc,%esp
  8013e5:	53                   	push   %ebx
  8013e6:	e8 c0 ff ff ff       	call   8013ab <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8013eb:	43                   	inc    %ebx
  8013ec:	83 c4 10             	add    $0x10,%esp
  8013ef:	83 fb 20             	cmp    $0x20,%ebx
  8013f2:	75 ee                	jne    8013e2 <close_all+0xc>
		close(i);
}
  8013f4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013f7:	c9                   	leave  
  8013f8:	c3                   	ret    

008013f9 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8013f9:	55                   	push   %ebp
  8013fa:	89 e5                	mov    %esp,%ebp
  8013fc:	57                   	push   %edi
  8013fd:	56                   	push   %esi
  8013fe:	53                   	push   %ebx
  8013ff:	83 ec 2c             	sub    $0x2c,%esp
  801402:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801405:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801408:	50                   	push   %eax
  801409:	ff 75 08             	pushl  0x8(%ebp)
  80140c:	e8 56 fe ff ff       	call   801267 <fd_lookup>
  801411:	89 c3                	mov    %eax,%ebx
  801413:	83 c4 08             	add    $0x8,%esp
  801416:	85 c0                	test   %eax,%eax
  801418:	0f 88 c0 00 00 00    	js     8014de <dup+0xe5>
		return r;
	close(newfdnum);
  80141e:	83 ec 0c             	sub    $0xc,%esp
  801421:	57                   	push   %edi
  801422:	e8 84 ff ff ff       	call   8013ab <close>

	newfd = INDEX2FD(newfdnum);
  801427:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  80142d:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  801430:	83 c4 04             	add    $0x4,%esp
  801433:	ff 75 e4             	pushl  -0x1c(%ebp)
  801436:	e8 a1 fd ff ff       	call   8011dc <fd2data>
  80143b:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  80143d:	89 34 24             	mov    %esi,(%esp)
  801440:	e8 97 fd ff ff       	call   8011dc <fd2data>
  801445:	83 c4 10             	add    $0x10,%esp
  801448:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80144b:	89 d8                	mov    %ebx,%eax
  80144d:	c1 e8 16             	shr    $0x16,%eax
  801450:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801457:	a8 01                	test   $0x1,%al
  801459:	74 37                	je     801492 <dup+0x99>
  80145b:	89 d8                	mov    %ebx,%eax
  80145d:	c1 e8 0c             	shr    $0xc,%eax
  801460:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801467:	f6 c2 01             	test   $0x1,%dl
  80146a:	74 26                	je     801492 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80146c:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801473:	83 ec 0c             	sub    $0xc,%esp
  801476:	25 07 0e 00 00       	and    $0xe07,%eax
  80147b:	50                   	push   %eax
  80147c:	ff 75 d4             	pushl  -0x2c(%ebp)
  80147f:	6a 00                	push   $0x0
  801481:	53                   	push   %ebx
  801482:	6a 00                	push   $0x0
  801484:	e8 8b f7 ff ff       	call   800c14 <sys_page_map>
  801489:	89 c3                	mov    %eax,%ebx
  80148b:	83 c4 20             	add    $0x20,%esp
  80148e:	85 c0                	test   %eax,%eax
  801490:	78 2d                	js     8014bf <dup+0xc6>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801492:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801495:	89 c2                	mov    %eax,%edx
  801497:	c1 ea 0c             	shr    $0xc,%edx
  80149a:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8014a1:	83 ec 0c             	sub    $0xc,%esp
  8014a4:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  8014aa:	52                   	push   %edx
  8014ab:	56                   	push   %esi
  8014ac:	6a 00                	push   $0x0
  8014ae:	50                   	push   %eax
  8014af:	6a 00                	push   $0x0
  8014b1:	e8 5e f7 ff ff       	call   800c14 <sys_page_map>
  8014b6:	89 c3                	mov    %eax,%ebx
  8014b8:	83 c4 20             	add    $0x20,%esp
  8014bb:	85 c0                	test   %eax,%eax
  8014bd:	79 1d                	jns    8014dc <dup+0xe3>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8014bf:	83 ec 08             	sub    $0x8,%esp
  8014c2:	56                   	push   %esi
  8014c3:	6a 00                	push   $0x0
  8014c5:	e8 70 f7 ff ff       	call   800c3a <sys_page_unmap>
	sys_page_unmap(0, nva);
  8014ca:	83 c4 08             	add    $0x8,%esp
  8014cd:	ff 75 d4             	pushl  -0x2c(%ebp)
  8014d0:	6a 00                	push   $0x0
  8014d2:	e8 63 f7 ff ff       	call   800c3a <sys_page_unmap>
	return r;
  8014d7:	83 c4 10             	add    $0x10,%esp
  8014da:	eb 02                	jmp    8014de <dup+0xe5>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  8014dc:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  8014de:	89 d8                	mov    %ebx,%eax
  8014e0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8014e3:	5b                   	pop    %ebx
  8014e4:	5e                   	pop    %esi
  8014e5:	5f                   	pop    %edi
  8014e6:	c9                   	leave  
  8014e7:	c3                   	ret    

008014e8 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8014e8:	55                   	push   %ebp
  8014e9:	89 e5                	mov    %esp,%ebp
  8014eb:	53                   	push   %ebx
  8014ec:	83 ec 14             	sub    $0x14,%esp
  8014ef:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8014f2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014f5:	50                   	push   %eax
  8014f6:	53                   	push   %ebx
  8014f7:	e8 6b fd ff ff       	call   801267 <fd_lookup>
  8014fc:	83 c4 08             	add    $0x8,%esp
  8014ff:	85 c0                	test   %eax,%eax
  801501:	78 67                	js     80156a <read+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801503:	83 ec 08             	sub    $0x8,%esp
  801506:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801509:	50                   	push   %eax
  80150a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80150d:	ff 30                	pushl  (%eax)
  80150f:	e8 a9 fd ff ff       	call   8012bd <dev_lookup>
  801514:	83 c4 10             	add    $0x10,%esp
  801517:	85 c0                	test   %eax,%eax
  801519:	78 4f                	js     80156a <read+0x82>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80151b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80151e:	8b 50 08             	mov    0x8(%eax),%edx
  801521:	83 e2 03             	and    $0x3,%edx
  801524:	83 fa 01             	cmp    $0x1,%edx
  801527:	75 21                	jne    80154a <read+0x62>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801529:	a1 04 40 80 00       	mov    0x804004,%eax
  80152e:	8b 40 48             	mov    0x48(%eax),%eax
  801531:	83 ec 04             	sub    $0x4,%esp
  801534:	53                   	push   %ebx
  801535:	50                   	push   %eax
  801536:	68 4d 27 80 00       	push   $0x80274d
  80153b:	e8 78 ec ff ff       	call   8001b8 <cprintf>
		return -E_INVAL;
  801540:	83 c4 10             	add    $0x10,%esp
  801543:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801548:	eb 20                	jmp    80156a <read+0x82>
	}
	if (!dev->dev_read)
  80154a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80154d:	8b 52 08             	mov    0x8(%edx),%edx
  801550:	85 d2                	test   %edx,%edx
  801552:	74 11                	je     801565 <read+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801554:	83 ec 04             	sub    $0x4,%esp
  801557:	ff 75 10             	pushl  0x10(%ebp)
  80155a:	ff 75 0c             	pushl  0xc(%ebp)
  80155d:	50                   	push   %eax
  80155e:	ff d2                	call   *%edx
  801560:	83 c4 10             	add    $0x10,%esp
  801563:	eb 05                	jmp    80156a <read+0x82>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801565:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  80156a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80156d:	c9                   	leave  
  80156e:	c3                   	ret    

0080156f <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80156f:	55                   	push   %ebp
  801570:	89 e5                	mov    %esp,%ebp
  801572:	57                   	push   %edi
  801573:	56                   	push   %esi
  801574:	53                   	push   %ebx
  801575:	83 ec 0c             	sub    $0xc,%esp
  801578:	8b 7d 08             	mov    0x8(%ebp),%edi
  80157b:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80157e:	85 f6                	test   %esi,%esi
  801580:	74 31                	je     8015b3 <readn+0x44>
  801582:	b8 00 00 00 00       	mov    $0x0,%eax
  801587:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = read(fdnum, (char*)buf + tot, n - tot);
  80158c:	83 ec 04             	sub    $0x4,%esp
  80158f:	89 f2                	mov    %esi,%edx
  801591:	29 c2                	sub    %eax,%edx
  801593:	52                   	push   %edx
  801594:	03 45 0c             	add    0xc(%ebp),%eax
  801597:	50                   	push   %eax
  801598:	57                   	push   %edi
  801599:	e8 4a ff ff ff       	call   8014e8 <read>
		if (m < 0)
  80159e:	83 c4 10             	add    $0x10,%esp
  8015a1:	85 c0                	test   %eax,%eax
  8015a3:	78 17                	js     8015bc <readn+0x4d>
			return m;
		if (m == 0)
  8015a5:	85 c0                	test   %eax,%eax
  8015a7:	74 11                	je     8015ba <readn+0x4b>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8015a9:	01 c3                	add    %eax,%ebx
  8015ab:	89 d8                	mov    %ebx,%eax
  8015ad:	39 f3                	cmp    %esi,%ebx
  8015af:	72 db                	jb     80158c <readn+0x1d>
  8015b1:	eb 09                	jmp    8015bc <readn+0x4d>
  8015b3:	b8 00 00 00 00       	mov    $0x0,%eax
  8015b8:	eb 02                	jmp    8015bc <readn+0x4d>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  8015ba:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  8015bc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8015bf:	5b                   	pop    %ebx
  8015c0:	5e                   	pop    %esi
  8015c1:	5f                   	pop    %edi
  8015c2:	c9                   	leave  
  8015c3:	c3                   	ret    

008015c4 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8015c4:	55                   	push   %ebp
  8015c5:	89 e5                	mov    %esp,%ebp
  8015c7:	53                   	push   %ebx
  8015c8:	83 ec 14             	sub    $0x14,%esp
  8015cb:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015ce:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015d1:	50                   	push   %eax
  8015d2:	53                   	push   %ebx
  8015d3:	e8 8f fc ff ff       	call   801267 <fd_lookup>
  8015d8:	83 c4 08             	add    $0x8,%esp
  8015db:	85 c0                	test   %eax,%eax
  8015dd:	78 62                	js     801641 <write+0x7d>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015df:	83 ec 08             	sub    $0x8,%esp
  8015e2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015e5:	50                   	push   %eax
  8015e6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015e9:	ff 30                	pushl  (%eax)
  8015eb:	e8 cd fc ff ff       	call   8012bd <dev_lookup>
  8015f0:	83 c4 10             	add    $0x10,%esp
  8015f3:	85 c0                	test   %eax,%eax
  8015f5:	78 4a                	js     801641 <write+0x7d>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8015f7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015fa:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8015fe:	75 21                	jne    801621 <write+0x5d>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801600:	a1 04 40 80 00       	mov    0x804004,%eax
  801605:	8b 40 48             	mov    0x48(%eax),%eax
  801608:	83 ec 04             	sub    $0x4,%esp
  80160b:	53                   	push   %ebx
  80160c:	50                   	push   %eax
  80160d:	68 69 27 80 00       	push   $0x802769
  801612:	e8 a1 eb ff ff       	call   8001b8 <cprintf>
		return -E_INVAL;
  801617:	83 c4 10             	add    $0x10,%esp
  80161a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80161f:	eb 20                	jmp    801641 <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801621:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801624:	8b 52 0c             	mov    0xc(%edx),%edx
  801627:	85 d2                	test   %edx,%edx
  801629:	74 11                	je     80163c <write+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80162b:	83 ec 04             	sub    $0x4,%esp
  80162e:	ff 75 10             	pushl  0x10(%ebp)
  801631:	ff 75 0c             	pushl  0xc(%ebp)
  801634:	50                   	push   %eax
  801635:	ff d2                	call   *%edx
  801637:	83 c4 10             	add    $0x10,%esp
  80163a:	eb 05                	jmp    801641 <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80163c:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  801641:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801644:	c9                   	leave  
  801645:	c3                   	ret    

00801646 <seek>:

int
seek(int fdnum, off_t offset)
{
  801646:	55                   	push   %ebp
  801647:	89 e5                	mov    %esp,%ebp
  801649:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80164c:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80164f:	50                   	push   %eax
  801650:	ff 75 08             	pushl  0x8(%ebp)
  801653:	e8 0f fc ff ff       	call   801267 <fd_lookup>
  801658:	83 c4 08             	add    $0x8,%esp
  80165b:	85 c0                	test   %eax,%eax
  80165d:	78 0e                	js     80166d <seek+0x27>
		return r;
	fd->fd_offset = offset;
  80165f:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801662:	8b 55 0c             	mov    0xc(%ebp),%edx
  801665:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801668:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80166d:	c9                   	leave  
  80166e:	c3                   	ret    

0080166f <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80166f:	55                   	push   %ebp
  801670:	89 e5                	mov    %esp,%ebp
  801672:	53                   	push   %ebx
  801673:	83 ec 14             	sub    $0x14,%esp
  801676:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801679:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80167c:	50                   	push   %eax
  80167d:	53                   	push   %ebx
  80167e:	e8 e4 fb ff ff       	call   801267 <fd_lookup>
  801683:	83 c4 08             	add    $0x8,%esp
  801686:	85 c0                	test   %eax,%eax
  801688:	78 5f                	js     8016e9 <ftruncate+0x7a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80168a:	83 ec 08             	sub    $0x8,%esp
  80168d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801690:	50                   	push   %eax
  801691:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801694:	ff 30                	pushl  (%eax)
  801696:	e8 22 fc ff ff       	call   8012bd <dev_lookup>
  80169b:	83 c4 10             	add    $0x10,%esp
  80169e:	85 c0                	test   %eax,%eax
  8016a0:	78 47                	js     8016e9 <ftruncate+0x7a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8016a2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016a5:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8016a9:	75 21                	jne    8016cc <ftruncate+0x5d>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8016ab:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8016b0:	8b 40 48             	mov    0x48(%eax),%eax
  8016b3:	83 ec 04             	sub    $0x4,%esp
  8016b6:	53                   	push   %ebx
  8016b7:	50                   	push   %eax
  8016b8:	68 2c 27 80 00       	push   $0x80272c
  8016bd:	e8 f6 ea ff ff       	call   8001b8 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8016c2:	83 c4 10             	add    $0x10,%esp
  8016c5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8016ca:	eb 1d                	jmp    8016e9 <ftruncate+0x7a>
	}
	if (!dev->dev_trunc)
  8016cc:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8016cf:	8b 52 18             	mov    0x18(%edx),%edx
  8016d2:	85 d2                	test   %edx,%edx
  8016d4:	74 0e                	je     8016e4 <ftruncate+0x75>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8016d6:	83 ec 08             	sub    $0x8,%esp
  8016d9:	ff 75 0c             	pushl  0xc(%ebp)
  8016dc:	50                   	push   %eax
  8016dd:	ff d2                	call   *%edx
  8016df:	83 c4 10             	add    $0x10,%esp
  8016e2:	eb 05                	jmp    8016e9 <ftruncate+0x7a>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8016e4:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  8016e9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016ec:	c9                   	leave  
  8016ed:	c3                   	ret    

008016ee <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8016ee:	55                   	push   %ebp
  8016ef:	89 e5                	mov    %esp,%ebp
  8016f1:	53                   	push   %ebx
  8016f2:	83 ec 14             	sub    $0x14,%esp
  8016f5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016f8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016fb:	50                   	push   %eax
  8016fc:	ff 75 08             	pushl  0x8(%ebp)
  8016ff:	e8 63 fb ff ff       	call   801267 <fd_lookup>
  801704:	83 c4 08             	add    $0x8,%esp
  801707:	85 c0                	test   %eax,%eax
  801709:	78 52                	js     80175d <fstat+0x6f>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80170b:	83 ec 08             	sub    $0x8,%esp
  80170e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801711:	50                   	push   %eax
  801712:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801715:	ff 30                	pushl  (%eax)
  801717:	e8 a1 fb ff ff       	call   8012bd <dev_lookup>
  80171c:	83 c4 10             	add    $0x10,%esp
  80171f:	85 c0                	test   %eax,%eax
  801721:	78 3a                	js     80175d <fstat+0x6f>
		return r;
	if (!dev->dev_stat)
  801723:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801726:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80172a:	74 2c                	je     801758 <fstat+0x6a>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80172c:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80172f:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801736:	00 00 00 
	stat->st_isdir = 0;
  801739:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801740:	00 00 00 
	stat->st_dev = dev;
  801743:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801749:	83 ec 08             	sub    $0x8,%esp
  80174c:	53                   	push   %ebx
  80174d:	ff 75 f0             	pushl  -0x10(%ebp)
  801750:	ff 50 14             	call   *0x14(%eax)
  801753:	83 c4 10             	add    $0x10,%esp
  801756:	eb 05                	jmp    80175d <fstat+0x6f>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801758:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  80175d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801760:	c9                   	leave  
  801761:	c3                   	ret    

00801762 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801762:	55                   	push   %ebp
  801763:	89 e5                	mov    %esp,%ebp
  801765:	56                   	push   %esi
  801766:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801767:	83 ec 08             	sub    $0x8,%esp
  80176a:	6a 00                	push   $0x0
  80176c:	ff 75 08             	pushl  0x8(%ebp)
  80176f:	e8 78 01 00 00       	call   8018ec <open>
  801774:	89 c3                	mov    %eax,%ebx
  801776:	83 c4 10             	add    $0x10,%esp
  801779:	85 c0                	test   %eax,%eax
  80177b:	78 1b                	js     801798 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  80177d:	83 ec 08             	sub    $0x8,%esp
  801780:	ff 75 0c             	pushl  0xc(%ebp)
  801783:	50                   	push   %eax
  801784:	e8 65 ff ff ff       	call   8016ee <fstat>
  801789:	89 c6                	mov    %eax,%esi
	close(fd);
  80178b:	89 1c 24             	mov    %ebx,(%esp)
  80178e:	e8 18 fc ff ff       	call   8013ab <close>
	return r;
  801793:	83 c4 10             	add    $0x10,%esp
  801796:	89 f3                	mov    %esi,%ebx
}
  801798:	89 d8                	mov    %ebx,%eax
  80179a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80179d:	5b                   	pop    %ebx
  80179e:	5e                   	pop    %esi
  80179f:	c9                   	leave  
  8017a0:	c3                   	ret    
  8017a1:	00 00                	add    %al,(%eax)
	...

008017a4 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8017a4:	55                   	push   %ebp
  8017a5:	89 e5                	mov    %esp,%ebp
  8017a7:	56                   	push   %esi
  8017a8:	53                   	push   %ebx
  8017a9:	89 c3                	mov    %eax,%ebx
  8017ab:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  8017ad:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8017b4:	75 12                	jne    8017c8 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8017b6:	83 ec 0c             	sub    $0xc,%esp
  8017b9:	6a 01                	push   $0x1
  8017bb:	e8 be f9 ff ff       	call   80117e <ipc_find_env>
  8017c0:	a3 00 40 80 00       	mov    %eax,0x804000
  8017c5:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8017c8:	6a 07                	push   $0x7
  8017ca:	68 00 50 80 00       	push   $0x805000
  8017cf:	53                   	push   %ebx
  8017d0:	ff 35 00 40 80 00    	pushl  0x804000
  8017d6:	e8 4e f9 ff ff       	call   801129 <ipc_send>
	
	return ipc_recv(NULL, dstva, NULL);
  8017db:	83 c4 0c             	add    $0xc,%esp
  8017de:	6a 00                	push   $0x0
  8017e0:	56                   	push   %esi
  8017e1:	6a 00                	push   $0x0
  8017e3:	e8 cc f8 ff ff       	call   8010b4 <ipc_recv>
}
  8017e8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017eb:	5b                   	pop    %ebx
  8017ec:	5e                   	pop    %esi
  8017ed:	c9                   	leave  
  8017ee:	c3                   	ret    

008017ef <devfile_stat>:
}


static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8017ef:	55                   	push   %ebp
  8017f0:	89 e5                	mov    %esp,%ebp
  8017f2:	53                   	push   %ebx
  8017f3:	83 ec 04             	sub    $0x4,%esp
  8017f6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8017f9:	8b 45 08             	mov    0x8(%ebp),%eax
  8017fc:	8b 40 0c             	mov    0xc(%eax),%eax
  8017ff:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0) {
  801804:	ba 00 00 00 00       	mov    $0x0,%edx
  801809:	b8 05 00 00 00       	mov    $0x5,%eax
  80180e:	e8 91 ff ff ff       	call   8017a4 <fsipc>
  801813:	85 c0                	test   %eax,%eax
  801815:	78 2c                	js     801843 <devfile_stat+0x54>
		return r;
	}
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801817:	83 ec 08             	sub    $0x8,%esp
  80181a:	68 00 50 80 00       	push   $0x805000
  80181f:	53                   	push   %ebx
  801820:	e8 49 ef ff ff       	call   80076e <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801825:	a1 80 50 80 00       	mov    0x805080,%eax
  80182a:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801830:	a1 84 50 80 00       	mov    0x805084,%eax
  801835:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80183b:	83 c4 10             	add    $0x10,%esp
  80183e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801843:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801846:	c9                   	leave  
  801847:	c3                   	ret    

00801848 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801848:	55                   	push   %ebp
  801849:	89 e5                	mov    %esp,%ebp
  80184b:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80184e:	8b 45 08             	mov    0x8(%ebp),%eax
  801851:	8b 40 0c             	mov    0xc(%eax),%eax
  801854:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801859:	ba 00 00 00 00       	mov    $0x0,%edx
  80185e:	b8 06 00 00 00       	mov    $0x6,%eax
  801863:	e8 3c ff ff ff       	call   8017a4 <fsipc>
}
  801868:	c9                   	leave  
  801869:	c3                   	ret    

0080186a <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  80186a:	55                   	push   %ebp
  80186b:	89 e5                	mov    %esp,%ebp
  80186d:	56                   	push   %esi
  80186e:	53                   	push   %ebx
  80186f:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801872:	8b 45 08             	mov    0x8(%ebp),%eax
  801875:	8b 40 0c             	mov    0xc(%eax),%eax
  801878:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  80187d:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801883:	ba 00 00 00 00       	mov    $0x0,%edx
  801888:	b8 03 00 00 00       	mov    $0x3,%eax
  80188d:	e8 12 ff ff ff       	call   8017a4 <fsipc>
  801892:	89 c3                	mov    %eax,%ebx
  801894:	85 c0                	test   %eax,%eax
  801896:	78 4b                	js     8018e3 <devfile_read+0x79>
		return r;
	assert(r <= n);
  801898:	39 c6                	cmp    %eax,%esi
  80189a:	73 16                	jae    8018b2 <devfile_read+0x48>
  80189c:	68 98 27 80 00       	push   $0x802798
  8018a1:	68 9f 27 80 00       	push   $0x80279f
  8018a6:	6a 7d                	push   $0x7d
  8018a8:	68 b4 27 80 00       	push   $0x8027b4
  8018ad:	e8 ce 05 00 00       	call   801e80 <_panic>
	assert(r <= PGSIZE);
  8018b2:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8018b7:	7e 16                	jle    8018cf <devfile_read+0x65>
  8018b9:	68 bf 27 80 00       	push   $0x8027bf
  8018be:	68 9f 27 80 00       	push   $0x80279f
  8018c3:	6a 7e                	push   $0x7e
  8018c5:	68 b4 27 80 00       	push   $0x8027b4
  8018ca:	e8 b1 05 00 00       	call   801e80 <_panic>
	memmove(buf, &fsipcbuf, r);
  8018cf:	83 ec 04             	sub    $0x4,%esp
  8018d2:	50                   	push   %eax
  8018d3:	68 00 50 80 00       	push   $0x805000
  8018d8:	ff 75 0c             	pushl  0xc(%ebp)
  8018db:	e8 4f f0 ff ff       	call   80092f <memmove>
	return r;
  8018e0:	83 c4 10             	add    $0x10,%esp
}
  8018e3:	89 d8                	mov    %ebx,%eax
  8018e5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018e8:	5b                   	pop    %ebx
  8018e9:	5e                   	pop    %esi
  8018ea:	c9                   	leave  
  8018eb:	c3                   	ret    

008018ec <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8018ec:	55                   	push   %ebp
  8018ed:	89 e5                	mov    %esp,%ebp
  8018ef:	56                   	push   %esi
  8018f0:	53                   	push   %ebx
  8018f1:	83 ec 1c             	sub    $0x1c,%esp
  8018f4:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8018f7:	56                   	push   %esi
  8018f8:	e8 1f ee ff ff       	call   80071c <strlen>
  8018fd:	83 c4 10             	add    $0x10,%esp
  801900:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801905:	7f 65                	jg     80196c <open+0x80>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801907:	83 ec 0c             	sub    $0xc,%esp
  80190a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80190d:	50                   	push   %eax
  80190e:	e8 e1 f8 ff ff       	call   8011f4 <fd_alloc>
  801913:	89 c3                	mov    %eax,%ebx
  801915:	83 c4 10             	add    $0x10,%esp
  801918:	85 c0                	test   %eax,%eax
  80191a:	78 55                	js     801971 <open+0x85>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  80191c:	83 ec 08             	sub    $0x8,%esp
  80191f:	56                   	push   %esi
  801920:	68 00 50 80 00       	push   $0x805000
  801925:	e8 44 ee ff ff       	call   80076e <strcpy>
	fsipcbuf.open.req_omode = mode;
  80192a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80192d:	a3 00 54 80 00       	mov    %eax,0x805400



	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801932:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801935:	b8 01 00 00 00       	mov    $0x1,%eax
  80193a:	e8 65 fe ff ff       	call   8017a4 <fsipc>
  80193f:	89 c3                	mov    %eax,%ebx
  801941:	83 c4 10             	add    $0x10,%esp
  801944:	85 c0                	test   %eax,%eax
  801946:	79 12                	jns    80195a <open+0x6e>
		fd_close(fd, 0);
  801948:	83 ec 08             	sub    $0x8,%esp
  80194b:	6a 00                	push   $0x0
  80194d:	ff 75 f4             	pushl  -0xc(%ebp)
  801950:	e8 ce f9 ff ff       	call   801323 <fd_close>
		return r;
  801955:	83 c4 10             	add    $0x10,%esp
  801958:	eb 17                	jmp    801971 <open+0x85>
	}

	return fd2num(fd);
  80195a:	83 ec 0c             	sub    $0xc,%esp
  80195d:	ff 75 f4             	pushl  -0xc(%ebp)
  801960:	e8 67 f8 ff ff       	call   8011cc <fd2num>
  801965:	89 c3                	mov    %eax,%ebx
  801967:	83 c4 10             	add    $0x10,%esp
  80196a:	eb 05                	jmp    801971 <open+0x85>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  80196c:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801971:	89 d8                	mov    %ebx,%eax
  801973:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801976:	5b                   	pop    %ebx
  801977:	5e                   	pop    %esi
  801978:	c9                   	leave  
  801979:	c3                   	ret    
	...

0080197c <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  80197c:	55                   	push   %ebp
  80197d:	89 e5                	mov    %esp,%ebp
  80197f:	56                   	push   %esi
  801980:	53                   	push   %ebx
  801981:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801984:	83 ec 0c             	sub    $0xc,%esp
  801987:	ff 75 08             	pushl  0x8(%ebp)
  80198a:	e8 4d f8 ff ff       	call   8011dc <fd2data>
  80198f:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  801991:	83 c4 08             	add    $0x8,%esp
  801994:	68 cb 27 80 00       	push   $0x8027cb
  801999:	56                   	push   %esi
  80199a:	e8 cf ed ff ff       	call   80076e <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  80199f:	8b 43 04             	mov    0x4(%ebx),%eax
  8019a2:	2b 03                	sub    (%ebx),%eax
  8019a4:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  8019aa:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  8019b1:	00 00 00 
	stat->st_dev = &devpipe;
  8019b4:	c7 86 88 00 00 00 20 	movl   $0x803020,0x88(%esi)
  8019bb:	30 80 00 
	return 0;
}
  8019be:	b8 00 00 00 00       	mov    $0x0,%eax
  8019c3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8019c6:	5b                   	pop    %ebx
  8019c7:	5e                   	pop    %esi
  8019c8:	c9                   	leave  
  8019c9:	c3                   	ret    

008019ca <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8019ca:	55                   	push   %ebp
  8019cb:	89 e5                	mov    %esp,%ebp
  8019cd:	53                   	push   %ebx
  8019ce:	83 ec 0c             	sub    $0xc,%esp
  8019d1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8019d4:	53                   	push   %ebx
  8019d5:	6a 00                	push   $0x0
  8019d7:	e8 5e f2 ff ff       	call   800c3a <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8019dc:	89 1c 24             	mov    %ebx,(%esp)
  8019df:	e8 f8 f7 ff ff       	call   8011dc <fd2data>
  8019e4:	83 c4 08             	add    $0x8,%esp
  8019e7:	50                   	push   %eax
  8019e8:	6a 00                	push   $0x0
  8019ea:	e8 4b f2 ff ff       	call   800c3a <sys_page_unmap>
}
  8019ef:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019f2:	c9                   	leave  
  8019f3:	c3                   	ret    

008019f4 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8019f4:	55                   	push   %ebp
  8019f5:	89 e5                	mov    %esp,%ebp
  8019f7:	57                   	push   %edi
  8019f8:	56                   	push   %esi
  8019f9:	53                   	push   %ebx
  8019fa:	83 ec 1c             	sub    $0x1c,%esp
  8019fd:	89 c7                	mov    %eax,%edi
  8019ff:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801a02:	a1 04 40 80 00       	mov    0x804004,%eax
  801a07:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801a0a:	83 ec 0c             	sub    $0xc,%esp
  801a0d:	57                   	push   %edi
  801a0e:	e8 49 05 00 00       	call   801f5c <pageref>
  801a13:	89 c6                	mov    %eax,%esi
  801a15:	83 c4 04             	add    $0x4,%esp
  801a18:	ff 75 e4             	pushl  -0x1c(%ebp)
  801a1b:	e8 3c 05 00 00       	call   801f5c <pageref>
  801a20:	83 c4 10             	add    $0x10,%esp
  801a23:	39 c6                	cmp    %eax,%esi
  801a25:	0f 94 c0             	sete   %al
  801a28:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  801a2b:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801a31:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801a34:	39 cb                	cmp    %ecx,%ebx
  801a36:	75 08                	jne    801a40 <_pipeisclosed+0x4c>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  801a38:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a3b:	5b                   	pop    %ebx
  801a3c:	5e                   	pop    %esi
  801a3d:	5f                   	pop    %edi
  801a3e:	c9                   	leave  
  801a3f:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  801a40:	83 f8 01             	cmp    $0x1,%eax
  801a43:	75 bd                	jne    801a02 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801a45:	8b 42 58             	mov    0x58(%edx),%eax
  801a48:	6a 01                	push   $0x1
  801a4a:	50                   	push   %eax
  801a4b:	53                   	push   %ebx
  801a4c:	68 d2 27 80 00       	push   $0x8027d2
  801a51:	e8 62 e7 ff ff       	call   8001b8 <cprintf>
  801a56:	83 c4 10             	add    $0x10,%esp
  801a59:	eb a7                	jmp    801a02 <_pipeisclosed+0xe>

00801a5b <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801a5b:	55                   	push   %ebp
  801a5c:	89 e5                	mov    %esp,%ebp
  801a5e:	57                   	push   %edi
  801a5f:	56                   	push   %esi
  801a60:	53                   	push   %ebx
  801a61:	83 ec 28             	sub    $0x28,%esp
  801a64:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801a67:	56                   	push   %esi
  801a68:	e8 6f f7 ff ff       	call   8011dc <fd2data>
  801a6d:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801a6f:	83 c4 10             	add    $0x10,%esp
  801a72:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801a76:	75 4a                	jne    801ac2 <devpipe_write+0x67>
  801a78:	bf 00 00 00 00       	mov    $0x0,%edi
  801a7d:	eb 56                	jmp    801ad5 <devpipe_write+0x7a>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801a7f:	89 da                	mov    %ebx,%edx
  801a81:	89 f0                	mov    %esi,%eax
  801a83:	e8 6c ff ff ff       	call   8019f4 <_pipeisclosed>
  801a88:	85 c0                	test   %eax,%eax
  801a8a:	75 4d                	jne    801ad9 <devpipe_write+0x7e>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801a8c:	e8 38 f1 ff ff       	call   800bc9 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801a91:	8b 43 04             	mov    0x4(%ebx),%eax
  801a94:	8b 13                	mov    (%ebx),%edx
  801a96:	83 c2 20             	add    $0x20,%edx
  801a99:	39 d0                	cmp    %edx,%eax
  801a9b:	73 e2                	jae    801a7f <devpipe_write+0x24>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801a9d:	89 c2                	mov    %eax,%edx
  801a9f:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  801aa5:	79 05                	jns    801aac <devpipe_write+0x51>
  801aa7:	4a                   	dec    %edx
  801aa8:	83 ca e0             	or     $0xffffffe0,%edx
  801aab:	42                   	inc    %edx
  801aac:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801aaf:	8a 0c 39             	mov    (%ecx,%edi,1),%cl
  801ab2:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801ab6:	40                   	inc    %eax
  801ab7:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801aba:	47                   	inc    %edi
  801abb:	39 7d 10             	cmp    %edi,0x10(%ebp)
  801abe:	77 07                	ja     801ac7 <devpipe_write+0x6c>
  801ac0:	eb 13                	jmp    801ad5 <devpipe_write+0x7a>
  801ac2:	bf 00 00 00 00       	mov    $0x0,%edi
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801ac7:	8b 43 04             	mov    0x4(%ebx),%eax
  801aca:	8b 13                	mov    (%ebx),%edx
  801acc:	83 c2 20             	add    $0x20,%edx
  801acf:	39 d0                	cmp    %edx,%eax
  801ad1:	73 ac                	jae    801a7f <devpipe_write+0x24>
  801ad3:	eb c8                	jmp    801a9d <devpipe_write+0x42>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801ad5:	89 f8                	mov    %edi,%eax
  801ad7:	eb 05                	jmp    801ade <devpipe_write+0x83>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801ad9:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801ade:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ae1:	5b                   	pop    %ebx
  801ae2:	5e                   	pop    %esi
  801ae3:	5f                   	pop    %edi
  801ae4:	c9                   	leave  
  801ae5:	c3                   	ret    

00801ae6 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801ae6:	55                   	push   %ebp
  801ae7:	89 e5                	mov    %esp,%ebp
  801ae9:	57                   	push   %edi
  801aea:	56                   	push   %esi
  801aeb:	53                   	push   %ebx
  801aec:	83 ec 18             	sub    $0x18,%esp
  801aef:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801af2:	57                   	push   %edi
  801af3:	e8 e4 f6 ff ff       	call   8011dc <fd2data>
  801af8:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801afa:	83 c4 10             	add    $0x10,%esp
  801afd:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801b01:	75 44                	jne    801b47 <devpipe_read+0x61>
  801b03:	be 00 00 00 00       	mov    $0x0,%esi
  801b08:	eb 4f                	jmp    801b59 <devpipe_read+0x73>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
				return i;
  801b0a:	89 f0                	mov    %esi,%eax
  801b0c:	eb 54                	jmp    801b62 <devpipe_read+0x7c>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801b0e:	89 da                	mov    %ebx,%edx
  801b10:	89 f8                	mov    %edi,%eax
  801b12:	e8 dd fe ff ff       	call   8019f4 <_pipeisclosed>
  801b17:	85 c0                	test   %eax,%eax
  801b19:	75 42                	jne    801b5d <devpipe_read+0x77>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801b1b:	e8 a9 f0 ff ff       	call   800bc9 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801b20:	8b 03                	mov    (%ebx),%eax
  801b22:	3b 43 04             	cmp    0x4(%ebx),%eax
  801b25:	74 e7                	je     801b0e <devpipe_read+0x28>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801b27:	25 1f 00 00 80       	and    $0x8000001f,%eax
  801b2c:	79 05                	jns    801b33 <devpipe_read+0x4d>
  801b2e:	48                   	dec    %eax
  801b2f:	83 c8 e0             	or     $0xffffffe0,%eax
  801b32:	40                   	inc    %eax
  801b33:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  801b37:	8b 55 0c             	mov    0xc(%ebp),%edx
  801b3a:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  801b3d:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b3f:	46                   	inc    %esi
  801b40:	39 75 10             	cmp    %esi,0x10(%ebp)
  801b43:	77 07                	ja     801b4c <devpipe_read+0x66>
  801b45:	eb 12                	jmp    801b59 <devpipe_read+0x73>
  801b47:	be 00 00 00 00       	mov    $0x0,%esi
		while (p->p_rpos == p->p_wpos) {
  801b4c:	8b 03                	mov    (%ebx),%eax
  801b4e:	3b 43 04             	cmp    0x4(%ebx),%eax
  801b51:	75 d4                	jne    801b27 <devpipe_read+0x41>
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801b53:	85 f6                	test   %esi,%esi
  801b55:	75 b3                	jne    801b0a <devpipe_read+0x24>
  801b57:	eb b5                	jmp    801b0e <devpipe_read+0x28>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801b59:	89 f0                	mov    %esi,%eax
  801b5b:	eb 05                	jmp    801b62 <devpipe_read+0x7c>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801b5d:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801b62:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b65:	5b                   	pop    %ebx
  801b66:	5e                   	pop    %esi
  801b67:	5f                   	pop    %edi
  801b68:	c9                   	leave  
  801b69:	c3                   	ret    

00801b6a <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801b6a:	55                   	push   %ebp
  801b6b:	89 e5                	mov    %esp,%ebp
  801b6d:	57                   	push   %edi
  801b6e:	56                   	push   %esi
  801b6f:	53                   	push   %ebx
  801b70:	83 ec 28             	sub    $0x28,%esp
  801b73:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801b76:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801b79:	50                   	push   %eax
  801b7a:	e8 75 f6 ff ff       	call   8011f4 <fd_alloc>
  801b7f:	89 c3                	mov    %eax,%ebx
  801b81:	83 c4 10             	add    $0x10,%esp
  801b84:	85 c0                	test   %eax,%eax
  801b86:	0f 88 24 01 00 00    	js     801cb0 <pipe+0x146>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b8c:	83 ec 04             	sub    $0x4,%esp
  801b8f:	68 07 04 00 00       	push   $0x407
  801b94:	ff 75 e4             	pushl  -0x1c(%ebp)
  801b97:	6a 00                	push   $0x0
  801b99:	e8 52 f0 ff ff       	call   800bf0 <sys_page_alloc>
  801b9e:	89 c3                	mov    %eax,%ebx
  801ba0:	83 c4 10             	add    $0x10,%esp
  801ba3:	85 c0                	test   %eax,%eax
  801ba5:	0f 88 05 01 00 00    	js     801cb0 <pipe+0x146>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801bab:	83 ec 0c             	sub    $0xc,%esp
  801bae:	8d 45 e0             	lea    -0x20(%ebp),%eax
  801bb1:	50                   	push   %eax
  801bb2:	e8 3d f6 ff ff       	call   8011f4 <fd_alloc>
  801bb7:	89 c3                	mov    %eax,%ebx
  801bb9:	83 c4 10             	add    $0x10,%esp
  801bbc:	85 c0                	test   %eax,%eax
  801bbe:	0f 88 dc 00 00 00    	js     801ca0 <pipe+0x136>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801bc4:	83 ec 04             	sub    $0x4,%esp
  801bc7:	68 07 04 00 00       	push   $0x407
  801bcc:	ff 75 e0             	pushl  -0x20(%ebp)
  801bcf:	6a 00                	push   $0x0
  801bd1:	e8 1a f0 ff ff       	call   800bf0 <sys_page_alloc>
  801bd6:	89 c3                	mov    %eax,%ebx
  801bd8:	83 c4 10             	add    $0x10,%esp
  801bdb:	85 c0                	test   %eax,%eax
  801bdd:	0f 88 bd 00 00 00    	js     801ca0 <pipe+0x136>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801be3:	83 ec 0c             	sub    $0xc,%esp
  801be6:	ff 75 e4             	pushl  -0x1c(%ebp)
  801be9:	e8 ee f5 ff ff       	call   8011dc <fd2data>
  801bee:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801bf0:	83 c4 0c             	add    $0xc,%esp
  801bf3:	68 07 04 00 00       	push   $0x407
  801bf8:	50                   	push   %eax
  801bf9:	6a 00                	push   $0x0
  801bfb:	e8 f0 ef ff ff       	call   800bf0 <sys_page_alloc>
  801c00:	89 c3                	mov    %eax,%ebx
  801c02:	83 c4 10             	add    $0x10,%esp
  801c05:	85 c0                	test   %eax,%eax
  801c07:	0f 88 83 00 00 00    	js     801c90 <pipe+0x126>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c0d:	83 ec 0c             	sub    $0xc,%esp
  801c10:	ff 75 e0             	pushl  -0x20(%ebp)
  801c13:	e8 c4 f5 ff ff       	call   8011dc <fd2data>
  801c18:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801c1f:	50                   	push   %eax
  801c20:	6a 00                	push   $0x0
  801c22:	56                   	push   %esi
  801c23:	6a 00                	push   $0x0
  801c25:	e8 ea ef ff ff       	call   800c14 <sys_page_map>
  801c2a:	89 c3                	mov    %eax,%ebx
  801c2c:	83 c4 20             	add    $0x20,%esp
  801c2f:	85 c0                	test   %eax,%eax
  801c31:	78 4f                	js     801c82 <pipe+0x118>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801c33:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801c39:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801c3c:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801c3e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801c41:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801c48:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801c4e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801c51:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801c53:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801c56:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801c5d:	83 ec 0c             	sub    $0xc,%esp
  801c60:	ff 75 e4             	pushl  -0x1c(%ebp)
  801c63:	e8 64 f5 ff ff       	call   8011cc <fd2num>
  801c68:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  801c6a:	83 c4 04             	add    $0x4,%esp
  801c6d:	ff 75 e0             	pushl  -0x20(%ebp)
  801c70:	e8 57 f5 ff ff       	call   8011cc <fd2num>
  801c75:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  801c78:	83 c4 10             	add    $0x10,%esp
  801c7b:	bb 00 00 00 00       	mov    $0x0,%ebx
  801c80:	eb 2e                	jmp    801cb0 <pipe+0x146>

    err3:
	sys_page_unmap(0, va);
  801c82:	83 ec 08             	sub    $0x8,%esp
  801c85:	56                   	push   %esi
  801c86:	6a 00                	push   $0x0
  801c88:	e8 ad ef ff ff       	call   800c3a <sys_page_unmap>
  801c8d:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801c90:	83 ec 08             	sub    $0x8,%esp
  801c93:	ff 75 e0             	pushl  -0x20(%ebp)
  801c96:	6a 00                	push   $0x0
  801c98:	e8 9d ef ff ff       	call   800c3a <sys_page_unmap>
  801c9d:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801ca0:	83 ec 08             	sub    $0x8,%esp
  801ca3:	ff 75 e4             	pushl  -0x1c(%ebp)
  801ca6:	6a 00                	push   $0x0
  801ca8:	e8 8d ef ff ff       	call   800c3a <sys_page_unmap>
  801cad:	83 c4 10             	add    $0x10,%esp
    err:
	return r;
}
  801cb0:	89 d8                	mov    %ebx,%eax
  801cb2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801cb5:	5b                   	pop    %ebx
  801cb6:	5e                   	pop    %esi
  801cb7:	5f                   	pop    %edi
  801cb8:	c9                   	leave  
  801cb9:	c3                   	ret    

00801cba <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801cba:	55                   	push   %ebp
  801cbb:	89 e5                	mov    %esp,%ebp
  801cbd:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801cc0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801cc3:	50                   	push   %eax
  801cc4:	ff 75 08             	pushl  0x8(%ebp)
  801cc7:	e8 9b f5 ff ff       	call   801267 <fd_lookup>
  801ccc:	83 c4 10             	add    $0x10,%esp
  801ccf:	85 c0                	test   %eax,%eax
  801cd1:	78 18                	js     801ceb <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801cd3:	83 ec 0c             	sub    $0xc,%esp
  801cd6:	ff 75 f4             	pushl  -0xc(%ebp)
  801cd9:	e8 fe f4 ff ff       	call   8011dc <fd2data>
	return _pipeisclosed(fd, p);
  801cde:	89 c2                	mov    %eax,%edx
  801ce0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ce3:	e8 0c fd ff ff       	call   8019f4 <_pipeisclosed>
  801ce8:	83 c4 10             	add    $0x10,%esp
}
  801ceb:	c9                   	leave  
  801cec:	c3                   	ret    
  801ced:	00 00                	add    %al,(%eax)
	...

00801cf0 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801cf0:	55                   	push   %ebp
  801cf1:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801cf3:	b8 00 00 00 00       	mov    $0x0,%eax
  801cf8:	c9                   	leave  
  801cf9:	c3                   	ret    

00801cfa <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801cfa:	55                   	push   %ebp
  801cfb:	89 e5                	mov    %esp,%ebp
  801cfd:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801d00:	68 ea 27 80 00       	push   $0x8027ea
  801d05:	ff 75 0c             	pushl  0xc(%ebp)
  801d08:	e8 61 ea ff ff       	call   80076e <strcpy>
	return 0;
}
  801d0d:	b8 00 00 00 00       	mov    $0x0,%eax
  801d12:	c9                   	leave  
  801d13:	c3                   	ret    

00801d14 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801d14:	55                   	push   %ebp
  801d15:	89 e5                	mov    %esp,%ebp
  801d17:	57                   	push   %edi
  801d18:	56                   	push   %esi
  801d19:	53                   	push   %ebx
  801d1a:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801d20:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801d24:	74 45                	je     801d6b <devcons_write+0x57>
  801d26:	b8 00 00 00 00       	mov    $0x0,%eax
  801d2b:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801d30:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801d36:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801d39:	29 c3                	sub    %eax,%ebx
		if (m > sizeof(buf) - 1)
  801d3b:	83 fb 7f             	cmp    $0x7f,%ebx
  801d3e:	76 05                	jbe    801d45 <devcons_write+0x31>
			m = sizeof(buf) - 1;
  801d40:	bb 7f 00 00 00       	mov    $0x7f,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  801d45:	83 ec 04             	sub    $0x4,%esp
  801d48:	53                   	push   %ebx
  801d49:	03 45 0c             	add    0xc(%ebp),%eax
  801d4c:	50                   	push   %eax
  801d4d:	57                   	push   %edi
  801d4e:	e8 dc eb ff ff       	call   80092f <memmove>
		sys_cputs(buf, m);
  801d53:	83 c4 08             	add    $0x8,%esp
  801d56:	53                   	push   %ebx
  801d57:	57                   	push   %edi
  801d58:	e8 dc ed ff ff       	call   800b39 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801d5d:	01 de                	add    %ebx,%esi
  801d5f:	89 f0                	mov    %esi,%eax
  801d61:	83 c4 10             	add    $0x10,%esp
  801d64:	3b 75 10             	cmp    0x10(%ebp),%esi
  801d67:	72 cd                	jb     801d36 <devcons_write+0x22>
  801d69:	eb 05                	jmp    801d70 <devcons_write+0x5c>
  801d6b:	be 00 00 00 00       	mov    $0x0,%esi
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801d70:	89 f0                	mov    %esi,%eax
  801d72:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d75:	5b                   	pop    %ebx
  801d76:	5e                   	pop    %esi
  801d77:	5f                   	pop    %edi
  801d78:	c9                   	leave  
  801d79:	c3                   	ret    

00801d7a <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801d7a:	55                   	push   %ebp
  801d7b:	89 e5                	mov    %esp,%ebp
  801d7d:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  801d80:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801d84:	75 07                	jne    801d8d <devcons_read+0x13>
  801d86:	eb 25                	jmp    801dad <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801d88:	e8 3c ee ff ff       	call   800bc9 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801d8d:	e8 cd ed ff ff       	call   800b5f <sys_cgetc>
  801d92:	85 c0                	test   %eax,%eax
  801d94:	74 f2                	je     801d88 <devcons_read+0xe>
  801d96:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  801d98:	85 c0                	test   %eax,%eax
  801d9a:	78 1d                	js     801db9 <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801d9c:	83 f8 04             	cmp    $0x4,%eax
  801d9f:	74 13                	je     801db4 <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  801da1:	8b 45 0c             	mov    0xc(%ebp),%eax
  801da4:	88 10                	mov    %dl,(%eax)
	return 1;
  801da6:	b8 01 00 00 00       	mov    $0x1,%eax
  801dab:	eb 0c                	jmp    801db9 <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  801dad:	b8 00 00 00 00       	mov    $0x0,%eax
  801db2:	eb 05                	jmp    801db9 <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801db4:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801db9:	c9                   	leave  
  801dba:	c3                   	ret    

00801dbb <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801dbb:	55                   	push   %ebp
  801dbc:	89 e5                	mov    %esp,%ebp
  801dbe:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801dc1:	8b 45 08             	mov    0x8(%ebp),%eax
  801dc4:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801dc7:	6a 01                	push   $0x1
  801dc9:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801dcc:	50                   	push   %eax
  801dcd:	e8 67 ed ff ff       	call   800b39 <sys_cputs>
  801dd2:	83 c4 10             	add    $0x10,%esp
}
  801dd5:	c9                   	leave  
  801dd6:	c3                   	ret    

00801dd7 <getchar>:

int
getchar(void)
{
  801dd7:	55                   	push   %ebp
  801dd8:	89 e5                	mov    %esp,%ebp
  801dda:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801ddd:	6a 01                	push   $0x1
  801ddf:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801de2:	50                   	push   %eax
  801de3:	6a 00                	push   $0x0
  801de5:	e8 fe f6 ff ff       	call   8014e8 <read>
	if (r < 0)
  801dea:	83 c4 10             	add    $0x10,%esp
  801ded:	85 c0                	test   %eax,%eax
  801def:	78 0f                	js     801e00 <getchar+0x29>
		return r;
	if (r < 1)
  801df1:	85 c0                	test   %eax,%eax
  801df3:	7e 06                	jle    801dfb <getchar+0x24>
		return -E_EOF;
	return c;
  801df5:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801df9:	eb 05                	jmp    801e00 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801dfb:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801e00:	c9                   	leave  
  801e01:	c3                   	ret    

00801e02 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801e02:	55                   	push   %ebp
  801e03:	89 e5                	mov    %esp,%ebp
  801e05:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801e08:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e0b:	50                   	push   %eax
  801e0c:	ff 75 08             	pushl  0x8(%ebp)
  801e0f:	e8 53 f4 ff ff       	call   801267 <fd_lookup>
  801e14:	83 c4 10             	add    $0x10,%esp
  801e17:	85 c0                	test   %eax,%eax
  801e19:	78 11                	js     801e2c <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801e1b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e1e:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801e24:	39 10                	cmp    %edx,(%eax)
  801e26:	0f 94 c0             	sete   %al
  801e29:	0f b6 c0             	movzbl %al,%eax
}
  801e2c:	c9                   	leave  
  801e2d:	c3                   	ret    

00801e2e <opencons>:

int
opencons(void)
{
  801e2e:	55                   	push   %ebp
  801e2f:	89 e5                	mov    %esp,%ebp
  801e31:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801e34:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e37:	50                   	push   %eax
  801e38:	e8 b7 f3 ff ff       	call   8011f4 <fd_alloc>
  801e3d:	83 c4 10             	add    $0x10,%esp
  801e40:	85 c0                	test   %eax,%eax
  801e42:	78 3a                	js     801e7e <opencons+0x50>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801e44:	83 ec 04             	sub    $0x4,%esp
  801e47:	68 07 04 00 00       	push   $0x407
  801e4c:	ff 75 f4             	pushl  -0xc(%ebp)
  801e4f:	6a 00                	push   $0x0
  801e51:	e8 9a ed ff ff       	call   800bf0 <sys_page_alloc>
  801e56:	83 c4 10             	add    $0x10,%esp
  801e59:	85 c0                	test   %eax,%eax
  801e5b:	78 21                	js     801e7e <opencons+0x50>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801e5d:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801e63:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e66:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801e68:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e6b:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801e72:	83 ec 0c             	sub    $0xc,%esp
  801e75:	50                   	push   %eax
  801e76:	e8 51 f3 ff ff       	call   8011cc <fd2num>
  801e7b:	83 c4 10             	add    $0x10,%esp
}
  801e7e:	c9                   	leave  
  801e7f:	c3                   	ret    

00801e80 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801e80:	55                   	push   %ebp
  801e81:	89 e5                	mov    %esp,%ebp
  801e83:	56                   	push   %esi
  801e84:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801e85:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801e88:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  801e8e:	e8 12 ed ff ff       	call   800ba5 <sys_getenvid>
  801e93:	83 ec 0c             	sub    $0xc,%esp
  801e96:	ff 75 0c             	pushl  0xc(%ebp)
  801e99:	ff 75 08             	pushl  0x8(%ebp)
  801e9c:	53                   	push   %ebx
  801e9d:	50                   	push   %eax
  801e9e:	68 f8 27 80 00       	push   $0x8027f8
  801ea3:	e8 10 e3 ff ff       	call   8001b8 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801ea8:	83 c4 18             	add    $0x18,%esp
  801eab:	56                   	push   %esi
  801eac:	ff 75 10             	pushl  0x10(%ebp)
  801eaf:	e8 b3 e2 ff ff       	call   800167 <vcprintf>
	cprintf("\n");
  801eb4:	c7 04 24 e3 27 80 00 	movl   $0x8027e3,(%esp)
  801ebb:	e8 f8 e2 ff ff       	call   8001b8 <cprintf>
  801ec0:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801ec3:	cc                   	int3   
  801ec4:	eb fd                	jmp    801ec3 <_panic+0x43>
	...

00801ec8 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801ec8:	55                   	push   %ebp
  801ec9:	89 e5                	mov    %esp,%ebp
  801ecb:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  801ece:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801ed5:	75 52                	jne    801f29 <set_pgfault_handler+0x61>
		// First time through!	
		// LAB 4: Your code here.

		//int sys_page_alloc(envid_t envid, void *va, int perm)
		r = sys_page_alloc(0, (void*)(UXSTACKTOP - PGSIZE), PTE_U | PTE_W | PTE_P);
  801ed7:	83 ec 04             	sub    $0x4,%esp
  801eda:	6a 07                	push   $0x7
  801edc:	68 00 f0 bf ee       	push   $0xeebff000
  801ee1:	6a 00                	push   $0x0
  801ee3:	e8 08 ed ff ff       	call   800bf0 <sys_page_alloc>
		if (r < 0) {
  801ee8:	83 c4 10             	add    $0x10,%esp
  801eeb:	85 c0                	test   %eax,%eax
  801eed:	79 12                	jns    801f01 <set_pgfault_handler+0x39>
			panic("sys_page_alloc error : %e\n", r);
  801eef:	50                   	push   %eax
  801ef0:	68 1b 28 80 00       	push   $0x80281b
  801ef5:	6a 24                	push   $0x24
  801ef7:	68 36 28 80 00       	push   $0x802836
  801efc:	e8 7f ff ff ff       	call   801e80 <_panic>
		}

		// how to know envid, put 0, envid2env will help us to get curenv in syscall
		r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);		
  801f01:	83 ec 08             	sub    $0x8,%esp
  801f04:	68 34 1f 80 00       	push   $0x801f34
  801f09:	6a 00                	push   $0x0
  801f0b:	e8 93 ed ff ff       	call   800ca3 <sys_env_set_pgfault_upcall>
		if (r < 0) {
  801f10:	83 c4 10             	add    $0x10,%esp
  801f13:	85 c0                	test   %eax,%eax
  801f15:	79 12                	jns    801f29 <set_pgfault_handler+0x61>
			panic("sys_env_set_pgfault_upcall error : %e\n", r);
  801f17:	50                   	push   %eax
  801f18:	68 44 28 80 00       	push   $0x802844
  801f1d:	6a 2a                	push   $0x2a
  801f1f:	68 36 28 80 00       	push   $0x802836
  801f24:	e8 57 ff ff ff       	call   801e80 <_panic>
		}
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801f29:	8b 45 08             	mov    0x8(%ebp),%eax
  801f2c:	a3 00 60 80 00       	mov    %eax,0x806000
}
  801f31:	c9                   	leave  
  801f32:	c3                   	ret    
	...

00801f34 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801f34:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801f35:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  801f3a:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801f3c:	83 c4 04             	add    $0x4,%esp
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	
	// fix old esp
	movl 0x30(%esp), %eax
  801f3f:	8b 44 24 30          	mov    0x30(%esp),%eax
	subl $0x4, %eax
  801f43:	83 e8 04             	sub    $0x4,%eax
	movl %eax, 0x30(%esp)
  801f46:	89 44 24 30          	mov    %eax,0x30(%esp)

	// set trap-time %eip
	movl 0x28(%esp), %ebx
  801f4a:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	movl %ebx, (%eax)
  801f4e:	89 18                	mov    %ebx,(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $0x08, %esp 	// ignore err_code and fault_va
  801f50:	83 c4 08             	add    $0x8,%esp
	popal 				// restore registers
  801f53:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x04, %esp 	// ignore eip 
  801f54:	83 c4 04             	add    $0x4,%esp
	popfl				// modify eflags
  801f57:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  801f58:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  801f59:	c3                   	ret    
	...

00801f5c <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801f5c:	55                   	push   %ebp
  801f5d:	89 e5                	mov    %esp,%ebp
  801f5f:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801f62:	89 c2                	mov    %eax,%edx
  801f64:	c1 ea 16             	shr    $0x16,%edx
  801f67:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801f6e:	f6 c2 01             	test   $0x1,%dl
  801f71:	74 1e                	je     801f91 <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  801f73:	c1 e8 0c             	shr    $0xc,%eax
  801f76:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801f7d:	a8 01                	test   $0x1,%al
  801f7f:	74 17                	je     801f98 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801f81:	c1 e8 0c             	shr    $0xc,%eax
  801f84:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  801f8b:	ef 
  801f8c:	0f b7 c0             	movzwl %ax,%eax
  801f8f:	eb 0c                	jmp    801f9d <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  801f91:	b8 00 00 00 00       	mov    $0x0,%eax
  801f96:	eb 05                	jmp    801f9d <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  801f98:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  801f9d:	c9                   	leave  
  801f9e:	c3                   	ret    
	...

00801fa0 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  801fa0:	55                   	push   %ebp
  801fa1:	89 e5                	mov    %esp,%ebp
  801fa3:	57                   	push   %edi
  801fa4:	56                   	push   %esi
  801fa5:	83 ec 10             	sub    $0x10,%esp
  801fa8:	8b 7d 08             	mov    0x8(%ebp),%edi
  801fab:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  801fae:	89 7d f0             	mov    %edi,-0x10(%ebp)
  801fb1:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  801fb4:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  801fb7:	8b 45 14             	mov    0x14(%ebp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  801fba:	85 c0                	test   %eax,%eax
  801fbc:	75 2e                	jne    801fec <__udivdi3+0x4c>
    {
      if (d0 > n1)
  801fbe:	39 f1                	cmp    %esi,%ecx
  801fc0:	77 5a                	ja     80201c <__udivdi3+0x7c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  801fc2:	85 c9                	test   %ecx,%ecx
  801fc4:	75 0b                	jne    801fd1 <__udivdi3+0x31>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  801fc6:	b8 01 00 00 00       	mov    $0x1,%eax
  801fcb:	31 d2                	xor    %edx,%edx
  801fcd:	f7 f1                	div    %ecx
  801fcf:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  801fd1:	31 d2                	xor    %edx,%edx
  801fd3:	89 f0                	mov    %esi,%eax
  801fd5:	f7 f1                	div    %ecx
  801fd7:	89 c6                	mov    %eax,%esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801fd9:	89 f8                	mov    %edi,%eax
  801fdb:	f7 f1                	div    %ecx
  801fdd:	89 c7                	mov    %eax,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801fdf:	89 f8                	mov    %edi,%eax
  801fe1:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801fe3:	83 c4 10             	add    $0x10,%esp
  801fe6:	5e                   	pop    %esi
  801fe7:	5f                   	pop    %edi
  801fe8:	c9                   	leave  
  801fe9:	c3                   	ret    
  801fea:	66 90                	xchg   %ax,%ax
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801fec:	39 f0                	cmp    %esi,%eax
  801fee:	77 1c                	ja     80200c <__udivdi3+0x6c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  801ff0:	0f bd f8             	bsr    %eax,%edi
	  if (bm == 0)
  801ff3:	83 f7 1f             	xor    $0x1f,%edi
  801ff6:	75 3c                	jne    802034 <__udivdi3+0x94>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801ff8:	39 f0                	cmp    %esi,%eax
  801ffa:	0f 82 90 00 00 00    	jb     802090 <__udivdi3+0xf0>
  802000:	8b 55 f0             	mov    -0x10(%ebp),%edx
  802003:	39 55 f4             	cmp    %edx,-0xc(%ebp)
  802006:	0f 86 84 00 00 00    	jbe    802090 <__udivdi3+0xf0>
  80200c:	31 f6                	xor    %esi,%esi
  80200e:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  802010:	89 f8                	mov    %edi,%eax
  802012:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802014:	83 c4 10             	add    $0x10,%esp
  802017:	5e                   	pop    %esi
  802018:	5f                   	pop    %edi
  802019:	c9                   	leave  
  80201a:	c3                   	ret    
  80201b:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  80201c:	89 f2                	mov    %esi,%edx
  80201e:	89 f8                	mov    %edi,%eax
  802020:	f7 f1                	div    %ecx
  802022:	89 c7                	mov    %eax,%edi
  802024:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  802026:	89 f8                	mov    %edi,%eax
  802028:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  80202a:	83 c4 10             	add    $0x10,%esp
  80202d:	5e                   	pop    %esi
  80202e:	5f                   	pop    %edi
  80202f:	c9                   	leave  
  802030:	c3                   	ret    
  802031:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  802034:	89 f9                	mov    %edi,%ecx
  802036:	d3 e0                	shl    %cl,%eax
  802038:	89 45 e8             	mov    %eax,-0x18(%ebp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  80203b:	b8 20 00 00 00       	mov    $0x20,%eax
  802040:	29 f8                	sub    %edi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  802042:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802045:	88 c1                	mov    %al,%cl
  802047:	d3 ea                	shr    %cl,%edx
  802049:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  80204c:	09 ca                	or     %ecx,%edx
  80204e:	89 55 ec             	mov    %edx,-0x14(%ebp)
	      d0 = d0 << bm;
  802051:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802054:	89 f9                	mov    %edi,%ecx
  802056:	d3 e2                	shl    %cl,%edx
  802058:	89 55 f4             	mov    %edx,-0xc(%ebp)
	      n2 = n1 >> b;
  80205b:	89 f2                	mov    %esi,%edx
  80205d:	88 c1                	mov    %al,%cl
  80205f:	d3 ea                	shr    %cl,%edx
  802061:	89 55 e8             	mov    %edx,-0x18(%ebp)
	      n1 = (n1 << bm) | (n0 >> b);
  802064:	89 f2                	mov    %esi,%edx
  802066:	89 f9                	mov    %edi,%ecx
  802068:	d3 e2                	shl    %cl,%edx
  80206a:	8b 75 f0             	mov    -0x10(%ebp),%esi
  80206d:	88 c1                	mov    %al,%cl
  80206f:	d3 ee                	shr    %cl,%esi
  802071:	09 d6                	or     %edx,%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  802073:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  802076:	89 f0                	mov    %esi,%eax
  802078:	89 ca                	mov    %ecx,%edx
  80207a:	f7 75 ec             	divl   -0x14(%ebp)
  80207d:	89 d1                	mov    %edx,%ecx
  80207f:	89 c6                	mov    %eax,%esi
	      umul_ppmm (m1, m0, q0, d0);
  802081:	f7 65 f4             	mull   -0xc(%ebp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802084:	39 d1                	cmp    %edx,%ecx
  802086:	72 28                	jb     8020b0 <__udivdi3+0x110>
  802088:	74 1a                	je     8020a4 <__udivdi3+0x104>
  80208a:	89 f7                	mov    %esi,%edi
  80208c:	31 f6                	xor    %esi,%esi
  80208e:	eb 80                	jmp    802010 <__udivdi3+0x70>
	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  802090:	31 f6                	xor    %esi,%esi
  802092:	bf 01 00 00 00       	mov    $0x1,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  802097:	89 f8                	mov    %edi,%eax
  802099:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  80209b:	83 c4 10             	add    $0x10,%esp
  80209e:	5e                   	pop    %esi
  80209f:	5f                   	pop    %edi
  8020a0:	c9                   	leave  
  8020a1:	c3                   	ret    
  8020a2:	66 90                	xchg   %ax,%ax

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  8020a4:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8020a7:	89 f9                	mov    %edi,%ecx
  8020a9:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8020ab:	39 c2                	cmp    %eax,%edx
  8020ad:	73 db                	jae    80208a <__udivdi3+0xea>
  8020af:	90                   	nop
		{
		  q0--;
  8020b0:	8d 7e ff             	lea    -0x1(%esi),%edi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  8020b3:	31 f6                	xor    %esi,%esi
  8020b5:	e9 56 ff ff ff       	jmp    802010 <__udivdi3+0x70>
	...

008020bc <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  8020bc:	55                   	push   %ebp
  8020bd:	89 e5                	mov    %esp,%ebp
  8020bf:	57                   	push   %edi
  8020c0:	56                   	push   %esi
  8020c1:	83 ec 20             	sub    $0x20,%esp
  8020c4:	8b 45 08             	mov    0x8(%ebp),%eax
  8020c7:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  8020ca:	89 45 e8             	mov    %eax,-0x18(%ebp)
  8020cd:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  8020d0:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  8020d3:	8b 7d 14             	mov    0x14(%ebp),%edi
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  8020d6:	89 45 f0             	mov    %eax,-0x10(%ebp)
  n1 = nn.s.high;
  8020d9:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  8020db:	85 ff                	test   %edi,%edi
  8020dd:	75 15                	jne    8020f4 <__umoddi3+0x38>
    {
      if (d0 > n1)
  8020df:	39 f1                	cmp    %esi,%ecx
  8020e1:	0f 86 99 00 00 00    	jbe    802180 <__umoddi3+0xc4>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8020e7:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  8020e9:	89 d0                	mov    %edx,%eax
  8020eb:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8020ed:	83 c4 20             	add    $0x20,%esp
  8020f0:	5e                   	pop    %esi
  8020f1:	5f                   	pop    %edi
  8020f2:	c9                   	leave  
  8020f3:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  8020f4:	39 f7                	cmp    %esi,%edi
  8020f6:	0f 87 a4 00 00 00    	ja     8021a0 <__umoddi3+0xe4>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  8020fc:	0f bd c7             	bsr    %edi,%eax
	  if (bm == 0)
  8020ff:	83 f0 1f             	xor    $0x1f,%eax
  802102:	89 45 ec             	mov    %eax,-0x14(%ebp)
  802105:	0f 84 a1 00 00 00    	je     8021ac <__umoddi3+0xf0>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  80210b:	89 f8                	mov    %edi,%eax
  80210d:	8a 4d ec             	mov    -0x14(%ebp),%cl
  802110:	d3 e0                	shl    %cl,%eax
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  802112:	bf 20 00 00 00       	mov    $0x20,%edi
  802117:	2b 7d ec             	sub    -0x14(%ebp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  80211a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80211d:	89 f9                	mov    %edi,%ecx
  80211f:	d3 ea                	shr    %cl,%edx
  802121:	09 c2                	or     %eax,%edx
  802123:	89 55 f0             	mov    %edx,-0x10(%ebp)
	      d0 = d0 << bm;
  802126:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802129:	8a 4d ec             	mov    -0x14(%ebp),%cl
  80212c:	d3 e0                	shl    %cl,%eax
  80212e:	89 45 f4             	mov    %eax,-0xc(%ebp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  802131:	89 f2                	mov    %esi,%edx
  802133:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  802135:	8b 45 e8             	mov    -0x18(%ebp),%eax
  802138:	d3 e0                	shl    %cl,%eax
  80213a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  80213d:	8b 45 e8             	mov    -0x18(%ebp),%eax
  802140:	89 f9                	mov    %edi,%ecx
  802142:	d3 e8                	shr    %cl,%eax
  802144:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  802146:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  802148:	89 f2                	mov    %esi,%edx
  80214a:	f7 75 f0             	divl   -0x10(%ebp)
  80214d:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  80214f:	f7 65 f4             	mull   -0xc(%ebp)
  802152:	89 55 e8             	mov    %edx,-0x18(%ebp)
  802155:	89 c1                	mov    %eax,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802157:	39 d6                	cmp    %edx,%esi
  802159:	72 71                	jb     8021cc <__umoddi3+0x110>
  80215b:	74 7f                	je     8021dc <__umoddi3+0x120>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  80215d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802160:	29 c8                	sub    %ecx,%eax
  802162:	19 d6                	sbb    %edx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  802164:	8a 4d ec             	mov    -0x14(%ebp),%cl
  802167:	d3 e8                	shr    %cl,%eax
  802169:	89 f2                	mov    %esi,%edx
  80216b:	89 f9                	mov    %edi,%ecx
  80216d:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  80216f:	09 d0                	or     %edx,%eax
  802171:	89 f2                	mov    %esi,%edx
  802173:	8a 4d ec             	mov    -0x14(%ebp),%cl
  802176:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802178:	83 c4 20             	add    $0x20,%esp
  80217b:	5e                   	pop    %esi
  80217c:	5f                   	pop    %edi
  80217d:	c9                   	leave  
  80217e:	c3                   	ret    
  80217f:	90                   	nop
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  802180:	85 c9                	test   %ecx,%ecx
  802182:	75 0b                	jne    80218f <__umoddi3+0xd3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  802184:	b8 01 00 00 00       	mov    $0x1,%eax
  802189:	31 d2                	xor    %edx,%edx
  80218b:	f7 f1                	div    %ecx
  80218d:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  80218f:	89 f0                	mov    %esi,%eax
  802191:	31 d2                	xor    %edx,%edx
  802193:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802195:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802198:	f7 f1                	div    %ecx
  80219a:	e9 4a ff ff ff       	jmp    8020e9 <__umoddi3+0x2d>
  80219f:	90                   	nop
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  8021a0:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8021a2:	83 c4 20             	add    $0x20,%esp
  8021a5:	5e                   	pop    %esi
  8021a6:	5f                   	pop    %edi
  8021a7:	c9                   	leave  
  8021a8:	c3                   	ret    
  8021a9:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  8021ac:	39 f7                	cmp    %esi,%edi
  8021ae:	72 05                	jb     8021b5 <__umoddi3+0xf9>
  8021b0:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
  8021b3:	77 0c                	ja     8021c1 <__umoddi3+0x105>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  8021b5:	89 f2                	mov    %esi,%edx
  8021b7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8021ba:	29 c8                	sub    %ecx,%eax
  8021bc:	19 fa                	sbb    %edi,%edx
  8021be:	89 45 f0             	mov    %eax,-0x10(%ebp)

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  8021c1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8021c4:	83 c4 20             	add    $0x20,%esp
  8021c7:	5e                   	pop    %esi
  8021c8:	5f                   	pop    %edi
  8021c9:	c9                   	leave  
  8021ca:	c3                   	ret    
  8021cb:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  8021cc:	8b 55 e8             	mov    -0x18(%ebp),%edx
  8021cf:	89 c1                	mov    %eax,%ecx
  8021d1:	2b 4d f4             	sub    -0xc(%ebp),%ecx
  8021d4:	1b 55 f0             	sbb    -0x10(%ebp),%edx
  8021d7:	eb 84                	jmp    80215d <__umoddi3+0xa1>
  8021d9:	8d 76 00             	lea    0x0(%esi),%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8021dc:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  8021df:	72 eb                	jb     8021cc <__umoddi3+0x110>
  8021e1:	89 f2                	mov    %esi,%edx
  8021e3:	e9 75 ff ff ff       	jmp    80215d <__umoddi3+0xa1>
