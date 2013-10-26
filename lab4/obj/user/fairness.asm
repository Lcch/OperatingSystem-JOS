
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
  80003c:	e8 3c 0b 00 00       	call   800b7d <sys_getenvid>
  800041:	89 c3                	mov    %eax,%ebx

	if (thisenv == &envs[1]) {
  800043:	81 3d 04 20 80 00 80 	cmpl   $0xeec00080,0x802004
  80004a:	00 c0 ee 
  80004d:	75 26                	jne    800075 <umain+0x41>
		while (1) {
			ipc_recv(&who, 0, 0);
  80004f:	8d 75 f4             	lea    -0xc(%ebp),%esi
  800052:	83 ec 04             	sub    $0x4,%esp
  800055:	6a 00                	push   $0x0
  800057:	6a 00                	push   $0x0
  800059:	56                   	push   %esi
  80005a:	e8 89 0c 00 00       	call   800ce8 <ipc_recv>
			cprintf("%x recv from %x\n", id, who);
  80005f:	83 c4 0c             	add    $0xc,%esp
  800062:	ff 75 f4             	pushl  -0xc(%ebp)
  800065:	53                   	push   %ebx
  800066:	68 a0 10 80 00       	push   $0x8010a0
  80006b:	e8 20 01 00 00       	call   800190 <cprintf>
  800070:	83 c4 10             	add    $0x10,%esp
  800073:	eb dd                	jmp    800052 <umain+0x1e>
		}
	} else {
		cprintf("%x loop sending to %x\n", id, envs[1].env_id);
  800075:	83 ec 04             	sub    $0x4,%esp
  800078:	ff 35 c8 00 c0 ee    	pushl  0xeec000c8
  80007e:	50                   	push   %eax
  80007f:	68 b1 10 80 00       	push   $0x8010b1
  800084:	e8 07 01 00 00       	call   800190 <cprintf>
  800089:	83 c4 10             	add    $0x10,%esp
		while (1)
			ipc_send(envs[1].env_id, 0, 0, 0);
  80008c:	6a 00                	push   $0x0
  80008e:	6a 00                	push   $0x0
  800090:	6a 00                	push   $0x0
  800092:	ff 35 c8 00 c0 ee    	pushl  0xeec000c8
  800098:	e8 c0 0c 00 00       	call   800d5d <ipc_send>
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
  8000af:	e8 c9 0a 00 00       	call   800b7d <sys_getenvid>
  8000b4:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000b9:	c1 e0 07             	shl    $0x7,%eax
  8000bc:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000c1:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000c6:	85 f6                	test   %esi,%esi
  8000c8:	7e 07                	jle    8000d1 <libmain+0x2d>
		binaryname = argv[0];
  8000ca:	8b 03                	mov    (%ebx),%eax
  8000cc:	a3 00 20 80 00       	mov    %eax,0x802000
	// call user main routine
	umain(argc, argv);
  8000d1:	83 ec 08             	sub    $0x8,%esp
  8000d4:	53                   	push   %ebx
  8000d5:	56                   	push   %esi
  8000d6:	e8 59 ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  8000db:	e8 0c 00 00 00       	call   8000ec <exit>
  8000e0:	83 c4 10             	add    $0x10,%esp
}
  8000e3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000e6:	5b                   	pop    %ebx
  8000e7:	5e                   	pop    %esi
  8000e8:	c9                   	leave  
  8000e9:	c3                   	ret    
	...

008000ec <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000ec:	55                   	push   %ebp
  8000ed:	89 e5                	mov    %esp,%ebp
  8000ef:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  8000f2:	6a 00                	push   $0x0
  8000f4:	e8 62 0a 00 00       	call   800b5b <sys_env_destroy>
  8000f9:	83 c4 10             	add    $0x10,%esp
}
  8000fc:	c9                   	leave  
  8000fd:	c3                   	ret    
	...

00800100 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800100:	55                   	push   %ebp
  800101:	89 e5                	mov    %esp,%ebp
  800103:	53                   	push   %ebx
  800104:	83 ec 04             	sub    $0x4,%esp
  800107:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80010a:	8b 03                	mov    (%ebx),%eax
  80010c:	8b 55 08             	mov    0x8(%ebp),%edx
  80010f:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  800113:	40                   	inc    %eax
  800114:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  800116:	3d ff 00 00 00       	cmp    $0xff,%eax
  80011b:	75 1a                	jne    800137 <putch+0x37>
		sys_cputs(b->buf, b->idx);
  80011d:	83 ec 08             	sub    $0x8,%esp
  800120:	68 ff 00 00 00       	push   $0xff
  800125:	8d 43 08             	lea    0x8(%ebx),%eax
  800128:	50                   	push   %eax
  800129:	e8 e3 09 00 00       	call   800b11 <sys_cputs>
		b->idx = 0;
  80012e:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800134:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800137:	ff 43 04             	incl   0x4(%ebx)
}
  80013a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80013d:	c9                   	leave  
  80013e:	c3                   	ret    

0080013f <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80013f:	55                   	push   %ebp
  800140:	89 e5                	mov    %esp,%ebp
  800142:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800148:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80014f:	00 00 00 
	b.cnt = 0;
  800152:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800159:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80015c:	ff 75 0c             	pushl  0xc(%ebp)
  80015f:	ff 75 08             	pushl  0x8(%ebp)
  800162:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800168:	50                   	push   %eax
  800169:	68 00 01 80 00       	push   $0x800100
  80016e:	e8 82 01 00 00       	call   8002f5 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800173:	83 c4 08             	add    $0x8,%esp
  800176:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80017c:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800182:	50                   	push   %eax
  800183:	e8 89 09 00 00       	call   800b11 <sys_cputs>

	return b.cnt;
}
  800188:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80018e:	c9                   	leave  
  80018f:	c3                   	ret    

00800190 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800190:	55                   	push   %ebp
  800191:	89 e5                	mov    %esp,%ebp
  800193:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800196:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800199:	50                   	push   %eax
  80019a:	ff 75 08             	pushl  0x8(%ebp)
  80019d:	e8 9d ff ff ff       	call   80013f <vcprintf>
	va_end(ap);

	return cnt;
}
  8001a2:	c9                   	leave  
  8001a3:	c3                   	ret    

008001a4 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001a4:	55                   	push   %ebp
  8001a5:	89 e5                	mov    %esp,%ebp
  8001a7:	57                   	push   %edi
  8001a8:	56                   	push   %esi
  8001a9:	53                   	push   %ebx
  8001aa:	83 ec 2c             	sub    $0x2c,%esp
  8001ad:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8001b0:	89 d6                	mov    %edx,%esi
  8001b2:	8b 45 08             	mov    0x8(%ebp),%eax
  8001b5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001b8:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001bb:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8001be:	8b 45 10             	mov    0x10(%ebp),%eax
  8001c1:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8001c4:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001c7:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8001ca:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  8001d1:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
  8001d4:	72 0c                	jb     8001e2 <printnum+0x3e>
  8001d6:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  8001d9:	76 07                	jbe    8001e2 <printnum+0x3e>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8001db:	4b                   	dec    %ebx
  8001dc:	85 db                	test   %ebx,%ebx
  8001de:	7f 31                	jg     800211 <printnum+0x6d>
  8001e0:	eb 3f                	jmp    800221 <printnum+0x7d>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001e2:	83 ec 0c             	sub    $0xc,%esp
  8001e5:	57                   	push   %edi
  8001e6:	4b                   	dec    %ebx
  8001e7:	53                   	push   %ebx
  8001e8:	50                   	push   %eax
  8001e9:	83 ec 08             	sub    $0x8,%esp
  8001ec:	ff 75 d4             	pushl  -0x2c(%ebp)
  8001ef:	ff 75 d0             	pushl  -0x30(%ebp)
  8001f2:	ff 75 dc             	pushl  -0x24(%ebp)
  8001f5:	ff 75 d8             	pushl  -0x28(%ebp)
  8001f8:	e8 47 0c 00 00       	call   800e44 <__udivdi3>
  8001fd:	83 c4 18             	add    $0x18,%esp
  800200:	52                   	push   %edx
  800201:	50                   	push   %eax
  800202:	89 f2                	mov    %esi,%edx
  800204:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800207:	e8 98 ff ff ff       	call   8001a4 <printnum>
  80020c:	83 c4 20             	add    $0x20,%esp
  80020f:	eb 10                	jmp    800221 <printnum+0x7d>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800211:	83 ec 08             	sub    $0x8,%esp
  800214:	56                   	push   %esi
  800215:	57                   	push   %edi
  800216:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800219:	4b                   	dec    %ebx
  80021a:	83 c4 10             	add    $0x10,%esp
  80021d:	85 db                	test   %ebx,%ebx
  80021f:	7f f0                	jg     800211 <printnum+0x6d>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800221:	83 ec 08             	sub    $0x8,%esp
  800224:	56                   	push   %esi
  800225:	83 ec 04             	sub    $0x4,%esp
  800228:	ff 75 d4             	pushl  -0x2c(%ebp)
  80022b:	ff 75 d0             	pushl  -0x30(%ebp)
  80022e:	ff 75 dc             	pushl  -0x24(%ebp)
  800231:	ff 75 d8             	pushl  -0x28(%ebp)
  800234:	e8 27 0d 00 00       	call   800f60 <__umoddi3>
  800239:	83 c4 14             	add    $0x14,%esp
  80023c:	0f be 80 d2 10 80 00 	movsbl 0x8010d2(%eax),%eax
  800243:	50                   	push   %eax
  800244:	ff 55 e4             	call   *-0x1c(%ebp)
  800247:	83 c4 10             	add    $0x10,%esp
}
  80024a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80024d:	5b                   	pop    %ebx
  80024e:	5e                   	pop    %esi
  80024f:	5f                   	pop    %edi
  800250:	c9                   	leave  
  800251:	c3                   	ret    

00800252 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800252:	55                   	push   %ebp
  800253:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800255:	83 fa 01             	cmp    $0x1,%edx
  800258:	7e 0e                	jle    800268 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80025a:	8b 10                	mov    (%eax),%edx
  80025c:	8d 4a 08             	lea    0x8(%edx),%ecx
  80025f:	89 08                	mov    %ecx,(%eax)
  800261:	8b 02                	mov    (%edx),%eax
  800263:	8b 52 04             	mov    0x4(%edx),%edx
  800266:	eb 22                	jmp    80028a <getuint+0x38>
	else if (lflag)
  800268:	85 d2                	test   %edx,%edx
  80026a:	74 10                	je     80027c <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80026c:	8b 10                	mov    (%eax),%edx
  80026e:	8d 4a 04             	lea    0x4(%edx),%ecx
  800271:	89 08                	mov    %ecx,(%eax)
  800273:	8b 02                	mov    (%edx),%eax
  800275:	ba 00 00 00 00       	mov    $0x0,%edx
  80027a:	eb 0e                	jmp    80028a <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80027c:	8b 10                	mov    (%eax),%edx
  80027e:	8d 4a 04             	lea    0x4(%edx),%ecx
  800281:	89 08                	mov    %ecx,(%eax)
  800283:	8b 02                	mov    (%edx),%eax
  800285:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80028a:	c9                   	leave  
  80028b:	c3                   	ret    

