
obj/user/spin.debug:     file format elf32-i386


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

00800034 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	53                   	push   %ebx
  800038:	83 ec 10             	sub    $0x10,%esp
	envid_t env;

	cprintf("I am the parent.  Forking the child...\n");
  80003b:	68 a0 21 80 00       	push   $0x8021a0
  800040:	e8 6f 01 00 00       	call   8001b4 <cprintf>
	if ((env = fork()) == 0) {
  800045:	e8 b4 0d 00 00       	call   800dfe <fork>
  80004a:	89 c3                	mov    %eax,%ebx
  80004c:	83 c4 10             	add    $0x10,%esp
  80004f:	85 c0                	test   %eax,%eax
  800051:	75 12                	jne    800065 <umain+0x31>
		cprintf("I am the child.  Spinning...\n");
  800053:	83 ec 0c             	sub    $0xc,%esp
  800056:	68 18 22 80 00       	push   $0x802218
  80005b:	e8 54 01 00 00       	call   8001b4 <cprintf>
  800060:	83 c4 10             	add    $0x10,%esp
  800063:	eb fe                	jmp    800063 <umain+0x2f>
		while (1)
			/* do nothing */;
	}

	cprintf("I am the parent.  Running the child...\n");
  800065:	83 ec 0c             	sub    $0xc,%esp
  800068:	68 c8 21 80 00       	push   $0x8021c8
  80006d:	e8 42 01 00 00       	call   8001b4 <cprintf>
	sys_yield();
  800072:	e8 4e 0b 00 00       	call   800bc5 <sys_yield>
	sys_yield();
  800077:	e8 49 0b 00 00       	call   800bc5 <sys_yield>
	sys_yield();
  80007c:	e8 44 0b 00 00       	call   800bc5 <sys_yield>
	sys_yield();
  800081:	e8 3f 0b 00 00       	call   800bc5 <sys_yield>
	sys_yield();
  800086:	e8 3a 0b 00 00       	call   800bc5 <sys_yield>
	sys_yield();
  80008b:	e8 35 0b 00 00       	call   800bc5 <sys_yield>
	sys_yield();
  800090:	e8 30 0b 00 00       	call   800bc5 <sys_yield>
	sys_yield();
  800095:	e8 2b 0b 00 00       	call   800bc5 <sys_yield>

	cprintf("I am the parent.  Killing the child...\n");
  80009a:	c7 04 24 f0 21 80 00 	movl   $0x8021f0,(%esp)
  8000a1:	e8 0e 01 00 00       	call   8001b4 <cprintf>
	sys_env_destroy(env);
  8000a6:	89 1c 24             	mov    %ebx,(%esp)
  8000a9:	e8 d1 0a 00 00       	call   800b7f <sys_env_destroy>
  8000ae:	83 c4 10             	add    $0x10,%esp
}
  8000b1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
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
  8000c3:	e8 d9 0a 00 00       	call   800ba1 <sys_getenvid>
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
  8000f3:	e8 3c ff ff ff       	call   800034 <umain>

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
  80010e:	e8 3f 11 00 00       	call   801252 <close_all>
	sys_env_destroy(0);
  800113:	83 ec 0c             	sub    $0xc,%esp
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
  80021c:	e8 23 1d 00 00       	call   801f44 <__udivdi3>
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
  800258:	e8 03 1e 00 00       	call   802060 <__umoddi3>
  80025d:	83 c4 14             	add    $0x14,%esp
  800260:	0f be 80 40 22 80 00 	movsbl 0x802240(%eax),%eax
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
  8003a4:	ff 24 85 80 23 80 00 	jmp    *0x802380(,%eax,4)
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
  80044b:	83 f8 0f             	cmp    $0xf,%eax
  80044e:	7f 0b                	jg     80045b <vprintfmt+0x142>
  800450:	8b 04 85 e0 24 80 00 	mov    0x8024e0(,%eax,4),%eax
  800457:	85 c0                	test   %eax,%eax
  800459:	75 1a                	jne    800475 <vprintfmt+0x15c>
				printfmt(putch, putdat, "error %d", err);
  80045b:	52                   	push   %edx
  80045c:	68 58 22 80 00       	push   $0x802258
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
  800476:	68 95 27 80 00       	push   $0x802795
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
  8004ac:	c7 45 d0 51 22 80 00 	movl   $0x802251,-0x30(%ebp)
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
  800b1a:	68 3f 25 80 00       	push   $0x80253f
  800b1f:	6a 42                	push   $0x42
  800b21:	68 5c 25 80 00       	push   $0x80255c
  800b26:	e8 d1 11 00 00       	call   801cfc <_panic>

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
  800bdd:	b8 0b 00 00 00       	mov    $0xb,%eax
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

00800c7c <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800c7c:	55                   	push   %ebp
  800c7d:	89 e5                	mov    %esp,%ebp
  800c7f:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
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

00800c9f <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800c9f:	55                   	push   %ebp
  800ca0:	89 e5                	mov    %esp,%ebp
  800ca2:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  800ca5:	6a 00                	push   $0x0
  800ca7:	6a 00                	push   $0x0
  800ca9:	6a 00                	push   $0x0
  800cab:	ff 75 0c             	pushl  0xc(%ebp)
  800cae:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800cb1:	ba 01 00 00 00       	mov    $0x1,%edx
  800cb6:	b8 0a 00 00 00       	mov    $0xa,%eax
  800cbb:	e8 28 fe ff ff       	call   800ae8 <syscall>
}
  800cc0:	c9                   	leave  
  800cc1:	c3                   	ret    

00800cc2 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800cc2:	55                   	push   %ebp
  800cc3:	89 e5                	mov    %esp,%ebp
  800cc5:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  800cc8:	6a 00                	push   $0x0
  800cca:	ff 75 14             	pushl  0x14(%ebp)
  800ccd:	ff 75 10             	pushl  0x10(%ebp)
  800cd0:	ff 75 0c             	pushl  0xc(%ebp)
  800cd3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800cd6:	ba 00 00 00 00       	mov    $0x0,%edx
  800cdb:	b8 0c 00 00 00       	mov    $0xc,%eax
  800ce0:	e8 03 fe ff ff       	call   800ae8 <syscall>
}
  800ce5:	c9                   	leave  
  800ce6:	c3                   	ret    

00800ce7 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800ce7:	55                   	push   %ebp
  800ce8:	89 e5                	mov    %esp,%ebp
  800cea:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  800ced:	6a 00                	push   $0x0
  800cef:	6a 00                	push   $0x0
  800cf1:	6a 00                	push   $0x0
  800cf3:	6a 00                	push   $0x0
  800cf5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800cf8:	ba 01 00 00 00       	mov    $0x1,%edx
  800cfd:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d02:	e8 e1 fd ff ff       	call   800ae8 <syscall>
}
  800d07:	c9                   	leave  
  800d08:	c3                   	ret    

00800d09 <sys_set_priority>:

int
sys_set_priority(envid_t envid, uint32_t new_priority)
{
  800d09:	55                   	push   %ebp
  800d0a:	89 e5                	mov    %esp,%ebp
  800d0c:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_set_priority, 0, envid, new_priority, 0, 0, 0);
  800d0f:	6a 00                	push   $0x0
  800d11:	6a 00                	push   $0x0
  800d13:	6a 00                	push   $0x0
  800d15:	ff 75 0c             	pushl  0xc(%ebp)
  800d18:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d1b:	ba 00 00 00 00       	mov    $0x0,%edx
  800d20:	b8 0e 00 00 00       	mov    $0xe,%eax
  800d25:	e8 be fd ff ff       	call   800ae8 <syscall>
}
  800d2a:	c9                   	leave  
  800d2b:	c3                   	ret    

00800d2c <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800d2c:	55                   	push   %ebp
  800d2d:	89 e5                	mov    %esp,%ebp
  800d2f:	53                   	push   %ebx
  800d30:	83 ec 04             	sub    $0x4,%esp
  800d33:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800d36:	8b 18                	mov    (%eax),%ebx

	// LAB 4: Your code here.
	
	// cprintf("PAGE FAULT HANDLER, 0x%08x %d\n", (uint32_t)addr, err & FEC_WR);
	
	if ((err & FEC_WR) == 0)
  800d38:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800d3c:	75 14                	jne    800d52 <pgfault+0x26>
		panic("pgfault, the fault is not a write\n");
  800d3e:	83 ec 04             	sub    $0x4,%esp
  800d41:	68 6c 25 80 00       	push   $0x80256c
  800d46:	6a 20                	push   $0x20
  800d48:	68 b0 26 80 00       	push   $0x8026b0
  800d4d:	e8 aa 0f 00 00       	call   801cfc <_panic>

	uint32_t uaddr = (uint32_t) addr;
	if ((uvpd[PDX(addr)] & PTE_P) == 0 || (uvpt[uaddr / PGSIZE] & PTE_COW) == 0) {
  800d52:	89 d8                	mov    %ebx,%eax
  800d54:	c1 e8 16             	shr    $0x16,%eax
  800d57:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800d5e:	a8 01                	test   $0x1,%al
  800d60:	74 11                	je     800d73 <pgfault+0x47>
  800d62:	89 d8                	mov    %ebx,%eax
  800d64:	c1 e8 0c             	shr    $0xc,%eax
  800d67:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800d6e:	f6 c4 08             	test   $0x8,%ah
  800d71:	75 14                	jne    800d87 <pgfault+0x5b>
		panic("pgfault, not a copy-on-write page\n");
  800d73:	83 ec 04             	sub    $0x4,%esp
  800d76:	68 90 25 80 00       	push   $0x802590
  800d7b:	6a 24                	push   $0x24
  800d7d:	68 b0 26 80 00       	push   $0x8026b0
  800d82:	e8 75 0f 00 00       	call   801cfc <_panic>
	//   No need to explicitly delete the old page's mapping.

	// LAB 4: Your code here.

	// static int sys_page_alloc(envid_t envid, void *va, int perm)
	r = sys_page_alloc(0, (void *)PFTEMP, PTE_W | PTE_U | PTE_P);
  800d87:	83 ec 04             	sub    $0x4,%esp
  800d8a:	6a 07                	push   $0x7
  800d8c:	68 00 f0 7f 00       	push   $0x7ff000
  800d91:	6a 00                	push   $0x0
  800d93:	e8 54 fe ff ff       	call   800bec <sys_page_alloc>
	if (r < 0) panic("pgfault, sys_page_alloc error : %e\n", r);
  800d98:	83 c4 10             	add    $0x10,%esp
  800d9b:	85 c0                	test   %eax,%eax
  800d9d:	79 12                	jns    800db1 <pgfault+0x85>
  800d9f:	50                   	push   %eax
  800da0:	68 b4 25 80 00       	push   $0x8025b4
  800da5:	6a 32                	push   $0x32
  800da7:	68 b0 26 80 00       	push   $0x8026b0
  800dac:	e8 4b 0f 00 00       	call   801cfc <_panic>

	// Oh my god, I forget this at the first, it waste me a lot of time to debug!!!
	addr = ROUNDDOWN(addr, PGSIZE);
  800db1:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	
	memcpy(PFTEMP, addr, PGSIZE);
  800db7:	83 ec 04             	sub    $0x4,%esp
  800dba:	68 00 10 00 00       	push   $0x1000
  800dbf:	53                   	push   %ebx
  800dc0:	68 00 f0 7f 00       	push   $0x7ff000
  800dc5:	e8 cb fb ff ff       	call   800995 <memcpy>
	
	r = sys_page_map(0, PFTEMP, 0, addr, PTE_W | PTE_U | PTE_P);
  800dca:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800dd1:	53                   	push   %ebx
  800dd2:	6a 00                	push   $0x0
  800dd4:	68 00 f0 7f 00       	push   $0x7ff000
  800dd9:	6a 00                	push   $0x0
  800ddb:	e8 30 fe ff ff       	call   800c10 <sys_page_map>
	if (r < 0) panic("pgfault, sys_page_map error : %e\n", r);
  800de0:	83 c4 20             	add    $0x20,%esp
  800de3:	85 c0                	test   %eax,%eax
  800de5:	79 12                	jns    800df9 <pgfault+0xcd>
  800de7:	50                   	push   %eax
  800de8:	68 d8 25 80 00       	push   $0x8025d8
  800ded:	6a 3a                	push   $0x3a
  800def:	68 b0 26 80 00       	push   $0x8026b0
  800df4:	e8 03 0f 00 00       	call   801cfc <_panic>

	return;
}
  800df9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800dfc:	c9                   	leave  
  800dfd:	c3                   	ret    

