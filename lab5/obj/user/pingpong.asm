
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
  80003d:	e8 ec 0d 00 00       	call   800e2e <fork>
  800042:	89 c3                	mov    %eax,%ebx
  800044:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800047:	85 c0                	test   %eax,%eax
  800049:	74 25                	je     800070 <umain+0x3c>
		// get the ball rolling
		cprintf("send 0 from %x to %x\n", sys_getenvid(), who);
  80004b:	e8 59 0b 00 00       	call   800ba9 <sys_getenvid>
  800050:	83 ec 04             	sub    $0x4,%esp
  800053:	53                   	push   %ebx
  800054:	50                   	push   %eax
  800055:	68 c0 21 80 00       	push   $0x8021c0
  80005a:	e8 5d 01 00 00       	call   8001bc <cprintf>
		ipc_send(who, 0, 0, 0);
  80005f:	6a 00                	push   $0x0
  800061:	6a 00                	push   $0x0
  800063:	6a 00                	push   $0x0
  800065:	ff 75 e4             	pushl  -0x1c(%ebp)
  800068:	e8 80 10 00 00       	call   8010ed <ipc_send>
  80006d:	83 c4 20             	add    $0x20,%esp
	}

	while (1) {
		uint32_t i = ipc_recv(&who, 0, 0);
  800070:	8d 7d e4             	lea    -0x1c(%ebp),%edi
  800073:	83 ec 04             	sub    $0x4,%esp
  800076:	6a 00                	push   $0x0
  800078:	6a 00                	push   $0x0
  80007a:	57                   	push   %edi
  80007b:	e8 f8 0f 00 00       	call   801078 <ipc_recv>
  800080:	89 c3                	mov    %eax,%ebx
		cprintf("%x got %d from %x\n", sys_getenvid(), i, who);
  800082:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  800085:	e8 1f 0b 00 00       	call   800ba9 <sys_getenvid>
  80008a:	56                   	push   %esi
  80008b:	53                   	push   %ebx
  80008c:	50                   	push   %eax
  80008d:	68 d6 21 80 00       	push   $0x8021d6
  800092:	e8 25 01 00 00       	call   8001bc <cprintf>
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
  8000a8:	e8 40 10 00 00       	call   8010ed <ipc_send>
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
  8000cb:	e8 d9 0a 00 00       	call   800ba9 <sys_getenvid>
  8000d0:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000d5:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  8000dc:	c1 e0 07             	shl    $0x7,%eax
  8000df:	29 d0                	sub    %edx,%eax
  8000e1:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000e6:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000eb:	85 f6                	test   %esi,%esi
  8000ed:	7e 07                	jle    8000f6 <libmain+0x36>
		binaryname = argv[0];
  8000ef:	8b 03                	mov    (%ebx),%eax
  8000f1:	a3 00 30 80 00       	mov    %eax,0x803000
	// call user main routine
	umain(argc, argv);
  8000f6:	83 ec 08             	sub    $0x8,%esp
  8000f9:	53                   	push   %ebx
  8000fa:	56                   	push   %esi
  8000fb:	e8 34 ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  800100:	e8 0b 00 00 00       	call   800110 <exit>
  800105:	83 c4 10             	add    $0x10,%esp
}
  800108:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80010b:	5b                   	pop    %ebx
  80010c:	5e                   	pop    %esi
  80010d:	c9                   	leave  
  80010e:	c3                   	ret    
	...

00800110 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800110:	55                   	push   %ebp
  800111:	89 e5                	mov    %esp,%ebp
  800113:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800116:	e8 8f 12 00 00       	call   8013aa <close_all>
	sys_env_destroy(0);
  80011b:	83 ec 0c             	sub    $0xc,%esp
  80011e:	6a 00                	push   $0x0
  800120:	e8 62 0a 00 00       	call   800b87 <sys_env_destroy>
  800125:	83 c4 10             	add    $0x10,%esp
}
  800128:	c9                   	leave  
  800129:	c3                   	ret    
	...

0080012c <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80012c:	55                   	push   %ebp
  80012d:	89 e5                	mov    %esp,%ebp
  80012f:	53                   	push   %ebx
  800130:	83 ec 04             	sub    $0x4,%esp
  800133:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800136:	8b 03                	mov    (%ebx),%eax
  800138:	8b 55 08             	mov    0x8(%ebp),%edx
  80013b:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  80013f:	40                   	inc    %eax
  800140:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  800142:	3d ff 00 00 00       	cmp    $0xff,%eax
  800147:	75 1a                	jne    800163 <putch+0x37>
		sys_cputs(b->buf, b->idx);
  800149:	83 ec 08             	sub    $0x8,%esp
  80014c:	68 ff 00 00 00       	push   $0xff
  800151:	8d 43 08             	lea    0x8(%ebx),%eax
  800154:	50                   	push   %eax
  800155:	e8 e3 09 00 00       	call   800b3d <sys_cputs>
		b->idx = 0;
  80015a:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800160:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800163:	ff 43 04             	incl   0x4(%ebx)
}
  800166:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800169:	c9                   	leave  
  80016a:	c3                   	ret    

0080016b <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80016b:	55                   	push   %ebp
  80016c:	89 e5                	mov    %esp,%ebp
  80016e:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800174:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80017b:	00 00 00 
	b.cnt = 0;
  80017e:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800185:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800188:	ff 75 0c             	pushl  0xc(%ebp)
  80018b:	ff 75 08             	pushl  0x8(%ebp)
  80018e:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800194:	50                   	push   %eax
  800195:	68 2c 01 80 00       	push   $0x80012c
  80019a:	e8 82 01 00 00       	call   800321 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80019f:	83 c4 08             	add    $0x8,%esp
  8001a2:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8001a8:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001ae:	50                   	push   %eax
  8001af:	e8 89 09 00 00       	call   800b3d <sys_cputs>

	return b.cnt;
}
  8001b4:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001ba:	c9                   	leave  
  8001bb:	c3                   	ret    

008001bc <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001bc:	55                   	push   %ebp
  8001bd:	89 e5                	mov    %esp,%ebp
  8001bf:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001c2:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001c5:	50                   	push   %eax
  8001c6:	ff 75 08             	pushl  0x8(%ebp)
  8001c9:	e8 9d ff ff ff       	call   80016b <vcprintf>
	va_end(ap);

	return cnt;
}
  8001ce:	c9                   	leave  
  8001cf:	c3                   	ret    

008001d0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001d0:	55                   	push   %ebp
  8001d1:	89 e5                	mov    %esp,%ebp
  8001d3:	57                   	push   %edi
  8001d4:	56                   	push   %esi
  8001d5:	53                   	push   %ebx
  8001d6:	83 ec 2c             	sub    $0x2c,%esp
  8001d9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8001dc:	89 d6                	mov    %edx,%esi
  8001de:	8b 45 08             	mov    0x8(%ebp),%eax
  8001e1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001e4:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001e7:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8001ea:	8b 45 10             	mov    0x10(%ebp),%eax
  8001ed:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8001f0:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001f3:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8001f6:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  8001fd:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
  800200:	72 0c                	jb     80020e <printnum+0x3e>
  800202:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  800205:	76 07                	jbe    80020e <printnum+0x3e>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800207:	4b                   	dec    %ebx
  800208:	85 db                	test   %ebx,%ebx
  80020a:	7f 31                	jg     80023d <printnum+0x6d>
  80020c:	eb 3f                	jmp    80024d <printnum+0x7d>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80020e:	83 ec 0c             	sub    $0xc,%esp
  800211:	57                   	push   %edi
  800212:	4b                   	dec    %ebx
  800213:	53                   	push   %ebx
  800214:	50                   	push   %eax
  800215:	83 ec 08             	sub    $0x8,%esp
  800218:	ff 75 d4             	pushl  -0x2c(%ebp)
  80021b:	ff 75 d0             	pushl  -0x30(%ebp)
  80021e:	ff 75 dc             	pushl  -0x24(%ebp)
  800221:	ff 75 d8             	pushl  -0x28(%ebp)
  800224:	e8 4b 1d 00 00       	call   801f74 <__udivdi3>
  800229:	83 c4 18             	add    $0x18,%esp
  80022c:	52                   	push   %edx
  80022d:	50                   	push   %eax
  80022e:	89 f2                	mov    %esi,%edx
  800230:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800233:	e8 98 ff ff ff       	call   8001d0 <printnum>
  800238:	83 c4 20             	add    $0x20,%esp
  80023b:	eb 10                	jmp    80024d <printnum+0x7d>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80023d:	83 ec 08             	sub    $0x8,%esp
  800240:	56                   	push   %esi
  800241:	57                   	push   %edi
  800242:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800245:	4b                   	dec    %ebx
  800246:	83 c4 10             	add    $0x10,%esp
  800249:	85 db                	test   %ebx,%ebx
  80024b:	7f f0                	jg     80023d <printnum+0x6d>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80024d:	83 ec 08             	sub    $0x8,%esp
  800250:	56                   	push   %esi
  800251:	83 ec 04             	sub    $0x4,%esp
  800254:	ff 75 d4             	pushl  -0x2c(%ebp)
  800257:	ff 75 d0             	pushl  -0x30(%ebp)
  80025a:	ff 75 dc             	pushl  -0x24(%ebp)
  80025d:	ff 75 d8             	pushl  -0x28(%ebp)
  800260:	e8 2b 1e 00 00       	call   802090 <__umoddi3>
  800265:	83 c4 14             	add    $0x14,%esp
  800268:	0f be 80 f3 21 80 00 	movsbl 0x8021f3(%eax),%eax
  80026f:	50                   	push   %eax
  800270:	ff 55 e4             	call   *-0x1c(%ebp)
  800273:	83 c4 10             	add    $0x10,%esp
}
  800276:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800279:	5b                   	pop    %ebx
  80027a:	5e                   	pop    %esi
  80027b:	5f                   	pop    %edi
  80027c:	c9                   	leave  
  80027d:	c3                   	ret    

0080027e <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80027e:	55                   	push   %ebp
  80027f:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800281:	83 fa 01             	cmp    $0x1,%edx
  800284:	7e 0e                	jle    800294 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800286:	8b 10                	mov    (%eax),%edx
  800288:	8d 4a 08             	lea    0x8(%edx),%ecx
  80028b:	89 08                	mov    %ecx,(%eax)
  80028d:	8b 02                	mov    (%edx),%eax
  80028f:	8b 52 04             	mov    0x4(%edx),%edx
  800292:	eb 22                	jmp    8002b6 <getuint+0x38>
	else if (lflag)
  800294:	85 d2                	test   %edx,%edx
  800296:	74 10                	je     8002a8 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800298:	8b 10                	mov    (%eax),%edx
  80029a:	8d 4a 04             	lea    0x4(%edx),%ecx
  80029d:	89 08                	mov    %ecx,(%eax)
  80029f:	8b 02                	mov    (%edx),%eax
  8002a1:	ba 00 00 00 00       	mov    $0x0,%edx
  8002a6:	eb 0e                	jmp    8002b6 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8002a8:	8b 10                	mov    (%eax),%edx
  8002aa:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002ad:	89 08                	mov    %ecx,(%eax)
  8002af:	8b 02                	mov    (%edx),%eax
  8002b1:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002b6:	c9                   	leave  
  8002b7:	c3                   	ret    

008002b8 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  8002b8:	55                   	push   %ebp
  8002b9:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002bb:	83 fa 01             	cmp    $0x1,%edx
  8002be:	7e 0e                	jle    8002ce <getint+0x16>
		return va_arg(*ap, long long);
  8002c0:	8b 10                	mov    (%eax),%edx
  8002c2:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002c5:	89 08                	mov    %ecx,(%eax)
  8002c7:	8b 02                	mov    (%edx),%eax
  8002c9:	8b 52 04             	mov    0x4(%edx),%edx
  8002cc:	eb 1a                	jmp    8002e8 <getint+0x30>
	else if (lflag)
  8002ce:	85 d2                	test   %edx,%edx
  8002d0:	74 0c                	je     8002de <getint+0x26>
		return va_arg(*ap, long);
  8002d2:	8b 10                	mov    (%eax),%edx
  8002d4:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002d7:	89 08                	mov    %ecx,(%eax)
  8002d9:	8b 02                	mov    (%edx),%eax
  8002db:	99                   	cltd   
  8002dc:	eb 0a                	jmp    8002e8 <getint+0x30>
	else
		return va_arg(*ap, int);
  8002de:	8b 10                	mov    (%eax),%edx
  8002e0:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002e3:	89 08                	mov    %ecx,(%eax)
  8002e5:	8b 02                	mov    (%edx),%eax
  8002e7:	99                   	cltd   
}
  8002e8:	c9                   	leave  
  8002e9:	c3                   	ret    

008002ea <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002ea:	55                   	push   %ebp
  8002eb:	89 e5                	mov    %esp,%ebp
  8002ed:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002f0:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  8002f3:	8b 10                	mov    (%eax),%edx
  8002f5:	3b 50 04             	cmp    0x4(%eax),%edx
  8002f8:	73 08                	jae    800302 <sprintputch+0x18>
		*b->buf++ = ch;
  8002fa:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8002fd:	88 0a                	mov    %cl,(%edx)
  8002ff:	42                   	inc    %edx
  800300:	89 10                	mov    %edx,(%eax)
}
  800302:	c9                   	leave  
  800303:	c3                   	ret    

00800304 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800304:	55                   	push   %ebp
  800305:	89 e5                	mov    %esp,%ebp
  800307:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80030a:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80030d:	50                   	push   %eax
  80030e:	ff 75 10             	pushl  0x10(%ebp)
  800311:	ff 75 0c             	pushl  0xc(%ebp)
  800314:	ff 75 08             	pushl  0x8(%ebp)
  800317:	e8 05 00 00 00       	call   800321 <vprintfmt>
	va_end(ap);
  80031c:	83 c4 10             	add    $0x10,%esp
}
  80031f:	c9                   	leave  
  800320:	c3                   	ret    