0080028c <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  80028c:	55                   	push   %ebp
  80028d:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80028f:	83 fa 01             	cmp    $0x1,%edx
  800292:	7e 0e                	jle    8002a2 <getint+0x16>
		return va_arg(*ap, long long);
  800294:	8b 10                	mov    (%eax),%edx
  800296:	8d 4a 08             	lea    0x8(%edx),%ecx
  800299:	89 08                	mov    %ecx,(%eax)
  80029b:	8b 02                	mov    (%edx),%eax
  80029d:	8b 52 04             	mov    0x4(%edx),%edx
  8002a0:	eb 1a                	jmp    8002bc <getint+0x30>
	else if (lflag)
  8002a2:	85 d2                	test   %edx,%edx
  8002a4:	74 0c                	je     8002b2 <getint+0x26>
		return va_arg(*ap, long);
  8002a6:	8b 10                	mov    (%eax),%edx
  8002a8:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002ab:	89 08                	mov    %ecx,(%eax)
  8002ad:	8b 02                	mov    (%edx),%eax
  8002af:	99                   	cltd   
  8002b0:	eb 0a                	jmp    8002bc <getint+0x30>
	else
		return va_arg(*ap, int);
  8002b2:	8b 10                	mov    (%eax),%edx
  8002b4:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002b7:	89 08                	mov    %ecx,(%eax)
  8002b9:	8b 02                	mov    (%edx),%eax
  8002bb:	99                   	cltd   
}
  8002bc:	c9                   	leave  
  8002bd:	c3                   	ret    

008002be <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002be:	55                   	push   %ebp
  8002bf:	89 e5                	mov    %esp,%ebp
  8002c1:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002c4:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  8002c7:	8b 10                	mov    (%eax),%edx
  8002c9:	3b 50 04             	cmp    0x4(%eax),%edx
  8002cc:	73 08                	jae    8002d6 <sprintputch+0x18>
		*b->buf++ = ch;
  8002ce:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8002d1:	88 0a                	mov    %cl,(%edx)
  8002d3:	42                   	inc    %edx
  8002d4:	89 10                	mov    %edx,(%eax)
}
  8002d6:	c9                   	leave  
  8002d7:	c3                   	ret    

008002d8 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8002d8:	55                   	push   %ebp
  8002d9:	89 e5                	mov    %esp,%ebp
  8002db:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8002de:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002e1:	50                   	push   %eax
  8002e2:	ff 75 10             	pushl  0x10(%ebp)
  8002e5:	ff 75 0c             	pushl  0xc(%ebp)
  8002e8:	ff 75 08             	pushl  0x8(%ebp)
  8002eb:	e8 05 00 00 00       	call   8002f5 <vprintfmt>
	va_end(ap);
  8002f0:	83 c4 10             	add    $0x10,%esp
}
  8002f3:	c9                   	leave  
  8002f4:	c3                   	ret    

