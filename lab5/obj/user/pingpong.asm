
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
  80003d:	e8 c4 0d 00 00       	call   800e06 <fork>
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
  800055:	68 a0 21 80 00       	push   $0x8021a0
  80005a:	e8 5d 01 00 00       	call   8001bc <cprintf>
		ipc_send(who, 0, 0, 0);
  80005f:	6a 00                	push   $0x0
  800061:	6a 00                	push   $0x0
  800063:	6a 00                	push   $0x0
  800065:	ff 75 e4             	pushl  -0x1c(%ebp)
  800068:	e8 58 10 00 00       	call   8010c5 <ipc_send>
  80006d:	83 c4 20             	add    $0x20,%esp
	}

	while (1) {
		uint32_t i = ipc_recv(&who, 0, 0);
  800070:	8d 7d e4             	lea    -0x1c(%ebp),%edi
  800073:	83 ec 04             	sub    $0x4,%esp
  800076:	6a 00                	push   $0x0
  800078:	6a 00                	push   $0x0
  80007a:	57                   	push   %edi
  80007b:	e8 d0 0f 00 00       	call   801050 <ipc_recv>
  800080:	89 c3                	mov    %eax,%ebx
		cprintf("%x got %d from %x\n", sys_getenvid(), i, who);
  800082:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  800085:	e8 1f 0b 00 00       	call   800ba9 <sys_getenvid>
  80008a:	56                   	push   %esi
  80008b:	53                   	push   %ebx
  80008c:	50                   	push   %eax
  80008d:	68 b6 21 80 00       	push   $0x8021b6
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
  8000a8:	e8 18 10 00 00       	call   8010c5 <ipc_send>
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
  800116:	e8 67 12 00 00       	call   801382 <close_all>
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
  800224:	e8 23 1d 00 00       	call   801f4c <__udivdi3>
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
  800260:	e8 03 1e 00 00       	call   802068 <__umoddi3>
  800265:	83 c4 14             	add    $0x14,%esp
  800268:	0f be 80 d3 21 80 00 	movsbl 0x8021d3(%eax),%eax
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
  8003ac:	ff 24 85 20 23 80 00 	jmp    *0x802320(,%eax,4)
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
  800458:	8b 04 85 80 24 80 00 	mov    0x802480(,%eax,4),%eax
  80045f:	85 c0                	test   %eax,%eax
  800461:	75 1a                	jne    80047d <vprintfmt+0x15c>
				printfmt(putch, putdat, "error %d", err);
  800463:	52                   	push   %edx
  800464:	68 eb 21 80 00       	push   $0x8021eb
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
  80047e:	68 51 27 80 00       	push   $0x802751
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
  8004b4:	c7 45 d0 e4 21 80 00 	movl   $0x8021e4,-0x30(%ebp)
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
  800b22:	68 df 24 80 00       	push   $0x8024df
  800b27:	6a 42                	push   $0x42
  800b29:	68 fc 24 80 00       	push   $0x8024fc
  800b2e:	e8 f9 12 00 00       	call   801e2c <_panic>

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

00800d34 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800d34:	55                   	push   %ebp
  800d35:	89 e5                	mov    %esp,%ebp
  800d37:	53                   	push   %ebx
  800d38:	83 ec 04             	sub    $0x4,%esp
  800d3b:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800d3e:	8b 18                	mov    (%eax),%ebx

	// LAB 4: Your code here.
	
	// cprintf("PAGE FAULT HANDLER, 0x%08x %d\n", (uint32_t)addr, err & FEC_WR);
	
	if ((err & FEC_WR) == 0)
  800d40:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800d44:	75 14                	jne    800d5a <pgfault+0x26>
		panic("pgfault, the fault is not a write\n");
  800d46:	83 ec 04             	sub    $0x4,%esp
  800d49:	68 0c 25 80 00       	push   $0x80250c
  800d4e:	6a 20                	push   $0x20
  800d50:	68 50 26 80 00       	push   $0x802650
  800d55:	e8 d2 10 00 00       	call   801e2c <_panic>

	uint32_t uaddr = (uint32_t) addr;
	if ((uvpd[PDX(addr)] & PTE_P) == 0 || (uvpt[uaddr / PGSIZE] & PTE_COW) == 0) {
  800d5a:	89 d8                	mov    %ebx,%eax
  800d5c:	c1 e8 16             	shr    $0x16,%eax
  800d5f:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800d66:	a8 01                	test   $0x1,%al
  800d68:	74 11                	je     800d7b <pgfault+0x47>
  800d6a:	89 d8                	mov    %ebx,%eax
  800d6c:	c1 e8 0c             	shr    $0xc,%eax
  800d6f:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800d76:	f6 c4 08             	test   $0x8,%ah
  800d79:	75 14                	jne    800d8f <pgfault+0x5b>
		panic("pgfault, not a copy-on-write page\n");
  800d7b:	83 ec 04             	sub    $0x4,%esp
  800d7e:	68 30 25 80 00       	push   $0x802530
  800d83:	6a 24                	push   $0x24
  800d85:	68 50 26 80 00       	push   $0x802650
  800d8a:	e8 9d 10 00 00       	call   801e2c <_panic>
	//   No need to explicitly delete the old page's mapping.

	// LAB 4: Your code here.

	// static int sys_page_alloc(envid_t envid, void *va, int perm)
	r = sys_page_alloc(0, (void *)PFTEMP, PTE_W | PTE_U | PTE_P);
  800d8f:	83 ec 04             	sub    $0x4,%esp
  800d92:	6a 07                	push   $0x7
  800d94:	68 00 f0 7f 00       	push   $0x7ff000
  800d99:	6a 00                	push   $0x0
  800d9b:	e8 54 fe ff ff       	call   800bf4 <sys_page_alloc>
	if (r < 0) panic("pgfault, sys_page_alloc error : %e\n", r);
  800da0:	83 c4 10             	add    $0x10,%esp
  800da3:	85 c0                	test   %eax,%eax
  800da5:	79 12                	jns    800db9 <pgfault+0x85>
  800da7:	50                   	push   %eax
  800da8:	68 54 25 80 00       	push   $0x802554
  800dad:	6a 32                	push   $0x32
  800daf:	68 50 26 80 00       	push   $0x802650
  800db4:	e8 73 10 00 00       	call   801e2c <_panic>

	// Oh my god, I forget this at the first, it waste me a lot of time to debug!!!
	addr = ROUNDDOWN(addr, PGSIZE);
  800db9:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	
	memcpy(PFTEMP, addr, PGSIZE);
  800dbf:	83 ec 04             	sub    $0x4,%esp
  800dc2:	68 00 10 00 00       	push   $0x1000
  800dc7:	53                   	push   %ebx
  800dc8:	68 00 f0 7f 00       	push   $0x7ff000
  800dcd:	e8 cb fb ff ff       	call   80099d <memcpy>
	
	r = sys_page_map(0, PFTEMP, 0, addr, PTE_W | PTE_U | PTE_P);
  800dd2:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800dd9:	53                   	push   %ebx
  800dda:	6a 00                	push   $0x0
  800ddc:	68 00 f0 7f 00       	push   $0x7ff000
  800de1:	6a 00                	push   $0x0
  800de3:	e8 30 fe ff ff       	call   800c18 <sys_page_map>
	if (r < 0) panic("pgfault, sys_page_map error : %e\n", r);
  800de8:	83 c4 20             	add    $0x20,%esp
  800deb:	85 c0                	test   %eax,%eax
  800ded:	79 12                	jns    800e01 <pgfault+0xcd>
  800def:	50                   	push   %eax
  800df0:	68 78 25 80 00       	push   $0x802578
  800df5:	6a 3a                	push   $0x3a
  800df7:	68 50 26 80 00       	push   $0x802650
  800dfc:	e8 2b 10 00 00       	call   801e2c <_panic>

	return;
}
  800e01:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e04:	c9                   	leave  
  800e05:	c3                   	ret    

00800e06 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800e06:	55                   	push   %ebp
  800e07:	89 e5                	mov    %esp,%ebp
  800e09:	57                   	push   %edi
  800e0a:	56                   	push   %esi
  800e0b:	53                   	push   %ebx
  800e0c:	83 ec 28             	sub    $0x28,%esp
	// static int num = 0x100;

	// LAB 4: Your code here.
	set_pgfault_handler(pgfault);
  800e0f:	68 34 0d 80 00       	push   $0x800d34
  800e14:	e8 5b 10 00 00       	call   801e74 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  800e19:	ba 07 00 00 00       	mov    $0x7,%edx
  800e1e:	89 d0                	mov    %edx,%eax
  800e20:	cd 30                	int    $0x30
  800e22:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800e25:	89 c7                	mov    %eax,%edi
	int childpid = sys_exofork();
	if (childpid < 0) {
  800e27:	83 c4 10             	add    $0x10,%esp
  800e2a:	85 c0                	test   %eax,%eax
  800e2c:	79 12                	jns    800e40 <fork+0x3a>
		panic("fork sys_exofork error : %e\n", childpid);
  800e2e:	50                   	push   %eax
  800e2f:	68 5b 26 80 00       	push   $0x80265b
  800e34:	6a 7f                	push   $0x7f
  800e36:	68 50 26 80 00       	push   $0x802650
  800e3b:	e8 ec 0f 00 00       	call   801e2c <_panic>
	}
	int r;

	if (childpid == 0) {
  800e40:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800e44:	75 25                	jne    800e6b <fork+0x65>
		// child process
		// Remember to fix "thisenv" in the child process. ??? 
		thisenv = &envs[ENVX(sys_getenvid())];
  800e46:	e8 5e fd ff ff       	call   800ba9 <sys_getenvid>
  800e4b:	25 ff 03 00 00       	and    $0x3ff,%eax
  800e50:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800e57:	c1 e0 07             	shl    $0x7,%eax
  800e5a:	29 d0                	sub    %edx,%eax
  800e5c:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800e61:	a3 04 40 80 00       	mov    %eax,0x804004
		// cprintf("fork child ok\n");
		return 0;
  800e66:	e9 be 01 00 00       	jmp    801029 <fork+0x223>
	if (childpid < 0) {
		panic("fork sys_exofork error : %e\n", childpid);
	}
	int r;

	if (childpid == 0) {
  800e6b:	bb 00 00 00 00       	mov    $0x0,%ebx
	} else {
		// map page to new environment
		// kernel page is already in new environment
		uint32_t i;
		for (i = 0; i != UTOP; i += PGSIZE) 
		if ((uvpd[PDX(i)] & PTE_P) && (uvpt[i / PGSIZE] & PTE_P) && (uvpt[i / PGSIZE] & PTE_U)) {
  800e70:	89 d8                	mov    %ebx,%eax
  800e72:	c1 e8 16             	shr    $0x16,%eax
  800e75:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800e7c:	a8 01                	test   $0x1,%al
  800e7e:	0f 84 10 01 00 00    	je     800f94 <fork+0x18e>
  800e84:	89 d8                	mov    %ebx,%eax
  800e86:	c1 e8 0c             	shr    $0xc,%eax
  800e89:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800e90:	f6 c2 01             	test   $0x1,%dl
  800e93:	0f 84 fb 00 00 00    	je     800f94 <fork+0x18e>
  800e99:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800ea0:	f6 c2 04             	test   $0x4,%dl
  800ea3:	0f 84 eb 00 00 00    	je     800f94 <fork+0x18e>
//
static int
duppage(envid_t envid, unsigned pn)
{
	// do not dup exception stack
	if (pn * PGSIZE == UXSTACKTOP - PGSIZE) return 0;
  800ea9:	89 c6                	mov    %eax,%esi
  800eab:	c1 e6 0c             	shl    $0xc,%esi
  800eae:	81 fe 00 f0 bf ee    	cmp    $0xeebff000,%esi
  800eb4:	0f 84 da 00 00 00    	je     800f94 <fork+0x18e>

	int r;
	void * addr = (void *)(pn * PGSIZE);
    if (uvpt[pn] & PTE_SHARE) {
  800eba:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800ec1:	f6 c6 04             	test   $0x4,%dh
  800ec4:	74 37                	je     800efd <fork+0xf7>
        r = sys_page_map(0, addr, envid, addr, uvpt[pn] & PTE_SYSCALL);
  800ec6:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800ecd:	83 ec 0c             	sub    $0xc,%esp
  800ed0:	25 07 0e 00 00       	and    $0xe07,%eax
  800ed5:	50                   	push   %eax
  800ed6:	56                   	push   %esi
  800ed7:	57                   	push   %edi
  800ed8:	56                   	push   %esi
  800ed9:	6a 00                	push   $0x0
  800edb:	e8 38 fd ff ff       	call   800c18 <sys_page_map>
        if (r < 0) panic("duppage sys_page_map error : %e\n", r);
  800ee0:	83 c4 20             	add    $0x20,%esp
  800ee3:	85 c0                	test   %eax,%eax
  800ee5:	0f 89 a9 00 00 00    	jns    800f94 <fork+0x18e>
  800eeb:	50                   	push   %eax
  800eec:	68 9c 25 80 00       	push   $0x80259c
  800ef1:	6a 54                	push   $0x54
  800ef3:	68 50 26 80 00       	push   $0x802650
  800ef8:	e8 2f 0f 00 00       	call   801e2c <_panic>
    } else
	if ((uvpt[pn] & PTE_W) || (uvpt[pn] & PTE_COW)) {
  800efd:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800f04:	f6 c2 02             	test   $0x2,%dl
  800f07:	75 0c                	jne    800f15 <fork+0x10f>
  800f09:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f10:	f6 c4 08             	test   $0x8,%ah
  800f13:	74 57                	je     800f6c <fork+0x166>
		// cow
		r = sys_page_map(0, addr, envid, addr, PTE_COW | PTE_P | PTE_U);
  800f15:	83 ec 0c             	sub    $0xc,%esp
  800f18:	68 05 08 00 00       	push   $0x805
  800f1d:	56                   	push   %esi
  800f1e:	57                   	push   %edi
  800f1f:	56                   	push   %esi
  800f20:	6a 00                	push   $0x0
  800f22:	e8 f1 fc ff ff       	call   800c18 <sys_page_map>
		if (r < 0) panic("duppage sys_page_map error : %e\n", r);
  800f27:	83 c4 20             	add    $0x20,%esp
  800f2a:	85 c0                	test   %eax,%eax
  800f2c:	79 12                	jns    800f40 <fork+0x13a>
  800f2e:	50                   	push   %eax
  800f2f:	68 9c 25 80 00       	push   $0x80259c
  800f34:	6a 59                	push   $0x59
  800f36:	68 50 26 80 00       	push   $0x802650
  800f3b:	e8 ec 0e 00 00       	call   801e2c <_panic>
		
		r = sys_page_map(0, addr, 0, addr, PTE_COW | PTE_P | PTE_U);
  800f40:	83 ec 0c             	sub    $0xc,%esp
  800f43:	68 05 08 00 00       	push   $0x805
  800f48:	56                   	push   %esi
  800f49:	6a 00                	push   $0x0
  800f4b:	56                   	push   %esi
  800f4c:	6a 00                	push   $0x0
  800f4e:	e8 c5 fc ff ff       	call   800c18 <sys_page_map>
		if (r < 0) panic("duppage sys_page_map error : %e\n", r);
  800f53:	83 c4 20             	add    $0x20,%esp
  800f56:	85 c0                	test   %eax,%eax
  800f58:	79 3a                	jns    800f94 <fork+0x18e>
  800f5a:	50                   	push   %eax
  800f5b:	68 9c 25 80 00       	push   $0x80259c
  800f60:	6a 5c                	push   $0x5c
  800f62:	68 50 26 80 00       	push   $0x802650
  800f67:	e8 c0 0e 00 00       	call   801e2c <_panic>
	} else {
		// read only
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U);
  800f6c:	83 ec 0c             	sub    $0xc,%esp
  800f6f:	6a 05                	push   $0x5
  800f71:	56                   	push   %esi
  800f72:	57                   	push   %edi
  800f73:	56                   	push   %esi
  800f74:	6a 00                	push   $0x0
  800f76:	e8 9d fc ff ff       	call   800c18 <sys_page_map>
		if (r < 0) panic("duppage sys_page_map error : %e\n", r);
  800f7b:	83 c4 20             	add    $0x20,%esp
  800f7e:	85 c0                	test   %eax,%eax
  800f80:	79 12                	jns    800f94 <fork+0x18e>
  800f82:	50                   	push   %eax
  800f83:	68 9c 25 80 00       	push   $0x80259c
  800f88:	6a 60                	push   $0x60
  800f8a:	68 50 26 80 00       	push   $0x802650
  800f8f:	e8 98 0e 00 00       	call   801e2c <_panic>
		return 0;
	} else {
		// map page to new environment
		// kernel page is already in new environment
		uint32_t i;
		for (i = 0; i != UTOP; i += PGSIZE) 
  800f94:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  800f9a:	81 fb 00 00 c0 ee    	cmp    $0xeec00000,%ebx
  800fa0:	0f 85 ca fe ff ff    	jne    800e70 <fork+0x6a>
		if ((uvpd[PDX(i)] & PTE_P) && (uvpt[i / PGSIZE] & PTE_P) && (uvpt[i / PGSIZE] & PTE_U)) {
			duppage(childpid, i / PGSIZE);
		}

		// allocate exception stack
		r = sys_page_alloc(childpid, (void *)(UXSTACKTOP - PGSIZE), PTE_U | PTE_W | PTE_P);
  800fa6:	83 ec 04             	sub    $0x4,%esp
  800fa9:	6a 07                	push   $0x7
  800fab:	68 00 f0 bf ee       	push   $0xeebff000
  800fb0:	ff 75 e4             	pushl  -0x1c(%ebp)
  800fb3:	e8 3c fc ff ff       	call   800bf4 <sys_page_alloc>
		if (r < 0) panic("fork, sys_page_alloc user exception stack error : %e\n", r);
  800fb8:	83 c4 10             	add    $0x10,%esp
  800fbb:	85 c0                	test   %eax,%eax
  800fbd:	79 15                	jns    800fd4 <fork+0x1ce>
  800fbf:	50                   	push   %eax
  800fc0:	68 c0 25 80 00       	push   $0x8025c0
  800fc5:	68 94 00 00 00       	push   $0x94
  800fca:	68 50 26 80 00       	push   $0x802650
  800fcf:	e8 58 0e 00 00       	call   801e2c <_panic>

		// set user environment user page fault handler 
		extern void _pgfault_upcall(void);
		r = sys_env_set_pgfault_upcall(childpid, _pgfault_upcall);
  800fd4:	83 ec 08             	sub    $0x8,%esp
  800fd7:	68 e0 1e 80 00       	push   $0x801ee0
  800fdc:	ff 75 e4             	pushl  -0x1c(%ebp)
  800fdf:	e8 c3 fc ff ff       	call   800ca7 <sys_env_set_pgfault_upcall>
		if (r < 0) panic("fork, set pgfault upcall fail : %e\n", r);
  800fe4:	83 c4 10             	add    $0x10,%esp
  800fe7:	85 c0                	test   %eax,%eax
  800fe9:	79 15                	jns    801000 <fork+0x1fa>
  800feb:	50                   	push   %eax
  800fec:	68 f8 25 80 00       	push   $0x8025f8
  800ff1:	68 99 00 00 00       	push   $0x99
  800ff6:	68 50 26 80 00       	push   $0x802650
  800ffb:	e8 2c 0e 00 00       	call   801e2c <_panic>
		r = sys_set_priority(childpid, num);
		if (r < 0) panic("fork, set priority error\n");
		*/

		// mark the child as runnable and return
		r = sys_env_set_status(childpid, ENV_RUNNABLE);
  801000:	83 ec 08             	sub    $0x8,%esp
  801003:	6a 02                	push   $0x2
  801005:	ff 75 e4             	pushl  -0x1c(%ebp)
  801008:	e8 54 fc ff ff       	call   800c61 <sys_env_set_status>
		if (r < 0) panic("fork, set child process to ENV_RUNNABLE error : %e\n", r);
  80100d:	83 c4 10             	add    $0x10,%esp
  801010:	85 c0                	test   %eax,%eax
  801012:	79 15                	jns    801029 <fork+0x223>
  801014:	50                   	push   %eax
  801015:	68 1c 26 80 00       	push   $0x80261c
  80101a:	68 a4 00 00 00       	push   $0xa4
  80101f:	68 50 26 80 00       	push   $0x802650
  801024:	e8 03 0e 00 00       	call   801e2c <_panic>
		// cprintf("fork father ok!")
		return childpid;
	}

	panic("fork not implemented");
}
  801029:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80102c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80102f:	5b                   	pop    %ebx
  801030:	5e                   	pop    %esi
  801031:	5f                   	pop    %edi
  801032:	c9                   	leave  
  801033:	c3                   	ret    

00801034 <sfork>:

// Challenge!
int
sfork(void)
{
  801034:	55                   	push   %ebp
  801035:	89 e5                	mov    %esp,%ebp
  801037:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  80103a:	68 78 26 80 00       	push   $0x802678
  80103f:	68 b1 00 00 00       	push   $0xb1
  801044:	68 50 26 80 00       	push   $0x802650
  801049:	e8 de 0d 00 00       	call   801e2c <_panic>
	...

00801050 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801050:	55                   	push   %ebp
  801051:	89 e5                	mov    %esp,%ebp
  801053:	56                   	push   %esi
  801054:	53                   	push   %ebx
  801055:	8b 75 08             	mov    0x8(%ebp),%esi
  801058:	8b 45 0c             	mov    0xc(%ebp),%eax
  80105b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// cprintf("0x%x 0x%x 0x%x\n", (uint32_t)from_env_store, (uint32_t)pg, (uint32_t)perm_store);
	int r;
	if (pg != NULL) {
  80105e:	85 c0                	test   %eax,%eax
  801060:	74 0e                	je     801070 <ipc_recv+0x20>
		r = sys_ipc_recv(pg);
  801062:	83 ec 0c             	sub    $0xc,%esp
  801065:	50                   	push   %eax
  801066:	e8 84 fc ff ff       	call   800cef <sys_ipc_recv>
  80106b:	83 c4 10             	add    $0x10,%esp
  80106e:	eb 10                	jmp    801080 <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv((void *)UTOP);
  801070:	83 ec 0c             	sub    $0xc,%esp
  801073:	68 00 00 c0 ee       	push   $0xeec00000
  801078:	e8 72 fc ff ff       	call   800cef <sys_ipc_recv>
  80107d:	83 c4 10             	add    $0x10,%esp
	}

	if (r == 0) {
  801080:	85 c0                	test   %eax,%eax
  801082:	75 26                	jne    8010aa <ipc_recv+0x5a>
		if (from_env_store != NULL) *from_env_store = thisenv->env_ipc_from;
  801084:	85 f6                	test   %esi,%esi
  801086:	74 0a                	je     801092 <ipc_recv+0x42>
  801088:	a1 04 40 80 00       	mov    0x804004,%eax
  80108d:	8b 40 74             	mov    0x74(%eax),%eax
  801090:	89 06                	mov    %eax,(%esi)
		if (perm_store != NULL) *perm_store = thisenv->env_ipc_perm;
  801092:	85 db                	test   %ebx,%ebx
  801094:	74 0a                	je     8010a0 <ipc_recv+0x50>
  801096:	a1 04 40 80 00       	mov    0x804004,%eax
  80109b:	8b 40 78             	mov    0x78(%eax),%eax
  80109e:	89 03                	mov    %eax,(%ebx)
		return thisenv->env_ipc_value;
  8010a0:	a1 04 40 80 00       	mov    0x804004,%eax
  8010a5:	8b 40 70             	mov    0x70(%eax),%eax
  8010a8:	eb 14                	jmp    8010be <ipc_recv+0x6e>
	} else {
		// fails;
		if (from_env_store != NULL) *from_env_store = 0;
  8010aa:	85 f6                	test   %esi,%esi
  8010ac:	74 06                	je     8010b4 <ipc_recv+0x64>
  8010ae:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if (perm_store != NULL) *perm_store = 0;
  8010b4:	85 db                	test   %ebx,%ebx
  8010b6:	74 06                	je     8010be <ipc_recv+0x6e>
  8010b8:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		return r;
	}
}
  8010be:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8010c1:	5b                   	pop    %ebx
  8010c2:	5e                   	pop    %esi
  8010c3:	c9                   	leave  
  8010c4:	c3                   	ret    

008010c5 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8010c5:	55                   	push   %ebp
  8010c6:	89 e5                	mov    %esp,%ebp
  8010c8:	57                   	push   %edi
  8010c9:	56                   	push   %esi
  8010ca:	53                   	push   %ebx
  8010cb:	83 ec 0c             	sub    $0xc,%esp
  8010ce:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8010d1:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8010d4:	8b 75 14             	mov    0x14(%ebp),%esi
	// LAB 4: Your code here.
	// int sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
	int r;
	if (pg == NULL) pg = (void *)UTOP;
  8010d7:	85 db                	test   %ebx,%ebx
  8010d9:	75 25                	jne    801100 <ipc_send+0x3b>
  8010db:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
  8010e0:	eb 1e                	jmp    801100 <ipc_send+0x3b>
	
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) != 0) {
		if (r == -E_IPC_NOT_RECV) {
  8010e2:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8010e5:	75 07                	jne    8010ee <ipc_send+0x29>
			// cprintf("Try Again and Again....\n");
			sys_yield();
  8010e7:	e8 e1 fa ff ff       	call   800bcd <sys_yield>
  8010ec:	eb 12                	jmp    801100 <ipc_send+0x3b>
		} else {
			panic("ipc_send error %e\n", r);
  8010ee:	50                   	push   %eax
  8010ef:	68 8e 26 80 00       	push   $0x80268e
  8010f4:	6a 43                	push   $0x43
  8010f6:	68 a1 26 80 00       	push   $0x8026a1
  8010fb:	e8 2c 0d 00 00       	call   801e2c <_panic>
	// LAB 4: Your code here.
	// int sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
	int r;
	if (pg == NULL) pg = (void *)UTOP;
	
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) != 0) {
  801100:	56                   	push   %esi
  801101:	53                   	push   %ebx
  801102:	57                   	push   %edi
  801103:	ff 75 08             	pushl  0x8(%ebp)
  801106:	e8 bf fb ff ff       	call   800cca <sys_ipc_try_send>
  80110b:	83 c4 10             	add    $0x10,%esp
  80110e:	85 c0                	test   %eax,%eax
  801110:	75 d0                	jne    8010e2 <ipc_send+0x1d>
		} else {
			panic("ipc_send error %e\n", r);
		}
	}
	return;
}
  801112:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801115:	5b                   	pop    %ebx
  801116:	5e                   	pop    %esi
  801117:	5f                   	pop    %edi
  801118:	c9                   	leave  
  801119:	c3                   	ret    

