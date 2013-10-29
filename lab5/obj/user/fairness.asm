
obj/user/fairness.debug:     file format elf32-i386


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
  80003c:	e8 4c 0b 00 00       	call   800b8d <sys_getenvid>
  800041:	89 c3                	mov    %eax,%ebx

	if (thisenv == &envs[1]) {
  800043:	81 3d 04 40 80 00 7c 	cmpl   $0xeec0007c,0x804004
  80004a:	00 c0 ee 
  80004d:	75 26                	jne    800075 <umain+0x41>
		while (1) {
			ipc_recv(&who, 0, 0);
  80004f:	8d 75 f4             	lea    -0xc(%ebp),%esi
  800052:	83 ec 04             	sub    $0x4,%esp
  800055:	6a 00                	push   $0x0
  800057:	6a 00                	push   $0x0
  800059:	56                   	push   %esi
  80005a:	e8 b9 0c 00 00       	call   800d18 <ipc_recv>
			cprintf("%x recv from %x\n", id, who);
  80005f:	83 c4 0c             	add    $0xc,%esp
  800062:	ff 75 f4             	pushl  -0xc(%ebp)
  800065:	53                   	push   %ebx
  800066:	68 20 1e 80 00       	push   $0x801e20
  80006b:	e8 30 01 00 00       	call   8001a0 <cprintf>
  800070:	83 c4 10             	add    $0x10,%esp
  800073:	eb dd                	jmp    800052 <umain+0x1e>
		}
	} else {
		cprintf("%x loop sending to %x\n", id, envs[1].env_id);
  800075:	83 ec 04             	sub    $0x4,%esp
  800078:	ff 35 c4 00 c0 ee    	pushl  0xeec000c4
  80007e:	50                   	push   %eax
  80007f:	68 31 1e 80 00       	push   $0x801e31
  800084:	e8 17 01 00 00       	call   8001a0 <cprintf>
  800089:	83 c4 10             	add    $0x10,%esp
		while (1)
			ipc_send(envs[1].env_id, 0, 0, 0);
  80008c:	6a 00                	push   $0x0
  80008e:	6a 00                	push   $0x0
  800090:	6a 00                	push   $0x0
  800092:	ff 35 c4 00 c0 ee    	pushl  0xeec000c4
  800098:	e8 23 0d 00 00       	call   800dc0 <ipc_send>
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
  8000af:	e8 d9 0a 00 00       	call   800b8d <sys_getenvid>
  8000b4:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000b9:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  8000c0:	c1 e0 07             	shl    $0x7,%eax
  8000c3:	29 d0                	sub    %edx,%eax
  8000c5:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000ca:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000cf:	85 f6                	test   %esi,%esi
  8000d1:	7e 07                	jle    8000da <libmain+0x36>
		binaryname = argv[0];
  8000d3:	8b 03                	mov    (%ebx),%eax
  8000d5:	a3 00 30 80 00       	mov    %eax,0x803000
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
  8000f7:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8000fa:	e8 7b 0f 00 00       	call   80107a <close_all>
	sys_env_destroy(0);
  8000ff:	83 ec 0c             	sub    $0xc,%esp
  800102:	6a 00                	push   $0x0
  800104:	e8 62 0a 00 00       	call   800b6b <sys_env_destroy>
  800109:	83 c4 10             	add    $0x10,%esp
}
  80010c:	c9                   	leave  
  80010d:	c3                   	ret    
	...

00800110 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800110:	55                   	push   %ebp
  800111:	89 e5                	mov    %esp,%ebp
  800113:	53                   	push   %ebx
  800114:	83 ec 04             	sub    $0x4,%esp
  800117:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80011a:	8b 03                	mov    (%ebx),%eax
  80011c:	8b 55 08             	mov    0x8(%ebp),%edx
  80011f:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  800123:	40                   	inc    %eax
  800124:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  800126:	3d ff 00 00 00       	cmp    $0xff,%eax
  80012b:	75 1a                	jne    800147 <putch+0x37>
		sys_cputs(b->buf, b->idx);
  80012d:	83 ec 08             	sub    $0x8,%esp
  800130:	68 ff 00 00 00       	push   $0xff
  800135:	8d 43 08             	lea    0x8(%ebx),%eax
  800138:	50                   	push   %eax
  800139:	e8 e3 09 00 00       	call   800b21 <sys_cputs>
		b->idx = 0;
  80013e:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800144:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800147:	ff 43 04             	incl   0x4(%ebx)
}
  80014a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80014d:	c9                   	leave  
  80014e:	c3                   	ret    

0080014f <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80014f:	55                   	push   %ebp
  800150:	89 e5                	mov    %esp,%ebp
  800152:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800158:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80015f:	00 00 00 
	b.cnt = 0;
  800162:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800169:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80016c:	ff 75 0c             	pushl  0xc(%ebp)
  80016f:	ff 75 08             	pushl  0x8(%ebp)
  800172:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800178:	50                   	push   %eax
  800179:	68 10 01 80 00       	push   $0x800110
  80017e:	e8 82 01 00 00       	call   800305 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800183:	83 c4 08             	add    $0x8,%esp
  800186:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80018c:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800192:	50                   	push   %eax
  800193:	e8 89 09 00 00       	call   800b21 <sys_cputs>

	return b.cnt;
}
  800198:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80019e:	c9                   	leave  
  80019f:	c3                   	ret    

008001a0 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001a0:	55                   	push   %ebp
  8001a1:	89 e5                	mov    %esp,%ebp
  8001a3:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001a6:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001a9:	50                   	push   %eax
  8001aa:	ff 75 08             	pushl  0x8(%ebp)
  8001ad:	e8 9d ff ff ff       	call   80014f <vcprintf>
	va_end(ap);

	return cnt;
}
  8001b2:	c9                   	leave  
  8001b3:	c3                   	ret    

008001b4 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001b4:	55                   	push   %ebp
  8001b5:	89 e5                	mov    %esp,%ebp
  8001b7:	57                   	push   %edi
  8001b8:	56                   	push   %esi
  8001b9:	53                   	push   %ebx
  8001ba:	83 ec 2c             	sub    $0x2c,%esp
  8001bd:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8001c0:	89 d6                	mov    %edx,%esi
  8001c2:	8b 45 08             	mov    0x8(%ebp),%eax
  8001c5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001c8:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001cb:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8001ce:	8b 45 10             	mov    0x10(%ebp),%eax
  8001d1:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8001d4:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001d7:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8001da:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  8001e1:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
  8001e4:	72 0c                	jb     8001f2 <printnum+0x3e>
  8001e6:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  8001e9:	76 07                	jbe    8001f2 <printnum+0x3e>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8001eb:	4b                   	dec    %ebx
  8001ec:	85 db                	test   %ebx,%ebx
  8001ee:	7f 31                	jg     800221 <printnum+0x6d>
  8001f0:	eb 3f                	jmp    800231 <printnum+0x7d>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001f2:	83 ec 0c             	sub    $0xc,%esp
  8001f5:	57                   	push   %edi
  8001f6:	4b                   	dec    %ebx
  8001f7:	53                   	push   %ebx
  8001f8:	50                   	push   %eax
  8001f9:	83 ec 08             	sub    $0x8,%esp
  8001fc:	ff 75 d4             	pushl  -0x2c(%ebp)
  8001ff:	ff 75 d0             	pushl  -0x30(%ebp)
  800202:	ff 75 dc             	pushl  -0x24(%ebp)
  800205:	ff 75 d8             	pushl  -0x28(%ebp)
  800208:	e8 c3 19 00 00       	call   801bd0 <__udivdi3>
  80020d:	83 c4 18             	add    $0x18,%esp
  800210:	52                   	push   %edx
  800211:	50                   	push   %eax
  800212:	89 f2                	mov    %esi,%edx
  800214:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800217:	e8 98 ff ff ff       	call   8001b4 <printnum>
  80021c:	83 c4 20             	add    $0x20,%esp
  80021f:	eb 10                	jmp    800231 <printnum+0x7d>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800221:	83 ec 08             	sub    $0x8,%esp
  800224:	56                   	push   %esi
  800225:	57                   	push   %edi
  800226:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800229:	4b                   	dec    %ebx
  80022a:	83 c4 10             	add    $0x10,%esp
  80022d:	85 db                	test   %ebx,%ebx
  80022f:	7f f0                	jg     800221 <printnum+0x6d>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800231:	83 ec 08             	sub    $0x8,%esp
  800234:	56                   	push   %esi
  800235:	83 ec 04             	sub    $0x4,%esp
  800238:	ff 75 d4             	pushl  -0x2c(%ebp)
  80023b:	ff 75 d0             	pushl  -0x30(%ebp)
  80023e:	ff 75 dc             	pushl  -0x24(%ebp)
  800241:	ff 75 d8             	pushl  -0x28(%ebp)
  800244:	e8 a3 1a 00 00       	call   801cec <__umoddi3>
  800249:	83 c4 14             	add    $0x14,%esp
  80024c:	0f be 80 52 1e 80 00 	movsbl 0x801e52(%eax),%eax
  800253:	50                   	push   %eax
  800254:	ff 55 e4             	call   *-0x1c(%ebp)
  800257:	83 c4 10             	add    $0x10,%esp
}
  80025a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80025d:	5b                   	pop    %ebx
  80025e:	5e                   	pop    %esi
  80025f:	5f                   	pop    %edi
  800260:	c9                   	leave  
  800261:	c3                   	ret    

00800262 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800262:	55                   	push   %ebp
  800263:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800265:	83 fa 01             	cmp    $0x1,%edx
  800268:	7e 0e                	jle    800278 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80026a:	8b 10                	mov    (%eax),%edx
  80026c:	8d 4a 08             	lea    0x8(%edx),%ecx
  80026f:	89 08                	mov    %ecx,(%eax)
  800271:	8b 02                	mov    (%edx),%eax
  800273:	8b 52 04             	mov    0x4(%edx),%edx
  800276:	eb 22                	jmp    80029a <getuint+0x38>
	else if (lflag)
  800278:	85 d2                	test   %edx,%edx
  80027a:	74 10                	je     80028c <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80027c:	8b 10                	mov    (%eax),%edx
  80027e:	8d 4a 04             	lea    0x4(%edx),%ecx
  800281:	89 08                	mov    %ecx,(%eax)
  800283:	8b 02                	mov    (%edx),%eax
  800285:	ba 00 00 00 00       	mov    $0x0,%edx
  80028a:	eb 0e                	jmp    80029a <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80028c:	8b 10                	mov    (%eax),%edx
  80028e:	8d 4a 04             	lea    0x4(%edx),%ecx
  800291:	89 08                	mov    %ecx,(%eax)
  800293:	8b 02                	mov    (%edx),%eax
  800295:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80029a:	c9                   	leave  
  80029b:	c3                   	ret    

0080029c <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  80029c:	55                   	push   %ebp
  80029d:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80029f:	83 fa 01             	cmp    $0x1,%edx
  8002a2:	7e 0e                	jle    8002b2 <getint+0x16>
		return va_arg(*ap, long long);
  8002a4:	8b 10                	mov    (%eax),%edx
  8002a6:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002a9:	89 08                	mov    %ecx,(%eax)
  8002ab:	8b 02                	mov    (%edx),%eax
  8002ad:	8b 52 04             	mov    0x4(%edx),%edx
  8002b0:	eb 1a                	jmp    8002cc <getint+0x30>
	else if (lflag)
  8002b2:	85 d2                	test   %edx,%edx
  8002b4:	74 0c                	je     8002c2 <getint+0x26>
		return va_arg(*ap, long);
  8002b6:	8b 10                	mov    (%eax),%edx
  8002b8:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002bb:	89 08                	mov    %ecx,(%eax)
  8002bd:	8b 02                	mov    (%edx),%eax
  8002bf:	99                   	cltd   
  8002c0:	eb 0a                	jmp    8002cc <getint+0x30>
	else
		return va_arg(*ap, int);
  8002c2:	8b 10                	mov    (%eax),%edx
  8002c4:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002c7:	89 08                	mov    %ecx,(%eax)
  8002c9:	8b 02                	mov    (%edx),%eax
  8002cb:	99                   	cltd   
}
  8002cc:	c9                   	leave  
  8002cd:	c3                   	ret    

008002ce <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002ce:	55                   	push   %ebp
  8002cf:	89 e5                	mov    %esp,%ebp
  8002d1:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002d4:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  8002d7:	8b 10                	mov    (%eax),%edx
  8002d9:	3b 50 04             	cmp    0x4(%eax),%edx
  8002dc:	73 08                	jae    8002e6 <sprintputch+0x18>
		*b->buf++ = ch;
  8002de:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8002e1:	88 0a                	mov    %cl,(%edx)
  8002e3:	42                   	inc    %edx
  8002e4:	89 10                	mov    %edx,(%eax)
}
  8002e6:	c9                   	leave  
  8002e7:	c3                   	ret    

008002e8 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8002e8:	55                   	push   %ebp
  8002e9:	89 e5                	mov    %esp,%ebp
  8002eb:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8002ee:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002f1:	50                   	push   %eax
  8002f2:	ff 75 10             	pushl  0x10(%ebp)
  8002f5:	ff 75 0c             	pushl  0xc(%ebp)
  8002f8:	ff 75 08             	pushl  0x8(%ebp)
  8002fb:	e8 05 00 00 00       	call   800305 <vprintfmt>
	va_end(ap);
  800300:	83 c4 10             	add    $0x10,%esp
}
  800303:	c9                   	leave  
  800304:	c3                   	ret    

