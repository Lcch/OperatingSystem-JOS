
obj/user/fairness:     file format elf32-i386


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
  80002c:	e8 73 00 00 00       	call   8000a4 <libmain>
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
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 10             	sub    $0x10,%esp
	envid_t who, id;

	id = sys_getenvid();
  80003c:	e8 44 0b 00 00       	call   800b85 <sys_getenvid>
  800041:	89 c3                	mov    %eax,%ebx

	if (thisenv == &envs[1]) {
  800043:	81 3d 04 20 80 00 7c 	cmpl   $0xeec0007c,0x802004
  80004a:	00 c0 ee 
  80004d:	75 26                	jne    800075 <umain+0x41>
		while (1) {
			ipc_recv(&who, 0, 0);
  80004f:	8d 75 f4             	lea    -0xc(%ebp),%esi
  800052:	83 ec 04             	sub    $0x4,%esp
  800055:	6a 00                	push   $0x0
  800057:	6a 00                	push   $0x0
  800059:	56                   	push   %esi
  80005a:	e8 6d 0c 00 00       	call   800ccc <ipc_recv>
			cprintf("%x recv from %x\n", id, who);
  80005f:	83 c4 0c             	add    $0xc,%esp
  800062:	ff 75 f4             	pushl  -0xc(%ebp)
  800065:	53                   	push   %ebx
  800066:	68 00 10 80 00       	push   $0x801000
  80006b:	e8 28 01 00 00       	call   800198 <cprintf>
  800070:	83 c4 10             	add    $0x10,%esp
  800073:	eb dd                	jmp    800052 <umain+0x1e>
		}
	} else {
		cprintf("%x loop sending to %x\n", id, envs[1].env_id);
  800075:	83 ec 04             	sub    $0x4,%esp
  800078:	ff 35 c4 00 c0 ee    	pushl  0xeec000c4
  80007e:	50                   	push   %eax
  80007f:	68 11 10 80 00       	push   $0x801011
  800084:	e8 0f 01 00 00       	call   800198 <cprintf>
  800089:	83 c4 10             	add    $0x10,%esp
		while (1)
			ipc_send(envs[1].env_id, 0, 0, 0);
  80008c:	6a 00                	push   $0x0
  80008e:	6a 00                	push   $0x0
  800090:	6a 00                	push   $0x0
  800092:	ff 35 c4 00 c0 ee    	pushl  0xeec000c4
  800098:	e8 46 0c 00 00       	call   800ce3 <ipc_send>
  80009d:	83 c4 10             	add    $0x10,%esp
  8000a0:	eb ea                	jmp    80008c <umain+0x58>
	...

008000a4 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000a4:	55                   	push   %ebp
  8000a5:	89 e5                	mov    %esp,%ebp
  8000a7:	56                   	push   %esi
  8000a8:	53                   	push   %ebx
  8000a9:	8b 75 08             	mov    0x8(%ebp),%esi
  8000ac:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs + ENVX(sys_getenvid());
  8000af:	e8 d1 0a 00 00       	call   800b85 <sys_getenvid>
  8000b4:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000b9:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  8000c0:	c1 e0 07             	shl    $0x7,%eax
  8000c3:	29 d0                	sub    %edx,%eax
  8000c5:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000ca:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000cf:	85 f6                	test   %esi,%esi
  8000d1:	7e 07                	jle    8000da <libmain+0x36>
		binaryname = argv[0];
  8000d3:	8b 03                	mov    (%ebx),%eax
  8000d5:	a3 00 20 80 00       	mov    %eax,0x802000
	// call user main routine
	umain(argc, argv);
  8000da:	83 ec 08             	sub    $0x8,%esp
  8000dd:	53                   	push   %ebx
  8000de:	56                   	push   %esi
  8000df:	e8 50 ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  8000e4:	e8 0b 00 00 00       	call   8000f4 <exit>
  8000e9:	83 c4 10             	add    $0x10,%esp
}
  8000ec:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000ef:	5b                   	pop    %ebx
  8000f0:	5e                   	pop    %esi
  8000f1:	c9                   	leave  
  8000f2:	c3                   	ret    
	...

