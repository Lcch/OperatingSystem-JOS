
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
  800068:	e8 47 10 00 00       	call   8010b4 <ipc_send>
  80006d:	83 c4 20             	add    $0x20,%esp
	}

	while (1) {
		uint32_t i = ipc_recv(&who, 0, 0);
  800070:	8d 7d e4             	lea    -0x1c(%ebp),%edi
  800073:	83 ec 04             	sub    $0x4,%esp
  800076:	6a 00                	push   $0x0
  800078:	6a 00                	push   $0x0
  80007a:	57                   	push   %edi
  80007b:	e8 8c 0f 00 00       	call   80100c <ipc_recv>
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
  8000a8:	e8 07 10 00 00       	call   8010b4 <ipc_send>
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
  800116:	e8 53 12 00 00       	call   80136e <close_all>
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
  800224:	e8 2f 1d 00 00       	call   801f58 <__udivdi3>
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
  800260:	e8 0f 1e 00 00       	call   802074 <__umoddi3>
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
  80047e:	68 6d 27 80 00       	push   $0x80276d
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
  800b2e:	e8 05 13 00 00       	call   801e38 <_panic>

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
  800d55:	e8 de 10 00 00       	call   801e38 <_panic>

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
  800d8a:	e8 a9 10 00 00       	call   801e38 <_panic>
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
  800db4:	e8 7f 10 00 00       	call   801e38 <_panic>

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
  800dfc:	e8 37 10 00 00       	call   801e38 <_panic>

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
  800e14:	e8 67 10 00 00       	call   801e80 <set_pgfault_handler>
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
  800e34:	6a 7b                	push   $0x7b
  800e36:	68 50 26 80 00       	push   $0x802650
  800e3b:	e8 f8 0f 00 00       	call   801e38 <_panic>
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
  800e66:	e9 7b 01 00 00       	jmp    800fe6 <fork+0x1e0>
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
  800e7e:	0f 84 cd 00 00 00    	je     800f51 <fork+0x14b>
  800e84:	89 d8                	mov    %ebx,%eax
  800e86:	c1 e8 0c             	shr    $0xc,%eax
  800e89:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800e90:	f6 c2 01             	test   $0x1,%dl
  800e93:	0f 84 b8 00 00 00    	je     800f51 <fork+0x14b>
  800e99:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800ea0:	f6 c2 04             	test   $0x4,%dl
  800ea3:	0f 84 a8 00 00 00    	je     800f51 <fork+0x14b>
//
static int
duppage(envid_t envid, unsigned pn)
{
	// do not dup exception stack
	if (pn * PGSIZE == UXSTACKTOP - PGSIZE) return 0;
  800ea9:	89 c6                	mov    %eax,%esi
  800eab:	c1 e6 0c             	shl    $0xc,%esi
  800eae:	81 fe 00 f0 bf ee    	cmp    $0xeebff000,%esi
  800eb4:	0f 84 97 00 00 00    	je     800f51 <fork+0x14b>

	int r;
	void * addr = (void *)(pn * PGSIZE);
	if ((uvpt[pn] & PTE_W) || (uvpt[pn] & PTE_COW)) {
  800eba:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800ec1:	f6 c2 02             	test   $0x2,%dl
  800ec4:	75 0c                	jne    800ed2 <fork+0xcc>
  800ec6:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800ecd:	f6 c4 08             	test   $0x8,%ah
  800ed0:	74 57                	je     800f29 <fork+0x123>
		// cow
		r = sys_page_map(0, addr, envid, addr, PTE_COW | PTE_P | PTE_U);
  800ed2:	83 ec 0c             	sub    $0xc,%esp
  800ed5:	68 05 08 00 00       	push   $0x805
  800eda:	56                   	push   %esi
  800edb:	57                   	push   %edi
  800edc:	56                   	push   %esi
  800edd:	6a 00                	push   $0x0
  800edf:	e8 34 fd ff ff       	call   800c18 <sys_page_map>
		if (r < 0) panic("duppage sys_page_map error : %e\n", r);
  800ee4:	83 c4 20             	add    $0x20,%esp
  800ee7:	85 c0                	test   %eax,%eax
  800ee9:	79 12                	jns    800efd <fork+0xf7>
  800eeb:	50                   	push   %eax
  800eec:	68 9c 25 80 00       	push   $0x80259c
  800ef1:	6a 55                	push   $0x55
  800ef3:	68 50 26 80 00       	push   $0x802650
  800ef8:	e8 3b 0f 00 00       	call   801e38 <_panic>
		
		r = sys_page_map(0, addr, 0, addr, PTE_COW | PTE_P | PTE_U);
  800efd:	83 ec 0c             	sub    $0xc,%esp
  800f00:	68 05 08 00 00       	push   $0x805
  800f05:	56                   	push   %esi
  800f06:	6a 00                	push   $0x0
  800f08:	56                   	push   %esi
  800f09:	6a 00                	push   $0x0
  800f0b:	e8 08 fd ff ff       	call   800c18 <sys_page_map>
		if (r < 0) panic("duppage sys_page_map error : %e\n", r);
  800f10:	83 c4 20             	add    $0x20,%esp
  800f13:	85 c0                	test   %eax,%eax
  800f15:	79 3a                	jns    800f51 <fork+0x14b>
  800f17:	50                   	push   %eax
  800f18:	68 9c 25 80 00       	push   $0x80259c
  800f1d:	6a 58                	push   $0x58
  800f1f:	68 50 26 80 00       	push   $0x802650
  800f24:	e8 0f 0f 00 00       	call   801e38 <_panic>
	} else {
		// read only
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U);
  800f29:	83 ec 0c             	sub    $0xc,%esp
  800f2c:	6a 05                	push   $0x5
  800f2e:	56                   	push   %esi
  800f2f:	57                   	push   %edi
  800f30:	56                   	push   %esi
  800f31:	6a 00                	push   $0x0
  800f33:	e8 e0 fc ff ff       	call   800c18 <sys_page_map>
		if (r < 0) panic("duppage sys_page_map error : %e\n", r);
  800f38:	83 c4 20             	add    $0x20,%esp
  800f3b:	85 c0                	test   %eax,%eax
  800f3d:	79 12                	jns    800f51 <fork+0x14b>
  800f3f:	50                   	push   %eax
  800f40:	68 9c 25 80 00       	push   $0x80259c
  800f45:	6a 5c                	push   $0x5c
  800f47:	68 50 26 80 00       	push   $0x802650
  800f4c:	e8 e7 0e 00 00       	call   801e38 <_panic>
		return 0;
	} else {
		// map page to new environment
		// kernel page is already in new environment
		uint32_t i;
		for (i = 0; i != UTOP; i += PGSIZE) 
  800f51:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  800f57:	81 fb 00 00 c0 ee    	cmp    $0xeec00000,%ebx
  800f5d:	0f 85 0d ff ff ff    	jne    800e70 <fork+0x6a>
		if ((uvpd[PDX(i)] & PTE_P) && (uvpt[i / PGSIZE] & PTE_P) && (uvpt[i / PGSIZE] & PTE_U)) {
			duppage(childpid, i / PGSIZE);
		}

		// allocate exception stack
		r = sys_page_alloc(childpid, (void *)(UXSTACKTOP - PGSIZE), PTE_U | PTE_W | PTE_P);
  800f63:	83 ec 04             	sub    $0x4,%esp
  800f66:	6a 07                	push   $0x7
  800f68:	68 00 f0 bf ee       	push   $0xeebff000
  800f6d:	ff 75 e4             	pushl  -0x1c(%ebp)
  800f70:	e8 7f fc ff ff       	call   800bf4 <sys_page_alloc>
		if (r < 0) panic("fork, sys_page_alloc user exception stack error : %e\n", r);
  800f75:	83 c4 10             	add    $0x10,%esp
  800f78:	85 c0                	test   %eax,%eax
  800f7a:	79 15                	jns    800f91 <fork+0x18b>
  800f7c:	50                   	push   %eax
  800f7d:	68 c0 25 80 00       	push   $0x8025c0
  800f82:	68 90 00 00 00       	push   $0x90
  800f87:	68 50 26 80 00       	push   $0x802650
  800f8c:	e8 a7 0e 00 00       	call   801e38 <_panic>

		// set user environment user page fault handler 
		extern void _pgfault_upcall(void);
		r = sys_env_set_pgfault_upcall(childpid, _pgfault_upcall);
  800f91:	83 ec 08             	sub    $0x8,%esp
  800f94:	68 ec 1e 80 00       	push   $0x801eec
  800f99:	ff 75 e4             	pushl  -0x1c(%ebp)
  800f9c:	e8 06 fd ff ff       	call   800ca7 <sys_env_set_pgfault_upcall>
		if (r < 0) panic("fork, set pgfault upcall fail : %e\n", r);
  800fa1:	83 c4 10             	add    $0x10,%esp
  800fa4:	85 c0                	test   %eax,%eax
  800fa6:	79 15                	jns    800fbd <fork+0x1b7>
  800fa8:	50                   	push   %eax
  800fa9:	68 f8 25 80 00       	push   $0x8025f8
  800fae:	68 95 00 00 00       	push   $0x95
  800fb3:	68 50 26 80 00       	push   $0x802650
  800fb8:	e8 7b 0e 00 00       	call   801e38 <_panic>
		r = sys_set_priority(childpid, num);
		if (r < 0) panic("fork, set priority error\n");
		*/

		// mark the child as runnable and return
		r = sys_env_set_status(childpid, ENV_RUNNABLE);
  800fbd:	83 ec 08             	sub    $0x8,%esp
  800fc0:	6a 02                	push   $0x2
  800fc2:	ff 75 e4             	pushl  -0x1c(%ebp)
  800fc5:	e8 97 fc ff ff       	call   800c61 <sys_env_set_status>
		if (r < 0) panic("fork, set child process to ENV_RUNNABLE error : %e\n", r);
  800fca:	83 c4 10             	add    $0x10,%esp
  800fcd:	85 c0                	test   %eax,%eax
  800fcf:	79 15                	jns    800fe6 <fork+0x1e0>
  800fd1:	50                   	push   %eax
  800fd2:	68 1c 26 80 00       	push   $0x80261c
  800fd7:	68 a0 00 00 00       	push   $0xa0
  800fdc:	68 50 26 80 00       	push   $0x802650
  800fe1:	e8 52 0e 00 00       	call   801e38 <_panic>
		// cprintf("fork father ok!")
		return childpid;
	}

	panic("fork not implemented");
}
  800fe6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800fe9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800fec:	5b                   	pop    %ebx
  800fed:	5e                   	pop    %esi
  800fee:	5f                   	pop    %edi
  800fef:	c9                   	leave  
  800ff0:	c3                   	ret    

00800ff1 <sfork>:

// Challenge!
int
sfork(void)
{
  800ff1:	55                   	push   %ebp
  800ff2:	89 e5                	mov    %esp,%ebp
  800ff4:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  800ff7:	68 78 26 80 00       	push   $0x802678
  800ffc:	68 ad 00 00 00       	push   $0xad
  801001:	68 50 26 80 00       	push   $0x802650
  801006:	e8 2d 0e 00 00       	call   801e38 <_panic>
	...

0080100c <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  80100c:	55                   	push   %ebp
  80100d:	89 e5                	mov    %esp,%ebp
  80100f:	57                   	push   %edi
  801010:	56                   	push   %esi
  801011:	53                   	push   %ebx
  801012:	83 ec 0c             	sub    $0xc,%esp
  801015:	8b 7d 08             	mov    0x8(%ebp),%edi
  801018:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80101b:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	cprintf("0x%x 0x%x 0x%x\n", (uint32_t)from_env_store, (uint32_t)pg, (uint32_t)perm_store);
  80101e:	56                   	push   %esi
  80101f:	53                   	push   %ebx
  801020:	57                   	push   %edi
  801021:	68 8e 26 80 00       	push   $0x80268e
  801026:	e8 91 f1 ff ff       	call   8001bc <cprintf>
	int r;
	if (pg != NULL) {
  80102b:	83 c4 10             	add    $0x10,%esp
  80102e:	85 db                	test   %ebx,%ebx
  801030:	74 28                	je     80105a <ipc_recv+0x4e>
		cprintf("BEGIN\n");
  801032:	83 ec 0c             	sub    $0xc,%esp
  801035:	68 9e 26 80 00       	push   $0x80269e
  80103a:	e8 7d f1 ff ff       	call   8001bc <cprintf>
		r = sys_ipc_recv(pg);
  80103f:	89 1c 24             	mov    %ebx,(%esp)
  801042:	e8 a8 fc ff ff       	call   800cef <sys_ipc_recv>
  801047:	89 c3                	mov    %eax,%ebx
		cprintf("OVER\n");
  801049:	c7 04 24 a5 26 80 00 	movl   $0x8026a5,(%esp)
  801050:	e8 67 f1 ff ff       	call   8001bc <cprintf>
  801055:	83 c4 10             	add    $0x10,%esp
  801058:	eb 12                	jmp    80106c <ipc_recv+0x60>
	} else {
		r = sys_ipc_recv((void *)UTOP);
  80105a:	83 ec 0c             	sub    $0xc,%esp
  80105d:	68 00 00 c0 ee       	push   $0xeec00000
  801062:	e8 88 fc ff ff       	call   800cef <sys_ipc_recv>
  801067:	89 c3                	mov    %eax,%ebx
  801069:	83 c4 10             	add    $0x10,%esp
	}

	if (r == 0) {
  80106c:	85 db                	test   %ebx,%ebx
  80106e:	75 26                	jne    801096 <ipc_recv+0x8a>
		if (from_env_store != NULL) *from_env_store = thisenv->env_ipc_from;
  801070:	85 ff                	test   %edi,%edi
  801072:	74 0a                	je     80107e <ipc_recv+0x72>
  801074:	a1 04 40 80 00       	mov    0x804004,%eax
  801079:	8b 40 74             	mov    0x74(%eax),%eax
  80107c:	89 07                	mov    %eax,(%edi)
		if (perm_store != NULL) *perm_store = thisenv->env_ipc_perm;
  80107e:	85 f6                	test   %esi,%esi
  801080:	74 0a                	je     80108c <ipc_recv+0x80>
  801082:	a1 04 40 80 00       	mov    0x804004,%eax
  801087:	8b 40 78             	mov    0x78(%eax),%eax
  80108a:	89 06                	mov    %eax,(%esi)
		return thisenv->env_ipc_value;
  80108c:	a1 04 40 80 00       	mov    0x804004,%eax
  801091:	8b 58 70             	mov    0x70(%eax),%ebx
  801094:	eb 14                	jmp    8010aa <ipc_recv+0x9e>
	} else {
		// fails;
		if (from_env_store != NULL) *from_env_store = 0;
  801096:	85 ff                	test   %edi,%edi
  801098:	74 06                	je     8010a0 <ipc_recv+0x94>
  80109a:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
		if (perm_store != NULL) *perm_store = 0;
  8010a0:	85 f6                	test   %esi,%esi
  8010a2:	74 06                	je     8010aa <ipc_recv+0x9e>
  8010a4:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		return r;
	}
}
  8010aa:	89 d8                	mov    %ebx,%eax
  8010ac:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010af:	5b                   	pop    %ebx
  8010b0:	5e                   	pop    %esi
  8010b1:	5f                   	pop    %edi
  8010b2:	c9                   	leave  
  8010b3:	c3                   	ret    

008010b4 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8010b4:	55                   	push   %ebp
  8010b5:	89 e5                	mov    %esp,%ebp
  8010b7:	57                   	push   %edi
  8010b8:	56                   	push   %esi
  8010b9:	53                   	push   %ebx
  8010ba:	83 ec 0c             	sub    $0xc,%esp
  8010bd:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8010c0:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8010c3:	8b 75 14             	mov    0x14(%ebp),%esi
	// LAB 4: Your code here.
	// int sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
	int r;
	if (pg == NULL) pg = (void *)UTOP;
  8010c6:	85 db                	test   %ebx,%ebx
  8010c8:	75 25                	jne    8010ef <ipc_send+0x3b>
  8010ca:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
  8010cf:	eb 1e                	jmp    8010ef <ipc_send+0x3b>
	
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) != 0) {
		if (r == -E_IPC_NOT_RECV) {
  8010d1:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8010d4:	75 07                	jne    8010dd <ipc_send+0x29>
			// cprintf("Try Again and Again....\n");
			sys_yield();
  8010d6:	e8 f2 fa ff ff       	call   800bcd <sys_yield>
  8010db:	eb 12                	jmp    8010ef <ipc_send+0x3b>
		} else {
			panic("ipc_send error %e\n", r);
  8010dd:	50                   	push   %eax
  8010de:	68 ab 26 80 00       	push   $0x8026ab
  8010e3:	6a 45                	push   $0x45
  8010e5:	68 be 26 80 00       	push   $0x8026be
  8010ea:	e8 49 0d 00 00       	call   801e38 <_panic>
	// LAB 4: Your code here.
	// int sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
	int r;
	if (pg == NULL) pg = (void *)UTOP;
	
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) != 0) {
  8010ef:	56                   	push   %esi
  8010f0:	53                   	push   %ebx
  8010f1:	57                   	push   %edi
  8010f2:	ff 75 08             	pushl  0x8(%ebp)
  8010f5:	e8 d0 fb ff ff       	call   800cca <sys_ipc_try_send>
  8010fa:	83 c4 10             	add    $0x10,%esp
  8010fd:	85 c0                	test   %eax,%eax
  8010ff:	75 d0                	jne    8010d1 <ipc_send+0x1d>
		} else {
			panic("ipc_send error %e\n", r);
		}
	}
	return;
}
  801101:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801104:	5b                   	pop    %ebx
  801105:	5e                   	pop    %esi
  801106:	5f                   	pop    %edi
  801107:	c9                   	leave  
  801108:	c3                   	ret    

00801109 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801109:	55                   	push   %ebp
  80110a:	89 e5                	mov    %esp,%ebp
  80110c:	53                   	push   %ebx
  80110d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  801110:	39 1d 50 00 c0 ee    	cmp    %ebx,0xeec00050
  801116:	74 22                	je     80113a <ipc_find_env+0x31>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801118:	b8 01 00 00 00       	mov    $0x1,%eax
		if (envs[i].env_type == type)
  80111d:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  801124:	89 c2                	mov    %eax,%edx
  801126:	c1 e2 07             	shl    $0x7,%edx
  801129:	29 ca                	sub    %ecx,%edx
  80112b:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801131:	8b 52 50             	mov    0x50(%edx),%edx
  801134:	39 da                	cmp    %ebx,%edx
  801136:	75 1d                	jne    801155 <ipc_find_env+0x4c>
  801138:	eb 05                	jmp    80113f <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80113a:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
			return envs[i].env_id;
  80113f:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  801146:	c1 e0 07             	shl    $0x7,%eax
  801149:	29 d0                	sub    %edx,%eax
  80114b:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  801150:	8b 40 40             	mov    0x40(%eax),%eax
  801153:	eb 0c                	jmp    801161 <ipc_find_env+0x58>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801155:	40                   	inc    %eax
  801156:	3d 00 04 00 00       	cmp    $0x400,%eax
  80115b:	75 c0                	jne    80111d <ipc_find_env+0x14>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  80115d:	66 b8 00 00          	mov    $0x0,%ax
}
  801161:	5b                   	pop    %ebx
  801162:	c9                   	leave  
  801163:	c3                   	ret    

00801164 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801164:	55                   	push   %ebp
  801165:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801167:	8b 45 08             	mov    0x8(%ebp),%eax
  80116a:	05 00 00 00 30       	add    $0x30000000,%eax
  80116f:	c1 e8 0c             	shr    $0xc,%eax
}
  801172:	c9                   	leave  
  801173:	c3                   	ret    

00801174 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801174:	55                   	push   %ebp
  801175:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  801177:	ff 75 08             	pushl  0x8(%ebp)
  80117a:	e8 e5 ff ff ff       	call   801164 <fd2num>
  80117f:	83 c4 04             	add    $0x4,%esp
  801182:	05 20 00 0d 00       	add    $0xd0020,%eax
  801187:	c1 e0 0c             	shl    $0xc,%eax
}
  80118a:	c9                   	leave  
  80118b:	c3                   	ret    

0080118c <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80118c:	55                   	push   %ebp
  80118d:	89 e5                	mov    %esp,%ebp
  80118f:	53                   	push   %ebx
  801190:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801193:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  801198:	a8 01                	test   $0x1,%al
  80119a:	74 34                	je     8011d0 <fd_alloc+0x44>
  80119c:	a1 00 00 74 ef       	mov    0xef740000,%eax
  8011a1:	a8 01                	test   $0x1,%al
  8011a3:	74 32                	je     8011d7 <fd_alloc+0x4b>
  8011a5:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
  8011aa:	89 c1                	mov    %eax,%ecx
  8011ac:	89 c2                	mov    %eax,%edx
  8011ae:	c1 ea 16             	shr    $0x16,%edx
  8011b1:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8011b8:	f6 c2 01             	test   $0x1,%dl
  8011bb:	74 1f                	je     8011dc <fd_alloc+0x50>
  8011bd:	89 c2                	mov    %eax,%edx
  8011bf:	c1 ea 0c             	shr    $0xc,%edx
  8011c2:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8011c9:	f6 c2 01             	test   $0x1,%dl
  8011cc:	75 17                	jne    8011e5 <fd_alloc+0x59>
  8011ce:	eb 0c                	jmp    8011dc <fd_alloc+0x50>
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  8011d0:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
  8011d5:	eb 05                	jmp    8011dc <fd_alloc+0x50>
  8011d7:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
  8011dc:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  8011de:	b8 00 00 00 00       	mov    $0x0,%eax
  8011e3:	eb 17                	jmp    8011fc <fd_alloc+0x70>
  8011e5:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8011ea:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8011ef:	75 b9                	jne    8011aa <fd_alloc+0x1e>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8011f1:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  8011f7:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8011fc:	5b                   	pop    %ebx
  8011fd:	c9                   	leave  
  8011fe:	c3                   	ret    

008011ff <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8011ff:	55                   	push   %ebp
  801200:	89 e5                	mov    %esp,%ebp
  801202:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801205:	83 f8 1f             	cmp    $0x1f,%eax
  801208:	77 36                	ja     801240 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80120a:	05 00 00 0d 00       	add    $0xd0000,%eax
  80120f:	c1 e0 0c             	shl    $0xc,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801212:	89 c2                	mov    %eax,%edx
  801214:	c1 ea 16             	shr    $0x16,%edx
  801217:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80121e:	f6 c2 01             	test   $0x1,%dl
  801221:	74 24                	je     801247 <fd_lookup+0x48>
  801223:	89 c2                	mov    %eax,%edx
  801225:	c1 ea 0c             	shr    $0xc,%edx
  801228:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80122f:	f6 c2 01             	test   $0x1,%dl
  801232:	74 1a                	je     80124e <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801234:	8b 55 0c             	mov    0xc(%ebp),%edx
  801237:	89 02                	mov    %eax,(%edx)
	return 0;
  801239:	b8 00 00 00 00       	mov    $0x0,%eax
  80123e:	eb 13                	jmp    801253 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801240:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801245:	eb 0c                	jmp    801253 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801247:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80124c:	eb 05                	jmp    801253 <fd_lookup+0x54>
  80124e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801253:	c9                   	leave  
  801254:	c3                   	ret    

