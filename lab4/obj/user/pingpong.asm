
obj/user/pingpong:     file format elf32-i386


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
  80003d:	e8 78 0d 00 00       	call   800dba <fork>
  800042:	89 c3                	mov    %eax,%ebx
  800044:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800047:	85 c0                	test   %eax,%eax
  800049:	74 25                	je     800070 <umain+0x3c>
		// get the ball rolling
		cprintf("send 0 from %x to %x\n", sys_getenvid(), who);
  80004b:	e8 51 0b 00 00       	call   800ba1 <sys_getenvid>
  800050:	83 ec 04             	sub    $0x4,%esp
  800053:	53                   	push   %ebx
  800054:	50                   	push   %eax
  800055:	68 80 13 80 00       	push   $0x801380
  80005a:	e8 55 01 00 00       	call   8001b4 <cprintf>
		ipc_send(who, 0, 0, 0);
  80005f:	6a 00                	push   $0x0
  800061:	6a 00                	push   $0x0
  800063:	6a 00                	push   $0x0
  800065:	ff 75 e4             	pushl  -0x1c(%ebp)
  800068:	e8 6a 0f 00 00       	call   800fd7 <ipc_send>
  80006d:	83 c4 20             	add    $0x20,%esp
	}

	while (1) {
		uint32_t i = ipc_recv(&who, 0, 0);
  800070:	8d 7d e4             	lea    -0x1c(%ebp),%edi
  800073:	83 ec 04             	sub    $0x4,%esp
  800076:	6a 00                	push   $0x0
  800078:	6a 00                	push   $0x0
  80007a:	57                   	push   %edi
  80007b:	e8 40 0f 00 00       	call   800fc0 <ipc_recv>
  800080:	89 c3                	mov    %eax,%ebx
		cprintf("%x got %d from %x\n", sys_getenvid(), i, who);
  800082:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  800085:	e8 17 0b 00 00       	call   800ba1 <sys_getenvid>
  80008a:	56                   	push   %esi
  80008b:	53                   	push   %ebx
  80008c:	50                   	push   %eax
  80008d:	68 96 13 80 00       	push   $0x801396
  800092:	e8 1d 01 00 00       	call   8001b4 <cprintf>
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
  8000a8:	e8 2a 0f 00 00       	call   800fd7 <ipc_send>
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
  8000cb:	e8 d1 0a 00 00       	call   800ba1 <sys_getenvid>
  8000d0:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000d5:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  8000dc:	c1 e0 07             	shl    $0x7,%eax
  8000df:	29 d0                	sub    %edx,%eax
  8000e1:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000e6:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000eb:	85 f6                	test   %esi,%esi
  8000ed:	7e 07                	jle    8000f6 <libmain+0x36>
		binaryname = argv[0];
  8000ef:	8b 03                	mov    (%ebx),%eax
  8000f1:	a3 00 20 80 00       	mov    %eax,0x802000
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
  800113:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  800116:	6a 00                	push   $0x0
  800118:	e8 62 0a 00 00       	call   800b7f <sys_env_destroy>
  80011d:	83 c4 10             	add    $0x10,%esp
}
  800120:	c9                   	leave  
  800121:	c3                   	ret    
	...

00800124 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800124:	55                   	push   %ebp
  800125:	89 e5                	mov    %esp,%ebp
  800127:	53                   	push   %ebx
  800128:	83 ec 04             	sub    $0x4,%esp
  80012b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80012e:	8b 03                	mov    (%ebx),%eax
  800130:	8b 55 08             	mov    0x8(%ebp),%edx
  800133:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  800137:	40                   	inc    %eax
  800138:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  80013a:	3d ff 00 00 00       	cmp    $0xff,%eax
  80013f:	75 1a                	jne    80015b <putch+0x37>
		sys_cputs(b->buf, b->idx);
  800141:	83 ec 08             	sub    $0x8,%esp
  800144:	68 ff 00 00 00       	push   $0xff
  800149:	8d 43 08             	lea    0x8(%ebx),%eax
  80014c:	50                   	push   %eax
  80014d:	e8 e3 09 00 00       	call   800b35 <sys_cputs>
		b->idx = 0;
  800152:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800158:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80015b:	ff 43 04             	incl   0x4(%ebx)
}
  80015e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800161:	c9                   	leave  
  800162:	c3                   	ret    

00800163 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800163:	55                   	push   %ebp
  800164:	89 e5                	mov    %esp,%ebp
  800166:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80016c:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800173:	00 00 00 
	b.cnt = 0;
  800176:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80017d:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800180:	ff 75 0c             	pushl  0xc(%ebp)
  800183:	ff 75 08             	pushl  0x8(%ebp)
  800186:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80018c:	50                   	push   %eax
  80018d:	68 24 01 80 00       	push   $0x800124
  800192:	e8 82 01 00 00       	call   800319 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800197:	83 c4 08             	add    $0x8,%esp
  80019a:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8001a0:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001a6:	50                   	push   %eax
  8001a7:	e8 89 09 00 00       	call   800b35 <sys_cputs>

	return b.cnt;
}
  8001ac:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001b2:	c9                   	leave  
  8001b3:	c3                   	ret    

008001b4 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001b4:	55                   	push   %ebp
  8001b5:	89 e5                	mov    %esp,%ebp
  8001b7:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001ba:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001bd:	50                   	push   %eax
  8001be:	ff 75 08             	pushl  0x8(%ebp)
  8001c1:	e8 9d ff ff ff       	call   800163 <vcprintf>
	va_end(ap);

	return cnt;
}
  8001c6:	c9                   	leave  
  8001c7:	c3                   	ret    

008001c8 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001c8:	55                   	push   %ebp
  8001c9:	89 e5                	mov    %esp,%ebp
  8001cb:	57                   	push   %edi
  8001cc:	56                   	push   %esi
  8001cd:	53                   	push   %ebx
  8001ce:	83 ec 2c             	sub    $0x2c,%esp
  8001d1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8001d4:	89 d6                	mov    %edx,%esi
  8001d6:	8b 45 08             	mov    0x8(%ebp),%eax
  8001d9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001dc:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001df:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8001e2:	8b 45 10             	mov    0x10(%ebp),%eax
  8001e5:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8001e8:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001eb:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8001ee:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  8001f5:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
  8001f8:	72 0c                	jb     800206 <printnum+0x3e>
  8001fa:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  8001fd:	76 07                	jbe    800206 <printnum+0x3e>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8001ff:	4b                   	dec    %ebx
  800200:	85 db                	test   %ebx,%ebx
  800202:	7f 31                	jg     800235 <printnum+0x6d>
  800204:	eb 3f                	jmp    800245 <printnum+0x7d>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800206:	83 ec 0c             	sub    $0xc,%esp
  800209:	57                   	push   %edi
  80020a:	4b                   	dec    %ebx
  80020b:	53                   	push   %ebx
  80020c:	50                   	push   %eax
  80020d:	83 ec 08             	sub    $0x8,%esp
  800210:	ff 75 d4             	pushl  -0x2c(%ebp)
  800213:	ff 75 d0             	pushl  -0x30(%ebp)
  800216:	ff 75 dc             	pushl  -0x24(%ebp)
  800219:	ff 75 d8             	pushl  -0x28(%ebp)
  80021c:	e8 07 0f 00 00       	call   801128 <__udivdi3>
  800221:	83 c4 18             	add    $0x18,%esp
  800224:	52                   	push   %edx
  800225:	50                   	push   %eax
  800226:	89 f2                	mov    %esi,%edx
  800228:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80022b:	e8 98 ff ff ff       	call   8001c8 <printnum>
  800230:	83 c4 20             	add    $0x20,%esp
  800233:	eb 10                	jmp    800245 <printnum+0x7d>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800235:	83 ec 08             	sub    $0x8,%esp
  800238:	56                   	push   %esi
  800239:	57                   	push   %edi
  80023a:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80023d:	4b                   	dec    %ebx
  80023e:	83 c4 10             	add    $0x10,%esp
  800241:	85 db                	test   %ebx,%ebx
  800243:	7f f0                	jg     800235 <printnum+0x6d>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800245:	83 ec 08             	sub    $0x8,%esp
  800248:	56                   	push   %esi
  800249:	83 ec 04             	sub    $0x4,%esp
  80024c:	ff 75 d4             	pushl  -0x2c(%ebp)
  80024f:	ff 75 d0             	pushl  -0x30(%ebp)
  800252:	ff 75 dc             	pushl  -0x24(%ebp)
  800255:	ff 75 d8             	pushl  -0x28(%ebp)
  800258:	e8 e7 0f 00 00       	call   801244 <__umoddi3>
  80025d:	83 c4 14             	add    $0x14,%esp
  800260:	0f be 80 b3 13 80 00 	movsbl 0x8013b3(%eax),%eax
  800267:	50                   	push   %eax
  800268:	ff 55 e4             	call   *-0x1c(%ebp)
  80026b:	83 c4 10             	add    $0x10,%esp
}
  80026e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800271:	5b                   	pop    %ebx
  800272:	5e                   	pop    %esi
  800273:	5f                   	pop    %edi
  800274:	c9                   	leave  
  800275:	c3                   	ret    

00800276 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800276:	55                   	push   %ebp
  800277:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800279:	83 fa 01             	cmp    $0x1,%edx
  80027c:	7e 0e                	jle    80028c <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80027e:	8b 10                	mov    (%eax),%edx
  800280:	8d 4a 08             	lea    0x8(%edx),%ecx
  800283:	89 08                	mov    %ecx,(%eax)
  800285:	8b 02                	mov    (%edx),%eax
  800287:	8b 52 04             	mov    0x4(%edx),%edx
  80028a:	eb 22                	jmp    8002ae <getuint+0x38>
	else if (lflag)
  80028c:	85 d2                	test   %edx,%edx
  80028e:	74 10                	je     8002a0 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800290:	8b 10                	mov    (%eax),%edx
  800292:	8d 4a 04             	lea    0x4(%edx),%ecx
  800295:	89 08                	mov    %ecx,(%eax)
  800297:	8b 02                	mov    (%edx),%eax
  800299:	ba 00 00 00 00       	mov    $0x0,%edx
  80029e:	eb 0e                	jmp    8002ae <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8002a0:	8b 10                	mov    (%eax),%edx
  8002a2:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002a5:	89 08                	mov    %ecx,(%eax)
  8002a7:	8b 02                	mov    (%edx),%eax
  8002a9:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002ae:	c9                   	leave  
  8002af:	c3                   	ret    

008002b0 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  8002b0:	55                   	push   %ebp
  8002b1:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002b3:	83 fa 01             	cmp    $0x1,%edx
  8002b6:	7e 0e                	jle    8002c6 <getint+0x16>
		return va_arg(*ap, long long);
  8002b8:	8b 10                	mov    (%eax),%edx
  8002ba:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002bd:	89 08                	mov    %ecx,(%eax)
  8002bf:	8b 02                	mov    (%edx),%eax
  8002c1:	8b 52 04             	mov    0x4(%edx),%edx
  8002c4:	eb 1a                	jmp    8002e0 <getint+0x30>
	else if (lflag)
  8002c6:	85 d2                	test   %edx,%edx
  8002c8:	74 0c                	je     8002d6 <getint+0x26>
		return va_arg(*ap, long);
  8002ca:	8b 10                	mov    (%eax),%edx
  8002cc:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002cf:	89 08                	mov    %ecx,(%eax)
  8002d1:	8b 02                	mov    (%edx),%eax
  8002d3:	99                   	cltd   
  8002d4:	eb 0a                	jmp    8002e0 <getint+0x30>
	else
		return va_arg(*ap, int);
  8002d6:	8b 10                	mov    (%eax),%edx
  8002d8:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002db:	89 08                	mov    %ecx,(%eax)
  8002dd:	8b 02                	mov    (%edx),%eax
  8002df:	99                   	cltd   
}
  8002e0:	c9                   	leave  
  8002e1:	c3                   	ret    

008002e2 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002e2:	55                   	push   %ebp
  8002e3:	89 e5                	mov    %esp,%ebp
  8002e5:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002e8:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  8002eb:	8b 10                	mov    (%eax),%edx
  8002ed:	3b 50 04             	cmp    0x4(%eax),%edx
  8002f0:	73 08                	jae    8002fa <sprintputch+0x18>
		*b->buf++ = ch;
  8002f2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8002f5:	88 0a                	mov    %cl,(%edx)
  8002f7:	42                   	inc    %edx
  8002f8:	89 10                	mov    %edx,(%eax)
}
  8002fa:	c9                   	leave  
  8002fb:	c3                   	ret    

008002fc <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8002fc:	55                   	push   %ebp
  8002fd:	89 e5                	mov    %esp,%ebp
  8002ff:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800302:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800305:	50                   	push   %eax
  800306:	ff 75 10             	pushl  0x10(%ebp)
  800309:	ff 75 0c             	pushl  0xc(%ebp)
  80030c:	ff 75 08             	pushl  0x8(%ebp)
  80030f:	e8 05 00 00 00       	call   800319 <vprintfmt>
	va_end(ap);
  800314:	83 c4 10             	add    $0x10,%esp
}
  800317:	c9                   	leave  
  800318:	c3                   	ret    

