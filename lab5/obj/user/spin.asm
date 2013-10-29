
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
  80010e:	e8 fb 10 00 00       	call   80120e <close_all>
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
  80021c:	e8 2f 1d 00 00       	call   801f50 <__udivdi3>
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
  800258:	e8 0f 1e 00 00       	call   80206c <__umoddi3>
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
  800476:	68 9b 27 80 00       	push   $0x80279b
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
  800b26:	e8 ad 11 00 00       	call   801cd8 <_panic>

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
  800d4d:	e8 86 0f 00 00       	call   801cd8 <_panic>

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
  800d82:	e8 51 0f 00 00       	call   801cd8 <_panic>
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
  800dac:	e8 27 0f 00 00       	call   801cd8 <_panic>

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
  800df4:	e8 df 0e 00 00       	call   801cd8 <_panic>

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
  800e0c:	e8 0f 0f 00 00       	call   801d20 <set_pgfault_handler>
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
  800e2c:	6a 7b                	push   $0x7b
  800e2e:	68 b0 26 80 00       	push   $0x8026b0
  800e33:	e8 a0 0e 00 00       	call   801cd8 <_panic>
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
  800e5e:	e9 7b 01 00 00       	jmp    800fde <fork+0x1e0>
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
  800e76:	0f 84 cd 00 00 00    	je     800f49 <fork+0x14b>
  800e7c:	89 d8                	mov    %ebx,%eax
  800e7e:	c1 e8 0c             	shr    $0xc,%eax
  800e81:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800e88:	f6 c2 01             	test   $0x1,%dl
  800e8b:	0f 84 b8 00 00 00    	je     800f49 <fork+0x14b>
  800e91:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800e98:	f6 c2 04             	test   $0x4,%dl
  800e9b:	0f 84 a8 00 00 00    	je     800f49 <fork+0x14b>
//
static int
duppage(envid_t envid, unsigned pn)
{
	// do not dup exception stack
	if (pn * PGSIZE == UXSTACKTOP - PGSIZE) return 0;
  800ea1:	89 c6                	mov    %eax,%esi
  800ea3:	c1 e6 0c             	shl    $0xc,%esi
  800ea6:	81 fe 00 f0 bf ee    	cmp    $0xeebff000,%esi
  800eac:	0f 84 97 00 00 00    	je     800f49 <fork+0x14b>

	int r;
	void * addr = (void *)(pn * PGSIZE);
	if ((uvpt[pn] & PTE_W) || (uvpt[pn] & PTE_COW)) {
  800eb2:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800eb9:	f6 c2 02             	test   $0x2,%dl
  800ebc:	75 0c                	jne    800eca <fork+0xcc>
  800ebe:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800ec5:	f6 c4 08             	test   $0x8,%ah
  800ec8:	74 57                	je     800f21 <fork+0x123>
		// cow
		r = sys_page_map(0, addr, envid, addr, PTE_COW | PTE_P | PTE_U);
  800eca:	83 ec 0c             	sub    $0xc,%esp
  800ecd:	68 05 08 00 00       	push   $0x805
  800ed2:	56                   	push   %esi
  800ed3:	57                   	push   %edi
  800ed4:	56                   	push   %esi
  800ed5:	6a 00                	push   $0x0
  800ed7:	e8 34 fd ff ff       	call   800c10 <sys_page_map>
		if (r < 0) panic("duppage sys_page_map error : %e\n", r);
  800edc:	83 c4 20             	add    $0x20,%esp
  800edf:	85 c0                	test   %eax,%eax
  800ee1:	79 12                	jns    800ef5 <fork+0xf7>
  800ee3:	50                   	push   %eax
  800ee4:	68 fc 25 80 00       	push   $0x8025fc
  800ee9:	6a 55                	push   $0x55
  800eeb:	68 b0 26 80 00       	push   $0x8026b0
  800ef0:	e8 e3 0d 00 00       	call   801cd8 <_panic>
		
		r = sys_page_map(0, addr, 0, addr, PTE_COW | PTE_P | PTE_U);
  800ef5:	83 ec 0c             	sub    $0xc,%esp
  800ef8:	68 05 08 00 00       	push   $0x805
  800efd:	56                   	push   %esi
  800efe:	6a 00                	push   $0x0
  800f00:	56                   	push   %esi
  800f01:	6a 00                	push   $0x0
  800f03:	e8 08 fd ff ff       	call   800c10 <sys_page_map>
		if (r < 0) panic("duppage sys_page_map error : %e\n", r);
  800f08:	83 c4 20             	add    $0x20,%esp
  800f0b:	85 c0                	test   %eax,%eax
  800f0d:	79 3a                	jns    800f49 <fork+0x14b>
  800f0f:	50                   	push   %eax
  800f10:	68 fc 25 80 00       	push   $0x8025fc
  800f15:	6a 58                	push   $0x58
  800f17:	68 b0 26 80 00       	push   $0x8026b0
  800f1c:	e8 b7 0d 00 00       	call   801cd8 <_panic>
	} else {
		// read only
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U);
  800f21:	83 ec 0c             	sub    $0xc,%esp
  800f24:	6a 05                	push   $0x5
  800f26:	56                   	push   %esi
  800f27:	57                   	push   %edi
  800f28:	56                   	push   %esi
  800f29:	6a 00                	push   $0x0
  800f2b:	e8 e0 fc ff ff       	call   800c10 <sys_page_map>
		if (r < 0) panic("duppage sys_page_map error : %e\n", r);
  800f30:	83 c4 20             	add    $0x20,%esp
  800f33:	85 c0                	test   %eax,%eax
  800f35:	79 12                	jns    800f49 <fork+0x14b>
  800f37:	50                   	push   %eax
  800f38:	68 fc 25 80 00       	push   $0x8025fc
  800f3d:	6a 5c                	push   $0x5c
  800f3f:	68 b0 26 80 00       	push   $0x8026b0
  800f44:	e8 8f 0d 00 00       	call   801cd8 <_panic>
		return 0;
	} else {
		// map page to new environment
		// kernel page is already in new environment
		uint32_t i;
		for (i = 0; i != UTOP; i += PGSIZE) 
  800f49:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  800f4f:	81 fb 00 00 c0 ee    	cmp    $0xeec00000,%ebx
  800f55:	0f 85 0d ff ff ff    	jne    800e68 <fork+0x6a>
		if ((uvpd[PDX(i)] & PTE_P) && (uvpt[i / PGSIZE] & PTE_P) && (uvpt[i / PGSIZE] & PTE_U)) {
			duppage(childpid, i / PGSIZE);
		}

		// allocate exception stack
		r = sys_page_alloc(childpid, (void *)(UXSTACKTOP - PGSIZE), PTE_U | PTE_W | PTE_P);
  800f5b:	83 ec 04             	sub    $0x4,%esp
  800f5e:	6a 07                	push   $0x7
  800f60:	68 00 f0 bf ee       	push   $0xeebff000
  800f65:	ff 75 e4             	pushl  -0x1c(%ebp)
  800f68:	e8 7f fc ff ff       	call   800bec <sys_page_alloc>
		if (r < 0) panic("fork, sys_page_alloc user exception stack error : %e\n", r);
  800f6d:	83 c4 10             	add    $0x10,%esp
  800f70:	85 c0                	test   %eax,%eax
  800f72:	79 15                	jns    800f89 <fork+0x18b>
  800f74:	50                   	push   %eax
  800f75:	68 20 26 80 00       	push   $0x802620
  800f7a:	68 90 00 00 00       	push   $0x90
  800f7f:	68 b0 26 80 00       	push   $0x8026b0
  800f84:	e8 4f 0d 00 00       	call   801cd8 <_panic>

		// set user environment user page fault handler 
		extern void _pgfault_upcall(void);
		r = sys_env_set_pgfault_upcall(childpid, _pgfault_upcall);
  800f89:	83 ec 08             	sub    $0x8,%esp
  800f8c:	68 8c 1d 80 00       	push   $0x801d8c
  800f91:	ff 75 e4             	pushl  -0x1c(%ebp)
  800f94:	e8 06 fd ff ff       	call   800c9f <sys_env_set_pgfault_upcall>
		if (r < 0) panic("fork, set pgfault upcall fail : %e\n", r);
  800f99:	83 c4 10             	add    $0x10,%esp
  800f9c:	85 c0                	test   %eax,%eax
  800f9e:	79 15                	jns    800fb5 <fork+0x1b7>
  800fa0:	50                   	push   %eax
  800fa1:	68 58 26 80 00       	push   $0x802658
  800fa6:	68 95 00 00 00       	push   $0x95
  800fab:	68 b0 26 80 00       	push   $0x8026b0
  800fb0:	e8 23 0d 00 00       	call   801cd8 <_panic>
		r = sys_set_priority(childpid, num);
		if (r < 0) panic("fork, set priority error\n");
		*/

		// mark the child as runnable and return
		r = sys_env_set_status(childpid, ENV_RUNNABLE);
  800fb5:	83 ec 08             	sub    $0x8,%esp
  800fb8:	6a 02                	push   $0x2
  800fba:	ff 75 e4             	pushl  -0x1c(%ebp)
  800fbd:	e8 97 fc ff ff       	call   800c59 <sys_env_set_status>
		if (r < 0) panic("fork, set child process to ENV_RUNNABLE error : %e\n", r);
  800fc2:	83 c4 10             	add    $0x10,%esp
  800fc5:	85 c0                	test   %eax,%eax
  800fc7:	79 15                	jns    800fde <fork+0x1e0>
  800fc9:	50                   	push   %eax
  800fca:	68 7c 26 80 00       	push   $0x80267c
  800fcf:	68 a0 00 00 00       	push   $0xa0
  800fd4:	68 b0 26 80 00       	push   $0x8026b0
  800fd9:	e8 fa 0c 00 00       	call   801cd8 <_panic>
		// cprintf("fork father ok!")
		return childpid;
	}

	panic("fork not implemented");
}
  800fde:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800fe1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800fe4:	5b                   	pop    %ebx
  800fe5:	5e                   	pop    %esi
  800fe6:	5f                   	pop    %edi
  800fe7:	c9                   	leave  
  800fe8:	c3                   	ret    

00800fe9 <sfork>:

// Challenge!
int
sfork(void)
{
  800fe9:	55                   	push   %ebp
  800fea:	89 e5                	mov    %esp,%ebp
  800fec:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  800fef:	68 d8 26 80 00       	push   $0x8026d8
  800ff4:	68 ad 00 00 00       	push   $0xad
  800ff9:	68 b0 26 80 00       	push   $0x8026b0
  800ffe:	e8 d5 0c 00 00       	call   801cd8 <_panic>
	...

00801004 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801004:	55                   	push   %ebp
  801005:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801007:	8b 45 08             	mov    0x8(%ebp),%eax
  80100a:	05 00 00 00 30       	add    $0x30000000,%eax
  80100f:	c1 e8 0c             	shr    $0xc,%eax
}
  801012:	c9                   	leave  
  801013:	c3                   	ret    

00801014 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801014:	55                   	push   %ebp
  801015:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  801017:	ff 75 08             	pushl  0x8(%ebp)
  80101a:	e8 e5 ff ff ff       	call   801004 <fd2num>
  80101f:	83 c4 04             	add    $0x4,%esp
  801022:	05 20 00 0d 00       	add    $0xd0020,%eax
  801027:	c1 e0 0c             	shl    $0xc,%eax
}
  80102a:	c9                   	leave  
  80102b:	c3                   	ret    

0080102c <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80102c:	55                   	push   %ebp
  80102d:	89 e5                	mov    %esp,%ebp
  80102f:	53                   	push   %ebx
  801030:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801033:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  801038:	a8 01                	test   $0x1,%al
  80103a:	74 34                	je     801070 <fd_alloc+0x44>
  80103c:	a1 00 00 74 ef       	mov    0xef740000,%eax
  801041:	a8 01                	test   $0x1,%al
  801043:	74 32                	je     801077 <fd_alloc+0x4b>
  801045:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
  80104a:	89 c1                	mov    %eax,%ecx
  80104c:	89 c2                	mov    %eax,%edx
  80104e:	c1 ea 16             	shr    $0x16,%edx
  801051:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801058:	f6 c2 01             	test   $0x1,%dl
  80105b:	74 1f                	je     80107c <fd_alloc+0x50>
  80105d:	89 c2                	mov    %eax,%edx
  80105f:	c1 ea 0c             	shr    $0xc,%edx
  801062:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801069:	f6 c2 01             	test   $0x1,%dl
  80106c:	75 17                	jne    801085 <fd_alloc+0x59>
  80106e:	eb 0c                	jmp    80107c <fd_alloc+0x50>
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  801070:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
  801075:	eb 05                	jmp    80107c <fd_alloc+0x50>
  801077:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
  80107c:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  80107e:	b8 00 00 00 00       	mov    $0x0,%eax
  801083:	eb 17                	jmp    80109c <fd_alloc+0x70>
  801085:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  80108a:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80108f:	75 b9                	jne    80104a <fd_alloc+0x1e>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801091:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  801097:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  80109c:	5b                   	pop    %ebx
  80109d:	c9                   	leave  
  80109e:	c3                   	ret    

