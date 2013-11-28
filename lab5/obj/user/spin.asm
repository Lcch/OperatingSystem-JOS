
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
  80003b:	68 c0 21 80 00       	push   $0x8021c0
  800040:	e8 6f 01 00 00       	call   8001b4 <cprintf>
	if ((env = fork()) == 0) {
  800045:	e8 dc 0d 00 00       	call   800e26 <fork>
  80004a:	89 c3                	mov    %eax,%ebx
  80004c:	83 c4 10             	add    $0x10,%esp
  80004f:	85 c0                	test   %eax,%eax
  800051:	75 12                	jne    800065 <umain+0x31>
		cprintf("I am the child.  Spinning...\n");
  800053:	83 ec 0c             	sub    $0xc,%esp
  800056:	68 38 22 80 00       	push   $0x802238
  80005b:	e8 54 01 00 00       	call   8001b4 <cprintf>
  800060:	83 c4 10             	add    $0x10,%esp
  800063:	eb fe                	jmp    800063 <umain+0x2f>
		while (1)
			/* do nothing */;
	}

	cprintf("I am the parent.  Running the child...\n");
  800065:	83 ec 0c             	sub    $0xc,%esp
  800068:	68 e8 21 80 00       	push   $0x8021e8
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
  80009a:	c7 04 24 10 22 80 00 	movl   $0x802210,(%esp)
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
  80010e:	e8 67 11 00 00       	call   80127a <close_all>
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
  80021c:	e8 4b 1d 00 00       	call   801f6c <__udivdi3>
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
  800258:	e8 2b 1e 00 00       	call   802088 <__umoddi3>
  80025d:	83 c4 14             	add    $0x14,%esp
  800260:	0f be 80 60 22 80 00 	movsbl 0x802260(%eax),%eax
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
  8003a4:	ff 24 85 a0 23 80 00 	jmp    *0x8023a0(,%eax,4)
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
  800450:	8b 04 85 00 25 80 00 	mov    0x802500(,%eax,4),%eax
  800457:	85 c0                	test   %eax,%eax
  800459:	75 1a                	jne    800475 <vprintfmt+0x15c>
				printfmt(putch, putdat, "error %d", err);
  80045b:	52                   	push   %edx
  80045c:	68 78 22 80 00       	push   $0x802278
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
  800476:	68 b5 27 80 00       	push   $0x8027b5
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
  8004ac:	c7 45 d0 71 22 80 00 	movl   $0x802271,-0x30(%ebp)
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
  800b1a:	68 5f 25 80 00       	push   $0x80255f
  800b1f:	6a 42                	push   $0x42
  800b21:	68 7c 25 80 00       	push   $0x80257c
  800b26:	e8 f9 11 00 00       	call   801d24 <_panic>

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

00800d2c <sys_exec>:

int
sys_exec(uint32_t eip, uint32_t esp, void * ph, uint32_t elf_phnum)
{
  800d2c:	55                   	push   %ebp
  800d2d:	89 e5                	mov    %esp,%ebp
  800d2f:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_exec, 0, eip, esp, (uint32_t)ph, elf_phnum, 0);
  800d32:	6a 00                	push   $0x0
  800d34:	ff 75 14             	pushl  0x14(%ebp)
  800d37:	ff 75 10             	pushl  0x10(%ebp)
  800d3a:	ff 75 0c             	pushl  0xc(%ebp)
  800d3d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d40:	ba 00 00 00 00       	mov    $0x0,%edx
  800d45:	b8 0f 00 00 00       	mov    $0xf,%eax
  800d4a:	e8 99 fd ff ff       	call   800ae8 <syscall>
  800d4f:	c9                   	leave  
  800d50:	c3                   	ret    
  800d51:	00 00                	add    %al,(%eax)
	...

00800d54 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800d54:	55                   	push   %ebp
  800d55:	89 e5                	mov    %esp,%ebp
  800d57:	53                   	push   %ebx
  800d58:	83 ec 04             	sub    $0x4,%esp
  800d5b:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800d5e:	8b 18                	mov    (%eax),%ebx

	// LAB 4: Your code here.
	
	// cprintf("PAGE FAULT HANDLER, 0x%08x %d\n", (uint32_t)addr, err & FEC_WR);
	
	if ((err & FEC_WR) == 0)
  800d60:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800d64:	75 14                	jne    800d7a <pgfault+0x26>
		panic("pgfault, the fault is not a write\n");
  800d66:	83 ec 04             	sub    $0x4,%esp
  800d69:	68 8c 25 80 00       	push   $0x80258c
  800d6e:	6a 20                	push   $0x20
  800d70:	68 d0 26 80 00       	push   $0x8026d0
  800d75:	e8 aa 0f 00 00       	call   801d24 <_panic>

	uint32_t uaddr = (uint32_t) addr;
	if ((uvpd[PDX(addr)] & PTE_P) == 0 || (uvpt[uaddr / PGSIZE] & PTE_COW) == 0) {
  800d7a:	89 d8                	mov    %ebx,%eax
  800d7c:	c1 e8 16             	shr    $0x16,%eax
  800d7f:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800d86:	a8 01                	test   $0x1,%al
  800d88:	74 11                	je     800d9b <pgfault+0x47>
  800d8a:	89 d8                	mov    %ebx,%eax
  800d8c:	c1 e8 0c             	shr    $0xc,%eax
  800d8f:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800d96:	f6 c4 08             	test   $0x8,%ah
  800d99:	75 14                	jne    800daf <pgfault+0x5b>
		panic("pgfault, not a copy-on-write page\n");
  800d9b:	83 ec 04             	sub    $0x4,%esp
  800d9e:	68 b0 25 80 00       	push   $0x8025b0
  800da3:	6a 24                	push   $0x24
  800da5:	68 d0 26 80 00       	push   $0x8026d0
  800daa:	e8 75 0f 00 00       	call   801d24 <_panic>
	//   No need to explicitly delete the old page's mapping.

	// LAB 4: Your code here.

	// static int sys_page_alloc(envid_t envid, void *va, int perm)
	r = sys_page_alloc(0, (void *)PFTEMP, PTE_W | PTE_U | PTE_P);
  800daf:	83 ec 04             	sub    $0x4,%esp
  800db2:	6a 07                	push   $0x7
  800db4:	68 00 f0 7f 00       	push   $0x7ff000
  800db9:	6a 00                	push   $0x0
  800dbb:	e8 2c fe ff ff       	call   800bec <sys_page_alloc>
	if (r < 0) panic("pgfault, sys_page_alloc error : %e\n", r);
  800dc0:	83 c4 10             	add    $0x10,%esp
  800dc3:	85 c0                	test   %eax,%eax
  800dc5:	79 12                	jns    800dd9 <pgfault+0x85>
  800dc7:	50                   	push   %eax
  800dc8:	68 d4 25 80 00       	push   $0x8025d4
  800dcd:	6a 32                	push   $0x32
  800dcf:	68 d0 26 80 00       	push   $0x8026d0
  800dd4:	e8 4b 0f 00 00       	call   801d24 <_panic>

	// Oh my god, I forget this at the first, it waste me a lot of time to debug!!!
	addr = ROUNDDOWN(addr, PGSIZE);
  800dd9:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	
	memcpy(PFTEMP, addr, PGSIZE);
  800ddf:	83 ec 04             	sub    $0x4,%esp
  800de2:	68 00 10 00 00       	push   $0x1000
  800de7:	53                   	push   %ebx
  800de8:	68 00 f0 7f 00       	push   $0x7ff000
  800ded:	e8 a3 fb ff ff       	call   800995 <memcpy>
	
	r = sys_page_map(0, PFTEMP, 0, addr, PTE_W | PTE_U | PTE_P);
  800df2:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800df9:	53                   	push   %ebx
  800dfa:	6a 00                	push   $0x0
  800dfc:	68 00 f0 7f 00       	push   $0x7ff000
  800e01:	6a 00                	push   $0x0
  800e03:	e8 08 fe ff ff       	call   800c10 <sys_page_map>
	if (r < 0) panic("pgfault, sys_page_map error : %e\n", r);
  800e08:	83 c4 20             	add    $0x20,%esp
  800e0b:	85 c0                	test   %eax,%eax
  800e0d:	79 12                	jns    800e21 <pgfault+0xcd>
  800e0f:	50                   	push   %eax
  800e10:	68 f8 25 80 00       	push   $0x8025f8
  800e15:	6a 3a                	push   $0x3a
  800e17:	68 d0 26 80 00       	push   $0x8026d0
  800e1c:	e8 03 0f 00 00       	call   801d24 <_panic>

	return;
}
  800e21:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e24:	c9                   	leave  
  800e25:	c3                   	ret    