00800305 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800305:	55                   	push   %ebp
  800306:	89 e5                	mov    %esp,%ebp
  800308:	57                   	push   %edi
  800309:	56                   	push   %esi
  80030a:	53                   	push   %ebx
  80030b:	83 ec 2c             	sub    $0x2c,%esp
  80030e:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800311:	8b 75 10             	mov    0x10(%ebp),%esi
  800314:	eb 13                	jmp    800329 <vprintfmt+0x24>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800316:	85 c0                	test   %eax,%eax
  800318:	0f 84 6d 03 00 00    	je     80068b <vprintfmt+0x386>
				return;
			putch(ch, putdat);
  80031e:	83 ec 08             	sub    $0x8,%esp
  800321:	57                   	push   %edi
  800322:	50                   	push   %eax
  800323:	ff 55 08             	call   *0x8(%ebp)
  800326:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800329:	0f b6 06             	movzbl (%esi),%eax
  80032c:	46                   	inc    %esi
  80032d:	83 f8 25             	cmp    $0x25,%eax
  800330:	75 e4                	jne    800316 <vprintfmt+0x11>
  800332:	c6 45 dc 20          	movb   $0x20,-0x24(%ebp)
  800336:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  80033d:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  800344:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  80034b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800350:	eb 28                	jmp    80037a <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800352:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800354:	c6 45 dc 2d          	movb   $0x2d,-0x24(%ebp)
  800358:	eb 20                	jmp    80037a <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80035a:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80035c:	c6 45 dc 30          	movb   $0x30,-0x24(%ebp)
  800360:	eb 18                	jmp    80037a <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800362:	89 de                	mov    %ebx,%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800364:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  80036b:	eb 0d                	jmp    80037a <vprintfmt+0x75>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  80036d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800370:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800373:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80037a:	8a 06                	mov    (%esi),%al
  80037c:	0f b6 d0             	movzbl %al,%edx
  80037f:	8d 5e 01             	lea    0x1(%esi),%ebx
  800382:	83 e8 23             	sub    $0x23,%eax
  800385:	3c 55                	cmp    $0x55,%al
  800387:	0f 87 e0 02 00 00    	ja     80066d <vprintfmt+0x368>
  80038d:	0f b6 c0             	movzbl %al,%eax
  800390:	ff 24 85 a0 1f 80 00 	jmp    *0x801fa0(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800397:	83 ea 30             	sub    $0x30,%edx
  80039a:	89 55 d4             	mov    %edx,-0x2c(%ebp)
				ch = *fmt;
  80039d:	0f be 03             	movsbl (%ebx),%eax
				if (ch < '0' || ch > '9')
  8003a0:	8d 50 d0             	lea    -0x30(%eax),%edx
  8003a3:	83 fa 09             	cmp    $0x9,%edx
  8003a6:	77 44                	ja     8003ec <vprintfmt+0xe7>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003a8:	89 de                	mov    %ebx,%esi
  8003aa:	8b 55 d4             	mov    -0x2c(%ebp),%edx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003ad:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
  8003ae:	8d 14 92             	lea    (%edx,%edx,4),%edx
  8003b1:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
  8003b5:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8003b8:	8d 58 d0             	lea    -0x30(%eax),%ebx
  8003bb:	83 fb 09             	cmp    $0x9,%ebx
  8003be:	76 ed                	jbe    8003ad <vprintfmt+0xa8>
  8003c0:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  8003c3:	eb 29                	jmp    8003ee <vprintfmt+0xe9>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003c5:	8b 45 14             	mov    0x14(%ebp),%eax
  8003c8:	8d 50 04             	lea    0x4(%eax),%edx
  8003cb:	89 55 14             	mov    %edx,0x14(%ebp)
  8003ce:	8b 00                	mov    (%eax),%eax
  8003d0:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003d3:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8003d5:	eb 17                	jmp    8003ee <vprintfmt+0xe9>

		case '.':
			if (width < 0)
  8003d7:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8003db:	78 85                	js     800362 <vprintfmt+0x5d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003dd:	89 de                	mov    %ebx,%esi
  8003df:	eb 99                	jmp    80037a <vprintfmt+0x75>
  8003e1:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8003e3:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  8003ea:	eb 8e                	jmp    80037a <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ec:	89 de                	mov    %ebx,%esi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  8003ee:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8003f2:	79 86                	jns    80037a <vprintfmt+0x75>
  8003f4:	e9 74 ff ff ff       	jmp    80036d <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8003f9:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003fa:	89 de                	mov    %ebx,%esi
  8003fc:	e9 79 ff ff ff       	jmp    80037a <vprintfmt+0x75>
  800401:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800404:	8b 45 14             	mov    0x14(%ebp),%eax
  800407:	8d 50 04             	lea    0x4(%eax),%edx
  80040a:	89 55 14             	mov    %edx,0x14(%ebp)
  80040d:	83 ec 08             	sub    $0x8,%esp
  800410:	57                   	push   %edi
  800411:	ff 30                	pushl  (%eax)
  800413:	ff 55 08             	call   *0x8(%ebp)
			break;
  800416:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800419:	8b 75 d8             	mov    -0x28(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80041c:	e9 08 ff ff ff       	jmp    800329 <vprintfmt+0x24>
  800421:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  800424:	8b 45 14             	mov    0x14(%ebp),%eax
  800427:	8d 50 04             	lea    0x4(%eax),%edx
  80042a:	89 55 14             	mov    %edx,0x14(%ebp)
  80042d:	8b 00                	mov    (%eax),%eax
  80042f:	85 c0                	test   %eax,%eax
  800431:	79 02                	jns    800435 <vprintfmt+0x130>
  800433:	f7 d8                	neg    %eax
  800435:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800437:	83 f8 0f             	cmp    $0xf,%eax
  80043a:	7f 0b                	jg     800447 <vprintfmt+0x142>
  80043c:	8b 04 85 00 21 80 00 	mov    0x802100(,%eax,4),%eax
  800443:	85 c0                	test   %eax,%eax
  800445:	75 1a                	jne    800461 <vprintfmt+0x15c>
				printfmt(putch, putdat, "error %d", err);
  800447:	52                   	push   %edx
  800448:	68 6a 1e 80 00       	push   $0x801e6a
  80044d:	57                   	push   %edi
  80044e:	ff 75 08             	pushl  0x8(%ebp)
  800451:	e8 92 fe ff ff       	call   8002e8 <printfmt>
  800456:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800459:	8b 75 d8             	mov    -0x28(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80045c:	e9 c8 fe ff ff       	jmp    800329 <vprintfmt+0x24>
			else
				printfmt(putch, putdat, "%s", p);
  800461:	50                   	push   %eax
  800462:	68 69 22 80 00       	push   $0x802269
  800467:	57                   	push   %edi
  800468:	ff 75 08             	pushl  0x8(%ebp)
  80046b:	e8 78 fe ff ff       	call   8002e8 <printfmt>
  800470:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800473:	8b 75 d8             	mov    -0x28(%ebp),%esi
  800476:	e9 ae fe ff ff       	jmp    800329 <vprintfmt+0x24>
  80047b:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  80047e:	89 de                	mov    %ebx,%esi
  800480:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  800483:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800486:	8b 45 14             	mov    0x14(%ebp),%eax
  800489:	8d 50 04             	lea    0x4(%eax),%edx
  80048c:	89 55 14             	mov    %edx,0x14(%ebp)
  80048f:	8b 00                	mov    (%eax),%eax
  800491:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800494:	85 c0                	test   %eax,%eax
  800496:	75 07                	jne    80049f <vprintfmt+0x19a>
				p = "(null)";
  800498:	c7 45 d0 63 1e 80 00 	movl   $0x801e63,-0x30(%ebp)
			if (width > 0 && padc != '-')
  80049f:	85 db                	test   %ebx,%ebx
  8004a1:	7e 42                	jle    8004e5 <vprintfmt+0x1e0>
  8004a3:	80 7d dc 2d          	cmpb   $0x2d,-0x24(%ebp)
  8004a7:	74 3c                	je     8004e5 <vprintfmt+0x1e0>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004a9:	83 ec 08             	sub    $0x8,%esp
  8004ac:	51                   	push   %ecx
  8004ad:	ff 75 d0             	pushl  -0x30(%ebp)
  8004b0:	e8 6f 02 00 00       	call   800724 <strnlen>
  8004b5:	29 c3                	sub    %eax,%ebx
  8004b7:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8004ba:	83 c4 10             	add    $0x10,%esp
  8004bd:	85 db                	test   %ebx,%ebx
  8004bf:	7e 24                	jle    8004e5 <vprintfmt+0x1e0>
					putch(padc, putdat);
  8004c1:	0f be 5d dc          	movsbl -0x24(%ebp),%ebx
  8004c5:	89 75 dc             	mov    %esi,-0x24(%ebp)
  8004c8:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  8004cb:	83 ec 08             	sub    $0x8,%esp
  8004ce:	57                   	push   %edi
  8004cf:	53                   	push   %ebx
  8004d0:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004d3:	4e                   	dec    %esi
  8004d4:	83 c4 10             	add    $0x10,%esp
  8004d7:	85 f6                	test   %esi,%esi
  8004d9:	7f f0                	jg     8004cb <vprintfmt+0x1c6>
  8004db:	8b 75 dc             	mov    -0x24(%ebp),%esi
  8004de:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004e5:	8b 55 d0             	mov    -0x30(%ebp),%edx
  8004e8:	0f be 02             	movsbl (%edx),%eax
  8004eb:	85 c0                	test   %eax,%eax
  8004ed:	75 47                	jne    800536 <vprintfmt+0x231>
  8004ef:	eb 37                	jmp    800528 <vprintfmt+0x223>
				if (altflag && (ch < ' ' || ch > '~'))
  8004f1:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004f5:	74 16                	je     80050d <vprintfmt+0x208>
  8004f7:	8d 50 e0             	lea    -0x20(%eax),%edx
  8004fa:	83 fa 5e             	cmp    $0x5e,%edx
  8004fd:	76 0e                	jbe    80050d <vprintfmt+0x208>
					putch('?', putdat);
  8004ff:	83 ec 08             	sub    $0x8,%esp
  800502:	57                   	push   %edi
  800503:	6a 3f                	push   $0x3f
  800505:	ff 55 08             	call   *0x8(%ebp)
  800508:	83 c4 10             	add    $0x10,%esp
  80050b:	eb 0b                	jmp    800518 <vprintfmt+0x213>
				else
					putch(ch, putdat);
  80050d:	83 ec 08             	sub    $0x8,%esp
  800510:	57                   	push   %edi
  800511:	50                   	push   %eax
  800512:	ff 55 08             	call   *0x8(%ebp)
  800515:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800518:	ff 4d e4             	decl   -0x1c(%ebp)
  80051b:	0f be 03             	movsbl (%ebx),%eax
  80051e:	85 c0                	test   %eax,%eax
  800520:	74 03                	je     800525 <vprintfmt+0x220>
  800522:	43                   	inc    %ebx
  800523:	eb 1b                	jmp    800540 <vprintfmt+0x23b>
  800525:	8b 75 dc             	mov    -0x24(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800528:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80052c:	7f 1e                	jg     80054c <vprintfmt+0x247>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80052e:	8b 75 d8             	mov    -0x28(%ebp),%esi
  800531:	e9 f3 fd ff ff       	jmp    800329 <vprintfmt+0x24>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800536:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800539:	43                   	inc    %ebx
  80053a:	89 75 dc             	mov    %esi,-0x24(%ebp)
  80053d:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  800540:	85 f6                	test   %esi,%esi
  800542:	78 ad                	js     8004f1 <vprintfmt+0x1ec>
  800544:	4e                   	dec    %esi
  800545:	79 aa                	jns    8004f1 <vprintfmt+0x1ec>
  800547:	8b 75 dc             	mov    -0x24(%ebp),%esi
  80054a:	eb dc                	jmp    800528 <vprintfmt+0x223>
  80054c:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80054f:	83 ec 08             	sub    $0x8,%esp
  800552:	57                   	push   %edi
  800553:	6a 20                	push   $0x20
  800555:	ff 55 08             	call   *0x8(%ebp)
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800558:	4b                   	dec    %ebx
  800559:	83 c4 10             	add    $0x10,%esp
  80055c:	85 db                	test   %ebx,%ebx
  80055e:	7f ef                	jg     80054f <vprintfmt+0x24a>
  800560:	e9 c4 fd ff ff       	jmp    800329 <vprintfmt+0x24>
  800565:	89 5d d8             	mov    %ebx,-0x28(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800568:	89 ca                	mov    %ecx,%edx
  80056a:	8d 45 14             	lea    0x14(%ebp),%eax
  80056d:	e8 2a fd ff ff       	call   80029c <getint>
  800572:	89 c3                	mov    %eax,%ebx
  800574:	89 d6                	mov    %edx,%esi
			if ((long long) num < 0) {
  800576:	85 d2                	test   %edx,%edx
  800578:	78 0a                	js     800584 <vprintfmt+0x27f>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80057a:	b8 0a 00 00 00       	mov    $0xa,%eax
  80057f:	e9 b0 00 00 00       	jmp    800634 <vprintfmt+0x32f>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  800584:	83 ec 08             	sub    $0x8,%esp
  800587:	57                   	push   %edi
  800588:	6a 2d                	push   $0x2d
  80058a:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  80058d:	f7 db                	neg    %ebx
  80058f:	83 d6 00             	adc    $0x0,%esi
  800592:	f7 de                	neg    %esi
  800594:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800597:	b8 0a 00 00 00       	mov    $0xa,%eax
  80059c:	e9 93 00 00 00       	jmp    800634 <vprintfmt+0x32f>
  8005a1:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8005a4:	89 ca                	mov    %ecx,%edx
  8005a6:	8d 45 14             	lea    0x14(%ebp),%eax
  8005a9:	e8 b4 fc ff ff       	call   800262 <getuint>
  8005ae:	89 c3                	mov    %eax,%ebx
  8005b0:	89 d6                	mov    %edx,%esi
			base = 10;
  8005b2:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  8005b7:	eb 7b                	jmp    800634 <vprintfmt+0x32f>
  8005b9:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
  8005bc:	89 ca                	mov    %ecx,%edx
  8005be:	8d 45 14             	lea    0x14(%ebp),%eax
  8005c1:	e8 d6 fc ff ff       	call   80029c <getint>
  8005c6:	89 c3                	mov    %eax,%ebx
  8005c8:	89 d6                	mov    %edx,%esi
            if ((long long) num < 0) {
  8005ca:	85 d2                	test   %edx,%edx
  8005cc:	78 07                	js     8005d5 <vprintfmt+0x2d0>
                putch('-', putdat);
                num = -(long long) num;
            }
            base = 8;
  8005ce:	b8 08 00 00 00       	mov    $0x8,%eax
  8005d3:	eb 5f                	jmp    800634 <vprintfmt+0x32f>
		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
            if ((long long) num < 0) {
                putch('-', putdat);
  8005d5:	83 ec 08             	sub    $0x8,%esp
  8005d8:	57                   	push   %edi
  8005d9:	6a 2d                	push   $0x2d
  8005db:	ff 55 08             	call   *0x8(%ebp)
                num = -(long long) num;
  8005de:	f7 db                	neg    %ebx
  8005e0:	83 d6 00             	adc    $0x0,%esi
  8005e3:	f7 de                	neg    %esi
  8005e5:	83 c4 10             	add    $0x10,%esp
            }
            base = 8;
  8005e8:	b8 08 00 00 00       	mov    $0x8,%eax
  8005ed:	eb 45                	jmp    800634 <vprintfmt+0x32f>
  8005ef:	89 5d d8             	mov    %ebx,-0x28(%ebp)
            goto number;

        // pointer
		case 'p':
			putch('0', putdat);
  8005f2:	83 ec 08             	sub    $0x8,%esp
  8005f5:	57                   	push   %edi
  8005f6:	6a 30                	push   $0x30
  8005f8:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8005fb:	83 c4 08             	add    $0x8,%esp
  8005fe:	57                   	push   %edi
  8005ff:	6a 78                	push   $0x78
  800601:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800604:	8b 45 14             	mov    0x14(%ebp),%eax
  800607:	8d 50 04             	lea    0x4(%eax),%edx
  80060a:	89 55 14             	mov    %edx,0x14(%ebp)

        // pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80060d:	8b 18                	mov    (%eax),%ebx
  80060f:	be 00 00 00 00       	mov    $0x0,%esi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800614:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800617:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  80061c:	eb 16                	jmp    800634 <vprintfmt+0x32f>
  80061e:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800621:	89 ca                	mov    %ecx,%edx
  800623:	8d 45 14             	lea    0x14(%ebp),%eax
  800626:	e8 37 fc ff ff       	call   800262 <getuint>
  80062b:	89 c3                	mov    %eax,%ebx
  80062d:	89 d6                	mov    %edx,%esi
			base = 16;
  80062f:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800634:	83 ec 0c             	sub    $0xc,%esp
  800637:	0f be 55 dc          	movsbl -0x24(%ebp),%edx
  80063b:	52                   	push   %edx
  80063c:	ff 75 e4             	pushl  -0x1c(%ebp)
  80063f:	50                   	push   %eax
  800640:	56                   	push   %esi
  800641:	53                   	push   %ebx
  800642:	89 fa                	mov    %edi,%edx
  800644:	8b 45 08             	mov    0x8(%ebp),%eax
  800647:	e8 68 fb ff ff       	call   8001b4 <printnum>
			break;
  80064c:	83 c4 20             	add    $0x20,%esp
  80064f:	8b 75 d8             	mov    -0x28(%ebp),%esi
  800652:	e9 d2 fc ff ff       	jmp    800329 <vprintfmt+0x24>
  800657:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80065a:	83 ec 08             	sub    $0x8,%esp
  80065d:	57                   	push   %edi
  80065e:	52                   	push   %edx
  80065f:	ff 55 08             	call   *0x8(%ebp)
			break;
  800662:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800665:	8b 75 d8             	mov    -0x28(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800668:	e9 bc fc ff ff       	jmp    800329 <vprintfmt+0x24>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80066d:	83 ec 08             	sub    $0x8,%esp
  800670:	57                   	push   %edi
  800671:	6a 25                	push   $0x25
  800673:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800676:	83 c4 10             	add    $0x10,%esp
  800679:	eb 02                	jmp    80067d <vprintfmt+0x378>
  80067b:	89 c6                	mov    %eax,%esi
  80067d:	8d 46 ff             	lea    -0x1(%esi),%eax
  800680:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800684:	75 f5                	jne    80067b <vprintfmt+0x376>
  800686:	e9 9e fc ff ff       	jmp    800329 <vprintfmt+0x24>
				/* do nothing */;
			break;
		}
	}
}
  80068b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80068e:	5b                   	pop    %ebx
  80068f:	5e                   	pop    %esi
  800690:	5f                   	pop    %edi
  800691:	c9                   	leave  
  800692:	c3                   	ret    

00800693 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800693:	55                   	push   %ebp
  800694:	89 e5                	mov    %esp,%ebp
  800696:	83 ec 18             	sub    $0x18,%esp
  800699:	8b 45 08             	mov    0x8(%ebp),%eax
  80069c:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80069f:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006a2:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8006a6:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8006a9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8006b0:	85 c0                	test   %eax,%eax
  8006b2:	74 26                	je     8006da <vsnprintf+0x47>
  8006b4:	85 d2                	test   %edx,%edx
  8006b6:	7e 29                	jle    8006e1 <vsnprintf+0x4e>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8006b8:	ff 75 14             	pushl  0x14(%ebp)
  8006bb:	ff 75 10             	pushl  0x10(%ebp)
  8006be:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8006c1:	50                   	push   %eax
  8006c2:	68 ce 02 80 00       	push   $0x8002ce
  8006c7:	e8 39 fc ff ff       	call   800305 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8006cc:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8006cf:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8006d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006d5:	83 c4 10             	add    $0x10,%esp
  8006d8:	eb 0c                	jmp    8006e6 <vsnprintf+0x53>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8006da:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8006df:	eb 05                	jmp    8006e6 <vsnprintf+0x53>
  8006e1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8006e6:	c9                   	leave  
  8006e7:	c3                   	ret    

008006e8 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8006e8:	55                   	push   %ebp
  8006e9:	89 e5                	mov    %esp,%ebp
  8006eb:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8006ee:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8006f1:	50                   	push   %eax
  8006f2:	ff 75 10             	pushl  0x10(%ebp)
  8006f5:	ff 75 0c             	pushl  0xc(%ebp)
  8006f8:	ff 75 08             	pushl  0x8(%ebp)
  8006fb:	e8 93 ff ff ff       	call   800693 <vsnprintf>
	va_end(ap);

	return rc;
}
  800700:	c9                   	leave  
  800701:	c3                   	ret    
	...

00800704 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800704:	55                   	push   %ebp
  800705:	89 e5                	mov    %esp,%ebp
  800707:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80070a:	80 3a 00             	cmpb   $0x0,(%edx)
  80070d:	74 0e                	je     80071d <strlen+0x19>
  80070f:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800714:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800715:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800719:	75 f9                	jne    800714 <strlen+0x10>
  80071b:	eb 05                	jmp    800722 <strlen+0x1e>
  80071d:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800722:	c9                   	leave  
  800723:	c3                   	ret    

00800724 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800724:	55                   	push   %ebp
  800725:	89 e5                	mov    %esp,%ebp
  800727:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80072a:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80072d:	85 d2                	test   %edx,%edx
  80072f:	74 17                	je     800748 <strnlen+0x24>
  800731:	80 39 00             	cmpb   $0x0,(%ecx)
  800734:	74 19                	je     80074f <strnlen+0x2b>
  800736:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  80073b:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80073c:	39 d0                	cmp    %edx,%eax
  80073e:	74 14                	je     800754 <strnlen+0x30>
  800740:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800744:	75 f5                	jne    80073b <strnlen+0x17>
  800746:	eb 0c                	jmp    800754 <strnlen+0x30>
  800748:	b8 00 00 00 00       	mov    $0x0,%eax
  80074d:	eb 05                	jmp    800754 <strnlen+0x30>
  80074f:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800754:	c9                   	leave  
  800755:	c3                   	ret    

00800756 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800756:	55                   	push   %ebp
  800757:	89 e5                	mov    %esp,%ebp
  800759:	53                   	push   %ebx
  80075a:	8b 45 08             	mov    0x8(%ebp),%eax
  80075d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800760:	ba 00 00 00 00       	mov    $0x0,%edx
  800765:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  800768:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  80076b:	42                   	inc    %edx
  80076c:	84 c9                	test   %cl,%cl
  80076e:	75 f5                	jne    800765 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800770:	5b                   	pop    %ebx
  800771:	c9                   	leave  
  800772:	c3                   	ret    

00800773 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800773:	55                   	push   %ebp
  800774:	89 e5                	mov    %esp,%ebp
  800776:	53                   	push   %ebx
  800777:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80077a:	53                   	push   %ebx
  80077b:	e8 84 ff ff ff       	call   800704 <strlen>
  800780:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800783:	ff 75 0c             	pushl  0xc(%ebp)
  800786:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  800789:	50                   	push   %eax
  80078a:	e8 c7 ff ff ff       	call   800756 <strcpy>
	return dst;
}
  80078f:	89 d8                	mov    %ebx,%eax
  800791:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800794:	c9                   	leave  
  800795:	c3                   	ret    

00800796 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800796:	55                   	push   %ebp
  800797:	89 e5                	mov    %esp,%ebp
  800799:	56                   	push   %esi
  80079a:	53                   	push   %ebx
  80079b:	8b 45 08             	mov    0x8(%ebp),%eax
  80079e:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007a1:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007a4:	85 f6                	test   %esi,%esi
  8007a6:	74 15                	je     8007bd <strncpy+0x27>
  8007a8:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  8007ad:	8a 1a                	mov    (%edx),%bl
  8007af:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007b2:	80 3a 01             	cmpb   $0x1,(%edx)
  8007b5:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007b8:	41                   	inc    %ecx
  8007b9:	39 ce                	cmp    %ecx,%esi
  8007bb:	77 f0                	ja     8007ad <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8007bd:	5b                   	pop    %ebx
  8007be:	5e                   	pop    %esi
  8007bf:	c9                   	leave  
  8007c0:	c3                   	ret    

008007c1 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8007c1:	55                   	push   %ebp
  8007c2:	89 e5                	mov    %esp,%ebp
  8007c4:	57                   	push   %edi
  8007c5:	56                   	push   %esi
  8007c6:	53                   	push   %ebx
  8007c7:	8b 7d 08             	mov    0x8(%ebp),%edi
  8007ca:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8007cd:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007d0:	85 f6                	test   %esi,%esi
  8007d2:	74 32                	je     800806 <strlcpy+0x45>
		while (--size > 0 && *src != '\0')
  8007d4:	83 fe 01             	cmp    $0x1,%esi
  8007d7:	74 22                	je     8007fb <strlcpy+0x3a>
  8007d9:	8a 0b                	mov    (%ebx),%cl
  8007db:	84 c9                	test   %cl,%cl
  8007dd:	74 20                	je     8007ff <strlcpy+0x3e>
  8007df:	89 f8                	mov    %edi,%eax
  8007e1:	ba 00 00 00 00       	mov    $0x0,%edx
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
  8007e6:	83 ee 02             	sub    $0x2,%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8007e9:	88 08                	mov    %cl,(%eax)
  8007eb:	40                   	inc    %eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8007ec:	39 f2                	cmp    %esi,%edx
  8007ee:	74 11                	je     800801 <strlcpy+0x40>
  8007f0:	8a 4c 13 01          	mov    0x1(%ebx,%edx,1),%cl
  8007f4:	42                   	inc    %edx
  8007f5:	84 c9                	test   %cl,%cl
  8007f7:	75 f0                	jne    8007e9 <strlcpy+0x28>
  8007f9:	eb 06                	jmp    800801 <strlcpy+0x40>
  8007fb:	89 f8                	mov    %edi,%eax
  8007fd:	eb 02                	jmp    800801 <strlcpy+0x40>
  8007ff:	89 f8                	mov    %edi,%eax
			*dst++ = *src++;
		*dst = '\0';
  800801:	c6 00 00             	movb   $0x0,(%eax)
  800804:	eb 02                	jmp    800808 <strlcpy+0x47>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800806:	89 f8                	mov    %edi,%eax
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
		*dst = '\0';
	}
	return dst - dst_in;
  800808:	29 f8                	sub    %edi,%eax
}
  80080a:	5b                   	pop    %ebx
  80080b:	5e                   	pop    %esi
  80080c:	5f                   	pop    %edi
  80080d:	c9                   	leave  
  80080e:	c3                   	ret    