0080109f <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80109f:	55                   	push   %ebp
  8010a0:	89 e5                	mov    %esp,%ebp
  8010a2:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8010a5:	83 f8 1f             	cmp    $0x1f,%eax
  8010a8:	77 36                	ja     8010e0 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8010aa:	05 00 00 0d 00       	add    $0xd0000,%eax
  8010af:	c1 e0 0c             	shl    $0xc,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8010b2:	89 c2                	mov    %eax,%edx
  8010b4:	c1 ea 16             	shr    $0x16,%edx
  8010b7:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8010be:	f6 c2 01             	test   $0x1,%dl
  8010c1:	74 24                	je     8010e7 <fd_lookup+0x48>
  8010c3:	89 c2                	mov    %eax,%edx
  8010c5:	c1 ea 0c             	shr    $0xc,%edx
  8010c8:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8010cf:	f6 c2 01             	test   $0x1,%dl
  8010d2:	74 1a                	je     8010ee <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8010d4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8010d7:	89 02                	mov    %eax,(%edx)
	return 0;
  8010d9:	b8 00 00 00 00       	mov    $0x0,%eax
  8010de:	eb 13                	jmp    8010f3 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8010e0:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8010e5:	eb 0c                	jmp    8010f3 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8010e7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8010ec:	eb 05                	jmp    8010f3 <fd_lookup+0x54>
  8010ee:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8010f3:	c9                   	leave  
  8010f4:	c3                   	ret    

008010f5 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8010f5:	55                   	push   %ebp
  8010f6:	89 e5                	mov    %esp,%ebp
  8010f8:	53                   	push   %ebx
  8010f9:	83 ec 04             	sub    $0x4,%esp
  8010fc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8010ff:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  801102:	39 0d 04 30 80 00    	cmp    %ecx,0x803004
  801108:	74 0d                	je     801117 <dev_lookup+0x22>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80110a:	b8 00 00 00 00       	mov    $0x0,%eax
  80110f:	eb 14                	jmp    801125 <dev_lookup+0x30>
		if (devtab[i]->dev_id == dev_id) {
  801111:	39 0a                	cmp    %ecx,(%edx)
  801113:	75 10                	jne    801125 <dev_lookup+0x30>
  801115:	eb 05                	jmp    80111c <dev_lookup+0x27>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801117:	ba 04 30 80 00       	mov    $0x803004,%edx
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
  80111c:	89 13                	mov    %edx,(%ebx)
			return 0;
  80111e:	b8 00 00 00 00       	mov    $0x0,%eax
  801123:	eb 31                	jmp    801156 <dev_lookup+0x61>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801125:	40                   	inc    %eax
  801126:	8b 14 85 6c 27 80 00 	mov    0x80276c(,%eax,4),%edx
  80112d:	85 d2                	test   %edx,%edx
  80112f:	75 e0                	jne    801111 <dev_lookup+0x1c>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801131:	a1 04 40 80 00       	mov    0x804004,%eax
  801136:	8b 40 48             	mov    0x48(%eax),%eax
  801139:	83 ec 04             	sub    $0x4,%esp
  80113c:	51                   	push   %ecx
  80113d:	50                   	push   %eax
  80113e:	68 f0 26 80 00       	push   $0x8026f0
  801143:	e8 6c f0 ff ff       	call   8001b4 <cprintf>
	*dev = 0;
  801148:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  80114e:	83 c4 10             	add    $0x10,%esp
  801151:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801156:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801159:	c9                   	leave  
  80115a:	c3                   	ret    

0080115b <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80115b:	55                   	push   %ebp
  80115c:	89 e5                	mov    %esp,%ebp
  80115e:	56                   	push   %esi
  80115f:	53                   	push   %ebx
  801160:	83 ec 20             	sub    $0x20,%esp
  801163:	8b 75 08             	mov    0x8(%ebp),%esi
  801166:	8a 45 0c             	mov    0xc(%ebp),%al
  801169:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80116c:	56                   	push   %esi
  80116d:	e8 92 fe ff ff       	call   801004 <fd2num>
  801172:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801175:	89 14 24             	mov    %edx,(%esp)
  801178:	50                   	push   %eax
  801179:	e8 21 ff ff ff       	call   80109f <fd_lookup>
  80117e:	89 c3                	mov    %eax,%ebx
  801180:	83 c4 08             	add    $0x8,%esp
  801183:	85 c0                	test   %eax,%eax
  801185:	78 05                	js     80118c <fd_close+0x31>
	    || fd != fd2)
  801187:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80118a:	74 0d                	je     801199 <fd_close+0x3e>
		return (must_exist ? r : 0);
  80118c:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  801190:	75 48                	jne    8011da <fd_close+0x7f>
  801192:	bb 00 00 00 00       	mov    $0x0,%ebx
  801197:	eb 41                	jmp    8011da <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801199:	83 ec 08             	sub    $0x8,%esp
  80119c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80119f:	50                   	push   %eax
  8011a0:	ff 36                	pushl  (%esi)
  8011a2:	e8 4e ff ff ff       	call   8010f5 <dev_lookup>
  8011a7:	89 c3                	mov    %eax,%ebx
  8011a9:	83 c4 10             	add    $0x10,%esp
  8011ac:	85 c0                	test   %eax,%eax
  8011ae:	78 1c                	js     8011cc <fd_close+0x71>
		if (dev->dev_close)
  8011b0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011b3:	8b 40 10             	mov    0x10(%eax),%eax
  8011b6:	85 c0                	test   %eax,%eax
  8011b8:	74 0d                	je     8011c7 <fd_close+0x6c>
			r = (*dev->dev_close)(fd);
  8011ba:	83 ec 0c             	sub    $0xc,%esp
  8011bd:	56                   	push   %esi
  8011be:	ff d0                	call   *%eax
  8011c0:	89 c3                	mov    %eax,%ebx
  8011c2:	83 c4 10             	add    $0x10,%esp
  8011c5:	eb 05                	jmp    8011cc <fd_close+0x71>
		else
			r = 0;
  8011c7:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8011cc:	83 ec 08             	sub    $0x8,%esp
  8011cf:	56                   	push   %esi
  8011d0:	6a 00                	push   $0x0
  8011d2:	e8 5f fa ff ff       	call   800c36 <sys_page_unmap>
	return r;
  8011d7:	83 c4 10             	add    $0x10,%esp
}
  8011da:	89 d8                	mov    %ebx,%eax
  8011dc:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8011df:	5b                   	pop    %ebx
  8011e0:	5e                   	pop    %esi
  8011e1:	c9                   	leave  
  8011e2:	c3                   	ret    

008011e3 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8011e3:	55                   	push   %ebp
  8011e4:	89 e5                	mov    %esp,%ebp
  8011e6:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8011e9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011ec:	50                   	push   %eax
  8011ed:	ff 75 08             	pushl  0x8(%ebp)
  8011f0:	e8 aa fe ff ff       	call   80109f <fd_lookup>
  8011f5:	83 c4 08             	add    $0x8,%esp
  8011f8:	85 c0                	test   %eax,%eax
  8011fa:	78 10                	js     80120c <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  8011fc:	83 ec 08             	sub    $0x8,%esp
  8011ff:	6a 01                	push   $0x1
  801201:	ff 75 f4             	pushl  -0xc(%ebp)
  801204:	e8 52 ff ff ff       	call   80115b <fd_close>
  801209:	83 c4 10             	add    $0x10,%esp
}
  80120c:	c9                   	leave  
  80120d:	c3                   	ret    

0080120e <close_all>:

void
close_all(void)
{
  80120e:	55                   	push   %ebp
  80120f:	89 e5                	mov    %esp,%ebp
  801211:	53                   	push   %ebx
  801212:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801215:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80121a:	83 ec 0c             	sub    $0xc,%esp
  80121d:	53                   	push   %ebx
  80121e:	e8 c0 ff ff ff       	call   8011e3 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801223:	43                   	inc    %ebx
  801224:	83 c4 10             	add    $0x10,%esp
  801227:	83 fb 20             	cmp    $0x20,%ebx
  80122a:	75 ee                	jne    80121a <close_all+0xc>
		close(i);
}
  80122c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80122f:	c9                   	leave  
  801230:	c3                   	ret    

00801231 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801231:	55                   	push   %ebp
  801232:	89 e5                	mov    %esp,%ebp
  801234:	57                   	push   %edi
  801235:	56                   	push   %esi
  801236:	53                   	push   %ebx
  801237:	83 ec 2c             	sub    $0x2c,%esp
  80123a:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80123d:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801240:	50                   	push   %eax
  801241:	ff 75 08             	pushl  0x8(%ebp)
  801244:	e8 56 fe ff ff       	call   80109f <fd_lookup>
  801249:	89 c3                	mov    %eax,%ebx
  80124b:	83 c4 08             	add    $0x8,%esp
  80124e:	85 c0                	test   %eax,%eax
  801250:	0f 88 c0 00 00 00    	js     801316 <dup+0xe5>
		return r;
	close(newfdnum);
  801256:	83 ec 0c             	sub    $0xc,%esp
  801259:	57                   	push   %edi
  80125a:	e8 84 ff ff ff       	call   8011e3 <close>

	newfd = INDEX2FD(newfdnum);
  80125f:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  801265:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  801268:	83 c4 04             	add    $0x4,%esp
  80126b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80126e:	e8 a1 fd ff ff       	call   801014 <fd2data>
  801273:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801275:	89 34 24             	mov    %esi,(%esp)
  801278:	e8 97 fd ff ff       	call   801014 <fd2data>
  80127d:	83 c4 10             	add    $0x10,%esp
  801280:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801283:	89 d8                	mov    %ebx,%eax
  801285:	c1 e8 16             	shr    $0x16,%eax
  801288:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80128f:	a8 01                	test   $0x1,%al
  801291:	74 37                	je     8012ca <dup+0x99>
  801293:	89 d8                	mov    %ebx,%eax
  801295:	c1 e8 0c             	shr    $0xc,%eax
  801298:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80129f:	f6 c2 01             	test   $0x1,%dl
  8012a2:	74 26                	je     8012ca <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8012a4:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8012ab:	83 ec 0c             	sub    $0xc,%esp
  8012ae:	25 07 0e 00 00       	and    $0xe07,%eax
  8012b3:	50                   	push   %eax
  8012b4:	ff 75 d4             	pushl  -0x2c(%ebp)
  8012b7:	6a 00                	push   $0x0
  8012b9:	53                   	push   %ebx
  8012ba:	6a 00                	push   $0x0
  8012bc:	e8 4f f9 ff ff       	call   800c10 <sys_page_map>
  8012c1:	89 c3                	mov    %eax,%ebx
  8012c3:	83 c4 20             	add    $0x20,%esp
  8012c6:	85 c0                	test   %eax,%eax
  8012c8:	78 2d                	js     8012f7 <dup+0xc6>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8012ca:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8012cd:	89 c2                	mov    %eax,%edx
  8012cf:	c1 ea 0c             	shr    $0xc,%edx
  8012d2:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8012d9:	83 ec 0c             	sub    $0xc,%esp
  8012dc:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  8012e2:	52                   	push   %edx
  8012e3:	56                   	push   %esi
  8012e4:	6a 00                	push   $0x0
  8012e6:	50                   	push   %eax
  8012e7:	6a 00                	push   $0x0
  8012e9:	e8 22 f9 ff ff       	call   800c10 <sys_page_map>
  8012ee:	89 c3                	mov    %eax,%ebx
  8012f0:	83 c4 20             	add    $0x20,%esp
  8012f3:	85 c0                	test   %eax,%eax
  8012f5:	79 1d                	jns    801314 <dup+0xe3>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8012f7:	83 ec 08             	sub    $0x8,%esp
  8012fa:	56                   	push   %esi
  8012fb:	6a 00                	push   $0x0
  8012fd:	e8 34 f9 ff ff       	call   800c36 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801302:	83 c4 08             	add    $0x8,%esp
  801305:	ff 75 d4             	pushl  -0x2c(%ebp)
  801308:	6a 00                	push   $0x0
  80130a:	e8 27 f9 ff ff       	call   800c36 <sys_page_unmap>
	return r;
  80130f:	83 c4 10             	add    $0x10,%esp
  801312:	eb 02                	jmp    801316 <dup+0xe5>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  801314:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  801316:	89 d8                	mov    %ebx,%eax
  801318:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80131b:	5b                   	pop    %ebx
  80131c:	5e                   	pop    %esi
  80131d:	5f                   	pop    %edi
  80131e:	c9                   	leave  
  80131f:	c3                   	ret    