00800e26 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800e26:	55                   	push   %ebp
  800e27:	89 e5                	mov    %esp,%ebp
  800e29:	57                   	push   %edi
  800e2a:	56                   	push   %esi
  800e2b:	53                   	push   %ebx
  800e2c:	83 ec 28             	sub    $0x28,%esp
	// static int num = 0x100;

	// LAB 4: Your code here.
	set_pgfault_handler(pgfault);
  800e2f:	68 54 0d 80 00       	push   $0x800d54
  800e34:	e8 33 0f 00 00       	call   801d6c <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  800e39:	ba 07 00 00 00       	mov    $0x7,%edx
  800e3e:	89 d0                	mov    %edx,%eax
  800e40:	cd 30                	int    $0x30
  800e42:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800e45:	89 c7                	mov    %eax,%edi
	int childpid = sys_exofork();
	if (childpid < 0) {
  800e47:	83 c4 10             	add    $0x10,%esp
  800e4a:	85 c0                	test   %eax,%eax
  800e4c:	79 12                	jns    800e60 <fork+0x3a>
		panic("fork sys_exofork error : %e\n", childpid);
  800e4e:	50                   	push   %eax
  800e4f:	68 db 26 80 00       	push   $0x8026db
  800e54:	6a 7f                	push   $0x7f
  800e56:	68 d0 26 80 00       	push   $0x8026d0
  800e5b:	e8 c4 0e 00 00       	call   801d24 <_panic>
	}
	int r;

	if (childpid == 0) {
  800e60:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800e64:	75 25                	jne    800e8b <fork+0x65>
		// child process
		// Remember to fix "thisenv" in the child process. ??? 
		thisenv = &envs[ENVX(sys_getenvid())];
  800e66:	e8 36 fd ff ff       	call   800ba1 <sys_getenvid>
  800e6b:	25 ff 03 00 00       	and    $0x3ff,%eax
  800e70:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800e77:	c1 e0 07             	shl    $0x7,%eax
  800e7a:	29 d0                	sub    %edx,%eax
  800e7c:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800e81:	a3 04 40 80 00       	mov    %eax,0x804004
		// cprintf("fork child ok\n");
		return 0;
  800e86:	e9 be 01 00 00       	jmp    801049 <fork+0x223>
	if (childpid < 0) {
		panic("fork sys_exofork error : %e\n", childpid);
	}
	int r;

	if (childpid == 0) {
  800e8b:	bb 00 00 00 00       	mov    $0x0,%ebx
	} else {
		// map page to new environment
		// kernel page is already in new environment
		uint32_t i;
		for (i = 0; i != UTOP; i += PGSIZE) 
		if ((uvpd[PDX(i)] & PTE_P) && (uvpt[i / PGSIZE] & PTE_P) && (uvpt[i / PGSIZE] & PTE_U)) {
  800e90:	89 d8                	mov    %ebx,%eax
  800e92:	c1 e8 16             	shr    $0x16,%eax
  800e95:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800e9c:	a8 01                	test   $0x1,%al
  800e9e:	0f 84 10 01 00 00    	je     800fb4 <fork+0x18e>
  800ea4:	89 d8                	mov    %ebx,%eax
  800ea6:	c1 e8 0c             	shr    $0xc,%eax
  800ea9:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800eb0:	f6 c2 01             	test   $0x1,%dl
  800eb3:	0f 84 fb 00 00 00    	je     800fb4 <fork+0x18e>
  800eb9:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800ec0:	f6 c2 04             	test   $0x4,%dl
  800ec3:	0f 84 eb 00 00 00    	je     800fb4 <fork+0x18e>
//
static int
duppage(envid_t envid, unsigned pn)
{
	// do not dup exception stack
	if (pn * PGSIZE == UXSTACKTOP - PGSIZE) return 0;
  800ec9:	89 c6                	mov    %eax,%esi
  800ecb:	c1 e6 0c             	shl    $0xc,%esi
  800ece:	81 fe 00 f0 bf ee    	cmp    $0xeebff000,%esi
  800ed4:	0f 84 da 00 00 00    	je     800fb4 <fork+0x18e>

	int r;
	void * addr = (void *)(pn * PGSIZE);
    if (uvpt[pn] & PTE_SHARE) {
  800eda:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800ee1:	f6 c6 04             	test   $0x4,%dh
  800ee4:	74 37                	je     800f1d <fork+0xf7>
        r = sys_page_map(0, addr, envid, addr, uvpt[pn] & PTE_SYSCALL);
  800ee6:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800eed:	83 ec 0c             	sub    $0xc,%esp
  800ef0:	25 07 0e 00 00       	and    $0xe07,%eax
  800ef5:	50                   	push   %eax
  800ef6:	56                   	push   %esi
  800ef7:	57                   	push   %edi
  800ef8:	56                   	push   %esi
  800ef9:	6a 00                	push   $0x0
  800efb:	e8 10 fd ff ff       	call   800c10 <sys_page_map>
        if (r < 0) panic("duppage sys_page_map error : %e\n", r);
  800f00:	83 c4 20             	add    $0x20,%esp
  800f03:	85 c0                	test   %eax,%eax
  800f05:	0f 89 a9 00 00 00    	jns    800fb4 <fork+0x18e>
  800f0b:	50                   	push   %eax
  800f0c:	68 1c 26 80 00       	push   $0x80261c
  800f11:	6a 54                	push   $0x54
  800f13:	68 d0 26 80 00       	push   $0x8026d0
  800f18:	e8 07 0e 00 00       	call   801d24 <_panic>
    } else
	if ((uvpt[pn] & PTE_W) || (uvpt[pn] & PTE_COW)) {
  800f1d:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800f24:	f6 c2 02             	test   $0x2,%dl
  800f27:	75 0c                	jne    800f35 <fork+0x10f>
  800f29:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f30:	f6 c4 08             	test   $0x8,%ah
  800f33:	74 57                	je     800f8c <fork+0x166>
		// cow
		r = sys_page_map(0, addr, envid, addr, PTE_COW | PTE_P | PTE_U);
  800f35:	83 ec 0c             	sub    $0xc,%esp
  800f38:	68 05 08 00 00       	push   $0x805
  800f3d:	56                   	push   %esi
  800f3e:	57                   	push   %edi
  800f3f:	56                   	push   %esi
  800f40:	6a 00                	push   $0x0
  800f42:	e8 c9 fc ff ff       	call   800c10 <sys_page_map>
		if (r < 0) panic("duppage sys_page_map error : %e\n", r);
  800f47:	83 c4 20             	add    $0x20,%esp
  800f4a:	85 c0                	test   %eax,%eax
  800f4c:	79 12                	jns    800f60 <fork+0x13a>
  800f4e:	50                   	push   %eax
  800f4f:	68 1c 26 80 00       	push   $0x80261c
  800f54:	6a 59                	push   $0x59
  800f56:	68 d0 26 80 00       	push   $0x8026d0
  800f5b:	e8 c4 0d 00 00       	call   801d24 <_panic>
		
		r = sys_page_map(0, addr, 0, addr, PTE_COW | PTE_P | PTE_U);
  800f60:	83 ec 0c             	sub    $0xc,%esp
  800f63:	68 05 08 00 00       	push   $0x805
  800f68:	56                   	push   %esi
  800f69:	6a 00                	push   $0x0
  800f6b:	56                   	push   %esi
  800f6c:	6a 00                	push   $0x0
  800f6e:	e8 9d fc ff ff       	call   800c10 <sys_page_map>
		if (r < 0) panic("duppage sys_page_map error : %e\n", r);
  800f73:	83 c4 20             	add    $0x20,%esp
  800f76:	85 c0                	test   %eax,%eax
  800f78:	79 3a                	jns    800fb4 <fork+0x18e>
  800f7a:	50                   	push   %eax
  800f7b:	68 1c 26 80 00       	push   $0x80261c
  800f80:	6a 5c                	push   $0x5c
  800f82:	68 d0 26 80 00       	push   $0x8026d0
  800f87:	e8 98 0d 00 00       	call   801d24 <_panic>
	} else {
		// read only
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U);
  800f8c:	83 ec 0c             	sub    $0xc,%esp
  800f8f:	6a 05                	push   $0x5
  800f91:	56                   	push   %esi
  800f92:	57                   	push   %edi
  800f93:	56                   	push   %esi
  800f94:	6a 00                	push   $0x0
  800f96:	e8 75 fc ff ff       	call   800c10 <sys_page_map>
		if (r < 0) panic("duppage sys_page_map error : %e\n", r);
  800f9b:	83 c4 20             	add    $0x20,%esp
  800f9e:	85 c0                	test   %eax,%eax
  800fa0:	79 12                	jns    800fb4 <fork+0x18e>
  800fa2:	50                   	push   %eax
  800fa3:	68 1c 26 80 00       	push   $0x80261c
  800fa8:	6a 60                	push   $0x60
  800faa:	68 d0 26 80 00       	push   $0x8026d0
  800faf:	e8 70 0d 00 00       	call   801d24 <_panic>
		return 0;
	} else {
		// map page to new environment
		// kernel page is already in new environment
		uint32_t i;
		for (i = 0; i != UTOP; i += PGSIZE) 
  800fb4:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  800fba:	81 fb 00 00 c0 ee    	cmp    $0xeec00000,%ebx
  800fc0:	0f 85 ca fe ff ff    	jne    800e90 <fork+0x6a>
		if ((uvpd[PDX(i)] & PTE_P) && (uvpt[i / PGSIZE] & PTE_P) && (uvpt[i / PGSIZE] & PTE_U)) {
			duppage(childpid, i / PGSIZE);
		}

		// allocate exception stack
		r = sys_page_alloc(childpid, (void *)(UXSTACKTOP - PGSIZE), PTE_U | PTE_W | PTE_P);
  800fc6:	83 ec 04             	sub    $0x4,%esp
  800fc9:	6a 07                	push   $0x7
  800fcb:	68 00 f0 bf ee       	push   $0xeebff000
  800fd0:	ff 75 e4             	pushl  -0x1c(%ebp)
  800fd3:	e8 14 fc ff ff       	call   800bec <sys_page_alloc>
		if (r < 0) panic("fork, sys_page_alloc user exception stack error : %e\n", r);
  800fd8:	83 c4 10             	add    $0x10,%esp
  800fdb:	85 c0                	test   %eax,%eax
  800fdd:	79 15                	jns    800ff4 <fork+0x1ce>
  800fdf:	50                   	push   %eax
  800fe0:	68 40 26 80 00       	push   $0x802640
  800fe5:	68 94 00 00 00       	push   $0x94
  800fea:	68 d0 26 80 00       	push   $0x8026d0
  800fef:	e8 30 0d 00 00       	call   801d24 <_panic>

		// set user environment user page fault handler 
		extern void _pgfault_upcall(void);
		r = sys_env_set_pgfault_upcall(childpid, _pgfault_upcall);
  800ff4:	83 ec 08             	sub    $0x8,%esp
  800ff7:	68 d8 1d 80 00       	push   $0x801dd8
  800ffc:	ff 75 e4             	pushl  -0x1c(%ebp)
  800fff:	e8 9b fc ff ff       	call   800c9f <sys_env_set_pgfault_upcall>
		if (r < 0) panic("fork, set pgfault upcall fail : %e\n", r);
  801004:	83 c4 10             	add    $0x10,%esp
  801007:	85 c0                	test   %eax,%eax
  801009:	79 15                	jns    801020 <fork+0x1fa>
  80100b:	50                   	push   %eax
  80100c:	68 78 26 80 00       	push   $0x802678
  801011:	68 99 00 00 00       	push   $0x99
  801016:	68 d0 26 80 00       	push   $0x8026d0
  80101b:	e8 04 0d 00 00       	call   801d24 <_panic>
		r = sys_set_priority(childpid, num);
		if (r < 0) panic("fork, set priority error\n");
		*/

		// mark the child as runnable and return
		r = sys_env_set_status(childpid, ENV_RUNNABLE);
  801020:	83 ec 08             	sub    $0x8,%esp
  801023:	6a 02                	push   $0x2
  801025:	ff 75 e4             	pushl  -0x1c(%ebp)
  801028:	e8 2c fc ff ff       	call   800c59 <sys_env_set_status>
		if (r < 0) panic("fork, set child process to ENV_RUNNABLE error : %e\n", r);
  80102d:	83 c4 10             	add    $0x10,%esp
  801030:	85 c0                	test   %eax,%eax
  801032:	79 15                	jns    801049 <fork+0x223>
  801034:	50                   	push   %eax
  801035:	68 9c 26 80 00       	push   $0x80269c
  80103a:	68 a4 00 00 00       	push   $0xa4
  80103f:	68 d0 26 80 00       	push   $0x8026d0
  801044:	e8 db 0c 00 00       	call   801d24 <_panic>
		// cprintf("fork father ok!")
		return childpid;
	}

	panic("fork not implemented");
}
  801049:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80104c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80104f:	5b                   	pop    %ebx
  801050:	5e                   	pop    %esi
  801051:	5f                   	pop    %edi
  801052:	c9                   	leave  
  801053:	c3                   	ret    

00801054 <sfork>:

// Challenge!
int
sfork(void)
{
  801054:	55                   	push   %ebp
  801055:	89 e5                	mov    %esp,%ebp
  801057:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  80105a:	68 f8 26 80 00       	push   $0x8026f8
  80105f:	68 b1 00 00 00       	push   $0xb1
  801064:	68 d0 26 80 00       	push   $0x8026d0
  801069:	e8 b6 0c 00 00       	call   801d24 <_panic>
	...

00801070 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801070:	55                   	push   %ebp
  801071:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801073:	8b 45 08             	mov    0x8(%ebp),%eax
  801076:	05 00 00 00 30       	add    $0x30000000,%eax
  80107b:	c1 e8 0c             	shr    $0xc,%eax
}
  80107e:	c9                   	leave  
  80107f:	c3                   	ret    

00801080 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801080:	55                   	push   %ebp
  801081:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  801083:	ff 75 08             	pushl  0x8(%ebp)
  801086:	e8 e5 ff ff ff       	call   801070 <fd2num>
  80108b:	83 c4 04             	add    $0x4,%esp
  80108e:	05 20 00 0d 00       	add    $0xd0020,%eax
  801093:	c1 e0 0c             	shl    $0xc,%eax
}
  801096:	c9                   	leave  
  801097:	c3                   	ret    

00801098 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801098:	55                   	push   %ebp
  801099:	89 e5                	mov    %esp,%ebp
  80109b:	53                   	push   %ebx
  80109c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80109f:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  8010a4:	a8 01                	test   $0x1,%al
  8010a6:	74 34                	je     8010dc <fd_alloc+0x44>
  8010a8:	a1 00 00 74 ef       	mov    0xef740000,%eax
  8010ad:	a8 01                	test   $0x1,%al
  8010af:	74 32                	je     8010e3 <fd_alloc+0x4b>
  8010b1:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
  8010b6:	89 c1                	mov    %eax,%ecx
  8010b8:	89 c2                	mov    %eax,%edx
  8010ba:	c1 ea 16             	shr    $0x16,%edx
  8010bd:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8010c4:	f6 c2 01             	test   $0x1,%dl
  8010c7:	74 1f                	je     8010e8 <fd_alloc+0x50>
  8010c9:	89 c2                	mov    %eax,%edx
  8010cb:	c1 ea 0c             	shr    $0xc,%edx
  8010ce:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8010d5:	f6 c2 01             	test   $0x1,%dl
  8010d8:	75 17                	jne    8010f1 <fd_alloc+0x59>
  8010da:	eb 0c                	jmp    8010e8 <fd_alloc+0x50>
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  8010dc:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
  8010e1:	eb 05                	jmp    8010e8 <fd_alloc+0x50>
  8010e3:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
  8010e8:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  8010ea:	b8 00 00 00 00       	mov    $0x0,%eax
  8010ef:	eb 17                	jmp    801108 <fd_alloc+0x70>
  8010f1:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8010f6:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8010fb:	75 b9                	jne    8010b6 <fd_alloc+0x1e>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8010fd:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  801103:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801108:	5b                   	pop    %ebx
  801109:	c9                   	leave  
  80110a:	c3                   	ret    

0080110b <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80110b:	55                   	push   %ebp
  80110c:	89 e5                	mov    %esp,%ebp
  80110e:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801111:	83 f8 1f             	cmp    $0x1f,%eax
  801114:	77 36                	ja     80114c <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801116:	05 00 00 0d 00       	add    $0xd0000,%eax
  80111b:	c1 e0 0c             	shl    $0xc,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80111e:	89 c2                	mov    %eax,%edx
  801120:	c1 ea 16             	shr    $0x16,%edx
  801123:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80112a:	f6 c2 01             	test   $0x1,%dl
  80112d:	74 24                	je     801153 <fd_lookup+0x48>
  80112f:	89 c2                	mov    %eax,%edx
  801131:	c1 ea 0c             	shr    $0xc,%edx
  801134:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80113b:	f6 c2 01             	test   $0x1,%dl
  80113e:	74 1a                	je     80115a <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801140:	8b 55 0c             	mov    0xc(%ebp),%edx
  801143:	89 02                	mov    %eax,(%edx)
	return 0;
  801145:	b8 00 00 00 00       	mov    $0x0,%eax
  80114a:	eb 13                	jmp    80115f <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80114c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801151:	eb 0c                	jmp    80115f <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801153:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801158:	eb 05                	jmp    80115f <fd_lookup+0x54>
  80115a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  80115f:	c9                   	leave  
  801160:	c3                   	ret    

00801161 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801161:	55                   	push   %ebp
  801162:	89 e5                	mov    %esp,%ebp
  801164:	53                   	push   %ebx
  801165:	83 ec 04             	sub    $0x4,%esp
  801168:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80116b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  80116e:	39 0d 04 30 80 00    	cmp    %ecx,0x803004
  801174:	74 0d                	je     801183 <dev_lookup+0x22>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801176:	b8 00 00 00 00       	mov    $0x0,%eax
  80117b:	eb 14                	jmp    801191 <dev_lookup+0x30>
		if (devtab[i]->dev_id == dev_id) {
  80117d:	39 0a                	cmp    %ecx,(%edx)
  80117f:	75 10                	jne    801191 <dev_lookup+0x30>
  801181:	eb 05                	jmp    801188 <dev_lookup+0x27>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801183:	ba 04 30 80 00       	mov    $0x803004,%edx
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
  801188:	89 13                	mov    %edx,(%ebx)
			return 0;
  80118a:	b8 00 00 00 00       	mov    $0x0,%eax
  80118f:	eb 31                	jmp    8011c2 <dev_lookup+0x61>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801191:	40                   	inc    %eax
  801192:	8b 14 85 8c 27 80 00 	mov    0x80278c(,%eax,4),%edx
  801199:	85 d2                	test   %edx,%edx
  80119b:	75 e0                	jne    80117d <dev_lookup+0x1c>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80119d:	a1 04 40 80 00       	mov    0x804004,%eax
  8011a2:	8b 40 48             	mov    0x48(%eax),%eax
  8011a5:	83 ec 04             	sub    $0x4,%esp
  8011a8:	51                   	push   %ecx
  8011a9:	50                   	push   %eax
  8011aa:	68 10 27 80 00       	push   $0x802710
  8011af:	e8 00 f0 ff ff       	call   8001b4 <cprintf>
	*dev = 0;
  8011b4:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  8011ba:	83 c4 10             	add    $0x10,%esp
  8011bd:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8011c2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8011c5:	c9                   	leave  
  8011c6:	c3                   	ret    

008011c7 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8011c7:	55                   	push   %ebp
  8011c8:	89 e5                	mov    %esp,%ebp
  8011ca:	56                   	push   %esi
  8011cb:	53                   	push   %ebx
  8011cc:	83 ec 20             	sub    $0x20,%esp
  8011cf:	8b 75 08             	mov    0x8(%ebp),%esi
  8011d2:	8a 45 0c             	mov    0xc(%ebp),%al
  8011d5:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8011d8:	56                   	push   %esi
  8011d9:	e8 92 fe ff ff       	call   801070 <fd2num>
  8011de:	8d 55 f4             	lea    -0xc(%ebp),%edx
  8011e1:	89 14 24             	mov    %edx,(%esp)
  8011e4:	50                   	push   %eax
  8011e5:	e8 21 ff ff ff       	call   80110b <fd_lookup>
  8011ea:	89 c3                	mov    %eax,%ebx
  8011ec:	83 c4 08             	add    $0x8,%esp
  8011ef:	85 c0                	test   %eax,%eax
  8011f1:	78 05                	js     8011f8 <fd_close+0x31>
	    || fd != fd2)
  8011f3:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8011f6:	74 0d                	je     801205 <fd_close+0x3e>
		return (must_exist ? r : 0);
  8011f8:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  8011fc:	75 48                	jne    801246 <fd_close+0x7f>
  8011fe:	bb 00 00 00 00       	mov    $0x0,%ebx
  801203:	eb 41                	jmp    801246 <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801205:	83 ec 08             	sub    $0x8,%esp
  801208:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80120b:	50                   	push   %eax
  80120c:	ff 36                	pushl  (%esi)
  80120e:	e8 4e ff ff ff       	call   801161 <dev_lookup>
  801213:	89 c3                	mov    %eax,%ebx
  801215:	83 c4 10             	add    $0x10,%esp
  801218:	85 c0                	test   %eax,%eax
  80121a:	78 1c                	js     801238 <fd_close+0x71>
		if (dev->dev_close)
  80121c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80121f:	8b 40 10             	mov    0x10(%eax),%eax
  801222:	85 c0                	test   %eax,%eax
  801224:	74 0d                	je     801233 <fd_close+0x6c>
			r = (*dev->dev_close)(fd);
  801226:	83 ec 0c             	sub    $0xc,%esp
  801229:	56                   	push   %esi
  80122a:	ff d0                	call   *%eax
  80122c:	89 c3                	mov    %eax,%ebx
  80122e:	83 c4 10             	add    $0x10,%esp
  801231:	eb 05                	jmp    801238 <fd_close+0x71>
		else
			r = 0;
  801233:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801238:	83 ec 08             	sub    $0x8,%esp
  80123b:	56                   	push   %esi
  80123c:	6a 00                	push   $0x0
  80123e:	e8 f3 f9 ff ff       	call   800c36 <sys_page_unmap>
	return r;
  801243:	83 c4 10             	add    $0x10,%esp
}
  801246:	89 d8                	mov    %ebx,%eax
  801248:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80124b:	5b                   	pop    %ebx
  80124c:	5e                   	pop    %esi
  80124d:	c9                   	leave  
  80124e:	c3                   	ret    