0080080f <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80080f:	55                   	push   %ebp
  800810:	89 e5                	mov    %esp,%ebp
  800812:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800815:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800818:	8a 01                	mov    (%ecx),%al
  80081a:	84 c0                	test   %al,%al
  80081c:	74 10                	je     80082e <strcmp+0x1f>
  80081e:	3a 02                	cmp    (%edx),%al
  800820:	75 0c                	jne    80082e <strcmp+0x1f>
		p++, q++;
  800822:	41                   	inc    %ecx
  800823:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800824:	8a 01                	mov    (%ecx),%al
  800826:	84 c0                	test   %al,%al
  800828:	74 04                	je     80082e <strcmp+0x1f>
  80082a:	3a 02                	cmp    (%edx),%al
  80082c:	74 f4                	je     800822 <strcmp+0x13>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80082e:	0f b6 c0             	movzbl %al,%eax
  800831:	0f b6 12             	movzbl (%edx),%edx
  800834:	29 d0                	sub    %edx,%eax
}
  800836:	c9                   	leave  
  800837:	c3                   	ret    

00800838 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800838:	55                   	push   %ebp
  800839:	89 e5                	mov    %esp,%ebp
  80083b:	53                   	push   %ebx
  80083c:	8b 55 08             	mov    0x8(%ebp),%edx
  80083f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800842:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  800845:	85 c0                	test   %eax,%eax
  800847:	74 1b                	je     800864 <strncmp+0x2c>
  800849:	8a 1a                	mov    (%edx),%bl
  80084b:	84 db                	test   %bl,%bl
  80084d:	74 24                	je     800873 <strncmp+0x3b>
  80084f:	3a 19                	cmp    (%ecx),%bl
  800851:	75 20                	jne    800873 <strncmp+0x3b>
  800853:	48                   	dec    %eax
  800854:	74 15                	je     80086b <strncmp+0x33>
		n--, p++, q++;
  800856:	42                   	inc    %edx
  800857:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800858:	8a 1a                	mov    (%edx),%bl
  80085a:	84 db                	test   %bl,%bl
  80085c:	74 15                	je     800873 <strncmp+0x3b>
  80085e:	3a 19                	cmp    (%ecx),%bl
  800860:	74 f1                	je     800853 <strncmp+0x1b>
  800862:	eb 0f                	jmp    800873 <strncmp+0x3b>
		n--, p++, q++;
	if (n == 0)
		return 0;
  800864:	b8 00 00 00 00       	mov    $0x0,%eax
  800869:	eb 05                	jmp    800870 <strncmp+0x38>
  80086b:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800870:	5b                   	pop    %ebx
  800871:	c9                   	leave  
  800872:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800873:	0f b6 02             	movzbl (%edx),%eax
  800876:	0f b6 11             	movzbl (%ecx),%edx
  800879:	29 d0                	sub    %edx,%eax
  80087b:	eb f3                	jmp    800870 <strncmp+0x38>

0080087d <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80087d:	55                   	push   %ebp
  80087e:	89 e5                	mov    %esp,%ebp
  800880:	8b 45 08             	mov    0x8(%ebp),%eax
  800883:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800886:	8a 10                	mov    (%eax),%dl
  800888:	84 d2                	test   %dl,%dl
  80088a:	74 18                	je     8008a4 <strchr+0x27>
		if (*s == c)
  80088c:	38 ca                	cmp    %cl,%dl
  80088e:	75 06                	jne    800896 <strchr+0x19>
  800890:	eb 17                	jmp    8008a9 <strchr+0x2c>
  800892:	38 ca                	cmp    %cl,%dl
  800894:	74 13                	je     8008a9 <strchr+0x2c>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800896:	40                   	inc    %eax
  800897:	8a 10                	mov    (%eax),%dl
  800899:	84 d2                	test   %dl,%dl
  80089b:	75 f5                	jne    800892 <strchr+0x15>
		if (*s == c)
			return (char *) s;
	return 0;
  80089d:	b8 00 00 00 00       	mov    $0x0,%eax
  8008a2:	eb 05                	jmp    8008a9 <strchr+0x2c>
  8008a4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008a9:	c9                   	leave  
  8008aa:	c3                   	ret    

008008ab <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008ab:	55                   	push   %ebp
  8008ac:	89 e5                	mov    %esp,%ebp
  8008ae:	8b 45 08             	mov    0x8(%ebp),%eax
  8008b1:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8008b4:	8a 10                	mov    (%eax),%dl
  8008b6:	84 d2                	test   %dl,%dl
  8008b8:	74 11                	je     8008cb <strfind+0x20>
		if (*s == c)
  8008ba:	38 ca                	cmp    %cl,%dl
  8008bc:	75 06                	jne    8008c4 <strfind+0x19>
  8008be:	eb 0b                	jmp    8008cb <strfind+0x20>
  8008c0:	38 ca                	cmp    %cl,%dl
  8008c2:	74 07                	je     8008cb <strfind+0x20>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  8008c4:	40                   	inc    %eax
  8008c5:	8a 10                	mov    (%eax),%dl
  8008c7:	84 d2                	test   %dl,%dl
  8008c9:	75 f5                	jne    8008c0 <strfind+0x15>
		if (*s == c)
			break;
	return (char *) s;
}
  8008cb:	c9                   	leave  
  8008cc:	c3                   	ret    

008008cd <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008cd:	55                   	push   %ebp
  8008ce:	89 e5                	mov    %esp,%ebp
  8008d0:	57                   	push   %edi
  8008d1:	56                   	push   %esi
  8008d2:	53                   	push   %ebx
  8008d3:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008d6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008d9:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8008dc:	85 c9                	test   %ecx,%ecx
  8008de:	74 30                	je     800910 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008e0:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008e6:	75 25                	jne    80090d <memset+0x40>
  8008e8:	f6 c1 03             	test   $0x3,%cl
  8008eb:	75 20                	jne    80090d <memset+0x40>
		c &= 0xFF;
  8008ed:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8008f0:	89 d3                	mov    %edx,%ebx
  8008f2:	c1 e3 08             	shl    $0x8,%ebx
  8008f5:	89 d6                	mov    %edx,%esi
  8008f7:	c1 e6 18             	shl    $0x18,%esi
  8008fa:	89 d0                	mov    %edx,%eax
  8008fc:	c1 e0 10             	shl    $0x10,%eax
  8008ff:	09 f0                	or     %esi,%eax
  800901:	09 d0                	or     %edx,%eax
  800903:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800905:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800908:	fc                   	cld    
  800909:	f3 ab                	rep stos %eax,%es:(%edi)
  80090b:	eb 03                	jmp    800910 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80090d:	fc                   	cld    
  80090e:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800910:	89 f8                	mov    %edi,%eax
  800912:	5b                   	pop    %ebx
  800913:	5e                   	pop    %esi
  800914:	5f                   	pop    %edi
  800915:	c9                   	leave  
  800916:	c3                   	ret    

00800917 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800917:	55                   	push   %ebp
  800918:	89 e5                	mov    %esp,%ebp
  80091a:	57                   	push   %edi
  80091b:	56                   	push   %esi
  80091c:	8b 45 08             	mov    0x8(%ebp),%eax
  80091f:	8b 75 0c             	mov    0xc(%ebp),%esi
  800922:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800925:	39 c6                	cmp    %eax,%esi
  800927:	73 34                	jae    80095d <memmove+0x46>
  800929:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80092c:	39 d0                	cmp    %edx,%eax
  80092e:	73 2d                	jae    80095d <memmove+0x46>
		s += n;
		d += n;
  800930:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800933:	f6 c2 03             	test   $0x3,%dl
  800936:	75 1b                	jne    800953 <memmove+0x3c>
  800938:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80093e:	75 13                	jne    800953 <memmove+0x3c>
  800940:	f6 c1 03             	test   $0x3,%cl
  800943:	75 0e                	jne    800953 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800945:	83 ef 04             	sub    $0x4,%edi
  800948:	8d 72 fc             	lea    -0x4(%edx),%esi
  80094b:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  80094e:	fd                   	std    
  80094f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800951:	eb 07                	jmp    80095a <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800953:	4f                   	dec    %edi
  800954:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800957:	fd                   	std    
  800958:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80095a:	fc                   	cld    
  80095b:	eb 20                	jmp    80097d <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80095d:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800963:	75 13                	jne    800978 <memmove+0x61>
  800965:	a8 03                	test   $0x3,%al
  800967:	75 0f                	jne    800978 <memmove+0x61>
  800969:	f6 c1 03             	test   $0x3,%cl
  80096c:	75 0a                	jne    800978 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  80096e:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800971:	89 c7                	mov    %eax,%edi
  800973:	fc                   	cld    
  800974:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800976:	eb 05                	jmp    80097d <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800978:	89 c7                	mov    %eax,%edi
  80097a:	fc                   	cld    
  80097b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  80097d:	5e                   	pop    %esi
  80097e:	5f                   	pop    %edi
  80097f:	c9                   	leave  
  800980:	c3                   	ret    

00800981 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800981:	55                   	push   %ebp
  800982:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800984:	ff 75 10             	pushl  0x10(%ebp)
  800987:	ff 75 0c             	pushl  0xc(%ebp)
  80098a:	ff 75 08             	pushl  0x8(%ebp)
  80098d:	e8 85 ff ff ff       	call   800917 <memmove>
}
  800992:	c9                   	leave  
  800993:	c3                   	ret    

00800994 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800994:	55                   	push   %ebp
  800995:	89 e5                	mov    %esp,%ebp
  800997:	57                   	push   %edi
  800998:	56                   	push   %esi
  800999:	53                   	push   %ebx
  80099a:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80099d:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009a0:	8b 7d 10             	mov    0x10(%ebp),%edi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009a3:	85 ff                	test   %edi,%edi
  8009a5:	74 32                	je     8009d9 <memcmp+0x45>
		if (*s1 != *s2)
  8009a7:	8a 03                	mov    (%ebx),%al
  8009a9:	8a 0e                	mov    (%esi),%cl
  8009ab:	38 c8                	cmp    %cl,%al
  8009ad:	74 19                	je     8009c8 <memcmp+0x34>
  8009af:	eb 0d                	jmp    8009be <memcmp+0x2a>
  8009b1:	8a 44 13 01          	mov    0x1(%ebx,%edx,1),%al
  8009b5:	8a 4c 16 01          	mov    0x1(%esi,%edx,1),%cl
  8009b9:	42                   	inc    %edx
  8009ba:	38 c8                	cmp    %cl,%al
  8009bc:	74 10                	je     8009ce <memcmp+0x3a>
			return (int) *s1 - (int) *s2;
  8009be:	0f b6 c0             	movzbl %al,%eax
  8009c1:	0f b6 c9             	movzbl %cl,%ecx
  8009c4:	29 c8                	sub    %ecx,%eax
  8009c6:	eb 16                	jmp    8009de <memcmp+0x4a>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009c8:	4f                   	dec    %edi
  8009c9:	ba 00 00 00 00       	mov    $0x0,%edx
  8009ce:	39 fa                	cmp    %edi,%edx
  8009d0:	75 df                	jne    8009b1 <memcmp+0x1d>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8009d2:	b8 00 00 00 00       	mov    $0x0,%eax
  8009d7:	eb 05                	jmp    8009de <memcmp+0x4a>
  8009d9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009de:	5b                   	pop    %ebx
  8009df:	5e                   	pop    %esi
  8009e0:	5f                   	pop    %edi
  8009e1:	c9                   	leave  
  8009e2:	c3                   	ret    

008009e3 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009e3:	55                   	push   %ebp
  8009e4:	89 e5                	mov    %esp,%ebp
  8009e6:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  8009e9:	89 c2                	mov    %eax,%edx
  8009eb:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  8009ee:	39 d0                	cmp    %edx,%eax
  8009f0:	73 12                	jae    800a04 <memfind+0x21>
		if (*(const unsigned char *) s == (unsigned char) c)
  8009f2:	8a 4d 0c             	mov    0xc(%ebp),%cl
  8009f5:	38 08                	cmp    %cl,(%eax)
  8009f7:	75 06                	jne    8009ff <memfind+0x1c>
  8009f9:	eb 09                	jmp    800a04 <memfind+0x21>
  8009fb:	38 08                	cmp    %cl,(%eax)
  8009fd:	74 05                	je     800a04 <memfind+0x21>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009ff:	40                   	inc    %eax
  800a00:	39 c2                	cmp    %eax,%edx
  800a02:	77 f7                	ja     8009fb <memfind+0x18>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a04:	c9                   	leave  
  800a05:	c3                   	ret    

00800a06 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a06:	55                   	push   %ebp
  800a07:	89 e5                	mov    %esp,%ebp
  800a09:	57                   	push   %edi
  800a0a:	56                   	push   %esi
  800a0b:	53                   	push   %ebx
  800a0c:	8b 55 08             	mov    0x8(%ebp),%edx
  800a0f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a12:	eb 01                	jmp    800a15 <strtol+0xf>
		s++;
  800a14:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a15:	8a 02                	mov    (%edx),%al
  800a17:	3c 20                	cmp    $0x20,%al
  800a19:	74 f9                	je     800a14 <strtol+0xe>
  800a1b:	3c 09                	cmp    $0x9,%al
  800a1d:	74 f5                	je     800a14 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a1f:	3c 2b                	cmp    $0x2b,%al
  800a21:	75 08                	jne    800a2b <strtol+0x25>
		s++;
  800a23:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a24:	bf 00 00 00 00       	mov    $0x0,%edi
  800a29:	eb 13                	jmp    800a3e <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a2b:	3c 2d                	cmp    $0x2d,%al
  800a2d:	75 0a                	jne    800a39 <strtol+0x33>
		s++, neg = 1;
  800a2f:	8d 52 01             	lea    0x1(%edx),%edx
  800a32:	bf 01 00 00 00       	mov    $0x1,%edi
  800a37:	eb 05                	jmp    800a3e <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a39:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a3e:	85 db                	test   %ebx,%ebx
  800a40:	74 05                	je     800a47 <strtol+0x41>
  800a42:	83 fb 10             	cmp    $0x10,%ebx
  800a45:	75 28                	jne    800a6f <strtol+0x69>
  800a47:	8a 02                	mov    (%edx),%al
  800a49:	3c 30                	cmp    $0x30,%al
  800a4b:	75 10                	jne    800a5d <strtol+0x57>
  800a4d:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800a51:	75 0a                	jne    800a5d <strtol+0x57>
		s += 2, base = 16;
  800a53:	83 c2 02             	add    $0x2,%edx
  800a56:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a5b:	eb 12                	jmp    800a6f <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800a5d:	85 db                	test   %ebx,%ebx
  800a5f:	75 0e                	jne    800a6f <strtol+0x69>
  800a61:	3c 30                	cmp    $0x30,%al
  800a63:	75 05                	jne    800a6a <strtol+0x64>
		s++, base = 8;
  800a65:	42                   	inc    %edx
  800a66:	b3 08                	mov    $0x8,%bl
  800a68:	eb 05                	jmp    800a6f <strtol+0x69>
	else if (base == 0)
		base = 10;
  800a6a:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800a6f:	b8 00 00 00 00       	mov    $0x0,%eax
  800a74:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a76:	8a 0a                	mov    (%edx),%cl
  800a78:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800a7b:	80 fb 09             	cmp    $0x9,%bl
  800a7e:	77 08                	ja     800a88 <strtol+0x82>
			dig = *s - '0';
  800a80:	0f be c9             	movsbl %cl,%ecx
  800a83:	83 e9 30             	sub    $0x30,%ecx
  800a86:	eb 1e                	jmp    800aa6 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800a88:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800a8b:	80 fb 19             	cmp    $0x19,%bl
  800a8e:	77 08                	ja     800a98 <strtol+0x92>
			dig = *s - 'a' + 10;
  800a90:	0f be c9             	movsbl %cl,%ecx
  800a93:	83 e9 57             	sub    $0x57,%ecx
  800a96:	eb 0e                	jmp    800aa6 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800a98:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800a9b:	80 fb 19             	cmp    $0x19,%bl
  800a9e:	77 13                	ja     800ab3 <strtol+0xad>
			dig = *s - 'A' + 10;
  800aa0:	0f be c9             	movsbl %cl,%ecx
  800aa3:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800aa6:	39 f1                	cmp    %esi,%ecx
  800aa8:	7d 0d                	jge    800ab7 <strtol+0xb1>
			break;
		s++, val = (val * base) + dig;
  800aaa:	42                   	inc    %edx
  800aab:	0f af c6             	imul   %esi,%eax
  800aae:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  800ab1:	eb c3                	jmp    800a76 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800ab3:	89 c1                	mov    %eax,%ecx
  800ab5:	eb 02                	jmp    800ab9 <strtol+0xb3>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800ab7:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800ab9:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800abd:	74 05                	je     800ac4 <strtol+0xbe>
		*endptr = (char *) s;
  800abf:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800ac2:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800ac4:	85 ff                	test   %edi,%edi
  800ac6:	74 04                	je     800acc <strtol+0xc6>
  800ac8:	89 c8                	mov    %ecx,%eax
  800aca:	f7 d8                	neg    %eax
}
  800acc:	5b                   	pop    %ebx
  800acd:	5e                   	pop    %esi
  800ace:	5f                   	pop    %edi
  800acf:	c9                   	leave  
  800ad0:	c3                   	ret    
  800ad1:	00 00                	add    %al,(%eax)
	...

00800ad4 <syscall>:
	return ret;
}

static int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800ad4:	55                   	push   %ebp
  800ad5:	89 e5                	mov    %esp,%ebp
  800ad7:	57                   	push   %edi
  800ad8:	56                   	push   %esi
  800ad9:	53                   	push   %ebx
  800ada:	83 ec 1c             	sub    $0x1c,%esp
  800add:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800ae0:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800ae3:	89 ca                	mov    %ecx,%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ae5:	8b 75 14             	mov    0x14(%ebp),%esi
  800ae8:	8b 7d 10             	mov    0x10(%ebp),%edi
  800aeb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800aee:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800af1:	cd 30                	int    $0x30
  800af3:	89 c2                	mov    %eax,%edx
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800af5:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800af9:	74 1c                	je     800b17 <syscall+0x43>
  800afb:	85 c0                	test   %eax,%eax
  800afd:	7e 18                	jle    800b17 <syscall+0x43>
		panic("syscall %d returned %d (> 0)", num, ret);
  800aff:	83 ec 0c             	sub    $0xc,%esp
  800b02:	50                   	push   %eax
  800b03:	ff 75 e4             	pushl  -0x1c(%ebp)
  800b06:	68 5f 21 80 00       	push   $0x80215f
  800b0b:	6a 42                	push   $0x42
  800b0d:	68 7c 21 80 00       	push   $0x80217c
  800b12:	e8 2d 10 00 00       	call   801b44 <_panic>

	return ret;
}
  800b17:	89 d0                	mov    %edx,%eax
  800b19:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b1c:	5b                   	pop    %ebx
  800b1d:	5e                   	pop    %esi
  800b1e:	5f                   	pop    %edi
  800b1f:	c9                   	leave  
  800b20:	c3                   	ret    

