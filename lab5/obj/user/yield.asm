
obj/user/yield.debug:     file format elf32-i386


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
  80002c:	e8 6b 00 00 00       	call   80009c <libmain>
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
  800038:	83 ec 0c             	sub    $0xc,%esp
	int i;

	cprintf("Hello, I am environment %08x.\n", thisenv->env_id);
  80003b:	a1 04 40 80 00       	mov    0x804004,%eax
  800040:	8b 40 48             	mov    0x48(%eax),%eax
  800043:	50                   	push   %eax
  800044:	68 c0 1d 80 00       	push   $0x801dc0
  800049:	e8 4a 01 00 00       	call   800198 <cprintf>
  80004e:	83 c4 10             	add    $0x10,%esp
	for (i = 0; i < 5; i++) {
  800051:	bb 00 00 00 00       	mov    $0x0,%ebx
		sys_yield();
  800056:	e8 4e 0b 00 00       	call   800ba9 <sys_yield>
		cprintf("Back in environment %08x, iteration %d.\n",
			thisenv->env_id, i);
  80005b:	a1 04 40 80 00       	mov    0x804004,%eax
	int i;

	cprintf("Hello, I am environment %08x.\n", thisenv->env_id);
	for (i = 0; i < 5; i++) {
		sys_yield();
		cprintf("Back in environment %08x, iteration %d.\n",
  800060:	8b 40 48             	mov    0x48(%eax),%eax
  800063:	83 ec 04             	sub    $0x4,%esp
  800066:	53                   	push   %ebx
  800067:	50                   	push   %eax
  800068:	68 e0 1d 80 00       	push   $0x801de0
  80006d:	e8 26 01 00 00       	call   800198 <cprintf>
umain(int argc, char **argv)
{
	int i;

	cprintf("Hello, I am environment %08x.\n", thisenv->env_id);
	for (i = 0; i < 5; i++) {
  800072:	43                   	inc    %ebx
  800073:	83 c4 10             	add    $0x10,%esp
  800076:	83 fb 05             	cmp    $0x5,%ebx
  800079:	75 db                	jne    800056 <umain+0x22>
		sys_yield();
		cprintf("Back in environment %08x, iteration %d.\n",
			thisenv->env_id, i);
	}
	cprintf("All done in environment %08x.\n", thisenv->env_id);
  80007b:	a1 04 40 80 00       	mov    0x804004,%eax
  800080:	8b 40 48             	mov    0x48(%eax),%eax
  800083:	83 ec 08             	sub    $0x8,%esp
  800086:	50                   	push   %eax
  800087:	68 0c 1e 80 00       	push   $0x801e0c
  80008c:	e8 07 01 00 00       	call   800198 <cprintf>
  800091:	83 c4 10             	add    $0x10,%esp
}
  800094:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800097:	c9                   	leave  
  800098:	c3                   	ret    
  800099:	00 00                	add    %al,(%eax)
	...

0080009c <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80009c:	55                   	push   %ebp
  80009d:	89 e5                	mov    %esp,%ebp
  80009f:	56                   	push   %esi
  8000a0:	53                   	push   %ebx
  8000a1:	8b 75 08             	mov    0x8(%ebp),%esi
  8000a4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs + ENVX(sys_getenvid());
  8000a7:	e8 d9 0a 00 00       	call   800b85 <sys_getenvid>
  8000ac:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000b1:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  8000b8:	c1 e0 07             	shl    $0x7,%eax
  8000bb:	29 d0                	sub    %edx,%eax
  8000bd:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000c2:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000c7:	85 f6                	test   %esi,%esi
  8000c9:	7e 07                	jle    8000d2 <libmain+0x36>
		binaryname = argv[0];
  8000cb:	8b 03                	mov    (%ebx),%eax
  8000cd:	a3 00 30 80 00       	mov    %eax,0x803000
	// call user main routine
	umain(argc, argv);
  8000d2:	83 ec 08             	sub    $0x8,%esp
  8000d5:	53                   	push   %ebx
  8000d6:	56                   	push   %esi
  8000d7:	e8 58 ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  8000dc:	e8 0b 00 00 00       	call   8000ec <exit>
  8000e1:	83 c4 10             	add    $0x10,%esp
}
  8000e4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000e7:	5b                   	pop    %ebx
  8000e8:	5e                   	pop    %esi
  8000e9:	c9                   	leave  
  8000ea:	c3                   	ret    
	...

008000ec <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000ec:	55                   	push   %ebp
  8000ed:	89 e5                	mov    %esp,%ebp
  8000ef:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8000f2:	e8 23 0e 00 00       	call   800f1a <close_all>
	sys_env_destroy(0);
  8000f7:	83 ec 0c             	sub    $0xc,%esp
  8000fa:	6a 00                	push   $0x0
  8000fc:	e8 62 0a 00 00       	call   800b63 <sys_env_destroy>
  800101:	83 c4 10             	add    $0x10,%esp
}
  800104:	c9                   	leave  
  800105:	c3                   	ret    
	...

00800108 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800108:	55                   	push   %ebp
  800109:	89 e5                	mov    %esp,%ebp
  80010b:	53                   	push   %ebx
  80010c:	83 ec 04             	sub    $0x4,%esp
  80010f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800112:	8b 03                	mov    (%ebx),%eax
  800114:	8b 55 08             	mov    0x8(%ebp),%edx
  800117:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  80011b:	40                   	inc    %eax
  80011c:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  80011e:	3d ff 00 00 00       	cmp    $0xff,%eax
  800123:	75 1a                	jne    80013f <putch+0x37>
		sys_cputs(b->buf, b->idx);
  800125:	83 ec 08             	sub    $0x8,%esp
  800128:	68 ff 00 00 00       	push   $0xff
  80012d:	8d 43 08             	lea    0x8(%ebx),%eax
  800130:	50                   	push   %eax
  800131:	e8 e3 09 00 00       	call   800b19 <sys_cputs>
		b->idx = 0;
  800136:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80013c:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80013f:	ff 43 04             	incl   0x4(%ebx)
}
  800142:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800145:	c9                   	leave  
  800146:	c3                   	ret    

00800147 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800147:	55                   	push   %ebp
  800148:	89 e5                	mov    %esp,%ebp
  80014a:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800150:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800157:	00 00 00 
	b.cnt = 0;
  80015a:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800161:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800164:	ff 75 0c             	pushl  0xc(%ebp)
  800167:	ff 75 08             	pushl  0x8(%ebp)
  80016a:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800170:	50                   	push   %eax
  800171:	68 08 01 80 00       	push   $0x800108
  800176:	e8 82 01 00 00       	call   8002fd <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80017b:	83 c4 08             	add    $0x8,%esp
  80017e:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800184:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80018a:	50                   	push   %eax
  80018b:	e8 89 09 00 00       	call   800b19 <sys_cputs>

	return b.cnt;
}
  800190:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800196:	c9                   	leave  
  800197:	c3                   	ret    

00800198 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800198:	55                   	push   %ebp
  800199:	89 e5                	mov    %esp,%ebp
  80019b:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80019e:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001a1:	50                   	push   %eax
  8001a2:	ff 75 08             	pushl  0x8(%ebp)
  8001a5:	e8 9d ff ff ff       	call   800147 <vcprintf>
	va_end(ap);

	return cnt;
}
  8001aa:	c9                   	leave  
  8001ab:	c3                   	ret    

008001ac <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001ac:	55                   	push   %ebp
  8001ad:	89 e5                	mov    %esp,%ebp
  8001af:	57                   	push   %edi
  8001b0:	56                   	push   %esi
  8001b1:	53                   	push   %ebx
  8001b2:	83 ec 2c             	sub    $0x2c,%esp
  8001b5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8001b8:	89 d6                	mov    %edx,%esi
  8001ba:	8b 45 08             	mov    0x8(%ebp),%eax
  8001bd:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001c0:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001c3:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8001c6:	8b 45 10             	mov    0x10(%ebp),%eax
  8001c9:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8001cc:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001cf:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8001d2:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  8001d9:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
  8001dc:	72 0c                	jb     8001ea <printnum+0x3e>
  8001de:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  8001e1:	76 07                	jbe    8001ea <printnum+0x3e>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8001e3:	4b                   	dec    %ebx
  8001e4:	85 db                	test   %ebx,%ebx
  8001e6:	7f 31                	jg     800219 <printnum+0x6d>
  8001e8:	eb 3f                	jmp    800229 <printnum+0x7d>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001ea:	83 ec 0c             	sub    $0xc,%esp
  8001ed:	57                   	push   %edi
  8001ee:	4b                   	dec    %ebx
  8001ef:	53                   	push   %ebx
  8001f0:	50                   	push   %eax
  8001f1:	83 ec 08             	sub    $0x8,%esp
  8001f4:	ff 75 d4             	pushl  -0x2c(%ebp)
  8001f7:	ff 75 d0             	pushl  -0x30(%ebp)
  8001fa:	ff 75 dc             	pushl  -0x24(%ebp)
  8001fd:	ff 75 d8             	pushl  -0x28(%ebp)
  800200:	e8 73 19 00 00       	call   801b78 <__udivdi3>
  800205:	83 c4 18             	add    $0x18,%esp
  800208:	52                   	push   %edx
  800209:	50                   	push   %eax
  80020a:	89 f2                	mov    %esi,%edx
  80020c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80020f:	e8 98 ff ff ff       	call   8001ac <printnum>
  800214:	83 c4 20             	add    $0x20,%esp
  800217:	eb 10                	jmp    800229 <printnum+0x7d>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800219:	83 ec 08             	sub    $0x8,%esp
  80021c:	56                   	push   %esi
  80021d:	57                   	push   %edi
  80021e:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800221:	4b                   	dec    %ebx
  800222:	83 c4 10             	add    $0x10,%esp
  800225:	85 db                	test   %ebx,%ebx
  800227:	7f f0                	jg     800219 <printnum+0x6d>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800229:	83 ec 08             	sub    $0x8,%esp
  80022c:	56                   	push   %esi
  80022d:	83 ec 04             	sub    $0x4,%esp
  800230:	ff 75 d4             	pushl  -0x2c(%ebp)
  800233:	ff 75 d0             	pushl  -0x30(%ebp)
  800236:	ff 75 dc             	pushl  -0x24(%ebp)
  800239:	ff 75 d8             	pushl  -0x28(%ebp)
  80023c:	e8 53 1a 00 00       	call   801c94 <__umoddi3>
  800241:	83 c4 14             	add    $0x14,%esp
  800244:	0f be 80 35 1e 80 00 	movsbl 0x801e35(%eax),%eax
  80024b:	50                   	push   %eax
  80024c:	ff 55 e4             	call   *-0x1c(%ebp)
  80024f:	83 c4 10             	add    $0x10,%esp
}
  800252:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800255:	5b                   	pop    %ebx
  800256:	5e                   	pop    %esi
  800257:	5f                   	pop    %edi
  800258:	c9                   	leave  
  800259:	c3                   	ret    

0080025a <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80025a:	55                   	push   %ebp
  80025b:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80025d:	83 fa 01             	cmp    $0x1,%edx
  800260:	7e 0e                	jle    800270 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800262:	8b 10                	mov    (%eax),%edx
  800264:	8d 4a 08             	lea    0x8(%edx),%ecx
  800267:	89 08                	mov    %ecx,(%eax)
  800269:	8b 02                	mov    (%edx),%eax
  80026b:	8b 52 04             	mov    0x4(%edx),%edx
  80026e:	eb 22                	jmp    800292 <getuint+0x38>
	else if (lflag)
  800270:	85 d2                	test   %edx,%edx
  800272:	74 10                	je     800284 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800274:	8b 10                	mov    (%eax),%edx
  800276:	8d 4a 04             	lea    0x4(%edx),%ecx
  800279:	89 08                	mov    %ecx,(%eax)
  80027b:	8b 02                	mov    (%edx),%eax
  80027d:	ba 00 00 00 00       	mov    $0x0,%edx
  800282:	eb 0e                	jmp    800292 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800284:	8b 10                	mov    (%eax),%edx
  800286:	8d 4a 04             	lea    0x4(%edx),%ecx
  800289:	89 08                	mov    %ecx,(%eax)
  80028b:	8b 02                	mov    (%edx),%eax
  80028d:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800292:	c9                   	leave  
  800293:	c3                   	ret    

00800294 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  800294:	55                   	push   %ebp
  800295:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800297:	83 fa 01             	cmp    $0x1,%edx
  80029a:	7e 0e                	jle    8002aa <getint+0x16>
		return va_arg(*ap, long long);
  80029c:	8b 10                	mov    (%eax),%edx
  80029e:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002a1:	89 08                	mov    %ecx,(%eax)
  8002a3:	8b 02                	mov    (%edx),%eax
  8002a5:	8b 52 04             	mov    0x4(%edx),%edx
  8002a8:	eb 1a                	jmp    8002c4 <getint+0x30>
	else if (lflag)
  8002aa:	85 d2                	test   %edx,%edx
  8002ac:	74 0c                	je     8002ba <getint+0x26>
		return va_arg(*ap, long);
  8002ae:	8b 10                	mov    (%eax),%edx
  8002b0:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002b3:	89 08                	mov    %ecx,(%eax)
  8002b5:	8b 02                	mov    (%edx),%eax
  8002b7:	99                   	cltd   
  8002b8:	eb 0a                	jmp    8002c4 <getint+0x30>
	else
		return va_arg(*ap, int);
  8002ba:	8b 10                	mov    (%eax),%edx
  8002bc:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002bf:	89 08                	mov    %ecx,(%eax)
  8002c1:	8b 02                	mov    (%edx),%eax
  8002c3:	99                   	cltd   
}
  8002c4:	c9                   	leave  
  8002c5:	c3                   	ret    

008002c6 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002c6:	55                   	push   %ebp
  8002c7:	89 e5                	mov    %esp,%ebp
  8002c9:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002cc:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  8002cf:	8b 10                	mov    (%eax),%edx
  8002d1:	3b 50 04             	cmp    0x4(%eax),%edx
  8002d4:	73 08                	jae    8002de <sprintputch+0x18>
		*b->buf++ = ch;
  8002d6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8002d9:	88 0a                	mov    %cl,(%edx)
  8002db:	42                   	inc    %edx
  8002dc:	89 10                	mov    %edx,(%eax)
}
  8002de:	c9                   	leave  
  8002df:	c3                   	ret    

008002e0 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8002e0:	55                   	push   %ebp
  8002e1:	89 e5                	mov    %esp,%ebp
  8002e3:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8002e6:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002e9:	50                   	push   %eax
  8002ea:	ff 75 10             	pushl  0x10(%ebp)
  8002ed:	ff 75 0c             	pushl  0xc(%ebp)
  8002f0:	ff 75 08             	pushl  0x8(%ebp)
  8002f3:	e8 05 00 00 00       	call   8002fd <vprintfmt>
	va_end(ap);
  8002f8:	83 c4 10             	add    $0x10,%esp
}
  8002fb:	c9                   	leave  
  8002fc:	c3                   	ret    