008002f5 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8002f5:	55                   	push   %ebp
  8002f6:	89 e5                	mov    %esp,%ebp
  8002f8:	57                   	push   %edi
  8002f9:	56                   	push   %esi
  8002fa:	53                   	push   %ebx
  8002fb:	83 ec 2c             	sub    $0x2c,%esp
  8002fe:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800301:	8b 75 10             	mov    0x10(%ebp),%esi
  800304:	eb 13                	jmp    800319 <vprintfmt+0x24>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800306:	85 c0                	test   %eax,%eax
  800308:	0f 84 6d 03 00 00    	je     80067b <vprintfmt+0x386>
				return;
			putch(ch, putdat);
  80030e:	83 ec 08             	sub    $0x8,%esp
  800311:	57                   	push   %edi
  800312:	50                   	push   %eax
  800313:	ff 55 08             	call   *0x8(%ebp)
  800316:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800319:	0f b6 06             	movzbl (%esi),%eax
  80031c:	46                   	inc    %esi
  80031d:	83 f8 25             	cmp    $0x25,%eax
  800320:	75 e4                	jne    800306 <vprintfmt+0x11>
  800322:	c6 45 dc 20          	movb   $0x20,-0x24(%ebp)
  800326:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  80032d:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  800334:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  80033b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800340:	eb 28                	jmp    80036a <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800342:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800344:	c6 45 dc 2d          	movb   $0x2d,-0x24(%ebp)
  800348:	eb 20                	jmp    80036a <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80034a:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80034c:	c6 45 dc 30          	movb   $0x30,-0x24(%ebp)
  800350:	eb 18                	jmp    80036a <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800352:	89 de                	mov    %ebx,%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800354:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  80035b:	eb 0d                	jmp    80036a <vprintfmt+0x75>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  80035d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800360:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800363:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80036a:	8a 06                	mov    (%esi),%al
  80036c:	0f b6 d0             	movzbl %al,%edx
  80036f:	8d 5e 01             	lea    0x1(%esi),%ebx
  800372:	83 e8 23             	sub    $0x23,%eax
  800375:	3c 55                	cmp    $0x55,%al
  800377:	0f 87 e0 02 00 00    	ja     80065d <vprintfmt+0x368>
  80037d:	0f b6 c0             	movzbl %al,%eax
  800380:	ff 24 85 a0 11 80 00 	jmp    *0x8011a0(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800387:	83 ea 30             	sub    $0x30,%edx
  80038a:	89 55 d4             	mov    %edx,-0x2c(%ebp)
				ch = *fmt;
  80038d:	0f be 03             	movsbl (%ebx),%eax
				if (ch < '0' || ch > '9')
  800390:	8d 50 d0             	lea    -0x30(%eax),%edx
  800393:	83 fa 09             	cmp    $0x9,%edx
  800396:	77 44                	ja     8003dc <vprintfmt+0xe7>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800398:	89 de                	mov    %ebx,%esi
  80039a:	8b 55 d4             	mov    -0x2c(%ebp),%edx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80039d:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
  80039e:	8d 14 92             	lea    (%edx,%edx,4),%edx
  8003a1:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
  8003a5:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8003a8:	8d 58 d0             	lea    -0x30(%eax),%ebx
  8003ab:	83 fb 09             	cmp    $0x9,%ebx
  8003ae:	76 ed                	jbe    80039d <vprintfmt+0xa8>
  8003b0:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  8003b3:	eb 29                	jmp    8003de <vprintfmt+0xe9>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003b5:	8b 45 14             	mov    0x14(%ebp),%eax
  8003b8:	8d 50 04             	lea    0x4(%eax),%edx
  8003bb:	89 55 14             	mov    %edx,0x14(%ebp)
  8003be:	8b 00                	mov    (%eax),%eax
  8003c0:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003c3:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8003c5:	eb 17                	jmp    8003de <vprintfmt+0xe9>

		case '.':
			if (width < 0)
  8003c7:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8003cb:	78 85                	js     800352 <vprintfmt+0x5d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003cd:	89 de                	mov    %ebx,%esi
  8003cf:	eb 99                	jmp    80036a <vprintfmt+0x75>
  8003d1:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8003d3:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  8003da:	eb 8e                	jmp    80036a <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003dc:	89 de                	mov    %ebx,%esi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  8003de:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8003e2:	79 86                	jns    80036a <vprintfmt+0x75>
  8003e4:	e9 74 ff ff ff       	jmp    80035d <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8003e9:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ea:	89 de                	mov    %ebx,%esi
  8003ec:	e9 79 ff ff ff       	jmp    80036a <vprintfmt+0x75>
  8003f1:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8003f4:	8b 45 14             	mov    0x14(%ebp),%eax
  8003f7:	8d 50 04             	lea    0x4(%eax),%edx
  8003fa:	89 55 14             	mov    %edx,0x14(%ebp)
  8003fd:	83 ec 08             	sub    $0x8,%esp
  800400:	57                   	push   %edi
  800401:	ff 30                	pushl  (%eax)
  800403:	ff 55 08             	call   *0x8(%ebp)
			break;
  800406:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800409:	8b 75 d8             	mov    -0x28(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80040c:	e9 08 ff ff ff       	jmp    800319 <vprintfmt+0x24>
  800411:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  800414:	8b 45 14             	mov    0x14(%ebp),%eax
  800417:	8d 50 04             	lea    0x4(%eax),%edx
  80041a:	89 55 14             	mov    %edx,0x14(%ebp)
  80041d:	8b 00                	mov    (%eax),%eax
  80041f:	85 c0                	test   %eax,%eax
  800421:	79 02                	jns    800425 <vprintfmt+0x130>
  800423:	f7 d8                	neg    %eax
  800425:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800427:	83 f8 08             	cmp    $0x8,%eax
  80042a:	7f 0b                	jg     800437 <vprintfmt+0x142>
  80042c:	8b 04 85 00 13 80 00 	mov    0x801300(,%eax,4),%eax
  800433:	85 c0                	test   %eax,%eax
  800435:	75 1a                	jne    800451 <vprintfmt+0x15c>
				printfmt(putch, putdat, "error %d", err);
  800437:	52                   	push   %edx
  800438:	68 ea 10 80 00       	push   $0x8010ea
  80043d:	57                   	push   %edi
  80043e:	ff 75 08             	pushl  0x8(%ebp)
  800441:	e8 92 fe ff ff       	call   8002d8 <printfmt>
  800446:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800449:	8b 75 d8             	mov    -0x28(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80044c:	e9 c8 fe ff ff       	jmp    800319 <vprintfmt+0x24>
			else
				printfmt(putch, putdat, "%s", p);
  800451:	50                   	push   %eax
  800452:	68 f3 10 80 00       	push   $0x8010f3
  800457:	57                   	push   %edi
  800458:	ff 75 08             	pushl  0x8(%ebp)
  80045b:	e8 78 fe ff ff       	call   8002d8 <printfmt>
  800460:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800463:	8b 75 d8             	mov    -0x28(%ebp),%esi
  800466:	e9 ae fe ff ff       	jmp    800319 <vprintfmt+0x24>
  80046b:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  80046e:	89 de                	mov    %ebx,%esi
  800470:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  800473:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800476:	8b 45 14             	mov    0x14(%ebp),%eax
  800479:	8d 50 04             	lea    0x4(%eax),%edx
  80047c:	89 55 14             	mov    %edx,0x14(%ebp)
  80047f:	8b 00                	mov    (%eax),%eax
  800481:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800484:	85 c0                	test   %eax,%eax
  800486:	75 07                	jne    80048f <vprintfmt+0x19a>
				p = "(null)";
  800488:	c7 45 d0 e3 10 80 00 	movl   $0x8010e3,-0x30(%ebp)
			if (width > 0 && padc != '-')
  80048f:	85 db                	test   %ebx,%ebx
  800491:	7e 42                	jle    8004d5 <vprintfmt+0x1e0>
  800493:	80 7d dc 2d          	cmpb   $0x2d,-0x24(%ebp)
  800497:	74 3c                	je     8004d5 <vprintfmt+0x1e0>
				for (width -= strnlen(p, precision); width > 0; width--)
  800499:	83 ec 08             	sub    $0x8,%esp
  80049c:	51                   	push   %ecx
  80049d:	ff 75 d0             	pushl  -0x30(%ebp)
  8004a0:	e8 6f 02 00 00       	call   800714 <strnlen>
  8004a5:	29 c3                	sub    %eax,%ebx
  8004a7:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8004aa:	83 c4 10             	add    $0x10,%esp
  8004ad:	85 db                	test   %ebx,%ebx
  8004af:	7e 24                	jle    8004d5 <vprintfmt+0x1e0>
					putch(padc, putdat);
  8004b1:	0f be 5d dc          	movsbl -0x24(%ebp),%ebx
  8004b5:	89 75 dc             	mov    %esi,-0x24(%ebp)
  8004b8:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  8004bb:	83 ec 08             	sub    $0x8,%esp
  8004be:	57                   	push   %edi
  8004bf:	53                   	push   %ebx
  8004c0:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004c3:	4e                   	dec    %esi
  8004c4:	83 c4 10             	add    $0x10,%esp
  8004c7:	85 f6                	test   %esi,%esi
  8004c9:	7f f0                	jg     8004bb <vprintfmt+0x1c6>
  8004cb:	8b 75 dc             	mov    -0x24(%ebp),%esi
  8004ce:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004d5:	8b 55 d0             	mov    -0x30(%ebp),%edx
  8004d8:	0f be 02             	movsbl (%edx),%eax
  8004db:	85 c0                	test   %eax,%eax
  8004dd:	75 47                	jne    800526 <vprintfmt+0x231>
  8004df:	eb 37                	jmp    800518 <vprintfmt+0x223>
				if (altflag && (ch < ' ' || ch > '~'))
  8004e1:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004e5:	74 16                	je     8004fd <vprintfmt+0x208>
  8004e7:	8d 50 e0             	lea    -0x20(%eax),%edx
  8004ea:	83 fa 5e             	cmp    $0x5e,%edx
  8004ed:	76 0e                	jbe    8004fd <vprintfmt+0x208>
					putch('?', putdat);
  8004ef:	83 ec 08             	sub    $0x8,%esp
  8004f2:	57                   	push   %edi
  8004f3:	6a 3f                	push   $0x3f
  8004f5:	ff 55 08             	call   *0x8(%ebp)
  8004f8:	83 c4 10             	add    $0x10,%esp
  8004fb:	eb 0b                	jmp    800508 <vprintfmt+0x213>
				else
					putch(ch, putdat);
  8004fd:	83 ec 08             	sub    $0x8,%esp
  800500:	57                   	push   %edi
  800501:	50                   	push   %eax
  800502:	ff 55 08             	call   *0x8(%ebp)
  800505:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800508:	ff 4d e4             	decl   -0x1c(%ebp)
  80050b:	0f be 03             	movsbl (%ebx),%eax
  80050e:	85 c0                	test   %eax,%eax
  800510:	74 03                	je     800515 <vprintfmt+0x220>
  800512:	43                   	inc    %ebx
  800513:	eb 1b                	jmp    800530 <vprintfmt+0x23b>
  800515:	8b 75 dc             	mov    -0x24(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800518:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80051c:	7f 1e                	jg     80053c <vprintfmt+0x247>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80051e:	8b 75 d8             	mov    -0x28(%ebp),%esi
  800521:	e9 f3 fd ff ff       	jmp    800319 <vprintfmt+0x24>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800526:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800529:	43                   	inc    %ebx
  80052a:	89 75 dc             	mov    %esi,-0x24(%ebp)
  80052d:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  800530:	85 f6                	test   %esi,%esi
  800532:	78 ad                	js     8004e1 <vprintfmt+0x1ec>
  800534:	4e                   	dec    %esi
  800535:	79 aa                	jns    8004e1 <vprintfmt+0x1ec>
  800537:	8b 75 dc             	mov    -0x24(%ebp),%esi
  80053a:	eb dc                	jmp    800518 <vprintfmt+0x223>
  80053c:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80053f:	83 ec 08             	sub    $0x8,%esp
  800542:	57                   	push   %edi
  800543:	6a 20                	push   $0x20
  800545:	ff 55 08             	call   *0x8(%ebp)
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800548:	4b                   	dec    %ebx
  800549:	83 c4 10             	add    $0x10,%esp
  80054c:	85 db                	test   %ebx,%ebx
  80054e:	7f ef                	jg     80053f <vprintfmt+0x24a>
  800550:	e9 c4 fd ff ff       	jmp    800319 <vprintfmt+0x24>
  800555:	89 5d d8             	mov    %ebx,-0x28(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800558:	89 ca                	mov    %ecx,%edx
  80055a:	8d 45 14             	lea    0x14(%ebp),%eax
  80055d:	e8 2a fd ff ff       	call   80028c <getint>
  800562:	89 c3                	mov    %eax,%ebx
  800564:	89 d6                	mov    %edx,%esi
			if ((long long) num < 0) {
  800566:	85 d2                	test   %edx,%edx
  800568:	78 0a                	js     800574 <vprintfmt+0x27f>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80056a:	b8 0a 00 00 00       	mov    $0xa,%eax
  80056f:	e9 b0 00 00 00       	jmp    800624 <vprintfmt+0x32f>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  800574:	83 ec 08             	sub    $0x8,%esp
  800577:	57                   	push   %edi
  800578:	6a 2d                	push   $0x2d
  80057a:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  80057d:	f7 db                	neg    %ebx
  80057f:	83 d6 00             	adc    $0x0,%esi
  800582:	f7 de                	neg    %esi
  800584:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800587:	b8 0a 00 00 00       	mov    $0xa,%eax
  80058c:	e9 93 00 00 00       	jmp    800624 <vprintfmt+0x32f>
  800591:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800594:	89 ca                	mov    %ecx,%edx
  800596:	8d 45 14             	lea    0x14(%ebp),%eax
  800599:	e8 b4 fc ff ff       	call   800252 <getuint>
  80059e:	89 c3                	mov    %eax,%ebx
  8005a0:	89 d6                	mov    %edx,%esi
			base = 10;
  8005a2:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  8005a7:	eb 7b                	jmp    800624 <vprintfmt+0x32f>
  8005a9:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
  8005ac:	89 ca                	mov    %ecx,%edx
  8005ae:	8d 45 14             	lea    0x14(%ebp),%eax
  8005b1:	e8 d6 fc ff ff       	call   80028c <getint>
  8005b6:	89 c3                	mov    %eax,%ebx
  8005b8:	89 d6                	mov    %edx,%esi
            if ((long long) num < 0) {
  8005ba:	85 d2                	test   %edx,%edx
  8005bc:	78 07                	js     8005c5 <vprintfmt+0x2d0>
                putch('-', putdat);
                num = -(long long) num;
            }
            base = 8;
  8005be:	b8 08 00 00 00       	mov    $0x8,%eax
  8005c3:	eb 5f                	jmp    800624 <vprintfmt+0x32f>
		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
            if ((long long) num < 0) {
                putch('-', putdat);
  8005c5:	83 ec 08             	sub    $0x8,%esp
  8005c8:	57                   	push   %edi
  8005c9:	6a 2d                	push   $0x2d
  8005cb:	ff 55 08             	call   *0x8(%ebp)
                num = -(long long) num;
  8005ce:	f7 db                	neg    %ebx
  8005d0:	83 d6 00             	adc    $0x0,%esi
  8005d3:	f7 de                	neg    %esi
  8005d5:	83 c4 10             	add    $0x10,%esp
            }
            base = 8;
  8005d8:	b8 08 00 00 00       	mov    $0x8,%eax
  8005dd:	eb 45                	jmp    800624 <vprintfmt+0x32f>
  8005df:	89 5d d8             	mov    %ebx,-0x28(%ebp)
            goto number;

        // pointer
		case 'p':
			putch('0', putdat);
  8005e2:	83 ec 08             	sub    $0x8,%esp
  8005e5:	57                   	push   %edi
  8005e6:	6a 30                	push   $0x30
  8005e8:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8005eb:	83 c4 08             	add    $0x8,%esp
  8005ee:	57                   	push   %edi
  8005ef:	6a 78                	push   $0x78
  8005f1:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8005f4:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f7:	8d 50 04             	lea    0x4(%eax),%edx
  8005fa:	89 55 14             	mov    %edx,0x14(%ebp)

        // pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8005fd:	8b 18                	mov    (%eax),%ebx
  8005ff:	be 00 00 00 00       	mov    $0x0,%esi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800604:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800607:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  80060c:	eb 16                	jmp    800624 <vprintfmt+0x32f>
  80060e:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800611:	89 ca                	mov    %ecx,%edx
  800613:	8d 45 14             	lea    0x14(%ebp),%eax
  800616:	e8 37 fc ff ff       	call   800252 <getuint>
  80061b:	89 c3                	mov    %eax,%ebx
  80061d:	89 d6                	mov    %edx,%esi
			base = 16;
  80061f:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800624:	83 ec 0c             	sub    $0xc,%esp
  800627:	0f be 55 dc          	movsbl -0x24(%ebp),%edx
  80062b:	52                   	push   %edx
  80062c:	ff 75 e4             	pushl  -0x1c(%ebp)
  80062f:	50                   	push   %eax
  800630:	56                   	push   %esi
  800631:	53                   	push   %ebx
  800632:	89 fa                	mov    %edi,%edx
  800634:	8b 45 08             	mov    0x8(%ebp),%eax
  800637:	e8 68 fb ff ff       	call   8001a4 <printnum>
			break;
  80063c:	83 c4 20             	add    $0x20,%esp
  80063f:	8b 75 d8             	mov    -0x28(%ebp),%esi
  800642:	e9 d2 fc ff ff       	jmp    800319 <vprintfmt+0x24>
  800647:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80064a:	83 ec 08             	sub    $0x8,%esp
  80064d:	57                   	push   %edi
  80064e:	52                   	push   %edx
  80064f:	ff 55 08             	call   *0x8(%ebp)
			break;
  800652:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800655:	8b 75 d8             	mov    -0x28(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800658:	e9 bc fc ff ff       	jmp    800319 <vprintfmt+0x24>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80065d:	83 ec 08             	sub    $0x8,%esp
  800660:	57                   	push   %edi
  800661:	6a 25                	push   $0x25
  800663:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800666:	83 c4 10             	add    $0x10,%esp
  800669:	eb 02                	jmp    80066d <vprintfmt+0x378>
  80066b:	89 c6                	mov    %eax,%esi
  80066d:	8d 46 ff             	lea    -0x1(%esi),%eax
  800670:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800674:	75 f5                	jne    80066b <vprintfmt+0x376>
  800676:	e9 9e fc ff ff       	jmp    800319 <vprintfmt+0x24>
				/* do nothing */;
			break;
		}
	}
}
  80067b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80067e:	5b                   	pop    %ebx
  80067f:	5e                   	pop    %esi
  800680:	5f                   	pop    %edi
  800681:	c9                   	leave  
  800682:	c3                   	ret    

00800683 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800683:	55                   	push   %ebp
  800684:	89 e5                	mov    %esp,%ebp
  800686:	83 ec 18             	sub    $0x18,%esp
  800689:	8b 45 08             	mov    0x8(%ebp),%eax
  80068c:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80068f:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800692:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800696:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800699:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8006a0:	85 c0                	test   %eax,%eax
  8006a2:	74 26                	je     8006ca <vsnprintf+0x47>
  8006a4:	85 d2                	test   %edx,%edx
  8006a6:	7e 29                	jle    8006d1 <vsnprintf+0x4e>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8006a8:	ff 75 14             	pushl  0x14(%ebp)
  8006ab:	ff 75 10             	pushl  0x10(%ebp)
  8006ae:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8006b1:	50                   	push   %eax
  8006b2:	68 be 02 80 00       	push   $0x8002be
  8006b7:	e8 39 fc ff ff       	call   8002f5 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8006bc:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8006bf:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8006c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006c5:	83 c4 10             	add    $0x10,%esp
  8006c8:	eb 0c                	jmp    8006d6 <vsnprintf+0x53>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8006ca:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8006cf:	eb 05                	jmp    8006d6 <vsnprintf+0x53>
  8006d1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8006d6:	c9                   	leave  
  8006d7:	c3                   	ret    

008006d8 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8006d8:	55                   	push   %ebp
  8006d9:	89 e5                	mov    %esp,%ebp
  8006db:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8006de:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8006e1:	50                   	push   %eax
  8006e2:	ff 75 10             	pushl  0x10(%ebp)
  8006e5:	ff 75 0c             	pushl  0xc(%ebp)
  8006e8:	ff 75 08             	pushl  0x8(%ebp)
  8006eb:	e8 93 ff ff ff       	call   800683 <vsnprintf>
	va_end(ap);

	return rc;
}
  8006f0:	c9                   	leave  
  8006f1:	c3                   	ret    
	...

008006f4 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8006f4:	55                   	push   %ebp
  8006f5:	89 e5                	mov    %esp,%ebp
  8006f7:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8006fa:	80 3a 00             	cmpb   $0x0,(%edx)
  8006fd:	74 0e                	je     80070d <strlen+0x19>
  8006ff:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800704:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800705:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800709:	75 f9                	jne    800704 <strlen+0x10>
  80070b:	eb 05                	jmp    800712 <strlen+0x1e>
  80070d:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800712:	c9                   	leave  
  800713:	c3                   	ret    

00800714 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800714:	55                   	push   %ebp
  800715:	89 e5                	mov    %esp,%ebp
  800717:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80071a:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80071d:	85 d2                	test   %edx,%edx
  80071f:	74 17                	je     800738 <strnlen+0x24>
  800721:	80 39 00             	cmpb   $0x0,(%ecx)
  800724:	74 19                	je     80073f <strnlen+0x2b>
  800726:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  80072b:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80072c:	39 d0                	cmp    %edx,%eax
  80072e:	74 14                	je     800744 <strnlen+0x30>
  800730:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800734:	75 f5                	jne    80072b <strnlen+0x17>
  800736:	eb 0c                	jmp    800744 <strnlen+0x30>
  800738:	b8 00 00 00 00       	mov    $0x0,%eax
  80073d:	eb 05                	jmp    800744 <strnlen+0x30>
  80073f:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800744:	c9                   	leave  
  800745:	c3                   	ret    

00800746 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800746:	55                   	push   %ebp
  800747:	89 e5                	mov    %esp,%ebp
  800749:	53                   	push   %ebx
  80074a:	8b 45 08             	mov    0x8(%ebp),%eax
  80074d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800750:	ba 00 00 00 00       	mov    $0x0,%edx
  800755:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  800758:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  80075b:	42                   	inc    %edx
  80075c:	84 c9                	test   %cl,%cl
  80075e:	75 f5                	jne    800755 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800760:	5b                   	pop    %ebx
  800761:	c9                   	leave  
  800762:	c3                   	ret    

00800763 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800763:	55                   	push   %ebp
  800764:	89 e5                	mov    %esp,%ebp
  800766:	53                   	push   %ebx
  800767:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80076a:	53                   	push   %ebx
  80076b:	e8 84 ff ff ff       	call   8006f4 <strlen>
  800770:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800773:	ff 75 0c             	pushl  0xc(%ebp)
  800776:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  800779:	50                   	push   %eax
  80077a:	e8 c7 ff ff ff       	call   800746 <strcpy>
	return dst;
}
  80077f:	89 d8                	mov    %ebx,%eax
  800781:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800784:	c9                   	leave  
  800785:	c3                   	ret    

00800786 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800786:	55                   	push   %ebp
  800787:	89 e5                	mov    %esp,%ebp
  800789:	56                   	push   %esi
  80078a:	53                   	push   %ebx
  80078b:	8b 45 08             	mov    0x8(%ebp),%eax
  80078e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800791:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800794:	85 f6                	test   %esi,%esi
  800796:	74 15                	je     8007ad <strncpy+0x27>
  800798:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  80079d:	8a 1a                	mov    (%edx),%bl
  80079f:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007a2:	80 3a 01             	cmpb   $0x1,(%edx)
  8007a5:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007a8:	41                   	inc    %ecx
  8007a9:	39 ce                	cmp    %ecx,%esi
  8007ab:	77 f0                	ja     80079d <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8007ad:	5b                   	pop    %ebx
  8007ae:	5e                   	pop    %esi
  8007af:	c9                   	leave  
  8007b0:	c3                   	ret    

008007b1 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8007b1:	55                   	push   %ebp
  8007b2:	89 e5                	mov    %esp,%ebp
  8007b4:	57                   	push   %edi
  8007b5:	56                   	push   %esi
  8007b6:	53                   	push   %ebx
  8007b7:	8b 7d 08             	mov    0x8(%ebp),%edi
  8007ba:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8007bd:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007c0:	85 f6                	test   %esi,%esi
  8007c2:	74 32                	je     8007f6 <strlcpy+0x45>
		while (--size > 0 && *src != '\0')
  8007c4:	83 fe 01             	cmp    $0x1,%esi
  8007c7:	74 22                	je     8007eb <strlcpy+0x3a>
  8007c9:	8a 0b                	mov    (%ebx),%cl
  8007cb:	84 c9                	test   %cl,%cl
  8007cd:	74 20                	je     8007ef <strlcpy+0x3e>
  8007cf:	89 f8                	mov    %edi,%eax
  8007d1:	ba 00 00 00 00       	mov    $0x0,%edx
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
  8007d6:	83 ee 02             	sub    $0x2,%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8007d9:	88 08                	mov    %cl,(%eax)
  8007db:	40                   	inc    %eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8007dc:	39 f2                	cmp    %esi,%edx
  8007de:	74 11                	je     8007f1 <strlcpy+0x40>
  8007e0:	8a 4c 13 01          	mov    0x1(%ebx,%edx,1),%cl
  8007e4:	42                   	inc    %edx
  8007e5:	84 c9                	test   %cl,%cl
  8007e7:	75 f0                	jne    8007d9 <strlcpy+0x28>
  8007e9:	eb 06                	jmp    8007f1 <strlcpy+0x40>
  8007eb:	89 f8                	mov    %edi,%eax
  8007ed:	eb 02                	jmp    8007f1 <strlcpy+0x40>
  8007ef:	89 f8                	mov    %edi,%eax
			*dst++ = *src++;
		*dst = '\0';
  8007f1:	c6 00 00             	movb   $0x0,(%eax)
  8007f4:	eb 02                	jmp    8007f8 <strlcpy+0x47>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007f6:	89 f8                	mov    %edi,%eax
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
		*dst = '\0';
	}
	return dst - dst_in;
  8007f8:	29 f8                	sub    %edi,%eax
}
  8007fa:	5b                   	pop    %ebx
  8007fb:	5e                   	pop    %esi
  8007fc:	5f                   	pop    %edi
  8007fd:	c9                   	leave  
  8007fe:	c3                   	ret    