00800321 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800321:	55                   	push   %ebp
  800322:	89 e5                	mov    %esp,%ebp
  800324:	57                   	push   %edi
  800325:	56                   	push   %esi
  800326:	53                   	push   %ebx
  800327:	83 ec 2c             	sub    $0x2c,%esp
  80032a:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80032d:	8b 75 10             	mov    0x10(%ebp),%esi
  800330:	eb 13                	jmp    800345 <vprintfmt+0x24>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800332:	85 c0                	test   %eax,%eax
  800334:	0f 84 6d 03 00 00    	je     8006a7 <vprintfmt+0x386>
				return;
			putch(ch, putdat);
  80033a:	83 ec 08             	sub    $0x8,%esp
  80033d:	57                   	push   %edi
  80033e:	50                   	push   %eax
  80033f:	ff 55 08             	call   *0x8(%ebp)
  800342:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800345:	0f b6 06             	movzbl (%esi),%eax
  800348:	46                   	inc    %esi
  800349:	83 f8 25             	cmp    $0x25,%eax
  80034c:	75 e4                	jne    800332 <vprintfmt+0x11>
  80034e:	c6 45 dc 20          	movb   $0x20,-0x24(%ebp)
  800352:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  800359:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  800360:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800367:	b9 00 00 00 00       	mov    $0x0,%ecx
  80036c:	eb 28                	jmp    800396 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80036e:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800370:	c6 45 dc 2d          	movb   $0x2d,-0x24(%ebp)
  800374:	eb 20                	jmp    800396 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800376:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800378:	c6 45 dc 30          	movb   $0x30,-0x24(%ebp)
  80037c:	eb 18                	jmp    800396 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80037e:	89 de                	mov    %ebx,%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800380:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800387:	eb 0d                	jmp    800396 <vprintfmt+0x75>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800389:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80038c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80038f:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800396:	8a 06                	mov    (%esi),%al
  800398:	0f b6 d0             	movzbl %al,%edx
  80039b:	8d 5e 01             	lea    0x1(%esi),%ebx
  80039e:	83 e8 23             	sub    $0x23,%eax
  8003a1:	3c 55                	cmp    $0x55,%al
  8003a3:	0f 87 e0 02 00 00    	ja     800689 <vprintfmt+0x368>
  8003a9:	0f b6 c0             	movzbl %al,%eax
  8003ac:	ff 24 85 40 23 80 00 	jmp    *0x802340(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003b3:	83 ea 30             	sub    $0x30,%edx
  8003b6:	89 55 d4             	mov    %edx,-0x2c(%ebp)
				ch = *fmt;
  8003b9:	0f be 03             	movsbl (%ebx),%eax
				if (ch < '0' || ch > '9')
  8003bc:	8d 50 d0             	lea    -0x30(%eax),%edx
  8003bf:	83 fa 09             	cmp    $0x9,%edx
  8003c2:	77 44                	ja     800408 <vprintfmt+0xe7>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003c4:	89 de                	mov    %ebx,%esi
  8003c6:	8b 55 d4             	mov    -0x2c(%ebp),%edx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003c9:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
  8003ca:	8d 14 92             	lea    (%edx,%edx,4),%edx
  8003cd:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
  8003d1:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8003d4:	8d 58 d0             	lea    -0x30(%eax),%ebx
  8003d7:	83 fb 09             	cmp    $0x9,%ebx
  8003da:	76 ed                	jbe    8003c9 <vprintfmt+0xa8>
  8003dc:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  8003df:	eb 29                	jmp    80040a <vprintfmt+0xe9>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003e1:	8b 45 14             	mov    0x14(%ebp),%eax
  8003e4:	8d 50 04             	lea    0x4(%eax),%edx
  8003e7:	89 55 14             	mov    %edx,0x14(%ebp)
  8003ea:	8b 00                	mov    (%eax),%eax
  8003ec:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ef:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8003f1:	eb 17                	jmp    80040a <vprintfmt+0xe9>

		case '.':
			if (width < 0)
  8003f3:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8003f7:	78 85                	js     80037e <vprintfmt+0x5d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003f9:	89 de                	mov    %ebx,%esi
  8003fb:	eb 99                	jmp    800396 <vprintfmt+0x75>
  8003fd:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8003ff:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  800406:	eb 8e                	jmp    800396 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800408:	89 de                	mov    %ebx,%esi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  80040a:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80040e:	79 86                	jns    800396 <vprintfmt+0x75>
  800410:	e9 74 ff ff ff       	jmp    800389 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800415:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800416:	89 de                	mov    %ebx,%esi
  800418:	e9 79 ff ff ff       	jmp    800396 <vprintfmt+0x75>
  80041d:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800420:	8b 45 14             	mov    0x14(%ebp),%eax
  800423:	8d 50 04             	lea    0x4(%eax),%edx
  800426:	89 55 14             	mov    %edx,0x14(%ebp)
  800429:	83 ec 08             	sub    $0x8,%esp
  80042c:	57                   	push   %edi
  80042d:	ff 30                	pushl  (%eax)
  80042f:	ff 55 08             	call   *0x8(%ebp)
			break;
  800432:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800435:	8b 75 d8             	mov    -0x28(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800438:	e9 08 ff ff ff       	jmp    800345 <vprintfmt+0x24>
  80043d:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  800440:	8b 45 14             	mov    0x14(%ebp),%eax
  800443:	8d 50 04             	lea    0x4(%eax),%edx
  800446:	89 55 14             	mov    %edx,0x14(%ebp)
  800449:	8b 00                	mov    (%eax),%eax
  80044b:	85 c0                	test   %eax,%eax
  80044d:	79 02                	jns    800451 <vprintfmt+0x130>
  80044f:	f7 d8                	neg    %eax
  800451:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800453:	83 f8 0f             	cmp    $0xf,%eax
  800456:	7f 0b                	jg     800463 <vprintfmt+0x142>
  800458:	8b 04 85 a0 24 80 00 	mov    0x8024a0(,%eax,4),%eax
  80045f:	85 c0                	test   %eax,%eax
  800461:	75 1a                	jne    80047d <vprintfmt+0x15c>
				printfmt(putch, putdat, "error %d", err);
  800463:	52                   	push   %edx
  800464:	68 0b 22 80 00       	push   $0x80220b
  800469:	57                   	push   %edi
  80046a:	ff 75 08             	pushl  0x8(%ebp)
  80046d:	e8 92 fe ff ff       	call   800304 <printfmt>
  800472:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800475:	8b 75 d8             	mov    -0x28(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800478:	e9 c8 fe ff ff       	jmp    800345 <vprintfmt+0x24>
			else
				printfmt(putch, putdat, "%s", p);
  80047d:	50                   	push   %eax
  80047e:	68 71 27 80 00       	push   $0x802771
  800483:	57                   	push   %edi
  800484:	ff 75 08             	pushl  0x8(%ebp)
  800487:	e8 78 fe ff ff       	call   800304 <printfmt>
  80048c:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80048f:	8b 75 d8             	mov    -0x28(%ebp),%esi
  800492:	e9 ae fe ff ff       	jmp    800345 <vprintfmt+0x24>
  800497:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  80049a:	89 de                	mov    %ebx,%esi
  80049c:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  80049f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004a2:	8b 45 14             	mov    0x14(%ebp),%eax
  8004a5:	8d 50 04             	lea    0x4(%eax),%edx
  8004a8:	89 55 14             	mov    %edx,0x14(%ebp)
  8004ab:	8b 00                	mov    (%eax),%eax
  8004ad:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8004b0:	85 c0                	test   %eax,%eax
  8004b2:	75 07                	jne    8004bb <vprintfmt+0x19a>
				p = "(null)";
  8004b4:	c7 45 d0 04 22 80 00 	movl   $0x802204,-0x30(%ebp)
			if (width > 0 && padc != '-')
  8004bb:	85 db                	test   %ebx,%ebx
  8004bd:	7e 42                	jle    800501 <vprintfmt+0x1e0>
  8004bf:	80 7d dc 2d          	cmpb   $0x2d,-0x24(%ebp)
  8004c3:	74 3c                	je     800501 <vprintfmt+0x1e0>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004c5:	83 ec 08             	sub    $0x8,%esp
  8004c8:	51                   	push   %ecx
  8004c9:	ff 75 d0             	pushl  -0x30(%ebp)
  8004cc:	e8 6f 02 00 00       	call   800740 <strnlen>
  8004d1:	29 c3                	sub    %eax,%ebx
  8004d3:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8004d6:	83 c4 10             	add    $0x10,%esp
  8004d9:	85 db                	test   %ebx,%ebx
  8004db:	7e 24                	jle    800501 <vprintfmt+0x1e0>
					putch(padc, putdat);
  8004dd:	0f be 5d dc          	movsbl -0x24(%ebp),%ebx
  8004e1:	89 75 dc             	mov    %esi,-0x24(%ebp)
  8004e4:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  8004e7:	83 ec 08             	sub    $0x8,%esp
  8004ea:	57                   	push   %edi
  8004eb:	53                   	push   %ebx
  8004ec:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004ef:	4e                   	dec    %esi
  8004f0:	83 c4 10             	add    $0x10,%esp
  8004f3:	85 f6                	test   %esi,%esi
  8004f5:	7f f0                	jg     8004e7 <vprintfmt+0x1c6>
  8004f7:	8b 75 dc             	mov    -0x24(%ebp),%esi
  8004fa:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800501:	8b 55 d0             	mov    -0x30(%ebp),%edx
  800504:	0f be 02             	movsbl (%edx),%eax
  800507:	85 c0                	test   %eax,%eax
  800509:	75 47                	jne    800552 <vprintfmt+0x231>
  80050b:	eb 37                	jmp    800544 <vprintfmt+0x223>
				if (altflag && (ch < ' ' || ch > '~'))
  80050d:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800511:	74 16                	je     800529 <vprintfmt+0x208>
  800513:	8d 50 e0             	lea    -0x20(%eax),%edx
  800516:	83 fa 5e             	cmp    $0x5e,%edx
  800519:	76 0e                	jbe    800529 <vprintfmt+0x208>
					putch('?', putdat);
  80051b:	83 ec 08             	sub    $0x8,%esp
  80051e:	57                   	push   %edi
  80051f:	6a 3f                	push   $0x3f
  800521:	ff 55 08             	call   *0x8(%ebp)
  800524:	83 c4 10             	add    $0x10,%esp
  800527:	eb 0b                	jmp    800534 <vprintfmt+0x213>
				else
					putch(ch, putdat);
  800529:	83 ec 08             	sub    $0x8,%esp
  80052c:	57                   	push   %edi
  80052d:	50                   	push   %eax
  80052e:	ff 55 08             	call   *0x8(%ebp)
  800531:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800534:	ff 4d e4             	decl   -0x1c(%ebp)
  800537:	0f be 03             	movsbl (%ebx),%eax
  80053a:	85 c0                	test   %eax,%eax
  80053c:	74 03                	je     800541 <vprintfmt+0x220>
  80053e:	43                   	inc    %ebx
  80053f:	eb 1b                	jmp    80055c <vprintfmt+0x23b>
  800541:	8b 75 dc             	mov    -0x24(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800544:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800548:	7f 1e                	jg     800568 <vprintfmt+0x247>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80054a:	8b 75 d8             	mov    -0x28(%ebp),%esi
  80054d:	e9 f3 fd ff ff       	jmp    800345 <vprintfmt+0x24>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800552:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800555:	43                   	inc    %ebx
  800556:	89 75 dc             	mov    %esi,-0x24(%ebp)
  800559:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  80055c:	85 f6                	test   %esi,%esi
  80055e:	78 ad                	js     80050d <vprintfmt+0x1ec>
  800560:	4e                   	dec    %esi
  800561:	79 aa                	jns    80050d <vprintfmt+0x1ec>
  800563:	8b 75 dc             	mov    -0x24(%ebp),%esi
  800566:	eb dc                	jmp    800544 <vprintfmt+0x223>
  800568:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80056b:	83 ec 08             	sub    $0x8,%esp
  80056e:	57                   	push   %edi
  80056f:	6a 20                	push   $0x20
  800571:	ff 55 08             	call   *0x8(%ebp)
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800574:	4b                   	dec    %ebx
  800575:	83 c4 10             	add    $0x10,%esp
  800578:	85 db                	test   %ebx,%ebx
  80057a:	7f ef                	jg     80056b <vprintfmt+0x24a>
  80057c:	e9 c4 fd ff ff       	jmp    800345 <vprintfmt+0x24>
  800581:	89 5d d8             	mov    %ebx,-0x28(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800584:	89 ca                	mov    %ecx,%edx
  800586:	8d 45 14             	lea    0x14(%ebp),%eax
  800589:	e8 2a fd ff ff       	call   8002b8 <getint>
  80058e:	89 c3                	mov    %eax,%ebx
  800590:	89 d6                	mov    %edx,%esi
			if ((long long) num < 0) {
  800592:	85 d2                	test   %edx,%edx
  800594:	78 0a                	js     8005a0 <vprintfmt+0x27f>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800596:	b8 0a 00 00 00       	mov    $0xa,%eax
  80059b:	e9 b0 00 00 00       	jmp    800650 <vprintfmt+0x32f>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  8005a0:	83 ec 08             	sub    $0x8,%esp
  8005a3:	57                   	push   %edi
  8005a4:	6a 2d                	push   $0x2d
  8005a6:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8005a9:	f7 db                	neg    %ebx
  8005ab:	83 d6 00             	adc    $0x0,%esi
  8005ae:	f7 de                	neg    %esi
  8005b0:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8005b3:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005b8:	e9 93 00 00 00       	jmp    800650 <vprintfmt+0x32f>
  8005bd:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8005c0:	89 ca                	mov    %ecx,%edx
  8005c2:	8d 45 14             	lea    0x14(%ebp),%eax
  8005c5:	e8 b4 fc ff ff       	call   80027e <getuint>
  8005ca:	89 c3                	mov    %eax,%ebx
  8005cc:	89 d6                	mov    %edx,%esi
			base = 10;
  8005ce:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  8005d3:	eb 7b                	jmp    800650 <vprintfmt+0x32f>
  8005d5:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
  8005d8:	89 ca                	mov    %ecx,%edx
  8005da:	8d 45 14             	lea    0x14(%ebp),%eax
  8005dd:	e8 d6 fc ff ff       	call   8002b8 <getint>
  8005e2:	89 c3                	mov    %eax,%ebx
  8005e4:	89 d6                	mov    %edx,%esi
            if ((long long) num < 0) {
  8005e6:	85 d2                	test   %edx,%edx
  8005e8:	78 07                	js     8005f1 <vprintfmt+0x2d0>
                putch('-', putdat);
                num = -(long long) num;
            }
            base = 8;
  8005ea:	b8 08 00 00 00       	mov    $0x8,%eax
  8005ef:	eb 5f                	jmp    800650 <vprintfmt+0x32f>
		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
            if ((long long) num < 0) {
                putch('-', putdat);
  8005f1:	83 ec 08             	sub    $0x8,%esp
  8005f4:	57                   	push   %edi
  8005f5:	6a 2d                	push   $0x2d
  8005f7:	ff 55 08             	call   *0x8(%ebp)
                num = -(long long) num;
  8005fa:	f7 db                	neg    %ebx
  8005fc:	83 d6 00             	adc    $0x0,%esi
  8005ff:	f7 de                	neg    %esi
  800601:	83 c4 10             	add    $0x10,%esp
            }
            base = 8;
  800604:	b8 08 00 00 00       	mov    $0x8,%eax
  800609:	eb 45                	jmp    800650 <vprintfmt+0x32f>
  80060b:	89 5d d8             	mov    %ebx,-0x28(%ebp)
            goto number;

        // pointer
		case 'p':
			putch('0', putdat);
  80060e:	83 ec 08             	sub    $0x8,%esp
  800611:	57                   	push   %edi
  800612:	6a 30                	push   $0x30
  800614:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800617:	83 c4 08             	add    $0x8,%esp
  80061a:	57                   	push   %edi
  80061b:	6a 78                	push   $0x78
  80061d:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800620:	8b 45 14             	mov    0x14(%ebp),%eax
  800623:	8d 50 04             	lea    0x4(%eax),%edx
  800626:	89 55 14             	mov    %edx,0x14(%ebp)

        // pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800629:	8b 18                	mov    (%eax),%ebx
  80062b:	be 00 00 00 00       	mov    $0x0,%esi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800630:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800633:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800638:	eb 16                	jmp    800650 <vprintfmt+0x32f>
  80063a:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80063d:	89 ca                	mov    %ecx,%edx
  80063f:	8d 45 14             	lea    0x14(%ebp),%eax
  800642:	e8 37 fc ff ff       	call   80027e <getuint>
  800647:	89 c3                	mov    %eax,%ebx
  800649:	89 d6                	mov    %edx,%esi
			base = 16;
  80064b:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800650:	83 ec 0c             	sub    $0xc,%esp
  800653:	0f be 55 dc          	movsbl -0x24(%ebp),%edx
  800657:	52                   	push   %edx
  800658:	ff 75 e4             	pushl  -0x1c(%ebp)
  80065b:	50                   	push   %eax
  80065c:	56                   	push   %esi
  80065d:	53                   	push   %ebx
  80065e:	89 fa                	mov    %edi,%edx
  800660:	8b 45 08             	mov    0x8(%ebp),%eax
  800663:	e8 68 fb ff ff       	call   8001d0 <printnum>
			break;
  800668:	83 c4 20             	add    $0x20,%esp
  80066b:	8b 75 d8             	mov    -0x28(%ebp),%esi
  80066e:	e9 d2 fc ff ff       	jmp    800345 <vprintfmt+0x24>
  800673:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800676:	83 ec 08             	sub    $0x8,%esp
  800679:	57                   	push   %edi
  80067a:	52                   	push   %edx
  80067b:	ff 55 08             	call   *0x8(%ebp)
			break;
  80067e:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800681:	8b 75 d8             	mov    -0x28(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800684:	e9 bc fc ff ff       	jmp    800345 <vprintfmt+0x24>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800689:	83 ec 08             	sub    $0x8,%esp
  80068c:	57                   	push   %edi
  80068d:	6a 25                	push   $0x25
  80068f:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800692:	83 c4 10             	add    $0x10,%esp
  800695:	eb 02                	jmp    800699 <vprintfmt+0x378>
  800697:	89 c6                	mov    %eax,%esi
  800699:	8d 46 ff             	lea    -0x1(%esi),%eax
  80069c:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  8006a0:	75 f5                	jne    800697 <vprintfmt+0x376>
  8006a2:	e9 9e fc ff ff       	jmp    800345 <vprintfmt+0x24>
				/* do nothing */;
			break;
		}
	}
}
  8006a7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006aa:	5b                   	pop    %ebx
  8006ab:	5e                   	pop    %esi
  8006ac:	5f                   	pop    %edi
  8006ad:	c9                   	leave  
  8006ae:	c3                   	ret    

008006af <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006af:	55                   	push   %ebp
  8006b0:	89 e5                	mov    %esp,%ebp
  8006b2:	83 ec 18             	sub    $0x18,%esp
  8006b5:	8b 45 08             	mov    0x8(%ebp),%eax
  8006b8:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006bb:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006be:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8006c2:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8006c5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8006cc:	85 c0                	test   %eax,%eax
  8006ce:	74 26                	je     8006f6 <vsnprintf+0x47>
  8006d0:	85 d2                	test   %edx,%edx
  8006d2:	7e 29                	jle    8006fd <vsnprintf+0x4e>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8006d4:	ff 75 14             	pushl  0x14(%ebp)
  8006d7:	ff 75 10             	pushl  0x10(%ebp)
  8006da:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8006dd:	50                   	push   %eax
  8006de:	68 ea 02 80 00       	push   $0x8002ea
  8006e3:	e8 39 fc ff ff       	call   800321 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8006e8:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8006eb:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8006ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006f1:	83 c4 10             	add    $0x10,%esp
  8006f4:	eb 0c                	jmp    800702 <vsnprintf+0x53>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8006f6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8006fb:	eb 05                	jmp    800702 <vsnprintf+0x53>
  8006fd:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800702:	c9                   	leave  
  800703:	c3                   	ret    

00800704 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800704:	55                   	push   %ebp
  800705:	89 e5                	mov    %esp,%ebp
  800707:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80070a:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80070d:	50                   	push   %eax
  80070e:	ff 75 10             	pushl  0x10(%ebp)
  800711:	ff 75 0c             	pushl  0xc(%ebp)
  800714:	ff 75 08             	pushl  0x8(%ebp)
  800717:	e8 93 ff ff ff       	call   8006af <vsnprintf>
	va_end(ap);

	return rc;
}
  80071c:	c9                   	leave  
  80071d:	c3                   	ret    
	...

00800720 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800720:	55                   	push   %ebp
  800721:	89 e5                	mov    %esp,%ebp
  800723:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800726:	80 3a 00             	cmpb   $0x0,(%edx)
  800729:	74 0e                	je     800739 <strlen+0x19>
  80072b:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800730:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800731:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800735:	75 f9                	jne    800730 <strlen+0x10>
  800737:	eb 05                	jmp    80073e <strlen+0x1e>
  800739:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  80073e:	c9                   	leave  
  80073f:	c3                   	ret    

00800740 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800740:	55                   	push   %ebp
  800741:	89 e5                	mov    %esp,%ebp
  800743:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800746:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800749:	85 d2                	test   %edx,%edx
  80074b:	74 17                	je     800764 <strnlen+0x24>
  80074d:	80 39 00             	cmpb   $0x0,(%ecx)
  800750:	74 19                	je     80076b <strnlen+0x2b>
  800752:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800757:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800758:	39 d0                	cmp    %edx,%eax
  80075a:	74 14                	je     800770 <strnlen+0x30>
  80075c:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800760:	75 f5                	jne    800757 <strnlen+0x17>
  800762:	eb 0c                	jmp    800770 <strnlen+0x30>
  800764:	b8 00 00 00 00       	mov    $0x0,%eax
  800769:	eb 05                	jmp    800770 <strnlen+0x30>
  80076b:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800770:	c9                   	leave  
  800771:	c3                   	ret    

00800772 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800772:	55                   	push   %ebp
  800773:	89 e5                	mov    %esp,%ebp
  800775:	53                   	push   %ebx
  800776:	8b 45 08             	mov    0x8(%ebp),%eax
  800779:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80077c:	ba 00 00 00 00       	mov    $0x0,%edx
  800781:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  800784:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800787:	42                   	inc    %edx
  800788:	84 c9                	test   %cl,%cl
  80078a:	75 f5                	jne    800781 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  80078c:	5b                   	pop    %ebx
  80078d:	c9                   	leave  
  80078e:	c3                   	ret    

0080078f <strcat>:

char *
strcat(char *dst, const char *src)
{
  80078f:	55                   	push   %ebp
  800790:	89 e5                	mov    %esp,%ebp
  800792:	53                   	push   %ebx
  800793:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800796:	53                   	push   %ebx
  800797:	e8 84 ff ff ff       	call   800720 <strlen>
  80079c:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  80079f:	ff 75 0c             	pushl  0xc(%ebp)
  8007a2:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  8007a5:	50                   	push   %eax
  8007a6:	e8 c7 ff ff ff       	call   800772 <strcpy>
	return dst;
}
  8007ab:	89 d8                	mov    %ebx,%eax
  8007ad:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007b0:	c9                   	leave  
  8007b1:	c3                   	ret    

008007b2 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007b2:	55                   	push   %ebp
  8007b3:	89 e5                	mov    %esp,%ebp
  8007b5:	56                   	push   %esi
  8007b6:	53                   	push   %ebx
  8007b7:	8b 45 08             	mov    0x8(%ebp),%eax
  8007ba:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007bd:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007c0:	85 f6                	test   %esi,%esi
  8007c2:	74 15                	je     8007d9 <strncpy+0x27>
  8007c4:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  8007c9:	8a 1a                	mov    (%edx),%bl
  8007cb:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007ce:	80 3a 01             	cmpb   $0x1,(%edx)
  8007d1:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007d4:	41                   	inc    %ecx
  8007d5:	39 ce                	cmp    %ecx,%esi
  8007d7:	77 f0                	ja     8007c9 <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8007d9:	5b                   	pop    %ebx
  8007da:	5e                   	pop    %esi
  8007db:	c9                   	leave  
  8007dc:	c3                   	ret    

008007dd <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8007dd:	55                   	push   %ebp
  8007de:	89 e5                	mov    %esp,%ebp
  8007e0:	57                   	push   %edi
  8007e1:	56                   	push   %esi
  8007e2:	53                   	push   %ebx
  8007e3:	8b 7d 08             	mov    0x8(%ebp),%edi
  8007e6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8007e9:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007ec:	85 f6                	test   %esi,%esi
  8007ee:	74 32                	je     800822 <strlcpy+0x45>
		while (--size > 0 && *src != '\0')
  8007f0:	83 fe 01             	cmp    $0x1,%esi
  8007f3:	74 22                	je     800817 <strlcpy+0x3a>
  8007f5:	8a 0b                	mov    (%ebx),%cl
  8007f7:	84 c9                	test   %cl,%cl
  8007f9:	74 20                	je     80081b <strlcpy+0x3e>
  8007fb:	89 f8                	mov    %edi,%eax
  8007fd:	ba 00 00 00 00       	mov    $0x0,%edx
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
  800802:	83 ee 02             	sub    $0x2,%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800805:	88 08                	mov    %cl,(%eax)
  800807:	40                   	inc    %eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800808:	39 f2                	cmp    %esi,%edx
  80080a:	74 11                	je     80081d <strlcpy+0x40>
  80080c:	8a 4c 13 01          	mov    0x1(%ebx,%edx,1),%cl
  800810:	42                   	inc    %edx
  800811:	84 c9                	test   %cl,%cl
  800813:	75 f0                	jne    800805 <strlcpy+0x28>
  800815:	eb 06                	jmp    80081d <strlcpy+0x40>
  800817:	89 f8                	mov    %edi,%eax
  800819:	eb 02                	jmp    80081d <strlcpy+0x40>
  80081b:	89 f8                	mov    %edi,%eax
			*dst++ = *src++;
		*dst = '\0';
  80081d:	c6 00 00             	movb   $0x0,(%eax)
  800820:	eb 02                	jmp    800824 <strlcpy+0x47>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800822:	89 f8                	mov    %edi,%eax
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
		*dst = '\0';
	}
	return dst - dst_in;
  800824:	29 f8                	sub    %edi,%eax
}
  800826:	5b                   	pop    %ebx
  800827:	5e                   	pop    %esi
  800828:	5f                   	pop    %edi
  800829:	c9                   	leave  
  80082a:	c3                   	ret    

0080082b <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80082b:	55                   	push   %ebp
  80082c:	89 e5                	mov    %esp,%ebp
  80082e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800831:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800834:	8a 01                	mov    (%ecx),%al
  800836:	84 c0                	test   %al,%al
  800838:	74 10                	je     80084a <strcmp+0x1f>
  80083a:	3a 02                	cmp    (%edx),%al
  80083c:	75 0c                	jne    80084a <strcmp+0x1f>
		p++, q++;
  80083e:	41                   	inc    %ecx
  80083f:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800840:	8a 01                	mov    (%ecx),%al
  800842:	84 c0                	test   %al,%al
  800844:	74 04                	je     80084a <strcmp+0x1f>
  800846:	3a 02                	cmp    (%edx),%al
  800848:	74 f4                	je     80083e <strcmp+0x13>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80084a:	0f b6 c0             	movzbl %al,%eax
  80084d:	0f b6 12             	movzbl (%edx),%edx
  800850:	29 d0                	sub    %edx,%eax
}
  800852:	c9                   	leave  
  800853:	c3                   	ret    

00800854 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800854:	55                   	push   %ebp
  800855:	89 e5                	mov    %esp,%ebp
  800857:	53                   	push   %ebx
  800858:	8b 55 08             	mov    0x8(%ebp),%edx
  80085b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80085e:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  800861:	85 c0                	test   %eax,%eax
  800863:	74 1b                	je     800880 <strncmp+0x2c>
  800865:	8a 1a                	mov    (%edx),%bl
  800867:	84 db                	test   %bl,%bl
  800869:	74 24                	je     80088f <strncmp+0x3b>
  80086b:	3a 19                	cmp    (%ecx),%bl
  80086d:	75 20                	jne    80088f <strncmp+0x3b>
  80086f:	48                   	dec    %eax
  800870:	74 15                	je     800887 <strncmp+0x33>
		n--, p++, q++;
  800872:	42                   	inc    %edx
  800873:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800874:	8a 1a                	mov    (%edx),%bl
  800876:	84 db                	test   %bl,%bl
  800878:	74 15                	je     80088f <strncmp+0x3b>
  80087a:	3a 19                	cmp    (%ecx),%bl
  80087c:	74 f1                	je     80086f <strncmp+0x1b>
  80087e:	eb 0f                	jmp    80088f <strncmp+0x3b>
		n--, p++, q++;
	if (n == 0)
		return 0;
  800880:	b8 00 00 00 00       	mov    $0x0,%eax
  800885:	eb 05                	jmp    80088c <strncmp+0x38>
  800887:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80088c:	5b                   	pop    %ebx
  80088d:	c9                   	leave  
  80088e:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80088f:	0f b6 02             	movzbl (%edx),%eax
  800892:	0f b6 11             	movzbl (%ecx),%edx
  800895:	29 d0                	sub    %edx,%eax
  800897:	eb f3                	jmp    80088c <strncmp+0x38>

00800899 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800899:	55                   	push   %ebp
  80089a:	89 e5                	mov    %esp,%ebp
  80089c:	8b 45 08             	mov    0x8(%ebp),%eax
  80089f:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8008a2:	8a 10                	mov    (%eax),%dl
  8008a4:	84 d2                	test   %dl,%dl
  8008a6:	74 18                	je     8008c0 <strchr+0x27>
		if (*s == c)
  8008a8:	38 ca                	cmp    %cl,%dl
  8008aa:	75 06                	jne    8008b2 <strchr+0x19>
  8008ac:	eb 17                	jmp    8008c5 <strchr+0x2c>
  8008ae:	38 ca                	cmp    %cl,%dl
  8008b0:	74 13                	je     8008c5 <strchr+0x2c>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8008b2:	40                   	inc    %eax
  8008b3:	8a 10                	mov    (%eax),%dl
  8008b5:	84 d2                	test   %dl,%dl
  8008b7:	75 f5                	jne    8008ae <strchr+0x15>
		if (*s == c)
			return (char *) s;
	return 0;
  8008b9:	b8 00 00 00 00       	mov    $0x0,%eax
  8008be:	eb 05                	jmp    8008c5 <strchr+0x2c>
  8008c0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008c5:	c9                   	leave  
  8008c6:	c3                   	ret    