008002fd <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8002fd:	55                   	push   %ebp
  8002fe:	89 e5                	mov    %esp,%ebp
  800300:	57                   	push   %edi
  800301:	56                   	push   %esi
  800302:	53                   	push   %ebx
  800303:	83 ec 2c             	sub    $0x2c,%esp
  800306:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800309:	8b 75 10             	mov    0x10(%ebp),%esi
  80030c:	eb 13                	jmp    800321 <vprintfmt+0x24>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80030e:	85 c0                	test   %eax,%eax
  800310:	0f 84 6d 03 00 00    	je     800683 <vprintfmt+0x386>
				return;
			putch(ch, putdat);
  800316:	83 ec 08             	sub    $0x8,%esp
  800319:	57                   	push   %edi
  80031a:	50                   	push   %eax
  80031b:	ff 55 08             	call   *0x8(%ebp)
  80031e:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800321:	0f b6 06             	movzbl (%esi),%eax
  800324:	46                   	inc    %esi
  800325:	83 f8 25             	cmp    $0x25,%eax
  800328:	75 e4                	jne    80030e <vprintfmt+0x11>
  80032a:	c6 45 dc 20          	movb   $0x20,-0x24(%ebp)
  80032e:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  800335:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  80033c:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800343:	b9 00 00 00 00       	mov    $0x0,%ecx
  800348:	eb 28                	jmp    800372 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80034a:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  80034c:	c6 45 dc 2d          	movb   $0x2d,-0x24(%ebp)
  800350:	eb 20                	jmp    800372 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800352:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800354:	c6 45 dc 30          	movb   $0x30,-0x24(%ebp)
  800358:	eb 18                	jmp    800372 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80035a:	89 de                	mov    %ebx,%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  80035c:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800363:	eb 0d                	jmp    800372 <vprintfmt+0x75>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800365:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800368:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80036b:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800372:	8a 06                	mov    (%esi),%al
  800374:	0f b6 d0             	movzbl %al,%edx
  800377:	8d 5e 01             	lea    0x1(%esi),%ebx
  80037a:	83 e8 23             	sub    $0x23,%eax
  80037d:	3c 55                	cmp    $0x55,%al
  80037f:	0f 87 e0 02 00 00    	ja     800665 <vprintfmt+0x368>
  800385:	0f b6 c0             	movzbl %al,%eax
  800388:	ff 24 85 80 1f 80 00 	jmp    *0x801f80(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80038f:	83 ea 30             	sub    $0x30,%edx
  800392:	89 55 d4             	mov    %edx,-0x2c(%ebp)
				ch = *fmt;
  800395:	0f be 03             	movsbl (%ebx),%eax
				if (ch < '0' || ch > '9')
  800398:	8d 50 d0             	lea    -0x30(%eax),%edx
  80039b:	83 fa 09             	cmp    $0x9,%edx
  80039e:	77 44                	ja     8003e4 <vprintfmt+0xe7>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003a0:	89 de                	mov    %ebx,%esi
  8003a2:	8b 55 d4             	mov    -0x2c(%ebp),%edx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003a5:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
  8003a6:	8d 14 92             	lea    (%edx,%edx,4),%edx
  8003a9:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
  8003ad:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8003b0:	8d 58 d0             	lea    -0x30(%eax),%ebx
  8003b3:	83 fb 09             	cmp    $0x9,%ebx
  8003b6:	76 ed                	jbe    8003a5 <vprintfmt+0xa8>
  8003b8:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  8003bb:	eb 29                	jmp    8003e6 <vprintfmt+0xe9>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003bd:	8b 45 14             	mov    0x14(%ebp),%eax
  8003c0:	8d 50 04             	lea    0x4(%eax),%edx
  8003c3:	89 55 14             	mov    %edx,0x14(%ebp)
  8003c6:	8b 00                	mov    (%eax),%eax
  8003c8:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003cb:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8003cd:	eb 17                	jmp    8003e6 <vprintfmt+0xe9>

		case '.':
			if (width < 0)
  8003cf:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8003d3:	78 85                	js     80035a <vprintfmt+0x5d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003d5:	89 de                	mov    %ebx,%esi
  8003d7:	eb 99                	jmp    800372 <vprintfmt+0x75>
  8003d9:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8003db:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  8003e2:	eb 8e                	jmp    800372 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003e4:	89 de                	mov    %ebx,%esi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  8003e6:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8003ea:	79 86                	jns    800372 <vprintfmt+0x75>
  8003ec:	e9 74 ff ff ff       	jmp    800365 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8003f1:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003f2:	89 de                	mov    %ebx,%esi
  8003f4:	e9 79 ff ff ff       	jmp    800372 <vprintfmt+0x75>
  8003f9:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8003fc:	8b 45 14             	mov    0x14(%ebp),%eax
  8003ff:	8d 50 04             	lea    0x4(%eax),%edx
  800402:	89 55 14             	mov    %edx,0x14(%ebp)
  800405:	83 ec 08             	sub    $0x8,%esp
  800408:	57                   	push   %edi
  800409:	ff 30                	pushl  (%eax)
  80040b:	ff 55 08             	call   *0x8(%ebp)
			break;
  80040e:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800411:	8b 75 d8             	mov    -0x28(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800414:	e9 08 ff ff ff       	jmp    800321 <vprintfmt+0x24>
  800419:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  80041c:	8b 45 14             	mov    0x14(%ebp),%eax
  80041f:	8d 50 04             	lea    0x4(%eax),%edx
  800422:	89 55 14             	mov    %edx,0x14(%ebp)
  800425:	8b 00                	mov    (%eax),%eax
  800427:	85 c0                	test   %eax,%eax
  800429:	79 02                	jns    80042d <vprintfmt+0x130>
  80042b:	f7 d8                	neg    %eax
  80042d:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80042f:	83 f8 0f             	cmp    $0xf,%eax
  800432:	7f 0b                	jg     80043f <vprintfmt+0x142>
  800434:	8b 04 85 e0 20 80 00 	mov    0x8020e0(,%eax,4),%eax
  80043b:	85 c0                	test   %eax,%eax
  80043d:	75 1a                	jne    800459 <vprintfmt+0x15c>
				printfmt(putch, putdat, "error %d", err);
  80043f:	52                   	push   %edx
  800440:	68 4d 1e 80 00       	push   $0x801e4d
  800445:	57                   	push   %edi
  800446:	ff 75 08             	pushl  0x8(%ebp)
  800449:	e8 92 fe ff ff       	call   8002e0 <printfmt>
  80044e:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800451:	8b 75 d8             	mov    -0x28(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800454:	e9 c8 fe ff ff       	jmp    800321 <vprintfmt+0x24>
			else
				printfmt(putch, putdat, "%s", p);
  800459:	50                   	push   %eax
  80045a:	68 11 22 80 00       	push   $0x802211
  80045f:	57                   	push   %edi
  800460:	ff 75 08             	pushl  0x8(%ebp)
  800463:	e8 78 fe ff ff       	call   8002e0 <printfmt>
  800468:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80046b:	8b 75 d8             	mov    -0x28(%ebp),%esi
  80046e:	e9 ae fe ff ff       	jmp    800321 <vprintfmt+0x24>
  800473:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  800476:	89 de                	mov    %ebx,%esi
  800478:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  80047b:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80047e:	8b 45 14             	mov    0x14(%ebp),%eax
  800481:	8d 50 04             	lea    0x4(%eax),%edx
  800484:	89 55 14             	mov    %edx,0x14(%ebp)
  800487:	8b 00                	mov    (%eax),%eax
  800489:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80048c:	85 c0                	test   %eax,%eax
  80048e:	75 07                	jne    800497 <vprintfmt+0x19a>
				p = "(null)";
  800490:	c7 45 d0 46 1e 80 00 	movl   $0x801e46,-0x30(%ebp)
			if (width > 0 && padc != '-')
  800497:	85 db                	test   %ebx,%ebx
  800499:	7e 42                	jle    8004dd <vprintfmt+0x1e0>
  80049b:	80 7d dc 2d          	cmpb   $0x2d,-0x24(%ebp)
  80049f:	74 3c                	je     8004dd <vprintfmt+0x1e0>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004a1:	83 ec 08             	sub    $0x8,%esp
  8004a4:	51                   	push   %ecx
  8004a5:	ff 75 d0             	pushl  -0x30(%ebp)
  8004a8:	e8 6f 02 00 00       	call   80071c <strnlen>
  8004ad:	29 c3                	sub    %eax,%ebx
  8004af:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8004b2:	83 c4 10             	add    $0x10,%esp
  8004b5:	85 db                	test   %ebx,%ebx
  8004b7:	7e 24                	jle    8004dd <vprintfmt+0x1e0>
					putch(padc, putdat);
  8004b9:	0f be 5d dc          	movsbl -0x24(%ebp),%ebx
  8004bd:	89 75 dc             	mov    %esi,-0x24(%ebp)
  8004c0:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  8004c3:	83 ec 08             	sub    $0x8,%esp
  8004c6:	57                   	push   %edi
  8004c7:	53                   	push   %ebx
  8004c8:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004cb:	4e                   	dec    %esi
  8004cc:	83 c4 10             	add    $0x10,%esp
  8004cf:	85 f6                	test   %esi,%esi
  8004d1:	7f f0                	jg     8004c3 <vprintfmt+0x1c6>
  8004d3:	8b 75 dc             	mov    -0x24(%ebp),%esi
  8004d6:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004dd:	8b 55 d0             	mov    -0x30(%ebp),%edx
  8004e0:	0f be 02             	movsbl (%edx),%eax
  8004e3:	85 c0                	test   %eax,%eax
  8004e5:	75 47                	jne    80052e <vprintfmt+0x231>
  8004e7:	eb 37                	jmp    800520 <vprintfmt+0x223>
				if (altflag && (ch < ' ' || ch > '~'))
  8004e9:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004ed:	74 16                	je     800505 <vprintfmt+0x208>
  8004ef:	8d 50 e0             	lea    -0x20(%eax),%edx
  8004f2:	83 fa 5e             	cmp    $0x5e,%edx
  8004f5:	76 0e                	jbe    800505 <vprintfmt+0x208>
					putch('?', putdat);
  8004f7:	83 ec 08             	sub    $0x8,%esp
  8004fa:	57                   	push   %edi
  8004fb:	6a 3f                	push   $0x3f
  8004fd:	ff 55 08             	call   *0x8(%ebp)
  800500:	83 c4 10             	add    $0x10,%esp
  800503:	eb 0b                	jmp    800510 <vprintfmt+0x213>
				else
					putch(ch, putdat);
  800505:	83 ec 08             	sub    $0x8,%esp
  800508:	57                   	push   %edi
  800509:	50                   	push   %eax
  80050a:	ff 55 08             	call   *0x8(%ebp)
  80050d:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800510:	ff 4d e4             	decl   -0x1c(%ebp)
  800513:	0f be 03             	movsbl (%ebx),%eax
  800516:	85 c0                	test   %eax,%eax
  800518:	74 03                	je     80051d <vprintfmt+0x220>
  80051a:	43                   	inc    %ebx
  80051b:	eb 1b                	jmp    800538 <vprintfmt+0x23b>
  80051d:	8b 75 dc             	mov    -0x24(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800520:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800524:	7f 1e                	jg     800544 <vprintfmt+0x247>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800526:	8b 75 d8             	mov    -0x28(%ebp),%esi
  800529:	e9 f3 fd ff ff       	jmp    800321 <vprintfmt+0x24>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80052e:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800531:	43                   	inc    %ebx
  800532:	89 75 dc             	mov    %esi,-0x24(%ebp)
  800535:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  800538:	85 f6                	test   %esi,%esi
  80053a:	78 ad                	js     8004e9 <vprintfmt+0x1ec>
  80053c:	4e                   	dec    %esi
  80053d:	79 aa                	jns    8004e9 <vprintfmt+0x1ec>
  80053f:	8b 75 dc             	mov    -0x24(%ebp),%esi
  800542:	eb dc                	jmp    800520 <vprintfmt+0x223>
  800544:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800547:	83 ec 08             	sub    $0x8,%esp
  80054a:	57                   	push   %edi
  80054b:	6a 20                	push   $0x20
  80054d:	ff 55 08             	call   *0x8(%ebp)
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800550:	4b                   	dec    %ebx
  800551:	83 c4 10             	add    $0x10,%esp
  800554:	85 db                	test   %ebx,%ebx
  800556:	7f ef                	jg     800547 <vprintfmt+0x24a>
  800558:	e9 c4 fd ff ff       	jmp    800321 <vprintfmt+0x24>
  80055d:	89 5d d8             	mov    %ebx,-0x28(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800560:	89 ca                	mov    %ecx,%edx
  800562:	8d 45 14             	lea    0x14(%ebp),%eax
  800565:	e8 2a fd ff ff       	call   800294 <getint>
  80056a:	89 c3                	mov    %eax,%ebx
  80056c:	89 d6                	mov    %edx,%esi
			if ((long long) num < 0) {
  80056e:	85 d2                	test   %edx,%edx
  800570:	78 0a                	js     80057c <vprintfmt+0x27f>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800572:	b8 0a 00 00 00       	mov    $0xa,%eax
  800577:	e9 b0 00 00 00       	jmp    80062c <vprintfmt+0x32f>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  80057c:	83 ec 08             	sub    $0x8,%esp
  80057f:	57                   	push   %edi
  800580:	6a 2d                	push   $0x2d
  800582:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800585:	f7 db                	neg    %ebx
  800587:	83 d6 00             	adc    $0x0,%esi
  80058a:	f7 de                	neg    %esi
  80058c:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  80058f:	b8 0a 00 00 00       	mov    $0xa,%eax
  800594:	e9 93 00 00 00       	jmp    80062c <vprintfmt+0x32f>
  800599:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80059c:	89 ca                	mov    %ecx,%edx
  80059e:	8d 45 14             	lea    0x14(%ebp),%eax
  8005a1:	e8 b4 fc ff ff       	call   80025a <getuint>
  8005a6:	89 c3                	mov    %eax,%ebx
  8005a8:	89 d6                	mov    %edx,%esi
			base = 10;
  8005aa:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  8005af:	eb 7b                	jmp    80062c <vprintfmt+0x32f>
  8005b1:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
  8005b4:	89 ca                	mov    %ecx,%edx
  8005b6:	8d 45 14             	lea    0x14(%ebp),%eax
  8005b9:	e8 d6 fc ff ff       	call   800294 <getint>
  8005be:	89 c3                	mov    %eax,%ebx
  8005c0:	89 d6                	mov    %edx,%esi
            if ((long long) num < 0) {
  8005c2:	85 d2                	test   %edx,%edx
  8005c4:	78 07                	js     8005cd <vprintfmt+0x2d0>
                putch('-', putdat);
                num = -(long long) num;
            }
            base = 8;
  8005c6:	b8 08 00 00 00       	mov    $0x8,%eax
  8005cb:	eb 5f                	jmp    80062c <vprintfmt+0x32f>
		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
            if ((long long) num < 0) {
                putch('-', putdat);
  8005cd:	83 ec 08             	sub    $0x8,%esp
  8005d0:	57                   	push   %edi
  8005d1:	6a 2d                	push   $0x2d
  8005d3:	ff 55 08             	call   *0x8(%ebp)
                num = -(long long) num;
  8005d6:	f7 db                	neg    %ebx
  8005d8:	83 d6 00             	adc    $0x0,%esi
  8005db:	f7 de                	neg    %esi
  8005dd:	83 c4 10             	add    $0x10,%esp
            }
            base = 8;
  8005e0:	b8 08 00 00 00       	mov    $0x8,%eax
  8005e5:	eb 45                	jmp    80062c <vprintfmt+0x32f>
  8005e7:	89 5d d8             	mov    %ebx,-0x28(%ebp)
            goto number;

        // pointer
		case 'p':
			putch('0', putdat);
  8005ea:	83 ec 08             	sub    $0x8,%esp
  8005ed:	57                   	push   %edi
  8005ee:	6a 30                	push   $0x30
  8005f0:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8005f3:	83 c4 08             	add    $0x8,%esp
  8005f6:	57                   	push   %edi
  8005f7:	6a 78                	push   $0x78
  8005f9:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8005fc:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ff:	8d 50 04             	lea    0x4(%eax),%edx
  800602:	89 55 14             	mov    %edx,0x14(%ebp)

        // pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800605:	8b 18                	mov    (%eax),%ebx
  800607:	be 00 00 00 00       	mov    $0x0,%esi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80060c:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80060f:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800614:	eb 16                	jmp    80062c <vprintfmt+0x32f>
  800616:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800619:	89 ca                	mov    %ecx,%edx
  80061b:	8d 45 14             	lea    0x14(%ebp),%eax
  80061e:	e8 37 fc ff ff       	call   80025a <getuint>
  800623:	89 c3                	mov    %eax,%ebx
  800625:	89 d6                	mov    %edx,%esi
			base = 16;
  800627:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  80062c:	83 ec 0c             	sub    $0xc,%esp
  80062f:	0f be 55 dc          	movsbl -0x24(%ebp),%edx
  800633:	52                   	push   %edx
  800634:	ff 75 e4             	pushl  -0x1c(%ebp)
  800637:	50                   	push   %eax
  800638:	56                   	push   %esi
  800639:	53                   	push   %ebx
  80063a:	89 fa                	mov    %edi,%edx
  80063c:	8b 45 08             	mov    0x8(%ebp),%eax
  80063f:	e8 68 fb ff ff       	call   8001ac <printnum>
			break;
  800644:	83 c4 20             	add    $0x20,%esp
  800647:	8b 75 d8             	mov    -0x28(%ebp),%esi
  80064a:	e9 d2 fc ff ff       	jmp    800321 <vprintfmt+0x24>
  80064f:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800652:	83 ec 08             	sub    $0x8,%esp
  800655:	57                   	push   %edi
  800656:	52                   	push   %edx
  800657:	ff 55 08             	call   *0x8(%ebp)
			break;
  80065a:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80065d:	8b 75 d8             	mov    -0x28(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800660:	e9 bc fc ff ff       	jmp    800321 <vprintfmt+0x24>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800665:	83 ec 08             	sub    $0x8,%esp
  800668:	57                   	push   %edi
  800669:	6a 25                	push   $0x25
  80066b:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  80066e:	83 c4 10             	add    $0x10,%esp
  800671:	eb 02                	jmp    800675 <vprintfmt+0x378>
  800673:	89 c6                	mov    %eax,%esi
  800675:	8d 46 ff             	lea    -0x1(%esi),%eax
  800678:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  80067c:	75 f5                	jne    800673 <vprintfmt+0x376>
  80067e:	e9 9e fc ff ff       	jmp    800321 <vprintfmt+0x24>
				/* do nothing */;
			break;
		}
	}
}
  800683:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800686:	5b                   	pop    %ebx
  800687:	5e                   	pop    %esi
  800688:	5f                   	pop    %edi
  800689:	c9                   	leave  
  80068a:	c3                   	ret    

0080068b <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80068b:	55                   	push   %ebp
  80068c:	89 e5                	mov    %esp,%ebp
  80068e:	83 ec 18             	sub    $0x18,%esp
  800691:	8b 45 08             	mov    0x8(%ebp),%eax
  800694:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800697:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80069a:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80069e:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8006a1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8006a8:	85 c0                	test   %eax,%eax
  8006aa:	74 26                	je     8006d2 <vsnprintf+0x47>
  8006ac:	85 d2                	test   %edx,%edx
  8006ae:	7e 29                	jle    8006d9 <vsnprintf+0x4e>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8006b0:	ff 75 14             	pushl  0x14(%ebp)
  8006b3:	ff 75 10             	pushl  0x10(%ebp)
  8006b6:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8006b9:	50                   	push   %eax
  8006ba:	68 c6 02 80 00       	push   $0x8002c6
  8006bf:	e8 39 fc ff ff       	call   8002fd <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8006c4:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8006c7:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8006ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006cd:	83 c4 10             	add    $0x10,%esp
  8006d0:	eb 0c                	jmp    8006de <vsnprintf+0x53>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8006d2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8006d7:	eb 05                	jmp    8006de <vsnprintf+0x53>
  8006d9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8006de:	c9                   	leave  
  8006df:	c3                   	ret    

008006e0 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8006e0:	55                   	push   %ebp
  8006e1:	89 e5                	mov    %esp,%ebp
  8006e3:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8006e6:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8006e9:	50                   	push   %eax
  8006ea:	ff 75 10             	pushl  0x10(%ebp)
  8006ed:	ff 75 0c             	pushl  0xc(%ebp)
  8006f0:	ff 75 08             	pushl  0x8(%ebp)
  8006f3:	e8 93 ff ff ff       	call   80068b <vsnprintf>
	va_end(ap);

	return rc;
}
  8006f8:	c9                   	leave  
  8006f9:	c3                   	ret    
	...

008006fc <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8006fc:	55                   	push   %ebp
  8006fd:	89 e5                	mov    %esp,%ebp
  8006ff:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800702:	80 3a 00             	cmpb   $0x0,(%edx)
  800705:	74 0e                	je     800715 <strlen+0x19>
  800707:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  80070c:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80070d:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800711:	75 f9                	jne    80070c <strlen+0x10>
  800713:	eb 05                	jmp    80071a <strlen+0x1e>
  800715:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  80071a:	c9                   	leave  
  80071b:	c3                   	ret    

0080071c <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80071c:	55                   	push   %ebp
  80071d:	89 e5                	mov    %esp,%ebp
  80071f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800722:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800725:	85 d2                	test   %edx,%edx
  800727:	74 17                	je     800740 <strnlen+0x24>
  800729:	80 39 00             	cmpb   $0x0,(%ecx)
  80072c:	74 19                	je     800747 <strnlen+0x2b>
  80072e:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800733:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800734:	39 d0                	cmp    %edx,%eax
  800736:	74 14                	je     80074c <strnlen+0x30>
  800738:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  80073c:	75 f5                	jne    800733 <strnlen+0x17>
  80073e:	eb 0c                	jmp    80074c <strnlen+0x30>
  800740:	b8 00 00 00 00       	mov    $0x0,%eax
  800745:	eb 05                	jmp    80074c <strnlen+0x30>
  800747:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  80074c:	c9                   	leave  
  80074d:	c3                   	ret    

0080074e <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80074e:	55                   	push   %ebp
  80074f:	89 e5                	mov    %esp,%ebp
  800751:	53                   	push   %ebx
  800752:	8b 45 08             	mov    0x8(%ebp),%eax
  800755:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800758:	ba 00 00 00 00       	mov    $0x0,%edx
  80075d:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  800760:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800763:	42                   	inc    %edx
  800764:	84 c9                	test   %cl,%cl
  800766:	75 f5                	jne    80075d <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800768:	5b                   	pop    %ebx
  800769:	c9                   	leave  
  80076a:	c3                   	ret    

0080076b <strcat>:

char *
strcat(char *dst, const char *src)
{
  80076b:	55                   	push   %ebp
  80076c:	89 e5                	mov    %esp,%ebp
  80076e:	53                   	push   %ebx
  80076f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800772:	53                   	push   %ebx
  800773:	e8 84 ff ff ff       	call   8006fc <strlen>
  800778:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  80077b:	ff 75 0c             	pushl  0xc(%ebp)
  80077e:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  800781:	50                   	push   %eax
  800782:	e8 c7 ff ff ff       	call   80074e <strcpy>
	return dst;
}
  800787:	89 d8                	mov    %ebx,%eax
  800789:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80078c:	c9                   	leave  
  80078d:	c3                   	ret    

0080078e <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80078e:	55                   	push   %ebp
  80078f:	89 e5                	mov    %esp,%ebp
  800791:	56                   	push   %esi
  800792:	53                   	push   %ebx
  800793:	8b 45 08             	mov    0x8(%ebp),%eax
  800796:	8b 55 0c             	mov    0xc(%ebp),%edx
  800799:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80079c:	85 f6                	test   %esi,%esi
  80079e:	74 15                	je     8007b5 <strncpy+0x27>
  8007a0:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  8007a5:	8a 1a                	mov    (%edx),%bl
  8007a7:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007aa:	80 3a 01             	cmpb   $0x1,(%edx)
  8007ad:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007b0:	41                   	inc    %ecx
  8007b1:	39 ce                	cmp    %ecx,%esi
  8007b3:	77 f0                	ja     8007a5 <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8007b5:	5b                   	pop    %ebx
  8007b6:	5e                   	pop    %esi
  8007b7:	c9                   	leave  
  8007b8:	c3                   	ret    

008007b9 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8007b9:	55                   	push   %ebp
  8007ba:	89 e5                	mov    %esp,%ebp
  8007bc:	57                   	push   %edi
  8007bd:	56                   	push   %esi
  8007be:	53                   	push   %ebx
  8007bf:	8b 7d 08             	mov    0x8(%ebp),%edi
  8007c2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8007c5:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007c8:	85 f6                	test   %esi,%esi
  8007ca:	74 32                	je     8007fe <strlcpy+0x45>
		while (--size > 0 && *src != '\0')
  8007cc:	83 fe 01             	cmp    $0x1,%esi
  8007cf:	74 22                	je     8007f3 <strlcpy+0x3a>
  8007d1:	8a 0b                	mov    (%ebx),%cl
  8007d3:	84 c9                	test   %cl,%cl
  8007d5:	74 20                	je     8007f7 <strlcpy+0x3e>
  8007d7:	89 f8                	mov    %edi,%eax
  8007d9:	ba 00 00 00 00       	mov    $0x0,%edx
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
  8007de:	83 ee 02             	sub    $0x2,%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8007e1:	88 08                	mov    %cl,(%eax)
  8007e3:	40                   	inc    %eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8007e4:	39 f2                	cmp    %esi,%edx
  8007e6:	74 11                	je     8007f9 <strlcpy+0x40>
  8007e8:	8a 4c 13 01          	mov    0x1(%ebx,%edx,1),%cl
  8007ec:	42                   	inc    %edx
  8007ed:	84 c9                	test   %cl,%cl
  8007ef:	75 f0                	jne    8007e1 <strlcpy+0x28>
  8007f1:	eb 06                	jmp    8007f9 <strlcpy+0x40>
  8007f3:	89 f8                	mov    %edi,%eax
  8007f5:	eb 02                	jmp    8007f9 <strlcpy+0x40>
  8007f7:	89 f8                	mov    %edi,%eax
			*dst++ = *src++;
		*dst = '\0';
  8007f9:	c6 00 00             	movb   $0x0,(%eax)
  8007fc:	eb 02                	jmp    800800 <strlcpy+0x47>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007fe:	89 f8                	mov    %edi,%eax
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
		*dst = '\0';
	}
	return dst - dst_in;
  800800:	29 f8                	sub    %edi,%eax
}
  800802:	5b                   	pop    %ebx
  800803:	5e                   	pop    %esi
  800804:	5f                   	pop    %edi
  800805:	c9                   	leave  
  800806:	c3                   	ret    

00800807 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800807:	55                   	push   %ebp
  800808:	89 e5                	mov    %esp,%ebp
  80080a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80080d:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800810:	8a 01                	mov    (%ecx),%al
  800812:	84 c0                	test   %al,%al
  800814:	74 10                	je     800826 <strcmp+0x1f>
  800816:	3a 02                	cmp    (%edx),%al
  800818:	75 0c                	jne    800826 <strcmp+0x1f>
		p++, q++;
  80081a:	41                   	inc    %ecx
  80081b:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80081c:	8a 01                	mov    (%ecx),%al
  80081e:	84 c0                	test   %al,%al
  800820:	74 04                	je     800826 <strcmp+0x1f>
  800822:	3a 02                	cmp    (%edx),%al
  800824:	74 f4                	je     80081a <strcmp+0x13>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800826:	0f b6 c0             	movzbl %al,%eax
  800829:	0f b6 12             	movzbl (%edx),%edx
  80082c:	29 d0                	sub    %edx,%eax
}
  80082e:	c9                   	leave  
  80082f:	c3                   	ret    

