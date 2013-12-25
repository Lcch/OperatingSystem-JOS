
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
  80003c:	e8 48 0b 00 00       	call   800b89 <sys_getenvid>
  800041:	89 c3                	mov    %eax,%ebx

	if (thisenv == &envs[1]) {
  800043:	81 3d 04 40 80 00 84 	cmpl   $0xeec00084,0x804004
  80004a:	00 c0 ee 
  80004d:	75 26                	jne    800075 <umain+0x41>
		while (1) {
			ipc_recv(&who, 0, 0);
  80004f:	8d 75 f4             	lea    -0xc(%ebp),%esi
  800052:	83 ec 04             	sub    $0x4,%esp
  800055:	6a 00                	push   $0x0
  800057:	6a 00                	push   $0x0
  800059:	56                   	push   %esi
  80005a:	e8 21 0d 00 00       	call   800d80 <ipc_recv>
			cprintf("%x recv from %x\n", id, who);
  80005f:	83 c4 0c             	add    $0xc,%esp
  800062:	ff 75 f4             	pushl  -0xc(%ebp)
  800065:	53                   	push   %ebx
  800066:	68 20 1e 80 00       	push   $0x801e20
  80006b:	e8 2c 01 00 00       	call   80019c <cprintf>
  800070:	83 c4 10             	add    $0x10,%esp
  800073:	eb dd                	jmp    800052 <umain+0x1e>
		}
	} else {
		cprintf("%x loop sending to %x\n", id, envs[1].env_id);
  800075:	83 ec 04             	sub    $0x4,%esp
  800078:	ff 35 cc 00 c0 ee    	pushl  0xeec000cc
  80007e:	50                   	push   %eax
  80007f:	68 31 1e 80 00       	push   $0x801e31
  800084:	e8 13 01 00 00       	call   80019c <cprintf>
  800089:	83 c4 10             	add    $0x10,%esp
		while (1)
			ipc_send(envs[1].env_id, 0, 0, 0);
  80008c:	6a 00                	push   $0x0
  80008e:	6a 00                	push   $0x0
  800090:	6a 00                	push   $0x0
  800092:	ff 35 cc 00 c0 ee    	pushl  0xeec000cc
  800098:	e8 58 0d 00 00       	call   800df5 <ipc_send>
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
  8000af:	e8 d5 0a 00 00       	call   800b89 <sys_getenvid>
  8000b4:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000b9:	89 c2                	mov    %eax,%edx
  8000bb:	c1 e2 07             	shl    $0x7,%edx
  8000be:	8d 84 82 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,4),%eax
  8000c5:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000ca:	85 f6                	test   %esi,%esi
  8000cc:	7e 07                	jle    8000d5 <libmain+0x31>
		binaryname = argv[0];
  8000ce:	8b 03                	mov    (%ebx),%eax
  8000d0:	a3 00 30 80 00       	mov    %eax,0x803000
	// call user main routine
	umain(argc, argv);
  8000d5:	83 ec 08             	sub    $0x8,%esp
  8000d8:	53                   	push   %ebx
  8000d9:	56                   	push   %esi
  8000da:	e8 55 ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  8000df:	e8 0c 00 00 00       	call   8000f0 <exit>
  8000e4:	83 c4 10             	add    $0x10,%esp
}
  8000e7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000ea:	5b                   	pop    %ebx
  8000eb:	5e                   	pop    %esi
  8000ec:	c9                   	leave  
  8000ed:	c3                   	ret    
	...

008000f0 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000f0:	55                   	push   %ebp
  8000f1:	89 e5                	mov    %esp,%ebp
  8000f3:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8000f6:	e8 a7 0f 00 00       	call   8010a2 <close_all>
	sys_env_destroy(0);
  8000fb:	83 ec 0c             	sub    $0xc,%esp
  8000fe:	6a 00                	push   $0x0
  800100:	e8 62 0a 00 00       	call   800b67 <sys_env_destroy>
  800105:	83 c4 10             	add    $0x10,%esp
}
  800108:	c9                   	leave  
  800109:	c3                   	ret    
	...

0080010c <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80010c:	55                   	push   %ebp
  80010d:	89 e5                	mov    %esp,%ebp
  80010f:	53                   	push   %ebx
  800110:	83 ec 04             	sub    $0x4,%esp
  800113:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800116:	8b 03                	mov    (%ebx),%eax
  800118:	8b 55 08             	mov    0x8(%ebp),%edx
  80011b:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  80011f:	40                   	inc    %eax
  800120:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  800122:	3d ff 00 00 00       	cmp    $0xff,%eax
  800127:	75 1a                	jne    800143 <putch+0x37>
		sys_cputs(b->buf, b->idx);
  800129:	83 ec 08             	sub    $0x8,%esp
  80012c:	68 ff 00 00 00       	push   $0xff
  800131:	8d 43 08             	lea    0x8(%ebx),%eax
  800134:	50                   	push   %eax
  800135:	e8 e3 09 00 00       	call   800b1d <sys_cputs>
		b->idx = 0;
  80013a:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800140:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800143:	ff 43 04             	incl   0x4(%ebx)
}
  800146:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800149:	c9                   	leave  
  80014a:	c3                   	ret    

0080014b <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80014b:	55                   	push   %ebp
  80014c:	89 e5                	mov    %esp,%ebp
  80014e:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800154:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80015b:	00 00 00 
	b.cnt = 0;
  80015e:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800165:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800168:	ff 75 0c             	pushl  0xc(%ebp)
  80016b:	ff 75 08             	pushl  0x8(%ebp)
  80016e:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800174:	50                   	push   %eax
  800175:	68 0c 01 80 00       	push   $0x80010c
  80017a:	e8 82 01 00 00       	call   800301 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80017f:	83 c4 08             	add    $0x8,%esp
  800182:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800188:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80018e:	50                   	push   %eax
  80018f:	e8 89 09 00 00       	call   800b1d <sys_cputs>

	return b.cnt;
}
  800194:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80019a:	c9                   	leave  
  80019b:	c3                   	ret    

0080019c <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80019c:	55                   	push   %ebp
  80019d:	89 e5                	mov    %esp,%ebp
  80019f:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001a2:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001a5:	50                   	push   %eax
  8001a6:	ff 75 08             	pushl  0x8(%ebp)
  8001a9:	e8 9d ff ff ff       	call   80014b <vcprintf>
	va_end(ap);

	return cnt;
}
  8001ae:	c9                   	leave  
  8001af:	c3                   	ret    

008001b0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001b0:	55                   	push   %ebp
  8001b1:	89 e5                	mov    %esp,%ebp
  8001b3:	57                   	push   %edi
  8001b4:	56                   	push   %esi
  8001b5:	53                   	push   %ebx
  8001b6:	83 ec 2c             	sub    $0x2c,%esp
  8001b9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8001bc:	89 d6                	mov    %edx,%esi
  8001be:	8b 45 08             	mov    0x8(%ebp),%eax
  8001c1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001c4:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001c7:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8001ca:	8b 45 10             	mov    0x10(%ebp),%eax
  8001cd:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8001d0:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001d3:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8001d6:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  8001dd:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
  8001e0:	72 0c                	jb     8001ee <printnum+0x3e>
  8001e2:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  8001e5:	76 07                	jbe    8001ee <printnum+0x3e>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8001e7:	4b                   	dec    %ebx
  8001e8:	85 db                	test   %ebx,%ebx
  8001ea:	7f 31                	jg     80021d <printnum+0x6d>
  8001ec:	eb 3f                	jmp    80022d <printnum+0x7d>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001ee:	83 ec 0c             	sub    $0xc,%esp
  8001f1:	57                   	push   %edi
  8001f2:	4b                   	dec    %ebx
  8001f3:	53                   	push   %ebx
  8001f4:	50                   	push   %eax
  8001f5:	83 ec 08             	sub    $0x8,%esp
  8001f8:	ff 75 d4             	pushl  -0x2c(%ebp)
  8001fb:	ff 75 d0             	pushl  -0x30(%ebp)
  8001fe:	ff 75 dc             	pushl  -0x24(%ebp)
  800201:	ff 75 d8             	pushl  -0x28(%ebp)
  800204:	e8 cf 19 00 00       	call   801bd8 <__udivdi3>
  800209:	83 c4 18             	add    $0x18,%esp
  80020c:	52                   	push   %edx
  80020d:	50                   	push   %eax
  80020e:	89 f2                	mov    %esi,%edx
  800210:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800213:	e8 98 ff ff ff       	call   8001b0 <printnum>
  800218:	83 c4 20             	add    $0x20,%esp
  80021b:	eb 10                	jmp    80022d <printnum+0x7d>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80021d:	83 ec 08             	sub    $0x8,%esp
  800220:	56                   	push   %esi
  800221:	57                   	push   %edi
  800222:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800225:	4b                   	dec    %ebx
  800226:	83 c4 10             	add    $0x10,%esp
  800229:	85 db                	test   %ebx,%ebx
  80022b:	7f f0                	jg     80021d <printnum+0x6d>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80022d:	83 ec 08             	sub    $0x8,%esp
  800230:	56                   	push   %esi
  800231:	83 ec 04             	sub    $0x4,%esp
  800234:	ff 75 d4             	pushl  -0x2c(%ebp)
  800237:	ff 75 d0             	pushl  -0x30(%ebp)
  80023a:	ff 75 dc             	pushl  -0x24(%ebp)
  80023d:	ff 75 d8             	pushl  -0x28(%ebp)
  800240:	e8 af 1a 00 00       	call   801cf4 <__umoddi3>
  800245:	83 c4 14             	add    $0x14,%esp
  800248:	0f be 80 52 1e 80 00 	movsbl 0x801e52(%eax),%eax
  80024f:	50                   	push   %eax
  800250:	ff 55 e4             	call   *-0x1c(%ebp)
  800253:	83 c4 10             	add    $0x10,%esp
}
  800256:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800259:	5b                   	pop    %ebx
  80025a:	5e                   	pop    %esi
  80025b:	5f                   	pop    %edi
  80025c:	c9                   	leave  
  80025d:	c3                   	ret    

0080025e <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80025e:	55                   	push   %ebp
  80025f:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800261:	83 fa 01             	cmp    $0x1,%edx
  800264:	7e 0e                	jle    800274 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800266:	8b 10                	mov    (%eax),%edx
  800268:	8d 4a 08             	lea    0x8(%edx),%ecx
  80026b:	89 08                	mov    %ecx,(%eax)
  80026d:	8b 02                	mov    (%edx),%eax
  80026f:	8b 52 04             	mov    0x4(%edx),%edx
  800272:	eb 22                	jmp    800296 <getuint+0x38>
	else if (lflag)
  800274:	85 d2                	test   %edx,%edx
  800276:	74 10                	je     800288 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800278:	8b 10                	mov    (%eax),%edx
  80027a:	8d 4a 04             	lea    0x4(%edx),%ecx
  80027d:	89 08                	mov    %ecx,(%eax)
  80027f:	8b 02                	mov    (%edx),%eax
  800281:	ba 00 00 00 00       	mov    $0x0,%edx
  800286:	eb 0e                	jmp    800296 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800288:	8b 10                	mov    (%eax),%edx
  80028a:	8d 4a 04             	lea    0x4(%edx),%ecx
  80028d:	89 08                	mov    %ecx,(%eax)
  80028f:	8b 02                	mov    (%edx),%eax
  800291:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800296:	c9                   	leave  
  800297:	c3                   	ret    

00800298 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  800298:	55                   	push   %ebp
  800299:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80029b:	83 fa 01             	cmp    $0x1,%edx
  80029e:	7e 0e                	jle    8002ae <getint+0x16>
		return va_arg(*ap, long long);
  8002a0:	8b 10                	mov    (%eax),%edx
  8002a2:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002a5:	89 08                	mov    %ecx,(%eax)
  8002a7:	8b 02                	mov    (%edx),%eax
  8002a9:	8b 52 04             	mov    0x4(%edx),%edx
  8002ac:	eb 1a                	jmp    8002c8 <getint+0x30>
	else if (lflag)
  8002ae:	85 d2                	test   %edx,%edx
  8002b0:	74 0c                	je     8002be <getint+0x26>
		return va_arg(*ap, long);
  8002b2:	8b 10                	mov    (%eax),%edx
  8002b4:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002b7:	89 08                	mov    %ecx,(%eax)
  8002b9:	8b 02                	mov    (%edx),%eax
  8002bb:	99                   	cltd   
  8002bc:	eb 0a                	jmp    8002c8 <getint+0x30>
	else
		return va_arg(*ap, int);
  8002be:	8b 10                	mov    (%eax),%edx
  8002c0:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002c3:	89 08                	mov    %ecx,(%eax)
  8002c5:	8b 02                	mov    (%edx),%eax
  8002c7:	99                   	cltd   
}
  8002c8:	c9                   	leave  
  8002c9:	c3                   	ret    

008002ca <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002ca:	55                   	push   %ebp
  8002cb:	89 e5                	mov    %esp,%ebp
  8002cd:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002d0:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  8002d3:	8b 10                	mov    (%eax),%edx
  8002d5:	3b 50 04             	cmp    0x4(%eax),%edx
  8002d8:	73 08                	jae    8002e2 <sprintputch+0x18>
		*b->buf++ = ch;
  8002da:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8002dd:	88 0a                	mov    %cl,(%edx)
  8002df:	42                   	inc    %edx
  8002e0:	89 10                	mov    %edx,(%eax)
}
  8002e2:	c9                   	leave  
  8002e3:	c3                   	ret    

008002e4 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8002e4:	55                   	push   %ebp
  8002e5:	89 e5                	mov    %esp,%ebp
  8002e7:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8002ea:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002ed:	50                   	push   %eax
  8002ee:	ff 75 10             	pushl  0x10(%ebp)
  8002f1:	ff 75 0c             	pushl  0xc(%ebp)
  8002f4:	ff 75 08             	pushl  0x8(%ebp)
  8002f7:	e8 05 00 00 00       	call   800301 <vprintfmt>
	va_end(ap);
  8002fc:	83 c4 10             	add    $0x10,%esp
}
  8002ff:	c9                   	leave  
  800300:	c3                   	ret    