00800b21 <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{	
  800b21:	55                   	push   %ebp
  800b22:	89 e5                	mov    %esp,%ebp
  800b24:	83 ec 08             	sub    $0x8,%esp
	// my_sysenter(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
	// return;
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  800b27:	6a 00                	push   $0x0
  800b29:	6a 00                	push   $0x0
  800b2b:	6a 00                	push   $0x0
  800b2d:	ff 75 0c             	pushl  0xc(%ebp)
  800b30:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b33:	ba 00 00 00 00       	mov    $0x0,%edx
  800b38:	b8 00 00 00 00       	mov    $0x0,%eax
  800b3d:	e8 92 ff ff ff       	call   800ad4 <syscall>
  800b42:	83 c4 10             	add    $0x10,%esp
	return;
}
  800b45:	c9                   	leave  
  800b46:	c3                   	ret    

00800b47 <sys_cgetc>:

int
sys_cgetc(void)
{
  800b47:	55                   	push   %ebp
  800b48:	89 e5                	mov    %esp,%ebp
  800b4a:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_cgetc, 0, 0, 0, 0, 0, 0);
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  800b4d:	6a 00                	push   $0x0
  800b4f:	6a 00                	push   $0x0
  800b51:	6a 00                	push   $0x0
  800b53:	6a 00                	push   $0x0
  800b55:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b5a:	ba 00 00 00 00       	mov    $0x0,%edx
  800b5f:	b8 01 00 00 00       	mov    $0x1,%eax
  800b64:	e8 6b ff ff ff       	call   800ad4 <syscall>
}
  800b69:	c9                   	leave  
  800b6a:	c3                   	ret    

00800b6b <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b6b:	55                   	push   %ebp
  800b6c:	89 e5                	mov    %esp,%ebp
  800b6e:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  800b71:	6a 00                	push   $0x0
  800b73:	6a 00                	push   $0x0
  800b75:	6a 00                	push   $0x0
  800b77:	6a 00                	push   $0x0
  800b79:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b7c:	ba 01 00 00 00       	mov    $0x1,%edx
  800b81:	b8 03 00 00 00       	mov    $0x3,%eax
  800b86:	e8 49 ff ff ff       	call   800ad4 <syscall>
}
  800b8b:	c9                   	leave  
  800b8c:	c3                   	ret    

00800b8d <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b8d:	55                   	push   %ebp
  800b8e:	89 e5                	mov    %esp,%ebp
  800b90:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_getenvid, 0, 0, 0, 0, 0, 0);
	return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  800b93:	6a 00                	push   $0x0
  800b95:	6a 00                	push   $0x0
  800b97:	6a 00                	push   $0x0
  800b99:	6a 00                	push   $0x0
  800b9b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ba0:	ba 00 00 00 00       	mov    $0x0,%edx
  800ba5:	b8 02 00 00 00       	mov    $0x2,%eax
  800baa:	e8 25 ff ff ff       	call   800ad4 <syscall>
}
  800baf:	c9                   	leave  
  800bb0:	c3                   	ret    

00800bb1 <sys_yield>:

void
sys_yield(void)
{
  800bb1:	55                   	push   %ebp
  800bb2:	89 e5                	mov    %esp,%ebp
  800bb4:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  800bb7:	6a 00                	push   $0x0
  800bb9:	6a 00                	push   $0x0
  800bbb:	6a 00                	push   $0x0
  800bbd:	6a 00                	push   $0x0
  800bbf:	b9 00 00 00 00       	mov    $0x0,%ecx
  800bc4:	ba 00 00 00 00       	mov    $0x0,%edx
  800bc9:	b8 0b 00 00 00       	mov    $0xb,%eax
  800bce:	e8 01 ff ff ff       	call   800ad4 <syscall>
  800bd3:	83 c4 10             	add    $0x10,%esp
}
  800bd6:	c9                   	leave  
  800bd7:	c3                   	ret    

00800bd8 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800bd8:	55                   	push   %ebp
  800bd9:	89 e5                	mov    %esp,%ebp
  800bdb:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  800bde:	6a 00                	push   $0x0
  800be0:	6a 00                	push   $0x0
  800be2:	ff 75 10             	pushl  0x10(%ebp)
  800be5:	ff 75 0c             	pushl  0xc(%ebp)
  800be8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800beb:	ba 01 00 00 00       	mov    $0x1,%edx
  800bf0:	b8 04 00 00 00       	mov    $0x4,%eax
  800bf5:	e8 da fe ff ff       	call   800ad4 <syscall>
}
  800bfa:	c9                   	leave  
  800bfb:	c3                   	ret    

00800bfc <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800bfc:	55                   	push   %ebp
  800bfd:	89 e5                	mov    %esp,%ebp
  800bff:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
  800c02:	ff 75 18             	pushl  0x18(%ebp)
  800c05:	ff 75 14             	pushl  0x14(%ebp)
  800c08:	ff 75 10             	pushl  0x10(%ebp)
  800c0b:	ff 75 0c             	pushl  0xc(%ebp)
  800c0e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c11:	ba 01 00 00 00       	mov    $0x1,%edx
  800c16:	b8 05 00 00 00       	mov    $0x5,%eax
  800c1b:	e8 b4 fe ff ff       	call   800ad4 <syscall>
}
  800c20:	c9                   	leave  
  800c21:	c3                   	ret    

00800c22 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c22:	55                   	push   %ebp
  800c23:	89 e5                	mov    %esp,%ebp
  800c25:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  800c28:	6a 00                	push   $0x0
  800c2a:	6a 00                	push   $0x0
  800c2c:	6a 00                	push   $0x0
  800c2e:	ff 75 0c             	pushl  0xc(%ebp)
  800c31:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c34:	ba 01 00 00 00       	mov    $0x1,%edx
  800c39:	b8 06 00 00 00       	mov    $0x6,%eax
  800c3e:	e8 91 fe ff ff       	call   800ad4 <syscall>
}
  800c43:	c9                   	leave  
  800c44:	c3                   	ret    

00800c45 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c45:	55                   	push   %ebp
  800c46:	89 e5                	mov    %esp,%ebp
  800c48:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  800c4b:	6a 00                	push   $0x0
  800c4d:	6a 00                	push   $0x0
  800c4f:	6a 00                	push   $0x0
  800c51:	ff 75 0c             	pushl  0xc(%ebp)
  800c54:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c57:	ba 01 00 00 00       	mov    $0x1,%edx
  800c5c:	b8 08 00 00 00       	mov    $0x8,%eax
  800c61:	e8 6e fe ff ff       	call   800ad4 <syscall>
}
  800c66:	c9                   	leave  
  800c67:	c3                   	ret    

00800c68 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800c68:	55                   	push   %ebp
  800c69:	89 e5                	mov    %esp,%ebp
  800c6b:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
  800c6e:	6a 00                	push   $0x0
  800c70:	6a 00                	push   $0x0
  800c72:	6a 00                	push   $0x0
  800c74:	ff 75 0c             	pushl  0xc(%ebp)
  800c77:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c7a:	ba 01 00 00 00       	mov    $0x1,%edx
  800c7f:	b8 09 00 00 00       	mov    $0x9,%eax
  800c84:	e8 4b fe ff ff       	call   800ad4 <syscall>
}
  800c89:	c9                   	leave  
  800c8a:	c3                   	ret    

00800c8b <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800c8b:	55                   	push   %ebp
  800c8c:	89 e5                	mov    %esp,%ebp
  800c8e:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  800c91:	6a 00                	push   $0x0
  800c93:	6a 00                	push   $0x0
  800c95:	6a 00                	push   $0x0
  800c97:	ff 75 0c             	pushl  0xc(%ebp)
  800c9a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c9d:	ba 01 00 00 00       	mov    $0x1,%edx
  800ca2:	b8 0a 00 00 00       	mov    $0xa,%eax
  800ca7:	e8 28 fe ff ff       	call   800ad4 <syscall>
}
  800cac:	c9                   	leave  
  800cad:	c3                   	ret    

00800cae <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800cae:	55                   	push   %ebp
  800caf:	89 e5                	mov    %esp,%ebp
  800cb1:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  800cb4:	6a 00                	push   $0x0
  800cb6:	ff 75 14             	pushl  0x14(%ebp)
  800cb9:	ff 75 10             	pushl  0x10(%ebp)
  800cbc:	ff 75 0c             	pushl  0xc(%ebp)
  800cbf:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800cc2:	ba 00 00 00 00       	mov    $0x0,%edx
  800cc7:	b8 0c 00 00 00       	mov    $0xc,%eax
  800ccc:	e8 03 fe ff ff       	call   800ad4 <syscall>
}
  800cd1:	c9                   	leave  
  800cd2:	c3                   	ret    

00800cd3 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800cd3:	55                   	push   %ebp
  800cd4:	89 e5                	mov    %esp,%ebp
  800cd6:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  800cd9:	6a 00                	push   $0x0
  800cdb:	6a 00                	push   $0x0
  800cdd:	6a 00                	push   $0x0
  800cdf:	6a 00                	push   $0x0
  800ce1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ce4:	ba 01 00 00 00       	mov    $0x1,%edx
  800ce9:	b8 0d 00 00 00       	mov    $0xd,%eax
  800cee:	e8 e1 fd ff ff       	call   800ad4 <syscall>
}
  800cf3:	c9                   	leave  
  800cf4:	c3                   	ret    

00800cf5 <sys_set_priority>:

int
sys_set_priority(envid_t envid, uint32_t new_priority)
{
  800cf5:	55                   	push   %ebp
  800cf6:	89 e5                	mov    %esp,%ebp
  800cf8:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_set_priority, 0, envid, new_priority, 0, 0, 0);
  800cfb:	6a 00                	push   $0x0
  800cfd:	6a 00                	push   $0x0
  800cff:	6a 00                	push   $0x0
  800d01:	ff 75 0c             	pushl  0xc(%ebp)
  800d04:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d07:	ba 00 00 00 00       	mov    $0x0,%edx
  800d0c:	b8 0e 00 00 00       	mov    $0xe,%eax
  800d11:	e8 be fd ff ff       	call   800ad4 <syscall>
}
  800d16:	c9                   	leave  
  800d17:	c3                   	ret    

00800d18 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  800d18:	55                   	push   %ebp
  800d19:	89 e5                	mov    %esp,%ebp
  800d1b:	57                   	push   %edi
  800d1c:	56                   	push   %esi
  800d1d:	53                   	push   %ebx
  800d1e:	83 ec 0c             	sub    $0xc,%esp
  800d21:	8b 7d 08             	mov    0x8(%ebp),%edi
  800d24:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800d27:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	cprintf("0x%x 0x%x 0x%x\n", (uint32_t)from_env_store, (uint32_t)pg, (uint32_t)perm_store);
  800d2a:	56                   	push   %esi
  800d2b:	53                   	push   %ebx
  800d2c:	57                   	push   %edi
  800d2d:	68 8a 21 80 00       	push   $0x80218a
  800d32:	e8 69 f4 ff ff       	call   8001a0 <cprintf>
	int r;
	if (pg != NULL) {
  800d37:	83 c4 10             	add    $0x10,%esp
  800d3a:	85 db                	test   %ebx,%ebx
  800d3c:	74 28                	je     800d66 <ipc_recv+0x4e>
		cprintf("BEGIN\n");
  800d3e:	83 ec 0c             	sub    $0xc,%esp
  800d41:	68 9a 21 80 00       	push   $0x80219a
  800d46:	e8 55 f4 ff ff       	call   8001a0 <cprintf>
		r = sys_ipc_recv(pg);
  800d4b:	89 1c 24             	mov    %ebx,(%esp)
  800d4e:	e8 80 ff ff ff       	call   800cd3 <sys_ipc_recv>
  800d53:	89 c3                	mov    %eax,%ebx
		cprintf("OVER\n");
  800d55:	c7 04 24 a1 21 80 00 	movl   $0x8021a1,(%esp)
  800d5c:	e8 3f f4 ff ff       	call   8001a0 <cprintf>
  800d61:	83 c4 10             	add    $0x10,%esp
  800d64:	eb 12                	jmp    800d78 <ipc_recv+0x60>
	} else {
		r = sys_ipc_recv((void *)UTOP);
  800d66:	83 ec 0c             	sub    $0xc,%esp
  800d69:	68 00 00 c0 ee       	push   $0xeec00000
  800d6e:	e8 60 ff ff ff       	call   800cd3 <sys_ipc_recv>
  800d73:	89 c3                	mov    %eax,%ebx
  800d75:	83 c4 10             	add    $0x10,%esp
	}

	if (r == 0) {
  800d78:	85 db                	test   %ebx,%ebx
  800d7a:	75 26                	jne    800da2 <ipc_recv+0x8a>
		if (from_env_store != NULL) *from_env_store = thisenv->env_ipc_from;
  800d7c:	85 ff                	test   %edi,%edi
  800d7e:	74 0a                	je     800d8a <ipc_recv+0x72>
  800d80:	a1 04 40 80 00       	mov    0x804004,%eax
  800d85:	8b 40 74             	mov    0x74(%eax),%eax
  800d88:	89 07                	mov    %eax,(%edi)
		if (perm_store != NULL) *perm_store = thisenv->env_ipc_perm;
  800d8a:	85 f6                	test   %esi,%esi
  800d8c:	74 0a                	je     800d98 <ipc_recv+0x80>
  800d8e:	a1 04 40 80 00       	mov    0x804004,%eax
  800d93:	8b 40 78             	mov    0x78(%eax),%eax
  800d96:	89 06                	mov    %eax,(%esi)
		return thisenv->env_ipc_value;
  800d98:	a1 04 40 80 00       	mov    0x804004,%eax
  800d9d:	8b 58 70             	mov    0x70(%eax),%ebx
  800da0:	eb 14                	jmp    800db6 <ipc_recv+0x9e>
	} else {
		// fails;
		if (from_env_store != NULL) *from_env_store = 0;
  800da2:	85 ff                	test   %edi,%edi
  800da4:	74 06                	je     800dac <ipc_recv+0x94>
  800da6:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
		if (perm_store != NULL) *perm_store = 0;
  800dac:	85 f6                	test   %esi,%esi
  800dae:	74 06                	je     800db6 <ipc_recv+0x9e>
  800db0:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		return r;
	}
}
  800db6:	89 d8                	mov    %ebx,%eax
  800db8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dbb:	5b                   	pop    %ebx
  800dbc:	5e                   	pop    %esi
  800dbd:	5f                   	pop    %edi
  800dbe:	c9                   	leave  
  800dbf:	c3                   	ret    

00800dc0 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  800dc0:	55                   	push   %ebp
  800dc1:	89 e5                	mov    %esp,%ebp
  800dc3:	57                   	push   %edi
  800dc4:	56                   	push   %esi
  800dc5:	53                   	push   %ebx
  800dc6:	83 ec 0c             	sub    $0xc,%esp
  800dc9:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800dcc:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800dcf:	8b 75 14             	mov    0x14(%ebp),%esi
	// LAB 4: Your code here.
	// int sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
	int r;
	if (pg == NULL) pg = (void *)UTOP;
  800dd2:	85 db                	test   %ebx,%ebx
  800dd4:	75 25                	jne    800dfb <ipc_send+0x3b>
  800dd6:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
  800ddb:	eb 1e                	jmp    800dfb <ipc_send+0x3b>
	
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) != 0) {
		if (r == -E_IPC_NOT_RECV) {
  800ddd:	83 f8 f9             	cmp    $0xfffffff9,%eax
  800de0:	75 07                	jne    800de9 <ipc_send+0x29>
			// cprintf("Try Again and Again....\n");
			sys_yield();
  800de2:	e8 ca fd ff ff       	call   800bb1 <sys_yield>
  800de7:	eb 12                	jmp    800dfb <ipc_send+0x3b>
		} else {
			panic("ipc_send error %e\n", r);
  800de9:	50                   	push   %eax
  800dea:	68 a7 21 80 00       	push   $0x8021a7
  800def:	6a 45                	push   $0x45
  800df1:	68 ba 21 80 00       	push   $0x8021ba
  800df6:	e8 49 0d 00 00       	call   801b44 <_panic>
	// LAB 4: Your code here.
	// int sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
	int r;
	if (pg == NULL) pg = (void *)UTOP;
	
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) != 0) {
  800dfb:	56                   	push   %esi
  800dfc:	53                   	push   %ebx
  800dfd:	57                   	push   %edi
  800dfe:	ff 75 08             	pushl  0x8(%ebp)
  800e01:	e8 a8 fe ff ff       	call   800cae <sys_ipc_try_send>
  800e06:	83 c4 10             	add    $0x10,%esp
  800e09:	85 c0                	test   %eax,%eax
  800e0b:	75 d0                	jne    800ddd <ipc_send+0x1d>
		} else {
			panic("ipc_send error %e\n", r);
		}
	}
	return;
}
  800e0d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e10:	5b                   	pop    %ebx
  800e11:	5e                   	pop    %esi
  800e12:	5f                   	pop    %edi
  800e13:	c9                   	leave  
  800e14:	c3                   	ret    

00800e15 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  800e15:	55                   	push   %ebp
  800e16:	89 e5                	mov    %esp,%ebp
  800e18:	53                   	push   %ebx
  800e19:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  800e1c:	39 1d 50 00 c0 ee    	cmp    %ebx,0xeec00050
  800e22:	74 22                	je     800e46 <ipc_find_env+0x31>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  800e24:	b8 01 00 00 00       	mov    $0x1,%eax
		if (envs[i].env_type == type)
  800e29:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  800e30:	89 c2                	mov    %eax,%edx
  800e32:	c1 e2 07             	shl    $0x7,%edx
  800e35:	29 ca                	sub    %ecx,%edx
  800e37:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  800e3d:	8b 52 50             	mov    0x50(%edx),%edx
  800e40:	39 da                	cmp    %ebx,%edx
  800e42:	75 1d                	jne    800e61 <ipc_find_env+0x4c>
  800e44:	eb 05                	jmp    800e4b <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  800e46:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
			return envs[i].env_id;
  800e4b:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800e52:	c1 e0 07             	shl    $0x7,%eax
  800e55:	29 d0                	sub    %edx,%eax
  800e57:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  800e5c:	8b 40 40             	mov    0x40(%eax),%eax
  800e5f:	eb 0c                	jmp    800e6d <ipc_find_env+0x58>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  800e61:	40                   	inc    %eax
  800e62:	3d 00 04 00 00       	cmp    $0x400,%eax
  800e67:	75 c0                	jne    800e29 <ipc_find_env+0x14>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  800e69:	66 b8 00 00          	mov    $0x0,%ax
}
  800e6d:	5b                   	pop    %ebx
  800e6e:	c9                   	leave  
  800e6f:	c3                   	ret    

00800e70 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800e70:	55                   	push   %ebp
  800e71:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800e73:	8b 45 08             	mov    0x8(%ebp),%eax
  800e76:	05 00 00 00 30       	add    $0x30000000,%eax
  800e7b:	c1 e8 0c             	shr    $0xc,%eax
}
  800e7e:	c9                   	leave  
  800e7f:	c3                   	ret    

00800e80 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800e80:	55                   	push   %ebp
  800e81:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800e83:	ff 75 08             	pushl  0x8(%ebp)
  800e86:	e8 e5 ff ff ff       	call   800e70 <fd2num>
  800e8b:	83 c4 04             	add    $0x4,%esp
  800e8e:	05 20 00 0d 00       	add    $0xd0020,%eax
  800e93:	c1 e0 0c             	shl    $0xc,%eax
}
  800e96:	c9                   	leave  
  800e97:	c3                   	ret    