0080111a <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80111a:	55                   	push   %ebp
  80111b:	89 e5                	mov    %esp,%ebp
  80111d:	53                   	push   %ebx
  80111e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  801121:	39 1d 50 00 c0 ee    	cmp    %ebx,0xeec00050
  801127:	74 22                	je     80114b <ipc_find_env+0x31>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801129:	b8 01 00 00 00       	mov    $0x1,%eax
		if (envs[i].env_type == type)
  80112e:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  801135:	89 c2                	mov    %eax,%edx
  801137:	c1 e2 07             	shl    $0x7,%edx
  80113a:	29 ca                	sub    %ecx,%edx
  80113c:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801142:	8b 52 50             	mov    0x50(%edx),%edx
  801145:	39 da                	cmp    %ebx,%edx
  801147:	75 1d                	jne    801166 <ipc_find_env+0x4c>
  801149:	eb 05                	jmp    801150 <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80114b:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
			return envs[i].env_id;
  801150:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  801157:	c1 e0 07             	shl    $0x7,%eax
  80115a:	29 d0                	sub    %edx,%eax
  80115c:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  801161:	8b 40 40             	mov    0x40(%eax),%eax
  801164:	eb 0c                	jmp    801172 <ipc_find_env+0x58>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801166:	40                   	inc    %eax
  801167:	3d 00 04 00 00       	cmp    $0x400,%eax
  80116c:	75 c0                	jne    80112e <ipc_find_env+0x14>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  80116e:	66 b8 00 00          	mov    $0x0,%ax
}
  801172:	5b                   	pop    %ebx
  801173:	c9                   	leave  
  801174:	c3                   	ret    
  801175:	00 00                	add    %al,(%eax)
	...