00800301 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800301:	55                   	push   %ebp
  800302:	89 e5                	mov    %esp,%ebp
  800304:	57                   	push   %edi
  800305:	56                   	push   %esi
  800306:	53                   	push   %ebx
  800307:	83 ec 2c             	sub    $0x2c,%esp
  80030a:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80030d:	8b 75 10             	mov    0x10(%ebp),%esi
  800310:	eb 13                	jmp    800325 <vprintfmt+0x24>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800312:	85 c0                	test   %eax,%eax
  800314:	0f 84 6d 03 00 00    	je     800687 <vprintfmt+0x386>
				return;
			putch(ch, putdat);
  80031a:	83 ec 08             	sub    $0x8,%esp
  80031d:	57                   	push   %edi
  80031e:	50                   	push   %eax
  80031f:	ff 55 08             	call   *0x8(%ebp)
  800322:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800325:	0f b6 06             	movzbl (%esi),%eax
  800328:	46                   	inc    %esi
  800329:	83 f8 25             	cmp    $0x25,%eax
  80032c:	75 e4                	jne    800312 <vprintfmt+0x11>
  80032e:	c6 45 dc 20          	movb   $0x20,-0x24(%ebp)
  800332:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  800339:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  800340:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800347:	b9 00 00 00 00       	mov    $0x0,%ecx
  80034c:	eb 28                	jmp    800376 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80034e:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800350:	c6 45 dc 2d          	movb   $0x2d,-0x24(%ebp)
  800354:	eb 20                	jmp    800376 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800356:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800358:	c6 45 dc 30          	movb   $0x30,-0x24(%ebp)
  80035c:	eb 18                	jmp    800376 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80035e:	89 de                	mov    %ebx,%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800360:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800367:	eb 0d                	jmp    800376 <vprintfmt+0x75>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800369:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80036c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80036f:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800376:	8a 06                	mov    (%esi),%al
  800378:	0f b6 d0             	movzbl %al,%edx
  80037b:	8d 5e 01             	lea    0x1(%esi),%ebx
  80037e:	83 e8 23             	sub    $0x23,%eax
  800381:	3c 55                	cmp    $0x55,%al
  800383:	0f 87 e0 02 00 00    	ja     800669 <vprintfmt+0x368>
  800389:	0f b6 c0             	movzbl %al,%eax
  80038c:	ff 24 85 a0 1f 80 00 	jmp    *0x801fa0(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800393:	83 ea 30             	sub    $0x30,%edx
  800396:	89 55 d4             	mov    %edx,-0x2c(%ebp)
				ch = *fmt;
  800399:	0f be 03             	movsbl (%ebx),%eax
				if (ch < '0' || ch > '9')
  80039c:	8d 50 d0             	lea    -0x30(%eax),%edx
  80039f:	83 fa 09             	cmp    $0x9,%edx
  8003a2:	77 44                	ja     8003e8 <vprintfmt+0xe7>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003a4:	89 de                	mov    %ebx,%esi
  8003a6:	8b 55 d4             	mov    -0x2c(%ebp),%edx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003a9:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
  8003aa:	8d 14 92             	lea    (%edx,%edx,4),%edx
  8003ad:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
  8003b1:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8003b4:	8d 58 d0             	lea    -0x30(%eax),%ebx
  8003b7:	83 fb 09             	cmp    $0x9,%ebx
  8003ba:	76 ed                	jbe    8003a9 <vprintfmt+0xa8>
  8003bc:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  8003bf:	eb 29                	jmp    8003ea <vprintfmt+0xe9>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003c1:	8b 45 14             	mov    0x14(%ebp),%eax
  8003c4:	8d 50 04             	lea    0x4(%eax),%edx
  8003c7:	89 55 14             	mov    %edx,0x14(%ebp)
  8003ca:	8b 00                	mov    (%eax),%eax
  8003cc:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003cf:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8003d1:	eb 17                	jmp    8003ea <vprintfmt+0xe9>

		case '.':
			if (width < 0)
  8003d3:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8003d7:	78 85                	js     80035e <vprintfmt+0x5d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003d9:	89 de                	mov    %ebx,%esi
  8003db:	eb 99                	jmp    800376 <vprintfmt+0x75>
  8003dd:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8003df:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  8003e6:	eb 8e                	jmp    800376 <vprintfmt+0x75>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003e8:	89 de                	mov    %ebx,%esi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  8003ea:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8003ee:	79 86                	jns    800376 <vprintfmt+0x75>
  8003f0:	e9 74 ff ff ff       	jmp    800369 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8003f5:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003f6:	89 de                	mov    %ebx,%esi
  8003f8:	e9 79 ff ff ff       	jmp    800376 <vprintfmt+0x75>
  8003fd:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800400:	8b 45 14             	mov    0x14(%ebp),%eax
  800403:	8d 50 04             	lea    0x4(%eax),%edx
  800406:	89 55 14             	mov    %edx,0x14(%ebp)
  800409:	83 ec 08             	sub    $0x8,%esp
  80040c:	57                   	push   %edi
  80040d:	ff 30                	pushl  (%eax)
  80040f:	ff 55 08             	call   *0x8(%ebp)
			break;
  800412:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800415:	8b 75 d8             	mov    -0x28(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800418:	e9 08 ff ff ff       	jmp    800325 <vprintfmt+0x24>
  80041d:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  800420:	8b 45 14             	mov    0x14(%ebp),%eax
  800423:	8d 50 04             	lea    0x4(%eax),%edx
  800426:	89 55 14             	mov    %edx,0x14(%ebp)
  800429:	8b 00                	mov    (%eax),%eax
  80042b:	85 c0                	test   %eax,%eax
  80042d:	79 02                	jns    800431 <vprintfmt+0x130>
  80042f:	f7 d8                	neg    %eax
  800431:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800433:	83 f8 0f             	cmp    $0xf,%eax
  800436:	7f 0b                	jg     800443 <vprintfmt+0x142>
  800438:	8b 04 85 00 21 80 00 	mov    0x802100(,%eax,4),%eax
  80043f:	85 c0                	test   %eax,%eax
  800441:	75 1a                	jne    80045d <vprintfmt+0x15c>
				printfmt(putch, putdat, "error %d", err);
  800443:	52                   	push   %edx
  800444:	68 6a 1e 80 00       	push   $0x801e6a
  800449:	57                   	push   %edi
  80044a:	ff 75 08             	pushl  0x8(%ebp)
  80044d:	e8 92 fe ff ff       	call   8002e4 <printfmt>
  800452:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800455:	8b 75 d8             	mov    -0x28(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800458:	e9 c8 fe ff ff       	jmp    800325 <vprintfmt+0x24>
			else
				printfmt(putch, putdat, "%s", p);
  80045d:	50                   	push   %eax
  80045e:	68 4d 22 80 00       	push   $0x80224d
  800463:	57                   	push   %edi
  800464:	ff 75 08             	pushl  0x8(%ebp)
  800467:	e8 78 fe ff ff       	call   8002e4 <printfmt>
  80046c:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80046f:	8b 75 d8             	mov    -0x28(%ebp),%esi
  800472:	e9 ae fe ff ff       	jmp    800325 <vprintfmt+0x24>
  800477:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  80047a:	89 de                	mov    %ebx,%esi
  80047c:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  80047f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800482:	8b 45 14             	mov    0x14(%ebp),%eax
  800485:	8d 50 04             	lea    0x4(%eax),%edx
  800488:	89 55 14             	mov    %edx,0x14(%ebp)
  80048b:	8b 00                	mov    (%eax),%eax
  80048d:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800490:	85 c0                	test   %eax,%eax
  800492:	75 07                	jne    80049b <vprintfmt+0x19a>
				p = "(null)";
  800494:	c7 45 d0 63 1e 80 00 	movl   $0x801e63,-0x30(%ebp)
			if (width > 0 && padc != '-')
  80049b:	85 db                	test   %ebx,%ebx
  80049d:	7e 42                	jle    8004e1 <vprintfmt+0x1e0>
  80049f:	80 7d dc 2d          	cmpb   $0x2d,-0x24(%ebp)
  8004a3:	74 3c                	je     8004e1 <vprintfmt+0x1e0>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004a5:	83 ec 08             	sub    $0x8,%esp
  8004a8:	51                   	push   %ecx
  8004a9:	ff 75 d0             	pushl  -0x30(%ebp)
  8004ac:	e8 6f 02 00 00       	call   800720 <strnlen>
  8004b1:	29 c3                	sub    %eax,%ebx
  8004b3:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8004b6:	83 c4 10             	add    $0x10,%esp
  8004b9:	85 db                	test   %ebx,%ebx
  8004bb:	7e 24                	jle    8004e1 <vprintfmt+0x1e0>
					putch(padc, putdat);
  8004bd:	0f be 5d dc          	movsbl -0x24(%ebp),%ebx
  8004c1:	89 75 dc             	mov    %esi,-0x24(%ebp)
  8004c4:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  8004c7:	83 ec 08             	sub    $0x8,%esp
  8004ca:	57                   	push   %edi
  8004cb:	53                   	push   %ebx
  8004cc:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004cf:	4e                   	dec    %esi
  8004d0:	83 c4 10             	add    $0x10,%esp
  8004d3:	85 f6                	test   %esi,%esi
  8004d5:	7f f0                	jg     8004c7 <vprintfmt+0x1c6>
  8004d7:	8b 75 dc             	mov    -0x24(%ebp),%esi
  8004da:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004e1:	8b 55 d0             	mov    -0x30(%ebp),%edx
  8004e4:	0f be 02             	movsbl (%edx),%eax
  8004e7:	85 c0                	test   %eax,%eax
  8004e9:	75 47                	jne    800532 <vprintfmt+0x231>
  8004eb:	eb 37                	jmp    800524 <vprintfmt+0x223>
				if (altflag && (ch < ' ' || ch > '~'))
  8004ed:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004f1:	74 16                	je     800509 <vprintfmt+0x208>
  8004f3:	8d 50 e0             	lea    -0x20(%eax),%edx
  8004f6:	83 fa 5e             	cmp    $0x5e,%edx
  8004f9:	76 0e                	jbe    800509 <vprintfmt+0x208>
					putch('?', putdat);
  8004fb:	83 ec 08             	sub    $0x8,%esp
  8004fe:	57                   	push   %edi
  8004ff:	6a 3f                	push   $0x3f
  800501:	ff 55 08             	call   *0x8(%ebp)
  800504:	83 c4 10             	add    $0x10,%esp
  800507:	eb 0b                	jmp    800514 <vprintfmt+0x213>
				else
					putch(ch, putdat);
  800509:	83 ec 08             	sub    $0x8,%esp
  80050c:	57                   	push   %edi
  80050d:	50                   	push   %eax
  80050e:	ff 55 08             	call   *0x8(%ebp)
  800511:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800514:	ff 4d e4             	decl   -0x1c(%ebp)
  800517:	0f be 03             	movsbl (%ebx),%eax
  80051a:	85 c0                	test   %eax,%eax
  80051c:	74 03                	je     800521 <vprintfmt+0x220>
  80051e:	43                   	inc    %ebx
  80051f:	eb 1b                	jmp    80053c <vprintfmt+0x23b>
  800521:	8b 75 dc             	mov    -0x24(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800524:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800528:	7f 1e                	jg     800548 <vprintfmt+0x247>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80052a:	8b 75 d8             	mov    -0x28(%ebp),%esi
  80052d:	e9 f3 fd ff ff       	jmp    800325 <vprintfmt+0x24>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800532:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800535:	43                   	inc    %ebx
  800536:	89 75 dc             	mov    %esi,-0x24(%ebp)
  800539:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  80053c:	85 f6                	test   %esi,%esi
  80053e:	78 ad                	js     8004ed <vprintfmt+0x1ec>
  800540:	4e                   	dec    %esi
  800541:	79 aa                	jns    8004ed <vprintfmt+0x1ec>
  800543:	8b 75 dc             	mov    -0x24(%ebp),%esi
  800546:	eb dc                	jmp    800524 <vprintfmt+0x223>
  800548:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80054b:	83 ec 08             	sub    $0x8,%esp
  80054e:	57                   	push   %edi
  80054f:	6a 20                	push   $0x20
  800551:	ff 55 08             	call   *0x8(%ebp)
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800554:	4b                   	dec    %ebx
  800555:	83 c4 10             	add    $0x10,%esp
  800558:	85 db                	test   %ebx,%ebx
  80055a:	7f ef                	jg     80054b <vprintfmt+0x24a>
  80055c:	e9 c4 fd ff ff       	jmp    800325 <vprintfmt+0x24>
  800561:	89 5d d8             	mov    %ebx,-0x28(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800564:	89 ca                	mov    %ecx,%edx
  800566:	8d 45 14             	lea    0x14(%ebp),%eax
  800569:	e8 2a fd ff ff       	call   800298 <getint>
  80056e:	89 c3                	mov    %eax,%ebx
  800570:	89 d6                	mov    %edx,%esi
			if ((long long) num < 0) {
  800572:	85 d2                	test   %edx,%edx
  800574:	78 0a                	js     800580 <vprintfmt+0x27f>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800576:	b8 0a 00 00 00       	mov    $0xa,%eax
  80057b:	e9 b0 00 00 00       	jmp    800630 <vprintfmt+0x32f>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  800580:	83 ec 08             	sub    $0x8,%esp
  800583:	57                   	push   %edi
  800584:	6a 2d                	push   $0x2d
  800586:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800589:	f7 db                	neg    %ebx
  80058b:	83 d6 00             	adc    $0x0,%esi
  80058e:	f7 de                	neg    %esi
  800590:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800593:	b8 0a 00 00 00       	mov    $0xa,%eax
  800598:	e9 93 00 00 00       	jmp    800630 <vprintfmt+0x32f>
  80059d:	89 5d d8             	mov    %ebx,-0x28(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8005a0:	89 ca                	mov    %ecx,%edx
  8005a2:	8d 45 14             	lea    0x14(%ebp),%eax
  8005a5:	e8 b4 fc ff ff       	call   80025e <getuint>
  8005aa:	89 c3                	mov    %eax,%ebx
  8005ac:	89 d6                	mov    %edx,%esi
			base = 10;
  8005ae:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  8005b3:	eb 7b                	jmp    800630 <vprintfmt+0x32f>
  8005b5:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
  8005b8:	89 ca                	mov    %ecx,%edx
  8005ba:	8d 45 14             	lea    0x14(%ebp),%eax
  8005bd:	e8 d6 fc ff ff       	call   800298 <getint>
  8005c2:	89 c3                	mov    %eax,%ebx
  8005c4:	89 d6                	mov    %edx,%esi
            if ((long long) num < 0) {
  8005c6:	85 d2                	test   %edx,%edx
  8005c8:	78 07                	js     8005d1 <vprintfmt+0x2d0>
                putch('-', putdat);
                num = -(long long) num;
            }
            base = 8;
  8005ca:	b8 08 00 00 00       	mov    $0x8,%eax
  8005cf:	eb 5f                	jmp    800630 <vprintfmt+0x32f>
		// (unsigned) octal
		case 'o':
            // (MIT 6.828, lab1, Ex.8)  my code : 
            num = getint(&ap, lflag);
            if ((long long) num < 0) {
                putch('-', putdat);
  8005d1:	83 ec 08             	sub    $0x8,%esp
  8005d4:	57                   	push   %edi
  8005d5:	6a 2d                	push   $0x2d
  8005d7:	ff 55 08             	call   *0x8(%ebp)
                num = -(long long) num;
  8005da:	f7 db                	neg    %ebx
  8005dc:	83 d6 00             	adc    $0x0,%esi
  8005df:	f7 de                	neg    %esi
  8005e1:	83 c4 10             	add    $0x10,%esp
            }
            base = 8;
  8005e4:	b8 08 00 00 00       	mov    $0x8,%eax
  8005e9:	eb 45                	jmp    800630 <vprintfmt+0x32f>
  8005eb:	89 5d d8             	mov    %ebx,-0x28(%ebp)
            goto number;

        // pointer
		case 'p':
			putch('0', putdat);
  8005ee:	83 ec 08             	sub    $0x8,%esp
  8005f1:	57                   	push   %edi
  8005f2:	6a 30                	push   $0x30
  8005f4:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8005f7:	83 c4 08             	add    $0x8,%esp
  8005fa:	57                   	push   %edi
  8005fb:	6a 78                	push   $0x78
  8005fd:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800600:	8b 45 14             	mov    0x14(%ebp),%eax
  800603:	8d 50 04             	lea    0x4(%eax),%edx
  800606:	89 55 14             	mov    %edx,0x14(%ebp)

        // pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800609:	8b 18                	mov    (%eax),%ebx
  80060b:	be 00 00 00 00       	mov    $0x0,%esi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800610:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800613:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800618:	eb 16                	jmp    800630 <vprintfmt+0x32f>
  80061a:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80061d:	89 ca                	mov    %ecx,%edx
  80061f:	8d 45 14             	lea    0x14(%ebp),%eax
  800622:	e8 37 fc ff ff       	call   80025e <getuint>
  800627:	89 c3                	mov    %eax,%ebx
  800629:	89 d6                	mov    %edx,%esi
			base = 16;
  80062b:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800630:	83 ec 0c             	sub    $0xc,%esp
  800633:	0f be 55 dc          	movsbl -0x24(%ebp),%edx
  800637:	52                   	push   %edx
  800638:	ff 75 e4             	pushl  -0x1c(%ebp)
  80063b:	50                   	push   %eax
  80063c:	56                   	push   %esi
  80063d:	53                   	push   %ebx
  80063e:	89 fa                	mov    %edi,%edx
  800640:	8b 45 08             	mov    0x8(%ebp),%eax
  800643:	e8 68 fb ff ff       	call   8001b0 <printnum>
			break;
  800648:	83 c4 20             	add    $0x20,%esp
  80064b:	8b 75 d8             	mov    -0x28(%ebp),%esi
  80064e:	e9 d2 fc ff ff       	jmp    800325 <vprintfmt+0x24>
  800653:	89 5d d8             	mov    %ebx,-0x28(%ebp)

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800656:	83 ec 08             	sub    $0x8,%esp
  800659:	57                   	push   %edi
  80065a:	52                   	push   %edx
  80065b:	ff 55 08             	call   *0x8(%ebp)
			break;
  80065e:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800661:	8b 75 d8             	mov    -0x28(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800664:	e9 bc fc ff ff       	jmp    800325 <vprintfmt+0x24>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800669:	83 ec 08             	sub    $0x8,%esp
  80066c:	57                   	push   %edi
  80066d:	6a 25                	push   $0x25
  80066f:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800672:	83 c4 10             	add    $0x10,%esp
  800675:	eb 02                	jmp    800679 <vprintfmt+0x378>
  800677:	89 c6                	mov    %eax,%esi
  800679:	8d 46 ff             	lea    -0x1(%esi),%eax
  80067c:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800680:	75 f5                	jne    800677 <vprintfmt+0x376>
  800682:	e9 9e fc ff ff       	jmp    800325 <vprintfmt+0x24>
				/* do nothing */;
			break;
		}
	}
}
  800687:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80068a:	5b                   	pop    %ebx
  80068b:	5e                   	pop    %esi
  80068c:	5f                   	pop    %edi
  80068d:	c9                   	leave  
  80068e:	c3                   	ret    

0080068f <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80068f:	55                   	push   %ebp
  800690:	89 e5                	mov    %esp,%ebp
  800692:	83 ec 18             	sub    $0x18,%esp
  800695:	8b 45 08             	mov    0x8(%ebp),%eax
  800698:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80069b:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80069e:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8006a2:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8006a5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8006ac:	85 c0                	test   %eax,%eax
  8006ae:	74 26                	je     8006d6 <vsnprintf+0x47>
  8006b0:	85 d2                	test   %edx,%edx
  8006b2:	7e 29                	jle    8006dd <vsnprintf+0x4e>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8006b4:	ff 75 14             	pushl  0x14(%ebp)
  8006b7:	ff 75 10             	pushl  0x10(%ebp)
  8006ba:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8006bd:	50                   	push   %eax
  8006be:	68 ca 02 80 00       	push   $0x8002ca
  8006c3:	e8 39 fc ff ff       	call   800301 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8006c8:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8006cb:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8006ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006d1:	83 c4 10             	add    $0x10,%esp
  8006d4:	eb 0c                	jmp    8006e2 <vsnprintf+0x53>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8006d6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8006db:	eb 05                	jmp    8006e2 <vsnprintf+0x53>
  8006dd:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8006e2:	c9                   	leave  
  8006e3:	c3                   	ret    

008006e4 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8006e4:	55                   	push   %ebp
  8006e5:	89 e5                	mov    %esp,%ebp
  8006e7:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8006ea:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8006ed:	50                   	push   %eax
  8006ee:	ff 75 10             	pushl  0x10(%ebp)
  8006f1:	ff 75 0c             	pushl  0xc(%ebp)
  8006f4:	ff 75 08             	pushl  0x8(%ebp)
  8006f7:	e8 93 ff ff ff       	call   80068f <vsnprintf>
	va_end(ap);

	return rc;
}
  8006fc:	c9                   	leave  
  8006fd:	c3                   	ret    
	...

00800700 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800700:	55                   	push   %ebp
  800701:	89 e5                	mov    %esp,%ebp
  800703:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800706:	80 3a 00             	cmpb   $0x0,(%edx)
  800709:	74 0e                	je     800719 <strlen+0x19>
  80070b:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800710:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800711:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800715:	75 f9                	jne    800710 <strlen+0x10>
  800717:	eb 05                	jmp    80071e <strlen+0x1e>
  800719:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  80071e:	c9                   	leave  
  80071f:	c3                   	ret    

00800720 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800720:	55                   	push   %ebp
  800721:	89 e5                	mov    %esp,%ebp
  800723:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800726:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800729:	85 d2                	test   %edx,%edx
  80072b:	74 17                	je     800744 <strnlen+0x24>
  80072d:	80 39 00             	cmpb   $0x0,(%ecx)
  800730:	74 19                	je     80074b <strnlen+0x2b>
  800732:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800737:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800738:	39 d0                	cmp    %edx,%eax
  80073a:	74 14                	je     800750 <strnlen+0x30>
  80073c:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800740:	75 f5                	jne    800737 <strnlen+0x17>
  800742:	eb 0c                	jmp    800750 <strnlen+0x30>
  800744:	b8 00 00 00 00       	mov    $0x0,%eax
  800749:	eb 05                	jmp    800750 <strnlen+0x30>
  80074b:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800750:	c9                   	leave  
  800751:	c3                   	ret    

00800752 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800752:	55                   	push   %ebp
  800753:	89 e5                	mov    %esp,%ebp
  800755:	53                   	push   %ebx
  800756:	8b 45 08             	mov    0x8(%ebp),%eax
  800759:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80075c:	ba 00 00 00 00       	mov    $0x0,%edx
  800761:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  800764:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800767:	42                   	inc    %edx
  800768:	84 c9                	test   %cl,%cl
  80076a:	75 f5                	jne    800761 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  80076c:	5b                   	pop    %ebx
  80076d:	c9                   	leave  
  80076e:	c3                   	ret    

0080076f <strcat>:

char *
strcat(char *dst, const char *src)
{
  80076f:	55                   	push   %ebp
  800770:	89 e5                	mov    %esp,%ebp
  800772:	53                   	push   %ebx
  800773:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800776:	53                   	push   %ebx
  800777:	e8 84 ff ff ff       	call   800700 <strlen>
  80077c:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  80077f:	ff 75 0c             	pushl  0xc(%ebp)
  800782:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  800785:	50                   	push   %eax
  800786:	e8 c7 ff ff ff       	call   800752 <strcpy>
	return dst;
}
  80078b:	89 d8                	mov    %ebx,%eax
  80078d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800790:	c9                   	leave  
  800791:	c3                   	ret    

00800792 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800792:	55                   	push   %ebp
  800793:	89 e5                	mov    %esp,%ebp
  800795:	56                   	push   %esi
  800796:	53                   	push   %ebx
  800797:	8b 45 08             	mov    0x8(%ebp),%eax
  80079a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80079d:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007a0:	85 f6                	test   %esi,%esi
  8007a2:	74 15                	je     8007b9 <strncpy+0x27>
  8007a4:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  8007a9:	8a 1a                	mov    (%edx),%bl
  8007ab:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007ae:	80 3a 01             	cmpb   $0x1,(%edx)
  8007b1:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007b4:	41                   	inc    %ecx
  8007b5:	39 ce                	cmp    %ecx,%esi
  8007b7:	77 f0                	ja     8007a9 <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8007b9:	5b                   	pop    %ebx
  8007ba:	5e                   	pop    %esi
  8007bb:	c9                   	leave  
  8007bc:	c3                   	ret    

008007bd <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8007bd:	55                   	push   %ebp
  8007be:	89 e5                	mov    %esp,%ebp
  8007c0:	57                   	push   %edi
  8007c1:	56                   	push   %esi
  8007c2:	53                   	push   %ebx
  8007c3:	8b 7d 08             	mov    0x8(%ebp),%edi
  8007c6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8007c9:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007cc:	85 f6                	test   %esi,%esi
  8007ce:	74 32                	je     800802 <strlcpy+0x45>
		while (--size > 0 && *src != '\0')
  8007d0:	83 fe 01             	cmp    $0x1,%esi
  8007d3:	74 22                	je     8007f7 <strlcpy+0x3a>
  8007d5:	8a 0b                	mov    (%ebx),%cl
  8007d7:	84 c9                	test   %cl,%cl
  8007d9:	74 20                	je     8007fb <strlcpy+0x3e>
  8007db:	89 f8                	mov    %edi,%eax
  8007dd:	ba 00 00 00 00       	mov    $0x0,%edx
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
  8007e2:	83 ee 02             	sub    $0x2,%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8007e5:	88 08                	mov    %cl,(%eax)
  8007e7:	40                   	inc    %eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8007e8:	39 f2                	cmp    %esi,%edx
  8007ea:	74 11                	je     8007fd <strlcpy+0x40>
  8007ec:	8a 4c 13 01          	mov    0x1(%ebx,%edx,1),%cl
  8007f0:	42                   	inc    %edx
  8007f1:	84 c9                	test   %cl,%cl
  8007f3:	75 f0                	jne    8007e5 <strlcpy+0x28>
  8007f5:	eb 06                	jmp    8007fd <strlcpy+0x40>
  8007f7:	89 f8                	mov    %edi,%eax
  8007f9:	eb 02                	jmp    8007fd <strlcpy+0x40>
  8007fb:	89 f8                	mov    %edi,%eax
			*dst++ = *src++;
		*dst = '\0';
  8007fd:	c6 00 00             	movb   $0x0,(%eax)
  800800:	eb 02                	jmp    800804 <strlcpy+0x47>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800802:	89 f8                	mov    %edi,%eax
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
		*dst = '\0';
	}
	return dst - dst_in;
  800804:	29 f8                	sub    %edi,%eax
}
  800806:	5b                   	pop    %ebx
  800807:	5e                   	pop    %esi
  800808:	5f                   	pop    %edi
  800809:	c9                   	leave  
  80080a:	c3                   	ret    

0080080b <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80080b:	55                   	push   %ebp
  80080c:	89 e5                	mov    %esp,%ebp
  80080e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800811:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800814:	8a 01                	mov    (%ecx),%al
  800816:	84 c0                	test   %al,%al
  800818:	74 10                	je     80082a <strcmp+0x1f>
  80081a:	3a 02                	cmp    (%edx),%al
  80081c:	75 0c                	jne    80082a <strcmp+0x1f>
		p++, q++;
  80081e:	41                   	inc    %ecx
  80081f:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800820:	8a 01                	mov    (%ecx),%al
  800822:	84 c0                	test   %al,%al
  800824:	74 04                	je     80082a <strcmp+0x1f>
  800826:	3a 02                	cmp    (%edx),%al
  800828:	74 f4                	je     80081e <strcmp+0x13>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80082a:	0f b6 c0             	movzbl %al,%eax
  80082d:	0f b6 12             	movzbl (%edx),%edx
  800830:	29 d0                	sub    %edx,%eax
}
  800832:	c9                   	leave  
  800833:	c3                   	ret    

00800834 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800834:	55                   	push   %ebp
  800835:	89 e5                	mov    %esp,%ebp
  800837:	53                   	push   %ebx
  800838:	8b 55 08             	mov    0x8(%ebp),%edx
  80083b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80083e:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  800841:	85 c0                	test   %eax,%eax
  800843:	74 1b                	je     800860 <strncmp+0x2c>
  800845:	8a 1a                	mov    (%edx),%bl
  800847:	84 db                	test   %bl,%bl
  800849:	74 24                	je     80086f <strncmp+0x3b>
  80084b:	3a 19                	cmp    (%ecx),%bl
  80084d:	75 20                	jne    80086f <strncmp+0x3b>
  80084f:	48                   	dec    %eax
  800850:	74 15                	je     800867 <strncmp+0x33>
		n--, p++, q++;
  800852:	42                   	inc    %edx
  800853:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800854:	8a 1a                	mov    (%edx),%bl
  800856:	84 db                	test   %bl,%bl
  800858:	74 15                	je     80086f <strncmp+0x3b>
  80085a:	3a 19                	cmp    (%ecx),%bl
  80085c:	74 f1                	je     80084f <strncmp+0x1b>
  80085e:	eb 0f                	jmp    80086f <strncmp+0x3b>
		n--, p++, q++;
	if (n == 0)
		return 0;
  800860:	b8 00 00 00 00       	mov    $0x0,%eax
  800865:	eb 05                	jmp    80086c <strncmp+0x38>
  800867:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80086c:	5b                   	pop    %ebx
  80086d:	c9                   	leave  
  80086e:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80086f:	0f b6 02             	movzbl (%edx),%eax
  800872:	0f b6 11             	movzbl (%ecx),%edx
  800875:	29 d0                	sub    %edx,%eax
  800877:	eb f3                	jmp    80086c <strncmp+0x38>

00800879 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800879:	55                   	push   %ebp
  80087a:	89 e5                	mov    %esp,%ebp
  80087c:	8b 45 08             	mov    0x8(%ebp),%eax
  80087f:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800882:	8a 10                	mov    (%eax),%dl
  800884:	84 d2                	test   %dl,%dl
  800886:	74 18                	je     8008a0 <strchr+0x27>
		if (*s == c)
  800888:	38 ca                	cmp    %cl,%dl
  80088a:	75 06                	jne    800892 <strchr+0x19>
  80088c:	eb 17                	jmp    8008a5 <strchr+0x2c>
  80088e:	38 ca                	cmp    %cl,%dl
  800890:	74 13                	je     8008a5 <strchr+0x2c>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800892:	40                   	inc    %eax
  800893:	8a 10                	mov    (%eax),%dl
  800895:	84 d2                	test   %dl,%dl
  800897:	75 f5                	jne    80088e <strchr+0x15>
		if (*s == c)
			return (char *) s;
	return 0;
  800899:	b8 00 00 00 00       	mov    $0x0,%eax
  80089e:	eb 05                	jmp    8008a5 <strchr+0x2c>
  8008a0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008a5:	c9                   	leave  
  8008a6:	c3                   	ret    

008008a7 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008a7:	55                   	push   %ebp
  8008a8:	89 e5                	mov    %esp,%ebp
  8008aa:	8b 45 08             	mov    0x8(%ebp),%eax
  8008ad:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8008b0:	8a 10                	mov    (%eax),%dl
  8008b2:	84 d2                	test   %dl,%dl
  8008b4:	74 11                	je     8008c7 <strfind+0x20>
		if (*s == c)
  8008b6:	38 ca                	cmp    %cl,%dl
  8008b8:	75 06                	jne    8008c0 <strfind+0x19>
  8008ba:	eb 0b                	jmp    8008c7 <strfind+0x20>
  8008bc:	38 ca                	cmp    %cl,%dl
  8008be:	74 07                	je     8008c7 <strfind+0x20>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  8008c0:	40                   	inc    %eax
  8008c1:	8a 10                	mov    (%eax),%dl
  8008c3:	84 d2                	test   %dl,%dl
  8008c5:	75 f5                	jne    8008bc <strfind+0x15>
		if (*s == c)
			break;
	return (char *) s;
}
  8008c7:	c9                   	leave  
  8008c8:	c3                   	ret    