00800830 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800830:	55                   	push   %ebp
  800831:	89 e5                	mov    %esp,%ebp
  800833:	53                   	push   %ebx
  800834:	8b 55 08             	mov    0x8(%ebp),%edx
  800837:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80083a:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  80083d:	85 c0                	test   %eax,%eax
  80083f:	74 1b                	je     80085c <strncmp+0x2c>
  800841:	8a 1a                	mov    (%edx),%bl
  800843:	84 db                	test   %bl,%bl
  800845:	74 24                	je     80086b <strncmp+0x3b>
  800847:	3a 19                	cmp    (%ecx),%bl
  800849:	75 20                	jne    80086b <strncmp+0x3b>
  80084b:	48                   	dec    %eax
  80084c:	74 15                	je     800863 <strncmp+0x33>
		n--, p++, q++;
  80084e:	42                   	inc    %edx
  80084f:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800850:	8a 1a                	mov    (%edx),%bl
  800852:	84 db                	test   %bl,%bl
  800854:	74 15                	je     80086b <strncmp+0x3b>
  800856:	3a 19                	cmp    (%ecx),%bl
  800858:	74 f1                	je     80084b <strncmp+0x1b>
  80085a:	eb 0f                	jmp    80086b <strncmp+0x3b>
		n--, p++, q++;
	if (n == 0)
		return 0;
  80085c:	b8 00 00 00 00       	mov    $0x0,%eax
  800861:	eb 05                	jmp    800868 <strncmp+0x38>
  800863:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800868:	5b                   	pop    %ebx
  800869:	c9                   	leave  
  80086a:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80086b:	0f b6 02             	movzbl (%edx),%eax
  80086e:	0f b6 11             	movzbl (%ecx),%edx
  800871:	29 d0                	sub    %edx,%eax
  800873:	eb f3                	jmp    800868 <strncmp+0x38>

00800875 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800875:	55                   	push   %ebp
  800876:	89 e5                	mov    %esp,%ebp
  800878:	8b 45 08             	mov    0x8(%ebp),%eax
  80087b:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  80087e:	8a 10                	mov    (%eax),%dl
  800880:	84 d2                	test   %dl,%dl
  800882:	74 18                	je     80089c <strchr+0x27>
		if (*s == c)
  800884:	38 ca                	cmp    %cl,%dl
  800886:	75 06                	jne    80088e <strchr+0x19>
  800888:	eb 17                	jmp    8008a1 <strchr+0x2c>
  80088a:	38 ca                	cmp    %cl,%dl
  80088c:	74 13                	je     8008a1 <strchr+0x2c>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80088e:	40                   	inc    %eax
  80088f:	8a 10                	mov    (%eax),%dl
  800891:	84 d2                	test   %dl,%dl
  800893:	75 f5                	jne    80088a <strchr+0x15>
		if (*s == c)
			return (char *) s;
	return 0;
  800895:	b8 00 00 00 00       	mov    $0x0,%eax
  80089a:	eb 05                	jmp    8008a1 <strchr+0x2c>
  80089c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008a1:	c9                   	leave  
  8008a2:	c3                   	ret    

008008a3 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008a3:	55                   	push   %ebp
  8008a4:	89 e5                	mov    %esp,%ebp
  8008a6:	8b 45 08             	mov    0x8(%ebp),%eax
  8008a9:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8008ac:	8a 10                	mov    (%eax),%dl
  8008ae:	84 d2                	test   %dl,%dl
  8008b0:	74 11                	je     8008c3 <strfind+0x20>
		if (*s == c)
  8008b2:	38 ca                	cmp    %cl,%dl
  8008b4:	75 06                	jne    8008bc <strfind+0x19>
  8008b6:	eb 0b                	jmp    8008c3 <strfind+0x20>
  8008b8:	38 ca                	cmp    %cl,%dl
  8008ba:	74 07                	je     8008c3 <strfind+0x20>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  8008bc:	40                   	inc    %eax
  8008bd:	8a 10                	mov    (%eax),%dl
  8008bf:	84 d2                	test   %dl,%dl
  8008c1:	75 f5                	jne    8008b8 <strfind+0x15>
		if (*s == c)
			break;
	return (char *) s;
}
  8008c3:	c9                   	leave  
  8008c4:	c3                   	ret    

008008c5 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008c5:	55                   	push   %ebp
  8008c6:	89 e5                	mov    %esp,%ebp
  8008c8:	57                   	push   %edi
  8008c9:	56                   	push   %esi
  8008ca:	53                   	push   %ebx
  8008cb:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008ce:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008d1:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8008d4:	85 c9                	test   %ecx,%ecx
  8008d6:	74 30                	je     800908 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008d8:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008de:	75 25                	jne    800905 <memset+0x40>
  8008e0:	f6 c1 03             	test   $0x3,%cl
  8008e3:	75 20                	jne    800905 <memset+0x40>
		c &= 0xFF;
  8008e5:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8008e8:	89 d3                	mov    %edx,%ebx
  8008ea:	c1 e3 08             	shl    $0x8,%ebx
  8008ed:	89 d6                	mov    %edx,%esi
  8008ef:	c1 e6 18             	shl    $0x18,%esi
  8008f2:	89 d0                	mov    %edx,%eax
  8008f4:	c1 e0 10             	shl    $0x10,%eax
  8008f7:	09 f0                	or     %esi,%eax
  8008f9:	09 d0                	or     %edx,%eax
  8008fb:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  8008fd:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800900:	fc                   	cld    
  800901:	f3 ab                	rep stos %eax,%es:(%edi)
  800903:	eb 03                	jmp    800908 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800905:	fc                   	cld    
  800906:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800908:	89 f8                	mov    %edi,%eax
  80090a:	5b                   	pop    %ebx
  80090b:	5e                   	pop    %esi
  80090c:	5f                   	pop    %edi
  80090d:	c9                   	leave  
  80090e:	c3                   	ret    

0080090f <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80090f:	55                   	push   %ebp
  800910:	89 e5                	mov    %esp,%ebp
  800912:	57                   	push   %edi
  800913:	56                   	push   %esi
  800914:	8b 45 08             	mov    0x8(%ebp),%eax
  800917:	8b 75 0c             	mov    0xc(%ebp),%esi
  80091a:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80091d:	39 c6                	cmp    %eax,%esi
  80091f:	73 34                	jae    800955 <memmove+0x46>
  800921:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800924:	39 d0                	cmp    %edx,%eax
  800926:	73 2d                	jae    800955 <memmove+0x46>
		s += n;
		d += n;
  800928:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80092b:	f6 c2 03             	test   $0x3,%dl
  80092e:	75 1b                	jne    80094b <memmove+0x3c>
  800930:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800936:	75 13                	jne    80094b <memmove+0x3c>
  800938:	f6 c1 03             	test   $0x3,%cl
  80093b:	75 0e                	jne    80094b <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  80093d:	83 ef 04             	sub    $0x4,%edi
  800940:	8d 72 fc             	lea    -0x4(%edx),%esi
  800943:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800946:	fd                   	std    
  800947:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800949:	eb 07                	jmp    800952 <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  80094b:	4f                   	dec    %edi
  80094c:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  80094f:	fd                   	std    
  800950:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800952:	fc                   	cld    
  800953:	eb 20                	jmp    800975 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800955:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80095b:	75 13                	jne    800970 <memmove+0x61>
  80095d:	a8 03                	test   $0x3,%al
  80095f:	75 0f                	jne    800970 <memmove+0x61>
  800961:	f6 c1 03             	test   $0x3,%cl
  800964:	75 0a                	jne    800970 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800966:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800969:	89 c7                	mov    %eax,%edi
  80096b:	fc                   	cld    
  80096c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80096e:	eb 05                	jmp    800975 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800970:	89 c7                	mov    %eax,%edi
  800972:	fc                   	cld    
  800973:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800975:	5e                   	pop    %esi
  800976:	5f                   	pop    %edi
  800977:	c9                   	leave  
  800978:	c3                   	ret    

00800979 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800979:	55                   	push   %ebp
  80097a:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  80097c:	ff 75 10             	pushl  0x10(%ebp)
  80097f:	ff 75 0c             	pushl  0xc(%ebp)
  800982:	ff 75 08             	pushl  0x8(%ebp)
  800985:	e8 85 ff ff ff       	call   80090f <memmove>
}
  80098a:	c9                   	leave  
  80098b:	c3                   	ret    

0080098c <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  80098c:	55                   	push   %ebp
  80098d:	89 e5                	mov    %esp,%ebp
  80098f:	57                   	push   %edi
  800990:	56                   	push   %esi
  800991:	53                   	push   %ebx
  800992:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800995:	8b 75 0c             	mov    0xc(%ebp),%esi
  800998:	8b 7d 10             	mov    0x10(%ebp),%edi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80099b:	85 ff                	test   %edi,%edi
  80099d:	74 32                	je     8009d1 <memcmp+0x45>
		if (*s1 != *s2)
  80099f:	8a 03                	mov    (%ebx),%al
  8009a1:	8a 0e                	mov    (%esi),%cl
  8009a3:	38 c8                	cmp    %cl,%al
  8009a5:	74 19                	je     8009c0 <memcmp+0x34>
  8009a7:	eb 0d                	jmp    8009b6 <memcmp+0x2a>
  8009a9:	8a 44 13 01          	mov    0x1(%ebx,%edx,1),%al
  8009ad:	8a 4c 16 01          	mov    0x1(%esi,%edx,1),%cl
  8009b1:	42                   	inc    %edx
  8009b2:	38 c8                	cmp    %cl,%al
  8009b4:	74 10                	je     8009c6 <memcmp+0x3a>
			return (int) *s1 - (int) *s2;
  8009b6:	0f b6 c0             	movzbl %al,%eax
  8009b9:	0f b6 c9             	movzbl %cl,%ecx
  8009bc:	29 c8                	sub    %ecx,%eax
  8009be:	eb 16                	jmp    8009d6 <memcmp+0x4a>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009c0:	4f                   	dec    %edi
  8009c1:	ba 00 00 00 00       	mov    $0x0,%edx
  8009c6:	39 fa                	cmp    %edi,%edx
  8009c8:	75 df                	jne    8009a9 <memcmp+0x1d>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8009ca:	b8 00 00 00 00       	mov    $0x0,%eax
  8009cf:	eb 05                	jmp    8009d6 <memcmp+0x4a>
  8009d1:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009d6:	5b                   	pop    %ebx
  8009d7:	5e                   	pop    %esi
  8009d8:	5f                   	pop    %edi
  8009d9:	c9                   	leave  
  8009da:	c3                   	ret    

008009db <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009db:	55                   	push   %ebp
  8009dc:	89 e5                	mov    %esp,%ebp
  8009de:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  8009e1:	89 c2                	mov    %eax,%edx
  8009e3:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  8009e6:	39 d0                	cmp    %edx,%eax
  8009e8:	73 12                	jae    8009fc <memfind+0x21>
		if (*(const unsigned char *) s == (unsigned char) c)
  8009ea:	8a 4d 0c             	mov    0xc(%ebp),%cl
  8009ed:	38 08                	cmp    %cl,(%eax)
  8009ef:	75 06                	jne    8009f7 <memfind+0x1c>
  8009f1:	eb 09                	jmp    8009fc <memfind+0x21>
  8009f3:	38 08                	cmp    %cl,(%eax)
  8009f5:	74 05                	je     8009fc <memfind+0x21>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009f7:	40                   	inc    %eax
  8009f8:	39 c2                	cmp    %eax,%edx
  8009fa:	77 f7                	ja     8009f3 <memfind+0x18>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8009fc:	c9                   	leave  
  8009fd:	c3                   	ret    

008009fe <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8009fe:	55                   	push   %ebp
  8009ff:	89 e5                	mov    %esp,%ebp
  800a01:	57                   	push   %edi
  800a02:	56                   	push   %esi
  800a03:	53                   	push   %ebx
  800a04:	8b 55 08             	mov    0x8(%ebp),%edx
  800a07:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a0a:	eb 01                	jmp    800a0d <strtol+0xf>
		s++;
  800a0c:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a0d:	8a 02                	mov    (%edx),%al
  800a0f:	3c 20                	cmp    $0x20,%al
  800a11:	74 f9                	je     800a0c <strtol+0xe>
  800a13:	3c 09                	cmp    $0x9,%al
  800a15:	74 f5                	je     800a0c <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a17:	3c 2b                	cmp    $0x2b,%al
  800a19:	75 08                	jne    800a23 <strtol+0x25>
		s++;
  800a1b:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a1c:	bf 00 00 00 00       	mov    $0x0,%edi
  800a21:	eb 13                	jmp    800a36 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a23:	3c 2d                	cmp    $0x2d,%al
  800a25:	75 0a                	jne    800a31 <strtol+0x33>
		s++, neg = 1;
  800a27:	8d 52 01             	lea    0x1(%edx),%edx
  800a2a:	bf 01 00 00 00       	mov    $0x1,%edi
  800a2f:	eb 05                	jmp    800a36 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a31:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a36:	85 db                	test   %ebx,%ebx
  800a38:	74 05                	je     800a3f <strtol+0x41>
  800a3a:	83 fb 10             	cmp    $0x10,%ebx
  800a3d:	75 28                	jne    800a67 <strtol+0x69>
  800a3f:	8a 02                	mov    (%edx),%al
  800a41:	3c 30                	cmp    $0x30,%al
  800a43:	75 10                	jne    800a55 <strtol+0x57>
  800a45:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800a49:	75 0a                	jne    800a55 <strtol+0x57>
		s += 2, base = 16;
  800a4b:	83 c2 02             	add    $0x2,%edx
  800a4e:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a53:	eb 12                	jmp    800a67 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800a55:	85 db                	test   %ebx,%ebx
  800a57:	75 0e                	jne    800a67 <strtol+0x69>
  800a59:	3c 30                	cmp    $0x30,%al
  800a5b:	75 05                	jne    800a62 <strtol+0x64>
		s++, base = 8;
  800a5d:	42                   	inc    %edx
  800a5e:	b3 08                	mov    $0x8,%bl
  800a60:	eb 05                	jmp    800a67 <strtol+0x69>
	else if (base == 0)
		base = 10;
  800a62:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800a67:	b8 00 00 00 00       	mov    $0x0,%eax
  800a6c:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a6e:	8a 0a                	mov    (%edx),%cl
  800a70:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800a73:	80 fb 09             	cmp    $0x9,%bl
  800a76:	77 08                	ja     800a80 <strtol+0x82>
			dig = *s - '0';
  800a78:	0f be c9             	movsbl %cl,%ecx
  800a7b:	83 e9 30             	sub    $0x30,%ecx
  800a7e:	eb 1e                	jmp    800a9e <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800a80:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800a83:	80 fb 19             	cmp    $0x19,%bl
  800a86:	77 08                	ja     800a90 <strtol+0x92>
			dig = *s - 'a' + 10;
  800a88:	0f be c9             	movsbl %cl,%ecx
  800a8b:	83 e9 57             	sub    $0x57,%ecx
  800a8e:	eb 0e                	jmp    800a9e <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800a90:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800a93:	80 fb 19             	cmp    $0x19,%bl
  800a96:	77 13                	ja     800aab <strtol+0xad>
			dig = *s - 'A' + 10;
  800a98:	0f be c9             	movsbl %cl,%ecx
  800a9b:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800a9e:	39 f1                	cmp    %esi,%ecx
  800aa0:	7d 0d                	jge    800aaf <strtol+0xb1>
			break;
		s++, val = (val * base) + dig;
  800aa2:	42                   	inc    %edx
  800aa3:	0f af c6             	imul   %esi,%eax
  800aa6:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  800aa9:	eb c3                	jmp    800a6e <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800aab:	89 c1                	mov    %eax,%ecx
  800aad:	eb 02                	jmp    800ab1 <strtol+0xb3>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800aaf:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800ab1:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ab5:	74 05                	je     800abc <strtol+0xbe>
		*endptr = (char *) s;
  800ab7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800aba:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800abc:	85 ff                	test   %edi,%edi
  800abe:	74 04                	je     800ac4 <strtol+0xc6>
  800ac0:	89 c8                	mov    %ecx,%eax
  800ac2:	f7 d8                	neg    %eax
}
  800ac4:	5b                   	pop    %ebx
  800ac5:	5e                   	pop    %esi
  800ac6:	5f                   	pop    %edi
  800ac7:	c9                   	leave  
  800ac8:	c3                   	ret    
  800ac9:	00 00                	add    %al,(%eax)
	...