00800e98 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800e98:	55                   	push   %ebp
  800e99:	89 e5                	mov    %esp,%ebp
  800e9b:	53                   	push   %ebx
  800e9c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800e9f:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  800ea4:	a8 01                	test   $0x1,%al
  800ea6:	74 34                	je     800edc <fd_alloc+0x44>
  800ea8:	a1 00 00 74 ef       	mov    0xef740000,%eax
  800ead:	a8 01                	test   $0x1,%al
  800eaf:	74 32                	je     800ee3 <fd_alloc+0x4b>
  800eb1:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
  800eb6:	89 c1                	mov    %eax,%ecx
  800eb8:	89 c2                	mov    %eax,%edx
  800eba:	c1 ea 16             	shr    $0x16,%edx
  800ebd:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800ec4:	f6 c2 01             	test   $0x1,%dl
  800ec7:	74 1f                	je     800ee8 <fd_alloc+0x50>
  800ec9:	89 c2                	mov    %eax,%edx
  800ecb:	c1 ea 0c             	shr    $0xc,%edx
  800ece:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800ed5:	f6 c2 01             	test   $0x1,%dl
  800ed8:	75 17                	jne    800ef1 <fd_alloc+0x59>
  800eda:	eb 0c                	jmp    800ee8 <fd_alloc+0x50>
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  800edc:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
  800ee1:	eb 05                	jmp    800ee8 <fd_alloc+0x50>
  800ee3:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
  800ee8:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  800eea:	b8 00 00 00 00       	mov    $0x0,%eax
  800eef:	eb 17                	jmp    800f08 <fd_alloc+0x70>
  800ef1:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800ef6:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800efb:	75 b9                	jne    800eb6 <fd_alloc+0x1e>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800efd:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  800f03:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800f08:	5b                   	pop    %ebx
  800f09:	c9                   	leave  
  800f0a:	c3                   	ret    

00800f0b <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800f0b:	55                   	push   %ebp
  800f0c:	89 e5                	mov    %esp,%ebp
  800f0e:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800f11:	83 f8 1f             	cmp    $0x1f,%eax
  800f14:	77 36                	ja     800f4c <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800f16:	05 00 00 0d 00       	add    $0xd0000,%eax
  800f1b:	c1 e0 0c             	shl    $0xc,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800f1e:	89 c2                	mov    %eax,%edx
  800f20:	c1 ea 16             	shr    $0x16,%edx
  800f23:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800f2a:	f6 c2 01             	test   $0x1,%dl
  800f2d:	74 24                	je     800f53 <fd_lookup+0x48>
  800f2f:	89 c2                	mov    %eax,%edx
  800f31:	c1 ea 0c             	shr    $0xc,%edx
  800f34:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800f3b:	f6 c2 01             	test   $0x1,%dl
  800f3e:	74 1a                	je     800f5a <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800f40:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f43:	89 02                	mov    %eax,(%edx)
	return 0;
  800f45:	b8 00 00 00 00       	mov    $0x0,%eax
  800f4a:	eb 13                	jmp    800f5f <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800f4c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f51:	eb 0c                	jmp    800f5f <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800f53:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f58:	eb 05                	jmp    800f5f <fd_lookup+0x54>
  800f5a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800f5f:	c9                   	leave  
  800f60:	c3                   	ret    

00800f61 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800f61:	55                   	push   %ebp
  800f62:	89 e5                	mov    %esp,%ebp
  800f64:	53                   	push   %ebx
  800f65:	83 ec 04             	sub    $0x4,%esp
  800f68:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f6b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  800f6e:	39 0d 04 30 80 00    	cmp    %ecx,0x803004
  800f74:	74 0d                	je     800f83 <dev_lookup+0x22>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800f76:	b8 00 00 00 00       	mov    $0x0,%eax
  800f7b:	eb 14                	jmp    800f91 <dev_lookup+0x30>
		if (devtab[i]->dev_id == dev_id) {
  800f7d:	39 0a                	cmp    %ecx,(%edx)
  800f7f:	75 10                	jne    800f91 <dev_lookup+0x30>
  800f81:	eb 05                	jmp    800f88 <dev_lookup+0x27>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800f83:	ba 04 30 80 00       	mov    $0x803004,%edx
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
  800f88:	89 13                	mov    %edx,(%ebx)
			return 0;
  800f8a:	b8 00 00 00 00       	mov    $0x0,%eax
  800f8f:	eb 31                	jmp    800fc2 <dev_lookup+0x61>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800f91:	40                   	inc    %eax
  800f92:	8b 14 85 40 22 80 00 	mov    0x802240(,%eax,4),%edx
  800f99:	85 d2                	test   %edx,%edx
  800f9b:	75 e0                	jne    800f7d <dev_lookup+0x1c>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800f9d:	a1 04 40 80 00       	mov    0x804004,%eax
  800fa2:	8b 40 48             	mov    0x48(%eax),%eax
  800fa5:	83 ec 04             	sub    $0x4,%esp
  800fa8:	51                   	push   %ecx
  800fa9:	50                   	push   %eax
  800faa:	68 c4 21 80 00       	push   $0x8021c4
  800faf:	e8 ec f1 ff ff       	call   8001a0 <cprintf>
	*dev = 0;
  800fb4:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  800fba:	83 c4 10             	add    $0x10,%esp
  800fbd:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800fc2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800fc5:	c9                   	leave  
  800fc6:	c3                   	ret    

00800fc7 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800fc7:	55                   	push   %ebp
  800fc8:	89 e5                	mov    %esp,%ebp
  800fca:	56                   	push   %esi
  800fcb:	53                   	push   %ebx
  800fcc:	83 ec 20             	sub    $0x20,%esp
  800fcf:	8b 75 08             	mov    0x8(%ebp),%esi
  800fd2:	8a 45 0c             	mov    0xc(%ebp),%al
  800fd5:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800fd8:	56                   	push   %esi
  800fd9:	e8 92 fe ff ff       	call   800e70 <fd2num>
  800fde:	8d 55 f4             	lea    -0xc(%ebp),%edx
  800fe1:	89 14 24             	mov    %edx,(%esp)
  800fe4:	50                   	push   %eax
  800fe5:	e8 21 ff ff ff       	call   800f0b <fd_lookup>
  800fea:	89 c3                	mov    %eax,%ebx
  800fec:	83 c4 08             	add    $0x8,%esp
  800fef:	85 c0                	test   %eax,%eax
  800ff1:	78 05                	js     800ff8 <fd_close+0x31>
	    || fd != fd2)
  800ff3:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800ff6:	74 0d                	je     801005 <fd_close+0x3e>
		return (must_exist ? r : 0);
  800ff8:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  800ffc:	75 48                	jne    801046 <fd_close+0x7f>
  800ffe:	bb 00 00 00 00       	mov    $0x0,%ebx
  801003:	eb 41                	jmp    801046 <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801005:	83 ec 08             	sub    $0x8,%esp
  801008:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80100b:	50                   	push   %eax
  80100c:	ff 36                	pushl  (%esi)
  80100e:	e8 4e ff ff ff       	call   800f61 <dev_lookup>
  801013:	89 c3                	mov    %eax,%ebx
  801015:	83 c4 10             	add    $0x10,%esp
  801018:	85 c0                	test   %eax,%eax
  80101a:	78 1c                	js     801038 <fd_close+0x71>
		if (dev->dev_close)
  80101c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80101f:	8b 40 10             	mov    0x10(%eax),%eax
  801022:	85 c0                	test   %eax,%eax
  801024:	74 0d                	je     801033 <fd_close+0x6c>
			r = (*dev->dev_close)(fd);
  801026:	83 ec 0c             	sub    $0xc,%esp
  801029:	56                   	push   %esi
  80102a:	ff d0                	call   *%eax
  80102c:	89 c3                	mov    %eax,%ebx
  80102e:	83 c4 10             	add    $0x10,%esp
  801031:	eb 05                	jmp    801038 <fd_close+0x71>
		else
			r = 0;
  801033:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801038:	83 ec 08             	sub    $0x8,%esp
  80103b:	56                   	push   %esi
  80103c:	6a 00                	push   $0x0
  80103e:	e8 df fb ff ff       	call   800c22 <sys_page_unmap>
	return r;
  801043:	83 c4 10             	add    $0x10,%esp
}
  801046:	89 d8                	mov    %ebx,%eax
  801048:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80104b:	5b                   	pop    %ebx
  80104c:	5e                   	pop    %esi
  80104d:	c9                   	leave  
  80104e:	c3                   	ret    

0080104f <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80104f:	55                   	push   %ebp
  801050:	89 e5                	mov    %esp,%ebp
  801052:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801055:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801058:	50                   	push   %eax
  801059:	ff 75 08             	pushl  0x8(%ebp)
  80105c:	e8 aa fe ff ff       	call   800f0b <fd_lookup>
  801061:	83 c4 08             	add    $0x8,%esp
  801064:	85 c0                	test   %eax,%eax
  801066:	78 10                	js     801078 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801068:	83 ec 08             	sub    $0x8,%esp
  80106b:	6a 01                	push   $0x1
  80106d:	ff 75 f4             	pushl  -0xc(%ebp)
  801070:	e8 52 ff ff ff       	call   800fc7 <fd_close>
  801075:	83 c4 10             	add    $0x10,%esp
}
  801078:	c9                   	leave  
  801079:	c3                   	ret    

0080107a <close_all>:

void
close_all(void)
{
  80107a:	55                   	push   %ebp
  80107b:	89 e5                	mov    %esp,%ebp
  80107d:	53                   	push   %ebx
  80107e:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801081:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801086:	83 ec 0c             	sub    $0xc,%esp
  801089:	53                   	push   %ebx
  80108a:	e8 c0 ff ff ff       	call   80104f <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80108f:	43                   	inc    %ebx
  801090:	83 c4 10             	add    $0x10,%esp
  801093:	83 fb 20             	cmp    $0x20,%ebx
  801096:	75 ee                	jne    801086 <close_all+0xc>
		close(i);
}
  801098:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80109b:	c9                   	leave  
  80109c:	c3                   	ret    

0080109d <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80109d:	55                   	push   %ebp
  80109e:	89 e5                	mov    %esp,%ebp
  8010a0:	57                   	push   %edi
  8010a1:	56                   	push   %esi
  8010a2:	53                   	push   %ebx
  8010a3:	83 ec 2c             	sub    $0x2c,%esp
  8010a6:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8010a9:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8010ac:	50                   	push   %eax
  8010ad:	ff 75 08             	pushl  0x8(%ebp)
  8010b0:	e8 56 fe ff ff       	call   800f0b <fd_lookup>
  8010b5:	89 c3                	mov    %eax,%ebx
  8010b7:	83 c4 08             	add    $0x8,%esp
  8010ba:	85 c0                	test   %eax,%eax
  8010bc:	0f 88 c0 00 00 00    	js     801182 <dup+0xe5>
		return r;
	close(newfdnum);
  8010c2:	83 ec 0c             	sub    $0xc,%esp
  8010c5:	57                   	push   %edi
  8010c6:	e8 84 ff ff ff       	call   80104f <close>

	newfd = INDEX2FD(newfdnum);
  8010cb:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  8010d1:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  8010d4:	83 c4 04             	add    $0x4,%esp
  8010d7:	ff 75 e4             	pushl  -0x1c(%ebp)
  8010da:	e8 a1 fd ff ff       	call   800e80 <fd2data>
  8010df:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  8010e1:	89 34 24             	mov    %esi,(%esp)
  8010e4:	e8 97 fd ff ff       	call   800e80 <fd2data>
  8010e9:	83 c4 10             	add    $0x10,%esp
  8010ec:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8010ef:	89 d8                	mov    %ebx,%eax
  8010f1:	c1 e8 16             	shr    $0x16,%eax
  8010f4:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8010fb:	a8 01                	test   $0x1,%al
  8010fd:	74 37                	je     801136 <dup+0x99>
  8010ff:	89 d8                	mov    %ebx,%eax
  801101:	c1 e8 0c             	shr    $0xc,%eax
  801104:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80110b:	f6 c2 01             	test   $0x1,%dl
  80110e:	74 26                	je     801136 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801110:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801117:	83 ec 0c             	sub    $0xc,%esp
  80111a:	25 07 0e 00 00       	and    $0xe07,%eax
  80111f:	50                   	push   %eax
  801120:	ff 75 d4             	pushl  -0x2c(%ebp)
  801123:	6a 00                	push   $0x0
  801125:	53                   	push   %ebx
  801126:	6a 00                	push   $0x0
  801128:	e8 cf fa ff ff       	call   800bfc <sys_page_map>
  80112d:	89 c3                	mov    %eax,%ebx
  80112f:	83 c4 20             	add    $0x20,%esp
  801132:	85 c0                	test   %eax,%eax
  801134:	78 2d                	js     801163 <dup+0xc6>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801136:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801139:	89 c2                	mov    %eax,%edx
  80113b:	c1 ea 0c             	shr    $0xc,%edx
  80113e:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801145:	83 ec 0c             	sub    $0xc,%esp
  801148:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  80114e:	52                   	push   %edx
  80114f:	56                   	push   %esi
  801150:	6a 00                	push   $0x0
  801152:	50                   	push   %eax
  801153:	6a 00                	push   $0x0
  801155:	e8 a2 fa ff ff       	call   800bfc <sys_page_map>
  80115a:	89 c3                	mov    %eax,%ebx
  80115c:	83 c4 20             	add    $0x20,%esp
  80115f:	85 c0                	test   %eax,%eax
  801161:	79 1d                	jns    801180 <dup+0xe3>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801163:	83 ec 08             	sub    $0x8,%esp
  801166:	56                   	push   %esi
  801167:	6a 00                	push   $0x0
  801169:	e8 b4 fa ff ff       	call   800c22 <sys_page_unmap>
	sys_page_unmap(0, nva);
  80116e:	83 c4 08             	add    $0x8,%esp
  801171:	ff 75 d4             	pushl  -0x2c(%ebp)
  801174:	6a 00                	push   $0x0
  801176:	e8 a7 fa ff ff       	call   800c22 <sys_page_unmap>
	return r;
  80117b:	83 c4 10             	add    $0x10,%esp
  80117e:	eb 02                	jmp    801182 <dup+0xe5>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  801180:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  801182:	89 d8                	mov    %ebx,%eax
  801184:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801187:	5b                   	pop    %ebx
  801188:	5e                   	pop    %esi
  801189:	5f                   	pop    %edi
  80118a:	c9                   	leave  
  80118b:	c3                   	ret    

0080118c <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80118c:	55                   	push   %ebp
  80118d:	89 e5                	mov    %esp,%ebp
  80118f:	53                   	push   %ebx
  801190:	83 ec 14             	sub    $0x14,%esp
  801193:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801196:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801199:	50                   	push   %eax
  80119a:	53                   	push   %ebx
  80119b:	e8 6b fd ff ff       	call   800f0b <fd_lookup>
  8011a0:	83 c4 08             	add    $0x8,%esp
  8011a3:	85 c0                	test   %eax,%eax
  8011a5:	78 67                	js     80120e <read+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011a7:	83 ec 08             	sub    $0x8,%esp
  8011aa:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011ad:	50                   	push   %eax
  8011ae:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011b1:	ff 30                	pushl  (%eax)
  8011b3:	e8 a9 fd ff ff       	call   800f61 <dev_lookup>
  8011b8:	83 c4 10             	add    $0x10,%esp
  8011bb:	85 c0                	test   %eax,%eax
  8011bd:	78 4f                	js     80120e <read+0x82>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8011bf:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011c2:	8b 50 08             	mov    0x8(%eax),%edx
  8011c5:	83 e2 03             	and    $0x3,%edx
  8011c8:	83 fa 01             	cmp    $0x1,%edx
  8011cb:	75 21                	jne    8011ee <read+0x62>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8011cd:	a1 04 40 80 00       	mov    0x804004,%eax
  8011d2:	8b 40 48             	mov    0x48(%eax),%eax
  8011d5:	83 ec 04             	sub    $0x4,%esp
  8011d8:	53                   	push   %ebx
  8011d9:	50                   	push   %eax
  8011da:	68 05 22 80 00       	push   $0x802205
  8011df:	e8 bc ef ff ff       	call   8001a0 <cprintf>
		return -E_INVAL;
  8011e4:	83 c4 10             	add    $0x10,%esp
  8011e7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8011ec:	eb 20                	jmp    80120e <read+0x82>
	}
	if (!dev->dev_read)
  8011ee:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8011f1:	8b 52 08             	mov    0x8(%edx),%edx
  8011f4:	85 d2                	test   %edx,%edx
  8011f6:	74 11                	je     801209 <read+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8011f8:	83 ec 04             	sub    $0x4,%esp
  8011fb:	ff 75 10             	pushl  0x10(%ebp)
  8011fe:	ff 75 0c             	pushl  0xc(%ebp)
  801201:	50                   	push   %eax
  801202:	ff d2                	call   *%edx
  801204:	83 c4 10             	add    $0x10,%esp
  801207:	eb 05                	jmp    80120e <read+0x82>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801209:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  80120e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801211:	c9                   	leave  
  801212:	c3                   	ret    

00801213 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801213:	55                   	push   %ebp
  801214:	89 e5                	mov    %esp,%ebp
  801216:	57                   	push   %edi
  801217:	56                   	push   %esi
  801218:	53                   	push   %ebx
  801219:	83 ec 0c             	sub    $0xc,%esp
  80121c:	8b 7d 08             	mov    0x8(%ebp),%edi
  80121f:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801222:	85 f6                	test   %esi,%esi
  801224:	74 31                	je     801257 <readn+0x44>
  801226:	b8 00 00 00 00       	mov    $0x0,%eax
  80122b:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = read(fdnum, (char*)buf + tot, n - tot);
  801230:	83 ec 04             	sub    $0x4,%esp
  801233:	89 f2                	mov    %esi,%edx
  801235:	29 c2                	sub    %eax,%edx
  801237:	52                   	push   %edx
  801238:	03 45 0c             	add    0xc(%ebp),%eax
  80123b:	50                   	push   %eax
  80123c:	57                   	push   %edi
  80123d:	e8 4a ff ff ff       	call   80118c <read>
		if (m < 0)
  801242:	83 c4 10             	add    $0x10,%esp
  801245:	85 c0                	test   %eax,%eax
  801247:	78 17                	js     801260 <readn+0x4d>
			return m;
		if (m == 0)
  801249:	85 c0                	test   %eax,%eax
  80124b:	74 11                	je     80125e <readn+0x4b>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80124d:	01 c3                	add    %eax,%ebx
  80124f:	89 d8                	mov    %ebx,%eax
  801251:	39 f3                	cmp    %esi,%ebx
  801253:	72 db                	jb     801230 <readn+0x1d>
  801255:	eb 09                	jmp    801260 <readn+0x4d>
  801257:	b8 00 00 00 00       	mov    $0x0,%eax
  80125c:	eb 02                	jmp    801260 <readn+0x4d>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  80125e:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  801260:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801263:	5b                   	pop    %ebx
  801264:	5e                   	pop    %esi
  801265:	5f                   	pop    %edi
  801266:	c9                   	leave  
  801267:	c3                   	ret    