008007ff <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8007ff:	55                   	push   %ebp
  800800:	89 e5                	mov    %esp,%ebp
  800802:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800805:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800808:	8a 01                	mov    (%ecx),%al
  80080a:	84 c0                	test   %al,%al
  80080c:	74 10                	je     80081e <strcmp+0x1f>
  80080e:	3a 02                	cmp    (%edx),%al
  800810:	75 0c                	jne    80081e <strcmp+0x1f>
		p++, q++;
  800812:	41                   	inc    %ecx
  800813:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800814:	8a 01                	mov    (%ecx),%al
  800816:	84 c0                	test   %al,%al
  800818:	74 04                	je     80081e <strcmp+0x1f>
  80081a:	3a 02                	cmp    (%edx),%al
  80081c:	74 f4                	je     800812 <strcmp+0x13>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80081e:	0f b6 c0             	movzbl %al,%eax
  800821:	0f b6 12             	movzbl (%edx),%edx
  800824:	29 d0                	sub    %edx,%eax
}
  800826:	c9                   	leave  
  800827:	c3                   	ret    

00800828 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800828:	55                   	push   %ebp
  800829:	89 e5                	mov    %esp,%ebp
  80082b:	53                   	push   %ebx
  80082c:	8b 55 08             	mov    0x8(%ebp),%edx
  80082f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800832:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  800835:	85 c0                	test   %eax,%eax
  800837:	74 1b                	je     800854 <strncmp+0x2c>
  800839:	8a 1a                	mov    (%edx),%bl
  80083b:	84 db                	test   %bl,%bl
  80083d:	74 24                	je     800863 <strncmp+0x3b>
  80083f:	3a 19                	cmp    (%ecx),%bl
  800841:	75 20                	jne    800863 <strncmp+0x3b>
  800843:	48                   	dec    %eax
  800844:	74 15                	je     80085b <strncmp+0x33>
		n--, p++, q++;
  800846:	42                   	inc    %edx
  800847:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800848:	8a 1a                	mov    (%edx),%bl
  80084a:	84 db                	test   %bl,%bl
  80084c:	74 15                	je     800863 <strncmp+0x3b>
  80084e:	3a 19                	cmp    (%ecx),%bl
  800850:	74 f1                	je     800843 <strncmp+0x1b>
  800852:	eb 0f                	jmp    800863 <strncmp+0x3b>
		n--, p++, q++;
	if (n == 0)
		return 0;
  800854:	b8 00 00 00 00       	mov    $0x0,%eax
  800859:	eb 05                	jmp    800860 <strncmp+0x38>
  80085b:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800860:	5b                   	pop    %ebx
  800861:	c9                   	leave  
  800862:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800863:	0f b6 02             	movzbl (%edx),%eax
  800866:	0f b6 11             	movzbl (%ecx),%edx
  800869:	29 d0                	sub    %edx,%eax
  80086b:	eb f3                	jmp    800860 <strncmp+0x38>

0080086d <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80086d:	55                   	push   %ebp
  80086e:	89 e5                	mov    %esp,%ebp
  800870:	8b 45 08             	mov    0x8(%ebp),%eax
  800873:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800876:	8a 10                	mov    (%eax),%dl
  800878:	84 d2                	test   %dl,%dl
  80087a:	74 18                	je     800894 <strchr+0x27>
		if (*s == c)
  80087c:	38 ca                	cmp    %cl,%dl
  80087e:	75 06                	jne    800886 <strchr+0x19>
  800880:	eb 17                	jmp    800899 <strchr+0x2c>
  800882:	38 ca                	cmp    %cl,%dl
  800884:	74 13                	je     800899 <strchr+0x2c>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800886:	40                   	inc    %eax
  800887:	8a 10                	mov    (%eax),%dl
  800889:	84 d2                	test   %dl,%dl
  80088b:	75 f5                	jne    800882 <strchr+0x15>
		if (*s == c)
			return (char *) s;
	return 0;
  80088d:	b8 00 00 00 00       	mov    $0x0,%eax
  800892:	eb 05                	jmp    800899 <strchr+0x2c>
  800894:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800899:	c9                   	leave  
  80089a:	c3                   	ret    

0080089b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80089b:	55                   	push   %ebp
  80089c:	89 e5                	mov    %esp,%ebp
  80089e:	8b 45 08             	mov    0x8(%ebp),%eax
  8008a1:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8008a4:	8a 10                	mov    (%eax),%dl
  8008a6:	84 d2                	test   %dl,%dl
  8008a8:	74 11                	je     8008bb <strfind+0x20>
		if (*s == c)
  8008aa:	38 ca                	cmp    %cl,%dl
  8008ac:	75 06                	jne    8008b4 <strfind+0x19>
  8008ae:	eb 0b                	jmp    8008bb <strfind+0x20>
  8008b0:	38 ca                	cmp    %cl,%dl
  8008b2:	74 07                	je     8008bb <strfind+0x20>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  8008b4:	40                   	inc    %eax
  8008b5:	8a 10                	mov    (%eax),%dl
  8008b7:	84 d2                	test   %dl,%dl
  8008b9:	75 f5                	jne    8008b0 <strfind+0x15>
		if (*s == c)
			break;
	return (char *) s;
}
  8008bb:	c9                   	leave  
  8008bc:	c3                   	ret    