00800dfe <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800dfe:	55                   	push   %ebp
  800dff:	89 e5                	mov    %esp,%ebp
  800e01:	57                   	push   %edi
  800e02:	56                   	push   %esi
  800e03:	53                   	push   %ebx
  800e04:	83 ec 28             	sub    $0x28,%esp
	// static int num = 0x100;

	// LAB 4: Your code here.
	set_pgfault_handler(pgfault);
  800e07:	68 2c 0d 80 00       	push   $0x800d2c
  800e0c:	e8 33 0f 00 00       	call   801d44 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  800e11:	ba 07 00 00 00       	mov    $0x7,%edx
  800e16:	89 d0                	mov    %edx,%eax
  800e18:	cd 30                	int    $0x30
  800e1a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800e1d:	89 c7                	mov    %eax,%edi
	int childpid = sys_exofork();
	if (childpid < 0) {
  800e1f:	83 c4 10             	add    $0x10,%esp
  800e22:	85 c0                	test   %eax,%eax
  800e24:	79 12                	jns    800e38 <fork+0x3a>
		panic("fork sys_exofork error : %e\n", childpid);
  800e26:	50                   	push   %eax
  800e27:	68 bb 26 80 00       	push   $0x8026bb
  800e2c:	6a 7f                	push   $0x7f
  800e2e:	68 b0 26 80 00       	push   $0x8026b0
  800e33:	e8 c4 0e 00 00       	call   801cfc <_panic>
	}
	int r;

	if (childpid == 0) {
  800e38:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800e3c:	75 25                	jne    800e63 <fork+0x65>
		// child process
		// Remember to fix "thisenv" in the child process. ??? 
		thisenv = &envs[ENVX(sys_getenvid())];
  800e3e:	e8 5e fd ff ff       	call   800ba1 <sys_getenvid>
  800e43:	25 ff 03 00 00       	and    $0x3ff,%eax
  800e48:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800e4f:	c1 e0 07             	shl    $0x7,%eax
  800e52:	29 d0                	sub    %edx,%eax
  800e54:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800e59:	a3 04 40 80 00       	mov    %eax,0x804004
		// cprintf("fork child ok\n");
		return 0;
  800e5e:	e9 be 01 00 00       	jmp    801021 <fork+0x223>
	if (childpid < 0) {
		panic("fork sys_exofork error : %e\n", childpid);
	}
	int r;

	if (childpid == 0) {
  800e63:	bb 00 00 00 00       	mov    $0x0,%ebx
	} else {
		// map page to new environment
		// kernel page is already in new environment
		uint32_t i;
		for (i = 0; i != UTOP; i += PGSIZE) 
		if ((uvpd[PDX(i)] & PTE_P) && (uvpt[i / PGSIZE] & PTE_P) && (uvpt[i / PGSIZE] & PTE_U)) {
  800e68:	89 d8                	mov    %ebx,%eax
  800e6a:	c1 e8 16             	shr    $0x16,%eax
  800e6d:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800e74:	a8 01                	test   $0x1,%al
  800e76:	0f 84 10 01 00 00    	je     800f8c <fork+0x18e>
  800e7c:	89 d8                	mov    %ebx,%eax
  800e7e:	c1 e8 0c             	shr    $0xc,%eax
  800e81:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800e88:	f6 c2 01             	test   $0x1,%dl
  800e8b:	0f 84 fb 00 00 00    	je     800f8c <fork+0x18e>
  800e91:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800e98:	f6 c2 04             	test   $0x4,%dl
  800e9b:	0f 84 eb 00 00 00    	je     800f8c <fork+0x18e>
//
static int
duppage(envid_t envid, unsigned pn)
{
	// do not dup exception stack
	if (pn * PGSIZE == UXSTACKTOP - PGSIZE) return 0;
  800ea1:	89 c6                	mov    %eax,%esi
  800ea3:	c1 e6 0c             	shl    $0xc,%esi
  800ea6:	81 fe 00 f0 bf ee    	cmp    $0xeebff000,%esi
  800eac:	0f 84 da 00 00 00    	je     800f8c <fork+0x18e>

	int r;
	void * addr = (void *)(pn * PGSIZE);
    if (uvpt[pn] & PTE_SHARE) {
  800eb2:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800eb9:	f6 c6 04             	test   $0x4,%dh
  800ebc:	74 37                	je     800ef5 <fork+0xf7>
        r = sys_page_map(0, addr, envid, addr, uvpt[pn] & PTE_SYSCALL);
  800ebe:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800ec5:	83 ec 0c             	sub    $0xc,%esp
  800ec8:	25 07 0e 00 00       	and    $0xe07,%eax
  800ecd:	50                   	push   %eax
  800ece:	56                   	push   %esi
  800ecf:	57                   	push   %edi
  800ed0:	56                   	push   %esi
  800ed1:	6a 00                	push   $0x0
  800ed3:	e8 38 fd ff ff       	call   800c10 <sys_page_map>
        if (r < 0) panic("duppage sys_page_map error : %e\n", r);
  800ed8:	83 c4 20             	add    $0x20,%esp
  800edb:	85 c0                	test   %eax,%eax
  800edd:	0f 89 a9 00 00 00    	jns    800f8c <fork+0x18e>
  800ee3:	50                   	push   %eax
  800ee4:	68 fc 25 80 00       	push   $0x8025fc
  800ee9:	6a 54                	push   $0x54
  800eeb:	68 b0 26 80 00       	push   $0x8026b0
  800ef0:	e8 07 0e 00 00       	call   801cfc <_panic>
    } else
	if ((uvpt[pn] & PTE_W) || (uvpt[pn] & PTE_COW)) {
  800ef5:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800efc:	f6 c2 02             	test   $0x2,%dl
  800eff:	75 0c                	jne    800f0d <fork+0x10f>
  800f01:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f08:	f6 c4 08             	test   $0x8,%ah
  800f0b:	74 57                	je     800f64 <fork+0x166>
		// cow
		r = sys_page_map(0, addr, envid, addr, PTE_COW | PTE_P | PTE_U);
  800f0d:	83 ec 0c             	sub    $0xc,%esp
  800f10:	68 05 08 00 00       	push   $0x805
  800f15:	56                   	push   %esi
  800f16:	57                   	push   %edi
  800f17:	56                   	push   %esi
  800f18:	6a 00                	push   $0x0
  800f1a:	e8 f1 fc ff ff       	call   800c10 <sys_page_map>
		if (r < 0) panic("duppage sys_page_map error : %e\n", r);
  800f1f:	83 c4 20             	add    $0x20,%esp
  800f22:	85 c0                	test   %eax,%eax
  800f24:	79 12                	jns    800f38 <fork+0x13a>
  800f26:	50                   	push   %eax
  800f27:	68 fc 25 80 00       	push   $0x8025fc
  800f2c:	6a 59                	push   $0x59
  800f2e:	68 b0 26 80 00       	push   $0x8026b0
  800f33:	e8 c4 0d 00 00       	call   801cfc <_panic>
		
		r = sys_page_map(0, addr, 0, addr, PTE_COW | PTE_P | PTE_U);
  800f38:	83 ec 0c             	sub    $0xc,%esp
  800f3b:	68 05 08 00 00       	push   $0x805
  800f40:	56                   	push   %esi
  800f41:	6a 00                	push   $0x0
  800f43:	56                   	push   %esi
  800f44:	6a 00                	push   $0x0
  800f46:	e8 c5 fc ff ff       	call   800c10 <sys_page_map>
		if (r < 0) panic("duppage sys_page_map error : %e\n", r);
  800f4b:	83 c4 20             	add    $0x20,%esp
  800f4e:	85 c0                	test   %eax,%eax
  800f50:	79 3a                	jns    800f8c <fork+0x18e>
  800f52:	50                   	push   %eax
  800f53:	68 fc 25 80 00       	push   $0x8025fc
  800f58:	6a 5c                	push   $0x5c
  800f5a:	68 b0 26 80 00       	push   $0x8026b0
  800f5f:	e8 98 0d 00 00       	call   801cfc <_panic>
	} else {
		// read only
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U);
  800f64:	83 ec 0c             	sub    $0xc,%esp
  800f67:	6a 05                	push   $0x5
  800f69:	56                   	push   %esi
  800f6a:	57                   	push   %edi
  800f6b:	56                   	push   %esi
  800f6c:	6a 00                	push   $0x0
  800f6e:	e8 9d fc ff ff       	call   800c10 <sys_page_map>
		if (r < 0) panic("duppage sys_page_map error : %e\n", r);
  800f73:	83 c4 20             	add    $0x20,%esp
  800f76:	85 c0                	test   %eax,%eax
  800f78:	79 12                	jns    800f8c <fork+0x18e>
  800f7a:	50                   	push   %eax
  800f7b:	68 fc 25 80 00       	push   $0x8025fc
  800f80:	6a 60                	push   $0x60
  800f82:	68 b0 26 80 00       	push   $0x8026b0
  800f87:	e8 70 0d 00 00       	call   801cfc <_panic>
		return 0;
	} else {
		// map page to new environment
		// kernel page is already in new environment
		uint32_t i;
		for (i = 0; i != UTOP; i += PGSIZE) 
  800f8c:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  800f92:	81 fb 00 00 c0 ee    	cmp    $0xeec00000,%ebx
  800f98:	0f 85 ca fe ff ff    	jne    800e68 <fork+0x6a>
		if ((uvpd[PDX(i)] & PTE_P) && (uvpt[i / PGSIZE] & PTE_P) && (uvpt[i / PGSIZE] & PTE_U)) {
			duppage(childpid, i / PGSIZE);
		}

		// allocate exception stack
		r = sys_page_alloc(childpid, (void *)(UXSTACKTOP - PGSIZE), PTE_U | PTE_W | PTE_P);
  800f9e:	83 ec 04             	sub    $0x4,%esp
  800fa1:	6a 07                	push   $0x7
  800fa3:	68 00 f0 bf ee       	push   $0xeebff000
  800fa8:	ff 75 e4             	pushl  -0x1c(%ebp)
  800fab:	e8 3c fc ff ff       	call   800bec <sys_page_alloc>
		if (r < 0) panic("fork, sys_page_alloc user exception stack error : %e\n", r);
  800fb0:	83 c4 10             	add    $0x10,%esp
  800fb3:	85 c0                	test   %eax,%eax
  800fb5:	79 15                	jns    800fcc <fork+0x1ce>
  800fb7:	50                   	push   %eax
  800fb8:	68 20 26 80 00       	push   $0x802620
  800fbd:	68 94 00 00 00       	push   $0x94
  800fc2:	68 b0 26 80 00       	push   $0x8026b0
  800fc7:	e8 30 0d 00 00       	call   801cfc <_panic>

		// set user environment user page fault handler 
		extern void _pgfault_upcall(void);
		r = sys_env_set_pgfault_upcall(childpid, _pgfault_upcall);
  800fcc:	83 ec 08             	sub    $0x8,%esp
  800fcf:	68 b0 1d 80 00       	push   $0x801db0
  800fd4:	ff 75 e4             	pushl  -0x1c(%ebp)
  800fd7:	e8 c3 fc ff ff       	call   800c9f <sys_env_set_pgfault_upcall>
		if (r < 0) panic("fork, set pgfault upcall fail : %e\n", r);
  800fdc:	83 c4 10             	add    $0x10,%esp
  800fdf:	85 c0                	test   %eax,%eax
  800fe1:	79 15                	jns    800ff8 <fork+0x1fa>
  800fe3:	50                   	push   %eax
  800fe4:	68 58 26 80 00       	push   $0x802658
  800fe9:	68 99 00 00 00       	push   $0x99
  800fee:	68 b0 26 80 00       	push   $0x8026b0
  800ff3:	e8 04 0d 00 00       	call   801cfc <_panic>
		r = sys_set_priority(childpid, num);
		if (r < 0) panic("fork, set priority error\n");
		*/

		// mark the child as runnable and return
		r = sys_env_set_status(childpid, ENV_RUNNABLE);
  800ff8:	83 ec 08             	sub    $0x8,%esp
  800ffb:	6a 02                	push   $0x2
  800ffd:	ff 75 e4             	pushl  -0x1c(%ebp)
  801000:	e8 54 fc ff ff       	call   800c59 <sys_env_set_status>
		if (r < 0) panic("fork, set child process to ENV_RUNNABLE error : %e\n", r);
  801005:	83 c4 10             	add    $0x10,%esp
  801008:	85 c0                	test   %eax,%eax
  80100a:	79 15                	jns    801021 <fork+0x223>
  80100c:	50                   	push   %eax
  80100d:	68 7c 26 80 00       	push   $0x80267c
  801012:	68 a4 00 00 00       	push   $0xa4
  801017:	68 b0 26 80 00       	push   $0x8026b0
  80101c:	e8 db 0c 00 00       	call   801cfc <_panic>
		// cprintf("fork father ok!")
		return childpid;
	}

	panic("fork not implemented");
}
  801021:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801024:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801027:	5b                   	pop    %ebx
  801028:	5e                   	pop    %esi
  801029:	5f                   	pop    %edi
  80102a:	c9                   	leave  
  80102b:	c3                   	ret    

0080102c <sfork>:

// Challenge!
int
sfork(void)
{
  80102c:	55                   	push   %ebp
  80102d:	89 e5                	mov    %esp,%ebp
  80102f:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  801032:	68 d8 26 80 00       	push   $0x8026d8
  801037:	68 b1 00 00 00       	push   $0xb1
  80103c:	68 b0 26 80 00       	push   $0x8026b0
  801041:	e8 b6 0c 00 00       	call   801cfc <_panic>
	...

00801048 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801048:	55                   	push   %ebp
  801049:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80104b:	8b 45 08             	mov    0x8(%ebp),%eax
  80104e:	05 00 00 00 30       	add    $0x30000000,%eax
  801053:	c1 e8 0c             	shr    $0xc,%eax
}
  801056:	c9                   	leave  
  801057:	c3                   	ret    

00801058 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801058:	55                   	push   %ebp
  801059:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  80105b:	ff 75 08             	pushl  0x8(%ebp)
  80105e:	e8 e5 ff ff ff       	call   801048 <fd2num>
  801063:	83 c4 04             	add    $0x4,%esp
  801066:	05 20 00 0d 00       	add    $0xd0020,%eax
  80106b:	c1 e0 0c             	shl    $0xc,%eax
}
  80106e:	c9                   	leave  
  80106f:	c3                   	ret    

00801070 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801070:	55                   	push   %ebp
  801071:	89 e5                	mov    %esp,%ebp
  801073:	53                   	push   %ebx
  801074:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801077:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  80107c:	a8 01                	test   $0x1,%al
  80107e:	74 34                	je     8010b4 <fd_alloc+0x44>
  801080:	a1 00 00 74 ef       	mov    0xef740000,%eax
  801085:	a8 01                	test   $0x1,%al
  801087:	74 32                	je     8010bb <fd_alloc+0x4b>
  801089:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
  80108e:	89 c1                	mov    %eax,%ecx
  801090:	89 c2                	mov    %eax,%edx
  801092:	c1 ea 16             	shr    $0x16,%edx
  801095:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80109c:	f6 c2 01             	test   $0x1,%dl
  80109f:	74 1f                	je     8010c0 <fd_alloc+0x50>
  8010a1:	89 c2                	mov    %eax,%edx
  8010a3:	c1 ea 0c             	shr    $0xc,%edx
  8010a6:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8010ad:	f6 c2 01             	test   $0x1,%dl
  8010b0:	75 17                	jne    8010c9 <fd_alloc+0x59>
  8010b2:	eb 0c                	jmp    8010c0 <fd_alloc+0x50>
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  8010b4:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
  8010b9:	eb 05                	jmp    8010c0 <fd_alloc+0x50>
  8010bb:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
  8010c0:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  8010c2:	b8 00 00 00 00       	mov    $0x0,%eax
  8010c7:	eb 17                	jmp    8010e0 <fd_alloc+0x70>
  8010c9:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8010ce:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8010d3:	75 b9                	jne    80108e <fd_alloc+0x1e>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8010d5:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  8010db:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8010e0:	5b                   	pop    %ebx
  8010e1:	c9                   	leave  
  8010e2:	c3                   	ret    

008010e3 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8010e3:	55                   	push   %ebp
  8010e4:	89 e5                	mov    %esp,%ebp
  8010e6:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8010e9:	83 f8 1f             	cmp    $0x1f,%eax
  8010ec:	77 36                	ja     801124 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8010ee:	05 00 00 0d 00       	add    $0xd0000,%eax
  8010f3:	c1 e0 0c             	shl    $0xc,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8010f6:	89 c2                	mov    %eax,%edx
  8010f8:	c1 ea 16             	shr    $0x16,%edx
  8010fb:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801102:	f6 c2 01             	test   $0x1,%dl
  801105:	74 24                	je     80112b <fd_lookup+0x48>
  801107:	89 c2                	mov    %eax,%edx
  801109:	c1 ea 0c             	shr    $0xc,%edx
  80110c:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801113:	f6 c2 01             	test   $0x1,%dl
  801116:	74 1a                	je     801132 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801118:	8b 55 0c             	mov    0xc(%ebp),%edx
  80111b:	89 02                	mov    %eax,(%edx)
	return 0;
  80111d:	b8 00 00 00 00       	mov    $0x0,%eax
  801122:	eb 13                	jmp    801137 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801124:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801129:	eb 0c                	jmp    801137 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80112b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801130:	eb 05                	jmp    801137 <fd_lookup+0x54>
  801132:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801137:	c9                   	leave  
  801138:	c3                   	ret    

00801139 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801139:	55                   	push   %ebp
  80113a:	89 e5                	mov    %esp,%ebp
  80113c:	53                   	push   %ebx
  80113d:	83 ec 04             	sub    $0x4,%esp
  801140:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801143:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  801146:	39 0d 04 30 80 00    	cmp    %ecx,0x803004
  80114c:	74 0d                	je     80115b <dev_lookup+0x22>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80114e:	b8 00 00 00 00       	mov    $0x0,%eax
  801153:	eb 14                	jmp    801169 <dev_lookup+0x30>
		if (devtab[i]->dev_id == dev_id) {
  801155:	39 0a                	cmp    %ecx,(%edx)
  801157:	75 10                	jne    801169 <dev_lookup+0x30>
  801159:	eb 05                	jmp    801160 <dev_lookup+0x27>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80115b:	ba 04 30 80 00       	mov    $0x803004,%edx
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
  801160:	89 13                	mov    %edx,(%ebx)
			return 0;
  801162:	b8 00 00 00 00       	mov    $0x0,%eax
  801167:	eb 31                	jmp    80119a <dev_lookup+0x61>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801169:	40                   	inc    %eax
  80116a:	8b 14 85 6c 27 80 00 	mov    0x80276c(,%eax,4),%edx
  801171:	85 d2                	test   %edx,%edx
  801173:	75 e0                	jne    801155 <dev_lookup+0x1c>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801175:	a1 04 40 80 00       	mov    0x804004,%eax
  80117a:	8b 40 48             	mov    0x48(%eax),%eax
  80117d:	83 ec 04             	sub    $0x4,%esp
  801180:	51                   	push   %ecx
  801181:	50                   	push   %eax
  801182:	68 f0 26 80 00       	push   $0x8026f0
  801187:	e8 28 f0 ff ff       	call   8001b4 <cprintf>
	*dev = 0;
  80118c:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  801192:	83 c4 10             	add    $0x10,%esp
  801195:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80119a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80119d:	c9                   	leave  
  80119e:	c3                   	ret    

0080119f <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80119f:	55                   	push   %ebp
  8011a0:	89 e5                	mov    %esp,%ebp
  8011a2:	56                   	push   %esi
  8011a3:	53                   	push   %ebx
  8011a4:	83 ec 20             	sub    $0x20,%esp
  8011a7:	8b 75 08             	mov    0x8(%ebp),%esi
  8011aa:	8a 45 0c             	mov    0xc(%ebp),%al
  8011ad:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8011b0:	56                   	push   %esi
  8011b1:	e8 92 fe ff ff       	call   801048 <fd2num>
  8011b6:	8d 55 f4             	lea    -0xc(%ebp),%edx
  8011b9:	89 14 24             	mov    %edx,(%esp)
  8011bc:	50                   	push   %eax
  8011bd:	e8 21 ff ff ff       	call   8010e3 <fd_lookup>
  8011c2:	89 c3                	mov    %eax,%ebx
  8011c4:	83 c4 08             	add    $0x8,%esp
  8011c7:	85 c0                	test   %eax,%eax
  8011c9:	78 05                	js     8011d0 <fd_close+0x31>
	    || fd != fd2)
  8011cb:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8011ce:	74 0d                	je     8011dd <fd_close+0x3e>
		return (must_exist ? r : 0);
  8011d0:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  8011d4:	75 48                	jne    80121e <fd_close+0x7f>
  8011d6:	bb 00 00 00 00       	mov    $0x0,%ebx
  8011db:	eb 41                	jmp    80121e <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8011dd:	83 ec 08             	sub    $0x8,%esp
  8011e0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011e3:	50                   	push   %eax
  8011e4:	ff 36                	pushl  (%esi)
  8011e6:	e8 4e ff ff ff       	call   801139 <dev_lookup>
  8011eb:	89 c3                	mov    %eax,%ebx
  8011ed:	83 c4 10             	add    $0x10,%esp
  8011f0:	85 c0                	test   %eax,%eax
  8011f2:	78 1c                	js     801210 <fd_close+0x71>
		if (dev->dev_close)
  8011f4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011f7:	8b 40 10             	mov    0x10(%eax),%eax
  8011fa:	85 c0                	test   %eax,%eax
  8011fc:	74 0d                	je     80120b <fd_close+0x6c>
			r = (*dev->dev_close)(fd);
  8011fe:	83 ec 0c             	sub    $0xc,%esp
  801201:	56                   	push   %esi
  801202:	ff d0                	call   *%eax
  801204:	89 c3                	mov    %eax,%ebx
  801206:	83 c4 10             	add    $0x10,%esp
  801209:	eb 05                	jmp    801210 <fd_close+0x71>
		else
			r = 0;
  80120b:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801210:	83 ec 08             	sub    $0x8,%esp
  801213:	56                   	push   %esi
  801214:	6a 00                	push   $0x0
  801216:	e8 1b fa ff ff       	call   800c36 <sys_page_unmap>
	return r;
  80121b:	83 c4 10             	add    $0x10,%esp
}
  80121e:	89 d8                	mov    %ebx,%eax
  801220:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801223:	5b                   	pop    %ebx
  801224:	5e                   	pop    %esi
  801225:	c9                   	leave  
  801226:	c3                   	ret    