00800319 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800319:	55                   	push   %ebp
  80031a:	89 e5                	mov    %esp,%ebp
  80031c:	57                   	push   %edi
  80031d:	56                   	push   %esi
  80031e:	53                   	push   %ebx
  80031f:	83 ec 2c             	sub    $0x2c,%esp
  800322:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800325:	8b 75 10             	mov    0x10(%ebp),%esi
  800328:	eb 13                	jmp    80033d <vprintfmt+0x24>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80032a:	85 c0                	test   %eax,%eax
  80032c:	0f 84 6d 03 00 00    	je     80069f <vprintfmt+0x386>
				return;
			putch(ch, putdat);
  800332:	83 ec 08             	sub    $0x8,%esp
  800335:	57                   	push   %edi
  800336:	50                   	push   %eax
  800337:	ff 55 08             	call   *0x8(%ebp)
  80033a:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80033d:	0f b6 06             	movzbl (%esi),%eax
  800340:	46                   	inc    %esi
  800341:	83 f8 25             	cmp    $0x25,%eax
  800344:	75 e4                	jne    80032a <vprintfmt+0x11>
  800346:	c6 45 dc 20          	movb   $0x20,-0x24(%ebp)
  80034a:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  800351:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  800358:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  80035f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800364:	eb 28                	jmp    80038e <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800366:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800368:	c6 45 dc 2d          	movb   $0x2d,-0x24(%ebp)
  80036c:	eb 20                	jmp    80038e <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80036e:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800370:	c6 45 dc 30          	movb   $0x30,-0x24(%ebp)
  800374:	eb 18                	jmp    80038e <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800376:	89 de                	mov    %ebx,%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800378:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  80037f:	eb 0d                	jmp    80038e <vprintfmt+0x75>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800381:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800384:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800387:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80038e:	8a 06                	mov    (%esi),%al
  800390:	0f b6 d0             	movzbl %al,%edx
  800393:	8d 5e 01             	lea    0x1(%esi),%ebx
  800396:	83 e8 23             	sub    $0x23,%eax
  800399:	3c 55                	cmp    $0x55,%al
  80039b:	0f 87 e0 02 00 00    	ja     800681 <vprintfmt+0x368>
  8003a1:	0f b6 c0             	movzbl %al,%eax
  8003a4:	ff 24 85 80 14 80 00 	jmp    *0x801480(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003ab:	83 ea 30             	sub    $0x30,%edx
  8003ae:	89 55 d4             	mov    %edx,-0x2c(%ebp)
				ch = *fmt;
  8003b1:	0f be 03             	movsbl (%ebx),%eax
				if (ch < '0' || ch > '9')
  8003b4:	8d 50 d0             	lea    -0x30(%eax),%edx
  8003b7:	83 fa 09             	cmp    $0x9,%edx
  8003ba:	77 44                	ja     800400 <vprintfmt+0xe7>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003bc:	89 de                	mov    %ebx,%esi
  8003be:	8b 55 d4             	mov    -0x2c(%ebp),%edx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003c1:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
  8003c2:	8d 14 92             	lea    (%edx,%edx,4),%edx
  8003c5:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
  8003c9:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8003cc:	8d 58 d0             	lea    -0x30(%eax),%ebx
  8003cf:	83 fb 09             	cmp    $0x9,%ebx
  8003d2:	76 ed                	jbe    8003c1 <vprintfmt+0xa8>
  8003d4:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  8003d7:	eb 29                	jmp    800402 <vprintfmt+0xe9>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003d9:	8b 45 14             	mov    0x14(%ebp),%eax
  8003dc:	8d 50 04             	lea    0x4(%eax),%edx
  8003df:	89 55 14             	mov    %edx,0x14(%ebp)
  8003e2:	8b 00                	mov    (%eax),%eax
  8003e4:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003e7:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8003e9:	eb 17                	jmp    800402 <vprintfmt+0xe9>

		case '.':
			if (width < 0)
  8003eb:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8003ef:	78 85                	js     800376 <vprintfmt+0x5d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003f1:	89 de                	mov    %ebx,%esi
  8003f3:	eb 99                	jmp    80038e <vprintfmt+0x75>
  8003f5:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8003f7:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  8003fe:	eb 8e                	jmp    80038e <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800400:	89 de                	mov    %ebx,%esi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  800402:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800406:	79 86                	jns    80038e <vprintfmt+0x75>
  800408:	e9 74 ff ff ff       	jmp    800381 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80040d:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80040e:	89 de                	mov    %ebx,%esi
  800410:	e9 79 ff ff ff       	jmp    80038e <vprintfmt+0x75>
  800415:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800418:	8b 45 14             	mov    0x14(%ebp),%eax
  80041b:	8d 50 04             	lea    0x4(%eax),%edx
  80041e:	89 55 14             	mov    %edx,0x14(%ebp)
  800421:	83 ec 08             	sub    $0x8,%esp
  800424:	57                   	push   %edi
  800425:	ff 30                	pushl  (%eax)
  800427:	ff 55 08             	call   *0x8(%ebp)
			break;
  80042a:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80042d:	8b 75 d8             	mov    -0x28(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800430:	e9 08 ff ff ff       	jmp    80033d <vprintfmt+0x24>
  800435:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  800438:	8b 45 14             	mov    0x14(%ebp),%eax
  80043b:	8d 50 04             	lea    0x4(%eax),%edx
  80043e:	89 55 14             	mov    %edx,0x14(%ebp)
  800441:	8b 00                	mov    (%eax),%eax
  800443:	85 c0                	test   %eax,%eax
  800445:	79 02                	jns    800449 <vprintfmt+0x130>
  800447:	f7 d8                	neg    %eax
  800449:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80044b:	83 f8 08             	cmp    $0x8,%eax
  80044e:	7f 0b                	jg     80045b <vprintfmt+0x142>
  800450:	8b 04 85 e0 15 80 00 	mov    0x8015e0(,%eax,4),%eax
  800457:	85 c0                	test   %eax,%eax
  800459:	75 1a                	jne    800475 <vprintfmt+0x15c>
				printfmt(putch, putdat, "error %d", err);
  80045b:	52                   	push   %edx
  80045c:	68 cb 13 80 00       	push   $0x8013cb
  800461:	57                   	push   %edi
  800462:	ff 75 08             	pushl  0x8(%ebp)
  800465:	e8 92 fe ff ff       	call   8002fc <printfmt>
  80046a:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80046d:	8b 75 d8             	mov    -0x28(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800470:	e9 c8 fe ff ff       	jmp    80033d <vprintfmt+0x24>
			else
				printfmt(putch, putdat, "%s", p);
  800475:	50                   	push   %eax
  800476:	68 d4 13 80 00       	push   $0x8013d4
  80047b:	57                   	push   %edi
  80047c:	ff 75 08             	pushl  0x8(%ebp)
  80047f:	e8 78 fe ff ff       	call   8002fc <printfmt>
  800484:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800487:	8b 75 d8             	mov    -0x28(%ebp),%esi
  80048a:	e9 ae fe ff ff       	jmp    80033d <vprintfmt+0x24>
  80048f:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  800492:	89 de                	mov    %ebx,%esi
  800494:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  800497:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80049a:	8b 45 14             	mov    0x14(%ebp),%eax
  80049d:	8d 50 04             	lea    0x4(%eax),%edx
  8004a0:	89 55 14             	mov    %edx,0x14(%ebp)
  8004a3:	8b 00                	mov    (%eax),%eax
  8004a5:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8004a8:	85 c0                	test   %eax,%eax
  8004aa:	75 07                	jne    8004b3 <vprintfmt+0x19a>
				p = "(null)";
  8004ac:	c7 45 d0 c4 13 80 00 	movl   $0x8013c4,-0x30(%ebp)
			if (width > 0 && padc != '-')
  8004b3:	85 db                	test   %ebx,%ebx
  8004b5:	7e 42                	jle    8004f9 <vprintfmt+0x1e0>
  8004b7:	80 7d dc 2d          	cmpb   $0x2d,-0x24(%ebp)
  8004bb:	74 3c                	je     8004f9 <vprintfmt+0x1e0>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004bd:	83 ec 08             	sub    $0x8,%esp
  8004c0:	51                   	push   %ecx
  8004c1:	ff 75 d0             	pushl  -0x30(%ebp)
  8004c4:	e8 6f 02 00 00       	call   800738 <strnlen>
  8004c9:	29 c3                	sub    %eax,%ebx
  8004cb:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8004ce:	83 c4 10             	add    $0x10,%esp
  8004d1:	85 db                	test   %ebx,%ebx
  8004d3:	7e 24                	jle    8004f9 <vprintfmt+0x1e0>
					putch(padc, putdat);
  8004d5:	0f be 5d dc          	movsbl -0x24(%ebp),%ebx
  8004d9:	89 75 dc             	mov    %esi,-0x24(%ebp)
  8004dc:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  8004df:	83 ec 08             	sub    $0x8,%esp
  8004e2:	57                   	push   %edi
  8004e3:	53                   	push   %ebx
  8004e4:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004e7:	4e                   	dec    %esi
  8004e8:	83 c4 10             	add    $0x10,%esp
  8004eb:	85 f6                	test   %esi,%esi
  8004ed:	7f f0                	jg     8004df <vprintfmt+0x1c6>
  8004ef:	8b 75 dc             	mov    -0x24(%ebp),%esi
  8004f2:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004f9:	8b 55 d0             	mov    -0x30(%ebp),%edx
  8004fc:	0f be 02             	movsbl (%edx),%eax
  8004ff:	85 c0                	test   %eax,%eax
  800501:	75 47                	jne    80054a <vprintfmt+0x231>
  800503:	eb 37                	jmp    80053c <vprintfmt+0x223>
				if (altflag && (ch < ' ' || ch > '~'))
  800505:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800509:	74 16                	je     800521 <vprintfmt+0x208>
  80050b:	8d 50 e0             	lea    -0x20(%eax),%edx
  80050e:	83 fa 5e             	cmp    $0x5e,%edx
  800511:	76 0e                	jbe    800521 <vprintfmt+0x208>
					putch('?', putdat);
  800513:	83 ec 08             	sub    $0x8,%esp
  800516:	57                   	push   %edi
  800517:	6a 3f                	push   $0x3f
  800519:	ff 55 08             	call   *0x8(%ebp)
  80051c:	83 c4 10             	add    $0x10,%esp
  80051f:	eb 0b                	jmp    80052c <vprintfmt+0x213>
				else
					putch(ch, putdat);
  800521:	83 ec 08             	sub    $0x8,%esp
  800524:	57                   	push   %edi
  800525:	50                   	push   %eax
  800526:	ff 55 08             	call   *0x8(%ebp)
  800529:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80052c:	ff 4d e4             	decl   -0x1c(%ebp)
  80052f:	0f be 03             	movsbl (%ebx),%eax
  800532:	85 c0                	test   %eax,%eax
  800534:	74 03                	je     800539 <vprintfmt+0x220>
  800536:	43                   	inc    %ebx
  800537:	eb 1b                	jmp    800554 <vprintfmt+0x23b>
  800539:	8b 75 dc             	mov    -0x24(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80053c:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800540:	7f 1e                	jg     800560 <vprintfmt+0x247>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800542:	8b 75 d8             	mov    -0x28(%ebp),%esi
  800545:	e9 f3 fd ff ff       	jmp    80033d <vprintfmt+0x24>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80054a:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  80054d:	43                   	inc    %ebx
  80054e:	89 75 dc             	mov    %esi,-0x24(%ebp)
  800551:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  800554:	85 f6                	test   %esi,%esi
  800556:	78 ad                	js     800505 <vprintfmt+0x1ec>
  800558:	4e                   	dec    %esi
  800559:	79 aa                	jns    800505 <vprintfmt+0x1ec>
  80055b:	8b 75 dc             	mov    -0x24(%ebp),%esi
  80055e:	eb dc                	jmp    80053c <vprintfmt+0x223>
  800560:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800563:	83 ec 08             	sub    $0x8,%esp
  800566:	57                   	push   %edi
  800567:	6a 20                	push   $0x20
  800569:	ff 55 08             	call   *0x8(%ebp)
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80056c:	4b                   	dec    %ebx
  80056d:	83 c4 10             	add    $0x10,%esp
  800570:	85 db                	test   %ebx,%ebx
  800572:	7f ef                	jg     800563 <vprintfmt+0x24a>
  800574:	e9 c4 fd ff ff       	jmp    80033d <vprintfmt+0x24>
  800579:	89 5d d8             	mov    %ebx,-0x28(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80057c:	89 ca                	mov    %ecx,%edx
  80057e:	8d 45 14             	lea    0x14(%ebp),%eax
  800581:	e8 2a fd ff ff       	call   8002b0 <getint>
  800586:	89 c3                	mov    %eax,%ebx
  800588:	89 d6                	mov    %edx,%esi
			if ((long long) num < 0) {
  80058a:	85 d2                	test   %edx,%edx
  80058c:	78 0a                	js     800598 <vprintfmt+0x27f>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80058e:	b8 0a 00 00 00       	mov    $0xa,%eax
  800593:	e9 b0 00 00 00       	jmp    800648 <vprintfmt+0x32f>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  800598:	83 ec 08             	sub    $0x8,%esp
  80059b:	57                   	push   %edi
  80059c:	6a 2d                	push   $0x2d
  80059e:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8005a1:	f7 db                	neg    %ebx
  8005a3:	83 d6 00             	adc    $0x0,%esi
  8005a6:	f7 de                	neg    %esi
  8005a8:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8005ab:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005b0:	e9 93 00 00 00       	jmp    800648 <vprintfmt+0x32f>
  8005b5:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8005b8:	89 ca                	mov    %ecx,%edx
  8005ba:	8d 45 14             	lea    0x14(%ebp),%eax
  8005bd:	e8 b4 fc ff ff       	call   800276 <getuint>
  8005c2:	89 c3                	mov    %eax,%ebx
  8005c4:	89 d6                	mov    %edx,%esi
			base = 10;
  8005c6:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  8005cb:	eb 7b                	jmp    800648 <vprintfmt+0x32f>
  8005cd:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
  8005d0:	89 ca                	mov    %ecx,%edx
  8005d2:	8d 45 14             	lea    0x14(%ebp),%eax
  8005d5:	e8 d6 fc ff ff       	call   8002b0 <getint>
  8005da:	89 c3                	mov    %eax,%ebx
  8005dc:	89 d6                	mov    %edx,%esi
            if ((long long) num < 0) {
  8005de:	85 d2                	test   %edx,%edx
  8005e0:	78 07                	js     8005e9 <vprintfmt+0x2d0>
                putch('-', putdat);
                num = -(long long) num;
            }
            base = 8;
  8005e2:	b8 08 00 00 00       	mov    $0x8,%eax
  8005e7:	eb 5f                	jmp    800648 <vprintfmt+0x32f>
		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
            if ((long long) num < 0) {
                putch('-', putdat);
  8005e9:	83 ec 08             	sub    $0x8,%esp
  8005ec:	57                   	push   %edi
  8005ed:	6a 2d                	push   $0x2d
  8005ef:	ff 55 08             	call   *0x8(%ebp)
                num = -(long long) num;
  8005f2:	f7 db                	neg    %ebx
  8005f4:	83 d6 00             	adc    $0x0,%esi
  8005f7:	f7 de                	neg    %esi
  8005f9:	83 c4 10             	add    $0x10,%esp
            }
            base = 8;
  8005fc:	b8 08 00 00 00       	mov    $0x8,%eax
  800601:	eb 45                	jmp    800648 <vprintfmt+0x32f>
  800603:	89 5d d8             	mov    %ebx,-0x28(%ebp)
            goto number;

        // pointer
		case 'p':
			putch('0', putdat);
  800606:	83 ec 08             	sub    $0x8,%esp
  800609:	57                   	push   %edi
  80060a:	6a 30                	push   $0x30
  80060c:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  80060f:	83 c4 08             	add    $0x8,%esp
  800612:	57                   	push   %edi
  800613:	6a 78                	push   $0x78
  800615:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800618:	8b 45 14             	mov    0x14(%ebp),%eax
  80061b:	8d 50 04             	lea    0x4(%eax),%edx
  80061e:	89 55 14             	mov    %edx,0x14(%ebp)

        // pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800621:	8b 18                	mov    (%eax),%ebx
  800623:	be 00 00 00 00       	mov    $0x0,%esi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800628:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80062b:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800630:	eb 16                	jmp    800648 <vprintfmt+0x32f>
  800632:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800635:	89 ca                	mov    %ecx,%edx
  800637:	8d 45 14             	lea    0x14(%ebp),%eax
  80063a:	e8 37 fc ff ff       	call   800276 <getuint>
  80063f:	89 c3                	mov    %eax,%ebx
  800641:	89 d6                	mov    %edx,%esi
			base = 16;
  800643:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800648:	83 ec 0c             	sub    $0xc,%esp
  80064b:	0f be 55 dc          	movsbl -0x24(%ebp),%edx
  80064f:	52                   	push   %edx
  800650:	ff 75 e4             	pushl  -0x1c(%ebp)
  800653:	50                   	push   %eax
  800654:	56                   	push   %esi
  800655:	53                   	push   %ebx
  800656:	89 fa                	mov    %edi,%edx
  800658:	8b 45 08             	mov    0x8(%ebp),%eax
  80065b:	e8 68 fb ff ff       	call   8001c8 <printnum>
			break;
  800660:	83 c4 20             	add    $0x20,%esp
  800663:	8b 75 d8             	mov    -0x28(%ebp),%esi
  800666:	e9 d2 fc ff ff       	jmp    80033d <vprintfmt+0x24>
  80066b:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80066e:	83 ec 08             	sub    $0x8,%esp
  800671:	57                   	push   %edi
  800672:	52                   	push   %edx
  800673:	ff 55 08             	call   *0x8(%ebp)
			break;
  800676:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800679:	8b 75 d8             	mov    -0x28(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80067c:	e9 bc fc ff ff       	jmp    80033d <vprintfmt+0x24>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800681:	83 ec 08             	sub    $0x8,%esp
  800684:	57                   	push   %edi
  800685:	6a 25                	push   $0x25
  800687:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  80068a:	83 c4 10             	add    $0x10,%esp
  80068d:	eb 02                	jmp    800691 <vprintfmt+0x378>
  80068f:	89 c6                	mov    %eax,%esi
  800691:	8d 46 ff             	lea    -0x1(%esi),%eax
  800694:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800698:	75 f5                	jne    80068f <vprintfmt+0x376>
  80069a:	e9 9e fc ff ff       	jmp    80033d <vprintfmt+0x24>
				/* do nothing */;
			break;
		}
	}
}
  80069f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006a2:	5b                   	pop    %ebx
  8006a3:	5e                   	pop    %esi
  8006a4:	5f                   	pop    %edi
  8006a5:	c9                   	leave  
  8006a6:	c3                   	ret    

008006a7 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006a7:	55                   	push   %ebp
  8006a8:	89 e5                	mov    %esp,%ebp
  8006aa:	83 ec 18             	sub    $0x18,%esp
  8006ad:	8b 45 08             	mov    0x8(%ebp),%eax
  8006b0:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006b3:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006b6:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8006ba:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8006bd:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8006c4:	85 c0                	test   %eax,%eax
  8006c6:	74 26                	je     8006ee <vsnprintf+0x47>
  8006c8:	85 d2                	test   %edx,%edx
  8006ca:	7e 29                	jle    8006f5 <vsnprintf+0x4e>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8006cc:	ff 75 14             	pushl  0x14(%ebp)
  8006cf:	ff 75 10             	pushl  0x10(%ebp)
  8006d2:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8006d5:	50                   	push   %eax
  8006d6:	68 e2 02 80 00       	push   $0x8002e2
  8006db:	e8 39 fc ff ff       	call   800319 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8006e0:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8006e3:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8006e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006e9:	83 c4 10             	add    $0x10,%esp
  8006ec:	eb 0c                	jmp    8006fa <vsnprintf+0x53>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8006ee:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8006f3:	eb 05                	jmp    8006fa <vsnprintf+0x53>
  8006f5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8006fa:	c9                   	leave  
  8006fb:	c3                   	ret    

008006fc <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8006fc:	55                   	push   %ebp
  8006fd:	89 e5                	mov    %esp,%ebp
  8006ff:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800702:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800705:	50                   	push   %eax
  800706:	ff 75 10             	pushl  0x10(%ebp)
  800709:	ff 75 0c             	pushl  0xc(%ebp)
  80070c:	ff 75 08             	pushl  0x8(%ebp)
  80070f:	e8 93 ff ff ff       	call   8006a7 <vsnprintf>
	va_end(ap);

	return rc;
}
  800714:	c9                   	leave  
  800715:	c3                   	ret    
	...

00800718 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800718:	55                   	push   %ebp
  800719:	89 e5                	mov    %esp,%ebp
  80071b:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80071e:	80 3a 00             	cmpb   $0x0,(%edx)
  800721:	74 0e                	je     800731 <strlen+0x19>
  800723:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800728:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800729:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80072d:	75 f9                	jne    800728 <strlen+0x10>
  80072f:	eb 05                	jmp    800736 <strlen+0x1e>
  800731:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800736:	c9                   	leave  
  800737:	c3                   	ret    

00800738 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800738:	55                   	push   %ebp
  800739:	89 e5                	mov    %esp,%ebp
  80073b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80073e:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800741:	85 d2                	test   %edx,%edx
  800743:	74 17                	je     80075c <strnlen+0x24>
  800745:	80 39 00             	cmpb   $0x0,(%ecx)
  800748:	74 19                	je     800763 <strnlen+0x2b>
  80074a:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  80074f:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800750:	39 d0                	cmp    %edx,%eax
  800752:	74 14                	je     800768 <strnlen+0x30>
  800754:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800758:	75 f5                	jne    80074f <strnlen+0x17>
  80075a:	eb 0c                	jmp    800768 <strnlen+0x30>
  80075c:	b8 00 00 00 00       	mov    $0x0,%eax
  800761:	eb 05                	jmp    800768 <strnlen+0x30>
  800763:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800768:	c9                   	leave  
  800769:	c3                   	ret    

0080076a <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80076a:	55                   	push   %ebp
  80076b:	89 e5                	mov    %esp,%ebp
  80076d:	53                   	push   %ebx
  80076e:	8b 45 08             	mov    0x8(%ebp),%eax
  800771:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800774:	ba 00 00 00 00       	mov    $0x0,%edx
  800779:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  80077c:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  80077f:	42                   	inc    %edx
  800780:	84 c9                	test   %cl,%cl
  800782:	75 f5                	jne    800779 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800784:	5b                   	pop    %ebx
  800785:	c9                   	leave  
  800786:	c3                   	ret    

00800787 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800787:	55                   	push   %ebp
  800788:	89 e5                	mov    %esp,%ebp
  80078a:	53                   	push   %ebx
  80078b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80078e:	53                   	push   %ebx
  80078f:	e8 84 ff ff ff       	call   800718 <strlen>
  800794:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800797:	ff 75 0c             	pushl  0xc(%ebp)
  80079a:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  80079d:	50                   	push   %eax
  80079e:	e8 c7 ff ff ff       	call   80076a <strcpy>
	return dst;
}
  8007a3:	89 d8                	mov    %ebx,%eax
  8007a5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007a8:	c9                   	leave  
  8007a9:	c3                   	ret    

008007aa <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007aa:	55                   	push   %ebp
  8007ab:	89 e5                	mov    %esp,%ebp
  8007ad:	56                   	push   %esi
  8007ae:	53                   	push   %ebx
  8007af:	8b 45 08             	mov    0x8(%ebp),%eax
  8007b2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007b5:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007b8:	85 f6                	test   %esi,%esi
  8007ba:	74 15                	je     8007d1 <strncpy+0x27>
  8007bc:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  8007c1:	8a 1a                	mov    (%edx),%bl
  8007c3:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007c6:	80 3a 01             	cmpb   $0x1,(%edx)
  8007c9:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007cc:	41                   	inc    %ecx
  8007cd:	39 ce                	cmp    %ecx,%esi
  8007cf:	77 f0                	ja     8007c1 <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8007d1:	5b                   	pop    %ebx
  8007d2:	5e                   	pop    %esi
  8007d3:	c9                   	leave  
  8007d4:	c3                   	ret    

008007d5 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8007d5:	55                   	push   %ebp
  8007d6:	89 e5                	mov    %esp,%ebp
  8007d8:	57                   	push   %edi
  8007d9:	56                   	push   %esi
  8007da:	53                   	push   %ebx
  8007db:	8b 7d 08             	mov    0x8(%ebp),%edi
  8007de:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8007e1:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007e4:	85 f6                	test   %esi,%esi
  8007e6:	74 32                	je     80081a <strlcpy+0x45>
		while (--size > 0 && *src != '\0')
  8007e8:	83 fe 01             	cmp    $0x1,%esi
  8007eb:	74 22                	je     80080f <strlcpy+0x3a>
  8007ed:	8a 0b                	mov    (%ebx),%cl
  8007ef:	84 c9                	test   %cl,%cl
  8007f1:	74 20                	je     800813 <strlcpy+0x3e>
  8007f3:	89 f8                	mov    %edi,%eax
  8007f5:	ba 00 00 00 00       	mov    $0x0,%edx
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
  8007fa:	83 ee 02             	sub    $0x2,%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8007fd:	88 08                	mov    %cl,(%eax)
  8007ff:	40                   	inc    %eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800800:	39 f2                	cmp    %esi,%edx
  800802:	74 11                	je     800815 <strlcpy+0x40>
  800804:	8a 4c 13 01          	mov    0x1(%ebx,%edx,1),%cl
  800808:	42                   	inc    %edx
  800809:	84 c9                	test   %cl,%cl
  80080b:	75 f0                	jne    8007fd <strlcpy+0x28>
  80080d:	eb 06                	jmp    800815 <strlcpy+0x40>
  80080f:	89 f8                	mov    %edi,%eax
  800811:	eb 02                	jmp    800815 <strlcpy+0x40>
  800813:	89 f8                	mov    %edi,%eax
			*dst++ = *src++;
		*dst = '\0';
  800815:	c6 00 00             	movb   $0x0,(%eax)
  800818:	eb 02                	jmp    80081c <strlcpy+0x47>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80081a:	89 f8                	mov    %edi,%eax
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
		*dst = '\0';
	}
	return dst - dst_in;
  80081c:	29 f8                	sub    %edi,%eax
}
  80081e:	5b                   	pop    %ebx
  80081f:	5e                   	pop    %esi
  800820:	5f                   	pop    %edi
  800821:	c9                   	leave  
  800822:	c3                   	ret    