00801268 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801268:	55                   	push   %ebp
  801269:	89 e5                	mov    %esp,%ebp
  80126b:	53                   	push   %ebx
  80126c:	83 ec 14             	sub    $0x14,%esp
  80126f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801272:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801275:	50                   	push   %eax
  801276:	53                   	push   %ebx
  801277:	e8 8f fc ff ff       	call   800f0b <fd_lookup>
  80127c:	83 c4 08             	add    $0x8,%esp
  80127f:	85 c0                	test   %eax,%eax
  801281:	78 62                	js     8012e5 <write+0x7d>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801283:	83 ec 08             	sub    $0x8,%esp
  801286:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801289:	50                   	push   %eax
  80128a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80128d:	ff 30                	pushl  (%eax)
  80128f:	e8 cd fc ff ff       	call   800f61 <dev_lookup>
  801294:	83 c4 10             	add    $0x10,%esp
  801297:	85 c0                	test   %eax,%eax
  801299:	78 4a                	js     8012e5 <write+0x7d>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80129b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80129e:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8012a2:	75 21                	jne    8012c5 <write+0x5d>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8012a4:	a1 04 40 80 00       	mov    0x804004,%eax
  8012a9:	8b 40 48             	mov    0x48(%eax),%eax
  8012ac:	83 ec 04             	sub    $0x4,%esp
  8012af:	53                   	push   %ebx
  8012b0:	50                   	push   %eax
  8012b1:	68 21 22 80 00       	push   $0x802221
  8012b6:	e8 e5 ee ff ff       	call   8001a0 <cprintf>
		return -E_INVAL;
  8012bb:	83 c4 10             	add    $0x10,%esp
  8012be:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012c3:	eb 20                	jmp    8012e5 <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8012c5:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8012c8:	8b 52 0c             	mov    0xc(%edx),%edx
  8012cb:	85 d2                	test   %edx,%edx
  8012cd:	74 11                	je     8012e0 <write+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8012cf:	83 ec 04             	sub    $0x4,%esp
  8012d2:	ff 75 10             	pushl  0x10(%ebp)
  8012d5:	ff 75 0c             	pushl  0xc(%ebp)
  8012d8:	50                   	push   %eax
  8012d9:	ff d2                	call   *%edx
  8012db:	83 c4 10             	add    $0x10,%esp
  8012de:	eb 05                	jmp    8012e5 <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8012e0:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  8012e5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012e8:	c9                   	leave  
  8012e9:	c3                   	ret    

008012ea <seek>:

int
seek(int fdnum, off_t offset)
{
  8012ea:	55                   	push   %ebp
  8012eb:	89 e5                	mov    %esp,%ebp
  8012ed:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8012f0:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8012f3:	50                   	push   %eax
  8012f4:	ff 75 08             	pushl  0x8(%ebp)
  8012f7:	e8 0f fc ff ff       	call   800f0b <fd_lookup>
  8012fc:	83 c4 08             	add    $0x8,%esp
  8012ff:	85 c0                	test   %eax,%eax
  801301:	78 0e                	js     801311 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801303:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801306:	8b 55 0c             	mov    0xc(%ebp),%edx
  801309:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80130c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801311:	c9                   	leave  
  801312:	c3                   	ret    

00801313 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801313:	55                   	push   %ebp
  801314:	89 e5                	mov    %esp,%ebp
  801316:	53                   	push   %ebx
  801317:	83 ec 14             	sub    $0x14,%esp
  80131a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80131d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801320:	50                   	push   %eax
  801321:	53                   	push   %ebx
  801322:	e8 e4 fb ff ff       	call   800f0b <fd_lookup>
  801327:	83 c4 08             	add    $0x8,%esp
  80132a:	85 c0                	test   %eax,%eax
  80132c:	78 5f                	js     80138d <ftruncate+0x7a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80132e:	83 ec 08             	sub    $0x8,%esp
  801331:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801334:	50                   	push   %eax
  801335:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801338:	ff 30                	pushl  (%eax)
  80133a:	e8 22 fc ff ff       	call   800f61 <dev_lookup>
  80133f:	83 c4 10             	add    $0x10,%esp
  801342:	85 c0                	test   %eax,%eax
  801344:	78 47                	js     80138d <ftruncate+0x7a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801346:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801349:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80134d:	75 21                	jne    801370 <ftruncate+0x5d>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80134f:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801354:	8b 40 48             	mov    0x48(%eax),%eax
  801357:	83 ec 04             	sub    $0x4,%esp
  80135a:	53                   	push   %ebx
  80135b:	50                   	push   %eax
  80135c:	68 e4 21 80 00       	push   $0x8021e4
  801361:	e8 3a ee ff ff       	call   8001a0 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801366:	83 c4 10             	add    $0x10,%esp
  801369:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80136e:	eb 1d                	jmp    80138d <ftruncate+0x7a>
	}
	if (!dev->dev_trunc)
  801370:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801373:	8b 52 18             	mov    0x18(%edx),%edx
  801376:	85 d2                	test   %edx,%edx
  801378:	74 0e                	je     801388 <ftruncate+0x75>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80137a:	83 ec 08             	sub    $0x8,%esp
  80137d:	ff 75 0c             	pushl  0xc(%ebp)
  801380:	50                   	push   %eax
  801381:	ff d2                	call   *%edx
  801383:	83 c4 10             	add    $0x10,%esp
  801386:	eb 05                	jmp    80138d <ftruncate+0x7a>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801388:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  80138d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801390:	c9                   	leave  
  801391:	c3                   	ret    

00801392 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801392:	55                   	push   %ebp
  801393:	89 e5                	mov    %esp,%ebp
  801395:	53                   	push   %ebx
  801396:	83 ec 14             	sub    $0x14,%esp
  801399:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80139c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80139f:	50                   	push   %eax
  8013a0:	ff 75 08             	pushl  0x8(%ebp)
  8013a3:	e8 63 fb ff ff       	call   800f0b <fd_lookup>
  8013a8:	83 c4 08             	add    $0x8,%esp
  8013ab:	85 c0                	test   %eax,%eax
  8013ad:	78 52                	js     801401 <fstat+0x6f>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013af:	83 ec 08             	sub    $0x8,%esp
  8013b2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013b5:	50                   	push   %eax
  8013b6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013b9:	ff 30                	pushl  (%eax)
  8013bb:	e8 a1 fb ff ff       	call   800f61 <dev_lookup>
  8013c0:	83 c4 10             	add    $0x10,%esp
  8013c3:	85 c0                	test   %eax,%eax
  8013c5:	78 3a                	js     801401 <fstat+0x6f>
		return r;
	if (!dev->dev_stat)
  8013c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013ca:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8013ce:	74 2c                	je     8013fc <fstat+0x6a>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8013d0:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8013d3:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8013da:	00 00 00 
	stat->st_isdir = 0;
  8013dd:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8013e4:	00 00 00 
	stat->st_dev = dev;
  8013e7:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8013ed:	83 ec 08             	sub    $0x8,%esp
  8013f0:	53                   	push   %ebx
  8013f1:	ff 75 f0             	pushl  -0x10(%ebp)
  8013f4:	ff 50 14             	call   *0x14(%eax)
  8013f7:	83 c4 10             	add    $0x10,%esp
  8013fa:	eb 05                	jmp    801401 <fstat+0x6f>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8013fc:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801401:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801404:	c9                   	leave  
  801405:	c3                   	ret    

00801406 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801406:	55                   	push   %ebp
  801407:	89 e5                	mov    %esp,%ebp
  801409:	56                   	push   %esi
  80140a:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80140b:	83 ec 08             	sub    $0x8,%esp
  80140e:	6a 00                	push   $0x0
  801410:	ff 75 08             	pushl  0x8(%ebp)
  801413:	e8 8b 01 00 00       	call   8015a3 <open>
  801418:	89 c3                	mov    %eax,%ebx
  80141a:	83 c4 10             	add    $0x10,%esp
  80141d:	85 c0                	test   %eax,%eax
  80141f:	78 1b                	js     80143c <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801421:	83 ec 08             	sub    $0x8,%esp
  801424:	ff 75 0c             	pushl  0xc(%ebp)
  801427:	50                   	push   %eax
  801428:	e8 65 ff ff ff       	call   801392 <fstat>
  80142d:	89 c6                	mov    %eax,%esi
	close(fd);
  80142f:	89 1c 24             	mov    %ebx,(%esp)
  801432:	e8 18 fc ff ff       	call   80104f <close>
	return r;
  801437:	83 c4 10             	add    $0x10,%esp
  80143a:	89 f3                	mov    %esi,%ebx
}
  80143c:	89 d8                	mov    %ebx,%eax
  80143e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801441:	5b                   	pop    %ebx
  801442:	5e                   	pop    %esi
  801443:	c9                   	leave  
  801444:	c3                   	ret    
  801445:	00 00                	add    %al,(%eax)
	...

00801448 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801448:	55                   	push   %ebp
  801449:	89 e5                	mov    %esp,%ebp
  80144b:	56                   	push   %esi
  80144c:	53                   	push   %ebx
  80144d:	89 c3                	mov    %eax,%ebx
  80144f:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  801451:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801458:	75 12                	jne    80146c <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80145a:	83 ec 0c             	sub    $0xc,%esp
  80145d:	6a 01                	push   $0x1
  80145f:	e8 b1 f9 ff ff       	call   800e15 <ipc_find_env>
  801464:	a3 00 40 80 00       	mov    %eax,0x804000
  801469:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80146c:	6a 07                	push   $0x7
  80146e:	68 00 50 80 00       	push   $0x805000
  801473:	53                   	push   %ebx
  801474:	ff 35 00 40 80 00    	pushl  0x804000
  80147a:	e8 41 f9 ff ff       	call   800dc0 <ipc_send>
	
	return ipc_recv(NULL, dstva, NULL);
  80147f:	83 c4 0c             	add    $0xc,%esp
  801482:	6a 00                	push   $0x0
  801484:	56                   	push   %esi
  801485:	6a 00                	push   $0x0
  801487:	e8 8c f8 ff ff       	call   800d18 <ipc_recv>
}
  80148c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80148f:	5b                   	pop    %ebx
  801490:	5e                   	pop    %esi
  801491:	c9                   	leave  
  801492:	c3                   	ret    

00801493 <devfile_stat>:
}


static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801493:	55                   	push   %ebp
  801494:	89 e5                	mov    %esp,%ebp
  801496:	53                   	push   %ebx
  801497:	83 ec 04             	sub    $0x4,%esp
  80149a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80149d:	8b 45 08             	mov    0x8(%ebp),%eax
  8014a0:	8b 40 0c             	mov    0xc(%eax),%eax
  8014a3:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0) {
  8014a8:	ba 00 00 00 00       	mov    $0x0,%edx
  8014ad:	b8 05 00 00 00       	mov    $0x5,%eax
  8014b2:	e8 91 ff ff ff       	call   801448 <fsipc>
  8014b7:	85 c0                	test   %eax,%eax
  8014b9:	78 39                	js     8014f4 <devfile_stat+0x61>
		return r;
	}
	cprintf("OVER\n");
  8014bb:	83 ec 0c             	sub    $0xc,%esp
  8014be:	68 a1 21 80 00       	push   $0x8021a1
  8014c3:	e8 d8 ec ff ff       	call   8001a0 <cprintf>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8014c8:	83 c4 08             	add    $0x8,%esp
  8014cb:	68 00 50 80 00       	push   $0x805000
  8014d0:	53                   	push   %ebx
  8014d1:	e8 80 f2 ff ff       	call   800756 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8014d6:	a1 80 50 80 00       	mov    0x805080,%eax
  8014db:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8014e1:	a1 84 50 80 00       	mov    0x805084,%eax
  8014e6:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8014ec:	83 c4 10             	add    $0x10,%esp
  8014ef:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8014f4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014f7:	c9                   	leave  
  8014f8:	c3                   	ret    

008014f9 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8014f9:	55                   	push   %ebp
  8014fa:	89 e5                	mov    %esp,%ebp
  8014fc:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8014ff:	8b 45 08             	mov    0x8(%ebp),%eax
  801502:	8b 40 0c             	mov    0xc(%eax),%eax
  801505:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80150a:	ba 00 00 00 00       	mov    $0x0,%edx
  80150f:	b8 06 00 00 00       	mov    $0x6,%eax
  801514:	e8 2f ff ff ff       	call   801448 <fsipc>
}
  801519:	c9                   	leave  
  80151a:	c3                   	ret    

0080151b <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  80151b:	55                   	push   %ebp
  80151c:	89 e5                	mov    %esp,%ebp
  80151e:	56                   	push   %esi
  80151f:	53                   	push   %ebx
  801520:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801523:	8b 45 08             	mov    0x8(%ebp),%eax
  801526:	8b 40 0c             	mov    0xc(%eax),%eax
  801529:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  80152e:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801534:	ba 00 00 00 00       	mov    $0x0,%edx
  801539:	b8 03 00 00 00       	mov    $0x3,%eax
  80153e:	e8 05 ff ff ff       	call   801448 <fsipc>
  801543:	89 c3                	mov    %eax,%ebx
  801545:	85 c0                	test   %eax,%eax
  801547:	78 51                	js     80159a <devfile_read+0x7f>
		return r;
	assert(r <= n);
  801549:	39 c6                	cmp    %eax,%esi
  80154b:	73 19                	jae    801566 <devfile_read+0x4b>
  80154d:	68 50 22 80 00       	push   $0x802250
  801552:	68 57 22 80 00       	push   $0x802257
  801557:	68 80 00 00 00       	push   $0x80
  80155c:	68 6c 22 80 00       	push   $0x80226c
  801561:	e8 de 05 00 00       	call   801b44 <_panic>
	assert(r <= PGSIZE);
  801566:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80156b:	7e 19                	jle    801586 <devfile_read+0x6b>
  80156d:	68 77 22 80 00       	push   $0x802277
  801572:	68 57 22 80 00       	push   $0x802257
  801577:	68 81 00 00 00       	push   $0x81
  80157c:	68 6c 22 80 00       	push   $0x80226c
  801581:	e8 be 05 00 00       	call   801b44 <_panic>
	memmove(buf, &fsipcbuf, r);
  801586:	83 ec 04             	sub    $0x4,%esp
  801589:	50                   	push   %eax
  80158a:	68 00 50 80 00       	push   $0x805000
  80158f:	ff 75 0c             	pushl  0xc(%ebp)
  801592:	e8 80 f3 ff ff       	call   800917 <memmove>
	return r;
  801597:	83 c4 10             	add    $0x10,%esp
}
  80159a:	89 d8                	mov    %ebx,%eax
  80159c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80159f:	5b                   	pop    %ebx
  8015a0:	5e                   	pop    %esi
  8015a1:	c9                   	leave  
  8015a2:	c3                   	ret    

008015a3 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8015a3:	55                   	push   %ebp
  8015a4:	89 e5                	mov    %esp,%ebp
  8015a6:	56                   	push   %esi
  8015a7:	53                   	push   %ebx
  8015a8:	83 ec 1c             	sub    $0x1c,%esp
  8015ab:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8015ae:	56                   	push   %esi
  8015af:	e8 50 f1 ff ff       	call   800704 <strlen>
  8015b4:	83 c4 10             	add    $0x10,%esp
  8015b7:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8015bc:	7f 72                	jg     801630 <open+0x8d>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8015be:	83 ec 0c             	sub    $0xc,%esp
  8015c1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015c4:	50                   	push   %eax
  8015c5:	e8 ce f8 ff ff       	call   800e98 <fd_alloc>
  8015ca:	89 c3                	mov    %eax,%ebx
  8015cc:	83 c4 10             	add    $0x10,%esp
  8015cf:	85 c0                	test   %eax,%eax
  8015d1:	78 62                	js     801635 <open+0x92>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8015d3:	83 ec 08             	sub    $0x8,%esp
  8015d6:	56                   	push   %esi
  8015d7:	68 00 50 80 00       	push   $0x805000
  8015dc:	e8 75 f1 ff ff       	call   800756 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8015e1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8015e4:	a3 00 54 80 00       	mov    %eax,0x805400



	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8015e9:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8015ec:	b8 01 00 00 00       	mov    $0x1,%eax
  8015f1:	e8 52 fe ff ff       	call   801448 <fsipc>
  8015f6:	89 c3                	mov    %eax,%ebx
  8015f8:	83 c4 10             	add    $0x10,%esp
  8015fb:	85 c0                	test   %eax,%eax
  8015fd:	79 12                	jns    801611 <open+0x6e>
		fd_close(fd, 0);
  8015ff:	83 ec 08             	sub    $0x8,%esp
  801602:	6a 00                	push   $0x0
  801604:	ff 75 f4             	pushl  -0xc(%ebp)
  801607:	e8 bb f9 ff ff       	call   800fc7 <fd_close>
		return r;
  80160c:	83 c4 10             	add    $0x10,%esp
  80160f:	eb 24                	jmp    801635 <open+0x92>
	}


	cprintf("OPEN\n");
  801611:	83 ec 0c             	sub    $0xc,%esp
  801614:	68 83 22 80 00       	push   $0x802283
  801619:	e8 82 eb ff ff       	call   8001a0 <cprintf>

	return fd2num(fd);
  80161e:	83 c4 04             	add    $0x4,%esp
  801621:	ff 75 f4             	pushl  -0xc(%ebp)
  801624:	e8 47 f8 ff ff       	call   800e70 <fd2num>
  801629:	89 c3                	mov    %eax,%ebx
  80162b:	83 c4 10             	add    $0x10,%esp
  80162e:	eb 05                	jmp    801635 <open+0x92>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801630:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx


	cprintf("OPEN\n");

	return fd2num(fd);
}
  801635:	89 d8                	mov    %ebx,%eax
  801637:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80163a:	5b                   	pop    %ebx
  80163b:	5e                   	pop    %esi
  80163c:	c9                   	leave  
  80163d:	c3                   	ret    
	...

00801640 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801640:	55                   	push   %ebp
  801641:	89 e5                	mov    %esp,%ebp
  801643:	56                   	push   %esi
  801644:	53                   	push   %ebx
  801645:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801648:	83 ec 0c             	sub    $0xc,%esp
  80164b:	ff 75 08             	pushl  0x8(%ebp)
  80164e:	e8 2d f8 ff ff       	call   800e80 <fd2data>
  801653:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  801655:	83 c4 08             	add    $0x8,%esp
  801658:	68 89 22 80 00       	push   $0x802289
  80165d:	56                   	push   %esi
  80165e:	e8 f3 f0 ff ff       	call   800756 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801663:	8b 43 04             	mov    0x4(%ebx),%eax
  801666:	2b 03                	sub    (%ebx),%eax
  801668:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  80166e:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  801675:	00 00 00 
	stat->st_dev = &devpipe;
  801678:	c7 86 88 00 00 00 20 	movl   $0x803020,0x88(%esi)
  80167f:	30 80 00 
	return 0;
}
  801682:	b8 00 00 00 00       	mov    $0x0,%eax
  801687:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80168a:	5b                   	pop    %ebx
  80168b:	5e                   	pop    %esi
  80168c:	c9                   	leave  
  80168d:	c3                   	ret    

0080168e <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  80168e:	55                   	push   %ebp
  80168f:	89 e5                	mov    %esp,%ebp
  801691:	53                   	push   %ebx
  801692:	83 ec 0c             	sub    $0xc,%esp
  801695:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801698:	53                   	push   %ebx
  801699:	6a 00                	push   $0x0
  80169b:	e8 82 f5 ff ff       	call   800c22 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8016a0:	89 1c 24             	mov    %ebx,(%esp)
  8016a3:	e8 d8 f7 ff ff       	call   800e80 <fd2data>
  8016a8:	83 c4 08             	add    $0x8,%esp
  8016ab:	50                   	push   %eax
  8016ac:	6a 00                	push   $0x0
  8016ae:	e8 6f f5 ff ff       	call   800c22 <sys_page_unmap>
}
  8016b3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016b6:	c9                   	leave  
  8016b7:	c3                   	ret    