008000f4 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000f4:	55                   	push   %ebp
  8000f5:	89 e5                	mov    %esp,%ebp
  8000f7:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
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
  800200:	e8 9b 0b 00 00       	call   800da0 <__udivdi3>
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
  80023c:	e8 7b 0c 00 00       	call   800ebc <__umoddi3>
  800241:	83 c4 14             	add    $0x14,%esp
  800244:	0f be 80 32 10 80 00 	movsbl 0x801032(%eax),%eax
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
  800388:	ff 24 85 00 11 80 00 	jmp    *0x801100(,%eax,4)
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
  80042f:	83 f8 08             	cmp    $0x8,%eax
  800432:	7f 0b                	jg     80043f <vprintfmt+0x142>
  800434:	8b 04 85 60 12 80 00 	mov    0x801260(,%eax,4),%eax
  80043b:	85 c0                	test   %eax,%eax
  80043d:	75 1a                	jne    800459 <vprintfmt+0x15c>
				printfmt(putch, putdat, "error %d", err);
  80043f:	52                   	push   %edx
  800440:	68 4a 10 80 00       	push   $0x80104a
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
  80045a:	68 53 10 80 00       	push   $0x801053
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
  800490:	c7 45 d0 43 10 80 00 	movl   $0x801043,-0x30(%ebp)
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
  800afe:	68 84 12 80 00       	push   $0x801284
  800b03:	6a 42                	push   $0x42
  800b05:	68 a1 12 80 00       	push   $0x8012a1
  800b0a:	e8 49 02 00 00       	call   800d58 <_panic>

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
  800bc1:	b8 0a 00 00 00       	mov    $0xa,%eax
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

00800c60 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800c60:	55                   	push   %ebp
  800c61:	89 e5                	mov    %esp,%ebp
  800c63:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
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

00800c83 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800c83:	55                   	push   %ebp
  800c84:	89 e5                	mov    %esp,%ebp
  800c86:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  800c89:	6a 00                	push   $0x0
  800c8b:	ff 75 14             	pushl  0x14(%ebp)
  800c8e:	ff 75 10             	pushl  0x10(%ebp)
  800c91:	ff 75 0c             	pushl  0xc(%ebp)
  800c94:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c97:	ba 00 00 00 00       	mov    $0x0,%edx
  800c9c:	b8 0b 00 00 00       	mov    $0xb,%eax
  800ca1:	e8 26 fe ff ff       	call   800acc <syscall>
}
  800ca6:	c9                   	leave  
  800ca7:	c3                   	ret    

00800ca8 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800ca8:	55                   	push   %ebp
  800ca9:	89 e5                	mov    %esp,%ebp
  800cab:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  800cae:	6a 00                	push   $0x0
  800cb0:	6a 00                	push   $0x0
  800cb2:	6a 00                	push   $0x0
  800cb4:	6a 00                	push   $0x0
  800cb6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800cb9:	ba 01 00 00 00       	mov    $0x1,%edx
  800cbe:	b8 0c 00 00 00       	mov    $0xc,%eax
  800cc3:	e8 04 fe ff ff       	call   800acc <syscall>
}
  800cc8:	c9                   	leave  
  800cc9:	c3                   	ret    
	...

00800ccc <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  800ccc:	55                   	push   %ebp
  800ccd:	89 e5                	mov    %esp,%ebp
  800ccf:	83 ec 0c             	sub    $0xc,%esp
	// LAB 4: Your code here.
	panic("ipc_recv not implemented");
  800cd2:	68 af 12 80 00       	push   $0x8012af
  800cd7:	6a 1a                	push   $0x1a
  800cd9:	68 c8 12 80 00       	push   $0x8012c8
  800cde:	e8 75 00 00 00       	call   800d58 <_panic>

00800ce3 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  800ce3:	55                   	push   %ebp
  800ce4:	89 e5                	mov    %esp,%ebp
  800ce6:	83 ec 0c             	sub    $0xc,%esp
	// LAB 4: Your code here.
	panic("ipc_send not implemented");
  800ce9:	68 d2 12 80 00       	push   $0x8012d2
  800cee:	6a 2a                	push   $0x2a
  800cf0:	68 c8 12 80 00       	push   $0x8012c8
  800cf5:	e8 5e 00 00 00       	call   800d58 <_panic>