00801227 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801227:	55                   	push   %ebp
  801228:	89 e5                	mov    %esp,%ebp
  80122a:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80122d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801230:	50                   	push   %eax
  801231:	ff 75 08             	pushl  0x8(%ebp)
  801234:	e8 aa fe ff ff       	call   8010e3 <fd_lookup>
  801239:	83 c4 08             	add    $0x8,%esp
  80123c:	85 c0                	test   %eax,%eax
  80123e:	78 10                	js     801250 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801240:	83 ec 08             	sub    $0x8,%esp
  801243:	6a 01                	push   $0x1
  801245:	ff 75 f4             	pushl  -0xc(%ebp)
  801248:	e8 52 ff ff ff       	call   80119f <fd_close>
  80124d:	83 c4 10             	add    $0x10,%esp
}
  801250:	c9                   	leave  
  801251:	c3                   	ret    

00801252 <close_all>:

void
close_all(void)
{
  801252:	55                   	push   %ebp
  801253:	89 e5                	mov    %esp,%ebp
  801255:	53                   	push   %ebx
  801256:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801259:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80125e:	83 ec 0c             	sub    $0xc,%esp
  801261:	53                   	push   %ebx
  801262:	e8 c0 ff ff ff       	call   801227 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801267:	43                   	inc    %ebx
  801268:	83 c4 10             	add    $0x10,%esp
  80126b:	83 fb 20             	cmp    $0x20,%ebx
  80126e:	75 ee                	jne    80125e <close_all+0xc>
		close(i);
}
  801270:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801273:	c9                   	leave  
  801274:	c3                   	ret    

00801275 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801275:	55                   	push   %ebp
  801276:	89 e5                	mov    %esp,%ebp
  801278:	57                   	push   %edi
  801279:	56                   	push   %esi
  80127a:	53                   	push   %ebx
  80127b:	83 ec 2c             	sub    $0x2c,%esp
  80127e:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801281:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801284:	50                   	push   %eax
  801285:	ff 75 08             	pushl  0x8(%ebp)
  801288:	e8 56 fe ff ff       	call   8010e3 <fd_lookup>
  80128d:	89 c3                	mov    %eax,%ebx
  80128f:	83 c4 08             	add    $0x8,%esp
  801292:	85 c0                	test   %eax,%eax
  801294:	0f 88 c0 00 00 00    	js     80135a <dup+0xe5>
		return r;
	close(newfdnum);
  80129a:	83 ec 0c             	sub    $0xc,%esp
  80129d:	57                   	push   %edi
  80129e:	e8 84 ff ff ff       	call   801227 <close>

	newfd = INDEX2FD(newfdnum);
  8012a3:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  8012a9:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  8012ac:	83 c4 04             	add    $0x4,%esp
  8012af:	ff 75 e4             	pushl  -0x1c(%ebp)
  8012b2:	e8 a1 fd ff ff       	call   801058 <fd2data>
  8012b7:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  8012b9:	89 34 24             	mov    %esi,(%esp)
  8012bc:	e8 97 fd ff ff       	call   801058 <fd2data>
  8012c1:	83 c4 10             	add    $0x10,%esp
  8012c4:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8012c7:	89 d8                	mov    %ebx,%eax
  8012c9:	c1 e8 16             	shr    $0x16,%eax
  8012cc:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8012d3:	a8 01                	test   $0x1,%al
  8012d5:	74 37                	je     80130e <dup+0x99>
  8012d7:	89 d8                	mov    %ebx,%eax
  8012d9:	c1 e8 0c             	shr    $0xc,%eax
  8012dc:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8012e3:	f6 c2 01             	test   $0x1,%dl
  8012e6:	74 26                	je     80130e <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8012e8:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8012ef:	83 ec 0c             	sub    $0xc,%esp
  8012f2:	25 07 0e 00 00       	and    $0xe07,%eax
  8012f7:	50                   	push   %eax
  8012f8:	ff 75 d4             	pushl  -0x2c(%ebp)
  8012fb:	6a 00                	push   $0x0
  8012fd:	53                   	push   %ebx
  8012fe:	6a 00                	push   $0x0
  801300:	e8 0b f9 ff ff       	call   800c10 <sys_page_map>
  801305:	89 c3                	mov    %eax,%ebx
  801307:	83 c4 20             	add    $0x20,%esp
  80130a:	85 c0                	test   %eax,%eax
  80130c:	78 2d                	js     80133b <dup+0xc6>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80130e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801311:	89 c2                	mov    %eax,%edx
  801313:	c1 ea 0c             	shr    $0xc,%edx
  801316:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80131d:	83 ec 0c             	sub    $0xc,%esp
  801320:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  801326:	52                   	push   %edx
  801327:	56                   	push   %esi
  801328:	6a 00                	push   $0x0
  80132a:	50                   	push   %eax
  80132b:	6a 00                	push   $0x0
  80132d:	e8 de f8 ff ff       	call   800c10 <sys_page_map>
  801332:	89 c3                	mov    %eax,%ebx
  801334:	83 c4 20             	add    $0x20,%esp
  801337:	85 c0                	test   %eax,%eax
  801339:	79 1d                	jns    801358 <dup+0xe3>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80133b:	83 ec 08             	sub    $0x8,%esp
  80133e:	56                   	push   %esi
  80133f:	6a 00                	push   $0x0
  801341:	e8 f0 f8 ff ff       	call   800c36 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801346:	83 c4 08             	add    $0x8,%esp
  801349:	ff 75 d4             	pushl  -0x2c(%ebp)
  80134c:	6a 00                	push   $0x0
  80134e:	e8 e3 f8 ff ff       	call   800c36 <sys_page_unmap>
	return r;
  801353:	83 c4 10             	add    $0x10,%esp
  801356:	eb 02                	jmp    80135a <dup+0xe5>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  801358:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  80135a:	89 d8                	mov    %ebx,%eax
  80135c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80135f:	5b                   	pop    %ebx
  801360:	5e                   	pop    %esi
  801361:	5f                   	pop    %edi
  801362:	c9                   	leave  
  801363:	c3                   	ret    

00801364 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801364:	55                   	push   %ebp
  801365:	89 e5                	mov    %esp,%ebp
  801367:	53                   	push   %ebx
  801368:	83 ec 14             	sub    $0x14,%esp
  80136b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80136e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801371:	50                   	push   %eax
  801372:	53                   	push   %ebx
  801373:	e8 6b fd ff ff       	call   8010e3 <fd_lookup>
  801378:	83 c4 08             	add    $0x8,%esp
  80137b:	85 c0                	test   %eax,%eax
  80137d:	78 67                	js     8013e6 <read+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80137f:	83 ec 08             	sub    $0x8,%esp
  801382:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801385:	50                   	push   %eax
  801386:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801389:	ff 30                	pushl  (%eax)
  80138b:	e8 a9 fd ff ff       	call   801139 <dev_lookup>
  801390:	83 c4 10             	add    $0x10,%esp
  801393:	85 c0                	test   %eax,%eax
  801395:	78 4f                	js     8013e6 <read+0x82>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801397:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80139a:	8b 50 08             	mov    0x8(%eax),%edx
  80139d:	83 e2 03             	and    $0x3,%edx
  8013a0:	83 fa 01             	cmp    $0x1,%edx
  8013a3:	75 21                	jne    8013c6 <read+0x62>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8013a5:	a1 04 40 80 00       	mov    0x804004,%eax
  8013aa:	8b 40 48             	mov    0x48(%eax),%eax
  8013ad:	83 ec 04             	sub    $0x4,%esp
  8013b0:	53                   	push   %ebx
  8013b1:	50                   	push   %eax
  8013b2:	68 31 27 80 00       	push   $0x802731
  8013b7:	e8 f8 ed ff ff       	call   8001b4 <cprintf>
		return -E_INVAL;
  8013bc:	83 c4 10             	add    $0x10,%esp
  8013bf:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8013c4:	eb 20                	jmp    8013e6 <read+0x82>
	}
	if (!dev->dev_read)
  8013c6:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8013c9:	8b 52 08             	mov    0x8(%edx),%edx
  8013cc:	85 d2                	test   %edx,%edx
  8013ce:	74 11                	je     8013e1 <read+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8013d0:	83 ec 04             	sub    $0x4,%esp
  8013d3:	ff 75 10             	pushl  0x10(%ebp)
  8013d6:	ff 75 0c             	pushl  0xc(%ebp)
  8013d9:	50                   	push   %eax
  8013da:	ff d2                	call   *%edx
  8013dc:	83 c4 10             	add    $0x10,%esp
  8013df:	eb 05                	jmp    8013e6 <read+0x82>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8013e1:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  8013e6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013e9:	c9                   	leave  
  8013ea:	c3                   	ret    