00801255 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801255:	55                   	push   %ebp
  801256:	89 e5                	mov    %esp,%ebp
  801258:	53                   	push   %ebx
  801259:	83 ec 04             	sub    $0x4,%esp
  80125c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80125f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  801262:	39 0d 04 30 80 00    	cmp    %ecx,0x803004
  801268:	74 0d                	je     801277 <dev_lookup+0x22>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80126a:	b8 00 00 00 00       	mov    $0x0,%eax
  80126f:	eb 14                	jmp    801285 <dev_lookup+0x30>
		if (devtab[i]->dev_id == dev_id) {
  801271:	39 0a                	cmp    %ecx,(%edx)
  801273:	75 10                	jne    801285 <dev_lookup+0x30>
  801275:	eb 05                	jmp    80127c <dev_lookup+0x27>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801277:	ba 04 30 80 00       	mov    $0x803004,%edx
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
  80127c:	89 13                	mov    %edx,(%ebx)
			return 0;
  80127e:	b8 00 00 00 00       	mov    $0x0,%eax
  801283:	eb 31                	jmp    8012b6 <dev_lookup+0x61>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801285:	40                   	inc    %eax
  801286:	8b 14 85 44 27 80 00 	mov    0x802744(,%eax,4),%edx
  80128d:	85 d2                	test   %edx,%edx
  80128f:	75 e0                	jne    801271 <dev_lookup+0x1c>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801291:	a1 04 40 80 00       	mov    0x804004,%eax
  801296:	8b 40 48             	mov    0x48(%eax),%eax
  801299:	83 ec 04             	sub    $0x4,%esp
  80129c:	51                   	push   %ecx
  80129d:	50                   	push   %eax
  80129e:	68 c8 26 80 00       	push   $0x8026c8
  8012a3:	e8 14 ef ff ff       	call   8001bc <cprintf>
	*dev = 0;
  8012a8:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  8012ae:	83 c4 10             	add    $0x10,%esp
  8012b1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8012b6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012b9:	c9                   	leave  
  8012ba:	c3                   	ret    

008012bb <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8012bb:	55                   	push   %ebp
  8012bc:	89 e5                	mov    %esp,%ebp
  8012be:	56                   	push   %esi
  8012bf:	53                   	push   %ebx
  8012c0:	83 ec 20             	sub    $0x20,%esp
  8012c3:	8b 75 08             	mov    0x8(%ebp),%esi
  8012c6:	8a 45 0c             	mov    0xc(%ebp),%al
  8012c9:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8012cc:	56                   	push   %esi
  8012cd:	e8 92 fe ff ff       	call   801164 <fd2num>
  8012d2:	8d 55 f4             	lea    -0xc(%ebp),%edx
  8012d5:	89 14 24             	mov    %edx,(%esp)
  8012d8:	50                   	push   %eax
  8012d9:	e8 21 ff ff ff       	call   8011ff <fd_lookup>
  8012de:	89 c3                	mov    %eax,%ebx
  8012e0:	83 c4 08             	add    $0x8,%esp
  8012e3:	85 c0                	test   %eax,%eax
  8012e5:	78 05                	js     8012ec <fd_close+0x31>
	    || fd != fd2)
  8012e7:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8012ea:	74 0d                	je     8012f9 <fd_close+0x3e>
		return (must_exist ? r : 0);
  8012ec:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  8012f0:	75 48                	jne    80133a <fd_close+0x7f>
  8012f2:	bb 00 00 00 00       	mov    $0x0,%ebx
  8012f7:	eb 41                	jmp    80133a <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8012f9:	83 ec 08             	sub    $0x8,%esp
  8012fc:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012ff:	50                   	push   %eax
  801300:	ff 36                	pushl  (%esi)
  801302:	e8 4e ff ff ff       	call   801255 <dev_lookup>
  801307:	89 c3                	mov    %eax,%ebx
  801309:	83 c4 10             	add    $0x10,%esp
  80130c:	85 c0                	test   %eax,%eax
  80130e:	78 1c                	js     80132c <fd_close+0x71>
		if (dev->dev_close)
  801310:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801313:	8b 40 10             	mov    0x10(%eax),%eax
  801316:	85 c0                	test   %eax,%eax
  801318:	74 0d                	je     801327 <fd_close+0x6c>
			r = (*dev->dev_close)(fd);
  80131a:	83 ec 0c             	sub    $0xc,%esp
  80131d:	56                   	push   %esi
  80131e:	ff d0                	call   *%eax
  801320:	89 c3                	mov    %eax,%ebx
  801322:	83 c4 10             	add    $0x10,%esp
  801325:	eb 05                	jmp    80132c <fd_close+0x71>
		else
			r = 0;
  801327:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  80132c:	83 ec 08             	sub    $0x8,%esp
  80132f:	56                   	push   %esi
  801330:	6a 00                	push   $0x0
  801332:	e8 07 f9 ff ff       	call   800c3e <sys_page_unmap>
	return r;
  801337:	83 c4 10             	add    $0x10,%esp
}
  80133a:	89 d8                	mov    %ebx,%eax
  80133c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80133f:	5b                   	pop    %ebx
  801340:	5e                   	pop    %esi
  801341:	c9                   	leave  
  801342:	c3                   	ret    

00801343 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801343:	55                   	push   %ebp
  801344:	89 e5                	mov    %esp,%ebp
  801346:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801349:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80134c:	50                   	push   %eax
  80134d:	ff 75 08             	pushl  0x8(%ebp)
  801350:	e8 aa fe ff ff       	call   8011ff <fd_lookup>
  801355:	83 c4 08             	add    $0x8,%esp
  801358:	85 c0                	test   %eax,%eax
  80135a:	78 10                	js     80136c <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  80135c:	83 ec 08             	sub    $0x8,%esp
  80135f:	6a 01                	push   $0x1
  801361:	ff 75 f4             	pushl  -0xc(%ebp)
  801364:	e8 52 ff ff ff       	call   8012bb <fd_close>
  801369:	83 c4 10             	add    $0x10,%esp
}
  80136c:	c9                   	leave  
  80136d:	c3                   	ret    

0080136e <close_all>:

void
close_all(void)
{
  80136e:	55                   	push   %ebp
  80136f:	89 e5                	mov    %esp,%ebp
  801371:	53                   	push   %ebx
  801372:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801375:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80137a:	83 ec 0c             	sub    $0xc,%esp
  80137d:	53                   	push   %ebx
  80137e:	e8 c0 ff ff ff       	call   801343 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801383:	43                   	inc    %ebx
  801384:	83 c4 10             	add    $0x10,%esp
  801387:	83 fb 20             	cmp    $0x20,%ebx
  80138a:	75 ee                	jne    80137a <close_all+0xc>
		close(i);
}
  80138c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80138f:	c9                   	leave  
  801390:	c3                   	ret    

00801391 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801391:	55                   	push   %ebp
  801392:	89 e5                	mov    %esp,%ebp
  801394:	57                   	push   %edi
  801395:	56                   	push   %esi
  801396:	53                   	push   %ebx
  801397:	83 ec 2c             	sub    $0x2c,%esp
  80139a:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80139d:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8013a0:	50                   	push   %eax
  8013a1:	ff 75 08             	pushl  0x8(%ebp)
  8013a4:	e8 56 fe ff ff       	call   8011ff <fd_lookup>
  8013a9:	89 c3                	mov    %eax,%ebx
  8013ab:	83 c4 08             	add    $0x8,%esp
  8013ae:	85 c0                	test   %eax,%eax
  8013b0:	0f 88 c0 00 00 00    	js     801476 <dup+0xe5>
		return r;
	close(newfdnum);
  8013b6:	83 ec 0c             	sub    $0xc,%esp
  8013b9:	57                   	push   %edi
  8013ba:	e8 84 ff ff ff       	call   801343 <close>

	newfd = INDEX2FD(newfdnum);
  8013bf:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  8013c5:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  8013c8:	83 c4 04             	add    $0x4,%esp
  8013cb:	ff 75 e4             	pushl  -0x1c(%ebp)
  8013ce:	e8 a1 fd ff ff       	call   801174 <fd2data>
  8013d3:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  8013d5:	89 34 24             	mov    %esi,(%esp)
  8013d8:	e8 97 fd ff ff       	call   801174 <fd2data>
  8013dd:	83 c4 10             	add    $0x10,%esp
  8013e0:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8013e3:	89 d8                	mov    %ebx,%eax
  8013e5:	c1 e8 16             	shr    $0x16,%eax
  8013e8:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8013ef:	a8 01                	test   $0x1,%al
  8013f1:	74 37                	je     80142a <dup+0x99>
  8013f3:	89 d8                	mov    %ebx,%eax
  8013f5:	c1 e8 0c             	shr    $0xc,%eax
  8013f8:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8013ff:	f6 c2 01             	test   $0x1,%dl
  801402:	74 26                	je     80142a <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801404:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80140b:	83 ec 0c             	sub    $0xc,%esp
  80140e:	25 07 0e 00 00       	and    $0xe07,%eax
  801413:	50                   	push   %eax
  801414:	ff 75 d4             	pushl  -0x2c(%ebp)
  801417:	6a 00                	push   $0x0
  801419:	53                   	push   %ebx
  80141a:	6a 00                	push   $0x0
  80141c:	e8 f7 f7 ff ff       	call   800c18 <sys_page_map>
  801421:	89 c3                	mov    %eax,%ebx
  801423:	83 c4 20             	add    $0x20,%esp
  801426:	85 c0                	test   %eax,%eax
  801428:	78 2d                	js     801457 <dup+0xc6>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80142a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80142d:	89 c2                	mov    %eax,%edx
  80142f:	c1 ea 0c             	shr    $0xc,%edx
  801432:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801439:	83 ec 0c             	sub    $0xc,%esp
  80143c:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  801442:	52                   	push   %edx
  801443:	56                   	push   %esi
  801444:	6a 00                	push   $0x0
  801446:	50                   	push   %eax
  801447:	6a 00                	push   $0x0
  801449:	e8 ca f7 ff ff       	call   800c18 <sys_page_map>
  80144e:	89 c3                	mov    %eax,%ebx
  801450:	83 c4 20             	add    $0x20,%esp
  801453:	85 c0                	test   %eax,%eax
  801455:	79 1d                	jns    801474 <dup+0xe3>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801457:	83 ec 08             	sub    $0x8,%esp
  80145a:	56                   	push   %esi
  80145b:	6a 00                	push   $0x0
  80145d:	e8 dc f7 ff ff       	call   800c3e <sys_page_unmap>
	sys_page_unmap(0, nva);
  801462:	83 c4 08             	add    $0x8,%esp
  801465:	ff 75 d4             	pushl  -0x2c(%ebp)
  801468:	6a 00                	push   $0x0
  80146a:	e8 cf f7 ff ff       	call   800c3e <sys_page_unmap>
	return r;
  80146f:	83 c4 10             	add    $0x10,%esp
  801472:	eb 02                	jmp    801476 <dup+0xe5>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  801474:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  801476:	89 d8                	mov    %ebx,%eax
  801478:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80147b:	5b                   	pop    %ebx
  80147c:	5e                   	pop    %esi
  80147d:	5f                   	pop    %edi
  80147e:	c9                   	leave  
  80147f:	c3                   	ret    

00801480 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801480:	55                   	push   %ebp
  801481:	89 e5                	mov    %esp,%ebp
  801483:	53                   	push   %ebx
  801484:	83 ec 14             	sub    $0x14,%esp
  801487:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80148a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80148d:	50                   	push   %eax
  80148e:	53                   	push   %ebx
  80148f:	e8 6b fd ff ff       	call   8011ff <fd_lookup>
  801494:	83 c4 08             	add    $0x8,%esp
  801497:	85 c0                	test   %eax,%eax
  801499:	78 67                	js     801502 <read+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80149b:	83 ec 08             	sub    $0x8,%esp
  80149e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014a1:	50                   	push   %eax
  8014a2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014a5:	ff 30                	pushl  (%eax)
  8014a7:	e8 a9 fd ff ff       	call   801255 <dev_lookup>
  8014ac:	83 c4 10             	add    $0x10,%esp
  8014af:	85 c0                	test   %eax,%eax
  8014b1:	78 4f                	js     801502 <read+0x82>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8014b3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014b6:	8b 50 08             	mov    0x8(%eax),%edx
  8014b9:	83 e2 03             	and    $0x3,%edx
  8014bc:	83 fa 01             	cmp    $0x1,%edx
  8014bf:	75 21                	jne    8014e2 <read+0x62>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8014c1:	a1 04 40 80 00       	mov    0x804004,%eax
  8014c6:	8b 40 48             	mov    0x48(%eax),%eax
  8014c9:	83 ec 04             	sub    $0x4,%esp
  8014cc:	53                   	push   %ebx
  8014cd:	50                   	push   %eax
  8014ce:	68 09 27 80 00       	push   $0x802709
  8014d3:	e8 e4 ec ff ff       	call   8001bc <cprintf>
		return -E_INVAL;
  8014d8:	83 c4 10             	add    $0x10,%esp
  8014db:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8014e0:	eb 20                	jmp    801502 <read+0x82>
	}
	if (!dev->dev_read)
  8014e2:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8014e5:	8b 52 08             	mov    0x8(%edx),%edx
  8014e8:	85 d2                	test   %edx,%edx
  8014ea:	74 11                	je     8014fd <read+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8014ec:	83 ec 04             	sub    $0x4,%esp
  8014ef:	ff 75 10             	pushl  0x10(%ebp)
  8014f2:	ff 75 0c             	pushl  0xc(%ebp)
  8014f5:	50                   	push   %eax
  8014f6:	ff d2                	call   *%edx
  8014f8:	83 c4 10             	add    $0x10,%esp
  8014fb:	eb 05                	jmp    801502 <read+0x82>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8014fd:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  801502:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801505:	c9                   	leave  
  801506:	c3                   	ret    

00801507 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801507:	55                   	push   %ebp
  801508:	89 e5                	mov    %esp,%ebp
  80150a:	57                   	push   %edi
  80150b:	56                   	push   %esi
  80150c:	53                   	push   %ebx
  80150d:	83 ec 0c             	sub    $0xc,%esp
  801510:	8b 7d 08             	mov    0x8(%ebp),%edi
  801513:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801516:	85 f6                	test   %esi,%esi
  801518:	74 31                	je     80154b <readn+0x44>
  80151a:	b8 00 00 00 00       	mov    $0x0,%eax
  80151f:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = read(fdnum, (char*)buf + tot, n - tot);
  801524:	83 ec 04             	sub    $0x4,%esp
  801527:	89 f2                	mov    %esi,%edx
  801529:	29 c2                	sub    %eax,%edx
  80152b:	52                   	push   %edx
  80152c:	03 45 0c             	add    0xc(%ebp),%eax
  80152f:	50                   	push   %eax
  801530:	57                   	push   %edi
  801531:	e8 4a ff ff ff       	call   801480 <read>
		if (m < 0)
  801536:	83 c4 10             	add    $0x10,%esp
  801539:	85 c0                	test   %eax,%eax
  80153b:	78 17                	js     801554 <readn+0x4d>
			return m;
		if (m == 0)
  80153d:	85 c0                	test   %eax,%eax
  80153f:	74 11                	je     801552 <readn+0x4b>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801541:	01 c3                	add    %eax,%ebx
  801543:	89 d8                	mov    %ebx,%eax
  801545:	39 f3                	cmp    %esi,%ebx
  801547:	72 db                	jb     801524 <readn+0x1d>
  801549:	eb 09                	jmp    801554 <readn+0x4d>
  80154b:	b8 00 00 00 00       	mov    $0x0,%eax
  801550:	eb 02                	jmp    801554 <readn+0x4d>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  801552:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  801554:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801557:	5b                   	pop    %ebx
  801558:	5e                   	pop    %esi
  801559:	5f                   	pop    %edi
  80155a:	c9                   	leave  
  80155b:	c3                   	ret    