0080124f <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80124f:	55                   	push   %ebp
  801250:	89 e5                	mov    %esp,%ebp
  801252:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801255:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801258:	50                   	push   %eax
  801259:	ff 75 08             	pushl  0x8(%ebp)
  80125c:	e8 aa fe ff ff       	call   80110b <fd_lookup>
  801261:	83 c4 08             	add    $0x8,%esp
  801264:	85 c0                	test   %eax,%eax
  801266:	78 10                	js     801278 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801268:	83 ec 08             	sub    $0x8,%esp
  80126b:	6a 01                	push   $0x1
  80126d:	ff 75 f4             	pushl  -0xc(%ebp)
  801270:	e8 52 ff ff ff       	call   8011c7 <fd_close>
  801275:	83 c4 10             	add    $0x10,%esp
}
  801278:	c9                   	leave  
  801279:	c3                   	ret    

0080127a <close_all>:

void
close_all(void)
{
  80127a:	55                   	push   %ebp
  80127b:	89 e5                	mov    %esp,%ebp
  80127d:	53                   	push   %ebx
  80127e:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801281:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801286:	83 ec 0c             	sub    $0xc,%esp
  801289:	53                   	push   %ebx
  80128a:	e8 c0 ff ff ff       	call   80124f <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80128f:	43                   	inc    %ebx
  801290:	83 c4 10             	add    $0x10,%esp
  801293:	83 fb 20             	cmp    $0x20,%ebx
  801296:	75 ee                	jne    801286 <close_all+0xc>
		close(i);
}
  801298:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80129b:	c9                   	leave  
  80129c:	c3                   	ret    

0080129d <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80129d:	55                   	push   %ebp
  80129e:	89 e5                	mov    %esp,%ebp
  8012a0:	57                   	push   %edi
  8012a1:	56                   	push   %esi
  8012a2:	53                   	push   %ebx
  8012a3:	83 ec 2c             	sub    $0x2c,%esp
  8012a6:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8012a9:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8012ac:	50                   	push   %eax
  8012ad:	ff 75 08             	pushl  0x8(%ebp)
  8012b0:	e8 56 fe ff ff       	call   80110b <fd_lookup>
  8012b5:	89 c3                	mov    %eax,%ebx
  8012b7:	83 c4 08             	add    $0x8,%esp
  8012ba:	85 c0                	test   %eax,%eax
  8012bc:	0f 88 c0 00 00 00    	js     801382 <dup+0xe5>
		return r;
	close(newfdnum);
  8012c2:	83 ec 0c             	sub    $0xc,%esp
  8012c5:	57                   	push   %edi
  8012c6:	e8 84 ff ff ff       	call   80124f <close>

	newfd = INDEX2FD(newfdnum);
  8012cb:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  8012d1:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  8012d4:	83 c4 04             	add    $0x4,%esp
  8012d7:	ff 75 e4             	pushl  -0x1c(%ebp)
  8012da:	e8 a1 fd ff ff       	call   801080 <fd2data>
  8012df:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  8012e1:	89 34 24             	mov    %esi,(%esp)
  8012e4:	e8 97 fd ff ff       	call   801080 <fd2data>
  8012e9:	83 c4 10             	add    $0x10,%esp
  8012ec:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8012ef:	89 d8                	mov    %ebx,%eax
  8012f1:	c1 e8 16             	shr    $0x16,%eax
  8012f4:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8012fb:	a8 01                	test   $0x1,%al
  8012fd:	74 37                	je     801336 <dup+0x99>
  8012ff:	89 d8                	mov    %ebx,%eax
  801301:	c1 e8 0c             	shr    $0xc,%eax
  801304:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80130b:	f6 c2 01             	test   $0x1,%dl
  80130e:	74 26                	je     801336 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801310:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801317:	83 ec 0c             	sub    $0xc,%esp
  80131a:	25 07 0e 00 00       	and    $0xe07,%eax
  80131f:	50                   	push   %eax
  801320:	ff 75 d4             	pushl  -0x2c(%ebp)
  801323:	6a 00                	push   $0x0
  801325:	53                   	push   %ebx
  801326:	6a 00                	push   $0x0
  801328:	e8 e3 f8 ff ff       	call   800c10 <sys_page_map>
  80132d:	89 c3                	mov    %eax,%ebx
  80132f:	83 c4 20             	add    $0x20,%esp
  801332:	85 c0                	test   %eax,%eax
  801334:	78 2d                	js     801363 <dup+0xc6>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801336:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801339:	89 c2                	mov    %eax,%edx
  80133b:	c1 ea 0c             	shr    $0xc,%edx
  80133e:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801345:	83 ec 0c             	sub    $0xc,%esp
  801348:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  80134e:	52                   	push   %edx
  80134f:	56                   	push   %esi
  801350:	6a 00                	push   $0x0
  801352:	50                   	push   %eax
  801353:	6a 00                	push   $0x0
  801355:	e8 b6 f8 ff ff       	call   800c10 <sys_page_map>
  80135a:	89 c3                	mov    %eax,%ebx
  80135c:	83 c4 20             	add    $0x20,%esp
  80135f:	85 c0                	test   %eax,%eax
  801361:	79 1d                	jns    801380 <dup+0xe3>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801363:	83 ec 08             	sub    $0x8,%esp
  801366:	56                   	push   %esi
  801367:	6a 00                	push   $0x0
  801369:	e8 c8 f8 ff ff       	call   800c36 <sys_page_unmap>
	sys_page_unmap(0, nva);
  80136e:	83 c4 08             	add    $0x8,%esp
  801371:	ff 75 d4             	pushl  -0x2c(%ebp)
  801374:	6a 00                	push   $0x0
  801376:	e8 bb f8 ff ff       	call   800c36 <sys_page_unmap>
	return r;
  80137b:	83 c4 10             	add    $0x10,%esp
  80137e:	eb 02                	jmp    801382 <dup+0xe5>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  801380:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  801382:	89 d8                	mov    %ebx,%eax
  801384:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801387:	5b                   	pop    %ebx
  801388:	5e                   	pop    %esi
  801389:	5f                   	pop    %edi
  80138a:	c9                   	leave  
  80138b:	c3                   	ret    

0080138c <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80138c:	55                   	push   %ebp
  80138d:	89 e5                	mov    %esp,%ebp
  80138f:	53                   	push   %ebx
  801390:	83 ec 14             	sub    $0x14,%esp
  801393:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801396:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801399:	50                   	push   %eax
  80139a:	53                   	push   %ebx
  80139b:	e8 6b fd ff ff       	call   80110b <fd_lookup>
  8013a0:	83 c4 08             	add    $0x8,%esp
  8013a3:	85 c0                	test   %eax,%eax
  8013a5:	78 67                	js     80140e <read+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013a7:	83 ec 08             	sub    $0x8,%esp
  8013aa:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013ad:	50                   	push   %eax
  8013ae:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013b1:	ff 30                	pushl  (%eax)
  8013b3:	e8 a9 fd ff ff       	call   801161 <dev_lookup>
  8013b8:	83 c4 10             	add    $0x10,%esp
  8013bb:	85 c0                	test   %eax,%eax
  8013bd:	78 4f                	js     80140e <read+0x82>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8013bf:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013c2:	8b 50 08             	mov    0x8(%eax),%edx
  8013c5:	83 e2 03             	and    $0x3,%edx
  8013c8:	83 fa 01             	cmp    $0x1,%edx
  8013cb:	75 21                	jne    8013ee <read+0x62>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8013cd:	a1 04 40 80 00       	mov    0x804004,%eax
  8013d2:	8b 40 48             	mov    0x48(%eax),%eax
  8013d5:	83 ec 04             	sub    $0x4,%esp
  8013d8:	53                   	push   %ebx
  8013d9:	50                   	push   %eax
  8013da:	68 51 27 80 00       	push   $0x802751
  8013df:	e8 d0 ed ff ff       	call   8001b4 <cprintf>
		return -E_INVAL;
  8013e4:	83 c4 10             	add    $0x10,%esp
  8013e7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8013ec:	eb 20                	jmp    80140e <read+0x82>
	}
	if (!dev->dev_read)
  8013ee:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8013f1:	8b 52 08             	mov    0x8(%edx),%edx
  8013f4:	85 d2                	test   %edx,%edx
  8013f6:	74 11                	je     801409 <read+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8013f8:	83 ec 04             	sub    $0x4,%esp
  8013fb:	ff 75 10             	pushl  0x10(%ebp)
  8013fe:	ff 75 0c             	pushl  0xc(%ebp)
  801401:	50                   	push   %eax
  801402:	ff d2                	call   *%edx
  801404:	83 c4 10             	add    $0x10,%esp
  801407:	eb 05                	jmp    80140e <read+0x82>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801409:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  80140e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801411:	c9                   	leave  
  801412:	c3                   	ret    

00801413 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801413:	55                   	push   %ebp
  801414:	89 e5                	mov    %esp,%ebp
  801416:	57                   	push   %edi
  801417:	56                   	push   %esi
  801418:	53                   	push   %ebx
  801419:	83 ec 0c             	sub    $0xc,%esp
  80141c:	8b 7d 08             	mov    0x8(%ebp),%edi
  80141f:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801422:	85 f6                	test   %esi,%esi
  801424:	74 31                	je     801457 <readn+0x44>
  801426:	b8 00 00 00 00       	mov    $0x0,%eax
  80142b:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = read(fdnum, (char*)buf + tot, n - tot);
  801430:	83 ec 04             	sub    $0x4,%esp
  801433:	89 f2                	mov    %esi,%edx
  801435:	29 c2                	sub    %eax,%edx
  801437:	52                   	push   %edx
  801438:	03 45 0c             	add    0xc(%ebp),%eax
  80143b:	50                   	push   %eax
  80143c:	57                   	push   %edi
  80143d:	e8 4a ff ff ff       	call   80138c <read>
		if (m < 0)
  801442:	83 c4 10             	add    $0x10,%esp
  801445:	85 c0                	test   %eax,%eax
  801447:	78 17                	js     801460 <readn+0x4d>
			return m;
		if (m == 0)
  801449:	85 c0                	test   %eax,%eax
  80144b:	74 11                	je     80145e <readn+0x4b>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80144d:	01 c3                	add    %eax,%ebx
  80144f:	89 d8                	mov    %ebx,%eax
  801451:	39 f3                	cmp    %esi,%ebx
  801453:	72 db                	jb     801430 <readn+0x1d>
  801455:	eb 09                	jmp    801460 <readn+0x4d>
  801457:	b8 00 00 00 00       	mov    $0x0,%eax
  80145c:	eb 02                	jmp    801460 <readn+0x4d>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  80145e:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  801460:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801463:	5b                   	pop    %ebx
  801464:	5e                   	pop    %esi
  801465:	5f                   	pop    %edi
  801466:	c9                   	leave  
  801467:	c3                   	ret    