008008bd <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008bd:	55                   	push   %ebp
  8008be:	89 e5                	mov    %esp,%ebp
  8008c0:	57                   	push   %edi
  8008c1:	56                   	push   %esi
  8008c2:	53                   	push   %ebx
  8008c3:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008c6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008c9:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8008cc:	85 c9                	test   %ecx,%ecx
  8008ce:	74 30                	je     800900 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008d0:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008d6:	75 25                	jne    8008fd <memset+0x40>
  8008d8:	f6 c1 03             	test   $0x3,%cl
  8008db:	75 20                	jne    8008fd <memset+0x40>
		c &= 0xFF;
  8008dd:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8008e0:	89 d3                	mov    %edx,%ebx
  8008e2:	c1 e3 08             	shl    $0x8,%ebx
  8008e5:	89 d6                	mov    %edx,%esi
  8008e7:	c1 e6 18             	shl    $0x18,%esi
  8008ea:	89 d0                	mov    %edx,%eax
  8008ec:	c1 e0 10             	shl    $0x10,%eax
  8008ef:	09 f0                	or     %esi,%eax
  8008f1:	09 d0                	or     %edx,%eax
  8008f3:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  8008f5:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  8008f8:	fc                   	cld    
  8008f9:	f3 ab                	rep stos %eax,%es:(%edi)
  8008fb:	eb 03                	jmp    800900 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8008fd:	fc                   	cld    
  8008fe:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800900:	89 f8                	mov    %edi,%eax
  800902:	5b                   	pop    %ebx
  800903:	5e                   	pop    %esi
  800904:	5f                   	pop    %edi
  800905:	c9                   	leave  
  800906:	c3                   	ret    

00800907 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800907:	55                   	push   %ebp
  800908:	89 e5                	mov    %esp,%ebp
  80090a:	57                   	push   %edi
  80090b:	56                   	push   %esi
  80090c:	8b 45 08             	mov    0x8(%ebp),%eax
  80090f:	8b 75 0c             	mov    0xc(%ebp),%esi
  800912:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800915:	39 c6                	cmp    %eax,%esi
  800917:	73 34                	jae    80094d <memmove+0x46>
  800919:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80091c:	39 d0                	cmp    %edx,%eax
  80091e:	73 2d                	jae    80094d <memmove+0x46>
		s += n;
		d += n;
  800920:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800923:	f6 c2 03             	test   $0x3,%dl
  800926:	75 1b                	jne    800943 <memmove+0x3c>
  800928:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80092e:	75 13                	jne    800943 <memmove+0x3c>
  800930:	f6 c1 03             	test   $0x3,%cl
  800933:	75 0e                	jne    800943 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800935:	83 ef 04             	sub    $0x4,%edi
  800938:	8d 72 fc             	lea    -0x4(%edx),%esi
  80093b:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  80093e:	fd                   	std    
  80093f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800941:	eb 07                	jmp    80094a <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800943:	4f                   	dec    %edi
  800944:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800947:	fd                   	std    
  800948:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80094a:	fc                   	cld    
  80094b:	eb 20                	jmp    80096d <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80094d:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800953:	75 13                	jne    800968 <memmove+0x61>
  800955:	a8 03                	test   $0x3,%al
  800957:	75 0f                	jne    800968 <memmove+0x61>
  800959:	f6 c1 03             	test   $0x3,%cl
  80095c:	75 0a                	jne    800968 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  80095e:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800961:	89 c7                	mov    %eax,%edi
  800963:	fc                   	cld    
  800964:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800966:	eb 05                	jmp    80096d <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800968:	89 c7                	mov    %eax,%edi
  80096a:	fc                   	cld    
  80096b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  80096d:	5e                   	pop    %esi
  80096e:	5f                   	pop    %edi
  80096f:	c9                   	leave  
  800970:	c3                   	ret    

00800971 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800971:	55                   	push   %ebp
  800972:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800974:	ff 75 10             	pushl  0x10(%ebp)
  800977:	ff 75 0c             	pushl  0xc(%ebp)
  80097a:	ff 75 08             	pushl  0x8(%ebp)
  80097d:	e8 85 ff ff ff       	call   800907 <memmove>
}
  800982:	c9                   	leave  
  800983:	c3                   	ret    

00800984 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800984:	55                   	push   %ebp
  800985:	89 e5                	mov    %esp,%ebp
  800987:	57                   	push   %edi
  800988:	56                   	push   %esi
  800989:	53                   	push   %ebx
  80098a:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80098d:	8b 75 0c             	mov    0xc(%ebp),%esi
  800990:	8b 7d 10             	mov    0x10(%ebp),%edi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800993:	85 ff                	test   %edi,%edi
  800995:	74 32                	je     8009c9 <memcmp+0x45>
		if (*s1 != *s2)
  800997:	8a 03                	mov    (%ebx),%al
  800999:	8a 0e                	mov    (%esi),%cl
  80099b:	38 c8                	cmp    %cl,%al
  80099d:	74 19                	je     8009b8 <memcmp+0x34>
  80099f:	eb 0d                	jmp    8009ae <memcmp+0x2a>
  8009a1:	8a 44 13 01          	mov    0x1(%ebx,%edx,1),%al
  8009a5:	8a 4c 16 01          	mov    0x1(%esi,%edx,1),%cl
  8009a9:	42                   	inc    %edx
  8009aa:	38 c8                	cmp    %cl,%al
  8009ac:	74 10                	je     8009be <memcmp+0x3a>
			return (int) *s1 - (int) *s2;
  8009ae:	0f b6 c0             	movzbl %al,%eax
  8009b1:	0f b6 c9             	movzbl %cl,%ecx
  8009b4:	29 c8                	sub    %ecx,%eax
  8009b6:	eb 16                	jmp    8009ce <memcmp+0x4a>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009b8:	4f                   	dec    %edi
  8009b9:	ba 00 00 00 00       	mov    $0x0,%edx
  8009be:	39 fa                	cmp    %edi,%edx
  8009c0:	75 df                	jne    8009a1 <memcmp+0x1d>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8009c2:	b8 00 00 00 00       	mov    $0x0,%eax
  8009c7:	eb 05                	jmp    8009ce <memcmp+0x4a>
  8009c9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009ce:	5b                   	pop    %ebx
  8009cf:	5e                   	pop    %esi
  8009d0:	5f                   	pop    %edi
  8009d1:	c9                   	leave  
  8009d2:	c3                   	ret    

008009d3 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009d3:	55                   	push   %ebp
  8009d4:	89 e5                	mov    %esp,%ebp
  8009d6:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  8009d9:	89 c2                	mov    %eax,%edx
  8009db:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  8009de:	39 d0                	cmp    %edx,%eax
  8009e0:	73 12                	jae    8009f4 <memfind+0x21>
		if (*(const unsigned char *) s == (unsigned char) c)
  8009e2:	8a 4d 0c             	mov    0xc(%ebp),%cl
  8009e5:	38 08                	cmp    %cl,(%eax)
  8009e7:	75 06                	jne    8009ef <memfind+0x1c>
  8009e9:	eb 09                	jmp    8009f4 <memfind+0x21>
  8009eb:	38 08                	cmp    %cl,(%eax)
  8009ed:	74 05                	je     8009f4 <memfind+0x21>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009ef:	40                   	inc    %eax
  8009f0:	39 c2                	cmp    %eax,%edx
  8009f2:	77 f7                	ja     8009eb <memfind+0x18>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8009f4:	c9                   	leave  
  8009f5:	c3                   	ret    

008009f6 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8009f6:	55                   	push   %ebp
  8009f7:	89 e5                	mov    %esp,%ebp
  8009f9:	57                   	push   %edi
  8009fa:	56                   	push   %esi
  8009fb:	53                   	push   %ebx
  8009fc:	8b 55 08             	mov    0x8(%ebp),%edx
  8009ff:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a02:	eb 01                	jmp    800a05 <strtol+0xf>
		s++;
  800a04:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a05:	8a 02                	mov    (%edx),%al
  800a07:	3c 20                	cmp    $0x20,%al
  800a09:	74 f9                	je     800a04 <strtol+0xe>
  800a0b:	3c 09                	cmp    $0x9,%al
  800a0d:	74 f5                	je     800a04 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a0f:	3c 2b                	cmp    $0x2b,%al
  800a11:	75 08                	jne    800a1b <strtol+0x25>
		s++;
  800a13:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a14:	bf 00 00 00 00       	mov    $0x0,%edi
  800a19:	eb 13                	jmp    800a2e <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a1b:	3c 2d                	cmp    $0x2d,%al
  800a1d:	75 0a                	jne    800a29 <strtol+0x33>
		s++, neg = 1;
  800a1f:	8d 52 01             	lea    0x1(%edx),%edx
  800a22:	bf 01 00 00 00       	mov    $0x1,%edi
  800a27:	eb 05                	jmp    800a2e <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a29:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a2e:	85 db                	test   %ebx,%ebx
  800a30:	74 05                	je     800a37 <strtol+0x41>
  800a32:	83 fb 10             	cmp    $0x10,%ebx
  800a35:	75 28                	jne    800a5f <strtol+0x69>
  800a37:	8a 02                	mov    (%edx),%al
  800a39:	3c 30                	cmp    $0x30,%al
  800a3b:	75 10                	jne    800a4d <strtol+0x57>
  800a3d:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800a41:	75 0a                	jne    800a4d <strtol+0x57>
		s += 2, base = 16;
  800a43:	83 c2 02             	add    $0x2,%edx
  800a46:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a4b:	eb 12                	jmp    800a5f <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800a4d:	85 db                	test   %ebx,%ebx
  800a4f:	75 0e                	jne    800a5f <strtol+0x69>
  800a51:	3c 30                	cmp    $0x30,%al
  800a53:	75 05                	jne    800a5a <strtol+0x64>
		s++, base = 8;
  800a55:	42                   	inc    %edx
  800a56:	b3 08                	mov    $0x8,%bl
  800a58:	eb 05                	jmp    800a5f <strtol+0x69>
	else if (base == 0)
		base = 10;
  800a5a:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800a5f:	b8 00 00 00 00       	mov    $0x0,%eax
  800a64:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a66:	8a 0a                	mov    (%edx),%cl
  800a68:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800a6b:	80 fb 09             	cmp    $0x9,%bl
  800a6e:	77 08                	ja     800a78 <strtol+0x82>
			dig = *s - '0';
  800a70:	0f be c9             	movsbl %cl,%ecx
  800a73:	83 e9 30             	sub    $0x30,%ecx
  800a76:	eb 1e                	jmp    800a96 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800a78:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800a7b:	80 fb 19             	cmp    $0x19,%bl
  800a7e:	77 08                	ja     800a88 <strtol+0x92>
			dig = *s - 'a' + 10;
  800a80:	0f be c9             	movsbl %cl,%ecx
  800a83:	83 e9 57             	sub    $0x57,%ecx
  800a86:	eb 0e                	jmp    800a96 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800a88:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800a8b:	80 fb 19             	cmp    $0x19,%bl
  800a8e:	77 13                	ja     800aa3 <strtol+0xad>
			dig = *s - 'A' + 10;
  800a90:	0f be c9             	movsbl %cl,%ecx
  800a93:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800a96:	39 f1                	cmp    %esi,%ecx
  800a98:	7d 0d                	jge    800aa7 <strtol+0xb1>
			break;
		s++, val = (val * base) + dig;
  800a9a:	42                   	inc    %edx
  800a9b:	0f af c6             	imul   %esi,%eax
  800a9e:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  800aa1:	eb c3                	jmp    800a66 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800aa3:	89 c1                	mov    %eax,%ecx
  800aa5:	eb 02                	jmp    800aa9 <strtol+0xb3>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800aa7:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800aa9:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800aad:	74 05                	je     800ab4 <strtol+0xbe>
		*endptr = (char *) s;
  800aaf:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800ab2:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800ab4:	85 ff                	test   %edi,%edi
  800ab6:	74 04                	je     800abc <strtol+0xc6>
  800ab8:	89 c8                	mov    %ecx,%eax
  800aba:	f7 d8                	neg    %eax
}
  800abc:	5b                   	pop    %ebx
  800abd:	5e                   	pop    %esi
  800abe:	5f                   	pop    %edi
  800abf:	c9                   	leave  
  800ac0:	c3                   	ret    
  800ac1:	00 00                	add    %al,(%eax)
	...