0080155c <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80155c:	55                   	push   %ebp
  80155d:	89 e5                	mov    %esp,%ebp
  80155f:	53                   	push   %ebx
  801560:	83 ec 14             	sub    $0x14,%esp
  801563:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801566:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801569:	50                   	push   %eax
  80156a:	53                   	push   %ebx
  80156b:	e8 8f fc ff ff       	call   8011ff <fd_lookup>
  801570:	83 c4 08             	add    $0x8,%esp
  801573:	85 c0                	test   %eax,%eax
  801575:	78 62                	js     8015d9 <write+0x7d>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801577:	83 ec 08             	sub    $0x8,%esp
  80157a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80157d:	50                   	push   %eax
  80157e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801581:	ff 30                	pushl  (%eax)
  801583:	e8 cd fc ff ff       	call   801255 <dev_lookup>
  801588:	83 c4 10             	add    $0x10,%esp
  80158b:	85 c0                	test   %eax,%eax
  80158d:	78 4a                	js     8015d9 <write+0x7d>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80158f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801592:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801596:	75 21                	jne    8015b9 <write+0x5d>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801598:	a1 04 40 80 00       	mov    0x804004,%eax
  80159d:	8b 40 48             	mov    0x48(%eax),%eax
  8015a0:	83 ec 04             	sub    $0x4,%esp
  8015a3:	53                   	push   %ebx
  8015a4:	50                   	push   %eax
  8015a5:	68 25 27 80 00       	push   $0x802725
  8015aa:	e8 0d ec ff ff       	call   8001bc <cprintf>
		return -E_INVAL;
  8015af:	83 c4 10             	add    $0x10,%esp
  8015b2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8015b7:	eb 20                	jmp    8015d9 <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8015b9:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8015bc:	8b 52 0c             	mov    0xc(%edx),%edx
  8015bf:	85 d2                	test   %edx,%edx
  8015c1:	74 11                	je     8015d4 <write+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8015c3:	83 ec 04             	sub    $0x4,%esp
  8015c6:	ff 75 10             	pushl  0x10(%ebp)
  8015c9:	ff 75 0c             	pushl  0xc(%ebp)
  8015cc:	50                   	push   %eax
  8015cd:	ff d2                	call   *%edx
  8015cf:	83 c4 10             	add    $0x10,%esp
  8015d2:	eb 05                	jmp    8015d9 <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8015d4:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  8015d9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015dc:	c9                   	leave  
  8015dd:	c3                   	ret    

008015de <seek>:

int
seek(int fdnum, off_t offset)
{
  8015de:	55                   	push   %ebp
  8015df:	89 e5                	mov    %esp,%ebp
  8015e1:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8015e4:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8015e7:	50                   	push   %eax
  8015e8:	ff 75 08             	pushl  0x8(%ebp)
  8015eb:	e8 0f fc ff ff       	call   8011ff <fd_lookup>
  8015f0:	83 c4 08             	add    $0x8,%esp
  8015f3:	85 c0                	test   %eax,%eax
  8015f5:	78 0e                	js     801605 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8015f7:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8015fa:	8b 55 0c             	mov    0xc(%ebp),%edx
  8015fd:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801600:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801605:	c9                   	leave  
  801606:	c3                   	ret    

00801607 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801607:	55                   	push   %ebp
  801608:	89 e5                	mov    %esp,%ebp
  80160a:	53                   	push   %ebx
  80160b:	83 ec 14             	sub    $0x14,%esp
  80160e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801611:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801614:	50                   	push   %eax
  801615:	53                   	push   %ebx
  801616:	e8 e4 fb ff ff       	call   8011ff <fd_lookup>
  80161b:	83 c4 08             	add    $0x8,%esp
  80161e:	85 c0                	test   %eax,%eax
  801620:	78 5f                	js     801681 <ftruncate+0x7a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801622:	83 ec 08             	sub    $0x8,%esp
  801625:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801628:	50                   	push   %eax
  801629:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80162c:	ff 30                	pushl  (%eax)
  80162e:	e8 22 fc ff ff       	call   801255 <dev_lookup>
  801633:	83 c4 10             	add    $0x10,%esp
  801636:	85 c0                	test   %eax,%eax
  801638:	78 47                	js     801681 <ftruncate+0x7a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80163a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80163d:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801641:	75 21                	jne    801664 <ftruncate+0x5d>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801643:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801648:	8b 40 48             	mov    0x48(%eax),%eax
  80164b:	83 ec 04             	sub    $0x4,%esp
  80164e:	53                   	push   %ebx
  80164f:	50                   	push   %eax
  801650:	68 e8 26 80 00       	push   $0x8026e8
  801655:	e8 62 eb ff ff       	call   8001bc <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80165a:	83 c4 10             	add    $0x10,%esp
  80165d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801662:	eb 1d                	jmp    801681 <ftruncate+0x7a>
	}
	if (!dev->dev_trunc)
  801664:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801667:	8b 52 18             	mov    0x18(%edx),%edx
  80166a:	85 d2                	test   %edx,%edx
  80166c:	74 0e                	je     80167c <ftruncate+0x75>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80166e:	83 ec 08             	sub    $0x8,%esp
  801671:	ff 75 0c             	pushl  0xc(%ebp)
  801674:	50                   	push   %eax
  801675:	ff d2                	call   *%edx
  801677:	83 c4 10             	add    $0x10,%esp
  80167a:	eb 05                	jmp    801681 <ftruncate+0x7a>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80167c:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  801681:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801684:	c9                   	leave  
  801685:	c3                   	ret    

00801686 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801686:	55                   	push   %ebp
  801687:	89 e5                	mov    %esp,%ebp
  801689:	53                   	push   %ebx
  80168a:	83 ec 14             	sub    $0x14,%esp
  80168d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801690:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801693:	50                   	push   %eax
  801694:	ff 75 08             	pushl  0x8(%ebp)
  801697:	e8 63 fb ff ff       	call   8011ff <fd_lookup>
  80169c:	83 c4 08             	add    $0x8,%esp
  80169f:	85 c0                	test   %eax,%eax
  8016a1:	78 52                	js     8016f5 <fstat+0x6f>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016a3:	83 ec 08             	sub    $0x8,%esp
  8016a6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016a9:	50                   	push   %eax
  8016aa:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016ad:	ff 30                	pushl  (%eax)
  8016af:	e8 a1 fb ff ff       	call   801255 <dev_lookup>
  8016b4:	83 c4 10             	add    $0x10,%esp
  8016b7:	85 c0                	test   %eax,%eax
  8016b9:	78 3a                	js     8016f5 <fstat+0x6f>
		return r;
	if (!dev->dev_stat)
  8016bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016be:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8016c2:	74 2c                	je     8016f0 <fstat+0x6a>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8016c4:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8016c7:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8016ce:	00 00 00 
	stat->st_isdir = 0;
  8016d1:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8016d8:	00 00 00 
	stat->st_dev = dev;
  8016db:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8016e1:	83 ec 08             	sub    $0x8,%esp
  8016e4:	53                   	push   %ebx
  8016e5:	ff 75 f0             	pushl  -0x10(%ebp)
  8016e8:	ff 50 14             	call   *0x14(%eax)
  8016eb:	83 c4 10             	add    $0x10,%esp
  8016ee:	eb 05                	jmp    8016f5 <fstat+0x6f>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8016f0:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8016f5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016f8:	c9                   	leave  
  8016f9:	c3                   	ret    

008016fa <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8016fa:	55                   	push   %ebp
  8016fb:	89 e5                	mov    %esp,%ebp
  8016fd:	56                   	push   %esi
  8016fe:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8016ff:	83 ec 08             	sub    $0x8,%esp
  801702:	6a 00                	push   $0x0
  801704:	ff 75 08             	pushl  0x8(%ebp)
  801707:	e8 8b 01 00 00       	call   801897 <open>
  80170c:	89 c3                	mov    %eax,%ebx
  80170e:	83 c4 10             	add    $0x10,%esp
  801711:	85 c0                	test   %eax,%eax
  801713:	78 1b                	js     801730 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801715:	83 ec 08             	sub    $0x8,%esp
  801718:	ff 75 0c             	pushl  0xc(%ebp)
  80171b:	50                   	push   %eax
  80171c:	e8 65 ff ff ff       	call   801686 <fstat>
  801721:	89 c6                	mov    %eax,%esi
	close(fd);
  801723:	89 1c 24             	mov    %ebx,(%esp)
  801726:	e8 18 fc ff ff       	call   801343 <close>
	return r;
  80172b:	83 c4 10             	add    $0x10,%esp
  80172e:	89 f3                	mov    %esi,%ebx
}
  801730:	89 d8                	mov    %ebx,%eax
  801732:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801735:	5b                   	pop    %ebx
  801736:	5e                   	pop    %esi
  801737:	c9                   	leave  
  801738:	c3                   	ret    
  801739:	00 00                	add    %al,(%eax)
	...

0080173c <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80173c:	55                   	push   %ebp
  80173d:	89 e5                	mov    %esp,%ebp
  80173f:	56                   	push   %esi
  801740:	53                   	push   %ebx
  801741:	89 c3                	mov    %eax,%ebx
  801743:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  801745:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  80174c:	75 12                	jne    801760 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80174e:	83 ec 0c             	sub    $0xc,%esp
  801751:	6a 01                	push   $0x1
  801753:	e8 b1 f9 ff ff       	call   801109 <ipc_find_env>
  801758:	a3 00 40 80 00       	mov    %eax,0x804000
  80175d:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801760:	6a 07                	push   $0x7
  801762:	68 00 50 80 00       	push   $0x805000
  801767:	53                   	push   %ebx
  801768:	ff 35 00 40 80 00    	pushl  0x804000
  80176e:	e8 41 f9 ff ff       	call   8010b4 <ipc_send>
	
	return ipc_recv(NULL, dstva, NULL);
  801773:	83 c4 0c             	add    $0xc,%esp
  801776:	6a 00                	push   $0x0
  801778:	56                   	push   %esi
  801779:	6a 00                	push   $0x0
  80177b:	e8 8c f8 ff ff       	call   80100c <ipc_recv>
}
  801780:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801783:	5b                   	pop    %ebx
  801784:	5e                   	pop    %esi
  801785:	c9                   	leave  
  801786:	c3                   	ret    

00801787 <devfile_stat>:
}


static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801787:	55                   	push   %ebp
  801788:	89 e5                	mov    %esp,%ebp
  80178a:	53                   	push   %ebx
  80178b:	83 ec 04             	sub    $0x4,%esp
  80178e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801791:	8b 45 08             	mov    0x8(%ebp),%eax
  801794:	8b 40 0c             	mov    0xc(%eax),%eax
  801797:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0) {
  80179c:	ba 00 00 00 00       	mov    $0x0,%edx
  8017a1:	b8 05 00 00 00       	mov    $0x5,%eax
  8017a6:	e8 91 ff ff ff       	call   80173c <fsipc>
  8017ab:	85 c0                	test   %eax,%eax
  8017ad:	78 39                	js     8017e8 <devfile_stat+0x61>
		return r;
	}
	cprintf("OVER\n");
  8017af:	83 ec 0c             	sub    $0xc,%esp
  8017b2:	68 a5 26 80 00       	push   $0x8026a5
  8017b7:	e8 00 ea ff ff       	call   8001bc <cprintf>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8017bc:	83 c4 08             	add    $0x8,%esp
  8017bf:	68 00 50 80 00       	push   $0x805000
  8017c4:	53                   	push   %ebx
  8017c5:	e8 a8 ef ff ff       	call   800772 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8017ca:	a1 80 50 80 00       	mov    0x805080,%eax
  8017cf:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8017d5:	a1 84 50 80 00       	mov    0x805084,%eax
  8017da:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8017e0:	83 c4 10             	add    $0x10,%esp
  8017e3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8017e8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017eb:	c9                   	leave  
  8017ec:	c3                   	ret    