00801468 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801468:	55                   	push   %ebp
  801469:	89 e5                	mov    %esp,%ebp
  80146b:	53                   	push   %ebx
  80146c:	83 ec 14             	sub    $0x14,%esp
  80146f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801472:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801475:	50                   	push   %eax
  801476:	53                   	push   %ebx
  801477:	e8 8f fc ff ff       	call   80110b <fd_lookup>
  80147c:	83 c4 08             	add    $0x8,%esp
  80147f:	85 c0                	test   %eax,%eax
  801481:	78 62                	js     8014e5 <write+0x7d>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801483:	83 ec 08             	sub    $0x8,%esp
  801486:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801489:	50                   	push   %eax
  80148a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80148d:	ff 30                	pushl  (%eax)
  80148f:	e8 cd fc ff ff       	call   801161 <dev_lookup>
  801494:	83 c4 10             	add    $0x10,%esp
  801497:	85 c0                	test   %eax,%eax
  801499:	78 4a                	js     8014e5 <write+0x7d>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80149b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80149e:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8014a2:	75 21                	jne    8014c5 <write+0x5d>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8014a4:	a1 04 40 80 00       	mov    0x804004,%eax
  8014a9:	8b 40 48             	mov    0x48(%eax),%eax
  8014ac:	83 ec 04             	sub    $0x4,%esp
  8014af:	53                   	push   %ebx
  8014b0:	50                   	push   %eax
  8014b1:	68 6d 27 80 00       	push   $0x80276d
  8014b6:	e8 f9 ec ff ff       	call   8001b4 <cprintf>
		return -E_INVAL;
  8014bb:	83 c4 10             	add    $0x10,%esp
  8014be:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8014c3:	eb 20                	jmp    8014e5 <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8014c5:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8014c8:	8b 52 0c             	mov    0xc(%edx),%edx
  8014cb:	85 d2                	test   %edx,%edx
  8014cd:	74 11                	je     8014e0 <write+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8014cf:	83 ec 04             	sub    $0x4,%esp
  8014d2:	ff 75 10             	pushl  0x10(%ebp)
  8014d5:	ff 75 0c             	pushl  0xc(%ebp)
  8014d8:	50                   	push   %eax
  8014d9:	ff d2                	call   *%edx
  8014db:	83 c4 10             	add    $0x10,%esp
  8014de:	eb 05                	jmp    8014e5 <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8014e0:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  8014e5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014e8:	c9                   	leave  
  8014e9:	c3                   	ret    

008014ea <seek>:

int
seek(int fdnum, off_t offset)
{
  8014ea:	55                   	push   %ebp
  8014eb:	89 e5                	mov    %esp,%ebp
  8014ed:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8014f0:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8014f3:	50                   	push   %eax
  8014f4:	ff 75 08             	pushl  0x8(%ebp)
  8014f7:	e8 0f fc ff ff       	call   80110b <fd_lookup>
  8014fc:	83 c4 08             	add    $0x8,%esp
  8014ff:	85 c0                	test   %eax,%eax
  801501:	78 0e                	js     801511 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801503:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801506:	8b 55 0c             	mov    0xc(%ebp),%edx
  801509:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80150c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801511:	c9                   	leave  
  801512:	c3                   	ret    

00801513 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801513:	55                   	push   %ebp
  801514:	89 e5                	mov    %esp,%ebp
  801516:	53                   	push   %ebx
  801517:	83 ec 14             	sub    $0x14,%esp
  80151a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80151d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801520:	50                   	push   %eax
  801521:	53                   	push   %ebx
  801522:	e8 e4 fb ff ff       	call   80110b <fd_lookup>
  801527:	83 c4 08             	add    $0x8,%esp
  80152a:	85 c0                	test   %eax,%eax
  80152c:	78 5f                	js     80158d <ftruncate+0x7a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80152e:	83 ec 08             	sub    $0x8,%esp
  801531:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801534:	50                   	push   %eax
  801535:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801538:	ff 30                	pushl  (%eax)
  80153a:	e8 22 fc ff ff       	call   801161 <dev_lookup>
  80153f:	83 c4 10             	add    $0x10,%esp
  801542:	85 c0                	test   %eax,%eax
  801544:	78 47                	js     80158d <ftruncate+0x7a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801546:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801549:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80154d:	75 21                	jne    801570 <ftruncate+0x5d>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80154f:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801554:	8b 40 48             	mov    0x48(%eax),%eax
  801557:	83 ec 04             	sub    $0x4,%esp
  80155a:	53                   	push   %ebx
  80155b:	50                   	push   %eax
  80155c:	68 30 27 80 00       	push   $0x802730
  801561:	e8 4e ec ff ff       	call   8001b4 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801566:	83 c4 10             	add    $0x10,%esp
  801569:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80156e:	eb 1d                	jmp    80158d <ftruncate+0x7a>
	}
	if (!dev->dev_trunc)
  801570:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801573:	8b 52 18             	mov    0x18(%edx),%edx
  801576:	85 d2                	test   %edx,%edx
  801578:	74 0e                	je     801588 <ftruncate+0x75>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80157a:	83 ec 08             	sub    $0x8,%esp
  80157d:	ff 75 0c             	pushl  0xc(%ebp)
  801580:	50                   	push   %eax
  801581:	ff d2                	call   *%edx
  801583:	83 c4 10             	add    $0x10,%esp
  801586:	eb 05                	jmp    80158d <ftruncate+0x7a>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801588:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  80158d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801590:	c9                   	leave  
  801591:	c3                   	ret    

00801592 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801592:	55                   	push   %ebp
  801593:	89 e5                	mov    %esp,%ebp
  801595:	53                   	push   %ebx
  801596:	83 ec 14             	sub    $0x14,%esp
  801599:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80159c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80159f:	50                   	push   %eax
  8015a0:	ff 75 08             	pushl  0x8(%ebp)
  8015a3:	e8 63 fb ff ff       	call   80110b <fd_lookup>
  8015a8:	83 c4 08             	add    $0x8,%esp
  8015ab:	85 c0                	test   %eax,%eax
  8015ad:	78 52                	js     801601 <fstat+0x6f>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015af:	83 ec 08             	sub    $0x8,%esp
  8015b2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015b5:	50                   	push   %eax
  8015b6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015b9:	ff 30                	pushl  (%eax)
  8015bb:	e8 a1 fb ff ff       	call   801161 <dev_lookup>
  8015c0:	83 c4 10             	add    $0x10,%esp
  8015c3:	85 c0                	test   %eax,%eax
  8015c5:	78 3a                	js     801601 <fstat+0x6f>
		return r;
	if (!dev->dev_stat)
  8015c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015ca:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8015ce:	74 2c                	je     8015fc <fstat+0x6a>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8015d0:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8015d3:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8015da:	00 00 00 
	stat->st_isdir = 0;
  8015dd:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8015e4:	00 00 00 
	stat->st_dev = dev;
  8015e7:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8015ed:	83 ec 08             	sub    $0x8,%esp
  8015f0:	53                   	push   %ebx
  8015f1:	ff 75 f0             	pushl  -0x10(%ebp)
  8015f4:	ff 50 14             	call   *0x14(%eax)
  8015f7:	83 c4 10             	add    $0x10,%esp
  8015fa:	eb 05                	jmp    801601 <fstat+0x6f>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8015fc:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801601:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801604:	c9                   	leave  
  801605:	c3                   	ret    

00801606 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801606:	55                   	push   %ebp
  801607:	89 e5                	mov    %esp,%ebp
  801609:	56                   	push   %esi
  80160a:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80160b:	83 ec 08             	sub    $0x8,%esp
  80160e:	6a 00                	push   $0x0
  801610:	ff 75 08             	pushl  0x8(%ebp)
  801613:	e8 78 01 00 00       	call   801790 <open>
  801618:	89 c3                	mov    %eax,%ebx
  80161a:	83 c4 10             	add    $0x10,%esp
  80161d:	85 c0                	test   %eax,%eax
  80161f:	78 1b                	js     80163c <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801621:	83 ec 08             	sub    $0x8,%esp
  801624:	ff 75 0c             	pushl  0xc(%ebp)
  801627:	50                   	push   %eax
  801628:	e8 65 ff ff ff       	call   801592 <fstat>
  80162d:	89 c6                	mov    %eax,%esi
	close(fd);
  80162f:	89 1c 24             	mov    %ebx,(%esp)
  801632:	e8 18 fc ff ff       	call   80124f <close>
	return r;
  801637:	83 c4 10             	add    $0x10,%esp
  80163a:	89 f3                	mov    %esi,%ebx
}
  80163c:	89 d8                	mov    %ebx,%eax
  80163e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801641:	5b                   	pop    %ebx
  801642:	5e                   	pop    %esi
  801643:	c9                   	leave  
  801644:	c3                   	ret    
  801645:	00 00                	add    %al,(%eax)
	...

00801648 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801648:	55                   	push   %ebp
  801649:	89 e5                	mov    %esp,%ebp
  80164b:	56                   	push   %esi
  80164c:	53                   	push   %ebx
  80164d:	89 c3                	mov    %eax,%ebx
  80164f:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  801651:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801658:	75 12                	jne    80166c <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80165a:	83 ec 0c             	sub    $0xc,%esp
  80165d:	6a 01                	push   $0x1
  80165f:	e8 66 08 00 00       	call   801eca <ipc_find_env>
  801664:	a3 00 40 80 00       	mov    %eax,0x804000
  801669:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80166c:	6a 07                	push   $0x7
  80166e:	68 00 50 80 00       	push   $0x805000
  801673:	53                   	push   %ebx
  801674:	ff 35 00 40 80 00    	pushl  0x804000
  80167a:	e8 f6 07 00 00       	call   801e75 <ipc_send>
	
	return ipc_recv(NULL, dstva, NULL);
  80167f:	83 c4 0c             	add    $0xc,%esp
  801682:	6a 00                	push   $0x0
  801684:	56                   	push   %esi
  801685:	6a 00                	push   $0x0
  801687:	e8 74 07 00 00       	call   801e00 <ipc_recv>
}
  80168c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80168f:	5b                   	pop    %ebx
  801690:	5e                   	pop    %esi
  801691:	c9                   	leave  
  801692:	c3                   	ret    

00801693 <devfile_stat>:
}


static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801693:	55                   	push   %ebp
  801694:	89 e5                	mov    %esp,%ebp
  801696:	53                   	push   %ebx
  801697:	83 ec 04             	sub    $0x4,%esp
  80169a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80169d:	8b 45 08             	mov    0x8(%ebp),%eax
  8016a0:	8b 40 0c             	mov    0xc(%eax),%eax
  8016a3:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0) {
  8016a8:	ba 00 00 00 00       	mov    $0x0,%edx
  8016ad:	b8 05 00 00 00       	mov    $0x5,%eax
  8016b2:	e8 91 ff ff ff       	call   801648 <fsipc>
  8016b7:	85 c0                	test   %eax,%eax
  8016b9:	78 2c                	js     8016e7 <devfile_stat+0x54>
		return r;
	}
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8016bb:	83 ec 08             	sub    $0x8,%esp
  8016be:	68 00 50 80 00       	push   $0x805000
  8016c3:	53                   	push   %ebx
  8016c4:	e8 a1 f0 ff ff       	call   80076a <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8016c9:	a1 80 50 80 00       	mov    0x805080,%eax
  8016ce:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8016d4:	a1 84 50 80 00       	mov    0x805084,%eax
  8016d9:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8016df:	83 c4 10             	add    $0x10,%esp
  8016e2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8016e7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016ea:	c9                   	leave  
  8016eb:	c3                   	ret    

008016ec <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8016ec:	55                   	push   %ebp
  8016ed:	89 e5                	mov    %esp,%ebp
  8016ef:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8016f2:	8b 45 08             	mov    0x8(%ebp),%eax
  8016f5:	8b 40 0c             	mov    0xc(%eax),%eax
  8016f8:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8016fd:	ba 00 00 00 00       	mov    $0x0,%edx
  801702:	b8 06 00 00 00       	mov    $0x6,%eax
  801707:	e8 3c ff ff ff       	call   801648 <fsipc>
}
  80170c:	c9                   	leave  
  80170d:	c3                   	ret    

0080170e <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  80170e:	55                   	push   %ebp
  80170f:	89 e5                	mov    %esp,%ebp
  801711:	56                   	push   %esi
  801712:	53                   	push   %ebx
  801713:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801716:	8b 45 08             	mov    0x8(%ebp),%eax
  801719:	8b 40 0c             	mov    0xc(%eax),%eax
  80171c:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801721:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801727:	ba 00 00 00 00       	mov    $0x0,%edx
  80172c:	b8 03 00 00 00       	mov    $0x3,%eax
  801731:	e8 12 ff ff ff       	call   801648 <fsipc>
  801736:	89 c3                	mov    %eax,%ebx
  801738:	85 c0                	test   %eax,%eax
  80173a:	78 4b                	js     801787 <devfile_read+0x79>
		return r;
	assert(r <= n);
  80173c:	39 c6                	cmp    %eax,%esi
  80173e:	73 16                	jae    801756 <devfile_read+0x48>
  801740:	68 9c 27 80 00       	push   $0x80279c
  801745:	68 a3 27 80 00       	push   $0x8027a3
  80174a:	6a 7d                	push   $0x7d
  80174c:	68 b8 27 80 00       	push   $0x8027b8
  801751:	e8 ce 05 00 00       	call   801d24 <_panic>
	assert(r <= PGSIZE);
  801756:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80175b:	7e 16                	jle    801773 <devfile_read+0x65>
  80175d:	68 c3 27 80 00       	push   $0x8027c3
  801762:	68 a3 27 80 00       	push   $0x8027a3
  801767:	6a 7e                	push   $0x7e
  801769:	68 b8 27 80 00       	push   $0x8027b8
  80176e:	e8 b1 05 00 00       	call   801d24 <_panic>
	memmove(buf, &fsipcbuf, r);
  801773:	83 ec 04             	sub    $0x4,%esp
  801776:	50                   	push   %eax
  801777:	68 00 50 80 00       	push   $0x805000
  80177c:	ff 75 0c             	pushl  0xc(%ebp)
  80177f:	e8 a7 f1 ff ff       	call   80092b <memmove>
	return r;
  801784:	83 c4 10             	add    $0x10,%esp
}
  801787:	89 d8                	mov    %ebx,%eax
  801789:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80178c:	5b                   	pop    %ebx
  80178d:	5e                   	pop    %esi
  80178e:	c9                   	leave  
  80178f:	c3                   	ret    