00800cfa <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  800cfa:	55                   	push   %ebp
  800cfb:	89 e5                	mov    %esp,%ebp
  800cfd:	53                   	push   %ebx
  800cfe:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  800d01:	39 1d 50 00 c0 ee    	cmp    %ebx,0xeec00050
  800d07:	74 22                	je     800d2b <ipc_find_env+0x31>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  800d09:	b8 01 00 00 00       	mov    $0x1,%eax
		if (envs[i].env_type == type)
  800d0e:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  800d15:	89 c2                	mov    %eax,%edx
  800d17:	c1 e2 07             	shl    $0x7,%edx
  800d1a:	29 ca                	sub    %ecx,%edx
  800d1c:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  800d22:	8b 52 50             	mov    0x50(%edx),%edx
  800d25:	39 da                	cmp    %ebx,%edx
  800d27:	75 1d                	jne    800d46 <ipc_find_env+0x4c>
  800d29:	eb 05                	jmp    800d30 <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  800d2b:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
			return envs[i].env_id;
  800d30:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800d37:	c1 e0 07             	shl    $0x7,%eax
  800d3a:	29 d0                	sub    %edx,%eax
  800d3c:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  800d41:	8b 40 40             	mov    0x40(%eax),%eax
  800d44:	eb 0c                	jmp    800d52 <ipc_find_env+0x58>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  800d46:	40                   	inc    %eax
  800d47:	3d 00 04 00 00       	cmp    $0x400,%eax
  800d4c:	75 c0                	jne    800d0e <ipc_find_env+0x14>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  800d4e:	66 b8 00 00          	mov    $0x0,%ax
}
  800d52:	5b                   	pop    %ebx
  800d53:	c9                   	leave  
  800d54:	c3                   	ret    
  800d55:	00 00                	add    %al,(%eax)
	...

00800d58 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800d58:	55                   	push   %ebp
  800d59:	89 e5                	mov    %esp,%ebp
  800d5b:	56                   	push   %esi
  800d5c:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800d5d:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800d60:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  800d66:	e8 1a fe ff ff       	call   800b85 <sys_getenvid>
  800d6b:	83 ec 0c             	sub    $0xc,%esp
  800d6e:	ff 75 0c             	pushl  0xc(%ebp)
  800d71:	ff 75 08             	pushl  0x8(%ebp)
  800d74:	53                   	push   %ebx
  800d75:	50                   	push   %eax
  800d76:	68 ec 12 80 00       	push   $0x8012ec
  800d7b:	e8 18 f4 ff ff       	call   800198 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800d80:	83 c4 18             	add    $0x18,%esp
  800d83:	56                   	push   %esi
  800d84:	ff 75 10             	pushl  0x10(%ebp)
  800d87:	e8 bb f3 ff ff       	call   800147 <vcprintf>
	cprintf("\n");
  800d8c:	c7 04 24 0f 10 80 00 	movl   $0x80100f,(%esp)
  800d93:	e8 00 f4 ff ff       	call   800198 <cprintf>
  800d98:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800d9b:	cc                   	int3   
  800d9c:	eb fd                	jmp    800d9b <_panic+0x43>
	...