008017ed <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8017ed:	55                   	push   %ebp
  8017ee:	89 e5                	mov    %esp,%ebp
  8017f0:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8017f3:	8b 45 08             	mov    0x8(%ebp),%eax
  8017f6:	8b 40 0c             	mov    0xc(%eax),%eax
  8017f9:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8017fe:	ba 00 00 00 00       	mov    $0x0,%edx
  801803:	b8 06 00 00 00       	mov    $0x6,%eax
  801808:	e8 2f ff ff ff       	call   80173c <fsipc>
}
  80180d:	c9                   	leave  
  80180e:	c3                   	ret    

0080180f <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  80180f:	55                   	push   %ebp
  801810:	89 e5                	mov    %esp,%ebp
  801812:	56                   	push   %esi
  801813:	53                   	push   %ebx
  801814:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801817:	8b 45 08             	mov    0x8(%ebp),%eax
  80181a:	8b 40 0c             	mov    0xc(%eax),%eax
  80181d:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801822:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801828:	ba 00 00 00 00       	mov    $0x0,%edx
  80182d:	b8 03 00 00 00       	mov    $0x3,%eax
  801832:	e8 05 ff ff ff       	call   80173c <fsipc>
  801837:	89 c3                	mov    %eax,%ebx
  801839:	85 c0                	test   %eax,%eax
  80183b:	78 51                	js     80188e <devfile_read+0x7f>
		return r;
	assert(r <= n);
  80183d:	39 c6                	cmp    %eax,%esi
  80183f:	73 19                	jae    80185a <devfile_read+0x4b>
  801841:	68 54 27 80 00       	push   $0x802754
  801846:	68 5b 27 80 00       	push   $0x80275b
  80184b:	68 80 00 00 00       	push   $0x80
  801850:	68 70 27 80 00       	push   $0x802770
  801855:	e8 de 05 00 00       	call   801e38 <_panic>
	assert(r <= PGSIZE);
  80185a:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80185f:	7e 19                	jle    80187a <devfile_read+0x6b>
  801861:	68 7b 27 80 00       	push   $0x80277b
  801866:	68 5b 27 80 00       	push   $0x80275b
  80186b:	68 81 00 00 00       	push   $0x81
  801870:	68 70 27 80 00       	push   $0x802770
  801875:	e8 be 05 00 00       	call   801e38 <_panic>
	memmove(buf, &fsipcbuf, r);
  80187a:	83 ec 04             	sub    $0x4,%esp
  80187d:	50                   	push   %eax
  80187e:	68 00 50 80 00       	push   $0x805000
  801883:	ff 75 0c             	pushl  0xc(%ebp)
  801886:	e8 a8 f0 ff ff       	call   800933 <memmove>
	return r;
  80188b:	83 c4 10             	add    $0x10,%esp
}
  80188e:	89 d8                	mov    %ebx,%eax
  801890:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801893:	5b                   	pop    %ebx
  801894:	5e                   	pop    %esi
  801895:	c9                   	leave  
  801896:	c3                   	ret    

00801897 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801897:	55                   	push   %ebp
  801898:	89 e5                	mov    %esp,%ebp
  80189a:	56                   	push   %esi
  80189b:	53                   	push   %ebx
  80189c:	83 ec 1c             	sub    $0x1c,%esp
  80189f:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8018a2:	56                   	push   %esi
  8018a3:	e8 78 ee ff ff       	call   800720 <strlen>
  8018a8:	83 c4 10             	add    $0x10,%esp
  8018ab:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8018b0:	7f 72                	jg     801924 <open+0x8d>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8018b2:	83 ec 0c             	sub    $0xc,%esp
  8018b5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018b8:	50                   	push   %eax
  8018b9:	e8 ce f8 ff ff       	call   80118c <fd_alloc>
  8018be:	89 c3                	mov    %eax,%ebx
  8018c0:	83 c4 10             	add    $0x10,%esp
  8018c3:	85 c0                	test   %eax,%eax
  8018c5:	78 62                	js     801929 <open+0x92>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8018c7:	83 ec 08             	sub    $0x8,%esp
  8018ca:	56                   	push   %esi
  8018cb:	68 00 50 80 00       	push   $0x805000
  8018d0:	e8 9d ee ff ff       	call   800772 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8018d5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018d8:	a3 00 54 80 00       	mov    %eax,0x805400



	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8018dd:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8018e0:	b8 01 00 00 00       	mov    $0x1,%eax
  8018e5:	e8 52 fe ff ff       	call   80173c <fsipc>
  8018ea:	89 c3                	mov    %eax,%ebx
  8018ec:	83 c4 10             	add    $0x10,%esp
  8018ef:	85 c0                	test   %eax,%eax
  8018f1:	79 12                	jns    801905 <open+0x6e>
		fd_close(fd, 0);
  8018f3:	83 ec 08             	sub    $0x8,%esp
  8018f6:	6a 00                	push   $0x0
  8018f8:	ff 75 f4             	pushl  -0xc(%ebp)
  8018fb:	e8 bb f9 ff ff       	call   8012bb <fd_close>
		return r;
  801900:	83 c4 10             	add    $0x10,%esp
  801903:	eb 24                	jmp    801929 <open+0x92>
	}


	cprintf("OPEN\n");
  801905:	83 ec 0c             	sub    $0xc,%esp
  801908:	68 87 27 80 00       	push   $0x802787
  80190d:	e8 aa e8 ff ff       	call   8001bc <cprintf>

	return fd2num(fd);
  801912:	83 c4 04             	add    $0x4,%esp
  801915:	ff 75 f4             	pushl  -0xc(%ebp)
  801918:	e8 47 f8 ff ff       	call   801164 <fd2num>
  80191d:	89 c3                	mov    %eax,%ebx
  80191f:	83 c4 10             	add    $0x10,%esp
  801922:	eb 05                	jmp    801929 <open+0x92>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801924:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx


	cprintf("OPEN\n");

	return fd2num(fd);
}
  801929:	89 d8                	mov    %ebx,%eax
  80192b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80192e:	5b                   	pop    %ebx
  80192f:	5e                   	pop    %esi
  801930:	c9                   	leave  
  801931:	c3                   	ret    
	...

00801934 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801934:	55                   	push   %ebp
  801935:	89 e5                	mov    %esp,%ebp
  801937:	56                   	push   %esi
  801938:	53                   	push   %ebx
  801939:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  80193c:	83 ec 0c             	sub    $0xc,%esp
  80193f:	ff 75 08             	pushl  0x8(%ebp)
  801942:	e8 2d f8 ff ff       	call   801174 <fd2data>
  801947:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  801949:	83 c4 08             	add    $0x8,%esp
  80194c:	68 8d 27 80 00       	push   $0x80278d
  801951:	56                   	push   %esi
  801952:	e8 1b ee ff ff       	call   800772 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801957:	8b 43 04             	mov    0x4(%ebx),%eax
  80195a:	2b 03                	sub    (%ebx),%eax
  80195c:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  801962:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  801969:	00 00 00 
	stat->st_dev = &devpipe;
  80196c:	c7 86 88 00 00 00 20 	movl   $0x803020,0x88(%esi)
  801973:	30 80 00 
	return 0;
}
  801976:	b8 00 00 00 00       	mov    $0x0,%eax
  80197b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80197e:	5b                   	pop    %ebx
  80197f:	5e                   	pop    %esi
  801980:	c9                   	leave  
  801981:	c3                   	ret    

00801982 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801982:	55                   	push   %ebp
  801983:	89 e5                	mov    %esp,%ebp
  801985:	53                   	push   %ebx
  801986:	83 ec 0c             	sub    $0xc,%esp
  801989:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  80198c:	53                   	push   %ebx
  80198d:	6a 00                	push   $0x0
  80198f:	e8 aa f2 ff ff       	call   800c3e <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801994:	89 1c 24             	mov    %ebx,(%esp)
  801997:	e8 d8 f7 ff ff       	call   801174 <fd2data>
  80199c:	83 c4 08             	add    $0x8,%esp
  80199f:	50                   	push   %eax
  8019a0:	6a 00                	push   $0x0
  8019a2:	e8 97 f2 ff ff       	call   800c3e <sys_page_unmap>
}
  8019a7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019aa:	c9                   	leave  
  8019ab:	c3                   	ret    

008019ac <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8019ac:	55                   	push   %ebp
  8019ad:	89 e5                	mov    %esp,%ebp
  8019af:	57                   	push   %edi
  8019b0:	56                   	push   %esi
  8019b1:	53                   	push   %ebx
  8019b2:	83 ec 1c             	sub    $0x1c,%esp
  8019b5:	89 c7                	mov    %eax,%edi
  8019b7:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8019ba:	a1 04 40 80 00       	mov    0x804004,%eax
  8019bf:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  8019c2:	83 ec 0c             	sub    $0xc,%esp
  8019c5:	57                   	push   %edi
  8019c6:	e8 49 05 00 00       	call   801f14 <pageref>
  8019cb:	89 c6                	mov    %eax,%esi
  8019cd:	83 c4 04             	add    $0x4,%esp
  8019d0:	ff 75 e4             	pushl  -0x1c(%ebp)
  8019d3:	e8 3c 05 00 00       	call   801f14 <pageref>
  8019d8:	83 c4 10             	add    $0x10,%esp
  8019db:	39 c6                	cmp    %eax,%esi
  8019dd:	0f 94 c0             	sete   %al
  8019e0:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  8019e3:	8b 15 04 40 80 00    	mov    0x804004,%edx
  8019e9:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  8019ec:	39 cb                	cmp    %ecx,%ebx
  8019ee:	75 08                	jne    8019f8 <_pipeisclosed+0x4c>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  8019f0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8019f3:	5b                   	pop    %ebx
  8019f4:	5e                   	pop    %esi
  8019f5:	5f                   	pop    %edi
  8019f6:	c9                   	leave  
  8019f7:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  8019f8:	83 f8 01             	cmp    $0x1,%eax
  8019fb:	75 bd                	jne    8019ba <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8019fd:	8b 42 58             	mov    0x58(%edx),%eax
  801a00:	6a 01                	push   $0x1
  801a02:	50                   	push   %eax
  801a03:	53                   	push   %ebx
  801a04:	68 94 27 80 00       	push   $0x802794
  801a09:	e8 ae e7 ff ff       	call   8001bc <cprintf>
  801a0e:	83 c4 10             	add    $0x10,%esp
  801a11:	eb a7                	jmp    8019ba <_pipeisclosed+0xe>

00801a13 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801a13:	55                   	push   %ebp
  801a14:	89 e5                	mov    %esp,%ebp
  801a16:	57                   	push   %edi
  801a17:	56                   	push   %esi
  801a18:	53                   	push   %ebx
  801a19:	83 ec 28             	sub    $0x28,%esp
  801a1c:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801a1f:	56                   	push   %esi
  801a20:	e8 4f f7 ff ff       	call   801174 <fd2data>
  801a25:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801a27:	83 c4 10             	add    $0x10,%esp
  801a2a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801a2e:	75 4a                	jne    801a7a <devpipe_write+0x67>
  801a30:	bf 00 00 00 00       	mov    $0x0,%edi
  801a35:	eb 56                	jmp    801a8d <devpipe_write+0x7a>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801a37:	89 da                	mov    %ebx,%edx
  801a39:	89 f0                	mov    %esi,%eax
  801a3b:	e8 6c ff ff ff       	call   8019ac <_pipeisclosed>
  801a40:	85 c0                	test   %eax,%eax
  801a42:	75 4d                	jne    801a91 <devpipe_write+0x7e>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801a44:	e8 84 f1 ff ff       	call   800bcd <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801a49:	8b 43 04             	mov    0x4(%ebx),%eax
  801a4c:	8b 13                	mov    (%ebx),%edx
  801a4e:	83 c2 20             	add    $0x20,%edx
  801a51:	39 d0                	cmp    %edx,%eax
  801a53:	73 e2                	jae    801a37 <devpipe_write+0x24>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801a55:	89 c2                	mov    %eax,%edx
  801a57:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  801a5d:	79 05                	jns    801a64 <devpipe_write+0x51>
  801a5f:	4a                   	dec    %edx
  801a60:	83 ca e0             	or     $0xffffffe0,%edx
  801a63:	42                   	inc    %edx
  801a64:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801a67:	8a 0c 39             	mov    (%ecx,%edi,1),%cl
  801a6a:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801a6e:	40                   	inc    %eax
  801a6f:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801a72:	47                   	inc    %edi
  801a73:	39 7d 10             	cmp    %edi,0x10(%ebp)
  801a76:	77 07                	ja     801a7f <devpipe_write+0x6c>
  801a78:	eb 13                	jmp    801a8d <devpipe_write+0x7a>
  801a7a:	bf 00 00 00 00       	mov    $0x0,%edi
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801a7f:	8b 43 04             	mov    0x4(%ebx),%eax
  801a82:	8b 13                	mov    (%ebx),%edx
  801a84:	83 c2 20             	add    $0x20,%edx
  801a87:	39 d0                	cmp    %edx,%eax
  801a89:	73 ac                	jae    801a37 <devpipe_write+0x24>
  801a8b:	eb c8                	jmp    801a55 <devpipe_write+0x42>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801a8d:	89 f8                	mov    %edi,%eax
  801a8f:	eb 05                	jmp    801a96 <devpipe_write+0x83>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801a91:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801a96:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a99:	5b                   	pop    %ebx
  801a9a:	5e                   	pop    %esi
  801a9b:	5f                   	pop    %edi
  801a9c:	c9                   	leave  
  801a9d:	c3                   	ret    