008008c9 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008c9:	55                   	push   %ebp
  8008ca:	89 e5                	mov    %esp,%ebp
  8008cc:	57                   	push   %edi
  8008cd:	56                   	push   %esi
  8008ce:	53                   	push   %ebx
  8008cf:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008d2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008d5:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8008d8:	85 c9                	test   %ecx,%ecx
  8008da:	74 30                	je     80090c <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008dc:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008e2:	75 25                	jne    800909 <memset+0x40>
  8008e4:	f6 c1 03             	test   $0x3,%cl
  8008e7:	75 20                	jne    800909 <memset+0x40>
		c &= 0xFF;
  8008e9:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8008ec:	89 d3                	mov    %edx,%ebx
  8008ee:	c1 e3 08             	shl    $0x8,%ebx
  8008f1:	89 d6                	mov    %edx,%esi
  8008f3:	c1 e6 18             	shl    $0x18,%esi
  8008f6:	89 d0                	mov    %edx,%eax
  8008f8:	c1 e0 10             	shl    $0x10,%eax
  8008fb:	09 f0                	or     %esi,%eax
  8008fd:	09 d0                	or     %edx,%eax
  8008ff:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800901:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800904:	fc                   	cld    
  800905:	f3 ab                	rep stos %eax,%es:(%edi)
  800907:	eb 03                	jmp    80090c <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800909:	fc                   	cld    
  80090a:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80090c:	89 f8                	mov    %edi,%eax
  80090e:	5b                   	pop    %ebx
  80090f:	5e                   	pop    %esi
  800910:	5f                   	pop    %edi
  800911:	c9                   	leave  
  800912:	c3                   	ret    

00800913 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800913:	55                   	push   %ebp
  800914:	89 e5                	mov    %esp,%ebp
  800916:	57                   	push   %edi
  800917:	56                   	push   %esi
  800918:	8b 45 08             	mov    0x8(%ebp),%eax
  80091b:	8b 75 0c             	mov    0xc(%ebp),%esi
  80091e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800921:	39 c6                	cmp    %eax,%esi
  800923:	73 34                	jae    800959 <memmove+0x46>
  800925:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800928:	39 d0                	cmp    %edx,%eax
  80092a:	73 2d                	jae    800959 <memmove+0x46>
		s += n;
		d += n;
  80092c:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80092f:	f6 c2 03             	test   $0x3,%dl
  800932:	75 1b                	jne    80094f <memmove+0x3c>
  800934:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80093a:	75 13                	jne    80094f <memmove+0x3c>
  80093c:	f6 c1 03             	test   $0x3,%cl
  80093f:	75 0e                	jne    80094f <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800941:	83 ef 04             	sub    $0x4,%edi
  800944:	8d 72 fc             	lea    -0x4(%edx),%esi
  800947:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  80094a:	fd                   	std    
  80094b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80094d:	eb 07                	jmp    800956 <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  80094f:	4f                   	dec    %edi
  800950:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800953:	fd                   	std    
  800954:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800956:	fc                   	cld    
  800957:	eb 20                	jmp    800979 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800959:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80095f:	75 13                	jne    800974 <memmove+0x61>
  800961:	a8 03                	test   $0x3,%al
  800963:	75 0f                	jne    800974 <memmove+0x61>
  800965:	f6 c1 03             	test   $0x3,%cl
  800968:	75 0a                	jne    800974 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  80096a:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  80096d:	89 c7                	mov    %eax,%edi
  80096f:	fc                   	cld    
  800970:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800972:	eb 05                	jmp    800979 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800974:	89 c7                	mov    %eax,%edi
  800976:	fc                   	cld    
  800977:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800979:	5e                   	pop    %esi
  80097a:	5f                   	pop    %edi
  80097b:	c9                   	leave  
  80097c:	c3                   	ret    

0080097d <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  80097d:	55                   	push   %ebp
  80097e:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800980:	ff 75 10             	pushl  0x10(%ebp)
  800983:	ff 75 0c             	pushl  0xc(%ebp)
  800986:	ff 75 08             	pushl  0x8(%ebp)
  800989:	e8 85 ff ff ff       	call   800913 <memmove>
}
  80098e:	c9                   	leave  
  80098f:	c3                   	ret    

00800990 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800990:	55                   	push   %ebp
  800991:	89 e5                	mov    %esp,%ebp
  800993:	57                   	push   %edi
  800994:	56                   	push   %esi
  800995:	53                   	push   %ebx
  800996:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800999:	8b 75 0c             	mov    0xc(%ebp),%esi
  80099c:	8b 7d 10             	mov    0x10(%ebp),%edi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80099f:	85 ff                	test   %edi,%edi
  8009a1:	74 32                	je     8009d5 <memcmp+0x45>
		if (*s1 != *s2)
  8009a3:	8a 03                	mov    (%ebx),%al
  8009a5:	8a 0e                	mov    (%esi),%cl
  8009a7:	38 c8                	cmp    %cl,%al
  8009a9:	74 19                	je     8009c4 <memcmp+0x34>
  8009ab:	eb 0d                	jmp    8009ba <memcmp+0x2a>
  8009ad:	8a 44 13 01          	mov    0x1(%ebx,%edx,1),%al
  8009b1:	8a 4c 16 01          	mov    0x1(%esi,%edx,1),%cl
  8009b5:	42                   	inc    %edx
  8009b6:	38 c8                	cmp    %cl,%al
  8009b8:	74 10                	je     8009ca <memcmp+0x3a>
			return (int) *s1 - (int) *s2;
  8009ba:	0f b6 c0             	movzbl %al,%eax
  8009bd:	0f b6 c9             	movzbl %cl,%ecx
  8009c0:	29 c8                	sub    %ecx,%eax
  8009c2:	eb 16                	jmp    8009da <memcmp+0x4a>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009c4:	4f                   	dec    %edi
  8009c5:	ba 00 00 00 00       	mov    $0x0,%edx
  8009ca:	39 fa                	cmp    %edi,%edx
  8009cc:	75 df                	jne    8009ad <memcmp+0x1d>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8009ce:	b8 00 00 00 00       	mov    $0x0,%eax
  8009d3:	eb 05                	jmp    8009da <memcmp+0x4a>
  8009d5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009da:	5b                   	pop    %ebx
  8009db:	5e                   	pop    %esi
  8009dc:	5f                   	pop    %edi
  8009dd:	c9                   	leave  
  8009de:	c3                   	ret    

008009df <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009df:	55                   	push   %ebp
  8009e0:	89 e5                	mov    %esp,%ebp
  8009e2:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  8009e5:	89 c2                	mov    %eax,%edx
  8009e7:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  8009ea:	39 d0                	cmp    %edx,%eax
  8009ec:	73 12                	jae    800a00 <memfind+0x21>
		if (*(const unsigned char *) s == (unsigned char) c)
  8009ee:	8a 4d 0c             	mov    0xc(%ebp),%cl
  8009f1:	38 08                	cmp    %cl,(%eax)
  8009f3:	75 06                	jne    8009fb <memfind+0x1c>
  8009f5:	eb 09                	jmp    800a00 <memfind+0x21>
  8009f7:	38 08                	cmp    %cl,(%eax)
  8009f9:	74 05                	je     800a00 <memfind+0x21>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009fb:	40                   	inc    %eax
  8009fc:	39 c2                	cmp    %eax,%edx
  8009fe:	77 f7                	ja     8009f7 <memfind+0x18>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a00:	c9                   	leave  
  800a01:	c3                   	ret    

00800a02 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a02:	55                   	push   %ebp
  800a03:	89 e5                	mov    %esp,%ebp
  800a05:	57                   	push   %edi
  800a06:	56                   	push   %esi
  800a07:	53                   	push   %ebx
  800a08:	8b 55 08             	mov    0x8(%ebp),%edx
  800a0b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a0e:	eb 01                	jmp    800a11 <strtol+0xf>
		s++;
  800a10:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a11:	8a 02                	mov    (%edx),%al
  800a13:	3c 20                	cmp    $0x20,%al
  800a15:	74 f9                	je     800a10 <strtol+0xe>
  800a17:	3c 09                	cmp    $0x9,%al
  800a19:	74 f5                	je     800a10 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a1b:	3c 2b                	cmp    $0x2b,%al
  800a1d:	75 08                	jne    800a27 <strtol+0x25>
		s++;
  800a1f:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a20:	bf 00 00 00 00       	mov    $0x0,%edi
  800a25:	eb 13                	jmp    800a3a <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a27:	3c 2d                	cmp    $0x2d,%al
  800a29:	75 0a                	jne    800a35 <strtol+0x33>
		s++, neg = 1;
  800a2b:	8d 52 01             	lea    0x1(%edx),%edx
  800a2e:	bf 01 00 00 00       	mov    $0x1,%edi
  800a33:	eb 05                	jmp    800a3a <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a35:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a3a:	85 db                	test   %ebx,%ebx
  800a3c:	74 05                	je     800a43 <strtol+0x41>
  800a3e:	83 fb 10             	cmp    $0x10,%ebx
  800a41:	75 28                	jne    800a6b <strtol+0x69>
  800a43:	8a 02                	mov    (%edx),%al
  800a45:	3c 30                	cmp    $0x30,%al
  800a47:	75 10                	jne    800a59 <strtol+0x57>
  800a49:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800a4d:	75 0a                	jne    800a59 <strtol+0x57>
		s += 2, base = 16;
  800a4f:	83 c2 02             	add    $0x2,%edx
  800a52:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a57:	eb 12                	jmp    800a6b <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800a59:	85 db                	test   %ebx,%ebx
  800a5b:	75 0e                	jne    800a6b <strtol+0x69>
  800a5d:	3c 30                	cmp    $0x30,%al
  800a5f:	75 05                	jne    800a66 <strtol+0x64>
		s++, base = 8;
  800a61:	42                   	inc    %edx
  800a62:	b3 08                	mov    $0x8,%bl
  800a64:	eb 05                	jmp    800a6b <strtol+0x69>
	else if (base == 0)
		base = 10;
  800a66:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800a6b:	b8 00 00 00 00       	mov    $0x0,%eax
  800a70:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a72:	8a 0a                	mov    (%edx),%cl
  800a74:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800a77:	80 fb 09             	cmp    $0x9,%bl
  800a7a:	77 08                	ja     800a84 <strtol+0x82>
			dig = *s - '0';
  800a7c:	0f be c9             	movsbl %cl,%ecx
  800a7f:	83 e9 30             	sub    $0x30,%ecx
  800a82:	eb 1e                	jmp    800aa2 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800a84:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800a87:	80 fb 19             	cmp    $0x19,%bl
  800a8a:	77 08                	ja     800a94 <strtol+0x92>
			dig = *s - 'a' + 10;
  800a8c:	0f be c9             	movsbl %cl,%ecx
  800a8f:	83 e9 57             	sub    $0x57,%ecx
  800a92:	eb 0e                	jmp    800aa2 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800a94:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800a97:	80 fb 19             	cmp    $0x19,%bl
  800a9a:	77 13                	ja     800aaf <strtol+0xad>
			dig = *s - 'A' + 10;
  800a9c:	0f be c9             	movsbl %cl,%ecx
  800a9f:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800aa2:	39 f1                	cmp    %esi,%ecx
  800aa4:	7d 0d                	jge    800ab3 <strtol+0xb1>
			break;
		s++, val = (val * base) + dig;
  800aa6:	42                   	inc    %edx
  800aa7:	0f af c6             	imul   %esi,%eax
  800aaa:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  800aad:	eb c3                	jmp    800a72 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800aaf:	89 c1                	mov    %eax,%ecx
  800ab1:	eb 02                	jmp    800ab5 <strtol+0xb3>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800ab3:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800ab5:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ab9:	74 05                	je     800ac0 <strtol+0xbe>
		*endptr = (char *) s;
  800abb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800abe:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800ac0:	85 ff                	test   %edi,%edi
  800ac2:	74 04                	je     800ac8 <strtol+0xc6>
  800ac4:	89 c8                	mov    %ecx,%eax
  800ac6:	f7 d8                	neg    %eax
}
  800ac8:	5b                   	pop    %ebx
  800ac9:	5e                   	pop    %esi
  800aca:	5f                   	pop    %edi
  800acb:	c9                   	leave  
  800acc:	c3                   	ret    
  800acd:	00 00                	add    %al,(%eax)
	...

00800ad0 <syscall>:
	return ret;
}

static int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800ad0:	55                   	push   %ebp
  800ad1:	89 e5                	mov    %esp,%ebp
  800ad3:	57                   	push   %edi
  800ad4:	56                   	push   %esi
  800ad5:	53                   	push   %ebx
  800ad6:	83 ec 1c             	sub    $0x1c,%esp
  800ad9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800adc:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800adf:	89 ca                	mov    %ecx,%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ae1:	8b 75 14             	mov    0x14(%ebp),%esi
  800ae4:	8b 7d 10             	mov    0x10(%ebp),%edi
  800ae7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800aea:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800aed:	cd 30                	int    $0x30
  800aef:	89 c2                	mov    %eax,%edx
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800af1:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800af5:	74 1c                	je     800b13 <syscall+0x43>
  800af7:	85 c0                	test   %eax,%eax
  800af9:	7e 18                	jle    800b13 <syscall+0x43>
		panic("syscall %d returned %d (> 0)", num, ret);
  800afb:	83 ec 0c             	sub    $0xc,%esp
  800afe:	50                   	push   %eax
  800aff:	ff 75 e4             	pushl  -0x1c(%ebp)
  800b02:	68 5f 21 80 00       	push   $0x80215f
  800b07:	6a 42                	push   $0x42
  800b09:	68 7c 21 80 00       	push   $0x80217c
  800b0e:	e8 39 10 00 00       	call   801b4c <_panic>

	return ret;
}
  800b13:	89 d0                	mov    %edx,%eax
  800b15:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b18:	5b                   	pop    %ebx
  800b19:	5e                   	pop    %esi
  800b1a:	5f                   	pop    %edi
  800b1b:	c9                   	leave  
  800b1c:	c3                   	ret    