00801178 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801178:	55                   	push   %ebp
  801179:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80117b:	8b 45 08             	mov    0x8(%ebp),%eax
  80117e:	05 00 00 00 30       	add    $0x30000000,%eax
  801183:	c1 e8 0c             	shr    $0xc,%eax
}
  801186:	c9                   	leave  
  801187:	c3                   	ret    

00801188 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801188:	55                   	push   %ebp
  801189:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  80118b:	ff 75 08             	pushl  0x8(%ebp)
  80118e:	e8 e5 ff ff ff       	call   801178 <fd2num>
  801193:	83 c4 04             	add    $0x4,%esp
  801196:	05 20 00 0d 00       	add    $0xd0020,%eax
  80119b:	c1 e0 0c             	shl    $0xc,%eax
}
  80119e:	c9                   	leave  
  80119f:	c3                   	ret    

008011a0 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8011a0:	55                   	push   %ebp
  8011a1:	89 e5                	mov    %esp,%ebp
  8011a3:	53                   	push   %ebx
  8011a4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8011a7:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  8011ac:	a8 01                	test   $0x1,%al
  8011ae:	74 34                	je     8011e4 <fd_alloc+0x44>
  8011b0:	a1 00 00 74 ef       	mov    0xef740000,%eax
  8011b5:	a8 01                	test   $0x1,%al
  8011b7:	74 32                	je     8011eb <fd_alloc+0x4b>
  8011b9:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
  8011be:	89 c1                	mov    %eax,%ecx
  8011c0:	89 c2                	mov    %eax,%edx
  8011c2:	c1 ea 16             	shr    $0x16,%edx
  8011c5:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8011cc:	f6 c2 01             	test   $0x1,%dl
  8011cf:	74 1f                	je     8011f0 <fd_alloc+0x50>
  8011d1:	89 c2                	mov    %eax,%edx
  8011d3:	c1 ea 0c             	shr    $0xc,%edx
  8011d6:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8011dd:	f6 c2 01             	test   $0x1,%dl
  8011e0:	75 17                	jne    8011f9 <fd_alloc+0x59>
  8011e2:	eb 0c                	jmp    8011f0 <fd_alloc+0x50>
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  8011e4:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
  8011e9:	eb 05                	jmp    8011f0 <fd_alloc+0x50>
  8011eb:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
  8011f0:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  8011f2:	b8 00 00 00 00       	mov    $0x0,%eax
  8011f7:	eb 17                	jmp    801210 <fd_alloc+0x70>
  8011f9:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8011fe:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801203:	75 b9                	jne    8011be <fd_alloc+0x1e>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801205:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  80120b:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801210:	5b                   	pop    %ebx
  801211:	c9                   	leave  
  801212:	c3                   	ret    

00801213 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801213:	55                   	push   %ebp
  801214:	89 e5                	mov    %esp,%ebp
  801216:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801219:	83 f8 1f             	cmp    $0x1f,%eax
  80121c:	77 36                	ja     801254 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80121e:	05 00 00 0d 00       	add    $0xd0000,%eax
  801223:	c1 e0 0c             	shl    $0xc,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801226:	89 c2                	mov    %eax,%edx
  801228:	c1 ea 16             	shr    $0x16,%edx
  80122b:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801232:	f6 c2 01             	test   $0x1,%dl
  801235:	74 24                	je     80125b <fd_lookup+0x48>
  801237:	89 c2                	mov    %eax,%edx
  801239:	c1 ea 0c             	shr    $0xc,%edx
  80123c:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801243:	f6 c2 01             	test   $0x1,%dl
  801246:	74 1a                	je     801262 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801248:	8b 55 0c             	mov    0xc(%ebp),%edx
  80124b:	89 02                	mov    %eax,(%edx)
	return 0;
  80124d:	b8 00 00 00 00       	mov    $0x0,%eax
  801252:	eb 13                	jmp    801267 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801254:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801259:	eb 0c                	jmp    801267 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80125b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801260:	eb 05                	jmp    801267 <fd_lookup+0x54>
  801262:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801267:	c9                   	leave  
  801268:	c3                   	ret    

00801269 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801269:	55                   	push   %ebp
  80126a:	89 e5                	mov    %esp,%ebp
  80126c:	53                   	push   %ebx
  80126d:	83 ec 04             	sub    $0x4,%esp
  801270:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801273:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  801276:	39 0d 04 30 80 00    	cmp    %ecx,0x803004
  80127c:	74 0d                	je     80128b <dev_lookup+0x22>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80127e:	b8 00 00 00 00       	mov    $0x0,%eax
  801283:	eb 14                	jmp    801299 <dev_lookup+0x30>
		if (devtab[i]->dev_id == dev_id) {
  801285:	39 0a                	cmp    %ecx,(%edx)
  801287:	75 10                	jne    801299 <dev_lookup+0x30>
  801289:	eb 05                	jmp    801290 <dev_lookup+0x27>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80128b:	ba 04 30 80 00       	mov    $0x803004,%edx
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
  801290:	89 13                	mov    %edx,(%ebx)
			return 0;
  801292:	b8 00 00 00 00       	mov    $0x0,%eax
  801297:	eb 31                	jmp    8012ca <dev_lookup+0x61>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801299:	40                   	inc    %eax
  80129a:	8b 14 85 28 27 80 00 	mov    0x802728(,%eax,4),%edx
  8012a1:	85 d2                	test   %edx,%edx
  8012a3:	75 e0                	jne    801285 <dev_lookup+0x1c>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8012a5:	a1 04 40 80 00       	mov    0x804004,%eax
  8012aa:	8b 40 48             	mov    0x48(%eax),%eax
  8012ad:	83 ec 04             	sub    $0x4,%esp
  8012b0:	51                   	push   %ecx
  8012b1:	50                   	push   %eax
  8012b2:	68 ac 26 80 00       	push   $0x8026ac
  8012b7:	e8 00 ef ff ff       	call   8001bc <cprintf>
	*dev = 0;
  8012bc:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  8012c2:	83 c4 10             	add    $0x10,%esp
  8012c5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8012ca:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012cd:	c9                   	leave  
  8012ce:	c3                   	ret    

008012cf <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8012cf:	55                   	push   %ebp
  8012d0:	89 e5                	mov    %esp,%ebp
  8012d2:	56                   	push   %esi
  8012d3:	53                   	push   %ebx
  8012d4:	83 ec 20             	sub    $0x20,%esp
  8012d7:	8b 75 08             	mov    0x8(%ebp),%esi
  8012da:	8a 45 0c             	mov    0xc(%ebp),%al
  8012dd:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8012e0:	56                   	push   %esi
  8012e1:	e8 92 fe ff ff       	call   801178 <fd2num>
  8012e6:	8d 55 f4             	lea    -0xc(%ebp),%edx
  8012e9:	89 14 24             	mov    %edx,(%esp)
  8012ec:	50                   	push   %eax
  8012ed:	e8 21 ff ff ff       	call   801213 <fd_lookup>
  8012f2:	89 c3                	mov    %eax,%ebx
  8012f4:	83 c4 08             	add    $0x8,%esp
  8012f7:	85 c0                	test   %eax,%eax
  8012f9:	78 05                	js     801300 <fd_close+0x31>
	    || fd != fd2)
  8012fb:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8012fe:	74 0d                	je     80130d <fd_close+0x3e>
		return (must_exist ? r : 0);
  801300:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  801304:	75 48                	jne    80134e <fd_close+0x7f>
  801306:	bb 00 00 00 00       	mov    $0x0,%ebx
  80130b:	eb 41                	jmp    80134e <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80130d:	83 ec 08             	sub    $0x8,%esp
  801310:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801313:	50                   	push   %eax
  801314:	ff 36                	pushl  (%esi)
  801316:	e8 4e ff ff ff       	call   801269 <dev_lookup>
  80131b:	89 c3                	mov    %eax,%ebx
  80131d:	83 c4 10             	add    $0x10,%esp
  801320:	85 c0                	test   %eax,%eax
  801322:	78 1c                	js     801340 <fd_close+0x71>
		if (dev->dev_close)
  801324:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801327:	8b 40 10             	mov    0x10(%eax),%eax
  80132a:	85 c0                	test   %eax,%eax
  80132c:	74 0d                	je     80133b <fd_close+0x6c>
			r = (*dev->dev_close)(fd);
  80132e:	83 ec 0c             	sub    $0xc,%esp
  801331:	56                   	push   %esi
  801332:	ff d0                	call   *%eax
  801334:	89 c3                	mov    %eax,%ebx
  801336:	83 c4 10             	add    $0x10,%esp
  801339:	eb 05                	jmp    801340 <fd_close+0x71>
		else
			r = 0;
  80133b:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801340:	83 ec 08             	sub    $0x8,%esp
  801343:	56                   	push   %esi
  801344:	6a 00                	push   $0x0
  801346:	e8 f3 f8 ff ff       	call   800c3e <sys_page_unmap>
	return r;
  80134b:	83 c4 10             	add    $0x10,%esp
}
  80134e:	89 d8                	mov    %ebx,%eax
  801350:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801353:	5b                   	pop    %ebx
  801354:	5e                   	pop    %esi
  801355:	c9                   	leave  
  801356:	c3                   	ret    

00801357 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801357:	55                   	push   %ebp
  801358:	89 e5                	mov    %esp,%ebp
  80135a:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80135d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801360:	50                   	push   %eax
  801361:	ff 75 08             	pushl  0x8(%ebp)
  801364:	e8 aa fe ff ff       	call   801213 <fd_lookup>
  801369:	83 c4 08             	add    $0x8,%esp
  80136c:	85 c0                	test   %eax,%eax
  80136e:	78 10                	js     801380 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801370:	83 ec 08             	sub    $0x8,%esp
  801373:	6a 01                	push   $0x1
  801375:	ff 75 f4             	pushl  -0xc(%ebp)
  801378:	e8 52 ff ff ff       	call   8012cf <fd_close>
  80137d:	83 c4 10             	add    $0x10,%esp
}
  801380:	c9                   	leave  
  801381:	c3                   	ret    

00801382 <close_all>:

void
close_all(void)
{
  801382:	55                   	push   %ebp
  801383:	89 e5                	mov    %esp,%ebp
  801385:	53                   	push   %ebx
  801386:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801389:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80138e:	83 ec 0c             	sub    $0xc,%esp
  801391:	53                   	push   %ebx
  801392:	e8 c0 ff ff ff       	call   801357 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801397:	43                   	inc    %ebx
  801398:	83 c4 10             	add    $0x10,%esp
  80139b:	83 fb 20             	cmp    $0x20,%ebx
  80139e:	75 ee                	jne    80138e <close_all+0xc>
		close(i);
}
  8013a0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013a3:	c9                   	leave  
  8013a4:	c3                   	ret    

008013a5 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8013a5:	55                   	push   %ebp
  8013a6:	89 e5                	mov    %esp,%ebp
  8013a8:	57                   	push   %edi
  8013a9:	56                   	push   %esi
  8013aa:	53                   	push   %ebx
  8013ab:	83 ec 2c             	sub    $0x2c,%esp
  8013ae:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8013b1:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8013b4:	50                   	push   %eax
  8013b5:	ff 75 08             	pushl  0x8(%ebp)
  8013b8:	e8 56 fe ff ff       	call   801213 <fd_lookup>
  8013bd:	89 c3                	mov    %eax,%ebx
  8013bf:	83 c4 08             	add    $0x8,%esp
  8013c2:	85 c0                	test   %eax,%eax
  8013c4:	0f 88 c0 00 00 00    	js     80148a <dup+0xe5>
		return r;
	close(newfdnum);
  8013ca:	83 ec 0c             	sub    $0xc,%esp
  8013cd:	57                   	push   %edi
  8013ce:	e8 84 ff ff ff       	call   801357 <close>

	newfd = INDEX2FD(newfdnum);
  8013d3:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  8013d9:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  8013dc:	83 c4 04             	add    $0x4,%esp
  8013df:	ff 75 e4             	pushl  -0x1c(%ebp)
  8013e2:	e8 a1 fd ff ff       	call   801188 <fd2data>
  8013e7:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  8013e9:	89 34 24             	mov    %esi,(%esp)
  8013ec:	e8 97 fd ff ff       	call   801188 <fd2data>
  8013f1:	83 c4 10             	add    $0x10,%esp
  8013f4:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8013f7:	89 d8                	mov    %ebx,%eax
  8013f9:	c1 e8 16             	shr    $0x16,%eax
  8013fc:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801403:	a8 01                	test   $0x1,%al
  801405:	74 37                	je     80143e <dup+0x99>
  801407:	89 d8                	mov    %ebx,%eax
  801409:	c1 e8 0c             	shr    $0xc,%eax
  80140c:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801413:	f6 c2 01             	test   $0x1,%dl
  801416:	74 26                	je     80143e <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801418:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80141f:	83 ec 0c             	sub    $0xc,%esp
  801422:	25 07 0e 00 00       	and    $0xe07,%eax
  801427:	50                   	push   %eax
  801428:	ff 75 d4             	pushl  -0x2c(%ebp)
  80142b:	6a 00                	push   $0x0
  80142d:	53                   	push   %ebx
  80142e:	6a 00                	push   $0x0
  801430:	e8 e3 f7 ff ff       	call   800c18 <sys_page_map>
  801435:	89 c3                	mov    %eax,%ebx
  801437:	83 c4 20             	add    $0x20,%esp
  80143a:	85 c0                	test   %eax,%eax
  80143c:	78 2d                	js     80146b <dup+0xc6>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80143e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801441:	89 c2                	mov    %eax,%edx
  801443:	c1 ea 0c             	shr    $0xc,%edx
  801446:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80144d:	83 ec 0c             	sub    $0xc,%esp
  801450:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  801456:	52                   	push   %edx
  801457:	56                   	push   %esi
  801458:	6a 00                	push   $0x0
  80145a:	50                   	push   %eax
  80145b:	6a 00                	push   $0x0
  80145d:	e8 b6 f7 ff ff       	call   800c18 <sys_page_map>
  801462:	89 c3                	mov    %eax,%ebx
  801464:	83 c4 20             	add    $0x20,%esp
  801467:	85 c0                	test   %eax,%eax
  801469:	79 1d                	jns    801488 <dup+0xe3>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80146b:	83 ec 08             	sub    $0x8,%esp
  80146e:	56                   	push   %esi
  80146f:	6a 00                	push   $0x0
  801471:	e8 c8 f7 ff ff       	call   800c3e <sys_page_unmap>
	sys_page_unmap(0, nva);
  801476:	83 c4 08             	add    $0x8,%esp
  801479:	ff 75 d4             	pushl  -0x2c(%ebp)
  80147c:	6a 00                	push   $0x0
  80147e:	e8 bb f7 ff ff       	call   800c3e <sys_page_unmap>
	return r;
  801483:	83 c4 10             	add    $0x10,%esp
  801486:	eb 02                	jmp    80148a <dup+0xe5>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  801488:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  80148a:	89 d8                	mov    %ebx,%eax
  80148c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80148f:	5b                   	pop    %ebx
  801490:	5e                   	pop    %esi
  801491:	5f                   	pop    %edi
  801492:	c9                   	leave  
  801493:	c3                   	ret    