00800da0 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  800da0:	55                   	push   %ebp
  800da1:	89 e5                	mov    %esp,%ebp
  800da3:	57                   	push   %edi
  800da4:	56                   	push   %esi
  800da5:	83 ec 10             	sub    $0x10,%esp
  800da8:	8b 7d 08             	mov    0x8(%ebp),%edi
  800dab:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  800dae:	89 7d f0             	mov    %edi,-0x10(%ebp)
  800db1:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  800db4:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  800db7:	8b 45 14             	mov    0x14(%ebp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800dba:	85 c0                	test   %eax,%eax
  800dbc:	75 2e                	jne    800dec <__udivdi3+0x4c>
    {
      if (d0 > n1)
  800dbe:	39 f1                	cmp    %esi,%ecx
  800dc0:	77 5a                	ja     800e1c <__udivdi3+0x7c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  800dc2:	85 c9                	test   %ecx,%ecx
  800dc4:	75 0b                	jne    800dd1 <__udivdi3+0x31>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  800dc6:	b8 01 00 00 00       	mov    $0x1,%eax
  800dcb:	31 d2                	xor    %edx,%edx
  800dcd:	f7 f1                	div    %ecx
  800dcf:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  800dd1:	31 d2                	xor    %edx,%edx
  800dd3:	89 f0                	mov    %esi,%eax
  800dd5:	f7 f1                	div    %ecx
  800dd7:	89 c6                	mov    %eax,%esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800dd9:	89 f8                	mov    %edi,%eax
  800ddb:	f7 f1                	div    %ecx
  800ddd:	89 c7                	mov    %eax,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800ddf:	89 f8                	mov    %edi,%eax
  800de1:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800de3:	83 c4 10             	add    $0x10,%esp
  800de6:	5e                   	pop    %esi
  800de7:	5f                   	pop    %edi
  800de8:	c9                   	leave  
  800de9:	c3                   	ret    
  800dea:	66 90                	xchg   %ax,%ax
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800dec:	39 f0                	cmp    %esi,%eax
  800dee:	77 1c                	ja     800e0c <__udivdi3+0x6c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  800df0:	0f bd f8             	bsr    %eax,%edi
	  if (bm == 0)
  800df3:	83 f7 1f             	xor    $0x1f,%edi
  800df6:	75 3c                	jne    800e34 <__udivdi3+0x94>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800df8:	39 f0                	cmp    %esi,%eax
  800dfa:	0f 82 90 00 00 00    	jb     800e90 <__udivdi3+0xf0>
  800e00:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800e03:	39 55 f4             	cmp    %edx,-0xc(%ebp)
  800e06:	0f 86 84 00 00 00    	jbe    800e90 <__udivdi3+0xf0>
  800e0c:	31 f6                	xor    %esi,%esi
  800e0e:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800e10:	89 f8                	mov    %edi,%eax
  800e12:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800e14:	83 c4 10             	add    $0x10,%esp
  800e17:	5e                   	pop    %esi
  800e18:	5f                   	pop    %edi
  800e19:	c9                   	leave  
  800e1a:	c3                   	ret    
  800e1b:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800e1c:	89 f2                	mov    %esi,%edx
  800e1e:	89 f8                	mov    %edi,%eax
  800e20:	f7 f1                	div    %ecx
  800e22:	89 c7                	mov    %eax,%edi
  800e24:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800e26:	89 f8                	mov    %edi,%eax
  800e28:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800e2a:	83 c4 10             	add    $0x10,%esp
  800e2d:	5e                   	pop    %esi
  800e2e:	5f                   	pop    %edi
  800e2f:	c9                   	leave  
  800e30:	c3                   	ret    
  800e31:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  800e34:	89 f9                	mov    %edi,%ecx
  800e36:	d3 e0                	shl    %cl,%eax
  800e38:	89 45 e8             	mov    %eax,-0x18(%ebp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  800e3b:	b8 20 00 00 00       	mov    $0x20,%eax
  800e40:	29 f8                	sub    %edi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  800e42:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800e45:	88 c1                	mov    %al,%cl
  800e47:	d3 ea                	shr    %cl,%edx
  800e49:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  800e4c:	09 ca                	or     %ecx,%edx
  800e4e:	89 55 ec             	mov    %edx,-0x14(%ebp)
	      d0 = d0 << bm;
  800e51:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800e54:	89 f9                	mov    %edi,%ecx
  800e56:	d3 e2                	shl    %cl,%edx
  800e58:	89 55 f4             	mov    %edx,-0xc(%ebp)
	      n2 = n1 >> b;
  800e5b:	89 f2                	mov    %esi,%edx
  800e5d:	88 c1                	mov    %al,%cl
  800e5f:	d3 ea                	shr    %cl,%edx
  800e61:	89 55 e8             	mov    %edx,-0x18(%ebp)
	      n1 = (n1 << bm) | (n0 >> b);
  800e64:	89 f2                	mov    %esi,%edx
  800e66:	89 f9                	mov    %edi,%ecx
  800e68:	d3 e2                	shl    %cl,%edx
  800e6a:	8b 75 f0             	mov    -0x10(%ebp),%esi
  800e6d:	88 c1                	mov    %al,%cl
  800e6f:	d3 ee                	shr    %cl,%esi
  800e71:	09 d6                	or     %edx,%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  800e73:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  800e76:	89 f0                	mov    %esi,%eax
  800e78:	89 ca                	mov    %ecx,%edx
  800e7a:	f7 75 ec             	divl   -0x14(%ebp)
  800e7d:	89 d1                	mov    %edx,%ecx
  800e7f:	89 c6                	mov    %eax,%esi
	      umul_ppmm (m1, m0, q0, d0);
  800e81:	f7 65 f4             	mull   -0xc(%ebp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800e84:	39 d1                	cmp    %edx,%ecx
  800e86:	72 28                	jb     800eb0 <__udivdi3+0x110>
  800e88:	74 1a                	je     800ea4 <__udivdi3+0x104>
  800e8a:	89 f7                	mov    %esi,%edi
  800e8c:	31 f6                	xor    %esi,%esi
  800e8e:	eb 80                	jmp    800e10 <__udivdi3+0x70>
	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  800e90:	31 f6                	xor    %esi,%esi
  800e92:	bf 01 00 00 00       	mov    $0x1,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800e97:	89 f8                	mov    %edi,%eax
  800e99:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800e9b:	83 c4 10             	add    $0x10,%esp
  800e9e:	5e                   	pop    %esi
  800e9f:	5f                   	pop    %edi
  800ea0:	c9                   	leave  
  800ea1:	c3                   	ret    
  800ea2:	66 90                	xchg   %ax,%ax

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  800ea4:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800ea7:	89 f9                	mov    %edi,%ecx
  800ea9:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800eab:	39 c2                	cmp    %eax,%edx
  800ead:	73 db                	jae    800e8a <__udivdi3+0xea>
  800eaf:	90                   	nop
		{
		  q0--;
  800eb0:	8d 7e ff             	lea    -0x1(%esi),%edi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  800eb3:	31 f6                	xor    %esi,%esi
  800eb5:	e9 56 ff ff ff       	jmp    800e10 <__udivdi3+0x70>
	...

00800ebc <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  800ebc:	55                   	push   %ebp
  800ebd:	89 e5                	mov    %esp,%ebp
  800ebf:	57                   	push   %edi
  800ec0:	56                   	push   %esi
  800ec1:	83 ec 20             	sub    $0x20,%esp
  800ec4:	8b 45 08             	mov    0x8(%ebp),%eax
  800ec7:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  800eca:	89 45 e8             	mov    %eax,-0x18(%ebp)
  800ecd:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  800ed0:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  800ed3:	8b 7d 14             	mov    0x14(%ebp),%edi
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  800ed6:	89 45 f0             	mov    %eax,-0x10(%ebp)
  n1 = nn.s.high;
  800ed9:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800edb:	85 ff                	test   %edi,%edi
  800edd:	75 15                	jne    800ef4 <__umoddi3+0x38>
    {
      if (d0 > n1)
  800edf:	39 f1                	cmp    %esi,%ecx
  800ee1:	0f 86 99 00 00 00    	jbe    800f80 <__umoddi3+0xc4>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800ee7:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  800ee9:	89 d0                	mov    %edx,%eax
  800eeb:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800eed:	83 c4 20             	add    $0x20,%esp
  800ef0:	5e                   	pop    %esi
  800ef1:	5f                   	pop    %edi
  800ef2:	c9                   	leave  
  800ef3:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800ef4:	39 f7                	cmp    %esi,%edi
  800ef6:	0f 87 a4 00 00 00    	ja     800fa0 <__umoddi3+0xe4>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  800efc:	0f bd c7             	bsr    %edi,%eax
	  if (bm == 0)
  800eff:	83 f0 1f             	xor    $0x1f,%eax
  800f02:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800f05:	0f 84 a1 00 00 00    	je     800fac <__umoddi3+0xf0>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  800f0b:	89 f8                	mov    %edi,%eax
  800f0d:	8a 4d ec             	mov    -0x14(%ebp),%cl
  800f10:	d3 e0                	shl    %cl,%eax
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  800f12:	bf 20 00 00 00       	mov    $0x20,%edi
  800f17:	2b 7d ec             	sub    -0x14(%ebp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  800f1a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800f1d:	89 f9                	mov    %edi,%ecx
  800f1f:	d3 ea                	shr    %cl,%edx
  800f21:	09 c2                	or     %eax,%edx
  800f23:	89 55 f0             	mov    %edx,-0x10(%ebp)
	      d0 = d0 << bm;
  800f26:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800f29:	8a 4d ec             	mov    -0x14(%ebp),%cl
  800f2c:	d3 e0                	shl    %cl,%eax
  800f2e:	89 45 f4             	mov    %eax,-0xc(%ebp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  800f31:	89 f2                	mov    %esi,%edx
  800f33:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  800f35:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800f38:	d3 e0                	shl    %cl,%eax
  800f3a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  800f3d:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800f40:	89 f9                	mov    %edi,%ecx
  800f42:	d3 e8                	shr    %cl,%eax
  800f44:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  800f46:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  800f48:	89 f2                	mov    %esi,%edx
  800f4a:	f7 75 f0             	divl   -0x10(%ebp)
  800f4d:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  800f4f:	f7 65 f4             	mull   -0xc(%ebp)
  800f52:	89 55 e8             	mov    %edx,-0x18(%ebp)
  800f55:	89 c1                	mov    %eax,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800f57:	39 d6                	cmp    %edx,%esi
  800f59:	72 71                	jb     800fcc <__umoddi3+0x110>
  800f5b:	74 7f                	je     800fdc <__umoddi3+0x120>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  800f5d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800f60:	29 c8                	sub    %ecx,%eax
  800f62:	19 d6                	sbb    %edx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  800f64:	8a 4d ec             	mov    -0x14(%ebp),%cl
  800f67:	d3 e8                	shr    %cl,%eax
  800f69:	89 f2                	mov    %esi,%edx
  800f6b:	89 f9                	mov    %edi,%ecx
  800f6d:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  800f6f:	09 d0                	or     %edx,%eax
  800f71:	89 f2                	mov    %esi,%edx
  800f73:	8a 4d ec             	mov    -0x14(%ebp),%cl
  800f76:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800f78:	83 c4 20             	add    $0x20,%esp
  800f7b:	5e                   	pop    %esi
  800f7c:	5f                   	pop    %edi
  800f7d:	c9                   	leave  
  800f7e:	c3                   	ret    
  800f7f:	90                   	nop
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  800f80:	85 c9                	test   %ecx,%ecx
  800f82:	75 0b                	jne    800f8f <__umoddi3+0xd3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  800f84:	b8 01 00 00 00       	mov    $0x1,%eax
  800f89:	31 d2                	xor    %edx,%edx
  800f8b:	f7 f1                	div    %ecx
  800f8d:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  800f8f:	89 f0                	mov    %esi,%eax
  800f91:	31 d2                	xor    %edx,%edx
  800f93:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800f95:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800f98:	f7 f1                	div    %ecx
  800f9a:	e9 4a ff ff ff       	jmp    800ee9 <__umoddi3+0x2d>
  800f9f:	90                   	nop
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  800fa0:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800fa2:	83 c4 20             	add    $0x20,%esp
  800fa5:	5e                   	pop    %esi
  800fa6:	5f                   	pop    %edi
  800fa7:	c9                   	leave  
  800fa8:	c3                   	ret    
  800fa9:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800fac:	39 f7                	cmp    %esi,%edi
  800fae:	72 05                	jb     800fb5 <__umoddi3+0xf9>
  800fb0:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
  800fb3:	77 0c                	ja     800fc1 <__umoddi3+0x105>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  800fb5:	89 f2                	mov    %esi,%edx
  800fb7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800fba:	29 c8                	sub    %ecx,%eax
  800fbc:	19 fa                	sbb    %edi,%edx
  800fbe:	89 45 f0             	mov    %eax,-0x10(%ebp)

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  800fc1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800fc4:	83 c4 20             	add    $0x20,%esp
  800fc7:	5e                   	pop    %esi
  800fc8:	5f                   	pop    %edi
  800fc9:	c9                   	leave  
  800fca:	c3                   	ret    
  800fcb:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  800fcc:	8b 55 e8             	mov    -0x18(%ebp),%edx
  800fcf:	89 c1                	mov    %eax,%ecx
  800fd1:	2b 4d f4             	sub    -0xc(%ebp),%ecx
  800fd4:	1b 55 f0             	sbb    -0x10(%ebp),%edx
  800fd7:	eb 84                	jmp    800f5d <__umoddi3+0xa1>
  800fd9:	8d 76 00             	lea    0x0(%esi),%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800fdc:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  800fdf:	72 eb                	jb     800fcc <__umoddi3+0x110>
  800fe1:	89 f2                	mov    %esi,%edx
  800fe3:	e9 75 ff ff ff       	jmp    800f5d <__umoddi3+0xa1>