008008c7 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008c7:	55                   	push   %ebp
  8008c8:	89 e5                	mov    %esp,%ebp
  8008ca:	8b 45 08             	mov    0x8(%ebp),%eax
  8008cd:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8008d0:	8a 10                	mov    (%eax),%dl
  8008d2:	84 d2                	test   %dl,%dl
  8008d4:	74 11                	je     8008e7 <strfind+0x20>
		if (*s == c)
  8008d6:	38 ca                	cmp    %cl,%dl
  8008d8:	75 06                	jne    8008e0 <strfind+0x19>
  8008da:	eb 0b                	jmp    8008e7 <strfind+0x20>
  8008dc:	38 ca                	cmp    %cl,%dl
  8008de:	74 07                	je     8008e7 <strfind+0x20>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  8008e0:	40                   	inc    %eax
  8008e1:	8a 10                	mov    (%eax),%dl
  8008e3:	84 d2                	test   %dl,%dl
  8008e5:	75 f5                	jne    8008dc <strfind+0x15>
		if (*s == c)
			break;
	return (char *) s;
}
  8008e7:	c9                   	leave  
  8008e8:	c3                   	ret    

008008e9 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008e9:	55                   	push   %ebp
  8008ea:	89 e5                	mov    %esp,%ebp
  8008ec:	57                   	push   %edi
  8008ed:	56                   	push   %esi
  8008ee:	53                   	push   %ebx
  8008ef:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008f2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008f5:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8008f8:	85 c9                	test   %ecx,%ecx
  8008fa:	74 30                	je     80092c <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008fc:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800902:	75 25                	jne    800929 <memset+0x40>
  800904:	f6 c1 03             	test   $0x3,%cl
  800907:	75 20                	jne    800929 <memset+0x40>
		c &= 0xFF;
  800909:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80090c:	89 d3                	mov    %edx,%ebx
  80090e:	c1 e3 08             	shl    $0x8,%ebx
  800911:	89 d6                	mov    %edx,%esi
  800913:	c1 e6 18             	shl    $0x18,%esi
  800916:	89 d0                	mov    %edx,%eax
  800918:	c1 e0 10             	shl    $0x10,%eax
  80091b:	09 f0                	or     %esi,%eax
  80091d:	09 d0                	or     %edx,%eax
  80091f:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800921:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800924:	fc                   	cld    
  800925:	f3 ab                	rep stos %eax,%es:(%edi)
  800927:	eb 03                	jmp    80092c <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800929:	fc                   	cld    
  80092a:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80092c:	89 f8                	mov    %edi,%eax
  80092e:	5b                   	pop    %ebx
  80092f:	5e                   	pop    %esi
  800930:	5f                   	pop    %edi
  800931:	c9                   	leave  
  800932:	c3                   	ret    

00800933 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800933:	55                   	push   %ebp
  800934:	89 e5                	mov    %esp,%ebp
  800936:	57                   	push   %edi
  800937:	56                   	push   %esi
  800938:	8b 45 08             	mov    0x8(%ebp),%eax
  80093b:	8b 75 0c             	mov    0xc(%ebp),%esi
  80093e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800941:	39 c6                	cmp    %eax,%esi
  800943:	73 34                	jae    800979 <memmove+0x46>
  800945:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800948:	39 d0                	cmp    %edx,%eax
  80094a:	73 2d                	jae    800979 <memmove+0x46>
		s += n;
		d += n;
  80094c:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80094f:	f6 c2 03             	test   $0x3,%dl
  800952:	75 1b                	jne    80096f <memmove+0x3c>
  800954:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80095a:	75 13                	jne    80096f <memmove+0x3c>
  80095c:	f6 c1 03             	test   $0x3,%cl
  80095f:	75 0e                	jne    80096f <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800961:	83 ef 04             	sub    $0x4,%edi
  800964:	8d 72 fc             	lea    -0x4(%edx),%esi
  800967:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  80096a:	fd                   	std    
  80096b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80096d:	eb 07                	jmp    800976 <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  80096f:	4f                   	dec    %edi
  800970:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800973:	fd                   	std    
  800974:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800976:	fc                   	cld    
  800977:	eb 20                	jmp    800999 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800979:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80097f:	75 13                	jne    800994 <memmove+0x61>
  800981:	a8 03                	test   $0x3,%al
  800983:	75 0f                	jne    800994 <memmove+0x61>
  800985:	f6 c1 03             	test   $0x3,%cl
  800988:	75 0a                	jne    800994 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  80098a:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  80098d:	89 c7                	mov    %eax,%edi
  80098f:	fc                   	cld    
  800990:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800992:	eb 05                	jmp    800999 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800994:	89 c7                	mov    %eax,%edi
  800996:	fc                   	cld    
  800997:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800999:	5e                   	pop    %esi
  80099a:	5f                   	pop    %edi
  80099b:	c9                   	leave  
  80099c:	c3                   	ret    

0080099d <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  80099d:	55                   	push   %ebp
  80099e:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8009a0:	ff 75 10             	pushl  0x10(%ebp)
  8009a3:	ff 75 0c             	pushl  0xc(%ebp)
  8009a6:	ff 75 08             	pushl  0x8(%ebp)
  8009a9:	e8 85 ff ff ff       	call   800933 <memmove>
}
  8009ae:	c9                   	leave  
  8009af:	c3                   	ret    

008009b0 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009b0:	55                   	push   %ebp
  8009b1:	89 e5                	mov    %esp,%ebp
  8009b3:	57                   	push   %edi
  8009b4:	56                   	push   %esi
  8009b5:	53                   	push   %ebx
  8009b6:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8009b9:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009bc:	8b 7d 10             	mov    0x10(%ebp),%edi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009bf:	85 ff                	test   %edi,%edi
  8009c1:	74 32                	je     8009f5 <memcmp+0x45>
		if (*s1 != *s2)
  8009c3:	8a 03                	mov    (%ebx),%al
  8009c5:	8a 0e                	mov    (%esi),%cl
  8009c7:	38 c8                	cmp    %cl,%al
  8009c9:	74 19                	je     8009e4 <memcmp+0x34>
  8009cb:	eb 0d                	jmp    8009da <memcmp+0x2a>
  8009cd:	8a 44 13 01          	mov    0x1(%ebx,%edx,1),%al
  8009d1:	8a 4c 16 01          	mov    0x1(%esi,%edx,1),%cl
  8009d5:	42                   	inc    %edx
  8009d6:	38 c8                	cmp    %cl,%al
  8009d8:	74 10                	je     8009ea <memcmp+0x3a>
			return (int) *s1 - (int) *s2;
  8009da:	0f b6 c0             	movzbl %al,%eax
  8009dd:	0f b6 c9             	movzbl %cl,%ecx
  8009e0:	29 c8                	sub    %ecx,%eax
  8009e2:	eb 16                	jmp    8009fa <memcmp+0x4a>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009e4:	4f                   	dec    %edi
  8009e5:	ba 00 00 00 00       	mov    $0x0,%edx
  8009ea:	39 fa                	cmp    %edi,%edx
  8009ec:	75 df                	jne    8009cd <memcmp+0x1d>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8009ee:	b8 00 00 00 00       	mov    $0x0,%eax
  8009f3:	eb 05                	jmp    8009fa <memcmp+0x4a>
  8009f5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009fa:	5b                   	pop    %ebx
  8009fb:	5e                   	pop    %esi
  8009fc:	5f                   	pop    %edi
  8009fd:	c9                   	leave  
  8009fe:	c3                   	ret    

008009ff <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009ff:	55                   	push   %ebp
  800a00:	89 e5                	mov    %esp,%ebp
  800a02:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800a05:	89 c2                	mov    %eax,%edx
  800a07:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a0a:	39 d0                	cmp    %edx,%eax
  800a0c:	73 12                	jae    800a20 <memfind+0x21>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a0e:	8a 4d 0c             	mov    0xc(%ebp),%cl
  800a11:	38 08                	cmp    %cl,(%eax)
  800a13:	75 06                	jne    800a1b <memfind+0x1c>
  800a15:	eb 09                	jmp    800a20 <memfind+0x21>
  800a17:	38 08                	cmp    %cl,(%eax)
  800a19:	74 05                	je     800a20 <memfind+0x21>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a1b:	40                   	inc    %eax
  800a1c:	39 c2                	cmp    %eax,%edx
  800a1e:	77 f7                	ja     800a17 <memfind+0x18>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a20:	c9                   	leave  
  800a21:	c3                   	ret    

00800a22 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a22:	55                   	push   %ebp
  800a23:	89 e5                	mov    %esp,%ebp
  800a25:	57                   	push   %edi
  800a26:	56                   	push   %esi
  800a27:	53                   	push   %ebx
  800a28:	8b 55 08             	mov    0x8(%ebp),%edx
  800a2b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a2e:	eb 01                	jmp    800a31 <strtol+0xf>
		s++;
  800a30:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a31:	8a 02                	mov    (%edx),%al
  800a33:	3c 20                	cmp    $0x20,%al
  800a35:	74 f9                	je     800a30 <strtol+0xe>
  800a37:	3c 09                	cmp    $0x9,%al
  800a39:	74 f5                	je     800a30 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a3b:	3c 2b                	cmp    $0x2b,%al
  800a3d:	75 08                	jne    800a47 <strtol+0x25>
		s++;
  800a3f:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a40:	bf 00 00 00 00       	mov    $0x0,%edi
  800a45:	eb 13                	jmp    800a5a <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a47:	3c 2d                	cmp    $0x2d,%al
  800a49:	75 0a                	jne    800a55 <strtol+0x33>
		s++, neg = 1;
  800a4b:	8d 52 01             	lea    0x1(%edx),%edx
  800a4e:	bf 01 00 00 00       	mov    $0x1,%edi
  800a53:	eb 05                	jmp    800a5a <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a55:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a5a:	85 db                	test   %ebx,%ebx
  800a5c:	74 05                	je     800a63 <strtol+0x41>
  800a5e:	83 fb 10             	cmp    $0x10,%ebx
  800a61:	75 28                	jne    800a8b <strtol+0x69>
  800a63:	8a 02                	mov    (%edx),%al
  800a65:	3c 30                	cmp    $0x30,%al
  800a67:	75 10                	jne    800a79 <strtol+0x57>
  800a69:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800a6d:	75 0a                	jne    800a79 <strtol+0x57>
		s += 2, base = 16;
  800a6f:	83 c2 02             	add    $0x2,%edx
  800a72:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a77:	eb 12                	jmp    800a8b <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800a79:	85 db                	test   %ebx,%ebx
  800a7b:	75 0e                	jne    800a8b <strtol+0x69>
  800a7d:	3c 30                	cmp    $0x30,%al
  800a7f:	75 05                	jne    800a86 <strtol+0x64>
		s++, base = 8;
  800a81:	42                   	inc    %edx
  800a82:	b3 08                	mov    $0x8,%bl
  800a84:	eb 05                	jmp    800a8b <strtol+0x69>
	else if (base == 0)
		base = 10;
  800a86:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800a8b:	b8 00 00 00 00       	mov    $0x0,%eax
  800a90:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a92:	8a 0a                	mov    (%edx),%cl
  800a94:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800a97:	80 fb 09             	cmp    $0x9,%bl
  800a9a:	77 08                	ja     800aa4 <strtol+0x82>
			dig = *s - '0';
  800a9c:	0f be c9             	movsbl %cl,%ecx
  800a9f:	83 e9 30             	sub    $0x30,%ecx
  800aa2:	eb 1e                	jmp    800ac2 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800aa4:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800aa7:	80 fb 19             	cmp    $0x19,%bl
  800aaa:	77 08                	ja     800ab4 <strtol+0x92>
			dig = *s - 'a' + 10;
  800aac:	0f be c9             	movsbl %cl,%ecx
  800aaf:	83 e9 57             	sub    $0x57,%ecx
  800ab2:	eb 0e                	jmp    800ac2 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800ab4:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800ab7:	80 fb 19             	cmp    $0x19,%bl
  800aba:	77 13                	ja     800acf <strtol+0xad>
			dig = *s - 'A' + 10;
  800abc:	0f be c9             	movsbl %cl,%ecx
  800abf:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800ac2:	39 f1                	cmp    %esi,%ecx
  800ac4:	7d 0d                	jge    800ad3 <strtol+0xb1>
			break;
		s++, val = (val * base) + dig;
  800ac6:	42                   	inc    %edx
  800ac7:	0f af c6             	imul   %esi,%eax
  800aca:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  800acd:	eb c3                	jmp    800a92 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800acf:	89 c1                	mov    %eax,%ecx
  800ad1:	eb 02                	jmp    800ad5 <strtol+0xb3>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800ad3:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800ad5:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ad9:	74 05                	je     800ae0 <strtol+0xbe>
		*endptr = (char *) s;
  800adb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800ade:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800ae0:	85 ff                	test   %edi,%edi
  800ae2:	74 04                	je     800ae8 <strtol+0xc6>
  800ae4:	89 c8                	mov    %ecx,%eax
  800ae6:	f7 d8                	neg    %eax
}
  800ae8:	5b                   	pop    %ebx
  800ae9:	5e                   	pop    %esi
  800aea:	5f                   	pop    %edi
  800aeb:	c9                   	leave  
  800aec:	c3                   	ret    
  800aed:	00 00                	add    %al,(%eax)
	...

00800af0 <syscall>:
	return ret;
}

static int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800af0:	55                   	push   %ebp
  800af1:	89 e5                	mov    %esp,%ebp
  800af3:	57                   	push   %edi
  800af4:	56                   	push   %esi
  800af5:	53                   	push   %ebx
  800af6:	83 ec 1c             	sub    $0x1c,%esp
  800af9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800afc:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800aff:	89 ca                	mov    %ecx,%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b01:	8b 75 14             	mov    0x14(%ebp),%esi
  800b04:	8b 7d 10             	mov    0x10(%ebp),%edi
  800b07:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800b0a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b0d:	cd 30                	int    $0x30
  800b0f:	89 c2                	mov    %eax,%edx
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b11:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800b15:	74 1c                	je     800b33 <syscall+0x43>
  800b17:	85 c0                	test   %eax,%eax
  800b19:	7e 18                	jle    800b33 <syscall+0x43>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b1b:	83 ec 0c             	sub    $0xc,%esp
  800b1e:	50                   	push   %eax
  800b1f:	ff 75 e4             	pushl  -0x1c(%ebp)
  800b22:	68 ff 24 80 00       	push   $0x8024ff
  800b27:	6a 42                	push   $0x42
  800b29:	68 1c 25 80 00       	push   $0x80251c
  800b2e:	e8 21 13 00 00       	call   801e54 <_panic>

	return ret;
}
  800b33:	89 d0                	mov    %edx,%eax
  800b35:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b38:	5b                   	pop    %ebx
  800b39:	5e                   	pop    %esi
  800b3a:	5f                   	pop    %edi
  800b3b:	c9                   	leave  
  800b3c:	c3                   	ret    

00800b3d <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{	
  800b3d:	55                   	push   %ebp
  800b3e:	89 e5                	mov    %esp,%ebp
  800b40:	83 ec 08             	sub    $0x8,%esp
	// my_sysenter(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
	// return;
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  800b43:	6a 00                	push   $0x0
  800b45:	6a 00                	push   $0x0
  800b47:	6a 00                	push   $0x0
  800b49:	ff 75 0c             	pushl  0xc(%ebp)
  800b4c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b4f:	ba 00 00 00 00       	mov    $0x0,%edx
  800b54:	b8 00 00 00 00       	mov    $0x0,%eax
  800b59:	e8 92 ff ff ff       	call   800af0 <syscall>
  800b5e:	83 c4 10             	add    $0x10,%esp
	return;
}
  800b61:	c9                   	leave  
  800b62:	c3                   	ret    

00800b63 <sys_cgetc>:

int
sys_cgetc(void)
{
  800b63:	55                   	push   %ebp
  800b64:	89 e5                	mov    %esp,%ebp
  800b66:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_cgetc, 0, 0, 0, 0, 0, 0);
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  800b69:	6a 00                	push   $0x0
  800b6b:	6a 00                	push   $0x0
  800b6d:	6a 00                	push   $0x0
  800b6f:	6a 00                	push   $0x0
  800b71:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b76:	ba 00 00 00 00       	mov    $0x0,%edx
  800b7b:	b8 01 00 00 00       	mov    $0x1,%eax
  800b80:	e8 6b ff ff ff       	call   800af0 <syscall>
}
  800b85:	c9                   	leave  
  800b86:	c3                   	ret    

00800b87 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b87:	55                   	push   %ebp
  800b88:	89 e5                	mov    %esp,%ebp
  800b8a:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  800b8d:	6a 00                	push   $0x0
  800b8f:	6a 00                	push   $0x0
  800b91:	6a 00                	push   $0x0
  800b93:	6a 00                	push   $0x0
  800b95:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b98:	ba 01 00 00 00       	mov    $0x1,%edx
  800b9d:	b8 03 00 00 00       	mov    $0x3,%eax
  800ba2:	e8 49 ff ff ff       	call   800af0 <syscall>
}
  800ba7:	c9                   	leave  
  800ba8:	c3                   	ret    

00800ba9 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800ba9:	55                   	push   %ebp
  800baa:	89 e5                	mov    %esp,%ebp
  800bac:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_getenvid, 0, 0, 0, 0, 0, 0);
	return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  800baf:	6a 00                	push   $0x0
  800bb1:	6a 00                	push   $0x0
  800bb3:	6a 00                	push   $0x0
  800bb5:	6a 00                	push   $0x0
  800bb7:	b9 00 00 00 00       	mov    $0x0,%ecx
  800bbc:	ba 00 00 00 00       	mov    $0x0,%edx
  800bc1:	b8 02 00 00 00       	mov    $0x2,%eax
  800bc6:	e8 25 ff ff ff       	call   800af0 <syscall>
}
  800bcb:	c9                   	leave  
  800bcc:	c3                   	ret    

00800bcd <sys_yield>:

void
sys_yield(void)
{
  800bcd:	55                   	push   %ebp
  800bce:	89 e5                	mov    %esp,%ebp
  800bd0:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  800bd3:	6a 00                	push   $0x0
  800bd5:	6a 00                	push   $0x0
  800bd7:	6a 00                	push   $0x0
  800bd9:	6a 00                	push   $0x0
  800bdb:	b9 00 00 00 00       	mov    $0x0,%ecx
  800be0:	ba 00 00 00 00       	mov    $0x0,%edx
  800be5:	b8 0b 00 00 00       	mov    $0xb,%eax
  800bea:	e8 01 ff ff ff       	call   800af0 <syscall>
  800bef:	83 c4 10             	add    $0x10,%esp
}
  800bf2:	c9                   	leave  
  800bf3:	c3                   	ret    

00800bf4 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800bf4:	55                   	push   %ebp
  800bf5:	89 e5                	mov    %esp,%ebp
  800bf7:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  800bfa:	6a 00                	push   $0x0
  800bfc:	6a 00                	push   $0x0
  800bfe:	ff 75 10             	pushl  0x10(%ebp)
  800c01:	ff 75 0c             	pushl  0xc(%ebp)
  800c04:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c07:	ba 01 00 00 00       	mov    $0x1,%edx
  800c0c:	b8 04 00 00 00       	mov    $0x4,%eax
  800c11:	e8 da fe ff ff       	call   800af0 <syscall>
}
  800c16:	c9                   	leave  
  800c17:	c3                   	ret    

00800c18 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c18:	55                   	push   %ebp
  800c19:	89 e5                	mov    %esp,%ebp
  800c1b:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
  800c1e:	ff 75 18             	pushl  0x18(%ebp)
  800c21:	ff 75 14             	pushl  0x14(%ebp)
  800c24:	ff 75 10             	pushl  0x10(%ebp)
  800c27:	ff 75 0c             	pushl  0xc(%ebp)
  800c2a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c2d:	ba 01 00 00 00       	mov    $0x1,%edx
  800c32:	b8 05 00 00 00       	mov    $0x5,%eax
  800c37:	e8 b4 fe ff ff       	call   800af0 <syscall>
}
  800c3c:	c9                   	leave  
  800c3d:	c3                   	ret    

00800c3e <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c3e:	55                   	push   %ebp
  800c3f:	89 e5                	mov    %esp,%ebp
  800c41:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  800c44:	6a 00                	push   $0x0
  800c46:	6a 00                	push   $0x0
  800c48:	6a 00                	push   $0x0
  800c4a:	ff 75 0c             	pushl  0xc(%ebp)
  800c4d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c50:	ba 01 00 00 00       	mov    $0x1,%edx
  800c55:	b8 06 00 00 00       	mov    $0x6,%eax
  800c5a:	e8 91 fe ff ff       	call   800af0 <syscall>
}
  800c5f:	c9                   	leave  
  800c60:	c3                   	ret    

00800c61 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c61:	55                   	push   %ebp
  800c62:	89 e5                	mov    %esp,%ebp
  800c64:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  800c67:	6a 00                	push   $0x0
  800c69:	6a 00                	push   $0x0
  800c6b:	6a 00                	push   $0x0
  800c6d:	ff 75 0c             	pushl  0xc(%ebp)
  800c70:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c73:	ba 01 00 00 00       	mov    $0x1,%edx
  800c78:	b8 08 00 00 00       	mov    $0x8,%eax
  800c7d:	e8 6e fe ff ff       	call   800af0 <syscall>
}
  800c82:	c9                   	leave  
  800c83:	c3                   	ret    

00800c84 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800c84:	55                   	push   %ebp
  800c85:	89 e5                	mov    %esp,%ebp
  800c87:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
  800c8a:	6a 00                	push   $0x0
  800c8c:	6a 00                	push   $0x0
  800c8e:	6a 00                	push   $0x0
  800c90:	ff 75 0c             	pushl  0xc(%ebp)
  800c93:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c96:	ba 01 00 00 00       	mov    $0x1,%edx
  800c9b:	b8 09 00 00 00       	mov    $0x9,%eax
  800ca0:	e8 4b fe ff ff       	call   800af0 <syscall>
}
  800ca5:	c9                   	leave  
  800ca6:	c3                   	ret    