00801494 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801494:	55                   	push   %ebp
  801495:	89 e5                	mov    %esp,%ebp
  801497:	53                   	push   %ebx
  801498:	83 ec 14             	sub    $0x14,%esp
  80149b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80149e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014a1:	50                   	push   %eax
  8014a2:	53                   	push   %ebx
  8014a3:	e8 6b fd ff ff       	call   801213 <fd_lookup>
  8014a8:	83 c4 08             	add    $0x8,%esp
  8014ab:	85 c0                	test   %eax,%eax
  8014ad:	78 67                	js     801516 <read+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014af:	83 ec 08             	sub    $0x8,%esp
  8014b2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014b5:	50                   	push   %eax
  8014b6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014b9:	ff 30                	pushl  (%eax)
  8014bb:	e8 a9 fd ff ff       	call   801269 <dev_lookup>
  8014c0:	83 c4 10             	add    $0x10,%esp
  8014c3:	85 c0                	test   %eax,%eax
  8014c5:	78 4f                	js     801516 <read+0x82>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8014c7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014ca:	8b 50 08             	mov    0x8(%eax),%edx
  8014cd:	83 e2 03             	and    $0x3,%edx
  8014d0:	83 fa 01             	cmp    $0x1,%edx
  8014d3:	75 21                	jne    8014f6 <read+0x62>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8014d5:	a1 04 40 80 00       	mov    0x804004,%eax
  8014da:	8b 40 48             	mov    0x48(%eax),%eax
  8014dd:	83 ec 04             	sub    $0x4,%esp
  8014e0:	53                   	push   %ebx
  8014e1:	50                   	push   %eax
  8014e2:	68 ed 26 80 00       	push   $0x8026ed
  8014e7:	e8 d0 ec ff ff       	call   8001bc <cprintf>
		return -E_INVAL;
  8014ec:	83 c4 10             	add    $0x10,%esp
  8014ef:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8014f4:	eb 20                	jmp    801516 <read+0x82>
	}
	if (!dev->dev_read)
  8014f6:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8014f9:	8b 52 08             	mov    0x8(%edx),%edx
  8014fc:	85 d2                	test   %edx,%edx
  8014fe:	74 11                	je     801511 <read+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801500:	83 ec 04             	sub    $0x4,%esp
  801503:	ff 75 10             	pushl  0x10(%ebp)
  801506:	ff 75 0c             	pushl  0xc(%ebp)
  801509:	50                   	push   %eax
  80150a:	ff d2                	call   *%edx
  80150c:	83 c4 10             	add    $0x10,%esp
  80150f:	eb 05                	jmp    801516 <read+0x82>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801511:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  801516:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801519:	c9                   	leave  
  80151a:	c3                   	ret    

0080151b <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80151b:	55                   	push   %ebp
  80151c:	89 e5                	mov    %esp,%ebp
  80151e:	57                   	push   %edi
  80151f:	56                   	push   %esi
  801520:	53                   	push   %ebx
  801521:	83 ec 0c             	sub    $0xc,%esp
  801524:	8b 7d 08             	mov    0x8(%ebp),%edi
  801527:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80152a:	85 f6                	test   %esi,%esi
  80152c:	74 31                	je     80155f <readn+0x44>
  80152e:	b8 00 00 00 00       	mov    $0x0,%eax
  801533:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = read(fdnum, (char*)buf + tot, n - tot);
  801538:	83 ec 04             	sub    $0x4,%esp
  80153b:	89 f2                	mov    %esi,%edx
  80153d:	29 c2                	sub    %eax,%edx
  80153f:	52                   	push   %edx
  801540:	03 45 0c             	add    0xc(%ebp),%eax
  801543:	50                   	push   %eax
  801544:	57                   	push   %edi
  801545:	e8 4a ff ff ff       	call   801494 <read>
		if (m < 0)
  80154a:	83 c4 10             	add    $0x10,%esp
  80154d:	85 c0                	test   %eax,%eax
  80154f:	78 17                	js     801568 <readn+0x4d>
			return m;
		if (m == 0)
  801551:	85 c0                	test   %eax,%eax
  801553:	74 11                	je     801566 <readn+0x4b>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801555:	01 c3                	add    %eax,%ebx
  801557:	89 d8                	mov    %ebx,%eax
  801559:	39 f3                	cmp    %esi,%ebx
  80155b:	72 db                	jb     801538 <readn+0x1d>
  80155d:	eb 09                	jmp    801568 <readn+0x4d>
  80155f:	b8 00 00 00 00       	mov    $0x0,%eax
  801564:	eb 02                	jmp    801568 <readn+0x4d>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  801566:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  801568:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80156b:	5b                   	pop    %ebx
  80156c:	5e                   	pop    %esi
  80156d:	5f                   	pop    %edi
  80156e:	c9                   	leave  
  80156f:	c3                   	ret    

00801570 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801570:	55                   	push   %ebp
  801571:	89 e5                	mov    %esp,%ebp
  801573:	53                   	push   %ebx
  801574:	83 ec 14             	sub    $0x14,%esp
  801577:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80157a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80157d:	50                   	push   %eax
  80157e:	53                   	push   %ebx
  80157f:	e8 8f fc ff ff       	call   801213 <fd_lookup>
  801584:	83 c4 08             	add    $0x8,%esp
  801587:	85 c0                	test   %eax,%eax
  801589:	78 62                	js     8015ed <write+0x7d>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80158b:	83 ec 08             	sub    $0x8,%esp
  80158e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801591:	50                   	push   %eax
  801592:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801595:	ff 30                	pushl  (%eax)
  801597:	e8 cd fc ff ff       	call   801269 <dev_lookup>
  80159c:	83 c4 10             	add    $0x10,%esp
  80159f:	85 c0                	test   %eax,%eax
  8015a1:	78 4a                	js     8015ed <write+0x7d>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8015a3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015a6:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8015aa:	75 21                	jne    8015cd <write+0x5d>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8015ac:	a1 04 40 80 00       	mov    0x804004,%eax
  8015b1:	8b 40 48             	mov    0x48(%eax),%eax
  8015b4:	83 ec 04             	sub    $0x4,%esp
  8015b7:	53                   	push   %ebx
  8015b8:	50                   	push   %eax
  8015b9:	68 09 27 80 00       	push   $0x802709
  8015be:	e8 f9 eb ff ff       	call   8001bc <cprintf>
		return -E_INVAL;
  8015c3:	83 c4 10             	add    $0x10,%esp
  8015c6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8015cb:	eb 20                	jmp    8015ed <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8015cd:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8015d0:	8b 52 0c             	mov    0xc(%edx),%edx
  8015d3:	85 d2                	test   %edx,%edx
  8015d5:	74 11                	je     8015e8 <write+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8015d7:	83 ec 04             	sub    $0x4,%esp
  8015da:	ff 75 10             	pushl  0x10(%ebp)
  8015dd:	ff 75 0c             	pushl  0xc(%ebp)
  8015e0:	50                   	push   %eax
  8015e1:	ff d2                	call   *%edx
  8015e3:	83 c4 10             	add    $0x10,%esp
  8015e6:	eb 05                	jmp    8015ed <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8015e8:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  8015ed:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015f0:	c9                   	leave  
  8015f1:	c3                   	ret    

008015f2 <seek>:

int
seek(int fdnum, off_t offset)
{
  8015f2:	55                   	push   %ebp
  8015f3:	89 e5                	mov    %esp,%ebp
  8015f5:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8015f8:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8015fb:	50                   	push   %eax
  8015fc:	ff 75 08             	pushl  0x8(%ebp)
  8015ff:	e8 0f fc ff ff       	call   801213 <fd_lookup>
  801604:	83 c4 08             	add    $0x8,%esp
  801607:	85 c0                	test   %eax,%eax
  801609:	78 0e                	js     801619 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  80160b:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80160e:	8b 55 0c             	mov    0xc(%ebp),%edx
  801611:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801614:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801619:	c9                   	leave  
  80161a:	c3                   	ret    

0080161b <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80161b:	55                   	push   %ebp
  80161c:	89 e5                	mov    %esp,%ebp
  80161e:	53                   	push   %ebx
  80161f:	83 ec 14             	sub    $0x14,%esp
  801622:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801625:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801628:	50                   	push   %eax
  801629:	53                   	push   %ebx
  80162a:	e8 e4 fb ff ff       	call   801213 <fd_lookup>
  80162f:	83 c4 08             	add    $0x8,%esp
  801632:	85 c0                	test   %eax,%eax
  801634:	78 5f                	js     801695 <ftruncate+0x7a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801636:	83 ec 08             	sub    $0x8,%esp
  801639:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80163c:	50                   	push   %eax
  80163d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801640:	ff 30                	pushl  (%eax)
  801642:	e8 22 fc ff ff       	call   801269 <dev_lookup>
  801647:	83 c4 10             	add    $0x10,%esp
  80164a:	85 c0                	test   %eax,%eax
  80164c:	78 47                	js     801695 <ftruncate+0x7a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80164e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801651:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801655:	75 21                	jne    801678 <ftruncate+0x5d>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801657:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80165c:	8b 40 48             	mov    0x48(%eax),%eax
  80165f:	83 ec 04             	sub    $0x4,%esp
  801662:	53                   	push   %ebx
  801663:	50                   	push   %eax
  801664:	68 cc 26 80 00       	push   $0x8026cc
  801669:	e8 4e eb ff ff       	call   8001bc <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80166e:	83 c4 10             	add    $0x10,%esp
  801671:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801676:	eb 1d                	jmp    801695 <ftruncate+0x7a>
	}
	if (!dev->dev_trunc)
  801678:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80167b:	8b 52 18             	mov    0x18(%edx),%edx
  80167e:	85 d2                	test   %edx,%edx
  801680:	74 0e                	je     801690 <ftruncate+0x75>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801682:	83 ec 08             	sub    $0x8,%esp
  801685:	ff 75 0c             	pushl  0xc(%ebp)
  801688:	50                   	push   %eax
  801689:	ff d2                	call   *%edx
  80168b:	83 c4 10             	add    $0x10,%esp
  80168e:	eb 05                	jmp    801695 <ftruncate+0x7a>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801690:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  801695:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801698:	c9                   	leave  
  801699:	c3                   	ret    

0080169a <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80169a:	55                   	push   %ebp
  80169b:	89 e5                	mov    %esp,%ebp
  80169d:	53                   	push   %ebx
  80169e:	83 ec 14             	sub    $0x14,%esp
  8016a1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016a4:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016a7:	50                   	push   %eax
  8016a8:	ff 75 08             	pushl  0x8(%ebp)
  8016ab:	e8 63 fb ff ff       	call   801213 <fd_lookup>
  8016b0:	83 c4 08             	add    $0x8,%esp
  8016b3:	85 c0                	test   %eax,%eax
  8016b5:	78 52                	js     801709 <fstat+0x6f>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016b7:	83 ec 08             	sub    $0x8,%esp
  8016ba:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016bd:	50                   	push   %eax
  8016be:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016c1:	ff 30                	pushl  (%eax)
  8016c3:	e8 a1 fb ff ff       	call   801269 <dev_lookup>
  8016c8:	83 c4 10             	add    $0x10,%esp
  8016cb:	85 c0                	test   %eax,%eax
  8016cd:	78 3a                	js     801709 <fstat+0x6f>
		return r;
	if (!dev->dev_stat)
  8016cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016d2:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8016d6:	74 2c                	je     801704 <fstat+0x6a>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8016d8:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8016db:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8016e2:	00 00 00 
	stat->st_isdir = 0;
  8016e5:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8016ec:	00 00 00 
	stat->st_dev = dev;
  8016ef:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8016f5:	83 ec 08             	sub    $0x8,%esp
  8016f8:	53                   	push   %ebx
  8016f9:	ff 75 f0             	pushl  -0x10(%ebp)
  8016fc:	ff 50 14             	call   *0x14(%eax)
  8016ff:	83 c4 10             	add    $0x10,%esp
  801702:	eb 05                	jmp    801709 <fstat+0x6f>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801704:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801709:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80170c:	c9                   	leave  
  80170d:	c3                   	ret    