00801790 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801790:	55                   	push   %ebp
  801791:	89 e5                	mov    %esp,%ebp
  801793:	56                   	push   %esi
  801794:	53                   	push   %ebx
  801795:	83 ec 1c             	sub    $0x1c,%esp
  801798:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  80179b:	56                   	push   %esi
  80179c:	e8 77 ef ff ff       	call   800718 <strlen>
  8017a1:	83 c4 10             	add    $0x10,%esp
  8017a4:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8017a9:	7f 65                	jg     801810 <open+0x80>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8017ab:	83 ec 0c             	sub    $0xc,%esp
  8017ae:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017b1:	50                   	push   %eax
  8017b2:	e8 e1 f8 ff ff       	call   801098 <fd_alloc>
  8017b7:	89 c3                	mov    %eax,%ebx
  8017b9:	83 c4 10             	add    $0x10,%esp
  8017bc:	85 c0                	test   %eax,%eax
  8017be:	78 55                	js     801815 <open+0x85>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8017c0:	83 ec 08             	sub    $0x8,%esp
  8017c3:	56                   	push   %esi
  8017c4:	68 00 50 80 00       	push   $0x805000
  8017c9:	e8 9c ef ff ff       	call   80076a <strcpy>
	fsipcbuf.open.req_omode = mode;
  8017ce:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017d1:	a3 00 54 80 00       	mov    %eax,0x805400



	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8017d6:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8017d9:	b8 01 00 00 00       	mov    $0x1,%eax
  8017de:	e8 65 fe ff ff       	call   801648 <fsipc>
  8017e3:	89 c3                	mov    %eax,%ebx
  8017e5:	83 c4 10             	add    $0x10,%esp
  8017e8:	85 c0                	test   %eax,%eax
  8017ea:	79 12                	jns    8017fe <open+0x6e>
		fd_close(fd, 0);
  8017ec:	83 ec 08             	sub    $0x8,%esp
  8017ef:	6a 00                	push   $0x0
  8017f1:	ff 75 f4             	pushl  -0xc(%ebp)
  8017f4:	e8 ce f9 ff ff       	call   8011c7 <fd_close>
		return r;
  8017f9:	83 c4 10             	add    $0x10,%esp
  8017fc:	eb 17                	jmp    801815 <open+0x85>
	}

	return fd2num(fd);
  8017fe:	83 ec 0c             	sub    $0xc,%esp
  801801:	ff 75 f4             	pushl  -0xc(%ebp)
  801804:	e8 67 f8 ff ff       	call   801070 <fd2num>
  801809:	89 c3                	mov    %eax,%ebx
  80180b:	83 c4 10             	add    $0x10,%esp
  80180e:	eb 05                	jmp    801815 <open+0x85>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801810:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801815:	89 d8                	mov    %ebx,%eax
  801817:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80181a:	5b                   	pop    %ebx
  80181b:	5e                   	pop    %esi
  80181c:	c9                   	leave  
  80181d:	c3                   	ret    
	...

00801820 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801820:	55                   	push   %ebp
  801821:	89 e5                	mov    %esp,%ebp
  801823:	56                   	push   %esi
  801824:	53                   	push   %ebx
  801825:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801828:	83 ec 0c             	sub    $0xc,%esp
  80182b:	ff 75 08             	pushl  0x8(%ebp)
  80182e:	e8 4d f8 ff ff       	call   801080 <fd2data>
  801833:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  801835:	83 c4 08             	add    $0x8,%esp
  801838:	68 cf 27 80 00       	push   $0x8027cf
  80183d:	56                   	push   %esi
  80183e:	e8 27 ef ff ff       	call   80076a <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801843:	8b 43 04             	mov    0x4(%ebx),%eax
  801846:	2b 03                	sub    (%ebx),%eax
  801848:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  80184e:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  801855:	00 00 00 
	stat->st_dev = &devpipe;
  801858:	c7 86 88 00 00 00 20 	movl   $0x803020,0x88(%esi)
  80185f:	30 80 00 
	return 0;
}
  801862:	b8 00 00 00 00       	mov    $0x0,%eax
  801867:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80186a:	5b                   	pop    %ebx
  80186b:	5e                   	pop    %esi
  80186c:	c9                   	leave  
  80186d:	c3                   	ret    

0080186e <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  80186e:	55                   	push   %ebp
  80186f:	89 e5                	mov    %esp,%ebp
  801871:	53                   	push   %ebx
  801872:	83 ec 0c             	sub    $0xc,%esp
  801875:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801878:	53                   	push   %ebx
  801879:	6a 00                	push   $0x0
  80187b:	e8 b6 f3 ff ff       	call   800c36 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801880:	89 1c 24             	mov    %ebx,(%esp)
  801883:	e8 f8 f7 ff ff       	call   801080 <fd2data>
  801888:	83 c4 08             	add    $0x8,%esp
  80188b:	50                   	push   %eax
  80188c:	6a 00                	push   $0x0
  80188e:	e8 a3 f3 ff ff       	call   800c36 <sys_page_unmap>
}
  801893:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801896:	c9                   	leave  
  801897:	c3                   	ret    

00801898 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801898:	55                   	push   %ebp
  801899:	89 e5                	mov    %esp,%ebp
  80189b:	57                   	push   %edi
  80189c:	56                   	push   %esi
  80189d:	53                   	push   %ebx
  80189e:	83 ec 1c             	sub    $0x1c,%esp
  8018a1:	89 c7                	mov    %eax,%edi
  8018a3:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8018a6:	a1 04 40 80 00       	mov    0x804004,%eax
  8018ab:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  8018ae:	83 ec 0c             	sub    $0xc,%esp
  8018b1:	57                   	push   %edi
  8018b2:	e8 71 06 00 00       	call   801f28 <pageref>
  8018b7:	89 c6                	mov    %eax,%esi
  8018b9:	83 c4 04             	add    $0x4,%esp
  8018bc:	ff 75 e4             	pushl  -0x1c(%ebp)
  8018bf:	e8 64 06 00 00       	call   801f28 <pageref>
  8018c4:	83 c4 10             	add    $0x10,%esp
  8018c7:	39 c6                	cmp    %eax,%esi
  8018c9:	0f 94 c0             	sete   %al
  8018cc:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  8018cf:	8b 15 04 40 80 00    	mov    0x804004,%edx
  8018d5:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  8018d8:	39 cb                	cmp    %ecx,%ebx
  8018da:	75 08                	jne    8018e4 <_pipeisclosed+0x4c>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  8018dc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8018df:	5b                   	pop    %ebx
  8018e0:	5e                   	pop    %esi
  8018e1:	5f                   	pop    %edi
  8018e2:	c9                   	leave  
  8018e3:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  8018e4:	83 f8 01             	cmp    $0x1,%eax
  8018e7:	75 bd                	jne    8018a6 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8018e9:	8b 42 58             	mov    0x58(%edx),%eax
  8018ec:	6a 01                	push   $0x1
  8018ee:	50                   	push   %eax
  8018ef:	53                   	push   %ebx
  8018f0:	68 d6 27 80 00       	push   $0x8027d6
  8018f5:	e8 ba e8 ff ff       	call   8001b4 <cprintf>
  8018fa:	83 c4 10             	add    $0x10,%esp
  8018fd:	eb a7                	jmp    8018a6 <_pipeisclosed+0xe>

008018ff <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8018ff:	55                   	push   %ebp
  801900:	89 e5                	mov    %esp,%ebp
  801902:	57                   	push   %edi
  801903:	56                   	push   %esi
  801904:	53                   	push   %ebx
  801905:	83 ec 28             	sub    $0x28,%esp
  801908:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  80190b:	56                   	push   %esi
  80190c:	e8 6f f7 ff ff       	call   801080 <fd2data>
  801911:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801913:	83 c4 10             	add    $0x10,%esp
  801916:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80191a:	75 4a                	jne    801966 <devpipe_write+0x67>
  80191c:	bf 00 00 00 00       	mov    $0x0,%edi
  801921:	eb 56                	jmp    801979 <devpipe_write+0x7a>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801923:	89 da                	mov    %ebx,%edx
  801925:	89 f0                	mov    %esi,%eax
  801927:	e8 6c ff ff ff       	call   801898 <_pipeisclosed>
  80192c:	85 c0                	test   %eax,%eax
  80192e:	75 4d                	jne    80197d <devpipe_write+0x7e>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801930:	e8 90 f2 ff ff       	call   800bc5 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801935:	8b 43 04             	mov    0x4(%ebx),%eax
  801938:	8b 13                	mov    (%ebx),%edx
  80193a:	83 c2 20             	add    $0x20,%edx
  80193d:	39 d0                	cmp    %edx,%eax
  80193f:	73 e2                	jae    801923 <devpipe_write+0x24>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801941:	89 c2                	mov    %eax,%edx
  801943:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  801949:	79 05                	jns    801950 <devpipe_write+0x51>
  80194b:	4a                   	dec    %edx
  80194c:	83 ca e0             	or     $0xffffffe0,%edx
  80194f:	42                   	inc    %edx
  801950:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801953:	8a 0c 39             	mov    (%ecx,%edi,1),%cl
  801956:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  80195a:	40                   	inc    %eax
  80195b:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80195e:	47                   	inc    %edi
  80195f:	39 7d 10             	cmp    %edi,0x10(%ebp)
  801962:	77 07                	ja     80196b <devpipe_write+0x6c>
  801964:	eb 13                	jmp    801979 <devpipe_write+0x7a>
  801966:	bf 00 00 00 00       	mov    $0x0,%edi
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  80196b:	8b 43 04             	mov    0x4(%ebx),%eax
  80196e:	8b 13                	mov    (%ebx),%edx
  801970:	83 c2 20             	add    $0x20,%edx
  801973:	39 d0                	cmp    %edx,%eax
  801975:	73 ac                	jae    801923 <devpipe_write+0x24>
  801977:	eb c8                	jmp    801941 <devpipe_write+0x42>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801979:	89 f8                	mov    %edi,%eax
  80197b:	eb 05                	jmp    801982 <devpipe_write+0x83>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80197d:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801982:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801985:	5b                   	pop    %ebx
  801986:	5e                   	pop    %esi
  801987:	5f                   	pop    %edi
  801988:	c9                   	leave  
  801989:	c3                   	ret    