00801a9e <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801a9e:	55                   	push   %ebp
  801a9f:	89 e5                	mov    %esp,%ebp
  801aa1:	57                   	push   %edi
  801aa2:	56                   	push   %esi
  801aa3:	53                   	push   %ebx
  801aa4:	83 ec 18             	sub    $0x18,%esp
  801aa7:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801aaa:	57                   	push   %edi
  801aab:	e8 c4 f6 ff ff       	call   801174 <fd2data>
  801ab0:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801ab2:	83 c4 10             	add    $0x10,%esp
  801ab5:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801ab9:	75 44                	jne    801aff <devpipe_read+0x61>
  801abb:	be 00 00 00 00       	mov    $0x0,%esi
  801ac0:	eb 4f                	jmp    801b11 <devpipe_read+0x73>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
				return i;
  801ac2:	89 f0                	mov    %esi,%eax
  801ac4:	eb 54                	jmp    801b1a <devpipe_read+0x7c>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801ac6:	89 da                	mov    %ebx,%edx
  801ac8:	89 f8                	mov    %edi,%eax
  801aca:	e8 dd fe ff ff       	call   8019ac <_pipeisclosed>
  801acf:	85 c0                	test   %eax,%eax
  801ad1:	75 42                	jne    801b15 <devpipe_read+0x77>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801ad3:	e8 f5 f0 ff ff       	call   800bcd <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801ad8:	8b 03                	mov    (%ebx),%eax
  801ada:	3b 43 04             	cmp    0x4(%ebx),%eax
  801add:	74 e7                	je     801ac6 <devpipe_read+0x28>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801adf:	25 1f 00 00 80       	and    $0x8000001f,%eax
  801ae4:	79 05                	jns    801aeb <devpipe_read+0x4d>
  801ae6:	48                   	dec    %eax
  801ae7:	83 c8 e0             	or     $0xffffffe0,%eax
  801aea:	40                   	inc    %eax
  801aeb:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  801aef:	8b 55 0c             	mov    0xc(%ebp),%edx
  801af2:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  801af5:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801af7:	46                   	inc    %esi
  801af8:	39 75 10             	cmp    %esi,0x10(%ebp)
  801afb:	77 07                	ja     801b04 <devpipe_read+0x66>
  801afd:	eb 12                	jmp    801b11 <devpipe_read+0x73>
  801aff:	be 00 00 00 00       	mov    $0x0,%esi
		while (p->p_rpos == p->p_wpos) {
  801b04:	8b 03                	mov    (%ebx),%eax
  801b06:	3b 43 04             	cmp    0x4(%ebx),%eax
  801b09:	75 d4                	jne    801adf <devpipe_read+0x41>
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801b0b:	85 f6                	test   %esi,%esi
  801b0d:	75 b3                	jne    801ac2 <devpipe_read+0x24>
  801b0f:	eb b5                	jmp    801ac6 <devpipe_read+0x28>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801b11:	89 f0                	mov    %esi,%eax
  801b13:	eb 05                	jmp    801b1a <devpipe_read+0x7c>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801b15:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801b1a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b1d:	5b                   	pop    %ebx
  801b1e:	5e                   	pop    %esi
  801b1f:	5f                   	pop    %edi
  801b20:	c9                   	leave  
  801b21:	c3                   	ret    

00801b22 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801b22:	55                   	push   %ebp
  801b23:	89 e5                	mov    %esp,%ebp
  801b25:	57                   	push   %edi
  801b26:	56                   	push   %esi
  801b27:	53                   	push   %ebx
  801b28:	83 ec 28             	sub    $0x28,%esp
  801b2b:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801b2e:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801b31:	50                   	push   %eax
  801b32:	e8 55 f6 ff ff       	call   80118c <fd_alloc>
  801b37:	89 c3                	mov    %eax,%ebx
  801b39:	83 c4 10             	add    $0x10,%esp
  801b3c:	85 c0                	test   %eax,%eax
  801b3e:	0f 88 24 01 00 00    	js     801c68 <pipe+0x146>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b44:	83 ec 04             	sub    $0x4,%esp
  801b47:	68 07 04 00 00       	push   $0x407
  801b4c:	ff 75 e4             	pushl  -0x1c(%ebp)
  801b4f:	6a 00                	push   $0x0
  801b51:	e8 9e f0 ff ff       	call   800bf4 <sys_page_alloc>
  801b56:	89 c3                	mov    %eax,%ebx
  801b58:	83 c4 10             	add    $0x10,%esp
  801b5b:	85 c0                	test   %eax,%eax
  801b5d:	0f 88 05 01 00 00    	js     801c68 <pipe+0x146>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801b63:	83 ec 0c             	sub    $0xc,%esp
  801b66:	8d 45 e0             	lea    -0x20(%ebp),%eax
  801b69:	50                   	push   %eax
  801b6a:	e8 1d f6 ff ff       	call   80118c <fd_alloc>
  801b6f:	89 c3                	mov    %eax,%ebx
  801b71:	83 c4 10             	add    $0x10,%esp
  801b74:	85 c0                	test   %eax,%eax
  801b76:	0f 88 dc 00 00 00    	js     801c58 <pipe+0x136>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b7c:	83 ec 04             	sub    $0x4,%esp
  801b7f:	68 07 04 00 00       	push   $0x407
  801b84:	ff 75 e0             	pushl  -0x20(%ebp)
  801b87:	6a 00                	push   $0x0
  801b89:	e8 66 f0 ff ff       	call   800bf4 <sys_page_alloc>
  801b8e:	89 c3                	mov    %eax,%ebx
  801b90:	83 c4 10             	add    $0x10,%esp
  801b93:	85 c0                	test   %eax,%eax
  801b95:	0f 88 bd 00 00 00    	js     801c58 <pipe+0x136>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801b9b:	83 ec 0c             	sub    $0xc,%esp
  801b9e:	ff 75 e4             	pushl  -0x1c(%ebp)
  801ba1:	e8 ce f5 ff ff       	call   801174 <fd2data>
  801ba6:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ba8:	83 c4 0c             	add    $0xc,%esp
  801bab:	68 07 04 00 00       	push   $0x407
  801bb0:	50                   	push   %eax
  801bb1:	6a 00                	push   $0x0
  801bb3:	e8 3c f0 ff ff       	call   800bf4 <sys_page_alloc>
  801bb8:	89 c3                	mov    %eax,%ebx
  801bba:	83 c4 10             	add    $0x10,%esp
  801bbd:	85 c0                	test   %eax,%eax
  801bbf:	0f 88 83 00 00 00    	js     801c48 <pipe+0x126>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801bc5:	83 ec 0c             	sub    $0xc,%esp
  801bc8:	ff 75 e0             	pushl  -0x20(%ebp)
  801bcb:	e8 a4 f5 ff ff       	call   801174 <fd2data>
  801bd0:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801bd7:	50                   	push   %eax
  801bd8:	6a 00                	push   $0x0
  801bda:	56                   	push   %esi
  801bdb:	6a 00                	push   $0x0
  801bdd:	e8 36 f0 ff ff       	call   800c18 <sys_page_map>
  801be2:	89 c3                	mov    %eax,%ebx
  801be4:	83 c4 20             	add    $0x20,%esp
  801be7:	85 c0                	test   %eax,%eax
  801be9:	78 4f                	js     801c3a <pipe+0x118>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801beb:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801bf1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801bf4:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801bf6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801bf9:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801c00:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801c06:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801c09:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801c0b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801c0e:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801c15:	83 ec 0c             	sub    $0xc,%esp
  801c18:	ff 75 e4             	pushl  -0x1c(%ebp)
  801c1b:	e8 44 f5 ff ff       	call   801164 <fd2num>
  801c20:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  801c22:	83 c4 04             	add    $0x4,%esp
  801c25:	ff 75 e0             	pushl  -0x20(%ebp)
  801c28:	e8 37 f5 ff ff       	call   801164 <fd2num>
  801c2d:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  801c30:	83 c4 10             	add    $0x10,%esp
  801c33:	bb 00 00 00 00       	mov    $0x0,%ebx
  801c38:	eb 2e                	jmp    801c68 <pipe+0x146>

    err3:
	sys_page_unmap(0, va);
  801c3a:	83 ec 08             	sub    $0x8,%esp
  801c3d:	56                   	push   %esi
  801c3e:	6a 00                	push   $0x0
  801c40:	e8 f9 ef ff ff       	call   800c3e <sys_page_unmap>
  801c45:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801c48:	83 ec 08             	sub    $0x8,%esp
  801c4b:	ff 75 e0             	pushl  -0x20(%ebp)
  801c4e:	6a 00                	push   $0x0
  801c50:	e8 e9 ef ff ff       	call   800c3e <sys_page_unmap>
  801c55:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801c58:	83 ec 08             	sub    $0x8,%esp
  801c5b:	ff 75 e4             	pushl  -0x1c(%ebp)
  801c5e:	6a 00                	push   $0x0
  801c60:	e8 d9 ef ff ff       	call   800c3e <sys_page_unmap>
  801c65:	83 c4 10             	add    $0x10,%esp
    err:
	return r;
}
  801c68:	89 d8                	mov    %ebx,%eax
  801c6a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c6d:	5b                   	pop    %ebx
  801c6e:	5e                   	pop    %esi
  801c6f:	5f                   	pop    %edi
  801c70:	c9                   	leave  
  801c71:	c3                   	ret    

00801c72 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801c72:	55                   	push   %ebp
  801c73:	89 e5                	mov    %esp,%ebp
  801c75:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801c78:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c7b:	50                   	push   %eax
  801c7c:	ff 75 08             	pushl  0x8(%ebp)
  801c7f:	e8 7b f5 ff ff       	call   8011ff <fd_lookup>
  801c84:	83 c4 10             	add    $0x10,%esp
  801c87:	85 c0                	test   %eax,%eax
  801c89:	78 18                	js     801ca3 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801c8b:	83 ec 0c             	sub    $0xc,%esp
  801c8e:	ff 75 f4             	pushl  -0xc(%ebp)
  801c91:	e8 de f4 ff ff       	call   801174 <fd2data>
	return _pipeisclosed(fd, p);
  801c96:	89 c2                	mov    %eax,%edx
  801c98:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c9b:	e8 0c fd ff ff       	call   8019ac <_pipeisclosed>
  801ca0:	83 c4 10             	add    $0x10,%esp
}
  801ca3:	c9                   	leave  
  801ca4:	c3                   	ret    
  801ca5:	00 00                	add    %al,(%eax)
	...

00801ca8 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801ca8:	55                   	push   %ebp
  801ca9:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801cab:	b8 00 00 00 00       	mov    $0x0,%eax
  801cb0:	c9                   	leave  
  801cb1:	c3                   	ret    

00801cb2 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801cb2:	55                   	push   %ebp
  801cb3:	89 e5                	mov    %esp,%ebp
  801cb5:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801cb8:	68 ac 27 80 00       	push   $0x8027ac
  801cbd:	ff 75 0c             	pushl  0xc(%ebp)
  801cc0:	e8 ad ea ff ff       	call   800772 <strcpy>
	return 0;
}
  801cc5:	b8 00 00 00 00       	mov    $0x0,%eax
  801cca:	c9                   	leave  
  801ccb:	c3                   	ret    