0080170e <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80170e:	55                   	push   %ebp
  80170f:	89 e5                	mov    %esp,%ebp
  801711:	56                   	push   %esi
  801712:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801713:	83 ec 08             	sub    $0x8,%esp
  801716:	6a 00                	push   $0x0
  801718:	ff 75 08             	pushl  0x8(%ebp)
  80171b:	e8 78 01 00 00       	call   801898 <open>
  801720:	89 c3                	mov    %eax,%ebx
  801722:	83 c4 10             	add    $0x10,%esp
  801725:	85 c0                	test   %eax,%eax
  801727:	78 1b                	js     801744 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801729:	83 ec 08             	sub    $0x8,%esp
  80172c:	ff 75 0c             	pushl  0xc(%ebp)
  80172f:	50                   	push   %eax
  801730:	e8 65 ff ff ff       	call   80169a <fstat>
  801735:	89 c6                	mov    %eax,%esi
	close(fd);
  801737:	89 1c 24             	mov    %ebx,(%esp)
  80173a:	e8 18 fc ff ff       	call   801357 <close>
	return r;
  80173f:	83 c4 10             	add    $0x10,%esp
  801742:	89 f3                	mov    %esi,%ebx
}
  801744:	89 d8                	mov    %ebx,%eax
  801746:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801749:	5b                   	pop    %ebx
  80174a:	5e                   	pop    %esi
  80174b:	c9                   	leave  
  80174c:	c3                   	ret    
  80174d:	00 00                	add    %al,(%eax)
	...

00801750 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801750:	55                   	push   %ebp
  801751:	89 e5                	mov    %esp,%ebp
  801753:	56                   	push   %esi
  801754:	53                   	push   %ebx
  801755:	89 c3                	mov    %eax,%ebx
  801757:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  801759:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801760:	75 12                	jne    801774 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801762:	83 ec 0c             	sub    $0xc,%esp
  801765:	6a 01                	push   $0x1
  801767:	e8 ae f9 ff ff       	call   80111a <ipc_find_env>
  80176c:	a3 00 40 80 00       	mov    %eax,0x804000
  801771:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801774:	6a 07                	push   $0x7
  801776:	68 00 50 80 00       	push   $0x805000
  80177b:	53                   	push   %ebx
  80177c:	ff 35 00 40 80 00    	pushl  0x804000
  801782:	e8 3e f9 ff ff       	call   8010c5 <ipc_send>
	
	return ipc_recv(NULL, dstva, NULL);
  801787:	83 c4 0c             	add    $0xc,%esp
  80178a:	6a 00                	push   $0x0
  80178c:	56                   	push   %esi
  80178d:	6a 00                	push   $0x0
  80178f:	e8 bc f8 ff ff       	call   801050 <ipc_recv>
}
  801794:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801797:	5b                   	pop    %ebx
  801798:	5e                   	pop    %esi
  801799:	c9                   	leave  
  80179a:	c3                   	ret    

0080179b <devfile_stat>:
}


static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80179b:	55                   	push   %ebp
  80179c:	89 e5                	mov    %esp,%ebp
  80179e:	53                   	push   %ebx
  80179f:	83 ec 04             	sub    $0x4,%esp
  8017a2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8017a5:	8b 45 08             	mov    0x8(%ebp),%eax
  8017a8:	8b 40 0c             	mov    0xc(%eax),%eax
  8017ab:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0) {
  8017b0:	ba 00 00 00 00       	mov    $0x0,%edx
  8017b5:	b8 05 00 00 00       	mov    $0x5,%eax
  8017ba:	e8 91 ff ff ff       	call   801750 <fsipc>
  8017bf:	85 c0                	test   %eax,%eax
  8017c1:	78 2c                	js     8017ef <devfile_stat+0x54>
		return r;
	}
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8017c3:	83 ec 08             	sub    $0x8,%esp
  8017c6:	68 00 50 80 00       	push   $0x805000
  8017cb:	53                   	push   %ebx
  8017cc:	e8 a1 ef ff ff       	call   800772 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8017d1:	a1 80 50 80 00       	mov    0x805080,%eax
  8017d6:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8017dc:	a1 84 50 80 00       	mov    0x805084,%eax
  8017e1:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8017e7:	83 c4 10             	add    $0x10,%esp
  8017ea:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8017ef:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017f2:	c9                   	leave  
  8017f3:	c3                   	ret    

008017f4 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8017f4:	55                   	push   %ebp
  8017f5:	89 e5                	mov    %esp,%ebp
  8017f7:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8017fa:	8b 45 08             	mov    0x8(%ebp),%eax
  8017fd:	8b 40 0c             	mov    0xc(%eax),%eax
  801800:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801805:	ba 00 00 00 00       	mov    $0x0,%edx
  80180a:	b8 06 00 00 00       	mov    $0x6,%eax
  80180f:	e8 3c ff ff ff       	call   801750 <fsipc>
}
  801814:	c9                   	leave  
  801815:	c3                   	ret    

00801816 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801816:	55                   	push   %ebp
  801817:	89 e5                	mov    %esp,%ebp
  801819:	56                   	push   %esi
  80181a:	53                   	push   %ebx
  80181b:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80181e:	8b 45 08             	mov    0x8(%ebp),%eax
  801821:	8b 40 0c             	mov    0xc(%eax),%eax
  801824:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801829:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80182f:	ba 00 00 00 00       	mov    $0x0,%edx
  801834:	b8 03 00 00 00       	mov    $0x3,%eax
  801839:	e8 12 ff ff ff       	call   801750 <fsipc>
  80183e:	89 c3                	mov    %eax,%ebx
  801840:	85 c0                	test   %eax,%eax
  801842:	78 4b                	js     80188f <devfile_read+0x79>
		return r;
	assert(r <= n);
  801844:	39 c6                	cmp    %eax,%esi
  801846:	73 16                	jae    80185e <devfile_read+0x48>
  801848:	68 38 27 80 00       	push   $0x802738
  80184d:	68 3f 27 80 00       	push   $0x80273f
  801852:	6a 7d                	push   $0x7d
  801854:	68 54 27 80 00       	push   $0x802754
  801859:	e8 ce 05 00 00       	call   801e2c <_panic>
	assert(r <= PGSIZE);
  80185e:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801863:	7e 16                	jle    80187b <devfile_read+0x65>
  801865:	68 5f 27 80 00       	push   $0x80275f
  80186a:	68 3f 27 80 00       	push   $0x80273f
  80186f:	6a 7e                	push   $0x7e
  801871:	68 54 27 80 00       	push   $0x802754
  801876:	e8 b1 05 00 00       	call   801e2c <_panic>
	memmove(buf, &fsipcbuf, r);
  80187b:	83 ec 04             	sub    $0x4,%esp
  80187e:	50                   	push   %eax
  80187f:	68 00 50 80 00       	push   $0x805000
  801884:	ff 75 0c             	pushl  0xc(%ebp)
  801887:	e8 a7 f0 ff ff       	call   800933 <memmove>
	return r;
  80188c:	83 c4 10             	add    $0x10,%esp
}
  80188f:	89 d8                	mov    %ebx,%eax
  801891:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801894:	5b                   	pop    %ebx
  801895:	5e                   	pop    %esi
  801896:	c9                   	leave  
  801897:	c3                   	ret    

00801898 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801898:	55                   	push   %ebp
  801899:	89 e5                	mov    %esp,%ebp
  80189b:	56                   	push   %esi
  80189c:	53                   	push   %ebx
  80189d:	83 ec 1c             	sub    $0x1c,%esp
  8018a0:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8018a3:	56                   	push   %esi
  8018a4:	e8 77 ee ff ff       	call   800720 <strlen>
  8018a9:	83 c4 10             	add    $0x10,%esp
  8018ac:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8018b1:	7f 65                	jg     801918 <open+0x80>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8018b3:	83 ec 0c             	sub    $0xc,%esp
  8018b6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018b9:	50                   	push   %eax
  8018ba:	e8 e1 f8 ff ff       	call   8011a0 <fd_alloc>
  8018bf:	89 c3                	mov    %eax,%ebx
  8018c1:	83 c4 10             	add    $0x10,%esp
  8018c4:	85 c0                	test   %eax,%eax
  8018c6:	78 55                	js     80191d <open+0x85>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8018c8:	83 ec 08             	sub    $0x8,%esp
  8018cb:	56                   	push   %esi
  8018cc:	68 00 50 80 00       	push   $0x805000
  8018d1:	e8 9c ee ff ff       	call   800772 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8018d6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018d9:	a3 00 54 80 00       	mov    %eax,0x805400



	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8018de:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8018e1:	b8 01 00 00 00       	mov    $0x1,%eax
  8018e6:	e8 65 fe ff ff       	call   801750 <fsipc>
  8018eb:	89 c3                	mov    %eax,%ebx
  8018ed:	83 c4 10             	add    $0x10,%esp
  8018f0:	85 c0                	test   %eax,%eax
  8018f2:	79 12                	jns    801906 <open+0x6e>
		fd_close(fd, 0);
  8018f4:	83 ec 08             	sub    $0x8,%esp
  8018f7:	6a 00                	push   $0x0
  8018f9:	ff 75 f4             	pushl  -0xc(%ebp)
  8018fc:	e8 ce f9 ff ff       	call   8012cf <fd_close>
		return r;
  801901:	83 c4 10             	add    $0x10,%esp
  801904:	eb 17                	jmp    80191d <open+0x85>
	}

	return fd2num(fd);
  801906:	83 ec 0c             	sub    $0xc,%esp
  801909:	ff 75 f4             	pushl  -0xc(%ebp)
  80190c:	e8 67 f8 ff ff       	call   801178 <fd2num>
  801911:	89 c3                	mov    %eax,%ebx
  801913:	83 c4 10             	add    $0x10,%esp
  801916:	eb 05                	jmp    80191d <open+0x85>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801918:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  80191d:	89 d8                	mov    %ebx,%eax
  80191f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801922:	5b                   	pop    %ebx
  801923:	5e                   	pop    %esi
  801924:	c9                   	leave  
  801925:	c3                   	ret    
	...

00801928 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801928:	55                   	push   %ebp
  801929:	89 e5                	mov    %esp,%ebp
  80192b:	56                   	push   %esi
  80192c:	53                   	push   %ebx
  80192d:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801930:	83 ec 0c             	sub    $0xc,%esp
  801933:	ff 75 08             	pushl  0x8(%ebp)
  801936:	e8 4d f8 ff ff       	call   801188 <fd2data>
  80193b:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  80193d:	83 c4 08             	add    $0x8,%esp
  801940:	68 6b 27 80 00       	push   $0x80276b
  801945:	56                   	push   %esi
  801946:	e8 27 ee ff ff       	call   800772 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  80194b:	8b 43 04             	mov    0x4(%ebx),%eax
  80194e:	2b 03                	sub    (%ebx),%eax
  801950:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  801956:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  80195d:	00 00 00 
	stat->st_dev = &devpipe;
  801960:	c7 86 88 00 00 00 20 	movl   $0x803020,0x88(%esi)
  801967:	30 80 00 
	return 0;
}
  80196a:	b8 00 00 00 00       	mov    $0x0,%eax
  80196f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801972:	5b                   	pop    %ebx
  801973:	5e                   	pop    %esi
  801974:	c9                   	leave  
  801975:	c3                   	ret    

00801976 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801976:	55                   	push   %ebp
  801977:	89 e5                	mov    %esp,%ebp
  801979:	53                   	push   %ebx
  80197a:	83 ec 0c             	sub    $0xc,%esp
  80197d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801980:	53                   	push   %ebx
  801981:	6a 00                	push   $0x0
  801983:	e8 b6 f2 ff ff       	call   800c3e <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801988:	89 1c 24             	mov    %ebx,(%esp)
  80198b:	e8 f8 f7 ff ff       	call   801188 <fd2data>
  801990:	83 c4 08             	add    $0x8,%esp
  801993:	50                   	push   %eax
  801994:	6a 00                	push   $0x0
  801996:	e8 a3 f2 ff ff       	call   800c3e <sys_page_unmap>
}
  80199b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80199e:	c9                   	leave  
  80199f:	c3                   	ret    

008019a0 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8019a0:	55                   	push   %ebp
  8019a1:	89 e5                	mov    %esp,%ebp
  8019a3:	57                   	push   %edi
  8019a4:	56                   	push   %esi
  8019a5:	53                   	push   %ebx
  8019a6:	83 ec 1c             	sub    $0x1c,%esp
  8019a9:	89 c7                	mov    %eax,%edi
  8019ab:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8019ae:	a1 04 40 80 00       	mov    0x804004,%eax
  8019b3:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  8019b6:	83 ec 0c             	sub    $0xc,%esp
  8019b9:	57                   	push   %edi
  8019ba:	e8 49 05 00 00       	call   801f08 <pageref>
  8019bf:	89 c6                	mov    %eax,%esi
  8019c1:	83 c4 04             	add    $0x4,%esp
  8019c4:	ff 75 e4             	pushl  -0x1c(%ebp)
  8019c7:	e8 3c 05 00 00       	call   801f08 <pageref>
  8019cc:	83 c4 10             	add    $0x10,%esp
  8019cf:	39 c6                	cmp    %eax,%esi
  8019d1:	0f 94 c0             	sete   %al
  8019d4:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  8019d7:	8b 15 04 40 80 00    	mov    0x804004,%edx
  8019dd:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  8019e0:	39 cb                	cmp    %ecx,%ebx
  8019e2:	75 08                	jne    8019ec <_pipeisclosed+0x4c>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  8019e4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8019e7:	5b                   	pop    %ebx
  8019e8:	5e                   	pop    %esi
  8019e9:	5f                   	pop    %edi
  8019ea:	c9                   	leave  
  8019eb:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  8019ec:	83 f8 01             	cmp    $0x1,%eax
  8019ef:	75 bd                	jne    8019ae <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8019f1:	8b 42 58             	mov    0x58(%edx),%eax
  8019f4:	6a 01                	push   $0x1
  8019f6:	50                   	push   %eax
  8019f7:	53                   	push   %ebx
  8019f8:	68 72 27 80 00       	push   $0x802772
  8019fd:	e8 ba e7 ff ff       	call   8001bc <cprintf>
  801a02:	83 c4 10             	add    $0x10,%esp
  801a05:	eb a7                	jmp    8019ae <_pipeisclosed+0xe>