00800ac4 <syscall>:
	return ret;
}

static int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800ac4:	55                   	push   %ebp
  800ac5:	89 e5                	mov    %esp,%ebp
  800ac7:	57                   	push   %edi
  800ac8:	56                   	push   %esi
  800ac9:	53                   	push   %ebx
  800aca:	83 ec 1c             	sub    $0x1c,%esp
  800acd:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800ad0:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800ad3:	89 ca                	mov    %ecx,%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ad5:	8b 75 14             	mov    0x14(%ebp),%esi
  800ad8:	8b 7d 10             	mov    0x10(%ebp),%edi
  800adb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800ade:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ae1:	cd 30                	int    $0x30
  800ae3:	89 c2                	mov    %eax,%edx
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ae5:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800ae9:	74 1c                	je     800b07 <syscall+0x43>
  800aeb:	85 c0                	test   %eax,%eax
  800aed:	7e 18                	jle    800b07 <syscall+0x43>
		panic("syscall %d returned %d (> 0)", num, ret);
  800aef:	83 ec 0c             	sub    $0xc,%esp
  800af2:	50                   	push   %eax
  800af3:	ff 75 e4             	pushl  -0x1c(%ebp)
  800af6:	68 24 13 80 00       	push   $0x801324
  800afb:	6a 42                	push   $0x42
  800afd:	68 41 13 80 00       	push   $0x801341
  800b02:	e8 f5 02 00 00       	call   800dfc <_panic>

	return ret;
}
  800b07:	89 d0                	mov    %edx,%eax
  800b09:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b0c:	5b                   	pop    %ebx
  800b0d:	5e                   	pop    %esi
  800b0e:	5f                   	pop    %edi
  800b0f:	c9                   	leave  
  800b10:	c3                   	ret    

00800b11 <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{	
  800b11:	55                   	push   %ebp
  800b12:	89 e5                	mov    %esp,%ebp
  800b14:	83 ec 08             	sub    $0x8,%esp
	// my_sysenter(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
	// return;
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  800b17:	6a 00                	push   $0x0
  800b19:	6a 00                	push   $0x0
  800b1b:	6a 00                	push   $0x0
  800b1d:	ff 75 0c             	pushl  0xc(%ebp)
  800b20:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b23:	ba 00 00 00 00       	mov    $0x0,%edx
  800b28:	b8 00 00 00 00       	mov    $0x0,%eax
  800b2d:	e8 92 ff ff ff       	call   800ac4 <syscall>
  800b32:	83 c4 10             	add    $0x10,%esp
	return;
}
  800b35:	c9                   	leave  
  800b36:	c3                   	ret    

00800b37 <sys_cgetc>:

int
sys_cgetc(void)
{
  800b37:	55                   	push   %ebp
  800b38:	89 e5                	mov    %esp,%ebp
  800b3a:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_cgetc, 0, 0, 0, 0, 0, 0);
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  800b3d:	6a 00                	push   $0x0
  800b3f:	6a 00                	push   $0x0
  800b41:	6a 00                	push   $0x0
  800b43:	6a 00                	push   $0x0
  800b45:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b4a:	ba 00 00 00 00       	mov    $0x0,%edx
  800b4f:	b8 01 00 00 00       	mov    $0x1,%eax
  800b54:	e8 6b ff ff ff       	call   800ac4 <syscall>
}
  800b59:	c9                   	leave  
  800b5a:	c3                   	ret    

00800b5b <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b5b:	55                   	push   %ebp
  800b5c:	89 e5                	mov    %esp,%ebp
  800b5e:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  800b61:	6a 00                	push   $0x0
  800b63:	6a 00                	push   $0x0
  800b65:	6a 00                	push   $0x0
  800b67:	6a 00                	push   $0x0
  800b69:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b6c:	ba 01 00 00 00       	mov    $0x1,%edx
  800b71:	b8 03 00 00 00       	mov    $0x3,%eax
  800b76:	e8 49 ff ff ff       	call   800ac4 <syscall>
}
  800b7b:	c9                   	leave  
  800b7c:	c3                   	ret    

00800b7d <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b7d:	55                   	push   %ebp
  800b7e:	89 e5                	mov    %esp,%ebp
  800b80:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_getenvid, 0, 0, 0, 0, 0, 0);
	return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  800b83:	6a 00                	push   $0x0
  800b85:	6a 00                	push   $0x0
  800b87:	6a 00                	push   $0x0
  800b89:	6a 00                	push   $0x0
  800b8b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b90:	ba 00 00 00 00       	mov    $0x0,%edx
  800b95:	b8 02 00 00 00       	mov    $0x2,%eax
  800b9a:	e8 25 ff ff ff       	call   800ac4 <syscall>
}
  800b9f:	c9                   	leave  
  800ba0:	c3                   	ret    

00800ba1 <sys_yield>:

void
sys_yield(void)
{
  800ba1:	55                   	push   %ebp
  800ba2:	89 e5                	mov    %esp,%ebp
  800ba4:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  800ba7:	6a 00                	push   $0x0
  800ba9:	6a 00                	push   $0x0
  800bab:	6a 00                	push   $0x0
  800bad:	6a 00                	push   $0x0
  800baf:	b9 00 00 00 00       	mov    $0x0,%ecx
  800bb4:	ba 00 00 00 00       	mov    $0x0,%edx
  800bb9:	b8 0a 00 00 00       	mov    $0xa,%eax
  800bbe:	e8 01 ff ff ff       	call   800ac4 <syscall>
  800bc3:	83 c4 10             	add    $0x10,%esp
}
  800bc6:	c9                   	leave  
  800bc7:	c3                   	ret    

00800bc8 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800bc8:	55                   	push   %ebp
  800bc9:	89 e5                	mov    %esp,%ebp
  800bcb:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  800bce:	6a 00                	push   $0x0
  800bd0:	6a 00                	push   $0x0
  800bd2:	ff 75 10             	pushl  0x10(%ebp)
  800bd5:	ff 75 0c             	pushl  0xc(%ebp)
  800bd8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800bdb:	ba 01 00 00 00       	mov    $0x1,%edx
  800be0:	b8 04 00 00 00       	mov    $0x4,%eax
  800be5:	e8 da fe ff ff       	call   800ac4 <syscall>
}
  800bea:	c9                   	leave  
  800beb:	c3                   	ret    

00800bec <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800bec:	55                   	push   %ebp
  800bed:	89 e5                	mov    %esp,%ebp
  800bef:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
  800bf2:	ff 75 18             	pushl  0x18(%ebp)
  800bf5:	ff 75 14             	pushl  0x14(%ebp)
  800bf8:	ff 75 10             	pushl  0x10(%ebp)
  800bfb:	ff 75 0c             	pushl  0xc(%ebp)
  800bfe:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c01:	ba 01 00 00 00       	mov    $0x1,%edx
  800c06:	b8 05 00 00 00       	mov    $0x5,%eax
  800c0b:	e8 b4 fe ff ff       	call   800ac4 <syscall>
}
  800c10:	c9                   	leave  
  800c11:	c3                   	ret    

00800c12 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c12:	55                   	push   %ebp
  800c13:	89 e5                	mov    %esp,%ebp
  800c15:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  800c18:	6a 00                	push   $0x0
  800c1a:	6a 00                	push   $0x0
  800c1c:	6a 00                	push   $0x0
  800c1e:	ff 75 0c             	pushl  0xc(%ebp)
  800c21:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c24:	ba 01 00 00 00       	mov    $0x1,%edx
  800c29:	b8 06 00 00 00       	mov    $0x6,%eax
  800c2e:	e8 91 fe ff ff       	call   800ac4 <syscall>
}
  800c33:	c9                   	leave  
  800c34:	c3                   	ret    

00800c35 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c35:	55                   	push   %ebp
  800c36:	89 e5                	mov    %esp,%ebp
  800c38:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  800c3b:	6a 00                	push   $0x0
  800c3d:	6a 00                	push   $0x0
  800c3f:	6a 00                	push   $0x0
  800c41:	ff 75 0c             	pushl  0xc(%ebp)
  800c44:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c47:	ba 01 00 00 00       	mov    $0x1,%edx
  800c4c:	b8 08 00 00 00       	mov    $0x8,%eax
  800c51:	e8 6e fe ff ff       	call   800ac4 <syscall>
}
  800c56:	c9                   	leave  
  800c57:	c3                   	ret    

00800c58 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800c58:	55                   	push   %ebp
  800c59:	89 e5                	mov    %esp,%ebp
  800c5b:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  800c5e:	6a 00                	push   $0x0
  800c60:	6a 00                	push   $0x0
  800c62:	6a 00                	push   $0x0
  800c64:	ff 75 0c             	pushl  0xc(%ebp)
  800c67:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c6a:	ba 01 00 00 00       	mov    $0x1,%edx
  800c6f:	b8 09 00 00 00       	mov    $0x9,%eax
  800c74:	e8 4b fe ff ff       	call   800ac4 <syscall>
}
  800c79:	c9                   	leave  
  800c7a:	c3                   	ret    

00800c7b <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800c7b:	55                   	push   %ebp
  800c7c:	89 e5                	mov    %esp,%ebp
  800c7e:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  800c81:	6a 00                	push   $0x0
  800c83:	ff 75 14             	pushl  0x14(%ebp)
  800c86:	ff 75 10             	pushl  0x10(%ebp)
  800c89:	ff 75 0c             	pushl  0xc(%ebp)
  800c8c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c8f:	ba 00 00 00 00       	mov    $0x0,%edx
  800c94:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c99:	e8 26 fe ff ff       	call   800ac4 <syscall>
}
  800c9e:	c9                   	leave  
  800c9f:	c3                   	ret    

00800ca0 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800ca0:	55                   	push   %ebp
  800ca1:	89 e5                	mov    %esp,%ebp
  800ca3:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  800ca6:	6a 00                	push   $0x0
  800ca8:	6a 00                	push   $0x0
  800caa:	6a 00                	push   $0x0
  800cac:	6a 00                	push   $0x0
  800cae:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800cb1:	ba 01 00 00 00       	mov    $0x1,%edx
  800cb6:	b8 0c 00 00 00       	mov    $0xc,%eax
  800cbb:	e8 04 fe ff ff       	call   800ac4 <syscall>
}
  800cc0:	c9                   	leave  
  800cc1:	c3                   	ret    

00800cc2 <sys_set_priority>:

int
sys_set_priority(envid_t envid, uint32_t new_priority)
{
  800cc2:	55                   	push   %ebp
  800cc3:	89 e5                	mov    %esp,%ebp
  800cc5:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_set_priority, 0, envid, new_priority, 0, 0, 0);
  800cc8:	6a 00                	push   $0x0
  800cca:	6a 00                	push   $0x0
  800ccc:	6a 00                	push   $0x0
  800cce:	ff 75 0c             	pushl  0xc(%ebp)
  800cd1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800cd4:	ba 00 00 00 00       	mov    $0x0,%edx
  800cd9:	b8 0d 00 00 00       	mov    $0xd,%eax
  800cde:	e8 e1 fd ff ff       	call   800ac4 <syscall>
}
  800ce3:	c9                   	leave  
  800ce4:	c3                   	ret    
  800ce5:	00 00                	add    %al,(%eax)
	...

00800ce8 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  800ce8:	55                   	push   %ebp
  800ce9:	89 e5                	mov    %esp,%ebp
  800ceb:	56                   	push   %esi
  800cec:	53                   	push   %ebx
  800ced:	8b 75 08             	mov    0x8(%ebp),%esi
  800cf0:	8b 45 0c             	mov    0xc(%ebp),%eax
  800cf3:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int r;
	if (pg != NULL) {
  800cf6:	85 c0                	test   %eax,%eax
  800cf8:	74 0e                	je     800d08 <ipc_recv+0x20>
		r = sys_ipc_recv(pg);
  800cfa:	83 ec 0c             	sub    $0xc,%esp
  800cfd:	50                   	push   %eax
  800cfe:	e8 9d ff ff ff       	call   800ca0 <sys_ipc_recv>
  800d03:	83 c4 10             	add    $0x10,%esp
  800d06:	eb 10                	jmp    800d18 <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv((void *)UTOP);
  800d08:	83 ec 0c             	sub    $0xc,%esp
  800d0b:	68 00 00 c0 ee       	push   $0xeec00000
  800d10:	e8 8b ff ff ff       	call   800ca0 <sys_ipc_recv>
  800d15:	83 c4 10             	add    $0x10,%esp
	}

	if (r == 0) {
  800d18:	85 c0                	test   %eax,%eax
  800d1a:	75 26                	jne    800d42 <ipc_recv+0x5a>
		if (from_env_store != NULL) *from_env_store = thisenv->env_ipc_from;
  800d1c:	85 f6                	test   %esi,%esi
  800d1e:	74 0a                	je     800d2a <ipc_recv+0x42>
  800d20:	a1 04 20 80 00       	mov    0x802004,%eax
  800d25:	8b 40 74             	mov    0x74(%eax),%eax
  800d28:	89 06                	mov    %eax,(%esi)
		if (perm_store != NULL) *perm_store = thisenv->env_ipc_perm;
  800d2a:	85 db                	test   %ebx,%ebx
  800d2c:	74 0a                	je     800d38 <ipc_recv+0x50>
  800d2e:	a1 04 20 80 00       	mov    0x802004,%eax
  800d33:	8b 40 78             	mov    0x78(%eax),%eax
  800d36:	89 03                	mov    %eax,(%ebx)
		// cprintf("Receive %d\n", thisenv->env_ipc_value);
		return thisenv->env_ipc_value;
  800d38:	a1 04 20 80 00       	mov    0x802004,%eax
  800d3d:	8b 40 70             	mov    0x70(%eax),%eax
  800d40:	eb 14                	jmp    800d56 <ipc_recv+0x6e>
	} else {
		// fails;
		if (from_env_store != NULL) *from_env_store = 0;
  800d42:	85 f6                	test   %esi,%esi
  800d44:	74 06                	je     800d4c <ipc_recv+0x64>
  800d46:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if (perm_store != NULL) *perm_store = 0;
  800d4c:	85 db                	test   %ebx,%ebx
  800d4e:	74 06                	je     800d56 <ipc_recv+0x6e>
  800d50:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		return r;
	}
}
  800d56:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800d59:	5b                   	pop    %ebx
  800d5a:	5e                   	pop    %esi
  800d5b:	c9                   	leave  
  800d5c:	c3                   	ret    

00800d5d <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  800d5d:	55                   	push   %ebp
  800d5e:	89 e5                	mov    %esp,%ebp
  800d60:	57                   	push   %edi
  800d61:	56                   	push   %esi
  800d62:	53                   	push   %ebx
  800d63:	83 ec 0c             	sub    $0xc,%esp
  800d66:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800d69:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d6c:	8b 75 14             	mov    0x14(%ebp),%esi
	// LAB 4: Your code here.
	// int sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
	int r;
	if (pg == NULL) pg = (void *)UTOP;
  800d6f:	85 db                	test   %ebx,%ebx
  800d71:	75 25                	jne    800d98 <ipc_send+0x3b>
  800d73:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
  800d78:	eb 1e                	jmp    800d98 <ipc_send+0x3b>
	
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) != 0) {
		if (r == -E_IPC_NOT_RECV) {
  800d7a:	83 f8 f9             	cmp    $0xfffffff9,%eax
  800d7d:	75 07                	jne    800d86 <ipc_send+0x29>
			// cprintf("Try Again and Again....\n");
			sys_yield();
  800d7f:	e8 1d fe ff ff       	call   800ba1 <sys_yield>
  800d84:	eb 12                	jmp    800d98 <ipc_send+0x3b>
		} else {
			panic("ipc_send error %e\n", r);
  800d86:	50                   	push   %eax
  800d87:	68 4f 13 80 00       	push   $0x80134f
  800d8c:	6a 43                	push   $0x43
  800d8e:	68 62 13 80 00       	push   $0x801362
  800d93:	e8 64 00 00 00       	call   800dfc <_panic>
	// LAB 4: Your code here.
	// int sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
	int r;
	if (pg == NULL) pg = (void *)UTOP;
	
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) != 0) {
  800d98:	56                   	push   %esi
  800d99:	53                   	push   %ebx
  800d9a:	57                   	push   %edi
  800d9b:	ff 75 08             	pushl  0x8(%ebp)
  800d9e:	e8 d8 fe ff ff       	call   800c7b <sys_ipc_try_send>
  800da3:	83 c4 10             	add    $0x10,%esp
  800da6:	85 c0                	test   %eax,%eax
  800da8:	75 d0                	jne    800d7a <ipc_send+0x1d>
		} else {
			panic("ipc_send error %e\n", r);
		}
	}
	return;
}
  800daa:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dad:	5b                   	pop    %ebx
  800dae:	5e                   	pop    %esi
  800daf:	5f                   	pop    %edi
  800db0:	c9                   	leave  
  800db1:	c3                   	ret    

00800db2 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  800db2:	55                   	push   %ebp
  800db3:	89 e5                	mov    %esp,%ebp
  800db5:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  800db8:	39 0d 50 00 c0 ee    	cmp    %ecx,0xeec00050
  800dbe:	74 19                	je     800dd9 <ipc_find_env+0x27>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  800dc0:	b8 01 00 00 00       	mov    $0x1,%eax
		if (envs[i].env_type == type)
  800dc5:	89 c2                	mov    %eax,%edx
  800dc7:	c1 e2 07             	shl    $0x7,%edx
  800dca:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  800dd0:	8b 52 50             	mov    0x50(%edx),%edx
  800dd3:	39 ca                	cmp    %ecx,%edx
  800dd5:	75 14                	jne    800deb <ipc_find_env+0x39>
  800dd7:	eb 05                	jmp    800dde <ipc_find_env+0x2c>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  800dd9:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
			return envs[i].env_id;
  800dde:	c1 e0 07             	shl    $0x7,%eax
  800de1:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  800de6:	8b 40 40             	mov    0x40(%eax),%eax
  800de9:	eb 0c                	jmp    800df7 <ipc_find_env+0x45>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  800deb:	40                   	inc    %eax
  800dec:	3d 00 04 00 00       	cmp    $0x400,%eax
  800df1:	75 d2                	jne    800dc5 <ipc_find_env+0x13>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  800df3:	66 b8 00 00          	mov    $0x0,%ax
}
  800df7:	c9                   	leave  
  800df8:	c3                   	ret    
  800df9:	00 00                	add    %al,(%eax)
	...

00800dfc <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800dfc:	55                   	push   %ebp
  800dfd:	89 e5                	mov    %esp,%ebp
  800dff:	56                   	push   %esi
  800e00:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800e01:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800e04:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  800e0a:	e8 6e fd ff ff       	call   800b7d <sys_getenvid>
  800e0f:	83 ec 0c             	sub    $0xc,%esp
  800e12:	ff 75 0c             	pushl  0xc(%ebp)
  800e15:	ff 75 08             	pushl  0x8(%ebp)
  800e18:	53                   	push   %ebx
  800e19:	50                   	push   %eax
  800e1a:	68 6c 13 80 00       	push   $0x80136c
  800e1f:	e8 6c f3 ff ff       	call   800190 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800e24:	83 c4 18             	add    $0x18,%esp
  800e27:	56                   	push   %esi
  800e28:	ff 75 10             	pushl  0x10(%ebp)
  800e2b:	e8 0f f3 ff ff       	call   80013f <vcprintf>
	cprintf("\n");
  800e30:	c7 04 24 60 13 80 00 	movl   $0x801360,(%esp)
  800e37:	e8 54 f3 ff ff       	call   800190 <cprintf>
  800e3c:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800e3f:	cc                   	int3   
  800e40:	eb fd                	jmp    800e3f <_panic+0x43>
	...