00801320 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801320:	55                   	push   %ebp
  801321:	89 e5                	mov    %esp,%ebp
  801323:	53                   	push   %ebx
  801324:	83 ec 14             	sub    $0x14,%esp
  801327:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80132a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80132d:	50                   	push   %eax
  80132e:	53                   	push   %ebx
  80132f:	e8 6b fd ff ff       	call   80109f <fd_lookup>
  801334:	83 c4 08             	add    $0x8,%esp
  801337:	85 c0                	test   %eax,%eax
  801339:	78 67                	js     8013a2 <read+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80133b:	83 ec 08             	sub    $0x8,%esp
  80133e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801341:	50                   	push   %eax
  801342:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801345:	ff 30                	pushl  (%eax)
  801347:	e8 a9 fd ff ff       	call   8010f5 <dev_lookup>
  80134c:	83 c4 10             	add    $0x10,%esp
  80134f:	85 c0                	test   %eax,%eax
  801351:	78 4f                	js     8013a2 <read+0x82>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801353:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801356:	8b 50 08             	mov    0x8(%eax),%edx
  801359:	83 e2 03             	and    $0x3,%edx
  80135c:	83 fa 01             	cmp    $0x1,%edx
  80135f:	75 21                	jne    801382 <read+0x62>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801361:	a1 04 40 80 00       	mov    0x804004,%eax
  801366:	8b 40 48             	mov    0x48(%eax),%eax
  801369:	83 ec 04             	sub    $0x4,%esp
  80136c:	53                   	push   %ebx
  80136d:	50                   	push   %eax
  80136e:	68 31 27 80 00       	push   $0x802731
  801373:	e8 3c ee ff ff       	call   8001b4 <cprintf>
		return -E_INVAL;
  801378:	83 c4 10             	add    $0x10,%esp
  80137b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801380:	eb 20                	jmp    8013a2 <read+0x82>
	}
	if (!dev->dev_read)
  801382:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801385:	8b 52 08             	mov    0x8(%edx),%edx
  801388:	85 d2                	test   %edx,%edx
  80138a:	74 11                	je     80139d <read+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80138c:	83 ec 04             	sub    $0x4,%esp
  80138f:	ff 75 10             	pushl  0x10(%ebp)
  801392:	ff 75 0c             	pushl  0xc(%ebp)
  801395:	50                   	push   %eax
  801396:	ff d2                	call   *%edx
  801398:	83 c4 10             	add    $0x10,%esp
  80139b:	eb 05                	jmp    8013a2 <read+0x82>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80139d:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  8013a2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013a5:	c9                   	leave  
  8013a6:	c3                   	ret    

008013a7 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8013a7:	55                   	push   %ebp
  8013a8:	89 e5                	mov    %esp,%ebp
  8013aa:	57                   	push   %edi
  8013ab:	56                   	push   %esi
  8013ac:	53                   	push   %ebx
  8013ad:	83 ec 0c             	sub    $0xc,%esp
  8013b0:	8b 7d 08             	mov    0x8(%ebp),%edi
  8013b3:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8013b6:	85 f6                	test   %esi,%esi
  8013b8:	74 31                	je     8013eb <readn+0x44>
  8013ba:	b8 00 00 00 00       	mov    $0x0,%eax
  8013bf:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = read(fdnum, (char*)buf + tot, n - tot);
  8013c4:	83 ec 04             	sub    $0x4,%esp
  8013c7:	89 f2                	mov    %esi,%edx
  8013c9:	29 c2                	sub    %eax,%edx
  8013cb:	52                   	push   %edx
  8013cc:	03 45 0c             	add    0xc(%ebp),%eax
  8013cf:	50                   	push   %eax
  8013d0:	57                   	push   %edi
  8013d1:	e8 4a ff ff ff       	call   801320 <read>
		if (m < 0)
  8013d6:	83 c4 10             	add    $0x10,%esp
  8013d9:	85 c0                	test   %eax,%eax
  8013db:	78 17                	js     8013f4 <readn+0x4d>
			return m;
		if (m == 0)
  8013dd:	85 c0                	test   %eax,%eax
  8013df:	74 11                	je     8013f2 <readn+0x4b>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8013e1:	01 c3                	add    %eax,%ebx
  8013e3:	89 d8                	mov    %ebx,%eax
  8013e5:	39 f3                	cmp    %esi,%ebx
  8013e7:	72 db                	jb     8013c4 <readn+0x1d>
  8013e9:	eb 09                	jmp    8013f4 <readn+0x4d>
  8013eb:	b8 00 00 00 00       	mov    $0x0,%eax
  8013f0:	eb 02                	jmp    8013f4 <readn+0x4d>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  8013f2:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  8013f4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8013f7:	5b                   	pop    %ebx
  8013f8:	5e                   	pop    %esi
  8013f9:	5f                   	pop    %edi
  8013fa:	c9                   	leave  
  8013fb:	c3                   	ret    

008013fc <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8013fc:	55                   	push   %ebp
  8013fd:	89 e5                	mov    %esp,%ebp
  8013ff:	53                   	push   %ebx
  801400:	83 ec 14             	sub    $0x14,%esp
  801403:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801406:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801409:	50                   	push   %eax
  80140a:	53                   	push   %ebx
  80140b:	e8 8f fc ff ff       	call   80109f <fd_lookup>
  801410:	83 c4 08             	add    $0x8,%esp
  801413:	85 c0                	test   %eax,%eax
  801415:	78 62                	js     801479 <write+0x7d>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801417:	83 ec 08             	sub    $0x8,%esp
  80141a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80141d:	50                   	push   %eax
  80141e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801421:	ff 30                	pushl  (%eax)
  801423:	e8 cd fc ff ff       	call   8010f5 <dev_lookup>
  801428:	83 c4 10             	add    $0x10,%esp
  80142b:	85 c0                	test   %eax,%eax
  80142d:	78 4a                	js     801479 <write+0x7d>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80142f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801432:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801436:	75 21                	jne    801459 <write+0x5d>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801438:	a1 04 40 80 00       	mov    0x804004,%eax
  80143d:	8b 40 48             	mov    0x48(%eax),%eax
  801440:	83 ec 04             	sub    $0x4,%esp
  801443:	53                   	push   %ebx
  801444:	50                   	push   %eax
  801445:	68 4d 27 80 00       	push   $0x80274d
  80144a:	e8 65 ed ff ff       	call   8001b4 <cprintf>
		return -E_INVAL;
  80144f:	83 c4 10             	add    $0x10,%esp
  801452:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801457:	eb 20                	jmp    801479 <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801459:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80145c:	8b 52 0c             	mov    0xc(%edx),%edx
  80145f:	85 d2                	test   %edx,%edx
  801461:	74 11                	je     801474 <write+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801463:	83 ec 04             	sub    $0x4,%esp
  801466:	ff 75 10             	pushl  0x10(%ebp)
  801469:	ff 75 0c             	pushl  0xc(%ebp)
  80146c:	50                   	push   %eax
  80146d:	ff d2                	call   *%edx
  80146f:	83 c4 10             	add    $0x10,%esp
  801472:	eb 05                	jmp    801479 <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801474:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  801479:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80147c:	c9                   	leave  
  80147d:	c3                   	ret    

0080147e <seek>:

int
seek(int fdnum, off_t offset)
{
  80147e:	55                   	push   %ebp
  80147f:	89 e5                	mov    %esp,%ebp
  801481:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801484:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801487:	50                   	push   %eax
  801488:	ff 75 08             	pushl  0x8(%ebp)
  80148b:	e8 0f fc ff ff       	call   80109f <fd_lookup>
  801490:	83 c4 08             	add    $0x8,%esp
  801493:	85 c0                	test   %eax,%eax
  801495:	78 0e                	js     8014a5 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801497:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80149a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80149d:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8014a0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8014a5:	c9                   	leave  
  8014a6:	c3                   	ret    

008014a7 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8014a7:	55                   	push   %ebp
  8014a8:	89 e5                	mov    %esp,%ebp
  8014aa:	53                   	push   %ebx
  8014ab:	83 ec 14             	sub    $0x14,%esp
  8014ae:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8014b1:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014b4:	50                   	push   %eax
  8014b5:	53                   	push   %ebx
  8014b6:	e8 e4 fb ff ff       	call   80109f <fd_lookup>
  8014bb:	83 c4 08             	add    $0x8,%esp
  8014be:	85 c0                	test   %eax,%eax
  8014c0:	78 5f                	js     801521 <ftruncate+0x7a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014c2:	83 ec 08             	sub    $0x8,%esp
  8014c5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014c8:	50                   	push   %eax
  8014c9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014cc:	ff 30                	pushl  (%eax)
  8014ce:	e8 22 fc ff ff       	call   8010f5 <dev_lookup>
  8014d3:	83 c4 10             	add    $0x10,%esp
  8014d6:	85 c0                	test   %eax,%eax
  8014d8:	78 47                	js     801521 <ftruncate+0x7a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8014da:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014dd:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8014e1:	75 21                	jne    801504 <ftruncate+0x5d>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8014e3:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8014e8:	8b 40 48             	mov    0x48(%eax),%eax
  8014eb:	83 ec 04             	sub    $0x4,%esp
  8014ee:	53                   	push   %ebx
  8014ef:	50                   	push   %eax
  8014f0:	68 10 27 80 00       	push   $0x802710
  8014f5:	e8 ba ec ff ff       	call   8001b4 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8014fa:	83 c4 10             	add    $0x10,%esp
  8014fd:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801502:	eb 1d                	jmp    801521 <ftruncate+0x7a>
	}
	if (!dev->dev_trunc)
  801504:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801507:	8b 52 18             	mov    0x18(%edx),%edx
  80150a:	85 d2                	test   %edx,%edx
  80150c:	74 0e                	je     80151c <ftruncate+0x75>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80150e:	83 ec 08             	sub    $0x8,%esp
  801511:	ff 75 0c             	pushl  0xc(%ebp)
  801514:	50                   	push   %eax
  801515:	ff d2                	call   *%edx
  801517:	83 c4 10             	add    $0x10,%esp
  80151a:	eb 05                	jmp    801521 <ftruncate+0x7a>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80151c:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  801521:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801524:	c9                   	leave  
  801525:	c3                   	ret    

00801526 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801526:	55                   	push   %ebp
  801527:	89 e5                	mov    %esp,%ebp
  801529:	53                   	push   %ebx
  80152a:	83 ec 14             	sub    $0x14,%esp
  80152d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801530:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801533:	50                   	push   %eax
  801534:	ff 75 08             	pushl  0x8(%ebp)
  801537:	e8 63 fb ff ff       	call   80109f <fd_lookup>
  80153c:	83 c4 08             	add    $0x8,%esp
  80153f:	85 c0                	test   %eax,%eax
  801541:	78 52                	js     801595 <fstat+0x6f>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801543:	83 ec 08             	sub    $0x8,%esp
  801546:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801549:	50                   	push   %eax
  80154a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80154d:	ff 30                	pushl  (%eax)
  80154f:	e8 a1 fb ff ff       	call   8010f5 <dev_lookup>
  801554:	83 c4 10             	add    $0x10,%esp
  801557:	85 c0                	test   %eax,%eax
  801559:	78 3a                	js     801595 <fstat+0x6f>
		return r;
	if (!dev->dev_stat)
  80155b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80155e:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801562:	74 2c                	je     801590 <fstat+0x6a>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801564:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801567:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80156e:	00 00 00 
	stat->st_isdir = 0;
  801571:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801578:	00 00 00 
	stat->st_dev = dev;
  80157b:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801581:	83 ec 08             	sub    $0x8,%esp
  801584:	53                   	push   %ebx
  801585:	ff 75 f0             	pushl  -0x10(%ebp)
  801588:	ff 50 14             	call   *0x14(%eax)
  80158b:	83 c4 10             	add    $0x10,%esp
  80158e:	eb 05                	jmp    801595 <fstat+0x6f>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801590:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801595:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801598:	c9                   	leave  
  801599:	c3                   	ret    

0080159a <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80159a:	55                   	push   %ebp
  80159b:	89 e5                	mov    %esp,%ebp
  80159d:	56                   	push   %esi
  80159e:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80159f:	83 ec 08             	sub    $0x8,%esp
  8015a2:	6a 00                	push   $0x0
  8015a4:	ff 75 08             	pushl  0x8(%ebp)
  8015a7:	e8 8b 01 00 00       	call   801737 <open>
  8015ac:	89 c3                	mov    %eax,%ebx
  8015ae:	83 c4 10             	add    $0x10,%esp
  8015b1:	85 c0                	test   %eax,%eax
  8015b3:	78 1b                	js     8015d0 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8015b5:	83 ec 08             	sub    $0x8,%esp
  8015b8:	ff 75 0c             	pushl  0xc(%ebp)
  8015bb:	50                   	push   %eax
  8015bc:	e8 65 ff ff ff       	call   801526 <fstat>
  8015c1:	89 c6                	mov    %eax,%esi
	close(fd);
  8015c3:	89 1c 24             	mov    %ebx,(%esp)
  8015c6:	e8 18 fc ff ff       	call   8011e3 <close>
	return r;
  8015cb:	83 c4 10             	add    $0x10,%esp
  8015ce:	89 f3                	mov    %esi,%ebx
}
  8015d0:	89 d8                	mov    %ebx,%eax
  8015d2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8015d5:	5b                   	pop    %ebx
  8015d6:	5e                   	pop    %esi
  8015d7:	c9                   	leave  
  8015d8:	c3                   	ret    
  8015d9:	00 00                	add    %al,(%eax)
	...