00801a07 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801a07:	55                   	push   %ebp
  801a08:	89 e5                	mov    %esp,%ebp
  801a0a:	57                   	push   %edi
  801a0b:	56                   	push   %esi
  801a0c:	53                   	push   %ebx
  801a0d:	83 ec 28             	sub    $0x28,%esp
  801a10:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801a13:	56                   	push   %esi
  801a14:	e8 6f f7 ff ff       	call   801188 <fd2data>
  801a19:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801a1b:	83 c4 10             	add    $0x10,%esp
  801a1e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801a22:	75 4a                	jne    801a6e <devpipe_write+0x67>
  801a24:	bf 00 00 00 00       	mov    $0x0,%edi
  801a29:	eb 56                	jmp    801a81 <devpipe_write+0x7a>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801a2b:	89 da                	mov    %ebx,%edx
  801a2d:	89 f0                	mov    %esi,%eax
  801a2f:	e8 6c ff ff ff       	call   8019a0 <_pipeisclosed>
  801a34:	85 c0                	test   %eax,%eax
  801a36:	75 4d                	jne    801a85 <devpipe_write+0x7e>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801a38:	e8 90 f1 ff ff       	call   800bcd <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801a3d:	8b 43 04             	mov    0x4(%ebx),%eax
  801a40:	8b 13                	mov    (%ebx),%edx
  801a42:	83 c2 20             	add    $0x20,%edx
  801a45:	39 d0                	cmp    %edx,%eax
  801a47:	73 e2                	jae    801a2b <devpipe_write+0x24>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801a49:	89 c2                	mov    %eax,%edx
  801a4b:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  801a51:	79 05                	jns    801a58 <devpipe_write+0x51>
  801a53:	4a                   	dec    %edx
  801a54:	83 ca e0             	or     $0xffffffe0,%edx
  801a57:	42                   	inc    %edx
  801a58:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801a5b:	8a 0c 39             	mov    (%ecx,%edi,1),%cl
  801a5e:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801a62:	40                   	inc    %eax
  801a63:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801a66:	47                   	inc    %edi
  801a67:	39 7d 10             	cmp    %edi,0x10(%ebp)
  801a6a:	77 07                	ja     801a73 <devpipe_write+0x6c>
  801a6c:	eb 13                	jmp    801a81 <devpipe_write+0x7a>
  801a6e:	bf 00 00 00 00       	mov    $0x0,%edi
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801a73:	8b 43 04             	mov    0x4(%ebx),%eax
  801a76:	8b 13                	mov    (%ebx),%edx
  801a78:	83 c2 20             	add    $0x20,%edx
  801a7b:	39 d0                	cmp    %edx,%eax
  801a7d:	73 ac                	jae    801a2b <devpipe_write+0x24>
  801a7f:	eb c8                	jmp    801a49 <devpipe_write+0x42>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801a81:	89 f8                	mov    %edi,%eax
  801a83:	eb 05                	jmp    801a8a <devpipe_write+0x83>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801a85:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801a8a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a8d:	5b                   	pop    %ebx
  801a8e:	5e                   	pop    %esi
  801a8f:	5f                   	pop    %edi
  801a90:	c9                   	leave  
  801a91:	c3                   	ret    

00801a92 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801a92:	55                   	push   %ebp
  801a93:	89 e5                	mov    %esp,%ebp
  801a95:	57                   	push   %edi
  801a96:	56                   	push   %esi
  801a97:	53                   	push   %ebx
  801a98:	83 ec 18             	sub    $0x18,%esp
  801a9b:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801a9e:	57                   	push   %edi
  801a9f:	e8 e4 f6 ff ff       	call   801188 <fd2data>
  801aa4:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801aa6:	83 c4 10             	add    $0x10,%esp
  801aa9:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801aad:	75 44                	jne    801af3 <devpipe_read+0x61>
  801aaf:	be 00 00 00 00       	mov    $0x0,%esi
  801ab4:	eb 4f                	jmp    801b05 <devpipe_read+0x73>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
				return i;
  801ab6:	89 f0                	mov    %esi,%eax
  801ab8:	eb 54                	jmp    801b0e <devpipe_read+0x7c>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801aba:	89 da                	mov    %ebx,%edx
  801abc:	89 f8                	mov    %edi,%eax
  801abe:	e8 dd fe ff ff       	call   8019a0 <_pipeisclosed>
  801ac3:	85 c0                	test   %eax,%eax
  801ac5:	75 42                	jne    801b09 <devpipe_read+0x77>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801ac7:	e8 01 f1 ff ff       	call   800bcd <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801acc:	8b 03                	mov    (%ebx),%eax
  801ace:	3b 43 04             	cmp    0x4(%ebx),%eax
  801ad1:	74 e7                	je     801aba <devpipe_read+0x28>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801ad3:	25 1f 00 00 80       	and    $0x8000001f,%eax
  801ad8:	79 05                	jns    801adf <devpipe_read+0x4d>
  801ada:	48                   	dec    %eax
  801adb:	83 c8 e0             	or     $0xffffffe0,%eax
  801ade:	40                   	inc    %eax
  801adf:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  801ae3:	8b 55 0c             	mov    0xc(%ebp),%edx
  801ae6:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  801ae9:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801aeb:	46                   	inc    %esi
  801aec:	39 75 10             	cmp    %esi,0x10(%ebp)
  801aef:	77 07                	ja     801af8 <devpipe_read+0x66>
  801af1:	eb 12                	jmp    801b05 <devpipe_read+0x73>
  801af3:	be 00 00 00 00       	mov    $0x0,%esi
		while (p->p_rpos == p->p_wpos) {
  801af8:	8b 03                	mov    (%ebx),%eax
  801afa:	3b 43 04             	cmp    0x4(%ebx),%eax
  801afd:	75 d4                	jne    801ad3 <devpipe_read+0x41>
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801aff:	85 f6                	test   %esi,%esi
  801b01:	75 b3                	jne    801ab6 <devpipe_read+0x24>
  801b03:	eb b5                	jmp    801aba <devpipe_read+0x28>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801b05:	89 f0                	mov    %esi,%eax
  801b07:	eb 05                	jmp    801b0e <devpipe_read+0x7c>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801b09:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801b0e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b11:	5b                   	pop    %ebx
  801b12:	5e                   	pop    %esi
  801b13:	5f                   	pop    %edi
  801b14:	c9                   	leave  
  801b15:	c3                   	ret    

00801b16 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801b16:	55                   	push   %ebp
  801b17:	89 e5                	mov    %esp,%ebp
  801b19:	57                   	push   %edi
  801b1a:	56                   	push   %esi
  801b1b:	53                   	push   %ebx
  801b1c:	83 ec 28             	sub    $0x28,%esp
  801b1f:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801b22:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801b25:	50                   	push   %eax
  801b26:	e8 75 f6 ff ff       	call   8011a0 <fd_alloc>
  801b2b:	89 c3                	mov    %eax,%ebx
  801b2d:	83 c4 10             	add    $0x10,%esp
  801b30:	85 c0                	test   %eax,%eax
  801b32:	0f 88 24 01 00 00    	js     801c5c <pipe+0x146>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b38:	83 ec 04             	sub    $0x4,%esp
  801b3b:	68 07 04 00 00       	push   $0x407
  801b40:	ff 75 e4             	pushl  -0x1c(%ebp)
  801b43:	6a 00                	push   $0x0
  801b45:	e8 aa f0 ff ff       	call   800bf4 <sys_page_alloc>
  801b4a:	89 c3                	mov    %eax,%ebx
  801b4c:	83 c4 10             	add    $0x10,%esp
  801b4f:	85 c0                	test   %eax,%eax
  801b51:	0f 88 05 01 00 00    	js     801c5c <pipe+0x146>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801b57:	83 ec 0c             	sub    $0xc,%esp
  801b5a:	8d 45 e0             	lea    -0x20(%ebp),%eax
  801b5d:	50                   	push   %eax
  801b5e:	e8 3d f6 ff ff       	call   8011a0 <fd_alloc>
  801b63:	89 c3                	mov    %eax,%ebx
  801b65:	83 c4 10             	add    $0x10,%esp
  801b68:	85 c0                	test   %eax,%eax
  801b6a:	0f 88 dc 00 00 00    	js     801c4c <pipe+0x136>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b70:	83 ec 04             	sub    $0x4,%esp
  801b73:	68 07 04 00 00       	push   $0x407
  801b78:	ff 75 e0             	pushl  -0x20(%ebp)
  801b7b:	6a 00                	push   $0x0
  801b7d:	e8 72 f0 ff ff       	call   800bf4 <sys_page_alloc>
  801b82:	89 c3                	mov    %eax,%ebx
  801b84:	83 c4 10             	add    $0x10,%esp
  801b87:	85 c0                	test   %eax,%eax
  801b89:	0f 88 bd 00 00 00    	js     801c4c <pipe+0x136>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801b8f:	83 ec 0c             	sub    $0xc,%esp
  801b92:	ff 75 e4             	pushl  -0x1c(%ebp)
  801b95:	e8 ee f5 ff ff       	call   801188 <fd2data>
  801b9a:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b9c:	83 c4 0c             	add    $0xc,%esp
  801b9f:	68 07 04 00 00       	push   $0x407
  801ba4:	50                   	push   %eax
  801ba5:	6a 00                	push   $0x0
  801ba7:	e8 48 f0 ff ff       	call   800bf4 <sys_page_alloc>
  801bac:	89 c3                	mov    %eax,%ebx
  801bae:	83 c4 10             	add    $0x10,%esp
  801bb1:	85 c0                	test   %eax,%eax
  801bb3:	0f 88 83 00 00 00    	js     801c3c <pipe+0x126>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801bb9:	83 ec 0c             	sub    $0xc,%esp
  801bbc:	ff 75 e0             	pushl  -0x20(%ebp)
  801bbf:	e8 c4 f5 ff ff       	call   801188 <fd2data>
  801bc4:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801bcb:	50                   	push   %eax
  801bcc:	6a 00                	push   $0x0
  801bce:	56                   	push   %esi
  801bcf:	6a 00                	push   $0x0
  801bd1:	e8 42 f0 ff ff       	call   800c18 <sys_page_map>
  801bd6:	89 c3                	mov    %eax,%ebx
  801bd8:	83 c4 20             	add    $0x20,%esp
  801bdb:	85 c0                	test   %eax,%eax
  801bdd:	78 4f                	js     801c2e <pipe+0x118>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801bdf:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801be5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801be8:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801bea:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801bed:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801bf4:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801bfa:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801bfd:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801bff:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801c02:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801c09:	83 ec 0c             	sub    $0xc,%esp
  801c0c:	ff 75 e4             	pushl  -0x1c(%ebp)
  801c0f:	e8 64 f5 ff ff       	call   801178 <fd2num>
  801c14:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  801c16:	83 c4 04             	add    $0x4,%esp
  801c19:	ff 75 e0             	pushl  -0x20(%ebp)
  801c1c:	e8 57 f5 ff ff       	call   801178 <fd2num>
  801c21:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  801c24:	83 c4 10             	add    $0x10,%esp
  801c27:	bb 00 00 00 00       	mov    $0x0,%ebx
  801c2c:	eb 2e                	jmp    801c5c <pipe+0x146>

    err3:
	sys_page_unmap(0, va);
  801c2e:	83 ec 08             	sub    $0x8,%esp
  801c31:	56                   	push   %esi
  801c32:	6a 00                	push   $0x0
  801c34:	e8 05 f0 ff ff       	call   800c3e <sys_page_unmap>
  801c39:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801c3c:	83 ec 08             	sub    $0x8,%esp
  801c3f:	ff 75 e0             	pushl  -0x20(%ebp)
  801c42:	6a 00                	push   $0x0
  801c44:	e8 f5 ef ff ff       	call   800c3e <sys_page_unmap>
  801c49:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801c4c:	83 ec 08             	sub    $0x8,%esp
  801c4f:	ff 75 e4             	pushl  -0x1c(%ebp)
  801c52:	6a 00                	push   $0x0
  801c54:	e8 e5 ef ff ff       	call   800c3e <sys_page_unmap>
  801c59:	83 c4 10             	add    $0x10,%esp
    err:
	return r;
}
  801c5c:	89 d8                	mov    %ebx,%eax
  801c5e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c61:	5b                   	pop    %ebx
  801c62:	5e                   	pop    %esi
  801c63:	5f                   	pop    %edi
  801c64:	c9                   	leave  
  801c65:	c3                   	ret    

00801c66 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801c66:	55                   	push   %ebp
  801c67:	89 e5                	mov    %esp,%ebp
  801c69:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801c6c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c6f:	50                   	push   %eax
  801c70:	ff 75 08             	pushl  0x8(%ebp)
  801c73:	e8 9b f5 ff ff       	call   801213 <fd_lookup>
  801c78:	83 c4 10             	add    $0x10,%esp
  801c7b:	85 c0                	test   %eax,%eax
  801c7d:	78 18                	js     801c97 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801c7f:	83 ec 0c             	sub    $0xc,%esp
  801c82:	ff 75 f4             	pushl  -0xc(%ebp)
  801c85:	e8 fe f4 ff ff       	call   801188 <fd2data>
	return _pipeisclosed(fd, p);
  801c8a:	89 c2                	mov    %eax,%edx
  801c8c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c8f:	e8 0c fd ff ff       	call   8019a0 <_pipeisclosed>
  801c94:	83 c4 10             	add    $0x10,%esp
}
  801c97:	c9                   	leave  
  801c98:	c3                   	ret    
  801c99:	00 00                	add    %al,(%eax)
	...