00800b1d <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{	
  800b1d:	55                   	push   %ebp
  800b1e:	89 e5                	mov    %esp,%ebp
  800b20:	83 ec 08             	sub    $0x8,%esp
	// my_sysenter(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
	// return;
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  800b23:	6a 00                	push   $0x0
  800b25:	6a 00                	push   $0x0
  800b27:	6a 00                	push   $0x0
  800b29:	ff 75 0c             	pushl  0xc(%ebp)
  800b2c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b2f:	ba 00 00 00 00       	mov    $0x0,%edx
  800b34:	b8 00 00 00 00       	mov    $0x0,%eax
  800b39:	e8 92 ff ff ff       	call   800ad0 <syscall>
  800b3e:	83 c4 10             	add    $0x10,%esp
	return;
}
  800b41:	c9                   	leave  
  800b42:	c3                   	ret    

00800b43 <sys_cgetc>:

int
sys_cgetc(void)
{
  800b43:	55                   	push   %ebp
  800b44:	89 e5                	mov    %esp,%ebp
  800b46:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_cgetc, 0, 0, 0, 0, 0, 0);
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  800b49:	6a 00                	push   $0x0
  800b4b:	6a 00                	push   $0x0
  800b4d:	6a 00                	push   $0x0
  800b4f:	6a 00                	push   $0x0
  800b51:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b56:	ba 00 00 00 00       	mov    $0x0,%edx
  800b5b:	b8 01 00 00 00       	mov    $0x1,%eax
  800b60:	e8 6b ff ff ff       	call   800ad0 <syscall>
}
  800b65:	c9                   	leave  
  800b66:	c3                   	ret    

00800b67 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b67:	55                   	push   %ebp
  800b68:	89 e5                	mov    %esp,%ebp
  800b6a:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  800b6d:	6a 00                	push   $0x0
  800b6f:	6a 00                	push   $0x0
  800b71:	6a 00                	push   $0x0
  800b73:	6a 00                	push   $0x0
  800b75:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b78:	ba 01 00 00 00       	mov    $0x1,%edx
  800b7d:	b8 03 00 00 00       	mov    $0x3,%eax
  800b82:	e8 49 ff ff ff       	call   800ad0 <syscall>
}
  800b87:	c9                   	leave  
  800b88:	c3                   	ret    

00800b89 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b89:	55                   	push   %ebp
  800b8a:	89 e5                	mov    %esp,%ebp
  800b8c:	83 ec 08             	sub    $0x8,%esp
	// return my_sysenter(SYS_getenvid, 0, 0, 0, 0, 0, 0);
	return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  800b8f:	6a 00                	push   $0x0
  800b91:	6a 00                	push   $0x0
  800b93:	6a 00                	push   $0x0
  800b95:	6a 00                	push   $0x0
  800b97:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b9c:	ba 00 00 00 00       	mov    $0x0,%edx
  800ba1:	b8 02 00 00 00       	mov    $0x2,%eax
  800ba6:	e8 25 ff ff ff       	call   800ad0 <syscall>
}
  800bab:	c9                   	leave  
  800bac:	c3                   	ret    

00800bad <sys_yield>:

void
sys_yield(void)
{
  800bad:	55                   	push   %ebp
  800bae:	89 e5                	mov    %esp,%ebp
  800bb0:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  800bb3:	6a 00                	push   $0x0
  800bb5:	6a 00                	push   $0x0
  800bb7:	6a 00                	push   $0x0
  800bb9:	6a 00                	push   $0x0
  800bbb:	b9 00 00 00 00       	mov    $0x0,%ecx
  800bc0:	ba 00 00 00 00       	mov    $0x0,%edx
  800bc5:	b8 0b 00 00 00       	mov    $0xb,%eax
  800bca:	e8 01 ff ff ff       	call   800ad0 <syscall>
  800bcf:	83 c4 10             	add    $0x10,%esp
}
  800bd2:	c9                   	leave  
  800bd3:	c3                   	ret    

00800bd4 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800bd4:	55                   	push   %ebp
  800bd5:	89 e5                	mov    %esp,%ebp
  800bd7:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  800bda:	6a 00                	push   $0x0
  800bdc:	6a 00                	push   $0x0
  800bde:	ff 75 10             	pushl  0x10(%ebp)
  800be1:	ff 75 0c             	pushl  0xc(%ebp)
  800be4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800be7:	ba 01 00 00 00       	mov    $0x1,%edx
  800bec:	b8 04 00 00 00       	mov    $0x4,%eax
  800bf1:	e8 da fe ff ff       	call   800ad0 <syscall>
}
  800bf6:	c9                   	leave  
  800bf7:	c3                   	ret    

00800bf8 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800bf8:	55                   	push   %ebp
  800bf9:	89 e5                	mov    %esp,%ebp
  800bfb:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
  800bfe:	ff 75 18             	pushl  0x18(%ebp)
  800c01:	ff 75 14             	pushl  0x14(%ebp)
  800c04:	ff 75 10             	pushl  0x10(%ebp)
  800c07:	ff 75 0c             	pushl  0xc(%ebp)
  800c0a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c0d:	ba 01 00 00 00       	mov    $0x1,%edx
  800c12:	b8 05 00 00 00       	mov    $0x5,%eax
  800c17:	e8 b4 fe ff ff       	call   800ad0 <syscall>
}
  800c1c:	c9                   	leave  
  800c1d:	c3                   	ret    

00800c1e <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c1e:	55                   	push   %ebp
  800c1f:	89 e5                	mov    %esp,%ebp
  800c21:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  800c24:	6a 00                	push   $0x0
  800c26:	6a 00                	push   $0x0
  800c28:	6a 00                	push   $0x0
  800c2a:	ff 75 0c             	pushl  0xc(%ebp)
  800c2d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c30:	ba 01 00 00 00       	mov    $0x1,%edx
  800c35:	b8 06 00 00 00       	mov    $0x6,%eax
  800c3a:	e8 91 fe ff ff       	call   800ad0 <syscall>
}
  800c3f:	c9                   	leave  
  800c40:	c3                   	ret    

00800c41 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c41:	55                   	push   %ebp
  800c42:	89 e5                	mov    %esp,%ebp
  800c44:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  800c47:	6a 00                	push   $0x0
  800c49:	6a 00                	push   $0x0
  800c4b:	6a 00                	push   $0x0
  800c4d:	ff 75 0c             	pushl  0xc(%ebp)
  800c50:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c53:	ba 01 00 00 00       	mov    $0x1,%edx
  800c58:	b8 08 00 00 00       	mov    $0x8,%eax
  800c5d:	e8 6e fe ff ff       	call   800ad0 <syscall>
}
  800c62:	c9                   	leave  
  800c63:	c3                   	ret    

00800c64 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800c64:	55                   	push   %ebp
  800c65:	89 e5                	mov    %esp,%ebp
  800c67:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
  800c6a:	6a 00                	push   $0x0
  800c6c:	6a 00                	push   $0x0
  800c6e:	6a 00                	push   $0x0
  800c70:	ff 75 0c             	pushl  0xc(%ebp)
  800c73:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c76:	ba 01 00 00 00       	mov    $0x1,%edx
  800c7b:	b8 09 00 00 00       	mov    $0x9,%eax
  800c80:	e8 4b fe ff ff       	call   800ad0 <syscall>
}
  800c85:	c9                   	leave  
  800c86:	c3                   	ret    

00800c87 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800c87:	55                   	push   %ebp
  800c88:	89 e5                	mov    %esp,%ebp
  800c8a:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  800c8d:	6a 00                	push   $0x0
  800c8f:	6a 00                	push   $0x0
  800c91:	6a 00                	push   $0x0
  800c93:	ff 75 0c             	pushl  0xc(%ebp)
  800c96:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c99:	ba 01 00 00 00       	mov    $0x1,%edx
  800c9e:	b8 0a 00 00 00       	mov    $0xa,%eax
  800ca3:	e8 28 fe ff ff       	call   800ad0 <syscall>
}
  800ca8:	c9                   	leave  
  800ca9:	c3                   	ret    

00800caa <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800caa:	55                   	push   %ebp
  800cab:	89 e5                	mov    %esp,%ebp
  800cad:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  800cb0:	6a 00                	push   $0x0
  800cb2:	ff 75 14             	pushl  0x14(%ebp)
  800cb5:	ff 75 10             	pushl  0x10(%ebp)
  800cb8:	ff 75 0c             	pushl  0xc(%ebp)
  800cbb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800cbe:	ba 00 00 00 00       	mov    $0x0,%edx
  800cc3:	b8 0c 00 00 00       	mov    $0xc,%eax
  800cc8:	e8 03 fe ff ff       	call   800ad0 <syscall>
}
  800ccd:	c9                   	leave  
  800cce:	c3                   	ret    

00800ccf <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800ccf:	55                   	push   %ebp
  800cd0:	89 e5                	mov    %esp,%ebp
  800cd2:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  800cd5:	6a 00                	push   $0x0
  800cd7:	6a 00                	push   $0x0
  800cd9:	6a 00                	push   $0x0
  800cdb:	6a 00                	push   $0x0
  800cdd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ce0:	ba 01 00 00 00       	mov    $0x1,%edx
  800ce5:	b8 0d 00 00 00       	mov    $0xd,%eax
  800cea:	e8 e1 fd ff ff       	call   800ad0 <syscall>
}
  800cef:	c9                   	leave  
  800cf0:	c3                   	ret    

00800cf1 <sys_set_priority>:

int
sys_set_priority(envid_t envid, uint32_t new_priority)
{
  800cf1:	55                   	push   %ebp
  800cf2:	89 e5                	mov    %esp,%ebp
  800cf4:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_set_priority, 0, envid, new_priority, 0, 0, 0);
  800cf7:	6a 00                	push   $0x0
  800cf9:	6a 00                	push   $0x0
  800cfb:	6a 00                	push   $0x0
  800cfd:	ff 75 0c             	pushl  0xc(%ebp)
  800d00:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d03:	ba 00 00 00 00       	mov    $0x0,%edx
  800d08:	b8 0e 00 00 00       	mov    $0xe,%eax
  800d0d:	e8 be fd ff ff       	call   800ad0 <syscall>
}
  800d12:	c9                   	leave  
  800d13:	c3                   	ret    

00800d14 <sys_exec>:

int
sys_exec(uint32_t eip, uint32_t esp, void * ph, uint32_t elf_phnum)
{
  800d14:	55                   	push   %ebp
  800d15:	89 e5                	mov    %esp,%ebp
  800d17:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_exec, 0, eip, esp, (uint32_t)ph, elf_phnum, 0);
  800d1a:	6a 00                	push   $0x0
  800d1c:	ff 75 14             	pushl  0x14(%ebp)
  800d1f:	ff 75 10             	pushl  0x10(%ebp)
  800d22:	ff 75 0c             	pushl  0xc(%ebp)
  800d25:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d28:	ba 00 00 00 00       	mov    $0x0,%edx
  800d2d:	b8 0f 00 00 00       	mov    $0xf,%eax
  800d32:	e8 99 fd ff ff       	call   800ad0 <syscall>
} 
  800d37:	c9                   	leave  
  800d38:	c3                   	ret    

00800d39 <sys_join>:

// thread:
int
sys_join(envid_t envid)
{
  800d39:	55                   	push   %ebp
  800d3a:	89 e5                	mov    %esp,%ebp
  800d3c:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_join, 0, envid, 0, 0, 0, 0);
  800d3f:	6a 00                	push   $0x0
  800d41:	6a 00                	push   $0x0
  800d43:	6a 00                	push   $0x0
  800d45:	6a 00                	push   $0x0
  800d47:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d4a:	ba 00 00 00 00       	mov    $0x0,%edx
  800d4f:	b8 11 00 00 00       	mov    $0x11,%eax
  800d54:	e8 77 fd ff ff       	call   800ad0 <syscall>
}
  800d59:	c9                   	leave  
  800d5a:	c3                   	ret    

00800d5b <sys_getpid>:

envid_t
sys_getpid(void)
{
  800d5b:	55                   	push   %ebp
  800d5c:	89 e5                	mov    %esp,%ebp
  800d5e:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_getpid, 0, 0, 0, 0, 0, 0);
  800d61:	6a 00                	push   $0x0
  800d63:	6a 00                	push   $0x0
  800d65:	6a 00                	push   $0x0
  800d67:	6a 00                	push   $0x0
  800d69:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d6e:	ba 00 00 00 00       	mov    $0x0,%edx
  800d73:	b8 10 00 00 00       	mov    $0x10,%eax
  800d78:	e8 53 fd ff ff       	call   800ad0 <syscall>
  800d7d:	c9                   	leave  
  800d7e:	c3                   	ret    
	...

00800d80 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  800d80:	55                   	push   %ebp
  800d81:	89 e5                	mov    %esp,%ebp
  800d83:	56                   	push   %esi
  800d84:	53                   	push   %ebx
  800d85:	8b 75 08             	mov    0x8(%ebp),%esi
  800d88:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d8b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// cprintf("0x%x 0x%x 0x%x\n", (uint32_t)from_env_store, (uint32_t)pg, (uint32_t)perm_store);
	int r;
	if (pg != NULL) {
  800d8e:	85 c0                	test   %eax,%eax
  800d90:	74 0e                	je     800da0 <ipc_recv+0x20>
		r = sys_ipc_recv(pg);
  800d92:	83 ec 0c             	sub    $0xc,%esp
  800d95:	50                   	push   %eax
  800d96:	e8 34 ff ff ff       	call   800ccf <sys_ipc_recv>
  800d9b:	83 c4 10             	add    $0x10,%esp
  800d9e:	eb 10                	jmp    800db0 <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv((void *)UTOP);
  800da0:	83 ec 0c             	sub    $0xc,%esp
  800da3:	68 00 00 c0 ee       	push   $0xeec00000
  800da8:	e8 22 ff ff ff       	call   800ccf <sys_ipc_recv>
  800dad:	83 c4 10             	add    $0x10,%esp
	}

	if (r == 0) {
  800db0:	85 c0                	test   %eax,%eax
  800db2:	75 26                	jne    800dda <ipc_recv+0x5a>
		if (from_env_store != NULL) *from_env_store = thisenv->env_ipc_from;
  800db4:	85 f6                	test   %esi,%esi
  800db6:	74 0a                	je     800dc2 <ipc_recv+0x42>
  800db8:	a1 04 40 80 00       	mov    0x804004,%eax
  800dbd:	8b 40 74             	mov    0x74(%eax),%eax
  800dc0:	89 06                	mov    %eax,(%esi)
		if (perm_store != NULL) *perm_store = thisenv->env_ipc_perm;
  800dc2:	85 db                	test   %ebx,%ebx
  800dc4:	74 0a                	je     800dd0 <ipc_recv+0x50>
  800dc6:	a1 04 40 80 00       	mov    0x804004,%eax
  800dcb:	8b 40 78             	mov    0x78(%eax),%eax
  800dce:	89 03                	mov    %eax,(%ebx)
		return thisenv->env_ipc_value;
  800dd0:	a1 04 40 80 00       	mov    0x804004,%eax
  800dd5:	8b 40 70             	mov    0x70(%eax),%eax
  800dd8:	eb 14                	jmp    800dee <ipc_recv+0x6e>
	} else {
		// fails;
		if (from_env_store != NULL) *from_env_store = 0;
  800dda:	85 f6                	test   %esi,%esi
  800ddc:	74 06                	je     800de4 <ipc_recv+0x64>
  800dde:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if (perm_store != NULL) *perm_store = 0;
  800de4:	85 db                	test   %ebx,%ebx
  800de6:	74 06                	je     800dee <ipc_recv+0x6e>
  800de8:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		return r;
	}
}
  800dee:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800df1:	5b                   	pop    %ebx
  800df2:	5e                   	pop    %esi
  800df3:	c9                   	leave  
  800df4:	c3                   	ret    

00800df5 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  800df5:	55                   	push   %ebp
  800df6:	89 e5                	mov    %esp,%ebp
  800df8:	57                   	push   %edi
  800df9:	56                   	push   %esi
  800dfa:	53                   	push   %ebx
  800dfb:	83 ec 0c             	sub    $0xc,%esp
  800dfe:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800e01:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e04:	8b 75 14             	mov    0x14(%ebp),%esi
	// LAB 4: Your code here.
	// int sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
	int r;
	if (pg == NULL) pg = (void *)UTOP;
  800e07:	85 db                	test   %ebx,%ebx
  800e09:	75 25                	jne    800e30 <ipc_send+0x3b>
  800e0b:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
  800e10:	eb 1e                	jmp    800e30 <ipc_send+0x3b>
	
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) != 0) {
		if (r == -E_IPC_NOT_RECV) {
  800e12:	83 f8 f9             	cmp    $0xfffffff9,%eax
  800e15:	75 07                	jne    800e1e <ipc_send+0x29>
			// cprintf("Try Again and Again....\n");
			sys_yield();
  800e17:	e8 91 fd ff ff       	call   800bad <sys_yield>
  800e1c:	eb 12                	jmp    800e30 <ipc_send+0x3b>
		} else {
			panic("ipc_send error %e\n", r);
  800e1e:	50                   	push   %eax
  800e1f:	68 8a 21 80 00       	push   $0x80218a
  800e24:	6a 43                	push   $0x43
  800e26:	68 9d 21 80 00       	push   $0x80219d
  800e2b:	e8 1c 0d 00 00       	call   801b4c <_panic>
	// LAB 4: Your code here.
	// int sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
	int r;
	if (pg == NULL) pg = (void *)UTOP;
	
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) != 0) {
  800e30:	56                   	push   %esi
  800e31:	53                   	push   %ebx
  800e32:	57                   	push   %edi
  800e33:	ff 75 08             	pushl  0x8(%ebp)
  800e36:	e8 6f fe ff ff       	call   800caa <sys_ipc_try_send>
  800e3b:	83 c4 10             	add    $0x10,%esp
  800e3e:	85 c0                	test   %eax,%eax
  800e40:	75 d0                	jne    800e12 <ipc_send+0x1d>
		} else {
			panic("ipc_send error %e\n", r);
		}
	}
	return;
}
  800e42:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e45:	5b                   	pop    %ebx
  800e46:	5e                   	pop    %esi
  800e47:	5f                   	pop    %edi
  800e48:	c9                   	leave  
  800e49:	c3                   	ret    

00800e4a <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  800e4a:	55                   	push   %ebp
  800e4b:	89 e5                	mov    %esp,%ebp
  800e4d:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  800e50:	39 0d 50 00 c0 ee    	cmp    %ecx,0xeec00050
  800e56:	74 1a                	je     800e72 <ipc_find_env+0x28>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  800e58:	b8 01 00 00 00       	mov    $0x1,%eax
		if (envs[i].env_type == type)
  800e5d:	89 c2                	mov    %eax,%edx
  800e5f:	c1 e2 07             	shl    $0x7,%edx
  800e62:	8d 94 82 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,4),%edx
  800e69:	8b 52 50             	mov    0x50(%edx),%edx
  800e6c:	39 ca                	cmp    %ecx,%edx
  800e6e:	75 18                	jne    800e88 <ipc_find_env+0x3e>
  800e70:	eb 05                	jmp    800e77 <ipc_find_env+0x2d>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  800e72:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
			return envs[i].env_id;
  800e77:	89 c2                	mov    %eax,%edx
  800e79:	c1 e2 07             	shl    $0x7,%edx
  800e7c:	8d 84 82 08 00 c0 ee 	lea    -0x113ffff8(%edx,%eax,4),%eax
  800e83:	8b 40 40             	mov    0x40(%eax),%eax
  800e86:	eb 0c                	jmp    800e94 <ipc_find_env+0x4a>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  800e88:	40                   	inc    %eax
  800e89:	3d 00 04 00 00       	cmp    $0x400,%eax
  800e8e:	75 cd                	jne    800e5d <ipc_find_env+0x13>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  800e90:	66 b8 00 00          	mov    $0x0,%ax
}
  800e94:	c9                   	leave  
  800e95:	c3                   	ret    
	...