00801ccc <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801ccc:	55                   	push   %ebp
  801ccd:	89 e5                	mov    %esp,%ebp
  801ccf:	57                   	push   %edi
  801cd0:	56                   	push   %esi
  801cd1:	53                   	push   %ebx
  801cd2:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801cd8:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801cdc:	74 45                	je     801d23 <devcons_write+0x57>
  801cde:	b8 00 00 00 00       	mov    $0x0,%eax
  801ce3:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801ce8:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801cee:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801cf1:	29 c3                	sub    %eax,%ebx
		if (m > sizeof(buf) - 1)
  801cf3:	83 fb 7f             	cmp    $0x7f,%ebx
  801cf6:	76 05                	jbe    801cfd <devcons_write+0x31>
			m = sizeof(buf) - 1;
  801cf8:	bb 7f 00 00 00       	mov    $0x7f,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  801cfd:	83 ec 04             	sub    $0x4,%esp
  801d00:	53                   	push   %ebx
  801d01:	03 45 0c             	add    0xc(%ebp),%eax
  801d04:	50                   	push   %eax
  801d05:	57                   	push   %edi
  801d06:	e8 28 ec ff ff       	call   800933 <memmove>
		sys_cputs(buf, m);
  801d0b:	83 c4 08             	add    $0x8,%esp
  801d0e:	53                   	push   %ebx
  801d0f:	57                   	push   %edi
  801d10:	e8 28 ee ff ff       	call   800b3d <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801d15:	01 de                	add    %ebx,%esi
  801d17:	89 f0                	mov    %esi,%eax
  801d19:	83 c4 10             	add    $0x10,%esp
  801d1c:	3b 75 10             	cmp    0x10(%ebp),%esi
  801d1f:	72 cd                	jb     801cee <devcons_write+0x22>
  801d21:	eb 05                	jmp    801d28 <devcons_write+0x5c>
  801d23:	be 00 00 00 00       	mov    $0x0,%esi
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801d28:	89 f0                	mov    %esi,%eax
  801d2a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d2d:	5b                   	pop    %ebx
  801d2e:	5e                   	pop    %esi
  801d2f:	5f                   	pop    %edi
  801d30:	c9                   	leave  
  801d31:	c3                   	ret    

00801d32 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801d32:	55                   	push   %ebp
  801d33:	89 e5                	mov    %esp,%ebp
  801d35:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  801d38:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801d3c:	75 07                	jne    801d45 <devcons_read+0x13>
  801d3e:	eb 25                	jmp    801d65 <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801d40:	e8 88 ee ff ff       	call   800bcd <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801d45:	e8 19 ee ff ff       	call   800b63 <sys_cgetc>
  801d4a:	85 c0                	test   %eax,%eax
  801d4c:	74 f2                	je     801d40 <devcons_read+0xe>
  801d4e:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  801d50:	85 c0                	test   %eax,%eax
  801d52:	78 1d                	js     801d71 <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801d54:	83 f8 04             	cmp    $0x4,%eax
  801d57:	74 13                	je     801d6c <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  801d59:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d5c:	88 10                	mov    %dl,(%eax)
	return 1;
  801d5e:	b8 01 00 00 00       	mov    $0x1,%eax
  801d63:	eb 0c                	jmp    801d71 <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  801d65:	b8 00 00 00 00       	mov    $0x0,%eax
  801d6a:	eb 05                	jmp    801d71 <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801d6c:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801d71:	c9                   	leave  
  801d72:	c3                   	ret    

00801d73 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801d73:	55                   	push   %ebp
  801d74:	89 e5                	mov    %esp,%ebp
  801d76:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801d79:	8b 45 08             	mov    0x8(%ebp),%eax
  801d7c:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801d7f:	6a 01                	push   $0x1
  801d81:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801d84:	50                   	push   %eax
  801d85:	e8 b3 ed ff ff       	call   800b3d <sys_cputs>
  801d8a:	83 c4 10             	add    $0x10,%esp
}
  801d8d:	c9                   	leave  
  801d8e:	c3                   	ret    

00801d8f <getchar>:

int
getchar(void)
{
  801d8f:	55                   	push   %ebp
  801d90:	89 e5                	mov    %esp,%ebp
  801d92:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801d95:	6a 01                	push   $0x1
  801d97:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801d9a:	50                   	push   %eax
  801d9b:	6a 00                	push   $0x0
  801d9d:	e8 de f6 ff ff       	call   801480 <read>
	if (r < 0)
  801da2:	83 c4 10             	add    $0x10,%esp
  801da5:	85 c0                	test   %eax,%eax
  801da7:	78 0f                	js     801db8 <getchar+0x29>
		return r;
	if (r < 1)
  801da9:	85 c0                	test   %eax,%eax
  801dab:	7e 06                	jle    801db3 <getchar+0x24>
		return -E_EOF;
	return c;
  801dad:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801db1:	eb 05                	jmp    801db8 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801db3:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801db8:	c9                   	leave  
  801db9:	c3                   	ret    

00801dba <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801dba:	55                   	push   %ebp
  801dbb:	89 e5                	mov    %esp,%ebp
  801dbd:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801dc0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801dc3:	50                   	push   %eax
  801dc4:	ff 75 08             	pushl  0x8(%ebp)
  801dc7:	e8 33 f4 ff ff       	call   8011ff <fd_lookup>
  801dcc:	83 c4 10             	add    $0x10,%esp
  801dcf:	85 c0                	test   %eax,%eax
  801dd1:	78 11                	js     801de4 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801dd3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801dd6:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801ddc:	39 10                	cmp    %edx,(%eax)
  801dde:	0f 94 c0             	sete   %al
  801de1:	0f b6 c0             	movzbl %al,%eax
}
  801de4:	c9                   	leave  
  801de5:	c3                   	ret    

00801de6 <opencons>:

int
opencons(void)
{
  801de6:	55                   	push   %ebp
  801de7:	89 e5                	mov    %esp,%ebp
  801de9:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801dec:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801def:	50                   	push   %eax
  801df0:	e8 97 f3 ff ff       	call   80118c <fd_alloc>
  801df5:	83 c4 10             	add    $0x10,%esp
  801df8:	85 c0                	test   %eax,%eax
  801dfa:	78 3a                	js     801e36 <opencons+0x50>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801dfc:	83 ec 04             	sub    $0x4,%esp
  801dff:	68 07 04 00 00       	push   $0x407
  801e04:	ff 75 f4             	pushl  -0xc(%ebp)
  801e07:	6a 00                	push   $0x0
  801e09:	e8 e6 ed ff ff       	call   800bf4 <sys_page_alloc>
  801e0e:	83 c4 10             	add    $0x10,%esp
  801e11:	85 c0                	test   %eax,%eax
  801e13:	78 21                	js     801e36 <opencons+0x50>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801e15:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801e1b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e1e:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801e20:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e23:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801e2a:	83 ec 0c             	sub    $0xc,%esp
  801e2d:	50                   	push   %eax
  801e2e:	e8 31 f3 ff ff       	call   801164 <fd2num>
  801e33:	83 c4 10             	add    $0x10,%esp
}
  801e36:	c9                   	leave  
  801e37:	c3                   	ret    

00801e38 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801e38:	55                   	push   %ebp
  801e39:	89 e5                	mov    %esp,%ebp
  801e3b:	56                   	push   %esi
  801e3c:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801e3d:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801e40:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  801e46:	e8 5e ed ff ff       	call   800ba9 <sys_getenvid>
  801e4b:	83 ec 0c             	sub    $0xc,%esp
  801e4e:	ff 75 0c             	pushl  0xc(%ebp)
  801e51:	ff 75 08             	pushl  0x8(%ebp)
  801e54:	53                   	push   %ebx
  801e55:	50                   	push   %eax
  801e56:	68 b8 27 80 00       	push   $0x8027b8
  801e5b:	e8 5c e3 ff ff       	call   8001bc <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801e60:	83 c4 18             	add    $0x18,%esp
  801e63:	56                   	push   %esi
  801e64:	ff 75 10             	pushl  0x10(%ebp)
  801e67:	e8 ff e2 ff ff       	call   80016b <vcprintf>
	cprintf("\n");
  801e6c:	c7 04 24 8b 27 80 00 	movl   $0x80278b,(%esp)
  801e73:	e8 44 e3 ff ff       	call   8001bc <cprintf>
  801e78:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801e7b:	cc                   	int3   
  801e7c:	eb fd                	jmp    801e7b <_panic+0x43>
	...

00801e80 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801e80:	55                   	push   %ebp
  801e81:	89 e5                	mov    %esp,%ebp
  801e83:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  801e86:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801e8d:	75 52                	jne    801ee1 <set_pgfault_handler+0x61>
		// First time through!	
		// LAB 4: Your code here.

		//int sys_page_alloc(envid_t envid, void *va, int perm)
		r = sys_page_alloc(0, (void*)(UXSTACKTOP - PGSIZE), PTE_U | PTE_W | PTE_P);
  801e8f:	83 ec 04             	sub    $0x4,%esp
  801e92:	6a 07                	push   $0x7
  801e94:	68 00 f0 bf ee       	push   $0xeebff000
  801e99:	6a 00                	push   $0x0
  801e9b:	e8 54 ed ff ff       	call   800bf4 <sys_page_alloc>
		if (r < 0) {
  801ea0:	83 c4 10             	add    $0x10,%esp
  801ea3:	85 c0                	test   %eax,%eax
  801ea5:	79 12                	jns    801eb9 <set_pgfault_handler+0x39>
			panic("sys_page_alloc error : %e\n", r);
  801ea7:	50                   	push   %eax
  801ea8:	68 db 27 80 00       	push   $0x8027db
  801ead:	6a 24                	push   $0x24
  801eaf:	68 f6 27 80 00       	push   $0x8027f6
  801eb4:	e8 7f ff ff ff       	call   801e38 <_panic>
		}

		// how to know envid, put 0, envid2env will help us to get curenv in syscall
		r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);		
  801eb9:	83 ec 08             	sub    $0x8,%esp
  801ebc:	68 ec 1e 80 00       	push   $0x801eec
  801ec1:	6a 00                	push   $0x0
  801ec3:	e8 df ed ff ff       	call   800ca7 <sys_env_set_pgfault_upcall>
		if (r < 0) {
  801ec8:	83 c4 10             	add    $0x10,%esp
  801ecb:	85 c0                	test   %eax,%eax
  801ecd:	79 12                	jns    801ee1 <set_pgfault_handler+0x61>
			panic("sys_env_set_pgfault_upcall error : %e\n", r);
  801ecf:	50                   	push   %eax
  801ed0:	68 04 28 80 00       	push   $0x802804
  801ed5:	6a 2a                	push   $0x2a
  801ed7:	68 f6 27 80 00       	push   $0x8027f6
  801edc:	e8 57 ff ff ff       	call   801e38 <_panic>
		}
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801ee1:	8b 45 08             	mov    0x8(%ebp),%eax
  801ee4:	a3 00 60 80 00       	mov    %eax,0x806000
}
  801ee9:	c9                   	leave  
  801eea:	c3                   	ret    
	...