00800823 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800823:	55                   	push   %ebp
  800824:	89 e5                	mov    %esp,%ebp
  800826:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800829:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80082c:	8a 01                	mov    (%ecx),%al
  80082e:	84 c0                	test   %al,%al
  800830:	74 10                	je     800842 <strcmp+0x1f>
  800832:	3a 02                	cmp    (%edx),%al
  800834:	75 0c                	jne    800842 <strcmp+0x1f>
		p++, q++;
  800836:	41                   	inc    %ecx
  800837:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800838:	8a 01                	mov    (%ecx),%al
  80083a:	84 c0                	test   %al,%al
  80083c:	74 04                	je     800842 <strcmp+0x1f>
  80083e:	3a 02                	cmp    (%edx),%al
  800840:	74 f4                	je     800836 <strcmp+0x13>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800842:	0f b6 c0             	movzbl %al,%eax
  800845:	0f b6 12             	movzbl (%edx),%edx
  800848:	29 d0                	sub    %edx,%eax
}
  80084a:	c9                   	leave  
  80084b:	c3                   	ret    

0080084c <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80084c:	55                   	push   %ebp
  80084d:	89 e5                	mov    %esp,%ebp
  80084f:	53                   	push   %ebx
  800850:	8b 55 08             	mov    0x8(%ebp),%edx
  800853:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800856:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  800859:	85 c0                	test   %eax,%eax
  80085b:	74 1b                	je     800878 <strncmp+0x2c>
  80085d:	8a 1a                	mov    (%edx),%bl
  80085f:	84 db                	test   %bl,%bl
  800861:	74 24                	je     800887 <strncmp+0x3b>
  800863:	3a 19                	cmp    (%ecx),%bl
  800865:	75 20                	jne    800887 <strncmp+0x3b>
  800867:	48                   	dec    %eax
  800868:	74 15                	je     80087f <strncmp+0x33>
		n--, p++, q++;
  80086a:	42                   	inc    %edx
  80086b:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80086c:	8a 1a                	mov    (%edx),%bl
  80086e:	84 db                	test   %bl,%bl
  800870:	74 15                	je     800887 <strncmp+0x3b>
  800872:	3a 19                	cmp    (%ecx),%bl
  800874:	74 f1                	je     800867 <strncmp+0x1b>
  800876:	eb 0f                	jmp    800887 <strncmp+0x3b>
		n--, p++, q++;
	if (n == 0)
		return 0;
  800878:	b8 00 00 00 00       	mov    $0x0,%eax
  80087d:	eb 05                	jmp    800884 <strncmp+0x38>
  80087f:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800884:	5b                   	pop    %ebx
  800885:	c9                   	leave  
  800886:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800887:	0f b6 02             	movzbl (%edx),%eax
  80088a:	0f b6 11             	movzbl (%ecx),%edx
  80088d:	29 d0                	sub    %edx,%eax
  80088f:	eb f3                	jmp    800884 <strncmp+0x38>