00800ca7 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800ca7:	55                   	push   %ebp
  800ca8:	89 e5                	mov    %esp,%ebp
  800caa:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  800cad:	6a 00                	push   $0x0
  800caf:	6a 00                	push   $0x0
  800cb1:	6a 00                	push   $0x0
  800cb3:	ff 75 0c             	pushl  0xc(%ebp)
  800cb6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800cb9:	ba 01 00 00 00       	mov    $0x1,%edx
  800cbe:	b8 0a 00 00 00       	mov    $0xa,%eax
  800cc3:	e8 28 fe ff ff       	call   800af0 <syscall>
}
  800cc8:	c9                   	leave  
  800cc9:	c3                   	ret    

00800cca <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800cca:	55                   	push   %ebp
  800ccb:	89 e5                	mov    %esp,%ebp
  800ccd:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  800cd0:	6a 00                	push   $0x0
  800cd2:	ff 75 14             	pushl  0x14(%ebp)
  800cd5:	ff 75 10             	pushl  0x10(%ebp)
  800cd8:	ff 75 0c             	pushl  0xc(%ebp)
  800cdb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800cde:	ba 00 00 00 00       	mov    $0x0,%edx
  800ce3:	b8 0c 00 00 00       	mov    $0xc,%eax
  800ce8:	e8 03 fe ff ff       	call   800af0 <syscall>
}
  800ced:	c9                   	leave  
  800cee:	c3                   	ret    

00800cef <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800cef:	55                   	push   %ebp
  800cf0:	89 e5                	mov    %esp,%ebp
  800cf2:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  800cf5:	6a 00                	push   $0x0
  800cf7:	6a 00                	push   $0x0
  800cf9:	6a 00                	push   $0x0
  800cfb:	6a 00                	push   $0x0
  800cfd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d00:	ba 01 00 00 00       	mov    $0x1,%edx
  800d05:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d0a:	e8 e1 fd ff ff       	call   800af0 <syscall>
}
  800d0f:	c9                   	leave  
  800d10:	c3                   	ret    

00800d11 <sys_set_priority>:

int
sys_set_priority(envid_t envid, uint32_t new_priority)
{
  800d11:	55                   	push   %ebp
  800d12:	89 e5                	mov    %esp,%ebp
  800d14:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_set_priority, 0, envid, new_priority, 0, 0, 0);
  800d17:	6a 00                	push   $0x0
  800d19:	6a 00                	push   $0x0
  800d1b:	6a 00                	push   $0x0
  800d1d:	ff 75 0c             	pushl  0xc(%ebp)
  800d20:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d23:	ba 00 00 00 00       	mov    $0x0,%edx
  800d28:	b8 0e 00 00 00       	mov    $0xe,%eax
  800d2d:	e8 be fd ff ff       	call   800af0 <syscall>
}
  800d32:	c9                   	leave  
  800d33:	c3                   	ret    

00800d34 <sys_exec>:

int
sys_exec(uint32_t eip, uint32_t esp, void * ph, uint32_t elf_phnum)
{
  800d34:	55                   	push   %ebp
  800d35:	89 e5                	mov    %esp,%ebp
  800d37:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_exec, 0, eip, esp, (uint32_t)ph, elf_phnum, 0);
  800d3a:	6a 00                	push   $0x0
  800d3c:	ff 75 14             	pushl  0x14(%ebp)
  800d3f:	ff 75 10             	pushl  0x10(%ebp)
  800d42:	ff 75 0c             	pushl  0xc(%ebp)
  800d45:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d48:	ba 00 00 00 00       	mov    $0x0,%edx
  800d4d:	b8 0f 00 00 00       	mov    $0xf,%eax
  800d52:	e8 99 fd ff ff       	call   800af0 <syscall>
  800d57:	c9                   	leave  
  800d58:	c3                   	ret    
  800d59:	00 00                	add    %al,(%eax)
	...

00800d5c <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800d5c:	55                   	push   %ebp
  800d5d:	89 e5                	mov    %esp,%ebp
  800d5f:	53                   	push   %ebx
  800d60:	83 ec 04             	sub    $0x4,%esp
  800d63:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800d66:	8b 18                	mov    (%eax),%ebx

	// LAB 4: Your code here.
	
	// cprintf("PAGE FAULT HANDLER, 0x%08x %d\n", (uint32_t)addr, err & FEC_WR);
	
	if ((err & FEC_WR) == 0)
  800d68:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800d6c:	75 14                	jne    800d82 <pgfault+0x26>
		panic("pgfault, the fault is not a write\n");
  800d6e:	83 ec 04             	sub    $0x4,%esp
  800d71:	68 2c 25 80 00       	push   $0x80252c
  800d76:	6a 20                	push   $0x20
  800d78:	68 70 26 80 00       	push   $0x802670
  800d7d:	e8 d2 10 00 00       	call   801e54 <_panic>

	uint32_t uaddr = (uint32_t) addr;
	if ((uvpd[PDX(addr)] & PTE_P) == 0 || (uvpt[uaddr / PGSIZE] & PTE_COW) == 0) {
  800d82:	89 d8                	mov    %ebx,%eax
  800d84:	c1 e8 16             	shr    $0x16,%eax
  800d87:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800d8e:	a8 01                	test   $0x1,%al
  800d90:	74 11                	je     800da3 <pgfault+0x47>
  800d92:	89 d8                	mov    %ebx,%eax
  800d94:	c1 e8 0c             	shr    $0xc,%eax
  800d97:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800d9e:	f6 c4 08             	test   $0x8,%ah
  800da1:	75 14                	jne    800db7 <pgfault+0x5b>
		panic("pgfault, not a copy-on-write page\n");
  800da3:	83 ec 04             	sub    $0x4,%esp
  800da6:	68 50 25 80 00       	push   $0x802550
  800dab:	6a 24                	push   $0x24
  800dad:	68 70 26 80 00       	push   $0x802670
  800db2:	e8 9d 10 00 00       	call   801e54 <_panic>
	//   No need to explicitly delete the old page's mapping.

	// LAB 4: Your code here.

	// static int sys_page_alloc(envid_t envid, void *va, int perm)
	r = sys_page_alloc(0, (void *)PFTEMP, PTE_W | PTE_U | PTE_P);
  800db7:	83 ec 04             	sub    $0x4,%esp
  800dba:	6a 07                	push   $0x7
  800dbc:	68 00 f0 7f 00       	push   $0x7ff000
  800dc1:	6a 00                	push   $0x0
  800dc3:	e8 2c fe ff ff       	call   800bf4 <sys_page_alloc>
	if (r < 0) panic("pgfault, sys_page_alloc error : %e\n", r);
  800dc8:	83 c4 10             	add    $0x10,%esp
  800dcb:	85 c0                	test   %eax,%eax
  800dcd:	79 12                	jns    800de1 <pgfault+0x85>
  800dcf:	50                   	push   %eax
  800dd0:	68 74 25 80 00       	push   $0x802574
  800dd5:	6a 32                	push   $0x32
  800dd7:	68 70 26 80 00       	push   $0x802670
  800ddc:	e8 73 10 00 00       	call   801e54 <_panic>

	// Oh my god, I forget this at the first, it waste me a lot of time to debug!!!
	addr = ROUNDDOWN(addr, PGSIZE);
  800de1:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	
	memcpy(PFTEMP, addr, PGSIZE);
  800de7:	83 ec 04             	sub    $0x4,%esp
  800dea:	68 00 10 00 00       	push   $0x1000
  800def:	53                   	push   %ebx
  800df0:	68 00 f0 7f 00       	push   $0x7ff000
  800df5:	e8 a3 fb ff ff       	call   80099d <memcpy>
	
	r = sys_page_map(0, PFTEMP, 0, addr, PTE_W | PTE_U | PTE_P);
  800dfa:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800e01:	53                   	push   %ebx
  800e02:	6a 00                	push   $0x0
  800e04:	68 00 f0 7f 00       	push   $0x7ff000
  800e09:	6a 00                	push   $0x0
  800e0b:	e8 08 fe ff ff       	call   800c18 <sys_page_map>
	if (r < 0) panic("pgfault, sys_page_map error : %e\n", r);
  800e10:	83 c4 20             	add    $0x20,%esp
  800e13:	85 c0                	test   %eax,%eax
  800e15:	79 12                	jns    800e29 <pgfault+0xcd>
  800e17:	50                   	push   %eax
  800e18:	68 98 25 80 00       	push   $0x802598
  800e1d:	6a 3a                	push   $0x3a
  800e1f:	68 70 26 80 00       	push   $0x802670
  800e24:	e8 2b 10 00 00       	call   801e54 <_panic>

	return;
}
  800e29:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e2c:	c9                   	leave  
  800e2d:	c3                   	ret    

00800e2e <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800e2e:	55                   	push   %ebp
  800e2f:	89 e5                	mov    %esp,%ebp
  800e31:	57                   	push   %edi
  800e32:	56                   	push   %esi
  800e33:	53                   	push   %ebx
  800e34:	83 ec 28             	sub    $0x28,%esp
	// static int num = 0x100;

	// LAB 4: Your code here.
	set_pgfault_handler(pgfault);
  800e37:	68 5c 0d 80 00       	push   $0x800d5c
  800e3c:	e8 5b 10 00 00       	call   801e9c <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  800e41:	ba 07 00 00 00       	mov    $0x7,%edx
  800e46:	89 d0                	mov    %edx,%eax
  800e48:	cd 30                	int    $0x30
  800e4a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800e4d:	89 c7                	mov    %eax,%edi
	int childpid = sys_exofork();
	if (childpid < 0) {
  800e4f:	83 c4 10             	add    $0x10,%esp
  800e52:	85 c0                	test   %eax,%eax
  800e54:	79 12                	jns    800e68 <fork+0x3a>
		panic("fork sys_exofork error : %e\n", childpid);
  800e56:	50                   	push   %eax
  800e57:	68 7b 26 80 00       	push   $0x80267b
  800e5c:	6a 7f                	push   $0x7f
  800e5e:	68 70 26 80 00       	push   $0x802670
  800e63:	e8 ec 0f 00 00       	call   801e54 <_panic>
	}
	int r;

	if (childpid == 0) {
  800e68:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800e6c:	75 25                	jne    800e93 <fork+0x65>
		// child process
		// Remember to fix "thisenv" in the child process. ??? 
		thisenv = &envs[ENVX(sys_getenvid())];
  800e6e:	e8 36 fd ff ff       	call   800ba9 <sys_getenvid>
  800e73:	25 ff 03 00 00       	and    $0x3ff,%eax
  800e78:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800e7f:	c1 e0 07             	shl    $0x7,%eax
  800e82:	29 d0                	sub    %edx,%eax
  800e84:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800e89:	a3 04 40 80 00       	mov    %eax,0x804004
		// cprintf("fork child ok\n");
		return 0;
  800e8e:	e9 be 01 00 00       	jmp    801051 <fork+0x223>
	if (childpid < 0) {
		panic("fork sys_exofork error : %e\n", childpid);
	}
	int r;

	if (childpid == 0) {
  800e93:	bb 00 00 00 00       	mov    $0x0,%ebx
	} else {
		// map page to new environment
		// kernel page is already in new environment
		uint32_t i;
		for (i = 0; i != UTOP; i += PGSIZE) 
		if ((uvpd[PDX(i)] & PTE_P) && (uvpt[i / PGSIZE] & PTE_P) && (uvpt[i / PGSIZE] & PTE_U)) {
  800e98:	89 d8                	mov    %ebx,%eax
  800e9a:	c1 e8 16             	shr    $0x16,%eax
  800e9d:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800ea4:	a8 01                	test   $0x1,%al
  800ea6:	0f 84 10 01 00 00    	je     800fbc <fork+0x18e>
  800eac:	89 d8                	mov    %ebx,%eax
  800eae:	c1 e8 0c             	shr    $0xc,%eax
  800eb1:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800eb8:	f6 c2 01             	test   $0x1,%dl
  800ebb:	0f 84 fb 00 00 00    	je     800fbc <fork+0x18e>
  800ec1:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800ec8:	f6 c2 04             	test   $0x4,%dl
  800ecb:	0f 84 eb 00 00 00    	je     800fbc <fork+0x18e>
//
static int
duppage(envid_t envid, unsigned pn)
{
	// do not dup exception stack
	if (pn * PGSIZE == UXSTACKTOP - PGSIZE) return 0;
  800ed1:	89 c6                	mov    %eax,%esi
  800ed3:	c1 e6 0c             	shl    $0xc,%esi
  800ed6:	81 fe 00 f0 bf ee    	cmp    $0xeebff000,%esi
  800edc:	0f 84 da 00 00 00    	je     800fbc <fork+0x18e>

	int r;
	void * addr = (void *)(pn * PGSIZE);
    if (uvpt[pn] & PTE_SHARE) {
  800ee2:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800ee9:	f6 c6 04             	test   $0x4,%dh
  800eec:	74 37                	je     800f25 <fork+0xf7>
        r = sys_page_map(0, addr, envid, addr, uvpt[pn] & PTE_SYSCALL);
  800eee:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800ef5:	83 ec 0c             	sub    $0xc,%esp
  800ef8:	25 07 0e 00 00       	and    $0xe07,%eax
  800efd:	50                   	push   %eax
  800efe:	56                   	push   %esi
  800eff:	57                   	push   %edi
  800f00:	56                   	push   %esi
  800f01:	6a 00                	push   $0x0
  800f03:	e8 10 fd ff ff       	call   800c18 <sys_page_map>
        if (r < 0) panic("duppage sys_page_map error : %e\n", r);
  800f08:	83 c4 20             	add    $0x20,%esp
  800f0b:	85 c0                	test   %eax,%eax
  800f0d:	0f 89 a9 00 00 00    	jns    800fbc <fork+0x18e>
  800f13:	50                   	push   %eax
  800f14:	68 bc 25 80 00       	push   $0x8025bc
  800f19:	6a 54                	push   $0x54
  800f1b:	68 70 26 80 00       	push   $0x802670
  800f20:	e8 2f 0f 00 00       	call   801e54 <_panic>
    } else
	if ((uvpt[pn] & PTE_W) || (uvpt[pn] & PTE_COW)) {
  800f25:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800f2c:	f6 c2 02             	test   $0x2,%dl
  800f2f:	75 0c                	jne    800f3d <fork+0x10f>
  800f31:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f38:	f6 c4 08             	test   $0x8,%ah
  800f3b:	74 57                	je     800f94 <fork+0x166>
		// cow
		r = sys_page_map(0, addr, envid, addr, PTE_COW | PTE_P | PTE_U);
  800f3d:	83 ec 0c             	sub    $0xc,%esp
  800f40:	68 05 08 00 00       	push   $0x805
  800f45:	56                   	push   %esi
  800f46:	57                   	push   %edi
  800f47:	56                   	push   %esi
  800f48:	6a 00                	push   $0x0
  800f4a:	e8 c9 fc ff ff       	call   800c18 <sys_page_map>
		if (r < 0) panic("duppage sys_page_map error : %e\n", r);
  800f4f:	83 c4 20             	add    $0x20,%esp
  800f52:	85 c0                	test   %eax,%eax
  800f54:	79 12                	jns    800f68 <fork+0x13a>
  800f56:	50                   	push   %eax
  800f57:	68 bc 25 80 00       	push   $0x8025bc
  800f5c:	6a 59                	push   $0x59
  800f5e:	68 70 26 80 00       	push   $0x802670
  800f63:	e8 ec 0e 00 00       	call   801e54 <_panic>
		
		r = sys_page_map(0, addr, 0, addr, PTE_COW | PTE_P | PTE_U);
  800f68:	83 ec 0c             	sub    $0xc,%esp
  800f6b:	68 05 08 00 00       	push   $0x805
  800f70:	56                   	push   %esi
  800f71:	6a 00                	push   $0x0
  800f73:	56                   	push   %esi
  800f74:	6a 00                	push   $0x0
  800f76:	e8 9d fc ff ff       	call   800c18 <sys_page_map>
		if (r < 0) panic("duppage sys_page_map error : %e\n", r);
  800f7b:	83 c4 20             	add    $0x20,%esp
  800f7e:	85 c0                	test   %eax,%eax
  800f80:	79 3a                	jns    800fbc <fork+0x18e>
  800f82:	50                   	push   %eax
  800f83:	68 bc 25 80 00       	push   $0x8025bc
  800f88:	6a 5c                	push   $0x5c
  800f8a:	68 70 26 80 00       	push   $0x802670
  800f8f:	e8 c0 0e 00 00       	call   801e54 <_panic>
	} else {
		// read only
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U);
  800f94:	83 ec 0c             	sub    $0xc,%esp
  800f97:	6a 05                	push   $0x5
  800f99:	56                   	push   %esi
  800f9a:	57                   	push   %edi
  800f9b:	56                   	push   %esi
  800f9c:	6a 00                	push   $0x0
  800f9e:	e8 75 fc ff ff       	call   800c18 <sys_page_map>
		if (r < 0) panic("duppage sys_page_map error : %e\n", r);
  800fa3:	83 c4 20             	add    $0x20,%esp
  800fa6:	85 c0                	test   %eax,%eax
  800fa8:	79 12                	jns    800fbc <fork+0x18e>
  800faa:	50                   	push   %eax
  800fab:	68 bc 25 80 00       	push   $0x8025bc
  800fb0:	6a 60                	push   $0x60
  800fb2:	68 70 26 80 00       	push   $0x802670
  800fb7:	e8 98 0e 00 00       	call   801e54 <_panic>
		return 0;
	} else {
		// map page to new environment
		// kernel page is already in new environment
		uint32_t i;
		for (i = 0; i != UTOP; i += PGSIZE) 
  800fbc:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  800fc2:	81 fb 00 00 c0 ee    	cmp    $0xeec00000,%ebx
  800fc8:	0f 85 ca fe ff ff    	jne    800e98 <fork+0x6a>
		if ((uvpd[PDX(i)] & PTE_P) && (uvpt[i / PGSIZE] & PTE_P) && (uvpt[i / PGSIZE] & PTE_U)) {
			duppage(childpid, i / PGSIZE);
		}

		// allocate exception stack
		r = sys_page_alloc(childpid, (void *)(UXSTACKTOP - PGSIZE), PTE_U | PTE_W | PTE_P);
  800fce:	83 ec 04             	sub    $0x4,%esp
  800fd1:	6a 07                	push   $0x7
  800fd3:	68 00 f0 bf ee       	push   $0xeebff000
  800fd8:	ff 75 e4             	pushl  -0x1c(%ebp)
  800fdb:	e8 14 fc ff ff       	call   800bf4 <sys_page_alloc>
		if (r < 0) panic("fork, sys_page_alloc user exception stack error : %e\n", r);
  800fe0:	83 c4 10             	add    $0x10,%esp
  800fe3:	85 c0                	test   %eax,%eax
  800fe5:	79 15                	jns    800ffc <fork+0x1ce>
  800fe7:	50                   	push   %eax
  800fe8:	68 e0 25 80 00       	push   $0x8025e0
  800fed:	68 94 00 00 00       	push   $0x94
  800ff2:	68 70 26 80 00       	push   $0x802670
  800ff7:	e8 58 0e 00 00       	call   801e54 <_panic>

		// set user environment user page fault handler 
		extern void _pgfault_upcall(void);
		r = sys_env_set_pgfault_upcall(childpid, _pgfault_upcall);
  800ffc:	83 ec 08             	sub    $0x8,%esp
  800fff:	68 08 1f 80 00       	push   $0x801f08
  801004:	ff 75 e4             	pushl  -0x1c(%ebp)
  801007:	e8 9b fc ff ff       	call   800ca7 <sys_env_set_pgfault_upcall>
		if (r < 0) panic("fork, set pgfault upcall fail : %e\n", r);
  80100c:	83 c4 10             	add    $0x10,%esp
  80100f:	85 c0                	test   %eax,%eax
  801011:	79 15                	jns    801028 <fork+0x1fa>
  801013:	50                   	push   %eax
  801014:	68 18 26 80 00       	push   $0x802618
  801019:	68 99 00 00 00       	push   $0x99
  80101e:	68 70 26 80 00       	push   $0x802670
  801023:	e8 2c 0e 00 00       	call   801e54 <_panic>
		r = sys_set_priority(childpid, num);
		if (r < 0) panic("fork, set priority error\n");
		*/

		// mark the child as runnable and return
		r = sys_env_set_status(childpid, ENV_RUNNABLE);
  801028:	83 ec 08             	sub    $0x8,%esp
  80102b:	6a 02                	push   $0x2
  80102d:	ff 75 e4             	pushl  -0x1c(%ebp)
  801030:	e8 2c fc ff ff       	call   800c61 <sys_env_set_status>
		if (r < 0) panic("fork, set child process to ENV_RUNNABLE error : %e\n", r);
  801035:	83 c4 10             	add    $0x10,%esp
  801038:	85 c0                	test   %eax,%eax
  80103a:	79 15                	jns    801051 <fork+0x223>
  80103c:	50                   	push   %eax
  80103d:	68 3c 26 80 00       	push   $0x80263c
  801042:	68 a4 00 00 00       	push   $0xa4
  801047:	68 70 26 80 00       	push   $0x802670
  80104c:	e8 03 0e 00 00       	call   801e54 <_panic>
		// cprintf("fork father ok!")
		return childpid;
	}

	panic("fork not implemented");
}
  801051:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801054:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801057:	5b                   	pop    %ebx
  801058:	5e                   	pop    %esi
  801059:	5f                   	pop    %edi
  80105a:	c9                   	leave  
  80105b:	c3                   	ret    

0080105c <sfork>:

// Challenge!
int
sfork(void)
{
  80105c:	55                   	push   %ebp
  80105d:	89 e5                	mov    %esp,%ebp
  80105f:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  801062:	68 98 26 80 00       	push   $0x802698
  801067:	68 b1 00 00 00       	push   $0xb1
  80106c:	68 70 26 80 00       	push   $0x802670
  801071:	e8 de 0d 00 00       	call   801e54 <_panic>
	...

00801078 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801078:	55                   	push   %ebp
  801079:	89 e5                	mov    %esp,%ebp
  80107b:	56                   	push   %esi
  80107c:	53                   	push   %ebx
  80107d:	8b 75 08             	mov    0x8(%ebp),%esi
  801080:	8b 45 0c             	mov    0xc(%ebp),%eax
  801083:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// cprintf("0x%x 0x%x 0x%x\n", (uint32_t)from_env_store, (uint32_t)pg, (uint32_t)perm_store);
	int r;
	if (pg != NULL) {
  801086:	85 c0                	test   %eax,%eax
  801088:	74 0e                	je     801098 <ipc_recv+0x20>
		r = sys_ipc_recv(pg);
  80108a:	83 ec 0c             	sub    $0xc,%esp
  80108d:	50                   	push   %eax
  80108e:	e8 5c fc ff ff       	call   800cef <sys_ipc_recv>
  801093:	83 c4 10             	add    $0x10,%esp
  801096:	eb 10                	jmp    8010a8 <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv((void *)UTOP);
  801098:	83 ec 0c             	sub    $0xc,%esp
  80109b:	68 00 00 c0 ee       	push   $0xeec00000
  8010a0:	e8 4a fc ff ff       	call   800cef <sys_ipc_recv>
  8010a5:	83 c4 10             	add    $0x10,%esp
	}

	if (r == 0) {
  8010a8:	85 c0                	test   %eax,%eax
  8010aa:	75 26                	jne    8010d2 <ipc_recv+0x5a>
		if (from_env_store != NULL) *from_env_store = thisenv->env_ipc_from;
  8010ac:	85 f6                	test   %esi,%esi
  8010ae:	74 0a                	je     8010ba <ipc_recv+0x42>
  8010b0:	a1 04 40 80 00       	mov    0x804004,%eax
  8010b5:	8b 40 74             	mov    0x74(%eax),%eax
  8010b8:	89 06                	mov    %eax,(%esi)
		if (perm_store != NULL) *perm_store = thisenv->env_ipc_perm;
  8010ba:	85 db                	test   %ebx,%ebx
  8010bc:	74 0a                	je     8010c8 <ipc_recv+0x50>
  8010be:	a1 04 40 80 00       	mov    0x804004,%eax
  8010c3:	8b 40 78             	mov    0x78(%eax),%eax
  8010c6:	89 03                	mov    %eax,(%ebx)
		return thisenv->env_ipc_value;
  8010c8:	a1 04 40 80 00       	mov    0x804004,%eax
  8010cd:	8b 40 70             	mov    0x70(%eax),%eax
  8010d0:	eb 14                	jmp    8010e6 <ipc_recv+0x6e>
	} else {
		// fails;
		if (from_env_store != NULL) *from_env_store = 0;
  8010d2:	85 f6                	test   %esi,%esi
  8010d4:	74 06                	je     8010dc <ipc_recv+0x64>
  8010d6:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if (perm_store != NULL) *perm_store = 0;
  8010dc:	85 db                	test   %ebx,%ebx
  8010de:	74 06                	je     8010e6 <ipc_recv+0x6e>
  8010e0:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		return r;
	}
}
  8010e6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8010e9:	5b                   	pop    %ebx
  8010ea:	5e                   	pop    %esi
  8010eb:	c9                   	leave  
  8010ec:	c3                   	ret    

008010ed <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8010ed:	55                   	push   %ebp
  8010ee:	89 e5                	mov    %esp,%ebp
  8010f0:	57                   	push   %edi
  8010f1:	56                   	push   %esi
  8010f2:	53                   	push   %ebx
  8010f3:	83 ec 0c             	sub    $0xc,%esp
  8010f6:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8010f9:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8010fc:	8b 75 14             	mov    0x14(%ebp),%esi
	// LAB 4: Your code here.
	// int sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
	int r;
	if (pg == NULL) pg = (void *)UTOP;
  8010ff:	85 db                	test   %ebx,%ebx
  801101:	75 25                	jne    801128 <ipc_send+0x3b>
  801103:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
  801108:	eb 1e                	jmp    801128 <ipc_send+0x3b>
	
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) != 0) {
		if (r == -E_IPC_NOT_RECV) {
  80110a:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80110d:	75 07                	jne    801116 <ipc_send+0x29>
			// cprintf("Try Again and Again....\n");
			sys_yield();
  80110f:	e8 b9 fa ff ff       	call   800bcd <sys_yield>
  801114:	eb 12                	jmp    801128 <ipc_send+0x3b>
		} else {
			panic("ipc_send error %e\n", r);
  801116:	50                   	push   %eax
  801117:	68 ae 26 80 00       	push   $0x8026ae
  80111c:	6a 43                	push   $0x43
  80111e:	68 c1 26 80 00       	push   $0x8026c1
  801123:	e8 2c 0d 00 00       	call   801e54 <_panic>
	// LAB 4: Your code here.
	// int sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
	int r;
	if (pg == NULL) pg = (void *)UTOP;
	
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) != 0) {
  801128:	56                   	push   %esi
  801129:	53                   	push   %ebx
  80112a:	57                   	push   %edi
  80112b:	ff 75 08             	pushl  0x8(%ebp)
  80112e:	e8 97 fb ff ff       	call   800cca <sys_ipc_try_send>
  801133:	83 c4 10             	add    $0x10,%esp
  801136:	85 c0                	test   %eax,%eax
  801138:	75 d0                	jne    80110a <ipc_send+0x1d>
		} else {
			panic("ipc_send error %e\n", r);
		}
	}
	return;
}
  80113a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80113d:	5b                   	pop    %ebx
  80113e:	5e                   	pop    %esi
  80113f:	5f                   	pop    %edi
  801140:	c9                   	leave  
  801141:	c3                   	ret    