00801eec <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801eec:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801eed:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  801ef2:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801ef4:	83 c4 04             	add    $0x4,%esp
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	
	// fix old esp
	movl 0x30(%esp), %eax
  801ef7:	8b 44 24 30          	mov    0x30(%esp),%eax
	subl $0x4, %eax
  801efb:	83 e8 04             	sub    $0x4,%eax
	movl %eax, 0x30(%esp)
  801efe:	89 44 24 30          	mov    %eax,0x30(%esp)

	// set trap-time %eip
	movl 0x28(%esp), %ebx
  801f02:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	movl %ebx, (%eax)
  801f06:	89 18                	mov    %ebx,(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $0x08, %esp 	// ignore err_code and fault_va
  801f08:	83 c4 08             	add    $0x8,%esp
	popal 				// restore registers
  801f0b:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x04, %esp 	// ignore eip 
  801f0c:	83 c4 04             	add    $0x4,%esp
	popfl				// modify eflags
  801f0f:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  801f10:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  801f11:	c3                   	ret    
	...

00801f14 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801f14:	55                   	push   %ebp
  801f15:	89 e5                	mov    %esp,%ebp
  801f17:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801f1a:	89 c2                	mov    %eax,%edx
  801f1c:	c1 ea 16             	shr    $0x16,%edx
  801f1f:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801f26:	f6 c2 01             	test   $0x1,%dl
  801f29:	74 1e                	je     801f49 <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  801f2b:	c1 e8 0c             	shr    $0xc,%eax
  801f2e:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801f35:	a8 01                	test   $0x1,%al
  801f37:	74 17                	je     801f50 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801f39:	c1 e8 0c             	shr    $0xc,%eax
  801f3c:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  801f43:	ef 
  801f44:	0f b7 c0             	movzwl %ax,%eax
  801f47:	eb 0c                	jmp    801f55 <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  801f49:	b8 00 00 00 00       	mov    $0x0,%eax
  801f4e:	eb 05                	jmp    801f55 <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  801f50:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  801f55:	c9                   	leave  
  801f56:	c3                   	ret    
	...

00801f58 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  801f58:	55                   	push   %ebp
  801f59:	89 e5                	mov    %esp,%ebp
  801f5b:	57                   	push   %edi
  801f5c:	56                   	push   %esi
  801f5d:	83 ec 10             	sub    $0x10,%esp
  801f60:	8b 7d 08             	mov    0x8(%ebp),%edi
  801f63:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  801f66:	89 7d f0             	mov    %edi,-0x10(%ebp)
  801f69:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  801f6c:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  801f6f:	8b 45 14             	mov    0x14(%ebp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  801f72:	85 c0                	test   %eax,%eax
  801f74:	75 2e                	jne    801fa4 <__udivdi3+0x4c>
    {
      if (d0 > n1)
  801f76:	39 f1                	cmp    %esi,%ecx
  801f78:	77 5a                	ja     801fd4 <__udivdi3+0x7c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  801f7a:	85 c9                	test   %ecx,%ecx
  801f7c:	75 0b                	jne    801f89 <__udivdi3+0x31>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  801f7e:	b8 01 00 00 00       	mov    $0x1,%eax
  801f83:	31 d2                	xor    %edx,%edx
  801f85:	f7 f1                	div    %ecx
  801f87:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  801f89:	31 d2                	xor    %edx,%edx
  801f8b:	89 f0                	mov    %esi,%eax
  801f8d:	f7 f1                	div    %ecx
  801f8f:	89 c6                	mov    %eax,%esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801f91:	89 f8                	mov    %edi,%eax
  801f93:	f7 f1                	div    %ecx
  801f95:	89 c7                	mov    %eax,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801f97:	89 f8                	mov    %edi,%eax
  801f99:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801f9b:	83 c4 10             	add    $0x10,%esp
  801f9e:	5e                   	pop    %esi
  801f9f:	5f                   	pop    %edi
  801fa0:	c9                   	leave  
  801fa1:	c3                   	ret    
  801fa2:	66 90                	xchg   %ax,%ax
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801fa4:	39 f0                	cmp    %esi,%eax
  801fa6:	77 1c                	ja     801fc4 <__udivdi3+0x6c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  801fa8:	0f bd f8             	bsr    %eax,%edi
	  if (bm == 0)
  801fab:	83 f7 1f             	xor    $0x1f,%edi
  801fae:	75 3c                	jne    801fec <__udivdi3+0x94>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801fb0:	39 f0                	cmp    %esi,%eax
  801fb2:	0f 82 90 00 00 00    	jb     802048 <__udivdi3+0xf0>
  801fb8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801fbb:	39 55 f4             	cmp    %edx,-0xc(%ebp)
  801fbe:	0f 86 84 00 00 00    	jbe    802048 <__udivdi3+0xf0>
  801fc4:	31 f6                	xor    %esi,%esi
  801fc6:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801fc8:	89 f8                	mov    %edi,%eax
  801fca:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801fcc:	83 c4 10             	add    $0x10,%esp
  801fcf:	5e                   	pop    %esi
  801fd0:	5f                   	pop    %edi
  801fd1:	c9                   	leave  
  801fd2:	c3                   	ret    
  801fd3:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801fd4:	89 f2                	mov    %esi,%edx
  801fd6:	89 f8                	mov    %edi,%eax
  801fd8:	f7 f1                	div    %ecx
  801fda:	89 c7                	mov    %eax,%edi
  801fdc:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801fde:	89 f8                	mov    %edi,%eax
  801fe0:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801fe2:	83 c4 10             	add    $0x10,%esp
  801fe5:	5e                   	pop    %esi
  801fe6:	5f                   	pop    %edi
  801fe7:	c9                   	leave  
  801fe8:	c3                   	ret    
  801fe9:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  801fec:	89 f9                	mov    %edi,%ecx
  801fee:	d3 e0                	shl    %cl,%eax
  801ff0:	89 45 e8             	mov    %eax,-0x18(%ebp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  801ff3:	b8 20 00 00 00       	mov    $0x20,%eax
  801ff8:	29 f8                	sub    %edi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  801ffa:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801ffd:	88 c1                	mov    %al,%cl
  801fff:	d3 ea                	shr    %cl,%edx
  802001:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  802004:	09 ca                	or     %ecx,%edx
  802006:	89 55 ec             	mov    %edx,-0x14(%ebp)
	      d0 = d0 << bm;
  802009:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80200c:	89 f9                	mov    %edi,%ecx
  80200e:	d3 e2                	shl    %cl,%edx
  802010:	89 55 f4             	mov    %edx,-0xc(%ebp)
	      n2 = n1 >> b;
  802013:	89 f2                	mov    %esi,%edx
  802015:	88 c1                	mov    %al,%cl
  802017:	d3 ea                	shr    %cl,%edx
  802019:	89 55 e8             	mov    %edx,-0x18(%ebp)
	      n1 = (n1 << bm) | (n0 >> b);
  80201c:	89 f2                	mov    %esi,%edx
  80201e:	89 f9                	mov    %edi,%ecx
  802020:	d3 e2                	shl    %cl,%edx
  802022:	8b 75 f0             	mov    -0x10(%ebp),%esi
  802025:	88 c1                	mov    %al,%cl
  802027:	d3 ee                	shr    %cl,%esi
  802029:	09 d6                	or     %edx,%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  80202b:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  80202e:	89 f0                	mov    %esi,%eax
  802030:	89 ca                	mov    %ecx,%edx
  802032:	f7 75 ec             	divl   -0x14(%ebp)
  802035:	89 d1                	mov    %edx,%ecx
  802037:	89 c6                	mov    %eax,%esi
	      umul_ppmm (m1, m0, q0, d0);
  802039:	f7 65 f4             	mull   -0xc(%ebp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  80203c:	39 d1                	cmp    %edx,%ecx
  80203e:	72 28                	jb     802068 <__udivdi3+0x110>
  802040:	74 1a                	je     80205c <__udivdi3+0x104>
  802042:	89 f7                	mov    %esi,%edi
  802044:	31 f6                	xor    %esi,%esi
  802046:	eb 80                	jmp    801fc8 <__udivdi3+0x70>
	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  802048:	31 f6                	xor    %esi,%esi
  80204a:	bf 01 00 00 00       	mov    $0x1,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  80204f:	89 f8                	mov    %edi,%eax
  802051:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802053:	83 c4 10             	add    $0x10,%esp
  802056:	5e                   	pop    %esi
  802057:	5f                   	pop    %edi
  802058:	c9                   	leave  
  802059:	c3                   	ret    
  80205a:	66 90                	xchg   %ax,%ax

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  80205c:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80205f:	89 f9                	mov    %edi,%ecx
  802061:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802063:	39 c2                	cmp    %eax,%edx
  802065:	73 db                	jae    802042 <__udivdi3+0xea>
  802067:	90                   	nop
		{
		  q0--;
  802068:	8d 7e ff             	lea    -0x1(%esi),%edi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  80206b:	31 f6                	xor    %esi,%esi
  80206d:	e9 56 ff ff ff       	jmp    801fc8 <__udivdi3+0x70>
	...

00802074 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  802074:	55                   	push   %ebp
  802075:	89 e5                	mov    %esp,%ebp
  802077:	57                   	push   %edi
  802078:	56                   	push   %esi
  802079:	83 ec 20             	sub    $0x20,%esp
  80207c:	8b 45 08             	mov    0x8(%ebp),%eax
  80207f:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  802082:	89 45 e8             	mov    %eax,-0x18(%ebp)
  802085:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  802088:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  80208b:	8b 7d 14             	mov    0x14(%ebp),%edi
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  80208e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  n1 = nn.s.high;
  802091:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  802093:	85 ff                	test   %edi,%edi
  802095:	75 15                	jne    8020ac <__umoddi3+0x38>
    {
      if (d0 > n1)
  802097:	39 f1                	cmp    %esi,%ecx
  802099:	0f 86 99 00 00 00    	jbe    802138 <__umoddi3+0xc4>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  80209f:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  8020a1:	89 d0                	mov    %edx,%eax
  8020a3:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8020a5:	83 c4 20             	add    $0x20,%esp
  8020a8:	5e                   	pop    %esi
  8020a9:	5f                   	pop    %edi
  8020aa:	c9                   	leave  
  8020ab:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  8020ac:	39 f7                	cmp    %esi,%edi
  8020ae:	0f 87 a4 00 00 00    	ja     802158 <__umoddi3+0xe4>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  8020b4:	0f bd c7             	bsr    %edi,%eax
	  if (bm == 0)
  8020b7:	83 f0 1f             	xor    $0x1f,%eax
  8020ba:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8020bd:	0f 84 a1 00 00 00    	je     802164 <__umoddi3+0xf0>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  8020c3:	89 f8                	mov    %edi,%eax
  8020c5:	8a 4d ec             	mov    -0x14(%ebp),%cl
  8020c8:	d3 e0                	shl    %cl,%eax
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  8020ca:	bf 20 00 00 00       	mov    $0x20,%edi
  8020cf:	2b 7d ec             	sub    -0x14(%ebp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  8020d2:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8020d5:	89 f9                	mov    %edi,%ecx
  8020d7:	d3 ea                	shr    %cl,%edx
  8020d9:	09 c2                	or     %eax,%edx
  8020db:	89 55 f0             	mov    %edx,-0x10(%ebp)
	      d0 = d0 << bm;
  8020de:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020e1:	8a 4d ec             	mov    -0x14(%ebp),%cl
  8020e4:	d3 e0                	shl    %cl,%eax
  8020e6:	89 45 f4             	mov    %eax,-0xc(%ebp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  8020e9:	89 f2                	mov    %esi,%edx
  8020eb:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  8020ed:	8b 45 e8             	mov    -0x18(%ebp),%eax
  8020f0:	d3 e0                	shl    %cl,%eax
  8020f2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  8020f5:	8b 45 e8             	mov    -0x18(%ebp),%eax
  8020f8:	89 f9                	mov    %edi,%ecx
  8020fa:	d3 e8                	shr    %cl,%eax
  8020fc:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  8020fe:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  802100:	89 f2                	mov    %esi,%edx
  802102:	f7 75 f0             	divl   -0x10(%ebp)
  802105:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  802107:	f7 65 f4             	mull   -0xc(%ebp)
  80210a:	89 55 e8             	mov    %edx,-0x18(%ebp)
  80210d:	89 c1                	mov    %eax,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  80210f:	39 d6                	cmp    %edx,%esi
  802111:	72 71                	jb     802184 <__umoddi3+0x110>
  802113:	74 7f                	je     802194 <__umoddi3+0x120>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  802115:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802118:	29 c8                	sub    %ecx,%eax
  80211a:	19 d6                	sbb    %edx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  80211c:	8a 4d ec             	mov    -0x14(%ebp),%cl
  80211f:	d3 e8                	shr    %cl,%eax
  802121:	89 f2                	mov    %esi,%edx
  802123:	89 f9                	mov    %edi,%ecx
  802125:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  802127:	09 d0                	or     %edx,%eax
  802129:	89 f2                	mov    %esi,%edx
  80212b:	8a 4d ec             	mov    -0x14(%ebp),%cl
  80212e:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802130:	83 c4 20             	add    $0x20,%esp
  802133:	5e                   	pop    %esi
  802134:	5f                   	pop    %edi
  802135:	c9                   	leave  
  802136:	c3                   	ret    
  802137:	90                   	nop
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  802138:	85 c9                	test   %ecx,%ecx
  80213a:	75 0b                	jne    802147 <__umoddi3+0xd3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  80213c:	b8 01 00 00 00       	mov    $0x1,%eax
  802141:	31 d2                	xor    %edx,%edx
  802143:	f7 f1                	div    %ecx
  802145:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  802147:	89 f0                	mov    %esi,%eax
  802149:	31 d2                	xor    %edx,%edx
  80214b:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  80214d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802150:	f7 f1                	div    %ecx
  802152:	e9 4a ff ff ff       	jmp    8020a1 <__umoddi3+0x2d>
  802157:	90                   	nop
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  802158:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  80215a:	83 c4 20             	add    $0x20,%esp
  80215d:	5e                   	pop    %esi
  80215e:	5f                   	pop    %edi
  80215f:	c9                   	leave  
  802160:	c3                   	ret    
  802161:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802164:	39 f7                	cmp    %esi,%edi
  802166:	72 05                	jb     80216d <__umoddi3+0xf9>
  802168:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
  80216b:	77 0c                	ja     802179 <__umoddi3+0x105>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  80216d:	89 f2                	mov    %esi,%edx
  80216f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802172:	29 c8                	sub    %ecx,%eax
  802174:	19 fa                	sbb    %edi,%edx
  802176:	89 45 f0             	mov    %eax,-0x10(%ebp)

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  802179:	8b 45 f0             	mov    -0x10(%ebp),%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  80217c:	83 c4 20             	add    $0x20,%esp
  80217f:	5e                   	pop    %esi
  802180:	5f                   	pop    %edi
  802181:	c9                   	leave  
  802182:	c3                   	ret    
  802183:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  802184:	8b 55 e8             	mov    -0x18(%ebp),%edx
  802187:	89 c1                	mov    %eax,%ecx
  802189:	2b 4d f4             	sub    -0xc(%ebp),%ecx
  80218c:	1b 55 f0             	sbb    -0x10(%ebp),%edx
  80218f:	eb 84                	jmp    802115 <__umoddi3+0xa1>
  802191:	8d 76 00             	lea    0x0(%esi),%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802194:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  802197:	72 eb                	jb     802184 <__umoddi3+0x110>
  802199:	89 f2                	mov    %esi,%edx
  80219b:	e9 75 ff ff ff       	jmp    802115 <__umoddi3+0xa1>