00800891 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800891:	55                   	push   %ebp
  800892:	89 e5                	mov    %esp,%ebp
  800894:	8b 45 08             	mov    0x8(%ebp),%eax
  800897:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  80089a:	8a 10                	mov    (%eax),%dl
  80089c:	84 d2                	test   %dl,%dl
  80089e:	74 18                	je     8008b8 <strchr+0x27>
		if (*s == c)
  8008a0:	38 ca                	cmp    %cl,%dl
  8008a2:	75 06                	jne    8008aa <strchr+0x19>
  8008a4:	eb 17                	jmp    8008bd <strchr+0x2c>
  8008a6:	38 ca                	cmp    %cl,%dl
  8008a8:	74 13                	je     8008bd <strchr+0x2c>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8008aa:	40                   	inc    %eax
  8008ab:	8a 10                	mov    (%eax),%dl
  8008ad:	84 d2                	test   %dl,%dl
  8008af:	75 f5                	jne    8008a6 <strchr+0x15>
		if (*s == c)
			return (char *) s;
	return 0;
  8008b1:	b8 00 00 00 00       	mov    $0x0,%eax
  8008b6:	eb 05                	jmp    8008bd <strchr+0x2c>
  8008b8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008bd:	c9                   	leave  
  8008be:	c3                   	ret    

008008bf <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008bf:	55                   	push   %ebp
  8008c0:	89 e5                	mov    %esp,%ebp
  8008c2:	8b 45 08             	mov    0x8(%ebp),%eax
  8008c5:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8008c8:	8a 10                	mov    (%eax),%dl
  8008ca:	84 d2                	test   %dl,%dl
  8008cc:	74 11                	je     8008df <strfind+0x20>
		if (*s == c)
  8008ce:	38 ca                	cmp    %cl,%dl
  8008d0:	75 06                	jne    8008d8 <strfind+0x19>
  8008d2:	eb 0b                	jmp    8008df <strfind+0x20>
  8008d4:	38 ca                	cmp    %cl,%dl
  8008d6:	74 07                	je     8008df <strfind+0x20>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  8008d8:	40                   	inc    %eax
  8008d9:	8a 10                	mov    (%eax),%dl
  8008db:	84 d2                	test   %dl,%dl
  8008dd:	75 f5                	jne    8008d4 <strfind+0x15>
		if (*s == c)
			break;
	return (char *) s;
}
  8008df:	c9                   	leave  
  8008e0:	c3                   	ret    

008008e1 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008e1:	55                   	push   %ebp
  8008e2:	89 e5                	mov    %esp,%ebp
  8008e4:	57                   	push   %edi
  8008e5:	56                   	push   %esi
  8008e6:	53                   	push   %ebx
  8008e7:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008ea:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008ed:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8008f0:	85 c9                	test   %ecx,%ecx
  8008f2:	74 30                	je     800924 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008f4:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008fa:	75 25                	jne    800921 <memset+0x40>
  8008fc:	f6 c1 03             	test   $0x3,%cl
  8008ff:	75 20                	jne    800921 <memset+0x40>
		c &= 0xFF;
  800901:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800904:	89 d3                	mov    %edx,%ebx
  800906:	c1 e3 08             	shl    $0x8,%ebx
  800909:	89 d6                	mov    %edx,%esi
  80090b:	c1 e6 18             	shl    $0x18,%esi
  80090e:	89 d0                	mov    %edx,%eax
  800910:	c1 e0 10             	shl    $0x10,%eax
  800913:	09 f0                	or     %esi,%eax
  800915:	09 d0                	or     %edx,%eax
  800917:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800919:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  80091c:	fc                   	cld    
  80091d:	f3 ab                	rep stos %eax,%es:(%edi)
  80091f:	eb 03                	jmp    800924 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800921:	fc                   	cld    
  800922:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800924:	89 f8                	mov    %edi,%eax
  800926:	5b                   	pop    %ebx
  800927:	5e                   	pop    %esi
  800928:	5f                   	pop    %edi
  800929:	c9                   	leave  
  80092a:	c3                   	ret    

0080092b <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80092b:	55                   	push   %ebp
  80092c:	89 e5                	mov    %esp,%ebp
  80092e:	57                   	push   %edi
  80092f:	56                   	push   %esi
  800930:	8b 45 08             	mov    0x8(%ebp),%eax
  800933:	8b 75 0c             	mov    0xc(%ebp),%esi
  800936:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800939:	39 c6                	cmp    %eax,%esi
  80093b:	73 34                	jae    800971 <memmove+0x46>
  80093d:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800940:	39 d0                	cmp    %edx,%eax
  800942:	73 2d                	jae    800971 <memmove+0x46>
		s += n;
		d += n;
  800944:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800947:	f6 c2 03             	test   $0x3,%dl
  80094a:	75 1b                	jne    800967 <memmove+0x3c>
  80094c:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800952:	75 13                	jne    800967 <memmove+0x3c>
  800954:	f6 c1 03             	test   $0x3,%cl
  800957:	75 0e                	jne    800967 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800959:	83 ef 04             	sub    $0x4,%edi
  80095c:	8d 72 fc             	lea    -0x4(%edx),%esi
  80095f:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800962:	fd                   	std    
  800963:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800965:	eb 07                	jmp    80096e <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800967:	4f                   	dec    %edi
  800968:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  80096b:	fd                   	std    
  80096c:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80096e:	fc                   	cld    
  80096f:	eb 20                	jmp    800991 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800971:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800977:	75 13                	jne    80098c <memmove+0x61>
  800979:	a8 03                	test   $0x3,%al
  80097b:	75 0f                	jne    80098c <memmove+0x61>
  80097d:	f6 c1 03             	test   $0x3,%cl
  800980:	75 0a                	jne    80098c <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800982:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800985:	89 c7                	mov    %eax,%edi
  800987:	fc                   	cld    
  800988:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80098a:	eb 05                	jmp    800991 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  80098c:	89 c7                	mov    %eax,%edi
  80098e:	fc                   	cld    
  80098f:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800991:	5e                   	pop    %esi
  800992:	5f                   	pop    %edi
  800993:	c9                   	leave  
  800994:	c3                   	ret    

00800995 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800995:	55                   	push   %ebp
  800996:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800998:	ff 75 10             	pushl  0x10(%ebp)
  80099b:	ff 75 0c             	pushl  0xc(%ebp)
  80099e:	ff 75 08             	pushl  0x8(%ebp)
  8009a1:	e8 85 ff ff ff       	call   80092b <memmove>
}
  8009a6:	c9                   	leave  
  8009a7:	c3                   	ret    

008009a8 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009a8:	55                   	push   %ebp
  8009a9:	89 e5                	mov    %esp,%ebp
  8009ab:	57                   	push   %edi
  8009ac:	56                   	push   %esi
  8009ad:	53                   	push   %ebx
  8009ae:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8009b1:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009b4:	8b 7d 10             	mov    0x10(%ebp),%edi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009b7:	85 ff                	test   %edi,%edi
  8009b9:	74 32                	je     8009ed <memcmp+0x45>
		if (*s1 != *s2)
  8009bb:	8a 03                	mov    (%ebx),%al
  8009bd:	8a 0e                	mov    (%esi),%cl
  8009bf:	38 c8                	cmp    %cl,%al
  8009c1:	74 19                	je     8009dc <memcmp+0x34>
  8009c3:	eb 0d                	jmp    8009d2 <memcmp+0x2a>
  8009c5:	8a 44 13 01          	mov    0x1(%ebx,%edx,1),%al
  8009c9:	8a 4c 16 01          	mov    0x1(%esi,%edx,1),%cl
  8009cd:	42                   	inc    %edx
  8009ce:	38 c8                	cmp    %cl,%al
  8009d0:	74 10                	je     8009e2 <memcmp+0x3a>
			return (int) *s1 - (int) *s2;
  8009d2:	0f b6 c0             	movzbl %al,%eax
  8009d5:	0f b6 c9             	movzbl %cl,%ecx
  8009d8:	29 c8                	sub    %ecx,%eax
  8009da:	eb 16                	jmp    8009f2 <memcmp+0x4a>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009dc:	4f                   	dec    %edi
  8009dd:	ba 00 00 00 00       	mov    $0x0,%edx
  8009e2:	39 fa                	cmp    %edi,%edx
  8009e4:	75 df                	jne    8009c5 <memcmp+0x1d>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8009e6:	b8 00 00 00 00       	mov    $0x0,%eax
  8009eb:	eb 05                	jmp    8009f2 <memcmp+0x4a>
  8009ed:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009f2:	5b                   	pop    %ebx
  8009f3:	5e                   	pop    %esi
  8009f4:	5f                   	pop    %edi
  8009f5:	c9                   	leave  
  8009f6:	c3                   	ret    

008009f7 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009f7:	55                   	push   %ebp
  8009f8:	89 e5                	mov    %esp,%ebp
  8009fa:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  8009fd:	89 c2                	mov    %eax,%edx
  8009ff:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a02:	39 d0                	cmp    %edx,%eax
  800a04:	73 12                	jae    800a18 <memfind+0x21>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a06:	8a 4d 0c             	mov    0xc(%ebp),%cl
  800a09:	38 08                	cmp    %cl,(%eax)
  800a0b:	75 06                	jne    800a13 <memfind+0x1c>
  800a0d:	eb 09                	jmp    800a18 <memfind+0x21>
  800a0f:	38 08                	cmp    %cl,(%eax)
  800a11:	74 05                	je     800a18 <memfind+0x21>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a13:	40                   	inc    %eax
  800a14:	39 c2                	cmp    %eax,%edx
  800a16:	77 f7                	ja     800a0f <memfind+0x18>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a18:	c9                   	leave  
  800a19:	c3                   	ret    