008013eb <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8013eb:	55                   	push   %ebp
  8013ec:	89 e5                	mov    %esp,%ebp
  8013ee:	57                   	push   %edi
  8013ef:	56                   	push   %esi
  8013f0:	53                   	push   %ebx
  8013f1:	83 ec 0c             	sub    $0xc,%esp
  8013f4:	8b 7d 08             	mov    0x8(%ebp),%edi
  8013f7:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8013fa:	85 f6                	test   %esi,%esi
  8013fc:	74 31                	je     80142f <readn+0x44>
  8013fe:	b8 00 00 00 00       	mov    $0x0,%eax
  801403:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = read(fdnum, (char*)buf + tot, n - tot);
  801408:	83 ec 04             	sub    $0x4,%esp
  80140b:	89 f2                	mov    %esi,%edx
  80140d:	29 c2                	sub    %eax,%edx
  80140f:	52                   	push   %edx
  801410:	03 45 0c             	add    0xc(%ebp),%eax
  801413:	50                   	push   %eax
  801414:	57                   	push   %edi
  801415:	e8 4a ff ff ff       	call   801364 <read>
		if (m < 0)
  80141a:	83 c4 10             	add    $0x10,%esp
  80141d:	85 c0                	test   %eax,%eax
  80141f:	78 17                	js     801438 <readn+0x4d>
			return m;
		if (m == 0)
  801421:	85 c0                	test   %eax,%eax
  801423:	74 11                	je     801436 <readn+0x4b>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801425:	01 c3                	add    %eax,%ebx
  801427:	89 d8                	mov    %ebx,%eax
  801429:	39 f3                	cmp    %esi,%ebx
  80142b:	72 db                	jb     801408 <readn+0x1d>
  80142d:	eb 09                	jmp    801438 <readn+0x4d>
  80142f:	b8 00 00 00 00       	mov    $0x0,%eax
  801434:	eb 02                	jmp    801438 <readn+0x4d>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  801436:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  801438:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80143b:	5b                   	pop    %ebx
  80143c:	5e                   	pop    %esi
  80143d:	5f                   	pop    %edi
  80143e:	c9                   	leave  
  80143f:	c3                   	ret    

00801440 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801440:	55                   	push   %ebp
  801441:	89 e5                	mov    %esp,%ebp
  801443:	53                   	push   %ebx
  801444:	83 ec 14             	sub    $0x14,%esp
  801447:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80144a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80144d:	50                   	push   %eax
  80144e:	53                   	push   %ebx
  80144f:	e8 8f fc ff ff       	call   8010e3 <fd_lookup>
  801454:	83 c4 08             	add    $0x8,%esp
  801457:	85 c0                	test   %eax,%eax
  801459:	78 62                	js     8014bd <write+0x7d>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80145b:	83 ec 08             	sub    $0x8,%esp
  80145e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801461:	50                   	push   %eax
  801462:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801465:	ff 30                	pushl  (%eax)
  801467:	e8 cd fc ff ff       	call   801139 <dev_lookup>
  80146c:	83 c4 10             	add    $0x10,%esp
  80146f:	85 c0                	test   %eax,%eax
  801471:	78 4a                	js     8014bd <write+0x7d>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801473:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801476:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80147a:	75 21                	jne    80149d <write+0x5d>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80147c:	a1 04 40 80 00       	mov    0x804004,%eax
  801481:	8b 40 48             	mov    0x48(%eax),%eax
  801484:	83 ec 04             	sub    $0x4,%esp
  801487:	53                   	push   %ebx
  801488:	50                   	push   %eax
  801489:	68 4d 27 80 00       	push   $0x80274d
  80148e:	e8 21 ed ff ff       	call   8001b4 <cprintf>
		return -E_INVAL;
  801493:	83 c4 10             	add    $0x10,%esp
  801496:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80149b:	eb 20                	jmp    8014bd <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80149d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8014a0:	8b 52 0c             	mov    0xc(%edx),%edx
  8014a3:	85 d2                	test   %edx,%edx
  8014a5:	74 11                	je     8014b8 <write+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8014a7:	83 ec 04             	sub    $0x4,%esp
  8014aa:	ff 75 10             	pushl  0x10(%ebp)
  8014ad:	ff 75 0c             	pushl  0xc(%ebp)
  8014b0:	50                   	push   %eax
  8014b1:	ff d2                	call   *%edx
  8014b3:	83 c4 10             	add    $0x10,%esp
  8014b6:	eb 05                	jmp    8014bd <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8014b8:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  8014bd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014c0:	c9                   	leave  
  8014c1:	c3                   	ret    

008014c2 <seek>:

int
seek(int fdnum, off_t offset)
{
  8014c2:	55                   	push   %ebp
  8014c3:	89 e5                	mov    %esp,%ebp
  8014c5:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8014c8:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8014cb:	50                   	push   %eax
  8014cc:	ff 75 08             	pushl  0x8(%ebp)
  8014cf:	e8 0f fc ff ff       	call   8010e3 <fd_lookup>
  8014d4:	83 c4 08             	add    $0x8,%esp
  8014d7:	85 c0                	test   %eax,%eax
  8014d9:	78 0e                	js     8014e9 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8014db:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8014de:	8b 55 0c             	mov    0xc(%ebp),%edx
  8014e1:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8014e4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8014e9:	c9                   	leave  
  8014ea:	c3                   	ret    

008014eb <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8014eb:	55                   	push   %ebp
  8014ec:	89 e5                	mov    %esp,%ebp
  8014ee:	53                   	push   %ebx
  8014ef:	83 ec 14             	sub    $0x14,%esp
  8014f2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8014f5:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014f8:	50                   	push   %eax
  8014f9:	53                   	push   %ebx
  8014fa:	e8 e4 fb ff ff       	call   8010e3 <fd_lookup>
  8014ff:	83 c4 08             	add    $0x8,%esp
  801502:	85 c0                	test   %eax,%eax
  801504:	78 5f                	js     801565 <ftruncate+0x7a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801506:	83 ec 08             	sub    $0x8,%esp
  801509:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80150c:	50                   	push   %eax
  80150d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801510:	ff 30                	pushl  (%eax)
  801512:	e8 22 fc ff ff       	call   801139 <dev_lookup>
  801517:	83 c4 10             	add    $0x10,%esp
  80151a:	85 c0                	test   %eax,%eax
  80151c:	78 47                	js     801565 <ftruncate+0x7a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80151e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801521:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801525:	75 21                	jne    801548 <ftruncate+0x5d>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801527:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80152c:	8b 40 48             	mov    0x48(%eax),%eax
  80152f:	83 ec 04             	sub    $0x4,%esp
  801532:	53                   	push   %ebx
  801533:	50                   	push   %eax
  801534:	68 10 27 80 00       	push   $0x802710
  801539:	e8 76 ec ff ff       	call   8001b4 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80153e:	83 c4 10             	add    $0x10,%esp
  801541:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801546:	eb 1d                	jmp    801565 <ftruncate+0x7a>
	}
	if (!dev->dev_trunc)
  801548:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80154b:	8b 52 18             	mov    0x18(%edx),%edx
  80154e:	85 d2                	test   %edx,%edx
  801550:	74 0e                	je     801560 <ftruncate+0x75>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801552:	83 ec 08             	sub    $0x8,%esp
  801555:	ff 75 0c             	pushl  0xc(%ebp)
  801558:	50                   	push   %eax
  801559:	ff d2                	call   *%edx
  80155b:	83 c4 10             	add    $0x10,%esp
  80155e:	eb 05                	jmp    801565 <ftruncate+0x7a>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801560:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  801565:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801568:	c9                   	leave  
  801569:	c3                   	ret    

0080156a <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80156a:	55                   	push   %ebp
  80156b:	89 e5                	mov    %esp,%ebp
  80156d:	53                   	push   %ebx
  80156e:	83 ec 14             	sub    $0x14,%esp
  801571:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801574:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801577:	50                   	push   %eax
  801578:	ff 75 08             	pushl  0x8(%ebp)
  80157b:	e8 63 fb ff ff       	call   8010e3 <fd_lookup>
  801580:	83 c4 08             	add    $0x8,%esp
  801583:	85 c0                	test   %eax,%eax
  801585:	78 52                	js     8015d9 <fstat+0x6f>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801587:	83 ec 08             	sub    $0x8,%esp
  80158a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80158d:	50                   	push   %eax
  80158e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801591:	ff 30                	pushl  (%eax)
  801593:	e8 a1 fb ff ff       	call   801139 <dev_lookup>
  801598:	83 c4 10             	add    $0x10,%esp
  80159b:	85 c0                	test   %eax,%eax
  80159d:	78 3a                	js     8015d9 <fstat+0x6f>
		return r;
	if (!dev->dev_stat)
  80159f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015a2:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8015a6:	74 2c                	je     8015d4 <fstat+0x6a>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8015a8:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8015ab:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8015b2:	00 00 00 
	stat->st_isdir = 0;
  8015b5:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8015bc:	00 00 00 
	stat->st_dev = dev;
  8015bf:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8015c5:	83 ec 08             	sub    $0x8,%esp
  8015c8:	53                   	push   %ebx
  8015c9:	ff 75 f0             	pushl  -0x10(%ebp)
  8015cc:	ff 50 14             	call   *0x14(%eax)
  8015cf:	83 c4 10             	add    $0x10,%esp
  8015d2:	eb 05                	jmp    8015d9 <fstat+0x6f>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8015d4:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8015d9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015dc:	c9                   	leave  
  8015dd:	c3                   	ret    

008015de <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8015de:	55                   	push   %ebp
  8015df:	89 e5                	mov    %esp,%ebp
  8015e1:	56                   	push   %esi
  8015e2:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8015e3:	83 ec 08             	sub    $0x8,%esp
  8015e6:	6a 00                	push   $0x0
  8015e8:	ff 75 08             	pushl  0x8(%ebp)
  8015eb:	e8 78 01 00 00       	call   801768 <open>
  8015f0:	89 c3                	mov    %eax,%ebx
  8015f2:	83 c4 10             	add    $0x10,%esp
  8015f5:	85 c0                	test   %eax,%eax
  8015f7:	78 1b                	js     801614 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8015f9:	83 ec 08             	sub    $0x8,%esp
  8015fc:	ff 75 0c             	pushl  0xc(%ebp)
  8015ff:	50                   	push   %eax
  801600:	e8 65 ff ff ff       	call   80156a <fstat>
  801605:	89 c6                	mov    %eax,%esi
	close(fd);
  801607:	89 1c 24             	mov    %ebx,(%esp)
  80160a:	e8 18 fc ff ff       	call   801227 <close>
	return r;
  80160f:	83 c4 10             	add    $0x10,%esp
  801612:	89 f3                	mov    %esi,%ebx
}
  801614:	89 d8                	mov    %ebx,%eax
  801616:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801619:	5b                   	pop    %ebx
  80161a:	5e                   	pop    %esi
  80161b:	c9                   	leave  
  80161c:	c3                   	ret    
  80161d:	00 00                	add    %al,(%eax)
	...

00801620 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801620:	55                   	push   %ebp
  801621:	89 e5                	mov    %esp,%ebp
  801623:	56                   	push   %esi
  801624:	53                   	push   %ebx
  801625:	89 c3                	mov    %eax,%ebx
  801627:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  801629:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801630:	75 12                	jne    801644 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801632:	83 ec 0c             	sub    $0xc,%esp
  801635:	6a 01                	push   $0x1
  801637:	e8 66 08 00 00       	call   801ea2 <ipc_find_env>
  80163c:	a3 00 40 80 00       	mov    %eax,0x804000
  801641:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801644:	6a 07                	push   $0x7
  801646:	68 00 50 80 00       	push   $0x805000
  80164b:	53                   	push   %ebx
  80164c:	ff 35 00 40 80 00    	pushl  0x804000
  801652:	e8 f6 07 00 00       	call   801e4d <ipc_send>
	
	return ipc_recv(NULL, dstva, NULL);
  801657:	83 c4 0c             	add    $0xc,%esp
  80165a:	6a 00                	push   $0x0
  80165c:	56                   	push   %esi
  80165d:	6a 00                	push   $0x0
  80165f:	e8 74 07 00 00       	call   801dd8 <ipc_recv>
}
  801664:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801667:	5b                   	pop    %ebx
  801668:	5e                   	pop    %esi
  801669:	c9                   	leave  
  80166a:	c3                   	ret    

0080166b <devfile_stat>:
}


static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80166b:	55                   	push   %ebp
  80166c:	89 e5                	mov    %esp,%ebp
  80166e:	53                   	push   %ebx
  80166f:	83 ec 04             	sub    $0x4,%esp
  801672:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801675:	8b 45 08             	mov    0x8(%ebp),%eax
  801678:	8b 40 0c             	mov    0xc(%eax),%eax
  80167b:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0) {
  801680:	ba 00 00 00 00       	mov    $0x0,%edx
  801685:	b8 05 00 00 00       	mov    $0x5,%eax
  80168a:	e8 91 ff ff ff       	call   801620 <fsipc>
  80168f:	85 c0                	test   %eax,%eax
  801691:	78 2c                	js     8016bf <devfile_stat+0x54>
		return r;
	}
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801693:	83 ec 08             	sub    $0x8,%esp
  801696:	68 00 50 80 00       	push   $0x805000
  80169b:	53                   	push   %ebx
  80169c:	e8 c9 f0 ff ff       	call   80076a <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8016a1:	a1 80 50 80 00       	mov    0x805080,%eax
  8016a6:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8016ac:	a1 84 50 80 00       	mov    0x805084,%eax
  8016b1:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8016b7:	83 c4 10             	add    $0x10,%esp
  8016ba:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8016bf:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016c2:	c9                   	leave  
  8016c3:	c3                   	ret    

008016c4 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8016c4:	55                   	push   %ebp
  8016c5:	89 e5                	mov    %esp,%ebp
  8016c7:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8016ca:	8b 45 08             	mov    0x8(%ebp),%eax
  8016cd:	8b 40 0c             	mov    0xc(%eax),%eax
  8016d0:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8016d5:	ba 00 00 00 00       	mov    $0x0,%edx
  8016da:	b8 06 00 00 00       	mov    $0x6,%eax
  8016df:	e8 3c ff ff ff       	call   801620 <fsipc>
}
  8016e4:	c9                   	leave  
  8016e5:	c3                   	ret    