00800acc <syscall>:
	return ret;
}

static int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800acc:	55                   	push   %ebp
  800acd:	89 e5                	mov    %esp,%ebp
  800acf:	57                   	push   %edi
  800ad0:	56                   	push   %esi
  800ad1:	53                   	push   %ebx
  800ad2:	83 ec 1c             	sub    $0x1c,%esp
  800ad5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800ad8:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800adb:	89 ca                	mov    %ecx,%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800add:	8b 75 14             	mov    0x14(%ebp),%esi
  800ae0:	8b 7d 10             	mov    0x10(%ebp),%edi
  800ae3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800ae6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ae9:	cd 30                	int    $0x30
  800aeb:	89 c2                	mov    %eax,%edx
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800aed:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800af1:	74 1c                	je     800b0f <syscall+0x43>
  800af3:	85 c0                	test   %eax,%eax
  800af5:	7e 18                	jle    800b0f <syscall+0x43>
		panic("syscall %d returned %d (> 0)", num, ret);
  800af7:	83 ec 0c             	sub    $0xc,%esp
  800afa:	50                   	push   %eax
  800afb:	ff 75 e4             	pushl  -0x1c(%ebp)
  800afe:	68 3f 21 80 00       	push   $0x80213f
  800b03:	6a 42                	push   $0x42
  800b05:	68 5c 21 80 00       	push   $0x80215c
  800b0a:	e8 b5 0e 00 00       	call   8019c4 <_panic>

	return ret;
}
  800b0f:	89 d0                	mov    %edx,%eax
  800b11:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b14:	5b                   	pop    %ebx
  800b15:	5e                   	pop    %esi
  800b16:	5f                   	pop    %edi
  800b17:	c9                   	leave  
  800b18:	c3                   	ret    

00800b19 <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{	
  800b19:	55                   	push   %ebp
  800b1a:	89 e5                	mov    %esp,%ebp
  800b1c:	83 ec 08             	sub    $0x8,%esp
	// my_sysenter(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
	// return;
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  800b1f:	6a 00                	push   $0x0
  800b21:	6a 00                	push   $0x0
  800b23:	6a 00                	push   $0x0
  800b25:	ff 75 0c             	pushl  0xc(%ebp)
  800b28:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b2b:	ba 00 00 00 00       	mov    $0x0,%edx
  800b30:	b8 00 00 00 00       	mov    $0x0,%eax
  800b35:	e8 92 ff ff ff       	call   800acc <syscall>
  800b3a:	83 c4 10             	add    $0x10,%esp
	return;
}
  800b3d:	c9                   	leave  
  800b3e:	c3                   	ret    

00800b3f <sys_cgetc>:

int
sys_cgetc(void)
{
  800b3f:	55                   	push   %ebp
  800b40:	89 e5                	mov    %esp,%ebp
  800b42:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_cgetc, 0, 0, 0, 0, 0, 0);
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  800b45:	6a 00                	push   $0x0
  800b47:	6a 00                	push   $0x0
  800b49:	6a 00                	push   $0x0
  800b4b:	6a 00                	push   $0x0
  800b4d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b52:	ba 00 00 00 00       	mov    $0x0,%edx
  800b57:	b8 01 00 00 00       	mov    $0x1,%eax
  800b5c:	e8 6b ff ff ff       	call   800acc <syscall>
}
  800b61:	c9                   	leave  
  800b62:	c3                   	ret    

00800b63 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b63:	55                   	push   %ebp
  800b64:	89 e5                	mov    %esp,%ebp
  800b66:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  800b69:	6a 00                	push   $0x0
  800b6b:	6a 00                	push   $0x0
  800b6d:	6a 00                	push   $0x0
  800b6f:	6a 00                	push   $0x0
  800b71:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b74:	ba 01 00 00 00       	mov    $0x1,%edx
  800b79:	b8 03 00 00 00       	mov    $0x3,%eax
  800b7e:	e8 49 ff ff ff       	call   800acc <syscall>
}
  800b83:	c9                   	leave  
  800b84:	c3                   	ret    

00800b85 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b85:	55                   	push   %ebp
  800b86:	89 e5                	mov    %esp,%ebp
  800b88:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_getenvid, 0, 0, 0, 0, 0, 0);
	return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  800b8b:	6a 00                	push   $0x0
  800b8d:	6a 00                	push   $0x0
  800b8f:	6a 00                	push   $0x0
  800b91:	6a 00                	push   $0x0
  800b93:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b98:	ba 00 00 00 00       	mov    $0x0,%edx
  800b9d:	b8 02 00 00 00       	mov    $0x2,%eax
  800ba2:	e8 25 ff ff ff       	call   800acc <syscall>
}
  800ba7:	c9                   	leave  
  800ba8:	c3                   	ret    

00800ba9 <sys_yield>:

void
sys_yield(void)
{
  800ba9:	55                   	push   %ebp
  800baa:	89 e5                	mov    %esp,%ebp
  800bac:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  800baf:	6a 00                	push   $0x0
  800bb1:	6a 00                	push   $0x0
  800bb3:	6a 00                	push   $0x0
  800bb5:	6a 00                	push   $0x0
  800bb7:	b9 00 00 00 00       	mov    $0x0,%ecx
  800bbc:	ba 00 00 00 00       	mov    $0x0,%edx
  800bc1:	b8 0b 00 00 00       	mov    $0xb,%eax
  800bc6:	e8 01 ff ff ff       	call   800acc <syscall>
  800bcb:	83 c4 10             	add    $0x10,%esp
}
  800bce:	c9                   	leave  
  800bcf:	c3                   	ret    

00800bd0 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800bd0:	55                   	push   %ebp
  800bd1:	89 e5                	mov    %esp,%ebp
  800bd3:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  800bd6:	6a 00                	push   $0x0
  800bd8:	6a 00                	push   $0x0
  800bda:	ff 75 10             	pushl  0x10(%ebp)
  800bdd:	ff 75 0c             	pushl  0xc(%ebp)
  800be0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800be3:	ba 01 00 00 00       	mov    $0x1,%edx
  800be8:	b8 04 00 00 00       	mov    $0x4,%eax
  800bed:	e8 da fe ff ff       	call   800acc <syscall>
}
  800bf2:	c9                   	leave  
  800bf3:	c3                   	ret    

00800bf4 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800bf4:	55                   	push   %ebp
  800bf5:	89 e5                	mov    %esp,%ebp
  800bf7:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
  800bfa:	ff 75 18             	pushl  0x18(%ebp)
  800bfd:	ff 75 14             	pushl  0x14(%ebp)
  800c00:	ff 75 10             	pushl  0x10(%ebp)
  800c03:	ff 75 0c             	pushl  0xc(%ebp)
  800c06:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c09:	ba 01 00 00 00       	mov    $0x1,%edx
  800c0e:	b8 05 00 00 00       	mov    $0x5,%eax
  800c13:	e8 b4 fe ff ff       	call   800acc <syscall>
}
  800c18:	c9                   	leave  
  800c19:	c3                   	ret    

00800c1a <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c1a:	55                   	push   %ebp
  800c1b:	89 e5                	mov    %esp,%ebp
  800c1d:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  800c20:	6a 00                	push   $0x0
  800c22:	6a 00                	push   $0x0
  800c24:	6a 00                	push   $0x0
  800c26:	ff 75 0c             	pushl  0xc(%ebp)
  800c29:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c2c:	ba 01 00 00 00       	mov    $0x1,%edx
  800c31:	b8 06 00 00 00       	mov    $0x6,%eax
  800c36:	e8 91 fe ff ff       	call   800acc <syscall>
}
  800c3b:	c9                   	leave  
  800c3c:	c3                   	ret    

00800c3d <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c3d:	55                   	push   %ebp
  800c3e:	89 e5                	mov    %esp,%ebp
  800c40:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  800c43:	6a 00                	push   $0x0
  800c45:	6a 00                	push   $0x0
  800c47:	6a 00                	push   $0x0
  800c49:	ff 75 0c             	pushl  0xc(%ebp)
  800c4c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c4f:	ba 01 00 00 00       	mov    $0x1,%edx
  800c54:	b8 08 00 00 00       	mov    $0x8,%eax
  800c59:	e8 6e fe ff ff       	call   800acc <syscall>
}
  800c5e:	c9                   	leave  
  800c5f:	c3                   	ret    

00800c60 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800c60:	55                   	push   %ebp
  800c61:	89 e5                	mov    %esp,%ebp
  800c63:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
  800c66:	6a 00                	push   $0x0
  800c68:	6a 00                	push   $0x0
  800c6a:	6a 00                	push   $0x0
  800c6c:	ff 75 0c             	pushl  0xc(%ebp)
  800c6f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c72:	ba 01 00 00 00       	mov    $0x1,%edx
  800c77:	b8 09 00 00 00       	mov    $0x9,%eax
  800c7c:	e8 4b fe ff ff       	call   800acc <syscall>
}
  800c81:	c9                   	leave  
  800c82:	c3                   	ret    

00800c83 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800c83:	55                   	push   %ebp
  800c84:	89 e5                	mov    %esp,%ebp
  800c86:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  800c89:	6a 00                	push   $0x0
  800c8b:	6a 00                	push   $0x0
  800c8d:	6a 00                	push   $0x0
  800c8f:	ff 75 0c             	pushl  0xc(%ebp)
  800c92:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c95:	ba 01 00 00 00       	mov    $0x1,%edx
  800c9a:	b8 0a 00 00 00       	mov    $0xa,%eax
  800c9f:	e8 28 fe ff ff       	call   800acc <syscall>
}
  800ca4:	c9                   	leave  
  800ca5:	c3                   	ret    

00800ca6 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800ca6:	55                   	push   %ebp
  800ca7:	89 e5                	mov    %esp,%ebp
  800ca9:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  800cac:	6a 00                	push   $0x0
  800cae:	ff 75 14             	pushl  0x14(%ebp)
  800cb1:	ff 75 10             	pushl  0x10(%ebp)
  800cb4:	ff 75 0c             	pushl  0xc(%ebp)
  800cb7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800cba:	ba 00 00 00 00       	mov    $0x0,%edx
  800cbf:	b8 0c 00 00 00       	mov    $0xc,%eax
  800cc4:	e8 03 fe ff ff       	call   800acc <syscall>
}
  800cc9:	c9                   	leave  
  800cca:	c3                   	ret    

00800ccb <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800ccb:	55                   	push   %ebp
  800ccc:	89 e5                	mov    %esp,%ebp
  800cce:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  800cd1:	6a 00                	push   $0x0
  800cd3:	6a 00                	push   $0x0
  800cd5:	6a 00                	push   $0x0
  800cd7:	6a 00                	push   $0x0
  800cd9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800cdc:	ba 01 00 00 00       	mov    $0x1,%edx
  800ce1:	b8 0d 00 00 00       	mov    $0xd,%eax
  800ce6:	e8 e1 fd ff ff       	call   800acc <syscall>
}
  800ceb:	c9                   	leave  
  800cec:	c3                   	ret    

00800ced <sys_set_priority>:

int
sys_set_priority(envid_t envid, uint32_t new_priority)
{
  800ced:	55                   	push   %ebp
  800cee:	89 e5                	mov    %esp,%ebp
  800cf0:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_set_priority, 0, envid, new_priority, 0, 0, 0);
  800cf3:	6a 00                	push   $0x0
  800cf5:	6a 00                	push   $0x0
  800cf7:	6a 00                	push   $0x0
  800cf9:	ff 75 0c             	pushl  0xc(%ebp)
  800cfc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800cff:	ba 00 00 00 00       	mov    $0x0,%edx
  800d04:	b8 0e 00 00 00       	mov    $0xe,%eax
  800d09:	e8 be fd ff ff       	call   800acc <syscall>
}
  800d0e:	c9                   	leave  
  800d0f:	c3                   	ret    

00800d10 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800d10:	55                   	push   %ebp
  800d11:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800d13:	8b 45 08             	mov    0x8(%ebp),%eax
  800d16:	05 00 00 00 30       	add    $0x30000000,%eax
  800d1b:	c1 e8 0c             	shr    $0xc,%eax
}
  800d1e:	c9                   	leave  
  800d1f:	c3                   	ret    

00800d20 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800d20:	55                   	push   %ebp
  800d21:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800d23:	ff 75 08             	pushl  0x8(%ebp)
  800d26:	e8 e5 ff ff ff       	call   800d10 <fd2num>
  800d2b:	83 c4 04             	add    $0x4,%esp
  800d2e:	05 20 00 0d 00       	add    $0xd0020,%eax
  800d33:	c1 e0 0c             	shl    $0xc,%eax
}
  800d36:	c9                   	leave  
  800d37:	c3                   	ret    

00800d38 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800d38:	55                   	push   %ebp
  800d39:	89 e5                	mov    %esp,%ebp
  800d3b:	53                   	push   %ebx
  800d3c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800d3f:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  800d44:	a8 01                	test   $0x1,%al
  800d46:	74 34                	je     800d7c <fd_alloc+0x44>
  800d48:	a1 00 00 74 ef       	mov    0xef740000,%eax
  800d4d:	a8 01                	test   $0x1,%al
  800d4f:	74 32                	je     800d83 <fd_alloc+0x4b>
  800d51:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
  800d56:	89 c1                	mov    %eax,%ecx
  800d58:	89 c2                	mov    %eax,%edx
  800d5a:	c1 ea 16             	shr    $0x16,%edx
  800d5d:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800d64:	f6 c2 01             	test   $0x1,%dl
  800d67:	74 1f                	je     800d88 <fd_alloc+0x50>
  800d69:	89 c2                	mov    %eax,%edx
  800d6b:	c1 ea 0c             	shr    $0xc,%edx
  800d6e:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800d75:	f6 c2 01             	test   $0x1,%dl
  800d78:	75 17                	jne    800d91 <fd_alloc+0x59>
  800d7a:	eb 0c                	jmp    800d88 <fd_alloc+0x50>
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  800d7c:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
  800d81:	eb 05                	jmp    800d88 <fd_alloc+0x50>
  800d83:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
  800d88:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  800d8a:	b8 00 00 00 00       	mov    $0x0,%eax
  800d8f:	eb 17                	jmp    800da8 <fd_alloc+0x70>
  800d91:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800d96:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800d9b:	75 b9                	jne    800d56 <fd_alloc+0x1e>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800d9d:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  800da3:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800da8:	5b                   	pop    %ebx
  800da9:	c9                   	leave  
  800daa:	c3                   	ret    

00800dab <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800dab:	55                   	push   %ebp
  800dac:	89 e5                	mov    %esp,%ebp
  800dae:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800db1:	83 f8 1f             	cmp    $0x1f,%eax
  800db4:	77 36                	ja     800dec <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800db6:	05 00 00 0d 00       	add    $0xd0000,%eax
  800dbb:	c1 e0 0c             	shl    $0xc,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800dbe:	89 c2                	mov    %eax,%edx
  800dc0:	c1 ea 16             	shr    $0x16,%edx
  800dc3:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800dca:	f6 c2 01             	test   $0x1,%dl
  800dcd:	74 24                	je     800df3 <fd_lookup+0x48>
  800dcf:	89 c2                	mov    %eax,%edx
  800dd1:	c1 ea 0c             	shr    $0xc,%edx
  800dd4:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800ddb:	f6 c2 01             	test   $0x1,%dl
  800dde:	74 1a                	je     800dfa <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800de0:	8b 55 0c             	mov    0xc(%ebp),%edx
  800de3:	89 02                	mov    %eax,(%edx)
	return 0;
  800de5:	b8 00 00 00 00       	mov    $0x0,%eax
  800dea:	eb 13                	jmp    800dff <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800dec:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800df1:	eb 0c                	jmp    800dff <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800df3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800df8:	eb 05                	jmp    800dff <fd_lookup+0x54>
  800dfa:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800dff:	c9                   	leave  
  800e00:	c3                   	ret    

00800e01 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800e01:	55                   	push   %ebp
  800e02:	89 e5                	mov    %esp,%ebp
  800e04:	53                   	push   %ebx
  800e05:	83 ec 04             	sub    $0x4,%esp
  800e08:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e0b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  800e0e:	39 0d 04 30 80 00    	cmp    %ecx,0x803004
  800e14:	74 0d                	je     800e23 <dev_lookup+0x22>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800e16:	b8 00 00 00 00       	mov    $0x0,%eax
  800e1b:	eb 14                	jmp    800e31 <dev_lookup+0x30>
		if (devtab[i]->dev_id == dev_id) {
  800e1d:	39 0a                	cmp    %ecx,(%edx)
  800e1f:	75 10                	jne    800e31 <dev_lookup+0x30>
  800e21:	eb 05                	jmp    800e28 <dev_lookup+0x27>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800e23:	ba 04 30 80 00       	mov    $0x803004,%edx
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
  800e28:	89 13                	mov    %edx,(%ebx)
			return 0;
  800e2a:	b8 00 00 00 00       	mov    $0x0,%eax
  800e2f:	eb 31                	jmp    800e62 <dev_lookup+0x61>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800e31:	40                   	inc    %eax
  800e32:	8b 14 85 e8 21 80 00 	mov    0x8021e8(,%eax,4),%edx
  800e39:	85 d2                	test   %edx,%edx
  800e3b:	75 e0                	jne    800e1d <dev_lookup+0x1c>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800e3d:	a1 04 40 80 00       	mov    0x804004,%eax
  800e42:	8b 40 48             	mov    0x48(%eax),%eax
  800e45:	83 ec 04             	sub    $0x4,%esp
  800e48:	51                   	push   %ecx
  800e49:	50                   	push   %eax
  800e4a:	68 6c 21 80 00       	push   $0x80216c
  800e4f:	e8 44 f3 ff ff       	call   800198 <cprintf>
	*dev = 0;
  800e54:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  800e5a:	83 c4 10             	add    $0x10,%esp
  800e5d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800e62:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e65:	c9                   	leave  
  800e66:	c3                   	ret    

00800e67 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800e67:	55                   	push   %ebp
  800e68:	89 e5                	mov    %esp,%ebp
  800e6a:	56                   	push   %esi
  800e6b:	53                   	push   %ebx
  800e6c:	83 ec 20             	sub    $0x20,%esp
  800e6f:	8b 75 08             	mov    0x8(%ebp),%esi
  800e72:	8a 45 0c             	mov    0xc(%ebp),%al
  800e75:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800e78:	56                   	push   %esi
  800e79:	e8 92 fe ff ff       	call   800d10 <fd2num>
  800e7e:	8d 55 f4             	lea    -0xc(%ebp),%edx
  800e81:	89 14 24             	mov    %edx,(%esp)
  800e84:	50                   	push   %eax
  800e85:	e8 21 ff ff ff       	call   800dab <fd_lookup>
  800e8a:	89 c3                	mov    %eax,%ebx
  800e8c:	83 c4 08             	add    $0x8,%esp
  800e8f:	85 c0                	test   %eax,%eax
  800e91:	78 05                	js     800e98 <fd_close+0x31>
	    || fd != fd2)
  800e93:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800e96:	74 0d                	je     800ea5 <fd_close+0x3e>
		return (must_exist ? r : 0);
  800e98:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  800e9c:	75 48                	jne    800ee6 <fd_close+0x7f>
  800e9e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ea3:	eb 41                	jmp    800ee6 <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800ea5:	83 ec 08             	sub    $0x8,%esp
  800ea8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800eab:	50                   	push   %eax
  800eac:	ff 36                	pushl  (%esi)
  800eae:	e8 4e ff ff ff       	call   800e01 <dev_lookup>
  800eb3:	89 c3                	mov    %eax,%ebx
  800eb5:	83 c4 10             	add    $0x10,%esp
  800eb8:	85 c0                	test   %eax,%eax
  800eba:	78 1c                	js     800ed8 <fd_close+0x71>
		if (dev->dev_close)
  800ebc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800ebf:	8b 40 10             	mov    0x10(%eax),%eax
  800ec2:	85 c0                	test   %eax,%eax
  800ec4:	74 0d                	je     800ed3 <fd_close+0x6c>
			r = (*dev->dev_close)(fd);
  800ec6:	83 ec 0c             	sub    $0xc,%esp
  800ec9:	56                   	push   %esi
  800eca:	ff d0                	call   *%eax
  800ecc:	89 c3                	mov    %eax,%ebx
  800ece:	83 c4 10             	add    $0x10,%esp
  800ed1:	eb 05                	jmp    800ed8 <fd_close+0x71>
		else
			r = 0;
  800ed3:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800ed8:	83 ec 08             	sub    $0x8,%esp
  800edb:	56                   	push   %esi
  800edc:	6a 00                	push   $0x0
  800ede:	e8 37 fd ff ff       	call   800c1a <sys_page_unmap>
	return r;
  800ee3:	83 c4 10             	add    $0x10,%esp
}
  800ee6:	89 d8                	mov    %ebx,%eax
  800ee8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800eeb:	5b                   	pop    %ebx
  800eec:	5e                   	pop    %esi
  800eed:	c9                   	leave  
  800eee:	c3                   	ret    