00800a1a <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a1a:	55                   	push   %ebp
  800a1b:	89 e5                	mov    %esp,%ebp
  800a1d:	57                   	push   %edi
  800a1e:	56                   	push   %esi
  800a1f:	53                   	push   %ebx
  800a20:	8b 55 08             	mov    0x8(%ebp),%edx
  800a23:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a26:	eb 01                	jmp    800a29 <strtol+0xf>
		s++;
  800a28:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a29:	8a 02                	mov    (%edx),%al
  800a2b:	3c 20                	cmp    $0x20,%al
  800a2d:	74 f9                	je     800a28 <strtol+0xe>
  800a2f:	3c 09                	cmp    $0x9,%al
  800a31:	74 f5                	je     800a28 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a33:	3c 2b                	cmp    $0x2b,%al
  800a35:	75 08                	jne    800a3f <strtol+0x25>
		s++;
  800a37:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a38:	bf 00 00 00 00       	mov    $0x0,%edi
  800a3d:	eb 13                	jmp    800a52 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a3f:	3c 2d                	cmp    $0x2d,%al
  800a41:	75 0a                	jne    800a4d <strtol+0x33>
		s++, neg = 1;
  800a43:	8d 52 01             	lea    0x1(%edx),%edx
  800a46:	bf 01 00 00 00       	mov    $0x1,%edi
  800a4b:	eb 05                	jmp    800a52 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a4d:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a52:	85 db                	test   %ebx,%ebx
  800a54:	74 05                	je     800a5b <strtol+0x41>
  800a56:	83 fb 10             	cmp    $0x10,%ebx
  800a59:	75 28                	jne    800a83 <strtol+0x69>
  800a5b:	8a 02                	mov    (%edx),%al
  800a5d:	3c 30                	cmp    $0x30,%al
  800a5f:	75 10                	jne    800a71 <strtol+0x57>
  800a61:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800a65:	75 0a                	jne    800a71 <strtol+0x57>
		s += 2, base = 16;
  800a67:	83 c2 02             	add    $0x2,%edx
  800a6a:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a6f:	eb 12                	jmp    800a83 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800a71:	85 db                	test   %ebx,%ebx
  800a73:	75 0e                	jne    800a83 <strtol+0x69>
  800a75:	3c 30                	cmp    $0x30,%al
  800a77:	75 05                	jne    800a7e <strtol+0x64>
		s++, base = 8;
  800a79:	42                   	inc    %edx
  800a7a:	b3 08                	mov    $0x8,%bl
  800a7c:	eb 05                	jmp    800a83 <strtol+0x69>
	else if (base == 0)
		base = 10;
  800a7e:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800a83:	b8 00 00 00 00       	mov    $0x0,%eax
  800a88:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a8a:	8a 0a                	mov    (%edx),%cl
  800a8c:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800a8f:	80 fb 09             	cmp    $0x9,%bl
  800a92:	77 08                	ja     800a9c <strtol+0x82>
			dig = *s - '0';
  800a94:	0f be c9             	movsbl %cl,%ecx
  800a97:	83 e9 30             	sub    $0x30,%ecx
  800a9a:	eb 1e                	jmp    800aba <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800a9c:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800a9f:	80 fb 19             	cmp    $0x19,%bl
  800aa2:	77 08                	ja     800aac <strtol+0x92>
			dig = *s - 'a' + 10;
  800aa4:	0f be c9             	movsbl %cl,%ecx
  800aa7:	83 e9 57             	sub    $0x57,%ecx
  800aaa:	eb 0e                	jmp    800aba <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800aac:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800aaf:	80 fb 19             	cmp    $0x19,%bl
  800ab2:	77 13                	ja     800ac7 <strtol+0xad>
			dig = *s - 'A' + 10;
  800ab4:	0f be c9             	movsbl %cl,%ecx
  800ab7:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800aba:	39 f1                	cmp    %esi,%ecx
  800abc:	7d 0d                	jge    800acb <strtol+0xb1>
			break;
		s++, val = (val * base) + dig;
  800abe:	42                   	inc    %edx
  800abf:	0f af c6             	imul   %esi,%eax
  800ac2:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  800ac5:	eb c3                	jmp    800a8a <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800ac7:	89 c1                	mov    %eax,%ecx
  800ac9:	eb 02                	jmp    800acd <strtol+0xb3>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800acb:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800acd:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ad1:	74 05                	je     800ad8 <strtol+0xbe>
		*endptr = (char *) s;
  800ad3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800ad6:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800ad8:	85 ff                	test   %edi,%edi
  800ada:	74 04                	je     800ae0 <strtol+0xc6>
  800adc:	89 c8                	mov    %ecx,%eax
  800ade:	f7 d8                	neg    %eax
}
  800ae0:	5b                   	pop    %ebx
  800ae1:	5e                   	pop    %esi
  800ae2:	5f                   	pop    %edi
  800ae3:	c9                   	leave  
  800ae4:	c3                   	ret    
  800ae5:	00 00                	add    %al,(%eax)
	...

00800ae8 <syscall>:
	return ret;
}

static int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800ae8:	55                   	push   %ebp
  800ae9:	89 e5                	mov    %esp,%ebp
  800aeb:	57                   	push   %edi
  800aec:	56                   	push   %esi
  800aed:	53                   	push   %ebx
  800aee:	83 ec 1c             	sub    $0x1c,%esp
  800af1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800af4:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800af7:	89 ca                	mov    %ecx,%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800af9:	8b 75 14             	mov    0x14(%ebp),%esi
  800afc:	8b 7d 10             	mov    0x10(%ebp),%edi
  800aff:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800b02:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b05:	cd 30                	int    $0x30
  800b07:	89 c2                	mov    %eax,%edx
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b09:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800b0d:	74 1c                	je     800b2b <syscall+0x43>
  800b0f:	85 c0                	test   %eax,%eax
  800b11:	7e 18                	jle    800b2b <syscall+0x43>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b13:	83 ec 0c             	sub    $0xc,%esp
  800b16:	50                   	push   %eax
  800b17:	ff 75 e4             	pushl  -0x1c(%ebp)
  800b1a:	68 04 16 80 00       	push   $0x801604
  800b1f:	6a 42                	push   $0x42
  800b21:	68 21 16 80 00       	push   $0x801621
  800b26:	e8 21 05 00 00       	call   80104c <_panic>

	return ret;
}
  800b2b:	89 d0                	mov    %edx,%eax
  800b2d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b30:	5b                   	pop    %ebx
  800b31:	5e                   	pop    %esi
  800b32:	5f                   	pop    %edi
  800b33:	c9                   	leave  
  800b34:	c3                   	ret    

00800b35 <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{	
  800b35:	55                   	push   %ebp
  800b36:	89 e5                	mov    %esp,%ebp
  800b38:	83 ec 08             	sub    $0x8,%esp
	// my_sysenter(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
	// return;
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  800b3b:	6a 00                	push   $0x0
  800b3d:	6a 00                	push   $0x0
  800b3f:	6a 00                	push   $0x0
  800b41:	ff 75 0c             	pushl  0xc(%ebp)
  800b44:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b47:	ba 00 00 00 00       	mov    $0x0,%edx
  800b4c:	b8 00 00 00 00       	mov    $0x0,%eax
  800b51:	e8 92 ff ff ff       	call   800ae8 <syscall>
  800b56:	83 c4 10             	add    $0x10,%esp
	return;
}
  800b59:	c9                   	leave  
  800b5a:	c3                   	ret    

00800b5b <sys_cgetc>:

int
sys_cgetc(void)
{
  800b5b:	55                   	push   %ebp
  800b5c:	89 e5                	mov    %esp,%ebp
  800b5e:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_cgetc, 0, 0, 0, 0, 0, 0);
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  800b61:	6a 00                	push   $0x0
  800b63:	6a 00                	push   $0x0
  800b65:	6a 00                	push   $0x0
  800b67:	6a 00                	push   $0x0
  800b69:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b6e:	ba 00 00 00 00       	mov    $0x0,%edx
  800b73:	b8 01 00 00 00       	mov    $0x1,%eax
  800b78:	e8 6b ff ff ff       	call   800ae8 <syscall>
}
  800b7d:	c9                   	leave  
  800b7e:	c3                   	ret    

00800b7f <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b7f:	55                   	push   %ebp
  800b80:	89 e5                	mov    %esp,%ebp
  800b82:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  800b85:	6a 00                	push   $0x0
  800b87:	6a 00                	push   $0x0
  800b89:	6a 00                	push   $0x0
  800b8b:	6a 00                	push   $0x0
  800b8d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b90:	ba 01 00 00 00       	mov    $0x1,%edx
  800b95:	b8 03 00 00 00       	mov    $0x3,%eax
  800b9a:	e8 49 ff ff ff       	call   800ae8 <syscall>
}
  800b9f:	c9                   	leave  
  800ba0:	c3                   	ret    

00800ba1 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800ba1:	55                   	push   %ebp
  800ba2:	89 e5                	mov    %esp,%ebp
  800ba4:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_getenvid, 0, 0, 0, 0, 0, 0);
	return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  800ba7:	6a 00                	push   $0x0
  800ba9:	6a 00                	push   $0x0
  800bab:	6a 00                	push   $0x0
  800bad:	6a 00                	push   $0x0
  800baf:	b9 00 00 00 00       	mov    $0x0,%ecx
  800bb4:	ba 00 00 00 00       	mov    $0x0,%edx
  800bb9:	b8 02 00 00 00       	mov    $0x2,%eax
  800bbe:	e8 25 ff ff ff       	call   800ae8 <syscall>
}
  800bc3:	c9                   	leave  
  800bc4:	c3                   	ret    

00800bc5 <sys_yield>:

void
sys_yield(void)
{
  800bc5:	55                   	push   %ebp
  800bc6:	89 e5                	mov    %esp,%ebp
  800bc8:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  800bcb:	6a 00                	push   $0x0
  800bcd:	6a 00                	push   $0x0
  800bcf:	6a 00                	push   $0x0
  800bd1:	6a 00                	push   $0x0
  800bd3:	b9 00 00 00 00       	mov    $0x0,%ecx
  800bd8:	ba 00 00 00 00       	mov    $0x0,%edx
  800bdd:	b8 0a 00 00 00       	mov    $0xa,%eax
  800be2:	e8 01 ff ff ff       	call   800ae8 <syscall>
  800be7:	83 c4 10             	add    $0x10,%esp
}
  800bea:	c9                   	leave  
  800beb:	c3                   	ret    

00800bec <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800bec:	55                   	push   %ebp
  800bed:	89 e5                	mov    %esp,%ebp
  800bef:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  800bf2:	6a 00                	push   $0x0
  800bf4:	6a 00                	push   $0x0
  800bf6:	ff 75 10             	pushl  0x10(%ebp)
  800bf9:	ff 75 0c             	pushl  0xc(%ebp)
  800bfc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800bff:	ba 01 00 00 00       	mov    $0x1,%edx
  800c04:	b8 04 00 00 00       	mov    $0x4,%eax
  800c09:	e8 da fe ff ff       	call   800ae8 <syscall>
}
  800c0e:	c9                   	leave  
  800c0f:	c3                   	ret    

00800c10 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c10:	55                   	push   %ebp
  800c11:	89 e5                	mov    %esp,%ebp
  800c13:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
  800c16:	ff 75 18             	pushl  0x18(%ebp)
  800c19:	ff 75 14             	pushl  0x14(%ebp)
  800c1c:	ff 75 10             	pushl  0x10(%ebp)
  800c1f:	ff 75 0c             	pushl  0xc(%ebp)
  800c22:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c25:	ba 01 00 00 00       	mov    $0x1,%edx
  800c2a:	b8 05 00 00 00       	mov    $0x5,%eax
  800c2f:	e8 b4 fe ff ff       	call   800ae8 <syscall>
}
  800c34:	c9                   	leave  
  800c35:	c3                   	ret    

00800c36 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c36:	55                   	push   %ebp
  800c37:	89 e5                	mov    %esp,%ebp
  800c39:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  800c3c:	6a 00                	push   $0x0
  800c3e:	6a 00                	push   $0x0
  800c40:	6a 00                	push   $0x0
  800c42:	ff 75 0c             	pushl  0xc(%ebp)
  800c45:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c48:	ba 01 00 00 00       	mov    $0x1,%edx
  800c4d:	b8 06 00 00 00       	mov    $0x6,%eax
  800c52:	e8 91 fe ff ff       	call   800ae8 <syscall>
}
  800c57:	c9                   	leave  
  800c58:	c3                   	ret    

00800c59 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c59:	55                   	push   %ebp
  800c5a:	89 e5                	mov    %esp,%ebp
  800c5c:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  800c5f:	6a 00                	push   $0x0
  800c61:	6a 00                	push   $0x0
  800c63:	6a 00                	push   $0x0
  800c65:	ff 75 0c             	pushl  0xc(%ebp)
  800c68:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c6b:	ba 01 00 00 00       	mov    $0x1,%edx
  800c70:	b8 08 00 00 00       	mov    $0x8,%eax
  800c75:	e8 6e fe ff ff       	call   800ae8 <syscall>
}
  800c7a:	c9                   	leave  
  800c7b:	c3                   	ret    

00800c7c <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800c7c:	55                   	push   %ebp
  800c7d:	89 e5                	mov    %esp,%ebp
  800c7f:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  800c82:	6a 00                	push   $0x0
  800c84:	6a 00                	push   $0x0
  800c86:	6a 00                	push   $0x0
  800c88:	ff 75 0c             	pushl  0xc(%ebp)
  800c8b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c8e:	ba 01 00 00 00       	mov    $0x1,%edx
  800c93:	b8 09 00 00 00       	mov    $0x9,%eax
  800c98:	e8 4b fe ff ff       	call   800ae8 <syscall>
}
  800c9d:	c9                   	leave  
  800c9e:	c3                   	ret    