00800e98 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800e98:	55                   	push   %ebp
  800e99:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800e9b:	8b 45 08             	mov    0x8(%ebp),%eax
  800e9e:	05 00 00 00 30       	add    $0x30000000,%eax
  800ea3:	c1 e8 0c             	shr    $0xc,%eax
}
  800ea6:	c9                   	leave  
  800ea7:	c3                   	ret    

00800ea8 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800ea8:	55                   	push   %ebp
  800ea9:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800eab:	ff 75 08             	pushl  0x8(%ebp)
  800eae:	e8 e5 ff ff ff       	call   800e98 <fd2num>
  800eb3:	83 c4 04             	add    $0x4,%esp
  800eb6:	05 20 00 0d 00       	add    $0xd0020,%eax
  800ebb:	c1 e0 0c             	shl    $0xc,%eax
}
  800ebe:	c9                   	leave  
  800ebf:	c3                   	ret    

00800ec0 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800ec0:	55                   	push   %ebp
  800ec1:	89 e5                	mov    %esp,%ebp
  800ec3:	53                   	push   %ebx
  800ec4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800ec7:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  800ecc:	a8 01                	test   $0x1,%al
  800ece:	74 34                	je     800f04 <fd_alloc+0x44>
  800ed0:	a1 00 00 74 ef       	mov    0xef740000,%eax
  800ed5:	a8 01                	test   $0x1,%al
  800ed7:	74 32                	je     800f0b <fd_alloc+0x4b>
  800ed9:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
  800ede:	89 c1                	mov    %eax,%ecx
  800ee0:	89 c2                	mov    %eax,%edx
  800ee2:	c1 ea 16             	shr    $0x16,%edx
  800ee5:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800eec:	f6 c2 01             	test   $0x1,%dl
  800eef:	74 1f                	je     800f10 <fd_alloc+0x50>
  800ef1:	89 c2                	mov    %eax,%edx
  800ef3:	c1 ea 0c             	shr    $0xc,%edx
  800ef6:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800efd:	f6 c2 01             	test   $0x1,%dl
  800f00:	75 17                	jne    800f19 <fd_alloc+0x59>
  800f02:	eb 0c                	jmp    800f10 <fd_alloc+0x50>
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  800f04:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
  800f09:	eb 05                	jmp    800f10 <fd_alloc+0x50>
  800f0b:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
  800f10:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  800f12:	b8 00 00 00 00       	mov    $0x0,%eax
  800f17:	eb 17                	jmp    800f30 <fd_alloc+0x70>
  800f19:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800f1e:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800f23:	75 b9                	jne    800ede <fd_alloc+0x1e>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800f25:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  800f2b:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800f30:	5b                   	pop    %ebx
  800f31:	c9                   	leave  
  800f32:	c3                   	ret    

00800f33 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800f33:	55                   	push   %ebp
  800f34:	89 e5                	mov    %esp,%ebp
  800f36:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800f39:	83 f8 1f             	cmp    $0x1f,%eax
  800f3c:	77 36                	ja     800f74 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800f3e:	05 00 00 0d 00       	add    $0xd0000,%eax
  800f43:	c1 e0 0c             	shl    $0xc,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800f46:	89 c2                	mov    %eax,%edx
  800f48:	c1 ea 16             	shr    $0x16,%edx
  800f4b:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800f52:	f6 c2 01             	test   $0x1,%dl
  800f55:	74 24                	je     800f7b <fd_lookup+0x48>
  800f57:	89 c2                	mov    %eax,%edx
  800f59:	c1 ea 0c             	shr    $0xc,%edx
  800f5c:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800f63:	f6 c2 01             	test   $0x1,%dl
  800f66:	74 1a                	je     800f82 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800f68:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f6b:	89 02                	mov    %eax,(%edx)
	return 0;
  800f6d:	b8 00 00 00 00       	mov    $0x0,%eax
  800f72:	eb 13                	jmp    800f87 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800f74:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f79:	eb 0c                	jmp    800f87 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800f7b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f80:	eb 05                	jmp    800f87 <fd_lookup+0x54>
  800f82:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800f87:	c9                   	leave  
  800f88:	c3                   	ret    

00800f89 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800f89:	55                   	push   %ebp
  800f8a:	89 e5                	mov    %esp,%ebp
  800f8c:	53                   	push   %ebx
  800f8d:	83 ec 04             	sub    $0x4,%esp
  800f90:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f93:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  800f96:	39 0d 04 30 80 00    	cmp    %ecx,0x803004
  800f9c:	74 0d                	je     800fab <dev_lookup+0x22>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800f9e:	b8 00 00 00 00       	mov    $0x0,%eax
  800fa3:	eb 14                	jmp    800fb9 <dev_lookup+0x30>
		if (devtab[i]->dev_id == dev_id) {
  800fa5:	39 0a                	cmp    %ecx,(%edx)
  800fa7:	75 10                	jne    800fb9 <dev_lookup+0x30>
  800fa9:	eb 05                	jmp    800fb0 <dev_lookup+0x27>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800fab:	ba 04 30 80 00       	mov    $0x803004,%edx
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
  800fb0:	89 13                	mov    %edx,(%ebx)
			return 0;
  800fb2:	b8 00 00 00 00       	mov    $0x0,%eax
  800fb7:	eb 31                	jmp    800fea <dev_lookup+0x61>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800fb9:	40                   	inc    %eax
  800fba:	8b 14 85 24 22 80 00 	mov    0x802224(,%eax,4),%edx
  800fc1:	85 d2                	test   %edx,%edx
  800fc3:	75 e0                	jne    800fa5 <dev_lookup+0x1c>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800fc5:	a1 04 40 80 00       	mov    0x804004,%eax
  800fca:	8b 40 48             	mov    0x48(%eax),%eax
  800fcd:	83 ec 04             	sub    $0x4,%esp
  800fd0:	51                   	push   %ecx
  800fd1:	50                   	push   %eax
  800fd2:	68 a8 21 80 00       	push   $0x8021a8
  800fd7:	e8 c0 f1 ff ff       	call   80019c <cprintf>
	*dev = 0;
  800fdc:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  800fe2:	83 c4 10             	add    $0x10,%esp
  800fe5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800fea:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800fed:	c9                   	leave  
  800fee:	c3                   	ret    

00800fef <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800fef:	55                   	push   %ebp
  800ff0:	89 e5                	mov    %esp,%ebp
  800ff2:	56                   	push   %esi
  800ff3:	53                   	push   %ebx
  800ff4:	83 ec 20             	sub    $0x20,%esp
  800ff7:	8b 75 08             	mov    0x8(%ebp),%esi
  800ffa:	8a 45 0c             	mov    0xc(%ebp),%al
  800ffd:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801000:	56                   	push   %esi
  801001:	e8 92 fe ff ff       	call   800e98 <fd2num>
  801006:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801009:	89 14 24             	mov    %edx,(%esp)
  80100c:	50                   	push   %eax
  80100d:	e8 21 ff ff ff       	call   800f33 <fd_lookup>
  801012:	89 c3                	mov    %eax,%ebx
  801014:	83 c4 08             	add    $0x8,%esp
  801017:	85 c0                	test   %eax,%eax
  801019:	78 05                	js     801020 <fd_close+0x31>
	    || fd != fd2)
  80101b:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80101e:	74 0d                	je     80102d <fd_close+0x3e>
		return (must_exist ? r : 0);
  801020:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  801024:	75 48                	jne    80106e <fd_close+0x7f>
  801026:	bb 00 00 00 00       	mov    $0x0,%ebx
  80102b:	eb 41                	jmp    80106e <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80102d:	83 ec 08             	sub    $0x8,%esp
  801030:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801033:	50                   	push   %eax
  801034:	ff 36                	pushl  (%esi)
  801036:	e8 4e ff ff ff       	call   800f89 <dev_lookup>
  80103b:	89 c3                	mov    %eax,%ebx
  80103d:	83 c4 10             	add    $0x10,%esp
  801040:	85 c0                	test   %eax,%eax
  801042:	78 1c                	js     801060 <fd_close+0x71>
		if (dev->dev_close)
  801044:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801047:	8b 40 10             	mov    0x10(%eax),%eax
  80104a:	85 c0                	test   %eax,%eax
  80104c:	74 0d                	je     80105b <fd_close+0x6c>
			r = (*dev->dev_close)(fd);
  80104e:	83 ec 0c             	sub    $0xc,%esp
  801051:	56                   	push   %esi
  801052:	ff d0                	call   *%eax
  801054:	89 c3                	mov    %eax,%ebx
  801056:	83 c4 10             	add    $0x10,%esp
  801059:	eb 05                	jmp    801060 <fd_close+0x71>
		else
			r = 0;
  80105b:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801060:	83 ec 08             	sub    $0x8,%esp
  801063:	56                   	push   %esi
  801064:	6a 00                	push   $0x0
  801066:	e8 b3 fb ff ff       	call   800c1e <sys_page_unmap>
	return r;
  80106b:	83 c4 10             	add    $0x10,%esp
}
  80106e:	89 d8                	mov    %ebx,%eax
  801070:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801073:	5b                   	pop    %ebx
  801074:	5e                   	pop    %esi
  801075:	c9                   	leave  
  801076:	c3                   	ret    

00801077 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801077:	55                   	push   %ebp
  801078:	89 e5                	mov    %esp,%ebp
  80107a:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80107d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801080:	50                   	push   %eax
  801081:	ff 75 08             	pushl  0x8(%ebp)
  801084:	e8 aa fe ff ff       	call   800f33 <fd_lookup>
  801089:	83 c4 08             	add    $0x8,%esp
  80108c:	85 c0                	test   %eax,%eax
  80108e:	78 10                	js     8010a0 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801090:	83 ec 08             	sub    $0x8,%esp
  801093:	6a 01                	push   $0x1
  801095:	ff 75 f4             	pushl  -0xc(%ebp)
  801098:	e8 52 ff ff ff       	call   800fef <fd_close>
  80109d:	83 c4 10             	add    $0x10,%esp
}
  8010a0:	c9                   	leave  
  8010a1:	c3                   	ret    

008010a2 <close_all>:

void
close_all(void)
{
  8010a2:	55                   	push   %ebp
  8010a3:	89 e5                	mov    %esp,%ebp
  8010a5:	53                   	push   %ebx
  8010a6:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8010a9:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8010ae:	83 ec 0c             	sub    $0xc,%esp
  8010b1:	53                   	push   %ebx
  8010b2:	e8 c0 ff ff ff       	call   801077 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8010b7:	43                   	inc    %ebx
  8010b8:	83 c4 10             	add    $0x10,%esp
  8010bb:	83 fb 20             	cmp    $0x20,%ebx
  8010be:	75 ee                	jne    8010ae <close_all+0xc>
		close(i);
}
  8010c0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8010c3:	c9                   	leave  
  8010c4:	c3                   	ret    

008010c5 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8010c5:	55                   	push   %ebp
  8010c6:	89 e5                	mov    %esp,%ebp
  8010c8:	57                   	push   %edi
  8010c9:	56                   	push   %esi
  8010ca:	53                   	push   %ebx
  8010cb:	83 ec 2c             	sub    $0x2c,%esp
  8010ce:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8010d1:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8010d4:	50                   	push   %eax
  8010d5:	ff 75 08             	pushl  0x8(%ebp)
  8010d8:	e8 56 fe ff ff       	call   800f33 <fd_lookup>
  8010dd:	89 c3                	mov    %eax,%ebx
  8010df:	83 c4 08             	add    $0x8,%esp
  8010e2:	85 c0                	test   %eax,%eax
  8010e4:	0f 88 c0 00 00 00    	js     8011aa <dup+0xe5>
		return r;
	close(newfdnum);
  8010ea:	83 ec 0c             	sub    $0xc,%esp
  8010ed:	57                   	push   %edi
  8010ee:	e8 84 ff ff ff       	call   801077 <close>

	newfd = INDEX2FD(newfdnum);
  8010f3:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  8010f9:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  8010fc:	83 c4 04             	add    $0x4,%esp
  8010ff:	ff 75 e4             	pushl  -0x1c(%ebp)
  801102:	e8 a1 fd ff ff       	call   800ea8 <fd2data>
  801107:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801109:	89 34 24             	mov    %esi,(%esp)
  80110c:	e8 97 fd ff ff       	call   800ea8 <fd2data>
  801111:	83 c4 10             	add    $0x10,%esp
  801114:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801117:	89 d8                	mov    %ebx,%eax
  801119:	c1 e8 16             	shr    $0x16,%eax
  80111c:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801123:	a8 01                	test   $0x1,%al
  801125:	74 37                	je     80115e <dup+0x99>
  801127:	89 d8                	mov    %ebx,%eax
  801129:	c1 e8 0c             	shr    $0xc,%eax
  80112c:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801133:	f6 c2 01             	test   $0x1,%dl
  801136:	74 26                	je     80115e <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801138:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80113f:	83 ec 0c             	sub    $0xc,%esp
  801142:	25 07 0e 00 00       	and    $0xe07,%eax
  801147:	50                   	push   %eax
  801148:	ff 75 d4             	pushl  -0x2c(%ebp)
  80114b:	6a 00                	push   $0x0
  80114d:	53                   	push   %ebx
  80114e:	6a 00                	push   $0x0
  801150:	e8 a3 fa ff ff       	call   800bf8 <sys_page_map>
  801155:	89 c3                	mov    %eax,%ebx
  801157:	83 c4 20             	add    $0x20,%esp
  80115a:	85 c0                	test   %eax,%eax
  80115c:	78 2d                	js     80118b <dup+0xc6>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80115e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801161:	89 c2                	mov    %eax,%edx
  801163:	c1 ea 0c             	shr    $0xc,%edx
  801166:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80116d:	83 ec 0c             	sub    $0xc,%esp
  801170:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  801176:	52                   	push   %edx
  801177:	56                   	push   %esi
  801178:	6a 00                	push   $0x0
  80117a:	50                   	push   %eax
  80117b:	6a 00                	push   $0x0
  80117d:	e8 76 fa ff ff       	call   800bf8 <sys_page_map>
  801182:	89 c3                	mov    %eax,%ebx
  801184:	83 c4 20             	add    $0x20,%esp
  801187:	85 c0                	test   %eax,%eax
  801189:	79 1d                	jns    8011a8 <dup+0xe3>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80118b:	83 ec 08             	sub    $0x8,%esp
  80118e:	56                   	push   %esi
  80118f:	6a 00                	push   $0x0
  801191:	e8 88 fa ff ff       	call   800c1e <sys_page_unmap>
	sys_page_unmap(0, nva);
  801196:	83 c4 08             	add    $0x8,%esp
  801199:	ff 75 d4             	pushl  -0x2c(%ebp)
  80119c:	6a 00                	push   $0x0
  80119e:	e8 7b fa ff ff       	call   800c1e <sys_page_unmap>
	return r;
  8011a3:	83 c4 10             	add    $0x10,%esp
  8011a6:	eb 02                	jmp    8011aa <dup+0xe5>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  8011a8:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  8011aa:	89 d8                	mov    %ebx,%eax
  8011ac:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011af:	5b                   	pop    %ebx
  8011b0:	5e                   	pop    %esi
  8011b1:	5f                   	pop    %edi
  8011b2:	c9                   	leave  
  8011b3:	c3                   	ret    

008011b4 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8011b4:	55                   	push   %ebp
  8011b5:	89 e5                	mov    %esp,%ebp
  8011b7:	53                   	push   %ebx
  8011b8:	83 ec 14             	sub    $0x14,%esp
  8011bb:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8011be:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011c1:	50                   	push   %eax
  8011c2:	53                   	push   %ebx
  8011c3:	e8 6b fd ff ff       	call   800f33 <fd_lookup>
  8011c8:	83 c4 08             	add    $0x8,%esp
  8011cb:	85 c0                	test   %eax,%eax
  8011cd:	78 67                	js     801236 <read+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011cf:	83 ec 08             	sub    $0x8,%esp
  8011d2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011d5:	50                   	push   %eax
  8011d6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011d9:	ff 30                	pushl  (%eax)
  8011db:	e8 a9 fd ff ff       	call   800f89 <dev_lookup>
  8011e0:	83 c4 10             	add    $0x10,%esp
  8011e3:	85 c0                	test   %eax,%eax
  8011e5:	78 4f                	js     801236 <read+0x82>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8011e7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011ea:	8b 50 08             	mov    0x8(%eax),%edx
  8011ed:	83 e2 03             	and    $0x3,%edx
  8011f0:	83 fa 01             	cmp    $0x1,%edx
  8011f3:	75 21                	jne    801216 <read+0x62>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8011f5:	a1 04 40 80 00       	mov    0x804004,%eax
  8011fa:	8b 40 48             	mov    0x48(%eax),%eax
  8011fd:	83 ec 04             	sub    $0x4,%esp
  801200:	53                   	push   %ebx
  801201:	50                   	push   %eax
  801202:	68 e9 21 80 00       	push   $0x8021e9
  801207:	e8 90 ef ff ff       	call   80019c <cprintf>
		return -E_INVAL;
  80120c:	83 c4 10             	add    $0x10,%esp
  80120f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801214:	eb 20                	jmp    801236 <read+0x82>
	}
	if (!dev->dev_read)
  801216:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801219:	8b 52 08             	mov    0x8(%edx),%edx
  80121c:	85 d2                	test   %edx,%edx
  80121e:	74 11                	je     801231 <read+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801220:	83 ec 04             	sub    $0x4,%esp
  801223:	ff 75 10             	pushl  0x10(%ebp)
  801226:	ff 75 0c             	pushl  0xc(%ebp)
  801229:	50                   	push   %eax
  80122a:	ff d2                	call   *%edx
  80122c:	83 c4 10             	add    $0x10,%esp
  80122f:	eb 05                	jmp    801236 <read+0x82>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801231:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  801236:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801239:	c9                   	leave  
  80123a:	c3                   	ret    

0080123b <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80123b:	55                   	push   %ebp
  80123c:	89 e5                	mov    %esp,%ebp
  80123e:	57                   	push   %edi
  80123f:	56                   	push   %esi
  801240:	53                   	push   %ebx
  801241:	83 ec 0c             	sub    $0xc,%esp
  801244:	8b 7d 08             	mov    0x8(%ebp),%edi
  801247:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80124a:	85 f6                	test   %esi,%esi
  80124c:	74 31                	je     80127f <readn+0x44>
  80124e:	b8 00 00 00 00       	mov    $0x0,%eax
  801253:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = read(fdnum, (char*)buf + tot, n - tot);
  801258:	83 ec 04             	sub    $0x4,%esp
  80125b:	89 f2                	mov    %esi,%edx
  80125d:	29 c2                	sub    %eax,%edx
  80125f:	52                   	push   %edx
  801260:	03 45 0c             	add    0xc(%ebp),%eax
  801263:	50                   	push   %eax
  801264:	57                   	push   %edi
  801265:	e8 4a ff ff ff       	call   8011b4 <read>
		if (m < 0)
  80126a:	83 c4 10             	add    $0x10,%esp
  80126d:	85 c0                	test   %eax,%eax
  80126f:	78 17                	js     801288 <readn+0x4d>
			return m;
		if (m == 0)
  801271:	85 c0                	test   %eax,%eax
  801273:	74 11                	je     801286 <readn+0x4b>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801275:	01 c3                	add    %eax,%ebx
  801277:	89 d8                	mov    %ebx,%eax
  801279:	39 f3                	cmp    %esi,%ebx
  80127b:	72 db                	jb     801258 <readn+0x1d>
  80127d:	eb 09                	jmp    801288 <readn+0x4d>
  80127f:	b8 00 00 00 00       	mov    $0x0,%eax
  801284:	eb 02                	jmp    801288 <readn+0x4d>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  801286:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  801288:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80128b:	5b                   	pop    %ebx
  80128c:	5e                   	pop    %esi
  80128d:	5f                   	pop    %edi
  80128e:	c9                   	leave  
  80128f:	c3                   	ret    