008016b8 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8016b8:	55                   	push   %ebp
  8016b9:	89 e5                	mov    %esp,%ebp
  8016bb:	57                   	push   %edi
  8016bc:	56                   	push   %esi
  8016bd:	53                   	push   %ebx
  8016be:	83 ec 1c             	sub    $0x1c,%esp
  8016c1:	89 c7                	mov    %eax,%edi
  8016c3:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8016c6:	a1 04 40 80 00       	mov    0x804004,%eax
  8016cb:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  8016ce:	83 ec 0c             	sub    $0xc,%esp
  8016d1:	57                   	push   %edi
  8016d2:	e8 b5 04 00 00       	call   801b8c <pageref>
  8016d7:	89 c6                	mov    %eax,%esi
  8016d9:	83 c4 04             	add    $0x4,%esp
  8016dc:	ff 75 e4             	pushl  -0x1c(%ebp)
  8016df:	e8 a8 04 00 00       	call   801b8c <pageref>
  8016e4:	83 c4 10             	add    $0x10,%esp
  8016e7:	39 c6                	cmp    %eax,%esi
  8016e9:	0f 94 c0             	sete   %al
  8016ec:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  8016ef:	8b 15 04 40 80 00    	mov    0x804004,%edx
  8016f5:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  8016f8:	39 cb                	cmp    %ecx,%ebx
  8016fa:	75 08                	jne    801704 <_pipeisclosed+0x4c>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  8016fc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8016ff:	5b                   	pop    %ebx
  801700:	5e                   	pop    %esi
  801701:	5f                   	pop    %edi
  801702:	c9                   	leave  
  801703:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  801704:	83 f8 01             	cmp    $0x1,%eax
  801707:	75 bd                	jne    8016c6 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801709:	8b 42 58             	mov    0x58(%edx),%eax
  80170c:	6a 01                	push   $0x1
  80170e:	50                   	push   %eax
  80170f:	53                   	push   %ebx
  801710:	68 90 22 80 00       	push   $0x802290
  801715:	e8 86 ea ff ff       	call   8001a0 <cprintf>
  80171a:	83 c4 10             	add    $0x10,%esp
  80171d:	eb a7                	jmp    8016c6 <_pipeisclosed+0xe>

0080171f <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80171f:	55                   	push   %ebp
  801720:	89 e5                	mov    %esp,%ebp
  801722:	57                   	push   %edi
  801723:	56                   	push   %esi
  801724:	53                   	push   %ebx
  801725:	83 ec 28             	sub    $0x28,%esp
  801728:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  80172b:	56                   	push   %esi
  80172c:	e8 4f f7 ff ff       	call   800e80 <fd2data>
  801731:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801733:	83 c4 10             	add    $0x10,%esp
  801736:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80173a:	75 4a                	jne    801786 <devpipe_write+0x67>
  80173c:	bf 00 00 00 00       	mov    $0x0,%edi
  801741:	eb 56                	jmp    801799 <devpipe_write+0x7a>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801743:	89 da                	mov    %ebx,%edx
  801745:	89 f0                	mov    %esi,%eax
  801747:	e8 6c ff ff ff       	call   8016b8 <_pipeisclosed>
  80174c:	85 c0                	test   %eax,%eax
  80174e:	75 4d                	jne    80179d <devpipe_write+0x7e>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801750:	e8 5c f4 ff ff       	call   800bb1 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801755:	8b 43 04             	mov    0x4(%ebx),%eax
  801758:	8b 13                	mov    (%ebx),%edx
  80175a:	83 c2 20             	add    $0x20,%edx
  80175d:	39 d0                	cmp    %edx,%eax
  80175f:	73 e2                	jae    801743 <devpipe_write+0x24>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801761:	89 c2                	mov    %eax,%edx
  801763:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  801769:	79 05                	jns    801770 <devpipe_write+0x51>
  80176b:	4a                   	dec    %edx
  80176c:	83 ca e0             	or     $0xffffffe0,%edx
  80176f:	42                   	inc    %edx
  801770:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801773:	8a 0c 39             	mov    (%ecx,%edi,1),%cl
  801776:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  80177a:	40                   	inc    %eax
  80177b:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80177e:	47                   	inc    %edi
  80177f:	39 7d 10             	cmp    %edi,0x10(%ebp)
  801782:	77 07                	ja     80178b <devpipe_write+0x6c>
  801784:	eb 13                	jmp    801799 <devpipe_write+0x7a>
  801786:	bf 00 00 00 00       	mov    $0x0,%edi
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  80178b:	8b 43 04             	mov    0x4(%ebx),%eax
  80178e:	8b 13                	mov    (%ebx),%edx
  801790:	83 c2 20             	add    $0x20,%edx
  801793:	39 d0                	cmp    %edx,%eax
  801795:	73 ac                	jae    801743 <devpipe_write+0x24>
  801797:	eb c8                	jmp    801761 <devpipe_write+0x42>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801799:	89 f8                	mov    %edi,%eax
  80179b:	eb 05                	jmp    8017a2 <devpipe_write+0x83>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80179d:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  8017a2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8017a5:	5b                   	pop    %ebx
  8017a6:	5e                   	pop    %esi
  8017a7:	5f                   	pop    %edi
  8017a8:	c9                   	leave  
  8017a9:	c3                   	ret    

008017aa <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  8017aa:	55                   	push   %ebp
  8017ab:	89 e5                	mov    %esp,%ebp
  8017ad:	57                   	push   %edi
  8017ae:	56                   	push   %esi
  8017af:	53                   	push   %ebx
  8017b0:	83 ec 18             	sub    $0x18,%esp
  8017b3:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  8017b6:	57                   	push   %edi
  8017b7:	e8 c4 f6 ff ff       	call   800e80 <fd2data>
  8017bc:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8017be:	83 c4 10             	add    $0x10,%esp
  8017c1:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8017c5:	75 44                	jne    80180b <devpipe_read+0x61>
  8017c7:	be 00 00 00 00       	mov    $0x0,%esi
  8017cc:	eb 4f                	jmp    80181d <devpipe_read+0x73>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
				return i;
  8017ce:	89 f0                	mov    %esi,%eax
  8017d0:	eb 54                	jmp    801826 <devpipe_read+0x7c>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  8017d2:	89 da                	mov    %ebx,%edx
  8017d4:	89 f8                	mov    %edi,%eax
  8017d6:	e8 dd fe ff ff       	call   8016b8 <_pipeisclosed>
  8017db:	85 c0                	test   %eax,%eax
  8017dd:	75 42                	jne    801821 <devpipe_read+0x77>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  8017df:	e8 cd f3 ff ff       	call   800bb1 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8017e4:	8b 03                	mov    (%ebx),%eax
  8017e6:	3b 43 04             	cmp    0x4(%ebx),%eax
  8017e9:	74 e7                	je     8017d2 <devpipe_read+0x28>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8017eb:	25 1f 00 00 80       	and    $0x8000001f,%eax
  8017f0:	79 05                	jns    8017f7 <devpipe_read+0x4d>
  8017f2:	48                   	dec    %eax
  8017f3:	83 c8 e0             	or     $0xffffffe0,%eax
  8017f6:	40                   	inc    %eax
  8017f7:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  8017fb:	8b 55 0c             	mov    0xc(%ebp),%edx
  8017fe:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  801801:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801803:	46                   	inc    %esi
  801804:	39 75 10             	cmp    %esi,0x10(%ebp)
  801807:	77 07                	ja     801810 <devpipe_read+0x66>
  801809:	eb 12                	jmp    80181d <devpipe_read+0x73>
  80180b:	be 00 00 00 00       	mov    $0x0,%esi
		while (p->p_rpos == p->p_wpos) {
  801810:	8b 03                	mov    (%ebx),%eax
  801812:	3b 43 04             	cmp    0x4(%ebx),%eax
  801815:	75 d4                	jne    8017eb <devpipe_read+0x41>
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801817:	85 f6                	test   %esi,%esi
  801819:	75 b3                	jne    8017ce <devpipe_read+0x24>
  80181b:	eb b5                	jmp    8017d2 <devpipe_read+0x28>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  80181d:	89 f0                	mov    %esi,%eax
  80181f:	eb 05                	jmp    801826 <devpipe_read+0x7c>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801821:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801826:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801829:	5b                   	pop    %ebx
  80182a:	5e                   	pop    %esi
  80182b:	5f                   	pop    %edi
  80182c:	c9                   	leave  
  80182d:	c3                   	ret    

0080182e <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  80182e:	55                   	push   %ebp
  80182f:	89 e5                	mov    %esp,%ebp
  801831:	57                   	push   %edi
  801832:	56                   	push   %esi
  801833:	53                   	push   %ebx
  801834:	83 ec 28             	sub    $0x28,%esp
  801837:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  80183a:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80183d:	50                   	push   %eax
  80183e:	e8 55 f6 ff ff       	call   800e98 <fd_alloc>
  801843:	89 c3                	mov    %eax,%ebx
  801845:	83 c4 10             	add    $0x10,%esp
  801848:	85 c0                	test   %eax,%eax
  80184a:	0f 88 24 01 00 00    	js     801974 <pipe+0x146>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801850:	83 ec 04             	sub    $0x4,%esp
  801853:	68 07 04 00 00       	push   $0x407
  801858:	ff 75 e4             	pushl  -0x1c(%ebp)
  80185b:	6a 00                	push   $0x0
  80185d:	e8 76 f3 ff ff       	call   800bd8 <sys_page_alloc>
  801862:	89 c3                	mov    %eax,%ebx
  801864:	83 c4 10             	add    $0x10,%esp
  801867:	85 c0                	test   %eax,%eax
  801869:	0f 88 05 01 00 00    	js     801974 <pipe+0x146>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  80186f:	83 ec 0c             	sub    $0xc,%esp
  801872:	8d 45 e0             	lea    -0x20(%ebp),%eax
  801875:	50                   	push   %eax
  801876:	e8 1d f6 ff ff       	call   800e98 <fd_alloc>
  80187b:	89 c3                	mov    %eax,%ebx
  80187d:	83 c4 10             	add    $0x10,%esp
  801880:	85 c0                	test   %eax,%eax
  801882:	0f 88 dc 00 00 00    	js     801964 <pipe+0x136>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801888:	83 ec 04             	sub    $0x4,%esp
  80188b:	68 07 04 00 00       	push   $0x407
  801890:	ff 75 e0             	pushl  -0x20(%ebp)
  801893:	6a 00                	push   $0x0
  801895:	e8 3e f3 ff ff       	call   800bd8 <sys_page_alloc>
  80189a:	89 c3                	mov    %eax,%ebx
  80189c:	83 c4 10             	add    $0x10,%esp
  80189f:	85 c0                	test   %eax,%eax
  8018a1:	0f 88 bd 00 00 00    	js     801964 <pipe+0x136>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  8018a7:	83 ec 0c             	sub    $0xc,%esp
  8018aa:	ff 75 e4             	pushl  -0x1c(%ebp)
  8018ad:	e8 ce f5 ff ff       	call   800e80 <fd2data>
  8018b2:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8018b4:	83 c4 0c             	add    $0xc,%esp
  8018b7:	68 07 04 00 00       	push   $0x407
  8018bc:	50                   	push   %eax
  8018bd:	6a 00                	push   $0x0
  8018bf:	e8 14 f3 ff ff       	call   800bd8 <sys_page_alloc>
  8018c4:	89 c3                	mov    %eax,%ebx
  8018c6:	83 c4 10             	add    $0x10,%esp
  8018c9:	85 c0                	test   %eax,%eax
  8018cb:	0f 88 83 00 00 00    	js     801954 <pipe+0x126>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8018d1:	83 ec 0c             	sub    $0xc,%esp
  8018d4:	ff 75 e0             	pushl  -0x20(%ebp)
  8018d7:	e8 a4 f5 ff ff       	call   800e80 <fd2data>
  8018dc:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  8018e3:	50                   	push   %eax
  8018e4:	6a 00                	push   $0x0
  8018e6:	56                   	push   %esi
  8018e7:	6a 00                	push   $0x0
  8018e9:	e8 0e f3 ff ff       	call   800bfc <sys_page_map>
  8018ee:	89 c3                	mov    %eax,%ebx
  8018f0:	83 c4 20             	add    $0x20,%esp
  8018f3:	85 c0                	test   %eax,%eax
  8018f5:	78 4f                	js     801946 <pipe+0x118>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  8018f7:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8018fd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801900:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801902:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801905:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  80190c:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801912:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801915:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801917:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80191a:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801921:	83 ec 0c             	sub    $0xc,%esp
  801924:	ff 75 e4             	pushl  -0x1c(%ebp)
  801927:	e8 44 f5 ff ff       	call   800e70 <fd2num>
  80192c:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  80192e:	83 c4 04             	add    $0x4,%esp
  801931:	ff 75 e0             	pushl  -0x20(%ebp)
  801934:	e8 37 f5 ff ff       	call   800e70 <fd2num>
  801939:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  80193c:	83 c4 10             	add    $0x10,%esp
  80193f:	bb 00 00 00 00       	mov    $0x0,%ebx
  801944:	eb 2e                	jmp    801974 <pipe+0x146>

    err3:
	sys_page_unmap(0, va);
  801946:	83 ec 08             	sub    $0x8,%esp
  801949:	56                   	push   %esi
  80194a:	6a 00                	push   $0x0
  80194c:	e8 d1 f2 ff ff       	call   800c22 <sys_page_unmap>
  801951:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801954:	83 ec 08             	sub    $0x8,%esp
  801957:	ff 75 e0             	pushl  -0x20(%ebp)
  80195a:	6a 00                	push   $0x0
  80195c:	e8 c1 f2 ff ff       	call   800c22 <sys_page_unmap>
  801961:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801964:	83 ec 08             	sub    $0x8,%esp
  801967:	ff 75 e4             	pushl  -0x1c(%ebp)
  80196a:	6a 00                	push   $0x0
  80196c:	e8 b1 f2 ff ff       	call   800c22 <sys_page_unmap>
  801971:	83 c4 10             	add    $0x10,%esp
    err:
	return r;
}
  801974:	89 d8                	mov    %ebx,%eax
  801976:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801979:	5b                   	pop    %ebx
  80197a:	5e                   	pop    %esi
  80197b:	5f                   	pop    %edi
  80197c:	c9                   	leave  
  80197d:	c3                   	ret    

0080197e <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  80197e:	55                   	push   %ebp
  80197f:	89 e5                	mov    %esp,%ebp
  801981:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801984:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801987:	50                   	push   %eax
  801988:	ff 75 08             	pushl  0x8(%ebp)
  80198b:	e8 7b f5 ff ff       	call   800f0b <fd_lookup>
  801990:	83 c4 10             	add    $0x10,%esp
  801993:	85 c0                	test   %eax,%eax
  801995:	78 18                	js     8019af <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801997:	83 ec 0c             	sub    $0xc,%esp
  80199a:	ff 75 f4             	pushl  -0xc(%ebp)
  80199d:	e8 de f4 ff ff       	call   800e80 <fd2data>
	return _pipeisclosed(fd, p);
  8019a2:	89 c2                	mov    %eax,%edx
  8019a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019a7:	e8 0c fd ff ff       	call   8016b8 <_pipeisclosed>
  8019ac:	83 c4 10             	add    $0x10,%esp
}
  8019af:	c9                   	leave  
  8019b0:	c3                   	ret    
  8019b1:	00 00                	add    %al,(%eax)
	...

008019b4 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  8019b4:	55                   	push   %ebp
  8019b5:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  8019b7:	b8 00 00 00 00       	mov    $0x0,%eax
  8019bc:	c9                   	leave  
  8019bd:	c3                   	ret    

008019be <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8019be:	55                   	push   %ebp
  8019bf:	89 e5                	mov    %esp,%ebp
  8019c1:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  8019c4:	68 a8 22 80 00       	push   $0x8022a8
  8019c9:	ff 75 0c             	pushl  0xc(%ebp)
  8019cc:	e8 85 ed ff ff       	call   800756 <strcpy>
	return 0;
}
  8019d1:	b8 00 00 00 00       	mov    $0x0,%eax
  8019d6:	c9                   	leave  
  8019d7:	c3                   	ret    

008019d8 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8019d8:	55                   	push   %ebp
  8019d9:	89 e5                	mov    %esp,%ebp
  8019db:	57                   	push   %edi
  8019dc:	56                   	push   %esi
  8019dd:	53                   	push   %ebx
  8019de:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8019e4:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8019e8:	74 45                	je     801a2f <devcons_write+0x57>
  8019ea:	b8 00 00 00 00       	mov    $0x0,%eax
  8019ef:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8019f4:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  8019fa:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8019fd:	29 c3                	sub    %eax,%ebx
		if (m > sizeof(buf) - 1)
  8019ff:	83 fb 7f             	cmp    $0x7f,%ebx
  801a02:	76 05                	jbe    801a09 <devcons_write+0x31>
			m = sizeof(buf) - 1;
  801a04:	bb 7f 00 00 00       	mov    $0x7f,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  801a09:	83 ec 04             	sub    $0x4,%esp
  801a0c:	53                   	push   %ebx
  801a0d:	03 45 0c             	add    0xc(%ebp),%eax
  801a10:	50                   	push   %eax
  801a11:	57                   	push   %edi
  801a12:	e8 00 ef ff ff       	call   800917 <memmove>
		sys_cputs(buf, m);
  801a17:	83 c4 08             	add    $0x8,%esp
  801a1a:	53                   	push   %ebx
  801a1b:	57                   	push   %edi
  801a1c:	e8 00 f1 ff ff       	call   800b21 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801a21:	01 de                	add    %ebx,%esi
  801a23:	89 f0                	mov    %esi,%eax
  801a25:	83 c4 10             	add    $0x10,%esp
  801a28:	3b 75 10             	cmp    0x10(%ebp),%esi
  801a2b:	72 cd                	jb     8019fa <devcons_write+0x22>
  801a2d:	eb 05                	jmp    801a34 <devcons_write+0x5c>
  801a2f:	be 00 00 00 00       	mov    $0x0,%esi
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801a34:	89 f0                	mov    %esi,%eax
  801a36:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a39:	5b                   	pop    %ebx
  801a3a:	5e                   	pop    %esi
  801a3b:	5f                   	pop    %edi
  801a3c:	c9                   	leave  
  801a3d:	c3                   	ret    

00801a3e <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801a3e:	55                   	push   %ebp
  801a3f:	89 e5                	mov    %esp,%ebp
  801a41:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  801a44:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801a48:	75 07                	jne    801a51 <devcons_read+0x13>
  801a4a:	eb 25                	jmp    801a71 <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801a4c:	e8 60 f1 ff ff       	call   800bb1 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801a51:	e8 f1 f0 ff ff       	call   800b47 <sys_cgetc>
  801a56:	85 c0                	test   %eax,%eax
  801a58:	74 f2                	je     801a4c <devcons_read+0xe>
  801a5a:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  801a5c:	85 c0                	test   %eax,%eax
  801a5e:	78 1d                	js     801a7d <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801a60:	83 f8 04             	cmp    $0x4,%eax
  801a63:	74 13                	je     801a78 <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  801a65:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a68:	88 10                	mov    %dl,(%eax)
	return 1;
  801a6a:	b8 01 00 00 00       	mov    $0x1,%eax
  801a6f:	eb 0c                	jmp    801a7d <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  801a71:	b8 00 00 00 00       	mov    $0x0,%eax
  801a76:	eb 05                	jmp    801a7d <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801a78:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801a7d:	c9                   	leave  
  801a7e:	c3                   	ret    