00801142 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801142:	55                   	push   %ebp
  801143:	89 e5                	mov    %esp,%ebp
  801145:	53                   	push   %ebx
  801146:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  801149:	39 1d 50 00 c0 ee    	cmp    %ebx,0xeec00050
  80114f:	74 22                	je     801173 <ipc_find_env+0x31>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801151:	b8 01 00 00 00       	mov    $0x1,%eax
		if (envs[i].env_type == type)
  801156:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  80115d:	89 c2                	mov    %eax,%edx
  80115f:	c1 e2 07             	shl    $0x7,%edx
  801162:	29 ca                	sub    %ecx,%edx
  801164:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  80116a:	8b 52 50             	mov    0x50(%edx),%edx
  80116d:	39 da                	cmp    %ebx,%edx
  80116f:	75 1d                	jne    80118e <ipc_find_env+0x4c>
  801171:	eb 05                	jmp    801178 <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801173:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
			return envs[i].env_id;
  801178:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  80117f:	c1 e0 07             	shl    $0x7,%eax
  801182:	29 d0                	sub    %edx,%eax
  801184:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  801189:	8b 40 40             	mov    0x40(%eax),%eax
  80118c:	eb 0c                	jmp    80119a <ipc_find_env+0x58>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80118e:	40                   	inc    %eax
  80118f:	3d 00 04 00 00       	cmp    $0x400,%eax
  801194:	75 c0                	jne    801156 <ipc_find_env+0x14>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801196:	66 b8 00 00          	mov    $0x0,%ax
}
  80119a:	5b                   	pop    %ebx
  80119b:	c9                   	leave  
  80119c:	c3                   	ret    
  80119d:	00 00                	add    %al,(%eax)
	...

008011a0 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8011a0:	55                   	push   %ebp
  8011a1:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8011a3:	8b 45 08             	mov    0x8(%ebp),%eax
  8011a6:	05 00 00 00 30       	add    $0x30000000,%eax
  8011ab:	c1 e8 0c             	shr    $0xc,%eax
}
  8011ae:	c9                   	leave  
  8011af:	c3                   	ret    

008011b0 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8011b0:	55                   	push   %ebp
  8011b1:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  8011b3:	ff 75 08             	pushl  0x8(%ebp)
  8011b6:	e8 e5 ff ff ff       	call   8011a0 <fd2num>
  8011bb:	83 c4 04             	add    $0x4,%esp
  8011be:	05 20 00 0d 00       	add    $0xd0020,%eax
  8011c3:	c1 e0 0c             	shl    $0xc,%eax
}
  8011c6:	c9                   	leave  
  8011c7:	c3                   	ret    

008011c8 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8011c8:	55                   	push   %ebp
  8011c9:	89 e5                	mov    %esp,%ebp
  8011cb:	53                   	push   %ebx
  8011cc:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8011cf:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  8011d4:	a8 01                	test   $0x1,%al
  8011d6:	74 34                	je     80120c <fd_alloc+0x44>
  8011d8:	a1 00 00 74 ef       	mov    0xef740000,%eax
  8011dd:	a8 01                	test   $0x1,%al
  8011df:	74 32                	je     801213 <fd_alloc+0x4b>
  8011e1:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
  8011e6:	89 c1                	mov    %eax,%ecx
  8011e8:	89 c2                	mov    %eax,%edx
  8011ea:	c1 ea 16             	shr    $0x16,%edx
  8011ed:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8011f4:	f6 c2 01             	test   $0x1,%dl
  8011f7:	74 1f                	je     801218 <fd_alloc+0x50>
  8011f9:	89 c2                	mov    %eax,%edx
  8011fb:	c1 ea 0c             	shr    $0xc,%edx
  8011fe:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801205:	f6 c2 01             	test   $0x1,%dl
  801208:	75 17                	jne    801221 <fd_alloc+0x59>
  80120a:	eb 0c                	jmp    801218 <fd_alloc+0x50>
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  80120c:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
  801211:	eb 05                	jmp    801218 <fd_alloc+0x50>
  801213:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
  801218:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  80121a:	b8 00 00 00 00       	mov    $0x0,%eax
  80121f:	eb 17                	jmp    801238 <fd_alloc+0x70>
  801221:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801226:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80122b:	75 b9                	jne    8011e6 <fd_alloc+0x1e>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  80122d:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  801233:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801238:	5b                   	pop    %ebx
  801239:	c9                   	leave  
  80123a:	c3                   	ret    

0080123b <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80123b:	55                   	push   %ebp
  80123c:	89 e5                	mov    %esp,%ebp
  80123e:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801241:	83 f8 1f             	cmp    $0x1f,%eax
  801244:	77 36                	ja     80127c <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801246:	05 00 00 0d 00       	add    $0xd0000,%eax
  80124b:	c1 e0 0c             	shl    $0xc,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80124e:	89 c2                	mov    %eax,%edx
  801250:	c1 ea 16             	shr    $0x16,%edx
  801253:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80125a:	f6 c2 01             	test   $0x1,%dl
  80125d:	74 24                	je     801283 <fd_lookup+0x48>
  80125f:	89 c2                	mov    %eax,%edx
  801261:	c1 ea 0c             	shr    $0xc,%edx
  801264:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80126b:	f6 c2 01             	test   $0x1,%dl
  80126e:	74 1a                	je     80128a <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801270:	8b 55 0c             	mov    0xc(%ebp),%edx
  801273:	89 02                	mov    %eax,(%edx)
	return 0;
  801275:	b8 00 00 00 00       	mov    $0x0,%eax
  80127a:	eb 13                	jmp    80128f <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80127c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801281:	eb 0c                	jmp    80128f <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801283:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801288:	eb 05                	jmp    80128f <fd_lookup+0x54>
  80128a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  80128f:	c9                   	leave  
  801290:	c3                   	ret    

00801291 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801291:	55                   	push   %ebp
  801292:	89 e5                	mov    %esp,%ebp
  801294:	53                   	push   %ebx
  801295:	83 ec 04             	sub    $0x4,%esp
  801298:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80129b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  80129e:	39 0d 04 30 80 00    	cmp    %ecx,0x803004
  8012a4:	74 0d                	je     8012b3 <dev_lookup+0x22>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8012a6:	b8 00 00 00 00       	mov    $0x0,%eax
  8012ab:	eb 14                	jmp    8012c1 <dev_lookup+0x30>
		if (devtab[i]->dev_id == dev_id) {
  8012ad:	39 0a                	cmp    %ecx,(%edx)
  8012af:	75 10                	jne    8012c1 <dev_lookup+0x30>
  8012b1:	eb 05                	jmp    8012b8 <dev_lookup+0x27>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8012b3:	ba 04 30 80 00       	mov    $0x803004,%edx
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
  8012b8:	89 13                	mov    %edx,(%ebx)
			return 0;
  8012ba:	b8 00 00 00 00       	mov    $0x0,%eax
  8012bf:	eb 31                	jmp    8012f2 <dev_lookup+0x61>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8012c1:	40                   	inc    %eax
  8012c2:	8b 14 85 48 27 80 00 	mov    0x802748(,%eax,4),%edx
  8012c9:	85 d2                	test   %edx,%edx
  8012cb:	75 e0                	jne    8012ad <dev_lookup+0x1c>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8012cd:	a1 04 40 80 00       	mov    0x804004,%eax
  8012d2:	8b 40 48             	mov    0x48(%eax),%eax
  8012d5:	83 ec 04             	sub    $0x4,%esp
  8012d8:	51                   	push   %ecx
  8012d9:	50                   	push   %eax
  8012da:	68 cc 26 80 00       	push   $0x8026cc
  8012df:	e8 d8 ee ff ff       	call   8001bc <cprintf>
	*dev = 0;
  8012e4:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  8012ea:	83 c4 10             	add    $0x10,%esp
  8012ed:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8012f2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012f5:	c9                   	leave  
  8012f6:	c3                   	ret    

008012f7 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8012f7:	55                   	push   %ebp
  8012f8:	89 e5                	mov    %esp,%ebp
  8012fa:	56                   	push   %esi
  8012fb:	53                   	push   %ebx
  8012fc:	83 ec 20             	sub    $0x20,%esp
  8012ff:	8b 75 08             	mov    0x8(%ebp),%esi
  801302:	8a 45 0c             	mov    0xc(%ebp),%al
  801305:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801308:	56                   	push   %esi
  801309:	e8 92 fe ff ff       	call   8011a0 <fd2num>
  80130e:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801311:	89 14 24             	mov    %edx,(%esp)
  801314:	50                   	push   %eax
  801315:	e8 21 ff ff ff       	call   80123b <fd_lookup>
  80131a:	89 c3                	mov    %eax,%ebx
  80131c:	83 c4 08             	add    $0x8,%esp
  80131f:	85 c0                	test   %eax,%eax
  801321:	78 05                	js     801328 <fd_close+0x31>
	    || fd != fd2)
  801323:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801326:	74 0d                	je     801335 <fd_close+0x3e>
		return (must_exist ? r : 0);
  801328:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  80132c:	75 48                	jne    801376 <fd_close+0x7f>
  80132e:	bb 00 00 00 00       	mov    $0x0,%ebx
  801333:	eb 41                	jmp    801376 <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801335:	83 ec 08             	sub    $0x8,%esp
  801338:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80133b:	50                   	push   %eax
  80133c:	ff 36                	pushl  (%esi)
  80133e:	e8 4e ff ff ff       	call   801291 <dev_lookup>
  801343:	89 c3                	mov    %eax,%ebx
  801345:	83 c4 10             	add    $0x10,%esp
  801348:	85 c0                	test   %eax,%eax
  80134a:	78 1c                	js     801368 <fd_close+0x71>
		if (dev->dev_close)
  80134c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80134f:	8b 40 10             	mov    0x10(%eax),%eax
  801352:	85 c0                	test   %eax,%eax
  801354:	74 0d                	je     801363 <fd_close+0x6c>
			r = (*dev->dev_close)(fd);
  801356:	83 ec 0c             	sub    $0xc,%esp
  801359:	56                   	push   %esi
  80135a:	ff d0                	call   *%eax
  80135c:	89 c3                	mov    %eax,%ebx
  80135e:	83 c4 10             	add    $0x10,%esp
  801361:	eb 05                	jmp    801368 <fd_close+0x71>
		else
			r = 0;
  801363:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801368:	83 ec 08             	sub    $0x8,%esp
  80136b:	56                   	push   %esi
  80136c:	6a 00                	push   $0x0
  80136e:	e8 cb f8 ff ff       	call   800c3e <sys_page_unmap>
	return r;
  801373:	83 c4 10             	add    $0x10,%esp
}
  801376:	89 d8                	mov    %ebx,%eax
  801378:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80137b:	5b                   	pop    %ebx
  80137c:	5e                   	pop    %esi
  80137d:	c9                   	leave  
  80137e:	c3                   	ret    

0080137f <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80137f:	55                   	push   %ebp
  801380:	89 e5                	mov    %esp,%ebp
  801382:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801385:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801388:	50                   	push   %eax
  801389:	ff 75 08             	pushl  0x8(%ebp)
  80138c:	e8 aa fe ff ff       	call   80123b <fd_lookup>
  801391:	83 c4 08             	add    $0x8,%esp
  801394:	85 c0                	test   %eax,%eax
  801396:	78 10                	js     8013a8 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801398:	83 ec 08             	sub    $0x8,%esp
  80139b:	6a 01                	push   $0x1
  80139d:	ff 75 f4             	pushl  -0xc(%ebp)
  8013a0:	e8 52 ff ff ff       	call   8012f7 <fd_close>
  8013a5:	83 c4 10             	add    $0x10,%esp
}
  8013a8:	c9                   	leave  
  8013a9:	c3                   	ret    

008013aa <close_all>:

void
close_all(void)
{
  8013aa:	55                   	push   %ebp
  8013ab:	89 e5                	mov    %esp,%ebp
  8013ad:	53                   	push   %ebx
  8013ae:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8013b1:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8013b6:	83 ec 0c             	sub    $0xc,%esp
  8013b9:	53                   	push   %ebx
  8013ba:	e8 c0 ff ff ff       	call   80137f <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8013bf:	43                   	inc    %ebx
  8013c0:	83 c4 10             	add    $0x10,%esp
  8013c3:	83 fb 20             	cmp    $0x20,%ebx
  8013c6:	75 ee                	jne    8013b6 <close_all+0xc>
		close(i);
}
  8013c8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013cb:	c9                   	leave  
  8013cc:	c3                   	ret    

008013cd <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8013cd:	55                   	push   %ebp
  8013ce:	89 e5                	mov    %esp,%ebp
  8013d0:	57                   	push   %edi
  8013d1:	56                   	push   %esi
  8013d2:	53                   	push   %ebx
  8013d3:	83 ec 2c             	sub    $0x2c,%esp
  8013d6:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8013d9:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8013dc:	50                   	push   %eax
  8013dd:	ff 75 08             	pushl  0x8(%ebp)
  8013e0:	e8 56 fe ff ff       	call   80123b <fd_lookup>
  8013e5:	89 c3                	mov    %eax,%ebx
  8013e7:	83 c4 08             	add    $0x8,%esp
  8013ea:	85 c0                	test   %eax,%eax
  8013ec:	0f 88 c0 00 00 00    	js     8014b2 <dup+0xe5>
		return r;
	close(newfdnum);
  8013f2:	83 ec 0c             	sub    $0xc,%esp
  8013f5:	57                   	push   %edi
  8013f6:	e8 84 ff ff ff       	call   80137f <close>

	newfd = INDEX2FD(newfdnum);
  8013fb:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  801401:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  801404:	83 c4 04             	add    $0x4,%esp
  801407:	ff 75 e4             	pushl  -0x1c(%ebp)
  80140a:	e8 a1 fd ff ff       	call   8011b0 <fd2data>
  80140f:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801411:	89 34 24             	mov    %esi,(%esp)
  801414:	e8 97 fd ff ff       	call   8011b0 <fd2data>
  801419:	83 c4 10             	add    $0x10,%esp
  80141c:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80141f:	89 d8                	mov    %ebx,%eax
  801421:	c1 e8 16             	shr    $0x16,%eax
  801424:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80142b:	a8 01                	test   $0x1,%al
  80142d:	74 37                	je     801466 <dup+0x99>
  80142f:	89 d8                	mov    %ebx,%eax
  801431:	c1 e8 0c             	shr    $0xc,%eax
  801434:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80143b:	f6 c2 01             	test   $0x1,%dl
  80143e:	74 26                	je     801466 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801440:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801447:	83 ec 0c             	sub    $0xc,%esp
  80144a:	25 07 0e 00 00       	and    $0xe07,%eax
  80144f:	50                   	push   %eax
  801450:	ff 75 d4             	pushl  -0x2c(%ebp)
  801453:	6a 00                	push   $0x0
  801455:	53                   	push   %ebx
  801456:	6a 00                	push   $0x0
  801458:	e8 bb f7 ff ff       	call   800c18 <sys_page_map>
  80145d:	89 c3                	mov    %eax,%ebx
  80145f:	83 c4 20             	add    $0x20,%esp
  801462:	85 c0                	test   %eax,%eax
  801464:	78 2d                	js     801493 <dup+0xc6>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801466:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801469:	89 c2                	mov    %eax,%edx
  80146b:	c1 ea 0c             	shr    $0xc,%edx
  80146e:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801475:	83 ec 0c             	sub    $0xc,%esp
  801478:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  80147e:	52                   	push   %edx
  80147f:	56                   	push   %esi
  801480:	6a 00                	push   $0x0
  801482:	50                   	push   %eax
  801483:	6a 00                	push   $0x0
  801485:	e8 8e f7 ff ff       	call   800c18 <sys_page_map>
  80148a:	89 c3                	mov    %eax,%ebx
  80148c:	83 c4 20             	add    $0x20,%esp
  80148f:	85 c0                	test   %eax,%eax
  801491:	79 1d                	jns    8014b0 <dup+0xe3>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801493:	83 ec 08             	sub    $0x8,%esp
  801496:	56                   	push   %esi
  801497:	6a 00                	push   $0x0
  801499:	e8 a0 f7 ff ff       	call   800c3e <sys_page_unmap>
	sys_page_unmap(0, nva);
  80149e:	83 c4 08             	add    $0x8,%esp
  8014a1:	ff 75 d4             	pushl  -0x2c(%ebp)
  8014a4:	6a 00                	push   $0x0
  8014a6:	e8 93 f7 ff ff       	call   800c3e <sys_page_unmap>
	return r;
  8014ab:	83 c4 10             	add    $0x10,%esp
  8014ae:	eb 02                	jmp    8014b2 <dup+0xe5>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  8014b0:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  8014b2:	89 d8                	mov    %ebx,%eax
  8014b4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8014b7:	5b                   	pop    %ebx
  8014b8:	5e                   	pop    %esi
  8014b9:	5f                   	pop    %edi
  8014ba:	c9                   	leave  
  8014bb:	c3                   	ret    