008016e6 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8016e6:	55                   	push   %ebp
  8016e7:	89 e5                	mov    %esp,%ebp
  8016e9:	56                   	push   %esi
  8016ea:	53                   	push   %ebx
  8016eb:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8016ee:	8b 45 08             	mov    0x8(%ebp),%eax
  8016f1:	8b 40 0c             	mov    0xc(%eax),%eax
  8016f4:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8016f9:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8016ff:	ba 00 00 00 00       	mov    $0x0,%edx
  801704:	b8 03 00 00 00       	mov    $0x3,%eax
  801709:	e8 12 ff ff ff       	call   801620 <fsipc>
  80170e:	89 c3                	mov    %eax,%ebx
  801710:	85 c0                	test   %eax,%eax
  801712:	78 4b                	js     80175f <devfile_read+0x79>
		return r;
	assert(r <= n);
  801714:	39 c6                	cmp    %eax,%esi
  801716:	73 16                	jae    80172e <devfile_read+0x48>
  801718:	68 7c 27 80 00       	push   $0x80277c
  80171d:	68 83 27 80 00       	push   $0x802783
  801722:	6a 7d                	push   $0x7d
  801724:	68 98 27 80 00       	push   $0x802798
  801729:	e8 ce 05 00 00       	call   801cfc <_panic>
	assert(r <= PGSIZE);
  80172e:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801733:	7e 16                	jle    80174b <devfile_read+0x65>
  801735:	68 a3 27 80 00       	push   $0x8027a3
  80173a:	68 83 27 80 00       	push   $0x802783
  80173f:	6a 7e                	push   $0x7e
  801741:	68 98 27 80 00       	push   $0x802798
  801746:	e8 b1 05 00 00       	call   801cfc <_panic>
	memmove(buf, &fsipcbuf, r);
  80174b:	83 ec 04             	sub    $0x4,%esp
  80174e:	50                   	push   %eax
  80174f:	68 00 50 80 00       	push   $0x805000
  801754:	ff 75 0c             	pushl  0xc(%ebp)
  801757:	e8 cf f1 ff ff       	call   80092b <memmove>
	return r;
  80175c:	83 c4 10             	add    $0x10,%esp
}
  80175f:	89 d8                	mov    %ebx,%eax
  801761:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801764:	5b                   	pop    %ebx
  801765:	5e                   	pop    %esi
  801766:	c9                   	leave  
  801767:	c3                   	ret    

00801768 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801768:	55                   	push   %ebp
  801769:	89 e5                	mov    %esp,%ebp
  80176b:	56                   	push   %esi
  80176c:	53                   	push   %ebx
  80176d:	83 ec 1c             	sub    $0x1c,%esp
  801770:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801773:	56                   	push   %esi
  801774:	e8 9f ef ff ff       	call   800718 <strlen>
  801779:	83 c4 10             	add    $0x10,%esp
  80177c:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801781:	7f 65                	jg     8017e8 <open+0x80>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801783:	83 ec 0c             	sub    $0xc,%esp
  801786:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801789:	50                   	push   %eax
  80178a:	e8 e1 f8 ff ff       	call   801070 <fd_alloc>
  80178f:	89 c3                	mov    %eax,%ebx
  801791:	83 c4 10             	add    $0x10,%esp
  801794:	85 c0                	test   %eax,%eax
  801796:	78 55                	js     8017ed <open+0x85>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801798:	83 ec 08             	sub    $0x8,%esp
  80179b:	56                   	push   %esi
  80179c:	68 00 50 80 00       	push   $0x805000
  8017a1:	e8 c4 ef ff ff       	call   80076a <strcpy>
	fsipcbuf.open.req_omode = mode;
  8017a6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017a9:	a3 00 54 80 00       	mov    %eax,0x805400



	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8017ae:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8017b1:	b8 01 00 00 00       	mov    $0x1,%eax
  8017b6:	e8 65 fe ff ff       	call   801620 <fsipc>
  8017bb:	89 c3                	mov    %eax,%ebx
  8017bd:	83 c4 10             	add    $0x10,%esp
  8017c0:	85 c0                	test   %eax,%eax
  8017c2:	79 12                	jns    8017d6 <open+0x6e>
		fd_close(fd, 0);
  8017c4:	83 ec 08             	sub    $0x8,%esp
  8017c7:	6a 00                	push   $0x0
  8017c9:	ff 75 f4             	pushl  -0xc(%ebp)
  8017cc:	e8 ce f9 ff ff       	call   80119f <fd_close>
		return r;
  8017d1:	83 c4 10             	add    $0x10,%esp
  8017d4:	eb 17                	jmp    8017ed <open+0x85>
	}

	return fd2num(fd);
  8017d6:	83 ec 0c             	sub    $0xc,%esp
  8017d9:	ff 75 f4             	pushl  -0xc(%ebp)
  8017dc:	e8 67 f8 ff ff       	call   801048 <fd2num>
  8017e1:	89 c3                	mov    %eax,%ebx
  8017e3:	83 c4 10             	add    $0x10,%esp
  8017e6:	eb 05                	jmp    8017ed <open+0x85>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8017e8:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8017ed:	89 d8                	mov    %ebx,%eax
  8017ef:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017f2:	5b                   	pop    %ebx
  8017f3:	5e                   	pop    %esi
  8017f4:	c9                   	leave  
  8017f5:	c3                   	ret    
	...

008017f8 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8017f8:	55                   	push   %ebp
  8017f9:	89 e5                	mov    %esp,%ebp
  8017fb:	56                   	push   %esi
  8017fc:	53                   	push   %ebx
  8017fd:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801800:	83 ec 0c             	sub    $0xc,%esp
  801803:	ff 75 08             	pushl  0x8(%ebp)
  801806:	e8 4d f8 ff ff       	call   801058 <fd2data>
  80180b:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  80180d:	83 c4 08             	add    $0x8,%esp
  801810:	68 af 27 80 00       	push   $0x8027af
  801815:	56                   	push   %esi
  801816:	e8 4f ef ff ff       	call   80076a <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  80181b:	8b 43 04             	mov    0x4(%ebx),%eax
  80181e:	2b 03                	sub    (%ebx),%eax
  801820:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  801826:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  80182d:	00 00 00 
	stat->st_dev = &devpipe;
  801830:	c7 86 88 00 00 00 20 	movl   $0x803020,0x88(%esi)
  801837:	30 80 00 
	return 0;
}
  80183a:	b8 00 00 00 00       	mov    $0x0,%eax
  80183f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801842:	5b                   	pop    %ebx
  801843:	5e                   	pop    %esi
  801844:	c9                   	leave  
  801845:	c3                   	ret    

00801846 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801846:	55                   	push   %ebp
  801847:	89 e5                	mov    %esp,%ebp
  801849:	53                   	push   %ebx
  80184a:	83 ec 0c             	sub    $0xc,%esp
  80184d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801850:	53                   	push   %ebx
  801851:	6a 00                	push   $0x0
  801853:	e8 de f3 ff ff       	call   800c36 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801858:	89 1c 24             	mov    %ebx,(%esp)
  80185b:	e8 f8 f7 ff ff       	call   801058 <fd2data>
  801860:	83 c4 08             	add    $0x8,%esp
  801863:	50                   	push   %eax
  801864:	6a 00                	push   $0x0
  801866:	e8 cb f3 ff ff       	call   800c36 <sys_page_unmap>
}
  80186b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80186e:	c9                   	leave  
  80186f:	c3                   	ret    

00801870 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801870:	55                   	push   %ebp
  801871:	89 e5                	mov    %esp,%ebp
  801873:	57                   	push   %edi
  801874:	56                   	push   %esi
  801875:	53                   	push   %ebx
  801876:	83 ec 1c             	sub    $0x1c,%esp
  801879:	89 c7                	mov    %eax,%edi
  80187b:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  80187e:	a1 04 40 80 00       	mov    0x804004,%eax
  801883:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801886:	83 ec 0c             	sub    $0xc,%esp
  801889:	57                   	push   %edi
  80188a:	e8 71 06 00 00       	call   801f00 <pageref>
  80188f:	89 c6                	mov    %eax,%esi
  801891:	83 c4 04             	add    $0x4,%esp
  801894:	ff 75 e4             	pushl  -0x1c(%ebp)
  801897:	e8 64 06 00 00       	call   801f00 <pageref>
  80189c:	83 c4 10             	add    $0x10,%esp
  80189f:	39 c6                	cmp    %eax,%esi
  8018a1:	0f 94 c0             	sete   %al
  8018a4:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  8018a7:	8b 15 04 40 80 00    	mov    0x804004,%edx
  8018ad:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  8018b0:	39 cb                	cmp    %ecx,%ebx
  8018b2:	75 08                	jne    8018bc <_pipeisclosed+0x4c>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  8018b4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8018b7:	5b                   	pop    %ebx
  8018b8:	5e                   	pop    %esi
  8018b9:	5f                   	pop    %edi
  8018ba:	c9                   	leave  
  8018bb:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  8018bc:	83 f8 01             	cmp    $0x1,%eax
  8018bf:	75 bd                	jne    80187e <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8018c1:	8b 42 58             	mov    0x58(%edx),%eax
  8018c4:	6a 01                	push   $0x1
  8018c6:	50                   	push   %eax
  8018c7:	53                   	push   %ebx
  8018c8:	68 b6 27 80 00       	push   $0x8027b6
  8018cd:	e8 e2 e8 ff ff       	call   8001b4 <cprintf>
  8018d2:	83 c4 10             	add    $0x10,%esp
  8018d5:	eb a7                	jmp    80187e <_pipeisclosed+0xe>

008018d7 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8018d7:	55                   	push   %ebp
  8018d8:	89 e5                	mov    %esp,%ebp
  8018da:	57                   	push   %edi
  8018db:	56                   	push   %esi
  8018dc:	53                   	push   %ebx
  8018dd:	83 ec 28             	sub    $0x28,%esp
  8018e0:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  8018e3:	56                   	push   %esi
  8018e4:	e8 6f f7 ff ff       	call   801058 <fd2data>
  8018e9:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8018eb:	83 c4 10             	add    $0x10,%esp
  8018ee:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8018f2:	75 4a                	jne    80193e <devpipe_write+0x67>
  8018f4:	bf 00 00 00 00       	mov    $0x0,%edi
  8018f9:	eb 56                	jmp    801951 <devpipe_write+0x7a>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  8018fb:	89 da                	mov    %ebx,%edx
  8018fd:	89 f0                	mov    %esi,%eax
  8018ff:	e8 6c ff ff ff       	call   801870 <_pipeisclosed>
  801904:	85 c0                	test   %eax,%eax
  801906:	75 4d                	jne    801955 <devpipe_write+0x7e>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801908:	e8 b8 f2 ff ff       	call   800bc5 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  80190d:	8b 43 04             	mov    0x4(%ebx),%eax
  801910:	8b 13                	mov    (%ebx),%edx
  801912:	83 c2 20             	add    $0x20,%edx
  801915:	39 d0                	cmp    %edx,%eax
  801917:	73 e2                	jae    8018fb <devpipe_write+0x24>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801919:	89 c2                	mov    %eax,%edx
  80191b:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  801921:	79 05                	jns    801928 <devpipe_write+0x51>
  801923:	4a                   	dec    %edx
  801924:	83 ca e0             	or     $0xffffffe0,%edx
  801927:	42                   	inc    %edx
  801928:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80192b:	8a 0c 39             	mov    (%ecx,%edi,1),%cl
  80192e:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801932:	40                   	inc    %eax
  801933:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801936:	47                   	inc    %edi
  801937:	39 7d 10             	cmp    %edi,0x10(%ebp)
  80193a:	77 07                	ja     801943 <devpipe_write+0x6c>
  80193c:	eb 13                	jmp    801951 <devpipe_write+0x7a>
  80193e:	bf 00 00 00 00       	mov    $0x0,%edi
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801943:	8b 43 04             	mov    0x4(%ebx),%eax
  801946:	8b 13                	mov    (%ebx),%edx
  801948:	83 c2 20             	add    $0x20,%edx
  80194b:	39 d0                	cmp    %edx,%eax
  80194d:	73 ac                	jae    8018fb <devpipe_write+0x24>
  80194f:	eb c8                	jmp    801919 <devpipe_write+0x42>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801951:	89 f8                	mov    %edi,%eax
  801953:	eb 05                	jmp    80195a <devpipe_write+0x83>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801955:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  80195a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80195d:	5b                   	pop    %ebx
  80195e:	5e                   	pop    %esi
  80195f:	5f                   	pop    %edi
  801960:	c9                   	leave  
  801961:	c3                   	ret    