00800e44 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  800e44:	55                   	push   %ebp
  800e45:	89 e5                	mov    %esp,%ebp
  800e47:	57                   	push   %edi
  800e48:	56                   	push   %esi
  800e49:	83 ec 10             	sub    $0x10,%esp
  800e4c:	8b 7d 08             	mov    0x8(%ebp),%edi
  800e4f:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  800e52:	89 7d f0             	mov    %edi,-0x10(%ebp)
  800e55:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  800e58:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  800e5b:	8b 45 14             	mov    0x14(%ebp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800e5e:	85 c0                	test   %eax,%eax
  800e60:	75 2e                	jne    800e90 <__udivdi3+0x4c>
    {
      if (d0 > n1)
  800e62:	39 f1                	cmp    %esi,%ecx
  800e64:	77 5a                	ja     800ec0 <__udivdi3+0x7c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  800e66:	85 c9                	test   %ecx,%ecx
  800e68:	75 0b                	jne    800e75 <__udivdi3+0x31>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  800e6a:	b8 01 00 00 00       	mov    $0x1,%eax
  800e6f:	31 d2                	xor    %edx,%edx
  800e71:	f7 f1                	div    %ecx
  800e73:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  800e75:	31 d2                	xor    %edx,%edx
  800e77:	89 f0                	mov    %esi,%eax
  800e79:	f7 f1                	div    %ecx
  800e7b:	89 c6                	mov    %eax,%esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800e7d:	89 f8                	mov    %edi,%eax
  800e7f:	f7 f1                	div    %ecx
  800e81:	89 c7                	mov    %eax,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800e83:	89 f8                	mov    %edi,%eax
  800e85:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800e87:	83 c4 10             	add    $0x10,%esp
  800e8a:	5e                   	pop    %esi
  800e8b:	5f                   	pop    %edi
  800e8c:	c9                   	leave  
  800e8d:	c3                   	ret    
  800e8e:	66 90                	xchg   %ax,%ax
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800e90:	39 f0                	cmp    %esi,%eax
  800e92:	77 1c                	ja     800eb0 <__udivdi3+0x6c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  800e94:	0f bd f8             	bsr    %eax,%edi
	  if (bm == 0)
  800e97:	83 f7 1f             	xor    $0x1f,%edi
  800e9a:	75 3c                	jne    800ed8 <__udivdi3+0x94>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800e9c:	39 f0                	cmp    %esi,%eax
  800e9e:	0f 82 90 00 00 00    	jb     800f34 <__udivdi3+0xf0>
  800ea4:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800ea7:	39 55 f4             	cmp    %edx,-0xc(%ebp)
  800eaa:	0f 86 84 00 00 00    	jbe    800f34 <__udivdi3+0xf0>
  800eb0:	31 f6                	xor    %esi,%esi
  800eb2:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800eb4:	89 f8                	mov    %edi,%eax
  800eb6:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800eb8:	83 c4 10             	add    $0x10,%esp
  800ebb:	5e                   	pop    %esi
  800ebc:	5f                   	pop    %edi
  800ebd:	c9                   	leave  
  800ebe:	c3                   	ret    
  800ebf:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800ec0:	89 f2                	mov    %esi,%edx
  800ec2:	89 f8                	mov    %edi,%eax
  800ec4:	f7 f1                	div    %ecx
  800ec6:	89 c7                	mov    %eax,%edi
  800ec8:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800eca:	89 f8                	mov    %edi,%eax
  800ecc:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800ece:	83 c4 10             	add    $0x10,%esp
  800ed1:	5e                   	pop    %esi
  800ed2:	5f                   	pop    %edi
  800ed3:	c9                   	leave  
  800ed4:	c3                   	ret    
  800ed5:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  800ed8:	89 f9                	mov    %edi,%ecx
  800eda:	d3 e0                	shl    %cl,%eax
  800edc:	89 45 e8             	mov    %eax,-0x18(%ebp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  800edf:	b8 20 00 00 00       	mov    $0x20,%eax
  800ee4:	29 f8                	sub    %edi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  800ee6:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800ee9:	88 c1                	mov    %al,%cl
  800eeb:	d3 ea                	shr    %cl,%edx
  800eed:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  800ef0:	09 ca                	or     %ecx,%edx
  800ef2:	89 55 ec             	mov    %edx,-0x14(%ebp)
	      d0 = d0 << bm;
  800ef5:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800ef8:	89 f9                	mov    %edi,%ecx
  800efa:	d3 e2                	shl    %cl,%edx
  800efc:	89 55 f4             	mov    %edx,-0xc(%ebp)
	      n2 = n1 >> b;
  800eff:	89 f2                	mov    %esi,%edx
  800f01:	88 c1                	mov    %al,%cl
  800f03:	d3 ea                	shr    %cl,%edx
  800f05:	89 55 e8             	mov    %edx,-0x18(%ebp)
	      n1 = (n1 << bm) | (n0 >> b);
  800f08:	89 f2                	mov    %esi,%edx
  800f0a:	89 f9                	mov    %edi,%ecx
  800f0c:	d3 e2                	shl    %cl,%edx
  800f0e:	8b 75 f0             	mov    -0x10(%ebp),%esi
  800f11:	88 c1                	mov    %al,%cl
  800f13:	d3 ee                	shr    %cl,%esi
  800f15:	09 d6                	or     %edx,%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  800f17:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  800f1a:	89 f0                	mov    %esi,%eax
  800f1c:	89 ca                	mov    %ecx,%edx
  800f1e:	f7 75 ec             	divl   -0x14(%ebp)
  800f21:	89 d1                	mov    %edx,%ecx
  800f23:	89 c6                	mov    %eax,%esi
	      umul_ppmm (m1, m0, q0, d0);
  800f25:	f7 65 f4             	mull   -0xc(%ebp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800f28:	39 d1                	cmp    %edx,%ecx
  800f2a:	72 28                	jb     800f54 <__udivdi3+0x110>
  800f2c:	74 1a                	je     800f48 <__udivdi3+0x104>
  800f2e:	89 f7                	mov    %esi,%edi
  800f30:	31 f6                	xor    %esi,%esi
  800f32:	eb 80                	jmp    800eb4 <__udivdi3+0x70>
	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  800f34:	31 f6                	xor    %esi,%esi
  800f36:	bf 01 00 00 00       	mov    $0x1,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800f3b:	89 f8                	mov    %edi,%eax
  800f3d:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800f3f:	83 c4 10             	add    $0x10,%esp
  800f42:	5e                   	pop    %esi
  800f43:	5f                   	pop    %edi
  800f44:	c9                   	leave  
  800f45:	c3                   	ret    
  800f46:	66 90                	xchg   %ax,%ax

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  800f48:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800f4b:	89 f9                	mov    %edi,%ecx
  800f4d:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800f4f:	39 c2                	cmp    %eax,%edx
  800f51:	73 db                	jae    800f2e <__udivdi3+0xea>
  800f53:	90                   	nop
		{
		  q0--;
  800f54:	8d 7e ff             	lea    -0x1(%esi),%edi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  800f57:	31 f6                	xor    %esi,%esi
  800f59:	e9 56 ff ff ff       	jmp    800eb4 <__udivdi3+0x70>
	...

00800f60 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  800f60:	55                   	push   %ebp
  800f61:	89 e5                	mov    %esp,%ebp
  800f63:	57                   	push   %edi
  800f64:	56                   	push   %esi
  800f65:	83 ec 20             	sub    $0x20,%esp
  800f68:	8b 45 08             	mov    0x8(%ebp),%eax
  800f6b:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  800f6e:	89 45 e8             	mov    %eax,-0x18(%ebp)
  800f71:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  800f74:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  800f77:	8b 7d 14             	mov    0x14(%ebp),%edi
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  800f7a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  n1 = nn.s.high;
  800f7d:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800f7f:	85 ff                	test   %edi,%edi
  800f81:	75 15                	jne    800f98 <__umoddi3+0x38>
    {
      if (d0 > n1)
  800f83:	39 f1                	cmp    %esi,%ecx
  800f85:	0f 86 99 00 00 00    	jbe    801024 <__umoddi3+0xc4>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800f8b:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  800f8d:	89 d0                	mov    %edx,%eax
  800f8f:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800f91:	83 c4 20             	add    $0x20,%esp
  800f94:	5e                   	pop    %esi
  800f95:	5f                   	pop    %edi
  800f96:	c9                   	leave  
  800f97:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800f98:	39 f7                	cmp    %esi,%edi
  800f9a:	0f 87 a4 00 00 00    	ja     801044 <__umoddi3+0xe4>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  800fa0:	0f bd c7             	bsr    %edi,%eax
	  if (bm == 0)
  800fa3:	83 f0 1f             	xor    $0x1f,%eax
  800fa6:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800fa9:	0f 84 a1 00 00 00    	je     801050 <__umoddi3+0xf0>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  800faf:	89 f8                	mov    %edi,%eax
  800fb1:	8a 4d ec             	mov    -0x14(%ebp),%cl
  800fb4:	d3 e0                	shl    %cl,%eax
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  800fb6:	bf 20 00 00 00       	mov    $0x20,%edi
  800fbb:	2b 7d ec             	sub    -0x14(%ebp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  800fbe:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800fc1:	89 f9                	mov    %edi,%ecx
  800fc3:	d3 ea                	shr    %cl,%edx
  800fc5:	09 c2                	or     %eax,%edx
  800fc7:	89 55 f0             	mov    %edx,-0x10(%ebp)
	      d0 = d0 << bm;
  800fca:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800fcd:	8a 4d ec             	mov    -0x14(%ebp),%cl
  800fd0:	d3 e0                	shl    %cl,%eax
  800fd2:	89 45 f4             	mov    %eax,-0xc(%ebp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  800fd5:	89 f2                	mov    %esi,%edx
  800fd7:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  800fd9:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800fdc:	d3 e0                	shl    %cl,%eax
  800fde:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  800fe1:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800fe4:	89 f9                	mov    %edi,%ecx
  800fe6:	d3 e8                	shr    %cl,%eax
  800fe8:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  800fea:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  800fec:	89 f2                	mov    %esi,%edx
  800fee:	f7 75 f0             	divl   -0x10(%ebp)
  800ff1:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  800ff3:	f7 65 f4             	mull   -0xc(%ebp)
  800ff6:	89 55 e8             	mov    %edx,-0x18(%ebp)
  800ff9:	89 c1                	mov    %eax,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800ffb:	39 d6                	cmp    %edx,%esi
  800ffd:	72 71                	jb     801070 <__umoddi3+0x110>
  800fff:	74 7f                	je     801080 <__umoddi3+0x120>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  801001:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801004:	29 c8                	sub    %ecx,%eax
  801006:	19 d6                	sbb    %edx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  801008:	8a 4d ec             	mov    -0x14(%ebp),%cl
  80100b:	d3 e8                	shr    %cl,%eax
  80100d:	89 f2                	mov    %esi,%edx
  80100f:	89 f9                	mov    %edi,%ecx
  801011:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  801013:	09 d0                	or     %edx,%eax
  801015:	89 f2                	mov    %esi,%edx
  801017:	8a 4d ec             	mov    -0x14(%ebp),%cl
  80101a:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  80101c:	83 c4 20             	add    $0x20,%esp
  80101f:	5e                   	pop    %esi
  801020:	5f                   	pop    %edi
  801021:	c9                   	leave  
  801022:	c3                   	ret    
  801023:	90                   	nop
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  801024:	85 c9                	test   %ecx,%ecx
  801026:	75 0b                	jne    801033 <__umoddi3+0xd3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  801028:	b8 01 00 00 00       	mov    $0x1,%eax
  80102d:	31 d2                	xor    %edx,%edx
  80102f:	f7 f1                	div    %ecx
  801031:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  801033:	89 f0                	mov    %esi,%eax
  801035:	31 d2                	xor    %edx,%edx
  801037:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801039:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80103c:	f7 f1                	div    %ecx
  80103e:	e9 4a ff ff ff       	jmp    800f8d <__umoddi3+0x2d>
  801043:	90                   	nop
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  801044:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801046:	83 c4 20             	add    $0x20,%esp
  801049:	5e                   	pop    %esi
  80104a:	5f                   	pop    %edi
  80104b:	c9                   	leave  
  80104c:	c3                   	ret    
  80104d:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801050:	39 f7                	cmp    %esi,%edi
  801052:	72 05                	jb     801059 <__umoddi3+0xf9>
  801054:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
  801057:	77 0c                	ja     801065 <__umoddi3+0x105>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  801059:	89 f2                	mov    %esi,%edx
  80105b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80105e:	29 c8                	sub    %ecx,%eax
  801060:	19 fa                	sbb    %edi,%edx
  801062:	89 45 f0             	mov    %eax,-0x10(%ebp)

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  801065:	8b 45 f0             	mov    -0x10(%ebp),%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801068:	83 c4 20             	add    $0x20,%esp
  80106b:	5e                   	pop    %esi
  80106c:	5f                   	pop    %edi
  80106d:	c9                   	leave  
  80106e:	c3                   	ret    
  80106f:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  801070:	8b 55 e8             	mov    -0x18(%ebp),%edx
  801073:	89 c1                	mov    %eax,%ecx
  801075:	2b 4d f4             	sub    -0xc(%ebp),%ecx
  801078:	1b 55 f0             	sbb    -0x10(%ebp),%edx
  80107b:	eb 84                	jmp    801001 <__umoddi3+0xa1>
  80107d:	8d 76 00             	lea    0x0(%esi),%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801080:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801083:	72 eb                	jb     801070 <__umoddi3+0x110>
  801085:	89 f2                	mov    %esi,%edx
  801087:	e9 75 ff ff ff       	jmp    801001 <__umoddi3+0xa1>