00801c9c <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801c9c:	55                   	push   %ebp
  801c9d:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801c9f:	b8 00 00 00 00       	mov    $0x0,%eax
  801ca4:	c9                   	leave  
  801ca5:	c3                   	ret    

00801ca6 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801ca6:	55                   	push   %ebp
  801ca7:	89 e5                	mov    %esp,%ebp
  801ca9:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801cac:	68 8a 27 80 00       	push   $0x80278a
  801cb1:	ff 75 0c             	pushl  0xc(%ebp)
  801cb4:	e8 b9 ea ff ff       	call   800772 <strcpy>
	return 0;
}
  801cb9:	b8 00 00 00 00       	mov    $0x0,%eax
  801cbe:	c9                   	leave  
  801cbf:	c3                   	ret    

00801cc0 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801cc0:	55                   	push   %ebp
  801cc1:	89 e5                	mov    %esp,%ebp
  801cc3:	57                   	push   %edi
  801cc4:	56                   	push   %esi
  801cc5:	53                   	push   %ebx
  801cc6:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801ccc:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801cd0:	74 45                	je     801d17 <devcons_write+0x57>
  801cd2:	b8 00 00 00 00       	mov    $0x0,%eax
  801cd7:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801cdc:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801ce2:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801ce5:	29 c3                	sub    %eax,%ebx
		if (m > sizeof(buf) - 1)
  801ce7:	83 fb 7f             	cmp    $0x7f,%ebx
  801cea:	76 05                	jbe    801cf1 <devcons_write+0x31>
			m = sizeof(buf) - 1;
  801cec:	bb 7f 00 00 00       	mov    $0x7f,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  801cf1:	83 ec 04             	sub    $0x4,%esp
  801cf4:	53                   	push   %ebx
  801cf5:	03 45 0c             	add    0xc(%ebp),%eax
  801cf8:	50                   	push   %eax
  801cf9:	57                   	push   %edi
  801cfa:	e8 34 ec ff ff       	call   800933 <memmove>
		sys_cputs(buf, m);
  801cff:	83 c4 08             	add    $0x8,%esp
  801d02:	53                   	push   %ebx
  801d03:	57                   	push   %edi
  801d04:	e8 34 ee ff ff       	call   800b3d <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801d09:	01 de                	add    %ebx,%esi
  801d0b:	89 f0                	mov    %esi,%eax
  801d0d:	83 c4 10             	add    $0x10,%esp
  801d10:	3b 75 10             	cmp    0x10(%ebp),%esi
  801d13:	72 cd                	jb     801ce2 <devcons_write+0x22>
  801d15:	eb 05                	jmp    801d1c <devcons_write+0x5c>
  801d17:	be 00 00 00 00       	mov    $0x0,%esi
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801d1c:	89 f0                	mov    %esi,%eax
  801d1e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d21:	5b                   	pop    %ebx
  801d22:	5e                   	pop    %esi
  801d23:	5f                   	pop    %edi
  801d24:	c9                   	leave  
  801d25:	c3                   	ret    

00801d26 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801d26:	55                   	push   %ebp
  801d27:	89 e5                	mov    %esp,%ebp
  801d29:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  801d2c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801d30:	75 07                	jne    801d39 <devcons_read+0x13>
  801d32:	eb 25                	jmp    801d59 <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801d34:	e8 94 ee ff ff       	call   800bcd <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801d39:	e8 25 ee ff ff       	call   800b63 <sys_cgetc>
  801d3e:	85 c0                	test   %eax,%eax
  801d40:	74 f2                	je     801d34 <devcons_read+0xe>
  801d42:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  801d44:	85 c0                	test   %eax,%eax
  801d46:	78 1d                	js     801d65 <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801d48:	83 f8 04             	cmp    $0x4,%eax
  801d4b:	74 13                	je     801d60 <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  801d4d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d50:	88 10                	mov    %dl,(%eax)
	return 1;
  801d52:	b8 01 00 00 00       	mov    $0x1,%eax
  801d57:	eb 0c                	jmp    801d65 <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  801d59:	b8 00 00 00 00       	mov    $0x0,%eax
  801d5e:	eb 05                	jmp    801d65 <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801d60:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801d65:	c9                   	leave  
  801d66:	c3                   	ret    

00801d67 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801d67:	55                   	push   %ebp
  801d68:	89 e5                	mov    %esp,%ebp
  801d6a:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801d6d:	8b 45 08             	mov    0x8(%ebp),%eax
  801d70:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801d73:	6a 01                	push   $0x1
  801d75:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801d78:	50                   	push   %eax
  801d79:	e8 bf ed ff ff       	call   800b3d <sys_cputs>
  801d7e:	83 c4 10             	add    $0x10,%esp
}
  801d81:	c9                   	leave  
  801d82:	c3                   	ret    

00801d83 <getchar>:

int
getchar(void)
{
  801d83:	55                   	push   %ebp
  801d84:	89 e5                	mov    %esp,%ebp
  801d86:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801d89:	6a 01                	push   $0x1
  801d8b:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801d8e:	50                   	push   %eax
  801d8f:	6a 00                	push   $0x0
  801d91:	e8 fe f6 ff ff       	call   801494 <read>
	if (r < 0)
  801d96:	83 c4 10             	add    $0x10,%esp
  801d99:	85 c0                	test   %eax,%eax
  801d9b:	78 0f                	js     801dac <getchar+0x29>
		return r;
	if (r < 1)
  801d9d:	85 c0                	test   %eax,%eax
  801d9f:	7e 06                	jle    801da7 <getchar+0x24>
		return -E_EOF;
	return c;
  801da1:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801da5:	eb 05                	jmp    801dac <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801da7:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801dac:	c9                   	leave  
  801dad:	c3                   	ret    

00801dae <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801dae:	55                   	push   %ebp
  801daf:	89 e5                	mov    %esp,%ebp
  801db1:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801db4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801db7:	50                   	push   %eax
  801db8:	ff 75 08             	pushl  0x8(%ebp)
  801dbb:	e8 53 f4 ff ff       	call   801213 <fd_lookup>
  801dc0:	83 c4 10             	add    $0x10,%esp
  801dc3:	85 c0                	test   %eax,%eax
  801dc5:	78 11                	js     801dd8 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801dc7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801dca:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801dd0:	39 10                	cmp    %edx,(%eax)
  801dd2:	0f 94 c0             	sete   %al
  801dd5:	0f b6 c0             	movzbl %al,%eax
}
  801dd8:	c9                   	leave  
  801dd9:	c3                   	ret    

00801dda <opencons>:

int
opencons(void)
{
  801dda:	55                   	push   %ebp
  801ddb:	89 e5                	mov    %esp,%ebp
  801ddd:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801de0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801de3:	50                   	push   %eax
  801de4:	e8 b7 f3 ff ff       	call   8011a0 <fd_alloc>
  801de9:	83 c4 10             	add    $0x10,%esp
  801dec:	85 c0                	test   %eax,%eax
  801dee:	78 3a                	js     801e2a <opencons+0x50>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801df0:	83 ec 04             	sub    $0x4,%esp
  801df3:	68 07 04 00 00       	push   $0x407
  801df8:	ff 75 f4             	pushl  -0xc(%ebp)
  801dfb:	6a 00                	push   $0x0
  801dfd:	e8 f2 ed ff ff       	call   800bf4 <sys_page_alloc>
  801e02:	83 c4 10             	add    $0x10,%esp
  801e05:	85 c0                	test   %eax,%eax
  801e07:	78 21                	js     801e2a <opencons+0x50>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801e09:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801e0f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e12:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801e14:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e17:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801e1e:	83 ec 0c             	sub    $0xc,%esp
  801e21:	50                   	push   %eax
  801e22:	e8 51 f3 ff ff       	call   801178 <fd2num>
  801e27:	83 c4 10             	add    $0x10,%esp
}
  801e2a:	c9                   	leave  
  801e2b:	c3                   	ret    

00801e2c <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801e2c:	55                   	push   %ebp
  801e2d:	89 e5                	mov    %esp,%ebp
  801e2f:	56                   	push   %esi
  801e30:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801e31:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801e34:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  801e3a:	e8 6a ed ff ff       	call   800ba9 <sys_getenvid>
  801e3f:	83 ec 0c             	sub    $0xc,%esp
  801e42:	ff 75 0c             	pushl  0xc(%ebp)
  801e45:	ff 75 08             	pushl  0x8(%ebp)
  801e48:	53                   	push   %ebx
  801e49:	50                   	push   %eax
  801e4a:	68 98 27 80 00       	push   $0x802798
  801e4f:	e8 68 e3 ff ff       	call   8001bc <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801e54:	83 c4 18             	add    $0x18,%esp
  801e57:	56                   	push   %esi
  801e58:	ff 75 10             	pushl  0x10(%ebp)
  801e5b:	e8 0b e3 ff ff       	call   80016b <vcprintf>
	cprintf("\n");
  801e60:	c7 04 24 83 27 80 00 	movl   $0x802783,(%esp)
  801e67:	e8 50 e3 ff ff       	call   8001bc <cprintf>
  801e6c:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801e6f:	cc                   	int3   
  801e70:	eb fd                	jmp    801e6f <_panic+0x43>
	...

00801e74 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801e74:	55                   	push   %ebp
  801e75:	89 e5                	mov    %esp,%ebp
  801e77:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  801e7a:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801e81:	75 52                	jne    801ed5 <set_pgfault_handler+0x61>
		// First time through!	
		// LAB 4: Your code here.

		//int sys_page_alloc(envid_t envid, void *va, int perm)
		r = sys_page_alloc(0, (void*)(UXSTACKTOP - PGSIZE), PTE_U | PTE_W | PTE_P);
  801e83:	83 ec 04             	sub    $0x4,%esp
  801e86:	6a 07                	push   $0x7
  801e88:	68 00 f0 bf ee       	push   $0xeebff000
  801e8d:	6a 00                	push   $0x0
  801e8f:	e8 60 ed ff ff       	call   800bf4 <sys_page_alloc>
		if (r < 0) {
  801e94:	83 c4 10             	add    $0x10,%esp
  801e97:	85 c0                	test   %eax,%eax
  801e99:	79 12                	jns    801ead <set_pgfault_handler+0x39>
			panic("sys_page_alloc error : %e\n", r);
  801e9b:	50                   	push   %eax
  801e9c:	68 bb 27 80 00       	push   $0x8027bb
  801ea1:	6a 24                	push   $0x24
  801ea3:	68 d6 27 80 00       	push   $0x8027d6
  801ea8:	e8 7f ff ff ff       	call   801e2c <_panic>
		}

		// how to know envid, put 0, envid2env will help us to get curenv in syscall
		r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);		
  801ead:	83 ec 08             	sub    $0x8,%esp
  801eb0:	68 e0 1e 80 00       	push   $0x801ee0
  801eb5:	6a 00                	push   $0x0
  801eb7:	e8 eb ed ff ff       	call   800ca7 <sys_env_set_pgfault_upcall>
		if (r < 0) {
  801ebc:	83 c4 10             	add    $0x10,%esp
  801ebf:	85 c0                	test   %eax,%eax
  801ec1:	79 12                	jns    801ed5 <set_pgfault_handler+0x61>
			panic("sys_env_set_pgfault_upcall error : %e\n", r);
  801ec3:	50                   	push   %eax
  801ec4:	68 e4 27 80 00       	push   $0x8027e4
  801ec9:	6a 2a                	push   $0x2a
  801ecb:	68 d6 27 80 00       	push   $0x8027d6
  801ed0:	e8 57 ff ff ff       	call   801e2c <_panic>
		}
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801ed5:	8b 45 08             	mov    0x8(%ebp),%eax
  801ed8:	a3 00 60 80 00       	mov    %eax,0x806000
}
  801edd:	c9                   	leave  
  801ede:	c3                   	ret    
	...