00801290 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801290:	55                   	push   %ebp
  801291:	89 e5                	mov    %esp,%ebp
  801293:	53                   	push   %ebx
  801294:	83 ec 14             	sub    $0x14,%esp
  801297:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80129a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80129d:	50                   	push   %eax
  80129e:	53                   	push   %ebx
  80129f:	e8 8f fc ff ff       	call   800f33 <fd_lookup>
  8012a4:	83 c4 08             	add    $0x8,%esp
  8012a7:	85 c0                	test   %eax,%eax
  8012a9:	78 62                	js     80130d <write+0x7d>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012ab:	83 ec 08             	sub    $0x8,%esp
  8012ae:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012b1:	50                   	push   %eax
  8012b2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012b5:	ff 30                	pushl  (%eax)
  8012b7:	e8 cd fc ff ff       	call   800f89 <dev_lookup>
  8012bc:	83 c4 10             	add    $0x10,%esp
  8012bf:	85 c0                	test   %eax,%eax
  8012c1:	78 4a                	js     80130d <write+0x7d>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8012c3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012c6:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8012ca:	75 21                	jne    8012ed <write+0x5d>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8012cc:	a1 04 40 80 00       	mov    0x804004,%eax
  8012d1:	8b 40 48             	mov    0x48(%eax),%eax
  8012d4:	83 ec 04             	sub    $0x4,%esp
  8012d7:	53                   	push   %ebx
  8012d8:	50                   	push   %eax
  8012d9:	68 05 22 80 00       	push   $0x802205
  8012de:	e8 b9 ee ff ff       	call   80019c <cprintf>
		return -E_INVAL;
  8012e3:	83 c4 10             	add    $0x10,%esp
  8012e6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012eb:	eb 20                	jmp    80130d <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8012ed:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8012f0:	8b 52 0c             	mov    0xc(%edx),%edx
  8012f3:	85 d2                	test   %edx,%edx
  8012f5:	74 11                	je     801308 <write+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8012f7:	83 ec 04             	sub    $0x4,%esp
  8012fa:	ff 75 10             	pushl  0x10(%ebp)
  8012fd:	ff 75 0c             	pushl  0xc(%ebp)
  801300:	50                   	push   %eax
  801301:	ff d2                	call   *%edx
  801303:	83 c4 10             	add    $0x10,%esp
  801306:	eb 05                	jmp    80130d <write+0x7d>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801308:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  80130d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801310:	c9                   	leave  
  801311:	c3                   	ret    

00801312 <seek>:

int
seek(int fdnum, off_t offset)
{
  801312:	55                   	push   %ebp
  801313:	89 e5                	mov    %esp,%ebp
  801315:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801318:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80131b:	50                   	push   %eax
  80131c:	ff 75 08             	pushl  0x8(%ebp)
  80131f:	e8 0f fc ff ff       	call   800f33 <fd_lookup>
  801324:	83 c4 08             	add    $0x8,%esp
  801327:	85 c0                	test   %eax,%eax
  801329:	78 0e                	js     801339 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  80132b:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80132e:	8b 55 0c             	mov    0xc(%ebp),%edx
  801331:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801334:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801339:	c9                   	leave  
  80133a:	c3                   	ret    

0080133b <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80133b:	55                   	push   %ebp
  80133c:	89 e5                	mov    %esp,%ebp
  80133e:	53                   	push   %ebx
  80133f:	83 ec 14             	sub    $0x14,%esp
  801342:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801345:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801348:	50                   	push   %eax
  801349:	53                   	push   %ebx
  80134a:	e8 e4 fb ff ff       	call   800f33 <fd_lookup>
  80134f:	83 c4 08             	add    $0x8,%esp
  801352:	85 c0                	test   %eax,%eax
  801354:	78 5f                	js     8013b5 <ftruncate+0x7a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801356:	83 ec 08             	sub    $0x8,%esp
  801359:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80135c:	50                   	push   %eax
  80135d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801360:	ff 30                	pushl  (%eax)
  801362:	e8 22 fc ff ff       	call   800f89 <dev_lookup>
  801367:	83 c4 10             	add    $0x10,%esp
  80136a:	85 c0                	test   %eax,%eax
  80136c:	78 47                	js     8013b5 <ftruncate+0x7a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80136e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801371:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801375:	75 21                	jne    801398 <ftruncate+0x5d>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801377:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80137c:	8b 40 48             	mov    0x48(%eax),%eax
  80137f:	83 ec 04             	sub    $0x4,%esp
  801382:	53                   	push   %ebx
  801383:	50                   	push   %eax
  801384:	68 c8 21 80 00       	push   $0x8021c8
  801389:	e8 0e ee ff ff       	call   80019c <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80138e:	83 c4 10             	add    $0x10,%esp
  801391:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801396:	eb 1d                	jmp    8013b5 <ftruncate+0x7a>
	}
	if (!dev->dev_trunc)
  801398:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80139b:	8b 52 18             	mov    0x18(%edx),%edx
  80139e:	85 d2                	test   %edx,%edx
  8013a0:	74 0e                	je     8013b0 <ftruncate+0x75>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8013a2:	83 ec 08             	sub    $0x8,%esp
  8013a5:	ff 75 0c             	pushl  0xc(%ebp)
  8013a8:	50                   	push   %eax
  8013a9:	ff d2                	call   *%edx
  8013ab:	83 c4 10             	add    $0x10,%esp
  8013ae:	eb 05                	jmp    8013b5 <ftruncate+0x7a>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8013b0:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  8013b5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013b8:	c9                   	leave  
  8013b9:	c3                   	ret    

008013ba <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8013ba:	55                   	push   %ebp
  8013bb:	89 e5                	mov    %esp,%ebp
  8013bd:	53                   	push   %ebx
  8013be:	83 ec 14             	sub    $0x14,%esp
  8013c1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8013c4:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8013c7:	50                   	push   %eax
  8013c8:	ff 75 08             	pushl  0x8(%ebp)
  8013cb:	e8 63 fb ff ff       	call   800f33 <fd_lookup>
  8013d0:	83 c4 08             	add    $0x8,%esp
  8013d3:	85 c0                	test   %eax,%eax
  8013d5:	78 52                	js     801429 <fstat+0x6f>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013d7:	83 ec 08             	sub    $0x8,%esp
  8013da:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013dd:	50                   	push   %eax
  8013de:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013e1:	ff 30                	pushl  (%eax)
  8013e3:	e8 a1 fb ff ff       	call   800f89 <dev_lookup>
  8013e8:	83 c4 10             	add    $0x10,%esp
  8013eb:	85 c0                	test   %eax,%eax
  8013ed:	78 3a                	js     801429 <fstat+0x6f>
		return r;
	if (!dev->dev_stat)
  8013ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013f2:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8013f6:	74 2c                	je     801424 <fstat+0x6a>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8013f8:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8013fb:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801402:	00 00 00 
	stat->st_isdir = 0;
  801405:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80140c:	00 00 00 
	stat->st_dev = dev;
  80140f:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801415:	83 ec 08             	sub    $0x8,%esp
  801418:	53                   	push   %ebx
  801419:	ff 75 f0             	pushl  -0x10(%ebp)
  80141c:	ff 50 14             	call   *0x14(%eax)
  80141f:	83 c4 10             	add    $0x10,%esp
  801422:	eb 05                	jmp    801429 <fstat+0x6f>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801424:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801429:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80142c:	c9                   	leave  
  80142d:	c3                   	ret    

0080142e <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80142e:	55                   	push   %ebp
  80142f:	89 e5                	mov    %esp,%ebp
  801431:	56                   	push   %esi
  801432:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801433:	83 ec 08             	sub    $0x8,%esp
  801436:	6a 00                	push   $0x0
  801438:	ff 75 08             	pushl  0x8(%ebp)
  80143b:	e8 78 01 00 00       	call   8015b8 <open>
  801440:	89 c3                	mov    %eax,%ebx
  801442:	83 c4 10             	add    $0x10,%esp
  801445:	85 c0                	test   %eax,%eax
  801447:	78 1b                	js     801464 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801449:	83 ec 08             	sub    $0x8,%esp
  80144c:	ff 75 0c             	pushl  0xc(%ebp)
  80144f:	50                   	push   %eax
  801450:	e8 65 ff ff ff       	call   8013ba <fstat>
  801455:	89 c6                	mov    %eax,%esi
	close(fd);
  801457:	89 1c 24             	mov    %ebx,(%esp)
  80145a:	e8 18 fc ff ff       	call   801077 <close>
	return r;
  80145f:	83 c4 10             	add    $0x10,%esp
  801462:	89 f3                	mov    %esi,%ebx
}
  801464:	89 d8                	mov    %ebx,%eax
  801466:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801469:	5b                   	pop    %ebx
  80146a:	5e                   	pop    %esi
  80146b:	c9                   	leave  
  80146c:	c3                   	ret    
  80146d:	00 00                	add    %al,(%eax)
	...

00801470 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801470:	55                   	push   %ebp
  801471:	89 e5                	mov    %esp,%ebp
  801473:	56                   	push   %esi
  801474:	53                   	push   %ebx
  801475:	89 c3                	mov    %eax,%ebx
  801477:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  801479:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801480:	75 12                	jne    801494 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801482:	83 ec 0c             	sub    $0xc,%esp
  801485:	6a 01                	push   $0x1
  801487:	e8 be f9 ff ff       	call   800e4a <ipc_find_env>
  80148c:	a3 00 40 80 00       	mov    %eax,0x804000
  801491:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801494:	6a 07                	push   $0x7
  801496:	68 00 50 80 00       	push   $0x805000
  80149b:	53                   	push   %ebx
  80149c:	ff 35 00 40 80 00    	pushl  0x804000
  8014a2:	e8 4e f9 ff ff       	call   800df5 <ipc_send>
	
	return ipc_recv(NULL, dstva, NULL);
  8014a7:	83 c4 0c             	add    $0xc,%esp
  8014aa:	6a 00                	push   $0x0
  8014ac:	56                   	push   %esi
  8014ad:	6a 00                	push   $0x0
  8014af:	e8 cc f8 ff ff       	call   800d80 <ipc_recv>
}
  8014b4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8014b7:	5b                   	pop    %ebx
  8014b8:	5e                   	pop    %esi
  8014b9:	c9                   	leave  
  8014ba:	c3                   	ret    

008014bb <devfile_stat>:
}


static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8014bb:	55                   	push   %ebp
  8014bc:	89 e5                	mov    %esp,%ebp
  8014be:	53                   	push   %ebx
  8014bf:	83 ec 04             	sub    $0x4,%esp
  8014c2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8014c5:	8b 45 08             	mov    0x8(%ebp),%eax
  8014c8:	8b 40 0c             	mov    0xc(%eax),%eax
  8014cb:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0) {
  8014d0:	ba 00 00 00 00       	mov    $0x0,%edx
  8014d5:	b8 05 00 00 00       	mov    $0x5,%eax
  8014da:	e8 91 ff ff ff       	call   801470 <fsipc>
  8014df:	85 c0                	test   %eax,%eax
  8014e1:	78 2c                	js     80150f <devfile_stat+0x54>
		return r;
	}
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8014e3:	83 ec 08             	sub    $0x8,%esp
  8014e6:	68 00 50 80 00       	push   $0x805000
  8014eb:	53                   	push   %ebx
  8014ec:	e8 61 f2 ff ff       	call   800752 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8014f1:	a1 80 50 80 00       	mov    0x805080,%eax
  8014f6:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8014fc:	a1 84 50 80 00       	mov    0x805084,%eax
  801501:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801507:	83 c4 10             	add    $0x10,%esp
  80150a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80150f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801512:	c9                   	leave  
  801513:	c3                   	ret    

00801514 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801514:	55                   	push   %ebp
  801515:	89 e5                	mov    %esp,%ebp
  801517:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80151a:	8b 45 08             	mov    0x8(%ebp),%eax
  80151d:	8b 40 0c             	mov    0xc(%eax),%eax
  801520:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801525:	ba 00 00 00 00       	mov    $0x0,%edx
  80152a:	b8 06 00 00 00       	mov    $0x6,%eax
  80152f:	e8 3c ff ff ff       	call   801470 <fsipc>
}
  801534:	c9                   	leave  
  801535:	c3                   	ret    

00801536 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801536:	55                   	push   %ebp
  801537:	89 e5                	mov    %esp,%ebp
  801539:	56                   	push   %esi
  80153a:	53                   	push   %ebx
  80153b:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80153e:	8b 45 08             	mov    0x8(%ebp),%eax
  801541:	8b 40 0c             	mov    0xc(%eax),%eax
  801544:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801549:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80154f:	ba 00 00 00 00       	mov    $0x0,%edx
  801554:	b8 03 00 00 00       	mov    $0x3,%eax
  801559:	e8 12 ff ff ff       	call   801470 <fsipc>
  80155e:	89 c3                	mov    %eax,%ebx
  801560:	85 c0                	test   %eax,%eax
  801562:	78 4b                	js     8015af <devfile_read+0x79>
		return r;
	assert(r <= n);
  801564:	39 c6                	cmp    %eax,%esi
  801566:	73 16                	jae    80157e <devfile_read+0x48>
  801568:	68 34 22 80 00       	push   $0x802234
  80156d:	68 3b 22 80 00       	push   $0x80223b
  801572:	6a 7d                	push   $0x7d
  801574:	68 50 22 80 00       	push   $0x802250
  801579:	e8 ce 05 00 00       	call   801b4c <_panic>
	assert(r <= PGSIZE);
  80157e:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801583:	7e 16                	jle    80159b <devfile_read+0x65>
  801585:	68 5b 22 80 00       	push   $0x80225b
  80158a:	68 3b 22 80 00       	push   $0x80223b
  80158f:	6a 7e                	push   $0x7e
  801591:	68 50 22 80 00       	push   $0x802250
  801596:	e8 b1 05 00 00       	call   801b4c <_panic>
	memmove(buf, &fsipcbuf, r);
  80159b:	83 ec 04             	sub    $0x4,%esp
  80159e:	50                   	push   %eax
  80159f:	68 00 50 80 00       	push   $0x805000
  8015a4:	ff 75 0c             	pushl  0xc(%ebp)
  8015a7:	e8 67 f3 ff ff       	call   800913 <memmove>
	return r;
  8015ac:	83 c4 10             	add    $0x10,%esp
}
  8015af:	89 d8                	mov    %ebx,%eax
  8015b1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8015b4:	5b                   	pop    %ebx
  8015b5:	5e                   	pop    %esi
  8015b6:	c9                   	leave  
  8015b7:	c3                   	ret    

008015b8 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8015b8:	55                   	push   %ebp
  8015b9:	89 e5                	mov    %esp,%ebp
  8015bb:	56                   	push   %esi
  8015bc:	53                   	push   %ebx
  8015bd:	83 ec 1c             	sub    $0x1c,%esp
  8015c0:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8015c3:	56                   	push   %esi
  8015c4:	e8 37 f1 ff ff       	call   800700 <strlen>
  8015c9:	83 c4 10             	add    $0x10,%esp
  8015cc:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8015d1:	7f 65                	jg     801638 <open+0x80>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8015d3:	83 ec 0c             	sub    $0xc,%esp
  8015d6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015d9:	50                   	push   %eax
  8015da:	e8 e1 f8 ff ff       	call   800ec0 <fd_alloc>
  8015df:	89 c3                	mov    %eax,%ebx
  8015e1:	83 c4 10             	add    $0x10,%esp
  8015e4:	85 c0                	test   %eax,%eax
  8015e6:	78 55                	js     80163d <open+0x85>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8015e8:	83 ec 08             	sub    $0x8,%esp
  8015eb:	56                   	push   %esi
  8015ec:	68 00 50 80 00       	push   $0x805000
  8015f1:	e8 5c f1 ff ff       	call   800752 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8015f6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8015f9:	a3 00 54 80 00       	mov    %eax,0x805400



	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8015fe:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801601:	b8 01 00 00 00       	mov    $0x1,%eax
  801606:	e8 65 fe ff ff       	call   801470 <fsipc>
  80160b:	89 c3                	mov    %eax,%ebx
  80160d:	83 c4 10             	add    $0x10,%esp
  801610:	85 c0                	test   %eax,%eax
  801612:	79 12                	jns    801626 <open+0x6e>
		fd_close(fd, 0);
  801614:	83 ec 08             	sub    $0x8,%esp
  801617:	6a 00                	push   $0x0
  801619:	ff 75 f4             	pushl  -0xc(%ebp)
  80161c:	e8 ce f9 ff ff       	call   800fef <fd_close>
		return r;
  801621:	83 c4 10             	add    $0x10,%esp
  801624:	eb 17                	jmp    80163d <open+0x85>
	}

	return fd2num(fd);
  801626:	83 ec 0c             	sub    $0xc,%esp
  801629:	ff 75 f4             	pushl  -0xc(%ebp)
  80162c:	e8 67 f8 ff ff       	call   800e98 <fd2num>
  801631:	89 c3                	mov    %eax,%ebx
  801633:	83 c4 10             	add    $0x10,%esp
  801636:	eb 05                	jmp    80163d <open+0x85>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801638:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  80163d:	89 d8                	mov    %ebx,%eax
  80163f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801642:	5b                   	pop    %ebx
  801643:	5e                   	pop    %esi
  801644:	c9                   	leave  
  801645:	c3                   	ret    
	...

00801648 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801648:	55                   	push   %ebp
  801649:	89 e5                	mov    %esp,%ebp
  80164b:	56                   	push   %esi
  80164c:	53                   	push   %ebx
  80164d:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801650:	83 ec 0c             	sub    $0xc,%esp
  801653:	ff 75 08             	pushl  0x8(%ebp)
  801656:	e8 4d f8 ff ff       	call   800ea8 <fd2data>
  80165b:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  80165d:	83 c4 08             	add    $0x8,%esp
  801660:	68 67 22 80 00       	push   $0x802267
  801665:	56                   	push   %esi
  801666:	e8 e7 f0 ff ff       	call   800752 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  80166b:	8b 43 04             	mov    0x4(%ebx),%eax
  80166e:	2b 03                	sub    (%ebx),%eax
  801670:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  801676:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  80167d:	00 00 00 
	stat->st_dev = &devpipe;
  801680:	c7 86 88 00 00 00 20 	movl   $0x803020,0x88(%esi)
  801687:	30 80 00 
	return 0;
}
  80168a:	b8 00 00 00 00       	mov    $0x0,%eax
  80168f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801692:	5b                   	pop    %ebx
  801693:	5e                   	pop    %esi
  801694:	c9                   	leave  
  801695:	c3                   	ret    

00801696 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801696:	55                   	push   %ebp
  801697:	89 e5                	mov    %esp,%ebp
  801699:	53                   	push   %ebx
  80169a:	83 ec 0c             	sub    $0xc,%esp
  80169d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8016a0:	53                   	push   %ebx
  8016a1:	6a 00                	push   $0x0
  8016a3:	e8 76 f5 ff ff       	call   800c1e <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8016a8:	89 1c 24             	mov    %ebx,(%esp)
  8016ab:	e8 f8 f7 ff ff       	call   800ea8 <fd2data>
  8016b0:	83 c4 08             	add    $0x8,%esp
  8016b3:	50                   	push   %eax
  8016b4:	6a 00                	push   $0x0
  8016b6:	e8 63 f5 ff ff       	call   800c1e <sys_page_unmap>
}
  8016bb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016be:	c9                   	leave  
  8016bf:	c3                   	ret    