00800c9f <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800c9f:	55                   	push   %ebp
  800ca0:	89 e5                	mov    %esp,%ebp
  800ca2:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  800ca5:	6a 00                	push   $0x0
  800ca7:	ff 75 14             	pushl  0x14(%ebp)
  800caa:	ff 75 10             	pushl  0x10(%ebp)
  800cad:	ff 75 0c             	pushl  0xc(%ebp)
  800cb0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800cb3:	ba 00 00 00 00       	mov    $0x0,%edx
  800cb8:	b8 0b 00 00 00       	mov    $0xb,%eax
  800cbd:	e8 26 fe ff ff       	call   800ae8 <syscall>
}
  800cc2:	c9                   	leave  
  800cc3:	c3                   	ret    

00800cc4 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800cc4:	55                   	push   %ebp
  800cc5:	89 e5                	mov    %esp,%ebp
  800cc7:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  800cca:	6a 00                	push   $0x0
  800ccc:	6a 00                	push   $0x0
  800cce:	6a 00                	push   $0x0
  800cd0:	6a 00                	push   $0x0
  800cd2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800cd5:	ba 01 00 00 00       	mov    $0x1,%edx
  800cda:	b8 0c 00 00 00       	mov    $0xc,%eax
  800cdf:	e8 04 fe ff ff       	call   800ae8 <syscall>
}
  800ce4:	c9                   	leave  
  800ce5:	c3                   	ret    
	...

00800ce8 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800ce8:	55                   	push   %ebp
  800ce9:	89 e5                	mov    %esp,%ebp
  800ceb:	53                   	push   %ebx
  800cec:	83 ec 04             	sub    $0x4,%esp
  800cef:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800cf2:	8b 18                	mov    (%eax),%ebx

	// LAB 4: Your code here.
	
	// cprintf("PAGE FAULT HANDLER, 0x%08x %d\n", (uint32_t)addr, err & FEC_WR);
	
	if ((err & FEC_WR) == 0)
  800cf4:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800cf8:	75 14                	jne    800d0e <pgfault+0x26>
		panic("pgfault, the fault is not a write\n");
  800cfa:	83 ec 04             	sub    $0x4,%esp
  800cfd:	68 30 16 80 00       	push   $0x801630
  800d02:	6a 20                	push   $0x20
  800d04:	68 74 17 80 00       	push   $0x801774
  800d09:	e8 3e 03 00 00       	call   80104c <_panic>

	uint32_t uaddr = (uint32_t) addr;
	if ((uvpd[PDX(addr)] & PTE_P) == 0 || (uvpt[uaddr / PGSIZE] & PTE_COW) == 0) {
  800d0e:	89 d8                	mov    %ebx,%eax
  800d10:	c1 e8 16             	shr    $0x16,%eax
  800d13:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800d1a:	a8 01                	test   $0x1,%al
  800d1c:	74 11                	je     800d2f <pgfault+0x47>
  800d1e:	89 d8                	mov    %ebx,%eax
  800d20:	c1 e8 0c             	shr    $0xc,%eax
  800d23:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800d2a:	f6 c4 08             	test   $0x8,%ah
  800d2d:	75 14                	jne    800d43 <pgfault+0x5b>
		panic("pgfault, not a copy-on-write page\n");
  800d2f:	83 ec 04             	sub    $0x4,%esp
  800d32:	68 54 16 80 00       	push   $0x801654
  800d37:	6a 24                	push   $0x24
  800d39:	68 74 17 80 00       	push   $0x801774
  800d3e:	e8 09 03 00 00       	call   80104c <_panic>
	//   No need to explicitly delete the old page's mapping.

	// LAB 4: Your code here.

	// static int sys_page_alloc(envid_t envid, void *va, int perm)
	r = sys_page_alloc(0, (void *)PFTEMP, PTE_W | PTE_U | PTE_P);
  800d43:	83 ec 04             	sub    $0x4,%esp
  800d46:	6a 07                	push   $0x7
  800d48:	68 00 f0 7f 00       	push   $0x7ff000
  800d4d:	6a 00                	push   $0x0
  800d4f:	e8 98 fe ff ff       	call   800bec <sys_page_alloc>
	if (r < 0) panic("pgfault, sys_page_alloc error : %e\n", r);
  800d54:	83 c4 10             	add    $0x10,%esp
  800d57:	85 c0                	test   %eax,%eax
  800d59:	79 12                	jns    800d6d <pgfault+0x85>
  800d5b:	50                   	push   %eax
  800d5c:	68 78 16 80 00       	push   $0x801678
  800d61:	6a 32                	push   $0x32
  800d63:	68 74 17 80 00       	push   $0x801774
  800d68:	e8 df 02 00 00       	call   80104c <_panic>

	// Oh my god, I forget this at the first, it waste me a lot of time to debug!!!
	addr = ROUNDDOWN(addr, PGSIZE);
  800d6d:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	
	memcpy(PFTEMP, addr, PGSIZE);
  800d73:	83 ec 04             	sub    $0x4,%esp
  800d76:	68 00 10 00 00       	push   $0x1000
  800d7b:	53                   	push   %ebx
  800d7c:	68 00 f0 7f 00       	push   $0x7ff000
  800d81:	e8 0f fc ff ff       	call   800995 <memcpy>
	
	r = sys_page_map(0, PFTEMP, 0, addr, PTE_W | PTE_U | PTE_P);
  800d86:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800d8d:	53                   	push   %ebx
  800d8e:	6a 00                	push   $0x0
  800d90:	68 00 f0 7f 00       	push   $0x7ff000
  800d95:	6a 00                	push   $0x0
  800d97:	e8 74 fe ff ff       	call   800c10 <sys_page_map>
	if (r < 0) panic("pgfault, sys_page_map error : %e\n", r);
  800d9c:	83 c4 20             	add    $0x20,%esp
  800d9f:	85 c0                	test   %eax,%eax
  800da1:	79 12                	jns    800db5 <pgfault+0xcd>
  800da3:	50                   	push   %eax
  800da4:	68 9c 16 80 00       	push   $0x80169c
  800da9:	6a 3a                	push   $0x3a
  800dab:	68 74 17 80 00       	push   $0x801774
  800db0:	e8 97 02 00 00       	call   80104c <_panic>

	return;
}
  800db5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800db8:	c9                   	leave  
  800db9:	c3                   	ret    