008015dc <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8015dc:	55                   	push   %ebp
  8015dd:	89 e5                	mov    %esp,%ebp
  8015df:	56                   	push   %esi
  8015e0:	53                   	push   %ebx
  8015e1:	89 c3                	mov    %eax,%ebx
  8015e3:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  8015e5:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8015ec:	75 12                	jne    801600 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8015ee:	83 ec 0c             	sub    $0xc,%esp
  8015f1:	6a 01                	push   $0x1
  8015f3:	e8 b9 08 00 00       	call   801eb1 <ipc_find_env>
  8015f8:	a3 00 40 80 00       	mov    %eax,0x804000
  8015fd:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801600:	6a 07                	push   $0x7
  801602:	68 00 50 80 00       	push   $0x805000
  801607:	53                   	push   %ebx
  801608:	ff 35 00 40 80 00    	pushl  0x804000
  80160e:	e8 49 08 00 00       	call   801e5c <ipc_send>
	
	return ipc_recv(NULL, dstva, NULL);
  801613:	83 c4 0c             	add    $0xc,%esp
  801616:	6a 00                	push   $0x0
  801618:	56                   	push   %esi
  801619:	6a 00                	push   $0x0
  80161b:	e8 94 07 00 00       	call   801db4 <ipc_recv>
}
  801620:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801623:	5b                   	pop    %ebx
  801624:	5e                   	pop    %esi
  801625:	c9                   	leave  
  801626:	c3                   	ret    

00801627 <devfile_stat>:
}


static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801627:	55                   	push   %ebp
  801628:	89 e5                	mov    %esp,%ebp
  80162a:	53                   	push   %ebx
  80162b:	83 ec 04             	sub    $0x4,%esp
  80162e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801631:	8b 45 08             	mov    0x8(%ebp),%eax
  801634:	8b 40 0c             	mov    0xc(%eax),%eax
  801637:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0) {
  80163c:	ba 00 00 00 00       	mov    $0x0,%edx
  801641:	b8 05 00 00 00       	mov    $0x5,%eax
  801646:	e8 91 ff ff ff       	call   8015dc <fsipc>
  80164b:	85 c0                	test   %eax,%eax
  80164d:	78 39                	js     801688 <devfile_stat+0x61>
		return r;
	}
	cprintf("OVER\n");
  80164f:	83 ec 0c             	sub    $0xc,%esp
  801652:	68 7c 27 80 00       	push   $0x80277c
  801657:	e8 58 eb ff ff       	call   8001b4 <cprintf>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80165c:	83 c4 08             	add    $0x8,%esp
  80165f:	68 00 50 80 00       	push   $0x805000
  801664:	53                   	push   %ebx
  801665:	e8 00 f1 ff ff       	call   80076a <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  80166a:	a1 80 50 80 00       	mov    0x805080,%eax
  80166f:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801675:	a1 84 50 80 00       	mov    0x805084,%eax
  80167a:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801680:	83 c4 10             	add    $0x10,%esp
  801683:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801688:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80168b:	c9                   	leave  
  80168c:	c3                   	ret    

0080168d <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80168d:	55                   	push   %ebp
  80168e:	89 e5                	mov    %esp,%ebp
  801690:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801693:	8b 45 08             	mov    0x8(%ebp),%eax
  801696:	8b 40 0c             	mov    0xc(%eax),%eax
  801699:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80169e:	ba 00 00 00 00       	mov    $0x0,%edx
  8016a3:	b8 06 00 00 00       	mov    $0x6,%eax
  8016a8:	e8 2f ff ff ff       	call   8015dc <fsipc>
}
  8016ad:	c9                   	leave  
  8016ae:	c3                   	ret    

008016af <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8016af:	55                   	push   %ebp
  8016b0:	89 e5                	mov    %esp,%ebp
  8016b2:	56                   	push   %esi
  8016b3:	53                   	push   %ebx
  8016b4:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8016b7:	8b 45 08             	mov    0x8(%ebp),%eax
  8016ba:	8b 40 0c             	mov    0xc(%eax),%eax
  8016bd:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8016c2:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8016c8:	ba 00 00 00 00       	mov    $0x0,%edx
  8016cd:	b8 03 00 00 00       	mov    $0x3,%eax
  8016d2:	e8 05 ff ff ff       	call   8015dc <fsipc>
  8016d7:	89 c3                	mov    %eax,%ebx
  8016d9:	85 c0                	test   %eax,%eax
  8016db:	78 51                	js     80172e <devfile_read+0x7f>
		return r;
	assert(r <= n);
  8016dd:	39 c6                	cmp    %eax,%esi
  8016df:	73 19                	jae    8016fa <devfile_read+0x4b>
  8016e1:	68 82 27 80 00       	push   $0x802782
  8016e6:	68 89 27 80 00       	push   $0x802789
  8016eb:	68 80 00 00 00       	push   $0x80
  8016f0:	68 9e 27 80 00       	push   $0x80279e
  8016f5:	e8 de 05 00 00       	call   801cd8 <_panic>
	assert(r <= PGSIZE);
  8016fa:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8016ff:	7e 19                	jle    80171a <devfile_read+0x6b>
  801701:	68 a9 27 80 00       	push   $0x8027a9
  801706:	68 89 27 80 00       	push   $0x802789
  80170b:	68 81 00 00 00       	push   $0x81
  801710:	68 9e 27 80 00       	push   $0x80279e
  801715:	e8 be 05 00 00       	call   801cd8 <_panic>
	memmove(buf, &fsipcbuf, r);
  80171a:	83 ec 04             	sub    $0x4,%esp
  80171d:	50                   	push   %eax
  80171e:	68 00 50 80 00       	push   $0x805000
  801723:	ff 75 0c             	pushl  0xc(%ebp)
  801726:	e8 00 f2 ff ff       	call   80092b <memmove>
	return r;
  80172b:	83 c4 10             	add    $0x10,%esp
}
  80172e:	89 d8                	mov    %ebx,%eax
  801730:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801733:	5b                   	pop    %ebx
  801734:	5e                   	pop    %esi
  801735:	c9                   	leave  
  801736:	c3                   	ret    

00801737 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801737:	55                   	push   %ebp
  801738:	89 e5                	mov    %esp,%ebp
  80173a:	56                   	push   %esi
  80173b:	53                   	push   %ebx
  80173c:	83 ec 1c             	sub    $0x1c,%esp
  80173f:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801742:	56                   	push   %esi
  801743:	e8 d0 ef ff ff       	call   800718 <strlen>
  801748:	83 c4 10             	add    $0x10,%esp
  80174b:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801750:	7f 72                	jg     8017c4 <open+0x8d>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801752:	83 ec 0c             	sub    $0xc,%esp
  801755:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801758:	50                   	push   %eax
  801759:	e8 ce f8 ff ff       	call   80102c <fd_alloc>
  80175e:	89 c3                	mov    %eax,%ebx
  801760:	83 c4 10             	add    $0x10,%esp
  801763:	85 c0                	test   %eax,%eax
  801765:	78 62                	js     8017c9 <open+0x92>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801767:	83 ec 08             	sub    $0x8,%esp
  80176a:	56                   	push   %esi
  80176b:	68 00 50 80 00       	push   $0x805000
  801770:	e8 f5 ef ff ff       	call   80076a <strcpy>
	fsipcbuf.open.req_omode = mode;
  801775:	8b 45 0c             	mov    0xc(%ebp),%eax
  801778:	a3 00 54 80 00       	mov    %eax,0x805400



	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  80177d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801780:	b8 01 00 00 00       	mov    $0x1,%eax
  801785:	e8 52 fe ff ff       	call   8015dc <fsipc>
  80178a:	89 c3                	mov    %eax,%ebx
  80178c:	83 c4 10             	add    $0x10,%esp
  80178f:	85 c0                	test   %eax,%eax
  801791:	79 12                	jns    8017a5 <open+0x6e>
		fd_close(fd, 0);
  801793:	83 ec 08             	sub    $0x8,%esp
  801796:	6a 00                	push   $0x0
  801798:	ff 75 f4             	pushl  -0xc(%ebp)
  80179b:	e8 bb f9 ff ff       	call   80115b <fd_close>
		return r;
  8017a0:	83 c4 10             	add    $0x10,%esp
  8017a3:	eb 24                	jmp    8017c9 <open+0x92>
	}


	cprintf("OPEN\n");
  8017a5:	83 ec 0c             	sub    $0xc,%esp
  8017a8:	68 b5 27 80 00       	push   $0x8027b5
  8017ad:	e8 02 ea ff ff       	call   8001b4 <cprintf>

	return fd2num(fd);
  8017b2:	83 c4 04             	add    $0x4,%esp
  8017b5:	ff 75 f4             	pushl  -0xc(%ebp)
  8017b8:	e8 47 f8 ff ff       	call   801004 <fd2num>
  8017bd:	89 c3                	mov    %eax,%ebx
  8017bf:	83 c4 10             	add    $0x10,%esp
  8017c2:	eb 05                	jmp    8017c9 <open+0x92>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8017c4:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx


	cprintf("OPEN\n");

	return fd2num(fd);
}
  8017c9:	89 d8                	mov    %ebx,%eax
  8017cb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017ce:	5b                   	pop    %ebx
  8017cf:	5e                   	pop    %esi
  8017d0:	c9                   	leave  
  8017d1:	c3                   	ret    
	...

008017d4 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8017d4:	55                   	push   %ebp
  8017d5:	89 e5                	mov    %esp,%ebp
  8017d7:	56                   	push   %esi
  8017d8:	53                   	push   %ebx
  8017d9:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8017dc:	83 ec 0c             	sub    $0xc,%esp
  8017df:	ff 75 08             	pushl  0x8(%ebp)
  8017e2:	e8 2d f8 ff ff       	call   801014 <fd2data>
  8017e7:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  8017e9:	83 c4 08             	add    $0x8,%esp
  8017ec:	68 bb 27 80 00       	push   $0x8027bb
  8017f1:	56                   	push   %esi
  8017f2:	e8 73 ef ff ff       	call   80076a <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8017f7:	8b 43 04             	mov    0x4(%ebx),%eax
  8017fa:	2b 03                	sub    (%ebx),%eax
  8017fc:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  801802:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  801809:	00 00 00 
	stat->st_dev = &devpipe;
  80180c:	c7 86 88 00 00 00 20 	movl   $0x803020,0x88(%esi)
  801813:	30 80 00 
	return 0;
}
  801816:	b8 00 00 00 00       	mov    $0x0,%eax
  80181b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80181e:	5b                   	pop    %ebx
  80181f:	5e                   	pop    %esi
  801820:	c9                   	leave  
  801821:	c3                   	ret    

00801822 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801822:	55                   	push   %ebp
  801823:	89 e5                	mov    %esp,%ebp
  801825:	53                   	push   %ebx
  801826:	83 ec 0c             	sub    $0xc,%esp
  801829:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  80182c:	53                   	push   %ebx
  80182d:	6a 00                	push   $0x0
  80182f:	e8 02 f4 ff ff       	call   800c36 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801834:	89 1c 24             	mov    %ebx,(%esp)
  801837:	e8 d8 f7 ff ff       	call   801014 <fd2data>
  80183c:	83 c4 08             	add    $0x8,%esp
  80183f:	50                   	push   %eax
  801840:	6a 00                	push   $0x0
  801842:	e8 ef f3 ff ff       	call   800c36 <sys_page_unmap>
}
  801847:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80184a:	c9                   	leave  
  80184b:	c3                   	ret    