0080198a <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  80198a:	55                   	push   %ebp
  80198b:	89 e5                	mov    %esp,%ebp
  80198d:	57                   	push   %edi
  80198e:	56                   	push   %esi
  80198f:	53                   	push   %ebx
  801990:	83 ec 18             	sub    $0x18,%esp
  801993:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801996:	57                   	push   %edi
  801997:	e8 e4 f6 ff ff       	call   801080 <fd2data>
  80199c:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80199e:	83 c4 10             	add    $0x10,%esp
  8019a1:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8019a5:	75 44                	jne    8019eb <devpipe_read+0x61>
  8019a7:	be 00 00 00 00       	mov    $0x0,%esi
  8019ac:	eb 4f                	jmp    8019fd <devpipe_read+0x73>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
				return i;
  8019ae:	89 f0                	mov    %esi,%eax
  8019b0:	eb 54                	jmp    801a06 <devpipe_read+0x7c>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  8019b2:	89 da                	mov    %ebx,%edx
  8019b4:	89 f8                	mov    %edi,%eax
  8019b6:	e8 dd fe ff ff       	call   801898 <_pipeisclosed>
  8019bb:	85 c0                	test   %eax,%eax
  8019bd:	75 42                	jne    801a01 <devpipe_read+0x77>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  8019bf:	e8 01 f2 ff ff       	call   800bc5 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8019c4:	8b 03                	mov    (%ebx),%eax
  8019c6:	3b 43 04             	cmp    0x4(%ebx),%eax
  8019c9:	74 e7                	je     8019b2 <devpipe_read+0x28>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8019cb:	25 1f 00 00 80       	and    $0x8000001f,%eax
  8019d0:	79 05                	jns    8019d7 <devpipe_read+0x4d>
  8019d2:	48                   	dec    %eax
  8019d3:	83 c8 e0             	or     $0xffffffe0,%eax
  8019d6:	40                   	inc    %eax
  8019d7:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  8019db:	8b 55 0c             	mov    0xc(%ebp),%edx
  8019de:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  8019e1:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8019e3:	46                   	inc    %esi
  8019e4:	39 75 10             	cmp    %esi,0x10(%ebp)
  8019e7:	77 07                	ja     8019f0 <devpipe_read+0x66>
  8019e9:	eb 12                	jmp    8019fd <devpipe_read+0x73>
  8019eb:	be 00 00 00 00       	mov    $0x0,%esi
		while (p->p_rpos == p->p_wpos) {
  8019f0:	8b 03                	mov    (%ebx),%eax
  8019f2:	3b 43 04             	cmp    0x4(%ebx),%eax
  8019f5:	75 d4                	jne    8019cb <devpipe_read+0x41>
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  8019f7:	85 f6                	test   %esi,%esi
  8019f9:	75 b3                	jne    8019ae <devpipe_read+0x24>
  8019fb:	eb b5                	jmp    8019b2 <devpipe_read+0x28>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  8019fd:	89 f0                	mov    %esi,%eax
  8019ff:	eb 05                	jmp    801a06 <devpipe_read+0x7c>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801a01:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801a06:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a09:	5b                   	pop    %ebx
  801a0a:	5e                   	pop    %esi
  801a0b:	5f                   	pop    %edi
  801a0c:	c9                   	leave  
  801a0d:	c3                   	ret    

00801a0e <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801a0e:	55                   	push   %ebp
  801a0f:	89 e5                	mov    %esp,%ebp
  801a11:	57                   	push   %edi
  801a12:	56                   	push   %esi
  801a13:	53                   	push   %ebx
  801a14:	83 ec 28             	sub    $0x28,%esp
  801a17:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801a1a:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801a1d:	50                   	push   %eax
  801a1e:	e8 75 f6 ff ff       	call   801098 <fd_alloc>
  801a23:	89 c3                	mov    %eax,%ebx
  801a25:	83 c4 10             	add    $0x10,%esp
  801a28:	85 c0                	test   %eax,%eax
  801a2a:	0f 88 24 01 00 00    	js     801b54 <pipe+0x146>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801a30:	83 ec 04             	sub    $0x4,%esp
  801a33:	68 07 04 00 00       	push   $0x407
  801a38:	ff 75 e4             	pushl  -0x1c(%ebp)
  801a3b:	6a 00                	push   $0x0
  801a3d:	e8 aa f1 ff ff       	call   800bec <sys_page_alloc>
  801a42:	89 c3                	mov    %eax,%ebx
  801a44:	83 c4 10             	add    $0x10,%esp
  801a47:	85 c0                	test   %eax,%eax
  801a49:	0f 88 05 01 00 00    	js     801b54 <pipe+0x146>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801a4f:	83 ec 0c             	sub    $0xc,%esp
  801a52:	8d 45 e0             	lea    -0x20(%ebp),%eax
  801a55:	50                   	push   %eax
  801a56:	e8 3d f6 ff ff       	call   801098 <fd_alloc>
  801a5b:	89 c3                	mov    %eax,%ebx
  801a5d:	83 c4 10             	add    $0x10,%esp
  801a60:	85 c0                	test   %eax,%eax
  801a62:	0f 88 dc 00 00 00    	js     801b44 <pipe+0x136>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801a68:	83 ec 04             	sub    $0x4,%esp
  801a6b:	68 07 04 00 00       	push   $0x407
  801a70:	ff 75 e0             	pushl  -0x20(%ebp)
  801a73:	6a 00                	push   $0x0
  801a75:	e8 72 f1 ff ff       	call   800bec <sys_page_alloc>
  801a7a:	89 c3                	mov    %eax,%ebx
  801a7c:	83 c4 10             	add    $0x10,%esp
  801a7f:	85 c0                	test   %eax,%eax
  801a81:	0f 88 bd 00 00 00    	js     801b44 <pipe+0x136>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801a87:	83 ec 0c             	sub    $0xc,%esp
  801a8a:	ff 75 e4             	pushl  -0x1c(%ebp)
  801a8d:	e8 ee f5 ff ff       	call   801080 <fd2data>
  801a92:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801a94:	83 c4 0c             	add    $0xc,%esp
  801a97:	68 07 04 00 00       	push   $0x407
  801a9c:	50                   	push   %eax
  801a9d:	6a 00                	push   $0x0
  801a9f:	e8 48 f1 ff ff       	call   800bec <sys_page_alloc>
  801aa4:	89 c3                	mov    %eax,%ebx
  801aa6:	83 c4 10             	add    $0x10,%esp
  801aa9:	85 c0                	test   %eax,%eax
  801aab:	0f 88 83 00 00 00    	js     801b34 <pipe+0x126>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ab1:	83 ec 0c             	sub    $0xc,%esp
  801ab4:	ff 75 e0             	pushl  -0x20(%ebp)
  801ab7:	e8 c4 f5 ff ff       	call   801080 <fd2data>
  801abc:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801ac3:	50                   	push   %eax
  801ac4:	6a 00                	push   $0x0
  801ac6:	56                   	push   %esi
  801ac7:	6a 00                	push   $0x0
  801ac9:	e8 42 f1 ff ff       	call   800c10 <sys_page_map>
  801ace:	89 c3                	mov    %eax,%ebx
  801ad0:	83 c4 20             	add    $0x20,%esp
  801ad3:	85 c0                	test   %eax,%eax
  801ad5:	78 4f                	js     801b26 <pipe+0x118>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801ad7:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801add:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801ae0:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801ae2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801ae5:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801aec:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801af2:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801af5:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801af7:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801afa:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801b01:	83 ec 0c             	sub    $0xc,%esp
  801b04:	ff 75 e4             	pushl  -0x1c(%ebp)
  801b07:	e8 64 f5 ff ff       	call   801070 <fd2num>
  801b0c:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  801b0e:	83 c4 04             	add    $0x4,%esp
  801b11:	ff 75 e0             	pushl  -0x20(%ebp)
  801b14:	e8 57 f5 ff ff       	call   801070 <fd2num>
  801b19:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  801b1c:	83 c4 10             	add    $0x10,%esp
  801b1f:	bb 00 00 00 00       	mov    $0x0,%ebx
  801b24:	eb 2e                	jmp    801b54 <pipe+0x146>

    err3:
	sys_page_unmap(0, va);
  801b26:	83 ec 08             	sub    $0x8,%esp
  801b29:	56                   	push   %esi
  801b2a:	6a 00                	push   $0x0
  801b2c:	e8 05 f1 ff ff       	call   800c36 <sys_page_unmap>
  801b31:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801b34:	83 ec 08             	sub    $0x8,%esp
  801b37:	ff 75 e0             	pushl  -0x20(%ebp)
  801b3a:	6a 00                	push   $0x0
  801b3c:	e8 f5 f0 ff ff       	call   800c36 <sys_page_unmap>
  801b41:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801b44:	83 ec 08             	sub    $0x8,%esp
  801b47:	ff 75 e4             	pushl  -0x1c(%ebp)
  801b4a:	6a 00                	push   $0x0
  801b4c:	e8 e5 f0 ff ff       	call   800c36 <sys_page_unmap>
  801b51:	83 c4 10             	add    $0x10,%esp
    err:
	return r;
}
  801b54:	89 d8                	mov    %ebx,%eax
  801b56:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b59:	5b                   	pop    %ebx
  801b5a:	5e                   	pop    %esi
  801b5b:	5f                   	pop    %edi
  801b5c:	c9                   	leave  
  801b5d:	c3                   	ret    

00801b5e <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801b5e:	55                   	push   %ebp
  801b5f:	89 e5                	mov    %esp,%ebp
  801b61:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801b64:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b67:	50                   	push   %eax
  801b68:	ff 75 08             	pushl  0x8(%ebp)
  801b6b:	e8 9b f5 ff ff       	call   80110b <fd_lookup>
  801b70:	83 c4 10             	add    $0x10,%esp
  801b73:	85 c0                	test   %eax,%eax
  801b75:	78 18                	js     801b8f <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801b77:	83 ec 0c             	sub    $0xc,%esp
  801b7a:	ff 75 f4             	pushl  -0xc(%ebp)
  801b7d:	e8 fe f4 ff ff       	call   801080 <fd2data>
	return _pipeisclosed(fd, p);
  801b82:	89 c2                	mov    %eax,%edx
  801b84:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b87:	e8 0c fd ff ff       	call   801898 <_pipeisclosed>
  801b8c:	83 c4 10             	add    $0x10,%esp
}
  801b8f:	c9                   	leave  
  801b90:	c3                   	ret    
  801b91:	00 00                	add    %al,(%eax)
	...

00801b94 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801b94:	55                   	push   %ebp
  801b95:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801b97:	b8 00 00 00 00       	mov    $0x0,%eax
  801b9c:	c9                   	leave  
  801b9d:	c3                   	ret    

00801b9e <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801b9e:	55                   	push   %ebp
  801b9f:	89 e5                	mov    %esp,%ebp
  801ba1:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801ba4:	68 ee 27 80 00       	push   $0x8027ee
  801ba9:	ff 75 0c             	pushl  0xc(%ebp)
  801bac:	e8 b9 eb ff ff       	call   80076a <strcpy>
	return 0;
}
  801bb1:	b8 00 00 00 00       	mov    $0x0,%eax
  801bb6:	c9                   	leave  
  801bb7:	c3                   	ret    

00801bb8 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801bb8:	55                   	push   %ebp
  801bb9:	89 e5                	mov    %esp,%ebp
  801bbb:	57                   	push   %edi
  801bbc:	56                   	push   %esi
  801bbd:	53                   	push   %ebx
  801bbe:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801bc4:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801bc8:	74 45                	je     801c0f <devcons_write+0x57>
  801bca:	b8 00 00 00 00       	mov    $0x0,%eax
  801bcf:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801bd4:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801bda:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801bdd:	29 c3                	sub    %eax,%ebx
		if (m > sizeof(buf) - 1)
  801bdf:	83 fb 7f             	cmp    $0x7f,%ebx
  801be2:	76 05                	jbe    801be9 <devcons_write+0x31>
			m = sizeof(buf) - 1;
  801be4:	bb 7f 00 00 00       	mov    $0x7f,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  801be9:	83 ec 04             	sub    $0x4,%esp
  801bec:	53                   	push   %ebx
  801bed:	03 45 0c             	add    0xc(%ebp),%eax
  801bf0:	50                   	push   %eax
  801bf1:	57                   	push   %edi
  801bf2:	e8 34 ed ff ff       	call   80092b <memmove>
		sys_cputs(buf, m);
  801bf7:	83 c4 08             	add    $0x8,%esp
  801bfa:	53                   	push   %ebx
  801bfb:	57                   	push   %edi
  801bfc:	e8 34 ef ff ff       	call   800b35 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801c01:	01 de                	add    %ebx,%esi
  801c03:	89 f0                	mov    %esi,%eax
  801c05:	83 c4 10             	add    $0x10,%esp
  801c08:	3b 75 10             	cmp    0x10(%ebp),%esi
  801c0b:	72 cd                	jb     801bda <devcons_write+0x22>
  801c0d:	eb 05                	jmp    801c14 <devcons_write+0x5c>
  801c0f:	be 00 00 00 00       	mov    $0x0,%esi
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801c14:	89 f0                	mov    %esi,%eax
  801c16:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c19:	5b                   	pop    %ebx
  801c1a:	5e                   	pop    %esi
  801c1b:	5f                   	pop    %edi
  801c1c:	c9                   	leave  
  801c1d:	c3                   	ret    

00801c1e <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801c1e:	55                   	push   %ebp
  801c1f:	89 e5                	mov    %esp,%ebp
  801c21:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  801c24:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801c28:	75 07                	jne    801c31 <devcons_read+0x13>
  801c2a:	eb 25                	jmp    801c51 <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801c2c:	e8 94 ef ff ff       	call   800bc5 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801c31:	e8 25 ef ff ff       	call   800b5b <sys_cgetc>
  801c36:	85 c0                	test   %eax,%eax
  801c38:	74 f2                	je     801c2c <devcons_read+0xe>
  801c3a:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  801c3c:	85 c0                	test   %eax,%eax
  801c3e:	78 1d                	js     801c5d <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801c40:	83 f8 04             	cmp    $0x4,%eax
  801c43:	74 13                	je     801c58 <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  801c45:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c48:	88 10                	mov    %dl,(%eax)
	return 1;
  801c4a:	b8 01 00 00 00       	mov    $0x1,%eax
  801c4f:	eb 0c                	jmp    801c5d <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  801c51:	b8 00 00 00 00       	mov    $0x0,%eax
  801c56:	eb 05                	jmp    801c5d <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801c58:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801c5d:	c9                   	leave  
  801c5e:	c3                   	ret    

00801c5f <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801c5f:	55                   	push   %ebp
  801c60:	89 e5                	mov    %esp,%ebp
  801c62:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801c65:	8b 45 08             	mov    0x8(%ebp),%eax
  801c68:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801c6b:	6a 01                	push   $0x1
  801c6d:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801c70:	50                   	push   %eax
  801c71:	e8 bf ee ff ff       	call   800b35 <sys_cputs>
  801c76:	83 c4 10             	add    $0x10,%esp
}
  801c79:	c9                   	leave  
  801c7a:	c3                   	ret    

00801c7b <getchar>:

int
getchar(void)
{
  801c7b:	55                   	push   %ebp
  801c7c:	89 e5                	mov    %esp,%ebp
  801c7e:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801c81:	6a 01                	push   $0x1
  801c83:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801c86:	50                   	push   %eax
  801c87:	6a 00                	push   $0x0
  801c89:	e8 fe f6 ff ff       	call   80138c <read>
	if (r < 0)
  801c8e:	83 c4 10             	add    $0x10,%esp
  801c91:	85 c0                	test   %eax,%eax
  801c93:	78 0f                	js     801ca4 <getchar+0x29>
		return r;
	if (r < 1)
  801c95:	85 c0                	test   %eax,%eax
  801c97:	7e 06                	jle    801c9f <getchar+0x24>
		return -E_EOF;
	return c;
  801c99:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801c9d:	eb 05                	jmp    801ca4 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801c9f:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801ca4:	c9                   	leave  
  801ca5:	c3                   	ret    

00801ca6 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801ca6:	55                   	push   %ebp
  801ca7:	89 e5                	mov    %esp,%ebp
  801ca9:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801cac:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801caf:	50                   	push   %eax
  801cb0:	ff 75 08             	pushl  0x8(%ebp)
  801cb3:	e8 53 f4 ff ff       	call   80110b <fd_lookup>
  801cb8:	83 c4 10             	add    $0x10,%esp
  801cbb:	85 c0                	test   %eax,%eax
  801cbd:	78 11                	js     801cd0 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801cbf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cc2:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801cc8:	39 10                	cmp    %edx,(%eax)
  801cca:	0f 94 c0             	sete   %al
  801ccd:	0f b6 c0             	movzbl %al,%eax
}
  801cd0:	c9                   	leave  
  801cd1:	c3                   	ret    

00801cd2 <opencons>:

int
opencons(void)
{
  801cd2:	55                   	push   %ebp
  801cd3:	89 e5                	mov    %esp,%ebp
  801cd5:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801cd8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801cdb:	50                   	push   %eax
  801cdc:	e8 b7 f3 ff ff       	call   801098 <fd_alloc>
  801ce1:	83 c4 10             	add    $0x10,%esp
  801ce4:	85 c0                	test   %eax,%eax
  801ce6:	78 3a                	js     801d22 <opencons+0x50>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801ce8:	83 ec 04             	sub    $0x4,%esp
  801ceb:	68 07 04 00 00       	push   $0x407
  801cf0:	ff 75 f4             	pushl  -0xc(%ebp)
  801cf3:	6a 00                	push   $0x0
  801cf5:	e8 f2 ee ff ff       	call   800bec <sys_page_alloc>
  801cfa:	83 c4 10             	add    $0x10,%esp
  801cfd:	85 c0                	test   %eax,%eax
  801cff:	78 21                	js     801d22 <opencons+0x50>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801d01:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801d07:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d0a:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801d0c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d0f:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801d16:	83 ec 0c             	sub    $0xc,%esp
  801d19:	50                   	push   %eax
  801d1a:	e8 51 f3 ff ff       	call   801070 <fd2num>
  801d1f:	83 c4 10             	add    $0x10,%esp
}
  801d22:	c9                   	leave  
  801d23:	c3                   	ret    

00801d24 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801d24:	55                   	push   %ebp
  801d25:	89 e5                	mov    %esp,%ebp
  801d27:	56                   	push   %esi
  801d28:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801d29:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801d2c:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  801d32:	e8 6a ee ff ff       	call   800ba1 <sys_getenvid>
  801d37:	83 ec 0c             	sub    $0xc,%esp
  801d3a:	ff 75 0c             	pushl  0xc(%ebp)
  801d3d:	ff 75 08             	pushl  0x8(%ebp)
  801d40:	53                   	push   %ebx
  801d41:	50                   	push   %eax
  801d42:	68 fc 27 80 00       	push   $0x8027fc
  801d47:	e8 68 e4 ff ff       	call   8001b4 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801d4c:	83 c4 18             	add    $0x18,%esp
  801d4f:	56                   	push   %esi
  801d50:	ff 75 10             	pushl  0x10(%ebp)
  801d53:	e8 0b e4 ff ff       	call   800163 <vcprintf>
	cprintf("\n");
  801d58:	c7 04 24 54 22 80 00 	movl   $0x802254,(%esp)
  801d5f:	e8 50 e4 ff ff       	call   8001b4 <cprintf>
  801d64:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801d67:	cc                   	int3   
  801d68:	eb fd                	jmp    801d67 <_panic+0x43>
	...

00801d6c <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801d6c:	55                   	push   %ebp
  801d6d:	89 e5                	mov    %esp,%ebp
  801d6f:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  801d72:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801d79:	75 52                	jne    801dcd <set_pgfault_handler+0x61>
		// First time through!	
		// LAB 4: Your code here.

		//int sys_page_alloc(envid_t envid, void *va, int perm)
		r = sys_page_alloc(0, (void*)(UXSTACKTOP - PGSIZE), PTE_U | PTE_W | PTE_P);
  801d7b:	83 ec 04             	sub    $0x4,%esp
  801d7e:	6a 07                	push   $0x7
  801d80:	68 00 f0 bf ee       	push   $0xeebff000
  801d85:	6a 00                	push   $0x0
  801d87:	e8 60 ee ff ff       	call   800bec <sys_page_alloc>
		if (r < 0) {
  801d8c:	83 c4 10             	add    $0x10,%esp
  801d8f:	85 c0                	test   %eax,%eax
  801d91:	79 12                	jns    801da5 <set_pgfault_handler+0x39>
			panic("sys_page_alloc error : %e\n", r);
  801d93:	50                   	push   %eax
  801d94:	68 1f 28 80 00       	push   $0x80281f
  801d99:	6a 24                	push   $0x24
  801d9b:	68 3a 28 80 00       	push   $0x80283a
  801da0:	e8 7f ff ff ff       	call   801d24 <_panic>
		}

		// how to know envid, put 0, envid2env will help us to get curenv in syscall
		r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);		
  801da5:	83 ec 08             	sub    $0x8,%esp
  801da8:	68 d8 1d 80 00       	push   $0x801dd8
  801dad:	6a 00                	push   $0x0
  801daf:	e8 eb ee ff ff       	call   800c9f <sys_env_set_pgfault_upcall>
		if (r < 0) {
  801db4:	83 c4 10             	add    $0x10,%esp
  801db7:	85 c0                	test   %eax,%eax
  801db9:	79 12                	jns    801dcd <set_pgfault_handler+0x61>
			panic("sys_env_set_pgfault_upcall error : %e\n", r);
  801dbb:	50                   	push   %eax
  801dbc:	68 48 28 80 00       	push   $0x802848
  801dc1:	6a 2a                	push   $0x2a
  801dc3:	68 3a 28 80 00       	push   $0x80283a
  801dc8:	e8 57 ff ff ff       	call   801d24 <_panic>
		}
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801dcd:	8b 45 08             	mov    0x8(%ebp),%eax
  801dd0:	a3 00 60 80 00       	mov    %eax,0x806000
}
  801dd5:	c9                   	leave  
  801dd6:	c3                   	ret    
	...

00801dd8 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801dd8:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801dd9:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  801dde:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801de0:	83 c4 04             	add    $0x4,%esp
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	
	// fix old esp
	movl 0x30(%esp), %eax
  801de3:	8b 44 24 30          	mov    0x30(%esp),%eax
	subl $0x4, %eax
  801de7:	83 e8 04             	sub    $0x4,%eax
	movl %eax, 0x30(%esp)
  801dea:	89 44 24 30          	mov    %eax,0x30(%esp)

	// set trap-time %eip
	movl 0x28(%esp), %ebx
  801dee:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	movl %ebx, (%eax)
  801df2:	89 18                	mov    %ebx,(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $0x08, %esp 	// ignore err_code and fault_va
  801df4:	83 c4 08             	add    $0x8,%esp
	popal 				// restore registers
  801df7:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x04, %esp 	// ignore eip 
  801df8:	83 c4 04             	add    $0x4,%esp
	popfl				// modify eflags
  801dfb:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  801dfc:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  801dfd:	c3                   	ret    
	...

00801e00 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801e00:	55                   	push   %ebp
  801e01:	89 e5                	mov    %esp,%ebp
  801e03:	56                   	push   %esi
  801e04:	53                   	push   %ebx
  801e05:	8b 75 08             	mov    0x8(%ebp),%esi
  801e08:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e0b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// cprintf("0x%x 0x%x 0x%x\n", (uint32_t)from_env_store, (uint32_t)pg, (uint32_t)perm_store);
	int r;
	if (pg != NULL) {
  801e0e:	85 c0                	test   %eax,%eax
  801e10:	74 0e                	je     801e20 <ipc_recv+0x20>
		r = sys_ipc_recv(pg);
  801e12:	83 ec 0c             	sub    $0xc,%esp
  801e15:	50                   	push   %eax
  801e16:	e8 cc ee ff ff       	call   800ce7 <sys_ipc_recv>
  801e1b:	83 c4 10             	add    $0x10,%esp
  801e1e:	eb 10                	jmp    801e30 <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv((void *)UTOP);
  801e20:	83 ec 0c             	sub    $0xc,%esp
  801e23:	68 00 00 c0 ee       	push   $0xeec00000
  801e28:	e8 ba ee ff ff       	call   800ce7 <sys_ipc_recv>
  801e2d:	83 c4 10             	add    $0x10,%esp
	}

	if (r == 0) {
  801e30:	85 c0                	test   %eax,%eax
  801e32:	75 26                	jne    801e5a <ipc_recv+0x5a>
		if (from_env_store != NULL) *from_env_store = thisenv->env_ipc_from;
  801e34:	85 f6                	test   %esi,%esi
  801e36:	74 0a                	je     801e42 <ipc_recv+0x42>
  801e38:	a1 04 40 80 00       	mov    0x804004,%eax
  801e3d:	8b 40 74             	mov    0x74(%eax),%eax
  801e40:	89 06                	mov    %eax,(%esi)
		if (perm_store != NULL) *perm_store = thisenv->env_ipc_perm;
  801e42:	85 db                	test   %ebx,%ebx
  801e44:	74 0a                	je     801e50 <ipc_recv+0x50>
  801e46:	a1 04 40 80 00       	mov    0x804004,%eax
  801e4b:	8b 40 78             	mov    0x78(%eax),%eax
  801e4e:	89 03                	mov    %eax,(%ebx)
		return thisenv->env_ipc_value;
  801e50:	a1 04 40 80 00       	mov    0x804004,%eax
  801e55:	8b 40 70             	mov    0x70(%eax),%eax
  801e58:	eb 14                	jmp    801e6e <ipc_recv+0x6e>
	} else {
		// fails;
		if (from_env_store != NULL) *from_env_store = 0;
  801e5a:	85 f6                	test   %esi,%esi
  801e5c:	74 06                	je     801e64 <ipc_recv+0x64>
  801e5e:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if (perm_store != NULL) *perm_store = 0;
  801e64:	85 db                	test   %ebx,%ebx
  801e66:	74 06                	je     801e6e <ipc_recv+0x6e>
  801e68:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		return r;
	}
}
  801e6e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e71:	5b                   	pop    %ebx
  801e72:	5e                   	pop    %esi
  801e73:	c9                   	leave  
  801e74:	c3                   	ret    

00801e75 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801e75:	55                   	push   %ebp
  801e76:	89 e5                	mov    %esp,%ebp
  801e78:	57                   	push   %edi
  801e79:	56                   	push   %esi
  801e7a:	53                   	push   %ebx
  801e7b:	83 ec 0c             	sub    $0xc,%esp
  801e7e:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801e81:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801e84:	8b 75 14             	mov    0x14(%ebp),%esi
	// LAB 4: Your code here.
	// int sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
	int r;
	if (pg == NULL) pg = (void *)UTOP;
  801e87:	85 db                	test   %ebx,%ebx
  801e89:	75 25                	jne    801eb0 <ipc_send+0x3b>
  801e8b:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
  801e90:	eb 1e                	jmp    801eb0 <ipc_send+0x3b>
	
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) != 0) {
		if (r == -E_IPC_NOT_RECV) {
  801e92:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801e95:	75 07                	jne    801e9e <ipc_send+0x29>
			// cprintf("Try Again and Again....\n");
			sys_yield();
  801e97:	e8 29 ed ff ff       	call   800bc5 <sys_yield>
  801e9c:	eb 12                	jmp    801eb0 <ipc_send+0x3b>
		} else {
			panic("ipc_send error %e\n", r);
  801e9e:	50                   	push   %eax
  801e9f:	68 70 28 80 00       	push   $0x802870
  801ea4:	6a 43                	push   $0x43
  801ea6:	68 83 28 80 00       	push   $0x802883
  801eab:	e8 74 fe ff ff       	call   801d24 <_panic>
	// LAB 4: Your code here.
	// int sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
	int r;
	if (pg == NULL) pg = (void *)UTOP;
	
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) != 0) {
  801eb0:	56                   	push   %esi
  801eb1:	53                   	push   %ebx
  801eb2:	57                   	push   %edi
  801eb3:	ff 75 08             	pushl  0x8(%ebp)
  801eb6:	e8 07 ee ff ff       	call   800cc2 <sys_ipc_try_send>
  801ebb:	83 c4 10             	add    $0x10,%esp
  801ebe:	85 c0                	test   %eax,%eax
  801ec0:	75 d0                	jne    801e92 <ipc_send+0x1d>
		} else {
			panic("ipc_send error %e\n", r);
		}
	}
	return;
}
  801ec2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ec5:	5b                   	pop    %ebx
  801ec6:	5e                   	pop    %esi
  801ec7:	5f                   	pop    %edi
  801ec8:	c9                   	leave  
  801ec9:	c3                   	ret    

00801eca <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801eca:	55                   	push   %ebp
  801ecb:	89 e5                	mov    %esp,%ebp
  801ecd:	53                   	push   %ebx
  801ece:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  801ed1:	39 1d 50 00 c0 ee    	cmp    %ebx,0xeec00050
  801ed7:	74 22                	je     801efb <ipc_find_env+0x31>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801ed9:	b8 01 00 00 00       	mov    $0x1,%eax
		if (envs[i].env_type == type)
  801ede:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  801ee5:	89 c2                	mov    %eax,%edx
  801ee7:	c1 e2 07             	shl    $0x7,%edx
  801eea:	29 ca                	sub    %ecx,%edx
  801eec:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801ef2:	8b 52 50             	mov    0x50(%edx),%edx
  801ef5:	39 da                	cmp    %ebx,%edx
  801ef7:	75 1d                	jne    801f16 <ipc_find_env+0x4c>
  801ef9:	eb 05                	jmp    801f00 <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801efb:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
			return envs[i].env_id;
  801f00:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  801f07:	c1 e0 07             	shl    $0x7,%eax
  801f0a:	29 d0                	sub    %edx,%eax
  801f0c:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  801f11:	8b 40 40             	mov    0x40(%eax),%eax
  801f14:	eb 0c                	jmp    801f22 <ipc_find_env+0x58>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801f16:	40                   	inc    %eax
  801f17:	3d 00 04 00 00       	cmp    $0x400,%eax
  801f1c:	75 c0                	jne    801ede <ipc_find_env+0x14>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801f1e:	66 b8 00 00          	mov    $0x0,%ax
}
  801f22:	5b                   	pop    %ebx
  801f23:	c9                   	leave  
  801f24:	c3                   	ret    
  801f25:	00 00                	add    %al,(%eax)
	...

00801f28 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801f28:	55                   	push   %ebp
  801f29:	89 e5                	mov    %esp,%ebp
  801f2b:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801f2e:	89 c2                	mov    %eax,%edx
  801f30:	c1 ea 16             	shr    $0x16,%edx
  801f33:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801f3a:	f6 c2 01             	test   $0x1,%dl
  801f3d:	74 1e                	je     801f5d <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  801f3f:	c1 e8 0c             	shr    $0xc,%eax
  801f42:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801f49:	a8 01                	test   $0x1,%al
  801f4b:	74 17                	je     801f64 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801f4d:	c1 e8 0c             	shr    $0xc,%eax
  801f50:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  801f57:	ef 
  801f58:	0f b7 c0             	movzwl %ax,%eax
  801f5b:	eb 0c                	jmp    801f69 <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  801f5d:	b8 00 00 00 00       	mov    $0x0,%eax
  801f62:	eb 05                	jmp    801f69 <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  801f64:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  801f69:	c9                   	leave  
  801f6a:	c3                   	ret    
	...