00800dba <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800dba:	55                   	push   %ebp
  800dbb:	89 e5                	mov    %esp,%ebp
  800dbd:	57                   	push   %edi
  800dbe:	56                   	push   %esi
  800dbf:	53                   	push   %ebx
  800dc0:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	set_pgfault_handler(pgfault);
  800dc3:	68 e8 0c 80 00       	push   $0x800ce8
  800dc8:	e8 c7 02 00 00       	call   801094 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  800dcd:	ba 07 00 00 00       	mov    $0x7,%edx
  800dd2:	89 d0                	mov    %edx,%eax
  800dd4:	cd 30                	int    $0x30
  800dd6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800dd9:	89 c7                	mov    %eax,%edi
	int childpid = sys_exofork();
	if (childpid < 0) {
  800ddb:	83 c4 10             	add    $0x10,%esp
  800dde:	85 c0                	test   %eax,%eax
  800de0:	79 12                	jns    800df4 <fork+0x3a>
		panic("fork sys_exofork error : %e\n", childpid);
  800de2:	50                   	push   %eax
  800de3:	68 7f 17 80 00       	push   $0x80177f
  800de8:	6a 79                	push   $0x79
  800dea:	68 74 17 80 00       	push   $0x801774
  800def:	e8 58 02 00 00       	call   80104c <_panic>
	}
	int r;

	if (childpid == 0) {
  800df4:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800df8:	75 25                	jne    800e1f <fork+0x65>
		// child process
		// Remember to fix "thisenv" in the child process. ??? 
		thisenv = &envs[ENVX(sys_getenvid())];
  800dfa:	e8 a2 fd ff ff       	call   800ba1 <sys_getenvid>
  800dff:	25 ff 03 00 00       	and    $0x3ff,%eax
  800e04:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800e0b:	c1 e0 07             	shl    $0x7,%eax
  800e0e:	29 d0                	sub    %edx,%eax
  800e10:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800e15:	a3 04 20 80 00       	mov    %eax,0x802004
		// cprintf("fork child ok\n");
		return 0;
  800e1a:	e9 7b 01 00 00       	jmp    800f9a <fork+0x1e0>
	if (childpid < 0) {
		panic("fork sys_exofork error : %e\n", childpid);
	}
	int r;

	if (childpid == 0) {
  800e1f:	bb 00 00 00 00       	mov    $0x0,%ebx
	} else {
		// map page to new environment
		// kernel page is already in new environment
		uint32_t i;
		for (i = 0; i != UTOP; i += PGSIZE) 
		if ((uvpd[PDX(i)] & PTE_P) && (uvpt[i / PGSIZE] & PTE_P) && (uvpt[i / PGSIZE] & PTE_U)) {
  800e24:	89 d8                	mov    %ebx,%eax
  800e26:	c1 e8 16             	shr    $0x16,%eax
  800e29:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800e30:	a8 01                	test   $0x1,%al
  800e32:	0f 84 cd 00 00 00    	je     800f05 <fork+0x14b>
  800e38:	89 d8                	mov    %ebx,%eax
  800e3a:	c1 e8 0c             	shr    $0xc,%eax
  800e3d:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800e44:	f6 c2 01             	test   $0x1,%dl
  800e47:	0f 84 b8 00 00 00    	je     800f05 <fork+0x14b>
  800e4d:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800e54:	f6 c2 04             	test   $0x4,%dl
  800e57:	0f 84 a8 00 00 00    	je     800f05 <fork+0x14b>
//
static int
duppage(envid_t envid, unsigned pn)
{
	// do not dup exception stack
	if (pn * PGSIZE == UXSTACKTOP - PGSIZE) return 0;
  800e5d:	89 c6                	mov    %eax,%esi
  800e5f:	c1 e6 0c             	shl    $0xc,%esi
  800e62:	81 fe 00 f0 bf ee    	cmp    $0xeebff000,%esi
  800e68:	0f 84 97 00 00 00    	je     800f05 <fork+0x14b>

	int r;
	void * addr = (void *)(pn * PGSIZE);
	if ((uvpt[pn] & PTE_W) || (uvpt[pn] & PTE_COW)) {
  800e6e:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800e75:	f6 c2 02             	test   $0x2,%dl
  800e78:	75 0c                	jne    800e86 <fork+0xcc>
  800e7a:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800e81:	f6 c4 08             	test   $0x8,%ah
  800e84:	74 57                	je     800edd <fork+0x123>
		// cow
		r = sys_page_map(0, addr, envid, addr, PTE_COW | PTE_P | PTE_U);
  800e86:	83 ec 0c             	sub    $0xc,%esp
  800e89:	68 05 08 00 00       	push   $0x805
  800e8e:	56                   	push   %esi
  800e8f:	57                   	push   %edi
  800e90:	56                   	push   %esi
  800e91:	6a 00                	push   $0x0
  800e93:	e8 78 fd ff ff       	call   800c10 <sys_page_map>
		if (r < 0) panic("duppage sys_page_map error : %e\n", r);
  800e98:	83 c4 20             	add    $0x20,%esp
  800e9b:	85 c0                	test   %eax,%eax
  800e9d:	79 12                	jns    800eb1 <fork+0xf7>
  800e9f:	50                   	push   %eax
  800ea0:	68 c0 16 80 00       	push   $0x8016c0
  800ea5:	6a 55                	push   $0x55
  800ea7:	68 74 17 80 00       	push   $0x801774
  800eac:	e8 9b 01 00 00       	call   80104c <_panic>
		
		r = sys_page_map(0, addr, 0, addr, PTE_COW | PTE_P | PTE_U);
  800eb1:	83 ec 0c             	sub    $0xc,%esp
  800eb4:	68 05 08 00 00       	push   $0x805
  800eb9:	56                   	push   %esi
  800eba:	6a 00                	push   $0x0
  800ebc:	56                   	push   %esi
  800ebd:	6a 00                	push   $0x0
  800ebf:	e8 4c fd ff ff       	call   800c10 <sys_page_map>
		if (r < 0) panic("duppage sys_page_map error : %e\n", r);
  800ec4:	83 c4 20             	add    $0x20,%esp
  800ec7:	85 c0                	test   %eax,%eax
  800ec9:	79 3a                	jns    800f05 <fork+0x14b>
  800ecb:	50                   	push   %eax
  800ecc:	68 c0 16 80 00       	push   $0x8016c0
  800ed1:	6a 58                	push   $0x58
  800ed3:	68 74 17 80 00       	push   $0x801774
  800ed8:	e8 6f 01 00 00       	call   80104c <_panic>
	} else {
		// read only
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U);
  800edd:	83 ec 0c             	sub    $0xc,%esp
  800ee0:	6a 05                	push   $0x5
  800ee2:	56                   	push   %esi
  800ee3:	57                   	push   %edi
  800ee4:	56                   	push   %esi
  800ee5:	6a 00                	push   $0x0
  800ee7:	e8 24 fd ff ff       	call   800c10 <sys_page_map>
		if (r < 0) panic("duppage sys_page_map error : %e\n", r);
  800eec:	83 c4 20             	add    $0x20,%esp
  800eef:	85 c0                	test   %eax,%eax
  800ef1:	79 12                	jns    800f05 <fork+0x14b>
  800ef3:	50                   	push   %eax
  800ef4:	68 c0 16 80 00       	push   $0x8016c0
  800ef9:	6a 5c                	push   $0x5c
  800efb:	68 74 17 80 00       	push   $0x801774
  800f00:	e8 47 01 00 00       	call   80104c <_panic>
		return 0;
	} else {
		// map page to new environment
		// kernel page is already in new environment
		uint32_t i;
		for (i = 0; i != UTOP; i += PGSIZE) 
  800f05:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  800f0b:	81 fb 00 00 c0 ee    	cmp    $0xeec00000,%ebx
  800f11:	0f 85 0d ff ff ff    	jne    800e24 <fork+0x6a>
		if ((uvpd[PDX(i)] & PTE_P) && (uvpt[i / PGSIZE] & PTE_P) && (uvpt[i / PGSIZE] & PTE_U)) {
			duppage(childpid, i / PGSIZE);
		}

		// allocate exception stack
		r = sys_page_alloc(childpid, (void *)(UXSTACKTOP - PGSIZE), PTE_U | PTE_W | PTE_P);
  800f17:	83 ec 04             	sub    $0x4,%esp
  800f1a:	6a 07                	push   $0x7
  800f1c:	68 00 f0 bf ee       	push   $0xeebff000
  800f21:	ff 75 e4             	pushl  -0x1c(%ebp)
  800f24:	e8 c3 fc ff ff       	call   800bec <sys_page_alloc>
		if (r < 0) panic("fork, sys_page_alloc user exception stack error : %e\n", r);
  800f29:	83 c4 10             	add    $0x10,%esp
  800f2c:	85 c0                	test   %eax,%eax
  800f2e:	79 15                	jns    800f45 <fork+0x18b>
  800f30:	50                   	push   %eax
  800f31:	68 e4 16 80 00       	push   $0x8016e4
  800f36:	68 8e 00 00 00       	push   $0x8e
  800f3b:	68 74 17 80 00       	push   $0x801774
  800f40:	e8 07 01 00 00       	call   80104c <_panic>

		// set user environment user page fault handler 
		extern void _pgfault_upcall(void);
		r = sys_env_set_pgfault_upcall(childpid, _pgfault_upcall);
  800f45:	83 ec 08             	sub    $0x8,%esp
  800f48:	68 00 11 80 00       	push   $0x801100
  800f4d:	ff 75 e4             	pushl  -0x1c(%ebp)
  800f50:	e8 27 fd ff ff       	call   800c7c <sys_env_set_pgfault_upcall>
		if (r < 0) panic("fork, set pgfault upcall fail : %e\n", r);
  800f55:	83 c4 10             	add    $0x10,%esp
  800f58:	85 c0                	test   %eax,%eax
  800f5a:	79 15                	jns    800f71 <fork+0x1b7>
  800f5c:	50                   	push   %eax
  800f5d:	68 1c 17 80 00       	push   $0x80171c
  800f62:	68 93 00 00 00       	push   $0x93
  800f67:	68 74 17 80 00       	push   $0x801774
  800f6c:	e8 db 00 00 00       	call   80104c <_panic>

		// mark the child as runnable and return
		r = sys_env_set_status(childpid, ENV_RUNNABLE);
  800f71:	83 ec 08             	sub    $0x8,%esp
  800f74:	6a 02                	push   $0x2
  800f76:	ff 75 e4             	pushl  -0x1c(%ebp)
  800f79:	e8 db fc ff ff       	call   800c59 <sys_env_set_status>
		if (r < 0) panic("fork, set child process to ENV_RUNNABLE error : %e\n", r);
  800f7e:	83 c4 10             	add    $0x10,%esp
  800f81:	85 c0                	test   %eax,%eax
  800f83:	79 15                	jns    800f9a <fork+0x1e0>
  800f85:	50                   	push   %eax
  800f86:	68 40 17 80 00       	push   $0x801740
  800f8b:	68 97 00 00 00       	push   $0x97
  800f90:	68 74 17 80 00       	push   $0x801774
  800f95:	e8 b2 00 00 00       	call   80104c <_panic>
		// cprintf("fork father ok!");
		return childpid;
	}

	panic("fork not implemented");
}
  800f9a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800f9d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800fa0:	5b                   	pop    %ebx
  800fa1:	5e                   	pop    %esi
  800fa2:	5f                   	pop    %edi
  800fa3:	c9                   	leave  
  800fa4:	c3                   	ret    

00800fa5 <sfork>:

// Challenge!
int
sfork(void)
{
  800fa5:	55                   	push   %ebp
  800fa6:	89 e5                	mov    %esp,%ebp
  800fa8:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  800fab:	68 9c 17 80 00       	push   $0x80179c
  800fb0:	68 a4 00 00 00       	push   $0xa4
  800fb5:	68 74 17 80 00       	push   $0x801774
  800fba:	e8 8d 00 00 00       	call   80104c <_panic>
	...

00800fc0 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  800fc0:	55                   	push   %ebp
  800fc1:	89 e5                	mov    %esp,%ebp
  800fc3:	83 ec 0c             	sub    $0xc,%esp
	// LAB 4: Your code here.
	panic("ipc_recv not implemented");
  800fc6:	68 b2 17 80 00       	push   $0x8017b2
  800fcb:	6a 1a                	push   $0x1a
  800fcd:	68 cb 17 80 00       	push   $0x8017cb
  800fd2:	e8 75 00 00 00       	call   80104c <_panic>

00800fd7 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  800fd7:	55                   	push   %ebp
  800fd8:	89 e5                	mov    %esp,%ebp
  800fda:	83 ec 0c             	sub    $0xc,%esp
	// LAB 4: Your code here.
	panic("ipc_send not implemented");
  800fdd:	68 d5 17 80 00       	push   $0x8017d5
  800fe2:	6a 2a                	push   $0x2a
  800fe4:	68 cb 17 80 00       	push   $0x8017cb
  800fe9:	e8 5e 00 00 00       	call   80104c <_panic>

00800fee <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  800fee:	55                   	push   %ebp
  800fef:	89 e5                	mov    %esp,%ebp
  800ff1:	53                   	push   %ebx
  800ff2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  800ff5:	39 1d 50 00 c0 ee    	cmp    %ebx,0xeec00050
  800ffb:	74 22                	je     80101f <ipc_find_env+0x31>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  800ffd:	b8 01 00 00 00       	mov    $0x1,%eax
		if (envs[i].env_type == type)
  801002:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  801009:	89 c2                	mov    %eax,%edx
  80100b:	c1 e2 07             	shl    $0x7,%edx
  80100e:	29 ca                	sub    %ecx,%edx
  801010:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801016:	8b 52 50             	mov    0x50(%edx),%edx
  801019:	39 da                	cmp    %ebx,%edx
  80101b:	75 1d                	jne    80103a <ipc_find_env+0x4c>
  80101d:	eb 05                	jmp    801024 <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80101f:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
			return envs[i].env_id;
  801024:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  80102b:	c1 e0 07             	shl    $0x7,%eax
  80102e:	29 d0                	sub    %edx,%eax
  801030:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  801035:	8b 40 40             	mov    0x40(%eax),%eax
  801038:	eb 0c                	jmp    801046 <ipc_find_env+0x58>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80103a:	40                   	inc    %eax
  80103b:	3d 00 04 00 00       	cmp    $0x400,%eax
  801040:	75 c0                	jne    801002 <ipc_find_env+0x14>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801042:	66 b8 00 00          	mov    $0x0,%ax
}
  801046:	5b                   	pop    %ebx
  801047:	c9                   	leave  
  801048:	c3                   	ret    
  801049:	00 00                	add    %al,(%eax)
	...

0080104c <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80104c:	55                   	push   %ebp
  80104d:	89 e5                	mov    %esp,%ebp
  80104f:	56                   	push   %esi
  801050:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801051:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801054:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  80105a:	e8 42 fb ff ff       	call   800ba1 <sys_getenvid>
  80105f:	83 ec 0c             	sub    $0xc,%esp
  801062:	ff 75 0c             	pushl  0xc(%ebp)
  801065:	ff 75 08             	pushl  0x8(%ebp)
  801068:	53                   	push   %ebx
  801069:	50                   	push   %eax
  80106a:	68 f0 17 80 00       	push   $0x8017f0
  80106f:	e8 40 f1 ff ff       	call   8001b4 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801074:	83 c4 18             	add    $0x18,%esp
  801077:	56                   	push   %esi
  801078:	ff 75 10             	pushl  0x10(%ebp)
  80107b:	e8 e3 f0 ff ff       	call   800163 <vcprintf>
	cprintf("\n");
  801080:	c7 04 24 2c 18 80 00 	movl   $0x80182c,(%esp)
  801087:	e8 28 f1 ff ff       	call   8001b4 <cprintf>
  80108c:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80108f:	cc                   	int3   
  801090:	eb fd                	jmp    80108f <_panic+0x43>
	...

00801094 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801094:	55                   	push   %ebp
  801095:	89 e5                	mov    %esp,%ebp
  801097:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  80109a:	83 3d 08 20 80 00 00 	cmpl   $0x0,0x802008
  8010a1:	75 52                	jne    8010f5 <set_pgfault_handler+0x61>
		// First time through!	
		// LAB 4: Your code here.

		//int sys_page_alloc(envid_t envid, void *va, int perm)
		r = sys_page_alloc(0, (void*)(UXSTACKTOP - PGSIZE), PTE_U | PTE_W | PTE_P);
  8010a3:	83 ec 04             	sub    $0x4,%esp
  8010a6:	6a 07                	push   $0x7
  8010a8:	68 00 f0 bf ee       	push   $0xeebff000
  8010ad:	6a 00                	push   $0x0
  8010af:	e8 38 fb ff ff       	call   800bec <sys_page_alloc>
		if (r < 0) {
  8010b4:	83 c4 10             	add    $0x10,%esp
  8010b7:	85 c0                	test   %eax,%eax
  8010b9:	79 12                	jns    8010cd <set_pgfault_handler+0x39>
			panic("sys_page_alloc error : %e\n", r);
  8010bb:	50                   	push   %eax
  8010bc:	68 13 18 80 00       	push   $0x801813
  8010c1:	6a 24                	push   $0x24
  8010c3:	68 2e 18 80 00       	push   $0x80182e
  8010c8:	e8 7f ff ff ff       	call   80104c <_panic>
		}

		// how to know envid, put 0, envid2env will help us to get curenv in syscall
		r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);		
  8010cd:	83 ec 08             	sub    $0x8,%esp
  8010d0:	68 00 11 80 00       	push   $0x801100
  8010d5:	6a 00                	push   $0x0
  8010d7:	e8 a0 fb ff ff       	call   800c7c <sys_env_set_pgfault_upcall>
		if (r < 0) {
  8010dc:	83 c4 10             	add    $0x10,%esp
  8010df:	85 c0                	test   %eax,%eax
  8010e1:	79 12                	jns    8010f5 <set_pgfault_handler+0x61>
			panic("sys_env_set_pgfault_upcall error : %e\n", r);
  8010e3:	50                   	push   %eax
  8010e4:	68 3c 18 80 00       	push   $0x80183c
  8010e9:	6a 2a                	push   $0x2a
  8010eb:	68 2e 18 80 00       	push   $0x80182e
  8010f0:	e8 57 ff ff ff       	call   80104c <_panic>
		}
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8010f5:	8b 45 08             	mov    0x8(%ebp),%eax
  8010f8:	a3 08 20 80 00       	mov    %eax,0x802008
}
  8010fd:	c9                   	leave  
  8010fe:	c3                   	ret    
	...