0080184c <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  80184c:	55                   	push   %ebp
  80184d:	89 e5                	mov    %esp,%ebp
  80184f:	57                   	push   %edi
  801850:	56                   	push   %esi
  801851:	53                   	push   %ebx
  801852:	83 ec 1c             	sub    $0x1c,%esp
  801855:	89 c7                	mov    %eax,%edi
  801857:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  80185a:	a1 04 40 80 00       	mov    0x804004,%eax
  80185f:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801862:	83 ec 0c             	sub    $0xc,%esp
  801865:	57                   	push   %edi
  801866:	e8 a1 06 00 00       	call   801f0c <pageref>
  80186b:	89 c6                	mov    %eax,%esi
  80186d:	83 c4 04             	add    $0x4,%esp
  801870:	ff 75 e4             	pushl  -0x1c(%ebp)
  801873:	e8 94 06 00 00       	call   801f0c <pageref>
  801878:	83 c4 10             	add    $0x10,%esp
  80187b:	39 c6                	cmp    %eax,%esi
  80187d:	0f 94 c0             	sete   %al
  801880:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  801883:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801889:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  80188c:	39 cb                	cmp    %ecx,%ebx
  80188e:	75 08                	jne    801898 <_pipeisclosed+0x4c>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  801890:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801893:	5b                   	pop    %ebx
  801894:	5e                   	pop    %esi
  801895:	5f                   	pop    %edi
  801896:	c9                   	leave  
  801897:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  801898:	83 f8 01             	cmp    $0x1,%eax
  80189b:	75 bd                	jne    80185a <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  80189d:	8b 42 58             	mov    0x58(%edx),%eax
  8018a0:	6a 01                	push   $0x1
  8018a2:	50                   	push   %eax
  8018a3:	53                   	push   %ebx
  8018a4:	68 c2 27 80 00       	push   $0x8027c2
  8018a9:	e8 06 e9 ff ff       	call   8001b4 <cprintf>
  8018ae:	83 c4 10             	add    $0x10,%esp
  8018b1:	eb a7                	jmp    80185a <_pipeisclosed+0xe>

008018b3 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8018b3:	55                   	push   %ebp
  8018b4:	89 e5                	mov    %esp,%ebp
  8018b6:	57                   	push   %edi
  8018b7:	56                   	push   %esi
  8018b8:	53                   	push   %ebx
  8018b9:	83 ec 28             	sub    $0x28,%esp
  8018bc:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  8018bf:	56                   	push   %esi
  8018c0:	e8 4f f7 ff ff       	call   801014 <fd2data>
  8018c5:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8018c7:	83 c4 10             	add    $0x10,%esp
  8018ca:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8018ce:	75 4a                	jne    80191a <devpipe_write+0x67>
  8018d0:	bf 00 00 00 00       	mov    $0x0,%edi
  8018d5:	eb 56                	jmp    80192d <devpipe_write+0x7a>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  8018d7:	89 da                	mov    %ebx,%edx
  8018d9:	89 f0                	mov    %esi,%eax
  8018db:	e8 6c ff ff ff       	call   80184c <_pipeisclosed>
  8018e0:	85 c0                	test   %eax,%eax
  8018e2:	75 4d                	jne    801931 <devpipe_write+0x7e>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  8018e4:	e8 dc f2 ff ff       	call   800bc5 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8018e9:	8b 43 04             	mov    0x4(%ebx),%eax
  8018ec:	8b 13                	mov    (%ebx),%edx
  8018ee:	83 c2 20             	add    $0x20,%edx
  8018f1:	39 d0                	cmp    %edx,%eax
  8018f3:	73 e2                	jae    8018d7 <devpipe_write+0x24>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  8018f5:	89 c2                	mov    %eax,%edx
  8018f7:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  8018fd:	79 05                	jns    801904 <devpipe_write+0x51>
  8018ff:	4a                   	dec    %edx
  801900:	83 ca e0             	or     $0xffffffe0,%edx
  801903:	42                   	inc    %edx
  801904:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801907:	8a 0c 39             	mov    (%ecx,%edi,1),%cl
  80190a:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  80190e:	40                   	inc    %eax
  80190f:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801912:	47                   	inc    %edi
  801913:	39 7d 10             	cmp    %edi,0x10(%ebp)
  801916:	77 07                	ja     80191f <devpipe_write+0x6c>
  801918:	eb 13                	jmp    80192d <devpipe_write+0x7a>
  80191a:	bf 00 00 00 00       	mov    $0x0,%edi
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  80191f:	8b 43 04             	mov    0x4(%ebx),%eax
  801922:	8b 13                	mov    (%ebx),%edx
  801924:	83 c2 20             	add    $0x20,%edx
  801927:	39 d0                	cmp    %edx,%eax
  801929:	73 ac                	jae    8018d7 <devpipe_write+0x24>
  80192b:	eb c8                	jmp    8018f5 <devpipe_write+0x42>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  80192d:	89 f8                	mov    %edi,%eax
  80192f:	eb 05                	jmp    801936 <devpipe_write+0x83>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801931:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801936:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801939:	5b                   	pop    %ebx
  80193a:	5e                   	pop    %esi
  80193b:	5f                   	pop    %edi
  80193c:	c9                   	leave  
  80193d:	c3                   	ret    

0080193e <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  80193e:	55                   	push   %ebp
  80193f:	89 e5                	mov    %esp,%ebp
  801941:	57                   	push   %edi
  801942:	56                   	push   %esi
  801943:	53                   	push   %ebx
  801944:	83 ec 18             	sub    $0x18,%esp
  801947:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  80194a:	57                   	push   %edi
  80194b:	e8 c4 f6 ff ff       	call   801014 <fd2data>
  801950:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801952:	83 c4 10             	add    $0x10,%esp
  801955:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801959:	75 44                	jne    80199f <devpipe_read+0x61>
  80195b:	be 00 00 00 00       	mov    $0x0,%esi
  801960:	eb 4f                	jmp    8019b1 <devpipe_read+0x73>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
				return i;
  801962:	89 f0                	mov    %esi,%eax
  801964:	eb 54                	jmp    8019ba <devpipe_read+0x7c>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801966:	89 da                	mov    %ebx,%edx
  801968:	89 f8                	mov    %edi,%eax
  80196a:	e8 dd fe ff ff       	call   80184c <_pipeisclosed>
  80196f:	85 c0                	test   %eax,%eax
  801971:	75 42                	jne    8019b5 <devpipe_read+0x77>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801973:	e8 4d f2 ff ff       	call   800bc5 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801978:	8b 03                	mov    (%ebx),%eax
  80197a:	3b 43 04             	cmp    0x4(%ebx),%eax
  80197d:	74 e7                	je     801966 <devpipe_read+0x28>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  80197f:	25 1f 00 00 80       	and    $0x8000001f,%eax
  801984:	79 05                	jns    80198b <devpipe_read+0x4d>
  801986:	48                   	dec    %eax
  801987:	83 c8 e0             	or     $0xffffffe0,%eax
  80198a:	40                   	inc    %eax
  80198b:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  80198f:	8b 55 0c             	mov    0xc(%ebp),%edx
  801992:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  801995:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801997:	46                   	inc    %esi
  801998:	39 75 10             	cmp    %esi,0x10(%ebp)
  80199b:	77 07                	ja     8019a4 <devpipe_read+0x66>
  80199d:	eb 12                	jmp    8019b1 <devpipe_read+0x73>
  80199f:	be 00 00 00 00       	mov    $0x0,%esi
		while (p->p_rpos == p->p_wpos) {
  8019a4:	8b 03                	mov    (%ebx),%eax
  8019a6:	3b 43 04             	cmp    0x4(%ebx),%eax
  8019a9:	75 d4                	jne    80197f <devpipe_read+0x41>
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  8019ab:	85 f6                	test   %esi,%esi
  8019ad:	75 b3                	jne    801962 <devpipe_read+0x24>
  8019af:	eb b5                	jmp    801966 <devpipe_read+0x28>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  8019b1:	89 f0                	mov    %esi,%eax
  8019b3:	eb 05                	jmp    8019ba <devpipe_read+0x7c>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8019b5:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  8019ba:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8019bd:	5b                   	pop    %ebx
  8019be:	5e                   	pop    %esi
  8019bf:	5f                   	pop    %edi
  8019c0:	c9                   	leave  
  8019c1:	c3                   	ret    

008019c2 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  8019c2:	55                   	push   %ebp
  8019c3:	89 e5                	mov    %esp,%ebp
  8019c5:	57                   	push   %edi
  8019c6:	56                   	push   %esi
  8019c7:	53                   	push   %ebx
  8019c8:	83 ec 28             	sub    $0x28,%esp
  8019cb:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  8019ce:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8019d1:	50                   	push   %eax
  8019d2:	e8 55 f6 ff ff       	call   80102c <fd_alloc>
  8019d7:	89 c3                	mov    %eax,%ebx
  8019d9:	83 c4 10             	add    $0x10,%esp
  8019dc:	85 c0                	test   %eax,%eax
  8019de:	0f 88 24 01 00 00    	js     801b08 <pipe+0x146>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8019e4:	83 ec 04             	sub    $0x4,%esp
  8019e7:	68 07 04 00 00       	push   $0x407
  8019ec:	ff 75 e4             	pushl  -0x1c(%ebp)
  8019ef:	6a 00                	push   $0x0
  8019f1:	e8 f6 f1 ff ff       	call   800bec <sys_page_alloc>
  8019f6:	89 c3                	mov    %eax,%ebx
  8019f8:	83 c4 10             	add    $0x10,%esp
  8019fb:	85 c0                	test   %eax,%eax
  8019fd:	0f 88 05 01 00 00    	js     801b08 <pipe+0x146>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801a03:	83 ec 0c             	sub    $0xc,%esp
  801a06:	8d 45 e0             	lea    -0x20(%ebp),%eax
  801a09:	50                   	push   %eax
  801a0a:	e8 1d f6 ff ff       	call   80102c <fd_alloc>
  801a0f:	89 c3                	mov    %eax,%ebx
  801a11:	83 c4 10             	add    $0x10,%esp
  801a14:	85 c0                	test   %eax,%eax
  801a16:	0f 88 dc 00 00 00    	js     801af8 <pipe+0x136>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801a1c:	83 ec 04             	sub    $0x4,%esp
  801a1f:	68 07 04 00 00       	push   $0x407
  801a24:	ff 75 e0             	pushl  -0x20(%ebp)
  801a27:	6a 00                	push   $0x0
  801a29:	e8 be f1 ff ff       	call   800bec <sys_page_alloc>
  801a2e:	89 c3                	mov    %eax,%ebx
  801a30:	83 c4 10             	add    $0x10,%esp
  801a33:	85 c0                	test   %eax,%eax
  801a35:	0f 88 bd 00 00 00    	js     801af8 <pipe+0x136>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801a3b:	83 ec 0c             	sub    $0xc,%esp
  801a3e:	ff 75 e4             	pushl  -0x1c(%ebp)
  801a41:	e8 ce f5 ff ff       	call   801014 <fd2data>
  801a46:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801a48:	83 c4 0c             	add    $0xc,%esp
  801a4b:	68 07 04 00 00       	push   $0x407
  801a50:	50                   	push   %eax
  801a51:	6a 00                	push   $0x0
  801a53:	e8 94 f1 ff ff       	call   800bec <sys_page_alloc>
  801a58:	89 c3                	mov    %eax,%ebx
  801a5a:	83 c4 10             	add    $0x10,%esp
  801a5d:	85 c0                	test   %eax,%eax
  801a5f:	0f 88 83 00 00 00    	js     801ae8 <pipe+0x126>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801a65:	83 ec 0c             	sub    $0xc,%esp
  801a68:	ff 75 e0             	pushl  -0x20(%ebp)
  801a6b:	e8 a4 f5 ff ff       	call   801014 <fd2data>
  801a70:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801a77:	50                   	push   %eax
  801a78:	6a 00                	push   $0x0
  801a7a:	56                   	push   %esi
  801a7b:	6a 00                	push   $0x0
  801a7d:	e8 8e f1 ff ff       	call   800c10 <sys_page_map>
  801a82:	89 c3                	mov    %eax,%ebx
  801a84:	83 c4 20             	add    $0x20,%esp
  801a87:	85 c0                	test   %eax,%eax
  801a89:	78 4f                	js     801ada <pipe+0x118>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801a8b:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801a91:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801a94:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801a96:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801a99:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801aa0:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801aa6:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801aa9:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801aab:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801aae:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801ab5:	83 ec 0c             	sub    $0xc,%esp
  801ab8:	ff 75 e4             	pushl  -0x1c(%ebp)
  801abb:	e8 44 f5 ff ff       	call   801004 <fd2num>
  801ac0:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  801ac2:	83 c4 04             	add    $0x4,%esp
  801ac5:	ff 75 e0             	pushl  -0x20(%ebp)
  801ac8:	e8 37 f5 ff ff       	call   801004 <fd2num>
  801acd:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  801ad0:	83 c4 10             	add    $0x10,%esp
  801ad3:	bb 00 00 00 00       	mov    $0x0,%ebx
  801ad8:	eb 2e                	jmp    801b08 <pipe+0x146>

    err3:
	sys_page_unmap(0, va);
  801ada:	83 ec 08             	sub    $0x8,%esp
  801add:	56                   	push   %esi
  801ade:	6a 00                	push   $0x0
  801ae0:	e8 51 f1 ff ff       	call   800c36 <sys_page_unmap>
  801ae5:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801ae8:	83 ec 08             	sub    $0x8,%esp
  801aeb:	ff 75 e0             	pushl  -0x20(%ebp)
  801aee:	6a 00                	push   $0x0
  801af0:	e8 41 f1 ff ff       	call   800c36 <sys_page_unmap>
  801af5:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801af8:	83 ec 08             	sub    $0x8,%esp
  801afb:	ff 75 e4             	pushl  -0x1c(%ebp)
  801afe:	6a 00                	push   $0x0
  801b00:	e8 31 f1 ff ff       	call   800c36 <sys_page_unmap>
  801b05:	83 c4 10             	add    $0x10,%esp
    err:
	return r;
}
  801b08:	89 d8                	mov    %ebx,%eax
  801b0a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b0d:	5b                   	pop    %ebx
  801b0e:	5e                   	pop    %esi
  801b0f:	5f                   	pop    %edi
  801b10:	c9                   	leave  
  801b11:	c3                   	ret    