008016c0 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8016c0:	55                   	push   %ebp
  8016c1:	89 e5                	mov    %esp,%ebp
  8016c3:	57                   	push   %edi
  8016c4:	56                   	push   %esi
  8016c5:	53                   	push   %ebx
  8016c6:	83 ec 1c             	sub    $0x1c,%esp
  8016c9:	89 c7                	mov    %eax,%edi
  8016cb:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8016ce:	a1 04 40 80 00       	mov    0x804004,%eax
  8016d3:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  8016d6:	83 ec 0c             	sub    $0xc,%esp
  8016d9:	57                   	push   %edi
  8016da:	e8 b5 04 00 00       	call   801b94 <pageref>
  8016df:	89 c6                	mov    %eax,%esi
  8016e1:	83 c4 04             	add    $0x4,%esp
  8016e4:	ff 75 e4             	pushl  -0x1c(%ebp)
  8016e7:	e8 a8 04 00 00       	call   801b94 <pageref>
  8016ec:	83 c4 10             	add    $0x10,%esp
  8016ef:	39 c6                	cmp    %eax,%esi
  8016f1:	0f 94 c0             	sete   %al
  8016f4:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  8016f7:	8b 15 04 40 80 00    	mov    0x804004,%edx
  8016fd:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801700:	39 cb                	cmp    %ecx,%ebx
  801702:	75 08                	jne    80170c <_pipeisclosed+0x4c>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  801704:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801707:	5b                   	pop    %ebx
  801708:	5e                   	pop    %esi
  801709:	5f                   	pop    %edi
  80170a:	c9                   	leave  
  80170b:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  80170c:	83 f8 01             	cmp    $0x1,%eax
  80170f:	75 bd                	jne    8016ce <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801711:	8b 42 58             	mov    0x58(%edx),%eax
  801714:	6a 01                	push   $0x1
  801716:	50                   	push   %eax
  801717:	53                   	push   %ebx
  801718:	68 6e 22 80 00       	push   $0x80226e
  80171d:	e8 7a ea ff ff       	call   80019c <cprintf>
  801722:	83 c4 10             	add    $0x10,%esp
  801725:	eb a7                	jmp    8016ce <_pipeisclosed+0xe>

00801727 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801727:	55                   	push   %ebp
  801728:	89 e5                	mov    %esp,%ebp
  80172a:	57                   	push   %edi
  80172b:	56                   	push   %esi
  80172c:	53                   	push   %ebx
  80172d:	83 ec 28             	sub    $0x28,%esp
  801730:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801733:	56                   	push   %esi
  801734:	e8 6f f7 ff ff       	call   800ea8 <fd2data>
  801739:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80173b:	83 c4 10             	add    $0x10,%esp
  80173e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801742:	75 4a                	jne    80178e <devpipe_write+0x67>
  801744:	bf 00 00 00 00       	mov    $0x0,%edi
  801749:	eb 56                	jmp    8017a1 <devpipe_write+0x7a>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  80174b:	89 da                	mov    %ebx,%edx
  80174d:	89 f0                	mov    %esi,%eax
  80174f:	e8 6c ff ff ff       	call   8016c0 <_pipeisclosed>
  801754:	85 c0                	test   %eax,%eax
  801756:	75 4d                	jne    8017a5 <devpipe_write+0x7e>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801758:	e8 50 f4 ff ff       	call   800bad <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  80175d:	8b 43 04             	mov    0x4(%ebx),%eax
  801760:	8b 13                	mov    (%ebx),%edx
  801762:	83 c2 20             	add    $0x20,%edx
  801765:	39 d0                	cmp    %edx,%eax
  801767:	73 e2                	jae    80174b <devpipe_write+0x24>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801769:	89 c2                	mov    %eax,%edx
  80176b:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  801771:	79 05                	jns    801778 <devpipe_write+0x51>
  801773:	4a                   	dec    %edx
  801774:	83 ca e0             	or     $0xffffffe0,%edx
  801777:	42                   	inc    %edx
  801778:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80177b:	8a 0c 39             	mov    (%ecx,%edi,1),%cl
  80177e:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801782:	40                   	inc    %eax
  801783:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801786:	47                   	inc    %edi
  801787:	39 7d 10             	cmp    %edi,0x10(%ebp)
  80178a:	77 07                	ja     801793 <devpipe_write+0x6c>
  80178c:	eb 13                	jmp    8017a1 <devpipe_write+0x7a>
  80178e:	bf 00 00 00 00       	mov    $0x0,%edi
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801793:	8b 43 04             	mov    0x4(%ebx),%eax
  801796:	8b 13                	mov    (%ebx),%edx
  801798:	83 c2 20             	add    $0x20,%edx
  80179b:	39 d0                	cmp    %edx,%eax
  80179d:	73 ac                	jae    80174b <devpipe_write+0x24>
  80179f:	eb c8                	jmp    801769 <devpipe_write+0x42>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  8017a1:	89 f8                	mov    %edi,%eax
  8017a3:	eb 05                	jmp    8017aa <devpipe_write+0x83>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8017a5:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  8017aa:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8017ad:	5b                   	pop    %ebx
  8017ae:	5e                   	pop    %esi
  8017af:	5f                   	pop    %edi
  8017b0:	c9                   	leave  
  8017b1:	c3                   	ret    

008017b2 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  8017b2:	55                   	push   %ebp
  8017b3:	89 e5                	mov    %esp,%ebp
  8017b5:	57                   	push   %edi
  8017b6:	56                   	push   %esi
  8017b7:	53                   	push   %ebx
  8017b8:	83 ec 18             	sub    $0x18,%esp
  8017bb:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  8017be:	57                   	push   %edi
  8017bf:	e8 e4 f6 ff ff       	call   800ea8 <fd2data>
  8017c4:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8017c6:	83 c4 10             	add    $0x10,%esp
  8017c9:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8017cd:	75 44                	jne    801813 <devpipe_read+0x61>
  8017cf:	be 00 00 00 00       	mov    $0x0,%esi
  8017d4:	eb 4f                	jmp    801825 <devpipe_read+0x73>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
				return i;
  8017d6:	89 f0                	mov    %esi,%eax
  8017d8:	eb 54                	jmp    80182e <devpipe_read+0x7c>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  8017da:	89 da                	mov    %ebx,%edx
  8017dc:	89 f8                	mov    %edi,%eax
  8017de:	e8 dd fe ff ff       	call   8016c0 <_pipeisclosed>
  8017e3:	85 c0                	test   %eax,%eax
  8017e5:	75 42                	jne    801829 <devpipe_read+0x77>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  8017e7:	e8 c1 f3 ff ff       	call   800bad <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8017ec:	8b 03                	mov    (%ebx),%eax
  8017ee:	3b 43 04             	cmp    0x4(%ebx),%eax
  8017f1:	74 e7                	je     8017da <devpipe_read+0x28>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8017f3:	25 1f 00 00 80       	and    $0x8000001f,%eax
  8017f8:	79 05                	jns    8017ff <devpipe_read+0x4d>
  8017fa:	48                   	dec    %eax
  8017fb:	83 c8 e0             	or     $0xffffffe0,%eax
  8017fe:	40                   	inc    %eax
  8017ff:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  801803:	8b 55 0c             	mov    0xc(%ebp),%edx
  801806:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  801809:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80180b:	46                   	inc    %esi
  80180c:	39 75 10             	cmp    %esi,0x10(%ebp)
  80180f:	77 07                	ja     801818 <devpipe_read+0x66>
  801811:	eb 12                	jmp    801825 <devpipe_read+0x73>
  801813:	be 00 00 00 00       	mov    $0x0,%esi
		while (p->p_rpos == p->p_wpos) {
  801818:	8b 03                	mov    (%ebx),%eax
  80181a:	3b 43 04             	cmp    0x4(%ebx),%eax
  80181d:	75 d4                	jne    8017f3 <devpipe_read+0x41>
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  80181f:	85 f6                	test   %esi,%esi
  801821:	75 b3                	jne    8017d6 <devpipe_read+0x24>
  801823:	eb b5                	jmp    8017da <devpipe_read+0x28>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801825:	89 f0                	mov    %esi,%eax
  801827:	eb 05                	jmp    80182e <devpipe_read+0x7c>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801829:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  80182e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801831:	5b                   	pop    %ebx
  801832:	5e                   	pop    %esi
  801833:	5f                   	pop    %edi
  801834:	c9                   	leave  
  801835:	c3                   	ret    

00801836 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801836:	55                   	push   %ebp
  801837:	89 e5                	mov    %esp,%ebp
  801839:	57                   	push   %edi
  80183a:	56                   	push   %esi
  80183b:	53                   	push   %ebx
  80183c:	83 ec 28             	sub    $0x28,%esp
  80183f:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801842:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801845:	50                   	push   %eax
  801846:	e8 75 f6 ff ff       	call   800ec0 <fd_alloc>
  80184b:	89 c3                	mov    %eax,%ebx
  80184d:	83 c4 10             	add    $0x10,%esp
  801850:	85 c0                	test   %eax,%eax
  801852:	0f 88 24 01 00 00    	js     80197c <pipe+0x146>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801858:	83 ec 04             	sub    $0x4,%esp
  80185b:	68 07 04 00 00       	push   $0x407
  801860:	ff 75 e4             	pushl  -0x1c(%ebp)
  801863:	6a 00                	push   $0x0
  801865:	e8 6a f3 ff ff       	call   800bd4 <sys_page_alloc>
  80186a:	89 c3                	mov    %eax,%ebx
  80186c:	83 c4 10             	add    $0x10,%esp
  80186f:	85 c0                	test   %eax,%eax
  801871:	0f 88 05 01 00 00    	js     80197c <pipe+0x146>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801877:	83 ec 0c             	sub    $0xc,%esp
  80187a:	8d 45 e0             	lea    -0x20(%ebp),%eax
  80187d:	50                   	push   %eax
  80187e:	e8 3d f6 ff ff       	call   800ec0 <fd_alloc>
  801883:	89 c3                	mov    %eax,%ebx
  801885:	83 c4 10             	add    $0x10,%esp
  801888:	85 c0                	test   %eax,%eax
  80188a:	0f 88 dc 00 00 00    	js     80196c <pipe+0x136>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801890:	83 ec 04             	sub    $0x4,%esp
  801893:	68 07 04 00 00       	push   $0x407
  801898:	ff 75 e0             	pushl  -0x20(%ebp)
  80189b:	6a 00                	push   $0x0
  80189d:	e8 32 f3 ff ff       	call   800bd4 <sys_page_alloc>
  8018a2:	89 c3                	mov    %eax,%ebx
  8018a4:	83 c4 10             	add    $0x10,%esp
  8018a7:	85 c0                	test   %eax,%eax
  8018a9:	0f 88 bd 00 00 00    	js     80196c <pipe+0x136>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  8018af:	83 ec 0c             	sub    $0xc,%esp
  8018b2:	ff 75 e4             	pushl  -0x1c(%ebp)
  8018b5:	e8 ee f5 ff ff       	call   800ea8 <fd2data>
  8018ba:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8018bc:	83 c4 0c             	add    $0xc,%esp
  8018bf:	68 07 04 00 00       	push   $0x407
  8018c4:	50                   	push   %eax
  8018c5:	6a 00                	push   $0x0
  8018c7:	e8 08 f3 ff ff       	call   800bd4 <sys_page_alloc>
  8018cc:	89 c3                	mov    %eax,%ebx
  8018ce:	83 c4 10             	add    $0x10,%esp
  8018d1:	85 c0                	test   %eax,%eax
  8018d3:	0f 88 83 00 00 00    	js     80195c <pipe+0x126>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8018d9:	83 ec 0c             	sub    $0xc,%esp
  8018dc:	ff 75 e0             	pushl  -0x20(%ebp)
  8018df:	e8 c4 f5 ff ff       	call   800ea8 <fd2data>
  8018e4:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  8018eb:	50                   	push   %eax
  8018ec:	6a 00                	push   $0x0
  8018ee:	56                   	push   %esi
  8018ef:	6a 00                	push   $0x0
  8018f1:	e8 02 f3 ff ff       	call   800bf8 <sys_page_map>
  8018f6:	89 c3                	mov    %eax,%ebx
  8018f8:	83 c4 20             	add    $0x20,%esp
  8018fb:	85 c0                	test   %eax,%eax
  8018fd:	78 4f                	js     80194e <pipe+0x118>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  8018ff:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801905:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801908:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  80190a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80190d:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801914:	8b 15 20 30 80 00    	mov    0x803020,%edx
  80191a:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80191d:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  80191f:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801922:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801929:	83 ec 0c             	sub    $0xc,%esp
  80192c:	ff 75 e4             	pushl  -0x1c(%ebp)
  80192f:	e8 64 f5 ff ff       	call   800e98 <fd2num>
  801934:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  801936:	83 c4 04             	add    $0x4,%esp
  801939:	ff 75 e0             	pushl  -0x20(%ebp)
  80193c:	e8 57 f5 ff ff       	call   800e98 <fd2num>
  801941:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  801944:	83 c4 10             	add    $0x10,%esp
  801947:	bb 00 00 00 00       	mov    $0x0,%ebx
  80194c:	eb 2e                	jmp    80197c <pipe+0x146>

    err3:
	sys_page_unmap(0, va);
  80194e:	83 ec 08             	sub    $0x8,%esp
  801951:	56                   	push   %esi
  801952:	6a 00                	push   $0x0
  801954:	e8 c5 f2 ff ff       	call   800c1e <sys_page_unmap>
  801959:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  80195c:	83 ec 08             	sub    $0x8,%esp
  80195f:	ff 75 e0             	pushl  -0x20(%ebp)
  801962:	6a 00                	push   $0x0
  801964:	e8 b5 f2 ff ff       	call   800c1e <sys_page_unmap>
  801969:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  80196c:	83 ec 08             	sub    $0x8,%esp
  80196f:	ff 75 e4             	pushl  -0x1c(%ebp)
  801972:	6a 00                	push   $0x0
  801974:	e8 a5 f2 ff ff       	call   800c1e <sys_page_unmap>
  801979:	83 c4 10             	add    $0x10,%esp
    err:
	return r;
}
  80197c:	89 d8                	mov    %ebx,%eax
  80197e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801981:	5b                   	pop    %ebx
  801982:	5e                   	pop    %esi
  801983:	5f                   	pop    %edi
  801984:	c9                   	leave  
  801985:	c3                   	ret    

00801986 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801986:	55                   	push   %ebp
  801987:	89 e5                	mov    %esp,%ebp
  801989:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80198c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80198f:	50                   	push   %eax
  801990:	ff 75 08             	pushl  0x8(%ebp)
  801993:	e8 9b f5 ff ff       	call   800f33 <fd_lookup>
  801998:	83 c4 10             	add    $0x10,%esp
  80199b:	85 c0                	test   %eax,%eax
  80199d:	78 18                	js     8019b7 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  80199f:	83 ec 0c             	sub    $0xc,%esp
  8019a2:	ff 75 f4             	pushl  -0xc(%ebp)
  8019a5:	e8 fe f4 ff ff       	call   800ea8 <fd2data>
	return _pipeisclosed(fd, p);
  8019aa:	89 c2                	mov    %eax,%edx
  8019ac:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019af:	e8 0c fd ff ff       	call   8016c0 <_pipeisclosed>
  8019b4:	83 c4 10             	add    $0x10,%esp
}
  8019b7:	c9                   	leave  
  8019b8:	c3                   	ret    
  8019b9:	00 00                	add    %al,(%eax)
	...

008019bc <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  8019bc:	55                   	push   %ebp
  8019bd:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  8019bf:	b8 00 00 00 00       	mov    $0x0,%eax
  8019c4:	c9                   	leave  
  8019c5:	c3                   	ret    

008019c6 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8019c6:	55                   	push   %ebp
  8019c7:	89 e5                	mov    %esp,%ebp
  8019c9:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  8019cc:	68 86 22 80 00       	push   $0x802286
  8019d1:	ff 75 0c             	pushl  0xc(%ebp)
  8019d4:	e8 79 ed ff ff       	call   800752 <strcpy>
	return 0;
}
  8019d9:	b8 00 00 00 00       	mov    $0x0,%eax
  8019de:	c9                   	leave  
  8019df:	c3                   	ret    

008019e0 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8019e0:	55                   	push   %ebp
  8019e1:	89 e5                	mov    %esp,%ebp
  8019e3:	57                   	push   %edi
  8019e4:	56                   	push   %esi
  8019e5:	53                   	push   %ebx
  8019e6:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8019ec:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8019f0:	74 45                	je     801a37 <devcons_write+0x57>
  8019f2:	b8 00 00 00 00       	mov    $0x0,%eax
  8019f7:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8019fc:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801a02:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801a05:	29 c3                	sub    %eax,%ebx
		if (m > sizeof(buf) - 1)
  801a07:	83 fb 7f             	cmp    $0x7f,%ebx
  801a0a:	76 05                	jbe    801a11 <devcons_write+0x31>
			m = sizeof(buf) - 1;
  801a0c:	bb 7f 00 00 00       	mov    $0x7f,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  801a11:	83 ec 04             	sub    $0x4,%esp
  801a14:	53                   	push   %ebx
  801a15:	03 45 0c             	add    0xc(%ebp),%eax
  801a18:	50                   	push   %eax
  801a19:	57                   	push   %edi
  801a1a:	e8 f4 ee ff ff       	call   800913 <memmove>
		sys_cputs(buf, m);
  801a1f:	83 c4 08             	add    $0x8,%esp
  801a22:	53                   	push   %ebx
  801a23:	57                   	push   %edi
  801a24:	e8 f4 f0 ff ff       	call   800b1d <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801a29:	01 de                	add    %ebx,%esi
  801a2b:	89 f0                	mov    %esi,%eax
  801a2d:	83 c4 10             	add    $0x10,%esp
  801a30:	3b 75 10             	cmp    0x10(%ebp),%esi
  801a33:	72 cd                	jb     801a02 <devcons_write+0x22>
  801a35:	eb 05                	jmp    801a3c <devcons_write+0x5c>
  801a37:	be 00 00 00 00       	mov    $0x0,%esi
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801a3c:	89 f0                	mov    %esi,%eax
  801a3e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a41:	5b                   	pop    %ebx
  801a42:	5e                   	pop    %esi
  801a43:	5f                   	pop    %edi
  801a44:	c9                   	leave  
  801a45:	c3                   	ret    

00801a46 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801a46:	55                   	push   %ebp
  801a47:	89 e5                	mov    %esp,%ebp
  801a49:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  801a4c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801a50:	75 07                	jne    801a59 <devcons_read+0x13>
  801a52:	eb 25                	jmp    801a79 <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801a54:	e8 54 f1 ff ff       	call   800bad <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801a59:	e8 e5 f0 ff ff       	call   800b43 <sys_cgetc>
  801a5e:	85 c0                	test   %eax,%eax
  801a60:	74 f2                	je     801a54 <devcons_read+0xe>
  801a62:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  801a64:	85 c0                	test   %eax,%eax
  801a66:	78 1d                	js     801a85 <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801a68:	83 f8 04             	cmp    $0x4,%eax
  801a6b:	74 13                	je     801a80 <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  801a6d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a70:	88 10                	mov    %dl,(%eax)
	return 1;
  801a72:	b8 01 00 00 00       	mov    $0x1,%eax
  801a77:	eb 0c                	jmp    801a85 <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  801a79:	b8 00 00 00 00       	mov    $0x0,%eax
  801a7e:	eb 05                	jmp    801a85 <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801a80:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801a85:	c9                   	leave  
  801a86:	c3                   	ret    