00801a7f <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801a7f:	55                   	push   %ebp
  801a80:	89 e5                	mov    %esp,%ebp
  801a82:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801a85:	8b 45 08             	mov    0x8(%ebp),%eax
  801a88:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801a8b:	6a 01                	push   $0x1
  801a8d:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801a90:	50                   	push   %eax
  801a91:	e8 8b f0 ff ff       	call   800b21 <sys_cputs>
  801a96:	83 c4 10             	add    $0x10,%esp
}
  801a99:	c9                   	leave  
  801a9a:	c3                   	ret    

00801a9b <getchar>:

int
getchar(void)
{
  801a9b:	55                   	push   %ebp
  801a9c:	89 e5                	mov    %esp,%ebp
  801a9e:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801aa1:	6a 01                	push   $0x1
  801aa3:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801aa6:	50                   	push   %eax
  801aa7:	6a 00                	push   $0x0
  801aa9:	e8 de f6 ff ff       	call   80118c <read>
	if (r < 0)
  801aae:	83 c4 10             	add    $0x10,%esp
  801ab1:	85 c0                	test   %eax,%eax
  801ab3:	78 0f                	js     801ac4 <getchar+0x29>
		return r;
	if (r < 1)
  801ab5:	85 c0                	test   %eax,%eax
  801ab7:	7e 06                	jle    801abf <getchar+0x24>
		return -E_EOF;
	return c;
  801ab9:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801abd:	eb 05                	jmp    801ac4 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801abf:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801ac4:	c9                   	leave  
  801ac5:	c3                   	ret    

00801ac6 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801ac6:	55                   	push   %ebp
  801ac7:	89 e5                	mov    %esp,%ebp
  801ac9:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801acc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801acf:	50                   	push   %eax
  801ad0:	ff 75 08             	pushl  0x8(%ebp)
  801ad3:	e8 33 f4 ff ff       	call   800f0b <fd_lookup>
  801ad8:	83 c4 10             	add    $0x10,%esp
  801adb:	85 c0                	test   %eax,%eax
  801add:	78 11                	js     801af0 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801adf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ae2:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801ae8:	39 10                	cmp    %edx,(%eax)
  801aea:	0f 94 c0             	sete   %al
  801aed:	0f b6 c0             	movzbl %al,%eax
}
  801af0:	c9                   	leave  
  801af1:	c3                   	ret    

00801af2 <opencons>:

int
opencons(void)
{
  801af2:	55                   	push   %ebp
  801af3:	89 e5                	mov    %esp,%ebp
  801af5:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801af8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801afb:	50                   	push   %eax
  801afc:	e8 97 f3 ff ff       	call   800e98 <fd_alloc>
  801b01:	83 c4 10             	add    $0x10,%esp
  801b04:	85 c0                	test   %eax,%eax
  801b06:	78 3a                	js     801b42 <opencons+0x50>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801b08:	83 ec 04             	sub    $0x4,%esp
  801b0b:	68 07 04 00 00       	push   $0x407
  801b10:	ff 75 f4             	pushl  -0xc(%ebp)
  801b13:	6a 00                	push   $0x0
  801b15:	e8 be f0 ff ff       	call   800bd8 <sys_page_alloc>
  801b1a:	83 c4 10             	add    $0x10,%esp
  801b1d:	85 c0                	test   %eax,%eax
  801b1f:	78 21                	js     801b42 <opencons+0x50>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801b21:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801b27:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b2a:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801b2c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b2f:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801b36:	83 ec 0c             	sub    $0xc,%esp
  801b39:	50                   	push   %eax
  801b3a:	e8 31 f3 ff ff       	call   800e70 <fd2num>
  801b3f:	83 c4 10             	add    $0x10,%esp
}
  801b42:	c9                   	leave  
  801b43:	c3                   	ret    

00801b44 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801b44:	55                   	push   %ebp
  801b45:	89 e5                	mov    %esp,%ebp
  801b47:	56                   	push   %esi
  801b48:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801b49:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801b4c:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  801b52:	e8 36 f0 ff ff       	call   800b8d <sys_getenvid>
  801b57:	83 ec 0c             	sub    $0xc,%esp
  801b5a:	ff 75 0c             	pushl  0xc(%ebp)
  801b5d:	ff 75 08             	pushl  0x8(%ebp)
  801b60:	53                   	push   %ebx
  801b61:	50                   	push   %eax
  801b62:	68 b4 22 80 00       	push   $0x8022b4
  801b67:	e8 34 e6 ff ff       	call   8001a0 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801b6c:	83 c4 18             	add    $0x18,%esp
  801b6f:	56                   	push   %esi
  801b70:	ff 75 10             	pushl  0x10(%ebp)
  801b73:	e8 d7 e5 ff ff       	call   80014f <vcprintf>
	cprintf("\n");
  801b78:	c7 04 24 87 22 80 00 	movl   $0x802287,(%esp)
  801b7f:	e8 1c e6 ff ff       	call   8001a0 <cprintf>
  801b84:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801b87:	cc                   	int3   
  801b88:	eb fd                	jmp    801b87 <_panic+0x43>
	...

00801b8c <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801b8c:	55                   	push   %ebp
  801b8d:	89 e5                	mov    %esp,%ebp
  801b8f:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b92:	89 c2                	mov    %eax,%edx
  801b94:	c1 ea 16             	shr    $0x16,%edx
  801b97:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801b9e:	f6 c2 01             	test   $0x1,%dl
  801ba1:	74 1e                	je     801bc1 <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  801ba3:	c1 e8 0c             	shr    $0xc,%eax
  801ba6:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801bad:	a8 01                	test   $0x1,%al
  801baf:	74 17                	je     801bc8 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801bb1:	c1 e8 0c             	shr    $0xc,%eax
  801bb4:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  801bbb:	ef 
  801bbc:	0f b7 c0             	movzwl %ax,%eax
  801bbf:	eb 0c                	jmp    801bcd <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  801bc1:	b8 00 00 00 00       	mov    $0x0,%eax
  801bc6:	eb 05                	jmp    801bcd <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  801bc8:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  801bcd:	c9                   	leave  
  801bce:	c3                   	ret    
	...

00801bd0 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  801bd0:	55                   	push   %ebp
  801bd1:	89 e5                	mov    %esp,%ebp
  801bd3:	57                   	push   %edi
  801bd4:	56                   	push   %esi
  801bd5:	83 ec 10             	sub    $0x10,%esp
  801bd8:	8b 7d 08             	mov    0x8(%ebp),%edi
  801bdb:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  801bde:	89 7d f0             	mov    %edi,-0x10(%ebp)
  801be1:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  801be4:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  801be7:	8b 45 14             	mov    0x14(%ebp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  801bea:	85 c0                	test   %eax,%eax
  801bec:	75 2e                	jne    801c1c <__udivdi3+0x4c>
    {
      if (d0 > n1)
  801bee:	39 f1                	cmp    %esi,%ecx
  801bf0:	77 5a                	ja     801c4c <__udivdi3+0x7c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  801bf2:	85 c9                	test   %ecx,%ecx
  801bf4:	75 0b                	jne    801c01 <__udivdi3+0x31>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  801bf6:	b8 01 00 00 00       	mov    $0x1,%eax
  801bfb:	31 d2                	xor    %edx,%edx
  801bfd:	f7 f1                	div    %ecx
  801bff:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  801c01:	31 d2                	xor    %edx,%edx
  801c03:	89 f0                	mov    %esi,%eax
  801c05:	f7 f1                	div    %ecx
  801c07:	89 c6                	mov    %eax,%esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801c09:	89 f8                	mov    %edi,%eax
  801c0b:	f7 f1                	div    %ecx
  801c0d:	89 c7                	mov    %eax,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801c0f:	89 f8                	mov    %edi,%eax
  801c11:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801c13:	83 c4 10             	add    $0x10,%esp
  801c16:	5e                   	pop    %esi
  801c17:	5f                   	pop    %edi
  801c18:	c9                   	leave  
  801c19:	c3                   	ret    
  801c1a:	66 90                	xchg   %ax,%ax
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801c1c:	39 f0                	cmp    %esi,%eax
  801c1e:	77 1c                	ja     801c3c <__udivdi3+0x6c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  801c20:	0f bd f8             	bsr    %eax,%edi
	  if (bm == 0)
  801c23:	83 f7 1f             	xor    $0x1f,%edi
  801c26:	75 3c                	jne    801c64 <__udivdi3+0x94>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801c28:	39 f0                	cmp    %esi,%eax
  801c2a:	0f 82 90 00 00 00    	jb     801cc0 <__udivdi3+0xf0>
  801c30:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801c33:	39 55 f4             	cmp    %edx,-0xc(%ebp)
  801c36:	0f 86 84 00 00 00    	jbe    801cc0 <__udivdi3+0xf0>
  801c3c:	31 f6                	xor    %esi,%esi
  801c3e:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801c40:	89 f8                	mov    %edi,%eax
  801c42:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801c44:	83 c4 10             	add    $0x10,%esp
  801c47:	5e                   	pop    %esi
  801c48:	5f                   	pop    %edi
  801c49:	c9                   	leave  
  801c4a:	c3                   	ret    
  801c4b:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801c4c:	89 f2                	mov    %esi,%edx
  801c4e:	89 f8                	mov    %edi,%eax
  801c50:	f7 f1                	div    %ecx
  801c52:	89 c7                	mov    %eax,%edi
  801c54:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801c56:	89 f8                	mov    %edi,%eax
  801c58:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801c5a:	83 c4 10             	add    $0x10,%esp
  801c5d:	5e                   	pop    %esi
  801c5e:	5f                   	pop    %edi
  801c5f:	c9                   	leave  
  801c60:	c3                   	ret    
  801c61:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  801c64:	89 f9                	mov    %edi,%ecx
  801c66:	d3 e0                	shl    %cl,%eax
  801c68:	89 45 e8             	mov    %eax,-0x18(%ebp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  801c6b:	b8 20 00 00 00       	mov    $0x20,%eax
  801c70:	29 f8                	sub    %edi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  801c72:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801c75:	88 c1                	mov    %al,%cl
  801c77:	d3 ea                	shr    %cl,%edx
  801c79:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  801c7c:	09 ca                	or     %ecx,%edx
  801c7e:	89 55 ec             	mov    %edx,-0x14(%ebp)
	      d0 = d0 << bm;
  801c81:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801c84:	89 f9                	mov    %edi,%ecx
  801c86:	d3 e2                	shl    %cl,%edx
  801c88:	89 55 f4             	mov    %edx,-0xc(%ebp)
	      n2 = n1 >> b;
  801c8b:	89 f2                	mov    %esi,%edx
  801c8d:	88 c1                	mov    %al,%cl
  801c8f:	d3 ea                	shr    %cl,%edx
  801c91:	89 55 e8             	mov    %edx,-0x18(%ebp)
	      n1 = (n1 << bm) | (n0 >> b);
  801c94:	89 f2                	mov    %esi,%edx
  801c96:	89 f9                	mov    %edi,%ecx
  801c98:	d3 e2                	shl    %cl,%edx
  801c9a:	8b 75 f0             	mov    -0x10(%ebp),%esi
  801c9d:	88 c1                	mov    %al,%cl
  801c9f:	d3 ee                	shr    %cl,%esi
  801ca1:	09 d6                	or     %edx,%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  801ca3:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  801ca6:	89 f0                	mov    %esi,%eax
  801ca8:	89 ca                	mov    %ecx,%edx
  801caa:	f7 75 ec             	divl   -0x14(%ebp)
  801cad:	89 d1                	mov    %edx,%ecx
  801caf:	89 c6                	mov    %eax,%esi
	      umul_ppmm (m1, m0, q0, d0);
  801cb1:	f7 65 f4             	mull   -0xc(%ebp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801cb4:	39 d1                	cmp    %edx,%ecx
  801cb6:	72 28                	jb     801ce0 <__udivdi3+0x110>
  801cb8:	74 1a                	je     801cd4 <__udivdi3+0x104>
  801cba:	89 f7                	mov    %esi,%edi
  801cbc:	31 f6                	xor    %esi,%esi
  801cbe:	eb 80                	jmp    801c40 <__udivdi3+0x70>
	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  801cc0:	31 f6                	xor    %esi,%esi
  801cc2:	bf 01 00 00 00       	mov    $0x1,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801cc7:	89 f8                	mov    %edi,%eax
  801cc9:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801ccb:	83 c4 10             	add    $0x10,%esp
  801cce:	5e                   	pop    %esi
  801ccf:	5f                   	pop    %edi
  801cd0:	c9                   	leave  
  801cd1:	c3                   	ret    
  801cd2:	66 90                	xchg   %ax,%ax

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  801cd4:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801cd7:	89 f9                	mov    %edi,%ecx
  801cd9:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801cdb:	39 c2                	cmp    %eax,%edx
  801cdd:	73 db                	jae    801cba <__udivdi3+0xea>
  801cdf:	90                   	nop
		{
		  q0--;
  801ce0:	8d 7e ff             	lea    -0x1(%esi),%edi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  801ce3:	31 f6                	xor    %esi,%esi
  801ce5:	e9 56 ff ff ff       	jmp    801c40 <__udivdi3+0x70>
	...

00801cec <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  801cec:	55                   	push   %ebp
  801ced:	89 e5                	mov    %esp,%ebp
  801cef:	57                   	push   %edi
  801cf0:	56                   	push   %esi
  801cf1:	83 ec 20             	sub    $0x20,%esp
  801cf4:	8b 45 08             	mov    0x8(%ebp),%eax
  801cf7:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  801cfa:	89 45 e8             	mov    %eax,-0x18(%ebp)
  801cfd:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  801d00:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  801d03:	8b 7d 14             	mov    0x14(%ebp),%edi
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  801d06:	89 45 f0             	mov    %eax,-0x10(%ebp)
  n1 = nn.s.high;
  801d09:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  801d0b:	85 ff                	test   %edi,%edi
  801d0d:	75 15                	jne    801d24 <__umoddi3+0x38>
    {
      if (d0 > n1)
  801d0f:	39 f1                	cmp    %esi,%ecx
  801d11:	0f 86 99 00 00 00    	jbe    801db0 <__umoddi3+0xc4>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801d17:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  801d19:	89 d0                	mov    %edx,%eax
  801d1b:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801d1d:	83 c4 20             	add    $0x20,%esp
  801d20:	5e                   	pop    %esi
  801d21:	5f                   	pop    %edi
  801d22:	c9                   	leave  
  801d23:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801d24:	39 f7                	cmp    %esi,%edi
  801d26:	0f 87 a4 00 00 00    	ja     801dd0 <__umoddi3+0xe4>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  801d2c:	0f bd c7             	bsr    %edi,%eax
	  if (bm == 0)
  801d2f:	83 f0 1f             	xor    $0x1f,%eax
  801d32:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801d35:	0f 84 a1 00 00 00    	je     801ddc <__umoddi3+0xf0>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  801d3b:	89 f8                	mov    %edi,%eax
  801d3d:	8a 4d ec             	mov    -0x14(%ebp),%cl
  801d40:	d3 e0                	shl    %cl,%eax
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  801d42:	bf 20 00 00 00       	mov    $0x20,%edi
  801d47:	2b 7d ec             	sub    -0x14(%ebp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  801d4a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801d4d:	89 f9                	mov    %edi,%ecx
  801d4f:	d3 ea                	shr    %cl,%edx
  801d51:	09 c2                	or     %eax,%edx
  801d53:	89 55 f0             	mov    %edx,-0x10(%ebp)
	      d0 = d0 << bm;
  801d56:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d59:	8a 4d ec             	mov    -0x14(%ebp),%cl
  801d5c:	d3 e0                	shl    %cl,%eax
  801d5e:	89 45 f4             	mov    %eax,-0xc(%ebp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  801d61:	89 f2                	mov    %esi,%edx
  801d63:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  801d65:	8b 45 e8             	mov    -0x18(%ebp),%eax
  801d68:	d3 e0                	shl    %cl,%eax
  801d6a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  801d6d:	8b 45 e8             	mov    -0x18(%ebp),%eax
  801d70:	89 f9                	mov    %edi,%ecx
  801d72:	d3 e8                	shr    %cl,%eax
  801d74:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  801d76:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  801d78:	89 f2                	mov    %esi,%edx
  801d7a:	f7 75 f0             	divl   -0x10(%ebp)
  801d7d:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  801d7f:	f7 65 f4             	mull   -0xc(%ebp)
  801d82:	89 55 e8             	mov    %edx,-0x18(%ebp)
  801d85:	89 c1                	mov    %eax,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801d87:	39 d6                	cmp    %edx,%esi
  801d89:	72 71                	jb     801dfc <__umoddi3+0x110>
  801d8b:	74 7f                	je     801e0c <__umoddi3+0x120>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  801d8d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801d90:	29 c8                	sub    %ecx,%eax
  801d92:	19 d6                	sbb    %edx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  801d94:	8a 4d ec             	mov    -0x14(%ebp),%cl
  801d97:	d3 e8                	shr    %cl,%eax
  801d99:	89 f2                	mov    %esi,%edx
  801d9b:	89 f9                	mov    %edi,%ecx
  801d9d:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  801d9f:	09 d0                	or     %edx,%eax
  801da1:	89 f2                	mov    %esi,%edx
  801da3:	8a 4d ec             	mov    -0x14(%ebp),%cl
  801da6:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801da8:	83 c4 20             	add    $0x20,%esp
  801dab:	5e                   	pop    %esi
  801dac:	5f                   	pop    %edi
  801dad:	c9                   	leave  
  801dae:	c3                   	ret    
  801daf:	90                   	nop
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  801db0:	85 c9                	test   %ecx,%ecx
  801db2:	75 0b                	jne    801dbf <__umoddi3+0xd3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  801db4:	b8 01 00 00 00       	mov    $0x1,%eax
  801db9:	31 d2                	xor    %edx,%edx
  801dbb:	f7 f1                	div    %ecx
  801dbd:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  801dbf:	89 f0                	mov    %esi,%eax
  801dc1:	31 d2                	xor    %edx,%edx
  801dc3:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801dc5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801dc8:	f7 f1                	div    %ecx
  801dca:	e9 4a ff ff ff       	jmp    801d19 <__umoddi3+0x2d>
  801dcf:	90                   	nop
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  801dd0:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801dd2:	83 c4 20             	add    $0x20,%esp
  801dd5:	5e                   	pop    %esi
  801dd6:	5f                   	pop    %edi
  801dd7:	c9                   	leave  
  801dd8:	c3                   	ret    
  801dd9:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801ddc:	39 f7                	cmp    %esi,%edi
  801dde:	72 05                	jb     801de5 <__umoddi3+0xf9>
  801de0:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
  801de3:	77 0c                	ja     801df1 <__umoddi3+0x105>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  801de5:	89 f2                	mov    %esi,%edx
  801de7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801dea:	29 c8                	sub    %ecx,%eax
  801dec:	19 fa                	sbb    %edi,%edx
  801dee:	89 45 f0             	mov    %eax,-0x10(%ebp)

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  801df1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801df4:	83 c4 20             	add    $0x20,%esp
  801df7:	5e                   	pop    %esi
  801df8:	5f                   	pop    %edi
  801df9:	c9                   	leave  
  801dfa:	c3                   	ret    
  801dfb:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  801dfc:	8b 55 e8             	mov    -0x18(%ebp),%edx
  801dff:	89 c1                	mov    %eax,%ecx
  801e01:	2b 4d f4             	sub    -0xc(%ebp),%ecx
  801e04:	1b 55 f0             	sbb    -0x10(%ebp),%edx
  801e07:	eb 84                	jmp    801d8d <__umoddi3+0xa1>
  801e09:	8d 76 00             	lea    0x0(%esi),%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801e0c:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801e0f:	72 eb                	jb     801dfc <__umoddi3+0x110>
  801e11:	89 f2                	mov    %esi,%edx
  801e13:	e9 75 ff ff ff       	jmp    801d8d <__umoddi3+0xa1>