00801b12 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801b12:	55                   	push   %ebp
  801b13:	89 e5                	mov    %esp,%ebp
  801b15:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801b18:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b1b:	50                   	push   %eax
  801b1c:	ff 75 08             	pushl  0x8(%ebp)
  801b1f:	e8 7b f5 ff ff       	call   80109f <fd_lookup>
  801b24:	83 c4 10             	add    $0x10,%esp
  801b27:	85 c0                	test   %eax,%eax
  801b29:	78 18                	js     801b43 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801b2b:	83 ec 0c             	sub    $0xc,%esp
  801b2e:	ff 75 f4             	pushl  -0xc(%ebp)
  801b31:	e8 de f4 ff ff       	call   801014 <fd2data>
	return _pipeisclosed(fd, p);
  801b36:	89 c2                	mov    %eax,%edx
  801b38:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b3b:	e8 0c fd ff ff       	call   80184c <_pipeisclosed>
  801b40:	83 c4 10             	add    $0x10,%esp
}
  801b43:	c9                   	leave  
  801b44:	c3                   	ret    
  801b45:	00 00                	add    %al,(%eax)
	...

00801b48 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801b48:	55                   	push   %ebp
  801b49:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801b4b:	b8 00 00 00 00       	mov    $0x0,%eax
  801b50:	c9                   	leave  
  801b51:	c3                   	ret    

00801b52 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801b52:	55                   	push   %ebp
  801b53:	89 e5                	mov    %esp,%ebp
  801b55:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801b58:	68 da 27 80 00       	push   $0x8027da
  801b5d:	ff 75 0c             	pushl  0xc(%ebp)
  801b60:	e8 05 ec ff ff       	call   80076a <strcpy>
	return 0;
}
  801b65:	b8 00 00 00 00       	mov    $0x0,%eax
  801b6a:	c9                   	leave  
  801b6b:	c3                   	ret    

00801b6c <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801b6c:	55                   	push   %ebp
  801b6d:	89 e5                	mov    %esp,%ebp
  801b6f:	57                   	push   %edi
  801b70:	56                   	push   %esi
  801b71:	53                   	push   %ebx
  801b72:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801b78:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801b7c:	74 45                	je     801bc3 <devcons_write+0x57>
  801b7e:	b8 00 00 00 00       	mov    $0x0,%eax
  801b83:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801b88:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801b8e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801b91:	29 c3                	sub    %eax,%ebx
		if (m > sizeof(buf) - 1)
  801b93:	83 fb 7f             	cmp    $0x7f,%ebx
  801b96:	76 05                	jbe    801b9d <devcons_write+0x31>
			m = sizeof(buf) - 1;
  801b98:	bb 7f 00 00 00       	mov    $0x7f,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  801b9d:	83 ec 04             	sub    $0x4,%esp
  801ba0:	53                   	push   %ebx
  801ba1:	03 45 0c             	add    0xc(%ebp),%eax
  801ba4:	50                   	push   %eax
  801ba5:	57                   	push   %edi
  801ba6:	e8 80 ed ff ff       	call   80092b <memmove>
		sys_cputs(buf, m);
  801bab:	83 c4 08             	add    $0x8,%esp
  801bae:	53                   	push   %ebx
  801baf:	57                   	push   %edi
  801bb0:	e8 80 ef ff ff       	call   800b35 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801bb5:	01 de                	add    %ebx,%esi
  801bb7:	89 f0                	mov    %esi,%eax
  801bb9:	83 c4 10             	add    $0x10,%esp
  801bbc:	3b 75 10             	cmp    0x10(%ebp),%esi
  801bbf:	72 cd                	jb     801b8e <devcons_write+0x22>
  801bc1:	eb 05                	jmp    801bc8 <devcons_write+0x5c>
  801bc3:	be 00 00 00 00       	mov    $0x0,%esi
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801bc8:	89 f0                	mov    %esi,%eax
  801bca:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801bcd:	5b                   	pop    %ebx
  801bce:	5e                   	pop    %esi
  801bcf:	5f                   	pop    %edi
  801bd0:	c9                   	leave  
  801bd1:	c3                   	ret    

00801bd2 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801bd2:	55                   	push   %ebp
  801bd3:	89 e5                	mov    %esp,%ebp
  801bd5:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  801bd8:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801bdc:	75 07                	jne    801be5 <devcons_read+0x13>
  801bde:	eb 25                	jmp    801c05 <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801be0:	e8 e0 ef ff ff       	call   800bc5 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801be5:	e8 71 ef ff ff       	call   800b5b <sys_cgetc>
  801bea:	85 c0                	test   %eax,%eax
  801bec:	74 f2                	je     801be0 <devcons_read+0xe>
  801bee:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  801bf0:	85 c0                	test   %eax,%eax
  801bf2:	78 1d                	js     801c11 <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801bf4:	83 f8 04             	cmp    $0x4,%eax
  801bf7:	74 13                	je     801c0c <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  801bf9:	8b 45 0c             	mov    0xc(%ebp),%eax
  801bfc:	88 10                	mov    %dl,(%eax)
	return 1;
  801bfe:	b8 01 00 00 00       	mov    $0x1,%eax
  801c03:	eb 0c                	jmp    801c11 <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  801c05:	b8 00 00 00 00       	mov    $0x0,%eax
  801c0a:	eb 05                	jmp    801c11 <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801c0c:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801c11:	c9                   	leave  
  801c12:	c3                   	ret    

00801c13 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801c13:	55                   	push   %ebp
  801c14:	89 e5                	mov    %esp,%ebp
  801c16:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801c19:	8b 45 08             	mov    0x8(%ebp),%eax
  801c1c:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801c1f:	6a 01                	push   $0x1
  801c21:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801c24:	50                   	push   %eax
  801c25:	e8 0b ef ff ff       	call   800b35 <sys_cputs>
  801c2a:	83 c4 10             	add    $0x10,%esp
}
  801c2d:	c9                   	leave  
  801c2e:	c3                   	ret    

00801c2f <getchar>:

int
getchar(void)
{
  801c2f:	55                   	push   %ebp
  801c30:	89 e5                	mov    %esp,%ebp
  801c32:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801c35:	6a 01                	push   $0x1
  801c37:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801c3a:	50                   	push   %eax
  801c3b:	6a 00                	push   $0x0
  801c3d:	e8 de f6 ff ff       	call   801320 <read>
	if (r < 0)
  801c42:	83 c4 10             	add    $0x10,%esp
  801c45:	85 c0                	test   %eax,%eax
  801c47:	78 0f                	js     801c58 <getchar+0x29>
		return r;
	if (r < 1)
  801c49:	85 c0                	test   %eax,%eax
  801c4b:	7e 06                	jle    801c53 <getchar+0x24>
		return -E_EOF;
	return c;
  801c4d:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801c51:	eb 05                	jmp    801c58 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801c53:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801c58:	c9                   	leave  
  801c59:	c3                   	ret    

00801c5a <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801c5a:	55                   	push   %ebp
  801c5b:	89 e5                	mov    %esp,%ebp
  801c5d:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801c60:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c63:	50                   	push   %eax
  801c64:	ff 75 08             	pushl  0x8(%ebp)
  801c67:	e8 33 f4 ff ff       	call   80109f <fd_lookup>
  801c6c:	83 c4 10             	add    $0x10,%esp
  801c6f:	85 c0                	test   %eax,%eax
  801c71:	78 11                	js     801c84 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801c73:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c76:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801c7c:	39 10                	cmp    %edx,(%eax)
  801c7e:	0f 94 c0             	sete   %al
  801c81:	0f b6 c0             	movzbl %al,%eax
}
  801c84:	c9                   	leave  
  801c85:	c3                   	ret    

00801c86 <opencons>:

int
opencons(void)
{
  801c86:	55                   	push   %ebp
  801c87:	89 e5                	mov    %esp,%ebp
  801c89:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801c8c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c8f:	50                   	push   %eax
  801c90:	e8 97 f3 ff ff       	call   80102c <fd_alloc>
  801c95:	83 c4 10             	add    $0x10,%esp
  801c98:	85 c0                	test   %eax,%eax
  801c9a:	78 3a                	js     801cd6 <opencons+0x50>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801c9c:	83 ec 04             	sub    $0x4,%esp
  801c9f:	68 07 04 00 00       	push   $0x407
  801ca4:	ff 75 f4             	pushl  -0xc(%ebp)
  801ca7:	6a 00                	push   $0x0
  801ca9:	e8 3e ef ff ff       	call   800bec <sys_page_alloc>
  801cae:	83 c4 10             	add    $0x10,%esp
  801cb1:	85 c0                	test   %eax,%eax
  801cb3:	78 21                	js     801cd6 <opencons+0x50>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801cb5:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801cbb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cbe:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801cc0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cc3:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801cca:	83 ec 0c             	sub    $0xc,%esp
  801ccd:	50                   	push   %eax
  801cce:	e8 31 f3 ff ff       	call   801004 <fd2num>
  801cd3:	83 c4 10             	add    $0x10,%esp
}
  801cd6:	c9                   	leave  
  801cd7:	c3                   	ret    

00801cd8 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801cd8:	55                   	push   %ebp
  801cd9:	89 e5                	mov    %esp,%ebp
  801cdb:	56                   	push   %esi
  801cdc:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801cdd:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801ce0:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  801ce6:	e8 b6 ee ff ff       	call   800ba1 <sys_getenvid>
  801ceb:	83 ec 0c             	sub    $0xc,%esp
  801cee:	ff 75 0c             	pushl  0xc(%ebp)
  801cf1:	ff 75 08             	pushl  0x8(%ebp)
  801cf4:	53                   	push   %ebx
  801cf5:	50                   	push   %eax
  801cf6:	68 e8 27 80 00       	push   $0x8027e8
  801cfb:	e8 b4 e4 ff ff       	call   8001b4 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801d00:	83 c4 18             	add    $0x18,%esp
  801d03:	56                   	push   %esi
  801d04:	ff 75 10             	pushl  0x10(%ebp)
  801d07:	e8 57 e4 ff ff       	call   800163 <vcprintf>
	cprintf("\n");
  801d0c:	c7 04 24 34 22 80 00 	movl   $0x802234,(%esp)
  801d13:	e8 9c e4 ff ff       	call   8001b4 <cprintf>
  801d18:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801d1b:	cc                   	int3   
  801d1c:	eb fd                	jmp    801d1b <_panic+0x43>
	...

00801d20 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801d20:	55                   	push   %ebp
  801d21:	89 e5                	mov    %esp,%ebp
  801d23:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  801d26:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801d2d:	75 52                	jne    801d81 <set_pgfault_handler+0x61>
		// First time through!	
		// LAB 4: Your code here.

		//int sys_page_alloc(envid_t envid, void *va, int perm)
		r = sys_page_alloc(0, (void*)(UXSTACKTOP - PGSIZE), PTE_U | PTE_W | PTE_P);
  801d2f:	83 ec 04             	sub    $0x4,%esp
  801d32:	6a 07                	push   $0x7
  801d34:	68 00 f0 bf ee       	push   $0xeebff000
  801d39:	6a 00                	push   $0x0
  801d3b:	e8 ac ee ff ff       	call   800bec <sys_page_alloc>
		if (r < 0) {
  801d40:	83 c4 10             	add    $0x10,%esp
  801d43:	85 c0                	test   %eax,%eax
  801d45:	79 12                	jns    801d59 <set_pgfault_handler+0x39>
			panic("sys_page_alloc error : %e\n", r);
  801d47:	50                   	push   %eax
  801d48:	68 0b 28 80 00       	push   $0x80280b
  801d4d:	6a 24                	push   $0x24
  801d4f:	68 26 28 80 00       	push   $0x802826
  801d54:	e8 7f ff ff ff       	call   801cd8 <_panic>
		}

		// how to know envid, put 0, envid2env will help us to get curenv in syscall
		r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);		
  801d59:	83 ec 08             	sub    $0x8,%esp
  801d5c:	68 8c 1d 80 00       	push   $0x801d8c
  801d61:	6a 00                	push   $0x0
  801d63:	e8 37 ef ff ff       	call   800c9f <sys_env_set_pgfault_upcall>
		if (r < 0) {
  801d68:	83 c4 10             	add    $0x10,%esp
  801d6b:	85 c0                	test   %eax,%eax
  801d6d:	79 12                	jns    801d81 <set_pgfault_handler+0x61>
			panic("sys_env_set_pgfault_upcall error : %e\n", r);
  801d6f:	50                   	push   %eax
  801d70:	68 34 28 80 00       	push   $0x802834
  801d75:	6a 2a                	push   $0x2a
  801d77:	68 26 28 80 00       	push   $0x802826
  801d7c:	e8 57 ff ff ff       	call   801cd8 <_panic>
		}
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801d81:	8b 45 08             	mov    0x8(%ebp),%eax
  801d84:	a3 00 60 80 00       	mov    %eax,0x806000
}
  801d89:	c9                   	leave  
  801d8a:	c3                   	ret    
	...