00801962 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801962:	55                   	push   %ebp
  801963:	89 e5                	mov    %esp,%ebp
  801965:	57                   	push   %edi
  801966:	56                   	push   %esi
  801967:	53                   	push   %ebx
  801968:	83 ec 18             	sub    $0x18,%esp
  80196b:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  80196e:	57                   	push   %edi
  80196f:	e8 e4 f6 ff ff       	call   801058 <fd2data>
  801974:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801976:	83 c4 10             	add    $0x10,%esp
  801979:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80197d:	75 44                	jne    8019c3 <devpipe_read+0x61>
  80197f:	be 00 00 00 00       	mov    $0x0,%esi
  801984:	eb 4f                	jmp    8019d5 <devpipe_read+0x73>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
				return i;
  801986:	89 f0                	mov    %esi,%eax
  801988:	eb 54                	jmp    8019de <devpipe_read+0x7c>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  80198a:	89 da                	mov    %ebx,%edx
  80198c:	89 f8                	mov    %edi,%eax
  80198e:	e8 dd fe ff ff       	call   801870 <_pipeisclosed>
  801993:	85 c0                	test   %eax,%eax
  801995:	75 42                	jne    8019d9 <devpipe_read+0x77>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801997:	e8 29 f2 ff ff       	call   800bc5 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  80199c:	8b 03                	mov    (%ebx),%eax
  80199e:	3b 43 04             	cmp    0x4(%ebx),%eax
  8019a1:	74 e7                	je     80198a <devpipe_read+0x28>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8019a3:	25 1f 00 00 80       	and    $0x8000001f,%eax
  8019a8:	79 05                	jns    8019af <devpipe_read+0x4d>
  8019aa:	48                   	dec    %eax
  8019ab:	83 c8 e0             	or     $0xffffffe0,%eax
  8019ae:	40                   	inc    %eax
  8019af:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  8019b3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8019b6:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  8019b9:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8019bb:	46                   	inc    %esi
  8019bc:	39 75 10             	cmp    %esi,0x10(%ebp)
  8019bf:	77 07                	ja     8019c8 <devpipe_read+0x66>
  8019c1:	eb 12                	jmp    8019d5 <devpipe_read+0x73>
  8019c3:	be 00 00 00 00       	mov    $0x0,%esi
		while (p->p_rpos == p->p_wpos) {
  8019c8:	8b 03                	mov    (%ebx),%eax
  8019ca:	3b 43 04             	cmp    0x4(%ebx),%eax
  8019cd:	75 d4                	jne    8019a3 <devpipe_read+0x41>
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  8019cf:	85 f6                	test   %esi,%esi
  8019d1:	75 b3                	jne    801986 <devpipe_read+0x24>
  8019d3:	eb b5                	jmp    80198a <devpipe_read+0x28>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  8019d5:	89 f0                	mov    %esi,%eax
  8019d7:	eb 05                	jmp    8019de <devpipe_read+0x7c>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8019d9:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  8019de:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8019e1:	5b                   	pop    %ebx
  8019e2:	5e                   	pop    %esi
  8019e3:	5f                   	pop    %edi
  8019e4:	c9                   	leave  
  8019e5:	c3                   	ret    

008019e6 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  8019e6:	55                   	push   %ebp
  8019e7:	89 e5                	mov    %esp,%ebp
  8019e9:	57                   	push   %edi
  8019ea:	56                   	push   %esi
  8019eb:	53                   	push   %ebx
  8019ec:	83 ec 28             	sub    $0x28,%esp
  8019ef:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  8019f2:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8019f5:	50                   	push   %eax
  8019f6:	e8 75 f6 ff ff       	call   801070 <fd_alloc>
  8019fb:	89 c3                	mov    %eax,%ebx
  8019fd:	83 c4 10             	add    $0x10,%esp
  801a00:	85 c0                	test   %eax,%eax
  801a02:	0f 88 24 01 00 00    	js     801b2c <pipe+0x146>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801a08:	83 ec 04             	sub    $0x4,%esp
  801a0b:	68 07 04 00 00       	push   $0x407
  801a10:	ff 75 e4             	pushl  -0x1c(%ebp)
  801a13:	6a 00                	push   $0x0
  801a15:	e8 d2 f1 ff ff       	call   800bec <sys_page_alloc>
  801a1a:	89 c3                	mov    %eax,%ebx
  801a1c:	83 c4 10             	add    $0x10,%esp
  801a1f:	85 c0                	test   %eax,%eax
  801a21:	0f 88 05 01 00 00    	js     801b2c <pipe+0x146>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801a27:	83 ec 0c             	sub    $0xc,%esp
  801a2a:	8d 45 e0             	lea    -0x20(%ebp),%eax
  801a2d:	50                   	push   %eax
  801a2e:	e8 3d f6 ff ff       	call   801070 <fd_alloc>
  801a33:	89 c3                	mov    %eax,%ebx
  801a35:	83 c4 10             	add    $0x10,%esp
  801a38:	85 c0                	test   %eax,%eax
  801a3a:	0f 88 dc 00 00 00    	js     801b1c <pipe+0x136>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801a40:	83 ec 04             	sub    $0x4,%esp
  801a43:	68 07 04 00 00       	push   $0x407
  801a48:	ff 75 e0             	pushl  -0x20(%ebp)
  801a4b:	6a 00                	push   $0x0
  801a4d:	e8 9a f1 ff ff       	call   800bec <sys_page_alloc>
  801a52:	89 c3                	mov    %eax,%ebx
  801a54:	83 c4 10             	add    $0x10,%esp
  801a57:	85 c0                	test   %eax,%eax
  801a59:	0f 88 bd 00 00 00    	js     801b1c <pipe+0x136>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801a5f:	83 ec 0c             	sub    $0xc,%esp
  801a62:	ff 75 e4             	pushl  -0x1c(%ebp)
  801a65:	e8 ee f5 ff ff       	call   801058 <fd2data>
  801a6a:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801a6c:	83 c4 0c             	add    $0xc,%esp
  801a6f:	68 07 04 00 00       	push   $0x407
  801a74:	50                   	push   %eax
  801a75:	6a 00                	push   $0x0
  801a77:	e8 70 f1 ff ff       	call   800bec <sys_page_alloc>
  801a7c:	89 c3                	mov    %eax,%ebx
  801a7e:	83 c4 10             	add    $0x10,%esp
  801a81:	85 c0                	test   %eax,%eax
  801a83:	0f 88 83 00 00 00    	js     801b0c <pipe+0x126>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801a89:	83 ec 0c             	sub    $0xc,%esp
  801a8c:	ff 75 e0             	pushl  -0x20(%ebp)
  801a8f:	e8 c4 f5 ff ff       	call   801058 <fd2data>
  801a94:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801a9b:	50                   	push   %eax
  801a9c:	6a 00                	push   $0x0
  801a9e:	56                   	push   %esi
  801a9f:	6a 00                	push   $0x0
  801aa1:	e8 6a f1 ff ff       	call   800c10 <sys_page_map>
  801aa6:	89 c3                	mov    %eax,%ebx
  801aa8:	83 c4 20             	add    $0x20,%esp
  801aab:	85 c0                	test   %eax,%eax
  801aad:	78 4f                	js     801afe <pipe+0x118>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801aaf:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801ab5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801ab8:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801aba:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801abd:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801ac4:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801aca:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801acd:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801acf:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801ad2:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801ad9:	83 ec 0c             	sub    $0xc,%esp
  801adc:	ff 75 e4             	pushl  -0x1c(%ebp)
  801adf:	e8 64 f5 ff ff       	call   801048 <fd2num>
  801ae4:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  801ae6:	83 c4 04             	add    $0x4,%esp
  801ae9:	ff 75 e0             	pushl  -0x20(%ebp)
  801aec:	e8 57 f5 ff ff       	call   801048 <fd2num>
  801af1:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  801af4:	83 c4 10             	add    $0x10,%esp
  801af7:	bb 00 00 00 00       	mov    $0x0,%ebx
  801afc:	eb 2e                	jmp    801b2c <pipe+0x146>

    err3:
	sys_page_unmap(0, va);
  801afe:	83 ec 08             	sub    $0x8,%esp
  801b01:	56                   	push   %esi
  801b02:	6a 00                	push   $0x0
  801b04:	e8 2d f1 ff ff       	call   800c36 <sys_page_unmap>
  801b09:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801b0c:	83 ec 08             	sub    $0x8,%esp
  801b0f:	ff 75 e0             	pushl  -0x20(%ebp)
  801b12:	6a 00                	push   $0x0
  801b14:	e8 1d f1 ff ff       	call   800c36 <sys_page_unmap>
  801b19:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801b1c:	83 ec 08             	sub    $0x8,%esp
  801b1f:	ff 75 e4             	pushl  -0x1c(%ebp)
  801b22:	6a 00                	push   $0x0
  801b24:	e8 0d f1 ff ff       	call   800c36 <sys_page_unmap>
  801b29:	83 c4 10             	add    $0x10,%esp
    err:
	return r;
}
  801b2c:	89 d8                	mov    %ebx,%eax
  801b2e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b31:	5b                   	pop    %ebx
  801b32:	5e                   	pop    %esi
  801b33:	5f                   	pop    %edi
  801b34:	c9                   	leave  
  801b35:	c3                   	ret    

00801b36 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801b36:	55                   	push   %ebp
  801b37:	89 e5                	mov    %esp,%ebp
  801b39:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801b3c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b3f:	50                   	push   %eax
  801b40:	ff 75 08             	pushl  0x8(%ebp)
  801b43:	e8 9b f5 ff ff       	call   8010e3 <fd_lookup>
  801b48:	83 c4 10             	add    $0x10,%esp
  801b4b:	85 c0                	test   %eax,%eax
  801b4d:	78 18                	js     801b67 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801b4f:	83 ec 0c             	sub    $0xc,%esp
  801b52:	ff 75 f4             	pushl  -0xc(%ebp)
  801b55:	e8 fe f4 ff ff       	call   801058 <fd2data>
	return _pipeisclosed(fd, p);
  801b5a:	89 c2                	mov    %eax,%edx
  801b5c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b5f:	e8 0c fd ff ff       	call   801870 <_pipeisclosed>
  801b64:	83 c4 10             	add    $0x10,%esp
}
  801b67:	c9                   	leave  
  801b68:	c3                   	ret    
  801b69:	00 00                	add    %al,(%eax)
	...

00801b6c <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801b6c:	55                   	push   %ebp
  801b6d:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801b6f:	b8 00 00 00 00       	mov    $0x0,%eax
  801b74:	c9                   	leave  
  801b75:	c3                   	ret    

00801b76 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801b76:	55                   	push   %ebp
  801b77:	89 e5                	mov    %esp,%ebp
  801b79:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801b7c:	68 ce 27 80 00       	push   $0x8027ce
  801b81:	ff 75 0c             	pushl  0xc(%ebp)
  801b84:	e8 e1 eb ff ff       	call   80076a <strcpy>
	return 0;
}
  801b89:	b8 00 00 00 00       	mov    $0x0,%eax
  801b8e:	c9                   	leave  
  801b8f:	c3                   	ret    

00801b90 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801b90:	55                   	push   %ebp
  801b91:	89 e5                	mov    %esp,%ebp
  801b93:	57                   	push   %edi
  801b94:	56                   	push   %esi
  801b95:	53                   	push   %ebx
  801b96:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801b9c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801ba0:	74 45                	je     801be7 <devcons_write+0x57>
  801ba2:	b8 00 00 00 00       	mov    $0x0,%eax
  801ba7:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801bac:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801bb2:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801bb5:	29 c3                	sub    %eax,%ebx
		if (m > sizeof(buf) - 1)
  801bb7:	83 fb 7f             	cmp    $0x7f,%ebx
  801bba:	76 05                	jbe    801bc1 <devcons_write+0x31>
			m = sizeof(buf) - 1;
  801bbc:	bb 7f 00 00 00       	mov    $0x7f,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  801bc1:	83 ec 04             	sub    $0x4,%esp
  801bc4:	53                   	push   %ebx
  801bc5:	03 45 0c             	add    0xc(%ebp),%eax
  801bc8:	50                   	push   %eax
  801bc9:	57                   	push   %edi
  801bca:	e8 5c ed ff ff       	call   80092b <memmove>
		sys_cputs(buf, m);
  801bcf:	83 c4 08             	add    $0x8,%esp
  801bd2:	53                   	push   %ebx
  801bd3:	57                   	push   %edi
  801bd4:	e8 5c ef ff ff       	call   800b35 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801bd9:	01 de                	add    %ebx,%esi
  801bdb:	89 f0                	mov    %esi,%eax
  801bdd:	83 c4 10             	add    $0x10,%esp
  801be0:	3b 75 10             	cmp    0x10(%ebp),%esi
  801be3:	72 cd                	jb     801bb2 <devcons_write+0x22>
  801be5:	eb 05                	jmp    801bec <devcons_write+0x5c>
  801be7:	be 00 00 00 00       	mov    $0x0,%esi
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801bec:	89 f0                	mov    %esi,%eax
  801bee:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801bf1:	5b                   	pop    %ebx
  801bf2:	5e                   	pop    %esi
  801bf3:	5f                   	pop    %edi
  801bf4:	c9                   	leave  
  801bf5:	c3                   	ret    

00801bf6 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801bf6:	55                   	push   %ebp
  801bf7:	89 e5                	mov    %esp,%ebp
  801bf9:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  801bfc:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801c00:	75 07                	jne    801c09 <devcons_read+0x13>
  801c02:	eb 25                	jmp    801c29 <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801c04:	e8 bc ef ff ff       	call   800bc5 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801c09:	e8 4d ef ff ff       	call   800b5b <sys_cgetc>
  801c0e:	85 c0                	test   %eax,%eax
  801c10:	74 f2                	je     801c04 <devcons_read+0xe>
  801c12:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  801c14:	85 c0                	test   %eax,%eax
  801c16:	78 1d                	js     801c35 <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801c18:	83 f8 04             	cmp    $0x4,%eax
  801c1b:	74 13                	je     801c30 <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  801c1d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c20:	88 10                	mov    %dl,(%eax)
	return 1;
  801c22:	b8 01 00 00 00       	mov    $0x1,%eax
  801c27:	eb 0c                	jmp    801c35 <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  801c29:	b8 00 00 00 00       	mov    $0x0,%eax
  801c2e:	eb 05                	jmp    801c35 <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801c30:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801c35:	c9                   	leave  
  801c36:	c3                   	ret    

00801c37 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801c37:	55                   	push   %ebp
  801c38:	89 e5                	mov    %esp,%ebp
  801c3a:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801c3d:	8b 45 08             	mov    0x8(%ebp),%eax
  801c40:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801c43:	6a 01                	push   $0x1
  801c45:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801c48:	50                   	push   %eax
  801c49:	e8 e7 ee ff ff       	call   800b35 <sys_cputs>
  801c4e:	83 c4 10             	add    $0x10,%esp
}
  801c51:	c9                   	leave  
  801c52:	c3                   	ret    

00801c53 <getchar>:

int
getchar(void)
{
  801c53:	55                   	push   %ebp
  801c54:	89 e5                	mov    %esp,%ebp
  801c56:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801c59:	6a 01                	push   $0x1
  801c5b:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801c5e:	50                   	push   %eax
  801c5f:	6a 00                	push   $0x0
  801c61:	e8 fe f6 ff ff       	call   801364 <read>
	if (r < 0)
  801c66:	83 c4 10             	add    $0x10,%esp
  801c69:	85 c0                	test   %eax,%eax
  801c6b:	78 0f                	js     801c7c <getchar+0x29>
		return r;
	if (r < 1)
  801c6d:	85 c0                	test   %eax,%eax
  801c6f:	7e 06                	jle    801c77 <getchar+0x24>
		return -E_EOF;
	return c;
  801c71:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801c75:	eb 05                	jmp    801c7c <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801c77:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801c7c:	c9                   	leave  
  801c7d:	c3                   	ret    

00801c7e <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801c7e:	55                   	push   %ebp
  801c7f:	89 e5                	mov    %esp,%ebp
  801c81:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801c84:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c87:	50                   	push   %eax
  801c88:	ff 75 08             	pushl  0x8(%ebp)
  801c8b:	e8 53 f4 ff ff       	call   8010e3 <fd_lookup>
  801c90:	83 c4 10             	add    $0x10,%esp
  801c93:	85 c0                	test   %eax,%eax
  801c95:	78 11                	js     801ca8 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801c97:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c9a:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801ca0:	39 10                	cmp    %edx,(%eax)
  801ca2:	0f 94 c0             	sete   %al
  801ca5:	0f b6 c0             	movzbl %al,%eax
}
  801ca8:	c9                   	leave  
  801ca9:	c3                   	ret    