00800eef <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800eef:	55                   	push   %ebp
  800ef0:	89 e5                	mov    %esp,%ebp
  800ef2:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800ef5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ef8:	50                   	push   %eax
  800ef9:	ff 75 08             	pushl  0x8(%ebp)
  800efc:	e8 aa fe ff ff       	call   800dab <fd_lookup>
  800f01:	83 c4 08             	add    $0x8,%esp
  800f04:	85 c0                	test   %eax,%eax
  800f06:	78 10                	js     800f18 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800f08:	83 ec 08             	sub    $0x8,%esp
  800f0b:	6a 01                	push   $0x1
  800f0d:	ff 75 f4             	pushl  -0xc(%ebp)
  800f10:	e8 52 ff ff ff       	call   800e67 <fd_close>
  800f15:	83 c4 10             	add    $0x10,%esp
}
  800f18:	c9                   	leave  
  800f19:	c3                   	ret    

00800f1a <close_all>:

void
close_all(void)
{
  800f1a:	55                   	push   %ebp
  800f1b:	89 e5                	mov    %esp,%ebp
  800f1d:	53                   	push   %ebx
  800f1e:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800f21:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800f26:	83 ec 0c             	sub    $0xc,%esp
  800f29:	53                   	push   %ebx
  800f2a:	e8 c0 ff ff ff       	call   800eef <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800f2f:	43                   	inc    %ebx
  800f30:	83 c4 10             	add    $0x10,%esp
  800f33:	83 fb 20             	cmp    $0x20,%ebx
  800f36:	75 ee                	jne    800f26 <close_all+0xc>
		close(i);
}
  800f38:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f3b:	c9                   	leave  
  800f3c:	c3                   	ret    

00800f3d <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800f3d:	55                   	push   %ebp
  800f3e:	89 e5                	mov    %esp,%ebp
  800f40:	57                   	push   %edi
  800f41:	56                   	push   %esi
  800f42:	53                   	push   %ebx
  800f43:	83 ec 2c             	sub    $0x2c,%esp
  800f46:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800f49:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800f4c:	50                   	push   %eax
  800f4d:	ff 75 08             	pushl  0x8(%ebp)
  800f50:	e8 56 fe ff ff       	call   800dab <fd_lookup>
  800f55:	89 c3                	mov    %eax,%ebx
  800f57:	83 c4 08             	add    $0x8,%esp
  800f5a:	85 c0                	test   %eax,%eax
  800f5c:	0f 88 c0 00 00 00    	js     801022 <dup+0xe5>
		return r;
	close(newfdnum);
  800f62:	83 ec 0c             	sub    $0xc,%esp
  800f65:	57                   	push   %edi
  800f66:	e8 84 ff ff ff       	call   800eef <close>

	newfd = INDEX2FD(newfdnum);
  800f6b:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  800f71:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  800f74:	83 c4 04             	add    $0x4,%esp
  800f77:	ff 75 e4             	pushl  -0x1c(%ebp)
  800f7a:	e8 a1 fd ff ff       	call   800d20 <fd2data>
  800f7f:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  800f81:	89 34 24             	mov    %esi,(%esp)
  800f84:	e8 97 fd ff ff       	call   800d20 <fd2data>
  800f89:	83 c4 10             	add    $0x10,%esp
  800f8c:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800f8f:	89 d8                	mov    %ebx,%eax
  800f91:	c1 e8 16             	shr    $0x16,%eax
  800f94:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800f9b:	a8 01                	test   $0x1,%al
  800f9d:	74 37                	je     800fd6 <dup+0x99>
  800f9f:	89 d8                	mov    %ebx,%eax
  800fa1:	c1 e8 0c             	shr    $0xc,%eax
  800fa4:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800fab:	f6 c2 01             	test   $0x1,%dl
  800fae:	74 26                	je     800fd6 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  800fb0:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800fb7:	83 ec 0c             	sub    $0xc,%esp
  800fba:	25 07 0e 00 00       	and    $0xe07,%eax
  800fbf:	50                   	push   %eax
  800fc0:	ff 75 d4             	pushl  -0x2c(%ebp)
  800fc3:	6a 00                	push   $0x0
  800fc5:	53                   	push   %ebx
  800fc6:	6a 00                	push   $0x0
  800fc8:	e8 27 fc ff ff       	call   800bf4 <sys_page_map>
  800fcd:	89 c3                	mov    %eax,%ebx
  800fcf:	83 c4 20             	add    $0x20,%esp
  800fd2:	85 c0                	test   %eax,%eax
  800fd4:	78 2d                	js     801003 <dup+0xc6>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800fd6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800fd9:	89 c2                	mov    %eax,%edx
  800fdb:	c1 ea 0c             	shr    $0xc,%edx
  800fde:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800fe5:	83 ec 0c             	sub    $0xc,%esp
  800fe8:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  800fee:	52                   	push   %edx
  800fef:	56                   	push   %esi
  800ff0:	6a 00                	push   $0x0
  800ff2:	50                   	push   %eax
  800ff3:	6a 00                	push   $0x0
  800ff5:	e8 fa fb ff ff       	call   800bf4 <sys_page_map>
  800ffa:	89 c3                	mov    %eax,%ebx
  800ffc:	83 c4 20             	add    $0x20,%esp
  800fff:	85 c0                	test   %eax,%eax
  801001:	79 1d                	jns    801020 <dup+0xe3>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801003:	83 ec 08             	sub    $0x8,%esp
  801006:	56                   	push   %esi
  801007:	6a 00                	push   $0x0
  801009:	e8 0c fc ff ff       	call   800c1a <sys_page_unmap>
	sys_page_unmap(0, nva);
  80100e:	83 c4 08             	add    $0x8,%esp
  801011:	ff 75 d4             	pushl  -0x2c(%ebp)
  801014:	6a 00                	push   $0x0
  801016:	e8 ff fb ff ff       	call   800c1a <sys_page_unmap>
	return r;
  80101b:	83 c4 10             	add    $0x10,%esp
  80101e:	eb 02                	jmp    801022 <dup+0xe5>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  801020:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  801022:	89 d8                	mov    %ebx,%eax
  801024:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801027:	5b                   	pop    %ebx
  801028:	5e                   	pop    %esi
  801029:	5f                   	pop    %edi
  80102a:	c9                   	leave  
  80102b:	c3                   	ret    

0080102c <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80102c:	55                   	push   %ebp
  80102d:	89 e5                	mov    %esp,%ebp
  80102f:	53                   	push   %ebx
  801030:	83 ec 14             	sub    $0x14,%esp
  801033:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801036:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801039:	50                   	push   %eax
  80103a:	53                   	push   %ebx
  80103b:	e8 6b fd ff ff       	call   800dab <fd_lookup>
  801040:	83 c4 08             	add    $0x8,%esp
  801043:	85 c0                	test   %eax,%eax
  801045:	78 67                	js     8010ae <read+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801047:	83 ec 08             	sub    $0x8,%esp
  80104a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80104d:	50                   	push   %eax
  80104e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801051:	ff 30                	pushl  (%eax)
  801053:	e8 a9 fd ff ff       	call   800e01 <dev_lookup>
  801058:	83 c4 10             	add    $0x10,%esp
  80105b:	85 c0                	test   %eax,%eax
  80105d:	78 4f                	js     8010ae <read+0x82>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80105f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801062:	8b 50 08             	mov    0x8(%eax),%edx
  801065:	83 e2 03             	and    $0x3,%edx
  801068:	83 fa 01             	cmp    $0x1,%edx
  80106b:	75 21                	jne    80108e <read+0x62>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80106d:	a1 04 40 80 00       	mov    0x804004,%eax
  801072:	8b 40 48             	mov    0x48(%eax),%eax
  801075:	83 ec 04             	sub    $0x4,%esp
  801078:	53                   	push   %ebx
  801079:	50                   	push   %eax
  80107a:	68 ad 21 80 00       	push   $0x8021ad
  80107f:	e8 14 f1 ff ff       	call   800198 <cprintf>
		return -E_INVAL;
  801084:	83 c4 10             	add    $0x10,%esp
  801087:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80108c:	eb 20                	jmp    8010ae <read+0x82>
	}
	if (!dev->dev_read)
  80108e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801091:	8b 52 08             	mov    0x8(%edx),%edx
  801094:	85 d2                	test   %edx,%edx
  801096:	74 11                	je     8010a9 <read+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801098:	83 ec 04             	sub    $0x4,%esp
  80109b:	ff 75 10             	pushl  0x10(%ebp)
  80109e:	ff 75 0c             	pushl  0xc(%ebp)
  8010a1:	50                   	push   %eax
  8010a2:	ff d2                	call   *%edx
  8010a4:	83 c4 10             	add    $0x10,%esp
  8010a7:	eb 05                	jmp    8010ae <read+0x82>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8010a9:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  8010ae:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8010b1:	c9                   	leave  
  8010b2:	c3                   	ret    

008010b3 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8010b3:	55                   	push   %ebp
  8010b4:	89 e5                	mov    %esp,%ebp
  8010b6:	57                   	push   %edi
  8010b7:	56                   	push   %esi
  8010b8:	53                   	push   %ebx
  8010b9:	83 ec 0c             	sub    $0xc,%esp
  8010bc:	8b 7d 08             	mov    0x8(%ebp),%edi
  8010bf:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8010c2:	85 f6                	test   %esi,%esi
  8010c4:	74 31                	je     8010f7 <readn+0x44>
  8010c6:	b8 00 00 00 00       	mov    $0x0,%eax
  8010cb:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = read(fdnum, (char*)buf + tot, n - tot);
  8010d0:	83 ec 04             	sub    $0x4,%esp
  8010d3:	89 f2                	mov    %esi,%edx
  8010d5:	29 c2                	sub    %eax,%edx
  8010d7:	52                   	push   %edx
  8010d8:	03 45 0c             	add    0xc(%ebp),%eax
  8010db:	50                   	push   %eax
  8010dc:	57                   	push   %edi
  8010dd:	e8 4a ff ff ff       	call   80102c <read>
		if (m < 0)
  8010e2:	83 c4 10             	add    $0x10,%esp
  8010e5:	85 c0                	test   %eax,%eax
  8010e7:	78 17                	js     801100 <readn+0x4d>
			return m;
		if (m == 0)
  8010e9:	85 c0                	test   %eax,%eax
  8010eb:	74 11                	je     8010fe <readn+0x4b>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8010ed:	01 c3                	add    %eax,%ebx
  8010ef:	89 d8                	mov    %ebx,%eax
  8010f1:	39 f3                	cmp    %esi,%ebx
  8010f3:	72 db                	jb     8010d0 <readn+0x1d>
  8010f5:	eb 09                	jmp    801100 <readn+0x4d>
  8010f7:	b8 00 00 00 00       	mov    $0x0,%eax
  8010fc:	eb 02                	jmp    801100 <readn+0x4d>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  8010fe:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  801100:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801103:	5b                   	pop    %ebx
  801104:	5e                   	pop    %esi
  801105:	5f                   	pop    %edi
  801106:	c9                   	leave  
  801107:	c3                   	ret    

00801108 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801108:	55                   	push   %ebp
  801109:	89 e5                	mov    %esp,%ebp
  80110b:	53                   	push   %ebx
  80110c:	83 ec 14             	sub    $0x14,%esp
  80110f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801112:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801115:	50                   	push   %eax
  801116:	53                   	push   %ebx
  801117:	e8 8f fc ff ff       	call   800dab <fd_lookup>
  80111c:	83 c4 08             	add    $0x8,%esp
  80111f:	85 c0                	test   %eax,%eax
  801121:	78 62                	js     801185 <write+0x7d>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801123:	83 ec 08             	sub    $0x8,%esp
  801126:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801129:	50                   	push   %eax
  80112a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80112d:	ff 30                	pushl  (%eax)
  80112f:	e8 cd fc ff ff       	call   800e01 <dev_lookup>
  801134:	83 c4 10             	add    $0x10,%esp
  801137:	85 c0                	test   %eax,%eax
  801139:	78 4a                	js     801185 <write+0x7d>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80113b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80113e:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801142:	75 21                	jne    801165 <write+0x5d>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801144:	a1 04 40 80 00       	mov    0x804004,%eax
  801149:	8b 40 48             	mov    0x48(%eax),%eax
  80114c:	83 ec 04             	sub    $0x4,%esp
  80114f:	53                   	push   %ebx
  801150:	50                   	push   %eax
  801151:	68 c9 21 80 00       	push   $0x8021c9
  801156:	e8 3d f0 ff ff       	call   800198 <cprintf>
		return -E_INVAL;
  80115b:	83 c4 10             	add    $0x10,%esp
  80115e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801163:	eb 20                	jmp    801185 <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801165:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801168:	8b 52 0c             	mov    0xc(%edx),%edx
  80116b:	85 d2                	test   %edx,%edx
  80116d:	74 11                	je     801180 <write+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80116f:	83 ec 04             	sub    $0x4,%esp
  801172:	ff 75 10             	pushl  0x10(%ebp)
  801175:	ff 75 0c             	pushl  0xc(%ebp)
  801178:	50                   	push   %eax
  801179:	ff d2                	call   *%edx
  80117b:	83 c4 10             	add    $0x10,%esp
  80117e:	eb 05                	jmp    801185 <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801180:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  801185:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801188:	c9                   	leave  
  801189:	c3                   	ret    

0080118a <seek>:

int
seek(int fdnum, off_t offset)
{
  80118a:	55                   	push   %ebp
  80118b:	89 e5                	mov    %esp,%ebp
  80118d:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801190:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801193:	50                   	push   %eax
  801194:	ff 75 08             	pushl  0x8(%ebp)
  801197:	e8 0f fc ff ff       	call   800dab <fd_lookup>
  80119c:	83 c4 08             	add    $0x8,%esp
  80119f:	85 c0                	test   %eax,%eax
  8011a1:	78 0e                	js     8011b1 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8011a3:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8011a6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8011a9:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8011ac:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8011b1:	c9                   	leave  
  8011b2:	c3                   	ret    

008011b3 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8011b3:	55                   	push   %ebp
  8011b4:	89 e5                	mov    %esp,%ebp
  8011b6:	53                   	push   %ebx
  8011b7:	83 ec 14             	sub    $0x14,%esp
  8011ba:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8011bd:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011c0:	50                   	push   %eax
  8011c1:	53                   	push   %ebx
  8011c2:	e8 e4 fb ff ff       	call   800dab <fd_lookup>
  8011c7:	83 c4 08             	add    $0x8,%esp
  8011ca:	85 c0                	test   %eax,%eax
  8011cc:	78 5f                	js     80122d <ftruncate+0x7a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011ce:	83 ec 08             	sub    $0x8,%esp
  8011d1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011d4:	50                   	push   %eax
  8011d5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011d8:	ff 30                	pushl  (%eax)
  8011da:	e8 22 fc ff ff       	call   800e01 <dev_lookup>
  8011df:	83 c4 10             	add    $0x10,%esp
  8011e2:	85 c0                	test   %eax,%eax
  8011e4:	78 47                	js     80122d <ftruncate+0x7a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8011e6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011e9:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8011ed:	75 21                	jne    801210 <ftruncate+0x5d>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8011ef:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8011f4:	8b 40 48             	mov    0x48(%eax),%eax
  8011f7:	83 ec 04             	sub    $0x4,%esp
  8011fa:	53                   	push   %ebx
  8011fb:	50                   	push   %eax
  8011fc:	68 8c 21 80 00       	push   $0x80218c
  801201:	e8 92 ef ff ff       	call   800198 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801206:	83 c4 10             	add    $0x10,%esp
  801209:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80120e:	eb 1d                	jmp    80122d <ftruncate+0x7a>
	}
	if (!dev->dev_trunc)
  801210:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801213:	8b 52 18             	mov    0x18(%edx),%edx
  801216:	85 d2                	test   %edx,%edx
  801218:	74 0e                	je     801228 <ftruncate+0x75>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80121a:	83 ec 08             	sub    $0x8,%esp
  80121d:	ff 75 0c             	pushl  0xc(%ebp)
  801220:	50                   	push   %eax
  801221:	ff d2                	call   *%edx
  801223:	83 c4 10             	add    $0x10,%esp
  801226:	eb 05                	jmp    80122d <ftruncate+0x7a>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801228:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  80122d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801230:	c9                   	leave  
  801231:	c3                   	ret    

00801232 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801232:	55                   	push   %ebp
  801233:	89 e5                	mov    %esp,%ebp
  801235:	53                   	push   %ebx
  801236:	83 ec 14             	sub    $0x14,%esp
  801239:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80123c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80123f:	50                   	push   %eax
  801240:	ff 75 08             	pushl  0x8(%ebp)
  801243:	e8 63 fb ff ff       	call   800dab <fd_lookup>
  801248:	83 c4 08             	add    $0x8,%esp
  80124b:	85 c0                	test   %eax,%eax
  80124d:	78 52                	js     8012a1 <fstat+0x6f>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80124f:	83 ec 08             	sub    $0x8,%esp
  801252:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801255:	50                   	push   %eax
  801256:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801259:	ff 30                	pushl  (%eax)
  80125b:	e8 a1 fb ff ff       	call   800e01 <dev_lookup>
  801260:	83 c4 10             	add    $0x10,%esp
  801263:	85 c0                	test   %eax,%eax
  801265:	78 3a                	js     8012a1 <fstat+0x6f>
		return r;
	if (!dev->dev_stat)
  801267:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80126a:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80126e:	74 2c                	je     80129c <fstat+0x6a>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801270:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801273:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80127a:	00 00 00 
	stat->st_isdir = 0;
  80127d:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801284:	00 00 00 
	stat->st_dev = dev;
  801287:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80128d:	83 ec 08             	sub    $0x8,%esp
  801290:	53                   	push   %ebx
  801291:	ff 75 f0             	pushl  -0x10(%ebp)
  801294:	ff 50 14             	call   *0x14(%eax)
  801297:	83 c4 10             	add    $0x10,%esp
  80129a:	eb 05                	jmp    8012a1 <fstat+0x6f>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  80129c:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8012a1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012a4:	c9                   	leave  
  8012a5:	c3                   	ret    