008014bc <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8014bc:	55                   	push   %ebp
  8014bd:	89 e5                	mov    %esp,%ebp
  8014bf:	53                   	push   %ebx
  8014c0:	83 ec 14             	sub    $0x14,%esp
  8014c3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8014c6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014c9:	50                   	push   %eax
  8014ca:	53                   	push   %ebx
  8014cb:	e8 6b fd ff ff       	call   80123b <fd_lookup>
  8014d0:	83 c4 08             	add    $0x8,%esp
  8014d3:	85 c0                	test   %eax,%eax
  8014d5:	78 67                	js     80153e <read+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014d7:	83 ec 08             	sub    $0x8,%esp
  8014da:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014dd:	50                   	push   %eax
  8014de:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014e1:	ff 30                	pushl  (%eax)
  8014e3:	e8 a9 fd ff ff       	call   801291 <dev_lookup>
  8014e8:	83 c4 10             	add    $0x10,%esp
  8014eb:	85 c0                	test   %eax,%eax
  8014ed:	78 4f                	js     80153e <read+0x82>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8014ef:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014f2:	8b 50 08             	mov    0x8(%eax),%edx
  8014f5:	83 e2 03             	and    $0x3,%edx
  8014f8:	83 fa 01             	cmp    $0x1,%edx
  8014fb:	75 21                	jne    80151e <read+0x62>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8014fd:	a1 04 40 80 00       	mov    0x804004,%eax
  801502:	8b 40 48             	mov    0x48(%eax),%eax
  801505:	83 ec 04             	sub    $0x4,%esp
  801508:	53                   	push   %ebx
  801509:	50                   	push   %eax
  80150a:	68 0d 27 80 00       	push   $0x80270d
  80150f:	e8 a8 ec ff ff       	call   8001bc <cprintf>
		return -E_INVAL;
  801514:	83 c4 10             	add    $0x10,%esp
  801517:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80151c:	eb 20                	jmp    80153e <read+0x82>
	}
	if (!dev->dev_read)
  80151e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801521:	8b 52 08             	mov    0x8(%edx),%edx
  801524:	85 d2                	test   %edx,%edx
  801526:	74 11                	je     801539 <read+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801528:	83 ec 04             	sub    $0x4,%esp
  80152b:	ff 75 10             	pushl  0x10(%ebp)
  80152e:	ff 75 0c             	pushl  0xc(%ebp)
  801531:	50                   	push   %eax
  801532:	ff d2                	call   *%edx
  801534:	83 c4 10             	add    $0x10,%esp
  801537:	eb 05                	jmp    80153e <read+0x82>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801539:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  80153e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801541:	c9                   	leave  
  801542:	c3                   	ret    

00801543 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801543:	55                   	push   %ebp
  801544:	89 e5                	mov    %esp,%ebp
  801546:	57                   	push   %edi
  801547:	56                   	push   %esi
  801548:	53                   	push   %ebx
  801549:	83 ec 0c             	sub    $0xc,%esp
  80154c:	8b 7d 08             	mov    0x8(%ebp),%edi
  80154f:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801552:	85 f6                	test   %esi,%esi
  801554:	74 31                	je     801587 <readn+0x44>
  801556:	b8 00 00 00 00       	mov    $0x0,%eax
  80155b:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = read(fdnum, (char*)buf + tot, n - tot);
  801560:	83 ec 04             	sub    $0x4,%esp
  801563:	89 f2                	mov    %esi,%edx
  801565:	29 c2                	sub    %eax,%edx
  801567:	52                   	push   %edx
  801568:	03 45 0c             	add    0xc(%ebp),%eax
  80156b:	50                   	push   %eax
  80156c:	57                   	push   %edi
  80156d:	e8 4a ff ff ff       	call   8014bc <read>
		if (m < 0)
  801572:	83 c4 10             	add    $0x10,%esp
  801575:	85 c0                	test   %eax,%eax
  801577:	78 17                	js     801590 <readn+0x4d>
			return m;
		if (m == 0)
  801579:	85 c0                	test   %eax,%eax
  80157b:	74 11                	je     80158e <readn+0x4b>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80157d:	01 c3                	add    %eax,%ebx
  80157f:	89 d8                	mov    %ebx,%eax
  801581:	39 f3                	cmp    %esi,%ebx
  801583:	72 db                	jb     801560 <readn+0x1d>
  801585:	eb 09                	jmp    801590 <readn+0x4d>
  801587:	b8 00 00 00 00       	mov    $0x0,%eax
  80158c:	eb 02                	jmp    801590 <readn+0x4d>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  80158e:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  801590:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801593:	5b                   	pop    %ebx
  801594:	5e                   	pop    %esi
  801595:	5f                   	pop    %edi
  801596:	c9                   	leave  
  801597:	c3                   	ret    

00801598 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801598:	55                   	push   %ebp
  801599:	89 e5                	mov    %esp,%ebp
  80159b:	53                   	push   %ebx
  80159c:	83 ec 14             	sub    $0x14,%esp
  80159f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015a2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015a5:	50                   	push   %eax
  8015a6:	53                   	push   %ebx
  8015a7:	e8 8f fc ff ff       	call   80123b <fd_lookup>
  8015ac:	83 c4 08             	add    $0x8,%esp
  8015af:	85 c0                	test   %eax,%eax
  8015b1:	78 62                	js     801615 <write+0x7d>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015b3:	83 ec 08             	sub    $0x8,%esp
  8015b6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015b9:	50                   	push   %eax
  8015ba:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015bd:	ff 30                	pushl  (%eax)
  8015bf:	e8 cd fc ff ff       	call   801291 <dev_lookup>
  8015c4:	83 c4 10             	add    $0x10,%esp
  8015c7:	85 c0                	test   %eax,%eax
  8015c9:	78 4a                	js     801615 <write+0x7d>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8015cb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015ce:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8015d2:	75 21                	jne    8015f5 <write+0x5d>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8015d4:	a1 04 40 80 00       	mov    0x804004,%eax
  8015d9:	8b 40 48             	mov    0x48(%eax),%eax
  8015dc:	83 ec 04             	sub    $0x4,%esp
  8015df:	53                   	push   %ebx
  8015e0:	50                   	push   %eax
  8015e1:	68 29 27 80 00       	push   $0x802729
  8015e6:	e8 d1 eb ff ff       	call   8001bc <cprintf>
		return -E_INVAL;
  8015eb:	83 c4 10             	add    $0x10,%esp
  8015ee:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8015f3:	eb 20                	jmp    801615 <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8015f5:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8015f8:	8b 52 0c             	mov    0xc(%edx),%edx
  8015fb:	85 d2                	test   %edx,%edx
  8015fd:	74 11                	je     801610 <write+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8015ff:	83 ec 04             	sub    $0x4,%esp
  801602:	ff 75 10             	pushl  0x10(%ebp)
  801605:	ff 75 0c             	pushl  0xc(%ebp)
  801608:	50                   	push   %eax
  801609:	ff d2                	call   *%edx
  80160b:	83 c4 10             	add    $0x10,%esp
  80160e:	eb 05                	jmp    801615 <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801610:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  801615:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801618:	c9                   	leave  
  801619:	c3                   	ret    

0080161a <seek>:

int
seek(int fdnum, off_t offset)
{
  80161a:	55                   	push   %ebp
  80161b:	89 e5                	mov    %esp,%ebp
  80161d:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801620:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801623:	50                   	push   %eax
  801624:	ff 75 08             	pushl  0x8(%ebp)
  801627:	e8 0f fc ff ff       	call   80123b <fd_lookup>
  80162c:	83 c4 08             	add    $0x8,%esp
  80162f:	85 c0                	test   %eax,%eax
  801631:	78 0e                	js     801641 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801633:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801636:	8b 55 0c             	mov    0xc(%ebp),%edx
  801639:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80163c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801641:	c9                   	leave  
  801642:	c3                   	ret    

00801643 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801643:	55                   	push   %ebp
  801644:	89 e5                	mov    %esp,%ebp
  801646:	53                   	push   %ebx
  801647:	83 ec 14             	sub    $0x14,%esp
  80164a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80164d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801650:	50                   	push   %eax
  801651:	53                   	push   %ebx
  801652:	e8 e4 fb ff ff       	call   80123b <fd_lookup>
  801657:	83 c4 08             	add    $0x8,%esp
  80165a:	85 c0                	test   %eax,%eax
  80165c:	78 5f                	js     8016bd <ftruncate+0x7a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80165e:	83 ec 08             	sub    $0x8,%esp
  801661:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801664:	50                   	push   %eax
  801665:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801668:	ff 30                	pushl  (%eax)
  80166a:	e8 22 fc ff ff       	call   801291 <dev_lookup>
  80166f:	83 c4 10             	add    $0x10,%esp
  801672:	85 c0                	test   %eax,%eax
  801674:	78 47                	js     8016bd <ftruncate+0x7a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801676:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801679:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80167d:	75 21                	jne    8016a0 <ftruncate+0x5d>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80167f:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801684:	8b 40 48             	mov    0x48(%eax),%eax
  801687:	83 ec 04             	sub    $0x4,%esp
  80168a:	53                   	push   %ebx
  80168b:	50                   	push   %eax
  80168c:	68 ec 26 80 00       	push   $0x8026ec
  801691:	e8 26 eb ff ff       	call   8001bc <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801696:	83 c4 10             	add    $0x10,%esp
  801699:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80169e:	eb 1d                	jmp    8016bd <ftruncate+0x7a>
	}
	if (!dev->dev_trunc)
  8016a0:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8016a3:	8b 52 18             	mov    0x18(%edx),%edx
  8016a6:	85 d2                	test   %edx,%edx
  8016a8:	74 0e                	je     8016b8 <ftruncate+0x75>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8016aa:	83 ec 08             	sub    $0x8,%esp
  8016ad:	ff 75 0c             	pushl  0xc(%ebp)
  8016b0:	50                   	push   %eax
  8016b1:	ff d2                	call   *%edx
  8016b3:	83 c4 10             	add    $0x10,%esp
  8016b6:	eb 05                	jmp    8016bd <ftruncate+0x7a>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8016b8:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  8016bd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016c0:	c9                   	leave  
  8016c1:	c3                   	ret    

008016c2 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8016c2:	55                   	push   %ebp
  8016c3:	89 e5                	mov    %esp,%ebp
  8016c5:	53                   	push   %ebx
  8016c6:	83 ec 14             	sub    $0x14,%esp
  8016c9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016cc:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016cf:	50                   	push   %eax
  8016d0:	ff 75 08             	pushl  0x8(%ebp)
  8016d3:	e8 63 fb ff ff       	call   80123b <fd_lookup>
  8016d8:	83 c4 08             	add    $0x8,%esp
  8016db:	85 c0                	test   %eax,%eax
  8016dd:	78 52                	js     801731 <fstat+0x6f>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016df:	83 ec 08             	sub    $0x8,%esp
  8016e2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016e5:	50                   	push   %eax
  8016e6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016e9:	ff 30                	pushl  (%eax)
  8016eb:	e8 a1 fb ff ff       	call   801291 <dev_lookup>
  8016f0:	83 c4 10             	add    $0x10,%esp
  8016f3:	85 c0                	test   %eax,%eax
  8016f5:	78 3a                	js     801731 <fstat+0x6f>
		return r;
	if (!dev->dev_stat)
  8016f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016fa:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8016fe:	74 2c                	je     80172c <fstat+0x6a>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801700:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801703:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80170a:	00 00 00 
	stat->st_isdir = 0;
  80170d:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801714:	00 00 00 
	stat->st_dev = dev;
  801717:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80171d:	83 ec 08             	sub    $0x8,%esp
  801720:	53                   	push   %ebx
  801721:	ff 75 f0             	pushl  -0x10(%ebp)
  801724:	ff 50 14             	call   *0x14(%eax)
  801727:	83 c4 10             	add    $0x10,%esp
  80172a:	eb 05                	jmp    801731 <fstat+0x6f>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  80172c:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801731:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801734:	c9                   	leave  
  801735:	c3                   	ret    

00801736 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801736:	55                   	push   %ebp
  801737:	89 e5                	mov    %esp,%ebp
  801739:	56                   	push   %esi
  80173a:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80173b:	83 ec 08             	sub    $0x8,%esp
  80173e:	6a 00                	push   $0x0
  801740:	ff 75 08             	pushl  0x8(%ebp)
  801743:	e8 78 01 00 00       	call   8018c0 <open>
  801748:	89 c3                	mov    %eax,%ebx
  80174a:	83 c4 10             	add    $0x10,%esp
  80174d:	85 c0                	test   %eax,%eax
  80174f:	78 1b                	js     80176c <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801751:	83 ec 08             	sub    $0x8,%esp
  801754:	ff 75 0c             	pushl  0xc(%ebp)
  801757:	50                   	push   %eax
  801758:	e8 65 ff ff ff       	call   8016c2 <fstat>
  80175d:	89 c6                	mov    %eax,%esi
	close(fd);
  80175f:	89 1c 24             	mov    %ebx,(%esp)
  801762:	e8 18 fc ff ff       	call   80137f <close>
	return r;
  801767:	83 c4 10             	add    $0x10,%esp
  80176a:	89 f3                	mov    %esi,%ebx
}
  80176c:	89 d8                	mov    %ebx,%eax
  80176e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801771:	5b                   	pop    %ebx
  801772:	5e                   	pop    %esi
  801773:	c9                   	leave  
  801774:	c3                   	ret    
  801775:	00 00                	add    %al,(%eax)
	...

00801778 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801778:	55                   	push   %ebp
  801779:	89 e5                	mov    %esp,%ebp
  80177b:	56                   	push   %esi
  80177c:	53                   	push   %ebx
  80177d:	89 c3                	mov    %eax,%ebx
  80177f:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  801781:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801788:	75 12                	jne    80179c <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80178a:	83 ec 0c             	sub    $0xc,%esp
  80178d:	6a 01                	push   $0x1
  80178f:	e8 ae f9 ff ff       	call   801142 <ipc_find_env>
  801794:	a3 00 40 80 00       	mov    %eax,0x804000
  801799:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80179c:	6a 07                	push   $0x7
  80179e:	68 00 50 80 00       	push   $0x805000
  8017a3:	53                   	push   %ebx
  8017a4:	ff 35 00 40 80 00    	pushl  0x804000
  8017aa:	e8 3e f9 ff ff       	call   8010ed <ipc_send>
	
	return ipc_recv(NULL, dstva, NULL);
  8017af:	83 c4 0c             	add    $0xc,%esp
  8017b2:	6a 00                	push   $0x0
  8017b4:	56                   	push   %esi
  8017b5:	6a 00                	push   $0x0
  8017b7:	e8 bc f8 ff ff       	call   801078 <ipc_recv>
}
  8017bc:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017bf:	5b                   	pop    %ebx
  8017c0:	5e                   	pop    %esi
  8017c1:	c9                   	leave  
  8017c2:	c3                   	ret    

008017c3 <devfile_stat>:
}


static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8017c3:	55                   	push   %ebp
  8017c4:	89 e5                	mov    %esp,%ebp
  8017c6:	53                   	push   %ebx
  8017c7:	83 ec 04             	sub    $0x4,%esp
  8017ca:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8017cd:	8b 45 08             	mov    0x8(%ebp),%eax
  8017d0:	8b 40 0c             	mov    0xc(%eax),%eax
  8017d3:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0) {
  8017d8:	ba 00 00 00 00       	mov    $0x0,%edx
  8017dd:	b8 05 00 00 00       	mov    $0x5,%eax
  8017e2:	e8 91 ff ff ff       	call   801778 <fsipc>
  8017e7:	85 c0                	test   %eax,%eax
  8017e9:	78 2c                	js     801817 <devfile_stat+0x54>
		return r;
	}
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8017eb:	83 ec 08             	sub    $0x8,%esp
  8017ee:	68 00 50 80 00       	push   $0x805000
  8017f3:	53                   	push   %ebx
  8017f4:	e8 79 ef ff ff       	call   800772 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8017f9:	a1 80 50 80 00       	mov    0x805080,%eax
  8017fe:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801804:	a1 84 50 80 00       	mov    0x805084,%eax
  801809:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80180f:	83 c4 10             	add    $0x10,%esp
  801812:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801817:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80181a:	c9                   	leave  
  80181b:	c3                   	ret    

0080181c <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80181c:	55                   	push   %ebp
  80181d:	89 e5                	mov    %esp,%ebp
  80181f:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801822:	8b 45 08             	mov    0x8(%ebp),%eax
  801825:	8b 40 0c             	mov    0xc(%eax),%eax
  801828:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80182d:	ba 00 00 00 00       	mov    $0x0,%edx
  801832:	b8 06 00 00 00       	mov    $0x6,%eax
  801837:	e8 3c ff ff ff       	call   801778 <fsipc>
}
  80183c:	c9                   	leave  
  80183d:	c3                   	ret    

0080183e <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  80183e:	55                   	push   %ebp
  80183f:	89 e5                	mov    %esp,%ebp
  801841:	56                   	push   %esi
  801842:	53                   	push   %ebx
  801843:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801846:	8b 45 08             	mov    0x8(%ebp),%eax
  801849:	8b 40 0c             	mov    0xc(%eax),%eax
  80184c:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801851:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801857:	ba 00 00 00 00       	mov    $0x0,%edx
  80185c:	b8 03 00 00 00       	mov    $0x3,%eax
  801861:	e8 12 ff ff ff       	call   801778 <fsipc>
  801866:	89 c3                	mov    %eax,%ebx
  801868:	85 c0                	test   %eax,%eax
  80186a:	78 4b                	js     8018b7 <devfile_read+0x79>
		return r;
	assert(r <= n);
  80186c:	39 c6                	cmp    %eax,%esi
  80186e:	73 16                	jae    801886 <devfile_read+0x48>
  801870:	68 58 27 80 00       	push   $0x802758
  801875:	68 5f 27 80 00       	push   $0x80275f
  80187a:	6a 7d                	push   $0x7d
  80187c:	68 74 27 80 00       	push   $0x802774
  801881:	e8 ce 05 00 00       	call   801e54 <_panic>
	assert(r <= PGSIZE);
  801886:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80188b:	7e 16                	jle    8018a3 <devfile_read+0x65>
  80188d:	68 7f 27 80 00       	push   $0x80277f
  801892:	68 5f 27 80 00       	push   $0x80275f
  801897:	6a 7e                	push   $0x7e
  801899:	68 74 27 80 00       	push   $0x802774
  80189e:	e8 b1 05 00 00       	call   801e54 <_panic>
	memmove(buf, &fsipcbuf, r);
  8018a3:	83 ec 04             	sub    $0x4,%esp
  8018a6:	50                   	push   %eax
  8018a7:	68 00 50 80 00       	push   $0x805000
  8018ac:	ff 75 0c             	pushl  0xc(%ebp)
  8018af:	e8 7f f0 ff ff       	call   800933 <memmove>
	return r;
  8018b4:	83 c4 10             	add    $0x10,%esp
}
  8018b7:	89 d8                	mov    %ebx,%eax
  8018b9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018bc:	5b                   	pop    %ebx
  8018bd:	5e                   	pop    %esi
  8018be:	c9                   	leave  
  8018bf:	c3                   	ret    

008018c0 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8018c0:	55                   	push   %ebp
  8018c1:	89 e5                	mov    %esp,%ebp
  8018c3:	56                   	push   %esi
  8018c4:	53                   	push   %ebx
  8018c5:	83 ec 1c             	sub    $0x1c,%esp
  8018c8:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8018cb:	56                   	push   %esi
  8018cc:	e8 4f ee ff ff       	call   800720 <strlen>
  8018d1:	83 c4 10             	add    $0x10,%esp
  8018d4:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8018d9:	7f 65                	jg     801940 <open+0x80>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8018db:	83 ec 0c             	sub    $0xc,%esp
  8018de:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018e1:	50                   	push   %eax
  8018e2:	e8 e1 f8 ff ff       	call   8011c8 <fd_alloc>
  8018e7:	89 c3                	mov    %eax,%ebx
  8018e9:	83 c4 10             	add    $0x10,%esp
  8018ec:	85 c0                	test   %eax,%eax
  8018ee:	78 55                	js     801945 <open+0x85>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8018f0:	83 ec 08             	sub    $0x8,%esp
  8018f3:	56                   	push   %esi
  8018f4:	68 00 50 80 00       	push   $0x805000
  8018f9:	e8 74 ee ff ff       	call   800772 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8018fe:	8b 45 0c             	mov    0xc(%ebp),%eax
  801901:	a3 00 54 80 00       	mov    %eax,0x805400



	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801906:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801909:	b8 01 00 00 00       	mov    $0x1,%eax
  80190e:	e8 65 fe ff ff       	call   801778 <fsipc>
  801913:	89 c3                	mov    %eax,%ebx
  801915:	83 c4 10             	add    $0x10,%esp
  801918:	85 c0                	test   %eax,%eax
  80191a:	79 12                	jns    80192e <open+0x6e>
		fd_close(fd, 0);
  80191c:	83 ec 08             	sub    $0x8,%esp
  80191f:	6a 00                	push   $0x0
  801921:	ff 75 f4             	pushl  -0xc(%ebp)
  801924:	e8 ce f9 ff ff       	call   8012f7 <fd_close>
		return r;
  801929:	83 c4 10             	add    $0x10,%esp
  80192c:	eb 17                	jmp    801945 <open+0x85>
	}

	return fd2num(fd);
  80192e:	83 ec 0c             	sub    $0xc,%esp
  801931:	ff 75 f4             	pushl  -0xc(%ebp)
  801934:	e8 67 f8 ff ff       	call   8011a0 <fd2num>
  801939:	89 c3                	mov    %eax,%ebx
  80193b:	83 c4 10             	add    $0x10,%esp
  80193e:	eb 05                	jmp    801945 <open+0x85>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801940:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801945:	89 d8                	mov    %ebx,%eax
  801947:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80194a:	5b                   	pop    %ebx
  80194b:	5e                   	pop    %esi
  80194c:	c9                   	leave  
  80194d:	c3                   	ret    
	...