00801caa <opencons>:

int
opencons(void)
{
  801caa:	55                   	push   %ebp
  801cab:	89 e5                	mov    %esp,%ebp
  801cad:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801cb0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801cb3:	50                   	push   %eax
  801cb4:	e8 b7 f3 ff ff       	call   801070 <fd_alloc>
  801cb9:	83 c4 10             	add    $0x10,%esp
  801cbc:	85 c0                	test   %eax,%eax
  801cbe:	78 3a                	js     801cfa <opencons+0x50>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801cc0:	83 ec 04             	sub    $0x4,%esp
  801cc3:	68 07 04 00 00       	push   $0x407
  801cc8:	ff 75 f4             	pushl  -0xc(%ebp)
  801ccb:	6a 00                	push   $0x0
  801ccd:	e8 1a ef ff ff       	call   800bec <sys_page_alloc>
  801cd2:	83 c4 10             	add    $0x10,%esp
  801cd5:	85 c0                	test   %eax,%eax
  801cd7:	78 21                	js     801cfa <opencons+0x50>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801cd9:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801cdf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ce2:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801ce4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ce7:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801cee:	83 ec 0c             	sub    $0xc,%esp
  801cf1:	50                   	push   %eax
  801cf2:	e8 51 f3 ff ff       	call   801048 <fd2num>
  801cf7:	83 c4 10             	add    $0x10,%esp
}
  801cfa:	c9                   	leave  
  801cfb:	c3                   	ret    

00801cfc <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801cfc:	55                   	push   %ebp
  801cfd:	89 e5                	mov    %esp,%ebp
  801cff:	56                   	push   %esi
  801d00:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801d01:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801d04:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  801d0a:	e8 92 ee ff ff       	call   800ba1 <sys_getenvid>
  801d0f:	83 ec 0c             	sub    $0xc,%esp
  801d12:	ff 75 0c             	pushl  0xc(%ebp)
  801d15:	ff 75 08             	pushl  0x8(%ebp)
  801d18:	53                   	push   %ebx
  801d19:	50                   	push   %eax
  801d1a:	68 dc 27 80 00       	push   $0x8027dc
  801d1f:	e8 90 e4 ff ff       	call   8001b4 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801d24:	83 c4 18             	add    $0x18,%esp
  801d27:	56                   	push   %esi
  801d28:	ff 75 10             	pushl  0x10(%ebp)
  801d2b:	e8 33 e4 ff ff       	call   800163 <vcprintf>
	cprintf("\n");
  801d30:	c7 04 24 34 22 80 00 	movl   $0x802234,(%esp)
  801d37:	e8 78 e4 ff ff       	call   8001b4 <cprintf>
  801d3c:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801d3f:	cc                   	int3   
  801d40:	eb fd                	jmp    801d3f <_panic+0x43>
	...

00801d44 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801d44:	55                   	push   %ebp
  801d45:	89 e5                	mov    %esp,%ebp
  801d47:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  801d4a:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801d51:	75 52                	jne    801da5 <set_pgfault_handler+0x61>
		// First time through!	
		// LAB 4: Your code here.

		//int sys_page_alloc(envid_t envid, void *va, int perm)
		r = sys_page_alloc(0, (void*)(UXSTACKTOP - PGSIZE), PTE_U | PTE_W | PTE_P);
  801d53:	83 ec 04             	sub    $0x4,%esp
  801d56:	6a 07                	push   $0x7
  801d58:	68 00 f0 bf ee       	push   $0xeebff000
  801d5d:	6a 00                	push   $0x0
  801d5f:	e8 88 ee ff ff       	call   800bec <sys_page_alloc>
		if (r < 0) {
  801d64:	83 c4 10             	add    $0x10,%esp
  801d67:	85 c0                	test   %eax,%eax
  801d69:	79 12                	jns    801d7d <set_pgfault_handler+0x39>
			panic("sys_page_alloc error : %e\n", r);
  801d6b:	50                   	push   %eax
  801d6c:	68 ff 27 80 00       	push   $0x8027ff
  801d71:	6a 24                	push   $0x24
  801d73:	68 1a 28 80 00       	push   $0x80281a
  801d78:	e8 7f ff ff ff       	call   801cfc <_panic>
		}

		// how to know envid, put 0, envid2env will help us to get curenv in syscall
		r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);		
  801d7d:	83 ec 08             	sub    $0x8,%esp
  801d80:	68 b0 1d 80 00       	push   $0x801db0
  801d85:	6a 00                	push   $0x0
  801d87:	e8 13 ef ff ff       	call   800c9f <sys_env_set_pgfault_upcall>
		if (r < 0) {
  801d8c:	83 c4 10             	add    $0x10,%esp
  801d8f:	85 c0                	test   %eax,%eax
  801d91:	79 12                	jns    801da5 <set_pgfault_handler+0x61>
			panic("sys_env_set_pgfault_upcall error : %e\n", r);
  801d93:	50                   	push   %eax
  801d94:	68 28 28 80 00       	push   $0x802828
  801d99:	6a 2a                	push   $0x2a
  801d9b:	68 1a 28 80 00       	push   $0x80281a
  801da0:	e8 57 ff ff ff       	call   801cfc <_panic>
		}
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801da5:	8b 45 08             	mov    0x8(%ebp),%eax
  801da8:	a3 00 60 80 00       	mov    %eax,0x806000
}
  801dad:	c9                   	leave  
  801dae:	c3                   	ret    
	...

00801db0 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801db0:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801db1:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  801db6:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801db8:	83 c4 04             	add    $0x4,%esp
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	
	// fix old esp
	movl 0x30(%esp), %eax
  801dbb:	8b 44 24 30          	mov    0x30(%esp),%eax
	subl $0x4, %eax
  801dbf:	83 e8 04             	sub    $0x4,%eax
	movl %eax, 0x30(%esp)
  801dc2:	89 44 24 30          	mov    %eax,0x30(%esp)

	// set trap-time %eip
	movl 0x28(%esp), %ebx
  801dc6:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	movl %ebx, (%eax)
  801dca:	89 18                	mov    %ebx,(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $0x08, %esp 	// ignore err_code and fault_va
  801dcc:	83 c4 08             	add    $0x8,%esp
	popal 				// restore registers
  801dcf:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x04, %esp 	// ignore eip 
  801dd0:	83 c4 04             	add    $0x4,%esp
	popfl				// modify eflags
  801dd3:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  801dd4:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  801dd5:	c3                   	ret    
	...

00801dd8 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801dd8:	55                   	push   %ebp
  801dd9:	89 e5                	mov    %esp,%ebp
  801ddb:	56                   	push   %esi
  801ddc:	53                   	push   %ebx
  801ddd:	8b 75 08             	mov    0x8(%ebp),%esi
  801de0:	8b 45 0c             	mov    0xc(%ebp),%eax
  801de3:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// cprintf("0x%x 0x%x 0x%x\n", (uint32_t)from_env_store, (uint32_t)pg, (uint32_t)perm_store);
	int r;
	if (pg != NULL) {
  801de6:	85 c0                	test   %eax,%eax
  801de8:	74 0e                	je     801df8 <ipc_recv+0x20>
		r = sys_ipc_recv(pg);
  801dea:	83 ec 0c             	sub    $0xc,%esp
  801ded:	50                   	push   %eax
  801dee:	e8 f4 ee ff ff       	call   800ce7 <sys_ipc_recv>
  801df3:	83 c4 10             	add    $0x10,%esp
  801df6:	eb 10                	jmp    801e08 <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv((void *)UTOP);
  801df8:	83 ec 0c             	sub    $0xc,%esp
  801dfb:	68 00 00 c0 ee       	push   $0xeec00000
  801e00:	e8 e2 ee ff ff       	call   800ce7 <sys_ipc_recv>
  801e05:	83 c4 10             	add    $0x10,%esp
	}

	if (r == 0) {
  801e08:	85 c0                	test   %eax,%eax
  801e0a:	75 26                	jne    801e32 <ipc_recv+0x5a>
		if (from_env_store != NULL) *from_env_store = thisenv->env_ipc_from;
  801e0c:	85 f6                	test   %esi,%esi
  801e0e:	74 0a                	je     801e1a <ipc_recv+0x42>
  801e10:	a1 04 40 80 00       	mov    0x804004,%eax
  801e15:	8b 40 74             	mov    0x74(%eax),%eax
  801e18:	89 06                	mov    %eax,(%esi)
		if (perm_store != NULL) *perm_store = thisenv->env_ipc_perm;
  801e1a:	85 db                	test   %ebx,%ebx
  801e1c:	74 0a                	je     801e28 <ipc_recv+0x50>
  801e1e:	a1 04 40 80 00       	mov    0x804004,%eax
  801e23:	8b 40 78             	mov    0x78(%eax),%eax
  801e26:	89 03                	mov    %eax,(%ebx)
		return thisenv->env_ipc_value;
  801e28:	a1 04 40 80 00       	mov    0x804004,%eax
  801e2d:	8b 40 70             	mov    0x70(%eax),%eax
  801e30:	eb 14                	jmp    801e46 <ipc_recv+0x6e>
	} else {
		// fails;
		if (from_env_store != NULL) *from_env_store = 0;
  801e32:	85 f6                	test   %esi,%esi
  801e34:	74 06                	je     801e3c <ipc_recv+0x64>
  801e36:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if (perm_store != NULL) *perm_store = 0;
  801e3c:	85 db                	test   %ebx,%ebx
  801e3e:	74 06                	je     801e46 <ipc_recv+0x6e>
  801e40:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		return r;
	}
}
  801e46:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e49:	5b                   	pop    %ebx
  801e4a:	5e                   	pop    %esi
  801e4b:	c9                   	leave  
  801e4c:	c3                   	ret    

00801e4d <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801e4d:	55                   	push   %ebp
  801e4e:	89 e5                	mov    %esp,%ebp
  801e50:	57                   	push   %edi
  801e51:	56                   	push   %esi
  801e52:	53                   	push   %ebx
  801e53:	83 ec 0c             	sub    $0xc,%esp
  801e56:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801e59:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801e5c:	8b 75 14             	mov    0x14(%ebp),%esi
	// LAB 4: Your code here.
	// int sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
	int r;
	if (pg == NULL) pg = (void *)UTOP;
  801e5f:	85 db                	test   %ebx,%ebx
  801e61:	75 25                	jne    801e88 <ipc_send+0x3b>
  801e63:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
  801e68:	eb 1e                	jmp    801e88 <ipc_send+0x3b>
	
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) != 0) {
		if (r == -E_IPC_NOT_RECV) {
  801e6a:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801e6d:	75 07                	jne    801e76 <ipc_send+0x29>
			// cprintf("Try Again and Again....\n");
			sys_yield();
  801e6f:	e8 51 ed ff ff       	call   800bc5 <sys_yield>
  801e74:	eb 12                	jmp    801e88 <ipc_send+0x3b>
		} else {
			panic("ipc_send error %e\n", r);
  801e76:	50                   	push   %eax
  801e77:	68 50 28 80 00       	push   $0x802850
  801e7c:	6a 43                	push   $0x43
  801e7e:	68 63 28 80 00       	push   $0x802863
  801e83:	e8 74 fe ff ff       	call   801cfc <_panic>
	// LAB 4: Your code here.
	// int sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
	int r;
	if (pg == NULL) pg = (void *)UTOP;
	
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) != 0) {
  801e88:	56                   	push   %esi
  801e89:	53                   	push   %ebx
  801e8a:	57                   	push   %edi
  801e8b:	ff 75 08             	pushl  0x8(%ebp)
  801e8e:	e8 2f ee ff ff       	call   800cc2 <sys_ipc_try_send>
  801e93:	83 c4 10             	add    $0x10,%esp
  801e96:	85 c0                	test   %eax,%eax
  801e98:	75 d0                	jne    801e6a <ipc_send+0x1d>
		} else {
			panic("ipc_send error %e\n", r);
		}
	}
	return;
}
  801e9a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e9d:	5b                   	pop    %ebx
  801e9e:	5e                   	pop    %esi
  801e9f:	5f                   	pop    %edi
  801ea0:	c9                   	leave  
  801ea1:	c3                   	ret    

00801ea2 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801ea2:	55                   	push   %ebp
  801ea3:	89 e5                	mov    %esp,%ebp
  801ea5:	53                   	push   %ebx
  801ea6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  801ea9:	39 1d 50 00 c0 ee    	cmp    %ebx,0xeec00050
  801eaf:	74 22                	je     801ed3 <ipc_find_env+0x31>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801eb1:	b8 01 00 00 00       	mov    $0x1,%eax
		if (envs[i].env_type == type)
  801eb6:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  801ebd:	89 c2                	mov    %eax,%edx
  801ebf:	c1 e2 07             	shl    $0x7,%edx
  801ec2:	29 ca                	sub    %ecx,%edx
  801ec4:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801eca:	8b 52 50             	mov    0x50(%edx),%edx
  801ecd:	39 da                	cmp    %ebx,%edx
  801ecf:	75 1d                	jne    801eee <ipc_find_env+0x4c>
  801ed1:	eb 05                	jmp    801ed8 <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801ed3:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
			return envs[i].env_id;
  801ed8:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  801edf:	c1 e0 07             	shl    $0x7,%eax
  801ee2:	29 d0                	sub    %edx,%eax
  801ee4:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  801ee9:	8b 40 40             	mov    0x40(%eax),%eax
  801eec:	eb 0c                	jmp    801efa <ipc_find_env+0x58>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801eee:	40                   	inc    %eax
  801eef:	3d 00 04 00 00       	cmp    $0x400,%eax
  801ef4:	75 c0                	jne    801eb6 <ipc_find_env+0x14>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801ef6:	66 b8 00 00          	mov    $0x0,%ax
}
  801efa:	5b                   	pop    %ebx
  801efb:	c9                   	leave  
  801efc:	c3                   	ret    
  801efd:	00 00                	add    %al,(%eax)
	...