00801d8c <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801d8c:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801d8d:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  801d92:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801d94:	83 c4 04             	add    $0x4,%esp
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	
	// fix old esp
	movl 0x30(%esp), %eax
  801d97:	8b 44 24 30          	mov    0x30(%esp),%eax
	subl $0x4, %eax
  801d9b:	83 e8 04             	sub    $0x4,%eax
	movl %eax, 0x30(%esp)
  801d9e:	89 44 24 30          	mov    %eax,0x30(%esp)

	// set trap-time %eip
	movl 0x28(%esp), %ebx
  801da2:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	movl %ebx, (%eax)
  801da6:	89 18                	mov    %ebx,(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $0x08, %esp 	// ignore err_code and fault_va
  801da8:	83 c4 08             	add    $0x8,%esp
	popal 				// restore registers
  801dab:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x04, %esp 	// ignore eip 
  801dac:	83 c4 04             	add    $0x4,%esp
	popfl				// modify eflags
  801daf:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  801db0:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  801db1:	c3                   	ret    
	...

00801db4 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801db4:	55                   	push   %ebp
  801db5:	89 e5                	mov    %esp,%ebp
  801db7:	57                   	push   %edi
  801db8:	56                   	push   %esi
  801db9:	53                   	push   %ebx
  801dba:	83 ec 0c             	sub    $0xc,%esp
  801dbd:	8b 7d 08             	mov    0x8(%ebp),%edi
  801dc0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801dc3:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	cprintf("0x%x 0x%x 0x%x\n", (uint32_t)from_env_store, (uint32_t)pg, (uint32_t)perm_store);
  801dc6:	56                   	push   %esi
  801dc7:	53                   	push   %ebx
  801dc8:	57                   	push   %edi
  801dc9:	68 5c 28 80 00       	push   $0x80285c
  801dce:	e8 e1 e3 ff ff       	call   8001b4 <cprintf>
	int r;
	if (pg != NULL) {
  801dd3:	83 c4 10             	add    $0x10,%esp
  801dd6:	85 db                	test   %ebx,%ebx
  801dd8:	74 28                	je     801e02 <ipc_recv+0x4e>
		cprintf("BEGIN\n");
  801dda:	83 ec 0c             	sub    $0xc,%esp
  801ddd:	68 6c 28 80 00       	push   $0x80286c
  801de2:	e8 cd e3 ff ff       	call   8001b4 <cprintf>
		r = sys_ipc_recv(pg);
  801de7:	89 1c 24             	mov    %ebx,(%esp)
  801dea:	e8 f8 ee ff ff       	call   800ce7 <sys_ipc_recv>
  801def:	89 c3                	mov    %eax,%ebx
		cprintf("OVER\n");
  801df1:	c7 04 24 7c 27 80 00 	movl   $0x80277c,(%esp)
  801df8:	e8 b7 e3 ff ff       	call   8001b4 <cprintf>
  801dfd:	83 c4 10             	add    $0x10,%esp
  801e00:	eb 12                	jmp    801e14 <ipc_recv+0x60>
	} else {
		r = sys_ipc_recv((void *)UTOP);
  801e02:	83 ec 0c             	sub    $0xc,%esp
  801e05:	68 00 00 c0 ee       	push   $0xeec00000
  801e0a:	e8 d8 ee ff ff       	call   800ce7 <sys_ipc_recv>
  801e0f:	89 c3                	mov    %eax,%ebx
  801e11:	83 c4 10             	add    $0x10,%esp
	}

	if (r == 0) {
  801e14:	85 db                	test   %ebx,%ebx
  801e16:	75 26                	jne    801e3e <ipc_recv+0x8a>
		if (from_env_store != NULL) *from_env_store = thisenv->env_ipc_from;
  801e18:	85 ff                	test   %edi,%edi
  801e1a:	74 0a                	je     801e26 <ipc_recv+0x72>
  801e1c:	a1 04 40 80 00       	mov    0x804004,%eax
  801e21:	8b 40 74             	mov    0x74(%eax),%eax
  801e24:	89 07                	mov    %eax,(%edi)
		if (perm_store != NULL) *perm_store = thisenv->env_ipc_perm;
  801e26:	85 f6                	test   %esi,%esi
  801e28:	74 0a                	je     801e34 <ipc_recv+0x80>
  801e2a:	a1 04 40 80 00       	mov    0x804004,%eax
  801e2f:	8b 40 78             	mov    0x78(%eax),%eax
  801e32:	89 06                	mov    %eax,(%esi)
		return thisenv->env_ipc_value;
  801e34:	a1 04 40 80 00       	mov    0x804004,%eax
  801e39:	8b 58 70             	mov    0x70(%eax),%ebx
  801e3c:	eb 14                	jmp    801e52 <ipc_recv+0x9e>
	} else {
		// fails;
		if (from_env_store != NULL) *from_env_store = 0;
  801e3e:	85 ff                	test   %edi,%edi
  801e40:	74 06                	je     801e48 <ipc_recv+0x94>
  801e42:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
		if (perm_store != NULL) *perm_store = 0;
  801e48:	85 f6                	test   %esi,%esi
  801e4a:	74 06                	je     801e52 <ipc_recv+0x9e>
  801e4c:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		return r;
	}
}
  801e52:	89 d8                	mov    %ebx,%eax
  801e54:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e57:	5b                   	pop    %ebx
  801e58:	5e                   	pop    %esi
  801e59:	5f                   	pop    %edi
  801e5a:	c9                   	leave  
  801e5b:	c3                   	ret    

00801e5c <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801e5c:	55                   	push   %ebp
  801e5d:	89 e5                	mov    %esp,%ebp
  801e5f:	57                   	push   %edi
  801e60:	56                   	push   %esi
  801e61:	53                   	push   %ebx
  801e62:	83 ec 0c             	sub    $0xc,%esp
  801e65:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801e68:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801e6b:	8b 75 14             	mov    0x14(%ebp),%esi
	// LAB 4: Your code here.
	// int sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
	int r;
	if (pg == NULL) pg = (void *)UTOP;
  801e6e:	85 db                	test   %ebx,%ebx
  801e70:	75 25                	jne    801e97 <ipc_send+0x3b>
  801e72:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
  801e77:	eb 1e                	jmp    801e97 <ipc_send+0x3b>
	
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) != 0) {
		if (r == -E_IPC_NOT_RECV) {
  801e79:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801e7c:	75 07                	jne    801e85 <ipc_send+0x29>
			// cprintf("Try Again and Again....\n");
			sys_yield();
  801e7e:	e8 42 ed ff ff       	call   800bc5 <sys_yield>
  801e83:	eb 12                	jmp    801e97 <ipc_send+0x3b>
		} else {
			panic("ipc_send error %e\n", r);
  801e85:	50                   	push   %eax
  801e86:	68 73 28 80 00       	push   $0x802873
  801e8b:	6a 45                	push   $0x45
  801e8d:	68 86 28 80 00       	push   $0x802886
  801e92:	e8 41 fe ff ff       	call   801cd8 <_panic>
	// LAB 4: Your code here.
	// int sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
	int r;
	if (pg == NULL) pg = (void *)UTOP;
	
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) != 0) {
  801e97:	56                   	push   %esi
  801e98:	53                   	push   %ebx
  801e99:	57                   	push   %edi
  801e9a:	ff 75 08             	pushl  0x8(%ebp)
  801e9d:	e8 20 ee ff ff       	call   800cc2 <sys_ipc_try_send>
  801ea2:	83 c4 10             	add    $0x10,%esp
  801ea5:	85 c0                	test   %eax,%eax
  801ea7:	75 d0                	jne    801e79 <ipc_send+0x1d>
		} else {
			panic("ipc_send error %e\n", r);
		}
	}
	return;
}
  801ea9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801eac:	5b                   	pop    %ebx
  801ead:	5e                   	pop    %esi
  801eae:	5f                   	pop    %edi
  801eaf:	c9                   	leave  
  801eb0:	c3                   	ret    

00801eb1 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801eb1:	55                   	push   %ebp
  801eb2:	89 e5                	mov    %esp,%ebp
  801eb4:	53                   	push   %ebx
  801eb5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  801eb8:	39 1d 50 00 c0 ee    	cmp    %ebx,0xeec00050
  801ebe:	74 22                	je     801ee2 <ipc_find_env+0x31>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801ec0:	b8 01 00 00 00       	mov    $0x1,%eax
		if (envs[i].env_type == type)
  801ec5:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  801ecc:	89 c2                	mov    %eax,%edx
  801ece:	c1 e2 07             	shl    $0x7,%edx
  801ed1:	29 ca                	sub    %ecx,%edx
  801ed3:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801ed9:	8b 52 50             	mov    0x50(%edx),%edx
  801edc:	39 da                	cmp    %ebx,%edx
  801ede:	75 1d                	jne    801efd <ipc_find_env+0x4c>
  801ee0:	eb 05                	jmp    801ee7 <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801ee2:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
			return envs[i].env_id;
  801ee7:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  801eee:	c1 e0 07             	shl    $0x7,%eax
  801ef1:	29 d0                	sub    %edx,%eax
  801ef3:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  801ef8:	8b 40 40             	mov    0x40(%eax),%eax
  801efb:	eb 0c                	jmp    801f09 <ipc_find_env+0x58>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801efd:	40                   	inc    %eax
  801efe:	3d 00 04 00 00       	cmp    $0x400,%eax
  801f03:	75 c0                	jne    801ec5 <ipc_find_env+0x14>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801f05:	66 b8 00 00          	mov    $0x0,%ax
}
  801f09:	5b                   	pop    %ebx
  801f0a:	c9                   	leave  
  801f0b:	c3                   	ret    

00801f0c <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801f0c:	55                   	push   %ebp
  801f0d:	89 e5                	mov    %esp,%ebp
  801f0f:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801f12:	89 c2                	mov    %eax,%edx
  801f14:	c1 ea 16             	shr    $0x16,%edx
  801f17:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801f1e:	f6 c2 01             	test   $0x1,%dl
  801f21:	74 1e                	je     801f41 <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  801f23:	c1 e8 0c             	shr    $0xc,%eax
  801f26:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801f2d:	a8 01                	test   $0x1,%al
  801f2f:	74 17                	je     801f48 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801f31:	c1 e8 0c             	shr    $0xc,%eax
  801f34:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  801f3b:	ef 
  801f3c:	0f b7 c0             	movzwl %ax,%eax
  801f3f:	eb 0c                	jmp    801f4d <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  801f41:	b8 00 00 00 00       	mov    $0x0,%eax
  801f46:	eb 05                	jmp    801f4d <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  801f48:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  801f4d:	c9                   	leave  
  801f4e:	c3                   	ret    
	...