008012a6 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8012a6:	55                   	push   %ebp
  8012a7:	89 e5                	mov    %esp,%ebp
  8012a9:	56                   	push   %esi
  8012aa:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8012ab:	83 ec 08             	sub    $0x8,%esp
  8012ae:	6a 00                	push   $0x0
  8012b0:	ff 75 08             	pushl  0x8(%ebp)
  8012b3:	e8 78 01 00 00       	call   801430 <open>
  8012b8:	89 c3                	mov    %eax,%ebx
  8012ba:	83 c4 10             	add    $0x10,%esp
  8012bd:	85 c0                	test   %eax,%eax
  8012bf:	78 1b                	js     8012dc <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8012c1:	83 ec 08             	sub    $0x8,%esp
  8012c4:	ff 75 0c             	pushl  0xc(%ebp)
  8012c7:	50                   	push   %eax
  8012c8:	e8 65 ff ff ff       	call   801232 <fstat>
  8012cd:	89 c6                	mov    %eax,%esi
	close(fd);
  8012cf:	89 1c 24             	mov    %ebx,(%esp)
  8012d2:	e8 18 fc ff ff       	call   800eef <close>
	return r;
  8012d7:	83 c4 10             	add    $0x10,%esp
  8012da:	89 f3                	mov    %esi,%ebx
}
  8012dc:	89 d8                	mov    %ebx,%eax
  8012de:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8012e1:	5b                   	pop    %ebx
  8012e2:	5e                   	pop    %esi
  8012e3:	c9                   	leave  
  8012e4:	c3                   	ret    
  8012e5:	00 00                	add    %al,(%eax)
	...

008012e8 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8012e8:	55                   	push   %ebp
  8012e9:	89 e5                	mov    %esp,%ebp
  8012eb:	56                   	push   %esi
  8012ec:	53                   	push   %ebx
  8012ed:	89 c3                	mov    %eax,%ebx
  8012ef:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  8012f1:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8012f8:	75 12                	jne    80130c <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8012fa:	83 ec 0c             	sub    $0xc,%esp
  8012fd:	6a 01                	push   $0x1
  8012ff:	e8 d2 07 00 00       	call   801ad6 <ipc_find_env>
  801304:	a3 00 40 80 00       	mov    %eax,0x804000
  801309:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80130c:	6a 07                	push   $0x7
  80130e:	68 00 50 80 00       	push   $0x805000
  801313:	53                   	push   %ebx
  801314:	ff 35 00 40 80 00    	pushl  0x804000
  80131a:	e8 62 07 00 00       	call   801a81 <ipc_send>
	
	return ipc_recv(NULL, dstva, NULL);
  80131f:	83 c4 0c             	add    $0xc,%esp
  801322:	6a 00                	push   $0x0
  801324:	56                   	push   %esi
  801325:	6a 00                	push   $0x0
  801327:	e8 e0 06 00 00       	call   801a0c <ipc_recv>
}
  80132c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80132f:	5b                   	pop    %ebx
  801330:	5e                   	pop    %esi
  801331:	c9                   	leave  
  801332:	c3                   	ret    

00801333 <devfile_stat>:
}


static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801333:	55                   	push   %ebp
  801334:	89 e5                	mov    %esp,%ebp
  801336:	53                   	push   %ebx
  801337:	83 ec 04             	sub    $0x4,%esp
  80133a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80133d:	8b 45 08             	mov    0x8(%ebp),%eax
  801340:	8b 40 0c             	mov    0xc(%eax),%eax
  801343:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0) {
  801348:	ba 00 00 00 00       	mov    $0x0,%edx
  80134d:	b8 05 00 00 00       	mov    $0x5,%eax
  801352:	e8 91 ff ff ff       	call   8012e8 <fsipc>
  801357:	85 c0                	test   %eax,%eax
  801359:	78 2c                	js     801387 <devfile_stat+0x54>
		return r;
	}
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80135b:	83 ec 08             	sub    $0x8,%esp
  80135e:	68 00 50 80 00       	push   $0x805000
  801363:	53                   	push   %ebx
  801364:	e8 e5 f3 ff ff       	call   80074e <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801369:	a1 80 50 80 00       	mov    0x805080,%eax
  80136e:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801374:	a1 84 50 80 00       	mov    0x805084,%eax
  801379:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80137f:	83 c4 10             	add    $0x10,%esp
  801382:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801387:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80138a:	c9                   	leave  
  80138b:	c3                   	ret    

0080138c <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80138c:	55                   	push   %ebp
  80138d:	89 e5                	mov    %esp,%ebp
  80138f:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801392:	8b 45 08             	mov    0x8(%ebp),%eax
  801395:	8b 40 0c             	mov    0xc(%eax),%eax
  801398:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80139d:	ba 00 00 00 00       	mov    $0x0,%edx
  8013a2:	b8 06 00 00 00       	mov    $0x6,%eax
  8013a7:	e8 3c ff ff ff       	call   8012e8 <fsipc>
}
  8013ac:	c9                   	leave  
  8013ad:	c3                   	ret    

008013ae <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8013ae:	55                   	push   %ebp
  8013af:	89 e5                	mov    %esp,%ebp
  8013b1:	56                   	push   %esi
  8013b2:	53                   	push   %ebx
  8013b3:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8013b6:	8b 45 08             	mov    0x8(%ebp),%eax
  8013b9:	8b 40 0c             	mov    0xc(%eax),%eax
  8013bc:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8013c1:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8013c7:	ba 00 00 00 00       	mov    $0x0,%edx
  8013cc:	b8 03 00 00 00       	mov    $0x3,%eax
  8013d1:	e8 12 ff ff ff       	call   8012e8 <fsipc>
  8013d6:	89 c3                	mov    %eax,%ebx
  8013d8:	85 c0                	test   %eax,%eax
  8013da:	78 4b                	js     801427 <devfile_read+0x79>
		return r;
	assert(r <= n);
  8013dc:	39 c6                	cmp    %eax,%esi
  8013de:	73 16                	jae    8013f6 <devfile_read+0x48>
  8013e0:	68 f8 21 80 00       	push   $0x8021f8
  8013e5:	68 ff 21 80 00       	push   $0x8021ff
  8013ea:	6a 7d                	push   $0x7d
  8013ec:	68 14 22 80 00       	push   $0x802214
  8013f1:	e8 ce 05 00 00       	call   8019c4 <_panic>
	assert(r <= PGSIZE);
  8013f6:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8013fb:	7e 16                	jle    801413 <devfile_read+0x65>
  8013fd:	68 1f 22 80 00       	push   $0x80221f
  801402:	68 ff 21 80 00       	push   $0x8021ff
  801407:	6a 7e                	push   $0x7e
  801409:	68 14 22 80 00       	push   $0x802214
  80140e:	e8 b1 05 00 00       	call   8019c4 <_panic>
	memmove(buf, &fsipcbuf, r);
  801413:	83 ec 04             	sub    $0x4,%esp
  801416:	50                   	push   %eax
  801417:	68 00 50 80 00       	push   $0x805000
  80141c:	ff 75 0c             	pushl  0xc(%ebp)
  80141f:	e8 eb f4 ff ff       	call   80090f <memmove>
	return r;
  801424:	83 c4 10             	add    $0x10,%esp
}
  801427:	89 d8                	mov    %ebx,%eax
  801429:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80142c:	5b                   	pop    %ebx
  80142d:	5e                   	pop    %esi
  80142e:	c9                   	leave  
  80142f:	c3                   	ret    

00801430 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801430:	55                   	push   %ebp
  801431:	89 e5                	mov    %esp,%ebp
  801433:	56                   	push   %esi
  801434:	53                   	push   %ebx
  801435:	83 ec 1c             	sub    $0x1c,%esp
  801438:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  80143b:	56                   	push   %esi
  80143c:	e8 bb f2 ff ff       	call   8006fc <strlen>
  801441:	83 c4 10             	add    $0x10,%esp
  801444:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801449:	7f 65                	jg     8014b0 <open+0x80>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80144b:	83 ec 0c             	sub    $0xc,%esp
  80144e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801451:	50                   	push   %eax
  801452:	e8 e1 f8 ff ff       	call   800d38 <fd_alloc>
  801457:	89 c3                	mov    %eax,%ebx
  801459:	83 c4 10             	add    $0x10,%esp
  80145c:	85 c0                	test   %eax,%eax
  80145e:	78 55                	js     8014b5 <open+0x85>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801460:	83 ec 08             	sub    $0x8,%esp
  801463:	56                   	push   %esi
  801464:	68 00 50 80 00       	push   $0x805000
  801469:	e8 e0 f2 ff ff       	call   80074e <strcpy>
	fsipcbuf.open.req_omode = mode;
  80146e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801471:	a3 00 54 80 00       	mov    %eax,0x805400



	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801476:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801479:	b8 01 00 00 00       	mov    $0x1,%eax
  80147e:	e8 65 fe ff ff       	call   8012e8 <fsipc>
  801483:	89 c3                	mov    %eax,%ebx
  801485:	83 c4 10             	add    $0x10,%esp
  801488:	85 c0                	test   %eax,%eax
  80148a:	79 12                	jns    80149e <open+0x6e>
		fd_close(fd, 0);
  80148c:	83 ec 08             	sub    $0x8,%esp
  80148f:	6a 00                	push   $0x0
  801491:	ff 75 f4             	pushl  -0xc(%ebp)
  801494:	e8 ce f9 ff ff       	call   800e67 <fd_close>
		return r;
  801499:	83 c4 10             	add    $0x10,%esp
  80149c:	eb 17                	jmp    8014b5 <open+0x85>
	}

	return fd2num(fd);
  80149e:	83 ec 0c             	sub    $0xc,%esp
  8014a1:	ff 75 f4             	pushl  -0xc(%ebp)
  8014a4:	e8 67 f8 ff ff       	call   800d10 <fd2num>
  8014a9:	89 c3                	mov    %eax,%ebx
  8014ab:	83 c4 10             	add    $0x10,%esp
  8014ae:	eb 05                	jmp    8014b5 <open+0x85>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8014b0:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8014b5:	89 d8                	mov    %ebx,%eax
  8014b7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8014ba:	5b                   	pop    %ebx
  8014bb:	5e                   	pop    %esi
  8014bc:	c9                   	leave  
  8014bd:	c3                   	ret    
	...

008014c0 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8014c0:	55                   	push   %ebp
  8014c1:	89 e5                	mov    %esp,%ebp
  8014c3:	56                   	push   %esi
  8014c4:	53                   	push   %ebx
  8014c5:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8014c8:	83 ec 0c             	sub    $0xc,%esp
  8014cb:	ff 75 08             	pushl  0x8(%ebp)
  8014ce:	e8 4d f8 ff ff       	call   800d20 <fd2data>
  8014d3:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  8014d5:	83 c4 08             	add    $0x8,%esp
  8014d8:	68 2b 22 80 00       	push   $0x80222b
  8014dd:	56                   	push   %esi
  8014de:	e8 6b f2 ff ff       	call   80074e <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8014e3:	8b 43 04             	mov    0x4(%ebx),%eax
  8014e6:	2b 03                	sub    (%ebx),%eax
  8014e8:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  8014ee:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  8014f5:	00 00 00 
	stat->st_dev = &devpipe;
  8014f8:	c7 86 88 00 00 00 20 	movl   $0x803020,0x88(%esi)
  8014ff:	30 80 00 
	return 0;
}
  801502:	b8 00 00 00 00       	mov    $0x0,%eax
  801507:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80150a:	5b                   	pop    %ebx
  80150b:	5e                   	pop    %esi
  80150c:	c9                   	leave  
  80150d:	c3                   	ret    

0080150e <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  80150e:	55                   	push   %ebp
  80150f:	89 e5                	mov    %esp,%ebp
  801511:	53                   	push   %ebx
  801512:	83 ec 0c             	sub    $0xc,%esp
  801515:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801518:	53                   	push   %ebx
  801519:	6a 00                	push   $0x0
  80151b:	e8 fa f6 ff ff       	call   800c1a <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801520:	89 1c 24             	mov    %ebx,(%esp)
  801523:	e8 f8 f7 ff ff       	call   800d20 <fd2data>
  801528:	83 c4 08             	add    $0x8,%esp
  80152b:	50                   	push   %eax
  80152c:	6a 00                	push   $0x0
  80152e:	e8 e7 f6 ff ff       	call   800c1a <sys_page_unmap>
}
  801533:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801536:	c9                   	leave  
  801537:	c3                   	ret    

00801538 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801538:	55                   	push   %ebp
  801539:	89 e5                	mov    %esp,%ebp
  80153b:	57                   	push   %edi
  80153c:	56                   	push   %esi
  80153d:	53                   	push   %ebx
  80153e:	83 ec 1c             	sub    $0x1c,%esp
  801541:	89 c7                	mov    %eax,%edi
  801543:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801546:	a1 04 40 80 00       	mov    0x804004,%eax
  80154b:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  80154e:	83 ec 0c             	sub    $0xc,%esp
  801551:	57                   	push   %edi
  801552:	e8 dd 05 00 00       	call   801b34 <pageref>
  801557:	89 c6                	mov    %eax,%esi
  801559:	83 c4 04             	add    $0x4,%esp
  80155c:	ff 75 e4             	pushl  -0x1c(%ebp)
  80155f:	e8 d0 05 00 00       	call   801b34 <pageref>
  801564:	83 c4 10             	add    $0x10,%esp
  801567:	39 c6                	cmp    %eax,%esi
  801569:	0f 94 c0             	sete   %al
  80156c:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  80156f:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801575:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801578:	39 cb                	cmp    %ecx,%ebx
  80157a:	75 08                	jne    801584 <_pipeisclosed+0x4c>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  80157c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80157f:	5b                   	pop    %ebx
  801580:	5e                   	pop    %esi
  801581:	5f                   	pop    %edi
  801582:	c9                   	leave  
  801583:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  801584:	83 f8 01             	cmp    $0x1,%eax
  801587:	75 bd                	jne    801546 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801589:	8b 42 58             	mov    0x58(%edx),%eax
  80158c:	6a 01                	push   $0x1
  80158e:	50                   	push   %eax
  80158f:	53                   	push   %ebx
  801590:	68 32 22 80 00       	push   $0x802232
  801595:	e8 fe eb ff ff       	call   800198 <cprintf>
  80159a:	83 c4 10             	add    $0x10,%esp
  80159d:	eb a7                	jmp    801546 <_pipeisclosed+0xe>

0080159f <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80159f:	55                   	push   %ebp
  8015a0:	89 e5                	mov    %esp,%ebp
  8015a2:	57                   	push   %edi
  8015a3:	56                   	push   %esi
  8015a4:	53                   	push   %ebx
  8015a5:	83 ec 28             	sub    $0x28,%esp
  8015a8:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  8015ab:	56                   	push   %esi
  8015ac:	e8 6f f7 ff ff       	call   800d20 <fd2data>
  8015b1:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8015b3:	83 c4 10             	add    $0x10,%esp
  8015b6:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8015ba:	75 4a                	jne    801606 <devpipe_write+0x67>
  8015bc:	bf 00 00 00 00       	mov    $0x0,%edi
  8015c1:	eb 56                	jmp    801619 <devpipe_write+0x7a>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  8015c3:	89 da                	mov    %ebx,%edx
  8015c5:	89 f0                	mov    %esi,%eax
  8015c7:	e8 6c ff ff ff       	call   801538 <_pipeisclosed>
  8015cc:	85 c0                	test   %eax,%eax
  8015ce:	75 4d                	jne    80161d <devpipe_write+0x7e>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  8015d0:	e8 d4 f5 ff ff       	call   800ba9 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8015d5:	8b 43 04             	mov    0x4(%ebx),%eax
  8015d8:	8b 13                	mov    (%ebx),%edx
  8015da:	83 c2 20             	add    $0x20,%edx
  8015dd:	39 d0                	cmp    %edx,%eax
  8015df:	73 e2                	jae    8015c3 <devpipe_write+0x24>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  8015e1:	89 c2                	mov    %eax,%edx
  8015e3:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  8015e9:	79 05                	jns    8015f0 <devpipe_write+0x51>
  8015eb:	4a                   	dec    %edx
  8015ec:	83 ca e0             	or     $0xffffffe0,%edx
  8015ef:	42                   	inc    %edx
  8015f0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8015f3:	8a 0c 39             	mov    (%ecx,%edi,1),%cl
  8015f6:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  8015fa:	40                   	inc    %eax
  8015fb:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8015fe:	47                   	inc    %edi
  8015ff:	39 7d 10             	cmp    %edi,0x10(%ebp)
  801602:	77 07                	ja     80160b <devpipe_write+0x6c>
  801604:	eb 13                	jmp    801619 <devpipe_write+0x7a>
  801606:	bf 00 00 00 00       	mov    $0x0,%edi
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  80160b:	8b 43 04             	mov    0x4(%ebx),%eax
  80160e:	8b 13                	mov    (%ebx),%edx
  801610:	83 c2 20             	add    $0x20,%edx
  801613:	39 d0                	cmp    %edx,%eax
  801615:	73 ac                	jae    8015c3 <devpipe_write+0x24>
  801617:	eb c8                	jmp    8015e1 <devpipe_write+0x42>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801619:	89 f8                	mov    %edi,%eax
  80161b:	eb 05                	jmp    801622 <devpipe_write+0x83>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80161d:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801622:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801625:	5b                   	pop    %ebx
  801626:	5e                   	pop    %esi
  801627:	5f                   	pop    %edi
  801628:	c9                   	leave  
  801629:	c3                   	ret    