00801950 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801950:	55                   	push   %ebp
  801951:	89 e5                	mov    %esp,%ebp
  801953:	56                   	push   %esi
  801954:	53                   	push   %ebx
  801955:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801958:	83 ec 0c             	sub    $0xc,%esp
  80195b:	ff 75 08             	pushl  0x8(%ebp)
  80195e:	e8 4d f8 ff ff       	call   8011b0 <fd2data>
  801963:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  801965:	83 c4 08             	add    $0x8,%esp
  801968:	68 8b 27 80 00       	push   $0x80278b
  80196d:	56                   	push   %esi
  80196e:	e8 ff ed ff ff       	call   800772 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801973:	8b 43 04             	mov    0x4(%ebx),%eax
  801976:	2b 03                	sub    (%ebx),%eax
  801978:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  80197e:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  801985:	00 00 00 
	stat->st_dev = &devpipe;
  801988:	c7 86 88 00 00 00 20 	movl   $0x803020,0x88(%esi)
  80198f:	30 80 00 
	return 0;
}
  801992:	b8 00 00 00 00       	mov    $0x0,%eax
  801997:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80199a:	5b                   	pop    %ebx
  80199b:	5e                   	pop    %esi
  80199c:	c9                   	leave  
  80199d:	c3                   	ret    

0080199e <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  80199e:	55                   	push   %ebp
  80199f:	89 e5                	mov    %esp,%ebp
  8019a1:	53                   	push   %ebx
  8019a2:	83 ec 0c             	sub    $0xc,%esp
  8019a5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8019a8:	53                   	push   %ebx
  8019a9:	6a 00                	push   $0x0
  8019ab:	e8 8e f2 ff ff       	call   800c3e <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8019b0:	89 1c 24             	mov    %ebx,(%esp)
  8019b3:	e8 f8 f7 ff ff       	call   8011b0 <fd2data>
  8019b8:	83 c4 08             	add    $0x8,%esp
  8019bb:	50                   	push   %eax
  8019bc:	6a 00                	push   $0x0
  8019be:	e8 7b f2 ff ff       	call   800c3e <sys_page_unmap>
}
  8019c3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019c6:	c9                   	leave  
  8019c7:	c3                   	ret    

008019c8 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8019c8:	55                   	push   %ebp
  8019c9:	89 e5                	mov    %esp,%ebp
  8019cb:	57                   	push   %edi
  8019cc:	56                   	push   %esi
  8019cd:	53                   	push   %ebx
  8019ce:	83 ec 1c             	sub    $0x1c,%esp
  8019d1:	89 c7                	mov    %eax,%edi
  8019d3:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8019d6:	a1 04 40 80 00       	mov    0x804004,%eax
  8019db:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  8019de:	83 ec 0c             	sub    $0xc,%esp
  8019e1:	57                   	push   %edi
  8019e2:	e8 49 05 00 00       	call   801f30 <pageref>
  8019e7:	89 c6                	mov    %eax,%esi
  8019e9:	83 c4 04             	add    $0x4,%esp
  8019ec:	ff 75 e4             	pushl  -0x1c(%ebp)
  8019ef:	e8 3c 05 00 00       	call   801f30 <pageref>
  8019f4:	83 c4 10             	add    $0x10,%esp
  8019f7:	39 c6                	cmp    %eax,%esi
  8019f9:	0f 94 c0             	sete   %al
  8019fc:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  8019ff:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801a05:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801a08:	39 cb                	cmp    %ecx,%ebx
  801a0a:	75 08                	jne    801a14 <_pipeisclosed+0x4c>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  801a0c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a0f:	5b                   	pop    %ebx
  801a10:	5e                   	pop    %esi
  801a11:	5f                   	pop    %edi
  801a12:	c9                   	leave  
  801a13:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  801a14:	83 f8 01             	cmp    $0x1,%eax
  801a17:	75 bd                	jne    8019d6 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801a19:	8b 42 58             	mov    0x58(%edx),%eax
  801a1c:	6a 01                	push   $0x1
  801a1e:	50                   	push   %eax
  801a1f:	53                   	push   %ebx
  801a20:	68 92 27 80 00       	push   $0x802792
  801a25:	e8 92 e7 ff ff       	call   8001bc <cprintf>
  801a2a:	83 c4 10             	add    $0x10,%esp
  801a2d:	eb a7                	jmp    8019d6 <_pipeisclosed+0xe>

00801a2f <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801a2f:	55                   	push   %ebp
  801a30:	89 e5                	mov    %esp,%ebp
  801a32:	57                   	push   %edi
  801a33:	56                   	push   %esi
  801a34:	53                   	push   %ebx
  801a35:	83 ec 28             	sub    $0x28,%esp
  801a38:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801a3b:	56                   	push   %esi
  801a3c:	e8 6f f7 ff ff       	call   8011b0 <fd2data>
  801a41:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801a43:	83 c4 10             	add    $0x10,%esp
  801a46:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801a4a:	75 4a                	jne    801a96 <devpipe_write+0x67>
  801a4c:	bf 00 00 00 00       	mov    $0x0,%edi
  801a51:	eb 56                	jmp    801aa9 <devpipe_write+0x7a>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801a53:	89 da                	mov    %ebx,%edx
  801a55:	89 f0                	mov    %esi,%eax
  801a57:	e8 6c ff ff ff       	call   8019c8 <_pipeisclosed>
  801a5c:	85 c0                	test   %eax,%eax
  801a5e:	75 4d                	jne    801aad <devpipe_write+0x7e>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801a60:	e8 68 f1 ff ff       	call   800bcd <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801a65:	8b 43 04             	mov    0x4(%ebx),%eax
  801a68:	8b 13                	mov    (%ebx),%edx
  801a6a:	83 c2 20             	add    $0x20,%edx
  801a6d:	39 d0                	cmp    %edx,%eax
  801a6f:	73 e2                	jae    801a53 <devpipe_write+0x24>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801a71:	89 c2                	mov    %eax,%edx
  801a73:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  801a79:	79 05                	jns    801a80 <devpipe_write+0x51>
  801a7b:	4a                   	dec    %edx
  801a7c:	83 ca e0             	or     $0xffffffe0,%edx
  801a7f:	42                   	inc    %edx
  801a80:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801a83:	8a 0c 39             	mov    (%ecx,%edi,1),%cl
  801a86:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801a8a:	40                   	inc    %eax
  801a8b:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801a8e:	47                   	inc    %edi
  801a8f:	39 7d 10             	cmp    %edi,0x10(%ebp)
  801a92:	77 07                	ja     801a9b <devpipe_write+0x6c>
  801a94:	eb 13                	jmp    801aa9 <devpipe_write+0x7a>
  801a96:	bf 00 00 00 00       	mov    $0x0,%edi
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801a9b:	8b 43 04             	mov    0x4(%ebx),%eax
  801a9e:	8b 13                	mov    (%ebx),%edx
  801aa0:	83 c2 20             	add    $0x20,%edx
  801aa3:	39 d0                	cmp    %edx,%eax
  801aa5:	73 ac                	jae    801a53 <devpipe_write+0x24>
  801aa7:	eb c8                	jmp    801a71 <devpipe_write+0x42>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801aa9:	89 f8                	mov    %edi,%eax
  801aab:	eb 05                	jmp    801ab2 <devpipe_write+0x83>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801aad:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801ab2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ab5:	5b                   	pop    %ebx
  801ab6:	5e                   	pop    %esi
  801ab7:	5f                   	pop    %edi
  801ab8:	c9                   	leave  
  801ab9:	c3                   	ret    

00801aba <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801aba:	55                   	push   %ebp
  801abb:	89 e5                	mov    %esp,%ebp
  801abd:	57                   	push   %edi
  801abe:	56                   	push   %esi
  801abf:	53                   	push   %ebx
  801ac0:	83 ec 18             	sub    $0x18,%esp
  801ac3:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801ac6:	57                   	push   %edi
  801ac7:	e8 e4 f6 ff ff       	call   8011b0 <fd2data>
  801acc:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801ace:	83 c4 10             	add    $0x10,%esp
  801ad1:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801ad5:	75 44                	jne    801b1b <devpipe_read+0x61>
  801ad7:	be 00 00 00 00       	mov    $0x0,%esi
  801adc:	eb 4f                	jmp    801b2d <devpipe_read+0x73>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
				return i;
  801ade:	89 f0                	mov    %esi,%eax
  801ae0:	eb 54                	jmp    801b36 <devpipe_read+0x7c>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801ae2:	89 da                	mov    %ebx,%edx
  801ae4:	89 f8                	mov    %edi,%eax
  801ae6:	e8 dd fe ff ff       	call   8019c8 <_pipeisclosed>
  801aeb:	85 c0                	test   %eax,%eax
  801aed:	75 42                	jne    801b31 <devpipe_read+0x77>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801aef:	e8 d9 f0 ff ff       	call   800bcd <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801af4:	8b 03                	mov    (%ebx),%eax
  801af6:	3b 43 04             	cmp    0x4(%ebx),%eax
  801af9:	74 e7                	je     801ae2 <devpipe_read+0x28>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801afb:	25 1f 00 00 80       	and    $0x8000001f,%eax
  801b00:	79 05                	jns    801b07 <devpipe_read+0x4d>
  801b02:	48                   	dec    %eax
  801b03:	83 c8 e0             	or     $0xffffffe0,%eax
  801b06:	40                   	inc    %eax
  801b07:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  801b0b:	8b 55 0c             	mov    0xc(%ebp),%edx
  801b0e:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  801b11:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b13:	46                   	inc    %esi
  801b14:	39 75 10             	cmp    %esi,0x10(%ebp)
  801b17:	77 07                	ja     801b20 <devpipe_read+0x66>
  801b19:	eb 12                	jmp    801b2d <devpipe_read+0x73>
  801b1b:	be 00 00 00 00       	mov    $0x0,%esi
		while (p->p_rpos == p->p_wpos) {
  801b20:	8b 03                	mov    (%ebx),%eax
  801b22:	3b 43 04             	cmp    0x4(%ebx),%eax
  801b25:	75 d4                	jne    801afb <devpipe_read+0x41>
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801b27:	85 f6                	test   %esi,%esi
  801b29:	75 b3                	jne    801ade <devpipe_read+0x24>
  801b2b:	eb b5                	jmp    801ae2 <devpipe_read+0x28>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801b2d:	89 f0                	mov    %esi,%eax
  801b2f:	eb 05                	jmp    801b36 <devpipe_read+0x7c>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801b31:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801b36:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b39:	5b                   	pop    %ebx
  801b3a:	5e                   	pop    %esi
  801b3b:	5f                   	pop    %edi
  801b3c:	c9                   	leave  
  801b3d:	c3                   	ret    

00801b3e <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801b3e:	55                   	push   %ebp
  801b3f:	89 e5                	mov    %esp,%ebp
  801b41:	57                   	push   %edi
  801b42:	56                   	push   %esi
  801b43:	53                   	push   %ebx
  801b44:	83 ec 28             	sub    $0x28,%esp
  801b47:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801b4a:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801b4d:	50                   	push   %eax
  801b4e:	e8 75 f6 ff ff       	call   8011c8 <fd_alloc>
  801b53:	89 c3                	mov    %eax,%ebx
  801b55:	83 c4 10             	add    $0x10,%esp
  801b58:	85 c0                	test   %eax,%eax
  801b5a:	0f 88 24 01 00 00    	js     801c84 <pipe+0x146>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b60:	83 ec 04             	sub    $0x4,%esp
  801b63:	68 07 04 00 00       	push   $0x407
  801b68:	ff 75 e4             	pushl  -0x1c(%ebp)
  801b6b:	6a 00                	push   $0x0
  801b6d:	e8 82 f0 ff ff       	call   800bf4 <sys_page_alloc>
  801b72:	89 c3                	mov    %eax,%ebx
  801b74:	83 c4 10             	add    $0x10,%esp
  801b77:	85 c0                	test   %eax,%eax
  801b79:	0f 88 05 01 00 00    	js     801c84 <pipe+0x146>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801b7f:	83 ec 0c             	sub    $0xc,%esp
  801b82:	8d 45 e0             	lea    -0x20(%ebp),%eax
  801b85:	50                   	push   %eax
  801b86:	e8 3d f6 ff ff       	call   8011c8 <fd_alloc>
  801b8b:	89 c3                	mov    %eax,%ebx
  801b8d:	83 c4 10             	add    $0x10,%esp
  801b90:	85 c0                	test   %eax,%eax
  801b92:	0f 88 dc 00 00 00    	js     801c74 <pipe+0x136>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b98:	83 ec 04             	sub    $0x4,%esp
  801b9b:	68 07 04 00 00       	push   $0x407
  801ba0:	ff 75 e0             	pushl  -0x20(%ebp)
  801ba3:	6a 00                	push   $0x0
  801ba5:	e8 4a f0 ff ff       	call   800bf4 <sys_page_alloc>
  801baa:	89 c3                	mov    %eax,%ebx
  801bac:	83 c4 10             	add    $0x10,%esp
  801baf:	85 c0                	test   %eax,%eax
  801bb1:	0f 88 bd 00 00 00    	js     801c74 <pipe+0x136>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801bb7:	83 ec 0c             	sub    $0xc,%esp
  801bba:	ff 75 e4             	pushl  -0x1c(%ebp)
  801bbd:	e8 ee f5 ff ff       	call   8011b0 <fd2data>
  801bc2:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801bc4:	83 c4 0c             	add    $0xc,%esp
  801bc7:	68 07 04 00 00       	push   $0x407
  801bcc:	50                   	push   %eax
  801bcd:	6a 00                	push   $0x0
  801bcf:	e8 20 f0 ff ff       	call   800bf4 <sys_page_alloc>
  801bd4:	89 c3                	mov    %eax,%ebx
  801bd6:	83 c4 10             	add    $0x10,%esp
  801bd9:	85 c0                	test   %eax,%eax
  801bdb:	0f 88 83 00 00 00    	js     801c64 <pipe+0x126>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801be1:	83 ec 0c             	sub    $0xc,%esp
  801be4:	ff 75 e0             	pushl  -0x20(%ebp)
  801be7:	e8 c4 f5 ff ff       	call   8011b0 <fd2data>
  801bec:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801bf3:	50                   	push   %eax
  801bf4:	6a 00                	push   $0x0
  801bf6:	56                   	push   %esi
  801bf7:	6a 00                	push   $0x0
  801bf9:	e8 1a f0 ff ff       	call   800c18 <sys_page_map>
  801bfe:	89 c3                	mov    %eax,%ebx
  801c00:	83 c4 20             	add    $0x20,%esp
  801c03:	85 c0                	test   %eax,%eax
  801c05:	78 4f                	js     801c56 <pipe+0x118>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801c07:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801c0d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801c10:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801c12:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801c15:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801c1c:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801c22:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801c25:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801c27:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801c2a:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801c31:	83 ec 0c             	sub    $0xc,%esp
  801c34:	ff 75 e4             	pushl  -0x1c(%ebp)
  801c37:	e8 64 f5 ff ff       	call   8011a0 <fd2num>
  801c3c:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  801c3e:	83 c4 04             	add    $0x4,%esp
  801c41:	ff 75 e0             	pushl  -0x20(%ebp)
  801c44:	e8 57 f5 ff ff       	call   8011a0 <fd2num>
  801c49:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  801c4c:	83 c4 10             	add    $0x10,%esp
  801c4f:	bb 00 00 00 00       	mov    $0x0,%ebx
  801c54:	eb 2e                	jmp    801c84 <pipe+0x146>

    err3:
	sys_page_unmap(0, va);
  801c56:	83 ec 08             	sub    $0x8,%esp
  801c59:	56                   	push   %esi
  801c5a:	6a 00                	push   $0x0
  801c5c:	e8 dd ef ff ff       	call   800c3e <sys_page_unmap>
  801c61:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801c64:	83 ec 08             	sub    $0x8,%esp
  801c67:	ff 75 e0             	pushl  -0x20(%ebp)
  801c6a:	6a 00                	push   $0x0
  801c6c:	e8 cd ef ff ff       	call   800c3e <sys_page_unmap>
  801c71:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801c74:	83 ec 08             	sub    $0x8,%esp
  801c77:	ff 75 e4             	pushl  -0x1c(%ebp)
  801c7a:	6a 00                	push   $0x0
  801c7c:	e8 bd ef ff ff       	call   800c3e <sys_page_unmap>
  801c81:	83 c4 10             	add    $0x10,%esp
    err:
	return r;
}
  801c84:	89 d8                	mov    %ebx,%eax
  801c86:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c89:	5b                   	pop    %ebx
  801c8a:	5e                   	pop    %esi
  801c8b:	5f                   	pop    %edi
  801c8c:	c9                   	leave  
  801c8d:	c3                   	ret    

00801c8e <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801c8e:	55                   	push   %ebp
  801c8f:	89 e5                	mov    %esp,%ebp
  801c91:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801c94:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c97:	50                   	push   %eax
  801c98:	ff 75 08             	pushl  0x8(%ebp)
  801c9b:	e8 9b f5 ff ff       	call   80123b <fd_lookup>
  801ca0:	83 c4 10             	add    $0x10,%esp
  801ca3:	85 c0                	test   %eax,%eax
  801ca5:	78 18                	js     801cbf <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801ca7:	83 ec 0c             	sub    $0xc,%esp
  801caa:	ff 75 f4             	pushl  -0xc(%ebp)
  801cad:	e8 fe f4 ff ff       	call   8011b0 <fd2data>
	return _pipeisclosed(fd, p);
  801cb2:	89 c2                	mov    %eax,%edx
  801cb4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cb7:	e8 0c fd ff ff       	call   8019c8 <_pipeisclosed>
  801cbc:	83 c4 10             	add    $0x10,%esp
}
  801cbf:	c9                   	leave  
  801cc0:	c3                   	ret    
  801cc1:	00 00                	add    %al,(%eax)
	...

00801cc4 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801cc4:	55                   	push   %ebp
  801cc5:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801cc7:	b8 00 00 00 00       	mov    $0x0,%eax
  801ccc:	c9                   	leave  
  801ccd:	c3                   	ret    

00801cce <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801cce:	55                   	push   %ebp
  801ccf:	89 e5                	mov    %esp,%ebp
  801cd1:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801cd4:	68 aa 27 80 00       	push   $0x8027aa
  801cd9:	ff 75 0c             	pushl  0xc(%ebp)
  801cdc:	e8 91 ea ff ff       	call   800772 <strcpy>
	return 0;
}
  801ce1:	b8 00 00 00 00       	mov    $0x0,%eax
  801ce6:	c9                   	leave  
  801ce7:	c3                   	ret    

00801ce8 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801ce8:	55                   	push   %ebp
  801ce9:	89 e5                	mov    %esp,%ebp
  801ceb:	57                   	push   %edi
  801cec:	56                   	push   %esi
  801ced:	53                   	push   %ebx
  801cee:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801cf4:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801cf8:	74 45                	je     801d3f <devcons_write+0x57>
  801cfa:	b8 00 00 00 00       	mov    $0x0,%eax
  801cff:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801d04:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801d0a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801d0d:	29 c3                	sub    %eax,%ebx
		if (m > sizeof(buf) - 1)
  801d0f:	83 fb 7f             	cmp    $0x7f,%ebx
  801d12:	76 05                	jbe    801d19 <devcons_write+0x31>
			m = sizeof(buf) - 1;
  801d14:	bb 7f 00 00 00       	mov    $0x7f,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  801d19:	83 ec 04             	sub    $0x4,%esp
  801d1c:	53                   	push   %ebx
  801d1d:	03 45 0c             	add    0xc(%ebp),%eax
  801d20:	50                   	push   %eax
  801d21:	57                   	push   %edi
  801d22:	e8 0c ec ff ff       	call   800933 <memmove>
		sys_cputs(buf, m);
  801d27:	83 c4 08             	add    $0x8,%esp
  801d2a:	53                   	push   %ebx
  801d2b:	57                   	push   %edi
  801d2c:	e8 0c ee ff ff       	call   800b3d <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801d31:	01 de                	add    %ebx,%esi
  801d33:	89 f0                	mov    %esi,%eax
  801d35:	83 c4 10             	add    $0x10,%esp
  801d38:	3b 75 10             	cmp    0x10(%ebp),%esi
  801d3b:	72 cd                	jb     801d0a <devcons_write+0x22>
  801d3d:	eb 05                	jmp    801d44 <devcons_write+0x5c>
  801d3f:	be 00 00 00 00       	mov    $0x0,%esi
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801d44:	89 f0                	mov    %esi,%eax
  801d46:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d49:	5b                   	pop    %ebx
  801d4a:	5e                   	pop    %esi
  801d4b:	5f                   	pop    %edi
  801d4c:	c9                   	leave  
  801d4d:	c3                   	ret    

00801d4e <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801d4e:	55                   	push   %ebp
  801d4f:	89 e5                	mov    %esp,%ebp
  801d51:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  801d54:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801d58:	75 07                	jne    801d61 <devcons_read+0x13>
  801d5a:	eb 25                	jmp    801d81 <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801d5c:	e8 6c ee ff ff       	call   800bcd <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801d61:	e8 fd ed ff ff       	call   800b63 <sys_cgetc>
  801d66:	85 c0                	test   %eax,%eax
  801d68:	74 f2                	je     801d5c <devcons_read+0xe>
  801d6a:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  801d6c:	85 c0                	test   %eax,%eax
  801d6e:	78 1d                	js     801d8d <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801d70:	83 f8 04             	cmp    $0x4,%eax
  801d73:	74 13                	je     801d88 <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  801d75:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d78:	88 10                	mov    %dl,(%eax)
	return 1;
  801d7a:	b8 01 00 00 00       	mov    $0x1,%eax
  801d7f:	eb 0c                	jmp    801d8d <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  801d81:	b8 00 00 00 00       	mov    $0x0,%eax
  801d86:	eb 05                	jmp    801d8d <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801d88:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801d8d:	c9                   	leave  
  801d8e:	c3                   	ret    

00801d8f <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801d8f:	55                   	push   %ebp
  801d90:	89 e5                	mov    %esp,%ebp
  801d92:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801d95:	8b 45 08             	mov    0x8(%ebp),%eax
  801d98:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801d9b:	6a 01                	push   $0x1
  801d9d:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801da0:	50                   	push   %eax
  801da1:	e8 97 ed ff ff       	call   800b3d <sys_cputs>
  801da6:	83 c4 10             	add    $0x10,%esp
}
  801da9:	c9                   	leave  
  801daa:	c3                   	ret    

00801dab <getchar>:

int
getchar(void)
{
  801dab:	55                   	push   %ebp
  801dac:	89 e5                	mov    %esp,%ebp
  801dae:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801db1:	6a 01                	push   $0x1
  801db3:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801db6:	50                   	push   %eax
  801db7:	6a 00                	push   $0x0
  801db9:	e8 fe f6 ff ff       	call   8014bc <read>
	if (r < 0)
  801dbe:	83 c4 10             	add    $0x10,%esp
  801dc1:	85 c0                	test   %eax,%eax
  801dc3:	78 0f                	js     801dd4 <getchar+0x29>
		return r;
	if (r < 1)
  801dc5:	85 c0                	test   %eax,%eax
  801dc7:	7e 06                	jle    801dcf <getchar+0x24>
		return -E_EOF;
	return c;
  801dc9:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801dcd:	eb 05                	jmp    801dd4 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801dcf:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801dd4:	c9                   	leave  
  801dd5:	c3                   	ret    

00801dd6 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801dd6:	55                   	push   %ebp
  801dd7:	89 e5                	mov    %esp,%ebp
  801dd9:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801ddc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ddf:	50                   	push   %eax
  801de0:	ff 75 08             	pushl  0x8(%ebp)
  801de3:	e8 53 f4 ff ff       	call   80123b <fd_lookup>
  801de8:	83 c4 10             	add    $0x10,%esp
  801deb:	85 c0                	test   %eax,%eax
  801ded:	78 11                	js     801e00 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801def:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801df2:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801df8:	39 10                	cmp    %edx,(%eax)
  801dfa:	0f 94 c0             	sete   %al
  801dfd:	0f b6 c0             	movzbl %al,%eax
}
  801e00:	c9                   	leave  
  801e01:	c3                   	ret    

00801e02 <opencons>:

int
opencons(void)
{
  801e02:	55                   	push   %ebp
  801e03:	89 e5                	mov    %esp,%ebp
  801e05:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801e08:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e0b:	50                   	push   %eax
  801e0c:	e8 b7 f3 ff ff       	call   8011c8 <fd_alloc>
  801e11:	83 c4 10             	add    $0x10,%esp
  801e14:	85 c0                	test   %eax,%eax
  801e16:	78 3a                	js     801e52 <opencons+0x50>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801e18:	83 ec 04             	sub    $0x4,%esp
  801e1b:	68 07 04 00 00       	push   $0x407
  801e20:	ff 75 f4             	pushl  -0xc(%ebp)
  801e23:	6a 00                	push   $0x0
  801e25:	e8 ca ed ff ff       	call   800bf4 <sys_page_alloc>
  801e2a:	83 c4 10             	add    $0x10,%esp
  801e2d:	85 c0                	test   %eax,%eax
  801e2f:	78 21                	js     801e52 <opencons+0x50>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801e31:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801e37:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e3a:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801e3c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e3f:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801e46:	83 ec 0c             	sub    $0xc,%esp
  801e49:	50                   	push   %eax
  801e4a:	e8 51 f3 ff ff       	call   8011a0 <fd2num>
  801e4f:	83 c4 10             	add    $0x10,%esp
}
  801e52:	c9                   	leave  
  801e53:	c3                   	ret    

00801e54 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801e54:	55                   	push   %ebp
  801e55:	89 e5                	mov    %esp,%ebp
  801e57:	56                   	push   %esi
  801e58:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801e59:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801e5c:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  801e62:	e8 42 ed ff ff       	call   800ba9 <sys_getenvid>
  801e67:	83 ec 0c             	sub    $0xc,%esp
  801e6a:	ff 75 0c             	pushl  0xc(%ebp)
  801e6d:	ff 75 08             	pushl  0x8(%ebp)
  801e70:	53                   	push   %ebx
  801e71:	50                   	push   %eax
  801e72:	68 b8 27 80 00       	push   $0x8027b8
  801e77:	e8 40 e3 ff ff       	call   8001bc <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801e7c:	83 c4 18             	add    $0x18,%esp
  801e7f:	56                   	push   %esi
  801e80:	ff 75 10             	pushl  0x10(%ebp)
  801e83:	e8 e3 e2 ff ff       	call   80016b <vcprintf>
	cprintf("\n");
  801e88:	c7 04 24 a3 27 80 00 	movl   $0x8027a3,(%esp)
  801e8f:	e8 28 e3 ff ff       	call   8001bc <cprintf>
  801e94:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801e97:	cc                   	int3   
  801e98:	eb fd                	jmp    801e97 <_panic+0x43>
	...

00801e9c <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801e9c:	55                   	push   %ebp
  801e9d:	89 e5                	mov    %esp,%ebp
  801e9f:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  801ea2:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801ea9:	75 52                	jne    801efd <set_pgfault_handler+0x61>
		// First time through!	
		// LAB 4: Your code here.

		//int sys_page_alloc(envid_t envid, void *va, int perm)
		r = sys_page_alloc(0, (void*)(UXSTACKTOP - PGSIZE), PTE_U | PTE_W | PTE_P);
  801eab:	83 ec 04             	sub    $0x4,%esp
  801eae:	6a 07                	push   $0x7
  801eb0:	68 00 f0 bf ee       	push   $0xeebff000
  801eb5:	6a 00                	push   $0x0
  801eb7:	e8 38 ed ff ff       	call   800bf4 <sys_page_alloc>
		if (r < 0) {
  801ebc:	83 c4 10             	add    $0x10,%esp
  801ebf:	85 c0                	test   %eax,%eax
  801ec1:	79 12                	jns    801ed5 <set_pgfault_handler+0x39>
			panic("sys_page_alloc error : %e\n", r);
  801ec3:	50                   	push   %eax
  801ec4:	68 db 27 80 00       	push   $0x8027db
  801ec9:	6a 24                	push   $0x24
  801ecb:	68 f6 27 80 00       	push   $0x8027f6
  801ed0:	e8 7f ff ff ff       	call   801e54 <_panic>
		}

		// how to know envid, put 0, envid2env will help us to get curenv in syscall
		r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);		
  801ed5:	83 ec 08             	sub    $0x8,%esp
  801ed8:	68 08 1f 80 00       	push   $0x801f08
  801edd:	6a 00                	push   $0x0
  801edf:	e8 c3 ed ff ff       	call   800ca7 <sys_env_set_pgfault_upcall>
		if (r < 0) {
  801ee4:	83 c4 10             	add    $0x10,%esp
  801ee7:	85 c0                	test   %eax,%eax
  801ee9:	79 12                	jns    801efd <set_pgfault_handler+0x61>
			panic("sys_env_set_pgfault_upcall error : %e\n", r);
  801eeb:	50                   	push   %eax
  801eec:	68 04 28 80 00       	push   $0x802804
  801ef1:	6a 2a                	push   $0x2a
  801ef3:	68 f6 27 80 00       	push   $0x8027f6
  801ef8:	e8 57 ff ff ff       	call   801e54 <_panic>
		}
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801efd:	8b 45 08             	mov    0x8(%ebp),%eax
  801f00:	a3 00 60 80 00       	mov    %eax,0x806000
}
  801f05:	c9                   	leave  
  801f06:	c3                   	ret    
	...

00801f08 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801f08:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801f09:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  801f0e:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801f10:	83 c4 04             	add    $0x4,%esp
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	
	// fix old esp
	movl 0x30(%esp), %eax
  801f13:	8b 44 24 30          	mov    0x30(%esp),%eax
	subl $0x4, %eax
  801f17:	83 e8 04             	sub    $0x4,%eax
	movl %eax, 0x30(%esp)
  801f1a:	89 44 24 30          	mov    %eax,0x30(%esp)

	// set trap-time %eip
	movl 0x28(%esp), %ebx
  801f1e:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	movl %ebx, (%eax)
  801f22:	89 18                	mov    %ebx,(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $0x08, %esp 	// ignore err_code and fault_va
  801f24:	83 c4 08             	add    $0x8,%esp
	popal 				// restore registers
  801f27:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x04, %esp 	// ignore eip 
  801f28:	83 c4 04             	add    $0x4,%esp
	popfl				// modify eflags
  801f2b:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  801f2c:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  801f2d:	c3                   	ret    
	...

00801f30 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801f30:	55                   	push   %ebp
  801f31:	89 e5                	mov    %esp,%ebp
  801f33:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801f36:	89 c2                	mov    %eax,%edx
  801f38:	c1 ea 16             	shr    $0x16,%edx
  801f3b:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801f42:	f6 c2 01             	test   $0x1,%dl
  801f45:	74 1e                	je     801f65 <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  801f47:	c1 e8 0c             	shr    $0xc,%eax
  801f4a:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801f51:	a8 01                	test   $0x1,%al
  801f53:	74 17                	je     801f6c <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801f55:	c1 e8 0c             	shr    $0xc,%eax
  801f58:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  801f5f:	ef 
  801f60:	0f b7 c0             	movzwl %ax,%eax
  801f63:	eb 0c                	jmp    801f71 <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  801f65:	b8 00 00 00 00       	mov    $0x0,%eax
  801f6a:	eb 05                	jmp    801f71 <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  801f6c:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  801f71:	c9                   	leave  
  801f72:	c3                   	ret    
	...

00801f74 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  801f74:	55                   	push   %ebp
  801f75:	89 e5                	mov    %esp,%ebp
  801f77:	57                   	push   %edi
  801f78:	56                   	push   %esi
  801f79:	83 ec 10             	sub    $0x10,%esp
  801f7c:	8b 7d 08             	mov    0x8(%ebp),%edi
  801f7f:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  801f82:	89 7d f0             	mov    %edi,-0x10(%ebp)
  801f85:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  801f88:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  801f8b:	8b 45 14             	mov    0x14(%ebp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  801f8e:	85 c0                	test   %eax,%eax
  801f90:	75 2e                	jne    801fc0 <__udivdi3+0x4c>
    {
      if (d0 > n1)
  801f92:	39 f1                	cmp    %esi,%ecx
  801f94:	77 5a                	ja     801ff0 <__udivdi3+0x7c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  801f96:	85 c9                	test   %ecx,%ecx
  801f98:	75 0b                	jne    801fa5 <__udivdi3+0x31>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  801f9a:	b8 01 00 00 00       	mov    $0x1,%eax
  801f9f:	31 d2                	xor    %edx,%edx
  801fa1:	f7 f1                	div    %ecx
  801fa3:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  801fa5:	31 d2                	xor    %edx,%edx
  801fa7:	89 f0                	mov    %esi,%eax
  801fa9:	f7 f1                	div    %ecx
  801fab:	89 c6                	mov    %eax,%esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801fad:	89 f8                	mov    %edi,%eax
  801faf:	f7 f1                	div    %ecx
  801fb1:	89 c7                	mov    %eax,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801fb3:	89 f8                	mov    %edi,%eax
  801fb5:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801fb7:	83 c4 10             	add    $0x10,%esp
  801fba:	5e                   	pop    %esi
  801fbb:	5f                   	pop    %edi
  801fbc:	c9                   	leave  
  801fbd:	c3                   	ret    
  801fbe:	66 90                	xchg   %ax,%ax
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801fc0:	39 f0                	cmp    %esi,%eax
  801fc2:	77 1c                	ja     801fe0 <__udivdi3+0x6c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  801fc4:	0f bd f8             	bsr    %eax,%edi
	  if (bm == 0)
  801fc7:	83 f7 1f             	xor    $0x1f,%edi
  801fca:	75 3c                	jne    802008 <__udivdi3+0x94>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801fcc:	39 f0                	cmp    %esi,%eax
  801fce:	0f 82 90 00 00 00    	jb     802064 <__udivdi3+0xf0>
  801fd4:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801fd7:	39 55 f4             	cmp    %edx,-0xc(%ebp)
  801fda:	0f 86 84 00 00 00    	jbe    802064 <__udivdi3+0xf0>
  801fe0:	31 f6                	xor    %esi,%esi
  801fe2:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801fe4:	89 f8                	mov    %edi,%eax
  801fe6:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801fe8:	83 c4 10             	add    $0x10,%esp
  801feb:	5e                   	pop    %esi
  801fec:	5f                   	pop    %edi
  801fed:	c9                   	leave  
  801fee:	c3                   	ret    
  801fef:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801ff0:	89 f2                	mov    %esi,%edx
  801ff2:	89 f8                	mov    %edi,%eax
  801ff4:	f7 f1                	div    %ecx
  801ff6:	89 c7                	mov    %eax,%edi
  801ff8:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801ffa:	89 f8                	mov    %edi,%eax
  801ffc:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801ffe:	83 c4 10             	add    $0x10,%esp
  802001:	5e                   	pop    %esi
  802002:	5f                   	pop    %edi
  802003:	c9                   	leave  
  802004:	c3                   	ret    
  802005:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  802008:	89 f9                	mov    %edi,%ecx
  80200a:	d3 e0                	shl    %cl,%eax
  80200c:	89 45 e8             	mov    %eax,-0x18(%ebp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  80200f:	b8 20 00 00 00       	mov    $0x20,%eax
  802014:	29 f8                	sub    %edi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  802016:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802019:	88 c1                	mov    %al,%cl
  80201b:	d3 ea                	shr    %cl,%edx
  80201d:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  802020:	09 ca                	or     %ecx,%edx
  802022:	89 55 ec             	mov    %edx,-0x14(%ebp)
	      d0 = d0 << bm;
  802025:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802028:	89 f9                	mov    %edi,%ecx
  80202a:	d3 e2                	shl    %cl,%edx
  80202c:	89 55 f4             	mov    %edx,-0xc(%ebp)
	      n2 = n1 >> b;
  80202f:	89 f2                	mov    %esi,%edx
  802031:	88 c1                	mov    %al,%cl
  802033:	d3 ea                	shr    %cl,%edx
  802035:	89 55 e8             	mov    %edx,-0x18(%ebp)
	      n1 = (n1 << bm) | (n0 >> b);
  802038:	89 f2                	mov    %esi,%edx
  80203a:	89 f9                	mov    %edi,%ecx
  80203c:	d3 e2                	shl    %cl,%edx
  80203e:	8b 75 f0             	mov    -0x10(%ebp),%esi
  802041:	88 c1                	mov    %al,%cl
  802043:	d3 ee                	shr    %cl,%esi
  802045:	09 d6                	or     %edx,%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  802047:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  80204a:	89 f0                	mov    %esi,%eax
  80204c:	89 ca                	mov    %ecx,%edx
  80204e:	f7 75 ec             	divl   -0x14(%ebp)
  802051:	89 d1                	mov    %edx,%ecx
  802053:	89 c6                	mov    %eax,%esi
	      umul_ppmm (m1, m0, q0, d0);
  802055:	f7 65 f4             	mull   -0xc(%ebp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802058:	39 d1                	cmp    %edx,%ecx
  80205a:	72 28                	jb     802084 <__udivdi3+0x110>
  80205c:	74 1a                	je     802078 <__udivdi3+0x104>
  80205e:	89 f7                	mov    %esi,%edi
  802060:	31 f6                	xor    %esi,%esi
  802062:	eb 80                	jmp    801fe4 <__udivdi3+0x70>
	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  802064:	31 f6                	xor    %esi,%esi
  802066:	bf 01 00 00 00       	mov    $0x1,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  80206b:	89 f8                	mov    %edi,%eax
  80206d:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  80206f:	83 c4 10             	add    $0x10,%esp
  802072:	5e                   	pop    %esi
  802073:	5f                   	pop    %edi
  802074:	c9                   	leave  
  802075:	c3                   	ret    
  802076:	66 90                	xchg   %ax,%ax

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  802078:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80207b:	89 f9                	mov    %edi,%ecx
  80207d:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  80207f:	39 c2                	cmp    %eax,%edx
  802081:	73 db                	jae    80205e <__udivdi3+0xea>
  802083:	90                   	nop
		{
		  q0--;
  802084:	8d 7e ff             	lea    -0x1(%esi),%edi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  802087:	31 f6                	xor    %esi,%esi
  802089:	e9 56 ff ff ff       	jmp    801fe4 <__udivdi3+0x70>
	...

00802090 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  802090:	55                   	push   %ebp
  802091:	89 e5                	mov    %esp,%ebp
  802093:	57                   	push   %edi
  802094:	56                   	push   %esi
  802095:	83 ec 20             	sub    $0x20,%esp
  802098:	8b 45 08             	mov    0x8(%ebp),%eax
  80209b:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  80209e:	89 45 e8             	mov    %eax,-0x18(%ebp)
  8020a1:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  8020a4:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  8020a7:	8b 7d 14             	mov    0x14(%ebp),%edi
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  8020aa:	89 45 f0             	mov    %eax,-0x10(%ebp)
  n1 = nn.s.high;
  8020ad:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  8020af:	85 ff                	test   %edi,%edi
  8020b1:	75 15                	jne    8020c8 <__umoddi3+0x38>
    {
      if (d0 > n1)
  8020b3:	39 f1                	cmp    %esi,%ecx
  8020b5:	0f 86 99 00 00 00    	jbe    802154 <__umoddi3+0xc4>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8020bb:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  8020bd:	89 d0                	mov    %edx,%eax
  8020bf:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8020c1:	83 c4 20             	add    $0x20,%esp
  8020c4:	5e                   	pop    %esi
  8020c5:	5f                   	pop    %edi
  8020c6:	c9                   	leave  
  8020c7:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  8020c8:	39 f7                	cmp    %esi,%edi
  8020ca:	0f 87 a4 00 00 00    	ja     802174 <__umoddi3+0xe4>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  8020d0:	0f bd c7             	bsr    %edi,%eax
	  if (bm == 0)
  8020d3:	83 f0 1f             	xor    $0x1f,%eax
  8020d6:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8020d9:	0f 84 a1 00 00 00    	je     802180 <__umoddi3+0xf0>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  8020df:	89 f8                	mov    %edi,%eax
  8020e1:	8a 4d ec             	mov    -0x14(%ebp),%cl
  8020e4:	d3 e0                	shl    %cl,%eax
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  8020e6:	bf 20 00 00 00       	mov    $0x20,%edi
  8020eb:	2b 7d ec             	sub    -0x14(%ebp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  8020ee:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8020f1:	89 f9                	mov    %edi,%ecx
  8020f3:	d3 ea                	shr    %cl,%edx
  8020f5:	09 c2                	or     %eax,%edx
  8020f7:	89 55 f0             	mov    %edx,-0x10(%ebp)
	      d0 = d0 << bm;
  8020fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020fd:	8a 4d ec             	mov    -0x14(%ebp),%cl
  802100:	d3 e0                	shl    %cl,%eax
  802102:	89 45 f4             	mov    %eax,-0xc(%ebp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  802105:	89 f2                	mov    %esi,%edx
  802107:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  802109:	8b 45 e8             	mov    -0x18(%ebp),%eax
  80210c:	d3 e0                	shl    %cl,%eax
  80210e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  802111:	8b 45 e8             	mov    -0x18(%ebp),%eax
  802114:	89 f9                	mov    %edi,%ecx
  802116:	d3 e8                	shr    %cl,%eax
  802118:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  80211a:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  80211c:	89 f2                	mov    %esi,%edx
  80211e:	f7 75 f0             	divl   -0x10(%ebp)
  802121:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  802123:	f7 65 f4             	mull   -0xc(%ebp)
  802126:	89 55 e8             	mov    %edx,-0x18(%ebp)
  802129:	89 c1                	mov    %eax,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  80212b:	39 d6                	cmp    %edx,%esi
  80212d:	72 71                	jb     8021a0 <__umoddi3+0x110>
  80212f:	74 7f                	je     8021b0 <__umoddi3+0x120>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  802131:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802134:	29 c8                	sub    %ecx,%eax
  802136:	19 d6                	sbb    %edx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  802138:	8a 4d ec             	mov    -0x14(%ebp),%cl
  80213b:	d3 e8                	shr    %cl,%eax
  80213d:	89 f2                	mov    %esi,%edx
  80213f:	89 f9                	mov    %edi,%ecx
  802141:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  802143:	09 d0                	or     %edx,%eax
  802145:	89 f2                	mov    %esi,%edx
  802147:	8a 4d ec             	mov    -0x14(%ebp),%cl
  80214a:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  80214c:	83 c4 20             	add    $0x20,%esp
  80214f:	5e                   	pop    %esi
  802150:	5f                   	pop    %edi
  802151:	c9                   	leave  
  802152:	c3                   	ret    
  802153:	90                   	nop
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  802154:	85 c9                	test   %ecx,%ecx
  802156:	75 0b                	jne    802163 <__umoddi3+0xd3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  802158:	b8 01 00 00 00       	mov    $0x1,%eax
  80215d:	31 d2                	xor    %edx,%edx
  80215f:	f7 f1                	div    %ecx
  802161:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  802163:	89 f0                	mov    %esi,%eax
  802165:	31 d2                	xor    %edx,%edx
  802167:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802169:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80216c:	f7 f1                	div    %ecx
  80216e:	e9 4a ff ff ff       	jmp    8020bd <__umoddi3+0x2d>
  802173:	90                   	nop
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  802174:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802176:	83 c4 20             	add    $0x20,%esp
  802179:	5e                   	pop    %esi
  80217a:	5f                   	pop    %edi
  80217b:	c9                   	leave  
  80217c:	c3                   	ret    
  80217d:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802180:	39 f7                	cmp    %esi,%edi
  802182:	72 05                	jb     802189 <__umoddi3+0xf9>
  802184:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
  802187:	77 0c                	ja     802195 <__umoddi3+0x105>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  802189:	89 f2                	mov    %esi,%edx
  80218b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80218e:	29 c8                	sub    %ecx,%eax
  802190:	19 fa                	sbb    %edi,%edx
  802192:	89 45 f0             	mov    %eax,-0x10(%ebp)

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  802195:	8b 45 f0             	mov    -0x10(%ebp),%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802198:	83 c4 20             	add    $0x20,%esp
  80219b:	5e                   	pop    %esi
  80219c:	5f                   	pop    %edi
  80219d:	c9                   	leave  
  80219e:	c3                   	ret    
  80219f:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  8021a0:	8b 55 e8             	mov    -0x18(%ebp),%edx
  8021a3:	89 c1                	mov    %eax,%ecx
  8021a5:	2b 4d f4             	sub    -0xc(%ebp),%ecx
  8021a8:	1b 55 f0             	sbb    -0x10(%ebp),%edx
  8021ab:	eb 84                	jmp    802131 <__umoddi3+0xa1>
  8021ad:	8d 76 00             	lea    0x0(%esi),%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8021b0:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  8021b3:	72 eb                	jb     8021a0 <__umoddi3+0x110>
  8021b5:	89 f2                	mov    %esi,%edx
  8021b7:	e9 75 ff ff ff       	jmp    802131 <__umoddi3+0xa1>