00801f50 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  801f50:	55                   	push   %ebp
  801f51:	89 e5                	mov    %esp,%ebp
  801f53:	57                   	push   %edi
  801f54:	56                   	push   %esi
  801f55:	83 ec 10             	sub    $0x10,%esp
  801f58:	8b 7d 08             	mov    0x8(%ebp),%edi
  801f5b:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  801f5e:	89 7d f0             	mov    %edi,-0x10(%ebp)
  801f61:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  801f64:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  801f67:	8b 45 14             	mov    0x14(%ebp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  801f6a:	85 c0                	test   %eax,%eax
  801f6c:	75 2e                	jne    801f9c <__udivdi3+0x4c>
    {
      if (d0 > n1)
  801f6e:	39 f1                	cmp    %esi,%ecx
  801f70:	77 5a                	ja     801fcc <__udivdi3+0x7c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  801f72:	85 c9                	test   %ecx,%ecx
  801f74:	75 0b                	jne    801f81 <__udivdi3+0x31>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  801f76:	b8 01 00 00 00       	mov    $0x1,%eax
  801f7b:	31 d2                	xor    %edx,%edx
  801f7d:	f7 f1                	div    %ecx
  801f7f:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  801f81:	31 d2                	xor    %edx,%edx
  801f83:	89 f0                	mov    %esi,%eax
  801f85:	f7 f1                	div    %ecx
  801f87:	89 c6                	mov    %eax,%esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801f89:	89 f8                	mov    %edi,%eax
  801f8b:	f7 f1                	div    %ecx
  801f8d:	89 c7                	mov    %eax,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801f8f:	89 f8                	mov    %edi,%eax
  801f91:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801f93:	83 c4 10             	add    $0x10,%esp
  801f96:	5e                   	pop    %esi
  801f97:	5f                   	pop    %edi
  801f98:	c9                   	leave  
  801f99:	c3                   	ret    
  801f9a:	66 90                	xchg   %ax,%ax
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801f9c:	39 f0                	cmp    %esi,%eax
  801f9e:	77 1c                	ja     801fbc <__udivdi3+0x6c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  801fa0:	0f bd f8             	bsr    %eax,%edi
	  if (bm == 0)
  801fa3:	83 f7 1f             	xor    $0x1f,%edi
  801fa6:	75 3c                	jne    801fe4 <__udivdi3+0x94>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801fa8:	39 f0                	cmp    %esi,%eax
  801faa:	0f 82 90 00 00 00    	jb     802040 <__udivdi3+0xf0>
  801fb0:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801fb3:	39 55 f4             	cmp    %edx,-0xc(%ebp)
  801fb6:	0f 86 84 00 00 00    	jbe    802040 <__udivdi3+0xf0>
  801fbc:	31 f6                	xor    %esi,%esi
  801fbe:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801fc0:	89 f8                	mov    %edi,%eax
  801fc2:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801fc4:	83 c4 10             	add    $0x10,%esp
  801fc7:	5e                   	pop    %esi
  801fc8:	5f                   	pop    %edi
  801fc9:	c9                   	leave  
  801fca:	c3                   	ret    
  801fcb:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801fcc:	89 f2                	mov    %esi,%edx
  801fce:	89 f8                	mov    %edi,%eax
  801fd0:	f7 f1                	div    %ecx
  801fd2:	89 c7                	mov    %eax,%edi
  801fd4:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801fd6:	89 f8                	mov    %edi,%eax
  801fd8:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801fda:	83 c4 10             	add    $0x10,%esp
  801fdd:	5e                   	pop    %esi
  801fde:	5f                   	pop    %edi
  801fdf:	c9                   	leave  
  801fe0:	c3                   	ret    
  801fe1:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  801fe4:	89 f9                	mov    %edi,%ecx
  801fe6:	d3 e0                	shl    %cl,%eax
  801fe8:	89 45 e8             	mov    %eax,-0x18(%ebp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  801feb:	b8 20 00 00 00       	mov    $0x20,%eax
  801ff0:	29 f8                	sub    %edi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  801ff2:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801ff5:	88 c1                	mov    %al,%cl
  801ff7:	d3 ea                	shr    %cl,%edx
  801ff9:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  801ffc:	09 ca                	or     %ecx,%edx
  801ffe:	89 55 ec             	mov    %edx,-0x14(%ebp)
	      d0 = d0 << bm;
  802001:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802004:	89 f9                	mov    %edi,%ecx
  802006:	d3 e2                	shl    %cl,%edx
  802008:	89 55 f4             	mov    %edx,-0xc(%ebp)
	      n2 = n1 >> b;
  80200b:	89 f2                	mov    %esi,%edx
  80200d:	88 c1                	mov    %al,%cl
  80200f:	d3 ea                	shr    %cl,%edx
  802011:	89 55 e8             	mov    %edx,-0x18(%ebp)
	      n1 = (n1 << bm) | (n0 >> b);
  802014:	89 f2                	mov    %esi,%edx
  802016:	89 f9                	mov    %edi,%ecx
  802018:	d3 e2                	shl    %cl,%edx
  80201a:	8b 75 f0             	mov    -0x10(%ebp),%esi
  80201d:	88 c1                	mov    %al,%cl
  80201f:	d3 ee                	shr    %cl,%esi
  802021:	09 d6                	or     %edx,%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  802023:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  802026:	89 f0                	mov    %esi,%eax
  802028:	89 ca                	mov    %ecx,%edx
  80202a:	f7 75 ec             	divl   -0x14(%ebp)
  80202d:	89 d1                	mov    %edx,%ecx
  80202f:	89 c6                	mov    %eax,%esi
	      umul_ppmm (m1, m0, q0, d0);
  802031:	f7 65 f4             	mull   -0xc(%ebp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802034:	39 d1                	cmp    %edx,%ecx
  802036:	72 28                	jb     802060 <__udivdi3+0x110>
  802038:	74 1a                	je     802054 <__udivdi3+0x104>
  80203a:	89 f7                	mov    %esi,%edi
  80203c:	31 f6                	xor    %esi,%esi
  80203e:	eb 80                	jmp    801fc0 <__udivdi3+0x70>
	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  802040:	31 f6                	xor    %esi,%esi
  802042:	bf 01 00 00 00       	mov    $0x1,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  802047:	89 f8                	mov    %edi,%eax
  802049:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  80204b:	83 c4 10             	add    $0x10,%esp
  80204e:	5e                   	pop    %esi
  80204f:	5f                   	pop    %edi
  802050:	c9                   	leave  
  802051:	c3                   	ret    
  802052:	66 90                	xchg   %ax,%ax

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  802054:	8b 55 f0             	mov    -0x10(%ebp),%edx
  802057:	89 f9                	mov    %edi,%ecx
  802059:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  80205b:	39 c2                	cmp    %eax,%edx
  80205d:	73 db                	jae    80203a <__udivdi3+0xea>
  80205f:	90                   	nop
		{
		  q0--;
  802060:	8d 7e ff             	lea    -0x1(%esi),%edi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  802063:	31 f6                	xor    %esi,%esi
  802065:	e9 56 ff ff ff       	jmp    801fc0 <__udivdi3+0x70>
	...

0080206c <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  80206c:	55                   	push   %ebp
  80206d:	89 e5                	mov    %esp,%ebp
  80206f:	57                   	push   %edi
  802070:	56                   	push   %esi
  802071:	83 ec 20             	sub    $0x20,%esp
  802074:	8b 45 08             	mov    0x8(%ebp),%eax
  802077:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  80207a:	89 45 e8             	mov    %eax,-0x18(%ebp)
  80207d:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  802080:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  802083:	8b 7d 14             	mov    0x14(%ebp),%edi
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  802086:	89 45 f0             	mov    %eax,-0x10(%ebp)
  n1 = nn.s.high;
  802089:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  80208b:	85 ff                	test   %edi,%edi
  80208d:	75 15                	jne    8020a4 <__umoddi3+0x38>
    {
      if (d0 > n1)
  80208f:	39 f1                	cmp    %esi,%ecx
  802091:	0f 86 99 00 00 00    	jbe    802130 <__umoddi3+0xc4>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802097:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  802099:	89 d0                	mov    %edx,%eax
  80209b:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  80209d:	83 c4 20             	add    $0x20,%esp
  8020a0:	5e                   	pop    %esi
  8020a1:	5f                   	pop    %edi
  8020a2:	c9                   	leave  
  8020a3:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  8020a4:	39 f7                	cmp    %esi,%edi
  8020a6:	0f 87 a4 00 00 00    	ja     802150 <__umoddi3+0xe4>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  8020ac:	0f bd c7             	bsr    %edi,%eax
	  if (bm == 0)
  8020af:	83 f0 1f             	xor    $0x1f,%eax
  8020b2:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8020b5:	0f 84 a1 00 00 00    	je     80215c <__umoddi3+0xf0>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  8020bb:	89 f8                	mov    %edi,%eax
  8020bd:	8a 4d ec             	mov    -0x14(%ebp),%cl
  8020c0:	d3 e0                	shl    %cl,%eax
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  8020c2:	bf 20 00 00 00       	mov    $0x20,%edi
  8020c7:	2b 7d ec             	sub    -0x14(%ebp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  8020ca:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8020cd:	89 f9                	mov    %edi,%ecx
  8020cf:	d3 ea                	shr    %cl,%edx
  8020d1:	09 c2                	or     %eax,%edx
  8020d3:	89 55 f0             	mov    %edx,-0x10(%ebp)
	      d0 = d0 << bm;
  8020d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020d9:	8a 4d ec             	mov    -0x14(%ebp),%cl
  8020dc:	d3 e0                	shl    %cl,%eax
  8020de:	89 45 f4             	mov    %eax,-0xc(%ebp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  8020e1:	89 f2                	mov    %esi,%edx
  8020e3:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  8020e5:	8b 45 e8             	mov    -0x18(%ebp),%eax
  8020e8:	d3 e0                	shl    %cl,%eax
  8020ea:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  8020ed:	8b 45 e8             	mov    -0x18(%ebp),%eax
  8020f0:	89 f9                	mov    %edi,%ecx
  8020f2:	d3 e8                	shr    %cl,%eax
  8020f4:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  8020f6:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  8020f8:	89 f2                	mov    %esi,%edx
  8020fa:	f7 75 f0             	divl   -0x10(%ebp)
  8020fd:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  8020ff:	f7 65 f4             	mull   -0xc(%ebp)
  802102:	89 55 e8             	mov    %edx,-0x18(%ebp)
  802105:	89 c1                	mov    %eax,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802107:	39 d6                	cmp    %edx,%esi
  802109:	72 71                	jb     80217c <__umoddi3+0x110>
  80210b:	74 7f                	je     80218c <__umoddi3+0x120>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  80210d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802110:	29 c8                	sub    %ecx,%eax
  802112:	19 d6                	sbb    %edx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  802114:	8a 4d ec             	mov    -0x14(%ebp),%cl
  802117:	d3 e8                	shr    %cl,%eax
  802119:	89 f2                	mov    %esi,%edx
  80211b:	89 f9                	mov    %edi,%ecx
  80211d:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  80211f:	09 d0                	or     %edx,%eax
  802121:	89 f2                	mov    %esi,%edx
  802123:	8a 4d ec             	mov    -0x14(%ebp),%cl
  802126:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802128:	83 c4 20             	add    $0x20,%esp
  80212b:	5e                   	pop    %esi
  80212c:	5f                   	pop    %edi
  80212d:	c9                   	leave  
  80212e:	c3                   	ret    
  80212f:	90                   	nop
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  802130:	85 c9                	test   %ecx,%ecx
  802132:	75 0b                	jne    80213f <__umoddi3+0xd3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  802134:	b8 01 00 00 00       	mov    $0x1,%eax
  802139:	31 d2                	xor    %edx,%edx
  80213b:	f7 f1                	div    %ecx
  80213d:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  80213f:	89 f0                	mov    %esi,%eax
  802141:	31 d2                	xor    %edx,%edx
  802143:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802145:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802148:	f7 f1                	div    %ecx
  80214a:	e9 4a ff ff ff       	jmp    802099 <__umoddi3+0x2d>
  80214f:	90                   	nop
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  802150:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802152:	83 c4 20             	add    $0x20,%esp
  802155:	5e                   	pop    %esi
  802156:	5f                   	pop    %edi
  802157:	c9                   	leave  
  802158:	c3                   	ret    
  802159:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  80215c:	39 f7                	cmp    %esi,%edi
  80215e:	72 05                	jb     802165 <__umoddi3+0xf9>
  802160:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
  802163:	77 0c                	ja     802171 <__umoddi3+0x105>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  802165:	89 f2                	mov    %esi,%edx
  802167:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80216a:	29 c8                	sub    %ecx,%eax
  80216c:	19 fa                	sbb    %edi,%edx
  80216e:	89 45 f0             	mov    %eax,-0x10(%ebp)

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  802171:	8b 45 f0             	mov    -0x10(%ebp),%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802174:	83 c4 20             	add    $0x20,%esp
  802177:	5e                   	pop    %esi
  802178:	5f                   	pop    %edi
  802179:	c9                   	leave  
  80217a:	c3                   	ret    
  80217b:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  80217c:	8b 55 e8             	mov    -0x18(%ebp),%edx
  80217f:	89 c1                	mov    %eax,%ecx
  802181:	2b 4d f4             	sub    -0xc(%ebp),%ecx
  802184:	1b 55 f0             	sbb    -0x10(%ebp),%edx
  802187:	eb 84                	jmp    80210d <__umoddi3+0xa1>
  802189:	8d 76 00             	lea    0x0(%esi),%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  80218c:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  80218f:	72 eb                	jb     80217c <__umoddi3+0x110>
  802191:	89 f2                	mov    %esi,%edx
  802193:	e9 75 ff ff ff       	jmp    80210d <__umoddi3+0xa1>