0080162a <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  80162a:	55                   	push   %ebp
  80162b:	89 e5                	mov    %esp,%ebp
  80162d:	57                   	push   %edi
  80162e:	56                   	push   %esi
  80162f:	53                   	push   %ebx
  801630:	83 ec 18             	sub    $0x18,%esp
  801633:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801636:	57                   	push   %edi
  801637:	e8 e4 f6 ff ff       	call   800d20 <fd2data>
  80163c:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80163e:	83 c4 10             	add    $0x10,%esp
  801641:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801645:	75 44                	jne    80168b <devpipe_read+0x61>
  801647:	be 00 00 00 00       	mov    $0x0,%esi
  80164c:	eb 4f                	jmp    80169d <devpipe_read+0x73>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
				return i;
  80164e:	89 f0                	mov    %esi,%eax
  801650:	eb 54                	jmp    8016a6 <devpipe_read+0x7c>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801652:	89 da                	mov    %ebx,%edx
  801654:	89 f8                	mov    %edi,%eax
  801656:	e8 dd fe ff ff       	call   801538 <_pipeisclosed>
  80165b:	85 c0                	test   %eax,%eax
  80165d:	75 42                	jne    8016a1 <devpipe_read+0x77>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  80165f:	e8 45 f5 ff ff       	call   800ba9 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801664:	8b 03                	mov    (%ebx),%eax
  801666:	3b 43 04             	cmp    0x4(%ebx),%eax
  801669:	74 e7                	je     801652 <devpipe_read+0x28>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  80166b:	25 1f 00 00 80       	and    $0x8000001f,%eax
  801670:	79 05                	jns    801677 <devpipe_read+0x4d>
  801672:	48                   	dec    %eax
  801673:	83 c8 e0             	or     $0xffffffe0,%eax
  801676:	40                   	inc    %eax
  801677:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  80167b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80167e:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  801681:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801683:	46                   	inc    %esi
  801684:	39 75 10             	cmp    %esi,0x10(%ebp)
  801687:	77 07                	ja     801690 <devpipe_read+0x66>
  801689:	eb 12                	jmp    80169d <devpipe_read+0x73>
  80168b:	be 00 00 00 00       	mov    $0x0,%esi
		while (p->p_rpos == p->p_wpos) {
  801690:	8b 03                	mov    (%ebx),%eax
  801692:	3b 43 04             	cmp    0x4(%ebx),%eax
  801695:	75 d4                	jne    80166b <devpipe_read+0x41>
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801697:	85 f6                	test   %esi,%esi
  801699:	75 b3                	jne    80164e <devpipe_read+0x24>
  80169b:	eb b5                	jmp    801652 <devpipe_read+0x28>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  80169d:	89 f0                	mov    %esi,%eax
  80169f:	eb 05                	jmp    8016a6 <devpipe_read+0x7c>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8016a1:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  8016a6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8016a9:	5b                   	pop    %ebx
  8016aa:	5e                   	pop    %esi
  8016ab:	5f                   	pop    %edi
  8016ac:	c9                   	leave  
  8016ad:	c3                   	ret    

008016ae <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  8016ae:	55                   	push   %ebp
  8016af:	89 e5                	mov    %esp,%ebp
  8016b1:	57                   	push   %edi
  8016b2:	56                   	push   %esi
  8016b3:	53                   	push   %ebx
  8016b4:	83 ec 28             	sub    $0x28,%esp
  8016b7:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  8016ba:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8016bd:	50                   	push   %eax
  8016be:	e8 75 f6 ff ff       	call   800d38 <fd_alloc>
  8016c3:	89 c3                	mov    %eax,%ebx
  8016c5:	83 c4 10             	add    $0x10,%esp
  8016c8:	85 c0                	test   %eax,%eax
  8016ca:	0f 88 24 01 00 00    	js     8017f4 <pipe+0x146>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8016d0:	83 ec 04             	sub    $0x4,%esp
  8016d3:	68 07 04 00 00       	push   $0x407
  8016d8:	ff 75 e4             	pushl  -0x1c(%ebp)
  8016db:	6a 00                	push   $0x0
  8016dd:	e8 ee f4 ff ff       	call   800bd0 <sys_page_alloc>
  8016e2:	89 c3                	mov    %eax,%ebx
  8016e4:	83 c4 10             	add    $0x10,%esp
  8016e7:	85 c0                	test   %eax,%eax
  8016e9:	0f 88 05 01 00 00    	js     8017f4 <pipe+0x146>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  8016ef:	83 ec 0c             	sub    $0xc,%esp
  8016f2:	8d 45 e0             	lea    -0x20(%ebp),%eax
  8016f5:	50                   	push   %eax
  8016f6:	e8 3d f6 ff ff       	call   800d38 <fd_alloc>
  8016fb:	89 c3                	mov    %eax,%ebx
  8016fd:	83 c4 10             	add    $0x10,%esp
  801700:	85 c0                	test   %eax,%eax
  801702:	0f 88 dc 00 00 00    	js     8017e4 <pipe+0x136>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801708:	83 ec 04             	sub    $0x4,%esp
  80170b:	68 07 04 00 00       	push   $0x407
  801710:	ff 75 e0             	pushl  -0x20(%ebp)
  801713:	6a 00                	push   $0x0
  801715:	e8 b6 f4 ff ff       	call   800bd0 <sys_page_alloc>
  80171a:	89 c3                	mov    %eax,%ebx
  80171c:	83 c4 10             	add    $0x10,%esp
  80171f:	85 c0                	test   %eax,%eax
  801721:	0f 88 bd 00 00 00    	js     8017e4 <pipe+0x136>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801727:	83 ec 0c             	sub    $0xc,%esp
  80172a:	ff 75 e4             	pushl  -0x1c(%ebp)
  80172d:	e8 ee f5 ff ff       	call   800d20 <fd2data>
  801732:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801734:	83 c4 0c             	add    $0xc,%esp
  801737:	68 07 04 00 00       	push   $0x407
  80173c:	50                   	push   %eax
  80173d:	6a 00                	push   $0x0
  80173f:	e8 8c f4 ff ff       	call   800bd0 <sys_page_alloc>
  801744:	89 c3                	mov    %eax,%ebx
  801746:	83 c4 10             	add    $0x10,%esp
  801749:	85 c0                	test   %eax,%eax
  80174b:	0f 88 83 00 00 00    	js     8017d4 <pipe+0x126>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801751:	83 ec 0c             	sub    $0xc,%esp
  801754:	ff 75 e0             	pushl  -0x20(%ebp)
  801757:	e8 c4 f5 ff ff       	call   800d20 <fd2data>
  80175c:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801763:	50                   	push   %eax
  801764:	6a 00                	push   $0x0
  801766:	56                   	push   %esi
  801767:	6a 00                	push   $0x0
  801769:	e8 86 f4 ff ff       	call   800bf4 <sys_page_map>
  80176e:	89 c3                	mov    %eax,%ebx
  801770:	83 c4 20             	add    $0x20,%esp
  801773:	85 c0                	test   %eax,%eax
  801775:	78 4f                	js     8017c6 <pipe+0x118>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801777:	8b 15 20 30 80 00    	mov    0x803020,%edx
  80177d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801780:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801782:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801785:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  80178c:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801792:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801795:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801797:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80179a:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  8017a1:	83 ec 0c             	sub    $0xc,%esp
  8017a4:	ff 75 e4             	pushl  -0x1c(%ebp)
  8017a7:	e8 64 f5 ff ff       	call   800d10 <fd2num>
  8017ac:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  8017ae:	83 c4 04             	add    $0x4,%esp
  8017b1:	ff 75 e0             	pushl  -0x20(%ebp)
  8017b4:	e8 57 f5 ff ff       	call   800d10 <fd2num>
  8017b9:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  8017bc:	83 c4 10             	add    $0x10,%esp
  8017bf:	bb 00 00 00 00       	mov    $0x0,%ebx
  8017c4:	eb 2e                	jmp    8017f4 <pipe+0x146>

    err3:
	sys_page_unmap(0, va);
  8017c6:	83 ec 08             	sub    $0x8,%esp
  8017c9:	56                   	push   %esi
  8017ca:	6a 00                	push   $0x0
  8017cc:	e8 49 f4 ff ff       	call   800c1a <sys_page_unmap>
  8017d1:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  8017d4:	83 ec 08             	sub    $0x8,%esp
  8017d7:	ff 75 e0             	pushl  -0x20(%ebp)
  8017da:	6a 00                	push   $0x0
  8017dc:	e8 39 f4 ff ff       	call   800c1a <sys_page_unmap>
  8017e1:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  8017e4:	83 ec 08             	sub    $0x8,%esp
  8017e7:	ff 75 e4             	pushl  -0x1c(%ebp)
  8017ea:	6a 00                	push   $0x0
  8017ec:	e8 29 f4 ff ff       	call   800c1a <sys_page_unmap>
  8017f1:	83 c4 10             	add    $0x10,%esp
    err:
	return r;
}
  8017f4:	89 d8                	mov    %ebx,%eax
  8017f6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8017f9:	5b                   	pop    %ebx
  8017fa:	5e                   	pop    %esi
  8017fb:	5f                   	pop    %edi
  8017fc:	c9                   	leave  
  8017fd:	c3                   	ret    

008017fe <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  8017fe:	55                   	push   %ebp
  8017ff:	89 e5                	mov    %esp,%ebp
  801801:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801804:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801807:	50                   	push   %eax
  801808:	ff 75 08             	pushl  0x8(%ebp)
  80180b:	e8 9b f5 ff ff       	call   800dab <fd_lookup>
  801810:	83 c4 10             	add    $0x10,%esp
  801813:	85 c0                	test   %eax,%eax
  801815:	78 18                	js     80182f <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801817:	83 ec 0c             	sub    $0xc,%esp
  80181a:	ff 75 f4             	pushl  -0xc(%ebp)
  80181d:	e8 fe f4 ff ff       	call   800d20 <fd2data>
	return _pipeisclosed(fd, p);
  801822:	89 c2                	mov    %eax,%edx
  801824:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801827:	e8 0c fd ff ff       	call   801538 <_pipeisclosed>
  80182c:	83 c4 10             	add    $0x10,%esp
}
  80182f:	c9                   	leave  
  801830:	c3                   	ret    
  801831:	00 00                	add    %al,(%eax)
	...

00801834 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801834:	55                   	push   %ebp
  801835:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801837:	b8 00 00 00 00       	mov    $0x0,%eax
  80183c:	c9                   	leave  
  80183d:	c3                   	ret    

0080183e <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80183e:	55                   	push   %ebp
  80183f:	89 e5                	mov    %esp,%ebp
  801841:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801844:	68 4a 22 80 00       	push   $0x80224a
  801849:	ff 75 0c             	pushl  0xc(%ebp)
  80184c:	e8 fd ee ff ff       	call   80074e <strcpy>
	return 0;
}
  801851:	b8 00 00 00 00       	mov    $0x0,%eax
  801856:	c9                   	leave  
  801857:	c3                   	ret    

00801858 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801858:	55                   	push   %ebp
  801859:	89 e5                	mov    %esp,%ebp
  80185b:	57                   	push   %edi
  80185c:	56                   	push   %esi
  80185d:	53                   	push   %ebx
  80185e:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801864:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801868:	74 45                	je     8018af <devcons_write+0x57>
  80186a:	b8 00 00 00 00       	mov    $0x0,%eax
  80186f:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801874:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  80187a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80187d:	29 c3                	sub    %eax,%ebx
		if (m > sizeof(buf) - 1)
  80187f:	83 fb 7f             	cmp    $0x7f,%ebx
  801882:	76 05                	jbe    801889 <devcons_write+0x31>
			m = sizeof(buf) - 1;
  801884:	bb 7f 00 00 00       	mov    $0x7f,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  801889:	83 ec 04             	sub    $0x4,%esp
  80188c:	53                   	push   %ebx
  80188d:	03 45 0c             	add    0xc(%ebp),%eax
  801890:	50                   	push   %eax
  801891:	57                   	push   %edi
  801892:	e8 78 f0 ff ff       	call   80090f <memmove>
		sys_cputs(buf, m);
  801897:	83 c4 08             	add    $0x8,%esp
  80189a:	53                   	push   %ebx
  80189b:	57                   	push   %edi
  80189c:	e8 78 f2 ff ff       	call   800b19 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8018a1:	01 de                	add    %ebx,%esi
  8018a3:	89 f0                	mov    %esi,%eax
  8018a5:	83 c4 10             	add    $0x10,%esp
  8018a8:	3b 75 10             	cmp    0x10(%ebp),%esi
  8018ab:	72 cd                	jb     80187a <devcons_write+0x22>
  8018ad:	eb 05                	jmp    8018b4 <devcons_write+0x5c>
  8018af:	be 00 00 00 00       	mov    $0x0,%esi
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8018b4:	89 f0                	mov    %esi,%eax
  8018b6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8018b9:	5b                   	pop    %ebx
  8018ba:	5e                   	pop    %esi
  8018bb:	5f                   	pop    %edi
  8018bc:	c9                   	leave  
  8018bd:	c3                   	ret    

008018be <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8018be:	55                   	push   %ebp
  8018bf:	89 e5                	mov    %esp,%ebp
  8018c1:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  8018c4:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8018c8:	75 07                	jne    8018d1 <devcons_read+0x13>
  8018ca:	eb 25                	jmp    8018f1 <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8018cc:	e8 d8 f2 ff ff       	call   800ba9 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8018d1:	e8 69 f2 ff ff       	call   800b3f <sys_cgetc>
  8018d6:	85 c0                	test   %eax,%eax
  8018d8:	74 f2                	je     8018cc <devcons_read+0xe>
  8018da:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  8018dc:	85 c0                	test   %eax,%eax
  8018de:	78 1d                	js     8018fd <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8018e0:	83 f8 04             	cmp    $0x4,%eax
  8018e3:	74 13                	je     8018f8 <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  8018e5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018e8:	88 10                	mov    %dl,(%eax)
	return 1;
  8018ea:	b8 01 00 00 00       	mov    $0x1,%eax
  8018ef:	eb 0c                	jmp    8018fd <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  8018f1:	b8 00 00 00 00       	mov    $0x0,%eax
  8018f6:	eb 05                	jmp    8018fd <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8018f8:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8018fd:	c9                   	leave  
  8018fe:	c3                   	ret    

008018ff <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  8018ff:	55                   	push   %ebp
  801900:	89 e5                	mov    %esp,%ebp
  801902:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801905:	8b 45 08             	mov    0x8(%ebp),%eax
  801908:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  80190b:	6a 01                	push   $0x1
  80190d:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801910:	50                   	push   %eax
  801911:	e8 03 f2 ff ff       	call   800b19 <sys_cputs>
  801916:	83 c4 10             	add    $0x10,%esp
}
  801919:	c9                   	leave  
  80191a:	c3                   	ret    

0080191b <getchar>:

int
getchar(void)
{
  80191b:	55                   	push   %ebp
  80191c:	89 e5                	mov    %esp,%ebp
  80191e:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801921:	6a 01                	push   $0x1
  801923:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801926:	50                   	push   %eax
  801927:	6a 00                	push   $0x0
  801929:	e8 fe f6 ff ff       	call   80102c <read>
	if (r < 0)
  80192e:	83 c4 10             	add    $0x10,%esp
  801931:	85 c0                	test   %eax,%eax
  801933:	78 0f                	js     801944 <getchar+0x29>
		return r;
	if (r < 1)
  801935:	85 c0                	test   %eax,%eax
  801937:	7e 06                	jle    80193f <getchar+0x24>
		return -E_EOF;
	return c;
  801939:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  80193d:	eb 05                	jmp    801944 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  80193f:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801944:	c9                   	leave  
  801945:	c3                   	ret    

00801946 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801946:	55                   	push   %ebp
  801947:	89 e5                	mov    %esp,%ebp
  801949:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80194c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80194f:	50                   	push   %eax
  801950:	ff 75 08             	pushl  0x8(%ebp)
  801953:	e8 53 f4 ff ff       	call   800dab <fd_lookup>
  801958:	83 c4 10             	add    $0x10,%esp
  80195b:	85 c0                	test   %eax,%eax
  80195d:	78 11                	js     801970 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  80195f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801962:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801968:	39 10                	cmp    %edx,(%eax)
  80196a:	0f 94 c0             	sete   %al
  80196d:	0f b6 c0             	movzbl %al,%eax
}
  801970:	c9                   	leave  
  801971:	c3                   	ret    

00801972 <opencons>:

int
opencons(void)
{
  801972:	55                   	push   %ebp
  801973:	89 e5                	mov    %esp,%ebp
  801975:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801978:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80197b:	50                   	push   %eax
  80197c:	e8 b7 f3 ff ff       	call   800d38 <fd_alloc>
  801981:	83 c4 10             	add    $0x10,%esp
  801984:	85 c0                	test   %eax,%eax
  801986:	78 3a                	js     8019c2 <opencons+0x50>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801988:	83 ec 04             	sub    $0x4,%esp
  80198b:	68 07 04 00 00       	push   $0x407
  801990:	ff 75 f4             	pushl  -0xc(%ebp)
  801993:	6a 00                	push   $0x0
  801995:	e8 36 f2 ff ff       	call   800bd0 <sys_page_alloc>
  80199a:	83 c4 10             	add    $0x10,%esp
  80199d:	85 c0                	test   %eax,%eax
  80199f:	78 21                	js     8019c2 <opencons+0x50>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8019a1:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8019a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019aa:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8019ac:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019af:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8019b6:	83 ec 0c             	sub    $0xc,%esp
  8019b9:	50                   	push   %eax
  8019ba:	e8 51 f3 ff ff       	call   800d10 <fd2num>
  8019bf:	83 c4 10             	add    $0x10,%esp
}
  8019c2:	c9                   	leave  
  8019c3:	c3                   	ret    

008019c4 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8019c4:	55                   	push   %ebp
  8019c5:	89 e5                	mov    %esp,%ebp
  8019c7:	56                   	push   %esi
  8019c8:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8019c9:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8019cc:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  8019d2:	e8 ae f1 ff ff       	call   800b85 <sys_getenvid>
  8019d7:	83 ec 0c             	sub    $0xc,%esp
  8019da:	ff 75 0c             	pushl  0xc(%ebp)
  8019dd:	ff 75 08             	pushl  0x8(%ebp)
  8019e0:	53                   	push   %ebx
  8019e1:	50                   	push   %eax
  8019e2:	68 58 22 80 00       	push   $0x802258
  8019e7:	e8 ac e7 ff ff       	call   800198 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8019ec:	83 c4 18             	add    $0x18,%esp
  8019ef:	56                   	push   %esi
  8019f0:	ff 75 10             	pushl  0x10(%ebp)
  8019f3:	e8 4f e7 ff ff       	call   800147 <vcprintf>
	cprintf("\n");
  8019f8:	c7 04 24 43 22 80 00 	movl   $0x802243,(%esp)
  8019ff:	e8 94 e7 ff ff       	call   800198 <cprintf>
  801a04:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801a07:	cc                   	int3   
  801a08:	eb fd                	jmp    801a07 <_panic+0x43>
	...

00801a0c <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801a0c:	55                   	push   %ebp
  801a0d:	89 e5                	mov    %esp,%ebp
  801a0f:	56                   	push   %esi
  801a10:	53                   	push   %ebx
  801a11:	8b 75 08             	mov    0x8(%ebp),%esi
  801a14:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a17:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// cprintf("0x%x 0x%x 0x%x\n", (uint32_t)from_env_store, (uint32_t)pg, (uint32_t)perm_store);
	int r;
	if (pg != NULL) {
  801a1a:	85 c0                	test   %eax,%eax
  801a1c:	74 0e                	je     801a2c <ipc_recv+0x20>
		r = sys_ipc_recv(pg);
  801a1e:	83 ec 0c             	sub    $0xc,%esp
  801a21:	50                   	push   %eax
  801a22:	e8 a4 f2 ff ff       	call   800ccb <sys_ipc_recv>
  801a27:	83 c4 10             	add    $0x10,%esp
  801a2a:	eb 10                	jmp    801a3c <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv((void *)UTOP);
  801a2c:	83 ec 0c             	sub    $0xc,%esp
  801a2f:	68 00 00 c0 ee       	push   $0xeec00000
  801a34:	e8 92 f2 ff ff       	call   800ccb <sys_ipc_recv>
  801a39:	83 c4 10             	add    $0x10,%esp
	}

	if (r == 0) {
  801a3c:	85 c0                	test   %eax,%eax
  801a3e:	75 26                	jne    801a66 <ipc_recv+0x5a>
		if (from_env_store != NULL) *from_env_store = thisenv->env_ipc_from;
  801a40:	85 f6                	test   %esi,%esi
  801a42:	74 0a                	je     801a4e <ipc_recv+0x42>
  801a44:	a1 04 40 80 00       	mov    0x804004,%eax
  801a49:	8b 40 74             	mov    0x74(%eax),%eax
  801a4c:	89 06                	mov    %eax,(%esi)
		if (perm_store != NULL) *perm_store = thisenv->env_ipc_perm;
  801a4e:	85 db                	test   %ebx,%ebx
  801a50:	74 0a                	je     801a5c <ipc_recv+0x50>
  801a52:	a1 04 40 80 00       	mov    0x804004,%eax
  801a57:	8b 40 78             	mov    0x78(%eax),%eax
  801a5a:	89 03                	mov    %eax,(%ebx)
		return thisenv->env_ipc_value;
  801a5c:	a1 04 40 80 00       	mov    0x804004,%eax
  801a61:	8b 40 70             	mov    0x70(%eax),%eax
  801a64:	eb 14                	jmp    801a7a <ipc_recv+0x6e>
	} else {
		// fails;
		if (from_env_store != NULL) *from_env_store = 0;
  801a66:	85 f6                	test   %esi,%esi
  801a68:	74 06                	je     801a70 <ipc_recv+0x64>
  801a6a:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if (perm_store != NULL) *perm_store = 0;
  801a70:	85 db                	test   %ebx,%ebx
  801a72:	74 06                	je     801a7a <ipc_recv+0x6e>
  801a74:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		return r;
	}
}
  801a7a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a7d:	5b                   	pop    %ebx
  801a7e:	5e                   	pop    %esi
  801a7f:	c9                   	leave  
  801a80:	c3                   	ret    