00801f00 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801f00:	55                   	push   %ebp
  801f01:	89 e5                	mov    %esp,%ebp
  801f03:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801f06:	89 c2                	mov    %eax,%edx
  801f08:	c1 ea 16             	shr    $0x16,%edx
  801f0b:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801f12:	f6 c2 01             	test   $0x1,%dl
  801f15:	74 1e                	je     801f35 <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  801f17:	c1 e8 0c             	shr    $0xc,%eax
  801f1a:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801f21:	a8 01                	test   $0x1,%al
  801f23:	74 17                	je     801f3c <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801f25:	c1 e8 0c             	shr    $0xc,%eax
  801f28:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  801f2f:	ef 
  801f30:	0f b7 c0             	movzwl %ax,%eax
  801f33:	eb 0c                	jmp    801f41 <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  801f35:	b8 00 00 00 00       	mov    $0x0,%eax
  801f3a:	eb 05                	jmp    801f41 <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  801f3c:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  801f41:	c9                   	leave  
  801f42:	c3                   	ret    
	...

00801f44 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  801f44:	55                   	push   %ebp
  801f45:	89 e5                	mov    %esp,%ebp
  801f47:	57                   	push   %edi
  801f48:	56                   	push   %esi
  801f49:	83 ec 10             	sub    $0x10,%esp
  801f4c:	8b 7d 08             	mov    0x8(%ebp),%edi
  801f4f:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  801f52:	89 7d f0             	mov    %edi,-0x10(%ebp)
  801f55:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  801f58:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  801f5b:	8b 45 14             	mov    0x14(%ebp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  801f5e:	85 c0                	test   %eax,%eax
  801f60:	75 2e                	jne    801f90 <__udivdi3+0x4c>
    {
      if (d0 > n1)
  801f62:	39 f1                	cmp    %esi,%ecx
  801f64:	77 5a                	ja     801fc0 <__udivdi3+0x7c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  801f66:	85 c9                	test   %ecx,%ecx
  801f68:	75 0b                	jne    801f75 <__udivdi3+0x31>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  801f6a:	b8 01 00 00 00       	mov    $0x1,%eax
  801f6f:	31 d2                	xor    %edx,%edx
  801f71:	f7 f1                	div    %ecx
  801f73:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  801f75:	31 d2                	xor    %edx,%edx
  801f77:	89 f0                	mov    %esi,%eax
  801f79:	f7 f1                	div    %ecx
  801f7b:	89 c6                	mov    %eax,%esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801f7d:	89 f8                	mov    %edi,%eax
  801f7f:	f7 f1                	div    %ecx
  801f81:	89 c7                	mov    %eax,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801f83:	89 f8                	mov    %edi,%eax
  801f85:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801f87:	83 c4 10             	add    $0x10,%esp
  801f8a:	5e                   	pop    %esi
  801f8b:	5f                   	pop    %edi
  801f8c:	c9                   	leave  
  801f8d:	c3                   	ret    
  801f8e:	66 90                	xchg   %ax,%ax
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801f90:	39 f0                	cmp    %esi,%eax
  801f92:	77 1c                	ja     801fb0 <__udivdi3+0x6c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  801f94:	0f bd f8             	bsr    %eax,%edi
	  if (bm == 0)
  801f97:	83 f7 1f             	xor    $0x1f,%edi
  801f9a:	75 3c                	jne    801fd8 <__udivdi3+0x94>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801f9c:	39 f0                	cmp    %esi,%eax
  801f9e:	0f 82 90 00 00 00    	jb     802034 <__udivdi3+0xf0>
  801fa4:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801fa7:	39 55 f4             	cmp    %edx,-0xc(%ebp)
  801faa:	0f 86 84 00 00 00    	jbe    802034 <__udivdi3+0xf0>
  801fb0:	31 f6                	xor    %esi,%esi
  801fb2:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801fb4:	89 f8                	mov    %edi,%eax
  801fb6:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801fb8:	83 c4 10             	add    $0x10,%esp
  801fbb:	5e                   	pop    %esi
  801fbc:	5f                   	pop    %edi
  801fbd:	c9                   	leave  
  801fbe:	c3                   	ret    
  801fbf:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801fc0:	89 f2                	mov    %esi,%edx
  801fc2:	89 f8                	mov    %edi,%eax
  801fc4:	f7 f1                	div    %ecx
  801fc6:	89 c7                	mov    %eax,%edi
  801fc8:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801fca:	89 f8                	mov    %edi,%eax
  801fcc:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801fce:	83 c4 10             	add    $0x10,%esp
  801fd1:	5e                   	pop    %esi
  801fd2:	5f                   	pop    %edi
  801fd3:	c9                   	leave  
  801fd4:	c3                   	ret    
  801fd5:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  801fd8:	89 f9                	mov    %edi,%ecx
  801fda:	d3 e0                	shl    %cl,%eax
  801fdc:	89 45 e8             	mov    %eax,-0x18(%ebp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  801fdf:	b8 20 00 00 00       	mov    $0x20,%eax
  801fe4:	29 f8                	sub    %edi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  801fe6:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801fe9:	88 c1                	mov    %al,%cl
  801feb:	d3 ea                	shr    %cl,%edx
  801fed:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  801ff0:	09 ca                	or     %ecx,%edx
  801ff2:	89 55 ec             	mov    %edx,-0x14(%ebp)
	      d0 = d0 << bm;
  801ff5:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801ff8:	89 f9                	mov    %edi,%ecx
  801ffa:	d3 e2                	shl    %cl,%edx
  801ffc:	89 55 f4             	mov    %edx,-0xc(%ebp)
	      n2 = n1 >> b;
  801fff:	89 f2                	mov    %esi,%edx
  802001:	88 c1                	mov    %al,%cl
  802003:	d3 ea                	shr    %cl,%edx
  802005:	89 55 e8             	mov    %edx,-0x18(%ebp)
	      n1 = (n1 << bm) | (n0 >> b);
  802008:	89 f2                	mov    %esi,%edx
  80200a:	89 f9                	mov    %edi,%ecx
  80200c:	d3 e2                	shl    %cl,%edx
  80200e:	8b 75 f0             	mov    -0x10(%ebp),%esi
  802011:	88 c1                	mov    %al,%cl
  802013:	d3 ee                	shr    %cl,%esi
  802015:	09 d6                	or     %edx,%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  802017:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  80201a:	89 f0                	mov    %esi,%eax
  80201c:	89 ca                	mov    %ecx,%edx
  80201e:	f7 75 ec             	divl   -0x14(%ebp)
  802021:	89 d1                	mov    %edx,%ecx
  802023:	89 c6                	mov    %eax,%esi
	      umul_ppmm (m1, m0, q0, d0);
  802025:	f7 65 f4             	mull   -0xc(%ebp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802028:	39 d1                	cmp    %edx,%ecx
  80202a:	72 28                	jb     802054 <__udivdi3+0x110>
  80202c:	74 1a                	je     802048 <__udivdi3+0x104>
  80202e:	89 f7                	mov    %esi,%edi
  802030:	31 f6                	xor    %esi,%esi
  802032:	eb 80                	jmp    801fb4 <__udivdi3+0x70>
	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  802034:	31 f6                	xor    %esi,%esi
  802036:	bf 01 00 00 00       	mov    $0x1,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  80203b:	89 f8                	mov    %edi,%eax
  80203d:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  80203f:	83 c4 10             	add    $0x10,%esp
  802042:	5e                   	pop    %esi
  802043:	5f                   	pop    %edi
  802044:	c9                   	leave  
  802045:	c3                   	ret    
  802046:	66 90                	xchg   %ax,%ax

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  802048:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80204b:	89 f9                	mov    %edi,%ecx
  80204d:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  80204f:	39 c2                	cmp    %eax,%edx
  802051:	73 db                	jae    80202e <__udivdi3+0xea>
  802053:	90                   	nop
		{
		  q0--;
  802054:	8d 7e ff             	lea    -0x1(%esi),%edi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  802057:	31 f6                	xor    %esi,%esi
  802059:	e9 56 ff ff ff       	jmp    801fb4 <__udivdi3+0x70>
	...

00802060 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  802060:	55                   	push   %ebp
  802061:	89 e5                	mov    %esp,%ebp
  802063:	57                   	push   %edi
  802064:	56                   	push   %esi
  802065:	83 ec 20             	sub    $0x20,%esp
  802068:	8b 45 08             	mov    0x8(%ebp),%eax
  80206b:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  80206e:	89 45 e8             	mov    %eax,-0x18(%ebp)
  802071:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  802074:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  802077:	8b 7d 14             	mov    0x14(%ebp),%edi
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  80207a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  n1 = nn.s.high;
  80207d:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  80207f:	85 ff                	test   %edi,%edi
  802081:	75 15                	jne    802098 <__umoddi3+0x38>
    {
      if (d0 > n1)
  802083:	39 f1                	cmp    %esi,%ecx
  802085:	0f 86 99 00 00 00    	jbe    802124 <__umoddi3+0xc4>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  80208b:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  80208d:	89 d0                	mov    %edx,%eax
  80208f:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802091:	83 c4 20             	add    $0x20,%esp
  802094:	5e                   	pop    %esi
  802095:	5f                   	pop    %edi
  802096:	c9                   	leave  
  802097:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  802098:	39 f7                	cmp    %esi,%edi
  80209a:	0f 87 a4 00 00 00    	ja     802144 <__umoddi3+0xe4>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  8020a0:	0f bd c7             	bsr    %edi,%eax
	  if (bm == 0)
  8020a3:	83 f0 1f             	xor    $0x1f,%eax
  8020a6:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8020a9:	0f 84 a1 00 00 00    	je     802150 <__umoddi3+0xf0>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  8020af:	89 f8                	mov    %edi,%eax
  8020b1:	8a 4d ec             	mov    -0x14(%ebp),%cl
  8020b4:	d3 e0                	shl    %cl,%eax
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  8020b6:	bf 20 00 00 00       	mov    $0x20,%edi
  8020bb:	2b 7d ec             	sub    -0x14(%ebp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  8020be:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8020c1:	89 f9                	mov    %edi,%ecx
  8020c3:	d3 ea                	shr    %cl,%edx
  8020c5:	09 c2                	or     %eax,%edx
  8020c7:	89 55 f0             	mov    %edx,-0x10(%ebp)
	      d0 = d0 << bm;
  8020ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020cd:	8a 4d ec             	mov    -0x14(%ebp),%cl
  8020d0:	d3 e0                	shl    %cl,%eax
  8020d2:	89 45 f4             	mov    %eax,-0xc(%ebp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  8020d5:	89 f2                	mov    %esi,%edx
  8020d7:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  8020d9:	8b 45 e8             	mov    -0x18(%ebp),%eax
  8020dc:	d3 e0                	shl    %cl,%eax
  8020de:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  8020e1:	8b 45 e8             	mov    -0x18(%ebp),%eax
  8020e4:	89 f9                	mov    %edi,%ecx
  8020e6:	d3 e8                	shr    %cl,%eax
  8020e8:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  8020ea:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  8020ec:	89 f2                	mov    %esi,%edx
  8020ee:	f7 75 f0             	divl   -0x10(%ebp)
  8020f1:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  8020f3:	f7 65 f4             	mull   -0xc(%ebp)
  8020f6:	89 55 e8             	mov    %edx,-0x18(%ebp)
  8020f9:	89 c1                	mov    %eax,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8020fb:	39 d6                	cmp    %edx,%esi
  8020fd:	72 71                	jb     802170 <__umoddi3+0x110>
  8020ff:	74 7f                	je     802180 <__umoddi3+0x120>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  802101:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802104:	29 c8                	sub    %ecx,%eax
  802106:	19 d6                	sbb    %edx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  802108:	8a 4d ec             	mov    -0x14(%ebp),%cl
  80210b:	d3 e8                	shr    %cl,%eax
  80210d:	89 f2                	mov    %esi,%edx
  80210f:	89 f9                	mov    %edi,%ecx
  802111:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  802113:	09 d0                	or     %edx,%eax
  802115:	89 f2                	mov    %esi,%edx
  802117:	8a 4d ec             	mov    -0x14(%ebp),%cl
  80211a:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  80211c:	83 c4 20             	add    $0x20,%esp
  80211f:	5e                   	pop    %esi
  802120:	5f                   	pop    %edi
  802121:	c9                   	leave  
  802122:	c3                   	ret    
  802123:	90                   	nop
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  802124:	85 c9                	test   %ecx,%ecx
  802126:	75 0b                	jne    802133 <__umoddi3+0xd3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  802128:	b8 01 00 00 00       	mov    $0x1,%eax
  80212d:	31 d2                	xor    %edx,%edx
  80212f:	f7 f1                	div    %ecx
  802131:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  802133:	89 f0                	mov    %esi,%eax
  802135:	31 d2                	xor    %edx,%edx
  802137:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802139:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80213c:	f7 f1                	div    %ecx
  80213e:	e9 4a ff ff ff       	jmp    80208d <__umoddi3+0x2d>
  802143:	90                   	nop
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  802144:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802146:	83 c4 20             	add    $0x20,%esp
  802149:	5e                   	pop    %esi
  80214a:	5f                   	pop    %edi
  80214b:	c9                   	leave  
  80214c:	c3                   	ret    
  80214d:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802150:	39 f7                	cmp    %esi,%edi
  802152:	72 05                	jb     802159 <__umoddi3+0xf9>
  802154:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
  802157:	77 0c                	ja     802165 <__umoddi3+0x105>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  802159:	89 f2                	mov    %esi,%edx
  80215b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80215e:	29 c8                	sub    %ecx,%eax
  802160:	19 fa                	sbb    %edi,%edx
  802162:	89 45 f0             	mov    %eax,-0x10(%ebp)

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  802165:	8b 45 f0             	mov    -0x10(%ebp),%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802168:	83 c4 20             	add    $0x20,%esp
  80216b:	5e                   	pop    %esi
  80216c:	5f                   	pop    %edi
  80216d:	c9                   	leave  
  80216e:	c3                   	ret    
  80216f:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  802170:	8b 55 e8             	mov    -0x18(%ebp),%edx
  802173:	89 c1                	mov    %eax,%ecx
  802175:	2b 4d f4             	sub    -0xc(%ebp),%ecx
  802178:	1b 55 f0             	sbb    -0x10(%ebp),%edx
  80217b:	eb 84                	jmp    802101 <__umoddi3+0xa1>
  80217d:	8d 76 00             	lea    0x0(%esi),%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802180:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  802183:	72 eb                	jb     802170 <__umoddi3+0x110>
  802185:	89 f2                	mov    %esi,%edx
  802187:	e9 75 ff ff ff       	jmp    802101 <__umoddi3+0xa1>