00801100 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801100:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801101:	a1 08 20 80 00       	mov    0x802008,%eax
	call *%eax
  801106:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801108:	83 c4 04             	add    $0x4,%esp
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	
	// fix old esp
	movl 0x30(%esp), %eax
  80110b:	8b 44 24 30          	mov    0x30(%esp),%eax
	subl $0x4, %eax
  80110f:	83 e8 04             	sub    $0x4,%eax
	movl %eax, 0x30(%esp)
  801112:	89 44 24 30          	mov    %eax,0x30(%esp)

	// set trap-time %eip
	movl 0x28(%esp), %ebx
  801116:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	movl %ebx, (%eax)
  80111a:	89 18                	mov    %ebx,(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $0x08, %esp 	// ignore err_code and fault_va
  80111c:	83 c4 08             	add    $0x8,%esp
	popal 				// restore registers
  80111f:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x04, %esp 	// ignore eip 
  801120:	83 c4 04             	add    $0x4,%esp
	popfl				// modify eflags
  801123:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  801124:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  801125:	c3                   	ret    
	...

00801128 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  801128:	55                   	push   %ebp
  801129:	89 e5                	mov    %esp,%ebp
  80112b:	57                   	push   %edi
  80112c:	56                   	push   %esi
  80112d:	83 ec 10             	sub    $0x10,%esp
  801130:	8b 7d 08             	mov    0x8(%ebp),%edi
  801133:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  801136:	89 7d f0             	mov    %edi,-0x10(%ebp)
  801139:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  80113c:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  80113f:	8b 45 14             	mov    0x14(%ebp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  801142:	85 c0                	test   %eax,%eax
  801144:	75 2e                	jne    801174 <__udivdi3+0x4c>
    {
      if (d0 > n1)
  801146:	39 f1                	cmp    %esi,%ecx
  801148:	77 5a                	ja     8011a4 <__udivdi3+0x7c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  80114a:	85 c9                	test   %ecx,%ecx
  80114c:	75 0b                	jne    801159 <__udivdi3+0x31>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  80114e:	b8 01 00 00 00       	mov    $0x1,%eax
  801153:	31 d2                	xor    %edx,%edx
  801155:	f7 f1                	div    %ecx
  801157:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  801159:	31 d2                	xor    %edx,%edx
  80115b:	89 f0                	mov    %esi,%eax
  80115d:	f7 f1                	div    %ecx
  80115f:	89 c6                	mov    %eax,%esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801161:	89 f8                	mov    %edi,%eax
  801163:	f7 f1                	div    %ecx
  801165:	89 c7                	mov    %eax,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801167:	89 f8                	mov    %edi,%eax
  801169:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  80116b:	83 c4 10             	add    $0x10,%esp
  80116e:	5e                   	pop    %esi
  80116f:	5f                   	pop    %edi
  801170:	c9                   	leave  
  801171:	c3                   	ret    
  801172:	66 90                	xchg   %ax,%ax
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801174:	39 f0                	cmp    %esi,%eax
  801176:	77 1c                	ja     801194 <__udivdi3+0x6c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  801178:	0f bd f8             	bsr    %eax,%edi
	  if (bm == 0)
  80117b:	83 f7 1f             	xor    $0x1f,%edi
  80117e:	75 3c                	jne    8011bc <__udivdi3+0x94>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801180:	39 f0                	cmp    %esi,%eax
  801182:	0f 82 90 00 00 00    	jb     801218 <__udivdi3+0xf0>
  801188:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80118b:	39 55 f4             	cmp    %edx,-0xc(%ebp)
  80118e:	0f 86 84 00 00 00    	jbe    801218 <__udivdi3+0xf0>
  801194:	31 f6                	xor    %esi,%esi
  801196:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801198:	89 f8                	mov    %edi,%eax
  80119a:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  80119c:	83 c4 10             	add    $0x10,%esp
  80119f:	5e                   	pop    %esi
  8011a0:	5f                   	pop    %edi
  8011a1:	c9                   	leave  
  8011a2:	c3                   	ret    
  8011a3:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8011a4:	89 f2                	mov    %esi,%edx
  8011a6:	89 f8                	mov    %edi,%eax
  8011a8:	f7 f1                	div    %ecx
  8011aa:	89 c7                	mov    %eax,%edi
  8011ac:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  8011ae:	89 f8                	mov    %edi,%eax
  8011b0:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  8011b2:	83 c4 10             	add    $0x10,%esp
  8011b5:	5e                   	pop    %esi
  8011b6:	5f                   	pop    %edi
  8011b7:	c9                   	leave  
  8011b8:	c3                   	ret    
  8011b9:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  8011bc:	89 f9                	mov    %edi,%ecx
  8011be:	d3 e0                	shl    %cl,%eax
  8011c0:	89 45 e8             	mov    %eax,-0x18(%ebp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  8011c3:	b8 20 00 00 00       	mov    $0x20,%eax
  8011c8:	29 f8                	sub    %edi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  8011ca:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8011cd:	88 c1                	mov    %al,%cl
  8011cf:	d3 ea                	shr    %cl,%edx
  8011d1:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  8011d4:	09 ca                	or     %ecx,%edx
  8011d6:	89 55 ec             	mov    %edx,-0x14(%ebp)
	      d0 = d0 << bm;
  8011d9:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8011dc:	89 f9                	mov    %edi,%ecx
  8011de:	d3 e2                	shl    %cl,%edx
  8011e0:	89 55 f4             	mov    %edx,-0xc(%ebp)
	      n2 = n1 >> b;
  8011e3:	89 f2                	mov    %esi,%edx
  8011e5:	88 c1                	mov    %al,%cl
  8011e7:	d3 ea                	shr    %cl,%edx
  8011e9:	89 55 e8             	mov    %edx,-0x18(%ebp)
	      n1 = (n1 << bm) | (n0 >> b);
  8011ec:	89 f2                	mov    %esi,%edx
  8011ee:	89 f9                	mov    %edi,%ecx
  8011f0:	d3 e2                	shl    %cl,%edx
  8011f2:	8b 75 f0             	mov    -0x10(%ebp),%esi
  8011f5:	88 c1                	mov    %al,%cl
  8011f7:	d3 ee                	shr    %cl,%esi
  8011f9:	09 d6                	or     %edx,%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  8011fb:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  8011fe:	89 f0                	mov    %esi,%eax
  801200:	89 ca                	mov    %ecx,%edx
  801202:	f7 75 ec             	divl   -0x14(%ebp)
  801205:	89 d1                	mov    %edx,%ecx
  801207:	89 c6                	mov    %eax,%esi
	      umul_ppmm (m1, m0, q0, d0);
  801209:	f7 65 f4             	mull   -0xc(%ebp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  80120c:	39 d1                	cmp    %edx,%ecx
  80120e:	72 28                	jb     801238 <__udivdi3+0x110>
  801210:	74 1a                	je     80122c <__udivdi3+0x104>
  801212:	89 f7                	mov    %esi,%edi
  801214:	31 f6                	xor    %esi,%esi
  801216:	eb 80                	jmp    801198 <__udivdi3+0x70>
	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  801218:	31 f6                	xor    %esi,%esi
  80121a:	bf 01 00 00 00       	mov    $0x1,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  80121f:	89 f8                	mov    %edi,%eax
  801221:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801223:	83 c4 10             	add    $0x10,%esp
  801226:	5e                   	pop    %esi
  801227:	5f                   	pop    %edi
  801228:	c9                   	leave  
  801229:	c3                   	ret    
  80122a:	66 90                	xchg   %ax,%ax

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  80122c:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80122f:	89 f9                	mov    %edi,%ecx
  801231:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801233:	39 c2                	cmp    %eax,%edx
  801235:	73 db                	jae    801212 <__udivdi3+0xea>
  801237:	90                   	nop
		{
		  q0--;
  801238:	8d 7e ff             	lea    -0x1(%esi),%edi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  80123b:	31 f6                	xor    %esi,%esi
  80123d:	e9 56 ff ff ff       	jmp    801198 <__udivdi3+0x70>
	...

00801244 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  801244:	55                   	push   %ebp
  801245:	89 e5                	mov    %esp,%ebp
  801247:	57                   	push   %edi
  801248:	56                   	push   %esi
  801249:	83 ec 20             	sub    $0x20,%esp
  80124c:	8b 45 08             	mov    0x8(%ebp),%eax
  80124f:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  801252:	89 45 e8             	mov    %eax,-0x18(%ebp)
  801255:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  801258:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  80125b:	8b 7d 14             	mov    0x14(%ebp),%edi
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  80125e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  n1 = nn.s.high;
  801261:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  801263:	85 ff                	test   %edi,%edi
  801265:	75 15                	jne    80127c <__umoddi3+0x38>
    {
      if (d0 > n1)
  801267:	39 f1                	cmp    %esi,%ecx
  801269:	0f 86 99 00 00 00    	jbe    801308 <__umoddi3+0xc4>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  80126f:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  801271:	89 d0                	mov    %edx,%eax
  801273:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801275:	83 c4 20             	add    $0x20,%esp
  801278:	5e                   	pop    %esi
  801279:	5f                   	pop    %edi
  80127a:	c9                   	leave  
  80127b:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  80127c:	39 f7                	cmp    %esi,%edi
  80127e:	0f 87 a4 00 00 00    	ja     801328 <__umoddi3+0xe4>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  801284:	0f bd c7             	bsr    %edi,%eax
	  if (bm == 0)
  801287:	83 f0 1f             	xor    $0x1f,%eax
  80128a:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80128d:	0f 84 a1 00 00 00    	je     801334 <__umoddi3+0xf0>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  801293:	89 f8                	mov    %edi,%eax
  801295:	8a 4d ec             	mov    -0x14(%ebp),%cl
  801298:	d3 e0                	shl    %cl,%eax
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  80129a:	bf 20 00 00 00       	mov    $0x20,%edi
  80129f:	2b 7d ec             	sub    -0x14(%ebp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  8012a2:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8012a5:	89 f9                	mov    %edi,%ecx
  8012a7:	d3 ea                	shr    %cl,%edx
  8012a9:	09 c2                	or     %eax,%edx
  8012ab:	89 55 f0             	mov    %edx,-0x10(%ebp)
	      d0 = d0 << bm;
  8012ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8012b1:	8a 4d ec             	mov    -0x14(%ebp),%cl
  8012b4:	d3 e0                	shl    %cl,%eax
  8012b6:	89 45 f4             	mov    %eax,-0xc(%ebp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  8012b9:	89 f2                	mov    %esi,%edx
  8012bb:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  8012bd:	8b 45 e8             	mov    -0x18(%ebp),%eax
  8012c0:	d3 e0                	shl    %cl,%eax
  8012c2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  8012c5:	8b 45 e8             	mov    -0x18(%ebp),%eax
  8012c8:	89 f9                	mov    %edi,%ecx
  8012ca:	d3 e8                	shr    %cl,%eax
  8012cc:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  8012ce:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  8012d0:	89 f2                	mov    %esi,%edx
  8012d2:	f7 75 f0             	divl   -0x10(%ebp)
  8012d5:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  8012d7:	f7 65 f4             	mull   -0xc(%ebp)
  8012da:	89 55 e8             	mov    %edx,-0x18(%ebp)
  8012dd:	89 c1                	mov    %eax,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8012df:	39 d6                	cmp    %edx,%esi
  8012e1:	72 71                	jb     801354 <__umoddi3+0x110>
  8012e3:	74 7f                	je     801364 <__umoddi3+0x120>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  8012e5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8012e8:	29 c8                	sub    %ecx,%eax
  8012ea:	19 d6                	sbb    %edx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  8012ec:	8a 4d ec             	mov    -0x14(%ebp),%cl
  8012ef:	d3 e8                	shr    %cl,%eax
  8012f1:	89 f2                	mov    %esi,%edx
  8012f3:	89 f9                	mov    %edi,%ecx
  8012f5:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  8012f7:	09 d0                	or     %edx,%eax
  8012f9:	89 f2                	mov    %esi,%edx
  8012fb:	8a 4d ec             	mov    -0x14(%ebp),%cl
  8012fe:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801300:	83 c4 20             	add    $0x20,%esp
  801303:	5e                   	pop    %esi
  801304:	5f                   	pop    %edi
  801305:	c9                   	leave  
  801306:	c3                   	ret    
  801307:	90                   	nop
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  801308:	85 c9                	test   %ecx,%ecx
  80130a:	75 0b                	jne    801317 <__umoddi3+0xd3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  80130c:	b8 01 00 00 00       	mov    $0x1,%eax
  801311:	31 d2                	xor    %edx,%edx
  801313:	f7 f1                	div    %ecx
  801315:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  801317:	89 f0                	mov    %esi,%eax
  801319:	31 d2                	xor    %edx,%edx
  80131b:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  80131d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801320:	f7 f1                	div    %ecx
  801322:	e9 4a ff ff ff       	jmp    801271 <__umoddi3+0x2d>
  801327:	90                   	nop
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  801328:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  80132a:	83 c4 20             	add    $0x20,%esp
  80132d:	5e                   	pop    %esi
  80132e:	5f                   	pop    %edi
  80132f:	c9                   	leave  
  801330:	c3                   	ret    
  801331:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801334:	39 f7                	cmp    %esi,%edi
  801336:	72 05                	jb     80133d <__umoddi3+0xf9>
  801338:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
  80133b:	77 0c                	ja     801349 <__umoddi3+0x105>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  80133d:	89 f2                	mov    %esi,%edx
  80133f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801342:	29 c8                	sub    %ecx,%eax
  801344:	19 fa                	sbb    %edi,%edx
  801346:	89 45 f0             	mov    %eax,-0x10(%ebp)

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  801349:	8b 45 f0             	mov    -0x10(%ebp),%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  80134c:	83 c4 20             	add    $0x20,%esp
  80134f:	5e                   	pop    %esi
  801350:	5f                   	pop    %edi
  801351:	c9                   	leave  
  801352:	c3                   	ret    
  801353:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  801354:	8b 55 e8             	mov    -0x18(%ebp),%edx
  801357:	89 c1                	mov    %eax,%ecx
  801359:	2b 4d f4             	sub    -0xc(%ebp),%ecx
  80135c:	1b 55 f0             	sbb    -0x10(%ebp),%edx
  80135f:	eb 84                	jmp    8012e5 <__umoddi3+0xa1>
  801361:	8d 76 00             	lea    0x0(%esi),%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801364:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801367:	72 eb                	jb     801354 <__umoddi3+0x110>
  801369:	89 f2                	mov    %esi,%edx
  80136b:	e9 75 ff ff ff       	jmp    8012e5 <__umoddi3+0xa1>