00801a81 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801a81:	55                   	push   %ebp
  801a82:	89 e5                	mov    %esp,%ebp
  801a84:	57                   	push   %edi
  801a85:	56                   	push   %esi
  801a86:	53                   	push   %ebx
  801a87:	83 ec 0c             	sub    $0xc,%esp
  801a8a:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801a8d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801a90:	8b 75 14             	mov    0x14(%ebp),%esi
	// LAB 4: Your code here.
	// int sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
	int r;
	if (pg == NULL) pg = (void *)UTOP;
  801a93:	85 db                	test   %ebx,%ebx
  801a95:	75 25                	jne    801abc <ipc_send+0x3b>
  801a97:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
  801a9c:	eb 1e                	jmp    801abc <ipc_send+0x3b>
	
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) != 0) {
		if (r == -E_IPC_NOT_RECV) {
  801a9e:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801aa1:	75 07                	jne    801aaa <ipc_send+0x29>
			// cprintf("Try Again and Again....\n");
			sys_yield();
  801aa3:	e8 01 f1 ff ff       	call   800ba9 <sys_yield>
  801aa8:	eb 12                	jmp    801abc <ipc_send+0x3b>
		} else {
			panic("ipc_send error %e\n", r);
  801aaa:	50                   	push   %eax
  801aab:	68 7c 22 80 00       	push   $0x80227c
  801ab0:	6a 43                	push   $0x43
  801ab2:	68 8f 22 80 00       	push   $0x80228f
  801ab7:	e8 08 ff ff ff       	call   8019c4 <_panic>
	// LAB 4: Your code here.
	// int sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
	int r;
	if (pg == NULL) pg = (void *)UTOP;
	
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) != 0) {
  801abc:	56                   	push   %esi
  801abd:	53                   	push   %ebx
  801abe:	57                   	push   %edi
  801abf:	ff 75 08             	pushl  0x8(%ebp)
  801ac2:	e8 df f1 ff ff       	call   800ca6 <sys_ipc_try_send>
  801ac7:	83 c4 10             	add    $0x10,%esp
  801aca:	85 c0                	test   %eax,%eax
  801acc:	75 d0                	jne    801a9e <ipc_send+0x1d>
		} else {
			panic("ipc_send error %e\n", r);
		}
	}
	return;
}
  801ace:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ad1:	5b                   	pop    %ebx
  801ad2:	5e                   	pop    %esi
  801ad3:	5f                   	pop    %edi
  801ad4:	c9                   	leave  
  801ad5:	c3                   	ret    

00801ad6 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801ad6:	55                   	push   %ebp
  801ad7:	89 e5                	mov    %esp,%ebp
  801ad9:	53                   	push   %ebx
  801ada:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  801add:	39 1d 50 00 c0 ee    	cmp    %ebx,0xeec00050
  801ae3:	74 22                	je     801b07 <ipc_find_env+0x31>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801ae5:	b8 01 00 00 00       	mov    $0x1,%eax
		if (envs[i].env_type == type)
  801aea:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  801af1:	89 c2                	mov    %eax,%edx
  801af3:	c1 e2 07             	shl    $0x7,%edx
  801af6:	29 ca                	sub    %ecx,%edx
  801af8:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801afe:	8b 52 50             	mov    0x50(%edx),%edx
  801b01:	39 da                	cmp    %ebx,%edx
  801b03:	75 1d                	jne    801b22 <ipc_find_env+0x4c>
  801b05:	eb 05                	jmp    801b0c <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801b07:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
			return envs[i].env_id;
  801b0c:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  801b13:	c1 e0 07             	shl    $0x7,%eax
  801b16:	29 d0                	sub    %edx,%eax
  801b18:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  801b1d:	8b 40 40             	mov    0x40(%eax),%eax
  801b20:	eb 0c                	jmp    801b2e <ipc_find_env+0x58>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801b22:	40                   	inc    %eax
  801b23:	3d 00 04 00 00       	cmp    $0x400,%eax
  801b28:	75 c0                	jne    801aea <ipc_find_env+0x14>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801b2a:	66 b8 00 00          	mov    $0x0,%ax
}
  801b2e:	5b                   	pop    %ebx
  801b2f:	c9                   	leave  
  801b30:	c3                   	ret    
  801b31:	00 00                	add    %al,(%eax)
	...

00801b34 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801b34:	55                   	push   %ebp
  801b35:	89 e5                	mov    %esp,%ebp
  801b37:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b3a:	89 c2                	mov    %eax,%edx
  801b3c:	c1 ea 16             	shr    $0x16,%edx
  801b3f:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801b46:	f6 c2 01             	test   $0x1,%dl
  801b49:	74 1e                	je     801b69 <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  801b4b:	c1 e8 0c             	shr    $0xc,%eax
  801b4e:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801b55:	a8 01                	test   $0x1,%al
  801b57:	74 17                	je     801b70 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801b59:	c1 e8 0c             	shr    $0xc,%eax
  801b5c:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  801b63:	ef 
  801b64:	0f b7 c0             	movzwl %ax,%eax
  801b67:	eb 0c                	jmp    801b75 <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  801b69:	b8 00 00 00 00       	mov    $0x0,%eax
  801b6e:	eb 05                	jmp    801b75 <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  801b70:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  801b75:	c9                   	leave  
  801b76:	c3                   	ret    
	...

00801b78 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  801b78:	55                   	push   %ebp
  801b79:	89 e5                	mov    %esp,%ebp
  801b7b:	57                   	push   %edi
  801b7c:	56                   	push   %esi
  801b7d:	83 ec 10             	sub    $0x10,%esp
  801b80:	8b 7d 08             	mov    0x8(%ebp),%edi
  801b83:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  801b86:	89 7d f0             	mov    %edi,-0x10(%ebp)
  801b89:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  801b8c:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  801b8f:	8b 45 14             	mov    0x14(%ebp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  801b92:	85 c0                	test   %eax,%eax
  801b94:	75 2e                	jne    801bc4 <__udivdi3+0x4c>
    {
      if (d0 > n1)
  801b96:	39 f1                	cmp    %esi,%ecx
  801b98:	77 5a                	ja     801bf4 <__udivdi3+0x7c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  801b9a:	85 c9                	test   %ecx,%ecx
  801b9c:	75 0b                	jne    801ba9 <__udivdi3+0x31>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  801b9e:	b8 01 00 00 00       	mov    $0x1,%eax
  801ba3:	31 d2                	xor    %edx,%edx
  801ba5:	f7 f1                	div    %ecx
  801ba7:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  801ba9:	31 d2                	xor    %edx,%edx
  801bab:	89 f0                	mov    %esi,%eax
  801bad:	f7 f1                	div    %ecx
  801baf:	89 c6                	mov    %eax,%esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801bb1:	89 f8                	mov    %edi,%eax
  801bb3:	f7 f1                	div    %ecx
  801bb5:	89 c7                	mov    %eax,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801bb7:	89 f8                	mov    %edi,%eax
  801bb9:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801bbb:	83 c4 10             	add    $0x10,%esp
  801bbe:	5e                   	pop    %esi
  801bbf:	5f                   	pop    %edi
  801bc0:	c9                   	leave  
  801bc1:	c3                   	ret    
  801bc2:	66 90                	xchg   %ax,%ax
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801bc4:	39 f0                	cmp    %esi,%eax
  801bc6:	77 1c                	ja     801be4 <__udivdi3+0x6c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  801bc8:	0f bd f8             	bsr    %eax,%edi
	  if (bm == 0)
  801bcb:	83 f7 1f             	xor    $0x1f,%edi
  801bce:	75 3c                	jne    801c0c <__udivdi3+0x94>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801bd0:	39 f0                	cmp    %esi,%eax
  801bd2:	0f 82 90 00 00 00    	jb     801c68 <__udivdi3+0xf0>
  801bd8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801bdb:	39 55 f4             	cmp    %edx,-0xc(%ebp)
  801bde:	0f 86 84 00 00 00    	jbe    801c68 <__udivdi3+0xf0>
  801be4:	31 f6                	xor    %esi,%esi
  801be6:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801be8:	89 f8                	mov    %edi,%eax
  801bea:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801bec:	83 c4 10             	add    $0x10,%esp
  801bef:	5e                   	pop    %esi
  801bf0:	5f                   	pop    %edi
  801bf1:	c9                   	leave  
  801bf2:	c3                   	ret    
  801bf3:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801bf4:	89 f2                	mov    %esi,%edx
  801bf6:	89 f8                	mov    %edi,%eax
  801bf8:	f7 f1                	div    %ecx
  801bfa:	89 c7                	mov    %eax,%edi
  801bfc:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801bfe:	89 f8                	mov    %edi,%eax
  801c00:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801c02:	83 c4 10             	add    $0x10,%esp
  801c05:	5e                   	pop    %esi
  801c06:	5f                   	pop    %edi
  801c07:	c9                   	leave  
  801c08:	c3                   	ret    
  801c09:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  801c0c:	89 f9                	mov    %edi,%ecx
  801c0e:	d3 e0                	shl    %cl,%eax
  801c10:	89 45 e8             	mov    %eax,-0x18(%ebp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  801c13:	b8 20 00 00 00       	mov    $0x20,%eax
  801c18:	29 f8                	sub    %edi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  801c1a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801c1d:	88 c1                	mov    %al,%cl
  801c1f:	d3 ea                	shr    %cl,%edx
  801c21:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  801c24:	09 ca                	or     %ecx,%edx
  801c26:	89 55 ec             	mov    %edx,-0x14(%ebp)
	      d0 = d0 << bm;
  801c29:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801c2c:	89 f9                	mov    %edi,%ecx
  801c2e:	d3 e2                	shl    %cl,%edx
  801c30:	89 55 f4             	mov    %edx,-0xc(%ebp)
	      n2 = n1 >> b;
  801c33:	89 f2                	mov    %esi,%edx
  801c35:	88 c1                	mov    %al,%cl
  801c37:	d3 ea                	shr    %cl,%edx
  801c39:	89 55 e8             	mov    %edx,-0x18(%ebp)
	      n1 = (n1 << bm) | (n0 >> b);
  801c3c:	89 f2                	mov    %esi,%edx
  801c3e:	89 f9                	mov    %edi,%ecx
  801c40:	d3 e2                	shl    %cl,%edx
  801c42:	8b 75 f0             	mov    -0x10(%ebp),%esi
  801c45:	88 c1                	mov    %al,%cl
  801c47:	d3 ee                	shr    %cl,%esi
  801c49:	09 d6                	or     %edx,%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  801c4b:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  801c4e:	89 f0                	mov    %esi,%eax
  801c50:	89 ca                	mov    %ecx,%edx
  801c52:	f7 75 ec             	divl   -0x14(%ebp)
  801c55:	89 d1                	mov    %edx,%ecx
  801c57:	89 c6                	mov    %eax,%esi
	      umul_ppmm (m1, m0, q0, d0);
  801c59:	f7 65 f4             	mull   -0xc(%ebp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801c5c:	39 d1                	cmp    %edx,%ecx
  801c5e:	72 28                	jb     801c88 <__udivdi3+0x110>
  801c60:	74 1a                	je     801c7c <__udivdi3+0x104>
  801c62:	89 f7                	mov    %esi,%edi
  801c64:	31 f6                	xor    %esi,%esi
  801c66:	eb 80                	jmp    801be8 <__udivdi3+0x70>
	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  801c68:	31 f6                	xor    %esi,%esi
  801c6a:	bf 01 00 00 00       	mov    $0x1,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801c6f:	89 f8                	mov    %edi,%eax
  801c71:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801c73:	83 c4 10             	add    $0x10,%esp
  801c76:	5e                   	pop    %esi
  801c77:	5f                   	pop    %edi
  801c78:	c9                   	leave  
  801c79:	c3                   	ret    
  801c7a:	66 90                	xchg   %ax,%ax

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  801c7c:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801c7f:	89 f9                	mov    %edi,%ecx
  801c81:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801c83:	39 c2                	cmp    %eax,%edx
  801c85:	73 db                	jae    801c62 <__udivdi3+0xea>
  801c87:	90                   	nop
		{
		  q0--;
  801c88:	8d 7e ff             	lea    -0x1(%esi),%edi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  801c8b:	31 f6                	xor    %esi,%esi
  801c8d:	e9 56 ff ff ff       	jmp    801be8 <__udivdi3+0x70>
	...

00801c94 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  801c94:	55                   	push   %ebp
  801c95:	89 e5                	mov    %esp,%ebp
  801c97:	57                   	push   %edi
  801c98:	56                   	push   %esi
  801c99:	83 ec 20             	sub    $0x20,%esp
  801c9c:	8b 45 08             	mov    0x8(%ebp),%eax
  801c9f:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  801ca2:	89 45 e8             	mov    %eax,-0x18(%ebp)
  801ca5:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  801ca8:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  801cab:	8b 7d 14             	mov    0x14(%ebp),%edi
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  801cae:	89 45 f0             	mov    %eax,-0x10(%ebp)
  n1 = nn.s.high;
  801cb1:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  801cb3:	85 ff                	test   %edi,%edi
  801cb5:	75 15                	jne    801ccc <__umoddi3+0x38>
    {
      if (d0 > n1)
  801cb7:	39 f1                	cmp    %esi,%ecx
  801cb9:	0f 86 99 00 00 00    	jbe    801d58 <__umoddi3+0xc4>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801cbf:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  801cc1:	89 d0                	mov    %edx,%eax
  801cc3:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801cc5:	83 c4 20             	add    $0x20,%esp
  801cc8:	5e                   	pop    %esi
  801cc9:	5f                   	pop    %edi
  801cca:	c9                   	leave  
  801ccb:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801ccc:	39 f7                	cmp    %esi,%edi
  801cce:	0f 87 a4 00 00 00    	ja     801d78 <__umoddi3+0xe4>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  801cd4:	0f bd c7             	bsr    %edi,%eax
	  if (bm == 0)
  801cd7:	83 f0 1f             	xor    $0x1f,%eax
  801cda:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801cdd:	0f 84 a1 00 00 00    	je     801d84 <__umoddi3+0xf0>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  801ce3:	89 f8                	mov    %edi,%eax
  801ce5:	8a 4d ec             	mov    -0x14(%ebp),%cl
  801ce8:	d3 e0                	shl    %cl,%eax
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  801cea:	bf 20 00 00 00       	mov    $0x20,%edi
  801cef:	2b 7d ec             	sub    -0x14(%ebp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  801cf2:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801cf5:	89 f9                	mov    %edi,%ecx
  801cf7:	d3 ea                	shr    %cl,%edx
  801cf9:	09 c2                	or     %eax,%edx
  801cfb:	89 55 f0             	mov    %edx,-0x10(%ebp)
	      d0 = d0 << bm;
  801cfe:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d01:	8a 4d ec             	mov    -0x14(%ebp),%cl
  801d04:	d3 e0                	shl    %cl,%eax
  801d06:	89 45 f4             	mov    %eax,-0xc(%ebp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  801d09:	89 f2                	mov    %esi,%edx
  801d0b:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  801d0d:	8b 45 e8             	mov    -0x18(%ebp),%eax
  801d10:	d3 e0                	shl    %cl,%eax
  801d12:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  801d15:	8b 45 e8             	mov    -0x18(%ebp),%eax
  801d18:	89 f9                	mov    %edi,%ecx
  801d1a:	d3 e8                	shr    %cl,%eax
  801d1c:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  801d1e:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  801d20:	89 f2                	mov    %esi,%edx
  801d22:	f7 75 f0             	divl   -0x10(%ebp)
  801d25:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  801d27:	f7 65 f4             	mull   -0xc(%ebp)
  801d2a:	89 55 e8             	mov    %edx,-0x18(%ebp)
  801d2d:	89 c1                	mov    %eax,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801d2f:	39 d6                	cmp    %edx,%esi
  801d31:	72 71                	jb     801da4 <__umoddi3+0x110>
  801d33:	74 7f                	je     801db4 <__umoddi3+0x120>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  801d35:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801d38:	29 c8                	sub    %ecx,%eax
  801d3a:	19 d6                	sbb    %edx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  801d3c:	8a 4d ec             	mov    -0x14(%ebp),%cl
  801d3f:	d3 e8                	shr    %cl,%eax
  801d41:	89 f2                	mov    %esi,%edx
  801d43:	89 f9                	mov    %edi,%ecx
  801d45:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  801d47:	09 d0                	or     %edx,%eax
  801d49:	89 f2                	mov    %esi,%edx
  801d4b:	8a 4d ec             	mov    -0x14(%ebp),%cl
  801d4e:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801d50:	83 c4 20             	add    $0x20,%esp
  801d53:	5e                   	pop    %esi
  801d54:	5f                   	pop    %edi
  801d55:	c9                   	leave  
  801d56:	c3                   	ret    
  801d57:	90                   	nop
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  801d58:	85 c9                	test   %ecx,%ecx
  801d5a:	75 0b                	jne    801d67 <__umoddi3+0xd3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  801d5c:	b8 01 00 00 00       	mov    $0x1,%eax
  801d61:	31 d2                	xor    %edx,%edx
  801d63:	f7 f1                	div    %ecx
  801d65:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  801d67:	89 f0                	mov    %esi,%eax
  801d69:	31 d2                	xor    %edx,%edx
  801d6b:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801d6d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801d70:	f7 f1                	div    %ecx
  801d72:	e9 4a ff ff ff       	jmp    801cc1 <__umoddi3+0x2d>
  801d77:	90                   	nop
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  801d78:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801d7a:	83 c4 20             	add    $0x20,%esp
  801d7d:	5e                   	pop    %esi
  801d7e:	5f                   	pop    %edi
  801d7f:	c9                   	leave  
  801d80:	c3                   	ret    
  801d81:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801d84:	39 f7                	cmp    %esi,%edi
  801d86:	72 05                	jb     801d8d <__umoddi3+0xf9>
  801d88:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
  801d8b:	77 0c                	ja     801d99 <__umoddi3+0x105>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  801d8d:	89 f2                	mov    %esi,%edx
  801d8f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801d92:	29 c8                	sub    %ecx,%eax
  801d94:	19 fa                	sbb    %edi,%edx
  801d96:	89 45 f0             	mov    %eax,-0x10(%ebp)

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  801d99:	8b 45 f0             	mov    -0x10(%ebp),%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801d9c:	83 c4 20             	add    $0x20,%esp
  801d9f:	5e                   	pop    %esi
  801da0:	5f                   	pop    %edi
  801da1:	c9                   	leave  
  801da2:	c3                   	ret    
  801da3:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  801da4:	8b 55 e8             	mov    -0x18(%ebp),%edx
  801da7:	89 c1                	mov    %eax,%ecx
  801da9:	2b 4d f4             	sub    -0xc(%ebp),%ecx
  801dac:	1b 55 f0             	sbb    -0x10(%ebp),%edx
  801daf:	eb 84                	jmp    801d35 <__umoddi3+0xa1>
  801db1:	8d 76 00             	lea    0x0(%esi),%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801db4:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801db7:	72 eb                	jb     801da4 <__umoddi3+0x110>
  801db9:	89 f2                	mov    %esi,%edx
  801dbb:	e9 75 ff ff ff       	jmp    801d35 <__umoddi3+0xa1>