00801f6c <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  801f6c:	55                   	push   %ebp
  801f6d:	89 e5                	mov    %esp,%ebp
  801f6f:	57                   	push   %edi
  801f70:	56                   	push   %esi
  801f71:	83 ec 10             	sub    $0x10,%esp
  801f74:	8b 7d 08             	mov    0x8(%ebp),%edi
  801f77:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  801f7a:	89 7d f0             	mov    %edi,-0x10(%ebp)
  801f7d:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  801f80:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  801f83:	8b 45 14             	mov    0x14(%ebp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  801f86:	85 c0                	test   %eax,%eax
  801f88:	75 2e                	jne    801fb8 <__udivdi3+0x4c>
    {
      if (d0 > n1)
  801f8a:	39 f1                	cmp    %esi,%ecx
  801f8c:	77 5a                	ja     801fe8 <__udivdi3+0x7c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  801f8e:	85 c9                	test   %ecx,%ecx
  801f90:	75 0b                	jne    801f9d <__udivdi3+0x31>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  801f92:	b8 01 00 00 00       	mov    $0x1,%eax
  801f97:	31 d2                	xor    %edx,%edx
  801f99:	f7 f1                	div    %ecx
  801f9b:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  801f9d:	31 d2                	xor    %edx,%edx
  801f9f:	89 f0                	mov    %esi,%eax
  801fa1:	f7 f1                	div    %ecx
  801fa3:	89 c6                	mov    %eax,%esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801fa5:	89 f8                	mov    %edi,%eax
  801fa7:	f7 f1                	div    %ecx
  801fa9:	89 c7                	mov    %eax,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801fab:	89 f8                	mov    %edi,%eax
  801fad:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801faf:	83 c4 10             	add    $0x10,%esp
  801fb2:	5e                   	pop    %esi
  801fb3:	5f                   	pop    %edi
  801fb4:	c9                   	leave  
  801fb5:	c3                   	ret    
  801fb6:	66 90                	xchg   %ax,%ax
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801fb8:	39 f0                	cmp    %esi,%eax
  801fba:	77 1c                	ja     801fd8 <__udivdi3+0x6c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  801fbc:	0f bd f8             	bsr    %eax,%edi
	  if (bm == 0)
  801fbf:	83 f7 1f             	xor    $0x1f,%edi
  801fc2:	75 3c                	jne    802000 <__udivdi3+0x94>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801fc4:	39 f0                	cmp    %esi,%eax
  801fc6:	0f 82 90 00 00 00    	jb     80205c <__udivdi3+0xf0>
  801fcc:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801fcf:	39 55 f4             	cmp    %edx,-0xc(%ebp)
  801fd2:	0f 86 84 00 00 00    	jbe    80205c <__udivdi3+0xf0>
  801fd8:	31 f6                	xor    %esi,%esi
  801fda:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801fdc:	89 f8                	mov    %edi,%eax
  801fde:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801fe0:	83 c4 10             	add    $0x10,%esp
  801fe3:	5e                   	pop    %esi
  801fe4:	5f                   	pop    %edi
  801fe5:	c9                   	leave  
  801fe6:	c3                   	ret    
  801fe7:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801fe8:	89 f2                	mov    %esi,%edx
  801fea:	89 f8                	mov    %edi,%eax
  801fec:	f7 f1                	div    %ecx
  801fee:	89 c7                	mov    %eax,%edi
  801ff0:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801ff2:	89 f8                	mov    %edi,%eax
  801ff4:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801ff6:	83 c4 10             	add    $0x10,%esp
  801ff9:	5e                   	pop    %esi
  801ffa:	5f                   	pop    %edi
  801ffb:	c9                   	leave  
  801ffc:	c3                   	ret    
  801ffd:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  802000:	89 f9                	mov    %edi,%ecx
  802002:	d3 e0                	shl    %cl,%eax
  802004:	89 45 e8             	mov    %eax,-0x18(%ebp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  802007:	b8 20 00 00 00       	mov    $0x20,%eax
  80200c:	29 f8                	sub    %edi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  80200e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802011:	88 c1                	mov    %al,%cl
  802013:	d3 ea                	shr    %cl,%edx
  802015:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  802018:	09 ca                	or     %ecx,%edx
  80201a:	89 55 ec             	mov    %edx,-0x14(%ebp)
	      d0 = d0 << bm;
  80201d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802020:	89 f9                	mov    %edi,%ecx
  802022:	d3 e2                	shl    %cl,%edx
  802024:	89 55 f4             	mov    %edx,-0xc(%ebp)
	      n2 = n1 >> b;
  802027:	89 f2                	mov    %esi,%edx
  802029:	88 c1                	mov    %al,%cl
  80202b:	d3 ea                	shr    %cl,%edx
  80202d:	89 55 e8             	mov    %edx,-0x18(%ebp)
	      n1 = (n1 << bm) | (n0 >> b);
  802030:	89 f2                	mov    %esi,%edx
  802032:	89 f9                	mov    %edi,%ecx
  802034:	d3 e2                	shl    %cl,%edx
  802036:	8b 75 f0             	mov    -0x10(%ebp),%esi
  802039:	88 c1                	mov    %al,%cl
  80203b:	d3 ee                	shr    %cl,%esi
  80203d:	09 d6                	or     %edx,%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  80203f:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  802042:	89 f0                	mov    %esi,%eax
  802044:	89 ca                	mov    %ecx,%edx
  802046:	f7 75 ec             	divl   -0x14(%ebp)
  802049:	89 d1                	mov    %edx,%ecx
  80204b:	89 c6                	mov    %eax,%esi
	      umul_ppmm (m1, m0, q0, d0);
  80204d:	f7 65 f4             	mull   -0xc(%ebp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802050:	39 d1                	cmp    %edx,%ecx
  802052:	72 28                	jb     80207c <__udivdi3+0x110>
  802054:	74 1a                	je     802070 <__udivdi3+0x104>
  802056:	89 f7                	mov    %esi,%edi
  802058:	31 f6                	xor    %esi,%esi
  80205a:	eb 80                	jmp    801fdc <__udivdi3+0x70>
	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  80205c:	31 f6                	xor    %esi,%esi
  80205e:	bf 01 00 00 00       	mov    $0x1,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  802063:	89 f8                	mov    %edi,%eax
  802065:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802067:	83 c4 10             	add    $0x10,%esp
  80206a:	5e                   	pop    %esi
  80206b:	5f                   	pop    %edi
  80206c:	c9                   	leave  
  80206d:	c3                   	ret    
  80206e:	66 90                	xchg   %ax,%ax

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  802070:	8b 55 f0             	mov    -0x10(%ebp),%edx
  802073:	89 f9                	mov    %edi,%ecx
  802075:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802077:	39 c2                	cmp    %eax,%edx
  802079:	73 db                	jae    802056 <__udivdi3+0xea>
  80207b:	90                   	nop
		{
		  q0--;
  80207c:	8d 7e ff             	lea    -0x1(%esi),%edi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  80207f:	31 f6                	xor    %esi,%esi
  802081:	e9 56 ff ff ff       	jmp    801fdc <__udivdi3+0x70>
	...

00802088 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  802088:	55                   	push   %ebp
  802089:	89 e5                	mov    %esp,%ebp
  80208b:	57                   	push   %edi
  80208c:	56                   	push   %esi
  80208d:	83 ec 20             	sub    $0x20,%esp
  802090:	8b 45 08             	mov    0x8(%ebp),%eax
  802093:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  802096:	89 45 e8             	mov    %eax,-0x18(%ebp)
  802099:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  80209c:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  80209f:	8b 7d 14             	mov    0x14(%ebp),%edi
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  8020a2:	89 45 f0             	mov    %eax,-0x10(%ebp)
  n1 = nn.s.high;
  8020a5:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  8020a7:	85 ff                	test   %edi,%edi
  8020a9:	75 15                	jne    8020c0 <__umoddi3+0x38>
    {
      if (d0 > n1)
  8020ab:	39 f1                	cmp    %esi,%ecx
  8020ad:	0f 86 99 00 00 00    	jbe    80214c <__umoddi3+0xc4>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8020b3:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  8020b5:	89 d0                	mov    %edx,%eax
  8020b7:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8020b9:	83 c4 20             	add    $0x20,%esp
  8020bc:	5e                   	pop    %esi
  8020bd:	5f                   	pop    %edi
  8020be:	c9                   	leave  
  8020bf:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  8020c0:	39 f7                	cmp    %esi,%edi
  8020c2:	0f 87 a4 00 00 00    	ja     80216c <__umoddi3+0xe4>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  8020c8:	0f bd c7             	bsr    %edi,%eax
	  if (bm == 0)
  8020cb:	83 f0 1f             	xor    $0x1f,%eax
  8020ce:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8020d1:	0f 84 a1 00 00 00    	je     802178 <__umoddi3+0xf0>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  8020d7:	89 f8                	mov    %edi,%eax
  8020d9:	8a 4d ec             	mov    -0x14(%ebp),%cl
  8020dc:	d3 e0                	shl    %cl,%eax
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  8020de:	bf 20 00 00 00       	mov    $0x20,%edi
  8020e3:	2b 7d ec             	sub    -0x14(%ebp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  8020e6:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8020e9:	89 f9                	mov    %edi,%ecx
  8020eb:	d3 ea                	shr    %cl,%edx
  8020ed:	09 c2                	or     %eax,%edx
  8020ef:	89 55 f0             	mov    %edx,-0x10(%ebp)
	      d0 = d0 << bm;
  8020f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020f5:	8a 4d ec             	mov    -0x14(%ebp),%cl
  8020f8:	d3 e0                	shl    %cl,%eax
  8020fa:	89 45 f4             	mov    %eax,-0xc(%ebp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  8020fd:	89 f2                	mov    %esi,%edx
  8020ff:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  802101:	8b 45 e8             	mov    -0x18(%ebp),%eax
  802104:	d3 e0                	shl    %cl,%eax
  802106:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  802109:	8b 45 e8             	mov    -0x18(%ebp),%eax
  80210c:	89 f9                	mov    %edi,%ecx
  80210e:	d3 e8                	shr    %cl,%eax
  802110:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  802112:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  802114:	89 f2                	mov    %esi,%edx
  802116:	f7 75 f0             	divl   -0x10(%ebp)
  802119:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  80211b:	f7 65 f4             	mull   -0xc(%ebp)
  80211e:	89 55 e8             	mov    %edx,-0x18(%ebp)
  802121:	89 c1                	mov    %eax,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802123:	39 d6                	cmp    %edx,%esi
  802125:	72 71                	jb     802198 <__umoddi3+0x110>
  802127:	74 7f                	je     8021a8 <__umoddi3+0x120>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  802129:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80212c:	29 c8                	sub    %ecx,%eax
  80212e:	19 d6                	sbb    %edx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  802130:	8a 4d ec             	mov    -0x14(%ebp),%cl
  802133:	d3 e8                	shr    %cl,%eax
  802135:	89 f2                	mov    %esi,%edx
  802137:	89 f9                	mov    %edi,%ecx
  802139:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  80213b:	09 d0                	or     %edx,%eax
  80213d:	89 f2                	mov    %esi,%edx
  80213f:	8a 4d ec             	mov    -0x14(%ebp),%cl
  802142:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802144:	83 c4 20             	add    $0x20,%esp
  802147:	5e                   	pop    %esi
  802148:	5f                   	pop    %edi
  802149:	c9                   	leave  
  80214a:	c3                   	ret    
  80214b:	90                   	nop
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  80214c:	85 c9                	test   %ecx,%ecx
  80214e:	75 0b                	jne    80215b <__umoddi3+0xd3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  802150:	b8 01 00 00 00       	mov    $0x1,%eax
  802155:	31 d2                	xor    %edx,%edx
  802157:	f7 f1                	div    %ecx
  802159:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  80215b:	89 f0                	mov    %esi,%eax
  80215d:	31 d2                	xor    %edx,%edx
  80215f:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802161:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802164:	f7 f1                	div    %ecx
  802166:	e9 4a ff ff ff       	jmp    8020b5 <__umoddi3+0x2d>
  80216b:	90                   	nop
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  80216c:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  80216e:	83 c4 20             	add    $0x20,%esp
  802171:	5e                   	pop    %esi
  802172:	5f                   	pop    %edi
  802173:	c9                   	leave  
  802174:	c3                   	ret    
  802175:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802178:	39 f7                	cmp    %esi,%edi
  80217a:	72 05                	jb     802181 <__umoddi3+0xf9>
  80217c:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
  80217f:	77 0c                	ja     80218d <__umoddi3+0x105>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  802181:	89 f2                	mov    %esi,%edx
  802183:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802186:	29 c8                	sub    %ecx,%eax
  802188:	19 fa                	sbb    %edi,%edx
  80218a:	89 45 f0             	mov    %eax,-0x10(%ebp)

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  80218d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802190:	83 c4 20             	add    $0x20,%esp
  802193:	5e                   	pop    %esi
  802194:	5f                   	pop    %edi
  802195:	c9                   	leave  
  802196:	c3                   	ret    
  802197:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  802198:	8b 55 e8             	mov    -0x18(%ebp),%edx
  80219b:	89 c1                	mov    %eax,%ecx
  80219d:	2b 4d f4             	sub    -0xc(%ebp),%ecx
  8021a0:	1b 55 f0             	sbb    -0x10(%ebp),%edx
  8021a3:	eb 84                	jmp    802129 <__umoddi3+0xa1>
  8021a5:	8d 76 00             	lea    0x0(%esi),%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8021a8:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  8021ab:	72 eb                	jb     802198 <__umoddi3+0x110>
  8021ad:	89 f2                	mov    %esi,%edx
  8021af:	e9 75 ff ff ff       	jmp    802129 <__umoddi3+0xa1>