00801ee0 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801ee0:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801ee1:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  801ee6:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801ee8:	83 c4 04             	add    $0x4,%esp
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	
	// fix old esp
	movl 0x30(%esp), %eax
  801eeb:	8b 44 24 30          	mov    0x30(%esp),%eax
	subl $0x4, %eax
  801eef:	83 e8 04             	sub    $0x4,%eax
	movl %eax, 0x30(%esp)
  801ef2:	89 44 24 30          	mov    %eax,0x30(%esp)

	// set trap-time %eip
	movl 0x28(%esp), %ebx
  801ef6:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	movl %ebx, (%eax)
  801efa:	89 18                	mov    %ebx,(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $0x08, %esp 	// ignore err_code and fault_va
  801efc:	83 c4 08             	add    $0x8,%esp
	popal 				// restore registers
  801eff:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x04, %esp 	// ignore eip 
  801f00:	83 c4 04             	add    $0x4,%esp
	popfl				// modify eflags
  801f03:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  801f04:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  801f05:	c3                   	ret    
	...

00801f08 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801f08:	55                   	push   %ebp
  801f09:	89 e5                	mov    %esp,%ebp
  801f0b:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801f0e:	89 c2                	mov    %eax,%edx
  801f10:	c1 ea 16             	shr    $0x16,%edx
  801f13:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801f1a:	f6 c2 01             	test   $0x1,%dl
  801f1d:	74 1e                	je     801f3d <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  801f1f:	c1 e8 0c             	shr    $0xc,%eax
  801f22:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801f29:	a8 01                	test   $0x1,%al
  801f2b:	74 17                	je     801f44 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801f2d:	c1 e8 0c             	shr    $0xc,%eax
  801f30:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  801f37:	ef 
  801f38:	0f b7 c0             	movzwl %ax,%eax
  801f3b:	eb 0c                	jmp    801f49 <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  801f3d:	b8 00 00 00 00       	mov    $0x0,%eax
  801f42:	eb 05                	jmp    801f49 <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  801f44:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  801f49:	c9                   	leave  
  801f4a:	c3                   	ret    
	...

00801f4c <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  801f4c:	55                   	push   %ebp
  801f4d:	89 e5                	mov    %esp,%ebp
  801f4f:	57                   	push   %edi
  801f50:	56                   	push   %esi
  801f51:	83 ec 10             	sub    $0x10,%esp
  801f54:	8b 7d 08             	mov    0x8(%ebp),%edi
  801f57:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  801f5a:	89 7d f0             	mov    %edi,-0x10(%ebp)
  801f5d:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  801f60:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  801f63:	8b 45 14             	mov    0x14(%ebp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  801f66:	85 c0                	test   %eax,%eax
  801f68:	75 2e                	jne    801f98 <__udivdi3+0x4c>
    {
      if (d0 > n1)
  801f6a:	39 f1                	cmp    %esi,%ecx
  801f6c:	77 5a                	ja     801fc8 <__udivdi3+0x7c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  801f6e:	85 c9                	test   %ecx,%ecx
  801f70:	75 0b                	jne    801f7d <__udivdi3+0x31>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  801f72:	b8 01 00 00 00       	mov    $0x1,%eax
  801f77:	31 d2                	xor    %edx,%edx
  801f79:	f7 f1                	div    %ecx
  801f7b:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  801f7d:	31 d2                	xor    %edx,%edx
  801f7f:	89 f0                	mov    %esi,%eax
  801f81:	f7 f1                	div    %ecx
  801f83:	89 c6                	mov    %eax,%esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801f85:	89 f8                	mov    %edi,%eax
  801f87:	f7 f1                	div    %ecx
  801f89:	89 c7                	mov    %eax,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801f8b:	89 f8                	mov    %edi,%eax
  801f8d:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801f8f:	83 c4 10             	add    $0x10,%esp
  801f92:	5e                   	pop    %esi
  801f93:	5f                   	pop    %edi
  801f94:	c9                   	leave  
  801f95:	c3                   	ret    
  801f96:	66 90                	xchg   %ax,%ax
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801f98:	39 f0                	cmp    %esi,%eax
  801f9a:	77 1c                	ja     801fb8 <__udivdi3+0x6c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  801f9c:	0f bd f8             	bsr    %eax,%edi
	  if (bm == 0)
  801f9f:	83 f7 1f             	xor    $0x1f,%edi
  801fa2:	75 3c                	jne    801fe0 <__udivdi3+0x94>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801fa4:	39 f0                	cmp    %esi,%eax
  801fa6:	0f 82 90 00 00 00    	jb     80203c <__udivdi3+0xf0>
  801fac:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801faf:	39 55 f4             	cmp    %edx,-0xc(%ebp)
  801fb2:	0f 86 84 00 00 00    	jbe    80203c <__udivdi3+0xf0>
  801fb8:	31 f6                	xor    %esi,%esi
  801fba:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801fbc:	89 f8                	mov    %edi,%eax
  801fbe:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801fc0:	83 c4 10             	add    $0x10,%esp
  801fc3:	5e                   	pop    %esi
  801fc4:	5f                   	pop    %edi
  801fc5:	c9                   	leave  
  801fc6:	c3                   	ret    
  801fc7:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801fc8:	89 f2                	mov    %esi,%edx
  801fca:	89 f8                	mov    %edi,%eax
  801fcc:	f7 f1                	div    %ecx
  801fce:	89 c7                	mov    %eax,%edi
  801fd0:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801fd2:	89 f8                	mov    %edi,%eax
  801fd4:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801fd6:	83 c4 10             	add    $0x10,%esp
  801fd9:	5e                   	pop    %esi
  801fda:	5f                   	pop    %edi
  801fdb:	c9                   	leave  
  801fdc:	c3                   	ret    
  801fdd:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  801fe0:	89 f9                	mov    %edi,%ecx
  801fe2:	d3 e0                	shl    %cl,%eax
  801fe4:	89 45 e8             	mov    %eax,-0x18(%ebp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  801fe7:	b8 20 00 00 00       	mov    $0x20,%eax
  801fec:	29 f8                	sub    %edi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  801fee:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801ff1:	88 c1                	mov    %al,%cl
  801ff3:	d3 ea                	shr    %cl,%edx
  801ff5:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  801ff8:	09 ca                	or     %ecx,%edx
  801ffa:	89 55 ec             	mov    %edx,-0x14(%ebp)
	      d0 = d0 << bm;
  801ffd:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802000:	89 f9                	mov    %edi,%ecx
  802002:	d3 e2                	shl    %cl,%edx
  802004:	89 55 f4             	mov    %edx,-0xc(%ebp)
	      n2 = n1 >> b;
  802007:	89 f2                	mov    %esi,%edx
  802009:	88 c1                	mov    %al,%cl
  80200b:	d3 ea                	shr    %cl,%edx
  80200d:	89 55 e8             	mov    %edx,-0x18(%ebp)
	      n1 = (n1 << bm) | (n0 >> b);
  802010:	89 f2                	mov    %esi,%edx
  802012:	89 f9                	mov    %edi,%ecx
  802014:	d3 e2                	shl    %cl,%edx
  802016:	8b 75 f0             	mov    -0x10(%ebp),%esi
  802019:	88 c1                	mov    %al,%cl
  80201b:	d3 ee                	shr    %cl,%esi
  80201d:	09 d6                	or     %edx,%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  80201f:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  802022:	89 f0                	mov    %esi,%eax
  802024:	89 ca                	mov    %ecx,%edx
  802026:	f7 75 ec             	divl   -0x14(%ebp)
  802029:	89 d1                	mov    %edx,%ecx
  80202b:	89 c6                	mov    %eax,%esi
	      umul_ppmm (m1, m0, q0, d0);
  80202d:	f7 65 f4             	mull   -0xc(%ebp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802030:	39 d1                	cmp    %edx,%ecx
  802032:	72 28                	jb     80205c <__udivdi3+0x110>
  802034:	74 1a                	je     802050 <__udivdi3+0x104>
  802036:	89 f7                	mov    %esi,%edi
  802038:	31 f6                	xor    %esi,%esi
  80203a:	eb 80                	jmp    801fbc <__udivdi3+0x70>
	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  80203c:	31 f6                	xor    %esi,%esi
  80203e:	bf 01 00 00 00       	mov    $0x1,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  802043:	89 f8                	mov    %edi,%eax
  802045:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802047:	83 c4 10             	add    $0x10,%esp
  80204a:	5e                   	pop    %esi
  80204b:	5f                   	pop    %edi
  80204c:	c9                   	leave  
  80204d:	c3                   	ret    
  80204e:	66 90                	xchg   %ax,%ax

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  802050:	8b 55 f0             	mov    -0x10(%ebp),%edx
  802053:	89 f9                	mov    %edi,%ecx
  802055:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802057:	39 c2                	cmp    %eax,%edx
  802059:	73 db                	jae    802036 <__udivdi3+0xea>
  80205b:	90                   	nop
		{
		  q0--;
  80205c:	8d 7e ff             	lea    -0x1(%esi),%edi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  80205f:	31 f6                	xor    %esi,%esi
  802061:	e9 56 ff ff ff       	jmp    801fbc <__udivdi3+0x70>
	...

00802068 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  802068:	55                   	push   %ebp
  802069:	89 e5                	mov    %esp,%ebp
  80206b:	57                   	push   %edi
  80206c:	56                   	push   %esi
  80206d:	83 ec 20             	sub    $0x20,%esp
  802070:	8b 45 08             	mov    0x8(%ebp),%eax
  802073:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  802076:	89 45 e8             	mov    %eax,-0x18(%ebp)
  802079:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  80207c:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  80207f:	8b 7d 14             	mov    0x14(%ebp),%edi
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  802082:	89 45 f0             	mov    %eax,-0x10(%ebp)
  n1 = nn.s.high;
  802085:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  802087:	85 ff                	test   %edi,%edi
  802089:	75 15                	jne    8020a0 <__umoddi3+0x38>
    {
      if (d0 > n1)
  80208b:	39 f1                	cmp    %esi,%ecx
  80208d:	0f 86 99 00 00 00    	jbe    80212c <__umoddi3+0xc4>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802093:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  802095:	89 d0                	mov    %edx,%eax
  802097:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802099:	83 c4 20             	add    $0x20,%esp
  80209c:	5e                   	pop    %esi
  80209d:	5f                   	pop    %edi
  80209e:	c9                   	leave  
  80209f:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  8020a0:	39 f7                	cmp    %esi,%edi
  8020a2:	0f 87 a4 00 00 00    	ja     80214c <__umoddi3+0xe4>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  8020a8:	0f bd c7             	bsr    %edi,%eax
	  if (bm == 0)
  8020ab:	83 f0 1f             	xor    $0x1f,%eax
  8020ae:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8020b1:	0f 84 a1 00 00 00    	je     802158 <__umoddi3+0xf0>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  8020b7:	89 f8                	mov    %edi,%eax
  8020b9:	8a 4d ec             	mov    -0x14(%ebp),%cl
  8020bc:	d3 e0                	shl    %cl,%eax
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  8020be:	bf 20 00 00 00       	mov    $0x20,%edi
  8020c3:	2b 7d ec             	sub    -0x14(%ebp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  8020c6:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8020c9:	89 f9                	mov    %edi,%ecx
  8020cb:	d3 ea                	shr    %cl,%edx
  8020cd:	09 c2                	or     %eax,%edx
  8020cf:	89 55 f0             	mov    %edx,-0x10(%ebp)
	      d0 = d0 << bm;
  8020d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020d5:	8a 4d ec             	mov    -0x14(%ebp),%cl
  8020d8:	d3 e0                	shl    %cl,%eax
  8020da:	89 45 f4             	mov    %eax,-0xc(%ebp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  8020dd:	89 f2                	mov    %esi,%edx
  8020df:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  8020e1:	8b 45 e8             	mov    -0x18(%ebp),%eax
  8020e4:	d3 e0                	shl    %cl,%eax
  8020e6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  8020e9:	8b 45 e8             	mov    -0x18(%ebp),%eax
  8020ec:	89 f9                	mov    %edi,%ecx
  8020ee:	d3 e8                	shr    %cl,%eax
  8020f0:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  8020f2:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  8020f4:	89 f2                	mov    %esi,%edx
  8020f6:	f7 75 f0             	divl   -0x10(%ebp)
  8020f9:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  8020fb:	f7 65 f4             	mull   -0xc(%ebp)
  8020fe:	89 55 e8             	mov    %edx,-0x18(%ebp)
  802101:	89 c1                	mov    %eax,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802103:	39 d6                	cmp    %edx,%esi
  802105:	72 71                	jb     802178 <__umoddi3+0x110>
  802107:	74 7f                	je     802188 <__umoddi3+0x120>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  802109:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80210c:	29 c8                	sub    %ecx,%eax
  80210e:	19 d6                	sbb    %edx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  802110:	8a 4d ec             	mov    -0x14(%ebp),%cl
  802113:	d3 e8                	shr    %cl,%eax
  802115:	89 f2                	mov    %esi,%edx
  802117:	89 f9                	mov    %edi,%ecx
  802119:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  80211b:	09 d0                	or     %edx,%eax
  80211d:	89 f2                	mov    %esi,%edx
  80211f:	8a 4d ec             	mov    -0x14(%ebp),%cl
  802122:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802124:	83 c4 20             	add    $0x20,%esp
  802127:	5e                   	pop    %esi
  802128:	5f                   	pop    %edi
  802129:	c9                   	leave  
  80212a:	c3                   	ret    
  80212b:	90                   	nop
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  80212c:	85 c9                	test   %ecx,%ecx
  80212e:	75 0b                	jne    80213b <__umoddi3+0xd3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  802130:	b8 01 00 00 00       	mov    $0x1,%eax
  802135:	31 d2                	xor    %edx,%edx
  802137:	f7 f1                	div    %ecx
  802139:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  80213b:	89 f0                	mov    %esi,%eax
  80213d:	31 d2                	xor    %edx,%edx
  80213f:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802141:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802144:	f7 f1                	div    %ecx
  802146:	e9 4a ff ff ff       	jmp    802095 <__umoddi3+0x2d>
  80214b:	90                   	nop
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  80214c:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  80214e:	83 c4 20             	add    $0x20,%esp
  802151:	5e                   	pop    %esi
  802152:	5f                   	pop    %edi
  802153:	c9                   	leave  
  802154:	c3                   	ret    
  802155:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802158:	39 f7                	cmp    %esi,%edi
  80215a:	72 05                	jb     802161 <__umoddi3+0xf9>
  80215c:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
  80215f:	77 0c                	ja     80216d <__umoddi3+0x105>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  802161:	89 f2                	mov    %esi,%edx
  802163:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802166:	29 c8                	sub    %ecx,%eax
  802168:	19 fa                	sbb    %edi,%edx
  80216a:	89 45 f0             	mov    %eax,-0x10(%ebp)

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  80216d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802170:	83 c4 20             	add    $0x20,%esp
  802173:	5e                   	pop    %esi
  802174:	5f                   	pop    %edi
  802175:	c9                   	leave  
  802176:	c3                   	ret    
  802177:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  802178:	8b 55 e8             	mov    -0x18(%ebp),%edx
  80217b:	89 c1                	mov    %eax,%ecx
  80217d:	2b 4d f4             	sub    -0xc(%ebp),%ecx
  802180:	1b 55 f0             	sbb    -0x10(%ebp),%edx
  802183:	eb 84                	jmp    802109 <__umoddi3+0xa1>
  802185:	8d 76 00             	lea    0x0(%esi),%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802188:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  80218b:	72 eb                	jb     802178 <__umoddi3+0x110>
  80218d:	89 f2                	mov    %esi,%edx
  80218f:	e9 75 ff ff ff       	jmp    802109 <__umoddi3+0xa1>