00801a87 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801a87:	55                   	push   %ebp
  801a88:	89 e5                	mov    %esp,%ebp
  801a8a:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801a8d:	8b 45 08             	mov    0x8(%ebp),%eax
  801a90:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801a93:	6a 01                	push   $0x1
  801a95:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801a98:	50                   	push   %eax
  801a99:	e8 7f f0 ff ff       	call   800b1d <sys_cputs>
  801a9e:	83 c4 10             	add    $0x10,%esp
}
  801aa1:	c9                   	leave  
  801aa2:	c3                   	ret    

00801aa3 <getchar>:

int
getchar(void)
{
  801aa3:	55                   	push   %ebp
  801aa4:	89 e5                	mov    %esp,%ebp
  801aa6:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801aa9:	6a 01                	push   $0x1
  801aab:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801aae:	50                   	push   %eax
  801aaf:	6a 00                	push   $0x0
  801ab1:	e8 fe f6 ff ff       	call   8011b4 <read>
	if (r < 0)
  801ab6:	83 c4 10             	add    $0x10,%esp
  801ab9:	85 c0                	test   %eax,%eax
  801abb:	78 0f                	js     801acc <getchar+0x29>
		return r;
	if (r < 1)
  801abd:	85 c0                	test   %eax,%eax
  801abf:	7e 06                	jle    801ac7 <getchar+0x24>
		return -E_EOF;
	return c;
  801ac1:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801ac5:	eb 05                	jmp    801acc <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801ac7:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801acc:	c9                   	leave  
  801acd:	c3                   	ret    

00801ace <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801ace:	55                   	push   %ebp
  801acf:	89 e5                	mov    %esp,%ebp
  801ad1:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801ad4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ad7:	50                   	push   %eax
  801ad8:	ff 75 08             	pushl  0x8(%ebp)
  801adb:	e8 53 f4 ff ff       	call   800f33 <fd_lookup>
  801ae0:	83 c4 10             	add    $0x10,%esp
  801ae3:	85 c0                	test   %eax,%eax
  801ae5:	78 11                	js     801af8 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801ae7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801aea:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801af0:	39 10                	cmp    %edx,(%eax)
  801af2:	0f 94 c0             	sete   %al
  801af5:	0f b6 c0             	movzbl %al,%eax
}
  801af8:	c9                   	leave  
  801af9:	c3                   	ret    

00801afa <opencons>:

int
opencons(void)
{
  801afa:	55                   	push   %ebp
  801afb:	89 e5                	mov    %esp,%ebp
  801afd:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801b00:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b03:	50                   	push   %eax
  801b04:	e8 b7 f3 ff ff       	call   800ec0 <fd_alloc>
  801b09:	83 c4 10             	add    $0x10,%esp
  801b0c:	85 c0                	test   %eax,%eax
  801b0e:	78 3a                	js     801b4a <opencons+0x50>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801b10:	83 ec 04             	sub    $0x4,%esp
  801b13:	68 07 04 00 00       	push   $0x407
  801b18:	ff 75 f4             	pushl  -0xc(%ebp)
  801b1b:	6a 00                	push   $0x0
  801b1d:	e8 b2 f0 ff ff       	call   800bd4 <sys_page_alloc>
  801b22:	83 c4 10             	add    $0x10,%esp
  801b25:	85 c0                	test   %eax,%eax
  801b27:	78 21                	js     801b4a <opencons+0x50>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801b29:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801b2f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b32:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801b34:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b37:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801b3e:	83 ec 0c             	sub    $0xc,%esp
  801b41:	50                   	push   %eax
  801b42:	e8 51 f3 ff ff       	call   800e98 <fd2num>
  801b47:	83 c4 10             	add    $0x10,%esp
}
  801b4a:	c9                   	leave  
  801b4b:	c3                   	ret    

00801b4c <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801b4c:	55                   	push   %ebp
  801b4d:	89 e5                	mov    %esp,%ebp
  801b4f:	56                   	push   %esi
  801b50:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801b51:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801b54:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  801b5a:	e8 2a f0 ff ff       	call   800b89 <sys_getenvid>
  801b5f:	83 ec 0c             	sub    $0xc,%esp
  801b62:	ff 75 0c             	pushl  0xc(%ebp)
  801b65:	ff 75 08             	pushl  0x8(%ebp)
  801b68:	53                   	push   %ebx
  801b69:	50                   	push   %eax
  801b6a:	68 94 22 80 00       	push   $0x802294
  801b6f:	e8 28 e6 ff ff       	call   80019c <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801b74:	83 c4 18             	add    $0x18,%esp
  801b77:	56                   	push   %esi
  801b78:	ff 75 10             	pushl  0x10(%ebp)
  801b7b:	e8 cb e5 ff ff       	call   80014b <vcprintf>
	cprintf("\n");
  801b80:	c7 04 24 7f 22 80 00 	movl   $0x80227f,(%esp)
  801b87:	e8 10 e6 ff ff       	call   80019c <cprintf>
  801b8c:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801b8f:	cc                   	int3   
  801b90:	eb fd                	jmp    801b8f <_panic+0x43>
	...

00801b94 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801b94:	55                   	push   %ebp
  801b95:	89 e5                	mov    %esp,%ebp
  801b97:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b9a:	89 c2                	mov    %eax,%edx
  801b9c:	c1 ea 16             	shr    $0x16,%edx
  801b9f:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801ba6:	f6 c2 01             	test   $0x1,%dl
  801ba9:	74 1e                	je     801bc9 <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  801bab:	c1 e8 0c             	shr    $0xc,%eax
  801bae:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801bb5:	a8 01                	test   $0x1,%al
  801bb7:	74 17                	je     801bd0 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801bb9:	c1 e8 0c             	shr    $0xc,%eax
  801bbc:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  801bc3:	ef 
  801bc4:	0f b7 c0             	movzwl %ax,%eax
  801bc7:	eb 0c                	jmp    801bd5 <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  801bc9:	b8 00 00 00 00       	mov    $0x0,%eax
  801bce:	eb 05                	jmp    801bd5 <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  801bd0:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  801bd5:	c9                   	leave  
  801bd6:	c3                   	ret    
	...

00801bd8 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  801bd8:	55                   	push   %ebp
  801bd9:	89 e5                	mov    %esp,%ebp
  801bdb:	57                   	push   %edi
  801bdc:	56                   	push   %esi
  801bdd:	83 ec 10             	sub    $0x10,%esp
  801be0:	8b 7d 08             	mov    0x8(%ebp),%edi
  801be3:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  801be6:	89 7d f0             	mov    %edi,-0x10(%ebp)
  801be9:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  801bec:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  801bef:	8b 45 14             	mov    0x14(%ebp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  801bf2:	85 c0                	test   %eax,%eax
  801bf4:	75 2e                	jne    801c24 <__udivdi3+0x4c>
    {
      if (d0 > n1)
  801bf6:	39 f1                	cmp    %esi,%ecx
  801bf8:	77 5a                	ja     801c54 <__udivdi3+0x7c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  801bfa:	85 c9                	test   %ecx,%ecx
  801bfc:	75 0b                	jne    801c09 <__udivdi3+0x31>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  801bfe:	b8 01 00 00 00       	mov    $0x1,%eax
  801c03:	31 d2                	xor    %edx,%edx
  801c05:	f7 f1                	div    %ecx
  801c07:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  801c09:	31 d2                	xor    %edx,%edx
  801c0b:	89 f0                	mov    %esi,%eax
  801c0d:	f7 f1                	div    %ecx
  801c0f:	89 c6                	mov    %eax,%esi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801c11:	89 f8                	mov    %edi,%eax
  801c13:	f7 f1                	div    %ecx
  801c15:	89 c7                	mov    %eax,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801c17:	89 f8                	mov    %edi,%eax
  801c19:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801c1b:	83 c4 10             	add    $0x10,%esp
  801c1e:	5e                   	pop    %esi
  801c1f:	5f                   	pop    %edi
  801c20:	c9                   	leave  
  801c21:	c3                   	ret    
  801c22:	66 90                	xchg   %ax,%ax
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801c24:	39 f0                	cmp    %esi,%eax
  801c26:	77 1c                	ja     801c44 <__udivdi3+0x6c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  801c28:	0f bd f8             	bsr    %eax,%edi
	  if (bm == 0)
  801c2b:	83 f7 1f             	xor    $0x1f,%edi
  801c2e:	75 3c                	jne    801c6c <__udivdi3+0x94>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801c30:	39 f0                	cmp    %esi,%eax
  801c32:	0f 82 90 00 00 00    	jb     801cc8 <__udivdi3+0xf0>
  801c38:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801c3b:	39 55 f4             	cmp    %edx,-0xc(%ebp)
  801c3e:	0f 86 84 00 00 00    	jbe    801cc8 <__udivdi3+0xf0>
  801c44:	31 f6                	xor    %esi,%esi
  801c46:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801c48:	89 f8                	mov    %edi,%eax
  801c4a:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801c4c:	83 c4 10             	add    $0x10,%esp
  801c4f:	5e                   	pop    %esi
  801c50:	5f                   	pop    %edi
  801c51:	c9                   	leave  
  801c52:	c3                   	ret    
  801c53:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801c54:	89 f2                	mov    %esi,%edx
  801c56:	89 f8                	mov    %edi,%eax
  801c58:	f7 f1                	div    %ecx
  801c5a:	89 c7                	mov    %eax,%edi
  801c5c:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801c5e:	89 f8                	mov    %edi,%eax
  801c60:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801c62:	83 c4 10             	add    $0x10,%esp
  801c65:	5e                   	pop    %esi
  801c66:	5f                   	pop    %edi
  801c67:	c9                   	leave  
  801c68:	c3                   	ret    
  801c69:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  801c6c:	89 f9                	mov    %edi,%ecx
  801c6e:	d3 e0                	shl    %cl,%eax
  801c70:	89 45 e8             	mov    %eax,-0x18(%ebp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  801c73:	b8 20 00 00 00       	mov    $0x20,%eax
  801c78:	29 f8                	sub    %edi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  801c7a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801c7d:	88 c1                	mov    %al,%cl
  801c7f:	d3 ea                	shr    %cl,%edx
  801c81:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  801c84:	09 ca                	or     %ecx,%edx
  801c86:	89 55 ec             	mov    %edx,-0x14(%ebp)
	      d0 = d0 << bm;
  801c89:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801c8c:	89 f9                	mov    %edi,%ecx
  801c8e:	d3 e2                	shl    %cl,%edx
  801c90:	89 55 f4             	mov    %edx,-0xc(%ebp)
	      n2 = n1 >> b;
  801c93:	89 f2                	mov    %esi,%edx
  801c95:	88 c1                	mov    %al,%cl
  801c97:	d3 ea                	shr    %cl,%edx
  801c99:	89 55 e8             	mov    %edx,-0x18(%ebp)
	      n1 = (n1 << bm) | (n0 >> b);
  801c9c:	89 f2                	mov    %esi,%edx
  801c9e:	89 f9                	mov    %edi,%ecx
  801ca0:	d3 e2                	shl    %cl,%edx
  801ca2:	8b 75 f0             	mov    -0x10(%ebp),%esi
  801ca5:	88 c1                	mov    %al,%cl
  801ca7:	d3 ee                	shr    %cl,%esi
  801ca9:	09 d6                	or     %edx,%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  801cab:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  801cae:	89 f0                	mov    %esi,%eax
  801cb0:	89 ca                	mov    %ecx,%edx
  801cb2:	f7 75 ec             	divl   -0x14(%ebp)
  801cb5:	89 d1                	mov    %edx,%ecx
  801cb7:	89 c6                	mov    %eax,%esi
	      umul_ppmm (m1, m0, q0, d0);
  801cb9:	f7 65 f4             	mull   -0xc(%ebp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801cbc:	39 d1                	cmp    %edx,%ecx
  801cbe:	72 28                	jb     801ce8 <__udivdi3+0x110>
  801cc0:	74 1a                	je     801cdc <__udivdi3+0x104>
  801cc2:	89 f7                	mov    %esi,%edi
  801cc4:	31 f6                	xor    %esi,%esi
  801cc6:	eb 80                	jmp    801c48 <__udivdi3+0x70>
	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  801cc8:	31 f6                	xor    %esi,%esi
  801cca:	bf 01 00 00 00       	mov    $0x1,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801ccf:	89 f8                	mov    %edi,%eax
  801cd1:	89 f2                	mov    %esi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801cd3:	83 c4 10             	add    $0x10,%esp
  801cd6:	5e                   	pop    %esi
  801cd7:	5f                   	pop    %edi
  801cd8:	c9                   	leave  
  801cd9:	c3                   	ret    
  801cda:	66 90                	xchg   %ax,%ax

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  801cdc:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801cdf:	89 f9                	mov    %edi,%ecx
  801ce1:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801ce3:	39 c2                	cmp    %eax,%edx
  801ce5:	73 db                	jae    801cc2 <__udivdi3+0xea>
  801ce7:	90                   	nop
		{
		  q0--;
  801ce8:	8d 7e ff             	lea    -0x1(%esi),%edi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  801ceb:	31 f6                	xor    %esi,%esi
  801ced:	e9 56 ff ff ff       	jmp    801c48 <__udivdi3+0x70>
	...

00801cf4 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  801cf4:	55                   	push   %ebp
  801cf5:	89 e5                	mov    %esp,%ebp
  801cf7:	57                   	push   %edi
  801cf8:	56                   	push   %esi
  801cf9:	83 ec 20             	sub    $0x20,%esp
  801cfc:	8b 45 08             	mov    0x8(%ebp),%eax
  801cff:	8b 4d 10             	mov    0x10(%ebp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  801d02:	89 45 e8             	mov    %eax,-0x18(%ebp)
  801d05:	8b 75 0c             	mov    0xc(%ebp),%esi
  const DWunion dd = {.ll = d};
  801d08:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  801d0b:	8b 7d 14             	mov    0x14(%ebp),%edi
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  801d0e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  n1 = nn.s.high;
  801d11:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  801d13:	85 ff                	test   %edi,%edi
  801d15:	75 15                	jne    801d2c <__umoddi3+0x38>
    {
      if (d0 > n1)
  801d17:	39 f1                	cmp    %esi,%ecx
  801d19:	0f 86 99 00 00 00    	jbe    801db8 <__umoddi3+0xc4>
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801d1f:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  801d21:	89 d0                	mov    %edx,%eax
  801d23:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801d25:	83 c4 20             	add    $0x20,%esp
  801d28:	5e                   	pop    %esi
  801d29:	5f                   	pop    %edi
  801d2a:	c9                   	leave  
  801d2b:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801d2c:	39 f7                	cmp    %esi,%edi
  801d2e:	0f 87 a4 00 00 00    	ja     801dd8 <__umoddi3+0xe4>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  801d34:	0f bd c7             	bsr    %edi,%eax
	  if (bm == 0)
  801d37:	83 f0 1f             	xor    $0x1f,%eax
  801d3a:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801d3d:	0f 84 a1 00 00 00    	je     801de4 <__umoddi3+0xf0>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  801d43:	89 f8                	mov    %edi,%eax
  801d45:	8a 4d ec             	mov    -0x14(%ebp),%cl
  801d48:	d3 e0                	shl    %cl,%eax
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  801d4a:	bf 20 00 00 00       	mov    $0x20,%edi
  801d4f:	2b 7d ec             	sub    -0x14(%ebp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  801d52:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801d55:	89 f9                	mov    %edi,%ecx
  801d57:	d3 ea                	shr    %cl,%edx
  801d59:	09 c2                	or     %eax,%edx
  801d5b:	89 55 f0             	mov    %edx,-0x10(%ebp)
	      d0 = d0 << bm;
  801d5e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d61:	8a 4d ec             	mov    -0x14(%ebp),%cl
  801d64:	d3 e0                	shl    %cl,%eax
  801d66:	89 45 f4             	mov    %eax,-0xc(%ebp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  801d69:	89 f2                	mov    %esi,%edx
  801d6b:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  801d6d:	8b 45 e8             	mov    -0x18(%ebp),%eax
  801d70:	d3 e0                	shl    %cl,%eax
  801d72:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  801d75:	8b 45 e8             	mov    -0x18(%ebp),%eax
  801d78:	89 f9                	mov    %edi,%ecx
  801d7a:	d3 e8                	shr    %cl,%eax
  801d7c:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  801d7e:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  801d80:	89 f2                	mov    %esi,%edx
  801d82:	f7 75 f0             	divl   -0x10(%ebp)
  801d85:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  801d87:	f7 65 f4             	mull   -0xc(%ebp)
  801d8a:	89 55 e8             	mov    %edx,-0x18(%ebp)
  801d8d:	89 c1                	mov    %eax,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801d8f:	39 d6                	cmp    %edx,%esi
  801d91:	72 71                	jb     801e04 <__umoddi3+0x110>
  801d93:	74 7f                	je     801e14 <__umoddi3+0x120>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  801d95:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801d98:	29 c8                	sub    %ecx,%eax
  801d9a:	19 d6                	sbb    %edx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  801d9c:	8a 4d ec             	mov    -0x14(%ebp),%cl
  801d9f:	d3 e8                	shr    %cl,%eax
  801da1:	89 f2                	mov    %esi,%edx
  801da3:	89 f9                	mov    %edi,%ecx
  801da5:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  801da7:	09 d0                	or     %edx,%eax
  801da9:	89 f2                	mov    %esi,%edx
  801dab:	8a 4d ec             	mov    -0x14(%ebp),%cl
  801dae:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801db0:	83 c4 20             	add    $0x20,%esp
  801db3:	5e                   	pop    %esi
  801db4:	5f                   	pop    %edi
  801db5:	c9                   	leave  
  801db6:	c3                   	ret    
  801db7:	90                   	nop
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  801db8:	85 c9                	test   %ecx,%ecx
  801dba:	75 0b                	jne    801dc7 <__umoddi3+0xd3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  801dbc:	b8 01 00 00 00       	mov    $0x1,%eax
  801dc1:	31 d2                	xor    %edx,%edx
  801dc3:	f7 f1                	div    %ecx
  801dc5:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  801dc7:	89 f0                	mov    %esi,%eax
  801dc9:	31 d2                	xor    %edx,%edx
  801dcb:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801dcd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801dd0:	f7 f1                	div    %ecx
  801dd2:	e9 4a ff ff ff       	jmp    801d21 <__umoddi3+0x2d>
  801dd7:	90                   	nop
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  801dd8:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801dda:	83 c4 20             	add    $0x20,%esp
  801ddd:	5e                   	pop    %esi
  801dde:	5f                   	pop    %edi
  801ddf:	c9                   	leave  
  801de0:	c3                   	ret    
  801de1:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801de4:	39 f7                	cmp    %esi,%edi
  801de6:	72 05                	jb     801ded <__umoddi3+0xf9>
  801de8:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
  801deb:	77 0c                	ja     801df9 <__umoddi3+0x105>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  801ded:	89 f2                	mov    %esi,%edx
  801def:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801df2:	29 c8                	sub    %ecx,%eax
  801df4:	19 fa                	sbb    %edi,%edx
  801df6:	89 45 f0             	mov    %eax,-0x10(%ebp)

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  801df9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801dfc:	83 c4 20             	add    $0x20,%esp
  801dff:	5e                   	pop    %esi
  801e00:	5f                   	pop    %edi
  801e01:	c9                   	leave  
  801e02:	c3                   	ret    
  801e03:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  801e04:	8b 55 e8             	mov    -0x18(%ebp),%edx
  801e07:	89 c1                	mov    %eax,%ecx
  801e09:	2b 4d f4             	sub    -0xc(%ebp),%ecx
  801e0c:	1b 55 f0             	sbb    -0x10(%ebp),%edx
  801e0f:	eb 84                	jmp    801d95 <__umoddi3+0xa1>
  801e11:	8d 76 00             	lea    0x0(%esi),%esi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801e14:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801e17:	72 eb                	jb     801e04 <__umoddi3+0x110>
  801e19:	89 f2                	mov    %esi,%edx
  801e1b:	e9 75 ff ff ff       	jmp    801d95 <__umoddi3+0xa1>
